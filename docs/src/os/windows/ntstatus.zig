<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">    <title>os/windows/ntstatus.zig - source view</title>
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
<pre><code><span class="line" id="L1"><span class="tok-comment">/// NTSTATUS codes from https://docs.microsoft.com/en-us/openspecs/windows_protocols/ms-erref/596a1078-e883-4972-9bbc-49e60bebca55?</span></span>
<span class="line" id="L2"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> NTSTATUS = <span class="tok-kw">enum</span>(<span class="tok-type">u32</span>) {</span>
<span class="line" id="L3">    <span class="tok-comment">/// The caller specified WaitAny for WaitType and one of the dispatcher</span></span>
<span class="line" id="L4">    <span class="tok-comment">/// objects in the Object array has been set to the signaled state.</span></span>
<span class="line" id="L5">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> WAIT_0: NTSTATUS = .SUCCESS;</span>
<span class="line" id="L6">    <span class="tok-comment">/// The caller attempted to wait for a mutex that has been abandoned.</span></span>
<span class="line" id="L7">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> ABANDONED_WAIT_0: NTSTATUS = .ABANDONED;</span>
<span class="line" id="L8">    <span class="tok-comment">/// The maximum number of boot-time filters has been reached.</span></span>
<span class="line" id="L9">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> FWP_TOO_MANY_BOOTTIME_FILTERS: NTSTATUS = .FWP_TOO_MANY_CALLOUTS;</span>
<span class="line" id="L10"></span>
<span class="line" id="L11">    <span class="tok-comment">/// The operation completed successfully.</span></span>
<span class="line" id="L12">    SUCCESS = <span class="tok-number">0x00000000</span>,</span>
<span class="line" id="L13">    <span class="tok-comment">/// The caller specified WaitAny for WaitType and one of the dispatcher objects in the Object array has been set to the signaled state.</span></span>
<span class="line" id="L14">    WAIT_1 = <span class="tok-number">0x00000001</span>,</span>
<span class="line" id="L15">    <span class="tok-comment">/// The caller specified WaitAny for WaitType and one of the dispatcher objects in the Object array has been set to the signaled state.</span></span>
<span class="line" id="L16">    WAIT_2 = <span class="tok-number">0x00000002</span>,</span>
<span class="line" id="L17">    <span class="tok-comment">/// The caller specified WaitAny for WaitType and one of the dispatcher objects in the Object array has been set to the signaled state.</span></span>
<span class="line" id="L18">    WAIT_3 = <span class="tok-number">0x00000003</span>,</span>
<span class="line" id="L19">    <span class="tok-comment">/// The caller specified WaitAny for WaitType and one of the dispatcher objects in the Object array has been set to the signaled state.</span></span>
<span class="line" id="L20">    WAIT_63 = <span class="tok-number">0x0000003F</span>,</span>
<span class="line" id="L21">    <span class="tok-comment">/// The caller attempted to wait for a mutex that has been abandoned.</span></span>
<span class="line" id="L22">    ABANDONED = <span class="tok-number">0x00000080</span>,</span>
<span class="line" id="L23">    <span class="tok-comment">/// The caller attempted to wait for a mutex that has been abandoned.</span></span>
<span class="line" id="L24">    ABANDONED_WAIT_63 = <span class="tok-number">0x000000BF</span>,</span>
<span class="line" id="L25">    <span class="tok-comment">/// A user-mode APC was delivered before the given Interval expired.</span></span>
<span class="line" id="L26">    USER_APC = <span class="tok-number">0x000000C0</span>,</span>
<span class="line" id="L27">    <span class="tok-comment">/// The delay completed because the thread was alerted.</span></span>
<span class="line" id="L28">    ALERTED = <span class="tok-number">0x00000101</span>,</span>
<span class="line" id="L29">    <span class="tok-comment">/// The given Timeout interval expired.</span></span>
<span class="line" id="L30">    TIMEOUT = <span class="tok-number">0x00000102</span>,</span>
<span class="line" id="L31">    <span class="tok-comment">/// The operation that was requested is pending completion.</span></span>
<span class="line" id="L32">    PENDING = <span class="tok-number">0x00000103</span>,</span>
<span class="line" id="L33">    <span class="tok-comment">/// A reparse should be performed by the Object Manager because the name of the file resulted in a symbolic link.</span></span>
<span class="line" id="L34">    REPARSE = <span class="tok-number">0x00000104</span>,</span>
<span class="line" id="L35">    <span class="tok-comment">/// Returned by enumeration APIs to indicate more information is available to successive calls.</span></span>
<span class="line" id="L36">    MORE_ENTRIES = <span class="tok-number">0x00000105</span>,</span>
<span class="line" id="L37">    <span class="tok-comment">/// Indicates not all privileges or groups that are referenced are assigned to the caller.</span></span>
<span class="line" id="L38">    <span class="tok-comment">/// This allows, for example, all privileges to be disabled without having to know exactly which privileges are assigned.</span></span>
<span class="line" id="L39">    NOT_ALL_ASSIGNED = <span class="tok-number">0x00000106</span>,</span>
<span class="line" id="L40">    <span class="tok-comment">/// Some of the information to be translated has not been translated.</span></span>
<span class="line" id="L41">    SOME_NOT_MAPPED = <span class="tok-number">0x00000107</span>,</span>
<span class="line" id="L42">    <span class="tok-comment">/// An open/create operation completed while an opportunistic lock (oplock) break is underway.</span></span>
<span class="line" id="L43">    OPLOCK_BREAK_IN_PROGRESS = <span class="tok-number">0x00000108</span>,</span>
<span class="line" id="L44">    <span class="tok-comment">/// A new volume has been mounted by a file system.</span></span>
<span class="line" id="L45">    VOLUME_MOUNTED = <span class="tok-number">0x00000109</span>,</span>
<span class="line" id="L46">    <span class="tok-comment">/// This success level status indicates that the transaction state already exists for the registry subtree but that a transaction commit was previously aborted. The commit has now been completed.</span></span>
<span class="line" id="L47">    RXACT_COMMITTED = <span class="tok-number">0x0000010A</span>,</span>
<span class="line" id="L48">    <span class="tok-comment">/// Indicates that a notify change request has been completed due to closing the handle that made the notify change request.</span></span>
<span class="line" id="L49">    NOTIFY_CLEANUP = <span class="tok-number">0x0000010B</span>,</span>
<span class="line" id="L50">    <span class="tok-comment">/// Indicates that a notify change request is being completed and that the information is not being returned in the caller's buffer.</span></span>
<span class="line" id="L51">    <span class="tok-comment">/// The caller now needs to enumerate the files to find the changes.</span></span>
<span class="line" id="L52">    NOTIFY_ENUM_DIR = <span class="tok-number">0x0000010C</span>,</span>
<span class="line" id="L53">    <span class="tok-comment">/// {No Quotas} No system quota limits are specifically set for this account.</span></span>
<span class="line" id="L54">    NO_QUOTAS_FOR_ACCOUNT = <span class="tok-number">0x0000010D</span>,</span>
<span class="line" id="L55">    <span class="tok-comment">/// {Connect Failure on Primary Transport} An attempt was made to connect to the remote server %hs on the primary transport, but the connection failed.</span></span>
<span class="line" id="L56">    <span class="tok-comment">/// The computer WAS able to connect on a secondary transport.</span></span>
<span class="line" id="L57">    PRIMARY_TRANSPORT_CONNECT_FAILED = <span class="tok-number">0x0000010E</span>,</span>
<span class="line" id="L58">    <span class="tok-comment">/// The page fault was a transition fault.</span></span>
<span class="line" id="L59">    PAGE_FAULT_TRANSITION = <span class="tok-number">0x00000110</span>,</span>
<span class="line" id="L60">    <span class="tok-comment">/// The page fault was a demand zero fault.</span></span>
<span class="line" id="L61">    PAGE_FAULT_DEMAND_ZERO = <span class="tok-number">0x00000111</span>,</span>
<span class="line" id="L62">    <span class="tok-comment">/// The page fault was a demand zero fault.</span></span>
<span class="line" id="L63">    PAGE_FAULT_COPY_ON_WRITE = <span class="tok-number">0x00000112</span>,</span>
<span class="line" id="L64">    <span class="tok-comment">/// The page fault was a demand zero fault.</span></span>
<span class="line" id="L65">    PAGE_FAULT_GUARD_PAGE = <span class="tok-number">0x00000113</span>,</span>
<span class="line" id="L66">    <span class="tok-comment">/// The page fault was satisfied by reading from a secondary storage device.</span></span>
<span class="line" id="L67">    PAGE_FAULT_PAGING_FILE = <span class="tok-number">0x00000114</span>,</span>
<span class="line" id="L68">    <span class="tok-comment">/// The cached page was locked during operation.</span></span>
<span class="line" id="L69">    CACHE_PAGE_LOCKED = <span class="tok-number">0x00000115</span>,</span>
<span class="line" id="L70">    <span class="tok-comment">/// The crash dump exists in a paging file.</span></span>
<span class="line" id="L71">    CRASH_DUMP = <span class="tok-number">0x00000116</span>,</span>
<span class="line" id="L72">    <span class="tok-comment">/// The specified buffer contains all zeros.</span></span>
<span class="line" id="L73">    BUFFER_ALL_ZEROS = <span class="tok-number">0x00000117</span>,</span>
<span class="line" id="L74">    <span class="tok-comment">/// A reparse should be performed by the Object Manager because the name of the file resulted in a symbolic link.</span></span>
<span class="line" id="L75">    REPARSE_OBJECT = <span class="tok-number">0x00000118</span>,</span>
<span class="line" id="L76">    <span class="tok-comment">/// The device has succeeded a query-stop and its resource requirements have changed.</span></span>
<span class="line" id="L77">    RESOURCE_REQUIREMENTS_CHANGED = <span class="tok-number">0x00000119</span>,</span>
<span class="line" id="L78">    <span class="tok-comment">/// The translator has translated these resources into the global space and no additional translations should be performed.</span></span>
<span class="line" id="L79">    TRANSLATION_COMPLETE = <span class="tok-number">0x00000120</span>,</span>
<span class="line" id="L80">    <span class="tok-comment">/// The directory service evaluated group memberships locally, because it was unable to contact a global catalog server.</span></span>
<span class="line" id="L81">    DS_MEMBERSHIP_EVALUATED_LOCALLY = <span class="tok-number">0x00000121</span>,</span>
<span class="line" id="L82">    <span class="tok-comment">/// A process being terminated has no threads to terminate.</span></span>
<span class="line" id="L83">    NOTHING_TO_TERMINATE = <span class="tok-number">0x00000122</span>,</span>
<span class="line" id="L84">    <span class="tok-comment">/// The specified process is not part of a job.</span></span>
<span class="line" id="L85">    PROCESS_NOT_IN_JOB = <span class="tok-number">0x00000123</span>,</span>
<span class="line" id="L86">    <span class="tok-comment">/// The specified process is part of a job.</span></span>
<span class="line" id="L87">    PROCESS_IN_JOB = <span class="tok-number">0x00000124</span>,</span>
<span class="line" id="L88">    <span class="tok-comment">/// {Volume Shadow Copy Service} The system is now ready for hibernation.</span></span>
<span class="line" id="L89">    VOLSNAP_HIBERNATE_READY = <span class="tok-number">0x00000125</span>,</span>
<span class="line" id="L90">    <span class="tok-comment">/// A file system or file system filter driver has successfully completed an FsFilter operation.</span></span>
<span class="line" id="L91">    FSFILTER_OP_COMPLETED_SUCCESSFULLY = <span class="tok-number">0x00000126</span>,</span>
<span class="line" id="L92">    <span class="tok-comment">/// The specified interrupt vector was already connected.</span></span>
<span class="line" id="L93">    INTERRUPT_VECTOR_ALREADY_CONNECTED = <span class="tok-number">0x00000127</span>,</span>
<span class="line" id="L94">    <span class="tok-comment">/// The specified interrupt vector is still connected.</span></span>
<span class="line" id="L95">    INTERRUPT_STILL_CONNECTED = <span class="tok-number">0x00000128</span>,</span>
<span class="line" id="L96">    <span class="tok-comment">/// The current process is a cloned process.</span></span>
<span class="line" id="L97">    PROCESS_CLONED = <span class="tok-number">0x00000129</span>,</span>
<span class="line" id="L98">    <span class="tok-comment">/// The file was locked and all users of the file can only read.</span></span>
<span class="line" id="L99">    FILE_LOCKED_WITH_ONLY_READERS = <span class="tok-number">0x0000012A</span>,</span>
<span class="line" id="L100">    <span class="tok-comment">/// The file was locked and at least one user of the file can write.</span></span>
<span class="line" id="L101">    FILE_LOCKED_WITH_WRITERS = <span class="tok-number">0x0000012B</span>,</span>
<span class="line" id="L102">    <span class="tok-comment">/// The specified ResourceManager made no changes or updates to the resource under this transaction.</span></span>
<span class="line" id="L103">    RESOURCEMANAGER_READ_ONLY = <span class="tok-number">0x00000202</span>,</span>
<span class="line" id="L104">    <span class="tok-comment">/// An operation is blocked and waiting for an oplock.</span></span>
<span class="line" id="L105">    WAIT_FOR_OPLOCK = <span class="tok-number">0x00000367</span>,</span>
<span class="line" id="L106">    <span class="tok-comment">/// Debugger handled the exception.</span></span>
<span class="line" id="L107">    DBG_EXCEPTION_HANDLED = <span class="tok-number">0x00010001</span>,</span>
<span class="line" id="L108">    <span class="tok-comment">/// The debugger continued.</span></span>
<span class="line" id="L109">    DBG_CONTINUE = <span class="tok-number">0x00010002</span>,</span>
<span class="line" id="L110">    <span class="tok-comment">/// The IO was completed by a filter.</span></span>
<span class="line" id="L111">    FLT_IO_COMPLETE = <span class="tok-number">0x001C0001</span>,</span>
<span class="line" id="L112">    <span class="tok-comment">/// The file is temporarily unavailable.</span></span>
<span class="line" id="L113">    FILE_NOT_AVAILABLE = <span class="tok-number">0xC0000467</span>,</span>
<span class="line" id="L114">    <span class="tok-comment">/// The share is temporarily unavailable.</span></span>
<span class="line" id="L115">    SHARE_UNAVAILABLE = <span class="tok-number">0xC0000480</span>,</span>
<span class="line" id="L116">    <span class="tok-comment">/// A threadpool worker thread entered a callback at thread affinity %p and exited at affinity %p.</span></span>
<span class="line" id="L117">    <span class="tok-comment">/// This is unexpected, indicating that the callback missed restoring the priority.</span></span>
<span class="line" id="L118">    CALLBACK_RETURNED_THREAD_AFFINITY = <span class="tok-number">0xC0000721</span>,</span>
<span class="line" id="L119">    <span class="tok-comment">/// {Object Exists} An attempt was made to create an object but the object name already exists.</span></span>
<span class="line" id="L120">    OBJECT_NAME_EXISTS = <span class="tok-number">0x40000000</span>,</span>
<span class="line" id="L121">    <span class="tok-comment">/// {Thread Suspended} A thread termination occurred while the thread was suspended. The thread resumed, and termination proceeded.</span></span>
<span class="line" id="L122">    THREAD_WAS_SUSPENDED = <span class="tok-number">0x40000001</span>,</span>
<span class="line" id="L123">    <span class="tok-comment">/// {Working Set Range Error} An attempt was made to set the working set minimum or maximum to values that are outside the allowable range.</span></span>
<span class="line" id="L124">    WORKING_SET_LIMIT_RANGE = <span class="tok-number">0x40000002</span>,</span>
<span class="line" id="L125">    <span class="tok-comment">/// {Image Relocated} An image file could not be mapped at the address that is specified in the image file. Local fixes must be performed on this image.</span></span>
<span class="line" id="L126">    IMAGE_NOT_AT_BASE = <span class="tok-number">0x40000003</span>,</span>
<span class="line" id="L127">    <span class="tok-comment">/// This informational level status indicates that a specified registry subtree transaction state did not yet exist and had to be created.</span></span>
<span class="line" id="L128">    RXACT_STATE_CREATED = <span class="tok-number">0x40000004</span>,</span>
<span class="line" id="L129">    <span class="tok-comment">/// {Segment Load} A virtual DOS machine (VDM) is loading, unloading, or moving an MS-DOS or Win16 program segment image.</span></span>
<span class="line" id="L130">    <span class="tok-comment">/// An exception is raised so that a debugger can load, unload, or track symbols and breakpoints within these 16-bit segments.</span></span>
<span class="line" id="L131">    SEGMENT_NOTIFICATION = <span class="tok-number">0x40000005</span>,</span>
<span class="line" id="L132">    <span class="tok-comment">/// {Local Session Key} A user session key was requested for a local remote procedure call (RPC) connection.</span></span>
<span class="line" id="L133">    <span class="tok-comment">/// The session key that is returned is a constant value and not unique to this connection.</span></span>
<span class="line" id="L134">    LOCAL_USER_SESSION_KEY = <span class="tok-number">0x40000006</span>,</span>
<span class="line" id="L135">    <span class="tok-comment">/// {Invalid Current Directory} The process cannot switch to the startup current directory %hs.</span></span>
<span class="line" id="L136">    <span class="tok-comment">/// Select OK to set the current directory to %hs, or select CANCEL to exit.</span></span>
<span class="line" id="L137">    BAD_CURRENT_DIRECTORY = <span class="tok-number">0x40000007</span>,</span>
<span class="line" id="L138">    <span class="tok-comment">/// {Serial IOCTL Complete} A serial I/O operation was completed by another write to a serial port. (The IOCTL_SERIAL_XOFF_COUNTER reached zero.)</span></span>
<span class="line" id="L139">    SERIAL_MORE_WRITES = <span class="tok-number">0x40000008</span>,</span>
<span class="line" id="L140">    <span class="tok-comment">/// {Registry Recovery} One of the files that contains the system registry data had to be recovered by using a log or alternate copy. The recovery was successful.</span></span>
<span class="line" id="L141">    REGISTRY_RECOVERED = <span class="tok-number">0x40000009</span>,</span>
<span class="line" id="L142">    <span class="tok-comment">/// {Redundant Read} To satisfy a read request, the Windows NT operating system fault-tolerant file system successfully read the requested data from a redundant copy.</span></span>
<span class="line" id="L143">    <span class="tok-comment">/// This was done because the file system encountered a failure on a member of the fault-tolerant volume but was unable to reassign the failing area of the device.</span></span>
<span class="line" id="L144">    FT_READ_RECOVERY_FROM_BACKUP = <span class="tok-number">0x4000000A</span>,</span>
<span class="line" id="L145">    <span class="tok-comment">/// {Redundant Write} To satisfy a write request, the Windows NT fault-tolerant file system successfully wrote a redundant copy of the information.</span></span>
<span class="line" id="L146">    <span class="tok-comment">/// This was done because the file system encountered a failure on a member of the fault-tolerant volume but was unable to reassign the failing area of the device.</span></span>
<span class="line" id="L147">    FT_WRITE_RECOVERY = <span class="tok-number">0x4000000B</span>,</span>
<span class="line" id="L148">    <span class="tok-comment">/// {Serial IOCTL Timeout} A serial I/O operation completed because the time-out period expired.</span></span>
<span class="line" id="L149">    <span class="tok-comment">/// (The IOCTL_SERIAL_XOFF_COUNTER had not reached zero.)</span></span>
<span class="line" id="L150">    SERIAL_COUNTER_TIMEOUT = <span class="tok-number">0x4000000C</span>,</span>
<span class="line" id="L151">    <span class="tok-comment">/// {Password Too Complex} The Windows password is too complex to be converted to a LAN Manager password.</span></span>
<span class="line" id="L152">    <span class="tok-comment">/// The LAN Manager password that returned is a NULL string.</span></span>
<span class="line" id="L153">    NULL_LM_PASSWORD = <span class="tok-number">0x4000000D</span>,</span>
<span class="line" id="L154">    <span class="tok-comment">/// {Machine Type Mismatch} The image file %hs is valid but is for a machine type other than the current machine.</span></span>
<span class="line" id="L155">    <span class="tok-comment">/// Select OK to continue, or CANCEL to fail the DLL load.</span></span>
<span class="line" id="L156">    IMAGE_MACHINE_TYPE_MISMATCH = <span class="tok-number">0x4000000E</span>,</span>
<span class="line" id="L157">    <span class="tok-comment">/// {Partial Data Received} The network transport returned partial data to its client. The remaining data will be sent later.</span></span>
<span class="line" id="L158">    RECEIVE_PARTIAL = <span class="tok-number">0x4000000F</span>,</span>
<span class="line" id="L159">    <span class="tok-comment">/// {Expedited Data Received} The network transport returned data to its client that was marked as expedited by the remote system.</span></span>
<span class="line" id="L160">    RECEIVE_EXPEDITED = <span class="tok-number">0x40000010</span>,</span>
<span class="line" id="L161">    <span class="tok-comment">/// {Partial Expedited Data Received} The network transport returned partial data to its client and this data was marked as expedited by the remote system. The remaining data will be sent later.</span></span>
<span class="line" id="L162">    RECEIVE_PARTIAL_EXPEDITED = <span class="tok-number">0x40000011</span>,</span>
<span class="line" id="L163">    <span class="tok-comment">/// {TDI Event Done} The TDI indication has completed successfully.</span></span>
<span class="line" id="L164">    EVENT_DONE = <span class="tok-number">0x40000012</span>,</span>
<span class="line" id="L165">    <span class="tok-comment">/// {TDI Event Pending} The TDI indication has entered the pending state.</span></span>
<span class="line" id="L166">    EVENT_PENDING = <span class="tok-number">0x40000013</span>,</span>
<span class="line" id="L167">    <span class="tok-comment">/// Checking file system on %wZ.</span></span>
<span class="line" id="L168">    CHECKING_FILE_SYSTEM = <span class="tok-number">0x40000014</span>,</span>
<span class="line" id="L169">    <span class="tok-comment">/// {Fatal Application Exit} %hs</span></span>
<span class="line" id="L170">    FATAL_APP_EXIT = <span class="tok-number">0x40000015</span>,</span>
<span class="line" id="L171">    <span class="tok-comment">/// The specified registry key is referenced by a predefined handle.</span></span>
<span class="line" id="L172">    PREDEFINED_HANDLE = <span class="tok-number">0x40000016</span>,</span>
<span class="line" id="L173">    <span class="tok-comment">/// {Page Unlocked} The page protection of a locked page was changed to 'No Access' and the page was unlocked from memory and from the process.</span></span>
<span class="line" id="L174">    WAS_UNLOCKED = <span class="tok-number">0x40000017</span>,</span>
<span class="line" id="L175">    <span class="tok-comment">/// %hs</span></span>
<span class="line" id="L176">    SERVICE_NOTIFICATION = <span class="tok-number">0x40000018</span>,</span>
<span class="line" id="L177">    <span class="tok-comment">/// {Page Locked} One of the pages to lock was already locked.</span></span>
<span class="line" id="L178">    WAS_LOCKED = <span class="tok-number">0x40000019</span>,</span>
<span class="line" id="L179">    <span class="tok-comment">/// Application popup: %1 : %2</span></span>
<span class="line" id="L180">    LOG_HARD_ERROR = <span class="tok-number">0x4000001A</span>,</span>
<span class="line" id="L181">    <span class="tok-comment">/// A Win32 process already exists.</span></span>
<span class="line" id="L182">    ALREADY_WIN32 = <span class="tok-number">0x4000001B</span>,</span>
<span class="line" id="L183">    <span class="tok-comment">/// An exception status code that is used by the Win32 x86 emulation subsystem.</span></span>
<span class="line" id="L184">    WX86_UNSIMULATE = <span class="tok-number">0x4000001C</span>,</span>
<span class="line" id="L185">    <span class="tok-comment">/// An exception status code that is used by the Win32 x86 emulation subsystem.</span></span>
<span class="line" id="L186">    WX86_CONTINUE = <span class="tok-number">0x4000001D</span>,</span>
<span class="line" id="L187">    <span class="tok-comment">/// An exception status code that is used by the Win32 x86 emulation subsystem.</span></span>
<span class="line" id="L188">    WX86_SINGLE_STEP = <span class="tok-number">0x4000001E</span>,</span>
<span class="line" id="L189">    <span class="tok-comment">/// An exception status code that is used by the Win32 x86 emulation subsystem.</span></span>
<span class="line" id="L190">    WX86_BREAKPOINT = <span class="tok-number">0x4000001F</span>,</span>
<span class="line" id="L191">    <span class="tok-comment">/// An exception status code that is used by the Win32 x86 emulation subsystem.</span></span>
<span class="line" id="L192">    WX86_EXCEPTION_CONTINUE = <span class="tok-number">0x40000020</span>,</span>
<span class="line" id="L193">    <span class="tok-comment">/// An exception status code that is used by the Win32 x86 emulation subsystem.</span></span>
<span class="line" id="L194">    WX86_EXCEPTION_LASTCHANCE = <span class="tok-number">0x40000021</span>,</span>
<span class="line" id="L195">    <span class="tok-comment">/// An exception status code that is used by the Win32 x86 emulation subsystem.</span></span>
<span class="line" id="L196">    WX86_EXCEPTION_CHAIN = <span class="tok-number">0x40000022</span>,</span>
<span class="line" id="L197">    <span class="tok-comment">/// {Machine Type Mismatch} The image file %hs is valid but is for a machine type other than the current machine.</span></span>
<span class="line" id="L198">    IMAGE_MACHINE_TYPE_MISMATCH_EXE = <span class="tok-number">0x40000023</span>,</span>
<span class="line" id="L199">    <span class="tok-comment">/// A yield execution was performed and no thread was available to run.</span></span>
<span class="line" id="L200">    NO_YIELD_PERFORMED = <span class="tok-number">0x40000024</span>,</span>
<span class="line" id="L201">    <span class="tok-comment">/// The resume flag to a timer API was ignored.</span></span>
<span class="line" id="L202">    TIMER_RESUME_IGNORED = <span class="tok-number">0x40000025</span>,</span>
<span class="line" id="L203">    <span class="tok-comment">/// The arbiter has deferred arbitration of these resources to its parent.</span></span>
<span class="line" id="L204">    ARBITRATION_UNHANDLED = <span class="tok-number">0x40000026</span>,</span>
<span class="line" id="L205">    <span class="tok-comment">/// The device has detected a CardBus card in its slot.</span></span>
<span class="line" id="L206">    CARDBUS_NOT_SUPPORTED = <span class="tok-number">0x40000027</span>,</span>
<span class="line" id="L207">    <span class="tok-comment">/// An exception status code that is used by the Win32 x86 emulation subsystem.</span></span>
<span class="line" id="L208">    WX86_CREATEWX86TIB = <span class="tok-number">0x40000028</span>,</span>
<span class="line" id="L209">    <span class="tok-comment">/// The CPUs in this multiprocessor system are not all the same revision level.</span></span>
<span class="line" id="L210">    <span class="tok-comment">/// To use all processors, the operating system restricts itself to the features of the least capable processor in the system.</span></span>
<span class="line" id="L211">    <span class="tok-comment">/// If problems occur with this system, contact the CPU manufacturer to see if this mix of processors is supported.</span></span>
<span class="line" id="L212">    MP_PROCESSOR_MISMATCH = <span class="tok-number">0x40000029</span>,</span>
<span class="line" id="L213">    <span class="tok-comment">/// The system was put into hibernation.</span></span>
<span class="line" id="L214">    HIBERNATED = <span class="tok-number">0x4000002A</span>,</span>
<span class="line" id="L215">    <span class="tok-comment">/// The system was resumed from hibernation.</span></span>
<span class="line" id="L216">    RESUME_HIBERNATION = <span class="tok-number">0x4000002B</span>,</span>
<span class="line" id="L217">    <span class="tok-comment">/// Windows has detected that the system firmware (BIOS) was updated [previous firmware date = %2, current firmware date %3].</span></span>
<span class="line" id="L218">    FIRMWARE_UPDATED = <span class="tok-number">0x4000002C</span>,</span>
<span class="line" id="L219">    <span class="tok-comment">/// A device driver is leaking locked I/O pages and is causing system degradation.</span></span>
<span class="line" id="L220">    <span class="tok-comment">/// The system has automatically enabled the tracking code to try and catch the culprit.</span></span>
<span class="line" id="L221">    DRIVERS_LEAKING_LOCKED_PAGES = <span class="tok-number">0x4000002D</span>,</span>
<span class="line" id="L222">    <span class="tok-comment">/// The ALPC message being canceled has already been retrieved from the queue on the other side.</span></span>
<span class="line" id="L223">    MESSAGE_RETRIEVED = <span class="tok-number">0x4000002E</span>,</span>
<span class="line" id="L224">    <span class="tok-comment">/// The system power state is transitioning from %2 to %3.</span></span>
<span class="line" id="L225">    SYSTEM_POWERSTATE_TRANSITION = <span class="tok-number">0x4000002F</span>,</span>
<span class="line" id="L226">    <span class="tok-comment">/// The receive operation was successful.</span></span>
<span class="line" id="L227">    <span class="tok-comment">/// Check the ALPC completion list for the received message.</span></span>
<span class="line" id="L228">    ALPC_CHECK_COMPLETION_LIST = <span class="tok-number">0x40000030</span>,</span>
<span class="line" id="L229">    <span class="tok-comment">/// The system power state is transitioning from %2 to %3 but could enter %4.</span></span>
<span class="line" id="L230">    SYSTEM_POWERSTATE_COMPLEX_TRANSITION = <span class="tok-number">0x40000031</span>,</span>
<span class="line" id="L231">    <span class="tok-comment">/// Access to %1 is monitored by policy rule %2.</span></span>
<span class="line" id="L232">    ACCESS_AUDIT_BY_POLICY = <span class="tok-number">0x40000032</span>,</span>
<span class="line" id="L233">    <span class="tok-comment">/// A valid hibernation file has been invalidated and should be abandoned.</span></span>
<span class="line" id="L234">    ABANDON_HIBERFILE = <span class="tok-number">0x40000033</span>,</span>
<span class="line" id="L235">    <span class="tok-comment">/// Business rule scripts are disabled for the calling application.</span></span>
<span class="line" id="L236">    BIZRULES_NOT_ENABLED = <span class="tok-number">0x40000034</span>,</span>
<span class="line" id="L237">    <span class="tok-comment">/// The system has awoken.</span></span>
<span class="line" id="L238">    WAKE_SYSTEM = <span class="tok-number">0x40000294</span>,</span>
<span class="line" id="L239">    <span class="tok-comment">/// The directory service is shutting down.</span></span>
<span class="line" id="L240">    DS_SHUTTING_DOWN = <span class="tok-number">0x40000370</span>,</span>
<span class="line" id="L241">    <span class="tok-comment">/// Debugger will reply later.</span></span>
<span class="line" id="L242">    DBG_REPLY_LATER = <span class="tok-number">0x40010001</span>,</span>
<span class="line" id="L243">    <span class="tok-comment">/// Debugger cannot provide a handle.</span></span>
<span class="line" id="L244">    DBG_UNABLE_TO_PROVIDE_HANDLE = <span class="tok-number">0x40010002</span>,</span>
<span class="line" id="L245">    <span class="tok-comment">/// Debugger terminated the thread.</span></span>
<span class="line" id="L246">    DBG_TERMINATE_THREAD = <span class="tok-number">0x40010003</span>,</span>
<span class="line" id="L247">    <span class="tok-comment">/// Debugger terminated the process.</span></span>
<span class="line" id="L248">    DBG_TERMINATE_PROCESS = <span class="tok-number">0x40010004</span>,</span>
<span class="line" id="L249">    <span class="tok-comment">/// Debugger obtained control of C.</span></span>
<span class="line" id="L250">    DBG_CONTROL_C = <span class="tok-number">0x40010005</span>,</span>
<span class="line" id="L251">    <span class="tok-comment">/// Debugger printed an exception on control C.</span></span>
<span class="line" id="L252">    DBG_PRINTEXCEPTION_C = <span class="tok-number">0x40010006</span>,</span>
<span class="line" id="L253">    <span class="tok-comment">/// Debugger received a RIP exception.</span></span>
<span class="line" id="L254">    DBG_RIPEXCEPTION = <span class="tok-number">0x40010007</span>,</span>
<span class="line" id="L255">    <span class="tok-comment">/// Debugger received a control break.</span></span>
<span class="line" id="L256">    DBG_CONTROL_BREAK = <span class="tok-number">0x40010008</span>,</span>
<span class="line" id="L257">    <span class="tok-comment">/// Debugger command communication exception.</span></span>
<span class="line" id="L258">    DBG_COMMAND_EXCEPTION = <span class="tok-number">0x40010009</span>,</span>
<span class="line" id="L259">    <span class="tok-comment">/// A UUID that is valid only on this computer has been allocated.</span></span>
<span class="line" id="L260">    RPC_NT_UUID_LOCAL_ONLY = <span class="tok-number">0x40020056</span>,</span>
<span class="line" id="L261">    <span class="tok-comment">/// Some data remains to be sent in the request buffer.</span></span>
<span class="line" id="L262">    RPC_NT_SEND_INCOMPLETE = <span class="tok-number">0x400200AF</span>,</span>
<span class="line" id="L263">    <span class="tok-comment">/// The Client Drive Mapping Service has connected on Terminal Connection.</span></span>
<span class="line" id="L264">    CTX_CDM_CONNECT = <span class="tok-number">0x400A0004</span>,</span>
<span class="line" id="L265">    <span class="tok-comment">/// The Client Drive Mapping Service has disconnected on Terminal Connection.</span></span>
<span class="line" id="L266">    CTX_CDM_DISCONNECT = <span class="tok-number">0x400A0005</span>,</span>
<span class="line" id="L267">    <span class="tok-comment">/// A kernel mode component is releasing a reference on an activation context.</span></span>
<span class="line" id="L268">    SXS_RELEASE_ACTIVATION_CONTEXT = <span class="tok-number">0x4015000D</span>,</span>
<span class="line" id="L269">    <span class="tok-comment">/// The transactional resource manager is already consistent. Recovery is not needed.</span></span>
<span class="line" id="L270">    RECOVERY_NOT_NEEDED = <span class="tok-number">0x40190034</span>,</span>
<span class="line" id="L271">    <span class="tok-comment">/// The transactional resource manager has already been started.</span></span>
<span class="line" id="L272">    RM_ALREADY_STARTED = <span class="tok-number">0x40190035</span>,</span>
<span class="line" id="L273">    <span class="tok-comment">/// The log service encountered a log stream with no restart area.</span></span>
<span class="line" id="L274">    LOG_NO_RESTART = <span class="tok-number">0x401A000C</span>,</span>
<span class="line" id="L275">    <span class="tok-comment">/// {Display Driver Recovered From Failure} The %hs display driver has detected a failure and recovered from it. Some graphical operations might have failed.</span></span>
<span class="line" id="L276">    <span class="tok-comment">/// The next time you restart the machine, a dialog box appears, giving you an opportunity to upload data about this failure to Microsoft.</span></span>
<span class="line" id="L277">    VIDEO_DRIVER_DEBUG_REPORT_REQUEST = <span class="tok-number">0x401B00EC</span>,</span>
<span class="line" id="L278">    <span class="tok-comment">/// The specified buffer is not big enough to contain the entire requested dataset.</span></span>
<span class="line" id="L279">    <span class="tok-comment">/// Partial data is populated up to the size of the buffer.</span></span>
<span class="line" id="L280">    <span class="tok-comment">/// The caller needs to provide a buffer of the size as specified in the partially populated buffer's content (interface specific).</span></span>
<span class="line" id="L281">    GRAPHICS_PARTIAL_DATA_POPULATED = <span class="tok-number">0x401E000A</span>,</span>
<span class="line" id="L282">    <span class="tok-comment">/// The kernel driver detected a version mismatch between it and the user mode driver.</span></span>
<span class="line" id="L283">    GRAPHICS_DRIVER_MISMATCH = <span class="tok-number">0x401E0117</span>,</span>
<span class="line" id="L284">    <span class="tok-comment">/// No mode is pinned on the specified VidPN source/target.</span></span>
<span class="line" id="L285">    GRAPHICS_MODE_NOT_PINNED = <span class="tok-number">0x401E0307</span>,</span>
<span class="line" id="L286">    <span class="tok-comment">/// The specified mode set does not specify a preference for one of its modes.</span></span>
<span class="line" id="L287">    GRAPHICS_NO_PREFERRED_MODE = <span class="tok-number">0x401E031E</span>,</span>
<span class="line" id="L288">    <span class="tok-comment">/// The specified dataset (for example, mode set, frequency range set, descriptor set, or topology) is empty.</span></span>
<span class="line" id="L289">    GRAPHICS_DATASET_IS_EMPTY = <span class="tok-number">0x401E034B</span>,</span>
<span class="line" id="L290">    <span class="tok-comment">/// The specified dataset (for example, mode set, frequency range set, descriptor set, or topology) does not contain any more elements.</span></span>
<span class="line" id="L291">    GRAPHICS_NO_MORE_ELEMENTS_IN_DATASET = <span class="tok-number">0x401E034C</span>,</span>
<span class="line" id="L292">    <span class="tok-comment">/// The specified content transformation is not pinned on the specified VidPN present path.</span></span>
<span class="line" id="L293">    GRAPHICS_PATH_CONTENT_GEOMETRY_TRANSFORMATION_NOT_PINNED = <span class="tok-number">0x401E0351</span>,</span>
<span class="line" id="L294">    <span class="tok-comment">/// The child device presence was not reliably detected.</span></span>
<span class="line" id="L295">    GRAPHICS_UNKNOWN_CHILD_STATUS = <span class="tok-number">0x401E042F</span>,</span>
<span class="line" id="L296">    <span class="tok-comment">/// Starting the lead adapter in a linked configuration has been temporarily deferred.</span></span>
<span class="line" id="L297">    GRAPHICS_LEADLINK_START_DEFERRED = <span class="tok-number">0x401E0437</span>,</span>
<span class="line" id="L298">    <span class="tok-comment">/// The display adapter is being polled for children too frequently at the same polling level.</span></span>
<span class="line" id="L299">    GRAPHICS_POLLING_TOO_FREQUENTLY = <span class="tok-number">0x401E0439</span>,</span>
<span class="line" id="L300">    <span class="tok-comment">/// Starting the adapter has been temporarily deferred.</span></span>
<span class="line" id="L301">    GRAPHICS_START_DEFERRED = <span class="tok-number">0x401E043A</span>,</span>
<span class="line" id="L302">    <span class="tok-comment">/// The request will be completed later by an NDIS status indication.</span></span>
<span class="line" id="L303">    NDIS_INDICATION_REQUIRED = <span class="tok-number">0x40230001</span>,</span>
<span class="line" id="L304">    <span class="tok-comment">/// {EXCEPTION} Guard Page Exception A page of memory that marks the end of a data structure, such as a stack or an array, has been accessed.</span></span>
<span class="line" id="L305">    GUARD_PAGE_VIOLATION = <span class="tok-number">0x80000001</span>,</span>
<span class="line" id="L306">    <span class="tok-comment">/// {EXCEPTION} Alignment Fault A data type misalignment was detected in a load or store instruction.</span></span>
<span class="line" id="L307">    DATATYPE_MISALIGNMENT = <span class="tok-number">0x80000002</span>,</span>
<span class="line" id="L308">    <span class="tok-comment">/// {EXCEPTION} Breakpoint A breakpoint has been reached.</span></span>
<span class="line" id="L309">    BREAKPOINT = <span class="tok-number">0x80000003</span>,</span>
<span class="line" id="L310">    <span class="tok-comment">/// {EXCEPTION} Single Step A single step or trace operation has just been completed.</span></span>
<span class="line" id="L311">    SINGLE_STEP = <span class="tok-number">0x80000004</span>,</span>
<span class="line" id="L312">    <span class="tok-comment">/// {Buffer Overflow} The data was too large to fit into the specified buffer.</span></span>
<span class="line" id="L313">    BUFFER_OVERFLOW = <span class="tok-number">0x80000005</span>,</span>
<span class="line" id="L314">    <span class="tok-comment">/// {No More Files} No more files were found which match the file specification.</span></span>
<span class="line" id="L315">    NO_MORE_FILES = <span class="tok-number">0x80000006</span>,</span>
<span class="line" id="L316">    <span class="tok-comment">/// {Kernel Debugger Awakened} The system debugger was awakened by an interrupt.</span></span>
<span class="line" id="L317">    WAKE_SYSTEM_DEBUGGER = <span class="tok-number">0x80000007</span>,</span>
<span class="line" id="L318">    <span class="tok-comment">/// {Handles Closed} Handles to objects have been automatically closed because of the requested operation.</span></span>
<span class="line" id="L319">    HANDLES_CLOSED = <span class="tok-number">0x8000000A</span>,</span>
<span class="line" id="L320">    <span class="tok-comment">/// {Non-Inheritable ACL} An access control list (ACL) contains no components that can be inherited.</span></span>
<span class="line" id="L321">    NO_INHERITANCE = <span class="tok-number">0x8000000B</span>,</span>
<span class="line" id="L322">    <span class="tok-comment">/// {GUID Substitution} During the translation of a globally unique identifier (GUID) to a Windows security ID (SID), no administratively defined GUID prefix was found.</span></span>
<span class="line" id="L323">    <span class="tok-comment">/// A substitute prefix was used, which will not compromise system security.</span></span>
<span class="line" id="L324">    <span class="tok-comment">/// However, this might provide a more restrictive access than intended.</span></span>
<span class="line" id="L325">    GUID_SUBSTITUTION_MADE = <span class="tok-number">0x8000000C</span>,</span>
<span class="line" id="L326">    <span class="tok-comment">/// Because of protection conflicts, not all the requested bytes could be copied.</span></span>
<span class="line" id="L327">    PARTIAL_COPY = <span class="tok-number">0x8000000D</span>,</span>
<span class="line" id="L328">    <span class="tok-comment">/// {Out of Paper} The printer is out of paper.</span></span>
<span class="line" id="L329">    DEVICE_PAPER_EMPTY = <span class="tok-number">0x8000000E</span>,</span>
<span class="line" id="L330">    <span class="tok-comment">/// {Device Power Is Off} The printer power has been turned off.</span></span>
<span class="line" id="L331">    DEVICE_POWERED_OFF = <span class="tok-number">0x8000000F</span>,</span>
<span class="line" id="L332">    <span class="tok-comment">/// {Device Offline} The printer has been taken offline.</span></span>
<span class="line" id="L333">    DEVICE_OFF_LINE = <span class="tok-number">0x80000010</span>,</span>
<span class="line" id="L334">    <span class="tok-comment">/// {Device Busy} The device is currently busy.</span></span>
<span class="line" id="L335">    DEVICE_BUSY = <span class="tok-number">0x80000011</span>,</span>
<span class="line" id="L336">    <span class="tok-comment">/// {No More EAs} No more extended attributes (EAs) were found for the file.</span></span>
<span class="line" id="L337">    NO_MORE_EAS = <span class="tok-number">0x80000012</span>,</span>
<span class="line" id="L338">    <span class="tok-comment">/// {Illegal EA} The specified extended attribute (EA) name contains at least one illegal character.</span></span>
<span class="line" id="L339">    INVALID_EA_NAME = <span class="tok-number">0x80000013</span>,</span>
<span class="line" id="L340">    <span class="tok-comment">/// {Inconsistent EA List} The extended attribute (EA) list is inconsistent.</span></span>
<span class="line" id="L341">    EA_LIST_INCONSISTENT = <span class="tok-number">0x80000014</span>,</span>
<span class="line" id="L342">    <span class="tok-comment">/// {Invalid EA Flag} An invalid extended attribute (EA) flag was set.</span></span>
<span class="line" id="L343">    INVALID_EA_FLAG = <span class="tok-number">0x80000015</span>,</span>
<span class="line" id="L344">    <span class="tok-comment">/// {Verifying Disk} The media has changed and a verify operation is in progress; therefore, no reads or writes can be performed to the device, except those that are used in the verify operation.</span></span>
<span class="line" id="L345">    VERIFY_REQUIRED = <span class="tok-number">0x80000016</span>,</span>
<span class="line" id="L346">    <span class="tok-comment">/// {Too Much Information} The specified access control list (ACL) contained more information than was expected.</span></span>
<span class="line" id="L347">    EXTRANEOUS_INFORMATION = <span class="tok-number">0x80000017</span>,</span>
<span class="line" id="L348">    <span class="tok-comment">/// This warning level status indicates that the transaction state already exists for the registry subtree, but that a transaction commit was previously aborted.</span></span>
<span class="line" id="L349">    <span class="tok-comment">/// The commit has NOT been completed but has not been rolled back either; therefore, it can still be committed, if needed.</span></span>
<span class="line" id="L350">    RXACT_COMMIT_NECESSARY = <span class="tok-number">0x80000018</span>,</span>
<span class="line" id="L351">    <span class="tok-comment">/// {No More Entries} No more entries are available from an enumeration operation.</span></span>
<span class="line" id="L352">    NO_MORE_ENTRIES = <span class="tok-number">0x8000001A</span>,</span>
<span class="line" id="L353">    <span class="tok-comment">/// {Filemark Found} A filemark was detected.</span></span>
<span class="line" id="L354">    FILEMARK_DETECTED = <span class="tok-number">0x8000001B</span>,</span>
<span class="line" id="L355">    <span class="tok-comment">/// {Media Changed} The media has changed.</span></span>
<span class="line" id="L356">    MEDIA_CHANGED = <span class="tok-number">0x8000001C</span>,</span>
<span class="line" id="L357">    <span class="tok-comment">/// {I/O Bus Reset} An I/O bus reset was detected.</span></span>
<span class="line" id="L358">    BUS_RESET = <span class="tok-number">0x8000001D</span>,</span>
<span class="line" id="L359">    <span class="tok-comment">/// {End of Media} The end of the media was encountered.</span></span>
<span class="line" id="L360">    END_OF_MEDIA = <span class="tok-number">0x8000001E</span>,</span>
<span class="line" id="L361">    <span class="tok-comment">/// The beginning of a tape or partition has been detected.</span></span>
<span class="line" id="L362">    BEGINNING_OF_MEDIA = <span class="tok-number">0x8000001F</span>,</span>
<span class="line" id="L363">    <span class="tok-comment">/// {Media Changed} The media might have changed.</span></span>
<span class="line" id="L364">    MEDIA_CHECK = <span class="tok-number">0x80000020</span>,</span>
<span class="line" id="L365">    <span class="tok-comment">/// A tape access reached a set mark.</span></span>
<span class="line" id="L366">    SETMARK_DETECTED = <span class="tok-number">0x80000021</span>,</span>
<span class="line" id="L367">    <span class="tok-comment">/// During a tape access, the end of the data written is reached.</span></span>
<span class="line" id="L368">    NO_DATA_DETECTED = <span class="tok-number">0x80000022</span>,</span>
<span class="line" id="L369">    <span class="tok-comment">/// The redirector is in use and cannot be unloaded.</span></span>
<span class="line" id="L370">    REDIRECTOR_HAS_OPEN_HANDLES = <span class="tok-number">0x80000023</span>,</span>
<span class="line" id="L371">    <span class="tok-comment">/// The server is in use and cannot be unloaded.</span></span>
<span class="line" id="L372">    SERVER_HAS_OPEN_HANDLES = <span class="tok-number">0x80000024</span>,</span>
<span class="line" id="L373">    <span class="tok-comment">/// The specified connection has already been disconnected.</span></span>
<span class="line" id="L374">    ALREADY_DISCONNECTED = <span class="tok-number">0x80000025</span>,</span>
<span class="line" id="L375">    <span class="tok-comment">/// A long jump has been executed.</span></span>
<span class="line" id="L376">    LONGJUMP = <span class="tok-number">0x80000026</span>,</span>
<span class="line" id="L377">    <span class="tok-comment">/// A cleaner cartridge is present in the tape library.</span></span>
<span class="line" id="L378">    CLEANER_CARTRIDGE_INSTALLED = <span class="tok-number">0x80000027</span>,</span>
<span class="line" id="L379">    <span class="tok-comment">/// The Plug and Play query operation was not successful.</span></span>
<span class="line" id="L380">    PLUGPLAY_QUERY_VETOED = <span class="tok-number">0x80000028</span>,</span>
<span class="line" id="L381">    <span class="tok-comment">/// A frame consolidation has been executed.</span></span>
<span class="line" id="L382">    UNWIND_CONSOLIDATE = <span class="tok-number">0x80000029</span>,</span>
<span class="line" id="L383">    <span class="tok-comment">/// {Registry Hive Recovered} The registry hive (file): %hs was corrupted and it has been recovered. Some data might have been lost.</span></span>
<span class="line" id="L384">    REGISTRY_HIVE_RECOVERED = <span class="tok-number">0x8000002A</span>,</span>
<span class="line" id="L385">    <span class="tok-comment">/// The application is attempting to run executable code from the module %hs. This might be insecure.</span></span>
<span class="line" id="L386">    <span class="tok-comment">/// An alternative, %hs, is available. Should the application use the secure module %hs?</span></span>
<span class="line" id="L387">    DLL_MIGHT_BE_INSECURE = <span class="tok-number">0x8000002B</span>,</span>
<span class="line" id="L388">    <span class="tok-comment">/// The application is loading executable code from the module %hs.</span></span>
<span class="line" id="L389">    <span class="tok-comment">/// This is secure but might be incompatible with previous releases of the operating system.</span></span>
<span class="line" id="L390">    <span class="tok-comment">/// An alternative, %hs, is available. Should the application use the secure module %hs?</span></span>
<span class="line" id="L391">    DLL_MIGHT_BE_INCOMPATIBLE = <span class="tok-number">0x8000002C</span>,</span>
<span class="line" id="L392">    <span class="tok-comment">/// The create operation stopped after reaching a symbolic link.</span></span>
<span class="line" id="L393">    STOPPED_ON_SYMLINK = <span class="tok-number">0x8000002D</span>,</span>
<span class="line" id="L394">    <span class="tok-comment">/// The device has indicated that cleaning is necessary.</span></span>
<span class="line" id="L395">    DEVICE_REQUIRES_CLEANING = <span class="tok-number">0x80000288</span>,</span>
<span class="line" id="L396">    <span class="tok-comment">/// The device has indicated that its door is open. Further operations require it closed and secured.</span></span>
<span class="line" id="L397">    DEVICE_DOOR_OPEN = <span class="tok-number">0x80000289</span>,</span>
<span class="line" id="L398">    <span class="tok-comment">/// Windows discovered a corruption in the file %hs. This file has now been repaired.</span></span>
<span class="line" id="L399">    <span class="tok-comment">/// Check if any data in the file was lost because of the corruption.</span></span>
<span class="line" id="L400">    DATA_LOST_REPAIR = <span class="tok-number">0x80000803</span>,</span>
<span class="line" id="L401">    <span class="tok-comment">/// Debugger did not handle the exception.</span></span>
<span class="line" id="L402">    DBG_EXCEPTION_NOT_HANDLED = <span class="tok-number">0x80010001</span>,</span>
<span class="line" id="L403">    <span class="tok-comment">/// The cluster node is already up.</span></span>
<span class="line" id="L404">    CLUSTER_NODE_ALREADY_UP = <span class="tok-number">0x80130001</span>,</span>
<span class="line" id="L405">    <span class="tok-comment">/// The cluster node is already down.</span></span>
<span class="line" id="L406">    CLUSTER_NODE_ALREADY_DOWN = <span class="tok-number">0x80130002</span>,</span>
<span class="line" id="L407">    <span class="tok-comment">/// The cluster network is already online.</span></span>
<span class="line" id="L408">    CLUSTER_NETWORK_ALREADY_ONLINE = <span class="tok-number">0x80130003</span>,</span>
<span class="line" id="L409">    <span class="tok-comment">/// The cluster network is already offline.</span></span>
<span class="line" id="L410">    CLUSTER_NETWORK_ALREADY_OFFLINE = <span class="tok-number">0x80130004</span>,</span>
<span class="line" id="L411">    <span class="tok-comment">/// The cluster node is already a member of the cluster.</span></span>
<span class="line" id="L412">    CLUSTER_NODE_ALREADY_MEMBER = <span class="tok-number">0x80130005</span>,</span>
<span class="line" id="L413">    <span class="tok-comment">/// The log could not be set to the requested size.</span></span>
<span class="line" id="L414">    COULD_NOT_RESIZE_LOG = <span class="tok-number">0x80190009</span>,</span>
<span class="line" id="L415">    <span class="tok-comment">/// There is no transaction metadata on the file.</span></span>
<span class="line" id="L416">    NO_TXF_METADATA = <span class="tok-number">0x80190029</span>,</span>
<span class="line" id="L417">    <span class="tok-comment">/// The file cannot be recovered because there is a handle still open on it.</span></span>
<span class="line" id="L418">    CANT_RECOVER_WITH_HANDLE_OPEN = <span class="tok-number">0x80190031</span>,</span>
<span class="line" id="L419">    <span class="tok-comment">/// Transaction metadata is already present on this file and cannot be superseded.</span></span>
<span class="line" id="L420">    TXF_METADATA_ALREADY_PRESENT = <span class="tok-number">0x80190041</span>,</span>
<span class="line" id="L421">    <span class="tok-comment">/// A transaction scope could not be entered because the scope handler has not been initialized.</span></span>
<span class="line" id="L422">    TRANSACTION_SCOPE_CALLBACKS_NOT_SET = <span class="tok-number">0x80190042</span>,</span>
<span class="line" id="L423">    <span class="tok-comment">/// {Display Driver Stopped Responding and recovered} The %hs display driver has stopped working normally. The recovery had been performed.</span></span>
<span class="line" id="L424">    VIDEO_HUNG_DISPLAY_DRIVER_THREAD_RECOVERED = <span class="tok-number">0x801B00EB</span>,</span>
<span class="line" id="L425">    <span class="tok-comment">/// {Buffer too small} The buffer is too small to contain the entry. No information has been written to the buffer.</span></span>
<span class="line" id="L426">    FLT_BUFFER_TOO_SMALL = <span class="tok-number">0x801C0001</span>,</span>
<span class="line" id="L427">    <span class="tok-comment">/// Volume metadata read or write is incomplete.</span></span>
<span class="line" id="L428">    FVE_PARTIAL_METADATA = <span class="tok-number">0x80210001</span>,</span>
<span class="line" id="L429">    <span class="tok-comment">/// BitLocker encryption keys were ignored because the volume was in a transient state.</span></span>
<span class="line" id="L430">    FVE_TRANSIENT_STATE = <span class="tok-number">0x80210002</span>,</span>
<span class="line" id="L431">    <span class="tok-comment">/// {Operation Failed} The requested operation was unsuccessful.</span></span>
<span class="line" id="L432">    UNSUCCESSFUL = <span class="tok-number">0xC0000001</span>,</span>
<span class="line" id="L433">    <span class="tok-comment">/// {Not Implemented} The requested operation is not implemented.</span></span>
<span class="line" id="L434">    NOT_IMPLEMENTED = <span class="tok-number">0xC0000002</span>,</span>
<span class="line" id="L435">    <span class="tok-comment">/// {Invalid Parameter} The specified information class is not a valid information class for the specified object.</span></span>
<span class="line" id="L436">    INVALID_INFO_CLASS = <span class="tok-number">0xC0000003</span>,</span>
<span class="line" id="L437">    <span class="tok-comment">/// The specified information record length does not match the length that is required for the specified information class.</span></span>
<span class="line" id="L438">    INFO_LENGTH_MISMATCH = <span class="tok-number">0xC0000004</span>,</span>
<span class="line" id="L439">    <span class="tok-comment">/// The instruction at 0x%08lx referenced memory at 0x%08lx. The memory could not be %s.</span></span>
<span class="line" id="L440">    ACCESS_VIOLATION = <span class="tok-number">0xC0000005</span>,</span>
<span class="line" id="L441">    <span class="tok-comment">/// The instruction at 0x%08lx referenced memory at 0x%08lx.</span></span>
<span class="line" id="L442">    <span class="tok-comment">/// The required data was not placed into memory because of an I/O error status of 0x%08lx.</span></span>
<span class="line" id="L443">    IN_PAGE_ERROR = <span class="tok-number">0xC0000006</span>,</span>
<span class="line" id="L444">    <span class="tok-comment">/// The page file quota for the process has been exhausted.</span></span>
<span class="line" id="L445">    PAGEFILE_QUOTA = <span class="tok-number">0xC0000007</span>,</span>
<span class="line" id="L446">    <span class="tok-comment">/// An invalid HANDLE was specified.</span></span>
<span class="line" id="L447">    INVALID_HANDLE = <span class="tok-number">0xC0000008</span>,</span>
<span class="line" id="L448">    <span class="tok-comment">/// An invalid initial stack was specified in a call to NtCreateThread.</span></span>
<span class="line" id="L449">    BAD_INITIAL_STACK = <span class="tok-number">0xC0000009</span>,</span>
<span class="line" id="L450">    <span class="tok-comment">/// An invalid initial start address was specified in a call to NtCreateThread.</span></span>
<span class="line" id="L451">    BAD_INITIAL_PC = <span class="tok-number">0xC000000A</span>,</span>
<span class="line" id="L452">    <span class="tok-comment">/// An invalid client ID was specified.</span></span>
<span class="line" id="L453">    INVALID_CID = <span class="tok-number">0xC000000B</span>,</span>
<span class="line" id="L454">    <span class="tok-comment">/// An attempt was made to cancel or set a timer that has an associated APC and the specified thread is not the thread that originally set the timer with an associated APC routine.</span></span>
<span class="line" id="L455">    TIMER_NOT_CANCELED = <span class="tok-number">0xC000000C</span>,</span>
<span class="line" id="L456">    <span class="tok-comment">/// An invalid parameter was passed to a service or function.</span></span>
<span class="line" id="L457">    INVALID_PARAMETER = <span class="tok-number">0xC000000D</span>,</span>
<span class="line" id="L458">    <span class="tok-comment">/// A device that does not exist was specified.</span></span>
<span class="line" id="L459">    NO_SUCH_DEVICE = <span class="tok-number">0xC000000E</span>,</span>
<span class="line" id="L460">    <span class="tok-comment">/// {File Not Found} The file %hs does not exist.</span></span>
<span class="line" id="L461">    NO_SUCH_FILE = <span class="tok-number">0xC000000F</span>,</span>
<span class="line" id="L462">    <span class="tok-comment">/// The specified request is not a valid operation for the target device.</span></span>
<span class="line" id="L463">    INVALID_DEVICE_REQUEST = <span class="tok-number">0xC0000010</span>,</span>
<span class="line" id="L464">    <span class="tok-comment">/// The end-of-file marker has been reached.</span></span>
<span class="line" id="L465">    <span class="tok-comment">/// There is no valid data in the file beyond this marker.</span></span>
<span class="line" id="L466">    END_OF_FILE = <span class="tok-number">0xC0000011</span>,</span>
<span class="line" id="L467">    <span class="tok-comment">/// {Wrong Volume} The wrong volume is in the drive. Insert volume %hs into drive %hs.</span></span>
<span class="line" id="L468">    WRONG_VOLUME = <span class="tok-number">0xC0000012</span>,</span>
<span class="line" id="L469">    <span class="tok-comment">/// {No Disk} There is no disk in the drive. Insert a disk into drive %hs.</span></span>
<span class="line" id="L470">    NO_MEDIA_IN_DEVICE = <span class="tok-number">0xC0000013</span>,</span>
<span class="line" id="L471">    <span class="tok-comment">/// {Unknown Disk Format} The disk in drive %hs is not formatted properly.</span></span>
<span class="line" id="L472">    <span class="tok-comment">/// Check the disk, and reformat it, if needed.</span></span>
<span class="line" id="L473">    UNRECOGNIZED_MEDIA = <span class="tok-number">0xC0000014</span>,</span>
<span class="line" id="L474">    <span class="tok-comment">/// {Sector Not Found} The specified sector does not exist.</span></span>
<span class="line" id="L475">    NONEXISTENT_SECTOR = <span class="tok-number">0xC0000015</span>,</span>
<span class="line" id="L476">    <span class="tok-comment">/// {Still Busy} The specified I/O request packet (IRP) cannot be disposed of because the I/O operation is not complete.</span></span>
<span class="line" id="L477">    MORE_PROCESSING_REQUIRED = <span class="tok-number">0xC0000016</span>,</span>
<span class="line" id="L478">    <span class="tok-comment">/// {Not Enough Quota} Not enough virtual memory or paging file quota is available to complete the specified operation.</span></span>
<span class="line" id="L479">    NO_MEMORY = <span class="tok-number">0xC0000017</span>,</span>
<span class="line" id="L480">    <span class="tok-comment">/// {Conflicting Address Range} The specified address range conflicts with the address space.</span></span>
<span class="line" id="L481">    CONFLICTING_ADDRESSES = <span class="tok-number">0xC0000018</span>,</span>
<span class="line" id="L482">    <span class="tok-comment">/// The address range to unmap is not a mapped view.</span></span>
<span class="line" id="L483">    NOT_MAPPED_VIEW = <span class="tok-number">0xC0000019</span>,</span>
<span class="line" id="L484">    <span class="tok-comment">/// The virtual memory cannot be freed.</span></span>
<span class="line" id="L485">    UNABLE_TO_FREE_VM = <span class="tok-number">0xC000001A</span>,</span>
<span class="line" id="L486">    <span class="tok-comment">/// The specified section cannot be deleted.</span></span>
<span class="line" id="L487">    UNABLE_TO_DELETE_SECTION = <span class="tok-number">0xC000001B</span>,</span>
<span class="line" id="L488">    <span class="tok-comment">/// An invalid system service was specified in a system service call.</span></span>
<span class="line" id="L489">    INVALID_SYSTEM_SERVICE = <span class="tok-number">0xC000001C</span>,</span>
<span class="line" id="L490">    <span class="tok-comment">/// {EXCEPTION} Illegal Instruction An attempt was made to execute an illegal instruction.</span></span>
<span class="line" id="L491">    ILLEGAL_INSTRUCTION = <span class="tok-number">0xC000001D</span>,</span>
<span class="line" id="L492">    <span class="tok-comment">/// {Invalid Lock Sequence} An attempt was made to execute an invalid lock sequence.</span></span>
<span class="line" id="L493">    INVALID_LOCK_SEQUENCE = <span class="tok-number">0xC000001E</span>,</span>
<span class="line" id="L494">    <span class="tok-comment">/// {Invalid Mapping} An attempt was made to create a view for a section that is bigger than the section.</span></span>
<span class="line" id="L495">    INVALID_VIEW_SIZE = <span class="tok-number">0xC000001F</span>,</span>
<span class="line" id="L496">    <span class="tok-comment">/// {Bad File} The attributes of the specified mapping file for a section of memory cannot be read.</span></span>
<span class="line" id="L497">    INVALID_FILE_FOR_SECTION = <span class="tok-number">0xC0000020</span>,</span>
<span class="line" id="L498">    <span class="tok-comment">/// {Already Committed} The specified address range is already committed.</span></span>
<span class="line" id="L499">    ALREADY_COMMITTED = <span class="tok-number">0xC0000021</span>,</span>
<span class="line" id="L500">    <span class="tok-comment">/// {Access Denied} A process has requested access to an object but has not been granted those access rights.</span></span>
<span class="line" id="L501">    ACCESS_DENIED = <span class="tok-number">0xC0000022</span>,</span>
<span class="line" id="L502">    <span class="tok-comment">/// {Buffer Too Small} The buffer is too small to contain the entry. No information has been written to the buffer.</span></span>
<span class="line" id="L503">    BUFFER_TOO_SMALL = <span class="tok-number">0xC0000023</span>,</span>
<span class="line" id="L504">    <span class="tok-comment">/// {Wrong Type} There is a mismatch between the type of object that is required by the requested operation and the type of object that is specified in the request.</span></span>
<span class="line" id="L505">    OBJECT_TYPE_MISMATCH = <span class="tok-number">0xC0000024</span>,</span>
<span class="line" id="L506">    <span class="tok-comment">/// {EXCEPTION} Cannot Continue Windows cannot continue from this exception.</span></span>
<span class="line" id="L507">    NONCONTINUABLE_EXCEPTION = <span class="tok-number">0xC0000025</span>,</span>
<span class="line" id="L508">    <span class="tok-comment">/// An invalid exception disposition was returned by an exception handler.</span></span>
<span class="line" id="L509">    INVALID_DISPOSITION = <span class="tok-number">0xC0000026</span>,</span>
<span class="line" id="L510">    <span class="tok-comment">/// Unwind exception code.</span></span>
<span class="line" id="L511">    UNWIND = <span class="tok-number">0xC0000027</span>,</span>
<span class="line" id="L512">    <span class="tok-comment">/// An invalid or unaligned stack was encountered during an unwind operation.</span></span>
<span class="line" id="L513">    BAD_STACK = <span class="tok-number">0xC0000028</span>,</span>
<span class="line" id="L514">    <span class="tok-comment">/// An invalid unwind target was encountered during an unwind operation.</span></span>
<span class="line" id="L515">    INVALID_UNWIND_TARGET = <span class="tok-number">0xC0000029</span>,</span>
<span class="line" id="L516">    <span class="tok-comment">/// An attempt was made to unlock a page of memory that was not locked.</span></span>
<span class="line" id="L517">    NOT_LOCKED = <span class="tok-number">0xC000002A</span>,</span>
<span class="line" id="L518">    <span class="tok-comment">/// A device parity error on an I/O operation.</span></span>
<span class="line" id="L519">    PARITY_ERROR = <span class="tok-number">0xC000002B</span>,</span>
<span class="line" id="L520">    <span class="tok-comment">/// An attempt was made to decommit uncommitted virtual memory.</span></span>
<span class="line" id="L521">    UNABLE_TO_DECOMMIT_VM = <span class="tok-number">0xC000002C</span>,</span>
<span class="line" id="L522">    <span class="tok-comment">/// An attempt was made to change the attributes on memory that has not been committed.</span></span>
<span class="line" id="L523">    NOT_COMMITTED = <span class="tok-number">0xC000002D</span>,</span>
<span class="line" id="L524">    <span class="tok-comment">/// Invalid object attributes specified to NtCreatePort or invalid port attributes specified to NtConnectPort.</span></span>
<span class="line" id="L525">    INVALID_PORT_ATTRIBUTES = <span class="tok-number">0xC000002E</span>,</span>
<span class="line" id="L526">    <span class="tok-comment">/// The length of the message that was passed to NtRequestPort or NtRequestWaitReplyPort is longer than the maximum message that is allowed by the port.</span></span>
<span class="line" id="L527">    PORT_MESSAGE_TOO_LONG = <span class="tok-number">0xC000002F</span>,</span>
<span class="line" id="L528">    <span class="tok-comment">/// An invalid combination of parameters was specified.</span></span>
<span class="line" id="L529">    INVALID_PARAMETER_MIX = <span class="tok-number">0xC0000030</span>,</span>
<span class="line" id="L530">    <span class="tok-comment">/// An attempt was made to lower a quota limit below the current usage.</span></span>
<span class="line" id="L531">    INVALID_QUOTA_LOWER = <span class="tok-number">0xC0000031</span>,</span>
<span class="line" id="L532">    <span class="tok-comment">/// {Corrupt Disk} The file system structure on the disk is corrupt and unusable. Run the Chkdsk utility on the volume %hs.</span></span>
<span class="line" id="L533">    DISK_CORRUPT_ERROR = <span class="tok-number">0xC0000032</span>,</span>
<span class="line" id="L534">    <span class="tok-comment">/// The object name is invalid.</span></span>
<span class="line" id="L535">    OBJECT_NAME_INVALID = <span class="tok-number">0xC0000033</span>,</span>
<span class="line" id="L536">    <span class="tok-comment">/// The object name is not found.</span></span>
<span class="line" id="L537">    OBJECT_NAME_NOT_FOUND = <span class="tok-number">0xC0000034</span>,</span>
<span class="line" id="L538">    <span class="tok-comment">/// The object name already exists.</span></span>
<span class="line" id="L539">    OBJECT_NAME_COLLISION = <span class="tok-number">0xC0000035</span>,</span>
<span class="line" id="L540">    <span class="tok-comment">/// An attempt was made to send a message to a disconnected communication port.</span></span>
<span class="line" id="L541">    PORT_DISCONNECTED = <span class="tok-number">0xC0000037</span>,</span>
<span class="line" id="L542">    <span class="tok-comment">/// An attempt was made to attach to a device that was already attached to another device.</span></span>
<span class="line" id="L543">    DEVICE_ALREADY_ATTACHED = <span class="tok-number">0xC0000038</span>,</span>
<span class="line" id="L544">    <span class="tok-comment">/// The object path component was not a directory object.</span></span>
<span class="line" id="L545">    OBJECT_PATH_INVALID = <span class="tok-number">0xC0000039</span>,</span>
<span class="line" id="L546">    <span class="tok-comment">/// {Path Not Found} The path %hs does not exist.</span></span>
<span class="line" id="L547">    OBJECT_PATH_NOT_FOUND = <span class="tok-number">0xC000003A</span>,</span>
<span class="line" id="L548">    <span class="tok-comment">/// The object path component was not a directory object.</span></span>
<span class="line" id="L549">    OBJECT_PATH_SYNTAX_BAD = <span class="tok-number">0xC000003B</span>,</span>
<span class="line" id="L550">    <span class="tok-comment">/// {Data Overrun} A data overrun error occurred.</span></span>
<span class="line" id="L551">    DATA_OVERRUN = <span class="tok-number">0xC000003C</span>,</span>
<span class="line" id="L552">    <span class="tok-comment">/// {Data Late} A data late error occurred.</span></span>
<span class="line" id="L553">    DATA_LATE_ERROR = <span class="tok-number">0xC000003D</span>,</span>
<span class="line" id="L554">    <span class="tok-comment">/// {Data Error} An error occurred in reading or writing data.</span></span>
<span class="line" id="L555">    DATA_ERROR = <span class="tok-number">0xC000003E</span>,</span>
<span class="line" id="L556">    <span class="tok-comment">/// {Bad CRC} A cyclic redundancy check (CRC) checksum error occurred.</span></span>
<span class="line" id="L557">    CRC_ERROR = <span class="tok-number">0xC000003F</span>,</span>
<span class="line" id="L558">    <span class="tok-comment">/// {Section Too Large} The specified section is too big to map the file.</span></span>
<span class="line" id="L559">    SECTION_TOO_BIG = <span class="tok-number">0xC0000040</span>,</span>
<span class="line" id="L560">    <span class="tok-comment">/// The NtConnectPort request is refused.</span></span>
<span class="line" id="L561">    PORT_CONNECTION_REFUSED = <span class="tok-number">0xC0000041</span>,</span>
<span class="line" id="L562">    <span class="tok-comment">/// The type of port handle is invalid for the operation that is requested.</span></span>
<span class="line" id="L563">    INVALID_PORT_HANDLE = <span class="tok-number">0xC0000042</span>,</span>
<span class="line" id="L564">    <span class="tok-comment">/// A file cannot be opened because the share access flags are incompatible.</span></span>
<span class="line" id="L565">    SHARING_VIOLATION = <span class="tok-number">0xC0000043</span>,</span>
<span class="line" id="L566">    <span class="tok-comment">/// Insufficient quota exists to complete the operation.</span></span>
<span class="line" id="L567">    QUOTA_EXCEEDED = <span class="tok-number">0xC0000044</span>,</span>
<span class="line" id="L568">    <span class="tok-comment">/// The specified page protection was not valid.</span></span>
<span class="line" id="L569">    INVALID_PAGE_PROTECTION = <span class="tok-number">0xC0000045</span>,</span>
<span class="line" id="L570">    <span class="tok-comment">/// An attempt to release a mutant object was made by a thread that was not the owner of the mutant object.</span></span>
<span class="line" id="L571">    MUTANT_NOT_OWNED = <span class="tok-number">0xC0000046</span>,</span>
<span class="line" id="L572">    <span class="tok-comment">/// An attempt was made to release a semaphore such that its maximum count would have been exceeded.</span></span>
<span class="line" id="L573">    SEMAPHORE_LIMIT_EXCEEDED = <span class="tok-number">0xC0000047</span>,</span>
<span class="line" id="L574">    <span class="tok-comment">/// An attempt was made to set the DebugPort or ExceptionPort of a process, but a port already exists in the process, or an attempt was made to set the CompletionPort of a file but a port was already set in the file, or an attempt was made to set the associated completion port of an ALPC port but it is already set.</span></span>
<span class="line" id="L575">    PORT_ALREADY_SET = <span class="tok-number">0xC0000048</span>,</span>
<span class="line" id="L576">    <span class="tok-comment">/// An attempt was made to query image information on a section that does not map an image.</span></span>
<span class="line" id="L577">    SECTION_NOT_IMAGE = <span class="tok-number">0xC0000049</span>,</span>
<span class="line" id="L578">    <span class="tok-comment">/// An attempt was made to suspend a thread whose suspend count was at its maximum.</span></span>
<span class="line" id="L579">    SUSPEND_COUNT_EXCEEDED = <span class="tok-number">0xC000004A</span>,</span>
<span class="line" id="L580">    <span class="tok-comment">/// An attempt was made to suspend a thread that has begun termination.</span></span>
<span class="line" id="L581">    THREAD_IS_TERMINATING = <span class="tok-number">0xC000004B</span>,</span>
<span class="line" id="L582">    <span class="tok-comment">/// An attempt was made to set the working set limit to an invalid value (for example, the minimum greater than maximum).</span></span>
<span class="line" id="L583">    BAD_WORKING_SET_LIMIT = <span class="tok-number">0xC000004C</span>,</span>
<span class="line" id="L584">    <span class="tok-comment">/// A section was created to map a file that is not compatible with an already existing section that maps the same file.</span></span>
<span class="line" id="L585">    INCOMPATIBLE_FILE_MAP = <span class="tok-number">0xC000004D</span>,</span>
<span class="line" id="L586">    <span class="tok-comment">/// A view to a section specifies a protection that is incompatible with the protection of the initial view.</span></span>
<span class="line" id="L587">    SECTION_PROTECTION = <span class="tok-number">0xC000004E</span>,</span>
<span class="line" id="L588">    <span class="tok-comment">/// An operation involving EAs failed because the file system does not support EAs.</span></span>
<span class="line" id="L589">    EAS_NOT_SUPPORTED = <span class="tok-number">0xC000004F</span>,</span>
<span class="line" id="L590">    <span class="tok-comment">/// An EA operation failed because the EA set is too large.</span></span>
<span class="line" id="L591">    EA_TOO_LARGE = <span class="tok-number">0xC0000050</span>,</span>
<span class="line" id="L592">    <span class="tok-comment">/// An EA operation failed because the name or EA index is invalid.</span></span>
<span class="line" id="L593">    NONEXISTENT_EA_ENTRY = <span class="tok-number">0xC0000051</span>,</span>
<span class="line" id="L594">    <span class="tok-comment">/// The file for which EAs were requested has no EAs.</span></span>
<span class="line" id="L595">    NO_EAS_ON_FILE = <span class="tok-number">0xC0000052</span>,</span>
<span class="line" id="L596">    <span class="tok-comment">/// The EA is corrupt and cannot be read.</span></span>
<span class="line" id="L597">    EA_CORRUPT_ERROR = <span class="tok-number">0xC0000053</span>,</span>
<span class="line" id="L598">    <span class="tok-comment">/// A requested read/write cannot be granted due to a conflicting file lock.</span></span>
<span class="line" id="L599">    FILE_LOCK_CONFLICT = <span class="tok-number">0xC0000054</span>,</span>
<span class="line" id="L600">    <span class="tok-comment">/// A requested file lock cannot be granted due to other existing locks.</span></span>
<span class="line" id="L601">    LOCK_NOT_GRANTED = <span class="tok-number">0xC0000055</span>,</span>
<span class="line" id="L602">    <span class="tok-comment">/// A non-close operation has been requested of a file object that has a delete pending.</span></span>
<span class="line" id="L603">    DELETE_PENDING = <span class="tok-number">0xC0000056</span>,</span>
<span class="line" id="L604">    <span class="tok-comment">/// An attempt was made to set the control attribute on a file.</span></span>
<span class="line" id="L605">    <span class="tok-comment">/// This attribute is not supported in the destination file system.</span></span>
<span class="line" id="L606">    CTL_FILE_NOT_SUPPORTED = <span class="tok-number">0xC0000057</span>,</span>
<span class="line" id="L607">    <span class="tok-comment">/// Indicates a revision number that was encountered or specified is not one that is known by the service.</span></span>
<span class="line" id="L608">    <span class="tok-comment">/// It might be a more recent revision than the service is aware of.</span></span>
<span class="line" id="L609">    UNKNOWN_REVISION = <span class="tok-number">0xC0000058</span>,</span>
<span class="line" id="L610">    <span class="tok-comment">/// Indicates that two revision levels are incompatible.</span></span>
<span class="line" id="L611">    REVISION_MISMATCH = <span class="tok-number">0xC0000059</span>,</span>
<span class="line" id="L612">    <span class="tok-comment">/// Indicates a particular security ID cannot be assigned as the owner of an object.</span></span>
<span class="line" id="L613">    INVALID_OWNER = <span class="tok-number">0xC000005A</span>,</span>
<span class="line" id="L614">    <span class="tok-comment">/// Indicates a particular security ID cannot be assigned as the primary group of an object.</span></span>
<span class="line" id="L615">    INVALID_PRIMARY_GROUP = <span class="tok-number">0xC000005B</span>,</span>
<span class="line" id="L616">    <span class="tok-comment">/// An attempt has been made to operate on an impersonation token by a thread that is not currently impersonating a client.</span></span>
<span class="line" id="L617">    NO_IMPERSONATION_TOKEN = <span class="tok-number">0xC000005C</span>,</span>
<span class="line" id="L618">    <span class="tok-comment">/// A mandatory group cannot be disabled.</span></span>
<span class="line" id="L619">    CANT_DISABLE_MANDATORY = <span class="tok-number">0xC000005D</span>,</span>
<span class="line" id="L620">    <span class="tok-comment">/// No logon servers are currently available to service the logon request.</span></span>
<span class="line" id="L621">    NO_LOGON_SERVERS = <span class="tok-number">0xC000005E</span>,</span>
<span class="line" id="L622">    <span class="tok-comment">/// A specified logon session does not exist. It might already have been terminated.</span></span>
<span class="line" id="L623">    NO_SUCH_LOGON_SESSION = <span class="tok-number">0xC000005F</span>,</span>
<span class="line" id="L624">    <span class="tok-comment">/// A specified privilege does not exist.</span></span>
<span class="line" id="L625">    NO_SUCH_PRIVILEGE = <span class="tok-number">0xC0000060</span>,</span>
<span class="line" id="L626">    <span class="tok-comment">/// A required privilege is not held by the client.</span></span>
<span class="line" id="L627">    PRIVILEGE_NOT_HELD = <span class="tok-number">0xC0000061</span>,</span>
<span class="line" id="L628">    <span class="tok-comment">/// The name provided is not a properly formed account name.</span></span>
<span class="line" id="L629">    INVALID_ACCOUNT_NAME = <span class="tok-number">0xC0000062</span>,</span>
<span class="line" id="L630">    <span class="tok-comment">/// The specified account already exists.</span></span>
<span class="line" id="L631">    USER_EXISTS = <span class="tok-number">0xC0000063</span>,</span>
<span class="line" id="L632">    <span class="tok-comment">/// The specified account does not exist.</span></span>
<span class="line" id="L633">    NO_SUCH_USER = <span class="tok-number">0xC0000064</span>,</span>
<span class="line" id="L634">    <span class="tok-comment">/// The specified group already exists.</span></span>
<span class="line" id="L635">    GROUP_EXISTS = <span class="tok-number">0xC0000065</span>,</span>
<span class="line" id="L636">    <span class="tok-comment">/// The specified group does not exist.</span></span>
<span class="line" id="L637">    NO_SUCH_GROUP = <span class="tok-number">0xC0000066</span>,</span>
<span class="line" id="L638">    <span class="tok-comment">/// The specified user account is already in the specified group account.</span></span>
<span class="line" id="L639">    <span class="tok-comment">/// Also used to indicate a group cannot be deleted because it contains a member.</span></span>
<span class="line" id="L640">    MEMBER_IN_GROUP = <span class="tok-number">0xC0000067</span>,</span>
<span class="line" id="L641">    <span class="tok-comment">/// The specified user account is not a member of the specified group account.</span></span>
<span class="line" id="L642">    MEMBER_NOT_IN_GROUP = <span class="tok-number">0xC0000068</span>,</span>
<span class="line" id="L643">    <span class="tok-comment">/// Indicates the requested operation would disable or delete the last remaining administration account.</span></span>
<span class="line" id="L644">    <span class="tok-comment">/// This is not allowed to prevent creating a situation in which the system cannot be administrated.</span></span>
<span class="line" id="L645">    LAST_ADMIN = <span class="tok-number">0xC0000069</span>,</span>
<span class="line" id="L646">    <span class="tok-comment">/// When trying to update a password, this return status indicates that the value provided as the current password is not correct.</span></span>
<span class="line" id="L647">    WRONG_PASSWORD = <span class="tok-number">0xC000006A</span>,</span>
<span class="line" id="L648">    <span class="tok-comment">/// When trying to update a password, this return status indicates that the value provided for the new password contains values that are not allowed in passwords.</span></span>
<span class="line" id="L649">    ILL_FORMED_PASSWORD = <span class="tok-number">0xC000006B</span>,</span>
<span class="line" id="L650">    <span class="tok-comment">/// When trying to update a password, this status indicates that some password update rule has been violated.</span></span>
<span class="line" id="L651">    <span class="tok-comment">/// For example, the password might not meet length criteria.</span></span>
<span class="line" id="L652">    PASSWORD_RESTRICTION = <span class="tok-number">0xC000006C</span>,</span>
<span class="line" id="L653">    <span class="tok-comment">/// The attempted logon is invalid.</span></span>
<span class="line" id="L654">    <span class="tok-comment">/// This is either due to a bad username or authentication information.</span></span>
<span class="line" id="L655">    LOGON_FAILURE = <span class="tok-number">0xC000006D</span>,</span>
<span class="line" id="L656">    <span class="tok-comment">/// Indicates a referenced user name and authentication information are valid, but some user account restriction has prevented successful authentication (such as time-of-day restrictions).</span></span>
<span class="line" id="L657">    ACCOUNT_RESTRICTION = <span class="tok-number">0xC000006E</span>,</span>
<span class="line" id="L658">    <span class="tok-comment">/// The user account has time restrictions and cannot be logged onto at this time.</span></span>
<span class="line" id="L659">    INVALID_LOGON_HOURS = <span class="tok-number">0xC000006F</span>,</span>
<span class="line" id="L660">    <span class="tok-comment">/// The user account is restricted so that it cannot be used to log on from the source workstation.</span></span>
<span class="line" id="L661">    INVALID_WORKSTATION = <span class="tok-number">0xC0000070</span>,</span>
<span class="line" id="L662">    <span class="tok-comment">/// The user account password has expired.</span></span>
<span class="line" id="L663">    PASSWORD_EXPIRED = <span class="tok-number">0xC0000071</span>,</span>
<span class="line" id="L664">    <span class="tok-comment">/// The referenced account is currently disabled and cannot be logged on to.</span></span>
<span class="line" id="L665">    ACCOUNT_DISABLED = <span class="tok-number">0xC0000072</span>,</span>
<span class="line" id="L666">    <span class="tok-comment">/// None of the information to be translated has been translated.</span></span>
<span class="line" id="L667">    NONE_MAPPED = <span class="tok-number">0xC0000073</span>,</span>
<span class="line" id="L668">    <span class="tok-comment">/// The number of LUIDs requested cannot be allocated with a single allocation.</span></span>
<span class="line" id="L669">    TOO_MANY_LUIDS_REQUESTED = <span class="tok-number">0xC0000074</span>,</span>
<span class="line" id="L670">    <span class="tok-comment">/// Indicates there are no more LUIDs to allocate.</span></span>
<span class="line" id="L671">    LUIDS_EXHAUSTED = <span class="tok-number">0xC0000075</span>,</span>
<span class="line" id="L672">    <span class="tok-comment">/// Indicates the sub-authority value is invalid for the particular use.</span></span>
<span class="line" id="L673">    INVALID_SUB_AUTHORITY = <span class="tok-number">0xC0000076</span>,</span>
<span class="line" id="L674">    <span class="tok-comment">/// Indicates the ACL structure is not valid.</span></span>
<span class="line" id="L675">    INVALID_ACL = <span class="tok-number">0xC0000077</span>,</span>
<span class="line" id="L676">    <span class="tok-comment">/// Indicates the SID structure is not valid.</span></span>
<span class="line" id="L677">    INVALID_SID = <span class="tok-number">0xC0000078</span>,</span>
<span class="line" id="L678">    <span class="tok-comment">/// Indicates the SECURITY_DESCRIPTOR structure is not valid.</span></span>
<span class="line" id="L679">    INVALID_SECURITY_DESCR = <span class="tok-number">0xC0000079</span>,</span>
<span class="line" id="L680">    <span class="tok-comment">/// Indicates the specified procedure address cannot be found in the DLL.</span></span>
<span class="line" id="L681">    PROCEDURE_NOT_FOUND = <span class="tok-number">0xC000007A</span>,</span>
<span class="line" id="L682">    <span class="tok-comment">/// {Bad Image} %hs is either not designed to run on Windows or it contains an error.</span></span>
<span class="line" id="L683">    <span class="tok-comment">/// Try installing the program again using the original installation media or contact your system administrator or the software vendor for support.</span></span>
<span class="line" id="L684">    INVALID_IMAGE_FORMAT = <span class="tok-number">0xC000007B</span>,</span>
<span class="line" id="L685">    <span class="tok-comment">/// An attempt was made to reference a token that does not exist.</span></span>
<span class="line" id="L686">    <span class="tok-comment">/// This is typically done by referencing the token that is associated with a thread when the thread is not impersonating a client.</span></span>
<span class="line" id="L687">    NO_TOKEN = <span class="tok-number">0xC000007C</span>,</span>
<span class="line" id="L688">    <span class="tok-comment">/// Indicates that an attempt to build either an inherited ACL or ACE was not successful. This can be caused by a number of things.</span></span>
<span class="line" id="L689">    <span class="tok-comment">/// One of the more probable causes is the replacement of a CreatorId with a SID that did not fit into the ACE or ACL.</span></span>
<span class="line" id="L690">    BAD_INHERITANCE_ACL = <span class="tok-number">0xC000007D</span>,</span>
<span class="line" id="L691">    <span class="tok-comment">/// The range specified in NtUnlockFile was not locked.</span></span>
<span class="line" id="L692">    RANGE_NOT_LOCKED = <span class="tok-number">0xC000007E</span>,</span>
<span class="line" id="L693">    <span class="tok-comment">/// An operation failed because the disk was full.</span></span>
<span class="line" id="L694">    DISK_FULL = <span class="tok-number">0xC000007F</span>,</span>
<span class="line" id="L695">    <span class="tok-comment">/// The GUID allocation server is disabled at the moment.</span></span>
<span class="line" id="L696">    SERVER_DISABLED = <span class="tok-number">0xC0000080</span>,</span>
<span class="line" id="L697">    <span class="tok-comment">/// The GUID allocation server is enabled at the moment.</span></span>
<span class="line" id="L698">    SERVER_NOT_DISABLED = <span class="tok-number">0xC0000081</span>,</span>
<span class="line" id="L699">    <span class="tok-comment">/// Too many GUIDs were requested from the allocation server at once.</span></span>
<span class="line" id="L700">    TOO_MANY_GUIDS_REQUESTED = <span class="tok-number">0xC0000082</span>,</span>
<span class="line" id="L701">    <span class="tok-comment">/// The GUIDs could not be allocated because the Authority Agent was exhausted.</span></span>
<span class="line" id="L702">    GUIDS_EXHAUSTED = <span class="tok-number">0xC0000083</span>,</span>
<span class="line" id="L703">    <span class="tok-comment">/// The value provided was an invalid value for an identifier authority.</span></span>
<span class="line" id="L704">    INVALID_ID_AUTHORITY = <span class="tok-number">0xC0000084</span>,</span>
<span class="line" id="L705">    <span class="tok-comment">/// No more authority agent values are available for the particular identifier authority value.</span></span>
<span class="line" id="L706">    AGENTS_EXHAUSTED = <span class="tok-number">0xC0000085</span>,</span>
<span class="line" id="L707">    <span class="tok-comment">/// An invalid volume label has been specified.</span></span>
<span class="line" id="L708">    INVALID_VOLUME_LABEL = <span class="tok-number">0xC0000086</span>,</span>
<span class="line" id="L709">    <span class="tok-comment">/// A mapped section could not be extended.</span></span>
<span class="line" id="L710">    SECTION_NOT_EXTENDED = <span class="tok-number">0xC0000087</span>,</span>
<span class="line" id="L711">    <span class="tok-comment">/// Specified section to flush does not map a data file.</span></span>
<span class="line" id="L712">    NOT_MAPPED_DATA = <span class="tok-number">0xC0000088</span>,</span>
<span class="line" id="L713">    <span class="tok-comment">/// Indicates the specified image file did not contain a resource section.</span></span>
<span class="line" id="L714">    RESOURCE_DATA_NOT_FOUND = <span class="tok-number">0xC0000089</span>,</span>
<span class="line" id="L715">    <span class="tok-comment">/// Indicates the specified resource type cannot be found in the image file.</span></span>
<span class="line" id="L716">    RESOURCE_TYPE_NOT_FOUND = <span class="tok-number">0xC000008A</span>,</span>
<span class="line" id="L717">    <span class="tok-comment">/// Indicates the specified resource name cannot be found in the image file.</span></span>
<span class="line" id="L718">    RESOURCE_NAME_NOT_FOUND = <span class="tok-number">0xC000008B</span>,</span>
<span class="line" id="L719">    <span class="tok-comment">/// {EXCEPTION} Array bounds exceeded.</span></span>
<span class="line" id="L720">    ARRAY_BOUNDS_EXCEEDED = <span class="tok-number">0xC000008C</span>,</span>
<span class="line" id="L721">    <span class="tok-comment">/// {EXCEPTION} Floating-point denormal operand.</span></span>
<span class="line" id="L722">    FLOAT_DENORMAL_OPERAND = <span class="tok-number">0xC000008D</span>,</span>
<span class="line" id="L723">    <span class="tok-comment">/// {EXCEPTION} Floating-point division by zero.</span></span>
<span class="line" id="L724">    FLOAT_DIVIDE_BY_ZERO = <span class="tok-number">0xC000008E</span>,</span>
<span class="line" id="L725">    <span class="tok-comment">/// {EXCEPTION} Floating-point inexact result.</span></span>
<span class="line" id="L726">    FLOAT_INEXACT_RESULT = <span class="tok-number">0xC000008F</span>,</span>
<span class="line" id="L727">    <span class="tok-comment">/// {EXCEPTION} Floating-point invalid operation.</span></span>
<span class="line" id="L728">    FLOAT_INVALID_OPERATION = <span class="tok-number">0xC0000090</span>,</span>
<span class="line" id="L729">    <span class="tok-comment">/// {EXCEPTION} Floating-point overflow.</span></span>
<span class="line" id="L730">    FLOAT_OVERFLOW = <span class="tok-number">0xC0000091</span>,</span>
<span class="line" id="L731">    <span class="tok-comment">/// {EXCEPTION} Floating-point stack check.</span></span>
<span class="line" id="L732">    FLOAT_STACK_CHECK = <span class="tok-number">0xC0000092</span>,</span>
<span class="line" id="L733">    <span class="tok-comment">/// {EXCEPTION} Floating-point underflow.</span></span>
<span class="line" id="L734">    FLOAT_UNDERFLOW = <span class="tok-number">0xC0000093</span>,</span>
<span class="line" id="L735">    <span class="tok-comment">/// {EXCEPTION} Integer division by zero.</span></span>
<span class="line" id="L736">    INTEGER_DIVIDE_BY_ZERO = <span class="tok-number">0xC0000094</span>,</span>
<span class="line" id="L737">    <span class="tok-comment">/// {EXCEPTION} Integer overflow.</span></span>
<span class="line" id="L738">    INTEGER_OVERFLOW = <span class="tok-number">0xC0000095</span>,</span>
<span class="line" id="L739">    <span class="tok-comment">/// {EXCEPTION} Privileged instruction.</span></span>
<span class="line" id="L740">    PRIVILEGED_INSTRUCTION = <span class="tok-number">0xC0000096</span>,</span>
<span class="line" id="L741">    <span class="tok-comment">/// An attempt was made to install more paging files than the system supports.</span></span>
<span class="line" id="L742">    TOO_MANY_PAGING_FILES = <span class="tok-number">0xC0000097</span>,</span>
<span class="line" id="L743">    <span class="tok-comment">/// The volume for a file has been externally altered such that the opened file is no longer valid.</span></span>
<span class="line" id="L744">    FILE_INVALID = <span class="tok-number">0xC0000098</span>,</span>
<span class="line" id="L745">    <span class="tok-comment">/// When a block of memory is allotted for future updates, such as the memory allocated to hold discretionary access control and primary group information, successive updates might exceed the amount of memory originally allotted.</span></span>
<span class="line" id="L746">    <span class="tok-comment">/// Because a quota might already have been charged to several processes that have handles to the object, it is not reasonable to alter the size of the allocated memory.</span></span>
<span class="line" id="L747">    <span class="tok-comment">/// Instead, a request that requires more memory than has been allotted must fail and the STATUS_ALLOTTED_SPACE_EXCEEDED error returned.</span></span>
<span class="line" id="L748">    ALLOTTED_SPACE_EXCEEDED = <span class="tok-number">0xC0000099</span>,</span>
<span class="line" id="L749">    <span class="tok-comment">/// Insufficient system resources exist to complete the API.</span></span>
<span class="line" id="L750">    INSUFFICIENT_RESOURCES = <span class="tok-number">0xC000009A</span>,</span>
<span class="line" id="L751">    <span class="tok-comment">/// An attempt has been made to open a DFS exit path control file.</span></span>
<span class="line" id="L752">    DFS_EXIT_PATH_FOUND = <span class="tok-number">0xC000009B</span>,</span>
<span class="line" id="L753">    <span class="tok-comment">/// There are bad blocks (sectors) on the hard disk.</span></span>
<span class="line" id="L754">    DEVICE_DATA_ERROR = <span class="tok-number">0xC000009C</span>,</span>
<span class="line" id="L755">    <span class="tok-comment">/// There is bad cabling, non-termination, or the controller is not able to obtain access to the hard disk.</span></span>
<span class="line" id="L756">    DEVICE_NOT_CONNECTED = <span class="tok-number">0xC000009D</span>,</span>
<span class="line" id="L757">    <span class="tok-comment">/// Virtual memory cannot be freed because the base address is not the base of the region and a region size of zero was specified.</span></span>
<span class="line" id="L758">    FREE_VM_NOT_AT_BASE = <span class="tok-number">0xC000009F</span>,</span>
<span class="line" id="L759">    <span class="tok-comment">/// An attempt was made to free virtual memory that is not allocated.</span></span>
<span class="line" id="L760">    MEMORY_NOT_ALLOCATED = <span class="tok-number">0xC00000A0</span>,</span>
<span class="line" id="L761">    <span class="tok-comment">/// The working set is not big enough to allow the requested pages to be locked.</span></span>
<span class="line" id="L762">    WORKING_SET_QUOTA = <span class="tok-number">0xC00000A1</span>,</span>
<span class="line" id="L763">    <span class="tok-comment">/// {Write Protect Error} The disk cannot be written to because it is write-protected.</span></span>
<span class="line" id="L764">    <span class="tok-comment">/// Remove the write protection from the volume %hs in drive %hs.</span></span>
<span class="line" id="L765">    MEDIA_WRITE_PROTECTED = <span class="tok-number">0xC00000A2</span>,</span>
<span class="line" id="L766">    <span class="tok-comment">/// {Drive Not Ready} The drive is not ready for use; its door might be open.</span></span>
<span class="line" id="L767">    <span class="tok-comment">/// Check drive %hs and make sure that a disk is inserted and that the drive door is closed.</span></span>
<span class="line" id="L768">    DEVICE_NOT_READY = <span class="tok-number">0xC00000A3</span>,</span>
<span class="line" id="L769">    <span class="tok-comment">/// The specified attributes are invalid or are incompatible with the attributes for the group as a whole.</span></span>
<span class="line" id="L770">    INVALID_GROUP_ATTRIBUTES = <span class="tok-number">0xC00000A4</span>,</span>
<span class="line" id="L771">    <span class="tok-comment">/// A specified impersonation level is invalid.</span></span>
<span class="line" id="L772">    <span class="tok-comment">/// Also used to indicate that a required impersonation level was not provided.</span></span>
<span class="line" id="L773">    BAD_IMPERSONATION_LEVEL = <span class="tok-number">0xC00000A5</span>,</span>
<span class="line" id="L774">    <span class="tok-comment">/// An attempt was made to open an anonymous-level token. Anonymous tokens cannot be opened.</span></span>
<span class="line" id="L775">    CANT_OPEN_ANONYMOUS = <span class="tok-number">0xC00000A6</span>,</span>
<span class="line" id="L776">    <span class="tok-comment">/// The validation information class requested was invalid.</span></span>
<span class="line" id="L777">    BAD_VALIDATION_CLASS = <span class="tok-number">0xC00000A7</span>,</span>
<span class="line" id="L778">    <span class="tok-comment">/// The type of a token object is inappropriate for its attempted use.</span></span>
<span class="line" id="L779">    BAD_TOKEN_TYPE = <span class="tok-number">0xC00000A8</span>,</span>
<span class="line" id="L780">    <span class="tok-comment">/// The type of a token object is inappropriate for its attempted use.</span></span>
<span class="line" id="L781">    BAD_MASTER_BOOT_RECORD = <span class="tok-number">0xC00000A9</span>,</span>
<span class="line" id="L782">    <span class="tok-comment">/// An attempt was made to execute an instruction at an unaligned address and the host system does not support unaligned instruction references.</span></span>
<span class="line" id="L783">    INSTRUCTION_MISALIGNMENT = <span class="tok-number">0xC00000AA</span>,</span>
<span class="line" id="L784">    <span class="tok-comment">/// The maximum named pipe instance count has been reached.</span></span>
<span class="line" id="L785">    INSTANCE_NOT_AVAILABLE = <span class="tok-number">0xC00000AB</span>,</span>
<span class="line" id="L786">    <span class="tok-comment">/// An instance of a named pipe cannot be found in the listening state.</span></span>
<span class="line" id="L787">    PIPE_NOT_AVAILABLE = <span class="tok-number">0xC00000AC</span>,</span>
<span class="line" id="L788">    <span class="tok-comment">/// The named pipe is not in the connected or closing state.</span></span>
<span class="line" id="L789">    INVALID_PIPE_STATE = <span class="tok-number">0xC00000AD</span>,</span>
<span class="line" id="L790">    <span class="tok-comment">/// The specified pipe is set to complete operations and there are current I/O operations queued so that it cannot be changed to queue operations.</span></span>
<span class="line" id="L791">    PIPE_BUSY = <span class="tok-number">0xC00000AE</span>,</span>
<span class="line" id="L792">    <span class="tok-comment">/// The specified handle is not open to the server end of the named pipe.</span></span>
<span class="line" id="L793">    ILLEGAL_FUNCTION = <span class="tok-number">0xC00000AF</span>,</span>
<span class="line" id="L794">    <span class="tok-comment">/// The specified named pipe is in the disconnected state.</span></span>
<span class="line" id="L795">    PIPE_DISCONNECTED = <span class="tok-number">0xC00000B0</span>,</span>
<span class="line" id="L796">    <span class="tok-comment">/// The specified named pipe is in the closing state.</span></span>
<span class="line" id="L797">    PIPE_CLOSING = <span class="tok-number">0xC00000B1</span>,</span>
<span class="line" id="L798">    <span class="tok-comment">/// The specified named pipe is in the connected state.</span></span>
<span class="line" id="L799">    PIPE_CONNECTED = <span class="tok-number">0xC00000B2</span>,</span>
<span class="line" id="L800">    <span class="tok-comment">/// The specified named pipe is in the listening state.</span></span>
<span class="line" id="L801">    PIPE_LISTENING = <span class="tok-number">0xC00000B3</span>,</span>
<span class="line" id="L802">    <span class="tok-comment">/// The specified named pipe is not in message mode.</span></span>
<span class="line" id="L803">    INVALID_READ_MODE = <span class="tok-number">0xC00000B4</span>,</span>
<span class="line" id="L804">    <span class="tok-comment">/// {Device Timeout} The specified I/O operation on %hs was not completed before the time-out period expired.</span></span>
<span class="line" id="L805">    IO_TIMEOUT = <span class="tok-number">0xC00000B5</span>,</span>
<span class="line" id="L806">    <span class="tok-comment">/// The specified file has been closed by another process.</span></span>
<span class="line" id="L807">    FILE_FORCED_CLOSED = <span class="tok-number">0xC00000B6</span>,</span>
<span class="line" id="L808">    <span class="tok-comment">/// Profiling is not started.</span></span>
<span class="line" id="L809">    PROFILING_NOT_STARTED = <span class="tok-number">0xC00000B7</span>,</span>
<span class="line" id="L810">    <span class="tok-comment">/// Profiling is not stopped.</span></span>
<span class="line" id="L811">    PROFILING_NOT_STOPPED = <span class="tok-number">0xC00000B8</span>,</span>
<span class="line" id="L812">    <span class="tok-comment">/// The passed ACL did not contain the minimum required information.</span></span>
<span class="line" id="L813">    COULD_NOT_INTERPRET = <span class="tok-number">0xC00000B9</span>,</span>
<span class="line" id="L814">    <span class="tok-comment">/// The file that was specified as a target is a directory, and the caller specified that it could be anything but a directory.</span></span>
<span class="line" id="L815">    FILE_IS_A_DIRECTORY = <span class="tok-number">0xC00000BA</span>,</span>
<span class="line" id="L816">    <span class="tok-comment">/// The request is not supported.</span></span>
<span class="line" id="L817">    NOT_SUPPORTED = <span class="tok-number">0xC00000BB</span>,</span>
<span class="line" id="L818">    <span class="tok-comment">/// This remote computer is not listening.</span></span>
<span class="line" id="L819">    REMOTE_NOT_LISTENING = <span class="tok-number">0xC00000BC</span>,</span>
<span class="line" id="L820">    <span class="tok-comment">/// A duplicate name exists on the network.</span></span>
<span class="line" id="L821">    DUPLICATE_NAME = <span class="tok-number">0xC00000BD</span>,</span>
<span class="line" id="L822">    <span class="tok-comment">/// The network path cannot be located.</span></span>
<span class="line" id="L823">    BAD_NETWORK_PATH = <span class="tok-number">0xC00000BE</span>,</span>
<span class="line" id="L824">    <span class="tok-comment">/// The network is busy.</span></span>
<span class="line" id="L825">    NETWORK_BUSY = <span class="tok-number">0xC00000BF</span>,</span>
<span class="line" id="L826">    <span class="tok-comment">/// This device does not exist.</span></span>
<span class="line" id="L827">    DEVICE_DOES_NOT_EXIST = <span class="tok-number">0xC00000C0</span>,</span>
<span class="line" id="L828">    <span class="tok-comment">/// The network BIOS command limit has been reached.</span></span>
<span class="line" id="L829">    TOO_MANY_COMMANDS = <span class="tok-number">0xC00000C1</span>,</span>
<span class="line" id="L830">    <span class="tok-comment">/// An I/O adapter hardware error has occurred.</span></span>
<span class="line" id="L831">    ADAPTER_HARDWARE_ERROR = <span class="tok-number">0xC00000C2</span>,</span>
<span class="line" id="L832">    <span class="tok-comment">/// The network responded incorrectly.</span></span>
<span class="line" id="L833">    INVALID_NETWORK_RESPONSE = <span class="tok-number">0xC00000C3</span>,</span>
<span class="line" id="L834">    <span class="tok-comment">/// An unexpected network error occurred.</span></span>
<span class="line" id="L835">    UNEXPECTED_NETWORK_ERROR = <span class="tok-number">0xC00000C4</span>,</span>
<span class="line" id="L836">    <span class="tok-comment">/// The remote adapter is not compatible.</span></span>
<span class="line" id="L837">    BAD_REMOTE_ADAPTER = <span class="tok-number">0xC00000C5</span>,</span>
<span class="line" id="L838">    <span class="tok-comment">/// The print queue is full.</span></span>
<span class="line" id="L839">    PRINT_QUEUE_FULL = <span class="tok-number">0xC00000C6</span>,</span>
<span class="line" id="L840">    <span class="tok-comment">/// Space to store the file that is waiting to be printed is not available on the server.</span></span>
<span class="line" id="L841">    NO_SPOOL_SPACE = <span class="tok-number">0xC00000C7</span>,</span>
<span class="line" id="L842">    <span class="tok-comment">/// The requested print file has been canceled.</span></span>
<span class="line" id="L843">    PRINT_CANCELLED = <span class="tok-number">0xC00000C8</span>,</span>
<span class="line" id="L844">    <span class="tok-comment">/// The network name was deleted.</span></span>
<span class="line" id="L845">    NETWORK_NAME_DELETED = <span class="tok-number">0xC00000C9</span>,</span>
<span class="line" id="L846">    <span class="tok-comment">/// Network access is denied.</span></span>
<span class="line" id="L847">    NETWORK_ACCESS_DENIED = <span class="tok-number">0xC00000CA</span>,</span>
<span class="line" id="L848">    <span class="tok-comment">/// {Incorrect Network Resource Type} The specified device type (LPT, for example) conflicts with the actual device type on the remote resource.</span></span>
<span class="line" id="L849">    BAD_DEVICE_TYPE = <span class="tok-number">0xC00000CB</span>,</span>
<span class="line" id="L850">    <span class="tok-comment">/// {Network Name Not Found} The specified share name cannot be found on the remote server.</span></span>
<span class="line" id="L851">    BAD_NETWORK_NAME = <span class="tok-number">0xC00000CC</span>,</span>
<span class="line" id="L852">    <span class="tok-comment">/// The name limit for the network adapter card of the local computer was exceeded.</span></span>
<span class="line" id="L853">    TOO_MANY_NAMES = <span class="tok-number">0xC00000CD</span>,</span>
<span class="line" id="L854">    <span class="tok-comment">/// The network BIOS session limit was exceeded.</span></span>
<span class="line" id="L855">    TOO_MANY_SESSIONS = <span class="tok-number">0xC00000CE</span>,</span>
<span class="line" id="L856">    <span class="tok-comment">/// File sharing has been temporarily paused.</span></span>
<span class="line" id="L857">    SHARING_PAUSED = <span class="tok-number">0xC00000CF</span>,</span>
<span class="line" id="L858">    <span class="tok-comment">/// No more connections can be made to this remote computer at this time because the computer has already accepted the maximum number of connections.</span></span>
<span class="line" id="L859">    REQUEST_NOT_ACCEPTED = <span class="tok-number">0xC00000D0</span>,</span>
<span class="line" id="L860">    <span class="tok-comment">/// Print or disk redirection is temporarily paused.</span></span>
<span class="line" id="L861">    REDIRECTOR_PAUSED = <span class="tok-number">0xC00000D1</span>,</span>
<span class="line" id="L862">    <span class="tok-comment">/// A network data fault occurred.</span></span>
<span class="line" id="L863">    NET_WRITE_FAULT = <span class="tok-number">0xC00000D2</span>,</span>
<span class="line" id="L864">    <span class="tok-comment">/// The number of active profiling objects is at the maximum and no more can be started.</span></span>
<span class="line" id="L865">    PROFILING_AT_LIMIT = <span class="tok-number">0xC00000D3</span>,</span>
<span class="line" id="L866">    <span class="tok-comment">/// {Incorrect Volume} The destination file of a rename request is located on a different device than the source of the rename request.</span></span>
<span class="line" id="L867">    NOT_SAME_DEVICE = <span class="tok-number">0xC00000D4</span>,</span>
<span class="line" id="L868">    <span class="tok-comment">/// The specified file has been renamed and thus cannot be modified.</span></span>
<span class="line" id="L869">    FILE_RENAMED = <span class="tok-number">0xC00000D5</span>,</span>
<span class="line" id="L870">    <span class="tok-comment">/// {Network Request Timeout} The session with a remote server has been disconnected because the time-out interval for a request has expired.</span></span>
<span class="line" id="L871">    VIRTUAL_CIRCUIT_CLOSED = <span class="tok-number">0xC00000D6</span>,</span>
<span class="line" id="L872">    <span class="tok-comment">/// Indicates an attempt was made to operate on the security of an object that does not have security associated with it.</span></span>
<span class="line" id="L873">    NO_SECURITY_ON_OBJECT = <span class="tok-number">0xC00000D7</span>,</span>
<span class="line" id="L874">    <span class="tok-comment">/// Used to indicate that an operation cannot continue without blocking for I/O.</span></span>
<span class="line" id="L875">    CANT_WAIT = <span class="tok-number">0xC00000D8</span>,</span>
<span class="line" id="L876">    <span class="tok-comment">/// Used to indicate that a read operation was done on an empty pipe.</span></span>
<span class="line" id="L877">    PIPE_EMPTY = <span class="tok-number">0xC00000D9</span>,</span>
<span class="line" id="L878">    <span class="tok-comment">/// Configuration information could not be read from the domain controller, either because the machine is unavailable or access has been denied.</span></span>
<span class="line" id="L879">    CANT_ACCESS_DOMAIN_INFO = <span class="tok-number">0xC00000DA</span>,</span>
<span class="line" id="L880">    <span class="tok-comment">/// Indicates that a thread attempted to terminate itself by default (called NtTerminateThread with NULL) and it was the last thread in the current process.</span></span>
<span class="line" id="L881">    CANT_TERMINATE_SELF = <span class="tok-number">0xC00000DB</span>,</span>
<span class="line" id="L882">    <span class="tok-comment">/// Indicates the Sam Server was in the wrong state to perform the desired operation.</span></span>
<span class="line" id="L883">    INVALID_SERVER_STATE = <span class="tok-number">0xC00000DC</span>,</span>
<span class="line" id="L884">    <span class="tok-comment">/// Indicates the domain was in the wrong state to perform the desired operation.</span></span>
<span class="line" id="L885">    INVALID_DOMAIN_STATE = <span class="tok-number">0xC00000DD</span>,</span>
<span class="line" id="L886">    <span class="tok-comment">/// This operation is only allowed for the primary domain controller of the domain.</span></span>
<span class="line" id="L887">    INVALID_DOMAIN_ROLE = <span class="tok-number">0xC00000DE</span>,</span>
<span class="line" id="L888">    <span class="tok-comment">/// The specified domain did not exist.</span></span>
<span class="line" id="L889">    NO_SUCH_DOMAIN = <span class="tok-number">0xC00000DF</span>,</span>
<span class="line" id="L890">    <span class="tok-comment">/// The specified domain already exists.</span></span>
<span class="line" id="L891">    DOMAIN_EXISTS = <span class="tok-number">0xC00000E0</span>,</span>
<span class="line" id="L892">    <span class="tok-comment">/// An attempt was made to exceed the limit on the number of domains per server for this release.</span></span>
<span class="line" id="L893">    DOMAIN_LIMIT_EXCEEDED = <span class="tok-number">0xC00000E1</span>,</span>
<span class="line" id="L894">    <span class="tok-comment">/// An error status returned when the opportunistic lock (oplock) request is denied.</span></span>
<span class="line" id="L895">    OPLOCK_NOT_GRANTED = <span class="tok-number">0xC00000E2</span>,</span>
<span class="line" id="L896">    <span class="tok-comment">/// An error status returned when an invalid opportunistic lock (oplock) acknowledgment is received by a file system.</span></span>
<span class="line" id="L897">    INVALID_OPLOCK_PROTOCOL = <span class="tok-number">0xC00000E3</span>,</span>
<span class="line" id="L898">    <span class="tok-comment">/// This error indicates that the requested operation cannot be completed due to a catastrophic media failure or an on-disk data structure corruption.</span></span>
<span class="line" id="L899">    INTERNAL_DB_CORRUPTION = <span class="tok-number">0xC00000E4</span>,</span>
<span class="line" id="L900">    <span class="tok-comment">/// An internal error occurred.</span></span>
<span class="line" id="L901">    INTERNAL_ERROR = <span class="tok-number">0xC00000E5</span>,</span>
<span class="line" id="L902">    <span class="tok-comment">/// Indicates generic access types were contained in an access mask which should already be mapped to non-generic access types.</span></span>
<span class="line" id="L903">    GENERIC_NOT_MAPPED = <span class="tok-number">0xC00000E6</span>,</span>
<span class="line" id="L904">    <span class="tok-comment">/// Indicates a security descriptor is not in the necessary format (absolute or self-relative).</span></span>
<span class="line" id="L905">    BAD_DESCRIPTOR_FORMAT = <span class="tok-number">0xC00000E7</span>,</span>
<span class="line" id="L906">    <span class="tok-comment">/// An access to a user buffer failed at an expected point in time.</span></span>
<span class="line" id="L907">    <span class="tok-comment">/// This code is defined because the caller does not want to accept STATUS_ACCESS_VIOLATION in its filter.</span></span>
<span class="line" id="L908">    INVALID_USER_BUFFER = <span class="tok-number">0xC00000E8</span>,</span>
<span class="line" id="L909">    <span class="tok-comment">/// If an I/O error that is not defined in the standard FsRtl filter is returned, it is converted to the following error, which is guaranteed to be in the filter.</span></span>
<span class="line" id="L910">    <span class="tok-comment">/// In this case, information is lost; however, the filter correctly handles the exception.</span></span>
<span class="line" id="L911">    UNEXPECTED_IO_ERROR = <span class="tok-number">0xC00000E9</span>,</span>
<span class="line" id="L912">    <span class="tok-comment">/// If an MM error that is not defined in the standard FsRtl filter is returned, it is converted to one of the following errors, which are guaranteed to be in the filter.</span></span>
<span class="line" id="L913">    <span class="tok-comment">/// In this case, information is lost; however, the filter correctly handles the exception.</span></span>
<span class="line" id="L914">    UNEXPECTED_MM_CREATE_ERR = <span class="tok-number">0xC00000EA</span>,</span>
<span class="line" id="L915">    <span class="tok-comment">/// If an MM error that is not defined in the standard FsRtl filter is returned, it is converted to one of the following errors, which are guaranteed to be in the filter.</span></span>
<span class="line" id="L916">    <span class="tok-comment">/// In this case, information is lost; however, the filter correctly handles the exception.</span></span>
<span class="line" id="L917">    UNEXPECTED_MM_MAP_ERROR = <span class="tok-number">0xC00000EB</span>,</span>
<span class="line" id="L918">    <span class="tok-comment">/// If an MM error that is not defined in the standard FsRtl filter is returned, it is converted to one of the following errors, which are guaranteed to be in the filter.</span></span>
<span class="line" id="L919">    <span class="tok-comment">/// In this case, information is lost; however, the filter correctly handles the exception.</span></span>
<span class="line" id="L920">    UNEXPECTED_MM_EXTEND_ERR = <span class="tok-number">0xC00000EC</span>,</span>
<span class="line" id="L921">    <span class="tok-comment">/// The requested action is restricted for use by logon processes only.</span></span>
<span class="line" id="L922">    <span class="tok-comment">/// The calling process has not registered as a logon process.</span></span>
<span class="line" id="L923">    NOT_LOGON_PROCESS = <span class="tok-number">0xC00000ED</span>,</span>
<span class="line" id="L924">    <span class="tok-comment">/// An attempt has been made to start a new session manager or LSA logon session by using an ID that is already in use.</span></span>
<span class="line" id="L925">    LOGON_SESSION_EXISTS = <span class="tok-number">0xC00000EE</span>,</span>
<span class="line" id="L926">    <span class="tok-comment">/// An invalid parameter was passed to a service or function as the first argument.</span></span>
<span class="line" id="L927">    INVALID_PARAMETER_1 = <span class="tok-number">0xC00000EF</span>,</span>
<span class="line" id="L928">    <span class="tok-comment">/// An invalid parameter was passed to a service or function as the second argument.</span></span>
<span class="line" id="L929">    INVALID_PARAMETER_2 = <span class="tok-number">0xC00000F0</span>,</span>
<span class="line" id="L930">    <span class="tok-comment">/// An invalid parameter was passed to a service or function as the third argument.</span></span>
<span class="line" id="L931">    INVALID_PARAMETER_3 = <span class="tok-number">0xC00000F1</span>,</span>
<span class="line" id="L932">    <span class="tok-comment">/// An invalid parameter was passed to a service or function as the fourth argument.</span></span>
<span class="line" id="L933">    INVALID_PARAMETER_4 = <span class="tok-number">0xC00000F2</span>,</span>
<span class="line" id="L934">    <span class="tok-comment">/// An invalid parameter was passed to a service or function as the fifth argument.</span></span>
<span class="line" id="L935">    INVALID_PARAMETER_5 = <span class="tok-number">0xC00000F3</span>,</span>
<span class="line" id="L936">    <span class="tok-comment">/// An invalid parameter was passed to a service or function as the sixth argument.</span></span>
<span class="line" id="L937">    INVALID_PARAMETER_6 = <span class="tok-number">0xC00000F4</span>,</span>
<span class="line" id="L938">    <span class="tok-comment">/// An invalid parameter was passed to a service or function as the seventh argument.</span></span>
<span class="line" id="L939">    INVALID_PARAMETER_7 = <span class="tok-number">0xC00000F5</span>,</span>
<span class="line" id="L940">    <span class="tok-comment">/// An invalid parameter was passed to a service or function as the eighth argument.</span></span>
<span class="line" id="L941">    INVALID_PARAMETER_8 = <span class="tok-number">0xC00000F6</span>,</span>
<span class="line" id="L942">    <span class="tok-comment">/// An invalid parameter was passed to a service or function as the ninth argument.</span></span>
<span class="line" id="L943">    INVALID_PARAMETER_9 = <span class="tok-number">0xC00000F7</span>,</span>
<span class="line" id="L944">    <span class="tok-comment">/// An invalid parameter was passed to a service or function as the tenth argument.</span></span>
<span class="line" id="L945">    INVALID_PARAMETER_10 = <span class="tok-number">0xC00000F8</span>,</span>
<span class="line" id="L946">    <span class="tok-comment">/// An invalid parameter was passed to a service or function as the eleventh argument.</span></span>
<span class="line" id="L947">    INVALID_PARAMETER_11 = <span class="tok-number">0xC00000F9</span>,</span>
<span class="line" id="L948">    <span class="tok-comment">/// An invalid parameter was passed to a service or function as the twelfth argument.</span></span>
<span class="line" id="L949">    INVALID_PARAMETER_12 = <span class="tok-number">0xC00000FA</span>,</span>
<span class="line" id="L950">    <span class="tok-comment">/// An attempt was made to access a network file, but the network software was not yet started.</span></span>
<span class="line" id="L951">    REDIRECTOR_NOT_STARTED = <span class="tok-number">0xC00000FB</span>,</span>
<span class="line" id="L952">    <span class="tok-comment">/// An attempt was made to start the redirector, but the redirector has already been started.</span></span>
<span class="line" id="L953">    REDIRECTOR_STARTED = <span class="tok-number">0xC00000FC</span>,</span>
<span class="line" id="L954">    <span class="tok-comment">/// A new guard page for the stack cannot be created.</span></span>
<span class="line" id="L955">    STACK_OVERFLOW = <span class="tok-number">0xC00000FD</span>,</span>
<span class="line" id="L956">    <span class="tok-comment">/// A specified authentication package is unknown.</span></span>
<span class="line" id="L957">    NO_SUCH_PACKAGE = <span class="tok-number">0xC00000FE</span>,</span>
<span class="line" id="L958">    <span class="tok-comment">/// A malformed function table was encountered during an unwind operation.</span></span>
<span class="line" id="L959">    BAD_FUNCTION_TABLE = <span class="tok-number">0xC00000FF</span>,</span>
<span class="line" id="L960">    <span class="tok-comment">/// Indicates the specified environment variable name was not found in the specified environment block.</span></span>
<span class="line" id="L961">    VARIABLE_NOT_FOUND = <span class="tok-number">0xC0000100</span>,</span>
<span class="line" id="L962">    <span class="tok-comment">/// Indicates that the directory trying to be deleted is not empty.</span></span>
<span class="line" id="L963">    DIRECTORY_NOT_EMPTY = <span class="tok-number">0xC0000101</span>,</span>
<span class="line" id="L964">    <span class="tok-comment">/// {Corrupt File} The file or directory %hs is corrupt and unreadable. Run the Chkdsk utility.</span></span>
<span class="line" id="L965">    FILE_CORRUPT_ERROR = <span class="tok-number">0xC0000102</span>,</span>
<span class="line" id="L966">    <span class="tok-comment">/// A requested opened file is not a directory.</span></span>
<span class="line" id="L967">    NOT_A_DIRECTORY = <span class="tok-number">0xC0000103</span>,</span>
<span class="line" id="L968">    <span class="tok-comment">/// The logon session is not in a state that is consistent with the requested operation.</span></span>
<span class="line" id="L969">    BAD_LOGON_SESSION_STATE = <span class="tok-number">0xC0000104</span>,</span>
<span class="line" id="L970">    <span class="tok-comment">/// An internal LSA error has occurred.</span></span>
<span class="line" id="L971">    <span class="tok-comment">/// An authentication package has requested the creation of a logon session but the ID of an already existing logon session has been specified.</span></span>
<span class="line" id="L972">    LOGON_SESSION_COLLISION = <span class="tok-number">0xC0000105</span>,</span>
<span class="line" id="L973">    <span class="tok-comment">/// A specified name string is too long for its intended use.</span></span>
<span class="line" id="L974">    NAME_TOO_LONG = <span class="tok-number">0xC0000106</span>,</span>
<span class="line" id="L975">    <span class="tok-comment">/// The user attempted to force close the files on a redirected drive, but there were opened files on the drive, and the user did not specify a sufficient level of force.</span></span>
<span class="line" id="L976">    FILES_OPEN = <span class="tok-number">0xC0000107</span>,</span>
<span class="line" id="L977">    <span class="tok-comment">/// The user attempted to force close the files on a redirected drive, but there were opened directories on the drive, and the user did not specify a sufficient level of force.</span></span>
<span class="line" id="L978">    CONNECTION_IN_USE = <span class="tok-number">0xC0000108</span>,</span>
<span class="line" id="L979">    <span class="tok-comment">/// RtlFindMessage could not locate the requested message ID in the message table resource.</span></span>
<span class="line" id="L980">    MESSAGE_NOT_FOUND = <span class="tok-number">0xC0000109</span>,</span>
<span class="line" id="L981">    <span class="tok-comment">/// An attempt was made to duplicate an object handle into or out of an exiting process.</span></span>
<span class="line" id="L982">    PROCESS_IS_TERMINATING = <span class="tok-number">0xC000010A</span>,</span>
<span class="line" id="L983">    <span class="tok-comment">/// Indicates an invalid value has been provided for the LogonType requested.</span></span>
<span class="line" id="L984">    INVALID_LOGON_TYPE = <span class="tok-number">0xC000010B</span>,</span>
<span class="line" id="L985">    <span class="tok-comment">/// Indicates that an attempt was made to assign protection to a file system file or directory and one of the SIDs in the security descriptor could not be translated into a GUID that could be stored by the file system.</span></span>
<span class="line" id="L986">    <span class="tok-comment">/// This causes the protection attempt to fail, which might cause a file creation attempt to fail.</span></span>
<span class="line" id="L987">    NO_GUID_TRANSLATION = <span class="tok-number">0xC000010C</span>,</span>
<span class="line" id="L988">    <span class="tok-comment">/// Indicates that an attempt has been made to impersonate via a named pipe that has not yet been read from.</span></span>
<span class="line" id="L989">    CANNOT_IMPERSONATE = <span class="tok-number">0xC000010D</span>,</span>
<span class="line" id="L990">    <span class="tok-comment">/// Indicates that the specified image is already loaded.</span></span>
<span class="line" id="L991">    IMAGE_ALREADY_LOADED = <span class="tok-number">0xC000010E</span>,</span>
<span class="line" id="L992">    <span class="tok-comment">/// Indicates that an attempt was made to change the size of the LDT for a process that has no LDT.</span></span>
<span class="line" id="L993">    NO_LDT = <span class="tok-number">0xC0000117</span>,</span>
<span class="line" id="L994">    <span class="tok-comment">/// Indicates that an attempt was made to grow an LDT by setting its size, or that the size was not an even number of selectors.</span></span>
<span class="line" id="L995">    INVALID_LDT_SIZE = <span class="tok-number">0xC0000118</span>,</span>
<span class="line" id="L996">    <span class="tok-comment">/// Indicates that the starting value for the LDT information was not an integral multiple of the selector size.</span></span>
<span class="line" id="L997">    INVALID_LDT_OFFSET = <span class="tok-number">0xC0000119</span>,</span>
<span class="line" id="L998">    <span class="tok-comment">/// Indicates that the user supplied an invalid descriptor when trying to set up LDT descriptors.</span></span>
<span class="line" id="L999">    INVALID_LDT_DESCRIPTOR = <span class="tok-number">0xC000011A</span>,</span>
<span class="line" id="L1000">    <span class="tok-comment">/// The specified image file did not have the correct format. It appears to be NE format.</span></span>
<span class="line" id="L1001">    INVALID_IMAGE_NE_FORMAT = <span class="tok-number">0xC000011B</span>,</span>
<span class="line" id="L1002">    <span class="tok-comment">/// Indicates that the transaction state of a registry subtree is incompatible with the requested operation.</span></span>
<span class="line" id="L1003">    <span class="tok-comment">/// For example, a request has been made to start a new transaction with one already in progress, or a request has been made to apply a transaction when one is not currently in progress.</span></span>
<span class="line" id="L1004">    RXACT_INVALID_STATE = <span class="tok-number">0xC000011C</span>,</span>
<span class="line" id="L1005">    <span class="tok-comment">/// Indicates an error has occurred during a registry transaction commit.</span></span>
<span class="line" id="L1006">    <span class="tok-comment">/// The database has been left in an unknown, but probably inconsistent, state.</span></span>
<span class="line" id="L1007">    <span class="tok-comment">/// The state of the registry transaction is left as COMMITTING.</span></span>
<span class="line" id="L1008">    RXACT_COMMIT_FAILURE = <span class="tok-number">0xC000011D</span>,</span>
<span class="line" id="L1009">    <span class="tok-comment">/// An attempt was made to map a file of size zero with the maximum size specified as zero.</span></span>
<span class="line" id="L1010">    MAPPED_FILE_SIZE_ZERO = <span class="tok-number">0xC000011E</span>,</span>
<span class="line" id="L1011">    <span class="tok-comment">/// Too many files are opened on a remote server.</span></span>
<span class="line" id="L1012">    <span class="tok-comment">/// This error should only be returned by the Windows redirector on a remote drive.</span></span>
<span class="line" id="L1013">    TOO_MANY_OPENED_FILES = <span class="tok-number">0xC000011F</span>,</span>
<span class="line" id="L1014">    <span class="tok-comment">/// The I/O request was canceled.</span></span>
<span class="line" id="L1015">    CANCELLED = <span class="tok-number">0xC0000120</span>,</span>
<span class="line" id="L1016">    <span class="tok-comment">/// An attempt has been made to remove a file or directory that cannot be deleted.</span></span>
<span class="line" id="L1017">    CANNOT_DELETE = <span class="tok-number">0xC0000121</span>,</span>
<span class="line" id="L1018">    <span class="tok-comment">/// Indicates a name that was specified as a remote computer name is syntactically invalid.</span></span>
<span class="line" id="L1019">    INVALID_COMPUTER_NAME = <span class="tok-number">0xC0000122</span>,</span>
<span class="line" id="L1020">    <span class="tok-comment">/// An I/O request other than close was performed on a file after it was deleted, which can only happen to a request that did not complete before the last handle was closed via NtClose.</span></span>
<span class="line" id="L1021">    FILE_DELETED = <span class="tok-number">0xC0000123</span>,</span>
<span class="line" id="L1022">    <span class="tok-comment">/// Indicates an operation that is incompatible with built-in accounts has been attempted on a built-in (special) SAM account. For example, built-in accounts cannot be deleted.</span></span>
<span class="line" id="L1023">    SPECIAL_ACCOUNT = <span class="tok-number">0xC0000124</span>,</span>
<span class="line" id="L1024">    <span class="tok-comment">/// The operation requested cannot be performed on the specified group because it is a built-in special group.</span></span>
<span class="line" id="L1025">    SPECIAL_GROUP = <span class="tok-number">0xC0000125</span>,</span>
<span class="line" id="L1026">    <span class="tok-comment">/// The operation requested cannot be performed on the specified user because it is a built-in special user.</span></span>
<span class="line" id="L1027">    SPECIAL_USER = <span class="tok-number">0xC0000126</span>,</span>
<span class="line" id="L1028">    <span class="tok-comment">/// Indicates a member cannot be removed from a group because the group is currently the member's primary group.</span></span>
<span class="line" id="L1029">    MEMBERS_PRIMARY_GROUP = <span class="tok-number">0xC0000127</span>,</span>
<span class="line" id="L1030">    <span class="tok-comment">/// An I/O request other than close and several other special case operations was attempted using a file object that had already been closed.</span></span>
<span class="line" id="L1031">    FILE_CLOSED = <span class="tok-number">0xC0000128</span>,</span>
<span class="line" id="L1032">    <span class="tok-comment">/// Indicates a process has too many threads to perform the requested action.</span></span>
<span class="line" id="L1033">    <span class="tok-comment">/// For example, assignment of a primary token can be performed only when a process has zero or one threads.</span></span>
<span class="line" id="L1034">    TOO_MANY_THREADS = <span class="tok-number">0xC0000129</span>,</span>
<span class="line" id="L1035">    <span class="tok-comment">/// An attempt was made to operate on a thread within a specific process, but the specified thread is not in the specified process.</span></span>
<span class="line" id="L1036">    THREAD_NOT_IN_PROCESS = <span class="tok-number">0xC000012A</span>,</span>
<span class="line" id="L1037">    <span class="tok-comment">/// An attempt was made to establish a token for use as a primary token but the token is already in use.</span></span>
<span class="line" id="L1038">    <span class="tok-comment">/// A token can only be the primary token of one process at a time.</span></span>
<span class="line" id="L1039">    TOKEN_ALREADY_IN_USE = <span class="tok-number">0xC000012B</span>,</span>
<span class="line" id="L1040">    <span class="tok-comment">/// The page file quota was exceeded.</span></span>
<span class="line" id="L1041">    PAGEFILE_QUOTA_EXCEEDED = <span class="tok-number">0xC000012C</span>,</span>
<span class="line" id="L1042">    <span class="tok-comment">/// {Out of Virtual Memory} Your system is low on virtual memory.</span></span>
<span class="line" id="L1043">    <span class="tok-comment">/// To ensure that Windows runs correctly, increase the size of your virtual memory paging file. For more information, see Help.</span></span>
<span class="line" id="L1044">    COMMITMENT_LIMIT = <span class="tok-number">0xC000012D</span>,</span>
<span class="line" id="L1045">    <span class="tok-comment">/// The specified image file did not have the correct format: it appears to be LE format.</span></span>
<span class="line" id="L1046">    INVALID_IMAGE_LE_FORMAT = <span class="tok-number">0xC000012E</span>,</span>
<span class="line" id="L1047">    <span class="tok-comment">/// The specified image file did not have the correct format: it did not have an initial MZ.</span></span>
<span class="line" id="L1048">    INVALID_IMAGE_NOT_MZ = <span class="tok-number">0xC000012F</span>,</span>
<span class="line" id="L1049">    <span class="tok-comment">/// The specified image file did not have the correct format: it did not have a proper e_lfarlc in the MZ header.</span></span>
<span class="line" id="L1050">    INVALID_IMAGE_PROTECT = <span class="tok-number">0xC0000130</span>,</span>
<span class="line" id="L1051">    <span class="tok-comment">/// The specified image file did not have the correct format: it appears to be a 16-bit Windows image.</span></span>
<span class="line" id="L1052">    INVALID_IMAGE_WIN_16 = <span class="tok-number">0xC0000131</span>,</span>
<span class="line" id="L1053">    <span class="tok-comment">/// The Netlogon service cannot start because another Netlogon service running in the domain conflicts with the specified role.</span></span>
<span class="line" id="L1054">    LOGON_SERVER_CONFLICT = <span class="tok-number">0xC0000132</span>,</span>
<span class="line" id="L1055">    <span class="tok-comment">/// The time at the primary domain controller is different from the time at the backup domain controller or member server by too large an amount.</span></span>
<span class="line" id="L1056">    TIME_DIFFERENCE_AT_DC = <span class="tok-number">0xC0000133</span>,</span>
<span class="line" id="L1057">    <span class="tok-comment">/// On applicable Windows Server releases, the SAM database is significantly out of synchronization with the copy on the domain controller. A complete synchronization is required.</span></span>
<span class="line" id="L1058">    SYNCHRONIZATION_REQUIRED = <span class="tok-number">0xC0000134</span>,</span>
<span class="line" id="L1059">    <span class="tok-comment">/// {Unable To Locate Component} This application has failed to start because %hs was not found.</span></span>
<span class="line" id="L1060">    <span class="tok-comment">/// Reinstalling the application might fix this problem.</span></span>
<span class="line" id="L1061">    DLL_NOT_FOUND = <span class="tok-number">0xC0000135</span>,</span>
<span class="line" id="L1062">    <span class="tok-comment">/// The NtCreateFile API failed. This error should never be returned to an application; it is a place holder for the Windows LAN Manager Redirector to use in its internal error-mapping routines.</span></span>
<span class="line" id="L1063">    OPEN_FAILED = <span class="tok-number">0xC0000136</span>,</span>
<span class="line" id="L1064">    <span class="tok-comment">/// {Privilege Failed} The I/O permissions for the process could not be changed.</span></span>
<span class="line" id="L1065">    IO_PRIVILEGE_FAILED = <span class="tok-number">0xC0000137</span>,</span>
<span class="line" id="L1066">    <span class="tok-comment">/// {Ordinal Not Found} The ordinal %ld could not be located in the dynamic link library %hs.</span></span>
<span class="line" id="L1067">    ORDINAL_NOT_FOUND = <span class="tok-number">0xC0000138</span>,</span>
<span class="line" id="L1068">    <span class="tok-comment">/// {Entry Point Not Found} The procedure entry point %hs could not be located in the dynamic link library %hs.</span></span>
<span class="line" id="L1069">    ENTRYPOINT_NOT_FOUND = <span class="tok-number">0xC0000139</span>,</span>
<span class="line" id="L1070">    <span class="tok-comment">/// {Application Exit by CTRL+C} The application terminated as a result of a CTRL+C.</span></span>
<span class="line" id="L1071">    CONTROL_C_EXIT = <span class="tok-number">0xC000013A</span>,</span>
<span class="line" id="L1072">    <span class="tok-comment">/// {Virtual Circuit Closed} The network transport on your computer has closed a network connection.</span></span>
<span class="line" id="L1073">    <span class="tok-comment">/// There might or might not be I/O requests outstanding.</span></span>
<span class="line" id="L1074">    LOCAL_DISCONNECT = <span class="tok-number">0xC000013B</span>,</span>
<span class="line" id="L1075">    <span class="tok-comment">/// {Virtual Circuit Closed} The network transport on a remote computer has closed a network connection.</span></span>
<span class="line" id="L1076">    <span class="tok-comment">/// There might or might not be I/O requests outstanding.</span></span>
<span class="line" id="L1077">    REMOTE_DISCONNECT = <span class="tok-number">0xC000013C</span>,</span>
<span class="line" id="L1078">    <span class="tok-comment">/// {Insufficient Resources on Remote Computer} The remote computer has insufficient resources to complete the network request.</span></span>
<span class="line" id="L1079">    <span class="tok-comment">/// For example, the remote computer might not have enough available memory to carry out the request at this time.</span></span>
<span class="line" id="L1080">    REMOTE_RESOURCES = <span class="tok-number">0xC000013D</span>,</span>
<span class="line" id="L1081">    <span class="tok-comment">/// {Virtual Circuit Closed} An existing connection (virtual circuit) has been broken at the remote computer.</span></span>
<span class="line" id="L1082">    <span class="tok-comment">/// There is probably something wrong with the network software protocol or the network hardware on the remote computer.</span></span>
<span class="line" id="L1083">    LINK_FAILED = <span class="tok-number">0xC000013E</span>,</span>
<span class="line" id="L1084">    <span class="tok-comment">/// {Virtual Circuit Closed} The network transport on your computer has closed a network connection because it had to wait too long for a response from the remote computer.</span></span>
<span class="line" id="L1085">    LINK_TIMEOUT = <span class="tok-number">0xC000013F</span>,</span>
<span class="line" id="L1086">    <span class="tok-comment">/// The connection handle that was given to the transport was invalid.</span></span>
<span class="line" id="L1087">    INVALID_CONNECTION = <span class="tok-number">0xC0000140</span>,</span>
<span class="line" id="L1088">    <span class="tok-comment">/// The address handle that was given to the transport was invalid.</span></span>
<span class="line" id="L1089">    INVALID_ADDRESS = <span class="tok-number">0xC0000141</span>,</span>
<span class="line" id="L1090">    <span class="tok-comment">/// {DLL Initialization Failed} Initialization of the dynamic link library %hs failed. The process is terminating abnormally.</span></span>
<span class="line" id="L1091">    DLL_INIT_FAILED = <span class="tok-number">0xC0000142</span>,</span>
<span class="line" id="L1092">    <span class="tok-comment">/// {Missing System File} The required system file %hs is bad or missing.</span></span>
<span class="line" id="L1093">    MISSING_SYSTEMFILE = <span class="tok-number">0xC0000143</span>,</span>
<span class="line" id="L1094">    <span class="tok-comment">/// {Application Error} The exception %s (0x%08lx) occurred in the application at location 0x%08lx.</span></span>
<span class="line" id="L1095">    UNHANDLED_EXCEPTION = <span class="tok-number">0xC0000144</span>,</span>
<span class="line" id="L1096">    <span class="tok-comment">/// {Application Error} The application failed to initialize properly (0x%lx). Click OK to terminate the application.</span></span>
<span class="line" id="L1097">    APP_INIT_FAILURE = <span class="tok-number">0xC0000145</span>,</span>
<span class="line" id="L1098">    <span class="tok-comment">/// {Unable to Create Paging File} The creation of the paging file %hs failed (%lx). The requested size was %ld.</span></span>
<span class="line" id="L1099">    PAGEFILE_CREATE_FAILED = <span class="tok-number">0xC0000146</span>,</span>
<span class="line" id="L1100">    <span class="tok-comment">/// {No Paging File Specified} No paging file was specified in the system configuration.</span></span>
<span class="line" id="L1101">    NO_PAGEFILE = <span class="tok-number">0xC0000147</span>,</span>
<span class="line" id="L1102">    <span class="tok-comment">/// {Incorrect System Call Level} An invalid level was passed into the specified system call.</span></span>
<span class="line" id="L1103">    INVALID_LEVEL = <span class="tok-number">0xC0000148</span>,</span>
<span class="line" id="L1104">    <span class="tok-comment">/// {Incorrect Password to LAN Manager Server} You specified an incorrect password to a LAN Manager 2.x or MS-NET server.</span></span>
<span class="line" id="L1105">    WRONG_PASSWORD_CORE = <span class="tok-number">0xC0000149</span>,</span>
<span class="line" id="L1106">    <span class="tok-comment">/// {EXCEPTION} A real-mode application issued a floating-point instruction and floating-point hardware is not present.</span></span>
<span class="line" id="L1107">    ILLEGAL_FLOAT_CONTEXT = <span class="tok-number">0xC000014A</span>,</span>
<span class="line" id="L1108">    <span class="tok-comment">/// The pipe operation has failed because the other end of the pipe has been closed.</span></span>
<span class="line" id="L1109">    PIPE_BROKEN = <span class="tok-number">0xC000014B</span>,</span>
<span class="line" id="L1110">    <span class="tok-comment">/// {The Registry Is Corrupt} The structure of one of the files that contains registry data is corrupt; the image of the file in memory is corrupt; or the file could not be recovered because the alternate copy or log was absent or corrupt.</span></span>
<span class="line" id="L1111">    REGISTRY_CORRUPT = <span class="tok-number">0xC000014C</span>,</span>
<span class="line" id="L1112">    <span class="tok-comment">/// An I/O operation initiated by the Registry failed and cannot be recovered.</span></span>
<span class="line" id="L1113">    <span class="tok-comment">/// The registry could not read in, write out, or flush one of the files that contain the system's image of the registry.</span></span>
<span class="line" id="L1114">    REGISTRY_IO_FAILED = <span class="tok-number">0xC000014D</span>,</span>
<span class="line" id="L1115">    <span class="tok-comment">/// An event pair synchronization operation was performed using the thread-specific client/server event pair object, but no event pair object was associated with the thread.</span></span>
<span class="line" id="L1116">    NO_EVENT_PAIR = <span class="tok-number">0xC000014E</span>,</span>
<span class="line" id="L1117">    <span class="tok-comment">/// The volume does not contain a recognized file system.</span></span>
<span class="line" id="L1118">    <span class="tok-comment">/// Be sure that all required file system drivers are loaded and that the volume is not corrupt.</span></span>
<span class="line" id="L1119">    UNRECOGNIZED_VOLUME = <span class="tok-number">0xC000014F</span>,</span>
<span class="line" id="L1120">    <span class="tok-comment">/// No serial device was successfully initialized. The serial driver will unload.</span></span>
<span class="line" id="L1121">    SERIAL_NO_DEVICE_INITED = <span class="tok-number">0xC0000150</span>,</span>
<span class="line" id="L1122">    <span class="tok-comment">/// The specified local group does not exist.</span></span>
<span class="line" id="L1123">    NO_SUCH_ALIAS = <span class="tok-number">0xC0000151</span>,</span>
<span class="line" id="L1124">    <span class="tok-comment">/// The specified account name is not a member of the group.</span></span>
<span class="line" id="L1125">    MEMBER_NOT_IN_ALIAS = <span class="tok-number">0xC0000152</span>,</span>
<span class="line" id="L1126">    <span class="tok-comment">/// The specified account name is already a member of the group.</span></span>
<span class="line" id="L1127">    MEMBER_IN_ALIAS = <span class="tok-number">0xC0000153</span>,</span>
<span class="line" id="L1128">    <span class="tok-comment">/// The specified local group already exists.</span></span>
<span class="line" id="L1129">    ALIAS_EXISTS = <span class="tok-number">0xC0000154</span>,</span>
<span class="line" id="L1130">    <span class="tok-comment">/// A requested type of logon (for example, interactive, network, and service) is not granted by the local security policy of the target system.</span></span>
<span class="line" id="L1131">    <span class="tok-comment">/// Ask the system administrator to grant the necessary form of logon.</span></span>
<span class="line" id="L1132">    LOGON_NOT_GRANTED = <span class="tok-number">0xC0000155</span>,</span>
<span class="line" id="L1133">    <span class="tok-comment">/// The maximum number of secrets that can be stored in a single system was exceeded.</span></span>
<span class="line" id="L1134">    <span class="tok-comment">/// The length and number of secrets is limited to satisfy U.S. State Department export restrictions.</span></span>
<span class="line" id="L1135">    TOO_MANY_SECRETS = <span class="tok-number">0xC0000156</span>,</span>
<span class="line" id="L1136">    <span class="tok-comment">/// The length of a secret exceeds the maximum allowable length.</span></span>
<span class="line" id="L1137">    <span class="tok-comment">/// The length and number of secrets is limited to satisfy U.S. State Department export restrictions.</span></span>
<span class="line" id="L1138">    SECRET_TOO_LONG = <span class="tok-number">0xC0000157</span>,</span>
<span class="line" id="L1139">    <span class="tok-comment">/// The local security authority (LSA) database contains an internal inconsistency.</span></span>
<span class="line" id="L1140">    INTERNAL_DB_ERROR = <span class="tok-number">0xC0000158</span>,</span>
<span class="line" id="L1141">    <span class="tok-comment">/// The requested operation cannot be performed in full-screen mode.</span></span>
<span class="line" id="L1142">    FULLSCREEN_MODE = <span class="tok-number">0xC0000159</span>,</span>
<span class="line" id="L1143">    <span class="tok-comment">/// During a logon attempt, the user's security context accumulated too many security IDs. This is a very unusual situation.</span></span>
<span class="line" id="L1144">    <span class="tok-comment">/// Remove the user from some global or local groups to reduce the number of security IDs to incorporate into the security context.</span></span>
<span class="line" id="L1145">    TOO_MANY_CONTEXT_IDS = <span class="tok-number">0xC000015A</span>,</span>
<span class="line" id="L1146">    <span class="tok-comment">/// A user has requested a type of logon (for example, interactive or network) that has not been granted.</span></span>
<span class="line" id="L1147">    <span class="tok-comment">/// An administrator has control over who can logon interactively and through the network.</span></span>
<span class="line" id="L1148">    LOGON_TYPE_NOT_GRANTED = <span class="tok-number">0xC000015B</span>,</span>
<span class="line" id="L1149">    <span class="tok-comment">/// The system has attempted to load or restore a file into the registry, and the specified file is not in the format of a registry file.</span></span>
<span class="line" id="L1150">    NOT_REGISTRY_FILE = <span class="tok-number">0xC000015C</span>,</span>
<span class="line" id="L1151">    <span class="tok-comment">/// An attempt was made to change a user password in the security account manager without providing the necessary Windows cross-encrypted password.</span></span>
<span class="line" id="L1152">    NT_CROSS_ENCRYPTION_REQUIRED = <span class="tok-number">0xC000015D</span>,</span>
<span class="line" id="L1153">    <span class="tok-comment">/// A domain server has an incorrect configuration.</span></span>
<span class="line" id="L1154">    DOMAIN_CTRLR_CONFIG_ERROR = <span class="tok-number">0xC000015E</span>,</span>
<span class="line" id="L1155">    <span class="tok-comment">/// An attempt was made to explicitly access the secondary copy of information via a device control to the fault tolerance driver and the secondary copy is not present in the system.</span></span>
<span class="line" id="L1156">    FT_MISSING_MEMBER = <span class="tok-number">0xC000015F</span>,</span>
<span class="line" id="L1157">    <span class="tok-comment">/// A configuration registry node that represents a driver service entry was ill-formed and did not contain the required value entries.</span></span>
<span class="line" id="L1158">    ILL_FORMED_SERVICE_ENTRY = <span class="tok-number">0xC0000160</span>,</span>
<span class="line" id="L1159">    <span class="tok-comment">/// An illegal character was encountered.</span></span>
<span class="line" id="L1160">    <span class="tok-comment">/// For a multibyte character set, this includes a lead byte without a succeeding trail byte.</span></span>
<span class="line" id="L1161">    <span class="tok-comment">/// For the Unicode character set this includes the characters 0xFFFF and 0xFFFE.</span></span>
<span class="line" id="L1162">    ILLEGAL_CHARACTER = <span class="tok-number">0xC0000161</span>,</span>
<span class="line" id="L1163">    <span class="tok-comment">/// No mapping for the Unicode character exists in the target multibyte code page.</span></span>
<span class="line" id="L1164">    UNMAPPABLE_CHARACTER = <span class="tok-number">0xC0000162</span>,</span>
<span class="line" id="L1165">    <span class="tok-comment">/// The Unicode character is not defined in the Unicode character set that is installed on the system.</span></span>
<span class="line" id="L1166">    UNDEFINED_CHARACTER = <span class="tok-number">0xC0000163</span>,</span>
<span class="line" id="L1167">    <span class="tok-comment">/// The paging file cannot be created on a floppy disk.</span></span>
<span class="line" id="L1168">    FLOPPY_VOLUME = <span class="tok-number">0xC0000164</span>,</span>
<span class="line" id="L1169">    <span class="tok-comment">/// {Floppy Disk Error} While accessing a floppy disk, an ID address mark was not found.</span></span>
<span class="line" id="L1170">    FLOPPY_ID_MARK_NOT_FOUND = <span class="tok-number">0xC0000165</span>,</span>
<span class="line" id="L1171">    <span class="tok-comment">/// {Floppy Disk Error} While accessing a floppy disk, the track address from the sector ID field was found to be different from the track address that is maintained by the controller.</span></span>
<span class="line" id="L1172">    FLOPPY_WRONG_CYLINDER = <span class="tok-number">0xC0000166</span>,</span>
<span class="line" id="L1173">    <span class="tok-comment">/// {Floppy Disk Error} The floppy disk controller reported an error that is not recognized by the floppy disk driver.</span></span>
<span class="line" id="L1174">    FLOPPY_UNKNOWN_ERROR = <span class="tok-number">0xC0000167</span>,</span>
<span class="line" id="L1175">    <span class="tok-comment">/// {Floppy Disk Error} While accessing a floppy-disk, the controller returned inconsistent results via its registers.</span></span>
<span class="line" id="L1176">    FLOPPY_BAD_REGISTERS = <span class="tok-number">0xC0000168</span>,</span>
<span class="line" id="L1177">    <span class="tok-comment">/// {Hard Disk Error} While accessing the hard disk, a recalibrate operation failed, even after retries.</span></span>
<span class="line" id="L1178">    DISK_RECALIBRATE_FAILED = <span class="tok-number">0xC0000169</span>,</span>
<span class="line" id="L1179">    <span class="tok-comment">/// {Hard Disk Error} While accessing the hard disk, a disk operation failed even after retries.</span></span>
<span class="line" id="L1180">    DISK_OPERATION_FAILED = <span class="tok-number">0xC000016A</span>,</span>
<span class="line" id="L1181">    <span class="tok-comment">/// {Hard Disk Error} While accessing the hard disk, a disk controller reset was needed, but even that failed.</span></span>
<span class="line" id="L1182">    DISK_RESET_FAILED = <span class="tok-number">0xC000016B</span>,</span>
<span class="line" id="L1183">    <span class="tok-comment">/// An attempt was made to open a device that was sharing an interrupt request (IRQ) with other devices.</span></span>
<span class="line" id="L1184">    <span class="tok-comment">/// At least one other device that uses that IRQ was already opened.</span></span>
<span class="line" id="L1185">    <span class="tok-comment">/// Two concurrent opens of devices that share an IRQ and only work via interrupts is not supported for the particular bus type that the devices use.</span></span>
<span class="line" id="L1186">    SHARED_IRQ_BUSY = <span class="tok-number">0xC000016C</span>,</span>
<span class="line" id="L1187">    <span class="tok-comment">/// {FT Orphaning} A disk that is part of a fault-tolerant volume can no longer be accessed.</span></span>
<span class="line" id="L1188">    FT_ORPHANING = <span class="tok-number">0xC000016D</span>,</span>
<span class="line" id="L1189">    <span class="tok-comment">/// The basic input/output system (BIOS) failed to connect a system interrupt to the device or bus for which the device is connected.</span></span>
<span class="line" id="L1190">    BIOS_FAILED_TO_CONNECT_INTERRUPT = <span class="tok-number">0xC000016E</span>,</span>
<span class="line" id="L1191">    <span class="tok-comment">/// The tape could not be partitioned.</span></span>
<span class="line" id="L1192">    PARTITION_FAILURE = <span class="tok-number">0xC0000172</span>,</span>
<span class="line" id="L1193">    <span class="tok-comment">/// When accessing a new tape of a multi-volume partition, the current blocksize is incorrect.</span></span>
<span class="line" id="L1194">    INVALID_BLOCK_LENGTH = <span class="tok-number">0xC0000173</span>,</span>
<span class="line" id="L1195">    <span class="tok-comment">/// The tape partition information could not be found when loading a tape.</span></span>
<span class="line" id="L1196">    DEVICE_NOT_PARTITIONED = <span class="tok-number">0xC0000174</span>,</span>
<span class="line" id="L1197">    <span class="tok-comment">/// An attempt to lock the eject media mechanism failed.</span></span>
<span class="line" id="L1198">    UNABLE_TO_LOCK_MEDIA = <span class="tok-number">0xC0000175</span>,</span>
<span class="line" id="L1199">    <span class="tok-comment">/// An attempt to unload media failed.</span></span>
<span class="line" id="L1200">    UNABLE_TO_UNLOAD_MEDIA = <span class="tok-number">0xC0000176</span>,</span>
<span class="line" id="L1201">    <span class="tok-comment">/// The physical end of tape was detected.</span></span>
<span class="line" id="L1202">    EOM_OVERFLOW = <span class="tok-number">0xC0000177</span>,</span>
<span class="line" id="L1203">    <span class="tok-comment">/// {No Media} There is no media in the drive. Insert media into drive %hs.</span></span>
<span class="line" id="L1204">    NO_MEDIA = <span class="tok-number">0xC0000178</span>,</span>
<span class="line" id="L1205">    <span class="tok-comment">/// A member could not be added to or removed from the local group because the member does not exist.</span></span>
<span class="line" id="L1206">    NO_SUCH_MEMBER = <span class="tok-number">0xC000017A</span>,</span>
<span class="line" id="L1207">    <span class="tok-comment">/// A new member could not be added to a local group because the member has the wrong account type.</span></span>
<span class="line" id="L1208">    INVALID_MEMBER = <span class="tok-number">0xC000017B</span>,</span>
<span class="line" id="L1209">    <span class="tok-comment">/// An illegal operation was attempted on a registry key that has been marked for deletion.</span></span>
<span class="line" id="L1210">    KEY_DELETED = <span class="tok-number">0xC000017C</span>,</span>
<span class="line" id="L1211">    <span class="tok-comment">/// The system could not allocate the required space in a registry log.</span></span>
<span class="line" id="L1212">    NO_LOG_SPACE = <span class="tok-number">0xC000017D</span>,</span>
<span class="line" id="L1213">    <span class="tok-comment">/// Too many SIDs have been specified.</span></span>
<span class="line" id="L1214">    TOO_MANY_SIDS = <span class="tok-number">0xC000017E</span>,</span>
<span class="line" id="L1215">    <span class="tok-comment">/// An attempt was made to change a user password in the security account manager without providing the necessary LM cross-encrypted password.</span></span>
<span class="line" id="L1216">    LM_CROSS_ENCRYPTION_REQUIRED = <span class="tok-number">0xC000017F</span>,</span>
<span class="line" id="L1217">    <span class="tok-comment">/// An attempt was made to create a symbolic link in a registry key that already has subkeys or values.</span></span>
<span class="line" id="L1218">    KEY_HAS_CHILDREN = <span class="tok-number">0xC0000180</span>,</span>
<span class="line" id="L1219">    <span class="tok-comment">/// An attempt was made to create a stable subkey under a volatile parent key.</span></span>
<span class="line" id="L1220">    CHILD_MUST_BE_VOLATILE = <span class="tok-number">0xC0000181</span>,</span>
<span class="line" id="L1221">    <span class="tok-comment">/// The I/O device is configured incorrectly or the configuration parameters to the driver are incorrect.</span></span>
<span class="line" id="L1222">    DEVICE_CONFIGURATION_ERROR = <span class="tok-number">0xC0000182</span>,</span>
<span class="line" id="L1223">    <span class="tok-comment">/// An error was detected between two drivers or within an I/O driver.</span></span>
<span class="line" id="L1224">    DRIVER_INTERNAL_ERROR = <span class="tok-number">0xC0000183</span>,</span>
<span class="line" id="L1225">    <span class="tok-comment">/// The device is not in a valid state to perform this request.</span></span>
<span class="line" id="L1226">    INVALID_DEVICE_STATE = <span class="tok-number">0xC0000184</span>,</span>
<span class="line" id="L1227">    <span class="tok-comment">/// The I/O device reported an I/O error.</span></span>
<span class="line" id="L1228">    IO_DEVICE_ERROR = <span class="tok-number">0xC0000185</span>,</span>
<span class="line" id="L1229">    <span class="tok-comment">/// A protocol error was detected between the driver and the device.</span></span>
<span class="line" id="L1230">    DEVICE_PROTOCOL_ERROR = <span class="tok-number">0xC0000186</span>,</span>
<span class="line" id="L1231">    <span class="tok-comment">/// This operation is only allowed for the primary domain controller of the domain.</span></span>
<span class="line" id="L1232">    BACKUP_CONTROLLER = <span class="tok-number">0xC0000187</span>,</span>
<span class="line" id="L1233">    <span class="tok-comment">/// The log file space is insufficient to support this operation.</span></span>
<span class="line" id="L1234">    LOG_FILE_FULL = <span class="tok-number">0xC0000188</span>,</span>
<span class="line" id="L1235">    <span class="tok-comment">/// A write operation was attempted to a volume after it was dismounted.</span></span>
<span class="line" id="L1236">    TOO_LATE = <span class="tok-number">0xC0000189</span>,</span>
<span class="line" id="L1237">    <span class="tok-comment">/// The workstation does not have a trust secret for the primary domain in the local LSA database.</span></span>
<span class="line" id="L1238">    NO_TRUST_LSA_SECRET = <span class="tok-number">0xC000018A</span>,</span>
<span class="line" id="L1239">    <span class="tok-comment">/// On applicable Windows Server releases, the SAM database does not have a computer account for this workstation trust relationship.</span></span>
<span class="line" id="L1240">    NO_TRUST_SAM_ACCOUNT = <span class="tok-number">0xC000018B</span>,</span>
<span class="line" id="L1241">    <span class="tok-comment">/// The logon request failed because the trust relationship between the primary domain and the trusted domain failed.</span></span>
<span class="line" id="L1242">    TRUSTED_DOMAIN_FAILURE = <span class="tok-number">0xC000018C</span>,</span>
<span class="line" id="L1243">    <span class="tok-comment">/// The logon request failed because the trust relationship between this workstation and the primary domain failed.</span></span>
<span class="line" id="L1244">    TRUSTED_RELATIONSHIP_FAILURE = <span class="tok-number">0xC000018D</span>,</span>
<span class="line" id="L1245">    <span class="tok-comment">/// The Eventlog log file is corrupt.</span></span>
<span class="line" id="L1246">    EVENTLOG_FILE_CORRUPT = <span class="tok-number">0xC000018E</span>,</span>
<span class="line" id="L1247">    <span class="tok-comment">/// No Eventlog log file could be opened. The Eventlog service did not start.</span></span>
<span class="line" id="L1248">    EVENTLOG_CANT_START = <span class="tok-number">0xC000018F</span>,</span>
<span class="line" id="L1249">    <span class="tok-comment">/// The network logon failed. This might be because the validation authority cannot be reached.</span></span>
<span class="line" id="L1250">    TRUST_FAILURE = <span class="tok-number">0xC0000190</span>,</span>
<span class="line" id="L1251">    <span class="tok-comment">/// An attempt was made to acquire a mutant such that its maximum count would have been exceeded.</span></span>
<span class="line" id="L1252">    MUTANT_LIMIT_EXCEEDED = <span class="tok-number">0xC0000191</span>,</span>
<span class="line" id="L1253">    <span class="tok-comment">/// An attempt was made to logon, but the NetLogon service was not started.</span></span>
<span class="line" id="L1254">    NETLOGON_NOT_STARTED = <span class="tok-number">0xC0000192</span>,</span>
<span class="line" id="L1255">    <span class="tok-comment">/// The user account has expired.</span></span>
<span class="line" id="L1256">    ACCOUNT_EXPIRED = <span class="tok-number">0xC0000193</span>,</span>
<span class="line" id="L1257">    <span class="tok-comment">/// {EXCEPTION} Possible deadlock condition.</span></span>
<span class="line" id="L1258">    POSSIBLE_DEADLOCK = <span class="tok-number">0xC0000194</span>,</span>
<span class="line" id="L1259">    <span class="tok-comment">/// Multiple connections to a server or shared resource by the same user, using more than one user name, are not allowed.</span></span>
<span class="line" id="L1260">    <span class="tok-comment">/// Disconnect all previous connections to the server or shared resource and try again.</span></span>
<span class="line" id="L1261">    NETWORK_CREDENTIAL_CONFLICT = <span class="tok-number">0xC0000195</span>,</span>
<span class="line" id="L1262">    <span class="tok-comment">/// An attempt was made to establish a session to a network server, but there are already too many sessions established to that server.</span></span>
<span class="line" id="L1263">    REMOTE_SESSION_LIMIT = <span class="tok-number">0xC0000196</span>,</span>
<span class="line" id="L1264">    <span class="tok-comment">/// The log file has changed between reads.</span></span>
<span class="line" id="L1265">    EVENTLOG_FILE_CHANGED = <span class="tok-number">0xC0000197</span>,</span>
<span class="line" id="L1266">    <span class="tok-comment">/// The account used is an interdomain trust account.</span></span>
<span class="line" id="L1267">    <span class="tok-comment">/// Use your global user account or local user account to access this server.</span></span>
<span class="line" id="L1268">    NOLOGON_INTERDOMAIN_TRUST_ACCOUNT = <span class="tok-number">0xC0000198</span>,</span>
<span class="line" id="L1269">    <span class="tok-comment">/// The account used is a computer account.</span></span>
<span class="line" id="L1270">    <span class="tok-comment">/// Use your global user account or local user account to access this server.</span></span>
<span class="line" id="L1271">    NOLOGON_WORKSTATION_TRUST_ACCOUNT = <span class="tok-number">0xC0000199</span>,</span>
<span class="line" id="L1272">    <span class="tok-comment">/// The account used is a server trust account.</span></span>
<span class="line" id="L1273">    <span class="tok-comment">/// Use your global user account or local user account to access this server.</span></span>
<span class="line" id="L1274">    NOLOGON_SERVER_TRUST_ACCOUNT = <span class="tok-number">0xC000019A</span>,</span>
<span class="line" id="L1275">    <span class="tok-comment">/// The name or SID of the specified domain is inconsistent with the trust information for that domain.</span></span>
<span class="line" id="L1276">    DOMAIN_TRUST_INCONSISTENT = <span class="tok-number">0xC000019B</span>,</span>
<span class="line" id="L1277">    <span class="tok-comment">/// A volume has been accessed for which a file system driver is required that has not yet been loaded.</span></span>
<span class="line" id="L1278">    FS_DRIVER_REQUIRED = <span class="tok-number">0xC000019C</span>,</span>
<span class="line" id="L1279">    <span class="tok-comment">/// Indicates that the specified image is already loaded as a DLL.</span></span>
<span class="line" id="L1280">    IMAGE_ALREADY_LOADED_AS_DLL = <span class="tok-number">0xC000019D</span>,</span>
<span class="line" id="L1281">    <span class="tok-comment">/// Short name settings cannot be changed on this volume due to the global registry setting.</span></span>
<span class="line" id="L1282">    INCOMPATIBLE_WITH_GLOBAL_SHORT_NAME_REGISTRY_SETTING = <span class="tok-number">0xC000019E</span>,</span>
<span class="line" id="L1283">    <span class="tok-comment">/// Short names are not enabled on this volume.</span></span>
<span class="line" id="L1284">    SHORT_NAMES_NOT_ENABLED_ON_VOLUME = <span class="tok-number">0xC000019F</span>,</span>
<span class="line" id="L1285">    <span class="tok-comment">/// The security stream for the given volume is in an inconsistent state. Please run CHKDSK on the volume.</span></span>
<span class="line" id="L1286">    SECURITY_STREAM_IS_INCONSISTENT = <span class="tok-number">0xC00001A0</span>,</span>
<span class="line" id="L1287">    <span class="tok-comment">/// A requested file lock operation cannot be processed due to an invalid byte range.</span></span>
<span class="line" id="L1288">    INVALID_LOCK_RANGE = <span class="tok-number">0xC00001A1</span>,</span>
<span class="line" id="L1289">    <span class="tok-comment">/// The specified access control entry (ACE) contains an invalid condition.</span></span>
<span class="line" id="L1290">    INVALID_ACE_CONDITION = <span class="tok-number">0xC00001A2</span>,</span>
<span class="line" id="L1291">    <span class="tok-comment">/// The subsystem needed to support the image type is not present.</span></span>
<span class="line" id="L1292">    IMAGE_SUBSYSTEM_NOT_PRESENT = <span class="tok-number">0xC00001A3</span>,</span>
<span class="line" id="L1293">    <span class="tok-comment">/// The specified file already has a notification GUID associated with it.</span></span>
<span class="line" id="L1294">    NOTIFICATION_GUID_ALREADY_DEFINED = <span class="tok-number">0xC00001A4</span>,</span>
<span class="line" id="L1295">    <span class="tok-comment">/// A remote open failed because the network open restrictions were not satisfied.</span></span>
<span class="line" id="L1296">    NETWORK_OPEN_RESTRICTION = <span class="tok-number">0xC0000201</span>,</span>
<span class="line" id="L1297">    <span class="tok-comment">/// There is no user session key for the specified logon session.</span></span>
<span class="line" id="L1298">    NO_USER_SESSION_KEY = <span class="tok-number">0xC0000202</span>,</span>
<span class="line" id="L1299">    <span class="tok-comment">/// The remote user session has been deleted.</span></span>
<span class="line" id="L1300">    USER_SESSION_DELETED = <span class="tok-number">0xC0000203</span>,</span>
<span class="line" id="L1301">    <span class="tok-comment">/// Indicates the specified resource language ID cannot be found in the image file.</span></span>
<span class="line" id="L1302">    RESOURCE_LANG_NOT_FOUND = <span class="tok-number">0xC0000204</span>,</span>
<span class="line" id="L1303">    <span class="tok-comment">/// Insufficient server resources exist to complete the request.</span></span>
<span class="line" id="L1304">    INSUFF_SERVER_RESOURCES = <span class="tok-number">0xC0000205</span>,</span>
<span class="line" id="L1305">    <span class="tok-comment">/// The size of the buffer is invalid for the specified operation.</span></span>
<span class="line" id="L1306">    INVALID_BUFFER_SIZE = <span class="tok-number">0xC0000206</span>,</span>
<span class="line" id="L1307">    <span class="tok-comment">/// The transport rejected the specified network address as invalid.</span></span>
<span class="line" id="L1308">    INVALID_ADDRESS_COMPONENT = <span class="tok-number">0xC0000207</span>,</span>
<span class="line" id="L1309">    <span class="tok-comment">/// The transport rejected the specified network address due to invalid use of a wildcard.</span></span>
<span class="line" id="L1310">    INVALID_ADDRESS_WILDCARD = <span class="tok-number">0xC0000208</span>,</span>
<span class="line" id="L1311">    <span class="tok-comment">/// The transport address could not be opened because all the available addresses are in use.</span></span>
<span class="line" id="L1312">    TOO_MANY_ADDRESSES = <span class="tok-number">0xC0000209</span>,</span>
<span class="line" id="L1313">    <span class="tok-comment">/// The transport address could not be opened because it already exists.</span></span>
<span class="line" id="L1314">    ADDRESS_ALREADY_EXISTS = <span class="tok-number">0xC000020A</span>,</span>
<span class="line" id="L1315">    <span class="tok-comment">/// The transport address is now closed.</span></span>
<span class="line" id="L1316">    ADDRESS_CLOSED = <span class="tok-number">0xC000020B</span>,</span>
<span class="line" id="L1317">    <span class="tok-comment">/// The transport connection is now disconnected.</span></span>
<span class="line" id="L1318">    CONNECTION_DISCONNECTED = <span class="tok-number">0xC000020C</span>,</span>
<span class="line" id="L1319">    <span class="tok-comment">/// The transport connection has been reset.</span></span>
<span class="line" id="L1320">    CONNECTION_RESET = <span class="tok-number">0xC000020D</span>,</span>
<span class="line" id="L1321">    <span class="tok-comment">/// The transport cannot dynamically acquire any more nodes.</span></span>
<span class="line" id="L1322">    TOO_MANY_NODES = <span class="tok-number">0xC000020E</span>,</span>
<span class="line" id="L1323">    <span class="tok-comment">/// The transport aborted a pending transaction.</span></span>
<span class="line" id="L1324">    TRANSACTION_ABORTED = <span class="tok-number">0xC000020F</span>,</span>
<span class="line" id="L1325">    <span class="tok-comment">/// The transport timed out a request that is waiting for a response.</span></span>
<span class="line" id="L1326">    TRANSACTION_TIMED_OUT = <span class="tok-number">0xC0000210</span>,</span>
<span class="line" id="L1327">    <span class="tok-comment">/// The transport did not receive a release for a pending response.</span></span>
<span class="line" id="L1328">    TRANSACTION_NO_RELEASE = <span class="tok-number">0xC0000211</span>,</span>
<span class="line" id="L1329">    <span class="tok-comment">/// The transport did not find a transaction that matches the specific token.</span></span>
<span class="line" id="L1330">    TRANSACTION_NO_MATCH = <span class="tok-number">0xC0000212</span>,</span>
<span class="line" id="L1331">    <span class="tok-comment">/// The transport had previously responded to a transaction request.</span></span>
<span class="line" id="L1332">    TRANSACTION_RESPONDED = <span class="tok-number">0xC0000213</span>,</span>
<span class="line" id="L1333">    <span class="tok-comment">/// The transport does not recognize the specified transaction request ID.</span></span>
<span class="line" id="L1334">    TRANSACTION_INVALID_ID = <span class="tok-number">0xC0000214</span>,</span>
<span class="line" id="L1335">    <span class="tok-comment">/// The transport does not recognize the specified transaction request type.</span></span>
<span class="line" id="L1336">    TRANSACTION_INVALID_TYPE = <span class="tok-number">0xC0000215</span>,</span>
<span class="line" id="L1337">    <span class="tok-comment">/// The transport can only process the specified request on the server side of a session.</span></span>
<span class="line" id="L1338">    NOT_SERVER_SESSION = <span class="tok-number">0xC0000216</span>,</span>
<span class="line" id="L1339">    <span class="tok-comment">/// The transport can only process the specified request on the client side of a session.</span></span>
<span class="line" id="L1340">    NOT_CLIENT_SESSION = <span class="tok-number">0xC0000217</span>,</span>
<span class="line" id="L1341">    <span class="tok-comment">/// {Registry File Failure} The registry cannot load the hive (file): %hs or its log or alternate. It is corrupt, absent, or not writable.</span></span>
<span class="line" id="L1342">    CANNOT_LOAD_REGISTRY_FILE = <span class="tok-number">0xC0000218</span>,</span>
<span class="line" id="L1343">    <span class="tok-comment">/// {Unexpected Failure in DebugActiveProcess} An unexpected failure occurred while processing a DebugActiveProcess API request.</span></span>
<span class="line" id="L1344">    <span class="tok-comment">/// Choosing OK will terminate the process, and choosing Cancel will ignore the error.</span></span>
<span class="line" id="L1345">    DEBUG_ATTACH_FAILED = <span class="tok-number">0xC0000219</span>,</span>
<span class="line" id="L1346">    <span class="tok-comment">/// {Fatal System Error} The %hs system process terminated unexpectedly with a status of 0x%08x (0x%08x 0x%08x). The system has been shut down.</span></span>
<span class="line" id="L1347">    SYSTEM_PROCESS_TERMINATED = <span class="tok-number">0xC000021A</span>,</span>
<span class="line" id="L1348">    <span class="tok-comment">/// {Data Not Accepted} The TDI client could not handle the data received during an indication.</span></span>
<span class="line" id="L1349">    DATA_NOT_ACCEPTED = <span class="tok-number">0xC000021B</span>,</span>
<span class="line" id="L1350">    <span class="tok-comment">/// {Unable to Retrieve Browser Server List} The list of servers for this workgroup is not currently available.</span></span>
<span class="line" id="L1351">    NO_BROWSER_SERVERS_FOUND = <span class="tok-number">0xC000021C</span>,</span>
<span class="line" id="L1352">    <span class="tok-comment">/// NTVDM encountered a hard error.</span></span>
<span class="line" id="L1353">    VDM_HARD_ERROR = <span class="tok-number">0xC000021D</span>,</span>
<span class="line" id="L1354">    <span class="tok-comment">/// {Cancel Timeout} The driver %hs failed to complete a canceled I/O request in the allotted time.</span></span>
<span class="line" id="L1355">    DRIVER_CANCEL_TIMEOUT = <span class="tok-number">0xC000021E</span>,</span>
<span class="line" id="L1356">    <span class="tok-comment">/// {Reply Message Mismatch} An attempt was made to reply to an LPC message, but the thread specified by the client ID in the message was not waiting on that message.</span></span>
<span class="line" id="L1357">    REPLY_MESSAGE_MISMATCH = <span class="tok-number">0xC000021F</span>,</span>
<span class="line" id="L1358">    <span class="tok-comment">/// {Mapped View Alignment Incorrect} An attempt was made to map a view of a file, but either the specified base address or the offset into the file were not aligned on the proper allocation granularity.</span></span>
<span class="line" id="L1359">    MAPPED_ALIGNMENT = <span class="tok-number">0xC0000220</span>,</span>
<span class="line" id="L1360">    <span class="tok-comment">/// {Bad Image Checksum} The image %hs is possibly corrupt.</span></span>
<span class="line" id="L1361">    <span class="tok-comment">/// The header checksum does not match the computed checksum.</span></span>
<span class="line" id="L1362">    IMAGE_CHECKSUM_MISMATCH = <span class="tok-number">0xC0000221</span>,</span>
<span class="line" id="L1363">    <span class="tok-comment">/// {Delayed Write Failed} Windows was unable to save all the data for the file %hs. The data has been lost.</span></span>
<span class="line" id="L1364">    <span class="tok-comment">/// This error might be caused by a failure of your computer hardware or network connection. Try to save this file elsewhere.</span></span>
<span class="line" id="L1365">    LOST_WRITEBEHIND_DATA = <span class="tok-number">0xC0000222</span>,</span>
<span class="line" id="L1366">    <span class="tok-comment">/// The parameters passed to the server in the client/server shared memory window were invalid.</span></span>
<span class="line" id="L1367">    <span class="tok-comment">/// Too much data might have been put in the shared memory window.</span></span>
<span class="line" id="L1368">    CLIENT_SERVER_PARAMETERS_INVALID = <span class="tok-number">0xC0000223</span>,</span>
<span class="line" id="L1369">    <span class="tok-comment">/// The user password must be changed before logging on the first time.</span></span>
<span class="line" id="L1370">    PASSWORD_MUST_CHANGE = <span class="tok-number">0xC0000224</span>,</span>
<span class="line" id="L1371">    <span class="tok-comment">/// The object was not found.</span></span>
<span class="line" id="L1372">    NOT_FOUND = <span class="tok-number">0xC0000225</span>,</span>
<span class="line" id="L1373">    <span class="tok-comment">/// The stream is not a tiny stream.</span></span>
<span class="line" id="L1374">    NOT_TINY_STREAM = <span class="tok-number">0xC0000226</span>,</span>
<span class="line" id="L1375">    <span class="tok-comment">/// A transaction recovery failed.</span></span>
<span class="line" id="L1376">    RECOVERY_FAILURE = <span class="tok-number">0xC0000227</span>,</span>
<span class="line" id="L1377">    <span class="tok-comment">/// The request must be handled by the stack overflow code.</span></span>
<span class="line" id="L1378">    STACK_OVERFLOW_READ = <span class="tok-number">0xC0000228</span>,</span>
<span class="line" id="L1379">    <span class="tok-comment">/// A consistency check failed.</span></span>
<span class="line" id="L1380">    FAIL_CHECK = <span class="tok-number">0xC0000229</span>,</span>
<span class="line" id="L1381">    <span class="tok-comment">/// The attempt to insert the ID in the index failed because the ID is already in the index.</span></span>
<span class="line" id="L1382">    DUPLICATE_OBJECTID = <span class="tok-number">0xC000022A</span>,</span>
<span class="line" id="L1383">    <span class="tok-comment">/// The attempt to set the object ID failed because the object already has an ID.</span></span>
<span class="line" id="L1384">    OBJECTID_EXISTS = <span class="tok-number">0xC000022B</span>,</span>
<span class="line" id="L1385">    <span class="tok-comment">/// Internal OFS status codes indicating how an allocation operation is handled.</span></span>
<span class="line" id="L1386">    <span class="tok-comment">/// Either it is retried after the containing oNode is moved or the extent stream is converted to a large stream.</span></span>
<span class="line" id="L1387">    CONVERT_TO_LARGE = <span class="tok-number">0xC000022C</span>,</span>
<span class="line" id="L1388">    <span class="tok-comment">/// The request needs to be retried.</span></span>
<span class="line" id="L1389">    RETRY = <span class="tok-number">0xC000022D</span>,</span>
<span class="line" id="L1390">    <span class="tok-comment">/// The attempt to find the object found an object on the volume that matches by ID; however, it is out of the scope of the handle that is used for the operation.</span></span>
<span class="line" id="L1391">    FOUND_OUT_OF_SCOPE = <span class="tok-number">0xC000022E</span>,</span>
<span class="line" id="L1392">    <span class="tok-comment">/// The bucket array must be grown. Retry the transaction after doing so.</span></span>
<span class="line" id="L1393">    ALLOCATE_BUCKET = <span class="tok-number">0xC000022F</span>,</span>
<span class="line" id="L1394">    <span class="tok-comment">/// The specified property set does not exist on the object.</span></span>
<span class="line" id="L1395">    PROPSET_NOT_FOUND = <span class="tok-number">0xC0000230</span>,</span>
<span class="line" id="L1396">    <span class="tok-comment">/// The user/kernel marshaling buffer has overflowed.</span></span>
<span class="line" id="L1397">    MARSHALL_OVERFLOW = <span class="tok-number">0xC0000231</span>,</span>
<span class="line" id="L1398">    <span class="tok-comment">/// The supplied variant structure contains invalid data.</span></span>
<span class="line" id="L1399">    INVALID_VARIANT = <span class="tok-number">0xC0000232</span>,</span>
<span class="line" id="L1400">    <span class="tok-comment">/// A domain controller for this domain was not found.</span></span>
<span class="line" id="L1401">    DOMAIN_CONTROLLER_NOT_FOUND = <span class="tok-number">0xC0000233</span>,</span>
<span class="line" id="L1402">    <span class="tok-comment">/// The user account has been automatically locked because too many invalid logon attempts or password change attempts have been requested.</span></span>
<span class="line" id="L1403">    ACCOUNT_LOCKED_OUT = <span class="tok-number">0xC0000234</span>,</span>
<span class="line" id="L1404">    <span class="tok-comment">/// NtClose was called on a handle that was protected from close via NtSetInformationObject.</span></span>
<span class="line" id="L1405">    HANDLE_NOT_CLOSABLE = <span class="tok-number">0xC0000235</span>,</span>
<span class="line" id="L1406">    <span class="tok-comment">/// The transport-connection attempt was refused by the remote system.</span></span>
<span class="line" id="L1407">    CONNECTION_REFUSED = <span class="tok-number">0xC0000236</span>,</span>
<span class="line" id="L1408">    <span class="tok-comment">/// The transport connection was gracefully closed.</span></span>
<span class="line" id="L1409">    GRACEFUL_DISCONNECT = <span class="tok-number">0xC0000237</span>,</span>
<span class="line" id="L1410">    <span class="tok-comment">/// The transport endpoint already has an address associated with it.</span></span>
<span class="line" id="L1411">    ADDRESS_ALREADY_ASSOCIATED = <span class="tok-number">0xC0000238</span>,</span>
<span class="line" id="L1412">    <span class="tok-comment">/// An address has not yet been associated with the transport endpoint.</span></span>
<span class="line" id="L1413">    ADDRESS_NOT_ASSOCIATED = <span class="tok-number">0xC0000239</span>,</span>
<span class="line" id="L1414">    <span class="tok-comment">/// An operation was attempted on a nonexistent transport connection.</span></span>
<span class="line" id="L1415">    CONNECTION_INVALID = <span class="tok-number">0xC000023A</span>,</span>
<span class="line" id="L1416">    <span class="tok-comment">/// An invalid operation was attempted on an active transport connection.</span></span>
<span class="line" id="L1417">    CONNECTION_ACTIVE = <span class="tok-number">0xC000023B</span>,</span>
<span class="line" id="L1418">    <span class="tok-comment">/// The remote network is not reachable by the transport.</span></span>
<span class="line" id="L1419">    NETWORK_UNREACHABLE = <span class="tok-number">0xC000023C</span>,</span>
<span class="line" id="L1420">    <span class="tok-comment">/// The remote system is not reachable by the transport.</span></span>
<span class="line" id="L1421">    HOST_UNREACHABLE = <span class="tok-number">0xC000023D</span>,</span>
<span class="line" id="L1422">    <span class="tok-comment">/// The remote system does not support the transport protocol.</span></span>
<span class="line" id="L1423">    PROTOCOL_UNREACHABLE = <span class="tok-number">0xC000023E</span>,</span>
<span class="line" id="L1424">    <span class="tok-comment">/// No service is operating at the destination port of the transport on the remote system.</span></span>
<span class="line" id="L1425">    PORT_UNREACHABLE = <span class="tok-number">0xC000023F</span>,</span>
<span class="line" id="L1426">    <span class="tok-comment">/// The request was aborted.</span></span>
<span class="line" id="L1427">    REQUEST_ABORTED = <span class="tok-number">0xC0000240</span>,</span>
<span class="line" id="L1428">    <span class="tok-comment">/// The transport connection was aborted by the local system.</span></span>
<span class="line" id="L1429">    CONNECTION_ABORTED = <span class="tok-number">0xC0000241</span>,</span>
<span class="line" id="L1430">    <span class="tok-comment">/// The specified buffer contains ill-formed data.</span></span>
<span class="line" id="L1431">    BAD_COMPRESSION_BUFFER = <span class="tok-number">0xC0000242</span>,</span>
<span class="line" id="L1432">    <span class="tok-comment">/// The requested operation cannot be performed on a file with a user mapped section open.</span></span>
<span class="line" id="L1433">    USER_MAPPED_FILE = <span class="tok-number">0xC0000243</span>,</span>
<span class="line" id="L1434">    <span class="tok-comment">/// {Audit Failed} An attempt to generate a security audit failed.</span></span>
<span class="line" id="L1435">    AUDIT_FAILED = <span class="tok-number">0xC0000244</span>,</span>
<span class="line" id="L1436">    <span class="tok-comment">/// The timer resolution was not previously set by the current process.</span></span>
<span class="line" id="L1437">    TIMER_RESOLUTION_NOT_SET = <span class="tok-number">0xC0000245</span>,</span>
<span class="line" id="L1438">    <span class="tok-comment">/// A connection to the server could not be made because the limit on the number of concurrent connections for this account has been reached.</span></span>
<span class="line" id="L1439">    CONNECTION_COUNT_LIMIT = <span class="tok-number">0xC0000246</span>,</span>
<span class="line" id="L1440">    <span class="tok-comment">/// Attempting to log on during an unauthorized time of day for this account.</span></span>
<span class="line" id="L1441">    LOGIN_TIME_RESTRICTION = <span class="tok-number">0xC0000247</span>,</span>
<span class="line" id="L1442">    <span class="tok-comment">/// The account is not authorized to log on from this station.</span></span>
<span class="line" id="L1443">    LOGIN_WKSTA_RESTRICTION = <span class="tok-number">0xC0000248</span>,</span>
<span class="line" id="L1444">    <span class="tok-comment">/// {UP/MP Image Mismatch} The image %hs has been modified for use on a uniprocessor system, but you are running it on a multiprocessor machine. Reinstall the image file.</span></span>
<span class="line" id="L1445">    IMAGE_MP_UP_MISMATCH = <span class="tok-number">0xC0000249</span>,</span>
<span class="line" id="L1446">    <span class="tok-comment">/// There is insufficient account information to log you on.</span></span>
<span class="line" id="L1447">    INSUFFICIENT_LOGON_INFO = <span class="tok-number">0xC0000250</span>,</span>
<span class="line" id="L1448">    <span class="tok-comment">/// {Invalid DLL Entrypoint} The dynamic link library %hs is not written correctly.</span></span>
<span class="line" id="L1449">    <span class="tok-comment">/// The stack pointer has been left in an inconsistent state.</span></span>
<span class="line" id="L1450">    <span class="tok-comment">/// The entry point should be declared as WINAPI or STDCALL.</span></span>
<span class="line" id="L1451">    <span class="tok-comment">/// Select YES to fail the DLL load. Select NO to continue execution.</span></span>
<span class="line" id="L1452">    <span class="tok-comment">/// Selecting NO might cause the application to operate incorrectly.</span></span>
<span class="line" id="L1453">    BAD_DLL_ENTRYPOINT = <span class="tok-number">0xC0000251</span>,</span>
<span class="line" id="L1454">    <span class="tok-comment">/// {Invalid Service Callback Entrypoint} The %hs service is not written correctly.</span></span>
<span class="line" id="L1455">    <span class="tok-comment">/// The stack pointer has been left in an inconsistent state.</span></span>
<span class="line" id="L1456">    <span class="tok-comment">/// The callback entry point should be declared as WINAPI or STDCALL.</span></span>
<span class="line" id="L1457">    <span class="tok-comment">/// Selecting OK will cause the service to continue operation.</span></span>
<span class="line" id="L1458">    <span class="tok-comment">/// However, the service process might operate incorrectly.</span></span>
<span class="line" id="L1459">    BAD_SERVICE_ENTRYPOINT = <span class="tok-number">0xC0000252</span>,</span>
<span class="line" id="L1460">    <span class="tok-comment">/// The server received the messages but did not send a reply.</span></span>
<span class="line" id="L1461">    LPC_REPLY_LOST = <span class="tok-number">0xC0000253</span>,</span>
<span class="line" id="L1462">    <span class="tok-comment">/// There is an IP address conflict with another system on the network.</span></span>
<span class="line" id="L1463">    IP_ADDRESS_CONFLICT1 = <span class="tok-number">0xC0000254</span>,</span>
<span class="line" id="L1464">    <span class="tok-comment">/// There is an IP address conflict with another system on the network.</span></span>
<span class="line" id="L1465">    IP_ADDRESS_CONFLICT2 = <span class="tok-number">0xC0000255</span>,</span>
<span class="line" id="L1466">    <span class="tok-comment">/// {Low On Registry Space} The system has reached the maximum size that is allowed for the system part of the registry. Additional storage requests will be ignored.</span></span>
<span class="line" id="L1467">    REGISTRY_QUOTA_LIMIT = <span class="tok-number">0xC0000256</span>,</span>
<span class="line" id="L1468">    <span class="tok-comment">/// The contacted server does not support the indicated part of the DFS namespace.</span></span>
<span class="line" id="L1469">    PATH_NOT_COVERED = <span class="tok-number">0xC0000257</span>,</span>
<span class="line" id="L1470">    <span class="tok-comment">/// A callback return system service cannot be executed when no callback is active.</span></span>
<span class="line" id="L1471">    NO_CALLBACK_ACTIVE = <span class="tok-number">0xC0000258</span>,</span>
<span class="line" id="L1472">    <span class="tok-comment">/// The service being accessed is licensed for a particular number of connections.</span></span>
<span class="line" id="L1473">    <span class="tok-comment">/// No more connections can be made to the service at this time because the service has already accepted the maximum number of connections.</span></span>
<span class="line" id="L1474">    LICENSE_QUOTA_EXCEEDED = <span class="tok-number">0xC0000259</span>,</span>
<span class="line" id="L1475">    <span class="tok-comment">/// The password provided is too short to meet the policy of your user account. Choose a longer password.</span></span>
<span class="line" id="L1476">    PWD_TOO_SHORT = <span class="tok-number">0xC000025A</span>,</span>
<span class="line" id="L1477">    <span class="tok-comment">/// The policy of your user account does not allow you to change passwords too frequently.</span></span>
<span class="line" id="L1478">    <span class="tok-comment">/// This is done to prevent users from changing back to a familiar, but potentially discovered, password.</span></span>
<span class="line" id="L1479">    <span class="tok-comment">/// If you feel your password has been compromised, contact your administrator immediately to have a new one assigned.</span></span>
<span class="line" id="L1480">    PWD_TOO_RECENT = <span class="tok-number">0xC000025B</span>,</span>
<span class="line" id="L1481">    <span class="tok-comment">/// You have attempted to change your password to one that you have used in the past.</span></span>
<span class="line" id="L1482">    <span class="tok-comment">/// The policy of your user account does not allow this.</span></span>
<span class="line" id="L1483">    <span class="tok-comment">/// Select a password that you have not previously used.</span></span>
<span class="line" id="L1484">    PWD_HISTORY_CONFLICT = <span class="tok-number">0xC000025C</span>,</span>
<span class="line" id="L1485">    <span class="tok-comment">/// You have attempted to load a legacy device driver while its device instance had been disabled.</span></span>
<span class="line" id="L1486">    PLUGPLAY_NO_DEVICE = <span class="tok-number">0xC000025E</span>,</span>
<span class="line" id="L1487">    <span class="tok-comment">/// The specified compression format is unsupported.</span></span>
<span class="line" id="L1488">    UNSUPPORTED_COMPRESSION = <span class="tok-number">0xC000025F</span>,</span>
<span class="line" id="L1489">    <span class="tok-comment">/// The specified hardware profile configuration is invalid.</span></span>
<span class="line" id="L1490">    INVALID_HW_PROFILE = <span class="tok-number">0xC0000260</span>,</span>
<span class="line" id="L1491">    <span class="tok-comment">/// The specified Plug and Play registry device path is invalid.</span></span>
<span class="line" id="L1492">    INVALID_PLUGPLAY_DEVICE_PATH = <span class="tok-number">0xC0000261</span>,</span>
<span class="line" id="L1493">    <span class="tok-comment">/// {Driver Entry Point Not Found} The %hs device driver could not locate the ordinal %ld in driver %hs.</span></span>
<span class="line" id="L1494">    DRIVER_ORDINAL_NOT_FOUND = <span class="tok-number">0xC0000262</span>,</span>
<span class="line" id="L1495">    <span class="tok-comment">/// {Driver Entry Point Not Found} The %hs device driver could not locate the entry point %hs in driver %hs.</span></span>
<span class="line" id="L1496">    DRIVER_ENTRYPOINT_NOT_FOUND = <span class="tok-number">0xC0000263</span>,</span>
<span class="line" id="L1497">    <span class="tok-comment">/// {Application Error} The application attempted to release a resource it did not own. Click OK to terminate the application.</span></span>
<span class="line" id="L1498">    RESOURCE_NOT_OWNED = <span class="tok-number">0xC0000264</span>,</span>
<span class="line" id="L1499">    <span class="tok-comment">/// An attempt was made to create more links on a file than the file system supports.</span></span>
<span class="line" id="L1500">    TOO_MANY_LINKS = <span class="tok-number">0xC0000265</span>,</span>
<span class="line" id="L1501">    <span class="tok-comment">/// The specified quota list is internally inconsistent with its descriptor.</span></span>
<span class="line" id="L1502">    QUOTA_LIST_INCONSISTENT = <span class="tok-number">0xC0000266</span>,</span>
<span class="line" id="L1503">    <span class="tok-comment">/// The specified file has been relocated to offline storage.</span></span>
<span class="line" id="L1504">    FILE_IS_OFFLINE = <span class="tok-number">0xC0000267</span>,</span>
<span class="line" id="L1505">    <span class="tok-comment">/// {Windows Evaluation Notification} The evaluation period for this installation of Windows has expired. This system will shutdown in 1 hour.</span></span>
<span class="line" id="L1506">    <span class="tok-comment">/// To restore access to this installation of Windows, upgrade this installation by using a licensed distribution of this product.</span></span>
<span class="line" id="L1507">    EVALUATION_EXPIRATION = <span class="tok-number">0xC0000268</span>,</span>
<span class="line" id="L1508">    <span class="tok-comment">/// {Illegal System DLL Relocation} The system DLL %hs was relocated in memory. The application will not run properly.</span></span>
<span class="line" id="L1509">    <span class="tok-comment">/// The relocation occurred because the DLL %hs occupied an address range that is reserved for Windows system DLLs.</span></span>
<span class="line" id="L1510">    <span class="tok-comment">/// The vendor supplying the DLL should be contacted for a new DLL.</span></span>
<span class="line" id="L1511">    ILLEGAL_DLL_RELOCATION = <span class="tok-number">0xC0000269</span>,</span>
<span class="line" id="L1512">    <span class="tok-comment">/// {License Violation} The system has detected tampering with your registered product type.</span></span>
<span class="line" id="L1513">    <span class="tok-comment">/// This is a violation of your software license. Tampering with the product type is not permitted.</span></span>
<span class="line" id="L1514">    LICENSE_VIOLATION = <span class="tok-number">0xC000026A</span>,</span>
<span class="line" id="L1515">    <span class="tok-comment">/// {DLL Initialization Failed} The application failed to initialize because the window station is shutting down.</span></span>
<span class="line" id="L1516">    DLL_INIT_FAILED_LOGOFF = <span class="tok-number">0xC000026B</span>,</span>
<span class="line" id="L1517">    <span class="tok-comment">/// {Unable to Load Device Driver} %hs device driver could not be loaded. Error Status was 0x%x.</span></span>
<span class="line" id="L1518">    DRIVER_UNABLE_TO_LOAD = <span class="tok-number">0xC000026C</span>,</span>
<span class="line" id="L1519">    <span class="tok-comment">/// DFS is unavailable on the contacted server.</span></span>
<span class="line" id="L1520">    DFS_UNAVAILABLE = <span class="tok-number">0xC000026D</span>,</span>
<span class="line" id="L1521">    <span class="tok-comment">/// An operation was attempted to a volume after it was dismounted.</span></span>
<span class="line" id="L1522">    VOLUME_DISMOUNTED = <span class="tok-number">0xC000026E</span>,</span>
<span class="line" id="L1523">    <span class="tok-comment">/// An internal error occurred in the Win32 x86 emulation subsystem.</span></span>
<span class="line" id="L1524">    WX86_INTERNAL_ERROR = <span class="tok-number">0xC000026F</span>,</span>
<span class="line" id="L1525">    <span class="tok-comment">/// Win32 x86 emulation subsystem floating-point stack check.</span></span>
<span class="line" id="L1526">    WX86_FLOAT_STACK_CHECK = <span class="tok-number">0xC0000270</span>,</span>
<span class="line" id="L1527">    <span class="tok-comment">/// The validation process needs to continue on to the next step.</span></span>
<span class="line" id="L1528">    VALIDATE_CONTINUE = <span class="tok-number">0xC0000271</span>,</span>
<span class="line" id="L1529">    <span class="tok-comment">/// There was no match for the specified key in the index.</span></span>
<span class="line" id="L1530">    NO_MATCH = <span class="tok-number">0xC0000272</span>,</span>
<span class="line" id="L1531">    <span class="tok-comment">/// There are no more matches for the current index enumeration.</span></span>
<span class="line" id="L1532">    NO_MORE_MATCHES = <span class="tok-number">0xC0000273</span>,</span>
<span class="line" id="L1533">    <span class="tok-comment">/// The NTFS file or directory is not a reparse point.</span></span>
<span class="line" id="L1534">    NOT_A_REPARSE_POINT = <span class="tok-number">0xC0000275</span>,</span>
<span class="line" id="L1535">    <span class="tok-comment">/// The Windows I/O reparse tag passed for the NTFS reparse point is invalid.</span></span>
<span class="line" id="L1536">    IO_REPARSE_TAG_INVALID = <span class="tok-number">0xC0000276</span>,</span>
<span class="line" id="L1537">    <span class="tok-comment">/// The Windows I/O reparse tag does not match the one that is in the NTFS reparse point.</span></span>
<span class="line" id="L1538">    IO_REPARSE_TAG_MISMATCH = <span class="tok-number">0xC0000277</span>,</span>
<span class="line" id="L1539">    <span class="tok-comment">/// The user data passed for the NTFS reparse point is invalid.</span></span>
<span class="line" id="L1540">    IO_REPARSE_DATA_INVALID = <span class="tok-number">0xC0000278</span>,</span>
<span class="line" id="L1541">    <span class="tok-comment">/// The layered file system driver for this I/O tag did not handle it when needed.</span></span>
<span class="line" id="L1542">    IO_REPARSE_TAG_NOT_HANDLED = <span class="tok-number">0xC0000279</span>,</span>
<span class="line" id="L1543">    <span class="tok-comment">/// The NTFS symbolic link could not be resolved even though the initial file name is valid.</span></span>
<span class="line" id="L1544">    REPARSE_POINT_NOT_RESOLVED = <span class="tok-number">0xC0000280</span>,</span>
<span class="line" id="L1545">    <span class="tok-comment">/// The NTFS directory is a reparse point.</span></span>
<span class="line" id="L1546">    DIRECTORY_IS_A_REPARSE_POINT = <span class="tok-number">0xC0000281</span>,</span>
<span class="line" id="L1547">    <span class="tok-comment">/// The range could not be added to the range list because of a conflict.</span></span>
<span class="line" id="L1548">    RANGE_LIST_CONFLICT = <span class="tok-number">0xC0000282</span>,</span>
<span class="line" id="L1549">    <span class="tok-comment">/// The specified medium changer source element contains no media.</span></span>
<span class="line" id="L1550">    SOURCE_ELEMENT_EMPTY = <span class="tok-number">0xC0000283</span>,</span>
<span class="line" id="L1551">    <span class="tok-comment">/// The specified medium changer destination element already contains media.</span></span>
<span class="line" id="L1552">    DESTINATION_ELEMENT_FULL = <span class="tok-number">0xC0000284</span>,</span>
<span class="line" id="L1553">    <span class="tok-comment">/// The specified medium changer element does not exist.</span></span>
<span class="line" id="L1554">    ILLEGAL_ELEMENT_ADDRESS = <span class="tok-number">0xC0000285</span>,</span>
<span class="line" id="L1555">    <span class="tok-comment">/// The specified element is contained in a magazine that is no longer present.</span></span>
<span class="line" id="L1556">    MAGAZINE_NOT_PRESENT = <span class="tok-number">0xC0000286</span>,</span>
<span class="line" id="L1557">    <span class="tok-comment">/// The device requires re-initialization due to hardware errors.</span></span>
<span class="line" id="L1558">    REINITIALIZATION_NEEDED = <span class="tok-number">0xC0000287</span>,</span>
<span class="line" id="L1559">    <span class="tok-comment">/// The file encryption attempt failed.</span></span>
<span class="line" id="L1560">    ENCRYPTION_FAILED = <span class="tok-number">0xC000028A</span>,</span>
<span class="line" id="L1561">    <span class="tok-comment">/// The file decryption attempt failed.</span></span>
<span class="line" id="L1562">    DECRYPTION_FAILED = <span class="tok-number">0xC000028B</span>,</span>
<span class="line" id="L1563">    <span class="tok-comment">/// The specified range could not be found in the range list.</span></span>
<span class="line" id="L1564">    RANGE_NOT_FOUND = <span class="tok-number">0xC000028C</span>,</span>
<span class="line" id="L1565">    <span class="tok-comment">/// There is no encryption recovery policy configured for this system.</span></span>
<span class="line" id="L1566">    NO_RECOVERY_POLICY = <span class="tok-number">0xC000028D</span>,</span>
<span class="line" id="L1567">    <span class="tok-comment">/// The required encryption driver is not loaded for this system.</span></span>
<span class="line" id="L1568">    NO_EFS = <span class="tok-number">0xC000028E</span>,</span>
<span class="line" id="L1569">    <span class="tok-comment">/// The file was encrypted with a different encryption driver than is currently loaded.</span></span>
<span class="line" id="L1570">    WRONG_EFS = <span class="tok-number">0xC000028F</span>,</span>
<span class="line" id="L1571">    <span class="tok-comment">/// There are no EFS keys defined for the user.</span></span>
<span class="line" id="L1572">    NO_USER_KEYS = <span class="tok-number">0xC0000290</span>,</span>
<span class="line" id="L1573">    <span class="tok-comment">/// The specified file is not encrypted.</span></span>
<span class="line" id="L1574">    FILE_NOT_ENCRYPTED = <span class="tok-number">0xC0000291</span>,</span>
<span class="line" id="L1575">    <span class="tok-comment">/// The specified file is not in the defined EFS export format.</span></span>
<span class="line" id="L1576">    NOT_EXPORT_FORMAT = <span class="tok-number">0xC0000292</span>,</span>
<span class="line" id="L1577">    <span class="tok-comment">/// The specified file is encrypted and the user does not have the ability to decrypt it.</span></span>
<span class="line" id="L1578">    FILE_ENCRYPTED = <span class="tok-number">0xC0000293</span>,</span>
<span class="line" id="L1579">    <span class="tok-comment">/// The GUID passed was not recognized as valid by a WMI data provider.</span></span>
<span class="line" id="L1580">    WMI_GUID_NOT_FOUND = <span class="tok-number">0xC0000295</span>,</span>
<span class="line" id="L1581">    <span class="tok-comment">/// The instance name passed was not recognized as valid by a WMI data provider.</span></span>
<span class="line" id="L1582">    WMI_INSTANCE_NOT_FOUND = <span class="tok-number">0xC0000296</span>,</span>
<span class="line" id="L1583">    <span class="tok-comment">/// The data item ID passed was not recognized as valid by a WMI data provider.</span></span>
<span class="line" id="L1584">    WMI_ITEMID_NOT_FOUND = <span class="tok-number">0xC0000297</span>,</span>
<span class="line" id="L1585">    <span class="tok-comment">/// The WMI request could not be completed and should be retried.</span></span>
<span class="line" id="L1586">    WMI_TRY_AGAIN = <span class="tok-number">0xC0000298</span>,</span>
<span class="line" id="L1587">    <span class="tok-comment">/// The policy object is shared and can only be modified at the root.</span></span>
<span class="line" id="L1588">    SHARED_POLICY = <span class="tok-number">0xC0000299</span>,</span>
<span class="line" id="L1589">    <span class="tok-comment">/// The policy object does not exist when it should.</span></span>
<span class="line" id="L1590">    POLICY_OBJECT_NOT_FOUND = <span class="tok-number">0xC000029A</span>,</span>
<span class="line" id="L1591">    <span class="tok-comment">/// The requested policy information only lives in the Ds.</span></span>
<span class="line" id="L1592">    POLICY_ONLY_IN_DS = <span class="tok-number">0xC000029B</span>,</span>
<span class="line" id="L1593">    <span class="tok-comment">/// The volume must be upgraded to enable this feature.</span></span>
<span class="line" id="L1594">    VOLUME_NOT_UPGRADED = <span class="tok-number">0xC000029C</span>,</span>
<span class="line" id="L1595">    <span class="tok-comment">/// The remote storage service is not operational at this time.</span></span>
<span class="line" id="L1596">    REMOTE_STORAGE_NOT_ACTIVE = <span class="tok-number">0xC000029D</span>,</span>
<span class="line" id="L1597">    <span class="tok-comment">/// The remote storage service encountered a media error.</span></span>
<span class="line" id="L1598">    REMOTE_STORAGE_MEDIA_ERROR = <span class="tok-number">0xC000029E</span>,</span>
<span class="line" id="L1599">    <span class="tok-comment">/// The tracking (workstation) service is not running.</span></span>
<span class="line" id="L1600">    NO_TRACKING_SERVICE = <span class="tok-number">0xC000029F</span>,</span>
<span class="line" id="L1601">    <span class="tok-comment">/// The server process is running under a SID that is different from the SID that is required by client.</span></span>
<span class="line" id="L1602">    SERVER_SID_MISMATCH = <span class="tok-number">0xC00002A0</span>,</span>
<span class="line" id="L1603">    <span class="tok-comment">/// The specified directory service attribute or value does not exist.</span></span>
<span class="line" id="L1604">    DS_NO_ATTRIBUTE_OR_VALUE = <span class="tok-number">0xC00002A1</span>,</span>
<span class="line" id="L1605">    <span class="tok-comment">/// The attribute syntax specified to the directory service is invalid.</span></span>
<span class="line" id="L1606">    DS_INVALID_ATTRIBUTE_SYNTAX = <span class="tok-number">0xC00002A2</span>,</span>
<span class="line" id="L1607">    <span class="tok-comment">/// The attribute type specified to the directory service is not defined.</span></span>
<span class="line" id="L1608">    DS_ATTRIBUTE_TYPE_UNDEFINED = <span class="tok-number">0xC00002A3</span>,</span>
<span class="line" id="L1609">    <span class="tok-comment">/// The specified directory service attribute or value already exists.</span></span>
<span class="line" id="L1610">    DS_ATTRIBUTE_OR_VALUE_EXISTS = <span class="tok-number">0xC00002A4</span>,</span>
<span class="line" id="L1611">    <span class="tok-comment">/// The directory service is busy.</span></span>
<span class="line" id="L1612">    DS_BUSY = <span class="tok-number">0xC00002A5</span>,</span>
<span class="line" id="L1613">    <span class="tok-comment">/// The directory service is unavailable.</span></span>
<span class="line" id="L1614">    DS_UNAVAILABLE = <span class="tok-number">0xC00002A6</span>,</span>
<span class="line" id="L1615">    <span class="tok-comment">/// The directory service was unable to allocate a relative identifier.</span></span>
<span class="line" id="L1616">    DS_NO_RIDS_ALLOCATED = <span class="tok-number">0xC00002A7</span>,</span>
<span class="line" id="L1617">    <span class="tok-comment">/// The directory service has exhausted the pool of relative identifiers.</span></span>
<span class="line" id="L1618">    DS_NO_MORE_RIDS = <span class="tok-number">0xC00002A8</span>,</span>
<span class="line" id="L1619">    <span class="tok-comment">/// The requested operation could not be performed because the directory service is not the master for that type of operation.</span></span>
<span class="line" id="L1620">    DS_INCORRECT_ROLE_OWNER = <span class="tok-number">0xC00002A9</span>,</span>
<span class="line" id="L1621">    <span class="tok-comment">/// The directory service was unable to initialize the subsystem that allocates relative identifiers.</span></span>
<span class="line" id="L1622">    DS_RIDMGR_INIT_ERROR = <span class="tok-number">0xC00002AA</span>,</span>
<span class="line" id="L1623">    <span class="tok-comment">/// The requested operation did not satisfy one or more constraints that are associated with the class of the object.</span></span>
<span class="line" id="L1624">    DS_OBJ_CLASS_VIOLATION = <span class="tok-number">0xC00002AB</span>,</span>
<span class="line" id="L1625">    <span class="tok-comment">/// The directory service can perform the requested operation only on a leaf object.</span></span>
<span class="line" id="L1626">    DS_CANT_ON_NON_LEAF = <span class="tok-number">0xC00002AC</span>,</span>
<span class="line" id="L1627">    <span class="tok-comment">/// The directory service cannot perform the requested operation on the Relatively Defined Name (RDN) attribute of an object.</span></span>
<span class="line" id="L1628">    DS_CANT_ON_RDN = <span class="tok-number">0xC00002AD</span>,</span>
<span class="line" id="L1629">    <span class="tok-comment">/// The directory service detected an attempt to modify the object class of an object.</span></span>
<span class="line" id="L1630">    DS_CANT_MOD_OBJ_CLASS = <span class="tok-number">0xC00002AE</span>,</span>
<span class="line" id="L1631">    <span class="tok-comment">/// An error occurred while performing a cross domain move operation.</span></span>
<span class="line" id="L1632">    DS_CROSS_DOM_MOVE_FAILED = <span class="tok-number">0xC00002AF</span>,</span>
<span class="line" id="L1633">    <span class="tok-comment">/// Unable to contact the global catalog server.</span></span>
<span class="line" id="L1634">    DS_GC_NOT_AVAILABLE = <span class="tok-number">0xC00002B0</span>,</span>
<span class="line" id="L1635">    <span class="tok-comment">/// The requested operation requires a directory service, and none was available.</span></span>
<span class="line" id="L1636">    DIRECTORY_SERVICE_REQUIRED = <span class="tok-number">0xC00002B1</span>,</span>
<span class="line" id="L1637">    <span class="tok-comment">/// The reparse attribute cannot be set because it is incompatible with an existing attribute.</span></span>
<span class="line" id="L1638">    REPARSE_ATTRIBUTE_CONFLICT = <span class="tok-number">0xC00002B2</span>,</span>
<span class="line" id="L1639">    <span class="tok-comment">/// A group marked &quot;use for deny only&quot; cannot be enabled.</span></span>
<span class="line" id="L1640">    CANT_ENABLE_DENY_ONLY = <span class="tok-number">0xC00002B3</span>,</span>
<span class="line" id="L1641">    <span class="tok-comment">/// {EXCEPTION} Multiple floating-point faults.</span></span>
<span class="line" id="L1642">    FLOAT_MULTIPLE_FAULTS = <span class="tok-number">0xC00002B4</span>,</span>
<span class="line" id="L1643">    <span class="tok-comment">/// {EXCEPTION} Multiple floating-point traps.</span></span>
<span class="line" id="L1644">    FLOAT_MULTIPLE_TRAPS = <span class="tok-number">0xC00002B5</span>,</span>
<span class="line" id="L1645">    <span class="tok-comment">/// The device has been removed.</span></span>
<span class="line" id="L1646">    DEVICE_REMOVED = <span class="tok-number">0xC00002B6</span>,</span>
<span class="line" id="L1647">    <span class="tok-comment">/// The volume change journal is being deleted.</span></span>
<span class="line" id="L1648">    JOURNAL_DELETE_IN_PROGRESS = <span class="tok-number">0xC00002B7</span>,</span>
<span class="line" id="L1649">    <span class="tok-comment">/// The volume change journal is not active.</span></span>
<span class="line" id="L1650">    JOURNAL_NOT_ACTIVE = <span class="tok-number">0xC00002B8</span>,</span>
<span class="line" id="L1651">    <span class="tok-comment">/// The requested interface is not supported.</span></span>
<span class="line" id="L1652">    NOINTERFACE = <span class="tok-number">0xC00002B9</span>,</span>
<span class="line" id="L1653">    <span class="tok-comment">/// A directory service resource limit has been exceeded.</span></span>
<span class="line" id="L1654">    DS_ADMIN_LIMIT_EXCEEDED = <span class="tok-number">0xC00002C1</span>,</span>
<span class="line" id="L1655">    <span class="tok-comment">/// {System Standby Failed} The driver %hs does not support standby mode.</span></span>
<span class="line" id="L1656">    <span class="tok-comment">/// Updating this driver allows the system to go to standby mode.</span></span>
<span class="line" id="L1657">    DRIVER_FAILED_SLEEP = <span class="tok-number">0xC00002C2</span>,</span>
<span class="line" id="L1658">    <span class="tok-comment">/// Mutual Authentication failed. The server password is out of date at the domain controller.</span></span>
<span class="line" id="L1659">    MUTUAL_AUTHENTICATION_FAILED = <span class="tok-number">0xC00002C3</span>,</span>
<span class="line" id="L1660">    <span class="tok-comment">/// The system file %1 has become corrupt and has been replaced.</span></span>
<span class="line" id="L1661">    CORRUPT_SYSTEM_FILE = <span class="tok-number">0xC00002C4</span>,</span>
<span class="line" id="L1662">    <span class="tok-comment">/// {EXCEPTION} Alignment Error A data type misalignment error was detected in a load or store instruction.</span></span>
<span class="line" id="L1663">    DATATYPE_MISALIGNMENT_ERROR = <span class="tok-number">0xC00002C5</span>,</span>
<span class="line" id="L1664">    <span class="tok-comment">/// The WMI data item or data block is read-only.</span></span>
<span class="line" id="L1665">    WMI_READ_ONLY = <span class="tok-number">0xC00002C6</span>,</span>
<span class="line" id="L1666">    <span class="tok-comment">/// The WMI data item or data block could not be changed.</span></span>
<span class="line" id="L1667">    WMI_SET_FAILURE = <span class="tok-number">0xC00002C7</span>,</span>
<span class="line" id="L1668">    <span class="tok-comment">/// {Virtual Memory Minimum Too Low} Your system is low on virtual memory.</span></span>
<span class="line" id="L1669">    <span class="tok-comment">/// Windows is increasing the size of your virtual memory paging file.</span></span>
<span class="line" id="L1670">    <span class="tok-comment">/// During this process, memory requests for some applications might be denied. For more information, see Help.</span></span>
<span class="line" id="L1671">    COMMITMENT_MINIMUM = <span class="tok-number">0xC00002C8</span>,</span>
<span class="line" id="L1672">    <span class="tok-comment">/// {EXCEPTION} Register NaT consumption faults.</span></span>
<span class="line" id="L1673">    <span class="tok-comment">/// A NaT value is consumed on a non-speculative instruction.</span></span>
<span class="line" id="L1674">    REG_NAT_CONSUMPTION = <span class="tok-number">0xC00002C9</span>,</span>
<span class="line" id="L1675">    <span class="tok-comment">/// The transport element of the medium changer contains media, which is causing the operation to fail.</span></span>
<span class="line" id="L1676">    TRANSPORT_FULL = <span class="tok-number">0xC00002CA</span>,</span>
<span class="line" id="L1677">    <span class="tok-comment">/// Security Accounts Manager initialization failed because of the following error: %hs Error Status: 0x%x.</span></span>
<span class="line" id="L1678">    <span class="tok-comment">/// Click OK to shut down this system and restart in Directory Services Restore Mode.</span></span>
<span class="line" id="L1679">    <span class="tok-comment">/// Check the event log for more detailed information.</span></span>
<span class="line" id="L1680">    DS_SAM_INIT_FAILURE = <span class="tok-number">0xC00002CB</span>,</span>
<span class="line" id="L1681">    <span class="tok-comment">/// This operation is supported only when you are connected to the server.</span></span>
<span class="line" id="L1682">    ONLY_IF_CONNECTED = <span class="tok-number">0xC00002CC</span>,</span>
<span class="line" id="L1683">    <span class="tok-comment">/// Only an administrator can modify the membership list of an administrative group.</span></span>
<span class="line" id="L1684">    DS_SENSITIVE_GROUP_VIOLATION = <span class="tok-number">0xC00002CD</span>,</span>
<span class="line" id="L1685">    <span class="tok-comment">/// A device was removed so enumeration must be restarted.</span></span>
<span class="line" id="L1686">    PNP_RESTART_ENUMERATION = <span class="tok-number">0xC00002CE</span>,</span>
<span class="line" id="L1687">    <span class="tok-comment">/// The journal entry has been deleted from the journal.</span></span>
<span class="line" id="L1688">    JOURNAL_ENTRY_DELETED = <span class="tok-number">0xC00002CF</span>,</span>
<span class="line" id="L1689">    <span class="tok-comment">/// Cannot change the primary group ID of a domain controller account.</span></span>
<span class="line" id="L1690">    DS_CANT_MOD_PRIMARYGROUPID = <span class="tok-number">0xC00002D0</span>,</span>
<span class="line" id="L1691">    <span class="tok-comment">/// {Fatal System Error} The system image %s is not properly signed.</span></span>
<span class="line" id="L1692">    <span class="tok-comment">/// The file has been replaced with the signed file. The system has been shut down.</span></span>
<span class="line" id="L1693">    SYSTEM_IMAGE_BAD_SIGNATURE = <span class="tok-number">0xC00002D1</span>,</span>
<span class="line" id="L1694">    <span class="tok-comment">/// The device will not start without a reboot.</span></span>
<span class="line" id="L1695">    PNP_REBOOT_REQUIRED = <span class="tok-number">0xC00002D2</span>,</span>
<span class="line" id="L1696">    <span class="tok-comment">/// The power state of the current device cannot support this request.</span></span>
<span class="line" id="L1697">    POWER_STATE_INVALID = <span class="tok-number">0xC00002D3</span>,</span>
<span class="line" id="L1698">    <span class="tok-comment">/// The specified group type is invalid.</span></span>
<span class="line" id="L1699">    DS_INVALID_GROUP_TYPE = <span class="tok-number">0xC00002D4</span>,</span>
<span class="line" id="L1700">    <span class="tok-comment">/// In a mixed domain, no nesting of a global group if the group is security enabled.</span></span>
<span class="line" id="L1701">    DS_NO_NEST_GLOBALGROUP_IN_MIXEDDOMAIN = <span class="tok-number">0xC00002D5</span>,</span>
<span class="line" id="L1702">    <span class="tok-comment">/// In a mixed domain, cannot nest local groups with other local groups, if the group is security enabled.</span></span>
<span class="line" id="L1703">    DS_NO_NEST_LOCALGROUP_IN_MIXEDDOMAIN = <span class="tok-number">0xC00002D6</span>,</span>
<span class="line" id="L1704">    <span class="tok-comment">/// A global group cannot have a local group as a member.</span></span>
<span class="line" id="L1705">    DS_GLOBAL_CANT_HAVE_LOCAL_MEMBER = <span class="tok-number">0xC00002D7</span>,</span>
<span class="line" id="L1706">    <span class="tok-comment">/// A global group cannot have a universal group as a member.</span></span>
<span class="line" id="L1707">    DS_GLOBAL_CANT_HAVE_UNIVERSAL_MEMBER = <span class="tok-number">0xC00002D8</span>,</span>
<span class="line" id="L1708">    <span class="tok-comment">/// A universal group cannot have a local group as a member.</span></span>
<span class="line" id="L1709">    DS_UNIVERSAL_CANT_HAVE_LOCAL_MEMBER = <span class="tok-number">0xC00002D9</span>,</span>
<span class="line" id="L1710">    <span class="tok-comment">/// A global group cannot have a cross-domain member.</span></span>
<span class="line" id="L1711">    DS_GLOBAL_CANT_HAVE_CROSSDOMAIN_MEMBER = <span class="tok-number">0xC00002DA</span>,</span>
<span class="line" id="L1712">    <span class="tok-comment">/// A local group cannot have another cross-domain local group as a member.</span></span>
<span class="line" id="L1713">    DS_LOCAL_CANT_HAVE_CROSSDOMAIN_LOCAL_MEMBER = <span class="tok-number">0xC00002DB</span>,</span>
<span class="line" id="L1714">    <span class="tok-comment">/// Cannot change to a security-disabled group because primary members are in this group.</span></span>
<span class="line" id="L1715">    DS_HAVE_PRIMARY_MEMBERS = <span class="tok-number">0xC00002DC</span>,</span>
<span class="line" id="L1716">    <span class="tok-comment">/// The WMI operation is not supported by the data block or method.</span></span>
<span class="line" id="L1717">    WMI_NOT_SUPPORTED = <span class="tok-number">0xC00002DD</span>,</span>
<span class="line" id="L1718">    <span class="tok-comment">/// There is not enough power to complete the requested operation.</span></span>
<span class="line" id="L1719">    INSUFFICIENT_POWER = <span class="tok-number">0xC00002DE</span>,</span>
<span class="line" id="L1720">    <span class="tok-comment">/// The Security Accounts Manager needs to get the boot password.</span></span>
<span class="line" id="L1721">    SAM_NEED_BOOTKEY_PASSWORD = <span class="tok-number">0xC00002DF</span>,</span>
<span class="line" id="L1722">    <span class="tok-comment">/// The Security Accounts Manager needs to get the boot key from the floppy disk.</span></span>
<span class="line" id="L1723">    SAM_NEED_BOOTKEY_FLOPPY = <span class="tok-number">0xC00002E0</span>,</span>
<span class="line" id="L1724">    <span class="tok-comment">/// The directory service cannot start.</span></span>
<span class="line" id="L1725">    DS_CANT_START = <span class="tok-number">0xC00002E1</span>,</span>
<span class="line" id="L1726">    <span class="tok-comment">/// The directory service could not start because of the following error: %hs Error Status: 0x%x.</span></span>
<span class="line" id="L1727">    <span class="tok-comment">/// Click OK to shut down this system and restart in Directory Services Restore Mode.</span></span>
<span class="line" id="L1728">    <span class="tok-comment">/// Check the event log for more detailed information.</span></span>
<span class="line" id="L1729">    DS_INIT_FAILURE = <span class="tok-number">0xC00002E2</span>,</span>
<span class="line" id="L1730">    <span class="tok-comment">/// The Security Accounts Manager initialization failed because of the following error: %hs Error Status: 0x%x.</span></span>
<span class="line" id="L1731">    <span class="tok-comment">/// Click OK to shut down this system and restart in Safe Mode.</span></span>
<span class="line" id="L1732">    <span class="tok-comment">/// Check the event log for more detailed information.</span></span>
<span class="line" id="L1733">    SAM_INIT_FAILURE = <span class="tok-number">0xC00002E3</span>,</span>
<span class="line" id="L1734">    <span class="tok-comment">/// The requested operation can be performed only on a global catalog server.</span></span>
<span class="line" id="L1735">    DS_GC_REQUIRED = <span class="tok-number">0xC00002E4</span>,</span>
<span class="line" id="L1736">    <span class="tok-comment">/// A local group can only be a member of other local groups in the same domain.</span></span>
<span class="line" id="L1737">    DS_LOCAL_MEMBER_OF_LOCAL_ONLY = <span class="tok-number">0xC00002E5</span>,</span>
<span class="line" id="L1738">    <span class="tok-comment">/// Foreign security principals cannot be members of universal groups.</span></span>
<span class="line" id="L1739">    DS_NO_FPO_IN_UNIVERSAL_GROUPS = <span class="tok-number">0xC00002E6</span>,</span>
<span class="line" id="L1740">    <span class="tok-comment">/// Your computer could not be joined to the domain.</span></span>
<span class="line" id="L1741">    <span class="tok-comment">/// You have exceeded the maximum number of computer accounts you are allowed to create in this domain.</span></span>
<span class="line" id="L1742">    <span class="tok-comment">/// Contact your system administrator to have this limit reset or increased.</span></span>
<span class="line" id="L1743">    DS_MACHINE_ACCOUNT_QUOTA_EXCEEDED = <span class="tok-number">0xC00002E7</span>,</span>
<span class="line" id="L1744">    <span class="tok-comment">/// This operation cannot be performed on the current domain.</span></span>
<span class="line" id="L1745">    CURRENT_DOMAIN_NOT_ALLOWED = <span class="tok-number">0xC00002E9</span>,</span>
<span class="line" id="L1746">    <span class="tok-comment">/// The directory or file cannot be created.</span></span>
<span class="line" id="L1747">    CANNOT_MAKE = <span class="tok-number">0xC00002EA</span>,</span>
<span class="line" id="L1748">    <span class="tok-comment">/// The system is in the process of shutting down.</span></span>
<span class="line" id="L1749">    SYSTEM_SHUTDOWN = <span class="tok-number">0xC00002EB</span>,</span>
<span class="line" id="L1750">    <span class="tok-comment">/// Directory Services could not start because of the following error: %hs Error Status: 0x%x. Click OK to shut down the system.</span></span>
<span class="line" id="L1751">    <span class="tok-comment">/// You can use the recovery console to diagnose the system further.</span></span>
<span class="line" id="L1752">    DS_INIT_FAILURE_CONSOLE = <span class="tok-number">0xC00002EC</span>,</span>
<span class="line" id="L1753">    <span class="tok-comment">/// Security Accounts Manager initialization failed because of the following error: %hs Error Status: 0x%x. Click OK to shut down the system.</span></span>
<span class="line" id="L1754">    <span class="tok-comment">/// You can use the recovery console to diagnose the system further.</span></span>
<span class="line" id="L1755">    DS_SAM_INIT_FAILURE_CONSOLE = <span class="tok-number">0xC00002ED</span>,</span>
<span class="line" id="L1756">    <span class="tok-comment">/// A security context was deleted before the context was completed. This is considered a logon failure.</span></span>
<span class="line" id="L1757">    UNFINISHED_CONTEXT_DELETED = <span class="tok-number">0xC00002EE</span>,</span>
<span class="line" id="L1758">    <span class="tok-comment">/// The client is trying to negotiate a context and the server requires user-to-user but did not send a TGT reply.</span></span>
<span class="line" id="L1759">    NO_TGT_REPLY = <span class="tok-number">0xC00002EF</span>,</span>
<span class="line" id="L1760">    <span class="tok-comment">/// An object ID was not found in the file.</span></span>
<span class="line" id="L1761">    OBJECTID_NOT_FOUND = <span class="tok-number">0xC00002F0</span>,</span>
<span class="line" id="L1762">    <span class="tok-comment">/// Unable to accomplish the requested task because the local machine does not have any IP addresses.</span></span>
<span class="line" id="L1763">    NO_IP_ADDRESSES = <span class="tok-number">0xC00002F1</span>,</span>
<span class="line" id="L1764">    <span class="tok-comment">/// The supplied credential handle does not match the credential that is associated with the security context.</span></span>
<span class="line" id="L1765">    WRONG_CREDENTIAL_HANDLE = <span class="tok-number">0xC00002F2</span>,</span>
<span class="line" id="L1766">    <span class="tok-comment">/// The crypto system or checksum function is invalid because a required function is unavailable.</span></span>
<span class="line" id="L1767">    CRYPTO_SYSTEM_INVALID = <span class="tok-number">0xC00002F3</span>,</span>
<span class="line" id="L1768">    <span class="tok-comment">/// The number of maximum ticket referrals has been exceeded.</span></span>
<span class="line" id="L1769">    MAX_REFERRALS_EXCEEDED = <span class="tok-number">0xC00002F4</span>,</span>
<span class="line" id="L1770">    <span class="tok-comment">/// The local machine must be a Kerberos KDC (domain controller) and it is not.</span></span>
<span class="line" id="L1771">    MUST_BE_KDC = <span class="tok-number">0xC00002F5</span>,</span>
<span class="line" id="L1772">    <span class="tok-comment">/// The other end of the security negotiation requires strong crypto but it is not supported on the local machine.</span></span>
<span class="line" id="L1773">    STRONG_CRYPTO_NOT_SUPPORTED = <span class="tok-number">0xC00002F6</span>,</span>
<span class="line" id="L1774">    <span class="tok-comment">/// The KDC reply contained more than one principal name.</span></span>
<span class="line" id="L1775">    TOO_MANY_PRINCIPALS = <span class="tok-number">0xC00002F7</span>,</span>
<span class="line" id="L1776">    <span class="tok-comment">/// Expected to find PA data for a hint of what etype to use, but it was not found.</span></span>
<span class="line" id="L1777">    NO_PA_DATA = <span class="tok-number">0xC00002F8</span>,</span>
<span class="line" id="L1778">    <span class="tok-comment">/// The client certificate does not contain a valid UPN, or does not match the client name in the logon request. Contact your administrator.</span></span>
<span class="line" id="L1779">    PKINIT_NAME_MISMATCH = <span class="tok-number">0xC00002F9</span>,</span>
<span class="line" id="L1780">    <span class="tok-comment">/// Smart card logon is required and was not used.</span></span>
<span class="line" id="L1781">    SMARTCARD_LOGON_REQUIRED = <span class="tok-number">0xC00002FA</span>,</span>
<span class="line" id="L1782">    <span class="tok-comment">/// An invalid request was sent to the KDC.</span></span>
<span class="line" id="L1783">    KDC_INVALID_REQUEST = <span class="tok-number">0xC00002FB</span>,</span>
<span class="line" id="L1784">    <span class="tok-comment">/// The KDC was unable to generate a referral for the service requested.</span></span>
<span class="line" id="L1785">    KDC_UNABLE_TO_REFER = <span class="tok-number">0xC00002FC</span>,</span>
<span class="line" id="L1786">    <span class="tok-comment">/// The encryption type requested is not supported by the KDC.</span></span>
<span class="line" id="L1787">    KDC_UNKNOWN_ETYPE = <span class="tok-number">0xC00002FD</span>,</span>
<span class="line" id="L1788">    <span class="tok-comment">/// A system shutdown is in progress.</span></span>
<span class="line" id="L1789">    SHUTDOWN_IN_PROGRESS = <span class="tok-number">0xC00002FE</span>,</span>
<span class="line" id="L1790">    <span class="tok-comment">/// The server machine is shutting down.</span></span>
<span class="line" id="L1791">    SERVER_SHUTDOWN_IN_PROGRESS = <span class="tok-number">0xC00002FF</span>,</span>
<span class="line" id="L1792">    <span class="tok-comment">/// This operation is not supported on a computer running Windows Server 2003 operating system for Small Business Server.</span></span>
<span class="line" id="L1793">    NOT_SUPPORTED_ON_SBS = <span class="tok-number">0xC0000300</span>,</span>
<span class="line" id="L1794">    <span class="tok-comment">/// The WMI GUID is no longer available.</span></span>
<span class="line" id="L1795">    WMI_GUID_DISCONNECTED = <span class="tok-number">0xC0000301</span>,</span>
<span class="line" id="L1796">    <span class="tok-comment">/// Collection or events for the WMI GUID is already disabled.</span></span>
<span class="line" id="L1797">    WMI_ALREADY_DISABLED = <span class="tok-number">0xC0000302</span>,</span>
<span class="line" id="L1798">    <span class="tok-comment">/// Collection or events for the WMI GUID is already enabled.</span></span>
<span class="line" id="L1799">    WMI_ALREADY_ENABLED = <span class="tok-number">0xC0000303</span>,</span>
<span class="line" id="L1800">    <span class="tok-comment">/// The master file table on the volume is too fragmented to complete this operation.</span></span>
<span class="line" id="L1801">    MFT_TOO_FRAGMENTED = <span class="tok-number">0xC0000304</span>,</span>
<span class="line" id="L1802">    <span class="tok-comment">/// Copy protection failure.</span></span>
<span class="line" id="L1803">    COPY_PROTECTION_FAILURE = <span class="tok-number">0xC0000305</span>,</span>
<span class="line" id="L1804">    <span class="tok-comment">/// Copy protection error—DVD CSS Authentication failed.</span></span>
<span class="line" id="L1805">    CSS_AUTHENTICATION_FAILURE = <span class="tok-number">0xC0000306</span>,</span>
<span class="line" id="L1806">    <span class="tok-comment">/// Copy protection error—The specified sector does not contain a valid key.</span></span>
<span class="line" id="L1807">    CSS_KEY_NOT_PRESENT = <span class="tok-number">0xC0000307</span>,</span>
<span class="line" id="L1808">    <span class="tok-comment">/// Copy protection error—DVD session key not established.</span></span>
<span class="line" id="L1809">    CSS_KEY_NOT_ESTABLISHED = <span class="tok-number">0xC0000308</span>,</span>
<span class="line" id="L1810">    <span class="tok-comment">/// Copy protection error—The read failed because the sector is encrypted.</span></span>
<span class="line" id="L1811">    CSS_SCRAMBLED_SECTOR = <span class="tok-number">0xC0000309</span>,</span>
<span class="line" id="L1812">    <span class="tok-comment">/// Copy protection error—The region of the specified DVD does not correspond to the region setting of the drive.</span></span>
<span class="line" id="L1813">    CSS_REGION_MISMATCH = <span class="tok-number">0xC000030A</span>,</span>
<span class="line" id="L1814">    <span class="tok-comment">/// Copy protection error—The region setting of the drive might be permanent.</span></span>
<span class="line" id="L1815">    CSS_RESETS_EXHAUSTED = <span class="tok-number">0xC000030B</span>,</span>
<span class="line" id="L1816">    <span class="tok-comment">/// The Kerberos protocol encountered an error while validating the KDC certificate during smart card logon.</span></span>
<span class="line" id="L1817">    <span class="tok-comment">/// There is more information in the system event log.</span></span>
<span class="line" id="L1818">    PKINIT_FAILURE = <span class="tok-number">0xC0000320</span>,</span>
<span class="line" id="L1819">    <span class="tok-comment">/// The Kerberos protocol encountered an error while attempting to use the smart card subsystem.</span></span>
<span class="line" id="L1820">    SMARTCARD_SUBSYSTEM_FAILURE = <span class="tok-number">0xC0000321</span>,</span>
<span class="line" id="L1821">    <span class="tok-comment">/// The target server does not have acceptable Kerberos credentials.</span></span>
<span class="line" id="L1822">    NO_KERB_KEY = <span class="tok-number">0xC0000322</span>,</span>
<span class="line" id="L1823">    <span class="tok-comment">/// The transport determined that the remote system is down.</span></span>
<span class="line" id="L1824">    HOST_DOWN = <span class="tok-number">0xC0000350</span>,</span>
<span class="line" id="L1825">    <span class="tok-comment">/// An unsupported pre-authentication mechanism was presented to the Kerberos package.</span></span>
<span class="line" id="L1826">    UNSUPPORTED_PREAUTH = <span class="tok-number">0xC0000351</span>,</span>
<span class="line" id="L1827">    <span class="tok-comment">/// The encryption algorithm that is used on the source file needs a bigger key buffer than the one that is used on the destination file.</span></span>
<span class="line" id="L1828">    EFS_ALG_BLOB_TOO_BIG = <span class="tok-number">0xC0000352</span>,</span>
<span class="line" id="L1829">    <span class="tok-comment">/// An attempt to remove a processes DebugPort was made, but a port was not already associated with the process.</span></span>
<span class="line" id="L1830">    PORT_NOT_SET = <span class="tok-number">0xC0000353</span>,</span>
<span class="line" id="L1831">    <span class="tok-comment">/// An attempt to do an operation on a debug port failed because the port is in the process of being deleted.</span></span>
<span class="line" id="L1832">    DEBUGGER_INACTIVE = <span class="tok-number">0xC0000354</span>,</span>
<span class="line" id="L1833">    <span class="tok-comment">/// This version of Windows is not compatible with the behavior version of the directory forest, domain, or domain controller.</span></span>
<span class="line" id="L1834">    DS_VERSION_CHECK_FAILURE = <span class="tok-number">0xC0000355</span>,</span>
<span class="line" id="L1835">    <span class="tok-comment">/// The specified event is currently not being audited.</span></span>
<span class="line" id="L1836">    AUDITING_DISABLED = <span class="tok-number">0xC0000356</span>,</span>
<span class="line" id="L1837">    <span class="tok-comment">/// The machine account was created prior to Windows NT 4.0 operating system. The account needs to be recreated.</span></span>
<span class="line" id="L1838">    PRENT4_MACHINE_ACCOUNT = <span class="tok-number">0xC0000357</span>,</span>
<span class="line" id="L1839">    <span class="tok-comment">/// An account group cannot have a universal group as a member.</span></span>
<span class="line" id="L1840">    DS_AG_CANT_HAVE_UNIVERSAL_MEMBER = <span class="tok-number">0xC0000358</span>,</span>
<span class="line" id="L1841">    <span class="tok-comment">/// The specified image file did not have the correct format; it appears to be a 32-bit Windows image.</span></span>
<span class="line" id="L1842">    INVALID_IMAGE_WIN_32 = <span class="tok-number">0xC0000359</span>,</span>
<span class="line" id="L1843">    <span class="tok-comment">/// The specified image file did not have the correct format; it appears to be a 64-bit Windows image.</span></span>
<span class="line" id="L1844">    INVALID_IMAGE_WIN_64 = <span class="tok-number">0xC000035A</span>,</span>
<span class="line" id="L1845">    <span class="tok-comment">/// The client's supplied SSPI channel bindings were incorrect.</span></span>
<span class="line" id="L1846">    BAD_BINDINGS = <span class="tok-number">0xC000035B</span>,</span>
<span class="line" id="L1847">    <span class="tok-comment">/// The client session has expired; so the client must re-authenticate to continue accessing the remote resources.</span></span>
<span class="line" id="L1848">    NETWORK_SESSION_EXPIRED = <span class="tok-number">0xC000035C</span>,</span>
<span class="line" id="L1849">    <span class="tok-comment">/// The AppHelp dialog box canceled; thus preventing the application from starting.</span></span>
<span class="line" id="L1850">    APPHELP_BLOCK = <span class="tok-number">0xC000035D</span>,</span>
<span class="line" id="L1851">    <span class="tok-comment">/// The SID filtering operation removed all SIDs.</span></span>
<span class="line" id="L1852">    ALL_SIDS_FILTERED = <span class="tok-number">0xC000035E</span>,</span>
<span class="line" id="L1853">    <span class="tok-comment">/// The driver was not loaded because the system is starting in safe mode.</span></span>
<span class="line" id="L1854">    NOT_SAFE_MODE_DRIVER = <span class="tok-number">0xC000035F</span>,</span>
<span class="line" id="L1855">    <span class="tok-comment">/// Access to %1 has been restricted by your Administrator by the default software restriction policy level.</span></span>
<span class="line" id="L1856">    ACCESS_DISABLED_BY_POLICY_DEFAULT = <span class="tok-number">0xC0000361</span>,</span>
<span class="line" id="L1857">    <span class="tok-comment">/// Access to %1 has been restricted by your Administrator by location with policy rule %2 placed on path %3.</span></span>
<span class="line" id="L1858">    ACCESS_DISABLED_BY_POLICY_PATH = <span class="tok-number">0xC0000362</span>,</span>
<span class="line" id="L1859">    <span class="tok-comment">/// Access to %1 has been restricted by your Administrator by software publisher policy.</span></span>
<span class="line" id="L1860">    ACCESS_DISABLED_BY_POLICY_PUBLISHER = <span class="tok-number">0xC0000363</span>,</span>
<span class="line" id="L1861">    <span class="tok-comment">/// Access to %1 has been restricted by your Administrator by policy rule %2.</span></span>
<span class="line" id="L1862">    ACCESS_DISABLED_BY_POLICY_OTHER = <span class="tok-number">0xC0000364</span>,</span>
<span class="line" id="L1863">    <span class="tok-comment">/// The driver was not loaded because it failed its initialization call.</span></span>
<span class="line" id="L1864">    FAILED_DRIVER_ENTRY = <span class="tok-number">0xC0000365</span>,</span>
<span class="line" id="L1865">    <span class="tok-comment">/// The device encountered an error while applying power or reading the device configuration.</span></span>
<span class="line" id="L1866">    <span class="tok-comment">/// This might be caused by a failure of your hardware or by a poor connection.</span></span>
<span class="line" id="L1867">    DEVICE_ENUMERATION_ERROR = <span class="tok-number">0xC0000366</span>,</span>
<span class="line" id="L1868">    <span class="tok-comment">/// The create operation failed because the name contained at least one mount point that resolves to a volume to which the specified device object is not attached.</span></span>
<span class="line" id="L1869">    MOUNT_POINT_NOT_RESOLVED = <span class="tok-number">0xC0000368</span>,</span>
<span class="line" id="L1870">    <span class="tok-comment">/// The device object parameter is either not a valid device object or is not attached to the volume that is specified by the file name.</span></span>
<span class="line" id="L1871">    INVALID_DEVICE_OBJECT_PARAMETER = <span class="tok-number">0xC0000369</span>,</span>
<span class="line" id="L1872">    <span class="tok-comment">/// A machine check error has occurred.</span></span>
<span class="line" id="L1873">    <span class="tok-comment">/// Check the system event log for additional information.</span></span>
<span class="line" id="L1874">    MCA_OCCURED = <span class="tok-number">0xC000036A</span>,</span>
<span class="line" id="L1875">    <span class="tok-comment">/// Driver %2 has been blocked from loading.</span></span>
<span class="line" id="L1876">    DRIVER_BLOCKED_CRITICAL = <span class="tok-number">0xC000036B</span>,</span>
<span class="line" id="L1877">    <span class="tok-comment">/// Driver %2 has been blocked from loading.</span></span>
<span class="line" id="L1878">    DRIVER_BLOCKED = <span class="tok-number">0xC000036C</span>,</span>
<span class="line" id="L1879">    <span class="tok-comment">/// There was error [%2] processing the driver database.</span></span>
<span class="line" id="L1880">    DRIVER_DATABASE_ERROR = <span class="tok-number">0xC000036D</span>,</span>
<span class="line" id="L1881">    <span class="tok-comment">/// System hive size has exceeded its limit.</span></span>
<span class="line" id="L1882">    SYSTEM_HIVE_TOO_LARGE = <span class="tok-number">0xC000036E</span>,</span>
<span class="line" id="L1883">    <span class="tok-comment">/// A dynamic link library (DLL) referenced a module that was neither a DLL nor the process's executable image.</span></span>
<span class="line" id="L1884">    INVALID_IMPORT_OF_NON_DLL = <span class="tok-number">0xC000036F</span>,</span>
<span class="line" id="L1885">    <span class="tok-comment">/// The local account store does not contain secret material for the specified account.</span></span>
<span class="line" id="L1886">    NO_SECRETS = <span class="tok-number">0xC0000371</span>,</span>
<span class="line" id="L1887">    <span class="tok-comment">/// Access to %1 has been restricted by your Administrator by policy rule %2.</span></span>
<span class="line" id="L1888">    ACCESS_DISABLED_NO_SAFER_UI_BY_POLICY = <span class="tok-number">0xC0000372</span>,</span>
<span class="line" id="L1889">    <span class="tok-comment">/// The system was not able to allocate enough memory to perform a stack switch.</span></span>
<span class="line" id="L1890">    FAILED_STACK_SWITCH = <span class="tok-number">0xC0000373</span>,</span>
<span class="line" id="L1891">    <span class="tok-comment">/// A heap has been corrupted.</span></span>
<span class="line" id="L1892">    HEAP_CORRUPTION = <span class="tok-number">0xC0000374</span>,</span>
<span class="line" id="L1893">    <span class="tok-comment">/// An incorrect PIN was presented to the smart card.</span></span>
<span class="line" id="L1894">    SMARTCARD_WRONG_PIN = <span class="tok-number">0xC0000380</span>,</span>
<span class="line" id="L1895">    <span class="tok-comment">/// The smart card is blocked.</span></span>
<span class="line" id="L1896">    SMARTCARD_CARD_BLOCKED = <span class="tok-number">0xC0000381</span>,</span>
<span class="line" id="L1897">    <span class="tok-comment">/// No PIN was presented to the smart card.</span></span>
<span class="line" id="L1898">    SMARTCARD_CARD_NOT_AUTHENTICATED = <span class="tok-number">0xC0000382</span>,</span>
<span class="line" id="L1899">    <span class="tok-comment">/// No smart card is available.</span></span>
<span class="line" id="L1900">    SMARTCARD_NO_CARD = <span class="tok-number">0xC0000383</span>,</span>
<span class="line" id="L1901">    <span class="tok-comment">/// The requested key container does not exist on the smart card.</span></span>
<span class="line" id="L1902">    SMARTCARD_NO_KEY_CONTAINER = <span class="tok-number">0xC0000384</span>,</span>
<span class="line" id="L1903">    <span class="tok-comment">/// The requested certificate does not exist on the smart card.</span></span>
<span class="line" id="L1904">    SMARTCARD_NO_CERTIFICATE = <span class="tok-number">0xC0000385</span>,</span>
<span class="line" id="L1905">    <span class="tok-comment">/// The requested keyset does not exist.</span></span>
<span class="line" id="L1906">    SMARTCARD_NO_KEYSET = <span class="tok-number">0xC0000386</span>,</span>
<span class="line" id="L1907">    <span class="tok-comment">/// A communication error with the smart card has been detected.</span></span>
<span class="line" id="L1908">    SMARTCARD_IO_ERROR = <span class="tok-number">0xC0000387</span>,</span>
<span class="line" id="L1909">    <span class="tok-comment">/// The system detected a possible attempt to compromise security.</span></span>
<span class="line" id="L1910">    <span class="tok-comment">/// Ensure that you can contact the server that authenticated you.</span></span>
<span class="line" id="L1911">    DOWNGRADE_DETECTED = <span class="tok-number">0xC0000388</span>,</span>
<span class="line" id="L1912">    <span class="tok-comment">/// The smart card certificate used for authentication has been revoked. Contact your system administrator.</span></span>
<span class="line" id="L1913">    <span class="tok-comment">/// There might be additional information in the event log.</span></span>
<span class="line" id="L1914">    SMARTCARD_CERT_REVOKED = <span class="tok-number">0xC0000389</span>,</span>
<span class="line" id="L1915">    <span class="tok-comment">/// An untrusted certificate authority was detected while processing the smart card certificate that is used for authentication. Contact your system administrator.</span></span>
<span class="line" id="L1916">    ISSUING_CA_UNTRUSTED = <span class="tok-number">0xC000038A</span>,</span>
<span class="line" id="L1917">    <span class="tok-comment">/// The revocation status of the smart card certificate that is used for authentication could not be determined. Contact your system administrator.</span></span>
<span class="line" id="L1918">    REVOCATION_OFFLINE_C = <span class="tok-number">0xC000038B</span>,</span>
<span class="line" id="L1919">    <span class="tok-comment">/// The smart card certificate used for authentication was not trusted. Contact your system administrator.</span></span>
<span class="line" id="L1920">    PKINIT_CLIENT_FAILURE = <span class="tok-number">0xC000038C</span>,</span>
<span class="line" id="L1921">    <span class="tok-comment">/// The smart card certificate used for authentication has expired. Contact your system administrator.</span></span>
<span class="line" id="L1922">    SMARTCARD_CERT_EXPIRED = <span class="tok-number">0xC000038D</span>,</span>
<span class="line" id="L1923">    <span class="tok-comment">/// The driver could not be loaded because a previous version of the driver is still in memory.</span></span>
<span class="line" id="L1924">    DRIVER_FAILED_PRIOR_UNLOAD = <span class="tok-number">0xC000038E</span>,</span>
<span class="line" id="L1925">    <span class="tok-comment">/// The smart card provider could not perform the action because the context was acquired as silent.</span></span>
<span class="line" id="L1926">    SMARTCARD_SILENT_CONTEXT = <span class="tok-number">0xC000038F</span>,</span>
<span class="line" id="L1927">    <span class="tok-comment">/// The delegated trust creation quota of the current user has been exceeded.</span></span>
<span class="line" id="L1928">    PER_USER_TRUST_QUOTA_EXCEEDED = <span class="tok-number">0xC0000401</span>,</span>
<span class="line" id="L1929">    <span class="tok-comment">/// The total delegated trust creation quota has been exceeded.</span></span>
<span class="line" id="L1930">    ALL_USER_TRUST_QUOTA_EXCEEDED = <span class="tok-number">0xC0000402</span>,</span>
<span class="line" id="L1931">    <span class="tok-comment">/// The delegated trust deletion quota of the current user has been exceeded.</span></span>
<span class="line" id="L1932">    USER_DELETE_TRUST_QUOTA_EXCEEDED = <span class="tok-number">0xC0000403</span>,</span>
<span class="line" id="L1933">    <span class="tok-comment">/// The requested name already exists as a unique identifier.</span></span>
<span class="line" id="L1934">    DS_NAME_NOT_UNIQUE = <span class="tok-number">0xC0000404</span>,</span>
<span class="line" id="L1935">    <span class="tok-comment">/// The requested object has a non-unique identifier and cannot be retrieved.</span></span>
<span class="line" id="L1936">    DS_DUPLICATE_ID_FOUND = <span class="tok-number">0xC0000405</span>,</span>
<span class="line" id="L1937">    <span class="tok-comment">/// The group cannot be converted due to attribute restrictions on the requested group type.</span></span>
<span class="line" id="L1938">    DS_GROUP_CONVERSION_ERROR = <span class="tok-number">0xC0000406</span>,</span>
<span class="line" id="L1939">    <span class="tok-comment">/// {Volume Shadow Copy Service} Wait while the Volume Shadow Copy Service prepares volume %hs for hibernation.</span></span>
<span class="line" id="L1940">    VOLSNAP_PREPARE_HIBERNATE = <span class="tok-number">0xC0000407</span>,</span>
<span class="line" id="L1941">    <span class="tok-comment">/// Kerberos sub-protocol User2User is required.</span></span>
<span class="line" id="L1942">    USER2USER_REQUIRED = <span class="tok-number">0xC0000408</span>,</span>
<span class="line" id="L1943">    <span class="tok-comment">/// The system detected an overrun of a stack-based buffer in this application.</span></span>
<span class="line" id="L1944">    <span class="tok-comment">/// This overrun could potentially allow a malicious user to gain control of this application.</span></span>
<span class="line" id="L1945">    STACK_BUFFER_OVERRUN = <span class="tok-number">0xC0000409</span>,</span>
<span class="line" id="L1946">    <span class="tok-comment">/// The Kerberos subsystem encountered an error.</span></span>
<span class="line" id="L1947">    <span class="tok-comment">/// A service for user protocol request was made against a domain controller which does not support service for user.</span></span>
<span class="line" id="L1948">    NO_S4U_PROT_SUPPORT = <span class="tok-number">0xC000040A</span>,</span>
<span class="line" id="L1949">    <span class="tok-comment">/// An attempt was made by this server to make a Kerberos constrained delegation request for a target that is outside the server realm.</span></span>
<span class="line" id="L1950">    <span class="tok-comment">/// This action is not supported and the resulting error indicates a misconfiguration on the allowed-to-delegate-to list for this server. Contact your administrator.</span></span>
<span class="line" id="L1951">    CROSSREALM_DELEGATION_FAILURE = <span class="tok-number">0xC000040B</span>,</span>
<span class="line" id="L1952">    <span class="tok-comment">/// The revocation status of the domain controller certificate used for smart card authentication could not be determined.</span></span>
<span class="line" id="L1953">    <span class="tok-comment">/// There is additional information in the system event log. Contact your system administrator.</span></span>
<span class="line" id="L1954">    REVOCATION_OFFLINE_KDC = <span class="tok-number">0xC000040C</span>,</span>
<span class="line" id="L1955">    <span class="tok-comment">/// An untrusted certificate authority was detected while processing the domain controller certificate used for authentication.</span></span>
<span class="line" id="L1956">    <span class="tok-comment">/// There is additional information in the system event log. Contact your system administrator.</span></span>
<span class="line" id="L1957">    ISSUING_CA_UNTRUSTED_KDC = <span class="tok-number">0xC000040D</span>,</span>
<span class="line" id="L1958">    <span class="tok-comment">/// The domain controller certificate used for smart card logon has expired.</span></span>
<span class="line" id="L1959">    <span class="tok-comment">/// Contact your system administrator with the contents of your system event log.</span></span>
<span class="line" id="L1960">    KDC_CERT_EXPIRED = <span class="tok-number">0xC000040E</span>,</span>
<span class="line" id="L1961">    <span class="tok-comment">/// The domain controller certificate used for smart card logon has been revoked.</span></span>
<span class="line" id="L1962">    <span class="tok-comment">/// Contact your system administrator with the contents of your system event log.</span></span>
<span class="line" id="L1963">    KDC_CERT_REVOKED = <span class="tok-number">0xC000040F</span>,</span>
<span class="line" id="L1964">    <span class="tok-comment">/// Data present in one of the parameters is more than the function can operate on.</span></span>
<span class="line" id="L1965">    PARAMETER_QUOTA_EXCEEDED = <span class="tok-number">0xC0000410</span>,</span>
<span class="line" id="L1966">    <span class="tok-comment">/// The system has failed to hibernate (The error code is %hs).</span></span>
<span class="line" id="L1967">    <span class="tok-comment">/// Hibernation will be disabled until the system is restarted.</span></span>
<span class="line" id="L1968">    HIBERNATION_FAILURE = <span class="tok-number">0xC0000411</span>,</span>
<span class="line" id="L1969">    <span class="tok-comment">/// An attempt to delay-load a .dll or get a function address in a delay-loaded .dll failed.</span></span>
<span class="line" id="L1970">    DELAY_LOAD_FAILED = <span class="tok-number">0xC0000412</span>,</span>
<span class="line" id="L1971">    <span class="tok-comment">/// Logon Failure: The machine you are logging onto is protected by an authentication firewall.</span></span>
<span class="line" id="L1972">    <span class="tok-comment">/// The specified account is not allowed to authenticate to the machine.</span></span>
<span class="line" id="L1973">    AUTHENTICATION_FIREWALL_FAILED = <span class="tok-number">0xC0000413</span>,</span>
<span class="line" id="L1974">    <span class="tok-comment">/// %hs is a 16-bit application. You do not have permissions to execute 16-bit applications.</span></span>
<span class="line" id="L1975">    <span class="tok-comment">/// Check your permissions with your system administrator.</span></span>
<span class="line" id="L1976">    VDM_DISALLOWED = <span class="tok-number">0xC0000414</span>,</span>
<span class="line" id="L1977">    <span class="tok-comment">/// {Display Driver Stopped Responding} The %hs display driver has stopped working normally.</span></span>
<span class="line" id="L1978">    <span class="tok-comment">/// Save your work and reboot the system to restore full display functionality.</span></span>
<span class="line" id="L1979">    <span class="tok-comment">/// The next time you reboot the machine a dialog will be displayed giving you a chance to report this failure to Microsoft.</span></span>
<span class="line" id="L1980">    HUNG_DISPLAY_DRIVER_THREAD = <span class="tok-number">0xC0000415</span>,</span>
<span class="line" id="L1981">    <span class="tok-comment">/// The Desktop heap encountered an error while allocating session memory.</span></span>
<span class="line" id="L1982">    <span class="tok-comment">/// There is more information in the system event log.</span></span>
<span class="line" id="L1983">    INSUFFICIENT_RESOURCE_FOR_SPECIFIED_SHARED_SECTION_SIZE = <span class="tok-number">0xC0000416</span>,</span>
<span class="line" id="L1984">    <span class="tok-comment">/// An invalid parameter was passed to a C runtime function.</span></span>
<span class="line" id="L1985">    INVALID_CRUNTIME_PARAMETER = <span class="tok-number">0xC0000417</span>,</span>
<span class="line" id="L1986">    <span class="tok-comment">/// The authentication failed because NTLM was blocked.</span></span>
<span class="line" id="L1987">    NTLM_BLOCKED = <span class="tok-number">0xC0000418</span>,</span>
<span class="line" id="L1988">    <span class="tok-comment">/// The source object's SID already exists in destination forest.</span></span>
<span class="line" id="L1989">    DS_SRC_SID_EXISTS_IN_FOREST = <span class="tok-number">0xC0000419</span>,</span>
<span class="line" id="L1990">    <span class="tok-comment">/// The domain name of the trusted domain already exists in the forest.</span></span>
<span class="line" id="L1991">    DS_DOMAIN_NAME_EXISTS_IN_FOREST = <span class="tok-number">0xC000041A</span>,</span>
<span class="line" id="L1992">    <span class="tok-comment">/// The flat name of the trusted domain already exists in the forest.</span></span>
<span class="line" id="L1993">    DS_FLAT_NAME_EXISTS_IN_FOREST = <span class="tok-number">0xC000041B</span>,</span>
<span class="line" id="L1994">    <span class="tok-comment">/// The User Principal Name (UPN) is invalid.</span></span>
<span class="line" id="L1995">    INVALID_USER_PRINCIPAL_NAME = <span class="tok-number">0xC000041C</span>,</span>
<span class="line" id="L1996">    <span class="tok-comment">/// There has been an assertion failure.</span></span>
<span class="line" id="L1997">    ASSERTION_FAILURE = <span class="tok-number">0xC0000420</span>,</span>
<span class="line" id="L1998">    <span class="tok-comment">/// Application verifier has found an error in the current process.</span></span>
<span class="line" id="L1999">    VERIFIER_STOP = <span class="tok-number">0xC0000421</span>,</span>
<span class="line" id="L2000">    <span class="tok-comment">/// A user mode unwind is in progress.</span></span>
<span class="line" id="L2001">    CALLBACK_POP_STACK = <span class="tok-number">0xC0000423</span>,</span>
<span class="line" id="L2002">    <span class="tok-comment">/// %2 has been blocked from loading due to incompatibility with this system.</span></span>
<span class="line" id="L2003">    <span class="tok-comment">/// Contact your software vendor for a compatible version of the driver.</span></span>
<span class="line" id="L2004">    INCOMPATIBLE_DRIVER_BLOCKED = <span class="tok-number">0xC0000424</span>,</span>
<span class="line" id="L2005">    <span class="tok-comment">/// Illegal operation attempted on a registry key which has already been unloaded.</span></span>
<span class="line" id="L2006">    HIVE_UNLOADED = <span class="tok-number">0xC0000425</span>,</span>
<span class="line" id="L2007">    <span class="tok-comment">/// Compression is disabled for this volume.</span></span>
<span class="line" id="L2008">    COMPRESSION_DISABLED = <span class="tok-number">0xC0000426</span>,</span>
<span class="line" id="L2009">    <span class="tok-comment">/// The requested operation could not be completed due to a file system limitation.</span></span>
<span class="line" id="L2010">    FILE_SYSTEM_LIMITATION = <span class="tok-number">0xC0000427</span>,</span>
<span class="line" id="L2011">    <span class="tok-comment">/// The hash for image %hs cannot be found in the system catalogs.</span></span>
<span class="line" id="L2012">    <span class="tok-comment">/// The image is likely corrupt or the victim of tampering.</span></span>
<span class="line" id="L2013">    INVALID_IMAGE_HASH = <span class="tok-number">0xC0000428</span>,</span>
<span class="line" id="L2014">    <span class="tok-comment">/// The implementation is not capable of performing the request.</span></span>
<span class="line" id="L2015">    NOT_CAPABLE = <span class="tok-number">0xC0000429</span>,</span>
<span class="line" id="L2016">    <span class="tok-comment">/// The requested operation is out of order with respect to other operations.</span></span>
<span class="line" id="L2017">    REQUEST_OUT_OF_SEQUENCE = <span class="tok-number">0xC000042A</span>,</span>
<span class="line" id="L2018">    <span class="tok-comment">/// An operation attempted to exceed an implementation-defined limit.</span></span>
<span class="line" id="L2019">    IMPLEMENTATION_LIMIT = <span class="tok-number">0xC000042B</span>,</span>
<span class="line" id="L2020">    <span class="tok-comment">/// The requested operation requires elevation.</span></span>
<span class="line" id="L2021">    ELEVATION_REQUIRED = <span class="tok-number">0xC000042C</span>,</span>
<span class="line" id="L2022">    <span class="tok-comment">/// The required security context does not exist.</span></span>
<span class="line" id="L2023">    NO_SECURITY_CONTEXT = <span class="tok-number">0xC000042D</span>,</span>
<span class="line" id="L2024">    <span class="tok-comment">/// The PKU2U protocol encountered an error while attempting to utilize the associated certificates.</span></span>
<span class="line" id="L2025">    PKU2U_CERT_FAILURE = <span class="tok-number">0xC000042E</span>,</span>
<span class="line" id="L2026">    <span class="tok-comment">/// The operation was attempted beyond the valid data length of the file.</span></span>
<span class="line" id="L2027">    BEYOND_VDL = <span class="tok-number">0xC0000432</span>,</span>
<span class="line" id="L2028">    <span class="tok-comment">/// The attempted write operation encountered a write already in progress for some portion of the range.</span></span>
<span class="line" id="L2029">    ENCOUNTERED_WRITE_IN_PROGRESS = <span class="tok-number">0xC0000433</span>,</span>
<span class="line" id="L2030">    <span class="tok-comment">/// The page fault mappings changed in the middle of processing a fault so the operation must be retried.</span></span>
<span class="line" id="L2031">    PTE_CHANGED = <span class="tok-number">0xC0000434</span>,</span>
<span class="line" id="L2032">    <span class="tok-comment">/// The attempt to purge this file from memory failed to purge some or all the data from memory.</span></span>
<span class="line" id="L2033">    PURGE_FAILED = <span class="tok-number">0xC0000435</span>,</span>
<span class="line" id="L2034">    <span class="tok-comment">/// The requested credential requires confirmation.</span></span>
<span class="line" id="L2035">    CRED_REQUIRES_CONFIRMATION = <span class="tok-number">0xC0000440</span>,</span>
<span class="line" id="L2036">    <span class="tok-comment">/// The remote server sent an invalid response for a file being opened with Client Side Encryption.</span></span>
<span class="line" id="L2037">    CS_ENCRYPTION_INVALID_SERVER_RESPONSE = <span class="tok-number">0xC0000441</span>,</span>
<span class="line" id="L2038">    <span class="tok-comment">/// Client Side Encryption is not supported by the remote server even though it claims to support it.</span></span>
<span class="line" id="L2039">    CS_ENCRYPTION_UNSUPPORTED_SERVER = <span class="tok-number">0xC0000442</span>,</span>
<span class="line" id="L2040">    <span class="tok-comment">/// File is encrypted and should be opened in Client Side Encryption mode.</span></span>
<span class="line" id="L2041">    CS_ENCRYPTION_EXISTING_ENCRYPTED_FILE = <span class="tok-number">0xC0000443</span>,</span>
<span class="line" id="L2042">    <span class="tok-comment">/// A new encrypted file is being created and a $EFS needs to be provided.</span></span>
<span class="line" id="L2043">    CS_ENCRYPTION_NEW_ENCRYPTED_FILE = <span class="tok-number">0xC0000444</span>,</span>
<span class="line" id="L2044">    <span class="tok-comment">/// The SMB client requested a CSE FSCTL on a non-CSE file.</span></span>
<span class="line" id="L2045">    CS_ENCRYPTION_FILE_NOT_CSE = <span class="tok-number">0xC0000445</span>,</span>
<span class="line" id="L2046">    <span class="tok-comment">/// Indicates a particular Security ID cannot be assigned as the label of an object.</span></span>
<span class="line" id="L2047">    INVALID_LABEL = <span class="tok-number">0xC0000446</span>,</span>
<span class="line" id="L2048">    <span class="tok-comment">/// The process hosting the driver for this device has terminated.</span></span>
<span class="line" id="L2049">    DRIVER_PROCESS_TERMINATED = <span class="tok-number">0xC0000450</span>,</span>
<span class="line" id="L2050">    <span class="tok-comment">/// The requested system device cannot be identified due to multiple indistinguishable devices potentially matching the identification criteria.</span></span>
<span class="line" id="L2051">    AMBIGUOUS_SYSTEM_DEVICE = <span class="tok-number">0xC0000451</span>,</span>
<span class="line" id="L2052">    <span class="tok-comment">/// The requested system device cannot be found.</span></span>
<span class="line" id="L2053">    SYSTEM_DEVICE_NOT_FOUND = <span class="tok-number">0xC0000452</span>,</span>
<span class="line" id="L2054">    <span class="tok-comment">/// This boot application must be restarted.</span></span>
<span class="line" id="L2055">    RESTART_BOOT_APPLICATION = <span class="tok-number">0xC0000453</span>,</span>
<span class="line" id="L2056">    <span class="tok-comment">/// Insufficient NVRAM resources exist to complete the API.  A reboot might be required.</span></span>
<span class="line" id="L2057">    INSUFFICIENT_NVRAM_RESOURCES = <span class="tok-number">0xC0000454</span>,</span>
<span class="line" id="L2058">    <span class="tok-comment">/// No ranges for the specified operation were able to be processed.</span></span>
<span class="line" id="L2059">    NO_RANGES_PROCESSED = <span class="tok-number">0xC0000460</span>,</span>
<span class="line" id="L2060">    <span class="tok-comment">/// The storage device does not support Offload Write.</span></span>
<span class="line" id="L2061">    DEVICE_FEATURE_NOT_SUPPORTED = <span class="tok-number">0xC0000463</span>,</span>
<span class="line" id="L2062">    <span class="tok-comment">/// Data cannot be moved because the source device cannot communicate with the destination device.</span></span>
<span class="line" id="L2063">    DEVICE_UNREACHABLE = <span class="tok-number">0xC0000464</span>,</span>
<span class="line" id="L2064">    <span class="tok-comment">/// The token representing the data is invalid or expired.</span></span>
<span class="line" id="L2065">    INVALID_TOKEN = <span class="tok-number">0xC0000465</span>,</span>
<span class="line" id="L2066">    <span class="tok-comment">/// The file server is temporarily unavailable.</span></span>
<span class="line" id="L2067">    SERVER_UNAVAILABLE = <span class="tok-number">0xC0000466</span>,</span>
<span class="line" id="L2068">    <span class="tok-comment">/// The specified task name is invalid.</span></span>
<span class="line" id="L2069">    INVALID_TASK_NAME = <span class="tok-number">0xC0000500</span>,</span>
<span class="line" id="L2070">    <span class="tok-comment">/// The specified task index is invalid.</span></span>
<span class="line" id="L2071">    INVALID_TASK_INDEX = <span class="tok-number">0xC0000501</span>,</span>
<span class="line" id="L2072">    <span class="tok-comment">/// The specified thread is already joining a task.</span></span>
<span class="line" id="L2073">    THREAD_ALREADY_IN_TASK = <span class="tok-number">0xC0000502</span>,</span>
<span class="line" id="L2074">    <span class="tok-comment">/// A callback has requested to bypass native code.</span></span>
<span class="line" id="L2075">    CALLBACK_BYPASS = <span class="tok-number">0xC0000503</span>,</span>
<span class="line" id="L2076">    <span class="tok-comment">/// A fail fast exception occurred.</span></span>
<span class="line" id="L2077">    <span class="tok-comment">/// Exception handlers will not be invoked and the process will be terminated immediately.</span></span>
<span class="line" id="L2078">    FAIL_FAST_EXCEPTION = <span class="tok-number">0xC0000602</span>,</span>
<span class="line" id="L2079">    <span class="tok-comment">/// Windows cannot verify the digital signature for this file.</span></span>
<span class="line" id="L2080">    <span class="tok-comment">/// The signing certificate for this file has been revoked.</span></span>
<span class="line" id="L2081">    IMAGE_CERT_REVOKED = <span class="tok-number">0xC0000603</span>,</span>
<span class="line" id="L2082">    <span class="tok-comment">/// The ALPC port is closed.</span></span>
<span class="line" id="L2083">    PORT_CLOSED = <span class="tok-number">0xC0000700</span>,</span>
<span class="line" id="L2084">    <span class="tok-comment">/// The ALPC message requested is no longer available.</span></span>
<span class="line" id="L2085">    MESSAGE_LOST = <span class="tok-number">0xC0000701</span>,</span>
<span class="line" id="L2086">    <span class="tok-comment">/// The ALPC message supplied is invalid.</span></span>
<span class="line" id="L2087">    INVALID_MESSAGE = <span class="tok-number">0xC0000702</span>,</span>
<span class="line" id="L2088">    <span class="tok-comment">/// The ALPC message has been canceled.</span></span>
<span class="line" id="L2089">    REQUEST_CANCELED = <span class="tok-number">0xC0000703</span>,</span>
<span class="line" id="L2090">    <span class="tok-comment">/// Invalid recursive dispatch attempt.</span></span>
<span class="line" id="L2091">    RECURSIVE_DISPATCH = <span class="tok-number">0xC0000704</span>,</span>
<span class="line" id="L2092">    <span class="tok-comment">/// No receive buffer has been supplied in a synchronous request.</span></span>
<span class="line" id="L2093">    LPC_RECEIVE_BUFFER_EXPECTED = <span class="tok-number">0xC0000705</span>,</span>
<span class="line" id="L2094">    <span class="tok-comment">/// The connection port is used in an invalid context.</span></span>
<span class="line" id="L2095">    LPC_INVALID_CONNECTION_USAGE = <span class="tok-number">0xC0000706</span>,</span>
<span class="line" id="L2096">    <span class="tok-comment">/// The ALPC port does not accept new request messages.</span></span>
<span class="line" id="L2097">    LPC_REQUESTS_NOT_ALLOWED = <span class="tok-number">0xC0000707</span>,</span>
<span class="line" id="L2098">    <span class="tok-comment">/// The resource requested is already in use.</span></span>
<span class="line" id="L2099">    RESOURCE_IN_USE = <span class="tok-number">0xC0000708</span>,</span>
<span class="line" id="L2100">    <span class="tok-comment">/// The hardware has reported an uncorrectable memory error.</span></span>
<span class="line" id="L2101">    HARDWARE_MEMORY_ERROR = <span class="tok-number">0xC0000709</span>,</span>
<span class="line" id="L2102">    <span class="tok-comment">/// Status 0x%08x was returned, waiting on handle 0x%x for wait 0x%p, in waiter 0x%p.</span></span>
<span class="line" id="L2103">    THREADPOOL_HANDLE_EXCEPTION = <span class="tok-number">0xC000070A</span>,</span>
<span class="line" id="L2104">    <span class="tok-comment">/// After a callback to 0x%p(0x%p), a completion call to Set event(0x%p) failed with status 0x%08x.</span></span>
<span class="line" id="L2105">    THREADPOOL_SET_EVENT_ON_COMPLETION_FAILED = <span class="tok-number">0xC000070B</span>,</span>
<span class="line" id="L2106">    <span class="tok-comment">/// After a callback to 0x%p(0x%p), a completion call to ReleaseSemaphore(0x%p, %d) failed with status 0x%08x.</span></span>
<span class="line" id="L2107">    THREADPOOL_RELEASE_SEMAPHORE_ON_COMPLETION_FAILED = <span class="tok-number">0xC000070C</span>,</span>
<span class="line" id="L2108">    <span class="tok-comment">/// After a callback to 0x%p(0x%p), a completion call to ReleaseMutex(%p) failed with status 0x%08x.</span></span>
<span class="line" id="L2109">    THREADPOOL_RELEASE_MUTEX_ON_COMPLETION_FAILED = <span class="tok-number">0xC000070D</span>,</span>
<span class="line" id="L2110">    <span class="tok-comment">/// After a callback to 0x%p(0x%p), a completion call to FreeLibrary(%p) failed with status 0x%08x.</span></span>
<span class="line" id="L2111">    THREADPOOL_FREE_LIBRARY_ON_COMPLETION_FAILED = <span class="tok-number">0xC000070E</span>,</span>
<span class="line" id="L2112">    <span class="tok-comment">/// The thread pool 0x%p was released while a thread was posting a callback to 0x%p(0x%p) to it.</span></span>
<span class="line" id="L2113">    THREADPOOL_RELEASED_DURING_OPERATION = <span class="tok-number">0xC000070F</span>,</span>
<span class="line" id="L2114">    <span class="tok-comment">/// A thread pool worker thread is impersonating a client, after a callback to 0x%p(0x%p).</span></span>
<span class="line" id="L2115">    <span class="tok-comment">/// This is unexpected, indicating that the callback is missing a call to revert the impersonation.</span></span>
<span class="line" id="L2116">    CALLBACK_RETURNED_WHILE_IMPERSONATING = <span class="tok-number">0xC0000710</span>,</span>
<span class="line" id="L2117">    <span class="tok-comment">/// A thread pool worker thread is impersonating a client, after executing an APC.</span></span>
<span class="line" id="L2118">    <span class="tok-comment">/// This is unexpected, indicating that the APC is missing a call to revert the impersonation.</span></span>
<span class="line" id="L2119">    APC_RETURNED_WHILE_IMPERSONATING = <span class="tok-number">0xC0000711</span>,</span>
<span class="line" id="L2120">    <span class="tok-comment">/// Either the target process, or the target thread's containing process, is a protected process.</span></span>
<span class="line" id="L2121">    PROCESS_IS_PROTECTED = <span class="tok-number">0xC0000712</span>,</span>
<span class="line" id="L2122">    <span class="tok-comment">/// A thread is getting dispatched with MCA EXCEPTION because of MCA.</span></span>
<span class="line" id="L2123">    MCA_EXCEPTION = <span class="tok-number">0xC0000713</span>,</span>
<span class="line" id="L2124">    <span class="tok-comment">/// The client certificate account mapping is not unique.</span></span>
<span class="line" id="L2125">    CERTIFICATE_MAPPING_NOT_UNIQUE = <span class="tok-number">0xC0000714</span>,</span>
<span class="line" id="L2126">    <span class="tok-comment">/// The symbolic link cannot be followed because its type is disabled.</span></span>
<span class="line" id="L2127">    SYMLINK_CLASS_DISABLED = <span class="tok-number">0xC0000715</span>,</span>
<span class="line" id="L2128">    <span class="tok-comment">/// Indicates that the specified string is not valid for IDN normalization.</span></span>
<span class="line" id="L2129">    INVALID_IDN_NORMALIZATION = <span class="tok-number">0xC0000716</span>,</span>
<span class="line" id="L2130">    <span class="tok-comment">/// No mapping for the Unicode character exists in the target multi-byte code page.</span></span>
<span class="line" id="L2131">    NO_UNICODE_TRANSLATION = <span class="tok-number">0xC0000717</span>,</span>
<span class="line" id="L2132">    <span class="tok-comment">/// The provided callback is already registered.</span></span>
<span class="line" id="L2133">    ALREADY_REGISTERED = <span class="tok-number">0xC0000718</span>,</span>
<span class="line" id="L2134">    <span class="tok-comment">/// The provided context did not match the target.</span></span>
<span class="line" id="L2135">    CONTEXT_MISMATCH = <span class="tok-number">0xC0000719</span>,</span>
<span class="line" id="L2136">    <span class="tok-comment">/// The specified port already has a completion list.</span></span>
<span class="line" id="L2137">    PORT_ALREADY_HAS_COMPLETION_LIST = <span class="tok-number">0xC000071A</span>,</span>
<span class="line" id="L2138">    <span class="tok-comment">/// A threadpool worker thread entered a callback at thread base priority 0x%x and exited at priority 0x%x.</span></span>
<span class="line" id="L2139">    <span class="tok-comment">/// This is unexpected, indicating that the callback missed restoring the priority.</span></span>
<span class="line" id="L2140">    CALLBACK_RETURNED_THREAD_PRIORITY = <span class="tok-number">0xC000071B</span>,</span>
<span class="line" id="L2141">    <span class="tok-comment">/// An invalid thread, handle %p, is specified for this operation.</span></span>
<span class="line" id="L2142">    <span class="tok-comment">/// Possibly, a threadpool worker thread was specified.</span></span>
<span class="line" id="L2143">    INVALID_THREAD = <span class="tok-number">0xC000071C</span>,</span>
<span class="line" id="L2144">    <span class="tok-comment">/// A threadpool worker thread entered a callback, which left transaction state.</span></span>
<span class="line" id="L2145">    <span class="tok-comment">/// This is unexpected, indicating that the callback missed clearing the transaction.</span></span>
<span class="line" id="L2146">    CALLBACK_RETURNED_TRANSACTION = <span class="tok-number">0xC000071D</span>,</span>
<span class="line" id="L2147">    <span class="tok-comment">/// A threadpool worker thread entered a callback, which left the loader lock held.</span></span>
<span class="line" id="L2148">    <span class="tok-comment">/// This is unexpected, indicating that the callback missed releasing the lock.</span></span>
<span class="line" id="L2149">    CALLBACK_RETURNED_LDR_LOCK = <span class="tok-number">0xC000071E</span>,</span>
<span class="line" id="L2150">    <span class="tok-comment">/// A threadpool worker thread entered a callback, which left with preferred languages set.</span></span>
<span class="line" id="L2151">    <span class="tok-comment">/// This is unexpected, indicating that the callback missed clearing them.</span></span>
<span class="line" id="L2152">    CALLBACK_RETURNED_LANG = <span class="tok-number">0xC000071F</span>,</span>
<span class="line" id="L2153">    <span class="tok-comment">/// A threadpool worker thread entered a callback, which left with background priorities set.</span></span>
<span class="line" id="L2154">    <span class="tok-comment">/// This is unexpected, indicating that the callback missed restoring the original priorities.</span></span>
<span class="line" id="L2155">    CALLBACK_RETURNED_PRI_BACK = <span class="tok-number">0xC0000720</span>,</span>
<span class="line" id="L2156">    <span class="tok-comment">/// The attempted operation required self healing to be enabled.</span></span>
<span class="line" id="L2157">    DISK_REPAIR_DISABLED = <span class="tok-number">0xC0000800</span>,</span>
<span class="line" id="L2158">    <span class="tok-comment">/// The directory service cannot perform the requested operation because a domain rename operation is in progress.</span></span>
<span class="line" id="L2159">    DS_DOMAIN_RENAME_IN_PROGRESS = <span class="tok-number">0xC0000801</span>,</span>
<span class="line" id="L2160">    <span class="tok-comment">/// An operation failed because the storage quota was exceeded.</span></span>
<span class="line" id="L2161">    DISK_QUOTA_EXCEEDED = <span class="tok-number">0xC0000802</span>,</span>
<span class="line" id="L2162">    <span class="tok-comment">/// An operation failed because the content was blocked.</span></span>
<span class="line" id="L2163">    CONTENT_BLOCKED = <span class="tok-number">0xC0000804</span>,</span>
<span class="line" id="L2164">    <span class="tok-comment">/// The operation could not be completed due to bad clusters on disk.</span></span>
<span class="line" id="L2165">    BAD_CLUSTERS = <span class="tok-number">0xC0000805</span>,</span>
<span class="line" id="L2166">    <span class="tok-comment">/// The operation could not be completed because the volume is dirty. Please run the Chkdsk utility and try again.</span></span>
<span class="line" id="L2167">    VOLUME_DIRTY = <span class="tok-number">0xC0000806</span>,</span>
<span class="line" id="L2168">    <span class="tok-comment">/// This file is checked out or locked for editing by another user.</span></span>
<span class="line" id="L2169">    FILE_CHECKED_OUT = <span class="tok-number">0xC0000901</span>,</span>
<span class="line" id="L2170">    <span class="tok-comment">/// The file must be checked out before saving changes.</span></span>
<span class="line" id="L2171">    CHECKOUT_REQUIRED = <span class="tok-number">0xC0000902</span>,</span>
<span class="line" id="L2172">    <span class="tok-comment">/// The file type being saved or retrieved has been blocked.</span></span>
<span class="line" id="L2173">    BAD_FILE_TYPE = <span class="tok-number">0xC0000903</span>,</span>
<span class="line" id="L2174">    <span class="tok-comment">/// The file size exceeds the limit allowed and cannot be saved.</span></span>
<span class="line" id="L2175">    FILE_TOO_LARGE = <span class="tok-number">0xC0000904</span>,</span>
<span class="line" id="L2176">    <span class="tok-comment">/// Access Denied. Before opening files in this location, you must first browse to the e.g.</span></span>
<span class="line" id="L2177">    <span class="tok-comment">/// site and select the option to log on automatically.</span></span>
<span class="line" id="L2178">    FORMS_AUTH_REQUIRED = <span class="tok-number">0xC0000905</span>,</span>
<span class="line" id="L2179">    <span class="tok-comment">/// The operation did not complete successfully because the file contains a virus.</span></span>
<span class="line" id="L2180">    VIRUS_INFECTED = <span class="tok-number">0xC0000906</span>,</span>
<span class="line" id="L2181">    <span class="tok-comment">/// This file contains a virus and cannot be opened.</span></span>
<span class="line" id="L2182">    <span class="tok-comment">/// Due to the nature of this virus, the file has been removed from this location.</span></span>
<span class="line" id="L2183">    VIRUS_DELETED = <span class="tok-number">0xC0000907</span>,</span>
<span class="line" id="L2184">    <span class="tok-comment">/// The resources required for this device conflict with the MCFG table.</span></span>
<span class="line" id="L2185">    BAD_MCFG_TABLE = <span class="tok-number">0xC0000908</span>,</span>
<span class="line" id="L2186">    <span class="tok-comment">/// The operation did not complete successfully because it would cause an oplock to be broken.</span></span>
<span class="line" id="L2187">    <span class="tok-comment">/// The caller has requested that existing oplocks not be broken.</span></span>
<span class="line" id="L2188">    CANNOT_BREAK_OPLOCK = <span class="tok-number">0xC0000909</span>,</span>
<span class="line" id="L2189">    <span class="tok-comment">/// WOW Assertion Error.</span></span>
<span class="line" id="L2190">    WOW_ASSERTION = <span class="tok-number">0xC0009898</span>,</span>
<span class="line" id="L2191">    <span class="tok-comment">/// The cryptographic signature is invalid.</span></span>
<span class="line" id="L2192">    INVALID_SIGNATURE = <span class="tok-number">0xC000A000</span>,</span>
<span class="line" id="L2193">    <span class="tok-comment">/// The cryptographic provider does not support HMAC.</span></span>
<span class="line" id="L2194">    HMAC_NOT_SUPPORTED = <span class="tok-number">0xC000A001</span>,</span>
<span class="line" id="L2195">    <span class="tok-comment">/// The IPsec queue overflowed.</span></span>
<span class="line" id="L2196">    IPSEC_QUEUE_OVERFLOW = <span class="tok-number">0xC000A010</span>,</span>
<span class="line" id="L2197">    <span class="tok-comment">/// The neighbor discovery queue overflowed.</span></span>
<span class="line" id="L2198">    ND_QUEUE_OVERFLOW = <span class="tok-number">0xC000A011</span>,</span>
<span class="line" id="L2199">    <span class="tok-comment">/// An Internet Control Message Protocol (ICMP) hop limit exceeded error was received.</span></span>
<span class="line" id="L2200">    HOPLIMIT_EXCEEDED = <span class="tok-number">0xC000A012</span>,</span>
<span class="line" id="L2201">    <span class="tok-comment">/// The protocol is not installed on the local machine.</span></span>
<span class="line" id="L2202">    PROTOCOL_NOT_SUPPORTED = <span class="tok-number">0xC000A013</span>,</span>
<span class="line" id="L2203">    <span class="tok-comment">/// {Delayed Write Failed} Windows was unable to save all the data for the file %hs; the data has been lost.</span></span>
<span class="line" id="L2204">    <span class="tok-comment">/// This error might be caused by network connectivity issues. Try to save this file elsewhere.</span></span>
<span class="line" id="L2205">    LOST_WRITEBEHIND_DATA_NETWORK_DISCONNECTED = <span class="tok-number">0xC000A080</span>,</span>
<span class="line" id="L2206">    <span class="tok-comment">/// {Delayed Write Failed} Windows was unable to save all the data for the file %hs; the data has been lost.</span></span>
<span class="line" id="L2207">    <span class="tok-comment">/// This error was returned by the server on which the file exists. Try to save this file elsewhere.</span></span>
<span class="line" id="L2208">    LOST_WRITEBEHIND_DATA_NETWORK_SERVER_ERROR = <span class="tok-number">0xC000A081</span>,</span>
<span class="line" id="L2209">    <span class="tok-comment">/// {Delayed Write Failed} Windows was unable to save all the data for the file %hs; the data has been lost.</span></span>
<span class="line" id="L2210">    <span class="tok-comment">/// This error might be caused if the device has been removed or the media is write-protected.</span></span>
<span class="line" id="L2211">    LOST_WRITEBEHIND_DATA_LOCAL_DISK_ERROR = <span class="tok-number">0xC000A082</span>,</span>
<span class="line" id="L2212">    <span class="tok-comment">/// Windows was unable to parse the requested XML data.</span></span>
<span class="line" id="L2213">    XML_PARSE_ERROR = <span class="tok-number">0xC000A083</span>,</span>
<span class="line" id="L2214">    <span class="tok-comment">/// An error was encountered while processing an XML digital signature.</span></span>
<span class="line" id="L2215">    XMLDSIG_ERROR = <span class="tok-number">0xC000A084</span>,</span>
<span class="line" id="L2216">    <span class="tok-comment">/// This indicates that the caller made the connection request in the wrong routing compartment.</span></span>
<span class="line" id="L2217">    WRONG_COMPARTMENT = <span class="tok-number">0xC000A085</span>,</span>
<span class="line" id="L2218">    <span class="tok-comment">/// This indicates that there was an AuthIP failure when attempting to connect to the remote host.</span></span>
<span class="line" id="L2219">    AUTHIP_FAILURE = <span class="tok-number">0xC000A086</span>,</span>
<span class="line" id="L2220">    <span class="tok-comment">/// OID mapped groups cannot have members.</span></span>
<span class="line" id="L2221">    DS_OID_MAPPED_GROUP_CANT_HAVE_MEMBERS = <span class="tok-number">0xC000A087</span>,</span>
<span class="line" id="L2222">    <span class="tok-comment">/// The specified OID cannot be found.</span></span>
<span class="line" id="L2223">    DS_OID_NOT_FOUND = <span class="tok-number">0xC000A088</span>,</span>
<span class="line" id="L2224">    <span class="tok-comment">/// Hash generation for the specified version and hash type is not enabled on server.</span></span>
<span class="line" id="L2225">    HASH_NOT_SUPPORTED = <span class="tok-number">0xC000A100</span>,</span>
<span class="line" id="L2226">    <span class="tok-comment">/// The hash requests is not present or not up to date with the current file contents.</span></span>
<span class="line" id="L2227">    HASH_NOT_PRESENT = <span class="tok-number">0xC000A101</span>,</span>
<span class="line" id="L2228">    <span class="tok-comment">/// A file system filter on the server has not opted in for Offload Read support.</span></span>
<span class="line" id="L2229">    OFFLOAD_READ_FLT_NOT_SUPPORTED = <span class="tok-number">0xC000A2A1</span>,</span>
<span class="line" id="L2230">    <span class="tok-comment">/// A file system filter on the server has not opted in for Offload Write support.</span></span>
<span class="line" id="L2231">    OFFLOAD_WRITE_FLT_NOT_SUPPORTED = <span class="tok-number">0xC000A2A2</span>,</span>
<span class="line" id="L2232">    <span class="tok-comment">/// Offload read operations cannot be performed on:</span></span>
<span class="line" id="L2233">    <span class="tok-comment">///   - Compressed files</span></span>
<span class="line" id="L2234">    <span class="tok-comment">///   - Sparse files</span></span>
<span class="line" id="L2235">    <span class="tok-comment">///   - Encrypted files</span></span>
<span class="line" id="L2236">    <span class="tok-comment">///   - File system metadata files</span></span>
<span class="line" id="L2237">    OFFLOAD_READ_FILE_NOT_SUPPORTED = <span class="tok-number">0xC000A2A3</span>,</span>
<span class="line" id="L2238">    <span class="tok-comment">/// Offload write operations cannot be performed on:</span></span>
<span class="line" id="L2239">    <span class="tok-comment">///  - Compressed files</span></span>
<span class="line" id="L2240">    <span class="tok-comment">///  - Sparse files</span></span>
<span class="line" id="L2241">    <span class="tok-comment">///  - Encrypted files</span></span>
<span class="line" id="L2242">    <span class="tok-comment">///  - File system metadata files</span></span>
<span class="line" id="L2243">    OFFLOAD_WRITE_FILE_NOT_SUPPORTED = <span class="tok-number">0xC000A2A4</span>,</span>
<span class="line" id="L2244">    <span class="tok-comment">/// The debugger did not perform a state change.</span></span>
<span class="line" id="L2245">    DBG_NO_STATE_CHANGE = <span class="tok-number">0xC0010001</span>,</span>
<span class="line" id="L2246">    <span class="tok-comment">/// The debugger found that the application is not idle.</span></span>
<span class="line" id="L2247">    DBG_APP_NOT_IDLE = <span class="tok-number">0xC0010002</span>,</span>
<span class="line" id="L2248">    <span class="tok-comment">/// The string binding is invalid.</span></span>
<span class="line" id="L2249">    RPC_NT_INVALID_STRING_BINDING = <span class="tok-number">0xC0020001</span>,</span>
<span class="line" id="L2250">    <span class="tok-comment">/// The binding handle is not the correct type.</span></span>
<span class="line" id="L2251">    RPC_NT_WRONG_KIND_OF_BINDING = <span class="tok-number">0xC0020002</span>,</span>
<span class="line" id="L2252">    <span class="tok-comment">/// The binding handle is invalid.</span></span>
<span class="line" id="L2253">    RPC_NT_INVALID_BINDING = <span class="tok-number">0xC0020003</span>,</span>
<span class="line" id="L2254">    <span class="tok-comment">/// The RPC protocol sequence is not supported.</span></span>
<span class="line" id="L2255">    RPC_NT_PROTSEQ_NOT_SUPPORTED = <span class="tok-number">0xC0020004</span>,</span>
<span class="line" id="L2256">    <span class="tok-comment">/// The RPC protocol sequence is invalid.</span></span>
<span class="line" id="L2257">    RPC_NT_INVALID_RPC_PROTSEQ = <span class="tok-number">0xC0020005</span>,</span>
<span class="line" id="L2258">    <span class="tok-comment">/// The string UUID is invalid.</span></span>
<span class="line" id="L2259">    RPC_NT_INVALID_STRING_UUID = <span class="tok-number">0xC0020006</span>,</span>
<span class="line" id="L2260">    <span class="tok-comment">/// The endpoint format is invalid.</span></span>
<span class="line" id="L2261">    RPC_NT_INVALID_ENDPOINT_FORMAT = <span class="tok-number">0xC0020007</span>,</span>
<span class="line" id="L2262">    <span class="tok-comment">/// The network address is invalid.</span></span>
<span class="line" id="L2263">    RPC_NT_INVALID_NET_ADDR = <span class="tok-number">0xC0020008</span>,</span>
<span class="line" id="L2264">    <span class="tok-comment">/// No endpoint was found.</span></span>
<span class="line" id="L2265">    RPC_NT_NO_ENDPOINT_FOUND = <span class="tok-number">0xC0020009</span>,</span>
<span class="line" id="L2266">    <span class="tok-comment">/// The time-out value is invalid.</span></span>
<span class="line" id="L2267">    RPC_NT_INVALID_TIMEOUT = <span class="tok-number">0xC002000A</span>,</span>
<span class="line" id="L2268">    <span class="tok-comment">/// The object UUID was not found.</span></span>
<span class="line" id="L2269">    RPC_NT_OBJECT_NOT_FOUND = <span class="tok-number">0xC002000B</span>,</span>
<span class="line" id="L2270">    <span class="tok-comment">/// The object UUID has already been registered.</span></span>
<span class="line" id="L2271">    RPC_NT_ALREADY_REGISTERED = <span class="tok-number">0xC002000C</span>,</span>
<span class="line" id="L2272">    <span class="tok-comment">/// The type UUID has already been registered.</span></span>
<span class="line" id="L2273">    RPC_NT_TYPE_ALREADY_REGISTERED = <span class="tok-number">0xC002000D</span>,</span>
<span class="line" id="L2274">    <span class="tok-comment">/// The RPC server is already listening.</span></span>
<span class="line" id="L2275">    RPC_NT_ALREADY_LISTENING = <span class="tok-number">0xC002000E</span>,</span>
<span class="line" id="L2276">    <span class="tok-comment">/// No protocol sequences have been registered.</span></span>
<span class="line" id="L2277">    RPC_NT_NO_PROTSEQS_REGISTERED = <span class="tok-number">0xC002000F</span>,</span>
<span class="line" id="L2278">    <span class="tok-comment">/// The RPC server is not listening.</span></span>
<span class="line" id="L2279">    RPC_NT_NOT_LISTENING = <span class="tok-number">0xC0020010</span>,</span>
<span class="line" id="L2280">    <span class="tok-comment">/// The manager type is unknown.</span></span>
<span class="line" id="L2281">    RPC_NT_UNKNOWN_MGR_TYPE = <span class="tok-number">0xC0020011</span>,</span>
<span class="line" id="L2282">    <span class="tok-comment">/// The interface is unknown.</span></span>
<span class="line" id="L2283">    RPC_NT_UNKNOWN_IF = <span class="tok-number">0xC0020012</span>,</span>
<span class="line" id="L2284">    <span class="tok-comment">/// There are no bindings.</span></span>
<span class="line" id="L2285">    RPC_NT_NO_BINDINGS = <span class="tok-number">0xC0020013</span>,</span>
<span class="line" id="L2286">    <span class="tok-comment">/// There are no protocol sequences.</span></span>
<span class="line" id="L2287">    RPC_NT_NO_PROTSEQS = <span class="tok-number">0xC0020014</span>,</span>
<span class="line" id="L2288">    <span class="tok-comment">/// The endpoint cannot be created.</span></span>
<span class="line" id="L2289">    RPC_NT_CANT_CREATE_ENDPOINT = <span class="tok-number">0xC0020015</span>,</span>
<span class="line" id="L2290">    <span class="tok-comment">/// Insufficient resources are available to complete this operation.</span></span>
<span class="line" id="L2291">    RPC_NT_OUT_OF_RESOURCES = <span class="tok-number">0xC0020016</span>,</span>
<span class="line" id="L2292">    <span class="tok-comment">/// The RPC server is unavailable.</span></span>
<span class="line" id="L2293">    RPC_NT_SERVER_UNAVAILABLE = <span class="tok-number">0xC0020017</span>,</span>
<span class="line" id="L2294">    <span class="tok-comment">/// The RPC server is too busy to complete this operation.</span></span>
<span class="line" id="L2295">    RPC_NT_SERVER_TOO_BUSY = <span class="tok-number">0xC0020018</span>,</span>
<span class="line" id="L2296">    <span class="tok-comment">/// The network options are invalid.</span></span>
<span class="line" id="L2297">    RPC_NT_INVALID_NETWORK_OPTIONS = <span class="tok-number">0xC0020019</span>,</span>
<span class="line" id="L2298">    <span class="tok-comment">/// No RPCs are active on this thread.</span></span>
<span class="line" id="L2299">    RPC_NT_NO_CALL_ACTIVE = <span class="tok-number">0xC002001A</span>,</span>
<span class="line" id="L2300">    <span class="tok-comment">/// The RPC failed.</span></span>
<span class="line" id="L2301">    RPC_NT_CALL_FAILED = <span class="tok-number">0xC002001B</span>,</span>
<span class="line" id="L2302">    <span class="tok-comment">/// The RPC failed and did not execute.</span></span>
<span class="line" id="L2303">    RPC_NT_CALL_FAILED_DNE = <span class="tok-number">0xC002001C</span>,</span>
<span class="line" id="L2304">    <span class="tok-comment">/// An RPC protocol error occurred.</span></span>
<span class="line" id="L2305">    RPC_NT_PROTOCOL_ERROR = <span class="tok-number">0xC002001D</span>,</span>
<span class="line" id="L2306">    <span class="tok-comment">/// The RPC server does not support the transfer syntax.</span></span>
<span class="line" id="L2307">    RPC_NT_UNSUPPORTED_TRANS_SYN = <span class="tok-number">0xC002001F</span>,</span>
<span class="line" id="L2308">    <span class="tok-comment">/// The type UUID is not supported.</span></span>
<span class="line" id="L2309">    RPC_NT_UNSUPPORTED_TYPE = <span class="tok-number">0xC0020021</span>,</span>
<span class="line" id="L2310">    <span class="tok-comment">/// The tag is invalid.</span></span>
<span class="line" id="L2311">    RPC_NT_INVALID_TAG = <span class="tok-number">0xC0020022</span>,</span>
<span class="line" id="L2312">    <span class="tok-comment">/// The array bounds are invalid.</span></span>
<span class="line" id="L2313">    RPC_NT_INVALID_BOUND = <span class="tok-number">0xC0020023</span>,</span>
<span class="line" id="L2314">    <span class="tok-comment">/// The binding does not contain an entry name.</span></span>
<span class="line" id="L2315">    RPC_NT_NO_ENTRY_NAME = <span class="tok-number">0xC0020024</span>,</span>
<span class="line" id="L2316">    <span class="tok-comment">/// The name syntax is invalid.</span></span>
<span class="line" id="L2317">    RPC_NT_INVALID_NAME_SYNTAX = <span class="tok-number">0xC0020025</span>,</span>
<span class="line" id="L2318">    <span class="tok-comment">/// The name syntax is not supported.</span></span>
<span class="line" id="L2319">    RPC_NT_UNSUPPORTED_NAME_SYNTAX = <span class="tok-number">0xC0020026</span>,</span>
<span class="line" id="L2320">    <span class="tok-comment">/// No network address is available to construct a UUID.</span></span>
<span class="line" id="L2321">    RPC_NT_UUID_NO_ADDRESS = <span class="tok-number">0xC0020028</span>,</span>
<span class="line" id="L2322">    <span class="tok-comment">/// The endpoint is a duplicate.</span></span>
<span class="line" id="L2323">    RPC_NT_DUPLICATE_ENDPOINT = <span class="tok-number">0xC0020029</span>,</span>
<span class="line" id="L2324">    <span class="tok-comment">/// The authentication type is unknown.</span></span>
<span class="line" id="L2325">    RPC_NT_UNKNOWN_AUTHN_TYPE = <span class="tok-number">0xC002002A</span>,</span>
<span class="line" id="L2326">    <span class="tok-comment">/// The maximum number of calls is too small.</span></span>
<span class="line" id="L2327">    RPC_NT_MAX_CALLS_TOO_SMALL = <span class="tok-number">0xC002002B</span>,</span>
<span class="line" id="L2328">    <span class="tok-comment">/// The string is too long.</span></span>
<span class="line" id="L2329">    RPC_NT_STRING_TOO_LONG = <span class="tok-number">0xC002002C</span>,</span>
<span class="line" id="L2330">    <span class="tok-comment">/// The RPC protocol sequence was not found.</span></span>
<span class="line" id="L2331">    RPC_NT_PROTSEQ_NOT_FOUND = <span class="tok-number">0xC002002D</span>,</span>
<span class="line" id="L2332">    <span class="tok-comment">/// The procedure number is out of range.</span></span>
<span class="line" id="L2333">    RPC_NT_PROCNUM_OUT_OF_RANGE = <span class="tok-number">0xC002002E</span>,</span>
<span class="line" id="L2334">    <span class="tok-comment">/// The binding does not contain any authentication information.</span></span>
<span class="line" id="L2335">    RPC_NT_BINDING_HAS_NO_AUTH = <span class="tok-number">0xC002002F</span>,</span>
<span class="line" id="L2336">    <span class="tok-comment">/// The authentication service is unknown.</span></span>
<span class="line" id="L2337">    RPC_NT_UNKNOWN_AUTHN_SERVICE = <span class="tok-number">0xC0020030</span>,</span>
<span class="line" id="L2338">    <span class="tok-comment">/// The authentication level is unknown.</span></span>
<span class="line" id="L2339">    RPC_NT_UNKNOWN_AUTHN_LEVEL = <span class="tok-number">0xC0020031</span>,</span>
<span class="line" id="L2340">    <span class="tok-comment">/// The security context is invalid.</span></span>
<span class="line" id="L2341">    RPC_NT_INVALID_AUTH_IDENTITY = <span class="tok-number">0xC0020032</span>,</span>
<span class="line" id="L2342">    <span class="tok-comment">/// The authorization service is unknown.</span></span>
<span class="line" id="L2343">    RPC_NT_UNKNOWN_AUTHZ_SERVICE = <span class="tok-number">0xC0020033</span>,</span>
<span class="line" id="L2344">    <span class="tok-comment">/// The entry is invalid.</span></span>
<span class="line" id="L2345">    EPT_NT_INVALID_ENTRY = <span class="tok-number">0xC0020034</span>,</span>
<span class="line" id="L2346">    <span class="tok-comment">/// The operation cannot be performed.</span></span>
<span class="line" id="L2347">    EPT_NT_CANT_PERFORM_OP = <span class="tok-number">0xC0020035</span>,</span>
<span class="line" id="L2348">    <span class="tok-comment">/// No more endpoints are available from the endpoint mapper.</span></span>
<span class="line" id="L2349">    EPT_NT_NOT_REGISTERED = <span class="tok-number">0xC0020036</span>,</span>
<span class="line" id="L2350">    <span class="tok-comment">/// No interfaces have been exported.</span></span>
<span class="line" id="L2351">    RPC_NT_NOTHING_TO_EXPORT = <span class="tok-number">0xC0020037</span>,</span>
<span class="line" id="L2352">    <span class="tok-comment">/// The entry name is incomplete.</span></span>
<span class="line" id="L2353">    RPC_NT_INCOMPLETE_NAME = <span class="tok-number">0xC0020038</span>,</span>
<span class="line" id="L2354">    <span class="tok-comment">/// The version option is invalid.</span></span>
<span class="line" id="L2355">    RPC_NT_INVALID_VERS_OPTION = <span class="tok-number">0xC0020039</span>,</span>
<span class="line" id="L2356">    <span class="tok-comment">/// There are no more members.</span></span>
<span class="line" id="L2357">    RPC_NT_NO_MORE_MEMBERS = <span class="tok-number">0xC002003A</span>,</span>
<span class="line" id="L2358">    <span class="tok-comment">/// There is nothing to unexport.</span></span>
<span class="line" id="L2359">    RPC_NT_NOT_ALL_OBJS_UNEXPORTED = <span class="tok-number">0xC002003B</span>,</span>
<span class="line" id="L2360">    <span class="tok-comment">/// The interface was not found.</span></span>
<span class="line" id="L2361">    RPC_NT_INTERFACE_NOT_FOUND = <span class="tok-number">0xC002003C</span>,</span>
<span class="line" id="L2362">    <span class="tok-comment">/// The entry already exists.</span></span>
<span class="line" id="L2363">    RPC_NT_ENTRY_ALREADY_EXISTS = <span class="tok-number">0xC002003D</span>,</span>
<span class="line" id="L2364">    <span class="tok-comment">/// The entry was not found.</span></span>
<span class="line" id="L2365">    RPC_NT_ENTRY_NOT_FOUND = <span class="tok-number">0xC002003E</span>,</span>
<span class="line" id="L2366">    <span class="tok-comment">/// The name service is unavailable.</span></span>
<span class="line" id="L2367">    RPC_NT_NAME_SERVICE_UNAVAILABLE = <span class="tok-number">0xC002003F</span>,</span>
<span class="line" id="L2368">    <span class="tok-comment">/// The network address family is invalid.</span></span>
<span class="line" id="L2369">    RPC_NT_INVALID_NAF_ID = <span class="tok-number">0xC0020040</span>,</span>
<span class="line" id="L2370">    <span class="tok-comment">/// The requested operation is not supported.</span></span>
<span class="line" id="L2371">    RPC_NT_CANNOT_SUPPORT = <span class="tok-number">0xC0020041</span>,</span>
<span class="line" id="L2372">    <span class="tok-comment">/// No security context is available to allow impersonation.</span></span>
<span class="line" id="L2373">    RPC_NT_NO_CONTEXT_AVAILABLE = <span class="tok-number">0xC0020042</span>,</span>
<span class="line" id="L2374">    <span class="tok-comment">/// An internal error occurred in the RPC.</span></span>
<span class="line" id="L2375">    RPC_NT_INTERNAL_ERROR = <span class="tok-number">0xC0020043</span>,</span>
<span class="line" id="L2376">    <span class="tok-comment">/// The RPC server attempted to divide an integer by zero.</span></span>
<span class="line" id="L2377">    RPC_NT_ZERO_DIVIDE = <span class="tok-number">0xC0020044</span>,</span>
<span class="line" id="L2378">    <span class="tok-comment">/// An addressing error occurred in the RPC server.</span></span>
<span class="line" id="L2379">    RPC_NT_ADDRESS_ERROR = <span class="tok-number">0xC0020045</span>,</span>
<span class="line" id="L2380">    <span class="tok-comment">/// A floating point operation at the RPC server caused a divide by zero.</span></span>
<span class="line" id="L2381">    RPC_NT_FP_DIV_ZERO = <span class="tok-number">0xC0020046</span>,</span>
<span class="line" id="L2382">    <span class="tok-comment">/// A floating point underflow occurred at the RPC server.</span></span>
<span class="line" id="L2383">    RPC_NT_FP_UNDERFLOW = <span class="tok-number">0xC0020047</span>,</span>
<span class="line" id="L2384">    <span class="tok-comment">/// A floating point overflow occurred at the RPC server.</span></span>
<span class="line" id="L2385">    RPC_NT_FP_OVERFLOW = <span class="tok-number">0xC0020048</span>,</span>
<span class="line" id="L2386">    <span class="tok-comment">/// An RPC is already in progress for this thread.</span></span>
<span class="line" id="L2387">    RPC_NT_CALL_IN_PROGRESS = <span class="tok-number">0xC0020049</span>,</span>
<span class="line" id="L2388">    <span class="tok-comment">/// There are no more bindings.</span></span>
<span class="line" id="L2389">    RPC_NT_NO_MORE_BINDINGS = <span class="tok-number">0xC002004A</span>,</span>
<span class="line" id="L2390">    <span class="tok-comment">/// The group member was not found.</span></span>
<span class="line" id="L2391">    RPC_NT_GROUP_MEMBER_NOT_FOUND = <span class="tok-number">0xC002004B</span>,</span>
<span class="line" id="L2392">    <span class="tok-comment">/// The endpoint mapper database entry could not be created.</span></span>
<span class="line" id="L2393">    EPT_NT_CANT_CREATE = <span class="tok-number">0xC002004C</span>,</span>
<span class="line" id="L2394">    <span class="tok-comment">/// The object UUID is the nil UUID.</span></span>
<span class="line" id="L2395">    RPC_NT_INVALID_OBJECT = <span class="tok-number">0xC002004D</span>,</span>
<span class="line" id="L2396">    <span class="tok-comment">/// No interfaces have been registered.</span></span>
<span class="line" id="L2397">    RPC_NT_NO_INTERFACES = <span class="tok-number">0xC002004F</span>,</span>
<span class="line" id="L2398">    <span class="tok-comment">/// The RPC was canceled.</span></span>
<span class="line" id="L2399">    RPC_NT_CALL_CANCELLED = <span class="tok-number">0xC0020050</span>,</span>
<span class="line" id="L2400">    <span class="tok-comment">/// The binding handle does not contain all the required information.</span></span>
<span class="line" id="L2401">    RPC_NT_BINDING_INCOMPLETE = <span class="tok-number">0xC0020051</span>,</span>
<span class="line" id="L2402">    <span class="tok-comment">/// A communications failure occurred during an RPC.</span></span>
<span class="line" id="L2403">    RPC_NT_COMM_FAILURE = <span class="tok-number">0xC0020052</span>,</span>
<span class="line" id="L2404">    <span class="tok-comment">/// The requested authentication level is not supported.</span></span>
<span class="line" id="L2405">    RPC_NT_UNSUPPORTED_AUTHN_LEVEL = <span class="tok-number">0xC0020053</span>,</span>
<span class="line" id="L2406">    <span class="tok-comment">/// No principal name was registered.</span></span>
<span class="line" id="L2407">    RPC_NT_NO_PRINC_NAME = <span class="tok-number">0xC0020054</span>,</span>
<span class="line" id="L2408">    <span class="tok-comment">/// The error specified is not a valid Windows RPC error code.</span></span>
<span class="line" id="L2409">    RPC_NT_NOT_RPC_ERROR = <span class="tok-number">0xC0020055</span>,</span>
<span class="line" id="L2410">    <span class="tok-comment">/// A security package-specific error occurred.</span></span>
<span class="line" id="L2411">    RPC_NT_SEC_PKG_ERROR = <span class="tok-number">0xC0020057</span>,</span>
<span class="line" id="L2412">    <span class="tok-comment">/// The thread was not canceled.</span></span>
<span class="line" id="L2413">    RPC_NT_NOT_CANCELLED = <span class="tok-number">0xC0020058</span>,</span>
<span class="line" id="L2414">    <span class="tok-comment">/// Invalid asynchronous RPC handle.</span></span>
<span class="line" id="L2415">    RPC_NT_INVALID_ASYNC_HANDLE = <span class="tok-number">0xC0020062</span>,</span>
<span class="line" id="L2416">    <span class="tok-comment">/// Invalid asynchronous RPC call handle for this operation.</span></span>
<span class="line" id="L2417">    RPC_NT_INVALID_ASYNC_CALL = <span class="tok-number">0xC0020063</span>,</span>
<span class="line" id="L2418">    <span class="tok-comment">/// Access to the HTTP proxy is denied.</span></span>
<span class="line" id="L2419">    RPC_NT_PROXY_ACCESS_DENIED = <span class="tok-number">0xC0020064</span>,</span>
<span class="line" id="L2420">    <span class="tok-comment">/// The list of RPC servers available for auto-handle binding has been exhausted.</span></span>
<span class="line" id="L2421">    RPC_NT_NO_MORE_ENTRIES = <span class="tok-number">0xC0030001</span>,</span>
<span class="line" id="L2422">    <span class="tok-comment">/// The file designated by DCERPCCHARTRANS cannot be opened.</span></span>
<span class="line" id="L2423">    RPC_NT_SS_CHAR_TRANS_OPEN_FAIL = <span class="tok-number">0xC0030002</span>,</span>
<span class="line" id="L2424">    <span class="tok-comment">/// The file containing the character translation table has fewer than 512 bytes.</span></span>
<span class="line" id="L2425">    RPC_NT_SS_CHAR_TRANS_SHORT_FILE = <span class="tok-number">0xC0030003</span>,</span>
<span class="line" id="L2426">    <span class="tok-comment">/// A null context handle is passed as an [in] parameter.</span></span>
<span class="line" id="L2427">    RPC_NT_SS_IN_NULL_CONTEXT = <span class="tok-number">0xC0030004</span>,</span>
<span class="line" id="L2428">    <span class="tok-comment">/// The context handle does not match any known context handles.</span></span>
<span class="line" id="L2429">    RPC_NT_SS_CONTEXT_MISMATCH = <span class="tok-number">0xC0030005</span>,</span>
<span class="line" id="L2430">    <span class="tok-comment">/// The context handle changed during a call.</span></span>
<span class="line" id="L2431">    RPC_NT_SS_CONTEXT_DAMAGED = <span class="tok-number">0xC0030006</span>,</span>
<span class="line" id="L2432">    <span class="tok-comment">/// The binding handles passed to an RPC do not match.</span></span>
<span class="line" id="L2433">    RPC_NT_SS_HANDLES_MISMATCH = <span class="tok-number">0xC0030007</span>,</span>
<span class="line" id="L2434">    <span class="tok-comment">/// The stub is unable to get the call handle.</span></span>
<span class="line" id="L2435">    RPC_NT_SS_CANNOT_GET_CALL_HANDLE = <span class="tok-number">0xC0030008</span>,</span>
<span class="line" id="L2436">    <span class="tok-comment">/// A null reference pointer was passed to the stub.</span></span>
<span class="line" id="L2437">    RPC_NT_NULL_REF_POINTER = <span class="tok-number">0xC0030009</span>,</span>
<span class="line" id="L2438">    <span class="tok-comment">/// The enumeration value is out of range.</span></span>
<span class="line" id="L2439">    RPC_NT_ENUM_VALUE_OUT_OF_RANGE = <span class="tok-number">0xC003000A</span>,</span>
<span class="line" id="L2440">    <span class="tok-comment">/// The byte count is too small.</span></span>
<span class="line" id="L2441">    RPC_NT_BYTE_COUNT_TOO_SMALL = <span class="tok-number">0xC003000B</span>,</span>
<span class="line" id="L2442">    <span class="tok-comment">/// The stub received bad data.</span></span>
<span class="line" id="L2443">    RPC_NT_BAD_STUB_DATA = <span class="tok-number">0xC003000C</span>,</span>
<span class="line" id="L2444">    <span class="tok-comment">/// Invalid operation on the encoding/decoding handle.</span></span>
<span class="line" id="L2445">    RPC_NT_INVALID_ES_ACTION = <span class="tok-number">0xC0030059</span>,</span>
<span class="line" id="L2446">    <span class="tok-comment">/// Incompatible version of the serializing package.</span></span>
<span class="line" id="L2447">    RPC_NT_WRONG_ES_VERSION = <span class="tok-number">0xC003005A</span>,</span>
<span class="line" id="L2448">    <span class="tok-comment">/// Incompatible version of the RPC stub.</span></span>
<span class="line" id="L2449">    RPC_NT_WRONG_STUB_VERSION = <span class="tok-number">0xC003005B</span>,</span>
<span class="line" id="L2450">    <span class="tok-comment">/// The RPC pipe object is invalid or corrupt.</span></span>
<span class="line" id="L2451">    RPC_NT_INVALID_PIPE_OBJECT = <span class="tok-number">0xC003005C</span>,</span>
<span class="line" id="L2452">    <span class="tok-comment">/// An invalid operation was attempted on an RPC pipe object.</span></span>
<span class="line" id="L2453">    RPC_NT_INVALID_PIPE_OPERATION = <span class="tok-number">0xC003005D</span>,</span>
<span class="line" id="L2454">    <span class="tok-comment">/// Unsupported RPC pipe version.</span></span>
<span class="line" id="L2455">    RPC_NT_WRONG_PIPE_VERSION = <span class="tok-number">0xC003005E</span>,</span>
<span class="line" id="L2456">    <span class="tok-comment">/// The RPC pipe object has already been closed.</span></span>
<span class="line" id="L2457">    RPC_NT_PIPE_CLOSED = <span class="tok-number">0xC003005F</span>,</span>
<span class="line" id="L2458">    <span class="tok-comment">/// The RPC call completed before all pipes were processed.</span></span>
<span class="line" id="L2459">    RPC_NT_PIPE_DISCIPLINE_ERROR = <span class="tok-number">0xC0030060</span>,</span>
<span class="line" id="L2460">    <span class="tok-comment">/// No more data is available from the RPC pipe.</span></span>
<span class="line" id="L2461">    RPC_NT_PIPE_EMPTY = <span class="tok-number">0xC0030061</span>,</span>
<span class="line" id="L2462">    <span class="tok-comment">/// A device is missing in the system BIOS MPS table. This device will not be used.</span></span>
<span class="line" id="L2463">    <span class="tok-comment">/// Contact your system vendor for a system BIOS update.</span></span>
<span class="line" id="L2464">    PNP_BAD_MPS_TABLE = <span class="tok-number">0xC0040035</span>,</span>
<span class="line" id="L2465">    <span class="tok-comment">/// A translator failed to translate resources.</span></span>
<span class="line" id="L2466">    PNP_TRANSLATION_FAILED = <span class="tok-number">0xC0040036</span>,</span>
<span class="line" id="L2467">    <span class="tok-comment">/// An IRQ translator failed to translate resources.</span></span>
<span class="line" id="L2468">    PNP_IRQ_TRANSLATION_FAILED = <span class="tok-number">0xC0040037</span>,</span>
<span class="line" id="L2469">    <span class="tok-comment">/// Driver %2 returned an invalid ID for a child device (%3).</span></span>
<span class="line" id="L2470">    PNP_INVALID_ID = <span class="tok-number">0xC0040038</span>,</span>
<span class="line" id="L2471">    <span class="tok-comment">/// Reissue the given operation as a cached I/O operation</span></span>
<span class="line" id="L2472">    IO_REISSUE_AS_CACHED = <span class="tok-number">0xC0040039</span>,</span>
<span class="line" id="L2473">    <span class="tok-comment">/// Session name %1 is invalid.</span></span>
<span class="line" id="L2474">    CTX_WINSTATION_NAME_INVALID = <span class="tok-number">0xC00A0001</span>,</span>
<span class="line" id="L2475">    <span class="tok-comment">/// The protocol driver %1 is invalid.</span></span>
<span class="line" id="L2476">    CTX_INVALID_PD = <span class="tok-number">0xC00A0002</span>,</span>
<span class="line" id="L2477">    <span class="tok-comment">/// The protocol driver %1 was not found in the system path.</span></span>
<span class="line" id="L2478">    CTX_PD_NOT_FOUND = <span class="tok-number">0xC00A0003</span>,</span>
<span class="line" id="L2479">    <span class="tok-comment">/// A close operation is pending on the terminal connection.</span></span>
<span class="line" id="L2480">    CTX_CLOSE_PENDING = <span class="tok-number">0xC00A0006</span>,</span>
<span class="line" id="L2481">    <span class="tok-comment">/// No free output buffers are available.</span></span>
<span class="line" id="L2482">    CTX_NO_OUTBUF = <span class="tok-number">0xC00A0007</span>,</span>
<span class="line" id="L2483">    <span class="tok-comment">/// The MODEM.INF file was not found.</span></span>
<span class="line" id="L2484">    CTX_MODEM_INF_NOT_FOUND = <span class="tok-number">0xC00A0008</span>,</span>
<span class="line" id="L2485">    <span class="tok-comment">/// The modem (%1) was not found in the MODEM.INF file.</span></span>
<span class="line" id="L2486">    CTX_INVALID_MODEMNAME = <span class="tok-number">0xC00A0009</span>,</span>
<span class="line" id="L2487">    <span class="tok-comment">/// The modem did not accept the command sent to it.</span></span>
<span class="line" id="L2488">    <span class="tok-comment">/// Verify that the configured modem name matches the attached modem.</span></span>
<span class="line" id="L2489">    CTX_RESPONSE_ERROR = <span class="tok-number">0xC00A000A</span>,</span>
<span class="line" id="L2490">    <span class="tok-comment">/// The modem did not respond to the command sent to it.</span></span>
<span class="line" id="L2491">    <span class="tok-comment">/// Verify that the modem cable is properly attached and the modem is turned on.</span></span>
<span class="line" id="L2492">    CTX_MODEM_RESPONSE_TIMEOUT = <span class="tok-number">0xC00A000B</span>,</span>
<span class="line" id="L2493">    <span class="tok-comment">/// Carrier detection has failed or the carrier has been dropped due to disconnection.</span></span>
<span class="line" id="L2494">    CTX_MODEM_RESPONSE_NO_CARRIER = <span class="tok-number">0xC00A000C</span>,</span>
<span class="line" id="L2495">    <span class="tok-comment">/// A dial tone was not detected within the required time.</span></span>
<span class="line" id="L2496">    <span class="tok-comment">/// Verify that the phone cable is properly attached and functional.</span></span>
<span class="line" id="L2497">    CTX_MODEM_RESPONSE_NO_DIALTONE = <span class="tok-number">0xC00A000D</span>,</span>
<span class="line" id="L2498">    <span class="tok-comment">/// A busy signal was detected at a remote site on callback.</span></span>
<span class="line" id="L2499">    CTX_MODEM_RESPONSE_BUSY = <span class="tok-number">0xC00A000E</span>,</span>
<span class="line" id="L2500">    <span class="tok-comment">/// A voice was detected at a remote site on callback.</span></span>
<span class="line" id="L2501">    CTX_MODEM_RESPONSE_VOICE = <span class="tok-number">0xC00A000F</span>,</span>
<span class="line" id="L2502">    <span class="tok-comment">/// Transport driver error.</span></span>
<span class="line" id="L2503">    CTX_TD_ERROR = <span class="tok-number">0xC00A0010</span>,</span>
<span class="line" id="L2504">    <span class="tok-comment">/// The client you are using is not licensed to use this system. Your logon request is denied.</span></span>
<span class="line" id="L2505">    CTX_LICENSE_CLIENT_INVALID = <span class="tok-number">0xC00A0012</span>,</span>
<span class="line" id="L2506">    <span class="tok-comment">/// The system has reached its licensed logon limit. Try again later.</span></span>
<span class="line" id="L2507">    CTX_LICENSE_NOT_AVAILABLE = <span class="tok-number">0xC00A0013</span>,</span>
<span class="line" id="L2508">    <span class="tok-comment">/// The system license has expired. Your logon request is denied.</span></span>
<span class="line" id="L2509">    CTX_LICENSE_EXPIRED = <span class="tok-number">0xC00A0014</span>,</span>
<span class="line" id="L2510">    <span class="tok-comment">/// The specified session cannot be found.</span></span>
<span class="line" id="L2511">    CTX_WINSTATION_NOT_FOUND = <span class="tok-number">0xC00A0015</span>,</span>
<span class="line" id="L2512">    <span class="tok-comment">/// The specified session name is already in use.</span></span>
<span class="line" id="L2513">    CTX_WINSTATION_NAME_COLLISION = <span class="tok-number">0xC00A0016</span>,</span>
<span class="line" id="L2514">    <span class="tok-comment">/// The requested operation cannot be completed because the terminal connection is currently processing a connect, disconnect, reset, or delete operation.</span></span>
<span class="line" id="L2515">    CTX_WINSTATION_BUSY = <span class="tok-number">0xC00A0017</span>,</span>
<span class="line" id="L2516">    <span class="tok-comment">/// An attempt has been made to connect to a session whose video mode is not supported by the current client.</span></span>
<span class="line" id="L2517">    CTX_BAD_VIDEO_MODE = <span class="tok-number">0xC00A0018</span>,</span>
<span class="line" id="L2518">    <span class="tok-comment">/// The application attempted to enable DOS graphics mode. DOS graphics mode is not supported.</span></span>
<span class="line" id="L2519">    CTX_GRAPHICS_INVALID = <span class="tok-number">0xC00A0022</span>,</span>
<span class="line" id="L2520">    <span class="tok-comment">/// The requested operation can be performed only on the system console.</span></span>
<span class="line" id="L2521">    <span class="tok-comment">/// This is most often the result of a driver or system DLL requiring direct console access.</span></span>
<span class="line" id="L2522">    CTX_NOT_CONSOLE = <span class="tok-number">0xC00A0024</span>,</span>
<span class="line" id="L2523">    <span class="tok-comment">/// The client failed to respond to the server connect message.</span></span>
<span class="line" id="L2524">    CTX_CLIENT_QUERY_TIMEOUT = <span class="tok-number">0xC00A0026</span>,</span>
<span class="line" id="L2525">    <span class="tok-comment">/// Disconnecting the console session is not supported.</span></span>
<span class="line" id="L2526">    CTX_CONSOLE_DISCONNECT = <span class="tok-number">0xC00A0027</span>,</span>
<span class="line" id="L2527">    <span class="tok-comment">/// Reconnecting a disconnected session to the console is not supported.</span></span>
<span class="line" id="L2528">    CTX_CONSOLE_CONNECT = <span class="tok-number">0xC00A0028</span>,</span>
<span class="line" id="L2529">    <span class="tok-comment">/// The request to control another session remotely was denied.</span></span>
<span class="line" id="L2530">    CTX_SHADOW_DENIED = <span class="tok-number">0xC00A002A</span>,</span>
<span class="line" id="L2531">    <span class="tok-comment">/// A process has requested access to a session, but has not been granted those access rights.</span></span>
<span class="line" id="L2532">    CTX_WINSTATION_ACCESS_DENIED = <span class="tok-number">0xC00A002B</span>,</span>
<span class="line" id="L2533">    <span class="tok-comment">/// The terminal connection driver %1 is invalid.</span></span>
<span class="line" id="L2534">    CTX_INVALID_WD = <span class="tok-number">0xC00A002E</span>,</span>
<span class="line" id="L2535">    <span class="tok-comment">/// The terminal connection driver %1 was not found in the system path.</span></span>
<span class="line" id="L2536">    CTX_WD_NOT_FOUND = <span class="tok-number">0xC00A002F</span>,</span>
<span class="line" id="L2537">    <span class="tok-comment">/// The requested session cannot be controlled remotely.</span></span>
<span class="line" id="L2538">    <span class="tok-comment">/// You cannot control your own session, a session that is trying to control your session, a session that has no user logged on, or other sessions from the console.</span></span>
<span class="line" id="L2539">    CTX_SHADOW_INVALID = <span class="tok-number">0xC00A0030</span>,</span>
<span class="line" id="L2540">    <span class="tok-comment">/// The requested session is not configured to allow remote control.</span></span>
<span class="line" id="L2541">    CTX_SHADOW_DISABLED = <span class="tok-number">0xC00A0031</span>,</span>
<span class="line" id="L2542">    <span class="tok-comment">/// The RDP protocol component %2 detected an error in the protocol stream and has disconnected the client.</span></span>
<span class="line" id="L2543">    RDP_PROTOCOL_ERROR = <span class="tok-number">0xC00A0032</span>,</span>
<span class="line" id="L2544">    <span class="tok-comment">/// Your request to connect to this terminal server has been rejected.</span></span>
<span class="line" id="L2545">    <span class="tok-comment">/// Your terminal server client license number has not been entered for this copy of the terminal client.</span></span>
<span class="line" id="L2546">    <span class="tok-comment">/// Contact your system administrator for help in entering a valid, unique license number for this terminal server client. Click OK to continue.</span></span>
<span class="line" id="L2547">    CTX_CLIENT_LICENSE_NOT_SET = <span class="tok-number">0xC00A0033</span>,</span>
<span class="line" id="L2548">    <span class="tok-comment">/// Your request to connect to this terminal server has been rejected.</span></span>
<span class="line" id="L2549">    <span class="tok-comment">/// Your terminal server client license number is currently being used by another user.</span></span>
<span class="line" id="L2550">    <span class="tok-comment">/// Contact your system administrator to obtain a new copy of the terminal server client with a valid, unique license number. Click OK to continue.</span></span>
<span class="line" id="L2551">    CTX_CLIENT_LICENSE_IN_USE = <span class="tok-number">0xC00A0034</span>,</span>
<span class="line" id="L2552">    <span class="tok-comment">/// The remote control of the console was terminated because the display mode was changed.</span></span>
<span class="line" id="L2553">    <span class="tok-comment">/// Changing the display mode in a remote control session is not supported.</span></span>
<span class="line" id="L2554">    CTX_SHADOW_ENDED_BY_MODE_CHANGE = <span class="tok-number">0xC00A0035</span>,</span>
<span class="line" id="L2555">    <span class="tok-comment">/// Remote control could not be terminated because the specified session is not currently being remotely controlled.</span></span>
<span class="line" id="L2556">    CTX_SHADOW_NOT_RUNNING = <span class="tok-number">0xC00A0036</span>,</span>
<span class="line" id="L2557">    <span class="tok-comment">/// Your interactive logon privilege has been disabled. Contact your system administrator.</span></span>
<span class="line" id="L2558">    CTX_LOGON_DISABLED = <span class="tok-number">0xC00A0037</span>,</span>
<span class="line" id="L2559">    <span class="tok-comment">/// The terminal server security layer detected an error in the protocol stream and has disconnected the client.</span></span>
<span class="line" id="L2560">    CTX_SECURITY_LAYER_ERROR = <span class="tok-number">0xC00A0038</span>,</span>
<span class="line" id="L2561">    <span class="tok-comment">/// The target session is incompatible with the current session.</span></span>
<span class="line" id="L2562">    TS_INCOMPATIBLE_SESSIONS = <span class="tok-number">0xC00A0039</span>,</span>
<span class="line" id="L2563">    <span class="tok-comment">/// The resource loader failed to find an MUI file.</span></span>
<span class="line" id="L2564">    MUI_FILE_NOT_FOUND = <span class="tok-number">0xC00B0001</span>,</span>
<span class="line" id="L2565">    <span class="tok-comment">/// The resource loader failed to load an MUI file because the file failed to pass validation.</span></span>
<span class="line" id="L2566">    MUI_INVALID_FILE = <span class="tok-number">0xC00B0002</span>,</span>
<span class="line" id="L2567">    <span class="tok-comment">/// The RC manifest is corrupted with garbage data, is an unsupported version, or is missing a required item.</span></span>
<span class="line" id="L2568">    MUI_INVALID_RC_CONFIG = <span class="tok-number">0xC00B0003</span>,</span>
<span class="line" id="L2569">    <span class="tok-comment">/// The RC manifest has an invalid culture name.</span></span>
<span class="line" id="L2570">    MUI_INVALID_LOCALE_NAME = <span class="tok-number">0xC00B0004</span>,</span>
<span class="line" id="L2571">    <span class="tok-comment">/// The RC manifest has and invalid ultimate fallback name.</span></span>
<span class="line" id="L2572">    MUI_INVALID_ULTIMATEFALLBACK_NAME = <span class="tok-number">0xC00B0005</span>,</span>
<span class="line" id="L2573">    <span class="tok-comment">/// The resource loader cache does not have a loaded MUI entry.</span></span>
<span class="line" id="L2574">    MUI_FILE_NOT_LOADED = <span class="tok-number">0xC00B0006</span>,</span>
<span class="line" id="L2575">    <span class="tok-comment">/// The user stopped resource enumeration.</span></span>
<span class="line" id="L2576">    RESOURCE_ENUM_USER_STOP = <span class="tok-number">0xC00B0007</span>,</span>
<span class="line" id="L2577">    <span class="tok-comment">/// The cluster node is not valid.</span></span>
<span class="line" id="L2578">    CLUSTER_INVALID_NODE = <span class="tok-number">0xC0130001</span>,</span>
<span class="line" id="L2579">    <span class="tok-comment">/// The cluster node already exists.</span></span>
<span class="line" id="L2580">    CLUSTER_NODE_EXISTS = <span class="tok-number">0xC0130002</span>,</span>
<span class="line" id="L2581">    <span class="tok-comment">/// A node is in the process of joining the cluster.</span></span>
<span class="line" id="L2582">    CLUSTER_JOIN_IN_PROGRESS = <span class="tok-number">0xC0130003</span>,</span>
<span class="line" id="L2583">    <span class="tok-comment">/// The cluster node was not found.</span></span>
<span class="line" id="L2584">    CLUSTER_NODE_NOT_FOUND = <span class="tok-number">0xC0130004</span>,</span>
<span class="line" id="L2585">    <span class="tok-comment">/// The cluster local node information was not found.</span></span>
<span class="line" id="L2586">    CLUSTER_LOCAL_NODE_NOT_FOUND = <span class="tok-number">0xC0130005</span>,</span>
<span class="line" id="L2587">    <span class="tok-comment">/// The cluster network already exists.</span></span>
<span class="line" id="L2588">    CLUSTER_NETWORK_EXISTS = <span class="tok-number">0xC0130006</span>,</span>
<span class="line" id="L2589">    <span class="tok-comment">/// The cluster network was not found.</span></span>
<span class="line" id="L2590">    CLUSTER_NETWORK_NOT_FOUND = <span class="tok-number">0xC0130007</span>,</span>
<span class="line" id="L2591">    <span class="tok-comment">/// The cluster network interface already exists.</span></span>
<span class="line" id="L2592">    CLUSTER_NETINTERFACE_EXISTS = <span class="tok-number">0xC0130008</span>,</span>
<span class="line" id="L2593">    <span class="tok-comment">/// The cluster network interface was not found.</span></span>
<span class="line" id="L2594">    CLUSTER_NETINTERFACE_NOT_FOUND = <span class="tok-number">0xC0130009</span>,</span>
<span class="line" id="L2595">    <span class="tok-comment">/// The cluster request is not valid for this object.</span></span>
<span class="line" id="L2596">    CLUSTER_INVALID_REQUEST = <span class="tok-number">0xC013000A</span>,</span>
<span class="line" id="L2597">    <span class="tok-comment">/// The cluster network provider is not valid.</span></span>
<span class="line" id="L2598">    CLUSTER_INVALID_NETWORK_PROVIDER = <span class="tok-number">0xC013000B</span>,</span>
<span class="line" id="L2599">    <span class="tok-comment">/// The cluster node is down.</span></span>
<span class="line" id="L2600">    CLUSTER_NODE_DOWN = <span class="tok-number">0xC013000C</span>,</span>
<span class="line" id="L2601">    <span class="tok-comment">/// The cluster node is not reachable.</span></span>
<span class="line" id="L2602">    CLUSTER_NODE_UNREACHABLE = <span class="tok-number">0xC013000D</span>,</span>
<span class="line" id="L2603">    <span class="tok-comment">/// The cluster node is not a member of the cluster.</span></span>
<span class="line" id="L2604">    CLUSTER_NODE_NOT_MEMBER = <span class="tok-number">0xC013000E</span>,</span>
<span class="line" id="L2605">    <span class="tok-comment">/// A cluster join operation is not in progress.</span></span>
<span class="line" id="L2606">    CLUSTER_JOIN_NOT_IN_PROGRESS = <span class="tok-number">0xC013000F</span>,</span>
<span class="line" id="L2607">    <span class="tok-comment">/// The cluster network is not valid.</span></span>
<span class="line" id="L2608">    CLUSTER_INVALID_NETWORK = <span class="tok-number">0xC0130010</span>,</span>
<span class="line" id="L2609">    <span class="tok-comment">/// No network adapters are available.</span></span>
<span class="line" id="L2610">    CLUSTER_NO_NET_ADAPTERS = <span class="tok-number">0xC0130011</span>,</span>
<span class="line" id="L2611">    <span class="tok-comment">/// The cluster node is up.</span></span>
<span class="line" id="L2612">    CLUSTER_NODE_UP = <span class="tok-number">0xC0130012</span>,</span>
<span class="line" id="L2613">    <span class="tok-comment">/// The cluster node is paused.</span></span>
<span class="line" id="L2614">    CLUSTER_NODE_PAUSED = <span class="tok-number">0xC0130013</span>,</span>
<span class="line" id="L2615">    <span class="tok-comment">/// The cluster node is not paused.</span></span>
<span class="line" id="L2616">    CLUSTER_NODE_NOT_PAUSED = <span class="tok-number">0xC0130014</span>,</span>
<span class="line" id="L2617">    <span class="tok-comment">/// No cluster security context is available.</span></span>
<span class="line" id="L2618">    CLUSTER_NO_SECURITY_CONTEXT = <span class="tok-number">0xC0130015</span>,</span>
<span class="line" id="L2619">    <span class="tok-comment">/// The cluster network is not configured for internal cluster communication.</span></span>
<span class="line" id="L2620">    CLUSTER_NETWORK_NOT_INTERNAL = <span class="tok-number">0xC0130016</span>,</span>
<span class="line" id="L2621">    <span class="tok-comment">/// The cluster node has been poisoned.</span></span>
<span class="line" id="L2622">    CLUSTER_POISONED = <span class="tok-number">0xC0130017</span>,</span>
<span class="line" id="L2623">    <span class="tok-comment">/// An attempt was made to run an invalid AML opcode.</span></span>
<span class="line" id="L2624">    ACPI_INVALID_OPCODE = <span class="tok-number">0xC0140001</span>,</span>
<span class="line" id="L2625">    <span class="tok-comment">/// The AML interpreter stack has overflowed.</span></span>
<span class="line" id="L2626">    ACPI_STACK_OVERFLOW = <span class="tok-number">0xC0140002</span>,</span>
<span class="line" id="L2627">    <span class="tok-comment">/// An inconsistent state has occurred.</span></span>
<span class="line" id="L2628">    ACPI_ASSERT_FAILED = <span class="tok-number">0xC0140003</span>,</span>
<span class="line" id="L2629">    <span class="tok-comment">/// An attempt was made to access an array outside its bounds.</span></span>
<span class="line" id="L2630">    ACPI_INVALID_INDEX = <span class="tok-number">0xC0140004</span>,</span>
<span class="line" id="L2631">    <span class="tok-comment">/// A required argument was not specified.</span></span>
<span class="line" id="L2632">    ACPI_INVALID_ARGUMENT = <span class="tok-number">0xC0140005</span>,</span>
<span class="line" id="L2633">    <span class="tok-comment">/// A fatal error has occurred.</span></span>
<span class="line" id="L2634">    ACPI_FATAL = <span class="tok-number">0xC0140006</span>,</span>
<span class="line" id="L2635">    <span class="tok-comment">/// An invalid SuperName was specified.</span></span>
<span class="line" id="L2636">    ACPI_INVALID_SUPERNAME = <span class="tok-number">0xC0140007</span>,</span>
<span class="line" id="L2637">    <span class="tok-comment">/// An argument with an incorrect type was specified.</span></span>
<span class="line" id="L2638">    ACPI_INVALID_ARGTYPE = <span class="tok-number">0xC0140008</span>,</span>
<span class="line" id="L2639">    <span class="tok-comment">/// An object with an incorrect type was specified.</span></span>
<span class="line" id="L2640">    ACPI_INVALID_OBJTYPE = <span class="tok-number">0xC0140009</span>,</span>
<span class="line" id="L2641">    <span class="tok-comment">/// A target with an incorrect type was specified.</span></span>
<span class="line" id="L2642">    ACPI_INVALID_TARGETTYPE = <span class="tok-number">0xC014000A</span>,</span>
<span class="line" id="L2643">    <span class="tok-comment">/// An incorrect number of arguments was specified.</span></span>
<span class="line" id="L2644">    ACPI_INCORRECT_ARGUMENT_COUNT = <span class="tok-number">0xC014000B</span>,</span>
<span class="line" id="L2645">    <span class="tok-comment">/// An address failed to translate.</span></span>
<span class="line" id="L2646">    ACPI_ADDRESS_NOT_MAPPED = <span class="tok-number">0xC014000C</span>,</span>
<span class="line" id="L2647">    <span class="tok-comment">/// An incorrect event type was specified.</span></span>
<span class="line" id="L2648">    ACPI_INVALID_EVENTTYPE = <span class="tok-number">0xC014000D</span>,</span>
<span class="line" id="L2649">    <span class="tok-comment">/// A handler for the target already exists.</span></span>
<span class="line" id="L2650">    ACPI_HANDLER_COLLISION = <span class="tok-number">0xC014000E</span>,</span>
<span class="line" id="L2651">    <span class="tok-comment">/// Invalid data for the target was specified.</span></span>
<span class="line" id="L2652">    ACPI_INVALID_DATA = <span class="tok-number">0xC014000F</span>,</span>
<span class="line" id="L2653">    <span class="tok-comment">/// An invalid region for the target was specified.</span></span>
<span class="line" id="L2654">    ACPI_INVALID_REGION = <span class="tok-number">0xC0140010</span>,</span>
<span class="line" id="L2655">    <span class="tok-comment">/// An attempt was made to access a field outside the defined range.</span></span>
<span class="line" id="L2656">    ACPI_INVALID_ACCESS_SIZE = <span class="tok-number">0xC0140011</span>,</span>
<span class="line" id="L2657">    <span class="tok-comment">/// The global system lock could not be acquired.</span></span>
<span class="line" id="L2658">    ACPI_ACQUIRE_GLOBAL_LOCK = <span class="tok-number">0xC0140012</span>,</span>
<span class="line" id="L2659">    <span class="tok-comment">/// An attempt was made to reinitialize the ACPI subsystem.</span></span>
<span class="line" id="L2660">    ACPI_ALREADY_INITIALIZED = <span class="tok-number">0xC0140013</span>,</span>
<span class="line" id="L2661">    <span class="tok-comment">/// The ACPI subsystem has not been initialized.</span></span>
<span class="line" id="L2662">    ACPI_NOT_INITIALIZED = <span class="tok-number">0xC0140014</span>,</span>
<span class="line" id="L2663">    <span class="tok-comment">/// An incorrect mutex was specified.</span></span>
<span class="line" id="L2664">    ACPI_INVALID_MUTEX_LEVEL = <span class="tok-number">0xC0140015</span>,</span>
<span class="line" id="L2665">    <span class="tok-comment">/// The mutex is not currently owned.</span></span>
<span class="line" id="L2666">    ACPI_MUTEX_NOT_OWNED = <span class="tok-number">0xC0140016</span>,</span>
<span class="line" id="L2667">    <span class="tok-comment">/// An attempt was made to access the mutex by a process that was not the owner.</span></span>
<span class="line" id="L2668">    ACPI_MUTEX_NOT_OWNER = <span class="tok-number">0xC0140017</span>,</span>
<span class="line" id="L2669">    <span class="tok-comment">/// An error occurred during an access to region space.</span></span>
<span class="line" id="L2670">    ACPI_RS_ACCESS = <span class="tok-number">0xC0140018</span>,</span>
<span class="line" id="L2671">    <span class="tok-comment">/// An attempt was made to use an incorrect table.</span></span>
<span class="line" id="L2672">    ACPI_INVALID_TABLE = <span class="tok-number">0xC0140019</span>,</span>
<span class="line" id="L2673">    <span class="tok-comment">/// The registration of an ACPI event failed.</span></span>
<span class="line" id="L2674">    ACPI_REG_HANDLER_FAILED = <span class="tok-number">0xC0140020</span>,</span>
<span class="line" id="L2675">    <span class="tok-comment">/// An ACPI power object failed to transition state.</span></span>
<span class="line" id="L2676">    ACPI_POWER_REQUEST_FAILED = <span class="tok-number">0xC0140021</span>,</span>
<span class="line" id="L2677">    <span class="tok-comment">/// The requested section is not present in the activation context.</span></span>
<span class="line" id="L2678">    SXS_SECTION_NOT_FOUND = <span class="tok-number">0xC0150001</span>,</span>
<span class="line" id="L2679">    <span class="tok-comment">/// Windows was unble to process the application binding information.</span></span>
<span class="line" id="L2680">    <span class="tok-comment">/// Refer to the system event log for further information.</span></span>
<span class="line" id="L2681">    SXS_CANT_GEN_ACTCTX = <span class="tok-number">0xC0150002</span>,</span>
<span class="line" id="L2682">    <span class="tok-comment">/// The application binding data format is invalid.</span></span>
<span class="line" id="L2683">    SXS_INVALID_ACTCTXDATA_FORMAT = <span class="tok-number">0xC0150003</span>,</span>
<span class="line" id="L2684">    <span class="tok-comment">/// The referenced assembly is not installed on the system.</span></span>
<span class="line" id="L2685">    SXS_ASSEMBLY_NOT_FOUND = <span class="tok-number">0xC0150004</span>,</span>
<span class="line" id="L2686">    <span class="tok-comment">/// The manifest file does not begin with the required tag and format information.</span></span>
<span class="line" id="L2687">    SXS_MANIFEST_FORMAT_ERROR = <span class="tok-number">0xC0150005</span>,</span>
<span class="line" id="L2688">    <span class="tok-comment">/// The manifest file contains one or more syntax errors.</span></span>
<span class="line" id="L2689">    SXS_MANIFEST_PARSE_ERROR = <span class="tok-number">0xC0150006</span>,</span>
<span class="line" id="L2690">    <span class="tok-comment">/// The application attempted to activate a disabled activation context.</span></span>
<span class="line" id="L2691">    SXS_ACTIVATION_CONTEXT_DISABLED = <span class="tok-number">0xC0150007</span>,</span>
<span class="line" id="L2692">    <span class="tok-comment">/// The requested lookup key was not found in any active activation context.</span></span>
<span class="line" id="L2693">    SXS_KEY_NOT_FOUND = <span class="tok-number">0xC0150008</span>,</span>
<span class="line" id="L2694">    <span class="tok-comment">/// A component version required by the application conflicts with another component version that is already active.</span></span>
<span class="line" id="L2695">    SXS_VERSION_CONFLICT = <span class="tok-number">0xC0150009</span>,</span>
<span class="line" id="L2696">    <span class="tok-comment">/// The type requested activation context section does not match the query API used.</span></span>
<span class="line" id="L2697">    SXS_WRONG_SECTION_TYPE = <span class="tok-number">0xC015000A</span>,</span>
<span class="line" id="L2698">    <span class="tok-comment">/// Lack of system resources has required isolated activation to be disabled for the current thread of execution.</span></span>
<span class="line" id="L2699">    SXS_THREAD_QUERIES_DISABLED = <span class="tok-number">0xC015000B</span>,</span>
<span class="line" id="L2700">    <span class="tok-comment">/// The referenced assembly could not be found.</span></span>
<span class="line" id="L2701">    SXS_ASSEMBLY_MISSING = <span class="tok-number">0xC015000C</span>,</span>
<span class="line" id="L2702">    <span class="tok-comment">/// An attempt to set the process default activation context failed because the process default activation context was already set.</span></span>
<span class="line" id="L2703">    SXS_PROCESS_DEFAULT_ALREADY_SET = <span class="tok-number">0xC015000E</span>,</span>
<span class="line" id="L2704">    <span class="tok-comment">/// The activation context being deactivated is not the most recently activated one.</span></span>
<span class="line" id="L2705">    SXS_EARLY_DEACTIVATION = <span class="tok-number">0xC015000F</span>,</span>
<span class="line" id="L2706">    <span class="tok-comment">/// The activation context being deactivated is not active for the current thread of execution.</span></span>
<span class="line" id="L2707">    SXS_INVALID_DEACTIVATION = <span class="tok-number">0xC0150010</span>,</span>
<span class="line" id="L2708">    <span class="tok-comment">/// The activation context being deactivated has already been deactivated.</span></span>
<span class="line" id="L2709">    SXS_MULTIPLE_DEACTIVATION = <span class="tok-number">0xC0150011</span>,</span>
<span class="line" id="L2710">    <span class="tok-comment">/// The activation context of the system default assembly could not be generated.</span></span>
<span class="line" id="L2711">    SXS_SYSTEM_DEFAULT_ACTIVATION_CONTEXT_EMPTY = <span class="tok-number">0xC0150012</span>,</span>
<span class="line" id="L2712">    <span class="tok-comment">/// A component used by the isolation facility has requested that the process be terminated.</span></span>
<span class="line" id="L2713">    SXS_PROCESS_TERMINATION_REQUESTED = <span class="tok-number">0xC0150013</span>,</span>
<span class="line" id="L2714">    <span class="tok-comment">/// The activation context activation stack for the running thread of execution is corrupt.</span></span>
<span class="line" id="L2715">    SXS_CORRUPT_ACTIVATION_STACK = <span class="tok-number">0xC0150014</span>,</span>
<span class="line" id="L2716">    <span class="tok-comment">/// The application isolation metadata for this process or thread has become corrupt.</span></span>
<span class="line" id="L2717">    SXS_CORRUPTION = <span class="tok-number">0xC0150015</span>,</span>
<span class="line" id="L2718">    <span class="tok-comment">/// The value of an attribute in an identity is not within the legal range.</span></span>
<span class="line" id="L2719">    SXS_INVALID_IDENTITY_ATTRIBUTE_VALUE = <span class="tok-number">0xC0150016</span>,</span>
<span class="line" id="L2720">    <span class="tok-comment">/// The name of an attribute in an identity is not within the legal range.</span></span>
<span class="line" id="L2721">    SXS_INVALID_IDENTITY_ATTRIBUTE_NAME = <span class="tok-number">0xC0150017</span>,</span>
<span class="line" id="L2722">    <span class="tok-comment">/// An identity contains two definitions for the same attribute.</span></span>
<span class="line" id="L2723">    SXS_IDENTITY_DUPLICATE_ATTRIBUTE = <span class="tok-number">0xC0150018</span>,</span>
<span class="line" id="L2724">    <span class="tok-comment">/// The identity string is malformed.</span></span>
<span class="line" id="L2725">    <span class="tok-comment">/// This might be due to a trailing comma, more than two unnamed attributes, a missing attribute name, or a missing attribute value.</span></span>
<span class="line" id="L2726">    SXS_IDENTITY_PARSE_ERROR = <span class="tok-number">0xC0150019</span>,</span>
<span class="line" id="L2727">    <span class="tok-comment">/// The component store has become corrupted.</span></span>
<span class="line" id="L2728">    SXS_COMPONENT_STORE_CORRUPT = <span class="tok-number">0xC015001A</span>,</span>
<span class="line" id="L2729">    <span class="tok-comment">/// A component's file does not match the verification information present in the component manifest.</span></span>
<span class="line" id="L2730">    SXS_FILE_HASH_MISMATCH = <span class="tok-number">0xC015001B</span>,</span>
<span class="line" id="L2731">    <span class="tok-comment">/// The identities of the manifests are identical, but their contents are different.</span></span>
<span class="line" id="L2732">    SXS_MANIFEST_IDENTITY_SAME_BUT_CONTENTS_DIFFERENT = <span class="tok-number">0xC015001C</span>,</span>
<span class="line" id="L2733">    <span class="tok-comment">/// The component identities are different.</span></span>
<span class="line" id="L2734">    SXS_IDENTITIES_DIFFERENT = <span class="tok-number">0xC015001D</span>,</span>
<span class="line" id="L2735">    <span class="tok-comment">/// The assembly is not a deployment.</span></span>
<span class="line" id="L2736">    SXS_ASSEMBLY_IS_NOT_A_DEPLOYMENT = <span class="tok-number">0xC015001E</span>,</span>
<span class="line" id="L2737">    <span class="tok-comment">/// The file is not a part of the assembly.</span></span>
<span class="line" id="L2738">    SXS_FILE_NOT_PART_OF_ASSEMBLY = <span class="tok-number">0xC015001F</span>,</span>
<span class="line" id="L2739">    <span class="tok-comment">/// An advanced installer failed during setup or servicing.</span></span>
<span class="line" id="L2740">    ADVANCED_INSTALLER_FAILED = <span class="tok-number">0xC0150020</span>,</span>
<span class="line" id="L2741">    <span class="tok-comment">/// The character encoding in the XML declaration did not match the encoding used in the document.</span></span>
<span class="line" id="L2742">    XML_ENCODING_MISMATCH = <span class="tok-number">0xC0150021</span>,</span>
<span class="line" id="L2743">    <span class="tok-comment">/// The size of the manifest exceeds the maximum allowed.</span></span>
<span class="line" id="L2744">    SXS_MANIFEST_TOO_BIG = <span class="tok-number">0xC0150022</span>,</span>
<span class="line" id="L2745">    <span class="tok-comment">/// The setting is not registered.</span></span>
<span class="line" id="L2746">    SXS_SETTING_NOT_REGISTERED = <span class="tok-number">0xC0150023</span>,</span>
<span class="line" id="L2747">    <span class="tok-comment">/// One or more required transaction members are not present.</span></span>
<span class="line" id="L2748">    SXS_TRANSACTION_CLOSURE_INCOMPLETE = <span class="tok-number">0xC0150024</span>,</span>
<span class="line" id="L2749">    <span class="tok-comment">/// The SMI primitive installer failed during setup or servicing.</span></span>
<span class="line" id="L2750">    SMI_PRIMITIVE_INSTALLER_FAILED = <span class="tok-number">0xC0150025</span>,</span>
<span class="line" id="L2751">    <span class="tok-comment">/// A generic command executable returned a result that indicates failure.</span></span>
<span class="line" id="L2752">    GENERIC_COMMAND_FAILED = <span class="tok-number">0xC0150026</span>,</span>
<span class="line" id="L2753">    <span class="tok-comment">/// A component is missing file verification information in its manifest.</span></span>
<span class="line" id="L2754">    SXS_FILE_HASH_MISSING = <span class="tok-number">0xC0150027</span>,</span>
<span class="line" id="L2755">    <span class="tok-comment">/// The function attempted to use a name that is reserved for use by another transaction.</span></span>
<span class="line" id="L2756">    TRANSACTIONAL_CONFLICT = <span class="tok-number">0xC0190001</span>,</span>
<span class="line" id="L2757">    <span class="tok-comment">/// The transaction handle associated with this operation is invalid.</span></span>
<span class="line" id="L2758">    INVALID_TRANSACTION = <span class="tok-number">0xC0190002</span>,</span>
<span class="line" id="L2759">    <span class="tok-comment">/// The requested operation was made in the context of a transaction that is no longer active.</span></span>
<span class="line" id="L2760">    TRANSACTION_NOT_ACTIVE = <span class="tok-number">0xC0190003</span>,</span>
<span class="line" id="L2761">    <span class="tok-comment">/// The transaction manager was unable to be successfully initialized. Transacted operations are not supported.</span></span>
<span class="line" id="L2762">    TM_INITIALIZATION_FAILED = <span class="tok-number">0xC0190004</span>,</span>
<span class="line" id="L2763">    <span class="tok-comment">/// Transaction support within the specified file system resource manager was not started or was shut down due to an error.</span></span>
<span class="line" id="L2764">    RM_NOT_ACTIVE = <span class="tok-number">0xC0190005</span>,</span>
<span class="line" id="L2765">    <span class="tok-comment">/// The metadata of the resource manager has been corrupted. The resource manager will not function.</span></span>
<span class="line" id="L2766">    RM_METADATA_CORRUPT = <span class="tok-number">0xC0190006</span>,</span>
<span class="line" id="L2767">    <span class="tok-comment">/// The resource manager attempted to prepare a transaction that it has not successfully joined.</span></span>
<span class="line" id="L2768">    TRANSACTION_NOT_JOINED = <span class="tok-number">0xC0190007</span>,</span>
<span class="line" id="L2769">    <span class="tok-comment">/// The specified directory does not contain a file system resource manager.</span></span>
<span class="line" id="L2770">    DIRECTORY_NOT_RM = <span class="tok-number">0xC0190008</span>,</span>
<span class="line" id="L2771">    <span class="tok-comment">/// The remote server or share does not support transacted file operations.</span></span>
<span class="line" id="L2772">    TRANSACTIONS_UNSUPPORTED_REMOTE = <span class="tok-number">0xC019000A</span>,</span>
<span class="line" id="L2773">    <span class="tok-comment">/// The requested log size for the file system resource manager is invalid.</span></span>
<span class="line" id="L2774">    LOG_RESIZE_INVALID_SIZE = <span class="tok-number">0xC019000B</span>,</span>
<span class="line" id="L2775">    <span class="tok-comment">/// The remote server sent mismatching version number or Fid for a file opened with transactions.</span></span>
<span class="line" id="L2776">    REMOTE_FILE_VERSION_MISMATCH = <span class="tok-number">0xC019000C</span>,</span>
<span class="line" id="L2777">    <span class="tok-comment">/// The resource manager tried to register a protocol that already exists.</span></span>
<span class="line" id="L2778">    CRM_PROTOCOL_ALREADY_EXISTS = <span class="tok-number">0xC019000F</span>,</span>
<span class="line" id="L2779">    <span class="tok-comment">/// The attempt to propagate the transaction failed.</span></span>
<span class="line" id="L2780">    TRANSACTION_PROPAGATION_FAILED = <span class="tok-number">0xC0190010</span>,</span>
<span class="line" id="L2781">    <span class="tok-comment">/// The requested propagation protocol was not registered as a CRM.</span></span>
<span class="line" id="L2782">    CRM_PROTOCOL_NOT_FOUND = <span class="tok-number">0xC0190011</span>,</span>
<span class="line" id="L2783">    <span class="tok-comment">/// The transaction object already has a superior enlistment, and the caller attempted an operation that would have created a new superior. Only a single superior enlistment is allowed.</span></span>
<span class="line" id="L2784">    TRANSACTION_SUPERIOR_EXISTS = <span class="tok-number">0xC0190012</span>,</span>
<span class="line" id="L2785">    <span class="tok-comment">/// The requested operation is not valid on the transaction object in its current state.</span></span>
<span class="line" id="L2786">    TRANSACTION_REQUEST_NOT_VALID = <span class="tok-number">0xC0190013</span>,</span>
<span class="line" id="L2787">    <span class="tok-comment">/// The caller has called a response API, but the response is not expected because the transaction manager did not issue the corresponding request to the caller.</span></span>
<span class="line" id="L2788">    TRANSACTION_NOT_REQUESTED = <span class="tok-number">0xC0190014</span>,</span>
<span class="line" id="L2789">    <span class="tok-comment">/// It is too late to perform the requested operation, because the transaction has already been aborted.</span></span>
<span class="line" id="L2790">    TRANSACTION_ALREADY_ABORTED = <span class="tok-number">0xC0190015</span>,</span>
<span class="line" id="L2791">    <span class="tok-comment">/// It is too late to perform the requested operation, because the transaction has already been committed.</span></span>
<span class="line" id="L2792">    TRANSACTION_ALREADY_COMMITTED = <span class="tok-number">0xC0190016</span>,</span>
<span class="line" id="L2793">    <span class="tok-comment">/// The buffer passed in to NtPushTransaction or NtPullTransaction is not in a valid format.</span></span>
<span class="line" id="L2794">    TRANSACTION_INVALID_MARSHALL_BUFFER = <span class="tok-number">0xC0190017</span>,</span>
<span class="line" id="L2795">    <span class="tok-comment">/// The current transaction context associated with the thread is not a valid handle to a transaction object.</span></span>
<span class="line" id="L2796">    CURRENT_TRANSACTION_NOT_VALID = <span class="tok-number">0xC0190018</span>,</span>
<span class="line" id="L2797">    <span class="tok-comment">/// An attempt to create space in the transactional resource manager's log failed.</span></span>
<span class="line" id="L2798">    <span class="tok-comment">/// The failure status has been recorded in the event log.</span></span>
<span class="line" id="L2799">    LOG_GROWTH_FAILED = <span class="tok-number">0xC0190019</span>,</span>
<span class="line" id="L2800">    <span class="tok-comment">/// The object (file, stream, or link) that corresponds to the handle has been deleted by a transaction savepoint rollback.</span></span>
<span class="line" id="L2801">    OBJECT_NO_LONGER_EXISTS = <span class="tok-number">0xC0190021</span>,</span>
<span class="line" id="L2802">    <span class="tok-comment">/// The specified file miniversion was not found for this transacted file open.</span></span>
<span class="line" id="L2803">    STREAM_MINIVERSION_NOT_FOUND = <span class="tok-number">0xC0190022</span>,</span>
<span class="line" id="L2804">    <span class="tok-comment">/// The specified file miniversion was found but has been invalidated.</span></span>
<span class="line" id="L2805">    <span class="tok-comment">/// The most likely cause is a transaction savepoint rollback.</span></span>
<span class="line" id="L2806">    STREAM_MINIVERSION_NOT_VALID = <span class="tok-number">0xC0190023</span>,</span>
<span class="line" id="L2807">    <span class="tok-comment">/// A miniversion can be opened only in the context of the transaction that created it.</span></span>
<span class="line" id="L2808">    MINIVERSION_INACCESSIBLE_FROM_SPECIFIED_TRANSACTION = <span class="tok-number">0xC0190024</span>,</span>
<span class="line" id="L2809">    <span class="tok-comment">/// It is not possible to open a miniversion with modify access.</span></span>
<span class="line" id="L2810">    CANT_OPEN_MINIVERSION_WITH_MODIFY_INTENT = <span class="tok-number">0xC0190025</span>,</span>
<span class="line" id="L2811">    <span class="tok-comment">/// It is not possible to create any more miniversions for this stream.</span></span>
<span class="line" id="L2812">    CANT_CREATE_MORE_STREAM_MINIVERSIONS = <span class="tok-number">0xC0190026</span>,</span>
<span class="line" id="L2813">    <span class="tok-comment">/// The handle has been invalidated by a transaction.</span></span>
<span class="line" id="L2814">    <span class="tok-comment">/// The most likely cause is the presence of memory mapping on a file or an open handle when the transaction ended or rolled back to savepoint.</span></span>
<span class="line" id="L2815">    HANDLE_NO_LONGER_VALID = <span class="tok-number">0xC0190028</span>,</span>
<span class="line" id="L2816">    <span class="tok-comment">/// The log data is corrupt.</span></span>
<span class="line" id="L2817">    LOG_CORRUPTION_DETECTED = <span class="tok-number">0xC0190030</span>,</span>
<span class="line" id="L2818">    <span class="tok-comment">/// The transaction outcome is unavailable because the resource manager responsible for it is disconnected.</span></span>
<span class="line" id="L2819">    RM_DISCONNECTED = <span class="tok-number">0xC0190032</span>,</span>
<span class="line" id="L2820">    <span class="tok-comment">/// The request was rejected because the enlistment in question is not a superior enlistment.</span></span>
<span class="line" id="L2821">    ENLISTMENT_NOT_SUPERIOR = <span class="tok-number">0xC0190033</span>,</span>
<span class="line" id="L2822">    <span class="tok-comment">/// The file cannot be opened in a transaction because its identity depends on the outcome of an unresolved transaction.</span></span>
<span class="line" id="L2823">    FILE_IDENTITY_NOT_PERSISTENT = <span class="tok-number">0xC0190036</span>,</span>
<span class="line" id="L2824">    <span class="tok-comment">/// The operation cannot be performed because another transaction is depending on this property not changing.</span></span>
<span class="line" id="L2825">    CANT_BREAK_TRANSACTIONAL_DEPENDENCY = <span class="tok-number">0xC0190037</span>,</span>
<span class="line" id="L2826">    <span class="tok-comment">/// The operation would involve a single file with two transactional resource managers and is, therefore, not allowed.</span></span>
<span class="line" id="L2827">    CANT_CROSS_RM_BOUNDARY = <span class="tok-number">0xC0190038</span>,</span>
<span class="line" id="L2828">    <span class="tok-comment">/// The $Txf directory must be empty for this operation to succeed.</span></span>
<span class="line" id="L2829">    TXF_DIR_NOT_EMPTY = <span class="tok-number">0xC0190039</span>,</span>
<span class="line" id="L2830">    <span class="tok-comment">/// The operation would leave a transactional resource manager in an inconsistent state and is therefore not allowed.</span></span>
<span class="line" id="L2831">    INDOUBT_TRANSACTIONS_EXIST = <span class="tok-number">0xC019003A</span>,</span>
<span class="line" id="L2832">    <span class="tok-comment">/// The operation could not be completed because the transaction manager does not have a log.</span></span>
<span class="line" id="L2833">    TM_VOLATILE = <span class="tok-number">0xC019003B</span>,</span>
<span class="line" id="L2834">    <span class="tok-comment">/// A rollback could not be scheduled because a previously scheduled rollback has already executed or been queued for execution.</span></span>
<span class="line" id="L2835">    ROLLBACK_TIMER_EXPIRED = <span class="tok-number">0xC019003C</span>,</span>
<span class="line" id="L2836">    <span class="tok-comment">/// The transactional metadata attribute on the file or directory %hs is corrupt and unreadable.</span></span>
<span class="line" id="L2837">    TXF_ATTRIBUTE_CORRUPT = <span class="tok-number">0xC019003D</span>,</span>
<span class="line" id="L2838">    <span class="tok-comment">/// The encryption operation could not be completed because a transaction is active.</span></span>
<span class="line" id="L2839">    EFS_NOT_ALLOWED_IN_TRANSACTION = <span class="tok-number">0xC019003E</span>,</span>
<span class="line" id="L2840">    <span class="tok-comment">/// This object is not allowed to be opened in a transaction.</span></span>
<span class="line" id="L2841">    TRANSACTIONAL_OPEN_NOT_ALLOWED = <span class="tok-number">0xC019003F</span>,</span>
<span class="line" id="L2842">    <span class="tok-comment">/// Memory mapping (creating a mapped section) a remote file under a transaction is not supported.</span></span>
<span class="line" id="L2843">    TRANSACTED_MAPPING_UNSUPPORTED_REMOTE = <span class="tok-number">0xC0190040</span>,</span>
<span class="line" id="L2844">    <span class="tok-comment">/// Promotion was required to allow the resource manager to enlist, but the transaction was set to disallow it.</span></span>
<span class="line" id="L2845">    TRANSACTION_REQUIRED_PROMOTION = <span class="tok-number">0xC0190043</span>,</span>
<span class="line" id="L2846">    <span class="tok-comment">/// This file is open for modification in an unresolved transaction and can be opened for execute only by a transacted reader.</span></span>
<span class="line" id="L2847">    CANNOT_EXECUTE_FILE_IN_TRANSACTION = <span class="tok-number">0xC0190044</span>,</span>
<span class="line" id="L2848">    <span class="tok-comment">/// The request to thaw frozen transactions was ignored because transactions were not previously frozen.</span></span>
<span class="line" id="L2849">    TRANSACTIONS_NOT_FROZEN = <span class="tok-number">0xC0190045</span>,</span>
<span class="line" id="L2850">    <span class="tok-comment">/// Transactions cannot be frozen because a freeze is already in progress.</span></span>
<span class="line" id="L2851">    TRANSACTION_FREEZE_IN_PROGRESS = <span class="tok-number">0xC0190046</span>,</span>
<span class="line" id="L2852">    <span class="tok-comment">/// The target volume is not a snapshot volume.</span></span>
<span class="line" id="L2853">    <span class="tok-comment">/// This operation is valid only on a volume mounted as a snapshot.</span></span>
<span class="line" id="L2854">    NOT_SNAPSHOT_VOLUME = <span class="tok-number">0xC0190047</span>,</span>
<span class="line" id="L2855">    <span class="tok-comment">/// The savepoint operation failed because files are open on the transaction, which is not permitted.</span></span>
<span class="line" id="L2856">    NO_SAVEPOINT_WITH_OPEN_FILES = <span class="tok-number">0xC0190048</span>,</span>
<span class="line" id="L2857">    <span class="tok-comment">/// The sparse operation could not be completed because a transaction is active on the file.</span></span>
<span class="line" id="L2858">    SPARSE_NOT_ALLOWED_IN_TRANSACTION = <span class="tok-number">0xC0190049</span>,</span>
<span class="line" id="L2859">    <span class="tok-comment">/// The call to create a transaction manager object failed because the Tm Identity that is stored in the log file does not match the Tm Identity that was passed in as an argument.</span></span>
<span class="line" id="L2860">    TM_IDENTITY_MISMATCH = <span class="tok-number">0xC019004A</span>,</span>
<span class="line" id="L2861">    <span class="tok-comment">/// I/O was attempted on a section object that has been floated as a result of a transaction ending. There is no valid data.</span></span>
<span class="line" id="L2862">    FLOATED_SECTION = <span class="tok-number">0xC019004B</span>,</span>
<span class="line" id="L2863">    <span class="tok-comment">/// The transactional resource manager cannot currently accept transacted work due to a transient condition, such as low resources.</span></span>
<span class="line" id="L2864">    CANNOT_ACCEPT_TRANSACTED_WORK = <span class="tok-number">0xC019004C</span>,</span>
<span class="line" id="L2865">    <span class="tok-comment">/// The transactional resource manager had too many transactions outstanding that could not be aborted.</span></span>
<span class="line" id="L2866">    <span class="tok-comment">/// The transactional resource manager has been shut down.</span></span>
<span class="line" id="L2867">    CANNOT_ABORT_TRANSACTIONS = <span class="tok-number">0xC019004D</span>,</span>
<span class="line" id="L2868">    <span class="tok-comment">/// The specified transaction was unable to be opened because it was not found.</span></span>
<span class="line" id="L2869">    TRANSACTION_NOT_FOUND = <span class="tok-number">0xC019004E</span>,</span>
<span class="line" id="L2870">    <span class="tok-comment">/// The specified resource manager was unable to be opened because it was not found.</span></span>
<span class="line" id="L2871">    RESOURCEMANAGER_NOT_FOUND = <span class="tok-number">0xC019004F</span>,</span>
<span class="line" id="L2872">    <span class="tok-comment">/// The specified enlistment was unable to be opened because it was not found.</span></span>
<span class="line" id="L2873">    ENLISTMENT_NOT_FOUND = <span class="tok-number">0xC0190050</span>,</span>
<span class="line" id="L2874">    <span class="tok-comment">/// The specified transaction manager was unable to be opened because it was not found.</span></span>
<span class="line" id="L2875">    TRANSACTIONMANAGER_NOT_FOUND = <span class="tok-number">0xC0190051</span>,</span>
<span class="line" id="L2876">    <span class="tok-comment">/// The specified resource manager was unable to create an enlistment because its associated transaction manager is not online.</span></span>
<span class="line" id="L2877">    TRANSACTIONMANAGER_NOT_ONLINE = <span class="tok-number">0xC0190052</span>,</span>
<span class="line" id="L2878">    <span class="tok-comment">/// The specified transaction manager was unable to create the objects contained in its log file in the Ob namespace.</span></span>
<span class="line" id="L2879">    <span class="tok-comment">/// Therefore, the transaction manager was unable to recover.</span></span>
<span class="line" id="L2880">    TRANSACTIONMANAGER_RECOVERY_NAME_COLLISION = <span class="tok-number">0xC0190053</span>,</span>
<span class="line" id="L2881">    <span class="tok-comment">/// The call to create a superior enlistment on this transaction object could not be completed because the transaction object specified for the enlistment is a subordinate branch of the transaction.</span></span>
<span class="line" id="L2882">    <span class="tok-comment">/// Only the root of the transaction can be enlisted as a superior.</span></span>
<span class="line" id="L2883">    TRANSACTION_NOT_ROOT = <span class="tok-number">0xC0190054</span>,</span>
<span class="line" id="L2884">    <span class="tok-comment">/// Because the associated transaction manager or resource manager has been closed, the handle is no longer valid.</span></span>
<span class="line" id="L2885">    TRANSACTION_OBJECT_EXPIRED = <span class="tok-number">0xC0190055</span>,</span>
<span class="line" id="L2886">    <span class="tok-comment">/// The compression operation could not be completed because a transaction is active on the file.</span></span>
<span class="line" id="L2887">    COMPRESSION_NOT_ALLOWED_IN_TRANSACTION = <span class="tok-number">0xC0190056</span>,</span>
<span class="line" id="L2888">    <span class="tok-comment">/// The specified operation could not be performed on this superior enlistment because the enlistment was not created with the corresponding completion response in the NotificationMask.</span></span>
<span class="line" id="L2889">    TRANSACTION_RESPONSE_NOT_ENLISTED = <span class="tok-number">0xC0190057</span>,</span>
<span class="line" id="L2890">    <span class="tok-comment">/// The specified operation could not be performed because the record to be logged was too long.</span></span>
<span class="line" id="L2891">    <span class="tok-comment">/// This can occur because either there are too many enlistments on this transaction or the combined RecoveryInformation being logged on behalf of those enlistments is too long.</span></span>
<span class="line" id="L2892">    TRANSACTION_RECORD_TOO_LONG = <span class="tok-number">0xC0190058</span>,</span>
<span class="line" id="L2893">    <span class="tok-comment">/// The link-tracking operation could not be completed because a transaction is active.</span></span>
<span class="line" id="L2894">    NO_LINK_TRACKING_IN_TRANSACTION = <span class="tok-number">0xC0190059</span>,</span>
<span class="line" id="L2895">    <span class="tok-comment">/// This operation cannot be performed in a transaction.</span></span>
<span class="line" id="L2896">    OPERATION_NOT_SUPPORTED_IN_TRANSACTION = <span class="tok-number">0xC019005A</span>,</span>
<span class="line" id="L2897">    <span class="tok-comment">/// The kernel transaction manager had to abort or forget the transaction because it blocked forward progress.</span></span>
<span class="line" id="L2898">    TRANSACTION_INTEGRITY_VIOLATED = <span class="tok-number">0xC019005B</span>,</span>
<span class="line" id="L2899">    <span class="tok-comment">/// The handle is no longer properly associated with its transaction.</span></span>
<span class="line" id="L2900">    <span class="tok-comment">///  It might have been opened in a transactional resource manager that was subsequently forced to restart.  Please close the handle and open a new one.</span></span>
<span class="line" id="L2901">    EXPIRED_HANDLE = <span class="tok-number">0xC0190060</span>,</span>
<span class="line" id="L2902">    <span class="tok-comment">/// The specified operation could not be performed because the resource manager is not enlisted in the transaction.</span></span>
<span class="line" id="L2903">    TRANSACTION_NOT_ENLISTED = <span class="tok-number">0xC0190061</span>,</span>
<span class="line" id="L2904">    <span class="tok-comment">/// The log service found an invalid log sector.</span></span>
<span class="line" id="L2905">    LOG_SECTOR_INVALID = <span class="tok-number">0xC01A0001</span>,</span>
<span class="line" id="L2906">    <span class="tok-comment">/// The log service encountered a log sector with invalid block parity.</span></span>
<span class="line" id="L2907">    LOG_SECTOR_PARITY_INVALID = <span class="tok-number">0xC01A0002</span>,</span>
<span class="line" id="L2908">    <span class="tok-comment">/// The log service encountered a remapped log sector.</span></span>
<span class="line" id="L2909">    LOG_SECTOR_REMAPPED = <span class="tok-number">0xC01A0003</span>,</span>
<span class="line" id="L2910">    <span class="tok-comment">/// The log service encountered a partial or incomplete log block.</span></span>
<span class="line" id="L2911">    LOG_BLOCK_INCOMPLETE = <span class="tok-number">0xC01A0004</span>,</span>
<span class="line" id="L2912">    <span class="tok-comment">/// The log service encountered an attempt to access data outside the active log range.</span></span>
<span class="line" id="L2913">    LOG_INVALID_RANGE = <span class="tok-number">0xC01A0005</span>,</span>
<span class="line" id="L2914">    <span class="tok-comment">/// The log service user-log marshaling buffers are exhausted.</span></span>
<span class="line" id="L2915">    LOG_BLOCKS_EXHAUSTED = <span class="tok-number">0xC01A0006</span>,</span>
<span class="line" id="L2916">    <span class="tok-comment">/// The log service encountered an attempt to read from a marshaling area with an invalid read context.</span></span>
<span class="line" id="L2917">    LOG_READ_CONTEXT_INVALID = <span class="tok-number">0xC01A0007</span>,</span>
<span class="line" id="L2918">    <span class="tok-comment">/// The log service encountered an invalid log restart area.</span></span>
<span class="line" id="L2919">    LOG_RESTART_INVALID = <span class="tok-number">0xC01A0008</span>,</span>
<span class="line" id="L2920">    <span class="tok-comment">/// The log service encountered an invalid log block version.</span></span>
<span class="line" id="L2921">    LOG_BLOCK_VERSION = <span class="tok-number">0xC01A0009</span>,</span>
<span class="line" id="L2922">    <span class="tok-comment">/// The log service encountered an invalid log block.</span></span>
<span class="line" id="L2923">    LOG_BLOCK_INVALID = <span class="tok-number">0xC01A000A</span>,</span>
<span class="line" id="L2924">    <span class="tok-comment">/// The log service encountered an attempt to read the log with an invalid read mode.</span></span>
<span class="line" id="L2925">    LOG_READ_MODE_INVALID = <span class="tok-number">0xC01A000B</span>,</span>
<span class="line" id="L2926">    <span class="tok-comment">/// The log service encountered a corrupted metadata file.</span></span>
<span class="line" id="L2927">    LOG_METADATA_CORRUPT = <span class="tok-number">0xC01A000D</span>,</span>
<span class="line" id="L2928">    <span class="tok-comment">/// The log service encountered a metadata file that could not be created by the log file system.</span></span>
<span class="line" id="L2929">    LOG_METADATA_INVALID = <span class="tok-number">0xC01A000E</span>,</span>
<span class="line" id="L2930">    <span class="tok-comment">/// The log service encountered a metadata file with inconsistent data.</span></span>
<span class="line" id="L2931">    LOG_METADATA_INCONSISTENT = <span class="tok-number">0xC01A000F</span>,</span>
<span class="line" id="L2932">    <span class="tok-comment">/// The log service encountered an attempt to erroneously allocate or dispose reservation space.</span></span>
<span class="line" id="L2933">    LOG_RESERVATION_INVALID = <span class="tok-number">0xC01A0010</span>,</span>
<span class="line" id="L2934">    <span class="tok-comment">/// The log service cannot delete the log file or the file system container.</span></span>
<span class="line" id="L2935">    LOG_CANT_DELETE = <span class="tok-number">0xC01A0011</span>,</span>
<span class="line" id="L2936">    <span class="tok-comment">/// The log service has reached the maximum allowable containers allocated to a log file.</span></span>
<span class="line" id="L2937">    LOG_CONTAINER_LIMIT_EXCEEDED = <span class="tok-number">0xC01A0012</span>,</span>
<span class="line" id="L2938">    <span class="tok-comment">/// The log service has attempted to read or write backward past the start of the log.</span></span>
<span class="line" id="L2939">    LOG_START_OF_LOG = <span class="tok-number">0xC01A0013</span>,</span>
<span class="line" id="L2940">    <span class="tok-comment">/// The log policy could not be installed because a policy of the same type is already present.</span></span>
<span class="line" id="L2941">    LOG_POLICY_ALREADY_INSTALLED = <span class="tok-number">0xC01A0014</span>,</span>
<span class="line" id="L2942">    <span class="tok-comment">/// The log policy in question was not installed at the time of the request.</span></span>
<span class="line" id="L2943">    LOG_POLICY_NOT_INSTALLED = <span class="tok-number">0xC01A0015</span>,</span>
<span class="line" id="L2944">    <span class="tok-comment">/// The installed set of policies on the log is invalid.</span></span>
<span class="line" id="L2945">    LOG_POLICY_INVALID = <span class="tok-number">0xC01A0016</span>,</span>
<span class="line" id="L2946">    <span class="tok-comment">/// A policy on the log in question prevented the operation from completing.</span></span>
<span class="line" id="L2947">    LOG_POLICY_CONFLICT = <span class="tok-number">0xC01A0017</span>,</span>
<span class="line" id="L2948">    <span class="tok-comment">/// The log space cannot be reclaimed because the log is pinned by the archive tail.</span></span>
<span class="line" id="L2949">    LOG_PINNED_ARCHIVE_TAIL = <span class="tok-number">0xC01A0018</span>,</span>
<span class="line" id="L2950">    <span class="tok-comment">/// The log record is not a record in the log file.</span></span>
<span class="line" id="L2951">    LOG_RECORD_NONEXISTENT = <span class="tok-number">0xC01A0019</span>,</span>
<span class="line" id="L2952">    <span class="tok-comment">/// The number of reserved log records or the adjustment of the number of reserved log records is invalid.</span></span>
<span class="line" id="L2953">    LOG_RECORDS_RESERVED_INVALID = <span class="tok-number">0xC01A001A</span>,</span>
<span class="line" id="L2954">    <span class="tok-comment">/// The reserved log space or the adjustment of the log space is invalid.</span></span>
<span class="line" id="L2955">    LOG_SPACE_RESERVED_INVALID = <span class="tok-number">0xC01A001B</span>,</span>
<span class="line" id="L2956">    <span class="tok-comment">/// A new or existing archive tail or the base of the active log is invalid.</span></span>
<span class="line" id="L2957">    LOG_TAIL_INVALID = <span class="tok-number">0xC01A001C</span>,</span>
<span class="line" id="L2958">    <span class="tok-comment">/// The log space is exhausted.</span></span>
<span class="line" id="L2959">    LOG_FULL = <span class="tok-number">0xC01A001D</span>,</span>
<span class="line" id="L2960">    <span class="tok-comment">/// The log is multiplexed; no direct writes to the physical log are allowed.</span></span>
<span class="line" id="L2961">    LOG_MULTIPLEXED = <span class="tok-number">0xC01A001E</span>,</span>
<span class="line" id="L2962">    <span class="tok-comment">/// The operation failed because the log is dedicated.</span></span>
<span class="line" id="L2963">    LOG_DEDICATED = <span class="tok-number">0xC01A001F</span>,</span>
<span class="line" id="L2964">    <span class="tok-comment">/// The operation requires an archive context.</span></span>
<span class="line" id="L2965">    LOG_ARCHIVE_NOT_IN_PROGRESS = <span class="tok-number">0xC01A0020</span>,</span>
<span class="line" id="L2966">    <span class="tok-comment">/// Log archival is in progress.</span></span>
<span class="line" id="L2967">    LOG_ARCHIVE_IN_PROGRESS = <span class="tok-number">0xC01A0021</span>,</span>
<span class="line" id="L2968">    <span class="tok-comment">/// The operation requires a nonephemeral log, but the log is ephemeral.</span></span>
<span class="line" id="L2969">    LOG_EPHEMERAL = <span class="tok-number">0xC01A0022</span>,</span>
<span class="line" id="L2970">    <span class="tok-comment">/// The log must have at least two containers before it can be read from or written to.</span></span>
<span class="line" id="L2971">    LOG_NOT_ENOUGH_CONTAINERS = <span class="tok-number">0xC01A0023</span>,</span>
<span class="line" id="L2972">    <span class="tok-comment">/// A log client has already registered on the stream.</span></span>
<span class="line" id="L2973">    LOG_CLIENT_ALREADY_REGISTERED = <span class="tok-number">0xC01A0024</span>,</span>
<span class="line" id="L2974">    <span class="tok-comment">/// A log client has not been registered on the stream.</span></span>
<span class="line" id="L2975">    LOG_CLIENT_NOT_REGISTERED = <span class="tok-number">0xC01A0025</span>,</span>
<span class="line" id="L2976">    <span class="tok-comment">/// A request has already been made to handle the log full condition.</span></span>
<span class="line" id="L2977">    LOG_FULL_HANDLER_IN_PROGRESS = <span class="tok-number">0xC01A0026</span>,</span>
<span class="line" id="L2978">    <span class="tok-comment">/// The log service encountered an error when attempting to read from a log container.</span></span>
<span class="line" id="L2979">    LOG_CONTAINER_READ_FAILED = <span class="tok-number">0xC01A0027</span>,</span>
<span class="line" id="L2980">    <span class="tok-comment">/// The log service encountered an error when attempting to write to a log container.</span></span>
<span class="line" id="L2981">    LOG_CONTAINER_WRITE_FAILED = <span class="tok-number">0xC01A0028</span>,</span>
<span class="line" id="L2982">    <span class="tok-comment">/// The log service encountered an error when attempting to open a log container.</span></span>
<span class="line" id="L2983">    LOG_CONTAINER_OPEN_FAILED = <span class="tok-number">0xC01A0029</span>,</span>
<span class="line" id="L2984">    <span class="tok-comment">/// The log service encountered an invalid container state when attempting a requested action.</span></span>
<span class="line" id="L2985">    LOG_CONTAINER_STATE_INVALID = <span class="tok-number">0xC01A002A</span>,</span>
<span class="line" id="L2986">    <span class="tok-comment">/// The log service is not in the correct state to perform a requested action.</span></span>
<span class="line" id="L2987">    LOG_STATE_INVALID = <span class="tok-number">0xC01A002B</span>,</span>
<span class="line" id="L2988">    <span class="tok-comment">/// The log space cannot be reclaimed because the log is pinned.</span></span>
<span class="line" id="L2989">    LOG_PINNED = <span class="tok-number">0xC01A002C</span>,</span>
<span class="line" id="L2990">    <span class="tok-comment">/// The log metadata flush failed.</span></span>
<span class="line" id="L2991">    LOG_METADATA_FLUSH_FAILED = <span class="tok-number">0xC01A002D</span>,</span>
<span class="line" id="L2992">    <span class="tok-comment">/// Security on the log and its containers is inconsistent.</span></span>
<span class="line" id="L2993">    LOG_INCONSISTENT_SECURITY = <span class="tok-number">0xC01A002E</span>,</span>
<span class="line" id="L2994">    <span class="tok-comment">/// Records were appended to the log or reservation changes were made, but the log could not be flushed.</span></span>
<span class="line" id="L2995">    LOG_APPENDED_FLUSH_FAILED = <span class="tok-number">0xC01A002F</span>,</span>
<span class="line" id="L2996">    <span class="tok-comment">/// The log is pinned due to reservation consuming most of the log space.</span></span>
<span class="line" id="L2997">    <span class="tok-comment">/// Free some reserved records to make space available.</span></span>
<span class="line" id="L2998">    LOG_PINNED_RESERVATION = <span class="tok-number">0xC01A0030</span>,</span>
<span class="line" id="L2999">    <span class="tok-comment">/// {Display Driver Stopped Responding} The %hs display driver has stopped working normally.</span></span>
<span class="line" id="L3000">    <span class="tok-comment">/// Save your work and reboot the system to restore full display functionality.</span></span>
<span class="line" id="L3001">    <span class="tok-comment">/// The next time you reboot the computer, a dialog box will allow you to upload data about this failure to Microsoft.</span></span>
<span class="line" id="L3002">    VIDEO_HUNG_DISPLAY_DRIVER_THREAD = <span class="tok-number">0xC01B00EA</span>,</span>
<span class="line" id="L3003">    <span class="tok-comment">/// A handler was not defined by the filter for this operation.</span></span>
<span class="line" id="L3004">    FLT_NO_HANDLER_DEFINED = <span class="tok-number">0xC01C0001</span>,</span>
<span class="line" id="L3005">    <span class="tok-comment">/// A context is already defined for this object.</span></span>
<span class="line" id="L3006">    FLT_CONTEXT_ALREADY_DEFINED = <span class="tok-number">0xC01C0002</span>,</span>
<span class="line" id="L3007">    <span class="tok-comment">/// Asynchronous requests are not valid for this operation.</span></span>
<span class="line" id="L3008">    FLT_INVALID_ASYNCHRONOUS_REQUEST = <span class="tok-number">0xC01C0003</span>,</span>
<span class="line" id="L3009">    <span class="tok-comment">/// This is an internal error code used by the filter manager to determine if a fast I/O operation should be forced down the input/output request packet (IRP) path. Minifilters should never return this value.</span></span>
<span class="line" id="L3010">    FLT_DISALLOW_FAST_IO = <span class="tok-number">0xC01C0004</span>,</span>
<span class="line" id="L3011">    <span class="tok-comment">/// An invalid name request was made.</span></span>
<span class="line" id="L3012">    <span class="tok-comment">/// The name requested cannot be retrieved at this time.</span></span>
<span class="line" id="L3013">    FLT_INVALID_NAME_REQUEST = <span class="tok-number">0xC01C0005</span>,</span>
<span class="line" id="L3014">    <span class="tok-comment">/// Posting this operation to a worker thread for further processing is not safe at this time because it could lead to a system deadlock.</span></span>
<span class="line" id="L3015">    FLT_NOT_SAFE_TO_POST_OPERATION = <span class="tok-number">0xC01C0006</span>,</span>
<span class="line" id="L3016">    <span class="tok-comment">/// The Filter Manager was not initialized when a filter tried to register.</span></span>
<span class="line" id="L3017">    <span class="tok-comment">/// Make sure that the Filter Manager is loaded as a driver.</span></span>
<span class="line" id="L3018">    FLT_NOT_INITIALIZED = <span class="tok-number">0xC01C0007</span>,</span>
<span class="line" id="L3019">    <span class="tok-comment">/// The filter is not ready for attachment to volumes because it has not finished initializing (FltStartFiltering has not been called).</span></span>
<span class="line" id="L3020">    FLT_FILTER_NOT_READY = <span class="tok-number">0xC01C0008</span>,</span>
<span class="line" id="L3021">    <span class="tok-comment">/// The filter must clean up any operation-specific context at this time because it is being removed from the system before the operation is completed by the lower drivers.</span></span>
<span class="line" id="L3022">    FLT_POST_OPERATION_CLEANUP = <span class="tok-number">0xC01C0009</span>,</span>
<span class="line" id="L3023">    <span class="tok-comment">/// The Filter Manager had an internal error from which it cannot recover; therefore, the operation has failed.</span></span>
<span class="line" id="L3024">    <span class="tok-comment">/// This is usually the result of a filter returning an invalid value from a pre-operation callback.</span></span>
<span class="line" id="L3025">    FLT_INTERNAL_ERROR = <span class="tok-number">0xC01C000A</span>,</span>
<span class="line" id="L3026">    <span class="tok-comment">/// The object specified for this action is in the process of being deleted; therefore, the action requested cannot be completed at this time.</span></span>
<span class="line" id="L3027">    FLT_DELETING_OBJECT = <span class="tok-number">0xC01C000B</span>,</span>
<span class="line" id="L3028">    <span class="tok-comment">/// A nonpaged pool must be used for this type of context.</span></span>
<span class="line" id="L3029">    FLT_MUST_BE_NONPAGED_POOL = <span class="tok-number">0xC01C000C</span>,</span>
<span class="line" id="L3030">    <span class="tok-comment">/// A duplicate handler definition has been provided for an operation.</span></span>
<span class="line" id="L3031">    FLT_DUPLICATE_ENTRY = <span class="tok-number">0xC01C000D</span>,</span>
<span class="line" id="L3032">    <span class="tok-comment">/// The callback data queue has been disabled.</span></span>
<span class="line" id="L3033">    FLT_CBDQ_DISABLED = <span class="tok-number">0xC01C000E</span>,</span>
<span class="line" id="L3034">    <span class="tok-comment">/// Do not attach the filter to the volume at this time.</span></span>
<span class="line" id="L3035">    FLT_DO_NOT_ATTACH = <span class="tok-number">0xC01C000F</span>,</span>
<span class="line" id="L3036">    <span class="tok-comment">/// Do not detach the filter from the volume at this time.</span></span>
<span class="line" id="L3037">    FLT_DO_NOT_DETACH = <span class="tok-number">0xC01C0010</span>,</span>
<span class="line" id="L3038">    <span class="tok-comment">/// An instance already exists at this altitude on the volume specified.</span></span>
<span class="line" id="L3039">    FLT_INSTANCE_ALTITUDE_COLLISION = <span class="tok-number">0xC01C0011</span>,</span>
<span class="line" id="L3040">    <span class="tok-comment">/// An instance already exists with this name on the volume specified.</span></span>
<span class="line" id="L3041">    FLT_INSTANCE_NAME_COLLISION = <span class="tok-number">0xC01C0012</span>,</span>
<span class="line" id="L3042">    <span class="tok-comment">/// The system could not find the filter specified.</span></span>
<span class="line" id="L3043">    FLT_FILTER_NOT_FOUND = <span class="tok-number">0xC01C0013</span>,</span>
<span class="line" id="L3044">    <span class="tok-comment">/// The system could not find the volume specified.</span></span>
<span class="line" id="L3045">    FLT_VOLUME_NOT_FOUND = <span class="tok-number">0xC01C0014</span>,</span>
<span class="line" id="L3046">    <span class="tok-comment">/// The system could not find the instance specified.</span></span>
<span class="line" id="L3047">    FLT_INSTANCE_NOT_FOUND = <span class="tok-number">0xC01C0015</span>,</span>
<span class="line" id="L3048">    <span class="tok-comment">/// No registered context allocation definition was found for the given request.</span></span>
<span class="line" id="L3049">    FLT_CONTEXT_ALLOCATION_NOT_FOUND = <span class="tok-number">0xC01C0016</span>,</span>
<span class="line" id="L3050">    <span class="tok-comment">/// An invalid parameter was specified during context registration.</span></span>
<span class="line" id="L3051">    FLT_INVALID_CONTEXT_REGISTRATION = <span class="tok-number">0xC01C0017</span>,</span>
<span class="line" id="L3052">    <span class="tok-comment">/// The name requested was not found in the Filter Manager name cache and could not be retrieved from the file system.</span></span>
<span class="line" id="L3053">    FLT_NAME_CACHE_MISS = <span class="tok-number">0xC01C0018</span>,</span>
<span class="line" id="L3054">    <span class="tok-comment">/// The requested device object does not exist for the given volume.</span></span>
<span class="line" id="L3055">    FLT_NO_DEVICE_OBJECT = <span class="tok-number">0xC01C0019</span>,</span>
<span class="line" id="L3056">    <span class="tok-comment">/// The specified volume is already mounted.</span></span>
<span class="line" id="L3057">    FLT_VOLUME_ALREADY_MOUNTED = <span class="tok-number">0xC01C001A</span>,</span>
<span class="line" id="L3058">    <span class="tok-comment">/// The specified transaction context is already enlisted in a transaction.</span></span>
<span class="line" id="L3059">    FLT_ALREADY_ENLISTED = <span class="tok-number">0xC01C001B</span>,</span>
<span class="line" id="L3060">    <span class="tok-comment">/// The specified context is already attached to another object.</span></span>
<span class="line" id="L3061">    FLT_CONTEXT_ALREADY_LINKED = <span class="tok-number">0xC01C001C</span>,</span>
<span class="line" id="L3062">    <span class="tok-comment">/// No waiter is present for the filter's reply to this message.</span></span>
<span class="line" id="L3063">    FLT_NO_WAITER_FOR_REPLY = <span class="tok-number">0xC01C0020</span>,</span>
<span class="line" id="L3064">    <span class="tok-comment">/// A monitor descriptor could not be obtained.</span></span>
<span class="line" id="L3065">    MONITOR_NO_DESCRIPTOR = <span class="tok-number">0xC01D0001</span>,</span>
<span class="line" id="L3066">    <span class="tok-comment">/// This release does not support the format of the obtained monitor descriptor.</span></span>
<span class="line" id="L3067">    MONITOR_UNKNOWN_DESCRIPTOR_FORMAT = <span class="tok-number">0xC01D0002</span>,</span>
<span class="line" id="L3068">    <span class="tok-comment">/// The checksum of the obtained monitor descriptor is invalid.</span></span>
<span class="line" id="L3069">    MONITOR_INVALID_DESCRIPTOR_CHECKSUM = <span class="tok-number">0xC01D0003</span>,</span>
<span class="line" id="L3070">    <span class="tok-comment">/// The monitor descriptor contains an invalid standard timing block.</span></span>
<span class="line" id="L3071">    MONITOR_INVALID_STANDARD_TIMING_BLOCK = <span class="tok-number">0xC01D0004</span>,</span>
<span class="line" id="L3072">    <span class="tok-comment">/// WMI data-block registration failed for one of the MSMonitorClass WMI subclasses.</span></span>
<span class="line" id="L3073">    MONITOR_WMI_DATABLOCK_REGISTRATION_FAILED = <span class="tok-number">0xC01D0005</span>,</span>
<span class="line" id="L3074">    <span class="tok-comment">/// The provided monitor descriptor block is either corrupted or does not contain the monitor's detailed serial number.</span></span>
<span class="line" id="L3075">    MONITOR_INVALID_SERIAL_NUMBER_MONDSC_BLOCK = <span class="tok-number">0xC01D0006</span>,</span>
<span class="line" id="L3076">    <span class="tok-comment">/// The provided monitor descriptor block is either corrupted or does not contain the monitor's user-friendly name.</span></span>
<span class="line" id="L3077">    MONITOR_INVALID_USER_FRIENDLY_MONDSC_BLOCK = <span class="tok-number">0xC01D0007</span>,</span>
<span class="line" id="L3078">    <span class="tok-comment">/// There is no monitor descriptor data at the specified (offset or size) region.</span></span>
<span class="line" id="L3079">    MONITOR_NO_MORE_DESCRIPTOR_DATA = <span class="tok-number">0xC01D0008</span>,</span>
<span class="line" id="L3080">    <span class="tok-comment">/// The monitor descriptor contains an invalid detailed timing block.</span></span>
<span class="line" id="L3081">    MONITOR_INVALID_DETAILED_TIMING_BLOCK = <span class="tok-number">0xC01D0009</span>,</span>
<span class="line" id="L3082">    <span class="tok-comment">/// Monitor descriptor contains invalid manufacture date.</span></span>
<span class="line" id="L3083">    MONITOR_INVALID_MANUFACTURE_DATE = <span class="tok-number">0xC01D000A</span>,</span>
<span class="line" id="L3084">    <span class="tok-comment">/// Exclusive mode ownership is needed to create an unmanaged primary allocation.</span></span>
<span class="line" id="L3085">    GRAPHICS_NOT_EXCLUSIVE_MODE_OWNER = <span class="tok-number">0xC01E0000</span>,</span>
<span class="line" id="L3086">    <span class="tok-comment">/// The driver needs more DMA buffer space to complete the requested operation.</span></span>
<span class="line" id="L3087">    GRAPHICS_INSUFFICIENT_DMA_BUFFER = <span class="tok-number">0xC01E0001</span>,</span>
<span class="line" id="L3088">    <span class="tok-comment">/// The specified display adapter handle is invalid.</span></span>
<span class="line" id="L3089">    GRAPHICS_INVALID_DISPLAY_ADAPTER = <span class="tok-number">0xC01E0002</span>,</span>
<span class="line" id="L3090">    <span class="tok-comment">/// The specified display adapter and all of its state have been reset.</span></span>
<span class="line" id="L3091">    GRAPHICS_ADAPTER_WAS_RESET = <span class="tok-number">0xC01E0003</span>,</span>
<span class="line" id="L3092">    <span class="tok-comment">/// The driver stack does not match the expected driver model.</span></span>
<span class="line" id="L3093">    GRAPHICS_INVALID_DRIVER_MODEL = <span class="tok-number">0xC01E0004</span>,</span>
<span class="line" id="L3094">    <span class="tok-comment">/// Present happened but ended up into the changed desktop mode.</span></span>
<span class="line" id="L3095">    GRAPHICS_PRESENT_MODE_CHANGED = <span class="tok-number">0xC01E0005</span>,</span>
<span class="line" id="L3096">    <span class="tok-comment">/// Nothing to present due to desktop occlusion.</span></span>
<span class="line" id="L3097">    GRAPHICS_PRESENT_OCCLUDED = <span class="tok-number">0xC01E0006</span>,</span>
<span class="line" id="L3098">    <span class="tok-comment">/// Not able to present due to denial of desktop access.</span></span>
<span class="line" id="L3099">    GRAPHICS_PRESENT_DENIED = <span class="tok-number">0xC01E0007</span>,</span>
<span class="line" id="L3100">    <span class="tok-comment">/// Not able to present with color conversion.</span></span>
<span class="line" id="L3101">    GRAPHICS_CANNOTCOLORCONVERT = <span class="tok-number">0xC01E0008</span>,</span>
<span class="line" id="L3102">    <span class="tok-comment">/// Present redirection is disabled (desktop windowing management subsystem is off).</span></span>
<span class="line" id="L3103">    GRAPHICS_PRESENT_REDIRECTION_DISABLED = <span class="tok-number">0xC01E000B</span>,</span>
<span class="line" id="L3104">    <span class="tok-comment">/// Previous exclusive VidPn source owner has released its ownership</span></span>
<span class="line" id="L3105">    GRAPHICS_PRESENT_UNOCCLUDED = <span class="tok-number">0xC01E000C</span>,</span>
<span class="line" id="L3106">    <span class="tok-comment">/// Not enough video memory is available to complete the operation.</span></span>
<span class="line" id="L3107">    GRAPHICS_NO_VIDEO_MEMORY = <span class="tok-number">0xC01E0100</span>,</span>
<span class="line" id="L3108">    <span class="tok-comment">/// Could not probe and lock the underlying memory of an allocation.</span></span>
<span class="line" id="L3109">    GRAPHICS_CANT_LOCK_MEMORY = <span class="tok-number">0xC01E0101</span>,</span>
<span class="line" id="L3110">    <span class="tok-comment">/// The allocation is currently busy.</span></span>
<span class="line" id="L3111">    GRAPHICS_ALLOCATION_BUSY = <span class="tok-number">0xC01E0102</span>,</span>
<span class="line" id="L3112">    <span class="tok-comment">/// An object being referenced has already reached the maximum reference count and cannot be referenced further.</span></span>
<span class="line" id="L3113">    GRAPHICS_TOO_MANY_REFERENCES = <span class="tok-number">0xC01E0103</span>,</span>
<span class="line" id="L3114">    <span class="tok-comment">/// A problem could not be solved due to an existing condition. Try again later.</span></span>
<span class="line" id="L3115">    GRAPHICS_TRY_AGAIN_LATER = <span class="tok-number">0xC01E0104</span>,</span>
<span class="line" id="L3116">    <span class="tok-comment">/// A problem could not be solved due to an existing condition. Try again now.</span></span>
<span class="line" id="L3117">    GRAPHICS_TRY_AGAIN_NOW = <span class="tok-number">0xC01E0105</span>,</span>
<span class="line" id="L3118">    <span class="tok-comment">/// The allocation is invalid.</span></span>
<span class="line" id="L3119">    GRAPHICS_ALLOCATION_INVALID = <span class="tok-number">0xC01E0106</span>,</span>
<span class="line" id="L3120">    <span class="tok-comment">/// No more unswizzling apertures are currently available.</span></span>
<span class="line" id="L3121">    GRAPHICS_UNSWIZZLING_APERTURE_UNAVAILABLE = <span class="tok-number">0xC01E0107</span>,</span>
<span class="line" id="L3122">    <span class="tok-comment">/// The current allocation cannot be unswizzled by an aperture.</span></span>
<span class="line" id="L3123">    GRAPHICS_UNSWIZZLING_APERTURE_UNSUPPORTED = <span class="tok-number">0xC01E0108</span>,</span>
<span class="line" id="L3124">    <span class="tok-comment">/// The request failed because a pinned allocation cannot be evicted.</span></span>
<span class="line" id="L3125">    GRAPHICS_CANT_EVICT_PINNED_ALLOCATION = <span class="tok-number">0xC01E0109</span>,</span>
<span class="line" id="L3126">    <span class="tok-comment">/// The allocation cannot be used from its current segment location for the specified operation.</span></span>
<span class="line" id="L3127">    GRAPHICS_INVALID_ALLOCATION_USAGE = <span class="tok-number">0xC01E0110</span>,</span>
<span class="line" id="L3128">    <span class="tok-comment">/// A locked allocation cannot be used in the current command buffer.</span></span>
<span class="line" id="L3129">    GRAPHICS_CANT_RENDER_LOCKED_ALLOCATION = <span class="tok-number">0xC01E0111</span>,</span>
<span class="line" id="L3130">    <span class="tok-comment">/// The allocation being referenced has been closed permanently.</span></span>
<span class="line" id="L3131">    GRAPHICS_ALLOCATION_CLOSED = <span class="tok-number">0xC01E0112</span>,</span>
<span class="line" id="L3132">    <span class="tok-comment">/// An invalid allocation instance is being referenced.</span></span>
<span class="line" id="L3133">    GRAPHICS_INVALID_ALLOCATION_INSTANCE = <span class="tok-number">0xC01E0113</span>,</span>
<span class="line" id="L3134">    <span class="tok-comment">/// An invalid allocation handle is being referenced.</span></span>
<span class="line" id="L3135">    GRAPHICS_INVALID_ALLOCATION_HANDLE = <span class="tok-number">0xC01E0114</span>,</span>
<span class="line" id="L3136">    <span class="tok-comment">/// The allocation being referenced does not belong to the current device.</span></span>
<span class="line" id="L3137">    GRAPHICS_WRONG_ALLOCATION_DEVICE = <span class="tok-number">0xC01E0115</span>,</span>
<span class="line" id="L3138">    <span class="tok-comment">/// The specified allocation lost its content.</span></span>
<span class="line" id="L3139">    GRAPHICS_ALLOCATION_CONTENT_LOST = <span class="tok-number">0xC01E0116</span>,</span>
<span class="line" id="L3140">    <span class="tok-comment">/// A GPU exception was detected on the given device. The device cannot be scheduled.</span></span>
<span class="line" id="L3141">    GRAPHICS_GPU_EXCEPTION_ON_DEVICE = <span class="tok-number">0xC01E0200</span>,</span>
<span class="line" id="L3142">    <span class="tok-comment">/// The specified VidPN topology is invalid.</span></span>
<span class="line" id="L3143">    GRAPHICS_INVALID_VIDPN_TOPOLOGY = <span class="tok-number">0xC01E0300</span>,</span>
<span class="line" id="L3144">    <span class="tok-comment">/// The specified VidPN topology is valid but is not supported by this model of the display adapter.</span></span>
<span class="line" id="L3145">    GRAPHICS_VIDPN_TOPOLOGY_NOT_SUPPORTED = <span class="tok-number">0xC01E0301</span>,</span>
<span class="line" id="L3146">    <span class="tok-comment">/// The specified VidPN topology is valid but is not currently supported by the display adapter due to allocation of its resources.</span></span>
<span class="line" id="L3147">    GRAPHICS_VIDPN_TOPOLOGY_CURRENTLY_NOT_SUPPORTED = <span class="tok-number">0xC01E0302</span>,</span>
<span class="line" id="L3148">    <span class="tok-comment">/// The specified VidPN handle is invalid.</span></span>
<span class="line" id="L3149">    GRAPHICS_INVALID_VIDPN = <span class="tok-number">0xC01E0303</span>,</span>
<span class="line" id="L3150">    <span class="tok-comment">/// The specified video present source is invalid.</span></span>
<span class="line" id="L3151">    GRAPHICS_INVALID_VIDEO_PRESENT_SOURCE = <span class="tok-number">0xC01E0304</span>,</span>
<span class="line" id="L3152">    <span class="tok-comment">/// The specified video present target is invalid.</span></span>
<span class="line" id="L3153">    GRAPHICS_INVALID_VIDEO_PRESENT_TARGET = <span class="tok-number">0xC01E0305</span>,</span>
<span class="line" id="L3154">    <span class="tok-comment">/// The specified VidPN modality is not supported (for example, at least two of the pinned modes are not co-functional).</span></span>
<span class="line" id="L3155">    GRAPHICS_VIDPN_MODALITY_NOT_SUPPORTED = <span class="tok-number">0xC01E0306</span>,</span>
<span class="line" id="L3156">    <span class="tok-comment">/// The specified VidPN source mode set is invalid.</span></span>
<span class="line" id="L3157">    GRAPHICS_INVALID_VIDPN_SOURCEMODESET = <span class="tok-number">0xC01E0308</span>,</span>
<span class="line" id="L3158">    <span class="tok-comment">/// The specified VidPN target mode set is invalid.</span></span>
<span class="line" id="L3159">    GRAPHICS_INVALID_VIDPN_TARGETMODESET = <span class="tok-number">0xC01E0309</span>,</span>
<span class="line" id="L3160">    <span class="tok-comment">/// The specified video signal frequency is invalid.</span></span>
<span class="line" id="L3161">    GRAPHICS_INVALID_FREQUENCY = <span class="tok-number">0xC01E030A</span>,</span>
<span class="line" id="L3162">    <span class="tok-comment">/// The specified video signal active region is invalid.</span></span>
<span class="line" id="L3163">    GRAPHICS_INVALID_ACTIVE_REGION = <span class="tok-number">0xC01E030B</span>,</span>
<span class="line" id="L3164">    <span class="tok-comment">/// The specified video signal total region is invalid.</span></span>
<span class="line" id="L3165">    GRAPHICS_INVALID_TOTAL_REGION = <span class="tok-number">0xC01E030C</span>,</span>
<span class="line" id="L3166">    <span class="tok-comment">/// The specified video present source mode is invalid.</span></span>
<span class="line" id="L3167">    GRAPHICS_INVALID_VIDEO_PRESENT_SOURCE_MODE = <span class="tok-number">0xC01E0310</span>,</span>
<span class="line" id="L3168">    <span class="tok-comment">/// The specified video present target mode is invalid.</span></span>
<span class="line" id="L3169">    GRAPHICS_INVALID_VIDEO_PRESENT_TARGET_MODE = <span class="tok-number">0xC01E0311</span>,</span>
<span class="line" id="L3170">    <span class="tok-comment">/// The pinned mode must remain in the set on the VidPN's co-functional modality enumeration.</span></span>
<span class="line" id="L3171">    GRAPHICS_PINNED_MODE_MUST_REMAIN_IN_SET = <span class="tok-number">0xC01E0312</span>,</span>
<span class="line" id="L3172">    <span class="tok-comment">/// The specified video present path is already in the VidPN's topology.</span></span>
<span class="line" id="L3173">    GRAPHICS_PATH_ALREADY_IN_TOPOLOGY = <span class="tok-number">0xC01E0313</span>,</span>
<span class="line" id="L3174">    <span class="tok-comment">/// The specified mode is already in the mode set.</span></span>
<span class="line" id="L3175">    GRAPHICS_MODE_ALREADY_IN_MODESET = <span class="tok-number">0xC01E0314</span>,</span>
<span class="line" id="L3176">    <span class="tok-comment">/// The specified video present source set is invalid.</span></span>
<span class="line" id="L3177">    GRAPHICS_INVALID_VIDEOPRESENTSOURCESET = <span class="tok-number">0xC01E0315</span>,</span>
<span class="line" id="L3178">    <span class="tok-comment">/// The specified video present target set is invalid.</span></span>
<span class="line" id="L3179">    GRAPHICS_INVALID_VIDEOPRESENTTARGETSET = <span class="tok-number">0xC01E0316</span>,</span>
<span class="line" id="L3180">    <span class="tok-comment">/// The specified video present source is already in the video present source set.</span></span>
<span class="line" id="L3181">    GRAPHICS_SOURCE_ALREADY_IN_SET = <span class="tok-number">0xC01E0317</span>,</span>
<span class="line" id="L3182">    <span class="tok-comment">/// The specified video present target is already in the video present target set.</span></span>
<span class="line" id="L3183">    GRAPHICS_TARGET_ALREADY_IN_SET = <span class="tok-number">0xC01E0318</span>,</span>
<span class="line" id="L3184">    <span class="tok-comment">/// The specified VidPN present path is invalid.</span></span>
<span class="line" id="L3185">    GRAPHICS_INVALID_VIDPN_PRESENT_PATH = <span class="tok-number">0xC01E0319</span>,</span>
<span class="line" id="L3186">    <span class="tok-comment">/// The miniport has no recommendation for augmenting the specified VidPN's topology.</span></span>
<span class="line" id="L3187">    GRAPHICS_NO_RECOMMENDED_VIDPN_TOPOLOGY = <span class="tok-number">0xC01E031A</span>,</span>
<span class="line" id="L3188">    <span class="tok-comment">/// The specified monitor frequency range set is invalid.</span></span>
<span class="line" id="L3189">    GRAPHICS_INVALID_MONITOR_FREQUENCYRANGESET = <span class="tok-number">0xC01E031B</span>,</span>
<span class="line" id="L3190">    <span class="tok-comment">/// The specified monitor frequency range is invalid.</span></span>
<span class="line" id="L3191">    GRAPHICS_INVALID_MONITOR_FREQUENCYRANGE = <span class="tok-number">0xC01E031C</span>,</span>
<span class="line" id="L3192">    <span class="tok-comment">/// The specified frequency range is not in the specified monitor frequency range set.</span></span>
<span class="line" id="L3193">    GRAPHICS_FREQUENCYRANGE_NOT_IN_SET = <span class="tok-number">0xC01E031D</span>,</span>
<span class="line" id="L3194">    <span class="tok-comment">/// The specified frequency range is already in the specified monitor frequency range set.</span></span>
<span class="line" id="L3195">    GRAPHICS_FREQUENCYRANGE_ALREADY_IN_SET = <span class="tok-number">0xC01E031F</span>,</span>
<span class="line" id="L3196">    <span class="tok-comment">/// The specified mode set is stale. Reacquire the new mode set.</span></span>
<span class="line" id="L3197">    GRAPHICS_STALE_MODESET = <span class="tok-number">0xC01E0320</span>,</span>
<span class="line" id="L3198">    <span class="tok-comment">/// The specified monitor source mode set is invalid.</span></span>
<span class="line" id="L3199">    GRAPHICS_INVALID_MONITOR_SOURCEMODESET = <span class="tok-number">0xC01E0321</span>,</span>
<span class="line" id="L3200">    <span class="tok-comment">/// The specified monitor source mode is invalid.</span></span>
<span class="line" id="L3201">    GRAPHICS_INVALID_MONITOR_SOURCE_MODE = <span class="tok-number">0xC01E0322</span>,</span>
<span class="line" id="L3202">    <span class="tok-comment">/// The miniport does not have a recommendation regarding the request to provide a functional VidPN given the current display adapter configuration.</span></span>
<span class="line" id="L3203">    GRAPHICS_NO_RECOMMENDED_FUNCTIONAL_VIDPN = <span class="tok-number">0xC01E0323</span>,</span>
<span class="line" id="L3204">    <span class="tok-comment">/// The ID of the specified mode is being used by another mode in the set.</span></span>
<span class="line" id="L3205">    GRAPHICS_MODE_ID_MUST_BE_UNIQUE = <span class="tok-number">0xC01E0324</span>,</span>
<span class="line" id="L3206">    <span class="tok-comment">/// The system failed to determine a mode that is supported by both the display adapter and the monitor connected to it.</span></span>
<span class="line" id="L3207">    GRAPHICS_EMPTY_ADAPTER_MONITOR_MODE_SUPPORT_INTERSECTION = <span class="tok-number">0xC01E0325</span>,</span>
<span class="line" id="L3208">    <span class="tok-comment">/// The number of video present targets must be greater than or equal to the number of video present sources.</span></span>
<span class="line" id="L3209">    GRAPHICS_VIDEO_PRESENT_TARGETS_LESS_THAN_SOURCES = <span class="tok-number">0xC01E0326</span>,</span>
<span class="line" id="L3210">    <span class="tok-comment">/// The specified present path is not in the VidPN's topology.</span></span>
<span class="line" id="L3211">    GRAPHICS_PATH_NOT_IN_TOPOLOGY = <span class="tok-number">0xC01E0327</span>,</span>
<span class="line" id="L3212">    <span class="tok-comment">/// The display adapter must have at least one video present source.</span></span>
<span class="line" id="L3213">    GRAPHICS_ADAPTER_MUST_HAVE_AT_LEAST_ONE_SOURCE = <span class="tok-number">0xC01E0328</span>,</span>
<span class="line" id="L3214">    <span class="tok-comment">/// The display adapter must have at least one video present target.</span></span>
<span class="line" id="L3215">    GRAPHICS_ADAPTER_MUST_HAVE_AT_LEAST_ONE_TARGET = <span class="tok-number">0xC01E0329</span>,</span>
<span class="line" id="L3216">    <span class="tok-comment">/// The specified monitor descriptor set is invalid.</span></span>
<span class="line" id="L3217">    GRAPHICS_INVALID_MONITORDESCRIPTORSET = <span class="tok-number">0xC01E032A</span>,</span>
<span class="line" id="L3218">    <span class="tok-comment">/// The specified monitor descriptor is invalid.</span></span>
<span class="line" id="L3219">    GRAPHICS_INVALID_MONITORDESCRIPTOR = <span class="tok-number">0xC01E032B</span>,</span>
<span class="line" id="L3220">    <span class="tok-comment">/// The specified descriptor is not in the specified monitor descriptor set.</span></span>
<span class="line" id="L3221">    GRAPHICS_MONITORDESCRIPTOR_NOT_IN_SET = <span class="tok-number">0xC01E032C</span>,</span>
<span class="line" id="L3222">    <span class="tok-comment">/// The specified descriptor is already in the specified monitor descriptor set.</span></span>
<span class="line" id="L3223">    GRAPHICS_MONITORDESCRIPTOR_ALREADY_IN_SET = <span class="tok-number">0xC01E032D</span>,</span>
<span class="line" id="L3224">    <span class="tok-comment">/// The ID of the specified monitor descriptor is being used by another descriptor in the set.</span></span>
<span class="line" id="L3225">    GRAPHICS_MONITORDESCRIPTOR_ID_MUST_BE_UNIQUE = <span class="tok-number">0xC01E032E</span>,</span>
<span class="line" id="L3226">    <span class="tok-comment">/// The specified video present target subset type is invalid.</span></span>
<span class="line" id="L3227">    GRAPHICS_INVALID_VIDPN_TARGET_SUBSET_TYPE = <span class="tok-number">0xC01E032F</span>,</span>
<span class="line" id="L3228">    <span class="tok-comment">/// Two or more of the specified resources are not related to each other, as defined by the interface semantics.</span></span>
<span class="line" id="L3229">    GRAPHICS_RESOURCES_NOT_RELATED = <span class="tok-number">0xC01E0330</span>,</span>
<span class="line" id="L3230">    <span class="tok-comment">/// The ID of the specified video present source is being used by another source in the set.</span></span>
<span class="line" id="L3231">    GRAPHICS_SOURCE_ID_MUST_BE_UNIQUE = <span class="tok-number">0xC01E0331</span>,</span>
<span class="line" id="L3232">    <span class="tok-comment">/// The ID of the specified video present target is being used by another target in the set.</span></span>
<span class="line" id="L3233">    GRAPHICS_TARGET_ID_MUST_BE_UNIQUE = <span class="tok-number">0xC01E0332</span>,</span>
<span class="line" id="L3234">    <span class="tok-comment">/// The specified VidPN source cannot be used because there is no available VidPN target to connect it to.</span></span>
<span class="line" id="L3235">    GRAPHICS_NO_AVAILABLE_VIDPN_TARGET = <span class="tok-number">0xC01E0333</span>,</span>
<span class="line" id="L3236">    <span class="tok-comment">/// The newly arrived monitor could not be associated with a display adapter.</span></span>
<span class="line" id="L3237">    GRAPHICS_MONITOR_COULD_NOT_BE_ASSOCIATED_WITH_ADAPTER = <span class="tok-number">0xC01E0334</span>,</span>
<span class="line" id="L3238">    <span class="tok-comment">/// The particular display adapter does not have an associated VidPN manager.</span></span>
<span class="line" id="L3239">    GRAPHICS_NO_VIDPNMGR = <span class="tok-number">0xC01E0335</span>,</span>
<span class="line" id="L3240">    <span class="tok-comment">/// The VidPN manager of the particular display adapter does not have an active VidPN.</span></span>
<span class="line" id="L3241">    GRAPHICS_NO_ACTIVE_VIDPN = <span class="tok-number">0xC01E0336</span>,</span>
<span class="line" id="L3242">    <span class="tok-comment">/// The specified VidPN topology is stale; obtain the new topology.</span></span>
<span class="line" id="L3243">    GRAPHICS_STALE_VIDPN_TOPOLOGY = <span class="tok-number">0xC01E0337</span>,</span>
<span class="line" id="L3244">    <span class="tok-comment">/// No monitor is connected on the specified video present target.</span></span>
<span class="line" id="L3245">    GRAPHICS_MONITOR_NOT_CONNECTED = <span class="tok-number">0xC01E0338</span>,</span>
<span class="line" id="L3246">    <span class="tok-comment">/// The specified source is not part of the specified VidPN's topology.</span></span>
<span class="line" id="L3247">    GRAPHICS_SOURCE_NOT_IN_TOPOLOGY = <span class="tok-number">0xC01E0339</span>,</span>
<span class="line" id="L3248">    <span class="tok-comment">/// The specified primary surface size is invalid.</span></span>
<span class="line" id="L3249">    GRAPHICS_INVALID_PRIMARYSURFACE_SIZE = <span class="tok-number">0xC01E033A</span>,</span>
<span class="line" id="L3250">    <span class="tok-comment">/// The specified visible region size is invalid.</span></span>
<span class="line" id="L3251">    GRAPHICS_INVALID_VISIBLEREGION_SIZE = <span class="tok-number">0xC01E033B</span>,</span>
<span class="line" id="L3252">    <span class="tok-comment">/// The specified stride is invalid.</span></span>
<span class="line" id="L3253">    GRAPHICS_INVALID_STRIDE = <span class="tok-number">0xC01E033C</span>,</span>
<span class="line" id="L3254">    <span class="tok-comment">/// The specified pixel format is invalid.</span></span>
<span class="line" id="L3255">    GRAPHICS_INVALID_PIXELFORMAT = <span class="tok-number">0xC01E033D</span>,</span>
<span class="line" id="L3256">    <span class="tok-comment">/// The specified color basis is invalid.</span></span>
<span class="line" id="L3257">    GRAPHICS_INVALID_COLORBASIS = <span class="tok-number">0xC01E033E</span>,</span>
<span class="line" id="L3258">    <span class="tok-comment">/// The specified pixel value access mode is invalid.</span></span>
<span class="line" id="L3259">    GRAPHICS_INVALID_PIXELVALUEACCESSMODE = <span class="tok-number">0xC01E033F</span>,</span>
<span class="line" id="L3260">    <span class="tok-comment">/// The specified target is not part of the specified VidPN's topology.</span></span>
<span class="line" id="L3261">    GRAPHICS_TARGET_NOT_IN_TOPOLOGY = <span class="tok-number">0xC01E0340</span>,</span>
<span class="line" id="L3262">    <span class="tok-comment">/// Failed to acquire the display mode management interface.</span></span>
<span class="line" id="L3263">    GRAPHICS_NO_DISPLAY_MODE_MANAGEMENT_SUPPORT = <span class="tok-number">0xC01E0341</span>,</span>
<span class="line" id="L3264">    <span class="tok-comment">/// The specified VidPN source is already owned by a DMM client and cannot be used until that client releases it.</span></span>
<span class="line" id="L3265">    GRAPHICS_VIDPN_SOURCE_IN_USE = <span class="tok-number">0xC01E0342</span>,</span>
<span class="line" id="L3266">    <span class="tok-comment">/// The specified VidPN is active and cannot be accessed.</span></span>
<span class="line" id="L3267">    GRAPHICS_CANT_ACCESS_ACTIVE_VIDPN = <span class="tok-number">0xC01E0343</span>,</span>
<span class="line" id="L3268">    <span class="tok-comment">/// The specified VidPN's present path importance ordinal is invalid.</span></span>
<span class="line" id="L3269">    GRAPHICS_INVALID_PATH_IMPORTANCE_ORDINAL = <span class="tok-number">0xC01E0344</span>,</span>
<span class="line" id="L3270">    <span class="tok-comment">/// The specified VidPN's present path content geometry transformation is invalid.</span></span>
<span class="line" id="L3271">    GRAPHICS_INVALID_PATH_CONTENT_GEOMETRY_TRANSFORMATION = <span class="tok-number">0xC01E0345</span>,</span>
<span class="line" id="L3272">    <span class="tok-comment">/// The specified content geometry transformation is not supported on the respective VidPN present path.</span></span>
<span class="line" id="L3273">    GRAPHICS_PATH_CONTENT_GEOMETRY_TRANSFORMATION_NOT_SUPPORTED = <span class="tok-number">0xC01E0346</span>,</span>
<span class="line" id="L3274">    <span class="tok-comment">/// The specified gamma ramp is invalid.</span></span>
<span class="line" id="L3275">    GRAPHICS_INVALID_GAMMA_RAMP = <span class="tok-number">0xC01E0347</span>,</span>
<span class="line" id="L3276">    <span class="tok-comment">/// The specified gamma ramp is not supported on the respective VidPN present path.</span></span>
<span class="line" id="L3277">    GRAPHICS_GAMMA_RAMP_NOT_SUPPORTED = <span class="tok-number">0xC01E0348</span>,</span>
<span class="line" id="L3278">    <span class="tok-comment">/// Multisampling is not supported on the respective VidPN present path.</span></span>
<span class="line" id="L3279">    GRAPHICS_MULTISAMPLING_NOT_SUPPORTED = <span class="tok-number">0xC01E0349</span>,</span>
<span class="line" id="L3280">    <span class="tok-comment">/// The specified mode is not in the specified mode set.</span></span>
<span class="line" id="L3281">    GRAPHICS_MODE_NOT_IN_MODESET = <span class="tok-number">0xC01E034A</span>,</span>
<span class="line" id="L3282">    <span class="tok-comment">/// The specified VidPN topology recommendation reason is invalid.</span></span>
<span class="line" id="L3283">    GRAPHICS_INVALID_VIDPN_TOPOLOGY_RECOMMENDATION_REASON = <span class="tok-number">0xC01E034D</span>,</span>
<span class="line" id="L3284">    <span class="tok-comment">/// The specified VidPN present path content type is invalid.</span></span>
<span class="line" id="L3285">    GRAPHICS_INVALID_PATH_CONTENT_TYPE = <span class="tok-number">0xC01E034E</span>,</span>
<span class="line" id="L3286">    <span class="tok-comment">/// The specified VidPN present path copy protection type is invalid.</span></span>
<span class="line" id="L3287">    GRAPHICS_INVALID_COPYPROTECTION_TYPE = <span class="tok-number">0xC01E034F</span>,</span>
<span class="line" id="L3288">    <span class="tok-comment">/// Only one unassigned mode set can exist at any one time for a particular VidPN source or target.</span></span>
<span class="line" id="L3289">    GRAPHICS_UNASSIGNED_MODESET_ALREADY_EXISTS = <span class="tok-number">0xC01E0350</span>,</span>
<span class="line" id="L3290">    <span class="tok-comment">/// The specified scan line ordering type is invalid.</span></span>
<span class="line" id="L3291">    GRAPHICS_INVALID_SCANLINE_ORDERING = <span class="tok-number">0xC01E0352</span>,</span>
<span class="line" id="L3292">    <span class="tok-comment">/// The topology changes are not allowed for the specified VidPN.</span></span>
<span class="line" id="L3293">    GRAPHICS_TOPOLOGY_CHANGES_NOT_ALLOWED = <span class="tok-number">0xC01E0353</span>,</span>
<span class="line" id="L3294">    <span class="tok-comment">/// All available importance ordinals are being used in the specified topology.</span></span>
<span class="line" id="L3295">    GRAPHICS_NO_AVAILABLE_IMPORTANCE_ORDINALS = <span class="tok-number">0xC01E0354</span>,</span>
<span class="line" id="L3296">    <span class="tok-comment">/// The specified primary surface has a different private-format attribute than the current primary surface.</span></span>
<span class="line" id="L3297">    GRAPHICS_INCOMPATIBLE_PRIVATE_FORMAT = <span class="tok-number">0xC01E0355</span>,</span>
<span class="line" id="L3298">    <span class="tok-comment">/// The specified mode-pruning algorithm is invalid.</span></span>
<span class="line" id="L3299">    GRAPHICS_INVALID_MODE_PRUNING_ALGORITHM = <span class="tok-number">0xC01E0356</span>,</span>
<span class="line" id="L3300">    <span class="tok-comment">/// The specified monitor-capability origin is invalid.</span></span>
<span class="line" id="L3301">    GRAPHICS_INVALID_MONITOR_CAPABILITY_ORIGIN = <span class="tok-number">0xC01E0357</span>,</span>
<span class="line" id="L3302">    <span class="tok-comment">/// The specified monitor-frequency range constraint is invalid.</span></span>
<span class="line" id="L3303">    GRAPHICS_INVALID_MONITOR_FREQUENCYRANGE_CONSTRAINT = <span class="tok-number">0xC01E0358</span>,</span>
<span class="line" id="L3304">    <span class="tok-comment">/// The maximum supported number of present paths has been reached.</span></span>
<span class="line" id="L3305">    GRAPHICS_MAX_NUM_PATHS_REACHED = <span class="tok-number">0xC01E0359</span>,</span>
<span class="line" id="L3306">    <span class="tok-comment">/// The miniport requested that augmentation be canceled for the specified source of the specified VidPN's topology.</span></span>
<span class="line" id="L3307">    GRAPHICS_CANCEL_VIDPN_TOPOLOGY_AUGMENTATION = <span class="tok-number">0xC01E035A</span>,</span>
<span class="line" id="L3308">    <span class="tok-comment">/// The specified client type was not recognized.</span></span>
<span class="line" id="L3309">    GRAPHICS_INVALID_CLIENT_TYPE = <span class="tok-number">0xC01E035B</span>,</span>
<span class="line" id="L3310">    <span class="tok-comment">/// The client VidPN is not set on this adapter (for example, no user mode-initiated mode changes have taken place on this adapter).</span></span>
<span class="line" id="L3311">    GRAPHICS_CLIENTVIDPN_NOT_SET = <span class="tok-number">0xC01E035C</span>,</span>
<span class="line" id="L3312">    <span class="tok-comment">/// The specified display adapter child device already has an external device connected to it.</span></span>
<span class="line" id="L3313">    GRAPHICS_SPECIFIED_CHILD_ALREADY_CONNECTED = <span class="tok-number">0xC01E0400</span>,</span>
<span class="line" id="L3314">    <span class="tok-comment">/// The display adapter child device does not support reporting a descriptor.</span></span>
<span class="line" id="L3315">    GRAPHICS_CHILD_DESCRIPTOR_NOT_SUPPORTED = <span class="tok-number">0xC01E0401</span>,</span>
<span class="line" id="L3316">    <span class="tok-comment">/// The display adapter is not linked to any other adapters.</span></span>
<span class="line" id="L3317">    GRAPHICS_NOT_A_LINKED_ADAPTER = <span class="tok-number">0xC01E0430</span>,</span>
<span class="line" id="L3318">    <span class="tok-comment">/// The lead adapter in a linked configuration was not enumerated yet.</span></span>
<span class="line" id="L3319">    GRAPHICS_LEADLINK_NOT_ENUMERATED = <span class="tok-number">0xC01E0431</span>,</span>
<span class="line" id="L3320">    <span class="tok-comment">/// Some chain adapters in a linked configuration have not yet been enumerated.</span></span>
<span class="line" id="L3321">    GRAPHICS_CHAINLINKS_NOT_ENUMERATED = <span class="tok-number">0xC01E0432</span>,</span>
<span class="line" id="L3322">    <span class="tok-comment">/// The chain of linked adapters is not ready to start because of an unknown failure.</span></span>
<span class="line" id="L3323">    GRAPHICS_ADAPTER_CHAIN_NOT_READY = <span class="tok-number">0xC01E0433</span>,</span>
<span class="line" id="L3324">    <span class="tok-comment">/// An attempt was made to start a lead link display adapter when the chain links had not yet started.</span></span>
<span class="line" id="L3325">    GRAPHICS_CHAINLINKS_NOT_STARTED = <span class="tok-number">0xC01E0434</span>,</span>
<span class="line" id="L3326">    <span class="tok-comment">/// An attempt was made to turn on a lead link display adapter when the chain links were turned off.</span></span>
<span class="line" id="L3327">    GRAPHICS_CHAINLINKS_NOT_POWERED_ON = <span class="tok-number">0xC01E0435</span>,</span>
<span class="line" id="L3328">    <span class="tok-comment">/// The adapter link was found in an inconsistent state.</span></span>
<span class="line" id="L3329">    <span class="tok-comment">/// Not all adapters are in an expected PNP/power state.</span></span>
<span class="line" id="L3330">    GRAPHICS_INCONSISTENT_DEVICE_LINK_STATE = <span class="tok-number">0xC01E0436</span>,</span>
<span class="line" id="L3331">    <span class="tok-comment">/// The driver trying to start is not the same as the driver for the posted display adapter.</span></span>
<span class="line" id="L3332">    GRAPHICS_NOT_POST_DEVICE_DRIVER = <span class="tok-number">0xC01E0438</span>,</span>
<span class="line" id="L3333">    <span class="tok-comment">/// An operation is being attempted that requires the display adapter to be in a quiescent state.</span></span>
<span class="line" id="L3334">    GRAPHICS_ADAPTER_ACCESS_NOT_EXCLUDED = <span class="tok-number">0xC01E043B</span>,</span>
<span class="line" id="L3335">    <span class="tok-comment">/// The driver does not support OPM.</span></span>
<span class="line" id="L3336">    GRAPHICS_OPM_NOT_SUPPORTED = <span class="tok-number">0xC01E0500</span>,</span>
<span class="line" id="L3337">    <span class="tok-comment">/// The driver does not support COPP.</span></span>
<span class="line" id="L3338">    GRAPHICS_COPP_NOT_SUPPORTED = <span class="tok-number">0xC01E0501</span>,</span>
<span class="line" id="L3339">    <span class="tok-comment">/// The driver does not support UAB.</span></span>
<span class="line" id="L3340">    GRAPHICS_UAB_NOT_SUPPORTED = <span class="tok-number">0xC01E0502</span>,</span>
<span class="line" id="L3341">    <span class="tok-comment">/// The specified encrypted parameters are invalid.</span></span>
<span class="line" id="L3342">    GRAPHICS_OPM_INVALID_ENCRYPTED_PARAMETERS = <span class="tok-number">0xC01E0503</span>,</span>
<span class="line" id="L3343">    <span class="tok-comment">/// An array passed to a function cannot hold all of the data that the function wants to put in it.</span></span>
<span class="line" id="L3344">    GRAPHICS_OPM_PARAMETER_ARRAY_TOO_SMALL = <span class="tok-number">0xC01E0504</span>,</span>
<span class="line" id="L3345">    <span class="tok-comment">/// The GDI display device passed to this function does not have any active protected outputs.</span></span>
<span class="line" id="L3346">    GRAPHICS_OPM_NO_PROTECTED_OUTPUTS_EXIST = <span class="tok-number">0xC01E0505</span>,</span>
<span class="line" id="L3347">    <span class="tok-comment">/// The PVP cannot find an actual GDI display device that corresponds to the passed-in GDI display device name.</span></span>
<span class="line" id="L3348">    GRAPHICS_PVP_NO_DISPLAY_DEVICE_CORRESPONDS_TO_NAME = <span class="tok-number">0xC01E0506</span>,</span>
<span class="line" id="L3349">    <span class="tok-comment">/// This function failed because the GDI display device passed to it was not attached to the Windows desktop.</span></span>
<span class="line" id="L3350">    GRAPHICS_PVP_DISPLAY_DEVICE_NOT_ATTACHED_TO_DESKTOP = <span class="tok-number">0xC01E0507</span>,</span>
<span class="line" id="L3351">    <span class="tok-comment">/// The PVP does not support mirroring display devices because they do not have any protected outputs.</span></span>
<span class="line" id="L3352">    GRAPHICS_PVP_MIRRORING_DEVICES_NOT_SUPPORTED = <span class="tok-number">0xC01E0508</span>,</span>
<span class="line" id="L3353">    <span class="tok-comment">/// The function failed because an invalid pointer parameter was passed to it.</span></span>
<span class="line" id="L3354">    <span class="tok-comment">/// A pointer parameter is invalid if it is null, is not correctly aligned, or it points to an invalid address or a kernel mode address.</span></span>
<span class="line" id="L3355">    GRAPHICS_OPM_INVALID_POINTER = <span class="tok-number">0xC01E050A</span>,</span>
<span class="line" id="L3356">    <span class="tok-comment">/// An internal error caused an operation to fail.</span></span>
<span class="line" id="L3357">    GRAPHICS_OPM_INTERNAL_ERROR = <span class="tok-number">0xC01E050B</span>,</span>
<span class="line" id="L3358">    <span class="tok-comment">/// The function failed because the caller passed in an invalid OPM user-mode handle.</span></span>
<span class="line" id="L3359">    GRAPHICS_OPM_INVALID_HANDLE = <span class="tok-number">0xC01E050C</span>,</span>
<span class="line" id="L3360">    <span class="tok-comment">/// This function failed because the GDI device passed to it did not have any monitors associated with it.</span></span>
<span class="line" id="L3361">    GRAPHICS_PVP_NO_MONITORS_CORRESPOND_TO_DISPLAY_DEVICE = <span class="tok-number">0xC01E050D</span>,</span>
<span class="line" id="L3362">    <span class="tok-comment">/// A certificate could not be returned because the certificate buffer passed to the function was too small.</span></span>
<span class="line" id="L3363">    GRAPHICS_PVP_INVALID_CERTIFICATE_LENGTH = <span class="tok-number">0xC01E050E</span>,</span>
<span class="line" id="L3364">    <span class="tok-comment">/// DxgkDdiOpmCreateProtectedOutput() could not create a protected output because the video present yarget is in spanning mode.</span></span>
<span class="line" id="L3365">    GRAPHICS_OPM_SPANNING_MODE_ENABLED = <span class="tok-number">0xC01E050F</span>,</span>
<span class="line" id="L3366">    <span class="tok-comment">/// DxgkDdiOpmCreateProtectedOutput() could not create a protected output because the video present target is in theater mode.</span></span>
<span class="line" id="L3367">    GRAPHICS_OPM_THEATER_MODE_ENABLED = <span class="tok-number">0xC01E0510</span>,</span>
<span class="line" id="L3368">    <span class="tok-comment">/// The function call failed because the display adapter's hardware functionality scan (HFS) failed to validate the graphics hardware.</span></span>
<span class="line" id="L3369">    GRAPHICS_PVP_HFS_FAILED = <span class="tok-number">0xC01E0511</span>,</span>
<span class="line" id="L3370">    <span class="tok-comment">/// The HDCP SRM passed to this function did not comply with section 5 of the HDCP 1.1 specification.</span></span>
<span class="line" id="L3371">    GRAPHICS_OPM_INVALID_SRM = <span class="tok-number">0xC01E0512</span>,</span>
<span class="line" id="L3372">    <span class="tok-comment">/// The protected output cannot enable the HDCP system because it does not support it.</span></span>
<span class="line" id="L3373">    GRAPHICS_OPM_OUTPUT_DOES_NOT_SUPPORT_HDCP = <span class="tok-number">0xC01E0513</span>,</span>
<span class="line" id="L3374">    <span class="tok-comment">/// The protected output cannot enable analog copy protection because it does not support it.</span></span>
<span class="line" id="L3375">    GRAPHICS_OPM_OUTPUT_DOES_NOT_SUPPORT_ACP = <span class="tok-number">0xC01E0514</span>,</span>
<span class="line" id="L3376">    <span class="tok-comment">/// The protected output cannot enable the CGMS-A protection technology because it does not support it.</span></span>
<span class="line" id="L3377">    GRAPHICS_OPM_OUTPUT_DOES_NOT_SUPPORT_CGMSA = <span class="tok-number">0xC01E0515</span>,</span>
<span class="line" id="L3378">    <span class="tok-comment">/// DxgkDdiOPMGetInformation() cannot return the version of the SRM being used because the application never successfully passed an SRM to the protected output.</span></span>
<span class="line" id="L3379">    GRAPHICS_OPM_HDCP_SRM_NEVER_SET = <span class="tok-number">0xC01E0516</span>,</span>
<span class="line" id="L3380">    <span class="tok-comment">/// DxgkDdiOPMConfigureProtectedOutput() cannot enable the specified output protection technology because the output's screen resolution is too high.</span></span>
<span class="line" id="L3381">    GRAPHICS_OPM_RESOLUTION_TOO_HIGH = <span class="tok-number">0xC01E0517</span>,</span>
<span class="line" id="L3382">    <span class="tok-comment">/// DxgkDdiOPMConfigureProtectedOutput() cannot enable HDCP because other physical outputs are using the display adapter's HDCP hardware.</span></span>
<span class="line" id="L3383">    GRAPHICS_OPM_ALL_HDCP_HARDWARE_ALREADY_IN_USE = <span class="tok-number">0xC01E0518</span>,</span>
<span class="line" id="L3384">    <span class="tok-comment">/// The operating system asynchronously destroyed this OPM-protected output because the operating system state changed.</span></span>
<span class="line" id="L3385">    <span class="tok-comment">/// This error typically occurs because the monitor PDO associated with this protected output was removed or stopped, the protected output's session became a nonconsole session, or the protected output's desktop became inactive.</span></span>
<span class="line" id="L3386">    GRAPHICS_OPM_PROTECTED_OUTPUT_NO_LONGER_EXISTS = <span class="tok-number">0xC01E051A</span>,</span>
<span class="line" id="L3387">    <span class="tok-comment">/// OPM functions cannot be called when a session is changing its type.</span></span>
<span class="line" id="L3388">    <span class="tok-comment">/// Three types of sessions currently exist: console, disconnected, and remote (RDP or ICA).</span></span>
<span class="line" id="L3389">    GRAPHICS_OPM_SESSION_TYPE_CHANGE_IN_PROGRESS = <span class="tok-number">0xC01E051B</span>,</span>
<span class="line" id="L3390">    <span class="tok-comment">/// The DxgkDdiOPMGetCOPPCompatibleInformation, DxgkDdiOPMGetInformation, or DxgkDdiOPMConfigureProtectedOutput function failed.</span></span>
<span class="line" id="L3391">    <span class="tok-comment">/// This error is returned only if a protected output has OPM semantics.</span></span>
<span class="line" id="L3392">    <span class="tok-comment">/// DxgkDdiOPMGetCOPPCompatibleInformation always returns this error if a protected output has OPM semantics.</span></span>
<span class="line" id="L3393">    <span class="tok-comment">/// DxgkDdiOPMGetInformation returns this error code if the caller requested COPP-specific information.</span></span>
<span class="line" id="L3394">    <span class="tok-comment">/// DxgkDdiOPMConfigureProtectedOutput returns this error when the caller tries to use a COPP-specific command.</span></span>
<span class="line" id="L3395">    GRAPHICS_OPM_PROTECTED_OUTPUT_DOES_NOT_HAVE_COPP_SEMANTICS = <span class="tok-number">0xC01E051C</span>,</span>
<span class="line" id="L3396">    <span class="tok-comment">/// The DxgkDdiOPMGetInformation and DxgkDdiOPMGetCOPPCompatibleInformation functions return this error code if the passed-in sequence number is not the expected sequence number or the passed-in OMAC value is invalid.</span></span>
<span class="line" id="L3397">    GRAPHICS_OPM_INVALID_INFORMATION_REQUEST = <span class="tok-number">0xC01E051D</span>,</span>
<span class="line" id="L3398">    <span class="tok-comment">/// The function failed because an unexpected error occurred inside a display driver.</span></span>
<span class="line" id="L3399">    GRAPHICS_OPM_DRIVER_INTERNAL_ERROR = <span class="tok-number">0xC01E051E</span>,</span>
<span class="line" id="L3400">    <span class="tok-comment">/// The DxgkDdiOPMGetCOPPCompatibleInformation, DxgkDdiOPMGetInformation, or DxgkDdiOPMConfigureProtectedOutput function failed.</span></span>
<span class="line" id="L3401">    <span class="tok-comment">/// This error is returned only if a protected output has COPP semantics.</span></span>
<span class="line" id="L3402">    <span class="tok-comment">/// DxgkDdiOPMGetCOPPCompatibleInformation returns this error code if the caller requested OPM-specific information.</span></span>
<span class="line" id="L3403">    <span class="tok-comment">/// DxgkDdiOPMGetInformation always returns this error if a protected output has COPP semantics.</span></span>
<span class="line" id="L3404">    <span class="tok-comment">/// DxgkDdiOPMConfigureProtectedOutput returns this error when the caller tries to use an OPM-specific command.</span></span>
<span class="line" id="L3405">    GRAPHICS_OPM_PROTECTED_OUTPUT_DOES_NOT_HAVE_OPM_SEMANTICS = <span class="tok-number">0xC01E051F</span>,</span>
<span class="line" id="L3406">    <span class="tok-comment">/// The DxgkDdiOPMGetCOPPCompatibleInformation and DxgkDdiOPMConfigureProtectedOutput functions return this error if the display driver does not support the DXGKMDT_OPM_GET_ACP_AND_CGMSA_SIGNALING and DXGKMDT_OPM_SET_ACP_AND_CGMSA_SIGNALING GUIDs.</span></span>
<span class="line" id="L3407">    GRAPHICS_OPM_SIGNALING_NOT_SUPPORTED = <span class="tok-number">0xC01E0520</span>,</span>
<span class="line" id="L3408">    <span class="tok-comment">/// The DxgkDdiOPMConfigureProtectedOutput function returns this error code if the passed-in sequence number is not the expected sequence number or the passed-in OMAC value is invalid.</span></span>
<span class="line" id="L3409">    GRAPHICS_OPM_INVALID_CONFIGURATION_REQUEST = <span class="tok-number">0xC01E0521</span>,</span>
<span class="line" id="L3410">    <span class="tok-comment">/// The monitor connected to the specified video output does not have an I2C bus.</span></span>
<span class="line" id="L3411">    GRAPHICS_I2C_NOT_SUPPORTED = <span class="tok-number">0xC01E0580</span>,</span>
<span class="line" id="L3412">    <span class="tok-comment">/// No device on the I2C bus has the specified address.</span></span>
<span class="line" id="L3413">    GRAPHICS_I2C_DEVICE_DOES_NOT_EXIST = <span class="tok-number">0xC01E0581</span>,</span>
<span class="line" id="L3414">    <span class="tok-comment">/// An error occurred while transmitting data to the device on the I2C bus.</span></span>
<span class="line" id="L3415">    GRAPHICS_I2C_ERROR_TRANSMITTING_DATA = <span class="tok-number">0xC01E0582</span>,</span>
<span class="line" id="L3416">    <span class="tok-comment">/// An error occurred while receiving data from the device on the I2C bus.</span></span>
<span class="line" id="L3417">    GRAPHICS_I2C_ERROR_RECEIVING_DATA = <span class="tok-number">0xC01E0583</span>,</span>
<span class="line" id="L3418">    <span class="tok-comment">/// The monitor does not support the specified VCP code.</span></span>
<span class="line" id="L3419">    GRAPHICS_DDCCI_VCP_NOT_SUPPORTED = <span class="tok-number">0xC01E0584</span>,</span>
<span class="line" id="L3420">    <span class="tok-comment">/// The data received from the monitor is invalid.</span></span>
<span class="line" id="L3421">    GRAPHICS_DDCCI_INVALID_DATA = <span class="tok-number">0xC01E0585</span>,</span>
<span class="line" id="L3422">    <span class="tok-comment">/// A function call failed because a monitor returned an invalid timing status byte when the operating system used the DDC/CI get timing report and timing message command to get a timing report from a monitor.</span></span>
<span class="line" id="L3423">    GRAPHICS_DDCCI_MONITOR_RETURNED_INVALID_TIMING_STATUS_BYTE = <span class="tok-number">0xC01E0586</span>,</span>
<span class="line" id="L3424">    <span class="tok-comment">/// A monitor returned a DDC/CI capabilities string that did not comply with the ACCESS.bus 3.0, DDC/CI 1.1, or MCCS 2 Revision 1 specification.</span></span>
<span class="line" id="L3425">    GRAPHICS_DDCCI_INVALID_CAPABILITIES_STRING = <span class="tok-number">0xC01E0587</span>,</span>
<span class="line" id="L3426">    <span class="tok-comment">/// An internal error caused an operation to fail.</span></span>
<span class="line" id="L3427">    GRAPHICS_MCA_INTERNAL_ERROR = <span class="tok-number">0xC01E0588</span>,</span>
<span class="line" id="L3428">    <span class="tok-comment">/// An operation failed because a DDC/CI message had an invalid value in its command field.</span></span>
<span class="line" id="L3429">    GRAPHICS_DDCCI_INVALID_MESSAGE_COMMAND = <span class="tok-number">0xC01E0589</span>,</span>
<span class="line" id="L3430">    <span class="tok-comment">/// This error occurred because a DDC/CI message had an invalid value in its length field.</span></span>
<span class="line" id="L3431">    GRAPHICS_DDCCI_INVALID_MESSAGE_LENGTH = <span class="tok-number">0xC01E058A</span>,</span>
<span class="line" id="L3432">    <span class="tok-comment">/// This error occurred because the value in a DDC/CI message's checksum field did not match the message's computed checksum value.</span></span>
<span class="line" id="L3433">    <span class="tok-comment">/// This error implies that the data was corrupted while it was being transmitted from a monitor to a computer.</span></span>
<span class="line" id="L3434">    GRAPHICS_DDCCI_INVALID_MESSAGE_CHECKSUM = <span class="tok-number">0xC01E058B</span>,</span>
<span class="line" id="L3435">    <span class="tok-comment">/// This function failed because an invalid monitor handle was passed to it.</span></span>
<span class="line" id="L3436">    GRAPHICS_INVALID_PHYSICAL_MONITOR_HANDLE = <span class="tok-number">0xC01E058C</span>,</span>
<span class="line" id="L3437">    <span class="tok-comment">/// The operating system asynchronously destroyed the monitor that corresponds to this handle because the operating system's state changed.</span></span>
<span class="line" id="L3438">    <span class="tok-comment">/// This error typically occurs because the monitor PDO associated with this handle was removed or stopped, or a display mode change occurred.</span></span>
<span class="line" id="L3439">    <span class="tok-comment">/// A display mode change occurs when Windows sends a WM_DISPLAYCHANGE message to applications.</span></span>
<span class="line" id="L3440">    GRAPHICS_MONITOR_NO_LONGER_EXISTS = <span class="tok-number">0xC01E058D</span>,</span>
<span class="line" id="L3441">    <span class="tok-comment">/// This function can be used only if a program is running in the local console session.</span></span>
<span class="line" id="L3442">    <span class="tok-comment">/// It cannot be used if a program is running on a remote desktop session or on a terminal server session.</span></span>
<span class="line" id="L3443">    GRAPHICS_ONLY_CONSOLE_SESSION_SUPPORTED = <span class="tok-number">0xC01E05E0</span>,</span>
<span class="line" id="L3444">    <span class="tok-comment">/// This function cannot find an actual GDI display device that corresponds to the specified GDI display device name.</span></span>
<span class="line" id="L3445">    GRAPHICS_NO_DISPLAY_DEVICE_CORRESPONDS_TO_NAME = <span class="tok-number">0xC01E05E1</span>,</span>
<span class="line" id="L3446">    <span class="tok-comment">/// The function failed because the specified GDI display device was not attached to the Windows desktop.</span></span>
<span class="line" id="L3447">    GRAPHICS_DISPLAY_DEVICE_NOT_ATTACHED_TO_DESKTOP = <span class="tok-number">0xC01E05E2</span>,</span>
<span class="line" id="L3448">    <span class="tok-comment">/// This function does not support GDI mirroring display devices because GDI mirroring display devices do not have any physical monitors associated with them.</span></span>
<span class="line" id="L3449">    GRAPHICS_MIRRORING_DEVICES_NOT_SUPPORTED = <span class="tok-number">0xC01E05E3</span>,</span>
<span class="line" id="L3450">    <span class="tok-comment">/// The function failed because an invalid pointer parameter was passed to it.</span></span>
<span class="line" id="L3451">    <span class="tok-comment">/// A pointer parameter is invalid if it is null, is not correctly aligned, or points to an invalid address or to a kernel mode address.</span></span>
<span class="line" id="L3452">    GRAPHICS_INVALID_POINTER = <span class="tok-number">0xC01E05E4</span>,</span>
<span class="line" id="L3453">    <span class="tok-comment">/// This function failed because the GDI device passed to it did not have a monitor associated with it.</span></span>
<span class="line" id="L3454">    GRAPHICS_NO_MONITORS_CORRESPOND_TO_DISPLAY_DEVICE = <span class="tok-number">0xC01E05E5</span>,</span>
<span class="line" id="L3455">    <span class="tok-comment">/// An array passed to the function cannot hold all of the data that the function must copy into the array.</span></span>
<span class="line" id="L3456">    GRAPHICS_PARAMETER_ARRAY_TOO_SMALL = <span class="tok-number">0xC01E05E6</span>,</span>
<span class="line" id="L3457">    <span class="tok-comment">/// An internal error caused an operation to fail.</span></span>
<span class="line" id="L3458">    GRAPHICS_INTERNAL_ERROR = <span class="tok-number">0xC01E05E7</span>,</span>
<span class="line" id="L3459">    <span class="tok-comment">/// The function failed because the current session is changing its type.</span></span>
<span class="line" id="L3460">    <span class="tok-comment">/// This function cannot be called when the current session is changing its type.</span></span>
<span class="line" id="L3461">    <span class="tok-comment">/// Three types of sessions currently exist: console, disconnected, and remote (RDP or ICA).</span></span>
<span class="line" id="L3462">    GRAPHICS_SESSION_TYPE_CHANGE_IN_PROGRESS = <span class="tok-number">0xC01E05E8</span>,</span>
<span class="line" id="L3463">    <span class="tok-comment">/// The volume must be unlocked before it can be used.</span></span>
<span class="line" id="L3464">    FVE_LOCKED_VOLUME = <span class="tok-number">0xC0210000</span>,</span>
<span class="line" id="L3465">    <span class="tok-comment">/// The volume is fully decrypted and no key is available.</span></span>
<span class="line" id="L3466">    FVE_NOT_ENCRYPTED = <span class="tok-number">0xC0210001</span>,</span>
<span class="line" id="L3467">    <span class="tok-comment">/// The control block for the encrypted volume is not valid.</span></span>
<span class="line" id="L3468">    FVE_BAD_INFORMATION = <span class="tok-number">0xC0210002</span>,</span>
<span class="line" id="L3469">    <span class="tok-comment">/// Not enough free space remains on the volume to allow encryption.</span></span>
<span class="line" id="L3470">    FVE_TOO_SMALL = <span class="tok-number">0xC0210003</span>,</span>
<span class="line" id="L3471">    <span class="tok-comment">/// The partition cannot be encrypted because the file system is not supported.</span></span>
<span class="line" id="L3472">    FVE_FAILED_WRONG_FS = <span class="tok-number">0xC0210004</span>,</span>
<span class="line" id="L3473">    <span class="tok-comment">/// The file system is inconsistent. Run the Check Disk utility.</span></span>
<span class="line" id="L3474">    FVE_FAILED_BAD_FS = <span class="tok-number">0xC0210005</span>,</span>
<span class="line" id="L3475">    <span class="tok-comment">/// The file system does not extend to the end of the volume.</span></span>
<span class="line" id="L3476">    FVE_FS_NOT_EXTENDED = <span class="tok-number">0xC0210006</span>,</span>
<span class="line" id="L3477">    <span class="tok-comment">/// This operation cannot be performed while a file system is mounted on the volume.</span></span>
<span class="line" id="L3478">    FVE_FS_MOUNTED = <span class="tok-number">0xC0210007</span>,</span>
<span class="line" id="L3479">    <span class="tok-comment">/// BitLocker Drive Encryption is not included with this version of Windows.</span></span>
<span class="line" id="L3480">    FVE_NO_LICENSE = <span class="tok-number">0xC0210008</span>,</span>
<span class="line" id="L3481">    <span class="tok-comment">/// The requested action was denied by the FVE control engine.</span></span>
<span class="line" id="L3482">    FVE_ACTION_NOT_ALLOWED = <span class="tok-number">0xC0210009</span>,</span>
<span class="line" id="L3483">    <span class="tok-comment">/// The data supplied is malformed.</span></span>
<span class="line" id="L3484">    FVE_BAD_DATA = <span class="tok-number">0xC021000A</span>,</span>
<span class="line" id="L3485">    <span class="tok-comment">/// The volume is not bound to the system.</span></span>
<span class="line" id="L3486">    FVE_VOLUME_NOT_BOUND = <span class="tok-number">0xC021000B</span>,</span>
<span class="line" id="L3487">    <span class="tok-comment">/// The volume specified is not a data volume.</span></span>
<span class="line" id="L3488">    FVE_NOT_DATA_VOLUME = <span class="tok-number">0xC021000C</span>,</span>
<span class="line" id="L3489">    <span class="tok-comment">/// A read operation failed while converting the volume.</span></span>
<span class="line" id="L3490">    FVE_CONV_READ_ERROR = <span class="tok-number">0xC021000D</span>,</span>
<span class="line" id="L3491">    <span class="tok-comment">/// A write operation failed while converting the volume.</span></span>
<span class="line" id="L3492">    FVE_CONV_WRITE_ERROR = <span class="tok-number">0xC021000E</span>,</span>
<span class="line" id="L3493">    <span class="tok-comment">/// The control block for the encrypted volume was updated by another thread. Try again.</span></span>
<span class="line" id="L3494">    FVE_OVERLAPPED_UPDATE = <span class="tok-number">0xC021000F</span>,</span>
<span class="line" id="L3495">    <span class="tok-comment">/// The volume encryption algorithm cannot be used on this sector size.</span></span>
<span class="line" id="L3496">    FVE_FAILED_SECTOR_SIZE = <span class="tok-number">0xC0210010</span>,</span>
<span class="line" id="L3497">    <span class="tok-comment">/// BitLocker recovery authentication failed.</span></span>
<span class="line" id="L3498">    FVE_FAILED_AUTHENTICATION = <span class="tok-number">0xC0210011</span>,</span>
<span class="line" id="L3499">    <span class="tok-comment">/// The volume specified is not the boot operating system volume.</span></span>
<span class="line" id="L3500">    FVE_NOT_OS_VOLUME = <span class="tok-number">0xC0210012</span>,</span>
<span class="line" id="L3501">    <span class="tok-comment">/// The BitLocker startup key or recovery password could not be read from external media.</span></span>
<span class="line" id="L3502">    FVE_KEYFILE_NOT_FOUND = <span class="tok-number">0xC0210013</span>,</span>
<span class="line" id="L3503">    <span class="tok-comment">/// The BitLocker startup key or recovery password file is corrupt or invalid.</span></span>
<span class="line" id="L3504">    FVE_KEYFILE_INVALID = <span class="tok-number">0xC0210014</span>,</span>
<span class="line" id="L3505">    <span class="tok-comment">/// The BitLocker encryption key could not be obtained from the startup key or the recovery password.</span></span>
<span class="line" id="L3506">    FVE_KEYFILE_NO_VMK = <span class="tok-number">0xC0210015</span>,</span>
<span class="line" id="L3507">    <span class="tok-comment">/// The TPM is disabled.</span></span>
<span class="line" id="L3508">    FVE_TPM_DISABLED = <span class="tok-number">0xC0210016</span>,</span>
<span class="line" id="L3509">    <span class="tok-comment">/// The authorization data for the SRK of the TPM is not zero.</span></span>
<span class="line" id="L3510">    FVE_TPM_SRK_AUTH_NOT_ZERO = <span class="tok-number">0xC0210017</span>,</span>
<span class="line" id="L3511">    <span class="tok-comment">/// The system boot information changed or the TPM locked out access to BitLocker encryption keys until the computer is restarted.</span></span>
<span class="line" id="L3512">    FVE_TPM_INVALID_PCR = <span class="tok-number">0xC0210018</span>,</span>
<span class="line" id="L3513">    <span class="tok-comment">/// The BitLocker encryption key could not be obtained from the TPM.</span></span>
<span class="line" id="L3514">    FVE_TPM_NO_VMK = <span class="tok-number">0xC0210019</span>,</span>
<span class="line" id="L3515">    <span class="tok-comment">/// The BitLocker encryption key could not be obtained from the TPM and PIN.</span></span>
<span class="line" id="L3516">    FVE_PIN_INVALID = <span class="tok-number">0xC021001A</span>,</span>
<span class="line" id="L3517">    <span class="tok-comment">/// A boot application hash does not match the hash computed when BitLocker was turned on.</span></span>
<span class="line" id="L3518">    FVE_AUTH_INVALID_APPLICATION = <span class="tok-number">0xC021001B</span>,</span>
<span class="line" id="L3519">    <span class="tok-comment">/// The Boot Configuration Data (BCD) settings are not supported or have changed because BitLocker was enabled.</span></span>
<span class="line" id="L3520">    FVE_AUTH_INVALID_CONFIG = <span class="tok-number">0xC021001C</span>,</span>
<span class="line" id="L3521">    <span class="tok-comment">/// Boot debugging is enabled. Run Windows Boot Configuration Data Store Editor (bcdedit.exe) to turn it off.</span></span>
<span class="line" id="L3522">    FVE_DEBUGGER_ENABLED = <span class="tok-number">0xC021001D</span>,</span>
<span class="line" id="L3523">    <span class="tok-comment">/// The BitLocker encryption key could not be obtained.</span></span>
<span class="line" id="L3524">    FVE_DRY_RUN_FAILED = <span class="tok-number">0xC021001E</span>,</span>
<span class="line" id="L3525">    <span class="tok-comment">/// The metadata disk region pointer is incorrect.</span></span>
<span class="line" id="L3526">    FVE_BAD_METADATA_POINTER = <span class="tok-number">0xC021001F</span>,</span>
<span class="line" id="L3527">    <span class="tok-comment">/// The backup copy of the metadata is out of date.</span></span>
<span class="line" id="L3528">    FVE_OLD_METADATA_COPY = <span class="tok-number">0xC0210020</span>,</span>
<span class="line" id="L3529">    <span class="tok-comment">/// No action was taken because a system restart is required.</span></span>
<span class="line" id="L3530">    FVE_REBOOT_REQUIRED = <span class="tok-number">0xC0210021</span>,</span>
<span class="line" id="L3531">    <span class="tok-comment">/// No action was taken because BitLocker Drive Encryption is in RAW access mode.</span></span>
<span class="line" id="L3532">    FVE_RAW_ACCESS = <span class="tok-number">0xC0210022</span>,</span>
<span class="line" id="L3533">    <span class="tok-comment">/// BitLocker Drive Encryption cannot enter RAW access mode for this volume.</span></span>
<span class="line" id="L3534">    FVE_RAW_BLOCKED = <span class="tok-number">0xC0210023</span>,</span>
<span class="line" id="L3535">    <span class="tok-comment">/// This feature of BitLocker Drive Encryption is not included with this version of Windows.</span></span>
<span class="line" id="L3536">    FVE_NO_FEATURE_LICENSE = <span class="tok-number">0xC0210026</span>,</span>
<span class="line" id="L3537">    <span class="tok-comment">/// Group policy does not permit turning off BitLocker Drive Encryption on roaming data volumes.</span></span>
<span class="line" id="L3538">    FVE_POLICY_USER_DISABLE_RDV_NOT_ALLOWED = <span class="tok-number">0xC0210027</span>,</span>
<span class="line" id="L3539">    <span class="tok-comment">/// Bitlocker Drive Encryption failed to recover from aborted conversion.</span></span>
<span class="line" id="L3540">    <span class="tok-comment">/// This could be due to either all conversion logs being corrupted or the media being write-protected.</span></span>
<span class="line" id="L3541">    FVE_CONV_RECOVERY_FAILED = <span class="tok-number">0xC0210028</span>,</span>
<span class="line" id="L3542">    <span class="tok-comment">/// The requested virtualization size is too big.</span></span>
<span class="line" id="L3543">    FVE_VIRTUALIZED_SPACE_TOO_BIG = <span class="tok-number">0xC0210029</span>,</span>
<span class="line" id="L3544">    <span class="tok-comment">/// The drive is too small to be protected using BitLocker Drive Encryption.</span></span>
<span class="line" id="L3545">    FVE_VOLUME_TOO_SMALL = <span class="tok-number">0xC0210030</span>,</span>
<span class="line" id="L3546">    <span class="tok-comment">/// The callout does not exist.</span></span>
<span class="line" id="L3547">    FWP_CALLOUT_NOT_FOUND = <span class="tok-number">0xC0220001</span>,</span>
<span class="line" id="L3548">    <span class="tok-comment">/// The filter condition does not exist.</span></span>
<span class="line" id="L3549">    FWP_CONDITION_NOT_FOUND = <span class="tok-number">0xC0220002</span>,</span>
<span class="line" id="L3550">    <span class="tok-comment">/// The filter does not exist.</span></span>
<span class="line" id="L3551">    FWP_FILTER_NOT_FOUND = <span class="tok-number">0xC0220003</span>,</span>
<span class="line" id="L3552">    <span class="tok-comment">/// The layer does not exist.</span></span>
<span class="line" id="L3553">    FWP_LAYER_NOT_FOUND = <span class="tok-number">0xC0220004</span>,</span>
<span class="line" id="L3554">    <span class="tok-comment">/// The provider does not exist.</span></span>
<span class="line" id="L3555">    FWP_PROVIDER_NOT_FOUND = <span class="tok-number">0xC0220005</span>,</span>
<span class="line" id="L3556">    <span class="tok-comment">/// The provider context does not exist.</span></span>
<span class="line" id="L3557">    FWP_PROVIDER_CONTEXT_NOT_FOUND = <span class="tok-number">0xC0220006</span>,</span>
<span class="line" id="L3558">    <span class="tok-comment">/// The sublayer does not exist.</span></span>
<span class="line" id="L3559">    FWP_SUBLAYER_NOT_FOUND = <span class="tok-number">0xC0220007</span>,</span>
<span class="line" id="L3560">    <span class="tok-comment">/// The object does not exist.</span></span>
<span class="line" id="L3561">    FWP_NOT_FOUND = <span class="tok-number">0xC0220008</span>,</span>
<span class="line" id="L3562">    <span class="tok-comment">/// An object with that GUID or LUID already exists.</span></span>
<span class="line" id="L3563">    FWP_ALREADY_EXISTS = <span class="tok-number">0xC0220009</span>,</span>
<span class="line" id="L3564">    <span class="tok-comment">/// The object is referenced by other objects and cannot be deleted.</span></span>
<span class="line" id="L3565">    FWP_IN_USE = <span class="tok-number">0xC022000A</span>,</span>
<span class="line" id="L3566">    <span class="tok-comment">/// The call is not allowed from within a dynamic session.</span></span>
<span class="line" id="L3567">    FWP_DYNAMIC_SESSION_IN_PROGRESS = <span class="tok-number">0xC022000B</span>,</span>
<span class="line" id="L3568">    <span class="tok-comment">/// The call was made from the wrong session and cannot be completed.</span></span>
<span class="line" id="L3569">    FWP_WRONG_SESSION = <span class="tok-number">0xC022000C</span>,</span>
<span class="line" id="L3570">    <span class="tok-comment">/// The call must be made from within an explicit transaction.</span></span>
<span class="line" id="L3571">    FWP_NO_TXN_IN_PROGRESS = <span class="tok-number">0xC022000D</span>,</span>
<span class="line" id="L3572">    <span class="tok-comment">/// The call is not allowed from within an explicit transaction.</span></span>
<span class="line" id="L3573">    FWP_TXN_IN_PROGRESS = <span class="tok-number">0xC022000E</span>,</span>
<span class="line" id="L3574">    <span class="tok-comment">/// The explicit transaction has been forcibly canceled.</span></span>
<span class="line" id="L3575">    FWP_TXN_ABORTED = <span class="tok-number">0xC022000F</span>,</span>
<span class="line" id="L3576">    <span class="tok-comment">/// The session has been canceled.</span></span>
<span class="line" id="L3577">    FWP_SESSION_ABORTED = <span class="tok-number">0xC0220010</span>,</span>
<span class="line" id="L3578">    <span class="tok-comment">/// The call is not allowed from within a read-only transaction.</span></span>
<span class="line" id="L3579">    FWP_INCOMPATIBLE_TXN = <span class="tok-number">0xC0220011</span>,</span>
<span class="line" id="L3580">    <span class="tok-comment">/// The call timed out while waiting to acquire the transaction lock.</span></span>
<span class="line" id="L3581">    FWP_TIMEOUT = <span class="tok-number">0xC0220012</span>,</span>
<span class="line" id="L3582">    <span class="tok-comment">/// The collection of network diagnostic events is disabled.</span></span>
<span class="line" id="L3583">    FWP_NET_EVENTS_DISABLED = <span class="tok-number">0xC0220013</span>,</span>
<span class="line" id="L3584">    <span class="tok-comment">/// The operation is not supported by the specified layer.</span></span>
<span class="line" id="L3585">    FWP_INCOMPATIBLE_LAYER = <span class="tok-number">0xC0220014</span>,</span>
<span class="line" id="L3586">    <span class="tok-comment">/// The call is allowed for kernel-mode callers only.</span></span>
<span class="line" id="L3587">    FWP_KM_CLIENTS_ONLY = <span class="tok-number">0xC0220015</span>,</span>
<span class="line" id="L3588">    <span class="tok-comment">/// The call tried to associate two objects with incompatible lifetimes.</span></span>
<span class="line" id="L3589">    FWP_LIFETIME_MISMATCH = <span class="tok-number">0xC0220016</span>,</span>
<span class="line" id="L3590">    <span class="tok-comment">/// The object is built-in and cannot be deleted.</span></span>
<span class="line" id="L3591">    FWP_BUILTIN_OBJECT = <span class="tok-number">0xC0220017</span>,</span>
<span class="line" id="L3592">    <span class="tok-comment">/// The maximum number of callouts has been reached.</span></span>
<span class="line" id="L3593">    FWP_TOO_MANY_CALLOUTS = <span class="tok-number">0xC0220018</span>,</span>
<span class="line" id="L3594">    <span class="tok-comment">/// A notification could not be delivered because a message queue has reached maximum capacity.</span></span>
<span class="line" id="L3595">    FWP_NOTIFICATION_DROPPED = <span class="tok-number">0xC0220019</span>,</span>
<span class="line" id="L3596">    <span class="tok-comment">/// The traffic parameters do not match those for the security association context.</span></span>
<span class="line" id="L3597">    FWP_TRAFFIC_MISMATCH = <span class="tok-number">0xC022001A</span>,</span>
<span class="line" id="L3598">    <span class="tok-comment">/// The call is not allowed for the current security association state.</span></span>
<span class="line" id="L3599">    FWP_INCOMPATIBLE_SA_STATE = <span class="tok-number">0xC022001B</span>,</span>
<span class="line" id="L3600">    <span class="tok-comment">/// A required pointer is null.</span></span>
<span class="line" id="L3601">    FWP_NULL_POINTER = <span class="tok-number">0xC022001C</span>,</span>
<span class="line" id="L3602">    <span class="tok-comment">/// An enumerator is not valid.</span></span>
<span class="line" id="L3603">    FWP_INVALID_ENUMERATOR = <span class="tok-number">0xC022001D</span>,</span>
<span class="line" id="L3604">    <span class="tok-comment">/// The flags field contains an invalid value.</span></span>
<span class="line" id="L3605">    FWP_INVALID_FLAGS = <span class="tok-number">0xC022001E</span>,</span>
<span class="line" id="L3606">    <span class="tok-comment">/// A network mask is not valid.</span></span>
<span class="line" id="L3607">    FWP_INVALID_NET_MASK = <span class="tok-number">0xC022001F</span>,</span>
<span class="line" id="L3608">    <span class="tok-comment">/// An FWP_RANGE is not valid.</span></span>
<span class="line" id="L3609">    FWP_INVALID_RANGE = <span class="tok-number">0xC0220020</span>,</span>
<span class="line" id="L3610">    <span class="tok-comment">/// The time interval is not valid.</span></span>
<span class="line" id="L3611">    FWP_INVALID_INTERVAL = <span class="tok-number">0xC0220021</span>,</span>
<span class="line" id="L3612">    <span class="tok-comment">/// An array that must contain at least one element has a zero length.</span></span>
<span class="line" id="L3613">    FWP_ZERO_LENGTH_ARRAY = <span class="tok-number">0xC0220022</span>,</span>
<span class="line" id="L3614">    <span class="tok-comment">/// The displayData.name field cannot be null.</span></span>
<span class="line" id="L3615">    FWP_NULL_DISPLAY_NAME = <span class="tok-number">0xC0220023</span>,</span>
<span class="line" id="L3616">    <span class="tok-comment">/// The action type is not one of the allowed action types for a filter.</span></span>
<span class="line" id="L3617">    FWP_INVALID_ACTION_TYPE = <span class="tok-number">0xC0220024</span>,</span>
<span class="line" id="L3618">    <span class="tok-comment">/// The filter weight is not valid.</span></span>
<span class="line" id="L3619">    FWP_INVALID_WEIGHT = <span class="tok-number">0xC0220025</span>,</span>
<span class="line" id="L3620">    <span class="tok-comment">/// A filter condition contains a match type that is not compatible with the operands.</span></span>
<span class="line" id="L3621">    FWP_MATCH_TYPE_MISMATCH = <span class="tok-number">0xC0220026</span>,</span>
<span class="line" id="L3622">    <span class="tok-comment">/// An FWP_VALUE or FWPM_CONDITION_VALUE is of the wrong type.</span></span>
<span class="line" id="L3623">    FWP_TYPE_MISMATCH = <span class="tok-number">0xC0220027</span>,</span>
<span class="line" id="L3624">    <span class="tok-comment">/// An integer value is outside the allowed range.</span></span>
<span class="line" id="L3625">    FWP_OUT_OF_BOUNDS = <span class="tok-number">0xC0220028</span>,</span>
<span class="line" id="L3626">    <span class="tok-comment">/// A reserved field is nonzero.</span></span>
<span class="line" id="L3627">    FWP_RESERVED = <span class="tok-number">0xC0220029</span>,</span>
<span class="line" id="L3628">    <span class="tok-comment">/// A filter cannot contain multiple conditions operating on a single field.</span></span>
<span class="line" id="L3629">    FWP_DUPLICATE_CONDITION = <span class="tok-number">0xC022002A</span>,</span>
<span class="line" id="L3630">    <span class="tok-comment">/// A policy cannot contain the same keying module more than once.</span></span>
<span class="line" id="L3631">    FWP_DUPLICATE_KEYMOD = <span class="tok-number">0xC022002B</span>,</span>
<span class="line" id="L3632">    <span class="tok-comment">/// The action type is not compatible with the layer.</span></span>
<span class="line" id="L3633">    FWP_ACTION_INCOMPATIBLE_WITH_LAYER = <span class="tok-number">0xC022002C</span>,</span>
<span class="line" id="L3634">    <span class="tok-comment">/// The action type is not compatible with the sublayer.</span></span>
<span class="line" id="L3635">    FWP_ACTION_INCOMPATIBLE_WITH_SUBLAYER = <span class="tok-number">0xC022002D</span>,</span>
<span class="line" id="L3636">    <span class="tok-comment">/// The raw context or the provider context is not compatible with the layer.</span></span>
<span class="line" id="L3637">    FWP_CONTEXT_INCOMPATIBLE_WITH_LAYER = <span class="tok-number">0xC022002E</span>,</span>
<span class="line" id="L3638">    <span class="tok-comment">/// The raw context or the provider context is not compatible with the callout.</span></span>
<span class="line" id="L3639">    FWP_CONTEXT_INCOMPATIBLE_WITH_CALLOUT = <span class="tok-number">0xC022002F</span>,</span>
<span class="line" id="L3640">    <span class="tok-comment">/// The authentication method is not compatible with the policy type.</span></span>
<span class="line" id="L3641">    FWP_INCOMPATIBLE_AUTH_METHOD = <span class="tok-number">0xC0220030</span>,</span>
<span class="line" id="L3642">    <span class="tok-comment">/// The Diffie-Hellman group is not compatible with the policy type.</span></span>
<span class="line" id="L3643">    FWP_INCOMPATIBLE_DH_GROUP = <span class="tok-number">0xC0220031</span>,</span>
<span class="line" id="L3644">    <span class="tok-comment">/// An IKE policy cannot contain an Extended Mode policy.</span></span>
<span class="line" id="L3645">    FWP_EM_NOT_SUPPORTED = <span class="tok-number">0xC0220032</span>,</span>
<span class="line" id="L3646">    <span class="tok-comment">/// The enumeration template or subscription will never match any objects.</span></span>
<span class="line" id="L3647">    FWP_NEVER_MATCH = <span class="tok-number">0xC0220033</span>,</span>
<span class="line" id="L3648">    <span class="tok-comment">/// The provider context is of the wrong type.</span></span>
<span class="line" id="L3649">    FWP_PROVIDER_CONTEXT_MISMATCH = <span class="tok-number">0xC0220034</span>,</span>
<span class="line" id="L3650">    <span class="tok-comment">/// The parameter is incorrect.</span></span>
<span class="line" id="L3651">    FWP_INVALID_PARAMETER = <span class="tok-number">0xC0220035</span>,</span>
<span class="line" id="L3652">    <span class="tok-comment">/// The maximum number of sublayers has been reached.</span></span>
<span class="line" id="L3653">    FWP_TOO_MANY_SUBLAYERS = <span class="tok-number">0xC0220036</span>,</span>
<span class="line" id="L3654">    <span class="tok-comment">/// The notification function for a callout returned an error.</span></span>
<span class="line" id="L3655">    FWP_CALLOUT_NOTIFICATION_FAILED = <span class="tok-number">0xC0220037</span>,</span>
<span class="line" id="L3656">    <span class="tok-comment">/// The IPsec authentication configuration is not compatible with the authentication type.</span></span>
<span class="line" id="L3657">    FWP_INCOMPATIBLE_AUTH_CONFIG = <span class="tok-number">0xC0220038</span>,</span>
<span class="line" id="L3658">    <span class="tok-comment">/// The IPsec cipher configuration is not compatible with the cipher type.</span></span>
<span class="line" id="L3659">    FWP_INCOMPATIBLE_CIPHER_CONFIG = <span class="tok-number">0xC0220039</span>,</span>
<span class="line" id="L3660">    <span class="tok-comment">/// A policy cannot contain the same auth method more than once.</span></span>
<span class="line" id="L3661">    FWP_DUPLICATE_AUTH_METHOD = <span class="tok-number">0xC022003C</span>,</span>
<span class="line" id="L3662">    <span class="tok-comment">/// The TCP/IP stack is not ready.</span></span>
<span class="line" id="L3663">    FWP_TCPIP_NOT_READY = <span class="tok-number">0xC0220100</span>,</span>
<span class="line" id="L3664">    <span class="tok-comment">/// The injection handle is being closed by another thread.</span></span>
<span class="line" id="L3665">    FWP_INJECT_HANDLE_CLOSING = <span class="tok-number">0xC0220101</span>,</span>
<span class="line" id="L3666">    <span class="tok-comment">/// The injection handle is stale.</span></span>
<span class="line" id="L3667">    FWP_INJECT_HANDLE_STALE = <span class="tok-number">0xC0220102</span>,</span>
<span class="line" id="L3668">    <span class="tok-comment">/// The classify cannot be pended.</span></span>
<span class="line" id="L3669">    FWP_CANNOT_PEND = <span class="tok-number">0xC0220103</span>,</span>
<span class="line" id="L3670">    <span class="tok-comment">/// The binding to the network interface is being closed.</span></span>
<span class="line" id="L3671">    NDIS_CLOSING = <span class="tok-number">0xC0230002</span>,</span>
<span class="line" id="L3672">    <span class="tok-comment">/// An invalid version was specified.</span></span>
<span class="line" id="L3673">    NDIS_BAD_VERSION = <span class="tok-number">0xC0230004</span>,</span>
<span class="line" id="L3674">    <span class="tok-comment">/// An invalid characteristics table was used.</span></span>
<span class="line" id="L3675">    NDIS_BAD_CHARACTERISTICS = <span class="tok-number">0xC0230005</span>,</span>
<span class="line" id="L3676">    <span class="tok-comment">/// Failed to find the network interface or the network interface is not ready.</span></span>
<span class="line" id="L3677">    NDIS_ADAPTER_NOT_FOUND = <span class="tok-number">0xC0230006</span>,</span>
<span class="line" id="L3678">    <span class="tok-comment">/// Failed to open the network interface.</span></span>
<span class="line" id="L3679">    NDIS_OPEN_FAILED = <span class="tok-number">0xC0230007</span>,</span>
<span class="line" id="L3680">    <span class="tok-comment">/// The network interface has encountered an internal unrecoverable failure.</span></span>
<span class="line" id="L3681">    NDIS_DEVICE_FAILED = <span class="tok-number">0xC0230008</span>,</span>
<span class="line" id="L3682">    <span class="tok-comment">/// The multicast list on the network interface is full.</span></span>
<span class="line" id="L3683">    NDIS_MULTICAST_FULL = <span class="tok-number">0xC0230009</span>,</span>
<span class="line" id="L3684">    <span class="tok-comment">/// An attempt was made to add a duplicate multicast address to the list.</span></span>
<span class="line" id="L3685">    NDIS_MULTICAST_EXISTS = <span class="tok-number">0xC023000A</span>,</span>
<span class="line" id="L3686">    <span class="tok-comment">/// At attempt was made to remove a multicast address that was never added.</span></span>
<span class="line" id="L3687">    NDIS_MULTICAST_NOT_FOUND = <span class="tok-number">0xC023000B</span>,</span>
<span class="line" id="L3688">    <span class="tok-comment">/// The network interface aborted the request.</span></span>
<span class="line" id="L3689">    NDIS_REQUEST_ABORTED = <span class="tok-number">0xC023000C</span>,</span>
<span class="line" id="L3690">    <span class="tok-comment">/// The network interface cannot process the request because it is being reset.</span></span>
<span class="line" id="L3691">    NDIS_RESET_IN_PROGRESS = <span class="tok-number">0xC023000D</span>,</span>
<span class="line" id="L3692">    <span class="tok-comment">/// An attempt was made to send an invalid packet on a network interface.</span></span>
<span class="line" id="L3693">    NDIS_INVALID_PACKET = <span class="tok-number">0xC023000F</span>,</span>
<span class="line" id="L3694">    <span class="tok-comment">/// The specified request is not a valid operation for the target device.</span></span>
<span class="line" id="L3695">    NDIS_INVALID_DEVICE_REQUEST = <span class="tok-number">0xC0230010</span>,</span>
<span class="line" id="L3696">    <span class="tok-comment">/// The network interface is not ready to complete this operation.</span></span>
<span class="line" id="L3697">    NDIS_ADAPTER_NOT_READY = <span class="tok-number">0xC0230011</span>,</span>
<span class="line" id="L3698">    <span class="tok-comment">/// The length of the buffer submitted for this operation is not valid.</span></span>
<span class="line" id="L3699">    NDIS_INVALID_LENGTH = <span class="tok-number">0xC0230014</span>,</span>
<span class="line" id="L3700">    <span class="tok-comment">/// The data used for this operation is not valid.</span></span>
<span class="line" id="L3701">    NDIS_INVALID_DATA = <span class="tok-number">0xC0230015</span>,</span>
<span class="line" id="L3702">    <span class="tok-comment">/// The length of the submitted buffer for this operation is too small.</span></span>
<span class="line" id="L3703">    NDIS_BUFFER_TOO_SHORT = <span class="tok-number">0xC0230016</span>,</span>
<span class="line" id="L3704">    <span class="tok-comment">/// The network interface does not support this object identifier.</span></span>
<span class="line" id="L3705">    NDIS_INVALID_OID = <span class="tok-number">0xC0230017</span>,</span>
<span class="line" id="L3706">    <span class="tok-comment">/// The network interface has been removed.</span></span>
<span class="line" id="L3707">    NDIS_ADAPTER_REMOVED = <span class="tok-number">0xC0230018</span>,</span>
<span class="line" id="L3708">    <span class="tok-comment">/// The network interface does not support this media type.</span></span>
<span class="line" id="L3709">    NDIS_UNSUPPORTED_MEDIA = <span class="tok-number">0xC0230019</span>,</span>
<span class="line" id="L3710">    <span class="tok-comment">/// An attempt was made to remove a token ring group address that is in use by other components.</span></span>
<span class="line" id="L3711">    NDIS_GROUP_ADDRESS_IN_USE = <span class="tok-number">0xC023001A</span>,</span>
<span class="line" id="L3712">    <span class="tok-comment">/// An attempt was made to map a file that cannot be found.</span></span>
<span class="line" id="L3713">    NDIS_FILE_NOT_FOUND = <span class="tok-number">0xC023001B</span>,</span>
<span class="line" id="L3714">    <span class="tok-comment">/// An error occurred while NDIS tried to map the file.</span></span>
<span class="line" id="L3715">    NDIS_ERROR_READING_FILE = <span class="tok-number">0xC023001C</span>,</span>
<span class="line" id="L3716">    <span class="tok-comment">/// An attempt was made to map a file that is already mapped.</span></span>
<span class="line" id="L3717">    NDIS_ALREADY_MAPPED = <span class="tok-number">0xC023001D</span>,</span>
<span class="line" id="L3718">    <span class="tok-comment">/// An attempt to allocate a hardware resource failed because the resource is used by another component.</span></span>
<span class="line" id="L3719">    NDIS_RESOURCE_CONFLICT = <span class="tok-number">0xC023001E</span>,</span>
<span class="line" id="L3720">    <span class="tok-comment">/// The I/O operation failed because the network media is disconnected or the wireless access point is out of range.</span></span>
<span class="line" id="L3721">    NDIS_MEDIA_DISCONNECTED = <span class="tok-number">0xC023001F</span>,</span>
<span class="line" id="L3722">    <span class="tok-comment">/// The network address used in the request is invalid.</span></span>
<span class="line" id="L3723">    NDIS_INVALID_ADDRESS = <span class="tok-number">0xC0230022</span>,</span>
<span class="line" id="L3724">    <span class="tok-comment">/// The offload operation on the network interface has been paused.</span></span>
<span class="line" id="L3725">    NDIS_PAUSED = <span class="tok-number">0xC023002A</span>,</span>
<span class="line" id="L3726">    <span class="tok-comment">/// The network interface was not found.</span></span>
<span class="line" id="L3727">    NDIS_INTERFACE_NOT_FOUND = <span class="tok-number">0xC023002B</span>,</span>
<span class="line" id="L3728">    <span class="tok-comment">/// The revision number specified in the structure is not supported.</span></span>
<span class="line" id="L3729">    NDIS_UNSUPPORTED_REVISION = <span class="tok-number">0xC023002C</span>,</span>
<span class="line" id="L3730">    <span class="tok-comment">/// The specified port does not exist on this network interface.</span></span>
<span class="line" id="L3731">    NDIS_INVALID_PORT = <span class="tok-number">0xC023002D</span>,</span>
<span class="line" id="L3732">    <span class="tok-comment">/// The current state of the specified port on this network interface does not support the requested operation.</span></span>
<span class="line" id="L3733">    NDIS_INVALID_PORT_STATE = <span class="tok-number">0xC023002E</span>,</span>
<span class="line" id="L3734">    <span class="tok-comment">/// The miniport adapter is in a lower power state.</span></span>
<span class="line" id="L3735">    NDIS_LOW_POWER_STATE = <span class="tok-number">0xC023002F</span>,</span>
<span class="line" id="L3736">    <span class="tok-comment">/// The network interface does not support this request.</span></span>
<span class="line" id="L3737">    NDIS_NOT_SUPPORTED = <span class="tok-number">0xC02300BB</span>,</span>
<span class="line" id="L3738">    <span class="tok-comment">/// The TCP connection is not offloadable because of a local policy setting.</span></span>
<span class="line" id="L3739">    NDIS_OFFLOAD_POLICY = <span class="tok-number">0xC023100F</span>,</span>
<span class="line" id="L3740">    <span class="tok-comment">/// The TCP connection is not offloadable by the Chimney offload target.</span></span>
<span class="line" id="L3741">    NDIS_OFFLOAD_CONNECTION_REJECTED = <span class="tok-number">0xC0231012</span>,</span>
<span class="line" id="L3742">    <span class="tok-comment">/// The IP Path object is not in an offloadable state.</span></span>
<span class="line" id="L3743">    NDIS_OFFLOAD_PATH_REJECTED = <span class="tok-number">0xC0231013</span>,</span>
<span class="line" id="L3744">    <span class="tok-comment">/// The wireless LAN interface is in auto-configuration mode and does not support the requested parameter change operation.</span></span>
<span class="line" id="L3745">    NDIS_DOT11_AUTO_CONFIG_ENABLED = <span class="tok-number">0xC0232000</span>,</span>
<span class="line" id="L3746">    <span class="tok-comment">/// The wireless LAN interface is busy and cannot perform the requested operation.</span></span>
<span class="line" id="L3747">    NDIS_DOT11_MEDIA_IN_USE = <span class="tok-number">0xC0232001</span>,</span>
<span class="line" id="L3748">    <span class="tok-comment">/// The wireless LAN interface is power down and does not support the requested operation.</span></span>
<span class="line" id="L3749">    NDIS_DOT11_POWER_STATE_INVALID = <span class="tok-number">0xC0232002</span>,</span>
<span class="line" id="L3750">    <span class="tok-comment">/// The list of wake on LAN patterns is full.</span></span>
<span class="line" id="L3751">    NDIS_PM_WOL_PATTERN_LIST_FULL = <span class="tok-number">0xC0232003</span>,</span>
<span class="line" id="L3752">    <span class="tok-comment">/// The list of low power protocol offloads is full.</span></span>
<span class="line" id="L3753">    NDIS_PM_PROTOCOL_OFFLOAD_LIST_FULL = <span class="tok-number">0xC0232004</span>,</span>
<span class="line" id="L3754">    <span class="tok-comment">/// The SPI in the packet does not match a valid IPsec SA.</span></span>
<span class="line" id="L3755">    IPSEC_BAD_SPI = <span class="tok-number">0xC0360001</span>,</span>
<span class="line" id="L3756">    <span class="tok-comment">/// The packet was received on an IPsec SA whose lifetime has expired.</span></span>
<span class="line" id="L3757">    IPSEC_SA_LIFETIME_EXPIRED = <span class="tok-number">0xC0360002</span>,</span>
<span class="line" id="L3758">    <span class="tok-comment">/// The packet was received on an IPsec SA that does not match the packet characteristics.</span></span>
<span class="line" id="L3759">    IPSEC_WRONG_SA = <span class="tok-number">0xC0360003</span>,</span>
<span class="line" id="L3760">    <span class="tok-comment">/// The packet sequence number replay check failed.</span></span>
<span class="line" id="L3761">    IPSEC_REPLAY_CHECK_FAILED = <span class="tok-number">0xC0360004</span>,</span>
<span class="line" id="L3762">    <span class="tok-comment">/// The IPsec header and/or trailer in the packet is invalid.</span></span>
<span class="line" id="L3763">    IPSEC_INVALID_PACKET = <span class="tok-number">0xC0360005</span>,</span>
<span class="line" id="L3764">    <span class="tok-comment">/// The IPsec integrity check failed.</span></span>
<span class="line" id="L3765">    IPSEC_INTEGRITY_CHECK_FAILED = <span class="tok-number">0xC0360006</span>,</span>
<span class="line" id="L3766">    <span class="tok-comment">/// IPsec dropped a clear text packet.</span></span>
<span class="line" id="L3767">    IPSEC_CLEAR_TEXT_DROP = <span class="tok-number">0xC0360007</span>,</span>
<span class="line" id="L3768">    <span class="tok-comment">/// IPsec dropped an incoming ESP packet in authenticated firewall mode.  This drop is benign.</span></span>
<span class="line" id="L3769">    IPSEC_AUTH_FIREWALL_DROP = <span class="tok-number">0xC0360008</span>,</span>
<span class="line" id="L3770">    <span class="tok-comment">/// IPsec dropped a packet due to DOS throttle.</span></span>
<span class="line" id="L3771">    IPSEC_THROTTLE_DROP = <span class="tok-number">0xC0360009</span>,</span>
<span class="line" id="L3772">    <span class="tok-comment">/// IPsec Dos Protection matched an explicit block rule.</span></span>
<span class="line" id="L3773">    IPSEC_DOSP_BLOCK = <span class="tok-number">0xC0368000</span>,</span>
<span class="line" id="L3774">    <span class="tok-comment">/// IPsec Dos Protection received an IPsec specific multicast packet which is not allowed.</span></span>
<span class="line" id="L3775">    IPSEC_DOSP_RECEIVED_MULTICAST = <span class="tok-number">0xC0368001</span>,</span>
<span class="line" id="L3776">    <span class="tok-comment">/// IPsec Dos Protection received an incorrectly formatted packet.</span></span>
<span class="line" id="L3777">    IPSEC_DOSP_INVALID_PACKET = <span class="tok-number">0xC0368002</span>,</span>
<span class="line" id="L3778">    <span class="tok-comment">/// IPsec Dos Protection failed to lookup state.</span></span>
<span class="line" id="L3779">    IPSEC_DOSP_STATE_LOOKUP_FAILED = <span class="tok-number">0xC0368003</span>,</span>
<span class="line" id="L3780">    <span class="tok-comment">/// IPsec Dos Protection failed to create state because there are already maximum number of entries allowed by policy.</span></span>
<span class="line" id="L3781">    IPSEC_DOSP_MAX_ENTRIES = <span class="tok-number">0xC0368004</span>,</span>
<span class="line" id="L3782">    <span class="tok-comment">/// IPsec Dos Protection received an IPsec negotiation packet for a keying module which is not allowed by policy.</span></span>
<span class="line" id="L3783">    IPSEC_DOSP_KEYMOD_NOT_ALLOWED = <span class="tok-number">0xC0368005</span>,</span>
<span class="line" id="L3784">    <span class="tok-comment">/// IPsec Dos Protection failed to create per internal IP ratelimit queue because there is already maximum number of queues allowed by policy.</span></span>
<span class="line" id="L3785">    IPSEC_DOSP_MAX_PER_IP_RATELIMIT_QUEUES = <span class="tok-number">0xC0368006</span>,</span>
<span class="line" id="L3786">    <span class="tok-comment">/// The system does not support mirrored volumes.</span></span>
<span class="line" id="L3787">    VOLMGR_MIRROR_NOT_SUPPORTED = <span class="tok-number">0xC038005B</span>,</span>
<span class="line" id="L3788">    <span class="tok-comment">/// The system does not support RAID-5 volumes.</span></span>
<span class="line" id="L3789">    VOLMGR_RAID5_NOT_SUPPORTED = <span class="tok-number">0xC038005C</span>,</span>
<span class="line" id="L3790">    <span class="tok-comment">/// A virtual disk support provider for the specified file was not found.</span></span>
<span class="line" id="L3791">    VIRTDISK_PROVIDER_NOT_FOUND = <span class="tok-number">0xC03A0014</span>,</span>
<span class="line" id="L3792">    <span class="tok-comment">/// The specified disk is not a virtual disk.</span></span>
<span class="line" id="L3793">    VIRTDISK_NOT_VIRTUAL_DISK = <span class="tok-number">0xC03A0015</span>,</span>
<span class="line" id="L3794">    <span class="tok-comment">/// The chain of virtual hard disks is inaccessible.</span></span>
<span class="line" id="L3795">    <span class="tok-comment">/// The process has not been granted access rights to the parent virtual hard disk for the differencing disk.</span></span>
<span class="line" id="L3796">    VHD_PARENT_VHD_ACCESS_DENIED = <span class="tok-number">0xC03A0016</span>,</span>
<span class="line" id="L3797">    <span class="tok-comment">/// The chain of virtual hard disks is corrupted.</span></span>
<span class="line" id="L3798">    <span class="tok-comment">/// There is a mismatch in the virtual sizes of the parent virtual hard disk and differencing disk.</span></span>
<span class="line" id="L3799">    VHD_CHILD_PARENT_SIZE_MISMATCH = <span class="tok-number">0xC03A0017</span>,</span>
<span class="line" id="L3800">    <span class="tok-comment">/// The chain of virtual hard disks is corrupted.</span></span>
<span class="line" id="L3801">    <span class="tok-comment">/// A differencing disk is indicated in its own parent chain.</span></span>
<span class="line" id="L3802">    VHD_DIFFERENCING_CHAIN_CYCLE_DETECTED = <span class="tok-number">0xC03A0018</span>,</span>
<span class="line" id="L3803">    <span class="tok-comment">/// The chain of virtual hard disks is inaccessible.</span></span>
<span class="line" id="L3804">    <span class="tok-comment">/// There was an error opening a virtual hard disk further up the chain.</span></span>
<span class="line" id="L3805">    VHD_DIFFERENCING_CHAIN_ERROR_IN_PARENT = <span class="tok-number">0xC03A0019</span>,</span>
<span class="line" id="L3806">    _,</span>
<span class="line" id="L3807">};</span>
<span class="line" id="L3808"></span>
</code></pre></body>
</html>