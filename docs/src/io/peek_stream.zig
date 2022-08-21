<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">    <title>io/peek_stream.zig - source view</title>
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
<span class="line" id="L4"><span class="tok-kw">const</span> testing = std.testing;</span>
<span class="line" id="L5"></span>
<span class="line" id="L6"><span class="tok-comment">/// Creates a stream which supports 'un-reading' data, so that it can be read again.</span></span>
<span class="line" id="L7"><span class="tok-comment">/// This makes look-ahead style parsing much easier.</span></span>
<span class="line" id="L8"><span class="tok-comment">/// TODO merge this with `std.io.BufferedReader`: https://github.com/ziglang/zig/issues/4501</span></span>
<span class="line" id="L9"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">PeekStream</span>(</span>
<span class="line" id="L10">    <span class="tok-kw">comptime</span> buffer_type: std.fifo.LinearFifoBufferType,</span>
<span class="line" id="L11">    <span class="tok-kw">comptime</span> ReaderType: <span class="tok-type">type</span>,</span>
<span class="line" id="L12">) <span class="tok-type">type</span> {</span>
<span class="line" id="L13">    <span class="tok-kw">return</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L14">        unbuffered_reader: ReaderType,</span>
<span class="line" id="L15">        fifo: FifoType,</span>
<span class="line" id="L16"></span>
<span class="line" id="L17">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> Error = ReaderType.Error;</span>
<span class="line" id="L18">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> Reader = io.Reader(*Self, Error, read);</span>
<span class="line" id="L19"></span>
<span class="line" id="L20">        <span class="tok-kw">const</span> Self = <span class="tok-builtin">@This</span>();</span>
<span class="line" id="L21">        <span class="tok-kw">const</span> FifoType = std.fifo.LinearFifo(<span class="tok-type">u8</span>, buffer_type);</span>
<span class="line" id="L22"></span>
<span class="line" id="L23">        <span class="tok-kw">pub</span> <span class="tok-kw">usingnamespace</span> <span class="tok-kw">switch</span> (buffer_type) {</span>
<span class="line" id="L24">            .Static =&gt; <span class="tok-kw">struct</span> {</span>
<span class="line" id="L25">                <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">init</span>(base: ReaderType) Self {</span>
<span class="line" id="L26">                    <span class="tok-kw">return</span> .{</span>
<span class="line" id="L27">                        .unbuffered_reader = base,</span>
<span class="line" id="L28">                        .fifo = FifoType.init(),</span>
<span class="line" id="L29">                    };</span>
<span class="line" id="L30">                }</span>
<span class="line" id="L31">            },</span>
<span class="line" id="L32">            .Slice =&gt; <span class="tok-kw">struct</span> {</span>
<span class="line" id="L33">                <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">init</span>(base: ReaderType, buf: []<span class="tok-type">u8</span>) Self {</span>
<span class="line" id="L34">                    <span class="tok-kw">return</span> .{</span>
<span class="line" id="L35">                        .unbuffered_reader = base,</span>
<span class="line" id="L36">                        .fifo = FifoType.init(buf),</span>
<span class="line" id="L37">                    };</span>
<span class="line" id="L38">                }</span>
<span class="line" id="L39">            },</span>
<span class="line" id="L40">            .Dynamic =&gt; <span class="tok-kw">struct</span> {</span>
<span class="line" id="L41">                <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">init</span>(base: ReaderType, allocator: mem.Allocator) Self {</span>
<span class="line" id="L42">                    <span class="tok-kw">return</span> .{</span>
<span class="line" id="L43">                        .unbuffered_reader = base,</span>
<span class="line" id="L44">                        .fifo = FifoType.init(allocator),</span>
<span class="line" id="L45">                    };</span>
<span class="line" id="L46">                }</span>
<span class="line" id="L47">            },</span>
<span class="line" id="L48">        };</span>
<span class="line" id="L49"></span>
<span class="line" id="L50">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">putBackByte</span>(self: *Self, byte: <span class="tok-type">u8</span>) !<span class="tok-type">void</span> {</span>
<span class="line" id="L51">            <span class="tok-kw">try</span> self.putBack(&amp;[_]<span class="tok-type">u8</span>{byte});</span>
<span class="line" id="L52">        }</span>
<span class="line" id="L53"></span>
<span class="line" id="L54">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">putBack</span>(self: *Self, bytes: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) !<span class="tok-type">void</span> {</span>
<span class="line" id="L55">            <span class="tok-kw">try</span> self.fifo.unget(bytes);</span>
<span class="line" id="L56">        }</span>
<span class="line" id="L57"></span>
<span class="line" id="L58">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">read</span>(self: *Self, dest: []<span class="tok-type">u8</span>) Error!<span class="tok-type">usize</span> {</span>
<span class="line" id="L59">            <span class="tok-comment">// copy over anything putBack()'d</span>
</span>
<span class="line" id="L60">            <span class="tok-kw">var</span> dest_index = self.fifo.read(dest);</span>
<span class="line" id="L61">            <span class="tok-kw">if</span> (dest_index == dest.len) <span class="tok-kw">return</span> dest_index;</span>
<span class="line" id="L62"></span>
<span class="line" id="L63">            <span class="tok-comment">// ask the backing stream for more</span>
</span>
<span class="line" id="L64">            dest_index += <span class="tok-kw">try</span> self.unbuffered_reader.read(dest[dest_index..]);</span>
<span class="line" id="L65">            <span class="tok-kw">return</span> dest_index;</span>
<span class="line" id="L66">        }</span>
<span class="line" id="L67"></span>
<span class="line" id="L68">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">reader</span>(self: *Self) Reader {</span>
<span class="line" id="L69">            <span class="tok-kw">return</span> .{ .context = self };</span>
<span class="line" id="L70">        }</span>
<span class="line" id="L71">    };</span>
<span class="line" id="L72">}</span>
<span class="line" id="L73"></span>
<span class="line" id="L74"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">peekStream</span>(</span>
<span class="line" id="L75">    <span class="tok-kw">comptime</span> lookahead: <span class="tok-type">comptime_int</span>,</span>
<span class="line" id="L76">    underlying_stream: <span class="tok-kw">anytype</span>,</span>
<span class="line" id="L77">) PeekStream(.{ .Static = lookahead }, <span class="tok-builtin">@TypeOf</span>(underlying_stream)) {</span>
<span class="line" id="L78">    <span class="tok-kw">return</span> PeekStream(.{ .Static = lookahead }, <span class="tok-builtin">@TypeOf</span>(underlying_stream)).init(underlying_stream);</span>
<span class="line" id="L79">}</span>
<span class="line" id="L80"></span>
<span class="line" id="L81"><span class="tok-kw">test</span> <span class="tok-str">&quot;PeekStream&quot;</span> {</span>
<span class="line" id="L82">    <span class="tok-kw">const</span> bytes = [_]<span class="tok-type">u8</span>{ <span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">4</span>, <span class="tok-number">5</span>, <span class="tok-number">6</span>, <span class="tok-number">7</span>, <span class="tok-number">8</span> };</span>
<span class="line" id="L83">    <span class="tok-kw">var</span> fbs = io.fixedBufferStream(&amp;bytes);</span>
<span class="line" id="L84">    <span class="tok-kw">var</span> ps = peekStream(<span class="tok-number">2</span>, fbs.reader());</span>
<span class="line" id="L85"></span>
<span class="line" id="L86">    <span class="tok-kw">var</span> dest: [<span class="tok-number">4</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L87"></span>
<span class="line" id="L88">    <span class="tok-kw">try</span> ps.putBackByte(<span class="tok-number">9</span>);</span>
<span class="line" id="L89">    <span class="tok-kw">try</span> ps.putBackByte(<span class="tok-number">10</span>);</span>
<span class="line" id="L90"></span>
<span class="line" id="L91">    <span class="tok-kw">var</span> read = <span class="tok-kw">try</span> ps.reader().read(dest[<span class="tok-number">0</span>..<span class="tok-number">4</span>]);</span>
<span class="line" id="L92">    <span class="tok-kw">try</span> testing.expect(read == <span class="tok-number">4</span>);</span>
<span class="line" id="L93">    <span class="tok-kw">try</span> testing.expect(dest[<span class="tok-number">0</span>] == <span class="tok-number">10</span>);</span>
<span class="line" id="L94">    <span class="tok-kw">try</span> testing.expect(dest[<span class="tok-number">1</span>] == <span class="tok-number">9</span>);</span>
<span class="line" id="L95">    <span class="tok-kw">try</span> testing.expect(mem.eql(<span class="tok-type">u8</span>, dest[<span class="tok-number">2</span>..<span class="tok-number">4</span>], bytes[<span class="tok-number">0</span>..<span class="tok-number">2</span>]));</span>
<span class="line" id="L96"></span>
<span class="line" id="L97">    read = <span class="tok-kw">try</span> ps.reader().read(dest[<span class="tok-number">0</span>..<span class="tok-number">4</span>]);</span>
<span class="line" id="L98">    <span class="tok-kw">try</span> testing.expect(read == <span class="tok-number">4</span>);</span>
<span class="line" id="L99">    <span class="tok-kw">try</span> testing.expect(mem.eql(<span class="tok-type">u8</span>, dest[<span class="tok-number">0</span>..<span class="tok-number">4</span>], bytes[<span class="tok-number">2</span>..<span class="tok-number">6</span>]));</span>
<span class="line" id="L100"></span>
<span class="line" id="L101">    read = <span class="tok-kw">try</span> ps.reader().read(dest[<span class="tok-number">0</span>..<span class="tok-number">4</span>]);</span>
<span class="line" id="L102">    <span class="tok-kw">try</span> testing.expect(read == <span class="tok-number">2</span>);</span>
<span class="line" id="L103">    <span class="tok-kw">try</span> testing.expect(mem.eql(<span class="tok-type">u8</span>, dest[<span class="tok-number">0</span>..<span class="tok-number">2</span>], bytes[<span class="tok-number">6</span>..<span class="tok-number">8</span>]));</span>
<span class="line" id="L104"></span>
<span class="line" id="L105">    <span class="tok-kw">try</span> ps.putBackByte(<span class="tok-number">11</span>);</span>
<span class="line" id="L106">    <span class="tok-kw">try</span> ps.putBackByte(<span class="tok-number">12</span>);</span>
<span class="line" id="L107"></span>
<span class="line" id="L108">    read = <span class="tok-kw">try</span> ps.reader().read(dest[<span class="tok-number">0</span>..<span class="tok-number">4</span>]);</span>
<span class="line" id="L109">    <span class="tok-kw">try</span> testing.expect(read == <span class="tok-number">2</span>);</span>
<span class="line" id="L110">    <span class="tok-kw">try</span> testing.expect(dest[<span class="tok-number">0</span>] == <span class="tok-number">12</span>);</span>
<span class="line" id="L111">    <span class="tok-kw">try</span> testing.expect(dest[<span class="tok-number">1</span>] == <span class="tok-number">11</span>);</span>
<span class="line" id="L112">}</span>
<span class="line" id="L113"></span>
</code></pre></body>
</html>