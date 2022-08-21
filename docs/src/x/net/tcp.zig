<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">    <title>x/net/tcp.zig - source view</title>
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
<pre><code><span class="line" id="L1"><span class="tok-kw">const</span> std = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;../../std.zig&quot;</span>);</span>
<span class="line" id="L2"><span class="tok-kw">const</span> builtin = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;builtin&quot;</span>);</span>
<span class="line" id="L3"></span>
<span class="line" id="L4"><span class="tok-kw">const</span> io = std.io;</span>
<span class="line" id="L5"><span class="tok-kw">const</span> os = std.os;</span>
<span class="line" id="L6"><span class="tok-kw">const</span> ip = std.x.net.ip;</span>
<span class="line" id="L7"></span>
<span class="line" id="L8"><span class="tok-kw">const</span> fmt = std.fmt;</span>
<span class="line" id="L9"><span class="tok-kw">const</span> mem = std.mem;</span>
<span class="line" id="L10"><span class="tok-kw">const</span> testing = std.testing;</span>
<span class="line" id="L11"><span class="tok-kw">const</span> native_os = builtin.os;</span>
<span class="line" id="L12"></span>
<span class="line" id="L13"><span class="tok-kw">const</span> IPv4 = std.x.os.IPv4;</span>
<span class="line" id="L14"><span class="tok-kw">const</span> IPv6 = std.x.os.IPv6;</span>
<span class="line" id="L15"><span class="tok-kw">const</span> Socket = std.x.os.Socket;</span>
<span class="line" id="L16"><span class="tok-kw">const</span> Buffer = std.x.os.Buffer;</span>
<span class="line" id="L17"></span>
<span class="line" id="L18"><span class="tok-comment">/// A generic TCP socket abstraction.</span></span>
<span class="line" id="L19"><span class="tok-kw">const</span> tcp = <span class="tok-builtin">@This</span>();</span>
<span class="line" id="L20"></span>
<span class="line" id="L21"><span class="tok-comment">/// A TCP client-address pair.</span></span>
<span class="line" id="L22"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> Connection = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L23">    client: tcp.Client,</span>
<span class="line" id="L24">    address: ip.Address,</span>
<span class="line" id="L25"></span>
<span class="line" id="L26">    <span class="tok-comment">/// Enclose a TCP client and address into a client-address pair.</span></span>
<span class="line" id="L27">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">from</span>(conn: Socket.Connection) tcp.Connection {</span>
<span class="line" id="L28">        <span class="tok-kw">return</span> .{</span>
<span class="line" id="L29">            .client = tcp.Client.from(conn.socket),</span>
<span class="line" id="L30">            .address = ip.Address.from(conn.address),</span>
<span class="line" id="L31">        };</span>
<span class="line" id="L32">    }</span>
<span class="line" id="L33"></span>
<span class="line" id="L34">    <span class="tok-comment">/// Unravel a TCP client-address pair into a socket-address pair.</span></span>
<span class="line" id="L35">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">into</span>(self: tcp.Connection) Socket.Connection {</span>
<span class="line" id="L36">        <span class="tok-kw">return</span> .{</span>
<span class="line" id="L37">            .socket = self.client.socket,</span>
<span class="line" id="L38">            .address = self.address.into(),</span>
<span class="line" id="L39">        };</span>
<span class="line" id="L40">    }</span>
<span class="line" id="L41"></span>
<span class="line" id="L42">    <span class="tok-comment">/// Closes the underlying client of the connection.</span></span>
<span class="line" id="L43">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">deinit</span>(self: tcp.Connection) <span class="tok-type">void</span> {</span>
<span class="line" id="L44">        self.client.deinit();</span>
<span class="line" id="L45">    }</span>
<span class="line" id="L46">};</span>
<span class="line" id="L47"></span>
<span class="line" id="L48"><span class="tok-comment">/// Possible domains that a TCP client/listener may operate over.</span></span>
<span class="line" id="L49"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> Domain = <span class="tok-kw">enum</span>(<span class="tok-type">u16</span>) {</span>
<span class="line" id="L50">    ip = os.AF.INET,</span>
<span class="line" id="L51">    ipv6 = os.AF.INET6,</span>
<span class="line" id="L52">};</span>
<span class="line" id="L53"></span>
<span class="line" id="L54"><span class="tok-comment">/// A TCP client.</span></span>
<span class="line" id="L55"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> Client = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L56">    socket: Socket,</span>
<span class="line" id="L57"></span>
<span class="line" id="L58">    <span class="tok-comment">/// Implements `std.io.Reader`.</span></span>
<span class="line" id="L59">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> Reader = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L60">        client: Client,</span>
<span class="line" id="L61">        flags: <span class="tok-type">u32</span>,</span>
<span class="line" id="L62"></span>
<span class="line" id="L63">        <span class="tok-comment">/// Implements `readFn` for `std.io.Reader`.</span></span>
<span class="line" id="L64">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">read</span>(self: Client.Reader, buffer: []<span class="tok-type">u8</span>) !<span class="tok-type">usize</span> {</span>
<span class="line" id="L65">            <span class="tok-kw">return</span> self.client.read(buffer, self.flags);</span>
<span class="line" id="L66">        }</span>
<span class="line" id="L67">    };</span>
<span class="line" id="L68"></span>
<span class="line" id="L69">    <span class="tok-comment">/// Implements `std.io.Writer`.</span></span>
<span class="line" id="L70">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> Writer = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L71">        client: Client,</span>
<span class="line" id="L72">        flags: <span class="tok-type">u32</span>,</span>
<span class="line" id="L73"></span>
<span class="line" id="L74">        <span class="tok-comment">/// Implements `writeFn` for `std.io.Writer`.</span></span>
<span class="line" id="L75">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">write</span>(self: Client.Writer, buffer: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) !<span class="tok-type">usize</span> {</span>
<span class="line" id="L76">            <span class="tok-kw">return</span> self.client.write(buffer, self.flags);</span>
<span class="line" id="L77">        }</span>
<span class="line" id="L78">    };</span>
<span class="line" id="L79"></span>
<span class="line" id="L80">    <span class="tok-comment">/// Opens a new client.</span></span>
<span class="line" id="L81">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">init</span>(domain: tcp.Domain, flags: std.enums.EnumFieldStruct(Socket.InitFlags, <span class="tok-type">bool</span>, <span class="tok-null">false</span>)) !Client {</span>
<span class="line" id="L82">        <span class="tok-kw">return</span> Client{</span>
<span class="line" id="L83">            .socket = <span class="tok-kw">try</span> Socket.init(</span>
<span class="line" id="L84">                <span class="tok-builtin">@enumToInt</span>(domain),</span>
<span class="line" id="L85">                os.SOCK.STREAM,</span>
<span class="line" id="L86">                os.IPPROTO.TCP,</span>
<span class="line" id="L87">                flags,</span>
<span class="line" id="L88">            ),</span>
<span class="line" id="L89">        };</span>
<span class="line" id="L90">    }</span>
<span class="line" id="L91"></span>
<span class="line" id="L92">    <span class="tok-comment">/// Enclose a TCP client over an existing socket.</span></span>
<span class="line" id="L93">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">from</span>(socket: Socket) Client {</span>
<span class="line" id="L94">        <span class="tok-kw">return</span> Client{ .socket = socket };</span>
<span class="line" id="L95">    }</span>
<span class="line" id="L96"></span>
<span class="line" id="L97">    <span class="tok-comment">/// Closes the client.</span></span>
<span class="line" id="L98">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">deinit</span>(self: Client) <span class="tok-type">void</span> {</span>
<span class="line" id="L99">        self.socket.deinit();</span>
<span class="line" id="L100">    }</span>
<span class="line" id="L101"></span>
<span class="line" id="L102">    <span class="tok-comment">/// Shutdown either the read side, write side, or all sides of the client's underlying socket.</span></span>
<span class="line" id="L103">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">shutdown</span>(self: Client, how: os.ShutdownHow) !<span class="tok-type">void</span> {</span>
<span class="line" id="L104">        <span class="tok-kw">return</span> self.socket.shutdown(how);</span>
<span class="line" id="L105">    }</span>
<span class="line" id="L106"></span>
<span class="line" id="L107">    <span class="tok-comment">/// Have the client attempt to the connect to an address.</span></span>
<span class="line" id="L108">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">connect</span>(self: Client, address: ip.Address) !<span class="tok-type">void</span> {</span>
<span class="line" id="L109">        <span class="tok-kw">return</span> self.socket.connect(address.into());</span>
<span class="line" id="L110">    }</span>
<span class="line" id="L111"></span>
<span class="line" id="L112">    <span class="tok-comment">/// Extracts the error set of a function.</span></span>
<span class="line" id="L113">    <span class="tok-comment">/// TODO: remove after Socket.{read, write} error unions are well-defined across different platforms</span></span>
<span class="line" id="L114">    <span class="tok-kw">fn</span> <span class="tok-fn">ErrorSetOf</span>(<span class="tok-kw">comptime</span> Function: <span class="tok-kw">anytype</span>) <span class="tok-type">type</span> {</span>
<span class="line" id="L115">        <span class="tok-kw">return</span> <span class="tok-builtin">@typeInfo</span>(<span class="tok-builtin">@typeInfo</span>(<span class="tok-builtin">@TypeOf</span>(Function)).Fn.return_type.?).ErrorUnion.error_set;</span>
<span class="line" id="L116">    }</span>
<span class="line" id="L117"></span>
<span class="line" id="L118">    <span class="tok-comment">/// Wrap `tcp.Client` into `std.io.Reader`.</span></span>
<span class="line" id="L119">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">reader</span>(self: Client, flags: <span class="tok-type">u32</span>) io.Reader(Client.Reader, ErrorSetOf(Client.Reader.read), Client.Reader.read) {</span>
<span class="line" id="L120">        <span class="tok-kw">return</span> .{ .context = .{ .client = self, .flags = flags } };</span>
<span class="line" id="L121">    }</span>
<span class="line" id="L122"></span>
<span class="line" id="L123">    <span class="tok-comment">/// Wrap `tcp.Client` into `std.io.Writer`.</span></span>
<span class="line" id="L124">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">writer</span>(self: Client, flags: <span class="tok-type">u32</span>) io.Writer(Client.Writer, ErrorSetOf(Client.Writer.write), Client.Writer.write) {</span>
<span class="line" id="L125">        <span class="tok-kw">return</span> .{ .context = .{ .client = self, .flags = flags } };</span>
<span class="line" id="L126">    }</span>
<span class="line" id="L127"></span>
<span class="line" id="L128">    <span class="tok-comment">/// Read data from the socket into the buffer provided with a set of flags</span></span>
<span class="line" id="L129">    <span class="tok-comment">/// specified. It returns the number of bytes read into the buffer provided.</span></span>
<span class="line" id="L130">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">read</span>(self: Client, buf: []<span class="tok-type">u8</span>, flags: <span class="tok-type">u32</span>) !<span class="tok-type">usize</span> {</span>
<span class="line" id="L131">        <span class="tok-kw">return</span> self.socket.read(buf, flags);</span>
<span class="line" id="L132">    }</span>
<span class="line" id="L133"></span>
<span class="line" id="L134">    <span class="tok-comment">/// Write a buffer of data provided to the socket with a set of flags specified.</span></span>
<span class="line" id="L135">    <span class="tok-comment">/// It returns the number of bytes that are written to the socket.</span></span>
<span class="line" id="L136">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">write</span>(self: Client, buf: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, flags: <span class="tok-type">u32</span>) !<span class="tok-type">usize</span> {</span>
<span class="line" id="L137">        <span class="tok-kw">return</span> self.socket.write(buf, flags);</span>
<span class="line" id="L138">    }</span>
<span class="line" id="L139"></span>
<span class="line" id="L140">    <span class="tok-comment">/// Writes multiple I/O vectors with a prepended message header to the socket</span></span>
<span class="line" id="L141">    <span class="tok-comment">/// with a set of flags specified. It returns the number of bytes that are</span></span>
<span class="line" id="L142">    <span class="tok-comment">/// written to the socket.</span></span>
<span class="line" id="L143">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">writeMessage</span>(self: Client, msg: Socket.Message, flags: <span class="tok-type">u32</span>) !<span class="tok-type">usize</span> {</span>
<span class="line" id="L144">        <span class="tok-kw">return</span> self.socket.writeMessage(msg, flags);</span>
<span class="line" id="L145">    }</span>
<span class="line" id="L146"></span>
<span class="line" id="L147">    <span class="tok-comment">/// Read multiple I/O vectors with a prepended message header from the socket</span></span>
<span class="line" id="L148">    <span class="tok-comment">/// with a set of flags specified. It returns the number of bytes that were</span></span>
<span class="line" id="L149">    <span class="tok-comment">/// read into the buffer provided.</span></span>
<span class="line" id="L150">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">readMessage</span>(self: Client, msg: *Socket.Message, flags: <span class="tok-type">u32</span>) !<span class="tok-type">usize</span> {</span>
<span class="line" id="L151">        <span class="tok-kw">return</span> self.socket.readMessage(msg, flags);</span>
<span class="line" id="L152">    }</span>
<span class="line" id="L153"></span>
<span class="line" id="L154">    <span class="tok-comment">/// Query and return the latest cached error on the client's underlying socket.</span></span>
<span class="line" id="L155">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">getError</span>(self: Client) !<span class="tok-type">void</span> {</span>
<span class="line" id="L156">        <span class="tok-kw">return</span> self.socket.getError();</span>
<span class="line" id="L157">    }</span>
<span class="line" id="L158"></span>
<span class="line" id="L159">    <span class="tok-comment">/// Query the read buffer size of the client's underlying socket.</span></span>
<span class="line" id="L160">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">getReadBufferSize</span>(self: Client) !<span class="tok-type">u32</span> {</span>
<span class="line" id="L161">        <span class="tok-kw">return</span> self.socket.getReadBufferSize();</span>
<span class="line" id="L162">    }</span>
<span class="line" id="L163"></span>
<span class="line" id="L164">    <span class="tok-comment">/// Query the write buffer size of the client's underlying socket.</span></span>
<span class="line" id="L165">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">getWriteBufferSize</span>(self: Client) !<span class="tok-type">u32</span> {</span>
<span class="line" id="L166">        <span class="tok-kw">return</span> self.socket.getWriteBufferSize();</span>
<span class="line" id="L167">    }</span>
<span class="line" id="L168"></span>
<span class="line" id="L169">    <span class="tok-comment">/// Query the address that the client's socket is locally bounded to.</span></span>
<span class="line" id="L170">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">getLocalAddress</span>(self: Client) !ip.Address {</span>
<span class="line" id="L171">        <span class="tok-kw">return</span> ip.Address.from(<span class="tok-kw">try</span> self.socket.getLocalAddress());</span>
<span class="line" id="L172">    }</span>
<span class="line" id="L173"></span>
<span class="line" id="L174">    <span class="tok-comment">/// Query the address that the socket is connected to.</span></span>
<span class="line" id="L175">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">getRemoteAddress</span>(self: Client) !ip.Address {</span>
<span class="line" id="L176">        <span class="tok-kw">return</span> ip.Address.from(<span class="tok-kw">try</span> self.socket.getRemoteAddress());</span>
<span class="line" id="L177">    }</span>
<span class="line" id="L178"></span>
<span class="line" id="L179">    <span class="tok-comment">/// Have close() or shutdown() syscalls block until all queued messages in the client have been successfully</span></span>
<span class="line" id="L180">    <span class="tok-comment">/// sent, or if the timeout specified in seconds has been reached. It returns `error.UnsupportedSocketOption`</span></span>
<span class="line" id="L181">    <span class="tok-comment">/// if the host does not support the option for a socket to linger around up until a timeout specified in</span></span>
<span class="line" id="L182">    <span class="tok-comment">/// seconds.</span></span>
<span class="line" id="L183">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">setLinger</span>(self: Client, timeout_seconds: ?<span class="tok-type">u16</span>) !<span class="tok-type">void</span> {</span>
<span class="line" id="L184">        <span class="tok-kw">return</span> self.socket.setLinger(timeout_seconds);</span>
<span class="line" id="L185">    }</span>
<span class="line" id="L186"></span>
<span class="line" id="L187">    <span class="tok-comment">/// Have keep-alive messages be sent periodically. The timing in which keep-alive messages are sent are</span></span>
<span class="line" id="L188">    <span class="tok-comment">/// dependant on operating system settings. It returns `error.UnsupportedSocketOption` if the host does</span></span>
<span class="line" id="L189">    <span class="tok-comment">/// not support periodically sending keep-alive messages on connection-oriented sockets.</span></span>
<span class="line" id="L190">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">setKeepAlive</span>(self: Client, enabled: <span class="tok-type">bool</span>) !<span class="tok-type">void</span> {</span>
<span class="line" id="L191">        <span class="tok-kw">return</span> self.socket.setKeepAlive(enabled);</span>
<span class="line" id="L192">    }</span>
<span class="line" id="L193"></span>
<span class="line" id="L194">    <span class="tok-comment">/// Disable Nagle's algorithm on a TCP socket. It returns `error.UnsupportedSocketOption` if</span></span>
<span class="line" id="L195">    <span class="tok-comment">/// the host does not support sockets disabling Nagle's algorithm.</span></span>
<span class="line" id="L196">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">setNoDelay</span>(self: Client, enabled: <span class="tok-type">bool</span>) !<span class="tok-type">void</span> {</span>
<span class="line" id="L197">        <span class="tok-kw">if</span> (<span class="tok-builtin">@hasDecl</span>(os.TCP, <span class="tok-str">&quot;NODELAY&quot;</span>)) {</span>
<span class="line" id="L198">            <span class="tok-kw">const</span> bytes = mem.asBytes(&amp;<span class="tok-builtin">@as</span>(<span class="tok-type">usize</span>, <span class="tok-builtin">@boolToInt</span>(enabled)));</span>
<span class="line" id="L199">            <span class="tok-kw">return</span> self.socket.setOption(os.IPPROTO.TCP, os.TCP.NODELAY, bytes);</span>
<span class="line" id="L200">        }</span>
<span class="line" id="L201">        <span class="tok-kw">return</span> <span class="tok-kw">error</span>.UnsupportedSocketOption;</span>
<span class="line" id="L202">    }</span>
<span class="line" id="L203"></span>
<span class="line" id="L204">    <span class="tok-comment">/// Enables TCP Quick ACK on a TCP socket to immediately send rather than delay ACKs when necessary. It returns</span></span>
<span class="line" id="L205">    <span class="tok-comment">/// `error.UnsupportedSocketOption` if the host does not support TCP Quick ACK.</span></span>
<span class="line" id="L206">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">setQuickACK</span>(self: Client, enabled: <span class="tok-type">bool</span>) !<span class="tok-type">void</span> {</span>
<span class="line" id="L207">        <span class="tok-kw">if</span> (<span class="tok-builtin">@hasDecl</span>(os.TCP, <span class="tok-str">&quot;QUICKACK&quot;</span>)) {</span>
<span class="line" id="L208">            <span class="tok-kw">return</span> self.socket.setOption(os.IPPROTO.TCP, os.TCP.QUICKACK, mem.asBytes(&amp;<span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-builtin">@boolToInt</span>(enabled))));</span>
<span class="line" id="L209">        }</span>
<span class="line" id="L210">        <span class="tok-kw">return</span> <span class="tok-kw">error</span>.UnsupportedSocketOption;</span>
<span class="line" id="L211">    }</span>
<span class="line" id="L212"></span>
<span class="line" id="L213">    <span class="tok-comment">/// Set the write buffer size of the socket.</span></span>
<span class="line" id="L214">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">setWriteBufferSize</span>(self: Client, size: <span class="tok-type">u32</span>) !<span class="tok-type">void</span> {</span>
<span class="line" id="L215">        <span class="tok-kw">return</span> self.socket.setWriteBufferSize(size);</span>
<span class="line" id="L216">    }</span>
<span class="line" id="L217"></span>
<span class="line" id="L218">    <span class="tok-comment">/// Set the read buffer size of the socket.</span></span>
<span class="line" id="L219">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">setReadBufferSize</span>(self: Client, size: <span class="tok-type">u32</span>) !<span class="tok-type">void</span> {</span>
<span class="line" id="L220">        <span class="tok-kw">return</span> self.socket.setReadBufferSize(size);</span>
<span class="line" id="L221">    }</span>
<span class="line" id="L222"></span>
<span class="line" id="L223">    <span class="tok-comment">/// Set a timeout on the socket that is to occur if no messages are successfully written</span></span>
<span class="line" id="L224">    <span class="tok-comment">/// to its bound destination after a specified number of milliseconds. A subsequent write</span></span>
<span class="line" id="L225">    <span class="tok-comment">/// to the socket will thereafter return `error.WouldBlock` should the timeout be exceeded.</span></span>
<span class="line" id="L226">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">setWriteTimeout</span>(self: Client, milliseconds: <span class="tok-type">u32</span>) !<span class="tok-type">void</span> {</span>
<span class="line" id="L227">        <span class="tok-kw">return</span> self.socket.setWriteTimeout(milliseconds);</span>
<span class="line" id="L228">    }</span>
<span class="line" id="L229"></span>
<span class="line" id="L230">    <span class="tok-comment">/// Set a timeout on the socket that is to occur if no messages are successfully read</span></span>
<span class="line" id="L231">    <span class="tok-comment">/// from its bound destination after a specified number of milliseconds. A subsequent</span></span>
<span class="line" id="L232">    <span class="tok-comment">/// read from the socket will thereafter return `error.WouldBlock` should the timeout be</span></span>
<span class="line" id="L233">    <span class="tok-comment">/// exceeded.</span></span>
<span class="line" id="L234">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">setReadTimeout</span>(self: Client, milliseconds: <span class="tok-type">u32</span>) !<span class="tok-type">void</span> {</span>
<span class="line" id="L235">        <span class="tok-kw">return</span> self.socket.setReadTimeout(milliseconds);</span>
<span class="line" id="L236">    }</span>
<span class="line" id="L237">};</span>
<span class="line" id="L238"></span>
<span class="line" id="L239"><span class="tok-comment">/// A TCP listener.</span></span>
<span class="line" id="L240"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> Listener = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L241">    socket: Socket,</span>
<span class="line" id="L242"></span>
<span class="line" id="L243">    <span class="tok-comment">/// Opens a new listener.</span></span>
<span class="line" id="L244">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">init</span>(domain: tcp.Domain, flags: std.enums.EnumFieldStruct(Socket.InitFlags, <span class="tok-type">bool</span>, <span class="tok-null">false</span>)) !Listener {</span>
<span class="line" id="L245">        <span class="tok-kw">return</span> Listener{</span>
<span class="line" id="L246">            .socket = <span class="tok-kw">try</span> Socket.init(</span>
<span class="line" id="L247">                <span class="tok-builtin">@enumToInt</span>(domain),</span>
<span class="line" id="L248">                os.SOCK.STREAM,</span>
<span class="line" id="L249">                os.IPPROTO.TCP,</span>
<span class="line" id="L250">                flags,</span>
<span class="line" id="L251">            ),</span>
<span class="line" id="L252">        };</span>
<span class="line" id="L253">    }</span>
<span class="line" id="L254"></span>
<span class="line" id="L255">    <span class="tok-comment">/// Closes the listener.</span></span>
<span class="line" id="L256">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">deinit</span>(self: Listener) <span class="tok-type">void</span> {</span>
<span class="line" id="L257">        self.socket.deinit();</span>
<span class="line" id="L258">    }</span>
<span class="line" id="L259"></span>
<span class="line" id="L260">    <span class="tok-comment">/// Shuts down the underlying listener's socket. The next subsequent call, or</span></span>
<span class="line" id="L261">    <span class="tok-comment">/// a current pending call to accept() after shutdown is called will return</span></span>
<span class="line" id="L262">    <span class="tok-comment">/// an error.</span></span>
<span class="line" id="L263">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">shutdown</span>(self: Listener) !<span class="tok-type">void</span> {</span>
<span class="line" id="L264">        <span class="tok-kw">return</span> self.socket.shutdown(.recv);</span>
<span class="line" id="L265">    }</span>
<span class="line" id="L266"></span>
<span class="line" id="L267">    <span class="tok-comment">/// Binds the listener's socket to an address.</span></span>
<span class="line" id="L268">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">bind</span>(self: Listener, address: ip.Address) !<span class="tok-type">void</span> {</span>
<span class="line" id="L269">        <span class="tok-kw">return</span> self.socket.bind(address.into());</span>
<span class="line" id="L270">    }</span>
<span class="line" id="L271"></span>
<span class="line" id="L272">    <span class="tok-comment">/// Start listening for incoming connections.</span></span>
<span class="line" id="L273">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">listen</span>(self: Listener, max_backlog_size: <span class="tok-type">u31</span>) !<span class="tok-type">void</span> {</span>
<span class="line" id="L274">        <span class="tok-kw">return</span> self.socket.listen(max_backlog_size);</span>
<span class="line" id="L275">    }</span>
<span class="line" id="L276"></span>
<span class="line" id="L277">    <span class="tok-comment">/// Accept a pending incoming connection queued to the kernel backlog</span></span>
<span class="line" id="L278">    <span class="tok-comment">/// of the listener's socket.</span></span>
<span class="line" id="L279">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">accept</span>(self: Listener, flags: std.enums.EnumFieldStruct(Socket.InitFlags, <span class="tok-type">bool</span>, <span class="tok-null">false</span>)) !tcp.Connection {</span>
<span class="line" id="L280">        <span class="tok-kw">return</span> tcp.Connection.from(<span class="tok-kw">try</span> self.socket.accept(flags));</span>
<span class="line" id="L281">    }</span>
<span class="line" id="L282"></span>
<span class="line" id="L283">    <span class="tok-comment">/// Query and return the latest cached error on the listener's underlying socket.</span></span>
<span class="line" id="L284">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">getError</span>(self: Client) !<span class="tok-type">void</span> {</span>
<span class="line" id="L285">        <span class="tok-kw">return</span> self.socket.getError();</span>
<span class="line" id="L286">    }</span>
<span class="line" id="L287"></span>
<span class="line" id="L288">    <span class="tok-comment">/// Query the address that the listener's socket is locally bounded to.</span></span>
<span class="line" id="L289">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">getLocalAddress</span>(self: Listener) !ip.Address {</span>
<span class="line" id="L290">        <span class="tok-kw">return</span> ip.Address.from(<span class="tok-kw">try</span> self.socket.getLocalAddress());</span>
<span class="line" id="L291">    }</span>
<span class="line" id="L292"></span>
<span class="line" id="L293">    <span class="tok-comment">/// Allow multiple sockets on the same host to listen on the same address. It returns `error.UnsupportedSocketOption` if</span></span>
<span class="line" id="L294">    <span class="tok-comment">/// the host does not support sockets listening the same address.</span></span>
<span class="line" id="L295">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">setReuseAddress</span>(self: Listener, enabled: <span class="tok-type">bool</span>) !<span class="tok-type">void</span> {</span>
<span class="line" id="L296">        <span class="tok-kw">return</span> self.socket.setReuseAddress(enabled);</span>
<span class="line" id="L297">    }</span>
<span class="line" id="L298"></span>
<span class="line" id="L299">    <span class="tok-comment">/// Allow multiple sockets on the same host to listen on the same port. It returns `error.UnsupportedSocketOption` if</span></span>
<span class="line" id="L300">    <span class="tok-comment">/// the host does not supports sockets listening on the same port.</span></span>
<span class="line" id="L301">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">setReusePort</span>(self: Listener, enabled: <span class="tok-type">bool</span>) !<span class="tok-type">void</span> {</span>
<span class="line" id="L302">        <span class="tok-kw">return</span> self.socket.setReusePort(enabled);</span>
<span class="line" id="L303">    }</span>
<span class="line" id="L304"></span>
<span class="line" id="L305">    <span class="tok-comment">/// Enables TCP Fast Open (RFC 7413) on a TCP socket. It returns `error.UnsupportedSocketOption` if the host does not</span></span>
<span class="line" id="L306">    <span class="tok-comment">/// support TCP Fast Open.</span></span>
<span class="line" id="L307">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">setFastOpen</span>(self: Listener, enabled: <span class="tok-type">bool</span>) !<span class="tok-type">void</span> {</span>
<span class="line" id="L308">        <span class="tok-kw">if</span> (<span class="tok-builtin">@hasDecl</span>(os.TCP, <span class="tok-str">&quot;FASTOPEN&quot;</span>)) {</span>
<span class="line" id="L309">            <span class="tok-kw">return</span> self.socket.setOption(os.IPPROTO.TCP, os.TCP.FASTOPEN, mem.asBytes(&amp;<span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-builtin">@boolToInt</span>(enabled))));</span>
<span class="line" id="L310">        }</span>
<span class="line" id="L311">        <span class="tok-kw">return</span> <span class="tok-kw">error</span>.UnsupportedSocketOption;</span>
<span class="line" id="L312">    }</span>
<span class="line" id="L313"></span>
<span class="line" id="L314">    <span class="tok-comment">/// Set a timeout on the listener that is to occur if no new incoming connections come in</span></span>
<span class="line" id="L315">    <span class="tok-comment">/// after a specified number of milliseconds. A subsequent accept call to the listener</span></span>
<span class="line" id="L316">    <span class="tok-comment">/// will thereafter return `error.WouldBlock` should the timeout be exceeded.</span></span>
<span class="line" id="L317">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">setAcceptTimeout</span>(self: Listener, milliseconds: <span class="tok-type">usize</span>) !<span class="tok-type">void</span> {</span>
<span class="line" id="L318">        <span class="tok-kw">return</span> self.socket.setReadTimeout(milliseconds);</span>
<span class="line" id="L319">    }</span>
<span class="line" id="L320">};</span>
<span class="line" id="L321"></span>
<span class="line" id="L322"><span class="tok-kw">test</span> <span class="tok-str">&quot;tcp: create client/listener pair&quot;</span> {</span>
<span class="line" id="L323">    <span class="tok-kw">if</span> (native_os.tag == .wasi) <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SkipZigTest;</span>
<span class="line" id="L324"></span>
<span class="line" id="L325">    <span class="tok-kw">const</span> listener = <span class="tok-kw">try</span> tcp.Listener.init(.ip, .{ .close_on_exec = <span class="tok-null">true</span> });</span>
<span class="line" id="L326">    <span class="tok-kw">defer</span> listener.deinit();</span>
<span class="line" id="L327"></span>
<span class="line" id="L328">    <span class="tok-kw">try</span> listener.bind(ip.Address.initIPv4(IPv4.unspecified, <span class="tok-number">0</span>));</span>
<span class="line" id="L329">    <span class="tok-kw">try</span> listener.listen(<span class="tok-number">128</span>);</span>
<span class="line" id="L330"></span>
<span class="line" id="L331">    <span class="tok-kw">var</span> binded_address = <span class="tok-kw">try</span> listener.getLocalAddress();</span>
<span class="line" id="L332">    <span class="tok-kw">switch</span> (binded_address) {</span>
<span class="line" id="L333">        .ipv4 =&gt; |*ipv4| ipv4.host = IPv4.localhost,</span>
<span class="line" id="L334">        .ipv6 =&gt; |*ipv6| ipv6.host = IPv6.localhost,</span>
<span class="line" id="L335">    }</span>
<span class="line" id="L336"></span>
<span class="line" id="L337">    <span class="tok-kw">const</span> client = <span class="tok-kw">try</span> tcp.Client.init(.ip, .{ .close_on_exec = <span class="tok-null">true</span> });</span>
<span class="line" id="L338">    <span class="tok-kw">defer</span> client.deinit();</span>
<span class="line" id="L339"></span>
<span class="line" id="L340">    <span class="tok-kw">try</span> client.connect(binded_address);</span>
<span class="line" id="L341"></span>
<span class="line" id="L342">    <span class="tok-kw">const</span> conn = <span class="tok-kw">try</span> listener.accept(.{ .close_on_exec = <span class="tok-null">true</span> });</span>
<span class="line" id="L343">    <span class="tok-kw">defer</span> conn.deinit();</span>
<span class="line" id="L344">}</span>
<span class="line" id="L345"></span>
<span class="line" id="L346"><span class="tok-kw">test</span> <span class="tok-str">&quot;tcp/client: 1ms read timeout&quot;</span> {</span>
<span class="line" id="L347">    <span class="tok-kw">if</span> (native_os.tag == .wasi) <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SkipZigTest;</span>
<span class="line" id="L348"></span>
<span class="line" id="L349">    <span class="tok-kw">const</span> listener = <span class="tok-kw">try</span> tcp.Listener.init(.ip, .{ .close_on_exec = <span class="tok-null">true</span> });</span>
<span class="line" id="L350">    <span class="tok-kw">defer</span> listener.deinit();</span>
<span class="line" id="L351"></span>
<span class="line" id="L352">    <span class="tok-kw">try</span> listener.bind(ip.Address.initIPv4(IPv4.unspecified, <span class="tok-number">0</span>));</span>
<span class="line" id="L353">    <span class="tok-kw">try</span> listener.listen(<span class="tok-number">128</span>);</span>
<span class="line" id="L354"></span>
<span class="line" id="L355">    <span class="tok-kw">var</span> binded_address = <span class="tok-kw">try</span> listener.getLocalAddress();</span>
<span class="line" id="L356">    <span class="tok-kw">switch</span> (binded_address) {</span>
<span class="line" id="L357">        .ipv4 =&gt; |*ipv4| ipv4.host = IPv4.localhost,</span>
<span class="line" id="L358">        .ipv6 =&gt; |*ipv6| ipv6.host = IPv6.localhost,</span>
<span class="line" id="L359">    }</span>
<span class="line" id="L360"></span>
<span class="line" id="L361">    <span class="tok-kw">const</span> client = <span class="tok-kw">try</span> tcp.Client.init(.ip, .{ .close_on_exec = <span class="tok-null">true</span> });</span>
<span class="line" id="L362">    <span class="tok-kw">defer</span> client.deinit();</span>
<span class="line" id="L363"></span>
<span class="line" id="L364">    <span class="tok-kw">try</span> client.connect(binded_address);</span>
<span class="line" id="L365">    <span class="tok-kw">try</span> client.setReadTimeout(<span class="tok-number">1</span>);</span>
<span class="line" id="L366"></span>
<span class="line" id="L367">    <span class="tok-kw">const</span> conn = <span class="tok-kw">try</span> listener.accept(.{ .close_on_exec = <span class="tok-null">true</span> });</span>
<span class="line" id="L368">    <span class="tok-kw">defer</span> conn.deinit();</span>
<span class="line" id="L369"></span>
<span class="line" id="L370">    <span class="tok-kw">var</span> buf: [<span class="tok-number">1</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L371">    <span class="tok-kw">try</span> testing.expectError(<span class="tok-kw">error</span>.WouldBlock, client.reader(<span class="tok-number">0</span>).read(&amp;buf));</span>
<span class="line" id="L372">}</span>
<span class="line" id="L373"></span>
<span class="line" id="L374"><span class="tok-kw">test</span> <span class="tok-str">&quot;tcp/client: read and write multiple vectors&quot;</span> {</span>
<span class="line" id="L375">    <span class="tok-kw">if</span> (native_os.tag == .wasi) <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SkipZigTest;</span>
<span class="line" id="L376"></span>
<span class="line" id="L377">    <span class="tok-kw">const</span> listener = <span class="tok-kw">try</span> tcp.Listener.init(.ip, .{ .close_on_exec = <span class="tok-null">true</span> });</span>
<span class="line" id="L378">    <span class="tok-kw">defer</span> listener.deinit();</span>
<span class="line" id="L379"></span>
<span class="line" id="L380">    <span class="tok-kw">try</span> listener.bind(ip.Address.initIPv4(IPv4.unspecified, <span class="tok-number">0</span>));</span>
<span class="line" id="L381">    <span class="tok-kw">try</span> listener.listen(<span class="tok-number">128</span>);</span>
<span class="line" id="L382"></span>
<span class="line" id="L383">    <span class="tok-kw">var</span> binded_address = <span class="tok-kw">try</span> listener.getLocalAddress();</span>
<span class="line" id="L384">    <span class="tok-kw">switch</span> (binded_address) {</span>
<span class="line" id="L385">        .ipv4 =&gt; |*ipv4| ipv4.host = IPv4.localhost,</span>
<span class="line" id="L386">        .ipv6 =&gt; |*ipv6| ipv6.host = IPv6.localhost,</span>
<span class="line" id="L387">    }</span>
<span class="line" id="L388"></span>
<span class="line" id="L389">    <span class="tok-kw">const</span> client = <span class="tok-kw">try</span> tcp.Client.init(.ip, .{ .close_on_exec = <span class="tok-null">true</span> });</span>
<span class="line" id="L390">    <span class="tok-kw">defer</span> client.deinit();</span>
<span class="line" id="L391"></span>
<span class="line" id="L392">    <span class="tok-kw">try</span> client.connect(binded_address);</span>
<span class="line" id="L393"></span>
<span class="line" id="L394">    <span class="tok-kw">const</span> conn = <span class="tok-kw">try</span> listener.accept(.{ .close_on_exec = <span class="tok-null">true</span> });</span>
<span class="line" id="L395">    <span class="tok-kw">defer</span> conn.deinit();</span>
<span class="line" id="L396"></span>
<span class="line" id="L397">    <span class="tok-kw">const</span> message = <span class="tok-str">&quot;hello world&quot;</span>;</span>
<span class="line" id="L398">    _ = <span class="tok-kw">try</span> conn.client.writeMessage(Socket.Message.fromBuffers(&amp;[_]Buffer{</span>
<span class="line" id="L399">        Buffer.from(message[<span class="tok-number">0</span> .. message.len / <span class="tok-number">2</span>]),</span>
<span class="line" id="L400">        Buffer.from(message[message.len / <span class="tok-number">2</span> ..]),</span>
<span class="line" id="L401">    }), <span class="tok-number">0</span>);</span>
<span class="line" id="L402"></span>
<span class="line" id="L403">    <span class="tok-kw">var</span> buf: [message.len + <span class="tok-number">1</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L404">    <span class="tok-kw">var</span> msg = Socket.Message.fromBuffers(&amp;[_]Buffer{</span>
<span class="line" id="L405">        Buffer.from(buf[<span class="tok-number">0</span> .. message.len / <span class="tok-number">2</span>]),</span>
<span class="line" id="L406">        Buffer.from(buf[message.len / <span class="tok-number">2</span> ..]),</span>
<span class="line" id="L407">    });</span>
<span class="line" id="L408">    _ = <span class="tok-kw">try</span> client.readMessage(&amp;msg, <span class="tok-number">0</span>);</span>
<span class="line" id="L409"></span>
<span class="line" id="L410">    <span class="tok-kw">try</span> testing.expectEqualStrings(message, buf[<span class="tok-number">0</span>..message.len]);</span>
<span class="line" id="L411">}</span>
<span class="line" id="L412"></span>
<span class="line" id="L413"><span class="tok-kw">test</span> <span class="tok-str">&quot;tcp/listener: bind to unspecified ipv4 address&quot;</span> {</span>
<span class="line" id="L414">    <span class="tok-kw">if</span> (native_os.tag == .wasi) <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SkipZigTest;</span>
<span class="line" id="L415"></span>
<span class="line" id="L416">    <span class="tok-kw">const</span> listener = <span class="tok-kw">try</span> tcp.Listener.init(.ip, .{ .close_on_exec = <span class="tok-null">true</span> });</span>
<span class="line" id="L417">    <span class="tok-kw">defer</span> listener.deinit();</span>
<span class="line" id="L418"></span>
<span class="line" id="L419">    <span class="tok-kw">try</span> listener.bind(ip.Address.initIPv4(IPv4.unspecified, <span class="tok-number">0</span>));</span>
<span class="line" id="L420">    <span class="tok-kw">try</span> listener.listen(<span class="tok-number">128</span>);</span>
<span class="line" id="L421"></span>
<span class="line" id="L422">    <span class="tok-kw">const</span> address = <span class="tok-kw">try</span> listener.getLocalAddress();</span>
<span class="line" id="L423">    <span class="tok-kw">try</span> testing.expect(address == .ipv4);</span>
<span class="line" id="L424">}</span>
<span class="line" id="L425"></span>
<span class="line" id="L426"><span class="tok-kw">test</span> <span class="tok-str">&quot;tcp/listener: bind to unspecified ipv6 address&quot;</span> {</span>
<span class="line" id="L427">    <span class="tok-kw">if</span> (native_os.tag == .wasi) <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SkipZigTest;</span>
<span class="line" id="L428"></span>
<span class="line" id="L429">    <span class="tok-kw">const</span> listener = <span class="tok-kw">try</span> tcp.Listener.init(.ipv6, .{ .close_on_exec = <span class="tok-null">true</span> });</span>
<span class="line" id="L430">    <span class="tok-kw">defer</span> listener.deinit();</span>
<span class="line" id="L431"></span>
<span class="line" id="L432">    <span class="tok-kw">try</span> listener.bind(ip.Address.initIPv6(IPv6.unspecified, <span class="tok-number">0</span>));</span>
<span class="line" id="L433">    <span class="tok-kw">try</span> listener.listen(<span class="tok-number">128</span>);</span>
<span class="line" id="L434"></span>
<span class="line" id="L435">    <span class="tok-kw">const</span> address = <span class="tok-kw">try</span> listener.getLocalAddress();</span>
<span class="line" id="L436">    <span class="tok-kw">try</span> testing.expect(address == .ipv6);</span>
<span class="line" id="L437">}</span>
<span class="line" id="L438"></span>
</code></pre></body>
</html>