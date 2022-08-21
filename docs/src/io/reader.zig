<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">    <title>io/reader.zig - source view</title>
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
<span class="line" id="L2"><span class="tok-kw">const</span> math = std.math;</span>
<span class="line" id="L3"><span class="tok-kw">const</span> assert = std.debug.assert;</span>
<span class="line" id="L4"><span class="tok-kw">const</span> mem = std.mem;</span>
<span class="line" id="L5"><span class="tok-kw">const</span> testing = std.testing;</span>
<span class="line" id="L6"></span>
<span class="line" id="L7"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">Reader</span>(</span>
<span class="line" id="L8">    <span class="tok-kw">comptime</span> Context: <span class="tok-type">type</span>,</span>
<span class="line" id="L9">    <span class="tok-kw">comptime</span> ReadError: <span class="tok-type">type</span>,</span>
<span class="line" id="L10">    <span class="tok-comment">/// Returns the number of bytes read. It may be less than buffer.len.</span></span>
<span class="line" id="L11">    <span class="tok-comment">/// If the number of bytes read is 0, it means end of stream.</span></span>
<span class="line" id="L12">    <span class="tok-comment">/// End of stream is not an error condition.</span></span>
<span class="line" id="L13">    <span class="tok-kw">comptime</span> readFn: <span class="tok-kw">fn</span> (context: Context, buffer: []<span class="tok-type">u8</span>) ReadError!<span class="tok-type">usize</span>,</span>
<span class="line" id="L14">) <span class="tok-type">type</span> {</span>
<span class="line" id="L15">    <span class="tok-kw">return</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L16">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> Error = ReadError;</span>
<span class="line" id="L17"></span>
<span class="line" id="L18">        context: Context,</span>
<span class="line" id="L19"></span>
<span class="line" id="L20">        <span class="tok-kw">const</span> Self = <span class="tok-builtin">@This</span>();</span>
<span class="line" id="L21"></span>
<span class="line" id="L22">        <span class="tok-comment">/// Returns the number of bytes read. It may be less than buffer.len.</span></span>
<span class="line" id="L23">        <span class="tok-comment">/// If the number of bytes read is 0, it means end of stream.</span></span>
<span class="line" id="L24">        <span class="tok-comment">/// End of stream is not an error condition.</span></span>
<span class="line" id="L25">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">read</span>(self: Self, buffer: []<span class="tok-type">u8</span>) Error!<span class="tok-type">usize</span> {</span>
<span class="line" id="L26">            <span class="tok-kw">return</span> readFn(self.context, buffer);</span>
<span class="line" id="L27">        }</span>
<span class="line" id="L28"></span>
<span class="line" id="L29">        <span class="tok-comment">/// Returns the number of bytes read. If the number read is smaller than `buffer.len`, it</span></span>
<span class="line" id="L30">        <span class="tok-comment">/// means the stream reached the end. Reaching the end of a stream is not an error</span></span>
<span class="line" id="L31">        <span class="tok-comment">/// condition.</span></span>
<span class="line" id="L32">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">readAll</span>(self: Self, buffer: []<span class="tok-type">u8</span>) Error!<span class="tok-type">usize</span> {</span>
<span class="line" id="L33">            <span class="tok-kw">var</span> index: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L34">            <span class="tok-kw">while</span> (index != buffer.len) {</span>
<span class="line" id="L35">                <span class="tok-kw">const</span> amt = <span class="tok-kw">try</span> self.read(buffer[index..]);</span>
<span class="line" id="L36">                <span class="tok-kw">if</span> (amt == <span class="tok-number">0</span>) <span class="tok-kw">return</span> index;</span>
<span class="line" id="L37">                index += amt;</span>
<span class="line" id="L38">            }</span>
<span class="line" id="L39">            <span class="tok-kw">return</span> index;</span>
<span class="line" id="L40">        }</span>
<span class="line" id="L41"></span>
<span class="line" id="L42">        <span class="tok-comment">/// If the number read would be smaller than `buf.len`, `error.EndOfStream` is returned instead.</span></span>
<span class="line" id="L43">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">readNoEof</span>(self: Self, buf: []<span class="tok-type">u8</span>) !<span class="tok-type">void</span> {</span>
<span class="line" id="L44">            <span class="tok-kw">const</span> amt_read = <span class="tok-kw">try</span> self.readAll(buf);</span>
<span class="line" id="L45">            <span class="tok-kw">if</span> (amt_read &lt; buf.len) <span class="tok-kw">return</span> <span class="tok-kw">error</span>.EndOfStream;</span>
<span class="line" id="L46">        }</span>
<span class="line" id="L47"></span>
<span class="line" id="L48">        <span class="tok-comment">/// Appends to the `std.ArrayList` contents by reading from the stream</span></span>
<span class="line" id="L49">        <span class="tok-comment">/// until end of stream is found.</span></span>
<span class="line" id="L50">        <span class="tok-comment">/// If the number of bytes appended would exceed `max_append_size`,</span></span>
<span class="line" id="L51">        <span class="tok-comment">/// `error.StreamTooLong` is returned</span></span>
<span class="line" id="L52">        <span class="tok-comment">/// and the `std.ArrayList` has exactly `max_append_size` bytes appended.</span></span>
<span class="line" id="L53">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">readAllArrayList</span>(self: Self, array_list: *std.ArrayList(<span class="tok-type">u8</span>), max_append_size: <span class="tok-type">usize</span>) !<span class="tok-type">void</span> {</span>
<span class="line" id="L54">            <span class="tok-kw">return</span> self.readAllArrayListAligned(<span class="tok-null">null</span>, array_list, max_append_size);</span>
<span class="line" id="L55">        }</span>
<span class="line" id="L56"></span>
<span class="line" id="L57">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">readAllArrayListAligned</span>(</span>
<span class="line" id="L58">            self: Self,</span>
<span class="line" id="L59">            <span class="tok-kw">comptime</span> alignment: ?<span class="tok-type">u29</span>,</span>
<span class="line" id="L60">            array_list: *std.ArrayListAligned(<span class="tok-type">u8</span>, alignment),</span>
<span class="line" id="L61">            max_append_size: <span class="tok-type">usize</span>,</span>
<span class="line" id="L62">        ) !<span class="tok-type">void</span> {</span>
<span class="line" id="L63">            <span class="tok-kw">try</span> array_list.ensureTotalCapacity(math.min(max_append_size, <span class="tok-number">4096</span>));</span>
<span class="line" id="L64">            <span class="tok-kw">const</span> original_len = array_list.items.len;</span>
<span class="line" id="L65">            <span class="tok-kw">var</span> start_index: <span class="tok-type">usize</span> = original_len;</span>
<span class="line" id="L66">            <span class="tok-kw">while</span> (<span class="tok-null">true</span>) {</span>
<span class="line" id="L67">                array_list.expandToCapacity();</span>
<span class="line" id="L68">                <span class="tok-kw">const</span> dest_slice = array_list.items[start_index..];</span>
<span class="line" id="L69">                <span class="tok-kw">const</span> bytes_read = <span class="tok-kw">try</span> self.readAll(dest_slice);</span>
<span class="line" id="L70">                start_index += bytes_read;</span>
<span class="line" id="L71"></span>
<span class="line" id="L72">                <span class="tok-kw">if</span> (start_index - original_len &gt; max_append_size) {</span>
<span class="line" id="L73">                    array_list.shrinkAndFree(original_len + max_append_size);</span>
<span class="line" id="L74">                    <span class="tok-kw">return</span> <span class="tok-kw">error</span>.StreamTooLong;</span>
<span class="line" id="L75">                }</span>
<span class="line" id="L76"></span>
<span class="line" id="L77">                <span class="tok-kw">if</span> (bytes_read != dest_slice.len) {</span>
<span class="line" id="L78">                    array_list.shrinkAndFree(start_index);</span>
<span class="line" id="L79">                    <span class="tok-kw">return</span>;</span>
<span class="line" id="L80">                }</span>
<span class="line" id="L81"></span>
<span class="line" id="L82">                <span class="tok-comment">// This will trigger ArrayList to expand superlinearly at whatever its growth rate is.</span>
</span>
<span class="line" id="L83">                <span class="tok-kw">try</span> array_list.ensureTotalCapacity(start_index + <span class="tok-number">1</span>);</span>
<span class="line" id="L84">            }</span>
<span class="line" id="L85">        }</span>
<span class="line" id="L86"></span>
<span class="line" id="L87">        <span class="tok-comment">/// Allocates enough memory to hold all the contents of the stream. If the allocated</span></span>
<span class="line" id="L88">        <span class="tok-comment">/// memory would be greater than `max_size`, returns `error.StreamTooLong`.</span></span>
<span class="line" id="L89">        <span class="tok-comment">/// Caller owns returned memory.</span></span>
<span class="line" id="L90">        <span class="tok-comment">/// If this function returns an error, the contents from the stream read so far are lost.</span></span>
<span class="line" id="L91">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">readAllAlloc</span>(self: Self, allocator: mem.Allocator, max_size: <span class="tok-type">usize</span>) ![]<span class="tok-type">u8</span> {</span>
<span class="line" id="L92">            <span class="tok-kw">var</span> array_list = std.ArrayList(<span class="tok-type">u8</span>).init(allocator);</span>
<span class="line" id="L93">            <span class="tok-kw">defer</span> array_list.deinit();</span>
<span class="line" id="L94">            <span class="tok-kw">try</span> self.readAllArrayList(&amp;array_list, max_size);</span>
<span class="line" id="L95">            <span class="tok-kw">return</span> array_list.toOwnedSlice();</span>
<span class="line" id="L96">        }</span>
<span class="line" id="L97"></span>
<span class="line" id="L98">        <span class="tok-comment">/// Replaces the `std.ArrayList` contents by reading from the stream until `delimiter` is found.</span></span>
<span class="line" id="L99">        <span class="tok-comment">/// Does not include the delimiter in the result.</span></span>
<span class="line" id="L100">        <span class="tok-comment">/// If the `std.ArrayList` length would exceed `max_size`, `error.StreamTooLong` is returned and the</span></span>
<span class="line" id="L101">        <span class="tok-comment">/// `std.ArrayList` is populated with `max_size` bytes from the stream.</span></span>
<span class="line" id="L102">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">readUntilDelimiterArrayList</span>(</span>
<span class="line" id="L103">            self: Self,</span>
<span class="line" id="L104">            array_list: *std.ArrayList(<span class="tok-type">u8</span>),</span>
<span class="line" id="L105">            delimiter: <span class="tok-type">u8</span>,</span>
<span class="line" id="L106">            max_size: <span class="tok-type">usize</span>,</span>
<span class="line" id="L107">        ) !<span class="tok-type">void</span> {</span>
<span class="line" id="L108">            array_list.shrinkRetainingCapacity(<span class="tok-number">0</span>);</span>
<span class="line" id="L109">            <span class="tok-kw">while</span> (<span class="tok-null">true</span>) {</span>
<span class="line" id="L110">                <span class="tok-kw">if</span> (array_list.items.len == max_size) {</span>
<span class="line" id="L111">                    <span class="tok-kw">return</span> <span class="tok-kw">error</span>.StreamTooLong;</span>
<span class="line" id="L112">                }</span>
<span class="line" id="L113"></span>
<span class="line" id="L114">                <span class="tok-kw">var</span> byte: <span class="tok-type">u8</span> = <span class="tok-kw">try</span> self.readByte();</span>
<span class="line" id="L115"></span>
<span class="line" id="L116">                <span class="tok-kw">if</span> (byte == delimiter) {</span>
<span class="line" id="L117">                    <span class="tok-kw">return</span>;</span>
<span class="line" id="L118">                }</span>
<span class="line" id="L119"></span>
<span class="line" id="L120">                <span class="tok-kw">try</span> array_list.append(byte);</span>
<span class="line" id="L121">            }</span>
<span class="line" id="L122">        }</span>
<span class="line" id="L123"></span>
<span class="line" id="L124">        <span class="tok-comment">/// Allocates enough memory to read until `delimiter`. If the allocated</span></span>
<span class="line" id="L125">        <span class="tok-comment">/// memory would be greater than `max_size`, returns `error.StreamTooLong`.</span></span>
<span class="line" id="L126">        <span class="tok-comment">/// Caller owns returned memory.</span></span>
<span class="line" id="L127">        <span class="tok-comment">/// If this function returns an error, the contents from the stream read so far are lost.</span></span>
<span class="line" id="L128">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">readUntilDelimiterAlloc</span>(</span>
<span class="line" id="L129">            self: Self,</span>
<span class="line" id="L130">            allocator: mem.Allocator,</span>
<span class="line" id="L131">            delimiter: <span class="tok-type">u8</span>,</span>
<span class="line" id="L132">            max_size: <span class="tok-type">usize</span>,</span>
<span class="line" id="L133">        ) ![]<span class="tok-type">u8</span> {</span>
<span class="line" id="L134">            <span class="tok-kw">var</span> array_list = std.ArrayList(<span class="tok-type">u8</span>).init(allocator);</span>
<span class="line" id="L135">            <span class="tok-kw">defer</span> array_list.deinit();</span>
<span class="line" id="L136">            <span class="tok-kw">try</span> self.readUntilDelimiterArrayList(&amp;array_list, delimiter, max_size);</span>
<span class="line" id="L137">            <span class="tok-kw">return</span> array_list.toOwnedSlice();</span>
<span class="line" id="L138">        }</span>
<span class="line" id="L139"></span>
<span class="line" id="L140">        <span class="tok-comment">/// Reads from the stream until specified byte is found. If the buffer is not</span></span>
<span class="line" id="L141">        <span class="tok-comment">/// large enough to hold the entire contents, `error.StreamTooLong` is returned.</span></span>
<span class="line" id="L142">        <span class="tok-comment">/// If end-of-stream is found, `error.EndOfStream` is returned.</span></span>
<span class="line" id="L143">        <span class="tok-comment">/// Returns a slice of the stream data, with ptr equal to `buf.ptr`. The</span></span>
<span class="line" id="L144">        <span class="tok-comment">/// delimiter byte is written to the output buffer but is not included</span></span>
<span class="line" id="L145">        <span class="tok-comment">/// in the returned slice.</span></span>
<span class="line" id="L146">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">readUntilDelimiter</span>(self: Self, buf: []<span class="tok-type">u8</span>, delimiter: <span class="tok-type">u8</span>) ![]<span class="tok-type">u8</span> {</span>
<span class="line" id="L147">            <span class="tok-kw">var</span> index: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L148">            <span class="tok-kw">while</span> (<span class="tok-null">true</span>) {</span>
<span class="line" id="L149">                <span class="tok-kw">if</span> (index &gt;= buf.len) <span class="tok-kw">return</span> <span class="tok-kw">error</span>.StreamTooLong;</span>
<span class="line" id="L150"></span>
<span class="line" id="L151">                <span class="tok-kw">const</span> byte = <span class="tok-kw">try</span> self.readByte();</span>
<span class="line" id="L152">                buf[index] = byte;</span>
<span class="line" id="L153"></span>
<span class="line" id="L154">                <span class="tok-kw">if</span> (byte == delimiter) <span class="tok-kw">return</span> buf[<span class="tok-number">0</span>..index];</span>
<span class="line" id="L155"></span>
<span class="line" id="L156">                index += <span class="tok-number">1</span>;</span>
<span class="line" id="L157">            }</span>
<span class="line" id="L158">        }</span>
<span class="line" id="L159"></span>
<span class="line" id="L160">        <span class="tok-comment">/// Allocates enough memory to read until `delimiter` or end-of-stream.</span></span>
<span class="line" id="L161">        <span class="tok-comment">/// If the allocated memory would be greater than `max_size`, returns</span></span>
<span class="line" id="L162">        <span class="tok-comment">/// `error.StreamTooLong`. If end-of-stream is found, returns the rest</span></span>
<span class="line" id="L163">        <span class="tok-comment">/// of the stream. If this function is called again after that, returns</span></span>
<span class="line" id="L164">        <span class="tok-comment">/// null.</span></span>
<span class="line" id="L165">        <span class="tok-comment">/// Caller owns returned memory.</span></span>
<span class="line" id="L166">        <span class="tok-comment">/// If this function returns an error, the contents from the stream read so far are lost.</span></span>
<span class="line" id="L167">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">readUntilDelimiterOrEofAlloc</span>(</span>
<span class="line" id="L168">            self: Self,</span>
<span class="line" id="L169">            allocator: mem.Allocator,</span>
<span class="line" id="L170">            delimiter: <span class="tok-type">u8</span>,</span>
<span class="line" id="L171">            max_size: <span class="tok-type">usize</span>,</span>
<span class="line" id="L172">        ) !?[]<span class="tok-type">u8</span> {</span>
<span class="line" id="L173">            <span class="tok-kw">var</span> array_list = std.ArrayList(<span class="tok-type">u8</span>).init(allocator);</span>
<span class="line" id="L174">            <span class="tok-kw">defer</span> array_list.deinit();</span>
<span class="line" id="L175">            self.readUntilDelimiterArrayList(&amp;array_list, delimiter, max_size) <span class="tok-kw">catch</span> |err| <span class="tok-kw">switch</span> (err) {</span>
<span class="line" id="L176">                <span class="tok-kw">error</span>.EndOfStream =&gt; <span class="tok-kw">if</span> (array_list.items.len == <span class="tok-number">0</span>) {</span>
<span class="line" id="L177">                    <span class="tok-kw">return</span> <span class="tok-null">null</span>;</span>
<span class="line" id="L178">                } <span class="tok-kw">else</span> {</span>
<span class="line" id="L179">                    <span class="tok-kw">return</span> array_list.toOwnedSlice();</span>
<span class="line" id="L180">                },</span>
<span class="line" id="L181">                <span class="tok-kw">else</span> =&gt; |e| <span class="tok-kw">return</span> e,</span>
<span class="line" id="L182">            };</span>
<span class="line" id="L183">            <span class="tok-kw">return</span> array_list.toOwnedSlice();</span>
<span class="line" id="L184">        }</span>
<span class="line" id="L185"></span>
<span class="line" id="L186">        <span class="tok-comment">/// Reads from the stream until specified byte is found. If the buffer is not</span></span>
<span class="line" id="L187">        <span class="tok-comment">/// large enough to hold the entire contents, `error.StreamTooLong` is returned.</span></span>
<span class="line" id="L188">        <span class="tok-comment">/// If end-of-stream is found, returns the rest of the stream. If this</span></span>
<span class="line" id="L189">        <span class="tok-comment">/// function is called again after that, returns null.</span></span>
<span class="line" id="L190">        <span class="tok-comment">/// Returns a slice of the stream data, with ptr equal to `buf.ptr`. The</span></span>
<span class="line" id="L191">        <span class="tok-comment">/// delimiter byte is written to the output buffer but is not included</span></span>
<span class="line" id="L192">        <span class="tok-comment">/// in the returned slice.</span></span>
<span class="line" id="L193">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">readUntilDelimiterOrEof</span>(self: Self, buf: []<span class="tok-type">u8</span>, delimiter: <span class="tok-type">u8</span>) !?[]<span class="tok-type">u8</span> {</span>
<span class="line" id="L194">            <span class="tok-kw">var</span> index: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L195">            <span class="tok-kw">while</span> (<span class="tok-null">true</span>) {</span>
<span class="line" id="L196">                <span class="tok-kw">if</span> (index &gt;= buf.len) <span class="tok-kw">return</span> <span class="tok-kw">error</span>.StreamTooLong;</span>
<span class="line" id="L197"></span>
<span class="line" id="L198">                <span class="tok-kw">const</span> byte = self.readByte() <span class="tok-kw">catch</span> |err| <span class="tok-kw">switch</span> (err) {</span>
<span class="line" id="L199">                    <span class="tok-kw">error</span>.EndOfStream =&gt; {</span>
<span class="line" id="L200">                        <span class="tok-kw">if</span> (index == <span class="tok-number">0</span>) {</span>
<span class="line" id="L201">                            <span class="tok-kw">return</span> <span class="tok-null">null</span>;</span>
<span class="line" id="L202">                        } <span class="tok-kw">else</span> {</span>
<span class="line" id="L203">                            <span class="tok-kw">return</span> buf[<span class="tok-number">0</span>..index];</span>
<span class="line" id="L204">                        }</span>
<span class="line" id="L205">                    },</span>
<span class="line" id="L206">                    <span class="tok-kw">else</span> =&gt; |e| <span class="tok-kw">return</span> e,</span>
<span class="line" id="L207">                };</span>
<span class="line" id="L208">                buf[index] = byte;</span>
<span class="line" id="L209"></span>
<span class="line" id="L210">                <span class="tok-kw">if</span> (byte == delimiter) <span class="tok-kw">return</span> buf[<span class="tok-number">0</span>..index];</span>
<span class="line" id="L211"></span>
<span class="line" id="L212">                index += <span class="tok-number">1</span>;</span>
<span class="line" id="L213">            }</span>
<span class="line" id="L214">        }</span>
<span class="line" id="L215"></span>
<span class="line" id="L216">        <span class="tok-comment">/// Reads from the stream until specified byte is found, discarding all data,</span></span>
<span class="line" id="L217">        <span class="tok-comment">/// including the delimiter.</span></span>
<span class="line" id="L218">        <span class="tok-comment">/// If end-of-stream is found, this function succeeds.</span></span>
<span class="line" id="L219">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">skipUntilDelimiterOrEof</span>(self: Self, delimiter: <span class="tok-type">u8</span>) !<span class="tok-type">void</span> {</span>
<span class="line" id="L220">            <span class="tok-kw">while</span> (<span class="tok-null">true</span>) {</span>
<span class="line" id="L221">                <span class="tok-kw">const</span> byte = self.readByte() <span class="tok-kw">catch</span> |err| <span class="tok-kw">switch</span> (err) {</span>
<span class="line" id="L222">                    <span class="tok-kw">error</span>.EndOfStream =&gt; <span class="tok-kw">return</span>,</span>
<span class="line" id="L223">                    <span class="tok-kw">else</span> =&gt; |e| <span class="tok-kw">return</span> e,</span>
<span class="line" id="L224">                };</span>
<span class="line" id="L225">                <span class="tok-kw">if</span> (byte == delimiter) <span class="tok-kw">return</span>;</span>
<span class="line" id="L226">            }</span>
<span class="line" id="L227">        }</span>
<span class="line" id="L228"></span>
<span class="line" id="L229">        <span class="tok-comment">/// Reads 1 byte from the stream or returns `error.EndOfStream`.</span></span>
<span class="line" id="L230">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">readByte</span>(self: Self) !<span class="tok-type">u8</span> {</span>
<span class="line" id="L231">            <span class="tok-kw">var</span> result: [<span class="tok-number">1</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L232">            <span class="tok-kw">const</span> amt_read = <span class="tok-kw">try</span> self.read(result[<span class="tok-number">0</span>..]);</span>
<span class="line" id="L233">            <span class="tok-kw">if</span> (amt_read &lt; <span class="tok-number">1</span>) <span class="tok-kw">return</span> <span class="tok-kw">error</span>.EndOfStream;</span>
<span class="line" id="L234">            <span class="tok-kw">return</span> result[<span class="tok-number">0</span>];</span>
<span class="line" id="L235">        }</span>
<span class="line" id="L236"></span>
<span class="line" id="L237">        <span class="tok-comment">/// Same as `readByte` except the returned byte is signed.</span></span>
<span class="line" id="L238">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">readByteSigned</span>(self: Self) !<span class="tok-type">i8</span> {</span>
<span class="line" id="L239">            <span class="tok-kw">return</span> <span class="tok-builtin">@bitCast</span>(<span class="tok-type">i8</span>, <span class="tok-kw">try</span> self.readByte());</span>
<span class="line" id="L240">        }</span>
<span class="line" id="L241"></span>
<span class="line" id="L242">        <span class="tok-comment">/// Reads exactly `num_bytes` bytes and returns as an array.</span></span>
<span class="line" id="L243">        <span class="tok-comment">/// `num_bytes` must be comptime-known</span></span>
<span class="line" id="L244">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">readBytesNoEof</span>(self: Self, <span class="tok-kw">comptime</span> num_bytes: <span class="tok-type">usize</span>) ![num_bytes]<span class="tok-type">u8</span> {</span>
<span class="line" id="L245">            <span class="tok-kw">var</span> bytes: [num_bytes]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L246">            <span class="tok-kw">try</span> self.readNoEof(&amp;bytes);</span>
<span class="line" id="L247">            <span class="tok-kw">return</span> bytes;</span>
<span class="line" id="L248">        }</span>
<span class="line" id="L249"></span>
<span class="line" id="L250">        <span class="tok-comment">/// Reads a native-endian integer</span></span>
<span class="line" id="L251">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">readIntNative</span>(self: Self, <span class="tok-kw">comptime</span> T: <span class="tok-type">type</span>) !T {</span>
<span class="line" id="L252">            <span class="tok-kw">const</span> bytes = <span class="tok-kw">try</span> self.readBytesNoEof((<span class="tok-builtin">@typeInfo</span>(T).Int.bits + <span class="tok-number">7</span>) / <span class="tok-number">8</span>);</span>
<span class="line" id="L253">            <span class="tok-kw">return</span> mem.readIntNative(T, &amp;bytes);</span>
<span class="line" id="L254">        }</span>
<span class="line" id="L255"></span>
<span class="line" id="L256">        <span class="tok-comment">/// Reads a foreign-endian integer</span></span>
<span class="line" id="L257">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">readIntForeign</span>(self: Self, <span class="tok-kw">comptime</span> T: <span class="tok-type">type</span>) !T {</span>
<span class="line" id="L258">            <span class="tok-kw">const</span> bytes = <span class="tok-kw">try</span> self.readBytesNoEof((<span class="tok-builtin">@typeInfo</span>(T).Int.bits + <span class="tok-number">7</span>) / <span class="tok-number">8</span>);</span>
<span class="line" id="L259">            <span class="tok-kw">return</span> mem.readIntForeign(T, &amp;bytes);</span>
<span class="line" id="L260">        }</span>
<span class="line" id="L261"></span>
<span class="line" id="L262">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">readIntLittle</span>(self: Self, <span class="tok-kw">comptime</span> T: <span class="tok-type">type</span>) !T {</span>
<span class="line" id="L263">            <span class="tok-kw">const</span> bytes = <span class="tok-kw">try</span> self.readBytesNoEof((<span class="tok-builtin">@typeInfo</span>(T).Int.bits + <span class="tok-number">7</span>) / <span class="tok-number">8</span>);</span>
<span class="line" id="L264">            <span class="tok-kw">return</span> mem.readIntLittle(T, &amp;bytes);</span>
<span class="line" id="L265">        }</span>
<span class="line" id="L266"></span>
<span class="line" id="L267">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">readIntBig</span>(self: Self, <span class="tok-kw">comptime</span> T: <span class="tok-type">type</span>) !T {</span>
<span class="line" id="L268">            <span class="tok-kw">const</span> bytes = <span class="tok-kw">try</span> self.readBytesNoEof((<span class="tok-builtin">@typeInfo</span>(T).Int.bits + <span class="tok-number">7</span>) / <span class="tok-number">8</span>);</span>
<span class="line" id="L269">            <span class="tok-kw">return</span> mem.readIntBig(T, &amp;bytes);</span>
<span class="line" id="L270">        }</span>
<span class="line" id="L271"></span>
<span class="line" id="L272">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">readInt</span>(self: Self, <span class="tok-kw">comptime</span> T: <span class="tok-type">type</span>, endian: std.builtin.Endian) !T {</span>
<span class="line" id="L273">            <span class="tok-kw">const</span> bytes = <span class="tok-kw">try</span> self.readBytesNoEof((<span class="tok-builtin">@typeInfo</span>(T).Int.bits + <span class="tok-number">7</span>) / <span class="tok-number">8</span>);</span>
<span class="line" id="L274">            <span class="tok-kw">return</span> mem.readInt(T, &amp;bytes, endian);</span>
<span class="line" id="L275">        }</span>
<span class="line" id="L276"></span>
<span class="line" id="L277">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">readVarInt</span>(self: Self, <span class="tok-kw">comptime</span> ReturnType: <span class="tok-type">type</span>, endian: std.builtin.Endian, size: <span class="tok-type">usize</span>) !ReturnType {</span>
<span class="line" id="L278">            assert(size &lt;= <span class="tok-builtin">@sizeOf</span>(ReturnType));</span>
<span class="line" id="L279">            <span class="tok-kw">var</span> bytes_buf: [<span class="tok-builtin">@sizeOf</span>(ReturnType)]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L280">            <span class="tok-kw">const</span> bytes = bytes_buf[<span class="tok-number">0</span>..size];</span>
<span class="line" id="L281">            <span class="tok-kw">try</span> self.readNoEof(bytes);</span>
<span class="line" id="L282">            <span class="tok-kw">return</span> mem.readVarInt(ReturnType, bytes, endian);</span>
<span class="line" id="L283">        }</span>
<span class="line" id="L284"></span>
<span class="line" id="L285">        <span class="tok-comment">/// Optional parameters for `skipBytes`</span></span>
<span class="line" id="L286">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> SkipBytesOptions = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L287">            buf_size: <span class="tok-type">usize</span> = <span class="tok-number">512</span>,</span>
<span class="line" id="L288">        };</span>
<span class="line" id="L289"></span>
<span class="line" id="L290">        <span class="tok-comment">// `num_bytes` is a `u64` to match `off_t`</span>
</span>
<span class="line" id="L291">        <span class="tok-comment">/// Reads `num_bytes` bytes from the stream and discards them</span></span>
<span class="line" id="L292">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">skipBytes</span>(self: Self, num_bytes: <span class="tok-type">u64</span>, <span class="tok-kw">comptime</span> options: SkipBytesOptions) !<span class="tok-type">void</span> {</span>
<span class="line" id="L293">            <span class="tok-kw">var</span> buf: [options.buf_size]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L294">            <span class="tok-kw">var</span> remaining = num_bytes;</span>
<span class="line" id="L295"></span>
<span class="line" id="L296">            <span class="tok-kw">while</span> (remaining &gt; <span class="tok-number">0</span>) {</span>
<span class="line" id="L297">                <span class="tok-kw">const</span> amt = std.math.min(remaining, options.buf_size);</span>
<span class="line" id="L298">                <span class="tok-kw">try</span> self.readNoEof(buf[<span class="tok-number">0</span>..amt]);</span>
<span class="line" id="L299">                remaining -= amt;</span>
<span class="line" id="L300">            }</span>
<span class="line" id="L301">        }</span>
<span class="line" id="L302"></span>
<span class="line" id="L303">        <span class="tok-comment">/// Reads `slice.len` bytes from the stream and returns if they are the same as the passed slice</span></span>
<span class="line" id="L304">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">isBytes</span>(self: Self, slice: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) !<span class="tok-type">bool</span> {</span>
<span class="line" id="L305">            <span class="tok-kw">var</span> i: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L306">            <span class="tok-kw">var</span> matches = <span class="tok-null">true</span>;</span>
<span class="line" id="L307">            <span class="tok-kw">while</span> (i &lt; slice.len) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L308">                <span class="tok-kw">if</span> (slice[i] != <span class="tok-kw">try</span> self.readByte()) {</span>
<span class="line" id="L309">                    matches = <span class="tok-null">false</span>;</span>
<span class="line" id="L310">                }</span>
<span class="line" id="L311">            }</span>
<span class="line" id="L312">            <span class="tok-kw">return</span> matches;</span>
<span class="line" id="L313">        }</span>
<span class="line" id="L314"></span>
<span class="line" id="L315">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">readStruct</span>(self: Self, <span class="tok-kw">comptime</span> T: <span class="tok-type">type</span>) !T {</span>
<span class="line" id="L316">            <span class="tok-comment">// Only extern and packed structs have defined in-memory layout.</span>
</span>
<span class="line" id="L317">            <span class="tok-kw">comptime</span> assert(<span class="tok-builtin">@typeInfo</span>(T).Struct.layout != .Auto);</span>
<span class="line" id="L318">            <span class="tok-kw">var</span> res: [<span class="tok-number">1</span>]T = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L319">            <span class="tok-kw">try</span> self.readNoEof(mem.sliceAsBytes(res[<span class="tok-number">0</span>..]));</span>
<span class="line" id="L320">            <span class="tok-kw">return</span> res[<span class="tok-number">0</span>];</span>
<span class="line" id="L321">        }</span>
<span class="line" id="L322"></span>
<span class="line" id="L323">        <span class="tok-comment">/// Reads an integer with the same size as the given enum's tag type. If the integer matches</span></span>
<span class="line" id="L324">        <span class="tok-comment">/// an enum tag, casts the integer to the enum tag and returns it. Otherwise, returns an error.</span></span>
<span class="line" id="L325">        <span class="tok-comment">/// TODO optimization taking advantage of most fields being in order</span></span>
<span class="line" id="L326">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">readEnum</span>(self: Self, <span class="tok-kw">comptime</span> Enum: <span class="tok-type">type</span>, endian: std.builtin.Endian) !Enum {</span>
<span class="line" id="L327">            <span class="tok-kw">const</span> E = <span class="tok-kw">error</span>{</span>
<span class="line" id="L328">                <span class="tok-comment">/// An integer was read, but it did not match any of the tags in the supplied enum.</span></span>
<span class="line" id="L329">                InvalidValue,</span>
<span class="line" id="L330">            };</span>
<span class="line" id="L331">            <span class="tok-kw">const</span> type_info = <span class="tok-builtin">@typeInfo</span>(Enum).Enum;</span>
<span class="line" id="L332">            <span class="tok-kw">const</span> tag = <span class="tok-kw">try</span> self.readInt(type_info.tag_type, endian);</span>
<span class="line" id="L333"></span>
<span class="line" id="L334">            <span class="tok-kw">inline</span> <span class="tok-kw">for</span> (std.meta.fields(Enum)) |field| {</span>
<span class="line" id="L335">                <span class="tok-kw">if</span> (tag == field.value) {</span>
<span class="line" id="L336">                    <span class="tok-kw">return</span> <span class="tok-builtin">@field</span>(Enum, field.name);</span>
<span class="line" id="L337">                }</span>
<span class="line" id="L338">            }</span>
<span class="line" id="L339"></span>
<span class="line" id="L340">            <span class="tok-kw">return</span> E.InvalidValue;</span>
<span class="line" id="L341">        }</span>
<span class="line" id="L342">    };</span>
<span class="line" id="L343">}</span>
<span class="line" id="L344"></span>
<span class="line" id="L345"><span class="tok-kw">test</span> <span class="tok-str">&quot;Reader&quot;</span> {</span>
<span class="line" id="L346">    <span class="tok-kw">var</span> buf = <span class="tok-str">&quot;a\x02&quot;</span>.*;</span>
<span class="line" id="L347">    <span class="tok-kw">var</span> fis = std.io.fixedBufferStream(&amp;buf);</span>
<span class="line" id="L348">    <span class="tok-kw">const</span> reader = fis.reader();</span>
<span class="line" id="L349">    <span class="tok-kw">try</span> testing.expect((<span class="tok-kw">try</span> reader.readByte()) == <span class="tok-str">'a'</span>);</span>
<span class="line" id="L350">    <span class="tok-kw">try</span> testing.expect((<span class="tok-kw">try</span> reader.readEnum(<span class="tok-kw">enum</span>(<span class="tok-type">u8</span>) {</span>
<span class="line" id="L351">        a = <span class="tok-number">0</span>,</span>
<span class="line" id="L352">        b = <span class="tok-number">99</span>,</span>
<span class="line" id="L353">        c = <span class="tok-number">2</span>,</span>
<span class="line" id="L354">        d = <span class="tok-number">3</span>,</span>
<span class="line" id="L355">    }, <span class="tok-null">undefined</span>)) == .c);</span>
<span class="line" id="L356">    <span class="tok-kw">try</span> testing.expectError(<span class="tok-kw">error</span>.EndOfStream, reader.readByte());</span>
<span class="line" id="L357">}</span>
<span class="line" id="L358"></span>
<span class="line" id="L359"><span class="tok-kw">test</span> <span class="tok-str">&quot;Reader.isBytes&quot;</span> {</span>
<span class="line" id="L360">    <span class="tok-kw">var</span> fis = std.io.fixedBufferStream(<span class="tok-str">&quot;foobar&quot;</span>);</span>
<span class="line" id="L361">    <span class="tok-kw">const</span> reader = fis.reader();</span>
<span class="line" id="L362">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-null">true</span>, <span class="tok-kw">try</span> reader.isBytes(<span class="tok-str">&quot;foo&quot;</span>));</span>
<span class="line" id="L363">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-null">false</span>, <span class="tok-kw">try</span> reader.isBytes(<span class="tok-str">&quot;qux&quot;</span>));</span>
<span class="line" id="L364">}</span>
<span class="line" id="L365"></span>
<span class="line" id="L366"><span class="tok-kw">test</span> <span class="tok-str">&quot;Reader.skipBytes&quot;</span> {</span>
<span class="line" id="L367">    <span class="tok-kw">var</span> fis = std.io.fixedBufferStream(<span class="tok-str">&quot;foobar&quot;</span>);</span>
<span class="line" id="L368">    <span class="tok-kw">const</span> reader = fis.reader();</span>
<span class="line" id="L369">    <span class="tok-kw">try</span> reader.skipBytes(<span class="tok-number">3</span>, .{});</span>
<span class="line" id="L370">    <span class="tok-kw">try</span> testing.expect(<span class="tok-kw">try</span> reader.isBytes(<span class="tok-str">&quot;bar&quot;</span>));</span>
<span class="line" id="L371">    <span class="tok-kw">try</span> reader.skipBytes(<span class="tok-number">0</span>, .{});</span>
<span class="line" id="L372">    <span class="tok-kw">try</span> testing.expectError(<span class="tok-kw">error</span>.EndOfStream, reader.skipBytes(<span class="tok-number">1</span>, .{}));</span>
<span class="line" id="L373">}</span>
<span class="line" id="L374"></span>
<span class="line" id="L375"><span class="tok-kw">test</span> <span class="tok-str">&quot;Reader.readUntilDelimiterArrayList returns ArrayLists with bytes read until the delimiter, then EndOfStream&quot;</span> {</span>
<span class="line" id="L376">    <span class="tok-kw">const</span> a = std.testing.allocator;</span>
<span class="line" id="L377">    <span class="tok-kw">var</span> list = std.ArrayList(<span class="tok-type">u8</span>).init(a);</span>
<span class="line" id="L378">    <span class="tok-kw">defer</span> list.deinit();</span>
<span class="line" id="L379"></span>
<span class="line" id="L380">    <span class="tok-kw">var</span> fis = std.io.fixedBufferStream(<span class="tok-str">&quot;0000\n1234\n&quot;</span>);</span>
<span class="line" id="L381">    <span class="tok-kw">const</span> reader = fis.reader();</span>
<span class="line" id="L382"></span>
<span class="line" id="L383">    <span class="tok-kw">try</span> reader.readUntilDelimiterArrayList(&amp;list, <span class="tok-str">'\n'</span>, <span class="tok-number">5</span>);</span>
<span class="line" id="L384">    <span class="tok-kw">try</span> std.testing.expectEqualStrings(<span class="tok-str">&quot;0000&quot;</span>, list.items);</span>
<span class="line" id="L385">    <span class="tok-kw">try</span> reader.readUntilDelimiterArrayList(&amp;list, <span class="tok-str">'\n'</span>, <span class="tok-number">5</span>);</span>
<span class="line" id="L386">    <span class="tok-kw">try</span> std.testing.expectEqualStrings(<span class="tok-str">&quot;1234&quot;</span>, list.items);</span>
<span class="line" id="L387">    <span class="tok-kw">try</span> std.testing.expectError(<span class="tok-kw">error</span>.EndOfStream, reader.readUntilDelimiterArrayList(&amp;list, <span class="tok-str">'\n'</span>, <span class="tok-number">5</span>));</span>
<span class="line" id="L388">}</span>
<span class="line" id="L389"></span>
<span class="line" id="L390"><span class="tok-kw">test</span> <span class="tok-str">&quot;Reader.readUntilDelimiterArrayList returns an empty ArrayList&quot;</span> {</span>
<span class="line" id="L391">    <span class="tok-kw">const</span> a = std.testing.allocator;</span>
<span class="line" id="L392">    <span class="tok-kw">var</span> list = std.ArrayList(<span class="tok-type">u8</span>).init(a);</span>
<span class="line" id="L393">    <span class="tok-kw">defer</span> list.deinit();</span>
<span class="line" id="L394"></span>
<span class="line" id="L395">    <span class="tok-kw">var</span> fis = std.io.fixedBufferStream(<span class="tok-str">&quot;\n&quot;</span>);</span>
<span class="line" id="L396">    <span class="tok-kw">const</span> reader = fis.reader();</span>
<span class="line" id="L397"></span>
<span class="line" id="L398">    <span class="tok-kw">try</span> reader.readUntilDelimiterArrayList(&amp;list, <span class="tok-str">'\n'</span>, <span class="tok-number">5</span>);</span>
<span class="line" id="L399">    <span class="tok-kw">try</span> std.testing.expectEqualStrings(<span class="tok-str">&quot;&quot;</span>, list.items);</span>
<span class="line" id="L400">}</span>
<span class="line" id="L401"></span>
<span class="line" id="L402"><span class="tok-kw">test</span> <span class="tok-str">&quot;Reader.readUntilDelimiterArrayList returns StreamTooLong, then an ArrayList with bytes read until the delimiter&quot;</span> {</span>
<span class="line" id="L403">    <span class="tok-kw">const</span> a = std.testing.allocator;</span>
<span class="line" id="L404">    <span class="tok-kw">var</span> list = std.ArrayList(<span class="tok-type">u8</span>).init(a);</span>
<span class="line" id="L405">    <span class="tok-kw">defer</span> list.deinit();</span>
<span class="line" id="L406"></span>
<span class="line" id="L407">    <span class="tok-kw">var</span> fis = std.io.fixedBufferStream(<span class="tok-str">&quot;1234567\n&quot;</span>);</span>
<span class="line" id="L408">    <span class="tok-kw">const</span> reader = fis.reader();</span>
<span class="line" id="L409"></span>
<span class="line" id="L410">    <span class="tok-kw">try</span> std.testing.expectError(<span class="tok-kw">error</span>.StreamTooLong, reader.readUntilDelimiterArrayList(&amp;list, <span class="tok-str">'\n'</span>, <span class="tok-number">5</span>));</span>
<span class="line" id="L411">    <span class="tok-kw">try</span> std.testing.expectEqualStrings(<span class="tok-str">&quot;12345&quot;</span>, list.items);</span>
<span class="line" id="L412">    <span class="tok-kw">try</span> reader.readUntilDelimiterArrayList(&amp;list, <span class="tok-str">'\n'</span>, <span class="tok-number">5</span>);</span>
<span class="line" id="L413">    <span class="tok-kw">try</span> std.testing.expectEqualStrings(<span class="tok-str">&quot;67&quot;</span>, list.items);</span>
<span class="line" id="L414">}</span>
<span class="line" id="L415"></span>
<span class="line" id="L416"><span class="tok-kw">test</span> <span class="tok-str">&quot;Reader.readUntilDelimiterArrayList returns EndOfStream&quot;</span> {</span>
<span class="line" id="L417">    <span class="tok-kw">const</span> a = std.testing.allocator;</span>
<span class="line" id="L418">    <span class="tok-kw">var</span> list = std.ArrayList(<span class="tok-type">u8</span>).init(a);</span>
<span class="line" id="L419">    <span class="tok-kw">defer</span> list.deinit();</span>
<span class="line" id="L420"></span>
<span class="line" id="L421">    <span class="tok-kw">var</span> fis = std.io.fixedBufferStream(<span class="tok-str">&quot;1234&quot;</span>);</span>
<span class="line" id="L422">    <span class="tok-kw">const</span> reader = fis.reader();</span>
<span class="line" id="L423"></span>
<span class="line" id="L424">    <span class="tok-kw">try</span> std.testing.expectError(<span class="tok-kw">error</span>.EndOfStream, reader.readUntilDelimiterArrayList(&amp;list, <span class="tok-str">'\n'</span>, <span class="tok-number">5</span>));</span>
<span class="line" id="L425">    <span class="tok-kw">try</span> std.testing.expectEqualStrings(<span class="tok-str">&quot;1234&quot;</span>, list.items);</span>
<span class="line" id="L426">}</span>
<span class="line" id="L427"></span>
<span class="line" id="L428"><span class="tok-kw">test</span> <span class="tok-str">&quot;Reader.readUntilDelimiterAlloc returns ArrayLists with bytes read until the delimiter, then EndOfStream&quot;</span> {</span>
<span class="line" id="L429">    <span class="tok-kw">const</span> a = std.testing.allocator;</span>
<span class="line" id="L430"></span>
<span class="line" id="L431">    <span class="tok-kw">var</span> fis = std.io.fixedBufferStream(<span class="tok-str">&quot;0000\n1234\n&quot;</span>);</span>
<span class="line" id="L432">    <span class="tok-kw">const</span> reader = fis.reader();</span>
<span class="line" id="L433"></span>
<span class="line" id="L434">    {</span>
<span class="line" id="L435">        <span class="tok-kw">var</span> result = <span class="tok-kw">try</span> reader.readUntilDelimiterAlloc(a, <span class="tok-str">'\n'</span>, <span class="tok-number">5</span>);</span>
<span class="line" id="L436">        <span class="tok-kw">defer</span> a.free(result);</span>
<span class="line" id="L437">        <span class="tok-kw">try</span> std.testing.expectEqualStrings(<span class="tok-str">&quot;0000&quot;</span>, result);</span>
<span class="line" id="L438">    }</span>
<span class="line" id="L439"></span>
<span class="line" id="L440">    {</span>
<span class="line" id="L441">        <span class="tok-kw">var</span> result = <span class="tok-kw">try</span> reader.readUntilDelimiterAlloc(a, <span class="tok-str">'\n'</span>, <span class="tok-number">5</span>);</span>
<span class="line" id="L442">        <span class="tok-kw">defer</span> a.free(result);</span>
<span class="line" id="L443">        <span class="tok-kw">try</span> std.testing.expectEqualStrings(<span class="tok-str">&quot;1234&quot;</span>, result);</span>
<span class="line" id="L444">    }</span>
<span class="line" id="L445"></span>
<span class="line" id="L446">    <span class="tok-kw">try</span> std.testing.expectError(<span class="tok-kw">error</span>.EndOfStream, reader.readUntilDelimiterAlloc(a, <span class="tok-str">'\n'</span>, <span class="tok-number">5</span>));</span>
<span class="line" id="L447">}</span>
<span class="line" id="L448"></span>
<span class="line" id="L449"><span class="tok-kw">test</span> <span class="tok-str">&quot;Reader.readUntilDelimiterAlloc returns an empty ArrayList&quot;</span> {</span>
<span class="line" id="L450">    <span class="tok-kw">const</span> a = std.testing.allocator;</span>
<span class="line" id="L451"></span>
<span class="line" id="L452">    <span class="tok-kw">var</span> fis = std.io.fixedBufferStream(<span class="tok-str">&quot;\n&quot;</span>);</span>
<span class="line" id="L453">    <span class="tok-kw">const</span> reader = fis.reader();</span>
<span class="line" id="L454"></span>
<span class="line" id="L455">    {</span>
<span class="line" id="L456">        <span class="tok-kw">var</span> result = <span class="tok-kw">try</span> reader.readUntilDelimiterAlloc(a, <span class="tok-str">'\n'</span>, <span class="tok-number">5</span>);</span>
<span class="line" id="L457">        <span class="tok-kw">defer</span> a.free(result);</span>
<span class="line" id="L458">        <span class="tok-kw">try</span> std.testing.expectEqualStrings(<span class="tok-str">&quot;&quot;</span>, result);</span>
<span class="line" id="L459">    }</span>
<span class="line" id="L460">}</span>
<span class="line" id="L461"></span>
<span class="line" id="L462"><span class="tok-kw">test</span> <span class="tok-str">&quot;Reader.readUntilDelimiterAlloc returns StreamTooLong, then an ArrayList with bytes read until the delimiter&quot;</span> {</span>
<span class="line" id="L463">    <span class="tok-kw">const</span> a = std.testing.allocator;</span>
<span class="line" id="L464"></span>
<span class="line" id="L465">    <span class="tok-kw">var</span> fis = std.io.fixedBufferStream(<span class="tok-str">&quot;1234567\n&quot;</span>);</span>
<span class="line" id="L466">    <span class="tok-kw">const</span> reader = fis.reader();</span>
<span class="line" id="L467"></span>
<span class="line" id="L468">    <span class="tok-kw">try</span> std.testing.expectError(<span class="tok-kw">error</span>.StreamTooLong, reader.readUntilDelimiterAlloc(a, <span class="tok-str">'\n'</span>, <span class="tok-number">5</span>));</span>
<span class="line" id="L469"></span>
<span class="line" id="L470">    <span class="tok-kw">var</span> result = <span class="tok-kw">try</span> reader.readUntilDelimiterAlloc(a, <span class="tok-str">'\n'</span>, <span class="tok-number">5</span>);</span>
<span class="line" id="L471">    <span class="tok-kw">defer</span> a.free(result);</span>
<span class="line" id="L472">    <span class="tok-kw">try</span> std.testing.expectEqualStrings(<span class="tok-str">&quot;67&quot;</span>, result);</span>
<span class="line" id="L473">}</span>
<span class="line" id="L474"></span>
<span class="line" id="L475"><span class="tok-kw">test</span> <span class="tok-str">&quot;Reader.readUntilDelimiterAlloc returns EndOfStream&quot;</span> {</span>
<span class="line" id="L476">    <span class="tok-kw">const</span> a = std.testing.allocator;</span>
<span class="line" id="L477"></span>
<span class="line" id="L478">    <span class="tok-kw">var</span> fis = std.io.fixedBufferStream(<span class="tok-str">&quot;1234&quot;</span>);</span>
<span class="line" id="L479">    <span class="tok-kw">const</span> reader = fis.reader();</span>
<span class="line" id="L480"></span>
<span class="line" id="L481">    <span class="tok-kw">try</span> std.testing.expectError(<span class="tok-kw">error</span>.EndOfStream, reader.readUntilDelimiterAlloc(a, <span class="tok-str">'\n'</span>, <span class="tok-number">5</span>));</span>
<span class="line" id="L482">}</span>
<span class="line" id="L483"></span>
<span class="line" id="L484"><span class="tok-kw">test</span> <span class="tok-str">&quot;Reader.readUntilDelimiter returns bytes read until the delimiter&quot;</span> {</span>
<span class="line" id="L485">    <span class="tok-kw">var</span> buf: [<span class="tok-number">5</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L486">    <span class="tok-kw">var</span> fis = std.io.fixedBufferStream(<span class="tok-str">&quot;0000\n1234\n&quot;</span>);</span>
<span class="line" id="L487">    <span class="tok-kw">const</span> reader = fis.reader();</span>
<span class="line" id="L488">    <span class="tok-kw">try</span> std.testing.expectEqualStrings(<span class="tok-str">&quot;0000&quot;</span>, <span class="tok-kw">try</span> reader.readUntilDelimiter(&amp;buf, <span class="tok-str">'\n'</span>));</span>
<span class="line" id="L489">    <span class="tok-kw">try</span> std.testing.expectEqualStrings(<span class="tok-str">&quot;1234&quot;</span>, <span class="tok-kw">try</span> reader.readUntilDelimiter(&amp;buf, <span class="tok-str">'\n'</span>));</span>
<span class="line" id="L490">}</span>
<span class="line" id="L491"></span>
<span class="line" id="L492"><span class="tok-kw">test</span> <span class="tok-str">&quot;Reader.readUntilDelimiter returns an empty string&quot;</span> {</span>
<span class="line" id="L493">    <span class="tok-kw">var</span> buf: [<span class="tok-number">5</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L494">    <span class="tok-kw">var</span> fis = std.io.fixedBufferStream(<span class="tok-str">&quot;\n&quot;</span>);</span>
<span class="line" id="L495">    <span class="tok-kw">const</span> reader = fis.reader();</span>
<span class="line" id="L496">    <span class="tok-kw">try</span> std.testing.expectEqualStrings(<span class="tok-str">&quot;&quot;</span>, <span class="tok-kw">try</span> reader.readUntilDelimiter(&amp;buf, <span class="tok-str">'\n'</span>));</span>
<span class="line" id="L497">}</span>
<span class="line" id="L498"></span>
<span class="line" id="L499"><span class="tok-kw">test</span> <span class="tok-str">&quot;Reader.readUntilDelimiter returns StreamTooLong, then an empty string&quot;</span> {</span>
<span class="line" id="L500">    <span class="tok-kw">var</span> buf: [<span class="tok-number">5</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L501">    <span class="tok-kw">var</span> fis = std.io.fixedBufferStream(<span class="tok-str">&quot;12345\n&quot;</span>);</span>
<span class="line" id="L502">    <span class="tok-kw">const</span> reader = fis.reader();</span>
<span class="line" id="L503">    <span class="tok-kw">try</span> std.testing.expectError(<span class="tok-kw">error</span>.StreamTooLong, reader.readUntilDelimiter(&amp;buf, <span class="tok-str">'\n'</span>));</span>
<span class="line" id="L504">    <span class="tok-kw">try</span> std.testing.expectEqualStrings(<span class="tok-str">&quot;&quot;</span>, <span class="tok-kw">try</span> reader.readUntilDelimiter(&amp;buf, <span class="tok-str">'\n'</span>));</span>
<span class="line" id="L505">}</span>
<span class="line" id="L506"></span>
<span class="line" id="L507"><span class="tok-kw">test</span> <span class="tok-str">&quot;Reader.readUntilDelimiter returns StreamTooLong, then bytes read until the delimiter&quot;</span> {</span>
<span class="line" id="L508">    <span class="tok-kw">var</span> buf: [<span class="tok-number">5</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L509">    <span class="tok-kw">var</span> fis = std.io.fixedBufferStream(<span class="tok-str">&quot;1234567\n&quot;</span>);</span>
<span class="line" id="L510">    <span class="tok-kw">const</span> reader = fis.reader();</span>
<span class="line" id="L511">    <span class="tok-kw">try</span> std.testing.expectError(<span class="tok-kw">error</span>.StreamTooLong, reader.readUntilDelimiter(&amp;buf, <span class="tok-str">'\n'</span>));</span>
<span class="line" id="L512">    <span class="tok-kw">try</span> std.testing.expectEqualStrings(<span class="tok-str">&quot;67&quot;</span>, <span class="tok-kw">try</span> reader.readUntilDelimiter(&amp;buf, <span class="tok-str">'\n'</span>));</span>
<span class="line" id="L513">}</span>
<span class="line" id="L514"></span>
<span class="line" id="L515"><span class="tok-kw">test</span> <span class="tok-str">&quot;Reader.readUntilDelimiter returns EndOfStream&quot;</span> {</span>
<span class="line" id="L516">    <span class="tok-kw">var</span> buf: [<span class="tok-number">5</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L517">    <span class="tok-kw">var</span> fis = std.io.fixedBufferStream(<span class="tok-str">&quot;&quot;</span>);</span>
<span class="line" id="L518">    <span class="tok-kw">const</span> reader = fis.reader();</span>
<span class="line" id="L519">    <span class="tok-kw">try</span> std.testing.expectError(<span class="tok-kw">error</span>.EndOfStream, reader.readUntilDelimiter(&amp;buf, <span class="tok-str">'\n'</span>));</span>
<span class="line" id="L520">}</span>
<span class="line" id="L521"></span>
<span class="line" id="L522"><span class="tok-kw">test</span> <span class="tok-str">&quot;Reader.readUntilDelimiter returns bytes read until delimiter, then EndOfStream&quot;</span> {</span>
<span class="line" id="L523">    <span class="tok-kw">var</span> buf: [<span class="tok-number">5</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L524">    <span class="tok-kw">var</span> fis = std.io.fixedBufferStream(<span class="tok-str">&quot;1234\n&quot;</span>);</span>
<span class="line" id="L525">    <span class="tok-kw">const</span> reader = fis.reader();</span>
<span class="line" id="L526">    <span class="tok-kw">try</span> std.testing.expectEqualStrings(<span class="tok-str">&quot;1234&quot;</span>, <span class="tok-kw">try</span> reader.readUntilDelimiter(&amp;buf, <span class="tok-str">'\n'</span>));</span>
<span class="line" id="L527">    <span class="tok-kw">try</span> std.testing.expectError(<span class="tok-kw">error</span>.EndOfStream, reader.readUntilDelimiter(&amp;buf, <span class="tok-str">'\n'</span>));</span>
<span class="line" id="L528">}</span>
<span class="line" id="L529"></span>
<span class="line" id="L530"><span class="tok-kw">test</span> <span class="tok-str">&quot;Reader.readUntilDelimiter returns EndOfStream&quot;</span> {</span>
<span class="line" id="L531">    <span class="tok-kw">var</span> buf: [<span class="tok-number">5</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L532">    <span class="tok-kw">var</span> fis = std.io.fixedBufferStream(<span class="tok-str">&quot;1234&quot;</span>);</span>
<span class="line" id="L533">    <span class="tok-kw">const</span> reader = fis.reader();</span>
<span class="line" id="L534">    <span class="tok-kw">try</span> std.testing.expectError(<span class="tok-kw">error</span>.EndOfStream, reader.readUntilDelimiter(&amp;buf, <span class="tok-str">'\n'</span>));</span>
<span class="line" id="L535">}</span>
<span class="line" id="L536"></span>
<span class="line" id="L537"><span class="tok-kw">test</span> <span class="tok-str">&quot;Reader.readUntilDelimiter returns StreamTooLong, then EndOfStream&quot;</span> {</span>
<span class="line" id="L538">    <span class="tok-kw">var</span> buf: [<span class="tok-number">5</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L539">    <span class="tok-kw">var</span> fis = std.io.fixedBufferStream(<span class="tok-str">&quot;12345&quot;</span>);</span>
<span class="line" id="L540">    <span class="tok-kw">const</span> reader = fis.reader();</span>
<span class="line" id="L541">    <span class="tok-kw">try</span> std.testing.expectError(<span class="tok-kw">error</span>.StreamTooLong, reader.readUntilDelimiter(&amp;buf, <span class="tok-str">'\n'</span>));</span>
<span class="line" id="L542">    <span class="tok-kw">try</span> std.testing.expectError(<span class="tok-kw">error</span>.EndOfStream, reader.readUntilDelimiter(&amp;buf, <span class="tok-str">'\n'</span>));</span>
<span class="line" id="L543">}</span>
<span class="line" id="L544"></span>
<span class="line" id="L545"><span class="tok-kw">test</span> <span class="tok-str">&quot;Reader.readUntilDelimiter writes all bytes read to the output buffer&quot;</span> {</span>
<span class="line" id="L546">    <span class="tok-kw">var</span> buf: [<span class="tok-number">5</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L547">    <span class="tok-kw">var</span> fis = std.io.fixedBufferStream(<span class="tok-str">&quot;0000\n12345&quot;</span>);</span>
<span class="line" id="L548">    <span class="tok-kw">const</span> reader = fis.reader();</span>
<span class="line" id="L549">    _ = <span class="tok-kw">try</span> reader.readUntilDelimiter(&amp;buf, <span class="tok-str">'\n'</span>);</span>
<span class="line" id="L550">    <span class="tok-kw">try</span> std.testing.expectEqualStrings(<span class="tok-str">&quot;0000\n&quot;</span>, &amp;buf);</span>
<span class="line" id="L551">    <span class="tok-kw">try</span> std.testing.expectError(<span class="tok-kw">error</span>.StreamTooLong, reader.readUntilDelimiter(&amp;buf, <span class="tok-str">'\n'</span>));</span>
<span class="line" id="L552">    <span class="tok-kw">try</span> std.testing.expectEqualStrings(<span class="tok-str">&quot;12345&quot;</span>, &amp;buf);</span>
<span class="line" id="L553">}</span>
<span class="line" id="L554"></span>
<span class="line" id="L555"><span class="tok-kw">test</span> <span class="tok-str">&quot;Reader.readUntilDelimiterOrEofAlloc returns ArrayLists with bytes read until the delimiter, then EndOfStream&quot;</span> {</span>
<span class="line" id="L556">    <span class="tok-kw">const</span> a = std.testing.allocator;</span>
<span class="line" id="L557"></span>
<span class="line" id="L558">    <span class="tok-kw">var</span> fis = std.io.fixedBufferStream(<span class="tok-str">&quot;0000\n1234\n&quot;</span>);</span>
<span class="line" id="L559">    <span class="tok-kw">const</span> reader = fis.reader();</span>
<span class="line" id="L560"></span>
<span class="line" id="L561">    {</span>
<span class="line" id="L562">        <span class="tok-kw">var</span> result = (<span class="tok-kw">try</span> reader.readUntilDelimiterOrEofAlloc(a, <span class="tok-str">'\n'</span>, <span class="tok-number">5</span>)).?;</span>
<span class="line" id="L563">        <span class="tok-kw">defer</span> a.free(result);</span>
<span class="line" id="L564">        <span class="tok-kw">try</span> std.testing.expectEqualStrings(<span class="tok-str">&quot;0000&quot;</span>, result);</span>
<span class="line" id="L565">    }</span>
<span class="line" id="L566"></span>
<span class="line" id="L567">    {</span>
<span class="line" id="L568">        <span class="tok-kw">var</span> result = (<span class="tok-kw">try</span> reader.readUntilDelimiterOrEofAlloc(a, <span class="tok-str">'\n'</span>, <span class="tok-number">5</span>)).?;</span>
<span class="line" id="L569">        <span class="tok-kw">defer</span> a.free(result);</span>
<span class="line" id="L570">        <span class="tok-kw">try</span> std.testing.expectEqualStrings(<span class="tok-str">&quot;1234&quot;</span>, result);</span>
<span class="line" id="L571">    }</span>
<span class="line" id="L572"></span>
<span class="line" id="L573">    <span class="tok-kw">try</span> std.testing.expect((<span class="tok-kw">try</span> reader.readUntilDelimiterOrEofAlloc(a, <span class="tok-str">'\n'</span>, <span class="tok-number">5</span>)) == <span class="tok-null">null</span>);</span>
<span class="line" id="L574">}</span>
<span class="line" id="L575"></span>
<span class="line" id="L576"><span class="tok-kw">test</span> <span class="tok-str">&quot;Reader.readUntilDelimiterOrEofAlloc returns an empty ArrayList&quot;</span> {</span>
<span class="line" id="L577">    <span class="tok-kw">const</span> a = std.testing.allocator;</span>
<span class="line" id="L578"></span>
<span class="line" id="L579">    <span class="tok-kw">var</span> fis = std.io.fixedBufferStream(<span class="tok-str">&quot;\n&quot;</span>);</span>
<span class="line" id="L580">    <span class="tok-kw">const</span> reader = fis.reader();</span>
<span class="line" id="L581"></span>
<span class="line" id="L582">    {</span>
<span class="line" id="L583">        <span class="tok-kw">var</span> result = (<span class="tok-kw">try</span> reader.readUntilDelimiterOrEofAlloc(a, <span class="tok-str">'\n'</span>, <span class="tok-number">5</span>)).?;</span>
<span class="line" id="L584">        <span class="tok-kw">defer</span> a.free(result);</span>
<span class="line" id="L585">        <span class="tok-kw">try</span> std.testing.expectEqualStrings(<span class="tok-str">&quot;&quot;</span>, result);</span>
<span class="line" id="L586">    }</span>
<span class="line" id="L587">}</span>
<span class="line" id="L588"></span>
<span class="line" id="L589"><span class="tok-kw">test</span> <span class="tok-str">&quot;Reader.readUntilDelimiterOrEofAlloc returns StreamTooLong, then an ArrayList with bytes read until the delimiter&quot;</span> {</span>
<span class="line" id="L590">    <span class="tok-kw">const</span> a = std.testing.allocator;</span>
<span class="line" id="L591"></span>
<span class="line" id="L592">    <span class="tok-kw">var</span> fis = std.io.fixedBufferStream(<span class="tok-str">&quot;1234567\n&quot;</span>);</span>
<span class="line" id="L593">    <span class="tok-kw">const</span> reader = fis.reader();</span>
<span class="line" id="L594"></span>
<span class="line" id="L595">    <span class="tok-kw">try</span> std.testing.expectError(<span class="tok-kw">error</span>.StreamTooLong, reader.readUntilDelimiterOrEofAlloc(a, <span class="tok-str">'\n'</span>, <span class="tok-number">5</span>));</span>
<span class="line" id="L596"></span>
<span class="line" id="L597">    <span class="tok-kw">var</span> result = (<span class="tok-kw">try</span> reader.readUntilDelimiterOrEofAlloc(a, <span class="tok-str">'\n'</span>, <span class="tok-number">5</span>)).?;</span>
<span class="line" id="L598">    <span class="tok-kw">defer</span> a.free(result);</span>
<span class="line" id="L599">    <span class="tok-kw">try</span> std.testing.expectEqualStrings(<span class="tok-str">&quot;67&quot;</span>, result);</span>
<span class="line" id="L600">}</span>
<span class="line" id="L601"></span>
<span class="line" id="L602"><span class="tok-kw">test</span> <span class="tok-str">&quot;Reader.readUntilDelimiterOrEof returns bytes read until the delimiter&quot;</span> {</span>
<span class="line" id="L603">    <span class="tok-kw">var</span> buf: [<span class="tok-number">5</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L604">    <span class="tok-kw">var</span> fis = std.io.fixedBufferStream(<span class="tok-str">&quot;0000\n1234\n&quot;</span>);</span>
<span class="line" id="L605">    <span class="tok-kw">const</span> reader = fis.reader();</span>
<span class="line" id="L606">    <span class="tok-kw">try</span> std.testing.expectEqualStrings(<span class="tok-str">&quot;0000&quot;</span>, (<span class="tok-kw">try</span> reader.readUntilDelimiterOrEof(&amp;buf, <span class="tok-str">'\n'</span>)).?);</span>
<span class="line" id="L607">    <span class="tok-kw">try</span> std.testing.expectEqualStrings(<span class="tok-str">&quot;1234&quot;</span>, (<span class="tok-kw">try</span> reader.readUntilDelimiterOrEof(&amp;buf, <span class="tok-str">'\n'</span>)).?);</span>
<span class="line" id="L608">}</span>
<span class="line" id="L609"></span>
<span class="line" id="L610"><span class="tok-kw">test</span> <span class="tok-str">&quot;Reader.readUntilDelimiterOrEof returns an empty string&quot;</span> {</span>
<span class="line" id="L611">    <span class="tok-kw">var</span> buf: [<span class="tok-number">5</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L612">    <span class="tok-kw">var</span> fis = std.io.fixedBufferStream(<span class="tok-str">&quot;\n&quot;</span>);</span>
<span class="line" id="L613">    <span class="tok-kw">const</span> reader = fis.reader();</span>
<span class="line" id="L614">    <span class="tok-kw">try</span> std.testing.expectEqualStrings(<span class="tok-str">&quot;&quot;</span>, (<span class="tok-kw">try</span> reader.readUntilDelimiterOrEof(&amp;buf, <span class="tok-str">'\n'</span>)).?);</span>
<span class="line" id="L615">}</span>
<span class="line" id="L616"></span>
<span class="line" id="L617"><span class="tok-kw">test</span> <span class="tok-str">&quot;Reader.readUntilDelimiterOrEof returns StreamTooLong, then an empty string&quot;</span> {</span>
<span class="line" id="L618">    <span class="tok-kw">var</span> buf: [<span class="tok-number">5</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L619">    <span class="tok-kw">var</span> fis = std.io.fixedBufferStream(<span class="tok-str">&quot;12345\n&quot;</span>);</span>
<span class="line" id="L620">    <span class="tok-kw">const</span> reader = fis.reader();</span>
<span class="line" id="L621">    <span class="tok-kw">try</span> std.testing.expectError(<span class="tok-kw">error</span>.StreamTooLong, reader.readUntilDelimiterOrEof(&amp;buf, <span class="tok-str">'\n'</span>));</span>
<span class="line" id="L622">    <span class="tok-kw">try</span> std.testing.expectEqualStrings(<span class="tok-str">&quot;&quot;</span>, (<span class="tok-kw">try</span> reader.readUntilDelimiterOrEof(&amp;buf, <span class="tok-str">'\n'</span>)).?);</span>
<span class="line" id="L623">}</span>
<span class="line" id="L624"></span>
<span class="line" id="L625"><span class="tok-kw">test</span> <span class="tok-str">&quot;Reader.readUntilDelimiterOrEof returns StreamTooLong, then bytes read until the delimiter&quot;</span> {</span>
<span class="line" id="L626">    <span class="tok-kw">var</span> buf: [<span class="tok-number">5</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L627">    <span class="tok-kw">var</span> fis = std.io.fixedBufferStream(<span class="tok-str">&quot;1234567\n&quot;</span>);</span>
<span class="line" id="L628">    <span class="tok-kw">const</span> reader = fis.reader();</span>
<span class="line" id="L629">    <span class="tok-kw">try</span> std.testing.expectError(<span class="tok-kw">error</span>.StreamTooLong, reader.readUntilDelimiterOrEof(&amp;buf, <span class="tok-str">'\n'</span>));</span>
<span class="line" id="L630">    <span class="tok-kw">try</span> std.testing.expectEqualStrings(<span class="tok-str">&quot;67&quot;</span>, (<span class="tok-kw">try</span> reader.readUntilDelimiterOrEof(&amp;buf, <span class="tok-str">'\n'</span>)).?);</span>
<span class="line" id="L631">}</span>
<span class="line" id="L632"></span>
<span class="line" id="L633"><span class="tok-kw">test</span> <span class="tok-str">&quot;Reader.readUntilDelimiterOrEof returns null&quot;</span> {</span>
<span class="line" id="L634">    <span class="tok-kw">var</span> buf: [<span class="tok-number">5</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L635">    <span class="tok-kw">var</span> fis = std.io.fixedBufferStream(<span class="tok-str">&quot;&quot;</span>);</span>
<span class="line" id="L636">    <span class="tok-kw">const</span> reader = fis.reader();</span>
<span class="line" id="L637">    <span class="tok-kw">try</span> std.testing.expect((<span class="tok-kw">try</span> reader.readUntilDelimiterOrEof(&amp;buf, <span class="tok-str">'\n'</span>)) == <span class="tok-null">null</span>);</span>
<span class="line" id="L638">}</span>
<span class="line" id="L639"></span>
<span class="line" id="L640"><span class="tok-kw">test</span> <span class="tok-str">&quot;Reader.readUntilDelimiterOrEof returns bytes read until delimiter, then null&quot;</span> {</span>
<span class="line" id="L641">    <span class="tok-kw">var</span> buf: [<span class="tok-number">5</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L642">    <span class="tok-kw">var</span> fis = std.io.fixedBufferStream(<span class="tok-str">&quot;1234\n&quot;</span>);</span>
<span class="line" id="L643">    <span class="tok-kw">const</span> reader = fis.reader();</span>
<span class="line" id="L644">    <span class="tok-kw">try</span> std.testing.expectEqualStrings(<span class="tok-str">&quot;1234&quot;</span>, (<span class="tok-kw">try</span> reader.readUntilDelimiterOrEof(&amp;buf, <span class="tok-str">'\n'</span>)).?);</span>
<span class="line" id="L645">    <span class="tok-kw">try</span> std.testing.expect((<span class="tok-kw">try</span> reader.readUntilDelimiterOrEof(&amp;buf, <span class="tok-str">'\n'</span>)) == <span class="tok-null">null</span>);</span>
<span class="line" id="L646">}</span>
<span class="line" id="L647"></span>
<span class="line" id="L648"><span class="tok-kw">test</span> <span class="tok-str">&quot;Reader.readUntilDelimiterOrEof returns bytes read until end-of-stream&quot;</span> {</span>
<span class="line" id="L649">    <span class="tok-kw">var</span> buf: [<span class="tok-number">5</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L650">    <span class="tok-kw">var</span> fis = std.io.fixedBufferStream(<span class="tok-str">&quot;1234&quot;</span>);</span>
<span class="line" id="L651">    <span class="tok-kw">const</span> reader = fis.reader();</span>
<span class="line" id="L652">    <span class="tok-kw">try</span> std.testing.expectEqualStrings(<span class="tok-str">&quot;1234&quot;</span>, (<span class="tok-kw">try</span> reader.readUntilDelimiterOrEof(&amp;buf, <span class="tok-str">'\n'</span>)).?);</span>
<span class="line" id="L653">}</span>
<span class="line" id="L654"></span>
<span class="line" id="L655"><span class="tok-kw">test</span> <span class="tok-str">&quot;Reader.readUntilDelimiterOrEof returns StreamTooLong, then bytes read until end-of-stream&quot;</span> {</span>
<span class="line" id="L656">    <span class="tok-kw">var</span> buf: [<span class="tok-number">5</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L657">    <span class="tok-kw">var</span> fis = std.io.fixedBufferStream(<span class="tok-str">&quot;1234567&quot;</span>);</span>
<span class="line" id="L658">    <span class="tok-kw">const</span> reader = fis.reader();</span>
<span class="line" id="L659">    <span class="tok-kw">try</span> std.testing.expectError(<span class="tok-kw">error</span>.StreamTooLong, reader.readUntilDelimiterOrEof(&amp;buf, <span class="tok-str">'\n'</span>));</span>
<span class="line" id="L660">    <span class="tok-kw">try</span> std.testing.expectEqualStrings(<span class="tok-str">&quot;67&quot;</span>, (<span class="tok-kw">try</span> reader.readUntilDelimiterOrEof(&amp;buf, <span class="tok-str">'\n'</span>)).?);</span>
<span class="line" id="L661">}</span>
<span class="line" id="L662"></span>
<span class="line" id="L663"><span class="tok-kw">test</span> <span class="tok-str">&quot;Reader.readUntilDelimiterOrEof writes all bytes read to the output buffer&quot;</span> {</span>
<span class="line" id="L664">    <span class="tok-kw">var</span> buf: [<span class="tok-number">5</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L665">    <span class="tok-kw">var</span> fis = std.io.fixedBufferStream(<span class="tok-str">&quot;0000\n12345&quot;</span>);</span>
<span class="line" id="L666">    <span class="tok-kw">const</span> reader = fis.reader();</span>
<span class="line" id="L667">    _ = <span class="tok-kw">try</span> reader.readUntilDelimiterOrEof(&amp;buf, <span class="tok-str">'\n'</span>);</span>
<span class="line" id="L668">    <span class="tok-kw">try</span> std.testing.expectEqualStrings(<span class="tok-str">&quot;0000\n&quot;</span>, &amp;buf);</span>
<span class="line" id="L669">    <span class="tok-kw">try</span> std.testing.expectError(<span class="tok-kw">error</span>.StreamTooLong, reader.readUntilDelimiterOrEof(&amp;buf, <span class="tok-str">'\n'</span>));</span>
<span class="line" id="L670">    <span class="tok-kw">try</span> std.testing.expectEqualStrings(<span class="tok-str">&quot;12345&quot;</span>, &amp;buf);</span>
<span class="line" id="L671">}</span>
<span class="line" id="L672"></span>
</code></pre></body>
</html>