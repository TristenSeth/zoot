<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">    <title>math/complex/atan.zig - source view</title>
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
<span class="line" id="L4"><span class="tok-comment">// https://git.musl-libc.org/cgit/musl/tree/src/complex/catanf.c</span>
</span>
<span class="line" id="L5"><span class="tok-comment">// https://git.musl-libc.org/cgit/musl/tree/src/complex/catan.c</span>
</span>
<span class="line" id="L6"></span>
<span class="line" id="L7"><span class="tok-kw">const</span> std = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;../../std.zig&quot;</span>);</span>
<span class="line" id="L8"><span class="tok-kw">const</span> testing = std.testing;</span>
<span class="line" id="L9"><span class="tok-kw">const</span> math = std.math;</span>
<span class="line" id="L10"><span class="tok-kw">const</span> cmath = math.complex;</span>
<span class="line" id="L11"><span class="tok-kw">const</span> Complex = cmath.Complex;</span>
<span class="line" id="L12"></span>
<span class="line" id="L13"><span class="tok-comment">/// Returns the arc-tangent of z.</span></span>
<span class="line" id="L14"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">atan</span>(z: <span class="tok-kw">anytype</span>) <span class="tok-builtin">@TypeOf</span>(z) {</span>
<span class="line" id="L15">    <span class="tok-kw">const</span> T = <span class="tok-builtin">@TypeOf</span>(z.re);</span>
<span class="line" id="L16">    <span class="tok-kw">return</span> <span class="tok-kw">switch</span> (T) {</span>
<span class="line" id="L17">        <span class="tok-type">f32</span> =&gt; atan32(z),</span>
<span class="line" id="L18">        <span class="tok-type">f64</span> =&gt; atan64(z),</span>
<span class="line" id="L19">        <span class="tok-kw">else</span> =&gt; <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;atan not implemented for &quot;</span> ++ <span class="tok-builtin">@typeName</span>(z)),</span>
<span class="line" id="L20">    };</span>
<span class="line" id="L21">}</span>
<span class="line" id="L22"></span>
<span class="line" id="L23"><span class="tok-kw">fn</span> <span class="tok-fn">redupif32</span>(x: <span class="tok-type">f32</span>) <span class="tok-type">f32</span> {</span>
<span class="line" id="L24">    <span class="tok-kw">const</span> DP1 = <span class="tok-number">3.140625</span>;</span>
<span class="line" id="L25">    <span class="tok-kw">const</span> DP2 = <span class="tok-number">9.67502593994140625e-4</span>;</span>
<span class="line" id="L26">    <span class="tok-kw">const</span> DP3 = <span class="tok-number">1.509957990978376432e-7</span>;</span>
<span class="line" id="L27"></span>
<span class="line" id="L28">    <span class="tok-kw">var</span> t = x / math.pi;</span>
<span class="line" id="L29">    <span class="tok-kw">if</span> (t &gt;= <span class="tok-number">0.0</span>) {</span>
<span class="line" id="L30">        t += <span class="tok-number">0.5</span>;</span>
<span class="line" id="L31">    } <span class="tok-kw">else</span> {</span>
<span class="line" id="L32">        t -= <span class="tok-number">0.5</span>;</span>
<span class="line" id="L33">    }</span>
<span class="line" id="L34"></span>
<span class="line" id="L35">    <span class="tok-kw">const</span> u = <span class="tok-builtin">@intToFloat</span>(<span class="tok-type">f32</span>, <span class="tok-builtin">@floatToInt</span>(<span class="tok-type">i32</span>, t));</span>
<span class="line" id="L36">    <span class="tok-kw">return</span> ((x - u * DP1) - u * DP2) - t * DP3;</span>
<span class="line" id="L37">}</span>
<span class="line" id="L38"></span>
<span class="line" id="L39"><span class="tok-kw">fn</span> <span class="tok-fn">atan32</span>(z: Complex(<span class="tok-type">f32</span>)) Complex(<span class="tok-type">f32</span>) {</span>
<span class="line" id="L40">    <span class="tok-kw">const</span> maxnum = <span class="tok-number">1.0e38</span>;</span>
<span class="line" id="L41"></span>
<span class="line" id="L42">    <span class="tok-kw">const</span> x = z.re;</span>
<span class="line" id="L43">    <span class="tok-kw">const</span> y = z.im;</span>
<span class="line" id="L44"></span>
<span class="line" id="L45">    <span class="tok-kw">if</span> ((x == <span class="tok-number">0.0</span>) <span class="tok-kw">and</span> (y &gt; <span class="tok-number">1.0</span>)) {</span>
<span class="line" id="L46">        <span class="tok-comment">// overflow</span>
</span>
<span class="line" id="L47">        <span class="tok-kw">return</span> Complex(<span class="tok-type">f32</span>).init(maxnum, maxnum);</span>
<span class="line" id="L48">    }</span>
<span class="line" id="L49"></span>
<span class="line" id="L50">    <span class="tok-kw">const</span> x2 = x * x;</span>
<span class="line" id="L51">    <span class="tok-kw">var</span> a = <span class="tok-number">1.0</span> - x2 - (y * y);</span>
<span class="line" id="L52">    <span class="tok-kw">if</span> (a == <span class="tok-number">0.0</span>) {</span>
<span class="line" id="L53">        <span class="tok-comment">// overflow</span>
</span>
<span class="line" id="L54">        <span class="tok-kw">return</span> Complex(<span class="tok-type">f32</span>).init(maxnum, maxnum);</span>
<span class="line" id="L55">    }</span>
<span class="line" id="L56"></span>
<span class="line" id="L57">    <span class="tok-kw">var</span> t = <span class="tok-number">0.5</span> * math.atan2(<span class="tok-type">f32</span>, <span class="tok-number">2.0</span> * x, a);</span>
<span class="line" id="L58">    <span class="tok-kw">var</span> w = redupif32(t);</span>
<span class="line" id="L59"></span>
<span class="line" id="L60">    t = y - <span class="tok-number">1.0</span>;</span>
<span class="line" id="L61">    a = x2 + t * t;</span>
<span class="line" id="L62">    <span class="tok-kw">if</span> (a == <span class="tok-number">0.0</span>) {</span>
<span class="line" id="L63">        <span class="tok-comment">// overflow</span>
</span>
<span class="line" id="L64">        <span class="tok-kw">return</span> Complex(<span class="tok-type">f32</span>).init(maxnum, maxnum);</span>
<span class="line" id="L65">    }</span>
<span class="line" id="L66"></span>
<span class="line" id="L67">    t = y + <span class="tok-number">1.0</span>;</span>
<span class="line" id="L68">    a = (x2 + (t * t)) / a;</span>
<span class="line" id="L69">    <span class="tok-kw">return</span> Complex(<span class="tok-type">f32</span>).init(w, <span class="tok-number">0.25</span> * <span class="tok-builtin">@log</span>(a));</span>
<span class="line" id="L70">}</span>
<span class="line" id="L71"></span>
<span class="line" id="L72"><span class="tok-kw">fn</span> <span class="tok-fn">redupif64</span>(x: <span class="tok-type">f64</span>) <span class="tok-type">f64</span> {</span>
<span class="line" id="L73">    <span class="tok-kw">const</span> DP1 = <span class="tok-number">3.14159265160560607910</span>;</span>
<span class="line" id="L74">    <span class="tok-kw">const</span> DP2 = <span class="tok-number">1.98418714791870343106e-9</span>;</span>
<span class="line" id="L75">    <span class="tok-kw">const</span> DP3 = <span class="tok-number">1.14423774522196636802e-17</span>;</span>
<span class="line" id="L76"></span>
<span class="line" id="L77">    <span class="tok-kw">var</span> t = x / math.pi;</span>
<span class="line" id="L78">    <span class="tok-kw">if</span> (t &gt;= <span class="tok-number">0.0</span>) {</span>
<span class="line" id="L79">        t += <span class="tok-number">0.5</span>;</span>
<span class="line" id="L80">    } <span class="tok-kw">else</span> {</span>
<span class="line" id="L81">        t -= <span class="tok-number">0.5</span>;</span>
<span class="line" id="L82">    }</span>
<span class="line" id="L83"></span>
<span class="line" id="L84">    <span class="tok-kw">const</span> u = <span class="tok-builtin">@intToFloat</span>(<span class="tok-type">f64</span>, <span class="tok-builtin">@floatToInt</span>(<span class="tok-type">i64</span>, t));</span>
<span class="line" id="L85">    <span class="tok-kw">return</span> ((x - u * DP1) - u * DP2) - t * DP3;</span>
<span class="line" id="L86">}</span>
<span class="line" id="L87"></span>
<span class="line" id="L88"><span class="tok-kw">fn</span> <span class="tok-fn">atan64</span>(z: Complex(<span class="tok-type">f64</span>)) Complex(<span class="tok-type">f64</span>) {</span>
<span class="line" id="L89">    <span class="tok-kw">const</span> maxnum = <span class="tok-number">1.0e308</span>;</span>
<span class="line" id="L90"></span>
<span class="line" id="L91">    <span class="tok-kw">const</span> x = z.re;</span>
<span class="line" id="L92">    <span class="tok-kw">const</span> y = z.im;</span>
<span class="line" id="L93"></span>
<span class="line" id="L94">    <span class="tok-kw">if</span> ((x == <span class="tok-number">0.0</span>) <span class="tok-kw">and</span> (y &gt; <span class="tok-number">1.0</span>)) {</span>
<span class="line" id="L95">        <span class="tok-comment">// overflow</span>
</span>
<span class="line" id="L96">        <span class="tok-kw">return</span> Complex(<span class="tok-type">f64</span>).init(maxnum, maxnum);</span>
<span class="line" id="L97">    }</span>
<span class="line" id="L98"></span>
<span class="line" id="L99">    <span class="tok-kw">const</span> x2 = x * x;</span>
<span class="line" id="L100">    <span class="tok-kw">var</span> a = <span class="tok-number">1.0</span> - x2 - (y * y);</span>
<span class="line" id="L101">    <span class="tok-kw">if</span> (a == <span class="tok-number">0.0</span>) {</span>
<span class="line" id="L102">        <span class="tok-comment">// overflow</span>
</span>
<span class="line" id="L103">        <span class="tok-kw">return</span> Complex(<span class="tok-type">f64</span>).init(maxnum, maxnum);</span>
<span class="line" id="L104">    }</span>
<span class="line" id="L105"></span>
<span class="line" id="L106">    <span class="tok-kw">var</span> t = <span class="tok-number">0.5</span> * math.atan2(<span class="tok-type">f64</span>, <span class="tok-number">2.0</span> * x, a);</span>
<span class="line" id="L107">    <span class="tok-kw">var</span> w = redupif64(t);</span>
<span class="line" id="L108"></span>
<span class="line" id="L109">    t = y - <span class="tok-number">1.0</span>;</span>
<span class="line" id="L110">    a = x2 + t * t;</span>
<span class="line" id="L111">    <span class="tok-kw">if</span> (a == <span class="tok-number">0.0</span>) {</span>
<span class="line" id="L112">        <span class="tok-comment">// overflow</span>
</span>
<span class="line" id="L113">        <span class="tok-kw">return</span> Complex(<span class="tok-type">f64</span>).init(maxnum, maxnum);</span>
<span class="line" id="L114">    }</span>
<span class="line" id="L115"></span>
<span class="line" id="L116">    t = y + <span class="tok-number">1.0</span>;</span>
<span class="line" id="L117">    a = (x2 + (t * t)) / a;</span>
<span class="line" id="L118">    <span class="tok-kw">return</span> Complex(<span class="tok-type">f64</span>).init(w, <span class="tok-number">0.25</span> * <span class="tok-builtin">@log</span>(a));</span>
<span class="line" id="L119">}</span>
<span class="line" id="L120"></span>
<span class="line" id="L121"><span class="tok-kw">const</span> epsilon = <span class="tok-number">0.0001</span>;</span>
<span class="line" id="L122"></span>
<span class="line" id="L123"><span class="tok-kw">test</span> <span class="tok-str">&quot;complex.catan32&quot;</span> {</span>
<span class="line" id="L124">    <span class="tok-kw">const</span> a = Complex(<span class="tok-type">f32</span>).init(<span class="tok-number">5</span>, <span class="tok-number">3</span>);</span>
<span class="line" id="L125">    <span class="tok-kw">const</span> c = atan(a);</span>
<span class="line" id="L126"></span>
<span class="line" id="L127">    <span class="tok-kw">try</span> testing.expect(math.approxEqAbs(<span class="tok-type">f32</span>, c.re, <span class="tok-number">1.423679</span>, epsilon));</span>
<span class="line" id="L128">    <span class="tok-kw">try</span> testing.expect(math.approxEqAbs(<span class="tok-type">f32</span>, c.im, <span class="tok-number">0.086569</span>, epsilon));</span>
<span class="line" id="L129">}</span>
<span class="line" id="L130"></span>
<span class="line" id="L131"><span class="tok-kw">test</span> <span class="tok-str">&quot;complex.catan64&quot;</span> {</span>
<span class="line" id="L132">    <span class="tok-kw">const</span> a = Complex(<span class="tok-type">f64</span>).init(<span class="tok-number">5</span>, <span class="tok-number">3</span>);</span>
<span class="line" id="L133">    <span class="tok-kw">const</span> c = atan(a);</span>
<span class="line" id="L134"></span>
<span class="line" id="L135">    <span class="tok-kw">try</span> testing.expect(math.approxEqAbs(<span class="tok-type">f64</span>, c.re, <span class="tok-number">1.423679</span>, epsilon));</span>
<span class="line" id="L136">    <span class="tok-kw">try</span> testing.expect(math.approxEqAbs(<span class="tok-type">f64</span>, c.im, <span class="tok-number">0.086569</span>, epsilon));</span>
<span class="line" id="L137">}</span>
<span class="line" id="L138"></span>
</code></pre></body>
</html>