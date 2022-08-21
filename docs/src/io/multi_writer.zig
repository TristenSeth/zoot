<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">    <title>io/multi_writer.zig - source view</title>
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
<span class="line" id="L3"><span class="tok-kw">const</span> testing = std.testing;</span>
<span class="line" id="L4"></span>
<span class="line" id="L5"><span class="tok-comment">/// Takes a tuple of streams, and constructs a new stream that writes to all of them</span></span>
<span class="line" id="L6"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">MultiWriter</span>(<span class="tok-kw">comptime</span> Writers: <span class="tok-type">type</span>) <span class="tok-type">type</span> {</span>
<span class="line" id="L7">    <span class="tok-kw">comptime</span> <span class="tok-kw">var</span> ErrSet = <span class="tok-kw">error</span>{};</span>
<span class="line" id="L8">    <span class="tok-kw">inline</span> <span class="tok-kw">for</span> (<span class="tok-builtin">@typeInfo</span>(Writers).Struct.fields) |field| {</span>
<span class="line" id="L9">        <span class="tok-kw">const</span> StreamType = field.field_type;</span>
<span class="line" id="L10">        ErrSet = ErrSet || StreamType.Error;</span>
<span class="line" id="L11">    }</span>
<span class="line" id="L12"></span>
<span class="line" id="L13">    <span class="tok-kw">return</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L14">        <span class="tok-kw">const</span> Self = <span class="tok-builtin">@This</span>();</span>
<span class="line" id="L15"></span>
<span class="line" id="L16">        streams: Writers,</span>
<span class="line" id="L17"></span>
<span class="line" id="L18">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> Error = ErrSet;</span>
<span class="line" id="L19">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> Writer = io.Writer(*Self, Error, write);</span>
<span class="line" id="L20"></span>
<span class="line" id="L21">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">writer</span>(self: *Self) Writer {</span>
<span class="line" id="L22">            <span class="tok-kw">return</span> .{ .context = self };</span>
<span class="line" id="L23">        }</span>
<span class="line" id="L24"></span>
<span class="line" id="L25">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">write</span>(self: *Self, bytes: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) Error!<span class="tok-type">usize</span> {</span>
<span class="line" id="L26">            <span class="tok-kw">var</span> batch = std.event.Batch(Error!<span class="tok-type">void</span>, self.streams.len, .auto_async).init();</span>
<span class="line" id="L27">            <span class="tok-kw">comptime</span> <span class="tok-kw">var</span> i = <span class="tok-number">0</span>;</span>
<span class="line" id="L28">            <span class="tok-kw">inline</span> <span class="tok-kw">while</span> (i &lt; self.streams.len) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L29">                <span class="tok-kw">const</span> stream = self.streams[i];</span>
<span class="line" id="L30">                <span class="tok-comment">// TODO: remove ptrCast: https://github.com/ziglang/zig/issues/5258</span>
</span>
<span class="line" id="L31">                batch.add(<span class="tok-builtin">@ptrCast</span>(<span class="tok-kw">anyframe</span>-&gt;Error!<span class="tok-type">void</span>, &amp;<span class="tok-kw">async</span> stream.writeAll(bytes)));</span>
<span class="line" id="L32">            }</span>
<span class="line" id="L33">            <span class="tok-kw">try</span> batch.wait();</span>
<span class="line" id="L34">            <span class="tok-kw">return</span> bytes.len;</span>
<span class="line" id="L35">        }</span>
<span class="line" id="L36">    };</span>
<span class="line" id="L37">}</span>
<span class="line" id="L38"></span>
<span class="line" id="L39"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">multiWriter</span>(streams: <span class="tok-kw">anytype</span>) MultiWriter(<span class="tok-builtin">@TypeOf</span>(streams)) {</span>
<span class="line" id="L40">    <span class="tok-kw">return</span> .{ .streams = streams };</span>
<span class="line" id="L41">}</span>
<span class="line" id="L42"></span>
<span class="line" id="L43"><span class="tok-kw">test</span> <span class="tok-str">&quot;MultiWriter&quot;</span> {</span>
<span class="line" id="L44">    <span class="tok-kw">var</span> buf1: [<span class="tok-number">255</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L45">    <span class="tok-kw">var</span> fbs1 = io.fixedBufferStream(&amp;buf1);</span>
<span class="line" id="L46">    <span class="tok-kw">var</span> buf2: [<span class="tok-number">255</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L47">    <span class="tok-kw">var</span> fbs2 = io.fixedBufferStream(&amp;buf2);</span>
<span class="line" id="L48">    <span class="tok-kw">var</span> stream = multiWriter(.{ fbs1.writer(), fbs2.writer() });</span>
<span class="line" id="L49">    <span class="tok-kw">try</span> stream.writer().print(<span class="tok-str">&quot;HI&quot;</span>, .{});</span>
<span class="line" id="L50">    <span class="tok-kw">try</span> testing.expectEqualSlices(<span class="tok-type">u8</span>, <span class="tok-str">&quot;HI&quot;</span>, fbs1.getWritten());</span>
<span class="line" id="L51">    <span class="tok-kw">try</span> testing.expectEqualSlices(<span class="tok-type">u8</span>, <span class="tok-str">&quot;HI&quot;</span>, fbs2.getWritten());</span>
<span class="line" id="L52">}</span>
<span class="line" id="L53"></span>
</code></pre></body>
</html>