<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">    <title>math/signbit.zig - source view</title>
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
<span class="line" id="L5"><span class="tok-comment">/// Returns whether x is negative or negative 0.</span></span>
<span class="line" id="L6"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">signbit</span>(x: <span class="tok-kw">anytype</span>) <span class="tok-type">bool</span> {</span>
<span class="line" id="L7">    <span class="tok-kw">const</span> T = <span class="tok-builtin">@TypeOf</span>(x);</span>
<span class="line" id="L8">    <span class="tok-kw">const</span> TBits = std.meta.Int(.unsigned, <span class="tok-builtin">@typeInfo</span>(T).Float.bits);</span>
<span class="line" id="L9">    <span class="tok-kw">return</span> <span class="tok-builtin">@bitCast</span>(TBits, x) &gt;&gt; (<span class="tok-builtin">@bitSizeOf</span>(T) - <span class="tok-number">1</span>) != <span class="tok-number">0</span>;</span>
<span class="line" id="L10">}</span>
<span class="line" id="L11"></span>
<span class="line" id="L12"><span class="tok-kw">test</span> <span class="tok-str">&quot;math.signbit&quot;</span> {</span>
<span class="line" id="L13">    <span class="tok-kw">inline</span> <span class="tok-kw">for</span> ([_]<span class="tok-type">type</span>{ <span class="tok-type">f16</span>, <span class="tok-type">f32</span>, <span class="tok-type">f64</span>, f80, <span class="tok-type">f128</span> }) |T| {</span>
<span class="line" id="L14">        <span class="tok-kw">try</span> expect(!signbit(<span class="tok-builtin">@as</span>(T, <span class="tok-number">0.0</span>)));</span>
<span class="line" id="L15">        <span class="tok-kw">try</span> expect(!signbit(<span class="tok-builtin">@as</span>(T, <span class="tok-number">1.0</span>)));</span>
<span class="line" id="L16">        <span class="tok-kw">try</span> expect(signbit(<span class="tok-builtin">@as</span>(T, -<span class="tok-number">2.0</span>)));</span>
<span class="line" id="L17">        <span class="tok-kw">try</span> expect(signbit(<span class="tok-builtin">@as</span>(T, -<span class="tok-number">0.0</span>)));</span>
<span class="line" id="L18">        <span class="tok-kw">try</span> expect(!signbit(math.inf(T)));</span>
<span class="line" id="L19">        <span class="tok-kw">try</span> expect(signbit(-math.inf(T)));</span>
<span class="line" id="L20">        <span class="tok-kw">try</span> expect(!signbit(math.nan(T)));</span>
<span class="line" id="L21">        <span class="tok-kw">try</span> expect(signbit(-math.nan(T)));</span>
<span class="line" id="L22">    }</span>
<span class="line" id="L23">}</span>
<span class="line" id="L24"></span>
</code></pre></body>
</html>