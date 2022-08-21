<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">    <title>math/cosh.zig - source view</title>
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
<span class="line" id="L4"><span class="tok-comment">// https://git.musl-libc.org/cgit/musl/tree/src/math/coshf.c</span>
</span>
<span class="line" id="L5"><span class="tok-comment">// https://git.musl-libc.org/cgit/musl/tree/src/math/cosh.c</span>
</span>
<span class="line" id="L6"></span>
<span class="line" id="L7"><span class="tok-kw">const</span> std = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;../std.zig&quot;</span>);</span>
<span class="line" id="L8"><span class="tok-kw">const</span> math = std.math;</span>
<span class="line" id="L9"><span class="tok-kw">const</span> expo2 = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;expo2.zig&quot;</span>).expo2;</span>
<span class="line" id="L10"><span class="tok-kw">const</span> expect = std.testing.expect;</span>
<span class="line" id="L11"><span class="tok-kw">const</span> maxInt = std.math.maxInt;</span>
<span class="line" id="L12"></span>
<span class="line" id="L13"><span class="tok-comment">/// Returns the hyperbolic cosine of x.</span></span>
<span class="line" id="L14"><span class="tok-comment">///</span></span>
<span class="line" id="L15"><span class="tok-comment">/// Special Cases:</span></span>
<span class="line" id="L16"><span class="tok-comment">///  - cosh(+-0)   = 1</span></span>
<span class="line" id="L17"><span class="tok-comment">///  - cosh(+-inf) = +inf</span></span>
<span class="line" id="L18"><span class="tok-comment">///  - cosh(nan)   = nan</span></span>
<span class="line" id="L19"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">cosh</span>(x: <span class="tok-kw">anytype</span>) <span class="tok-builtin">@TypeOf</span>(x) {</span>
<span class="line" id="L20">    <span class="tok-kw">const</span> T = <span class="tok-builtin">@TypeOf</span>(x);</span>
<span class="line" id="L21">    <span class="tok-kw">return</span> <span class="tok-kw">switch</span> (T) {</span>
<span class="line" id="L22">        <span class="tok-type">f32</span> =&gt; cosh32(x),</span>
<span class="line" id="L23">        <span class="tok-type">f64</span> =&gt; cosh64(x),</span>
<span class="line" id="L24">        <span class="tok-kw">else</span> =&gt; <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;cosh not implemented for &quot;</span> ++ <span class="tok-builtin">@typeName</span>(T)),</span>
<span class="line" id="L25">    };</span>
<span class="line" id="L26">}</span>
<span class="line" id="L27"></span>
<span class="line" id="L28"><span class="tok-comment">// cosh(x) = (exp(x) + 1 / exp(x)) / 2</span>
</span>
<span class="line" id="L29"><span class="tok-comment">//         = 1 + 0.5 * (exp(x) - 1) * (exp(x) - 1) / exp(x)</span>
</span>
<span class="line" id="L30"><span class="tok-comment">//         = 1 + (x * x) / 2 + o(x^4)</span>
</span>
<span class="line" id="L31"><span class="tok-kw">fn</span> <span class="tok-fn">cosh32</span>(x: <span class="tok-type">f32</span>) <span class="tok-type">f32</span> {</span>
<span class="line" id="L32">    <span class="tok-kw">const</span> u = <span class="tok-builtin">@bitCast</span>(<span class="tok-type">u32</span>, x);</span>
<span class="line" id="L33">    <span class="tok-kw">const</span> ux = u &amp; <span class="tok-number">0x7FFFFFFF</span>;</span>
<span class="line" id="L34">    <span class="tok-kw">const</span> ax = <span class="tok-builtin">@bitCast</span>(<span class="tok-type">f32</span>, ux);</span>
<span class="line" id="L35"></span>
<span class="line" id="L36">    <span class="tok-comment">// |x| &lt; log(2)</span>
</span>
<span class="line" id="L37">    <span class="tok-kw">if</span> (ux &lt; <span class="tok-number">0x3F317217</span>) {</span>
<span class="line" id="L38">        <span class="tok-kw">if</span> (ux &lt; <span class="tok-number">0x3F800000</span> - (<span class="tok-number">12</span> &lt;&lt; <span class="tok-number">23</span>)) {</span>
<span class="line" id="L39">            math.raiseOverflow();</span>
<span class="line" id="L40">            <span class="tok-kw">return</span> <span class="tok-number">1.0</span>;</span>
<span class="line" id="L41">        }</span>
<span class="line" id="L42">        <span class="tok-kw">const</span> t = math.expm1(ax);</span>
<span class="line" id="L43">        <span class="tok-kw">return</span> <span class="tok-number">1</span> + t * t / (<span class="tok-number">2</span> * (<span class="tok-number">1</span> + t));</span>
<span class="line" id="L44">    }</span>
<span class="line" id="L45"></span>
<span class="line" id="L46">    <span class="tok-comment">// |x| &lt; log(FLT_MAX)</span>
</span>
<span class="line" id="L47">    <span class="tok-kw">if</span> (ux &lt; <span class="tok-number">0x42B17217</span>) {</span>
<span class="line" id="L48">        <span class="tok-kw">const</span> t = <span class="tok-builtin">@exp</span>(ax);</span>
<span class="line" id="L49">        <span class="tok-kw">return</span> <span class="tok-number">0.5</span> * (t + <span class="tok-number">1</span> / t);</span>
<span class="line" id="L50">    }</span>
<span class="line" id="L51"></span>
<span class="line" id="L52">    <span class="tok-comment">// |x| &gt; log(FLT_MAX) or nan</span>
</span>
<span class="line" id="L53">    <span class="tok-kw">return</span> expo2(ax);</span>
<span class="line" id="L54">}</span>
<span class="line" id="L55"></span>
<span class="line" id="L56"><span class="tok-kw">fn</span> <span class="tok-fn">cosh64</span>(x: <span class="tok-type">f64</span>) <span class="tok-type">f64</span> {</span>
<span class="line" id="L57">    <span class="tok-kw">const</span> u = <span class="tok-builtin">@bitCast</span>(<span class="tok-type">u64</span>, x);</span>
<span class="line" id="L58">    <span class="tok-kw">const</span> w = <span class="tok-builtin">@intCast</span>(<span class="tok-type">u32</span>, u &gt;&gt; <span class="tok-number">32</span>) &amp; (maxInt(<span class="tok-type">u32</span>) &gt;&gt; <span class="tok-number">1</span>);</span>
<span class="line" id="L59">    <span class="tok-kw">const</span> ax = <span class="tok-builtin">@bitCast</span>(<span class="tok-type">f64</span>, u &amp; (maxInt(<span class="tok-type">u64</span>) &gt;&gt; <span class="tok-number">1</span>));</span>
<span class="line" id="L60"></span>
<span class="line" id="L61">    <span class="tok-comment">// TODO: Shouldn't need this explicit check.</span>
</span>
<span class="line" id="L62">    <span class="tok-kw">if</span> (x == <span class="tok-number">0.0</span>) {</span>
<span class="line" id="L63">        <span class="tok-kw">return</span> <span class="tok-number">1.0</span>;</span>
<span class="line" id="L64">    }</span>
<span class="line" id="L65"></span>
<span class="line" id="L66">    <span class="tok-comment">// |x| &lt; log(2)</span>
</span>
<span class="line" id="L67">    <span class="tok-kw">if</span> (w &lt; <span class="tok-number">0x3FE62E42</span>) {</span>
<span class="line" id="L68">        <span class="tok-kw">if</span> (w &lt; <span class="tok-number">0x3FF00000</span> - (<span class="tok-number">26</span> &lt;&lt; <span class="tok-number">20</span>)) {</span>
<span class="line" id="L69">            <span class="tok-kw">if</span> (x != <span class="tok-number">0</span>) {</span>
<span class="line" id="L70">                math.raiseInexact();</span>
<span class="line" id="L71">            }</span>
<span class="line" id="L72">            <span class="tok-kw">return</span> <span class="tok-number">1.0</span>;</span>
<span class="line" id="L73">        }</span>
<span class="line" id="L74">        <span class="tok-kw">const</span> t = math.expm1(ax);</span>
<span class="line" id="L75">        <span class="tok-kw">return</span> <span class="tok-number">1</span> + t * t / (<span class="tok-number">2</span> * (<span class="tok-number">1</span> + t));</span>
<span class="line" id="L76">    }</span>
<span class="line" id="L77"></span>
<span class="line" id="L78">    <span class="tok-comment">// |x| &lt; log(DBL_MAX)</span>
</span>
<span class="line" id="L79">    <span class="tok-kw">if</span> (w &lt; <span class="tok-number">0x40862E42</span>) {</span>
<span class="line" id="L80">        <span class="tok-kw">const</span> t = <span class="tok-builtin">@exp</span>(ax);</span>
<span class="line" id="L81">        <span class="tok-comment">// NOTE: If x &gt; log(0x1p26) then 1/t is not required.</span>
</span>
<span class="line" id="L82">        <span class="tok-kw">return</span> <span class="tok-number">0.5</span> * (t + <span class="tok-number">1</span> / t);</span>
<span class="line" id="L83">    }</span>
<span class="line" id="L84"></span>
<span class="line" id="L85">    <span class="tok-comment">// |x| &gt; log(CBL_MAX) or nan</span>
</span>
<span class="line" id="L86">    <span class="tok-kw">return</span> expo2(ax);</span>
<span class="line" id="L87">}</span>
<span class="line" id="L88"></span>
<span class="line" id="L89"><span class="tok-kw">test</span> <span class="tok-str">&quot;math.cosh&quot;</span> {</span>
<span class="line" id="L90">    <span class="tok-kw">try</span> expect(cosh(<span class="tok-builtin">@as</span>(<span class="tok-type">f32</span>, <span class="tok-number">1.5</span>)) == cosh32(<span class="tok-number">1.5</span>));</span>
<span class="line" id="L91">    <span class="tok-kw">try</span> expect(cosh(<span class="tok-builtin">@as</span>(<span class="tok-type">f64</span>, <span class="tok-number">1.5</span>)) == cosh64(<span class="tok-number">1.5</span>));</span>
<span class="line" id="L92">}</span>
<span class="line" id="L93"></span>
<span class="line" id="L94"><span class="tok-kw">test</span> <span class="tok-str">&quot;math.cosh32&quot;</span> {</span>
<span class="line" id="L95">    <span class="tok-kw">const</span> epsilon = <span class="tok-number">0.000001</span>;</span>
<span class="line" id="L96"></span>
<span class="line" id="L97">    <span class="tok-kw">try</span> expect(math.approxEqAbs(<span class="tok-type">f32</span>, cosh32(<span class="tok-number">0.0</span>), <span class="tok-number">1.0</span>, epsilon));</span>
<span class="line" id="L98">    <span class="tok-kw">try</span> expect(math.approxEqAbs(<span class="tok-type">f32</span>, cosh32(<span class="tok-number">0.2</span>), <span class="tok-number">1.020067</span>, epsilon));</span>
<span class="line" id="L99">    <span class="tok-kw">try</span> expect(math.approxEqAbs(<span class="tok-type">f32</span>, cosh32(<span class="tok-number">0.8923</span>), <span class="tok-number">1.425225</span>, epsilon));</span>
<span class="line" id="L100">    <span class="tok-kw">try</span> expect(math.approxEqAbs(<span class="tok-type">f32</span>, cosh32(<span class="tok-number">1.5</span>), <span class="tok-number">2.352410</span>, epsilon));</span>
<span class="line" id="L101">    <span class="tok-kw">try</span> expect(math.approxEqAbs(<span class="tok-type">f32</span>, cosh32(-<span class="tok-number">0.0</span>), <span class="tok-number">1.0</span>, epsilon));</span>
<span class="line" id="L102">    <span class="tok-kw">try</span> expect(math.approxEqAbs(<span class="tok-type">f32</span>, cosh32(-<span class="tok-number">0.2</span>), <span class="tok-number">1.020067</span>, epsilon));</span>
<span class="line" id="L103">    <span class="tok-kw">try</span> expect(math.approxEqAbs(<span class="tok-type">f32</span>, cosh32(-<span class="tok-number">0.8923</span>), <span class="tok-number">1.425225</span>, epsilon));</span>
<span class="line" id="L104">    <span class="tok-kw">try</span> expect(math.approxEqAbs(<span class="tok-type">f32</span>, cosh32(-<span class="tok-number">1.5</span>), <span class="tok-number">2.352410</span>, epsilon));</span>
<span class="line" id="L105">}</span>
<span class="line" id="L106"></span>
<span class="line" id="L107"><span class="tok-kw">test</span> <span class="tok-str">&quot;math.cosh64&quot;</span> {</span>
<span class="line" id="L108">    <span class="tok-kw">const</span> epsilon = <span class="tok-number">0.000001</span>;</span>
<span class="line" id="L109"></span>
<span class="line" id="L110">    <span class="tok-kw">try</span> expect(math.approxEqAbs(<span class="tok-type">f64</span>, cosh64(<span class="tok-number">0.0</span>), <span class="tok-number">1.0</span>, epsilon));</span>
<span class="line" id="L111">    <span class="tok-kw">try</span> expect(math.approxEqAbs(<span class="tok-type">f64</span>, cosh64(<span class="tok-number">0.2</span>), <span class="tok-number">1.020067</span>, epsilon));</span>
<span class="line" id="L112">    <span class="tok-kw">try</span> expect(math.approxEqAbs(<span class="tok-type">f64</span>, cosh64(<span class="tok-number">0.8923</span>), <span class="tok-number">1.425225</span>, epsilon));</span>
<span class="line" id="L113">    <span class="tok-kw">try</span> expect(math.approxEqAbs(<span class="tok-type">f64</span>, cosh64(<span class="tok-number">1.5</span>), <span class="tok-number">2.352410</span>, epsilon));</span>
<span class="line" id="L114">    <span class="tok-kw">try</span> expect(math.approxEqAbs(<span class="tok-type">f64</span>, cosh64(-<span class="tok-number">0.0</span>), <span class="tok-number">1.0</span>, epsilon));</span>
<span class="line" id="L115">    <span class="tok-kw">try</span> expect(math.approxEqAbs(<span class="tok-type">f64</span>, cosh64(-<span class="tok-number">0.2</span>), <span class="tok-number">1.020067</span>, epsilon));</span>
<span class="line" id="L116">    <span class="tok-kw">try</span> expect(math.approxEqAbs(<span class="tok-type">f64</span>, cosh64(-<span class="tok-number">0.8923</span>), <span class="tok-number">1.425225</span>, epsilon));</span>
<span class="line" id="L117">    <span class="tok-kw">try</span> expect(math.approxEqAbs(<span class="tok-type">f64</span>, cosh64(-<span class="tok-number">1.5</span>), <span class="tok-number">2.352410</span>, epsilon));</span>
<span class="line" id="L118">}</span>
<span class="line" id="L119"></span>
<span class="line" id="L120"><span class="tok-kw">test</span> <span class="tok-str">&quot;math.cosh32.special&quot;</span> {</span>
<span class="line" id="L121">    <span class="tok-kw">try</span> expect(cosh32(<span class="tok-number">0.0</span>) == <span class="tok-number">1.0</span>);</span>
<span class="line" id="L122">    <span class="tok-kw">try</span> expect(cosh32(-<span class="tok-number">0.0</span>) == <span class="tok-number">1.0</span>);</span>
<span class="line" id="L123">    <span class="tok-kw">try</span> expect(math.isPositiveInf(cosh32(math.inf(<span class="tok-type">f32</span>))));</span>
<span class="line" id="L124">    <span class="tok-kw">try</span> expect(math.isPositiveInf(cosh32(-math.inf(<span class="tok-type">f32</span>))));</span>
<span class="line" id="L125">    <span class="tok-kw">try</span> expect(math.isNan(cosh32(math.nan(<span class="tok-type">f32</span>))));</span>
<span class="line" id="L126">}</span>
<span class="line" id="L127"></span>
<span class="line" id="L128"><span class="tok-kw">test</span> <span class="tok-str">&quot;math.cosh64.special&quot;</span> {</span>
<span class="line" id="L129">    <span class="tok-kw">try</span> expect(cosh64(<span class="tok-number">0.0</span>) == <span class="tok-number">1.0</span>);</span>
<span class="line" id="L130">    <span class="tok-kw">try</span> expect(cosh64(-<span class="tok-number">0.0</span>) == <span class="tok-number">1.0</span>);</span>
<span class="line" id="L131">    <span class="tok-kw">try</span> expect(math.isPositiveInf(cosh64(math.inf(<span class="tok-type">f64</span>))));</span>
<span class="line" id="L132">    <span class="tok-kw">try</span> expect(math.isPositiveInf(cosh64(-math.inf(<span class="tok-type">f64</span>))));</span>
<span class="line" id="L133">    <span class="tok-kw">try</span> expect(math.isNan(cosh64(math.nan(<span class="tok-type">f64</span>))));</span>
<span class="line" id="L134">}</span>
<span class="line" id="L135"></span>
</code></pre></body>
</html>