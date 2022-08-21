<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">    <title>compress/deflate/deflate_const.zig - source view</title>
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
<pre><code><span class="line" id="L1"><span class="tok-comment">// Deflate</span>
</span>
<span class="line" id="L2"></span>
<span class="line" id="L3"><span class="tok-comment">// Biggest block size for uncompressed block.</span>
</span>
<span class="line" id="L4"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> max_store_block_size = <span class="tok-number">65535</span>;</span>
<span class="line" id="L5"><span class="tok-comment">// The special code used to mark the end of a block.</span>
</span>
<span class="line" id="L6"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> end_block_marker = <span class="tok-number">256</span>;</span>
<span class="line" id="L7"></span>
<span class="line" id="L8"><span class="tok-comment">// LZ77</span>
</span>
<span class="line" id="L9"></span>
<span class="line" id="L10"><span class="tok-comment">// The smallest match length per the RFC section 3.2.5</span>
</span>
<span class="line" id="L11"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> base_match_length = <span class="tok-number">3</span>;</span>
<span class="line" id="L12"><span class="tok-comment">// The smallest match offset.</span>
</span>
<span class="line" id="L13"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> base_match_offset = <span class="tok-number">1</span>;</span>
<span class="line" id="L14"><span class="tok-comment">// The largest match length.</span>
</span>
<span class="line" id="L15"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> max_match_length = <span class="tok-number">258</span>;</span>
<span class="line" id="L16"><span class="tok-comment">// The largest match offset.</span>
</span>
<span class="line" id="L17"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> max_match_offset = <span class="tok-number">1</span> &lt;&lt; <span class="tok-number">15</span>;</span>
<span class="line" id="L18"></span>
<span class="line" id="L19"><span class="tok-comment">// Huffman Codes</span>
</span>
<span class="line" id="L20"></span>
<span class="line" id="L21"><span class="tok-comment">// The largest offset code.</span>
</span>
<span class="line" id="L22"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> offset_code_count = <span class="tok-number">30</span>;</span>
<span class="line" id="L23"><span class="tok-comment">// Max number of frequencies used for a Huffman Code</span>
</span>
<span class="line" id="L24"><span class="tok-comment">// Possible lengths are codegenCodeCount (19), offset_code_count (30) and max_num_lit (286).</span>
</span>
<span class="line" id="L25"><span class="tok-comment">// The largest of these is max_num_lit.</span>
</span>
<span class="line" id="L26"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> max_num_frequencies = max_num_lit;</span>
<span class="line" id="L27"><span class="tok-comment">// Maximum number of literals.</span>
</span>
<span class="line" id="L28"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> max_num_lit = <span class="tok-number">286</span>;</span>
<span class="line" id="L29"></span>
</code></pre></body>
</html>