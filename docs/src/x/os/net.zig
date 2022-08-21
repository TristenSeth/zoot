<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">    <title>x/os/net.zig - source view</title>
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
<span class="line" id="L4"><span class="tok-kw">const</span> os = std.os;</span>
<span class="line" id="L5"><span class="tok-kw">const</span> fmt = std.fmt;</span>
<span class="line" id="L6"><span class="tok-kw">const</span> mem = std.mem;</span>
<span class="line" id="L7"><span class="tok-kw">const</span> math = std.math;</span>
<span class="line" id="L8"><span class="tok-kw">const</span> testing = std.testing;</span>
<span class="line" id="L9"><span class="tok-kw">const</span> native_os = builtin.os;</span>
<span class="line" id="L10"><span class="tok-kw">const</span> have_ifnamesize = <span class="tok-builtin">@hasDecl</span>(os.system, <span class="tok-str">&quot;IFNAMESIZE&quot;</span>);</span>
<span class="line" id="L11"></span>
<span class="line" id="L12"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> ResolveScopeIdError = <span class="tok-kw">error</span>{</span>
<span class="line" id="L13">    NameTooLong,</span>
<span class="line" id="L14">    PermissionDenied,</span>
<span class="line" id="L15">    AddressFamilyNotSupported,</span>
<span class="line" id="L16">    ProtocolFamilyNotAvailable,</span>
<span class="line" id="L17">    ProcessFdQuotaExceeded,</span>
<span class="line" id="L18">    SystemFdQuotaExceeded,</span>
<span class="line" id="L19">    SystemResources,</span>
<span class="line" id="L20">    ProtocolNotSupported,</span>
<span class="line" id="L21">    SocketTypeNotSupported,</span>
<span class="line" id="L22">    InterfaceNotFound,</span>
<span class="line" id="L23">    FileSystem,</span>
<span class="line" id="L24">    Unexpected,</span>
<span class="line" id="L25">};</span>
<span class="line" id="L26"></span>
<span class="line" id="L27"><span class="tok-comment">/// Resolves a network interface name into a scope/zone ID. It returns</span></span>
<span class="line" id="L28"><span class="tok-comment">/// an error if either resolution fails, or if the interface name is</span></span>
<span class="line" id="L29"><span class="tok-comment">/// too long.</span></span>
<span class="line" id="L30"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">resolveScopeId</span>(name: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) ResolveScopeIdError!<span class="tok-type">u32</span> {</span>
<span class="line" id="L31">    <span class="tok-kw">if</span> (have_ifnamesize) {</span>
<span class="line" id="L32">        <span class="tok-kw">if</span> (name.len &gt;= os.IFNAMESIZE) <span class="tok-kw">return</span> <span class="tok-kw">error</span>.NameTooLong;</span>
<span class="line" id="L33"></span>
<span class="line" id="L34">        <span class="tok-kw">if</span> (native_os.tag == .windows <span class="tok-kw">or</span> <span class="tok-kw">comptime</span> native_os.tag.isDarwin()) {</span>
<span class="line" id="L35">            <span class="tok-kw">var</span> interface_name: [os.IFNAMESIZE:<span class="tok-number">0</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L36">            mem.copy(<span class="tok-type">u8</span>, &amp;interface_name, name);</span>
<span class="line" id="L37">            interface_name[name.len] = <span class="tok-number">0</span>;</span>
<span class="line" id="L38"></span>
<span class="line" id="L39">            <span class="tok-kw">const</span> rc = blk: {</span>
<span class="line" id="L40">                <span class="tok-kw">if</span> (native_os.tag == .windows) {</span>
<span class="line" id="L41">                    <span class="tok-kw">break</span> :blk os.windows.ws2_32.if_nametoindex(<span class="tok-builtin">@ptrCast</span>([*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span>, &amp;interface_name));</span>
<span class="line" id="L42">                } <span class="tok-kw">else</span> {</span>
<span class="line" id="L43">                    <span class="tok-kw">const</span> index = os.system.if_nametoindex(<span class="tok-builtin">@ptrCast</span>([*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span>, &amp;interface_name));</span>
<span class="line" id="L44">                    <span class="tok-kw">break</span> :blk <span class="tok-builtin">@bitCast</span>(<span class="tok-type">u32</span>, index);</span>
<span class="line" id="L45">                }</span>
<span class="line" id="L46">            };</span>
<span class="line" id="L47">            <span class="tok-kw">if</span> (rc == <span class="tok-number">0</span>) {</span>
<span class="line" id="L48">                <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InterfaceNotFound;</span>
<span class="line" id="L49">            }</span>
<span class="line" id="L50">            <span class="tok-kw">return</span> rc;</span>
<span class="line" id="L51">        }</span>
<span class="line" id="L52"></span>
<span class="line" id="L53">        <span class="tok-kw">if</span> (native_os.tag == .linux) {</span>
<span class="line" id="L54">            <span class="tok-kw">const</span> fd = <span class="tok-kw">try</span> os.socket(os.AF.INET, os.SOCK.DGRAM, <span class="tok-number">0</span>);</span>
<span class="line" id="L55">            <span class="tok-kw">defer</span> os.closeSocket(fd);</span>
<span class="line" id="L56"></span>
<span class="line" id="L57">            <span class="tok-kw">var</span> f: os.ifreq = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L58">            mem.copy(<span class="tok-type">u8</span>, &amp;f.ifrn.name, name);</span>
<span class="line" id="L59">            f.ifrn.name[name.len] = <span class="tok-number">0</span>;</span>
<span class="line" id="L60"></span>
<span class="line" id="L61">            <span class="tok-kw">try</span> os.ioctl_SIOCGIFINDEX(fd, &amp;f);</span>
<span class="line" id="L62"></span>
<span class="line" id="L63">            <span class="tok-kw">return</span> <span class="tok-builtin">@bitCast</span>(<span class="tok-type">u32</span>, f.ifru.ivalue);</span>
<span class="line" id="L64">        }</span>
<span class="line" id="L65">    }</span>
<span class="line" id="L66"></span>
<span class="line" id="L67">    <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InterfaceNotFound;</span>
<span class="line" id="L68">}</span>
<span class="line" id="L69"></span>
<span class="line" id="L70"><span class="tok-comment">/// An IPv4 address comprised of 4 bytes.</span></span>
<span class="line" id="L71"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IPv4 = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L72">    <span class="tok-comment">/// A IPv4 host-port pair.</span></span>
<span class="line" id="L73">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> Address = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L74">        host: IPv4,</span>
<span class="line" id="L75">        port: <span class="tok-type">u16</span>,</span>
<span class="line" id="L76">    };</span>
<span class="line" id="L77"></span>
<span class="line" id="L78">    <span class="tok-comment">/// Octets of a IPv4 address designating the local host.</span></span>
<span class="line" id="L79">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> localhost_octets = [_]<span class="tok-type">u8</span>{ <span class="tok-number">127</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">1</span> };</span>
<span class="line" id="L80"></span>
<span class="line" id="L81">    <span class="tok-comment">/// The IPv4 address of the local host.</span></span>
<span class="line" id="L82">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> localhost: IPv4 = .{ .octets = localhost_octets };</span>
<span class="line" id="L83"></span>
<span class="line" id="L84">    <span class="tok-comment">/// Octets of an unspecified IPv4 address.</span></span>
<span class="line" id="L85">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> unspecified_octets = [_]<span class="tok-type">u8</span>{<span class="tok-number">0</span>} ** <span class="tok-number">4</span>;</span>
<span class="line" id="L86"></span>
<span class="line" id="L87">    <span class="tok-comment">/// An unspecified IPv4 address.</span></span>
<span class="line" id="L88">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> unspecified: IPv4 = .{ .octets = unspecified_octets };</span>
<span class="line" id="L89"></span>
<span class="line" id="L90">    <span class="tok-comment">/// Octets of a broadcast IPv4 address.</span></span>
<span class="line" id="L91">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> broadcast_octets = [_]<span class="tok-type">u8</span>{<span class="tok-number">255</span>} ** <span class="tok-number">4</span>;</span>
<span class="line" id="L92"></span>
<span class="line" id="L93">    <span class="tok-comment">/// An IPv4 broadcast address.</span></span>
<span class="line" id="L94">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> broadcast: IPv4 = .{ .octets = broadcast_octets };</span>
<span class="line" id="L95"></span>
<span class="line" id="L96">    <span class="tok-comment">/// The prefix octet pattern of a link-local IPv4 address.</span></span>
<span class="line" id="L97">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> link_local_prefix = [_]<span class="tok-type">u8</span>{ <span class="tok-number">169</span>, <span class="tok-number">254</span> };</span>
<span class="line" id="L98"></span>
<span class="line" id="L99">    <span class="tok-comment">/// The prefix octet patterns of IPv4 addresses intended for</span></span>
<span class="line" id="L100">    <span class="tok-comment">/// documentation.</span></span>
<span class="line" id="L101">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> documentation_prefixes = [_][]<span class="tok-kw">const</span> <span class="tok-type">u8</span>{</span>
<span class="line" id="L102">        &amp;[_]<span class="tok-type">u8</span>{ <span class="tok-number">192</span>, <span class="tok-number">0</span>, <span class="tok-number">2</span> },</span>
<span class="line" id="L103">        &amp;[_]<span class="tok-type">u8</span>{ <span class="tok-number">198</span>, <span class="tok-number">51</span>, <span class="tok-number">100</span> },</span>
<span class="line" id="L104">        &amp;[_]<span class="tok-type">u8</span>{ <span class="tok-number">203</span>, <span class="tok-number">0</span>, <span class="tok-number">113</span> },</span>
<span class="line" id="L105">    };</span>
<span class="line" id="L106"></span>
<span class="line" id="L107">    octets: [<span class="tok-number">4</span>]<span class="tok-type">u8</span>,</span>
<span class="line" id="L108"></span>
<span class="line" id="L109">    <span class="tok-comment">/// Returns whether or not the two addresses are equal to, less than, or</span></span>
<span class="line" id="L110">    <span class="tok-comment">/// greater than each other.</span></span>
<span class="line" id="L111">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">cmp</span>(self: IPv4, other: IPv4) math.Order {</span>
<span class="line" id="L112">        <span class="tok-kw">return</span> mem.order(<span class="tok-type">u8</span>, &amp;self.octets, &amp;other.octets);</span>
<span class="line" id="L113">    }</span>
<span class="line" id="L114"></span>
<span class="line" id="L115">    <span class="tok-comment">/// Returns true if both addresses are semantically equivalent.</span></span>
<span class="line" id="L116">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">eql</span>(self: IPv4, other: IPv4) <span class="tok-type">bool</span> {</span>
<span class="line" id="L117">        <span class="tok-kw">return</span> mem.eql(<span class="tok-type">u8</span>, &amp;self.octets, &amp;other.octets);</span>
<span class="line" id="L118">    }</span>
<span class="line" id="L119"></span>
<span class="line" id="L120">    <span class="tok-comment">/// Returns true if the address is a loopback address.</span></span>
<span class="line" id="L121">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">isLoopback</span>(self: IPv4) <span class="tok-type">bool</span> {</span>
<span class="line" id="L122">        <span class="tok-kw">return</span> self.octets[<span class="tok-number">0</span>] == <span class="tok-number">127</span>;</span>
<span class="line" id="L123">    }</span>
<span class="line" id="L124"></span>
<span class="line" id="L125">    <span class="tok-comment">/// Returns true if the address is an unspecified IPv4 address.</span></span>
<span class="line" id="L126">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">isUnspecified</span>(self: IPv4) <span class="tok-type">bool</span> {</span>
<span class="line" id="L127">        <span class="tok-kw">return</span> mem.eql(<span class="tok-type">u8</span>, &amp;self.octets, &amp;unspecified_octets);</span>
<span class="line" id="L128">    }</span>
<span class="line" id="L129"></span>
<span class="line" id="L130">    <span class="tok-comment">/// Returns true if the address is a private IPv4 address.</span></span>
<span class="line" id="L131">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">isPrivate</span>(self: IPv4) <span class="tok-type">bool</span> {</span>
<span class="line" id="L132">        <span class="tok-kw">return</span> self.octets[<span class="tok-number">0</span>] == <span class="tok-number">10</span> <span class="tok-kw">or</span></span>
<span class="line" id="L133">            (self.octets[<span class="tok-number">0</span>] == <span class="tok-number">172</span> <span class="tok-kw">and</span> self.octets[<span class="tok-number">1</span>] &gt;= <span class="tok-number">16</span> <span class="tok-kw">and</span> self.octets[<span class="tok-number">1</span>] &lt;= <span class="tok-number">31</span>) <span class="tok-kw">or</span></span>
<span class="line" id="L134">            (self.octets[<span class="tok-number">0</span>] == <span class="tok-number">192</span> <span class="tok-kw">and</span> self.octets[<span class="tok-number">1</span>] == <span class="tok-number">168</span>);</span>
<span class="line" id="L135">    }</span>
<span class="line" id="L136"></span>
<span class="line" id="L137">    <span class="tok-comment">/// Returns true if the address is a link-local IPv4 address.</span></span>
<span class="line" id="L138">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">isLinkLocal</span>(self: IPv4) <span class="tok-type">bool</span> {</span>
<span class="line" id="L139">        <span class="tok-kw">return</span> mem.startsWith(<span class="tok-type">u8</span>, &amp;self.octets, &amp;link_local_prefix);</span>
<span class="line" id="L140">    }</span>
<span class="line" id="L141"></span>
<span class="line" id="L142">    <span class="tok-comment">/// Returns true if the address is a multicast IPv4 address.</span></span>
<span class="line" id="L143">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">isMulticast</span>(self: IPv4) <span class="tok-type">bool</span> {</span>
<span class="line" id="L144">        <span class="tok-kw">return</span> self.octets[<span class="tok-number">0</span>] &gt;= <span class="tok-number">224</span> <span class="tok-kw">and</span> self.octets[<span class="tok-number">0</span>] &lt;= <span class="tok-number">239</span>;</span>
<span class="line" id="L145">    }</span>
<span class="line" id="L146"></span>
<span class="line" id="L147">    <span class="tok-comment">/// Returns true if the address is a IPv4 broadcast address.</span></span>
<span class="line" id="L148">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">isBroadcast</span>(self: IPv4) <span class="tok-type">bool</span> {</span>
<span class="line" id="L149">        <span class="tok-kw">return</span> mem.eql(<span class="tok-type">u8</span>, &amp;self.octets, &amp;broadcast_octets);</span>
<span class="line" id="L150">    }</span>
<span class="line" id="L151"></span>
<span class="line" id="L152">    <span class="tok-comment">/// Returns true if the address is in a range designated for documentation. Refer</span></span>
<span class="line" id="L153">    <span class="tok-comment">/// to IETF RFC 5737 for more details.</span></span>
<span class="line" id="L154">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">isDocumentation</span>(self: IPv4) <span class="tok-type">bool</span> {</span>
<span class="line" id="L155">        <span class="tok-kw">inline</span> <span class="tok-kw">for</span> (documentation_prefixes) |prefix| {</span>
<span class="line" id="L156">            <span class="tok-kw">if</span> (mem.startsWith(<span class="tok-type">u8</span>, &amp;self.octets, prefix)) {</span>
<span class="line" id="L157">                <span class="tok-kw">return</span> <span class="tok-null">true</span>;</span>
<span class="line" id="L158">            }</span>
<span class="line" id="L159">        }</span>
<span class="line" id="L160">        <span class="tok-kw">return</span> <span class="tok-null">false</span>;</span>
<span class="line" id="L161">    }</span>
<span class="line" id="L162"></span>
<span class="line" id="L163">    <span class="tok-comment">/// Implements the `std.fmt.format` API.</span></span>
<span class="line" id="L164">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">format</span>(</span>
<span class="line" id="L165">        self: IPv4,</span>
<span class="line" id="L166">        <span class="tok-kw">comptime</span> layout: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L167">        opts: fmt.FormatOptions,</span>
<span class="line" id="L168">        writer: <span class="tok-kw">anytype</span>,</span>
<span class="line" id="L169">    ) !<span class="tok-type">void</span> {</span>
<span class="line" id="L170">        _ = opts;</span>
<span class="line" id="L171">        <span class="tok-kw">if</span> (<span class="tok-kw">comptime</span> layout.len != <span class="tok-number">0</span> <span class="tok-kw">and</span> layout[<span class="tok-number">0</span>] != <span class="tok-str">'s'</span>) {</span>
<span class="line" id="L172">            <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;Unsupported format specifier for IPv4 type '&quot;</span> ++ layout ++ <span class="tok-str">&quot;'.&quot;</span>);</span>
<span class="line" id="L173">        }</span>
<span class="line" id="L174"></span>
<span class="line" id="L175">        <span class="tok-kw">try</span> fmt.format(writer, <span class="tok-str">&quot;{}.{}.{}.{}&quot;</span>, .{</span>
<span class="line" id="L176">            self.octets[<span class="tok-number">0</span>],</span>
<span class="line" id="L177">            self.octets[<span class="tok-number">1</span>],</span>
<span class="line" id="L178">            self.octets[<span class="tok-number">2</span>],</span>
<span class="line" id="L179">            self.octets[<span class="tok-number">3</span>],</span>
<span class="line" id="L180">        });</span>
<span class="line" id="L181">    }</span>
<span class="line" id="L182"></span>
<span class="line" id="L183">    <span class="tok-comment">/// Set of possible errors that may encountered when parsing an IPv4</span></span>
<span class="line" id="L184">    <span class="tok-comment">/// address.</span></span>
<span class="line" id="L185">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> ParseError = <span class="tok-kw">error</span>{</span>
<span class="line" id="L186">        UnexpectedEndOfOctet,</span>
<span class="line" id="L187">        TooManyOctets,</span>
<span class="line" id="L188">        OctetOverflow,</span>
<span class="line" id="L189">        UnexpectedToken,</span>
<span class="line" id="L190">        IncompleteAddress,</span>
<span class="line" id="L191">    };</span>
<span class="line" id="L192"></span>
<span class="line" id="L193">    <span class="tok-comment">/// Parses an arbitrary IPv4 address.</span></span>
<span class="line" id="L194">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">parse</span>(buf: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) ParseError!IPv4 {</span>
<span class="line" id="L195">        <span class="tok-kw">var</span> octets: [<span class="tok-number">4</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L196">        <span class="tok-kw">var</span> octet: <span class="tok-type">u8</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L197"></span>
<span class="line" id="L198">        <span class="tok-kw">var</span> index: <span class="tok-type">u8</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L199">        <span class="tok-kw">var</span> saw_any_digits: <span class="tok-type">bool</span> = <span class="tok-null">false</span>;</span>
<span class="line" id="L200"></span>
<span class="line" id="L201">        <span class="tok-kw">for</span> (buf) |c| {</span>
<span class="line" id="L202">            <span class="tok-kw">switch</span> (c) {</span>
<span class="line" id="L203">                <span class="tok-str">'.'</span> =&gt; {</span>
<span class="line" id="L204">                    <span class="tok-kw">if</span> (!saw_any_digits) <span class="tok-kw">return</span> <span class="tok-kw">error</span>.UnexpectedEndOfOctet;</span>
<span class="line" id="L205">                    <span class="tok-kw">if</span> (index == <span class="tok-number">3</span>) <span class="tok-kw">return</span> <span class="tok-kw">error</span>.TooManyOctets;</span>
<span class="line" id="L206">                    octets[index] = octet;</span>
<span class="line" id="L207">                    index += <span class="tok-number">1</span>;</span>
<span class="line" id="L208">                    octet = <span class="tok-number">0</span>;</span>
<span class="line" id="L209">                    saw_any_digits = <span class="tok-null">false</span>;</span>
<span class="line" id="L210">                },</span>
<span class="line" id="L211">                <span class="tok-str">'0'</span>...<span class="tok-str">'9'</span> =&gt; {</span>
<span class="line" id="L212">                    saw_any_digits = <span class="tok-null">true</span>;</span>
<span class="line" id="L213">                    octet = math.mul(<span class="tok-type">u8</span>, octet, <span class="tok-number">10</span>) <span class="tok-kw">catch</span> <span class="tok-kw">return</span> <span class="tok-kw">error</span>.OctetOverflow;</span>
<span class="line" id="L214">                    octet = math.add(<span class="tok-type">u8</span>, octet, c - <span class="tok-str">'0'</span>) <span class="tok-kw">catch</span> <span class="tok-kw">return</span> <span class="tok-kw">error</span>.OctetOverflow;</span>
<span class="line" id="L215">                },</span>
<span class="line" id="L216">                <span class="tok-kw">else</span> =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.UnexpectedToken,</span>
<span class="line" id="L217">            }</span>
<span class="line" id="L218">        }</span>
<span class="line" id="L219"></span>
<span class="line" id="L220">        <span class="tok-kw">if</span> (index == <span class="tok-number">3</span> <span class="tok-kw">and</span> saw_any_digits) {</span>
<span class="line" id="L221">            octets[index] = octet;</span>
<span class="line" id="L222">            <span class="tok-kw">return</span> IPv4{ .octets = octets };</span>
<span class="line" id="L223">        }</span>
<span class="line" id="L224"></span>
<span class="line" id="L225">        <span class="tok-kw">return</span> <span class="tok-kw">error</span>.IncompleteAddress;</span>
<span class="line" id="L226">    }</span>
<span class="line" id="L227"></span>
<span class="line" id="L228">    <span class="tok-comment">/// Maps the address to its IPv6 equivalent. In most cases, you would</span></span>
<span class="line" id="L229">    <span class="tok-comment">/// want to map the address to its IPv6 equivalent rather than directly</span></span>
<span class="line" id="L230">    <span class="tok-comment">/// re-interpreting the address.</span></span>
<span class="line" id="L231">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">mapToIPv6</span>(self: IPv4) IPv6 {</span>
<span class="line" id="L232">        <span class="tok-kw">var</span> octets: [<span class="tok-number">16</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L233">        mem.copy(<span class="tok-type">u8</span>, octets[<span class="tok-number">0</span>..<span class="tok-number">12</span>], &amp;IPv6.v4_mapped_prefix);</span>
<span class="line" id="L234">        mem.copy(<span class="tok-type">u8</span>, octets[<span class="tok-number">12</span>..], &amp;self.octets);</span>
<span class="line" id="L235">        <span class="tok-kw">return</span> IPv6{ .octets = octets, .scope_id = IPv6.no_scope_id };</span>
<span class="line" id="L236">    }</span>
<span class="line" id="L237"></span>
<span class="line" id="L238">    <span class="tok-comment">/// Directly re-interprets the address to its IPv6 equivalent. In most</span></span>
<span class="line" id="L239">    <span class="tok-comment">/// cases, you would want to map the address to its IPv6 equivalent rather</span></span>
<span class="line" id="L240">    <span class="tok-comment">/// than directly re-interpreting the address.</span></span>
<span class="line" id="L241">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">toIPv6</span>(self: IPv4) IPv6 {</span>
<span class="line" id="L242">        <span class="tok-kw">var</span> octets: [<span class="tok-number">16</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L243">        mem.set(<span class="tok-type">u8</span>, octets[<span class="tok-number">0</span>..<span class="tok-number">12</span>], <span class="tok-number">0</span>);</span>
<span class="line" id="L244">        mem.copy(<span class="tok-type">u8</span>, octets[<span class="tok-number">12</span>..], &amp;self.octets);</span>
<span class="line" id="L245">        <span class="tok-kw">return</span> IPv6{ .octets = octets, .scope_id = IPv6.no_scope_id };</span>
<span class="line" id="L246">    }</span>
<span class="line" id="L247">};</span>
<span class="line" id="L248"></span>
<span class="line" id="L249"><span class="tok-comment">/// An IPv6 address comprised of 16 bytes for an address, and 4 bytes</span></span>
<span class="line" id="L250"><span class="tok-comment">/// for a scope ID; cumulatively summing to 20 bytes in total.</span></span>
<span class="line" id="L251"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IPv6 = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L252">    <span class="tok-comment">/// A IPv6 host-port pair.</span></span>
<span class="line" id="L253">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> Address = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L254">        host: IPv6,</span>
<span class="line" id="L255">        port: <span class="tok-type">u16</span>,</span>
<span class="line" id="L256">    };</span>
<span class="line" id="L257"></span>
<span class="line" id="L258">    <span class="tok-comment">/// Octets of a IPv6 address designating the local host.</span></span>
<span class="line" id="L259">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> localhost_octets = [_]<span class="tok-type">u8</span>{<span class="tok-number">0</span>} ** <span class="tok-number">15</span> ++ [_]<span class="tok-type">u8</span>{<span class="tok-number">0x01</span>};</span>
<span class="line" id="L260"></span>
<span class="line" id="L261">    <span class="tok-comment">/// The IPv6 address of the local host.</span></span>
<span class="line" id="L262">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> localhost: IPv6 = .{</span>
<span class="line" id="L263">        .octets = localhost_octets,</span>
<span class="line" id="L264">        .scope_id = no_scope_id,</span>
<span class="line" id="L265">    };</span>
<span class="line" id="L266"></span>
<span class="line" id="L267">    <span class="tok-comment">/// Octets of an unspecified IPv6 address.</span></span>
<span class="line" id="L268">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> unspecified_octets = [_]<span class="tok-type">u8</span>{<span class="tok-number">0</span>} ** <span class="tok-number">16</span>;</span>
<span class="line" id="L269"></span>
<span class="line" id="L270">    <span class="tok-comment">/// An unspecified IPv6 address.</span></span>
<span class="line" id="L271">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> unspecified: IPv6 = .{</span>
<span class="line" id="L272">        .octets = unspecified_octets,</span>
<span class="line" id="L273">        .scope_id = no_scope_id,</span>
<span class="line" id="L274">    };</span>
<span class="line" id="L275"></span>
<span class="line" id="L276">    <span class="tok-comment">/// The prefix of a IPv6 address that is mapped to a IPv4 address.</span></span>
<span class="line" id="L277">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> v4_mapped_prefix = [_]<span class="tok-type">u8</span>{<span class="tok-number">0</span>} ** <span class="tok-number">10</span> ++ [_]<span class="tok-type">u8</span>{<span class="tok-number">0xFF</span>} ** <span class="tok-number">2</span>;</span>
<span class="line" id="L278"></span>
<span class="line" id="L279">    <span class="tok-comment">/// A marker value used to designate an IPv6 address with no</span></span>
<span class="line" id="L280">    <span class="tok-comment">/// associated scope ID.</span></span>
<span class="line" id="L281">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> no_scope_id = math.maxInt(<span class="tok-type">u32</span>);</span>
<span class="line" id="L282"></span>
<span class="line" id="L283">    octets: [<span class="tok-number">16</span>]<span class="tok-type">u8</span>,</span>
<span class="line" id="L284">    scope_id: <span class="tok-type">u32</span>,</span>
<span class="line" id="L285"></span>
<span class="line" id="L286">    <span class="tok-comment">/// Returns whether or not the two addresses are equal to, less than, or</span></span>
<span class="line" id="L287">    <span class="tok-comment">/// greater than each other.</span></span>
<span class="line" id="L288">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">cmp</span>(self: IPv6, other: IPv6) math.Order {</span>
<span class="line" id="L289">        <span class="tok-kw">return</span> <span class="tok-kw">switch</span> (mem.order(<span class="tok-type">u8</span>, self.octets, other.octets)) {</span>
<span class="line" id="L290">            .eq =&gt; math.order(self.scope_id, other.scope_id),</span>
<span class="line" id="L291">            <span class="tok-kw">else</span> =&gt; |order| order,</span>
<span class="line" id="L292">        };</span>
<span class="line" id="L293">    }</span>
<span class="line" id="L294"></span>
<span class="line" id="L295">    <span class="tok-comment">/// Returns true if both addresses are semantically equivalent.</span></span>
<span class="line" id="L296">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">eql</span>(self: IPv6, other: IPv6) <span class="tok-type">bool</span> {</span>
<span class="line" id="L297">        <span class="tok-kw">return</span> self.scope_id == other.scope_id <span class="tok-kw">and</span> mem.eql(<span class="tok-type">u8</span>, &amp;self.octets, &amp;other.octets);</span>
<span class="line" id="L298">    }</span>
<span class="line" id="L299"></span>
<span class="line" id="L300">    <span class="tok-comment">/// Returns true if the address is an unspecified IPv6 address.</span></span>
<span class="line" id="L301">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">isUnspecified</span>(self: IPv6) <span class="tok-type">bool</span> {</span>
<span class="line" id="L302">        <span class="tok-kw">return</span> mem.eql(<span class="tok-type">u8</span>, &amp;self.octets, &amp;unspecified_octets);</span>
<span class="line" id="L303">    }</span>
<span class="line" id="L304"></span>
<span class="line" id="L305">    <span class="tok-comment">/// Returns true if the address is a loopback address.</span></span>
<span class="line" id="L306">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">isLoopback</span>(self: IPv6) <span class="tok-type">bool</span> {</span>
<span class="line" id="L307">        <span class="tok-kw">return</span> mem.eql(<span class="tok-type">u8</span>, self.octets[<span class="tok-number">0</span>..<span class="tok-number">3</span>], &amp;[_]<span class="tok-type">u8</span>{ <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span> }) <span class="tok-kw">and</span></span>
<span class="line" id="L308">            mem.eql(<span class="tok-type">u8</span>, self.octets[<span class="tok-number">12</span>..], &amp;[_]<span class="tok-type">u8</span>{ <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">1</span> });</span>
<span class="line" id="L309">    }</span>
<span class="line" id="L310"></span>
<span class="line" id="L311">    <span class="tok-comment">/// Returns true if the address maps to an IPv4 address.</span></span>
<span class="line" id="L312">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">mapsToIPv4</span>(self: IPv6) <span class="tok-type">bool</span> {</span>
<span class="line" id="L313">        <span class="tok-kw">return</span> mem.startsWith(<span class="tok-type">u8</span>, &amp;self.octets, &amp;v4_mapped_prefix);</span>
<span class="line" id="L314">    }</span>
<span class="line" id="L315"></span>
<span class="line" id="L316">    <span class="tok-comment">/// Returns an IPv4 address representative of the address should</span></span>
<span class="line" id="L317">    <span class="tok-comment">/// it the address be mapped to an IPv4 address. It returns null</span></span>
<span class="line" id="L318">    <span class="tok-comment">/// otherwise.</span></span>
<span class="line" id="L319">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">toIPv4</span>(self: IPv6) ?IPv4 {</span>
<span class="line" id="L320">        <span class="tok-kw">if</span> (!self.mapsToIPv4()) <span class="tok-kw">return</span> <span class="tok-null">null</span>;</span>
<span class="line" id="L321">        <span class="tok-kw">return</span> IPv4{ .octets = self.octets[<span class="tok-number">12</span>..][<span class="tok-number">0</span>..<span class="tok-number">4</span>].* };</span>
<span class="line" id="L322">    }</span>
<span class="line" id="L323"></span>
<span class="line" id="L324">    <span class="tok-comment">/// Returns true if the address is a multicast IPv6 address.</span></span>
<span class="line" id="L325">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">isMulticast</span>(self: IPv6) <span class="tok-type">bool</span> {</span>
<span class="line" id="L326">        <span class="tok-kw">return</span> self.octets[<span class="tok-number">0</span>] == <span class="tok-number">0xFF</span>;</span>
<span class="line" id="L327">    }</span>
<span class="line" id="L328"></span>
<span class="line" id="L329">    <span class="tok-comment">/// Returns true if the address is a unicast link local IPv6 address.</span></span>
<span class="line" id="L330">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">isLinkLocal</span>(self: IPv6) <span class="tok-type">bool</span> {</span>
<span class="line" id="L331">        <span class="tok-kw">return</span> self.octets[<span class="tok-number">0</span>] == <span class="tok-number">0xFE</span> <span class="tok-kw">and</span> self.octets[<span class="tok-number">1</span>] &amp; <span class="tok-number">0xC0</span> == <span class="tok-number">0x80</span>;</span>
<span class="line" id="L332">    }</span>
<span class="line" id="L333"></span>
<span class="line" id="L334">    <span class="tok-comment">/// Returns true if the address is a deprecated unicast site local</span></span>
<span class="line" id="L335">    <span class="tok-comment">/// IPv6 address. Refer to IETF RFC 3879 for more details as to</span></span>
<span class="line" id="L336">    <span class="tok-comment">/// why they are deprecated.</span></span>
<span class="line" id="L337">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">isSiteLocal</span>(self: IPv6) <span class="tok-type">bool</span> {</span>
<span class="line" id="L338">        <span class="tok-kw">return</span> self.octets[<span class="tok-number">0</span>] == <span class="tok-number">0xFE</span> <span class="tok-kw">and</span> self.octets[<span class="tok-number">1</span>] &amp; <span class="tok-number">0xC0</span> == <span class="tok-number">0xC0</span>;</span>
<span class="line" id="L339">    }</span>
<span class="line" id="L340"></span>
<span class="line" id="L341">    <span class="tok-comment">/// IPv6 multicast address scopes.</span></span>
<span class="line" id="L342">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> Scope = <span class="tok-kw">enum</span>(<span class="tok-type">u8</span>) {</span>
<span class="line" id="L343">        interface = <span class="tok-number">1</span>,</span>
<span class="line" id="L344">        link = <span class="tok-number">2</span>,</span>
<span class="line" id="L345">        realm = <span class="tok-number">3</span>,</span>
<span class="line" id="L346">        admin = <span class="tok-number">4</span>,</span>
<span class="line" id="L347">        site = <span class="tok-number">5</span>,</span>
<span class="line" id="L348">        organization = <span class="tok-number">8</span>,</span>
<span class="line" id="L349">        global = <span class="tok-number">14</span>,</span>
<span class="line" id="L350">        unknown = <span class="tok-number">0xFF</span>,</span>
<span class="line" id="L351">    };</span>
<span class="line" id="L352"></span>
<span class="line" id="L353">    <span class="tok-comment">/// Returns the multicast scope of the address.</span></span>
<span class="line" id="L354">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">scope</span>(self: IPv6) Scope {</span>
<span class="line" id="L355">        <span class="tok-kw">if</span> (!self.isMulticast()) <span class="tok-kw">return</span> .unknown;</span>
<span class="line" id="L356"></span>
<span class="line" id="L357">        <span class="tok-kw">return</span> <span class="tok-kw">switch</span> (self.octets[<span class="tok-number">0</span>] &amp; <span class="tok-number">0x0F</span>) {</span>
<span class="line" id="L358">            <span class="tok-number">1</span> =&gt; .interface,</span>
<span class="line" id="L359">            <span class="tok-number">2</span> =&gt; .link,</span>
<span class="line" id="L360">            <span class="tok-number">3</span> =&gt; .realm,</span>
<span class="line" id="L361">            <span class="tok-number">4</span> =&gt; .admin,</span>
<span class="line" id="L362">            <span class="tok-number">5</span> =&gt; .site,</span>
<span class="line" id="L363">            <span class="tok-number">8</span> =&gt; .organization,</span>
<span class="line" id="L364">            <span class="tok-number">14</span> =&gt; .global,</span>
<span class="line" id="L365">            <span class="tok-kw">else</span> =&gt; .unknown,</span>
<span class="line" id="L366">        };</span>
<span class="line" id="L367">    }</span>
<span class="line" id="L368"></span>
<span class="line" id="L369">    <span class="tok-comment">/// Implements the `std.fmt.format` API. Specifying 'x' or 's' formats the</span></span>
<span class="line" id="L370">    <span class="tok-comment">/// address lower-cased octets, while specifying 'X' or 'S' formats the</span></span>
<span class="line" id="L371">    <span class="tok-comment">/// address using upper-cased ASCII octets.</span></span>
<span class="line" id="L372">    <span class="tok-comment">///</span></span>
<span class="line" id="L373">    <span class="tok-comment">/// The default specifier is 'x'.</span></span>
<span class="line" id="L374">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">format</span>(</span>
<span class="line" id="L375">        self: IPv6,</span>
<span class="line" id="L376">        <span class="tok-kw">comptime</span> layout: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L377">        opts: fmt.FormatOptions,</span>
<span class="line" id="L378">        writer: <span class="tok-kw">anytype</span>,</span>
<span class="line" id="L379">    ) !<span class="tok-type">void</span> {</span>
<span class="line" id="L380">        _ = opts;</span>
<span class="line" id="L381">        <span class="tok-kw">const</span> specifier = <span class="tok-kw">comptime</span> &amp;[_]<span class="tok-type">u8</span>{<span class="tok-kw">if</span> (layout.len == <span class="tok-number">0</span>) <span class="tok-str">'x'</span> <span class="tok-kw">else</span> <span class="tok-kw">switch</span> (layout[<span class="tok-number">0</span>]) {</span>
<span class="line" id="L382">            <span class="tok-str">'x'</span>, <span class="tok-str">'X'</span> =&gt; |specifier| specifier,</span>
<span class="line" id="L383">            <span class="tok-str">'s'</span> =&gt; <span class="tok-str">'x'</span>,</span>
<span class="line" id="L384">            <span class="tok-str">'S'</span> =&gt; <span class="tok-str">'X'</span>,</span>
<span class="line" id="L385">            <span class="tok-kw">else</span> =&gt; <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;Unsupported format specifier for IPv6 type '&quot;</span> ++ layout ++ <span class="tok-str">&quot;'.&quot;</span>),</span>
<span class="line" id="L386">        }};</span>
<span class="line" id="L387"></span>
<span class="line" id="L388">        <span class="tok-kw">if</span> (mem.startsWith(<span class="tok-type">u8</span>, &amp;self.octets, &amp;v4_mapped_prefix)) {</span>
<span class="line" id="L389">            <span class="tok-kw">return</span> fmt.format(writer, <span class="tok-str">&quot;::{&quot;</span> ++ specifier ++ <span class="tok-str">&quot;}{&quot;</span> ++ specifier ++ <span class="tok-str">&quot;}:{}.{}.{}.{}&quot;</span>, .{</span>
<span class="line" id="L390">                <span class="tok-number">0xFF</span>,</span>
<span class="line" id="L391">                <span class="tok-number">0xFF</span>,</span>
<span class="line" id="L392">                self.octets[<span class="tok-number">12</span>],</span>
<span class="line" id="L393">                self.octets[<span class="tok-number">13</span>],</span>
<span class="line" id="L394">                self.octets[<span class="tok-number">14</span>],</span>
<span class="line" id="L395">                self.octets[<span class="tok-number">15</span>],</span>
<span class="line" id="L396">            });</span>
<span class="line" id="L397">        }</span>
<span class="line" id="L398"></span>
<span class="line" id="L399">        <span class="tok-kw">const</span> zero_span: <span class="tok-kw">struct</span> { from: <span class="tok-type">usize</span>, to: <span class="tok-type">usize</span> } = span: {</span>
<span class="line" id="L400">            <span class="tok-kw">var</span> i: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L401">            <span class="tok-kw">while</span> (i &lt; self.octets.len) : (i += <span class="tok-number">2</span>) {</span>
<span class="line" id="L402">                <span class="tok-kw">if</span> (self.octets[i] == <span class="tok-number">0</span> <span class="tok-kw">and</span> self.octets[i + <span class="tok-number">1</span>] == <span class="tok-number">0</span>) <span class="tok-kw">break</span>;</span>
<span class="line" id="L403">            } <span class="tok-kw">else</span> <span class="tok-kw">break</span> :span .{ .from = <span class="tok-number">0</span>, .to = <span class="tok-number">0</span> };</span>
<span class="line" id="L404"></span>
<span class="line" id="L405">            <span class="tok-kw">const</span> from = i;</span>
<span class="line" id="L406"></span>
<span class="line" id="L407">            <span class="tok-kw">while</span> (i &lt; self.octets.len) : (i += <span class="tok-number">2</span>) {</span>
<span class="line" id="L408">                <span class="tok-kw">if</span> (self.octets[i] != <span class="tok-number">0</span> <span class="tok-kw">or</span> self.octets[i + <span class="tok-number">1</span>] != <span class="tok-number">0</span>) <span class="tok-kw">break</span>;</span>
<span class="line" id="L409">            }</span>
<span class="line" id="L410"></span>
<span class="line" id="L411">            <span class="tok-kw">break</span> :span .{ .from = from, .to = i };</span>
<span class="line" id="L412">        };</span>
<span class="line" id="L413"></span>
<span class="line" id="L414">        <span class="tok-kw">var</span> i: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L415">        <span class="tok-kw">while</span> (i != <span class="tok-number">16</span>) : (i += <span class="tok-number">2</span>) {</span>
<span class="line" id="L416">            <span class="tok-kw">if</span> (zero_span.from != zero_span.to <span class="tok-kw">and</span> i == zero_span.from) {</span>
<span class="line" id="L417">                <span class="tok-kw">try</span> writer.writeAll(<span class="tok-str">&quot;::&quot;</span>);</span>
<span class="line" id="L418">            } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (i &gt;= zero_span.from <span class="tok-kw">and</span> i &lt; zero_span.to) {} <span class="tok-kw">else</span> {</span>
<span class="line" id="L419">                <span class="tok-kw">if</span> (i != <span class="tok-number">0</span> <span class="tok-kw">and</span> i != zero_span.to) <span class="tok-kw">try</span> writer.writeAll(<span class="tok-str">&quot;:&quot;</span>);</span>
<span class="line" id="L420"></span>
<span class="line" id="L421">                <span class="tok-kw">const</span> val = <span class="tok-builtin">@as</span>(<span class="tok-type">u16</span>, self.octets[i]) &lt;&lt; <span class="tok-number">8</span> | self.octets[i + <span class="tok-number">1</span>];</span>
<span class="line" id="L422">                <span class="tok-kw">try</span> fmt.formatIntValue(val, specifier, .{}, writer);</span>
<span class="line" id="L423">            }</span>
<span class="line" id="L424">        }</span>
<span class="line" id="L425"></span>
<span class="line" id="L426">        <span class="tok-kw">if</span> (self.scope_id != no_scope_id <span class="tok-kw">and</span> self.scope_id != <span class="tok-number">0</span>) {</span>
<span class="line" id="L427">            <span class="tok-kw">try</span> fmt.format(writer, <span class="tok-str">&quot;%{d}&quot;</span>, .{self.scope_id});</span>
<span class="line" id="L428">        }</span>
<span class="line" id="L429">    }</span>
<span class="line" id="L430"></span>
<span class="line" id="L431">    <span class="tok-comment">/// Set of possible errors that may encountered when parsing an IPv6</span></span>
<span class="line" id="L432">    <span class="tok-comment">/// address.</span></span>
<span class="line" id="L433">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> ParseError = <span class="tok-kw">error</span>{</span>
<span class="line" id="L434">        MalformedV4Mapping,</span>
<span class="line" id="L435">        InterfaceNotFound,</span>
<span class="line" id="L436">        UnknownScopeId,</span>
<span class="line" id="L437">    } || IPv4.ParseError;</span>
<span class="line" id="L438"></span>
<span class="line" id="L439">    <span class="tok-comment">/// Parses an arbitrary IPv6 address, including link-local addresses.</span></span>
<span class="line" id="L440">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">parse</span>(buf: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) ParseError!IPv6 {</span>
<span class="line" id="L441">        <span class="tok-kw">if</span> (mem.lastIndexOfScalar(<span class="tok-type">u8</span>, buf, <span class="tok-str">'%'</span>)) |index| {</span>
<span class="line" id="L442">            <span class="tok-kw">const</span> ip_slice = buf[<span class="tok-number">0</span>..index];</span>
<span class="line" id="L443">            <span class="tok-kw">const</span> scope_id_slice = buf[index + <span class="tok-number">1</span> ..];</span>
<span class="line" id="L444"></span>
<span class="line" id="L445">            <span class="tok-kw">if</span> (scope_id_slice.len == <span class="tok-number">0</span>) <span class="tok-kw">return</span> <span class="tok-kw">error</span>.UnknownScopeId;</span>
<span class="line" id="L446"></span>
<span class="line" id="L447">            <span class="tok-kw">const</span> scope_id: <span class="tok-type">u32</span> = <span class="tok-kw">switch</span> (scope_id_slice[<span class="tok-number">0</span>]) {</span>
<span class="line" id="L448">                <span class="tok-str">'0'</span>...<span class="tok-str">'9'</span> =&gt; fmt.parseInt(<span class="tok-type">u32</span>, scope_id_slice, <span class="tok-number">10</span>),</span>
<span class="line" id="L449">                <span class="tok-kw">else</span> =&gt; resolveScopeId(scope_id_slice) <span class="tok-kw">catch</span> |err| <span class="tok-kw">switch</span> (err) {</span>
<span class="line" id="L450">                    <span class="tok-kw">error</span>.InterfaceNotFound =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InterfaceNotFound,</span>
<span class="line" id="L451">                    <span class="tok-kw">else</span> =&gt; err,</span>
<span class="line" id="L452">                },</span>
<span class="line" id="L453">            } <span class="tok-kw">catch</span> <span class="tok-kw">return</span> <span class="tok-kw">error</span>.UnknownScopeId;</span>
<span class="line" id="L454"></span>
<span class="line" id="L455">            <span class="tok-kw">return</span> parseWithScopeID(ip_slice, scope_id);</span>
<span class="line" id="L456">        }</span>
<span class="line" id="L457"></span>
<span class="line" id="L458">        <span class="tok-kw">return</span> parseWithScopeID(buf, no_scope_id);</span>
<span class="line" id="L459">    }</span>
<span class="line" id="L460"></span>
<span class="line" id="L461">    <span class="tok-comment">/// Parses an IPv6 address with a pre-specified scope ID. Presumes</span></span>
<span class="line" id="L462">    <span class="tok-comment">/// that the address is not a link-local address.</span></span>
<span class="line" id="L463">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">parseWithScopeID</span>(buf: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, scope_id: <span class="tok-type">u32</span>) ParseError!IPv6 {</span>
<span class="line" id="L464">        <span class="tok-kw">var</span> octets: [<span class="tok-number">16</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L465">        <span class="tok-kw">var</span> octet: <span class="tok-type">u16</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L466">        <span class="tok-kw">var</span> tail: [<span class="tok-number">16</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L467"></span>
<span class="line" id="L468">        <span class="tok-kw">var</span> out: []<span class="tok-type">u8</span> = &amp;octets;</span>
<span class="line" id="L469">        <span class="tok-kw">var</span> index: <span class="tok-type">u8</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L470"></span>
<span class="line" id="L471">        <span class="tok-kw">var</span> saw_any_digits: <span class="tok-type">bool</span> = <span class="tok-null">false</span>;</span>
<span class="line" id="L472">        <span class="tok-kw">var</span> abbrv: <span class="tok-type">bool</span> = <span class="tok-null">false</span>;</span>
<span class="line" id="L473"></span>
<span class="line" id="L474">        <span class="tok-kw">for</span> (buf) |c, i| {</span>
<span class="line" id="L475">            <span class="tok-kw">switch</span> (c) {</span>
<span class="line" id="L476">                <span class="tok-str">':'</span> =&gt; {</span>
<span class="line" id="L477">                    <span class="tok-kw">if</span> (!saw_any_digits) {</span>
<span class="line" id="L478">                        <span class="tok-kw">if</span> (abbrv) <span class="tok-kw">return</span> <span class="tok-kw">error</span>.UnexpectedToken;</span>
<span class="line" id="L479">                        <span class="tok-kw">if</span> (i != <span class="tok-number">0</span>) abbrv = <span class="tok-null">true</span>;</span>
<span class="line" id="L480">                        mem.set(<span class="tok-type">u8</span>, out[index..], <span class="tok-number">0</span>);</span>
<span class="line" id="L481">                        out = &amp;tail;</span>
<span class="line" id="L482">                        index = <span class="tok-number">0</span>;</span>
<span class="line" id="L483">                        <span class="tok-kw">continue</span>;</span>
<span class="line" id="L484">                    }</span>
<span class="line" id="L485">                    <span class="tok-kw">if</span> (index == <span class="tok-number">14</span>) <span class="tok-kw">return</span> <span class="tok-kw">error</span>.TooManyOctets;</span>
<span class="line" id="L486"></span>
<span class="line" id="L487">                    out[index] = <span class="tok-builtin">@truncate</span>(<span class="tok-type">u8</span>, octet &gt;&gt; <span class="tok-number">8</span>);</span>
<span class="line" id="L488">                    index += <span class="tok-number">1</span>;</span>
<span class="line" id="L489">                    out[index] = <span class="tok-builtin">@truncate</span>(<span class="tok-type">u8</span>, octet);</span>
<span class="line" id="L490">                    index += <span class="tok-number">1</span>;</span>
<span class="line" id="L491"></span>
<span class="line" id="L492">                    octet = <span class="tok-number">0</span>;</span>
<span class="line" id="L493">                    saw_any_digits = <span class="tok-null">false</span>;</span>
<span class="line" id="L494">                },</span>
<span class="line" id="L495">                <span class="tok-str">'.'</span> =&gt; {</span>
<span class="line" id="L496">                    <span class="tok-kw">if</span> (!abbrv <span class="tok-kw">or</span> out[<span class="tok-number">0</span>] != <span class="tok-number">0xFF</span> <span class="tok-kw">and</span> out[<span class="tok-number">1</span>] != <span class="tok-number">0xFF</span>) {</span>
<span class="line" id="L497">                        <span class="tok-kw">return</span> <span class="tok-kw">error</span>.MalformedV4Mapping;</span>
<span class="line" id="L498">                    }</span>
<span class="line" id="L499">                    <span class="tok-kw">const</span> start_index = mem.lastIndexOfScalar(<span class="tok-type">u8</span>, buf[<span class="tok-number">0</span>..i], <span class="tok-str">':'</span>).? + <span class="tok-number">1</span>;</span>
<span class="line" id="L500">                    <span class="tok-kw">const</span> v4 = <span class="tok-kw">try</span> IPv4.parse(buf[start_index..]);</span>
<span class="line" id="L501">                    octets[<span class="tok-number">10</span>] = <span class="tok-number">0xFF</span>;</span>
<span class="line" id="L502">                    octets[<span class="tok-number">11</span>] = <span class="tok-number">0xFF</span>;</span>
<span class="line" id="L503">                    mem.copy(<span class="tok-type">u8</span>, octets[<span class="tok-number">12</span>..], &amp;v4.octets);</span>
<span class="line" id="L504"></span>
<span class="line" id="L505">                    <span class="tok-kw">return</span> IPv6{ .octets = octets, .scope_id = scope_id };</span>
<span class="line" id="L506">                },</span>
<span class="line" id="L507">                <span class="tok-kw">else</span> =&gt; {</span>
<span class="line" id="L508">                    saw_any_digits = <span class="tok-null">true</span>;</span>
<span class="line" id="L509">                    <span class="tok-kw">const</span> digit = fmt.charToDigit(c, <span class="tok-number">16</span>) <span class="tok-kw">catch</span> <span class="tok-kw">return</span> <span class="tok-kw">error</span>.UnexpectedToken;</span>
<span class="line" id="L510">                    octet = math.mul(<span class="tok-type">u16</span>, octet, <span class="tok-number">16</span>) <span class="tok-kw">catch</span> <span class="tok-kw">return</span> <span class="tok-kw">error</span>.OctetOverflow;</span>
<span class="line" id="L511">                    octet = math.add(<span class="tok-type">u16</span>, octet, digit) <span class="tok-kw">catch</span> <span class="tok-kw">return</span> <span class="tok-kw">error</span>.OctetOverflow;</span>
<span class="line" id="L512">                },</span>
<span class="line" id="L513">            }</span>
<span class="line" id="L514">        }</span>
<span class="line" id="L515"></span>
<span class="line" id="L516">        <span class="tok-kw">if</span> (!saw_any_digits <span class="tok-kw">and</span> !abbrv) {</span>
<span class="line" id="L517">            <span class="tok-kw">return</span> <span class="tok-kw">error</span>.IncompleteAddress;</span>
<span class="line" id="L518">        }</span>
<span class="line" id="L519"></span>
<span class="line" id="L520">        <span class="tok-kw">if</span> (index == <span class="tok-number">14</span>) {</span>
<span class="line" id="L521">            out[<span class="tok-number">14</span>] = <span class="tok-builtin">@truncate</span>(<span class="tok-type">u8</span>, octet &gt;&gt; <span class="tok-number">8</span>);</span>
<span class="line" id="L522">            out[<span class="tok-number">15</span>] = <span class="tok-builtin">@truncate</span>(<span class="tok-type">u8</span>, octet);</span>
<span class="line" id="L523">        } <span class="tok-kw">else</span> {</span>
<span class="line" id="L524">            out[index] = <span class="tok-builtin">@truncate</span>(<span class="tok-type">u8</span>, octet &gt;&gt; <span class="tok-number">8</span>);</span>
<span class="line" id="L525">            index += <span class="tok-number">1</span>;</span>
<span class="line" id="L526">            out[index] = <span class="tok-builtin">@truncate</span>(<span class="tok-type">u8</span>, octet);</span>
<span class="line" id="L527">            index += <span class="tok-number">1</span>;</span>
<span class="line" id="L528">            mem.copy(<span class="tok-type">u8</span>, octets[<span class="tok-number">16</span> - index ..], out[<span class="tok-number">0</span>..index]);</span>
<span class="line" id="L529">        }</span>
<span class="line" id="L530"></span>
<span class="line" id="L531">        <span class="tok-kw">return</span> IPv6{ .octets = octets, .scope_id = scope_id };</span>
<span class="line" id="L532">    }</span>
<span class="line" id="L533">};</span>
<span class="line" id="L534"></span>
<span class="line" id="L535"><span class="tok-kw">test</span> {</span>
<span class="line" id="L536">    testing.refAllDecls(<span class="tok-builtin">@This</span>());</span>
<span class="line" id="L537">}</span>
<span class="line" id="L538"></span>
<span class="line" id="L539"><span class="tok-kw">test</span> <span class="tok-str">&quot;ip: convert to and from ipv6&quot;</span> {</span>
<span class="line" id="L540">    <span class="tok-kw">try</span> testing.expectFmt(<span class="tok-str">&quot;::7f00:1&quot;</span>, <span class="tok-str">&quot;{}&quot;</span>, .{IPv4.localhost.toIPv6()});</span>
<span class="line" id="L541">    <span class="tok-kw">try</span> testing.expect(!IPv4.localhost.toIPv6().mapsToIPv4());</span>
<span class="line" id="L542"></span>
<span class="line" id="L543">    <span class="tok-kw">try</span> testing.expectFmt(<span class="tok-str">&quot;::ffff:127.0.0.1&quot;</span>, <span class="tok-str">&quot;{}&quot;</span>, .{IPv4.localhost.mapToIPv6()});</span>
<span class="line" id="L544">    <span class="tok-kw">try</span> testing.expect(IPv4.localhost.mapToIPv6().mapsToIPv4());</span>
<span class="line" id="L545"></span>
<span class="line" id="L546">    <span class="tok-kw">try</span> testing.expect(IPv4.localhost.toIPv6().toIPv4() == <span class="tok-null">null</span>);</span>
<span class="line" id="L547">    <span class="tok-kw">try</span> testing.expectFmt(<span class="tok-str">&quot;127.0.0.1&quot;</span>, <span class="tok-str">&quot;{?}&quot;</span>, .{IPv4.localhost.mapToIPv6().toIPv4()});</span>
<span class="line" id="L548">}</span>
<span class="line" id="L549"></span>
<span class="line" id="L550"><span class="tok-kw">test</span> <span class="tok-str">&quot;ipv4: parse &amp; format&quot;</span> {</span>
<span class="line" id="L551">    <span class="tok-kw">const</span> cases = [_][]<span class="tok-kw">const</span> <span class="tok-type">u8</span>{</span>
<span class="line" id="L552">        <span class="tok-str">&quot;0.0.0.0&quot;</span>,</span>
<span class="line" id="L553">        <span class="tok-str">&quot;255.255.255.255&quot;</span>,</span>
<span class="line" id="L554">        <span class="tok-str">&quot;1.2.3.4&quot;</span>,</span>
<span class="line" id="L555">        <span class="tok-str">&quot;123.255.0.91&quot;</span>,</span>
<span class="line" id="L556">        <span class="tok-str">&quot;127.0.0.1&quot;</span>,</span>
<span class="line" id="L557">    };</span>
<span class="line" id="L558"></span>
<span class="line" id="L559">    <span class="tok-kw">for</span> (cases) |case| {</span>
<span class="line" id="L560">        <span class="tok-kw">try</span> testing.expectFmt(case, <span class="tok-str">&quot;{}&quot;</span>, .{<span class="tok-kw">try</span> IPv4.parse(case)});</span>
<span class="line" id="L561">    }</span>
<span class="line" id="L562">}</span>
<span class="line" id="L563"></span>
<span class="line" id="L564"><span class="tok-kw">test</span> <span class="tok-str">&quot;ipv6: parse &amp; format&quot;</span> {</span>
<span class="line" id="L565">    <span class="tok-kw">const</span> inputs = [_][]<span class="tok-kw">const</span> <span class="tok-type">u8</span>{</span>
<span class="line" id="L566">        <span class="tok-str">&quot;FF01:0:0:0:0:0:0:FB&quot;</span>,</span>
<span class="line" id="L567">        <span class="tok-str">&quot;FF01::Fb&quot;</span>,</span>
<span class="line" id="L568">        <span class="tok-str">&quot;::1&quot;</span>,</span>
<span class="line" id="L569">        <span class="tok-str">&quot;::&quot;</span>,</span>
<span class="line" id="L570">        <span class="tok-str">&quot;2001:db8::&quot;</span>,</span>
<span class="line" id="L571">        <span class="tok-str">&quot;::1234:5678&quot;</span>,</span>
<span class="line" id="L572">        <span class="tok-str">&quot;2001:db8::1234:5678&quot;</span>,</span>
<span class="line" id="L573">        <span class="tok-str">&quot;::ffff:123.5.123.5&quot;</span>,</span>
<span class="line" id="L574">    };</span>
<span class="line" id="L575"></span>
<span class="line" id="L576">    <span class="tok-kw">const</span> outputs = [_][]<span class="tok-kw">const</span> <span class="tok-type">u8</span>{</span>
<span class="line" id="L577">        <span class="tok-str">&quot;ff01::fb&quot;</span>,</span>
<span class="line" id="L578">        <span class="tok-str">&quot;ff01::fb&quot;</span>,</span>
<span class="line" id="L579">        <span class="tok-str">&quot;::1&quot;</span>,</span>
<span class="line" id="L580">        <span class="tok-str">&quot;::&quot;</span>,</span>
<span class="line" id="L581">        <span class="tok-str">&quot;2001:db8::&quot;</span>,</span>
<span class="line" id="L582">        <span class="tok-str">&quot;::1234:5678&quot;</span>,</span>
<span class="line" id="L583">        <span class="tok-str">&quot;2001:db8::1234:5678&quot;</span>,</span>
<span class="line" id="L584">        <span class="tok-str">&quot;::ffff:123.5.123.5&quot;</span>,</span>
<span class="line" id="L585">    };</span>
<span class="line" id="L586"></span>
<span class="line" id="L587">    <span class="tok-kw">for</span> (inputs) |input, i| {</span>
<span class="line" id="L588">        <span class="tok-kw">try</span> testing.expectFmt(outputs[i], <span class="tok-str">&quot;{}&quot;</span>, .{<span class="tok-kw">try</span> IPv6.parse(input)});</span>
<span class="line" id="L589">    }</span>
<span class="line" id="L590">}</span>
<span class="line" id="L591"></span>
<span class="line" id="L592"><span class="tok-kw">test</span> <span class="tok-str">&quot;ipv6: parse &amp; format addresses with scope ids&quot;</span> {</span>
<span class="line" id="L593">    <span class="tok-kw">if</span> (!have_ifnamesize) <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SkipZigTest;</span>
<span class="line" id="L594">    <span class="tok-kw">const</span> iface = <span class="tok-kw">if</span> (native_os.tag == .linux)</span>
<span class="line" id="L595">        <span class="tok-str">&quot;lo&quot;</span></span>
<span class="line" id="L596">    <span class="tok-kw">else</span></span>
<span class="line" id="L597">        <span class="tok-str">&quot;lo0&quot;</span>;</span>
<span class="line" id="L598">    <span class="tok-kw">const</span> input = <span class="tok-str">&quot;FF01::FB%&quot;</span> ++ iface;</span>
<span class="line" id="L599">    <span class="tok-kw">const</span> output = <span class="tok-str">&quot;ff01::fb%1&quot;</span>;</span>
<span class="line" id="L600"></span>
<span class="line" id="L601">    <span class="tok-kw">const</span> parsed = IPv6.parse(input) <span class="tok-kw">catch</span> |err| <span class="tok-kw">switch</span> (err) {</span>
<span class="line" id="L602">        <span class="tok-kw">error</span>.InterfaceNotFound =&gt; <span class="tok-kw">return</span>,</span>
<span class="line" id="L603">        <span class="tok-kw">else</span> =&gt; <span class="tok-kw">return</span> err,</span>
<span class="line" id="L604">    };</span>
<span class="line" id="L605"></span>
<span class="line" id="L606">    <span class="tok-kw">try</span> testing.expectFmt(output, <span class="tok-str">&quot;{}&quot;</span>, .{parsed});</span>
<span class="line" id="L607">}</span>
<span class="line" id="L608"></span>
</code></pre></body>
</html>