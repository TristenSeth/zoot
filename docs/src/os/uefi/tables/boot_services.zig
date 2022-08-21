<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">    <title>os/uefi/tables/boot_services.zig - source view</title>
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
<span class="line" id="L4"><span class="tok-kw">const</span> Handle = uefi.Handle;</span>
<span class="line" id="L5"><span class="tok-kw">const</span> Status = uefi.Status;</span>
<span class="line" id="L6"><span class="tok-kw">const</span> TableHeader = uefi.tables.TableHeader;</span>
<span class="line" id="L7"><span class="tok-kw">const</span> DevicePathProtocol = uefi.protocols.DevicePathProtocol;</span>
<span class="line" id="L8"></span>
<span class="line" id="L9"><span class="tok-comment">/// Boot services are services provided by the system's firmware until the operating system takes</span></span>
<span class="line" id="L10"><span class="tok-comment">/// over control over the hardware by calling exitBootServices.</span></span>
<span class="line" id="L11"><span class="tok-comment">///</span></span>
<span class="line" id="L12"><span class="tok-comment">/// Boot Services must not be used after exitBootServices has been called. The only exception is</span></span>
<span class="line" id="L13"><span class="tok-comment">/// getMemoryMap, which may be used after the first unsuccessful call to exitBootServices.</span></span>
<span class="line" id="L14"><span class="tok-comment">/// After successfully calling exitBootServices, system_table.console_in_handle, system_table.con_in,</span></span>
<span class="line" id="L15"><span class="tok-comment">/// system_table.console_out_handle, system_table.con_out, system_table.standard_error_handle,</span></span>
<span class="line" id="L16"><span class="tok-comment">/// system_table.std_err, and system_table.boot_services should be set to null. After setting these</span></span>
<span class="line" id="L17"><span class="tok-comment">/// attributes to null, system_table.hdr.crc32 must be recomputed.</span></span>
<span class="line" id="L18"><span class="tok-comment">///</span></span>
<span class="line" id="L19"><span class="tok-comment">/// As the boot_services table may grow with new UEFI versions, it is important to check hdr.header_size.</span></span>
<span class="line" id="L20"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> BootServices = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L21">    hdr: TableHeader,</span>
<span class="line" id="L22"></span>
<span class="line" id="L23">    <span class="tok-comment">/// Raises a task's priority level and returns its previous level.</span></span>
<span class="line" id="L24">    raiseTpl: <span class="tok-kw">fn</span> (new_tpl: <span class="tok-type">usize</span>) <span class="tok-kw">callconv</span>(.C) <span class="tok-type">usize</span>,</span>
<span class="line" id="L25"></span>
<span class="line" id="L26">    <span class="tok-comment">/// Restores a task's priority level to its previous value.</span></span>
<span class="line" id="L27">    restoreTpl: <span class="tok-kw">fn</span> (old_tpl: <span class="tok-type">usize</span>) <span class="tok-kw">callconv</span>(.C) <span class="tok-type">void</span>,</span>
<span class="line" id="L28"></span>
<span class="line" id="L29">    <span class="tok-comment">/// Allocates memory pages from the system.</span></span>
<span class="line" id="L30">    allocatePages: <span class="tok-kw">fn</span> (alloc_type: AllocateType, mem_type: MemoryType, pages: <span class="tok-type">usize</span>, memory: *[*]<span class="tok-kw">align</span>(<span class="tok-number">4096</span>) <span class="tok-type">u8</span>) <span class="tok-kw">callconv</span>(.C) Status,</span>
<span class="line" id="L31"></span>
<span class="line" id="L32">    <span class="tok-comment">/// Frees memory pages.</span></span>
<span class="line" id="L33">    freePages: <span class="tok-kw">fn</span> (memory: [*]<span class="tok-kw">align</span>(<span class="tok-number">4096</span>) <span class="tok-type">u8</span>, pages: <span class="tok-type">usize</span>) <span class="tok-kw">callconv</span>(.C) Status,</span>
<span class="line" id="L34"></span>
<span class="line" id="L35">    <span class="tok-comment">/// Returns the current memory map.</span></span>
<span class="line" id="L36">    getMemoryMap: <span class="tok-kw">fn</span> (mmap_size: *<span class="tok-type">usize</span>, mmap: [*]MemoryDescriptor, mapKey: *<span class="tok-type">usize</span>, descriptor_size: *<span class="tok-type">usize</span>, descriptor_version: *<span class="tok-type">u32</span>) <span class="tok-kw">callconv</span>(.C) Status,</span>
<span class="line" id="L37"></span>
<span class="line" id="L38">    <span class="tok-comment">/// Allocates pool memory.</span></span>
<span class="line" id="L39">    allocatePool: <span class="tok-kw">fn</span> (pool_type: MemoryType, size: <span class="tok-type">usize</span>, buffer: *[*]<span class="tok-kw">align</span>(<span class="tok-number">8</span>) <span class="tok-type">u8</span>) <span class="tok-kw">callconv</span>(.C) Status,</span>
<span class="line" id="L40"></span>
<span class="line" id="L41">    <span class="tok-comment">/// Returns pool memory to the system.</span></span>
<span class="line" id="L42">    freePool: <span class="tok-kw">fn</span> (buffer: [*]<span class="tok-kw">align</span>(<span class="tok-number">8</span>) <span class="tok-type">u8</span>) <span class="tok-kw">callconv</span>(.C) Status,</span>
<span class="line" id="L43"></span>
<span class="line" id="L44">    <span class="tok-comment">/// Creates an event.</span></span>
<span class="line" id="L45">    createEvent: <span class="tok-kw">fn</span> (<span class="tok-type">type</span>: <span class="tok-type">u32</span>, notify_tpl: <span class="tok-type">usize</span>, notify_func: ?<span class="tok-kw">fn</span> (Event, ?*<span class="tok-type">anyopaque</span>) <span class="tok-kw">callconv</span>(.C) <span class="tok-type">void</span>, notifyCtx: ?*<span class="tok-kw">const</span> <span class="tok-type">anyopaque</span>, event: *Event) <span class="tok-kw">callconv</span>(.C) Status,</span>
<span class="line" id="L46"></span>
<span class="line" id="L47">    <span class="tok-comment">/// Sets the type of timer and the trigger time for a timer event.</span></span>
<span class="line" id="L48">    setTimer: <span class="tok-kw">fn</span> (event: Event, <span class="tok-type">type</span>: TimerDelay, triggerTime: <span class="tok-type">u64</span>) <span class="tok-kw">callconv</span>(.C) Status,</span>
<span class="line" id="L49"></span>
<span class="line" id="L50">    <span class="tok-comment">/// Stops execution until an event is signaled.</span></span>
<span class="line" id="L51">    waitForEvent: <span class="tok-kw">fn</span> (event_len: <span class="tok-type">usize</span>, events: [*]<span class="tok-kw">const</span> Event, index: *<span class="tok-type">usize</span>) <span class="tok-kw">callconv</span>(.C) Status,</span>
<span class="line" id="L52"></span>
<span class="line" id="L53">    <span class="tok-comment">/// Signals an event.</span></span>
<span class="line" id="L54">    signalEvent: <span class="tok-kw">fn</span> (event: Event) <span class="tok-kw">callconv</span>(.C) Status,</span>
<span class="line" id="L55"></span>
<span class="line" id="L56">    <span class="tok-comment">/// Closes an event.</span></span>
<span class="line" id="L57">    closeEvent: <span class="tok-kw">fn</span> (event: Event) <span class="tok-kw">callconv</span>(.C) Status,</span>
<span class="line" id="L58"></span>
<span class="line" id="L59">    <span class="tok-comment">/// Checks whether an event is in the signaled state.</span></span>
<span class="line" id="L60">    checkEvent: <span class="tok-kw">fn</span> (event: Event) <span class="tok-kw">callconv</span>(.C) Status,</span>
<span class="line" id="L61"></span>
<span class="line" id="L62">    <span class="tok-comment">/// Installs a protocol interface on a device handle. If the handle does not exist, it is created</span></span>
<span class="line" id="L63">    <span class="tok-comment">/// and added to the list of handles in the system. installMultipleProtocolInterfaces()</span></span>
<span class="line" id="L64">    <span class="tok-comment">/// performs more error checking than installProtocolInterface(), so its use is recommended over this.</span></span>
<span class="line" id="L65">    installProtocolInterface: <span class="tok-kw">fn</span> (handle: Handle, protocol: *<span class="tok-kw">align</span>(<span class="tok-number">8</span>) <span class="tok-kw">const</span> Guid, interface_type: EfiInterfaceType, interface: *<span class="tok-type">anyopaque</span>) <span class="tok-kw">callconv</span>(.C) Status,</span>
<span class="line" id="L66"></span>
<span class="line" id="L67">    <span class="tok-comment">/// Reinstalls a protocol interface on a device handle</span></span>
<span class="line" id="L68">    reinstallProtocolInterface: <span class="tok-kw">fn</span> (handle: Handle, protocol: *<span class="tok-kw">align</span>(<span class="tok-number">8</span>) <span class="tok-kw">const</span> Guid, old_interface: *<span class="tok-type">anyopaque</span>, new_interface: *<span class="tok-type">anyopaque</span>) <span class="tok-kw">callconv</span>(.C) Status,</span>
<span class="line" id="L69"></span>
<span class="line" id="L70">    <span class="tok-comment">/// Removes a protocol interface from a device handle. Usage of</span></span>
<span class="line" id="L71">    <span class="tok-comment">/// uninstallMultipleProtocolInterfaces is recommended over this.</span></span>
<span class="line" id="L72">    uninstallProtocolInterface: <span class="tok-kw">fn</span> (handle: Handle, protocol: *<span class="tok-kw">align</span>(<span class="tok-number">8</span>) <span class="tok-kw">const</span> Guid, interface: *<span class="tok-type">anyopaque</span>) <span class="tok-kw">callconv</span>(.C) Status,</span>
<span class="line" id="L73"></span>
<span class="line" id="L74">    <span class="tok-comment">/// Queries a handle to determine if it supports a specified protocol.</span></span>
<span class="line" id="L75">    handleProtocol: <span class="tok-kw">fn</span> (handle: Handle, protocol: *<span class="tok-kw">align</span>(<span class="tok-number">8</span>) <span class="tok-kw">const</span> Guid, interface: *?*<span class="tok-type">anyopaque</span>) <span class="tok-kw">callconv</span>(.C) Status,</span>
<span class="line" id="L76"></span>
<span class="line" id="L77">    reserved: *<span class="tok-type">anyopaque</span>,</span>
<span class="line" id="L78"></span>
<span class="line" id="L79">    <span class="tok-comment">/// Creates an event that is to be signaled whenever an interface is installed for a specified protocol.</span></span>
<span class="line" id="L80">    registerProtocolNotify: <span class="tok-kw">fn</span> (protocol: *<span class="tok-kw">align</span>(<span class="tok-number">8</span>) <span class="tok-kw">const</span> Guid, event: Event, registration: **<span class="tok-type">anyopaque</span>) <span class="tok-kw">callconv</span>(.C) Status,</span>
<span class="line" id="L81"></span>
<span class="line" id="L82">    <span class="tok-comment">/// Returns an array of handles that support a specified protocol.</span></span>
<span class="line" id="L83">    locateHandle: <span class="tok-kw">fn</span> (search_type: LocateSearchType, protocol: ?*<span class="tok-kw">align</span>(<span class="tok-number">8</span>) <span class="tok-kw">const</span> Guid, search_key: ?*<span class="tok-kw">const</span> <span class="tok-type">anyopaque</span>, bufferSize: *<span class="tok-type">usize</span>, buffer: [*]Handle) <span class="tok-kw">callconv</span>(.C) Status,</span>
<span class="line" id="L84"></span>
<span class="line" id="L85">    <span class="tok-comment">/// Locates the handle to a device on the device path that supports the specified protocol</span></span>
<span class="line" id="L86">    locateDevicePath: <span class="tok-kw">fn</span> (protocols: *<span class="tok-kw">align</span>(<span class="tok-number">8</span>) <span class="tok-kw">const</span> Guid, device_path: **<span class="tok-kw">const</span> DevicePathProtocol, device: *?Handle) <span class="tok-kw">callconv</span>(.C) Status,</span>
<span class="line" id="L87"></span>
<span class="line" id="L88">    <span class="tok-comment">/// Adds, updates, or removes a configuration table entry from the EFI System Table.</span></span>
<span class="line" id="L89">    installConfigurationTable: <span class="tok-kw">fn</span> (guid: *<span class="tok-kw">align</span>(<span class="tok-number">8</span>) <span class="tok-kw">const</span> Guid, table: ?*<span class="tok-type">anyopaque</span>) <span class="tok-kw">callconv</span>(.C) Status,</span>
<span class="line" id="L90"></span>
<span class="line" id="L91">    <span class="tok-comment">/// Loads an EFI image into memory.</span></span>
<span class="line" id="L92">    loadImage: <span class="tok-kw">fn</span> (boot_policy: <span class="tok-type">bool</span>, parent_image_handle: Handle, device_path: ?*<span class="tok-kw">const</span> DevicePathProtocol, source_buffer: ?[*]<span class="tok-kw">const</span> <span class="tok-type">u8</span>, source_size: <span class="tok-type">usize</span>, imageHandle: *?Handle) <span class="tok-kw">callconv</span>(.C) Status,</span>
<span class="line" id="L93"></span>
<span class="line" id="L94">    <span class="tok-comment">/// Transfers control to a loaded image's entry point.</span></span>
<span class="line" id="L95">    startImage: <span class="tok-kw">fn</span> (image_handle: Handle, exit_data_size: ?*<span class="tok-type">usize</span>, exit_data: ?*[*]<span class="tok-type">u16</span>) <span class="tok-kw">callconv</span>(.C) Status,</span>
<span class="line" id="L96"></span>
<span class="line" id="L97">    <span class="tok-comment">/// Terminates a loaded EFI image and returns control to boot services.</span></span>
<span class="line" id="L98">    exit: <span class="tok-kw">fn</span> (image_handle: Handle, exit_status: Status, exit_data_size: <span class="tok-type">usize</span>, exit_data: ?*<span class="tok-kw">const</span> <span class="tok-type">anyopaque</span>) <span class="tok-kw">callconv</span>(.C) Status,</span>
<span class="line" id="L99"></span>
<span class="line" id="L100">    <span class="tok-comment">/// Unloads an image.</span></span>
<span class="line" id="L101">    unloadImage: <span class="tok-kw">fn</span> (image_handle: Handle) <span class="tok-kw">callconv</span>(.C) Status,</span>
<span class="line" id="L102"></span>
<span class="line" id="L103">    <span class="tok-comment">/// Terminates all boot services.</span></span>
<span class="line" id="L104">    exitBootServices: <span class="tok-kw">fn</span> (image_handle: Handle, map_key: <span class="tok-type">usize</span>) <span class="tok-kw">callconv</span>(.C) Status,</span>
<span class="line" id="L105"></span>
<span class="line" id="L106">    <span class="tok-comment">/// Returns a monotonically increasing count for the platform.</span></span>
<span class="line" id="L107">    getNextMonotonicCount: <span class="tok-kw">fn</span> (count: *<span class="tok-type">u64</span>) <span class="tok-kw">callconv</span>(.C) Status,</span>
<span class="line" id="L108"></span>
<span class="line" id="L109">    <span class="tok-comment">/// Induces a fine-grained stall.</span></span>
<span class="line" id="L110">    stall: <span class="tok-kw">fn</span> (microseconds: <span class="tok-type">usize</span>) <span class="tok-kw">callconv</span>(.C) Status,</span>
<span class="line" id="L111"></span>
<span class="line" id="L112">    <span class="tok-comment">/// Sets the system's watchdog timer.</span></span>
<span class="line" id="L113">    setWatchdogTimer: <span class="tok-kw">fn</span> (timeout: <span class="tok-type">usize</span>, watchdogCode: <span class="tok-type">u64</span>, data_size: <span class="tok-type">usize</span>, watchdog_data: ?[*]<span class="tok-kw">const</span> <span class="tok-type">u16</span>) <span class="tok-kw">callconv</span>(.C) Status,</span>
<span class="line" id="L114"></span>
<span class="line" id="L115">    <span class="tok-comment">/// Connects one or more drives to a controller.</span></span>
<span class="line" id="L116">    connectController: <span class="tok-kw">fn</span> (controller_handle: Handle, driver_image_handle: ?Handle, remaining_device_path: ?*DevicePathProtocol, recursive: <span class="tok-type">bool</span>) <span class="tok-kw">callconv</span>(.C) Status,</span>
<span class="line" id="L117"></span>
<span class="line" id="L118">    <span class="tok-comment">// Disconnects one or more drivers from a controller</span>
</span>
<span class="line" id="L119">    disconnectController: <span class="tok-kw">fn</span> (controller_handle: Handle, driver_image_handle: ?Handle, child_handle: ?Handle) <span class="tok-kw">callconv</span>(.C) Status,</span>
<span class="line" id="L120"></span>
<span class="line" id="L121">    <span class="tok-comment">/// Queries a handle to determine if it supports a specified protocol.</span></span>
<span class="line" id="L122">    openProtocol: <span class="tok-kw">fn</span> (handle: Handle, protocol: *<span class="tok-kw">align</span>(<span class="tok-number">8</span>) <span class="tok-kw">const</span> Guid, interface: *?*<span class="tok-type">anyopaque</span>, agent_handle: ?Handle, controller_handle: ?Handle, attributes: OpenProtocolAttributes) <span class="tok-kw">callconv</span>(.C) Status,</span>
<span class="line" id="L123"></span>
<span class="line" id="L124">    <span class="tok-comment">/// Closes a protocol on a handle that was opened using openProtocol().</span></span>
<span class="line" id="L125">    closeProtocol: <span class="tok-kw">fn</span> (handle: Handle, protocol: *<span class="tok-kw">align</span>(<span class="tok-number">8</span>) <span class="tok-kw">const</span> Guid, agentHandle: Handle, controller_handle: ?Handle) <span class="tok-kw">callconv</span>(.C) Status,</span>
<span class="line" id="L126"></span>
<span class="line" id="L127">    <span class="tok-comment">/// Retrieves the list of agents that currently have a protocol interface opened.</span></span>
<span class="line" id="L128">    openProtocolInformation: <span class="tok-kw">fn</span> (handle: Handle, protocol: *<span class="tok-kw">align</span>(<span class="tok-number">8</span>) <span class="tok-kw">const</span> Guid, entry_buffer: *[*]ProtocolInformationEntry, entry_count: *<span class="tok-type">usize</span>) <span class="tok-kw">callconv</span>(.C) Status,</span>
<span class="line" id="L129"></span>
<span class="line" id="L130">    <span class="tok-comment">/// Retrieves the list of protocol interface GUIDs that are installed on a handle in a buffer allocated from pool.</span></span>
<span class="line" id="L131">    protocolsPerHandle: <span class="tok-kw">fn</span> (handle: Handle, protocol_buffer: *[*]*<span class="tok-kw">align</span>(<span class="tok-number">8</span>) <span class="tok-kw">const</span> Guid, protocol_buffer_count: *<span class="tok-type">usize</span>) <span class="tok-kw">callconv</span>(.C) Status,</span>
<span class="line" id="L132"></span>
<span class="line" id="L133">    <span class="tok-comment">/// Returns an array of handles that support the requested protocol in a buffer allocated from pool.</span></span>
<span class="line" id="L134">    locateHandleBuffer: <span class="tok-kw">fn</span> (search_type: LocateSearchType, protocol: ?*<span class="tok-kw">align</span>(<span class="tok-number">8</span>) <span class="tok-kw">const</span> Guid, search_key: ?*<span class="tok-kw">const</span> <span class="tok-type">anyopaque</span>, num_handles: *<span class="tok-type">usize</span>, buffer: *[*]Handle) <span class="tok-kw">callconv</span>(.C) Status,</span>
<span class="line" id="L135"></span>
<span class="line" id="L136">    <span class="tok-comment">/// Returns the first protocol instance that matches the given protocol.</span></span>
<span class="line" id="L137">    locateProtocol: <span class="tok-kw">fn</span> (protocol: *<span class="tok-kw">align</span>(<span class="tok-number">8</span>) <span class="tok-kw">const</span> Guid, registration: ?*<span class="tok-kw">const</span> <span class="tok-type">anyopaque</span>, interface: *?*<span class="tok-type">anyopaque</span>) <span class="tok-kw">callconv</span>(.C) Status,</span>
<span class="line" id="L138"></span>
<span class="line" id="L139">    <span class="tok-comment">/// Installs one or more protocol interfaces into the boot services environment</span></span>
<span class="line" id="L140">    installMultipleProtocolInterfaces: <span class="tok-kw">fn</span> (handle: *Handle, ...) <span class="tok-kw">callconv</span>(.C) Status,</span>
<span class="line" id="L141"></span>
<span class="line" id="L142">    <span class="tok-comment">/// Removes one or more protocol interfaces into the boot services environment</span></span>
<span class="line" id="L143">    uninstallMultipleProtocolInterfaces: <span class="tok-kw">fn</span> (handle: *Handle, ...) <span class="tok-kw">callconv</span>(.C) Status,</span>
<span class="line" id="L144"></span>
<span class="line" id="L145">    <span class="tok-comment">/// Computes and returns a 32-bit CRC for a data buffer.</span></span>
<span class="line" id="L146">    calculateCrc32: <span class="tok-kw">fn</span> (data: [*]<span class="tok-kw">const</span> <span class="tok-type">u8</span>, data_size: <span class="tok-type">usize</span>, *<span class="tok-type">u32</span>) <span class="tok-kw">callconv</span>(.C) Status,</span>
<span class="line" id="L147"></span>
<span class="line" id="L148">    <span class="tok-comment">/// Copies the contents of one buffer to another buffer</span></span>
<span class="line" id="L149">    copyMem: <span class="tok-kw">fn</span> (dest: [*]<span class="tok-type">u8</span>, src: [*]<span class="tok-kw">const</span> <span class="tok-type">u8</span>, len: <span class="tok-type">usize</span>) <span class="tok-kw">callconv</span>(.C) <span class="tok-type">void</span>,</span>
<span class="line" id="L150"></span>
<span class="line" id="L151">    <span class="tok-comment">/// Fills a buffer with a specified value</span></span>
<span class="line" id="L152">    setMem: <span class="tok-kw">fn</span> (buffer: [*]<span class="tok-type">u8</span>, size: <span class="tok-type">usize</span>, value: <span class="tok-type">u8</span>) <span class="tok-kw">callconv</span>(.C) <span class="tok-type">void</span>,</span>
<span class="line" id="L153"></span>
<span class="line" id="L154">    <span class="tok-comment">/// Creates an event in a group.</span></span>
<span class="line" id="L155">    createEventEx: <span class="tok-kw">fn</span> (<span class="tok-type">type</span>: <span class="tok-type">u32</span>, notify_tpl: <span class="tok-type">usize</span>, notify_func: EfiEventNotify, notify_ctx: *<span class="tok-kw">const</span> <span class="tok-type">anyopaque</span>, event_group: *<span class="tok-kw">align</span>(<span class="tok-number">8</span>) <span class="tok-kw">const</span> Guid, event: *Event) <span class="tok-kw">callconv</span>(.C) Status,</span>
<span class="line" id="L156"></span>
<span class="line" id="L157">    <span class="tok-comment">/// Opens a protocol with a structure as the loaded image for a UEFI application</span></span>
<span class="line" id="L158">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">openProtocolSt</span>(self: *BootServices, <span class="tok-kw">comptime</span> protocol: <span class="tok-type">type</span>, handle: Handle) !*protocol {</span>
<span class="line" id="L159">        <span class="tok-kw">if</span> (!<span class="tok-builtin">@hasDecl</span>(protocol, <span class="tok-str">&quot;guid&quot;</span>))</span>
<span class="line" id="L160">            <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;Protocol is missing guid!&quot;</span>);</span>
<span class="line" id="L161"></span>
<span class="line" id="L162">        <span class="tok-kw">var</span> ptr: ?*protocol = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L163"></span>
<span class="line" id="L164">        <span class="tok-kw">try</span> self.openProtocol(</span>
<span class="line" id="L165">            handle,</span>
<span class="line" id="L166">            &amp;protocol.guid,</span>
<span class="line" id="L167">            <span class="tok-builtin">@ptrCast</span>(*?*<span class="tok-type">anyopaque</span>, &amp;ptr),</span>
<span class="line" id="L168">            <span class="tok-comment">// Invoking handle (loaded image)</span>
</span>
<span class="line" id="L169">            uefi.handle,</span>
<span class="line" id="L170">            <span class="tok-comment">// Control handle (null as not a driver)</span>
</span>
<span class="line" id="L171">            <span class="tok-null">null</span>,</span>
<span class="line" id="L172">            uefi.tables.OpenProtocolAttributes{ .by_handle_protocol = <span class="tok-null">true</span> },</span>
<span class="line" id="L173">        ).err();</span>
<span class="line" id="L174"></span>
<span class="line" id="L175">        <span class="tok-kw">return</span> ptr.?;</span>
<span class="line" id="L176">    }</span>
<span class="line" id="L177"></span>
<span class="line" id="L178">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> signature: <span class="tok-type">u64</span> = <span class="tok-number">0x56524553544f4f42</span>;</span>
<span class="line" id="L179"></span>
<span class="line" id="L180">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> event_timer: <span class="tok-type">u32</span> = <span class="tok-number">0x80000000</span>;</span>
<span class="line" id="L181">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> event_runtime: <span class="tok-type">u32</span> = <span class="tok-number">0x40000000</span>;</span>
<span class="line" id="L182">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> event_notify_wait: <span class="tok-type">u32</span> = <span class="tok-number">0x00000100</span>;</span>
<span class="line" id="L183">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> event_notify_signal: <span class="tok-type">u32</span> = <span class="tok-number">0x00000200</span>;</span>
<span class="line" id="L184">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> event_signal_exit_boot_services: <span class="tok-type">u32</span> = <span class="tok-number">0x00000201</span>;</span>
<span class="line" id="L185">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> event_signal_virtual_address_change: <span class="tok-type">u32</span> = <span class="tok-number">0x00000202</span>;</span>
<span class="line" id="L186"></span>
<span class="line" id="L187">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> tpl_application: <span class="tok-type">usize</span> = <span class="tok-number">4</span>;</span>
<span class="line" id="L188">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> tpl_callback: <span class="tok-type">usize</span> = <span class="tok-number">8</span>;</span>
<span class="line" id="L189">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> tpl_notify: <span class="tok-type">usize</span> = <span class="tok-number">16</span>;</span>
<span class="line" id="L190">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> tpl_high_level: <span class="tok-type">usize</span> = <span class="tok-number">31</span>;</span>
<span class="line" id="L191">};</span>
<span class="line" id="L192"></span>
<span class="line" id="L193"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> EfiEventNotify = <span class="tok-kw">fn</span> (event: Event, ctx: *<span class="tok-type">anyopaque</span>) <span class="tok-kw">callconv</span>(.C) <span class="tok-type">void</span>;</span>
<span class="line" id="L194"></span>
<span class="line" id="L195"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> TimerDelay = <span class="tok-kw">enum</span>(<span class="tok-type">u32</span>) {</span>
<span class="line" id="L196">    TimerCancel,</span>
<span class="line" id="L197">    TimerPeriodic,</span>
<span class="line" id="L198">    TimerRelative,</span>
<span class="line" id="L199">};</span>
<span class="line" id="L200"></span>
<span class="line" id="L201"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> MemoryType = <span class="tok-kw">enum</span>(<span class="tok-type">u32</span>) {</span>
<span class="line" id="L202">    ReservedMemoryType,</span>
<span class="line" id="L203">    LoaderCode,</span>
<span class="line" id="L204">    LoaderData,</span>
<span class="line" id="L205">    BootServicesCode,</span>
<span class="line" id="L206">    BootServicesData,</span>
<span class="line" id="L207">    RuntimeServicesCode,</span>
<span class="line" id="L208">    RuntimeServicesData,</span>
<span class="line" id="L209">    ConventionalMemory,</span>
<span class="line" id="L210">    UnusableMemory,</span>
<span class="line" id="L211">    ACPIReclaimMemory,</span>
<span class="line" id="L212">    ACPIMemoryNVS,</span>
<span class="line" id="L213">    MemoryMappedIO,</span>
<span class="line" id="L214">    MemoryMappedIOPortSpace,</span>
<span class="line" id="L215">    PalCode,</span>
<span class="line" id="L216">    PersistentMemory,</span>
<span class="line" id="L217">    MaxMemoryType,</span>
<span class="line" id="L218">    _,</span>
<span class="line" id="L219">};</span>
<span class="line" id="L220"></span>
<span class="line" id="L221"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> MemoryDescriptor = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L222">    <span class="tok-type">type</span>: MemoryType,</span>
<span class="line" id="L223">    padding: <span class="tok-type">u32</span>,</span>
<span class="line" id="L224">    physical_start: <span class="tok-type">u64</span>,</span>
<span class="line" id="L225">    virtual_start: <span class="tok-type">u64</span>,</span>
<span class="line" id="L226">    number_of_pages: <span class="tok-type">usize</span>,</span>
<span class="line" id="L227">    attribute: <span class="tok-kw">packed</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L228">        uc: <span class="tok-type">bool</span>,</span>
<span class="line" id="L229">        wc: <span class="tok-type">bool</span>,</span>
<span class="line" id="L230">        wt: <span class="tok-type">bool</span>,</span>
<span class="line" id="L231">        wb: <span class="tok-type">bool</span>,</span>
<span class="line" id="L232">        uce: <span class="tok-type">bool</span>,</span>
<span class="line" id="L233">        _pad1: <span class="tok-type">u3</span>,</span>
<span class="line" id="L234">        _pad2: <span class="tok-type">u4</span>,</span>
<span class="line" id="L235">        wp: <span class="tok-type">bool</span>,</span>
<span class="line" id="L236">        rp: <span class="tok-type">bool</span>,</span>
<span class="line" id="L237">        xp: <span class="tok-type">bool</span>,</span>
<span class="line" id="L238">        nv: <span class="tok-type">bool</span>,</span>
<span class="line" id="L239">        more_reliable: <span class="tok-type">bool</span>,</span>
<span class="line" id="L240">        ro: <span class="tok-type">bool</span>,</span>
<span class="line" id="L241">        sp: <span class="tok-type">bool</span>,</span>
<span class="line" id="L242">        cpu_crypto: <span class="tok-type">bool</span>,</span>
<span class="line" id="L243">        _pad3: <span class="tok-type">u4</span>,</span>
<span class="line" id="L244">        _pad4: <span class="tok-type">u32</span>,</span>
<span class="line" id="L245">        _pad5: <span class="tok-type">u7</span>,</span>
<span class="line" id="L246">        memory_runtime: <span class="tok-type">bool</span>,</span>
<span class="line" id="L247">    },</span>
<span class="line" id="L248">};</span>
<span class="line" id="L249"></span>
<span class="line" id="L250"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> LocateSearchType = <span class="tok-kw">enum</span>(<span class="tok-type">u32</span>) {</span>
<span class="line" id="L251">    AllHandles,</span>
<span class="line" id="L252">    ByRegisterNotify,</span>
<span class="line" id="L253">    ByProtocol,</span>
<span class="line" id="L254">};</span>
<span class="line" id="L255"></span>
<span class="line" id="L256"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> OpenProtocolAttributes = <span class="tok-kw">packed</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L257">    by_handle_protocol: <span class="tok-type">bool</span> = <span class="tok-null">false</span>,</span>
<span class="line" id="L258">    get_protocol: <span class="tok-type">bool</span> = <span class="tok-null">false</span>,</span>
<span class="line" id="L259">    test_protocol: <span class="tok-type">bool</span> = <span class="tok-null">false</span>,</span>
<span class="line" id="L260">    by_child_controller: <span class="tok-type">bool</span> = <span class="tok-null">false</span>,</span>
<span class="line" id="L261">    by_driver: <span class="tok-type">bool</span> = <span class="tok-null">false</span>,</span>
<span class="line" id="L262">    exclusive: <span class="tok-type">bool</span> = <span class="tok-null">false</span>,</span>
<span class="line" id="L263">    _pad: <span class="tok-type">u26</span> = <span class="tok-number">0</span>,</span>
<span class="line" id="L264">};</span>
<span class="line" id="L265"></span>
<span class="line" id="L266"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> ProtocolInformationEntry = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L267">    agent_handle: ?Handle,</span>
<span class="line" id="L268">    controller_handle: ?Handle,</span>
<span class="line" id="L269">    attributes: OpenProtocolAttributes,</span>
<span class="line" id="L270">    open_count: <span class="tok-type">u32</span>,</span>
<span class="line" id="L271">};</span>
<span class="line" id="L272"></span>
<span class="line" id="L273"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> EfiInterfaceType = <span class="tok-kw">enum</span>(<span class="tok-type">u32</span>) {</span>
<span class="line" id="L274">    EfiNativeInterface,</span>
<span class="line" id="L275">};</span>
<span class="line" id="L276"></span>
<span class="line" id="L277"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> AllocateType = <span class="tok-kw">enum</span>(<span class="tok-type">u32</span>) {</span>
<span class="line" id="L278">    AllocateAnyPages,</span>
<span class="line" id="L279">    AllocateMaxAddress,</span>
<span class="line" id="L280">    AllocateAddress,</span>
<span class="line" id="L281">};</span>
<span class="line" id="L282"></span>
</code></pre></body>
</html>