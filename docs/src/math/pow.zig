<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">    <title>math/pow.zig - source view</title>
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
<pre><code><span class="line" id="L1"><span class="tok-comment">// Ported from go, which is licensed under a BSD-3 license.</span>
</span>
<span class="line" id="L2"><span class="tok-comment">// https://golang.org/LICENSE</span>
</span>
<span class="line" id="L3"><span class="tok-comment">//</span>
</span>
<span class="line" id="L4"><span class="tok-comment">// https://golang.org/src/math/pow.go</span>
</span>
<span class="line" id="L5"></span>
<span class="line" id="L6"><span class="tok-kw">const</span> std = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;../std.zig&quot;</span>);</span>
<span class="line" id="L7"><span class="tok-kw">const</span> math = std.math;</span>
<span class="line" id="L8"><span class="tok-kw">const</span> expect = std.testing.expect;</span>
<span class="line" id="L9"></span>
<span class="line" id="L10"><span class="tok-comment">/// Returns x raised to the power of y (x^y).</span></span>
<span class="line" id="L11"><span class="tok-comment">///</span></span>
<span class="line" id="L12"><span class="tok-comment">/// Special Cases:</span></span>
<span class="line" id="L13"><span class="tok-comment">///  - pow(x, +-0)    = 1 for any x</span></span>
<span class="line" id="L14"><span class="tok-comment">///  - pow(1, y)      = 1 for any y</span></span>
<span class="line" id="L15"><span class="tok-comment">///  - pow(x, 1)      = x for any x</span></span>
<span class="line" id="L16"><span class="tok-comment">///  - pow(nan, y)    = nan</span></span>
<span class="line" id="L17"><span class="tok-comment">///  - pow(x, nan)    = nan</span></span>
<span class="line" id="L18"><span class="tok-comment">///  - pow(+-0, y)    = +-inf for y an odd integer &lt; 0</span></span>
<span class="line" id="L19"><span class="tok-comment">///  - pow(+-0, -inf) = +inf</span></span>
<span class="line" id="L20"><span class="tok-comment">///  - pow(+-0, +inf) = +0</span></span>
<span class="line" id="L21"><span class="tok-comment">///  - pow(+-0, y)    = +inf for finite y &lt; 0 and not an odd integer</span></span>
<span class="line" id="L22"><span class="tok-comment">///  - pow(+-0, y)    = +-0 for y an odd integer &gt; 0</span></span>
<span class="line" id="L23"><span class="tok-comment">///  - pow(+-0, y)    = +0 for finite y &gt; 0 and not an odd integer</span></span>
<span class="line" id="L24"><span class="tok-comment">///  - pow(-1, +-inf) = 1</span></span>
<span class="line" id="L25"><span class="tok-comment">///  - pow(x, +inf)   = +inf for |x| &gt; 1</span></span>
<span class="line" id="L26"><span class="tok-comment">///  - pow(x, -inf)   = +0 for |x| &gt; 1</span></span>
<span class="line" id="L27"><span class="tok-comment">///  - pow(x, +inf)   = +0 for |x| &lt; 1</span></span>
<span class="line" id="L28"><span class="tok-comment">///  - pow(x, -inf)   = +inf for |x| &lt; 1</span></span>
<span class="line" id="L29"><span class="tok-comment">///  - pow(+inf, y)   = +inf for y &gt; 0</span></span>
<span class="line" id="L30"><span class="tok-comment">///  - pow(+inf, y)   = +0 for y &lt; 0</span></span>
<span class="line" id="L31"><span class="tok-comment">///  - pow(-inf, y)   = pow(-0, -y)</span></span>
<span class="line" id="L32"><span class="tok-comment">///  - pow(x, y)      = nan for finite x &lt; 0 and finite non-integer y</span></span>
<span class="line" id="L33"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">pow</span>(<span class="tok-kw">comptime</span> T: <span class="tok-type">type</span>, x: T, y: T) T {</span>
<span class="line" id="L34">    <span class="tok-kw">if</span> (<span class="tok-builtin">@typeInfo</span>(T) == .Int) {</span>
<span class="line" id="L35">        <span class="tok-kw">return</span> math.powi(T, x, y) <span class="tok-kw">catch</span> <span class="tok-kw">unreachable</span>;</span>
<span class="line" id="L36">    }</span>
<span class="line" id="L37"></span>
<span class="line" id="L38">    <span class="tok-kw">if</span> (T != <span class="tok-type">f32</span> <span class="tok-kw">and</span> T != <span class="tok-type">f64</span>) {</span>
<span class="line" id="L39">        <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;pow not implemented for &quot;</span> ++ <span class="tok-builtin">@typeName</span>(T));</span>
<span class="line" id="L40">    }</span>
<span class="line" id="L41"></span>
<span class="line" id="L42">    <span class="tok-comment">// pow(x, +-0) = 1      for all x</span>
</span>
<span class="line" id="L43">    <span class="tok-comment">// pow(1, y) = 1        for all y</span>
</span>
<span class="line" id="L44">    <span class="tok-kw">if</span> (y == <span class="tok-number">0</span> <span class="tok-kw">or</span> x == <span class="tok-number">1</span>) {</span>
<span class="line" id="L45">        <span class="tok-kw">return</span> <span class="tok-number">1</span>;</span>
<span class="line" id="L46">    }</span>
<span class="line" id="L47"></span>
<span class="line" id="L48">    <span class="tok-comment">// pow(nan, y) = nan    for all y</span>
</span>
<span class="line" id="L49">    <span class="tok-comment">// pow(x, nan) = nan    for all x</span>
</span>
<span class="line" id="L50">    <span class="tok-kw">if</span> (math.isNan(x) <span class="tok-kw">or</span> math.isNan(y)) {</span>
<span class="line" id="L51">        <span class="tok-kw">return</span> math.nan(T);</span>
<span class="line" id="L52">    }</span>
<span class="line" id="L53"></span>
<span class="line" id="L54">    <span class="tok-comment">// pow(x, 1) = x        for all x</span>
</span>
<span class="line" id="L55">    <span class="tok-kw">if</span> (y == <span class="tok-number">1</span>) {</span>
<span class="line" id="L56">        <span class="tok-kw">return</span> x;</span>
<span class="line" id="L57">    }</span>
<span class="line" id="L58"></span>
<span class="line" id="L59">    <span class="tok-kw">if</span> (x == <span class="tok-number">0</span>) {</span>
<span class="line" id="L60">        <span class="tok-kw">if</span> (y &lt; <span class="tok-number">0</span>) {</span>
<span class="line" id="L61">            <span class="tok-comment">// pow(+-0, y) = +- 0   for y an odd integer</span>
</span>
<span class="line" id="L62">            <span class="tok-kw">if</span> (isOddInteger(y)) {</span>
<span class="line" id="L63">                <span class="tok-kw">return</span> math.copysign(math.inf(T), x);</span>
<span class="line" id="L64">            }</span>
<span class="line" id="L65">            <span class="tok-comment">// pow(+-0, y) = +inf   for y an even integer</span>
</span>
<span class="line" id="L66">            <span class="tok-kw">else</span> {</span>
<span class="line" id="L67">                <span class="tok-kw">return</span> math.inf(T);</span>
<span class="line" id="L68">            }</span>
<span class="line" id="L69">        } <span class="tok-kw">else</span> {</span>
<span class="line" id="L70">            <span class="tok-kw">if</span> (isOddInteger(y)) {</span>
<span class="line" id="L71">                <span class="tok-kw">return</span> x;</span>
<span class="line" id="L72">            } <span class="tok-kw">else</span> {</span>
<span class="line" id="L73">                <span class="tok-kw">return</span> <span class="tok-number">0</span>;</span>
<span class="line" id="L74">            }</span>
<span class="line" id="L75">        }</span>
<span class="line" id="L76">    }</span>
<span class="line" id="L77"></span>
<span class="line" id="L78">    <span class="tok-kw">if</span> (math.isInf(y)) {</span>
<span class="line" id="L79">        <span class="tok-comment">// pow(-1, inf) = 1     for all x</span>
</span>
<span class="line" id="L80">        <span class="tok-kw">if</span> (x == -<span class="tok-number">1</span>) {</span>
<span class="line" id="L81">            <span class="tok-kw">return</span> <span class="tok-number">1.0</span>;</span>
<span class="line" id="L82">        }</span>
<span class="line" id="L83">        <span class="tok-comment">// pow(x, +inf) = +0    for |x| &lt; 1</span>
</span>
<span class="line" id="L84">        <span class="tok-comment">// pow(x, -inf) = +0    for |x| &gt; 1</span>
</span>
<span class="line" id="L85">        <span class="tok-kw">else</span> <span class="tok-kw">if</span> ((<span class="tok-builtin">@fabs</span>(x) &lt; <span class="tok-number">1</span>) == math.isPositiveInf(y)) {</span>
<span class="line" id="L86">            <span class="tok-kw">return</span> <span class="tok-number">0</span>;</span>
<span class="line" id="L87">        }</span>
<span class="line" id="L88">        <span class="tok-comment">// pow(x, -inf) = +inf  for |x| &lt; 1</span>
</span>
<span class="line" id="L89">        <span class="tok-comment">// pow(x, +inf) = +inf  for |x| &gt; 1</span>
</span>
<span class="line" id="L90">        <span class="tok-kw">else</span> {</span>
<span class="line" id="L91">            <span class="tok-kw">return</span> math.inf(T);</span>
<span class="line" id="L92">        }</span>
<span class="line" id="L93">    }</span>
<span class="line" id="L94"></span>
<span class="line" id="L95">    <span class="tok-kw">if</span> (math.isInf(x)) {</span>
<span class="line" id="L96">        <span class="tok-kw">if</span> (math.isNegativeInf(x)) {</span>
<span class="line" id="L97">            <span class="tok-kw">return</span> pow(T, <span class="tok-number">1</span> / x, -y);</span>
<span class="line" id="L98">        }</span>
<span class="line" id="L99">        <span class="tok-comment">// pow(+inf, y) = +0    for y &lt; 0</span>
</span>
<span class="line" id="L100">        <span class="tok-kw">else</span> <span class="tok-kw">if</span> (y &lt; <span class="tok-number">0</span>) {</span>
<span class="line" id="L101">            <span class="tok-kw">return</span> <span class="tok-number">0</span>;</span>
<span class="line" id="L102">        }</span>
<span class="line" id="L103">        <span class="tok-comment">// pow(+inf, y) = +0    for y &gt; 0</span>
</span>
<span class="line" id="L104">        <span class="tok-kw">else</span> <span class="tok-kw">if</span> (y &gt; <span class="tok-number">0</span>) {</span>
<span class="line" id="L105">            <span class="tok-kw">return</span> math.inf(T);</span>
<span class="line" id="L106">        }</span>
<span class="line" id="L107">    }</span>
<span class="line" id="L108"></span>
<span class="line" id="L109">    <span class="tok-comment">// special case sqrt</span>
</span>
<span class="line" id="L110">    <span class="tok-kw">if</span> (y == <span class="tok-number">0.5</span>) {</span>
<span class="line" id="L111">        <span class="tok-kw">return</span> <span class="tok-builtin">@sqrt</span>(x);</span>
<span class="line" id="L112">    }</span>
<span class="line" id="L113"></span>
<span class="line" id="L114">    <span class="tok-kw">if</span> (y == -<span class="tok-number">0.5</span>) {</span>
<span class="line" id="L115">        <span class="tok-kw">return</span> <span class="tok-number">1</span> / <span class="tok-builtin">@sqrt</span>(x);</span>
<span class="line" id="L116">    }</span>
<span class="line" id="L117"></span>
<span class="line" id="L118">    <span class="tok-kw">const</span> r1 = math.modf(<span class="tok-builtin">@fabs</span>(y));</span>
<span class="line" id="L119">    <span class="tok-kw">var</span> yi = r1.ipart;</span>
<span class="line" id="L120">    <span class="tok-kw">var</span> yf = r1.fpart;</span>
<span class="line" id="L121"></span>
<span class="line" id="L122">    <span class="tok-kw">if</span> (yf != <span class="tok-number">0</span> <span class="tok-kw">and</span> x &lt; <span class="tok-number">0</span>) {</span>
<span class="line" id="L123">        <span class="tok-kw">return</span> math.nan(T);</span>
<span class="line" id="L124">    }</span>
<span class="line" id="L125">    <span class="tok-kw">if</span> (yi &gt;= <span class="tok-number">1</span> &lt;&lt; (<span class="tok-builtin">@typeInfo</span>(T).Float.bits - <span class="tok-number">1</span>)) {</span>
<span class="line" id="L126">        <span class="tok-kw">return</span> <span class="tok-builtin">@exp</span>(y * <span class="tok-builtin">@log</span>(x));</span>
<span class="line" id="L127">    }</span>
<span class="line" id="L128"></span>
<span class="line" id="L129">    <span class="tok-comment">// a = a1 * 2^ae</span>
</span>
<span class="line" id="L130">    <span class="tok-kw">var</span> a1: T = <span class="tok-number">1.0</span>;</span>
<span class="line" id="L131">    <span class="tok-kw">var</span> ae: <span class="tok-type">i32</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L132"></span>
<span class="line" id="L133">    <span class="tok-comment">// a *= x^yf</span>
</span>
<span class="line" id="L134">    <span class="tok-kw">if</span> (yf != <span class="tok-number">0</span>) {</span>
<span class="line" id="L135">        <span class="tok-kw">if</span> (yf &gt; <span class="tok-number">0.5</span>) {</span>
<span class="line" id="L136">            yf -= <span class="tok-number">1</span>;</span>
<span class="line" id="L137">            yi += <span class="tok-number">1</span>;</span>
<span class="line" id="L138">        }</span>
<span class="line" id="L139">        a1 = <span class="tok-builtin">@exp</span>(yf * <span class="tok-builtin">@log</span>(x));</span>
<span class="line" id="L140">    }</span>
<span class="line" id="L141"></span>
<span class="line" id="L142">    <span class="tok-comment">// a *= x^yi</span>
</span>
<span class="line" id="L143">    <span class="tok-kw">const</span> r2 = math.frexp(x);</span>
<span class="line" id="L144">    <span class="tok-kw">var</span> xe = r2.exponent;</span>
<span class="line" id="L145">    <span class="tok-kw">var</span> x1 = r2.significand;</span>
<span class="line" id="L146"></span>
<span class="line" id="L147">    <span class="tok-kw">var</span> i = <span class="tok-builtin">@floatToInt</span>(std.meta.Int(.signed, <span class="tok-builtin">@typeInfo</span>(T).Float.bits), yi);</span>
<span class="line" id="L148">    <span class="tok-kw">while</span> (i != <span class="tok-number">0</span>) : (i &gt;&gt;= <span class="tok-number">1</span>) {</span>
<span class="line" id="L149">        <span class="tok-kw">const</span> overflow_shift = math.floatExponentBits(T) + <span class="tok-number">1</span>;</span>
<span class="line" id="L150">        <span class="tok-kw">if</span> (xe &lt; -(<span class="tok-number">1</span> &lt;&lt; overflow_shift) <span class="tok-kw">or</span> (<span class="tok-number">1</span> &lt;&lt; overflow_shift) &lt; xe) {</span>
<span class="line" id="L151">            <span class="tok-comment">// catch xe before it overflows the left shift below</span>
</span>
<span class="line" id="L152">            <span class="tok-comment">// Since i != 0 it has at least one bit still set, so ae will accumulate xe</span>
</span>
<span class="line" id="L153">            <span class="tok-comment">// on at least one more iteration, ae += xe is a lower bound on ae</span>
</span>
<span class="line" id="L154">            <span class="tok-comment">// the lower bound on ae exceeds the size of a float exp</span>
</span>
<span class="line" id="L155">            <span class="tok-comment">// so the final call to Ldexp will produce under/overflow (0/Inf)</span>
</span>
<span class="line" id="L156">            ae += xe;</span>
<span class="line" id="L157">            <span class="tok-kw">break</span>;</span>
<span class="line" id="L158">        }</span>
<span class="line" id="L159">        <span class="tok-kw">if</span> (i &amp; <span class="tok-number">1</span> == <span class="tok-number">1</span>) {</span>
<span class="line" id="L160">            a1 *= x1;</span>
<span class="line" id="L161">            ae += xe;</span>
<span class="line" id="L162">        }</span>
<span class="line" id="L163">        x1 *= x1;</span>
<span class="line" id="L164">        xe &lt;&lt;= <span class="tok-number">1</span>;</span>
<span class="line" id="L165">        <span class="tok-kw">if</span> (x1 &lt; <span class="tok-number">0.5</span>) {</span>
<span class="line" id="L166">            x1 += x1;</span>
<span class="line" id="L167">            xe -= <span class="tok-number">1</span>;</span>
<span class="line" id="L168">        }</span>
<span class="line" id="L169">    }</span>
<span class="line" id="L170"></span>
<span class="line" id="L171">    <span class="tok-comment">// a *= a1 * 2^ae</span>
</span>
<span class="line" id="L172">    <span class="tok-kw">if</span> (y &lt; <span class="tok-number">0</span>) {</span>
<span class="line" id="L173">        a1 = <span class="tok-number">1</span> / a1;</span>
<span class="line" id="L174">        ae = -ae;</span>
<span class="line" id="L175">    }</span>
<span class="line" id="L176"></span>
<span class="line" id="L177">    <span class="tok-kw">return</span> math.scalbn(a1, ae);</span>
<span class="line" id="L178">}</span>
<span class="line" id="L179"></span>
<span class="line" id="L180"><span class="tok-kw">fn</span> <span class="tok-fn">isOddInteger</span>(x: <span class="tok-type">f64</span>) <span class="tok-type">bool</span> {</span>
<span class="line" id="L181">    <span class="tok-kw">const</span> r = math.modf(x);</span>
<span class="line" id="L182">    <span class="tok-kw">return</span> r.fpart == <span class="tok-number">0.0</span> <span class="tok-kw">and</span> <span class="tok-builtin">@floatToInt</span>(<span class="tok-type">i64</span>, r.ipart) &amp; <span class="tok-number">1</span> == <span class="tok-number">1</span>;</span>
<span class="line" id="L183">}</span>
<span class="line" id="L184"></span>
<span class="line" id="L185"><span class="tok-kw">test</span> <span class="tok-str">&quot;math.pow&quot;</span> {</span>
<span class="line" id="L186">    <span class="tok-kw">const</span> epsilon = <span class="tok-number">0.000001</span>;</span>
<span class="line" id="L187"></span>
<span class="line" id="L188">    <span class="tok-kw">try</span> expect(math.approxEqAbs(<span class="tok-type">f32</span>, pow(<span class="tok-type">f32</span>, <span class="tok-number">0.0</span>, <span class="tok-number">3.3</span>), <span class="tok-number">0.0</span>, epsilon));</span>
<span class="line" id="L189">    <span class="tok-kw">try</span> expect(math.approxEqAbs(<span class="tok-type">f32</span>, pow(<span class="tok-type">f32</span>, <span class="tok-number">0.8923</span>, <span class="tok-number">3.3</span>), <span class="tok-number">0.686572</span>, epsilon));</span>
<span class="line" id="L190">    <span class="tok-kw">try</span> expect(math.approxEqAbs(<span class="tok-type">f32</span>, pow(<span class="tok-type">f32</span>, <span class="tok-number">0.2</span>, <span class="tok-number">3.3</span>), <span class="tok-number">0.004936</span>, epsilon));</span>
<span class="line" id="L191">    <span class="tok-kw">try</span> expect(math.approxEqAbs(<span class="tok-type">f32</span>, pow(<span class="tok-type">f32</span>, <span class="tok-number">1.5</span>, <span class="tok-number">3.3</span>), <span class="tok-number">3.811546</span>, epsilon));</span>
<span class="line" id="L192">    <span class="tok-kw">try</span> expect(math.approxEqAbs(<span class="tok-type">f32</span>, pow(<span class="tok-type">f32</span>, <span class="tok-number">37.45</span>, <span class="tok-number">3.3</span>), <span class="tok-number">155736.703125</span>, epsilon));</span>
<span class="line" id="L193">    <span class="tok-kw">try</span> expect(math.approxEqAbs(<span class="tok-type">f32</span>, pow(<span class="tok-type">f32</span>, <span class="tok-number">89.123</span>, <span class="tok-number">3.3</span>), <span class="tok-number">2722489.5</span>, epsilon));</span>
<span class="line" id="L194"></span>
<span class="line" id="L195">    <span class="tok-kw">try</span> expect(math.approxEqAbs(<span class="tok-type">f64</span>, pow(<span class="tok-type">f64</span>, <span class="tok-number">0.0</span>, <span class="tok-number">3.3</span>), <span class="tok-number">0.0</span>, epsilon));</span>
<span class="line" id="L196">    <span class="tok-kw">try</span> expect(math.approxEqAbs(<span class="tok-type">f64</span>, pow(<span class="tok-type">f64</span>, <span class="tok-number">0.8923</span>, <span class="tok-number">3.3</span>), <span class="tok-number">0.686572</span>, epsilon));</span>
<span class="line" id="L197">    <span class="tok-kw">try</span> expect(math.approxEqAbs(<span class="tok-type">f64</span>, pow(<span class="tok-type">f64</span>, <span class="tok-number">0.2</span>, <span class="tok-number">3.3</span>), <span class="tok-number">0.004936</span>, epsilon));</span>
<span class="line" id="L198">    <span class="tok-kw">try</span> expect(math.approxEqAbs(<span class="tok-type">f64</span>, pow(<span class="tok-type">f64</span>, <span class="tok-number">1.5</span>, <span class="tok-number">3.3</span>), <span class="tok-number">3.811546</span>, epsilon));</span>
<span class="line" id="L199">    <span class="tok-kw">try</span> expect(math.approxEqAbs(<span class="tok-type">f64</span>, pow(<span class="tok-type">f64</span>, <span class="tok-number">37.45</span>, <span class="tok-number">3.3</span>), <span class="tok-number">155736.7160616</span>, epsilon));</span>
<span class="line" id="L200">    <span class="tok-kw">try</span> expect(math.approxEqAbs(<span class="tok-type">f64</span>, pow(<span class="tok-type">f64</span>, <span class="tok-number">89.123</span>, <span class="tok-number">3.3</span>), <span class="tok-number">2722490.231436</span>, epsilon));</span>
<span class="line" id="L201">}</span>
<span class="line" id="L202"></span>
<span class="line" id="L203"><span class="tok-kw">test</span> <span class="tok-str">&quot;math.pow.special&quot;</span> {</span>
<span class="line" id="L204">    <span class="tok-kw">const</span> epsilon = <span class="tok-number">0.000001</span>;</span>
<span class="line" id="L205"></span>
<span class="line" id="L206">    <span class="tok-kw">try</span> expect(pow(<span class="tok-type">f32</span>, <span class="tok-number">4</span>, <span class="tok-number">0.0</span>) == <span class="tok-number">1.0</span>);</span>
<span class="line" id="L207">    <span class="tok-kw">try</span> expect(pow(<span class="tok-type">f32</span>, <span class="tok-number">7</span>, -<span class="tok-number">0.0</span>) == <span class="tok-number">1.0</span>);</span>
<span class="line" id="L208">    <span class="tok-kw">try</span> expect(pow(<span class="tok-type">f32</span>, <span class="tok-number">45</span>, <span class="tok-number">1.0</span>) == <span class="tok-number">45</span>);</span>
<span class="line" id="L209">    <span class="tok-kw">try</span> expect(pow(<span class="tok-type">f32</span>, -<span class="tok-number">45</span>, <span class="tok-number">1.0</span>) == -<span class="tok-number">45</span>);</span>
<span class="line" id="L210">    <span class="tok-kw">try</span> expect(math.isNan(pow(<span class="tok-type">f32</span>, math.nan(<span class="tok-type">f32</span>), <span class="tok-number">5.0</span>)));</span>
<span class="line" id="L211">    <span class="tok-kw">try</span> expect(math.isPositiveInf(pow(<span class="tok-type">f32</span>, -math.inf(<span class="tok-type">f32</span>), <span class="tok-number">0.5</span>)));</span>
<span class="line" id="L212">    <span class="tok-kw">try</span> expect(math.isPositiveInf(pow(<span class="tok-type">f32</span>, -<span class="tok-number">0</span>, -<span class="tok-number">0.5</span>)));</span>
<span class="line" id="L213">    <span class="tok-kw">try</span> expect(pow(<span class="tok-type">f32</span>, -<span class="tok-number">0</span>, <span class="tok-number">0.5</span>) == <span class="tok-number">0</span>);</span>
<span class="line" id="L214">    <span class="tok-kw">try</span> expect(math.isNan(pow(<span class="tok-type">f32</span>, <span class="tok-number">5.0</span>, math.nan(<span class="tok-type">f32</span>))));</span>
<span class="line" id="L215">    <span class="tok-kw">try</span> expect(math.isPositiveInf(pow(<span class="tok-type">f32</span>, <span class="tok-number">0.0</span>, -<span class="tok-number">1.0</span>)));</span>
<span class="line" id="L216">    <span class="tok-comment">//expect(math.isNegativeInf(pow(f32, -0.0, -3.0))); TODO is this required?</span>
</span>
<span class="line" id="L217">    <span class="tok-kw">try</span> expect(math.isPositiveInf(pow(<span class="tok-type">f32</span>, <span class="tok-number">0.0</span>, -math.inf(<span class="tok-type">f32</span>))));</span>
<span class="line" id="L218">    <span class="tok-kw">try</span> expect(math.isPositiveInf(pow(<span class="tok-type">f32</span>, -<span class="tok-number">0.0</span>, -math.inf(<span class="tok-type">f32</span>))));</span>
<span class="line" id="L219">    <span class="tok-kw">try</span> expect(pow(<span class="tok-type">f32</span>, <span class="tok-number">0.0</span>, math.inf(<span class="tok-type">f32</span>)) == <span class="tok-number">0.0</span>);</span>
<span class="line" id="L220">    <span class="tok-kw">try</span> expect(pow(<span class="tok-type">f32</span>, -<span class="tok-number">0.0</span>, math.inf(<span class="tok-type">f32</span>)) == <span class="tok-number">0.0</span>);</span>
<span class="line" id="L221">    <span class="tok-kw">try</span> expect(math.isPositiveInf(pow(<span class="tok-type">f32</span>, <span class="tok-number">0.0</span>, -<span class="tok-number">2.0</span>)));</span>
<span class="line" id="L222">    <span class="tok-kw">try</span> expect(math.isPositiveInf(pow(<span class="tok-type">f32</span>, -<span class="tok-number">0.0</span>, -<span class="tok-number">2.0</span>)));</span>
<span class="line" id="L223">    <span class="tok-kw">try</span> expect(pow(<span class="tok-type">f32</span>, <span class="tok-number">0.0</span>, <span class="tok-number">1.0</span>) == <span class="tok-number">0.0</span>);</span>
<span class="line" id="L224">    <span class="tok-kw">try</span> expect(pow(<span class="tok-type">f32</span>, -<span class="tok-number">0.0</span>, <span class="tok-number">1.0</span>) == -<span class="tok-number">0.0</span>);</span>
<span class="line" id="L225">    <span class="tok-kw">try</span> expect(pow(<span class="tok-type">f32</span>, <span class="tok-number">0.0</span>, <span class="tok-number">2.0</span>) == <span class="tok-number">0.0</span>);</span>
<span class="line" id="L226">    <span class="tok-kw">try</span> expect(pow(<span class="tok-type">f32</span>, -<span class="tok-number">0.0</span>, <span class="tok-number">2.0</span>) == <span class="tok-number">0.0</span>);</span>
<span class="line" id="L227">    <span class="tok-kw">try</span> expect(math.approxEqAbs(<span class="tok-type">f32</span>, pow(<span class="tok-type">f32</span>, -<span class="tok-number">1.0</span>, math.inf(<span class="tok-type">f32</span>)), <span class="tok-number">1.0</span>, epsilon));</span>
<span class="line" id="L228">    <span class="tok-kw">try</span> expect(math.approxEqAbs(<span class="tok-type">f32</span>, pow(<span class="tok-type">f32</span>, -<span class="tok-number">1.0</span>, -math.inf(<span class="tok-type">f32</span>)), <span class="tok-number">1.0</span>, epsilon));</span>
<span class="line" id="L229">    <span class="tok-kw">try</span> expect(math.isPositiveInf(pow(<span class="tok-type">f32</span>, <span class="tok-number">1.2</span>, math.inf(<span class="tok-type">f32</span>))));</span>
<span class="line" id="L230">    <span class="tok-kw">try</span> expect(math.isPositiveInf(pow(<span class="tok-type">f32</span>, -<span class="tok-number">1.2</span>, math.inf(<span class="tok-type">f32</span>))));</span>
<span class="line" id="L231">    <span class="tok-kw">try</span> expect(pow(<span class="tok-type">f32</span>, <span class="tok-number">1.2</span>, -math.inf(<span class="tok-type">f32</span>)) == <span class="tok-number">0.0</span>);</span>
<span class="line" id="L232">    <span class="tok-kw">try</span> expect(pow(<span class="tok-type">f32</span>, -<span class="tok-number">1.2</span>, -math.inf(<span class="tok-type">f32</span>)) == <span class="tok-number">0.0</span>);</span>
<span class="line" id="L233">    <span class="tok-kw">try</span> expect(pow(<span class="tok-type">f32</span>, <span class="tok-number">0.2</span>, math.inf(<span class="tok-type">f32</span>)) == <span class="tok-number">0.0</span>);</span>
<span class="line" id="L234">    <span class="tok-kw">try</span> expect(pow(<span class="tok-type">f32</span>, -<span class="tok-number">0.2</span>, math.inf(<span class="tok-type">f32</span>)) == <span class="tok-number">0.0</span>);</span>
<span class="line" id="L235">    <span class="tok-kw">try</span> expect(math.isPositiveInf(pow(<span class="tok-type">f32</span>, <span class="tok-number">0.2</span>, -math.inf(<span class="tok-type">f32</span>))));</span>
<span class="line" id="L236">    <span class="tok-kw">try</span> expect(math.isPositiveInf(pow(<span class="tok-type">f32</span>, -<span class="tok-number">0.2</span>, -math.inf(<span class="tok-type">f32</span>))));</span>
<span class="line" id="L237">    <span class="tok-kw">try</span> expect(math.isPositiveInf(pow(<span class="tok-type">f32</span>, math.inf(<span class="tok-type">f32</span>), <span class="tok-number">1.0</span>)));</span>
<span class="line" id="L238">    <span class="tok-kw">try</span> expect(pow(<span class="tok-type">f32</span>, math.inf(<span class="tok-type">f32</span>), -<span class="tok-number">1.0</span>) == <span class="tok-number">0.0</span>);</span>
<span class="line" id="L239">    <span class="tok-comment">//expect(pow(f32, -math.inf(f32), 5.0) == pow(f32, -0.0, -5.0)); TODO support negative 0?</span>
</span>
<span class="line" id="L240">    <span class="tok-kw">try</span> expect(pow(<span class="tok-type">f32</span>, -math.inf(<span class="tok-type">f32</span>), -<span class="tok-number">5.2</span>) == pow(<span class="tok-type">f32</span>, -<span class="tok-number">0.0</span>, <span class="tok-number">5.2</span>));</span>
<span class="line" id="L241">    <span class="tok-kw">try</span> expect(math.isNan(pow(<span class="tok-type">f32</span>, -<span class="tok-number">1.0</span>, <span class="tok-number">1.2</span>)));</span>
<span class="line" id="L242">    <span class="tok-kw">try</span> expect(math.isNan(pow(<span class="tok-type">f32</span>, -<span class="tok-number">12.4</span>, <span class="tok-number">78.5</span>)));</span>
<span class="line" id="L243">}</span>
<span class="line" id="L244"></span>
<span class="line" id="L245"><span class="tok-kw">test</span> <span class="tok-str">&quot;math.pow.overflow&quot;</span> {</span>
<span class="line" id="L246">    <span class="tok-kw">try</span> expect(math.isPositiveInf(pow(<span class="tok-type">f64</span>, <span class="tok-number">2</span>, <span class="tok-number">1</span> &lt;&lt; <span class="tok-number">32</span>)));</span>
<span class="line" id="L247">    <span class="tok-kw">try</span> expect(pow(<span class="tok-type">f64</span>, <span class="tok-number">2</span>, -(<span class="tok-number">1</span> &lt;&lt; <span class="tok-number">32</span>)) == <span class="tok-number">0</span>);</span>
<span class="line" id="L248">    <span class="tok-kw">try</span> expect(math.isNegativeInf(pow(<span class="tok-type">f64</span>, -<span class="tok-number">2</span>, (<span class="tok-number">1</span> &lt;&lt; <span class="tok-number">32</span>) + <span class="tok-number">1</span>)));</span>
<span class="line" id="L249">    <span class="tok-kw">try</span> expect(pow(<span class="tok-type">f64</span>, <span class="tok-number">0.5</span>, <span class="tok-number">1</span> &lt;&lt; <span class="tok-number">45</span>) == <span class="tok-number">0</span>);</span>
<span class="line" id="L250">    <span class="tok-kw">try</span> expect(math.isPositiveInf(pow(<span class="tok-type">f64</span>, <span class="tok-number">0.5</span>, -(<span class="tok-number">1</span> &lt;&lt; <span class="tok-number">45</span>))));</span>
<span class="line" id="L251">}</span>
<span class="line" id="L252"></span>
</code></pre></body>
</html>