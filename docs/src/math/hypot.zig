<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">    <title>math/hypot.zig - source view</title>
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
<span class="line" id="L4"><span class="tok-comment">// https://git.musl-libc.org/cgit/musl/tree/src/math/hypotf.c</span>
</span>
<span class="line" id="L5"><span class="tok-comment">// https://git.musl-libc.org/cgit/musl/tree/src/math/hypot.c</span>
</span>
<span class="line" id="L6"></span>
<span class="line" id="L7"><span class="tok-kw">const</span> std = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;../std.zig&quot;</span>);</span>
<span class="line" id="L8"><span class="tok-kw">const</span> math = std.math;</span>
<span class="line" id="L9"><span class="tok-kw">const</span> expect = std.testing.expect;</span>
<span class="line" id="L10"><span class="tok-kw">const</span> maxInt = std.math.maxInt;</span>
<span class="line" id="L11"></span>
<span class="line" id="L12"><span class="tok-comment">/// Returns sqrt(x * x + y * y), avoiding unnecessary overflow and underflow.</span></span>
<span class="line" id="L13"><span class="tok-comment">///</span></span>
<span class="line" id="L14"><span class="tok-comment">/// Special Cases:</span></span>
<span class="line" id="L15"><span class="tok-comment">///  - hypot(+-inf, y)  = +inf</span></span>
<span class="line" id="L16"><span class="tok-comment">///  - hypot(x, +-inf)  = +inf</span></span>
<span class="line" id="L17"><span class="tok-comment">///  - hypot(nan, y)    = nan</span></span>
<span class="line" id="L18"><span class="tok-comment">///  - hypot(x, nan)    = nan</span></span>
<span class="line" id="L19"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">hypot</span>(<span class="tok-kw">comptime</span> T: <span class="tok-type">type</span>, x: T, y: T) T {</span>
<span class="line" id="L20">    <span class="tok-kw">return</span> <span class="tok-kw">switch</span> (T) {</span>
<span class="line" id="L21">        <span class="tok-type">f32</span> =&gt; hypot32(x, y),</span>
<span class="line" id="L22">        <span class="tok-type">f64</span> =&gt; hypot64(x, y),</span>
<span class="line" id="L23">        <span class="tok-kw">else</span> =&gt; <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;hypot not implemented for &quot;</span> ++ <span class="tok-builtin">@typeName</span>(T)),</span>
<span class="line" id="L24">    };</span>
<span class="line" id="L25">}</span>
<span class="line" id="L26"></span>
<span class="line" id="L27"><span class="tok-kw">fn</span> <span class="tok-fn">hypot32</span>(x: <span class="tok-type">f32</span>, y: <span class="tok-type">f32</span>) <span class="tok-type">f32</span> {</span>
<span class="line" id="L28">    <span class="tok-kw">var</span> ux = <span class="tok-builtin">@bitCast</span>(<span class="tok-type">u32</span>, x);</span>
<span class="line" id="L29">    <span class="tok-kw">var</span> uy = <span class="tok-builtin">@bitCast</span>(<span class="tok-type">u32</span>, y);</span>
<span class="line" id="L30"></span>
<span class="line" id="L31">    ux &amp;= maxInt(<span class="tok-type">u32</span>) &gt;&gt; <span class="tok-number">1</span>;</span>
<span class="line" id="L32">    uy &amp;= maxInt(<span class="tok-type">u32</span>) &gt;&gt; <span class="tok-number">1</span>;</span>
<span class="line" id="L33">    <span class="tok-kw">if</span> (ux &lt; uy) {</span>
<span class="line" id="L34">        <span class="tok-kw">const</span> tmp = ux;</span>
<span class="line" id="L35">        ux = uy;</span>
<span class="line" id="L36">        uy = tmp;</span>
<span class="line" id="L37">    }</span>
<span class="line" id="L38"></span>
<span class="line" id="L39">    <span class="tok-kw">var</span> xx = <span class="tok-builtin">@bitCast</span>(<span class="tok-type">f32</span>, ux);</span>
<span class="line" id="L40">    <span class="tok-kw">var</span> yy = <span class="tok-builtin">@bitCast</span>(<span class="tok-type">f32</span>, uy);</span>
<span class="line" id="L41">    <span class="tok-kw">if</span> (uy == <span class="tok-number">0xFF</span> &lt;&lt; <span class="tok-number">23</span>) {</span>
<span class="line" id="L42">        <span class="tok-kw">return</span> yy;</span>
<span class="line" id="L43">    }</span>
<span class="line" id="L44">    <span class="tok-kw">if</span> (ux &gt;= <span class="tok-number">0xFF</span> &lt;&lt; <span class="tok-number">23</span> <span class="tok-kw">or</span> uy == <span class="tok-number">0</span> <span class="tok-kw">or</span> ux - uy &gt;= (<span class="tok-number">25</span> &lt;&lt; <span class="tok-number">23</span>)) {</span>
<span class="line" id="L45">        <span class="tok-kw">return</span> xx + yy;</span>
<span class="line" id="L46">    }</span>
<span class="line" id="L47"></span>
<span class="line" id="L48">    <span class="tok-kw">var</span> z: <span class="tok-type">f32</span> = <span class="tok-number">1.0</span>;</span>
<span class="line" id="L49">    <span class="tok-kw">if</span> (ux &gt;= (<span class="tok-number">0x7F</span> + <span class="tok-number">60</span>) &lt;&lt; <span class="tok-number">23</span>) {</span>
<span class="line" id="L50">        z = <span class="tok-number">0x1.0p90</span>;</span>
<span class="line" id="L51">        xx *= <span class="tok-number">0x1.0p-90</span>;</span>
<span class="line" id="L52">        yy *= <span class="tok-number">0x1.0p-90</span>;</span>
<span class="line" id="L53">    } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (uy &lt; (<span class="tok-number">0x7F</span> - <span class="tok-number">60</span>) &lt;&lt; <span class="tok-number">23</span>) {</span>
<span class="line" id="L54">        z = <span class="tok-number">0x1.0p-90</span>;</span>
<span class="line" id="L55">        xx *= <span class="tok-number">0x1.0p-90</span>;</span>
<span class="line" id="L56">        yy *= <span class="tok-number">0x1.0p-90</span>;</span>
<span class="line" id="L57">    }</span>
<span class="line" id="L58"></span>
<span class="line" id="L59">    <span class="tok-kw">return</span> z * <span class="tok-builtin">@sqrt</span>(<span class="tok-builtin">@floatCast</span>(<span class="tok-type">f32</span>, <span class="tok-builtin">@as</span>(<span class="tok-type">f64</span>, x) * x + <span class="tok-builtin">@as</span>(<span class="tok-type">f64</span>, y) * y));</span>
<span class="line" id="L60">}</span>
<span class="line" id="L61"></span>
<span class="line" id="L62"><span class="tok-kw">fn</span> <span class="tok-fn">sq</span>(hi: *<span class="tok-type">f64</span>, lo: *<span class="tok-type">f64</span>, x: <span class="tok-type">f64</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L63">    <span class="tok-kw">const</span> split: <span class="tok-type">f64</span> = <span class="tok-number">0x1.0p27</span> + <span class="tok-number">1.0</span>;</span>
<span class="line" id="L64">    <span class="tok-kw">const</span> xc = x * split;</span>
<span class="line" id="L65">    <span class="tok-kw">const</span> xh = x - xc + xc;</span>
<span class="line" id="L66">    <span class="tok-kw">const</span> xl = x - xh;</span>
<span class="line" id="L67">    hi.* = x * x;</span>
<span class="line" id="L68">    lo.* = xh * xh - hi.* + <span class="tok-number">2</span> * xh * xl + xl * xl;</span>
<span class="line" id="L69">}</span>
<span class="line" id="L70"></span>
<span class="line" id="L71"><span class="tok-kw">fn</span> <span class="tok-fn">hypot64</span>(x: <span class="tok-type">f64</span>, y: <span class="tok-type">f64</span>) <span class="tok-type">f64</span> {</span>
<span class="line" id="L72">    <span class="tok-kw">var</span> ux = <span class="tok-builtin">@bitCast</span>(<span class="tok-type">u64</span>, x);</span>
<span class="line" id="L73">    <span class="tok-kw">var</span> uy = <span class="tok-builtin">@bitCast</span>(<span class="tok-type">u64</span>, y);</span>
<span class="line" id="L74"></span>
<span class="line" id="L75">    ux &amp;= maxInt(<span class="tok-type">u64</span>) &gt;&gt; <span class="tok-number">1</span>;</span>
<span class="line" id="L76">    uy &amp;= maxInt(<span class="tok-type">u64</span>) &gt;&gt; <span class="tok-number">1</span>;</span>
<span class="line" id="L77">    <span class="tok-kw">if</span> (ux &lt; uy) {</span>
<span class="line" id="L78">        <span class="tok-kw">const</span> tmp = ux;</span>
<span class="line" id="L79">        ux = uy;</span>
<span class="line" id="L80">        uy = tmp;</span>
<span class="line" id="L81">    }</span>
<span class="line" id="L82"></span>
<span class="line" id="L83">    <span class="tok-kw">const</span> ex = ux &gt;&gt; <span class="tok-number">52</span>;</span>
<span class="line" id="L84">    <span class="tok-kw">const</span> ey = uy &gt;&gt; <span class="tok-number">52</span>;</span>
<span class="line" id="L85">    <span class="tok-kw">var</span> xx = <span class="tok-builtin">@bitCast</span>(<span class="tok-type">f64</span>, ux);</span>
<span class="line" id="L86">    <span class="tok-kw">var</span> yy = <span class="tok-builtin">@bitCast</span>(<span class="tok-type">f64</span>, uy);</span>
<span class="line" id="L87"></span>
<span class="line" id="L88">    <span class="tok-comment">// hypot(inf, nan) == inf</span>
</span>
<span class="line" id="L89">    <span class="tok-kw">if</span> (ey == <span class="tok-number">0x7FF</span>) {</span>
<span class="line" id="L90">        <span class="tok-kw">return</span> yy;</span>
<span class="line" id="L91">    }</span>
<span class="line" id="L92">    <span class="tok-kw">if</span> (ex == <span class="tok-number">0x7FF</span> <span class="tok-kw">or</span> uy == <span class="tok-number">0</span>) {</span>
<span class="line" id="L93">        <span class="tok-kw">return</span> xx;</span>
<span class="line" id="L94">    }</span>
<span class="line" id="L95"></span>
<span class="line" id="L96">    <span class="tok-comment">// hypot(x, y) ~= x + y * y / x / 2 with inexact for small y/x</span>
</span>
<span class="line" id="L97">    <span class="tok-kw">if</span> (ex - ey &gt; <span class="tok-number">64</span>) {</span>
<span class="line" id="L98">        <span class="tok-kw">return</span> xx + yy;</span>
<span class="line" id="L99">    }</span>
<span class="line" id="L100"></span>
<span class="line" id="L101">    <span class="tok-kw">var</span> z: <span class="tok-type">f64</span> = <span class="tok-number">1</span>;</span>
<span class="line" id="L102">    <span class="tok-kw">if</span> (ex &gt; <span class="tok-number">0x3FF</span> + <span class="tok-number">510</span>) {</span>
<span class="line" id="L103">        z = <span class="tok-number">0x1.0p700</span>;</span>
<span class="line" id="L104">        xx *= <span class="tok-number">0x1.0p-700</span>;</span>
<span class="line" id="L105">        yy *= <span class="tok-number">0x1.0p-700</span>;</span>
<span class="line" id="L106">    } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (ey &lt; <span class="tok-number">0x3FF</span> - <span class="tok-number">450</span>) {</span>
<span class="line" id="L107">        z = <span class="tok-number">0x1.0p-700</span>;</span>
<span class="line" id="L108">        xx *= <span class="tok-number">0x1.0p700</span>;</span>
<span class="line" id="L109">        yy *= <span class="tok-number">0x1.0p700</span>;</span>
<span class="line" id="L110">    }</span>
<span class="line" id="L111"></span>
<span class="line" id="L112">    <span class="tok-kw">var</span> hx: <span class="tok-type">f64</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L113">    <span class="tok-kw">var</span> lx: <span class="tok-type">f64</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L114">    <span class="tok-kw">var</span> hy: <span class="tok-type">f64</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L115">    <span class="tok-kw">var</span> ly: <span class="tok-type">f64</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L116"></span>
<span class="line" id="L117">    sq(&amp;hx, &amp;lx, x);</span>
<span class="line" id="L118">    sq(&amp;hy, &amp;ly, y);</span>
<span class="line" id="L119"></span>
<span class="line" id="L120">    <span class="tok-kw">return</span> z * <span class="tok-builtin">@sqrt</span>(ly + lx + hy + hx);</span>
<span class="line" id="L121">}</span>
<span class="line" id="L122"></span>
<span class="line" id="L123"><span class="tok-kw">test</span> <span class="tok-str">&quot;math.hypot&quot;</span> {</span>
<span class="line" id="L124">    <span class="tok-kw">try</span> expect(hypot(<span class="tok-type">f32</span>, <span class="tok-number">0.0</span>, -<span class="tok-number">1.2</span>) == hypot32(<span class="tok-number">0.0</span>, -<span class="tok-number">1.2</span>));</span>
<span class="line" id="L125">    <span class="tok-kw">try</span> expect(hypot(<span class="tok-type">f64</span>, <span class="tok-number">0.0</span>, -<span class="tok-number">1.2</span>) == hypot64(<span class="tok-number">0.0</span>, -<span class="tok-number">1.2</span>));</span>
<span class="line" id="L126">}</span>
<span class="line" id="L127"></span>
<span class="line" id="L128"><span class="tok-kw">test</span> <span class="tok-str">&quot;math.hypot32&quot;</span> {</span>
<span class="line" id="L129">    <span class="tok-kw">const</span> epsilon = <span class="tok-number">0.000001</span>;</span>
<span class="line" id="L130"></span>
<span class="line" id="L131">    <span class="tok-kw">try</span> expect(math.approxEqAbs(<span class="tok-type">f32</span>, hypot32(<span class="tok-number">0.0</span>, -<span class="tok-number">1.2</span>), <span class="tok-number">1.2</span>, epsilon));</span>
<span class="line" id="L132">    <span class="tok-kw">try</span> expect(math.approxEqAbs(<span class="tok-type">f32</span>, hypot32(<span class="tok-number">0.2</span>, -<span class="tok-number">0.34</span>), <span class="tok-number">0.394462</span>, epsilon));</span>
<span class="line" id="L133">    <span class="tok-kw">try</span> expect(math.approxEqAbs(<span class="tok-type">f32</span>, hypot32(<span class="tok-number">0.8923</span>, <span class="tok-number">2.636890</span>), <span class="tok-number">2.783772</span>, epsilon));</span>
<span class="line" id="L134">    <span class="tok-kw">try</span> expect(math.approxEqAbs(<span class="tok-type">f32</span>, hypot32(<span class="tok-number">1.5</span>, <span class="tok-number">5.25</span>), <span class="tok-number">5.460083</span>, epsilon));</span>
<span class="line" id="L135">    <span class="tok-kw">try</span> expect(math.approxEqAbs(<span class="tok-type">f32</span>, hypot32(<span class="tok-number">37.45</span>, <span class="tok-number">159.835</span>), <span class="tok-number">164.163742</span>, epsilon));</span>
<span class="line" id="L136">    <span class="tok-kw">try</span> expect(math.approxEqAbs(<span class="tok-type">f32</span>, hypot32(<span class="tok-number">89.123</span>, <span class="tok-number">382.028905</span>), <span class="tok-number">392.286865</span>, epsilon));</span>
<span class="line" id="L137">    <span class="tok-kw">try</span> expect(math.approxEqAbs(<span class="tok-type">f32</span>, hypot32(<span class="tok-number">123123.234375</span>, <span class="tok-number">529428.707813</span>), <span class="tok-number">543556.875</span>, epsilon));</span>
<span class="line" id="L138">}</span>
<span class="line" id="L139"></span>
<span class="line" id="L140"><span class="tok-kw">test</span> <span class="tok-str">&quot;math.hypot64&quot;</span> {</span>
<span class="line" id="L141">    <span class="tok-kw">const</span> epsilon = <span class="tok-number">0.000001</span>;</span>
<span class="line" id="L142"></span>
<span class="line" id="L143">    <span class="tok-kw">try</span> expect(math.approxEqAbs(<span class="tok-type">f64</span>, hypot64(<span class="tok-number">0.0</span>, -<span class="tok-number">1.2</span>), <span class="tok-number">1.2</span>, epsilon));</span>
<span class="line" id="L144">    <span class="tok-kw">try</span> expect(math.approxEqAbs(<span class="tok-type">f64</span>, hypot64(<span class="tok-number">0.2</span>, -<span class="tok-number">0.34</span>), <span class="tok-number">0.394462</span>, epsilon));</span>
<span class="line" id="L145">    <span class="tok-kw">try</span> expect(math.approxEqAbs(<span class="tok-type">f64</span>, hypot64(<span class="tok-number">0.8923</span>, <span class="tok-number">2.636890</span>), <span class="tok-number">2.783772</span>, epsilon));</span>
<span class="line" id="L146">    <span class="tok-kw">try</span> expect(math.approxEqAbs(<span class="tok-type">f64</span>, hypot64(<span class="tok-number">1.5</span>, <span class="tok-number">5.25</span>), <span class="tok-number">5.460082</span>, epsilon));</span>
<span class="line" id="L147">    <span class="tok-kw">try</span> expect(math.approxEqAbs(<span class="tok-type">f64</span>, hypot64(<span class="tok-number">37.45</span>, <span class="tok-number">159.835</span>), <span class="tok-number">164.163728</span>, epsilon));</span>
<span class="line" id="L148">    <span class="tok-kw">try</span> expect(math.approxEqAbs(<span class="tok-type">f64</span>, hypot64(<span class="tok-number">89.123</span>, <span class="tok-number">382.028905</span>), <span class="tok-number">392.286876</span>, epsilon));</span>
<span class="line" id="L149">    <span class="tok-kw">try</span> expect(math.approxEqAbs(<span class="tok-type">f64</span>, hypot64(<span class="tok-number">123123.234375</span>, <span class="tok-number">529428.707813</span>), <span class="tok-number">543556.885247</span>, epsilon));</span>
<span class="line" id="L150">}</span>
<span class="line" id="L151"></span>
<span class="line" id="L152"><span class="tok-kw">test</span> <span class="tok-str">&quot;math.hypot32.special&quot;</span> {</span>
<span class="line" id="L153">    <span class="tok-kw">try</span> expect(math.isPositiveInf(hypot32(math.inf(<span class="tok-type">f32</span>), <span class="tok-number">0.0</span>)));</span>
<span class="line" id="L154">    <span class="tok-kw">try</span> expect(math.isPositiveInf(hypot32(-math.inf(<span class="tok-type">f32</span>), <span class="tok-number">0.0</span>)));</span>
<span class="line" id="L155">    <span class="tok-kw">try</span> expect(math.isPositiveInf(hypot32(<span class="tok-number">0.0</span>, math.inf(<span class="tok-type">f32</span>))));</span>
<span class="line" id="L156">    <span class="tok-kw">try</span> expect(math.isPositiveInf(hypot32(<span class="tok-number">0.0</span>, -math.inf(<span class="tok-type">f32</span>))));</span>
<span class="line" id="L157">    <span class="tok-kw">try</span> expect(math.isNan(hypot32(math.nan(<span class="tok-type">f32</span>), <span class="tok-number">0.0</span>)));</span>
<span class="line" id="L158">    <span class="tok-kw">try</span> expect(math.isNan(hypot32(<span class="tok-number">0.0</span>, math.nan(<span class="tok-type">f32</span>))));</span>
<span class="line" id="L159">}</span>
<span class="line" id="L160"></span>
<span class="line" id="L161"><span class="tok-kw">test</span> <span class="tok-str">&quot;math.hypot64.special&quot;</span> {</span>
<span class="line" id="L162">    <span class="tok-kw">try</span> expect(math.isPositiveInf(hypot64(math.inf(<span class="tok-type">f64</span>), <span class="tok-number">0.0</span>)));</span>
<span class="line" id="L163">    <span class="tok-kw">try</span> expect(math.isPositiveInf(hypot64(-math.inf(<span class="tok-type">f64</span>), <span class="tok-number">0.0</span>)));</span>
<span class="line" id="L164">    <span class="tok-kw">try</span> expect(math.isPositiveInf(hypot64(<span class="tok-number">0.0</span>, math.inf(<span class="tok-type">f64</span>))));</span>
<span class="line" id="L165">    <span class="tok-kw">try</span> expect(math.isPositiveInf(hypot64(<span class="tok-number">0.0</span>, -math.inf(<span class="tok-type">f64</span>))));</span>
<span class="line" id="L166">    <span class="tok-kw">try</span> expect(math.isNan(hypot64(math.nan(<span class="tok-type">f64</span>), <span class="tok-number">0.0</span>)));</span>
<span class="line" id="L167">    <span class="tok-kw">try</span> expect(math.isNan(hypot64(<span class="tok-number">0.0</span>, math.nan(<span class="tok-type">f64</span>))));</span>
<span class="line" id="L168">}</span>
<span class="line" id="L169"></span>
</code></pre></body>
</html>