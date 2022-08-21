<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">    <title>os/uefi/protocols/simple_network_protocol.zig - source view</title>
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
<pre><code><span class="line" id="L1"><span class="tok-kw">const</span> uefi = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;std&quot;</span>).os.uefi;</span>
<span class="line" id="L2"><span class="tok-kw">const</span> Event = uefi.Event;</span>
<span class="line" id="L3"><span class="tok-kw">const</span> Guid = uefi.Guid;</span>
<span class="line" id="L4"><span class="tok-kw">const</span> Status = uefi.Status;</span>
<span class="line" id="L5"></span>
<span class="line" id="L6"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SimpleNetworkProtocol = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L7">    revision: <span class="tok-type">u64</span>,</span>
<span class="line" id="L8">    _start: <span class="tok-kw">fn</span> (*<span class="tok-kw">const</span> SimpleNetworkProtocol) <span class="tok-kw">callconv</span>(.C) Status,</span>
<span class="line" id="L9">    _stop: <span class="tok-kw">fn</span> (*<span class="tok-kw">const</span> SimpleNetworkProtocol) <span class="tok-kw">callconv</span>(.C) Status,</span>
<span class="line" id="L10">    _initialize: <span class="tok-kw">fn</span> (*<span class="tok-kw">const</span> SimpleNetworkProtocol, <span class="tok-type">usize</span>, <span class="tok-type">usize</span>) <span class="tok-kw">callconv</span>(.C) Status,</span>
<span class="line" id="L11">    _reset: <span class="tok-kw">fn</span> (*<span class="tok-kw">const</span> SimpleNetworkProtocol, <span class="tok-type">bool</span>) <span class="tok-kw">callconv</span>(.C) Status,</span>
<span class="line" id="L12">    _shutdown: <span class="tok-kw">fn</span> (*<span class="tok-kw">const</span> SimpleNetworkProtocol) <span class="tok-kw">callconv</span>(.C) Status,</span>
<span class="line" id="L13">    _receive_filters: <span class="tok-kw">fn</span> (*<span class="tok-kw">const</span> SimpleNetworkProtocol, SimpleNetworkReceiveFilter, SimpleNetworkReceiveFilter, <span class="tok-type">bool</span>, <span class="tok-type">usize</span>, ?[*]<span class="tok-kw">const</span> MacAddress) <span class="tok-kw">callconv</span>(.C) Status,</span>
<span class="line" id="L14">    _station_address: <span class="tok-kw">fn</span> (*<span class="tok-kw">const</span> SimpleNetworkProtocol, <span class="tok-type">bool</span>, ?*<span class="tok-kw">const</span> MacAddress) <span class="tok-kw">callconv</span>(.C) Status,</span>
<span class="line" id="L15">    _statistics: <span class="tok-kw">fn</span> (*<span class="tok-kw">const</span> SimpleNetworkProtocol, <span class="tok-type">bool</span>, ?*<span class="tok-type">usize</span>, ?*NetworkStatistics) <span class="tok-kw">callconv</span>(.C) Status,</span>
<span class="line" id="L16">    _mcast_ip_to_mac: <span class="tok-kw">fn</span> (*<span class="tok-kw">const</span> SimpleNetworkProtocol, <span class="tok-type">bool</span>, *<span class="tok-kw">const</span> <span class="tok-type">anyopaque</span>, *MacAddress) <span class="tok-kw">callconv</span>(.C) Status,</span>
<span class="line" id="L17">    _nvdata: <span class="tok-kw">fn</span> (*<span class="tok-kw">const</span> SimpleNetworkProtocol, <span class="tok-type">bool</span>, <span class="tok-type">usize</span>, <span class="tok-type">usize</span>, [*]<span class="tok-type">u8</span>) <span class="tok-kw">callconv</span>(.C) Status,</span>
<span class="line" id="L18">    _get_status: <span class="tok-kw">fn</span> (*<span class="tok-kw">const</span> SimpleNetworkProtocol, *SimpleNetworkInterruptStatus, ?*?[*]<span class="tok-type">u8</span>) <span class="tok-kw">callconv</span>(.C) Status,</span>
<span class="line" id="L19">    _transmit: <span class="tok-kw">fn</span> (*<span class="tok-kw">const</span> SimpleNetworkProtocol, <span class="tok-type">usize</span>, <span class="tok-type">usize</span>, [*]<span class="tok-kw">const</span> <span class="tok-type">u8</span>, ?*<span class="tok-kw">const</span> MacAddress, ?*<span class="tok-kw">const</span> MacAddress, ?*<span class="tok-kw">const</span> <span class="tok-type">u16</span>) <span class="tok-kw">callconv</span>(.C) Status,</span>
<span class="line" id="L20">    _receive: <span class="tok-kw">fn</span> (*<span class="tok-kw">const</span> SimpleNetworkProtocol, ?*<span class="tok-type">usize</span>, *<span class="tok-type">usize</span>, [*]<span class="tok-type">u8</span>, ?*MacAddress, ?*MacAddress, ?*<span class="tok-type">u16</span>) <span class="tok-kw">callconv</span>(.C) Status,</span>
<span class="line" id="L21">    wait_for_packet: Event,</span>
<span class="line" id="L22">    mode: *SimpleNetworkMode,</span>
<span class="line" id="L23"></span>
<span class="line" id="L24">    <span class="tok-comment">/// Changes the state of a network interface from &quot;stopped&quot; to &quot;started&quot;.</span></span>
<span class="line" id="L25">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">start</span>(self: *<span class="tok-kw">const</span> SimpleNetworkProtocol) Status {</span>
<span class="line" id="L26">        <span class="tok-kw">return</span> self._start(self);</span>
<span class="line" id="L27">    }</span>
<span class="line" id="L28"></span>
<span class="line" id="L29">    <span class="tok-comment">/// Changes the state of a network interface from &quot;started&quot; to &quot;stopped&quot;.</span></span>
<span class="line" id="L30">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">stop</span>(self: *<span class="tok-kw">const</span> SimpleNetworkProtocol) Status {</span>
<span class="line" id="L31">        <span class="tok-kw">return</span> self._stop(self);</span>
<span class="line" id="L32">    }</span>
<span class="line" id="L33"></span>
<span class="line" id="L34">    <span class="tok-comment">/// Resets a network adapter and allocates the transmit and receive buffers required by the network interface.</span></span>
<span class="line" id="L35">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">initialize</span>(self: *<span class="tok-kw">const</span> SimpleNetworkProtocol, extra_rx_buffer_size: <span class="tok-type">usize</span>, extra_tx_buffer_size: <span class="tok-type">usize</span>) Status {</span>
<span class="line" id="L36">        <span class="tok-kw">return</span> self._initialize(self, extra_rx_buffer_size, extra_tx_buffer_size);</span>
<span class="line" id="L37">    }</span>
<span class="line" id="L38"></span>
<span class="line" id="L39">    <span class="tok-comment">/// Resets a network adapter and reinitializes it with the parameters that were provided in the previous call to initialize().</span></span>
<span class="line" id="L40">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">reset</span>(self: *<span class="tok-kw">const</span> SimpleNetworkProtocol, extended_verification: <span class="tok-type">bool</span>) Status {</span>
<span class="line" id="L41">        <span class="tok-kw">return</span> self._reset(self, extended_verification);</span>
<span class="line" id="L42">    }</span>
<span class="line" id="L43"></span>
<span class="line" id="L44">    <span class="tok-comment">/// Resets a network adapter and leaves it in a state that is safe for another driver to initialize.</span></span>
<span class="line" id="L45">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">shutdown</span>(self: *<span class="tok-kw">const</span> SimpleNetworkProtocol) Status {</span>
<span class="line" id="L46">        <span class="tok-kw">return</span> self._shutdown(self);</span>
<span class="line" id="L47">    }</span>
<span class="line" id="L48"></span>
<span class="line" id="L49">    <span class="tok-comment">/// Manages the multicast receive filters of a network interface.</span></span>
<span class="line" id="L50">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">receiveFilters</span>(self: *<span class="tok-kw">const</span> SimpleNetworkProtocol, enable: SimpleNetworkReceiveFilter, disable: SimpleNetworkReceiveFilter, reset_mcast_filter: <span class="tok-type">bool</span>, mcast_filter_cnt: <span class="tok-type">usize</span>, mcast_filter: ?[*]<span class="tok-kw">const</span> MacAddress) Status {</span>
<span class="line" id="L51">        <span class="tok-kw">return</span> self._receive_filters(self, enable, disable, reset_mcast_filter, mcast_filter_cnt, mcast_filter);</span>
<span class="line" id="L52">    }</span>
<span class="line" id="L53"></span>
<span class="line" id="L54">    <span class="tok-comment">/// Modifies or resets the current station address, if supported.</span></span>
<span class="line" id="L55">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">stationAddress</span>(self: *<span class="tok-kw">const</span> SimpleNetworkProtocol, reset_flag: <span class="tok-type">bool</span>, new: ?*<span class="tok-kw">const</span> MacAddress) Status {</span>
<span class="line" id="L56">        <span class="tok-kw">return</span> self._station_address(self, reset_flag, new);</span>
<span class="line" id="L57">    }</span>
<span class="line" id="L58"></span>
<span class="line" id="L59">    <span class="tok-comment">/// Resets or collects the statistics on a network interface.</span></span>
<span class="line" id="L60">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">statistics</span>(self: *<span class="tok-kw">const</span> SimpleNetworkProtocol, reset_flag: <span class="tok-type">bool</span>, statistics_size: ?*<span class="tok-type">usize</span>, statistics_table: ?*NetworkStatistics) Status {</span>
<span class="line" id="L61">        <span class="tok-kw">return</span> self._statistics(self, reset_flag, statistics_size, statistics_table);</span>
<span class="line" id="L62">    }</span>
<span class="line" id="L63"></span>
<span class="line" id="L64">    <span class="tok-comment">/// Converts a multicast IP address to a multicast HW MAC address.</span></span>
<span class="line" id="L65">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">mcastIpToMac</span>(self: *<span class="tok-kw">const</span> SimpleNetworkProtocol, ipv6: <span class="tok-type">bool</span>, ip: *<span class="tok-kw">const</span> <span class="tok-type">anyopaque</span>, mac: *MacAddress) Status {</span>
<span class="line" id="L66">        <span class="tok-kw">return</span> self._mcast_ip_to_mac(self, ipv6, ip, mac);</span>
<span class="line" id="L67">    }</span>
<span class="line" id="L68"></span>
<span class="line" id="L69">    <span class="tok-comment">/// Performs read and write operations on the NVRAM device attached to a network interface.</span></span>
<span class="line" id="L70">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">nvdata</span>(self: *<span class="tok-kw">const</span> SimpleNetworkProtocol, read_write: <span class="tok-type">bool</span>, offset: <span class="tok-type">usize</span>, buffer_size: <span class="tok-type">usize</span>, buffer: [*]<span class="tok-type">u8</span>) Status {</span>
<span class="line" id="L71">        <span class="tok-kw">return</span> self._nvdata(self, read_write, offset, buffer_size, buffer);</span>
<span class="line" id="L72">    }</span>
<span class="line" id="L73"></span>
<span class="line" id="L74">    <span class="tok-comment">/// Reads the current interrupt status and recycled transmit buffer status from a network interface.</span></span>
<span class="line" id="L75">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">getStatus</span>(self: *<span class="tok-kw">const</span> SimpleNetworkProtocol, interrupt_status: *SimpleNetworkInterruptStatus, tx_buf: ?*?[*]<span class="tok-type">u8</span>) Status {</span>
<span class="line" id="L76">        <span class="tok-kw">return</span> self._get_status(self, interrupt_status, tx_buf);</span>
<span class="line" id="L77">    }</span>
<span class="line" id="L78"></span>
<span class="line" id="L79">    <span class="tok-comment">/// Places a packet in the transmit queue of a network interface.</span></span>
<span class="line" id="L80">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">transmit</span>(self: *<span class="tok-kw">const</span> SimpleNetworkProtocol, header_size: <span class="tok-type">usize</span>, buffer_size: <span class="tok-type">usize</span>, buffer: [*]<span class="tok-kw">const</span> <span class="tok-type">u8</span>, src_addr: ?*<span class="tok-kw">const</span> MacAddress, dest_addr: ?*<span class="tok-kw">const</span> MacAddress, protocol: ?*<span class="tok-kw">const</span> <span class="tok-type">u16</span>) Status {</span>
<span class="line" id="L81">        <span class="tok-kw">return</span> self._transmit(self, header_size, buffer_size, buffer, src_addr, dest_addr, protocol);</span>
<span class="line" id="L82">    }</span>
<span class="line" id="L83"></span>
<span class="line" id="L84">    <span class="tok-comment">/// Receives a packet from a network interface.</span></span>
<span class="line" id="L85">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">receive</span>(self: *<span class="tok-kw">const</span> SimpleNetworkProtocol, header_size: ?*<span class="tok-type">usize</span>, buffer_size: *<span class="tok-type">usize</span>, buffer: [*]<span class="tok-type">u8</span>, src_addr: ?*MacAddress, dest_addr: ?*MacAddress, protocol: ?*<span class="tok-type">u16</span>) Status {</span>
<span class="line" id="L86">        <span class="tok-kw">return</span> self._receive(self, header_size, buffer_size, buffer, src_addr, dest_addr, protocol);</span>
<span class="line" id="L87">    }</span>
<span class="line" id="L88"></span>
<span class="line" id="L89">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> guid <span class="tok-kw">align</span>(<span class="tok-number">8</span>) = Guid{</span>
<span class="line" id="L90">        .time_low = <span class="tok-number">0xa19832b9</span>,</span>
<span class="line" id="L91">        .time_mid = <span class="tok-number">0xac25</span>,</span>
<span class="line" id="L92">        .time_high_and_version = <span class="tok-number">0x11d3</span>,</span>
<span class="line" id="L93">        .clock_seq_high_and_reserved = <span class="tok-number">0x9a</span>,</span>
<span class="line" id="L94">        .clock_seq_low = <span class="tok-number">0x2d</span>,</span>
<span class="line" id="L95">        .node = [_]<span class="tok-type">u8</span>{ <span class="tok-number">0x00</span>, <span class="tok-number">0x90</span>, <span class="tok-number">0x27</span>, <span class="tok-number">0x3f</span>, <span class="tok-number">0xc1</span>, <span class="tok-number">0x4d</span> },</span>
<span class="line" id="L96">    };</span>
<span class="line" id="L97">};</span>
<span class="line" id="L98"></span>
<span class="line" id="L99"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> MacAddress = [<span class="tok-number">32</span>]<span class="tok-type">u8</span>;</span>
<span class="line" id="L100"></span>
<span class="line" id="L101"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SimpleNetworkMode = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L102">    state: SimpleNetworkState,</span>
<span class="line" id="L103">    hw_address_size: <span class="tok-type">u32</span>,</span>
<span class="line" id="L104">    media_header_size: <span class="tok-type">u32</span>,</span>
<span class="line" id="L105">    max_packet_size: <span class="tok-type">u32</span>,</span>
<span class="line" id="L106">    nvram_size: <span class="tok-type">u32</span>,</span>
<span class="line" id="L107">    nvram_access_size: <span class="tok-type">u32</span>,</span>
<span class="line" id="L108">    receive_filter_mask: SimpleNetworkReceiveFilter,</span>
<span class="line" id="L109">    receive_filter_setting: SimpleNetworkReceiveFilter,</span>
<span class="line" id="L110">    max_mcast_filter_count: <span class="tok-type">u32</span>,</span>
<span class="line" id="L111">    mcast_filter_count: <span class="tok-type">u32</span>,</span>
<span class="line" id="L112">    mcast_filter: [<span class="tok-number">16</span>]MacAddress,</span>
<span class="line" id="L113">    current_address: MacAddress,</span>
<span class="line" id="L114">    broadcast_address: MacAddress,</span>
<span class="line" id="L115">    permanent_address: MacAddress,</span>
<span class="line" id="L116">    if_type: <span class="tok-type">u8</span>,</span>
<span class="line" id="L117">    mac_address_changeable: <span class="tok-type">bool</span>,</span>
<span class="line" id="L118">    multiple_tx_supported: <span class="tok-type">bool</span>,</span>
<span class="line" id="L119">    media_present_supported: <span class="tok-type">bool</span>,</span>
<span class="line" id="L120">    media_present: <span class="tok-type">bool</span>,</span>
<span class="line" id="L121">};</span>
<span class="line" id="L122"></span>
<span class="line" id="L123"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SimpleNetworkReceiveFilter = <span class="tok-kw">packed</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L124">    receive_unicast: <span class="tok-type">bool</span>,</span>
<span class="line" id="L125">    receive_multicast: <span class="tok-type">bool</span>,</span>
<span class="line" id="L126">    receive_broadcast: <span class="tok-type">bool</span>,</span>
<span class="line" id="L127">    receive_promiscuous: <span class="tok-type">bool</span>,</span>
<span class="line" id="L128">    receive_promiscuous_multicast: <span class="tok-type">bool</span>,</span>
<span class="line" id="L129">    _pad: <span class="tok-type">u27</span> = <span class="tok-number">0</span>,</span>
<span class="line" id="L130">};</span>
<span class="line" id="L131"></span>
<span class="line" id="L132"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SimpleNetworkState = <span class="tok-kw">enum</span>(<span class="tok-type">u32</span>) {</span>
<span class="line" id="L133">    Stopped,</span>
<span class="line" id="L134">    Started,</span>
<span class="line" id="L135">    Initialized,</span>
<span class="line" id="L136">};</span>
<span class="line" id="L137"></span>
<span class="line" id="L138"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> NetworkStatistics = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L139">    rx_total_frames: <span class="tok-type">u64</span>,</span>
<span class="line" id="L140">    rx_good_frames: <span class="tok-type">u64</span>,</span>
<span class="line" id="L141">    rx_undersize_frames: <span class="tok-type">u64</span>,</span>
<span class="line" id="L142">    rx_oversize_frames: <span class="tok-type">u64</span>,</span>
<span class="line" id="L143">    rx_dropped_frames: <span class="tok-type">u64</span>,</span>
<span class="line" id="L144">    rx_unicast_frames: <span class="tok-type">u64</span>,</span>
<span class="line" id="L145">    rx_broadcast_frames: <span class="tok-type">u64</span>,</span>
<span class="line" id="L146">    rx_multicast_frames: <span class="tok-type">u64</span>,</span>
<span class="line" id="L147">    rx_crc_error_frames: <span class="tok-type">u64</span>,</span>
<span class="line" id="L148">    rx_total_bytes: <span class="tok-type">u64</span>,</span>
<span class="line" id="L149">    tx_total_frames: <span class="tok-type">u64</span>,</span>
<span class="line" id="L150">    tx_good_frames: <span class="tok-type">u64</span>,</span>
<span class="line" id="L151">    tx_undersize_frames: <span class="tok-type">u64</span>,</span>
<span class="line" id="L152">    tx_oversize_frames: <span class="tok-type">u64</span>,</span>
<span class="line" id="L153">    tx_dropped_frames: <span class="tok-type">u64</span>,</span>
<span class="line" id="L154">    tx_unicast_frames: <span class="tok-type">u64</span>,</span>
<span class="line" id="L155">    tx_broadcast_frames: <span class="tok-type">u64</span>,</span>
<span class="line" id="L156">    tx_multicast_frames: <span class="tok-type">u64</span>,</span>
<span class="line" id="L157">    tx_crc_error_frames: <span class="tok-type">u64</span>,</span>
<span class="line" id="L158">    tx_total_bytes: <span class="tok-type">u64</span>,</span>
<span class="line" id="L159">    collisions: <span class="tok-type">u64</span>,</span>
<span class="line" id="L160">    unsupported_protocol: <span class="tok-type">u64</span>,</span>
<span class="line" id="L161">    rx_duplicated_frames: <span class="tok-type">u64</span>,</span>
<span class="line" id="L162">    rx_decryptError_frames: <span class="tok-type">u64</span>,</span>
<span class="line" id="L163">    tx_error_frames: <span class="tok-type">u64</span>,</span>
<span class="line" id="L164">    tx_retry_frames: <span class="tok-type">u64</span>,</span>
<span class="line" id="L165">};</span>
<span class="line" id="L166"></span>
<span class="line" id="L167"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SimpleNetworkInterruptStatus = <span class="tok-kw">packed</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L168">    receive_interrupt: <span class="tok-type">bool</span>,</span>
<span class="line" id="L169">    transmit_interrupt: <span class="tok-type">bool</span>,</span>
<span class="line" id="L170">    command_interrupt: <span class="tok-type">bool</span>,</span>
<span class="line" id="L171">    software_interrupt: <span class="tok-type">bool</span>,</span>
<span class="line" id="L172">    _pad: <span class="tok-type">u28</span> = <span class="tok-number">0</span>,</span>
<span class="line" id="L173">};</span>
<span class="line" id="L174"></span>
</code></pre></body>
</html>