<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">    <title>crypto/blake2.zig - source view</title>
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
<span class="line" id="L7"><span class="tok-kw">const</span> RoundParam = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L8">    a: <span class="tok-type">usize</span>,</span>
<span class="line" id="L9">    b: <span class="tok-type">usize</span>,</span>
<span class="line" id="L10">    c: <span class="tok-type">usize</span>,</span>
<span class="line" id="L11">    d: <span class="tok-type">usize</span>,</span>
<span class="line" id="L12">    x: <span class="tok-type">usize</span>,</span>
<span class="line" id="L13">    y: <span class="tok-type">usize</span>,</span>
<span class="line" id="L14">};</span>
<span class="line" id="L15"></span>
<span class="line" id="L16"><span class="tok-kw">fn</span> <span class="tok-fn">roundParam</span>(a: <span class="tok-type">usize</span>, b: <span class="tok-type">usize</span>, c: <span class="tok-type">usize</span>, d: <span class="tok-type">usize</span>, x: <span class="tok-type">usize</span>, y: <span class="tok-type">usize</span>) RoundParam {</span>
<span class="line" id="L17">    <span class="tok-kw">return</span> RoundParam{</span>
<span class="line" id="L18">        .a = a,</span>
<span class="line" id="L19">        .b = b,</span>
<span class="line" id="L20">        .c = c,</span>
<span class="line" id="L21">        .d = d,</span>
<span class="line" id="L22">        .x = x,</span>
<span class="line" id="L23">        .y = y,</span>
<span class="line" id="L24">    };</span>
<span class="line" id="L25">}</span>
<span class="line" id="L26"></span>
<span class="line" id="L27"><span class="tok-comment">/////////////////////</span>
</span>
<span class="line" id="L28"><span class="tok-comment">// Blake2s</span>
</span>
<span class="line" id="L29"></span>
<span class="line" id="L30"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> Blake2s128 = Blake2s(<span class="tok-number">128</span>);</span>
<span class="line" id="L31"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> Blake2s160 = Blake2s(<span class="tok-number">160</span>);</span>
<span class="line" id="L32"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> Blake2s224 = Blake2s(<span class="tok-number">224</span>);</span>
<span class="line" id="L33"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> Blake2s256 = Blake2s(<span class="tok-number">256</span>);</span>
<span class="line" id="L34"></span>
<span class="line" id="L35"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">Blake2s</span>(<span class="tok-kw">comptime</span> out_bits: <span class="tok-type">usize</span>) <span class="tok-type">type</span> {</span>
<span class="line" id="L36">    <span class="tok-kw">return</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L37">        <span class="tok-kw">const</span> Self = <span class="tok-builtin">@This</span>();</span>
<span class="line" id="L38">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> block_length = <span class="tok-number">64</span>;</span>
<span class="line" id="L39">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> digest_length = out_bits / <span class="tok-number">8</span>;</span>
<span class="line" id="L40">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> key_length_min = <span class="tok-number">0</span>;</span>
<span class="line" id="L41">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> key_length_max = <span class="tok-number">32</span>;</span>
<span class="line" id="L42">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> key_length = <span class="tok-number">32</span>; <span class="tok-comment">// recommended key length</span>
</span>
<span class="line" id="L43">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> Options = <span class="tok-kw">struct</span> { key: ?[]<span class="tok-kw">const</span> <span class="tok-type">u8</span> = <span class="tok-null">null</span>, salt: ?[<span class="tok-number">8</span>]<span class="tok-type">u8</span> = <span class="tok-null">null</span>, context: ?[<span class="tok-number">8</span>]<span class="tok-type">u8</span> = <span class="tok-null">null</span>, expected_out_bits: <span class="tok-type">usize</span> = out_bits };</span>
<span class="line" id="L44"></span>
<span class="line" id="L45">        <span class="tok-kw">const</span> iv = [<span class="tok-number">8</span>]<span class="tok-type">u32</span>{</span>
<span class="line" id="L46">            <span class="tok-number">0x6A09E667</span>,</span>
<span class="line" id="L47">            <span class="tok-number">0xBB67AE85</span>,</span>
<span class="line" id="L48">            <span class="tok-number">0x3C6EF372</span>,</span>
<span class="line" id="L49">            <span class="tok-number">0xA54FF53A</span>,</span>
<span class="line" id="L50">            <span class="tok-number">0x510E527F</span>,</span>
<span class="line" id="L51">            <span class="tok-number">0x9B05688C</span>,</span>
<span class="line" id="L52">            <span class="tok-number">0x1F83D9AB</span>,</span>
<span class="line" id="L53">            <span class="tok-number">0x5BE0CD19</span>,</span>
<span class="line" id="L54">        };</span>
<span class="line" id="L55"></span>
<span class="line" id="L56">        <span class="tok-kw">const</span> sigma = [<span class="tok-number">10</span>][<span class="tok-number">16</span>]<span class="tok-type">u8</span>{</span>
<span class="line" id="L57">            [_]<span class="tok-type">u8</span>{ <span class="tok-number">0</span>, <span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">4</span>, <span class="tok-number">5</span>, <span class="tok-number">6</span>, <span class="tok-number">7</span>, <span class="tok-number">8</span>, <span class="tok-number">9</span>, <span class="tok-number">10</span>, <span class="tok-number">11</span>, <span class="tok-number">12</span>, <span class="tok-number">13</span>, <span class="tok-number">14</span>, <span class="tok-number">15</span> },</span>
<span class="line" id="L58">            [_]<span class="tok-type">u8</span>{ <span class="tok-number">14</span>, <span class="tok-number">10</span>, <span class="tok-number">4</span>, <span class="tok-number">8</span>, <span class="tok-number">9</span>, <span class="tok-number">15</span>, <span class="tok-number">13</span>, <span class="tok-number">6</span>, <span class="tok-number">1</span>, <span class="tok-number">12</span>, <span class="tok-number">0</span>, <span class="tok-number">2</span>, <span class="tok-number">11</span>, <span class="tok-number">7</span>, <span class="tok-number">5</span>, <span class="tok-number">3</span> },</span>
<span class="line" id="L59">            [_]<span class="tok-type">u8</span>{ <span class="tok-number">11</span>, <span class="tok-number">8</span>, <span class="tok-number">12</span>, <span class="tok-number">0</span>, <span class="tok-number">5</span>, <span class="tok-number">2</span>, <span class="tok-number">15</span>, <span class="tok-number">13</span>, <span class="tok-number">10</span>, <span class="tok-number">14</span>, <span class="tok-number">3</span>, <span class="tok-number">6</span>, <span class="tok-number">7</span>, <span class="tok-number">1</span>, <span class="tok-number">9</span>, <span class="tok-number">4</span> },</span>
<span class="line" id="L60">            [_]<span class="tok-type">u8</span>{ <span class="tok-number">7</span>, <span class="tok-number">9</span>, <span class="tok-number">3</span>, <span class="tok-number">1</span>, <span class="tok-number">13</span>, <span class="tok-number">12</span>, <span class="tok-number">11</span>, <span class="tok-number">14</span>, <span class="tok-number">2</span>, <span class="tok-number">6</span>, <span class="tok-number">5</span>, <span class="tok-number">10</span>, <span class="tok-number">4</span>, <span class="tok-number">0</span>, <span class="tok-number">15</span>, <span class="tok-number">8</span> },</span>
<span class="line" id="L61">            [_]<span class="tok-type">u8</span>{ <span class="tok-number">9</span>, <span class="tok-number">0</span>, <span class="tok-number">5</span>, <span class="tok-number">7</span>, <span class="tok-number">2</span>, <span class="tok-number">4</span>, <span class="tok-number">10</span>, <span class="tok-number">15</span>, <span class="tok-number">14</span>, <span class="tok-number">1</span>, <span class="tok-number">11</span>, <span class="tok-number">12</span>, <span class="tok-number">6</span>, <span class="tok-number">8</span>, <span class="tok-number">3</span>, <span class="tok-number">13</span> },</span>
<span class="line" id="L62">            [_]<span class="tok-type">u8</span>{ <span class="tok-number">2</span>, <span class="tok-number">12</span>, <span class="tok-number">6</span>, <span class="tok-number">10</span>, <span class="tok-number">0</span>, <span class="tok-number">11</span>, <span class="tok-number">8</span>, <span class="tok-number">3</span>, <span class="tok-number">4</span>, <span class="tok-number">13</span>, <span class="tok-number">7</span>, <span class="tok-number">5</span>, <span class="tok-number">15</span>, <span class="tok-number">14</span>, <span class="tok-number">1</span>, <span class="tok-number">9</span> },</span>
<span class="line" id="L63">            [_]<span class="tok-type">u8</span>{ <span class="tok-number">12</span>, <span class="tok-number">5</span>, <span class="tok-number">1</span>, <span class="tok-number">15</span>, <span class="tok-number">14</span>, <span class="tok-number">13</span>, <span class="tok-number">4</span>, <span class="tok-number">10</span>, <span class="tok-number">0</span>, <span class="tok-number">7</span>, <span class="tok-number">6</span>, <span class="tok-number">3</span>, <span class="tok-number">9</span>, <span class="tok-number">2</span>, <span class="tok-number">8</span>, <span class="tok-number">11</span> },</span>
<span class="line" id="L64">            [_]<span class="tok-type">u8</span>{ <span class="tok-number">13</span>, <span class="tok-number">11</span>, <span class="tok-number">7</span>, <span class="tok-number">14</span>, <span class="tok-number">12</span>, <span class="tok-number">1</span>, <span class="tok-number">3</span>, <span class="tok-number">9</span>, <span class="tok-number">5</span>, <span class="tok-number">0</span>, <span class="tok-number">15</span>, <span class="tok-number">4</span>, <span class="tok-number">8</span>, <span class="tok-number">6</span>, <span class="tok-number">2</span>, <span class="tok-number">10</span> },</span>
<span class="line" id="L65">            [_]<span class="tok-type">u8</span>{ <span class="tok-number">6</span>, <span class="tok-number">15</span>, <span class="tok-number">14</span>, <span class="tok-number">9</span>, <span class="tok-number">11</span>, <span class="tok-number">3</span>, <span class="tok-number">0</span>, <span class="tok-number">8</span>, <span class="tok-number">12</span>, <span class="tok-number">2</span>, <span class="tok-number">13</span>, <span class="tok-number">7</span>, <span class="tok-number">1</span>, <span class="tok-number">4</span>, <span class="tok-number">10</span>, <span class="tok-number">5</span> },</span>
<span class="line" id="L66">            [_]<span class="tok-type">u8</span>{ <span class="tok-number">10</span>, <span class="tok-number">2</span>, <span class="tok-number">8</span>, <span class="tok-number">4</span>, <span class="tok-number">7</span>, <span class="tok-number">6</span>, <span class="tok-number">1</span>, <span class="tok-number">5</span>, <span class="tok-number">15</span>, <span class="tok-number">11</span>, <span class="tok-number">9</span>, <span class="tok-number">14</span>, <span class="tok-number">3</span>, <span class="tok-number">12</span>, <span class="tok-number">13</span>, <span class="tok-number">0</span> },</span>
<span class="line" id="L67">        };</span>
<span class="line" id="L68"></span>
<span class="line" id="L69">        h: [<span class="tok-number">8</span>]<span class="tok-type">u32</span>,</span>
<span class="line" id="L70">        t: <span class="tok-type">u64</span>,</span>
<span class="line" id="L71">        <span class="tok-comment">// Streaming cache</span>
</span>
<span class="line" id="L72">        buf: [<span class="tok-number">64</span>]<span class="tok-type">u8</span>,</span>
<span class="line" id="L73">        buf_len: <span class="tok-type">u8</span>,</span>
<span class="line" id="L74"></span>
<span class="line" id="L75">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">init</span>(options: Options) Self {</span>
<span class="line" id="L76">            <span class="tok-kw">comptime</span> debug.assert(<span class="tok-number">8</span> &lt;= out_bits <span class="tok-kw">and</span> out_bits &lt;= <span class="tok-number">256</span>);</span>
<span class="line" id="L77"></span>
<span class="line" id="L78">            <span class="tok-kw">var</span> d: Self = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L79">            mem.copy(<span class="tok-type">u32</span>, d.h[<span class="tok-number">0</span>..], iv[<span class="tok-number">0</span>..]);</span>
<span class="line" id="L80"></span>
<span class="line" id="L81">            <span class="tok-kw">const</span> key_len = <span class="tok-kw">if</span> (options.key) |key| key.len <span class="tok-kw">else</span> <span class="tok-number">0</span>;</span>
<span class="line" id="L82">            <span class="tok-comment">// default parameters</span>
</span>
<span class="line" id="L83">            d.h[<span class="tok-number">0</span>] ^= <span class="tok-number">0x01010000</span> ^ <span class="tok-builtin">@truncate</span>(<span class="tok-type">u32</span>, key_len &lt;&lt; <span class="tok-number">8</span>) ^ <span class="tok-builtin">@intCast</span>(<span class="tok-type">u32</span>, options.expected_out_bits &gt;&gt; <span class="tok-number">3</span>);</span>
<span class="line" id="L84">            d.t = <span class="tok-number">0</span>;</span>
<span class="line" id="L85">            d.buf_len = <span class="tok-number">0</span>;</span>
<span class="line" id="L86"></span>
<span class="line" id="L87">            <span class="tok-kw">if</span> (options.salt) |salt| {</span>
<span class="line" id="L88">                d.h[<span class="tok-number">4</span>] ^= mem.readIntLittle(<span class="tok-type">u32</span>, salt[<span class="tok-number">0</span>..<span class="tok-number">4</span>]);</span>
<span class="line" id="L89">                d.h[<span class="tok-number">5</span>] ^= mem.readIntLittle(<span class="tok-type">u32</span>, salt[<span class="tok-number">4</span>..<span class="tok-number">8</span>]);</span>
<span class="line" id="L90">            }</span>
<span class="line" id="L91">            <span class="tok-kw">if</span> (options.context) |context| {</span>
<span class="line" id="L92">                d.h[<span class="tok-number">6</span>] ^= mem.readIntLittle(<span class="tok-type">u32</span>, context[<span class="tok-number">0</span>..<span class="tok-number">4</span>]);</span>
<span class="line" id="L93">                d.h[<span class="tok-number">7</span>] ^= mem.readIntLittle(<span class="tok-type">u32</span>, context[<span class="tok-number">4</span>..<span class="tok-number">8</span>]);</span>
<span class="line" id="L94">            }</span>
<span class="line" id="L95">            <span class="tok-kw">if</span> (key_len &gt; <span class="tok-number">0</span>) {</span>
<span class="line" id="L96">                mem.set(<span class="tok-type">u8</span>, d.buf[key_len..], <span class="tok-number">0</span>);</span>
<span class="line" id="L97">                d.update(options.key.?);</span>
<span class="line" id="L98">                d.buf_len = <span class="tok-number">64</span>;</span>
<span class="line" id="L99">            }</span>
<span class="line" id="L100">            <span class="tok-kw">return</span> d;</span>
<span class="line" id="L101">        }</span>
<span class="line" id="L102"></span>
<span class="line" id="L103">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">hash</span>(b: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, out: *[digest_length]<span class="tok-type">u8</span>, options: Options) <span class="tok-type">void</span> {</span>
<span class="line" id="L104">            <span class="tok-kw">var</span> d = Self.init(options);</span>
<span class="line" id="L105">            d.update(b);</span>
<span class="line" id="L106">            d.final(out);</span>
<span class="line" id="L107">        }</span>
<span class="line" id="L108"></span>
<span class="line" id="L109">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">update</span>(d: *Self, b: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L110">            <span class="tok-kw">var</span> off: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L111"></span>
<span class="line" id="L112">            <span class="tok-comment">// Partial buffer exists from previous update. Copy into buffer then hash.</span>
</span>
<span class="line" id="L113">            <span class="tok-kw">if</span> (d.buf_len != <span class="tok-number">0</span> <span class="tok-kw">and</span> d.buf_len + b.len &gt; <span class="tok-number">64</span>) {</span>
<span class="line" id="L114">                off += <span class="tok-number">64</span> - d.buf_len;</span>
<span class="line" id="L115">                mem.copy(<span class="tok-type">u8</span>, d.buf[d.buf_len..], b[<span class="tok-number">0</span>..off]);</span>
<span class="line" id="L116">                d.t += <span class="tok-number">64</span>;</span>
<span class="line" id="L117">                d.round(d.buf[<span class="tok-number">0</span>..], <span class="tok-null">false</span>);</span>
<span class="line" id="L118">                d.buf_len = <span class="tok-number">0</span>;</span>
<span class="line" id="L119">            }</span>
<span class="line" id="L120"></span>
<span class="line" id="L121">            <span class="tok-comment">// Full middle blocks.</span>
</span>
<span class="line" id="L122">            <span class="tok-kw">while</span> (off + <span class="tok-number">64</span> &lt; b.len) : (off += <span class="tok-number">64</span>) {</span>
<span class="line" id="L123">                d.t += <span class="tok-number">64</span>;</span>
<span class="line" id="L124">                d.round(b[off..][<span class="tok-number">0</span>..<span class="tok-number">64</span>], <span class="tok-null">false</span>);</span>
<span class="line" id="L125">            }</span>
<span class="line" id="L126"></span>
<span class="line" id="L127">            <span class="tok-comment">// Copy any remainder for next pass.</span>
</span>
<span class="line" id="L128">            mem.copy(<span class="tok-type">u8</span>, d.buf[d.buf_len..], b[off..]);</span>
<span class="line" id="L129">            d.buf_len += <span class="tok-builtin">@intCast</span>(<span class="tok-type">u8</span>, b[off..].len);</span>
<span class="line" id="L130">        }</span>
<span class="line" id="L131"></span>
<span class="line" id="L132">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">final</span>(d: *Self, out: *[digest_length]<span class="tok-type">u8</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L133">            mem.set(<span class="tok-type">u8</span>, d.buf[d.buf_len..], <span class="tok-number">0</span>);</span>
<span class="line" id="L134">            d.t += d.buf_len;</span>
<span class="line" id="L135">            d.round(d.buf[<span class="tok-number">0</span>..], <span class="tok-null">true</span>);</span>
<span class="line" id="L136">            <span class="tok-kw">for</span> (d.h) |*x| x.* = mem.nativeToLittle(<span class="tok-type">u32</span>, x.*);</span>
<span class="line" id="L137">            mem.copy(<span class="tok-type">u8</span>, out[<span class="tok-number">0</span>..], <span class="tok-builtin">@ptrCast</span>(*[digest_length]<span class="tok-type">u8</span>, &amp;d.h));</span>
<span class="line" id="L138">        }</span>
<span class="line" id="L139"></span>
<span class="line" id="L140">        <span class="tok-kw">fn</span> <span class="tok-fn">round</span>(d: *Self, b: *<span class="tok-kw">const</span> [<span class="tok-number">64</span>]<span class="tok-type">u8</span>, last: <span class="tok-type">bool</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L141">            <span class="tok-kw">var</span> m: [<span class="tok-number">16</span>]<span class="tok-type">u32</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L142">            <span class="tok-kw">var</span> v: [<span class="tok-number">16</span>]<span class="tok-type">u32</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L143"></span>
<span class="line" id="L144">            <span class="tok-kw">for</span> (m) |*r, i| {</span>
<span class="line" id="L145">                r.* = mem.readIntLittle(<span class="tok-type">u32</span>, b[<span class="tok-number">4</span> * i ..][<span class="tok-number">0</span>..<span class="tok-number">4</span>]);</span>
<span class="line" id="L146">            }</span>
<span class="line" id="L147"></span>
<span class="line" id="L148">            <span class="tok-kw">var</span> k: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L149">            <span class="tok-kw">while</span> (k &lt; <span class="tok-number">8</span>) : (k += <span class="tok-number">1</span>) {</span>
<span class="line" id="L150">                v[k] = d.h[k];</span>
<span class="line" id="L151">                v[k + <span class="tok-number">8</span>] = iv[k];</span>
<span class="line" id="L152">            }</span>
<span class="line" id="L153"></span>
<span class="line" id="L154">            v[<span class="tok-number">12</span>] ^= <span class="tok-builtin">@truncate</span>(<span class="tok-type">u32</span>, d.t);</span>
<span class="line" id="L155">            v[<span class="tok-number">13</span>] ^= <span class="tok-builtin">@intCast</span>(<span class="tok-type">u32</span>, d.t &gt;&gt; <span class="tok-number">32</span>);</span>
<span class="line" id="L156">            <span class="tok-kw">if</span> (last) v[<span class="tok-number">14</span>] = ~v[<span class="tok-number">14</span>];</span>
<span class="line" id="L157"></span>
<span class="line" id="L158">            <span class="tok-kw">const</span> rounds = <span class="tok-kw">comptime</span> [_]RoundParam{</span>
<span class="line" id="L159">                roundParam(<span class="tok-number">0</span>, <span class="tok-number">4</span>, <span class="tok-number">8</span>, <span class="tok-number">12</span>, <span class="tok-number">0</span>, <span class="tok-number">1</span>),</span>
<span class="line" id="L160">                roundParam(<span class="tok-number">1</span>, <span class="tok-number">5</span>, <span class="tok-number">9</span>, <span class="tok-number">13</span>, <span class="tok-number">2</span>, <span class="tok-number">3</span>),</span>
<span class="line" id="L161">                roundParam(<span class="tok-number">2</span>, <span class="tok-number">6</span>, <span class="tok-number">10</span>, <span class="tok-number">14</span>, <span class="tok-number">4</span>, <span class="tok-number">5</span>),</span>
<span class="line" id="L162">                roundParam(<span class="tok-number">3</span>, <span class="tok-number">7</span>, <span class="tok-number">11</span>, <span class="tok-number">15</span>, <span class="tok-number">6</span>, <span class="tok-number">7</span>),</span>
<span class="line" id="L163">                roundParam(<span class="tok-number">0</span>, <span class="tok-number">5</span>, <span class="tok-number">10</span>, <span class="tok-number">15</span>, <span class="tok-number">8</span>, <span class="tok-number">9</span>),</span>
<span class="line" id="L164">                roundParam(<span class="tok-number">1</span>, <span class="tok-number">6</span>, <span class="tok-number">11</span>, <span class="tok-number">12</span>, <span class="tok-number">10</span>, <span class="tok-number">11</span>),</span>
<span class="line" id="L165">                roundParam(<span class="tok-number">2</span>, <span class="tok-number">7</span>, <span class="tok-number">8</span>, <span class="tok-number">13</span>, <span class="tok-number">12</span>, <span class="tok-number">13</span>),</span>
<span class="line" id="L166">                roundParam(<span class="tok-number">3</span>, <span class="tok-number">4</span>, <span class="tok-number">9</span>, <span class="tok-number">14</span>, <span class="tok-number">14</span>, <span class="tok-number">15</span>),</span>
<span class="line" id="L167">            };</span>
<span class="line" id="L168"></span>
<span class="line" id="L169">            <span class="tok-kw">comptime</span> <span class="tok-kw">var</span> j: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L170">            <span class="tok-kw">inline</span> <span class="tok-kw">while</span> (j &lt; <span class="tok-number">10</span>) : (j += <span class="tok-number">1</span>) {</span>
<span class="line" id="L171">                <span class="tok-kw">inline</span> <span class="tok-kw">for</span> (rounds) |r| {</span>
<span class="line" id="L172">                    v[r.a] = v[r.a] +% v[r.b] +% m[sigma[j][r.x]];</span>
<span class="line" id="L173">                    v[r.d] = math.rotr(<span class="tok-type">u32</span>, v[r.d] ^ v[r.a], <span class="tok-builtin">@as</span>(<span class="tok-type">usize</span>, <span class="tok-number">16</span>));</span>
<span class="line" id="L174">                    v[r.c] = v[r.c] +% v[r.d];</span>
<span class="line" id="L175">                    v[r.b] = math.rotr(<span class="tok-type">u32</span>, v[r.b] ^ v[r.c], <span class="tok-builtin">@as</span>(<span class="tok-type">usize</span>, <span class="tok-number">12</span>));</span>
<span class="line" id="L176">                    v[r.a] = v[r.a] +% v[r.b] +% m[sigma[j][r.y]];</span>
<span class="line" id="L177">                    v[r.d] = math.rotr(<span class="tok-type">u32</span>, v[r.d] ^ v[r.a], <span class="tok-builtin">@as</span>(<span class="tok-type">usize</span>, <span class="tok-number">8</span>));</span>
<span class="line" id="L178">                    v[r.c] = v[r.c] +% v[r.d];</span>
<span class="line" id="L179">                    v[r.b] = math.rotr(<span class="tok-type">u32</span>, v[r.b] ^ v[r.c], <span class="tok-builtin">@as</span>(<span class="tok-type">usize</span>, <span class="tok-number">7</span>));</span>
<span class="line" id="L180">                }</span>
<span class="line" id="L181">            }</span>
<span class="line" id="L182"></span>
<span class="line" id="L183">            <span class="tok-kw">for</span> (d.h) |*r, i| {</span>
<span class="line" id="L184">                r.* ^= v[i] ^ v[i + <span class="tok-number">8</span>];</span>
<span class="line" id="L185">            }</span>
<span class="line" id="L186">        }</span>
<span class="line" id="L187"></span>
<span class="line" id="L188">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> Error = <span class="tok-kw">error</span>{};</span>
<span class="line" id="L189">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> Writer = std.io.Writer(*Self, Error, write);</span>
<span class="line" id="L190"></span>
<span class="line" id="L191">        <span class="tok-kw">fn</span> <span class="tok-fn">write</span>(self: *Self, bytes: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) Error!<span class="tok-type">usize</span> {</span>
<span class="line" id="L192">            self.update(bytes);</span>
<span class="line" id="L193">            <span class="tok-kw">return</span> bytes.len;</span>
<span class="line" id="L194">        }</span>
<span class="line" id="L195"></span>
<span class="line" id="L196">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">writer</span>(self: *Self) Writer {</span>
<span class="line" id="L197">            <span class="tok-kw">return</span> .{ .context = self };</span>
<span class="line" id="L198">        }</span>
<span class="line" id="L199">    };</span>
<span class="line" id="L200">}</span>
<span class="line" id="L201"></span>
<span class="line" id="L202"><span class="tok-kw">test</span> <span class="tok-str">&quot;blake2s160 single&quot;</span> {</span>
<span class="line" id="L203">    <span class="tok-kw">const</span> h1 = <span class="tok-str">&quot;354c9c33f735962418bdacb9479873429c34916f&quot;</span>;</span>
<span class="line" id="L204">    <span class="tok-kw">try</span> htest.assertEqualHash(Blake2s160, h1, <span class="tok-str">&quot;&quot;</span>);</span>
<span class="line" id="L205"></span>
<span class="line" id="L206">    <span class="tok-kw">const</span> h2 = <span class="tok-str">&quot;5ae3b99be29b01834c3b508521ede60438f8de17&quot;</span>;</span>
<span class="line" id="L207">    <span class="tok-kw">try</span> htest.assertEqualHash(Blake2s160, h2, <span class="tok-str">&quot;abc&quot;</span>);</span>
<span class="line" id="L208"></span>
<span class="line" id="L209">    <span class="tok-kw">const</span> h3 = <span class="tok-str">&quot;5a604fec9713c369e84b0ed68daed7d7504ef240&quot;</span>;</span>
<span class="line" id="L210">    <span class="tok-kw">try</span> htest.assertEqualHash(Blake2s160, h3, <span class="tok-str">&quot;The quick brown fox jumps over the lazy dog&quot;</span>);</span>
<span class="line" id="L211"></span>
<span class="line" id="L212">    <span class="tok-kw">const</span> h4 = <span class="tok-str">&quot;b60c4dc60e2681e58fbc24e77f07e02c69e72ed0&quot;</span>;</span>
<span class="line" id="L213">    <span class="tok-kw">try</span> htest.assertEqualHash(Blake2s160, h4, <span class="tok-str">&quot;a&quot;</span> ** <span class="tok-number">32</span> ++ <span class="tok-str">&quot;b&quot;</span> ** <span class="tok-number">32</span>);</span>
<span class="line" id="L214">}</span>
<span class="line" id="L215"></span>
<span class="line" id="L216"><span class="tok-kw">test</span> <span class="tok-str">&quot;blake2s160 streaming&quot;</span> {</span>
<span class="line" id="L217">    <span class="tok-kw">var</span> h = Blake2s160.init(.{});</span>
<span class="line" id="L218">    <span class="tok-kw">var</span> out: [<span class="tok-number">20</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L219"></span>
<span class="line" id="L220">    <span class="tok-kw">const</span> h1 = <span class="tok-str">&quot;354c9c33f735962418bdacb9479873429c34916f&quot;</span>;</span>
<span class="line" id="L221"></span>
<span class="line" id="L222">    h.final(out[<span class="tok-number">0</span>..]);</span>
<span class="line" id="L223">    <span class="tok-kw">try</span> htest.assertEqual(h1, out[<span class="tok-number">0</span>..]);</span>
<span class="line" id="L224"></span>
<span class="line" id="L225">    <span class="tok-kw">const</span> h2 = <span class="tok-str">&quot;5ae3b99be29b01834c3b508521ede60438f8de17&quot;</span>;</span>
<span class="line" id="L226"></span>
<span class="line" id="L227">    h = Blake2s160.init(.{});</span>
<span class="line" id="L228">    h.update(<span class="tok-str">&quot;abc&quot;</span>);</span>
<span class="line" id="L229">    h.final(out[<span class="tok-number">0</span>..]);</span>
<span class="line" id="L230">    <span class="tok-kw">try</span> htest.assertEqual(h2, out[<span class="tok-number">0</span>..]);</span>
<span class="line" id="L231"></span>
<span class="line" id="L232">    h = Blake2s160.init(.{});</span>
<span class="line" id="L233">    h.update(<span class="tok-str">&quot;a&quot;</span>);</span>
<span class="line" id="L234">    h.update(<span class="tok-str">&quot;b&quot;</span>);</span>
<span class="line" id="L235">    h.update(<span class="tok-str">&quot;c&quot;</span>);</span>
<span class="line" id="L236">    h.final(out[<span class="tok-number">0</span>..]);</span>
<span class="line" id="L237">    <span class="tok-kw">try</span> htest.assertEqual(h2, out[<span class="tok-number">0</span>..]);</span>
<span class="line" id="L238"></span>
<span class="line" id="L239">    <span class="tok-kw">const</span> h3 = <span class="tok-str">&quot;b60c4dc60e2681e58fbc24e77f07e02c69e72ed0&quot;</span>;</span>
<span class="line" id="L240"></span>
<span class="line" id="L241">    h = Blake2s160.init(.{});</span>
<span class="line" id="L242">    h.update(<span class="tok-str">&quot;a&quot;</span> ** <span class="tok-number">32</span>);</span>
<span class="line" id="L243">    h.update(<span class="tok-str">&quot;b&quot;</span> ** <span class="tok-number">32</span>);</span>
<span class="line" id="L244">    h.final(out[<span class="tok-number">0</span>..]);</span>
<span class="line" id="L245">    <span class="tok-kw">try</span> htest.assertEqual(h3, out[<span class="tok-number">0</span>..]);</span>
<span class="line" id="L246"></span>
<span class="line" id="L247">    h = Blake2s160.init(.{});</span>
<span class="line" id="L248">    h.update(<span class="tok-str">&quot;a&quot;</span> ** <span class="tok-number">32</span> ++ <span class="tok-str">&quot;b&quot;</span> ** <span class="tok-number">32</span>);</span>
<span class="line" id="L249">    h.final(out[<span class="tok-number">0</span>..]);</span>
<span class="line" id="L250">    <span class="tok-kw">try</span> htest.assertEqual(h3, out[<span class="tok-number">0</span>..]);</span>
<span class="line" id="L251"></span>
<span class="line" id="L252">    <span class="tok-kw">const</span> h4 = <span class="tok-str">&quot;4667fd60791a7fe41f939bca646b4529e296bd68&quot;</span>;</span>
<span class="line" id="L253"></span>
<span class="line" id="L254">    h = Blake2s160.init(.{ .context = [_]<span class="tok-type">u8</span>{<span class="tok-number">0x69</span>} ** <span class="tok-number">8</span>, .salt = [_]<span class="tok-type">u8</span>{<span class="tok-number">0x42</span>} ** <span class="tok-number">8</span> });</span>
<span class="line" id="L255">    h.update(<span class="tok-str">&quot;a&quot;</span> ** <span class="tok-number">32</span>);</span>
<span class="line" id="L256">    h.update(<span class="tok-str">&quot;b&quot;</span> ** <span class="tok-number">32</span>);</span>
<span class="line" id="L257">    h.final(out[<span class="tok-number">0</span>..]);</span>
<span class="line" id="L258">    <span class="tok-kw">try</span> htest.assertEqual(h4, out[<span class="tok-number">0</span>..]);</span>
<span class="line" id="L259"></span>
<span class="line" id="L260">    h = Blake2s160.init(.{ .context = [_]<span class="tok-type">u8</span>{<span class="tok-number">0x69</span>} ** <span class="tok-number">8</span>, .salt = [_]<span class="tok-type">u8</span>{<span class="tok-number">0x42</span>} ** <span class="tok-number">8</span> });</span>
<span class="line" id="L261">    h.update(<span class="tok-str">&quot;a&quot;</span> ** <span class="tok-number">32</span> ++ <span class="tok-str">&quot;b&quot;</span> ** <span class="tok-number">32</span>);</span>
<span class="line" id="L262">    h.final(out[<span class="tok-number">0</span>..]);</span>
<span class="line" id="L263">    <span class="tok-kw">try</span> htest.assertEqual(h4, out[<span class="tok-number">0</span>..]);</span>
<span class="line" id="L264">}</span>
<span class="line" id="L265"></span>
<span class="line" id="L266"><span class="tok-kw">test</span> <span class="tok-str">&quot;comptime blake2s160&quot;</span> {</span>
<span class="line" id="L267">    <span class="tok-comment">//comptime</span>
</span>
<span class="line" id="L268">    {</span>
<span class="line" id="L269">        <span class="tok-builtin">@setEvalBranchQuota</span>(<span class="tok-number">10000</span>);</span>
<span class="line" id="L270">        <span class="tok-kw">var</span> block = [_]<span class="tok-type">u8</span>{<span class="tok-number">0</span>} ** Blake2s160.block_length;</span>
<span class="line" id="L271">        <span class="tok-kw">var</span> out: [Blake2s160.digest_length]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L272"></span>
<span class="line" id="L273">        <span class="tok-kw">const</span> h1 = <span class="tok-str">&quot;2c56ad9d0b2c8b474aafa93ab307db2f0940105f&quot;</span>;</span>
<span class="line" id="L274"></span>
<span class="line" id="L275">        <span class="tok-kw">try</span> htest.assertEqualHash(Blake2s160, h1, block[<span class="tok-number">0</span>..]);</span>
<span class="line" id="L276"></span>
<span class="line" id="L277">        <span class="tok-kw">var</span> h = Blake2s160.init(.{});</span>
<span class="line" id="L278">        h.update(&amp;block);</span>
<span class="line" id="L279">        h.final(out[<span class="tok-number">0</span>..]);</span>
<span class="line" id="L280"></span>
<span class="line" id="L281">        <span class="tok-kw">try</span> htest.assertEqual(h1, out[<span class="tok-number">0</span>..]);</span>
<span class="line" id="L282">    }</span>
<span class="line" id="L283">}</span>
<span class="line" id="L284"></span>
<span class="line" id="L285"><span class="tok-kw">test</span> <span class="tok-str">&quot;blake2s224 single&quot;</span> {</span>
<span class="line" id="L286">    <span class="tok-kw">const</span> h1 = <span class="tok-str">&quot;1fa1291e65248b37b3433475b2a0dd63d54a11ecc4e3e034e7bc1ef4&quot;</span>;</span>
<span class="line" id="L287">    <span class="tok-kw">try</span> htest.assertEqualHash(Blake2s224, h1, <span class="tok-str">&quot;&quot;</span>);</span>
<span class="line" id="L288"></span>
<span class="line" id="L289">    <span class="tok-kw">const</span> h2 = <span class="tok-str">&quot;0b033fc226df7abde29f67a05d3dc62cf271ef3dfea4d387407fbd55&quot;</span>;</span>
<span class="line" id="L290">    <span class="tok-kw">try</span> htest.assertEqualHash(Blake2s224, h2, <span class="tok-str">&quot;abc&quot;</span>);</span>
<span class="line" id="L291"></span>
<span class="line" id="L292">    <span class="tok-kw">const</span> h3 = <span class="tok-str">&quot;e4e5cb6c7cae41982b397bf7b7d2d9d1949823ae78435326e8db4912&quot;</span>;</span>
<span class="line" id="L293">    <span class="tok-kw">try</span> htest.assertEqualHash(Blake2s224, h3, <span class="tok-str">&quot;The quick brown fox jumps over the lazy dog&quot;</span>);</span>
<span class="line" id="L294"></span>
<span class="line" id="L295">    <span class="tok-kw">const</span> h4 = <span class="tok-str">&quot;557381a78facd2b298640f4e32113e58967d61420af1aa939d0cfe01&quot;</span>;</span>
<span class="line" id="L296">    <span class="tok-kw">try</span> htest.assertEqualHash(Blake2s224, h4, <span class="tok-str">&quot;a&quot;</span> ** <span class="tok-number">32</span> ++ <span class="tok-str">&quot;b&quot;</span> ** <span class="tok-number">32</span>);</span>
<span class="line" id="L297">}</span>
<span class="line" id="L298"></span>
<span class="line" id="L299"><span class="tok-kw">test</span> <span class="tok-str">&quot;blake2s224 streaming&quot;</span> {</span>
<span class="line" id="L300">    <span class="tok-kw">var</span> h = Blake2s224.init(.{});</span>
<span class="line" id="L301">    <span class="tok-kw">var</span> out: [<span class="tok-number">28</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L302"></span>
<span class="line" id="L303">    <span class="tok-kw">const</span> h1 = <span class="tok-str">&quot;1fa1291e65248b37b3433475b2a0dd63d54a11ecc4e3e034e7bc1ef4&quot;</span>;</span>
<span class="line" id="L304"></span>
<span class="line" id="L305">    h.final(out[<span class="tok-number">0</span>..]);</span>
<span class="line" id="L306">    <span class="tok-kw">try</span> htest.assertEqual(h1, out[<span class="tok-number">0</span>..]);</span>
<span class="line" id="L307"></span>
<span class="line" id="L308">    <span class="tok-kw">const</span> h2 = <span class="tok-str">&quot;0b033fc226df7abde29f67a05d3dc62cf271ef3dfea4d387407fbd55&quot;</span>;</span>
<span class="line" id="L309"></span>
<span class="line" id="L310">    h = Blake2s224.init(.{});</span>
<span class="line" id="L311">    h.update(<span class="tok-str">&quot;abc&quot;</span>);</span>
<span class="line" id="L312">    h.final(out[<span class="tok-number">0</span>..]);</span>
<span class="line" id="L313">    <span class="tok-kw">try</span> htest.assertEqual(h2, out[<span class="tok-number">0</span>..]);</span>
<span class="line" id="L314"></span>
<span class="line" id="L315">    h = Blake2s224.init(.{});</span>
<span class="line" id="L316">    h.update(<span class="tok-str">&quot;a&quot;</span>);</span>
<span class="line" id="L317">    h.update(<span class="tok-str">&quot;b&quot;</span>);</span>
<span class="line" id="L318">    h.update(<span class="tok-str">&quot;c&quot;</span>);</span>
<span class="line" id="L319">    h.final(out[<span class="tok-number">0</span>..]);</span>
<span class="line" id="L320">    <span class="tok-kw">try</span> htest.assertEqual(h2, out[<span class="tok-number">0</span>..]);</span>
<span class="line" id="L321"></span>
<span class="line" id="L322">    <span class="tok-kw">const</span> h3 = <span class="tok-str">&quot;557381a78facd2b298640f4e32113e58967d61420af1aa939d0cfe01&quot;</span>;</span>
<span class="line" id="L323"></span>
<span class="line" id="L324">    h = Blake2s224.init(.{});</span>
<span class="line" id="L325">    h.update(<span class="tok-str">&quot;a&quot;</span> ** <span class="tok-number">32</span>);</span>
<span class="line" id="L326">    h.update(<span class="tok-str">&quot;b&quot;</span> ** <span class="tok-number">32</span>);</span>
<span class="line" id="L327">    h.final(out[<span class="tok-number">0</span>..]);</span>
<span class="line" id="L328">    <span class="tok-kw">try</span> htest.assertEqual(h3, out[<span class="tok-number">0</span>..]);</span>
<span class="line" id="L329"></span>
<span class="line" id="L330">    h = Blake2s224.init(.{});</span>
<span class="line" id="L331">    h.update(<span class="tok-str">&quot;a&quot;</span> ** <span class="tok-number">32</span> ++ <span class="tok-str">&quot;b&quot;</span> ** <span class="tok-number">32</span>);</span>
<span class="line" id="L332">    h.final(out[<span class="tok-number">0</span>..]);</span>
<span class="line" id="L333">    <span class="tok-kw">try</span> htest.assertEqual(h3, out[<span class="tok-number">0</span>..]);</span>
<span class="line" id="L334"></span>
<span class="line" id="L335">    <span class="tok-kw">const</span> h4 = <span class="tok-str">&quot;a4d6a9d253441b80e5dfd60a04db169ffab77aec56a2855c402828c3&quot;</span>;</span>
<span class="line" id="L336"></span>
<span class="line" id="L337">    h = Blake2s224.init(.{ .context = [_]<span class="tok-type">u8</span>{<span class="tok-number">0x69</span>} ** <span class="tok-number">8</span>, .salt = [_]<span class="tok-type">u8</span>{<span class="tok-number">0x42</span>} ** <span class="tok-number">8</span> });</span>
<span class="line" id="L338">    h.update(<span class="tok-str">&quot;a&quot;</span> ** <span class="tok-number">32</span>);</span>
<span class="line" id="L339">    h.update(<span class="tok-str">&quot;b&quot;</span> ** <span class="tok-number">32</span>);</span>
<span class="line" id="L340">    h.final(out[<span class="tok-number">0</span>..]);</span>
<span class="line" id="L341">    <span class="tok-kw">try</span> htest.assertEqual(h4, out[<span class="tok-number">0</span>..]);</span>
<span class="line" id="L342"></span>
<span class="line" id="L343">    h = Blake2s224.init(.{ .context = [_]<span class="tok-type">u8</span>{<span class="tok-number">0x69</span>} ** <span class="tok-number">8</span>, .salt = [_]<span class="tok-type">u8</span>{<span class="tok-number">0x42</span>} ** <span class="tok-number">8</span> });</span>
<span class="line" id="L344">    h.update(<span class="tok-str">&quot;a&quot;</span> ** <span class="tok-number">32</span> ++ <span class="tok-str">&quot;b&quot;</span> ** <span class="tok-number">32</span>);</span>
<span class="line" id="L345">    h.final(out[<span class="tok-number">0</span>..]);</span>
<span class="line" id="L346">    <span class="tok-kw">try</span> htest.assertEqual(h4, out[<span class="tok-number">0</span>..]);</span>
<span class="line" id="L347">}</span>
<span class="line" id="L348"></span>
<span class="line" id="L349"><span class="tok-kw">test</span> <span class="tok-str">&quot;comptime blake2s224&quot;</span> {</span>
<span class="line" id="L350">    <span class="tok-kw">comptime</span> {</span>
<span class="line" id="L351">        <span class="tok-builtin">@setEvalBranchQuota</span>(<span class="tok-number">10000</span>);</span>
<span class="line" id="L352">        <span class="tok-kw">var</span> block = [_]<span class="tok-type">u8</span>{<span class="tok-number">0</span>} ** Blake2s224.block_length;</span>
<span class="line" id="L353">        <span class="tok-kw">var</span> out: [Blake2s224.digest_length]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L354"></span>
<span class="line" id="L355">        <span class="tok-kw">const</span> h1 = <span class="tok-str">&quot;86b7611563293f8c73627df7a6d6ba25ca0548c2a6481f7d116ee576&quot;</span>;</span>
<span class="line" id="L356"></span>
<span class="line" id="L357">        <span class="tok-kw">try</span> htest.assertEqualHash(Blake2s224, h1, block[<span class="tok-number">0</span>..]);</span>
<span class="line" id="L358"></span>
<span class="line" id="L359">        <span class="tok-kw">var</span> h = Blake2s224.init(.{});</span>
<span class="line" id="L360">        h.update(&amp;block);</span>
<span class="line" id="L361">        h.final(out[<span class="tok-number">0</span>..]);</span>
<span class="line" id="L362"></span>
<span class="line" id="L363">        <span class="tok-kw">try</span> htest.assertEqual(h1, out[<span class="tok-number">0</span>..]);</span>
<span class="line" id="L364">    }</span>
<span class="line" id="L365">}</span>
<span class="line" id="L366"></span>
<span class="line" id="L367"><span class="tok-kw">test</span> <span class="tok-str">&quot;blake2s256 single&quot;</span> {</span>
<span class="line" id="L368">    <span class="tok-kw">const</span> h1 = <span class="tok-str">&quot;69217a3079908094e11121d042354a7c1f55b6482ca1a51e1b250dfd1ed0eef9&quot;</span>;</span>
<span class="line" id="L369">    <span class="tok-kw">try</span> htest.assertEqualHash(Blake2s256, h1, <span class="tok-str">&quot;&quot;</span>);</span>
<span class="line" id="L370"></span>
<span class="line" id="L371">    <span class="tok-kw">const</span> h2 = <span class="tok-str">&quot;508c5e8c327c14e2e1a72ba34eeb452f37458b209ed63a294d999b4c86675982&quot;</span>;</span>
<span class="line" id="L372">    <span class="tok-kw">try</span> htest.assertEqualHash(Blake2s256, h2, <span class="tok-str">&quot;abc&quot;</span>);</span>
<span class="line" id="L373"></span>
<span class="line" id="L374">    <span class="tok-kw">const</span> h3 = <span class="tok-str">&quot;606beeec743ccbeff6cbcdf5d5302aa855c256c29b88c8ed331ea1a6bf3c8812&quot;</span>;</span>
<span class="line" id="L375">    <span class="tok-kw">try</span> htest.assertEqualHash(Blake2s256, h3, <span class="tok-str">&quot;The quick brown fox jumps over the lazy dog&quot;</span>);</span>
<span class="line" id="L376"></span>
<span class="line" id="L377">    <span class="tok-kw">const</span> h4 = <span class="tok-str">&quot;8d8711dade07a6b92b9a3ea1f40bee9b2c53ff3edd2a273dec170b0163568977&quot;</span>;</span>
<span class="line" id="L378">    <span class="tok-kw">try</span> htest.assertEqualHash(Blake2s256, h4, <span class="tok-str">&quot;a&quot;</span> ** <span class="tok-number">32</span> ++ <span class="tok-str">&quot;b&quot;</span> ** <span class="tok-number">32</span>);</span>
<span class="line" id="L379">}</span>
<span class="line" id="L380"></span>
<span class="line" id="L381"><span class="tok-kw">test</span> <span class="tok-str">&quot;blake2s256 streaming&quot;</span> {</span>
<span class="line" id="L382">    <span class="tok-kw">var</span> h = Blake2s256.init(.{});</span>
<span class="line" id="L383">    <span class="tok-kw">var</span> out: [<span class="tok-number">32</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L384"></span>
<span class="line" id="L385">    <span class="tok-kw">const</span> h1 = <span class="tok-str">&quot;69217a3079908094e11121d042354a7c1f55b6482ca1a51e1b250dfd1ed0eef9&quot;</span>;</span>
<span class="line" id="L386"></span>
<span class="line" id="L387">    h.final(out[<span class="tok-number">0</span>..]);</span>
<span class="line" id="L388">    <span class="tok-kw">try</span> htest.assertEqual(h1, out[<span class="tok-number">0</span>..]);</span>
<span class="line" id="L389"></span>
<span class="line" id="L390">    <span class="tok-kw">const</span> h2 = <span class="tok-str">&quot;508c5e8c327c14e2e1a72ba34eeb452f37458b209ed63a294d999b4c86675982&quot;</span>;</span>
<span class="line" id="L391"></span>
<span class="line" id="L392">    h = Blake2s256.init(.{});</span>
<span class="line" id="L393">    h.update(<span class="tok-str">&quot;abc&quot;</span>);</span>
<span class="line" id="L394">    h.final(out[<span class="tok-number">0</span>..]);</span>
<span class="line" id="L395">    <span class="tok-kw">try</span> htest.assertEqual(h2, out[<span class="tok-number">0</span>..]);</span>
<span class="line" id="L396"></span>
<span class="line" id="L397">    h = Blake2s256.init(.{});</span>
<span class="line" id="L398">    h.update(<span class="tok-str">&quot;a&quot;</span>);</span>
<span class="line" id="L399">    h.update(<span class="tok-str">&quot;b&quot;</span>);</span>
<span class="line" id="L400">    h.update(<span class="tok-str">&quot;c&quot;</span>);</span>
<span class="line" id="L401">    h.final(out[<span class="tok-number">0</span>..]);</span>
<span class="line" id="L402">    <span class="tok-kw">try</span> htest.assertEqual(h2, out[<span class="tok-number">0</span>..]);</span>
<span class="line" id="L403"></span>
<span class="line" id="L404">    <span class="tok-kw">const</span> h3 = <span class="tok-str">&quot;8d8711dade07a6b92b9a3ea1f40bee9b2c53ff3edd2a273dec170b0163568977&quot;</span>;</span>
<span class="line" id="L405"></span>
<span class="line" id="L406">    h = Blake2s256.init(.{});</span>
<span class="line" id="L407">    h.update(<span class="tok-str">&quot;a&quot;</span> ** <span class="tok-number">32</span>);</span>
<span class="line" id="L408">    h.update(<span class="tok-str">&quot;b&quot;</span> ** <span class="tok-number">32</span>);</span>
<span class="line" id="L409">    h.final(out[<span class="tok-number">0</span>..]);</span>
<span class="line" id="L410">    <span class="tok-kw">try</span> htest.assertEqual(h3, out[<span class="tok-number">0</span>..]);</span>
<span class="line" id="L411"></span>
<span class="line" id="L412">    h = Blake2s256.init(.{});</span>
<span class="line" id="L413">    h.update(<span class="tok-str">&quot;a&quot;</span> ** <span class="tok-number">32</span> ++ <span class="tok-str">&quot;b&quot;</span> ** <span class="tok-number">32</span>);</span>
<span class="line" id="L414">    h.final(out[<span class="tok-number">0</span>..]);</span>
<span class="line" id="L415">    <span class="tok-kw">try</span> htest.assertEqual(h3, out[<span class="tok-number">0</span>..]);</span>
<span class="line" id="L416">}</span>
<span class="line" id="L417"></span>
<span class="line" id="L418"><span class="tok-kw">test</span> <span class="tok-str">&quot;blake2s256 keyed&quot;</span> {</span>
<span class="line" id="L419">    <span class="tok-kw">var</span> out: [<span class="tok-number">32</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L420"></span>
<span class="line" id="L421">    <span class="tok-kw">const</span> h1 = <span class="tok-str">&quot;10f918da4d74fab3302e48a5d67d03804b1ec95372a62a0f33b7c9fa28ba1ae6&quot;</span>;</span>
<span class="line" id="L422">    <span class="tok-kw">const</span> key = <span class="tok-str">&quot;secret_key&quot;</span>;</span>
<span class="line" id="L423"></span>
<span class="line" id="L424">    Blake2s256.hash(<span class="tok-str">&quot;a&quot;</span> ** <span class="tok-number">64</span> ++ <span class="tok-str">&quot;b&quot;</span> ** <span class="tok-number">64</span>, &amp;out, .{ .key = key });</span>
<span class="line" id="L425">    <span class="tok-kw">try</span> htest.assertEqual(h1, out[<span class="tok-number">0</span>..]);</span>
<span class="line" id="L426"></span>
<span class="line" id="L427">    <span class="tok-kw">var</span> h = Blake2s256.init(.{ .key = key });</span>
<span class="line" id="L428">    h.update(<span class="tok-str">&quot;a&quot;</span> ** <span class="tok-number">64</span> ++ <span class="tok-str">&quot;b&quot;</span> ** <span class="tok-number">64</span>);</span>
<span class="line" id="L429">    h.final(out[<span class="tok-number">0</span>..]);</span>
<span class="line" id="L430"></span>
<span class="line" id="L431">    <span class="tok-kw">try</span> htest.assertEqual(h1, out[<span class="tok-number">0</span>..]);</span>
<span class="line" id="L432"></span>
<span class="line" id="L433">    h = Blake2s256.init(.{ .key = key });</span>
<span class="line" id="L434">    h.update(<span class="tok-str">&quot;a&quot;</span> ** <span class="tok-number">64</span>);</span>
<span class="line" id="L435">    h.update(<span class="tok-str">&quot;b&quot;</span> ** <span class="tok-number">64</span>);</span>
<span class="line" id="L436">    h.final(out[<span class="tok-number">0</span>..]);</span>
<span class="line" id="L437"></span>
<span class="line" id="L438">    <span class="tok-kw">try</span> htest.assertEqual(h1, out[<span class="tok-number">0</span>..]);</span>
<span class="line" id="L439">}</span>
<span class="line" id="L440"></span>
<span class="line" id="L441"><span class="tok-kw">test</span> <span class="tok-str">&quot;comptime blake2s256&quot;</span> {</span>
<span class="line" id="L442">    <span class="tok-kw">comptime</span> {</span>
<span class="line" id="L443">        <span class="tok-builtin">@setEvalBranchQuota</span>(<span class="tok-number">10000</span>);</span>
<span class="line" id="L444">        <span class="tok-kw">var</span> block = [_]<span class="tok-type">u8</span>{<span class="tok-number">0</span>} ** Blake2s256.block_length;</span>
<span class="line" id="L445">        <span class="tok-kw">var</span> out: [Blake2s256.digest_length]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L446"></span>
<span class="line" id="L447">        <span class="tok-kw">const</span> h1 = <span class="tok-str">&quot;ae09db7cd54f42b490ef09b6bc541af688e4959bb8c53f359a6f56e38ab454a3&quot;</span>;</span>
<span class="line" id="L448"></span>
<span class="line" id="L449">        <span class="tok-kw">try</span> htest.assertEqualHash(Blake2s256, h1, block[<span class="tok-number">0</span>..]);</span>
<span class="line" id="L450"></span>
<span class="line" id="L451">        <span class="tok-kw">var</span> h = Blake2s256.init(.{});</span>
<span class="line" id="L452">        h.update(&amp;block);</span>
<span class="line" id="L453">        h.final(out[<span class="tok-number">0</span>..]);</span>
<span class="line" id="L454"></span>
<span class="line" id="L455">        <span class="tok-kw">try</span> htest.assertEqual(h1, out[<span class="tok-number">0</span>..]);</span>
<span class="line" id="L456">    }</span>
<span class="line" id="L457">}</span>
<span class="line" id="L458"></span>
<span class="line" id="L459"><span class="tok-comment">/////////////////////</span>
</span>
<span class="line" id="L460"><span class="tok-comment">// Blake2b</span>
</span>
<span class="line" id="L461"></span>
<span class="line" id="L462"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> Blake2b128 = Blake2b(<span class="tok-number">128</span>);</span>
<span class="line" id="L463"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> Blake2b160 = Blake2b(<span class="tok-number">160</span>);</span>
<span class="line" id="L464"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> Blake2b256 = Blake2b(<span class="tok-number">256</span>);</span>
<span class="line" id="L465"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> Blake2b384 = Blake2b(<span class="tok-number">384</span>);</span>
<span class="line" id="L466"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> Blake2b512 = Blake2b(<span class="tok-number">512</span>);</span>
<span class="line" id="L467"></span>
<span class="line" id="L468"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">Blake2b</span>(<span class="tok-kw">comptime</span> out_bits: <span class="tok-type">usize</span>) <span class="tok-type">type</span> {</span>
<span class="line" id="L469">    <span class="tok-kw">return</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L470">        <span class="tok-kw">const</span> Self = <span class="tok-builtin">@This</span>();</span>
<span class="line" id="L471">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> block_length = <span class="tok-number">128</span>;</span>
<span class="line" id="L472">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> digest_length = out_bits / <span class="tok-number">8</span>;</span>
<span class="line" id="L473">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> key_length_min = <span class="tok-number">0</span>;</span>
<span class="line" id="L474">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> key_length_max = <span class="tok-number">64</span>;</span>
<span class="line" id="L475">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> key_length = <span class="tok-number">32</span>; <span class="tok-comment">// recommended key length</span>
</span>
<span class="line" id="L476">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> Options = <span class="tok-kw">struct</span> { key: ?[]<span class="tok-kw">const</span> <span class="tok-type">u8</span> = <span class="tok-null">null</span>, salt: ?[<span class="tok-number">16</span>]<span class="tok-type">u8</span> = <span class="tok-null">null</span>, context: ?[<span class="tok-number">16</span>]<span class="tok-type">u8</span> = <span class="tok-null">null</span>, expected_out_bits: <span class="tok-type">usize</span> = out_bits };</span>
<span class="line" id="L477"></span>
<span class="line" id="L478">        <span class="tok-kw">const</span> iv = [<span class="tok-number">8</span>]<span class="tok-type">u64</span>{</span>
<span class="line" id="L479">            <span class="tok-number">0x6a09e667f3bcc908</span>,</span>
<span class="line" id="L480">            <span class="tok-number">0xbb67ae8584caa73b</span>,</span>
<span class="line" id="L481">            <span class="tok-number">0x3c6ef372fe94f82b</span>,</span>
<span class="line" id="L482">            <span class="tok-number">0xa54ff53a5f1d36f1</span>,</span>
<span class="line" id="L483">            <span class="tok-number">0x510e527fade682d1</span>,</span>
<span class="line" id="L484">            <span class="tok-number">0x9b05688c2b3e6c1f</span>,</span>
<span class="line" id="L485">            <span class="tok-number">0x1f83d9abfb41bd6b</span>,</span>
<span class="line" id="L486">            <span class="tok-number">0x5be0cd19137e2179</span>,</span>
<span class="line" id="L487">        };</span>
<span class="line" id="L488"></span>
<span class="line" id="L489">        <span class="tok-kw">const</span> sigma = [<span class="tok-number">12</span>][<span class="tok-number">16</span>]<span class="tok-type">u8</span>{</span>
<span class="line" id="L490">            [_]<span class="tok-type">u8</span>{ <span class="tok-number">0</span>, <span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">4</span>, <span class="tok-number">5</span>, <span class="tok-number">6</span>, <span class="tok-number">7</span>, <span class="tok-number">8</span>, <span class="tok-number">9</span>, <span class="tok-number">10</span>, <span class="tok-number">11</span>, <span class="tok-number">12</span>, <span class="tok-number">13</span>, <span class="tok-number">14</span>, <span class="tok-number">15</span> },</span>
<span class="line" id="L491">            [_]<span class="tok-type">u8</span>{ <span class="tok-number">14</span>, <span class="tok-number">10</span>, <span class="tok-number">4</span>, <span class="tok-number">8</span>, <span class="tok-number">9</span>, <span class="tok-number">15</span>, <span class="tok-number">13</span>, <span class="tok-number">6</span>, <span class="tok-number">1</span>, <span class="tok-number">12</span>, <span class="tok-number">0</span>, <span class="tok-number">2</span>, <span class="tok-number">11</span>, <span class="tok-number">7</span>, <span class="tok-number">5</span>, <span class="tok-number">3</span> },</span>
<span class="line" id="L492">            [_]<span class="tok-type">u8</span>{ <span class="tok-number">11</span>, <span class="tok-number">8</span>, <span class="tok-number">12</span>, <span class="tok-number">0</span>, <span class="tok-number">5</span>, <span class="tok-number">2</span>, <span class="tok-number">15</span>, <span class="tok-number">13</span>, <span class="tok-number">10</span>, <span class="tok-number">14</span>, <span class="tok-number">3</span>, <span class="tok-number">6</span>, <span class="tok-number">7</span>, <span class="tok-number">1</span>, <span class="tok-number">9</span>, <span class="tok-number">4</span> },</span>
<span class="line" id="L493">            [_]<span class="tok-type">u8</span>{ <span class="tok-number">7</span>, <span class="tok-number">9</span>, <span class="tok-number">3</span>, <span class="tok-number">1</span>, <span class="tok-number">13</span>, <span class="tok-number">12</span>, <span class="tok-number">11</span>, <span class="tok-number">14</span>, <span class="tok-number">2</span>, <span class="tok-number">6</span>, <span class="tok-number">5</span>, <span class="tok-number">10</span>, <span class="tok-number">4</span>, <span class="tok-number">0</span>, <span class="tok-number">15</span>, <span class="tok-number">8</span> },</span>
<span class="line" id="L494">            [_]<span class="tok-type">u8</span>{ <span class="tok-number">9</span>, <span class="tok-number">0</span>, <span class="tok-number">5</span>, <span class="tok-number">7</span>, <span class="tok-number">2</span>, <span class="tok-number">4</span>, <span class="tok-number">10</span>, <span class="tok-number">15</span>, <span class="tok-number">14</span>, <span class="tok-number">1</span>, <span class="tok-number">11</span>, <span class="tok-number">12</span>, <span class="tok-number">6</span>, <span class="tok-number">8</span>, <span class="tok-number">3</span>, <span class="tok-number">13</span> },</span>
<span class="line" id="L495">            [_]<span class="tok-type">u8</span>{ <span class="tok-number">2</span>, <span class="tok-number">12</span>, <span class="tok-number">6</span>, <span class="tok-number">10</span>, <span class="tok-number">0</span>, <span class="tok-number">11</span>, <span class="tok-number">8</span>, <span class="tok-number">3</span>, <span class="tok-number">4</span>, <span class="tok-number">13</span>, <span class="tok-number">7</span>, <span class="tok-number">5</span>, <span class="tok-number">15</span>, <span class="tok-number">14</span>, <span class="tok-number">1</span>, <span class="tok-number">9</span> },</span>
<span class="line" id="L496">            [_]<span class="tok-type">u8</span>{ <span class="tok-number">12</span>, <span class="tok-number">5</span>, <span class="tok-number">1</span>, <span class="tok-number">15</span>, <span class="tok-number">14</span>, <span class="tok-number">13</span>, <span class="tok-number">4</span>, <span class="tok-number">10</span>, <span class="tok-number">0</span>, <span class="tok-number">7</span>, <span class="tok-number">6</span>, <span class="tok-number">3</span>, <span class="tok-number">9</span>, <span class="tok-number">2</span>, <span class="tok-number">8</span>, <span class="tok-number">11</span> },</span>
<span class="line" id="L497">            [_]<span class="tok-type">u8</span>{ <span class="tok-number">13</span>, <span class="tok-number">11</span>, <span class="tok-number">7</span>, <span class="tok-number">14</span>, <span class="tok-number">12</span>, <span class="tok-number">1</span>, <span class="tok-number">3</span>, <span class="tok-number">9</span>, <span class="tok-number">5</span>, <span class="tok-number">0</span>, <span class="tok-number">15</span>, <span class="tok-number">4</span>, <span class="tok-number">8</span>, <span class="tok-number">6</span>, <span class="tok-number">2</span>, <span class="tok-number">10</span> },</span>
<span class="line" id="L498">            [_]<span class="tok-type">u8</span>{ <span class="tok-number">6</span>, <span class="tok-number">15</span>, <span class="tok-number">14</span>, <span class="tok-number">9</span>, <span class="tok-number">11</span>, <span class="tok-number">3</span>, <span class="tok-number">0</span>, <span class="tok-number">8</span>, <span class="tok-number">12</span>, <span class="tok-number">2</span>, <span class="tok-number">13</span>, <span class="tok-number">7</span>, <span class="tok-number">1</span>, <span class="tok-number">4</span>, <span class="tok-number">10</span>, <span class="tok-number">5</span> },</span>
<span class="line" id="L499">            [_]<span class="tok-type">u8</span>{ <span class="tok-number">10</span>, <span class="tok-number">2</span>, <span class="tok-number">8</span>, <span class="tok-number">4</span>, <span class="tok-number">7</span>, <span class="tok-number">6</span>, <span class="tok-number">1</span>, <span class="tok-number">5</span>, <span class="tok-number">15</span>, <span class="tok-number">11</span>, <span class="tok-number">9</span>, <span class="tok-number">14</span>, <span class="tok-number">3</span>, <span class="tok-number">12</span>, <span class="tok-number">13</span>, <span class="tok-number">0</span> },</span>
<span class="line" id="L500">            [_]<span class="tok-type">u8</span>{ <span class="tok-number">0</span>, <span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">4</span>, <span class="tok-number">5</span>, <span class="tok-number">6</span>, <span class="tok-number">7</span>, <span class="tok-number">8</span>, <span class="tok-number">9</span>, <span class="tok-number">10</span>, <span class="tok-number">11</span>, <span class="tok-number">12</span>, <span class="tok-number">13</span>, <span class="tok-number">14</span>, <span class="tok-number">15</span> },</span>
<span class="line" id="L501">            [_]<span class="tok-type">u8</span>{ <span class="tok-number">14</span>, <span class="tok-number">10</span>, <span class="tok-number">4</span>, <span class="tok-number">8</span>, <span class="tok-number">9</span>, <span class="tok-number">15</span>, <span class="tok-number">13</span>, <span class="tok-number">6</span>, <span class="tok-number">1</span>, <span class="tok-number">12</span>, <span class="tok-number">0</span>, <span class="tok-number">2</span>, <span class="tok-number">11</span>, <span class="tok-number">7</span>, <span class="tok-number">5</span>, <span class="tok-number">3</span> },</span>
<span class="line" id="L502">        };</span>
<span class="line" id="L503"></span>
<span class="line" id="L504">        h: [<span class="tok-number">8</span>]<span class="tok-type">u64</span>,</span>
<span class="line" id="L505">        t: <span class="tok-type">u128</span>,</span>
<span class="line" id="L506">        <span class="tok-comment">// Streaming cache</span>
</span>
<span class="line" id="L507">        buf: [<span class="tok-number">128</span>]<span class="tok-type">u8</span>,</span>
<span class="line" id="L508">        buf_len: <span class="tok-type">u8</span>,</span>
<span class="line" id="L509"></span>
<span class="line" id="L510">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">init</span>(options: Options) Self {</span>
<span class="line" id="L511">            <span class="tok-kw">comptime</span> debug.assert(<span class="tok-number">8</span> &lt;= out_bits <span class="tok-kw">and</span> out_bits &lt;= <span class="tok-number">512</span>);</span>
<span class="line" id="L512"></span>
<span class="line" id="L513">            <span class="tok-kw">var</span> d: Self = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L514">            mem.copy(<span class="tok-type">u64</span>, d.h[<span class="tok-number">0</span>..], iv[<span class="tok-number">0</span>..]);</span>
<span class="line" id="L515"></span>
<span class="line" id="L516">            <span class="tok-kw">const</span> key_len = <span class="tok-kw">if</span> (options.key) |key| key.len <span class="tok-kw">else</span> <span class="tok-number">0</span>;</span>
<span class="line" id="L517">            <span class="tok-comment">// default parameters</span>
</span>
<span class="line" id="L518">            d.h[<span class="tok-number">0</span>] ^= <span class="tok-number">0x01010000</span> ^ (key_len &lt;&lt; <span class="tok-number">8</span>) ^ (options.expected_out_bits &gt;&gt; <span class="tok-number">3</span>);</span>
<span class="line" id="L519">            d.t = <span class="tok-number">0</span>;</span>
<span class="line" id="L520">            d.buf_len = <span class="tok-number">0</span>;</span>
<span class="line" id="L521"></span>
<span class="line" id="L522">            <span class="tok-kw">if</span> (options.salt) |salt| {</span>
<span class="line" id="L523">                d.h[<span class="tok-number">4</span>] ^= mem.readIntLittle(<span class="tok-type">u64</span>, salt[<span class="tok-number">0</span>..<span class="tok-number">8</span>]);</span>
<span class="line" id="L524">                d.h[<span class="tok-number">5</span>] ^= mem.readIntLittle(<span class="tok-type">u64</span>, salt[<span class="tok-number">8</span>..<span class="tok-number">16</span>]);</span>
<span class="line" id="L525">            }</span>
<span class="line" id="L526">            <span class="tok-kw">if</span> (options.context) |context| {</span>
<span class="line" id="L527">                d.h[<span class="tok-number">6</span>] ^= mem.readIntLittle(<span class="tok-type">u64</span>, context[<span class="tok-number">0</span>..<span class="tok-number">8</span>]);</span>
<span class="line" id="L528">                d.h[<span class="tok-number">7</span>] ^= mem.readIntLittle(<span class="tok-type">u64</span>, context[<span class="tok-number">8</span>..<span class="tok-number">16</span>]);</span>
<span class="line" id="L529">            }</span>
<span class="line" id="L530">            <span class="tok-kw">if</span> (key_len &gt; <span class="tok-number">0</span>) {</span>
<span class="line" id="L531">                mem.set(<span class="tok-type">u8</span>, d.buf[key_len..], <span class="tok-number">0</span>);</span>
<span class="line" id="L532">                d.update(options.key.?);</span>
<span class="line" id="L533">                d.buf_len = <span class="tok-number">128</span>;</span>
<span class="line" id="L534">            }</span>
<span class="line" id="L535">            <span class="tok-kw">return</span> d;</span>
<span class="line" id="L536">        }</span>
<span class="line" id="L537"></span>
<span class="line" id="L538">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">hash</span>(b: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, out: *[digest_length]<span class="tok-type">u8</span>, options: Options) <span class="tok-type">void</span> {</span>
<span class="line" id="L539">            <span class="tok-kw">var</span> d = Self.init(options);</span>
<span class="line" id="L540">            d.update(b);</span>
<span class="line" id="L541">            d.final(out);</span>
<span class="line" id="L542">        }</span>
<span class="line" id="L543"></span>
<span class="line" id="L544">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">update</span>(d: *Self, b: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L545">            <span class="tok-kw">var</span> off: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L546"></span>
<span class="line" id="L547">            <span class="tok-comment">// Partial buffer exists from previous update. Copy into buffer then hash.</span>
</span>
<span class="line" id="L548">            <span class="tok-kw">if</span> (d.buf_len != <span class="tok-number">0</span> <span class="tok-kw">and</span> d.buf_len + b.len &gt; <span class="tok-number">128</span>) {</span>
<span class="line" id="L549">                off += <span class="tok-number">128</span> - d.buf_len;</span>
<span class="line" id="L550">                mem.copy(<span class="tok-type">u8</span>, d.buf[d.buf_len..], b[<span class="tok-number">0</span>..off]);</span>
<span class="line" id="L551">                d.t += <span class="tok-number">128</span>;</span>
<span class="line" id="L552">                d.round(d.buf[<span class="tok-number">0</span>..], <span class="tok-null">false</span>);</span>
<span class="line" id="L553">                d.buf_len = <span class="tok-number">0</span>;</span>
<span class="line" id="L554">            }</span>
<span class="line" id="L555"></span>
<span class="line" id="L556">            <span class="tok-comment">// Full middle blocks.</span>
</span>
<span class="line" id="L557">            <span class="tok-kw">while</span> (off + <span class="tok-number">128</span> &lt; b.len) : (off += <span class="tok-number">128</span>) {</span>
<span class="line" id="L558">                d.t += <span class="tok-number">128</span>;</span>
<span class="line" id="L559">                d.round(b[off..][<span class="tok-number">0</span>..<span class="tok-number">128</span>], <span class="tok-null">false</span>);</span>
<span class="line" id="L560">            }</span>
<span class="line" id="L561"></span>
<span class="line" id="L562">            <span class="tok-comment">// Copy any remainder for next pass.</span>
</span>
<span class="line" id="L563">            mem.copy(<span class="tok-type">u8</span>, d.buf[d.buf_len..], b[off..]);</span>
<span class="line" id="L564">            d.buf_len += <span class="tok-builtin">@intCast</span>(<span class="tok-type">u8</span>, b[off..].len);</span>
<span class="line" id="L565">        }</span>
<span class="line" id="L566"></span>
<span class="line" id="L567">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">final</span>(d: *Self, out: *[digest_length]<span class="tok-type">u8</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L568">            mem.set(<span class="tok-type">u8</span>, d.buf[d.buf_len..], <span class="tok-number">0</span>);</span>
<span class="line" id="L569">            d.t += d.buf_len;</span>
<span class="line" id="L570">            d.round(d.buf[<span class="tok-number">0</span>..], <span class="tok-null">true</span>);</span>
<span class="line" id="L571">            <span class="tok-kw">for</span> (d.h) |*x| x.* = mem.nativeToLittle(<span class="tok-type">u64</span>, x.*);</span>
<span class="line" id="L572">            mem.copy(<span class="tok-type">u8</span>, out[<span class="tok-number">0</span>..], <span class="tok-builtin">@ptrCast</span>(*[digest_length]<span class="tok-type">u8</span>, &amp;d.h));</span>
<span class="line" id="L573">        }</span>
<span class="line" id="L574"></span>
<span class="line" id="L575">        <span class="tok-kw">fn</span> <span class="tok-fn">round</span>(d: *Self, b: *<span class="tok-kw">const</span> [<span class="tok-number">128</span>]<span class="tok-type">u8</span>, last: <span class="tok-type">bool</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L576">            <span class="tok-kw">var</span> m: [<span class="tok-number">16</span>]<span class="tok-type">u64</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L577">            <span class="tok-kw">var</span> v: [<span class="tok-number">16</span>]<span class="tok-type">u64</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L578"></span>
<span class="line" id="L579">            <span class="tok-kw">for</span> (m) |*r, i| {</span>
<span class="line" id="L580">                r.* = mem.readIntLittle(<span class="tok-type">u64</span>, b[<span class="tok-number">8</span> * i ..][<span class="tok-number">0</span>..<span class="tok-number">8</span>]);</span>
<span class="line" id="L581">            }</span>
<span class="line" id="L582"></span>
<span class="line" id="L583">            <span class="tok-kw">var</span> k: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L584">            <span class="tok-kw">while</span> (k &lt; <span class="tok-number">8</span>) : (k += <span class="tok-number">1</span>) {</span>
<span class="line" id="L585">                v[k] = d.h[k];</span>
<span class="line" id="L586">                v[k + <span class="tok-number">8</span>] = iv[k];</span>
<span class="line" id="L587">            }</span>
<span class="line" id="L588"></span>
<span class="line" id="L589">            v[<span class="tok-number">12</span>] ^= <span class="tok-builtin">@truncate</span>(<span class="tok-type">u64</span>, d.t);</span>
<span class="line" id="L590">            v[<span class="tok-number">13</span>] ^= <span class="tok-builtin">@intCast</span>(<span class="tok-type">u64</span>, d.t &gt;&gt; <span class="tok-number">64</span>);</span>
<span class="line" id="L591">            <span class="tok-kw">if</span> (last) v[<span class="tok-number">14</span>] = ~v[<span class="tok-number">14</span>];</span>
<span class="line" id="L592"></span>
<span class="line" id="L593">            <span class="tok-kw">const</span> rounds = <span class="tok-kw">comptime</span> [_]RoundParam{</span>
<span class="line" id="L594">                roundParam(<span class="tok-number">0</span>, <span class="tok-number">4</span>, <span class="tok-number">8</span>, <span class="tok-number">12</span>, <span class="tok-number">0</span>, <span class="tok-number">1</span>),</span>
<span class="line" id="L595">                roundParam(<span class="tok-number">1</span>, <span class="tok-number">5</span>, <span class="tok-number">9</span>, <span class="tok-number">13</span>, <span class="tok-number">2</span>, <span class="tok-number">3</span>),</span>
<span class="line" id="L596">                roundParam(<span class="tok-number">2</span>, <span class="tok-number">6</span>, <span class="tok-number">10</span>, <span class="tok-number">14</span>, <span class="tok-number">4</span>, <span class="tok-number">5</span>),</span>
<span class="line" id="L597">                roundParam(<span class="tok-number">3</span>, <span class="tok-number">7</span>, <span class="tok-number">11</span>, <span class="tok-number">15</span>, <span class="tok-number">6</span>, <span class="tok-number">7</span>),</span>
<span class="line" id="L598">                roundParam(<span class="tok-number">0</span>, <span class="tok-number">5</span>, <span class="tok-number">10</span>, <span class="tok-number">15</span>, <span class="tok-number">8</span>, <span class="tok-number">9</span>),</span>
<span class="line" id="L599">                roundParam(<span class="tok-number">1</span>, <span class="tok-number">6</span>, <span class="tok-number">11</span>, <span class="tok-number">12</span>, <span class="tok-number">10</span>, <span class="tok-number">11</span>),</span>
<span class="line" id="L600">                roundParam(<span class="tok-number">2</span>, <span class="tok-number">7</span>, <span class="tok-number">8</span>, <span class="tok-number">13</span>, <span class="tok-number">12</span>, <span class="tok-number">13</span>),</span>
<span class="line" id="L601">                roundParam(<span class="tok-number">3</span>, <span class="tok-number">4</span>, <span class="tok-number">9</span>, <span class="tok-number">14</span>, <span class="tok-number">14</span>, <span class="tok-number">15</span>),</span>
<span class="line" id="L602">            };</span>
<span class="line" id="L603"></span>
<span class="line" id="L604">            <span class="tok-kw">comptime</span> <span class="tok-kw">var</span> j: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L605">            <span class="tok-kw">inline</span> <span class="tok-kw">while</span> (j &lt; <span class="tok-number">12</span>) : (j += <span class="tok-number">1</span>) {</span>
<span class="line" id="L606">                <span class="tok-kw">inline</span> <span class="tok-kw">for</span> (rounds) |r| {</span>
<span class="line" id="L607">                    v[r.a] = v[r.a] +% v[r.b] +% m[sigma[j][r.x]];</span>
<span class="line" id="L608">                    v[r.d] = math.rotr(<span class="tok-type">u64</span>, v[r.d] ^ v[r.a], <span class="tok-builtin">@as</span>(<span class="tok-type">usize</span>, <span class="tok-number">32</span>));</span>
<span class="line" id="L609">                    v[r.c] = v[r.c] +% v[r.d];</span>
<span class="line" id="L610">                    v[r.b] = math.rotr(<span class="tok-type">u64</span>, v[r.b] ^ v[r.c], <span class="tok-builtin">@as</span>(<span class="tok-type">usize</span>, <span class="tok-number">24</span>));</span>
<span class="line" id="L611">                    v[r.a] = v[r.a] +% v[r.b] +% m[sigma[j][r.y]];</span>
<span class="line" id="L612">                    v[r.d] = math.rotr(<span class="tok-type">u64</span>, v[r.d] ^ v[r.a], <span class="tok-builtin">@as</span>(<span class="tok-type">usize</span>, <span class="tok-number">16</span>));</span>
<span class="line" id="L613">                    v[r.c] = v[r.c] +% v[r.d];</span>
<span class="line" id="L614">                    v[r.b] = math.rotr(<span class="tok-type">u64</span>, v[r.b] ^ v[r.c], <span class="tok-builtin">@as</span>(<span class="tok-type">usize</span>, <span class="tok-number">63</span>));</span>
<span class="line" id="L615">                }</span>
<span class="line" id="L616">            }</span>
<span class="line" id="L617"></span>
<span class="line" id="L618">            <span class="tok-kw">for</span> (d.h) |*r, i| {</span>
<span class="line" id="L619">                r.* ^= v[i] ^ v[i + <span class="tok-number">8</span>];</span>
<span class="line" id="L620">            }</span>
<span class="line" id="L621">        }</span>
<span class="line" id="L622">    };</span>
<span class="line" id="L623">}</span>
<span class="line" id="L624"></span>
<span class="line" id="L625"><span class="tok-kw">test</span> <span class="tok-str">&quot;blake2b160 single&quot;</span> {</span>
<span class="line" id="L626">    <span class="tok-kw">const</span> h1 = <span class="tok-str">&quot;3345524abf6bbe1809449224b5972c41790b6cf2&quot;</span>;</span>
<span class="line" id="L627">    <span class="tok-kw">try</span> htest.assertEqualHash(Blake2b160, h1, <span class="tok-str">&quot;&quot;</span>);</span>
<span class="line" id="L628"></span>
<span class="line" id="L629">    <span class="tok-kw">const</span> h2 = <span class="tok-str">&quot;384264f676f39536840523f284921cdc68b6846b&quot;</span>;</span>
<span class="line" id="L630">    <span class="tok-kw">try</span> htest.assertEqualHash(Blake2b160, h2, <span class="tok-str">&quot;abc&quot;</span>);</span>
<span class="line" id="L631"></span>
<span class="line" id="L632">    <span class="tok-kw">const</span> h3 = <span class="tok-str">&quot;3c523ed102ab45a37d54f5610d5a983162fde84f&quot;</span>;</span>
<span class="line" id="L633">    <span class="tok-kw">try</span> htest.assertEqualHash(Blake2b160, h3, <span class="tok-str">&quot;The quick brown fox jumps over the lazy dog&quot;</span>);</span>
<span class="line" id="L634"></span>
<span class="line" id="L635">    <span class="tok-kw">const</span> h4 = <span class="tok-str">&quot;43758f5de1740f651f1ae39de92260fe8bd5a11f&quot;</span>;</span>
<span class="line" id="L636">    <span class="tok-kw">try</span> htest.assertEqualHash(Blake2b160, h4, <span class="tok-str">&quot;a&quot;</span> ** <span class="tok-number">64</span> ++ <span class="tok-str">&quot;b&quot;</span> ** <span class="tok-number">64</span>);</span>
<span class="line" id="L637">}</span>
<span class="line" id="L638"></span>
<span class="line" id="L639"><span class="tok-kw">test</span> <span class="tok-str">&quot;blake2b160 streaming&quot;</span> {</span>
<span class="line" id="L640">    <span class="tok-kw">var</span> h = Blake2b160.init(.{});</span>
<span class="line" id="L641">    <span class="tok-kw">var</span> out: [<span class="tok-number">20</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L642"></span>
<span class="line" id="L643">    <span class="tok-kw">const</span> h1 = <span class="tok-str">&quot;3345524abf6bbe1809449224b5972c41790b6cf2&quot;</span>;</span>
<span class="line" id="L644"></span>
<span class="line" id="L645">    h.final(out[<span class="tok-number">0</span>..]);</span>
<span class="line" id="L646">    <span class="tok-kw">try</span> htest.assertEqual(h1, out[<span class="tok-number">0</span>..]);</span>
<span class="line" id="L647"></span>
<span class="line" id="L648">    <span class="tok-kw">const</span> h2 = <span class="tok-str">&quot;384264f676f39536840523f284921cdc68b6846b&quot;</span>;</span>
<span class="line" id="L649"></span>
<span class="line" id="L650">    h = Blake2b160.init(.{});</span>
<span class="line" id="L651">    h.update(<span class="tok-str">&quot;abc&quot;</span>);</span>
<span class="line" id="L652">    h.final(out[<span class="tok-number">0</span>..]);</span>
<span class="line" id="L653">    <span class="tok-kw">try</span> htest.assertEqual(h2, out[<span class="tok-number">0</span>..]);</span>
<span class="line" id="L654"></span>
<span class="line" id="L655">    h = Blake2b160.init(.{});</span>
<span class="line" id="L656">    h.update(<span class="tok-str">&quot;a&quot;</span>);</span>
<span class="line" id="L657">    h.update(<span class="tok-str">&quot;b&quot;</span>);</span>
<span class="line" id="L658">    h.update(<span class="tok-str">&quot;c&quot;</span>);</span>
<span class="line" id="L659">    h.final(out[<span class="tok-number">0</span>..]);</span>
<span class="line" id="L660">    <span class="tok-kw">try</span> htest.assertEqual(h2, out[<span class="tok-number">0</span>..]);</span>
<span class="line" id="L661"></span>
<span class="line" id="L662">    <span class="tok-kw">const</span> h3 = <span class="tok-str">&quot;43758f5de1740f651f1ae39de92260fe8bd5a11f&quot;</span>;</span>
<span class="line" id="L663"></span>
<span class="line" id="L664">    h = Blake2b160.init(.{});</span>
<span class="line" id="L665">    h.update(<span class="tok-str">&quot;a&quot;</span> ** <span class="tok-number">64</span> ++ <span class="tok-str">&quot;b&quot;</span> ** <span class="tok-number">64</span>);</span>
<span class="line" id="L666">    h.final(out[<span class="tok-number">0</span>..]);</span>
<span class="line" id="L667">    <span class="tok-kw">try</span> htest.assertEqual(h3, out[<span class="tok-number">0</span>..]);</span>
<span class="line" id="L668"></span>
<span class="line" id="L669">    h = Blake2b160.init(.{});</span>
<span class="line" id="L670">    h.update(<span class="tok-str">&quot;a&quot;</span> ** <span class="tok-number">64</span>);</span>
<span class="line" id="L671">    h.update(<span class="tok-str">&quot;b&quot;</span> ** <span class="tok-number">64</span>);</span>
<span class="line" id="L672">    h.final(out[<span class="tok-number">0</span>..]);</span>
<span class="line" id="L673">    <span class="tok-kw">try</span> htest.assertEqual(h3, out[<span class="tok-number">0</span>..]);</span>
<span class="line" id="L674"></span>
<span class="line" id="L675">    h = Blake2b160.init(.{});</span>
<span class="line" id="L676">    h.update(<span class="tok-str">&quot;a&quot;</span> ** <span class="tok-number">64</span>);</span>
<span class="line" id="L677">    h.update(<span class="tok-str">&quot;b&quot;</span> ** <span class="tok-number">64</span>);</span>
<span class="line" id="L678">    h.final(out[<span class="tok-number">0</span>..]);</span>
<span class="line" id="L679">    <span class="tok-kw">try</span> htest.assertEqual(h3, out[<span class="tok-number">0</span>..]);</span>
<span class="line" id="L680"></span>
<span class="line" id="L681">    <span class="tok-kw">const</span> h4 = <span class="tok-str">&quot;72328f8a8200663752fc302d372b5dd9b49dd8dc&quot;</span>;</span>
<span class="line" id="L682"></span>
<span class="line" id="L683">    h = Blake2b160.init(.{ .context = [_]<span class="tok-type">u8</span>{<span class="tok-number">0x69</span>} ** <span class="tok-number">16</span>, .salt = [_]<span class="tok-type">u8</span>{<span class="tok-number">0x42</span>} ** <span class="tok-number">16</span> });</span>
<span class="line" id="L684">    h.update(<span class="tok-str">&quot;a&quot;</span> ** <span class="tok-number">64</span>);</span>
<span class="line" id="L685">    h.update(<span class="tok-str">&quot;b&quot;</span> ** <span class="tok-number">64</span>);</span>
<span class="line" id="L686">    h.final(out[<span class="tok-number">0</span>..]);</span>
<span class="line" id="L687">    <span class="tok-kw">try</span> htest.assertEqual(h4, out[<span class="tok-number">0</span>..]);</span>
<span class="line" id="L688"></span>
<span class="line" id="L689">    h = Blake2b160.init(.{ .context = [_]<span class="tok-type">u8</span>{<span class="tok-number">0x69</span>} ** <span class="tok-number">16</span>, .salt = [_]<span class="tok-type">u8</span>{<span class="tok-number">0x42</span>} ** <span class="tok-number">16</span> });</span>
<span class="line" id="L690">    h.update(<span class="tok-str">&quot;a&quot;</span> ** <span class="tok-number">64</span>);</span>
<span class="line" id="L691">    h.update(<span class="tok-str">&quot;b&quot;</span> ** <span class="tok-number">64</span>);</span>
<span class="line" id="L692">    h.final(out[<span class="tok-number">0</span>..]);</span>
<span class="line" id="L693">    <span class="tok-kw">try</span> htest.assertEqual(h4, out[<span class="tok-number">0</span>..]);</span>
<span class="line" id="L694">}</span>
<span class="line" id="L695"></span>
<span class="line" id="L696"><span class="tok-kw">test</span> <span class="tok-str">&quot;comptime blake2b160&quot;</span> {</span>
<span class="line" id="L697">    <span class="tok-kw">comptime</span> {</span>
<span class="line" id="L698">        <span class="tok-builtin">@setEvalBranchQuota</span>(<span class="tok-number">10000</span>);</span>
<span class="line" id="L699">        <span class="tok-kw">var</span> block = [_]<span class="tok-type">u8</span>{<span class="tok-number">0</span>} ** Blake2b160.block_length;</span>
<span class="line" id="L700">        <span class="tok-kw">var</span> out: [Blake2b160.digest_length]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L701"></span>
<span class="line" id="L702">        <span class="tok-kw">const</span> h1 = <span class="tok-str">&quot;8d26f158f564e3293b42f5e3d34263cb173aa9c9&quot;</span>;</span>
<span class="line" id="L703"></span>
<span class="line" id="L704">        <span class="tok-kw">try</span> htest.assertEqualHash(Blake2b160, h1, block[<span class="tok-number">0</span>..]);</span>
<span class="line" id="L705"></span>
<span class="line" id="L706">        <span class="tok-kw">var</span> h = Blake2b160.init(.{});</span>
<span class="line" id="L707">        h.update(&amp;block);</span>
<span class="line" id="L708">        h.final(out[<span class="tok-number">0</span>..]);</span>
<span class="line" id="L709"></span>
<span class="line" id="L710">        <span class="tok-kw">try</span> htest.assertEqual(h1, out[<span class="tok-number">0</span>..]);</span>
<span class="line" id="L711">    }</span>
<span class="line" id="L712">}</span>
<span class="line" id="L713"></span>
<span class="line" id="L714"><span class="tok-kw">test</span> <span class="tok-str">&quot;blake2b384 single&quot;</span> {</span>
<span class="line" id="L715">    <span class="tok-kw">const</span> h1 = <span class="tok-str">&quot;b32811423377f52d7862286ee1a72ee540524380fda1724a6f25d7978c6fd3244a6caf0498812673c5e05ef583825100&quot;</span>;</span>
<span class="line" id="L716">    <span class="tok-kw">try</span> htest.assertEqualHash(Blake2b384, h1, <span class="tok-str">&quot;&quot;</span>);</span>
<span class="line" id="L717"></span>
<span class="line" id="L718">    <span class="tok-kw">const</span> h2 = <span class="tok-str">&quot;6f56a82c8e7ef526dfe182eb5212f7db9df1317e57815dbda46083fc30f54ee6c66ba83be64b302d7cba6ce15bb556f4&quot;</span>;</span>
<span class="line" id="L719">    <span class="tok-kw">try</span> htest.assertEqualHash(Blake2b384, h2, <span class="tok-str">&quot;abc&quot;</span>);</span>
<span class="line" id="L720"></span>
<span class="line" id="L721">    <span class="tok-kw">const</span> h3 = <span class="tok-str">&quot;b7c81b228b6bd912930e8f0b5387989691c1cee1e65aade4da3b86a3c9f678fc8018f6ed9e2906720c8d2a3aeda9c03d&quot;</span>;</span>
<span class="line" id="L722">    <span class="tok-kw">try</span> htest.assertEqualHash(Blake2b384, h3, <span class="tok-str">&quot;The quick brown fox jumps over the lazy dog&quot;</span>);</span>
<span class="line" id="L723"></span>
<span class="line" id="L724">    <span class="tok-kw">const</span> h4 = <span class="tok-str">&quot;b7283f0172fecbbd7eca32ce10d8a6c06b453cb3cf675b33eb4246f0da2bb94a6c0bdd6eec0b5fd71ec4fd51be80bf4c&quot;</span>;</span>
<span class="line" id="L725">    <span class="tok-kw">try</span> htest.assertEqualHash(Blake2b384, h4, <span class="tok-str">&quot;a&quot;</span> ** <span class="tok-number">64</span> ++ <span class="tok-str">&quot;b&quot;</span> ** <span class="tok-number">64</span>);</span>
<span class="line" id="L726">}</span>
<span class="line" id="L727"></span>
<span class="line" id="L728"><span class="tok-kw">test</span> <span class="tok-str">&quot;blake2b384 streaming&quot;</span> {</span>
<span class="line" id="L729">    <span class="tok-kw">var</span> h = Blake2b384.init(.{});</span>
<span class="line" id="L730">    <span class="tok-kw">var</span> out: [<span class="tok-number">48</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L731"></span>
<span class="line" id="L732">    <span class="tok-kw">const</span> h1 = <span class="tok-str">&quot;b32811423377f52d7862286ee1a72ee540524380fda1724a6f25d7978c6fd3244a6caf0498812673c5e05ef583825100&quot;</span>;</span>
<span class="line" id="L733"></span>
<span class="line" id="L734">    h.final(out[<span class="tok-number">0</span>..]);</span>
<span class="line" id="L735">    <span class="tok-kw">try</span> htest.assertEqual(h1, out[<span class="tok-number">0</span>..]);</span>
<span class="line" id="L736"></span>
<span class="line" id="L737">    <span class="tok-kw">const</span> h2 = <span class="tok-str">&quot;6f56a82c8e7ef526dfe182eb5212f7db9df1317e57815dbda46083fc30f54ee6c66ba83be64b302d7cba6ce15bb556f4&quot;</span>;</span>
<span class="line" id="L738"></span>
<span class="line" id="L739">    h = Blake2b384.init(.{});</span>
<span class="line" id="L740">    h.update(<span class="tok-str">&quot;abc&quot;</span>);</span>
<span class="line" id="L741">    h.final(out[<span class="tok-number">0</span>..]);</span>
<span class="line" id="L742">    <span class="tok-kw">try</span> htest.assertEqual(h2, out[<span class="tok-number">0</span>..]);</span>
<span class="line" id="L743"></span>
<span class="line" id="L744">    h = Blake2b384.init(.{});</span>
<span class="line" id="L745">    h.update(<span class="tok-str">&quot;a&quot;</span>);</span>
<span class="line" id="L746">    h.update(<span class="tok-str">&quot;b&quot;</span>);</span>
<span class="line" id="L747">    h.update(<span class="tok-str">&quot;c&quot;</span>);</span>
<span class="line" id="L748">    h.final(out[<span class="tok-number">0</span>..]);</span>
<span class="line" id="L749">    <span class="tok-kw">try</span> htest.assertEqual(h2, out[<span class="tok-number">0</span>..]);</span>
<span class="line" id="L750"></span>
<span class="line" id="L751">    <span class="tok-kw">const</span> h3 = <span class="tok-str">&quot;b7283f0172fecbbd7eca32ce10d8a6c06b453cb3cf675b33eb4246f0da2bb94a6c0bdd6eec0b5fd71ec4fd51be80bf4c&quot;</span>;</span>
<span class="line" id="L752"></span>
<span class="line" id="L753">    h = Blake2b384.init(.{});</span>
<span class="line" id="L754">    h.update(<span class="tok-str">&quot;a&quot;</span> ** <span class="tok-number">64</span> ++ <span class="tok-str">&quot;b&quot;</span> ** <span class="tok-number">64</span>);</span>
<span class="line" id="L755">    h.final(out[<span class="tok-number">0</span>..]);</span>
<span class="line" id="L756">    <span class="tok-kw">try</span> htest.assertEqual(h3, out[<span class="tok-number">0</span>..]);</span>
<span class="line" id="L757"></span>
<span class="line" id="L758">    h = Blake2b384.init(.{});</span>
<span class="line" id="L759">    h.update(<span class="tok-str">&quot;a&quot;</span> ** <span class="tok-number">64</span>);</span>
<span class="line" id="L760">    h.update(<span class="tok-str">&quot;b&quot;</span> ** <span class="tok-number">64</span>);</span>
<span class="line" id="L761">    h.final(out[<span class="tok-number">0</span>..]);</span>
<span class="line" id="L762">    <span class="tok-kw">try</span> htest.assertEqual(h3, out[<span class="tok-number">0</span>..]);</span>
<span class="line" id="L763"></span>
<span class="line" id="L764">    h = Blake2b384.init(.{});</span>
<span class="line" id="L765">    h.update(<span class="tok-str">&quot;a&quot;</span> ** <span class="tok-number">64</span>);</span>
<span class="line" id="L766">    h.update(<span class="tok-str">&quot;b&quot;</span> ** <span class="tok-number">64</span>);</span>
<span class="line" id="L767">    h.final(out[<span class="tok-number">0</span>..]);</span>
<span class="line" id="L768">    <span class="tok-kw">try</span> htest.assertEqual(h3, out[<span class="tok-number">0</span>..]);</span>
<span class="line" id="L769"></span>
<span class="line" id="L770">    <span class="tok-kw">const</span> h4 = <span class="tok-str">&quot;934c48fcb197031c71f583d92f98703510805e72142e0b46f5752d1e971bc86c355d556035613ff7a4154b4de09dac5c&quot;</span>;</span>
<span class="line" id="L771"></span>
<span class="line" id="L772">    h = Blake2b384.init(.{ .context = [_]<span class="tok-type">u8</span>{<span class="tok-number">0x69</span>} ** <span class="tok-number">16</span>, .salt = [_]<span class="tok-type">u8</span>{<span class="tok-number">0x42</span>} ** <span class="tok-number">16</span> });</span>
<span class="line" id="L773">    h.update(<span class="tok-str">&quot;a&quot;</span> ** <span class="tok-number">64</span>);</span>
<span class="line" id="L774">    h.update(<span class="tok-str">&quot;b&quot;</span> ** <span class="tok-number">64</span>);</span>
<span class="line" id="L775">    h.final(out[<span class="tok-number">0</span>..]);</span>
<span class="line" id="L776">    <span class="tok-kw">try</span> htest.assertEqual(h4, out[<span class="tok-number">0</span>..]);</span>
<span class="line" id="L777"></span>
<span class="line" id="L778">    h = Blake2b384.init(.{ .context = [_]<span class="tok-type">u8</span>{<span class="tok-number">0x69</span>} ** <span class="tok-number">16</span>, .salt = [_]<span class="tok-type">u8</span>{<span class="tok-number">0x42</span>} ** <span class="tok-number">16</span> });</span>
<span class="line" id="L779">    h.update(<span class="tok-str">&quot;a&quot;</span> ** <span class="tok-number">64</span>);</span>
<span class="line" id="L780">    h.update(<span class="tok-str">&quot;b&quot;</span> ** <span class="tok-number">64</span>);</span>
<span class="line" id="L781">    h.final(out[<span class="tok-number">0</span>..]);</span>
<span class="line" id="L782">    <span class="tok-kw">try</span> htest.assertEqual(h4, out[<span class="tok-number">0</span>..]);</span>
<span class="line" id="L783">}</span>
<span class="line" id="L784"></span>
<span class="line" id="L785"><span class="tok-kw">test</span> <span class="tok-str">&quot;comptime blake2b384&quot;</span> {</span>
<span class="line" id="L786">    <span class="tok-kw">comptime</span> {</span>
<span class="line" id="L787">        <span class="tok-builtin">@setEvalBranchQuota</span>(<span class="tok-number">10000</span>);</span>
<span class="line" id="L788">        <span class="tok-kw">var</span> block = [_]<span class="tok-type">u8</span>{<span class="tok-number">0</span>} ** Blake2b384.block_length;</span>
<span class="line" id="L789">        <span class="tok-kw">var</span> out: [Blake2b384.digest_length]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L790"></span>
<span class="line" id="L791">        <span class="tok-kw">const</span> h1 = <span class="tok-str">&quot;e8aa1931ea0422e4446fecdd25c16cf35c240b10cb4659dd5c776eddcaa4d922397a589404b46eb2e53d78132d05fd7d&quot;</span>;</span>
<span class="line" id="L792"></span>
<span class="line" id="L793">        <span class="tok-kw">try</span> htest.assertEqualHash(Blake2b384, h1, block[<span class="tok-number">0</span>..]);</span>
<span class="line" id="L794"></span>
<span class="line" id="L795">        <span class="tok-kw">var</span> h = Blake2b384.init(.{});</span>
<span class="line" id="L796">        h.update(&amp;block);</span>
<span class="line" id="L797">        h.final(out[<span class="tok-number">0</span>..]);</span>
<span class="line" id="L798"></span>
<span class="line" id="L799">        <span class="tok-kw">try</span> htest.assertEqual(h1, out[<span class="tok-number">0</span>..]);</span>
<span class="line" id="L800">    }</span>
<span class="line" id="L801">}</span>
<span class="line" id="L802"></span>
<span class="line" id="L803"><span class="tok-kw">test</span> <span class="tok-str">&quot;blake2b512 single&quot;</span> {</span>
<span class="line" id="L804">    <span class="tok-kw">const</span> h1 = <span class="tok-str">&quot;786a02f742015903c6c6fd852552d272912f4740e15847618a86e217f71f5419d25e1031afee585313896444934eb04b903a685b1448b755d56f701afe9be2ce&quot;</span>;</span>
<span class="line" id="L805">    <span class="tok-kw">try</span> htest.assertEqualHash(Blake2b512, h1, <span class="tok-str">&quot;&quot;</span>);</span>
<span class="line" id="L806"></span>
<span class="line" id="L807">    <span class="tok-kw">const</span> h2 = <span class="tok-str">&quot;ba80a53f981c4d0d6a2797b69f12f6e94c212f14685ac4b74b12bb6fdbffa2d17d87c5392aab792dc252d5de4533cc9518d38aa8dbf1925ab92386edd4009923&quot;</span>;</span>
<span class="line" id="L808">    <span class="tok-kw">try</span> htest.assertEqualHash(Blake2b512, h2, <span class="tok-str">&quot;abc&quot;</span>);</span>
<span class="line" id="L809"></span>
<span class="line" id="L810">    <span class="tok-kw">const</span> h3 = <span class="tok-str">&quot;a8add4bdddfd93e4877d2746e62817b116364a1fa7bc148d95090bc7333b3673f82401cf7aa2e4cb1ecd90296e3f14cb5413f8ed77be73045b13914cdcd6a918&quot;</span>;</span>
<span class="line" id="L811">    <span class="tok-kw">try</span> htest.assertEqualHash(Blake2b512, h3, <span class="tok-str">&quot;The quick brown fox jumps over the lazy dog&quot;</span>);</span>
<span class="line" id="L812"></span>
<span class="line" id="L813">    <span class="tok-kw">const</span> h4 = <span class="tok-str">&quot;049980af04d6a2cf16b4b49793c3ed7e40732073788806f2c989ebe9547bda0541d63abe298ec8955d08af48ae731f2e8a0bd6d201655a5473b4aa79d211b920&quot;</span>;</span>
<span class="line" id="L814">    <span class="tok-kw">try</span> htest.assertEqualHash(Blake2b512, h4, <span class="tok-str">&quot;a&quot;</span> ** <span class="tok-number">64</span> ++ <span class="tok-str">&quot;b&quot;</span> ** <span class="tok-number">64</span>);</span>
<span class="line" id="L815">}</span>
<span class="line" id="L816"></span>
<span class="line" id="L817"><span class="tok-kw">test</span> <span class="tok-str">&quot;blake2b512 streaming&quot;</span> {</span>
<span class="line" id="L818">    <span class="tok-kw">var</span> h = Blake2b512.init(.{});</span>
<span class="line" id="L819">    <span class="tok-kw">var</span> out: [<span class="tok-number">64</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L820"></span>
<span class="line" id="L821">    <span class="tok-kw">const</span> h1 = <span class="tok-str">&quot;786a02f742015903c6c6fd852552d272912f4740e15847618a86e217f71f5419d25e1031afee585313896444934eb04b903a685b1448b755d56f701afe9be2ce&quot;</span>;</span>
<span class="line" id="L822"></span>
<span class="line" id="L823">    h.final(out[<span class="tok-number">0</span>..]);</span>
<span class="line" id="L824">    <span class="tok-kw">try</span> htest.assertEqual(h1, out[<span class="tok-number">0</span>..]);</span>
<span class="line" id="L825"></span>
<span class="line" id="L826">    <span class="tok-kw">const</span> h2 = <span class="tok-str">&quot;ba80a53f981c4d0d6a2797b69f12f6e94c212f14685ac4b74b12bb6fdbffa2d17d87c5392aab792dc252d5de4533cc9518d38aa8dbf1925ab92386edd4009923&quot;</span>;</span>
<span class="line" id="L827"></span>
<span class="line" id="L828">    h = Blake2b512.init(.{});</span>
<span class="line" id="L829">    h.update(<span class="tok-str">&quot;abc&quot;</span>);</span>
<span class="line" id="L830">    h.final(out[<span class="tok-number">0</span>..]);</span>
<span class="line" id="L831">    <span class="tok-kw">try</span> htest.assertEqual(h2, out[<span class="tok-number">0</span>..]);</span>
<span class="line" id="L832"></span>
<span class="line" id="L833">    h = Blake2b512.init(.{});</span>
<span class="line" id="L834">    h.update(<span class="tok-str">&quot;a&quot;</span>);</span>
<span class="line" id="L835">    h.update(<span class="tok-str">&quot;b&quot;</span>);</span>
<span class="line" id="L836">    h.update(<span class="tok-str">&quot;c&quot;</span>);</span>
<span class="line" id="L837">    h.final(out[<span class="tok-number">0</span>..]);</span>
<span class="line" id="L838">    <span class="tok-kw">try</span> htest.assertEqual(h2, out[<span class="tok-number">0</span>..]);</span>
<span class="line" id="L839"></span>
<span class="line" id="L840">    <span class="tok-kw">const</span> h3 = <span class="tok-str">&quot;049980af04d6a2cf16b4b49793c3ed7e40732073788806f2c989ebe9547bda0541d63abe298ec8955d08af48ae731f2e8a0bd6d201655a5473b4aa79d211b920&quot;</span>;</span>
<span class="line" id="L841"></span>
<span class="line" id="L842">    h = Blake2b512.init(.{});</span>
<span class="line" id="L843">    h.update(<span class="tok-str">&quot;a&quot;</span> ** <span class="tok-number">64</span> ++ <span class="tok-str">&quot;b&quot;</span> ** <span class="tok-number">64</span>);</span>
<span class="line" id="L844">    h.final(out[<span class="tok-number">0</span>..]);</span>
<span class="line" id="L845">    <span class="tok-kw">try</span> htest.assertEqual(h3, out[<span class="tok-number">0</span>..]);</span>
<span class="line" id="L846"></span>
<span class="line" id="L847">    h = Blake2b512.init(.{});</span>
<span class="line" id="L848">    h.update(<span class="tok-str">&quot;a&quot;</span> ** <span class="tok-number">64</span>);</span>
<span class="line" id="L849">    h.update(<span class="tok-str">&quot;b&quot;</span> ** <span class="tok-number">64</span>);</span>
<span class="line" id="L850">    h.final(out[<span class="tok-number">0</span>..]);</span>
<span class="line" id="L851">    <span class="tok-kw">try</span> htest.assertEqual(h3, out[<span class="tok-number">0</span>..]);</span>
<span class="line" id="L852">}</span>
<span class="line" id="L853"></span>
<span class="line" id="L854"><span class="tok-kw">test</span> <span class="tok-str">&quot;blake2b512 keyed&quot;</span> {</span>
<span class="line" id="L855">    <span class="tok-kw">var</span> out: [<span class="tok-number">64</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L856"></span>
<span class="line" id="L857">    <span class="tok-kw">const</span> h1 = <span class="tok-str">&quot;8a978060ccaf582f388f37454363071ac9a67e3a704585fd879fb8a419a447e389c7c6de790faa20a7a7dccf197de736bc5b40b98a930b36df5bee7555750c4d&quot;</span>;</span>
<span class="line" id="L858">    <span class="tok-kw">const</span> key = <span class="tok-str">&quot;secret_key&quot;</span>;</span>
<span class="line" id="L859"></span>
<span class="line" id="L860">    Blake2b512.hash(<span class="tok-str">&quot;a&quot;</span> ** <span class="tok-number">64</span> ++ <span class="tok-str">&quot;b&quot;</span> ** <span class="tok-number">64</span>, &amp;out, .{ .key = key });</span>
<span class="line" id="L861">    <span class="tok-kw">try</span> htest.assertEqual(h1, out[<span class="tok-number">0</span>..]);</span>
<span class="line" id="L862"></span>
<span class="line" id="L863">    <span class="tok-kw">var</span> h = Blake2b512.init(.{ .key = key });</span>
<span class="line" id="L864">    h.update(<span class="tok-str">&quot;a&quot;</span> ** <span class="tok-number">64</span> ++ <span class="tok-str">&quot;b&quot;</span> ** <span class="tok-number">64</span>);</span>
<span class="line" id="L865">    h.final(out[<span class="tok-number">0</span>..]);</span>
<span class="line" id="L866"></span>
<span class="line" id="L867">    <span class="tok-kw">try</span> htest.assertEqual(h1, out[<span class="tok-number">0</span>..]);</span>
<span class="line" id="L868"></span>
<span class="line" id="L869">    h = Blake2b512.init(.{ .key = key });</span>
<span class="line" id="L870">    h.update(<span class="tok-str">&quot;a&quot;</span> ** <span class="tok-number">64</span>);</span>
<span class="line" id="L871">    h.update(<span class="tok-str">&quot;b&quot;</span> ** <span class="tok-number">64</span>);</span>
<span class="line" id="L872">    h.final(out[<span class="tok-number">0</span>..]);</span>
<span class="line" id="L873"></span>
<span class="line" id="L874">    <span class="tok-kw">try</span> htest.assertEqual(h1, out[<span class="tok-number">0</span>..]);</span>
<span class="line" id="L875">}</span>
<span class="line" id="L876"></span>
<span class="line" id="L877"><span class="tok-kw">test</span> <span class="tok-str">&quot;comptime blake2b512&quot;</span> {</span>
<span class="line" id="L878">    <span class="tok-kw">comptime</span> {</span>
<span class="line" id="L879">        <span class="tok-builtin">@setEvalBranchQuota</span>(<span class="tok-number">10000</span>);</span>
<span class="line" id="L880">        <span class="tok-kw">var</span> block = [_]<span class="tok-type">u8</span>{<span class="tok-number">0</span>} ** Blake2b512.block_length;</span>
<span class="line" id="L881">        <span class="tok-kw">var</span> out: [Blake2b512.digest_length]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L882"></span>
<span class="line" id="L883">        <span class="tok-kw">const</span> h1 = <span class="tok-str">&quot;865939e120e6805438478841afb739ae4250cf372653078a065cdcfffca4caf798e6d462b65d658fc165782640eded70963449ae1500fb0f24981d7727e22c41&quot;</span>;</span>
<span class="line" id="L884"></span>
<span class="line" id="L885">        <span class="tok-kw">try</span> htest.assertEqualHash(Blake2b512, h1, block[<span class="tok-number">0</span>..]);</span>
<span class="line" id="L886"></span>
<span class="line" id="L887">        <span class="tok-kw">var</span> h = Blake2b512.init(.{});</span>
<span class="line" id="L888">        h.update(&amp;block);</span>
<span class="line" id="L889">        h.final(out[<span class="tok-number">0</span>..]);</span>
<span class="line" id="L890"></span>
<span class="line" id="L891">        <span class="tok-kw">try</span> htest.assertEqual(h1, out[<span class="tok-number">0</span>..]);</span>
<span class="line" id="L892">    }</span>
<span class="line" id="L893">}</span>
<span class="line" id="L894"></span>
</code></pre></body>
</html>