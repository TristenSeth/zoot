<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">    <title>crypto/sha3.zig - source view</title>
    <link rel="icon" href="data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAAgklEQVR4AWMYWuD7EllJIM4G4g4g5oIJ/odhOJ8wToOxSTXgNxDHoeiBMfA4+wGShjyYOCkG/IGqWQziEzYAoUAeiF9D5U+DxEg14DRU7jWIT5IBIOdCxf+A+CQZAAoopEB7QJwBCBwHiip8UYmRdrAlDpIMgApwQZNnNii5Dq0MBgCxxycBnwEd+wAAAABJRU5ErkJggg=="/>
    <style>
      body{
        font-family: system-ui, -apple-system, Roboto, "Segoe UI", sans-serif;
        margin: 0;
        line-height: 1.5;
      }

      pre > code {
        display: block;
        overflow: auto;
        line-height: normal;
        margin: 0em;
      }
      .tok-kw {
          color: #333;
          font-weight: bold;
      }
      .tok-str {
          color: #d14;
      }
      .tok-builtin {
          color: #005C7A;
      }
      .tok-comment {
          color: #545454;
          font-style: italic;
      }
      .tok-fn {
          color: #900;
          font-weight: bold;
      }
      .tok-null {
          color: #005C5C;
      }
      .tok-number {
          color: #005C5C;
      }
      .tok-type {
          color: #458;
          font-weight: bold;
      }
      pre {
        counter-reset: line;
      }
      pre .line:before {
        counter-increment: line;
        content: counter(line);
        display: inline-block;
        padding-right: 1em;
        width: 2em;
        text-align: right;
        color: #999;
      }

      @media (prefers-color-scheme: dark) {
        body{
            background:#222;
            color: #ccc;
        }
        pre > code {
            color: #ccc;
            background: #222;
            border: unset;
        }
        .tok-kw {
            color: #eee;
        }
        .tok-str {
            color: #2e5;
        }
        .tok-builtin {
            color: #ff894c;
        }
        .tok-comment {
            color: #aa7;
        }
        .tok-fn {
            color: #B1A0F8;
        }
        .tok-null {
            color: #ff8080;
        }
        .tok-number {
            color: #ff8080;
        }
        .tok-type {
            color: #68f;
        }
      }
    </style>
</head>
<body>
<pre><code><span class="line" id="L1"><span class="tok-kw">const</span> std = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;../std.zig&quot;</span>);</span>
<span class="line" id="L2"><span class="tok-kw">const</span> mem = std.mem;</span>
<span class="line" id="L3"><span class="tok-kw">const</span> math = std.math;</span>
<span class="line" id="L4"><span class="tok-kw">const</span> debug = std.debug;</span>
<span class="line" id="L5"><span class="tok-kw">const</span> htest = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;test.zig&quot;</span>);</span>
<span class="line" id="L6"></span>
<span class="line" id="L7"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> Sha3_224 = Keccak(<span class="tok-number">224</span>, <span class="tok-number">0x06</span>);</span>
<span class="line" id="L8"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> Sha3_256 = Keccak(<span class="tok-number">256</span>, <span class="tok-number">0x06</span>);</span>
<span class="line" id="L9"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> Sha3_384 = Keccak(<span class="tok-number">384</span>, <span class="tok-number">0x06</span>);</span>
<span class="line" id="L10"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> Sha3_512 = Keccak(<span class="tok-number">512</span>, <span class="tok-number">0x06</span>);</span>
<span class="line" id="L11"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> Keccak_256 = Keccak(<span class="tok-number">256</span>, <span class="tok-number">0x01</span>);</span>
<span class="line" id="L12"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> Keccak_512 = Keccak(<span class="tok-number">512</span>, <span class="tok-number">0x01</span>);</span>
<span class="line" id="L13"></span>
<span class="line" id="L14"><span class="tok-kw">fn</span> <span class="tok-fn">Keccak</span>(<span class="tok-kw">comptime</span> bits: <span class="tok-type">usize</span>, <span class="tok-kw">comptime</span> delim: <span class="tok-type">u8</span>) <span class="tok-type">type</span> {</span>
<span class="line" id="L15">    <span class="tok-kw">return</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L16">        <span class="tok-kw">const</span> Self = <span class="tok-builtin">@This</span>();</span>
<span class="line" id="L17">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> block_length = <span class="tok-number">200</span>;</span>
<span class="line" id="L18">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> digest_length = bits / <span class="tok-number">8</span>;</span>
<span class="line" id="L19">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> Options = <span class="tok-kw">struct</span> {};</span>
<span class="line" id="L20"></span>
<span class="line" id="L21">        s: [<span class="tok-number">200</span>]<span class="tok-type">u8</span>,</span>
<span class="line" id="L22">        offset: <span class="tok-type">usize</span>,</span>
<span class="line" id="L23">        rate: <span class="tok-type">usize</span>,</span>
<span class="line" id="L24"></span>
<span class="line" id="L25">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">init</span>(options: Options) Self {</span>
<span class="line" id="L26">            _ = options;</span>
<span class="line" id="L27">            <span class="tok-kw">return</span> Self{ .s = [_]<span class="tok-type">u8</span>{<span class="tok-number">0</span>} ** <span class="tok-number">200</span>, .offset = <span class="tok-number">0</span>, .rate = <span class="tok-number">200</span> - (bits / <span class="tok-number">4</span>) };</span>
<span class="line" id="L28">        }</span>
<span class="line" id="L29"></span>
<span class="line" id="L30">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">hash</span>(b: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, out: *[digest_length]<span class="tok-type">u8</span>, options: Options) <span class="tok-type">void</span> {</span>
<span class="line" id="L31">            <span class="tok-kw">var</span> d = Self.init(options);</span>
<span class="line" id="L32">            d.update(b);</span>
<span class="line" id="L33">            d.final(out);</span>
<span class="line" id="L34">        }</span>
<span class="line" id="L35"></span>
<span class="line" id="L36">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">update</span>(d: *Self, b: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L37">            <span class="tok-kw">var</span> ip: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L38">            <span class="tok-kw">var</span> len = b.len;</span>
<span class="line" id="L39">            <span class="tok-kw">var</span> rate = d.rate - d.offset;</span>
<span class="line" id="L40">            <span class="tok-kw">var</span> offset = d.offset;</span>
<span class="line" id="L41"></span>
<span class="line" id="L42">            <span class="tok-comment">// absorb</span>
</span>
<span class="line" id="L43">            <span class="tok-kw">while</span> (len &gt;= rate) {</span>
<span class="line" id="L44">                <span class="tok-kw">for</span> (d.s[offset .. offset + rate]) |*r, i|</span>
<span class="line" id="L45">                    r.* ^= b[ip..][i];</span>
<span class="line" id="L46"></span>
<span class="line" id="L47">                keccakF(<span class="tok-number">1600</span>, &amp;d.s);</span>
<span class="line" id="L48"></span>
<span class="line" id="L49">                ip += rate;</span>
<span class="line" id="L50">                len -= rate;</span>
<span class="line" id="L51">                rate = d.rate;</span>
<span class="line" id="L52">                offset = <span class="tok-number">0</span>;</span>
<span class="line" id="L53">            }</span>
<span class="line" id="L54"></span>
<span class="line" id="L55">            <span class="tok-kw">for</span> (d.s[offset .. offset + len]) |*r, i|</span>
<span class="line" id="L56">                r.* ^= b[ip..][i];</span>
<span class="line" id="L57"></span>
<span class="line" id="L58">            d.offset = offset + len;</span>
<span class="line" id="L59">        }</span>
<span class="line" id="L60"></span>
<span class="line" id="L61">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">final</span>(d: *Self, out: *[digest_length]<span class="tok-type">u8</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L62">            <span class="tok-comment">// padding</span>
</span>
<span class="line" id="L63">            d.s[d.offset] ^= delim;</span>
<span class="line" id="L64">            d.s[d.rate - <span class="tok-number">1</span>] ^= <span class="tok-number">0x80</span>;</span>
<span class="line" id="L65"></span>
<span class="line" id="L66">            keccakF(<span class="tok-number">1600</span>, &amp;d.s);</span>
<span class="line" id="L67"></span>
<span class="line" id="L68">            <span class="tok-comment">// squeeze</span>
</span>
<span class="line" id="L69">            <span class="tok-kw">var</span> op: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L70">            <span class="tok-kw">var</span> len: <span class="tok-type">usize</span> = bits / <span class="tok-number">8</span>;</span>
<span class="line" id="L71"></span>
<span class="line" id="L72">            <span class="tok-kw">while</span> (len &gt;= d.rate) {</span>
<span class="line" id="L73">                mem.copy(<span class="tok-type">u8</span>, out[op..], d.s[<span class="tok-number">0</span>..d.rate]);</span>
<span class="line" id="L74">                keccakF(<span class="tok-number">1600</span>, &amp;d.s);</span>
<span class="line" id="L75">                op += d.rate;</span>
<span class="line" id="L76">                len -= d.rate;</span>
<span class="line" id="L77">            }</span>
<span class="line" id="L78"></span>
<span class="line" id="L79">            mem.copy(<span class="tok-type">u8</span>, out[op..], d.s[<span class="tok-number">0</span>..len]);</span>
<span class="line" id="L80">        }</span>
<span class="line" id="L81"></span>
<span class="line" id="L82">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> Error = <span class="tok-kw">error</span>{};</span>
<span class="line" id="L83">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> Writer = std.io.Writer(*Self, Error, write);</span>
<span class="line" id="L84"></span>
<span class="line" id="L85">        <span class="tok-kw">fn</span> <span class="tok-fn">write</span>(self: *Self, bytes: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) Error!<span class="tok-type">usize</span> {</span>
<span class="line" id="L86">            self.update(bytes);</span>
<span class="line" id="L87">            <span class="tok-kw">return</span> bytes.len;</span>
<span class="line" id="L88">        }</span>
<span class="line" id="L89"></span>
<span class="line" id="L90">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">writer</span>(self: *Self) Writer {</span>
<span class="line" id="L91">            <span class="tok-kw">return</span> .{ .context = self };</span>
<span class="line" id="L92">        }</span>
<span class="line" id="L93">    };</span>
<span class="line" id="L94">}</span>
<span class="line" id="L95"></span>
<span class="line" id="L96"><span class="tok-kw">const</span> RC = [_]<span class="tok-type">u64</span>{</span>
<span class="line" id="L97">    <span class="tok-number">0x0000000000000001</span>, <span class="tok-number">0x0000000000008082</span>, <span class="tok-number">0x800000000000808a</span>, <span class="tok-number">0x8000000080008000</span>,</span>
<span class="line" id="L98">    <span class="tok-number">0x000000000000808b</span>, <span class="tok-number">0x0000000080000001</span>, <span class="tok-number">0x8000000080008081</span>, <span class="tok-number">0x8000000000008009</span>,</span>
<span class="line" id="L99">    <span class="tok-number">0x000000000000008a</span>, <span class="tok-number">0x0000000000000088</span>, <span class="tok-number">0x0000000080008009</span>, <span class="tok-number">0x000000008000000a</span>,</span>
<span class="line" id="L100">    <span class="tok-number">0x000000008000808b</span>, <span class="tok-number">0x800000000000008b</span>, <span class="tok-number">0x8000000000008089</span>, <span class="tok-number">0x8000000000008003</span>,</span>
<span class="line" id="L101">    <span class="tok-number">0x8000000000008002</span>, <span class="tok-number">0x8000000000000080</span>, <span class="tok-number">0x000000000000800a</span>, <span class="tok-number">0x800000008000000a</span>,</span>
<span class="line" id="L102">    <span class="tok-number">0x8000000080008081</span>, <span class="tok-number">0x8000000000008080</span>, <span class="tok-number">0x0000000080000001</span>, <span class="tok-number">0x8000000080008008</span>,</span>
<span class="line" id="L103">};</span>
<span class="line" id="L104"></span>
<span class="line" id="L105"><span class="tok-kw">const</span> ROTC = [_]<span class="tok-type">usize</span>{</span>
<span class="line" id="L106">    <span class="tok-number">1</span>, <span class="tok-number">3</span>, <span class="tok-number">6</span>, <span class="tok-number">10</span>, <span class="tok-number">15</span>, <span class="tok-number">21</span>, <span class="tok-number">28</span>, <span class="tok-number">36</span>, <span class="tok-number">45</span>, <span class="tok-number">55</span>, <span class="tok-number">2</span>, <span class="tok-number">14</span>, <span class="tok-number">27</span>, <span class="tok-number">41</span>, <span class="tok-number">56</span>, <span class="tok-number">8</span>, <span class="tok-number">25</span>, <span class="tok-number">43</span>, <span class="tok-number">62</span>, <span class="tok-number">18</span>, <span class="tok-number">39</span>, <span class="tok-number">61</span>, <span class="tok-number">20</span>, <span class="tok-number">44</span>,</span>
<span class="line" id="L107">};</span>
<span class="line" id="L108"></span>
<span class="line" id="L109"><span class="tok-kw">const</span> PIL = [_]<span class="tok-type">usize</span>{</span>
<span class="line" id="L110">    <span class="tok-number">10</span>, <span class="tok-number">7</span>, <span class="tok-number">11</span>, <span class="tok-number">17</span>, <span class="tok-number">18</span>, <span class="tok-number">3</span>, <span class="tok-number">5</span>, <span class="tok-number">16</span>, <span class="tok-number">8</span>, <span class="tok-number">21</span>, <span class="tok-number">24</span>, <span class="tok-number">4</span>, <span class="tok-number">15</span>, <span class="tok-number">23</span>, <span class="tok-number">19</span>, <span class="tok-number">13</span>, <span class="tok-number">12</span>, <span class="tok-number">2</span>, <span class="tok-number">20</span>, <span class="tok-number">14</span>, <span class="tok-number">22</span>, <span class="tok-number">9</span>, <span class="tok-number">6</span>, <span class="tok-number">1</span>,</span>
<span class="line" id="L111">};</span>
<span class="line" id="L112"></span>
<span class="line" id="L113"><span class="tok-kw">const</span> M5 = [_]<span class="tok-type">usize</span>{</span>
<span class="line" id="L114">    <span class="tok-number">0</span>, <span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">4</span>, <span class="tok-number">0</span>, <span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">4</span>,</span>
<span class="line" id="L115">};</span>
<span class="line" id="L116"></span>
<span class="line" id="L117"><span class="tok-kw">fn</span> <span class="tok-fn">keccakF</span>(<span class="tok-kw">comptime</span> F: <span class="tok-type">usize</span>, d: *[F / <span class="tok-number">8</span>]<span class="tok-type">u8</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L118">    <span class="tok-kw">const</span> B = F / <span class="tok-number">25</span>;</span>
<span class="line" id="L119">    <span class="tok-kw">const</span> no_rounds = <span class="tok-kw">comptime</span> x: {</span>
<span class="line" id="L120">        <span class="tok-kw">break</span> :x <span class="tok-number">12</span> + <span class="tok-number">2</span> * math.log2(B);</span>
<span class="line" id="L121">    };</span>
<span class="line" id="L122"></span>
<span class="line" id="L123">    <span class="tok-kw">var</span> s = [_]<span class="tok-type">u64</span>{<span class="tok-number">0</span>} ** <span class="tok-number">25</span>;</span>
<span class="line" id="L124">    <span class="tok-kw">var</span> t = [_]<span class="tok-type">u64</span>{<span class="tok-number">0</span>} ** <span class="tok-number">1</span>;</span>
<span class="line" id="L125">    <span class="tok-kw">var</span> c = [_]<span class="tok-type">u64</span>{<span class="tok-number">0</span>} ** <span class="tok-number">5</span>;</span>
<span class="line" id="L126"></span>
<span class="line" id="L127">    <span class="tok-kw">for</span> (s) |*r, i| {</span>
<span class="line" id="L128">        r.* = mem.readIntLittle(<span class="tok-type">u64</span>, d[<span class="tok-number">8</span> * i ..][<span class="tok-number">0</span>..<span class="tok-number">8</span>]);</span>
<span class="line" id="L129">    }</span>
<span class="line" id="L130"></span>
<span class="line" id="L131">    <span class="tok-kw">for</span> (RC[<span class="tok-number">0</span>..no_rounds]) |round| {</span>
<span class="line" id="L132">        <span class="tok-comment">// theta</span>
</span>
<span class="line" id="L133">        <span class="tok-kw">comptime</span> <span class="tok-kw">var</span> x: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L134">        <span class="tok-kw">inline</span> <span class="tok-kw">while</span> (x &lt; <span class="tok-number">5</span>) : (x += <span class="tok-number">1</span>) {</span>
<span class="line" id="L135">            c[x] = s[x] ^ s[x + <span class="tok-number">5</span>] ^ s[x + <span class="tok-number">10</span>] ^ s[x + <span class="tok-number">15</span>] ^ s[x + <span class="tok-number">20</span>];</span>
<span class="line" id="L136">        }</span>
<span class="line" id="L137">        x = <span class="tok-number">0</span>;</span>
<span class="line" id="L138">        <span class="tok-kw">inline</span> <span class="tok-kw">while</span> (x &lt; <span class="tok-number">5</span>) : (x += <span class="tok-number">1</span>) {</span>
<span class="line" id="L139">            t[<span class="tok-number">0</span>] = c[M5[x + <span class="tok-number">4</span>]] ^ math.rotl(<span class="tok-type">u64</span>, c[M5[x + <span class="tok-number">1</span>]], <span class="tok-builtin">@as</span>(<span class="tok-type">usize</span>, <span class="tok-number">1</span>));</span>
<span class="line" id="L140">            <span class="tok-kw">comptime</span> <span class="tok-kw">var</span> y: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L141">            <span class="tok-kw">inline</span> <span class="tok-kw">while</span> (y &lt; <span class="tok-number">5</span>) : (y += <span class="tok-number">1</span>) {</span>
<span class="line" id="L142">                s[x + y * <span class="tok-number">5</span>] ^= t[<span class="tok-number">0</span>];</span>
<span class="line" id="L143">            }</span>
<span class="line" id="L144">        }</span>
<span class="line" id="L145"></span>
<span class="line" id="L146">        <span class="tok-comment">// rho+pi</span>
</span>
<span class="line" id="L147">        t[<span class="tok-number">0</span>] = s[<span class="tok-number">1</span>];</span>
<span class="line" id="L148">        x = <span class="tok-number">0</span>;</span>
<span class="line" id="L149">        <span class="tok-kw">inline</span> <span class="tok-kw">while</span> (x &lt; <span class="tok-number">24</span>) : (x += <span class="tok-number">1</span>) {</span>
<span class="line" id="L150">            c[<span class="tok-number">0</span>] = s[PIL[x]];</span>
<span class="line" id="L151">            s[PIL[x]] = math.rotl(<span class="tok-type">u64</span>, t[<span class="tok-number">0</span>], ROTC[x]);</span>
<span class="line" id="L152">            t[<span class="tok-number">0</span>] = c[<span class="tok-number">0</span>];</span>
<span class="line" id="L153">        }</span>
<span class="line" id="L154"></span>
<span class="line" id="L155">        <span class="tok-comment">// chi</span>
</span>
<span class="line" id="L156">        <span class="tok-kw">comptime</span> <span class="tok-kw">var</span> y: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L157">        <span class="tok-kw">inline</span> <span class="tok-kw">while</span> (y &lt; <span class="tok-number">5</span>) : (y += <span class="tok-number">1</span>) {</span>
<span class="line" id="L158">            x = <span class="tok-number">0</span>;</span>
<span class="line" id="L159">            <span class="tok-kw">inline</span> <span class="tok-kw">while</span> (x &lt; <span class="tok-number">5</span>) : (x += <span class="tok-number">1</span>) {</span>
<span class="line" id="L160">                c[x] = s[x + y * <span class="tok-number">5</span>];</span>
<span class="line" id="L161">            }</span>
<span class="line" id="L162">            x = <span class="tok-number">0</span>;</span>
<span class="line" id="L163">            <span class="tok-kw">inline</span> <span class="tok-kw">while</span> (x &lt; <span class="tok-number">5</span>) : (x += <span class="tok-number">1</span>) {</span>
<span class="line" id="L164">                s[x + y * <span class="tok-number">5</span>] = c[x] ^ (~c[M5[x + <span class="tok-number">1</span>]] &amp; c[M5[x + <span class="tok-number">2</span>]]);</span>
<span class="line" id="L165">            }</span>
<span class="line" id="L166">        }</span>
<span class="line" id="L167"></span>
<span class="line" id="L168">        <span class="tok-comment">// iota</span>
</span>
<span class="line" id="L169">        s[<span class="tok-number">0</span>] ^= round;</span>
<span class="line" id="L170">    }</span>
<span class="line" id="L171"></span>
<span class="line" id="L172">    <span class="tok-kw">for</span> (s) |r, i| {</span>
<span class="line" id="L173">        mem.writeIntLittle(<span class="tok-type">u64</span>, d[<span class="tok-number">8</span> * i ..][<span class="tok-number">0</span>..<span class="tok-number">8</span>], r);</span>
<span class="line" id="L174">    }</span>
<span class="line" id="L175">}</span>
<span class="line" id="L176"></span>
<span class="line" id="L177"><span class="tok-kw">test</span> <span class="tok-str">&quot;sha3-224 single&quot;</span> {</span>
<span class="line" id="L178">    <span class="tok-kw">try</span> htest.assertEqualHash(Sha3_224, <span class="tok-str">&quot;6b4e03423667dbb73b6e15454f0eb1abd4597f9a1b078e3f5b5a6bc7&quot;</span>, <span class="tok-str">&quot;&quot;</span>);</span>
<span class="line" id="L179">    <span class="tok-kw">try</span> htest.assertEqualHash(Sha3_224, <span class="tok-str">&quot;e642824c3f8cf24ad09234ee7d3c766fc9a3a5168d0c94ad73b46fdf&quot;</span>, <span class="tok-str">&quot;abc&quot;</span>);</span>
<span class="line" id="L180">    <span class="tok-kw">try</span> htest.assertEqualHash(Sha3_224, <span class="tok-str">&quot;543e6868e1666c1a643630df77367ae5a62a85070a51c14cbf665cbc&quot;</span>, <span class="tok-str">&quot;abcdefghbcdefghicdefghijdefghijkefghijklfghijklmghijklmnhijklmnoijklmnopjklmnopqklmnopqrlmnopqrsmnopqrstnopqrstu&quot;</span>);</span>
<span class="line" id="L181">}</span>
<span class="line" id="L182"></span>
<span class="line" id="L183"><span class="tok-kw">test</span> <span class="tok-str">&quot;sha3-224 streaming&quot;</span> {</span>
<span class="line" id="L184">    <span class="tok-kw">var</span> h = Sha3_224.init(.{});</span>
<span class="line" id="L185">    <span class="tok-kw">var</span> out: [<span class="tok-number">28</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L186"></span>
<span class="line" id="L187">    h.final(out[<span class="tok-number">0</span>..]);</span>
<span class="line" id="L188">    <span class="tok-kw">try</span> htest.assertEqual(<span class="tok-str">&quot;6b4e03423667dbb73b6e15454f0eb1abd4597f9a1b078e3f5b5a6bc7&quot;</span>, out[<span class="tok-number">0</span>..]);</span>
<span class="line" id="L189"></span>
<span class="line" id="L190">    h = Sha3_224.init(.{});</span>
<span class="line" id="L191">    h.update(<span class="tok-str">&quot;abc&quot;</span>);</span>
<span class="line" id="L192">    h.final(out[<span class="tok-number">0</span>..]);</span>
<span class="line" id="L193">    <span class="tok-kw">try</span> htest.assertEqual(<span class="tok-str">&quot;e642824c3f8cf24ad09234ee7d3c766fc9a3a5168d0c94ad73b46fdf&quot;</span>, out[<span class="tok-number">0</span>..]);</span>
<span class="line" id="L194"></span>
<span class="line" id="L195">    h = Sha3_224.init(.{});</span>
<span class="line" id="L196">    h.update(<span class="tok-str">&quot;a&quot;</span>);</span>
<span class="line" id="L197">    h.update(<span class="tok-str">&quot;b&quot;</span>);</span>
<span class="line" id="L198">    h.update(<span class="tok-str">&quot;c&quot;</span>);</span>
<span class="line" id="L199">    h.final(out[<span class="tok-number">0</span>..]);</span>
<span class="line" id="L200">    <span class="tok-kw">try</span> htest.assertEqual(<span class="tok-str">&quot;e642824c3f8cf24ad09234ee7d3c766fc9a3a5168d0c94ad73b46fdf&quot;</span>, out[<span class="tok-number">0</span>..]);</span>
<span class="line" id="L201">}</span>
<span class="line" id="L202"></span>
<span class="line" id="L203"><span class="tok-kw">test</span> <span class="tok-str">&quot;sha3-256 single&quot;</span> {</span>
<span class="line" id="L204">    <span class="tok-kw">try</span> htest.assertEqualHash(Sha3_256, <span class="tok-str">&quot;a7ffc6f8bf1ed76651c14756a061d662f580ff4de43b49fa82d80a4b80f8434a&quot;</span>, <span class="tok-str">&quot;&quot;</span>);</span>
<span class="line" id="L205">    <span class="tok-kw">try</span> htest.assertEqualHash(Sha3_256, <span class="tok-str">&quot;3a985da74fe225b2045c172d6bd390bd855f086e3e9d525b46bfe24511431532&quot;</span>, <span class="tok-str">&quot;abc&quot;</span>);</span>
<span class="line" id="L206">    <span class="tok-kw">try</span> htest.assertEqualHash(Sha3_256, <span class="tok-str">&quot;916f6061fe879741ca6469b43971dfdb28b1a32dc36cb3254e812be27aad1d18&quot;</span>, <span class="tok-str">&quot;abcdefghbcdefghicdefghijdefghijkefghijklfghijklmghijklmnhijklmnoijklmnopjklmnopqklmnopqrlmnopqrsmnopqrstnopqrstu&quot;</span>);</span>
<span class="line" id="L207">}</span>
<span class="line" id="L208"></span>
<span class="line" id="L209"><span class="tok-kw">test</span> <span class="tok-str">&quot;sha3-256 streaming&quot;</span> {</span>
<span class="line" id="L210">    <span class="tok-kw">var</span> h = Sha3_256.init(.{});</span>
<span class="line" id="L211">    <span class="tok-kw">var</span> out: [<span class="tok-number">32</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L212"></span>
<span class="line" id="L213">    h.final(out[<span class="tok-number">0</span>..]);</span>
<span class="line" id="L214">    <span class="tok-kw">try</span> htest.assertEqual(<span class="tok-str">&quot;a7ffc6f8bf1ed76651c14756a061d662f580ff4de43b49fa82d80a4b80f8434a&quot;</span>, out[<span class="tok-number">0</span>..]);</span>
<span class="line" id="L215"></span>
<span class="line" id="L216">    h = Sha3_256.init(.{});</span>
<span class="line" id="L217">    h.update(<span class="tok-str">&quot;abc&quot;</span>);</span>
<span class="line" id="L218">    h.final(out[<span class="tok-number">0</span>..]);</span>
<span class="line" id="L219">    <span class="tok-kw">try</span> htest.assertEqual(<span class="tok-str">&quot;3a985da74fe225b2045c172d6bd390bd855f086e3e9d525b46bfe24511431532&quot;</span>, out[<span class="tok-number">0</span>..]);</span>
<span class="line" id="L220"></span>
<span class="line" id="L221">    h = Sha3_256.init(.{});</span>
<span class="line" id="L222">    h.update(<span class="tok-str">&quot;a&quot;</span>);</span>
<span class="line" id="L223">    h.update(<span class="tok-str">&quot;b&quot;</span>);</span>
<span class="line" id="L224">    h.update(<span class="tok-str">&quot;c&quot;</span>);</span>
<span class="line" id="L225">    h.final(out[<span class="tok-number">0</span>..]);</span>
<span class="line" id="L226">    <span class="tok-kw">try</span> htest.assertEqual(<span class="tok-str">&quot;3a985da74fe225b2045c172d6bd390bd855f086e3e9d525b46bfe24511431532&quot;</span>, out[<span class="tok-number">0</span>..]);</span>
<span class="line" id="L227">}</span>
<span class="line" id="L228"></span>
<span class="line" id="L229"><span class="tok-kw">test</span> <span class="tok-str">&quot;sha3-256 aligned final&quot;</span> {</span>
<span class="line" id="L230">    <span class="tok-kw">var</span> block = [_]<span class="tok-type">u8</span>{<span class="tok-number">0</span>} ** Sha3_256.block_length;</span>
<span class="line" id="L231">    <span class="tok-kw">var</span> out: [Sha3_256.digest_length]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L232"></span>
<span class="line" id="L233">    <span class="tok-kw">var</span> h = Sha3_256.init(.{});</span>
<span class="line" id="L234">    h.update(&amp;block);</span>
<span class="line" id="L235">    h.final(out[<span class="tok-number">0</span>..]);</span>
<span class="line" id="L236">}</span>
<span class="line" id="L237"></span>
<span class="line" id="L238"><span class="tok-kw">test</span> <span class="tok-str">&quot;sha3-384 single&quot;</span> {</span>
<span class="line" id="L239">    <span class="tok-kw">const</span> h1 = <span class="tok-str">&quot;0c63a75b845e4f7d01107d852e4c2485c51a50aaaa94fc61995e71bbee983a2ac3713831264adb47fb6bd1e058d5f004&quot;</span>;</span>
<span class="line" id="L240">    <span class="tok-kw">try</span> htest.assertEqualHash(Sha3_384, h1, <span class="tok-str">&quot;&quot;</span>);</span>
<span class="line" id="L241">    <span class="tok-kw">const</span> h2 = <span class="tok-str">&quot;ec01498288516fc926459f58e2c6ad8df9b473cb0fc08c2596da7cf0e49be4b298d88cea927ac7f539f1edf228376d25&quot;</span>;</span>
<span class="line" id="L242">    <span class="tok-kw">try</span> htest.assertEqualHash(Sha3_384, h2, <span class="tok-str">&quot;abc&quot;</span>);</span>
<span class="line" id="L243">    <span class="tok-kw">const</span> h3 = <span class="tok-str">&quot;79407d3b5916b59c3e30b09822974791c313fb9ecc849e406f23592d04f625dc8c709b98b43b3852b337216179aa7fc7&quot;</span>;</span>
<span class="line" id="L244">    <span class="tok-kw">try</span> htest.assertEqualHash(Sha3_384, h3, <span class="tok-str">&quot;abcdefghbcdefghicdefghijdefghijkefghijklfghijklmghijklmnhijklmnoijklmnopjklmnopqklmnopqrlmnopqrsmnopqrstnopqrstu&quot;</span>);</span>
<span class="line" id="L245">}</span>
<span class="line" id="L246"></span>
<span class="line" id="L247"><span class="tok-kw">test</span> <span class="tok-str">&quot;sha3-384 streaming&quot;</span> {</span>
<span class="line" id="L248">    <span class="tok-kw">var</span> h = Sha3_384.init(.{});</span>
<span class="line" id="L249">    <span class="tok-kw">var</span> out: [<span class="tok-number">48</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L250"></span>
<span class="line" id="L251">    <span class="tok-kw">const</span> h1 = <span class="tok-str">&quot;0c63a75b845e4f7d01107d852e4c2485c51a50aaaa94fc61995e71bbee983a2ac3713831264adb47fb6bd1e058d5f004&quot;</span>;</span>
<span class="line" id="L252">    h.final(out[<span class="tok-number">0</span>..]);</span>
<span class="line" id="L253">    <span class="tok-kw">try</span> htest.assertEqual(h1, out[<span class="tok-number">0</span>..]);</span>
<span class="line" id="L254"></span>
<span class="line" id="L255">    <span class="tok-kw">const</span> h2 = <span class="tok-str">&quot;ec01498288516fc926459f58e2c6ad8df9b473cb0fc08c2596da7cf0e49be4b298d88cea927ac7f539f1edf228376d25&quot;</span>;</span>
<span class="line" id="L256">    h = Sha3_384.init(.{});</span>
<span class="line" id="L257">    h.update(<span class="tok-str">&quot;abc&quot;</span>);</span>
<span class="line" id="L258">    h.final(out[<span class="tok-number">0</span>..]);</span>
<span class="line" id="L259">    <span class="tok-kw">try</span> htest.assertEqual(h2, out[<span class="tok-number">0</span>..]);</span>
<span class="line" id="L260"></span>
<span class="line" id="L261">    h = Sha3_384.init(.{});</span>
<span class="line" id="L262">    h.update(<span class="tok-str">&quot;a&quot;</span>);</span>
<span class="line" id="L263">    h.update(<span class="tok-str">&quot;b&quot;</span>);</span>
<span class="line" id="L264">    h.update(<span class="tok-str">&quot;c&quot;</span>);</span>
<span class="line" id="L265">    h.final(out[<span class="tok-number">0</span>..]);</span>
<span class="line" id="L266">    <span class="tok-kw">try</span> htest.assertEqual(h2, out[<span class="tok-number">0</span>..]);</span>
<span class="line" id="L267">}</span>
<span class="line" id="L268"></span>
<span class="line" id="L269"><span class="tok-kw">test</span> <span class="tok-str">&quot;sha3-512 single&quot;</span> {</span>
<span class="line" id="L270">    <span class="tok-kw">const</span> h1 = <span class="tok-str">&quot;a69f73cca23a9ac5c8b567dc185a756e97c982164fe25859e0d1dcc1475c80a615b2123af1f5f94c11e3e9402c3ac558f500199d95b6d3e301758586281dcd26&quot;</span>;</span>
<span class="line" id="L271">    <span class="tok-kw">try</span> htest.assertEqualHash(Sha3_512, h1, <span class="tok-str">&quot;&quot;</span>);</span>
<span class="line" id="L272">    <span class="tok-kw">const</span> h2 = <span class="tok-str">&quot;b751850b1a57168a5693cd924b6b096e08f621827444f70d884f5d0240d2712e10e116e9192af3c91a7ec57647e3934057340b4cf408d5a56592f8274eec53f0&quot;</span>;</span>
<span class="line" id="L273">    <span class="tok-kw">try</span> htest.assertEqualHash(Sha3_512, h2, <span class="tok-str">&quot;abc&quot;</span>);</span>
<span class="line" id="L274">    <span class="tok-kw">const</span> h3 = <span class="tok-str">&quot;afebb2ef542e6579c50cad06d2e578f9f8dd6881d7dc824d26360feebf18a4fa73e3261122948efcfd492e74e82e2189ed0fb440d187f382270cb455f21dd185&quot;</span>;</span>
<span class="line" id="L275">    <span class="tok-kw">try</span> htest.assertEqualHash(Sha3_512, h3, <span class="tok-str">&quot;abcdefghbcdefghicdefghijdefghijkefghijklfghijklmghijklmnhijklmnoijklmnopjklmnopqklmnopqrlmnopqrsmnopqrstnopqrstu&quot;</span>);</span>
<span class="line" id="L276">}</span>
<span class="line" id="L277"></span>
<span class="line" id="L278"><span class="tok-kw">test</span> <span class="tok-str">&quot;sha3-512 streaming&quot;</span> {</span>
<span class="line" id="L279">    <span class="tok-kw">var</span> h = Sha3_512.init(.{});</span>
<span class="line" id="L280">    <span class="tok-kw">var</span> out: [<span class="tok-number">64</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L281"></span>
<span class="line" id="L282">    <span class="tok-kw">const</span> h1 = <span class="tok-str">&quot;a69f73cca23a9ac5c8b567dc185a756e97c982164fe25859e0d1dcc1475c80a615b2123af1f5f94c11e3e9402c3ac558f500199d95b6d3e301758586281dcd26&quot;</span>;</span>
<span class="line" id="L283">    h.final(out[<span class="tok-number">0</span>..]);</span>
<span class="line" id="L284">    <span class="tok-kw">try</span> htest.assertEqual(h1, out[<span class="tok-number">0</span>..]);</span>
<span class="line" id="L285"></span>
<span class="line" id="L286">    <span class="tok-kw">const</span> h2 = <span class="tok-str">&quot;b751850b1a57168a5693cd924b6b096e08f621827444f70d884f5d0240d2712e10e116e9192af3c91a7ec57647e3934057340b4cf408d5a56592f8274eec53f0&quot;</span>;</span>
<span class="line" id="L287">    h = Sha3_512.init(.{});</span>
<span class="line" id="L288">    h.update(<span class="tok-str">&quot;abc&quot;</span>);</span>
<span class="line" id="L289">    h.final(out[<span class="tok-number">0</span>..]);</span>
<span class="line" id="L290">    <span class="tok-kw">try</span> htest.assertEqual(h2, out[<span class="tok-number">0</span>..]);</span>
<span class="line" id="L291"></span>
<span class="line" id="L292">    h = Sha3_512.init(.{});</span>
<span class="line" id="L293">    h.update(<span class="tok-str">&quot;a&quot;</span>);</span>
<span class="line" id="L294">    h.update(<span class="tok-str">&quot;b&quot;</span>);</span>
<span class="line" id="L295">    h.update(<span class="tok-str">&quot;c&quot;</span>);</span>
<span class="line" id="L296">    h.final(out[<span class="tok-number">0</span>..]);</span>
<span class="line" id="L297">    <span class="tok-kw">try</span> htest.assertEqual(h2, out[<span class="tok-number">0</span>..]);</span>
<span class="line" id="L298">}</span>
<span class="line" id="L299"></span>
<span class="line" id="L300"><span class="tok-kw">test</span> <span class="tok-str">&quot;sha3-512 aligned final&quot;</span> {</span>
<span class="line" id="L301">    <span class="tok-kw">var</span> block = [_]<span class="tok-type">u8</span>{<span class="tok-number">0</span>} ** Sha3_512.block_length;</span>
<span class="line" id="L302">    <span class="tok-kw">var</span> out: [Sha3_512.digest_length]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L303"></span>
<span class="line" id="L304">    <span class="tok-kw">var</span> h = Sha3_512.init(.{});</span>
<span class="line" id="L305">    h.update(&amp;block);</span>
<span class="line" id="L306">    h.final(out[<span class="tok-number">0</span>..]);</span>
<span class="line" id="L307">}</span>
<span class="line" id="L308"></span>
<span class="line" id="L309"><span class="tok-kw">test</span> <span class="tok-str">&quot;keccak-256 single&quot;</span> {</span>
<span class="line" id="L310">    <span class="tok-kw">try</span> htest.assertEqualHash(Keccak_256, <span class="tok-str">&quot;c5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470&quot;</span>, <span class="tok-str">&quot;&quot;</span>);</span>
<span class="line" id="L311">    <span class="tok-kw">try</span> htest.assertEqualHash(Keccak_256, <span class="tok-str">&quot;4e03657aea45a94fc7d47ba826c8d667c0d1e6e33a64a036ec44f58fa12d6c45&quot;</span>, <span class="tok-str">&quot;abc&quot;</span>);</span>
<span class="line" id="L312">    <span class="tok-kw">try</span> htest.assertEqualHash(Keccak_256, <span class="tok-str">&quot;f519747ed599024f3882238e5ab43960132572b7345fbeb9a90769dafd21ad67&quot;</span>, <span class="tok-str">&quot;abcdefghbcdefghicdefghijdefghijkefghijklfghijklmghijklmnhijklmnoijklmnopjklmnopqklmnopqrlmnopqrsmnopqrstnopqrstu&quot;</span>);</span>
<span class="line" id="L313">}</span>
<span class="line" id="L314"></span>
<span class="line" id="L315"><span class="tok-kw">test</span> <span class="tok-str">&quot;keccak-512 single&quot;</span> {</span>
<span class="line" id="L316">    <span class="tok-kw">try</span> htest.assertEqualHash(Keccak_512, <span class="tok-str">&quot;0eab42de4c3ceb9235fc91acffe746b29c29a8c366b7c60e4e67c466f36a4304c00fa9caf9d87976ba469bcbe06713b435f091ef2769fb160cdab33d3670680e&quot;</span>, <span class="tok-str">&quot;&quot;</span>);</span>
<span class="line" id="L317">    <span class="tok-kw">try</span> htest.assertEqualHash(Keccak_512, <span class="tok-str">&quot;18587dc2ea106b9a1563e32b3312421ca164c7f1f07bc922a9c83d77cea3a1e5d0c69910739025372dc14ac9642629379540c17e2a65b19d77aa511a9d00bb96&quot;</span>, <span class="tok-str">&quot;abc&quot;</span>);</span>
<span class="line" id="L318">    <span class="tok-kw">try</span> htest.assertEqualHash(Keccak_512, <span class="tok-str">&quot;ac2fb35251825d3aa48468a9948c0a91b8256f6d97d8fa4160faff2dd9dfcc24f3f1db7a983dad13d53439ccac0b37e24037e7b95f80f59f37a2f683c4ba4682&quot;</span>, <span class="tok-str">&quot;abcdefghbcdefghicdefghijdefghijkefghijklfghijklmghijklmnhijklmnoijklmnopjklmnopqklmnopqrlmnopqrsmnopqrstnopqrstu&quot;</span>);</span>
<span class="line" id="L319">}</span>
<span class="line" id="L320"></span>
</code></pre></body>
</html>