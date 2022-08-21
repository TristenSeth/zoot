<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">    <title>os/windows/ntdll.zig - source view</title>
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
<span class="line" id="L2"><span class="tok-kw">const</span> windows = std.os.windows;</span>
<span class="line" id="L3"></span>
<span class="line" id="L4"><span class="tok-kw">const</span> BOOL = windows.BOOL;</span>
<span class="line" id="L5"><span class="tok-kw">const</span> DWORD = windows.DWORD;</span>
<span class="line" id="L6"><span class="tok-kw">const</span> ULONG = windows.ULONG;</span>
<span class="line" id="L7"><span class="tok-kw">const</span> WINAPI = windows.WINAPI;</span>
<span class="line" id="L8"><span class="tok-kw">const</span> NTSTATUS = windows.NTSTATUS;</span>
<span class="line" id="L9"><span class="tok-kw">const</span> WORD = windows.WORD;</span>
<span class="line" id="L10"><span class="tok-kw">const</span> HANDLE = windows.HANDLE;</span>
<span class="line" id="L11"><span class="tok-kw">const</span> ACCESS_MASK = windows.ACCESS_MASK;</span>
<span class="line" id="L12"><span class="tok-kw">const</span> IO_APC_ROUTINE = windows.IO_APC_ROUTINE;</span>
<span class="line" id="L13"><span class="tok-kw">const</span> BOOLEAN = windows.BOOLEAN;</span>
<span class="line" id="L14"><span class="tok-kw">const</span> OBJECT_ATTRIBUTES = windows.OBJECT_ATTRIBUTES;</span>
<span class="line" id="L15"><span class="tok-kw">const</span> PVOID = windows.PVOID;</span>
<span class="line" id="L16"><span class="tok-kw">const</span> IO_STATUS_BLOCK = windows.IO_STATUS_BLOCK;</span>
<span class="line" id="L17"><span class="tok-kw">const</span> LARGE_INTEGER = windows.LARGE_INTEGER;</span>
<span class="line" id="L18"><span class="tok-kw">const</span> OBJECT_INFORMATION_CLASS = windows.OBJECT_INFORMATION_CLASS;</span>
<span class="line" id="L19"><span class="tok-kw">const</span> FILE_INFORMATION_CLASS = windows.FILE_INFORMATION_CLASS;</span>
<span class="line" id="L20"><span class="tok-kw">const</span> UNICODE_STRING = windows.UNICODE_STRING;</span>
<span class="line" id="L21"><span class="tok-kw">const</span> RTL_OSVERSIONINFOW = windows.RTL_OSVERSIONINFOW;</span>
<span class="line" id="L22"><span class="tok-kw">const</span> FILE_BASIC_INFORMATION = windows.FILE_BASIC_INFORMATION;</span>
<span class="line" id="L23"><span class="tok-kw">const</span> SIZE_T = windows.SIZE_T;</span>
<span class="line" id="L24"><span class="tok-kw">const</span> CURDIR = windows.CURDIR;</span>
<span class="line" id="L25"></span>
<span class="line" id="L26"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> THREADINFOCLASS = <span class="tok-kw">enum</span>(<span class="tok-type">c_int</span>) {</span>
<span class="line" id="L27">    ThreadBasicInformation,</span>
<span class="line" id="L28">    ThreadTimes,</span>
<span class="line" id="L29">    ThreadPriority,</span>
<span class="line" id="L30">    ThreadBasePriority,</span>
<span class="line" id="L31">    ThreadAffinityMask,</span>
<span class="line" id="L32">    ThreadImpersonationToken,</span>
<span class="line" id="L33">    ThreadDescriptorTableEntry,</span>
<span class="line" id="L34">    ThreadEnableAlignmentFaultFixup,</span>
<span class="line" id="L35">    ThreadEventPair_Reusable,</span>
<span class="line" id="L36">    ThreadQuerySetWin32StartAddress,</span>
<span class="line" id="L37">    ThreadZeroTlsCell,</span>
<span class="line" id="L38">    ThreadPerformanceCount,</span>
<span class="line" id="L39">    ThreadAmILastThread,</span>
<span class="line" id="L40">    ThreadIdealProcessor,</span>
<span class="line" id="L41">    ThreadPriorityBoost,</span>
<span class="line" id="L42">    ThreadSetTlsArrayAddress,</span>
<span class="line" id="L43">    ThreadIsIoPending,</span>
<span class="line" id="L44">    <span class="tok-comment">// Windows 2000+ from here</span>
</span>
<span class="line" id="L45">    ThreadHideFromDebugger,</span>
<span class="line" id="L46">    <span class="tok-comment">// Windows XP+ from here</span>
</span>
<span class="line" id="L47">    ThreadBreakOnTermination,</span>
<span class="line" id="L48">    ThreadSwitchLegacyState,</span>
<span class="line" id="L49">    ThreadIsTerminated,</span>
<span class="line" id="L50">    <span class="tok-comment">// Windows Vista+ from here</span>
</span>
<span class="line" id="L51">    ThreadLastSystemCall,</span>
<span class="line" id="L52">    ThreadIoPriority,</span>
<span class="line" id="L53">    ThreadCycleTime,</span>
<span class="line" id="L54">    ThreadPagePriority,</span>
<span class="line" id="L55">    ThreadActualBasePriority,</span>
<span class="line" id="L56">    ThreadTebInformation,</span>
<span class="line" id="L57">    ThreadCSwitchMon,</span>
<span class="line" id="L58">    <span class="tok-comment">// Windows 7+ from here</span>
</span>
<span class="line" id="L59">    ThreadCSwitchPmu,</span>
<span class="line" id="L60">    ThreadWow64Context,</span>
<span class="line" id="L61">    ThreadGroupInformation,</span>
<span class="line" id="L62">    ThreadUmsInformation,</span>
<span class="line" id="L63">    ThreadCounterProfiling,</span>
<span class="line" id="L64">    ThreadIdealProcessorEx,</span>
<span class="line" id="L65">    <span class="tok-comment">// Windows 8+ from here</span>
</span>
<span class="line" id="L66">    ThreadCpuAccountingInformation,</span>
<span class="line" id="L67">    <span class="tok-comment">// Windows 8.1+ from here</span>
</span>
<span class="line" id="L68">    ThreadSuspendCount,</span>
<span class="line" id="L69">    <span class="tok-comment">// Windows 10+ from here</span>
</span>
<span class="line" id="L70">    ThreadHeterogeneousCpuPolicy,</span>
<span class="line" id="L71">    ThreadContainerId,</span>
<span class="line" id="L72">    ThreadNameInformation,</span>
<span class="line" id="L73">    ThreadSelectedCpuSets,</span>
<span class="line" id="L74">    ThreadSystemThreadInformation,</span>
<span class="line" id="L75">    ThreadActualGroupAffinity,</span>
<span class="line" id="L76">};</span>
<span class="line" id="L77"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;ntdll&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">NtQueryInformationThread</span>(</span>
<span class="line" id="L78">    ThreadHandle: HANDLE,</span>
<span class="line" id="L79">    ThreadInformationClass: THREADINFOCLASS,</span>
<span class="line" id="L80">    ThreadInformation: *<span class="tok-type">anyopaque</span>,</span>
<span class="line" id="L81">    ThreadInformationLength: ULONG,</span>
<span class="line" id="L82">    ReturnLength: ?*ULONG,</span>
<span class="line" id="L83">) <span class="tok-kw">callconv</span>(WINAPI) NTSTATUS;</span>
<span class="line" id="L84"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;ntdll&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">NtSetInformationThread</span>(</span>
<span class="line" id="L85">    ThreadHandle: HANDLE,</span>
<span class="line" id="L86">    ThreadInformationClass: THREADINFOCLASS,</span>
<span class="line" id="L87">    ThreadInformation: *<span class="tok-kw">const</span> <span class="tok-type">anyopaque</span>,</span>
<span class="line" id="L88">    ThreadInformationLength: ULONG,</span>
<span class="line" id="L89">) <span class="tok-kw">callconv</span>(WINAPI) NTSTATUS;</span>
<span class="line" id="L90"></span>
<span class="line" id="L91"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;ntdll&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">RtlGetVersion</span>(</span>
<span class="line" id="L92">    lpVersionInformation: *RTL_OSVERSIONINFOW,</span>
<span class="line" id="L93">) <span class="tok-kw">callconv</span>(WINAPI) NTSTATUS;</span>
<span class="line" id="L94"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;ntdll&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">RtlCaptureStackBackTrace</span>(</span>
<span class="line" id="L95">    FramesToSkip: DWORD,</span>
<span class="line" id="L96">    FramesToCapture: DWORD,</span>
<span class="line" id="L97">    BackTrace: **<span class="tok-type">anyopaque</span>,</span>
<span class="line" id="L98">    BackTraceHash: ?*DWORD,</span>
<span class="line" id="L99">) <span class="tok-kw">callconv</span>(WINAPI) WORD;</span>
<span class="line" id="L100"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;ntdll&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">NtQueryInformationFile</span>(</span>
<span class="line" id="L101">    FileHandle: HANDLE,</span>
<span class="line" id="L102">    IoStatusBlock: *IO_STATUS_BLOCK,</span>
<span class="line" id="L103">    FileInformation: *<span class="tok-type">anyopaque</span>,</span>
<span class="line" id="L104">    Length: ULONG,</span>
<span class="line" id="L105">    FileInformationClass: FILE_INFORMATION_CLASS,</span>
<span class="line" id="L106">) <span class="tok-kw">callconv</span>(WINAPI) NTSTATUS;</span>
<span class="line" id="L107"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;ntdll&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">NtSetInformationFile</span>(</span>
<span class="line" id="L108">    FileHandle: HANDLE,</span>
<span class="line" id="L109">    IoStatusBlock: *IO_STATUS_BLOCK,</span>
<span class="line" id="L110">    FileInformation: PVOID,</span>
<span class="line" id="L111">    Length: ULONG,</span>
<span class="line" id="L112">    FileInformationClass: FILE_INFORMATION_CLASS,</span>
<span class="line" id="L113">) <span class="tok-kw">callconv</span>(WINAPI) NTSTATUS;</span>
<span class="line" id="L114"></span>
<span class="line" id="L115"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;ntdll&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">NtQueryAttributesFile</span>(</span>
<span class="line" id="L116">    ObjectAttributes: *OBJECT_ATTRIBUTES,</span>
<span class="line" id="L117">    FileAttributes: *FILE_BASIC_INFORMATION,</span>
<span class="line" id="L118">) <span class="tok-kw">callconv</span>(WINAPI) NTSTATUS;</span>
<span class="line" id="L119"></span>
<span class="line" id="L120"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;ntdll&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">NtCreateFile</span>(</span>
<span class="line" id="L121">    FileHandle: *HANDLE,</span>
<span class="line" id="L122">    DesiredAccess: ACCESS_MASK,</span>
<span class="line" id="L123">    ObjectAttributes: *OBJECT_ATTRIBUTES,</span>
<span class="line" id="L124">    IoStatusBlock: *IO_STATUS_BLOCK,</span>
<span class="line" id="L125">    AllocationSize: ?*LARGE_INTEGER,</span>
<span class="line" id="L126">    FileAttributes: ULONG,</span>
<span class="line" id="L127">    ShareAccess: ULONG,</span>
<span class="line" id="L128">    CreateDisposition: ULONG,</span>
<span class="line" id="L129">    CreateOptions: ULONG,</span>
<span class="line" id="L130">    EaBuffer: ?*<span class="tok-type">anyopaque</span>,</span>
<span class="line" id="L131">    EaLength: ULONG,</span>
<span class="line" id="L132">) <span class="tok-kw">callconv</span>(WINAPI) NTSTATUS;</span>
<span class="line" id="L133"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;ntdll&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">NtDeviceIoControlFile</span>(</span>
<span class="line" id="L134">    FileHandle: HANDLE,</span>
<span class="line" id="L135">    Event: ?HANDLE,</span>
<span class="line" id="L136">    ApcRoutine: ?IO_APC_ROUTINE,</span>
<span class="line" id="L137">    ApcContext: ?*<span class="tok-type">anyopaque</span>,</span>
<span class="line" id="L138">    IoStatusBlock: *IO_STATUS_BLOCK,</span>
<span class="line" id="L139">    IoControlCode: ULONG,</span>
<span class="line" id="L140">    InputBuffer: ?*<span class="tok-kw">const</span> <span class="tok-type">anyopaque</span>,</span>
<span class="line" id="L141">    InputBufferLength: ULONG,</span>
<span class="line" id="L142">    OutputBuffer: ?PVOID,</span>
<span class="line" id="L143">    OutputBufferLength: ULONG,</span>
<span class="line" id="L144">) <span class="tok-kw">callconv</span>(WINAPI) NTSTATUS;</span>
<span class="line" id="L145"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;ntdll&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">NtFsControlFile</span>(</span>
<span class="line" id="L146">    FileHandle: HANDLE,</span>
<span class="line" id="L147">    Event: ?HANDLE,</span>
<span class="line" id="L148">    ApcRoutine: ?IO_APC_ROUTINE,</span>
<span class="line" id="L149">    ApcContext: ?*<span class="tok-type">anyopaque</span>,</span>
<span class="line" id="L150">    IoStatusBlock: *IO_STATUS_BLOCK,</span>
<span class="line" id="L151">    FsControlCode: ULONG,</span>
<span class="line" id="L152">    InputBuffer: ?*<span class="tok-kw">const</span> <span class="tok-type">anyopaque</span>,</span>
<span class="line" id="L153">    InputBufferLength: ULONG,</span>
<span class="line" id="L154">    OutputBuffer: ?PVOID,</span>
<span class="line" id="L155">    OutputBufferLength: ULONG,</span>
<span class="line" id="L156">) <span class="tok-kw">callconv</span>(WINAPI) NTSTATUS;</span>
<span class="line" id="L157"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;ntdll&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">NtClose</span>(Handle: HANDLE) <span class="tok-kw">callconv</span>(WINAPI) NTSTATUS;</span>
<span class="line" id="L158"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;ntdll&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">RtlDosPathNameToNtPathName_U</span>(</span>
<span class="line" id="L159">    DosPathName: [*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u16</span>,</span>
<span class="line" id="L160">    NtPathName: *UNICODE_STRING,</span>
<span class="line" id="L161">    NtFileNamePart: ?*?[*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u16</span>,</span>
<span class="line" id="L162">    DirectoryInfo: ?*CURDIR,</span>
<span class="line" id="L163">) <span class="tok-kw">callconv</span>(WINAPI) BOOL;</span>
<span class="line" id="L164"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;ntdll&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">RtlFreeUnicodeString</span>(UnicodeString: *UNICODE_STRING) <span class="tok-kw">callconv</span>(WINAPI) <span class="tok-type">void</span>;</span>
<span class="line" id="L165"></span>
<span class="line" id="L166"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;ntdll&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">NtQueryDirectoryFile</span>(</span>
<span class="line" id="L167">    FileHandle: HANDLE,</span>
<span class="line" id="L168">    Event: ?HANDLE,</span>
<span class="line" id="L169">    ApcRoutine: ?IO_APC_ROUTINE,</span>
<span class="line" id="L170">    ApcContext: ?*<span class="tok-type">anyopaque</span>,</span>
<span class="line" id="L171">    IoStatusBlock: *IO_STATUS_BLOCK,</span>
<span class="line" id="L172">    FileInformation: *<span class="tok-type">anyopaque</span>,</span>
<span class="line" id="L173">    Length: ULONG,</span>
<span class="line" id="L174">    FileInformationClass: FILE_INFORMATION_CLASS,</span>
<span class="line" id="L175">    ReturnSingleEntry: BOOLEAN,</span>
<span class="line" id="L176">    FileName: ?*UNICODE_STRING,</span>
<span class="line" id="L177">    RestartScan: BOOLEAN,</span>
<span class="line" id="L178">) <span class="tok-kw">callconv</span>(WINAPI) NTSTATUS;</span>
<span class="line" id="L179"></span>
<span class="line" id="L180"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;ntdll&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">NtCreateKeyedEvent</span>(</span>
<span class="line" id="L181">    KeyedEventHandle: *HANDLE,</span>
<span class="line" id="L182">    DesiredAccess: ACCESS_MASK,</span>
<span class="line" id="L183">    ObjectAttributes: ?PVOID,</span>
<span class="line" id="L184">    Flags: ULONG,</span>
<span class="line" id="L185">) <span class="tok-kw">callconv</span>(WINAPI) NTSTATUS;</span>
<span class="line" id="L186"></span>
<span class="line" id="L187"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;ntdll&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">NtReleaseKeyedEvent</span>(</span>
<span class="line" id="L188">    EventHandle: ?HANDLE,</span>
<span class="line" id="L189">    Key: ?*<span class="tok-kw">const</span> <span class="tok-type">anyopaque</span>,</span>
<span class="line" id="L190">    Alertable: BOOLEAN,</span>
<span class="line" id="L191">    Timeout: ?*<span class="tok-kw">const</span> LARGE_INTEGER,</span>
<span class="line" id="L192">) <span class="tok-kw">callconv</span>(WINAPI) NTSTATUS;</span>
<span class="line" id="L193"></span>
<span class="line" id="L194"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;ntdll&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">NtWaitForKeyedEvent</span>(</span>
<span class="line" id="L195">    EventHandle: ?HANDLE,</span>
<span class="line" id="L196">    Key: ?*<span class="tok-kw">const</span> <span class="tok-type">anyopaque</span>,</span>
<span class="line" id="L197">    Alertable: BOOLEAN,</span>
<span class="line" id="L198">    Timeout: ?*<span class="tok-kw">const</span> LARGE_INTEGER,</span>
<span class="line" id="L199">) <span class="tok-kw">callconv</span>(WINAPI) NTSTATUS;</span>
<span class="line" id="L200"></span>
<span class="line" id="L201"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;ntdll&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">RtlSetCurrentDirectory_U</span>(PathName: *UNICODE_STRING) <span class="tok-kw">callconv</span>(WINAPI) NTSTATUS;</span>
<span class="line" id="L202"></span>
<span class="line" id="L203"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;ntdll&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">NtQueryObject</span>(</span>
<span class="line" id="L204">    Handle: HANDLE,</span>
<span class="line" id="L205">    ObjectInformationClass: OBJECT_INFORMATION_CLASS,</span>
<span class="line" id="L206">    ObjectInformation: PVOID,</span>
<span class="line" id="L207">    ObjectInformationLength: ULONG,</span>
<span class="line" id="L208">    ReturnLength: ?*ULONG,</span>
<span class="line" id="L209">) <span class="tok-kw">callconv</span>(WINAPI) NTSTATUS;</span>
<span class="line" id="L210"></span>
<span class="line" id="L211"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;ntdll&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">RtlWakeAddressAll</span>(</span>
<span class="line" id="L212">    Address: ?*<span class="tok-kw">const</span> <span class="tok-type">anyopaque</span>,</span>
<span class="line" id="L213">) <span class="tok-kw">callconv</span>(WINAPI) <span class="tok-type">void</span>;</span>
<span class="line" id="L214"></span>
<span class="line" id="L215"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;ntdll&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">RtlWakeAddressSingle</span>(</span>
<span class="line" id="L216">    Address: ?*<span class="tok-kw">const</span> <span class="tok-type">anyopaque</span>,</span>
<span class="line" id="L217">) <span class="tok-kw">callconv</span>(WINAPI) <span class="tok-type">void</span>;</span>
<span class="line" id="L218"></span>
<span class="line" id="L219"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;ntdll&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">RtlWaitOnAddress</span>(</span>
<span class="line" id="L220">    Address: ?*<span class="tok-kw">const</span> <span class="tok-type">anyopaque</span>,</span>
<span class="line" id="L221">    CompareAddress: ?*<span class="tok-kw">const</span> <span class="tok-type">anyopaque</span>,</span>
<span class="line" id="L222">    AddressSize: SIZE_T,</span>
<span class="line" id="L223">    Timeout: ?*<span class="tok-kw">const</span> LARGE_INTEGER,</span>
<span class="line" id="L224">) <span class="tok-kw">callconv</span>(WINAPI) NTSTATUS;</span>
<span class="line" id="L225"></span>
<span class="line" id="L226"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;ntdll&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">RtlEqualUnicodeString</span>(</span>
<span class="line" id="L227">    String1: *<span class="tok-kw">const</span> UNICODE_STRING,</span>
<span class="line" id="L228">    String2: *<span class="tok-kw">const</span> UNICODE_STRING,</span>
<span class="line" id="L229">    CaseInSensitive: BOOLEAN,</span>
<span class="line" id="L230">) <span class="tok-kw">callconv</span>(WINAPI) BOOLEAN;</span>
<span class="line" id="L231"></span>
<span class="line" id="L232"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;ntdll&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">RtlUpcaseUnicodeChar</span>(</span>
<span class="line" id="L233">    SourceCharacter: <span class="tok-type">u16</span>,</span>
<span class="line" id="L234">) <span class="tok-kw">callconv</span>(WINAPI) <span class="tok-type">u16</span>;</span>
<span class="line" id="L235"></span>
<span class="line" id="L236"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;ntdll&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">NtLockFile</span>(</span>
<span class="line" id="L237">    FileHandle: HANDLE,</span>
<span class="line" id="L238">    Event: ?HANDLE,</span>
<span class="line" id="L239">    ApcRoutine: ?*IO_APC_ROUTINE,</span>
<span class="line" id="L240">    ApcContext: ?*<span class="tok-type">anyopaque</span>,</span>
<span class="line" id="L241">    IoStatusBlock: *IO_STATUS_BLOCK,</span>
<span class="line" id="L242">    ByteOffset: *<span class="tok-kw">const</span> LARGE_INTEGER,</span>
<span class="line" id="L243">    Length: *<span class="tok-kw">const</span> LARGE_INTEGER,</span>
<span class="line" id="L244">    Key: ?*ULONG,</span>
<span class="line" id="L245">    FailImmediately: BOOLEAN,</span>
<span class="line" id="L246">    ExclusiveLock: BOOLEAN,</span>
<span class="line" id="L247">) <span class="tok-kw">callconv</span>(WINAPI) NTSTATUS;</span>
<span class="line" id="L248"></span>
<span class="line" id="L249"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;ntdll&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">NtUnlockFile</span>(</span>
<span class="line" id="L250">    FileHandle: HANDLE,</span>
<span class="line" id="L251">    IoStatusBlock: *IO_STATUS_BLOCK,</span>
<span class="line" id="L252">    ByteOffset: *<span class="tok-kw">const</span> LARGE_INTEGER,</span>
<span class="line" id="L253">    Length: *<span class="tok-kw">const</span> LARGE_INTEGER,</span>
<span class="line" id="L254">    Key: ?*ULONG,</span>
<span class="line" id="L255">) <span class="tok-kw">callconv</span>(WINAPI) NTSTATUS;</span>
<span class="line" id="L256"></span>
</code></pre></body>
</html>