<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">    <title>math/complex/exp.zig - source view</title>
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
<span class="line" id="L4"><span class="tok-comment">// https://git.musl-libc.org/cgit/musl/tree/src/complex/cexpf.c</span>
</span>
<span class="line" id="L5"><span class="tok-comment">// https://git.musl-libc.org/cgit/musl/tree/src/complex/cexp.c</span>
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
<span class="line" id="L15"><span class="tok-comment">/// Returns e raised to the power of z (e^z).</span></span>
<span class="line" id="L16"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">exp</span>(z: <span class="tok-kw">anytype</span>) <span class="tok-builtin">@TypeOf</span>(z) {</span>
<span class="line" id="L17">    <span class="tok-kw">const</span> T = <span class="tok-builtin">@TypeOf</span>(z.re);</span>
<span class="line" id="L18"></span>
<span class="line" id="L19">    <span class="tok-kw">return</span> <span class="tok-kw">switch</span> (T) {</span>
<span class="line" id="L20">        <span class="tok-type">f32</span> =&gt; exp32(z),</span>
<span class="line" id="L21">        <span class="tok-type">f64</span> =&gt; exp64(z),</span>
<span class="line" id="L22">        <span class="tok-kw">else</span> =&gt; <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;exp not implemented for &quot;</span> ++ <span class="tok-builtin">@typeName</span>(z)),</span>
<span class="line" id="L23">    };</span>
<span class="line" id="L24">}</span>
<span class="line" id="L25"></span>
<span class="line" id="L26"><span class="tok-kw">fn</span> <span class="tok-fn">exp32</span>(z: Complex(<span class="tok-type">f32</span>)) Complex(<span class="tok-type">f32</span>) {</span>
<span class="line" id="L27">    <span class="tok-kw">const</span> exp_overflow = <span class="tok-number">0x42b17218</span>; <span class="tok-comment">// max_exp * ln2 ~= 88.72283955</span>
</span>
<span class="line" id="L28">    <span class="tok-kw">const</span> cexp_overflow = <span class="tok-number">0x43400074</span>; <span class="tok-comment">// (max_exp - min_denom_exp) * ln2</span>
</span>
<span class="line" id="L29"></span>
<span class="line" id="L30">    <span class="tok-kw">const</span> x = z.re;</span>
<span class="line" id="L31">    <span class="tok-kw">const</span> y = z.im;</span>
<span class="line" id="L32"></span>
<span class="line" id="L33">    <span class="tok-kw">const</span> hy = <span class="tok-builtin">@bitCast</span>(<span class="tok-type">u32</span>, y) &amp; <span class="tok-number">0x7fffffff</span>;</span>
<span class="line" id="L34">    <span class="tok-comment">// cexp(x + i0) = exp(x) + i0</span>
</span>
<span class="line" id="L35">    <span class="tok-kw">if</span> (hy == <span class="tok-number">0</span>) {</span>
<span class="line" id="L36">        <span class="tok-kw">return</span> Complex(<span class="tok-type">f32</span>).init(<span class="tok-builtin">@exp</span>(x), y);</span>
<span class="line" id="L37">    }</span>
<span class="line" id="L38"></span>
<span class="line" id="L39">    <span class="tok-kw">const</span> hx = <span class="tok-builtin">@bitCast</span>(<span class="tok-type">u32</span>, x);</span>
<span class="line" id="L40">    <span class="tok-comment">// cexp(0 + iy) = cos(y) + isin(y)</span>
</span>
<span class="line" id="L41">    <span class="tok-kw">if</span> ((hx &amp; <span class="tok-number">0x7fffffff</span>) == <span class="tok-number">0</span>) {</span>
<span class="line" id="L42">        <span class="tok-kw">return</span> Complex(<span class="tok-type">f32</span>).init(<span class="tok-builtin">@cos</span>(y), <span class="tok-builtin">@sin</span>(y));</span>
<span class="line" id="L43">    }</span>
<span class="line" id="L44"></span>
<span class="line" id="L45">    <span class="tok-kw">if</span> (hy &gt;= <span class="tok-number">0x7f800000</span>) {</span>
<span class="line" id="L46">        <span class="tok-comment">// cexp(finite|nan +- i inf|nan) = nan + i nan</span>
</span>
<span class="line" id="L47">        <span class="tok-kw">if</span> ((hx &amp; <span class="tok-number">0x7fffffff</span>) != <span class="tok-number">0x7f800000</span>) {</span>
<span class="line" id="L48">            <span class="tok-kw">return</span> Complex(<span class="tok-type">f32</span>).init(y - y, y - y);</span>
<span class="line" id="L49">        } <span class="tok-comment">// cexp(-inf +- i inf|nan) = 0 + i0</span>
</span>
<span class="line" id="L50">        <span class="tok-kw">else</span> <span class="tok-kw">if</span> (hx &amp; <span class="tok-number">0x80000000</span> != <span class="tok-number">0</span>) {</span>
<span class="line" id="L51">            <span class="tok-kw">return</span> Complex(<span class="tok-type">f32</span>).init(<span class="tok-number">0</span>, <span class="tok-number">0</span>);</span>
<span class="line" id="L52">        } <span class="tok-comment">// cexp(+inf +- i inf|nan) = inf + i nan</span>
</span>
<span class="line" id="L53">        <span class="tok-kw">else</span> {</span>
<span class="line" id="L54">            <span class="tok-kw">return</span> Complex(<span class="tok-type">f32</span>).init(x, y - y);</span>
<span class="line" id="L55">        }</span>
<span class="line" id="L56">    }</span>
<span class="line" id="L57"></span>
<span class="line" id="L58">    <span class="tok-comment">// 88.7 &lt;= x &lt;= 192 so must scale</span>
</span>
<span class="line" id="L59">    <span class="tok-kw">if</span> (hx &gt;= exp_overflow <span class="tok-kw">and</span> hx &lt;= cexp_overflow) {</span>
<span class="line" id="L60">        <span class="tok-kw">return</span> ldexp_cexp(z, <span class="tok-number">0</span>);</span>
<span class="line" id="L61">    } <span class="tok-comment">// - x &lt; exp_overflow =&gt; exp(x) won't overflow (common)</span>
</span>
<span class="line" id="L62">    <span class="tok-comment">// - x &gt; cexp_overflow, so exp(x) * s overflows for s &gt; 0</span>
</span>
<span class="line" id="L63">    <span class="tok-comment">// - x = +-inf</span>
</span>
<span class="line" id="L64">    <span class="tok-comment">// - x = nan</span>
</span>
<span class="line" id="L65">    <span class="tok-kw">else</span> {</span>
<span class="line" id="L66">        <span class="tok-kw">const</span> exp_x = <span class="tok-builtin">@exp</span>(x);</span>
<span class="line" id="L67">        <span class="tok-kw">return</span> Complex(<span class="tok-type">f32</span>).init(exp_x * <span class="tok-builtin">@cos</span>(y), exp_x * <span class="tok-builtin">@sin</span>(y));</span>
<span class="line" id="L68">    }</span>
<span class="line" id="L69">}</span>
<span class="line" id="L70"></span>
<span class="line" id="L71"><span class="tok-kw">fn</span> <span class="tok-fn">exp64</span>(z: Complex(<span class="tok-type">f64</span>)) Complex(<span class="tok-type">f64</span>) {</span>
<span class="line" id="L72">    <span class="tok-kw">const</span> exp_overflow = <span class="tok-number">0x40862e42</span>; <span class="tok-comment">// high bits of max_exp * ln2 ~= 710</span>
</span>
<span class="line" id="L73">    <span class="tok-kw">const</span> cexp_overflow = <span class="tok-number">0x4096b8e4</span>; <span class="tok-comment">// (max_exp - min_denorm_exp) * ln2</span>
</span>
<span class="line" id="L74"></span>
<span class="line" id="L75">    <span class="tok-kw">const</span> x = z.re;</span>
<span class="line" id="L76">    <span class="tok-kw">const</span> y = z.im;</span>
<span class="line" id="L77"></span>
<span class="line" id="L78">    <span class="tok-kw">const</span> fy = <span class="tok-builtin">@bitCast</span>(<span class="tok-type">u64</span>, y);</span>
<span class="line" id="L79">    <span class="tok-kw">const</span> hy = <span class="tok-builtin">@intCast</span>(<span class="tok-type">u32</span>, (fy &gt;&gt; <span class="tok-number">32</span>) &amp; <span class="tok-number">0x7fffffff</span>);</span>
<span class="line" id="L80">    <span class="tok-kw">const</span> ly = <span class="tok-builtin">@truncate</span>(<span class="tok-type">u32</span>, fy);</span>
<span class="line" id="L81"></span>
<span class="line" id="L82">    <span class="tok-comment">// cexp(x + i0) = exp(x) + i0</span>
</span>
<span class="line" id="L83">    <span class="tok-kw">if</span> (hy | ly == <span class="tok-number">0</span>) {</span>
<span class="line" id="L84">        <span class="tok-kw">return</span> Complex(<span class="tok-type">f64</span>).init(<span class="tok-builtin">@exp</span>(x), y);</span>
<span class="line" id="L85">    }</span>
<span class="line" id="L86"></span>
<span class="line" id="L87">    <span class="tok-kw">const</span> fx = <span class="tok-builtin">@bitCast</span>(<span class="tok-type">u64</span>, x);</span>
<span class="line" id="L88">    <span class="tok-kw">const</span> hx = <span class="tok-builtin">@intCast</span>(<span class="tok-type">u32</span>, fx &gt;&gt; <span class="tok-number">32</span>);</span>
<span class="line" id="L89">    <span class="tok-kw">const</span> lx = <span class="tok-builtin">@truncate</span>(<span class="tok-type">u32</span>, fx);</span>
<span class="line" id="L90"></span>
<span class="line" id="L91">    <span class="tok-comment">// cexp(0 + iy) = cos(y) + isin(y)</span>
</span>
<span class="line" id="L92">    <span class="tok-kw">if</span> ((hx &amp; <span class="tok-number">0x7fffffff</span>) | lx == <span class="tok-number">0</span>) {</span>
<span class="line" id="L93">        <span class="tok-kw">return</span> Complex(<span class="tok-type">f64</span>).init(<span class="tok-builtin">@cos</span>(y), <span class="tok-builtin">@sin</span>(y));</span>
<span class="line" id="L94">    }</span>
<span class="line" id="L95"></span>
<span class="line" id="L96">    <span class="tok-kw">if</span> (hy &gt;= <span class="tok-number">0x7ff00000</span>) {</span>
<span class="line" id="L97">        <span class="tok-comment">// cexp(finite|nan +- i inf|nan) = nan + i nan</span>
</span>
<span class="line" id="L98">        <span class="tok-kw">if</span> (lx != <span class="tok-number">0</span> <span class="tok-kw">or</span> (hx &amp; <span class="tok-number">0x7fffffff</span>) != <span class="tok-number">0x7ff00000</span>) {</span>
<span class="line" id="L99">            <span class="tok-kw">return</span> Complex(<span class="tok-type">f64</span>).init(y - y, y - y);</span>
<span class="line" id="L100">        } <span class="tok-comment">// cexp(-inf +- i inf|nan) = 0 + i0</span>
</span>
<span class="line" id="L101">        <span class="tok-kw">else</span> <span class="tok-kw">if</span> (hx &amp; <span class="tok-number">0x80000000</span> != <span class="tok-number">0</span>) {</span>
<span class="line" id="L102">            <span class="tok-kw">return</span> Complex(<span class="tok-type">f64</span>).init(<span class="tok-number">0</span>, <span class="tok-number">0</span>);</span>
<span class="line" id="L103">        } <span class="tok-comment">// cexp(+inf +- i inf|nan) = inf + i nan</span>
</span>
<span class="line" id="L104">        <span class="tok-kw">else</span> {</span>
<span class="line" id="L105">            <span class="tok-kw">return</span> Complex(<span class="tok-type">f64</span>).init(x, y - y);</span>
<span class="line" id="L106">        }</span>
<span class="line" id="L107">    }</span>
<span class="line" id="L108"></span>
<span class="line" id="L109">    <span class="tok-comment">// 709.7 &lt;= x &lt;= 1454.3 so must scale</span>
</span>
<span class="line" id="L110">    <span class="tok-kw">if</span> (hx &gt;= exp_overflow <span class="tok-kw">and</span> hx &lt;= cexp_overflow) {</span>
<span class="line" id="L111">        <span class="tok-kw">return</span> ldexp_cexp(z, <span class="tok-number">0</span>);</span>
<span class="line" id="L112">    } <span class="tok-comment">// - x &lt; exp_overflow =&gt; exp(x) won't overflow (common)</span>
</span>
<span class="line" id="L113">    <span class="tok-comment">// - x &gt; cexp_overflow, so exp(x) * s overflows for s &gt; 0</span>
</span>
<span class="line" id="L114">    <span class="tok-comment">// - x = +-inf</span>
</span>
<span class="line" id="L115">    <span class="tok-comment">// - x = nan</span>
</span>
<span class="line" id="L116">    <span class="tok-kw">else</span> {</span>
<span class="line" id="L117">        <span class="tok-kw">const</span> exp_x = <span class="tok-builtin">@exp</span>(x);</span>
<span class="line" id="L118">        <span class="tok-kw">return</span> Complex(<span class="tok-type">f64</span>).init(exp_x * <span class="tok-builtin">@cos</span>(y), exp_x * <span class="tok-builtin">@sin</span>(y));</span>
<span class="line" id="L119">    }</span>
<span class="line" id="L120">}</span>
<span class="line" id="L121"></span>
<span class="line" id="L122"><span class="tok-kw">test</span> <span class="tok-str">&quot;complex.cexp32&quot;</span> {</span>
<span class="line" id="L123">    <span class="tok-kw">const</span> tolerance_f32 = <span class="tok-builtin">@sqrt</span>(math.floatEps(<span class="tok-type">f32</span>));</span>
<span class="line" id="L124"></span>
<span class="line" id="L125">    {</span>
<span class="line" id="L126">        <span class="tok-kw">const</span> a = Complex(<span class="tok-type">f32</span>).init(<span class="tok-number">5</span>, <span class="tok-number">3</span>);</span>
<span class="line" id="L127">        <span class="tok-kw">const</span> c = exp(a);</span>
<span class="line" id="L128"></span>
<span class="line" id="L129">        <span class="tok-kw">try</span> testing.expectApproxEqRel(<span class="tok-builtin">@as</span>(<span class="tok-type">f32</span>, -<span class="tok-number">1.46927917e+02</span>), c.re, tolerance_f32);</span>
<span class="line" id="L130">        <span class="tok-kw">try</span> testing.expectApproxEqRel(<span class="tok-builtin">@as</span>(<span class="tok-type">f32</span>, <span class="tok-number">2.0944065e+01</span>), c.im, tolerance_f32);</span>
<span class="line" id="L131">    }</span>
<span class="line" id="L132"></span>
<span class="line" id="L133">    {</span>
<span class="line" id="L134">        <span class="tok-kw">const</span> a = Complex(<span class="tok-type">f32</span>).init(<span class="tok-number">88.8</span>, <span class="tok-number">0x1p-149</span>);</span>
<span class="line" id="L135">        <span class="tok-kw">const</span> c = exp(a);</span>
<span class="line" id="L136"></span>
<span class="line" id="L137">        <span class="tok-kw">try</span> testing.expectApproxEqAbs(math.inf(<span class="tok-type">f32</span>), c.re, tolerance_f32);</span>
<span class="line" id="L138">        <span class="tok-kw">try</span> testing.expectApproxEqAbs(<span class="tok-builtin">@as</span>(<span class="tok-type">f32</span>, <span class="tok-number">5.15088629e-07</span>), c.im, tolerance_f32);</span>
<span class="line" id="L139">    }</span>
<span class="line" id="L140">}</span>
<span class="line" id="L141"></span>
<span class="line" id="L142"><span class="tok-kw">test</span> <span class="tok-str">&quot;complex.cexp64&quot;</span> {</span>
<span class="line" id="L143">    <span class="tok-kw">const</span> tolerance_f64 = <span class="tok-builtin">@sqrt</span>(math.floatEps(<span class="tok-type">f64</span>));</span>
<span class="line" id="L144"></span>
<span class="line" id="L145">    {</span>
<span class="line" id="L146">        <span class="tok-kw">const</span> a = Complex(<span class="tok-type">f64</span>).init(<span class="tok-number">5</span>, <span class="tok-number">3</span>);</span>
<span class="line" id="L147">        <span class="tok-kw">const</span> c = exp(a);</span>
<span class="line" id="L148"></span>
<span class="line" id="L149">        <span class="tok-kw">try</span> testing.expectApproxEqRel(<span class="tok-builtin">@as</span>(<span class="tok-type">f64</span>, -<span class="tok-number">1.469279139083189e+02</span>), c.re, tolerance_f64);</span>
<span class="line" id="L150">        <span class="tok-kw">try</span> testing.expectApproxEqRel(<span class="tok-builtin">@as</span>(<span class="tok-type">f64</span>, <span class="tok-number">2.094406620874596e+01</span>), c.im, tolerance_f64);</span>
<span class="line" id="L151">    }</span>
<span class="line" id="L152"></span>
<span class="line" id="L153">    {</span>
<span class="line" id="L154">        <span class="tok-kw">const</span> a = Complex(<span class="tok-type">f64</span>).init(<span class="tok-number">709.8</span>, <span class="tok-number">0x1p-1074</span>);</span>
<span class="line" id="L155">        <span class="tok-kw">const</span> c = exp(a);</span>
<span class="line" id="L156"></span>
<span class="line" id="L157">        <span class="tok-kw">try</span> testing.expectApproxEqAbs(math.inf(<span class="tok-type">f64</span>), c.re, tolerance_f64);</span>
<span class="line" id="L158">        <span class="tok-kw">try</span> testing.expectApproxEqAbs(<span class="tok-builtin">@as</span>(<span class="tok-type">f64</span>, <span class="tok-number">9.036659362159884e-16</span>), c.im, tolerance_f64);</span>
<span class="line" id="L159">    }</span>
<span class="line" id="L160">}</span>
<span class="line" id="L161"></span>
</code></pre></body>
</html>