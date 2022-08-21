<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">    <title>crypto/md5.zig - source view</title>
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
<span class="line" id="L4"></span>
<span class="line" id="L5"><span class="tok-kw">const</span> RoundParam = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L6">    a: <span class="tok-type">usize</span>,</span>
<span class="line" id="L7">    b: <span class="tok-type">usize</span>,</span>
<span class="line" id="L8">    c: <span class="tok-type">usize</span>,</span>
<span class="line" id="L9">    d: <span class="tok-type">usize</span>,</span>
<span class="line" id="L10">    k: <span class="tok-type">usize</span>,</span>
<span class="line" id="L11">    s: <span class="tok-type">u32</span>,</span>
<span class="line" id="L12">    t: <span class="tok-type">u32</span>,</span>
<span class="line" id="L13">};</span>
<span class="line" id="L14"></span>
<span class="line" id="L15"><span class="tok-kw">fn</span> <span class="tok-fn">roundParam</span>(a: <span class="tok-type">usize</span>, b: <span class="tok-type">usize</span>, c: <span class="tok-type">usize</span>, d: <span class="tok-type">usize</span>, k: <span class="tok-type">usize</span>, s: <span class="tok-type">u32</span>, t: <span class="tok-type">u32</span>) RoundParam {</span>
<span class="line" id="L16">    <span class="tok-kw">return</span> RoundParam{</span>
<span class="line" id="L17">        .a = a,</span>
<span class="line" id="L18">        .b = b,</span>
<span class="line" id="L19">        .c = c,</span>
<span class="line" id="L20">        .d = d,</span>
<span class="line" id="L21">        .k = k,</span>
<span class="line" id="L22">        .s = s,</span>
<span class="line" id="L23">        .t = t,</span>
<span class="line" id="L24">    };</span>
<span class="line" id="L25">}</span>
<span class="line" id="L26"></span>
<span class="line" id="L27"><span class="tok-comment">/// The MD5 function is now considered cryptographically broken.</span></span>
<span class="line" id="L28"><span class="tok-comment">/// Namely, it is trivial to find multiple inputs producing the same hash.</span></span>
<span class="line" id="L29"><span class="tok-comment">/// For a fast-performing, cryptographically secure hash function, see SHA512/256, BLAKE2 or BLAKE3.</span></span>
<span class="line" id="L30"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> Md5 = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L31">    <span class="tok-kw">const</span> Self = <span class="tok-builtin">@This</span>();</span>
<span class="line" id="L32">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> block_length = <span class="tok-number">64</span>;</span>
<span class="line" id="L33">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> digest_length = <span class="tok-number">16</span>;</span>
<span class="line" id="L34">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> Options = <span class="tok-kw">struct</span> {};</span>
<span class="line" id="L35"></span>
<span class="line" id="L36">    s: [<span class="tok-number">4</span>]<span class="tok-type">u32</span>,</span>
<span class="line" id="L37">    <span class="tok-comment">// Streaming Cache</span>
</span>
<span class="line" id="L38">    buf: [<span class="tok-number">64</span>]<span class="tok-type">u8</span>,</span>
<span class="line" id="L39">    buf_len: <span class="tok-type">u8</span>,</span>
<span class="line" id="L40">    total_len: <span class="tok-type">u64</span>,</span>
<span class="line" id="L41"></span>
<span class="line" id="L42">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">init</span>(options: Options) Self {</span>
<span class="line" id="L43">        _ = options;</span>
<span class="line" id="L44">        <span class="tok-kw">return</span> Self{</span>
<span class="line" id="L45">            .s = [_]<span class="tok-type">u32</span>{</span>
<span class="line" id="L46">                <span class="tok-number">0x67452301</span>,</span>
<span class="line" id="L47">                <span class="tok-number">0xEFCDAB89</span>,</span>
<span class="line" id="L48">                <span class="tok-number">0x98BADCFE</span>,</span>
<span class="line" id="L49">                <span class="tok-number">0x10325476</span>,</span>
<span class="line" id="L50">            },</span>
<span class="line" id="L51">            .buf = <span class="tok-null">undefined</span>,</span>
<span class="line" id="L52">            .buf_len = <span class="tok-number">0</span>,</span>
<span class="line" id="L53">            .total_len = <span class="tok-number">0</span>,</span>
<span class="line" id="L54">        };</span>
<span class="line" id="L55">    }</span>
<span class="line" id="L56"></span>
<span class="line" id="L57">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">hash</span>(b: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, out: *[digest_length]<span class="tok-type">u8</span>, options: Options) <span class="tok-type">void</span> {</span>
<span class="line" id="L58">        <span class="tok-kw">var</span> d = Md5.init(options);</span>
<span class="line" id="L59">        d.update(b);</span>
<span class="line" id="L60">        d.final(out);</span>
<span class="line" id="L61">    }</span>
<span class="line" id="L62"></span>
<span class="line" id="L63">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">update</span>(d: *Self, b: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L64">        <span class="tok-kw">var</span> off: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L65"></span>
<span class="line" id="L66">        <span class="tok-comment">// Partial buffer exists from previous update. Copy into buffer then hash.</span>
</span>
<span class="line" id="L67">        <span class="tok-kw">if</span> (d.buf_len != <span class="tok-number">0</span> <span class="tok-kw">and</span> d.buf_len + b.len &gt;= <span class="tok-number">64</span>) {</span>
<span class="line" id="L68">            off += <span class="tok-number">64</span> - d.buf_len;</span>
<span class="line" id="L69">            mem.copy(<span class="tok-type">u8</span>, d.buf[d.buf_len..], b[<span class="tok-number">0</span>..off]);</span>
<span class="line" id="L70"></span>
<span class="line" id="L71">            d.round(&amp;d.buf);</span>
<span class="line" id="L72">            d.buf_len = <span class="tok-number">0</span>;</span>
<span class="line" id="L73">        }</span>
<span class="line" id="L74"></span>
<span class="line" id="L75">        <span class="tok-comment">// Full middle blocks.</span>
</span>
<span class="line" id="L76">        <span class="tok-kw">while</span> (off + <span class="tok-number">64</span> &lt;= b.len) : (off += <span class="tok-number">64</span>) {</span>
<span class="line" id="L77">            d.round(b[off..][<span class="tok-number">0</span>..<span class="tok-number">64</span>]);</span>
<span class="line" id="L78">        }</span>
<span class="line" id="L79"></span>
<span class="line" id="L80">        <span class="tok-comment">// Copy any remainder for next pass.</span>
</span>
<span class="line" id="L81">        mem.copy(<span class="tok-type">u8</span>, d.buf[d.buf_len..], b[off..]);</span>
<span class="line" id="L82">        d.buf_len += <span class="tok-builtin">@intCast</span>(<span class="tok-type">u8</span>, b[off..].len);</span>
<span class="line" id="L83"></span>
<span class="line" id="L84">        <span class="tok-comment">// Md5 uses the bottom 64-bits for length padding</span>
</span>
<span class="line" id="L85">        d.total_len +%= b.len;</span>
<span class="line" id="L86">    }</span>
<span class="line" id="L87"></span>
<span class="line" id="L88">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">final</span>(d: *Self, out: *[digest_length]<span class="tok-type">u8</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L89">        <span class="tok-comment">// The buffer here will never be completely full.</span>
</span>
<span class="line" id="L90">        mem.set(<span class="tok-type">u8</span>, d.buf[d.buf_len..], <span class="tok-number">0</span>);</span>
<span class="line" id="L91"></span>
<span class="line" id="L92">        <span class="tok-comment">// Append padding bits.</span>
</span>
<span class="line" id="L93">        d.buf[d.buf_len] = <span class="tok-number">0x80</span>;</span>
<span class="line" id="L94">        d.buf_len += <span class="tok-number">1</span>;</span>
<span class="line" id="L95"></span>
<span class="line" id="L96">        <span class="tok-comment">// &gt; 448 mod 512 so need to add an extra round to wrap around.</span>
</span>
<span class="line" id="L97">        <span class="tok-kw">if</span> (<span class="tok-number">64</span> - d.buf_len &lt; <span class="tok-number">8</span>) {</span>
<span class="line" id="L98">            d.round(d.buf[<span class="tok-number">0</span>..]);</span>
<span class="line" id="L99">            mem.set(<span class="tok-type">u8</span>, d.buf[<span class="tok-number">0</span>..], <span class="tok-number">0</span>);</span>
<span class="line" id="L100">        }</span>
<span class="line" id="L101"></span>
<span class="line" id="L102">        <span class="tok-comment">// Append message length.</span>
</span>
<span class="line" id="L103">        <span class="tok-kw">var</span> i: <span class="tok-type">usize</span> = <span class="tok-number">1</span>;</span>
<span class="line" id="L104">        <span class="tok-kw">var</span> len = d.total_len &gt;&gt; <span class="tok-number">5</span>;</span>
<span class="line" id="L105">        d.buf[<span class="tok-number">56</span>] = <span class="tok-builtin">@intCast</span>(<span class="tok-type">u8</span>, d.total_len &amp; <span class="tok-number">0x1f</span>) &lt;&lt; <span class="tok-number">3</span>;</span>
<span class="line" id="L106">        <span class="tok-kw">while</span> (i &lt; <span class="tok-number">8</span>) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L107">            d.buf[<span class="tok-number">56</span> + i] = <span class="tok-builtin">@intCast</span>(<span class="tok-type">u8</span>, len &amp; <span class="tok-number">0xff</span>);</span>
<span class="line" id="L108">            len &gt;&gt;= <span class="tok-number">8</span>;</span>
<span class="line" id="L109">        }</span>
<span class="line" id="L110"></span>
<span class="line" id="L111">        d.round(d.buf[<span class="tok-number">0</span>..]);</span>
<span class="line" id="L112"></span>
<span class="line" id="L113">        <span class="tok-kw">for</span> (d.s) |s, j| {</span>
<span class="line" id="L114">            mem.writeIntLittle(<span class="tok-type">u32</span>, out[<span class="tok-number">4</span> * j ..][<span class="tok-number">0</span>..<span class="tok-number">4</span>], s);</span>
<span class="line" id="L115">        }</span>
<span class="line" id="L116">    }</span>
<span class="line" id="L117"></span>
<span class="line" id="L118">    <span class="tok-kw">fn</span> <span class="tok-fn">round</span>(d: *Self, b: *<span class="tok-kw">const</span> [<span class="tok-number">64</span>]<span class="tok-type">u8</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L119">        <span class="tok-kw">var</span> s: [<span class="tok-number">16</span>]<span class="tok-type">u32</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L120"></span>
<span class="line" id="L121">        <span class="tok-kw">var</span> i: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L122">        <span class="tok-kw">while</span> (i &lt; <span class="tok-number">16</span>) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L123">            <span class="tok-comment">// NOTE: Performing or's separately improves perf by ~10%</span>
</span>
<span class="line" id="L124">            s[i] = <span class="tok-number">0</span>;</span>
<span class="line" id="L125">            s[i] |= <span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, b[i * <span class="tok-number">4</span> + <span class="tok-number">0</span>]);</span>
<span class="line" id="L126">            s[i] |= <span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, b[i * <span class="tok-number">4</span> + <span class="tok-number">1</span>]) &lt;&lt; <span class="tok-number">8</span>;</span>
<span class="line" id="L127">            s[i] |= <span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, b[i * <span class="tok-number">4</span> + <span class="tok-number">2</span>]) &lt;&lt; <span class="tok-number">16</span>;</span>
<span class="line" id="L128">            s[i] |= <span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, b[i * <span class="tok-number">4</span> + <span class="tok-number">3</span>]) &lt;&lt; <span class="tok-number">24</span>;</span>
<span class="line" id="L129">        }</span>
<span class="line" id="L130"></span>
<span class="line" id="L131">        <span class="tok-kw">var</span> v: [<span class="tok-number">4</span>]<span class="tok-type">u32</span> = [_]<span class="tok-type">u32</span>{</span>
<span class="line" id="L132">            d.s[<span class="tok-number">0</span>],</span>
<span class="line" id="L133">            d.s[<span class="tok-number">1</span>],</span>
<span class="line" id="L134">            d.s[<span class="tok-number">2</span>],</span>
<span class="line" id="L135">            d.s[<span class="tok-number">3</span>],</span>
<span class="line" id="L136">        };</span>
<span class="line" id="L137"></span>
<span class="line" id="L138">        <span class="tok-kw">const</span> round0 = <span class="tok-kw">comptime</span> [_]RoundParam{</span>
<span class="line" id="L139">            roundParam(<span class="tok-number">0</span>, <span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">0</span>, <span class="tok-number">7</span>, <span class="tok-number">0xD76AA478</span>),</span>
<span class="line" id="L140">            roundParam(<span class="tok-number">3</span>, <span class="tok-number">0</span>, <span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">1</span>, <span class="tok-number">12</span>, <span class="tok-number">0xE8C7B756</span>),</span>
<span class="line" id="L141">            roundParam(<span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">0</span>, <span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">17</span>, <span class="tok-number">0x242070DB</span>),</span>
<span class="line" id="L142">            roundParam(<span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">0</span>, <span class="tok-number">3</span>, <span class="tok-number">22</span>, <span class="tok-number">0xC1BDCEEE</span>),</span>
<span class="line" id="L143">            roundParam(<span class="tok-number">0</span>, <span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">4</span>, <span class="tok-number">7</span>, <span class="tok-number">0xF57C0FAF</span>),</span>
<span class="line" id="L144">            roundParam(<span class="tok-number">3</span>, <span class="tok-number">0</span>, <span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">5</span>, <span class="tok-number">12</span>, <span class="tok-number">0x4787C62A</span>),</span>
<span class="line" id="L145">            roundParam(<span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">0</span>, <span class="tok-number">1</span>, <span class="tok-number">6</span>, <span class="tok-number">17</span>, <span class="tok-number">0xA8304613</span>),</span>
<span class="line" id="L146">            roundParam(<span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">0</span>, <span class="tok-number">7</span>, <span class="tok-number">22</span>, <span class="tok-number">0xFD469501</span>),</span>
<span class="line" id="L147">            roundParam(<span class="tok-number">0</span>, <span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">8</span>, <span class="tok-number">7</span>, <span class="tok-number">0x698098D8</span>),</span>
<span class="line" id="L148">            roundParam(<span class="tok-number">3</span>, <span class="tok-number">0</span>, <span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">9</span>, <span class="tok-number">12</span>, <span class="tok-number">0x8B44F7AF</span>),</span>
<span class="line" id="L149">            roundParam(<span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">0</span>, <span class="tok-number">1</span>, <span class="tok-number">10</span>, <span class="tok-number">17</span>, <span class="tok-number">0xFFFF5BB1</span>),</span>
<span class="line" id="L150">            roundParam(<span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">0</span>, <span class="tok-number">11</span>, <span class="tok-number">22</span>, <span class="tok-number">0x895CD7BE</span>),</span>
<span class="line" id="L151">            roundParam(<span class="tok-number">0</span>, <span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">12</span>, <span class="tok-number">7</span>, <span class="tok-number">0x6B901122</span>),</span>
<span class="line" id="L152">            roundParam(<span class="tok-number">3</span>, <span class="tok-number">0</span>, <span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">13</span>, <span class="tok-number">12</span>, <span class="tok-number">0xFD987193</span>),</span>
<span class="line" id="L153">            roundParam(<span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">0</span>, <span class="tok-number">1</span>, <span class="tok-number">14</span>, <span class="tok-number">17</span>, <span class="tok-number">0xA679438E</span>),</span>
<span class="line" id="L154">            roundParam(<span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">0</span>, <span class="tok-number">15</span>, <span class="tok-number">22</span>, <span class="tok-number">0x49B40821</span>),</span>
<span class="line" id="L155">        };</span>
<span class="line" id="L156">        <span class="tok-kw">inline</span> <span class="tok-kw">for</span> (round0) |r| {</span>
<span class="line" id="L157">            v[r.a] = v[r.a] +% (v[r.d] ^ (v[r.b] &amp; (v[r.c] ^ v[r.d]))) +% r.t +% s[r.k];</span>
<span class="line" id="L158">            v[r.a] = v[r.b] +% math.rotl(<span class="tok-type">u32</span>, v[r.a], r.s);</span>
<span class="line" id="L159">        }</span>
<span class="line" id="L160"></span>
<span class="line" id="L161">        <span class="tok-kw">const</span> round1 = <span class="tok-kw">comptime</span> [_]RoundParam{</span>
<span class="line" id="L162">            roundParam(<span class="tok-number">0</span>, <span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">1</span>, <span class="tok-number">5</span>, <span class="tok-number">0xF61E2562</span>),</span>
<span class="line" id="L163">            roundParam(<span class="tok-number">3</span>, <span class="tok-number">0</span>, <span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">6</span>, <span class="tok-number">9</span>, <span class="tok-number">0xC040B340</span>),</span>
<span class="line" id="L164">            roundParam(<span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">0</span>, <span class="tok-number">1</span>, <span class="tok-number">11</span>, <span class="tok-number">14</span>, <span class="tok-number">0x265E5A51</span>),</span>
<span class="line" id="L165">            roundParam(<span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">20</span>, <span class="tok-number">0xE9B6C7AA</span>),</span>
<span class="line" id="L166">            roundParam(<span class="tok-number">0</span>, <span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">5</span>, <span class="tok-number">5</span>, <span class="tok-number">0xD62F105D</span>),</span>
<span class="line" id="L167">            roundParam(<span class="tok-number">3</span>, <span class="tok-number">0</span>, <span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">10</span>, <span class="tok-number">9</span>, <span class="tok-number">0x02441453</span>),</span>
<span class="line" id="L168">            roundParam(<span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">0</span>, <span class="tok-number">1</span>, <span class="tok-number">15</span>, <span class="tok-number">14</span>, <span class="tok-number">0xD8A1E681</span>),</span>
<span class="line" id="L169">            roundParam(<span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">0</span>, <span class="tok-number">4</span>, <span class="tok-number">20</span>, <span class="tok-number">0xE7D3FBC8</span>),</span>
<span class="line" id="L170">            roundParam(<span class="tok-number">0</span>, <span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">9</span>, <span class="tok-number">5</span>, <span class="tok-number">0x21E1CDE6</span>),</span>
<span class="line" id="L171">            roundParam(<span class="tok-number">3</span>, <span class="tok-number">0</span>, <span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">14</span>, <span class="tok-number">9</span>, <span class="tok-number">0xC33707D6</span>),</span>
<span class="line" id="L172">            roundParam(<span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">0</span>, <span class="tok-number">1</span>, <span class="tok-number">3</span>, <span class="tok-number">14</span>, <span class="tok-number">0xF4D50D87</span>),</span>
<span class="line" id="L173">            roundParam(<span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">0</span>, <span class="tok-number">8</span>, <span class="tok-number">20</span>, <span class="tok-number">0x455A14ED</span>),</span>
<span class="line" id="L174">            roundParam(<span class="tok-number">0</span>, <span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">13</span>, <span class="tok-number">5</span>, <span class="tok-number">0xA9E3E905</span>),</span>
<span class="line" id="L175">            roundParam(<span class="tok-number">3</span>, <span class="tok-number">0</span>, <span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">2</span>, <span class="tok-number">9</span>, <span class="tok-number">0xFCEFA3F8</span>),</span>
<span class="line" id="L176">            roundParam(<span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">0</span>, <span class="tok-number">1</span>, <span class="tok-number">7</span>, <span class="tok-number">14</span>, <span class="tok-number">0x676F02D9</span>),</span>
<span class="line" id="L177">            roundParam(<span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">0</span>, <span class="tok-number">12</span>, <span class="tok-number">20</span>, <span class="tok-number">0x8D2A4C8A</span>),</span>
<span class="line" id="L178">        };</span>
<span class="line" id="L179">        <span class="tok-kw">inline</span> <span class="tok-kw">for</span> (round1) |r| {</span>
<span class="line" id="L180">            v[r.a] = v[r.a] +% (v[r.c] ^ (v[r.d] &amp; (v[r.b] ^ v[r.c]))) +% r.t +% s[r.k];</span>
<span class="line" id="L181">            v[r.a] = v[r.b] +% math.rotl(<span class="tok-type">u32</span>, v[r.a], r.s);</span>
<span class="line" id="L182">        }</span>
<span class="line" id="L183"></span>
<span class="line" id="L184">        <span class="tok-kw">const</span> round2 = <span class="tok-kw">comptime</span> [_]RoundParam{</span>
<span class="line" id="L185">            roundParam(<span class="tok-number">0</span>, <span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">5</span>, <span class="tok-number">4</span>, <span class="tok-number">0xFFFA3942</span>),</span>
<span class="line" id="L186">            roundParam(<span class="tok-number">3</span>, <span class="tok-number">0</span>, <span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">8</span>, <span class="tok-number">11</span>, <span class="tok-number">0x8771F681</span>),</span>
<span class="line" id="L187">            roundParam(<span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">0</span>, <span class="tok-number">1</span>, <span class="tok-number">11</span>, <span class="tok-number">16</span>, <span class="tok-number">0x6D9D6122</span>),</span>
<span class="line" id="L188">            roundParam(<span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">0</span>, <span class="tok-number">14</span>, <span class="tok-number">23</span>, <span class="tok-number">0xFDE5380C</span>),</span>
<span class="line" id="L189">            roundParam(<span class="tok-number">0</span>, <span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">1</span>, <span class="tok-number">4</span>, <span class="tok-number">0xA4BEEA44</span>),</span>
<span class="line" id="L190">            roundParam(<span class="tok-number">3</span>, <span class="tok-number">0</span>, <span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">4</span>, <span class="tok-number">11</span>, <span class="tok-number">0x4BDECFA9</span>),</span>
<span class="line" id="L191">            roundParam(<span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">0</span>, <span class="tok-number">1</span>, <span class="tok-number">7</span>, <span class="tok-number">16</span>, <span class="tok-number">0xF6BB4B60</span>),</span>
<span class="line" id="L192">            roundParam(<span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">0</span>, <span class="tok-number">10</span>, <span class="tok-number">23</span>, <span class="tok-number">0xBEBFBC70</span>),</span>
<span class="line" id="L193">            roundParam(<span class="tok-number">0</span>, <span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">13</span>, <span class="tok-number">4</span>, <span class="tok-number">0x289B7EC6</span>),</span>
<span class="line" id="L194">            roundParam(<span class="tok-number">3</span>, <span class="tok-number">0</span>, <span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">0</span>, <span class="tok-number">11</span>, <span class="tok-number">0xEAA127FA</span>),</span>
<span class="line" id="L195">            roundParam(<span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">0</span>, <span class="tok-number">1</span>, <span class="tok-number">3</span>, <span class="tok-number">16</span>, <span class="tok-number">0xD4EF3085</span>),</span>
<span class="line" id="L196">            roundParam(<span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">0</span>, <span class="tok-number">6</span>, <span class="tok-number">23</span>, <span class="tok-number">0x04881D05</span>),</span>
<span class="line" id="L197">            roundParam(<span class="tok-number">0</span>, <span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">9</span>, <span class="tok-number">4</span>, <span class="tok-number">0xD9D4D039</span>),</span>
<span class="line" id="L198">            roundParam(<span class="tok-number">3</span>, <span class="tok-number">0</span>, <span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">12</span>, <span class="tok-number">11</span>, <span class="tok-number">0xE6DB99E5</span>),</span>
<span class="line" id="L199">            roundParam(<span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">0</span>, <span class="tok-number">1</span>, <span class="tok-number">15</span>, <span class="tok-number">16</span>, <span class="tok-number">0x1FA27CF8</span>),</span>
<span class="line" id="L200">            roundParam(<span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">0</span>, <span class="tok-number">2</span>, <span class="tok-number">23</span>, <span class="tok-number">0xC4AC5665</span>),</span>
<span class="line" id="L201">        };</span>
<span class="line" id="L202">        <span class="tok-kw">inline</span> <span class="tok-kw">for</span> (round2) |r| {</span>
<span class="line" id="L203">            v[r.a] = v[r.a] +% (v[r.b] ^ v[r.c] ^ v[r.d]) +% r.t +% s[r.k];</span>
<span class="line" id="L204">            v[r.a] = v[r.b] +% math.rotl(<span class="tok-type">u32</span>, v[r.a], r.s);</span>
<span class="line" id="L205">        }</span>
<span class="line" id="L206"></span>
<span class="line" id="L207">        <span class="tok-kw">const</span> round3 = <span class="tok-kw">comptime</span> [_]RoundParam{</span>
<span class="line" id="L208">            roundParam(<span class="tok-number">0</span>, <span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">0</span>, <span class="tok-number">6</span>, <span class="tok-number">0xF4292244</span>),</span>
<span class="line" id="L209">            roundParam(<span class="tok-number">3</span>, <span class="tok-number">0</span>, <span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">7</span>, <span class="tok-number">10</span>, <span class="tok-number">0x432AFF97</span>),</span>
<span class="line" id="L210">            roundParam(<span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">0</span>, <span class="tok-number">1</span>, <span class="tok-number">14</span>, <span class="tok-number">15</span>, <span class="tok-number">0xAB9423A7</span>),</span>
<span class="line" id="L211">            roundParam(<span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">0</span>, <span class="tok-number">5</span>, <span class="tok-number">21</span>, <span class="tok-number">0xFC93A039</span>),</span>
<span class="line" id="L212">            roundParam(<span class="tok-number">0</span>, <span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">12</span>, <span class="tok-number">6</span>, <span class="tok-number">0x655B59C3</span>),</span>
<span class="line" id="L213">            roundParam(<span class="tok-number">3</span>, <span class="tok-number">0</span>, <span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">10</span>, <span class="tok-number">0x8F0CCC92</span>),</span>
<span class="line" id="L214">            roundParam(<span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">0</span>, <span class="tok-number">1</span>, <span class="tok-number">10</span>, <span class="tok-number">15</span>, <span class="tok-number">0xFFEFF47D</span>),</span>
<span class="line" id="L215">            roundParam(<span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">0</span>, <span class="tok-number">1</span>, <span class="tok-number">21</span>, <span class="tok-number">0x85845DD1</span>),</span>
<span class="line" id="L216">            roundParam(<span class="tok-number">0</span>, <span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">8</span>, <span class="tok-number">6</span>, <span class="tok-number">0x6FA87E4F</span>),</span>
<span class="line" id="L217">            roundParam(<span class="tok-number">3</span>, <span class="tok-number">0</span>, <span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">15</span>, <span class="tok-number">10</span>, <span class="tok-number">0xFE2CE6E0</span>),</span>
<span class="line" id="L218">            roundParam(<span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">0</span>, <span class="tok-number">1</span>, <span class="tok-number">6</span>, <span class="tok-number">15</span>, <span class="tok-number">0xA3014314</span>),</span>
<span class="line" id="L219">            roundParam(<span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">0</span>, <span class="tok-number">13</span>, <span class="tok-number">21</span>, <span class="tok-number">0x4E0811A1</span>),</span>
<span class="line" id="L220">            roundParam(<span class="tok-number">0</span>, <span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">4</span>, <span class="tok-number">6</span>, <span class="tok-number">0xF7537E82</span>),</span>
<span class="line" id="L221">            roundParam(<span class="tok-number">3</span>, <span class="tok-number">0</span>, <span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">11</span>, <span class="tok-number">10</span>, <span class="tok-number">0xBD3AF235</span>),</span>
<span class="line" id="L222">            roundParam(<span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">0</span>, <span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">15</span>, <span class="tok-number">0x2AD7D2BB</span>),</span>
<span class="line" id="L223">            roundParam(<span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">0</span>, <span class="tok-number">9</span>, <span class="tok-number">21</span>, <span class="tok-number">0xEB86D391</span>),</span>
<span class="line" id="L224">        };</span>
<span class="line" id="L225">        <span class="tok-kw">inline</span> <span class="tok-kw">for</span> (round3) |r| {</span>
<span class="line" id="L226">            v[r.a] = v[r.a] +% (v[r.c] ^ (v[r.b] | ~v[r.d])) +% r.t +% s[r.k];</span>
<span class="line" id="L227">            v[r.a] = v[r.b] +% math.rotl(<span class="tok-type">u32</span>, v[r.a], r.s);</span>
<span class="line" id="L228">        }</span>
<span class="line" id="L229"></span>
<span class="line" id="L230">        d.s[<span class="tok-number">0</span>] +%= v[<span class="tok-number">0</span>];</span>
<span class="line" id="L231">        d.s[<span class="tok-number">1</span>] +%= v[<span class="tok-number">1</span>];</span>
<span class="line" id="L232">        d.s[<span class="tok-number">2</span>] +%= v[<span class="tok-number">2</span>];</span>
<span class="line" id="L233">        d.s[<span class="tok-number">3</span>] +%= v[<span class="tok-number">3</span>];</span>
<span class="line" id="L234">    }</span>
<span class="line" id="L235">};</span>
<span class="line" id="L236"></span>
<span class="line" id="L237"><span class="tok-kw">const</span> htest = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;test.zig&quot;</span>);</span>
<span class="line" id="L238"></span>
<span class="line" id="L239"><span class="tok-kw">test</span> <span class="tok-str">&quot;md5 single&quot;</span> {</span>
<span class="line" id="L240">    <span class="tok-kw">try</span> htest.assertEqualHash(Md5, <span class="tok-str">&quot;d41d8cd98f00b204e9800998ecf8427e&quot;</span>, <span class="tok-str">&quot;&quot;</span>);</span>
<span class="line" id="L241">    <span class="tok-kw">try</span> htest.assertEqualHash(Md5, <span class="tok-str">&quot;0cc175b9c0f1b6a831c399e269772661&quot;</span>, <span class="tok-str">&quot;a&quot;</span>);</span>
<span class="line" id="L242">    <span class="tok-kw">try</span> htest.assertEqualHash(Md5, <span class="tok-str">&quot;900150983cd24fb0d6963f7d28e17f72&quot;</span>, <span class="tok-str">&quot;abc&quot;</span>);</span>
<span class="line" id="L243">    <span class="tok-kw">try</span> htest.assertEqualHash(Md5, <span class="tok-str">&quot;f96b697d7cb7938d525a2f31aaf161d0&quot;</span>, <span class="tok-str">&quot;message digest&quot;</span>);</span>
<span class="line" id="L244">    <span class="tok-kw">try</span> htest.assertEqualHash(Md5, <span class="tok-str">&quot;c3fcd3d76192e4007dfb496cca67e13b&quot;</span>, <span class="tok-str">&quot;abcdefghijklmnopqrstuvwxyz&quot;</span>);</span>
<span class="line" id="L245">    <span class="tok-kw">try</span> htest.assertEqualHash(Md5, <span class="tok-str">&quot;d174ab98d277d9f5a5611c2c9f419d9f&quot;</span>, <span class="tok-str">&quot;ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789&quot;</span>);</span>
<span class="line" id="L246">    <span class="tok-kw">try</span> htest.assertEqualHash(Md5, <span class="tok-str">&quot;57edf4a22be3c955ac49da2e2107b67a&quot;</span>, <span class="tok-str">&quot;12345678901234567890123456789012345678901234567890123456789012345678901234567890&quot;</span>);</span>
<span class="line" id="L247">}</span>
<span class="line" id="L248"></span>
<span class="line" id="L249"><span class="tok-kw">test</span> <span class="tok-str">&quot;md5 streaming&quot;</span> {</span>
<span class="line" id="L250">    <span class="tok-kw">var</span> h = Md5.init(.{});</span>
<span class="line" id="L251">    <span class="tok-kw">var</span> out: [<span class="tok-number">16</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L252"></span>
<span class="line" id="L253">    h.final(out[<span class="tok-number">0</span>..]);</span>
<span class="line" id="L254">    <span class="tok-kw">try</span> htest.assertEqual(<span class="tok-str">&quot;d41d8cd98f00b204e9800998ecf8427e&quot;</span>, out[<span class="tok-number">0</span>..]);</span>
<span class="line" id="L255"></span>
<span class="line" id="L256">    h = Md5.init(.{});</span>
<span class="line" id="L257">    h.update(<span class="tok-str">&quot;abc&quot;</span>);</span>
<span class="line" id="L258">    h.final(out[<span class="tok-number">0</span>..]);</span>
<span class="line" id="L259">    <span class="tok-kw">try</span> htest.assertEqual(<span class="tok-str">&quot;900150983cd24fb0d6963f7d28e17f72&quot;</span>, out[<span class="tok-number">0</span>..]);</span>
<span class="line" id="L260"></span>
<span class="line" id="L261">    h = Md5.init(.{});</span>
<span class="line" id="L262">    h.update(<span class="tok-str">&quot;a&quot;</span>);</span>
<span class="line" id="L263">    h.update(<span class="tok-str">&quot;b&quot;</span>);</span>
<span class="line" id="L264">    h.update(<span class="tok-str">&quot;c&quot;</span>);</span>
<span class="line" id="L265">    h.final(out[<span class="tok-number">0</span>..]);</span>
<span class="line" id="L266"></span>
<span class="line" id="L267">    <span class="tok-kw">try</span> htest.assertEqual(<span class="tok-str">&quot;900150983cd24fb0d6963f7d28e17f72&quot;</span>, out[<span class="tok-number">0</span>..]);</span>
<span class="line" id="L268">}</span>
<span class="line" id="L269"></span>
<span class="line" id="L270"><span class="tok-kw">test</span> <span class="tok-str">&quot;md5 aligned final&quot;</span> {</span>
<span class="line" id="L271">    <span class="tok-kw">var</span> block = [_]<span class="tok-type">u8</span>{<span class="tok-number">0</span>} ** Md5.block_length;</span>
<span class="line" id="L272">    <span class="tok-kw">var</span> out: [Md5.digest_length]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L273"></span>
<span class="line" id="L274">    <span class="tok-kw">var</span> h = Md5.init(.{});</span>
<span class="line" id="L275">    h.update(&amp;block);</span>
<span class="line" id="L276">    h.final(out[<span class="tok-number">0</span>..]);</span>
<span class="line" id="L277">}</span>
<span class="line" id="L278"></span>
</code></pre></body>
</html>