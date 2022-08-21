<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">    <title>math/isnormal.zig - source view</title>
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
<pre><code><span class="line" id="L1"><span class="tok-kw">const</span> std = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;../std.zig&quot;</span>);</span>
<span class="line" id="L2"><span class="tok-kw">const</span> math = std.math;</span>
<span class="line" id="L3"><span class="tok-kw">const</span> expect = std.testing.expect;</span>
<span class="line" id="L4"></span>
<span class="line" id="L5"><span class="tok-comment">/// Returns whether x is neither zero, subnormal, infinity, or NaN.</span></span>
<span class="line" id="L6"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">isNormal</span>(x: <span class="tok-kw">anytype</span>) <span class="tok-type">bool</span> {</span>
<span class="line" id="L7">    <span class="tok-kw">const</span> T = <span class="tok-builtin">@TypeOf</span>(x);</span>
<span class="line" id="L8">    <span class="tok-kw">const</span> TBits = std.meta.Int(.unsigned, <span class="tok-builtin">@typeInfo</span>(T).Float.bits);</span>
<span class="line" id="L9"></span>
<span class="line" id="L10">    <span class="tok-kw">const</span> increment_exp = <span class="tok-number">1</span> &lt;&lt; math.floatMantissaBits(T);</span>
<span class="line" id="L11">    <span class="tok-kw">const</span> remove_sign = ~<span class="tok-builtin">@as</span>(TBits, <span class="tok-number">0</span>) &gt;&gt; <span class="tok-number">1</span>;</span>
<span class="line" id="L12"></span>
<span class="line" id="L13">    <span class="tok-comment">// We add 1 to the exponent, and if it overflows to 0 or becomes 1,</span>
</span>
<span class="line" id="L14">    <span class="tok-comment">// then it was all zeroes (subnormal) or all ones (special, inf/nan).</span>
</span>
<span class="line" id="L15">    <span class="tok-comment">// The sign bit is removed because all ones would overflow into it.</span>
</span>
<span class="line" id="L16">    <span class="tok-comment">// For f80, even though it has an explicit integer part stored,</span>
</span>
<span class="line" id="L17">    <span class="tok-comment">// the exponent effectively takes priority if mismatching.</span>
</span>
<span class="line" id="L18">    <span class="tok-kw">const</span> value = <span class="tok-builtin">@bitCast</span>(TBits, x) +% increment_exp;</span>
<span class="line" id="L19">    <span class="tok-kw">return</span> value &amp; remove_sign &gt;= (increment_exp &lt;&lt; <span class="tok-number">1</span>);</span>
<span class="line" id="L20">}</span>
<span class="line" id="L21"></span>
<span class="line" id="L22"><span class="tok-kw">test</span> <span class="tok-str">&quot;math.isNormal&quot;</span> {</span>
<span class="line" id="L23">    <span class="tok-comment">// TODO add `c_longdouble' when math.inf(T) supports it</span>
</span>
<span class="line" id="L24">    <span class="tok-kw">inline</span> <span class="tok-kw">for</span> ([_]<span class="tok-type">type</span>{ <span class="tok-type">f16</span>, <span class="tok-type">f32</span>, <span class="tok-type">f64</span>, f80, <span class="tok-type">f128</span> }) |T| {</span>
<span class="line" id="L25">        <span class="tok-kw">const</span> TBits = std.meta.Int(.unsigned, <span class="tok-builtin">@bitSizeOf</span>(T));</span>
<span class="line" id="L26"></span>
<span class="line" id="L27">        <span class="tok-comment">// normals</span>
</span>
<span class="line" id="L28">        <span class="tok-kw">try</span> expect(isNormal(<span class="tok-builtin">@as</span>(T, <span class="tok-number">1.0</span>)));</span>
<span class="line" id="L29">        <span class="tok-kw">try</span> expect(isNormal(math.floatMin(T)));</span>
<span class="line" id="L30">        <span class="tok-kw">try</span> expect(isNormal(math.floatMax(T)));</span>
<span class="line" id="L31"></span>
<span class="line" id="L32">        <span class="tok-comment">// subnormals</span>
</span>
<span class="line" id="L33">        <span class="tok-kw">try</span> expect(!isNormal(<span class="tok-builtin">@as</span>(T, -<span class="tok-number">0.0</span>)));</span>
<span class="line" id="L34">        <span class="tok-kw">try</span> expect(!isNormal(<span class="tok-builtin">@as</span>(T, <span class="tok-number">0.0</span>)));</span>
<span class="line" id="L35">        <span class="tok-kw">try</span> expect(!isNormal(<span class="tok-builtin">@as</span>(T, math.floatTrueMin(T))));</span>
<span class="line" id="L36"></span>
<span class="line" id="L37">        <span class="tok-comment">// largest subnormal</span>
</span>
<span class="line" id="L38">        <span class="tok-kw">try</span> expect(!isNormal(<span class="tok-builtin">@bitCast</span>(T, ~(~<span class="tok-builtin">@as</span>(TBits, <span class="tok-number">0</span>) &lt;&lt; math.floatFractionalBits(T)))));</span>
<span class="line" id="L39"></span>
<span class="line" id="L40">        <span class="tok-comment">// non-finite numbers</span>
</span>
<span class="line" id="L41">        <span class="tok-kw">try</span> expect(!isNormal(-math.inf(T)));</span>
<span class="line" id="L42">        <span class="tok-kw">try</span> expect(!isNormal(math.inf(T)));</span>
<span class="line" id="L43">        <span class="tok-kw">try</span> expect(!isNormal(math.nan(T)));</span>
<span class="line" id="L44"></span>
<span class="line" id="L45">        <span class="tok-comment">// overflow edge-case (described in implementation, also see #10133)</span>
</span>
<span class="line" id="L46">        <span class="tok-kw">try</span> expect(!isNormal(<span class="tok-builtin">@bitCast</span>(T, ~<span class="tok-builtin">@as</span>(TBits, <span class="tok-number">0</span>))));</span>
<span class="line" id="L47">    }</span>
<span class="line" id="L48">}</span>
<span class="line" id="L49"></span>
</code></pre></body>
</html>