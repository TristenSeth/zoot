<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">    <title>math/frexp.zig - source view</title>
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
<pre><code><span class="line" id="L1"><span class="tok-comment">// Ported from musl, which is MIT licensed:</span>
</span>
<span class="line" id="L2"><span class="tok-comment">// https://git.musl-libc.org/cgit/musl/tree/COPYRIGHT</span>
</span>
<span class="line" id="L3"><span class="tok-comment">//</span>
</span>
<span class="line" id="L4"><span class="tok-comment">// https://git.musl-libc.org/cgit/musl/tree/src/math/frexpl.c</span>
</span>
<span class="line" id="L5"><span class="tok-comment">// https://git.musl-libc.org/cgit/musl/tree/src/math/frexpf.c</span>
</span>
<span class="line" id="L6"><span class="tok-comment">// https://git.musl-libc.org/cgit/musl/tree/src/math/frexp.c</span>
</span>
<span class="line" id="L7"></span>
<span class="line" id="L8"><span class="tok-kw">const</span> std = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;../std.zig&quot;</span>);</span>
<span class="line" id="L9"><span class="tok-kw">const</span> math = std.math;</span>
<span class="line" id="L10"><span class="tok-kw">const</span> expect = std.testing.expect;</span>
<span class="line" id="L11"></span>
<span class="line" id="L12"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">Frexp</span>(<span class="tok-kw">comptime</span> T: <span class="tok-type">type</span>) <span class="tok-type">type</span> {</span>
<span class="line" id="L13">    <span class="tok-kw">return</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L14">        significand: T,</span>
<span class="line" id="L15">        exponent: <span class="tok-type">i32</span>,</span>
<span class="line" id="L16">    };</span>
<span class="line" id="L17">}</span>
<span class="line" id="L18"></span>
<span class="line" id="L19"><span class="tok-comment">/// Breaks x into a normalized fraction and an integral power of two.</span></span>
<span class="line" id="L20"><span class="tok-comment">/// f == frac * 2^exp, with |frac| in the interval [0.5, 1).</span></span>
<span class="line" id="L21"><span class="tok-comment">///</span></span>
<span class="line" id="L22"><span class="tok-comment">/// Special Cases:</span></span>
<span class="line" id="L23"><span class="tok-comment">///  - frexp(+-0)   = +-0, 0</span></span>
<span class="line" id="L24"><span class="tok-comment">///  - frexp(+-inf) = +-inf, 0</span></span>
<span class="line" id="L25"><span class="tok-comment">///  - frexp(nan)   = nan, undefined</span></span>
<span class="line" id="L26"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">frexp</span>(x: <span class="tok-kw">anytype</span>) Frexp(<span class="tok-builtin">@TypeOf</span>(x)) {</span>
<span class="line" id="L27">    <span class="tok-kw">const</span> T = <span class="tok-builtin">@TypeOf</span>(x);</span>
<span class="line" id="L28">    <span class="tok-kw">return</span> <span class="tok-kw">switch</span> (T) {</span>
<span class="line" id="L29">        <span class="tok-type">f32</span> =&gt; frexp32(x),</span>
<span class="line" id="L30">        <span class="tok-type">f64</span> =&gt; frexp64(x),</span>
<span class="line" id="L31">        <span class="tok-type">f128</span> =&gt; frexp128(x),</span>
<span class="line" id="L32">        <span class="tok-kw">else</span> =&gt; <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;frexp not implemented for &quot;</span> ++ <span class="tok-builtin">@typeName</span>(T)),</span>
<span class="line" id="L33">    };</span>
<span class="line" id="L34">}</span>
<span class="line" id="L35"></span>
<span class="line" id="L36"><span class="tok-comment">// TODO: unify all these implementations using generics</span>
</span>
<span class="line" id="L37"></span>
<span class="line" id="L38"><span class="tok-kw">fn</span> <span class="tok-fn">frexp32</span>(x: <span class="tok-type">f32</span>) Frexp(<span class="tok-type">f32</span>) {</span>
<span class="line" id="L39">    <span class="tok-kw">var</span> result: Frexp(<span class="tok-type">f32</span>) = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L40"></span>
<span class="line" id="L41">    <span class="tok-kw">var</span> y = <span class="tok-builtin">@bitCast</span>(<span class="tok-type">u32</span>, x);</span>
<span class="line" id="L42">    <span class="tok-kw">const</span> e = <span class="tok-builtin">@intCast</span>(<span class="tok-type">i32</span>, y &gt;&gt; <span class="tok-number">23</span>) &amp; <span class="tok-number">0xFF</span>;</span>
<span class="line" id="L43"></span>
<span class="line" id="L44">    <span class="tok-kw">if</span> (e == <span class="tok-number">0</span>) {</span>
<span class="line" id="L45">        <span class="tok-kw">if</span> (x != <span class="tok-number">0</span>) {</span>
<span class="line" id="L46">            <span class="tok-comment">// subnormal</span>
</span>
<span class="line" id="L47">            result = frexp32(x * <span class="tok-number">0x1.0p64</span>);</span>
<span class="line" id="L48">            result.exponent -= <span class="tok-number">64</span>;</span>
<span class="line" id="L49">        } <span class="tok-kw">else</span> {</span>
<span class="line" id="L50">            <span class="tok-comment">// frexp(+-0) = (+-0, 0)</span>
</span>
<span class="line" id="L51">            result.significand = x;</span>
<span class="line" id="L52">            result.exponent = <span class="tok-number">0</span>;</span>
<span class="line" id="L53">        }</span>
<span class="line" id="L54">        <span class="tok-kw">return</span> result;</span>
<span class="line" id="L55">    } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (e == <span class="tok-number">0xFF</span>) {</span>
<span class="line" id="L56">        <span class="tok-comment">// frexp(nan) = (nan, undefined)</span>
</span>
<span class="line" id="L57">        result.significand = x;</span>
<span class="line" id="L58">        result.exponent = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L59"></span>
<span class="line" id="L60">        <span class="tok-comment">// frexp(+-inf) = (+-inf, 0)</span>
</span>
<span class="line" id="L61">        <span class="tok-kw">if</span> (math.isInf(x)) {</span>
<span class="line" id="L62">            result.exponent = <span class="tok-number">0</span>;</span>
<span class="line" id="L63">        }</span>
<span class="line" id="L64"></span>
<span class="line" id="L65">        <span class="tok-kw">return</span> result;</span>
<span class="line" id="L66">    }</span>
<span class="line" id="L67"></span>
<span class="line" id="L68">    result.exponent = e - <span class="tok-number">0x7E</span>;</span>
<span class="line" id="L69">    y &amp;= <span class="tok-number">0x807FFFFF</span>;</span>
<span class="line" id="L70">    y |= <span class="tok-number">0x3F000000</span>;</span>
<span class="line" id="L71">    result.significand = <span class="tok-builtin">@bitCast</span>(<span class="tok-type">f32</span>, y);</span>
<span class="line" id="L72">    <span class="tok-kw">return</span> result;</span>
<span class="line" id="L73">}</span>
<span class="line" id="L74"></span>
<span class="line" id="L75"><span class="tok-kw">fn</span> <span class="tok-fn">frexp64</span>(x: <span class="tok-type">f64</span>) Frexp(<span class="tok-type">f64</span>) {</span>
<span class="line" id="L76">    <span class="tok-kw">var</span> result: Frexp(<span class="tok-type">f64</span>) = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L77"></span>
<span class="line" id="L78">    <span class="tok-kw">var</span> y = <span class="tok-builtin">@bitCast</span>(<span class="tok-type">u64</span>, x);</span>
<span class="line" id="L79">    <span class="tok-kw">const</span> e = <span class="tok-builtin">@intCast</span>(<span class="tok-type">i32</span>, y &gt;&gt; <span class="tok-number">52</span>) &amp; <span class="tok-number">0x7FF</span>;</span>
<span class="line" id="L80"></span>
<span class="line" id="L81">    <span class="tok-kw">if</span> (e == <span class="tok-number">0</span>) {</span>
<span class="line" id="L82">        <span class="tok-kw">if</span> (x != <span class="tok-number">0</span>) {</span>
<span class="line" id="L83">            <span class="tok-comment">// subnormal</span>
</span>
<span class="line" id="L84">            result = frexp64(x * <span class="tok-number">0x1.0p64</span>);</span>
<span class="line" id="L85">            result.exponent -= <span class="tok-number">64</span>;</span>
<span class="line" id="L86">        } <span class="tok-kw">else</span> {</span>
<span class="line" id="L87">            <span class="tok-comment">// frexp(+-0) = (+-0, 0)</span>
</span>
<span class="line" id="L88">            result.significand = x;</span>
<span class="line" id="L89">            result.exponent = <span class="tok-number">0</span>;</span>
<span class="line" id="L90">        }</span>
<span class="line" id="L91">        <span class="tok-kw">return</span> result;</span>
<span class="line" id="L92">    } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (e == <span class="tok-number">0x7FF</span>) {</span>
<span class="line" id="L93">        <span class="tok-comment">// frexp(nan) = (nan, undefined)</span>
</span>
<span class="line" id="L94">        result.significand = x;</span>
<span class="line" id="L95">        result.exponent = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L96"></span>
<span class="line" id="L97">        <span class="tok-comment">// frexp(+-inf) = (+-inf, 0)</span>
</span>
<span class="line" id="L98">        <span class="tok-kw">if</span> (math.isInf(x)) {</span>
<span class="line" id="L99">            result.exponent = <span class="tok-number">0</span>;</span>
<span class="line" id="L100">        }</span>
<span class="line" id="L101"></span>
<span class="line" id="L102">        <span class="tok-kw">return</span> result;</span>
<span class="line" id="L103">    }</span>
<span class="line" id="L104"></span>
<span class="line" id="L105">    result.exponent = e - <span class="tok-number">0x3FE</span>;</span>
<span class="line" id="L106">    y &amp;= <span class="tok-number">0x800FFFFFFFFFFFFF</span>;</span>
<span class="line" id="L107">    y |= <span class="tok-number">0x3FE0000000000000</span>;</span>
<span class="line" id="L108">    result.significand = <span class="tok-builtin">@bitCast</span>(<span class="tok-type">f64</span>, y);</span>
<span class="line" id="L109">    <span class="tok-kw">return</span> result;</span>
<span class="line" id="L110">}</span>
<span class="line" id="L111"></span>
<span class="line" id="L112"><span class="tok-kw">fn</span> <span class="tok-fn">frexp128</span>(x: <span class="tok-type">f128</span>) Frexp(<span class="tok-type">f128</span>) {</span>
<span class="line" id="L113">    <span class="tok-kw">var</span> result: Frexp(<span class="tok-type">f128</span>) = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L114"></span>
<span class="line" id="L115">    <span class="tok-kw">var</span> y = <span class="tok-builtin">@bitCast</span>(<span class="tok-type">u128</span>, x);</span>
<span class="line" id="L116">    <span class="tok-kw">const</span> e = <span class="tok-builtin">@intCast</span>(<span class="tok-type">i32</span>, y &gt;&gt; <span class="tok-number">112</span>) &amp; <span class="tok-number">0x7FFF</span>;</span>
<span class="line" id="L117"></span>
<span class="line" id="L118">    <span class="tok-kw">if</span> (e == <span class="tok-number">0</span>) {</span>
<span class="line" id="L119">        <span class="tok-kw">if</span> (x != <span class="tok-number">0</span>) {</span>
<span class="line" id="L120">            <span class="tok-comment">// subnormal</span>
</span>
<span class="line" id="L121">            result = frexp128(x * <span class="tok-number">0x1.0p120</span>);</span>
<span class="line" id="L122">            result.exponent -= <span class="tok-number">120</span>;</span>
<span class="line" id="L123">        } <span class="tok-kw">else</span> {</span>
<span class="line" id="L124">            <span class="tok-comment">// frexp(+-0) = (+-0, 0)</span>
</span>
<span class="line" id="L125">            result.significand = x;</span>
<span class="line" id="L126">            result.exponent = <span class="tok-number">0</span>;</span>
<span class="line" id="L127">        }</span>
<span class="line" id="L128">        <span class="tok-kw">return</span> result;</span>
<span class="line" id="L129">    } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (e == <span class="tok-number">0x7FFF</span>) {</span>
<span class="line" id="L130">        <span class="tok-comment">// frexp(nan) = (nan, undefined)</span>
</span>
<span class="line" id="L131">        result.significand = x;</span>
<span class="line" id="L132">        result.exponent = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L133"></span>
<span class="line" id="L134">        <span class="tok-comment">// frexp(+-inf) = (+-inf, 0)</span>
</span>
<span class="line" id="L135">        <span class="tok-kw">if</span> (math.isInf(x)) {</span>
<span class="line" id="L136">            result.exponent = <span class="tok-number">0</span>;</span>
<span class="line" id="L137">        }</span>
<span class="line" id="L138"></span>
<span class="line" id="L139">        <span class="tok-kw">return</span> result;</span>
<span class="line" id="L140">    }</span>
<span class="line" id="L141"></span>
<span class="line" id="L142">    result.exponent = e - <span class="tok-number">0x3FFE</span>;</span>
<span class="line" id="L143">    y &amp;= <span class="tok-number">0x8000FFFFFFFFFFFFFFFFFFFFFFFFFFFF</span>;</span>
<span class="line" id="L144">    y |= <span class="tok-number">0x3FFE0000000000000000000000000000</span>;</span>
<span class="line" id="L145">    result.significand = <span class="tok-builtin">@bitCast</span>(<span class="tok-type">f128</span>, y);</span>
<span class="line" id="L146">    <span class="tok-kw">return</span> result;</span>
<span class="line" id="L147">}</span>
<span class="line" id="L148"></span>
<span class="line" id="L149"><span class="tok-kw">test</span> <span class="tok-str">&quot;type dispatch&quot;</span> {</span>
<span class="line" id="L150">    <span class="tok-kw">const</span> a = frexp(<span class="tok-builtin">@as</span>(<span class="tok-type">f32</span>, <span class="tok-number">1.3</span>));</span>
<span class="line" id="L151">    <span class="tok-kw">const</span> b = frexp32(<span class="tok-number">1.3</span>);</span>
<span class="line" id="L152">    <span class="tok-kw">try</span> expect(a.significand == b.significand <span class="tok-kw">and</span> a.exponent == b.exponent);</span>
<span class="line" id="L153"></span>
<span class="line" id="L154">    <span class="tok-kw">const</span> c = frexp(<span class="tok-builtin">@as</span>(<span class="tok-type">f64</span>, <span class="tok-number">1.3</span>));</span>
<span class="line" id="L155">    <span class="tok-kw">const</span> d = frexp64(<span class="tok-number">1.3</span>);</span>
<span class="line" id="L156">    <span class="tok-kw">try</span> expect(c.significand == d.significand <span class="tok-kw">and</span> c.exponent == d.exponent);</span>
<span class="line" id="L157"></span>
<span class="line" id="L158">    <span class="tok-kw">const</span> e = frexp(<span class="tok-builtin">@as</span>(<span class="tok-type">f128</span>, <span class="tok-number">1.3</span>));</span>
<span class="line" id="L159">    <span class="tok-kw">const</span> f = frexp128(<span class="tok-number">1.3</span>);</span>
<span class="line" id="L160">    <span class="tok-kw">try</span> expect(e.significand == f.significand <span class="tok-kw">and</span> e.exponent == f.exponent);</span>
<span class="line" id="L161">}</span>
<span class="line" id="L162"></span>
<span class="line" id="L163"><span class="tok-kw">test</span> <span class="tok-str">&quot;32&quot;</span> {</span>
<span class="line" id="L164">    <span class="tok-kw">const</span> epsilon = <span class="tok-number">0.000001</span>;</span>
<span class="line" id="L165">    <span class="tok-kw">var</span> r: Frexp(<span class="tok-type">f32</span>) = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L166"></span>
<span class="line" id="L167">    r = frexp32(<span class="tok-number">1.3</span>);</span>
<span class="line" id="L168">    <span class="tok-kw">try</span> expect(math.approxEqAbs(<span class="tok-type">f32</span>, r.significand, <span class="tok-number">0.65</span>, epsilon) <span class="tok-kw">and</span> r.exponent == <span class="tok-number">1</span>);</span>
<span class="line" id="L169"></span>
<span class="line" id="L170">    r = frexp32(<span class="tok-number">78.0234</span>);</span>
<span class="line" id="L171">    <span class="tok-kw">try</span> expect(math.approxEqAbs(<span class="tok-type">f32</span>, r.significand, <span class="tok-number">0.609558</span>, epsilon) <span class="tok-kw">and</span> r.exponent == <span class="tok-number">7</span>);</span>
<span class="line" id="L172">}</span>
<span class="line" id="L173"></span>
<span class="line" id="L174"><span class="tok-kw">test</span> <span class="tok-str">&quot;64&quot;</span> {</span>
<span class="line" id="L175">    <span class="tok-kw">const</span> epsilon = <span class="tok-number">0.000001</span>;</span>
<span class="line" id="L176">    <span class="tok-kw">var</span> r: Frexp(<span class="tok-type">f64</span>) = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L177"></span>
<span class="line" id="L178">    r = frexp64(<span class="tok-number">1.3</span>);</span>
<span class="line" id="L179">    <span class="tok-kw">try</span> expect(math.approxEqAbs(<span class="tok-type">f64</span>, r.significand, <span class="tok-number">0.65</span>, epsilon) <span class="tok-kw">and</span> r.exponent == <span class="tok-number">1</span>);</span>
<span class="line" id="L180"></span>
<span class="line" id="L181">    r = frexp64(<span class="tok-number">78.0234</span>);</span>
<span class="line" id="L182">    <span class="tok-kw">try</span> expect(math.approxEqAbs(<span class="tok-type">f64</span>, r.significand, <span class="tok-number">0.609558</span>, epsilon) <span class="tok-kw">and</span> r.exponent == <span class="tok-number">7</span>);</span>
<span class="line" id="L183">}</span>
<span class="line" id="L184"></span>
<span class="line" id="L185"><span class="tok-kw">test</span> <span class="tok-str">&quot;128&quot;</span> {</span>
<span class="line" id="L186">    <span class="tok-kw">const</span> epsilon = <span class="tok-number">0.000001</span>;</span>
<span class="line" id="L187">    <span class="tok-kw">var</span> r: Frexp(<span class="tok-type">f128</span>) = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L188"></span>
<span class="line" id="L189">    r = frexp128(<span class="tok-number">1.3</span>);</span>
<span class="line" id="L190">    <span class="tok-kw">try</span> expect(math.approxEqAbs(<span class="tok-type">f128</span>, r.significand, <span class="tok-number">0.65</span>, epsilon) <span class="tok-kw">and</span> r.exponent == <span class="tok-number">1</span>);</span>
<span class="line" id="L191"></span>
<span class="line" id="L192">    r = frexp128(<span class="tok-number">78.0234</span>);</span>
<span class="line" id="L193">    <span class="tok-kw">try</span> expect(math.approxEqAbs(<span class="tok-type">f128</span>, r.significand, <span class="tok-number">0.609558</span>, epsilon) <span class="tok-kw">and</span> r.exponent == <span class="tok-number">7</span>);</span>
<span class="line" id="L194">}</span>
<span class="line" id="L195"></span>
<span class="line" id="L196"><span class="tok-kw">test</span> <span class="tok-str">&quot;32 special&quot;</span> {</span>
<span class="line" id="L197">    <span class="tok-kw">var</span> r: Frexp(<span class="tok-type">f32</span>) = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L198"></span>
<span class="line" id="L199">    r = frexp32(<span class="tok-number">0.0</span>);</span>
<span class="line" id="L200">    <span class="tok-kw">try</span> expect(r.significand == <span class="tok-number">0.0</span> <span class="tok-kw">and</span> r.exponent == <span class="tok-number">0</span>);</span>
<span class="line" id="L201"></span>
<span class="line" id="L202">    r = frexp32(-<span class="tok-number">0.0</span>);</span>
<span class="line" id="L203">    <span class="tok-kw">try</span> expect(r.significand == -<span class="tok-number">0.0</span> <span class="tok-kw">and</span> r.exponent == <span class="tok-number">0</span>);</span>
<span class="line" id="L204"></span>
<span class="line" id="L205">    r = frexp32(math.inf(<span class="tok-type">f32</span>));</span>
<span class="line" id="L206">    <span class="tok-kw">try</span> expect(math.isPositiveInf(r.significand) <span class="tok-kw">and</span> r.exponent == <span class="tok-number">0</span>);</span>
<span class="line" id="L207"></span>
<span class="line" id="L208">    r = frexp32(-math.inf(<span class="tok-type">f32</span>));</span>
<span class="line" id="L209">    <span class="tok-kw">try</span> expect(math.isNegativeInf(r.significand) <span class="tok-kw">and</span> r.exponent == <span class="tok-number">0</span>);</span>
<span class="line" id="L210"></span>
<span class="line" id="L211">    r = frexp32(math.nan(<span class="tok-type">f32</span>));</span>
<span class="line" id="L212">    <span class="tok-kw">try</span> expect(math.isNan(r.significand));</span>
<span class="line" id="L213">}</span>
<span class="line" id="L214"></span>
<span class="line" id="L215"><span class="tok-kw">test</span> <span class="tok-str">&quot;64 special&quot;</span> {</span>
<span class="line" id="L216">    <span class="tok-kw">var</span> r: Frexp(<span class="tok-type">f64</span>) = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L217"></span>
<span class="line" id="L218">    r = frexp64(<span class="tok-number">0.0</span>);</span>
<span class="line" id="L219">    <span class="tok-kw">try</span> expect(r.significand == <span class="tok-number">0.0</span> <span class="tok-kw">and</span> r.exponent == <span class="tok-number">0</span>);</span>
<span class="line" id="L220"></span>
<span class="line" id="L221">    r = frexp64(-<span class="tok-number">0.0</span>);</span>
<span class="line" id="L222">    <span class="tok-kw">try</span> expect(r.significand == -<span class="tok-number">0.0</span> <span class="tok-kw">and</span> r.exponent == <span class="tok-number">0</span>);</span>
<span class="line" id="L223"></span>
<span class="line" id="L224">    r = frexp64(math.inf(<span class="tok-type">f64</span>));</span>
<span class="line" id="L225">    <span class="tok-kw">try</span> expect(math.isPositiveInf(r.significand) <span class="tok-kw">and</span> r.exponent == <span class="tok-number">0</span>);</span>
<span class="line" id="L226"></span>
<span class="line" id="L227">    r = frexp64(-math.inf(<span class="tok-type">f64</span>));</span>
<span class="line" id="L228">    <span class="tok-kw">try</span> expect(math.isNegativeInf(r.significand) <span class="tok-kw">and</span> r.exponent == <span class="tok-number">0</span>);</span>
<span class="line" id="L229"></span>
<span class="line" id="L230">    r = frexp64(math.nan(<span class="tok-type">f64</span>));</span>
<span class="line" id="L231">    <span class="tok-kw">try</span> expect(math.isNan(r.significand));</span>
<span class="line" id="L232">}</span>
<span class="line" id="L233"></span>
<span class="line" id="L234"><span class="tok-kw">test</span> <span class="tok-str">&quot;128 special&quot;</span> {</span>
<span class="line" id="L235">    <span class="tok-kw">var</span> r: Frexp(<span class="tok-type">f128</span>) = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L236"></span>
<span class="line" id="L237">    r = frexp128(<span class="tok-number">0.0</span>);</span>
<span class="line" id="L238">    <span class="tok-kw">try</span> expect(r.significand == <span class="tok-number">0.0</span> <span class="tok-kw">and</span> r.exponent == <span class="tok-number">0</span>);</span>
<span class="line" id="L239"></span>
<span class="line" id="L240">    r = frexp128(-<span class="tok-number">0.0</span>);</span>
<span class="line" id="L241">    <span class="tok-kw">try</span> expect(r.significand == -<span class="tok-number">0.0</span> <span class="tok-kw">and</span> r.exponent == <span class="tok-number">0</span>);</span>
<span class="line" id="L242"></span>
<span class="line" id="L243">    r = frexp128(math.inf(<span class="tok-type">f128</span>));</span>
<span class="line" id="L244">    <span class="tok-kw">try</span> expect(math.isPositiveInf(r.significand) <span class="tok-kw">and</span> r.exponent == <span class="tok-number">0</span>);</span>
<span class="line" id="L245"></span>
<span class="line" id="L246">    r = frexp128(-math.inf(<span class="tok-type">f128</span>));</span>
<span class="line" id="L247">    <span class="tok-kw">try</span> expect(math.isNegativeInf(r.significand) <span class="tok-kw">and</span> r.exponent == <span class="tok-number">0</span>);</span>
<span class="line" id="L248"></span>
<span class="line" id="L249">    r = frexp128(math.nan(<span class="tok-type">f128</span>));</span>
<span class="line" id="L250">    <span class="tok-kw">try</span> expect(math.isNan(r.significand));</span>
<span class="line" id="L251">}</span>
<span class="line" id="L252"></span>
</code></pre></body>
</html>