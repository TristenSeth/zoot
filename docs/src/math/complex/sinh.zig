<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">    <title>math/complex/sinh.zig - source view</title>
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
<span class="line" id="L4"><span class="tok-comment">// https://git.musl-libc.org/cgit/musl/tree/src/complex/csinhf.c</span>
</span>
<span class="line" id="L5"><span class="tok-comment">// https://git.musl-libc.org/cgit/musl/tree/src/complex/csinh.c</span>
</span>
<span class="line" id="L6"></span>
<span class="line" id="L7"><span class="tok-kw">const</span> std = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;../../std.zig&quot;</span>);</span>
<span class="line" id="L8"><span class="tok-kw">const</span> testing = std.testing;</span>
<span class="line" id="L9"><span class="tok-kw">const</span> math = std.math;</span>
<span class="line" id="L10"><span class="tok-kw">const</span> cmath = math.complex;</span>
<span class="line" id="L11"><span class="tok-kw">const</span> Complex = cmath.Complex;</span>
<span class="line" id="L12"></span>
<span class="line" id="L13"><span class="tok-kw">const</span> ldexp_cexp = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;ldexp.zig&quot;</span>).ldexp_cexp;</span>
<span class="line" id="L14"></span>
<span class="line" id="L15"><span class="tok-comment">/// Returns the hyperbolic sine of z.</span></span>
<span class="line" id="L16"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">sinh</span>(z: <span class="tok-kw">anytype</span>) <span class="tok-builtin">@TypeOf</span>(z) {</span>
<span class="line" id="L17">    <span class="tok-kw">const</span> T = <span class="tok-builtin">@TypeOf</span>(z.re);</span>
<span class="line" id="L18">    <span class="tok-kw">return</span> <span class="tok-kw">switch</span> (T) {</span>
<span class="line" id="L19">        <span class="tok-type">f32</span> =&gt; sinh32(z),</span>
<span class="line" id="L20">        <span class="tok-type">f64</span> =&gt; sinh64(z),</span>
<span class="line" id="L21">        <span class="tok-kw">else</span> =&gt; <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;tan not implemented for &quot;</span> ++ <span class="tok-builtin">@typeName</span>(z)),</span>
<span class="line" id="L22">    };</span>
<span class="line" id="L23">}</span>
<span class="line" id="L24"></span>
<span class="line" id="L25"><span class="tok-kw">fn</span> <span class="tok-fn">sinh32</span>(z: Complex(<span class="tok-type">f32</span>)) Complex(<span class="tok-type">f32</span>) {</span>
<span class="line" id="L26">    <span class="tok-kw">const</span> x = z.re;</span>
<span class="line" id="L27">    <span class="tok-kw">const</span> y = z.im;</span>
<span class="line" id="L28"></span>
<span class="line" id="L29">    <span class="tok-kw">const</span> hx = <span class="tok-builtin">@bitCast</span>(<span class="tok-type">u32</span>, x);</span>
<span class="line" id="L30">    <span class="tok-kw">const</span> ix = hx &amp; <span class="tok-number">0x7fffffff</span>;</span>
<span class="line" id="L31"></span>
<span class="line" id="L32">    <span class="tok-kw">const</span> hy = <span class="tok-builtin">@bitCast</span>(<span class="tok-type">u32</span>, y);</span>
<span class="line" id="L33">    <span class="tok-kw">const</span> iy = hy &amp; <span class="tok-number">0x7fffffff</span>;</span>
<span class="line" id="L34"></span>
<span class="line" id="L35">    <span class="tok-kw">if</span> (ix &lt; <span class="tok-number">0x7f800000</span> <span class="tok-kw">and</span> iy &lt; <span class="tok-number">0x7f800000</span>) {</span>
<span class="line" id="L36">        <span class="tok-kw">if</span> (iy == <span class="tok-number">0</span>) {</span>
<span class="line" id="L37">            <span class="tok-kw">return</span> Complex(<span class="tok-type">f32</span>).init(math.sinh(x), y);</span>
<span class="line" id="L38">        }</span>
<span class="line" id="L39">        <span class="tok-comment">// small x: normal case</span>
</span>
<span class="line" id="L40">        <span class="tok-kw">if</span> (ix &lt; <span class="tok-number">0x41100000</span>) {</span>
<span class="line" id="L41">            <span class="tok-kw">return</span> Complex(<span class="tok-type">f32</span>).init(math.sinh(x) * <span class="tok-builtin">@cos</span>(y), math.cosh(x) * <span class="tok-builtin">@sin</span>(y));</span>
<span class="line" id="L42">        }</span>
<span class="line" id="L43"></span>
<span class="line" id="L44">        <span class="tok-comment">// |x|&gt;= 9, so cosh(x) ~= exp(|x|)</span>
</span>
<span class="line" id="L45">        <span class="tok-kw">if</span> (ix &lt; <span class="tok-number">0x42b17218</span>) {</span>
<span class="line" id="L46">            <span class="tok-comment">// x &lt; 88.7: exp(|x|) won't overflow</span>
</span>
<span class="line" id="L47">            <span class="tok-kw">const</span> h = <span class="tok-builtin">@exp</span>(<span class="tok-builtin">@fabs</span>(x)) * <span class="tok-number">0.5</span>;</span>
<span class="line" id="L48">            <span class="tok-kw">return</span> Complex(<span class="tok-type">f32</span>).init(math.copysign(h, x) * <span class="tok-builtin">@cos</span>(y), h * <span class="tok-builtin">@sin</span>(y));</span>
<span class="line" id="L49">        }</span>
<span class="line" id="L50">        <span class="tok-comment">// x &lt; 192.7: scale to avoid overflow</span>
</span>
<span class="line" id="L51">        <span class="tok-kw">else</span> <span class="tok-kw">if</span> (ix &lt; <span class="tok-number">0x4340b1e7</span>) {</span>
<span class="line" id="L52">            <span class="tok-kw">const</span> v = Complex(<span class="tok-type">f32</span>).init(<span class="tok-builtin">@fabs</span>(x), y);</span>
<span class="line" id="L53">            <span class="tok-kw">const</span> r = ldexp_cexp(v, -<span class="tok-number">1</span>);</span>
<span class="line" id="L54">            <span class="tok-kw">return</span> Complex(<span class="tok-type">f32</span>).init(r.re * math.copysign(<span class="tok-builtin">@as</span>(<span class="tok-type">f32</span>, <span class="tok-number">1.0</span>), x), r.im);</span>
<span class="line" id="L55">        }</span>
<span class="line" id="L56">        <span class="tok-comment">// x &gt;= 192.7: result always overflows</span>
</span>
<span class="line" id="L57">        <span class="tok-kw">else</span> {</span>
<span class="line" id="L58">            <span class="tok-kw">const</span> h = <span class="tok-number">0x1p127</span> * x;</span>
<span class="line" id="L59">            <span class="tok-kw">return</span> Complex(<span class="tok-type">f32</span>).init(h * <span class="tok-builtin">@cos</span>(y), h * h * <span class="tok-builtin">@sin</span>(y));</span>
<span class="line" id="L60">        }</span>
<span class="line" id="L61">    }</span>
<span class="line" id="L62"></span>
<span class="line" id="L63">    <span class="tok-kw">if</span> (ix == <span class="tok-number">0</span> <span class="tok-kw">and</span> iy &gt;= <span class="tok-number">0x7f800000</span>) {</span>
<span class="line" id="L64">        <span class="tok-kw">return</span> Complex(<span class="tok-type">f32</span>).init(math.copysign(<span class="tok-builtin">@as</span>(<span class="tok-type">f32</span>, <span class="tok-number">0.0</span>), x * (y - y)), y - y);</span>
<span class="line" id="L65">    }</span>
<span class="line" id="L66"></span>
<span class="line" id="L67">    <span class="tok-kw">if</span> (iy == <span class="tok-number">0</span> <span class="tok-kw">and</span> ix &gt;= <span class="tok-number">0x7f800000</span>) {</span>
<span class="line" id="L68">        <span class="tok-kw">if</span> (hx &amp; <span class="tok-number">0x7fffff</span> == <span class="tok-number">0</span>) {</span>
<span class="line" id="L69">            <span class="tok-kw">return</span> Complex(<span class="tok-type">f32</span>).init(x, y);</span>
<span class="line" id="L70">        }</span>
<span class="line" id="L71">        <span class="tok-kw">return</span> Complex(<span class="tok-type">f32</span>).init(x, math.copysign(<span class="tok-builtin">@as</span>(<span class="tok-type">f32</span>, <span class="tok-number">0.0</span>), y));</span>
<span class="line" id="L72">    }</span>
<span class="line" id="L73"></span>
<span class="line" id="L74">    <span class="tok-kw">if</span> (ix &lt; <span class="tok-number">0x7f800000</span> <span class="tok-kw">and</span> iy &gt;= <span class="tok-number">0x7f800000</span>) {</span>
<span class="line" id="L75">        <span class="tok-kw">return</span> Complex(<span class="tok-type">f32</span>).init(y - y, x * (y - y));</span>
<span class="line" id="L76">    }</span>
<span class="line" id="L77"></span>
<span class="line" id="L78">    <span class="tok-kw">if</span> (ix &gt;= <span class="tok-number">0x7f800000</span> <span class="tok-kw">and</span> (hx &amp; <span class="tok-number">0x7fffff</span>) == <span class="tok-number">0</span>) {</span>
<span class="line" id="L79">        <span class="tok-kw">if</span> (iy &gt;= <span class="tok-number">0x7f800000</span>) {</span>
<span class="line" id="L80">            <span class="tok-kw">return</span> Complex(<span class="tok-type">f32</span>).init(x * x, x * (y - y));</span>
<span class="line" id="L81">        }</span>
<span class="line" id="L82">        <span class="tok-kw">return</span> Complex(<span class="tok-type">f32</span>).init(x * <span class="tok-builtin">@cos</span>(y), math.inf(<span class="tok-type">f32</span>) * <span class="tok-builtin">@sin</span>(y));</span>
<span class="line" id="L83">    }</span>
<span class="line" id="L84"></span>
<span class="line" id="L85">    <span class="tok-kw">return</span> Complex(<span class="tok-type">f32</span>).init((x * x) * (y - y), (x + x) * (y - y));</span>
<span class="line" id="L86">}</span>
<span class="line" id="L87"></span>
<span class="line" id="L88"><span class="tok-kw">fn</span> <span class="tok-fn">sinh64</span>(z: Complex(<span class="tok-type">f64</span>)) Complex(<span class="tok-type">f64</span>) {</span>
<span class="line" id="L89">    <span class="tok-kw">const</span> x = z.re;</span>
<span class="line" id="L90">    <span class="tok-kw">const</span> y = z.im;</span>
<span class="line" id="L91"></span>
<span class="line" id="L92">    <span class="tok-kw">const</span> fx = <span class="tok-builtin">@bitCast</span>(<span class="tok-type">u64</span>, x);</span>
<span class="line" id="L93">    <span class="tok-kw">const</span> hx = <span class="tok-builtin">@intCast</span>(<span class="tok-type">u32</span>, fx &gt;&gt; <span class="tok-number">32</span>);</span>
<span class="line" id="L94">    <span class="tok-kw">const</span> lx = <span class="tok-builtin">@truncate</span>(<span class="tok-type">u32</span>, fx);</span>
<span class="line" id="L95">    <span class="tok-kw">const</span> ix = hx &amp; <span class="tok-number">0x7fffffff</span>;</span>
<span class="line" id="L96"></span>
<span class="line" id="L97">    <span class="tok-kw">const</span> fy = <span class="tok-builtin">@bitCast</span>(<span class="tok-type">u64</span>, y);</span>
<span class="line" id="L98">    <span class="tok-kw">const</span> hy = <span class="tok-builtin">@intCast</span>(<span class="tok-type">u32</span>, fy &gt;&gt; <span class="tok-number">32</span>);</span>
<span class="line" id="L99">    <span class="tok-kw">const</span> ly = <span class="tok-builtin">@truncate</span>(<span class="tok-type">u32</span>, fy);</span>
<span class="line" id="L100">    <span class="tok-kw">const</span> iy = hy &amp; <span class="tok-number">0x7fffffff</span>;</span>
<span class="line" id="L101"></span>
<span class="line" id="L102">    <span class="tok-kw">if</span> (ix &lt; <span class="tok-number">0x7ff00000</span> <span class="tok-kw">and</span> iy &lt; <span class="tok-number">0x7ff00000</span>) {</span>
<span class="line" id="L103">        <span class="tok-kw">if</span> (iy | ly == <span class="tok-number">0</span>) {</span>
<span class="line" id="L104">            <span class="tok-kw">return</span> Complex(<span class="tok-type">f64</span>).init(math.sinh(x), y);</span>
<span class="line" id="L105">        }</span>
<span class="line" id="L106">        <span class="tok-comment">// small x: normal case</span>
</span>
<span class="line" id="L107">        <span class="tok-kw">if</span> (ix &lt; <span class="tok-number">0x40360000</span>) {</span>
<span class="line" id="L108">            <span class="tok-kw">return</span> Complex(<span class="tok-type">f64</span>).init(math.sinh(x) * <span class="tok-builtin">@cos</span>(y), math.cosh(x) * <span class="tok-builtin">@sin</span>(y));</span>
<span class="line" id="L109">        }</span>
<span class="line" id="L110"></span>
<span class="line" id="L111">        <span class="tok-comment">// |x|&gt;= 22, so cosh(x) ~= exp(|x|)</span>
</span>
<span class="line" id="L112">        <span class="tok-kw">if</span> (ix &lt; <span class="tok-number">0x40862e42</span>) {</span>
<span class="line" id="L113">            <span class="tok-comment">// x &lt; 710: exp(|x|) won't overflow</span>
</span>
<span class="line" id="L114">            <span class="tok-kw">const</span> h = <span class="tok-builtin">@exp</span>(<span class="tok-builtin">@fabs</span>(x)) * <span class="tok-number">0.5</span>;</span>
<span class="line" id="L115">            <span class="tok-kw">return</span> Complex(<span class="tok-type">f64</span>).init(math.copysign(h, x) * <span class="tok-builtin">@cos</span>(y), h * <span class="tok-builtin">@sin</span>(y));</span>
<span class="line" id="L116">        }</span>
<span class="line" id="L117">        <span class="tok-comment">// x &lt; 1455: scale to avoid overflow</span>
</span>
<span class="line" id="L118">        <span class="tok-kw">else</span> <span class="tok-kw">if</span> (ix &lt; <span class="tok-number">0x4096bbaa</span>) {</span>
<span class="line" id="L119">            <span class="tok-kw">const</span> v = Complex(<span class="tok-type">f64</span>).init(<span class="tok-builtin">@fabs</span>(x), y);</span>
<span class="line" id="L120">            <span class="tok-kw">const</span> r = ldexp_cexp(v, -<span class="tok-number">1</span>);</span>
<span class="line" id="L121">            <span class="tok-kw">return</span> Complex(<span class="tok-type">f64</span>).init(r.re * math.copysign(<span class="tok-builtin">@as</span>(<span class="tok-type">f64</span>, <span class="tok-number">1.0</span>), x), r.im);</span>
<span class="line" id="L122">        }</span>
<span class="line" id="L123">        <span class="tok-comment">// x &gt;= 1455: result always overflows</span>
</span>
<span class="line" id="L124">        <span class="tok-kw">else</span> {</span>
<span class="line" id="L125">            <span class="tok-kw">const</span> h = <span class="tok-number">0x1p1023</span> * x;</span>
<span class="line" id="L126">            <span class="tok-kw">return</span> Complex(<span class="tok-type">f64</span>).init(h * <span class="tok-builtin">@cos</span>(y), h * h * <span class="tok-builtin">@sin</span>(y));</span>
<span class="line" id="L127">        }</span>
<span class="line" id="L128">    }</span>
<span class="line" id="L129"></span>
<span class="line" id="L130">    <span class="tok-kw">if</span> (ix | lx == <span class="tok-number">0</span> <span class="tok-kw">and</span> iy &gt;= <span class="tok-number">0x7ff00000</span>) {</span>
<span class="line" id="L131">        <span class="tok-kw">return</span> Complex(<span class="tok-type">f64</span>).init(math.copysign(<span class="tok-builtin">@as</span>(<span class="tok-type">f64</span>, <span class="tok-number">0.0</span>), x * (y - y)), y - y);</span>
<span class="line" id="L132">    }</span>
<span class="line" id="L133"></span>
<span class="line" id="L134">    <span class="tok-kw">if</span> (iy | ly == <span class="tok-number">0</span> <span class="tok-kw">and</span> ix &gt;= <span class="tok-number">0x7ff00000</span>) {</span>
<span class="line" id="L135">        <span class="tok-kw">if</span> ((hx &amp; <span class="tok-number">0xfffff</span>) | lx == <span class="tok-number">0</span>) {</span>
<span class="line" id="L136">            <span class="tok-kw">return</span> Complex(<span class="tok-type">f64</span>).init(x, y);</span>
<span class="line" id="L137">        }</span>
<span class="line" id="L138">        <span class="tok-kw">return</span> Complex(<span class="tok-type">f64</span>).init(x, math.copysign(<span class="tok-builtin">@as</span>(<span class="tok-type">f64</span>, <span class="tok-number">0.0</span>), y));</span>
<span class="line" id="L139">    }</span>
<span class="line" id="L140"></span>
<span class="line" id="L141">    <span class="tok-kw">if</span> (ix &lt; <span class="tok-number">0x7ff00000</span> <span class="tok-kw">and</span> iy &gt;= <span class="tok-number">0x7ff00000</span>) {</span>
<span class="line" id="L142">        <span class="tok-kw">return</span> Complex(<span class="tok-type">f64</span>).init(y - y, x * (y - y));</span>
<span class="line" id="L143">    }</span>
<span class="line" id="L144"></span>
<span class="line" id="L145">    <span class="tok-kw">if</span> (ix &gt;= <span class="tok-number">0x7ff00000</span> <span class="tok-kw">and</span> (hx &amp; <span class="tok-number">0xfffff</span>) | lx == <span class="tok-number">0</span>) {</span>
<span class="line" id="L146">        <span class="tok-kw">if</span> (iy &gt;= <span class="tok-number">0x7ff00000</span>) {</span>
<span class="line" id="L147">            <span class="tok-kw">return</span> Complex(<span class="tok-type">f64</span>).init(x * x, x * (y - y));</span>
<span class="line" id="L148">        }</span>
<span class="line" id="L149">        <span class="tok-kw">return</span> Complex(<span class="tok-type">f64</span>).init(x * <span class="tok-builtin">@cos</span>(y), math.inf(<span class="tok-type">f64</span>) * <span class="tok-builtin">@sin</span>(y));</span>
<span class="line" id="L150">    }</span>
<span class="line" id="L151"></span>
<span class="line" id="L152">    <span class="tok-kw">return</span> Complex(<span class="tok-type">f64</span>).init((x * x) * (y - y), (x + x) * (y - y));</span>
<span class="line" id="L153">}</span>
<span class="line" id="L154"></span>
<span class="line" id="L155"><span class="tok-kw">const</span> epsilon = <span class="tok-number">0.0001</span>;</span>
<span class="line" id="L156"></span>
<span class="line" id="L157"><span class="tok-kw">test</span> <span class="tok-str">&quot;complex.csinh32&quot;</span> {</span>
<span class="line" id="L158">    <span class="tok-kw">const</span> a = Complex(<span class="tok-type">f32</span>).init(<span class="tok-number">5</span>, <span class="tok-number">3</span>);</span>
<span class="line" id="L159">    <span class="tok-kw">const</span> c = sinh(a);</span>
<span class="line" id="L160"></span>
<span class="line" id="L161">    <span class="tok-kw">try</span> testing.expect(math.approxEqAbs(<span class="tok-type">f32</span>, c.re, -<span class="tok-number">73.460617</span>, epsilon));</span>
<span class="line" id="L162">    <span class="tok-kw">try</span> testing.expect(math.approxEqAbs(<span class="tok-type">f32</span>, c.im, <span class="tok-number">10.472508</span>, epsilon));</span>
<span class="line" id="L163">}</span>
<span class="line" id="L164"></span>
<span class="line" id="L165"><span class="tok-kw">test</span> <span class="tok-str">&quot;complex.csinh64&quot;</span> {</span>
<span class="line" id="L166">    <span class="tok-kw">const</span> a = Complex(<span class="tok-type">f64</span>).init(<span class="tok-number">5</span>, <span class="tok-number">3</span>);</span>
<span class="line" id="L167">    <span class="tok-kw">const</span> c = sinh(a);</span>
<span class="line" id="L168"></span>
<span class="line" id="L169">    <span class="tok-kw">try</span> testing.expect(math.approxEqAbs(<span class="tok-type">f64</span>, c.re, -<span class="tok-number">73.460617</span>, epsilon));</span>
<span class="line" id="L170">    <span class="tok-kw">try</span> testing.expect(math.approxEqAbs(<span class="tok-type">f64</span>, c.im, <span class="tok-number">10.472508</span>, epsilon));</span>
<span class="line" id="L171">}</span>
<span class="line" id="L172"></span>
</code></pre></body>
</html>