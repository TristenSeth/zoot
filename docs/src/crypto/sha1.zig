<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">    <title>crypto/sha1.zig - source view</title>
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
<span class="line" id="L10">    e: <span class="tok-type">usize</span>,</span>
<span class="line" id="L11">    i: <span class="tok-type">u32</span>,</span>
<span class="line" id="L12">};</span>
<span class="line" id="L13"></span>
<span class="line" id="L14"><span class="tok-kw">fn</span> <span class="tok-fn">roundParam</span>(a: <span class="tok-type">usize</span>, b: <span class="tok-type">usize</span>, c: <span class="tok-type">usize</span>, d: <span class="tok-type">usize</span>, e: <span class="tok-type">usize</span>, i: <span class="tok-type">u32</span>) RoundParam {</span>
<span class="line" id="L15">    <span class="tok-kw">return</span> RoundParam{</span>
<span class="line" id="L16">        .a = a,</span>
<span class="line" id="L17">        .b = b,</span>
<span class="line" id="L18">        .c = c,</span>
<span class="line" id="L19">        .d = d,</span>
<span class="line" id="L20">        .e = e,</span>
<span class="line" id="L21">        .i = i,</span>
<span class="line" id="L22">    };</span>
<span class="line" id="L23">}</span>
<span class="line" id="L24"></span>
<span class="line" id="L25"><span class="tok-comment">/// The SHA-1 function is now considered cryptographically broken.</span></span>
<span class="line" id="L26"><span class="tok-comment">/// Namely, it is feasible to find multiple inputs producing the same hash.</span></span>
<span class="line" id="L27"><span class="tok-comment">/// For a fast-performing, cryptographically secure hash function, see SHA512/256, BLAKE2 or BLAKE3.</span></span>
<span class="line" id="L28"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> Sha1 = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L29">    <span class="tok-kw">const</span> Self = <span class="tok-builtin">@This</span>();</span>
<span class="line" id="L30">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> block_length = <span class="tok-number">64</span>;</span>
<span class="line" id="L31">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> digest_length = <span class="tok-number">20</span>;</span>
<span class="line" id="L32">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> Options = <span class="tok-kw">struct</span> {};</span>
<span class="line" id="L33"></span>
<span class="line" id="L34">    s: [<span class="tok-number">5</span>]<span class="tok-type">u32</span>,</span>
<span class="line" id="L35">    <span class="tok-comment">// Streaming Cache</span>
</span>
<span class="line" id="L36">    buf: [<span class="tok-number">64</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>,</span>
<span class="line" id="L37">    buf_len: <span class="tok-type">u8</span> = <span class="tok-number">0</span>,</span>
<span class="line" id="L38">    total_len: <span class="tok-type">u64</span> = <span class="tok-number">0</span>,</span>
<span class="line" id="L39"></span>
<span class="line" id="L40">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">init</span>(options: Options) Self {</span>
<span class="line" id="L41">        _ = options;</span>
<span class="line" id="L42">        <span class="tok-kw">return</span> Self{</span>
<span class="line" id="L43">            .s = [_]<span class="tok-type">u32</span>{</span>
<span class="line" id="L44">                <span class="tok-number">0x67452301</span>,</span>
<span class="line" id="L45">                <span class="tok-number">0xEFCDAB89</span>,</span>
<span class="line" id="L46">                <span class="tok-number">0x98BADCFE</span>,</span>
<span class="line" id="L47">                <span class="tok-number">0x10325476</span>,</span>
<span class="line" id="L48">                <span class="tok-number">0xC3D2E1F0</span>,</span>
<span class="line" id="L49">            },</span>
<span class="line" id="L50">        };</span>
<span class="line" id="L51">    }</span>
<span class="line" id="L52"></span>
<span class="line" id="L53">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">hash</span>(b: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, out: *[digest_length]<span class="tok-type">u8</span>, options: Options) <span class="tok-type">void</span> {</span>
<span class="line" id="L54">        <span class="tok-kw">var</span> d = Sha1.init(options);</span>
<span class="line" id="L55">        d.update(b);</span>
<span class="line" id="L56">        d.final(out);</span>
<span class="line" id="L57">    }</span>
<span class="line" id="L58"></span>
<span class="line" id="L59">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">update</span>(d: *Self, b: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L60">        <span class="tok-kw">var</span> off: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L61"></span>
<span class="line" id="L62">        <span class="tok-comment">// Partial buffer exists from previous update. Copy into buffer then hash.</span>
</span>
<span class="line" id="L63">        <span class="tok-kw">if</span> (d.buf_len != <span class="tok-number">0</span> <span class="tok-kw">and</span> d.buf_len + b.len &gt;= <span class="tok-number">64</span>) {</span>
<span class="line" id="L64">            off += <span class="tok-number">64</span> - d.buf_len;</span>
<span class="line" id="L65">            mem.copy(<span class="tok-type">u8</span>, d.buf[d.buf_len..], b[<span class="tok-number">0</span>..off]);</span>
<span class="line" id="L66"></span>
<span class="line" id="L67">            d.round(d.buf[<span class="tok-number">0</span>..]);</span>
<span class="line" id="L68">            d.buf_len = <span class="tok-number">0</span>;</span>
<span class="line" id="L69">        }</span>
<span class="line" id="L70"></span>
<span class="line" id="L71">        <span class="tok-comment">// Full middle blocks.</span>
</span>
<span class="line" id="L72">        <span class="tok-kw">while</span> (off + <span class="tok-number">64</span> &lt;= b.len) : (off += <span class="tok-number">64</span>) {</span>
<span class="line" id="L73">            d.round(b[off..][<span class="tok-number">0</span>..<span class="tok-number">64</span>]);</span>
<span class="line" id="L74">        }</span>
<span class="line" id="L75"></span>
<span class="line" id="L76">        <span class="tok-comment">// Copy any remainder for next pass.</span>
</span>
<span class="line" id="L77">        mem.copy(<span class="tok-type">u8</span>, d.buf[d.buf_len..], b[off..]);</span>
<span class="line" id="L78">        d.buf_len += <span class="tok-builtin">@intCast</span>(<span class="tok-type">u8</span>, b[off..].len);</span>
<span class="line" id="L79"></span>
<span class="line" id="L80">        d.total_len += b.len;</span>
<span class="line" id="L81">    }</span>
<span class="line" id="L82"></span>
<span class="line" id="L83">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">final</span>(d: *Self, out: *[digest_length]<span class="tok-type">u8</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L84">        <span class="tok-comment">// The buffer here will never be completely full.</span>
</span>
<span class="line" id="L85">        mem.set(<span class="tok-type">u8</span>, d.buf[d.buf_len..], <span class="tok-number">0</span>);</span>
<span class="line" id="L86"></span>
<span class="line" id="L87">        <span class="tok-comment">// Append padding bits.</span>
</span>
<span class="line" id="L88">        d.buf[d.buf_len] = <span class="tok-number">0x80</span>;</span>
<span class="line" id="L89">        d.buf_len += <span class="tok-number">1</span>;</span>
<span class="line" id="L90"></span>
<span class="line" id="L91">        <span class="tok-comment">// &gt; 448 mod 512 so need to add an extra round to wrap around.</span>
</span>
<span class="line" id="L92">        <span class="tok-kw">if</span> (<span class="tok-number">64</span> - d.buf_len &lt; <span class="tok-number">8</span>) {</span>
<span class="line" id="L93">            d.round(d.buf[<span class="tok-number">0</span>..]);</span>
<span class="line" id="L94">            mem.set(<span class="tok-type">u8</span>, d.buf[<span class="tok-number">0</span>..], <span class="tok-number">0</span>);</span>
<span class="line" id="L95">        }</span>
<span class="line" id="L96"></span>
<span class="line" id="L97">        <span class="tok-comment">// Append message length.</span>
</span>
<span class="line" id="L98">        <span class="tok-kw">var</span> i: <span class="tok-type">usize</span> = <span class="tok-number">1</span>;</span>
<span class="line" id="L99">        <span class="tok-kw">var</span> len = d.total_len &gt;&gt; <span class="tok-number">5</span>;</span>
<span class="line" id="L100">        d.buf[<span class="tok-number">63</span>] = <span class="tok-builtin">@intCast</span>(<span class="tok-type">u8</span>, d.total_len &amp; <span class="tok-number">0x1f</span>) &lt;&lt; <span class="tok-number">3</span>;</span>
<span class="line" id="L101">        <span class="tok-kw">while</span> (i &lt; <span class="tok-number">8</span>) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L102">            d.buf[<span class="tok-number">63</span> - i] = <span class="tok-builtin">@intCast</span>(<span class="tok-type">u8</span>, len &amp; <span class="tok-number">0xff</span>);</span>
<span class="line" id="L103">            len &gt;&gt;= <span class="tok-number">8</span>;</span>
<span class="line" id="L104">        }</span>
<span class="line" id="L105"></span>
<span class="line" id="L106">        d.round(d.buf[<span class="tok-number">0</span>..]);</span>
<span class="line" id="L107"></span>
<span class="line" id="L108">        <span class="tok-kw">for</span> (d.s) |s, j| {</span>
<span class="line" id="L109">            mem.writeIntBig(<span class="tok-type">u32</span>, out[<span class="tok-number">4</span> * j ..][<span class="tok-number">0</span>..<span class="tok-number">4</span>], s);</span>
<span class="line" id="L110">        }</span>
<span class="line" id="L111">    }</span>
<span class="line" id="L112"></span>
<span class="line" id="L113">    <span class="tok-kw">fn</span> <span class="tok-fn">round</span>(d: *Self, b: *<span class="tok-kw">const</span> [<span class="tok-number">64</span>]<span class="tok-type">u8</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L114">        <span class="tok-kw">var</span> s: [<span class="tok-number">16</span>]<span class="tok-type">u32</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L115"></span>
<span class="line" id="L116">        <span class="tok-kw">var</span> v: [<span class="tok-number">5</span>]<span class="tok-type">u32</span> = [_]<span class="tok-type">u32</span>{</span>
<span class="line" id="L117">            d.s[<span class="tok-number">0</span>],</span>
<span class="line" id="L118">            d.s[<span class="tok-number">1</span>],</span>
<span class="line" id="L119">            d.s[<span class="tok-number">2</span>],</span>
<span class="line" id="L120">            d.s[<span class="tok-number">3</span>],</span>
<span class="line" id="L121">            d.s[<span class="tok-number">4</span>],</span>
<span class="line" id="L122">        };</span>
<span class="line" id="L123"></span>
<span class="line" id="L124">        <span class="tok-kw">const</span> round0a = <span class="tok-kw">comptime</span> [_]RoundParam{</span>
<span class="line" id="L125">            roundParam(<span class="tok-number">0</span>, <span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">4</span>, <span class="tok-number">0</span>),</span>
<span class="line" id="L126">            roundParam(<span class="tok-number">4</span>, <span class="tok-number">0</span>, <span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">1</span>),</span>
<span class="line" id="L127">            roundParam(<span class="tok-number">3</span>, <span class="tok-number">4</span>, <span class="tok-number">0</span>, <span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">2</span>),</span>
<span class="line" id="L128">            roundParam(<span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">4</span>, <span class="tok-number">0</span>, <span class="tok-number">1</span>, <span class="tok-number">3</span>),</span>
<span class="line" id="L129">            roundParam(<span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">4</span>, <span class="tok-number">0</span>, <span class="tok-number">4</span>),</span>
<span class="line" id="L130">            roundParam(<span class="tok-number">0</span>, <span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">4</span>, <span class="tok-number">5</span>),</span>
<span class="line" id="L131">            roundParam(<span class="tok-number">4</span>, <span class="tok-number">0</span>, <span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">6</span>),</span>
<span class="line" id="L132">            roundParam(<span class="tok-number">3</span>, <span class="tok-number">4</span>, <span class="tok-number">0</span>, <span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">7</span>),</span>
<span class="line" id="L133">            roundParam(<span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">4</span>, <span class="tok-number">0</span>, <span class="tok-number">1</span>, <span class="tok-number">8</span>),</span>
<span class="line" id="L134">            roundParam(<span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">4</span>, <span class="tok-number">0</span>, <span class="tok-number">9</span>),</span>
<span class="line" id="L135">            roundParam(<span class="tok-number">0</span>, <span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">4</span>, <span class="tok-number">10</span>),</span>
<span class="line" id="L136">            roundParam(<span class="tok-number">4</span>, <span class="tok-number">0</span>, <span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">11</span>),</span>
<span class="line" id="L137">            roundParam(<span class="tok-number">3</span>, <span class="tok-number">4</span>, <span class="tok-number">0</span>, <span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">12</span>),</span>
<span class="line" id="L138">            roundParam(<span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">4</span>, <span class="tok-number">0</span>, <span class="tok-number">1</span>, <span class="tok-number">13</span>),</span>
<span class="line" id="L139">            roundParam(<span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">4</span>, <span class="tok-number">0</span>, <span class="tok-number">14</span>),</span>
<span class="line" id="L140">            roundParam(<span class="tok-number">0</span>, <span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">4</span>, <span class="tok-number">15</span>),</span>
<span class="line" id="L141">        };</span>
<span class="line" id="L142">        <span class="tok-kw">inline</span> <span class="tok-kw">for</span> (round0a) |r| {</span>
<span class="line" id="L143">            s[r.i] = (<span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, b[r.i * <span class="tok-number">4</span> + <span class="tok-number">0</span>]) &lt;&lt; <span class="tok-number">24</span>) | (<span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, b[r.i * <span class="tok-number">4</span> + <span class="tok-number">1</span>]) &lt;&lt; <span class="tok-number">16</span>) | (<span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, b[r.i * <span class="tok-number">4</span> + <span class="tok-number">2</span>]) &lt;&lt; <span class="tok-number">8</span>) | (<span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, b[r.i * <span class="tok-number">4</span> + <span class="tok-number">3</span>]) &lt;&lt; <span class="tok-number">0</span>);</span>
<span class="line" id="L144"></span>
<span class="line" id="L145">            v[r.e] = v[r.e] +% math.rotl(<span class="tok-type">u32</span>, v[r.a], <span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">5</span>)) +% <span class="tok-number">0x5A827999</span> +% s[r.i &amp; <span class="tok-number">0xf</span>] +% ((v[r.b] &amp; v[r.c]) | (~v[r.b] &amp; v[r.d]));</span>
<span class="line" id="L146">            v[r.b] = math.rotl(<span class="tok-type">u32</span>, v[r.b], <span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">30</span>));</span>
<span class="line" id="L147">        }</span>
<span class="line" id="L148"></span>
<span class="line" id="L149">        <span class="tok-kw">const</span> round0b = <span class="tok-kw">comptime</span> [_]RoundParam{</span>
<span class="line" id="L150">            roundParam(<span class="tok-number">4</span>, <span class="tok-number">0</span>, <span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">16</span>),</span>
<span class="line" id="L151">            roundParam(<span class="tok-number">3</span>, <span class="tok-number">4</span>, <span class="tok-number">0</span>, <span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">17</span>),</span>
<span class="line" id="L152">            roundParam(<span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">4</span>, <span class="tok-number">0</span>, <span class="tok-number">1</span>, <span class="tok-number">18</span>),</span>
<span class="line" id="L153">            roundParam(<span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">4</span>, <span class="tok-number">0</span>, <span class="tok-number">19</span>),</span>
<span class="line" id="L154">        };</span>
<span class="line" id="L155">        <span class="tok-kw">inline</span> <span class="tok-kw">for</span> (round0b) |r| {</span>
<span class="line" id="L156">            <span class="tok-kw">const</span> t = s[(r.i - <span class="tok-number">3</span>) &amp; <span class="tok-number">0xf</span>] ^ s[(r.i - <span class="tok-number">8</span>) &amp; <span class="tok-number">0xf</span>] ^ s[(r.i - <span class="tok-number">14</span>) &amp; <span class="tok-number">0xf</span>] ^ s[(r.i - <span class="tok-number">16</span>) &amp; <span class="tok-number">0xf</span>];</span>
<span class="line" id="L157">            s[r.i &amp; <span class="tok-number">0xf</span>] = math.rotl(<span class="tok-type">u32</span>, t, <span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">1</span>));</span>
<span class="line" id="L158"></span>
<span class="line" id="L159">            v[r.e] = v[r.e] +% math.rotl(<span class="tok-type">u32</span>, v[r.a], <span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">5</span>)) +% <span class="tok-number">0x5A827999</span> +% s[r.i &amp; <span class="tok-number">0xf</span>] +% ((v[r.b] &amp; v[r.c]) | (~v[r.b] &amp; v[r.d]));</span>
<span class="line" id="L160">            v[r.b] = math.rotl(<span class="tok-type">u32</span>, v[r.b], <span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">30</span>));</span>
<span class="line" id="L161">        }</span>
<span class="line" id="L162"></span>
<span class="line" id="L163">        <span class="tok-kw">const</span> round1 = <span class="tok-kw">comptime</span> [_]RoundParam{</span>
<span class="line" id="L164">            roundParam(<span class="tok-number">0</span>, <span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">4</span>, <span class="tok-number">20</span>),</span>
<span class="line" id="L165">            roundParam(<span class="tok-number">4</span>, <span class="tok-number">0</span>, <span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">21</span>),</span>
<span class="line" id="L166">            roundParam(<span class="tok-number">3</span>, <span class="tok-number">4</span>, <span class="tok-number">0</span>, <span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">22</span>),</span>
<span class="line" id="L167">            roundParam(<span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">4</span>, <span class="tok-number">0</span>, <span class="tok-number">1</span>, <span class="tok-number">23</span>),</span>
<span class="line" id="L168">            roundParam(<span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">4</span>, <span class="tok-number">0</span>, <span class="tok-number">24</span>),</span>
<span class="line" id="L169">            roundParam(<span class="tok-number">0</span>, <span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">4</span>, <span class="tok-number">25</span>),</span>
<span class="line" id="L170">            roundParam(<span class="tok-number">4</span>, <span class="tok-number">0</span>, <span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">26</span>),</span>
<span class="line" id="L171">            roundParam(<span class="tok-number">3</span>, <span class="tok-number">4</span>, <span class="tok-number">0</span>, <span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">27</span>),</span>
<span class="line" id="L172">            roundParam(<span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">4</span>, <span class="tok-number">0</span>, <span class="tok-number">1</span>, <span class="tok-number">28</span>),</span>
<span class="line" id="L173">            roundParam(<span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">4</span>, <span class="tok-number">0</span>, <span class="tok-number">29</span>),</span>
<span class="line" id="L174">            roundParam(<span class="tok-number">0</span>, <span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">4</span>, <span class="tok-number">30</span>),</span>
<span class="line" id="L175">            roundParam(<span class="tok-number">4</span>, <span class="tok-number">0</span>, <span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">31</span>),</span>
<span class="line" id="L176">            roundParam(<span class="tok-number">3</span>, <span class="tok-number">4</span>, <span class="tok-number">0</span>, <span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">32</span>),</span>
<span class="line" id="L177">            roundParam(<span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">4</span>, <span class="tok-number">0</span>, <span class="tok-number">1</span>, <span class="tok-number">33</span>),</span>
<span class="line" id="L178">            roundParam(<span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">4</span>, <span class="tok-number">0</span>, <span class="tok-number">34</span>),</span>
<span class="line" id="L179">            roundParam(<span class="tok-number">0</span>, <span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">4</span>, <span class="tok-number">35</span>),</span>
<span class="line" id="L180">            roundParam(<span class="tok-number">4</span>, <span class="tok-number">0</span>, <span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">36</span>),</span>
<span class="line" id="L181">            roundParam(<span class="tok-number">3</span>, <span class="tok-number">4</span>, <span class="tok-number">0</span>, <span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">37</span>),</span>
<span class="line" id="L182">            roundParam(<span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">4</span>, <span class="tok-number">0</span>, <span class="tok-number">1</span>, <span class="tok-number">38</span>),</span>
<span class="line" id="L183">            roundParam(<span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">4</span>, <span class="tok-number">0</span>, <span class="tok-number">39</span>),</span>
<span class="line" id="L184">        };</span>
<span class="line" id="L185">        <span class="tok-kw">inline</span> <span class="tok-kw">for</span> (round1) |r| {</span>
<span class="line" id="L186">            <span class="tok-kw">const</span> t = s[(r.i - <span class="tok-number">3</span>) &amp; <span class="tok-number">0xf</span>] ^ s[(r.i - <span class="tok-number">8</span>) &amp; <span class="tok-number">0xf</span>] ^ s[(r.i - <span class="tok-number">14</span>) &amp; <span class="tok-number">0xf</span>] ^ s[(r.i - <span class="tok-number">16</span>) &amp; <span class="tok-number">0xf</span>];</span>
<span class="line" id="L187">            s[r.i &amp; <span class="tok-number">0xf</span>] = math.rotl(<span class="tok-type">u32</span>, t, <span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">1</span>));</span>
<span class="line" id="L188"></span>
<span class="line" id="L189">            v[r.e] = v[r.e] +% math.rotl(<span class="tok-type">u32</span>, v[r.a], <span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">5</span>)) +% <span class="tok-number">0x6ED9EBA1</span> +% s[r.i &amp; <span class="tok-number">0xf</span>] +% (v[r.b] ^ v[r.c] ^ v[r.d]);</span>
<span class="line" id="L190">            v[r.b] = math.rotl(<span class="tok-type">u32</span>, v[r.b], <span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">30</span>));</span>
<span class="line" id="L191">        }</span>
<span class="line" id="L192"></span>
<span class="line" id="L193">        <span class="tok-kw">const</span> round2 = <span class="tok-kw">comptime</span> [_]RoundParam{</span>
<span class="line" id="L194">            roundParam(<span class="tok-number">0</span>, <span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">4</span>, <span class="tok-number">40</span>),</span>
<span class="line" id="L195">            roundParam(<span class="tok-number">4</span>, <span class="tok-number">0</span>, <span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">41</span>),</span>
<span class="line" id="L196">            roundParam(<span class="tok-number">3</span>, <span class="tok-number">4</span>, <span class="tok-number">0</span>, <span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">42</span>),</span>
<span class="line" id="L197">            roundParam(<span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">4</span>, <span class="tok-number">0</span>, <span class="tok-number">1</span>, <span class="tok-number">43</span>),</span>
<span class="line" id="L198">            roundParam(<span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">4</span>, <span class="tok-number">0</span>, <span class="tok-number">44</span>),</span>
<span class="line" id="L199">            roundParam(<span class="tok-number">0</span>, <span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">4</span>, <span class="tok-number">45</span>),</span>
<span class="line" id="L200">            roundParam(<span class="tok-number">4</span>, <span class="tok-number">0</span>, <span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">46</span>),</span>
<span class="line" id="L201">            roundParam(<span class="tok-number">3</span>, <span class="tok-number">4</span>, <span class="tok-number">0</span>, <span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">47</span>),</span>
<span class="line" id="L202">            roundParam(<span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">4</span>, <span class="tok-number">0</span>, <span class="tok-number">1</span>, <span class="tok-number">48</span>),</span>
<span class="line" id="L203">            roundParam(<span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">4</span>, <span class="tok-number">0</span>, <span class="tok-number">49</span>),</span>
<span class="line" id="L204">            roundParam(<span class="tok-number">0</span>, <span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">4</span>, <span class="tok-number">50</span>),</span>
<span class="line" id="L205">            roundParam(<span class="tok-number">4</span>, <span class="tok-number">0</span>, <span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">51</span>),</span>
<span class="line" id="L206">            roundParam(<span class="tok-number">3</span>, <span class="tok-number">4</span>, <span class="tok-number">0</span>, <span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">52</span>),</span>
<span class="line" id="L207">            roundParam(<span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">4</span>, <span class="tok-number">0</span>, <span class="tok-number">1</span>, <span class="tok-number">53</span>),</span>
<span class="line" id="L208">            roundParam(<span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">4</span>, <span class="tok-number">0</span>, <span class="tok-number">54</span>),</span>
<span class="line" id="L209">            roundParam(<span class="tok-number">0</span>, <span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">4</span>, <span class="tok-number">55</span>),</span>
<span class="line" id="L210">            roundParam(<span class="tok-number">4</span>, <span class="tok-number">0</span>, <span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">56</span>),</span>
<span class="line" id="L211">            roundParam(<span class="tok-number">3</span>, <span class="tok-number">4</span>, <span class="tok-number">0</span>, <span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">57</span>),</span>
<span class="line" id="L212">            roundParam(<span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">4</span>, <span class="tok-number">0</span>, <span class="tok-number">1</span>, <span class="tok-number">58</span>),</span>
<span class="line" id="L213">            roundParam(<span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">4</span>, <span class="tok-number">0</span>, <span class="tok-number">59</span>),</span>
<span class="line" id="L214">        };</span>
<span class="line" id="L215">        <span class="tok-kw">inline</span> <span class="tok-kw">for</span> (round2) |r| {</span>
<span class="line" id="L216">            <span class="tok-kw">const</span> t = s[(r.i - <span class="tok-number">3</span>) &amp; <span class="tok-number">0xf</span>] ^ s[(r.i - <span class="tok-number">8</span>) &amp; <span class="tok-number">0xf</span>] ^ s[(r.i - <span class="tok-number">14</span>) &amp; <span class="tok-number">0xf</span>] ^ s[(r.i - <span class="tok-number">16</span>) &amp; <span class="tok-number">0xf</span>];</span>
<span class="line" id="L217">            s[r.i &amp; <span class="tok-number">0xf</span>] = math.rotl(<span class="tok-type">u32</span>, t, <span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">1</span>));</span>
<span class="line" id="L218"></span>
<span class="line" id="L219">            v[r.e] = v[r.e] +% math.rotl(<span class="tok-type">u32</span>, v[r.a], <span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">5</span>)) +% <span class="tok-number">0x8F1BBCDC</span> +% s[r.i &amp; <span class="tok-number">0xf</span>] +% ((v[r.b] &amp; v[r.c]) ^ (v[r.b] &amp; v[r.d]) ^ (v[r.c] &amp; v[r.d]));</span>
<span class="line" id="L220">            v[r.b] = math.rotl(<span class="tok-type">u32</span>, v[r.b], <span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">30</span>));</span>
<span class="line" id="L221">        }</span>
<span class="line" id="L222"></span>
<span class="line" id="L223">        <span class="tok-kw">const</span> round3 = <span class="tok-kw">comptime</span> [_]RoundParam{</span>
<span class="line" id="L224">            roundParam(<span class="tok-number">0</span>, <span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">4</span>, <span class="tok-number">60</span>),</span>
<span class="line" id="L225">            roundParam(<span class="tok-number">4</span>, <span class="tok-number">0</span>, <span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">61</span>),</span>
<span class="line" id="L226">            roundParam(<span class="tok-number">3</span>, <span class="tok-number">4</span>, <span class="tok-number">0</span>, <span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">62</span>),</span>
<span class="line" id="L227">            roundParam(<span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">4</span>, <span class="tok-number">0</span>, <span class="tok-number">1</span>, <span class="tok-number">63</span>),</span>
<span class="line" id="L228">            roundParam(<span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">4</span>, <span class="tok-number">0</span>, <span class="tok-number">64</span>),</span>
<span class="line" id="L229">            roundParam(<span class="tok-number">0</span>, <span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">4</span>, <span class="tok-number">65</span>),</span>
<span class="line" id="L230">            roundParam(<span class="tok-number">4</span>, <span class="tok-number">0</span>, <span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">66</span>),</span>
<span class="line" id="L231">            roundParam(<span class="tok-number">3</span>, <span class="tok-number">4</span>, <span class="tok-number">0</span>, <span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">67</span>),</span>
<span class="line" id="L232">            roundParam(<span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">4</span>, <span class="tok-number">0</span>, <span class="tok-number">1</span>, <span class="tok-number">68</span>),</span>
<span class="line" id="L233">            roundParam(<span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">4</span>, <span class="tok-number">0</span>, <span class="tok-number">69</span>),</span>
<span class="line" id="L234">            roundParam(<span class="tok-number">0</span>, <span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">4</span>, <span class="tok-number">70</span>),</span>
<span class="line" id="L235">            roundParam(<span class="tok-number">4</span>, <span class="tok-number">0</span>, <span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">71</span>),</span>
<span class="line" id="L236">            roundParam(<span class="tok-number">3</span>, <span class="tok-number">4</span>, <span class="tok-number">0</span>, <span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">72</span>),</span>
<span class="line" id="L237">            roundParam(<span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">4</span>, <span class="tok-number">0</span>, <span class="tok-number">1</span>, <span class="tok-number">73</span>),</span>
<span class="line" id="L238">            roundParam(<span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">4</span>, <span class="tok-number">0</span>, <span class="tok-number">74</span>),</span>
<span class="line" id="L239">            roundParam(<span class="tok-number">0</span>, <span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">4</span>, <span class="tok-number">75</span>),</span>
<span class="line" id="L240">            roundParam(<span class="tok-number">4</span>, <span class="tok-number">0</span>, <span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">76</span>),</span>
<span class="line" id="L241">            roundParam(<span class="tok-number">3</span>, <span class="tok-number">4</span>, <span class="tok-number">0</span>, <span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">77</span>),</span>
<span class="line" id="L242">            roundParam(<span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">4</span>, <span class="tok-number">0</span>, <span class="tok-number">1</span>, <span class="tok-number">78</span>),</span>
<span class="line" id="L243">            roundParam(<span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">4</span>, <span class="tok-number">0</span>, <span class="tok-number">79</span>),</span>
<span class="line" id="L244">        };</span>
<span class="line" id="L245">        <span class="tok-kw">inline</span> <span class="tok-kw">for</span> (round3) |r| {</span>
<span class="line" id="L246">            <span class="tok-kw">const</span> t = s[(r.i - <span class="tok-number">3</span>) &amp; <span class="tok-number">0xf</span>] ^ s[(r.i - <span class="tok-number">8</span>) &amp; <span class="tok-number">0xf</span>] ^ s[(r.i - <span class="tok-number">14</span>) &amp; <span class="tok-number">0xf</span>] ^ s[(r.i - <span class="tok-number">16</span>) &amp; <span class="tok-number">0xf</span>];</span>
<span class="line" id="L247">            s[r.i &amp; <span class="tok-number">0xf</span>] = math.rotl(<span class="tok-type">u32</span>, t, <span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">1</span>));</span>
<span class="line" id="L248"></span>
<span class="line" id="L249">            v[r.e] = v[r.e] +% math.rotl(<span class="tok-type">u32</span>, v[r.a], <span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">5</span>)) +% <span class="tok-number">0xCA62C1D6</span> +% s[r.i &amp; <span class="tok-number">0xf</span>] +% (v[r.b] ^ v[r.c] ^ v[r.d]);</span>
<span class="line" id="L250">            v[r.b] = math.rotl(<span class="tok-type">u32</span>, v[r.b], <span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">30</span>));</span>
<span class="line" id="L251">        }</span>
<span class="line" id="L252"></span>
<span class="line" id="L253">        d.s[<span class="tok-number">0</span>] +%= v[<span class="tok-number">0</span>];</span>
<span class="line" id="L254">        d.s[<span class="tok-number">1</span>] +%= v[<span class="tok-number">1</span>];</span>
<span class="line" id="L255">        d.s[<span class="tok-number">2</span>] +%= v[<span class="tok-number">2</span>];</span>
<span class="line" id="L256">        d.s[<span class="tok-number">3</span>] +%= v[<span class="tok-number">3</span>];</span>
<span class="line" id="L257">        d.s[<span class="tok-number">4</span>] +%= v[<span class="tok-number">4</span>];</span>
<span class="line" id="L258">    }</span>
<span class="line" id="L259"></span>
<span class="line" id="L260">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> Error = <span class="tok-kw">error</span>{};</span>
<span class="line" id="L261">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> Writer = std.io.Writer(*Self, Error, write);</span>
<span class="line" id="L262"></span>
<span class="line" id="L263">    <span class="tok-kw">fn</span> <span class="tok-fn">write</span>(self: *Self, bytes: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) Error!<span class="tok-type">usize</span> {</span>
<span class="line" id="L264">        self.update(bytes);</span>
<span class="line" id="L265">        <span class="tok-kw">return</span> bytes.len;</span>
<span class="line" id="L266">    }</span>
<span class="line" id="L267"></span>
<span class="line" id="L268">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">writer</span>(self: *Self) Writer {</span>
<span class="line" id="L269">        <span class="tok-kw">return</span> .{ .context = self };</span>
<span class="line" id="L270">    }</span>
<span class="line" id="L271">};</span>
<span class="line" id="L272"></span>
<span class="line" id="L273"><span class="tok-kw">const</span> htest = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;test.zig&quot;</span>);</span>
<span class="line" id="L274"></span>
<span class="line" id="L275"><span class="tok-kw">test</span> <span class="tok-str">&quot;sha1 single&quot;</span> {</span>
<span class="line" id="L276">    <span class="tok-kw">try</span> htest.assertEqualHash(Sha1, <span class="tok-str">&quot;da39a3ee5e6b4b0d3255bfef95601890afd80709&quot;</span>, <span class="tok-str">&quot;&quot;</span>);</span>
<span class="line" id="L277">    <span class="tok-kw">try</span> htest.assertEqualHash(Sha1, <span class="tok-str">&quot;a9993e364706816aba3e25717850c26c9cd0d89d&quot;</span>, <span class="tok-str">&quot;abc&quot;</span>);</span>
<span class="line" id="L278">    <span class="tok-kw">try</span> htest.assertEqualHash(Sha1, <span class="tok-str">&quot;a49b2446a02c645bf419f995b67091253a04a259&quot;</span>, <span class="tok-str">&quot;abcdefghbcdefghicdefghijdefghijkefghijklfghijklmghijklmnhijklmnoijklmnopjklmnopqklmnopqrlmnopqrsmnopqrstnopqrstu&quot;</span>);</span>
<span class="line" id="L279">}</span>
<span class="line" id="L280"></span>
<span class="line" id="L281"><span class="tok-kw">test</span> <span class="tok-str">&quot;sha1 streaming&quot;</span> {</span>
<span class="line" id="L282">    <span class="tok-kw">var</span> h = Sha1.init(.{});</span>
<span class="line" id="L283">    <span class="tok-kw">var</span> out: [<span class="tok-number">20</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L284"></span>
<span class="line" id="L285">    h.final(&amp;out);</span>
<span class="line" id="L286">    <span class="tok-kw">try</span> htest.assertEqual(<span class="tok-str">&quot;da39a3ee5e6b4b0d3255bfef95601890afd80709&quot;</span>, out[<span class="tok-number">0</span>..]);</span>
<span class="line" id="L287"></span>
<span class="line" id="L288">    h = Sha1.init(.{});</span>
<span class="line" id="L289">    h.update(<span class="tok-str">&quot;abc&quot;</span>);</span>
<span class="line" id="L290">    h.final(&amp;out);</span>
<span class="line" id="L291">    <span class="tok-kw">try</span> htest.assertEqual(<span class="tok-str">&quot;a9993e364706816aba3e25717850c26c9cd0d89d&quot;</span>, out[<span class="tok-number">0</span>..]);</span>
<span class="line" id="L292"></span>
<span class="line" id="L293">    h = Sha1.init(.{});</span>
<span class="line" id="L294">    h.update(<span class="tok-str">&quot;a&quot;</span>);</span>
<span class="line" id="L295">    h.update(<span class="tok-str">&quot;b&quot;</span>);</span>
<span class="line" id="L296">    h.update(<span class="tok-str">&quot;c&quot;</span>);</span>
<span class="line" id="L297">    h.final(&amp;out);</span>
<span class="line" id="L298">    <span class="tok-kw">try</span> htest.assertEqual(<span class="tok-str">&quot;a9993e364706816aba3e25717850c26c9cd0d89d&quot;</span>, out[<span class="tok-number">0</span>..]);</span>
<span class="line" id="L299">}</span>
<span class="line" id="L300"></span>
<span class="line" id="L301"><span class="tok-kw">test</span> <span class="tok-str">&quot;sha1 aligned final&quot;</span> {</span>
<span class="line" id="L302">    <span class="tok-kw">var</span> block = [_]<span class="tok-type">u8</span>{<span class="tok-number">0</span>} ** Sha1.block_length;</span>
<span class="line" id="L303">    <span class="tok-kw">var</span> out: [Sha1.digest_length]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L304"></span>
<span class="line" id="L305">    <span class="tok-kw">var</span> h = Sha1.init(.{});</span>
<span class="line" id="L306">    h.update(&amp;block);</span>
<span class="line" id="L307">    h.final(out[<span class="tok-number">0</span>..]);</span>
<span class="line" id="L308">}</span>
<span class="line" id="L309"></span>
</code></pre></body>
</html>