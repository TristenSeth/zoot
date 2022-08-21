<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">    <title>os/uefi/protocols/managed_network_protocol.zig - source view</title>
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
<span class="line" id="L2"><span class="tok-kw">const</span> Guid = uefi.Guid;</span>
<span class="line" id="L3"><span class="tok-kw">const</span> Event = uefi.Event;</span>
<span class="line" id="L4"><span class="tok-kw">const</span> Status = uefi.Status;</span>
<span class="line" id="L5"><span class="tok-kw">const</span> Time = uefi.Time;</span>
<span class="line" id="L6"><span class="tok-kw">const</span> SimpleNetworkMode = uefi.protocols.SimpleNetworkMode;</span>
<span class="line" id="L7"><span class="tok-kw">const</span> MacAddress = uefi.protocols.MacAddress;</span>
<span class="line" id="L8"></span>
<span class="line" id="L9"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> ManagedNetworkProtocol = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L10">    _get_mode_data: <span class="tok-kw">fn</span> (*<span class="tok-kw">const</span> ManagedNetworkProtocol, ?*ManagedNetworkConfigData, ?*SimpleNetworkMode) <span class="tok-kw">callconv</span>(.C) Status,</span>
<span class="line" id="L11">    _configure: <span class="tok-kw">fn</span> (*<span class="tok-kw">const</span> ManagedNetworkProtocol, ?*<span class="tok-kw">const</span> ManagedNetworkConfigData) <span class="tok-kw">callconv</span>(.C) Status,</span>
<span class="line" id="L12">    _mcast_ip_to_mac: <span class="tok-kw">fn</span> (*<span class="tok-kw">const</span> ManagedNetworkProtocol, <span class="tok-type">bool</span>, *<span class="tok-kw">const</span> <span class="tok-type">anyopaque</span>, *MacAddress) <span class="tok-kw">callconv</span>(.C) Status,</span>
<span class="line" id="L13">    _groups: <span class="tok-kw">fn</span> (*<span class="tok-kw">const</span> ManagedNetworkProtocol, <span class="tok-type">bool</span>, ?*<span class="tok-kw">const</span> MacAddress) <span class="tok-kw">callconv</span>(.C) Status,</span>
<span class="line" id="L14">    _transmit: <span class="tok-kw">fn</span> (*<span class="tok-kw">const</span> ManagedNetworkProtocol, *<span class="tok-kw">const</span> ManagedNetworkCompletionToken) <span class="tok-kw">callconv</span>(.C) Status,</span>
<span class="line" id="L15">    _receive: <span class="tok-kw">fn</span> (*<span class="tok-kw">const</span> ManagedNetworkProtocol, *<span class="tok-kw">const</span> ManagedNetworkCompletionToken) <span class="tok-kw">callconv</span>(.C) Status,</span>
<span class="line" id="L16">    _cancel: <span class="tok-kw">fn</span> (*<span class="tok-kw">const</span> ManagedNetworkProtocol, ?*<span class="tok-kw">const</span> ManagedNetworkCompletionToken) <span class="tok-kw">callconv</span>(.C) Status,</span>
<span class="line" id="L17">    _poll: <span class="tok-kw">fn</span> (*<span class="tok-kw">const</span> ManagedNetworkProtocol) <span class="tok-kw">callconv</span>(.C) <span class="tok-type">usize</span>,</span>
<span class="line" id="L18"></span>
<span class="line" id="L19">    <span class="tok-comment">/// Returns the operational parameters for the current MNP child driver.</span></span>
<span class="line" id="L20">    <span class="tok-comment">/// May also support returning the underlying SNP driver mode data.</span></span>
<span class="line" id="L21">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">getModeData</span>(self: *<span class="tok-kw">const</span> ManagedNetworkProtocol, mnp_config_data: ?*ManagedNetworkConfigData, snp_mode_data: ?*SimpleNetworkMode) Status {</span>
<span class="line" id="L22">        <span class="tok-kw">return</span> self._get_mode_data(self, mnp_config_data, snp_mode_data);</span>
<span class="line" id="L23">    }</span>
<span class="line" id="L24"></span>
<span class="line" id="L25">    <span class="tok-comment">/// Sets or clears the operational parameters for the MNP child driver.</span></span>
<span class="line" id="L26">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">configure</span>(self: *<span class="tok-kw">const</span> ManagedNetworkProtocol, mnp_config_data: ?*<span class="tok-kw">const</span> ManagedNetworkConfigData) Status {</span>
<span class="line" id="L27">        <span class="tok-kw">return</span> self._configure(self, mnp_config_data);</span>
<span class="line" id="L28">    }</span>
<span class="line" id="L29"></span>
<span class="line" id="L30">    <span class="tok-comment">/// Translates an IP multicast address to a hardware (MAC) multicast address.</span></span>
<span class="line" id="L31">    <span class="tok-comment">/// This function may be unsupported in some MNP implementations.</span></span>
<span class="line" id="L32">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">mcastIpToMac</span>(self: *<span class="tok-kw">const</span> ManagedNetworkProtocol, ipv6flag: <span class="tok-type">bool</span>, ipaddress: *<span class="tok-kw">const</span> <span class="tok-type">anyopaque</span>, mac_address: *MacAddress) Status {</span>
<span class="line" id="L33">        _ = mac_address;</span>
<span class="line" id="L34">        <span class="tok-kw">return</span> self._mcast_ip_to_mac(self, ipv6flag, ipaddress);</span>
<span class="line" id="L35">    }</span>
<span class="line" id="L36"></span>
<span class="line" id="L37">    <span class="tok-comment">/// Enables and disables receive filters for multicast address.</span></span>
<span class="line" id="L38">    <span class="tok-comment">/// This function may be unsupported in some MNP implementations.</span></span>
<span class="line" id="L39">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">groups</span>(self: *<span class="tok-kw">const</span> ManagedNetworkProtocol, join_flag: <span class="tok-type">bool</span>, mac_address: ?*<span class="tok-kw">const</span> MacAddress) Status {</span>
<span class="line" id="L40">        <span class="tok-kw">return</span> self._groups(self, join_flag, mac_address);</span>
<span class="line" id="L41">    }</span>
<span class="line" id="L42"></span>
<span class="line" id="L43">    <span class="tok-comment">/// Places asynchronous outgoing data packets into the transmit queue.</span></span>
<span class="line" id="L44">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">transmit</span>(self: *<span class="tok-kw">const</span> ManagedNetworkProtocol, token: *<span class="tok-kw">const</span> ManagedNetworkCompletionToken) Status {</span>
<span class="line" id="L45">        <span class="tok-kw">return</span> self._transmit(self, token);</span>
<span class="line" id="L46">    }</span>
<span class="line" id="L47"></span>
<span class="line" id="L48">    <span class="tok-comment">/// Places an asynchronous receiving request into the receiving queue.</span></span>
<span class="line" id="L49">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">receive</span>(self: *<span class="tok-kw">const</span> ManagedNetworkProtocol, token: *<span class="tok-kw">const</span> ManagedNetworkCompletionToken) Status {</span>
<span class="line" id="L50">        <span class="tok-kw">return</span> self._receive(self, token);</span>
<span class="line" id="L51">    }</span>
<span class="line" id="L52"></span>
<span class="line" id="L53">    <span class="tok-comment">/// Aborts an asynchronous transmit or receive request.</span></span>
<span class="line" id="L54">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">cancel</span>(self: *<span class="tok-kw">const</span> ManagedNetworkProtocol, token: ?*<span class="tok-kw">const</span> ManagedNetworkCompletionToken) Status {</span>
<span class="line" id="L55">        <span class="tok-kw">return</span> self._cancel(self, token);</span>
<span class="line" id="L56">    }</span>
<span class="line" id="L57"></span>
<span class="line" id="L58">    <span class="tok-comment">/// Polls for incoming data packets and processes outgoing data packets.</span></span>
<span class="line" id="L59">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">poll</span>(self: *<span class="tok-kw">const</span> ManagedNetworkProtocol) Status {</span>
<span class="line" id="L60">        <span class="tok-kw">return</span> self._poll(self);</span>
<span class="line" id="L61">    }</span>
<span class="line" id="L62"></span>
<span class="line" id="L63">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> guid <span class="tok-kw">align</span>(<span class="tok-number">8</span>) = Guid{</span>
<span class="line" id="L64">        .time_low = <span class="tok-number">0x7ab33a91</span>,</span>
<span class="line" id="L65">        .time_mid = <span class="tok-number">0xace5</span>,</span>
<span class="line" id="L66">        .time_high_and_version = <span class="tok-number">0x4326</span>,</span>
<span class="line" id="L67">        .clock_seq_high_and_reserved = <span class="tok-number">0xb5</span>,</span>
<span class="line" id="L68">        .clock_seq_low = <span class="tok-number">0x72</span>,</span>
<span class="line" id="L69">        .node = [_]<span class="tok-type">u8</span>{ <span class="tok-number">0xe7</span>, <span class="tok-number">0xee</span>, <span class="tok-number">0x33</span>, <span class="tok-number">0xd3</span>, <span class="tok-number">0x9f</span>, <span class="tok-number">0x16</span> },</span>
<span class="line" id="L70">    };</span>
<span class="line" id="L71">};</span>
<span class="line" id="L72"></span>
<span class="line" id="L73"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> ManagedNetworkConfigData = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L74">    received_queue_timeout_value: <span class="tok-type">u32</span>,</span>
<span class="line" id="L75">    transmit_queue_timeout_value: <span class="tok-type">u32</span>,</span>
<span class="line" id="L76">    protocol_type_filter: <span class="tok-type">u16</span>,</span>
<span class="line" id="L77">    enable_unicast_receive: <span class="tok-type">bool</span>,</span>
<span class="line" id="L78">    enable_multicast_receive: <span class="tok-type">bool</span>,</span>
<span class="line" id="L79">    enable_broadcast_receive: <span class="tok-type">bool</span>,</span>
<span class="line" id="L80">    enable_promiscuous_receive: <span class="tok-type">bool</span>,</span>
<span class="line" id="L81">    flush_queues_on_reset: <span class="tok-type">bool</span>,</span>
<span class="line" id="L82">    enable_receive_timestamps: <span class="tok-type">bool</span>,</span>
<span class="line" id="L83">    disable_background_polling: <span class="tok-type">bool</span>,</span>
<span class="line" id="L84">};</span>
<span class="line" id="L85"></span>
<span class="line" id="L86"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> ManagedNetworkCompletionToken = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L87">    event: Event,</span>
<span class="line" id="L88">    status: Status,</span>
<span class="line" id="L89">    packet: <span class="tok-kw">extern</span> <span class="tok-kw">union</span> {</span>
<span class="line" id="L90">        RxData: *ManagedNetworkReceiveData,</span>
<span class="line" id="L91">        TxData: *ManagedNetworkTransmitData,</span>
<span class="line" id="L92">    },</span>
<span class="line" id="L93">};</span>
<span class="line" id="L94"></span>
<span class="line" id="L95"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> ManagedNetworkReceiveData = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L96">    timestamp: Time,</span>
<span class="line" id="L97">    recycle_event: Event,</span>
<span class="line" id="L98">    packet_length: <span class="tok-type">u32</span>,</span>
<span class="line" id="L99">    header_length: <span class="tok-type">u32</span>,</span>
<span class="line" id="L100">    address_length: <span class="tok-type">u32</span>,</span>
<span class="line" id="L101">    data_length: <span class="tok-type">u32</span>,</span>
<span class="line" id="L102">    broadcast_flag: <span class="tok-type">bool</span>,</span>
<span class="line" id="L103">    multicast_flag: <span class="tok-type">bool</span>,</span>
<span class="line" id="L104">    promiscuous_flag: <span class="tok-type">bool</span>,</span>
<span class="line" id="L105">    protocol_type: <span class="tok-type">u16</span>,</span>
<span class="line" id="L106">    destination_address: [*]<span class="tok-type">u8</span>,</span>
<span class="line" id="L107">    source_address: [*]<span class="tok-type">u8</span>,</span>
<span class="line" id="L108">    media_header: [*]<span class="tok-type">u8</span>,</span>
<span class="line" id="L109">    packet_data: [*]<span class="tok-type">u8</span>,</span>
<span class="line" id="L110">};</span>
<span class="line" id="L111"></span>
<span class="line" id="L112"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> ManagedNetworkTransmitData = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L113">    destination_address: ?*MacAddress,</span>
<span class="line" id="L114">    source_address: ?*MacAddress,</span>
<span class="line" id="L115">    protocol_type: <span class="tok-type">u16</span>,</span>
<span class="line" id="L116">    data_length: <span class="tok-type">u32</span>,</span>
<span class="line" id="L117">    header_length: <span class="tok-type">u16</span>,</span>
<span class="line" id="L118">    fragment_count: <span class="tok-type">u16</span>,</span>
<span class="line" id="L119"></span>
<span class="line" id="L120">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">getFragments</span>(self: *ManagedNetworkTransmitData) []ManagedNetworkFragmentData {</span>
<span class="line" id="L121">        <span class="tok-kw">return</span> <span class="tok-builtin">@ptrCast</span>([*]ManagedNetworkFragmentData, <span class="tok-builtin">@ptrCast</span>([*]<span class="tok-type">u8</span>, self) + <span class="tok-builtin">@sizeOf</span>(ManagedNetworkTransmitData))[<span class="tok-number">0</span>..self.fragment_count];</span>
<span class="line" id="L122">    }</span>
<span class="line" id="L123">};</span>
<span class="line" id="L124"></span>
<span class="line" id="L125"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> ManagedNetworkFragmentData = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L126">    fragment_length: <span class="tok-type">u32</span>,</span>
<span class="line" id="L127">    fragment_buffer: [*]<span class="tok-type">u8</span>,</span>
<span class="line" id="L128">};</span>
<span class="line" id="L129"></span>
</code></pre></body>
</html>