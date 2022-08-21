<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">    <title>math/big.zig - source view</title>
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
<span class="line" id="L2"><span class="tok-kw">const</span> assert = std.debug.assert;</span>
<span class="line" id="L3"></span>
<span class="line" id="L4"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> Rational = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;big/rational.zig&quot;</span>).Rational;</span>
<span class="line" id="L5"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> int = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;big/int.zig&quot;</span>);</span>
<span class="line" id="L6"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> Limb = <span class="tok-type">usize</span>;</span>
<span class="line" id="L7"><span class="tok-kw">const</span> limb_info = <span class="tok-builtin">@typeInfo</span>(Limb).Int;</span>
<span class="line" id="L8"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SignedLimb = std.meta.Int(.signed, limb_info.bits);</span>
<span class="line" id="L9"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> DoubleLimb = std.meta.Int(.unsigned, <span class="tok-number">2</span> * limb_info.bits);</span>
<span class="line" id="L10"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> HalfLimb = std.meta.Int(.unsigned, limb_info.bits / <span class="tok-number">2</span>);</span>
<span class="line" id="L11"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SignedDoubleLimb = std.meta.Int(.signed, <span class="tok-number">2</span> * limb_info.bits);</span>
<span class="line" id="L12"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> Log2Limb = std.math.Log2Int(Limb);</span>
<span class="line" id="L13"></span>
<span class="line" id="L14"><span class="tok-kw">comptime</span> {</span>
<span class="line" id="L15">    assert(std.math.floorPowerOfTwo(<span class="tok-type">usize</span>, limb_info.bits) == limb_info.bits);</span>
<span class="line" id="L16">    assert(limb_info.bits &lt;= <span class="tok-number">64</span>); <span class="tok-comment">// u128 set is unsupported</span>
</span>
<span class="line" id="L17">    assert(limb_info.signedness == .unsigned);</span>
<span class="line" id="L18">}</span>
<span class="line" id="L19"></span>
<span class="line" id="L20"><span class="tok-kw">test</span> {</span>
<span class="line" id="L21">    _ = int;</span>
<span class="line" id="L22">    _ = Rational;</span>
<span class="line" id="L23">    _ = Limb;</span>
<span class="line" id="L24">    _ = SignedLimb;</span>
<span class="line" id="L25">    _ = DoubleLimb;</span>
<span class="line" id="L26">    _ = SignedDoubleLimb;</span>
<span class="line" id="L27">    _ = Log2Limb;</span>
<span class="line" id="L28">}</span>
<span class="line" id="L29"></span>
</code></pre></body>
</html>