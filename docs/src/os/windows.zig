<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">    <title>os/windows.zig - source view</title>
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
<pre><code><span class="line" id="L1"><span class="tok-comment">//! This file contains thin wrappers around Windows-specific APIs, with these</span></span>
<span class="line" id="L2"><span class="tok-comment">//! specific goals in mind:</span></span>
<span class="line" id="L3"><span class="tok-comment">//! * Convert &quot;errno&quot;-style error codes into Zig errors.</span></span>
<span class="line" id="L4"><span class="tok-comment">//! * When null-terminated or UTF16LE byte buffers are required, provide APIs which accept</span></span>
<span class="line" id="L5"><span class="tok-comment">//!   slices as well as APIs which accept null-terminated UTF16LE byte buffers.</span></span>
<span class="line" id="L6"></span>
<span class="line" id="L7"><span class="tok-kw">const</span> builtin = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;builtin&quot;</span>);</span>
<span class="line" id="L8"><span class="tok-kw">const</span> std = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;../std.zig&quot;</span>);</span>
<span class="line" id="L9"><span class="tok-kw">const</span> mem = std.mem;</span>
<span class="line" id="L10"><span class="tok-kw">const</span> assert = std.debug.assert;</span>
<span class="line" id="L11"><span class="tok-kw">const</span> math = std.math;</span>
<span class="line" id="L12"><span class="tok-kw">const</span> maxInt = std.math.maxInt;</span>
<span class="line" id="L13"><span class="tok-kw">const</span> native_arch = builtin.cpu.arch;</span>
<span class="line" id="L14"></span>
<span class="line" id="L15"><span class="tok-kw">test</span> {</span>
<span class="line" id="L16">    <span class="tok-kw">if</span> (builtin.os.tag == .windows) {</span>
<span class="line" id="L17">        _ = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;windows/test.zig&quot;</span>);</span>
<span class="line" id="L18">    }</span>
<span class="line" id="L19">}</span>
<span class="line" id="L20"></span>
<span class="line" id="L21"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> advapi32 = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;windows/advapi32.zig&quot;</span>);</span>
<span class="line" id="L22"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> kernel32 = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;windows/kernel32.zig&quot;</span>);</span>
<span class="line" id="L23"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> ntdll = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;windows/ntdll.zig&quot;</span>);</span>
<span class="line" id="L24"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> ole32 = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;windows/ole32.zig&quot;</span>);</span>
<span class="line" id="L25"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> psapi = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;windows/psapi.zig&quot;</span>);</span>
<span class="line" id="L26"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> shell32 = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;windows/shell32.zig&quot;</span>);</span>
<span class="line" id="L27"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> user32 = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;windows/user32.zig&quot;</span>);</span>
<span class="line" id="L28"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> ws2_32 = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;windows/ws2_32.zig&quot;</span>);</span>
<span class="line" id="L29"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> gdi32 = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;windows/gdi32.zig&quot;</span>);</span>
<span class="line" id="L30"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> winmm = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;windows/winmm.zig&quot;</span>);</span>
<span class="line" id="L31"></span>
<span class="line" id="L32"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> self_process_handle = <span class="tok-builtin">@intToPtr</span>(HANDLE, maxInt(<span class="tok-type">usize</span>));</span>
<span class="line" id="L33"></span>
<span class="line" id="L34"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> OpenError = <span class="tok-kw">error</span>{</span>
<span class="line" id="L35">    IsDir,</span>
<span class="line" id="L36">    NotDir,</span>
<span class="line" id="L37">    FileNotFound,</span>
<span class="line" id="L38">    NoDevice,</span>
<span class="line" id="L39">    AccessDenied,</span>
<span class="line" id="L40">    PipeBusy,</span>
<span class="line" id="L41">    PathAlreadyExists,</span>
<span class="line" id="L42">    Unexpected,</span>
<span class="line" id="L43">    NameTooLong,</span>
<span class="line" id="L44">    WouldBlock,</span>
<span class="line" id="L45">};</span>
<span class="line" id="L46"></span>
<span class="line" id="L47"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> OpenFileOptions = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L48">    access_mask: ACCESS_MASK,</span>
<span class="line" id="L49">    dir: ?HANDLE = <span class="tok-null">null</span>,</span>
<span class="line" id="L50">    sa: ?*SECURITY_ATTRIBUTES = <span class="tok-null">null</span>,</span>
<span class="line" id="L51">    share_access: ULONG = FILE_SHARE_WRITE | FILE_SHARE_READ | FILE_SHARE_DELETE,</span>
<span class="line" id="L52">    creation: ULONG,</span>
<span class="line" id="L53">    io_mode: std.io.ModeOverride,</span>
<span class="line" id="L54">    <span class="tok-comment">/// If true, tries to open path as a directory.</span></span>
<span class="line" id="L55">    <span class="tok-comment">/// Defaults to false.</span></span>
<span class="line" id="L56">    filter: Filter = .file_only,</span>
<span class="line" id="L57">    <span class="tok-comment">/// If false, tries to open path as a reparse point without dereferencing it.</span></span>
<span class="line" id="L58">    <span class="tok-comment">/// Defaults to true.</span></span>
<span class="line" id="L59">    follow_symlinks: <span class="tok-type">bool</span> = <span class="tok-null">true</span>,</span>
<span class="line" id="L60"></span>
<span class="line" id="L61">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> Filter = <span class="tok-kw">enum</span> {</span>
<span class="line" id="L62">        <span class="tok-comment">/// Causes `OpenFile` to return `error.IsDir` if the opened handle would be a directory.</span></span>
<span class="line" id="L63">        file_only,</span>
<span class="line" id="L64">        <span class="tok-comment">/// Causes `OpenFile` to return `error.NotDir` if the opened handle would be a file.</span></span>
<span class="line" id="L65">        dir_only,</span>
<span class="line" id="L66">        <span class="tok-comment">/// `OpenFile` does not discriminate between opening files and directories.</span></span>
<span class="line" id="L67">        any,</span>
<span class="line" id="L68">    };</span>
<span class="line" id="L69">};</span>
<span class="line" id="L70"></span>
<span class="line" id="L71"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">OpenFile</span>(sub_path_w: []<span class="tok-kw">const</span> <span class="tok-type">u16</span>, options: OpenFileOptions) OpenError!HANDLE {</span>
<span class="line" id="L72">    <span class="tok-kw">if</span> (mem.eql(<span class="tok-type">u16</span>, sub_path_w, &amp;[_]<span class="tok-type">u16</span>{<span class="tok-str">'.'</span>}) <span class="tok-kw">and</span> options.filter == .file_only) {</span>
<span class="line" id="L73">        <span class="tok-kw">return</span> <span class="tok-kw">error</span>.IsDir;</span>
<span class="line" id="L74">    }</span>
<span class="line" id="L75">    <span class="tok-kw">if</span> (mem.eql(<span class="tok-type">u16</span>, sub_path_w, &amp;[_]<span class="tok-type">u16</span>{ <span class="tok-str">'.'</span>, <span class="tok-str">'.'</span> }) <span class="tok-kw">and</span> options.filter == .file_only) {</span>
<span class="line" id="L76">        <span class="tok-kw">return</span> <span class="tok-kw">error</span>.IsDir;</span>
<span class="line" id="L77">    }</span>
<span class="line" id="L78"></span>
<span class="line" id="L79">    <span class="tok-kw">var</span> result: HANDLE = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L80"></span>
<span class="line" id="L81">    <span class="tok-kw">const</span> path_len_bytes = math.cast(<span class="tok-type">u16</span>, sub_path_w.len * <span class="tok-number">2</span>) <span class="tok-kw">orelse</span> <span class="tok-kw">return</span> <span class="tok-kw">error</span>.NameTooLong;</span>
<span class="line" id="L82">    <span class="tok-kw">var</span> nt_name = UNICODE_STRING{</span>
<span class="line" id="L83">        .Length = path_len_bytes,</span>
<span class="line" id="L84">        .MaximumLength = path_len_bytes,</span>
<span class="line" id="L85">        .Buffer = <span class="tok-builtin">@intToPtr</span>([*]<span class="tok-type">u16</span>, <span class="tok-builtin">@ptrToInt</span>(sub_path_w.ptr)),</span>
<span class="line" id="L86">    };</span>
<span class="line" id="L87">    <span class="tok-kw">var</span> attr = OBJECT_ATTRIBUTES{</span>
<span class="line" id="L88">        .Length = <span class="tok-builtin">@sizeOf</span>(OBJECT_ATTRIBUTES),</span>
<span class="line" id="L89">        .RootDirectory = <span class="tok-kw">if</span> (std.fs.path.isAbsoluteWindowsWTF16(sub_path_w)) <span class="tok-null">null</span> <span class="tok-kw">else</span> options.dir,</span>
<span class="line" id="L90">        .Attributes = <span class="tok-number">0</span>, <span class="tok-comment">// Note we do not use OBJ_CASE_INSENSITIVE here.</span>
</span>
<span class="line" id="L91">        .ObjectName = &amp;nt_name,</span>
<span class="line" id="L92">        .SecurityDescriptor = <span class="tok-kw">if</span> (options.sa) |ptr| ptr.lpSecurityDescriptor <span class="tok-kw">else</span> <span class="tok-null">null</span>,</span>
<span class="line" id="L93">        .SecurityQualityOfService = <span class="tok-null">null</span>,</span>
<span class="line" id="L94">    };</span>
<span class="line" id="L95">    <span class="tok-kw">var</span> io: IO_STATUS_BLOCK = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L96">    <span class="tok-kw">const</span> blocking_flag: ULONG = <span class="tok-kw">if</span> (options.io_mode == .blocking) FILE_SYNCHRONOUS_IO_NONALERT <span class="tok-kw">else</span> <span class="tok-number">0</span>;</span>
<span class="line" id="L97">    <span class="tok-kw">const</span> file_or_dir_flag: ULONG = <span class="tok-kw">switch</span> (options.filter) {</span>
<span class="line" id="L98">        .file_only =&gt; FILE_NON_DIRECTORY_FILE,</span>
<span class="line" id="L99">        .dir_only =&gt; FILE_DIRECTORY_FILE,</span>
<span class="line" id="L100">        .any =&gt; <span class="tok-number">0</span>,</span>
<span class="line" id="L101">    };</span>
<span class="line" id="L102">    <span class="tok-comment">// If we're not following symlinks, we need to ensure we don't pass in any synchronization flags such as FILE_SYNCHRONOUS_IO_NONALERT.</span>
</span>
<span class="line" id="L103">    <span class="tok-kw">const</span> flags: ULONG = <span class="tok-kw">if</span> (options.follow_symlinks) file_or_dir_flag | blocking_flag <span class="tok-kw">else</span> file_or_dir_flag | FILE_OPEN_REPARSE_POINT;</span>
<span class="line" id="L104"></span>
<span class="line" id="L105">    <span class="tok-kw">const</span> rc = ntdll.NtCreateFile(</span>
<span class="line" id="L106">        &amp;result,</span>
<span class="line" id="L107">        options.access_mask,</span>
<span class="line" id="L108">        &amp;attr,</span>
<span class="line" id="L109">        &amp;io,</span>
<span class="line" id="L110">        <span class="tok-null">null</span>,</span>
<span class="line" id="L111">        FILE_ATTRIBUTE_NORMAL,</span>
<span class="line" id="L112">        options.share_access,</span>
<span class="line" id="L113">        options.creation,</span>
<span class="line" id="L114">        flags,</span>
<span class="line" id="L115">        <span class="tok-null">null</span>,</span>
<span class="line" id="L116">        <span class="tok-number">0</span>,</span>
<span class="line" id="L117">    );</span>
<span class="line" id="L118">    <span class="tok-kw">switch</span> (rc) {</span>
<span class="line" id="L119">        .SUCCESS =&gt; {</span>
<span class="line" id="L120">            <span class="tok-kw">if</span> (std.io.is_async <span class="tok-kw">and</span> options.io_mode == .evented) {</span>
<span class="line" id="L121">                _ = CreateIoCompletionPort(result, std.event.Loop.instance.?.os_data.io_port, <span class="tok-null">undefined</span>, <span class="tok-null">undefined</span>) <span class="tok-kw">catch</span> <span class="tok-null">undefined</span>;</span>
<span class="line" id="L122">            }</span>
<span class="line" id="L123">            <span class="tok-kw">return</span> result;</span>
<span class="line" id="L124">        },</span>
<span class="line" id="L125">        .OBJECT_NAME_INVALID =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L126">        .OBJECT_NAME_NOT_FOUND =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.FileNotFound,</span>
<span class="line" id="L127">        .OBJECT_PATH_NOT_FOUND =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.FileNotFound,</span>
<span class="line" id="L128">        .NO_MEDIA_IN_DEVICE =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.NoDevice,</span>
<span class="line" id="L129">        .INVALID_PARAMETER =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L130">        .SHARING_VIOLATION =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.AccessDenied,</span>
<span class="line" id="L131">        .ACCESS_DENIED =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.AccessDenied,</span>
<span class="line" id="L132">        .PIPE_BUSY =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.PipeBusy,</span>
<span class="line" id="L133">        .OBJECT_PATH_SYNTAX_BAD =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L134">        .OBJECT_NAME_COLLISION =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.PathAlreadyExists,</span>
<span class="line" id="L135">        .FILE_IS_A_DIRECTORY =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.IsDir,</span>
<span class="line" id="L136">        .NOT_A_DIRECTORY =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.NotDir,</span>
<span class="line" id="L137">        <span class="tok-kw">else</span> =&gt; <span class="tok-kw">return</span> unexpectedStatus(rc),</span>
<span class="line" id="L138">    }</span>
<span class="line" id="L139">}</span>
<span class="line" id="L140"></span>
<span class="line" id="L141"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> CreatePipeError = <span class="tok-kw">error</span>{Unexpected};</span>
<span class="line" id="L142"></span>
<span class="line" id="L143"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">CreatePipe</span>(rd: *HANDLE, wr: *HANDLE, sattr: *<span class="tok-kw">const</span> SECURITY_ATTRIBUTES) CreatePipeError!<span class="tok-type">void</span> {</span>
<span class="line" id="L144">    <span class="tok-kw">if</span> (kernel32.CreatePipe(rd, wr, sattr, <span class="tok-number">0</span>) == <span class="tok-number">0</span>) {</span>
<span class="line" id="L145">        <span class="tok-kw">switch</span> (kernel32.GetLastError()) {</span>
<span class="line" id="L146">            <span class="tok-kw">else</span> =&gt; |err| <span class="tok-kw">return</span> unexpectedError(err),</span>
<span class="line" id="L147">        }</span>
<span class="line" id="L148">    }</span>
<span class="line" id="L149">}</span>
<span class="line" id="L150"></span>
<span class="line" id="L151"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">CreateEventEx</span>(attributes: ?*SECURITY_ATTRIBUTES, name: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, flags: DWORD, desired_access: DWORD) !HANDLE {</span>
<span class="line" id="L152">    <span class="tok-kw">const</span> nameW = <span class="tok-kw">try</span> sliceToPrefixedFileW(name);</span>
<span class="line" id="L153">    <span class="tok-kw">return</span> CreateEventExW(attributes, nameW.span().ptr, flags, desired_access);</span>
<span class="line" id="L154">}</span>
<span class="line" id="L155"></span>
<span class="line" id="L156"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">CreateEventExW</span>(attributes: ?*SECURITY_ATTRIBUTES, nameW: [*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u16</span>, flags: DWORD, desired_access: DWORD) !HANDLE {</span>
<span class="line" id="L157">    <span class="tok-kw">const</span> handle = kernel32.CreateEventExW(attributes, nameW, flags, desired_access);</span>
<span class="line" id="L158">    <span class="tok-kw">if</span> (handle) |h| {</span>
<span class="line" id="L159">        <span class="tok-kw">return</span> h;</span>
<span class="line" id="L160">    } <span class="tok-kw">else</span> {</span>
<span class="line" id="L161">        <span class="tok-kw">switch</span> (kernel32.GetLastError()) {</span>
<span class="line" id="L162">            <span class="tok-kw">else</span> =&gt; |err| <span class="tok-kw">return</span> unexpectedError(err),</span>
<span class="line" id="L163">        }</span>
<span class="line" id="L164">    }</span>
<span class="line" id="L165">}</span>
<span class="line" id="L166"></span>
<span class="line" id="L167"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> DeviceIoControlError = <span class="tok-kw">error</span>{ AccessDenied, Unexpected };</span>
<span class="line" id="L168"></span>
<span class="line" id="L169"><span class="tok-comment">/// A Zig wrapper around `NtDeviceIoControlFile` and `NtFsControlFile` syscalls.</span></span>
<span class="line" id="L170"><span class="tok-comment">/// It implements similar behavior to `DeviceIoControl` and is meant to serve</span></span>
<span class="line" id="L171"><span class="tok-comment">/// as a direct substitute for that call.</span></span>
<span class="line" id="L172"><span class="tok-comment">/// TODO work out if we need to expose other arguments to the underlying syscalls.</span></span>
<span class="line" id="L173"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">DeviceIoControl</span>(</span>
<span class="line" id="L174">    h: HANDLE,</span>
<span class="line" id="L175">    ioControlCode: ULONG,</span>
<span class="line" id="L176">    in: ?[]<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L177">    out: ?[]<span class="tok-type">u8</span>,</span>
<span class="line" id="L178">) DeviceIoControlError!<span class="tok-type">void</span> {</span>
<span class="line" id="L179">    <span class="tok-comment">// Logic from: https://doxygen.reactos.org/d3/d74/deviceio_8c.html</span>
</span>
<span class="line" id="L180">    <span class="tok-kw">const</span> is_fsctl = (ioControlCode &gt;&gt; <span class="tok-number">16</span>) == FILE_DEVICE_FILE_SYSTEM;</span>
<span class="line" id="L181"></span>
<span class="line" id="L182">    <span class="tok-kw">var</span> io: IO_STATUS_BLOCK = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L183">    <span class="tok-kw">const</span> in_ptr = <span class="tok-kw">if</span> (in) |i| i.ptr <span class="tok-kw">else</span> <span class="tok-null">null</span>;</span>
<span class="line" id="L184">    <span class="tok-kw">const</span> in_len = <span class="tok-kw">if</span> (in) |i| <span class="tok-builtin">@intCast</span>(ULONG, i.len) <span class="tok-kw">else</span> <span class="tok-number">0</span>;</span>
<span class="line" id="L185">    <span class="tok-kw">const</span> out_ptr = <span class="tok-kw">if</span> (out) |o| o.ptr <span class="tok-kw">else</span> <span class="tok-null">null</span>;</span>
<span class="line" id="L186">    <span class="tok-kw">const</span> out_len = <span class="tok-kw">if</span> (out) |o| <span class="tok-builtin">@intCast</span>(ULONG, o.len) <span class="tok-kw">else</span> <span class="tok-number">0</span>;</span>
<span class="line" id="L187"></span>
<span class="line" id="L188">    <span class="tok-kw">const</span> rc = blk: {</span>
<span class="line" id="L189">        <span class="tok-kw">if</span> (is_fsctl) {</span>
<span class="line" id="L190">            <span class="tok-kw">break</span> :blk ntdll.NtFsControlFile(</span>
<span class="line" id="L191">                h,</span>
<span class="line" id="L192">                <span class="tok-null">null</span>,</span>
<span class="line" id="L193">                <span class="tok-null">null</span>,</span>
<span class="line" id="L194">                <span class="tok-null">null</span>,</span>
<span class="line" id="L195">                &amp;io,</span>
<span class="line" id="L196">                ioControlCode,</span>
<span class="line" id="L197">                in_ptr,</span>
<span class="line" id="L198">                in_len,</span>
<span class="line" id="L199">                out_ptr,</span>
<span class="line" id="L200">                out_len,</span>
<span class="line" id="L201">            );</span>
<span class="line" id="L202">        } <span class="tok-kw">else</span> {</span>
<span class="line" id="L203">            <span class="tok-kw">break</span> :blk ntdll.NtDeviceIoControlFile(</span>
<span class="line" id="L204">                h,</span>
<span class="line" id="L205">                <span class="tok-null">null</span>,</span>
<span class="line" id="L206">                <span class="tok-null">null</span>,</span>
<span class="line" id="L207">                <span class="tok-null">null</span>,</span>
<span class="line" id="L208">                &amp;io,</span>
<span class="line" id="L209">                ioControlCode,</span>
<span class="line" id="L210">                in_ptr,</span>
<span class="line" id="L211">                in_len,</span>
<span class="line" id="L212">                out_ptr,</span>
<span class="line" id="L213">                out_len,</span>
<span class="line" id="L214">            );</span>
<span class="line" id="L215">        }</span>
<span class="line" id="L216">    };</span>
<span class="line" id="L217">    <span class="tok-kw">switch</span> (rc) {</span>
<span class="line" id="L218">        .SUCCESS =&gt; {},</span>
<span class="line" id="L219">        .PRIVILEGE_NOT_HELD =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.AccessDenied,</span>
<span class="line" id="L220">        .ACCESS_DENIED =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.AccessDenied,</span>
<span class="line" id="L221">        .INVALID_PARAMETER =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L222">        <span class="tok-kw">else</span> =&gt; <span class="tok-kw">return</span> unexpectedStatus(rc),</span>
<span class="line" id="L223">    }</span>
<span class="line" id="L224">}</span>
<span class="line" id="L225"></span>
<span class="line" id="L226"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">GetOverlappedResult</span>(h: HANDLE, overlapped: *OVERLAPPED, wait: <span class="tok-type">bool</span>) !DWORD {</span>
<span class="line" id="L227">    <span class="tok-kw">var</span> bytes: DWORD = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L228">    <span class="tok-kw">if</span> (kernel32.GetOverlappedResult(h, overlapped, &amp;bytes, <span class="tok-builtin">@boolToInt</span>(wait)) == <span class="tok-number">0</span>) {</span>
<span class="line" id="L229">        <span class="tok-kw">switch</span> (kernel32.GetLastError()) {</span>
<span class="line" id="L230">            .IO_INCOMPLETE =&gt; <span class="tok-kw">if</span> (!wait) <span class="tok-kw">return</span> <span class="tok-kw">error</span>.WouldBlock <span class="tok-kw">else</span> <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L231">            <span class="tok-kw">else</span> =&gt; |err| <span class="tok-kw">return</span> unexpectedError(err),</span>
<span class="line" id="L232">        }</span>
<span class="line" id="L233">    }</span>
<span class="line" id="L234">    <span class="tok-kw">return</span> bytes;</span>
<span class="line" id="L235">}</span>
<span class="line" id="L236"></span>
<span class="line" id="L237"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SetHandleInformationError = <span class="tok-kw">error</span>{Unexpected};</span>
<span class="line" id="L238"></span>
<span class="line" id="L239"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">SetHandleInformation</span>(h: HANDLE, mask: DWORD, flags: DWORD) SetHandleInformationError!<span class="tok-type">void</span> {</span>
<span class="line" id="L240">    <span class="tok-kw">if</span> (kernel32.SetHandleInformation(h, mask, flags) == <span class="tok-number">0</span>) {</span>
<span class="line" id="L241">        <span class="tok-kw">switch</span> (kernel32.GetLastError()) {</span>
<span class="line" id="L242">            <span class="tok-kw">else</span> =&gt; |err| <span class="tok-kw">return</span> unexpectedError(err),</span>
<span class="line" id="L243">        }</span>
<span class="line" id="L244">    }</span>
<span class="line" id="L245">}</span>
<span class="line" id="L246"></span>
<span class="line" id="L247"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> RtlGenRandomError = <span class="tok-kw">error</span>{Unexpected};</span>
<span class="line" id="L248"></span>
<span class="line" id="L249"><span class="tok-comment">/// Call RtlGenRandom() instead of CryptGetRandom() on Windows</span></span>
<span class="line" id="L250"><span class="tok-comment">/// https://github.com/rust-lang-nursery/rand/issues/111</span></span>
<span class="line" id="L251"><span class="tok-comment">/// https://bugzilla.mozilla.org/show_bug.cgi?id=504270</span></span>
<span class="line" id="L252"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">RtlGenRandom</span>(output: []<span class="tok-type">u8</span>) RtlGenRandomError!<span class="tok-type">void</span> {</span>
<span class="line" id="L253">    <span class="tok-kw">var</span> total_read: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L254">    <span class="tok-kw">var</span> buff: []<span class="tok-type">u8</span> = output[<span class="tok-number">0</span>..];</span>
<span class="line" id="L255">    <span class="tok-kw">const</span> max_read_size: ULONG = maxInt(ULONG);</span>
<span class="line" id="L256"></span>
<span class="line" id="L257">    <span class="tok-kw">while</span> (total_read &lt; output.len) {</span>
<span class="line" id="L258">        <span class="tok-kw">const</span> to_read: ULONG = math.min(buff.len, max_read_size);</span>
<span class="line" id="L259"></span>
<span class="line" id="L260">        <span class="tok-kw">if</span> (advapi32.RtlGenRandom(buff.ptr, to_read) == <span class="tok-number">0</span>) {</span>
<span class="line" id="L261">            <span class="tok-kw">return</span> unexpectedError(kernel32.GetLastError());</span>
<span class="line" id="L262">        }</span>
<span class="line" id="L263"></span>
<span class="line" id="L264">        total_read += to_read;</span>
<span class="line" id="L265">        buff = buff[to_read..];</span>
<span class="line" id="L266">    }</span>
<span class="line" id="L267">}</span>
<span class="line" id="L268"></span>
<span class="line" id="L269"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WaitForSingleObjectError = <span class="tok-kw">error</span>{</span>
<span class="line" id="L270">    WaitAbandoned,</span>
<span class="line" id="L271">    WaitTimeOut,</span>
<span class="line" id="L272">    Unexpected,</span>
<span class="line" id="L273">};</span>
<span class="line" id="L274"></span>
<span class="line" id="L275"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">WaitForSingleObject</span>(handle: HANDLE, milliseconds: DWORD) WaitForSingleObjectError!<span class="tok-type">void</span> {</span>
<span class="line" id="L276">    <span class="tok-kw">return</span> WaitForSingleObjectEx(handle, milliseconds, <span class="tok-null">false</span>);</span>
<span class="line" id="L277">}</span>
<span class="line" id="L278"></span>
<span class="line" id="L279"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">WaitForSingleObjectEx</span>(handle: HANDLE, milliseconds: DWORD, alertable: <span class="tok-type">bool</span>) WaitForSingleObjectError!<span class="tok-type">void</span> {</span>
<span class="line" id="L280">    <span class="tok-kw">switch</span> (kernel32.WaitForSingleObjectEx(handle, milliseconds, <span class="tok-builtin">@boolToInt</span>(alertable))) {</span>
<span class="line" id="L281">        WAIT_ABANDONED =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.WaitAbandoned,</span>
<span class="line" id="L282">        WAIT_OBJECT_0 =&gt; <span class="tok-kw">return</span>,</span>
<span class="line" id="L283">        WAIT_TIMEOUT =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.WaitTimeOut,</span>
<span class="line" id="L284">        WAIT_FAILED =&gt; <span class="tok-kw">switch</span> (kernel32.GetLastError()) {</span>
<span class="line" id="L285">            <span class="tok-kw">else</span> =&gt; |err| <span class="tok-kw">return</span> unexpectedError(err),</span>
<span class="line" id="L286">        },</span>
<span class="line" id="L287">        <span class="tok-kw">else</span> =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.Unexpected,</span>
<span class="line" id="L288">    }</span>
<span class="line" id="L289">}</span>
<span class="line" id="L290"></span>
<span class="line" id="L291"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">WaitForMultipleObjectsEx</span>(handles: []<span class="tok-kw">const</span> HANDLE, waitAll: <span class="tok-type">bool</span>, milliseconds: DWORD, alertable: <span class="tok-type">bool</span>) !<span class="tok-type">u32</span> {</span>
<span class="line" id="L292">    assert(handles.len &lt; MAXIMUM_WAIT_OBJECTS);</span>
<span class="line" id="L293">    <span class="tok-kw">const</span> nCount: DWORD = <span class="tok-builtin">@intCast</span>(DWORD, handles.len);</span>
<span class="line" id="L294">    <span class="tok-kw">switch</span> (kernel32.WaitForMultipleObjectsEx(</span>
<span class="line" id="L295">        nCount,</span>
<span class="line" id="L296">        handles.ptr,</span>
<span class="line" id="L297">        <span class="tok-builtin">@boolToInt</span>(waitAll),</span>
<span class="line" id="L298">        milliseconds,</span>
<span class="line" id="L299">        <span class="tok-builtin">@boolToInt</span>(alertable),</span>
<span class="line" id="L300">    )) {</span>
<span class="line" id="L301">        WAIT_OBJECT_0...WAIT_OBJECT_0 + MAXIMUM_WAIT_OBJECTS =&gt; |n| {</span>
<span class="line" id="L302">            <span class="tok-kw">const</span> handle_index = n - WAIT_OBJECT_0;</span>
<span class="line" id="L303">            assert(handle_index &lt; nCount);</span>
<span class="line" id="L304">            <span class="tok-kw">return</span> handle_index;</span>
<span class="line" id="L305">        },</span>
<span class="line" id="L306">        WAIT_ABANDONED_0...WAIT_ABANDONED_0 + MAXIMUM_WAIT_OBJECTS =&gt; |n| {</span>
<span class="line" id="L307">            <span class="tok-kw">const</span> handle_index = n - WAIT_ABANDONED_0;</span>
<span class="line" id="L308">            assert(handle_index &lt; nCount);</span>
<span class="line" id="L309">            <span class="tok-kw">return</span> <span class="tok-kw">error</span>.WaitAbandoned;</span>
<span class="line" id="L310">        },</span>
<span class="line" id="L311">        WAIT_TIMEOUT =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.WaitTimeOut,</span>
<span class="line" id="L312">        WAIT_FAILED =&gt; <span class="tok-kw">switch</span> (kernel32.GetLastError()) {</span>
<span class="line" id="L313">            <span class="tok-kw">else</span> =&gt; |err| <span class="tok-kw">return</span> unexpectedError(err),</span>
<span class="line" id="L314">        },</span>
<span class="line" id="L315">        <span class="tok-kw">else</span> =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.Unexpected,</span>
<span class="line" id="L316">    }</span>
<span class="line" id="L317">}</span>
<span class="line" id="L318"></span>
<span class="line" id="L319"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> CreateIoCompletionPortError = <span class="tok-kw">error</span>{Unexpected};</span>
<span class="line" id="L320"></span>
<span class="line" id="L321"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">CreateIoCompletionPort</span>(</span>
<span class="line" id="L322">    file_handle: HANDLE,</span>
<span class="line" id="L323">    existing_completion_port: ?HANDLE,</span>
<span class="line" id="L324">    completion_key: <span class="tok-type">usize</span>,</span>
<span class="line" id="L325">    concurrent_thread_count: DWORD,</span>
<span class="line" id="L326">) CreateIoCompletionPortError!HANDLE {</span>
<span class="line" id="L327">    <span class="tok-kw">const</span> handle = kernel32.CreateIoCompletionPort(file_handle, existing_completion_port, completion_key, concurrent_thread_count) <span class="tok-kw">orelse</span> {</span>
<span class="line" id="L328">        <span class="tok-kw">switch</span> (kernel32.GetLastError()) {</span>
<span class="line" id="L329">            .INVALID_PARAMETER =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L330">            <span class="tok-kw">else</span> =&gt; |err| <span class="tok-kw">return</span> unexpectedError(err),</span>
<span class="line" id="L331">        }</span>
<span class="line" id="L332">    };</span>
<span class="line" id="L333">    <span class="tok-kw">return</span> handle;</span>
<span class="line" id="L334">}</span>
<span class="line" id="L335"></span>
<span class="line" id="L336"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> PostQueuedCompletionStatusError = <span class="tok-kw">error</span>{Unexpected};</span>
<span class="line" id="L337"></span>
<span class="line" id="L338"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">PostQueuedCompletionStatus</span>(</span>
<span class="line" id="L339">    completion_port: HANDLE,</span>
<span class="line" id="L340">    bytes_transferred_count: DWORD,</span>
<span class="line" id="L341">    completion_key: <span class="tok-type">usize</span>,</span>
<span class="line" id="L342">    lpOverlapped: ?*OVERLAPPED,</span>
<span class="line" id="L343">) PostQueuedCompletionStatusError!<span class="tok-type">void</span> {</span>
<span class="line" id="L344">    <span class="tok-kw">if</span> (kernel32.PostQueuedCompletionStatus(completion_port, bytes_transferred_count, completion_key, lpOverlapped) == <span class="tok-number">0</span>) {</span>
<span class="line" id="L345">        <span class="tok-kw">switch</span> (kernel32.GetLastError()) {</span>
<span class="line" id="L346">            <span class="tok-kw">else</span> =&gt; |err| <span class="tok-kw">return</span> unexpectedError(err),</span>
<span class="line" id="L347">        }</span>
<span class="line" id="L348">    }</span>
<span class="line" id="L349">}</span>
<span class="line" id="L350"></span>
<span class="line" id="L351"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> GetQueuedCompletionStatusResult = <span class="tok-kw">enum</span> {</span>
<span class="line" id="L352">    Normal,</span>
<span class="line" id="L353">    Aborted,</span>
<span class="line" id="L354">    Cancelled,</span>
<span class="line" id="L355">    EOF,</span>
<span class="line" id="L356">};</span>
<span class="line" id="L357"></span>
<span class="line" id="L358"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">GetQueuedCompletionStatus</span>(</span>
<span class="line" id="L359">    completion_port: HANDLE,</span>
<span class="line" id="L360">    bytes_transferred_count: *DWORD,</span>
<span class="line" id="L361">    lpCompletionKey: *<span class="tok-type">usize</span>,</span>
<span class="line" id="L362">    lpOverlapped: *?*OVERLAPPED,</span>
<span class="line" id="L363">    dwMilliseconds: DWORD,</span>
<span class="line" id="L364">) GetQueuedCompletionStatusResult {</span>
<span class="line" id="L365">    <span class="tok-kw">if</span> (kernel32.GetQueuedCompletionStatus(</span>
<span class="line" id="L366">        completion_port,</span>
<span class="line" id="L367">        bytes_transferred_count,</span>
<span class="line" id="L368">        lpCompletionKey,</span>
<span class="line" id="L369">        lpOverlapped,</span>
<span class="line" id="L370">        dwMilliseconds,</span>
<span class="line" id="L371">    ) == FALSE) {</span>
<span class="line" id="L372">        <span class="tok-kw">switch</span> (kernel32.GetLastError()) {</span>
<span class="line" id="L373">            .ABANDONED_WAIT_0 =&gt; <span class="tok-kw">return</span> GetQueuedCompletionStatusResult.Aborted,</span>
<span class="line" id="L374">            .OPERATION_ABORTED =&gt; <span class="tok-kw">return</span> GetQueuedCompletionStatusResult.Cancelled,</span>
<span class="line" id="L375">            .HANDLE_EOF =&gt; <span class="tok-kw">return</span> GetQueuedCompletionStatusResult.EOF,</span>
<span class="line" id="L376">            <span class="tok-kw">else</span> =&gt; |err| {</span>
<span class="line" id="L377">                <span class="tok-kw">if</span> (std.debug.runtime_safety) {</span>
<span class="line" id="L378">                    <span class="tok-builtin">@setEvalBranchQuota</span>(<span class="tok-number">2500</span>);</span>
<span class="line" id="L379">                    std.debug.panic(<span class="tok-str">&quot;unexpected error: {}\n&quot;</span>, .{err});</span>
<span class="line" id="L380">                }</span>
<span class="line" id="L381">            },</span>
<span class="line" id="L382">        }</span>
<span class="line" id="L383">    }</span>
<span class="line" id="L384">    <span class="tok-kw">return</span> GetQueuedCompletionStatusResult.Normal;</span>
<span class="line" id="L385">}</span>
<span class="line" id="L386"></span>
<span class="line" id="L387"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> GetQueuedCompletionStatusError = <span class="tok-kw">error</span>{</span>
<span class="line" id="L388">    Aborted,</span>
<span class="line" id="L389">    Cancelled,</span>
<span class="line" id="L390">    EOF,</span>
<span class="line" id="L391">    Timeout,</span>
<span class="line" id="L392">} || std.os.UnexpectedError;</span>
<span class="line" id="L393"></span>
<span class="line" id="L394"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">GetQueuedCompletionStatusEx</span>(</span>
<span class="line" id="L395">    completion_port: HANDLE,</span>
<span class="line" id="L396">    completion_port_entries: []OVERLAPPED_ENTRY,</span>
<span class="line" id="L397">    timeout_ms: ?DWORD,</span>
<span class="line" id="L398">    alertable: <span class="tok-type">bool</span>,</span>
<span class="line" id="L399">) GetQueuedCompletionStatusError!<span class="tok-type">u32</span> {</span>
<span class="line" id="L400">    <span class="tok-kw">var</span> num_entries_removed: <span class="tok-type">u32</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L401"></span>
<span class="line" id="L402">    <span class="tok-kw">const</span> success = kernel32.GetQueuedCompletionStatusEx(</span>
<span class="line" id="L403">        completion_port,</span>
<span class="line" id="L404">        completion_port_entries.ptr,</span>
<span class="line" id="L405">        <span class="tok-builtin">@intCast</span>(ULONG, completion_port_entries.len),</span>
<span class="line" id="L406">        &amp;num_entries_removed,</span>
<span class="line" id="L407">        timeout_ms <span class="tok-kw">orelse</span> INFINITE,</span>
<span class="line" id="L408">        <span class="tok-builtin">@boolToInt</span>(alertable),</span>
<span class="line" id="L409">    );</span>
<span class="line" id="L410"></span>
<span class="line" id="L411">    <span class="tok-kw">if</span> (success == FALSE) {</span>
<span class="line" id="L412">        <span class="tok-kw">return</span> <span class="tok-kw">switch</span> (kernel32.GetLastError()) {</span>
<span class="line" id="L413">            .ABANDONED_WAIT_0 =&gt; <span class="tok-kw">error</span>.Aborted,</span>
<span class="line" id="L414">            .OPERATION_ABORTED =&gt; <span class="tok-kw">error</span>.Cancelled,</span>
<span class="line" id="L415">            .HANDLE_EOF =&gt; <span class="tok-kw">error</span>.EOF,</span>
<span class="line" id="L416">            .IMEOUT =&gt; <span class="tok-kw">error</span>.Timeout,</span>
<span class="line" id="L417">            <span class="tok-kw">else</span> =&gt; |err| unexpectedError(err),</span>
<span class="line" id="L418">        };</span>
<span class="line" id="L419">    }</span>
<span class="line" id="L420"></span>
<span class="line" id="L421">    <span class="tok-kw">return</span> num_entries_removed;</span>
<span class="line" id="L422">}</span>
<span class="line" id="L423"></span>
<span class="line" id="L424"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">CloseHandle</span>(hObject: HANDLE) <span class="tok-type">void</span> {</span>
<span class="line" id="L425">    assert(ntdll.NtClose(hObject) == .SUCCESS);</span>
<span class="line" id="L426">}</span>
<span class="line" id="L427"></span>
<span class="line" id="L428"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">FindClose</span>(hFindFile: HANDLE) <span class="tok-type">void</span> {</span>
<span class="line" id="L429">    assert(kernel32.FindClose(hFindFile) != <span class="tok-number">0</span>);</span>
<span class="line" id="L430">}</span>
<span class="line" id="L431"></span>
<span class="line" id="L432"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> ReadFileError = <span class="tok-kw">error</span>{</span>
<span class="line" id="L433">    OperationAborted,</span>
<span class="line" id="L434">    BrokenPipe,</span>
<span class="line" id="L435">    Unexpected,</span>
<span class="line" id="L436">};</span>
<span class="line" id="L437"></span>
<span class="line" id="L438"><span class="tok-comment">/// If buffer's length exceeds what a Windows DWORD integer can hold, it will be broken into</span></span>
<span class="line" id="L439"><span class="tok-comment">/// multiple non-atomic reads.</span></span>
<span class="line" id="L440"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">ReadFile</span>(in_hFile: HANDLE, buffer: []<span class="tok-type">u8</span>, offset: ?<span class="tok-type">u64</span>, io_mode: std.io.ModeOverride) ReadFileError!<span class="tok-type">usize</span> {</span>
<span class="line" id="L441">    <span class="tok-kw">if</span> (io_mode != .blocking) {</span>
<span class="line" id="L442">        <span class="tok-kw">const</span> loop = std.event.Loop.instance.?;</span>
<span class="line" id="L443">        <span class="tok-comment">// TODO make getting the file position non-blocking</span>
</span>
<span class="line" id="L444">        <span class="tok-kw">const</span> off = <span class="tok-kw">if</span> (offset) |o| o <span class="tok-kw">else</span> <span class="tok-kw">try</span> SetFilePointerEx_CURRENT_get(in_hFile);</span>
<span class="line" id="L445">        <span class="tok-kw">var</span> resume_node = std.event.Loop.ResumeNode.Basic{</span>
<span class="line" id="L446">            .base = .{</span>
<span class="line" id="L447">                .id = .Basic,</span>
<span class="line" id="L448">                .handle = <span class="tok-builtin">@frame</span>(),</span>
<span class="line" id="L449">                .overlapped = OVERLAPPED{</span>
<span class="line" id="L450">                    .Internal = <span class="tok-number">0</span>,</span>
<span class="line" id="L451">                    .InternalHigh = <span class="tok-number">0</span>,</span>
<span class="line" id="L452">                    .DUMMYUNIONNAME = .{</span>
<span class="line" id="L453">                        .DUMMYSTRUCTNAME = .{</span>
<span class="line" id="L454">                            .Offset = <span class="tok-builtin">@truncate</span>(<span class="tok-type">u32</span>, off),</span>
<span class="line" id="L455">                            .OffsetHigh = <span class="tok-builtin">@truncate</span>(<span class="tok-type">u32</span>, off &gt;&gt; <span class="tok-number">32</span>),</span>
<span class="line" id="L456">                        },</span>
<span class="line" id="L457">                    },</span>
<span class="line" id="L458">                    .hEvent = <span class="tok-null">null</span>,</span>
<span class="line" id="L459">                },</span>
<span class="line" id="L460">            },</span>
<span class="line" id="L461">        };</span>
<span class="line" id="L462">        loop.beginOneEvent();</span>
<span class="line" id="L463">        <span class="tok-kw">suspend</span> {</span>
<span class="line" id="L464">            <span class="tok-comment">// TODO handle buffer bigger than DWORD can hold</span>
</span>
<span class="line" id="L465">            _ = kernel32.ReadFile(in_hFile, buffer.ptr, <span class="tok-builtin">@intCast</span>(DWORD, buffer.len), <span class="tok-null">null</span>, &amp;resume_node.base.overlapped);</span>
<span class="line" id="L466">        }</span>
<span class="line" id="L467">        <span class="tok-kw">var</span> bytes_transferred: DWORD = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L468">        <span class="tok-kw">if</span> (kernel32.GetOverlappedResult(in_hFile, &amp;resume_node.base.overlapped, &amp;bytes_transferred, FALSE) == <span class="tok-number">0</span>) {</span>
<span class="line" id="L469">            <span class="tok-kw">switch</span> (kernel32.GetLastError()) {</span>
<span class="line" id="L470">                .IO_PENDING =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L471">                .OPERATION_ABORTED =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.OperationAborted,</span>
<span class="line" id="L472">                .BROKEN_PIPE =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.BrokenPipe,</span>
<span class="line" id="L473">                .HANDLE_EOF =&gt; <span class="tok-kw">return</span> <span class="tok-builtin">@as</span>(<span class="tok-type">usize</span>, bytes_transferred),</span>
<span class="line" id="L474">                <span class="tok-kw">else</span> =&gt; |err| <span class="tok-kw">return</span> unexpectedError(err),</span>
<span class="line" id="L475">            }</span>
<span class="line" id="L476">        }</span>
<span class="line" id="L477">        <span class="tok-kw">if</span> (offset == <span class="tok-null">null</span>) {</span>
<span class="line" id="L478">            <span class="tok-comment">// TODO make setting the file position non-blocking</span>
</span>
<span class="line" id="L479">            <span class="tok-kw">const</span> new_off = off + bytes_transferred;</span>
<span class="line" id="L480">            <span class="tok-kw">try</span> SetFilePointerEx_CURRENT(in_hFile, <span class="tok-builtin">@bitCast</span>(<span class="tok-type">i64</span>, new_off));</span>
<span class="line" id="L481">        }</span>
<span class="line" id="L482">        <span class="tok-kw">return</span> <span class="tok-builtin">@as</span>(<span class="tok-type">usize</span>, bytes_transferred);</span>
<span class="line" id="L483">    } <span class="tok-kw">else</span> {</span>
<span class="line" id="L484">        <span class="tok-kw">while</span> (<span class="tok-null">true</span>) {</span>
<span class="line" id="L485">            <span class="tok-kw">const</span> want_read_count = <span class="tok-builtin">@intCast</span>(DWORD, math.min(<span class="tok-builtin">@as</span>(DWORD, maxInt(DWORD)), buffer.len));</span>
<span class="line" id="L486">            <span class="tok-kw">var</span> amt_read: DWORD = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L487">            <span class="tok-kw">var</span> overlapped_data: OVERLAPPED = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L488">            <span class="tok-kw">const</span> overlapped: ?*OVERLAPPED = <span class="tok-kw">if</span> (offset) |off| blk: {</span>
<span class="line" id="L489">                overlapped_data = .{</span>
<span class="line" id="L490">                    .Internal = <span class="tok-number">0</span>,</span>
<span class="line" id="L491">                    .InternalHigh = <span class="tok-number">0</span>,</span>
<span class="line" id="L492">                    .DUMMYUNIONNAME = .{</span>
<span class="line" id="L493">                        .DUMMYSTRUCTNAME = .{</span>
<span class="line" id="L494">                            .Offset = <span class="tok-builtin">@truncate</span>(<span class="tok-type">u32</span>, off),</span>
<span class="line" id="L495">                            .OffsetHigh = <span class="tok-builtin">@truncate</span>(<span class="tok-type">u32</span>, off &gt;&gt; <span class="tok-number">32</span>),</span>
<span class="line" id="L496">                        },</span>
<span class="line" id="L497">                    },</span>
<span class="line" id="L498">                    .hEvent = <span class="tok-null">null</span>,</span>
<span class="line" id="L499">                };</span>
<span class="line" id="L500">                <span class="tok-kw">break</span> :blk &amp;overlapped_data;</span>
<span class="line" id="L501">            } <span class="tok-kw">else</span> <span class="tok-null">null</span>;</span>
<span class="line" id="L502">            <span class="tok-kw">if</span> (kernel32.ReadFile(in_hFile, buffer.ptr, want_read_count, &amp;amt_read, overlapped) == <span class="tok-number">0</span>) {</span>
<span class="line" id="L503">                <span class="tok-kw">switch</span> (kernel32.GetLastError()) {</span>
<span class="line" id="L504">                    .OPERATION_ABORTED =&gt; <span class="tok-kw">continue</span>,</span>
<span class="line" id="L505">                    .BROKEN_PIPE =&gt; <span class="tok-kw">return</span> <span class="tok-number">0</span>,</span>
<span class="line" id="L506">                    .HANDLE_EOF =&gt; <span class="tok-kw">return</span> <span class="tok-number">0</span>,</span>
<span class="line" id="L507">                    <span class="tok-kw">else</span> =&gt; |err| <span class="tok-kw">return</span> unexpectedError(err),</span>
<span class="line" id="L508">                }</span>
<span class="line" id="L509">            }</span>
<span class="line" id="L510">            <span class="tok-kw">return</span> amt_read;</span>
<span class="line" id="L511">        }</span>
<span class="line" id="L512">    }</span>
<span class="line" id="L513">}</span>
<span class="line" id="L514"></span>
<span class="line" id="L515"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WriteFileError = <span class="tok-kw">error</span>{</span>
<span class="line" id="L516">    SystemResources,</span>
<span class="line" id="L517">    OperationAborted,</span>
<span class="line" id="L518">    BrokenPipe,</span>
<span class="line" id="L519">    NotOpenForWriting,</span>
<span class="line" id="L520">    <span class="tok-comment">/// The process cannot access the file because another process has locked</span></span>
<span class="line" id="L521">    <span class="tok-comment">/// a portion of the file.</span></span>
<span class="line" id="L522">    LockViolation,</span>
<span class="line" id="L523">    Unexpected,</span>
<span class="line" id="L524">};</span>
<span class="line" id="L525"></span>
<span class="line" id="L526"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">WriteFile</span>(</span>
<span class="line" id="L527">    handle: HANDLE,</span>
<span class="line" id="L528">    bytes: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L529">    offset: ?<span class="tok-type">u64</span>,</span>
<span class="line" id="L530">    io_mode: std.io.ModeOverride,</span>
<span class="line" id="L531">) WriteFileError!<span class="tok-type">usize</span> {</span>
<span class="line" id="L532">    <span class="tok-kw">if</span> (std.event.Loop.instance != <span class="tok-null">null</span> <span class="tok-kw">and</span> io_mode != .blocking) {</span>
<span class="line" id="L533">        <span class="tok-kw">const</span> loop = std.event.Loop.instance.?;</span>
<span class="line" id="L534">        <span class="tok-comment">// TODO make getting the file position non-blocking</span>
</span>
<span class="line" id="L535">        <span class="tok-kw">const</span> off = <span class="tok-kw">if</span> (offset) |o| o <span class="tok-kw">else</span> <span class="tok-kw">try</span> SetFilePointerEx_CURRENT_get(handle);</span>
<span class="line" id="L536">        <span class="tok-kw">var</span> resume_node = std.event.Loop.ResumeNode.Basic{</span>
<span class="line" id="L537">            .base = .{</span>
<span class="line" id="L538">                .id = .Basic,</span>
<span class="line" id="L539">                .handle = <span class="tok-builtin">@frame</span>(),</span>
<span class="line" id="L540">                .overlapped = OVERLAPPED{</span>
<span class="line" id="L541">                    .Internal = <span class="tok-number">0</span>,</span>
<span class="line" id="L542">                    .InternalHigh = <span class="tok-number">0</span>,</span>
<span class="line" id="L543">                    .DUMMYUNIONNAME = .{</span>
<span class="line" id="L544">                        .DUMMYSTRUCTNAME = .{</span>
<span class="line" id="L545">                            .Offset = <span class="tok-builtin">@truncate</span>(<span class="tok-type">u32</span>, off),</span>
<span class="line" id="L546">                            .OffsetHigh = <span class="tok-builtin">@truncate</span>(<span class="tok-type">u32</span>, off &gt;&gt; <span class="tok-number">32</span>),</span>
<span class="line" id="L547">                        },</span>
<span class="line" id="L548">                    },</span>
<span class="line" id="L549">                    .hEvent = <span class="tok-null">null</span>,</span>
<span class="line" id="L550">                },</span>
<span class="line" id="L551">            },</span>
<span class="line" id="L552">        };</span>
<span class="line" id="L553">        loop.beginOneEvent();</span>
<span class="line" id="L554">        <span class="tok-kw">suspend</span> {</span>
<span class="line" id="L555">            <span class="tok-kw">const</span> adjusted_len = math.cast(DWORD, bytes.len) <span class="tok-kw">orelse</span> maxInt(DWORD);</span>
<span class="line" id="L556">            _ = kernel32.WriteFile(handle, bytes.ptr, adjusted_len, <span class="tok-null">null</span>, &amp;resume_node.base.overlapped);</span>
<span class="line" id="L557">        }</span>
<span class="line" id="L558">        <span class="tok-kw">var</span> bytes_transferred: DWORD = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L559">        <span class="tok-kw">if</span> (kernel32.GetOverlappedResult(handle, &amp;resume_node.base.overlapped, &amp;bytes_transferred, FALSE) == <span class="tok-number">0</span>) {</span>
<span class="line" id="L560">            <span class="tok-kw">switch</span> (kernel32.GetLastError()) {</span>
<span class="line" id="L561">                .IO_PENDING =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L562">                .INVALID_USER_BUFFER =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SystemResources,</span>
<span class="line" id="L563">                .NOT_ENOUGH_MEMORY =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SystemResources,</span>
<span class="line" id="L564">                .OPERATION_ABORTED =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.OperationAborted,</span>
<span class="line" id="L565">                .NOT_ENOUGH_QUOTA =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SystemResources,</span>
<span class="line" id="L566">                .BROKEN_PIPE =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.BrokenPipe,</span>
<span class="line" id="L567">                <span class="tok-kw">else</span> =&gt; |err| <span class="tok-kw">return</span> unexpectedError(err),</span>
<span class="line" id="L568">            }</span>
<span class="line" id="L569">        }</span>
<span class="line" id="L570">        <span class="tok-kw">if</span> (offset == <span class="tok-null">null</span>) {</span>
<span class="line" id="L571">            <span class="tok-comment">// TODO make setting the file position non-blocking</span>
</span>
<span class="line" id="L572">            <span class="tok-kw">const</span> new_off = off + bytes_transferred;</span>
<span class="line" id="L573">            <span class="tok-kw">try</span> SetFilePointerEx_CURRENT(handle, <span class="tok-builtin">@bitCast</span>(<span class="tok-type">i64</span>, new_off));</span>
<span class="line" id="L574">        }</span>
<span class="line" id="L575">        <span class="tok-kw">return</span> bytes_transferred;</span>
<span class="line" id="L576">    } <span class="tok-kw">else</span> {</span>
<span class="line" id="L577">        <span class="tok-kw">var</span> bytes_written: DWORD = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L578">        <span class="tok-kw">var</span> overlapped_data: OVERLAPPED = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L579">        <span class="tok-kw">const</span> overlapped: ?*OVERLAPPED = <span class="tok-kw">if</span> (offset) |off| blk: {</span>
<span class="line" id="L580">            overlapped_data = .{</span>
<span class="line" id="L581">                .Internal = <span class="tok-number">0</span>,</span>
<span class="line" id="L582">                .InternalHigh = <span class="tok-number">0</span>,</span>
<span class="line" id="L583">                .DUMMYUNIONNAME = .{</span>
<span class="line" id="L584">                    .DUMMYSTRUCTNAME = .{</span>
<span class="line" id="L585">                        .Offset = <span class="tok-builtin">@truncate</span>(<span class="tok-type">u32</span>, off),</span>
<span class="line" id="L586">                        .OffsetHigh = <span class="tok-builtin">@truncate</span>(<span class="tok-type">u32</span>, off &gt;&gt; <span class="tok-number">32</span>),</span>
<span class="line" id="L587">                    },</span>
<span class="line" id="L588">                },</span>
<span class="line" id="L589">                .hEvent = <span class="tok-null">null</span>,</span>
<span class="line" id="L590">            };</span>
<span class="line" id="L591">            <span class="tok-kw">break</span> :blk &amp;overlapped_data;</span>
<span class="line" id="L592">        } <span class="tok-kw">else</span> <span class="tok-null">null</span>;</span>
<span class="line" id="L593">        <span class="tok-kw">const</span> adjusted_len = math.cast(<span class="tok-type">u32</span>, bytes.len) <span class="tok-kw">orelse</span> maxInt(<span class="tok-type">u32</span>);</span>
<span class="line" id="L594">        <span class="tok-kw">if</span> (kernel32.WriteFile(handle, bytes.ptr, adjusted_len, &amp;bytes_written, overlapped) == <span class="tok-number">0</span>) {</span>
<span class="line" id="L595">            <span class="tok-kw">switch</span> (kernel32.GetLastError()) {</span>
<span class="line" id="L596">                .INVALID_USER_BUFFER =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SystemResources,</span>
<span class="line" id="L597">                .NOT_ENOUGH_MEMORY =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SystemResources,</span>
<span class="line" id="L598">                .OPERATION_ABORTED =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.OperationAborted,</span>
<span class="line" id="L599">                .NOT_ENOUGH_QUOTA =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SystemResources,</span>
<span class="line" id="L600">                .IO_PENDING =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L601">                .BROKEN_PIPE =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.BrokenPipe,</span>
<span class="line" id="L602">                .INVALID_HANDLE =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.NotOpenForWriting,</span>
<span class="line" id="L603">                .LOCK_VIOLATION =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.LockViolation,</span>
<span class="line" id="L604">                <span class="tok-kw">else</span> =&gt; |err| <span class="tok-kw">return</span> unexpectedError(err),</span>
<span class="line" id="L605">            }</span>
<span class="line" id="L606">        }</span>
<span class="line" id="L607">        <span class="tok-kw">return</span> bytes_written;</span>
<span class="line" id="L608">    }</span>
<span class="line" id="L609">}</span>
<span class="line" id="L610"></span>
<span class="line" id="L611"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SetCurrentDirectoryError = <span class="tok-kw">error</span>{</span>
<span class="line" id="L612">    NameTooLong,</span>
<span class="line" id="L613">    InvalidUtf8,</span>
<span class="line" id="L614">    FileNotFound,</span>
<span class="line" id="L615">    NotDir,</span>
<span class="line" id="L616">    AccessDenied,</span>
<span class="line" id="L617">    NoDevice,</span>
<span class="line" id="L618">    BadPathName,</span>
<span class="line" id="L619">    Unexpected,</span>
<span class="line" id="L620">};</span>
<span class="line" id="L621"></span>
<span class="line" id="L622"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">SetCurrentDirectory</span>(path_name: []<span class="tok-kw">const</span> <span class="tok-type">u16</span>) SetCurrentDirectoryError!<span class="tok-type">void</span> {</span>
<span class="line" id="L623">    <span class="tok-kw">const</span> path_len_bytes = math.cast(<span class="tok-type">u16</span>, path_name.len * <span class="tok-number">2</span>) <span class="tok-kw">orelse</span> <span class="tok-kw">return</span> <span class="tok-kw">error</span>.NameTooLong;</span>
<span class="line" id="L624"></span>
<span class="line" id="L625">    <span class="tok-kw">var</span> nt_name = UNICODE_STRING{</span>
<span class="line" id="L626">        .Length = path_len_bytes,</span>
<span class="line" id="L627">        .MaximumLength = path_len_bytes,</span>
<span class="line" id="L628">        .Buffer = <span class="tok-builtin">@intToPtr</span>([*]<span class="tok-type">u16</span>, <span class="tok-builtin">@ptrToInt</span>(path_name.ptr)),</span>
<span class="line" id="L629">    };</span>
<span class="line" id="L630"></span>
<span class="line" id="L631">    <span class="tok-kw">const</span> rc = ntdll.RtlSetCurrentDirectory_U(&amp;nt_name);</span>
<span class="line" id="L632">    <span class="tok-kw">switch</span> (rc) {</span>
<span class="line" id="L633">        .SUCCESS =&gt; {},</span>
<span class="line" id="L634">        .OBJECT_NAME_INVALID =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.BadPathName,</span>
<span class="line" id="L635">        .OBJECT_NAME_NOT_FOUND =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.FileNotFound,</span>
<span class="line" id="L636">        .OBJECT_PATH_NOT_FOUND =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.FileNotFound,</span>
<span class="line" id="L637">        .NO_MEDIA_IN_DEVICE =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.NoDevice,</span>
<span class="line" id="L638">        .INVALID_PARAMETER =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L639">        .ACCESS_DENIED =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.AccessDenied,</span>
<span class="line" id="L640">        .OBJECT_PATH_SYNTAX_BAD =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L641">        .NOT_A_DIRECTORY =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.NotDir,</span>
<span class="line" id="L642">        <span class="tok-kw">else</span> =&gt; <span class="tok-kw">return</span> unexpectedStatus(rc),</span>
<span class="line" id="L643">    }</span>
<span class="line" id="L644">}</span>
<span class="line" id="L645"></span>
<span class="line" id="L646"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> GetCurrentDirectoryError = <span class="tok-kw">error</span>{</span>
<span class="line" id="L647">    NameTooLong,</span>
<span class="line" id="L648">    Unexpected,</span>
<span class="line" id="L649">};</span>
<span class="line" id="L650"></span>
<span class="line" id="L651"><span class="tok-comment">/// The result is a slice of `buffer`, indexed from 0.</span></span>
<span class="line" id="L652"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">GetCurrentDirectory</span>(buffer: []<span class="tok-type">u8</span>) GetCurrentDirectoryError![]<span class="tok-type">u8</span> {</span>
<span class="line" id="L653">    <span class="tok-kw">var</span> utf16le_buf: [PATH_MAX_WIDE]<span class="tok-type">u16</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L654">    <span class="tok-kw">const</span> result = kernel32.GetCurrentDirectoryW(utf16le_buf.len, &amp;utf16le_buf);</span>
<span class="line" id="L655">    <span class="tok-kw">if</span> (result == <span class="tok-number">0</span>) {</span>
<span class="line" id="L656">        <span class="tok-kw">switch</span> (kernel32.GetLastError()) {</span>
<span class="line" id="L657">            <span class="tok-kw">else</span> =&gt; |err| <span class="tok-kw">return</span> unexpectedError(err),</span>
<span class="line" id="L658">        }</span>
<span class="line" id="L659">    }</span>
<span class="line" id="L660">    assert(result &lt;= utf16le_buf.len);</span>
<span class="line" id="L661">    <span class="tok-kw">const</span> utf16le_slice = utf16le_buf[<span class="tok-number">0</span>..result];</span>
<span class="line" id="L662">    <span class="tok-comment">// Trust that Windows gives us valid UTF-16LE.</span>
</span>
<span class="line" id="L663">    <span class="tok-kw">var</span> end_index: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L664">    <span class="tok-kw">var</span> it = std.unicode.Utf16LeIterator.init(utf16le_slice);</span>
<span class="line" id="L665">    <span class="tok-kw">while</span> (it.nextCodepoint() <span class="tok-kw">catch</span> <span class="tok-kw">unreachable</span>) |codepoint| {</span>
<span class="line" id="L666">        <span class="tok-kw">const</span> seq_len = std.unicode.utf8CodepointSequenceLength(codepoint) <span class="tok-kw">catch</span> <span class="tok-kw">unreachable</span>;</span>
<span class="line" id="L667">        <span class="tok-kw">if</span> (end_index + seq_len &gt;= buffer.len)</span>
<span class="line" id="L668">            <span class="tok-kw">return</span> <span class="tok-kw">error</span>.NameTooLong;</span>
<span class="line" id="L669">        end_index += std.unicode.utf8Encode(codepoint, buffer[end_index..]) <span class="tok-kw">catch</span> <span class="tok-kw">unreachable</span>;</span>
<span class="line" id="L670">    }</span>
<span class="line" id="L671">    <span class="tok-kw">return</span> buffer[<span class="tok-number">0</span>..end_index];</span>
<span class="line" id="L672">}</span>
<span class="line" id="L673"></span>
<span class="line" id="L674"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> CreateSymbolicLinkError = <span class="tok-kw">error</span>{</span>
<span class="line" id="L675">    AccessDenied,</span>
<span class="line" id="L676">    PathAlreadyExists,</span>
<span class="line" id="L677">    FileNotFound,</span>
<span class="line" id="L678">    NameTooLong,</span>
<span class="line" id="L679">    NoDevice,</span>
<span class="line" id="L680">    Unexpected,</span>
<span class="line" id="L681">};</span>
<span class="line" id="L682"></span>
<span class="line" id="L683"><span class="tok-comment">/// Needs either:</span></span>
<span class="line" id="L684"><span class="tok-comment">/// - `SeCreateSymbolicLinkPrivilege` privilege</span></span>
<span class="line" id="L685"><span class="tok-comment">/// or</span></span>
<span class="line" id="L686"><span class="tok-comment">/// - Developer mode on Windows 10</span></span>
<span class="line" id="L687"><span class="tok-comment">/// otherwise fails with `error.AccessDenied`. In which case `sym_link_path` may still</span></span>
<span class="line" id="L688"><span class="tok-comment">/// be created on the file system but will lack reparse processing data applied to it.</span></span>
<span class="line" id="L689"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">CreateSymbolicLink</span>(</span>
<span class="line" id="L690">    dir: ?HANDLE,</span>
<span class="line" id="L691">    sym_link_path: []<span class="tok-kw">const</span> <span class="tok-type">u16</span>,</span>
<span class="line" id="L692">    target_path: []<span class="tok-kw">const</span> <span class="tok-type">u16</span>,</span>
<span class="line" id="L693">    is_directory: <span class="tok-type">bool</span>,</span>
<span class="line" id="L694">) CreateSymbolicLinkError!<span class="tok-type">void</span> {</span>
<span class="line" id="L695">    <span class="tok-kw">const</span> SYMLINK_DATA = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L696">        ReparseTag: ULONG,</span>
<span class="line" id="L697">        ReparseDataLength: USHORT,</span>
<span class="line" id="L698">        Reserved: USHORT,</span>
<span class="line" id="L699">        SubstituteNameOffset: USHORT,</span>
<span class="line" id="L700">        SubstituteNameLength: USHORT,</span>
<span class="line" id="L701">        PrintNameOffset: USHORT,</span>
<span class="line" id="L702">        PrintNameLength: USHORT,</span>
<span class="line" id="L703">        Flags: ULONG,</span>
<span class="line" id="L704">    };</span>
<span class="line" id="L705"></span>
<span class="line" id="L706">    <span class="tok-kw">const</span> symlink_handle = OpenFile(sym_link_path, .{</span>
<span class="line" id="L707">        .access_mask = SYNCHRONIZE | GENERIC_READ | GENERIC_WRITE,</span>
<span class="line" id="L708">        .dir = dir,</span>
<span class="line" id="L709">        .creation = FILE_CREATE,</span>
<span class="line" id="L710">        .io_mode = .blocking,</span>
<span class="line" id="L711">        .filter = <span class="tok-kw">if</span> (is_directory) .dir_only <span class="tok-kw">else</span> .file_only,</span>
<span class="line" id="L712">    }) <span class="tok-kw">catch</span> |err| <span class="tok-kw">switch</span> (err) {</span>
<span class="line" id="L713">        <span class="tok-kw">error</span>.IsDir =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.PathAlreadyExists,</span>
<span class="line" id="L714">        <span class="tok-kw">error</span>.NotDir =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L715">        <span class="tok-kw">error</span>.WouldBlock =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L716">        <span class="tok-kw">error</span>.PipeBusy =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L717">        <span class="tok-kw">else</span> =&gt; |e| <span class="tok-kw">return</span> e,</span>
<span class="line" id="L718">    };</span>
<span class="line" id="L719">    <span class="tok-kw">defer</span> CloseHandle(symlink_handle);</span>
<span class="line" id="L720"></span>
<span class="line" id="L721">    <span class="tok-comment">// prepare reparse data buffer</span>
</span>
<span class="line" id="L722">    <span class="tok-kw">var</span> buffer: [MAXIMUM_REPARSE_DATA_BUFFER_SIZE]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L723">    <span class="tok-kw">const</span> buf_len = <span class="tok-builtin">@sizeOf</span>(SYMLINK_DATA) + target_path.len * <span class="tok-number">4</span>;</span>
<span class="line" id="L724">    <span class="tok-kw">const</span> header_len = <span class="tok-builtin">@sizeOf</span>(ULONG) + <span class="tok-builtin">@sizeOf</span>(USHORT) * <span class="tok-number">2</span>;</span>
<span class="line" id="L725">    <span class="tok-kw">const</span> symlink_data = SYMLINK_DATA{</span>
<span class="line" id="L726">        .ReparseTag = IO_REPARSE_TAG_SYMLINK,</span>
<span class="line" id="L727">        .ReparseDataLength = <span class="tok-builtin">@intCast</span>(<span class="tok-type">u16</span>, buf_len - header_len),</span>
<span class="line" id="L728">        .Reserved = <span class="tok-number">0</span>,</span>
<span class="line" id="L729">        .SubstituteNameOffset = <span class="tok-builtin">@intCast</span>(<span class="tok-type">u16</span>, target_path.len * <span class="tok-number">2</span>),</span>
<span class="line" id="L730">        .SubstituteNameLength = <span class="tok-builtin">@intCast</span>(<span class="tok-type">u16</span>, target_path.len * <span class="tok-number">2</span>),</span>
<span class="line" id="L731">        .PrintNameOffset = <span class="tok-number">0</span>,</span>
<span class="line" id="L732">        .PrintNameLength = <span class="tok-builtin">@intCast</span>(<span class="tok-type">u16</span>, target_path.len * <span class="tok-number">2</span>),</span>
<span class="line" id="L733">        .Flags = <span class="tok-kw">if</span> (dir) |_| SYMLINK_FLAG_RELATIVE <span class="tok-kw">else</span> <span class="tok-number">0</span>,</span>
<span class="line" id="L734">    };</span>
<span class="line" id="L735"></span>
<span class="line" id="L736">    std.mem.copy(<span class="tok-type">u8</span>, buffer[<span class="tok-number">0</span>..], std.mem.asBytes(&amp;symlink_data));</span>
<span class="line" id="L737">    <span class="tok-builtin">@memcpy</span>(buffer[<span class="tok-builtin">@sizeOf</span>(SYMLINK_DATA)..], <span class="tok-builtin">@ptrCast</span>([*]<span class="tok-kw">const</span> <span class="tok-type">u8</span>, target_path), target_path.len * <span class="tok-number">2</span>);</span>
<span class="line" id="L738">    <span class="tok-kw">const</span> paths_start = <span class="tok-builtin">@sizeOf</span>(SYMLINK_DATA) + target_path.len * <span class="tok-number">2</span>;</span>
<span class="line" id="L739">    <span class="tok-builtin">@memcpy</span>(buffer[paths_start..].ptr, <span class="tok-builtin">@ptrCast</span>([*]<span class="tok-kw">const</span> <span class="tok-type">u8</span>, target_path), target_path.len * <span class="tok-number">2</span>);</span>
<span class="line" id="L740">    _ = <span class="tok-kw">try</span> DeviceIoControl(symlink_handle, FSCTL_SET_REPARSE_POINT, buffer[<span class="tok-number">0</span>..buf_len], <span class="tok-null">null</span>);</span>
<span class="line" id="L741">}</span>
<span class="line" id="L742"></span>
<span class="line" id="L743"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> ReadLinkError = <span class="tok-kw">error</span>{</span>
<span class="line" id="L744">    FileNotFound,</span>
<span class="line" id="L745">    AccessDenied,</span>
<span class="line" id="L746">    Unexpected,</span>
<span class="line" id="L747">    NameTooLong,</span>
<span class="line" id="L748">    UnsupportedReparsePointType,</span>
<span class="line" id="L749">};</span>
<span class="line" id="L750"></span>
<span class="line" id="L751"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">ReadLink</span>(dir: ?HANDLE, sub_path_w: []<span class="tok-kw">const</span> <span class="tok-type">u16</span>, out_buffer: []<span class="tok-type">u8</span>) ReadLinkError![]<span class="tok-type">u8</span> {</span>
<span class="line" id="L752">    <span class="tok-comment">// Here, we use `NtCreateFile` to shave off one syscall if we were to use `OpenFile` wrapper.</span>
</span>
<span class="line" id="L753">    <span class="tok-comment">// With the latter, we'd need to call `NtCreateFile` twice, once for file symlink, and if that</span>
</span>
<span class="line" id="L754">    <span class="tok-comment">// failed, again for dir symlink. Omitting any mention of file/dir flags makes it possible</span>
</span>
<span class="line" id="L755">    <span class="tok-comment">// to open the symlink there and then.</span>
</span>
<span class="line" id="L756">    <span class="tok-kw">const</span> path_len_bytes = math.cast(<span class="tok-type">u16</span>, sub_path_w.len * <span class="tok-number">2</span>) <span class="tok-kw">orelse</span> <span class="tok-kw">return</span> <span class="tok-kw">error</span>.NameTooLong;</span>
<span class="line" id="L757">    <span class="tok-kw">var</span> nt_name = UNICODE_STRING{</span>
<span class="line" id="L758">        .Length = path_len_bytes,</span>
<span class="line" id="L759">        .MaximumLength = path_len_bytes,</span>
<span class="line" id="L760">        .Buffer = <span class="tok-builtin">@intToPtr</span>([*]<span class="tok-type">u16</span>, <span class="tok-builtin">@ptrToInt</span>(sub_path_w.ptr)),</span>
<span class="line" id="L761">    };</span>
<span class="line" id="L762">    <span class="tok-kw">var</span> attr = OBJECT_ATTRIBUTES{</span>
<span class="line" id="L763">        .Length = <span class="tok-builtin">@sizeOf</span>(OBJECT_ATTRIBUTES),</span>
<span class="line" id="L764">        .RootDirectory = <span class="tok-kw">if</span> (std.fs.path.isAbsoluteWindowsWTF16(sub_path_w)) <span class="tok-null">null</span> <span class="tok-kw">else</span> dir,</span>
<span class="line" id="L765">        .Attributes = <span class="tok-number">0</span>, <span class="tok-comment">// Note we do not use OBJ_CASE_INSENSITIVE here.</span>
</span>
<span class="line" id="L766">        .ObjectName = &amp;nt_name,</span>
<span class="line" id="L767">        .SecurityDescriptor = <span class="tok-null">null</span>,</span>
<span class="line" id="L768">        .SecurityQualityOfService = <span class="tok-null">null</span>,</span>
<span class="line" id="L769">    };</span>
<span class="line" id="L770">    <span class="tok-kw">var</span> result_handle: HANDLE = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L771">    <span class="tok-kw">var</span> io: IO_STATUS_BLOCK = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L772"></span>
<span class="line" id="L773">    <span class="tok-kw">const</span> rc = ntdll.NtCreateFile(</span>
<span class="line" id="L774">        &amp;result_handle,</span>
<span class="line" id="L775">        FILE_READ_ATTRIBUTES,</span>
<span class="line" id="L776">        &amp;attr,</span>
<span class="line" id="L777">        &amp;io,</span>
<span class="line" id="L778">        <span class="tok-null">null</span>,</span>
<span class="line" id="L779">        FILE_ATTRIBUTE_NORMAL,</span>
<span class="line" id="L780">        FILE_SHARE_READ,</span>
<span class="line" id="L781">        FILE_OPEN,</span>
<span class="line" id="L782">        FILE_OPEN_REPARSE_POINT,</span>
<span class="line" id="L783">        <span class="tok-null">null</span>,</span>
<span class="line" id="L784">        <span class="tok-number">0</span>,</span>
<span class="line" id="L785">    );</span>
<span class="line" id="L786">    <span class="tok-kw">switch</span> (rc) {</span>
<span class="line" id="L787">        .SUCCESS =&gt; {},</span>
<span class="line" id="L788">        .OBJECT_NAME_INVALID =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L789">        .OBJECT_NAME_NOT_FOUND =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.FileNotFound,</span>
<span class="line" id="L790">        .OBJECT_PATH_NOT_FOUND =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.FileNotFound,</span>
<span class="line" id="L791">        .NO_MEDIA_IN_DEVICE =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.FileNotFound,</span>
<span class="line" id="L792">        .INVALID_PARAMETER =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L793">        .SHARING_VIOLATION =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.AccessDenied,</span>
<span class="line" id="L794">        .ACCESS_DENIED =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.AccessDenied,</span>
<span class="line" id="L795">        .PIPE_BUSY =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.AccessDenied,</span>
<span class="line" id="L796">        .OBJECT_PATH_SYNTAX_BAD =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L797">        .OBJECT_NAME_COLLISION =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L798">        .FILE_IS_A_DIRECTORY =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L799">        <span class="tok-kw">else</span> =&gt; <span class="tok-kw">return</span> unexpectedStatus(rc),</span>
<span class="line" id="L800">    }</span>
<span class="line" id="L801">    <span class="tok-kw">defer</span> CloseHandle(result_handle);</span>
<span class="line" id="L802"></span>
<span class="line" id="L803">    <span class="tok-kw">var</span> reparse_buf: [MAXIMUM_REPARSE_DATA_BUFFER_SIZE]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L804">    _ = DeviceIoControl(result_handle, FSCTL_GET_REPARSE_POINT, <span class="tok-null">null</span>, reparse_buf[<span class="tok-number">0</span>..]) <span class="tok-kw">catch</span> |err| <span class="tok-kw">switch</span> (err) {</span>
<span class="line" id="L805">        <span class="tok-kw">error</span>.AccessDenied =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L806">        <span class="tok-kw">else</span> =&gt; |e| <span class="tok-kw">return</span> e,</span>
<span class="line" id="L807">    };</span>
<span class="line" id="L808"></span>
<span class="line" id="L809">    <span class="tok-kw">const</span> reparse_struct = <span class="tok-builtin">@ptrCast</span>(*<span class="tok-kw">const</span> REPARSE_DATA_BUFFER, <span class="tok-builtin">@alignCast</span>(<span class="tok-builtin">@alignOf</span>(REPARSE_DATA_BUFFER), &amp;reparse_buf[<span class="tok-number">0</span>]));</span>
<span class="line" id="L810">    <span class="tok-kw">switch</span> (reparse_struct.ReparseTag) {</span>
<span class="line" id="L811">        IO_REPARSE_TAG_SYMLINK =&gt; {</span>
<span class="line" id="L812">            <span class="tok-kw">const</span> buf = <span class="tok-builtin">@ptrCast</span>(*<span class="tok-kw">const</span> SYMBOLIC_LINK_REPARSE_BUFFER, <span class="tok-builtin">@alignCast</span>(<span class="tok-builtin">@alignOf</span>(SYMBOLIC_LINK_REPARSE_BUFFER), &amp;reparse_struct.DataBuffer[<span class="tok-number">0</span>]));</span>
<span class="line" id="L813">            <span class="tok-kw">const</span> offset = buf.SubstituteNameOffset &gt;&gt; <span class="tok-number">1</span>;</span>
<span class="line" id="L814">            <span class="tok-kw">const</span> len = buf.SubstituteNameLength &gt;&gt; <span class="tok-number">1</span>;</span>
<span class="line" id="L815">            <span class="tok-kw">const</span> path_buf = <span class="tok-builtin">@as</span>([*]<span class="tok-kw">const</span> <span class="tok-type">u16</span>, &amp;buf.PathBuffer);</span>
<span class="line" id="L816">            <span class="tok-kw">const</span> is_relative = buf.Flags &amp; SYMLINK_FLAG_RELATIVE != <span class="tok-number">0</span>;</span>
<span class="line" id="L817">            <span class="tok-kw">return</span> parseReadlinkPath(path_buf[offset .. offset + len], is_relative, out_buffer);</span>
<span class="line" id="L818">        },</span>
<span class="line" id="L819">        IO_REPARSE_TAG_MOUNT_POINT =&gt; {</span>
<span class="line" id="L820">            <span class="tok-kw">const</span> buf = <span class="tok-builtin">@ptrCast</span>(*<span class="tok-kw">const</span> MOUNT_POINT_REPARSE_BUFFER, <span class="tok-builtin">@alignCast</span>(<span class="tok-builtin">@alignOf</span>(MOUNT_POINT_REPARSE_BUFFER), &amp;reparse_struct.DataBuffer[<span class="tok-number">0</span>]));</span>
<span class="line" id="L821">            <span class="tok-kw">const</span> offset = buf.SubstituteNameOffset &gt;&gt; <span class="tok-number">1</span>;</span>
<span class="line" id="L822">            <span class="tok-kw">const</span> len = buf.SubstituteNameLength &gt;&gt; <span class="tok-number">1</span>;</span>
<span class="line" id="L823">            <span class="tok-kw">const</span> path_buf = <span class="tok-builtin">@as</span>([*]<span class="tok-kw">const</span> <span class="tok-type">u16</span>, &amp;buf.PathBuffer);</span>
<span class="line" id="L824">            <span class="tok-kw">return</span> parseReadlinkPath(path_buf[offset .. offset + len], <span class="tok-null">false</span>, out_buffer);</span>
<span class="line" id="L825">        },</span>
<span class="line" id="L826">        <span class="tok-kw">else</span> =&gt; |value| {</span>
<span class="line" id="L827">            std.debug.print(<span class="tok-str">&quot;unsupported symlink type: {}&quot;</span>, .{value});</span>
<span class="line" id="L828">            <span class="tok-kw">return</span> <span class="tok-kw">error</span>.UnsupportedReparsePointType;</span>
<span class="line" id="L829">        },</span>
<span class="line" id="L830">    }</span>
<span class="line" id="L831">}</span>
<span class="line" id="L832"></span>
<span class="line" id="L833"><span class="tok-kw">fn</span> <span class="tok-fn">parseReadlinkPath</span>(path: []<span class="tok-kw">const</span> <span class="tok-type">u16</span>, is_relative: <span class="tok-type">bool</span>, out_buffer: []<span class="tok-type">u8</span>) []<span class="tok-type">u8</span> {</span>
<span class="line" id="L834">    <span class="tok-kw">const</span> prefix = [_]<span class="tok-type">u16</span>{ <span class="tok-str">'\\'</span>, <span class="tok-str">'?'</span>, <span class="tok-str">'?'</span>, <span class="tok-str">'\\'</span> };</span>
<span class="line" id="L835">    <span class="tok-kw">var</span> start_index: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L836">    <span class="tok-kw">if</span> (!is_relative <span class="tok-kw">and</span> std.mem.startsWith(<span class="tok-type">u16</span>, path, &amp;prefix)) {</span>
<span class="line" id="L837">        start_index = prefix.len;</span>
<span class="line" id="L838">    }</span>
<span class="line" id="L839">    <span class="tok-kw">const</span> out_len = std.unicode.utf16leToUtf8(out_buffer, path[start_index..]) <span class="tok-kw">catch</span> <span class="tok-kw">unreachable</span>;</span>
<span class="line" id="L840">    <span class="tok-kw">return</span> out_buffer[<span class="tok-number">0</span>..out_len];</span>
<span class="line" id="L841">}</span>
<span class="line" id="L842"></span>
<span class="line" id="L843"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> DeleteFileError = <span class="tok-kw">error</span>{</span>
<span class="line" id="L844">    FileNotFound,</span>
<span class="line" id="L845">    AccessDenied,</span>
<span class="line" id="L846">    NameTooLong,</span>
<span class="line" id="L847">    <span class="tok-comment">/// Also known as sharing violation.</span></span>
<span class="line" id="L848">    FileBusy,</span>
<span class="line" id="L849">    Unexpected,</span>
<span class="line" id="L850">    NotDir,</span>
<span class="line" id="L851">    IsDir,</span>
<span class="line" id="L852">};</span>
<span class="line" id="L853"></span>
<span class="line" id="L854"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> DeleteFileOptions = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L855">    dir: ?HANDLE,</span>
<span class="line" id="L856">    remove_dir: <span class="tok-type">bool</span> = <span class="tok-null">false</span>,</span>
<span class="line" id="L857">};</span>
<span class="line" id="L858"></span>
<span class="line" id="L859"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">DeleteFile</span>(sub_path_w: []<span class="tok-kw">const</span> <span class="tok-type">u16</span>, options: DeleteFileOptions) DeleteFileError!<span class="tok-type">void</span> {</span>
<span class="line" id="L860">    <span class="tok-kw">const</span> create_options_flags: ULONG = <span class="tok-kw">if</span> (options.remove_dir)</span>
<span class="line" id="L861">        FILE_DELETE_ON_CLOSE | FILE_DIRECTORY_FILE | FILE_OPEN_REPARSE_POINT</span>
<span class="line" id="L862">    <span class="tok-kw">else</span></span>
<span class="line" id="L863">        FILE_DELETE_ON_CLOSE | FILE_NON_DIRECTORY_FILE | FILE_OPEN_REPARSE_POINT; <span class="tok-comment">// would we ever want to delete the target instead?</span>
</span>
<span class="line" id="L864"></span>
<span class="line" id="L865">    <span class="tok-kw">const</span> path_len_bytes = <span class="tok-builtin">@intCast</span>(<span class="tok-type">u16</span>, sub_path_w.len * <span class="tok-number">2</span>);</span>
<span class="line" id="L866">    <span class="tok-kw">var</span> nt_name = UNICODE_STRING{</span>
<span class="line" id="L867">        .Length = path_len_bytes,</span>
<span class="line" id="L868">        .MaximumLength = path_len_bytes,</span>
<span class="line" id="L869">        <span class="tok-comment">// The Windows API makes this mutable, but it will not mutate here.</span>
</span>
<span class="line" id="L870">        .Buffer = <span class="tok-builtin">@intToPtr</span>([*]<span class="tok-type">u16</span>, <span class="tok-builtin">@ptrToInt</span>(sub_path_w.ptr)),</span>
<span class="line" id="L871">    };</span>
<span class="line" id="L872"></span>
<span class="line" id="L873">    <span class="tok-kw">if</span> (sub_path_w[<span class="tok-number">0</span>] == <span class="tok-str">'.'</span> <span class="tok-kw">and</span> sub_path_w[<span class="tok-number">1</span>] == <span class="tok-number">0</span>) {</span>
<span class="line" id="L874">        <span class="tok-comment">// Windows does not recognize this, but it does work with empty string.</span>
</span>
<span class="line" id="L875">        nt_name.Length = <span class="tok-number">0</span>;</span>
<span class="line" id="L876">    }</span>
<span class="line" id="L877">    <span class="tok-kw">if</span> (sub_path_w[<span class="tok-number">0</span>] == <span class="tok-str">'.'</span> <span class="tok-kw">and</span> sub_path_w[<span class="tok-number">1</span>] == <span class="tok-str">'.'</span> <span class="tok-kw">and</span> sub_path_w[<span class="tok-number">2</span>] == <span class="tok-number">0</span>) {</span>
<span class="line" id="L878">        <span class="tok-comment">// Can't remove the parent directory with an open handle.</span>
</span>
<span class="line" id="L879">        <span class="tok-kw">return</span> <span class="tok-kw">error</span>.FileBusy;</span>
<span class="line" id="L880">    }</span>
<span class="line" id="L881"></span>
<span class="line" id="L882">    <span class="tok-kw">var</span> attr = OBJECT_ATTRIBUTES{</span>
<span class="line" id="L883">        .Length = <span class="tok-builtin">@sizeOf</span>(OBJECT_ATTRIBUTES),</span>
<span class="line" id="L884">        .RootDirectory = <span class="tok-kw">if</span> (std.fs.path.isAbsoluteWindowsWTF16(sub_path_w)) <span class="tok-null">null</span> <span class="tok-kw">else</span> options.dir,</span>
<span class="line" id="L885">        .Attributes = <span class="tok-number">0</span>, <span class="tok-comment">// Note we do not use OBJ_CASE_INSENSITIVE here.</span>
</span>
<span class="line" id="L886">        .ObjectName = &amp;nt_name,</span>
<span class="line" id="L887">        .SecurityDescriptor = <span class="tok-null">null</span>,</span>
<span class="line" id="L888">        .SecurityQualityOfService = <span class="tok-null">null</span>,</span>
<span class="line" id="L889">    };</span>
<span class="line" id="L890">    <span class="tok-kw">var</span> io: IO_STATUS_BLOCK = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L891">    <span class="tok-kw">var</span> tmp_handle: HANDLE = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L892">    <span class="tok-kw">var</span> rc = ntdll.NtCreateFile(</span>
<span class="line" id="L893">        &amp;tmp_handle,</span>
<span class="line" id="L894">        SYNCHRONIZE | DELETE,</span>
<span class="line" id="L895">        &amp;attr,</span>
<span class="line" id="L896">        &amp;io,</span>
<span class="line" id="L897">        <span class="tok-null">null</span>,</span>
<span class="line" id="L898">        <span class="tok-number">0</span>,</span>
<span class="line" id="L899">        FILE_SHARE_READ | FILE_SHARE_WRITE | FILE_SHARE_DELETE,</span>
<span class="line" id="L900">        FILE_OPEN,</span>
<span class="line" id="L901">        create_options_flags,</span>
<span class="line" id="L902">        <span class="tok-null">null</span>,</span>
<span class="line" id="L903">        <span class="tok-number">0</span>,</span>
<span class="line" id="L904">    );</span>
<span class="line" id="L905">    <span class="tok-kw">switch</span> (rc) {</span>
<span class="line" id="L906">        .SUCCESS =&gt; <span class="tok-kw">return</span> CloseHandle(tmp_handle),</span>
<span class="line" id="L907">        .OBJECT_NAME_INVALID =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L908">        .OBJECT_NAME_NOT_FOUND =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.FileNotFound,</span>
<span class="line" id="L909">        .OBJECT_PATH_NOT_FOUND =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.FileNotFound,</span>
<span class="line" id="L910">        .INVALID_PARAMETER =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L911">        .FILE_IS_A_DIRECTORY =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.IsDir,</span>
<span class="line" id="L912">        .NOT_A_DIRECTORY =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.NotDir,</span>
<span class="line" id="L913">        .SHARING_VIOLATION =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.FileBusy,</span>
<span class="line" id="L914">        .CANNOT_DELETE =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.AccessDenied,</span>
<span class="line" id="L915">        <span class="tok-kw">else</span> =&gt; <span class="tok-kw">return</span> unexpectedStatus(rc),</span>
<span class="line" id="L916">    }</span>
<span class="line" id="L917">}</span>
<span class="line" id="L918"></span>
<span class="line" id="L919"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> MoveFileError = <span class="tok-kw">error</span>{ FileNotFound, AccessDenied, Unexpected };</span>
<span class="line" id="L920"></span>
<span class="line" id="L921"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">MoveFileEx</span>(old_path: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, new_path: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, flags: DWORD) MoveFileError!<span class="tok-type">void</span> {</span>
<span class="line" id="L922">    <span class="tok-kw">const</span> old_path_w = <span class="tok-kw">try</span> sliceToPrefixedFileW(old_path);</span>
<span class="line" id="L923">    <span class="tok-kw">const</span> new_path_w = <span class="tok-kw">try</span> sliceToPrefixedFileW(new_path);</span>
<span class="line" id="L924">    <span class="tok-kw">return</span> MoveFileExW(old_path_w.span().ptr, new_path_w.span().ptr, flags);</span>
<span class="line" id="L925">}</span>
<span class="line" id="L926"></span>
<span class="line" id="L927"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">MoveFileExW</span>(old_path: [*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u16</span>, new_path: [*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u16</span>, flags: DWORD) MoveFileError!<span class="tok-type">void</span> {</span>
<span class="line" id="L928">    <span class="tok-kw">if</span> (kernel32.MoveFileExW(old_path, new_path, flags) == <span class="tok-number">0</span>) {</span>
<span class="line" id="L929">        <span class="tok-kw">switch</span> (kernel32.GetLastError()) {</span>
<span class="line" id="L930">            .FILE_NOT_FOUND =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.FileNotFound,</span>
<span class="line" id="L931">            .ACCESS_DENIED =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.AccessDenied,</span>
<span class="line" id="L932">            <span class="tok-kw">else</span> =&gt; |err| <span class="tok-kw">return</span> unexpectedError(err),</span>
<span class="line" id="L933">        }</span>
<span class="line" id="L934">    }</span>
<span class="line" id="L935">}</span>
<span class="line" id="L936"></span>
<span class="line" id="L937"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> GetStdHandleError = <span class="tok-kw">error</span>{</span>
<span class="line" id="L938">    NoStandardHandleAttached,</span>
<span class="line" id="L939">    Unexpected,</span>
<span class="line" id="L940">};</span>
<span class="line" id="L941"></span>
<span class="line" id="L942"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">GetStdHandle</span>(handle_id: DWORD) GetStdHandleError!HANDLE {</span>
<span class="line" id="L943">    <span class="tok-kw">const</span> handle = kernel32.GetStdHandle(handle_id) <span class="tok-kw">orelse</span> <span class="tok-kw">return</span> <span class="tok-kw">error</span>.NoStandardHandleAttached;</span>
<span class="line" id="L944">    <span class="tok-kw">if</span> (handle == INVALID_HANDLE_VALUE) {</span>
<span class="line" id="L945">        <span class="tok-kw">switch</span> (kernel32.GetLastError()) {</span>
<span class="line" id="L946">            <span class="tok-kw">else</span> =&gt; |err| <span class="tok-kw">return</span> unexpectedError(err),</span>
<span class="line" id="L947">        }</span>
<span class="line" id="L948">    }</span>
<span class="line" id="L949">    <span class="tok-kw">return</span> handle;</span>
<span class="line" id="L950">}</span>
<span class="line" id="L951"></span>
<span class="line" id="L952"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SetFilePointerError = <span class="tok-kw">error</span>{Unexpected};</span>
<span class="line" id="L953"></span>
<span class="line" id="L954"><span class="tok-comment">/// The SetFilePointerEx function with the `dwMoveMethod` parameter set to `FILE_BEGIN`.</span></span>
<span class="line" id="L955"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">SetFilePointerEx_BEGIN</span>(handle: HANDLE, offset: <span class="tok-type">u64</span>) SetFilePointerError!<span class="tok-type">void</span> {</span>
<span class="line" id="L956">    <span class="tok-comment">// &quot;The starting point is zero or the beginning of the file. If [FILE_BEGIN]</span>
</span>
<span class="line" id="L957">    <span class="tok-comment">// is specified, then the liDistanceToMove parameter is interpreted as an unsigned value.&quot;</span>
</span>
<span class="line" id="L958">    <span class="tok-comment">// https://docs.microsoft.com/en-us/windows/desktop/api/fileapi/nf-fileapi-setfilepointerex</span>
</span>
<span class="line" id="L959">    <span class="tok-kw">const</span> ipos = <span class="tok-builtin">@bitCast</span>(LARGE_INTEGER, offset);</span>
<span class="line" id="L960">    <span class="tok-kw">if</span> (kernel32.SetFilePointerEx(handle, ipos, <span class="tok-null">null</span>, FILE_BEGIN) == <span class="tok-number">0</span>) {</span>
<span class="line" id="L961">        <span class="tok-kw">switch</span> (kernel32.GetLastError()) {</span>
<span class="line" id="L962">            .INVALID_PARAMETER =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L963">            .INVALID_HANDLE =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L964">            <span class="tok-kw">else</span> =&gt; |err| <span class="tok-kw">return</span> unexpectedError(err),</span>
<span class="line" id="L965">        }</span>
<span class="line" id="L966">    }</span>
<span class="line" id="L967">}</span>
<span class="line" id="L968"></span>
<span class="line" id="L969"><span class="tok-comment">/// The SetFilePointerEx function with the `dwMoveMethod` parameter set to `FILE_CURRENT`.</span></span>
<span class="line" id="L970"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">SetFilePointerEx_CURRENT</span>(handle: HANDLE, offset: <span class="tok-type">i64</span>) SetFilePointerError!<span class="tok-type">void</span> {</span>
<span class="line" id="L971">    <span class="tok-kw">if</span> (kernel32.SetFilePointerEx(handle, offset, <span class="tok-null">null</span>, FILE_CURRENT) == <span class="tok-number">0</span>) {</span>
<span class="line" id="L972">        <span class="tok-kw">switch</span> (kernel32.GetLastError()) {</span>
<span class="line" id="L973">            .INVALID_PARAMETER =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L974">            .INVALID_HANDLE =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L975">            <span class="tok-kw">else</span> =&gt; |err| <span class="tok-kw">return</span> unexpectedError(err),</span>
<span class="line" id="L976">        }</span>
<span class="line" id="L977">    }</span>
<span class="line" id="L978">}</span>
<span class="line" id="L979"></span>
<span class="line" id="L980"><span class="tok-comment">/// The SetFilePointerEx function with the `dwMoveMethod` parameter set to `FILE_END`.</span></span>
<span class="line" id="L981"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">SetFilePointerEx_END</span>(handle: HANDLE, offset: <span class="tok-type">i64</span>) SetFilePointerError!<span class="tok-type">void</span> {</span>
<span class="line" id="L982">    <span class="tok-kw">if</span> (kernel32.SetFilePointerEx(handle, offset, <span class="tok-null">null</span>, FILE_END) == <span class="tok-number">0</span>) {</span>
<span class="line" id="L983">        <span class="tok-kw">switch</span> (kernel32.GetLastError()) {</span>
<span class="line" id="L984">            .INVALID_PARAMETER =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L985">            .INVALID_HANDLE =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L986">            <span class="tok-kw">else</span> =&gt; |err| <span class="tok-kw">return</span> unexpectedError(err),</span>
<span class="line" id="L987">        }</span>
<span class="line" id="L988">    }</span>
<span class="line" id="L989">}</span>
<span class="line" id="L990"></span>
<span class="line" id="L991"><span class="tok-comment">/// The SetFilePointerEx function with parameters to get the current offset.</span></span>
<span class="line" id="L992"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">SetFilePointerEx_CURRENT_get</span>(handle: HANDLE) SetFilePointerError!<span class="tok-type">u64</span> {</span>
<span class="line" id="L993">    <span class="tok-kw">var</span> result: LARGE_INTEGER = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L994">    <span class="tok-kw">if</span> (kernel32.SetFilePointerEx(handle, <span class="tok-number">0</span>, &amp;result, FILE_CURRENT) == <span class="tok-number">0</span>) {</span>
<span class="line" id="L995">        <span class="tok-kw">switch</span> (kernel32.GetLastError()) {</span>
<span class="line" id="L996">            .INVALID_PARAMETER =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L997">            .INVALID_HANDLE =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L998">            <span class="tok-kw">else</span> =&gt; |err| <span class="tok-kw">return</span> unexpectedError(err),</span>
<span class="line" id="L999">        }</span>
<span class="line" id="L1000">    }</span>
<span class="line" id="L1001">    <span class="tok-comment">// Based on the docs for FILE_BEGIN, it seems that the returned signed integer</span>
</span>
<span class="line" id="L1002">    <span class="tok-comment">// should be interpreted as an unsigned integer.</span>
</span>
<span class="line" id="L1003">    <span class="tok-kw">return</span> <span class="tok-builtin">@bitCast</span>(<span class="tok-type">u64</span>, result);</span>
<span class="line" id="L1004">}</span>
<span class="line" id="L1005"></span>
<span class="line" id="L1006"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">QueryObjectName</span>(</span>
<span class="line" id="L1007">    handle: HANDLE,</span>
<span class="line" id="L1008">    out_buffer: []<span class="tok-type">u16</span>,</span>
<span class="line" id="L1009">) ![]<span class="tok-type">u16</span> {</span>
<span class="line" id="L1010">    <span class="tok-kw">const</span> out_buffer_aligned = mem.alignInSlice(out_buffer, <span class="tok-builtin">@alignOf</span>(OBJECT_NAME_INFORMATION)) <span class="tok-kw">orelse</span> <span class="tok-kw">return</span> <span class="tok-kw">error</span>.NameTooLong;</span>
<span class="line" id="L1011"></span>
<span class="line" id="L1012">    <span class="tok-kw">const</span> info = <span class="tok-builtin">@ptrCast</span>(*OBJECT_NAME_INFORMATION, out_buffer_aligned);</span>
<span class="line" id="L1013">    <span class="tok-comment">//buffer size is specified in bytes</span>
</span>
<span class="line" id="L1014">    <span class="tok-kw">const</span> out_buffer_len = std.math.cast(ULONG, out_buffer_aligned.len * <span class="tok-number">2</span>) <span class="tok-kw">orelse</span> std.math.maxInt(ULONG);</span>
<span class="line" id="L1015">    <span class="tok-comment">//last argument would return the length required for full_buffer, not exposed here</span>
</span>
<span class="line" id="L1016">    <span class="tok-kw">const</span> rc = ntdll.NtQueryObject(handle, .ObjectNameInformation, info, out_buffer_len, <span class="tok-null">null</span>);</span>
<span class="line" id="L1017">    <span class="tok-kw">switch</span> (rc) {</span>
<span class="line" id="L1018">        .SUCCESS =&gt; {</span>
<span class="line" id="L1019">            <span class="tok-comment">// info.Name.Buffer from ObQueryNameString is documented to be null (and MaximumLength == 0)</span>
</span>
<span class="line" id="L1020">            <span class="tok-comment">// if the object was &quot;unnamed&quot;, not sure if this can happen for file handles</span>
</span>
<span class="line" id="L1021">            <span class="tok-kw">if</span> (info.Name.MaximumLength == <span class="tok-number">0</span>) <span class="tok-kw">return</span> <span class="tok-kw">error</span>.Unexpected;</span>
<span class="line" id="L1022">            <span class="tok-comment">// resulting string length is specified in bytes</span>
</span>
<span class="line" id="L1023">            <span class="tok-kw">const</span> path_length_unterminated = <span class="tok-builtin">@divExact</span>(info.Name.Length, <span class="tok-number">2</span>);</span>
<span class="line" id="L1024">            <span class="tok-kw">return</span> info.Name.Buffer[<span class="tok-number">0</span>..path_length_unterminated];</span>
<span class="line" id="L1025">        },</span>
<span class="line" id="L1026">        .ACCESS_DENIED =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.AccessDenied,</span>
<span class="line" id="L1027">        .INVALID_HANDLE =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InvalidHandle,</span>
<span class="line" id="L1028">        <span class="tok-comment">// triggered when the buffer is too small for the OBJECT_NAME_INFORMATION object (.INFO_LENGTH_MISMATCH),</span>
</span>
<span class="line" id="L1029">        <span class="tok-comment">// or if the buffer is too small for the file path returned (.BUFFER_OVERFLOW, .BUFFER_TOO_SMALL)</span>
</span>
<span class="line" id="L1030">        .INFO_LENGTH_MISMATCH, .BUFFER_OVERFLOW, .BUFFER_TOO_SMALL =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.NameTooLong,</span>
<span class="line" id="L1031">        <span class="tok-kw">else</span> =&gt; |e| <span class="tok-kw">return</span> unexpectedStatus(e),</span>
<span class="line" id="L1032">    }</span>
<span class="line" id="L1033">}</span>
<span class="line" id="L1034"><span class="tok-kw">test</span> <span class="tok-str">&quot;QueryObjectName&quot;</span> {</span>
<span class="line" id="L1035">    <span class="tok-kw">if</span> (builtin.os.tag != .windows)</span>
<span class="line" id="L1036">        <span class="tok-kw">return</span>;</span>
<span class="line" id="L1037"></span>
<span class="line" id="L1038">    <span class="tok-comment">//any file will do; canonicalization works on NTFS junctions and symlinks, hardlinks remain separate paths.</span>
</span>
<span class="line" id="L1039">    <span class="tok-kw">var</span> tmp = std.testing.tmpDir(.{});</span>
<span class="line" id="L1040">    <span class="tok-kw">defer</span> tmp.cleanup();</span>
<span class="line" id="L1041">    <span class="tok-kw">const</span> handle = tmp.dir.fd;</span>
<span class="line" id="L1042">    <span class="tok-kw">var</span> out_buffer: [PATH_MAX_WIDE]<span class="tok-type">u16</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L1043"></span>
<span class="line" id="L1044">    <span class="tok-kw">var</span> result_path = <span class="tok-kw">try</span> QueryObjectName(handle, &amp;out_buffer);</span>
<span class="line" id="L1045">    <span class="tok-kw">const</span> required_len_in_u16 = result_path.len + <span class="tok-builtin">@divExact</span>(<span class="tok-builtin">@ptrToInt</span>(result_path.ptr) - <span class="tok-builtin">@ptrToInt</span>(&amp;out_buffer), <span class="tok-number">2</span>) + <span class="tok-number">1</span>;</span>
<span class="line" id="L1046">    <span class="tok-comment">//insufficient size</span>
</span>
<span class="line" id="L1047">    <span class="tok-kw">try</span> std.testing.expectError(<span class="tok-kw">error</span>.NameTooLong, QueryObjectName(handle, out_buffer[<span class="tok-number">0</span> .. required_len_in_u16 - <span class="tok-number">1</span>]));</span>
<span class="line" id="L1048">    <span class="tok-comment">//exactly-sufficient size</span>
</span>
<span class="line" id="L1049">    _ = <span class="tok-kw">try</span> QueryObjectName(handle, out_buffer[<span class="tok-number">0</span>..required_len_in_u16]);</span>
<span class="line" id="L1050">}</span>
<span class="line" id="L1051"></span>
<span class="line" id="L1052"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> GetFinalPathNameByHandleError = <span class="tok-kw">error</span>{</span>
<span class="line" id="L1053">    AccessDenied,</span>
<span class="line" id="L1054">    BadPathName,</span>
<span class="line" id="L1055">    FileNotFound,</span>
<span class="line" id="L1056">    NameTooLong,</span>
<span class="line" id="L1057">    Unexpected,</span>
<span class="line" id="L1058">};</span>
<span class="line" id="L1059"></span>
<span class="line" id="L1060"><span class="tok-comment">/// Specifies how to format volume path in the result of `GetFinalPathNameByHandle`.</span></span>
<span class="line" id="L1061"><span class="tok-comment">/// Defaults to DOS volume names.</span></span>
<span class="line" id="L1062"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> GetFinalPathNameByHandleFormat = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L1063">    volume_name: <span class="tok-kw">enum</span> {</span>
<span class="line" id="L1064">        <span class="tok-comment">/// Format as DOS volume name</span></span>
<span class="line" id="L1065">        Dos,</span>
<span class="line" id="L1066">        <span class="tok-comment">/// Format as NT volume name</span></span>
<span class="line" id="L1067">        Nt,</span>
<span class="line" id="L1068">    } = .Dos,</span>
<span class="line" id="L1069">};</span>
<span class="line" id="L1070"></span>
<span class="line" id="L1071"><span class="tok-comment">/// Returns canonical (normalized) path of handle.</span></span>
<span class="line" id="L1072"><span class="tok-comment">/// Use `GetFinalPathNameByHandleFormat` to specify whether the path is meant to include</span></span>
<span class="line" id="L1073"><span class="tok-comment">/// NT or DOS volume name (e.g., `\Device\HarddiskVolume0\foo.txt` versus `C:\foo.txt`).</span></span>
<span class="line" id="L1074"><span class="tok-comment">/// If DOS volume name format is selected, note that this function does *not* prepend</span></span>
<span class="line" id="L1075"><span class="tok-comment">/// `\\?\` prefix to the resultant path.</span></span>
<span class="line" id="L1076"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">GetFinalPathNameByHandle</span>(</span>
<span class="line" id="L1077">    hFile: HANDLE,</span>
<span class="line" id="L1078">    fmt: GetFinalPathNameByHandleFormat,</span>
<span class="line" id="L1079">    out_buffer: []<span class="tok-type">u16</span>,</span>
<span class="line" id="L1080">) GetFinalPathNameByHandleError![]<span class="tok-type">u16</span> {</span>
<span class="line" id="L1081">    <span class="tok-kw">const</span> final_path = QueryObjectName(hFile, out_buffer) <span class="tok-kw">catch</span> |err| <span class="tok-kw">switch</span> (err) {</span>
<span class="line" id="L1082">        <span class="tok-comment">// we assume InvalidHandle is close enough to FileNotFound in semantics</span>
</span>
<span class="line" id="L1083">        <span class="tok-comment">// to not further complicate the error set</span>
</span>
<span class="line" id="L1084">        <span class="tok-kw">error</span>.InvalidHandle =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.FileNotFound,</span>
<span class="line" id="L1085">        <span class="tok-kw">else</span> =&gt; |e| <span class="tok-kw">return</span> e,</span>
<span class="line" id="L1086">    };</span>
<span class="line" id="L1087"></span>
<span class="line" id="L1088">    <span class="tok-kw">switch</span> (fmt.volume_name) {</span>
<span class="line" id="L1089">        .Nt =&gt; {</span>
<span class="line" id="L1090">            <span class="tok-comment">// the returned path is already in .Nt format</span>
</span>
<span class="line" id="L1091">            <span class="tok-kw">return</span> final_path;</span>
<span class="line" id="L1092">        },</span>
<span class="line" id="L1093">        .Dos =&gt; {</span>
<span class="line" id="L1094">            <span class="tok-comment">// parse the string to separate volume path from file path</span>
</span>
<span class="line" id="L1095">            <span class="tok-kw">const</span> expected_prefix = std.unicode.utf8ToUtf16LeStringLiteral(<span class="tok-str">&quot;\\Device\\&quot;</span>);</span>
<span class="line" id="L1096"></span>
<span class="line" id="L1097">            <span class="tok-comment">// TODO find out if a path can start with something besides `\Device\&lt;volume name&gt;`,</span>
</span>
<span class="line" id="L1098">            <span class="tok-comment">// and if we need to handle it differently</span>
</span>
<span class="line" id="L1099">            <span class="tok-comment">// (i.e. how to determine the start and end of the volume name in that case)</span>
</span>
<span class="line" id="L1100">            <span class="tok-kw">if</span> (!mem.eql(<span class="tok-type">u16</span>, expected_prefix, final_path[<span class="tok-number">0</span>..expected_prefix.len])) <span class="tok-kw">return</span> <span class="tok-kw">error</span>.Unexpected;</span>
<span class="line" id="L1101"></span>
<span class="line" id="L1102">            <span class="tok-kw">const</span> file_path_begin_index = mem.indexOfPos(<span class="tok-type">u16</span>, final_path, expected_prefix.len, &amp;[_]<span class="tok-type">u16</span>{<span class="tok-str">'\\'</span>}) <span class="tok-kw">orelse</span> <span class="tok-kw">unreachable</span>;</span>
<span class="line" id="L1103">            <span class="tok-kw">const</span> volume_name_u16 = final_path[<span class="tok-number">0</span>..file_path_begin_index];</span>
<span class="line" id="L1104">            <span class="tok-kw">const</span> file_name_u16 = final_path[file_path_begin_index..];</span>
<span class="line" id="L1105"></span>
<span class="line" id="L1106">            <span class="tok-comment">// Get DOS volume name. DOS volume names are actually symbolic link objects to the</span>
</span>
<span class="line" id="L1107">            <span class="tok-comment">// actual NT volume. For example:</span>
</span>
<span class="line" id="L1108">            <span class="tok-comment">// (NT) \Device\HarddiskVolume4 =&gt; (DOS) \DosDevices\C: == (DOS) C:</span>
</span>
<span class="line" id="L1109">            <span class="tok-kw">const</span> MIN_SIZE = <span class="tok-builtin">@sizeOf</span>(MOUNTMGR_MOUNT_POINT) + MAX_PATH;</span>
<span class="line" id="L1110">            <span class="tok-comment">// We initialize the input buffer to all zeros for convenience since</span>
</span>
<span class="line" id="L1111">            <span class="tok-comment">// `DeviceIoControl` with `IOCTL_MOUNTMGR_QUERY_POINTS` expects this.</span>
</span>
<span class="line" id="L1112">            <span class="tok-kw">var</span> input_buf: [MIN_SIZE]<span class="tok-type">u8</span> <span class="tok-kw">align</span>(<span class="tok-builtin">@alignOf</span>(MOUNTMGR_MOUNT_POINT)) = [_]<span class="tok-type">u8</span>{<span class="tok-number">0</span>} ** MIN_SIZE;</span>
<span class="line" id="L1113">            <span class="tok-kw">var</span> output_buf: [MIN_SIZE * <span class="tok-number">4</span>]<span class="tok-type">u8</span> <span class="tok-kw">align</span>(<span class="tok-builtin">@alignOf</span>(MOUNTMGR_MOUNT_POINTS)) = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L1114"></span>
<span class="line" id="L1115">            <span class="tok-comment">// This surprising path is a filesystem path to the mount manager on Windows.</span>
</span>
<span class="line" id="L1116">            <span class="tok-comment">// Source: https://stackoverflow.com/questions/3012828/using-ioctl-mountmgr-query-points</span>
</span>
<span class="line" id="L1117">            <span class="tok-kw">const</span> mgmt_path = <span class="tok-str">&quot;\\MountPointManager&quot;</span>;</span>
<span class="line" id="L1118">            <span class="tok-kw">const</span> mgmt_path_u16 = sliceToPrefixedFileW(mgmt_path) <span class="tok-kw">catch</span> <span class="tok-kw">unreachable</span>;</span>
<span class="line" id="L1119">            <span class="tok-kw">const</span> mgmt_handle = OpenFile(mgmt_path_u16.span(), .{</span>
<span class="line" id="L1120">                .access_mask = SYNCHRONIZE,</span>
<span class="line" id="L1121">                .share_access = FILE_SHARE_READ | FILE_SHARE_WRITE,</span>
<span class="line" id="L1122">                .creation = FILE_OPEN,</span>
<span class="line" id="L1123">                .io_mode = .blocking,</span>
<span class="line" id="L1124">            }) <span class="tok-kw">catch</span> |err| <span class="tok-kw">switch</span> (err) {</span>
<span class="line" id="L1125">                <span class="tok-kw">error</span>.IsDir =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L1126">                <span class="tok-kw">error</span>.NotDir =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L1127">                <span class="tok-kw">error</span>.NoDevice =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L1128">                <span class="tok-kw">error</span>.AccessDenied =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L1129">                <span class="tok-kw">error</span>.PipeBusy =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L1130">                <span class="tok-kw">error</span>.PathAlreadyExists =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L1131">                <span class="tok-kw">error</span>.WouldBlock =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L1132">                <span class="tok-kw">else</span> =&gt; |e| <span class="tok-kw">return</span> e,</span>
<span class="line" id="L1133">            };</span>
<span class="line" id="L1134">            <span class="tok-kw">defer</span> CloseHandle(mgmt_handle);</span>
<span class="line" id="L1135"></span>
<span class="line" id="L1136">            <span class="tok-kw">var</span> input_struct = <span class="tok-builtin">@ptrCast</span>(*MOUNTMGR_MOUNT_POINT, &amp;input_buf[<span class="tok-number">0</span>]);</span>
<span class="line" id="L1137">            input_struct.DeviceNameOffset = <span class="tok-builtin">@sizeOf</span>(MOUNTMGR_MOUNT_POINT);</span>
<span class="line" id="L1138">            input_struct.DeviceNameLength = <span class="tok-builtin">@intCast</span>(USHORT, volume_name_u16.len * <span class="tok-number">2</span>);</span>
<span class="line" id="L1139">            <span class="tok-builtin">@memcpy</span>(input_buf[<span class="tok-builtin">@sizeOf</span>(MOUNTMGR_MOUNT_POINT)..], <span class="tok-builtin">@ptrCast</span>([*]<span class="tok-kw">const</span> <span class="tok-type">u8</span>, volume_name_u16.ptr), volume_name_u16.len * <span class="tok-number">2</span>);</span>
<span class="line" id="L1140"></span>
<span class="line" id="L1141">            DeviceIoControl(mgmt_handle, IOCTL_MOUNTMGR_QUERY_POINTS, &amp;input_buf, &amp;output_buf) <span class="tok-kw">catch</span> |err| <span class="tok-kw">switch</span> (err) {</span>
<span class="line" id="L1142">                <span class="tok-kw">error</span>.AccessDenied =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L1143">                <span class="tok-kw">else</span> =&gt; |e| <span class="tok-kw">return</span> e,</span>
<span class="line" id="L1144">            };</span>
<span class="line" id="L1145">            <span class="tok-kw">const</span> mount_points_struct = <span class="tok-builtin">@ptrCast</span>(*<span class="tok-kw">const</span> MOUNTMGR_MOUNT_POINTS, &amp;output_buf[<span class="tok-number">0</span>]);</span>
<span class="line" id="L1146"></span>
<span class="line" id="L1147">            <span class="tok-kw">const</span> mount_points = <span class="tok-builtin">@ptrCast</span>(</span>
<span class="line" id="L1148">                [*]<span class="tok-kw">const</span> MOUNTMGR_MOUNT_POINT,</span>
<span class="line" id="L1149">                &amp;mount_points_struct.MountPoints[<span class="tok-number">0</span>],</span>
<span class="line" id="L1150">            )[<span class="tok-number">0</span>..mount_points_struct.NumberOfMountPoints];</span>
<span class="line" id="L1151"></span>
<span class="line" id="L1152">            <span class="tok-kw">for</span> (mount_points) |mount_point| {</span>
<span class="line" id="L1153">                <span class="tok-kw">const</span> symlink = <span class="tok-builtin">@ptrCast</span>(</span>
<span class="line" id="L1154">                    [*]<span class="tok-kw">const</span> <span class="tok-type">u16</span>,</span>
<span class="line" id="L1155">                    <span class="tok-builtin">@alignCast</span>(<span class="tok-builtin">@alignOf</span>(<span class="tok-type">u16</span>), &amp;output_buf[mount_point.SymbolicLinkNameOffset]),</span>
<span class="line" id="L1156">                )[<span class="tok-number">0</span> .. mount_point.SymbolicLinkNameLength / <span class="tok-number">2</span>];</span>
<span class="line" id="L1157"></span>
<span class="line" id="L1158">                <span class="tok-comment">// Look for `\DosDevices\` prefix. We don't really care if there are more than one symlinks</span>
</span>
<span class="line" id="L1159">                <span class="tok-comment">// with traditional DOS drive letters, so pick the first one available.</span>
</span>
<span class="line" id="L1160">                <span class="tok-kw">var</span> prefix_buf = std.unicode.utf8ToUtf16LeStringLiteral(<span class="tok-str">&quot;\\DosDevices\\&quot;</span>);</span>
<span class="line" id="L1161">                <span class="tok-kw">const</span> prefix = prefix_buf[<span class="tok-number">0</span>..prefix_buf.len];</span>
<span class="line" id="L1162"></span>
<span class="line" id="L1163">                <span class="tok-kw">if</span> (mem.startsWith(<span class="tok-type">u16</span>, symlink, prefix)) {</span>
<span class="line" id="L1164">                    <span class="tok-kw">const</span> drive_letter = symlink[prefix.len..];</span>
<span class="line" id="L1165"></span>
<span class="line" id="L1166">                    <span class="tok-kw">if</span> (out_buffer.len &lt; drive_letter.len + file_name_u16.len) <span class="tok-kw">return</span> <span class="tok-kw">error</span>.NameTooLong;</span>
<span class="line" id="L1167"></span>
<span class="line" id="L1168">                    mem.copy(<span class="tok-type">u16</span>, out_buffer, drive_letter);</span>
<span class="line" id="L1169">                    mem.copy(<span class="tok-type">u16</span>, out_buffer[drive_letter.len..], file_name_u16);</span>
<span class="line" id="L1170">                    <span class="tok-kw">const</span> total_len = drive_letter.len + file_name_u16.len;</span>
<span class="line" id="L1171"></span>
<span class="line" id="L1172">                    <span class="tok-comment">// Validate that DOS does not contain any spurious nul bytes.</span>
</span>
<span class="line" id="L1173">                    <span class="tok-kw">if</span> (mem.indexOfScalar(<span class="tok-type">u16</span>, out_buffer[<span class="tok-number">0</span>..total_len], <span class="tok-number">0</span>)) |_| {</span>
<span class="line" id="L1174">                        <span class="tok-kw">return</span> <span class="tok-kw">error</span>.BadPathName;</span>
<span class="line" id="L1175">                    }</span>
<span class="line" id="L1176"></span>
<span class="line" id="L1177">                    <span class="tok-kw">return</span> out_buffer[<span class="tok-number">0</span>..total_len];</span>
<span class="line" id="L1178">                }</span>
<span class="line" id="L1179">            }</span>
<span class="line" id="L1180"></span>
<span class="line" id="L1181">            <span class="tok-comment">// If we've ended up here, then something went wrong/is corrupted in the OS,</span>
</span>
<span class="line" id="L1182">            <span class="tok-comment">// so error out!</span>
</span>
<span class="line" id="L1183">            <span class="tok-kw">return</span> <span class="tok-kw">error</span>.FileNotFound;</span>
<span class="line" id="L1184">        },</span>
<span class="line" id="L1185">    }</span>
<span class="line" id="L1186">}</span>
<span class="line" id="L1187"></span>
<span class="line" id="L1188"><span class="tok-kw">test</span> <span class="tok-str">&quot;GetFinalPathNameByHandle&quot;</span> {</span>
<span class="line" id="L1189">    <span class="tok-kw">if</span> (builtin.os.tag != .windows)</span>
<span class="line" id="L1190">        <span class="tok-kw">return</span>;</span>
<span class="line" id="L1191"></span>
<span class="line" id="L1192">    <span class="tok-comment">//any file will do</span>
</span>
<span class="line" id="L1193">    <span class="tok-kw">var</span> tmp = std.testing.tmpDir(.{});</span>
<span class="line" id="L1194">    <span class="tok-kw">defer</span> tmp.cleanup();</span>
<span class="line" id="L1195">    <span class="tok-kw">const</span> handle = tmp.dir.fd;</span>
<span class="line" id="L1196">    <span class="tok-kw">var</span> buffer: [PATH_MAX_WIDE]<span class="tok-type">u16</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L1197"></span>
<span class="line" id="L1198">    <span class="tok-comment">//check with sufficient size</span>
</span>
<span class="line" id="L1199">    <span class="tok-kw">const</span> nt_path = <span class="tok-kw">try</span> GetFinalPathNameByHandle(handle, .{ .volume_name = .Nt }, &amp;buffer);</span>
<span class="line" id="L1200">    _ = <span class="tok-kw">try</span> GetFinalPathNameByHandle(handle, .{ .volume_name = .Dos }, &amp;buffer);</span>
<span class="line" id="L1201"></span>
<span class="line" id="L1202">    <span class="tok-kw">const</span> required_len_in_u16 = nt_path.len + <span class="tok-builtin">@divExact</span>(<span class="tok-builtin">@ptrToInt</span>(nt_path.ptr) - <span class="tok-builtin">@ptrToInt</span>(&amp;buffer), <span class="tok-number">2</span>) + <span class="tok-number">1</span>;</span>
<span class="line" id="L1203">    <span class="tok-comment">//check with insufficient size</span>
</span>
<span class="line" id="L1204">    <span class="tok-kw">try</span> std.testing.expectError(<span class="tok-kw">error</span>.NameTooLong, GetFinalPathNameByHandle(handle, .{ .volume_name = .Nt }, buffer[<span class="tok-number">0</span> .. required_len_in_u16 - <span class="tok-number">1</span>]));</span>
<span class="line" id="L1205">    <span class="tok-kw">try</span> std.testing.expectError(<span class="tok-kw">error</span>.NameTooLong, GetFinalPathNameByHandle(handle, .{ .volume_name = .Dos }, buffer[<span class="tok-number">0</span> .. required_len_in_u16 - <span class="tok-number">1</span>]));</span>
<span class="line" id="L1206"></span>
<span class="line" id="L1207">    <span class="tok-comment">//check with exactly-sufficient size</span>
</span>
<span class="line" id="L1208">    _ = <span class="tok-kw">try</span> GetFinalPathNameByHandle(handle, .{ .volume_name = .Nt }, buffer[<span class="tok-number">0</span>..required_len_in_u16]);</span>
<span class="line" id="L1209">    _ = <span class="tok-kw">try</span> GetFinalPathNameByHandle(handle, .{ .volume_name = .Dos }, buffer[<span class="tok-number">0</span>..required_len_in_u16]);</span>
<span class="line" id="L1210">}</span>
<span class="line" id="L1211"></span>
<span class="line" id="L1212"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> QueryInformationFileError = <span class="tok-kw">error</span>{Unexpected};</span>
<span class="line" id="L1213"></span>
<span class="line" id="L1214"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">QueryInformationFile</span>(</span>
<span class="line" id="L1215">    handle: HANDLE,</span>
<span class="line" id="L1216">    info_class: FILE_INFORMATION_CLASS,</span>
<span class="line" id="L1217">    out_buffer: []<span class="tok-type">u8</span>,</span>
<span class="line" id="L1218">) QueryInformationFileError!<span class="tok-type">void</span> {</span>
<span class="line" id="L1219">    <span class="tok-kw">var</span> io: IO_STATUS_BLOCK = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L1220">    <span class="tok-kw">const</span> len_bytes = std.math.cast(<span class="tok-type">u32</span>, out_buffer.len) <span class="tok-kw">orelse</span> <span class="tok-kw">unreachable</span>;</span>
<span class="line" id="L1221">    <span class="tok-kw">const</span> rc = ntdll.NtQueryInformationFile(handle, &amp;io, out_buffer.ptr, len_bytes, info_class);</span>
<span class="line" id="L1222">    <span class="tok-kw">switch</span> (rc) {</span>
<span class="line" id="L1223">        .SUCCESS =&gt; {},</span>
<span class="line" id="L1224">        .INVALID_PARAMETER =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L1225">        <span class="tok-kw">else</span> =&gt; <span class="tok-kw">return</span> unexpectedStatus(rc),</span>
<span class="line" id="L1226">    }</span>
<span class="line" id="L1227">}</span>
<span class="line" id="L1228"></span>
<span class="line" id="L1229"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> GetFileSizeError = <span class="tok-kw">error</span>{Unexpected};</span>
<span class="line" id="L1230"></span>
<span class="line" id="L1231"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">GetFileSizeEx</span>(hFile: HANDLE) GetFileSizeError!<span class="tok-type">u64</span> {</span>
<span class="line" id="L1232">    <span class="tok-kw">var</span> file_size: LARGE_INTEGER = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L1233">    <span class="tok-kw">if</span> (kernel32.GetFileSizeEx(hFile, &amp;file_size) == <span class="tok-number">0</span>) {</span>
<span class="line" id="L1234">        <span class="tok-kw">switch</span> (kernel32.GetLastError()) {</span>
<span class="line" id="L1235">            <span class="tok-kw">else</span> =&gt; |err| <span class="tok-kw">return</span> unexpectedError(err),</span>
<span class="line" id="L1236">        }</span>
<span class="line" id="L1237">    }</span>
<span class="line" id="L1238">    <span class="tok-kw">return</span> <span class="tok-builtin">@bitCast</span>(<span class="tok-type">u64</span>, file_size);</span>
<span class="line" id="L1239">}</span>
<span class="line" id="L1240"></span>
<span class="line" id="L1241"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> GetFileAttributesError = <span class="tok-kw">error</span>{</span>
<span class="line" id="L1242">    FileNotFound,</span>
<span class="line" id="L1243">    PermissionDenied,</span>
<span class="line" id="L1244">    Unexpected,</span>
<span class="line" id="L1245">};</span>
<span class="line" id="L1246"></span>
<span class="line" id="L1247"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">GetFileAttributes</span>(filename: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) GetFileAttributesError!DWORD {</span>
<span class="line" id="L1248">    <span class="tok-kw">const</span> filename_w = <span class="tok-kw">try</span> sliceToPrefixedFileW(filename);</span>
<span class="line" id="L1249">    <span class="tok-kw">return</span> GetFileAttributesW(filename_w.span().ptr);</span>
<span class="line" id="L1250">}</span>
<span class="line" id="L1251"></span>
<span class="line" id="L1252"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">GetFileAttributesW</span>(lpFileName: [*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u16</span>) GetFileAttributesError!DWORD {</span>
<span class="line" id="L1253">    <span class="tok-kw">const</span> rc = kernel32.GetFileAttributesW(lpFileName);</span>
<span class="line" id="L1254">    <span class="tok-kw">if</span> (rc == INVALID_FILE_ATTRIBUTES) {</span>
<span class="line" id="L1255">        <span class="tok-kw">switch</span> (kernel32.GetLastError()) {</span>
<span class="line" id="L1256">            .FILE_NOT_FOUND =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.FileNotFound,</span>
<span class="line" id="L1257">            .PATH_NOT_FOUND =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.FileNotFound,</span>
<span class="line" id="L1258">            .ACCESS_DENIED =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.PermissionDenied,</span>
<span class="line" id="L1259">            <span class="tok-kw">else</span> =&gt; |err| <span class="tok-kw">return</span> unexpectedError(err),</span>
<span class="line" id="L1260">        }</span>
<span class="line" id="L1261">    }</span>
<span class="line" id="L1262">    <span class="tok-kw">return</span> rc;</span>
<span class="line" id="L1263">}</span>
<span class="line" id="L1264"></span>
<span class="line" id="L1265"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">WSAStartup</span>(majorVersion: <span class="tok-type">u8</span>, minorVersion: <span class="tok-type">u8</span>) !ws2_32.WSADATA {</span>
<span class="line" id="L1266">    <span class="tok-kw">var</span> wsadata: ws2_32.WSADATA = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L1267">    <span class="tok-kw">return</span> <span class="tok-kw">switch</span> (ws2_32.WSAStartup((<span class="tok-builtin">@as</span>(WORD, minorVersion) &lt;&lt; <span class="tok-number">8</span>) | majorVersion, &amp;wsadata)) {</span>
<span class="line" id="L1268">        <span class="tok-number">0</span> =&gt; wsadata,</span>
<span class="line" id="L1269">        <span class="tok-kw">else</span> =&gt; |err_int| <span class="tok-kw">switch</span> (<span class="tok-builtin">@intToEnum</span>(ws2_32.WinsockError, <span class="tok-builtin">@intCast</span>(<span class="tok-type">u16</span>, err_int))) {</span>
<span class="line" id="L1270">            .WSASYSNOTREADY =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SystemNotAvailable,</span>
<span class="line" id="L1271">            .WSAVERNOTSUPPORTED =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.VersionNotSupported,</span>
<span class="line" id="L1272">            .WSAEINPROGRESS =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.BlockingOperationInProgress,</span>
<span class="line" id="L1273">            .WSAEPROCLIM =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.ProcessFdQuotaExceeded,</span>
<span class="line" id="L1274">            <span class="tok-kw">else</span> =&gt; |err| <span class="tok-kw">return</span> unexpectedWSAError(err),</span>
<span class="line" id="L1275">        },</span>
<span class="line" id="L1276">    };</span>
<span class="line" id="L1277">}</span>
<span class="line" id="L1278"></span>
<span class="line" id="L1279"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">WSACleanup</span>() !<span class="tok-type">void</span> {</span>
<span class="line" id="L1280">    <span class="tok-kw">return</span> <span class="tok-kw">switch</span> (ws2_32.WSACleanup()) {</span>
<span class="line" id="L1281">        <span class="tok-number">0</span> =&gt; {},</span>
<span class="line" id="L1282">        ws2_32.SOCKET_ERROR =&gt; <span class="tok-kw">switch</span> (ws2_32.WSAGetLastError()) {</span>
<span class="line" id="L1283">            .WSANOTINITIALISED =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.NotInitialized,</span>
<span class="line" id="L1284">            .WSAENETDOWN =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.NetworkNotAvailable,</span>
<span class="line" id="L1285">            .WSAEINPROGRESS =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.BlockingOperationInProgress,</span>
<span class="line" id="L1286">            <span class="tok-kw">else</span> =&gt; |err| <span class="tok-kw">return</span> unexpectedWSAError(err),</span>
<span class="line" id="L1287">        },</span>
<span class="line" id="L1288">        <span class="tok-kw">else</span> =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L1289">    };</span>
<span class="line" id="L1290">}</span>
<span class="line" id="L1291"></span>
<span class="line" id="L1292"><span class="tok-kw">var</span> wsa_startup_mutex: std.Thread.Mutex = .{};</span>
<span class="line" id="L1293"></span>
<span class="line" id="L1294"><span class="tok-comment">/// Microsoft requires WSAStartup to be called to initialize, or else</span></span>
<span class="line" id="L1295"><span class="tok-comment">/// WSASocketW will return WSANOTINITIALISED.</span></span>
<span class="line" id="L1296"><span class="tok-comment">/// Since this is a standard library, we do not have the luxury of</span></span>
<span class="line" id="L1297"><span class="tok-comment">/// putting initialization code anywhere, because we would not want</span></span>
<span class="line" id="L1298"><span class="tok-comment">/// to pay the cost of calling WSAStartup if there ended up being no</span></span>
<span class="line" id="L1299"><span class="tok-comment">/// networking. Also, if Zig code is used as a library, Zig is not in</span></span>
<span class="line" id="L1300"><span class="tok-comment">/// charge of the start code, and we couldn't put in any initialization</span></span>
<span class="line" id="L1301"><span class="tok-comment">/// code even if we wanted to.</span></span>
<span class="line" id="L1302"><span class="tok-comment">/// The documentation for WSAStartup mentions that there must be a</span></span>
<span class="line" id="L1303"><span class="tok-comment">/// matching WSACleanup call. It is not possible for the Zig Standard</span></span>
<span class="line" id="L1304"><span class="tok-comment">/// Library to honor this for the same reason - there is nowhere to put</span></span>
<span class="line" id="L1305"><span class="tok-comment">/// deinitialization code.</span></span>
<span class="line" id="L1306"><span class="tok-comment">/// So, API users of the zig std lib have two options:</span></span>
<span class="line" id="L1307"><span class="tok-comment">///  * (recommended) The simple, cross-platform way: just call `WSASocketW`</span></span>
<span class="line" id="L1308"><span class="tok-comment">///    and don't worry about it. Zig will call WSAStartup() in a thread-safe</span></span>
<span class="line" id="L1309"><span class="tok-comment">///    manner and never deinitialize networking. This is ideal for an</span></span>
<span class="line" id="L1310"><span class="tok-comment">///    application which has the capability to do networking.</span></span>
<span class="line" id="L1311"><span class="tok-comment">///  * The getting-your-hands-dirty way: call `WSAStartup()` before doing</span></span>
<span class="line" id="L1312"><span class="tok-comment">///    networking, so that the error handling code for WSANOTINITIALISED never</span></span>
<span class="line" id="L1313"><span class="tok-comment">///    gets run, which then allows the application or library to call `WSACleanup()`.</span></span>
<span class="line" id="L1314"><span class="tok-comment">///    This could make sense for a library, which has init and deinit</span></span>
<span class="line" id="L1315"><span class="tok-comment">///    functions for the whole library's lifetime.</span></span>
<span class="line" id="L1316"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">WSASocketW</span>(</span>
<span class="line" id="L1317">    af: <span class="tok-type">i32</span>,</span>
<span class="line" id="L1318">    socket_type: <span class="tok-type">i32</span>,</span>
<span class="line" id="L1319">    protocol: <span class="tok-type">i32</span>,</span>
<span class="line" id="L1320">    protocolInfo: ?*ws2_32.WSAPROTOCOL_INFOW,</span>
<span class="line" id="L1321">    g: ws2_32.GROUP,</span>
<span class="line" id="L1322">    dwFlags: DWORD,</span>
<span class="line" id="L1323">) !ws2_32.SOCKET {</span>
<span class="line" id="L1324">    <span class="tok-kw">var</span> first = <span class="tok-null">true</span>;</span>
<span class="line" id="L1325">    <span class="tok-kw">while</span> (<span class="tok-null">true</span>) {</span>
<span class="line" id="L1326">        <span class="tok-kw">const</span> rc = ws2_32.WSASocketW(af, socket_type, protocol, protocolInfo, g, dwFlags);</span>
<span class="line" id="L1327">        <span class="tok-kw">if</span> (rc == ws2_32.INVALID_SOCKET) {</span>
<span class="line" id="L1328">            <span class="tok-kw">switch</span> (ws2_32.WSAGetLastError()) {</span>
<span class="line" id="L1329">                .WSAEAFNOSUPPORT =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.AddressFamilyNotSupported,</span>
<span class="line" id="L1330">                .WSAEMFILE =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.ProcessFdQuotaExceeded,</span>
<span class="line" id="L1331">                .WSAENOBUFS =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SystemResources,</span>
<span class="line" id="L1332">                .WSAEPROTONOSUPPORT =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.ProtocolNotSupported,</span>
<span class="line" id="L1333">                .WSANOTINITIALISED =&gt; {</span>
<span class="line" id="L1334">                    <span class="tok-kw">if</span> (!first) <span class="tok-kw">return</span> <span class="tok-kw">error</span>.Unexpected;</span>
<span class="line" id="L1335">                    first = <span class="tok-null">false</span>;</span>
<span class="line" id="L1336"></span>
<span class="line" id="L1337">                    wsa_startup_mutex.lock();</span>
<span class="line" id="L1338">                    <span class="tok-kw">defer</span> wsa_startup_mutex.unlock();</span>
<span class="line" id="L1339"></span>
<span class="line" id="L1340">                    <span class="tok-comment">// Here we could use a flag to prevent multiple threads to prevent</span>
</span>
<span class="line" id="L1341">                    <span class="tok-comment">// multiple calls to WSAStartup, but it doesn't matter. We're globally</span>
</span>
<span class="line" id="L1342">                    <span class="tok-comment">// leaking the resource intentionally, and the mutex already prevents</span>
</span>
<span class="line" id="L1343">                    <span class="tok-comment">// data races within the WSAStartup function.</span>
</span>
<span class="line" id="L1344">                    _ = WSAStartup(<span class="tok-number">2</span>, <span class="tok-number">2</span>) <span class="tok-kw">catch</span> |err| <span class="tok-kw">switch</span> (err) {</span>
<span class="line" id="L1345">                        <span class="tok-kw">error</span>.SystemNotAvailable =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SystemResources,</span>
<span class="line" id="L1346">                        <span class="tok-kw">error</span>.VersionNotSupported =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.Unexpected,</span>
<span class="line" id="L1347">                        <span class="tok-kw">error</span>.BlockingOperationInProgress =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.Unexpected,</span>
<span class="line" id="L1348">                        <span class="tok-kw">error</span>.ProcessFdQuotaExceeded =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.ProcessFdQuotaExceeded,</span>
<span class="line" id="L1349">                        <span class="tok-kw">error</span>.Unexpected =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.Unexpected,</span>
<span class="line" id="L1350">                    };</span>
<span class="line" id="L1351">                    <span class="tok-kw">continue</span>;</span>
<span class="line" id="L1352">                },</span>
<span class="line" id="L1353">                <span class="tok-kw">else</span> =&gt; |err| <span class="tok-kw">return</span> unexpectedWSAError(err),</span>
<span class="line" id="L1354">            }</span>
<span class="line" id="L1355">        }</span>
<span class="line" id="L1356">        <span class="tok-kw">return</span> rc;</span>
<span class="line" id="L1357">    }</span>
<span class="line" id="L1358">}</span>
<span class="line" id="L1359"></span>
<span class="line" id="L1360"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">bind</span>(s: ws2_32.SOCKET, name: *<span class="tok-kw">const</span> ws2_32.sockaddr, namelen: ws2_32.socklen_t) <span class="tok-type">i32</span> {</span>
<span class="line" id="L1361">    <span class="tok-kw">return</span> ws2_32.bind(s, name, <span class="tok-builtin">@intCast</span>(<span class="tok-type">i32</span>, namelen));</span>
<span class="line" id="L1362">}</span>
<span class="line" id="L1363"></span>
<span class="line" id="L1364"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">listen</span>(s: ws2_32.SOCKET, backlog: <span class="tok-type">u31</span>) <span class="tok-type">i32</span> {</span>
<span class="line" id="L1365">    <span class="tok-kw">return</span> ws2_32.listen(s, backlog);</span>
<span class="line" id="L1366">}</span>
<span class="line" id="L1367"></span>
<span class="line" id="L1368"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">closesocket</span>(s: ws2_32.SOCKET) !<span class="tok-type">void</span> {</span>
<span class="line" id="L1369">    <span class="tok-kw">switch</span> (ws2_32.closesocket(s)) {</span>
<span class="line" id="L1370">        <span class="tok-number">0</span> =&gt; {},</span>
<span class="line" id="L1371">        ws2_32.SOCKET_ERROR =&gt; <span class="tok-kw">switch</span> (ws2_32.WSAGetLastError()) {</span>
<span class="line" id="L1372">            <span class="tok-kw">else</span> =&gt; |err| <span class="tok-kw">return</span> unexpectedWSAError(err),</span>
<span class="line" id="L1373">        },</span>
<span class="line" id="L1374">        <span class="tok-kw">else</span> =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L1375">    }</span>
<span class="line" id="L1376">}</span>
<span class="line" id="L1377"></span>
<span class="line" id="L1378"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">accept</span>(s: ws2_32.SOCKET, name: ?*ws2_32.sockaddr, namelen: ?*ws2_32.socklen_t) ws2_32.SOCKET {</span>
<span class="line" id="L1379">    assert((name == <span class="tok-null">null</span>) == (namelen == <span class="tok-null">null</span>));</span>
<span class="line" id="L1380">    <span class="tok-kw">return</span> ws2_32.accept(s, name, <span class="tok-builtin">@ptrCast</span>(?*<span class="tok-type">i32</span>, namelen));</span>
<span class="line" id="L1381">}</span>
<span class="line" id="L1382"></span>
<span class="line" id="L1383"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">getsockname</span>(s: ws2_32.SOCKET, name: *ws2_32.sockaddr, namelen: *ws2_32.socklen_t) <span class="tok-type">i32</span> {</span>
<span class="line" id="L1384">    <span class="tok-kw">return</span> ws2_32.getsockname(s, name, <span class="tok-builtin">@ptrCast</span>(*<span class="tok-type">i32</span>, namelen));</span>
<span class="line" id="L1385">}</span>
<span class="line" id="L1386"></span>
<span class="line" id="L1387"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">getpeername</span>(s: ws2_32.SOCKET, name: *ws2_32.sockaddr, namelen: *ws2_32.socklen_t) <span class="tok-type">i32</span> {</span>
<span class="line" id="L1388">    <span class="tok-kw">return</span> ws2_32.getpeername(s, name, <span class="tok-builtin">@ptrCast</span>(*<span class="tok-type">i32</span>, namelen));</span>
<span class="line" id="L1389">}</span>
<span class="line" id="L1390"></span>
<span class="line" id="L1391"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">sendmsg</span>(</span>
<span class="line" id="L1392">    s: ws2_32.SOCKET,</span>
<span class="line" id="L1393">    msg: *<span class="tok-kw">const</span> ws2_32.WSAMSG,</span>
<span class="line" id="L1394">    flags: <span class="tok-type">u32</span>,</span>
<span class="line" id="L1395">) <span class="tok-type">i32</span> {</span>
<span class="line" id="L1396">    <span class="tok-kw">var</span> bytes_send: DWORD = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L1397">    <span class="tok-kw">if</span> (ws2_32.WSASendMsg(s, msg, flags, &amp;bytes_send, <span class="tok-null">null</span>, <span class="tok-null">null</span>) == ws2_32.SOCKET_ERROR) {</span>
<span class="line" id="L1398">        <span class="tok-kw">return</span> ws2_32.SOCKET_ERROR;</span>
<span class="line" id="L1399">    } <span class="tok-kw">else</span> {</span>
<span class="line" id="L1400">        <span class="tok-kw">return</span> <span class="tok-builtin">@as</span>(<span class="tok-type">i32</span>, <span class="tok-builtin">@intCast</span>(<span class="tok-type">u31</span>, bytes_send));</span>
<span class="line" id="L1401">    }</span>
<span class="line" id="L1402">}</span>
<span class="line" id="L1403"></span>
<span class="line" id="L1404"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">sendto</span>(s: ws2_32.SOCKET, buf: [*]<span class="tok-kw">const</span> <span class="tok-type">u8</span>, len: <span class="tok-type">usize</span>, flags: <span class="tok-type">u32</span>, to: ?*<span class="tok-kw">const</span> ws2_32.sockaddr, to_len: ws2_32.socklen_t) <span class="tok-type">i32</span> {</span>
<span class="line" id="L1405">    <span class="tok-kw">var</span> buffer = ws2_32.WSABUF{ .len = <span class="tok-builtin">@truncate</span>(<span class="tok-type">u31</span>, len), .buf = <span class="tok-builtin">@intToPtr</span>([*]<span class="tok-type">u8</span>, <span class="tok-builtin">@ptrToInt</span>(buf)) };</span>
<span class="line" id="L1406">    <span class="tok-kw">var</span> bytes_send: DWORD = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L1407">    <span class="tok-kw">if</span> (ws2_32.WSASendTo(s, <span class="tok-builtin">@ptrCast</span>([*]ws2_32.WSABUF, &amp;buffer), <span class="tok-number">1</span>, &amp;bytes_send, flags, to, <span class="tok-builtin">@intCast</span>(<span class="tok-type">i32</span>, to_len), <span class="tok-null">null</span>, <span class="tok-null">null</span>) == ws2_32.SOCKET_ERROR) {</span>
<span class="line" id="L1408">        <span class="tok-kw">return</span> ws2_32.SOCKET_ERROR;</span>
<span class="line" id="L1409">    } <span class="tok-kw">else</span> {</span>
<span class="line" id="L1410">        <span class="tok-kw">return</span> <span class="tok-builtin">@as</span>(<span class="tok-type">i32</span>, <span class="tok-builtin">@intCast</span>(<span class="tok-type">u31</span>, bytes_send));</span>
<span class="line" id="L1411">    }</span>
<span class="line" id="L1412">}</span>
<span class="line" id="L1413"></span>
<span class="line" id="L1414"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">recvfrom</span>(s: ws2_32.SOCKET, buf: [*]<span class="tok-type">u8</span>, len: <span class="tok-type">usize</span>, flags: <span class="tok-type">u32</span>, from: ?*ws2_32.sockaddr, from_len: ?*ws2_32.socklen_t) <span class="tok-type">i32</span> {</span>
<span class="line" id="L1415">    <span class="tok-kw">var</span> buffer = ws2_32.WSABUF{ .len = <span class="tok-builtin">@truncate</span>(<span class="tok-type">u31</span>, len), .buf = buf };</span>
<span class="line" id="L1416">    <span class="tok-kw">var</span> bytes_received: DWORD = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L1417">    <span class="tok-kw">var</span> flags_inout = flags;</span>
<span class="line" id="L1418">    <span class="tok-kw">if</span> (ws2_32.WSARecvFrom(s, <span class="tok-builtin">@ptrCast</span>([*]ws2_32.WSABUF, &amp;buffer), <span class="tok-number">1</span>, &amp;bytes_received, &amp;flags_inout, from, <span class="tok-builtin">@ptrCast</span>(?*<span class="tok-type">i32</span>, from_len), <span class="tok-null">null</span>, <span class="tok-null">null</span>) == ws2_32.SOCKET_ERROR) {</span>
<span class="line" id="L1419">        <span class="tok-kw">return</span> ws2_32.SOCKET_ERROR;</span>
<span class="line" id="L1420">    } <span class="tok-kw">else</span> {</span>
<span class="line" id="L1421">        <span class="tok-kw">return</span> <span class="tok-builtin">@as</span>(<span class="tok-type">i32</span>, <span class="tok-builtin">@intCast</span>(<span class="tok-type">u31</span>, bytes_received));</span>
<span class="line" id="L1422">    }</span>
<span class="line" id="L1423">}</span>
<span class="line" id="L1424"></span>
<span class="line" id="L1425"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">poll</span>(fds: [*]ws2_32.pollfd, n: <span class="tok-type">c_ulong</span>, timeout: <span class="tok-type">i32</span>) <span class="tok-type">i32</span> {</span>
<span class="line" id="L1426">    <span class="tok-kw">return</span> ws2_32.WSAPoll(fds, n, timeout);</span>
<span class="line" id="L1427">}</span>
<span class="line" id="L1428"></span>
<span class="line" id="L1429"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">WSAIoctl</span>(</span>
<span class="line" id="L1430">    s: ws2_32.SOCKET,</span>
<span class="line" id="L1431">    dwIoControlCode: DWORD,</span>
<span class="line" id="L1432">    inBuffer: ?[]<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L1433">    outBuffer: []<span class="tok-type">u8</span>,</span>
<span class="line" id="L1434">    overlapped: ?*OVERLAPPED,</span>
<span class="line" id="L1435">    completionRoutine: ?ws2_32.LPWSAOVERLAPPED_COMPLETION_ROUTINE,</span>
<span class="line" id="L1436">) !DWORD {</span>
<span class="line" id="L1437">    <span class="tok-kw">var</span> bytes: DWORD = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L1438">    <span class="tok-kw">switch</span> (ws2_32.WSAIoctl(</span>
<span class="line" id="L1439">        s,</span>
<span class="line" id="L1440">        dwIoControlCode,</span>
<span class="line" id="L1441">        <span class="tok-kw">if</span> (inBuffer) |i| i.ptr <span class="tok-kw">else</span> <span class="tok-null">null</span>,</span>
<span class="line" id="L1442">        <span class="tok-kw">if</span> (inBuffer) |i| <span class="tok-builtin">@intCast</span>(DWORD, i.len) <span class="tok-kw">else</span> <span class="tok-number">0</span>,</span>
<span class="line" id="L1443">        outBuffer.ptr,</span>
<span class="line" id="L1444">        <span class="tok-builtin">@intCast</span>(DWORD, outBuffer.len),</span>
<span class="line" id="L1445">        &amp;bytes,</span>
<span class="line" id="L1446">        overlapped,</span>
<span class="line" id="L1447">        completionRoutine,</span>
<span class="line" id="L1448">    )) {</span>
<span class="line" id="L1449">        <span class="tok-number">0</span> =&gt; {},</span>
<span class="line" id="L1450">        ws2_32.SOCKET_ERROR =&gt; <span class="tok-kw">switch</span> (ws2_32.WSAGetLastError()) {</span>
<span class="line" id="L1451">            <span class="tok-kw">else</span> =&gt; |err| <span class="tok-kw">return</span> unexpectedWSAError(err),</span>
<span class="line" id="L1452">        },</span>
<span class="line" id="L1453">        <span class="tok-kw">else</span> =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L1454">    }</span>
<span class="line" id="L1455">    <span class="tok-kw">return</span> bytes;</span>
<span class="line" id="L1456">}</span>
<span class="line" id="L1457"></span>
<span class="line" id="L1458"><span class="tok-kw">const</span> GetModuleFileNameError = <span class="tok-kw">error</span>{Unexpected};</span>
<span class="line" id="L1459"></span>
<span class="line" id="L1460"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">GetModuleFileNameW</span>(hModule: ?HMODULE, buf_ptr: [*]<span class="tok-type">u16</span>, buf_len: DWORD) GetModuleFileNameError![:<span class="tok-number">0</span>]<span class="tok-type">u16</span> {</span>
<span class="line" id="L1461">    <span class="tok-kw">const</span> rc = kernel32.GetModuleFileNameW(hModule, buf_ptr, buf_len);</span>
<span class="line" id="L1462">    <span class="tok-kw">if</span> (rc == <span class="tok-number">0</span>) {</span>
<span class="line" id="L1463">        <span class="tok-kw">switch</span> (kernel32.GetLastError()) {</span>
<span class="line" id="L1464">            <span class="tok-kw">else</span> =&gt; |err| <span class="tok-kw">return</span> unexpectedError(err),</span>
<span class="line" id="L1465">        }</span>
<span class="line" id="L1466">    }</span>
<span class="line" id="L1467">    <span class="tok-kw">return</span> buf_ptr[<span class="tok-number">0</span>..rc :<span class="tok-number">0</span>];</span>
<span class="line" id="L1468">}</span>
<span class="line" id="L1469"></span>
<span class="line" id="L1470"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> TerminateProcessError = <span class="tok-kw">error</span>{Unexpected};</span>
<span class="line" id="L1471"></span>
<span class="line" id="L1472"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">TerminateProcess</span>(hProcess: HANDLE, uExitCode: UINT) TerminateProcessError!<span class="tok-type">void</span> {</span>
<span class="line" id="L1473">    <span class="tok-kw">if</span> (kernel32.TerminateProcess(hProcess, uExitCode) == <span class="tok-number">0</span>) {</span>
<span class="line" id="L1474">        <span class="tok-kw">switch</span> (kernel32.GetLastError()) {</span>
<span class="line" id="L1475">            <span class="tok-kw">else</span> =&gt; |err| <span class="tok-kw">return</span> unexpectedError(err),</span>
<span class="line" id="L1476">        }</span>
<span class="line" id="L1477">    }</span>
<span class="line" id="L1478">}</span>
<span class="line" id="L1479"></span>
<span class="line" id="L1480"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> VirtualAllocError = <span class="tok-kw">error</span>{Unexpected};</span>
<span class="line" id="L1481"></span>
<span class="line" id="L1482"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">VirtualAlloc</span>(addr: ?LPVOID, size: <span class="tok-type">usize</span>, alloc_type: DWORD, flProtect: DWORD) VirtualAllocError!LPVOID {</span>
<span class="line" id="L1483">    <span class="tok-kw">return</span> kernel32.VirtualAlloc(addr, size, alloc_type, flProtect) <span class="tok-kw">orelse</span> {</span>
<span class="line" id="L1484">        <span class="tok-kw">switch</span> (kernel32.GetLastError()) {</span>
<span class="line" id="L1485">            <span class="tok-kw">else</span> =&gt; |err| <span class="tok-kw">return</span> unexpectedError(err),</span>
<span class="line" id="L1486">        }</span>
<span class="line" id="L1487">    };</span>
<span class="line" id="L1488">}</span>
<span class="line" id="L1489"></span>
<span class="line" id="L1490"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">VirtualFree</span>(lpAddress: ?LPVOID, dwSize: <span class="tok-type">usize</span>, dwFreeType: DWORD) <span class="tok-type">void</span> {</span>
<span class="line" id="L1491">    assert(kernel32.VirtualFree(lpAddress, dwSize, dwFreeType) != <span class="tok-number">0</span>);</span>
<span class="line" id="L1492">}</span>
<span class="line" id="L1493"></span>
<span class="line" id="L1494"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> VirtualQuerryError = <span class="tok-kw">error</span>{Unexpected};</span>
<span class="line" id="L1495"></span>
<span class="line" id="L1496"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">VirtualQuery</span>(lpAddress: ?LPVOID, lpBuffer: PMEMORY_BASIC_INFORMATION, dwLength: SIZE_T) VirtualQuerryError!SIZE_T {</span>
<span class="line" id="L1497">    <span class="tok-kw">const</span> rc = kernel32.VirtualQuery(lpAddress, lpBuffer, dwLength);</span>
<span class="line" id="L1498">    <span class="tok-kw">if</span> (rc == <span class="tok-number">0</span>) {</span>
<span class="line" id="L1499">        <span class="tok-kw">switch</span> (kernel32.GetLastError()) {</span>
<span class="line" id="L1500">            <span class="tok-kw">else</span> =&gt; |err| <span class="tok-kw">return</span> unexpectedError(err),</span>
<span class="line" id="L1501">        }</span>
<span class="line" id="L1502">    }</span>
<span class="line" id="L1503"></span>
<span class="line" id="L1504">    <span class="tok-kw">return</span> rc;</span>
<span class="line" id="L1505">}</span>
<span class="line" id="L1506"></span>
<span class="line" id="L1507"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SetConsoleTextAttributeError = <span class="tok-kw">error</span>{Unexpected};</span>
<span class="line" id="L1508"></span>
<span class="line" id="L1509"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">SetConsoleTextAttribute</span>(hConsoleOutput: HANDLE, wAttributes: WORD) SetConsoleTextAttributeError!<span class="tok-type">void</span> {</span>
<span class="line" id="L1510">    <span class="tok-kw">if</span> (kernel32.SetConsoleTextAttribute(hConsoleOutput, wAttributes) == <span class="tok-number">0</span>) {</span>
<span class="line" id="L1511">        <span class="tok-kw">switch</span> (kernel32.GetLastError()) {</span>
<span class="line" id="L1512">            <span class="tok-kw">else</span> =&gt; |err| <span class="tok-kw">return</span> unexpectedError(err),</span>
<span class="line" id="L1513">        }</span>
<span class="line" id="L1514">    }</span>
<span class="line" id="L1515">}</span>
<span class="line" id="L1516"></span>
<span class="line" id="L1517"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">SetConsoleCtrlHandler</span>(handler_routine: ?HANDLER_ROUTINE, add: <span class="tok-type">bool</span>) !<span class="tok-type">void</span> {</span>
<span class="line" id="L1518">    <span class="tok-kw">const</span> success = kernel32.SetConsoleCtrlHandler(</span>
<span class="line" id="L1519">        handler_routine,</span>
<span class="line" id="L1520">        <span class="tok-kw">if</span> (add) TRUE <span class="tok-kw">else</span> FALSE,</span>
<span class="line" id="L1521">    );</span>
<span class="line" id="L1522"></span>
<span class="line" id="L1523">    <span class="tok-kw">if</span> (success == FALSE) {</span>
<span class="line" id="L1524">        <span class="tok-kw">return</span> <span class="tok-kw">switch</span> (kernel32.GetLastError()) {</span>
<span class="line" id="L1525">            <span class="tok-kw">else</span> =&gt; |err| unexpectedError(err),</span>
<span class="line" id="L1526">        };</span>
<span class="line" id="L1527">    }</span>
<span class="line" id="L1528">}</span>
<span class="line" id="L1529"></span>
<span class="line" id="L1530"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">SetFileCompletionNotificationModes</span>(handle: HANDLE, flags: UCHAR) !<span class="tok-type">void</span> {</span>
<span class="line" id="L1531">    <span class="tok-kw">const</span> success = kernel32.SetFileCompletionNotificationModes(handle, flags);</span>
<span class="line" id="L1532">    <span class="tok-kw">if</span> (success == FALSE) {</span>
<span class="line" id="L1533">        <span class="tok-kw">return</span> <span class="tok-kw">switch</span> (kernel32.GetLastError()) {</span>
<span class="line" id="L1534">            <span class="tok-kw">else</span> =&gt; |err| unexpectedError(err),</span>
<span class="line" id="L1535">        };</span>
<span class="line" id="L1536">    }</span>
<span class="line" id="L1537">}</span>
<span class="line" id="L1538"></span>
<span class="line" id="L1539"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> GetEnvironmentStringsError = <span class="tok-kw">error</span>{OutOfMemory};</span>
<span class="line" id="L1540"></span>
<span class="line" id="L1541"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">GetEnvironmentStringsW</span>() GetEnvironmentStringsError![*:<span class="tok-number">0</span>]<span class="tok-type">u16</span> {</span>
<span class="line" id="L1542">    <span class="tok-kw">return</span> kernel32.GetEnvironmentStringsW() <span class="tok-kw">orelse</span> <span class="tok-kw">return</span> <span class="tok-kw">error</span>.OutOfMemory;</span>
<span class="line" id="L1543">}</span>
<span class="line" id="L1544"></span>
<span class="line" id="L1545"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">FreeEnvironmentStringsW</span>(penv: [*:<span class="tok-number">0</span>]<span class="tok-type">u16</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L1546">    assert(kernel32.FreeEnvironmentStringsW(penv) != <span class="tok-number">0</span>);</span>
<span class="line" id="L1547">}</span>
<span class="line" id="L1548"></span>
<span class="line" id="L1549"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> GetEnvironmentVariableError = <span class="tok-kw">error</span>{</span>
<span class="line" id="L1550">    EnvironmentVariableNotFound,</span>
<span class="line" id="L1551">    Unexpected,</span>
<span class="line" id="L1552">};</span>
<span class="line" id="L1553"></span>
<span class="line" id="L1554"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">GetEnvironmentVariableW</span>(lpName: LPWSTR, lpBuffer: [*]<span class="tok-type">u16</span>, nSize: DWORD) GetEnvironmentVariableError!DWORD {</span>
<span class="line" id="L1555">    <span class="tok-kw">const</span> rc = kernel32.GetEnvironmentVariableW(lpName, lpBuffer, nSize);</span>
<span class="line" id="L1556">    <span class="tok-kw">if</span> (rc == <span class="tok-number">0</span>) {</span>
<span class="line" id="L1557">        <span class="tok-kw">switch</span> (kernel32.GetLastError()) {</span>
<span class="line" id="L1558">            .ENVVAR_NOT_FOUND =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.EnvironmentVariableNotFound,</span>
<span class="line" id="L1559">            <span class="tok-kw">else</span> =&gt; |err| <span class="tok-kw">return</span> unexpectedError(err),</span>
<span class="line" id="L1560">        }</span>
<span class="line" id="L1561">    }</span>
<span class="line" id="L1562">    <span class="tok-kw">return</span> rc;</span>
<span class="line" id="L1563">}</span>
<span class="line" id="L1564"></span>
<span class="line" id="L1565"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> CreateProcessError = <span class="tok-kw">error</span>{</span>
<span class="line" id="L1566">    FileNotFound,</span>
<span class="line" id="L1567">    AccessDenied,</span>
<span class="line" id="L1568">    InvalidName,</span>
<span class="line" id="L1569">    Unexpected,</span>
<span class="line" id="L1570">};</span>
<span class="line" id="L1571"></span>
<span class="line" id="L1572"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">CreateProcessW</span>(</span>
<span class="line" id="L1573">    lpApplicationName: ?LPWSTR,</span>
<span class="line" id="L1574">    lpCommandLine: LPWSTR,</span>
<span class="line" id="L1575">    lpProcessAttributes: ?*SECURITY_ATTRIBUTES,</span>
<span class="line" id="L1576">    lpThreadAttributes: ?*SECURITY_ATTRIBUTES,</span>
<span class="line" id="L1577">    bInheritHandles: BOOL,</span>
<span class="line" id="L1578">    dwCreationFlags: DWORD,</span>
<span class="line" id="L1579">    lpEnvironment: ?*<span class="tok-type">anyopaque</span>,</span>
<span class="line" id="L1580">    lpCurrentDirectory: ?LPWSTR,</span>
<span class="line" id="L1581">    lpStartupInfo: *STARTUPINFOW,</span>
<span class="line" id="L1582">    lpProcessInformation: *PROCESS_INFORMATION,</span>
<span class="line" id="L1583">) CreateProcessError!<span class="tok-type">void</span> {</span>
<span class="line" id="L1584">    <span class="tok-kw">if</span> (kernel32.CreateProcessW(</span>
<span class="line" id="L1585">        lpApplicationName,</span>
<span class="line" id="L1586">        lpCommandLine,</span>
<span class="line" id="L1587">        lpProcessAttributes,</span>
<span class="line" id="L1588">        lpThreadAttributes,</span>
<span class="line" id="L1589">        bInheritHandles,</span>
<span class="line" id="L1590">        dwCreationFlags,</span>
<span class="line" id="L1591">        lpEnvironment,</span>
<span class="line" id="L1592">        lpCurrentDirectory,</span>
<span class="line" id="L1593">        lpStartupInfo,</span>
<span class="line" id="L1594">        lpProcessInformation,</span>
<span class="line" id="L1595">    ) == <span class="tok-number">0</span>) {</span>
<span class="line" id="L1596">        <span class="tok-kw">switch</span> (kernel32.GetLastError()) {</span>
<span class="line" id="L1597">            .FILE_NOT_FOUND =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.FileNotFound,</span>
<span class="line" id="L1598">            .PATH_NOT_FOUND =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.FileNotFound,</span>
<span class="line" id="L1599">            .ACCESS_DENIED =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.AccessDenied,</span>
<span class="line" id="L1600">            .INVALID_PARAMETER =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L1601">            .INVALID_NAME =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InvalidName,</span>
<span class="line" id="L1602">            <span class="tok-kw">else</span> =&gt; |err| <span class="tok-kw">return</span> unexpectedError(err),</span>
<span class="line" id="L1603">        }</span>
<span class="line" id="L1604">    }</span>
<span class="line" id="L1605">}</span>
<span class="line" id="L1606"></span>
<span class="line" id="L1607"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> LoadLibraryError = <span class="tok-kw">error</span>{</span>
<span class="line" id="L1608">    FileNotFound,</span>
<span class="line" id="L1609">    Unexpected,</span>
<span class="line" id="L1610">};</span>
<span class="line" id="L1611"></span>
<span class="line" id="L1612"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">LoadLibraryW</span>(lpLibFileName: [*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u16</span>) LoadLibraryError!HMODULE {</span>
<span class="line" id="L1613">    <span class="tok-kw">return</span> kernel32.LoadLibraryW(lpLibFileName) <span class="tok-kw">orelse</span> {</span>
<span class="line" id="L1614">        <span class="tok-kw">switch</span> (kernel32.GetLastError()) {</span>
<span class="line" id="L1615">            .FILE_NOT_FOUND =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.FileNotFound,</span>
<span class="line" id="L1616">            .PATH_NOT_FOUND =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.FileNotFound,</span>
<span class="line" id="L1617">            .MOD_NOT_FOUND =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.FileNotFound,</span>
<span class="line" id="L1618">            <span class="tok-kw">else</span> =&gt; |err| <span class="tok-kw">return</span> unexpectedError(err),</span>
<span class="line" id="L1619">        }</span>
<span class="line" id="L1620">    };</span>
<span class="line" id="L1621">}</span>
<span class="line" id="L1622"></span>
<span class="line" id="L1623"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">FreeLibrary</span>(hModule: HMODULE) <span class="tok-type">void</span> {</span>
<span class="line" id="L1624">    assert(kernel32.FreeLibrary(hModule) != <span class="tok-number">0</span>);</span>
<span class="line" id="L1625">}</span>
<span class="line" id="L1626"></span>
<span class="line" id="L1627"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">QueryPerformanceFrequency</span>() <span class="tok-type">u64</span> {</span>
<span class="line" id="L1628">    <span class="tok-comment">// &quot;On systems that run Windows XP or later, the function will always succeed&quot;</span>
</span>
<span class="line" id="L1629">    <span class="tok-comment">// https://docs.microsoft.com/en-us/windows/desktop/api/profileapi/nf-profileapi-queryperformancefrequency</span>
</span>
<span class="line" id="L1630">    <span class="tok-kw">var</span> result: LARGE_INTEGER = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L1631">    assert(kernel32.QueryPerformanceFrequency(&amp;result) != <span class="tok-number">0</span>);</span>
<span class="line" id="L1632">    <span class="tok-comment">// The kernel treats this integer as unsigned.</span>
</span>
<span class="line" id="L1633">    <span class="tok-kw">return</span> <span class="tok-builtin">@bitCast</span>(<span class="tok-type">u64</span>, result);</span>
<span class="line" id="L1634">}</span>
<span class="line" id="L1635"></span>
<span class="line" id="L1636"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">QueryPerformanceCounter</span>() <span class="tok-type">u64</span> {</span>
<span class="line" id="L1637">    <span class="tok-comment">// &quot;On systems that run Windows XP or later, the function will always succeed&quot;</span>
</span>
<span class="line" id="L1638">    <span class="tok-comment">// https://docs.microsoft.com/en-us/windows/desktop/api/profileapi/nf-profileapi-queryperformancecounter</span>
</span>
<span class="line" id="L1639">    <span class="tok-kw">var</span> result: LARGE_INTEGER = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L1640">    assert(kernel32.QueryPerformanceCounter(&amp;result) != <span class="tok-number">0</span>);</span>
<span class="line" id="L1641">    <span class="tok-comment">// The kernel treats this integer as unsigned.</span>
</span>
<span class="line" id="L1642">    <span class="tok-kw">return</span> <span class="tok-builtin">@bitCast</span>(<span class="tok-type">u64</span>, result);</span>
<span class="line" id="L1643">}</span>
<span class="line" id="L1644"></span>
<span class="line" id="L1645"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">InitOnceExecuteOnce</span>(InitOnce: *INIT_ONCE, InitFn: INIT_ONCE_FN, Parameter: ?*<span class="tok-type">anyopaque</span>, Context: ?*<span class="tok-type">anyopaque</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L1646">    assert(kernel32.InitOnceExecuteOnce(InitOnce, InitFn, Parameter, Context) != <span class="tok-number">0</span>);</span>
<span class="line" id="L1647">}</span>
<span class="line" id="L1648"></span>
<span class="line" id="L1649"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">HeapFree</span>(hHeap: HANDLE, dwFlags: DWORD, lpMem: *<span class="tok-type">anyopaque</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L1650">    assert(kernel32.HeapFree(hHeap, dwFlags, lpMem) != <span class="tok-number">0</span>);</span>
<span class="line" id="L1651">}</span>
<span class="line" id="L1652"></span>
<span class="line" id="L1653"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">HeapDestroy</span>(hHeap: HANDLE) <span class="tok-type">void</span> {</span>
<span class="line" id="L1654">    assert(kernel32.HeapDestroy(hHeap) != <span class="tok-number">0</span>);</span>
<span class="line" id="L1655">}</span>
<span class="line" id="L1656"></span>
<span class="line" id="L1657"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">LocalFree</span>(hMem: HLOCAL) <span class="tok-type">void</span> {</span>
<span class="line" id="L1658">    assert(kernel32.LocalFree(hMem) == <span class="tok-null">null</span>);</span>
<span class="line" id="L1659">}</span>
<span class="line" id="L1660"></span>
<span class="line" id="L1661"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> GetFileInformationByHandleError = <span class="tok-kw">error</span>{Unexpected};</span>
<span class="line" id="L1662"></span>
<span class="line" id="L1663"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">GetFileInformationByHandle</span>(</span>
<span class="line" id="L1664">    hFile: HANDLE,</span>
<span class="line" id="L1665">) GetFileInformationByHandleError!BY_HANDLE_FILE_INFORMATION {</span>
<span class="line" id="L1666">    <span class="tok-kw">var</span> info: BY_HANDLE_FILE_INFORMATION = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L1667">    <span class="tok-kw">const</span> rc = ntdll.GetFileInformationByHandle(hFile, &amp;info);</span>
<span class="line" id="L1668">    <span class="tok-kw">if</span> (rc == <span class="tok-number">0</span>) {</span>
<span class="line" id="L1669">        <span class="tok-kw">switch</span> (kernel32.GetLastError()) {</span>
<span class="line" id="L1670">            <span class="tok-kw">else</span> =&gt; |err| <span class="tok-kw">return</span> unexpectedError(err),</span>
<span class="line" id="L1671">        }</span>
<span class="line" id="L1672">    }</span>
<span class="line" id="L1673">    <span class="tok-kw">return</span> info;</span>
<span class="line" id="L1674">}</span>
<span class="line" id="L1675"></span>
<span class="line" id="L1676"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SetFileTimeError = <span class="tok-kw">error</span>{Unexpected};</span>
<span class="line" id="L1677"></span>
<span class="line" id="L1678"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">SetFileTime</span>(</span>
<span class="line" id="L1679">    hFile: HANDLE,</span>
<span class="line" id="L1680">    lpCreationTime: ?*<span class="tok-kw">const</span> FILETIME,</span>
<span class="line" id="L1681">    lpLastAccessTime: ?*<span class="tok-kw">const</span> FILETIME,</span>
<span class="line" id="L1682">    lpLastWriteTime: ?*<span class="tok-kw">const</span> FILETIME,</span>
<span class="line" id="L1683">) SetFileTimeError!<span class="tok-type">void</span> {</span>
<span class="line" id="L1684">    <span class="tok-kw">const</span> rc = kernel32.SetFileTime(hFile, lpCreationTime, lpLastAccessTime, lpLastWriteTime);</span>
<span class="line" id="L1685">    <span class="tok-kw">if</span> (rc == <span class="tok-number">0</span>) {</span>
<span class="line" id="L1686">        <span class="tok-kw">switch</span> (kernel32.GetLastError()) {</span>
<span class="line" id="L1687">            <span class="tok-kw">else</span> =&gt; |err| <span class="tok-kw">return</span> unexpectedError(err),</span>
<span class="line" id="L1688">        }</span>
<span class="line" id="L1689">    }</span>
<span class="line" id="L1690">}</span>
<span class="line" id="L1691"></span>
<span class="line" id="L1692"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> LockFileError = <span class="tok-kw">error</span>{</span>
<span class="line" id="L1693">    SystemResources,</span>
<span class="line" id="L1694">    WouldBlock,</span>
<span class="line" id="L1695">} || std.os.UnexpectedError;</span>
<span class="line" id="L1696"></span>
<span class="line" id="L1697"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">LockFile</span>(</span>
<span class="line" id="L1698">    FileHandle: HANDLE,</span>
<span class="line" id="L1699">    Event: ?HANDLE,</span>
<span class="line" id="L1700">    ApcRoutine: ?*IO_APC_ROUTINE,</span>
<span class="line" id="L1701">    ApcContext: ?*<span class="tok-type">anyopaque</span>,</span>
<span class="line" id="L1702">    IoStatusBlock: *IO_STATUS_BLOCK,</span>
<span class="line" id="L1703">    ByteOffset: *<span class="tok-kw">const</span> LARGE_INTEGER,</span>
<span class="line" id="L1704">    Length: *<span class="tok-kw">const</span> LARGE_INTEGER,</span>
<span class="line" id="L1705">    Key: ?*ULONG,</span>
<span class="line" id="L1706">    FailImmediately: BOOLEAN,</span>
<span class="line" id="L1707">    ExclusiveLock: BOOLEAN,</span>
<span class="line" id="L1708">) !<span class="tok-type">void</span> {</span>
<span class="line" id="L1709">    <span class="tok-kw">const</span> rc = ntdll.NtLockFile(</span>
<span class="line" id="L1710">        FileHandle,</span>
<span class="line" id="L1711">        Event,</span>
<span class="line" id="L1712">        ApcRoutine,</span>
<span class="line" id="L1713">        ApcContext,</span>
<span class="line" id="L1714">        IoStatusBlock,</span>
<span class="line" id="L1715">        ByteOffset,</span>
<span class="line" id="L1716">        Length,</span>
<span class="line" id="L1717">        Key,</span>
<span class="line" id="L1718">        FailImmediately,</span>
<span class="line" id="L1719">        ExclusiveLock,</span>
<span class="line" id="L1720">    );</span>
<span class="line" id="L1721">    <span class="tok-kw">switch</span> (rc) {</span>
<span class="line" id="L1722">        .SUCCESS =&gt; <span class="tok-kw">return</span>,</span>
<span class="line" id="L1723">        .INSUFFICIENT_RESOURCES =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SystemResources,</span>
<span class="line" id="L1724">        .LOCK_NOT_GRANTED =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.WouldBlock,</span>
<span class="line" id="L1725">        .ACCESS_VIOLATION =&gt; <span class="tok-kw">unreachable</span>, <span class="tok-comment">// bad io_status_block pointer</span>
</span>
<span class="line" id="L1726">        <span class="tok-kw">else</span> =&gt; <span class="tok-kw">return</span> unexpectedStatus(rc),</span>
<span class="line" id="L1727">    }</span>
<span class="line" id="L1728">}</span>
<span class="line" id="L1729"></span>
<span class="line" id="L1730"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> UnlockFileError = <span class="tok-kw">error</span>{</span>
<span class="line" id="L1731">    RangeNotLocked,</span>
<span class="line" id="L1732">} || std.os.UnexpectedError;</span>
<span class="line" id="L1733"></span>
<span class="line" id="L1734"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">UnlockFile</span>(</span>
<span class="line" id="L1735">    FileHandle: HANDLE,</span>
<span class="line" id="L1736">    IoStatusBlock: *IO_STATUS_BLOCK,</span>
<span class="line" id="L1737">    ByteOffset: *<span class="tok-kw">const</span> LARGE_INTEGER,</span>
<span class="line" id="L1738">    Length: *<span class="tok-kw">const</span> LARGE_INTEGER,</span>
<span class="line" id="L1739">    Key: ?*ULONG,</span>
<span class="line" id="L1740">) !<span class="tok-type">void</span> {</span>
<span class="line" id="L1741">    <span class="tok-kw">const</span> rc = ntdll.NtUnlockFile(FileHandle, IoStatusBlock, ByteOffset, Length, Key);</span>
<span class="line" id="L1742">    <span class="tok-kw">switch</span> (rc) {</span>
<span class="line" id="L1743">        .SUCCESS =&gt; <span class="tok-kw">return</span>,</span>
<span class="line" id="L1744">        .RANGE_NOT_LOCKED =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.RangeNotLocked,</span>
<span class="line" id="L1745">        .ACCESS_VIOLATION =&gt; <span class="tok-kw">unreachable</span>, <span class="tok-comment">// bad io_status_block pointer</span>
</span>
<span class="line" id="L1746">        <span class="tok-kw">else</span> =&gt; <span class="tok-kw">return</span> unexpectedStatus(rc),</span>
<span class="line" id="L1747">    }</span>
<span class="line" id="L1748">}</span>
<span class="line" id="L1749"></span>
<span class="line" id="L1750"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">teb</span>() *TEB {</span>
<span class="line" id="L1751">    <span class="tok-kw">return</span> <span class="tok-kw">switch</span> (native_arch) {</span>
<span class="line" id="L1752">        .<span class="tok-type">i386</span> =&gt; <span class="tok-kw">asm</span> <span class="tok-kw">volatile</span> (</span>
<span class="line" id="L1753">            <span class="tok-str">\\ movl %%fs:0x18, %[ptr]</span></span>

<span class="line" id="L1754">            : [ptr] <span class="tok-str">&quot;=r&quot;</span> (-&gt; *TEB),</span>
<span class="line" id="L1755">        ),</span>
<span class="line" id="L1756">        .x86_64 =&gt; <span class="tok-kw">asm</span> <span class="tok-kw">volatile</span> (</span>
<span class="line" id="L1757">            <span class="tok-str">\\ movq %%gs:0x30, %[ptr]</span></span>

<span class="line" id="L1758">            : [ptr] <span class="tok-str">&quot;=r&quot;</span> (-&gt; *TEB),</span>
<span class="line" id="L1759">        ),</span>
<span class="line" id="L1760">        .aarch64 =&gt; <span class="tok-kw">asm</span> <span class="tok-kw">volatile</span> (</span>
<span class="line" id="L1761">            <span class="tok-str">\\ mov %[ptr], x18</span></span>

<span class="line" id="L1762">            : [ptr] <span class="tok-str">&quot;=r&quot;</span> (-&gt; *TEB),</span>
<span class="line" id="L1763">        ),</span>
<span class="line" id="L1764">        <span class="tok-kw">else</span> =&gt; <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;unsupported arch&quot;</span>),</span>
<span class="line" id="L1765">    };</span>
<span class="line" id="L1766">}</span>
<span class="line" id="L1767"></span>
<span class="line" id="L1768"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">peb</span>() *PEB {</span>
<span class="line" id="L1769">    <span class="tok-kw">return</span> teb().ProcessEnvironmentBlock;</span>
<span class="line" id="L1770">}</span>
<span class="line" id="L1771"></span>
<span class="line" id="L1772"><span class="tok-comment">/// A file time is a 64-bit value that represents the number of 100-nanosecond</span></span>
<span class="line" id="L1773"><span class="tok-comment">/// intervals that have elapsed since 12:00 A.M. January 1, 1601 Coordinated</span></span>
<span class="line" id="L1774"><span class="tok-comment">/// Universal Time (UTC).</span></span>
<span class="line" id="L1775"><span class="tok-comment">/// This function returns the number of nanoseconds since the canonical epoch,</span></span>
<span class="line" id="L1776"><span class="tok-comment">/// which is the POSIX one (Jan 01, 1970 AD).</span></span>
<span class="line" id="L1777"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">fromSysTime</span>(hns: <span class="tok-type">i64</span>) <span class="tok-type">i128</span> {</span>
<span class="line" id="L1778">    <span class="tok-kw">const</span> adjusted_epoch: <span class="tok-type">i128</span> = hns + std.time.epoch.windows * (std.time.ns_per_s / <span class="tok-number">100</span>);</span>
<span class="line" id="L1779">    <span class="tok-kw">return</span> adjusted_epoch * <span class="tok-number">100</span>;</span>
<span class="line" id="L1780">}</span>
<span class="line" id="L1781"></span>
<span class="line" id="L1782"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">toSysTime</span>(ns: <span class="tok-type">i128</span>) <span class="tok-type">i64</span> {</span>
<span class="line" id="L1783">    <span class="tok-kw">const</span> hns = <span class="tok-builtin">@divFloor</span>(ns, <span class="tok-number">100</span>);</span>
<span class="line" id="L1784">    <span class="tok-kw">return</span> <span class="tok-builtin">@intCast</span>(<span class="tok-type">i64</span>, hns) - std.time.epoch.windows * (std.time.ns_per_s / <span class="tok-number">100</span>);</span>
<span class="line" id="L1785">}</span>
<span class="line" id="L1786"></span>
<span class="line" id="L1787"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">fileTimeToNanoSeconds</span>(ft: FILETIME) <span class="tok-type">i128</span> {</span>
<span class="line" id="L1788">    <span class="tok-kw">const</span> hns = (<span class="tok-builtin">@as</span>(<span class="tok-type">i64</span>, ft.dwHighDateTime) &lt;&lt; <span class="tok-number">32</span>) | ft.dwLowDateTime;</span>
<span class="line" id="L1789">    <span class="tok-kw">return</span> fromSysTime(hns);</span>
<span class="line" id="L1790">}</span>
<span class="line" id="L1791"></span>
<span class="line" id="L1792"><span class="tok-comment">/// Converts a number of nanoseconds since the POSIX epoch to a Windows FILETIME.</span></span>
<span class="line" id="L1793"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">nanoSecondsToFileTime</span>(ns: <span class="tok-type">i128</span>) FILETIME {</span>
<span class="line" id="L1794">    <span class="tok-kw">const</span> adjusted = <span class="tok-builtin">@bitCast</span>(<span class="tok-type">u64</span>, toSysTime(ns));</span>
<span class="line" id="L1795">    <span class="tok-kw">return</span> FILETIME{</span>
<span class="line" id="L1796">        .dwHighDateTime = <span class="tok-builtin">@truncate</span>(<span class="tok-type">u32</span>, adjusted &gt;&gt; <span class="tok-number">32</span>),</span>
<span class="line" id="L1797">        .dwLowDateTime = <span class="tok-builtin">@truncate</span>(<span class="tok-type">u32</span>, adjusted),</span>
<span class="line" id="L1798">    };</span>
<span class="line" id="L1799">}</span>
<span class="line" id="L1800"></span>
<span class="line" id="L1801"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> PathSpace = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L1802">    data: [PATH_MAX_WIDE:<span class="tok-number">0</span>]<span class="tok-type">u16</span>,</span>
<span class="line" id="L1803">    len: <span class="tok-type">usize</span>,</span>
<span class="line" id="L1804"></span>
<span class="line" id="L1805">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">span</span>(self: *<span class="tok-kw">const</span> PathSpace) [:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u16</span> {</span>
<span class="line" id="L1806">        <span class="tok-kw">return</span> self.data[<span class="tok-number">0</span>..self.len :<span class="tok-number">0</span>];</span>
<span class="line" id="L1807">    }</span>
<span class="line" id="L1808">};</span>
<span class="line" id="L1809"></span>
<span class="line" id="L1810"><span class="tok-comment">/// The error type for `removeDotDirsSanitized`</span></span>
<span class="line" id="L1811"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> RemoveDotDirsError = <span class="tok-kw">error</span>{TooManyParentDirs};</span>
<span class="line" id="L1812"></span>
<span class="line" id="L1813"><span class="tok-comment">/// Removes '.' and '..' path components from a &quot;sanitized relative path&quot;.</span></span>
<span class="line" id="L1814"><span class="tok-comment">/// A &quot;sanitized path&quot; is one where:</span></span>
<span class="line" id="L1815"><span class="tok-comment">///    1) all forward slashes have been replaced with back slashes</span></span>
<span class="line" id="L1816"><span class="tok-comment">///    2) all repeating back slashes have been collapsed</span></span>
<span class="line" id="L1817"><span class="tok-comment">///    3) the path is a relative one (does not start with a back slash)</span></span>
<span class="line" id="L1818"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">removeDotDirsSanitized</span>(<span class="tok-kw">comptime</span> T: <span class="tok-type">type</span>, path: []T) RemoveDotDirsError!<span class="tok-type">usize</span> {</span>
<span class="line" id="L1819">    std.debug.assert(path.len == <span class="tok-number">0</span> <span class="tok-kw">or</span> path[<span class="tok-number">0</span>] != <span class="tok-str">'\\'</span>);</span>
<span class="line" id="L1820"></span>
<span class="line" id="L1821">    <span class="tok-kw">var</span> write_idx: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L1822">    <span class="tok-kw">var</span> read_idx: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L1823">    <span class="tok-kw">while</span> (read_idx &lt; path.len) {</span>
<span class="line" id="L1824">        <span class="tok-kw">if</span> (path[read_idx] == <span class="tok-str">'.'</span>) {</span>
<span class="line" id="L1825">            <span class="tok-kw">if</span> (read_idx + <span class="tok-number">1</span> == path.len)</span>
<span class="line" id="L1826">                <span class="tok-kw">return</span> write_idx;</span>
<span class="line" id="L1827"></span>
<span class="line" id="L1828">            <span class="tok-kw">const</span> after_dot = path[read_idx + <span class="tok-number">1</span>];</span>
<span class="line" id="L1829">            <span class="tok-kw">if</span> (after_dot == <span class="tok-str">'\\'</span>) {</span>
<span class="line" id="L1830">                read_idx += <span class="tok-number">2</span>;</span>
<span class="line" id="L1831">                <span class="tok-kw">continue</span>;</span>
<span class="line" id="L1832">            }</span>
<span class="line" id="L1833">            <span class="tok-kw">if</span> (after_dot == <span class="tok-str">'.'</span> <span class="tok-kw">and</span> (read_idx + <span class="tok-number">2</span> == path.len <span class="tok-kw">or</span> path[read_idx + <span class="tok-number">2</span>] == <span class="tok-str">'\\'</span>)) {</span>
<span class="line" id="L1834">                <span class="tok-kw">if</span> (write_idx == <span class="tok-number">0</span>) <span class="tok-kw">return</span> <span class="tok-kw">error</span>.TooManyParentDirs;</span>
<span class="line" id="L1835">                std.debug.assert(write_idx &gt;= <span class="tok-number">2</span>);</span>
<span class="line" id="L1836">                write_idx -= <span class="tok-number">1</span>;</span>
<span class="line" id="L1837">                <span class="tok-kw">while</span> (<span class="tok-null">true</span>) {</span>
<span class="line" id="L1838">                    write_idx -= <span class="tok-number">1</span>;</span>
<span class="line" id="L1839">                    <span class="tok-kw">if</span> (write_idx == <span class="tok-number">0</span>) <span class="tok-kw">break</span>;</span>
<span class="line" id="L1840">                    <span class="tok-kw">if</span> (path[write_idx] == <span class="tok-str">'\\'</span>) {</span>
<span class="line" id="L1841">                        write_idx += <span class="tok-number">1</span>;</span>
<span class="line" id="L1842">                        <span class="tok-kw">break</span>;</span>
<span class="line" id="L1843">                    }</span>
<span class="line" id="L1844">                }</span>
<span class="line" id="L1845">                <span class="tok-kw">if</span> (read_idx + <span class="tok-number">2</span> == path.len)</span>
<span class="line" id="L1846">                    <span class="tok-kw">return</span> write_idx;</span>
<span class="line" id="L1847">                read_idx += <span class="tok-number">3</span>;</span>
<span class="line" id="L1848">                <span class="tok-kw">continue</span>;</span>
<span class="line" id="L1849">            }</span>
<span class="line" id="L1850">        }</span>
<span class="line" id="L1851"></span>
<span class="line" id="L1852">        <span class="tok-comment">// skip to the next path separator</span>
</span>
<span class="line" id="L1853">        <span class="tok-kw">while</span> (<span class="tok-null">true</span>) : (read_idx += <span class="tok-number">1</span>) {</span>
<span class="line" id="L1854">            <span class="tok-kw">if</span> (read_idx == path.len)</span>
<span class="line" id="L1855">                <span class="tok-kw">return</span> write_idx;</span>
<span class="line" id="L1856">            path[write_idx] = path[read_idx];</span>
<span class="line" id="L1857">            write_idx += <span class="tok-number">1</span>;</span>
<span class="line" id="L1858">            <span class="tok-kw">if</span> (path[read_idx] == <span class="tok-str">'\\'</span>)</span>
<span class="line" id="L1859">                <span class="tok-kw">break</span>;</span>
<span class="line" id="L1860">        }</span>
<span class="line" id="L1861">        read_idx += <span class="tok-number">1</span>;</span>
<span class="line" id="L1862">    }</span>
<span class="line" id="L1863">    <span class="tok-kw">return</span> write_idx;</span>
<span class="line" id="L1864">}</span>
<span class="line" id="L1865"></span>
<span class="line" id="L1866"><span class="tok-comment">/// Normalizes a Windows path with the following steps:</span></span>
<span class="line" id="L1867"><span class="tok-comment">///     1) convert all forward slashes to back slashes</span></span>
<span class="line" id="L1868"><span class="tok-comment">///     2) collapse duplicate back slashes</span></span>
<span class="line" id="L1869"><span class="tok-comment">///     3) remove '.' and '..' directory parts</span></span>
<span class="line" id="L1870"><span class="tok-comment">/// Returns the length of the new path.</span></span>
<span class="line" id="L1871"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">normalizePath</span>(<span class="tok-kw">comptime</span> T: <span class="tok-type">type</span>, path: []T) RemoveDotDirsError!<span class="tok-type">usize</span> {</span>
<span class="line" id="L1872">    mem.replaceScalar(T, path, <span class="tok-str">'/'</span>, <span class="tok-str">'\\'</span>);</span>
<span class="line" id="L1873">    <span class="tok-kw">const</span> new_len = mem.collapseRepeatsLen(T, path, <span class="tok-str">'\\'</span>);</span>
<span class="line" id="L1874"></span>
<span class="line" id="L1875">    <span class="tok-kw">const</span> prefix_len: <span class="tok-type">usize</span> = init: {</span>
<span class="line" id="L1876">        <span class="tok-kw">if</span> (new_len &gt;= <span class="tok-number">1</span> <span class="tok-kw">and</span> path[<span class="tok-number">0</span>] == <span class="tok-str">'\\'</span>) <span class="tok-kw">break</span> :init <span class="tok-number">1</span>;</span>
<span class="line" id="L1877">        <span class="tok-kw">if</span> (new_len &gt;= <span class="tok-number">2</span> <span class="tok-kw">and</span> path[<span class="tok-number">1</span>] == <span class="tok-str">':'</span>)</span>
<span class="line" id="L1878">            <span class="tok-kw">break</span> :init <span class="tok-kw">if</span> (new_len &gt;= <span class="tok-number">3</span> <span class="tok-kw">and</span> path[<span class="tok-number">2</span>] == <span class="tok-str">'\\'</span>) <span class="tok-builtin">@as</span>(<span class="tok-type">usize</span>, <span class="tok-number">3</span>) <span class="tok-kw">else</span> <span class="tok-builtin">@as</span>(<span class="tok-type">usize</span>, <span class="tok-number">2</span>);</span>
<span class="line" id="L1879">        <span class="tok-kw">break</span> :init <span class="tok-number">0</span>;</span>
<span class="line" id="L1880">    };</span>
<span class="line" id="L1881"></span>
<span class="line" id="L1882">    <span class="tok-kw">return</span> prefix_len + <span class="tok-kw">try</span> removeDotDirsSanitized(T, path[prefix_len..new_len]);</span>
<span class="line" id="L1883">}</span>
<span class="line" id="L1884"></span>
<span class="line" id="L1885"><span class="tok-comment">/// Same as `sliceToPrefixedFileW` but accepts a pointer</span></span>
<span class="line" id="L1886"><span class="tok-comment">/// to a null-terminated path.</span></span>
<span class="line" id="L1887"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">cStrToPrefixedFileW</span>(s: [*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span>) !PathSpace {</span>
<span class="line" id="L1888">    <span class="tok-kw">return</span> sliceToPrefixedFileW(mem.sliceTo(s, <span class="tok-number">0</span>));</span>
<span class="line" id="L1889">}</span>
<span class="line" id="L1890"></span>
<span class="line" id="L1891"><span class="tok-comment">/// Converts the path `s` to WTF16, null-terminated. If the path is absolute,</span></span>
<span class="line" id="L1892"><span class="tok-comment">/// it will get NT-style prefix `\??\` prepended automatically.</span></span>
<span class="line" id="L1893"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">sliceToPrefixedFileW</span>(s: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) !PathSpace {</span>
<span class="line" id="L1894">    <span class="tok-comment">// TODO https://github.com/ziglang/zig/issues/2765</span>
</span>
<span class="line" id="L1895">    <span class="tok-kw">var</span> path_space: PathSpace = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L1896">    <span class="tok-kw">const</span> prefix = <span class="tok-str">&quot;\\??\\&quot;</span>;</span>
<span class="line" id="L1897">    <span class="tok-kw">const</span> prefix_index: <span class="tok-type">usize</span> = <span class="tok-kw">if</span> (mem.startsWith(<span class="tok-type">u8</span>, s, prefix)) prefix.len <span class="tok-kw">else</span> <span class="tok-number">0</span>;</span>
<span class="line" id="L1898">    <span class="tok-kw">for</span> (s[prefix_index..]) |byte| {</span>
<span class="line" id="L1899">        <span class="tok-kw">switch</span> (byte) {</span>
<span class="line" id="L1900">            <span class="tok-str">'*'</span>, <span class="tok-str">'?'</span>, <span class="tok-str">'&quot;'</span>, <span class="tok-str">'&lt;'</span>, <span class="tok-str">'&gt;'</span>, <span class="tok-str">'|'</span> =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.BadPathName,</span>
<span class="line" id="L1901">            <span class="tok-kw">else</span> =&gt; {},</span>
<span class="line" id="L1902">        }</span>
<span class="line" id="L1903">    }</span>
<span class="line" id="L1904">    <span class="tok-kw">const</span> prefix_u16 = [_]<span class="tok-type">u16</span>{ <span class="tok-str">'\\'</span>, <span class="tok-str">'?'</span>, <span class="tok-str">'?'</span>, <span class="tok-str">'\\'</span> };</span>
<span class="line" id="L1905">    <span class="tok-kw">const</span> start_index = <span class="tok-kw">if</span> (prefix_index &gt; <span class="tok-number">0</span> <span class="tok-kw">or</span> !std.fs.path.isAbsolute(s)) <span class="tok-number">0</span> <span class="tok-kw">else</span> blk: {</span>
<span class="line" id="L1906">        mem.copy(<span class="tok-type">u16</span>, path_space.data[<span class="tok-number">0</span>..], prefix_u16[<span class="tok-number">0</span>..]);</span>
<span class="line" id="L1907">        <span class="tok-kw">break</span> :blk prefix_u16.len;</span>
<span class="line" id="L1908">    };</span>
<span class="line" id="L1909">    path_space.len = start_index + <span class="tok-kw">try</span> std.unicode.utf8ToUtf16Le(path_space.data[start_index..], s);</span>
<span class="line" id="L1910">    <span class="tok-kw">if</span> (path_space.len &gt; path_space.data.len) <span class="tok-kw">return</span> <span class="tok-kw">error</span>.NameTooLong;</span>
<span class="line" id="L1911">    path_space.len = start_index + (normalizePath(<span class="tok-type">u16</span>, path_space.data[start_index..path_space.len]) <span class="tok-kw">catch</span> |err| <span class="tok-kw">switch</span> (err) {</span>
<span class="line" id="L1912">        <span class="tok-kw">error</span>.TooManyParentDirs =&gt; {</span>
<span class="line" id="L1913">            <span class="tok-kw">if</span> (!std.fs.path.isAbsolute(s)) {</span>
<span class="line" id="L1914">                <span class="tok-kw">var</span> temp_path: PathSpace = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L1915">                temp_path.len = <span class="tok-kw">try</span> std.unicode.utf8ToUtf16Le(&amp;temp_path.data, s);</span>
<span class="line" id="L1916">                std.debug.assert(temp_path.len == path_space.len);</span>
<span class="line" id="L1917">                temp_path.data[path_space.len] = <span class="tok-number">0</span>;</span>
<span class="line" id="L1918">                path_space.len = prefix_u16.len + <span class="tok-kw">try</span> getFullPathNameW(&amp;temp_path.data, path_space.data[prefix_u16.len..]);</span>
<span class="line" id="L1919">                mem.copy(<span class="tok-type">u16</span>, &amp;path_space.data, &amp;prefix_u16);</span>
<span class="line" id="L1920">                std.debug.assert(path_space.data[path_space.len] == <span class="tok-number">0</span>);</span>
<span class="line" id="L1921">                <span class="tok-kw">return</span> path_space;</span>
<span class="line" id="L1922">            }</span>
<span class="line" id="L1923">            <span class="tok-kw">return</span> <span class="tok-kw">error</span>.BadPathName;</span>
<span class="line" id="L1924">        },</span>
<span class="line" id="L1925">    });</span>
<span class="line" id="L1926">    path_space.data[path_space.len] = <span class="tok-number">0</span>;</span>
<span class="line" id="L1927">    <span class="tok-kw">return</span> path_space;</span>
<span class="line" id="L1928">}</span>
<span class="line" id="L1929"></span>
<span class="line" id="L1930"><span class="tok-kw">fn</span> <span class="tok-fn">getFullPathNameW</span>(path: [*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u16</span>, out: []<span class="tok-type">u16</span>) !<span class="tok-type">usize</span> {</span>
<span class="line" id="L1931">    <span class="tok-kw">const</span> result = kernel32.GetFullPathNameW(path, <span class="tok-builtin">@intCast</span>(<span class="tok-type">u32</span>, out.len), std.meta.assumeSentinel(out.ptr, <span class="tok-number">0</span>), <span class="tok-null">null</span>);</span>
<span class="line" id="L1932">    <span class="tok-kw">if</span> (result == <span class="tok-number">0</span>) {</span>
<span class="line" id="L1933">        <span class="tok-kw">switch</span> (kernel32.GetLastError()) {</span>
<span class="line" id="L1934">            <span class="tok-kw">else</span> =&gt; |err| <span class="tok-kw">return</span> unexpectedError(err),</span>
<span class="line" id="L1935">        }</span>
<span class="line" id="L1936">    }</span>
<span class="line" id="L1937">    <span class="tok-kw">return</span> result;</span>
<span class="line" id="L1938">}</span>
<span class="line" id="L1939"></span>
<span class="line" id="L1940"><span class="tok-comment">/// Assumes an absolute path.</span></span>
<span class="line" id="L1941"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">wToPrefixedFileW</span>(s: []<span class="tok-kw">const</span> <span class="tok-type">u16</span>) !PathSpace {</span>
<span class="line" id="L1942">    <span class="tok-comment">// TODO https://github.com/ziglang/zig/issues/2765</span>
</span>
<span class="line" id="L1943">    <span class="tok-kw">var</span> path_space: PathSpace = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L1944"></span>
<span class="line" id="L1945">    <span class="tok-kw">const</span> start_index = <span class="tok-kw">if</span> (mem.startsWith(<span class="tok-type">u16</span>, s, &amp;[_]<span class="tok-type">u16</span>{ <span class="tok-str">'\\'</span>, <span class="tok-str">'?'</span> })) <span class="tok-number">0</span> <span class="tok-kw">else</span> blk: {</span>
<span class="line" id="L1946">        <span class="tok-kw">const</span> prefix = [_]<span class="tok-type">u16</span>{ <span class="tok-str">'\\'</span>, <span class="tok-str">'?'</span>, <span class="tok-str">'?'</span>, <span class="tok-str">'\\'</span> };</span>
<span class="line" id="L1947">        mem.copy(<span class="tok-type">u16</span>, path_space.data[<span class="tok-number">0</span>..], &amp;prefix);</span>
<span class="line" id="L1948">        <span class="tok-kw">break</span> :blk prefix.len;</span>
<span class="line" id="L1949">    };</span>
<span class="line" id="L1950">    path_space.len = start_index + s.len;</span>
<span class="line" id="L1951">    <span class="tok-kw">if</span> (path_space.len &gt; path_space.data.len) <span class="tok-kw">return</span> <span class="tok-kw">error</span>.NameTooLong;</span>
<span class="line" id="L1952">    mem.copy(<span class="tok-type">u16</span>, path_space.data[start_index..], s);</span>
<span class="line" id="L1953">    <span class="tok-comment">// &gt; File I/O functions in the Windows API convert &quot;/&quot; to &quot;\&quot; as part of</span>
</span>
<span class="line" id="L1954">    <span class="tok-comment">// &gt; converting the name to an NT-style name, except when using the &quot;\\?\&quot;</span>
</span>
<span class="line" id="L1955">    <span class="tok-comment">// &gt; prefix as detailed in the following sections.</span>
</span>
<span class="line" id="L1956">    <span class="tok-comment">// from https://docs.microsoft.com/en-us/windows/desktop/FileIO/naming-a-file#maximum-path-length-limitation</span>
</span>
<span class="line" id="L1957">    <span class="tok-comment">// Because we want the larger maximum path length for absolute paths, we</span>
</span>
<span class="line" id="L1958">    <span class="tok-comment">// convert forward slashes to backward slashes here.</span>
</span>
<span class="line" id="L1959">    <span class="tok-kw">for</span> (path_space.data[<span class="tok-number">0</span>..path_space.len]) |*elem| {</span>
<span class="line" id="L1960">        <span class="tok-kw">if</span> (elem.* == <span class="tok-str">'/'</span>) {</span>
<span class="line" id="L1961">            elem.* = <span class="tok-str">'\\'</span>;</span>
<span class="line" id="L1962">        }</span>
<span class="line" id="L1963">    }</span>
<span class="line" id="L1964">    path_space.data[path_space.len] = <span class="tok-number">0</span>;</span>
<span class="line" id="L1965">    <span class="tok-kw">return</span> path_space;</span>
<span class="line" id="L1966">}</span>
<span class="line" id="L1967"></span>
<span class="line" id="L1968"><span class="tok-kw">inline</span> <span class="tok-kw">fn</span> <span class="tok-fn">MAKELANGID</span>(p: <span class="tok-type">c_ushort</span>, s: <span class="tok-type">c_ushort</span>) LANGID {</span>
<span class="line" id="L1969">    <span class="tok-kw">return</span> (s &lt;&lt; <span class="tok-number">10</span>) | p;</span>
<span class="line" id="L1970">}</span>
<span class="line" id="L1971"></span>
<span class="line" id="L1972"><span class="tok-comment">/// Loads a Winsock extension function in runtime specified by a GUID.</span></span>
<span class="line" id="L1973"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">loadWinsockExtensionFunction</span>(<span class="tok-kw">comptime</span> T: <span class="tok-type">type</span>, sock: ws2_32.SOCKET, guid: GUID) !T {</span>
<span class="line" id="L1974">    <span class="tok-kw">var</span> function: T = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L1975">    <span class="tok-kw">var</span> num_bytes: DWORD = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L1976"></span>
<span class="line" id="L1977">    <span class="tok-kw">const</span> rc = ws2_32.WSAIoctl(</span>
<span class="line" id="L1978">        sock,</span>
<span class="line" id="L1979">        ws2_32.SIO_GET_EXTENSION_FUNCTION_POINTER,</span>
<span class="line" id="L1980">        <span class="tok-builtin">@ptrCast</span>(*<span class="tok-kw">const</span> <span class="tok-type">anyopaque</span>, &amp;guid),</span>
<span class="line" id="L1981">        <span class="tok-builtin">@sizeOf</span>(GUID),</span>
<span class="line" id="L1982">        &amp;function,</span>
<span class="line" id="L1983">        <span class="tok-builtin">@sizeOf</span>(T),</span>
<span class="line" id="L1984">        &amp;num_bytes,</span>
<span class="line" id="L1985">        <span class="tok-null">null</span>,</span>
<span class="line" id="L1986">        <span class="tok-null">null</span>,</span>
<span class="line" id="L1987">    );</span>
<span class="line" id="L1988"></span>
<span class="line" id="L1989">    <span class="tok-kw">if</span> (rc == ws2_32.SOCKET_ERROR) {</span>
<span class="line" id="L1990">        <span class="tok-kw">return</span> <span class="tok-kw">switch</span> (ws2_32.WSAGetLastError()) {</span>
<span class="line" id="L1991">            .WSAEOPNOTSUPP =&gt; <span class="tok-kw">error</span>.OperationNotSupported,</span>
<span class="line" id="L1992">            .WSAENOTSOCK =&gt; <span class="tok-kw">error</span>.FileDescriptorNotASocket,</span>
<span class="line" id="L1993">            <span class="tok-kw">else</span> =&gt; |err| unexpectedWSAError(err),</span>
<span class="line" id="L1994">        };</span>
<span class="line" id="L1995">    }</span>
<span class="line" id="L1996"></span>
<span class="line" id="L1997">    <span class="tok-kw">if</span> (num_bytes != <span class="tok-builtin">@sizeOf</span>(T)) {</span>
<span class="line" id="L1998">        <span class="tok-kw">return</span> <span class="tok-kw">error</span>.ShortRead;</span>
<span class="line" id="L1999">    }</span>
<span class="line" id="L2000"></span>
<span class="line" id="L2001">    <span class="tok-kw">return</span> function;</span>
<span class="line" id="L2002">}</span>
<span class="line" id="L2003"></span>
<span class="line" id="L2004"><span class="tok-comment">/// Call this when you made a windows DLL call or something that does SetLastError</span></span>
<span class="line" id="L2005"><span class="tok-comment">/// and you get an unexpected error.</span></span>
<span class="line" id="L2006"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">unexpectedError</span>(err: Win32Error) std.os.UnexpectedError {</span>
<span class="line" id="L2007">    <span class="tok-kw">if</span> (std.os.unexpected_error_tracing) {</span>
<span class="line" id="L2008">        <span class="tok-comment">// 614 is the length of the longest windows error desciption</span>
</span>
<span class="line" id="L2009">        <span class="tok-kw">var</span> buf_wstr: [<span class="tok-number">614</span>]WCHAR = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L2010">        <span class="tok-kw">var</span> buf_utf8: [<span class="tok-number">614</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L2011">        <span class="tok-kw">const</span> len = kernel32.FormatMessageW(</span>
<span class="line" id="L2012">            FORMAT_MESSAGE_FROM_SYSTEM | FORMAT_MESSAGE_IGNORE_INSERTS,</span>
<span class="line" id="L2013">            <span class="tok-null">null</span>,</span>
<span class="line" id="L2014">            err,</span>
<span class="line" id="L2015">            MAKELANGID(LANG.NEUTRAL, SUBLANG.DEFAULT),</span>
<span class="line" id="L2016">            &amp;buf_wstr,</span>
<span class="line" id="L2017">            buf_wstr.len,</span>
<span class="line" id="L2018">            <span class="tok-null">null</span>,</span>
<span class="line" id="L2019">        );</span>
<span class="line" id="L2020">        _ = std.unicode.utf16leToUtf8(&amp;buf_utf8, buf_wstr[<span class="tok-number">0</span>..len]) <span class="tok-kw">catch</span> <span class="tok-kw">unreachable</span>;</span>
<span class="line" id="L2021">        std.debug.print(<span class="tok-str">&quot;error.Unexpected: GetLastError({}): {s}\n&quot;</span>, .{ <span class="tok-builtin">@enumToInt</span>(err), buf_utf8[<span class="tok-number">0</span>..len] });</span>
<span class="line" id="L2022">        std.debug.dumpCurrentStackTrace(<span class="tok-null">null</span>);</span>
<span class="line" id="L2023">    }</span>
<span class="line" id="L2024">    <span class="tok-kw">return</span> <span class="tok-kw">error</span>.Unexpected;</span>
<span class="line" id="L2025">}</span>
<span class="line" id="L2026"></span>
<span class="line" id="L2027"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">unexpectedWSAError</span>(err: ws2_32.WinsockError) std.os.UnexpectedError {</span>
<span class="line" id="L2028">    <span class="tok-kw">return</span> unexpectedError(<span class="tok-builtin">@intToEnum</span>(Win32Error, <span class="tok-builtin">@enumToInt</span>(err)));</span>
<span class="line" id="L2029">}</span>
<span class="line" id="L2030"></span>
<span class="line" id="L2031"><span class="tok-comment">/// Call this when you made a windows NtDll call</span></span>
<span class="line" id="L2032"><span class="tok-comment">/// and you get an unexpected status.</span></span>
<span class="line" id="L2033"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">unexpectedStatus</span>(status: NTSTATUS) std.os.UnexpectedError {</span>
<span class="line" id="L2034">    <span class="tok-kw">if</span> (std.os.unexpected_error_tracing) {</span>
<span class="line" id="L2035">        std.debug.print(<span class="tok-str">&quot;error.Unexpected NTSTATUS=0x{x}\n&quot;</span>, .{<span class="tok-builtin">@enumToInt</span>(status)});</span>
<span class="line" id="L2036">        std.debug.dumpCurrentStackTrace(<span class="tok-null">null</span>);</span>
<span class="line" id="L2037">    }</span>
<span class="line" id="L2038">    <span class="tok-kw">return</span> <span class="tok-kw">error</span>.Unexpected;</span>
<span class="line" id="L2039">}</span>
<span class="line" id="L2040"></span>
<span class="line" id="L2041"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> Win32Error = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;windows/win32error.zig&quot;</span>).Win32Error;</span>
<span class="line" id="L2042"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> NTSTATUS = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;windows/ntstatus.zig&quot;</span>).NTSTATUS;</span>
<span class="line" id="L2043"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> LANG = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;windows/lang.zig&quot;</span>);</span>
<span class="line" id="L2044"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SUBLANG = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;windows/sublang.zig&quot;</span>);</span>
<span class="line" id="L2045"></span>
<span class="line" id="L2046"><span class="tok-comment">/// The standard input device. Initially, this is the console input buffer, CONIN$.</span></span>
<span class="line" id="L2047"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> STD_INPUT_HANDLE = maxInt(DWORD) - <span class="tok-number">10</span> + <span class="tok-number">1</span>;</span>
<span class="line" id="L2048"></span>
<span class="line" id="L2049"><span class="tok-comment">/// The standard output device. Initially, this is the active console screen buffer, CONOUT$.</span></span>
<span class="line" id="L2050"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> STD_OUTPUT_HANDLE = maxInt(DWORD) - <span class="tok-number">11</span> + <span class="tok-number">1</span>;</span>
<span class="line" id="L2051"></span>
<span class="line" id="L2052"><span class="tok-comment">/// The standard error device. Initially, this is the active console screen buffer, CONOUT$.</span></span>
<span class="line" id="L2053"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> STD_ERROR_HANDLE = maxInt(DWORD) - <span class="tok-number">12</span> + <span class="tok-number">1</span>;</span>
<span class="line" id="L2054"></span>
<span class="line" id="L2055"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WINAPI: std.builtin.CallingConvention = <span class="tok-kw">if</span> (native_arch == .<span class="tok-type">i386</span>)</span>
<span class="line" id="L2056">    .Stdcall</span>
<span class="line" id="L2057"><span class="tok-kw">else</span></span>
<span class="line" id="L2058">    .C;</span>
<span class="line" id="L2059"></span>
<span class="line" id="L2060"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> BOOL = <span class="tok-type">c_int</span>;</span>
<span class="line" id="L2061"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> BOOLEAN = BYTE;</span>
<span class="line" id="L2062"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> BYTE = <span class="tok-type">u8</span>;</span>
<span class="line" id="L2063"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> CHAR = <span class="tok-type">u8</span>;</span>
<span class="line" id="L2064"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> UCHAR = <span class="tok-type">u8</span>;</span>
<span class="line" id="L2065"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FLOAT = <span class="tok-type">f32</span>;</span>
<span class="line" id="L2066"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> HANDLE = *<span class="tok-type">anyopaque</span>;</span>
<span class="line" id="L2067"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> HCRYPTPROV = ULONG_PTR;</span>
<span class="line" id="L2068"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> ATOM = <span class="tok-type">u16</span>;</span>
<span class="line" id="L2069"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> HBRUSH = *<span class="tok-kw">opaque</span> {};</span>
<span class="line" id="L2070"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> HCURSOR = *<span class="tok-kw">opaque</span> {};</span>
<span class="line" id="L2071"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> HICON = *<span class="tok-kw">opaque</span> {};</span>
<span class="line" id="L2072"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> HINSTANCE = *<span class="tok-kw">opaque</span> {};</span>
<span class="line" id="L2073"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> HMENU = *<span class="tok-kw">opaque</span> {};</span>
<span class="line" id="L2074"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> HMODULE = *<span class="tok-kw">opaque</span> {};</span>
<span class="line" id="L2075"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> HWND = *<span class="tok-kw">opaque</span> {};</span>
<span class="line" id="L2076"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> HDC = *<span class="tok-kw">opaque</span> {};</span>
<span class="line" id="L2077"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> HGLRC = *<span class="tok-kw">opaque</span> {};</span>
<span class="line" id="L2078"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FARPROC = *<span class="tok-kw">opaque</span> {};</span>
<span class="line" id="L2079"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> INT = <span class="tok-type">c_int</span>;</span>
<span class="line" id="L2080"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> LPCSTR = [*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> CHAR;</span>
<span class="line" id="L2081"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> LPCVOID = *<span class="tok-kw">const</span> <span class="tok-type">anyopaque</span>;</span>
<span class="line" id="L2082"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> LPSTR = [*:<span class="tok-number">0</span>]CHAR;</span>
<span class="line" id="L2083"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> LPVOID = *<span class="tok-type">anyopaque</span>;</span>
<span class="line" id="L2084"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> LPWSTR = [*:<span class="tok-number">0</span>]WCHAR;</span>
<span class="line" id="L2085"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> LPCWSTR = [*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> WCHAR;</span>
<span class="line" id="L2086"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> PVOID = *<span class="tok-type">anyopaque</span>;</span>
<span class="line" id="L2087"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> PWSTR = [*:<span class="tok-number">0</span>]WCHAR;</span>
<span class="line" id="L2088"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SIZE_T = <span class="tok-type">usize</span>;</span>
<span class="line" id="L2089"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> UINT = <span class="tok-type">c_uint</span>;</span>
<span class="line" id="L2090"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> ULONG_PTR = <span class="tok-type">usize</span>;</span>
<span class="line" id="L2091"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> LONG_PTR = <span class="tok-type">isize</span>;</span>
<span class="line" id="L2092"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> DWORD_PTR = ULONG_PTR;</span>
<span class="line" id="L2093"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WCHAR = <span class="tok-type">u16</span>;</span>
<span class="line" id="L2094"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WORD = <span class="tok-type">u16</span>;</span>
<span class="line" id="L2095"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> DWORD = <span class="tok-type">u32</span>;</span>
<span class="line" id="L2096"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> DWORD64 = <span class="tok-type">u64</span>;</span>
<span class="line" id="L2097"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> LARGE_INTEGER = <span class="tok-type">i64</span>;</span>
<span class="line" id="L2098"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> ULARGE_INTEGER = <span class="tok-type">u64</span>;</span>
<span class="line" id="L2099"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> USHORT = <span class="tok-type">u16</span>;</span>
<span class="line" id="L2100"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SHORT = <span class="tok-type">i16</span>;</span>
<span class="line" id="L2101"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> ULONG = <span class="tok-type">u32</span>;</span>
<span class="line" id="L2102"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> LONG = <span class="tok-type">i32</span>;</span>
<span class="line" id="L2103"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> ULONGLONG = <span class="tok-type">u64</span>;</span>
<span class="line" id="L2104"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> LONGLONG = <span class="tok-type">i64</span>;</span>
<span class="line" id="L2105"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> HLOCAL = HANDLE;</span>
<span class="line" id="L2106"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> LANGID = <span class="tok-type">c_ushort</span>;</span>
<span class="line" id="L2107"></span>
<span class="line" id="L2108"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WPARAM = <span class="tok-type">usize</span>;</span>
<span class="line" id="L2109"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> LPARAM = LONG_PTR;</span>
<span class="line" id="L2110"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> LRESULT = LONG_PTR;</span>
<span class="line" id="L2111"></span>
<span class="line" id="L2112"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> va_list = *<span class="tok-kw">opaque</span> {};</span>
<span class="line" id="L2113"></span>
<span class="line" id="L2114"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> TRUE = <span class="tok-number">1</span>;</span>
<span class="line" id="L2115"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FALSE = <span class="tok-number">0</span>;</span>
<span class="line" id="L2116"></span>
<span class="line" id="L2117"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> DEVICE_TYPE = ULONG;</span>
<span class="line" id="L2118"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FILE_DEVICE_BEEP: DEVICE_TYPE = <span class="tok-number">0x0001</span>;</span>
<span class="line" id="L2119"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FILE_DEVICE_CD_ROM: DEVICE_TYPE = <span class="tok-number">0x0002</span>;</span>
<span class="line" id="L2120"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FILE_DEVICE_CD_ROM_FILE_SYSTEM: DEVICE_TYPE = <span class="tok-number">0x0003</span>;</span>
<span class="line" id="L2121"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FILE_DEVICE_CONTROLLER: DEVICE_TYPE = <span class="tok-number">0x0004</span>;</span>
<span class="line" id="L2122"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FILE_DEVICE_DATALINK: DEVICE_TYPE = <span class="tok-number">0x0005</span>;</span>
<span class="line" id="L2123"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FILE_DEVICE_DFS: DEVICE_TYPE = <span class="tok-number">0x0006</span>;</span>
<span class="line" id="L2124"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FILE_DEVICE_DISK: DEVICE_TYPE = <span class="tok-number">0x0007</span>;</span>
<span class="line" id="L2125"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FILE_DEVICE_DISK_FILE_SYSTEM: DEVICE_TYPE = <span class="tok-number">0x0008</span>;</span>
<span class="line" id="L2126"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FILE_DEVICE_FILE_SYSTEM: DEVICE_TYPE = <span class="tok-number">0x0009</span>;</span>
<span class="line" id="L2127"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FILE_DEVICE_INPORT_PORT: DEVICE_TYPE = <span class="tok-number">0x000a</span>;</span>
<span class="line" id="L2128"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FILE_DEVICE_KEYBOARD: DEVICE_TYPE = <span class="tok-number">0x000b</span>;</span>
<span class="line" id="L2129"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FILE_DEVICE_MAILSLOT: DEVICE_TYPE = <span class="tok-number">0x000c</span>;</span>
<span class="line" id="L2130"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FILE_DEVICE_MIDI_IN: DEVICE_TYPE = <span class="tok-number">0x000d</span>;</span>
<span class="line" id="L2131"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FILE_DEVICE_MIDI_OUT: DEVICE_TYPE = <span class="tok-number">0x000e</span>;</span>
<span class="line" id="L2132"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FILE_DEVICE_MOUSE: DEVICE_TYPE = <span class="tok-number">0x000f</span>;</span>
<span class="line" id="L2133"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FILE_DEVICE_MULTI_UNC_PROVIDER: DEVICE_TYPE = <span class="tok-number">0x0010</span>;</span>
<span class="line" id="L2134"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FILE_DEVICE_NAMED_PIPE: DEVICE_TYPE = <span class="tok-number">0x0011</span>;</span>
<span class="line" id="L2135"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FILE_DEVICE_NETWORK: DEVICE_TYPE = <span class="tok-number">0x0012</span>;</span>
<span class="line" id="L2136"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FILE_DEVICE_NETWORK_BROWSER: DEVICE_TYPE = <span class="tok-number">0x0013</span>;</span>
<span class="line" id="L2137"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FILE_DEVICE_NETWORK_FILE_SYSTEM: DEVICE_TYPE = <span class="tok-number">0x0014</span>;</span>
<span class="line" id="L2138"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FILE_DEVICE_NULL: DEVICE_TYPE = <span class="tok-number">0x0015</span>;</span>
<span class="line" id="L2139"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FILE_DEVICE_PARALLEL_PORT: DEVICE_TYPE = <span class="tok-number">0x0016</span>;</span>
<span class="line" id="L2140"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FILE_DEVICE_PHYSICAL_NETCARD: DEVICE_TYPE = <span class="tok-number">0x0017</span>;</span>
<span class="line" id="L2141"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FILE_DEVICE_PRINTER: DEVICE_TYPE = <span class="tok-number">0x0018</span>;</span>
<span class="line" id="L2142"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FILE_DEVICE_SCANNER: DEVICE_TYPE = <span class="tok-number">0x0019</span>;</span>
<span class="line" id="L2143"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FILE_DEVICE_SERIAL_MOUSE_PORT: DEVICE_TYPE = <span class="tok-number">0x001a</span>;</span>
<span class="line" id="L2144"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FILE_DEVICE_SERIAL_PORT: DEVICE_TYPE = <span class="tok-number">0x001b</span>;</span>
<span class="line" id="L2145"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FILE_DEVICE_SCREEN: DEVICE_TYPE = <span class="tok-number">0x001c</span>;</span>
<span class="line" id="L2146"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FILE_DEVICE_SOUND: DEVICE_TYPE = <span class="tok-number">0x001d</span>;</span>
<span class="line" id="L2147"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FILE_DEVICE_STREAMS: DEVICE_TYPE = <span class="tok-number">0x001e</span>;</span>
<span class="line" id="L2148"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FILE_DEVICE_TAPE: DEVICE_TYPE = <span class="tok-number">0x001f</span>;</span>
<span class="line" id="L2149"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FILE_DEVICE_TAPE_FILE_SYSTEM: DEVICE_TYPE = <span class="tok-number">0x0020</span>;</span>
<span class="line" id="L2150"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FILE_DEVICE_TRANSPORT: DEVICE_TYPE = <span class="tok-number">0x0021</span>;</span>
<span class="line" id="L2151"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FILE_DEVICE_UNKNOWN: DEVICE_TYPE = <span class="tok-number">0x0022</span>;</span>
<span class="line" id="L2152"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FILE_DEVICE_VIDEO: DEVICE_TYPE = <span class="tok-number">0x0023</span>;</span>
<span class="line" id="L2153"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FILE_DEVICE_VIRTUAL_DISK: DEVICE_TYPE = <span class="tok-number">0x0024</span>;</span>
<span class="line" id="L2154"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FILE_DEVICE_WAVE_IN: DEVICE_TYPE = <span class="tok-number">0x0025</span>;</span>
<span class="line" id="L2155"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FILE_DEVICE_WAVE_OUT: DEVICE_TYPE = <span class="tok-number">0x0026</span>;</span>
<span class="line" id="L2156"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FILE_DEVICE_8042_PORT: DEVICE_TYPE = <span class="tok-number">0x0027</span>;</span>
<span class="line" id="L2157"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FILE_DEVICE_NETWORK_REDIRECTOR: DEVICE_TYPE = <span class="tok-number">0x0028</span>;</span>
<span class="line" id="L2158"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FILE_DEVICE_BATTERY: DEVICE_TYPE = <span class="tok-number">0x0029</span>;</span>
<span class="line" id="L2159"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FILE_DEVICE_BUS_EXTENDER: DEVICE_TYPE = <span class="tok-number">0x002a</span>;</span>
<span class="line" id="L2160"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FILE_DEVICE_MODEM: DEVICE_TYPE = <span class="tok-number">0x002b</span>;</span>
<span class="line" id="L2161"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FILE_DEVICE_VDM: DEVICE_TYPE = <span class="tok-number">0x002c</span>;</span>
<span class="line" id="L2162"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FILE_DEVICE_MASS_STORAGE: DEVICE_TYPE = <span class="tok-number">0x002d</span>;</span>
<span class="line" id="L2163"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FILE_DEVICE_SMB: DEVICE_TYPE = <span class="tok-number">0x002e</span>;</span>
<span class="line" id="L2164"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FILE_DEVICE_KS: DEVICE_TYPE = <span class="tok-number">0x002f</span>;</span>
<span class="line" id="L2165"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FILE_DEVICE_CHANGER: DEVICE_TYPE = <span class="tok-number">0x0030</span>;</span>
<span class="line" id="L2166"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FILE_DEVICE_SMARTCARD: DEVICE_TYPE = <span class="tok-number">0x0031</span>;</span>
<span class="line" id="L2167"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FILE_DEVICE_ACPI: DEVICE_TYPE = <span class="tok-number">0x0032</span>;</span>
<span class="line" id="L2168"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FILE_DEVICE_DVD: DEVICE_TYPE = <span class="tok-number">0x0033</span>;</span>
<span class="line" id="L2169"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FILE_DEVICE_FULLSCREEN_VIDEO: DEVICE_TYPE = <span class="tok-number">0x0034</span>;</span>
<span class="line" id="L2170"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FILE_DEVICE_DFS_FILE_SYSTEM: DEVICE_TYPE = <span class="tok-number">0x0035</span>;</span>
<span class="line" id="L2171"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FILE_DEVICE_DFS_VOLUME: DEVICE_TYPE = <span class="tok-number">0x0036</span>;</span>
<span class="line" id="L2172"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FILE_DEVICE_SERENUM: DEVICE_TYPE = <span class="tok-number">0x0037</span>;</span>
<span class="line" id="L2173"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FILE_DEVICE_TERMSRV: DEVICE_TYPE = <span class="tok-number">0x0038</span>;</span>
<span class="line" id="L2174"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FILE_DEVICE_KSEC: DEVICE_TYPE = <span class="tok-number">0x0039</span>;</span>
<span class="line" id="L2175"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FILE_DEVICE_FIPS: DEVICE_TYPE = <span class="tok-number">0x003a</span>;</span>
<span class="line" id="L2176"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FILE_DEVICE_INFINIBAND: DEVICE_TYPE = <span class="tok-number">0x003b</span>;</span>
<span class="line" id="L2177"><span class="tok-comment">// TODO: missing values?</span>
</span>
<span class="line" id="L2178"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FILE_DEVICE_VMBUS: DEVICE_TYPE = <span class="tok-number">0x003e</span>;</span>
<span class="line" id="L2179"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FILE_DEVICE_CRYPT_PROVIDER: DEVICE_TYPE = <span class="tok-number">0x003f</span>;</span>
<span class="line" id="L2180"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FILE_DEVICE_WPD: DEVICE_TYPE = <span class="tok-number">0x0040</span>;</span>
<span class="line" id="L2181"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FILE_DEVICE_BLUETOOTH: DEVICE_TYPE = <span class="tok-number">0x0041</span>;</span>
<span class="line" id="L2182"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FILE_DEVICE_MT_COMPOSITE: DEVICE_TYPE = <span class="tok-number">0x0042</span>;</span>
<span class="line" id="L2183"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FILE_DEVICE_MT_TRANSPORT: DEVICE_TYPE = <span class="tok-number">0x0043</span>;</span>
<span class="line" id="L2184"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FILE_DEVICE_BIOMETRIC: DEVICE_TYPE = <span class="tok-number">0x0044</span>;</span>
<span class="line" id="L2185"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FILE_DEVICE_PMI: DEVICE_TYPE = <span class="tok-number">0x0045</span>;</span>
<span class="line" id="L2186"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FILE_DEVICE_EHSTOR: DEVICE_TYPE = <span class="tok-number">0x0046</span>;</span>
<span class="line" id="L2187"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FILE_DEVICE_DEVAPI: DEVICE_TYPE = <span class="tok-number">0x0047</span>;</span>
<span class="line" id="L2188"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FILE_DEVICE_GPIO: DEVICE_TYPE = <span class="tok-number">0x0048</span>;</span>
<span class="line" id="L2189"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FILE_DEVICE_USBEX: DEVICE_TYPE = <span class="tok-number">0x0049</span>;</span>
<span class="line" id="L2190"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FILE_DEVICE_CONSOLE: DEVICE_TYPE = <span class="tok-number">0x0050</span>;</span>
<span class="line" id="L2191"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FILE_DEVICE_NFP: DEVICE_TYPE = <span class="tok-number">0x0051</span>;</span>
<span class="line" id="L2192"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FILE_DEVICE_SYSENV: DEVICE_TYPE = <span class="tok-number">0x0052</span>;</span>
<span class="line" id="L2193"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FILE_DEVICE_VIRTUAL_BLOCK: DEVICE_TYPE = <span class="tok-number">0x0053</span>;</span>
<span class="line" id="L2194"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FILE_DEVICE_POINT_OF_SERVICE: DEVICE_TYPE = <span class="tok-number">0x0054</span>;</span>
<span class="line" id="L2195"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FILE_DEVICE_STORAGE_REPLICATION: DEVICE_TYPE = <span class="tok-number">0x0055</span>;</span>
<span class="line" id="L2196"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FILE_DEVICE_TRUST_ENV: DEVICE_TYPE = <span class="tok-number">0x0056</span>;</span>
<span class="line" id="L2197"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FILE_DEVICE_UCM: DEVICE_TYPE = <span class="tok-number">0x0057</span>;</span>
<span class="line" id="L2198"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FILE_DEVICE_UCMTCPCI: DEVICE_TYPE = <span class="tok-number">0x0058</span>;</span>
<span class="line" id="L2199"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FILE_DEVICE_PERSISTENT_MEMORY: DEVICE_TYPE = <span class="tok-number">0x0059</span>;</span>
<span class="line" id="L2200"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FILE_DEVICE_NVDIMM: DEVICE_TYPE = <span class="tok-number">0x005a</span>;</span>
<span class="line" id="L2201"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FILE_DEVICE_HOLOGRAPHIC: DEVICE_TYPE = <span class="tok-number">0x005b</span>;</span>
<span class="line" id="L2202"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FILE_DEVICE_SDFXHCI: DEVICE_TYPE = <span class="tok-number">0x005c</span>;</span>
<span class="line" id="L2203"></span>
<span class="line" id="L2204"><span class="tok-comment">/// https://docs.microsoft.com/en-us/windows-hardware/drivers/kernel/buffer-descriptions-for-i-o-control-codes</span></span>
<span class="line" id="L2205"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> TransferType = <span class="tok-kw">enum</span>(<span class="tok-type">u2</span>) {</span>
<span class="line" id="L2206">    METHOD_BUFFERED = <span class="tok-number">0</span>,</span>
<span class="line" id="L2207">    METHOD_IN_DIRECT = <span class="tok-number">1</span>,</span>
<span class="line" id="L2208">    METHOD_OUT_DIRECT = <span class="tok-number">2</span>,</span>
<span class="line" id="L2209">    METHOD_NEITHER = <span class="tok-number">3</span>,</span>
<span class="line" id="L2210">};</span>
<span class="line" id="L2211"></span>
<span class="line" id="L2212"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FILE_ANY_ACCESS = <span class="tok-number">0</span>;</span>
<span class="line" id="L2213"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FILE_READ_ACCESS = <span class="tok-number">1</span>;</span>
<span class="line" id="L2214"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FILE_WRITE_ACCESS = <span class="tok-number">2</span>;</span>
<span class="line" id="L2215"></span>
<span class="line" id="L2216"><span class="tok-comment">/// https://docs.microsoft.com/en-us/windows-hardware/drivers/kernel/defining-i-o-control-codes</span></span>
<span class="line" id="L2217"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">CTL_CODE</span>(deviceType: <span class="tok-type">u16</span>, function: <span class="tok-type">u12</span>, method: TransferType, access: <span class="tok-type">u2</span>) DWORD {</span>
<span class="line" id="L2218">    <span class="tok-kw">return</span> (<span class="tok-builtin">@as</span>(DWORD, deviceType) &lt;&lt; <span class="tok-number">16</span>) |</span>
<span class="line" id="L2219">        (<span class="tok-builtin">@as</span>(DWORD, access) &lt;&lt; <span class="tok-number">14</span>) |</span>
<span class="line" id="L2220">        (<span class="tok-builtin">@as</span>(DWORD, function) &lt;&lt; <span class="tok-number">2</span>) |</span>
<span class="line" id="L2221">        <span class="tok-builtin">@enumToInt</span>(method);</span>
<span class="line" id="L2222">}</span>
<span class="line" id="L2223"></span>
<span class="line" id="L2224"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> INVALID_HANDLE_VALUE = <span class="tok-builtin">@intToPtr</span>(HANDLE, maxInt(<span class="tok-type">usize</span>));</span>
<span class="line" id="L2225"></span>
<span class="line" id="L2226"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> INVALID_FILE_ATTRIBUTES = <span class="tok-builtin">@as</span>(DWORD, maxInt(DWORD));</span>
<span class="line" id="L2227"></span>
<span class="line" id="L2228"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FILE_ALL_INFORMATION = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L2229">    BasicInformation: FILE_BASIC_INFORMATION,</span>
<span class="line" id="L2230">    StandardInformation: FILE_STANDARD_INFORMATION,</span>
<span class="line" id="L2231">    InternalInformation: FILE_INTERNAL_INFORMATION,</span>
<span class="line" id="L2232">    EaInformation: FILE_EA_INFORMATION,</span>
<span class="line" id="L2233">    AccessInformation: FILE_ACCESS_INFORMATION,</span>
<span class="line" id="L2234">    PositionInformation: FILE_POSITION_INFORMATION,</span>
<span class="line" id="L2235">    ModeInformation: FILE_MODE_INFORMATION,</span>
<span class="line" id="L2236">    AlignmentInformation: FILE_ALIGNMENT_INFORMATION,</span>
<span class="line" id="L2237">    NameInformation: FILE_NAME_INFORMATION,</span>
<span class="line" id="L2238">};</span>
<span class="line" id="L2239"></span>
<span class="line" id="L2240"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FILE_BASIC_INFORMATION = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L2241">    CreationTime: LARGE_INTEGER,</span>
<span class="line" id="L2242">    LastAccessTime: LARGE_INTEGER,</span>
<span class="line" id="L2243">    LastWriteTime: LARGE_INTEGER,</span>
<span class="line" id="L2244">    ChangeTime: LARGE_INTEGER,</span>
<span class="line" id="L2245">    FileAttributes: ULONG,</span>
<span class="line" id="L2246">};</span>
<span class="line" id="L2247"></span>
<span class="line" id="L2248"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FILE_STANDARD_INFORMATION = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L2249">    AllocationSize: LARGE_INTEGER,</span>
<span class="line" id="L2250">    EndOfFile: LARGE_INTEGER,</span>
<span class="line" id="L2251">    NumberOfLinks: ULONG,</span>
<span class="line" id="L2252">    DeletePending: BOOLEAN,</span>
<span class="line" id="L2253">    Directory: BOOLEAN,</span>
<span class="line" id="L2254">};</span>
<span class="line" id="L2255"></span>
<span class="line" id="L2256"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FILE_INTERNAL_INFORMATION = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L2257">    IndexNumber: LARGE_INTEGER,</span>
<span class="line" id="L2258">};</span>
<span class="line" id="L2259"></span>
<span class="line" id="L2260"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FILE_EA_INFORMATION = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L2261">    EaSize: ULONG,</span>
<span class="line" id="L2262">};</span>
<span class="line" id="L2263"></span>
<span class="line" id="L2264"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FILE_ACCESS_INFORMATION = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L2265">    AccessFlags: ACCESS_MASK,</span>
<span class="line" id="L2266">};</span>
<span class="line" id="L2267"></span>
<span class="line" id="L2268"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FILE_POSITION_INFORMATION = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L2269">    CurrentByteOffset: LARGE_INTEGER,</span>
<span class="line" id="L2270">};</span>
<span class="line" id="L2271"></span>
<span class="line" id="L2272"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FILE_END_OF_FILE_INFORMATION = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L2273">    EndOfFile: LARGE_INTEGER,</span>
<span class="line" id="L2274">};</span>
<span class="line" id="L2275"></span>
<span class="line" id="L2276"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FILE_MODE_INFORMATION = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L2277">    Mode: ULONG,</span>
<span class="line" id="L2278">};</span>
<span class="line" id="L2279"></span>
<span class="line" id="L2280"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FILE_ALIGNMENT_INFORMATION = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L2281">    AlignmentRequirement: ULONG,</span>
<span class="line" id="L2282">};</span>
<span class="line" id="L2283"></span>
<span class="line" id="L2284"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FILE_NAME_INFORMATION = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L2285">    FileNameLength: ULONG,</span>
<span class="line" id="L2286">    FileName: [<span class="tok-number">1</span>]WCHAR,</span>
<span class="line" id="L2287">};</span>
<span class="line" id="L2288"></span>
<span class="line" id="L2289"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FILE_RENAME_INFORMATION = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L2290">    ReplaceIfExists: BOOLEAN,</span>
<span class="line" id="L2291">    RootDirectory: ?HANDLE,</span>
<span class="line" id="L2292">    FileNameLength: ULONG,</span>
<span class="line" id="L2293">    FileName: [<span class="tok-number">1</span>]WCHAR,</span>
<span class="line" id="L2294">};</span>
<span class="line" id="L2295"></span>
<span class="line" id="L2296"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IO_STATUS_BLOCK = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L2297">    <span class="tok-comment">// &quot;DUMMYUNIONNAME&quot; expands to &quot;u&quot;</span>
</span>
<span class="line" id="L2298">    u: <span class="tok-kw">extern</span> <span class="tok-kw">union</span> {</span>
<span class="line" id="L2299">        Status: NTSTATUS,</span>
<span class="line" id="L2300">        Pointer: ?*<span class="tok-type">anyopaque</span>,</span>
<span class="line" id="L2301">    },</span>
<span class="line" id="L2302">    Information: ULONG_PTR,</span>
<span class="line" id="L2303">};</span>
<span class="line" id="L2304"></span>
<span class="line" id="L2305"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FILE_INFORMATION_CLASS = <span class="tok-kw">enum</span>(<span class="tok-type">c_int</span>) {</span>
<span class="line" id="L2306">    FileDirectoryInformation = <span class="tok-number">1</span>,</span>
<span class="line" id="L2307">    FileFullDirectoryInformation,</span>
<span class="line" id="L2308">    FileBothDirectoryInformation,</span>
<span class="line" id="L2309">    FileBasicInformation,</span>
<span class="line" id="L2310">    FileStandardInformation,</span>
<span class="line" id="L2311">    FileInternalInformation,</span>
<span class="line" id="L2312">    FileEaInformation,</span>
<span class="line" id="L2313">    FileAccessInformation,</span>
<span class="line" id="L2314">    FileNameInformation,</span>
<span class="line" id="L2315">    FileRenameInformation,</span>
<span class="line" id="L2316">    FileLinkInformation,</span>
<span class="line" id="L2317">    FileNamesInformation,</span>
<span class="line" id="L2318">    FileDispositionInformation,</span>
<span class="line" id="L2319">    FilePositionInformation,</span>
<span class="line" id="L2320">    FileFullEaInformation,</span>
<span class="line" id="L2321">    FileModeInformation,</span>
<span class="line" id="L2322">    FileAlignmentInformation,</span>
<span class="line" id="L2323">    FileAllInformation,</span>
<span class="line" id="L2324">    FileAllocationInformation,</span>
<span class="line" id="L2325">    FileEndOfFileInformation,</span>
<span class="line" id="L2326">    FileAlternateNameInformation,</span>
<span class="line" id="L2327">    FileStreamInformation,</span>
<span class="line" id="L2328">    FilePipeInformation,</span>
<span class="line" id="L2329">    FilePipeLocalInformation,</span>
<span class="line" id="L2330">    FilePipeRemoteInformation,</span>
<span class="line" id="L2331">    FileMailslotQueryInformation,</span>
<span class="line" id="L2332">    FileMailslotSetInformation,</span>
<span class="line" id="L2333">    FileCompressionInformation,</span>
<span class="line" id="L2334">    FileObjectIdInformation,</span>
<span class="line" id="L2335">    FileCompletionInformation,</span>
<span class="line" id="L2336">    FileMoveClusterInformation,</span>
<span class="line" id="L2337">    FileQuotaInformation,</span>
<span class="line" id="L2338">    FileReparsePointInformation,</span>
<span class="line" id="L2339">    FileNetworkOpenInformation,</span>
<span class="line" id="L2340">    FileAttributeTagInformation,</span>
<span class="line" id="L2341">    FileTrackingInformation,</span>
<span class="line" id="L2342">    FileIdBothDirectoryInformation,</span>
<span class="line" id="L2343">    FileIdFullDirectoryInformation,</span>
<span class="line" id="L2344">    FileValidDataLengthInformation,</span>
<span class="line" id="L2345">    FileShortNameInformation,</span>
<span class="line" id="L2346">    FileIoCompletionNotificationInformation,</span>
<span class="line" id="L2347">    FileIoStatusBlockRangeInformation,</span>
<span class="line" id="L2348">    FileIoPriorityHintInformation,</span>
<span class="line" id="L2349">    FileSfioReserveInformation,</span>
<span class="line" id="L2350">    FileSfioVolumeInformation,</span>
<span class="line" id="L2351">    FileHardLinkInformation,</span>
<span class="line" id="L2352">    FileProcessIdsUsingFileInformation,</span>
<span class="line" id="L2353">    FileNormalizedNameInformation,</span>
<span class="line" id="L2354">    FileNetworkPhysicalNameInformation,</span>
<span class="line" id="L2355">    FileIdGlobalTxDirectoryInformation,</span>
<span class="line" id="L2356">    FileIsRemoteDeviceInformation,</span>
<span class="line" id="L2357">    FileUnusedInformation,</span>
<span class="line" id="L2358">    FileNumaNodeInformation,</span>
<span class="line" id="L2359">    FileStandardLinkInformation,</span>
<span class="line" id="L2360">    FileRemoteProtocolInformation,</span>
<span class="line" id="L2361">    FileRenameInformationBypassAccessCheck,</span>
<span class="line" id="L2362">    FileLinkInformationBypassAccessCheck,</span>
<span class="line" id="L2363">    FileVolumeNameInformation,</span>
<span class="line" id="L2364">    FileIdInformation,</span>
<span class="line" id="L2365">    FileIdExtdDirectoryInformation,</span>
<span class="line" id="L2366">    FileReplaceCompletionInformation,</span>
<span class="line" id="L2367">    FileHardLinkFullIdInformation,</span>
<span class="line" id="L2368">    FileIdExtdBothDirectoryInformation,</span>
<span class="line" id="L2369">    FileDispositionInformationEx,</span>
<span class="line" id="L2370">    FileRenameInformationEx,</span>
<span class="line" id="L2371">    FileRenameInformationExBypassAccessCheck,</span>
<span class="line" id="L2372">    FileDesiredStorageClassInformation,</span>
<span class="line" id="L2373">    FileStatInformation,</span>
<span class="line" id="L2374">    FileMemoryPartitionInformation,</span>
<span class="line" id="L2375">    FileStatLxInformation,</span>
<span class="line" id="L2376">    FileCaseSensitiveInformation,</span>
<span class="line" id="L2377">    FileLinkInformationEx,</span>
<span class="line" id="L2378">    FileLinkInformationExBypassAccessCheck,</span>
<span class="line" id="L2379">    FileStorageReserveIdInformation,</span>
<span class="line" id="L2380">    FileCaseSensitiveInformationForceAccessCheck,</span>
<span class="line" id="L2381">    FileMaximumInformation,</span>
<span class="line" id="L2382">};</span>
<span class="line" id="L2383"></span>
<span class="line" id="L2384"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> OVERLAPPED = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L2385">    Internal: ULONG_PTR,</span>
<span class="line" id="L2386">    InternalHigh: ULONG_PTR,</span>
<span class="line" id="L2387">    DUMMYUNIONNAME: <span class="tok-kw">extern</span> <span class="tok-kw">union</span> {</span>
<span class="line" id="L2388">        DUMMYSTRUCTNAME: <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L2389">            Offset: DWORD,</span>
<span class="line" id="L2390">            OffsetHigh: DWORD,</span>
<span class="line" id="L2391">        },</span>
<span class="line" id="L2392">        Pointer: ?PVOID,</span>
<span class="line" id="L2393">    },</span>
<span class="line" id="L2394">    hEvent: ?HANDLE,</span>
<span class="line" id="L2395">};</span>
<span class="line" id="L2396"></span>
<span class="line" id="L2397"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> OVERLAPPED_ENTRY = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L2398">    lpCompletionKey: ULONG_PTR,</span>
<span class="line" id="L2399">    lpOverlapped: *OVERLAPPED,</span>
<span class="line" id="L2400">    Internal: ULONG_PTR,</span>
<span class="line" id="L2401">    dwNumberOfBytesTransferred: DWORD,</span>
<span class="line" id="L2402">};</span>
<span class="line" id="L2403"></span>
<span class="line" id="L2404"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> MAX_PATH = <span class="tok-number">260</span>;</span>
<span class="line" id="L2405"></span>
<span class="line" id="L2406"><span class="tok-comment">// TODO issue #305</span>
</span>
<span class="line" id="L2407"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FILE_INFO_BY_HANDLE_CLASS = <span class="tok-type">u32</span>;</span>
<span class="line" id="L2408"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FileBasicInfo = <span class="tok-number">0</span>;</span>
<span class="line" id="L2409"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FileStandardInfo = <span class="tok-number">1</span>;</span>
<span class="line" id="L2410"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FileNameInfo = <span class="tok-number">2</span>;</span>
<span class="line" id="L2411"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FileRenameInfo = <span class="tok-number">3</span>;</span>
<span class="line" id="L2412"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FileDispositionInfo = <span class="tok-number">4</span>;</span>
<span class="line" id="L2413"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FileAllocationInfo = <span class="tok-number">5</span>;</span>
<span class="line" id="L2414"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FileEndOfFileInfo = <span class="tok-number">6</span>;</span>
<span class="line" id="L2415"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FileStreamInfo = <span class="tok-number">7</span>;</span>
<span class="line" id="L2416"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FileCompressionInfo = <span class="tok-number">8</span>;</span>
<span class="line" id="L2417"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FileAttributeTagInfo = <span class="tok-number">9</span>;</span>
<span class="line" id="L2418"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FileIdBothDirectoryInfo = <span class="tok-number">10</span>;</span>
<span class="line" id="L2419"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FileIdBothDirectoryRestartInfo = <span class="tok-number">11</span>;</span>
<span class="line" id="L2420"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FileIoPriorityHintInfo = <span class="tok-number">12</span>;</span>
<span class="line" id="L2421"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FileRemoteProtocolInfo = <span class="tok-number">13</span>;</span>
<span class="line" id="L2422"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FileFullDirectoryInfo = <span class="tok-number">14</span>;</span>
<span class="line" id="L2423"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FileFullDirectoryRestartInfo = <span class="tok-number">15</span>;</span>
<span class="line" id="L2424"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FileStorageInfo = <span class="tok-number">16</span>;</span>
<span class="line" id="L2425"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FileAlignmentInfo = <span class="tok-number">17</span>;</span>
<span class="line" id="L2426"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FileIdInfo = <span class="tok-number">18</span>;</span>
<span class="line" id="L2427"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FileIdExtdDirectoryInfo = <span class="tok-number">19</span>;</span>
<span class="line" id="L2428"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FileIdExtdDirectoryRestartInfo = <span class="tok-number">20</span>;</span>
<span class="line" id="L2429"></span>
<span class="line" id="L2430"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> BY_HANDLE_FILE_INFORMATION = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L2431">    dwFileAttributes: DWORD,</span>
<span class="line" id="L2432">    ftCreationTime: FILETIME,</span>
<span class="line" id="L2433">    ftLastAccessTime: FILETIME,</span>
<span class="line" id="L2434">    ftLastWriteTime: FILETIME,</span>
<span class="line" id="L2435">    dwVolumeSerialNumber: DWORD,</span>
<span class="line" id="L2436">    nFileSizeHigh: DWORD,</span>
<span class="line" id="L2437">    nFileSizeLow: DWORD,</span>
<span class="line" id="L2438">    nNumberOfLinks: DWORD,</span>
<span class="line" id="L2439">    nFileIndexHigh: DWORD,</span>
<span class="line" id="L2440">    nFileIndexLow: DWORD,</span>
<span class="line" id="L2441">};</span>
<span class="line" id="L2442"></span>
<span class="line" id="L2443"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FILE_NAME_INFO = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L2444">    FileNameLength: DWORD,</span>
<span class="line" id="L2445">    FileName: [<span class="tok-number">1</span>]WCHAR,</span>
<span class="line" id="L2446">};</span>
<span class="line" id="L2447"></span>
<span class="line" id="L2448"><span class="tok-comment">/// Return the normalized drive name. This is the default.</span></span>
<span class="line" id="L2449"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FILE_NAME_NORMALIZED = <span class="tok-number">0x0</span>;</span>
<span class="line" id="L2450"></span>
<span class="line" id="L2451"><span class="tok-comment">/// Return the opened file name (not normalized).</span></span>
<span class="line" id="L2452"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FILE_NAME_OPENED = <span class="tok-number">0x8</span>;</span>
<span class="line" id="L2453"></span>
<span class="line" id="L2454"><span class="tok-comment">/// Return the path with the drive letter. This is the default.</span></span>
<span class="line" id="L2455"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> VOLUME_NAME_DOS = <span class="tok-number">0x0</span>;</span>
<span class="line" id="L2456"></span>
<span class="line" id="L2457"><span class="tok-comment">/// Return the path with a volume GUID path instead of the drive name.</span></span>
<span class="line" id="L2458"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> VOLUME_NAME_GUID = <span class="tok-number">0x1</span>;</span>
<span class="line" id="L2459"></span>
<span class="line" id="L2460"><span class="tok-comment">/// Return the path with no drive information.</span></span>
<span class="line" id="L2461"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> VOLUME_NAME_NONE = <span class="tok-number">0x4</span>;</span>
<span class="line" id="L2462"></span>
<span class="line" id="L2463"><span class="tok-comment">/// Return the path with the volume device path.</span></span>
<span class="line" id="L2464"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> VOLUME_NAME_NT = <span class="tok-number">0x2</span>;</span>
<span class="line" id="L2465"></span>
<span class="line" id="L2466"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SECURITY_ATTRIBUTES = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L2467">    nLength: DWORD,</span>
<span class="line" id="L2468">    lpSecurityDescriptor: ?*<span class="tok-type">anyopaque</span>,</span>
<span class="line" id="L2469">    bInheritHandle: BOOL,</span>
<span class="line" id="L2470">};</span>
<span class="line" id="L2471"></span>
<span class="line" id="L2472"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> PIPE_ACCESS_INBOUND = <span class="tok-number">0x00000001</span>;</span>
<span class="line" id="L2473"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> PIPE_ACCESS_OUTBOUND = <span class="tok-number">0x00000002</span>;</span>
<span class="line" id="L2474"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> PIPE_ACCESS_DUPLEX = <span class="tok-number">0x00000003</span>;</span>
<span class="line" id="L2475"></span>
<span class="line" id="L2476"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> PIPE_TYPE_BYTE = <span class="tok-number">0x00000000</span>;</span>
<span class="line" id="L2477"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> PIPE_TYPE_MESSAGE = <span class="tok-number">0x00000004</span>;</span>
<span class="line" id="L2478"></span>
<span class="line" id="L2479"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> PIPE_READMODE_BYTE = <span class="tok-number">0x00000000</span>;</span>
<span class="line" id="L2480"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> PIPE_READMODE_MESSAGE = <span class="tok-number">0x00000002</span>;</span>
<span class="line" id="L2481"></span>
<span class="line" id="L2482"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> PIPE_WAIT = <span class="tok-number">0x00000000</span>;</span>
<span class="line" id="L2483"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> PIPE_NOWAIT = <span class="tok-number">0x00000001</span>;</span>
<span class="line" id="L2484"></span>
<span class="line" id="L2485"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> GENERIC_READ = <span class="tok-number">0x80000000</span>;</span>
<span class="line" id="L2486"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> GENERIC_WRITE = <span class="tok-number">0x40000000</span>;</span>
<span class="line" id="L2487"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> GENERIC_EXECUTE = <span class="tok-number">0x20000000</span>;</span>
<span class="line" id="L2488"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> GENERIC_ALL = <span class="tok-number">0x10000000</span>;</span>
<span class="line" id="L2489"></span>
<span class="line" id="L2490"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FILE_SHARE_DELETE = <span class="tok-number">0x00000004</span>;</span>
<span class="line" id="L2491"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FILE_SHARE_READ = <span class="tok-number">0x00000001</span>;</span>
<span class="line" id="L2492"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FILE_SHARE_WRITE = <span class="tok-number">0x00000002</span>;</span>
<span class="line" id="L2493"></span>
<span class="line" id="L2494"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> DELETE = <span class="tok-number">0x00010000</span>;</span>
<span class="line" id="L2495"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> READ_CONTROL = <span class="tok-number">0x00020000</span>;</span>
<span class="line" id="L2496"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WRITE_DAC = <span class="tok-number">0x00040000</span>;</span>
<span class="line" id="L2497"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WRITE_OWNER = <span class="tok-number">0x00080000</span>;</span>
<span class="line" id="L2498"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SYNCHRONIZE = <span class="tok-number">0x00100000</span>;</span>
<span class="line" id="L2499"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> STANDARD_RIGHTS_READ = READ_CONTROL;</span>
<span class="line" id="L2500"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> STANDARD_RIGHTS_WRITE = READ_CONTROL;</span>
<span class="line" id="L2501"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> STANDARD_RIGHTS_EXECUTE = READ_CONTROL;</span>
<span class="line" id="L2502"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> STANDARD_RIGHTS_REQUIRED = DELETE | READ_CONTROL | WRITE_DAC | WRITE_OWNER;</span>
<span class="line" id="L2503"></span>
<span class="line" id="L2504"><span class="tok-comment">// disposition for NtCreateFile</span>
</span>
<span class="line" id="L2505"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FILE_SUPERSEDE = <span class="tok-number">0</span>;</span>
<span class="line" id="L2506"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FILE_OPEN = <span class="tok-number">1</span>;</span>
<span class="line" id="L2507"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FILE_CREATE = <span class="tok-number">2</span>;</span>
<span class="line" id="L2508"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FILE_OPEN_IF = <span class="tok-number">3</span>;</span>
<span class="line" id="L2509"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FILE_OVERWRITE = <span class="tok-number">4</span>;</span>
<span class="line" id="L2510"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FILE_OVERWRITE_IF = <span class="tok-number">5</span>;</span>
<span class="line" id="L2511"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FILE_MAXIMUM_DISPOSITION = <span class="tok-number">5</span>;</span>
<span class="line" id="L2512"></span>
<span class="line" id="L2513"><span class="tok-comment">// flags for NtCreateFile and NtOpenFile</span>
</span>
<span class="line" id="L2514"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FILE_READ_DATA = <span class="tok-number">0x00000001</span>;</span>
<span class="line" id="L2515"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FILE_LIST_DIRECTORY = <span class="tok-number">0x00000001</span>;</span>
<span class="line" id="L2516"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FILE_WRITE_DATA = <span class="tok-number">0x00000002</span>;</span>
<span class="line" id="L2517"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FILE_ADD_FILE = <span class="tok-number">0x00000002</span>;</span>
<span class="line" id="L2518"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FILE_APPEND_DATA = <span class="tok-number">0x00000004</span>;</span>
<span class="line" id="L2519"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FILE_ADD_SUBDIRECTORY = <span class="tok-number">0x00000004</span>;</span>
<span class="line" id="L2520"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FILE_CREATE_PIPE_INSTANCE = <span class="tok-number">0x00000004</span>;</span>
<span class="line" id="L2521"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FILE_READ_EA = <span class="tok-number">0x00000008</span>;</span>
<span class="line" id="L2522"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FILE_WRITE_EA = <span class="tok-number">0x00000010</span>;</span>
<span class="line" id="L2523"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FILE_EXECUTE = <span class="tok-number">0x00000020</span>;</span>
<span class="line" id="L2524"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FILE_TRAVERSE = <span class="tok-number">0x00000020</span>;</span>
<span class="line" id="L2525"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FILE_DELETE_CHILD = <span class="tok-number">0x00000040</span>;</span>
<span class="line" id="L2526"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FILE_READ_ATTRIBUTES = <span class="tok-number">0x00000080</span>;</span>
<span class="line" id="L2527"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FILE_WRITE_ATTRIBUTES = <span class="tok-number">0x00000100</span>;</span>
<span class="line" id="L2528"></span>
<span class="line" id="L2529"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FILE_DIRECTORY_FILE = <span class="tok-number">0x00000001</span>;</span>
<span class="line" id="L2530"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FILE_WRITE_THROUGH = <span class="tok-number">0x00000002</span>;</span>
<span class="line" id="L2531"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FILE_SEQUENTIAL_ONLY = <span class="tok-number">0x00000004</span>;</span>
<span class="line" id="L2532"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FILE_NO_INTERMEDIATE_BUFFERING = <span class="tok-number">0x00000008</span>;</span>
<span class="line" id="L2533"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FILE_SYNCHRONOUS_IO_ALERT = <span class="tok-number">0x00000010</span>;</span>
<span class="line" id="L2534"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FILE_SYNCHRONOUS_IO_NONALERT = <span class="tok-number">0x00000020</span>;</span>
<span class="line" id="L2535"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FILE_NON_DIRECTORY_FILE = <span class="tok-number">0x00000040</span>;</span>
<span class="line" id="L2536"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FILE_CREATE_TREE_CONNECTION = <span class="tok-number">0x00000080</span>;</span>
<span class="line" id="L2537"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FILE_COMPLETE_IF_OPLOCKED = <span class="tok-number">0x00000100</span>;</span>
<span class="line" id="L2538"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FILE_NO_EA_KNOWLEDGE = <span class="tok-number">0x00000200</span>;</span>
<span class="line" id="L2539"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FILE_OPEN_FOR_RECOVERY = <span class="tok-number">0x00000400</span>;</span>
<span class="line" id="L2540"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FILE_RANDOM_ACCESS = <span class="tok-number">0x00000800</span>;</span>
<span class="line" id="L2541"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FILE_DELETE_ON_CLOSE = <span class="tok-number">0x00001000</span>;</span>
<span class="line" id="L2542"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FILE_OPEN_BY_FILE_ID = <span class="tok-number">0x00002000</span>;</span>
<span class="line" id="L2543"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FILE_OPEN_FOR_BACKUP_INTENT = <span class="tok-number">0x00004000</span>;</span>
<span class="line" id="L2544"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FILE_NO_COMPRESSION = <span class="tok-number">0x00008000</span>;</span>
<span class="line" id="L2545"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FILE_RESERVE_OPFILTER = <span class="tok-number">0x00100000</span>;</span>
<span class="line" id="L2546"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FILE_OPEN_REPARSE_POINT = <span class="tok-number">0x00200000</span>;</span>
<span class="line" id="L2547"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FILE_OPEN_OFFLINE_FILE = <span class="tok-number">0x00400000</span>;</span>
<span class="line" id="L2548"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FILE_OPEN_FOR_FREE_SPACE_QUERY = <span class="tok-number">0x00800000</span>;</span>
<span class="line" id="L2549"></span>
<span class="line" id="L2550"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> CREATE_ALWAYS = <span class="tok-number">2</span>;</span>
<span class="line" id="L2551"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> CREATE_NEW = <span class="tok-number">1</span>;</span>
<span class="line" id="L2552"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> OPEN_ALWAYS = <span class="tok-number">4</span>;</span>
<span class="line" id="L2553"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> OPEN_EXISTING = <span class="tok-number">3</span>;</span>
<span class="line" id="L2554"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> TRUNCATE_EXISTING = <span class="tok-number">5</span>;</span>
<span class="line" id="L2555"></span>
<span class="line" id="L2556"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FILE_ATTRIBUTE_ARCHIVE = <span class="tok-number">0x20</span>;</span>
<span class="line" id="L2557"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FILE_ATTRIBUTE_COMPRESSED = <span class="tok-number">0x800</span>;</span>
<span class="line" id="L2558"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FILE_ATTRIBUTE_DEVICE = <span class="tok-number">0x40</span>;</span>
<span class="line" id="L2559"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FILE_ATTRIBUTE_DIRECTORY = <span class="tok-number">0x10</span>;</span>
<span class="line" id="L2560"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FILE_ATTRIBUTE_ENCRYPTED = <span class="tok-number">0x4000</span>;</span>
<span class="line" id="L2561"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FILE_ATTRIBUTE_HIDDEN = <span class="tok-number">0x2</span>;</span>
<span class="line" id="L2562"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FILE_ATTRIBUTE_INTEGRITY_STREAM = <span class="tok-number">0x8000</span>;</span>
<span class="line" id="L2563"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FILE_ATTRIBUTE_NORMAL = <span class="tok-number">0x80</span>;</span>
<span class="line" id="L2564"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FILE_ATTRIBUTE_NOT_CONTENT_INDEXED = <span class="tok-number">0x2000</span>;</span>
<span class="line" id="L2565"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FILE_ATTRIBUTE_NO_SCRUB_DATA = <span class="tok-number">0x20000</span>;</span>
<span class="line" id="L2566"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FILE_ATTRIBUTE_OFFLINE = <span class="tok-number">0x1000</span>;</span>
<span class="line" id="L2567"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FILE_ATTRIBUTE_READONLY = <span class="tok-number">0x1</span>;</span>
<span class="line" id="L2568"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FILE_ATTRIBUTE_RECALL_ON_DATA_ACCESS = <span class="tok-number">0x400000</span>;</span>
<span class="line" id="L2569"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FILE_ATTRIBUTE_RECALL_ON_OPEN = <span class="tok-number">0x40000</span>;</span>
<span class="line" id="L2570"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FILE_ATTRIBUTE_REPARSE_POINT = <span class="tok-number">0x400</span>;</span>
<span class="line" id="L2571"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FILE_ATTRIBUTE_SPARSE_FILE = <span class="tok-number">0x200</span>;</span>
<span class="line" id="L2572"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FILE_ATTRIBUTE_SYSTEM = <span class="tok-number">0x4</span>;</span>
<span class="line" id="L2573"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FILE_ATTRIBUTE_TEMPORARY = <span class="tok-number">0x100</span>;</span>
<span class="line" id="L2574"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FILE_ATTRIBUTE_VIRTUAL = <span class="tok-number">0x10000</span>;</span>
<span class="line" id="L2575"></span>
<span class="line" id="L2576"><span class="tok-comment">// flags for CreateEvent</span>
</span>
<span class="line" id="L2577"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> CREATE_EVENT_INITIAL_SET = <span class="tok-number">0x00000002</span>;</span>
<span class="line" id="L2578"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> CREATE_EVENT_MANUAL_RESET = <span class="tok-number">0x00000001</span>;</span>
<span class="line" id="L2579"></span>
<span class="line" id="L2580"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> EVENT_ALL_ACCESS = <span class="tok-number">0x1F0003</span>;</span>
<span class="line" id="L2581"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> EVENT_MODIFY_STATE = <span class="tok-number">0x0002</span>;</span>
<span class="line" id="L2582"></span>
<span class="line" id="L2583"><span class="tok-comment">// MEMORY_BASIC_INFORMATION.Type flags for VirtualQuery</span>
</span>
<span class="line" id="L2584"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> MEM_IMAGE = <span class="tok-number">0x1000000</span>;</span>
<span class="line" id="L2585"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> MEM_MAPPED = <span class="tok-number">0x40000</span>;</span>
<span class="line" id="L2586"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> MEM_PRIVATE = <span class="tok-number">0x20000</span>;</span>
<span class="line" id="L2587"></span>
<span class="line" id="L2588"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> PROCESS_INFORMATION = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L2589">    hProcess: HANDLE,</span>
<span class="line" id="L2590">    hThread: HANDLE,</span>
<span class="line" id="L2591">    dwProcessId: DWORD,</span>
<span class="line" id="L2592">    dwThreadId: DWORD,</span>
<span class="line" id="L2593">};</span>
<span class="line" id="L2594"></span>
<span class="line" id="L2595"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> STARTUPINFOW = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L2596">    cb: DWORD,</span>
<span class="line" id="L2597">    lpReserved: ?LPWSTR,</span>
<span class="line" id="L2598">    lpDesktop: ?LPWSTR,</span>
<span class="line" id="L2599">    lpTitle: ?LPWSTR,</span>
<span class="line" id="L2600">    dwX: DWORD,</span>
<span class="line" id="L2601">    dwY: DWORD,</span>
<span class="line" id="L2602">    dwXSize: DWORD,</span>
<span class="line" id="L2603">    dwYSize: DWORD,</span>
<span class="line" id="L2604">    dwXCountChars: DWORD,</span>
<span class="line" id="L2605">    dwYCountChars: DWORD,</span>
<span class="line" id="L2606">    dwFillAttribute: DWORD,</span>
<span class="line" id="L2607">    dwFlags: DWORD,</span>
<span class="line" id="L2608">    wShowWindow: WORD,</span>
<span class="line" id="L2609">    cbReserved2: WORD,</span>
<span class="line" id="L2610">    lpReserved2: ?*BYTE,</span>
<span class="line" id="L2611">    hStdInput: ?HANDLE,</span>
<span class="line" id="L2612">    hStdOutput: ?HANDLE,</span>
<span class="line" id="L2613">    hStdError: ?HANDLE,</span>
<span class="line" id="L2614">};</span>
<span class="line" id="L2615"></span>
<span class="line" id="L2616"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> STARTF_FORCEONFEEDBACK = <span class="tok-number">0x00000040</span>;</span>
<span class="line" id="L2617"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> STARTF_FORCEOFFFEEDBACK = <span class="tok-number">0x00000080</span>;</span>
<span class="line" id="L2618"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> STARTF_PREVENTPINNING = <span class="tok-number">0x00002000</span>;</span>
<span class="line" id="L2619"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> STARTF_RUNFULLSCREEN = <span class="tok-number">0x00000020</span>;</span>
<span class="line" id="L2620"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> STARTF_TITLEISAPPID = <span class="tok-number">0x00001000</span>;</span>
<span class="line" id="L2621"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> STARTF_TITLEISLINKNAME = <span class="tok-number">0x00000800</span>;</span>
<span class="line" id="L2622"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> STARTF_UNTRUSTEDSOURCE = <span class="tok-number">0x00008000</span>;</span>
<span class="line" id="L2623"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> STARTF_USECOUNTCHARS = <span class="tok-number">0x00000008</span>;</span>
<span class="line" id="L2624"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> STARTF_USEFILLATTRIBUTE = <span class="tok-number">0x00000010</span>;</span>
<span class="line" id="L2625"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> STARTF_USEHOTKEY = <span class="tok-number">0x00000200</span>;</span>
<span class="line" id="L2626"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> STARTF_USEPOSITION = <span class="tok-number">0x00000004</span>;</span>
<span class="line" id="L2627"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> STARTF_USESHOWWINDOW = <span class="tok-number">0x00000001</span>;</span>
<span class="line" id="L2628"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> STARTF_USESIZE = <span class="tok-number">0x00000002</span>;</span>
<span class="line" id="L2629"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> STARTF_USESTDHANDLES = <span class="tok-number">0x00000100</span>;</span>
<span class="line" id="L2630"></span>
<span class="line" id="L2631"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> INFINITE = <span class="tok-number">4294967295</span>;</span>
<span class="line" id="L2632"></span>
<span class="line" id="L2633"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> MAXIMUM_WAIT_OBJECTS = <span class="tok-number">64</span>;</span>
<span class="line" id="L2634"></span>
<span class="line" id="L2635"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WAIT_ABANDONED = <span class="tok-number">0x00000080</span>;</span>
<span class="line" id="L2636"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WAIT_ABANDONED_0 = WAIT_ABANDONED + <span class="tok-number">0</span>;</span>
<span class="line" id="L2637"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WAIT_OBJECT_0 = <span class="tok-number">0x00000000</span>;</span>
<span class="line" id="L2638"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WAIT_TIMEOUT = <span class="tok-number">0x00000102</span>;</span>
<span class="line" id="L2639"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WAIT_FAILED = <span class="tok-number">0xFFFFFFFF</span>;</span>
<span class="line" id="L2640"></span>
<span class="line" id="L2641"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> HANDLE_FLAG_INHERIT = <span class="tok-number">0x00000001</span>;</span>
<span class="line" id="L2642"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> HANDLE_FLAG_PROTECT_FROM_CLOSE = <span class="tok-number">0x00000002</span>;</span>
<span class="line" id="L2643"></span>
<span class="line" id="L2644"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> MOVEFILE_COPY_ALLOWED = <span class="tok-number">2</span>;</span>
<span class="line" id="L2645"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> MOVEFILE_CREATE_HARDLINK = <span class="tok-number">16</span>;</span>
<span class="line" id="L2646"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> MOVEFILE_DELAY_UNTIL_REBOOT = <span class="tok-number">4</span>;</span>
<span class="line" id="L2647"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> MOVEFILE_FAIL_IF_NOT_TRACKABLE = <span class="tok-number">32</span>;</span>
<span class="line" id="L2648"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> MOVEFILE_REPLACE_EXISTING = <span class="tok-number">1</span>;</span>
<span class="line" id="L2649"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> MOVEFILE_WRITE_THROUGH = <span class="tok-number">8</span>;</span>
<span class="line" id="L2650"></span>
<span class="line" id="L2651"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FILE_BEGIN = <span class="tok-number">0</span>;</span>
<span class="line" id="L2652"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FILE_CURRENT = <span class="tok-number">1</span>;</span>
<span class="line" id="L2653"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FILE_END = <span class="tok-number">2</span>;</span>
<span class="line" id="L2654"></span>
<span class="line" id="L2655"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> HEAP_CREATE_ENABLE_EXECUTE = <span class="tok-number">0x00040000</span>;</span>
<span class="line" id="L2656"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> HEAP_REALLOC_IN_PLACE_ONLY = <span class="tok-number">0x00000010</span>;</span>
<span class="line" id="L2657"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> HEAP_GENERATE_EXCEPTIONS = <span class="tok-number">0x00000004</span>;</span>
<span class="line" id="L2658"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> HEAP_NO_SERIALIZE = <span class="tok-number">0x00000001</span>;</span>
<span class="line" id="L2659"></span>
<span class="line" id="L2660"><span class="tok-comment">// AllocationType values</span>
</span>
<span class="line" id="L2661"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> MEM_COMMIT = <span class="tok-number">0x1000</span>;</span>
<span class="line" id="L2662"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> MEM_RESERVE = <span class="tok-number">0x2000</span>;</span>
<span class="line" id="L2663"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> MEM_FREE = <span class="tok-number">0x10000</span>;</span>
<span class="line" id="L2664"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> MEM_RESET = <span class="tok-number">0x80000</span>;</span>
<span class="line" id="L2665"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> MEM_RESET_UNDO = <span class="tok-number">0x1000000</span>;</span>
<span class="line" id="L2666"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> MEM_LARGE_PAGES = <span class="tok-number">0x20000000</span>;</span>
<span class="line" id="L2667"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> MEM_PHYSICAL = <span class="tok-number">0x400000</span>;</span>
<span class="line" id="L2668"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> MEM_TOP_DOWN = <span class="tok-number">0x100000</span>;</span>
<span class="line" id="L2669"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> MEM_WRITE_WATCH = <span class="tok-number">0x200000</span>;</span>
<span class="line" id="L2670"></span>
<span class="line" id="L2671"><span class="tok-comment">// Protect values</span>
</span>
<span class="line" id="L2672"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> PAGE_EXECUTE = <span class="tok-number">0x10</span>;</span>
<span class="line" id="L2673"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> PAGE_EXECUTE_READ = <span class="tok-number">0x20</span>;</span>
<span class="line" id="L2674"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> PAGE_EXECUTE_READWRITE = <span class="tok-number">0x40</span>;</span>
<span class="line" id="L2675"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> PAGE_EXECUTE_WRITECOPY = <span class="tok-number">0x80</span>;</span>
<span class="line" id="L2676"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> PAGE_NOACCESS = <span class="tok-number">0x01</span>;</span>
<span class="line" id="L2677"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> PAGE_READONLY = <span class="tok-number">0x02</span>;</span>
<span class="line" id="L2678"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> PAGE_READWRITE = <span class="tok-number">0x04</span>;</span>
<span class="line" id="L2679"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> PAGE_WRITECOPY = <span class="tok-number">0x08</span>;</span>
<span class="line" id="L2680"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> PAGE_TARGETS_INVALID = <span class="tok-number">0x40000000</span>;</span>
<span class="line" id="L2681"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> PAGE_TARGETS_NO_UPDATE = <span class="tok-number">0x40000000</span>; <span class="tok-comment">// Same as PAGE_TARGETS_INVALID</span>
</span>
<span class="line" id="L2682"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> PAGE_GUARD = <span class="tok-number">0x100</span>;</span>
<span class="line" id="L2683"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> PAGE_NOCACHE = <span class="tok-number">0x200</span>;</span>
<span class="line" id="L2684"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> PAGE_WRITECOMBINE = <span class="tok-number">0x400</span>;</span>
<span class="line" id="L2685"></span>
<span class="line" id="L2686"><span class="tok-comment">// FreeType values</span>
</span>
<span class="line" id="L2687"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> MEM_COALESCE_PLACEHOLDERS = <span class="tok-number">0x1</span>;</span>
<span class="line" id="L2688"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> MEM_RESERVE_PLACEHOLDERS = <span class="tok-number">0x2</span>;</span>
<span class="line" id="L2689"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> MEM_DECOMMIT = <span class="tok-number">0x4000</span>;</span>
<span class="line" id="L2690"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> MEM_RELEASE = <span class="tok-number">0x8000</span>;</span>
<span class="line" id="L2691"></span>
<span class="line" id="L2692"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> PTHREAD_START_ROUTINE = <span class="tok-kw">switch</span> (builtin.zig_backend) {</span>
<span class="line" id="L2693">    .stage1 =&gt; <span class="tok-kw">fn</span> (LPVOID) <span class="tok-kw">callconv</span>(.C) DWORD,</span>
<span class="line" id="L2694">    <span class="tok-kw">else</span> =&gt; *<span class="tok-kw">const</span> <span class="tok-kw">fn</span> (LPVOID) <span class="tok-kw">callconv</span>(.C) DWORD,</span>
<span class="line" id="L2695">};</span>
<span class="line" id="L2696"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> LPTHREAD_START_ROUTINE = PTHREAD_START_ROUTINE;</span>
<span class="line" id="L2697"></span>
<span class="line" id="L2698"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WIN32_FIND_DATAW = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L2699">    dwFileAttributes: DWORD,</span>
<span class="line" id="L2700">    ftCreationTime: FILETIME,</span>
<span class="line" id="L2701">    ftLastAccessTime: FILETIME,</span>
<span class="line" id="L2702">    ftLastWriteTime: FILETIME,</span>
<span class="line" id="L2703">    nFileSizeHigh: DWORD,</span>
<span class="line" id="L2704">    nFileSizeLow: DWORD,</span>
<span class="line" id="L2705">    dwReserved0: DWORD,</span>
<span class="line" id="L2706">    dwReserved1: DWORD,</span>
<span class="line" id="L2707">    cFileName: [<span class="tok-number">260</span>]<span class="tok-type">u16</span>,</span>
<span class="line" id="L2708">    cAlternateFileName: [<span class="tok-number">14</span>]<span class="tok-type">u16</span>,</span>
<span class="line" id="L2709">};</span>
<span class="line" id="L2710"></span>
<span class="line" id="L2711"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FILETIME = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L2712">    dwLowDateTime: DWORD,</span>
<span class="line" id="L2713">    dwHighDateTime: DWORD,</span>
<span class="line" id="L2714">};</span>
<span class="line" id="L2715"></span>
<span class="line" id="L2716"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SYSTEM_INFO = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L2717">    anon1: <span class="tok-kw">extern</span> <span class="tok-kw">union</span> {</span>
<span class="line" id="L2718">        dwOemId: DWORD,</span>
<span class="line" id="L2719">        anon2: <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L2720">            wProcessorArchitecture: WORD,</span>
<span class="line" id="L2721">            wReserved: WORD,</span>
<span class="line" id="L2722">        },</span>
<span class="line" id="L2723">    },</span>
<span class="line" id="L2724">    dwPageSize: DWORD,</span>
<span class="line" id="L2725">    lpMinimumApplicationAddress: LPVOID,</span>
<span class="line" id="L2726">    lpMaximumApplicationAddress: LPVOID,</span>
<span class="line" id="L2727">    dwActiveProcessorMask: DWORD_PTR,</span>
<span class="line" id="L2728">    dwNumberOfProcessors: DWORD,</span>
<span class="line" id="L2729">    dwProcessorType: DWORD,</span>
<span class="line" id="L2730">    dwAllocationGranularity: DWORD,</span>
<span class="line" id="L2731">    wProcessorLevel: WORD,</span>
<span class="line" id="L2732">    wProcessorRevision: WORD,</span>
<span class="line" id="L2733">};</span>
<span class="line" id="L2734"></span>
<span class="line" id="L2735"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> HRESULT = <span class="tok-type">c_long</span>;</span>
<span class="line" id="L2736"></span>
<span class="line" id="L2737"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> KNOWNFOLDERID = GUID;</span>
<span class="line" id="L2738"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> GUID = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L2739">    Data1: <span class="tok-type">u32</span>,</span>
<span class="line" id="L2740">    Data2: <span class="tok-type">u16</span>,</span>
<span class="line" id="L2741">    Data3: <span class="tok-type">u16</span>,</span>
<span class="line" id="L2742">    Data4: [<span class="tok-number">8</span>]<span class="tok-type">u8</span>,</span>
<span class="line" id="L2743"></span>
<span class="line" id="L2744">    <span class="tok-kw">const</span> hex_offsets = <span class="tok-kw">switch</span> (builtin.target.cpu.arch.endian()) {</span>
<span class="line" id="L2745">        .Big =&gt; [<span class="tok-number">16</span>]<span class="tok-type">u6</span>{</span>
<span class="line" id="L2746">            <span class="tok-number">0</span>,  <span class="tok-number">2</span>,  <span class="tok-number">4</span>,  <span class="tok-number">6</span>,</span>
<span class="line" id="L2747">            <span class="tok-number">9</span>,  <span class="tok-number">11</span>, <span class="tok-number">14</span>, <span class="tok-number">16</span>,</span>
<span class="line" id="L2748">            <span class="tok-number">19</span>, <span class="tok-number">21</span>, <span class="tok-number">24</span>, <span class="tok-number">26</span>,</span>
<span class="line" id="L2749">            <span class="tok-number">28</span>, <span class="tok-number">30</span>, <span class="tok-number">32</span>, <span class="tok-number">34</span>,</span>
<span class="line" id="L2750">        },</span>
<span class="line" id="L2751">        .Little =&gt; [<span class="tok-number">16</span>]<span class="tok-type">u6</span>{</span>
<span class="line" id="L2752">            <span class="tok-number">6</span>,  <span class="tok-number">4</span>,  <span class="tok-number">2</span>,  <span class="tok-number">0</span>,</span>
<span class="line" id="L2753">            <span class="tok-number">11</span>, <span class="tok-number">9</span>,  <span class="tok-number">16</span>, <span class="tok-number">14</span>,</span>
<span class="line" id="L2754">            <span class="tok-number">19</span>, <span class="tok-number">21</span>, <span class="tok-number">24</span>, <span class="tok-number">26</span>,</span>
<span class="line" id="L2755">            <span class="tok-number">28</span>, <span class="tok-number">30</span>, <span class="tok-number">32</span>, <span class="tok-number">34</span>,</span>
<span class="line" id="L2756">        },</span>
<span class="line" id="L2757">    };</span>
<span class="line" id="L2758"></span>
<span class="line" id="L2759">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">parse</span>(s: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) GUID {</span>
<span class="line" id="L2760">        assert(s[<span class="tok-number">0</span>] == <span class="tok-str">'{'</span>);</span>
<span class="line" id="L2761">        assert(s[<span class="tok-number">37</span>] == <span class="tok-str">'}'</span>);</span>
<span class="line" id="L2762">        <span class="tok-kw">return</span> parseNoBraces(s[<span class="tok-number">1</span> .. s.len - <span class="tok-number">1</span>]) <span class="tok-kw">catch</span> <span class="tok-builtin">@panic</span>(<span class="tok-str">&quot;invalid GUID string&quot;</span>);</span>
<span class="line" id="L2763">    }</span>
<span class="line" id="L2764"></span>
<span class="line" id="L2765">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">parseNoBraces</span>(s: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) !GUID {</span>
<span class="line" id="L2766">        assert(s.len == <span class="tok-number">36</span>);</span>
<span class="line" id="L2767">        assert(s[<span class="tok-number">8</span>] == <span class="tok-str">'-'</span>);</span>
<span class="line" id="L2768">        assert(s[<span class="tok-number">13</span>] == <span class="tok-str">'-'</span>);</span>
<span class="line" id="L2769">        assert(s[<span class="tok-number">18</span>] == <span class="tok-str">'-'</span>);</span>
<span class="line" id="L2770">        assert(s[<span class="tok-number">23</span>] == <span class="tok-str">'-'</span>);</span>
<span class="line" id="L2771">        <span class="tok-kw">var</span> bytes: [<span class="tok-number">16</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L2772">        <span class="tok-kw">for</span> (hex_offsets) |hex_offset, i| {</span>
<span class="line" id="L2773">            bytes[i] = (<span class="tok-kw">try</span> std.fmt.charToDigit(s[hex_offset], <span class="tok-number">16</span>)) &lt;&lt; <span class="tok-number">4</span> |</span>
<span class="line" id="L2774">                <span class="tok-kw">try</span> std.fmt.charToDigit(s[hex_offset + <span class="tok-number">1</span>], <span class="tok-number">16</span>);</span>
<span class="line" id="L2775">        }</span>
<span class="line" id="L2776">        <span class="tok-kw">return</span> <span class="tok-builtin">@bitCast</span>(GUID, bytes);</span>
<span class="line" id="L2777">    }</span>
<span class="line" id="L2778">};</span>
<span class="line" id="L2779"></span>
<span class="line" id="L2780"><span class="tok-kw">test</span> <span class="tok-str">&quot;GUID&quot;</span> {</span>
<span class="line" id="L2781">    <span class="tok-kw">try</span> std.testing.expectEqual(</span>
<span class="line" id="L2782">        GUID{</span>
<span class="line" id="L2783">            .Data1 = <span class="tok-number">0x01234567</span>,</span>
<span class="line" id="L2784">            .Data2 = <span class="tok-number">0x89ab</span>,</span>
<span class="line" id="L2785">            .Data3 = <span class="tok-number">0xef10</span>,</span>
<span class="line" id="L2786">            .Data4 = <span class="tok-str">&quot;\x32\x54\x76\x98\xba\xdc\xfe\x91&quot;</span>.*,</span>
<span class="line" id="L2787">        },</span>
<span class="line" id="L2788">        GUID.parse(<span class="tok-str">&quot;{01234567-89AB-EF10-3254-7698badcfe91}&quot;</span>),</span>
<span class="line" id="L2789">    );</span>
<span class="line" id="L2790">}</span>
<span class="line" id="L2791"></span>
<span class="line" id="L2792"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FOLDERID_LocalAppData = GUID.parse(<span class="tok-str">&quot;{F1B32785-6FBA-4FCF-9D55-7B8E7F157091}&quot;</span>);</span>
<span class="line" id="L2793"></span>
<span class="line" id="L2794"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> KF_FLAG_DEFAULT = <span class="tok-number">0</span>;</span>
<span class="line" id="L2795"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> KF_FLAG_NO_APPCONTAINER_REDIRECTION = <span class="tok-number">65536</span>;</span>
<span class="line" id="L2796"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> KF_FLAG_CREATE = <span class="tok-number">32768</span>;</span>
<span class="line" id="L2797"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> KF_FLAG_DONT_VERIFY = <span class="tok-number">16384</span>;</span>
<span class="line" id="L2798"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> KF_FLAG_DONT_UNEXPAND = <span class="tok-number">8192</span>;</span>
<span class="line" id="L2799"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> KF_FLAG_NO_ALIAS = <span class="tok-number">4096</span>;</span>
<span class="line" id="L2800"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> KF_FLAG_INIT = <span class="tok-number">2048</span>;</span>
<span class="line" id="L2801"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> KF_FLAG_DEFAULT_PATH = <span class="tok-number">1024</span>;</span>
<span class="line" id="L2802"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> KF_FLAG_NOT_PARENT_RELATIVE = <span class="tok-number">512</span>;</span>
<span class="line" id="L2803"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> KF_FLAG_SIMPLE_IDLIST = <span class="tok-number">256</span>;</span>
<span class="line" id="L2804"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> KF_FLAG_ALIAS_ONLY = -<span class="tok-number">2147483648</span>;</span>
<span class="line" id="L2805"></span>
<span class="line" id="L2806"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> S_OK = <span class="tok-number">0</span>;</span>
<span class="line" id="L2807"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> E_NOTIMPL = <span class="tok-builtin">@bitCast</span>(<span class="tok-type">c_long</span>, <span class="tok-builtin">@as</span>(<span class="tok-type">c_ulong</span>, <span class="tok-number">0x80004001</span>));</span>
<span class="line" id="L2808"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> E_NOINTERFACE = <span class="tok-builtin">@bitCast</span>(<span class="tok-type">c_long</span>, <span class="tok-builtin">@as</span>(<span class="tok-type">c_ulong</span>, <span class="tok-number">0x80004002</span>));</span>
<span class="line" id="L2809"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> E_POINTER = <span class="tok-builtin">@bitCast</span>(<span class="tok-type">c_long</span>, <span class="tok-builtin">@as</span>(<span class="tok-type">c_ulong</span>, <span class="tok-number">0x80004003</span>));</span>
<span class="line" id="L2810"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> E_ABORT = <span class="tok-builtin">@bitCast</span>(<span class="tok-type">c_long</span>, <span class="tok-builtin">@as</span>(<span class="tok-type">c_ulong</span>, <span class="tok-number">0x80004004</span>));</span>
<span class="line" id="L2811"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> E_FAIL = <span class="tok-builtin">@bitCast</span>(<span class="tok-type">c_long</span>, <span class="tok-builtin">@as</span>(<span class="tok-type">c_ulong</span>, <span class="tok-number">0x80004005</span>));</span>
<span class="line" id="L2812"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> E_UNEXPECTED = <span class="tok-builtin">@bitCast</span>(<span class="tok-type">c_long</span>, <span class="tok-builtin">@as</span>(<span class="tok-type">c_ulong</span>, <span class="tok-number">0x8000FFFF</span>));</span>
<span class="line" id="L2813"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> E_ACCESSDENIED = <span class="tok-builtin">@bitCast</span>(<span class="tok-type">c_long</span>, <span class="tok-builtin">@as</span>(<span class="tok-type">c_ulong</span>, <span class="tok-number">0x80070005</span>));</span>
<span class="line" id="L2814"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> E_HANDLE = <span class="tok-builtin">@bitCast</span>(<span class="tok-type">c_long</span>, <span class="tok-builtin">@as</span>(<span class="tok-type">c_ulong</span>, <span class="tok-number">0x80070006</span>));</span>
<span class="line" id="L2815"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> E_OUTOFMEMORY = <span class="tok-builtin">@bitCast</span>(<span class="tok-type">c_long</span>, <span class="tok-builtin">@as</span>(<span class="tok-type">c_ulong</span>, <span class="tok-number">0x8007000E</span>));</span>
<span class="line" id="L2816"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> E_INVALIDARG = <span class="tok-builtin">@bitCast</span>(<span class="tok-type">c_long</span>, <span class="tok-builtin">@as</span>(<span class="tok-type">c_ulong</span>, <span class="tok-number">0x80070057</span>));</span>
<span class="line" id="L2817"></span>
<span class="line" id="L2818"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FILE_FLAG_BACKUP_SEMANTICS = <span class="tok-number">0x02000000</span>;</span>
<span class="line" id="L2819"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FILE_FLAG_DELETE_ON_CLOSE = <span class="tok-number">0x04000000</span>;</span>
<span class="line" id="L2820"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FILE_FLAG_NO_BUFFERING = <span class="tok-number">0x20000000</span>;</span>
<span class="line" id="L2821"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FILE_FLAG_OPEN_NO_RECALL = <span class="tok-number">0x00100000</span>;</span>
<span class="line" id="L2822"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FILE_FLAG_OPEN_REPARSE_POINT = <span class="tok-number">0x00200000</span>;</span>
<span class="line" id="L2823"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FILE_FLAG_OVERLAPPED = <span class="tok-number">0x40000000</span>;</span>
<span class="line" id="L2824"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FILE_FLAG_POSIX_SEMANTICS = <span class="tok-number">0x0100000</span>;</span>
<span class="line" id="L2825"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FILE_FLAG_RANDOM_ACCESS = <span class="tok-number">0x10000000</span>;</span>
<span class="line" id="L2826"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FILE_FLAG_SESSION_AWARE = <span class="tok-number">0x00800000</span>;</span>
<span class="line" id="L2827"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FILE_FLAG_SEQUENTIAL_SCAN = <span class="tok-number">0x08000000</span>;</span>
<span class="line" id="L2828"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FILE_FLAG_WRITE_THROUGH = <span class="tok-number">0x80000000</span>;</span>
<span class="line" id="L2829"></span>
<span class="line" id="L2830"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> RECT = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L2831">    left: LONG,</span>
<span class="line" id="L2832">    top: LONG,</span>
<span class="line" id="L2833">    right: LONG,</span>
<span class="line" id="L2834">    bottom: LONG,</span>
<span class="line" id="L2835">};</span>
<span class="line" id="L2836"></span>
<span class="line" id="L2837"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SMALL_RECT = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L2838">    Left: SHORT,</span>
<span class="line" id="L2839">    Top: SHORT,</span>
<span class="line" id="L2840">    Right: SHORT,</span>
<span class="line" id="L2841">    Bottom: SHORT,</span>
<span class="line" id="L2842">};</span>
<span class="line" id="L2843"></span>
<span class="line" id="L2844"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> POINT = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L2845">    x: LONG,</span>
<span class="line" id="L2846">    y: LONG,</span>
<span class="line" id="L2847">};</span>
<span class="line" id="L2848"></span>
<span class="line" id="L2849"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> COORD = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L2850">    X: SHORT,</span>
<span class="line" id="L2851">    Y: SHORT,</span>
<span class="line" id="L2852">};</span>
<span class="line" id="L2853"></span>
<span class="line" id="L2854"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> CREATE_UNICODE_ENVIRONMENT = <span class="tok-number">1024</span>;</span>
<span class="line" id="L2855"></span>
<span class="line" id="L2856"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> TLS_OUT_OF_INDEXES = <span class="tok-number">4294967295</span>;</span>
<span class="line" id="L2857"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IMAGE_TLS_DIRECTORY = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L2858">    StartAddressOfRawData: <span class="tok-type">usize</span>,</span>
<span class="line" id="L2859">    EndAddressOfRawData: <span class="tok-type">usize</span>,</span>
<span class="line" id="L2860">    AddressOfIndex: <span class="tok-type">usize</span>,</span>
<span class="line" id="L2861">    AddressOfCallBacks: <span class="tok-type">usize</span>,</span>
<span class="line" id="L2862">    SizeOfZeroFill: <span class="tok-type">u32</span>,</span>
<span class="line" id="L2863">    Characteristics: <span class="tok-type">u32</span>,</span>
<span class="line" id="L2864">};</span>
<span class="line" id="L2865"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IMAGE_TLS_DIRECTORY64 = IMAGE_TLS_DIRECTORY;</span>
<span class="line" id="L2866"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IMAGE_TLS_DIRECTORY32 = IMAGE_TLS_DIRECTORY;</span>
<span class="line" id="L2867"></span>
<span class="line" id="L2868"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> PIMAGE_TLS_CALLBACK = <span class="tok-kw">switch</span> (builtin.zig_backend) {</span>
<span class="line" id="L2869">    .stage1 =&gt; ?<span class="tok-kw">fn</span> (PVOID, DWORD, PVOID) <span class="tok-kw">callconv</span>(.C) <span class="tok-type">void</span>,</span>
<span class="line" id="L2870">    <span class="tok-kw">else</span> =&gt; ?*<span class="tok-kw">const</span> <span class="tok-kw">fn</span> (PVOID, DWORD, PVOID) <span class="tok-kw">callconv</span>(.C) <span class="tok-type">void</span>,</span>
<span class="line" id="L2871">};</span>
<span class="line" id="L2872"></span>
<span class="line" id="L2873"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> PROV_RSA_FULL = <span class="tok-number">1</span>;</span>
<span class="line" id="L2874"></span>
<span class="line" id="L2875"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> REGSAM = ACCESS_MASK;</span>
<span class="line" id="L2876"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> ACCESS_MASK = DWORD;</span>
<span class="line" id="L2877"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> HKEY = *HKEY__;</span>
<span class="line" id="L2878"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> HKEY__ = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L2879">    unused: <span class="tok-type">c_int</span>,</span>
<span class="line" id="L2880">};</span>
<span class="line" id="L2881"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> LSTATUS = LONG;</span>
<span class="line" id="L2882"></span>
<span class="line" id="L2883"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FILE_NOTIFY_INFORMATION = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L2884">    NextEntryOffset: DWORD,</span>
<span class="line" id="L2885">    Action: DWORD,</span>
<span class="line" id="L2886">    FileNameLength: DWORD,</span>
<span class="line" id="L2887">    <span class="tok-comment">// Flexible array member</span>
</span>
<span class="line" id="L2888">    <span class="tok-comment">// FileName: [1]WCHAR,</span>
</span>
<span class="line" id="L2889">};</span>
<span class="line" id="L2890"></span>
<span class="line" id="L2891"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FILE_ACTION_ADDED = <span class="tok-number">0x00000001</span>;</span>
<span class="line" id="L2892"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FILE_ACTION_REMOVED = <span class="tok-number">0x00000002</span>;</span>
<span class="line" id="L2893"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FILE_ACTION_MODIFIED = <span class="tok-number">0x00000003</span>;</span>
<span class="line" id="L2894"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FILE_ACTION_RENAMED_OLD_NAME = <span class="tok-number">0x00000004</span>;</span>
<span class="line" id="L2895"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FILE_ACTION_RENAMED_NEW_NAME = <span class="tok-number">0x00000005</span>;</span>
<span class="line" id="L2896"></span>
<span class="line" id="L2897"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> LPOVERLAPPED_COMPLETION_ROUTINE = <span class="tok-kw">switch</span> (builtin.zig_backend) {</span>
<span class="line" id="L2898">    .stage1 =&gt; ?<span class="tok-kw">fn</span> (DWORD, DWORD, *OVERLAPPED) <span class="tok-kw">callconv</span>(.C) <span class="tok-type">void</span>,</span>
<span class="line" id="L2899">    <span class="tok-kw">else</span> =&gt; ?*<span class="tok-kw">const</span> <span class="tok-kw">fn</span> (DWORD, DWORD, *OVERLAPPED) <span class="tok-kw">callconv</span>(.C) <span class="tok-type">void</span>,</span>
<span class="line" id="L2900">};</span>
<span class="line" id="L2901"></span>
<span class="line" id="L2902"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FILE_NOTIFY_CHANGE_CREATION = <span class="tok-number">64</span>;</span>
<span class="line" id="L2903"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FILE_NOTIFY_CHANGE_SIZE = <span class="tok-number">8</span>;</span>
<span class="line" id="L2904"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FILE_NOTIFY_CHANGE_SECURITY = <span class="tok-number">256</span>;</span>
<span class="line" id="L2905"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FILE_NOTIFY_CHANGE_LAST_ACCESS = <span class="tok-number">32</span>;</span>
<span class="line" id="L2906"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FILE_NOTIFY_CHANGE_LAST_WRITE = <span class="tok-number">16</span>;</span>
<span class="line" id="L2907"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FILE_NOTIFY_CHANGE_DIR_NAME = <span class="tok-number">2</span>;</span>
<span class="line" id="L2908"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FILE_NOTIFY_CHANGE_FILE_NAME = <span class="tok-number">1</span>;</span>
<span class="line" id="L2909"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FILE_NOTIFY_CHANGE_ATTRIBUTES = <span class="tok-number">4</span>;</span>
<span class="line" id="L2910"></span>
<span class="line" id="L2911"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> CONSOLE_SCREEN_BUFFER_INFO = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L2912">    dwSize: COORD,</span>
<span class="line" id="L2913">    dwCursorPosition: COORD,</span>
<span class="line" id="L2914">    wAttributes: WORD,</span>
<span class="line" id="L2915">    srWindow: SMALL_RECT,</span>
<span class="line" id="L2916">    dwMaximumWindowSize: COORD,</span>
<span class="line" id="L2917">};</span>
<span class="line" id="L2918"></span>
<span class="line" id="L2919"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FOREGROUND_BLUE = <span class="tok-number">1</span>;</span>
<span class="line" id="L2920"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FOREGROUND_GREEN = <span class="tok-number">2</span>;</span>
<span class="line" id="L2921"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FOREGROUND_RED = <span class="tok-number">4</span>;</span>
<span class="line" id="L2922"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FOREGROUND_INTENSITY = <span class="tok-number">8</span>;</span>
<span class="line" id="L2923"></span>
<span class="line" id="L2924"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> LIST_ENTRY = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L2925">    Flink: *LIST_ENTRY,</span>
<span class="line" id="L2926">    Blink: *LIST_ENTRY,</span>
<span class="line" id="L2927">};</span>
<span class="line" id="L2928"></span>
<span class="line" id="L2929"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> RTL_CRITICAL_SECTION_DEBUG = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L2930">    Type: WORD,</span>
<span class="line" id="L2931">    CreatorBackTraceIndex: WORD,</span>
<span class="line" id="L2932">    CriticalSection: *RTL_CRITICAL_SECTION,</span>
<span class="line" id="L2933">    ProcessLocksList: LIST_ENTRY,</span>
<span class="line" id="L2934">    EntryCount: DWORD,</span>
<span class="line" id="L2935">    ContentionCount: DWORD,</span>
<span class="line" id="L2936">    Flags: DWORD,</span>
<span class="line" id="L2937">    CreatorBackTraceIndexHigh: WORD,</span>
<span class="line" id="L2938">    SpareWORD: WORD,</span>
<span class="line" id="L2939">};</span>
<span class="line" id="L2940"></span>
<span class="line" id="L2941"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> RTL_CRITICAL_SECTION = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L2942">    DebugInfo: *RTL_CRITICAL_SECTION_DEBUG,</span>
<span class="line" id="L2943">    LockCount: LONG,</span>
<span class="line" id="L2944">    RecursionCount: LONG,</span>
<span class="line" id="L2945">    OwningThread: HANDLE,</span>
<span class="line" id="L2946">    LockSemaphore: HANDLE,</span>
<span class="line" id="L2947">    SpinCount: ULONG_PTR,</span>
<span class="line" id="L2948">};</span>
<span class="line" id="L2949"></span>
<span class="line" id="L2950"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> CRITICAL_SECTION = RTL_CRITICAL_SECTION;</span>
<span class="line" id="L2951"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> INIT_ONCE = RTL_RUN_ONCE;</span>
<span class="line" id="L2952"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> INIT_ONCE_STATIC_INIT = RTL_RUN_ONCE_INIT;</span>
<span class="line" id="L2953"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> INIT_ONCE_FN = <span class="tok-kw">switch</span> (builtin.zig_backend) {</span>
<span class="line" id="L2954">    .stage1 =&gt; <span class="tok-kw">fn</span> (InitOnce: *INIT_ONCE, Parameter: ?*<span class="tok-type">anyopaque</span>, Context: ?*<span class="tok-type">anyopaque</span>) <span class="tok-kw">callconv</span>(.C) BOOL,</span>
<span class="line" id="L2955">    <span class="tok-kw">else</span> =&gt; *<span class="tok-kw">const</span> <span class="tok-kw">fn</span> (InitOnce: *INIT_ONCE, Parameter: ?*<span class="tok-type">anyopaque</span>, Context: ?*<span class="tok-type">anyopaque</span>) <span class="tok-kw">callconv</span>(.C) BOOL,</span>
<span class="line" id="L2956">};</span>
<span class="line" id="L2957"></span>
<span class="line" id="L2958"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> RTL_RUN_ONCE = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L2959">    Ptr: ?*<span class="tok-type">anyopaque</span>,</span>
<span class="line" id="L2960">};</span>
<span class="line" id="L2961"></span>
<span class="line" id="L2962"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> RTL_RUN_ONCE_INIT = RTL_RUN_ONCE{ .Ptr = <span class="tok-null">null</span> };</span>
<span class="line" id="L2963"></span>
<span class="line" id="L2964"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> COINIT_APARTMENTTHREADED = COINIT.COINIT_APARTMENTTHREADED;</span>
<span class="line" id="L2965"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> COINIT_MULTITHREADED = COINIT.COINIT_MULTITHREADED;</span>
<span class="line" id="L2966"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> COINIT_DISABLE_OLE1DDE = COINIT.COINIT_DISABLE_OLE1DDE;</span>
<span class="line" id="L2967"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> COINIT_SPEED_OVER_MEMORY = COINIT.COINIT_SPEED_OVER_MEMORY;</span>
<span class="line" id="L2968"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> COINIT = <span class="tok-kw">enum</span>(<span class="tok-type">c_int</span>) {</span>
<span class="line" id="L2969">    COINIT_APARTMENTTHREADED = <span class="tok-number">2</span>,</span>
<span class="line" id="L2970">    COINIT_MULTITHREADED = <span class="tok-number">0</span>,</span>
<span class="line" id="L2971">    COINIT_DISABLE_OLE1DDE = <span class="tok-number">4</span>,</span>
<span class="line" id="L2972">    COINIT_SPEED_OVER_MEMORY = <span class="tok-number">8</span>,</span>
<span class="line" id="L2973">};</span>
<span class="line" id="L2974"></span>
<span class="line" id="L2975"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> MEMORY_BASIC_INFORMATION = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L2976">    BaseAddress: PVOID,</span>
<span class="line" id="L2977">    AllocationBase: PVOID,</span>
<span class="line" id="L2978">    AllocationProtect: DWORD,</span>
<span class="line" id="L2979">    PartitionId: WORD,</span>
<span class="line" id="L2980">    RegionSize: SIZE_T,</span>
<span class="line" id="L2981">    State: DWORD,</span>
<span class="line" id="L2982">    Protect: DWORD,</span>
<span class="line" id="L2983">    Type: DWORD,</span>
<span class="line" id="L2984">};</span>
<span class="line" id="L2985"></span>
<span class="line" id="L2986"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> PMEMORY_BASIC_INFORMATION = *MEMORY_BASIC_INFORMATION;</span>
<span class="line" id="L2987"></span>
<span class="line" id="L2988"><span class="tok-comment">/// &gt; The maximum path of 32,767 characters is approximate, because the &quot;\\?\&quot;</span></span>
<span class="line" id="L2989"><span class="tok-comment">/// &gt; prefix may be expanded to a longer string by the system at run time, and</span></span>
<span class="line" id="L2990"><span class="tok-comment">/// &gt; this expansion applies to the total length.</span></span>
<span class="line" id="L2991"><span class="tok-comment">/// from https://docs.microsoft.com/en-us/windows/desktop/FileIO/naming-a-file#maximum-path-length-limitation</span></span>
<span class="line" id="L2992"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> PATH_MAX_WIDE = <span class="tok-number">32767</span>;</span>
<span class="line" id="L2993"></span>
<span class="line" id="L2994"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FORMAT_MESSAGE_ALLOCATE_BUFFER = <span class="tok-number">0x00000100</span>;</span>
<span class="line" id="L2995"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FORMAT_MESSAGE_ARGUMENT_ARRAY = <span class="tok-number">0x00002000</span>;</span>
<span class="line" id="L2996"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FORMAT_MESSAGE_FROM_HMODULE = <span class="tok-number">0x00000800</span>;</span>
<span class="line" id="L2997"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FORMAT_MESSAGE_FROM_STRING = <span class="tok-number">0x00000400</span>;</span>
<span class="line" id="L2998"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FORMAT_MESSAGE_FROM_SYSTEM = <span class="tok-number">0x00001000</span>;</span>
<span class="line" id="L2999"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FORMAT_MESSAGE_IGNORE_INSERTS = <span class="tok-number">0x00000200</span>;</span>
<span class="line" id="L3000"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FORMAT_MESSAGE_MAX_WIDTH_MASK = <span class="tok-number">0x000000FF</span>;</span>
<span class="line" id="L3001"></span>
<span class="line" id="L3002"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> EXCEPTION_DATATYPE_MISALIGNMENT = <span class="tok-number">0x80000002</span>;</span>
<span class="line" id="L3003"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> EXCEPTION_ACCESS_VIOLATION = <span class="tok-number">0xc0000005</span>;</span>
<span class="line" id="L3004"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> EXCEPTION_ILLEGAL_INSTRUCTION = <span class="tok-number">0xc000001d</span>;</span>
<span class="line" id="L3005"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> EXCEPTION_STACK_OVERFLOW = <span class="tok-number">0xc00000fd</span>;</span>
<span class="line" id="L3006"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> EXCEPTION_CONTINUE_SEARCH = <span class="tok-number">0</span>;</span>
<span class="line" id="L3007"></span>
<span class="line" id="L3008"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> EXCEPTION_RECORD = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L3009">    ExceptionCode: <span class="tok-type">u32</span>,</span>
<span class="line" id="L3010">    ExceptionFlags: <span class="tok-type">u32</span>,</span>
<span class="line" id="L3011">    ExceptionRecord: *EXCEPTION_RECORD,</span>
<span class="line" id="L3012">    ExceptionAddress: *<span class="tok-type">anyopaque</span>,</span>
<span class="line" id="L3013">    NumberParameters: <span class="tok-type">u32</span>,</span>
<span class="line" id="L3014">    ExceptionInformation: [<span class="tok-number">15</span>]<span class="tok-type">usize</span>,</span>
<span class="line" id="L3015">};</span>
<span class="line" id="L3016"></span>
<span class="line" id="L3017"><span class="tok-kw">pub</span> <span class="tok-kw">usingnamespace</span> <span class="tok-kw">switch</span> (native_arch) {</span>
<span class="line" id="L3018">    .<span class="tok-type">i386</span> =&gt; <span class="tok-kw">struct</span> {</span>
<span class="line" id="L3019">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> FLOATING_SAVE_AREA = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L3020">            ControlWord: DWORD,</span>
<span class="line" id="L3021">            StatusWord: DWORD,</span>
<span class="line" id="L3022">            TagWord: DWORD,</span>
<span class="line" id="L3023">            ErrorOffset: DWORD,</span>
<span class="line" id="L3024">            ErrorSelector: DWORD,</span>
<span class="line" id="L3025">            DataOffset: DWORD,</span>
<span class="line" id="L3026">            DataSelector: DWORD,</span>
<span class="line" id="L3027">            RegisterArea: [<span class="tok-number">80</span>]BYTE,</span>
<span class="line" id="L3028">            Cr0NpxState: DWORD,</span>
<span class="line" id="L3029">        };</span>
<span class="line" id="L3030"></span>
<span class="line" id="L3031">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> CONTEXT = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L3032">            ContextFlags: DWORD,</span>
<span class="line" id="L3033">            Dr0: DWORD,</span>
<span class="line" id="L3034">            Dr1: DWORD,</span>
<span class="line" id="L3035">            Dr2: DWORD,</span>
<span class="line" id="L3036">            Dr3: DWORD,</span>
<span class="line" id="L3037">            Dr6: DWORD,</span>
<span class="line" id="L3038">            Dr7: DWORD,</span>
<span class="line" id="L3039">            FloatSave: FLOATING_SAVE_AREA,</span>
<span class="line" id="L3040">            SegGs: DWORD,</span>
<span class="line" id="L3041">            SegFs: DWORD,</span>
<span class="line" id="L3042">            SegEs: DWORD,</span>
<span class="line" id="L3043">            SegDs: DWORD,</span>
<span class="line" id="L3044">            Edi: DWORD,</span>
<span class="line" id="L3045">            Esi: DWORD,</span>
<span class="line" id="L3046">            Ebx: DWORD,</span>
<span class="line" id="L3047">            Edx: DWORD,</span>
<span class="line" id="L3048">            Ecx: DWORD,</span>
<span class="line" id="L3049">            Eax: DWORD,</span>
<span class="line" id="L3050">            Ebp: DWORD,</span>
<span class="line" id="L3051">            Eip: DWORD,</span>
<span class="line" id="L3052">            SegCs: DWORD,</span>
<span class="line" id="L3053">            EFlags: DWORD,</span>
<span class="line" id="L3054">            Esp: DWORD,</span>
<span class="line" id="L3055">            SegSs: DWORD,</span>
<span class="line" id="L3056">            ExtendedRegisters: [<span class="tok-number">512</span>]BYTE,</span>
<span class="line" id="L3057"></span>
<span class="line" id="L3058">            <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">getRegs</span>(ctx: *<span class="tok-kw">const</span> CONTEXT) <span class="tok-kw">struct</span> { bp: <span class="tok-type">usize</span>, ip: <span class="tok-type">usize</span> } {</span>
<span class="line" id="L3059">                <span class="tok-kw">return</span> .{ .bp = ctx.Ebp, .ip = ctx.Eip };</span>
<span class="line" id="L3060">            }</span>
<span class="line" id="L3061">        };</span>
<span class="line" id="L3062">    },</span>
<span class="line" id="L3063">    .x86_64 =&gt; <span class="tok-kw">struct</span> {</span>
<span class="line" id="L3064">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> M128A = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L3065">            Low: ULONGLONG,</span>
<span class="line" id="L3066">            High: LONGLONG,</span>
<span class="line" id="L3067">        };</span>
<span class="line" id="L3068"></span>
<span class="line" id="L3069">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> XMM_SAVE_AREA32 = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L3070">            ControlWord: WORD,</span>
<span class="line" id="L3071">            StatusWord: WORD,</span>
<span class="line" id="L3072">            TagWord: BYTE,</span>
<span class="line" id="L3073">            Reserved1: BYTE,</span>
<span class="line" id="L3074">            ErrorOpcode: WORD,</span>
<span class="line" id="L3075">            ErrorOffset: DWORD,</span>
<span class="line" id="L3076">            ErrorSelector: WORD,</span>
<span class="line" id="L3077">            Reserved2: WORD,</span>
<span class="line" id="L3078">            DataOffset: DWORD,</span>
<span class="line" id="L3079">            DataSelector: WORD,</span>
<span class="line" id="L3080">            Reserved3: WORD,</span>
<span class="line" id="L3081">            MxCsr: DWORD,</span>
<span class="line" id="L3082">            MxCsr_Mask: DWORD,</span>
<span class="line" id="L3083">            FloatRegisters: [<span class="tok-number">8</span>]M128A,</span>
<span class="line" id="L3084">            XmmRegisters: [<span class="tok-number">16</span>]M128A,</span>
<span class="line" id="L3085">            Reserved4: [<span class="tok-number">96</span>]BYTE,</span>
<span class="line" id="L3086">        };</span>
<span class="line" id="L3087"></span>
<span class="line" id="L3088">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> CONTEXT = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L3089">            P1Home: DWORD64,</span>
<span class="line" id="L3090">            P2Home: DWORD64,</span>
<span class="line" id="L3091">            P3Home: DWORD64,</span>
<span class="line" id="L3092">            P4Home: DWORD64,</span>
<span class="line" id="L3093">            P5Home: DWORD64,</span>
<span class="line" id="L3094">            P6Home: DWORD64,</span>
<span class="line" id="L3095">            ContextFlags: DWORD,</span>
<span class="line" id="L3096">            MxCsr: DWORD,</span>
<span class="line" id="L3097">            SegCs: WORD,</span>
<span class="line" id="L3098">            SegDs: WORD,</span>
<span class="line" id="L3099">            SegEs: WORD,</span>
<span class="line" id="L3100">            SegFs: WORD,</span>
<span class="line" id="L3101">            SegGs: WORD,</span>
<span class="line" id="L3102">            SegSs: WORD,</span>
<span class="line" id="L3103">            EFlags: DWORD,</span>
<span class="line" id="L3104">            Dr0: DWORD64,</span>
<span class="line" id="L3105">            Dr1: DWORD64,</span>
<span class="line" id="L3106">            Dr2: DWORD64,</span>
<span class="line" id="L3107">            Dr3: DWORD64,</span>
<span class="line" id="L3108">            Dr6: DWORD64,</span>
<span class="line" id="L3109">            Dr7: DWORD64,</span>
<span class="line" id="L3110">            Rax: DWORD64,</span>
<span class="line" id="L3111">            Rcx: DWORD64,</span>
<span class="line" id="L3112">            Rdx: DWORD64,</span>
<span class="line" id="L3113">            Rbx: DWORD64,</span>
<span class="line" id="L3114">            Rsp: DWORD64,</span>
<span class="line" id="L3115">            Rbp: DWORD64,</span>
<span class="line" id="L3116">            Rsi: DWORD64,</span>
<span class="line" id="L3117">            Rdi: DWORD64,</span>
<span class="line" id="L3118">            R8: DWORD64,</span>
<span class="line" id="L3119">            R9: DWORD64,</span>
<span class="line" id="L3120">            R10: DWORD64,</span>
<span class="line" id="L3121">            R11: DWORD64,</span>
<span class="line" id="L3122">            R12: DWORD64,</span>
<span class="line" id="L3123">            R13: DWORD64,</span>
<span class="line" id="L3124">            R14: DWORD64,</span>
<span class="line" id="L3125">            R15: DWORD64,</span>
<span class="line" id="L3126">            Rip: DWORD64,</span>
<span class="line" id="L3127">            DUMMYUNIONNAME: <span class="tok-kw">extern</span> <span class="tok-kw">union</span> {</span>
<span class="line" id="L3128">                FltSave: XMM_SAVE_AREA32,</span>
<span class="line" id="L3129">                FloatSave: XMM_SAVE_AREA32,</span>
<span class="line" id="L3130">                DUMMYSTRUCTNAME: <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L3131">                    Header: [<span class="tok-number">2</span>]M128A,</span>
<span class="line" id="L3132">                    Legacy: [<span class="tok-number">8</span>]M128A,</span>
<span class="line" id="L3133">                    Xmm0: M128A,</span>
<span class="line" id="L3134">                    Xmm1: M128A,</span>
<span class="line" id="L3135">                    Xmm2: M128A,</span>
<span class="line" id="L3136">                    Xmm3: M128A,</span>
<span class="line" id="L3137">                    Xmm4: M128A,</span>
<span class="line" id="L3138">                    Xmm5: M128A,</span>
<span class="line" id="L3139">                    Xmm6: M128A,</span>
<span class="line" id="L3140">                    Xmm7: M128A,</span>
<span class="line" id="L3141">                    Xmm8: M128A,</span>
<span class="line" id="L3142">                    Xmm9: M128A,</span>
<span class="line" id="L3143">                    Xmm10: M128A,</span>
<span class="line" id="L3144">                    Xmm11: M128A,</span>
<span class="line" id="L3145">                    Xmm12: M128A,</span>
<span class="line" id="L3146">                    Xmm13: M128A,</span>
<span class="line" id="L3147">                    Xmm14: M128A,</span>
<span class="line" id="L3148">                    Xmm15: M128A,</span>
<span class="line" id="L3149">                },</span>
<span class="line" id="L3150">            },</span>
<span class="line" id="L3151">            VectorRegister: [<span class="tok-number">26</span>]M128A,</span>
<span class="line" id="L3152">            VectorControl: DWORD64,</span>
<span class="line" id="L3153">            DebugControl: DWORD64,</span>
<span class="line" id="L3154">            LastBranchToRip: DWORD64,</span>
<span class="line" id="L3155">            LastBranchFromRip: DWORD64,</span>
<span class="line" id="L3156">            LastExceptionToRip: DWORD64,</span>
<span class="line" id="L3157">            LastExceptionFromRip: DWORD64,</span>
<span class="line" id="L3158"></span>
<span class="line" id="L3159">            <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">getRegs</span>(ctx: *<span class="tok-kw">const</span> CONTEXT) <span class="tok-kw">struct</span> { bp: <span class="tok-type">usize</span>, ip: <span class="tok-type">usize</span> } {</span>
<span class="line" id="L3160">                <span class="tok-kw">return</span> .{ .bp = ctx.Rbp, .ip = ctx.Rip };</span>
<span class="line" id="L3161">            }</span>
<span class="line" id="L3162">        };</span>
<span class="line" id="L3163">    },</span>
<span class="line" id="L3164">    .aarch64 =&gt; <span class="tok-kw">struct</span> {</span>
<span class="line" id="L3165">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> NEON128 = <span class="tok-kw">extern</span> <span class="tok-kw">union</span> {</span>
<span class="line" id="L3166">            DUMMYSTRUCTNAME: <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L3167">                Low: ULONGLONG,</span>
<span class="line" id="L3168">                High: LONGLONG,</span>
<span class="line" id="L3169">            },</span>
<span class="line" id="L3170">            D: [<span class="tok-number">2</span>]<span class="tok-type">f64</span>,</span>
<span class="line" id="L3171">            S: [<span class="tok-number">4</span>]<span class="tok-type">f32</span>,</span>
<span class="line" id="L3172">            H: [<span class="tok-number">8</span>]WORD,</span>
<span class="line" id="L3173">            B: [<span class="tok-number">16</span>]BYTE,</span>
<span class="line" id="L3174">        };</span>
<span class="line" id="L3175"></span>
<span class="line" id="L3176">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> CONTEXT = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L3177">            ContextFlags: ULONG,</span>
<span class="line" id="L3178">            Cpsr: ULONG,</span>
<span class="line" id="L3179">            DUMMYUNIONNAME: <span class="tok-kw">extern</span> <span class="tok-kw">union</span> {</span>
<span class="line" id="L3180">                DUMMYSTRUCTNAME: <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L3181">                    X0: DWORD64,</span>
<span class="line" id="L3182">                    X1: DWORD64,</span>
<span class="line" id="L3183">                    X2: DWORD64,</span>
<span class="line" id="L3184">                    X3: DWORD64,</span>
<span class="line" id="L3185">                    X4: DWORD64,</span>
<span class="line" id="L3186">                    X5: DWORD64,</span>
<span class="line" id="L3187">                    X6: DWORD64,</span>
<span class="line" id="L3188">                    X7: DWORD64,</span>
<span class="line" id="L3189">                    X8: DWORD64,</span>
<span class="line" id="L3190">                    X9: DWORD64,</span>
<span class="line" id="L3191">                    X10: DWORD64,</span>
<span class="line" id="L3192">                    X11: DWORD64,</span>
<span class="line" id="L3193">                    X12: DWORD64,</span>
<span class="line" id="L3194">                    X13: DWORD64,</span>
<span class="line" id="L3195">                    X14: DWORD64,</span>
<span class="line" id="L3196">                    X15: DWORD64,</span>
<span class="line" id="L3197">                    X16: DWORD64,</span>
<span class="line" id="L3198">                    X17: DWORD64,</span>
<span class="line" id="L3199">                    X18: DWORD64,</span>
<span class="line" id="L3200">                    X19: DWORD64,</span>
<span class="line" id="L3201">                    X20: DWORD64,</span>
<span class="line" id="L3202">                    X21: DWORD64,</span>
<span class="line" id="L3203">                    X22: DWORD64,</span>
<span class="line" id="L3204">                    X23: DWORD64,</span>
<span class="line" id="L3205">                    X24: DWORD64,</span>
<span class="line" id="L3206">                    X25: DWORD64,</span>
<span class="line" id="L3207">                    X26: DWORD64,</span>
<span class="line" id="L3208">                    X27: DWORD64,</span>
<span class="line" id="L3209">                    X28: DWORD64,</span>
<span class="line" id="L3210">                    Fp: DWORD64,</span>
<span class="line" id="L3211">                    Lr: DWORD64,</span>
<span class="line" id="L3212">                },</span>
<span class="line" id="L3213">                X: [<span class="tok-number">31</span>]DWORD64,</span>
<span class="line" id="L3214">            },</span>
<span class="line" id="L3215">            Sp: DWORD64,</span>
<span class="line" id="L3216">            Pc: DWORD64,</span>
<span class="line" id="L3217">            V: [<span class="tok-number">32</span>]NEON128,</span>
<span class="line" id="L3218">            Fpcr: DWORD,</span>
<span class="line" id="L3219">            Fpsr: DWORD,</span>
<span class="line" id="L3220">            Bcr: [<span class="tok-number">8</span>]DWORD,</span>
<span class="line" id="L3221">            Bvr: [<span class="tok-number">8</span>]DWORD64,</span>
<span class="line" id="L3222">            Wcr: [<span class="tok-number">2</span>]DWORD,</span>
<span class="line" id="L3223">            Wvr: [<span class="tok-number">2</span>]DWORD64,</span>
<span class="line" id="L3224"></span>
<span class="line" id="L3225">            <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">getRegs</span>(ctx: *<span class="tok-kw">const</span> CONTEXT) <span class="tok-kw">struct</span> { bp: <span class="tok-type">usize</span>, ip: <span class="tok-type">usize</span> } {</span>
<span class="line" id="L3226">                <span class="tok-kw">return</span> .{</span>
<span class="line" id="L3227">                    .bp = ctx.DUMMYUNIONNAME.DUMMYSTRUCTNAME.Fp,</span>
<span class="line" id="L3228">                    .ip = ctx.Pc,</span>
<span class="line" id="L3229">                };</span>
<span class="line" id="L3230">            }</span>
<span class="line" id="L3231">        };</span>
<span class="line" id="L3232">    },</span>
<span class="line" id="L3233">    <span class="tok-kw">else</span> =&gt; <span class="tok-kw">struct</span> {},</span>
<span class="line" id="L3234">};</span>
<span class="line" id="L3235"></span>
<span class="line" id="L3236"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> EXCEPTION_POINTERS = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L3237">    ExceptionRecord: *EXCEPTION_RECORD,</span>
<span class="line" id="L3238">    ContextRecord: *std.os.windows.CONTEXT,</span>
<span class="line" id="L3239">};</span>
<span class="line" id="L3240"></span>
<span class="line" id="L3241"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> VECTORED_EXCEPTION_HANDLER = <span class="tok-kw">switch</span> (builtin.zig_backend) {</span>
<span class="line" id="L3242">    .stage1 =&gt; <span class="tok-kw">fn</span> (ExceptionInfo: *EXCEPTION_POINTERS) <span class="tok-kw">callconv</span>(WINAPI) <span class="tok-type">c_long</span>,</span>
<span class="line" id="L3243">    <span class="tok-kw">else</span> =&gt; *<span class="tok-kw">const</span> <span class="tok-kw">fn</span> (ExceptionInfo: *EXCEPTION_POINTERS) <span class="tok-kw">callconv</span>(WINAPI) <span class="tok-type">c_long</span>,</span>
<span class="line" id="L3244">};</span>
<span class="line" id="L3245"></span>
<span class="line" id="L3246"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> OBJECT_ATTRIBUTES = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L3247">    Length: ULONG,</span>
<span class="line" id="L3248">    RootDirectory: ?HANDLE,</span>
<span class="line" id="L3249">    ObjectName: *UNICODE_STRING,</span>
<span class="line" id="L3250">    Attributes: ULONG,</span>
<span class="line" id="L3251">    SecurityDescriptor: ?*<span class="tok-type">anyopaque</span>,</span>
<span class="line" id="L3252">    SecurityQualityOfService: ?*<span class="tok-type">anyopaque</span>,</span>
<span class="line" id="L3253">};</span>
<span class="line" id="L3254"></span>
<span class="line" id="L3255"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> OBJ_INHERIT = <span class="tok-number">0x00000002</span>;</span>
<span class="line" id="L3256"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> OBJ_PERMANENT = <span class="tok-number">0x00000010</span>;</span>
<span class="line" id="L3257"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> OBJ_EXCLUSIVE = <span class="tok-number">0x00000020</span>;</span>
<span class="line" id="L3258"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> OBJ_CASE_INSENSITIVE = <span class="tok-number">0x00000040</span>;</span>
<span class="line" id="L3259"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> OBJ_OPENIF = <span class="tok-number">0x00000080</span>;</span>
<span class="line" id="L3260"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> OBJ_OPENLINK = <span class="tok-number">0x00000100</span>;</span>
<span class="line" id="L3261"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> OBJ_KERNEL_HANDLE = <span class="tok-number">0x00000200</span>;</span>
<span class="line" id="L3262"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> OBJ_VALID_ATTRIBUTES = <span class="tok-number">0x000003F2</span>;</span>
<span class="line" id="L3263"></span>
<span class="line" id="L3264"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> UNICODE_STRING = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L3265">    Length: <span class="tok-type">c_ushort</span>,</span>
<span class="line" id="L3266">    MaximumLength: <span class="tok-type">c_ushort</span>,</span>
<span class="line" id="L3267">    Buffer: [*]WCHAR,</span>
<span class="line" id="L3268">};</span>
<span class="line" id="L3269"></span>
<span class="line" id="L3270"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> ACTIVATION_CONTEXT_DATA = <span class="tok-kw">opaque</span> {};</span>
<span class="line" id="L3271"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> ASSEMBLY_STORAGE_MAP = <span class="tok-kw">opaque</span> {};</span>
<span class="line" id="L3272"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FLS_CALLBACK_INFO = <span class="tok-kw">opaque</span> {};</span>
<span class="line" id="L3273"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> RTL_BITMAP = <span class="tok-kw">opaque</span> {};</span>
<span class="line" id="L3274"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> KAFFINITY = <span class="tok-type">usize</span>;</span>
<span class="line" id="L3275"></span>
<span class="line" id="L3276"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> TEB = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L3277">    Reserved1: [<span class="tok-number">12</span>]PVOID,</span>
<span class="line" id="L3278">    ProcessEnvironmentBlock: *PEB,</span>
<span class="line" id="L3279">    Reserved2: [<span class="tok-number">399</span>]PVOID,</span>
<span class="line" id="L3280">    Reserved3: [<span class="tok-number">1952</span>]<span class="tok-type">u8</span>,</span>
<span class="line" id="L3281">    TlsSlots: [<span class="tok-number">64</span>]PVOID,</span>
<span class="line" id="L3282">    Reserved4: [<span class="tok-number">8</span>]<span class="tok-type">u8</span>,</span>
<span class="line" id="L3283">    Reserved5: [<span class="tok-number">26</span>]PVOID,</span>
<span class="line" id="L3284">    ReservedForOle: PVOID,</span>
<span class="line" id="L3285">    Reserved6: [<span class="tok-number">4</span>]PVOID,</span>
<span class="line" id="L3286">    TlsExpansionSlots: PVOID,</span>
<span class="line" id="L3287">};</span>
<span class="line" id="L3288"></span>
<span class="line" id="L3289"><span class="tok-comment">/// Process Environment Block</span></span>
<span class="line" id="L3290"><span class="tok-comment">/// Microsoft documentation of this is incomplete, the fields here are taken from various resources including:</span></span>
<span class="line" id="L3291"><span class="tok-comment">///  - https://github.com/wine-mirror/wine/blob/1aff1e6a370ee8c0213a0fd4b220d121da8527aa/include/winternl.h#L269</span></span>
<span class="line" id="L3292"><span class="tok-comment">///  - https://www.geoffchappell.com/studies/windows/win32/ntdll/structs/peb/index.htm</span></span>
<span class="line" id="L3293"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> PEB = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L3294">    <span class="tok-comment">// Versions: All</span>
</span>
<span class="line" id="L3295">    InheritedAddressSpace: BOOLEAN,</span>
<span class="line" id="L3296"></span>
<span class="line" id="L3297">    <span class="tok-comment">// Versions: 3.51+</span>
</span>
<span class="line" id="L3298">    ReadImageFileExecOptions: BOOLEAN,</span>
<span class="line" id="L3299">    BeingDebugged: BOOLEAN,</span>
<span class="line" id="L3300"></span>
<span class="line" id="L3301">    <span class="tok-comment">// Versions: 5.2+ (previously was padding)</span>
</span>
<span class="line" id="L3302">    BitField: UCHAR,</span>
<span class="line" id="L3303"></span>
<span class="line" id="L3304">    <span class="tok-comment">// Versions: all</span>
</span>
<span class="line" id="L3305">    Mutant: HANDLE,</span>
<span class="line" id="L3306">    ImageBaseAddress: HMODULE,</span>
<span class="line" id="L3307">    Ldr: *PEB_LDR_DATA,</span>
<span class="line" id="L3308">    ProcessParameters: *RTL_USER_PROCESS_PARAMETERS,</span>
<span class="line" id="L3309">    SubSystemData: PVOID,</span>
<span class="line" id="L3310">    ProcessHeap: HANDLE,</span>
<span class="line" id="L3311"></span>
<span class="line" id="L3312">    <span class="tok-comment">// Versions: 5.1+</span>
</span>
<span class="line" id="L3313">    FastPebLock: *RTL_CRITICAL_SECTION,</span>
<span class="line" id="L3314"></span>
<span class="line" id="L3315">    <span class="tok-comment">// Versions: 5.2+</span>
</span>
<span class="line" id="L3316">    AtlThunkSListPtr: PVOID,</span>
<span class="line" id="L3317">    IFEOKey: PVOID,</span>
<span class="line" id="L3318"></span>
<span class="line" id="L3319">    <span class="tok-comment">// Versions: 6.0+</span>
</span>
<span class="line" id="L3320"></span>
<span class="line" id="L3321">    <span class="tok-comment">/// https://www.geoffchappell.com/studies/windows/win32/ntdll/structs/peb/crossprocessflags.htm</span></span>
<span class="line" id="L3322">    CrossProcessFlags: ULONG,</span>
<span class="line" id="L3323"></span>
<span class="line" id="L3324">    <span class="tok-comment">// Versions: 6.0+</span>
</span>
<span class="line" id="L3325">    union1: <span class="tok-kw">extern</span> <span class="tok-kw">union</span> {</span>
<span class="line" id="L3326">        KernelCallbackTable: PVOID,</span>
<span class="line" id="L3327">        UserSharedInfoPtr: PVOID,</span>
<span class="line" id="L3328">    },</span>
<span class="line" id="L3329"></span>
<span class="line" id="L3330">    <span class="tok-comment">// Versions: 5.1+</span>
</span>
<span class="line" id="L3331">    SystemReserved: ULONG,</span>
<span class="line" id="L3332"></span>
<span class="line" id="L3333">    <span class="tok-comment">// Versions: 5.1, (not 5.2, not 6.0), 6.1+</span>
</span>
<span class="line" id="L3334">    AtlThunkSListPtr32: ULONG,</span>
<span class="line" id="L3335"></span>
<span class="line" id="L3336">    <span class="tok-comment">// Versions: 6.1+</span>
</span>
<span class="line" id="L3337">    ApiSetMap: PVOID,</span>
<span class="line" id="L3338"></span>
<span class="line" id="L3339">    <span class="tok-comment">// Versions: all</span>
</span>
<span class="line" id="L3340">    TlsExpansionCounter: ULONG,</span>
<span class="line" id="L3341">    <span class="tok-comment">// note: there is padding here on 64 bit</span>
</span>
<span class="line" id="L3342">    TlsBitmap: *RTL_BITMAP,</span>
<span class="line" id="L3343">    TlsBitmapBits: [<span class="tok-number">2</span>]ULONG,</span>
<span class="line" id="L3344">    ReadOnlySharedMemoryBase: PVOID,</span>
<span class="line" id="L3345"></span>
<span class="line" id="L3346">    <span class="tok-comment">// Versions: 1703+</span>
</span>
<span class="line" id="L3347">    SharedData: PVOID,</span>
<span class="line" id="L3348"></span>
<span class="line" id="L3349">    <span class="tok-comment">// Versions: all</span>
</span>
<span class="line" id="L3350">    ReadOnlyStaticServerData: *PVOID,</span>
<span class="line" id="L3351">    AnsiCodePageData: PVOID,</span>
<span class="line" id="L3352">    OemCodePageData: PVOID,</span>
<span class="line" id="L3353">    UnicodeCaseTableData: PVOID,</span>
<span class="line" id="L3354"></span>
<span class="line" id="L3355">    <span class="tok-comment">// Versions: 3.51+</span>
</span>
<span class="line" id="L3356">    NumberOfProcessors: ULONG,</span>
<span class="line" id="L3357">    NtGlobalFlag: ULONG,</span>
<span class="line" id="L3358"></span>
<span class="line" id="L3359">    <span class="tok-comment">// Versions: all</span>
</span>
<span class="line" id="L3360">    CriticalSectionTimeout: LARGE_INTEGER,</span>
<span class="line" id="L3361"></span>
<span class="line" id="L3362">    <span class="tok-comment">// End of Original PEB size</span>
</span>
<span class="line" id="L3363"></span>
<span class="line" id="L3364">    <span class="tok-comment">// Fields appended in 3.51:</span>
</span>
<span class="line" id="L3365">    HeapSegmentReserve: ULONG_PTR,</span>
<span class="line" id="L3366">    HeapSegmentCommit: ULONG_PTR,</span>
<span class="line" id="L3367">    HeapDeCommitTotalFreeThreshold: ULONG_PTR,</span>
<span class="line" id="L3368">    HeapDeCommitFreeBlockThreshold: ULONG_PTR,</span>
<span class="line" id="L3369">    NumberOfHeaps: ULONG,</span>
<span class="line" id="L3370">    MaximumNumberOfHeaps: ULONG,</span>
<span class="line" id="L3371">    ProcessHeaps: *PVOID,</span>
<span class="line" id="L3372"></span>
<span class="line" id="L3373">    <span class="tok-comment">// Fields appended in 4.0:</span>
</span>
<span class="line" id="L3374">    GdiSharedHandleTable: PVOID,</span>
<span class="line" id="L3375">    ProcessStarterHelper: PVOID,</span>
<span class="line" id="L3376">    GdiDCAttributeList: ULONG,</span>
<span class="line" id="L3377">    <span class="tok-comment">// note: there is padding here on 64 bit</span>
</span>
<span class="line" id="L3378">    LoaderLock: *RTL_CRITICAL_SECTION,</span>
<span class="line" id="L3379">    OSMajorVersion: ULONG,</span>
<span class="line" id="L3380">    OSMinorVersion: ULONG,</span>
<span class="line" id="L3381">    OSBuildNumber: USHORT,</span>
<span class="line" id="L3382">    OSCSDVersion: USHORT,</span>
<span class="line" id="L3383">    OSPlatformId: ULONG,</span>
<span class="line" id="L3384">    ImageSubSystem: ULONG,</span>
<span class="line" id="L3385">    ImageSubSystemMajorVersion: ULONG,</span>
<span class="line" id="L3386">    ImageSubSystemMinorVersion: ULONG,</span>
<span class="line" id="L3387">    <span class="tok-comment">// note: there is padding here on 64 bit</span>
</span>
<span class="line" id="L3388">    ActiveProcessAffinityMask: KAFFINITY,</span>
<span class="line" id="L3389">    GdiHandleBuffer: [</span>
<span class="line" id="L3390">        <span class="tok-kw">switch</span> (<span class="tok-builtin">@sizeOf</span>(<span class="tok-type">usize</span>)) {</span>
<span class="line" id="L3391">            <span class="tok-number">4</span> =&gt; <span class="tok-number">0x22</span>,</span>
<span class="line" id="L3392">            <span class="tok-number">8</span> =&gt; <span class="tok-number">0x3C</span>,</span>
<span class="line" id="L3393">            <span class="tok-kw">else</span> =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L3394">        }</span>
<span class="line" id="L3395">    ]ULONG,</span>
<span class="line" id="L3396"></span>
<span class="line" id="L3397">    <span class="tok-comment">// Fields appended in 5.0 (Windows 2000):</span>
</span>
<span class="line" id="L3398">    PostProcessInitRoutine: PVOID,</span>
<span class="line" id="L3399">    TlsExpansionBitmap: *RTL_BITMAP,</span>
<span class="line" id="L3400">    TlsExpansionBitmapBits: [<span class="tok-number">32</span>]ULONG,</span>
<span class="line" id="L3401">    SessionId: ULONG,</span>
<span class="line" id="L3402">    <span class="tok-comment">// note: there is padding here on 64 bit</span>
</span>
<span class="line" id="L3403">    <span class="tok-comment">// Versions: 5.1+</span>
</span>
<span class="line" id="L3404">    AppCompatFlags: ULARGE_INTEGER,</span>
<span class="line" id="L3405">    AppCompatFlagsUser: ULARGE_INTEGER,</span>
<span class="line" id="L3406">    ShimData: PVOID,</span>
<span class="line" id="L3407">    <span class="tok-comment">// Versions: 5.0+</span>
</span>
<span class="line" id="L3408">    AppCompatInfo: PVOID,</span>
<span class="line" id="L3409">    CSDVersion: UNICODE_STRING,</span>
<span class="line" id="L3410"></span>
<span class="line" id="L3411">    <span class="tok-comment">// Fields appended in 5.1 (Windows XP):</span>
</span>
<span class="line" id="L3412">    ActivationContextData: *<span class="tok-kw">const</span> ACTIVATION_CONTEXT_DATA,</span>
<span class="line" id="L3413">    ProcessAssemblyStorageMap: *ASSEMBLY_STORAGE_MAP,</span>
<span class="line" id="L3414">    SystemDefaultActivationData: *<span class="tok-kw">const</span> ACTIVATION_CONTEXT_DATA,</span>
<span class="line" id="L3415">    SystemAssemblyStorageMap: *ASSEMBLY_STORAGE_MAP,</span>
<span class="line" id="L3416">    MinimumStackCommit: ULONG_PTR,</span>
<span class="line" id="L3417"></span>
<span class="line" id="L3418">    <span class="tok-comment">// Fields appended in 5.2 (Windows Server 2003):</span>
</span>
<span class="line" id="L3419">    FlsCallback: *FLS_CALLBACK_INFO,</span>
<span class="line" id="L3420">    FlsListHead: LIST_ENTRY,</span>
<span class="line" id="L3421">    FlsBitmap: *RTL_BITMAP,</span>
<span class="line" id="L3422">    FlsBitmapBits: [<span class="tok-number">4</span>]ULONG,</span>
<span class="line" id="L3423">    FlsHighIndex: ULONG,</span>
<span class="line" id="L3424"></span>
<span class="line" id="L3425">    <span class="tok-comment">// Fields appended in 6.0 (Windows Vista):</span>
</span>
<span class="line" id="L3426">    WerRegistrationData: PVOID,</span>
<span class="line" id="L3427">    WerShipAssertPtr: PVOID,</span>
<span class="line" id="L3428"></span>
<span class="line" id="L3429">    <span class="tok-comment">// Fields appended in 6.1 (Windows 7):</span>
</span>
<span class="line" id="L3430">    pUnused: PVOID, <span class="tok-comment">// previously pContextData</span>
</span>
<span class="line" id="L3431">    pImageHeaderHash: PVOID,</span>
<span class="line" id="L3432"></span>
<span class="line" id="L3433">    <span class="tok-comment">/// TODO: https://www.geoffchappell.com/studies/windows/win32/ntdll/structs/peb/tracingflags.htm</span></span>
<span class="line" id="L3434">    TracingFlags: ULONG,</span>
<span class="line" id="L3435"></span>
<span class="line" id="L3436">    <span class="tok-comment">// Fields appended in 6.2 (Windows 8):</span>
</span>
<span class="line" id="L3437">    CsrServerReadOnlySharedMemoryBase: ULONGLONG,</span>
<span class="line" id="L3438"></span>
<span class="line" id="L3439">    <span class="tok-comment">// Fields appended in 1511:</span>
</span>
<span class="line" id="L3440">    TppWorkerpListLock: ULONG,</span>
<span class="line" id="L3441">    TppWorkerpList: LIST_ENTRY,</span>
<span class="line" id="L3442">    WaitOnAddressHashTable: [<span class="tok-number">0x80</span>]PVOID,</span>
<span class="line" id="L3443"></span>
<span class="line" id="L3444">    <span class="tok-comment">// Fields appended in 1709:</span>
</span>
<span class="line" id="L3445">    TelemetryCoverageHeader: PVOID,</span>
<span class="line" id="L3446">    CloudFileFlags: ULONG,</span>
<span class="line" id="L3447">};</span>
<span class="line" id="L3448"></span>
<span class="line" id="L3449"><span class="tok-comment">/// The `PEB_LDR_DATA` structure is the main record of what modules are loaded in a process.</span></span>
<span class="line" id="L3450"><span class="tok-comment">/// It is essentially the head of three double-linked lists of `LDR_DATA_TABLE_ENTRY` structures which each represent one loaded module.</span></span>
<span class="line" id="L3451"><span class="tok-comment">///</span></span>
<span class="line" id="L3452"><span class="tok-comment">/// Microsoft documentation of this is incomplete, the fields here are taken from various resources including:</span></span>
<span class="line" id="L3453"><span class="tok-comment">///  - https://www.geoffchappell.com/studies/windows/win32/ntdll/structs/peb_ldr_data.htm</span></span>
<span class="line" id="L3454"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> PEB_LDR_DATA = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L3455">    <span class="tok-comment">// Versions: 3.51 and higher</span>
</span>
<span class="line" id="L3456">    <span class="tok-comment">/// The size in bytes of the structure</span></span>
<span class="line" id="L3457">    Length: ULONG,</span>
<span class="line" id="L3458"></span>
<span class="line" id="L3459">    <span class="tok-comment">/// TRUE if the structure is prepared.</span></span>
<span class="line" id="L3460">    Initialized: BOOLEAN,</span>
<span class="line" id="L3461"></span>
<span class="line" id="L3462">    SsHandle: PVOID,</span>
<span class="line" id="L3463">    InLoadOrderModuleList: LIST_ENTRY,</span>
<span class="line" id="L3464">    InMemoryOrderModuleList: LIST_ENTRY,</span>
<span class="line" id="L3465">    InInitializationOrderModuleList: LIST_ENTRY,</span>
<span class="line" id="L3466"></span>
<span class="line" id="L3467">    <span class="tok-comment">// Versions: 5.1 and higher</span>
</span>
<span class="line" id="L3468"></span>
<span class="line" id="L3469">    <span class="tok-comment">/// No known use of this field is known in Windows 8 and higher.</span></span>
<span class="line" id="L3470">    EntryInProgress: PVOID,</span>
<span class="line" id="L3471"></span>
<span class="line" id="L3472">    <span class="tok-comment">// Versions: 6.0 from Windows Vista SP1, and higher</span>
</span>
<span class="line" id="L3473">    ShutdownInProgress: BOOLEAN,</span>
<span class="line" id="L3474"></span>
<span class="line" id="L3475">    <span class="tok-comment">/// Though ShutdownThreadId is declared as a HANDLE,</span></span>
<span class="line" id="L3476">    <span class="tok-comment">/// it is indeed the thread ID as suggested by its name.</span></span>
<span class="line" id="L3477">    <span class="tok-comment">/// It is picked up from the UniqueThread member of the CLIENT_ID in the</span></span>
<span class="line" id="L3478">    <span class="tok-comment">/// TEB of the thread that asks to terminate the process.</span></span>
<span class="line" id="L3479">    ShutdownThreadId: HANDLE,</span>
<span class="line" id="L3480">};</span>
<span class="line" id="L3481"></span>
<span class="line" id="L3482"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> RTL_USER_PROCESS_PARAMETERS = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L3483">    AllocationSize: ULONG,</span>
<span class="line" id="L3484">    Size: ULONG,</span>
<span class="line" id="L3485">    Flags: ULONG,</span>
<span class="line" id="L3486">    DebugFlags: ULONG,</span>
<span class="line" id="L3487">    ConsoleHandle: HANDLE,</span>
<span class="line" id="L3488">    ConsoleFlags: ULONG,</span>
<span class="line" id="L3489">    hStdInput: HANDLE,</span>
<span class="line" id="L3490">    hStdOutput: HANDLE,</span>
<span class="line" id="L3491">    hStdError: HANDLE,</span>
<span class="line" id="L3492">    CurrentDirectory: CURDIR,</span>
<span class="line" id="L3493">    DllPath: UNICODE_STRING,</span>
<span class="line" id="L3494">    ImagePathName: UNICODE_STRING,</span>
<span class="line" id="L3495">    CommandLine: UNICODE_STRING,</span>
<span class="line" id="L3496">    Environment: [*:<span class="tok-number">0</span>]WCHAR,</span>
<span class="line" id="L3497">    dwX: ULONG,</span>
<span class="line" id="L3498">    dwY: ULONG,</span>
<span class="line" id="L3499">    dwXSize: ULONG,</span>
<span class="line" id="L3500">    dwYSize: ULONG,</span>
<span class="line" id="L3501">    dwXCountChars: ULONG,</span>
<span class="line" id="L3502">    dwYCountChars: ULONG,</span>
<span class="line" id="L3503">    dwFillAttribute: ULONG,</span>
<span class="line" id="L3504">    dwFlags: ULONG,</span>
<span class="line" id="L3505">    dwShowWindow: ULONG,</span>
<span class="line" id="L3506">    WindowTitle: UNICODE_STRING,</span>
<span class="line" id="L3507">    Desktop: UNICODE_STRING,</span>
<span class="line" id="L3508">    ShellInfo: UNICODE_STRING,</span>
<span class="line" id="L3509">    RuntimeInfo: UNICODE_STRING,</span>
<span class="line" id="L3510">    DLCurrentDirectory: [<span class="tok-number">0x20</span>]RTL_DRIVE_LETTER_CURDIR,</span>
<span class="line" id="L3511">};</span>
<span class="line" id="L3512"></span>
<span class="line" id="L3513"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> RTL_DRIVE_LETTER_CURDIR = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L3514">    Flags: <span class="tok-type">c_ushort</span>,</span>
<span class="line" id="L3515">    Length: <span class="tok-type">c_ushort</span>,</span>
<span class="line" id="L3516">    TimeStamp: ULONG,</span>
<span class="line" id="L3517">    DosPath: UNICODE_STRING,</span>
<span class="line" id="L3518">};</span>
<span class="line" id="L3519"></span>
<span class="line" id="L3520"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> PPS_POST_PROCESS_INIT_ROUTINE = <span class="tok-kw">switch</span> (builtin.zig_backend) {</span>
<span class="line" id="L3521">    .stage1 =&gt; ?<span class="tok-kw">fn</span> () <span class="tok-kw">callconv</span>(.C) <span class="tok-type">void</span>,</span>
<span class="line" id="L3522">    <span class="tok-kw">else</span> =&gt; ?*<span class="tok-kw">const</span> <span class="tok-kw">fn</span> () <span class="tok-kw">callconv</span>(.C) <span class="tok-type">void</span>,</span>
<span class="line" id="L3523">};</span>
<span class="line" id="L3524"></span>
<span class="line" id="L3525"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FILE_BOTH_DIR_INFORMATION = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L3526">    NextEntryOffset: ULONG,</span>
<span class="line" id="L3527">    FileIndex: ULONG,</span>
<span class="line" id="L3528">    CreationTime: LARGE_INTEGER,</span>
<span class="line" id="L3529">    LastAccessTime: LARGE_INTEGER,</span>
<span class="line" id="L3530">    LastWriteTime: LARGE_INTEGER,</span>
<span class="line" id="L3531">    ChangeTime: LARGE_INTEGER,</span>
<span class="line" id="L3532">    EndOfFile: LARGE_INTEGER,</span>
<span class="line" id="L3533">    AllocationSize: LARGE_INTEGER,</span>
<span class="line" id="L3534">    FileAttributes: ULONG,</span>
<span class="line" id="L3535">    FileNameLength: ULONG,</span>
<span class="line" id="L3536">    EaSize: ULONG,</span>
<span class="line" id="L3537">    ShortNameLength: CHAR,</span>
<span class="line" id="L3538">    ShortName: [<span class="tok-number">12</span>]WCHAR,</span>
<span class="line" id="L3539">    FileName: [<span class="tok-number">1</span>]WCHAR,</span>
<span class="line" id="L3540">};</span>
<span class="line" id="L3541"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FILE_BOTH_DIRECTORY_INFORMATION = FILE_BOTH_DIR_INFORMATION;</span>
<span class="line" id="L3542"></span>
<span class="line" id="L3543"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IO_APC_ROUTINE = <span class="tok-kw">switch</span> (builtin.zig_backend) {</span>
<span class="line" id="L3544">    .stage1 =&gt; <span class="tok-kw">fn</span> (PVOID, *IO_STATUS_BLOCK, ULONG) <span class="tok-kw">callconv</span>(.C) <span class="tok-type">void</span>,</span>
<span class="line" id="L3545">    <span class="tok-kw">else</span> =&gt; *<span class="tok-kw">const</span> <span class="tok-kw">fn</span> (PVOID, *IO_STATUS_BLOCK, ULONG) <span class="tok-kw">callconv</span>(.C) <span class="tok-type">void</span>,</span>
<span class="line" id="L3546">};</span>
<span class="line" id="L3547"></span>
<span class="line" id="L3548"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> CURDIR = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L3549">    DosPath: UNICODE_STRING,</span>
<span class="line" id="L3550">    Handle: HANDLE,</span>
<span class="line" id="L3551">};</span>
<span class="line" id="L3552"></span>
<span class="line" id="L3553"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> DUPLICATE_SAME_ACCESS = <span class="tok-number">2</span>;</span>
<span class="line" id="L3554"></span>
<span class="line" id="L3555"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> MODULEINFO = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L3556">    lpBaseOfDll: LPVOID,</span>
<span class="line" id="L3557">    SizeOfImage: DWORD,</span>
<span class="line" id="L3558">    EntryPoint: LPVOID,</span>
<span class="line" id="L3559">};</span>
<span class="line" id="L3560"></span>
<span class="line" id="L3561"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> PSAPI_WS_WATCH_INFORMATION = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L3562">    FaultingPc: LPVOID,</span>
<span class="line" id="L3563">    FaultingVa: LPVOID,</span>
<span class="line" id="L3564">};</span>
<span class="line" id="L3565"></span>
<span class="line" id="L3566"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> PROCESS_MEMORY_COUNTERS = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L3567">    cb: DWORD,</span>
<span class="line" id="L3568">    PageFaultCount: DWORD,</span>
<span class="line" id="L3569">    PeakWorkingSetSize: SIZE_T,</span>
<span class="line" id="L3570">    WorkingSetSize: SIZE_T,</span>
<span class="line" id="L3571">    QuotaPeakPagedPoolUsage: SIZE_T,</span>
<span class="line" id="L3572">    QuotaPagedPoolUsage: SIZE_T,</span>
<span class="line" id="L3573">    QuotaPeakNonPagedPoolUsage: SIZE_T,</span>
<span class="line" id="L3574">    QuotaNonPagedPoolUsage: SIZE_T,</span>
<span class="line" id="L3575">    PagefileUsage: SIZE_T,</span>
<span class="line" id="L3576">    PeakPagefileUsage: SIZE_T,</span>
<span class="line" id="L3577">};</span>
<span class="line" id="L3578"></span>
<span class="line" id="L3579"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> PROCESS_MEMORY_COUNTERS_EX = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L3580">    cb: DWORD,</span>
<span class="line" id="L3581">    PageFaultCount: DWORD,</span>
<span class="line" id="L3582">    PeakWorkingSetSize: SIZE_T,</span>
<span class="line" id="L3583">    WorkingSetSize: SIZE_T,</span>
<span class="line" id="L3584">    QuotaPeakPagedPoolUsage: SIZE_T,</span>
<span class="line" id="L3585">    QuotaPagedPoolUsage: SIZE_T,</span>
<span class="line" id="L3586">    QuotaPeakNonPagedPoolUsage: SIZE_T,</span>
<span class="line" id="L3587">    QuotaNonPagedPoolUsage: SIZE_T,</span>
<span class="line" id="L3588">    PagefileUsage: SIZE_T,</span>
<span class="line" id="L3589">    PeakPagefileUsage: SIZE_T,</span>
<span class="line" id="L3590">    PrivateUsage: SIZE_T,</span>
<span class="line" id="L3591">};</span>
<span class="line" id="L3592"></span>
<span class="line" id="L3593"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> PERFORMANCE_INFORMATION = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L3594">    cb: DWORD,</span>
<span class="line" id="L3595">    CommitTotal: SIZE_T,</span>
<span class="line" id="L3596">    CommitLimit: SIZE_T,</span>
<span class="line" id="L3597">    CommitPeak: SIZE_T,</span>
<span class="line" id="L3598">    PhysicalTotal: SIZE_T,</span>
<span class="line" id="L3599">    PhysicalAvailable: SIZE_T,</span>
<span class="line" id="L3600">    SystemCache: SIZE_T,</span>
<span class="line" id="L3601">    KernelTotal: SIZE_T,</span>
<span class="line" id="L3602">    KernelPaged: SIZE_T,</span>
<span class="line" id="L3603">    KernelNonpaged: SIZE_T,</span>
<span class="line" id="L3604">    PageSize: SIZE_T,</span>
<span class="line" id="L3605">    HandleCount: DWORD,</span>
<span class="line" id="L3606">    ProcessCount: DWORD,</span>
<span class="line" id="L3607">    ThreadCount: DWORD,</span>
<span class="line" id="L3608">};</span>
<span class="line" id="L3609"></span>
<span class="line" id="L3610"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> ENUM_PAGE_FILE_INFORMATION = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L3611">    cb: DWORD,</span>
<span class="line" id="L3612">    Reserved: DWORD,</span>
<span class="line" id="L3613">    TotalSize: SIZE_T,</span>
<span class="line" id="L3614">    TotalInUse: SIZE_T,</span>
<span class="line" id="L3615">    PeakUsage: SIZE_T,</span>
<span class="line" id="L3616">};</span>
<span class="line" id="L3617"></span>
<span class="line" id="L3618"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> PENUM_PAGE_FILE_CALLBACKW = <span class="tok-kw">switch</span> (builtin.zig_backend) {</span>
<span class="line" id="L3619">    .stage1 =&gt; ?<span class="tok-kw">fn</span> (?LPVOID, *ENUM_PAGE_FILE_INFORMATION, LPCWSTR) <span class="tok-kw">callconv</span>(.C) BOOL,</span>
<span class="line" id="L3620">    <span class="tok-kw">else</span> =&gt; ?*<span class="tok-kw">const</span> <span class="tok-kw">fn</span> (?LPVOID, *ENUM_PAGE_FILE_INFORMATION, LPCWSTR) <span class="tok-kw">callconv</span>(.C) BOOL,</span>
<span class="line" id="L3621">};</span>
<span class="line" id="L3622"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> PENUM_PAGE_FILE_CALLBACKA = <span class="tok-kw">switch</span> (builtin.zig_backend) {</span>
<span class="line" id="L3623">    .stage1 =&gt; ?<span class="tok-kw">fn</span> (?LPVOID, *ENUM_PAGE_FILE_INFORMATION, LPCSTR) <span class="tok-kw">callconv</span>(.C) BOOL,</span>
<span class="line" id="L3624">    <span class="tok-kw">else</span> =&gt; ?*<span class="tok-kw">const</span> <span class="tok-kw">fn</span> (?LPVOID, *ENUM_PAGE_FILE_INFORMATION, LPCSTR) <span class="tok-kw">callconv</span>(.C) BOOL,</span>
<span class="line" id="L3625">};</span>
<span class="line" id="L3626"></span>
<span class="line" id="L3627"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> PSAPI_WS_WATCH_INFORMATION_EX = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L3628">    BasicInfo: PSAPI_WS_WATCH_INFORMATION,</span>
<span class="line" id="L3629">    FaultingThreadId: ULONG_PTR,</span>
<span class="line" id="L3630">    Flags: ULONG_PTR,</span>
<span class="line" id="L3631">};</span>
<span class="line" id="L3632"></span>
<span class="line" id="L3633"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> OSVERSIONINFOW = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L3634">    dwOSVersionInfoSize: ULONG,</span>
<span class="line" id="L3635">    dwMajorVersion: ULONG,</span>
<span class="line" id="L3636">    dwMinorVersion: ULONG,</span>
<span class="line" id="L3637">    dwBuildNumber: ULONG,</span>
<span class="line" id="L3638">    dwPlatformId: ULONG,</span>
<span class="line" id="L3639">    szCSDVersion: [<span class="tok-number">128</span>]WCHAR,</span>
<span class="line" id="L3640">};</span>
<span class="line" id="L3641"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> RTL_OSVERSIONINFOW = OSVERSIONINFOW;</span>
<span class="line" id="L3642"></span>
<span class="line" id="L3643"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> REPARSE_DATA_BUFFER = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L3644">    ReparseTag: ULONG,</span>
<span class="line" id="L3645">    ReparseDataLength: USHORT,</span>
<span class="line" id="L3646">    Reserved: USHORT,</span>
<span class="line" id="L3647">    DataBuffer: [<span class="tok-number">1</span>]UCHAR,</span>
<span class="line" id="L3648">};</span>
<span class="line" id="L3649"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SYMBOLIC_LINK_REPARSE_BUFFER = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L3650">    SubstituteNameOffset: USHORT,</span>
<span class="line" id="L3651">    SubstituteNameLength: USHORT,</span>
<span class="line" id="L3652">    PrintNameOffset: USHORT,</span>
<span class="line" id="L3653">    PrintNameLength: USHORT,</span>
<span class="line" id="L3654">    Flags: ULONG,</span>
<span class="line" id="L3655">    PathBuffer: [<span class="tok-number">1</span>]WCHAR,</span>
<span class="line" id="L3656">};</span>
<span class="line" id="L3657"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> MOUNT_POINT_REPARSE_BUFFER = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L3658">    SubstituteNameOffset: USHORT,</span>
<span class="line" id="L3659">    SubstituteNameLength: USHORT,</span>
<span class="line" id="L3660">    PrintNameOffset: USHORT,</span>
<span class="line" id="L3661">    PrintNameLength: USHORT,</span>
<span class="line" id="L3662">    PathBuffer: [<span class="tok-number">1</span>]WCHAR,</span>
<span class="line" id="L3663">};</span>
<span class="line" id="L3664"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> MAXIMUM_REPARSE_DATA_BUFFER_SIZE: ULONG = <span class="tok-number">16</span> * <span class="tok-number">1024</span>;</span>
<span class="line" id="L3665"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FSCTL_SET_REPARSE_POINT: DWORD = <span class="tok-number">0x900a4</span>;</span>
<span class="line" id="L3666"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FSCTL_GET_REPARSE_POINT: DWORD = <span class="tok-number">0x900a8</span>;</span>
<span class="line" id="L3667"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IO_REPARSE_TAG_SYMLINK: ULONG = <span class="tok-number">0xa000000c</span>;</span>
<span class="line" id="L3668"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IO_REPARSE_TAG_MOUNT_POINT: ULONG = <span class="tok-number">0xa0000003</span>;</span>
<span class="line" id="L3669"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SYMLINK_FLAG_RELATIVE: ULONG = <span class="tok-number">0x1</span>;</span>
<span class="line" id="L3670"></span>
<span class="line" id="L3671"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SYMBOLIC_LINK_FLAG_DIRECTORY: DWORD = <span class="tok-number">0x1</span>;</span>
<span class="line" id="L3672"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SYMBOLIC_LINK_FLAG_ALLOW_UNPRIVILEGED_CREATE: DWORD = <span class="tok-number">0x2</span>;</span>
<span class="line" id="L3673"></span>
<span class="line" id="L3674"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> MOUNTMGR_MOUNT_POINT = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L3675">    SymbolicLinkNameOffset: ULONG,</span>
<span class="line" id="L3676">    SymbolicLinkNameLength: USHORT,</span>
<span class="line" id="L3677">    Reserved1: USHORT,</span>
<span class="line" id="L3678">    UniqueIdOffset: ULONG,</span>
<span class="line" id="L3679">    UniqueIdLength: USHORT,</span>
<span class="line" id="L3680">    Reserved2: USHORT,</span>
<span class="line" id="L3681">    DeviceNameOffset: ULONG,</span>
<span class="line" id="L3682">    DeviceNameLength: USHORT,</span>
<span class="line" id="L3683">    Reserved3: USHORT,</span>
<span class="line" id="L3684">};</span>
<span class="line" id="L3685"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> MOUNTMGR_MOUNT_POINTS = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L3686">    Size: ULONG,</span>
<span class="line" id="L3687">    NumberOfMountPoints: ULONG,</span>
<span class="line" id="L3688">    MountPoints: [<span class="tok-number">1</span>]MOUNTMGR_MOUNT_POINT,</span>
<span class="line" id="L3689">};</span>
<span class="line" id="L3690"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IOCTL_MOUNTMGR_QUERY_POINTS: ULONG = <span class="tok-number">0x6d0008</span>;</span>
<span class="line" id="L3691"></span>
<span class="line" id="L3692"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> OBJECT_INFORMATION_CLASS = <span class="tok-kw">enum</span>(<span class="tok-type">c_int</span>) {</span>
<span class="line" id="L3693">    ObjectBasicInformation = <span class="tok-number">0</span>,</span>
<span class="line" id="L3694">    ObjectNameInformation = <span class="tok-number">1</span>,</span>
<span class="line" id="L3695">    ObjectTypeInformation = <span class="tok-number">2</span>,</span>
<span class="line" id="L3696">    ObjectTypesInformation = <span class="tok-number">3</span>,</span>
<span class="line" id="L3697">    ObjectHandleFlagInformation = <span class="tok-number">4</span>,</span>
<span class="line" id="L3698">    ObjectSessionInformation = <span class="tok-number">5</span>,</span>
<span class="line" id="L3699">    MaxObjectInfoClass,</span>
<span class="line" id="L3700">};</span>
<span class="line" id="L3701"></span>
<span class="line" id="L3702"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> OBJECT_NAME_INFORMATION = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L3703">    Name: UNICODE_STRING,</span>
<span class="line" id="L3704">};</span>
<span class="line" id="L3705"></span>
<span class="line" id="L3706"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SRWLOCK_INIT = SRWLOCK{};</span>
<span class="line" id="L3707"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SRWLOCK = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L3708">    Ptr: ?PVOID = <span class="tok-null">null</span>,</span>
<span class="line" id="L3709">};</span>
<span class="line" id="L3710"></span>
<span class="line" id="L3711"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> CONDITION_VARIABLE_INIT = CONDITION_VARIABLE{};</span>
<span class="line" id="L3712"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> CONDITION_VARIABLE = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L3713">    Ptr: ?PVOID = <span class="tok-null">null</span>,</span>
<span class="line" id="L3714">};</span>
<span class="line" id="L3715"></span>
<span class="line" id="L3716"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FILE_SKIP_COMPLETION_PORT_ON_SUCCESS = <span class="tok-number">0x1</span>;</span>
<span class="line" id="L3717"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FILE_SKIP_SET_EVENT_ON_HANDLE = <span class="tok-number">0x2</span>;</span>
<span class="line" id="L3718"></span>
<span class="line" id="L3719"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> CTRL_C_EVENT: DWORD = <span class="tok-number">0</span>;</span>
<span class="line" id="L3720"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> CTRL_BREAK_EVENT: DWORD = <span class="tok-number">1</span>;</span>
<span class="line" id="L3721"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> CTRL_CLOSE_EVENT: DWORD = <span class="tok-number">2</span>;</span>
<span class="line" id="L3722"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> CTRL_LOGOFF_EVENT: DWORD = <span class="tok-number">5</span>;</span>
<span class="line" id="L3723"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> CTRL_SHUTDOWN_EVENT: DWORD = <span class="tok-number">6</span>;</span>
<span class="line" id="L3724"></span>
<span class="line" id="L3725"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> HANDLER_ROUTINE = <span class="tok-kw">switch</span> (builtin.zig_backend) {</span>
<span class="line" id="L3726">    .stage1 =&gt; <span class="tok-kw">fn</span> (dwCtrlType: DWORD) <span class="tok-kw">callconv</span>(.C) BOOL,</span>
<span class="line" id="L3727">    <span class="tok-kw">else</span> =&gt; *<span class="tok-kw">const</span> <span class="tok-kw">fn</span> (dwCtrlType: DWORD) <span class="tok-kw">callconv</span>(.C) BOOL,</span>
<span class="line" id="L3728">};</span>
<span class="line" id="L3729"></span>
</code></pre></body>
</html>