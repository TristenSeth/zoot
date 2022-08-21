<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">    <title>io/limited_reader.zig - source view</title>
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
<span class="line" id="L3"><span class="tok-kw">const</span> assert = std.debug.assert;</span>
<span class="line" id="L4"><span class="tok-kw">const</span> testing = std.testing;</span>
<span class="line" id="L5"></span>
<span class="line" id="L6"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">LimitedReader</span>(<span class="tok-kw">comptime</span> ReaderType: <span class="tok-type">type</span>) <span class="tok-type">type</span> {</span>
<span class="line" id="L7">    <span class="tok-kw">return</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L8">        inner_reader: ReaderType,</span>
<span class="line" id="L9">        bytes_left: <span class="tok-type">u64</span>,</span>
<span class="line" id="L10"></span>
<span class="line" id="L11">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> Error = ReaderType.Error;</span>
<span class="line" id="L12">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> Reader = io.Reader(*Self, Error, read);</span>
<span class="line" id="L13"></span>
<span class="line" id="L14">        <span class="tok-kw">const</span> Self = <span class="tok-builtin">@This</span>();</span>
<span class="line" id="L15"></span>
<span class="line" id="L16">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">read</span>(self: *Self, dest: []<span class="tok-type">u8</span>) Error!<span class="tok-type">usize</span> {</span>
<span class="line" id="L17">            <span class="tok-kw">const</span> max_read = std.math.min(self.bytes_left, dest.len);</span>
<span class="line" id="L18">            <span class="tok-kw">const</span> n = <span class="tok-kw">try</span> self.inner_reader.read(dest[<span class="tok-number">0</span>..max_read]);</span>
<span class="line" id="L19">            self.bytes_left -= n;</span>
<span class="line" id="L20">            <span class="tok-kw">return</span> n;</span>
<span class="line" id="L21">        }</span>
<span class="line" id="L22"></span>
<span class="line" id="L23">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">reader</span>(self: *Self) Reader {</span>
<span class="line" id="L24">            <span class="tok-kw">return</span> .{ .context = self };</span>
<span class="line" id="L25">        }</span>
<span class="line" id="L26">    };</span>
<span class="line" id="L27">}</span>
<span class="line" id="L28"></span>
<span class="line" id="L29"><span class="tok-comment">/// Returns an initialised `LimitedReader`</span></span>
<span class="line" id="L30"><span class="tok-comment">/// `bytes_left` is a `u64` to be able to take 64 bit file offsets</span></span>
<span class="line" id="L31"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">limitedReader</span>(inner_reader: <span class="tok-kw">anytype</span>, bytes_left: <span class="tok-type">u64</span>) LimitedReader(<span class="tok-builtin">@TypeOf</span>(inner_reader)) {</span>
<span class="line" id="L32">    <span class="tok-kw">return</span> .{ .inner_reader = inner_reader, .bytes_left = bytes_left };</span>
<span class="line" id="L33">}</span>
<span class="line" id="L34"></span>
<span class="line" id="L35"><span class="tok-kw">test</span> <span class="tok-str">&quot;basic usage&quot;</span> {</span>
<span class="line" id="L36">    <span class="tok-kw">const</span> data = <span class="tok-str">&quot;hello world&quot;</span>;</span>
<span class="line" id="L37">    <span class="tok-kw">var</span> fbs = std.io.fixedBufferStream(data);</span>
<span class="line" id="L38">    <span class="tok-kw">var</span> early_stream = limitedReader(fbs.reader(), <span class="tok-number">3</span>);</span>
<span class="line" id="L39"></span>
<span class="line" id="L40">    <span class="tok-kw">var</span> buf: [<span class="tok-number">5</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L41">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">usize</span>, <span class="tok-number">3</span>), <span class="tok-kw">try</span> early_stream.reader().read(&amp;buf));</span>
<span class="line" id="L42">    <span class="tok-kw">try</span> testing.expectEqualSlices(<span class="tok-type">u8</span>, data[<span class="tok-number">0</span>..<span class="tok-number">3</span>], buf[<span class="tok-number">0</span>..<span class="tok-number">3</span>]);</span>
<span class="line" id="L43">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">usize</span>, <span class="tok-number">0</span>), <span class="tok-kw">try</span> early_stream.reader().read(&amp;buf));</span>
<span class="line" id="L44">    <span class="tok-kw">try</span> testing.expectError(<span class="tok-kw">error</span>.EndOfStream, early_stream.reader().skipBytes(<span class="tok-number">10</span>, .{}));</span>
<span class="line" id="L45">}</span>
<span class="line" id="L46"></span>
</code></pre></body>
</html>