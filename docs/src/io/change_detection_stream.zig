<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">    <title>io/change_detection_stream.zig - source view</title>
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
<span class="line" id="L2"><span class="tok-kw">const</span> io = std.io;</span>
<span class="line" id="L3"><span class="tok-kw">const</span> mem = std.mem;</span>
<span class="line" id="L4"><span class="tok-kw">const</span> assert = std.debug.assert;</span>
<span class="line" id="L5"></span>
<span class="line" id="L6"><span class="tok-comment">/// Used to detect if the data written to a stream differs from a source buffer</span></span>
<span class="line" id="L7"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">ChangeDetectionStream</span>(<span class="tok-kw">comptime</span> WriterType: <span class="tok-type">type</span>) <span class="tok-type">type</span> {</span>
<span class="line" id="L8">    <span class="tok-kw">return</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L9">        <span class="tok-kw">const</span> Self = <span class="tok-builtin">@This</span>();</span>
<span class="line" id="L10">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> Error = WriterType.Error;</span>
<span class="line" id="L11">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> Writer = io.Writer(*Self, Error, write);</span>
<span class="line" id="L12"></span>
<span class="line" id="L13">        anything_changed: <span class="tok-type">bool</span>,</span>
<span class="line" id="L14">        underlying_writer: WriterType,</span>
<span class="line" id="L15">        source_index: <span class="tok-type">usize</span>,</span>
<span class="line" id="L16">        source: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L17"></span>
<span class="line" id="L18">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">writer</span>(self: *Self) Writer {</span>
<span class="line" id="L19">            <span class="tok-kw">return</span> .{ .context = self };</span>
<span class="line" id="L20">        }</span>
<span class="line" id="L21"></span>
<span class="line" id="L22">        <span class="tok-kw">fn</span> <span class="tok-fn">write</span>(self: *Self, bytes: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) Error!<span class="tok-type">usize</span> {</span>
<span class="line" id="L23">            <span class="tok-kw">if</span> (!self.anything_changed) {</span>
<span class="line" id="L24">                <span class="tok-kw">const</span> end = self.source_index + bytes.len;</span>
<span class="line" id="L25">                <span class="tok-kw">if</span> (end &gt; self.source.len) {</span>
<span class="line" id="L26">                    self.anything_changed = <span class="tok-null">true</span>;</span>
<span class="line" id="L27">                } <span class="tok-kw">else</span> {</span>
<span class="line" id="L28">                    <span class="tok-kw">const</span> src_slice = self.source[self.source_index..end];</span>
<span class="line" id="L29">                    self.source_index += bytes.len;</span>
<span class="line" id="L30">                    <span class="tok-kw">if</span> (!mem.eql(<span class="tok-type">u8</span>, bytes, src_slice)) {</span>
<span class="line" id="L31">                        self.anything_changed = <span class="tok-null">true</span>;</span>
<span class="line" id="L32">                    }</span>
<span class="line" id="L33">                }</span>
<span class="line" id="L34">            }</span>
<span class="line" id="L35"></span>
<span class="line" id="L36">            <span class="tok-kw">return</span> self.underlying_writer.write(bytes);</span>
<span class="line" id="L37">        }</span>
<span class="line" id="L38"></span>
<span class="line" id="L39">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">changeDetected</span>(self: *Self) <span class="tok-type">bool</span> {</span>
<span class="line" id="L40">            <span class="tok-kw">return</span> self.anything_changed <span class="tok-kw">or</span> (self.source_index != self.source.len);</span>
<span class="line" id="L41">        }</span>
<span class="line" id="L42">    };</span>
<span class="line" id="L43">}</span>
<span class="line" id="L44"></span>
<span class="line" id="L45"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">changeDetectionStream</span>(</span>
<span class="line" id="L46">    source: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L47">    underlying_writer: <span class="tok-kw">anytype</span>,</span>
<span class="line" id="L48">) ChangeDetectionStream(<span class="tok-builtin">@TypeOf</span>(underlying_writer)) {</span>
<span class="line" id="L49">    <span class="tok-kw">return</span> ChangeDetectionStream(<span class="tok-builtin">@TypeOf</span>(underlying_writer)){</span>
<span class="line" id="L50">        .anything_changed = <span class="tok-null">false</span>,</span>
<span class="line" id="L51">        .underlying_writer = underlying_writer,</span>
<span class="line" id="L52">        .source_index = <span class="tok-number">0</span>,</span>
<span class="line" id="L53">        .source = source,</span>
<span class="line" id="L54">    };</span>
<span class="line" id="L55">}</span>
<span class="line" id="L56"></span>
</code></pre></body>
</html>