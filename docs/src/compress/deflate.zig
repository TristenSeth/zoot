<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">    <title>compress/deflate.zig - source view</title>
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
<pre><code><span class="line" id="L1"><span class="tok-comment">//! The deflate package is a translation of the Go code of the compress/flate package from</span></span>
<span class="line" id="L2"><span class="tok-comment">//! https://go.googlesource.com/go/+/refs/tags/go1.17/src/compress/flate/</span></span>
<span class="line" id="L3"></span>
<span class="line" id="L4"><span class="tok-kw">const</span> deflate = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;deflate/compressor.zig&quot;</span>);</span>
<span class="line" id="L5"><span class="tok-kw">const</span> inflate = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;deflate/decompressor.zig&quot;</span>);</span>
<span class="line" id="L6"></span>
<span class="line" id="L7"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> Compression = deflate.Compression;</span>
<span class="line" id="L8"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> Compressor = deflate.Compressor;</span>
<span class="line" id="L9"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> Decompressor = inflate.Decompressor;</span>
<span class="line" id="L10"></span>
<span class="line" id="L11"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> compressor = deflate.compressor;</span>
<span class="line" id="L12"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> decompressor = inflate.decompressor;</span>
<span class="line" id="L13"></span>
<span class="line" id="L14"><span class="tok-kw">test</span> {</span>
<span class="line" id="L15">    _ = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;deflate/token.zig&quot;</span>);</span>
<span class="line" id="L16">    _ = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;deflate/bits_utils.zig&quot;</span>);</span>
<span class="line" id="L17">    _ = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;deflate/dict_decoder.zig&quot;</span>);</span>
<span class="line" id="L18"></span>
<span class="line" id="L19">    _ = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;deflate/huffman_code.zig&quot;</span>);</span>
<span class="line" id="L20">    _ = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;deflate/huffman_bit_writer.zig&quot;</span>);</span>
<span class="line" id="L21"></span>
<span class="line" id="L22">    _ = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;deflate/compressor.zig&quot;</span>);</span>
<span class="line" id="L23">    _ = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;deflate/compressor_test.zig&quot;</span>);</span>
<span class="line" id="L24"></span>
<span class="line" id="L25">    _ = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;deflate/deflate_fast.zig&quot;</span>);</span>
<span class="line" id="L26">    _ = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;deflate/deflate_fast_test.zig&quot;</span>);</span>
<span class="line" id="L27"></span>
<span class="line" id="L28">    _ = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;deflate/decompressor.zig&quot;</span>);</span>
<span class="line" id="L29">}</span>
<span class="line" id="L30"></span>
</code></pre></body>
</html>