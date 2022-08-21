<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">    <title>math/acos.zig - source view</title>
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
<span class="line" id="L4"><span class="tok-comment">// https://git.musl-libc.org/cgit/musl/tree/src/math/acosf.c</span>
</span>
<span class="line" id="L5"><span class="tok-comment">// https://git.musl-libc.org/cgit/musl/tree/src/math/acos.c</span>
</span>
<span class="line" id="L6"></span>
<span class="line" id="L7"><span class="tok-kw">const</span> std = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;../std.zig&quot;</span>);</span>
<span class="line" id="L8"><span class="tok-kw">const</span> math = std.math;</span>
<span class="line" id="L9"><span class="tok-kw">const</span> expect = std.testing.expect;</span>
<span class="line" id="L10"></span>
<span class="line" id="L11"><span class="tok-comment">/// Returns the arc-cosine of x.</span></span>
<span class="line" id="L12"><span class="tok-comment">///</span></span>
<span class="line" id="L13"><span class="tok-comment">/// Special cases:</span></span>
<span class="line" id="L14"><span class="tok-comment">///  - acos(x)   = nan if x &lt; -1 or x &gt; 1</span></span>
<span class="line" id="L15"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">acos</span>(x: <span class="tok-kw">anytype</span>) <span class="tok-builtin">@TypeOf</span>(x) {</span>
<span class="line" id="L16">    <span class="tok-kw">const</span> T = <span class="tok-builtin">@TypeOf</span>(x);</span>
<span class="line" id="L17">    <span class="tok-kw">return</span> <span class="tok-kw">switch</span> (T) {</span>
<span class="line" id="L18">        <span class="tok-type">f32</span> =&gt; acos32(x),</span>
<span class="line" id="L19">        <span class="tok-type">f64</span> =&gt; acos64(x),</span>
<span class="line" id="L20">        <span class="tok-kw">else</span> =&gt; <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;acos not implemented for &quot;</span> ++ <span class="tok-builtin">@typeName</span>(T)),</span>
<span class="line" id="L21">    };</span>
<span class="line" id="L22">}</span>
<span class="line" id="L23"></span>
<span class="line" id="L24"><span class="tok-kw">fn</span> <span class="tok-fn">r32</span>(z: <span class="tok-type">f32</span>) <span class="tok-type">f32</span> {</span>
<span class="line" id="L25">    <span class="tok-kw">const</span> pS0 = <span class="tok-number">1.6666586697e-01</span>;</span>
<span class="line" id="L26">    <span class="tok-kw">const</span> pS1 = -<span class="tok-number">4.2743422091e-02</span>;</span>
<span class="line" id="L27">    <span class="tok-kw">const</span> pS2 = -<span class="tok-number">8.6563630030e-03</span>;</span>
<span class="line" id="L28">    <span class="tok-kw">const</span> qS1 = -<span class="tok-number">7.0662963390e-01</span>;</span>
<span class="line" id="L29"></span>
<span class="line" id="L30">    <span class="tok-kw">const</span> p = z * (pS0 + z * (pS1 + z * pS2));</span>
<span class="line" id="L31">    <span class="tok-kw">const</span> q = <span class="tok-number">1.0</span> + z * qS1;</span>
<span class="line" id="L32">    <span class="tok-kw">return</span> p / q;</span>
<span class="line" id="L33">}</span>
<span class="line" id="L34"></span>
<span class="line" id="L35"><span class="tok-kw">fn</span> <span class="tok-fn">acos32</span>(x: <span class="tok-type">f32</span>) <span class="tok-type">f32</span> {</span>
<span class="line" id="L36">    <span class="tok-kw">const</span> pio2_hi = <span class="tok-number">1.5707962513e+00</span>;</span>
<span class="line" id="L37">    <span class="tok-kw">const</span> pio2_lo = <span class="tok-number">7.5497894159e-08</span>;</span>
<span class="line" id="L38"></span>
<span class="line" id="L39">    <span class="tok-kw">const</span> hx: <span class="tok-type">u32</span> = <span class="tok-builtin">@bitCast</span>(<span class="tok-type">u32</span>, x);</span>
<span class="line" id="L40">    <span class="tok-kw">const</span> ix: <span class="tok-type">u32</span> = hx &amp; <span class="tok-number">0x7FFFFFFF</span>;</span>
<span class="line" id="L41"></span>
<span class="line" id="L42">    <span class="tok-comment">// |x| &gt;= 1 or nan</span>
</span>
<span class="line" id="L43">    <span class="tok-kw">if</span> (ix &gt;= <span class="tok-number">0x3F800000</span>) {</span>
<span class="line" id="L44">        <span class="tok-kw">if</span> (ix == <span class="tok-number">0x3F800000</span>) {</span>
<span class="line" id="L45">            <span class="tok-kw">if</span> (hx &gt;&gt; <span class="tok-number">31</span> != <span class="tok-number">0</span>) {</span>
<span class="line" id="L46">                <span class="tok-kw">return</span> <span class="tok-number">2.0</span> * pio2_hi + <span class="tok-number">0x1.0p-120</span>;</span>
<span class="line" id="L47">            } <span class="tok-kw">else</span> {</span>
<span class="line" id="L48">                <span class="tok-kw">return</span> <span class="tok-number">0.0</span>;</span>
<span class="line" id="L49">            }</span>
<span class="line" id="L50">        } <span class="tok-kw">else</span> {</span>
<span class="line" id="L51">            <span class="tok-kw">return</span> math.nan(<span class="tok-type">f32</span>);</span>
<span class="line" id="L52">        }</span>
<span class="line" id="L53">    }</span>
<span class="line" id="L54"></span>
<span class="line" id="L55">    <span class="tok-comment">// |x| &lt; 0.5</span>
</span>
<span class="line" id="L56">    <span class="tok-kw">if</span> (ix &lt; <span class="tok-number">0x3F000000</span>) {</span>
<span class="line" id="L57">        <span class="tok-kw">if</span> (ix &lt;= <span class="tok-number">0x32800000</span>) { <span class="tok-comment">// |x| &lt; 2^(-26)</span>
</span>
<span class="line" id="L58">            <span class="tok-kw">return</span> pio2_hi + <span class="tok-number">0x1.0p-120</span>;</span>
<span class="line" id="L59">        } <span class="tok-kw">else</span> {</span>
<span class="line" id="L60">            <span class="tok-kw">return</span> pio2_hi - (x - (pio2_lo - x * r32(x * x)));</span>
<span class="line" id="L61">        }</span>
<span class="line" id="L62">    }</span>
<span class="line" id="L63"></span>
<span class="line" id="L64">    <span class="tok-comment">// x &lt; -0.5</span>
</span>
<span class="line" id="L65">    <span class="tok-kw">if</span> (hx &gt;&gt; <span class="tok-number">31</span> != <span class="tok-number">0</span>) {</span>
<span class="line" id="L66">        <span class="tok-kw">const</span> z = (<span class="tok-number">1</span> + x) * <span class="tok-number">0.5</span>;</span>
<span class="line" id="L67">        <span class="tok-kw">const</span> s = <span class="tok-builtin">@sqrt</span>(z);</span>
<span class="line" id="L68">        <span class="tok-kw">const</span> w = r32(z) * s - pio2_lo;</span>
<span class="line" id="L69">        <span class="tok-kw">return</span> <span class="tok-number">2</span> * (pio2_hi - (s + w));</span>
<span class="line" id="L70">    }</span>
<span class="line" id="L71"></span>
<span class="line" id="L72">    <span class="tok-comment">// x &gt; 0.5</span>
</span>
<span class="line" id="L73">    <span class="tok-kw">const</span> z = (<span class="tok-number">1.0</span> - x) * <span class="tok-number">0.5</span>;</span>
<span class="line" id="L74">    <span class="tok-kw">const</span> s = <span class="tok-builtin">@sqrt</span>(z);</span>
<span class="line" id="L75">    <span class="tok-kw">const</span> jx = <span class="tok-builtin">@bitCast</span>(<span class="tok-type">u32</span>, s);</span>
<span class="line" id="L76">    <span class="tok-kw">const</span> df = <span class="tok-builtin">@bitCast</span>(<span class="tok-type">f32</span>, jx &amp; <span class="tok-number">0xFFFFF000</span>);</span>
<span class="line" id="L77">    <span class="tok-kw">const</span> c = (z - df * df) / (s + df);</span>
<span class="line" id="L78">    <span class="tok-kw">const</span> w = r32(z) * s + c;</span>
<span class="line" id="L79">    <span class="tok-kw">return</span> <span class="tok-number">2</span> * (df + w);</span>
<span class="line" id="L80">}</span>
<span class="line" id="L81"></span>
<span class="line" id="L82"><span class="tok-kw">fn</span> <span class="tok-fn">r64</span>(z: <span class="tok-type">f64</span>) <span class="tok-type">f64</span> {</span>
<span class="line" id="L83">    <span class="tok-kw">const</span> pS0: <span class="tok-type">f64</span> = <span class="tok-number">1.66666666666666657415e-01</span>;</span>
<span class="line" id="L84">    <span class="tok-kw">const</span> pS1: <span class="tok-type">f64</span> = -<span class="tok-number">3.25565818622400915405e-01</span>;</span>
<span class="line" id="L85">    <span class="tok-kw">const</span> pS2: <span class="tok-type">f64</span> = <span class="tok-number">2.01212532134862925881e-01</span>;</span>
<span class="line" id="L86">    <span class="tok-kw">const</span> pS3: <span class="tok-type">f64</span> = -<span class="tok-number">4.00555345006794114027e-02</span>;</span>
<span class="line" id="L87">    <span class="tok-kw">const</span> pS4: <span class="tok-type">f64</span> = <span class="tok-number">7.91534994289814532176e-04</span>;</span>
<span class="line" id="L88">    <span class="tok-kw">const</span> pS5: <span class="tok-type">f64</span> = <span class="tok-number">3.47933107596021167570e-05</span>;</span>
<span class="line" id="L89">    <span class="tok-kw">const</span> qS1: <span class="tok-type">f64</span> = -<span class="tok-number">2.40339491173441421878e+00</span>;</span>
<span class="line" id="L90">    <span class="tok-kw">const</span> qS2: <span class="tok-type">f64</span> = <span class="tok-number">2.02094576023350569471e+00</span>;</span>
<span class="line" id="L91">    <span class="tok-kw">const</span> qS3: <span class="tok-type">f64</span> = -<span class="tok-number">6.88283971605453293030e-01</span>;</span>
<span class="line" id="L92">    <span class="tok-kw">const</span> qS4: <span class="tok-type">f64</span> = <span class="tok-number">7.70381505559019352791e-02</span>;</span>
<span class="line" id="L93"></span>
<span class="line" id="L94">    <span class="tok-kw">const</span> p = z * (pS0 + z * (pS1 + z * (pS2 + z * (pS3 + z * (pS4 + z * pS5)))));</span>
<span class="line" id="L95">    <span class="tok-kw">const</span> q = <span class="tok-number">1.0</span> + z * (qS1 + z * (qS2 + z * (qS3 + z * qS4)));</span>
<span class="line" id="L96">    <span class="tok-kw">return</span> p / q;</span>
<span class="line" id="L97">}</span>
<span class="line" id="L98"></span>
<span class="line" id="L99"><span class="tok-kw">fn</span> <span class="tok-fn">acos64</span>(x: <span class="tok-type">f64</span>) <span class="tok-type">f64</span> {</span>
<span class="line" id="L100">    <span class="tok-kw">const</span> pio2_hi: <span class="tok-type">f64</span> = <span class="tok-number">1.57079632679489655800e+00</span>;</span>
<span class="line" id="L101">    <span class="tok-kw">const</span> pio2_lo: <span class="tok-type">f64</span> = <span class="tok-number">6.12323399573676603587e-17</span>;</span>
<span class="line" id="L102"></span>
<span class="line" id="L103">    <span class="tok-kw">const</span> ux = <span class="tok-builtin">@bitCast</span>(<span class="tok-type">u64</span>, x);</span>
<span class="line" id="L104">    <span class="tok-kw">const</span> hx = <span class="tok-builtin">@intCast</span>(<span class="tok-type">u32</span>, ux &gt;&gt; <span class="tok-number">32</span>);</span>
<span class="line" id="L105">    <span class="tok-kw">const</span> ix = hx &amp; <span class="tok-number">0x7FFFFFFF</span>;</span>
<span class="line" id="L106"></span>
<span class="line" id="L107">    <span class="tok-comment">// |x| &gt;= 1 or nan</span>
</span>
<span class="line" id="L108">    <span class="tok-kw">if</span> (ix &gt;= <span class="tok-number">0x3FF00000</span>) {</span>
<span class="line" id="L109">        <span class="tok-kw">const</span> lx = <span class="tok-builtin">@intCast</span>(<span class="tok-type">u32</span>, ux &amp; <span class="tok-number">0xFFFFFFFF</span>);</span>
<span class="line" id="L110"></span>
<span class="line" id="L111">        <span class="tok-comment">// acos(1) = 0, acos(-1) = pi</span>
</span>
<span class="line" id="L112">        <span class="tok-kw">if</span> ((ix - <span class="tok-number">0x3FF00000</span>) | lx == <span class="tok-number">0</span>) {</span>
<span class="line" id="L113">            <span class="tok-kw">if</span> (hx &gt;&gt; <span class="tok-number">31</span> != <span class="tok-number">0</span>) {</span>
<span class="line" id="L114">                <span class="tok-kw">return</span> <span class="tok-number">2</span> * pio2_hi + <span class="tok-number">0x1.0p-120</span>;</span>
<span class="line" id="L115">            } <span class="tok-kw">else</span> {</span>
<span class="line" id="L116">                <span class="tok-kw">return</span> <span class="tok-number">0</span>;</span>
<span class="line" id="L117">            }</span>
<span class="line" id="L118">        }</span>
<span class="line" id="L119"></span>
<span class="line" id="L120">        <span class="tok-kw">return</span> math.nan(<span class="tok-type">f32</span>);</span>
<span class="line" id="L121">    }</span>
<span class="line" id="L122"></span>
<span class="line" id="L123">    <span class="tok-comment">// |x| &lt; 0.5</span>
</span>
<span class="line" id="L124">    <span class="tok-kw">if</span> (ix &lt; <span class="tok-number">0x3FE00000</span>) {</span>
<span class="line" id="L125">        <span class="tok-comment">// |x| &lt; 2^(-57)</span>
</span>
<span class="line" id="L126">        <span class="tok-kw">if</span> (ix &lt;= <span class="tok-number">0x3C600000</span>) {</span>
<span class="line" id="L127">            <span class="tok-kw">return</span> pio2_hi + <span class="tok-number">0x1.0p-120</span>;</span>
<span class="line" id="L128">        } <span class="tok-kw">else</span> {</span>
<span class="line" id="L129">            <span class="tok-kw">return</span> pio2_hi - (x - (pio2_lo - x * r64(x * x)));</span>
<span class="line" id="L130">        }</span>
<span class="line" id="L131">    }</span>
<span class="line" id="L132"></span>
<span class="line" id="L133">    <span class="tok-comment">// x &lt; -0.5</span>
</span>
<span class="line" id="L134">    <span class="tok-kw">if</span> (hx &gt;&gt; <span class="tok-number">31</span> != <span class="tok-number">0</span>) {</span>
<span class="line" id="L135">        <span class="tok-kw">const</span> z = (<span class="tok-number">1.0</span> + x) * <span class="tok-number">0.5</span>;</span>
<span class="line" id="L136">        <span class="tok-kw">const</span> s = <span class="tok-builtin">@sqrt</span>(z);</span>
<span class="line" id="L137">        <span class="tok-kw">const</span> w = r64(z) * s - pio2_lo;</span>
<span class="line" id="L138">        <span class="tok-kw">return</span> <span class="tok-number">2</span> * (pio2_hi - (s + w));</span>
<span class="line" id="L139">    }</span>
<span class="line" id="L140"></span>
<span class="line" id="L141">    <span class="tok-comment">// x &gt; 0.5</span>
</span>
<span class="line" id="L142">    <span class="tok-kw">const</span> z = (<span class="tok-number">1.0</span> - x) * <span class="tok-number">0.5</span>;</span>
<span class="line" id="L143">    <span class="tok-kw">const</span> s = <span class="tok-builtin">@sqrt</span>(z);</span>
<span class="line" id="L144">    <span class="tok-kw">const</span> jx = <span class="tok-builtin">@bitCast</span>(<span class="tok-type">u64</span>, s);</span>
<span class="line" id="L145">    <span class="tok-kw">const</span> df = <span class="tok-builtin">@bitCast</span>(<span class="tok-type">f64</span>, jx &amp; <span class="tok-number">0xFFFFFFFF00000000</span>);</span>
<span class="line" id="L146">    <span class="tok-kw">const</span> c = (z - df * df) / (s + df);</span>
<span class="line" id="L147">    <span class="tok-kw">const</span> w = r64(z) * s + c;</span>
<span class="line" id="L148">    <span class="tok-kw">return</span> <span class="tok-number">2</span> * (df + w);</span>
<span class="line" id="L149">}</span>
<span class="line" id="L150"></span>
<span class="line" id="L151"><span class="tok-kw">test</span> <span class="tok-str">&quot;math.acos&quot;</span> {</span>
<span class="line" id="L152">    <span class="tok-kw">try</span> expect(acos(<span class="tok-builtin">@as</span>(<span class="tok-type">f32</span>, <span class="tok-number">0.0</span>)) == acos32(<span class="tok-number">0.0</span>));</span>
<span class="line" id="L153">    <span class="tok-kw">try</span> expect(acos(<span class="tok-builtin">@as</span>(<span class="tok-type">f64</span>, <span class="tok-number">0.0</span>)) == acos64(<span class="tok-number">0.0</span>));</span>
<span class="line" id="L154">}</span>
<span class="line" id="L155"></span>
<span class="line" id="L156"><span class="tok-kw">test</span> <span class="tok-str">&quot;math.acos32&quot;</span> {</span>
<span class="line" id="L157">    <span class="tok-kw">const</span> epsilon = <span class="tok-number">0.000001</span>;</span>
<span class="line" id="L158"></span>
<span class="line" id="L159">    <span class="tok-kw">try</span> expect(math.approxEqAbs(<span class="tok-type">f32</span>, acos32(<span class="tok-number">0.0</span>), <span class="tok-number">1.570796</span>, epsilon));</span>
<span class="line" id="L160">    <span class="tok-kw">try</span> expect(math.approxEqAbs(<span class="tok-type">f32</span>, acos32(<span class="tok-number">0.2</span>), <span class="tok-number">1.369438</span>, epsilon));</span>
<span class="line" id="L161">    <span class="tok-kw">try</span> expect(math.approxEqAbs(<span class="tok-type">f32</span>, acos32(<span class="tok-number">0.3434</span>), <span class="tok-number">1.220262</span>, epsilon));</span>
<span class="line" id="L162">    <span class="tok-kw">try</span> expect(math.approxEqAbs(<span class="tok-type">f32</span>, acos32(<span class="tok-number">0.5</span>), <span class="tok-number">1.047198</span>, epsilon));</span>
<span class="line" id="L163">    <span class="tok-kw">try</span> expect(math.approxEqAbs(<span class="tok-type">f32</span>, acos32(<span class="tok-number">0.8923</span>), <span class="tok-number">0.468382</span>, epsilon));</span>
<span class="line" id="L164">    <span class="tok-kw">try</span> expect(math.approxEqAbs(<span class="tok-type">f32</span>, acos32(-<span class="tok-number">0.2</span>), <span class="tok-number">1.772154</span>, epsilon));</span>
<span class="line" id="L165">}</span>
<span class="line" id="L166"></span>
<span class="line" id="L167"><span class="tok-kw">test</span> <span class="tok-str">&quot;math.acos64&quot;</span> {</span>
<span class="line" id="L168">    <span class="tok-kw">const</span> epsilon = <span class="tok-number">0.000001</span>;</span>
<span class="line" id="L169"></span>
<span class="line" id="L170">    <span class="tok-kw">try</span> expect(math.approxEqAbs(<span class="tok-type">f64</span>, acos64(<span class="tok-number">0.0</span>), <span class="tok-number">1.570796</span>, epsilon));</span>
<span class="line" id="L171">    <span class="tok-kw">try</span> expect(math.approxEqAbs(<span class="tok-type">f64</span>, acos64(<span class="tok-number">0.2</span>), <span class="tok-number">1.369438</span>, epsilon));</span>
<span class="line" id="L172">    <span class="tok-kw">try</span> expect(math.approxEqAbs(<span class="tok-type">f64</span>, acos64(<span class="tok-number">0.3434</span>), <span class="tok-number">1.220262</span>, epsilon));</span>
<span class="line" id="L173">    <span class="tok-kw">try</span> expect(math.approxEqAbs(<span class="tok-type">f64</span>, acos64(<span class="tok-number">0.5</span>), <span class="tok-number">1.047198</span>, epsilon));</span>
<span class="line" id="L174">    <span class="tok-kw">try</span> expect(math.approxEqAbs(<span class="tok-type">f64</span>, acos64(<span class="tok-number">0.8923</span>), <span class="tok-number">0.468382</span>, epsilon));</span>
<span class="line" id="L175">    <span class="tok-kw">try</span> expect(math.approxEqAbs(<span class="tok-type">f64</span>, acos64(-<span class="tok-number">0.2</span>), <span class="tok-number">1.772154</span>, epsilon));</span>
<span class="line" id="L176">}</span>
<span class="line" id="L177"></span>
<span class="line" id="L178"><span class="tok-kw">test</span> <span class="tok-str">&quot;math.acos32.special&quot;</span> {</span>
<span class="line" id="L179">    <span class="tok-kw">try</span> expect(math.isNan(acos32(-<span class="tok-number">2</span>)));</span>
<span class="line" id="L180">    <span class="tok-kw">try</span> expect(math.isNan(acos32(<span class="tok-number">1.5</span>)));</span>
<span class="line" id="L181">}</span>
<span class="line" id="L182"></span>
<span class="line" id="L183"><span class="tok-kw">test</span> <span class="tok-str">&quot;math.acos64.special&quot;</span> {</span>
<span class="line" id="L184">    <span class="tok-kw">try</span> expect(math.isNan(acos64(-<span class="tok-number">2</span>)));</span>
<span class="line" id="L185">    <span class="tok-kw">try</span> expect(math.isNan(acos64(<span class="tok-number">1.5</span>)));</span>
<span class="line" id="L186">}</span>
<span class="line" id="L187"></span>
</code></pre></body>
</html>