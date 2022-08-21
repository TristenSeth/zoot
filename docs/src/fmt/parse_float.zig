<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">    <title>fmt/parse_float.zig - source view</title>
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
<pre><code><span class="line" id="L1"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> parseFloat = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;parse_float/parse_float.zig&quot;</span>).parseFloat;</span>
<span class="line" id="L2"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> ParseFloatError = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;parse_float/parse_float.zig&quot;</span>).ParseFloatError;</span>
<span class="line" id="L3"></span>
<span class="line" id="L4"><span class="tok-kw">const</span> builtin = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;builtin&quot;</span>);</span>
<span class="line" id="L5"><span class="tok-kw">const</span> std = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;std&quot;</span>);</span>
<span class="line" id="L6"><span class="tok-kw">const</span> math = std.math;</span>
<span class="line" id="L7"><span class="tok-kw">const</span> testing = std.testing;</span>
<span class="line" id="L8"><span class="tok-kw">const</span> expect = testing.expect;</span>
<span class="line" id="L9"><span class="tok-kw">const</span> expectEqual = testing.expectEqual;</span>
<span class="line" id="L10"><span class="tok-kw">const</span> expectError = testing.expectError;</span>
<span class="line" id="L11"><span class="tok-kw">const</span> approxEqAbs = std.math.approxEqAbs;</span>
<span class="line" id="L12"><span class="tok-kw">const</span> epsilon = <span class="tok-number">1e-7</span>;</span>
<span class="line" id="L13"></span>
<span class="line" id="L14"><span class="tok-comment">// See https://github.com/tiehuis/parse-number-fxx-test-data for a wider-selection of test-data.</span>
</span>
<span class="line" id="L15"></span>
<span class="line" id="L16"><span class="tok-kw">test</span> <span class="tok-str">&quot;fmt.parseFloat&quot;</span> {</span>
<span class="line" id="L17">    <span class="tok-kw">inline</span> <span class="tok-kw">for</span> ([_]<span class="tok-type">type</span>{ <span class="tok-type">f16</span>, <span class="tok-type">f32</span>, <span class="tok-type">f64</span>, <span class="tok-type">f128</span> }) |T| {</span>
<span class="line" id="L18">        <span class="tok-kw">try</span> testing.expectError(<span class="tok-kw">error</span>.InvalidCharacter, parseFloat(T, <span class="tok-str">&quot;&quot;</span>));</span>
<span class="line" id="L19">        <span class="tok-kw">try</span> testing.expectError(<span class="tok-kw">error</span>.InvalidCharacter, parseFloat(T, <span class="tok-str">&quot;   1&quot;</span>));</span>
<span class="line" id="L20">        <span class="tok-kw">try</span> testing.expectError(<span class="tok-kw">error</span>.InvalidCharacter, parseFloat(T, <span class="tok-str">&quot;1abc&quot;</span>));</span>
<span class="line" id="L21">        <span class="tok-kw">try</span> testing.expectError(<span class="tok-kw">error</span>.InvalidCharacter, parseFloat(T, <span class="tok-str">&quot;+&quot;</span>));</span>
<span class="line" id="L22">        <span class="tok-kw">try</span> testing.expectError(<span class="tok-kw">error</span>.InvalidCharacter, parseFloat(T, <span class="tok-str">&quot;-&quot;</span>));</span>
<span class="line" id="L23"></span>
<span class="line" id="L24">        <span class="tok-kw">try</span> expectEqual(<span class="tok-kw">try</span> parseFloat(T, <span class="tok-str">&quot;0&quot;</span>), <span class="tok-number">0.0</span>);</span>
<span class="line" id="L25">        <span class="tok-kw">try</span> expectEqual(<span class="tok-kw">try</span> parseFloat(T, <span class="tok-str">&quot;0&quot;</span>), <span class="tok-number">0.0</span>);</span>
<span class="line" id="L26">        <span class="tok-kw">try</span> expectEqual(<span class="tok-kw">try</span> parseFloat(T, <span class="tok-str">&quot;+0&quot;</span>), <span class="tok-number">0.0</span>);</span>
<span class="line" id="L27">        <span class="tok-kw">try</span> expectEqual(<span class="tok-kw">try</span> parseFloat(T, <span class="tok-str">&quot;-0&quot;</span>), <span class="tok-number">0.0</span>);</span>
<span class="line" id="L28"></span>
<span class="line" id="L29">        <span class="tok-kw">try</span> expectEqual(<span class="tok-kw">try</span> parseFloat(T, <span class="tok-str">&quot;0e0&quot;</span>), <span class="tok-number">0</span>);</span>
<span class="line" id="L30">        <span class="tok-kw">try</span> expectEqual(<span class="tok-kw">try</span> parseFloat(T, <span class="tok-str">&quot;2e3&quot;</span>), <span class="tok-number">2000.0</span>);</span>
<span class="line" id="L31">        <span class="tok-kw">try</span> expectEqual(<span class="tok-kw">try</span> parseFloat(T, <span class="tok-str">&quot;1e0&quot;</span>), <span class="tok-number">1.0</span>);</span>
<span class="line" id="L32">        <span class="tok-kw">try</span> expectEqual(<span class="tok-kw">try</span> parseFloat(T, <span class="tok-str">&quot;-2e3&quot;</span>), -<span class="tok-number">2000.0</span>);</span>
<span class="line" id="L33">        <span class="tok-kw">try</span> expectEqual(<span class="tok-kw">try</span> parseFloat(T, <span class="tok-str">&quot;-1e0&quot;</span>), -<span class="tok-number">1.0</span>);</span>
<span class="line" id="L34">        <span class="tok-kw">try</span> expectEqual(<span class="tok-kw">try</span> parseFloat(T, <span class="tok-str">&quot;1.234e3&quot;</span>), <span class="tok-number">1234</span>);</span>
<span class="line" id="L35"></span>
<span class="line" id="L36">        <span class="tok-kw">try</span> expect(approxEqAbs(T, <span class="tok-kw">try</span> parseFloat(T, <span class="tok-str">&quot;3.141&quot;</span>), <span class="tok-number">3.141</span>, epsilon));</span>
<span class="line" id="L37">        <span class="tok-kw">try</span> expect(approxEqAbs(T, <span class="tok-kw">try</span> parseFloat(T, <span class="tok-str">&quot;-3.141&quot;</span>), -<span class="tok-number">3.141</span>, epsilon));</span>
<span class="line" id="L38"></span>
<span class="line" id="L39">        <span class="tok-kw">try</span> expectEqual(<span class="tok-kw">try</span> parseFloat(T, <span class="tok-str">&quot;1e-5000&quot;</span>), <span class="tok-number">0</span>);</span>
<span class="line" id="L40">        <span class="tok-kw">try</span> expectEqual(<span class="tok-kw">try</span> parseFloat(T, <span class="tok-str">&quot;1e+5000&quot;</span>), std.math.inf(T));</span>
<span class="line" id="L41"></span>
<span class="line" id="L42">        <span class="tok-kw">try</span> expectEqual(<span class="tok-kw">try</span> parseFloat(T, <span class="tok-str">&quot;0.4e0066999999999999999999999999999999999999999999999999999&quot;</span>), std.math.inf(T));</span>
<span class="line" id="L43">        <span class="tok-kw">try</span> expect(approxEqAbs(T, <span class="tok-kw">try</span> parseFloat(T, <span class="tok-str">&quot;0_1_2_3_4_5_6.7_8_9_0_0_0e0_0_1_0&quot;</span>), <span class="tok-builtin">@as</span>(T, <span class="tok-number">123456.789000e10</span>), epsilon));</span>
<span class="line" id="L44"></span>
<span class="line" id="L45">        <span class="tok-comment">// underscore rule is simple and reduces to &quot;can only occur between two digits&quot; and multiple are not supported.</span>
</span>
<span class="line" id="L46">        <span class="tok-kw">try</span> expectError(<span class="tok-kw">error</span>.InvalidCharacter, parseFloat(T, <span class="tok-str">&quot;0123456.789000e_0010&quot;</span>)); <span class="tok-comment">// cannot occur immediately after exponent</span>
</span>
<span class="line" id="L47">        <span class="tok-kw">try</span> expectError(<span class="tok-kw">error</span>.InvalidCharacter, parseFloat(T, <span class="tok-str">&quot;_0123456.789000e0010&quot;</span>)); <span class="tok-comment">// cannot occur before any digits</span>
</span>
<span class="line" id="L48">        <span class="tok-kw">try</span> expectError(<span class="tok-kw">error</span>.InvalidCharacter, parseFloat(T, <span class="tok-str">&quot;0__123456.789000e_0010&quot;</span>)); <span class="tok-comment">// cannot occur twice in a row</span>
</span>
<span class="line" id="L49">        <span class="tok-kw">try</span> expectError(<span class="tok-kw">error</span>.InvalidCharacter, parseFloat(T, <span class="tok-str">&quot;0123456_.789000e0010&quot;</span>)); <span class="tok-comment">// cannot occur before decimal point</span>
</span>
<span class="line" id="L50">        <span class="tok-kw">try</span> expectError(<span class="tok-kw">error</span>.InvalidCharacter, parseFloat(T, <span class="tok-str">&quot;0123456.789000e0010_&quot;</span>)); <span class="tok-comment">// cannot occur at end of number</span>
</span>
<span class="line" id="L51"></span>
<span class="line" id="L52">        <span class="tok-kw">try</span> expect(approxEqAbs(T, <span class="tok-kw">try</span> parseFloat(T, <span class="tok-str">&quot;1e-2&quot;</span>), <span class="tok-number">0.01</span>, epsilon));</span>
<span class="line" id="L53">        <span class="tok-kw">try</span> expect(approxEqAbs(T, <span class="tok-kw">try</span> parseFloat(T, <span class="tok-str">&quot;1234e-2&quot;</span>), <span class="tok-number">12.34</span>, epsilon));</span>
<span class="line" id="L54"></span>
<span class="line" id="L55">        <span class="tok-kw">try</span> expect(approxEqAbs(T, <span class="tok-kw">try</span> parseFloat(T, <span class="tok-str">&quot;1.&quot;</span>), <span class="tok-number">1</span>, epsilon));</span>
<span class="line" id="L56">        <span class="tok-kw">try</span> expect(approxEqAbs(T, <span class="tok-kw">try</span> parseFloat(T, <span class="tok-str">&quot;0.&quot;</span>), <span class="tok-number">0</span>, epsilon));</span>
<span class="line" id="L57">        <span class="tok-kw">try</span> expect(approxEqAbs(T, <span class="tok-kw">try</span> parseFloat(T, <span class="tok-str">&quot;.1&quot;</span>), <span class="tok-number">0.1</span>, epsilon));</span>
<span class="line" id="L58">        <span class="tok-kw">try</span> expect(approxEqAbs(T, <span class="tok-kw">try</span> parseFloat(T, <span class="tok-str">&quot;.0&quot;</span>), <span class="tok-number">0</span>, epsilon));</span>
<span class="line" id="L59">        <span class="tok-kw">try</span> expect(approxEqAbs(T, <span class="tok-kw">try</span> parseFloat(T, <span class="tok-str">&quot;.1e-1&quot;</span>), <span class="tok-number">0.01</span>, epsilon));</span>
<span class="line" id="L60"></span>
<span class="line" id="L61">        <span class="tok-kw">try</span> expectError(<span class="tok-kw">error</span>.InvalidCharacter, parseFloat(T, <span class="tok-str">&quot;.&quot;</span>)); <span class="tok-comment">// At least one digit is required.</span>
</span>
<span class="line" id="L62">        <span class="tok-kw">try</span> expectError(<span class="tok-kw">error</span>.InvalidCharacter, parseFloat(T, <span class="tok-str">&quot;.e1&quot;</span>)); <span class="tok-comment">// At least one digit is required.</span>
</span>
<span class="line" id="L63">        <span class="tok-kw">try</span> expectError(<span class="tok-kw">error</span>.InvalidCharacter, parseFloat(T, <span class="tok-str">&quot;0.e&quot;</span>)); <span class="tok-comment">// At least one digit is required.</span>
</span>
<span class="line" id="L64"></span>
<span class="line" id="L65">        <span class="tok-kw">try</span> expect(approxEqAbs(T, <span class="tok-kw">try</span> parseFloat(T, <span class="tok-str">&quot;123142.1&quot;</span>), <span class="tok-number">123142.1</span>, epsilon));</span>
<span class="line" id="L66">        <span class="tok-kw">try</span> expect(approxEqAbs(T, <span class="tok-kw">try</span> parseFloat(T, <span class="tok-str">&quot;-123142.1124&quot;</span>), <span class="tok-builtin">@as</span>(T, -<span class="tok-number">123142.1124</span>), epsilon));</span>
<span class="line" id="L67">        <span class="tok-kw">try</span> expect(approxEqAbs(T, <span class="tok-kw">try</span> parseFloat(T, <span class="tok-str">&quot;0.7062146892655368&quot;</span>), <span class="tok-builtin">@as</span>(T, <span class="tok-number">0.7062146892655368</span>), epsilon));</span>
<span class="line" id="L68">        <span class="tok-kw">try</span> expect(approxEqAbs(T, <span class="tok-kw">try</span> parseFloat(T, <span class="tok-str">&quot;2.71828182845904523536&quot;</span>), <span class="tok-builtin">@as</span>(T, <span class="tok-number">2.718281828459045</span>), epsilon));</span>
<span class="line" id="L69">    }</span>
<span class="line" id="L70">}</span>
<span class="line" id="L71"></span>
<span class="line" id="L72"><span class="tok-kw">test</span> <span class="tok-str">&quot;fmt.parseFloat nan and inf&quot;</span> {</span>
<span class="line" id="L73">    <span class="tok-kw">if</span> ((builtin.zig_backend == .stage1 <span class="tok-kw">or</span> builtin.zig_backend == .stage2_llvm) <span class="tok-kw">and</span></span>
<span class="line" id="L74">        builtin.cpu.arch == .aarch64)</span>
<span class="line" id="L75">    {</span>
<span class="line" id="L76">        <span class="tok-comment">// https://github.com/ziglang/zig/issues/12027</span>
</span>
<span class="line" id="L77">        <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SkipZigTest;</span>
<span class="line" id="L78">    }</span>
<span class="line" id="L79"></span>
<span class="line" id="L80">    <span class="tok-kw">inline</span> <span class="tok-kw">for</span> ([_]<span class="tok-type">type</span>{ <span class="tok-type">f16</span>, <span class="tok-type">f32</span>, <span class="tok-type">f64</span>, <span class="tok-type">f128</span> }) |T| {</span>
<span class="line" id="L81">        <span class="tok-kw">const</span> Z = std.meta.Int(.unsigned, <span class="tok-builtin">@typeInfo</span>(T).Float.bits);</span>
<span class="line" id="L82"></span>
<span class="line" id="L83">        <span class="tok-kw">try</span> expectEqual(<span class="tok-builtin">@bitCast</span>(Z, <span class="tok-kw">try</span> parseFloat(T, <span class="tok-str">&quot;nAn&quot;</span>)), <span class="tok-builtin">@bitCast</span>(Z, std.math.nan(T)));</span>
<span class="line" id="L84">        <span class="tok-kw">try</span> expectEqual(<span class="tok-kw">try</span> parseFloat(T, <span class="tok-str">&quot;inF&quot;</span>), std.math.inf(T));</span>
<span class="line" id="L85">        <span class="tok-kw">try</span> expectEqual(<span class="tok-kw">try</span> parseFloat(T, <span class="tok-str">&quot;-INF&quot;</span>), -std.math.inf(T));</span>
<span class="line" id="L86">    }</span>
<span class="line" id="L87">}</span>
<span class="line" id="L88"></span>
<span class="line" id="L89"><span class="tok-kw">test</span> <span class="tok-str">&quot;fmt.parseFloat #11169&quot;</span> {</span>
<span class="line" id="L90">    <span class="tok-kw">try</span> expectEqual(<span class="tok-kw">try</span> parseFloat(<span class="tok-type">f128</span>, <span class="tok-str">&quot;9007199254740993.0&quot;</span>), <span class="tok-number">9007199254740993.0</span>);</span>
<span class="line" id="L91">}</span>
<span class="line" id="L92"></span>
<span class="line" id="L93"><span class="tok-kw">test</span> <span class="tok-str">&quot;fmt.parseFloat hex.special&quot;</span> {</span>
<span class="line" id="L94">    <span class="tok-kw">try</span> testing.expect(math.isNan(<span class="tok-kw">try</span> parseFloat(<span class="tok-type">f32</span>, <span class="tok-str">&quot;nAn&quot;</span>)));</span>
<span class="line" id="L95">    <span class="tok-kw">try</span> testing.expect(math.isPositiveInf(<span class="tok-kw">try</span> parseFloat(<span class="tok-type">f32</span>, <span class="tok-str">&quot;iNf&quot;</span>)));</span>
<span class="line" id="L96">    <span class="tok-kw">try</span> testing.expect(math.isPositiveInf(<span class="tok-kw">try</span> parseFloat(<span class="tok-type">f32</span>, <span class="tok-str">&quot;+Inf&quot;</span>)));</span>
<span class="line" id="L97">    <span class="tok-kw">try</span> testing.expect(math.isNegativeInf(<span class="tok-kw">try</span> parseFloat(<span class="tok-type">f32</span>, <span class="tok-str">&quot;-iNf&quot;</span>)));</span>
<span class="line" id="L98">}</span>
<span class="line" id="L99"><span class="tok-kw">test</span> <span class="tok-str">&quot;fmt.parseFloat hex.zero&quot;</span> {</span>
<span class="line" id="L100">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">f32</span>, <span class="tok-number">0.0</span>), <span class="tok-kw">try</span> parseFloat(<span class="tok-type">f32</span>, <span class="tok-str">&quot;0x0&quot;</span>));</span>
<span class="line" id="L101">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">f32</span>, <span class="tok-number">0.0</span>), <span class="tok-kw">try</span> parseFloat(<span class="tok-type">f32</span>, <span class="tok-str">&quot;-0x0&quot;</span>));</span>
<span class="line" id="L102">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">f32</span>, <span class="tok-number">0.0</span>), <span class="tok-kw">try</span> parseFloat(<span class="tok-type">f32</span>, <span class="tok-str">&quot;0x0p42&quot;</span>));</span>
<span class="line" id="L103">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">f32</span>, <span class="tok-number">0.0</span>), <span class="tok-kw">try</span> parseFloat(<span class="tok-type">f32</span>, <span class="tok-str">&quot;-0x0.00000p42&quot;</span>));</span>
<span class="line" id="L104">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">f32</span>, <span class="tok-number">0.0</span>), <span class="tok-kw">try</span> parseFloat(<span class="tok-type">f32</span>, <span class="tok-str">&quot;0x0.00000p666&quot;</span>));</span>
<span class="line" id="L105">}</span>
<span class="line" id="L106"></span>
<span class="line" id="L107"><span class="tok-kw">test</span> <span class="tok-str">&quot;fmt.parseFloat hex.f16&quot;</span> {</span>
<span class="line" id="L108">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-kw">try</span> parseFloat(<span class="tok-type">f16</span>, <span class="tok-str">&quot;0x1p0&quot;</span>), <span class="tok-number">1.0</span>);</span>
<span class="line" id="L109">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-kw">try</span> parseFloat(<span class="tok-type">f16</span>, <span class="tok-str">&quot;-0x1p-1&quot;</span>), -<span class="tok-number">0.5</span>);</span>
<span class="line" id="L110">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-kw">try</span> parseFloat(<span class="tok-type">f16</span>, <span class="tok-str">&quot;0x10p+10&quot;</span>), <span class="tok-number">16384.0</span>);</span>
<span class="line" id="L111">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-kw">try</span> parseFloat(<span class="tok-type">f16</span>, <span class="tok-str">&quot;0x10p-10&quot;</span>), <span class="tok-number">0.015625</span>);</span>
<span class="line" id="L112">    <span class="tok-comment">// Max normalized value.</span>
</span>
<span class="line" id="L113">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-kw">try</span> parseFloat(<span class="tok-type">f16</span>, <span class="tok-str">&quot;0x1.ffcp+15&quot;</span>), math.floatMax(<span class="tok-type">f16</span>));</span>
<span class="line" id="L114">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-kw">try</span> parseFloat(<span class="tok-type">f16</span>, <span class="tok-str">&quot;-0x1.ffcp+15&quot;</span>), -math.floatMax(<span class="tok-type">f16</span>));</span>
<span class="line" id="L115">    <span class="tok-comment">// Min normalized value.</span>
</span>
<span class="line" id="L116">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-kw">try</span> parseFloat(<span class="tok-type">f16</span>, <span class="tok-str">&quot;0x1p-14&quot;</span>), math.floatMin(<span class="tok-type">f16</span>));</span>
<span class="line" id="L117">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-kw">try</span> parseFloat(<span class="tok-type">f16</span>, <span class="tok-str">&quot;-0x1p-14&quot;</span>), -math.floatMin(<span class="tok-type">f16</span>));</span>
<span class="line" id="L118">    <span class="tok-comment">// Min denormal value.</span>
</span>
<span class="line" id="L119">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-kw">try</span> parseFloat(<span class="tok-type">f16</span>, <span class="tok-str">&quot;0x1p-24&quot;</span>), math.floatTrueMin(<span class="tok-type">f16</span>));</span>
<span class="line" id="L120">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-kw">try</span> parseFloat(<span class="tok-type">f16</span>, <span class="tok-str">&quot;-0x1p-24&quot;</span>), -math.floatTrueMin(<span class="tok-type">f16</span>));</span>
<span class="line" id="L121">}</span>
<span class="line" id="L122"></span>
<span class="line" id="L123"><span class="tok-kw">test</span> <span class="tok-str">&quot;fmt.parseFloat hex.f32&quot;</span> {</span>
<span class="line" id="L124">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-kw">try</span> parseFloat(<span class="tok-type">f32</span>, <span class="tok-str">&quot;0x1p0&quot;</span>), <span class="tok-number">1.0</span>);</span>
<span class="line" id="L125">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-kw">try</span> parseFloat(<span class="tok-type">f32</span>, <span class="tok-str">&quot;-0x1p-1&quot;</span>), -<span class="tok-number">0.5</span>);</span>
<span class="line" id="L126">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-kw">try</span> parseFloat(<span class="tok-type">f32</span>, <span class="tok-str">&quot;0x10p+10&quot;</span>), <span class="tok-number">16384.0</span>);</span>
<span class="line" id="L127">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-kw">try</span> parseFloat(<span class="tok-type">f32</span>, <span class="tok-str">&quot;0x10p-10&quot;</span>), <span class="tok-number">0.015625</span>);</span>
<span class="line" id="L128">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-kw">try</span> parseFloat(<span class="tok-type">f32</span>, <span class="tok-str">&quot;0x0.ffffffp128&quot;</span>), <span class="tok-number">0x0.ffffffp128</span>);</span>
<span class="line" id="L129">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-kw">try</span> parseFloat(<span class="tok-type">f32</span>, <span class="tok-str">&quot;0x0.1234570p-125&quot;</span>), <span class="tok-number">0x0.1234570p-125</span>);</span>
<span class="line" id="L130">    <span class="tok-comment">// Max normalized value.</span>
</span>
<span class="line" id="L131">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-kw">try</span> parseFloat(<span class="tok-type">f32</span>, <span class="tok-str">&quot;0x1.fffffeP+127&quot;</span>), math.floatMax(<span class="tok-type">f32</span>));</span>
<span class="line" id="L132">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-kw">try</span> parseFloat(<span class="tok-type">f32</span>, <span class="tok-str">&quot;-0x1.fffffeP+127&quot;</span>), -math.floatMax(<span class="tok-type">f32</span>));</span>
<span class="line" id="L133">    <span class="tok-comment">// Min normalized value.</span>
</span>
<span class="line" id="L134">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-kw">try</span> parseFloat(<span class="tok-type">f32</span>, <span class="tok-str">&quot;0x1p-126&quot;</span>), math.floatMin(<span class="tok-type">f32</span>));</span>
<span class="line" id="L135">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-kw">try</span> parseFloat(<span class="tok-type">f32</span>, <span class="tok-str">&quot;-0x1p-126&quot;</span>), -math.floatMin(<span class="tok-type">f32</span>));</span>
<span class="line" id="L136">    <span class="tok-comment">// Min denormal value.</span>
</span>
<span class="line" id="L137">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-kw">try</span> parseFloat(<span class="tok-type">f32</span>, <span class="tok-str">&quot;0x1P-149&quot;</span>), math.floatTrueMin(<span class="tok-type">f32</span>));</span>
<span class="line" id="L138">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-kw">try</span> parseFloat(<span class="tok-type">f32</span>, <span class="tok-str">&quot;-0x1P-149&quot;</span>), -math.floatTrueMin(<span class="tok-type">f32</span>));</span>
<span class="line" id="L139">}</span>
<span class="line" id="L140"></span>
<span class="line" id="L141"><span class="tok-kw">test</span> <span class="tok-str">&quot;fmt.parseFloat hex.f64&quot;</span> {</span>
<span class="line" id="L142">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-kw">try</span> parseFloat(<span class="tok-type">f64</span>, <span class="tok-str">&quot;0x1p0&quot;</span>), <span class="tok-number">1.0</span>);</span>
<span class="line" id="L143">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-kw">try</span> parseFloat(<span class="tok-type">f64</span>, <span class="tok-str">&quot;-0x1p-1&quot;</span>), -<span class="tok-number">0.5</span>);</span>
<span class="line" id="L144">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-kw">try</span> parseFloat(<span class="tok-type">f64</span>, <span class="tok-str">&quot;0x10p+10&quot;</span>), <span class="tok-number">16384.0</span>);</span>
<span class="line" id="L145">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-kw">try</span> parseFloat(<span class="tok-type">f64</span>, <span class="tok-str">&quot;0x10p-10&quot;</span>), <span class="tok-number">0.015625</span>);</span>
<span class="line" id="L146">    <span class="tok-comment">// Max normalized value.</span>
</span>
<span class="line" id="L147">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-kw">try</span> parseFloat(<span class="tok-type">f64</span>, <span class="tok-str">&quot;0x1.fffffffffffffp+1023&quot;</span>), math.floatMax(<span class="tok-type">f64</span>));</span>
<span class="line" id="L148">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-kw">try</span> parseFloat(<span class="tok-type">f64</span>, <span class="tok-str">&quot;-0x1.fffffffffffffp1023&quot;</span>), -math.floatMax(<span class="tok-type">f64</span>));</span>
<span class="line" id="L149">    <span class="tok-comment">// Min normalized value.</span>
</span>
<span class="line" id="L150">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-kw">try</span> parseFloat(<span class="tok-type">f64</span>, <span class="tok-str">&quot;0x1p-1022&quot;</span>), math.floatMin(<span class="tok-type">f64</span>));</span>
<span class="line" id="L151">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-kw">try</span> parseFloat(<span class="tok-type">f64</span>, <span class="tok-str">&quot;-0x1p-1022&quot;</span>), -math.floatMin(<span class="tok-type">f64</span>));</span>
<span class="line" id="L152">    <span class="tok-comment">// Min denormalized value.</span>
</span>
<span class="line" id="L153">    <span class="tok-comment">//try testing.expectEqual(try parseFloat(f64, &quot;0x1p-1074&quot;), math.floatTrueMin(f64));</span>
</span>
<span class="line" id="L154">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-kw">try</span> parseFloat(<span class="tok-type">f64</span>, <span class="tok-str">&quot;-0x1p-1074&quot;</span>), -math.floatTrueMin(<span class="tok-type">f64</span>));</span>
<span class="line" id="L155">}</span>
<span class="line" id="L156"><span class="tok-kw">test</span> <span class="tok-str">&quot;fmt.parseFloat hex.f128&quot;</span> {</span>
<span class="line" id="L157">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-kw">try</span> parseFloat(<span class="tok-type">f128</span>, <span class="tok-str">&quot;0x1p0&quot;</span>), <span class="tok-number">1.0</span>);</span>
<span class="line" id="L158">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-kw">try</span> parseFloat(<span class="tok-type">f128</span>, <span class="tok-str">&quot;-0x1p-1&quot;</span>), -<span class="tok-number">0.5</span>);</span>
<span class="line" id="L159">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-kw">try</span> parseFloat(<span class="tok-type">f128</span>, <span class="tok-str">&quot;0x10p+10&quot;</span>), <span class="tok-number">16384.0</span>);</span>
<span class="line" id="L160">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-kw">try</span> parseFloat(<span class="tok-type">f128</span>, <span class="tok-str">&quot;0x10p-10&quot;</span>), <span class="tok-number">0.015625</span>);</span>
<span class="line" id="L161">    <span class="tok-comment">// Max normalized value.</span>
</span>
<span class="line" id="L162">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-kw">try</span> parseFloat(<span class="tok-type">f128</span>, <span class="tok-str">&quot;0xf.fffffffffffffffffffffffffff8p+16380&quot;</span>), math.floatMax(<span class="tok-type">f128</span>));</span>
<span class="line" id="L163">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-kw">try</span> parseFloat(<span class="tok-type">f128</span>, <span class="tok-str">&quot;-0xf.fffffffffffffffffffffffffff8p+16380&quot;</span>), -math.floatMax(<span class="tok-type">f128</span>));</span>
<span class="line" id="L164">    <span class="tok-comment">// Min normalized value.</span>
</span>
<span class="line" id="L165">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-kw">try</span> parseFloat(<span class="tok-type">f128</span>, <span class="tok-str">&quot;0x1p-16382&quot;</span>), math.floatMin(<span class="tok-type">f128</span>));</span>
<span class="line" id="L166">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-kw">try</span> parseFloat(<span class="tok-type">f128</span>, <span class="tok-str">&quot;-0x1p-16382&quot;</span>), -math.floatMin(<span class="tok-type">f128</span>));</span>
<span class="line" id="L167">    <span class="tok-comment">// // Min denormalized value.</span>
</span>
<span class="line" id="L168">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-kw">try</span> parseFloat(<span class="tok-type">f128</span>, <span class="tok-str">&quot;0x1p-16494&quot;</span>), math.floatTrueMin(<span class="tok-type">f128</span>));</span>
<span class="line" id="L169">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-kw">try</span> parseFloat(<span class="tok-type">f128</span>, <span class="tok-str">&quot;-0x1p-16494&quot;</span>), -math.floatTrueMin(<span class="tok-type">f128</span>));</span>
<span class="line" id="L170"></span>
<span class="line" id="L171">    <span class="tok-comment">// NOTE: We are performing round-to-even. Previous behavior was round-up.</span>
</span>
<span class="line" id="L172">    <span class="tok-comment">// try testing.expectEqual(try parseFloat(f128, &quot;0x1.edcb34a235253948765432134674fp-1&quot;), 0x1.edcb34a235253948765432134674fp-1);</span>
</span>
<span class="line" id="L173">}</span>
<span class="line" id="L174"></span>
</code></pre></body>
</html>