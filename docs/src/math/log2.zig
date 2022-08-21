<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">    <title>math/log2.zig - source view</title>
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
<span class="line" id="L5"><span class="tok-comment">/// Returns the base-2 logarithm of x.</span></span>
<span class="line" id="L6"><span class="tok-comment">///</span></span>
<span class="line" id="L7"><span class="tok-comment">/// Special Cases:</span></span>
<span class="line" id="L8"><span class="tok-comment">///  - log2(+inf)  = +inf</span></span>
<span class="line" id="L9"><span class="tok-comment">///  - log2(0)     = -inf</span></span>
<span class="line" id="L10"><span class="tok-comment">///  - log2(x)     = nan if x &lt; 0</span></span>
<span class="line" id="L11"><span class="tok-comment">///  - log2(nan)   = nan</span></span>
<span class="line" id="L12"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">log2</span>(x: <span class="tok-kw">anytype</span>) <span class="tok-builtin">@TypeOf</span>(x) {</span>
<span class="line" id="L13">    <span class="tok-kw">const</span> T = <span class="tok-builtin">@TypeOf</span>(x);</span>
<span class="line" id="L14">    <span class="tok-kw">switch</span> (<span class="tok-builtin">@typeInfo</span>(T)) {</span>
<span class="line" id="L15">        .ComptimeFloat =&gt; {</span>
<span class="line" id="L16">            <span class="tok-kw">return</span> <span class="tok-builtin">@as</span>(<span class="tok-type">comptime_float</span>, <span class="tok-builtin">@log2</span>(x));</span>
<span class="line" id="L17">        },</span>
<span class="line" id="L18">        .Float =&gt; <span class="tok-kw">return</span> <span class="tok-builtin">@log2</span>(x),</span>
<span class="line" id="L19">        .ComptimeInt =&gt; <span class="tok-kw">comptime</span> {</span>
<span class="line" id="L20">            <span class="tok-kw">var</span> x_shifted = x;</span>
<span class="line" id="L21">            <span class="tok-comment">// First, calculate floorPowerOfTwo(x)</span>
</span>
<span class="line" id="L22">            <span class="tok-kw">var</span> shift_amt = <span class="tok-number">1</span>;</span>
<span class="line" id="L23">            <span class="tok-kw">while</span> (x_shifted &gt;&gt; (shift_amt &lt;&lt; <span class="tok-number">1</span>) != <span class="tok-number">0</span>) shift_amt &lt;&lt;= <span class="tok-number">1</span>;</span>
<span class="line" id="L24"></span>
<span class="line" id="L25">            <span class="tok-comment">// Answer is in the range [shift_amt, 2 * shift_amt - 1]</span>
</span>
<span class="line" id="L26">            <span class="tok-comment">// We can find it in O(log(N)) using binary search.</span>
</span>
<span class="line" id="L27">            <span class="tok-kw">var</span> result = <span class="tok-number">0</span>;</span>
<span class="line" id="L28">            <span class="tok-kw">while</span> (shift_amt != <span class="tok-number">0</span>) : (shift_amt &gt;&gt;= <span class="tok-number">1</span>) {</span>
<span class="line" id="L29">                <span class="tok-kw">if</span> (x_shifted &gt;&gt; shift_amt != <span class="tok-number">0</span>) {</span>
<span class="line" id="L30">                    x_shifted &gt;&gt;= shift_amt;</span>
<span class="line" id="L31">                    result += shift_amt;</span>
<span class="line" id="L32">                }</span>
<span class="line" id="L33">            }</span>
<span class="line" id="L34">            <span class="tok-kw">return</span> result;</span>
<span class="line" id="L35">        },</span>
<span class="line" id="L36">        .Int =&gt; |IntType| <span class="tok-kw">switch</span> (IntType.signedness) {</span>
<span class="line" id="L37">            .signed =&gt; <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;log2 not implemented for signed integers&quot;</span>),</span>
<span class="line" id="L38">            .unsigned =&gt; <span class="tok-kw">return</span> math.log2_int(T, x),</span>
<span class="line" id="L39">        },</span>
<span class="line" id="L40">        <span class="tok-kw">else</span> =&gt; <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;log2 not implemented for &quot;</span> ++ <span class="tok-builtin">@typeName</span>(T)),</span>
<span class="line" id="L41">    }</span>
<span class="line" id="L42">}</span>
<span class="line" id="L43"></span>
<span class="line" id="L44"><span class="tok-kw">test</span> <span class="tok-str">&quot;log2&quot;</span> {</span>
<span class="line" id="L45">    <span class="tok-kw">try</span> expect(log2(<span class="tok-builtin">@as</span>(<span class="tok-type">f32</span>, <span class="tok-number">0.2</span>)) == <span class="tok-builtin">@log2</span>(<span class="tok-number">0.2</span>));</span>
<span class="line" id="L46">    <span class="tok-kw">try</span> expect(log2(<span class="tok-builtin">@as</span>(<span class="tok-type">f64</span>, <span class="tok-number">0.2</span>)) == <span class="tok-builtin">@log2</span>(<span class="tok-number">0.2</span>));</span>
<span class="line" id="L47">    <span class="tok-kw">comptime</span> {</span>
<span class="line" id="L48">        <span class="tok-kw">try</span> expect(log2(<span class="tok-number">1</span>) == <span class="tok-number">0</span>);</span>
<span class="line" id="L49">        <span class="tok-kw">try</span> expect(log2(<span class="tok-number">15</span>) == <span class="tok-number">3</span>);</span>
<span class="line" id="L50">        <span class="tok-kw">try</span> expect(log2(<span class="tok-number">16</span>) == <span class="tok-number">4</span>);</span>
<span class="line" id="L51">        <span class="tok-kw">try</span> expect(log2(<span class="tok-number">1</span> &lt;&lt; <span class="tok-number">4073</span>) == <span class="tok-number">4073</span>);</span>
<span class="line" id="L52">    }</span>
<span class="line" id="L53">}</span>
<span class="line" id="L54"></span>
</code></pre></body>
</html>