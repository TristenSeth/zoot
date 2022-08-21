<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">    <title>io/buffered_atomic_file.zig - source view</title>
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
<span class="line" id="L2"><span class="tok-kw">const</span> mem = std.mem;</span>
<span class="line" id="L3"><span class="tok-kw">const</span> fs = std.fs;</span>
<span class="line" id="L4"><span class="tok-kw">const</span> File = std.fs.File;</span>
<span class="line" id="L5"></span>
<span class="line" id="L6"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> BufferedAtomicFile = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L7">    atomic_file: fs.AtomicFile,</span>
<span class="line" id="L8">    file_writer: File.Writer,</span>
<span class="line" id="L9">    buffered_writer: BufferedWriter,</span>
<span class="line" id="L10">    allocator: mem.Allocator,</span>
<span class="line" id="L11"></span>
<span class="line" id="L12">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> buffer_size = <span class="tok-number">4096</span>;</span>
<span class="line" id="L13">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> BufferedWriter = std.io.BufferedWriter(buffer_size, File.Writer);</span>
<span class="line" id="L14">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> Writer = std.io.Writer(*BufferedWriter, BufferedWriter.Error, BufferedWriter.write);</span>
<span class="line" id="L15"></span>
<span class="line" id="L16">    <span class="tok-comment">/// TODO when https://github.com/ziglang/zig/issues/2761 is solved</span></span>
<span class="line" id="L17">    <span class="tok-comment">/// this API will not need an allocator</span></span>
<span class="line" id="L18">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">create</span>(</span>
<span class="line" id="L19">        allocator: mem.Allocator,</span>
<span class="line" id="L20">        dir: fs.Dir,</span>
<span class="line" id="L21">        dest_path: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L22">        atomic_file_options: fs.Dir.AtomicFileOptions,</span>
<span class="line" id="L23">    ) !*BufferedAtomicFile {</span>
<span class="line" id="L24">        <span class="tok-kw">var</span> self = <span class="tok-kw">try</span> allocator.create(BufferedAtomicFile);</span>
<span class="line" id="L25">        self.* = BufferedAtomicFile{</span>
<span class="line" id="L26">            .atomic_file = <span class="tok-null">undefined</span>,</span>
<span class="line" id="L27">            .file_writer = <span class="tok-null">undefined</span>,</span>
<span class="line" id="L28">            .buffered_writer = <span class="tok-null">undefined</span>,</span>
<span class="line" id="L29">            .allocator = allocator,</span>
<span class="line" id="L30">        };</span>
<span class="line" id="L31">        <span class="tok-kw">errdefer</span> allocator.destroy(self);</span>
<span class="line" id="L32"></span>
<span class="line" id="L33">        self.atomic_file = <span class="tok-kw">try</span> dir.atomicFile(dest_path, atomic_file_options);</span>
<span class="line" id="L34">        <span class="tok-kw">errdefer</span> self.atomic_file.deinit();</span>
<span class="line" id="L35"></span>
<span class="line" id="L36">        self.file_writer = self.atomic_file.file.writer();</span>
<span class="line" id="L37">        self.buffered_writer = .{ .unbuffered_writer = self.file_writer };</span>
<span class="line" id="L38">        <span class="tok-kw">return</span> self;</span>
<span class="line" id="L39">    }</span>
<span class="line" id="L40"></span>
<span class="line" id="L41">    <span class="tok-comment">/// always call destroy, even after successful finish()</span></span>
<span class="line" id="L42">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">destroy</span>(self: *BufferedAtomicFile) <span class="tok-type">void</span> {</span>
<span class="line" id="L43">        self.atomic_file.deinit();</span>
<span class="line" id="L44">        self.allocator.destroy(self);</span>
<span class="line" id="L45">    }</span>
<span class="line" id="L46"></span>
<span class="line" id="L47">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">finish</span>(self: *BufferedAtomicFile) !<span class="tok-type">void</span> {</span>
<span class="line" id="L48">        <span class="tok-kw">try</span> self.buffered_writer.flush();</span>
<span class="line" id="L49">        <span class="tok-kw">try</span> self.atomic_file.finish();</span>
<span class="line" id="L50">    }</span>
<span class="line" id="L51"></span>
<span class="line" id="L52">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">writer</span>(self: *BufferedAtomicFile) Writer {</span>
<span class="line" id="L53">        <span class="tok-kw">return</span> .{ .context = &amp;self.buffered_writer };</span>
<span class="line" id="L54">    }</span>
<span class="line" id="L55">};</span>
<span class="line" id="L56"></span>
</code></pre></body>
</html>