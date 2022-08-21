<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">    <title>io/c_writer.zig - source view</title>
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
<span class="line" id="L2"><span class="tok-kw">const</span> builtin = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;builtin&quot;</span>);</span>
<span class="line" id="L3"><span class="tok-kw">const</span> io = std.io;</span>
<span class="line" id="L4"><span class="tok-kw">const</span> testing = std.testing;</span>
<span class="line" id="L5"><span class="tok-kw">const</span> os = std.os;</span>
<span class="line" id="L6"></span>
<span class="line" id="L7"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> CWriter = io.Writer(*std.c.FILE, std.fs.File.WriteError, cWriterWrite);</span>
<span class="line" id="L8"></span>
<span class="line" id="L9"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">cWriter</span>(c_file: *std.c.FILE) CWriter {</span>
<span class="line" id="L10">    <span class="tok-kw">return</span> .{ .context = c_file };</span>
<span class="line" id="L11">}</span>
<span class="line" id="L12"></span>
<span class="line" id="L13"><span class="tok-kw">fn</span> <span class="tok-fn">cWriterWrite</span>(c_file: *std.c.FILE, bytes: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) std.fs.File.WriteError!<span class="tok-type">usize</span> {</span>
<span class="line" id="L14">    <span class="tok-kw">const</span> amt_written = std.c.fwrite(bytes.ptr, <span class="tok-number">1</span>, bytes.len, c_file);</span>
<span class="line" id="L15">    <span class="tok-kw">if</span> (amt_written &gt;= <span class="tok-number">0</span>) <span class="tok-kw">return</span> amt_written;</span>
<span class="line" id="L16">    <span class="tok-kw">switch</span> (<span class="tok-builtin">@intToEnum</span>(os.E, std.c._errno().*)) {</span>
<span class="line" id="L17">        .SUCCESS =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L18">        .INVAL =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L19">        .FAULT =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L20">        .AGAIN =&gt; <span class="tok-kw">unreachable</span>, <span class="tok-comment">// this is a blocking API</span>
</span>
<span class="line" id="L21">        .BADF =&gt; <span class="tok-kw">unreachable</span>, <span class="tok-comment">// always a race condition</span>
</span>
<span class="line" id="L22">        .DESTADDRREQ =&gt; <span class="tok-kw">unreachable</span>, <span class="tok-comment">// connect was never called</span>
</span>
<span class="line" id="L23">        .DQUOT =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.DiskQuota,</span>
<span class="line" id="L24">        .FBIG =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.FileTooBig,</span>
<span class="line" id="L25">        .IO =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InputOutput,</span>
<span class="line" id="L26">        .NOSPC =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.NoSpaceLeft,</span>
<span class="line" id="L27">        .PERM =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.AccessDenied,</span>
<span class="line" id="L28">        .PIPE =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.BrokenPipe,</span>
<span class="line" id="L29">        <span class="tok-kw">else</span> =&gt; |err| <span class="tok-kw">return</span> os.unexpectedErrno(err),</span>
<span class="line" id="L30">    }</span>
<span class="line" id="L31">}</span>
<span class="line" id="L32"></span>
<span class="line" id="L33"><span class="tok-kw">test</span> <span class="tok-str">&quot;C Writer&quot;</span> {</span>
<span class="line" id="L34">    <span class="tok-kw">if</span> (!builtin.link_libc <span class="tok-kw">or</span> builtin.os.tag == .wasi) <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SkipZigTest;</span>
<span class="line" id="L35"></span>
<span class="line" id="L36">    <span class="tok-kw">const</span> filename = <span class="tok-str">&quot;tmp_io_test_file.txt&quot;</span>;</span>
<span class="line" id="L37">    <span class="tok-kw">const</span> out_file = std.c.fopen(filename, <span class="tok-str">&quot;w&quot;</span>) <span class="tok-kw">orelse</span> <span class="tok-kw">return</span> <span class="tok-kw">error</span>.UnableToOpenTestFile;</span>
<span class="line" id="L38">    <span class="tok-kw">defer</span> {</span>
<span class="line" id="L39">        _ = std.c.fclose(out_file);</span>
<span class="line" id="L40">        std.fs.cwd().deleteFileZ(filename) <span class="tok-kw">catch</span> {};</span>
<span class="line" id="L41">    }</span>
<span class="line" id="L42"></span>
<span class="line" id="L43">    <span class="tok-kw">const</span> writer = cWriter(out_file);</span>
<span class="line" id="L44">    <span class="tok-kw">try</span> writer.print(<span class="tok-str">&quot;hi: {}\n&quot;</span>, .{<span class="tok-builtin">@as</span>(<span class="tok-type">i32</span>, <span class="tok-number">123</span>)});</span>
<span class="line" id="L45">}</span>
<span class="line" id="L46"></span>
</code></pre></body>
</html>