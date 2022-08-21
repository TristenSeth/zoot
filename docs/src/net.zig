<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">    <title>net.zig - source view</title>
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
<pre><code><span class="line" id="L1"><span class="tok-kw">const</span> std = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;std.zig&quot;</span>);</span>
<span class="line" id="L2"><span class="tok-kw">const</span> builtin = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;builtin&quot;</span>);</span>
<span class="line" id="L3"><span class="tok-kw">const</span> assert = std.debug.assert;</span>
<span class="line" id="L4"><span class="tok-kw">const</span> net = <span class="tok-builtin">@This</span>();</span>
<span class="line" id="L5"><span class="tok-kw">const</span> mem = std.mem;</span>
<span class="line" id="L6"><span class="tok-kw">const</span> os = std.os;</span>
<span class="line" id="L7"><span class="tok-kw">const</span> fs = std.fs;</span>
<span class="line" id="L8"><span class="tok-kw">const</span> io = std.io;</span>
<span class="line" id="L9"><span class="tok-kw">const</span> native_endian = builtin.target.cpu.arch.endian();</span>
<span class="line" id="L10"></span>
<span class="line" id="L11"><span class="tok-comment">// Windows 10 added support for unix sockets in build 17063, redstone 4 is the</span>
</span>
<span class="line" id="L12"><span class="tok-comment">// first release to support them.</span>
</span>
<span class="line" id="L13"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> has_unix_sockets = <span class="tok-builtin">@hasDecl</span>(os.sockaddr, <span class="tok-str">&quot;un&quot;</span>) <span class="tok-kw">and</span></span>
<span class="line" id="L14">    (builtin.target.os.tag != .windows <span class="tok-kw">or</span></span>
<span class="line" id="L15">    builtin.os.version_range.windows.isAtLeast(.win10_rs4) <span class="tok-kw">orelse</span> <span class="tok-null">false</span>);</span>
<span class="line" id="L16"></span>
<span class="line" id="L17"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> Address = <span class="tok-kw">extern</span> <span class="tok-kw">union</span> {</span>
<span class="line" id="L18">    any: os.sockaddr,</span>
<span class="line" id="L19">    in: Ip4Address,</span>
<span class="line" id="L20">    in6: Ip6Address,</span>
<span class="line" id="L21">    un: <span class="tok-kw">if</span> (has_unix_sockets) os.sockaddr.un <span class="tok-kw">else</span> <span class="tok-type">void</span>,</span>
<span class="line" id="L22"></span>
<span class="line" id="L23">    <span class="tok-comment">/// Parse the given IP address string into an Address value.</span></span>
<span class="line" id="L24">    <span class="tok-comment">/// It is recommended to use `resolveIp` instead, to handle</span></span>
<span class="line" id="L25">    <span class="tok-comment">/// IPv6 link-local unix addresses.</span></span>
<span class="line" id="L26">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">parseIp</span>(name: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, port: <span class="tok-type">u16</span>) !Address {</span>
<span class="line" id="L27">        <span class="tok-kw">if</span> (parseIp4(name, port)) |ip4| <span class="tok-kw">return</span> ip4 <span class="tok-kw">else</span> |err| <span class="tok-kw">switch</span> (err) {</span>
<span class="line" id="L28">            <span class="tok-kw">error</span>.Overflow,</span>
<span class="line" id="L29">            <span class="tok-kw">error</span>.InvalidEnd,</span>
<span class="line" id="L30">            <span class="tok-kw">error</span>.InvalidCharacter,</span>
<span class="line" id="L31">            <span class="tok-kw">error</span>.Incomplete,</span>
<span class="line" id="L32">            <span class="tok-kw">error</span>.NonCanonical,</span>
<span class="line" id="L33">            =&gt; {},</span>
<span class="line" id="L34">        }</span>
<span class="line" id="L35"></span>
<span class="line" id="L36">        <span class="tok-kw">if</span> (parseIp6(name, port)) |ip6| <span class="tok-kw">return</span> ip6 <span class="tok-kw">else</span> |err| <span class="tok-kw">switch</span> (err) {</span>
<span class="line" id="L37">            <span class="tok-kw">error</span>.Overflow,</span>
<span class="line" id="L38">            <span class="tok-kw">error</span>.InvalidEnd,</span>
<span class="line" id="L39">            <span class="tok-kw">error</span>.InvalidCharacter,</span>
<span class="line" id="L40">            <span class="tok-kw">error</span>.Incomplete,</span>
<span class="line" id="L41">            <span class="tok-kw">error</span>.InvalidIpv4Mapping,</span>
<span class="line" id="L42">            =&gt; {},</span>
<span class="line" id="L43">        }</span>
<span class="line" id="L44"></span>
<span class="line" id="L45">        <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InvalidIPAddressFormat;</span>
<span class="line" id="L46">    }</span>
<span class="line" id="L47"></span>
<span class="line" id="L48">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">resolveIp</span>(name: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, port: <span class="tok-type">u16</span>) !Address {</span>
<span class="line" id="L49">        <span class="tok-kw">if</span> (parseIp4(name, port)) |ip4| <span class="tok-kw">return</span> ip4 <span class="tok-kw">else</span> |err| <span class="tok-kw">switch</span> (err) {</span>
<span class="line" id="L50">            <span class="tok-kw">error</span>.Overflow,</span>
<span class="line" id="L51">            <span class="tok-kw">error</span>.InvalidEnd,</span>
<span class="line" id="L52">            <span class="tok-kw">error</span>.InvalidCharacter,</span>
<span class="line" id="L53">            <span class="tok-kw">error</span>.Incomplete,</span>
<span class="line" id="L54">            <span class="tok-kw">error</span>.NonCanonical,</span>
<span class="line" id="L55">            =&gt; {},</span>
<span class="line" id="L56">        }</span>
<span class="line" id="L57"></span>
<span class="line" id="L58">        <span class="tok-kw">if</span> (resolveIp6(name, port)) |ip6| <span class="tok-kw">return</span> ip6 <span class="tok-kw">else</span> |err| <span class="tok-kw">switch</span> (err) {</span>
<span class="line" id="L59">            <span class="tok-kw">error</span>.Overflow,</span>
<span class="line" id="L60">            <span class="tok-kw">error</span>.InvalidEnd,</span>
<span class="line" id="L61">            <span class="tok-kw">error</span>.InvalidCharacter,</span>
<span class="line" id="L62">            <span class="tok-kw">error</span>.Incomplete,</span>
<span class="line" id="L63">            <span class="tok-kw">error</span>.InvalidIpv4Mapping,</span>
<span class="line" id="L64">            =&gt; {},</span>
<span class="line" id="L65">            <span class="tok-kw">else</span> =&gt; <span class="tok-kw">return</span> err,</span>
<span class="line" id="L66">        }</span>
<span class="line" id="L67"></span>
<span class="line" id="L68">        <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InvalidIPAddressFormat;</span>
<span class="line" id="L69">    }</span>
<span class="line" id="L70"></span>
<span class="line" id="L71">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">parseExpectingFamily</span>(name: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, family: os.sa_family_t, port: <span class="tok-type">u16</span>) !Address {</span>
<span class="line" id="L72">        <span class="tok-kw">switch</span> (family) {</span>
<span class="line" id="L73">            os.AF.INET =&gt; <span class="tok-kw">return</span> parseIp4(name, port),</span>
<span class="line" id="L74">            os.AF.INET6 =&gt; <span class="tok-kw">return</span> parseIp6(name, port),</span>
<span class="line" id="L75">            os.AF.UNSPEC =&gt; <span class="tok-kw">return</span> parseIp(name, port),</span>
<span class="line" id="L76">            <span class="tok-kw">else</span> =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L77">        }</span>
<span class="line" id="L78">    }</span>
<span class="line" id="L79"></span>
<span class="line" id="L80">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">parseIp6</span>(buf: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, port: <span class="tok-type">u16</span>) !Address {</span>
<span class="line" id="L81">        <span class="tok-kw">return</span> Address{ .in6 = <span class="tok-kw">try</span> Ip6Address.parse(buf, port) };</span>
<span class="line" id="L82">    }</span>
<span class="line" id="L83"></span>
<span class="line" id="L84">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">resolveIp6</span>(buf: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, port: <span class="tok-type">u16</span>) !Address {</span>
<span class="line" id="L85">        <span class="tok-kw">return</span> Address{ .in6 = <span class="tok-kw">try</span> Ip6Address.resolve(buf, port) };</span>
<span class="line" id="L86">    }</span>
<span class="line" id="L87"></span>
<span class="line" id="L88">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">parseIp4</span>(buf: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, port: <span class="tok-type">u16</span>) !Address {</span>
<span class="line" id="L89">        <span class="tok-kw">return</span> Address{ .in = <span class="tok-kw">try</span> Ip4Address.parse(buf, port) };</span>
<span class="line" id="L90">    }</span>
<span class="line" id="L91"></span>
<span class="line" id="L92">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">initIp4</span>(addr: [<span class="tok-number">4</span>]<span class="tok-type">u8</span>, port: <span class="tok-type">u16</span>) Address {</span>
<span class="line" id="L93">        <span class="tok-kw">return</span> Address{ .in = Ip4Address.init(addr, port) };</span>
<span class="line" id="L94">    }</span>
<span class="line" id="L95"></span>
<span class="line" id="L96">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">initIp6</span>(addr: [<span class="tok-number">16</span>]<span class="tok-type">u8</span>, port: <span class="tok-type">u16</span>, flowinfo: <span class="tok-type">u32</span>, scope_id: <span class="tok-type">u32</span>) Address {</span>
<span class="line" id="L97">        <span class="tok-kw">return</span> Address{ .in6 = Ip6Address.init(addr, port, flowinfo, scope_id) };</span>
<span class="line" id="L98">    }</span>
<span class="line" id="L99"></span>
<span class="line" id="L100">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">initUnix</span>(path: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) !Address {</span>
<span class="line" id="L101">        <span class="tok-kw">var</span> sock_addr = os.sockaddr.un{</span>
<span class="line" id="L102">            .family = os.AF.UNIX,</span>
<span class="line" id="L103">            .path = <span class="tok-null">undefined</span>,</span>
<span class="line" id="L104">        };</span>
<span class="line" id="L105"></span>
<span class="line" id="L106">        <span class="tok-comment">// this enables us to have the proper length of the socket in getOsSockLen</span>
</span>
<span class="line" id="L107">        mem.set(<span class="tok-type">u8</span>, &amp;sock_addr.path, <span class="tok-number">0</span>);</span>
<span class="line" id="L108"></span>
<span class="line" id="L109">        <span class="tok-kw">if</span> (path.len &gt; sock_addr.path.len) <span class="tok-kw">return</span> <span class="tok-kw">error</span>.NameTooLong;</span>
<span class="line" id="L110">        mem.copy(<span class="tok-type">u8</span>, &amp;sock_addr.path, path);</span>
<span class="line" id="L111"></span>
<span class="line" id="L112">        <span class="tok-kw">return</span> Address{ .un = sock_addr };</span>
<span class="line" id="L113">    }</span>
<span class="line" id="L114"></span>
<span class="line" id="L115">    <span class="tok-comment">/// Returns the port in native endian.</span></span>
<span class="line" id="L116">    <span class="tok-comment">/// Asserts that the address is ip4 or ip6.</span></span>
<span class="line" id="L117">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">getPort</span>(self: Address) <span class="tok-type">u16</span> {</span>
<span class="line" id="L118">        <span class="tok-kw">return</span> <span class="tok-kw">switch</span> (self.any.family) {</span>
<span class="line" id="L119">            os.AF.INET =&gt; self.in.getPort(),</span>
<span class="line" id="L120">            os.AF.INET6 =&gt; self.in6.getPort(),</span>
<span class="line" id="L121">            <span class="tok-kw">else</span> =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L122">        };</span>
<span class="line" id="L123">    }</span>
<span class="line" id="L124"></span>
<span class="line" id="L125">    <span class="tok-comment">/// `port` is native-endian.</span></span>
<span class="line" id="L126">    <span class="tok-comment">/// Asserts that the address is ip4 or ip6.</span></span>
<span class="line" id="L127">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">setPort</span>(self: *Address, port: <span class="tok-type">u16</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L128">        <span class="tok-kw">switch</span> (self.any.family) {</span>
<span class="line" id="L129">            os.AF.INET =&gt; self.in.setPort(port),</span>
<span class="line" id="L130">            os.AF.INET6 =&gt; self.in6.setPort(port),</span>
<span class="line" id="L131">            <span class="tok-kw">else</span> =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L132">        }</span>
<span class="line" id="L133">    }</span>
<span class="line" id="L134"></span>
<span class="line" id="L135">    <span class="tok-comment">/// Asserts that `addr` is an IP address.</span></span>
<span class="line" id="L136">    <span class="tok-comment">/// This function will read past the end of the pointer, with a size depending</span></span>
<span class="line" id="L137">    <span class="tok-comment">/// on the address family.</span></span>
<span class="line" id="L138">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">initPosix</span>(addr: *<span class="tok-kw">align</span>(<span class="tok-number">4</span>) <span class="tok-kw">const</span> os.sockaddr) Address {</span>
<span class="line" id="L139">        <span class="tok-kw">switch</span> (addr.family) {</span>
<span class="line" id="L140">            os.AF.INET =&gt; <span class="tok-kw">return</span> Address{ .in = Ip4Address{ .sa = <span class="tok-builtin">@ptrCast</span>(*<span class="tok-kw">const</span> os.sockaddr.in, addr).* } },</span>
<span class="line" id="L141">            os.AF.INET6 =&gt; <span class="tok-kw">return</span> Address{ .in6 = Ip6Address{ .sa = <span class="tok-builtin">@ptrCast</span>(*<span class="tok-kw">const</span> os.sockaddr.in6, addr).* } },</span>
<span class="line" id="L142">            <span class="tok-kw">else</span> =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L143">        }</span>
<span class="line" id="L144">    }</span>
<span class="line" id="L145"></span>
<span class="line" id="L146">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">format</span>(</span>
<span class="line" id="L147">        self: Address,</span>
<span class="line" id="L148">        <span class="tok-kw">comptime</span> fmt: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L149">        options: std.fmt.FormatOptions,</span>
<span class="line" id="L150">        out_stream: <span class="tok-kw">anytype</span>,</span>
<span class="line" id="L151">    ) !<span class="tok-type">void</span> {</span>
<span class="line" id="L152">        <span class="tok-kw">switch</span> (self.any.family) {</span>
<span class="line" id="L153">            os.AF.INET =&gt; <span class="tok-kw">try</span> self.in.format(fmt, options, out_stream),</span>
<span class="line" id="L154">            os.AF.INET6 =&gt; <span class="tok-kw">try</span> self.in6.format(fmt, options, out_stream),</span>
<span class="line" id="L155">            os.AF.UNIX =&gt; {</span>
<span class="line" id="L156">                <span class="tok-kw">if</span> (!has_unix_sockets) {</span>
<span class="line" id="L157">                    <span class="tok-kw">unreachable</span>;</span>
<span class="line" id="L158">                }</span>
<span class="line" id="L159"></span>
<span class="line" id="L160">                <span class="tok-kw">try</span> std.fmt.format(out_stream, <span class="tok-str">&quot;{s}&quot;</span>, .{std.mem.sliceTo(&amp;self.un.path, <span class="tok-number">0</span>)});</span>
<span class="line" id="L161">            },</span>
<span class="line" id="L162">            <span class="tok-kw">else</span> =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L163">        }</span>
<span class="line" id="L164">    }</span>
<span class="line" id="L165"></span>
<span class="line" id="L166">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">eql</span>(a: Address, b: Address) <span class="tok-type">bool</span> {</span>
<span class="line" id="L167">        <span class="tok-kw">const</span> a_bytes = <span class="tok-builtin">@ptrCast</span>([*]<span class="tok-kw">const</span> <span class="tok-type">u8</span>, &amp;a.any)[<span class="tok-number">0</span>..a.getOsSockLen()];</span>
<span class="line" id="L168">        <span class="tok-kw">const</span> b_bytes = <span class="tok-builtin">@ptrCast</span>([*]<span class="tok-kw">const</span> <span class="tok-type">u8</span>, &amp;b.any)[<span class="tok-number">0</span>..b.getOsSockLen()];</span>
<span class="line" id="L169">        <span class="tok-kw">return</span> mem.eql(<span class="tok-type">u8</span>, a_bytes, b_bytes);</span>
<span class="line" id="L170">    }</span>
<span class="line" id="L171"></span>
<span class="line" id="L172">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">getOsSockLen</span>(self: Address) os.socklen_t {</span>
<span class="line" id="L173">        <span class="tok-kw">switch</span> (self.any.family) {</span>
<span class="line" id="L174">            os.AF.INET =&gt; <span class="tok-kw">return</span> self.in.getOsSockLen(),</span>
<span class="line" id="L175">            os.AF.INET6 =&gt; <span class="tok-kw">return</span> self.in6.getOsSockLen(),</span>
<span class="line" id="L176">            os.AF.UNIX =&gt; {</span>
<span class="line" id="L177">                <span class="tok-kw">if</span> (!has_unix_sockets) {</span>
<span class="line" id="L178">                    <span class="tok-kw">unreachable</span>;</span>
<span class="line" id="L179">                }</span>
<span class="line" id="L180"></span>
<span class="line" id="L181">                <span class="tok-kw">const</span> path_len = std.mem.len(std.meta.assumeSentinel(&amp;self.un.path, <span class="tok-number">0</span>));</span>
<span class="line" id="L182">                <span class="tok-kw">return</span> <span class="tok-builtin">@intCast</span>(os.socklen_t, <span class="tok-builtin">@sizeOf</span>(os.sockaddr.un) - self.un.path.len + path_len);</span>
<span class="line" id="L183">            },</span>
<span class="line" id="L184">            <span class="tok-kw">else</span> =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L185">        }</span>
<span class="line" id="L186">    }</span>
<span class="line" id="L187">};</span>
<span class="line" id="L188"></span>
<span class="line" id="L189"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> Ip4Address = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L190">    sa: os.sockaddr.in,</span>
<span class="line" id="L191"></span>
<span class="line" id="L192">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">parse</span>(buf: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, port: <span class="tok-type">u16</span>) !Ip4Address {</span>
<span class="line" id="L193">        <span class="tok-kw">var</span> result = Ip4Address{</span>
<span class="line" id="L194">            .sa = .{</span>
<span class="line" id="L195">                .port = mem.nativeToBig(<span class="tok-type">u16</span>, port),</span>
<span class="line" id="L196">                .addr = <span class="tok-null">undefined</span>,</span>
<span class="line" id="L197">            },</span>
<span class="line" id="L198">        };</span>
<span class="line" id="L199">        <span class="tok-kw">const</span> out_ptr = mem.asBytes(&amp;result.sa.addr);</span>
<span class="line" id="L200"></span>
<span class="line" id="L201">        <span class="tok-kw">var</span> x: <span class="tok-type">u8</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L202">        <span class="tok-kw">var</span> index: <span class="tok-type">u8</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L203">        <span class="tok-kw">var</span> saw_any_digits = <span class="tok-null">false</span>;</span>
<span class="line" id="L204">        <span class="tok-kw">var</span> has_zero_prefix = <span class="tok-null">false</span>;</span>
<span class="line" id="L205">        <span class="tok-kw">for</span> (buf) |c| {</span>
<span class="line" id="L206">            <span class="tok-kw">if</span> (c == <span class="tok-str">'.'</span>) {</span>
<span class="line" id="L207">                <span class="tok-kw">if</span> (!saw_any_digits) {</span>
<span class="line" id="L208">                    <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InvalidCharacter;</span>
<span class="line" id="L209">                }</span>
<span class="line" id="L210">                <span class="tok-kw">if</span> (index == <span class="tok-number">3</span>) {</span>
<span class="line" id="L211">                    <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InvalidEnd;</span>
<span class="line" id="L212">                }</span>
<span class="line" id="L213">                out_ptr[index] = x;</span>
<span class="line" id="L214">                index += <span class="tok-number">1</span>;</span>
<span class="line" id="L215">                x = <span class="tok-number">0</span>;</span>
<span class="line" id="L216">                saw_any_digits = <span class="tok-null">false</span>;</span>
<span class="line" id="L217">                has_zero_prefix = <span class="tok-null">false</span>;</span>
<span class="line" id="L218">            } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (c &gt;= <span class="tok-str">'0'</span> <span class="tok-kw">and</span> c &lt;= <span class="tok-str">'9'</span>) {</span>
<span class="line" id="L219">                <span class="tok-kw">if</span> (c == <span class="tok-str">'0'</span> <span class="tok-kw">and</span> !saw_any_digits) {</span>
<span class="line" id="L220">                    has_zero_prefix = <span class="tok-null">true</span>;</span>
<span class="line" id="L221">                } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (has_zero_prefix) {</span>
<span class="line" id="L222">                    <span class="tok-kw">return</span> <span class="tok-kw">error</span>.NonCanonical;</span>
<span class="line" id="L223">                }</span>
<span class="line" id="L224">                saw_any_digits = <span class="tok-null">true</span>;</span>
<span class="line" id="L225">                x = <span class="tok-kw">try</span> std.math.mul(<span class="tok-type">u8</span>, x, <span class="tok-number">10</span>);</span>
<span class="line" id="L226">                x = <span class="tok-kw">try</span> std.math.add(<span class="tok-type">u8</span>, x, c - <span class="tok-str">'0'</span>);</span>
<span class="line" id="L227">            } <span class="tok-kw">else</span> {</span>
<span class="line" id="L228">                <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InvalidCharacter;</span>
<span class="line" id="L229">            }</span>
<span class="line" id="L230">        }</span>
<span class="line" id="L231">        <span class="tok-kw">if</span> (index == <span class="tok-number">3</span> <span class="tok-kw">and</span> saw_any_digits) {</span>
<span class="line" id="L232">            out_ptr[index] = x;</span>
<span class="line" id="L233">            <span class="tok-kw">return</span> result;</span>
<span class="line" id="L234">        }</span>
<span class="line" id="L235"></span>
<span class="line" id="L236">        <span class="tok-kw">return</span> <span class="tok-kw">error</span>.Incomplete;</span>
<span class="line" id="L237">    }</span>
<span class="line" id="L238"></span>
<span class="line" id="L239">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">resolveIp</span>(name: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, port: <span class="tok-type">u16</span>) !Ip4Address {</span>
<span class="line" id="L240">        <span class="tok-kw">if</span> (parse(name, port)) |ip4| <span class="tok-kw">return</span> ip4 <span class="tok-kw">else</span> |err| <span class="tok-kw">switch</span> (err) {</span>
<span class="line" id="L241">            <span class="tok-kw">error</span>.Overflow,</span>
<span class="line" id="L242">            <span class="tok-kw">error</span>.InvalidEnd,</span>
<span class="line" id="L243">            <span class="tok-kw">error</span>.InvalidCharacter,</span>
<span class="line" id="L244">            <span class="tok-kw">error</span>.Incomplete,</span>
<span class="line" id="L245">            =&gt; {},</span>
<span class="line" id="L246">        }</span>
<span class="line" id="L247">        <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InvalidIPAddressFormat;</span>
<span class="line" id="L248">    }</span>
<span class="line" id="L249"></span>
<span class="line" id="L250">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">init</span>(addr: [<span class="tok-number">4</span>]<span class="tok-type">u8</span>, port: <span class="tok-type">u16</span>) Ip4Address {</span>
<span class="line" id="L251">        <span class="tok-kw">return</span> Ip4Address{</span>
<span class="line" id="L252">            .sa = os.sockaddr.in{</span>
<span class="line" id="L253">                .port = mem.nativeToBig(<span class="tok-type">u16</span>, port),</span>
<span class="line" id="L254">                .addr = <span class="tok-builtin">@ptrCast</span>(*<span class="tok-kw">align</span>(<span class="tok-number">1</span>) <span class="tok-kw">const</span> <span class="tok-type">u32</span>, &amp;addr).*,</span>
<span class="line" id="L255">            },</span>
<span class="line" id="L256">        };</span>
<span class="line" id="L257">    }</span>
<span class="line" id="L258"></span>
<span class="line" id="L259">    <span class="tok-comment">/// Returns the port in native endian.</span></span>
<span class="line" id="L260">    <span class="tok-comment">/// Asserts that the address is ip4 or ip6.</span></span>
<span class="line" id="L261">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">getPort</span>(self: Ip4Address) <span class="tok-type">u16</span> {</span>
<span class="line" id="L262">        <span class="tok-kw">return</span> mem.bigToNative(<span class="tok-type">u16</span>, self.sa.port);</span>
<span class="line" id="L263">    }</span>
<span class="line" id="L264"></span>
<span class="line" id="L265">    <span class="tok-comment">/// `port` is native-endian.</span></span>
<span class="line" id="L266">    <span class="tok-comment">/// Asserts that the address is ip4 or ip6.</span></span>
<span class="line" id="L267">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">setPort</span>(self: *Ip4Address, port: <span class="tok-type">u16</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L268">        self.sa.port = mem.nativeToBig(<span class="tok-type">u16</span>, port);</span>
<span class="line" id="L269">    }</span>
<span class="line" id="L270"></span>
<span class="line" id="L271">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">format</span>(</span>
<span class="line" id="L272">        self: Ip4Address,</span>
<span class="line" id="L273">        <span class="tok-kw">comptime</span> fmt: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L274">        options: std.fmt.FormatOptions,</span>
<span class="line" id="L275">        out_stream: <span class="tok-kw">anytype</span>,</span>
<span class="line" id="L276">    ) !<span class="tok-type">void</span> {</span>
<span class="line" id="L277">        _ = fmt;</span>
<span class="line" id="L278">        _ = options;</span>
<span class="line" id="L279">        <span class="tok-kw">const</span> bytes = <span class="tok-builtin">@ptrCast</span>(*<span class="tok-kw">const</span> [<span class="tok-number">4</span>]<span class="tok-type">u8</span>, &amp;self.sa.addr);</span>
<span class="line" id="L280">        <span class="tok-kw">try</span> std.fmt.format(out_stream, <span class="tok-str">&quot;{}.{}.{}.{}:{}&quot;</span>, .{</span>
<span class="line" id="L281">            bytes[<span class="tok-number">0</span>],</span>
<span class="line" id="L282">            bytes[<span class="tok-number">1</span>],</span>
<span class="line" id="L283">            bytes[<span class="tok-number">2</span>],</span>
<span class="line" id="L284">            bytes[<span class="tok-number">3</span>],</span>
<span class="line" id="L285">            self.getPort(),</span>
<span class="line" id="L286">        });</span>
<span class="line" id="L287">    }</span>
<span class="line" id="L288"></span>
<span class="line" id="L289">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">getOsSockLen</span>(self: Ip4Address) os.socklen_t {</span>
<span class="line" id="L290">        _ = self;</span>
<span class="line" id="L291">        <span class="tok-kw">return</span> <span class="tok-builtin">@sizeOf</span>(os.sockaddr.in);</span>
<span class="line" id="L292">    }</span>
<span class="line" id="L293">};</span>
<span class="line" id="L294"></span>
<span class="line" id="L295"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> Ip6Address = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L296">    sa: os.sockaddr.in6,</span>
<span class="line" id="L297"></span>
<span class="line" id="L298">    <span class="tok-comment">/// Parse a given IPv6 address string into an Address.</span></span>
<span class="line" id="L299">    <span class="tok-comment">/// Assumes the Scope ID of the address is fully numeric.</span></span>
<span class="line" id="L300">    <span class="tok-comment">/// For non-numeric addresses, see `resolveIp6`.</span></span>
<span class="line" id="L301">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">parse</span>(buf: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, port: <span class="tok-type">u16</span>) !Ip6Address {</span>
<span class="line" id="L302">        <span class="tok-kw">var</span> result = Ip6Address{</span>
<span class="line" id="L303">            .sa = os.sockaddr.in6{</span>
<span class="line" id="L304">                .scope_id = <span class="tok-number">0</span>,</span>
<span class="line" id="L305">                .port = mem.nativeToBig(<span class="tok-type">u16</span>, port),</span>
<span class="line" id="L306">                .flowinfo = <span class="tok-number">0</span>,</span>
<span class="line" id="L307">                .addr = <span class="tok-null">undefined</span>,</span>
<span class="line" id="L308">            },</span>
<span class="line" id="L309">        };</span>
<span class="line" id="L310">        <span class="tok-kw">var</span> ip_slice = result.sa.addr[<span class="tok-number">0</span>..];</span>
<span class="line" id="L311"></span>
<span class="line" id="L312">        <span class="tok-kw">var</span> tail: [<span class="tok-number">16</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L313"></span>
<span class="line" id="L314">        <span class="tok-kw">var</span> x: <span class="tok-type">u16</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L315">        <span class="tok-kw">var</span> saw_any_digits = <span class="tok-null">false</span>;</span>
<span class="line" id="L316">        <span class="tok-kw">var</span> index: <span class="tok-type">u8</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L317">        <span class="tok-kw">var</span> scope_id = <span class="tok-null">false</span>;</span>
<span class="line" id="L318">        <span class="tok-kw">var</span> abbrv = <span class="tok-null">false</span>;</span>
<span class="line" id="L319">        <span class="tok-kw">for</span> (buf) |c, i| {</span>
<span class="line" id="L320">            <span class="tok-kw">if</span> (scope_id) {</span>
<span class="line" id="L321">                <span class="tok-kw">if</span> (c &gt;= <span class="tok-str">'0'</span> <span class="tok-kw">and</span> c &lt;= <span class="tok-str">'9'</span>) {</span>
<span class="line" id="L322">                    <span class="tok-kw">const</span> digit = c - <span class="tok-str">'0'</span>;</span>
<span class="line" id="L323">                    <span class="tok-kw">if</span> (<span class="tok-builtin">@mulWithOverflow</span>(<span class="tok-type">u32</span>, result.sa.scope_id, <span class="tok-number">10</span>, &amp;result.sa.scope_id)) {</span>
<span class="line" id="L324">                        <span class="tok-kw">return</span> <span class="tok-kw">error</span>.Overflow;</span>
<span class="line" id="L325">                    }</span>
<span class="line" id="L326">                    <span class="tok-kw">if</span> (<span class="tok-builtin">@addWithOverflow</span>(<span class="tok-type">u32</span>, result.sa.scope_id, digit, &amp;result.sa.scope_id)) {</span>
<span class="line" id="L327">                        <span class="tok-kw">return</span> <span class="tok-kw">error</span>.Overflow;</span>
<span class="line" id="L328">                    }</span>
<span class="line" id="L329">                } <span class="tok-kw">else</span> {</span>
<span class="line" id="L330">                    <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InvalidCharacter;</span>
<span class="line" id="L331">                }</span>
<span class="line" id="L332">            } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (c == <span class="tok-str">':'</span>) {</span>
<span class="line" id="L333">                <span class="tok-kw">if</span> (!saw_any_digits) {</span>
<span class="line" id="L334">                    <span class="tok-kw">if</span> (abbrv) <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InvalidCharacter; <span class="tok-comment">// ':::'</span>
</span>
<span class="line" id="L335">                    <span class="tok-kw">if</span> (i != <span class="tok-number">0</span>) abbrv = <span class="tok-null">true</span>;</span>
<span class="line" id="L336">                    mem.set(<span class="tok-type">u8</span>, ip_slice[index..], <span class="tok-number">0</span>);</span>
<span class="line" id="L337">                    ip_slice = tail[<span class="tok-number">0</span>..];</span>
<span class="line" id="L338">                    index = <span class="tok-number">0</span>;</span>
<span class="line" id="L339">                    <span class="tok-kw">continue</span>;</span>
<span class="line" id="L340">                }</span>
<span class="line" id="L341">                <span class="tok-kw">if</span> (index == <span class="tok-number">14</span>) {</span>
<span class="line" id="L342">                    <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InvalidEnd;</span>
<span class="line" id="L343">                }</span>
<span class="line" id="L344">                ip_slice[index] = <span class="tok-builtin">@truncate</span>(<span class="tok-type">u8</span>, x &gt;&gt; <span class="tok-number">8</span>);</span>
<span class="line" id="L345">                index += <span class="tok-number">1</span>;</span>
<span class="line" id="L346">                ip_slice[index] = <span class="tok-builtin">@truncate</span>(<span class="tok-type">u8</span>, x);</span>
<span class="line" id="L347">                index += <span class="tok-number">1</span>;</span>
<span class="line" id="L348"></span>
<span class="line" id="L349">                x = <span class="tok-number">0</span>;</span>
<span class="line" id="L350">                saw_any_digits = <span class="tok-null">false</span>;</span>
<span class="line" id="L351">            } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (c == <span class="tok-str">'%'</span>) {</span>
<span class="line" id="L352">                <span class="tok-kw">if</span> (!saw_any_digits) {</span>
<span class="line" id="L353">                    <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InvalidCharacter;</span>
<span class="line" id="L354">                }</span>
<span class="line" id="L355">                scope_id = <span class="tok-null">true</span>;</span>
<span class="line" id="L356">                saw_any_digits = <span class="tok-null">false</span>;</span>
<span class="line" id="L357">            } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (c == <span class="tok-str">'.'</span>) {</span>
<span class="line" id="L358">                <span class="tok-kw">if</span> (!abbrv <span class="tok-kw">or</span> ip_slice[<span class="tok-number">0</span>] != <span class="tok-number">0xff</span> <span class="tok-kw">or</span> ip_slice[<span class="tok-number">1</span>] != <span class="tok-number">0xff</span>) {</span>
<span class="line" id="L359">                    <span class="tok-comment">// must start with '::ffff:'</span>
</span>
<span class="line" id="L360">                    <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InvalidIpv4Mapping;</span>
<span class="line" id="L361">                }</span>
<span class="line" id="L362">                <span class="tok-kw">const</span> start_index = mem.lastIndexOfScalar(<span class="tok-type">u8</span>, buf[<span class="tok-number">0</span>..i], <span class="tok-str">':'</span>).? + <span class="tok-number">1</span>;</span>
<span class="line" id="L363">                <span class="tok-kw">const</span> addr = (Ip4Address.parse(buf[start_index..], <span class="tok-number">0</span>) <span class="tok-kw">catch</span> {</span>
<span class="line" id="L364">                    <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InvalidIpv4Mapping;</span>
<span class="line" id="L365">                }).sa.addr;</span>
<span class="line" id="L366">                ip_slice = result.sa.addr[<span class="tok-number">0</span>..];</span>
<span class="line" id="L367">                ip_slice[<span class="tok-number">10</span>] = <span class="tok-number">0xff</span>;</span>
<span class="line" id="L368">                ip_slice[<span class="tok-number">11</span>] = <span class="tok-number">0xff</span>;</span>
<span class="line" id="L369"></span>
<span class="line" id="L370">                <span class="tok-kw">const</span> ptr = mem.sliceAsBytes(<span class="tok-builtin">@as</span>(*<span class="tok-kw">const</span> [<span class="tok-number">1</span>]<span class="tok-type">u32</span>, &amp;addr)[<span class="tok-number">0</span>..]);</span>
<span class="line" id="L371"></span>
<span class="line" id="L372">                ip_slice[<span class="tok-number">12</span>] = ptr[<span class="tok-number">0</span>];</span>
<span class="line" id="L373">                ip_slice[<span class="tok-number">13</span>] = ptr[<span class="tok-number">1</span>];</span>
<span class="line" id="L374">                ip_slice[<span class="tok-number">14</span>] = ptr[<span class="tok-number">2</span>];</span>
<span class="line" id="L375">                ip_slice[<span class="tok-number">15</span>] = ptr[<span class="tok-number">3</span>];</span>
<span class="line" id="L376">                <span class="tok-kw">return</span> result;</span>
<span class="line" id="L377">            } <span class="tok-kw">else</span> {</span>
<span class="line" id="L378">                <span class="tok-kw">const</span> digit = <span class="tok-kw">try</span> std.fmt.charToDigit(c, <span class="tok-number">16</span>);</span>
<span class="line" id="L379">                <span class="tok-kw">if</span> (<span class="tok-builtin">@mulWithOverflow</span>(<span class="tok-type">u16</span>, x, <span class="tok-number">16</span>, &amp;x)) {</span>
<span class="line" id="L380">                    <span class="tok-kw">return</span> <span class="tok-kw">error</span>.Overflow;</span>
<span class="line" id="L381">                }</span>
<span class="line" id="L382">                <span class="tok-kw">if</span> (<span class="tok-builtin">@addWithOverflow</span>(<span class="tok-type">u16</span>, x, digit, &amp;x)) {</span>
<span class="line" id="L383">                    <span class="tok-kw">return</span> <span class="tok-kw">error</span>.Overflow;</span>
<span class="line" id="L384">                }</span>
<span class="line" id="L385">                saw_any_digits = <span class="tok-null">true</span>;</span>
<span class="line" id="L386">            }</span>
<span class="line" id="L387">        }</span>
<span class="line" id="L388"></span>
<span class="line" id="L389">        <span class="tok-kw">if</span> (!saw_any_digits <span class="tok-kw">and</span> !abbrv) {</span>
<span class="line" id="L390">            <span class="tok-kw">return</span> <span class="tok-kw">error</span>.Incomplete;</span>
<span class="line" id="L391">        }</span>
<span class="line" id="L392"></span>
<span class="line" id="L393">        <span class="tok-kw">if</span> (index == <span class="tok-number">14</span>) {</span>
<span class="line" id="L394">            ip_slice[<span class="tok-number">14</span>] = <span class="tok-builtin">@truncate</span>(<span class="tok-type">u8</span>, x &gt;&gt; <span class="tok-number">8</span>);</span>
<span class="line" id="L395">            ip_slice[<span class="tok-number">15</span>] = <span class="tok-builtin">@truncate</span>(<span class="tok-type">u8</span>, x);</span>
<span class="line" id="L396">            <span class="tok-kw">return</span> result;</span>
<span class="line" id="L397">        } <span class="tok-kw">else</span> {</span>
<span class="line" id="L398">            ip_slice[index] = <span class="tok-builtin">@truncate</span>(<span class="tok-type">u8</span>, x &gt;&gt; <span class="tok-number">8</span>);</span>
<span class="line" id="L399">            index += <span class="tok-number">1</span>;</span>
<span class="line" id="L400">            ip_slice[index] = <span class="tok-builtin">@truncate</span>(<span class="tok-type">u8</span>, x);</span>
<span class="line" id="L401">            index += <span class="tok-number">1</span>;</span>
<span class="line" id="L402">            mem.copy(<span class="tok-type">u8</span>, result.sa.addr[<span class="tok-number">16</span> - index ..], ip_slice[<span class="tok-number">0</span>..index]);</span>
<span class="line" id="L403">            <span class="tok-kw">return</span> result;</span>
<span class="line" id="L404">        }</span>
<span class="line" id="L405">    }</span>
<span class="line" id="L406"></span>
<span class="line" id="L407">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">resolve</span>(buf: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, port: <span class="tok-type">u16</span>) !Ip6Address {</span>
<span class="line" id="L408">        <span class="tok-comment">// TODO: Unify the implementations of resolveIp6 and parseIp6.</span>
</span>
<span class="line" id="L409">        <span class="tok-kw">var</span> result = Ip6Address{</span>
<span class="line" id="L410">            .sa = os.sockaddr.in6{</span>
<span class="line" id="L411">                .scope_id = <span class="tok-number">0</span>,</span>
<span class="line" id="L412">                .port = mem.nativeToBig(<span class="tok-type">u16</span>, port),</span>
<span class="line" id="L413">                .flowinfo = <span class="tok-number">0</span>,</span>
<span class="line" id="L414">                .addr = <span class="tok-null">undefined</span>,</span>
<span class="line" id="L415">            },</span>
<span class="line" id="L416">        };</span>
<span class="line" id="L417">        <span class="tok-kw">var</span> ip_slice = result.sa.addr[<span class="tok-number">0</span>..];</span>
<span class="line" id="L418"></span>
<span class="line" id="L419">        <span class="tok-kw">var</span> tail: [<span class="tok-number">16</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L420"></span>
<span class="line" id="L421">        <span class="tok-kw">var</span> x: <span class="tok-type">u16</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L422">        <span class="tok-kw">var</span> saw_any_digits = <span class="tok-null">false</span>;</span>
<span class="line" id="L423">        <span class="tok-kw">var</span> index: <span class="tok-type">u8</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L424">        <span class="tok-kw">var</span> abbrv = <span class="tok-null">false</span>;</span>
<span class="line" id="L425"></span>
<span class="line" id="L426">        <span class="tok-kw">var</span> scope_id = <span class="tok-null">false</span>;</span>
<span class="line" id="L427">        <span class="tok-kw">var</span> scope_id_value: [os.IFNAMESIZE - <span class="tok-number">1</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L428">        <span class="tok-kw">var</span> scope_id_index: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L429"></span>
<span class="line" id="L430">        <span class="tok-kw">for</span> (buf) |c, i| {</span>
<span class="line" id="L431">            <span class="tok-kw">if</span> (scope_id) {</span>
<span class="line" id="L432">                <span class="tok-comment">// Handling of percent-encoding should be for an URI library.</span>
</span>
<span class="line" id="L433">                <span class="tok-kw">if</span> ((c &gt;= <span class="tok-str">'0'</span> <span class="tok-kw">and</span> c &lt;= <span class="tok-str">'9'</span>) <span class="tok-kw">or</span></span>
<span class="line" id="L434">                    (c &gt;= <span class="tok-str">'A'</span> <span class="tok-kw">and</span> c &lt;= <span class="tok-str">'Z'</span>) <span class="tok-kw">or</span></span>
<span class="line" id="L435">                    (c &gt;= <span class="tok-str">'a'</span> <span class="tok-kw">and</span> c &lt;= <span class="tok-str">'z'</span>) <span class="tok-kw">or</span></span>
<span class="line" id="L436">                    (c == <span class="tok-str">'-'</span>) <span class="tok-kw">or</span> (c == <span class="tok-str">'.'</span>) <span class="tok-kw">or</span> (c == <span class="tok-str">'_'</span>) <span class="tok-kw">or</span> (c == <span class="tok-str">'~'</span>))</span>
<span class="line" id="L437">                {</span>
<span class="line" id="L438">                    <span class="tok-kw">if</span> (scope_id_index &gt;= scope_id_value.len) {</span>
<span class="line" id="L439">                        <span class="tok-kw">return</span> <span class="tok-kw">error</span>.Overflow;</span>
<span class="line" id="L440">                    }</span>
<span class="line" id="L441"></span>
<span class="line" id="L442">                    scope_id_value[scope_id_index] = c;</span>
<span class="line" id="L443">                    scope_id_index += <span class="tok-number">1</span>;</span>
<span class="line" id="L444">                } <span class="tok-kw">else</span> {</span>
<span class="line" id="L445">                    <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InvalidCharacter;</span>
<span class="line" id="L446">                }</span>
<span class="line" id="L447">            } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (c == <span class="tok-str">':'</span>) {</span>
<span class="line" id="L448">                <span class="tok-kw">if</span> (!saw_any_digits) {</span>
<span class="line" id="L449">                    <span class="tok-kw">if</span> (abbrv) <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InvalidCharacter; <span class="tok-comment">// ':::'</span>
</span>
<span class="line" id="L450">                    <span class="tok-kw">if</span> (i != <span class="tok-number">0</span>) abbrv = <span class="tok-null">true</span>;</span>
<span class="line" id="L451">                    mem.set(<span class="tok-type">u8</span>, ip_slice[index..], <span class="tok-number">0</span>);</span>
<span class="line" id="L452">                    ip_slice = tail[<span class="tok-number">0</span>..];</span>
<span class="line" id="L453">                    index = <span class="tok-number">0</span>;</span>
<span class="line" id="L454">                    <span class="tok-kw">continue</span>;</span>
<span class="line" id="L455">                }</span>
<span class="line" id="L456">                <span class="tok-kw">if</span> (index == <span class="tok-number">14</span>) {</span>
<span class="line" id="L457">                    <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InvalidEnd;</span>
<span class="line" id="L458">                }</span>
<span class="line" id="L459">                ip_slice[index] = <span class="tok-builtin">@truncate</span>(<span class="tok-type">u8</span>, x &gt;&gt; <span class="tok-number">8</span>);</span>
<span class="line" id="L460">                index += <span class="tok-number">1</span>;</span>
<span class="line" id="L461">                ip_slice[index] = <span class="tok-builtin">@truncate</span>(<span class="tok-type">u8</span>, x);</span>
<span class="line" id="L462">                index += <span class="tok-number">1</span>;</span>
<span class="line" id="L463"></span>
<span class="line" id="L464">                x = <span class="tok-number">0</span>;</span>
<span class="line" id="L465">                saw_any_digits = <span class="tok-null">false</span>;</span>
<span class="line" id="L466">            } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (c == <span class="tok-str">'%'</span>) {</span>
<span class="line" id="L467">                <span class="tok-kw">if</span> (!saw_any_digits) {</span>
<span class="line" id="L468">                    <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InvalidCharacter;</span>
<span class="line" id="L469">                }</span>
<span class="line" id="L470">                scope_id = <span class="tok-null">true</span>;</span>
<span class="line" id="L471">                saw_any_digits = <span class="tok-null">false</span>;</span>
<span class="line" id="L472">            } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (c == <span class="tok-str">'.'</span>) {</span>
<span class="line" id="L473">                <span class="tok-kw">if</span> (!abbrv <span class="tok-kw">or</span> ip_slice[<span class="tok-number">0</span>] != <span class="tok-number">0xff</span> <span class="tok-kw">or</span> ip_slice[<span class="tok-number">1</span>] != <span class="tok-number">0xff</span>) {</span>
<span class="line" id="L474">                    <span class="tok-comment">// must start with '::ffff:'</span>
</span>
<span class="line" id="L475">                    <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InvalidIpv4Mapping;</span>
<span class="line" id="L476">                }</span>
<span class="line" id="L477">                <span class="tok-kw">const</span> start_index = mem.lastIndexOfScalar(<span class="tok-type">u8</span>, buf[<span class="tok-number">0</span>..i], <span class="tok-str">':'</span>).? + <span class="tok-number">1</span>;</span>
<span class="line" id="L478">                <span class="tok-kw">const</span> addr = (Ip4Address.parse(buf[start_index..], <span class="tok-number">0</span>) <span class="tok-kw">catch</span> {</span>
<span class="line" id="L479">                    <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InvalidIpv4Mapping;</span>
<span class="line" id="L480">                }).sa.addr;</span>
<span class="line" id="L481">                ip_slice = result.sa.addr[<span class="tok-number">0</span>..];</span>
<span class="line" id="L482">                ip_slice[<span class="tok-number">10</span>] = <span class="tok-number">0xff</span>;</span>
<span class="line" id="L483">                ip_slice[<span class="tok-number">11</span>] = <span class="tok-number">0xff</span>;</span>
<span class="line" id="L484"></span>
<span class="line" id="L485">                <span class="tok-kw">const</span> ptr = mem.sliceAsBytes(<span class="tok-builtin">@as</span>(*<span class="tok-kw">const</span> [<span class="tok-number">1</span>]<span class="tok-type">u32</span>, &amp;addr)[<span class="tok-number">0</span>..]);</span>
<span class="line" id="L486"></span>
<span class="line" id="L487">                ip_slice[<span class="tok-number">12</span>] = ptr[<span class="tok-number">0</span>];</span>
<span class="line" id="L488">                ip_slice[<span class="tok-number">13</span>] = ptr[<span class="tok-number">1</span>];</span>
<span class="line" id="L489">                ip_slice[<span class="tok-number">14</span>] = ptr[<span class="tok-number">2</span>];</span>
<span class="line" id="L490">                ip_slice[<span class="tok-number">15</span>] = ptr[<span class="tok-number">3</span>];</span>
<span class="line" id="L491">                <span class="tok-kw">return</span> result;</span>
<span class="line" id="L492">            } <span class="tok-kw">else</span> {</span>
<span class="line" id="L493">                <span class="tok-kw">const</span> digit = <span class="tok-kw">try</span> std.fmt.charToDigit(c, <span class="tok-number">16</span>);</span>
<span class="line" id="L494">                <span class="tok-kw">if</span> (<span class="tok-builtin">@mulWithOverflow</span>(<span class="tok-type">u16</span>, x, <span class="tok-number">16</span>, &amp;x)) {</span>
<span class="line" id="L495">                    <span class="tok-kw">return</span> <span class="tok-kw">error</span>.Overflow;</span>
<span class="line" id="L496">                }</span>
<span class="line" id="L497">                <span class="tok-kw">if</span> (<span class="tok-builtin">@addWithOverflow</span>(<span class="tok-type">u16</span>, x, digit, &amp;x)) {</span>
<span class="line" id="L498">                    <span class="tok-kw">return</span> <span class="tok-kw">error</span>.Overflow;</span>
<span class="line" id="L499">                }</span>
<span class="line" id="L500">                saw_any_digits = <span class="tok-null">true</span>;</span>
<span class="line" id="L501">            }</span>
<span class="line" id="L502">        }</span>
<span class="line" id="L503"></span>
<span class="line" id="L504">        <span class="tok-kw">if</span> (!saw_any_digits <span class="tok-kw">and</span> !abbrv) {</span>
<span class="line" id="L505">            <span class="tok-kw">return</span> <span class="tok-kw">error</span>.Incomplete;</span>
<span class="line" id="L506">        }</span>
<span class="line" id="L507"></span>
<span class="line" id="L508">        <span class="tok-kw">if</span> (scope_id <span class="tok-kw">and</span> scope_id_index == <span class="tok-number">0</span>) {</span>
<span class="line" id="L509">            <span class="tok-kw">return</span> <span class="tok-kw">error</span>.Incomplete;</span>
<span class="line" id="L510">        }</span>
<span class="line" id="L511"></span>
<span class="line" id="L512">        <span class="tok-kw">var</span> resolved_scope_id: <span class="tok-type">u32</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L513">        <span class="tok-kw">if</span> (scope_id_index &gt; <span class="tok-number">0</span>) {</span>
<span class="line" id="L514">            <span class="tok-kw">const</span> scope_id_str = scope_id_value[<span class="tok-number">0</span>..scope_id_index];</span>
<span class="line" id="L515">            resolved_scope_id = std.fmt.parseInt(<span class="tok-type">u32</span>, scope_id_str, <span class="tok-number">10</span>) <span class="tok-kw">catch</span> |err| blk: {</span>
<span class="line" id="L516">                <span class="tok-kw">if</span> (err != <span class="tok-kw">error</span>.InvalidCharacter) <span class="tok-kw">return</span> err;</span>
<span class="line" id="L517">                <span class="tok-kw">break</span> :blk <span class="tok-kw">try</span> if_nametoindex(scope_id_str);</span>
<span class="line" id="L518">            };</span>
<span class="line" id="L519">        }</span>
<span class="line" id="L520"></span>
<span class="line" id="L521">        result.sa.scope_id = resolved_scope_id;</span>
<span class="line" id="L522"></span>
<span class="line" id="L523">        <span class="tok-kw">if</span> (index == <span class="tok-number">14</span>) {</span>
<span class="line" id="L524">            ip_slice[<span class="tok-number">14</span>] = <span class="tok-builtin">@truncate</span>(<span class="tok-type">u8</span>, x &gt;&gt; <span class="tok-number">8</span>);</span>
<span class="line" id="L525">            ip_slice[<span class="tok-number">15</span>] = <span class="tok-builtin">@truncate</span>(<span class="tok-type">u8</span>, x);</span>
<span class="line" id="L526">            <span class="tok-kw">return</span> result;</span>
<span class="line" id="L527">        } <span class="tok-kw">else</span> {</span>
<span class="line" id="L528">            ip_slice[index] = <span class="tok-builtin">@truncate</span>(<span class="tok-type">u8</span>, x &gt;&gt; <span class="tok-number">8</span>);</span>
<span class="line" id="L529">            index += <span class="tok-number">1</span>;</span>
<span class="line" id="L530">            ip_slice[index] = <span class="tok-builtin">@truncate</span>(<span class="tok-type">u8</span>, x);</span>
<span class="line" id="L531">            index += <span class="tok-number">1</span>;</span>
<span class="line" id="L532">            mem.copy(<span class="tok-type">u8</span>, result.sa.addr[<span class="tok-number">16</span> - index ..], ip_slice[<span class="tok-number">0</span>..index]);</span>
<span class="line" id="L533">            <span class="tok-kw">return</span> result;</span>
<span class="line" id="L534">        }</span>
<span class="line" id="L535">    }</span>
<span class="line" id="L536"></span>
<span class="line" id="L537">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">init</span>(addr: [<span class="tok-number">16</span>]<span class="tok-type">u8</span>, port: <span class="tok-type">u16</span>, flowinfo: <span class="tok-type">u32</span>, scope_id: <span class="tok-type">u32</span>) Ip6Address {</span>
<span class="line" id="L538">        <span class="tok-kw">return</span> Ip6Address{</span>
<span class="line" id="L539">            .sa = os.sockaddr.in6{</span>
<span class="line" id="L540">                .addr = addr,</span>
<span class="line" id="L541">                .port = mem.nativeToBig(<span class="tok-type">u16</span>, port),</span>
<span class="line" id="L542">                .flowinfo = flowinfo,</span>
<span class="line" id="L543">                .scope_id = scope_id,</span>
<span class="line" id="L544">            },</span>
<span class="line" id="L545">        };</span>
<span class="line" id="L546">    }</span>
<span class="line" id="L547"></span>
<span class="line" id="L548">    <span class="tok-comment">/// Returns the port in native endian.</span></span>
<span class="line" id="L549">    <span class="tok-comment">/// Asserts that the address is ip4 or ip6.</span></span>
<span class="line" id="L550">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">getPort</span>(self: Ip6Address) <span class="tok-type">u16</span> {</span>
<span class="line" id="L551">        <span class="tok-kw">return</span> mem.bigToNative(<span class="tok-type">u16</span>, self.sa.port);</span>
<span class="line" id="L552">    }</span>
<span class="line" id="L553"></span>
<span class="line" id="L554">    <span class="tok-comment">/// `port` is native-endian.</span></span>
<span class="line" id="L555">    <span class="tok-comment">/// Asserts that the address is ip4 or ip6.</span></span>
<span class="line" id="L556">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">setPort</span>(self: *Ip6Address, port: <span class="tok-type">u16</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L557">        self.sa.port = mem.nativeToBig(<span class="tok-type">u16</span>, port);</span>
<span class="line" id="L558">    }</span>
<span class="line" id="L559"></span>
<span class="line" id="L560">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">format</span>(</span>
<span class="line" id="L561">        self: Ip6Address,</span>
<span class="line" id="L562">        <span class="tok-kw">comptime</span> fmt: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L563">        options: std.fmt.FormatOptions,</span>
<span class="line" id="L564">        out_stream: <span class="tok-kw">anytype</span>,</span>
<span class="line" id="L565">    ) !<span class="tok-type">void</span> {</span>
<span class="line" id="L566">        _ = fmt;</span>
<span class="line" id="L567">        _ = options;</span>
<span class="line" id="L568">        <span class="tok-kw">const</span> port = mem.bigToNative(<span class="tok-type">u16</span>, self.sa.port);</span>
<span class="line" id="L569">        <span class="tok-kw">if</span> (mem.eql(<span class="tok-type">u8</span>, self.sa.addr[<span class="tok-number">0</span>..<span class="tok-number">12</span>], &amp;[_]<span class="tok-type">u8</span>{ <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0xff</span>, <span class="tok-number">0xff</span> })) {</span>
<span class="line" id="L570">            <span class="tok-kw">try</span> std.fmt.format(out_stream, <span class="tok-str">&quot;[::ffff:{}.{}.{}.{}]:{}&quot;</span>, .{</span>
<span class="line" id="L571">                self.sa.addr[<span class="tok-number">12</span>],</span>
<span class="line" id="L572">                self.sa.addr[<span class="tok-number">13</span>],</span>
<span class="line" id="L573">                self.sa.addr[<span class="tok-number">14</span>],</span>
<span class="line" id="L574">                self.sa.addr[<span class="tok-number">15</span>],</span>
<span class="line" id="L575">                port,</span>
<span class="line" id="L576">            });</span>
<span class="line" id="L577">            <span class="tok-kw">return</span>;</span>
<span class="line" id="L578">        }</span>
<span class="line" id="L579">        <span class="tok-kw">const</span> big_endian_parts = <span class="tok-builtin">@ptrCast</span>(*<span class="tok-kw">align</span>(<span class="tok-number">1</span>) <span class="tok-kw">const</span> [<span class="tok-number">8</span>]<span class="tok-type">u16</span>, &amp;self.sa.addr);</span>
<span class="line" id="L580">        <span class="tok-kw">const</span> native_endian_parts = <span class="tok-kw">switch</span> (native_endian) {</span>
<span class="line" id="L581">            .Big =&gt; big_endian_parts.*,</span>
<span class="line" id="L582">            .Little =&gt; blk: {</span>
<span class="line" id="L583">                <span class="tok-kw">var</span> buf: [<span class="tok-number">8</span>]<span class="tok-type">u16</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L584">                <span class="tok-kw">for</span> (big_endian_parts) |part, i| {</span>
<span class="line" id="L585">                    buf[i] = mem.bigToNative(<span class="tok-type">u16</span>, part);</span>
<span class="line" id="L586">                }</span>
<span class="line" id="L587">                <span class="tok-kw">break</span> :blk buf;</span>
<span class="line" id="L588">            },</span>
<span class="line" id="L589">        };</span>
<span class="line" id="L590">        <span class="tok-kw">try</span> out_stream.writeAll(<span class="tok-str">&quot;[&quot;</span>);</span>
<span class="line" id="L591">        <span class="tok-kw">var</span> i: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L592">        <span class="tok-kw">var</span> abbrv = <span class="tok-null">false</span>;</span>
<span class="line" id="L593">        <span class="tok-kw">while</span> (i &lt; native_endian_parts.len) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L594">            <span class="tok-kw">if</span> (native_endian_parts[i] == <span class="tok-number">0</span>) {</span>
<span class="line" id="L595">                <span class="tok-kw">if</span> (!abbrv) {</span>
<span class="line" id="L596">                    <span class="tok-kw">try</span> out_stream.writeAll(<span class="tok-kw">if</span> (i == <span class="tok-number">0</span>) <span class="tok-str">&quot;::&quot;</span> <span class="tok-kw">else</span> <span class="tok-str">&quot;:&quot;</span>);</span>
<span class="line" id="L597">                    abbrv = <span class="tok-null">true</span>;</span>
<span class="line" id="L598">                }</span>
<span class="line" id="L599">                <span class="tok-kw">continue</span>;</span>
<span class="line" id="L600">            }</span>
<span class="line" id="L601">            <span class="tok-kw">try</span> std.fmt.format(out_stream, <span class="tok-str">&quot;{x}&quot;</span>, .{native_endian_parts[i]});</span>
<span class="line" id="L602">            <span class="tok-kw">if</span> (i != native_endian_parts.len - <span class="tok-number">1</span>) {</span>
<span class="line" id="L603">                <span class="tok-kw">try</span> out_stream.writeAll(<span class="tok-str">&quot;:&quot;</span>);</span>
<span class="line" id="L604">            }</span>
<span class="line" id="L605">        }</span>
<span class="line" id="L606">        <span class="tok-kw">try</span> std.fmt.format(out_stream, <span class="tok-str">&quot;]:{}&quot;</span>, .{port});</span>
<span class="line" id="L607">    }</span>
<span class="line" id="L608"></span>
<span class="line" id="L609">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">getOsSockLen</span>(self: Ip6Address) os.socklen_t {</span>
<span class="line" id="L610">        _ = self;</span>
<span class="line" id="L611">        <span class="tok-kw">return</span> <span class="tok-builtin">@sizeOf</span>(os.sockaddr.in6);</span>
<span class="line" id="L612">    }</span>
<span class="line" id="L613">};</span>
<span class="line" id="L614"></span>
<span class="line" id="L615"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">connectUnixSocket</span>(path: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) !Stream {</span>
<span class="line" id="L616">    <span class="tok-kw">const</span> opt_non_block = <span class="tok-kw">if</span> (std.io.is_async) os.SOCK.NONBLOCK <span class="tok-kw">else</span> <span class="tok-number">0</span>;</span>
<span class="line" id="L617">    <span class="tok-kw">const</span> sockfd = <span class="tok-kw">try</span> os.socket(</span>
<span class="line" id="L618">        os.AF.UNIX,</span>
<span class="line" id="L619">        os.SOCK.STREAM | os.SOCK.CLOEXEC | opt_non_block,</span>
<span class="line" id="L620">        <span class="tok-number">0</span>,</span>
<span class="line" id="L621">    );</span>
<span class="line" id="L622">    <span class="tok-kw">errdefer</span> os.closeSocket(sockfd);</span>
<span class="line" id="L623"></span>
<span class="line" id="L624">    <span class="tok-kw">var</span> addr = <span class="tok-kw">try</span> std.net.Address.initUnix(path);</span>
<span class="line" id="L625"></span>
<span class="line" id="L626">    <span class="tok-kw">if</span> (std.io.is_async) {</span>
<span class="line" id="L627">        <span class="tok-kw">const</span> loop = std.event.Loop.instance <span class="tok-kw">orelse</span> <span class="tok-kw">return</span> <span class="tok-kw">error</span>.WouldBlock;</span>
<span class="line" id="L628">        <span class="tok-kw">try</span> loop.connect(sockfd, &amp;addr.any, addr.getOsSockLen());</span>
<span class="line" id="L629">    } <span class="tok-kw">else</span> {</span>
<span class="line" id="L630">        <span class="tok-kw">try</span> os.connect(sockfd, &amp;addr.any, addr.getOsSockLen());</span>
<span class="line" id="L631">    }</span>
<span class="line" id="L632"></span>
<span class="line" id="L633">    <span class="tok-kw">return</span> Stream{</span>
<span class="line" id="L634">        .handle = sockfd,</span>
<span class="line" id="L635">    };</span>
<span class="line" id="L636">}</span>
<span class="line" id="L637"></span>
<span class="line" id="L638"><span class="tok-kw">fn</span> <span class="tok-fn">if_nametoindex</span>(name: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) !<span class="tok-type">u32</span> {</span>
<span class="line" id="L639">    <span class="tok-kw">if</span> (builtin.target.os.tag == .linux) {</span>
<span class="line" id="L640">        <span class="tok-kw">var</span> ifr: os.ifreq = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L641">        <span class="tok-kw">var</span> sockfd = <span class="tok-kw">try</span> os.socket(os.AF.UNIX, os.SOCK.DGRAM | os.SOCK.CLOEXEC, <span class="tok-number">0</span>);</span>
<span class="line" id="L642">        <span class="tok-kw">defer</span> os.closeSocket(sockfd);</span>
<span class="line" id="L643"></span>
<span class="line" id="L644">        std.mem.copy(<span class="tok-type">u8</span>, &amp;ifr.ifrn.name, name);</span>
<span class="line" id="L645">        ifr.ifrn.name[name.len] = <span class="tok-number">0</span>;</span>
<span class="line" id="L646"></span>
<span class="line" id="L647">        <span class="tok-comment">// TODO investigate if this needs to be integrated with evented I/O.</span>
</span>
<span class="line" id="L648">        <span class="tok-kw">try</span> os.ioctl_SIOCGIFINDEX(sockfd, &amp;ifr);</span>
<span class="line" id="L649"></span>
<span class="line" id="L650">        <span class="tok-kw">return</span> <span class="tok-builtin">@bitCast</span>(<span class="tok-type">u32</span>, ifr.ifru.ivalue);</span>
<span class="line" id="L651">    }</span>
<span class="line" id="L652"></span>
<span class="line" id="L653">    <span class="tok-kw">if</span> (<span class="tok-kw">comptime</span> builtin.target.os.tag.isDarwin()) {</span>
<span class="line" id="L654">        <span class="tok-kw">if</span> (name.len &gt;= os.IFNAMESIZE)</span>
<span class="line" id="L655">            <span class="tok-kw">return</span> <span class="tok-kw">error</span>.NameTooLong;</span>
<span class="line" id="L656"></span>
<span class="line" id="L657">        <span class="tok-kw">var</span> if_name: [os.IFNAMESIZE:<span class="tok-number">0</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L658">        std.mem.copy(<span class="tok-type">u8</span>, &amp;if_name, name);</span>
<span class="line" id="L659">        if_name[name.len] = <span class="tok-number">0</span>;</span>
<span class="line" id="L660">        <span class="tok-kw">const</span> if_slice = if_name[<span class="tok-number">0</span>..name.len :<span class="tok-number">0</span>];</span>
<span class="line" id="L661">        <span class="tok-kw">const</span> index = os.system.if_nametoindex(if_slice);</span>
<span class="line" id="L662">        <span class="tok-kw">if</span> (index == <span class="tok-number">0</span>)</span>
<span class="line" id="L663">            <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InterfaceNotFound;</span>
<span class="line" id="L664">        <span class="tok-kw">return</span> <span class="tok-builtin">@bitCast</span>(<span class="tok-type">u32</span>, index);</span>
<span class="line" id="L665">    }</span>
<span class="line" id="L666"></span>
<span class="line" id="L667">    <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;std.net.if_nametoindex unimplemented for this OS&quot;</span>);</span>
<span class="line" id="L668">}</span>
<span class="line" id="L669"></span>
<span class="line" id="L670"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> AddressList = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L671">    arena: std.heap.ArenaAllocator,</span>
<span class="line" id="L672">    addrs: []Address,</span>
<span class="line" id="L673">    canon_name: ?[]<span class="tok-type">u8</span>,</span>
<span class="line" id="L674"></span>
<span class="line" id="L675">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">deinit</span>(self: *AddressList) <span class="tok-type">void</span> {</span>
<span class="line" id="L676">        <span class="tok-comment">// Here we copy the arena allocator into stack memory, because</span>
</span>
<span class="line" id="L677">        <span class="tok-comment">// otherwise it would destroy itself while it was still working.</span>
</span>
<span class="line" id="L678">        <span class="tok-kw">var</span> arena = self.arena;</span>
<span class="line" id="L679">        arena.deinit();</span>
<span class="line" id="L680">        <span class="tok-comment">// self is destroyed</span>
</span>
<span class="line" id="L681">    }</span>
<span class="line" id="L682">};</span>
<span class="line" id="L683"></span>
<span class="line" id="L684"><span class="tok-comment">/// All memory allocated with `allocator` will be freed before this function returns.</span></span>
<span class="line" id="L685"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">tcpConnectToHost</span>(allocator: mem.Allocator, name: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, port: <span class="tok-type">u16</span>) !Stream {</span>
<span class="line" id="L686">    <span class="tok-kw">const</span> list = <span class="tok-kw">try</span> getAddressList(allocator, name, port);</span>
<span class="line" id="L687">    <span class="tok-kw">defer</span> list.deinit();</span>
<span class="line" id="L688"></span>
<span class="line" id="L689">    <span class="tok-kw">if</span> (list.addrs.len == <span class="tok-number">0</span>) <span class="tok-kw">return</span> <span class="tok-kw">error</span>.UnknownHostName;</span>
<span class="line" id="L690"></span>
<span class="line" id="L691">    <span class="tok-kw">for</span> (list.addrs) |addr| {</span>
<span class="line" id="L692">        <span class="tok-kw">return</span> tcpConnectToAddress(addr) <span class="tok-kw">catch</span> |err| <span class="tok-kw">switch</span> (err) {</span>
<span class="line" id="L693">            <span class="tok-kw">error</span>.ConnectionRefused =&gt; {</span>
<span class="line" id="L694">                <span class="tok-kw">continue</span>;</span>
<span class="line" id="L695">            },</span>
<span class="line" id="L696">            <span class="tok-kw">else</span> =&gt; <span class="tok-kw">return</span> err,</span>
<span class="line" id="L697">        };</span>
<span class="line" id="L698">    }</span>
<span class="line" id="L699">    <span class="tok-kw">return</span> std.os.ConnectError.ConnectionRefused;</span>
<span class="line" id="L700">}</span>
<span class="line" id="L701"></span>
<span class="line" id="L702"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">tcpConnectToAddress</span>(address: Address) !Stream {</span>
<span class="line" id="L703">    <span class="tok-kw">const</span> nonblock = <span class="tok-kw">if</span> (std.io.is_async) os.SOCK.NONBLOCK <span class="tok-kw">else</span> <span class="tok-number">0</span>;</span>
<span class="line" id="L704">    <span class="tok-kw">const</span> sock_flags = os.SOCK.STREAM | nonblock |</span>
<span class="line" id="L705">        (<span class="tok-kw">if</span> (builtin.target.os.tag == .windows) <span class="tok-number">0</span> <span class="tok-kw">else</span> os.SOCK.CLOEXEC);</span>
<span class="line" id="L706">    <span class="tok-kw">const</span> sockfd = <span class="tok-kw">try</span> os.socket(address.any.family, sock_flags, os.IPPROTO.TCP);</span>
<span class="line" id="L707">    <span class="tok-kw">errdefer</span> os.closeSocket(sockfd);</span>
<span class="line" id="L708"></span>
<span class="line" id="L709">    <span class="tok-kw">if</span> (std.io.is_async) {</span>
<span class="line" id="L710">        <span class="tok-kw">const</span> loop = std.event.Loop.instance <span class="tok-kw">orelse</span> <span class="tok-kw">return</span> <span class="tok-kw">error</span>.WouldBlock;</span>
<span class="line" id="L711">        <span class="tok-kw">try</span> loop.connect(sockfd, &amp;address.any, address.getOsSockLen());</span>
<span class="line" id="L712">    } <span class="tok-kw">else</span> {</span>
<span class="line" id="L713">        <span class="tok-kw">try</span> os.connect(sockfd, &amp;address.any, address.getOsSockLen());</span>
<span class="line" id="L714">    }</span>
<span class="line" id="L715"></span>
<span class="line" id="L716">    <span class="tok-kw">return</span> Stream{ .handle = sockfd };</span>
<span class="line" id="L717">}</span>
<span class="line" id="L718"></span>
<span class="line" id="L719"><span class="tok-comment">/// Call `AddressList.deinit` on the result.</span></span>
<span class="line" id="L720"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">getAddressList</span>(allocator: mem.Allocator, name: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, port: <span class="tok-type">u16</span>) !*AddressList {</span>
<span class="line" id="L721">    <span class="tok-kw">const</span> result = blk: {</span>
<span class="line" id="L722">        <span class="tok-kw">var</span> arena = std.heap.ArenaAllocator.init(allocator);</span>
<span class="line" id="L723">        <span class="tok-kw">errdefer</span> arena.deinit();</span>
<span class="line" id="L724"></span>
<span class="line" id="L725">        <span class="tok-kw">const</span> result = <span class="tok-kw">try</span> arena.allocator().create(AddressList);</span>
<span class="line" id="L726">        result.* = AddressList{</span>
<span class="line" id="L727">            .arena = arena,</span>
<span class="line" id="L728">            .addrs = <span class="tok-null">undefined</span>,</span>
<span class="line" id="L729">            .canon_name = <span class="tok-null">null</span>,</span>
<span class="line" id="L730">        };</span>
<span class="line" id="L731">        <span class="tok-kw">break</span> :blk result;</span>
<span class="line" id="L732">    };</span>
<span class="line" id="L733">    <span class="tok-kw">const</span> arena = result.arena.allocator();</span>
<span class="line" id="L734">    <span class="tok-kw">errdefer</span> result.deinit();</span>
<span class="line" id="L735"></span>
<span class="line" id="L736">    <span class="tok-kw">if</span> (builtin.target.os.tag == .windows <span class="tok-kw">or</span> builtin.link_libc) {</span>
<span class="line" id="L737">        <span class="tok-kw">const</span> name_c = <span class="tok-kw">try</span> std.cstr.addNullByte(allocator, name);</span>
<span class="line" id="L738">        <span class="tok-kw">defer</span> allocator.free(name_c);</span>
<span class="line" id="L739"></span>
<span class="line" id="L740">        <span class="tok-kw">const</span> port_c = <span class="tok-kw">try</span> std.fmt.allocPrintZ(allocator, <span class="tok-str">&quot;{}&quot;</span>, .{port});</span>
<span class="line" id="L741">        <span class="tok-kw">defer</span> allocator.free(port_c);</span>
<span class="line" id="L742"></span>
<span class="line" id="L743">        <span class="tok-kw">const</span> sys = <span class="tok-kw">if</span> (builtin.target.os.tag == .windows) os.windows.ws2_32 <span class="tok-kw">else</span> os.system;</span>
<span class="line" id="L744">        <span class="tok-kw">const</span> hints = os.addrinfo{</span>
<span class="line" id="L745">            .flags = sys.AI.NUMERICSERV,</span>
<span class="line" id="L746">            .family = os.AF.UNSPEC,</span>
<span class="line" id="L747">            .socktype = os.SOCK.STREAM,</span>
<span class="line" id="L748">            .protocol = os.IPPROTO.TCP,</span>
<span class="line" id="L749">            .canonname = <span class="tok-null">null</span>,</span>
<span class="line" id="L750">            .addr = <span class="tok-null">null</span>,</span>
<span class="line" id="L751">            .addrlen = <span class="tok-number">0</span>,</span>
<span class="line" id="L752">            .next = <span class="tok-null">null</span>,</span>
<span class="line" id="L753">        };</span>
<span class="line" id="L754">        <span class="tok-kw">var</span> res: *os.addrinfo = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L755">        <span class="tok-kw">const</span> rc = sys.getaddrinfo(name_c.ptr, port_c.ptr, &amp;hints, &amp;res);</span>
<span class="line" id="L756">        <span class="tok-kw">if</span> (builtin.target.os.tag == .windows) <span class="tok-kw">switch</span> (<span class="tok-builtin">@intToEnum</span>(os.windows.ws2_32.WinsockError, <span class="tok-builtin">@intCast</span>(<span class="tok-type">u16</span>, rc))) {</span>
<span class="line" id="L757">            <span class="tok-builtin">@intToEnum</span>(os.windows.ws2_32.WinsockError, <span class="tok-number">0</span>) =&gt; {},</span>
<span class="line" id="L758">            .WSATRY_AGAIN =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.TemporaryNameServerFailure,</span>
<span class="line" id="L759">            .WSANO_RECOVERY =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.NameServerFailure,</span>
<span class="line" id="L760">            .WSAEAFNOSUPPORT =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.AddressFamilyNotSupported,</span>
<span class="line" id="L761">            .WSA_NOT_ENOUGH_MEMORY =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.OutOfMemory,</span>
<span class="line" id="L762">            .WSAHOST_NOT_FOUND =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.UnknownHostName,</span>
<span class="line" id="L763">            .WSATYPE_NOT_FOUND =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.ServiceUnavailable,</span>
<span class="line" id="L764">            .WSAEINVAL =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L765">            .WSAESOCKTNOSUPPORT =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L766">            <span class="tok-kw">else</span> =&gt; |err| <span class="tok-kw">return</span> os.windows.unexpectedWSAError(err),</span>
<span class="line" id="L767">        } <span class="tok-kw">else</span> <span class="tok-kw">switch</span> (rc) {</span>
<span class="line" id="L768">            <span class="tok-builtin">@intToEnum</span>(sys.EAI, <span class="tok-number">0</span>) =&gt; {},</span>
<span class="line" id="L769">            .ADDRFAMILY =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.HostLacksNetworkAddresses,</span>
<span class="line" id="L770">            .AGAIN =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.TemporaryNameServerFailure,</span>
<span class="line" id="L771">            .BADFLAGS =&gt; <span class="tok-kw">unreachable</span>, <span class="tok-comment">// Invalid hints</span>
</span>
<span class="line" id="L772">            .FAIL =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.NameServerFailure,</span>
<span class="line" id="L773">            .FAMILY =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.AddressFamilyNotSupported,</span>
<span class="line" id="L774">            .MEMORY =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.OutOfMemory,</span>
<span class="line" id="L775">            .NODATA =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.HostLacksNetworkAddresses,</span>
<span class="line" id="L776">            .NONAME =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.UnknownHostName,</span>
<span class="line" id="L777">            .SERVICE =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.ServiceUnavailable,</span>
<span class="line" id="L778">            .SOCKTYPE =&gt; <span class="tok-kw">unreachable</span>, <span class="tok-comment">// Invalid socket type requested in hints</span>
</span>
<span class="line" id="L779">            .SYSTEM =&gt; <span class="tok-kw">switch</span> (os.errno(-<span class="tok-number">1</span>)) {</span>
<span class="line" id="L780">                <span class="tok-kw">else</span> =&gt; |e| <span class="tok-kw">return</span> os.unexpectedErrno(e),</span>
<span class="line" id="L781">            },</span>
<span class="line" id="L782">            <span class="tok-kw">else</span> =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L783">        }</span>
<span class="line" id="L784">        <span class="tok-kw">defer</span> sys.freeaddrinfo(res);</span>
<span class="line" id="L785"></span>
<span class="line" id="L786">        <span class="tok-kw">const</span> addr_count = blk: {</span>
<span class="line" id="L787">            <span class="tok-kw">var</span> count: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L788">            <span class="tok-kw">var</span> it: ?*os.addrinfo = res;</span>
<span class="line" id="L789">            <span class="tok-kw">while</span> (it) |info| : (it = info.next) {</span>
<span class="line" id="L790">                <span class="tok-kw">if</span> (info.addr != <span class="tok-null">null</span>) {</span>
<span class="line" id="L791">                    count += <span class="tok-number">1</span>;</span>
<span class="line" id="L792">                }</span>
<span class="line" id="L793">            }</span>
<span class="line" id="L794">            <span class="tok-kw">break</span> :blk count;</span>
<span class="line" id="L795">        };</span>
<span class="line" id="L796">        result.addrs = <span class="tok-kw">try</span> arena.alloc(Address, addr_count);</span>
<span class="line" id="L797"></span>
<span class="line" id="L798">        <span class="tok-kw">var</span> it: ?*os.addrinfo = res;</span>
<span class="line" id="L799">        <span class="tok-kw">var</span> i: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L800">        <span class="tok-kw">while</span> (it) |info| : (it = info.next) {</span>
<span class="line" id="L801">            <span class="tok-kw">const</span> addr = info.addr <span class="tok-kw">orelse</span> <span class="tok-kw">continue</span>;</span>
<span class="line" id="L802">            result.addrs[i] = Address.initPosix(<span class="tok-builtin">@alignCast</span>(<span class="tok-number">4</span>, addr));</span>
<span class="line" id="L803"></span>
<span class="line" id="L804">            <span class="tok-kw">if</span> (info.canonname) |n| {</span>
<span class="line" id="L805">                <span class="tok-kw">if</span> (result.canon_name == <span class="tok-null">null</span>) {</span>
<span class="line" id="L806">                    result.canon_name = <span class="tok-kw">try</span> arena.dupe(<span class="tok-type">u8</span>, mem.sliceTo(n, <span class="tok-number">0</span>));</span>
<span class="line" id="L807">                }</span>
<span class="line" id="L808">            }</span>
<span class="line" id="L809">            i += <span class="tok-number">1</span>;</span>
<span class="line" id="L810">        }</span>
<span class="line" id="L811"></span>
<span class="line" id="L812">        <span class="tok-kw">return</span> result;</span>
<span class="line" id="L813">    }</span>
<span class="line" id="L814">    <span class="tok-kw">if</span> (builtin.target.os.tag == .linux) {</span>
<span class="line" id="L815">        <span class="tok-kw">const</span> flags = std.c.AI.NUMERICSERV;</span>
<span class="line" id="L816">        <span class="tok-kw">const</span> family = os.AF.UNSPEC;</span>
<span class="line" id="L817">        <span class="tok-kw">var</span> lookup_addrs = std.ArrayList(LookupAddr).init(allocator);</span>
<span class="line" id="L818">        <span class="tok-kw">defer</span> lookup_addrs.deinit();</span>
<span class="line" id="L819"></span>
<span class="line" id="L820">        <span class="tok-kw">var</span> canon = std.ArrayList(<span class="tok-type">u8</span>).init(arena);</span>
<span class="line" id="L821">        <span class="tok-kw">defer</span> canon.deinit();</span>
<span class="line" id="L822"></span>
<span class="line" id="L823">        <span class="tok-kw">try</span> linuxLookupName(&amp;lookup_addrs, &amp;canon, name, family, flags, port);</span>
<span class="line" id="L824"></span>
<span class="line" id="L825">        result.addrs = <span class="tok-kw">try</span> arena.alloc(Address, lookup_addrs.items.len);</span>
<span class="line" id="L826">        <span class="tok-kw">if</span> (canon.items.len != <span class="tok-number">0</span>) {</span>
<span class="line" id="L827">            result.canon_name = canon.toOwnedSlice();</span>
<span class="line" id="L828">        }</span>
<span class="line" id="L829"></span>
<span class="line" id="L830">        <span class="tok-kw">for</span> (lookup_addrs.items) |lookup_addr, i| {</span>
<span class="line" id="L831">            result.addrs[i] = lookup_addr.addr;</span>
<span class="line" id="L832">            assert(result.addrs[i].getPort() == port);</span>
<span class="line" id="L833">        }</span>
<span class="line" id="L834"></span>
<span class="line" id="L835">        <span class="tok-kw">return</span> result;</span>
<span class="line" id="L836">    }</span>
<span class="line" id="L837">    <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;std.net.getAddressList unimplemented for this OS&quot;</span>);</span>
<span class="line" id="L838">}</span>
<span class="line" id="L839"></span>
<span class="line" id="L840"><span class="tok-kw">const</span> LookupAddr = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L841">    addr: Address,</span>
<span class="line" id="L842">    sortkey: <span class="tok-type">i32</span> = <span class="tok-number">0</span>,</span>
<span class="line" id="L843">};</span>
<span class="line" id="L844"></span>
<span class="line" id="L845"><span class="tok-kw">const</span> DAS_USABLE = <span class="tok-number">0x40000000</span>;</span>
<span class="line" id="L846"><span class="tok-kw">const</span> DAS_MATCHINGSCOPE = <span class="tok-number">0x20000000</span>;</span>
<span class="line" id="L847"><span class="tok-kw">const</span> DAS_MATCHINGLABEL = <span class="tok-number">0x10000000</span>;</span>
<span class="line" id="L848"><span class="tok-kw">const</span> DAS_PREC_SHIFT = <span class="tok-number">20</span>;</span>
<span class="line" id="L849"><span class="tok-kw">const</span> DAS_SCOPE_SHIFT = <span class="tok-number">16</span>;</span>
<span class="line" id="L850"><span class="tok-kw">const</span> DAS_PREFIX_SHIFT = <span class="tok-number">8</span>;</span>
<span class="line" id="L851"><span class="tok-kw">const</span> DAS_ORDER_SHIFT = <span class="tok-number">0</span>;</span>
<span class="line" id="L852"></span>
<span class="line" id="L853"><span class="tok-kw">fn</span> <span class="tok-fn">linuxLookupName</span>(</span>
<span class="line" id="L854">    addrs: *std.ArrayList(LookupAddr),</span>
<span class="line" id="L855">    canon: *std.ArrayList(<span class="tok-type">u8</span>),</span>
<span class="line" id="L856">    opt_name: ?[]<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L857">    family: os.sa_family_t,</span>
<span class="line" id="L858">    flags: <span class="tok-type">u32</span>,</span>
<span class="line" id="L859">    port: <span class="tok-type">u16</span>,</span>
<span class="line" id="L860">) !<span class="tok-type">void</span> {</span>
<span class="line" id="L861">    <span class="tok-kw">if</span> (opt_name) |name| {</span>
<span class="line" id="L862">        <span class="tok-comment">// reject empty name and check len so it fits into temp bufs</span>
</span>
<span class="line" id="L863">        canon.items.len = <span class="tok-number">0</span>;</span>
<span class="line" id="L864">        <span class="tok-kw">try</span> canon.appendSlice(name);</span>
<span class="line" id="L865">        <span class="tok-kw">if</span> (Address.parseExpectingFamily(name, family, port)) |addr| {</span>
<span class="line" id="L866">            <span class="tok-kw">try</span> addrs.append(LookupAddr{ .addr = addr });</span>
<span class="line" id="L867">        } <span class="tok-kw">else</span> |name_err| <span class="tok-kw">if</span> ((flags &amp; std.c.AI.NUMERICHOST) != <span class="tok-number">0</span>) {</span>
<span class="line" id="L868">            <span class="tok-kw">return</span> name_err;</span>
<span class="line" id="L869">        } <span class="tok-kw">else</span> {</span>
<span class="line" id="L870">            <span class="tok-kw">try</span> linuxLookupNameFromHosts(addrs, canon, name, family, port);</span>
<span class="line" id="L871">            <span class="tok-kw">if</span> (addrs.items.len == <span class="tok-number">0</span>) {</span>
<span class="line" id="L872">                <span class="tok-kw">try</span> linuxLookupNameFromDnsSearch(addrs, canon, name, family, port);</span>
<span class="line" id="L873">            }</span>
<span class="line" id="L874">            <span class="tok-kw">if</span> (addrs.items.len == <span class="tok-number">0</span>) {</span>
<span class="line" id="L875">                <span class="tok-comment">// RFC 6761 Section 6.3</span>
</span>
<span class="line" id="L876">                <span class="tok-comment">// Name resolution APIs and libraries SHOULD recognize localhost</span>
</span>
<span class="line" id="L877">                <span class="tok-comment">// names as special and SHOULD always return the IP loopback address</span>
</span>
<span class="line" id="L878">                <span class="tok-comment">// for address queries and negative responses for all other query</span>
</span>
<span class="line" id="L879">                <span class="tok-comment">// types.</span>
</span>
<span class="line" id="L880"></span>
<span class="line" id="L881">                <span class="tok-comment">// Check for equal to &quot;localhost&quot; or ends in &quot;.localhost&quot;</span>
</span>
<span class="line" id="L882">                <span class="tok-kw">if</span> (mem.endsWith(<span class="tok-type">u8</span>, name, <span class="tok-str">&quot;localhost&quot;</span>) <span class="tok-kw">and</span> (name.len == <span class="tok-str">&quot;localhost&quot;</span>.len <span class="tok-kw">or</span> name[name.len - <span class="tok-str">&quot;localhost&quot;</span>.len] == <span class="tok-str">'.'</span>)) {</span>
<span class="line" id="L883">                    <span class="tok-kw">try</span> addrs.append(LookupAddr{ .addr = .{ .in = Ip4Address.parse(<span class="tok-str">&quot;127.0.0.1&quot;</span>, port) <span class="tok-kw">catch</span> <span class="tok-kw">unreachable</span> } });</span>
<span class="line" id="L884">                    <span class="tok-kw">try</span> addrs.append(LookupAddr{ .addr = .{ .in6 = Ip6Address.parse(<span class="tok-str">&quot;::1&quot;</span>, port) <span class="tok-kw">catch</span> <span class="tok-kw">unreachable</span> } });</span>
<span class="line" id="L885">                    <span class="tok-kw">return</span>;</span>
<span class="line" id="L886">                }</span>
<span class="line" id="L887">            }</span>
<span class="line" id="L888">        }</span>
<span class="line" id="L889">    } <span class="tok-kw">else</span> {</span>
<span class="line" id="L890">        <span class="tok-kw">try</span> canon.resize(<span class="tok-number">0</span>);</span>
<span class="line" id="L891">        <span class="tok-kw">try</span> linuxLookupNameFromNull(addrs, family, flags, port);</span>
<span class="line" id="L892">    }</span>
<span class="line" id="L893">    <span class="tok-kw">if</span> (addrs.items.len == <span class="tok-number">0</span>) <span class="tok-kw">return</span> <span class="tok-kw">error</span>.UnknownHostName;</span>
<span class="line" id="L894"></span>
<span class="line" id="L895">    <span class="tok-comment">// No further processing is needed if there are fewer than 2</span>
</span>
<span class="line" id="L896">    <span class="tok-comment">// results or if there are only IPv4 results.</span>
</span>
<span class="line" id="L897">    <span class="tok-kw">if</span> (addrs.items.len == <span class="tok-number">1</span> <span class="tok-kw">or</span> family == os.AF.INET) <span class="tok-kw">return</span>;</span>
<span class="line" id="L898">    <span class="tok-kw">const</span> all_ip4 = <span class="tok-kw">for</span> (addrs.items) |addr| {</span>
<span class="line" id="L899">        <span class="tok-kw">if</span> (addr.addr.any.family != os.AF.INET) <span class="tok-kw">break</span> <span class="tok-null">false</span>;</span>
<span class="line" id="L900">    } <span class="tok-kw">else</span> <span class="tok-null">true</span>;</span>
<span class="line" id="L901">    <span class="tok-kw">if</span> (all_ip4) <span class="tok-kw">return</span>;</span>
<span class="line" id="L902"></span>
<span class="line" id="L903">    <span class="tok-comment">// The following implements a subset of RFC 3484/6724 destination</span>
</span>
<span class="line" id="L904">    <span class="tok-comment">// address selection by generating a single 31-bit sort key for</span>
</span>
<span class="line" id="L905">    <span class="tok-comment">// each address. Rules 3, 4, and 7 are omitted for having</span>
</span>
<span class="line" id="L906">    <span class="tok-comment">// excessive runtime and code size cost and dubious benefit.</span>
</span>
<span class="line" id="L907">    <span class="tok-comment">// So far the label/precedence table cannot be customized.</span>
</span>
<span class="line" id="L908">    <span class="tok-comment">// This implementation is ported from musl libc.</span>
</span>
<span class="line" id="L909">    <span class="tok-comment">// A more idiomatic &quot;ziggy&quot; implementation would be welcome.</span>
</span>
<span class="line" id="L910">    <span class="tok-kw">for</span> (addrs.items) |*addr, i| {</span>
<span class="line" id="L911">        <span class="tok-kw">var</span> key: <span class="tok-type">i32</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L912">        <span class="tok-kw">var</span> sa6: os.sockaddr.in6 = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L913">        <span class="tok-builtin">@memset</span>(<span class="tok-builtin">@ptrCast</span>([*]<span class="tok-type">u8</span>, &amp;sa6), <span class="tok-number">0</span>, <span class="tok-builtin">@sizeOf</span>(os.sockaddr.in6));</span>
<span class="line" id="L914">        <span class="tok-kw">var</span> da6 = os.sockaddr.in6{</span>
<span class="line" id="L915">            .family = os.AF.INET6,</span>
<span class="line" id="L916">            .scope_id = addr.addr.in6.sa.scope_id,</span>
<span class="line" id="L917">            .port = <span class="tok-number">65535</span>,</span>
<span class="line" id="L918">            .flowinfo = <span class="tok-number">0</span>,</span>
<span class="line" id="L919">            .addr = [<span class="tok-number">1</span>]<span class="tok-type">u8</span>{<span class="tok-number">0</span>} ** <span class="tok-number">16</span>,</span>
<span class="line" id="L920">        };</span>
<span class="line" id="L921">        <span class="tok-kw">var</span> sa4: os.sockaddr.in = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L922">        <span class="tok-builtin">@memset</span>(<span class="tok-builtin">@ptrCast</span>([*]<span class="tok-type">u8</span>, &amp;sa4), <span class="tok-number">0</span>, <span class="tok-builtin">@sizeOf</span>(os.sockaddr.in));</span>
<span class="line" id="L923">        <span class="tok-kw">var</span> da4 = os.sockaddr.in{</span>
<span class="line" id="L924">            .family = os.AF.INET,</span>
<span class="line" id="L925">            .port = <span class="tok-number">65535</span>,</span>
<span class="line" id="L926">            .addr = <span class="tok-number">0</span>,</span>
<span class="line" id="L927">            .zero = [<span class="tok-number">1</span>]<span class="tok-type">u8</span>{<span class="tok-number">0</span>} ** <span class="tok-number">8</span>,</span>
<span class="line" id="L928">        };</span>
<span class="line" id="L929">        <span class="tok-kw">var</span> sa: *<span class="tok-kw">align</span>(<span class="tok-number">4</span>) os.sockaddr = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L930">        <span class="tok-kw">var</span> da: *<span class="tok-kw">align</span>(<span class="tok-number">4</span>) os.sockaddr = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L931">        <span class="tok-kw">var</span> salen: os.socklen_t = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L932">        <span class="tok-kw">var</span> dalen: os.socklen_t = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L933">        <span class="tok-kw">if</span> (addr.addr.any.family == os.AF.INET6) {</span>
<span class="line" id="L934">            mem.copy(<span class="tok-type">u8</span>, &amp;da6.addr, &amp;addr.addr.in6.sa.addr);</span>
<span class="line" id="L935">            da = <span class="tok-builtin">@ptrCast</span>(*os.sockaddr, &amp;da6);</span>
<span class="line" id="L936">            dalen = <span class="tok-builtin">@sizeOf</span>(os.sockaddr.in6);</span>
<span class="line" id="L937">            sa = <span class="tok-builtin">@ptrCast</span>(*os.sockaddr, &amp;sa6);</span>
<span class="line" id="L938">            salen = <span class="tok-builtin">@sizeOf</span>(os.sockaddr.in6);</span>
<span class="line" id="L939">        } <span class="tok-kw">else</span> {</span>
<span class="line" id="L940">            mem.copy(<span class="tok-type">u8</span>, &amp;sa6.addr, <span class="tok-str">&quot;\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\xff\xff&quot;</span>);</span>
<span class="line" id="L941">            mem.copy(<span class="tok-type">u8</span>, &amp;da6.addr, <span class="tok-str">&quot;\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\xff\xff&quot;</span>);</span>
<span class="line" id="L942">            mem.writeIntNative(<span class="tok-type">u32</span>, da6.addr[<span class="tok-number">12</span>..], addr.addr.in.sa.addr);</span>
<span class="line" id="L943">            da4.addr = addr.addr.in.sa.addr;</span>
<span class="line" id="L944">            da = <span class="tok-builtin">@ptrCast</span>(*os.sockaddr, &amp;da4);</span>
<span class="line" id="L945">            dalen = <span class="tok-builtin">@sizeOf</span>(os.sockaddr.in);</span>
<span class="line" id="L946">            sa = <span class="tok-builtin">@ptrCast</span>(*os.sockaddr, &amp;sa4);</span>
<span class="line" id="L947">            salen = <span class="tok-builtin">@sizeOf</span>(os.sockaddr.in);</span>
<span class="line" id="L948">        }</span>
<span class="line" id="L949">        <span class="tok-kw">const</span> dpolicy = policyOf(da6.addr);</span>
<span class="line" id="L950">        <span class="tok-kw">const</span> dscope: <span class="tok-type">i32</span> = scopeOf(da6.addr);</span>
<span class="line" id="L951">        <span class="tok-kw">const</span> dlabel = dpolicy.label;</span>
<span class="line" id="L952">        <span class="tok-kw">const</span> dprec: <span class="tok-type">i32</span> = dpolicy.prec;</span>
<span class="line" id="L953">        <span class="tok-kw">const</span> MAXADDRS = <span class="tok-number">3</span>;</span>
<span class="line" id="L954">        <span class="tok-kw">var</span> prefixlen: <span class="tok-type">i32</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L955">        <span class="tok-kw">const</span> sock_flags = os.SOCK.DGRAM | os.SOCK.CLOEXEC;</span>
<span class="line" id="L956">        <span class="tok-kw">if</span> (os.socket(addr.addr.any.family, sock_flags, os.IPPROTO.UDP)) |fd| syscalls: {</span>
<span class="line" id="L957">            <span class="tok-kw">defer</span> os.closeSocket(fd);</span>
<span class="line" id="L958">            os.connect(fd, da, dalen) <span class="tok-kw">catch</span> <span class="tok-kw">break</span> :syscalls;</span>
<span class="line" id="L959">            key |= DAS_USABLE;</span>
<span class="line" id="L960">            os.getsockname(fd, sa, &amp;salen) <span class="tok-kw">catch</span> <span class="tok-kw">break</span> :syscalls;</span>
<span class="line" id="L961">            <span class="tok-kw">if</span> (addr.addr.any.family == os.AF.INET) {</span>
<span class="line" id="L962">                <span class="tok-comment">// TODO sa6.addr[12..16] should return *[4]u8, making this cast unnecessary.</span>
</span>
<span class="line" id="L963">                mem.writeIntNative(<span class="tok-type">u32</span>, <span class="tok-builtin">@ptrCast</span>(*[<span class="tok-number">4</span>]<span class="tok-type">u8</span>, &amp;sa6.addr[<span class="tok-number">12</span>]), sa4.addr);</span>
<span class="line" id="L964">            }</span>
<span class="line" id="L965">            <span class="tok-kw">if</span> (dscope == <span class="tok-builtin">@as</span>(<span class="tok-type">i32</span>, scopeOf(sa6.addr))) key |= DAS_MATCHINGSCOPE;</span>
<span class="line" id="L966">            <span class="tok-kw">if</span> (dlabel == labelOf(sa6.addr)) key |= DAS_MATCHINGLABEL;</span>
<span class="line" id="L967">            prefixlen = prefixMatch(sa6.addr, da6.addr);</span>
<span class="line" id="L968">        } <span class="tok-kw">else</span> |_| {}</span>
<span class="line" id="L969">        key |= dprec &lt;&lt; DAS_PREC_SHIFT;</span>
<span class="line" id="L970">        key |= (<span class="tok-number">15</span> - dscope) &lt;&lt; DAS_SCOPE_SHIFT;</span>
<span class="line" id="L971">        key |= prefixlen &lt;&lt; DAS_PREFIX_SHIFT;</span>
<span class="line" id="L972">        key |= (MAXADDRS - <span class="tok-builtin">@intCast</span>(<span class="tok-type">i32</span>, i)) &lt;&lt; DAS_ORDER_SHIFT;</span>
<span class="line" id="L973">        addr.sortkey = key;</span>
<span class="line" id="L974">    }</span>
<span class="line" id="L975">    std.sort.sort(LookupAddr, addrs.items, {}, addrCmpLessThan);</span>
<span class="line" id="L976">}</span>
<span class="line" id="L977"></span>
<span class="line" id="L978"><span class="tok-kw">const</span> Policy = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L979">    addr: [<span class="tok-number">16</span>]<span class="tok-type">u8</span>,</span>
<span class="line" id="L980">    len: <span class="tok-type">u8</span>,</span>
<span class="line" id="L981">    mask: <span class="tok-type">u8</span>,</span>
<span class="line" id="L982">    prec: <span class="tok-type">u8</span>,</span>
<span class="line" id="L983">    label: <span class="tok-type">u8</span>,</span>
<span class="line" id="L984">};</span>
<span class="line" id="L985"></span>
<span class="line" id="L986"><span class="tok-kw">const</span> defined_policies = [_]Policy{</span>
<span class="line" id="L987">    Policy{</span>
<span class="line" id="L988">        .addr = <span class="tok-str">&quot;\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x01&quot;</span>.*,</span>
<span class="line" id="L989">        .len = <span class="tok-number">15</span>,</span>
<span class="line" id="L990">        .mask = <span class="tok-number">0xff</span>,</span>
<span class="line" id="L991">        .prec = <span class="tok-number">50</span>,</span>
<span class="line" id="L992">        .label = <span class="tok-number">0</span>,</span>
<span class="line" id="L993">    },</span>
<span class="line" id="L994">    Policy{</span>
<span class="line" id="L995">        .addr = <span class="tok-str">&quot;\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\xff\xff\x00\x00\x00\x00&quot;</span>.*,</span>
<span class="line" id="L996">        .len = <span class="tok-number">11</span>,</span>
<span class="line" id="L997">        .mask = <span class="tok-number">0xff</span>,</span>
<span class="line" id="L998">        .prec = <span class="tok-number">35</span>,</span>
<span class="line" id="L999">        .label = <span class="tok-number">4</span>,</span>
<span class="line" id="L1000">    },</span>
<span class="line" id="L1001">    Policy{</span>
<span class="line" id="L1002">        .addr = <span class="tok-str">&quot;\x20\x02\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00&quot;</span>.*,</span>
<span class="line" id="L1003">        .len = <span class="tok-number">1</span>,</span>
<span class="line" id="L1004">        .mask = <span class="tok-number">0xff</span>,</span>
<span class="line" id="L1005">        .prec = <span class="tok-number">30</span>,</span>
<span class="line" id="L1006">        .label = <span class="tok-number">2</span>,</span>
<span class="line" id="L1007">    },</span>
<span class="line" id="L1008">    Policy{</span>
<span class="line" id="L1009">        .addr = <span class="tok-str">&quot;\x20\x01\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00&quot;</span>.*,</span>
<span class="line" id="L1010">        .len = <span class="tok-number">3</span>,</span>
<span class="line" id="L1011">        .mask = <span class="tok-number">0xff</span>,</span>
<span class="line" id="L1012">        .prec = <span class="tok-number">5</span>,</span>
<span class="line" id="L1013">        .label = <span class="tok-number">5</span>,</span>
<span class="line" id="L1014">    },</span>
<span class="line" id="L1015">    Policy{</span>
<span class="line" id="L1016">        .addr = <span class="tok-str">&quot;\xfc\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00&quot;</span>.*,</span>
<span class="line" id="L1017">        .len = <span class="tok-number">0</span>,</span>
<span class="line" id="L1018">        .mask = <span class="tok-number">0xfe</span>,</span>
<span class="line" id="L1019">        .prec = <span class="tok-number">3</span>,</span>
<span class="line" id="L1020">        .label = <span class="tok-number">13</span>,</span>
<span class="line" id="L1021">    },</span>
<span class="line" id="L1022">    <span class="tok-comment">//  These are deprecated and/or returned to the address</span>
</span>
<span class="line" id="L1023">    <span class="tok-comment">//  pool, so despite the RFC, treating them as special</span>
</span>
<span class="line" id="L1024">    <span class="tok-comment">//  is probably wrong.</span>
</span>
<span class="line" id="L1025">    <span class="tok-comment">// { &quot;&quot;, 11, 0xff, 1, 3 },</span>
</span>
<span class="line" id="L1026">    <span class="tok-comment">// { &quot;\xfe\xc0&quot;, 1, 0xc0, 1, 11 },</span>
</span>
<span class="line" id="L1027">    <span class="tok-comment">// { &quot;\x3f\xfe&quot;, 1, 0xff, 1, 12 },</span>
</span>
<span class="line" id="L1028">    <span class="tok-comment">// Last rule must match all addresses to stop loop.</span>
</span>
<span class="line" id="L1029">    Policy{</span>
<span class="line" id="L1030">        .addr = <span class="tok-str">&quot;\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00&quot;</span>.*,</span>
<span class="line" id="L1031">        .len = <span class="tok-number">0</span>,</span>
<span class="line" id="L1032">        .mask = <span class="tok-number">0</span>,</span>
<span class="line" id="L1033">        .prec = <span class="tok-number">40</span>,</span>
<span class="line" id="L1034">        .label = <span class="tok-number">1</span>,</span>
<span class="line" id="L1035">    },</span>
<span class="line" id="L1036">};</span>
<span class="line" id="L1037"></span>
<span class="line" id="L1038"><span class="tok-kw">fn</span> <span class="tok-fn">policyOf</span>(a: [<span class="tok-number">16</span>]<span class="tok-type">u8</span>) *<span class="tok-kw">const</span> Policy {</span>
<span class="line" id="L1039">    <span class="tok-kw">for</span> (defined_policies) |*policy| {</span>
<span class="line" id="L1040">        <span class="tok-kw">if</span> (!mem.eql(<span class="tok-type">u8</span>, a[<span class="tok-number">0</span>..policy.len], policy.addr[<span class="tok-number">0</span>..policy.len])) <span class="tok-kw">continue</span>;</span>
<span class="line" id="L1041">        <span class="tok-kw">if</span> ((a[policy.len] &amp; policy.mask) != policy.addr[policy.len]) <span class="tok-kw">continue</span>;</span>
<span class="line" id="L1042">        <span class="tok-kw">return</span> policy;</span>
<span class="line" id="L1043">    }</span>
<span class="line" id="L1044">    <span class="tok-kw">unreachable</span>;</span>
<span class="line" id="L1045">}</span>
<span class="line" id="L1046"></span>
<span class="line" id="L1047"><span class="tok-kw">fn</span> <span class="tok-fn">scopeOf</span>(a: [<span class="tok-number">16</span>]<span class="tok-type">u8</span>) <span class="tok-type">u8</span> {</span>
<span class="line" id="L1048">    <span class="tok-kw">if</span> (IN6_IS_ADDR_MULTICAST(a)) <span class="tok-kw">return</span> a[<span class="tok-number">1</span>] &amp; <span class="tok-number">15</span>;</span>
<span class="line" id="L1049">    <span class="tok-kw">if</span> (IN6_IS_ADDR_LINKLOCAL(a)) <span class="tok-kw">return</span> <span class="tok-number">2</span>;</span>
<span class="line" id="L1050">    <span class="tok-kw">if</span> (IN6_IS_ADDR_LOOPBACK(a)) <span class="tok-kw">return</span> <span class="tok-number">2</span>;</span>
<span class="line" id="L1051">    <span class="tok-kw">if</span> (IN6_IS_ADDR_SITELOCAL(a)) <span class="tok-kw">return</span> <span class="tok-number">5</span>;</span>
<span class="line" id="L1052">    <span class="tok-kw">return</span> <span class="tok-number">14</span>;</span>
<span class="line" id="L1053">}</span>
<span class="line" id="L1054"></span>
<span class="line" id="L1055"><span class="tok-kw">fn</span> <span class="tok-fn">prefixMatch</span>(s: [<span class="tok-number">16</span>]<span class="tok-type">u8</span>, d: [<span class="tok-number">16</span>]<span class="tok-type">u8</span>) <span class="tok-type">u8</span> {</span>
<span class="line" id="L1056">    <span class="tok-comment">// TODO: This FIXME inherited from porting from musl libc.</span>
</span>
<span class="line" id="L1057">    <span class="tok-comment">// I don't want this to go into zig std lib 1.0.0.</span>
</span>
<span class="line" id="L1058"></span>
<span class="line" id="L1059">    <span class="tok-comment">// FIXME: The common prefix length should be limited to no greater</span>
</span>
<span class="line" id="L1060">    <span class="tok-comment">// than the nominal length of the prefix portion of the source</span>
</span>
<span class="line" id="L1061">    <span class="tok-comment">// address. However the definition of the source prefix length is</span>
</span>
<span class="line" id="L1062">    <span class="tok-comment">// not clear and thus this limiting is not yet implemented.</span>
</span>
<span class="line" id="L1063">    <span class="tok-kw">var</span> i: <span class="tok-type">u8</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L1064">    <span class="tok-kw">while</span> (i &lt; <span class="tok-number">128</span> <span class="tok-kw">and</span> ((s[i / <span class="tok-number">8</span>] ^ d[i / <span class="tok-number">8</span>]) &amp; (<span class="tok-builtin">@as</span>(<span class="tok-type">u8</span>, <span class="tok-number">128</span>) &gt;&gt; <span class="tok-builtin">@intCast</span>(<span class="tok-type">u3</span>, i % <span class="tok-number">8</span>))) == <span class="tok-number">0</span>) : (i += <span class="tok-number">1</span>) {}</span>
<span class="line" id="L1065">    <span class="tok-kw">return</span> i;</span>
<span class="line" id="L1066">}</span>
<span class="line" id="L1067"></span>
<span class="line" id="L1068"><span class="tok-kw">fn</span> <span class="tok-fn">labelOf</span>(a: [<span class="tok-number">16</span>]<span class="tok-type">u8</span>) <span class="tok-type">u8</span> {</span>
<span class="line" id="L1069">    <span class="tok-kw">return</span> policyOf(a).label;</span>
<span class="line" id="L1070">}</span>
<span class="line" id="L1071"></span>
<span class="line" id="L1072"><span class="tok-kw">fn</span> <span class="tok-fn">IN6_IS_ADDR_MULTICAST</span>(a: [<span class="tok-number">16</span>]<span class="tok-type">u8</span>) <span class="tok-type">bool</span> {</span>
<span class="line" id="L1073">    <span class="tok-kw">return</span> a[<span class="tok-number">0</span>] == <span class="tok-number">0xff</span>;</span>
<span class="line" id="L1074">}</span>
<span class="line" id="L1075"></span>
<span class="line" id="L1076"><span class="tok-kw">fn</span> <span class="tok-fn">IN6_IS_ADDR_LINKLOCAL</span>(a: [<span class="tok-number">16</span>]<span class="tok-type">u8</span>) <span class="tok-type">bool</span> {</span>
<span class="line" id="L1077">    <span class="tok-kw">return</span> a[<span class="tok-number">0</span>] == <span class="tok-number">0xfe</span> <span class="tok-kw">and</span> (a[<span class="tok-number">1</span>] &amp; <span class="tok-number">0xc0</span>) == <span class="tok-number">0x80</span>;</span>
<span class="line" id="L1078">}</span>
<span class="line" id="L1079"></span>
<span class="line" id="L1080"><span class="tok-kw">fn</span> <span class="tok-fn">IN6_IS_ADDR_LOOPBACK</span>(a: [<span class="tok-number">16</span>]<span class="tok-type">u8</span>) <span class="tok-type">bool</span> {</span>
<span class="line" id="L1081">    <span class="tok-kw">return</span> a[<span class="tok-number">0</span>] == <span class="tok-number">0</span> <span class="tok-kw">and</span> a[<span class="tok-number">1</span>] == <span class="tok-number">0</span> <span class="tok-kw">and</span></span>
<span class="line" id="L1082">        a[<span class="tok-number">2</span>] == <span class="tok-number">0</span> <span class="tok-kw">and</span></span>
<span class="line" id="L1083">        a[<span class="tok-number">12</span>] == <span class="tok-number">0</span> <span class="tok-kw">and</span> a[<span class="tok-number">13</span>] == <span class="tok-number">0</span> <span class="tok-kw">and</span></span>
<span class="line" id="L1084">        a[<span class="tok-number">14</span>] == <span class="tok-number">0</span> <span class="tok-kw">and</span> a[<span class="tok-number">15</span>] == <span class="tok-number">1</span>;</span>
<span class="line" id="L1085">}</span>
<span class="line" id="L1086"></span>
<span class="line" id="L1087"><span class="tok-kw">fn</span> <span class="tok-fn">IN6_IS_ADDR_SITELOCAL</span>(a: [<span class="tok-number">16</span>]<span class="tok-type">u8</span>) <span class="tok-type">bool</span> {</span>
<span class="line" id="L1088">    <span class="tok-kw">return</span> a[<span class="tok-number">0</span>] == <span class="tok-number">0xfe</span> <span class="tok-kw">and</span> (a[<span class="tok-number">1</span>] &amp; <span class="tok-number">0xc0</span>) == <span class="tok-number">0xc0</span>;</span>
<span class="line" id="L1089">}</span>
<span class="line" id="L1090"></span>
<span class="line" id="L1091"><span class="tok-comment">// Parameters `b` and `a` swapped to make this descending.</span>
</span>
<span class="line" id="L1092"><span class="tok-kw">fn</span> <span class="tok-fn">addrCmpLessThan</span>(context: <span class="tok-type">void</span>, b: LookupAddr, a: LookupAddr) <span class="tok-type">bool</span> {</span>
<span class="line" id="L1093">    _ = context;</span>
<span class="line" id="L1094">    <span class="tok-kw">return</span> a.sortkey &lt; b.sortkey;</span>
<span class="line" id="L1095">}</span>
<span class="line" id="L1096"></span>
<span class="line" id="L1097"><span class="tok-kw">fn</span> <span class="tok-fn">linuxLookupNameFromNull</span>(</span>
<span class="line" id="L1098">    addrs: *std.ArrayList(LookupAddr),</span>
<span class="line" id="L1099">    family: os.sa_family_t,</span>
<span class="line" id="L1100">    flags: <span class="tok-type">u32</span>,</span>
<span class="line" id="L1101">    port: <span class="tok-type">u16</span>,</span>
<span class="line" id="L1102">) !<span class="tok-type">void</span> {</span>
<span class="line" id="L1103">    <span class="tok-kw">if</span> ((flags &amp; std.c.AI.PASSIVE) != <span class="tok-number">0</span>) {</span>
<span class="line" id="L1104">        <span class="tok-kw">if</span> (family != os.AF.INET6) {</span>
<span class="line" id="L1105">            (<span class="tok-kw">try</span> addrs.addOne()).* = LookupAddr{</span>
<span class="line" id="L1106">                .addr = Address.initIp4([<span class="tok-number">1</span>]<span class="tok-type">u8</span>{<span class="tok-number">0</span>} ** <span class="tok-number">4</span>, port),</span>
<span class="line" id="L1107">            };</span>
<span class="line" id="L1108">        }</span>
<span class="line" id="L1109">        <span class="tok-kw">if</span> (family != os.AF.INET) {</span>
<span class="line" id="L1110">            (<span class="tok-kw">try</span> addrs.addOne()).* = LookupAddr{</span>
<span class="line" id="L1111">                .addr = Address.initIp6([<span class="tok-number">1</span>]<span class="tok-type">u8</span>{<span class="tok-number">0</span>} ** <span class="tok-number">16</span>, port, <span class="tok-number">0</span>, <span class="tok-number">0</span>),</span>
<span class="line" id="L1112">            };</span>
<span class="line" id="L1113">        }</span>
<span class="line" id="L1114">    } <span class="tok-kw">else</span> {</span>
<span class="line" id="L1115">        <span class="tok-kw">if</span> (family != os.AF.INET6) {</span>
<span class="line" id="L1116">            (<span class="tok-kw">try</span> addrs.addOne()).* = LookupAddr{</span>
<span class="line" id="L1117">                .addr = Address.initIp4([<span class="tok-number">4</span>]<span class="tok-type">u8</span>{ <span class="tok-number">127</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">1</span> }, port),</span>
<span class="line" id="L1118">            };</span>
<span class="line" id="L1119">        }</span>
<span class="line" id="L1120">        <span class="tok-kw">if</span> (family != os.AF.INET) {</span>
<span class="line" id="L1121">            (<span class="tok-kw">try</span> addrs.addOne()).* = LookupAddr{</span>
<span class="line" id="L1122">                .addr = Address.initIp6(([<span class="tok-number">1</span>]<span class="tok-type">u8</span>{<span class="tok-number">0</span>} ** <span class="tok-number">15</span>) ++ [<span class="tok-number">1</span>]<span class="tok-type">u8</span>{<span class="tok-number">1</span>}, port, <span class="tok-number">0</span>, <span class="tok-number">0</span>),</span>
<span class="line" id="L1123">            };</span>
<span class="line" id="L1124">        }</span>
<span class="line" id="L1125">    }</span>
<span class="line" id="L1126">}</span>
<span class="line" id="L1127"></span>
<span class="line" id="L1128"><span class="tok-kw">fn</span> <span class="tok-fn">linuxLookupNameFromHosts</span>(</span>
<span class="line" id="L1129">    addrs: *std.ArrayList(LookupAddr),</span>
<span class="line" id="L1130">    canon: *std.ArrayList(<span class="tok-type">u8</span>),</span>
<span class="line" id="L1131">    name: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L1132">    family: os.sa_family_t,</span>
<span class="line" id="L1133">    port: <span class="tok-type">u16</span>,</span>
<span class="line" id="L1134">) !<span class="tok-type">void</span> {</span>
<span class="line" id="L1135">    <span class="tok-kw">const</span> file = fs.openFileAbsoluteZ(<span class="tok-str">&quot;/etc/hosts&quot;</span>, .{}) <span class="tok-kw">catch</span> |err| <span class="tok-kw">switch</span> (err) {</span>
<span class="line" id="L1136">        <span class="tok-kw">error</span>.FileNotFound,</span>
<span class="line" id="L1137">        <span class="tok-kw">error</span>.NotDir,</span>
<span class="line" id="L1138">        <span class="tok-kw">error</span>.AccessDenied,</span>
<span class="line" id="L1139">        =&gt; <span class="tok-kw">return</span>,</span>
<span class="line" id="L1140">        <span class="tok-kw">else</span> =&gt; |e| <span class="tok-kw">return</span> e,</span>
<span class="line" id="L1141">    };</span>
<span class="line" id="L1142">    <span class="tok-kw">defer</span> file.close();</span>
<span class="line" id="L1143"></span>
<span class="line" id="L1144">    <span class="tok-kw">var</span> buffered_reader = std.io.bufferedReader(file.reader());</span>
<span class="line" id="L1145">    <span class="tok-kw">const</span> reader = buffered_reader.reader();</span>
<span class="line" id="L1146">    <span class="tok-kw">var</span> line_buf: [<span class="tok-number">512</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L1147">    <span class="tok-kw">while</span> (reader.readUntilDelimiterOrEof(&amp;line_buf, <span class="tok-str">'\n'</span>) <span class="tok-kw">catch</span> |err| <span class="tok-kw">switch</span> (err) {</span>
<span class="line" id="L1148">        <span class="tok-kw">error</span>.StreamTooLong =&gt; blk: {</span>
<span class="line" id="L1149">            <span class="tok-comment">// Skip to the delimiter in the reader, to fix parsing</span>
</span>
<span class="line" id="L1150">            <span class="tok-kw">try</span> reader.skipUntilDelimiterOrEof(<span class="tok-str">'\n'</span>);</span>
<span class="line" id="L1151">            <span class="tok-comment">// Use the truncated line. A truncated comment or hostname will be handled correctly.</span>
</span>
<span class="line" id="L1152">            <span class="tok-kw">break</span> :blk &amp;line_buf;</span>
<span class="line" id="L1153">        },</span>
<span class="line" id="L1154">        <span class="tok-kw">else</span> =&gt; |e| <span class="tok-kw">return</span> e,</span>
<span class="line" id="L1155">    }) |line| {</span>
<span class="line" id="L1156">        <span class="tok-kw">var</span> split_it = mem.split(<span class="tok-type">u8</span>, line, <span class="tok-str">&quot;#&quot;</span>);</span>
<span class="line" id="L1157">        <span class="tok-kw">const</span> no_comment_line = split_it.first();</span>
<span class="line" id="L1158"></span>
<span class="line" id="L1159">        <span class="tok-kw">var</span> line_it = mem.tokenize(<span class="tok-type">u8</span>, no_comment_line, <span class="tok-str">&quot; \t&quot;</span>);</span>
<span class="line" id="L1160">        <span class="tok-kw">const</span> ip_text = line_it.next() <span class="tok-kw">orelse</span> <span class="tok-kw">continue</span>;</span>
<span class="line" id="L1161">        <span class="tok-kw">var</span> first_name_text: ?[]<span class="tok-kw">const</span> <span class="tok-type">u8</span> = <span class="tok-null">null</span>;</span>
<span class="line" id="L1162">        <span class="tok-kw">while</span> (line_it.next()) |name_text| {</span>
<span class="line" id="L1163">            <span class="tok-kw">if</span> (first_name_text == <span class="tok-null">null</span>) first_name_text = name_text;</span>
<span class="line" id="L1164">            <span class="tok-kw">if</span> (mem.eql(<span class="tok-type">u8</span>, name_text, name)) {</span>
<span class="line" id="L1165">                <span class="tok-kw">break</span>;</span>
<span class="line" id="L1166">            }</span>
<span class="line" id="L1167">        } <span class="tok-kw">else</span> <span class="tok-kw">continue</span>;</span>
<span class="line" id="L1168"></span>
<span class="line" id="L1169">        <span class="tok-kw">const</span> addr = Address.parseExpectingFamily(ip_text, family, port) <span class="tok-kw">catch</span> |err| <span class="tok-kw">switch</span> (err) {</span>
<span class="line" id="L1170">            <span class="tok-kw">error</span>.Overflow,</span>
<span class="line" id="L1171">            <span class="tok-kw">error</span>.InvalidEnd,</span>
<span class="line" id="L1172">            <span class="tok-kw">error</span>.InvalidCharacter,</span>
<span class="line" id="L1173">            <span class="tok-kw">error</span>.Incomplete,</span>
<span class="line" id="L1174">            <span class="tok-kw">error</span>.InvalidIPAddressFormat,</span>
<span class="line" id="L1175">            <span class="tok-kw">error</span>.InvalidIpv4Mapping,</span>
<span class="line" id="L1176">            <span class="tok-kw">error</span>.NonCanonical,</span>
<span class="line" id="L1177">            =&gt; <span class="tok-kw">continue</span>,</span>
<span class="line" id="L1178">        };</span>
<span class="line" id="L1179">        <span class="tok-kw">try</span> addrs.append(LookupAddr{ .addr = addr });</span>
<span class="line" id="L1180"></span>
<span class="line" id="L1181">        <span class="tok-comment">// first name is canonical name</span>
</span>
<span class="line" id="L1182">        <span class="tok-kw">const</span> name_text = first_name_text.?;</span>
<span class="line" id="L1183">        <span class="tok-kw">if</span> (isValidHostName(name_text)) {</span>
<span class="line" id="L1184">            canon.items.len = <span class="tok-number">0</span>;</span>
<span class="line" id="L1185">            <span class="tok-kw">try</span> canon.appendSlice(name_text);</span>
<span class="line" id="L1186">        }</span>
<span class="line" id="L1187">    }</span>
<span class="line" id="L1188">}</span>
<span class="line" id="L1189"></span>
<span class="line" id="L1190"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">isValidHostName</span>(hostname: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) <span class="tok-type">bool</span> {</span>
<span class="line" id="L1191">    <span class="tok-kw">if</span> (hostname.len &gt;= <span class="tok-number">254</span>) <span class="tok-kw">return</span> <span class="tok-null">false</span>;</span>
<span class="line" id="L1192">    <span class="tok-kw">if</span> (!std.unicode.utf8ValidateSlice(hostname)) <span class="tok-kw">return</span> <span class="tok-null">false</span>;</span>
<span class="line" id="L1193">    <span class="tok-kw">for</span> (hostname) |byte| {</span>
<span class="line" id="L1194">        <span class="tok-kw">if</span> (byte &gt;= <span class="tok-number">0x80</span> <span class="tok-kw">or</span> byte == <span class="tok-str">'.'</span> <span class="tok-kw">or</span> byte == <span class="tok-str">'-'</span> <span class="tok-kw">or</span> std.ascii.isAlNum(byte)) {</span>
<span class="line" id="L1195">            <span class="tok-kw">continue</span>;</span>
<span class="line" id="L1196">        }</span>
<span class="line" id="L1197">        <span class="tok-kw">return</span> <span class="tok-null">false</span>;</span>
<span class="line" id="L1198">    }</span>
<span class="line" id="L1199">    <span class="tok-kw">return</span> <span class="tok-null">true</span>;</span>
<span class="line" id="L1200">}</span>
<span class="line" id="L1201"></span>
<span class="line" id="L1202"><span class="tok-kw">fn</span> <span class="tok-fn">linuxLookupNameFromDnsSearch</span>(</span>
<span class="line" id="L1203">    addrs: *std.ArrayList(LookupAddr),</span>
<span class="line" id="L1204">    canon: *std.ArrayList(<span class="tok-type">u8</span>),</span>
<span class="line" id="L1205">    name: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L1206">    family: os.sa_family_t,</span>
<span class="line" id="L1207">    port: <span class="tok-type">u16</span>,</span>
<span class="line" id="L1208">) !<span class="tok-type">void</span> {</span>
<span class="line" id="L1209">    <span class="tok-kw">var</span> rc: ResolvConf = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L1210">    <span class="tok-kw">try</span> getResolvConf(addrs.allocator, &amp;rc);</span>
<span class="line" id="L1211">    <span class="tok-kw">defer</span> rc.deinit();</span>
<span class="line" id="L1212"></span>
<span class="line" id="L1213">    <span class="tok-comment">// Count dots, suppress search when &gt;=ndots or name ends in</span>
</span>
<span class="line" id="L1214">    <span class="tok-comment">// a dot, which is an explicit request for global scope.</span>
</span>
<span class="line" id="L1215">    <span class="tok-kw">var</span> dots: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L1216">    <span class="tok-kw">for</span> (name) |byte| {</span>
<span class="line" id="L1217">        <span class="tok-kw">if</span> (byte == <span class="tok-str">'.'</span>) dots += <span class="tok-number">1</span>;</span>
<span class="line" id="L1218">    }</span>
<span class="line" id="L1219"></span>
<span class="line" id="L1220">    <span class="tok-kw">const</span> search = <span class="tok-kw">if</span> (dots &gt;= rc.ndots <span class="tok-kw">or</span> mem.endsWith(<span class="tok-type">u8</span>, name, <span class="tok-str">&quot;.&quot;</span>))</span>
<span class="line" id="L1221">        <span class="tok-str">&quot;&quot;</span></span>
<span class="line" id="L1222">    <span class="tok-kw">else</span></span>
<span class="line" id="L1223">        rc.search.items;</span>
<span class="line" id="L1224"></span>
<span class="line" id="L1225">    <span class="tok-kw">var</span> canon_name = name;</span>
<span class="line" id="L1226"></span>
<span class="line" id="L1227">    <span class="tok-comment">// Strip final dot for canon, fail if multiple trailing dots.</span>
</span>
<span class="line" id="L1228">    <span class="tok-kw">if</span> (mem.endsWith(<span class="tok-type">u8</span>, canon_name, <span class="tok-str">&quot;.&quot;</span>)) canon_name.len -= <span class="tok-number">1</span>;</span>
<span class="line" id="L1229">    <span class="tok-kw">if</span> (mem.endsWith(<span class="tok-type">u8</span>, canon_name, <span class="tok-str">&quot;.&quot;</span>)) <span class="tok-kw">return</span> <span class="tok-kw">error</span>.UnknownHostName;</span>
<span class="line" id="L1230"></span>
<span class="line" id="L1231">    <span class="tok-comment">// Name with search domain appended is setup in canon[]. This both</span>
</span>
<span class="line" id="L1232">    <span class="tok-comment">// provides the desired default canonical name (if the requested</span>
</span>
<span class="line" id="L1233">    <span class="tok-comment">// name is not a CNAME record) and serves as a buffer for passing</span>
</span>
<span class="line" id="L1234">    <span class="tok-comment">// the full requested name to name_from_dns.</span>
</span>
<span class="line" id="L1235">    <span class="tok-kw">try</span> canon.resize(canon_name.len);</span>
<span class="line" id="L1236">    mem.copy(<span class="tok-type">u8</span>, canon.items, canon_name);</span>
<span class="line" id="L1237">    <span class="tok-kw">try</span> canon.append(<span class="tok-str">'.'</span>);</span>
<span class="line" id="L1238"></span>
<span class="line" id="L1239">    <span class="tok-kw">var</span> tok_it = mem.tokenize(<span class="tok-type">u8</span>, search, <span class="tok-str">&quot; \t&quot;</span>);</span>
<span class="line" id="L1240">    <span class="tok-kw">while</span> (tok_it.next()) |tok| {</span>
<span class="line" id="L1241">        canon.shrinkRetainingCapacity(canon_name.len + <span class="tok-number">1</span>);</span>
<span class="line" id="L1242">        <span class="tok-kw">try</span> canon.appendSlice(tok);</span>
<span class="line" id="L1243">        <span class="tok-kw">try</span> linuxLookupNameFromDns(addrs, canon, canon.items, family, rc, port);</span>
<span class="line" id="L1244">        <span class="tok-kw">if</span> (addrs.items.len != <span class="tok-number">0</span>) <span class="tok-kw">return</span>;</span>
<span class="line" id="L1245">    }</span>
<span class="line" id="L1246"></span>
<span class="line" id="L1247">    canon.shrinkRetainingCapacity(canon_name.len);</span>
<span class="line" id="L1248">    <span class="tok-kw">return</span> linuxLookupNameFromDns(addrs, canon, name, family, rc, port);</span>
<span class="line" id="L1249">}</span>
<span class="line" id="L1250"></span>
<span class="line" id="L1251"><span class="tok-kw">const</span> dpc_ctx = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L1252">    addrs: *std.ArrayList(LookupAddr),</span>
<span class="line" id="L1253">    canon: *std.ArrayList(<span class="tok-type">u8</span>),</span>
<span class="line" id="L1254">    port: <span class="tok-type">u16</span>,</span>
<span class="line" id="L1255">};</span>
<span class="line" id="L1256"></span>
<span class="line" id="L1257"><span class="tok-kw">fn</span> <span class="tok-fn">linuxLookupNameFromDns</span>(</span>
<span class="line" id="L1258">    addrs: *std.ArrayList(LookupAddr),</span>
<span class="line" id="L1259">    canon: *std.ArrayList(<span class="tok-type">u8</span>),</span>
<span class="line" id="L1260">    name: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L1261">    family: os.sa_family_t,</span>
<span class="line" id="L1262">    rc: ResolvConf,</span>
<span class="line" id="L1263">    port: <span class="tok-type">u16</span>,</span>
<span class="line" id="L1264">) !<span class="tok-type">void</span> {</span>
<span class="line" id="L1265">    <span class="tok-kw">var</span> ctx = dpc_ctx{</span>
<span class="line" id="L1266">        .addrs = addrs,</span>
<span class="line" id="L1267">        .canon = canon,</span>
<span class="line" id="L1268">        .port = port,</span>
<span class="line" id="L1269">    };</span>
<span class="line" id="L1270">    <span class="tok-kw">const</span> AfRr = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L1271">        af: os.sa_family_t,</span>
<span class="line" id="L1272">        rr: <span class="tok-type">u8</span>,</span>
<span class="line" id="L1273">    };</span>
<span class="line" id="L1274">    <span class="tok-kw">const</span> afrrs = [_]AfRr{</span>
<span class="line" id="L1275">        AfRr{ .af = os.AF.INET6, .rr = os.RR.A },</span>
<span class="line" id="L1276">        AfRr{ .af = os.AF.INET, .rr = os.RR.AAAA },</span>
<span class="line" id="L1277">    };</span>
<span class="line" id="L1278">    <span class="tok-kw">var</span> qbuf: [<span class="tok-number">2</span>][<span class="tok-number">280</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L1279">    <span class="tok-kw">var</span> abuf: [<span class="tok-number">2</span>][<span class="tok-number">512</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L1280">    <span class="tok-kw">var</span> qp: [<span class="tok-number">2</span>][]<span class="tok-kw">const</span> <span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L1281">    <span class="tok-kw">const</span> apbuf = [<span class="tok-number">2</span>][]<span class="tok-type">u8</span>{ &amp;abuf[<span class="tok-number">0</span>], &amp;abuf[<span class="tok-number">1</span>] };</span>
<span class="line" id="L1282">    <span class="tok-kw">var</span> nq: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L1283"></span>
<span class="line" id="L1284">    <span class="tok-kw">for</span> (afrrs) |afrr| {</span>
<span class="line" id="L1285">        <span class="tok-kw">if</span> (family != afrr.af) {</span>
<span class="line" id="L1286">            <span class="tok-kw">const</span> len = os.res_mkquery(<span class="tok-number">0</span>, name, <span class="tok-number">1</span>, afrr.rr, &amp;[_]<span class="tok-type">u8</span>{}, <span class="tok-null">null</span>, &amp;qbuf[nq]);</span>
<span class="line" id="L1287">            qp[nq] = qbuf[nq][<span class="tok-number">0</span>..len];</span>
<span class="line" id="L1288">            nq += <span class="tok-number">1</span>;</span>
<span class="line" id="L1289">        }</span>
<span class="line" id="L1290">    }</span>
<span class="line" id="L1291"></span>
<span class="line" id="L1292">    <span class="tok-kw">var</span> ap = [<span class="tok-number">2</span>][]<span class="tok-type">u8</span>{ apbuf[<span class="tok-number">0</span>], apbuf[<span class="tok-number">1</span>] };</span>
<span class="line" id="L1293">    ap[<span class="tok-number">0</span>].len = <span class="tok-number">0</span>;</span>
<span class="line" id="L1294">    ap[<span class="tok-number">1</span>].len = <span class="tok-number">0</span>;</span>
<span class="line" id="L1295"></span>
<span class="line" id="L1296">    <span class="tok-kw">try</span> resMSendRc(qp[<span class="tok-number">0</span>..nq], ap[<span class="tok-number">0</span>..nq], apbuf[<span class="tok-number">0</span>..nq], rc);</span>
<span class="line" id="L1297"></span>
<span class="line" id="L1298">    <span class="tok-kw">var</span> i: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L1299">    <span class="tok-kw">while</span> (i &lt; nq) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L1300">        dnsParse(ap[i], ctx, dnsParseCallback) <span class="tok-kw">catch</span> {};</span>
<span class="line" id="L1301">    }</span>
<span class="line" id="L1302"></span>
<span class="line" id="L1303">    <span class="tok-kw">if</span> (addrs.items.len != <span class="tok-number">0</span>) <span class="tok-kw">return</span>;</span>
<span class="line" id="L1304">    <span class="tok-kw">if</span> (ap[<span class="tok-number">0</span>].len &lt; <span class="tok-number">4</span> <span class="tok-kw">or</span> (ap[<span class="tok-number">0</span>][<span class="tok-number">3</span>] &amp; <span class="tok-number">15</span>) == <span class="tok-number">2</span>) <span class="tok-kw">return</span> <span class="tok-kw">error</span>.TemporaryNameServerFailure;</span>
<span class="line" id="L1305">    <span class="tok-kw">if</span> ((ap[<span class="tok-number">0</span>][<span class="tok-number">3</span>] &amp; <span class="tok-number">15</span>) == <span class="tok-number">0</span>) <span class="tok-kw">return</span> <span class="tok-kw">error</span>.UnknownHostName;</span>
<span class="line" id="L1306">    <span class="tok-kw">if</span> ((ap[<span class="tok-number">0</span>][<span class="tok-number">3</span>] &amp; <span class="tok-number">15</span>) == <span class="tok-number">3</span>) <span class="tok-kw">return</span>;</span>
<span class="line" id="L1307">    <span class="tok-kw">return</span> <span class="tok-kw">error</span>.NameServerFailure;</span>
<span class="line" id="L1308">}</span>
<span class="line" id="L1309"></span>
<span class="line" id="L1310"><span class="tok-kw">const</span> ResolvConf = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L1311">    attempts: <span class="tok-type">u32</span>,</span>
<span class="line" id="L1312">    ndots: <span class="tok-type">u32</span>,</span>
<span class="line" id="L1313">    timeout: <span class="tok-type">u32</span>,</span>
<span class="line" id="L1314">    search: std.ArrayList(<span class="tok-type">u8</span>),</span>
<span class="line" id="L1315">    ns: std.ArrayList(LookupAddr),</span>
<span class="line" id="L1316"></span>
<span class="line" id="L1317">    <span class="tok-kw">fn</span> <span class="tok-fn">deinit</span>(rc: *ResolvConf) <span class="tok-type">void</span> {</span>
<span class="line" id="L1318">        rc.ns.deinit();</span>
<span class="line" id="L1319">        rc.search.deinit();</span>
<span class="line" id="L1320">        rc.* = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L1321">    }</span>
<span class="line" id="L1322">};</span>
<span class="line" id="L1323"></span>
<span class="line" id="L1324"><span class="tok-comment">/// Ignores lines longer than 512 bytes.</span></span>
<span class="line" id="L1325"><span class="tok-comment">/// TODO: https://github.com/ziglang/zig/issues/2765 and https://github.com/ziglang/zig/issues/2761</span></span>
<span class="line" id="L1326"><span class="tok-kw">fn</span> <span class="tok-fn">getResolvConf</span>(allocator: mem.Allocator, rc: *ResolvConf) !<span class="tok-type">void</span> {</span>
<span class="line" id="L1327">    rc.* = ResolvConf{</span>
<span class="line" id="L1328">        .ns = std.ArrayList(LookupAddr).init(allocator),</span>
<span class="line" id="L1329">        .search = std.ArrayList(<span class="tok-type">u8</span>).init(allocator),</span>
<span class="line" id="L1330">        .ndots = <span class="tok-number">1</span>,</span>
<span class="line" id="L1331">        .timeout = <span class="tok-number">5</span>,</span>
<span class="line" id="L1332">        .attempts = <span class="tok-number">2</span>,</span>
<span class="line" id="L1333">    };</span>
<span class="line" id="L1334">    <span class="tok-kw">errdefer</span> rc.deinit();</span>
<span class="line" id="L1335"></span>
<span class="line" id="L1336">    <span class="tok-kw">const</span> file = fs.openFileAbsoluteZ(<span class="tok-str">&quot;/etc/resolv.conf&quot;</span>, .{}) <span class="tok-kw">catch</span> |err| <span class="tok-kw">switch</span> (err) {</span>
<span class="line" id="L1337">        <span class="tok-kw">error</span>.FileNotFound,</span>
<span class="line" id="L1338">        <span class="tok-kw">error</span>.NotDir,</span>
<span class="line" id="L1339">        <span class="tok-kw">error</span>.AccessDenied,</span>
<span class="line" id="L1340">        =&gt; <span class="tok-kw">return</span> linuxLookupNameFromNumericUnspec(&amp;rc.ns, <span class="tok-str">&quot;127.0.0.1&quot;</span>, <span class="tok-number">53</span>),</span>
<span class="line" id="L1341">        <span class="tok-kw">else</span> =&gt; |e| <span class="tok-kw">return</span> e,</span>
<span class="line" id="L1342">    };</span>
<span class="line" id="L1343">    <span class="tok-kw">defer</span> file.close();</span>
<span class="line" id="L1344"></span>
<span class="line" id="L1345">    <span class="tok-kw">var</span> buf_reader = std.io.bufferedReader(file.reader());</span>
<span class="line" id="L1346">    <span class="tok-kw">const</span> stream = buf_reader.reader();</span>
<span class="line" id="L1347">    <span class="tok-kw">var</span> line_buf: [<span class="tok-number">512</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L1348">    <span class="tok-kw">while</span> (stream.readUntilDelimiterOrEof(&amp;line_buf, <span class="tok-str">'\n'</span>) <span class="tok-kw">catch</span> |err| <span class="tok-kw">switch</span> (err) {</span>
<span class="line" id="L1349">        <span class="tok-kw">error</span>.StreamTooLong =&gt; blk: {</span>
<span class="line" id="L1350">            <span class="tok-comment">// Skip to the delimiter in the stream, to fix parsing</span>
</span>
<span class="line" id="L1351">            <span class="tok-kw">try</span> stream.skipUntilDelimiterOrEof(<span class="tok-str">'\n'</span>);</span>
<span class="line" id="L1352">            <span class="tok-comment">// Give an empty line to the while loop, which will be skipped.</span>
</span>
<span class="line" id="L1353">            <span class="tok-kw">break</span> :blk line_buf[<span class="tok-number">0</span>..<span class="tok-number">0</span>];</span>
<span class="line" id="L1354">        },</span>
<span class="line" id="L1355">        <span class="tok-kw">else</span> =&gt; |e| <span class="tok-kw">return</span> e,</span>
<span class="line" id="L1356">    }) |line| {</span>
<span class="line" id="L1357">        <span class="tok-kw">const</span> no_comment_line = no_comment_line: {</span>
<span class="line" id="L1358">            <span class="tok-kw">var</span> split = mem.split(<span class="tok-type">u8</span>, line, <span class="tok-str">&quot;#&quot;</span>);</span>
<span class="line" id="L1359">            <span class="tok-kw">break</span> :no_comment_line split.first();</span>
<span class="line" id="L1360">        };</span>
<span class="line" id="L1361">        <span class="tok-kw">var</span> line_it = mem.tokenize(<span class="tok-type">u8</span>, no_comment_line, <span class="tok-str">&quot; \t&quot;</span>);</span>
<span class="line" id="L1362"></span>
<span class="line" id="L1363">        <span class="tok-kw">const</span> token = line_it.next() <span class="tok-kw">orelse</span> <span class="tok-kw">continue</span>;</span>
<span class="line" id="L1364">        <span class="tok-kw">if</span> (mem.eql(<span class="tok-type">u8</span>, token, <span class="tok-str">&quot;options&quot;</span>)) {</span>
<span class="line" id="L1365">            <span class="tok-kw">while</span> (line_it.next()) |sub_tok| {</span>
<span class="line" id="L1366">                <span class="tok-kw">var</span> colon_it = mem.split(<span class="tok-type">u8</span>, sub_tok, <span class="tok-str">&quot;:&quot;</span>);</span>
<span class="line" id="L1367">                <span class="tok-kw">const</span> name = colon_it.first();</span>
<span class="line" id="L1368">                <span class="tok-kw">const</span> value_txt = colon_it.next() <span class="tok-kw">orelse</span> <span class="tok-kw">continue</span>;</span>
<span class="line" id="L1369">                <span class="tok-kw">const</span> value = std.fmt.parseInt(<span class="tok-type">u8</span>, value_txt, <span class="tok-number">10</span>) <span class="tok-kw">catch</span> |err| <span class="tok-kw">switch</span> (err) {</span>
<span class="line" id="L1370">                    <span class="tok-comment">// TODO https://github.com/ziglang/zig/issues/11812</span>
</span>
<span class="line" id="L1371">                    <span class="tok-kw">error</span>.Overflow =&gt; <span class="tok-builtin">@as</span>(<span class="tok-type">u8</span>, <span class="tok-number">255</span>),</span>
<span class="line" id="L1372">                    <span class="tok-kw">error</span>.InvalidCharacter =&gt; <span class="tok-kw">continue</span>,</span>
<span class="line" id="L1373">                };</span>
<span class="line" id="L1374">                <span class="tok-kw">if</span> (mem.eql(<span class="tok-type">u8</span>, name, <span class="tok-str">&quot;ndots&quot;</span>)) {</span>
<span class="line" id="L1375">                    rc.ndots = std.math.min(value, <span class="tok-number">15</span>);</span>
<span class="line" id="L1376">                } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (mem.eql(<span class="tok-type">u8</span>, name, <span class="tok-str">&quot;attempts&quot;</span>)) {</span>
<span class="line" id="L1377">                    rc.attempts = std.math.min(value, <span class="tok-number">10</span>);</span>
<span class="line" id="L1378">                } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (mem.eql(<span class="tok-type">u8</span>, name, <span class="tok-str">&quot;timeout&quot;</span>)) {</span>
<span class="line" id="L1379">                    rc.timeout = std.math.min(value, <span class="tok-number">60</span>);</span>
<span class="line" id="L1380">                }</span>
<span class="line" id="L1381">            }</span>
<span class="line" id="L1382">        } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (mem.eql(<span class="tok-type">u8</span>, token, <span class="tok-str">&quot;nameserver&quot;</span>)) {</span>
<span class="line" id="L1383">            <span class="tok-kw">const</span> ip_txt = line_it.next() <span class="tok-kw">orelse</span> <span class="tok-kw">continue</span>;</span>
<span class="line" id="L1384">            <span class="tok-kw">try</span> linuxLookupNameFromNumericUnspec(&amp;rc.ns, ip_txt, <span class="tok-number">53</span>);</span>
<span class="line" id="L1385">        } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (mem.eql(<span class="tok-type">u8</span>, token, <span class="tok-str">&quot;domain&quot;</span>) <span class="tok-kw">or</span> mem.eql(<span class="tok-type">u8</span>, token, <span class="tok-str">&quot;search&quot;</span>)) {</span>
<span class="line" id="L1386">            rc.search.items.len = <span class="tok-number">0</span>;</span>
<span class="line" id="L1387">            <span class="tok-kw">try</span> rc.search.appendSlice(line_it.rest());</span>
<span class="line" id="L1388">        }</span>
<span class="line" id="L1389">    }</span>
<span class="line" id="L1390"></span>
<span class="line" id="L1391">    <span class="tok-kw">if</span> (rc.ns.items.len == <span class="tok-number">0</span>) {</span>
<span class="line" id="L1392">        <span class="tok-kw">return</span> linuxLookupNameFromNumericUnspec(&amp;rc.ns, <span class="tok-str">&quot;127.0.0.1&quot;</span>, <span class="tok-number">53</span>);</span>
<span class="line" id="L1393">    }</span>
<span class="line" id="L1394">}</span>
<span class="line" id="L1395"></span>
<span class="line" id="L1396"><span class="tok-kw">fn</span> <span class="tok-fn">linuxLookupNameFromNumericUnspec</span>(</span>
<span class="line" id="L1397">    addrs: *std.ArrayList(LookupAddr),</span>
<span class="line" id="L1398">    name: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L1399">    port: <span class="tok-type">u16</span>,</span>
<span class="line" id="L1400">) !<span class="tok-type">void</span> {</span>
<span class="line" id="L1401">    <span class="tok-kw">const</span> addr = <span class="tok-kw">try</span> Address.resolveIp(name, port);</span>
<span class="line" id="L1402">    (<span class="tok-kw">try</span> addrs.addOne()).* = LookupAddr{ .addr = addr };</span>
<span class="line" id="L1403">}</span>
<span class="line" id="L1404"></span>
<span class="line" id="L1405"><span class="tok-kw">fn</span> <span class="tok-fn">resMSendRc</span>(</span>
<span class="line" id="L1406">    queries: []<span class="tok-kw">const</span> []<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L1407">    answers: [][]<span class="tok-type">u8</span>,</span>
<span class="line" id="L1408">    answer_bufs: []<span class="tok-kw">const</span> []<span class="tok-type">u8</span>,</span>
<span class="line" id="L1409">    rc: ResolvConf,</span>
<span class="line" id="L1410">) !<span class="tok-type">void</span> {</span>
<span class="line" id="L1411">    <span class="tok-kw">const</span> timeout = <span class="tok-number">1000</span> * rc.timeout;</span>
<span class="line" id="L1412">    <span class="tok-kw">const</span> attempts = rc.attempts;</span>
<span class="line" id="L1413"></span>
<span class="line" id="L1414">    <span class="tok-kw">var</span> sl: os.socklen_t = <span class="tok-builtin">@sizeOf</span>(os.sockaddr.in);</span>
<span class="line" id="L1415">    <span class="tok-kw">var</span> family: os.sa_family_t = os.AF.INET;</span>
<span class="line" id="L1416"></span>
<span class="line" id="L1417">    <span class="tok-kw">var</span> ns_list = std.ArrayList(Address).init(rc.ns.allocator);</span>
<span class="line" id="L1418">    <span class="tok-kw">defer</span> ns_list.deinit();</span>
<span class="line" id="L1419"></span>
<span class="line" id="L1420">    <span class="tok-kw">try</span> ns_list.resize(rc.ns.items.len);</span>
<span class="line" id="L1421">    <span class="tok-kw">const</span> ns = ns_list.items;</span>
<span class="line" id="L1422"></span>
<span class="line" id="L1423">    <span class="tok-kw">for</span> (rc.ns.items) |iplit, i| {</span>
<span class="line" id="L1424">        ns[i] = iplit.addr;</span>
<span class="line" id="L1425">        assert(ns[i].getPort() == <span class="tok-number">53</span>);</span>
<span class="line" id="L1426">        <span class="tok-kw">if</span> (iplit.addr.any.family != os.AF.INET) {</span>
<span class="line" id="L1427">            sl = <span class="tok-builtin">@sizeOf</span>(os.sockaddr.in6);</span>
<span class="line" id="L1428">            family = os.AF.INET6;</span>
<span class="line" id="L1429">        }</span>
<span class="line" id="L1430">    }</span>
<span class="line" id="L1431"></span>
<span class="line" id="L1432">    <span class="tok-comment">// Get local address and open/bind a socket</span>
</span>
<span class="line" id="L1433">    <span class="tok-kw">var</span> sa: Address = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L1434">    <span class="tok-builtin">@memset</span>(<span class="tok-builtin">@ptrCast</span>([*]<span class="tok-type">u8</span>, &amp;sa), <span class="tok-number">0</span>, <span class="tok-builtin">@sizeOf</span>(Address));</span>
<span class="line" id="L1435">    sa.any.family = family;</span>
<span class="line" id="L1436">    <span class="tok-kw">const</span> flags = os.SOCK.DGRAM | os.SOCK.CLOEXEC | os.SOCK.NONBLOCK;</span>
<span class="line" id="L1437">    <span class="tok-kw">const</span> fd = os.socket(family, flags, <span class="tok-number">0</span>) <span class="tok-kw">catch</span> |err| <span class="tok-kw">switch</span> (err) {</span>
<span class="line" id="L1438">        <span class="tok-kw">error</span>.AddressFamilyNotSupported =&gt; blk: {</span>
<span class="line" id="L1439">            <span class="tok-comment">// Handle case where system lacks IPv6 support</span>
</span>
<span class="line" id="L1440">            <span class="tok-kw">if</span> (family == os.AF.INET6) {</span>
<span class="line" id="L1441">                family = os.AF.INET;</span>
<span class="line" id="L1442">                <span class="tok-kw">break</span> :blk <span class="tok-kw">try</span> os.socket(os.AF.INET, flags, <span class="tok-number">0</span>);</span>
<span class="line" id="L1443">            }</span>
<span class="line" id="L1444">            <span class="tok-kw">return</span> err;</span>
<span class="line" id="L1445">        },</span>
<span class="line" id="L1446">        <span class="tok-kw">else</span> =&gt; |e| <span class="tok-kw">return</span> e,</span>
<span class="line" id="L1447">    };</span>
<span class="line" id="L1448">    <span class="tok-kw">defer</span> os.closeSocket(fd);</span>
<span class="line" id="L1449">    <span class="tok-kw">try</span> os.bind(fd, &amp;sa.any, sl);</span>
<span class="line" id="L1450"></span>
<span class="line" id="L1451">    <span class="tok-comment">// Past this point, there are no errors. Each individual query will</span>
</span>
<span class="line" id="L1452">    <span class="tok-comment">// yield either no reply (indicated by zero length) or an answer</span>
</span>
<span class="line" id="L1453">    <span class="tok-comment">// packet which is up to the caller to interpret.</span>
</span>
<span class="line" id="L1454"></span>
<span class="line" id="L1455">    <span class="tok-comment">// Convert any IPv4 addresses in a mixed environment to v4-mapped</span>
</span>
<span class="line" id="L1456">    <span class="tok-comment">// TODO</span>
</span>
<span class="line" id="L1457">    <span class="tok-comment">//if (family == AF.INET6) {</span>
</span>
<span class="line" id="L1458">    <span class="tok-comment">//    setsockopt(fd, IPPROTO.IPV6, IPV6_V6ONLY, &amp;(int){0}, sizeof 0);</span>
</span>
<span class="line" id="L1459">    <span class="tok-comment">//    for (i=0; i&lt;nns; i++) {</span>
</span>
<span class="line" id="L1460">    <span class="tok-comment">//        if (ns[i].sin.sin_family != AF.INET) continue;</span>
</span>
<span class="line" id="L1461">    <span class="tok-comment">//        memcpy(ns[i].sin6.sin6_addr.s6_addr+12,</span>
</span>
<span class="line" id="L1462">    <span class="tok-comment">//            &amp;ns[i].sin.sin_addr, 4);</span>
</span>
<span class="line" id="L1463">    <span class="tok-comment">//        memcpy(ns[i].sin6.sin6_addr.s6_addr,</span>
</span>
<span class="line" id="L1464">    <span class="tok-comment">//            &quot;\0\0\0\0\0\0\0\0\0\0\xff\xff&quot;, 12);</span>
</span>
<span class="line" id="L1465">    <span class="tok-comment">//        ns[i].sin6.sin6_family = AF.INET6;</span>
</span>
<span class="line" id="L1466">    <span class="tok-comment">//        ns[i].sin6.sin6_flowinfo = 0;</span>
</span>
<span class="line" id="L1467">    <span class="tok-comment">//        ns[i].sin6.sin6_scope_id = 0;</span>
</span>
<span class="line" id="L1468">    <span class="tok-comment">//    }</span>
</span>
<span class="line" id="L1469">    <span class="tok-comment">//}</span>
</span>
<span class="line" id="L1470"></span>
<span class="line" id="L1471">    <span class="tok-kw">var</span> pfd = [<span class="tok-number">1</span>]os.pollfd{os.pollfd{</span>
<span class="line" id="L1472">        .fd = fd,</span>
<span class="line" id="L1473">        .events = os.POLL.IN,</span>
<span class="line" id="L1474">        .revents = <span class="tok-null">undefined</span>,</span>
<span class="line" id="L1475">    }};</span>
<span class="line" id="L1476">    <span class="tok-kw">const</span> retry_interval = timeout / attempts;</span>
<span class="line" id="L1477">    <span class="tok-kw">var</span> next: <span class="tok-type">u32</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L1478">    <span class="tok-kw">var</span> t2: <span class="tok-type">u64</span> = <span class="tok-builtin">@bitCast</span>(<span class="tok-type">u64</span>, std.time.milliTimestamp());</span>
<span class="line" id="L1479">    <span class="tok-kw">var</span> t0 = t2;</span>
<span class="line" id="L1480">    <span class="tok-kw">var</span> t1 = t2 - retry_interval;</span>
<span class="line" id="L1481"></span>
<span class="line" id="L1482">    <span class="tok-kw">var</span> servfail_retry: <span class="tok-type">usize</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L1483"></span>
<span class="line" id="L1484">    outer: <span class="tok-kw">while</span> (t2 - t0 &lt; timeout) : (t2 = <span class="tok-builtin">@bitCast</span>(<span class="tok-type">u64</span>, std.time.milliTimestamp())) {</span>
<span class="line" id="L1485">        <span class="tok-kw">if</span> (t2 - t1 &gt;= retry_interval) {</span>
<span class="line" id="L1486">            <span class="tok-comment">// Query all configured nameservers in parallel</span>
</span>
<span class="line" id="L1487">            <span class="tok-kw">var</span> i: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L1488">            <span class="tok-kw">while</span> (i &lt; queries.len) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L1489">                <span class="tok-kw">if</span> (answers[i].len == <span class="tok-number">0</span>) {</span>
<span class="line" id="L1490">                    <span class="tok-kw">var</span> j: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L1491">                    <span class="tok-kw">while</span> (j &lt; ns.len) : (j += <span class="tok-number">1</span>) {</span>
<span class="line" id="L1492">                        <span class="tok-kw">if</span> (std.io.is_async) {</span>
<span class="line" id="L1493">                            _ = std.event.Loop.instance.?.sendto(fd, queries[i], os.MSG.NOSIGNAL, &amp;ns[j].any, sl) <span class="tok-kw">catch</span> <span class="tok-null">undefined</span>;</span>
<span class="line" id="L1494">                        } <span class="tok-kw">else</span> {</span>
<span class="line" id="L1495">                            _ = os.sendto(fd, queries[i], os.MSG.NOSIGNAL, &amp;ns[j].any, sl) <span class="tok-kw">catch</span> <span class="tok-null">undefined</span>;</span>
<span class="line" id="L1496">                        }</span>
<span class="line" id="L1497">                    }</span>
<span class="line" id="L1498">                }</span>
<span class="line" id="L1499">            }</span>
<span class="line" id="L1500">            t1 = t2;</span>
<span class="line" id="L1501">            servfail_retry = <span class="tok-number">2</span> * queries.len;</span>
<span class="line" id="L1502">        }</span>
<span class="line" id="L1503"></span>
<span class="line" id="L1504">        <span class="tok-comment">// Wait for a response, or until time to retry</span>
</span>
<span class="line" id="L1505">        <span class="tok-kw">const</span> clamped_timeout = std.math.min(<span class="tok-builtin">@as</span>(<span class="tok-type">u31</span>, std.math.maxInt(<span class="tok-type">u31</span>)), t1 + retry_interval - t2);</span>
<span class="line" id="L1506">        <span class="tok-kw">const</span> nevents = os.poll(&amp;pfd, clamped_timeout) <span class="tok-kw">catch</span> <span class="tok-number">0</span>;</span>
<span class="line" id="L1507">        <span class="tok-kw">if</span> (nevents == <span class="tok-number">0</span>) <span class="tok-kw">continue</span>;</span>
<span class="line" id="L1508"></span>
<span class="line" id="L1509">        <span class="tok-kw">while</span> (<span class="tok-null">true</span>) {</span>
<span class="line" id="L1510">            <span class="tok-kw">var</span> sl_copy = sl;</span>
<span class="line" id="L1511">            <span class="tok-kw">const</span> rlen = <span class="tok-kw">if</span> (std.io.is_async)</span>
<span class="line" id="L1512">                std.event.Loop.instance.?.recvfrom(fd, answer_bufs[next], <span class="tok-number">0</span>, &amp;sa.any, &amp;sl_copy) <span class="tok-kw">catch</span> <span class="tok-kw">break</span></span>
<span class="line" id="L1513">            <span class="tok-kw">else</span></span>
<span class="line" id="L1514">                os.recvfrom(fd, answer_bufs[next], <span class="tok-number">0</span>, &amp;sa.any, &amp;sl_copy) <span class="tok-kw">catch</span> <span class="tok-kw">break</span>;</span>
<span class="line" id="L1515"></span>
<span class="line" id="L1516">            <span class="tok-comment">// Ignore non-identifiable packets</span>
</span>
<span class="line" id="L1517">            <span class="tok-kw">if</span> (rlen &lt; <span class="tok-number">4</span>) <span class="tok-kw">continue</span>;</span>
<span class="line" id="L1518"></span>
<span class="line" id="L1519">            <span class="tok-comment">// Ignore replies from addresses we didn't send to</span>
</span>
<span class="line" id="L1520">            <span class="tok-kw">var</span> j: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L1521">            <span class="tok-kw">while</span> (j &lt; ns.len <span class="tok-kw">and</span> !ns[j].eql(sa)) : (j += <span class="tok-number">1</span>) {}</span>
<span class="line" id="L1522">            <span class="tok-kw">if</span> (j == ns.len) <span class="tok-kw">continue</span>;</span>
<span class="line" id="L1523"></span>
<span class="line" id="L1524">            <span class="tok-comment">// Find which query this answer goes with, if any</span>
</span>
<span class="line" id="L1525">            <span class="tok-kw">var</span> i: <span class="tok-type">usize</span> = next;</span>
<span class="line" id="L1526">            <span class="tok-kw">while</span> (i &lt; queries.len <span class="tok-kw">and</span> (answer_bufs[next][<span class="tok-number">0</span>] != queries[i][<span class="tok-number">0</span>] <span class="tok-kw">or</span></span>
<span class="line" id="L1527">                answer_bufs[next][<span class="tok-number">1</span>] != queries[i][<span class="tok-number">1</span>])) : (i += <span class="tok-number">1</span>)</span>
<span class="line" id="L1528">            {}</span>
<span class="line" id="L1529"></span>
<span class="line" id="L1530">            <span class="tok-kw">if</span> (i == queries.len) <span class="tok-kw">continue</span>;</span>
<span class="line" id="L1531">            <span class="tok-kw">if</span> (answers[i].len != <span class="tok-number">0</span>) <span class="tok-kw">continue</span>;</span>
<span class="line" id="L1532"></span>
<span class="line" id="L1533">            <span class="tok-comment">// Only accept positive or negative responses;</span>
</span>
<span class="line" id="L1534">            <span class="tok-comment">// retry immediately on server failure, and ignore</span>
</span>
<span class="line" id="L1535">            <span class="tok-comment">// all other codes such as refusal.</span>
</span>
<span class="line" id="L1536">            <span class="tok-kw">switch</span> (answer_bufs[next][<span class="tok-number">3</span>] &amp; <span class="tok-number">15</span>) {</span>
<span class="line" id="L1537">                <span class="tok-number">0</span>, <span class="tok-number">3</span> =&gt; {},</span>
<span class="line" id="L1538">                <span class="tok-number">2</span> =&gt; <span class="tok-kw">if</span> (servfail_retry != <span class="tok-number">0</span>) {</span>
<span class="line" id="L1539">                    servfail_retry -= <span class="tok-number">1</span>;</span>
<span class="line" id="L1540">                    <span class="tok-kw">if</span> (std.io.is_async) {</span>
<span class="line" id="L1541">                        _ = std.event.Loop.instance.?.sendto(fd, queries[i], os.MSG.NOSIGNAL, &amp;ns[j].any, sl) <span class="tok-kw">catch</span> <span class="tok-null">undefined</span>;</span>
<span class="line" id="L1542">                    } <span class="tok-kw">else</span> {</span>
<span class="line" id="L1543">                        _ = os.sendto(fd, queries[i], os.MSG.NOSIGNAL, &amp;ns[j].any, sl) <span class="tok-kw">catch</span> <span class="tok-null">undefined</span>;</span>
<span class="line" id="L1544">                    }</span>
<span class="line" id="L1545">                },</span>
<span class="line" id="L1546">                <span class="tok-kw">else</span> =&gt; <span class="tok-kw">continue</span>,</span>
<span class="line" id="L1547">            }</span>
<span class="line" id="L1548"></span>
<span class="line" id="L1549">            <span class="tok-comment">// Store answer in the right slot, or update next</span>
</span>
<span class="line" id="L1550">            <span class="tok-comment">// available temp slot if it's already in place.</span>
</span>
<span class="line" id="L1551">            answers[i].len = rlen;</span>
<span class="line" id="L1552">            <span class="tok-kw">if</span> (i == next) {</span>
<span class="line" id="L1553">                <span class="tok-kw">while</span> (next &lt; queries.len <span class="tok-kw">and</span> answers[next].len != <span class="tok-number">0</span>) : (next += <span class="tok-number">1</span>) {}</span>
<span class="line" id="L1554">            } <span class="tok-kw">else</span> {</span>
<span class="line" id="L1555">                mem.copy(<span class="tok-type">u8</span>, answer_bufs[i], answer_bufs[next][<span class="tok-number">0</span>..rlen]);</span>
<span class="line" id="L1556">            }</span>
<span class="line" id="L1557"></span>
<span class="line" id="L1558">            <span class="tok-kw">if</span> (next == queries.len) <span class="tok-kw">break</span> :outer;</span>
<span class="line" id="L1559">        }</span>
<span class="line" id="L1560">    }</span>
<span class="line" id="L1561">}</span>
<span class="line" id="L1562"></span>
<span class="line" id="L1563"><span class="tok-kw">fn</span> <span class="tok-fn">dnsParse</span>(</span>
<span class="line" id="L1564">    r: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L1565">    ctx: <span class="tok-kw">anytype</span>,</span>
<span class="line" id="L1566">    <span class="tok-kw">comptime</span> callback: <span class="tok-kw">anytype</span>,</span>
<span class="line" id="L1567">) !<span class="tok-type">void</span> {</span>
<span class="line" id="L1568">    <span class="tok-comment">// This implementation is ported from musl libc.</span>
</span>
<span class="line" id="L1569">    <span class="tok-comment">// A more idiomatic &quot;ziggy&quot; implementation would be welcome.</span>
</span>
<span class="line" id="L1570">    <span class="tok-kw">if</span> (r.len &lt; <span class="tok-number">12</span>) <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InvalidDnsPacket;</span>
<span class="line" id="L1571">    <span class="tok-kw">if</span> ((r[<span class="tok-number">3</span>] &amp; <span class="tok-number">15</span>) != <span class="tok-number">0</span>) <span class="tok-kw">return</span>;</span>
<span class="line" id="L1572">    <span class="tok-kw">var</span> p = r.ptr + <span class="tok-number">12</span>;</span>
<span class="line" id="L1573">    <span class="tok-kw">var</span> qdcount = r[<span class="tok-number">4</span>] * <span class="tok-builtin">@as</span>(<span class="tok-type">usize</span>, <span class="tok-number">256</span>) + r[<span class="tok-number">5</span>];</span>
<span class="line" id="L1574">    <span class="tok-kw">var</span> ancount = r[<span class="tok-number">6</span>] * <span class="tok-builtin">@as</span>(<span class="tok-type">usize</span>, <span class="tok-number">256</span>) + r[<span class="tok-number">7</span>];</span>
<span class="line" id="L1575">    <span class="tok-kw">if</span> (qdcount + ancount &gt; <span class="tok-number">64</span>) <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InvalidDnsPacket;</span>
<span class="line" id="L1576">    <span class="tok-kw">while</span> (qdcount != <span class="tok-number">0</span>) {</span>
<span class="line" id="L1577">        qdcount -= <span class="tok-number">1</span>;</span>
<span class="line" id="L1578">        <span class="tok-kw">while</span> (<span class="tok-builtin">@ptrToInt</span>(p) - <span class="tok-builtin">@ptrToInt</span>(r.ptr) &lt; r.len <span class="tok-kw">and</span> p[<span class="tok-number">0</span>] -% <span class="tok-number">1</span> &lt; <span class="tok-number">127</span>) p += <span class="tok-number">1</span>;</span>
<span class="line" id="L1579">        <span class="tok-kw">if</span> (p[<span class="tok-number">0</span>] &gt; <span class="tok-number">193</span> <span class="tok-kw">or</span> (p[<span class="tok-number">0</span>] == <span class="tok-number">193</span> <span class="tok-kw">and</span> p[<span class="tok-number">1</span>] &gt; <span class="tok-number">254</span>) <span class="tok-kw">or</span> <span class="tok-builtin">@ptrToInt</span>(p) &gt; <span class="tok-builtin">@ptrToInt</span>(r.ptr) + r.len - <span class="tok-number">6</span>)</span>
<span class="line" id="L1580">            <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InvalidDnsPacket;</span>
<span class="line" id="L1581">        p += <span class="tok-builtin">@as</span>(<span class="tok-type">usize</span>, <span class="tok-number">5</span>) + <span class="tok-builtin">@boolToInt</span>(p[<span class="tok-number">0</span>] != <span class="tok-number">0</span>);</span>
<span class="line" id="L1582">    }</span>
<span class="line" id="L1583">    <span class="tok-kw">while</span> (ancount != <span class="tok-number">0</span>) {</span>
<span class="line" id="L1584">        ancount -= <span class="tok-number">1</span>;</span>
<span class="line" id="L1585">        <span class="tok-kw">while</span> (<span class="tok-builtin">@ptrToInt</span>(p) - <span class="tok-builtin">@ptrToInt</span>(r.ptr) &lt; r.len <span class="tok-kw">and</span> p[<span class="tok-number">0</span>] -% <span class="tok-number">1</span> &lt; <span class="tok-number">127</span>) p += <span class="tok-number">1</span>;</span>
<span class="line" id="L1586">        <span class="tok-kw">if</span> (p[<span class="tok-number">0</span>] &gt; <span class="tok-number">193</span> <span class="tok-kw">or</span> (p[<span class="tok-number">0</span>] == <span class="tok-number">193</span> <span class="tok-kw">and</span> p[<span class="tok-number">1</span>] &gt; <span class="tok-number">254</span>) <span class="tok-kw">or</span> <span class="tok-builtin">@ptrToInt</span>(p) &gt; <span class="tok-builtin">@ptrToInt</span>(r.ptr) + r.len - <span class="tok-number">6</span>)</span>
<span class="line" id="L1587">            <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InvalidDnsPacket;</span>
<span class="line" id="L1588">        p += <span class="tok-builtin">@as</span>(<span class="tok-type">usize</span>, <span class="tok-number">1</span>) + <span class="tok-builtin">@boolToInt</span>(p[<span class="tok-number">0</span>] != <span class="tok-number">0</span>);</span>
<span class="line" id="L1589">        <span class="tok-kw">const</span> len = p[<span class="tok-number">8</span>] * <span class="tok-builtin">@as</span>(<span class="tok-type">usize</span>, <span class="tok-number">256</span>) + p[<span class="tok-number">9</span>];</span>
<span class="line" id="L1590">        <span class="tok-kw">if</span> (<span class="tok-builtin">@ptrToInt</span>(p) + len &gt; <span class="tok-builtin">@ptrToInt</span>(r.ptr) + r.len) <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InvalidDnsPacket;</span>
<span class="line" id="L1591">        <span class="tok-kw">try</span> callback(ctx, p[<span class="tok-number">1</span>], p[<span class="tok-number">10</span> .. <span class="tok-number">10</span> + len], r);</span>
<span class="line" id="L1592">        p += <span class="tok-number">10</span> + len;</span>
<span class="line" id="L1593">    }</span>
<span class="line" id="L1594">}</span>
<span class="line" id="L1595"></span>
<span class="line" id="L1596"><span class="tok-kw">fn</span> <span class="tok-fn">dnsParseCallback</span>(ctx: dpc_ctx, rr: <span class="tok-type">u8</span>, data: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, packet: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) !<span class="tok-type">void</span> {</span>
<span class="line" id="L1597">    <span class="tok-kw">switch</span> (rr) {</span>
<span class="line" id="L1598">        os.RR.A =&gt; {</span>
<span class="line" id="L1599">            <span class="tok-kw">if</span> (data.len != <span class="tok-number">4</span>) <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InvalidDnsARecord;</span>
<span class="line" id="L1600">            <span class="tok-kw">const</span> new_addr = <span class="tok-kw">try</span> ctx.addrs.addOne();</span>
<span class="line" id="L1601">            new_addr.* = LookupAddr{</span>
<span class="line" id="L1602">                .addr = Address.initIp4(data[<span class="tok-number">0</span>..<span class="tok-number">4</span>].*, ctx.port),</span>
<span class="line" id="L1603">            };</span>
<span class="line" id="L1604">        },</span>
<span class="line" id="L1605">        os.RR.AAAA =&gt; {</span>
<span class="line" id="L1606">            <span class="tok-kw">if</span> (data.len != <span class="tok-number">16</span>) <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InvalidDnsAAAARecord;</span>
<span class="line" id="L1607">            <span class="tok-kw">const</span> new_addr = <span class="tok-kw">try</span> ctx.addrs.addOne();</span>
<span class="line" id="L1608">            new_addr.* = LookupAddr{</span>
<span class="line" id="L1609">                .addr = Address.initIp6(data[<span class="tok-number">0</span>..<span class="tok-number">16</span>].*, ctx.port, <span class="tok-number">0</span>, <span class="tok-number">0</span>),</span>
<span class="line" id="L1610">            };</span>
<span class="line" id="L1611">        },</span>
<span class="line" id="L1612">        os.RR.CNAME =&gt; {</span>
<span class="line" id="L1613">            <span class="tok-kw">var</span> tmp: [<span class="tok-number">256</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L1614">            <span class="tok-comment">// Returns len of compressed name. strlen to get canon name.</span>
</span>
<span class="line" id="L1615">            _ = <span class="tok-kw">try</span> os.dn_expand(packet, data, &amp;tmp);</span>
<span class="line" id="L1616">            <span class="tok-kw">const</span> canon_name = mem.sliceTo(std.meta.assumeSentinel(&amp;tmp, <span class="tok-number">0</span>), <span class="tok-number">0</span>);</span>
<span class="line" id="L1617">            <span class="tok-kw">if</span> (isValidHostName(canon_name)) {</span>
<span class="line" id="L1618">                ctx.canon.items.len = <span class="tok-number">0</span>;</span>
<span class="line" id="L1619">                <span class="tok-kw">try</span> ctx.canon.appendSlice(canon_name);</span>
<span class="line" id="L1620">            }</span>
<span class="line" id="L1621">        },</span>
<span class="line" id="L1622">        <span class="tok-kw">else</span> =&gt; <span class="tok-kw">return</span>,</span>
<span class="line" id="L1623">    }</span>
<span class="line" id="L1624">}</span>
<span class="line" id="L1625"></span>
<span class="line" id="L1626"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> Stream = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L1627">    <span class="tok-comment">// Underlying socket descriptor.</span>
</span>
<span class="line" id="L1628">    <span class="tok-comment">// Note that on some platforms this may not be interchangeable with a</span>
</span>
<span class="line" id="L1629">    <span class="tok-comment">// regular files descriptor.</span>
</span>
<span class="line" id="L1630">    handle: os.socket_t,</span>
<span class="line" id="L1631"></span>
<span class="line" id="L1632">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">close</span>(self: Stream) <span class="tok-type">void</span> {</span>
<span class="line" id="L1633">        os.closeSocket(self.handle);</span>
<span class="line" id="L1634">    }</span>
<span class="line" id="L1635"></span>
<span class="line" id="L1636">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> ReadError = os.ReadError;</span>
<span class="line" id="L1637">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> WriteError = os.WriteError;</span>
<span class="line" id="L1638"></span>
<span class="line" id="L1639">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> Reader = io.Reader(Stream, ReadError, read);</span>
<span class="line" id="L1640">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> Writer = io.Writer(Stream, WriteError, write);</span>
<span class="line" id="L1641"></span>
<span class="line" id="L1642">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">reader</span>(self: Stream) Reader {</span>
<span class="line" id="L1643">        <span class="tok-kw">return</span> .{ .context = self };</span>
<span class="line" id="L1644">    }</span>
<span class="line" id="L1645"></span>
<span class="line" id="L1646">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">writer</span>(self: Stream) Writer {</span>
<span class="line" id="L1647">        <span class="tok-kw">return</span> .{ .context = self };</span>
<span class="line" id="L1648">    }</span>
<span class="line" id="L1649"></span>
<span class="line" id="L1650">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">read</span>(self: Stream, buffer: []<span class="tok-type">u8</span>) ReadError!<span class="tok-type">usize</span> {</span>
<span class="line" id="L1651">        <span class="tok-kw">if</span> (builtin.os.tag == .windows) {</span>
<span class="line" id="L1652">            <span class="tok-kw">return</span> os.windows.ReadFile(self.handle, buffer, <span class="tok-null">null</span>, io.default_mode);</span>
<span class="line" id="L1653">        }</span>
<span class="line" id="L1654"></span>
<span class="line" id="L1655">        <span class="tok-kw">if</span> (std.io.is_async) {</span>
<span class="line" id="L1656">            <span class="tok-kw">return</span> std.event.Loop.instance.?.read(self.handle, buffer, <span class="tok-null">false</span>);</span>
<span class="line" id="L1657">        } <span class="tok-kw">else</span> {</span>
<span class="line" id="L1658">            <span class="tok-kw">return</span> os.read(self.handle, buffer);</span>
<span class="line" id="L1659">        }</span>
<span class="line" id="L1660">    }</span>
<span class="line" id="L1661"></span>
<span class="line" id="L1662">    <span class="tok-comment">/// TODO in evented I/O mode, this implementation incorrectly uses the event loop's</span></span>
<span class="line" id="L1663">    <span class="tok-comment">/// file system thread instead of non-blocking. It needs to be reworked to properly</span></span>
<span class="line" id="L1664">    <span class="tok-comment">/// use non-blocking I/O.</span></span>
<span class="line" id="L1665">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">write</span>(self: Stream, buffer: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) WriteError!<span class="tok-type">usize</span> {</span>
<span class="line" id="L1666">        <span class="tok-kw">if</span> (builtin.os.tag == .windows) {</span>
<span class="line" id="L1667">            <span class="tok-kw">return</span> os.windows.WriteFile(self.handle, buffer, <span class="tok-null">null</span>, io.default_mode);</span>
<span class="line" id="L1668">        }</span>
<span class="line" id="L1669"></span>
<span class="line" id="L1670">        <span class="tok-kw">if</span> (std.io.is_async) {</span>
<span class="line" id="L1671">            <span class="tok-kw">return</span> std.event.Loop.instance.?.write(self.handle, buffer, <span class="tok-null">false</span>);</span>
<span class="line" id="L1672">        } <span class="tok-kw">else</span> {</span>
<span class="line" id="L1673">            <span class="tok-kw">return</span> os.write(self.handle, buffer);</span>
<span class="line" id="L1674">        }</span>
<span class="line" id="L1675">    }</span>
<span class="line" id="L1676"></span>
<span class="line" id="L1677">    <span class="tok-comment">/// See https://github.com/ziglang/zig/issues/7699</span></span>
<span class="line" id="L1678">    <span class="tok-comment">/// See equivalent function: `std.fs.File.writev`.</span></span>
<span class="line" id="L1679">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">writev</span>(self: Stream, iovecs: []<span class="tok-kw">const</span> os.iovec_const) WriteError!<span class="tok-type">usize</span> {</span>
<span class="line" id="L1680">        <span class="tok-kw">if</span> (std.io.is_async) {</span>
<span class="line" id="L1681">            <span class="tok-comment">// TODO improve to actually take advantage of writev syscall, if available.</span>
</span>
<span class="line" id="L1682">            <span class="tok-kw">if</span> (iovecs.len == <span class="tok-number">0</span>) <span class="tok-kw">return</span> <span class="tok-number">0</span>;</span>
<span class="line" id="L1683">            <span class="tok-kw">const</span> first_buffer = iovecs[<span class="tok-number">0</span>].iov_base[<span class="tok-number">0</span>..iovecs[<span class="tok-number">0</span>].iov_len];</span>
<span class="line" id="L1684">            <span class="tok-kw">try</span> self.write(first_buffer);</span>
<span class="line" id="L1685">            <span class="tok-kw">return</span> first_buffer.len;</span>
<span class="line" id="L1686">        } <span class="tok-kw">else</span> {</span>
<span class="line" id="L1687">            <span class="tok-kw">return</span> os.writev(self.handle, iovecs);</span>
<span class="line" id="L1688">        }</span>
<span class="line" id="L1689">    }</span>
<span class="line" id="L1690"></span>
<span class="line" id="L1691">    <span class="tok-comment">/// The `iovecs` parameter is mutable because this function needs to mutate the fields in</span></span>
<span class="line" id="L1692">    <span class="tok-comment">/// order to handle partial writes from the underlying OS layer.</span></span>
<span class="line" id="L1693">    <span class="tok-comment">/// See https://github.com/ziglang/zig/issues/7699</span></span>
<span class="line" id="L1694">    <span class="tok-comment">/// See equivalent function: `std.fs.File.writevAll`.</span></span>
<span class="line" id="L1695">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">writevAll</span>(self: Stream, iovecs: []os.iovec_const) WriteError!<span class="tok-type">void</span> {</span>
<span class="line" id="L1696">        <span class="tok-kw">if</span> (iovecs.len == <span class="tok-number">0</span>) <span class="tok-kw">return</span>;</span>
<span class="line" id="L1697"></span>
<span class="line" id="L1698">        <span class="tok-kw">var</span> i: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L1699">        <span class="tok-kw">while</span> (<span class="tok-null">true</span>) {</span>
<span class="line" id="L1700">            <span class="tok-kw">var</span> amt = <span class="tok-kw">try</span> self.writev(iovecs[i..]);</span>
<span class="line" id="L1701">            <span class="tok-kw">while</span> (amt &gt;= iovecs[i].iov_len) {</span>
<span class="line" id="L1702">                amt -= iovecs[i].iov_len;</span>
<span class="line" id="L1703">                i += <span class="tok-number">1</span>;</span>
<span class="line" id="L1704">                <span class="tok-kw">if</span> (i &gt;= iovecs.len) <span class="tok-kw">return</span>;</span>
<span class="line" id="L1705">            }</span>
<span class="line" id="L1706">            iovecs[i].iov_base += amt;</span>
<span class="line" id="L1707">            iovecs[i].iov_len -= amt;</span>
<span class="line" id="L1708">        }</span>
<span class="line" id="L1709">    }</span>
<span class="line" id="L1710">};</span>
<span class="line" id="L1711"></span>
<span class="line" id="L1712"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> StreamServer = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L1713">    <span class="tok-comment">/// Copied from `Options` on `init`.</span></span>
<span class="line" id="L1714">    kernel_backlog: <span class="tok-type">u31</span>,</span>
<span class="line" id="L1715">    reuse_address: <span class="tok-type">bool</span>,</span>
<span class="line" id="L1716"></span>
<span class="line" id="L1717">    <span class="tok-comment">/// `undefined` until `listen` returns successfully.</span></span>
<span class="line" id="L1718">    listen_address: Address,</span>
<span class="line" id="L1719"></span>
<span class="line" id="L1720">    sockfd: ?os.socket_t,</span>
<span class="line" id="L1721"></span>
<span class="line" id="L1722">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> Options = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L1723">        <span class="tok-comment">/// How many connections the kernel will accept on the application's behalf.</span></span>
<span class="line" id="L1724">        <span class="tok-comment">/// If more than this many connections pool in the kernel, clients will start</span></span>
<span class="line" id="L1725">        <span class="tok-comment">/// seeing &quot;Connection refused&quot;.</span></span>
<span class="line" id="L1726">        kernel_backlog: <span class="tok-type">u31</span> = <span class="tok-number">128</span>,</span>
<span class="line" id="L1727"></span>
<span class="line" id="L1728">        <span class="tok-comment">/// Enable SO.REUSEADDR on the socket.</span></span>
<span class="line" id="L1729">        reuse_address: <span class="tok-type">bool</span> = <span class="tok-null">false</span>,</span>
<span class="line" id="L1730">    };</span>
<span class="line" id="L1731"></span>
<span class="line" id="L1732">    <span class="tok-comment">/// After this call succeeds, resources have been acquired and must</span></span>
<span class="line" id="L1733">    <span class="tok-comment">/// be released with `deinit`.</span></span>
<span class="line" id="L1734">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">init</span>(options: Options) StreamServer {</span>
<span class="line" id="L1735">        <span class="tok-kw">return</span> StreamServer{</span>
<span class="line" id="L1736">            .sockfd = <span class="tok-null">null</span>,</span>
<span class="line" id="L1737">            .kernel_backlog = options.kernel_backlog,</span>
<span class="line" id="L1738">            .reuse_address = options.reuse_address,</span>
<span class="line" id="L1739">            .listen_address = <span class="tok-null">undefined</span>,</span>
<span class="line" id="L1740">        };</span>
<span class="line" id="L1741">    }</span>
<span class="line" id="L1742"></span>
<span class="line" id="L1743">    <span class="tok-comment">/// Release all resources. The `StreamServer` memory becomes `undefined`.</span></span>
<span class="line" id="L1744">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">deinit</span>(self: *StreamServer) <span class="tok-type">void</span> {</span>
<span class="line" id="L1745">        self.close();</span>
<span class="line" id="L1746">        self.* = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L1747">    }</span>
<span class="line" id="L1748"></span>
<span class="line" id="L1749">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">listen</span>(self: *StreamServer, address: Address) !<span class="tok-type">void</span> {</span>
<span class="line" id="L1750">        <span class="tok-kw">const</span> nonblock = <span class="tok-kw">if</span> (std.io.is_async) os.SOCK.NONBLOCK <span class="tok-kw">else</span> <span class="tok-number">0</span>;</span>
<span class="line" id="L1751">        <span class="tok-kw">const</span> sock_flags = os.SOCK.STREAM | os.SOCK.CLOEXEC | nonblock;</span>
<span class="line" id="L1752">        <span class="tok-kw">const</span> proto = <span class="tok-kw">if</span> (address.any.family == os.AF.UNIX) <span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">0</span>) <span class="tok-kw">else</span> os.IPPROTO.TCP;</span>
<span class="line" id="L1753"></span>
<span class="line" id="L1754">        <span class="tok-kw">const</span> sockfd = <span class="tok-kw">try</span> os.socket(address.any.family, sock_flags, proto);</span>
<span class="line" id="L1755">        self.sockfd = sockfd;</span>
<span class="line" id="L1756">        <span class="tok-kw">errdefer</span> {</span>
<span class="line" id="L1757">            os.closeSocket(sockfd);</span>
<span class="line" id="L1758">            self.sockfd = <span class="tok-null">null</span>;</span>
<span class="line" id="L1759">        }</span>
<span class="line" id="L1760"></span>
<span class="line" id="L1761">        <span class="tok-kw">if</span> (self.reuse_address) {</span>
<span class="line" id="L1762">            <span class="tok-kw">try</span> os.setsockopt(</span>
<span class="line" id="L1763">                sockfd,</span>
<span class="line" id="L1764">                os.SOL.SOCKET,</span>
<span class="line" id="L1765">                os.SO.REUSEADDR,</span>
<span class="line" id="L1766">                &amp;mem.toBytes(<span class="tok-builtin">@as</span>(<span class="tok-type">c_int</span>, <span class="tok-number">1</span>)),</span>
<span class="line" id="L1767">            );</span>
<span class="line" id="L1768">        }</span>
<span class="line" id="L1769"></span>
<span class="line" id="L1770">        <span class="tok-kw">var</span> socklen = address.getOsSockLen();</span>
<span class="line" id="L1771">        <span class="tok-kw">try</span> os.bind(sockfd, &amp;address.any, socklen);</span>
<span class="line" id="L1772">        <span class="tok-kw">try</span> os.listen(sockfd, self.kernel_backlog);</span>
<span class="line" id="L1773">        <span class="tok-kw">try</span> os.getsockname(sockfd, &amp;self.listen_address.any, &amp;socklen);</span>
<span class="line" id="L1774">    }</span>
<span class="line" id="L1775"></span>
<span class="line" id="L1776">    <span class="tok-comment">/// Stop listening. It is still necessary to call `deinit` after stopping listening.</span></span>
<span class="line" id="L1777">    <span class="tok-comment">/// Calling `deinit` will automatically call `close`. It is safe to call `close` when</span></span>
<span class="line" id="L1778">    <span class="tok-comment">/// not listening.</span></span>
<span class="line" id="L1779">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">close</span>(self: *StreamServer) <span class="tok-type">void</span> {</span>
<span class="line" id="L1780">        <span class="tok-kw">if</span> (self.sockfd) |fd| {</span>
<span class="line" id="L1781">            os.closeSocket(fd);</span>
<span class="line" id="L1782">            self.sockfd = <span class="tok-null">null</span>;</span>
<span class="line" id="L1783">            self.listen_address = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L1784">        }</span>
<span class="line" id="L1785">    }</span>
<span class="line" id="L1786"></span>
<span class="line" id="L1787">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> AcceptError = <span class="tok-kw">error</span>{</span>
<span class="line" id="L1788">        ConnectionAborted,</span>
<span class="line" id="L1789"></span>
<span class="line" id="L1790">        <span class="tok-comment">/// The per-process limit on the number of open file descriptors has been reached.</span></span>
<span class="line" id="L1791">        ProcessFdQuotaExceeded,</span>
<span class="line" id="L1792"></span>
<span class="line" id="L1793">        <span class="tok-comment">/// The system-wide limit on the total number of open files has been reached.</span></span>
<span class="line" id="L1794">        SystemFdQuotaExceeded,</span>
<span class="line" id="L1795"></span>
<span class="line" id="L1796">        <span class="tok-comment">/// Not enough free memory.  This often means that the memory allocation  is  limited</span></span>
<span class="line" id="L1797">        <span class="tok-comment">/// by the socket buffer limits, not by the system memory.</span></span>
<span class="line" id="L1798">        SystemResources,</span>
<span class="line" id="L1799"></span>
<span class="line" id="L1800">        <span class="tok-comment">/// Socket is not listening for new connections.</span></span>
<span class="line" id="L1801">        SocketNotListening,</span>
<span class="line" id="L1802"></span>
<span class="line" id="L1803">        ProtocolFailure,</span>
<span class="line" id="L1804"></span>
<span class="line" id="L1805">        <span class="tok-comment">/// Firewall rules forbid connection.</span></span>
<span class="line" id="L1806">        BlockedByFirewall,</span>
<span class="line" id="L1807"></span>
<span class="line" id="L1808">        FileDescriptorNotASocket,</span>
<span class="line" id="L1809"></span>
<span class="line" id="L1810">        ConnectionResetByPeer,</span>
<span class="line" id="L1811"></span>
<span class="line" id="L1812">        NetworkSubsystemFailed,</span>
<span class="line" id="L1813"></span>
<span class="line" id="L1814">        OperationNotSupported,</span>
<span class="line" id="L1815">    } || os.UnexpectedError;</span>
<span class="line" id="L1816"></span>
<span class="line" id="L1817">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> Connection = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L1818">        stream: Stream,</span>
<span class="line" id="L1819">        address: Address,</span>
<span class="line" id="L1820">    };</span>
<span class="line" id="L1821"></span>
<span class="line" id="L1822">    <span class="tok-comment">/// If this function succeeds, the returned `Connection` is a caller-managed resource.</span></span>
<span class="line" id="L1823">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">accept</span>(self: *StreamServer) AcceptError!Connection {</span>
<span class="line" id="L1824">        <span class="tok-kw">var</span> accepted_addr: Address = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L1825">        <span class="tok-kw">var</span> adr_len: os.socklen_t = <span class="tok-builtin">@sizeOf</span>(Address);</span>
<span class="line" id="L1826">        <span class="tok-kw">const</span> accept_result = blk: {</span>
<span class="line" id="L1827">            <span class="tok-kw">if</span> (std.io.is_async) {</span>
<span class="line" id="L1828">                <span class="tok-kw">const</span> loop = std.event.Loop.instance <span class="tok-kw">orelse</span> <span class="tok-kw">return</span> <span class="tok-kw">error</span>.UnexpectedError;</span>
<span class="line" id="L1829">                <span class="tok-kw">break</span> :blk loop.accept(self.sockfd.?, &amp;accepted_addr.any, &amp;adr_len, os.SOCK.CLOEXEC);</span>
<span class="line" id="L1830">            } <span class="tok-kw">else</span> {</span>
<span class="line" id="L1831">                <span class="tok-kw">break</span> :blk os.accept(self.sockfd.?, &amp;accepted_addr.any, &amp;adr_len, os.SOCK.CLOEXEC);</span>
<span class="line" id="L1832">            }</span>
<span class="line" id="L1833">        };</span>
<span class="line" id="L1834"></span>
<span class="line" id="L1835">        <span class="tok-kw">if</span> (accept_result) |fd| {</span>
<span class="line" id="L1836">            <span class="tok-kw">return</span> Connection{</span>
<span class="line" id="L1837">                .stream = Stream{ .handle = fd },</span>
<span class="line" id="L1838">                .address = accepted_addr,</span>
<span class="line" id="L1839">            };</span>
<span class="line" id="L1840">        } <span class="tok-kw">else</span> |err| <span class="tok-kw">switch</span> (err) {</span>
<span class="line" id="L1841">            <span class="tok-kw">error</span>.WouldBlock =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L1842">            <span class="tok-kw">else</span> =&gt; |e| <span class="tok-kw">return</span> e,</span>
<span class="line" id="L1843">        }</span>
<span class="line" id="L1844">    }</span>
<span class="line" id="L1845">};</span>
<span class="line" id="L1846"></span>
<span class="line" id="L1847"><span class="tok-kw">test</span> {</span>
<span class="line" id="L1848">    _ = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;net/test.zig&quot;</span>);</span>
<span class="line" id="L1849">}</span>
<span class="line" id="L1850"></span>
</code></pre></body>
</html>