<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">    <title>math/atan2.zig - source view</title>
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
<pre><code><span class="line" id="L1"><span class="tok-comment">// Ported from musl, which is licensed under the MIT license:</span>
</span>
<span class="line" id="L2"><span class="tok-comment">// https://git.musl-libc.org/cgit/musl/tree/COPYRIGHT</span>
</span>
<span class="line" id="L3"><span class="tok-comment">//</span>
</span>
<span class="line" id="L4"><span class="tok-comment">// https://git.musl-libc.org/cgit/musl/tree/src/math/atan2f.c</span>
</span>
<span class="line" id="L5"><span class="tok-comment">// https://git.musl-libc.org/cgit/musl/tree/src/math/atan2.c</span>
</span>
<span class="line" id="L6"></span>
<span class="line" id="L7"><span class="tok-kw">const</span> std = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;../std.zig&quot;</span>);</span>
<span class="line" id="L8"><span class="tok-kw">const</span> math = std.math;</span>
<span class="line" id="L9"><span class="tok-kw">const</span> expect = std.testing.expect;</span>
<span class="line" id="L10"></span>
<span class="line" id="L11"><span class="tok-comment">/// Returns the arc-tangent of y/x.</span></span>
<span class="line" id="L12"><span class="tok-comment">///</span></span>
<span class="line" id="L13"><span class="tok-comment">/// Special Cases:</span></span>
<span class="line" id="L14"><span class="tok-comment">///  - atan2(y, nan)     = nan</span></span>
<span class="line" id="L15"><span class="tok-comment">///  - atan2(nan, x)     = nan</span></span>
<span class="line" id="L16"><span class="tok-comment">///  - atan2(+0, x&gt;=0)   = +0</span></span>
<span class="line" id="L17"><span class="tok-comment">///  - atan2(-0, x&gt;=0)   = -0</span></span>
<span class="line" id="L18"><span class="tok-comment">///  - atan2(+0, x&lt;=-0)  = +pi</span></span>
<span class="line" id="L19"><span class="tok-comment">///  - atan2(-0, x&lt;=-0)  = -pi</span></span>
<span class="line" id="L20"><span class="tok-comment">///  - atan2(y&gt;0, 0)     = +pi/2</span></span>
<span class="line" id="L21"><span class="tok-comment">///  - atan2(y&lt;0, 0)     = -pi/2</span></span>
<span class="line" id="L22"><span class="tok-comment">///  - atan2(+inf, +inf) = +pi/4</span></span>
<span class="line" id="L23"><span class="tok-comment">///  - atan2(-inf, +inf) = -pi/4</span></span>
<span class="line" id="L24"><span class="tok-comment">///  - atan2(+inf, -inf) = 3pi/4</span></span>
<span class="line" id="L25"><span class="tok-comment">///  - atan2(-inf, -inf) = -3pi/4</span></span>
<span class="line" id="L26"><span class="tok-comment">///  - atan2(y, +inf)    = 0</span></span>
<span class="line" id="L27"><span class="tok-comment">///  - atan2(y&gt;0, -inf)  = +pi</span></span>
<span class="line" id="L28"><span class="tok-comment">///  - atan2(y&lt;0, -inf)  = -pi</span></span>
<span class="line" id="L29"><span class="tok-comment">///  - atan2(+inf, x)    = +pi/2</span></span>
<span class="line" id="L30"><span class="tok-comment">///  - atan2(-inf, x)    = -pi/2</span></span>
<span class="line" id="L31"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">atan2</span>(<span class="tok-kw">comptime</span> T: <span class="tok-type">type</span>, y: T, x: T) T {</span>
<span class="line" id="L32">    <span class="tok-kw">return</span> <span class="tok-kw">switch</span> (T) {</span>
<span class="line" id="L33">        <span class="tok-type">f32</span> =&gt; atan2_32(y, x),</span>
<span class="line" id="L34">        <span class="tok-type">f64</span> =&gt; atan2_64(y, x),</span>
<span class="line" id="L35">        <span class="tok-kw">else</span> =&gt; <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;atan2 not implemented for &quot;</span> ++ <span class="tok-builtin">@typeName</span>(T)),</span>
<span class="line" id="L36">    };</span>
<span class="line" id="L37">}</span>
<span class="line" id="L38"></span>
<span class="line" id="L39"><span class="tok-kw">fn</span> <span class="tok-fn">atan2_32</span>(y: <span class="tok-type">f32</span>, x: <span class="tok-type">f32</span>) <span class="tok-type">f32</span> {</span>
<span class="line" id="L40">    <span class="tok-kw">const</span> pi: <span class="tok-type">f32</span> = <span class="tok-number">3.1415927410e+00</span>;</span>
<span class="line" id="L41">    <span class="tok-kw">const</span> pi_lo: <span class="tok-type">f32</span> = -<span class="tok-number">8.7422776573e-08</span>;</span>
<span class="line" id="L42"></span>
<span class="line" id="L43">    <span class="tok-kw">if</span> (math.isNan(x) <span class="tok-kw">or</span> math.isNan(y)) {</span>
<span class="line" id="L44">        <span class="tok-kw">return</span> x + y;</span>
<span class="line" id="L45">    }</span>
<span class="line" id="L46"></span>
<span class="line" id="L47">    <span class="tok-kw">var</span> ix = <span class="tok-builtin">@bitCast</span>(<span class="tok-type">u32</span>, x);</span>
<span class="line" id="L48">    <span class="tok-kw">var</span> iy = <span class="tok-builtin">@bitCast</span>(<span class="tok-type">u32</span>, y);</span>
<span class="line" id="L49"></span>
<span class="line" id="L50">    <span class="tok-comment">// x = 1.0</span>
</span>
<span class="line" id="L51">    <span class="tok-kw">if</span> (ix == <span class="tok-number">0x3F800000</span>) {</span>
<span class="line" id="L52">        <span class="tok-kw">return</span> math.atan(y);</span>
<span class="line" id="L53">    }</span>
<span class="line" id="L54"></span>
<span class="line" id="L55">    <span class="tok-comment">// 2 * sign(x) + sign(y)</span>
</span>
<span class="line" id="L56">    <span class="tok-kw">const</span> m = ((iy &gt;&gt; <span class="tok-number">31</span>) &amp; <span class="tok-number">1</span>) | ((ix &gt;&gt; <span class="tok-number">30</span>) &amp; <span class="tok-number">2</span>);</span>
<span class="line" id="L57">    ix &amp;= <span class="tok-number">0x7FFFFFFF</span>;</span>
<span class="line" id="L58">    iy &amp;= <span class="tok-number">0x7FFFFFFF</span>;</span>
<span class="line" id="L59"></span>
<span class="line" id="L60">    <span class="tok-kw">if</span> (iy == <span class="tok-number">0</span>) {</span>
<span class="line" id="L61">        <span class="tok-kw">switch</span> (m) {</span>
<span class="line" id="L62">            <span class="tok-number">0</span>, <span class="tok-number">1</span> =&gt; <span class="tok-kw">return</span> y, <span class="tok-comment">// atan(+-0, +...)</span>
</span>
<span class="line" id="L63">            <span class="tok-number">2</span> =&gt; <span class="tok-kw">return</span> pi, <span class="tok-comment">// atan(+0, -...)</span>
</span>
<span class="line" id="L64">            <span class="tok-number">3</span> =&gt; <span class="tok-kw">return</span> -pi, <span class="tok-comment">// atan(-0, -...)</span>
</span>
<span class="line" id="L65">            <span class="tok-kw">else</span> =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L66">        }</span>
<span class="line" id="L67">    }</span>
<span class="line" id="L68"></span>
<span class="line" id="L69">    <span class="tok-kw">if</span> (ix == <span class="tok-number">0</span>) {</span>
<span class="line" id="L70">        <span class="tok-kw">if</span> (m &amp; <span class="tok-number">1</span> != <span class="tok-number">0</span>) {</span>
<span class="line" id="L71">            <span class="tok-kw">return</span> -pi / <span class="tok-number">2</span>;</span>
<span class="line" id="L72">        } <span class="tok-kw">else</span> {</span>
<span class="line" id="L73">            <span class="tok-kw">return</span> pi / <span class="tok-number">2</span>;</span>
<span class="line" id="L74">        }</span>
<span class="line" id="L75">    }</span>
<span class="line" id="L76"></span>
<span class="line" id="L77">    <span class="tok-kw">if</span> (ix == <span class="tok-number">0x7F800000</span>) {</span>
<span class="line" id="L78">        <span class="tok-kw">if</span> (iy == <span class="tok-number">0x7F800000</span>) {</span>
<span class="line" id="L79">            <span class="tok-kw">switch</span> (m) {</span>
<span class="line" id="L80">                <span class="tok-number">0</span> =&gt; <span class="tok-kw">return</span> pi / <span class="tok-number">4</span>, <span class="tok-comment">// atan(+inf, +inf)</span>
</span>
<span class="line" id="L81">                <span class="tok-number">1</span> =&gt; <span class="tok-kw">return</span> -pi / <span class="tok-number">4</span>, <span class="tok-comment">// atan(-inf, +inf)</span>
</span>
<span class="line" id="L82">                <span class="tok-number">2</span> =&gt; <span class="tok-kw">return</span> <span class="tok-number">3</span> * pi / <span class="tok-number">4</span>, <span class="tok-comment">// atan(+inf, -inf)</span>
</span>
<span class="line" id="L83">                <span class="tok-number">3</span> =&gt; <span class="tok-kw">return</span> -<span class="tok-number">3</span> * pi / <span class="tok-number">4</span>, <span class="tok-comment">// atan(-inf, -inf)</span>
</span>
<span class="line" id="L84">                <span class="tok-kw">else</span> =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L85">            }</span>
<span class="line" id="L86">        } <span class="tok-kw">else</span> {</span>
<span class="line" id="L87">            <span class="tok-kw">switch</span> (m) {</span>
<span class="line" id="L88">                <span class="tok-number">0</span> =&gt; <span class="tok-kw">return</span> <span class="tok-number">0.0</span>, <span class="tok-comment">// atan(+..., +inf)</span>
</span>
<span class="line" id="L89">                <span class="tok-number">1</span> =&gt; <span class="tok-kw">return</span> -<span class="tok-number">0.0</span>, <span class="tok-comment">// atan(-..., +inf)</span>
</span>
<span class="line" id="L90">                <span class="tok-number">2</span> =&gt; <span class="tok-kw">return</span> pi, <span class="tok-comment">// atan(+..., -inf)</span>
</span>
<span class="line" id="L91">                <span class="tok-number">3</span> =&gt; <span class="tok-kw">return</span> -pi, <span class="tok-comment">// atan(-...f, -inf)</span>
</span>
<span class="line" id="L92">                <span class="tok-kw">else</span> =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L93">            }</span>
<span class="line" id="L94">        }</span>
<span class="line" id="L95">    }</span>
<span class="line" id="L96"></span>
<span class="line" id="L97">    <span class="tok-comment">// |y / x| &gt; 0x1p26</span>
</span>
<span class="line" id="L98">    <span class="tok-kw">if</span> (ix + (<span class="tok-number">26</span> &lt;&lt; <span class="tok-number">23</span>) &lt; iy <span class="tok-kw">or</span> iy == <span class="tok-number">0x7F800000</span>) {</span>
<span class="line" id="L99">        <span class="tok-kw">if</span> (m &amp; <span class="tok-number">1</span> != <span class="tok-number">0</span>) {</span>
<span class="line" id="L100">            <span class="tok-kw">return</span> -pi / <span class="tok-number">2</span>;</span>
<span class="line" id="L101">        } <span class="tok-kw">else</span> {</span>
<span class="line" id="L102">            <span class="tok-kw">return</span> pi / <span class="tok-number">2</span>;</span>
<span class="line" id="L103">        }</span>
<span class="line" id="L104">    }</span>
<span class="line" id="L105"></span>
<span class="line" id="L106">    <span class="tok-comment">// z = atan(|y / x|) with correct underflow</span>
</span>
<span class="line" id="L107">    <span class="tok-kw">var</span> z = z: {</span>
<span class="line" id="L108">        <span class="tok-kw">if</span> ((m &amp; <span class="tok-number">2</span>) != <span class="tok-number">0</span> <span class="tok-kw">and</span> iy + (<span class="tok-number">26</span> &lt;&lt; <span class="tok-number">23</span>) &lt; ix) {</span>
<span class="line" id="L109">            <span class="tok-kw">break</span> :z <span class="tok-number">0.0</span>;</span>
<span class="line" id="L110">        } <span class="tok-kw">else</span> {</span>
<span class="line" id="L111">            <span class="tok-kw">break</span> :z math.atan(<span class="tok-builtin">@fabs</span>(y / x));</span>
<span class="line" id="L112">        }</span>
<span class="line" id="L113">    };</span>
<span class="line" id="L114"></span>
<span class="line" id="L115">    <span class="tok-kw">switch</span> (m) {</span>
<span class="line" id="L116">        <span class="tok-number">0</span> =&gt; <span class="tok-kw">return</span> z, <span class="tok-comment">// atan(+, +)</span>
</span>
<span class="line" id="L117">        <span class="tok-number">1</span> =&gt; <span class="tok-kw">return</span> -z, <span class="tok-comment">// atan(-, +)</span>
</span>
<span class="line" id="L118">        <span class="tok-number">2</span> =&gt; <span class="tok-kw">return</span> pi - (z - pi_lo), <span class="tok-comment">// atan(+, -)</span>
</span>
<span class="line" id="L119">        <span class="tok-number">3</span> =&gt; <span class="tok-kw">return</span> (z - pi_lo) - pi, <span class="tok-comment">// atan(-, -)</span>
</span>
<span class="line" id="L120">        <span class="tok-kw">else</span> =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L121">    }</span>
<span class="line" id="L122">}</span>
<span class="line" id="L123"></span>
<span class="line" id="L124"><span class="tok-kw">fn</span> <span class="tok-fn">atan2_64</span>(y: <span class="tok-type">f64</span>, x: <span class="tok-type">f64</span>) <span class="tok-type">f64</span> {</span>
<span class="line" id="L125">    <span class="tok-kw">const</span> pi: <span class="tok-type">f64</span> = <span class="tok-number">3.1415926535897931160E+00</span>;</span>
<span class="line" id="L126">    <span class="tok-kw">const</span> pi_lo: <span class="tok-type">f64</span> = <span class="tok-number">1.2246467991473531772E-16</span>;</span>
<span class="line" id="L127"></span>
<span class="line" id="L128">    <span class="tok-kw">if</span> (math.isNan(x) <span class="tok-kw">or</span> math.isNan(y)) {</span>
<span class="line" id="L129">        <span class="tok-kw">return</span> x + y;</span>
<span class="line" id="L130">    }</span>
<span class="line" id="L131"></span>
<span class="line" id="L132">    <span class="tok-kw">var</span> ux = <span class="tok-builtin">@bitCast</span>(<span class="tok-type">u64</span>, x);</span>
<span class="line" id="L133">    <span class="tok-kw">var</span> ix = <span class="tok-builtin">@intCast</span>(<span class="tok-type">u32</span>, ux &gt;&gt; <span class="tok-number">32</span>);</span>
<span class="line" id="L134">    <span class="tok-kw">var</span> lx = <span class="tok-builtin">@intCast</span>(<span class="tok-type">u32</span>, ux &amp; <span class="tok-number">0xFFFFFFFF</span>);</span>
<span class="line" id="L135"></span>
<span class="line" id="L136">    <span class="tok-kw">var</span> uy = <span class="tok-builtin">@bitCast</span>(<span class="tok-type">u64</span>, y);</span>
<span class="line" id="L137">    <span class="tok-kw">var</span> iy = <span class="tok-builtin">@intCast</span>(<span class="tok-type">u32</span>, uy &gt;&gt; <span class="tok-number">32</span>);</span>
<span class="line" id="L138">    <span class="tok-kw">var</span> ly = <span class="tok-builtin">@intCast</span>(<span class="tok-type">u32</span>, uy &amp; <span class="tok-number">0xFFFFFFFF</span>);</span>
<span class="line" id="L139"></span>
<span class="line" id="L140">    <span class="tok-comment">// x = 1.0</span>
</span>
<span class="line" id="L141">    <span class="tok-kw">if</span> ((ix -% <span class="tok-number">0x3FF00000</span>) | lx == <span class="tok-number">0</span>) {</span>
<span class="line" id="L142">        <span class="tok-kw">return</span> math.atan(y);</span>
<span class="line" id="L143">    }</span>
<span class="line" id="L144"></span>
<span class="line" id="L145">    <span class="tok-comment">// 2 * sign(x) + sign(y)</span>
</span>
<span class="line" id="L146">    <span class="tok-kw">const</span> m = ((iy &gt;&gt; <span class="tok-number">31</span>) &amp; <span class="tok-number">1</span>) | ((ix &gt;&gt; <span class="tok-number">30</span>) &amp; <span class="tok-number">2</span>);</span>
<span class="line" id="L147">    ix &amp;= <span class="tok-number">0x7FFFFFFF</span>;</span>
<span class="line" id="L148">    iy &amp;= <span class="tok-number">0x7FFFFFFF</span>;</span>
<span class="line" id="L149"></span>
<span class="line" id="L150">    <span class="tok-kw">if</span> (iy | ly == <span class="tok-number">0</span>) {</span>
<span class="line" id="L151">        <span class="tok-kw">switch</span> (m) {</span>
<span class="line" id="L152">            <span class="tok-number">0</span>, <span class="tok-number">1</span> =&gt; <span class="tok-kw">return</span> y, <span class="tok-comment">// atan(+-0, +...)</span>
</span>
<span class="line" id="L153">            <span class="tok-number">2</span> =&gt; <span class="tok-kw">return</span> pi, <span class="tok-comment">// atan(+0, -...)</span>
</span>
<span class="line" id="L154">            <span class="tok-number">3</span> =&gt; <span class="tok-kw">return</span> -pi, <span class="tok-comment">// atan(-0, -...)</span>
</span>
<span class="line" id="L155">            <span class="tok-kw">else</span> =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L156">        }</span>
<span class="line" id="L157">    }</span>
<span class="line" id="L158"></span>
<span class="line" id="L159">    <span class="tok-kw">if</span> (ix | lx == <span class="tok-number">0</span>) {</span>
<span class="line" id="L160">        <span class="tok-kw">if</span> (m &amp; <span class="tok-number">1</span> != <span class="tok-number">0</span>) {</span>
<span class="line" id="L161">            <span class="tok-kw">return</span> -pi / <span class="tok-number">2</span>;</span>
<span class="line" id="L162">        } <span class="tok-kw">else</span> {</span>
<span class="line" id="L163">            <span class="tok-kw">return</span> pi / <span class="tok-number">2</span>;</span>
<span class="line" id="L164">        }</span>
<span class="line" id="L165">    }</span>
<span class="line" id="L166"></span>
<span class="line" id="L167">    <span class="tok-kw">if</span> (ix == <span class="tok-number">0x7FF00000</span>) {</span>
<span class="line" id="L168">        <span class="tok-kw">if</span> (iy == <span class="tok-number">0x7FF00000</span>) {</span>
<span class="line" id="L169">            <span class="tok-kw">switch</span> (m) {</span>
<span class="line" id="L170">                <span class="tok-number">0</span> =&gt; <span class="tok-kw">return</span> pi / <span class="tok-number">4</span>, <span class="tok-comment">// atan(+inf, +inf)</span>
</span>
<span class="line" id="L171">                <span class="tok-number">1</span> =&gt; <span class="tok-kw">return</span> -pi / <span class="tok-number">4</span>, <span class="tok-comment">// atan(-inf, +inf)</span>
</span>
<span class="line" id="L172">                <span class="tok-number">2</span> =&gt; <span class="tok-kw">return</span> <span class="tok-number">3</span> * pi / <span class="tok-number">4</span>, <span class="tok-comment">// atan(+inf, -inf)</span>
</span>
<span class="line" id="L173">                <span class="tok-number">3</span> =&gt; <span class="tok-kw">return</span> -<span class="tok-number">3</span> * pi / <span class="tok-number">4</span>, <span class="tok-comment">// atan(-inf, -inf)</span>
</span>
<span class="line" id="L174">                <span class="tok-kw">else</span> =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L175">            }</span>
<span class="line" id="L176">        } <span class="tok-kw">else</span> {</span>
<span class="line" id="L177">            <span class="tok-kw">switch</span> (m) {</span>
<span class="line" id="L178">                <span class="tok-number">0</span> =&gt; <span class="tok-kw">return</span> <span class="tok-number">0.0</span>, <span class="tok-comment">// atan(+..., +inf)</span>
</span>
<span class="line" id="L179">                <span class="tok-number">1</span> =&gt; <span class="tok-kw">return</span> -<span class="tok-number">0.0</span>, <span class="tok-comment">// atan(-..., +inf)</span>
</span>
<span class="line" id="L180">                <span class="tok-number">2</span> =&gt; <span class="tok-kw">return</span> pi, <span class="tok-comment">// atan(+..., -inf)</span>
</span>
<span class="line" id="L181">                <span class="tok-number">3</span> =&gt; <span class="tok-kw">return</span> -pi, <span class="tok-comment">// atan(-...f, -inf)</span>
</span>
<span class="line" id="L182">                <span class="tok-kw">else</span> =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L183">            }</span>
<span class="line" id="L184">        }</span>
<span class="line" id="L185">    }</span>
<span class="line" id="L186"></span>
<span class="line" id="L187">    <span class="tok-comment">// |y / x| &gt; 0x1p64</span>
</span>
<span class="line" id="L188">    <span class="tok-kw">if</span> (ix +% (<span class="tok-number">64</span> &lt;&lt; <span class="tok-number">20</span>) &lt; iy <span class="tok-kw">or</span> iy == <span class="tok-number">0x7FF00000</span>) {</span>
<span class="line" id="L189">        <span class="tok-kw">if</span> (m &amp; <span class="tok-number">1</span> != <span class="tok-number">0</span>) {</span>
<span class="line" id="L190">            <span class="tok-kw">return</span> -pi / <span class="tok-number">2</span>;</span>
<span class="line" id="L191">        } <span class="tok-kw">else</span> {</span>
<span class="line" id="L192">            <span class="tok-kw">return</span> pi / <span class="tok-number">2</span>;</span>
<span class="line" id="L193">        }</span>
<span class="line" id="L194">    }</span>
<span class="line" id="L195"></span>
<span class="line" id="L196">    <span class="tok-comment">// z = atan(|y / x|) with correct underflow</span>
</span>
<span class="line" id="L197">    <span class="tok-kw">var</span> z = z: {</span>
<span class="line" id="L198">        <span class="tok-kw">if</span> ((m &amp; <span class="tok-number">2</span>) != <span class="tok-number">0</span> <span class="tok-kw">and</span> iy +% (<span class="tok-number">64</span> &lt;&lt; <span class="tok-number">20</span>) &lt; ix) {</span>
<span class="line" id="L199">            <span class="tok-kw">break</span> :z <span class="tok-number">0.0</span>;</span>
<span class="line" id="L200">        } <span class="tok-kw">else</span> {</span>
<span class="line" id="L201">            <span class="tok-kw">break</span> :z math.atan(<span class="tok-builtin">@fabs</span>(y / x));</span>
<span class="line" id="L202">        }</span>
<span class="line" id="L203">    };</span>
<span class="line" id="L204"></span>
<span class="line" id="L205">    <span class="tok-kw">switch</span> (m) {</span>
<span class="line" id="L206">        <span class="tok-number">0</span> =&gt; <span class="tok-kw">return</span> z, <span class="tok-comment">// atan(+, +)</span>
</span>
<span class="line" id="L207">        <span class="tok-number">1</span> =&gt; <span class="tok-kw">return</span> -z, <span class="tok-comment">// atan(-, +)</span>
</span>
<span class="line" id="L208">        <span class="tok-number">2</span> =&gt; <span class="tok-kw">return</span> pi - (z - pi_lo), <span class="tok-comment">// atan(+, -)</span>
</span>
<span class="line" id="L209">        <span class="tok-number">3</span> =&gt; <span class="tok-kw">return</span> (z - pi_lo) - pi, <span class="tok-comment">// atan(-, -)</span>
</span>
<span class="line" id="L210">        <span class="tok-kw">else</span> =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L211">    }</span>
<span class="line" id="L212">}</span>
<span class="line" id="L213"></span>
<span class="line" id="L214"><span class="tok-kw">test</span> <span class="tok-str">&quot;math.atan2&quot;</span> {</span>
<span class="line" id="L215">    <span class="tok-kw">try</span> expect(atan2(<span class="tok-type">f32</span>, <span class="tok-number">0.2</span>, <span class="tok-number">0.21</span>) == atan2_32(<span class="tok-number">0.2</span>, <span class="tok-number">0.21</span>));</span>
<span class="line" id="L216">    <span class="tok-kw">try</span> expect(atan2(<span class="tok-type">f64</span>, <span class="tok-number">0.2</span>, <span class="tok-number">0.21</span>) == atan2_64(<span class="tok-number">0.2</span>, <span class="tok-number">0.21</span>));</span>
<span class="line" id="L217">}</span>
<span class="line" id="L218"></span>
<span class="line" id="L219"><span class="tok-kw">test</span> <span class="tok-str">&quot;math.atan2_32&quot;</span> {</span>
<span class="line" id="L220">    <span class="tok-kw">const</span> epsilon = <span class="tok-number">0.000001</span>;</span>
<span class="line" id="L221"></span>
<span class="line" id="L222">    <span class="tok-kw">try</span> expect(math.approxEqAbs(<span class="tok-type">f32</span>, atan2_32(<span class="tok-number">0.0</span>, <span class="tok-number">0.0</span>), <span class="tok-number">0.0</span>, epsilon));</span>
<span class="line" id="L223">    <span class="tok-kw">try</span> expect(math.approxEqAbs(<span class="tok-type">f32</span>, atan2_32(<span class="tok-number">0.2</span>, <span class="tok-number">0.2</span>), <span class="tok-number">0.785398</span>, epsilon));</span>
<span class="line" id="L224">    <span class="tok-kw">try</span> expect(math.approxEqAbs(<span class="tok-type">f32</span>, atan2_32(-<span class="tok-number">0.2</span>, <span class="tok-number">0.2</span>), -<span class="tok-number">0.785398</span>, epsilon));</span>
<span class="line" id="L225">    <span class="tok-kw">try</span> expect(math.approxEqAbs(<span class="tok-type">f32</span>, atan2_32(<span class="tok-number">0.2</span>, -<span class="tok-number">0.2</span>), <span class="tok-number">2.356194</span>, epsilon));</span>
<span class="line" id="L226">    <span class="tok-kw">try</span> expect(math.approxEqAbs(<span class="tok-type">f32</span>, atan2_32(-<span class="tok-number">0.2</span>, -<span class="tok-number">0.2</span>), -<span class="tok-number">2.356194</span>, epsilon));</span>
<span class="line" id="L227">    <span class="tok-kw">try</span> expect(math.approxEqAbs(<span class="tok-type">f32</span>, atan2_32(<span class="tok-number">0.34</span>, -<span class="tok-number">0.4</span>), <span class="tok-number">2.437099</span>, epsilon));</span>
<span class="line" id="L228">    <span class="tok-kw">try</span> expect(math.approxEqAbs(<span class="tok-type">f32</span>, atan2_32(<span class="tok-number">0.34</span>, <span class="tok-number">1.243</span>), <span class="tok-number">0.267001</span>, epsilon));</span>
<span class="line" id="L229">}</span>
<span class="line" id="L230"></span>
<span class="line" id="L231"><span class="tok-kw">test</span> <span class="tok-str">&quot;math.atan2_64&quot;</span> {</span>
<span class="line" id="L232">    <span class="tok-kw">const</span> epsilon = <span class="tok-number">0.000001</span>;</span>
<span class="line" id="L233"></span>
<span class="line" id="L234">    <span class="tok-kw">try</span> expect(math.approxEqAbs(<span class="tok-type">f64</span>, atan2_64(<span class="tok-number">0.0</span>, <span class="tok-number">0.0</span>), <span class="tok-number">0.0</span>, epsilon));</span>
<span class="line" id="L235">    <span class="tok-kw">try</span> expect(math.approxEqAbs(<span class="tok-type">f64</span>, atan2_64(<span class="tok-number">0.2</span>, <span class="tok-number">0.2</span>), <span class="tok-number">0.785398</span>, epsilon));</span>
<span class="line" id="L236">    <span class="tok-kw">try</span> expect(math.approxEqAbs(<span class="tok-type">f64</span>, atan2_64(-<span class="tok-number">0.2</span>, <span class="tok-number">0.2</span>), -<span class="tok-number">0.785398</span>, epsilon));</span>
<span class="line" id="L237">    <span class="tok-kw">try</span> expect(math.approxEqAbs(<span class="tok-type">f64</span>, atan2_64(<span class="tok-number">0.2</span>, -<span class="tok-number">0.2</span>), <span class="tok-number">2.356194</span>, epsilon));</span>
<span class="line" id="L238">    <span class="tok-kw">try</span> expect(math.approxEqAbs(<span class="tok-type">f64</span>, atan2_64(-<span class="tok-number">0.2</span>, -<span class="tok-number">0.2</span>), -<span class="tok-number">2.356194</span>, epsilon));</span>
<span class="line" id="L239">    <span class="tok-kw">try</span> expect(math.approxEqAbs(<span class="tok-type">f64</span>, atan2_64(<span class="tok-number">0.34</span>, -<span class="tok-number">0.4</span>), <span class="tok-number">2.437099</span>, epsilon));</span>
<span class="line" id="L240">    <span class="tok-kw">try</span> expect(math.approxEqAbs(<span class="tok-type">f64</span>, atan2_64(<span class="tok-number">0.34</span>, <span class="tok-number">1.243</span>), <span class="tok-number">0.267001</span>, epsilon));</span>
<span class="line" id="L241">}</span>
<span class="line" id="L242"></span>
<span class="line" id="L243"><span class="tok-kw">test</span> <span class="tok-str">&quot;math.atan2_32.special&quot;</span> {</span>
<span class="line" id="L244">    <span class="tok-kw">const</span> epsilon = <span class="tok-number">0.000001</span>;</span>
<span class="line" id="L245"></span>
<span class="line" id="L246">    <span class="tok-kw">try</span> expect(math.isNan(atan2_32(<span class="tok-number">1.0</span>, math.nan(<span class="tok-type">f32</span>))));</span>
<span class="line" id="L247">    <span class="tok-kw">try</span> expect(math.isNan(atan2_32(math.nan(<span class="tok-type">f32</span>), <span class="tok-number">1.0</span>)));</span>
<span class="line" id="L248">    <span class="tok-kw">try</span> expect(atan2_32(<span class="tok-number">0.0</span>, <span class="tok-number">5.0</span>) == <span class="tok-number">0.0</span>);</span>
<span class="line" id="L249">    <span class="tok-kw">try</span> expect(atan2_32(-<span class="tok-number">0.0</span>, <span class="tok-number">5.0</span>) == -<span class="tok-number">0.0</span>);</span>
<span class="line" id="L250">    <span class="tok-kw">try</span> expect(math.approxEqAbs(<span class="tok-type">f32</span>, atan2_32(<span class="tok-number">0.0</span>, -<span class="tok-number">5.0</span>), math.pi, epsilon));</span>
<span class="line" id="L251">    <span class="tok-comment">//expect(math.approxEqAbs(f32, atan2_32(-0.0, -5.0), -math.pi, .{.rel=0,.abs=epsilon})); TODO support negative zero?</span>
</span>
<span class="line" id="L252">    <span class="tok-kw">try</span> expect(math.approxEqAbs(<span class="tok-type">f32</span>, atan2_32(<span class="tok-number">1.0</span>, <span class="tok-number">0.0</span>), math.pi / <span class="tok-number">2.0</span>, epsilon));</span>
<span class="line" id="L253">    <span class="tok-kw">try</span> expect(math.approxEqAbs(<span class="tok-type">f32</span>, atan2_32(<span class="tok-number">1.0</span>, -<span class="tok-number">0.0</span>), math.pi / <span class="tok-number">2.0</span>, epsilon));</span>
<span class="line" id="L254">    <span class="tok-kw">try</span> expect(math.approxEqAbs(<span class="tok-type">f32</span>, atan2_32(-<span class="tok-number">1.0</span>, <span class="tok-number">0.0</span>), -math.pi / <span class="tok-number">2.0</span>, epsilon));</span>
<span class="line" id="L255">    <span class="tok-kw">try</span> expect(math.approxEqAbs(<span class="tok-type">f32</span>, atan2_32(-<span class="tok-number">1.0</span>, -<span class="tok-number">0.0</span>), -math.pi / <span class="tok-number">2.0</span>, epsilon));</span>
<span class="line" id="L256">    <span class="tok-kw">try</span> expect(math.approxEqAbs(<span class="tok-type">f32</span>, atan2_32(math.inf(<span class="tok-type">f32</span>), math.inf(<span class="tok-type">f32</span>)), math.pi / <span class="tok-number">4.0</span>, epsilon));</span>
<span class="line" id="L257">    <span class="tok-kw">try</span> expect(math.approxEqAbs(<span class="tok-type">f32</span>, atan2_32(-math.inf(<span class="tok-type">f32</span>), math.inf(<span class="tok-type">f32</span>)), -math.pi / <span class="tok-number">4.0</span>, epsilon));</span>
<span class="line" id="L258">    <span class="tok-kw">try</span> expect(math.approxEqAbs(<span class="tok-type">f32</span>, atan2_32(math.inf(<span class="tok-type">f32</span>), -math.inf(<span class="tok-type">f32</span>)), <span class="tok-number">3.0</span> * math.pi / <span class="tok-number">4.0</span>, epsilon));</span>
<span class="line" id="L259">    <span class="tok-kw">try</span> expect(math.approxEqAbs(<span class="tok-type">f32</span>, atan2_32(-math.inf(<span class="tok-type">f32</span>), -math.inf(<span class="tok-type">f32</span>)), -<span class="tok-number">3.0</span> * math.pi / <span class="tok-number">4.0</span>, epsilon));</span>
<span class="line" id="L260">    <span class="tok-kw">try</span> expect(atan2_32(<span class="tok-number">1.0</span>, math.inf(<span class="tok-type">f32</span>)) == <span class="tok-number">0.0</span>);</span>
<span class="line" id="L261">    <span class="tok-kw">try</span> expect(math.approxEqAbs(<span class="tok-type">f32</span>, atan2_32(<span class="tok-number">1.0</span>, -math.inf(<span class="tok-type">f32</span>)), math.pi, epsilon));</span>
<span class="line" id="L262">    <span class="tok-kw">try</span> expect(math.approxEqAbs(<span class="tok-type">f32</span>, atan2_32(-<span class="tok-number">1.0</span>, -math.inf(<span class="tok-type">f32</span>)), -math.pi, epsilon));</span>
<span class="line" id="L263">    <span class="tok-kw">try</span> expect(math.approxEqAbs(<span class="tok-type">f32</span>, atan2_32(math.inf(<span class="tok-type">f32</span>), <span class="tok-number">1.0</span>), math.pi / <span class="tok-number">2.0</span>, epsilon));</span>
<span class="line" id="L264">    <span class="tok-kw">try</span> expect(math.approxEqAbs(<span class="tok-type">f32</span>, atan2_32(-math.inf(<span class="tok-type">f32</span>), <span class="tok-number">1.0</span>), -math.pi / <span class="tok-number">2.0</span>, epsilon));</span>
<span class="line" id="L265">}</span>
<span class="line" id="L266"></span>
<span class="line" id="L267"><span class="tok-kw">test</span> <span class="tok-str">&quot;math.atan2_64.special&quot;</span> {</span>
<span class="line" id="L268">    <span class="tok-kw">const</span> epsilon = <span class="tok-number">0.000001</span>;</span>
<span class="line" id="L269"></span>
<span class="line" id="L270">    <span class="tok-kw">try</span> expect(math.isNan(atan2_64(<span class="tok-number">1.0</span>, math.nan(<span class="tok-type">f64</span>))));</span>
<span class="line" id="L271">    <span class="tok-kw">try</span> expect(math.isNan(atan2_64(math.nan(<span class="tok-type">f64</span>), <span class="tok-number">1.0</span>)));</span>
<span class="line" id="L272">    <span class="tok-kw">try</span> expect(atan2_64(<span class="tok-number">0.0</span>, <span class="tok-number">5.0</span>) == <span class="tok-number">0.0</span>);</span>
<span class="line" id="L273">    <span class="tok-kw">try</span> expect(atan2_64(-<span class="tok-number">0.0</span>, <span class="tok-number">5.0</span>) == -<span class="tok-number">0.0</span>);</span>
<span class="line" id="L274">    <span class="tok-kw">try</span> expect(math.approxEqAbs(<span class="tok-type">f64</span>, atan2_64(<span class="tok-number">0.0</span>, -<span class="tok-number">5.0</span>), math.pi, epsilon));</span>
<span class="line" id="L275">    <span class="tok-comment">//expect(math.approxEqAbs(f64, atan2_64(-0.0, -5.0), -math.pi, .{.rel=0,.abs=epsilon})); TODO support negative zero?</span>
</span>
<span class="line" id="L276">    <span class="tok-kw">try</span> expect(math.approxEqAbs(<span class="tok-type">f64</span>, atan2_64(<span class="tok-number">1.0</span>, <span class="tok-number">0.0</span>), math.pi / <span class="tok-number">2.0</span>, epsilon));</span>
<span class="line" id="L277">    <span class="tok-kw">try</span> expect(math.approxEqAbs(<span class="tok-type">f64</span>, atan2_64(<span class="tok-number">1.0</span>, -<span class="tok-number">0.0</span>), math.pi / <span class="tok-number">2.0</span>, epsilon));</span>
<span class="line" id="L278">    <span class="tok-kw">try</span> expect(math.approxEqAbs(<span class="tok-type">f64</span>, atan2_64(-<span class="tok-number">1.0</span>, <span class="tok-number">0.0</span>), -math.pi / <span class="tok-number">2.0</span>, epsilon));</span>
<span class="line" id="L279">    <span class="tok-kw">try</span> expect(math.approxEqAbs(<span class="tok-type">f64</span>, atan2_64(-<span class="tok-number">1.0</span>, -<span class="tok-number">0.0</span>), -math.pi / <span class="tok-number">2.0</span>, epsilon));</span>
<span class="line" id="L280">    <span class="tok-kw">try</span> expect(math.approxEqAbs(<span class="tok-type">f64</span>, atan2_64(math.inf(<span class="tok-type">f64</span>), math.inf(<span class="tok-type">f64</span>)), math.pi / <span class="tok-number">4.0</span>, epsilon));</span>
<span class="line" id="L281">    <span class="tok-kw">try</span> expect(math.approxEqAbs(<span class="tok-type">f64</span>, atan2_64(-math.inf(<span class="tok-type">f64</span>), math.inf(<span class="tok-type">f64</span>)), -math.pi / <span class="tok-number">4.0</span>, epsilon));</span>
<span class="line" id="L282">    <span class="tok-kw">try</span> expect(math.approxEqAbs(<span class="tok-type">f64</span>, atan2_64(math.inf(<span class="tok-type">f64</span>), -math.inf(<span class="tok-type">f64</span>)), <span class="tok-number">3.0</span> * math.pi / <span class="tok-number">4.0</span>, epsilon));</span>
<span class="line" id="L283">    <span class="tok-kw">try</span> expect(math.approxEqAbs(<span class="tok-type">f64</span>, atan2_64(-math.inf(<span class="tok-type">f64</span>), -math.inf(<span class="tok-type">f64</span>)), -<span class="tok-number">3.0</span> * math.pi / <span class="tok-number">4.0</span>, epsilon));</span>
<span class="line" id="L284">    <span class="tok-kw">try</span> expect(atan2_64(<span class="tok-number">1.0</span>, math.inf(<span class="tok-type">f64</span>)) == <span class="tok-number">0.0</span>);</span>
<span class="line" id="L285">    <span class="tok-kw">try</span> expect(math.approxEqAbs(<span class="tok-type">f64</span>, atan2_64(<span class="tok-number">1.0</span>, -math.inf(<span class="tok-type">f64</span>)), math.pi, epsilon));</span>
<span class="line" id="L286">    <span class="tok-kw">try</span> expect(math.approxEqAbs(<span class="tok-type">f64</span>, atan2_64(-<span class="tok-number">1.0</span>, -math.inf(<span class="tok-type">f64</span>)), -math.pi, epsilon));</span>
<span class="line" id="L287">    <span class="tok-kw">try</span> expect(math.approxEqAbs(<span class="tok-type">f64</span>, atan2_64(math.inf(<span class="tok-type">f64</span>), <span class="tok-number">1.0</span>), math.pi / <span class="tok-number">2.0</span>, epsilon));</span>
<span class="line" id="L288">    <span class="tok-kw">try</span> expect(math.approxEqAbs(<span class="tok-type">f64</span>, atan2_64(-math.inf(<span class="tok-type">f64</span>), <span class="tok-number">1.0</span>), -math.pi / <span class="tok-number">2.0</span>, epsilon));</span>
<span class="line" id="L289">}</span>
<span class="line" id="L290"></span>
</code></pre></body>
</html>