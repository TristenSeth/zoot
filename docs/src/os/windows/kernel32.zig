<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">    <title>os/windows/kernel32.zig - source view</title>
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
<span class="line" id="L5"><span class="tok-kw">const</span> BOOLEAN = windows.BOOLEAN;</span>
<span class="line" id="L6"><span class="tok-kw">const</span> CONDITION_VARIABLE = windows.CONDITION_VARIABLE;</span>
<span class="line" id="L7"><span class="tok-kw">const</span> CONSOLE_SCREEN_BUFFER_INFO = windows.CONSOLE_SCREEN_BUFFER_INFO;</span>
<span class="line" id="L8"><span class="tok-kw">const</span> COORD = windows.COORD;</span>
<span class="line" id="L9"><span class="tok-kw">const</span> DWORD = windows.DWORD;</span>
<span class="line" id="L10"><span class="tok-kw">const</span> FILE_INFO_BY_HANDLE_CLASS = windows.FILE_INFO_BY_HANDLE_CLASS;</span>
<span class="line" id="L11"><span class="tok-kw">const</span> HANDLE = windows.HANDLE;</span>
<span class="line" id="L12"><span class="tok-kw">const</span> HMODULE = windows.HMODULE;</span>
<span class="line" id="L13"><span class="tok-kw">const</span> HRESULT = windows.HRESULT;</span>
<span class="line" id="L14"><span class="tok-kw">const</span> LARGE_INTEGER = windows.LARGE_INTEGER;</span>
<span class="line" id="L15"><span class="tok-kw">const</span> LPCWSTR = windows.LPCWSTR;</span>
<span class="line" id="L16"><span class="tok-kw">const</span> LPTHREAD_START_ROUTINE = windows.LPTHREAD_START_ROUTINE;</span>
<span class="line" id="L17"><span class="tok-kw">const</span> LPVOID = windows.LPVOID;</span>
<span class="line" id="L18"><span class="tok-kw">const</span> LPWSTR = windows.LPWSTR;</span>
<span class="line" id="L19"><span class="tok-kw">const</span> MODULEINFO = windows.MODULEINFO;</span>
<span class="line" id="L20"><span class="tok-kw">const</span> OVERLAPPED = windows.OVERLAPPED;</span>
<span class="line" id="L21"><span class="tok-kw">const</span> PERFORMANCE_INFORMATION = windows.PERFORMANCE_INFORMATION;</span>
<span class="line" id="L22"><span class="tok-kw">const</span> PROCESS_MEMORY_COUNTERS = windows.PROCESS_MEMORY_COUNTERS;</span>
<span class="line" id="L23"><span class="tok-kw">const</span> PSAPI_WS_WATCH_INFORMATION = windows.PSAPI_WS_WATCH_INFORMATION;</span>
<span class="line" id="L24"><span class="tok-kw">const</span> PSAPI_WS_WATCH_INFORMATION_EX = windows.PSAPI_WS_WATCH_INFORMATION_EX;</span>
<span class="line" id="L25"><span class="tok-kw">const</span> SECURITY_ATTRIBUTES = windows.SECURITY_ATTRIBUTES;</span>
<span class="line" id="L26"><span class="tok-kw">const</span> SIZE_T = windows.SIZE_T;</span>
<span class="line" id="L27"><span class="tok-kw">const</span> SRWLOCK = windows.SRWLOCK;</span>
<span class="line" id="L28"><span class="tok-kw">const</span> UINT = windows.UINT;</span>
<span class="line" id="L29"><span class="tok-kw">const</span> VECTORED_EXCEPTION_HANDLER = windows.VECTORED_EXCEPTION_HANDLER;</span>
<span class="line" id="L30"><span class="tok-kw">const</span> WCHAR = windows.WCHAR;</span>
<span class="line" id="L31"><span class="tok-kw">const</span> WINAPI = windows.WINAPI;</span>
<span class="line" id="L32"><span class="tok-kw">const</span> WORD = windows.WORD;</span>
<span class="line" id="L33"><span class="tok-kw">const</span> Win32Error = windows.Win32Error;</span>
<span class="line" id="L34"><span class="tok-kw">const</span> va_list = windows.va_list;</span>
<span class="line" id="L35"><span class="tok-kw">const</span> HLOCAL = windows.HLOCAL;</span>
<span class="line" id="L36"><span class="tok-kw">const</span> FILETIME = windows.FILETIME;</span>
<span class="line" id="L37"><span class="tok-kw">const</span> STARTUPINFOW = windows.STARTUPINFOW;</span>
<span class="line" id="L38"><span class="tok-kw">const</span> PROCESS_INFORMATION = windows.PROCESS_INFORMATION;</span>
<span class="line" id="L39"><span class="tok-kw">const</span> OVERLAPPED_ENTRY = windows.OVERLAPPED_ENTRY;</span>
<span class="line" id="L40"><span class="tok-kw">const</span> LPHEAP_SUMMARY = windows.LPHEAP_SUMMARY;</span>
<span class="line" id="L41"><span class="tok-kw">const</span> ULONG_PTR = windows.ULONG_PTR;</span>
<span class="line" id="L42"><span class="tok-kw">const</span> FILE_NOTIFY_INFORMATION = windows.FILE_NOTIFY_INFORMATION;</span>
<span class="line" id="L43"><span class="tok-kw">const</span> HANDLER_ROUTINE = windows.HANDLER_ROUTINE;</span>
<span class="line" id="L44"><span class="tok-kw">const</span> ULONG = windows.ULONG;</span>
<span class="line" id="L45"><span class="tok-kw">const</span> PVOID = windows.PVOID;</span>
<span class="line" id="L46"><span class="tok-kw">const</span> LPSTR = windows.LPSTR;</span>
<span class="line" id="L47"><span class="tok-kw">const</span> PENUM_PAGE_FILE_CALLBACKA = windows.PENUM_PAGE_FILE_CALLBACKA;</span>
<span class="line" id="L48"><span class="tok-kw">const</span> PENUM_PAGE_FILE_CALLBACKW = windows.PENUM_PAGE_FILE_CALLBACKW;</span>
<span class="line" id="L49"><span class="tok-kw">const</span> INIT_ONCE = windows.INIT_ONCE;</span>
<span class="line" id="L50"><span class="tok-kw">const</span> CRITICAL_SECTION = windows.CRITICAL_SECTION;</span>
<span class="line" id="L51"><span class="tok-kw">const</span> WIN32_FIND_DATAW = windows.WIN32_FIND_DATAW;</span>
<span class="line" id="L52"><span class="tok-kw">const</span> CHAR = windows.CHAR;</span>
<span class="line" id="L53"><span class="tok-kw">const</span> BY_HANDLE_FILE_INFORMATION = windows.BY_HANDLE_FILE_INFORMATION;</span>
<span class="line" id="L54"><span class="tok-kw">const</span> SYSTEM_INFO = windows.SYSTEM_INFO;</span>
<span class="line" id="L55"><span class="tok-kw">const</span> LPOVERLAPPED_COMPLETION_ROUTINE = windows.LPOVERLAPPED_COMPLETION_ROUTINE;</span>
<span class="line" id="L56"><span class="tok-kw">const</span> UCHAR = windows.UCHAR;</span>
<span class="line" id="L57"><span class="tok-kw">const</span> FARPROC = windows.FARPROC;</span>
<span class="line" id="L58"><span class="tok-kw">const</span> INIT_ONCE_FN = windows.INIT_ONCE_FN;</span>
<span class="line" id="L59"><span class="tok-kw">const</span> PMEMORY_BASIC_INFORMATION = windows.PMEMORY_BASIC_INFORMATION;</span>
<span class="line" id="L60"></span>
<span class="line" id="L61"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;kernel32&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">AddVectoredExceptionHandler</span>(First: <span class="tok-type">c_ulong</span>, Handler: ?VECTORED_EXCEPTION_HANDLER) <span class="tok-kw">callconv</span>(WINAPI) ?*<span class="tok-type">anyopaque</span>;</span>
<span class="line" id="L62"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;kernel32&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">RemoveVectoredExceptionHandler</span>(Handle: HANDLE) <span class="tok-kw">callconv</span>(WINAPI) <span class="tok-type">c_ulong</span>;</span>
<span class="line" id="L63"></span>
<span class="line" id="L64"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;kernel32&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">CancelIo</span>(hFile: HANDLE) <span class="tok-kw">callconv</span>(WINAPI) BOOL;</span>
<span class="line" id="L65"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;kernel32&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">CancelIoEx</span>(hFile: HANDLE, lpOverlapped: ?*OVERLAPPED) <span class="tok-kw">callconv</span>(WINAPI) BOOL;</span>
<span class="line" id="L66"></span>
<span class="line" id="L67"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;kernel32&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">CloseHandle</span>(hObject: HANDLE) <span class="tok-kw">callconv</span>(WINAPI) BOOL;</span>
<span class="line" id="L68"></span>
<span class="line" id="L69"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;kernel32&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">CreateDirectoryW</span>(lpPathName: [*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u16</span>, lpSecurityAttributes: ?*SECURITY_ATTRIBUTES) <span class="tok-kw">callconv</span>(WINAPI) BOOL;</span>
<span class="line" id="L70"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;kernel32&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">SetEndOfFile</span>(hFile: HANDLE) <span class="tok-kw">callconv</span>(WINAPI) BOOL;</span>
<span class="line" id="L71"></span>
<span class="line" id="L72"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;kernel32&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">CreateEventExW</span>(</span>
<span class="line" id="L73">    lpEventAttributes: ?*SECURITY_ATTRIBUTES,</span>
<span class="line" id="L74">    lpName: [*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u16</span>,</span>
<span class="line" id="L75">    dwFlags: DWORD,</span>
<span class="line" id="L76">    dwDesiredAccess: DWORD,</span>
<span class="line" id="L77">) <span class="tok-kw">callconv</span>(WINAPI) ?HANDLE;</span>
<span class="line" id="L78"></span>
<span class="line" id="L79"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;kernel32&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">CreateFileW</span>(</span>
<span class="line" id="L80">    lpFileName: [*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u16</span>,</span>
<span class="line" id="L81">    dwDesiredAccess: DWORD,</span>
<span class="line" id="L82">    dwShareMode: DWORD,</span>
<span class="line" id="L83">    lpSecurityAttributes: ?*SECURITY_ATTRIBUTES,</span>
<span class="line" id="L84">    dwCreationDisposition: DWORD,</span>
<span class="line" id="L85">    dwFlagsAndAttributes: DWORD,</span>
<span class="line" id="L86">    hTemplateFile: ?HANDLE,</span>
<span class="line" id="L87">) <span class="tok-kw">callconv</span>(WINAPI) HANDLE;</span>
<span class="line" id="L88"></span>
<span class="line" id="L89"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;kernel32&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">CreatePipe</span>(</span>
<span class="line" id="L90">    hReadPipe: *HANDLE,</span>
<span class="line" id="L91">    hWritePipe: *HANDLE,</span>
<span class="line" id="L92">    lpPipeAttributes: *<span class="tok-kw">const</span> SECURITY_ATTRIBUTES,</span>
<span class="line" id="L93">    nSize: DWORD,</span>
<span class="line" id="L94">) <span class="tok-kw">callconv</span>(WINAPI) BOOL;</span>
<span class="line" id="L95"></span>
<span class="line" id="L96"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;kernel32&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">CreateNamedPipeW</span>(</span>
<span class="line" id="L97">    lpName: LPCWSTR,</span>
<span class="line" id="L98">    dwOpenMode: DWORD,</span>
<span class="line" id="L99">    dwPipeMode: DWORD,</span>
<span class="line" id="L100">    nMaxInstances: DWORD,</span>
<span class="line" id="L101">    nOutBufferSize: DWORD,</span>
<span class="line" id="L102">    nInBufferSize: DWORD,</span>
<span class="line" id="L103">    nDefaultTimeOut: DWORD,</span>
<span class="line" id="L104">    lpSecurityAttributes: ?*<span class="tok-kw">const</span> SECURITY_ATTRIBUTES,</span>
<span class="line" id="L105">) <span class="tok-kw">callconv</span>(WINAPI) HANDLE;</span>
<span class="line" id="L106"></span>
<span class="line" id="L107"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;kernel32&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">CreateProcessW</span>(</span>
<span class="line" id="L108">    lpApplicationName: ?LPWSTR,</span>
<span class="line" id="L109">    lpCommandLine: LPWSTR,</span>
<span class="line" id="L110">    lpProcessAttributes: ?*SECURITY_ATTRIBUTES,</span>
<span class="line" id="L111">    lpThreadAttributes: ?*SECURITY_ATTRIBUTES,</span>
<span class="line" id="L112">    bInheritHandles: BOOL,</span>
<span class="line" id="L113">    dwCreationFlags: DWORD,</span>
<span class="line" id="L114">    lpEnvironment: ?*<span class="tok-type">anyopaque</span>,</span>
<span class="line" id="L115">    lpCurrentDirectory: ?LPWSTR,</span>
<span class="line" id="L116">    lpStartupInfo: *STARTUPINFOW,</span>
<span class="line" id="L117">    lpProcessInformation: *PROCESS_INFORMATION,</span>
<span class="line" id="L118">) <span class="tok-kw">callconv</span>(WINAPI) BOOL;</span>
<span class="line" id="L119"></span>
<span class="line" id="L120"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;kernel32&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">CreateSymbolicLinkW</span>(lpSymlinkFileName: [*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u16</span>, lpTargetFileName: [*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u16</span>, dwFlags: DWORD) <span class="tok-kw">callconv</span>(WINAPI) BOOLEAN;</span>
<span class="line" id="L121"></span>
<span class="line" id="L122"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;kernel32&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">CreateIoCompletionPort</span>(FileHandle: HANDLE, ExistingCompletionPort: ?HANDLE, CompletionKey: ULONG_PTR, NumberOfConcurrentThreads: DWORD) <span class="tok-kw">callconv</span>(WINAPI) ?HANDLE;</span>
<span class="line" id="L123"></span>
<span class="line" id="L124"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;kernel32&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">CreateThread</span>(lpThreadAttributes: ?*SECURITY_ATTRIBUTES, dwStackSize: SIZE_T, lpStartAddress: LPTHREAD_START_ROUTINE, lpParameter: ?LPVOID, dwCreationFlags: DWORD, lpThreadId: ?*DWORD) <span class="tok-kw">callconv</span>(WINAPI) ?HANDLE;</span>
<span class="line" id="L125"></span>
<span class="line" id="L126"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;kernel32&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">DeviceIoControl</span>(</span>
<span class="line" id="L127">    h: HANDLE,</span>
<span class="line" id="L128">    dwIoControlCode: DWORD,</span>
<span class="line" id="L129">    lpInBuffer: ?*<span class="tok-kw">const</span> <span class="tok-type">anyopaque</span>,</span>
<span class="line" id="L130">    nInBufferSize: DWORD,</span>
<span class="line" id="L131">    lpOutBuffer: ?LPVOID,</span>
<span class="line" id="L132">    nOutBufferSize: DWORD,</span>
<span class="line" id="L133">    lpBytesReturned: ?*DWORD,</span>
<span class="line" id="L134">    lpOverlapped: ?*OVERLAPPED,</span>
<span class="line" id="L135">) <span class="tok-kw">callconv</span>(WINAPI) BOOL;</span>
<span class="line" id="L136"></span>
<span class="line" id="L137"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;kernel32&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">DeleteFileW</span>(lpFileName: [*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u16</span>) <span class="tok-kw">callconv</span>(WINAPI) BOOL;</span>
<span class="line" id="L138"></span>
<span class="line" id="L139"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;kernel32&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">DuplicateHandle</span>(hSourceProcessHandle: HANDLE, hSourceHandle: HANDLE, hTargetProcessHandle: HANDLE, lpTargetHandle: *HANDLE, dwDesiredAccess: DWORD, bInheritHandle: BOOL, dwOptions: DWORD) <span class="tok-kw">callconv</span>(WINAPI) BOOL;</span>
<span class="line" id="L140"></span>
<span class="line" id="L141"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;kernel32&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">ExitProcess</span>(exit_code: UINT) <span class="tok-kw">callconv</span>(WINAPI) <span class="tok-type">noreturn</span>;</span>
<span class="line" id="L142"></span>
<span class="line" id="L143"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;kernel32&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">FindFirstFileW</span>(lpFileName: [*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u16</span>, lpFindFileData: *WIN32_FIND_DATAW) <span class="tok-kw">callconv</span>(WINAPI) HANDLE;</span>
<span class="line" id="L144"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;kernel32&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">FindClose</span>(hFindFile: HANDLE) <span class="tok-kw">callconv</span>(WINAPI) BOOL;</span>
<span class="line" id="L145"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;kernel32&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">FindNextFileW</span>(hFindFile: HANDLE, lpFindFileData: *WIN32_FIND_DATAW) <span class="tok-kw">callconv</span>(WINAPI) BOOL;</span>
<span class="line" id="L146"></span>
<span class="line" id="L147"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;kernel32&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">FormatMessageW</span>(dwFlags: DWORD, lpSource: ?LPVOID, dwMessageId: Win32Error, dwLanguageId: DWORD, lpBuffer: [*]<span class="tok-type">u16</span>, nSize: DWORD, Arguments: ?*va_list) <span class="tok-kw">callconv</span>(WINAPI) DWORD;</span>
<span class="line" id="L148"></span>
<span class="line" id="L149"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;kernel32&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">FreeEnvironmentStringsW</span>(penv: [*:<span class="tok-number">0</span>]<span class="tok-type">u16</span>) <span class="tok-kw">callconv</span>(WINAPI) BOOL;</span>
<span class="line" id="L150"></span>
<span class="line" id="L151"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;kernel32&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">GetCommandLineA</span>() <span class="tok-kw">callconv</span>(WINAPI) LPSTR;</span>
<span class="line" id="L152"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;kernel32&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">GetCommandLineW</span>() <span class="tok-kw">callconv</span>(WINAPI) LPWSTR;</span>
<span class="line" id="L153"></span>
<span class="line" id="L154"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;kernel32&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">GetConsoleMode</span>(in_hConsoleHandle: HANDLE, out_lpMode: *DWORD) <span class="tok-kw">callconv</span>(WINAPI) BOOL;</span>
<span class="line" id="L155"></span>
<span class="line" id="L156"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;kernel32&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">GetConsoleOutputCP</span>() <span class="tok-kw">callconv</span>(WINAPI) UINT;</span>
<span class="line" id="L157"></span>
<span class="line" id="L158"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;kernel32&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">GetConsoleScreenBufferInfo</span>(hConsoleOutput: HANDLE, lpConsoleScreenBufferInfo: *CONSOLE_SCREEN_BUFFER_INFO) <span class="tok-kw">callconv</span>(WINAPI) BOOL;</span>
<span class="line" id="L159"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;kernel32&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">FillConsoleOutputCharacterA</span>(hConsoleOutput: HANDLE, cCharacter: CHAR, nLength: DWORD, dwWriteCoord: COORD, lpNumberOfCharsWritten: *DWORD) <span class="tok-kw">callconv</span>(WINAPI) BOOL;</span>
<span class="line" id="L160"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;kernel32&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">FillConsoleOutputCharacterW</span>(hConsoleOutput: HANDLE, cCharacter: WCHAR, nLength: DWORD, dwWriteCoord: COORD, lpNumberOfCharsWritten: *DWORD) <span class="tok-kw">callconv</span>(WINAPI) BOOL;</span>
<span class="line" id="L161"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;kernel32&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">FillConsoleOutputAttribute</span>(hConsoleOutput: HANDLE, wAttribute: WORD, nLength: DWORD, dwWriteCoord: COORD, lpNumberOfAttrsWritten: *DWORD) <span class="tok-kw">callconv</span>(WINAPI) BOOL;</span>
<span class="line" id="L162"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;kernel32&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">SetConsoleCursorPosition</span>(hConsoleOutput: HANDLE, dwCursorPosition: COORD) <span class="tok-kw">callconv</span>(WINAPI) BOOL;</span>
<span class="line" id="L163"></span>
<span class="line" id="L164"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;kernel32&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">GetCurrentDirectoryW</span>(nBufferLength: DWORD, lpBuffer: ?[*]WCHAR) <span class="tok-kw">callconv</span>(WINAPI) DWORD;</span>
<span class="line" id="L165"></span>
<span class="line" id="L166"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;kernel32&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">GetCurrentThread</span>() <span class="tok-kw">callconv</span>(WINAPI) HANDLE;</span>
<span class="line" id="L167"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;kernel32&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">GetCurrentThreadId</span>() <span class="tok-kw">callconv</span>(WINAPI) DWORD;</span>
<span class="line" id="L168"></span>
<span class="line" id="L169"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;kernel32&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">GetCurrentProcessId</span>() <span class="tok-kw">callconv</span>(WINAPI) DWORD;</span>
<span class="line" id="L170"></span>
<span class="line" id="L171"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;kernel32&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">GetCurrentProcess</span>() <span class="tok-kw">callconv</span>(WINAPI) HANDLE;</span>
<span class="line" id="L172"></span>
<span class="line" id="L173"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;kernel32&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">GetEnvironmentStringsW</span>() <span class="tok-kw">callconv</span>(WINAPI) ?[*:<span class="tok-number">0</span>]<span class="tok-type">u16</span>;</span>
<span class="line" id="L174"></span>
<span class="line" id="L175"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;kernel32&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">GetEnvironmentVariableW</span>(lpName: LPWSTR, lpBuffer: [*]<span class="tok-type">u16</span>, nSize: DWORD) <span class="tok-kw">callconv</span>(WINAPI) DWORD;</span>
<span class="line" id="L176"></span>
<span class="line" id="L177"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;kernel32&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">GetExitCodeProcess</span>(hProcess: HANDLE, lpExitCode: *DWORD) <span class="tok-kw">callconv</span>(WINAPI) BOOL;</span>
<span class="line" id="L178"></span>
<span class="line" id="L179"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;kernel32&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">GetFileSizeEx</span>(hFile: HANDLE, lpFileSize: *LARGE_INTEGER) <span class="tok-kw">callconv</span>(WINAPI) BOOL;</span>
<span class="line" id="L180"></span>
<span class="line" id="L181"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;kernel32&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">GetFileAttributesW</span>(lpFileName: [*]<span class="tok-kw">const</span> WCHAR) <span class="tok-kw">callconv</span>(WINAPI) DWORD;</span>
<span class="line" id="L182"></span>
<span class="line" id="L183"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;kernel32&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">GetModuleFileNameW</span>(hModule: ?HMODULE, lpFilename: [*]<span class="tok-type">u16</span>, nSize: DWORD) <span class="tok-kw">callconv</span>(WINAPI) DWORD;</span>
<span class="line" id="L184"></span>
<span class="line" id="L185"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;kernel32&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">GetModuleHandleW</span>(lpModuleName: ?[*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> WCHAR) <span class="tok-kw">callconv</span>(WINAPI) ?HMODULE;</span>
<span class="line" id="L186"></span>
<span class="line" id="L187"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;kernel32&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">GetLastError</span>() <span class="tok-kw">callconv</span>(WINAPI) Win32Error;</span>
<span class="line" id="L188"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;kernel32&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">SetLastError</span>(dwErrCode: Win32Error) <span class="tok-kw">callconv</span>(WINAPI) <span class="tok-type">void</span>;</span>
<span class="line" id="L189"></span>
<span class="line" id="L190"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;kernel32&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">GetFileInformationByHandle</span>(</span>
<span class="line" id="L191">    hFile: HANDLE,</span>
<span class="line" id="L192">    lpFileInformation: *BY_HANDLE_FILE_INFORMATION,</span>
<span class="line" id="L193">) <span class="tok-kw">callconv</span>(WINAPI) BOOL;</span>
<span class="line" id="L194"></span>
<span class="line" id="L195"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;kernel32&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">GetFileInformationByHandleEx</span>(</span>
<span class="line" id="L196">    in_hFile: HANDLE,</span>
<span class="line" id="L197">    in_FileInformationClass: FILE_INFO_BY_HANDLE_CLASS,</span>
<span class="line" id="L198">    out_lpFileInformation: *<span class="tok-type">anyopaque</span>,</span>
<span class="line" id="L199">    in_dwBufferSize: DWORD,</span>
<span class="line" id="L200">) <span class="tok-kw">callconv</span>(WINAPI) BOOL;</span>
<span class="line" id="L201"></span>
<span class="line" id="L202"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;kernel32&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">GetFinalPathNameByHandleW</span>(</span>
<span class="line" id="L203">    hFile: HANDLE,</span>
<span class="line" id="L204">    lpszFilePath: [*]<span class="tok-type">u16</span>,</span>
<span class="line" id="L205">    cchFilePath: DWORD,</span>
<span class="line" id="L206">    dwFlags: DWORD,</span>
<span class="line" id="L207">) <span class="tok-kw">callconv</span>(WINAPI) DWORD;</span>
<span class="line" id="L208"></span>
<span class="line" id="L209"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;kernel32&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">GetFullPathNameW</span>(</span>
<span class="line" id="L210">    lpFileName: [*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u16</span>,</span>
<span class="line" id="L211">    nBufferLength: <span class="tok-type">u32</span>,</span>
<span class="line" id="L212">    lpBuffer: ?[*:<span class="tok-number">0</span>]<span class="tok-type">u16</span>,</span>
<span class="line" id="L213">    lpFilePart: ?*?[*:<span class="tok-number">0</span>]<span class="tok-type">u16</span>,</span>
<span class="line" id="L214">) <span class="tok-kw">callconv</span>(<span class="tok-builtin">@import</span>(<span class="tok-str">&quot;std&quot;</span>).os.windows.WINAPI) <span class="tok-type">u32</span>;</span>
<span class="line" id="L215"></span>
<span class="line" id="L216"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;kernel32&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">GetOverlappedResult</span>(hFile: HANDLE, lpOverlapped: *OVERLAPPED, lpNumberOfBytesTransferred: *DWORD, bWait: BOOL) <span class="tok-kw">callconv</span>(WINAPI) BOOL;</span>
<span class="line" id="L217"></span>
<span class="line" id="L218"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;kernel32&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">GetProcessHeap</span>() <span class="tok-kw">callconv</span>(WINAPI) ?HANDLE;</span>
<span class="line" id="L219"></span>
<span class="line" id="L220"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;kernel32&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">GetProcessTimes</span>(in_hProcess: HANDLE, out_lpCreationTime: *FILETIME, out_lpExitTime: *FILETIME, out_lpKernelTime: *FILETIME, out_lpUserTime: *FILETIME) <span class="tok-kw">callconv</span>(WINAPI) BOOL;</span>
<span class="line" id="L221"></span>
<span class="line" id="L222"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;kernel32&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">GetQueuedCompletionStatus</span>(CompletionPort: HANDLE, lpNumberOfBytesTransferred: *DWORD, lpCompletionKey: *ULONG_PTR, lpOverlapped: *?*OVERLAPPED, dwMilliseconds: DWORD) <span class="tok-kw">callconv</span>(WINAPI) BOOL;</span>
<span class="line" id="L223"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;kernel32&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">GetQueuedCompletionStatusEx</span>(</span>
<span class="line" id="L224">    CompletionPort: HANDLE,</span>
<span class="line" id="L225">    lpCompletionPortEntries: [*]OVERLAPPED_ENTRY,</span>
<span class="line" id="L226">    ulCount: ULONG,</span>
<span class="line" id="L227">    ulNumEntriesRemoved: *ULONG,</span>
<span class="line" id="L228">    dwMilliseconds: DWORD,</span>
<span class="line" id="L229">    fAlertable: BOOL,</span>
<span class="line" id="L230">) <span class="tok-kw">callconv</span>(WINAPI) BOOL;</span>
<span class="line" id="L231"></span>
<span class="line" id="L232"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;kernel32&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">GetSystemInfo</span>(lpSystemInfo: *SYSTEM_INFO) <span class="tok-kw">callconv</span>(WINAPI) <span class="tok-type">void</span>;</span>
<span class="line" id="L233"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;kernel32&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">GetSystemTimeAsFileTime</span>(*FILETIME) <span class="tok-kw">callconv</span>(WINAPI) <span class="tok-type">void</span>;</span>
<span class="line" id="L234"></span>
<span class="line" id="L235"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;kernel32&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">HeapCreate</span>(flOptions: DWORD, dwInitialSize: SIZE_T, dwMaximumSize: SIZE_T) <span class="tok-kw">callconv</span>(WINAPI) ?HANDLE;</span>
<span class="line" id="L236"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;kernel32&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">HeapDestroy</span>(hHeap: HANDLE) <span class="tok-kw">callconv</span>(WINAPI) BOOL;</span>
<span class="line" id="L237"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;kernel32&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">HeapReAlloc</span>(hHeap: HANDLE, dwFlags: DWORD, lpMem: *<span class="tok-type">anyopaque</span>, dwBytes: SIZE_T) <span class="tok-kw">callconv</span>(WINAPI) ?*<span class="tok-type">anyopaque</span>;</span>
<span class="line" id="L238"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;kernel32&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">HeapSize</span>(hHeap: HANDLE, dwFlags: DWORD, lpMem: *<span class="tok-kw">const</span> <span class="tok-type">anyopaque</span>) <span class="tok-kw">callconv</span>(WINAPI) SIZE_T;</span>
<span class="line" id="L239"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;kernel32&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">HeapCompact</span>(hHeap: HANDLE, dwFlags: DWORD) <span class="tok-kw">callconv</span>(WINAPI) SIZE_T;</span>
<span class="line" id="L240"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;kernel32&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">HeapSummary</span>(hHeap: HANDLE, dwFlags: DWORD, lpSummary: LPHEAP_SUMMARY) <span class="tok-kw">callconv</span>(WINAPI) BOOL;</span>
<span class="line" id="L241"></span>
<span class="line" id="L242"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;kernel32&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">GetStdHandle</span>(in_nStdHandle: DWORD) <span class="tok-kw">callconv</span>(WINAPI) ?HANDLE;</span>
<span class="line" id="L243"></span>
<span class="line" id="L244"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;kernel32&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">HeapAlloc</span>(hHeap: HANDLE, dwFlags: DWORD, dwBytes: SIZE_T) <span class="tok-kw">callconv</span>(WINAPI) ?*<span class="tok-type">anyopaque</span>;</span>
<span class="line" id="L245"></span>
<span class="line" id="L246"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;kernel32&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">HeapFree</span>(hHeap: HANDLE, dwFlags: DWORD, lpMem: *<span class="tok-type">anyopaque</span>) <span class="tok-kw">callconv</span>(WINAPI) BOOL;</span>
<span class="line" id="L247"></span>
<span class="line" id="L248"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;kernel32&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">HeapValidate</span>(hHeap: HANDLE, dwFlags: DWORD, lpMem: ?*<span class="tok-kw">const</span> <span class="tok-type">anyopaque</span>) <span class="tok-kw">callconv</span>(WINAPI) BOOL;</span>
<span class="line" id="L249"></span>
<span class="line" id="L250"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;kernel32&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">VirtualAlloc</span>(lpAddress: ?LPVOID, dwSize: SIZE_T, flAllocationType: DWORD, flProtect: DWORD) <span class="tok-kw">callconv</span>(WINAPI) ?LPVOID;</span>
<span class="line" id="L251"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;kernel32&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">VirtualFree</span>(lpAddress: ?LPVOID, dwSize: SIZE_T, dwFreeType: DWORD) <span class="tok-kw">callconv</span>(WINAPI) BOOL;</span>
<span class="line" id="L252"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;kernel32&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">VirtualQuery</span>(lpAddress: ?LPVOID, lpBuffer: PMEMORY_BASIC_INFORMATION, dwLength: SIZE_T) <span class="tok-kw">callconv</span>(WINAPI) SIZE_T;</span>
<span class="line" id="L253"></span>
<span class="line" id="L254"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;kernel32&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">LocalFree</span>(hMem: HLOCAL) <span class="tok-kw">callconv</span>(WINAPI) ?HLOCAL;</span>
<span class="line" id="L255"></span>
<span class="line" id="L256"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;kernel32&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">MoveFileExW</span>(</span>
<span class="line" id="L257">    lpExistingFileName: [*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u16</span>,</span>
<span class="line" id="L258">    lpNewFileName: [*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u16</span>,</span>
<span class="line" id="L259">    dwFlags: DWORD,</span>
<span class="line" id="L260">) <span class="tok-kw">callconv</span>(WINAPI) BOOL;</span>
<span class="line" id="L261"></span>
<span class="line" id="L262"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;kernel32&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">PostQueuedCompletionStatus</span>(CompletionPort: HANDLE, dwNumberOfBytesTransferred: DWORD, dwCompletionKey: ULONG_PTR, lpOverlapped: ?*OVERLAPPED) <span class="tok-kw">callconv</span>(WINAPI) BOOL;</span>
<span class="line" id="L263"></span>
<span class="line" id="L264"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;kernel32&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">QueryPerformanceCounter</span>(lpPerformanceCount: *LARGE_INTEGER) <span class="tok-kw">callconv</span>(WINAPI) BOOL;</span>
<span class="line" id="L265"></span>
<span class="line" id="L266"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;kernel32&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">QueryPerformanceFrequency</span>(lpFrequency: *LARGE_INTEGER) <span class="tok-kw">callconv</span>(WINAPI) BOOL;</span>
<span class="line" id="L267"></span>
<span class="line" id="L268"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;kernel32&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">ReadDirectoryChangesW</span>(</span>
<span class="line" id="L269">    hDirectory: HANDLE,</span>
<span class="line" id="L270">    lpBuffer: [*]<span class="tok-kw">align</span>(<span class="tok-builtin">@alignOf</span>(FILE_NOTIFY_INFORMATION)) <span class="tok-type">u8</span>,</span>
<span class="line" id="L271">    nBufferLength: DWORD,</span>
<span class="line" id="L272">    bWatchSubtree: BOOL,</span>
<span class="line" id="L273">    dwNotifyFilter: DWORD,</span>
<span class="line" id="L274">    lpBytesReturned: ?*DWORD,</span>
<span class="line" id="L275">    lpOverlapped: ?*OVERLAPPED,</span>
<span class="line" id="L276">    lpCompletionRoutine: LPOVERLAPPED_COMPLETION_ROUTINE,</span>
<span class="line" id="L277">) <span class="tok-kw">callconv</span>(WINAPI) BOOL;</span>
<span class="line" id="L278"></span>
<span class="line" id="L279"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;kernel32&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">ReadFile</span>(</span>
<span class="line" id="L280">    in_hFile: HANDLE,</span>
<span class="line" id="L281">    out_lpBuffer: [*]<span class="tok-type">u8</span>,</span>
<span class="line" id="L282">    in_nNumberOfBytesToRead: DWORD,</span>
<span class="line" id="L283">    out_lpNumberOfBytesRead: ?*DWORD,</span>
<span class="line" id="L284">    in_out_lpOverlapped: ?*OVERLAPPED,</span>
<span class="line" id="L285">) <span class="tok-kw">callconv</span>(WINAPI) BOOL;</span>
<span class="line" id="L286"></span>
<span class="line" id="L287"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;kernel32&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">RemoveDirectoryW</span>(lpPathName: [*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u16</span>) <span class="tok-kw">callconv</span>(WINAPI) BOOL;</span>
<span class="line" id="L288"></span>
<span class="line" id="L289"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;kernel32&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">SetConsoleTextAttribute</span>(hConsoleOutput: HANDLE, wAttributes: WORD) <span class="tok-kw">callconv</span>(WINAPI) BOOL;</span>
<span class="line" id="L290"></span>
<span class="line" id="L291"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;kernel32&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">SetConsoleCtrlHandler</span>(</span>
<span class="line" id="L292">    HandlerRoutine: ?HANDLER_ROUTINE,</span>
<span class="line" id="L293">    Add: BOOL,</span>
<span class="line" id="L294">) <span class="tok-kw">callconv</span>(WINAPI) BOOL;</span>
<span class="line" id="L295"></span>
<span class="line" id="L296"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;kernel32&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">SetConsoleOutputCP</span>(wCodePageID: UINT) <span class="tok-kw">callconv</span>(WINAPI) BOOL;</span>
<span class="line" id="L297"></span>
<span class="line" id="L298"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;kernel32&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">SetFileCompletionNotificationModes</span>(</span>
<span class="line" id="L299">    FileHandle: HANDLE,</span>
<span class="line" id="L300">    Flags: UCHAR,</span>
<span class="line" id="L301">) <span class="tok-kw">callconv</span>(WINAPI) BOOL;</span>
<span class="line" id="L302"></span>
<span class="line" id="L303"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;kernel32&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">SetFilePointerEx</span>(</span>
<span class="line" id="L304">    in_fFile: HANDLE,</span>
<span class="line" id="L305">    in_liDistanceToMove: LARGE_INTEGER,</span>
<span class="line" id="L306">    out_opt_ldNewFilePointer: ?*LARGE_INTEGER,</span>
<span class="line" id="L307">    in_dwMoveMethod: DWORD,</span>
<span class="line" id="L308">) <span class="tok-kw">callconv</span>(WINAPI) BOOL;</span>
<span class="line" id="L309"></span>
<span class="line" id="L310"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;kernel32&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">SetFileTime</span>(</span>
<span class="line" id="L311">    hFile: HANDLE,</span>
<span class="line" id="L312">    lpCreationTime: ?*<span class="tok-kw">const</span> FILETIME,</span>
<span class="line" id="L313">    lpLastAccessTime: ?*<span class="tok-kw">const</span> FILETIME,</span>
<span class="line" id="L314">    lpLastWriteTime: ?*<span class="tok-kw">const</span> FILETIME,</span>
<span class="line" id="L315">) <span class="tok-kw">callconv</span>(WINAPI) BOOL;</span>
<span class="line" id="L316"></span>
<span class="line" id="L317"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;kernel32&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">SetHandleInformation</span>(hObject: HANDLE, dwMask: DWORD, dwFlags: DWORD) <span class="tok-kw">callconv</span>(WINAPI) BOOL;</span>
<span class="line" id="L318"></span>
<span class="line" id="L319"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;kernel32&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">Sleep</span>(dwMilliseconds: DWORD) <span class="tok-kw">callconv</span>(WINAPI) <span class="tok-type">void</span>;</span>
<span class="line" id="L320"></span>
<span class="line" id="L321"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;kernel32&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">SwitchToThread</span>() <span class="tok-kw">callconv</span>(WINAPI) BOOL;</span>
<span class="line" id="L322"></span>
<span class="line" id="L323"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;kernel32&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">TerminateProcess</span>(hProcess: HANDLE, uExitCode: UINT) <span class="tok-kw">callconv</span>(WINAPI) BOOL;</span>
<span class="line" id="L324"></span>
<span class="line" id="L325"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;kernel32&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">TlsAlloc</span>() <span class="tok-kw">callconv</span>(WINAPI) DWORD;</span>
<span class="line" id="L326"></span>
<span class="line" id="L327"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;kernel32&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">TlsFree</span>(dwTlsIndex: DWORD) <span class="tok-kw">callconv</span>(WINAPI) BOOL;</span>
<span class="line" id="L328"></span>
<span class="line" id="L329"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;kernel32&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">WaitForSingleObject</span>(hHandle: HANDLE, dwMilliseconds: DWORD) <span class="tok-kw">callconv</span>(WINAPI) DWORD;</span>
<span class="line" id="L330"></span>
<span class="line" id="L331"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;kernel32&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">WaitForSingleObjectEx</span>(hHandle: HANDLE, dwMilliseconds: DWORD, bAlertable: BOOL) <span class="tok-kw">callconv</span>(WINAPI) DWORD;</span>
<span class="line" id="L332"></span>
<span class="line" id="L333"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;kernel32&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">WaitForMultipleObjects</span>(nCount: DWORD, lpHandle: [*]<span class="tok-kw">const</span> HANDLE, bWaitAll: BOOL, dwMilliseconds: DWORD) <span class="tok-kw">callconv</span>(WINAPI) DWORD;</span>
<span class="line" id="L334"></span>
<span class="line" id="L335"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;kernel32&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">WaitForMultipleObjectsEx</span>(</span>
<span class="line" id="L336">    nCount: DWORD,</span>
<span class="line" id="L337">    lpHandle: [*]<span class="tok-kw">const</span> HANDLE,</span>
<span class="line" id="L338">    bWaitAll: BOOL,</span>
<span class="line" id="L339">    dwMilliseconds: DWORD,</span>
<span class="line" id="L340">    bAlertable: BOOL,</span>
<span class="line" id="L341">) <span class="tok-kw">callconv</span>(WINAPI) DWORD;</span>
<span class="line" id="L342"></span>
<span class="line" id="L343"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;kernel32&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">WriteFile</span>(</span>
<span class="line" id="L344">    in_hFile: HANDLE,</span>
<span class="line" id="L345">    in_lpBuffer: [*]<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L346">    in_nNumberOfBytesToWrite: DWORD,</span>
<span class="line" id="L347">    out_lpNumberOfBytesWritten: ?*DWORD,</span>
<span class="line" id="L348">    in_out_lpOverlapped: ?*OVERLAPPED,</span>
<span class="line" id="L349">) <span class="tok-kw">callconv</span>(WINAPI) BOOL;</span>
<span class="line" id="L350"></span>
<span class="line" id="L351"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;kernel32&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">WriteFileEx</span>(hFile: HANDLE, lpBuffer: [*]<span class="tok-kw">const</span> <span class="tok-type">u8</span>, nNumberOfBytesToWrite: DWORD, lpOverlapped: *OVERLAPPED, lpCompletionRoutine: LPOVERLAPPED_COMPLETION_ROUTINE) <span class="tok-kw">callconv</span>(WINAPI) BOOL;</span>
<span class="line" id="L352"></span>
<span class="line" id="L353"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;kernel32&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">LoadLibraryW</span>(lpLibFileName: [*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u16</span>) <span class="tok-kw">callconv</span>(WINAPI) ?HMODULE;</span>
<span class="line" id="L354"></span>
<span class="line" id="L355"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;kernel32&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">GetProcAddress</span>(hModule: HMODULE, lpProcName: [*]<span class="tok-kw">const</span> <span class="tok-type">u8</span>) <span class="tok-kw">callconv</span>(WINAPI) ?FARPROC;</span>
<span class="line" id="L356"></span>
<span class="line" id="L357"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;kernel32&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">FreeLibrary</span>(hModule: HMODULE) <span class="tok-kw">callconv</span>(WINAPI) BOOL;</span>
<span class="line" id="L358"></span>
<span class="line" id="L359"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;kernel32&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">InitializeCriticalSection</span>(lpCriticalSection: *CRITICAL_SECTION) <span class="tok-kw">callconv</span>(WINAPI) <span class="tok-type">void</span>;</span>
<span class="line" id="L360"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;kernel32&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">EnterCriticalSection</span>(lpCriticalSection: *CRITICAL_SECTION) <span class="tok-kw">callconv</span>(WINAPI) <span class="tok-type">void</span>;</span>
<span class="line" id="L361"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;kernel32&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">LeaveCriticalSection</span>(lpCriticalSection: *CRITICAL_SECTION) <span class="tok-kw">callconv</span>(WINAPI) <span class="tok-type">void</span>;</span>
<span class="line" id="L362"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;kernel32&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">DeleteCriticalSection</span>(lpCriticalSection: *CRITICAL_SECTION) <span class="tok-kw">callconv</span>(WINAPI) <span class="tok-type">void</span>;</span>
<span class="line" id="L363"></span>
<span class="line" id="L364"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;kernel32&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">InitOnceExecuteOnce</span>(InitOnce: *INIT_ONCE, InitFn: INIT_ONCE_FN, Parameter: ?*<span class="tok-type">anyopaque</span>, Context: ?*<span class="tok-type">anyopaque</span>) <span class="tok-kw">callconv</span>(WINAPI) BOOL;</span>
<span class="line" id="L365"></span>
<span class="line" id="L366"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;kernel32&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">K32EmptyWorkingSet</span>(hProcess: HANDLE) <span class="tok-kw">callconv</span>(WINAPI) BOOL;</span>
<span class="line" id="L367"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;kernel32&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">K32EnumDeviceDrivers</span>(lpImageBase: [*]LPVOID, cb: DWORD, lpcbNeeded: *DWORD) <span class="tok-kw">callconv</span>(WINAPI) BOOL;</span>
<span class="line" id="L368"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;kernel32&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">K32EnumPageFilesA</span>(pCallBackRoutine: PENUM_PAGE_FILE_CALLBACKA, pContext: LPVOID) <span class="tok-kw">callconv</span>(WINAPI) BOOL;</span>
<span class="line" id="L369"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;kernel32&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">K32EnumPageFilesW</span>(pCallBackRoutine: PENUM_PAGE_FILE_CALLBACKW, pContext: LPVOID) <span class="tok-kw">callconv</span>(WINAPI) BOOL;</span>
<span class="line" id="L370"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;kernel32&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">K32EnumProcessModules</span>(hProcess: HANDLE, lphModule: [*]HMODULE, cb: DWORD, lpcbNeeded: *DWORD) <span class="tok-kw">callconv</span>(WINAPI) BOOL;</span>
<span class="line" id="L371"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;kernel32&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">K32EnumProcessModulesEx</span>(hProcess: HANDLE, lphModule: [*]HMODULE, cb: DWORD, lpcbNeeded: *DWORD, dwFilterFlag: DWORD) <span class="tok-kw">callconv</span>(WINAPI) BOOL;</span>
<span class="line" id="L372"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;kernel32&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">K32EnumProcesses</span>(lpidProcess: [*]DWORD, cb: DWORD, cbNeeded: *DWORD) <span class="tok-kw">callconv</span>(WINAPI) BOOL;</span>
<span class="line" id="L373"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;kernel32&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">K32GetDeviceDriverBaseNameA</span>(ImageBase: LPVOID, lpBaseName: LPSTR, nSize: DWORD) <span class="tok-kw">callconv</span>(WINAPI) DWORD;</span>
<span class="line" id="L374"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;kernel32&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">K32GetDeviceDriverBaseNameW</span>(ImageBase: LPVOID, lpBaseName: LPWSTR, nSize: DWORD) <span class="tok-kw">callconv</span>(WINAPI) DWORD;</span>
<span class="line" id="L375"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;kernel32&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">K32GetDeviceDriverFileNameA</span>(ImageBase: LPVOID, lpFilename: LPSTR, nSize: DWORD) <span class="tok-kw">callconv</span>(WINAPI) DWORD;</span>
<span class="line" id="L376"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;kernel32&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">K32GetDeviceDriverFileNameW</span>(ImageBase: LPVOID, lpFilename: LPWSTR, nSize: DWORD) <span class="tok-kw">callconv</span>(WINAPI) DWORD;</span>
<span class="line" id="L377"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;kernel32&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">K32GetMappedFileNameA</span>(hProcess: HANDLE, lpv: ?LPVOID, lpFilename: LPSTR, nSize: DWORD) <span class="tok-kw">callconv</span>(WINAPI) DWORD;</span>
<span class="line" id="L378"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;kernel32&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">K32GetMappedFileNameW</span>(hProcess: HANDLE, lpv: ?LPVOID, lpFilename: LPWSTR, nSize: DWORD) <span class="tok-kw">callconv</span>(WINAPI) DWORD;</span>
<span class="line" id="L379"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;kernel32&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">K32GetModuleBaseNameA</span>(hProcess: HANDLE, hModule: ?HMODULE, lpBaseName: LPSTR, nSize: DWORD) <span class="tok-kw">callconv</span>(WINAPI) DWORD;</span>
<span class="line" id="L380"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;kernel32&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">K32GetModuleBaseNameW</span>(hProcess: HANDLE, hModule: ?HMODULE, lpBaseName: LPWSTR, nSize: DWORD) <span class="tok-kw">callconv</span>(WINAPI) DWORD;</span>
<span class="line" id="L381"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;kernel32&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">K32GetModuleFileNameExA</span>(hProcess: HANDLE, hModule: ?HMODULE, lpFilename: LPSTR, nSize: DWORD) <span class="tok-kw">callconv</span>(WINAPI) DWORD;</span>
<span class="line" id="L382"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;kernel32&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">K32GetModuleFileNameExW</span>(hProcess: HANDLE, hModule: ?HMODULE, lpFilename: LPWSTR, nSize: DWORD) <span class="tok-kw">callconv</span>(WINAPI) DWORD;</span>
<span class="line" id="L383"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;kernel32&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">K32GetModuleInformation</span>(hProcess: HANDLE, hModule: HMODULE, lpmodinfo: *MODULEINFO, cb: DWORD) <span class="tok-kw">callconv</span>(WINAPI) BOOL;</span>
<span class="line" id="L384"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;kernel32&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">K32GetPerformanceInfo</span>(pPerformanceInformation: *PERFORMANCE_INFORMATION, cb: DWORD) <span class="tok-kw">callconv</span>(WINAPI) BOOL;</span>
<span class="line" id="L385"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;kernel32&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">K32GetProcessImageFileNameA</span>(hProcess: HANDLE, lpImageFileName: LPSTR, nSize: DWORD) <span class="tok-kw">callconv</span>(WINAPI) DWORD;</span>
<span class="line" id="L386"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;kernel32&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">K32GetProcessImageFileNameW</span>(hProcess: HANDLE, lpImageFileName: LPWSTR, nSize: DWORD) <span class="tok-kw">callconv</span>(WINAPI) DWORD;</span>
<span class="line" id="L387"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;kernel32&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">K32GetProcessMemoryInfo</span>(Process: HANDLE, ppsmemCounters: *PROCESS_MEMORY_COUNTERS, cb: DWORD) <span class="tok-kw">callconv</span>(WINAPI) BOOL;</span>
<span class="line" id="L388"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;kernel32&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">K32GetWsChanges</span>(hProcess: HANDLE, lpWatchInfo: *PSAPI_WS_WATCH_INFORMATION, cb: DWORD) <span class="tok-kw">callconv</span>(WINAPI) BOOL;</span>
<span class="line" id="L389"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;kernel32&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">K32GetWsChangesEx</span>(hProcess: HANDLE, lpWatchInfoEx: *PSAPI_WS_WATCH_INFORMATION_EX, cb: DWORD) <span class="tok-kw">callconv</span>(WINAPI) BOOL;</span>
<span class="line" id="L390"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;kernel32&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">K32InitializeProcessForWsWatch</span>(hProcess: HANDLE) <span class="tok-kw">callconv</span>(WINAPI) BOOL;</span>
<span class="line" id="L391"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;kernel32&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">K32QueryWorkingSet</span>(hProcess: HANDLE, pv: PVOID, cb: DWORD) <span class="tok-kw">callconv</span>(WINAPI) BOOL;</span>
<span class="line" id="L392"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;kernel32&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">K32QueryWorkingSetEx</span>(hProcess: HANDLE, pv: PVOID, cb: DWORD) <span class="tok-kw">callconv</span>(WINAPI) BOOL;</span>
<span class="line" id="L393"></span>
<span class="line" id="L394"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;kernel32&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">FlushFileBuffers</span>(hFile: HANDLE) <span class="tok-kw">callconv</span>(WINAPI) BOOL;</span>
<span class="line" id="L395"></span>
<span class="line" id="L396"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;kernel32&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">WakeAllConditionVariable</span>(c: *CONDITION_VARIABLE) <span class="tok-kw">callconv</span>(WINAPI) <span class="tok-type">void</span>;</span>
<span class="line" id="L397"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;kernel32&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">WakeConditionVariable</span>(c: *CONDITION_VARIABLE) <span class="tok-kw">callconv</span>(WINAPI) <span class="tok-type">void</span>;</span>
<span class="line" id="L398"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;kernel32&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">SleepConditionVariableSRW</span>(</span>
<span class="line" id="L399">    c: *CONDITION_VARIABLE,</span>
<span class="line" id="L400">    s: *SRWLOCK,</span>
<span class="line" id="L401">    t: DWORD,</span>
<span class="line" id="L402">    f: ULONG,</span>
<span class="line" id="L403">) <span class="tok-kw">callconv</span>(WINAPI) BOOL;</span>
<span class="line" id="L404"></span>
<span class="line" id="L405"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;kernel32&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">TryAcquireSRWLockExclusive</span>(s: *SRWLOCK) <span class="tok-kw">callconv</span>(WINAPI) BOOLEAN;</span>
<span class="line" id="L406"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;kernel32&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">AcquireSRWLockExclusive</span>(s: *SRWLOCK) <span class="tok-kw">callconv</span>(WINAPI) <span class="tok-type">void</span>;</span>
<span class="line" id="L407"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;kernel32&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">ReleaseSRWLockExclusive</span>(s: *SRWLOCK) <span class="tok-kw">callconv</span>(WINAPI) <span class="tok-type">void</span>;</span>
<span class="line" id="L408"></span>
</code></pre></body>
</html>