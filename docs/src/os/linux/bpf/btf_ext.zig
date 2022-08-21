<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">    <title>os/linux/bpf/btf_ext.zig - source view</title>
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
<pre><code><span class="line" id="L1"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> Header = <span class="tok-kw">packed</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L2">    magic: <span class="tok-type">u16</span>,</span>
<span class="line" id="L3">    version: <span class="tok-type">u8</span>,</span>
<span class="line" id="L4">    flags: <span class="tok-type">u8</span>,</span>
<span class="line" id="L5">    hdr_len: <span class="tok-type">u32</span>,</span>
<span class="line" id="L6"></span>
<span class="line" id="L7">    <span class="tok-comment">/// All offsets are in bytes relative to the end of this header</span></span>
<span class="line" id="L8">    func_info_off: <span class="tok-type">u32</span>,</span>
<span class="line" id="L9">    func_info_len: <span class="tok-type">u32</span>,</span>
<span class="line" id="L10">    line_info_off: <span class="tok-type">u32</span>,</span>
<span class="line" id="L11">    line_info_len: <span class="tok-type">u32</span>,</span>
<span class="line" id="L12">};</span>
<span class="line" id="L13"></span>
<span class="line" id="L14"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> InfoSec = <span class="tok-kw">packed</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L15">    sec_name_off: <span class="tok-type">u32</span>,</span>
<span class="line" id="L16">    num_info: <span class="tok-type">u32</span>,</span>
<span class="line" id="L17">    <span class="tok-comment">// TODO: communicate that there is data here</span>
</span>
<span class="line" id="L18">    <span class="tok-comment">//data: [0]u8,</span>
</span>
<span class="line" id="L19">};</span>
<span class="line" id="L20"></span>
</code></pre></body>
</html>