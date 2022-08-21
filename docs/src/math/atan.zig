<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">    <title>math/atan.zig - source view</title>
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
<span class="line" id="L4"><span class="tok-comment">// https://git.musl-libc.org/cgit/musl/tree/src/math/atanf.c</span>
</span>
<span class="line" id="L5"><span class="tok-comment">// https://git.musl-libc.org/cgit/musl/tree/src/math/atan.c</span>
</span>
<span class="line" id="L6"></span>
<span class="line" id="L7"><span class="tok-kw">const</span> std = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;../std.zig&quot;</span>);</span>
<span class="line" id="L8"><span class="tok-kw">const</span> math = std.math;</span>
<span class="line" id="L9"><span class="tok-kw">const</span> expect = std.testing.expect;</span>
<span class="line" id="L10"></span>
<span class="line" id="L11"><span class="tok-comment">/// Returns the arc-tangent of x.</span></span>
<span class="line" id="L12"><span class="tok-comment">///</span></span>
<span class="line" id="L13"><span class="tok-comment">/// Special Cases:</span></span>
<span class="line" id="L14"><span class="tok-comment">///  - atan(+-0)   = +-0</span></span>
<span class="line" id="L15"><span class="tok-comment">///  - atan(+-inf) = +-pi/2</span></span>
<span class="line" id="L16"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">atan</span>(x: <span class="tok-kw">anytype</span>) <span class="tok-builtin">@TypeOf</span>(x) {</span>
<span class="line" id="L17">    <span class="tok-kw">const</span> T = <span class="tok-builtin">@TypeOf</span>(x);</span>
<span class="line" id="L18">    <span class="tok-kw">return</span> <span class="tok-kw">switch</span> (T) {</span>
<span class="line" id="L19">        <span class="tok-type">f32</span> =&gt; atan32(x),</span>
<span class="line" id="L20">        <span class="tok-type">f64</span> =&gt; atan64(x),</span>
<span class="line" id="L21">        <span class="tok-kw">else</span> =&gt; <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;atan not implemented for &quot;</span> ++ <span class="tok-builtin">@typeName</span>(T)),</span>
<span class="line" id="L22">    };</span>
<span class="line" id="L23">}</span>
<span class="line" id="L24"></span>
<span class="line" id="L25"><span class="tok-kw">fn</span> <span class="tok-fn">atan32</span>(x_: <span class="tok-type">f32</span>) <span class="tok-type">f32</span> {</span>
<span class="line" id="L26">    <span class="tok-kw">const</span> atanhi = [_]<span class="tok-type">f32</span>{</span>
<span class="line" id="L27">        <span class="tok-number">4.6364760399e-01</span>, <span class="tok-comment">// atan(0.5)hi</span>
</span>
<span class="line" id="L28">        <span class="tok-number">7.8539812565e-01</span>, <span class="tok-comment">// atan(1.0)hi</span>
</span>
<span class="line" id="L29">        <span class="tok-number">9.8279368877e-01</span>, <span class="tok-comment">// atan(1.5)hi</span>
</span>
<span class="line" id="L30">        <span class="tok-number">1.5707962513e+00</span>, <span class="tok-comment">// atan(inf)hi</span>
</span>
<span class="line" id="L31">    };</span>
<span class="line" id="L32"></span>
<span class="line" id="L33">    <span class="tok-kw">const</span> atanlo = [_]<span class="tok-type">f32</span>{</span>
<span class="line" id="L34">        <span class="tok-number">5.0121582440e-09</span>, <span class="tok-comment">// atan(0.5)lo</span>
</span>
<span class="line" id="L35">        <span class="tok-number">3.7748947079e-08</span>, <span class="tok-comment">// atan(1.0)lo</span>
</span>
<span class="line" id="L36">        <span class="tok-number">3.4473217170e-08</span>, <span class="tok-comment">// atan(1.5)lo</span>
</span>
<span class="line" id="L37">        <span class="tok-number">7.5497894159e-08</span>, <span class="tok-comment">// atan(inf)lo</span>
</span>
<span class="line" id="L38">    };</span>
<span class="line" id="L39"></span>
<span class="line" id="L40">    <span class="tok-kw">const</span> aT = [_]<span class="tok-type">f32</span>{</span>
<span class="line" id="L41">        <span class="tok-number">3.3333328366e-01</span>,</span>
<span class="line" id="L42">        -<span class="tok-number">1.9999158382e-01</span>,</span>
<span class="line" id="L43">        <span class="tok-number">1.4253635705e-01</span>,</span>
<span class="line" id="L44">        -<span class="tok-number">1.0648017377e-01</span>,</span>
<span class="line" id="L45">        <span class="tok-number">6.1687607318e-02</span>,</span>
<span class="line" id="L46">    };</span>
<span class="line" id="L47"></span>
<span class="line" id="L48">    <span class="tok-kw">var</span> x = x_;</span>
<span class="line" id="L49">    <span class="tok-kw">var</span> ix: <span class="tok-type">u32</span> = <span class="tok-builtin">@bitCast</span>(<span class="tok-type">u32</span>, x);</span>
<span class="line" id="L50">    <span class="tok-kw">const</span> sign = ix &gt;&gt; <span class="tok-number">31</span>;</span>
<span class="line" id="L51">    ix &amp;= <span class="tok-number">0x7FFFFFFF</span>;</span>
<span class="line" id="L52"></span>
<span class="line" id="L53">    <span class="tok-comment">// |x| &gt;= 2^26</span>
</span>
<span class="line" id="L54">    <span class="tok-kw">if</span> (ix &gt;= <span class="tok-number">0x4C800000</span>) {</span>
<span class="line" id="L55">        <span class="tok-kw">if</span> (math.isNan(x)) {</span>
<span class="line" id="L56">            <span class="tok-kw">return</span> x;</span>
<span class="line" id="L57">        } <span class="tok-kw">else</span> {</span>
<span class="line" id="L58">            <span class="tok-kw">const</span> z = atanhi[<span class="tok-number">3</span>] + <span class="tok-number">0x1.0p-120</span>;</span>
<span class="line" id="L59">            <span class="tok-kw">return</span> <span class="tok-kw">if</span> (sign != <span class="tok-number">0</span>) -z <span class="tok-kw">else</span> z;</span>
<span class="line" id="L60">        }</span>
<span class="line" id="L61">    }</span>
<span class="line" id="L62"></span>
<span class="line" id="L63">    <span class="tok-kw">var</span> id: ?<span class="tok-type">usize</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L64"></span>
<span class="line" id="L65">    <span class="tok-comment">// |x| &lt; 0.4375</span>
</span>
<span class="line" id="L66">    <span class="tok-kw">if</span> (ix &lt; <span class="tok-number">0x3EE00000</span>) {</span>
<span class="line" id="L67">        <span class="tok-comment">// |x| &lt; 2^(-12)</span>
</span>
<span class="line" id="L68">        <span class="tok-kw">if</span> (ix &lt; <span class="tok-number">0x39800000</span>) {</span>
<span class="line" id="L69">            <span class="tok-kw">if</span> (ix &lt; <span class="tok-number">0x00800000</span>) {</span>
<span class="line" id="L70">                math.doNotOptimizeAway(x * x);</span>
<span class="line" id="L71">            }</span>
<span class="line" id="L72">            <span class="tok-kw">return</span> x;</span>
<span class="line" id="L73">        }</span>
<span class="line" id="L74">        id = <span class="tok-null">null</span>;</span>
<span class="line" id="L75">    } <span class="tok-kw">else</span> {</span>
<span class="line" id="L76">        x = <span class="tok-builtin">@fabs</span>(x);</span>
<span class="line" id="L77">        <span class="tok-comment">// |x| &lt; 1.1875</span>
</span>
<span class="line" id="L78">        <span class="tok-kw">if</span> (ix &lt; <span class="tok-number">0x3F980000</span>) {</span>
<span class="line" id="L79">            <span class="tok-comment">// 7/16 &lt;= |x| &lt; 11/16</span>
</span>
<span class="line" id="L80">            <span class="tok-kw">if</span> (ix &lt; <span class="tok-number">0x3F300000</span>) {</span>
<span class="line" id="L81">                id = <span class="tok-number">0</span>;</span>
<span class="line" id="L82">                x = (<span class="tok-number">2.0</span> * x - <span class="tok-number">1.0</span>) / (<span class="tok-number">2.0</span> + x);</span>
<span class="line" id="L83">            }</span>
<span class="line" id="L84">            <span class="tok-comment">// 11/16 &lt;= |x| &lt; 19/16</span>
</span>
<span class="line" id="L85">            <span class="tok-kw">else</span> {</span>
<span class="line" id="L86">                id = <span class="tok-number">1</span>;</span>
<span class="line" id="L87">                x = (x - <span class="tok-number">1.0</span>) / (x + <span class="tok-number">1.0</span>);</span>
<span class="line" id="L88">            }</span>
<span class="line" id="L89">        } <span class="tok-kw">else</span> {</span>
<span class="line" id="L90">            <span class="tok-comment">// |x| &lt; 2.4375</span>
</span>
<span class="line" id="L91">            <span class="tok-kw">if</span> (ix &lt; <span class="tok-number">0x401C0000</span>) {</span>
<span class="line" id="L92">                id = <span class="tok-number">2</span>;</span>
<span class="line" id="L93">                x = (x - <span class="tok-number">1.5</span>) / (<span class="tok-number">1.0</span> + <span class="tok-number">1.5</span> * x);</span>
<span class="line" id="L94">            }</span>
<span class="line" id="L95">            <span class="tok-comment">// 2.4375 &lt;= |x| &lt; 2^26</span>
</span>
<span class="line" id="L96">            <span class="tok-kw">else</span> {</span>
<span class="line" id="L97">                id = <span class="tok-number">3</span>;</span>
<span class="line" id="L98">                x = -<span class="tok-number">1.0</span> / x;</span>
<span class="line" id="L99">            }</span>
<span class="line" id="L100">        }</span>
<span class="line" id="L101">    }</span>
<span class="line" id="L102"></span>
<span class="line" id="L103">    <span class="tok-kw">const</span> z = x * x;</span>
<span class="line" id="L104">    <span class="tok-kw">const</span> w = z * z;</span>
<span class="line" id="L105">    <span class="tok-kw">const</span> s1 = z * (aT[<span class="tok-number">0</span>] + w * (aT[<span class="tok-number">2</span>] + w * aT[<span class="tok-number">4</span>]));</span>
<span class="line" id="L106">    <span class="tok-kw">const</span> s2 = w * (aT[<span class="tok-number">1</span>] + w * aT[<span class="tok-number">3</span>]);</span>
<span class="line" id="L107"></span>
<span class="line" id="L108">    <span class="tok-kw">if</span> (id) |id_value| {</span>
<span class="line" id="L109">        <span class="tok-kw">const</span> zz = atanhi[id_value] - ((x * (s1 + s2) - atanlo[id_value]) - x);</span>
<span class="line" id="L110">        <span class="tok-kw">return</span> <span class="tok-kw">if</span> (sign != <span class="tok-number">0</span>) -zz <span class="tok-kw">else</span> zz;</span>
<span class="line" id="L111">    } <span class="tok-kw">else</span> {</span>
<span class="line" id="L112">        <span class="tok-kw">return</span> x - x * (s1 + s2);</span>
<span class="line" id="L113">    }</span>
<span class="line" id="L114">}</span>
<span class="line" id="L115"></span>
<span class="line" id="L116"><span class="tok-kw">fn</span> <span class="tok-fn">atan64</span>(x_: <span class="tok-type">f64</span>) <span class="tok-type">f64</span> {</span>
<span class="line" id="L117">    <span class="tok-kw">const</span> atanhi = [_]<span class="tok-type">f64</span>{</span>
<span class="line" id="L118">        <span class="tok-number">4.63647609000806093515e-01</span>, <span class="tok-comment">// atan(0.5)hi</span>
</span>
<span class="line" id="L119">        <span class="tok-number">7.85398163397448278999e-01</span>, <span class="tok-comment">// atan(1.0)hi</span>
</span>
<span class="line" id="L120">        <span class="tok-number">9.82793723247329054082e-01</span>, <span class="tok-comment">// atan(1.5)hi</span>
</span>
<span class="line" id="L121">        <span class="tok-number">1.57079632679489655800e+00</span>, <span class="tok-comment">// atan(inf)hi</span>
</span>
<span class="line" id="L122">    };</span>
<span class="line" id="L123"></span>
<span class="line" id="L124">    <span class="tok-kw">const</span> atanlo = [_]<span class="tok-type">f64</span>{</span>
<span class="line" id="L125">        <span class="tok-number">2.26987774529616870924e-17</span>, <span class="tok-comment">// atan(0.5)lo</span>
</span>
<span class="line" id="L126">        <span class="tok-number">3.06161699786838301793e-17</span>, <span class="tok-comment">// atan(1.0)lo</span>
</span>
<span class="line" id="L127">        <span class="tok-number">1.39033110312309984516e-17</span>, <span class="tok-comment">// atan(1.5)lo</span>
</span>
<span class="line" id="L128">        <span class="tok-number">6.12323399573676603587e-17</span>, <span class="tok-comment">// atan(inf)lo</span>
</span>
<span class="line" id="L129">    };</span>
<span class="line" id="L130"></span>
<span class="line" id="L131">    <span class="tok-kw">const</span> aT = [_]<span class="tok-type">f64</span>{</span>
<span class="line" id="L132">        <span class="tok-number">3.33333333333329318027e-01</span>,</span>
<span class="line" id="L133">        -<span class="tok-number">1.99999999998764832476e-01</span>,</span>
<span class="line" id="L134">        <span class="tok-number">1.42857142725034663711e-01</span>,</span>
<span class="line" id="L135">        -<span class="tok-number">1.11111104054623557880e-01</span>,</span>
<span class="line" id="L136">        <span class="tok-number">9.09088713343650656196e-02</span>,</span>
<span class="line" id="L137">        -<span class="tok-number">7.69187620504482999495e-02</span>,</span>
<span class="line" id="L138">        <span class="tok-number">6.66107313738753120669e-02</span>,</span>
<span class="line" id="L139">        -<span class="tok-number">5.83357013379057348645e-02</span>,</span>
<span class="line" id="L140">        <span class="tok-number">4.97687799461593236017e-02</span>,</span>
<span class="line" id="L141">        -<span class="tok-number">3.65315727442169155270e-02</span>,</span>
<span class="line" id="L142">        <span class="tok-number">1.62858201153657823623e-02</span>,</span>
<span class="line" id="L143">    };</span>
<span class="line" id="L144"></span>
<span class="line" id="L145">    <span class="tok-kw">var</span> x = x_;</span>
<span class="line" id="L146">    <span class="tok-kw">var</span> ux = <span class="tok-builtin">@bitCast</span>(<span class="tok-type">u64</span>, x);</span>
<span class="line" id="L147">    <span class="tok-kw">var</span> ix = <span class="tok-builtin">@intCast</span>(<span class="tok-type">u32</span>, ux &gt;&gt; <span class="tok-number">32</span>);</span>
<span class="line" id="L148">    <span class="tok-kw">const</span> sign = ix &gt;&gt; <span class="tok-number">31</span>;</span>
<span class="line" id="L149">    ix &amp;= <span class="tok-number">0x7FFFFFFF</span>;</span>
<span class="line" id="L150"></span>
<span class="line" id="L151">    <span class="tok-comment">// |x| &gt;= 2^66</span>
</span>
<span class="line" id="L152">    <span class="tok-kw">if</span> (ix &gt;= <span class="tok-number">0x44100000</span>) {</span>
<span class="line" id="L153">        <span class="tok-kw">if</span> (math.isNan(x)) {</span>
<span class="line" id="L154">            <span class="tok-kw">return</span> x;</span>
<span class="line" id="L155">        } <span class="tok-kw">else</span> {</span>
<span class="line" id="L156">            <span class="tok-kw">const</span> z = atanhi[<span class="tok-number">3</span>] + <span class="tok-number">0x1.0p-120</span>;</span>
<span class="line" id="L157">            <span class="tok-kw">return</span> <span class="tok-kw">if</span> (sign != <span class="tok-number">0</span>) -z <span class="tok-kw">else</span> z;</span>
<span class="line" id="L158">        }</span>
<span class="line" id="L159">    }</span>
<span class="line" id="L160"></span>
<span class="line" id="L161">    <span class="tok-kw">var</span> id: ?<span class="tok-type">usize</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L162"></span>
<span class="line" id="L163">    <span class="tok-comment">// |x| &lt; 0.4375</span>
</span>
<span class="line" id="L164">    <span class="tok-kw">if</span> (ix &lt; <span class="tok-number">0x3DFC0000</span>) {</span>
<span class="line" id="L165">        <span class="tok-comment">// |x| &lt; 2^(-27)</span>
</span>
<span class="line" id="L166">        <span class="tok-kw">if</span> (ix &lt; <span class="tok-number">0x3E400000</span>) {</span>
<span class="line" id="L167">            <span class="tok-kw">if</span> (ix &lt; <span class="tok-number">0x00100000</span>) {</span>
<span class="line" id="L168">                math.doNotOptimizeAway(<span class="tok-builtin">@floatCast</span>(<span class="tok-type">f32</span>, x));</span>
<span class="line" id="L169">            }</span>
<span class="line" id="L170">            <span class="tok-kw">return</span> x;</span>
<span class="line" id="L171">        }</span>
<span class="line" id="L172">        id = <span class="tok-null">null</span>;</span>
<span class="line" id="L173">    } <span class="tok-kw">else</span> {</span>
<span class="line" id="L174">        x = <span class="tok-builtin">@fabs</span>(x);</span>
<span class="line" id="L175">        <span class="tok-comment">// |x| &lt; 1.1875</span>
</span>
<span class="line" id="L176">        <span class="tok-kw">if</span> (ix &lt; <span class="tok-number">0x3FF30000</span>) {</span>
<span class="line" id="L177">            <span class="tok-comment">// 7/16 &lt;= |x| &lt; 11/16</span>
</span>
<span class="line" id="L178">            <span class="tok-kw">if</span> (ix &lt; <span class="tok-number">0x3FE60000</span>) {</span>
<span class="line" id="L179">                id = <span class="tok-number">0</span>;</span>
<span class="line" id="L180">                x = (<span class="tok-number">2.0</span> * x - <span class="tok-number">1.0</span>) / (<span class="tok-number">2.0</span> + x);</span>
<span class="line" id="L181">            }</span>
<span class="line" id="L182">            <span class="tok-comment">// 11/16 &lt;= |x| &lt; 19/16</span>
</span>
<span class="line" id="L183">            <span class="tok-kw">else</span> {</span>
<span class="line" id="L184">                id = <span class="tok-number">1</span>;</span>
<span class="line" id="L185">                x = (x - <span class="tok-number">1.0</span>) / (x + <span class="tok-number">1.0</span>);</span>
<span class="line" id="L186">            }</span>
<span class="line" id="L187">        } <span class="tok-kw">else</span> {</span>
<span class="line" id="L188">            <span class="tok-comment">// |x| &lt; 2.4375</span>
</span>
<span class="line" id="L189">            <span class="tok-kw">if</span> (ix &lt; <span class="tok-number">0x40038000</span>) {</span>
<span class="line" id="L190">                id = <span class="tok-number">2</span>;</span>
<span class="line" id="L191">                x = (x - <span class="tok-number">1.5</span>) / (<span class="tok-number">1.0</span> + <span class="tok-number">1.5</span> * x);</span>
<span class="line" id="L192">            }</span>
<span class="line" id="L193">            <span class="tok-comment">// 2.4375 &lt;= |x| &lt; 2^66</span>
</span>
<span class="line" id="L194">            <span class="tok-kw">else</span> {</span>
<span class="line" id="L195">                id = <span class="tok-number">3</span>;</span>
<span class="line" id="L196">                x = -<span class="tok-number">1.0</span> / x;</span>
<span class="line" id="L197">            }</span>
<span class="line" id="L198">        }</span>
<span class="line" id="L199">    }</span>
<span class="line" id="L200"></span>
<span class="line" id="L201">    <span class="tok-kw">const</span> z = x * x;</span>
<span class="line" id="L202">    <span class="tok-kw">const</span> w = z * z;</span>
<span class="line" id="L203">    <span class="tok-kw">const</span> s1 = z * (aT[<span class="tok-number">0</span>] + w * (aT[<span class="tok-number">2</span>] + w * (aT[<span class="tok-number">4</span>] + w * (aT[<span class="tok-number">6</span>] + w * (aT[<span class="tok-number">8</span>] + w * aT[<span class="tok-number">10</span>])))));</span>
<span class="line" id="L204">    <span class="tok-kw">const</span> s2 = w * (aT[<span class="tok-number">1</span>] + w * (aT[<span class="tok-number">3</span>] + w * (aT[<span class="tok-number">5</span>] + w * (aT[<span class="tok-number">7</span>] + w * aT[<span class="tok-number">9</span>]))));</span>
<span class="line" id="L205"></span>
<span class="line" id="L206">    <span class="tok-kw">if</span> (id) |id_value| {</span>
<span class="line" id="L207">        <span class="tok-kw">const</span> zz = atanhi[id_value] - ((x * (s1 + s2) - atanlo[id_value]) - x);</span>
<span class="line" id="L208">        <span class="tok-kw">return</span> <span class="tok-kw">if</span> (sign != <span class="tok-number">0</span>) -zz <span class="tok-kw">else</span> zz;</span>
<span class="line" id="L209">    } <span class="tok-kw">else</span> {</span>
<span class="line" id="L210">        <span class="tok-kw">return</span> x - x * (s1 + s2);</span>
<span class="line" id="L211">    }</span>
<span class="line" id="L212">}</span>
<span class="line" id="L213"></span>
<span class="line" id="L214"><span class="tok-kw">test</span> <span class="tok-str">&quot;math.atan&quot;</span> {</span>
<span class="line" id="L215">    <span class="tok-kw">try</span> expect(<span class="tok-builtin">@bitCast</span>(<span class="tok-type">u32</span>, atan(<span class="tok-builtin">@as</span>(<span class="tok-type">f32</span>, <span class="tok-number">0.2</span>))) == <span class="tok-builtin">@bitCast</span>(<span class="tok-type">u32</span>, atan32(<span class="tok-number">0.2</span>)));</span>
<span class="line" id="L216">    <span class="tok-kw">try</span> expect(atan(<span class="tok-builtin">@as</span>(<span class="tok-type">f64</span>, <span class="tok-number">0.2</span>)) == atan64(<span class="tok-number">0.2</span>));</span>
<span class="line" id="L217">}</span>
<span class="line" id="L218"></span>
<span class="line" id="L219"><span class="tok-kw">test</span> <span class="tok-str">&quot;math.atan32&quot;</span> {</span>
<span class="line" id="L220">    <span class="tok-kw">const</span> epsilon = <span class="tok-number">0.000001</span>;</span>
<span class="line" id="L221"></span>
<span class="line" id="L222">    <span class="tok-kw">try</span> expect(math.approxEqAbs(<span class="tok-type">f32</span>, atan32(<span class="tok-number">0.2</span>), <span class="tok-number">0.197396</span>, epsilon));</span>
<span class="line" id="L223">    <span class="tok-kw">try</span> expect(math.approxEqAbs(<span class="tok-type">f32</span>, atan32(-<span class="tok-number">0.2</span>), -<span class="tok-number">0.197396</span>, epsilon));</span>
<span class="line" id="L224">    <span class="tok-kw">try</span> expect(math.approxEqAbs(<span class="tok-type">f32</span>, atan32(<span class="tok-number">0.3434</span>), <span class="tok-number">0.330783</span>, epsilon));</span>
<span class="line" id="L225">    <span class="tok-kw">try</span> expect(math.approxEqAbs(<span class="tok-type">f32</span>, atan32(<span class="tok-number">0.8923</span>), <span class="tok-number">0.728545</span>, epsilon));</span>
<span class="line" id="L226">    <span class="tok-kw">try</span> expect(math.approxEqAbs(<span class="tok-type">f32</span>, atan32(<span class="tok-number">1.5</span>), <span class="tok-number">0.982794</span>, epsilon));</span>
<span class="line" id="L227">}</span>
<span class="line" id="L228"></span>
<span class="line" id="L229"><span class="tok-kw">test</span> <span class="tok-str">&quot;math.atan64&quot;</span> {</span>
<span class="line" id="L230">    <span class="tok-kw">const</span> epsilon = <span class="tok-number">0.000001</span>;</span>
<span class="line" id="L231"></span>
<span class="line" id="L232">    <span class="tok-kw">try</span> expect(math.approxEqAbs(<span class="tok-type">f64</span>, atan64(<span class="tok-number">0.2</span>), <span class="tok-number">0.197396</span>, epsilon));</span>
<span class="line" id="L233">    <span class="tok-kw">try</span> expect(math.approxEqAbs(<span class="tok-type">f64</span>, atan64(-<span class="tok-number">0.2</span>), -<span class="tok-number">0.197396</span>, epsilon));</span>
<span class="line" id="L234">    <span class="tok-kw">try</span> expect(math.approxEqAbs(<span class="tok-type">f64</span>, atan64(<span class="tok-number">0.3434</span>), <span class="tok-number">0.330783</span>, epsilon));</span>
<span class="line" id="L235">    <span class="tok-kw">try</span> expect(math.approxEqAbs(<span class="tok-type">f64</span>, atan64(<span class="tok-number">0.8923</span>), <span class="tok-number">0.728545</span>, epsilon));</span>
<span class="line" id="L236">    <span class="tok-kw">try</span> expect(math.approxEqAbs(<span class="tok-type">f64</span>, atan64(<span class="tok-number">1.5</span>), <span class="tok-number">0.982794</span>, epsilon));</span>
<span class="line" id="L237">}</span>
<span class="line" id="L238"></span>
<span class="line" id="L239"><span class="tok-kw">test</span> <span class="tok-str">&quot;math.atan32.special&quot;</span> {</span>
<span class="line" id="L240">    <span class="tok-kw">const</span> epsilon = <span class="tok-number">0.000001</span>;</span>
<span class="line" id="L241"></span>
<span class="line" id="L242">    <span class="tok-kw">try</span> expect(atan32(<span class="tok-number">0.0</span>) == <span class="tok-number">0.0</span>);</span>
<span class="line" id="L243">    <span class="tok-kw">try</span> expect(atan32(-<span class="tok-number">0.0</span>) == -<span class="tok-number">0.0</span>);</span>
<span class="line" id="L244">    <span class="tok-kw">try</span> expect(math.approxEqAbs(<span class="tok-type">f32</span>, atan32(math.inf(<span class="tok-type">f32</span>)), math.pi / <span class="tok-number">2.0</span>, epsilon));</span>
<span class="line" id="L245">    <span class="tok-kw">try</span> expect(math.approxEqAbs(<span class="tok-type">f32</span>, atan32(-math.inf(<span class="tok-type">f32</span>)), -math.pi / <span class="tok-number">2.0</span>, epsilon));</span>
<span class="line" id="L246">}</span>
<span class="line" id="L247"></span>
<span class="line" id="L248"><span class="tok-kw">test</span> <span class="tok-str">&quot;math.atan64.special&quot;</span> {</span>
<span class="line" id="L249">    <span class="tok-kw">const</span> epsilon = <span class="tok-number">0.000001</span>;</span>
<span class="line" id="L250"></span>
<span class="line" id="L251">    <span class="tok-kw">try</span> expect(atan64(<span class="tok-number">0.0</span>) == <span class="tok-number">0.0</span>);</span>
<span class="line" id="L252">    <span class="tok-kw">try</span> expect(atan64(-<span class="tok-number">0.0</span>) == -<span class="tok-number">0.0</span>);</span>
<span class="line" id="L253">    <span class="tok-kw">try</span> expect(math.approxEqAbs(<span class="tok-type">f64</span>, atan64(math.inf(<span class="tok-type">f64</span>)), math.pi / <span class="tok-number">2.0</span>, epsilon));</span>
<span class="line" id="L254">    <span class="tok-kw">try</span> expect(math.approxEqAbs(<span class="tok-type">f64</span>, atan64(-math.inf(<span class="tok-type">f64</span>)), -math.pi / <span class="tok-number">2.0</span>, epsilon));</span>
<span class="line" id="L255">}</span>
<span class="line" id="L256"></span>
</code></pre></body>
</html>