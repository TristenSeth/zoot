<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">    <title>compress/deflate/bits_utils.zig - source view</title>
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
<pre><code><span class="line" id="L1"><span class="tok-kw">const</span> math = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;std&quot;</span>).math;</span>
<span class="line" id="L2"></span>
<span class="line" id="L3"><span class="tok-comment">// Reverse bit-by-bit a N-bit code.</span>
</span>
<span class="line" id="L4"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">bitReverse</span>(<span class="tok-kw">comptime</span> T: <span class="tok-type">type</span>, value: T, N: <span class="tok-type">usize</span>) T {</span>
<span class="line" id="L5">    <span class="tok-kw">const</span> r = <span class="tok-builtin">@bitReverse</span>(T, value);</span>
<span class="line" id="L6">    <span class="tok-kw">return</span> r &gt;&gt; <span class="tok-builtin">@intCast</span>(math.Log2Int(T), <span class="tok-builtin">@typeInfo</span>(T).Int.bits - N);</span>
<span class="line" id="L7">}</span>
<span class="line" id="L8"></span>
<span class="line" id="L9"><span class="tok-kw">test</span> <span class="tok-str">&quot;bitReverse&quot;</span> {</span>
<span class="line" id="L10">    <span class="tok-kw">const</span> std = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;std&quot;</span>);</span>
<span class="line" id="L11">    <span class="tok-kw">const</span> expect = std.testing.expect;</span>
<span class="line" id="L12"></span>
<span class="line" id="L13">    <span class="tok-kw">const</span> ReverseBitsTest = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L14">        in: <span class="tok-type">u16</span>,</span>
<span class="line" id="L15">        bit_count: <span class="tok-type">u5</span>,</span>
<span class="line" id="L16">        out: <span class="tok-type">u16</span>,</span>
<span class="line" id="L17">    };</span>
<span class="line" id="L18"></span>
<span class="line" id="L19">    <span class="tok-kw">var</span> reverse_bits_tests = [_]ReverseBitsTest{</span>
<span class="line" id="L20">        .{ .in = <span class="tok-number">1</span>, .bit_count = <span class="tok-number">1</span>, .out = <span class="tok-number">1</span> },</span>
<span class="line" id="L21">        .{ .in = <span class="tok-number">1</span>, .bit_count = <span class="tok-number">2</span>, .out = <span class="tok-number">2</span> },</span>
<span class="line" id="L22">        .{ .in = <span class="tok-number">1</span>, .bit_count = <span class="tok-number">3</span>, .out = <span class="tok-number">4</span> },</span>
<span class="line" id="L23">        .{ .in = <span class="tok-number">1</span>, .bit_count = <span class="tok-number">4</span>, .out = <span class="tok-number">8</span> },</span>
<span class="line" id="L24">        .{ .in = <span class="tok-number">1</span>, .bit_count = <span class="tok-number">5</span>, .out = <span class="tok-number">16</span> },</span>
<span class="line" id="L25">        .{ .in = <span class="tok-number">17</span>, .bit_count = <span class="tok-number">5</span>, .out = <span class="tok-number">17</span> },</span>
<span class="line" id="L26">        .{ .in = <span class="tok-number">257</span>, .bit_count = <span class="tok-number">9</span>, .out = <span class="tok-number">257</span> },</span>
<span class="line" id="L27">        .{ .in = <span class="tok-number">29</span>, .bit_count = <span class="tok-number">5</span>, .out = <span class="tok-number">23</span> },</span>
<span class="line" id="L28">    };</span>
<span class="line" id="L29"></span>
<span class="line" id="L30">    <span class="tok-kw">for</span> (reverse_bits_tests) |h| {</span>
<span class="line" id="L31">        <span class="tok-kw">var</span> v = bitReverse(<span class="tok-type">u16</span>, h.in, h.bit_count);</span>
<span class="line" id="L32">        <span class="tok-kw">try</span> expect(v == h.out);</span>
<span class="line" id="L33">    }</span>
<span class="line" id="L34">}</span>
<span class="line" id="L35"></span>
</code></pre></body>
</html>