<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">    <title>crypto/scrypt.zig - source view</title>
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
<pre><code><span class="line" id="L1"><span class="tok-comment">// https://tools.ietf.org/html/rfc7914</span>
</span>
<span class="line" id="L2"><span class="tok-comment">// https://github.com/golang/crypto/blob/master/scrypt/scrypt.go</span>
</span>
<span class="line" id="L3"><span class="tok-comment">// https://github.com/Tarsnap/scrypt</span>
</span>
<span class="line" id="L4"></span>
<span class="line" id="L5"><span class="tok-kw">const</span> std = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;std&quot;</span>);</span>
<span class="line" id="L6"><span class="tok-kw">const</span> crypto = std.crypto;</span>
<span class="line" id="L7"><span class="tok-kw">const</span> fmt = std.fmt;</span>
<span class="line" id="L8"><span class="tok-kw">const</span> io = std.io;</span>
<span class="line" id="L9"><span class="tok-kw">const</span> math = std.math;</span>
<span class="line" id="L10"><span class="tok-kw">const</span> mem = std.mem;</span>
<span class="line" id="L11"><span class="tok-kw">const</span> meta = std.meta;</span>
<span class="line" id="L12"><span class="tok-kw">const</span> pwhash = crypto.pwhash;</span>
<span class="line" id="L13"></span>
<span class="line" id="L14"><span class="tok-kw">const</span> phc_format = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;phc_encoding.zig&quot;</span>);</span>
<span class="line" id="L15"></span>
<span class="line" id="L16"><span class="tok-kw">const</span> HmacSha256 = crypto.auth.hmac.sha2.HmacSha256;</span>
<span class="line" id="L17"><span class="tok-kw">const</span> KdfError = pwhash.KdfError;</span>
<span class="line" id="L18"><span class="tok-kw">const</span> HasherError = pwhash.HasherError;</span>
<span class="line" id="L19"><span class="tok-kw">const</span> EncodingError = phc_format.Error;</span>
<span class="line" id="L20"><span class="tok-kw">const</span> Error = pwhash.Error;</span>
<span class="line" id="L21"></span>
<span class="line" id="L22"><span class="tok-kw">const</span> max_size = math.maxInt(<span class="tok-type">usize</span>);</span>
<span class="line" id="L23"><span class="tok-kw">const</span> max_int = max_size &gt;&gt; <span class="tok-number">1</span>;</span>
<span class="line" id="L24"><span class="tok-kw">const</span> default_salt_len = <span class="tok-number">32</span>;</span>
<span class="line" id="L25"><span class="tok-kw">const</span> default_hash_len = <span class="tok-number">32</span>;</span>
<span class="line" id="L26"><span class="tok-kw">const</span> max_salt_len = <span class="tok-number">64</span>;</span>
<span class="line" id="L27"><span class="tok-kw">const</span> max_hash_len = <span class="tok-number">64</span>;</span>
<span class="line" id="L28"></span>
<span class="line" id="L29"><span class="tok-kw">fn</span> <span class="tok-fn">blockCopy</span>(dst: []<span class="tok-kw">align</span>(<span class="tok-number">16</span>) <span class="tok-type">u32</span>, src: []<span class="tok-kw">align</span>(<span class="tok-number">16</span>) <span class="tok-kw">const</span> <span class="tok-type">u32</span>, n: <span class="tok-type">usize</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L30">    mem.copy(<span class="tok-type">u32</span>, dst, src[<span class="tok-number">0</span> .. n * <span class="tok-number">16</span>]);</span>
<span class="line" id="L31">}</span>
<span class="line" id="L32"></span>
<span class="line" id="L33"><span class="tok-kw">fn</span> <span class="tok-fn">blockXor</span>(dst: []<span class="tok-kw">align</span>(<span class="tok-number">16</span>) <span class="tok-type">u32</span>, src: []<span class="tok-kw">align</span>(<span class="tok-number">16</span>) <span class="tok-kw">const</span> <span class="tok-type">u32</span>, n: <span class="tok-type">usize</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L34">    <span class="tok-kw">for</span> (src[<span class="tok-number">0</span> .. n * <span class="tok-number">16</span>]) |v, i| {</span>
<span class="line" id="L35">        dst[i] ^= v;</span>
<span class="line" id="L36">    }</span>
<span class="line" id="L37">}</span>
<span class="line" id="L38"></span>
<span class="line" id="L39"><span class="tok-kw">const</span> QuarterRound = <span class="tok-kw">struct</span> { a: <span class="tok-type">usize</span>, b: <span class="tok-type">usize</span>, c: <span class="tok-type">usize</span>, d: <span class="tok-type">u6</span> };</span>
<span class="line" id="L40"></span>
<span class="line" id="L41"><span class="tok-kw">fn</span> <span class="tok-fn">Rp</span>(a: <span class="tok-type">usize</span>, b: <span class="tok-type">usize</span>, c: <span class="tok-type">usize</span>, d: <span class="tok-type">u6</span>) QuarterRound {</span>
<span class="line" id="L42">    <span class="tok-kw">return</span> QuarterRound{ .a = a, .b = b, .c = c, .d = d };</span>
<span class="line" id="L43">}</span>
<span class="line" id="L44"></span>
<span class="line" id="L45"><span class="tok-kw">fn</span> <span class="tok-fn">salsa8core</span>(b: *<span class="tok-kw">align</span>(<span class="tok-number">16</span>) [<span class="tok-number">16</span>]<span class="tok-type">u32</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L46">    <span class="tok-kw">const</span> arx_steps = <span class="tok-kw">comptime</span> [_]QuarterRound{</span>
<span class="line" id="L47">        Rp(<span class="tok-number">4</span>, <span class="tok-number">0</span>, <span class="tok-number">12</span>, <span class="tok-number">7</span>),   Rp(<span class="tok-number">8</span>, <span class="tok-number">4</span>, <span class="tok-number">0</span>, <span class="tok-number">9</span>),    Rp(<span class="tok-number">12</span>, <span class="tok-number">8</span>, <span class="tok-number">4</span>, <span class="tok-number">13</span>),   Rp(<span class="tok-number">0</span>, <span class="tok-number">12</span>, <span class="tok-number">8</span>, <span class="tok-number">18</span>),</span>
<span class="line" id="L48">        Rp(<span class="tok-number">9</span>, <span class="tok-number">5</span>, <span class="tok-number">1</span>, <span class="tok-number">7</span>),    Rp(<span class="tok-number">13</span>, <span class="tok-number">9</span>, <span class="tok-number">5</span>, <span class="tok-number">9</span>),   Rp(<span class="tok-number">1</span>, <span class="tok-number">13</span>, <span class="tok-number">9</span>, <span class="tok-number">13</span>),   Rp(<span class="tok-number">5</span>, <span class="tok-number">1</span>, <span class="tok-number">13</span>, <span class="tok-number">18</span>),</span>
<span class="line" id="L49">        Rp(<span class="tok-number">14</span>, <span class="tok-number">10</span>, <span class="tok-number">6</span>, <span class="tok-number">7</span>),  Rp(<span class="tok-number">2</span>, <span class="tok-number">14</span>, <span class="tok-number">10</span>, <span class="tok-number">9</span>),  Rp(<span class="tok-number">6</span>, <span class="tok-number">2</span>, <span class="tok-number">14</span>, <span class="tok-number">13</span>),   Rp(<span class="tok-number">10</span>, <span class="tok-number">6</span>, <span class="tok-number">2</span>, <span class="tok-number">18</span>),</span>
<span class="line" id="L50">        Rp(<span class="tok-number">3</span>, <span class="tok-number">15</span>, <span class="tok-number">11</span>, <span class="tok-number">7</span>),  Rp(<span class="tok-number">7</span>, <span class="tok-number">3</span>, <span class="tok-number">15</span>, <span class="tok-number">9</span>),   Rp(<span class="tok-number">11</span>, <span class="tok-number">7</span>, <span class="tok-number">3</span>, <span class="tok-number">13</span>),   Rp(<span class="tok-number">15</span>, <span class="tok-number">11</span>, <span class="tok-number">7</span>, <span class="tok-number">18</span>),</span>
<span class="line" id="L51">        Rp(<span class="tok-number">1</span>, <span class="tok-number">0</span>, <span class="tok-number">3</span>, <span class="tok-number">7</span>),    Rp(<span class="tok-number">2</span>, <span class="tok-number">1</span>, <span class="tok-number">0</span>, <span class="tok-number">9</span>),    Rp(<span class="tok-number">3</span>, <span class="tok-number">2</span>, <span class="tok-number">1</span>, <span class="tok-number">13</span>),    Rp(<span class="tok-number">0</span>, <span class="tok-number">3</span>, <span class="tok-number">2</span>, <span class="tok-number">18</span>),</span>
<span class="line" id="L52">        Rp(<span class="tok-number">6</span>, <span class="tok-number">5</span>, <span class="tok-number">4</span>, <span class="tok-number">7</span>),    Rp(<span class="tok-number">7</span>, <span class="tok-number">6</span>, <span class="tok-number">5</span>, <span class="tok-number">9</span>),    Rp(<span class="tok-number">4</span>, <span class="tok-number">7</span>, <span class="tok-number">6</span>, <span class="tok-number">13</span>),    Rp(<span class="tok-number">5</span>, <span class="tok-number">4</span>, <span class="tok-number">7</span>, <span class="tok-number">18</span>),</span>
<span class="line" id="L53">        Rp(<span class="tok-number">11</span>, <span class="tok-number">10</span>, <span class="tok-number">9</span>, <span class="tok-number">7</span>),  Rp(<span class="tok-number">8</span>, <span class="tok-number">11</span>, <span class="tok-number">10</span>, <span class="tok-number">9</span>),  Rp(<span class="tok-number">9</span>, <span class="tok-number">8</span>, <span class="tok-number">11</span>, <span class="tok-number">13</span>),   Rp(<span class="tok-number">10</span>, <span class="tok-number">9</span>, <span class="tok-number">8</span>, <span class="tok-number">18</span>),</span>
<span class="line" id="L54">        Rp(<span class="tok-number">12</span>, <span class="tok-number">15</span>, <span class="tok-number">14</span>, <span class="tok-number">7</span>), Rp(<span class="tok-number">13</span>, <span class="tok-number">12</span>, <span class="tok-number">15</span>, <span class="tok-number">9</span>), Rp(<span class="tok-number">14</span>, <span class="tok-number">13</span>, <span class="tok-number">12</span>, <span class="tok-number">13</span>), Rp(<span class="tok-number">15</span>, <span class="tok-number">14</span>, <span class="tok-number">13</span>, <span class="tok-number">18</span>),</span>
<span class="line" id="L55">    };</span>
<span class="line" id="L56">    <span class="tok-kw">var</span> x = b.*;</span>
<span class="line" id="L57">    <span class="tok-kw">var</span> j: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L58">    <span class="tok-kw">while</span> (j &lt; <span class="tok-number">8</span>) : (j += <span class="tok-number">2</span>) {</span>
<span class="line" id="L59">        <span class="tok-kw">inline</span> <span class="tok-kw">for</span> (arx_steps) |r| {</span>
<span class="line" id="L60">            x[r.a] ^= math.rotl(<span class="tok-type">u32</span>, x[r.b] +% x[r.c], r.d);</span>
<span class="line" id="L61">        }</span>
<span class="line" id="L62">    }</span>
<span class="line" id="L63">    j = <span class="tok-number">0</span>;</span>
<span class="line" id="L64">    <span class="tok-kw">while</span> (j &lt; <span class="tok-number">16</span>) : (j += <span class="tok-number">1</span>) {</span>
<span class="line" id="L65">        b[j] +%= x[j];</span>
<span class="line" id="L66">    }</span>
<span class="line" id="L67">}</span>
<span class="line" id="L68"></span>
<span class="line" id="L69"><span class="tok-kw">fn</span> <span class="tok-fn">salsaXor</span>(tmp: *<span class="tok-kw">align</span>(<span class="tok-number">16</span>) [<span class="tok-number">16</span>]<span class="tok-type">u32</span>, in: []<span class="tok-kw">align</span>(<span class="tok-number">16</span>) <span class="tok-kw">const</span> <span class="tok-type">u32</span>, out: []<span class="tok-kw">align</span>(<span class="tok-number">16</span>) <span class="tok-type">u32</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L70">    blockXor(tmp, in, <span class="tok-number">1</span>);</span>
<span class="line" id="L71">    salsa8core(tmp);</span>
<span class="line" id="L72">    blockCopy(out, tmp, <span class="tok-number">1</span>);</span>
<span class="line" id="L73">}</span>
<span class="line" id="L74"></span>
<span class="line" id="L75"><span class="tok-kw">fn</span> <span class="tok-fn">blockMix</span>(tmp: *<span class="tok-kw">align</span>(<span class="tok-number">16</span>) [<span class="tok-number">16</span>]<span class="tok-type">u32</span>, in: []<span class="tok-kw">align</span>(<span class="tok-number">16</span>) <span class="tok-kw">const</span> <span class="tok-type">u32</span>, out: []<span class="tok-kw">align</span>(<span class="tok-number">16</span>) <span class="tok-type">u32</span>, r: <span class="tok-type">u30</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L76">    blockCopy(tmp, <span class="tok-builtin">@alignCast</span>(<span class="tok-number">16</span>, in[(<span class="tok-number">2</span> * r - <span class="tok-number">1</span>) * <span class="tok-number">16</span> ..]), <span class="tok-number">1</span>);</span>
<span class="line" id="L77">    <span class="tok-kw">var</span> i: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L78">    <span class="tok-kw">while</span> (i &lt; <span class="tok-number">2</span> * r) : (i += <span class="tok-number">2</span>) {</span>
<span class="line" id="L79">        salsaXor(tmp, <span class="tok-builtin">@alignCast</span>(<span class="tok-number">16</span>, in[i * <span class="tok-number">16</span> ..]), <span class="tok-builtin">@alignCast</span>(<span class="tok-number">16</span>, out[i * <span class="tok-number">8</span> ..]));</span>
<span class="line" id="L80">        salsaXor(tmp, <span class="tok-builtin">@alignCast</span>(<span class="tok-number">16</span>, in[i * <span class="tok-number">16</span> + <span class="tok-number">16</span> ..]), <span class="tok-builtin">@alignCast</span>(<span class="tok-number">16</span>, out[i * <span class="tok-number">8</span> + r * <span class="tok-number">16</span> ..]));</span>
<span class="line" id="L81">    }</span>
<span class="line" id="L82">}</span>
<span class="line" id="L83"></span>
<span class="line" id="L84"><span class="tok-kw">fn</span> <span class="tok-fn">integerify</span>(b: []<span class="tok-kw">align</span>(<span class="tok-number">16</span>) <span class="tok-kw">const</span> <span class="tok-type">u32</span>, r: <span class="tok-type">u30</span>) <span class="tok-type">u64</span> {</span>
<span class="line" id="L85">    <span class="tok-kw">const</span> j = (<span class="tok-number">2</span> * r - <span class="tok-number">1</span>) * <span class="tok-number">16</span>;</span>
<span class="line" id="L86">    <span class="tok-kw">return</span> <span class="tok-builtin">@as</span>(<span class="tok-type">u64</span>, b[j]) | <span class="tok-builtin">@as</span>(<span class="tok-type">u64</span>, b[j + <span class="tok-number">1</span>]) &lt;&lt; <span class="tok-number">32</span>;</span>
<span class="line" id="L87">}</span>
<span class="line" id="L88"></span>
<span class="line" id="L89"><span class="tok-kw">fn</span> <span class="tok-fn">smix</span>(b: []<span class="tok-kw">align</span>(<span class="tok-number">16</span>) <span class="tok-type">u8</span>, r: <span class="tok-type">u30</span>, n: <span class="tok-type">usize</span>, v: []<span class="tok-kw">align</span>(<span class="tok-number">16</span>) <span class="tok-type">u32</span>, xy: []<span class="tok-kw">align</span>(<span class="tok-number">16</span>) <span class="tok-type">u32</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L90">    <span class="tok-kw">var</span> x = <span class="tok-builtin">@alignCast</span>(<span class="tok-number">16</span>, xy[<span class="tok-number">0</span> .. <span class="tok-number">32</span> * r]);</span>
<span class="line" id="L91">    <span class="tok-kw">var</span> y = <span class="tok-builtin">@alignCast</span>(<span class="tok-number">16</span>, xy[<span class="tok-number">32</span> * r ..]);</span>
<span class="line" id="L92"></span>
<span class="line" id="L93">    <span class="tok-kw">for</span> (x) |*v1, j| {</span>
<span class="line" id="L94">        v1.* = mem.readIntSliceLittle(<span class="tok-type">u32</span>, b[<span class="tok-number">4</span> * j ..]);</span>
<span class="line" id="L95">    }</span>
<span class="line" id="L96"></span>
<span class="line" id="L97">    <span class="tok-kw">var</span> tmp: [<span class="tok-number">16</span>]<span class="tok-type">u32</span> <span class="tok-kw">align</span>(<span class="tok-number">16</span>) = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L98">    <span class="tok-kw">var</span> i: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L99">    <span class="tok-kw">while</span> (i &lt; n) : (i += <span class="tok-number">2</span>) {</span>
<span class="line" id="L100">        blockCopy(<span class="tok-builtin">@alignCast</span>(<span class="tok-number">16</span>, v[i * (<span class="tok-number">32</span> * r) ..]), x, <span class="tok-number">2</span> * r);</span>
<span class="line" id="L101">        blockMix(&amp;tmp, x, y, r);</span>
<span class="line" id="L102"></span>
<span class="line" id="L103">        blockCopy(<span class="tok-builtin">@alignCast</span>(<span class="tok-number">16</span>, v[(i + <span class="tok-number">1</span>) * (<span class="tok-number">32</span> * r) ..]), y, <span class="tok-number">2</span> * r);</span>
<span class="line" id="L104">        blockMix(&amp;tmp, y, x, r);</span>
<span class="line" id="L105">    }</span>
<span class="line" id="L106"></span>
<span class="line" id="L107">    i = <span class="tok-number">0</span>;</span>
<span class="line" id="L108">    <span class="tok-kw">while</span> (i &lt; n) : (i += <span class="tok-number">2</span>) {</span>
<span class="line" id="L109">        <span class="tok-kw">var</span> j = <span class="tok-builtin">@intCast</span>(<span class="tok-type">usize</span>, integerify(x, r) &amp; (n - <span class="tok-number">1</span>));</span>
<span class="line" id="L110">        blockXor(x, <span class="tok-builtin">@alignCast</span>(<span class="tok-number">16</span>, v[j * (<span class="tok-number">32</span> * r) ..]), <span class="tok-number">2</span> * r);</span>
<span class="line" id="L111">        blockMix(&amp;tmp, x, y, r);</span>
<span class="line" id="L112"></span>
<span class="line" id="L113">        j = <span class="tok-builtin">@intCast</span>(<span class="tok-type">usize</span>, integerify(y, r) &amp; (n - <span class="tok-number">1</span>));</span>
<span class="line" id="L114">        blockXor(y, <span class="tok-builtin">@alignCast</span>(<span class="tok-number">16</span>, v[j * (<span class="tok-number">32</span> * r) ..]), <span class="tok-number">2</span> * r);</span>
<span class="line" id="L115">        blockMix(&amp;tmp, y, x, r);</span>
<span class="line" id="L116">    }</span>
<span class="line" id="L117"></span>
<span class="line" id="L118">    <span class="tok-kw">for</span> (x) |v1, j| {</span>
<span class="line" id="L119">        mem.writeIntLittle(<span class="tok-type">u32</span>, b[<span class="tok-number">4</span> * j ..][<span class="tok-number">0</span>..<span class="tok-number">4</span>], v1);</span>
<span class="line" id="L120">    }</span>
<span class="line" id="L121">}</span>
<span class="line" id="L122"></span>
<span class="line" id="L123"><span class="tok-comment">/// Scrypt parameters</span></span>
<span class="line" id="L124"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> Params = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L125">    <span class="tok-kw">const</span> Self = <span class="tok-builtin">@This</span>();</span>
<span class="line" id="L126"></span>
<span class="line" id="L127">    <span class="tok-comment">/// The CPU/Memory cost parameter [ln] is log2(N).</span></span>
<span class="line" id="L128">    ln: <span class="tok-type">u6</span>,</span>
<span class="line" id="L129"></span>
<span class="line" id="L130">    <span class="tok-comment">/// The [r]esource usage parameter specifies the block size.</span></span>
<span class="line" id="L131">    r: <span class="tok-type">u30</span>,</span>
<span class="line" id="L132"></span>
<span class="line" id="L133">    <span class="tok-comment">/// The [p]arallelization parameter.</span></span>
<span class="line" id="L134">    <span class="tok-comment">/// A large value of [p] can be used to increase the computational cost of scrypt without</span></span>
<span class="line" id="L135">    <span class="tok-comment">/// increasing the memory usage.</span></span>
<span class="line" id="L136">    p: <span class="tok-type">u30</span>,</span>
<span class="line" id="L137"></span>
<span class="line" id="L138">    <span class="tok-comment">/// Baseline parameters for interactive logins</span></span>
<span class="line" id="L139">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> interactive = Self.fromLimits(<span class="tok-number">524288</span>, <span class="tok-number">16777216</span>);</span>
<span class="line" id="L140"></span>
<span class="line" id="L141">    <span class="tok-comment">/// Baseline parameters for offline usage</span></span>
<span class="line" id="L142">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> sensitive = Self.fromLimits(<span class="tok-number">33554432</span>, <span class="tok-number">1073741824</span>);</span>
<span class="line" id="L143"></span>
<span class="line" id="L144">    <span class="tok-comment">/// Create parameters from ops and mem limits, where mem_limit given in bytes</span></span>
<span class="line" id="L145">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">fromLimits</span>(ops_limit: <span class="tok-type">u64</span>, mem_limit: <span class="tok-type">usize</span>) Self {</span>
<span class="line" id="L146">        <span class="tok-kw">const</span> ops = math.max(<span class="tok-number">32768</span>, ops_limit);</span>
<span class="line" id="L147">        <span class="tok-kw">const</span> r: <span class="tok-type">u30</span> = <span class="tok-number">8</span>;</span>
<span class="line" id="L148">        <span class="tok-kw">if</span> (ops &lt; mem_limit / <span class="tok-number">32</span>) {</span>
<span class="line" id="L149">            <span class="tok-kw">const</span> max_n = ops / (r * <span class="tok-number">4</span>);</span>
<span class="line" id="L150">            <span class="tok-kw">return</span> Self{ .r = r, .p = <span class="tok-number">1</span>, .ln = <span class="tok-builtin">@intCast</span>(<span class="tok-type">u6</span>, math.log2(max_n)) };</span>
<span class="line" id="L151">        } <span class="tok-kw">else</span> {</span>
<span class="line" id="L152">            <span class="tok-kw">const</span> max_n = mem_limit / (<span class="tok-builtin">@intCast</span>(<span class="tok-type">usize</span>, r) * <span class="tok-number">128</span>);</span>
<span class="line" id="L153">            <span class="tok-kw">const</span> ln = <span class="tok-builtin">@intCast</span>(<span class="tok-type">u6</span>, math.log2(max_n));</span>
<span class="line" id="L154">            <span class="tok-kw">const</span> max_rp = math.min(<span class="tok-number">0x3fffffff</span>, (ops / <span class="tok-number">4</span>) / (<span class="tok-builtin">@as</span>(<span class="tok-type">u64</span>, <span class="tok-number">1</span>) &lt;&lt; ln));</span>
<span class="line" id="L155">            <span class="tok-kw">return</span> Self{ .r = r, .p = <span class="tok-builtin">@intCast</span>(<span class="tok-type">u30</span>, max_rp / <span class="tok-builtin">@as</span>(<span class="tok-type">u64</span>, r)), .ln = ln };</span>
<span class="line" id="L156">        }</span>
<span class="line" id="L157">    }</span>
<span class="line" id="L158">};</span>
<span class="line" id="L159"></span>
<span class="line" id="L160"><span class="tok-comment">/// Apply scrypt to generate a key from a password.</span></span>
<span class="line" id="L161"><span class="tok-comment">///</span></span>
<span class="line" id="L162"><span class="tok-comment">/// scrypt is defined in RFC 7914.</span></span>
<span class="line" id="L163"><span class="tok-comment">///</span></span>
<span class="line" id="L164"><span class="tok-comment">/// allocator: mem.Allocator.</span></span>
<span class="line" id="L165"><span class="tok-comment">///</span></span>
<span class="line" id="L166"><span class="tok-comment">/// derived_key: Slice of appropriate size for generated key. Generally 16 or 32 bytes in length.</span></span>
<span class="line" id="L167"><span class="tok-comment">///              May be uninitialized. All bytes will be overwritten.</span></span>
<span class="line" id="L168"><span class="tok-comment">///              Maximum size is `derived_key.len / 32 == 0xffff_ffff`.</span></span>
<span class="line" id="L169"><span class="tok-comment">///</span></span>
<span class="line" id="L170"><span class="tok-comment">/// password: Arbitrary sequence of bytes of any length.</span></span>
<span class="line" id="L171"><span class="tok-comment">///</span></span>
<span class="line" id="L172"><span class="tok-comment">/// salt: Arbitrary sequence of bytes of any length.</span></span>
<span class="line" id="L173"><span class="tok-comment">///</span></span>
<span class="line" id="L174"><span class="tok-comment">/// params: Params.</span></span>
<span class="line" id="L175"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">kdf</span>(</span>
<span class="line" id="L176">    allocator: mem.Allocator,</span>
<span class="line" id="L177">    derived_key: []<span class="tok-type">u8</span>,</span>
<span class="line" id="L178">    password: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L179">    salt: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L180">    params: Params,</span>
<span class="line" id="L181">) KdfError!<span class="tok-type">void</span> {</span>
<span class="line" id="L182">    <span class="tok-kw">if</span> (derived_key.len == <span class="tok-number">0</span>) <span class="tok-kw">return</span> KdfError.WeakParameters;</span>
<span class="line" id="L183">    <span class="tok-kw">if</span> (derived_key.len / <span class="tok-number">32</span> &gt; <span class="tok-number">0xffff_ffff</span>) <span class="tok-kw">return</span> KdfError.OutputTooLong;</span>
<span class="line" id="L184">    <span class="tok-kw">if</span> (params.ln == <span class="tok-number">0</span> <span class="tok-kw">or</span> params.r == <span class="tok-number">0</span> <span class="tok-kw">or</span> params.p == <span class="tok-number">0</span>) <span class="tok-kw">return</span> KdfError.WeakParameters;</span>
<span class="line" id="L185"></span>
<span class="line" id="L186">    <span class="tok-kw">const</span> n64 = <span class="tok-builtin">@as</span>(<span class="tok-type">u64</span>, <span class="tok-number">1</span>) &lt;&lt; params.ln;</span>
<span class="line" id="L187">    <span class="tok-kw">if</span> (n64 &gt; max_size) <span class="tok-kw">return</span> KdfError.WeakParameters;</span>
<span class="line" id="L188">    <span class="tok-kw">const</span> n = <span class="tok-builtin">@intCast</span>(<span class="tok-type">usize</span>, n64);</span>
<span class="line" id="L189">    <span class="tok-kw">if</span> (<span class="tok-builtin">@as</span>(<span class="tok-type">u64</span>, params.r) * <span class="tok-builtin">@as</span>(<span class="tok-type">u64</span>, params.p) &gt;= <span class="tok-number">1</span> &lt;&lt; <span class="tok-number">30</span> <span class="tok-kw">or</span></span>
<span class="line" id="L190">        params.r &gt; max_int / <span class="tok-number">128</span> / <span class="tok-builtin">@as</span>(<span class="tok-type">u64</span>, params.p) <span class="tok-kw">or</span></span>
<span class="line" id="L191">        params.r &gt; max_int / <span class="tok-number">256</span> <span class="tok-kw">or</span></span>
<span class="line" id="L192">        n &gt; max_int / <span class="tok-number">128</span> / <span class="tok-builtin">@as</span>(<span class="tok-type">u64</span>, params.r)) <span class="tok-kw">return</span> KdfError.WeakParameters;</span>
<span class="line" id="L193"></span>
<span class="line" id="L194">    <span class="tok-kw">var</span> xy = <span class="tok-kw">try</span> allocator.alignedAlloc(<span class="tok-type">u32</span>, <span class="tok-number">16</span>, <span class="tok-number">64</span> * params.r);</span>
<span class="line" id="L195">    <span class="tok-kw">defer</span> allocator.free(xy);</span>
<span class="line" id="L196">    <span class="tok-kw">var</span> v = <span class="tok-kw">try</span> allocator.alignedAlloc(<span class="tok-type">u32</span>, <span class="tok-number">16</span>, <span class="tok-number">32</span> * n * params.r);</span>
<span class="line" id="L197">    <span class="tok-kw">defer</span> allocator.free(v);</span>
<span class="line" id="L198">    <span class="tok-kw">var</span> dk = <span class="tok-kw">try</span> allocator.alignedAlloc(<span class="tok-type">u8</span>, <span class="tok-number">16</span>, params.p * <span class="tok-number">128</span> * params.r);</span>
<span class="line" id="L199">    <span class="tok-kw">defer</span> allocator.free(dk);</span>
<span class="line" id="L200"></span>
<span class="line" id="L201">    <span class="tok-kw">try</span> pwhash.pbkdf2(dk, password, salt, <span class="tok-number">1</span>, HmacSha256);</span>
<span class="line" id="L202">    <span class="tok-kw">var</span> i: <span class="tok-type">u32</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L203">    <span class="tok-kw">while</span> (i &lt; params.p) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L204">        smix(<span class="tok-builtin">@alignCast</span>(<span class="tok-number">16</span>, dk[i * <span class="tok-number">128</span> * params.r ..]), params.r, n, v, xy);</span>
<span class="line" id="L205">    }</span>
<span class="line" id="L206">    <span class="tok-kw">try</span> pwhash.pbkdf2(derived_key, password, dk, <span class="tok-number">1</span>, HmacSha256);</span>
<span class="line" id="L207">}</span>
<span class="line" id="L208"></span>
<span class="line" id="L209"><span class="tok-kw">const</span> crypt_format = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L210">    <span class="tok-comment">/// String prefix for scrypt</span></span>
<span class="line" id="L211">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> prefix = <span class="tok-str">&quot;$7$&quot;</span>;</span>
<span class="line" id="L212"></span>
<span class="line" id="L213">    <span class="tok-comment">/// Standard type for a set of scrypt parameters, with the salt and hash.</span></span>
<span class="line" id="L214">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">HashResult</span>(<span class="tok-kw">comptime</span> crypt_max_hash_len: <span class="tok-type">usize</span>) <span class="tok-type">type</span> {</span>
<span class="line" id="L215">        <span class="tok-kw">return</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L216">            ln: <span class="tok-type">u6</span>,</span>
<span class="line" id="L217">            r: <span class="tok-type">u30</span>,</span>
<span class="line" id="L218">            p: <span class="tok-type">u30</span>,</span>
<span class="line" id="L219">            salt: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L220">            hash: BinValue(crypt_max_hash_len),</span>
<span class="line" id="L221">        };</span>
<span class="line" id="L222">    }</span>
<span class="line" id="L223"></span>
<span class="line" id="L224">    <span class="tok-kw">const</span> Codec = CustomB64Codec(<span class="tok-str">&quot;./0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz&quot;</span>.*);</span>
<span class="line" id="L225"></span>
<span class="line" id="L226">    <span class="tok-comment">/// A wrapped binary value whose maximum size is `max_len`.</span></span>
<span class="line" id="L227">    <span class="tok-comment">///</span></span>
<span class="line" id="L228">    <span class="tok-comment">/// This type must be used whenever a binary value is encoded in a PHC-formatted string.</span></span>
<span class="line" id="L229">    <span class="tok-comment">/// This includes `salt`, `hash`, and any other binary parameters such as keys.</span></span>
<span class="line" id="L230">    <span class="tok-comment">///</span></span>
<span class="line" id="L231">    <span class="tok-comment">/// Once initialized, the actual value can be read with the `constSlice()` function.</span></span>
<span class="line" id="L232">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">BinValue</span>(<span class="tok-kw">comptime</span> max_len: <span class="tok-type">usize</span>) <span class="tok-type">type</span> {</span>
<span class="line" id="L233">        <span class="tok-kw">return</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L234">            <span class="tok-kw">const</span> Self = <span class="tok-builtin">@This</span>();</span>
<span class="line" id="L235">            <span class="tok-kw">const</span> capacity = max_len;</span>
<span class="line" id="L236">            <span class="tok-kw">const</span> max_encoded_length = Codec.encodedLen(max_len);</span>
<span class="line" id="L237"></span>
<span class="line" id="L238">            buf: [max_len]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>,</span>
<span class="line" id="L239">            len: <span class="tok-type">usize</span> = <span class="tok-number">0</span>,</span>
<span class="line" id="L240"></span>
<span class="line" id="L241">            <span class="tok-comment">/// Wrap an existing byte slice</span></span>
<span class="line" id="L242">            <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">fromSlice</span>(slice: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) EncodingError!Self {</span>
<span class="line" id="L243">                <span class="tok-kw">if</span> (slice.len &gt; capacity) <span class="tok-kw">return</span> EncodingError.NoSpaceLeft;</span>
<span class="line" id="L244">                <span class="tok-kw">var</span> bin_value: Self = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L245">                mem.copy(<span class="tok-type">u8</span>, &amp;bin_value.buf, slice);</span>
<span class="line" id="L246">                bin_value.len = slice.len;</span>
<span class="line" id="L247">                <span class="tok-kw">return</span> bin_value;</span>
<span class="line" id="L248">            }</span>
<span class="line" id="L249"></span>
<span class="line" id="L250">            <span class="tok-comment">/// Return the slice containing the actual value.</span></span>
<span class="line" id="L251">            <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">constSlice</span>(self: *<span class="tok-kw">const</span> Self) []<span class="tok-kw">const</span> <span class="tok-type">u8</span> {</span>
<span class="line" id="L252">                <span class="tok-kw">return</span> self.buf[<span class="tok-number">0</span>..self.len];</span>
<span class="line" id="L253">            }</span>
<span class="line" id="L254"></span>
<span class="line" id="L255">            <span class="tok-kw">fn</span> <span class="tok-fn">fromB64</span>(self: *Self, str: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) !<span class="tok-type">void</span> {</span>
<span class="line" id="L256">                <span class="tok-kw">const</span> len = Codec.decodedLen(str.len);</span>
<span class="line" id="L257">                <span class="tok-kw">if</span> (len &gt; self.buf.len) <span class="tok-kw">return</span> EncodingError.NoSpaceLeft;</span>
<span class="line" id="L258">                <span class="tok-kw">try</span> Codec.decode(self.buf[<span class="tok-number">0</span>..len], str);</span>
<span class="line" id="L259">                self.len = len;</span>
<span class="line" id="L260">            }</span>
<span class="line" id="L261"></span>
<span class="line" id="L262">            <span class="tok-kw">fn</span> <span class="tok-fn">toB64</span>(self: *<span class="tok-kw">const</span> Self, buf: []<span class="tok-type">u8</span>) ![]<span class="tok-kw">const</span> <span class="tok-type">u8</span> {</span>
<span class="line" id="L263">                <span class="tok-kw">const</span> value = self.constSlice();</span>
<span class="line" id="L264">                <span class="tok-kw">const</span> len = Codec.encodedLen(value.len);</span>
<span class="line" id="L265">                <span class="tok-kw">if</span> (len &gt; buf.len) <span class="tok-kw">return</span> EncodingError.NoSpaceLeft;</span>
<span class="line" id="L266">                <span class="tok-kw">var</span> encoded = buf[<span class="tok-number">0</span>..len];</span>
<span class="line" id="L267">                Codec.encode(encoded, value);</span>
<span class="line" id="L268">                <span class="tok-kw">return</span> encoded;</span>
<span class="line" id="L269">            }</span>
<span class="line" id="L270">        };</span>
<span class="line" id="L271">    }</span>
<span class="line" id="L272"></span>
<span class="line" id="L273">    <span class="tok-comment">/// Expand binary data into a salt for the modular crypt format.</span></span>
<span class="line" id="L274">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">saltFromBin</span>(<span class="tok-kw">comptime</span> len: <span class="tok-type">usize</span>, salt: [len]<span class="tok-type">u8</span>) [Codec.encodedLen(len)]<span class="tok-type">u8</span> {</span>
<span class="line" id="L275">        <span class="tok-kw">var</span> buf: [Codec.encodedLen(len)]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L276">        Codec.encode(&amp;buf, &amp;salt);</span>
<span class="line" id="L277">        <span class="tok-kw">return</span> buf;</span>
<span class="line" id="L278">    }</span>
<span class="line" id="L279"></span>
<span class="line" id="L280">    <span class="tok-comment">/// Deserialize a string into a structure `T` (matching `HashResult`).</span></span>
<span class="line" id="L281">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">deserialize</span>(<span class="tok-kw">comptime</span> T: <span class="tok-type">type</span>, str: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) EncodingError!T {</span>
<span class="line" id="L282">        <span class="tok-kw">var</span> out: T = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L283"></span>
<span class="line" id="L284">        <span class="tok-kw">if</span> (str.len &lt; <span class="tok-number">16</span>) <span class="tok-kw">return</span> EncodingError.InvalidEncoding;</span>
<span class="line" id="L285">        <span class="tok-kw">if</span> (!mem.eql(<span class="tok-type">u8</span>, prefix, str[<span class="tok-number">0</span>..<span class="tok-number">3</span>])) <span class="tok-kw">return</span> EncodingError.InvalidEncoding;</span>
<span class="line" id="L286">        out.ln = <span class="tok-kw">try</span> Codec.intDecode(<span class="tok-type">u6</span>, str[<span class="tok-number">3</span>..<span class="tok-number">4</span>]);</span>
<span class="line" id="L287">        out.r = <span class="tok-kw">try</span> Codec.intDecode(<span class="tok-type">u30</span>, str[<span class="tok-number">4</span>..<span class="tok-number">9</span>]);</span>
<span class="line" id="L288">        out.p = <span class="tok-kw">try</span> Codec.intDecode(<span class="tok-type">u30</span>, str[<span class="tok-number">9</span>..<span class="tok-number">14</span>]);</span>
<span class="line" id="L289"></span>
<span class="line" id="L290">        <span class="tok-kw">var</span> it = mem.split(<span class="tok-type">u8</span>, str[<span class="tok-number">14</span>..], <span class="tok-str">&quot;$&quot;</span>);</span>
<span class="line" id="L291"></span>
<span class="line" id="L292">        <span class="tok-kw">const</span> salt = it.first();</span>
<span class="line" id="L293">        <span class="tok-kw">if</span> (<span class="tok-builtin">@hasField</span>(T, <span class="tok-str">&quot;salt&quot;</span>)) out.salt = salt;</span>
<span class="line" id="L294"></span>
<span class="line" id="L295">        <span class="tok-kw">const</span> hash_str = it.next() <span class="tok-kw">orelse</span> <span class="tok-kw">return</span> EncodingError.InvalidEncoding;</span>
<span class="line" id="L296">        <span class="tok-kw">if</span> (<span class="tok-builtin">@hasField</span>(T, <span class="tok-str">&quot;hash&quot;</span>)) <span class="tok-kw">try</span> out.hash.fromB64(hash_str);</span>
<span class="line" id="L297"></span>
<span class="line" id="L298">        <span class="tok-kw">return</span> out;</span>
<span class="line" id="L299">    }</span>
<span class="line" id="L300"></span>
<span class="line" id="L301">    <span class="tok-comment">/// Serialize parameters into a string in modular crypt format.</span></span>
<span class="line" id="L302">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">serialize</span>(params: <span class="tok-kw">anytype</span>, str: []<span class="tok-type">u8</span>) EncodingError![]<span class="tok-kw">const</span> <span class="tok-type">u8</span> {</span>
<span class="line" id="L303">        <span class="tok-kw">var</span> buf = io.fixedBufferStream(str);</span>
<span class="line" id="L304">        <span class="tok-kw">try</span> serializeTo(params, buf.writer());</span>
<span class="line" id="L305">        <span class="tok-kw">return</span> buf.getWritten();</span>
<span class="line" id="L306">    }</span>
<span class="line" id="L307"></span>
<span class="line" id="L308">    <span class="tok-comment">/// Compute the number of bytes required to serialize `params`</span></span>
<span class="line" id="L309">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">calcSize</span>(params: <span class="tok-kw">anytype</span>) <span class="tok-type">usize</span> {</span>
<span class="line" id="L310">        <span class="tok-kw">var</span> buf = io.countingWriter(io.null_writer);</span>
<span class="line" id="L311">        serializeTo(params, buf.writer()) <span class="tok-kw">catch</span> <span class="tok-kw">unreachable</span>;</span>
<span class="line" id="L312">        <span class="tok-kw">return</span> <span class="tok-builtin">@intCast</span>(<span class="tok-type">usize</span>, buf.bytes_written);</span>
<span class="line" id="L313">    }</span>
<span class="line" id="L314"></span>
<span class="line" id="L315">    <span class="tok-kw">fn</span> <span class="tok-fn">serializeTo</span>(params: <span class="tok-kw">anytype</span>, out: <span class="tok-kw">anytype</span>) !<span class="tok-type">void</span> {</span>
<span class="line" id="L316">        <span class="tok-kw">var</span> header: [<span class="tok-number">14</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L317">        mem.copy(<span class="tok-type">u8</span>, header[<span class="tok-number">0</span>..<span class="tok-number">3</span>], prefix);</span>
<span class="line" id="L318">        Codec.intEncode(header[<span class="tok-number">3</span>..<span class="tok-number">4</span>], params.ln);</span>
<span class="line" id="L319">        Codec.intEncode(header[<span class="tok-number">4</span>..<span class="tok-number">9</span>], params.r);</span>
<span class="line" id="L320">        Codec.intEncode(header[<span class="tok-number">9</span>..<span class="tok-number">14</span>], params.p);</span>
<span class="line" id="L321">        <span class="tok-kw">try</span> out.writeAll(&amp;header);</span>
<span class="line" id="L322">        <span class="tok-kw">try</span> out.writeAll(params.salt);</span>
<span class="line" id="L323">        <span class="tok-kw">try</span> out.writeAll(<span class="tok-str">&quot;$&quot;</span>);</span>
<span class="line" id="L324">        <span class="tok-kw">var</span> buf: [<span class="tok-builtin">@TypeOf</span>(params.hash).max_encoded_length]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L325">        <span class="tok-kw">const</span> hash_str = <span class="tok-kw">try</span> params.hash.toB64(&amp;buf);</span>
<span class="line" id="L326">        <span class="tok-kw">try</span> out.writeAll(hash_str);</span>
<span class="line" id="L327">    }</span>
<span class="line" id="L328"></span>
<span class="line" id="L329">    <span class="tok-comment">/// Custom codec that maps 6 bits into 8 like regular Base64, but uses its own alphabet,</span></span>
<span class="line" id="L330">    <span class="tok-comment">/// encodes bits in little-endian, and can also encode integers.</span></span>
<span class="line" id="L331">    <span class="tok-kw">fn</span> <span class="tok-fn">CustomB64Codec</span>(<span class="tok-kw">comptime</span> map: [<span class="tok-number">64</span>]<span class="tok-type">u8</span>) <span class="tok-type">type</span> {</span>
<span class="line" id="L332">        <span class="tok-kw">return</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L333">            <span class="tok-kw">const</span> map64 = map;</span>
<span class="line" id="L334"></span>
<span class="line" id="L335">            <span class="tok-kw">fn</span> <span class="tok-fn">encodedLen</span>(len: <span class="tok-type">usize</span>) <span class="tok-type">usize</span> {</span>
<span class="line" id="L336">                <span class="tok-kw">return</span> (len * <span class="tok-number">4</span> + <span class="tok-number">2</span>) / <span class="tok-number">3</span>;</span>
<span class="line" id="L337">            }</span>
<span class="line" id="L338"></span>
<span class="line" id="L339">            <span class="tok-kw">fn</span> <span class="tok-fn">decodedLen</span>(len: <span class="tok-type">usize</span>) <span class="tok-type">usize</span> {</span>
<span class="line" id="L340">                <span class="tok-kw">return</span> len / <span class="tok-number">4</span> * <span class="tok-number">3</span> + (len % <span class="tok-number">4</span>) * <span class="tok-number">3</span> / <span class="tok-number">4</span>;</span>
<span class="line" id="L341">            }</span>
<span class="line" id="L342"></span>
<span class="line" id="L343">            <span class="tok-kw">fn</span> <span class="tok-fn">intEncode</span>(dst: []<span class="tok-type">u8</span>, src: <span class="tok-kw">anytype</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L344">                <span class="tok-kw">var</span> n = src;</span>
<span class="line" id="L345">                <span class="tok-kw">for</span> (dst) |*x| {</span>
<span class="line" id="L346">                    x.* = map64[<span class="tok-builtin">@truncate</span>(<span class="tok-type">u6</span>, n)];</span>
<span class="line" id="L347">                    n = math.shr(<span class="tok-builtin">@TypeOf</span>(src), n, <span class="tok-number">6</span>);</span>
<span class="line" id="L348">                }</span>
<span class="line" id="L349">            }</span>
<span class="line" id="L350"></span>
<span class="line" id="L351">            <span class="tok-kw">fn</span> <span class="tok-fn">intDecode</span>(<span class="tok-kw">comptime</span> T: <span class="tok-type">type</span>, src: *<span class="tok-kw">const</span> [(<span class="tok-builtin">@bitSizeOf</span>(T) + <span class="tok-number">5</span>) / <span class="tok-number">6</span>]<span class="tok-type">u8</span>) !T {</span>
<span class="line" id="L352">                <span class="tok-kw">var</span> v: T = <span class="tok-number">0</span>;</span>
<span class="line" id="L353">                <span class="tok-kw">for</span> (src) |x, i| {</span>
<span class="line" id="L354">                    <span class="tok-kw">const</span> vi = mem.indexOfScalar(<span class="tok-type">u8</span>, &amp;map64, x) <span class="tok-kw">orelse</span> <span class="tok-kw">return</span> EncodingError.InvalidEncoding;</span>
<span class="line" id="L355">                    v |= <span class="tok-builtin">@intCast</span>(T, vi) &lt;&lt; <span class="tok-builtin">@intCast</span>(math.Log2Int(T), i * <span class="tok-number">6</span>);</span>
<span class="line" id="L356">                }</span>
<span class="line" id="L357">                <span class="tok-kw">return</span> v;</span>
<span class="line" id="L358">            }</span>
<span class="line" id="L359"></span>
<span class="line" id="L360">            <span class="tok-kw">fn</span> <span class="tok-fn">decode</span>(dst: []<span class="tok-type">u8</span>, src: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) !<span class="tok-type">void</span> {</span>
<span class="line" id="L361">                std.debug.assert(dst.len == decodedLen(src.len));</span>
<span class="line" id="L362">                <span class="tok-kw">var</span> i: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L363">                <span class="tok-kw">while</span> (i &lt; src.len / <span class="tok-number">4</span>) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L364">                    mem.writeIntSliceLittle(<span class="tok-type">u24</span>, dst[i * <span class="tok-number">3</span> ..], <span class="tok-kw">try</span> intDecode(<span class="tok-type">u24</span>, src[i * <span class="tok-number">4</span> ..][<span class="tok-number">0</span>..<span class="tok-number">4</span>]));</span>
<span class="line" id="L365">                }</span>
<span class="line" id="L366">                <span class="tok-kw">const</span> leftover = src[i * <span class="tok-number">4</span> ..];</span>
<span class="line" id="L367">                <span class="tok-kw">var</span> v: <span class="tok-type">u24</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L368">                <span class="tok-kw">for</span> (leftover) |_, j| {</span>
<span class="line" id="L369">                    v |= <span class="tok-builtin">@as</span>(<span class="tok-type">u24</span>, <span class="tok-kw">try</span> intDecode(<span class="tok-type">u6</span>, leftover[j..][<span class="tok-number">0</span>..<span class="tok-number">1</span>])) &lt;&lt; <span class="tok-builtin">@intCast</span>(<span class="tok-type">u5</span>, j * <span class="tok-number">6</span>);</span>
<span class="line" id="L370">                }</span>
<span class="line" id="L371">                <span class="tok-kw">for</span> (dst[i * <span class="tok-number">3</span> ..]) |*x, j| {</span>
<span class="line" id="L372">                    x.* = <span class="tok-builtin">@truncate</span>(<span class="tok-type">u8</span>, v &gt;&gt; <span class="tok-builtin">@intCast</span>(<span class="tok-type">u5</span>, j * <span class="tok-number">8</span>));</span>
<span class="line" id="L373">                }</span>
<span class="line" id="L374">            }</span>
<span class="line" id="L375"></span>
<span class="line" id="L376">            <span class="tok-kw">fn</span> <span class="tok-fn">encode</span>(dst: []<span class="tok-type">u8</span>, src: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L377">                std.debug.assert(dst.len == encodedLen(src.len));</span>
<span class="line" id="L378">                <span class="tok-kw">var</span> i: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L379">                <span class="tok-kw">while</span> (i &lt; src.len / <span class="tok-number">3</span>) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L380">                    intEncode(dst[i * <span class="tok-number">4</span> ..][<span class="tok-number">0</span>..<span class="tok-number">4</span>], mem.readIntSliceLittle(<span class="tok-type">u24</span>, src[i * <span class="tok-number">3</span> ..]));</span>
<span class="line" id="L381">                }</span>
<span class="line" id="L382">                <span class="tok-kw">const</span> leftover = src[i * <span class="tok-number">3</span> ..];</span>
<span class="line" id="L383">                <span class="tok-kw">var</span> v: <span class="tok-type">u24</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L384">                <span class="tok-kw">for</span> (leftover) |x, j| {</span>
<span class="line" id="L385">                    v |= <span class="tok-builtin">@as</span>(<span class="tok-type">u24</span>, x) &lt;&lt; <span class="tok-builtin">@intCast</span>(<span class="tok-type">u5</span>, j * <span class="tok-number">8</span>);</span>
<span class="line" id="L386">                }</span>
<span class="line" id="L387">                intEncode(dst[i * <span class="tok-number">4</span> ..], v);</span>
<span class="line" id="L388">            }</span>
<span class="line" id="L389">        };</span>
<span class="line" id="L390">    }</span>
<span class="line" id="L391">};</span>
<span class="line" id="L392"></span>
<span class="line" id="L393"><span class="tok-comment">/// Hash and verify passwords using the PHC format.</span></span>
<span class="line" id="L394"><span class="tok-kw">const</span> PhcFormatHasher = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L395">    <span class="tok-kw">const</span> alg_id = <span class="tok-str">&quot;scrypt&quot;</span>;</span>
<span class="line" id="L396">    <span class="tok-kw">const</span> BinValue = phc_format.BinValue;</span>
<span class="line" id="L397"></span>
<span class="line" id="L398">    <span class="tok-kw">const</span> HashResult = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L399">        alg_id: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L400">        ln: <span class="tok-type">u6</span>,</span>
<span class="line" id="L401">        r: <span class="tok-type">u30</span>,</span>
<span class="line" id="L402">        p: <span class="tok-type">u30</span>,</span>
<span class="line" id="L403">        salt: BinValue(max_salt_len),</span>
<span class="line" id="L404">        hash: BinValue(max_hash_len),</span>
<span class="line" id="L405">    };</span>
<span class="line" id="L406"></span>
<span class="line" id="L407">    <span class="tok-comment">/// Return a non-deterministic hash of the password encoded as a PHC-format string</span></span>
<span class="line" id="L408">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">create</span>(</span>
<span class="line" id="L409">        allocator: mem.Allocator,</span>
<span class="line" id="L410">        password: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L411">        params: Params,</span>
<span class="line" id="L412">        buf: []<span class="tok-type">u8</span>,</span>
<span class="line" id="L413">    ) HasherError![]<span class="tok-kw">const</span> <span class="tok-type">u8</span> {</span>
<span class="line" id="L414">        <span class="tok-kw">var</span> salt: [default_salt_len]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L415">        crypto.random.bytes(&amp;salt);</span>
<span class="line" id="L416"></span>
<span class="line" id="L417">        <span class="tok-kw">var</span> hash: [default_hash_len]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L418">        <span class="tok-kw">try</span> kdf(allocator, &amp;hash, password, &amp;salt, params);</span>
<span class="line" id="L419"></span>
<span class="line" id="L420">        <span class="tok-kw">return</span> phc_format.serialize(HashResult{</span>
<span class="line" id="L421">            .alg_id = alg_id,</span>
<span class="line" id="L422">            .ln = params.ln,</span>
<span class="line" id="L423">            .r = params.r,</span>
<span class="line" id="L424">            .p = params.p,</span>
<span class="line" id="L425">            .salt = <span class="tok-kw">try</span> BinValue(max_salt_len).fromSlice(&amp;salt),</span>
<span class="line" id="L426">            .hash = <span class="tok-kw">try</span> BinValue(max_hash_len).fromSlice(&amp;hash),</span>
<span class="line" id="L427">        }, buf);</span>
<span class="line" id="L428">    }</span>
<span class="line" id="L429"></span>
<span class="line" id="L430">    <span class="tok-comment">/// Verify a password against a PHC-format encoded string</span></span>
<span class="line" id="L431">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">verify</span>(</span>
<span class="line" id="L432">        allocator: mem.Allocator,</span>
<span class="line" id="L433">        str: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L434">        password: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L435">    ) HasherError!<span class="tok-type">void</span> {</span>
<span class="line" id="L436">        <span class="tok-kw">const</span> hash_result = <span class="tok-kw">try</span> phc_format.deserialize(HashResult, str);</span>
<span class="line" id="L437">        <span class="tok-kw">if</span> (!mem.eql(<span class="tok-type">u8</span>, hash_result.alg_id, alg_id)) <span class="tok-kw">return</span> HasherError.PasswordVerificationFailed;</span>
<span class="line" id="L438">        <span class="tok-kw">const</span> params = Params{ .ln = hash_result.ln, .r = hash_result.r, .p = hash_result.p };</span>
<span class="line" id="L439">        <span class="tok-kw">const</span> expected_hash = hash_result.hash.constSlice();</span>
<span class="line" id="L440">        <span class="tok-kw">var</span> hash_buf: [max_hash_len]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L441">        <span class="tok-kw">if</span> (expected_hash.len &gt; hash_buf.len) <span class="tok-kw">return</span> HasherError.InvalidEncoding;</span>
<span class="line" id="L442">        <span class="tok-kw">var</span> hash = hash_buf[<span class="tok-number">0</span>..expected_hash.len];</span>
<span class="line" id="L443">        <span class="tok-kw">try</span> kdf(allocator, hash, password, hash_result.salt.constSlice(), params);</span>
<span class="line" id="L444">        <span class="tok-kw">if</span> (!mem.eql(<span class="tok-type">u8</span>, hash, expected_hash)) <span class="tok-kw">return</span> HasherError.PasswordVerificationFailed;</span>
<span class="line" id="L445">    }</span>
<span class="line" id="L446">};</span>
<span class="line" id="L447"></span>
<span class="line" id="L448"><span class="tok-comment">/// Hash and verify passwords using the modular crypt format.</span></span>
<span class="line" id="L449"><span class="tok-kw">const</span> CryptFormatHasher = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L450">    <span class="tok-kw">const</span> BinValue = crypt_format.BinValue;</span>
<span class="line" id="L451">    <span class="tok-kw">const</span> HashResult = crypt_format.HashResult(max_hash_len);</span>
<span class="line" id="L452"></span>
<span class="line" id="L453">    <span class="tok-comment">/// Length of a string returned by the create() function</span></span>
<span class="line" id="L454">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> pwhash_str_length: <span class="tok-type">usize</span> = <span class="tok-number">101</span>;</span>
<span class="line" id="L455"></span>
<span class="line" id="L456">    <span class="tok-comment">/// Return a non-deterministic hash of the password encoded into the modular crypt format</span></span>
<span class="line" id="L457">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">create</span>(</span>
<span class="line" id="L458">        allocator: mem.Allocator,</span>
<span class="line" id="L459">        password: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L460">        params: Params,</span>
<span class="line" id="L461">        buf: []<span class="tok-type">u8</span>,</span>
<span class="line" id="L462">    ) HasherError![]<span class="tok-kw">const</span> <span class="tok-type">u8</span> {</span>
<span class="line" id="L463">        <span class="tok-kw">var</span> salt_bin: [default_salt_len]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L464">        crypto.random.bytes(&amp;salt_bin);</span>
<span class="line" id="L465">        <span class="tok-kw">const</span> salt = crypt_format.saltFromBin(salt_bin.len, salt_bin);</span>
<span class="line" id="L466"></span>
<span class="line" id="L467">        <span class="tok-kw">var</span> hash: [default_hash_len]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L468">        <span class="tok-kw">try</span> kdf(allocator, &amp;hash, password, &amp;salt, params);</span>
<span class="line" id="L469"></span>
<span class="line" id="L470">        <span class="tok-kw">return</span> crypt_format.serialize(HashResult{</span>
<span class="line" id="L471">            .ln = params.ln,</span>
<span class="line" id="L472">            .r = params.r,</span>
<span class="line" id="L473">            .p = params.p,</span>
<span class="line" id="L474">            .salt = &amp;salt,</span>
<span class="line" id="L475">            .hash = <span class="tok-kw">try</span> BinValue(max_hash_len).fromSlice(&amp;hash),</span>
<span class="line" id="L476">        }, buf);</span>
<span class="line" id="L477">    }</span>
<span class="line" id="L478"></span>
<span class="line" id="L479">    <span class="tok-comment">/// Verify a password against a string in modular crypt format</span></span>
<span class="line" id="L480">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">verify</span>(</span>
<span class="line" id="L481">        allocator: mem.Allocator,</span>
<span class="line" id="L482">        str: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L483">        password: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L484">    ) HasherError!<span class="tok-type">void</span> {</span>
<span class="line" id="L485">        <span class="tok-kw">const</span> hash_result = <span class="tok-kw">try</span> crypt_format.deserialize(HashResult, str);</span>
<span class="line" id="L486">        <span class="tok-kw">const</span> params = Params{ .ln = hash_result.ln, .r = hash_result.r, .p = hash_result.p };</span>
<span class="line" id="L487">        <span class="tok-kw">const</span> expected_hash = hash_result.hash.constSlice();</span>
<span class="line" id="L488">        <span class="tok-kw">var</span> hash_buf: [max_hash_len]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L489">        <span class="tok-kw">if</span> (expected_hash.len &gt; hash_buf.len) <span class="tok-kw">return</span> HasherError.InvalidEncoding;</span>
<span class="line" id="L490">        <span class="tok-kw">var</span> hash = hash_buf[<span class="tok-number">0</span>..expected_hash.len];</span>
<span class="line" id="L491">        <span class="tok-kw">try</span> kdf(allocator, hash, password, hash_result.salt, params);</span>
<span class="line" id="L492">        <span class="tok-kw">if</span> (!mem.eql(<span class="tok-type">u8</span>, hash, expected_hash)) <span class="tok-kw">return</span> HasherError.PasswordVerificationFailed;</span>
<span class="line" id="L493">    }</span>
<span class="line" id="L494">};</span>
<span class="line" id="L495"></span>
<span class="line" id="L496"><span class="tok-comment">/// Options for hashing a password.</span></span>
<span class="line" id="L497"><span class="tok-comment">///</span></span>
<span class="line" id="L498"><span class="tok-comment">/// Allocator is required for scrypt.</span></span>
<span class="line" id="L499"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> HashOptions = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L500">    allocator: ?mem.Allocator,</span>
<span class="line" id="L501">    params: Params,</span>
<span class="line" id="L502">    encoding: pwhash.Encoding,</span>
<span class="line" id="L503">};</span>
<span class="line" id="L504"></span>
<span class="line" id="L505"><span class="tok-comment">/// Compute a hash of a password using the scrypt key derivation function.</span></span>
<span class="line" id="L506"><span class="tok-comment">/// The function returns a string that includes all the parameters required for verification.</span></span>
<span class="line" id="L507"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">strHash</span>(</span>
<span class="line" id="L508">    password: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L509">    options: HashOptions,</span>
<span class="line" id="L510">    out: []<span class="tok-type">u8</span>,</span>
<span class="line" id="L511">) Error![]<span class="tok-kw">const</span> <span class="tok-type">u8</span> {</span>
<span class="line" id="L512">    <span class="tok-kw">const</span> allocator = options.allocator <span class="tok-kw">orelse</span> <span class="tok-kw">return</span> Error.AllocatorRequired;</span>
<span class="line" id="L513">    <span class="tok-kw">switch</span> (options.encoding) {</span>
<span class="line" id="L514">        .phc =&gt; <span class="tok-kw">return</span> PhcFormatHasher.create(allocator, password, options.params, out),</span>
<span class="line" id="L515">        .crypt =&gt; <span class="tok-kw">return</span> CryptFormatHasher.create(allocator, password, options.params, out),</span>
<span class="line" id="L516">    }</span>
<span class="line" id="L517">}</span>
<span class="line" id="L518"></span>
<span class="line" id="L519"><span class="tok-comment">/// Options for hash verification.</span></span>
<span class="line" id="L520"><span class="tok-comment">///</span></span>
<span class="line" id="L521"><span class="tok-comment">/// Allocator is required for scrypt.</span></span>
<span class="line" id="L522"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> VerifyOptions = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L523">    allocator: ?mem.Allocator,</span>
<span class="line" id="L524">};</span>
<span class="line" id="L525"></span>
<span class="line" id="L526"><span class="tok-comment">/// Verify that a previously computed hash is valid for a given password.</span></span>
<span class="line" id="L527"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">strVerify</span>(</span>
<span class="line" id="L528">    str: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L529">    password: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L530">    options: VerifyOptions,</span>
<span class="line" id="L531">) Error!<span class="tok-type">void</span> {</span>
<span class="line" id="L532">    <span class="tok-kw">const</span> allocator = options.allocator <span class="tok-kw">orelse</span> <span class="tok-kw">return</span> Error.AllocatorRequired;</span>
<span class="line" id="L533">    <span class="tok-kw">if</span> (mem.startsWith(<span class="tok-type">u8</span>, str, crypt_format.prefix)) {</span>
<span class="line" id="L534">        <span class="tok-kw">return</span> CryptFormatHasher.verify(allocator, str, password);</span>
<span class="line" id="L535">    } <span class="tok-kw">else</span> {</span>
<span class="line" id="L536">        <span class="tok-kw">return</span> PhcFormatHasher.verify(allocator, str, password);</span>
<span class="line" id="L537">    }</span>
<span class="line" id="L538">}</span>
<span class="line" id="L539"></span>
<span class="line" id="L540"><span class="tok-comment">// These tests take way too long to run, so I have disabled them.</span>
</span>
<span class="line" id="L541"><span class="tok-kw">const</span> run_long_tests = <span class="tok-null">false</span>;</span>
<span class="line" id="L542"></span>
<span class="line" id="L543"><span class="tok-kw">test</span> <span class="tok-str">&quot;kdf&quot;</span> {</span>
<span class="line" id="L544">    <span class="tok-kw">if</span> (!run_long_tests) <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SkipZigTest;</span>
<span class="line" id="L545"></span>
<span class="line" id="L546">    <span class="tok-kw">const</span> password = <span class="tok-str">&quot;testpass&quot;</span>;</span>
<span class="line" id="L547">    <span class="tok-kw">const</span> salt = <span class="tok-str">&quot;saltsalt&quot;</span>;</span>
<span class="line" id="L548"></span>
<span class="line" id="L549">    <span class="tok-kw">var</span> dk: [<span class="tok-number">32</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L550">    <span class="tok-kw">try</span> kdf(std.testing.allocator, &amp;dk, password, salt, .{ .ln = <span class="tok-number">15</span>, .r = <span class="tok-number">8</span>, .p = <span class="tok-number">1</span> });</span>
<span class="line" id="L551"></span>
<span class="line" id="L552">    <span class="tok-kw">const</span> hex = <span class="tok-str">&quot;1e0f97c3f6609024022fbe698da29c2fe53ef1087a8e396dc6d5d2a041e886de&quot;</span>;</span>
<span class="line" id="L553">    <span class="tok-kw">var</span> bytes: [hex.len / <span class="tok-number">2</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L554">    _ = <span class="tok-kw">try</span> fmt.hexToBytes(&amp;bytes, hex);</span>
<span class="line" id="L555"></span>
<span class="line" id="L556">    <span class="tok-kw">try</span> std.testing.expectEqualSlices(<span class="tok-type">u8</span>, &amp;bytes, &amp;dk);</span>
<span class="line" id="L557">}</span>
<span class="line" id="L558"></span>
<span class="line" id="L559"><span class="tok-kw">test</span> <span class="tok-str">&quot;kdf rfc 1&quot;</span> {</span>
<span class="line" id="L560">    <span class="tok-kw">if</span> (!run_long_tests) <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SkipZigTest;</span>
<span class="line" id="L561"></span>
<span class="line" id="L562">    <span class="tok-kw">const</span> password = <span class="tok-str">&quot;&quot;</span>;</span>
<span class="line" id="L563">    <span class="tok-kw">const</span> salt = <span class="tok-str">&quot;&quot;</span>;</span>
<span class="line" id="L564"></span>
<span class="line" id="L565">    <span class="tok-kw">var</span> dk: [<span class="tok-number">64</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L566">    <span class="tok-kw">try</span> kdf(std.testing.allocator, &amp;dk, password, salt, .{ .ln = <span class="tok-number">4</span>, .r = <span class="tok-number">1</span>, .p = <span class="tok-number">1</span> });</span>
<span class="line" id="L567"></span>
<span class="line" id="L568">    <span class="tok-kw">const</span> hex = <span class="tok-str">&quot;77d6576238657b203b19ca42c18a0497f16b4844e3074ae8dfdffa3fede21442fcd0069ded0948f8326a753a0fc81f17e8d3e0fb2e0d3628cf35e20c38d18906&quot;</span>;</span>
<span class="line" id="L569">    <span class="tok-kw">var</span> bytes: [hex.len / <span class="tok-number">2</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L570">    _ = <span class="tok-kw">try</span> fmt.hexToBytes(&amp;bytes, hex);</span>
<span class="line" id="L571"></span>
<span class="line" id="L572">    <span class="tok-kw">try</span> std.testing.expectEqualSlices(<span class="tok-type">u8</span>, &amp;bytes, &amp;dk);</span>
<span class="line" id="L573">}</span>
<span class="line" id="L574"></span>
<span class="line" id="L575"><span class="tok-kw">test</span> <span class="tok-str">&quot;kdf rfc 2&quot;</span> {</span>
<span class="line" id="L576">    <span class="tok-kw">if</span> (!run_long_tests) <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SkipZigTest;</span>
<span class="line" id="L577"></span>
<span class="line" id="L578">    <span class="tok-kw">const</span> password = <span class="tok-str">&quot;password&quot;</span>;</span>
<span class="line" id="L579">    <span class="tok-kw">const</span> salt = <span class="tok-str">&quot;NaCl&quot;</span>;</span>
<span class="line" id="L580"></span>
<span class="line" id="L581">    <span class="tok-kw">var</span> dk: [<span class="tok-number">64</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L582">    <span class="tok-kw">try</span> kdf(std.testing.allocator, &amp;dk, password, salt, .{ .ln = <span class="tok-number">10</span>, .r = <span class="tok-number">8</span>, .p = <span class="tok-number">16</span> });</span>
<span class="line" id="L583"></span>
<span class="line" id="L584">    <span class="tok-kw">const</span> hex = <span class="tok-str">&quot;fdbabe1c9d3472007856e7190d01e9fe7c6ad7cbc8237830e77376634b3731622eaf30d92e22a3886ff109279d9830dac727afb94a83ee6d8360cbdfa2cc0640&quot;</span>;</span>
<span class="line" id="L585">    <span class="tok-kw">var</span> bytes: [hex.len / <span class="tok-number">2</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L586">    _ = <span class="tok-kw">try</span> fmt.hexToBytes(&amp;bytes, hex);</span>
<span class="line" id="L587"></span>
<span class="line" id="L588">    <span class="tok-kw">try</span> std.testing.expectEqualSlices(<span class="tok-type">u8</span>, &amp;bytes, &amp;dk);</span>
<span class="line" id="L589">}</span>
<span class="line" id="L590"></span>
<span class="line" id="L591"><span class="tok-kw">test</span> <span class="tok-str">&quot;kdf rfc 3&quot;</span> {</span>
<span class="line" id="L592">    <span class="tok-kw">if</span> (!run_long_tests) <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SkipZigTest;</span>
<span class="line" id="L593"></span>
<span class="line" id="L594">    <span class="tok-kw">const</span> password = <span class="tok-str">&quot;pleaseletmein&quot;</span>;</span>
<span class="line" id="L595">    <span class="tok-kw">const</span> salt = <span class="tok-str">&quot;SodiumChloride&quot;</span>;</span>
<span class="line" id="L596"></span>
<span class="line" id="L597">    <span class="tok-kw">var</span> dk: [<span class="tok-number">64</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L598">    <span class="tok-kw">try</span> kdf(std.testing.allocator, &amp;dk, password, salt, .{ .ln = <span class="tok-number">14</span>, .r = <span class="tok-number">8</span>, .p = <span class="tok-number">1</span> });</span>
<span class="line" id="L599"></span>
<span class="line" id="L600">    <span class="tok-kw">const</span> hex = <span class="tok-str">&quot;7023bdcb3afd7348461c06cd81fd38ebfda8fbba904f8e3ea9b543f6545da1f2d5432955613f0fcf62d49705242a9af9e61e85dc0d651e40dfcf017b45575887&quot;</span>;</span>
<span class="line" id="L601">    <span class="tok-kw">var</span> bytes: [hex.len / <span class="tok-number">2</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L602">    _ = <span class="tok-kw">try</span> fmt.hexToBytes(&amp;bytes, hex);</span>
<span class="line" id="L603"></span>
<span class="line" id="L604">    <span class="tok-kw">try</span> std.testing.expectEqualSlices(<span class="tok-type">u8</span>, &amp;bytes, &amp;dk);</span>
<span class="line" id="L605">}</span>
<span class="line" id="L606"></span>
<span class="line" id="L607"><span class="tok-kw">test</span> <span class="tok-str">&quot;kdf rfc 4&quot;</span> {</span>
<span class="line" id="L608">    <span class="tok-kw">if</span> (!run_long_tests) <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SkipZigTest;</span>
<span class="line" id="L609"></span>
<span class="line" id="L610">    <span class="tok-kw">const</span> password = <span class="tok-str">&quot;pleaseletmein&quot;</span>;</span>
<span class="line" id="L611">    <span class="tok-kw">const</span> salt = <span class="tok-str">&quot;SodiumChloride&quot;</span>;</span>
<span class="line" id="L612"></span>
<span class="line" id="L613">    <span class="tok-kw">var</span> dk: [<span class="tok-number">64</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L614">    <span class="tok-kw">try</span> kdf(std.testing.allocator, &amp;dk, password, salt, .{ .ln = <span class="tok-number">20</span>, .r = <span class="tok-number">8</span>, .p = <span class="tok-number">1</span> });</span>
<span class="line" id="L615"></span>
<span class="line" id="L616">    <span class="tok-kw">const</span> hex = <span class="tok-str">&quot;2101cb9b6a511aaeaddbbe09cf70f881ec568d574a2ffd4dabe5ee9820adaa478e56fd8f4ba5d09ffa1c6d927c40f4c337304049e8a952fbcbf45c6fa77a41a4&quot;</span>;</span>
<span class="line" id="L617">    <span class="tok-kw">var</span> bytes: [hex.len / <span class="tok-number">2</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L618">    _ = <span class="tok-kw">try</span> fmt.hexToBytes(&amp;bytes, hex);</span>
<span class="line" id="L619"></span>
<span class="line" id="L620">    <span class="tok-kw">try</span> std.testing.expectEqualSlices(<span class="tok-type">u8</span>, &amp;bytes, &amp;dk);</span>
<span class="line" id="L621">}</span>
<span class="line" id="L622"></span>
<span class="line" id="L623"><span class="tok-kw">test</span> <span class="tok-str">&quot;password hashing (crypt format)&quot;</span> {</span>
<span class="line" id="L624">    <span class="tok-kw">if</span> (!run_long_tests) <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SkipZigTest;</span>
<span class="line" id="L625"></span>
<span class="line" id="L626">    <span class="tok-kw">const</span> alloc = std.testing.allocator;</span>
<span class="line" id="L627"></span>
<span class="line" id="L628">    <span class="tok-kw">const</span> str = <span class="tok-str">&quot;$7$A6....1....TrXs5Zk6s8sWHpQgWDIXTR8kUU3s6Jc3s.DtdS8M2i4$a4ik5hGDN7foMuHOW.cp.CtX01UyCeO0.JAG.AHPpx5&quot;</span>;</span>
<span class="line" id="L629">    <span class="tok-kw">const</span> password = <span class="tok-str">&quot;Y0!?iQa9M%5ekffW(`&quot;</span>;</span>
<span class="line" id="L630">    <span class="tok-kw">try</span> CryptFormatHasher.verify(alloc, str, password);</span>
<span class="line" id="L631"></span>
<span class="line" id="L632">    <span class="tok-kw">const</span> params = Params.interactive;</span>
<span class="line" id="L633">    <span class="tok-kw">var</span> buf: [CryptFormatHasher.pwhash_str_length]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L634">    <span class="tok-kw">const</span> str2 = <span class="tok-kw">try</span> CryptFormatHasher.create(alloc, password, params, &amp;buf);</span>
<span class="line" id="L635">    <span class="tok-kw">try</span> CryptFormatHasher.verify(alloc, str2, password);</span>
<span class="line" id="L636">}</span>
<span class="line" id="L637"></span>
<span class="line" id="L638"><span class="tok-kw">test</span> <span class="tok-str">&quot;strHash and strVerify&quot;</span> {</span>
<span class="line" id="L639">    <span class="tok-kw">if</span> (!run_long_tests) <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SkipZigTest;</span>
<span class="line" id="L640"></span>
<span class="line" id="L641">    <span class="tok-kw">const</span> alloc = std.testing.allocator;</span>
<span class="line" id="L642"></span>
<span class="line" id="L643">    <span class="tok-kw">const</span> password = <span class="tok-str">&quot;testpass&quot;</span>;</span>
<span class="line" id="L644">    <span class="tok-kw">const</span> params = Params.interactive;</span>
<span class="line" id="L645">    <span class="tok-kw">const</span> verify_options = VerifyOptions{ .allocator = alloc };</span>
<span class="line" id="L646">    <span class="tok-kw">var</span> buf: [<span class="tok-number">128</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L647"></span>
<span class="line" id="L648">    {</span>
<span class="line" id="L649">        <span class="tok-kw">const</span> str = <span class="tok-kw">try</span> strHash(</span>
<span class="line" id="L650">            password,</span>
<span class="line" id="L651">            .{ .allocator = alloc, .params = params, .encoding = .crypt },</span>
<span class="line" id="L652">            &amp;buf,</span>
<span class="line" id="L653">        );</span>
<span class="line" id="L654">        <span class="tok-kw">try</span> strVerify(str, password, verify_options);</span>
<span class="line" id="L655">    }</span>
<span class="line" id="L656">    {</span>
<span class="line" id="L657">        <span class="tok-kw">const</span> str = <span class="tok-kw">try</span> strHash(</span>
<span class="line" id="L658">            password,</span>
<span class="line" id="L659">            .{ .allocator = alloc, .params = params, .encoding = .phc },</span>
<span class="line" id="L660">            &amp;buf,</span>
<span class="line" id="L661">        );</span>
<span class="line" id="L662">        <span class="tok-kw">try</span> strVerify(str, password, verify_options);</span>
<span class="line" id="L663">    }</span>
<span class="line" id="L664">}</span>
<span class="line" id="L665"></span>
<span class="line" id="L666"><span class="tok-kw">test</span> <span class="tok-str">&quot;unix-scrypt&quot;</span> {</span>
<span class="line" id="L667">    <span class="tok-kw">if</span> (!run_long_tests) <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SkipZigTest;</span>
<span class="line" id="L668"></span>
<span class="line" id="L669">    <span class="tok-kw">const</span> alloc = std.testing.allocator;</span>
<span class="line" id="L670"></span>
<span class="line" id="L671">    <span class="tok-comment">// https://gitlab.com/jas/scrypt-unix-crypt/blob/master/unix-scrypt.txt</span>
</span>
<span class="line" id="L672">    {</span>
<span class="line" id="L673">        <span class="tok-kw">const</span> str = <span class="tok-str">&quot;$7$C6..../....SodiumChloride$kBGj9fHznVYFQMEn/qDCfrDevf9YDtcDdKvEqHJLV8D&quot;</span>;</span>
<span class="line" id="L674">        <span class="tok-kw">const</span> password = <span class="tok-str">&quot;pleaseletmein&quot;</span>;</span>
<span class="line" id="L675">        <span class="tok-kw">try</span> strVerify(str, password, .{ .allocator = alloc });</span>
<span class="line" id="L676">    }</span>
<span class="line" id="L677">    <span class="tok-comment">// one of the libsodium test vectors</span>
</span>
<span class="line" id="L678">    {</span>
<span class="line" id="L679">        <span class="tok-kw">const</span> str = <span class="tok-str">&quot;$7$B6....1....75gBMAGwfFWZqBdyF3WdTQnWdUsuTiWjG1fF9c1jiSD$tc8RoB3.Em3/zNgMLWo2u00oGIoTyJv4fl3Fl8Tix72&quot;</span>;</span>
<span class="line" id="L680">        <span class="tok-kw">const</span> password = <span class="tok-str">&quot;^T5H$JYt39n%K*j:W]!1s?vg!:jGi]Ax?..l7[p0v:1jHTpla9;]bUN;?bWyCbtqg nrDFal+Jxl3,2`#^tFSu%v_+7iYse8-cCkNf!tD=KrW)&quot;</span>;</span>
<span class="line" id="L681">        <span class="tok-kw">try</span> strVerify(str, password, .{ .allocator = alloc });</span>
<span class="line" id="L682">    }</span>
<span class="line" id="L683">}</span>
<span class="line" id="L684"></span>
<span class="line" id="L685"><span class="tok-kw">test</span> <span class="tok-str">&quot;crypt format&quot;</span> {</span>
<span class="line" id="L686">    <span class="tok-kw">const</span> str = <span class="tok-str">&quot;$7$C6..../....SodiumChloride$kBGj9fHznVYFQMEn/qDCfrDevf9YDtcDdKvEqHJLV8D&quot;</span>;</span>
<span class="line" id="L687">    <span class="tok-kw">const</span> params = <span class="tok-kw">try</span> crypt_format.deserialize(crypt_format.HashResult(<span class="tok-number">32</span>), str);</span>
<span class="line" id="L688">    <span class="tok-kw">var</span> buf: [str.len]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L689">    <span class="tok-kw">const</span> s1 = <span class="tok-kw">try</span> crypt_format.serialize(params, &amp;buf);</span>
<span class="line" id="L690">    <span class="tok-kw">try</span> std.testing.expectEqualStrings(s1, str);</span>
<span class="line" id="L691">}</span>
<span class="line" id="L692"></span>
<span class="line" id="L693"><span class="tok-kw">test</span> <span class="tok-str">&quot;kdf fast&quot;</span> {</span>
<span class="line" id="L694">    <span class="tok-kw">const</span> TestVector = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L695">        password: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L696">        salt: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L697">        params: Params,</span>
<span class="line" id="L698">        want: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L699">    };</span>
<span class="line" id="L700">    <span class="tok-kw">const</span> test_vectors = [_]TestVector{</span>
<span class="line" id="L701">        .{</span>
<span class="line" id="L702">            .password = <span class="tok-str">&quot;p&quot;</span>,</span>
<span class="line" id="L703">            .salt = <span class="tok-str">&quot;s&quot;</span>,</span>
<span class="line" id="L704">            .params = .{ .ln = <span class="tok-number">1</span>, .r = <span class="tok-number">1</span>, .p = <span class="tok-number">1</span> },</span>
<span class="line" id="L705">            .want = &amp;([_]<span class="tok-type">u8</span>{</span>
<span class="line" id="L706">                <span class="tok-number">0x48</span>, <span class="tok-number">0xb0</span>, <span class="tok-number">0xd2</span>, <span class="tok-number">0xa8</span>, <span class="tok-number">0xa3</span>, <span class="tok-number">0x27</span>, <span class="tok-number">0x26</span>, <span class="tok-number">0x11</span>,</span>
<span class="line" id="L707">                <span class="tok-number">0x98</span>, <span class="tok-number">0x4c</span>, <span class="tok-number">0x50</span>, <span class="tok-number">0xeb</span>, <span class="tok-number">0xd6</span>, <span class="tok-number">0x30</span>, <span class="tok-number">0xaf</span>, <span class="tok-number">0x52</span>,</span>
<span class="line" id="L708">            }),</span>
<span class="line" id="L709">        },</span>
<span class="line" id="L710">    };</span>
<span class="line" id="L711">    <span class="tok-kw">inline</span> <span class="tok-kw">for</span> (test_vectors) |v| {</span>
<span class="line" id="L712">        <span class="tok-kw">var</span> dk: [v.want.len]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L713">        <span class="tok-kw">try</span> kdf(std.testing.allocator, &amp;dk, v.password, v.salt, v.params);</span>
<span class="line" id="L714">        <span class="tok-kw">try</span> std.testing.expectEqualSlices(<span class="tok-type">u8</span>, &amp;dk, v.want);</span>
<span class="line" id="L715">    }</span>
<span class="line" id="L716">}</span>
<span class="line" id="L717"></span>
</code></pre></body>
</html>