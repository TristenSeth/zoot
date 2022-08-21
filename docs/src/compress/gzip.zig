<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">    <title>compress/gzip.zig - source view</title>
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
<pre><code><span class="line" id="L1"><span class="tok-comment">//</span>
</span>
<span class="line" id="L2"><span class="tok-comment">// Decompressor for GZIP data streams (RFC1952)</span>
</span>
<span class="line" id="L3"></span>
<span class="line" id="L4"><span class="tok-kw">const</span> std = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;std&quot;</span>);</span>
<span class="line" id="L5"><span class="tok-kw">const</span> io = std.io;</span>
<span class="line" id="L6"><span class="tok-kw">const</span> fs = std.fs;</span>
<span class="line" id="L7"><span class="tok-kw">const</span> testing = std.testing;</span>
<span class="line" id="L8"><span class="tok-kw">const</span> mem = std.mem;</span>
<span class="line" id="L9"><span class="tok-kw">const</span> deflate = std.compress.deflate;</span>
<span class="line" id="L10"></span>
<span class="line" id="L11"><span class="tok-comment">// Flags for the FLG field in the header</span>
</span>
<span class="line" id="L12"><span class="tok-kw">const</span> FTEXT = <span class="tok-number">1</span> &lt;&lt; <span class="tok-number">0</span>;</span>
<span class="line" id="L13"><span class="tok-kw">const</span> FHCRC = <span class="tok-number">1</span> &lt;&lt; <span class="tok-number">1</span>;</span>
<span class="line" id="L14"><span class="tok-kw">const</span> FEXTRA = <span class="tok-number">1</span> &lt;&lt; <span class="tok-number">2</span>;</span>
<span class="line" id="L15"><span class="tok-kw">const</span> FNAME = <span class="tok-number">1</span> &lt;&lt; <span class="tok-number">3</span>;</span>
<span class="line" id="L16"><span class="tok-kw">const</span> FCOMMENT = <span class="tok-number">1</span> &lt;&lt; <span class="tok-number">4</span>;</span>
<span class="line" id="L17"></span>
<span class="line" id="L18"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">GzipStream</span>(<span class="tok-kw">comptime</span> ReaderType: <span class="tok-type">type</span>) <span class="tok-type">type</span> {</span>
<span class="line" id="L19">    <span class="tok-kw">return</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L20">        <span class="tok-kw">const</span> Self = <span class="tok-builtin">@This</span>();</span>
<span class="line" id="L21"></span>
<span class="line" id="L22">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> Error = ReaderType.Error ||</span>
<span class="line" id="L23">            deflate.Decompressor(ReaderType).Error ||</span>
<span class="line" id="L24">            <span class="tok-kw">error</span>{ CorruptedData, WrongChecksum };</span>
<span class="line" id="L25">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> Reader = io.Reader(*Self, Error, read);</span>
<span class="line" id="L26"></span>
<span class="line" id="L27">        allocator: mem.Allocator,</span>
<span class="line" id="L28">        inflater: deflate.Decompressor(ReaderType),</span>
<span class="line" id="L29">        in_reader: ReaderType,</span>
<span class="line" id="L30">        hasher: std.hash.Crc32,</span>
<span class="line" id="L31">        read_amt: <span class="tok-type">usize</span>,</span>
<span class="line" id="L32"></span>
<span class="line" id="L33">        info: <span class="tok-kw">struct</span> {</span>
<span class="line" id="L34">            filename: ?[]<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L35">            comment: ?[]<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L36">            modification_time: <span class="tok-type">u32</span>,</span>
<span class="line" id="L37">        },</span>
<span class="line" id="L38"></span>
<span class="line" id="L39">        <span class="tok-kw">fn</span> <span class="tok-fn">init</span>(allocator: mem.Allocator, source: ReaderType) !Self {</span>
<span class="line" id="L40">            <span class="tok-comment">// gzip header format is specified in RFC1952</span>
</span>
<span class="line" id="L41">            <span class="tok-kw">const</span> header = <span class="tok-kw">try</span> source.readBytesNoEof(<span class="tok-number">10</span>);</span>
<span class="line" id="L42"></span>
<span class="line" id="L43">            <span class="tok-comment">// Check the ID1/ID2 fields</span>
</span>
<span class="line" id="L44">            <span class="tok-kw">if</span> (header[<span class="tok-number">0</span>] != <span class="tok-number">0x1f</span> <span class="tok-kw">or</span> header[<span class="tok-number">1</span>] != <span class="tok-number">0x8b</span>)</span>
<span class="line" id="L45">                <span class="tok-kw">return</span> <span class="tok-kw">error</span>.BadHeader;</span>
<span class="line" id="L46"></span>
<span class="line" id="L47">            <span class="tok-kw">const</span> CM = header[<span class="tok-number">2</span>];</span>
<span class="line" id="L48">            <span class="tok-comment">// The CM field must be 8 to indicate the use of DEFLATE</span>
</span>
<span class="line" id="L49">            <span class="tok-kw">if</span> (CM != <span class="tok-number">8</span>) <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InvalidCompression;</span>
<span class="line" id="L50">            <span class="tok-comment">// Flags</span>
</span>
<span class="line" id="L51">            <span class="tok-kw">const</span> FLG = header[<span class="tok-number">3</span>];</span>
<span class="line" id="L52">            <span class="tok-comment">// Modification time, as a Unix timestamp.</span>
</span>
<span class="line" id="L53">            <span class="tok-comment">// If zero there's no timestamp available.</span>
</span>
<span class="line" id="L54">            <span class="tok-kw">const</span> MTIME = mem.readIntLittle(<span class="tok-type">u32</span>, header[<span class="tok-number">4</span>..<span class="tok-number">8</span>]);</span>
<span class="line" id="L55">            <span class="tok-comment">// Extra flags</span>
</span>
<span class="line" id="L56">            <span class="tok-kw">const</span> XFL = header[<span class="tok-number">8</span>];</span>
<span class="line" id="L57">            <span class="tok-comment">// Operating system where the compression took place</span>
</span>
<span class="line" id="L58">            <span class="tok-kw">const</span> OS = header[<span class="tok-number">9</span>];</span>
<span class="line" id="L59">            _ = XFL;</span>
<span class="line" id="L60">            _ = OS;</span>
<span class="line" id="L61"></span>
<span class="line" id="L62">            <span class="tok-kw">if</span> (FLG &amp; FEXTRA != <span class="tok-number">0</span>) {</span>
<span class="line" id="L63">                <span class="tok-comment">// Skip the extra data, we could read and expose it to the user</span>
</span>
<span class="line" id="L64">                <span class="tok-comment">// if somebody needs it.</span>
</span>
<span class="line" id="L65">                <span class="tok-kw">const</span> len = <span class="tok-kw">try</span> source.readIntLittle(<span class="tok-type">u16</span>);</span>
<span class="line" id="L66">                <span class="tok-kw">try</span> source.skipBytes(len, .{});</span>
<span class="line" id="L67">            }</span>
<span class="line" id="L68"></span>
<span class="line" id="L69">            <span class="tok-kw">var</span> filename: ?[]<span class="tok-kw">const</span> <span class="tok-type">u8</span> = <span class="tok-null">null</span>;</span>
<span class="line" id="L70">            <span class="tok-kw">if</span> (FLG &amp; FNAME != <span class="tok-number">0</span>) {</span>
<span class="line" id="L71">                filename = <span class="tok-kw">try</span> source.readUntilDelimiterAlloc(</span>
<span class="line" id="L72">                    allocator,</span>
<span class="line" id="L73">                    <span class="tok-number">0</span>,</span>
<span class="line" id="L74">                    std.math.maxInt(<span class="tok-type">usize</span>),</span>
<span class="line" id="L75">                );</span>
<span class="line" id="L76">            }</span>
<span class="line" id="L77">            <span class="tok-kw">errdefer</span> <span class="tok-kw">if</span> (filename) |p| allocator.free(p);</span>
<span class="line" id="L78"></span>
<span class="line" id="L79">            <span class="tok-kw">var</span> comment: ?[]<span class="tok-kw">const</span> <span class="tok-type">u8</span> = <span class="tok-null">null</span>;</span>
<span class="line" id="L80">            <span class="tok-kw">if</span> (FLG &amp; FCOMMENT != <span class="tok-number">0</span>) {</span>
<span class="line" id="L81">                comment = <span class="tok-kw">try</span> source.readUntilDelimiterAlloc(</span>
<span class="line" id="L82">                    allocator,</span>
<span class="line" id="L83">                    <span class="tok-number">0</span>,</span>
<span class="line" id="L84">                    std.math.maxInt(<span class="tok-type">usize</span>),</span>
<span class="line" id="L85">                );</span>
<span class="line" id="L86">            }</span>
<span class="line" id="L87">            <span class="tok-kw">errdefer</span> <span class="tok-kw">if</span> (comment) |p| allocator.free(p);</span>
<span class="line" id="L88"></span>
<span class="line" id="L89">            <span class="tok-kw">if</span> (FLG &amp; FHCRC != <span class="tok-number">0</span>) {</span>
<span class="line" id="L90">                <span class="tok-comment">// TODO: Evaluate and check the header checksum. The stdlib has</span>
</span>
<span class="line" id="L91">                <span class="tok-comment">// no CRC16 yet :(</span>
</span>
<span class="line" id="L92">                _ = <span class="tok-kw">try</span> source.readIntLittle(<span class="tok-type">u16</span>);</span>
<span class="line" id="L93">            }</span>
<span class="line" id="L94"></span>
<span class="line" id="L95">            <span class="tok-kw">return</span> Self{</span>
<span class="line" id="L96">                .allocator = allocator,</span>
<span class="line" id="L97">                .inflater = <span class="tok-kw">try</span> deflate.decompressor(allocator, source, <span class="tok-null">null</span>),</span>
<span class="line" id="L98">                .in_reader = source,</span>
<span class="line" id="L99">                .hasher = std.hash.Crc32.init(),</span>
<span class="line" id="L100">                .info = .{</span>
<span class="line" id="L101">                    .filename = filename,</span>
<span class="line" id="L102">                    .comment = comment,</span>
<span class="line" id="L103">                    .modification_time = MTIME,</span>
<span class="line" id="L104">                },</span>
<span class="line" id="L105">                .read_amt = <span class="tok-number">0</span>,</span>
<span class="line" id="L106">            };</span>
<span class="line" id="L107">        }</span>
<span class="line" id="L108"></span>
<span class="line" id="L109">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">deinit</span>(self: *Self) <span class="tok-type">void</span> {</span>
<span class="line" id="L110">            self.inflater.deinit();</span>
<span class="line" id="L111">            <span class="tok-kw">if</span> (self.info.filename) |filename|</span>
<span class="line" id="L112">                self.allocator.free(filename);</span>
<span class="line" id="L113">            <span class="tok-kw">if</span> (self.info.comment) |comment|</span>
<span class="line" id="L114">                self.allocator.free(comment);</span>
<span class="line" id="L115">        }</span>
<span class="line" id="L116"></span>
<span class="line" id="L117">        <span class="tok-comment">// Implements the io.Reader interface</span>
</span>
<span class="line" id="L118">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">read</span>(self: *Self, buffer: []<span class="tok-type">u8</span>) Error!<span class="tok-type">usize</span> {</span>
<span class="line" id="L119">            <span class="tok-kw">if</span> (buffer.len == <span class="tok-number">0</span>)</span>
<span class="line" id="L120">                <span class="tok-kw">return</span> <span class="tok-number">0</span>;</span>
<span class="line" id="L121"></span>
<span class="line" id="L122">            <span class="tok-comment">// Read from the compressed stream and update the computed checksum</span>
</span>
<span class="line" id="L123">            <span class="tok-kw">const</span> r = <span class="tok-kw">try</span> self.inflater.read(buffer);</span>
<span class="line" id="L124">            <span class="tok-kw">if</span> (r != <span class="tok-number">0</span>) {</span>
<span class="line" id="L125">                self.hasher.update(buffer[<span class="tok-number">0</span>..r]);</span>
<span class="line" id="L126">                self.read_amt += r;</span>
<span class="line" id="L127">                <span class="tok-kw">return</span> r;</span>
<span class="line" id="L128">            }</span>
<span class="line" id="L129"></span>
<span class="line" id="L130">            <span class="tok-comment">// We've reached the end of stream, check if the checksum matches</span>
</span>
<span class="line" id="L131">            <span class="tok-kw">const</span> hash = <span class="tok-kw">try</span> self.in_reader.readIntLittle(<span class="tok-type">u32</span>);</span>
<span class="line" id="L132">            <span class="tok-kw">if</span> (hash != self.hasher.final())</span>
<span class="line" id="L133">                <span class="tok-kw">return</span> <span class="tok-kw">error</span>.WrongChecksum;</span>
<span class="line" id="L134"></span>
<span class="line" id="L135">            <span class="tok-comment">// The ISIZE field is the size of the uncompressed input modulo 2^32</span>
</span>
<span class="line" id="L136">            <span class="tok-kw">const</span> input_size = <span class="tok-kw">try</span> self.in_reader.readIntLittle(<span class="tok-type">u32</span>);</span>
<span class="line" id="L137">            <span class="tok-kw">if</span> (self.read_amt &amp; <span class="tok-number">0xffffffff</span> != input_size)</span>
<span class="line" id="L138">                <span class="tok-kw">return</span> <span class="tok-kw">error</span>.CorruptedData;</span>
<span class="line" id="L139"></span>
<span class="line" id="L140">            <span class="tok-kw">return</span> <span class="tok-number">0</span>;</span>
<span class="line" id="L141">        }</span>
<span class="line" id="L142"></span>
<span class="line" id="L143">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">reader</span>(self: *Self) Reader {</span>
<span class="line" id="L144">            <span class="tok-kw">return</span> .{ .context = self };</span>
<span class="line" id="L145">        }</span>
<span class="line" id="L146">    };</span>
<span class="line" id="L147">}</span>
<span class="line" id="L148"></span>
<span class="line" id="L149"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">gzipStream</span>(allocator: mem.Allocator, reader: <span class="tok-kw">anytype</span>) !GzipStream(<span class="tok-builtin">@TypeOf</span>(reader)) {</span>
<span class="line" id="L150">    <span class="tok-kw">return</span> GzipStream(<span class="tok-builtin">@TypeOf</span>(reader)).init(allocator, reader);</span>
<span class="line" id="L151">}</span>
<span class="line" id="L152"></span>
<span class="line" id="L153"><span class="tok-kw">fn</span> <span class="tok-fn">testReader</span>(data: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, <span class="tok-kw">comptime</span> expected: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) !<span class="tok-type">void</span> {</span>
<span class="line" id="L154">    <span class="tok-kw">var</span> in_stream = io.fixedBufferStream(data);</span>
<span class="line" id="L155"></span>
<span class="line" id="L156">    <span class="tok-kw">var</span> gzip_stream = <span class="tok-kw">try</span> gzipStream(testing.allocator, in_stream.reader());</span>
<span class="line" id="L157">    <span class="tok-kw">defer</span> gzip_stream.deinit();</span>
<span class="line" id="L158"></span>
<span class="line" id="L159">    <span class="tok-comment">// Read and decompress the whole file</span>
</span>
<span class="line" id="L160">    <span class="tok-kw">const</span> buf = <span class="tok-kw">try</span> gzip_stream.reader().readAllAlloc(testing.allocator, std.math.maxInt(<span class="tok-type">usize</span>));</span>
<span class="line" id="L161">    <span class="tok-kw">defer</span> testing.allocator.free(buf);</span>
<span class="line" id="L162"></span>
<span class="line" id="L163">    <span class="tok-comment">// Check against the reference</span>
</span>
<span class="line" id="L164">    <span class="tok-kw">try</span> testing.expectEqualSlices(<span class="tok-type">u8</span>, buf, expected);</span>
<span class="line" id="L165">}</span>
<span class="line" id="L166"></span>
<span class="line" id="L167"><span class="tok-comment">// All the test cases are obtained by compressing the RFC1952 text</span>
</span>
<span class="line" id="L168"><span class="tok-comment">//</span>
</span>
<span class="line" id="L169"><span class="tok-comment">// https://tools.ietf.org/rfc/rfc1952.txt length=25037 bytes</span>
</span>
<span class="line" id="L170"><span class="tok-comment">// SHA256=164ef0897b4cbec63abf1b57f069f3599bd0fb7c72c2a4dee21bd7e03ec9af67</span>
</span>
<span class="line" id="L171"><span class="tok-kw">test</span> <span class="tok-str">&quot;compressed data&quot;</span> {</span>
<span class="line" id="L172">    <span class="tok-kw">try</span> testReader(</span>
<span class="line" id="L173">        <span class="tok-builtin">@embedFile</span>(<span class="tok-str">&quot;rfc1952.txt.gz&quot;</span>),</span>
<span class="line" id="L174">        <span class="tok-builtin">@embedFile</span>(<span class="tok-str">&quot;rfc1952.txt&quot;</span>),</span>
<span class="line" id="L175">    );</span>
<span class="line" id="L176">}</span>
<span class="line" id="L177"></span>
<span class="line" id="L178"><span class="tok-kw">test</span> <span class="tok-str">&quot;sanity checks&quot;</span> {</span>
<span class="line" id="L179">    <span class="tok-comment">// Truncated header</span>
</span>
<span class="line" id="L180">    <span class="tok-kw">try</span> testing.expectError(</span>
<span class="line" id="L181">        <span class="tok-kw">error</span>.EndOfStream,</span>
<span class="line" id="L182">        testReader(&amp;[_]<span class="tok-type">u8</span>{ <span class="tok-number">0x1f</span>, <span class="tok-number">0x8B</span> }, <span class="tok-str">&quot;&quot;</span>),</span>
<span class="line" id="L183">    );</span>
<span class="line" id="L184">    <span class="tok-comment">// Wrong CM</span>
</span>
<span class="line" id="L185">    <span class="tok-kw">try</span> testing.expectError(</span>
<span class="line" id="L186">        <span class="tok-kw">error</span>.InvalidCompression,</span>
<span class="line" id="L187">        testReader(&amp;[_]<span class="tok-type">u8</span>{</span>
<span class="line" id="L188">            <span class="tok-number">0x1f</span>, <span class="tok-number">0x8b</span>, <span class="tok-number">0x09</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>,</span>
<span class="line" id="L189">            <span class="tok-number">0x00</span>, <span class="tok-number">0x03</span>,</span>
<span class="line" id="L190">        }, <span class="tok-str">&quot;&quot;</span>),</span>
<span class="line" id="L191">    );</span>
<span class="line" id="L192">    <span class="tok-comment">// Wrong checksum</span>
</span>
<span class="line" id="L193">    <span class="tok-kw">try</span> testing.expectError(</span>
<span class="line" id="L194">        <span class="tok-kw">error</span>.WrongChecksum,</span>
<span class="line" id="L195">        testReader(&amp;[_]<span class="tok-type">u8</span>{</span>
<span class="line" id="L196">            <span class="tok-number">0x1f</span>, <span class="tok-number">0x8b</span>, <span class="tok-number">0x08</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>,</span>
<span class="line" id="L197">            <span class="tok-number">0x00</span>, <span class="tok-number">0x03</span>, <span class="tok-number">0x03</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x01</span>,</span>
<span class="line" id="L198">            <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>,</span>
<span class="line" id="L199">        }, <span class="tok-str">&quot;&quot;</span>),</span>
<span class="line" id="L200">    );</span>
<span class="line" id="L201">    <span class="tok-comment">// Truncated checksum</span>
</span>
<span class="line" id="L202">    <span class="tok-kw">try</span> testing.expectError(</span>
<span class="line" id="L203">        <span class="tok-kw">error</span>.EndOfStream,</span>
<span class="line" id="L204">        testReader(&amp;[_]<span class="tok-type">u8</span>{</span>
<span class="line" id="L205">            <span class="tok-number">0x1f</span>, <span class="tok-number">0x8b</span>, <span class="tok-number">0x08</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>,</span>
<span class="line" id="L206">            <span class="tok-number">0x00</span>, <span class="tok-number">0x03</span>, <span class="tok-number">0x03</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>,</span>
<span class="line" id="L207">        }, <span class="tok-str">&quot;&quot;</span>),</span>
<span class="line" id="L208">    );</span>
<span class="line" id="L209">    <span class="tok-comment">// Wrong initial size</span>
</span>
<span class="line" id="L210">    <span class="tok-kw">try</span> testing.expectError(</span>
<span class="line" id="L211">        <span class="tok-kw">error</span>.CorruptedData,</span>
<span class="line" id="L212">        testReader(&amp;[_]<span class="tok-type">u8</span>{</span>
<span class="line" id="L213">            <span class="tok-number">0x1f</span>, <span class="tok-number">0x8b</span>, <span class="tok-number">0x08</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>,</span>
<span class="line" id="L214">            <span class="tok-number">0x00</span>, <span class="tok-number">0x03</span>, <span class="tok-number">0x03</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>,</span>
<span class="line" id="L215">            <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x01</span>,</span>
<span class="line" id="L216">        }, <span class="tok-str">&quot;&quot;</span>),</span>
<span class="line" id="L217">    );</span>
<span class="line" id="L218">    <span class="tok-comment">// Truncated initial size field</span>
</span>
<span class="line" id="L219">    <span class="tok-kw">try</span> testing.expectError(</span>
<span class="line" id="L220">        <span class="tok-kw">error</span>.EndOfStream,</span>
<span class="line" id="L221">        testReader(&amp;[_]<span class="tok-type">u8</span>{</span>
<span class="line" id="L222">            <span class="tok-number">0x1f</span>, <span class="tok-number">0x8b</span>, <span class="tok-number">0x08</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>,</span>
<span class="line" id="L223">            <span class="tok-number">0x00</span>, <span class="tok-number">0x03</span>, <span class="tok-number">0x03</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>,</span>
<span class="line" id="L224">            <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>,</span>
<span class="line" id="L225">        }, <span class="tok-str">&quot;&quot;</span>),</span>
<span class="line" id="L226">    );</span>
<span class="line" id="L227">}</span>
<span class="line" id="L228"></span>
</code></pre></body>
</html>