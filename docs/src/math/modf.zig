<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">    <title>math/modf.zig - source view</title>
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
<span class="line" id="L4"><span class="tok-comment">// https://git.musl-libc.org/cgit/musl/tree/src/math/modff.c</span>
</span>
<span class="line" id="L5"><span class="tok-comment">// https://git.musl-libc.org/cgit/musl/tree/src/math/modf.c</span>
</span>
<span class="line" id="L6"></span>
<span class="line" id="L7"><span class="tok-kw">const</span> std = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;../std.zig&quot;</span>);</span>
<span class="line" id="L8"><span class="tok-kw">const</span> math = std.math;</span>
<span class="line" id="L9"><span class="tok-kw">const</span> expect = std.testing.expect;</span>
<span class="line" id="L10"><span class="tok-kw">const</span> expectEqual = std.testing.expectEqual;</span>
<span class="line" id="L11"><span class="tok-kw">const</span> maxInt = std.math.maxInt;</span>
<span class="line" id="L12"></span>
<span class="line" id="L13"><span class="tok-kw">fn</span> <span class="tok-fn">modf_result</span>(<span class="tok-kw">comptime</span> T: <span class="tok-type">type</span>) <span class="tok-type">type</span> {</span>
<span class="line" id="L14">    <span class="tok-kw">return</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L15">        fpart: T,</span>
<span class="line" id="L16">        ipart: T,</span>
<span class="line" id="L17">    };</span>
<span class="line" id="L18">}</span>
<span class="line" id="L19"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> modf32_result = modf_result(<span class="tok-type">f32</span>);</span>
<span class="line" id="L20"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> modf64_result = modf_result(<span class="tok-type">f64</span>);</span>
<span class="line" id="L21"></span>
<span class="line" id="L22"><span class="tok-comment">/// Returns the integer and fractional floating-point numbers that sum to x. The sign of each</span></span>
<span class="line" id="L23"><span class="tok-comment">/// result is the same as the sign of x.</span></span>
<span class="line" id="L24"><span class="tok-comment">///</span></span>
<span class="line" id="L25"><span class="tok-comment">/// Special Cases:</span></span>
<span class="line" id="L26"><span class="tok-comment">///  - modf(+-inf) = +-inf, nan</span></span>
<span class="line" id="L27"><span class="tok-comment">///  - modf(nan)   = nan, nan</span></span>
<span class="line" id="L28"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">modf</span>(x: <span class="tok-kw">anytype</span>) modf_result(<span class="tok-builtin">@TypeOf</span>(x)) {</span>
<span class="line" id="L29">    <span class="tok-kw">const</span> T = <span class="tok-builtin">@TypeOf</span>(x);</span>
<span class="line" id="L30">    <span class="tok-kw">return</span> <span class="tok-kw">switch</span> (T) {</span>
<span class="line" id="L31">        <span class="tok-type">f32</span> =&gt; modf32(x),</span>
<span class="line" id="L32">        <span class="tok-type">f64</span> =&gt; modf64(x),</span>
<span class="line" id="L33">        <span class="tok-kw">else</span> =&gt; <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;modf not implemented for &quot;</span> ++ <span class="tok-builtin">@typeName</span>(T)),</span>
<span class="line" id="L34">    };</span>
<span class="line" id="L35">}</span>
<span class="line" id="L36"></span>
<span class="line" id="L37"><span class="tok-kw">fn</span> <span class="tok-fn">modf32</span>(x: <span class="tok-type">f32</span>) modf32_result {</span>
<span class="line" id="L38">    <span class="tok-kw">var</span> result: modf32_result = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L39"></span>
<span class="line" id="L40">    <span class="tok-kw">const</span> u = <span class="tok-builtin">@bitCast</span>(<span class="tok-type">u32</span>, x);</span>
<span class="line" id="L41">    <span class="tok-kw">const</span> e = <span class="tok-builtin">@intCast</span>(<span class="tok-type">i32</span>, (u &gt;&gt; <span class="tok-number">23</span>) &amp; <span class="tok-number">0xFF</span>) - <span class="tok-number">0x7F</span>;</span>
<span class="line" id="L42">    <span class="tok-kw">const</span> us = u &amp; <span class="tok-number">0x80000000</span>;</span>
<span class="line" id="L43"></span>
<span class="line" id="L44">    <span class="tok-comment">// TODO: Shouldn't need this.</span>
</span>
<span class="line" id="L45">    <span class="tok-kw">if</span> (math.isInf(x)) {</span>
<span class="line" id="L46">        result.ipart = x;</span>
<span class="line" id="L47">        result.fpart = math.nan(<span class="tok-type">f32</span>);</span>
<span class="line" id="L48">        <span class="tok-kw">return</span> result;</span>
<span class="line" id="L49">    }</span>
<span class="line" id="L50"></span>
<span class="line" id="L51">    <span class="tok-comment">// no fractional part</span>
</span>
<span class="line" id="L52">    <span class="tok-kw">if</span> (e &gt;= <span class="tok-number">23</span>) {</span>
<span class="line" id="L53">        result.ipart = x;</span>
<span class="line" id="L54">        <span class="tok-kw">if</span> (e == <span class="tok-number">0x80</span> <span class="tok-kw">and</span> u &lt;&lt; <span class="tok-number">9</span> != <span class="tok-number">0</span>) { <span class="tok-comment">// nan</span>
</span>
<span class="line" id="L55">            result.fpart = x;</span>
<span class="line" id="L56">        } <span class="tok-kw">else</span> {</span>
<span class="line" id="L57">            result.fpart = <span class="tok-builtin">@bitCast</span>(<span class="tok-type">f32</span>, us);</span>
<span class="line" id="L58">        }</span>
<span class="line" id="L59">        <span class="tok-kw">return</span> result;</span>
<span class="line" id="L60">    }</span>
<span class="line" id="L61"></span>
<span class="line" id="L62">    <span class="tok-comment">// no integral part</span>
</span>
<span class="line" id="L63">    <span class="tok-kw">if</span> (e &lt; <span class="tok-number">0</span>) {</span>
<span class="line" id="L64">        result.ipart = <span class="tok-builtin">@bitCast</span>(<span class="tok-type">f32</span>, us);</span>
<span class="line" id="L65">        result.fpart = x;</span>
<span class="line" id="L66">        <span class="tok-kw">return</span> result;</span>
<span class="line" id="L67">    }</span>
<span class="line" id="L68"></span>
<span class="line" id="L69">    <span class="tok-kw">const</span> mask = <span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">0x007FFFFF</span>) &gt;&gt; <span class="tok-builtin">@intCast</span>(<span class="tok-type">u5</span>, e);</span>
<span class="line" id="L70">    <span class="tok-kw">if</span> (u &amp; mask == <span class="tok-number">0</span>) {</span>
<span class="line" id="L71">        result.ipart = x;</span>
<span class="line" id="L72">        result.fpart = <span class="tok-builtin">@bitCast</span>(<span class="tok-type">f32</span>, us);</span>
<span class="line" id="L73">        <span class="tok-kw">return</span> result;</span>
<span class="line" id="L74">    }</span>
<span class="line" id="L75"></span>
<span class="line" id="L76">    <span class="tok-kw">const</span> uf = <span class="tok-builtin">@bitCast</span>(<span class="tok-type">f32</span>, u &amp; ~mask);</span>
<span class="line" id="L77">    result.ipart = uf;</span>
<span class="line" id="L78">    result.fpart = x - uf;</span>
<span class="line" id="L79">    <span class="tok-kw">return</span> result;</span>
<span class="line" id="L80">}</span>
<span class="line" id="L81"></span>
<span class="line" id="L82"><span class="tok-kw">fn</span> <span class="tok-fn">modf64</span>(x: <span class="tok-type">f64</span>) modf64_result {</span>
<span class="line" id="L83">    <span class="tok-kw">var</span> result: modf64_result = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L84"></span>
<span class="line" id="L85">    <span class="tok-kw">const</span> u = <span class="tok-builtin">@bitCast</span>(<span class="tok-type">u64</span>, x);</span>
<span class="line" id="L86">    <span class="tok-kw">const</span> e = <span class="tok-builtin">@intCast</span>(<span class="tok-type">i32</span>, (u &gt;&gt; <span class="tok-number">52</span>) &amp; <span class="tok-number">0x7FF</span>) - <span class="tok-number">0x3FF</span>;</span>
<span class="line" id="L87">    <span class="tok-kw">const</span> us = u &amp; (<span class="tok-number">1</span> &lt;&lt; <span class="tok-number">63</span>);</span>
<span class="line" id="L88"></span>
<span class="line" id="L89">    <span class="tok-kw">if</span> (math.isInf(x)) {</span>
<span class="line" id="L90">        result.ipart = x;</span>
<span class="line" id="L91">        result.fpart = math.nan(<span class="tok-type">f64</span>);</span>
<span class="line" id="L92">        <span class="tok-kw">return</span> result;</span>
<span class="line" id="L93">    }</span>
<span class="line" id="L94"></span>
<span class="line" id="L95">    <span class="tok-comment">// no fractional part</span>
</span>
<span class="line" id="L96">    <span class="tok-kw">if</span> (e &gt;= <span class="tok-number">52</span>) {</span>
<span class="line" id="L97">        result.ipart = x;</span>
<span class="line" id="L98">        <span class="tok-kw">if</span> (e == <span class="tok-number">0x400</span> <span class="tok-kw">and</span> u &lt;&lt; <span class="tok-number">12</span> != <span class="tok-number">0</span>) { <span class="tok-comment">// nan</span>
</span>
<span class="line" id="L99">            result.fpart = x;</span>
<span class="line" id="L100">        } <span class="tok-kw">else</span> {</span>
<span class="line" id="L101">            result.fpart = <span class="tok-builtin">@bitCast</span>(<span class="tok-type">f64</span>, us);</span>
<span class="line" id="L102">        }</span>
<span class="line" id="L103">        <span class="tok-kw">return</span> result;</span>
<span class="line" id="L104">    }</span>
<span class="line" id="L105"></span>
<span class="line" id="L106">    <span class="tok-comment">// no integral part</span>
</span>
<span class="line" id="L107">    <span class="tok-kw">if</span> (e &lt; <span class="tok-number">0</span>) {</span>
<span class="line" id="L108">        result.ipart = <span class="tok-builtin">@bitCast</span>(<span class="tok-type">f64</span>, us);</span>
<span class="line" id="L109">        result.fpart = x;</span>
<span class="line" id="L110">        <span class="tok-kw">return</span> result;</span>
<span class="line" id="L111">    }</span>
<span class="line" id="L112"></span>
<span class="line" id="L113">    <span class="tok-kw">const</span> mask = <span class="tok-builtin">@as</span>(<span class="tok-type">u64</span>, maxInt(<span class="tok-type">u64</span>) &gt;&gt; <span class="tok-number">12</span>) &gt;&gt; <span class="tok-builtin">@intCast</span>(<span class="tok-type">u6</span>, e);</span>
<span class="line" id="L114">    <span class="tok-kw">if</span> (u &amp; mask == <span class="tok-number">0</span>) {</span>
<span class="line" id="L115">        result.ipart = x;</span>
<span class="line" id="L116">        result.fpart = <span class="tok-builtin">@bitCast</span>(<span class="tok-type">f64</span>, us);</span>
<span class="line" id="L117">        <span class="tok-kw">return</span> result;</span>
<span class="line" id="L118">    }</span>
<span class="line" id="L119"></span>
<span class="line" id="L120">    <span class="tok-kw">const</span> uf = <span class="tok-builtin">@bitCast</span>(<span class="tok-type">f64</span>, u &amp; ~mask);</span>
<span class="line" id="L121">    result.ipart = uf;</span>
<span class="line" id="L122">    result.fpart = x - uf;</span>
<span class="line" id="L123">    <span class="tok-kw">return</span> result;</span>
<span class="line" id="L124">}</span>
<span class="line" id="L125"></span>
<span class="line" id="L126"><span class="tok-kw">test</span> <span class="tok-str">&quot;math.modf&quot;</span> {</span>
<span class="line" id="L127">    <span class="tok-kw">const</span> a = modf(<span class="tok-builtin">@as</span>(<span class="tok-type">f32</span>, <span class="tok-number">1.0</span>));</span>
<span class="line" id="L128">    <span class="tok-kw">const</span> b = modf32(<span class="tok-number">1.0</span>);</span>
<span class="line" id="L129">    <span class="tok-comment">// NOTE: No struct comparison on generic return type function? non-named, makes sense, but still.</span>
</span>
<span class="line" id="L130">    <span class="tok-kw">try</span> expectEqual(a, b);</span>
<span class="line" id="L131">}</span>
<span class="line" id="L132"></span>
<span class="line" id="L133"><span class="tok-kw">test</span> <span class="tok-str">&quot;math.modf32&quot;</span> {</span>
<span class="line" id="L134">    <span class="tok-kw">const</span> epsilon = <span class="tok-number">0.000001</span>;</span>
<span class="line" id="L135">    <span class="tok-kw">var</span> r: modf32_result = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L136"></span>
<span class="line" id="L137">    r = modf32(<span class="tok-number">1.0</span>);</span>
<span class="line" id="L138">    <span class="tok-kw">try</span> expect(math.approxEqAbs(<span class="tok-type">f32</span>, r.ipart, <span class="tok-number">1.0</span>, epsilon));</span>
<span class="line" id="L139">    <span class="tok-kw">try</span> expect(math.approxEqAbs(<span class="tok-type">f32</span>, r.fpart, <span class="tok-number">0.0</span>, epsilon));</span>
<span class="line" id="L140"></span>
<span class="line" id="L141">    r = modf32(<span class="tok-number">2.545</span>);</span>
<span class="line" id="L142">    <span class="tok-kw">try</span> expect(math.approxEqAbs(<span class="tok-type">f32</span>, r.ipart, <span class="tok-number">2.0</span>, epsilon));</span>
<span class="line" id="L143">    <span class="tok-kw">try</span> expect(math.approxEqAbs(<span class="tok-type">f32</span>, r.fpart, <span class="tok-number">0.545</span>, epsilon));</span>
<span class="line" id="L144"></span>
<span class="line" id="L145">    r = modf32(<span class="tok-number">3.978123</span>);</span>
<span class="line" id="L146">    <span class="tok-kw">try</span> expect(math.approxEqAbs(<span class="tok-type">f32</span>, r.ipart, <span class="tok-number">3.0</span>, epsilon));</span>
<span class="line" id="L147">    <span class="tok-kw">try</span> expect(math.approxEqAbs(<span class="tok-type">f32</span>, r.fpart, <span class="tok-number">0.978123</span>, epsilon));</span>
<span class="line" id="L148"></span>
<span class="line" id="L149">    r = modf32(<span class="tok-number">43874.3</span>);</span>
<span class="line" id="L150">    <span class="tok-kw">try</span> expect(math.approxEqAbs(<span class="tok-type">f32</span>, r.ipart, <span class="tok-number">43874</span>, epsilon));</span>
<span class="line" id="L151">    <span class="tok-kw">try</span> expect(math.approxEqAbs(<span class="tok-type">f32</span>, r.fpart, <span class="tok-number">0.300781</span>, epsilon));</span>
<span class="line" id="L152"></span>
<span class="line" id="L153">    r = modf32(<span class="tok-number">1234.340780</span>);</span>
<span class="line" id="L154">    <span class="tok-kw">try</span> expect(math.approxEqAbs(<span class="tok-type">f32</span>, r.ipart, <span class="tok-number">1234</span>, epsilon));</span>
<span class="line" id="L155">    <span class="tok-kw">try</span> expect(math.approxEqAbs(<span class="tok-type">f32</span>, r.fpart, <span class="tok-number">0.340820</span>, epsilon));</span>
<span class="line" id="L156">}</span>
<span class="line" id="L157"></span>
<span class="line" id="L158"><span class="tok-kw">test</span> <span class="tok-str">&quot;math.modf64&quot;</span> {</span>
<span class="line" id="L159">    <span class="tok-kw">const</span> epsilon = <span class="tok-number">0.000001</span>;</span>
<span class="line" id="L160">    <span class="tok-kw">var</span> r: modf64_result = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L161"></span>
<span class="line" id="L162">    r = modf64(<span class="tok-number">1.0</span>);</span>
<span class="line" id="L163">    <span class="tok-kw">try</span> expect(math.approxEqAbs(<span class="tok-type">f64</span>, r.ipart, <span class="tok-number">1.0</span>, epsilon));</span>
<span class="line" id="L164">    <span class="tok-kw">try</span> expect(math.approxEqAbs(<span class="tok-type">f64</span>, r.fpart, <span class="tok-number">0.0</span>, epsilon));</span>
<span class="line" id="L165"></span>
<span class="line" id="L166">    r = modf64(<span class="tok-number">2.545</span>);</span>
<span class="line" id="L167">    <span class="tok-kw">try</span> expect(math.approxEqAbs(<span class="tok-type">f64</span>, r.ipart, <span class="tok-number">2.0</span>, epsilon));</span>
<span class="line" id="L168">    <span class="tok-kw">try</span> expect(math.approxEqAbs(<span class="tok-type">f64</span>, r.fpart, <span class="tok-number">0.545</span>, epsilon));</span>
<span class="line" id="L169"></span>
<span class="line" id="L170">    r = modf64(<span class="tok-number">3.978123</span>);</span>
<span class="line" id="L171">    <span class="tok-kw">try</span> expect(math.approxEqAbs(<span class="tok-type">f64</span>, r.ipart, <span class="tok-number">3.0</span>, epsilon));</span>
<span class="line" id="L172">    <span class="tok-kw">try</span> expect(math.approxEqAbs(<span class="tok-type">f64</span>, r.fpart, <span class="tok-number">0.978123</span>, epsilon));</span>
<span class="line" id="L173"></span>
<span class="line" id="L174">    r = modf64(<span class="tok-number">43874.3</span>);</span>
<span class="line" id="L175">    <span class="tok-kw">try</span> expect(math.approxEqAbs(<span class="tok-type">f64</span>, r.ipart, <span class="tok-number">43874</span>, epsilon));</span>
<span class="line" id="L176">    <span class="tok-kw">try</span> expect(math.approxEqAbs(<span class="tok-type">f64</span>, r.fpart, <span class="tok-number">0.3</span>, epsilon));</span>
<span class="line" id="L177"></span>
<span class="line" id="L178">    r = modf64(<span class="tok-number">1234.340780</span>);</span>
<span class="line" id="L179">    <span class="tok-kw">try</span> expect(math.approxEqAbs(<span class="tok-type">f64</span>, r.ipart, <span class="tok-number">1234</span>, epsilon));</span>
<span class="line" id="L180">    <span class="tok-kw">try</span> expect(math.approxEqAbs(<span class="tok-type">f64</span>, r.fpart, <span class="tok-number">0.340780</span>, epsilon));</span>
<span class="line" id="L181">}</span>
<span class="line" id="L182"></span>
<span class="line" id="L183"><span class="tok-kw">test</span> <span class="tok-str">&quot;math.modf32.special&quot;</span> {</span>
<span class="line" id="L184">    <span class="tok-kw">var</span> r: modf32_result = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L185"></span>
<span class="line" id="L186">    r = modf32(math.inf(<span class="tok-type">f32</span>));</span>
<span class="line" id="L187">    <span class="tok-kw">try</span> expect(math.isPositiveInf(r.ipart) <span class="tok-kw">and</span> math.isNan(r.fpart));</span>
<span class="line" id="L188"></span>
<span class="line" id="L189">    r = modf32(-math.inf(<span class="tok-type">f32</span>));</span>
<span class="line" id="L190">    <span class="tok-kw">try</span> expect(math.isNegativeInf(r.ipart) <span class="tok-kw">and</span> math.isNan(r.fpart));</span>
<span class="line" id="L191"></span>
<span class="line" id="L192">    r = modf32(math.nan(<span class="tok-type">f32</span>));</span>
<span class="line" id="L193">    <span class="tok-kw">try</span> expect(math.isNan(r.ipart) <span class="tok-kw">and</span> math.isNan(r.fpart));</span>
<span class="line" id="L194">}</span>
<span class="line" id="L195"></span>
<span class="line" id="L196"><span class="tok-kw">test</span> <span class="tok-str">&quot;math.modf64.special&quot;</span> {</span>
<span class="line" id="L197">    <span class="tok-kw">var</span> r: modf64_result = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L198"></span>
<span class="line" id="L199">    r = modf64(math.inf(<span class="tok-type">f64</span>));</span>
<span class="line" id="L200">    <span class="tok-kw">try</span> expect(math.isPositiveInf(r.ipart) <span class="tok-kw">and</span> math.isNan(r.fpart));</span>
<span class="line" id="L201"></span>
<span class="line" id="L202">    r = modf64(-math.inf(<span class="tok-type">f64</span>));</span>
<span class="line" id="L203">    <span class="tok-kw">try</span> expect(math.isNegativeInf(r.ipart) <span class="tok-kw">and</span> math.isNan(r.fpart));</span>
<span class="line" id="L204"></span>
<span class="line" id="L205">    r = modf64(math.nan(<span class="tok-type">f64</span>));</span>
<span class="line" id="L206">    <span class="tok-kw">try</span> expect(math.isNan(r.ipart) <span class="tok-kw">and</span> math.isNan(r.fpart));</span>
<span class="line" id="L207">}</span>
<span class="line" id="L208"></span>
</code></pre></body>
</html>