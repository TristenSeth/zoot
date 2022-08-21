<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">    <title>fs/file.zig - source view</title>
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
<pre><code><span class="line" id="L1"><span class="tok-kw">const</span> std = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;../std.zig&quot;</span>);</span>
<span class="line" id="L2"><span class="tok-kw">const</span> builtin = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;builtin&quot;</span>);</span>
<span class="line" id="L3"><span class="tok-kw">const</span> os = std.os;</span>
<span class="line" id="L4"><span class="tok-kw">const</span> io = std.io;</span>
<span class="line" id="L5"><span class="tok-kw">const</span> mem = std.mem;</span>
<span class="line" id="L6"><span class="tok-kw">const</span> math = std.math;</span>
<span class="line" id="L7"><span class="tok-kw">const</span> assert = std.debug.assert;</span>
<span class="line" id="L8"><span class="tok-kw">const</span> windows = os.windows;</span>
<span class="line" id="L9"><span class="tok-kw">const</span> Os = std.builtin.Os;</span>
<span class="line" id="L10"><span class="tok-kw">const</span> maxInt = std.math.maxInt;</span>
<span class="line" id="L11"><span class="tok-kw">const</span> is_windows = builtin.os.tag == .windows;</span>
<span class="line" id="L12"></span>
<span class="line" id="L13"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> File = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L14">    <span class="tok-comment">/// The OS-specific file descriptor or file handle.</span></span>
<span class="line" id="L15">    handle: Handle,</span>
<span class="line" id="L16"></span>
<span class="line" id="L17">    <span class="tok-comment">/// On some systems, such as Linux, file system file descriptors are incapable</span></span>
<span class="line" id="L18">    <span class="tok-comment">/// of non-blocking I/O. This forces us to perform asynchronous I/O on a dedicated thread,</span></span>
<span class="line" id="L19">    <span class="tok-comment">/// to achieve non-blocking file-system I/O. To do this, `File` must be aware of whether</span></span>
<span class="line" id="L20">    <span class="tok-comment">/// it is a file system file descriptor, or, more specifically, whether the I/O is always</span></span>
<span class="line" id="L21">    <span class="tok-comment">/// blocking.</span></span>
<span class="line" id="L22">    capable_io_mode: io.ModeOverride = io.default_mode,</span>
<span class="line" id="L23"></span>
<span class="line" id="L24">    <span class="tok-comment">/// Furthermore, even when `std.io.mode` is async, it is still sometimes desirable</span></span>
<span class="line" id="L25">    <span class="tok-comment">/// to perform blocking I/O, although not by default. For example, when printing a</span></span>
<span class="line" id="L26">    <span class="tok-comment">/// stack trace to stderr. This field tracks both by acting as an overriding I/O mode.</span></span>
<span class="line" id="L27">    <span class="tok-comment">/// When not building in async I/O mode, the type only has the `.blocking` tag, making</span></span>
<span class="line" id="L28">    <span class="tok-comment">/// it a zero-bit type.</span></span>
<span class="line" id="L29">    intended_io_mode: io.ModeOverride = io.default_mode,</span>
<span class="line" id="L30"></span>
<span class="line" id="L31">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> Handle = os.fd_t;</span>
<span class="line" id="L32">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> Mode = os.mode_t;</span>
<span class="line" id="L33">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> INode = os.ino_t;</span>
<span class="line" id="L34">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> Uid = os.uid_t;</span>
<span class="line" id="L35">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> Gid = os.gid_t;</span>
<span class="line" id="L36"></span>
<span class="line" id="L37">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> Kind = <span class="tok-kw">enum</span> {</span>
<span class="line" id="L38">        BlockDevice,</span>
<span class="line" id="L39">        CharacterDevice,</span>
<span class="line" id="L40">        Directory,</span>
<span class="line" id="L41">        NamedPipe,</span>
<span class="line" id="L42">        SymLink,</span>
<span class="line" id="L43">        File,</span>
<span class="line" id="L44">        UnixDomainSocket,</span>
<span class="line" id="L45">        Whiteout,</span>
<span class="line" id="L46">        Door,</span>
<span class="line" id="L47">        EventPort,</span>
<span class="line" id="L48">        Unknown,</span>
<span class="line" id="L49">    };</span>
<span class="line" id="L50"></span>
<span class="line" id="L51">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> default_mode = <span class="tok-kw">switch</span> (builtin.os.tag) {</span>
<span class="line" id="L52">        .windows =&gt; <span class="tok-number">0</span>,</span>
<span class="line" id="L53">        .wasi =&gt; <span class="tok-number">0</span>,</span>
<span class="line" id="L54">        <span class="tok-kw">else</span> =&gt; <span class="tok-number">0o666</span>,</span>
<span class="line" id="L55">    };</span>
<span class="line" id="L56"></span>
<span class="line" id="L57">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> OpenError = <span class="tok-kw">error</span>{</span>
<span class="line" id="L58">        SharingViolation,</span>
<span class="line" id="L59">        PathAlreadyExists,</span>
<span class="line" id="L60">        FileNotFound,</span>
<span class="line" id="L61">        AccessDenied,</span>
<span class="line" id="L62">        PipeBusy,</span>
<span class="line" id="L63">        NameTooLong,</span>
<span class="line" id="L64">        <span class="tok-comment">/// On Windows, file paths must be valid Unicode.</span></span>
<span class="line" id="L65">        InvalidUtf8,</span>
<span class="line" id="L66">        <span class="tok-comment">/// On Windows, file paths cannot contain these characters:</span></span>
<span class="line" id="L67">        <span class="tok-comment">/// '/', '*', '?', '&quot;', '&lt;', '&gt;', '|'</span></span>
<span class="line" id="L68">        BadPathName,</span>
<span class="line" id="L69">        Unexpected,</span>
<span class="line" id="L70">    } || os.OpenError || os.FlockError;</span>
<span class="line" id="L71"></span>
<span class="line" id="L72">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> OpenMode = <span class="tok-kw">enum</span> {</span>
<span class="line" id="L73">        read_only,</span>
<span class="line" id="L74">        write_only,</span>
<span class="line" id="L75">        read_write,</span>
<span class="line" id="L76">    };</span>
<span class="line" id="L77"></span>
<span class="line" id="L78">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> Lock = <span class="tok-kw">enum</span> { None, Shared, Exclusive };</span>
<span class="line" id="L79"></span>
<span class="line" id="L80">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> OpenFlags = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L81">        mode: OpenMode = .read_only,</span>
<span class="line" id="L82"></span>
<span class="line" id="L83">        <span class="tok-comment">/// Open the file with an advisory lock to coordinate with other processes</span></span>
<span class="line" id="L84">        <span class="tok-comment">/// accessing it at the same time. An exclusive lock will prevent other</span></span>
<span class="line" id="L85">        <span class="tok-comment">/// processes from acquiring a lock. A shared lock will prevent other</span></span>
<span class="line" id="L86">        <span class="tok-comment">/// processes from acquiring a exclusive lock, but does not prevent</span></span>
<span class="line" id="L87">        <span class="tok-comment">/// other process from getting their own shared locks.</span></span>
<span class="line" id="L88">        <span class="tok-comment">///</span></span>
<span class="line" id="L89">        <span class="tok-comment">/// The lock is advisory, except on Linux in very specific cirsumstances[1].</span></span>
<span class="line" id="L90">        <span class="tok-comment">/// This means that a process that does not respect the locking API can still get access</span></span>
<span class="line" id="L91">        <span class="tok-comment">/// to the file, despite the lock.</span></span>
<span class="line" id="L92">        <span class="tok-comment">///</span></span>
<span class="line" id="L93">        <span class="tok-comment">/// On these operating systems, the lock is acquired atomically with</span></span>
<span class="line" id="L94">        <span class="tok-comment">/// opening the file:</span></span>
<span class="line" id="L95">        <span class="tok-comment">/// * Darwin</span></span>
<span class="line" id="L96">        <span class="tok-comment">/// * DragonFlyBSD</span></span>
<span class="line" id="L97">        <span class="tok-comment">/// * FreeBSD</span></span>
<span class="line" id="L98">        <span class="tok-comment">/// * Haiku</span></span>
<span class="line" id="L99">        <span class="tok-comment">/// * NetBSD</span></span>
<span class="line" id="L100">        <span class="tok-comment">/// * OpenBSD</span></span>
<span class="line" id="L101">        <span class="tok-comment">/// On these operating systems, the lock is acquired via a separate syscall</span></span>
<span class="line" id="L102">        <span class="tok-comment">/// after opening the file:</span></span>
<span class="line" id="L103">        <span class="tok-comment">/// * Linux</span></span>
<span class="line" id="L104">        <span class="tok-comment">/// * Windows</span></span>
<span class="line" id="L105">        <span class="tok-comment">///</span></span>
<span class="line" id="L106">        <span class="tok-comment">/// [1]: https://www.kernel.org/doc/Documentation/filesystems/mandatory-locking.txt</span></span>
<span class="line" id="L107">        lock: Lock = .None,</span>
<span class="line" id="L108"></span>
<span class="line" id="L109">        <span class="tok-comment">/// Sets whether or not to wait until the file is locked to return. If set to true,</span></span>
<span class="line" id="L110">        <span class="tok-comment">/// `error.WouldBlock` will be returned. Otherwise, the file will wait until the file</span></span>
<span class="line" id="L111">        <span class="tok-comment">/// is available to proceed.</span></span>
<span class="line" id="L112">        <span class="tok-comment">/// In async I/O mode, non-blocking at the OS level is</span></span>
<span class="line" id="L113">        <span class="tok-comment">/// determined by `intended_io_mode`, and `true` means `error.WouldBlock` is returned,</span></span>
<span class="line" id="L114">        <span class="tok-comment">/// and `false` means `error.WouldBlock` is handled by the event loop.</span></span>
<span class="line" id="L115">        lock_nonblocking: <span class="tok-type">bool</span> = <span class="tok-null">false</span>,</span>
<span class="line" id="L116"></span>
<span class="line" id="L117">        <span class="tok-comment">/// Setting this to `.blocking` prevents `O.NONBLOCK` from being passed even</span></span>
<span class="line" id="L118">        <span class="tok-comment">/// if `std.io.is_async`. It allows the use of `nosuspend` when calling functions</span></span>
<span class="line" id="L119">        <span class="tok-comment">/// related to opening the file, reading, writing, and locking.</span></span>
<span class="line" id="L120">        intended_io_mode: io.ModeOverride = io.default_mode,</span>
<span class="line" id="L121"></span>
<span class="line" id="L122">        <span class="tok-comment">/// Set this to allow the opened file to automatically become the</span></span>
<span class="line" id="L123">        <span class="tok-comment">/// controlling TTY for the current process.</span></span>
<span class="line" id="L124">        allow_ctty: <span class="tok-type">bool</span> = <span class="tok-null">false</span>,</span>
<span class="line" id="L125"></span>
<span class="line" id="L126">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">isRead</span>(self: OpenFlags) <span class="tok-type">bool</span> {</span>
<span class="line" id="L127">            <span class="tok-kw">return</span> self.mode != .write_only;</span>
<span class="line" id="L128">        }</span>
<span class="line" id="L129"></span>
<span class="line" id="L130">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">isWrite</span>(self: OpenFlags) <span class="tok-type">bool</span> {</span>
<span class="line" id="L131">            <span class="tok-kw">return</span> self.mode != .read_only;</span>
<span class="line" id="L132">        }</span>
<span class="line" id="L133">    };</span>
<span class="line" id="L134"></span>
<span class="line" id="L135">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> CreateFlags = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L136">        <span class="tok-comment">/// Whether the file will be created with read access.</span></span>
<span class="line" id="L137">        read: <span class="tok-type">bool</span> = <span class="tok-null">false</span>,</span>
<span class="line" id="L138"></span>
<span class="line" id="L139">        <span class="tok-comment">/// If the file already exists, and is a regular file, and the access</span></span>
<span class="line" id="L140">        <span class="tok-comment">/// mode allows writing, it will be truncated to length 0.</span></span>
<span class="line" id="L141">        truncate: <span class="tok-type">bool</span> = <span class="tok-null">true</span>,</span>
<span class="line" id="L142"></span>
<span class="line" id="L143">        <span class="tok-comment">/// Ensures that this open call creates the file, otherwise causes</span></span>
<span class="line" id="L144">        <span class="tok-comment">/// `error.PathAlreadyExists` to be returned.</span></span>
<span class="line" id="L145">        exclusive: <span class="tok-type">bool</span> = <span class="tok-null">false</span>,</span>
<span class="line" id="L146"></span>
<span class="line" id="L147">        <span class="tok-comment">/// Open the file with an advisory lock to coordinate with other processes</span></span>
<span class="line" id="L148">        <span class="tok-comment">/// accessing it at the same time. An exclusive lock will prevent other</span></span>
<span class="line" id="L149">        <span class="tok-comment">/// processes from acquiring a lock. A shared lock will prevent other</span></span>
<span class="line" id="L150">        <span class="tok-comment">/// processes from acquiring a exclusive lock, but does not prevent</span></span>
<span class="line" id="L151">        <span class="tok-comment">/// other process from getting their own shared locks.</span></span>
<span class="line" id="L152">        <span class="tok-comment">///</span></span>
<span class="line" id="L153">        <span class="tok-comment">/// The lock is advisory, except on Linux in very specific cirsumstances[1].</span></span>
<span class="line" id="L154">        <span class="tok-comment">/// This means that a process that does not respect the locking API can still get access</span></span>
<span class="line" id="L155">        <span class="tok-comment">/// to the file, despite the lock.</span></span>
<span class="line" id="L156">        <span class="tok-comment">///</span></span>
<span class="line" id="L157">        <span class="tok-comment">/// On these operating systems, the lock is acquired atomically with</span></span>
<span class="line" id="L158">        <span class="tok-comment">/// opening the file:</span></span>
<span class="line" id="L159">        <span class="tok-comment">/// * Darwin</span></span>
<span class="line" id="L160">        <span class="tok-comment">/// * DragonFlyBSD</span></span>
<span class="line" id="L161">        <span class="tok-comment">/// * FreeBSD</span></span>
<span class="line" id="L162">        <span class="tok-comment">/// * Haiku</span></span>
<span class="line" id="L163">        <span class="tok-comment">/// * NetBSD</span></span>
<span class="line" id="L164">        <span class="tok-comment">/// * OpenBSD</span></span>
<span class="line" id="L165">        <span class="tok-comment">/// On these operating systems, the lock is acquired via a separate syscall</span></span>
<span class="line" id="L166">        <span class="tok-comment">/// after opening the file:</span></span>
<span class="line" id="L167">        <span class="tok-comment">/// * Linux</span></span>
<span class="line" id="L168">        <span class="tok-comment">/// * Windows</span></span>
<span class="line" id="L169">        <span class="tok-comment">///</span></span>
<span class="line" id="L170">        <span class="tok-comment">/// [1]: https://www.kernel.org/doc/Documentation/filesystems/mandatory-locking.txt</span></span>
<span class="line" id="L171">        lock: Lock = .None,</span>
<span class="line" id="L172"></span>
<span class="line" id="L173">        <span class="tok-comment">/// Sets whether or not to wait until the file is locked to return. If set to true,</span></span>
<span class="line" id="L174">        <span class="tok-comment">/// `error.WouldBlock` will be returned. Otherwise, the file will wait until the file</span></span>
<span class="line" id="L175">        <span class="tok-comment">/// is available to proceed.</span></span>
<span class="line" id="L176">        <span class="tok-comment">/// In async I/O mode, non-blocking at the OS level is</span></span>
<span class="line" id="L177">        <span class="tok-comment">/// determined by `intended_io_mode`, and `true` means `error.WouldBlock` is returned,</span></span>
<span class="line" id="L178">        <span class="tok-comment">/// and `false` means `error.WouldBlock` is handled by the event loop.</span></span>
<span class="line" id="L179">        lock_nonblocking: <span class="tok-type">bool</span> = <span class="tok-null">false</span>,</span>
<span class="line" id="L180"></span>
<span class="line" id="L181">        <span class="tok-comment">/// For POSIX systems this is the file system mode the file will</span></span>
<span class="line" id="L182">        <span class="tok-comment">/// be created with.</span></span>
<span class="line" id="L183">        mode: Mode = default_mode,</span>
<span class="line" id="L184"></span>
<span class="line" id="L185">        <span class="tok-comment">/// Setting this to `.blocking` prevents `O.NONBLOCK` from being passed even</span></span>
<span class="line" id="L186">        <span class="tok-comment">/// if `std.io.is_async`. It allows the use of `nosuspend` when calling functions</span></span>
<span class="line" id="L187">        <span class="tok-comment">/// related to opening the file, reading, writing, and locking.</span></span>
<span class="line" id="L188">        intended_io_mode: io.ModeOverride = io.default_mode,</span>
<span class="line" id="L189">    };</span>
<span class="line" id="L190"></span>
<span class="line" id="L191">    <span class="tok-comment">/// Upon success, the stream is in an uninitialized state. To continue using it,</span></span>
<span class="line" id="L192">    <span class="tok-comment">/// you must use the open() function.</span></span>
<span class="line" id="L193">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">close</span>(self: File) <span class="tok-type">void</span> {</span>
<span class="line" id="L194">        <span class="tok-kw">if</span> (is_windows) {</span>
<span class="line" id="L195">            windows.CloseHandle(self.handle);</span>
<span class="line" id="L196">        } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (self.capable_io_mode != self.intended_io_mode) {</span>
<span class="line" id="L197">            std.event.Loop.instance.?.close(self.handle);</span>
<span class="line" id="L198">        } <span class="tok-kw">else</span> {</span>
<span class="line" id="L199">            os.close(self.handle);</span>
<span class="line" id="L200">        }</span>
<span class="line" id="L201">    }</span>
<span class="line" id="L202"></span>
<span class="line" id="L203">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> SyncError = os.SyncError;</span>
<span class="line" id="L204"></span>
<span class="line" id="L205">    <span class="tok-comment">/// Blocks until all pending file contents and metadata modifications</span></span>
<span class="line" id="L206">    <span class="tok-comment">/// for the file have been synchronized with the underlying filesystem.</span></span>
<span class="line" id="L207">    <span class="tok-comment">///</span></span>
<span class="line" id="L208">    <span class="tok-comment">/// Note that this does not ensure that metadata for the</span></span>
<span class="line" id="L209">    <span class="tok-comment">/// directory containing the file has also reached disk.</span></span>
<span class="line" id="L210">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">sync</span>(self: File) SyncError!<span class="tok-type">void</span> {</span>
<span class="line" id="L211">        <span class="tok-kw">return</span> os.fsync(self.handle);</span>
<span class="line" id="L212">    }</span>
<span class="line" id="L213"></span>
<span class="line" id="L214">    <span class="tok-comment">/// Test whether the file refers to a terminal.</span></span>
<span class="line" id="L215">    <span class="tok-comment">/// See also `supportsAnsiEscapeCodes`.</span></span>
<span class="line" id="L216">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">isTty</span>(self: File) <span class="tok-type">bool</span> {</span>
<span class="line" id="L217">        <span class="tok-kw">return</span> os.isatty(self.handle);</span>
<span class="line" id="L218">    }</span>
<span class="line" id="L219"></span>
<span class="line" id="L220">    <span class="tok-comment">/// Test whether ANSI escape codes will be treated as such.</span></span>
<span class="line" id="L221">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">supportsAnsiEscapeCodes</span>(self: File) <span class="tok-type">bool</span> {</span>
<span class="line" id="L222">        <span class="tok-kw">if</span> (builtin.os.tag == .windows) {</span>
<span class="line" id="L223">            <span class="tok-kw">return</span> os.isCygwinPty(self.handle);</span>
<span class="line" id="L224">        }</span>
<span class="line" id="L225">        <span class="tok-kw">if</span> (builtin.os.tag == .wasi) {</span>
<span class="line" id="L226">            <span class="tok-comment">// WASI sanitizes stdout when fd is a tty so ANSI escape codes</span>
</span>
<span class="line" id="L227">            <span class="tok-comment">// will not be interpreted as actual cursor commands, and</span>
</span>
<span class="line" id="L228">            <span class="tok-comment">// stderr is always sanitized.</span>
</span>
<span class="line" id="L229">            <span class="tok-kw">return</span> <span class="tok-null">false</span>;</span>
<span class="line" id="L230">        }</span>
<span class="line" id="L231">        <span class="tok-kw">if</span> (self.isTty()) {</span>
<span class="line" id="L232">            <span class="tok-kw">if</span> (self.handle == os.STDOUT_FILENO <span class="tok-kw">or</span> self.handle == os.STDERR_FILENO) {</span>
<span class="line" id="L233">                <span class="tok-comment">// Use getenvC to workaround https://github.com/ziglang/zig/issues/3511</span>
</span>
<span class="line" id="L234">                <span class="tok-kw">if</span> (os.getenvZ(<span class="tok-str">&quot;TERM&quot;</span>)) |term| {</span>
<span class="line" id="L235">                    <span class="tok-kw">if</span> (std.mem.eql(<span class="tok-type">u8</span>, term, <span class="tok-str">&quot;dumb&quot;</span>))</span>
<span class="line" id="L236">                        <span class="tok-kw">return</span> <span class="tok-null">false</span>;</span>
<span class="line" id="L237">                }</span>
<span class="line" id="L238">            }</span>
<span class="line" id="L239">            <span class="tok-kw">return</span> <span class="tok-null">true</span>;</span>
<span class="line" id="L240">        }</span>
<span class="line" id="L241">        <span class="tok-kw">return</span> <span class="tok-null">false</span>;</span>
<span class="line" id="L242">    }</span>
<span class="line" id="L243"></span>
<span class="line" id="L244">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> SetEndPosError = os.TruncateError;</span>
<span class="line" id="L245"></span>
<span class="line" id="L246">    <span class="tok-comment">/// Shrinks or expands the file.</span></span>
<span class="line" id="L247">    <span class="tok-comment">/// The file offset after this call is left unchanged.</span></span>
<span class="line" id="L248">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">setEndPos</span>(self: File, length: <span class="tok-type">u64</span>) SetEndPosError!<span class="tok-type">void</span> {</span>
<span class="line" id="L249">        <span class="tok-kw">try</span> os.ftruncate(self.handle, length);</span>
<span class="line" id="L250">    }</span>
<span class="line" id="L251"></span>
<span class="line" id="L252">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> SeekError = os.SeekError;</span>
<span class="line" id="L253"></span>
<span class="line" id="L254">    <span class="tok-comment">/// Repositions read/write file offset relative to the current offset.</span></span>
<span class="line" id="L255">    <span class="tok-comment">/// TODO: integrate with async I/O</span></span>
<span class="line" id="L256">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">seekBy</span>(self: File, offset: <span class="tok-type">i64</span>) SeekError!<span class="tok-type">void</span> {</span>
<span class="line" id="L257">        <span class="tok-kw">return</span> os.lseek_CUR(self.handle, offset);</span>
<span class="line" id="L258">    }</span>
<span class="line" id="L259"></span>
<span class="line" id="L260">    <span class="tok-comment">/// Repositions read/write file offset relative to the end.</span></span>
<span class="line" id="L261">    <span class="tok-comment">/// TODO: integrate with async I/O</span></span>
<span class="line" id="L262">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">seekFromEnd</span>(self: File, offset: <span class="tok-type">i64</span>) SeekError!<span class="tok-type">void</span> {</span>
<span class="line" id="L263">        <span class="tok-kw">return</span> os.lseek_END(self.handle, offset);</span>
<span class="line" id="L264">    }</span>
<span class="line" id="L265"></span>
<span class="line" id="L266">    <span class="tok-comment">/// Repositions read/write file offset relative to the beginning.</span></span>
<span class="line" id="L267">    <span class="tok-comment">/// TODO: integrate with async I/O</span></span>
<span class="line" id="L268">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">seekTo</span>(self: File, offset: <span class="tok-type">u64</span>) SeekError!<span class="tok-type">void</span> {</span>
<span class="line" id="L269">        <span class="tok-kw">return</span> os.lseek_SET(self.handle, offset);</span>
<span class="line" id="L270">    }</span>
<span class="line" id="L271"></span>
<span class="line" id="L272">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> GetSeekPosError = os.SeekError || os.FStatError;</span>
<span class="line" id="L273"></span>
<span class="line" id="L274">    <span class="tok-comment">/// TODO: integrate with async I/O</span></span>
<span class="line" id="L275">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">getPos</span>(self: File) GetSeekPosError!<span class="tok-type">u64</span> {</span>
<span class="line" id="L276">        <span class="tok-kw">return</span> os.lseek_CUR_get(self.handle);</span>
<span class="line" id="L277">    }</span>
<span class="line" id="L278"></span>
<span class="line" id="L279">    <span class="tok-comment">/// TODO: integrate with async I/O</span></span>
<span class="line" id="L280">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">getEndPos</span>(self: File) GetSeekPosError!<span class="tok-type">u64</span> {</span>
<span class="line" id="L281">        <span class="tok-kw">if</span> (builtin.os.tag == .windows) {</span>
<span class="line" id="L282">            <span class="tok-kw">return</span> windows.GetFileSizeEx(self.handle);</span>
<span class="line" id="L283">        }</span>
<span class="line" id="L284">        <span class="tok-kw">return</span> (<span class="tok-kw">try</span> self.stat()).size;</span>
<span class="line" id="L285">    }</span>
<span class="line" id="L286"></span>
<span class="line" id="L287">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> ModeError = os.FStatError;</span>
<span class="line" id="L288"></span>
<span class="line" id="L289">    <span class="tok-comment">/// TODO: integrate with async I/O</span></span>
<span class="line" id="L290">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">mode</span>(self: File) ModeError!Mode {</span>
<span class="line" id="L291">        <span class="tok-kw">if</span> (builtin.os.tag == .windows) {</span>
<span class="line" id="L292">            <span class="tok-kw">return</span> <span class="tok-number">0</span>;</span>
<span class="line" id="L293">        }</span>
<span class="line" id="L294">        <span class="tok-kw">return</span> (<span class="tok-kw">try</span> self.stat()).mode;</span>
<span class="line" id="L295">    }</span>
<span class="line" id="L296"></span>
<span class="line" id="L297">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> Stat = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L298">        <span class="tok-comment">/// A number that the system uses to point to the file metadata. This number is not guaranteed to be</span></span>
<span class="line" id="L299">        <span class="tok-comment">/// unique across time, as some file systems may reuse an inode after its file has been deleted.</span></span>
<span class="line" id="L300">        <span class="tok-comment">/// Some systems may change the inode of a file over time.</span></span>
<span class="line" id="L301">        <span class="tok-comment">///</span></span>
<span class="line" id="L302">        <span class="tok-comment">/// On Linux, the inode is a structure that stores the metadata, and the inode _number_ is what</span></span>
<span class="line" id="L303">        <span class="tok-comment">/// you see here: the index number of the inode.</span></span>
<span class="line" id="L304">        <span class="tok-comment">///</span></span>
<span class="line" id="L305">        <span class="tok-comment">/// The FileIndex on Windows is similar. It is a number for a file that is unique to each filesystem.</span></span>
<span class="line" id="L306">        inode: INode,</span>
<span class="line" id="L307">        size: <span class="tok-type">u64</span>,</span>
<span class="line" id="L308">        mode: Mode,</span>
<span class="line" id="L309">        kind: Kind,</span>
<span class="line" id="L310"></span>
<span class="line" id="L311">        <span class="tok-comment">/// Access time in nanoseconds, relative to UTC 1970-01-01.</span></span>
<span class="line" id="L312">        atime: <span class="tok-type">i128</span>,</span>
<span class="line" id="L313">        <span class="tok-comment">/// Last modification time in nanoseconds, relative to UTC 1970-01-01.</span></span>
<span class="line" id="L314">        mtime: <span class="tok-type">i128</span>,</span>
<span class="line" id="L315">        <span class="tok-comment">/// Creation time in nanoseconds, relative to UTC 1970-01-01.</span></span>
<span class="line" id="L316">        ctime: <span class="tok-type">i128</span>,</span>
<span class="line" id="L317">    };</span>
<span class="line" id="L318"></span>
<span class="line" id="L319">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> StatError = os.FStatError;</span>
<span class="line" id="L320"></span>
<span class="line" id="L321">    <span class="tok-comment">/// TODO: integrate with async I/O</span></span>
<span class="line" id="L322">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">stat</span>(self: File) StatError!Stat {</span>
<span class="line" id="L323">        <span class="tok-kw">if</span> (builtin.os.tag == .windows) {</span>
<span class="line" id="L324">            <span class="tok-kw">var</span> io_status_block: windows.IO_STATUS_BLOCK = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L325">            <span class="tok-kw">var</span> info: windows.FILE_ALL_INFORMATION = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L326">            <span class="tok-kw">const</span> rc = windows.ntdll.NtQueryInformationFile(self.handle, &amp;io_status_block, &amp;info, <span class="tok-builtin">@sizeOf</span>(windows.FILE_ALL_INFORMATION), .FileAllInformation);</span>
<span class="line" id="L327">            <span class="tok-kw">switch</span> (rc) {</span>
<span class="line" id="L328">                .SUCCESS =&gt; {},</span>
<span class="line" id="L329">                .BUFFER_OVERFLOW =&gt; {},</span>
<span class="line" id="L330">                .INVALID_PARAMETER =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L331">                .ACCESS_DENIED =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.AccessDenied,</span>
<span class="line" id="L332">                <span class="tok-kw">else</span> =&gt; <span class="tok-kw">return</span> windows.unexpectedStatus(rc),</span>
<span class="line" id="L333">            }</span>
<span class="line" id="L334">            <span class="tok-kw">return</span> Stat{</span>
<span class="line" id="L335">                .inode = info.InternalInformation.IndexNumber,</span>
<span class="line" id="L336">                .size = <span class="tok-builtin">@bitCast</span>(<span class="tok-type">u64</span>, info.StandardInformation.EndOfFile),</span>
<span class="line" id="L337">                .mode = <span class="tok-number">0</span>,</span>
<span class="line" id="L338">                .kind = <span class="tok-kw">if</span> (info.StandardInformation.Directory == <span class="tok-number">0</span>) .File <span class="tok-kw">else</span> .Directory,</span>
<span class="line" id="L339">                .atime = windows.fromSysTime(info.BasicInformation.LastAccessTime),</span>
<span class="line" id="L340">                .mtime = windows.fromSysTime(info.BasicInformation.LastWriteTime),</span>
<span class="line" id="L341">                .ctime = windows.fromSysTime(info.BasicInformation.CreationTime),</span>
<span class="line" id="L342">            };</span>
<span class="line" id="L343">        }</span>
<span class="line" id="L344"></span>
<span class="line" id="L345">        <span class="tok-kw">const</span> st = <span class="tok-kw">try</span> os.fstat(self.handle);</span>
<span class="line" id="L346">        <span class="tok-kw">const</span> atime = st.atime();</span>
<span class="line" id="L347">        <span class="tok-kw">const</span> mtime = st.mtime();</span>
<span class="line" id="L348">        <span class="tok-kw">const</span> ctime = st.ctime();</span>
<span class="line" id="L349">        <span class="tok-kw">const</span> kind: Kind = <span class="tok-kw">if</span> (builtin.os.tag == .wasi <span class="tok-kw">and</span> !builtin.link_libc) <span class="tok-kw">switch</span> (st.filetype) {</span>
<span class="line" id="L350">            .BLOCK_DEVICE =&gt; Kind.BlockDevice,</span>
<span class="line" id="L351">            .CHARACTER_DEVICE =&gt; Kind.CharacterDevice,</span>
<span class="line" id="L352">            .DIRECTORY =&gt; Kind.Directory,</span>
<span class="line" id="L353">            .SYMBOLIC_LINK =&gt; Kind.SymLink,</span>
<span class="line" id="L354">            .REGULAR_FILE =&gt; Kind.File,</span>
<span class="line" id="L355">            .SOCKET_STREAM, .SOCKET_DGRAM =&gt; Kind.UnixDomainSocket,</span>
<span class="line" id="L356">            <span class="tok-kw">else</span> =&gt; Kind.Unknown,</span>
<span class="line" id="L357">        } <span class="tok-kw">else</span> blk: {</span>
<span class="line" id="L358">            <span class="tok-kw">const</span> m = st.mode &amp; os.S.IFMT;</span>
<span class="line" id="L359">            <span class="tok-kw">switch</span> (m) {</span>
<span class="line" id="L360">                os.S.IFBLK =&gt; <span class="tok-kw">break</span> :blk Kind.BlockDevice,</span>
<span class="line" id="L361">                os.S.IFCHR =&gt; <span class="tok-kw">break</span> :blk Kind.CharacterDevice,</span>
<span class="line" id="L362">                os.S.IFDIR =&gt; <span class="tok-kw">break</span> :blk Kind.Directory,</span>
<span class="line" id="L363">                os.S.IFIFO =&gt; <span class="tok-kw">break</span> :blk Kind.NamedPipe,</span>
<span class="line" id="L364">                os.S.IFLNK =&gt; <span class="tok-kw">break</span> :blk Kind.SymLink,</span>
<span class="line" id="L365">                os.S.IFREG =&gt; <span class="tok-kw">break</span> :blk Kind.File,</span>
<span class="line" id="L366">                os.S.IFSOCK =&gt; <span class="tok-kw">break</span> :blk Kind.UnixDomainSocket,</span>
<span class="line" id="L367">                <span class="tok-kw">else</span> =&gt; {},</span>
<span class="line" id="L368">            }</span>
<span class="line" id="L369">            <span class="tok-kw">if</span> (builtin.os.tag == .solaris) <span class="tok-kw">switch</span> (m) {</span>
<span class="line" id="L370">                os.S.IFDOOR =&gt; <span class="tok-kw">break</span> :blk Kind.Door,</span>
<span class="line" id="L371">                os.S.IFPORT =&gt; <span class="tok-kw">break</span> :blk Kind.EventPort,</span>
<span class="line" id="L372">                <span class="tok-kw">else</span> =&gt; {},</span>
<span class="line" id="L373">            };</span>
<span class="line" id="L374"></span>
<span class="line" id="L375">            <span class="tok-kw">break</span> :blk .Unknown;</span>
<span class="line" id="L376">        };</span>
<span class="line" id="L377"></span>
<span class="line" id="L378">        <span class="tok-kw">return</span> Stat{</span>
<span class="line" id="L379">            .inode = st.ino,</span>
<span class="line" id="L380">            .size = <span class="tok-builtin">@bitCast</span>(<span class="tok-type">u64</span>, st.size),</span>
<span class="line" id="L381">            .mode = st.mode,</span>
<span class="line" id="L382">            .kind = kind,</span>
<span class="line" id="L383">            .atime = <span class="tok-builtin">@as</span>(<span class="tok-type">i128</span>, atime.tv_sec) * std.time.ns_per_s + atime.tv_nsec,</span>
<span class="line" id="L384">            .mtime = <span class="tok-builtin">@as</span>(<span class="tok-type">i128</span>, mtime.tv_sec) * std.time.ns_per_s + mtime.tv_nsec,</span>
<span class="line" id="L385">            .ctime = <span class="tok-builtin">@as</span>(<span class="tok-type">i128</span>, ctime.tv_sec) * std.time.ns_per_s + ctime.tv_nsec,</span>
<span class="line" id="L386">        };</span>
<span class="line" id="L387">    }</span>
<span class="line" id="L388"></span>
<span class="line" id="L389">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> ChmodError = std.os.FChmodError;</span>
<span class="line" id="L390"></span>
<span class="line" id="L391">    <span class="tok-comment">/// Changes the mode of the file.</span></span>
<span class="line" id="L392">    <span class="tok-comment">/// The process must have the correct privileges in order to do this</span></span>
<span class="line" id="L393">    <span class="tok-comment">/// successfully, or must have the effective user ID matching the owner</span></span>
<span class="line" id="L394">    <span class="tok-comment">/// of the file.</span></span>
<span class="line" id="L395">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">chmod</span>(self: File, new_mode: Mode) ChmodError!<span class="tok-type">void</span> {</span>
<span class="line" id="L396">        <span class="tok-kw">try</span> os.fchmod(self.handle, new_mode);</span>
<span class="line" id="L397">    }</span>
<span class="line" id="L398"></span>
<span class="line" id="L399">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> ChownError = std.os.FChownError;</span>
<span class="line" id="L400"></span>
<span class="line" id="L401">    <span class="tok-comment">/// Changes the owner and group of the file.</span></span>
<span class="line" id="L402">    <span class="tok-comment">/// The process must have the correct privileges in order to do this</span></span>
<span class="line" id="L403">    <span class="tok-comment">/// successfully. The group may be changed by the owner of the file to</span></span>
<span class="line" id="L404">    <span class="tok-comment">/// any group of which the owner is a member. If the owner or group is</span></span>
<span class="line" id="L405">    <span class="tok-comment">/// specified as `null`, the ID is not changed.</span></span>
<span class="line" id="L406">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">chown</span>(self: File, owner: ?Uid, group: ?Gid) ChownError!<span class="tok-type">void</span> {</span>
<span class="line" id="L407">        <span class="tok-kw">try</span> os.fchown(self.handle, owner, group);</span>
<span class="line" id="L408">    }</span>
<span class="line" id="L409"></span>
<span class="line" id="L410">    <span class="tok-comment">/// Cross-platform representation of permissions on a file.</span></span>
<span class="line" id="L411">    <span class="tok-comment">/// The `readonly` and `setReadonly` are the only methods available across all platforms.</span></span>
<span class="line" id="L412">    <span class="tok-comment">/// Platform-specific functionality is available through the `inner` field.</span></span>
<span class="line" id="L413">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> Permissions = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L414">        <span class="tok-comment">/// You may use the `inner` field to use platform-specific functionality</span></span>
<span class="line" id="L415">        inner: <span class="tok-kw">switch</span> (builtin.os.tag) {</span>
<span class="line" id="L416">            .windows =&gt; PermissionsWindows,</span>
<span class="line" id="L417">            <span class="tok-kw">else</span> =&gt; PermissionsUnix,</span>
<span class="line" id="L418">        },</span>
<span class="line" id="L419"></span>
<span class="line" id="L420">        <span class="tok-kw">const</span> Self = <span class="tok-builtin">@This</span>();</span>
<span class="line" id="L421"></span>
<span class="line" id="L422">        <span class="tok-comment">/// Returns `true` if permissions represent an unwritable file.</span></span>
<span class="line" id="L423">        <span class="tok-comment">/// On Unix, `true` is returned only if no class has write permissions.</span></span>
<span class="line" id="L424">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">readOnly</span>(self: Self) <span class="tok-type">bool</span> {</span>
<span class="line" id="L425">            <span class="tok-kw">return</span> self.inner.readOnly();</span>
<span class="line" id="L426">        }</span>
<span class="line" id="L427"></span>
<span class="line" id="L428">        <span class="tok-comment">/// Sets whether write permissions are provided.</span></span>
<span class="line" id="L429">        <span class="tok-comment">/// On Unix, this affects *all* classes. If this is undesired, use `unixSet`</span></span>
<span class="line" id="L430">        <span class="tok-comment">/// This method *DOES NOT* set permissions on the filesystem: use `File.setPermissions(permissions)`</span></span>
<span class="line" id="L431">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">setReadOnly</span>(self: *Self, read_only: <span class="tok-type">bool</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L432">            self.inner.setReadOnly(read_only);</span>
<span class="line" id="L433">        }</span>
<span class="line" id="L434">    };</span>
<span class="line" id="L435"></span>
<span class="line" id="L436">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> PermissionsWindows = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L437">        attributes: os.windows.DWORD,</span>
<span class="line" id="L438"></span>
<span class="line" id="L439">        <span class="tok-kw">const</span> Self = <span class="tok-builtin">@This</span>();</span>
<span class="line" id="L440"></span>
<span class="line" id="L441">        <span class="tok-comment">/// Returns `true` if permissions represent an unwritable file.</span></span>
<span class="line" id="L442">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">readOnly</span>(self: Self) <span class="tok-type">bool</span> {</span>
<span class="line" id="L443">            <span class="tok-kw">return</span> self.attributes &amp; os.windows.FILE_ATTRIBUTE_READONLY != <span class="tok-number">0</span>;</span>
<span class="line" id="L444">        }</span>
<span class="line" id="L445"></span>
<span class="line" id="L446">        <span class="tok-comment">/// Sets whether write permissions are provided.</span></span>
<span class="line" id="L447">        <span class="tok-comment">/// This method *DOES NOT* set permissions on the filesystem: use `File.setPermissions(permissions)`</span></span>
<span class="line" id="L448">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">setReadOnly</span>(self: *Self, read_only: <span class="tok-type">bool</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L449">            <span class="tok-kw">if</span> (read_only) {</span>
<span class="line" id="L450">                self.attributes |= os.windows.FILE_ATTRIBUTE_READONLY;</span>
<span class="line" id="L451">            } <span class="tok-kw">else</span> {</span>
<span class="line" id="L452">                self.attributes &amp;= ~<span class="tok-builtin">@as</span>(os.windows.DWORD, os.windows.FILE_ATTRIBUTE_READONLY);</span>
<span class="line" id="L453">            }</span>
<span class="line" id="L454">        }</span>
<span class="line" id="L455">    };</span>
<span class="line" id="L456"></span>
<span class="line" id="L457">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> PermissionsUnix = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L458">        mode: Mode,</span>
<span class="line" id="L459"></span>
<span class="line" id="L460">        <span class="tok-kw">const</span> Self = <span class="tok-builtin">@This</span>();</span>
<span class="line" id="L461"></span>
<span class="line" id="L462">        <span class="tok-comment">/// Returns `true` if permissions represent an unwritable file.</span></span>
<span class="line" id="L463">        <span class="tok-comment">/// `true` is returned only if no class has write permissions.</span></span>
<span class="line" id="L464">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">readOnly</span>(self: Self) <span class="tok-type">bool</span> {</span>
<span class="line" id="L465">            <span class="tok-kw">return</span> self.mode &amp; <span class="tok-number">0o222</span> == <span class="tok-number">0</span>;</span>
<span class="line" id="L466">        }</span>
<span class="line" id="L467"></span>
<span class="line" id="L468">        <span class="tok-comment">/// Sets whether write permissions are provided.</span></span>
<span class="line" id="L469">        <span class="tok-comment">/// This affects *all* classes. If this is undesired, use `unixSet`</span></span>
<span class="line" id="L470">        <span class="tok-comment">/// This method *DOES NOT* set permissions on the filesystem: use `File.setPermissions(permissions)`</span></span>
<span class="line" id="L471">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">setReadOnly</span>(self: *Self, read_only: <span class="tok-type">bool</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L472">            <span class="tok-kw">if</span> (read_only) {</span>
<span class="line" id="L473">                self.mode &amp;= ~<span class="tok-builtin">@as</span>(Mode, <span class="tok-number">0o222</span>);</span>
<span class="line" id="L474">            } <span class="tok-kw">else</span> {</span>
<span class="line" id="L475">                self.mode |= <span class="tok-builtin">@as</span>(Mode, <span class="tok-number">0o222</span>);</span>
<span class="line" id="L476">            }</span>
<span class="line" id="L477">        }</span>
<span class="line" id="L478"></span>
<span class="line" id="L479">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> Class = <span class="tok-kw">enum</span>(<span class="tok-type">u2</span>) {</span>
<span class="line" id="L480">            user = <span class="tok-number">2</span>,</span>
<span class="line" id="L481">            group = <span class="tok-number">1</span>,</span>
<span class="line" id="L482">            other = <span class="tok-number">0</span>,</span>
<span class="line" id="L483">        };</span>
<span class="line" id="L484"></span>
<span class="line" id="L485">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> Permission = <span class="tok-kw">enum</span>(<span class="tok-type">u3</span>) {</span>
<span class="line" id="L486">            read = <span class="tok-number">0o4</span>,</span>
<span class="line" id="L487">            write = <span class="tok-number">0o2</span>,</span>
<span class="line" id="L488">            execute = <span class="tok-number">0o1</span>,</span>
<span class="line" id="L489">        };</span>
<span class="line" id="L490"></span>
<span class="line" id="L491">        <span class="tok-comment">/// Returns `true` if the chosen class has the selected permission.</span></span>
<span class="line" id="L492">        <span class="tok-comment">/// This method is only available on Unix platforms.</span></span>
<span class="line" id="L493">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">unixHas</span>(self: Self, class: Class, permission: Permission) <span class="tok-type">bool</span> {</span>
<span class="line" id="L494">            <span class="tok-kw">const</span> mask = <span class="tok-builtin">@as</span>(Mode, <span class="tok-builtin">@enumToInt</span>(permission)) &lt;&lt; <span class="tok-builtin">@as</span>(<span class="tok-type">u3</span>, <span class="tok-builtin">@enumToInt</span>(class)) * <span class="tok-number">3</span>;</span>
<span class="line" id="L495">            <span class="tok-kw">return</span> self.mode &amp; mask != <span class="tok-number">0</span>;</span>
<span class="line" id="L496">        }</span>
<span class="line" id="L497"></span>
<span class="line" id="L498">        <span class="tok-comment">/// Sets the permissions for the chosen class. Any permissions set to `null` are left unchanged.</span></span>
<span class="line" id="L499">        <span class="tok-comment">/// This method *DOES NOT* set permissions on the filesystem: use `File.setPermissions(permissions)`</span></span>
<span class="line" id="L500">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">unixSet</span>(self: *Self, class: Class, permissions: <span class="tok-kw">struct</span> {</span>
<span class="line" id="L501">            read: ?<span class="tok-type">bool</span> = <span class="tok-null">null</span>,</span>
<span class="line" id="L502">            write: ?<span class="tok-type">bool</span> = <span class="tok-null">null</span>,</span>
<span class="line" id="L503">            execute: ?<span class="tok-type">bool</span> = <span class="tok-null">null</span>,</span>
<span class="line" id="L504">        }) <span class="tok-type">void</span> {</span>
<span class="line" id="L505">            <span class="tok-kw">const</span> shift = <span class="tok-builtin">@as</span>(<span class="tok-type">u3</span>, <span class="tok-builtin">@enumToInt</span>(class)) * <span class="tok-number">3</span>;</span>
<span class="line" id="L506">            <span class="tok-kw">if</span> (permissions.read) |r| {</span>
<span class="line" id="L507">                <span class="tok-kw">if</span> (r) {</span>
<span class="line" id="L508">                    self.mode |= <span class="tok-builtin">@as</span>(Mode, <span class="tok-number">0o4</span>) &lt;&lt; shift;</span>
<span class="line" id="L509">                } <span class="tok-kw">else</span> {</span>
<span class="line" id="L510">                    self.mode &amp;= ~(<span class="tok-builtin">@as</span>(Mode, <span class="tok-number">0o4</span>) &lt;&lt; shift);</span>
<span class="line" id="L511">                }</span>
<span class="line" id="L512">            }</span>
<span class="line" id="L513">            <span class="tok-kw">if</span> (permissions.write) |w| {</span>
<span class="line" id="L514">                <span class="tok-kw">if</span> (w) {</span>
<span class="line" id="L515">                    self.mode |= <span class="tok-builtin">@as</span>(Mode, <span class="tok-number">0o2</span>) &lt;&lt; shift;</span>
<span class="line" id="L516">                } <span class="tok-kw">else</span> {</span>
<span class="line" id="L517">                    self.mode &amp;= ~(<span class="tok-builtin">@as</span>(Mode, <span class="tok-number">0o2</span>) &lt;&lt; shift);</span>
<span class="line" id="L518">                }</span>
<span class="line" id="L519">            }</span>
<span class="line" id="L520">            <span class="tok-kw">if</span> (permissions.execute) |x| {</span>
<span class="line" id="L521">                <span class="tok-kw">if</span> (x) {</span>
<span class="line" id="L522">                    self.mode |= <span class="tok-builtin">@as</span>(Mode, <span class="tok-number">0o1</span>) &lt;&lt; shift;</span>
<span class="line" id="L523">                } <span class="tok-kw">else</span> {</span>
<span class="line" id="L524">                    self.mode &amp;= ~(<span class="tok-builtin">@as</span>(Mode, <span class="tok-number">0o1</span>) &lt;&lt; shift);</span>
<span class="line" id="L525">                }</span>
<span class="line" id="L526">            }</span>
<span class="line" id="L527">        }</span>
<span class="line" id="L528"></span>
<span class="line" id="L529">        <span class="tok-comment">/// Returns a `Permissions` struct representing the permissions from the passed mode.</span></span>
<span class="line" id="L530">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">unixNew</span>(new_mode: Mode) Self {</span>
<span class="line" id="L531">            <span class="tok-kw">return</span> Self{</span>
<span class="line" id="L532">                .mode = new_mode,</span>
<span class="line" id="L533">            };</span>
<span class="line" id="L534">        }</span>
<span class="line" id="L535">    };</span>
<span class="line" id="L536"></span>
<span class="line" id="L537">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> SetPermissionsError = ChmodError;</span>
<span class="line" id="L538"></span>
<span class="line" id="L539">    <span class="tok-comment">/// Sets permissions according to the provided `Permissions` struct.</span></span>
<span class="line" id="L540">    <span class="tok-comment">/// This method is *NOT* available on WASI</span></span>
<span class="line" id="L541">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">setPermissions</span>(self: File, permissions: Permissions) SetPermissionsError!<span class="tok-type">void</span> {</span>
<span class="line" id="L542">        <span class="tok-kw">switch</span> (builtin.os.tag) {</span>
<span class="line" id="L543">            .windows =&gt; {</span>
<span class="line" id="L544">                <span class="tok-kw">var</span> io_status_block: windows.IO_STATUS_BLOCK = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L545">                <span class="tok-kw">var</span> info = windows.FILE_BASIC_INFORMATION{</span>
<span class="line" id="L546">                    .CreationTime = <span class="tok-number">0</span>,</span>
<span class="line" id="L547">                    .LastAccessTime = <span class="tok-number">0</span>,</span>
<span class="line" id="L548">                    .LastWriteTime = <span class="tok-number">0</span>,</span>
<span class="line" id="L549">                    .ChangeTime = <span class="tok-number">0</span>,</span>
<span class="line" id="L550">                    .FileAttributes = permissions.inner.attributes,</span>
<span class="line" id="L551">                };</span>
<span class="line" id="L552">                <span class="tok-kw">const</span> rc = windows.ntdll.NtSetInformationFile(</span>
<span class="line" id="L553">                    self.handle,</span>
<span class="line" id="L554">                    &amp;io_status_block,</span>
<span class="line" id="L555">                    &amp;info,</span>
<span class="line" id="L556">                    <span class="tok-builtin">@sizeOf</span>(windows.FILE_BASIC_INFORMATION),</span>
<span class="line" id="L557">                    .FileBasicInformation,</span>
<span class="line" id="L558">                );</span>
<span class="line" id="L559">                <span class="tok-kw">switch</span> (rc) {</span>
<span class="line" id="L560">                    .SUCCESS =&gt; <span class="tok-kw">return</span>,</span>
<span class="line" id="L561">                    .INVALID_HANDLE =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L562">                    .ACCESS_DENIED =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.AccessDenied,</span>
<span class="line" id="L563">                    <span class="tok-kw">else</span> =&gt; <span class="tok-kw">return</span> windows.unexpectedStatus(rc),</span>
<span class="line" id="L564">                }</span>
<span class="line" id="L565">            },</span>
<span class="line" id="L566">            .wasi =&gt; <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;Unsupported OS&quot;</span>), <span class="tok-comment">// Wasi filesystem does not *yet* support chmod</span>
</span>
<span class="line" id="L567">            <span class="tok-kw">else</span> =&gt; {</span>
<span class="line" id="L568">                <span class="tok-kw">try</span> self.chmod(permissions.inner.mode);</span>
<span class="line" id="L569">            },</span>
<span class="line" id="L570">        }</span>
<span class="line" id="L571">    }</span>
<span class="line" id="L572"></span>
<span class="line" id="L573">    <span class="tok-comment">/// Cross-platform representation of file metadata.</span></span>
<span class="line" id="L574">    <span class="tok-comment">/// Platform-specific functionality is available through the `inner` field.</span></span>
<span class="line" id="L575">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> Metadata = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L576">        <span class="tok-comment">/// You may use the `inner` field to use platform-specific functionality</span></span>
<span class="line" id="L577">        inner: <span class="tok-kw">switch</span> (builtin.os.tag) {</span>
<span class="line" id="L578">            .windows =&gt; MetadataWindows,</span>
<span class="line" id="L579">            .linux =&gt; MetadataLinux,</span>
<span class="line" id="L580">            <span class="tok-kw">else</span> =&gt; MetadataUnix,</span>
<span class="line" id="L581">        },</span>
<span class="line" id="L582"></span>
<span class="line" id="L583">        <span class="tok-kw">const</span> Self = <span class="tok-builtin">@This</span>();</span>
<span class="line" id="L584"></span>
<span class="line" id="L585">        <span class="tok-comment">/// Returns the size of the file</span></span>
<span class="line" id="L586">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">size</span>(self: Self) <span class="tok-type">u64</span> {</span>
<span class="line" id="L587">            <span class="tok-kw">return</span> self.inner.size();</span>
<span class="line" id="L588">        }</span>
<span class="line" id="L589"></span>
<span class="line" id="L590">        <span class="tok-comment">/// Returns a `Permissions` struct, representing the permissions on the file</span></span>
<span class="line" id="L591">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">permissions</span>(self: Self) Permissions {</span>
<span class="line" id="L592">            <span class="tok-kw">return</span> self.inner.permissions();</span>
<span class="line" id="L593">        }</span>
<span class="line" id="L594"></span>
<span class="line" id="L595">        <span class="tok-comment">/// Returns the `Kind` of file.</span></span>
<span class="line" id="L596">        <span class="tok-comment">/// On Windows, can only return: `.File`, `.Directory`, `.SymLink` or `.Unknown`</span></span>
<span class="line" id="L597">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">kind</span>(self: Self) Kind {</span>
<span class="line" id="L598">            <span class="tok-kw">return</span> self.inner.kind();</span>
<span class="line" id="L599">        }</span>
<span class="line" id="L600"></span>
<span class="line" id="L601">        <span class="tok-comment">/// Returns the last time the file was accessed in nanoseconds since UTC 1970-01-01</span></span>
<span class="line" id="L602">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">accessed</span>(self: Self) <span class="tok-type">i128</span> {</span>
<span class="line" id="L603">            <span class="tok-kw">return</span> self.inner.accessed();</span>
<span class="line" id="L604">        }</span>
<span class="line" id="L605"></span>
<span class="line" id="L606">        <span class="tok-comment">/// Returns the time the file was modified in nanoseconds since UTC 1970-01-01</span></span>
<span class="line" id="L607">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">modified</span>(self: Self) <span class="tok-type">i128</span> {</span>
<span class="line" id="L608">            <span class="tok-kw">return</span> self.inner.modified();</span>
<span class="line" id="L609">        }</span>
<span class="line" id="L610"></span>
<span class="line" id="L611">        <span class="tok-comment">/// Returns the time the file was created in nanoseconds since UTC 1970-01-01</span></span>
<span class="line" id="L612">        <span class="tok-comment">/// On Windows, this cannot return null</span></span>
<span class="line" id="L613">        <span class="tok-comment">/// On Linux, this returns null if the filesystem does not support creation times, or if the kernel is older than 4.11</span></span>
<span class="line" id="L614">        <span class="tok-comment">/// On Unices, this returns null if the filesystem or OS does not support creation times</span></span>
<span class="line" id="L615">        <span class="tok-comment">/// On MacOS, this returns the ctime if the filesystem does not support creation times; this is insanity, and yet another reason to hate on Apple</span></span>
<span class="line" id="L616">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">created</span>(self: Self) ?<span class="tok-type">i128</span> {</span>
<span class="line" id="L617">            <span class="tok-kw">return</span> self.inner.created();</span>
<span class="line" id="L618">        }</span>
<span class="line" id="L619">    };</span>
<span class="line" id="L620"></span>
<span class="line" id="L621">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> MetadataUnix = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L622">        stat: os.Stat,</span>
<span class="line" id="L623"></span>
<span class="line" id="L624">        <span class="tok-kw">const</span> Self = <span class="tok-builtin">@This</span>();</span>
<span class="line" id="L625"></span>
<span class="line" id="L626">        <span class="tok-comment">/// Returns the size of the file</span></span>
<span class="line" id="L627">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">size</span>(self: Self) <span class="tok-type">u64</span> {</span>
<span class="line" id="L628">            <span class="tok-kw">return</span> <span class="tok-builtin">@intCast</span>(<span class="tok-type">u64</span>, self.stat.size);</span>
<span class="line" id="L629">        }</span>
<span class="line" id="L630"></span>
<span class="line" id="L631">        <span class="tok-comment">/// Returns a `Permissions` struct, representing the permissions on the file</span></span>
<span class="line" id="L632">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">permissions</span>(self: Self) Permissions {</span>
<span class="line" id="L633">            <span class="tok-kw">return</span> Permissions{ .inner = PermissionsUnix{ .mode = self.stat.mode } };</span>
<span class="line" id="L634">        }</span>
<span class="line" id="L635"></span>
<span class="line" id="L636">        <span class="tok-comment">/// Returns the `Kind` of the file</span></span>
<span class="line" id="L637">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">kind</span>(self: Self) Kind {</span>
<span class="line" id="L638">            <span class="tok-kw">if</span> (builtin.os.tag == .wasi <span class="tok-kw">and</span> !builtin.link_libc) <span class="tok-kw">return</span> <span class="tok-kw">switch</span> (self.stat.filetype) {</span>
<span class="line" id="L639">                .BLOCK_DEVICE =&gt; Kind.BlockDevice,</span>
<span class="line" id="L640">                .CHARACTER_DEVICE =&gt; Kind.CharacterDevice,</span>
<span class="line" id="L641">                .DIRECTORY =&gt; Kind.Directory,</span>
<span class="line" id="L642">                .SYMBOLIC_LINK =&gt; Kind.SymLink,</span>
<span class="line" id="L643">                .REGULAR_FILE =&gt; Kind.File,</span>
<span class="line" id="L644">                .SOCKET_STREAM, .SOCKET_DGRAM =&gt; Kind.UnixDomainSocket,</span>
<span class="line" id="L645">                <span class="tok-kw">else</span> =&gt; Kind.Unknown,</span>
<span class="line" id="L646">            };</span>
<span class="line" id="L647"></span>
<span class="line" id="L648">            <span class="tok-kw">const</span> m = self.stat.mode &amp; os.S.IFMT;</span>
<span class="line" id="L649"></span>
<span class="line" id="L650">            <span class="tok-kw">switch</span> (m) {</span>
<span class="line" id="L651">                os.S.IFBLK =&gt; <span class="tok-kw">return</span> Kind.BlockDevice,</span>
<span class="line" id="L652">                os.S.IFCHR =&gt; <span class="tok-kw">return</span> Kind.CharacterDevice,</span>
<span class="line" id="L653">                os.S.IFDIR =&gt; <span class="tok-kw">return</span> Kind.Directory,</span>
<span class="line" id="L654">                os.S.IFIFO =&gt; <span class="tok-kw">return</span> Kind.NamedPipe,</span>
<span class="line" id="L655">                os.S.IFLNK =&gt; <span class="tok-kw">return</span> Kind.SymLink,</span>
<span class="line" id="L656">                os.S.IFREG =&gt; <span class="tok-kw">return</span> Kind.File,</span>
<span class="line" id="L657">                os.S.IFSOCK =&gt; <span class="tok-kw">return</span> Kind.UnixDomainSocket,</span>
<span class="line" id="L658">                <span class="tok-kw">else</span> =&gt; {},</span>
<span class="line" id="L659">            }</span>
<span class="line" id="L660"></span>
<span class="line" id="L661">            <span class="tok-kw">if</span> (builtin.os.tag == .solaris) <span class="tok-kw">switch</span> (m) {</span>
<span class="line" id="L662">                os.S.IFDOOR =&gt; <span class="tok-kw">return</span> Kind.Door,</span>
<span class="line" id="L663">                os.S.IFPORT =&gt; <span class="tok-kw">return</span> Kind.EventPort,</span>
<span class="line" id="L664">                <span class="tok-kw">else</span> =&gt; {},</span>
<span class="line" id="L665">            };</span>
<span class="line" id="L666"></span>
<span class="line" id="L667">            <span class="tok-kw">return</span> .Unknown;</span>
<span class="line" id="L668">        }</span>
<span class="line" id="L669"></span>
<span class="line" id="L670">        <span class="tok-comment">/// Returns the last time the file was accessed in nanoseconds since UTC 1970-01-01</span></span>
<span class="line" id="L671">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">accessed</span>(self: Self) <span class="tok-type">i128</span> {</span>
<span class="line" id="L672">            <span class="tok-kw">const</span> atime = self.stat.atime();</span>
<span class="line" id="L673">            <span class="tok-kw">return</span> <span class="tok-builtin">@as</span>(<span class="tok-type">i128</span>, atime.tv_sec) * std.time.ns_per_s + atime.tv_nsec;</span>
<span class="line" id="L674">        }</span>
<span class="line" id="L675"></span>
<span class="line" id="L676">        <span class="tok-comment">/// Returns the last time the file was modified in nanoseconds since UTC 1970-01-01</span></span>
<span class="line" id="L677">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">modified</span>(self: Self) <span class="tok-type">i128</span> {</span>
<span class="line" id="L678">            <span class="tok-kw">const</span> mtime = self.stat.mtime();</span>
<span class="line" id="L679">            <span class="tok-kw">return</span> <span class="tok-builtin">@as</span>(<span class="tok-type">i128</span>, mtime.tv_sec) * std.time.ns_per_s + mtime.tv_nsec;</span>
<span class="line" id="L680">        }</span>
<span class="line" id="L681"></span>
<span class="line" id="L682">        <span class="tok-comment">/// Returns the time the file was created in nanoseconds since UTC 1970-01-01</span></span>
<span class="line" id="L683">        <span class="tok-comment">/// Returns null if this is not supported by the OS or filesystem</span></span>
<span class="line" id="L684">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">created</span>(self: Self) ?<span class="tok-type">i128</span> {</span>
<span class="line" id="L685">            <span class="tok-kw">if</span> (!<span class="tok-builtin">@hasDecl</span>(<span class="tok-builtin">@TypeOf</span>(self.stat), <span class="tok-str">&quot;birthtime&quot;</span>)) <span class="tok-kw">return</span> <span class="tok-null">null</span>;</span>
<span class="line" id="L686">            <span class="tok-kw">const</span> birthtime = self.stat.birthtime();</span>
<span class="line" id="L687"></span>
<span class="line" id="L688">            <span class="tok-comment">// If the filesystem doesn't support this the value *should* be:</span>
</span>
<span class="line" id="L689">            <span class="tok-comment">// On FreeBSD: tv_nsec = 0, tv_sec = -1</span>
</span>
<span class="line" id="L690">            <span class="tok-comment">// On NetBSD and OpenBSD: tv_nsec = 0, tv_sec = 0</span>
</span>
<span class="line" id="L691">            <span class="tok-comment">// On MacOS, it is set to ctime -- we cannot detect this!!</span>
</span>
<span class="line" id="L692">            <span class="tok-kw">switch</span> (builtin.os.tag) {</span>
<span class="line" id="L693">                .freebsd =&gt; <span class="tok-kw">if</span> (birthtime.tv_sec == -<span class="tok-number">1</span> <span class="tok-kw">and</span> birthtime.tv_nsec == <span class="tok-number">0</span>) <span class="tok-kw">return</span> <span class="tok-null">null</span>,</span>
<span class="line" id="L694">                .netbsd, .openbsd =&gt; <span class="tok-kw">if</span> (birthtime.tv_sec == <span class="tok-number">0</span> <span class="tok-kw">and</span> birthtime.tv_nsec == <span class="tok-number">0</span>) <span class="tok-kw">return</span> <span class="tok-null">null</span>,</span>
<span class="line" id="L695">                .macos =&gt; {},</span>
<span class="line" id="L696">                <span class="tok-kw">else</span> =&gt; <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;Creation time detection not implemented for OS&quot;</span>),</span>
<span class="line" id="L697">            }</span>
<span class="line" id="L698"></span>
<span class="line" id="L699">            <span class="tok-kw">return</span> <span class="tok-builtin">@as</span>(<span class="tok-type">i128</span>, birthtime.tv_sec) * std.time.ns_per_s + birthtime.tv_nsec;</span>
<span class="line" id="L700">        }</span>
<span class="line" id="L701">    };</span>
<span class="line" id="L702"></span>
<span class="line" id="L703">    <span class="tok-comment">/// `MetadataUnix`, but using Linux's `statx` syscall.</span></span>
<span class="line" id="L704">    <span class="tok-comment">/// On Linux versions below 4.11, `statx` will be filled with data from stat.</span></span>
<span class="line" id="L705">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> MetadataLinux = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L706">        statx: os.linux.Statx,</span>
<span class="line" id="L707"></span>
<span class="line" id="L708">        <span class="tok-kw">const</span> Self = <span class="tok-builtin">@This</span>();</span>
<span class="line" id="L709"></span>
<span class="line" id="L710">        <span class="tok-comment">/// Returns the size of the file</span></span>
<span class="line" id="L711">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">size</span>(self: Self) <span class="tok-type">u64</span> {</span>
<span class="line" id="L712">            <span class="tok-kw">return</span> self.statx.size;</span>
<span class="line" id="L713">        }</span>
<span class="line" id="L714"></span>
<span class="line" id="L715">        <span class="tok-comment">/// Returns a `Permissions` struct, representing the permissions on the file</span></span>
<span class="line" id="L716">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">permissions</span>(self: Self) Permissions {</span>
<span class="line" id="L717">            <span class="tok-kw">return</span> Permissions{ .inner = PermissionsUnix{ .mode = self.statx.mode } };</span>
<span class="line" id="L718">        }</span>
<span class="line" id="L719"></span>
<span class="line" id="L720">        <span class="tok-comment">/// Returns the `Kind` of the file</span></span>
<span class="line" id="L721">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">kind</span>(self: Self) Kind {</span>
<span class="line" id="L722">            <span class="tok-kw">const</span> m = self.statx.mode &amp; os.S.IFMT;</span>
<span class="line" id="L723"></span>
<span class="line" id="L724">            <span class="tok-kw">switch</span> (m) {</span>
<span class="line" id="L725">                os.S.IFBLK =&gt; <span class="tok-kw">return</span> Kind.BlockDevice,</span>
<span class="line" id="L726">                os.S.IFCHR =&gt; <span class="tok-kw">return</span> Kind.CharacterDevice,</span>
<span class="line" id="L727">                os.S.IFDIR =&gt; <span class="tok-kw">return</span> Kind.Directory,</span>
<span class="line" id="L728">                os.S.IFIFO =&gt; <span class="tok-kw">return</span> Kind.NamedPipe,</span>
<span class="line" id="L729">                os.S.IFLNK =&gt; <span class="tok-kw">return</span> Kind.SymLink,</span>
<span class="line" id="L730">                os.S.IFREG =&gt; <span class="tok-kw">return</span> Kind.File,</span>
<span class="line" id="L731">                os.S.IFSOCK =&gt; <span class="tok-kw">return</span> Kind.UnixDomainSocket,</span>
<span class="line" id="L732">                <span class="tok-kw">else</span> =&gt; {},</span>
<span class="line" id="L733">            }</span>
<span class="line" id="L734"></span>
<span class="line" id="L735">            <span class="tok-kw">return</span> .Unknown;</span>
<span class="line" id="L736">        }</span>
<span class="line" id="L737"></span>
<span class="line" id="L738">        <span class="tok-comment">/// Returns the last time the file was accessed in nanoseconds since UTC 1970-01-01</span></span>
<span class="line" id="L739">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">accessed</span>(self: Self) <span class="tok-type">i128</span> {</span>
<span class="line" id="L740">            <span class="tok-kw">return</span> <span class="tok-builtin">@as</span>(<span class="tok-type">i128</span>, self.statx.atime.tv_sec) * std.time.ns_per_s + self.statx.atime.tv_nsec;</span>
<span class="line" id="L741">        }</span>
<span class="line" id="L742"></span>
<span class="line" id="L743">        <span class="tok-comment">/// Returns the last time the file was modified in nanoseconds since UTC 1970-01-01</span></span>
<span class="line" id="L744">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">modified</span>(self: Self) <span class="tok-type">i128</span> {</span>
<span class="line" id="L745">            <span class="tok-kw">return</span> <span class="tok-builtin">@as</span>(<span class="tok-type">i128</span>, self.statx.mtime.tv_sec) * std.time.ns_per_s + self.statx.mtime.tv_nsec;</span>
<span class="line" id="L746">        }</span>
<span class="line" id="L747"></span>
<span class="line" id="L748">        <span class="tok-comment">/// Returns the time the file was created in nanoseconds since UTC 1970-01-01</span></span>
<span class="line" id="L749">        <span class="tok-comment">/// Returns null if this is not supported by the filesystem, or on kernels before than version 4.11</span></span>
<span class="line" id="L750">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">created</span>(self: Self) ?<span class="tok-type">i128</span> {</span>
<span class="line" id="L751">            <span class="tok-kw">if</span> (self.statx.mask &amp; os.linux.STATX_BTIME == <span class="tok-number">0</span>) <span class="tok-kw">return</span> <span class="tok-null">null</span>;</span>
<span class="line" id="L752">            <span class="tok-kw">return</span> <span class="tok-builtin">@as</span>(<span class="tok-type">i128</span>, self.statx.btime.tv_sec) * std.time.ns_per_s + self.statx.btime.tv_nsec;</span>
<span class="line" id="L753">        }</span>
<span class="line" id="L754">    };</span>
<span class="line" id="L755"></span>
<span class="line" id="L756">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> MetadataWindows = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L757">        attributes: windows.DWORD,</span>
<span class="line" id="L758">        reparse_tag: windows.DWORD,</span>
<span class="line" id="L759">        _size: <span class="tok-type">u64</span>,</span>
<span class="line" id="L760">        access_time: <span class="tok-type">i128</span>,</span>
<span class="line" id="L761">        modified_time: <span class="tok-type">i128</span>,</span>
<span class="line" id="L762">        creation_time: <span class="tok-type">i128</span>,</span>
<span class="line" id="L763"></span>
<span class="line" id="L764">        <span class="tok-kw">const</span> Self = <span class="tok-builtin">@This</span>();</span>
<span class="line" id="L765"></span>
<span class="line" id="L766">        <span class="tok-comment">/// Returns the size of the file</span></span>
<span class="line" id="L767">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">size</span>(self: Self) <span class="tok-type">u64</span> {</span>
<span class="line" id="L768">            <span class="tok-kw">return</span> self._size;</span>
<span class="line" id="L769">        }</span>
<span class="line" id="L770"></span>
<span class="line" id="L771">        <span class="tok-comment">/// Returns a `Permissions` struct, representing the permissions on the file</span></span>
<span class="line" id="L772">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">permissions</span>(self: Self) Permissions {</span>
<span class="line" id="L773">            <span class="tok-kw">return</span> Permissions{ .inner = PermissionsWindows{ .attributes = self.attributes } };</span>
<span class="line" id="L774">        }</span>
<span class="line" id="L775"></span>
<span class="line" id="L776">        <span class="tok-comment">/// Returns the `Kind` of the file.</span></span>
<span class="line" id="L777">        <span class="tok-comment">/// Can only return: `.File`, `.Directory`, `.SymLink` or `.Unknown`</span></span>
<span class="line" id="L778">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">kind</span>(self: Self) Kind {</span>
<span class="line" id="L779">            <span class="tok-kw">if</span> (self.attributes &amp; windows.FILE_ATTRIBUTE_REPARSE_POINT != <span class="tok-number">0</span>) {</span>
<span class="line" id="L780">                <span class="tok-kw">if</span> (self.reparse_tag &amp; <span class="tok-number">0x20000000</span> != <span class="tok-number">0</span>) {</span>
<span class="line" id="L781">                    <span class="tok-kw">return</span> .SymLink;</span>
<span class="line" id="L782">                }</span>
<span class="line" id="L783">            } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (self.attributes &amp; windows.FILE_ATTRIBUTE_DIRECTORY != <span class="tok-number">0</span>) {</span>
<span class="line" id="L784">                <span class="tok-kw">return</span> .Directory;</span>
<span class="line" id="L785">            } <span class="tok-kw">else</span> {</span>
<span class="line" id="L786">                <span class="tok-kw">return</span> .File;</span>
<span class="line" id="L787">            }</span>
<span class="line" id="L788">            <span class="tok-kw">return</span> .Unknown;</span>
<span class="line" id="L789">        }</span>
<span class="line" id="L790"></span>
<span class="line" id="L791">        <span class="tok-comment">/// Returns the last time the file was accessed in nanoseconds since UTC 1970-01-01</span></span>
<span class="line" id="L792">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">accessed</span>(self: Self) <span class="tok-type">i128</span> {</span>
<span class="line" id="L793">            <span class="tok-kw">return</span> self.access_time;</span>
<span class="line" id="L794">        }</span>
<span class="line" id="L795"></span>
<span class="line" id="L796">        <span class="tok-comment">/// Returns the time the file was modified in nanoseconds since UTC 1970-01-01</span></span>
<span class="line" id="L797">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">modified</span>(self: Self) <span class="tok-type">i128</span> {</span>
<span class="line" id="L798">            <span class="tok-kw">return</span> self.modified_time;</span>
<span class="line" id="L799">        }</span>
<span class="line" id="L800"></span>
<span class="line" id="L801">        <span class="tok-comment">/// Returns the time the file was created in nanoseconds since UTC 1970-01-01</span></span>
<span class="line" id="L802">        <span class="tok-comment">/// This never returns null, only returning an optional for compatibility with other OSes</span></span>
<span class="line" id="L803">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">created</span>(self: Self) ?<span class="tok-type">i128</span> {</span>
<span class="line" id="L804">            <span class="tok-kw">return</span> self.creation_time;</span>
<span class="line" id="L805">        }</span>
<span class="line" id="L806">    };</span>
<span class="line" id="L807"></span>
<span class="line" id="L808">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> MetadataError = os.FStatError;</span>
<span class="line" id="L809"></span>
<span class="line" id="L810">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">metadata</span>(self: File) MetadataError!Metadata {</span>
<span class="line" id="L811">        <span class="tok-kw">return</span> Metadata{</span>
<span class="line" id="L812">            .inner = <span class="tok-kw">switch</span> (builtin.os.tag) {</span>
<span class="line" id="L813">                .windows =&gt; blk: {</span>
<span class="line" id="L814">                    <span class="tok-kw">var</span> io_status_block: windows.IO_STATUS_BLOCK = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L815">                    <span class="tok-kw">var</span> info: windows.FILE_ALL_INFORMATION = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L816"></span>
<span class="line" id="L817">                    <span class="tok-kw">const</span> rc = windows.ntdll.NtQueryInformationFile(self.handle, &amp;io_status_block, &amp;info, <span class="tok-builtin">@sizeOf</span>(windows.FILE_ALL_INFORMATION), .FileAllInformation);</span>
<span class="line" id="L818">                    <span class="tok-kw">switch</span> (rc) {</span>
<span class="line" id="L819">                        .SUCCESS =&gt; {},</span>
<span class="line" id="L820">                        .BUFFER_OVERFLOW =&gt; {},</span>
<span class="line" id="L821">                        .INVALID_PARAMETER =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L822">                        .ACCESS_DENIED =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.AccessDenied,</span>
<span class="line" id="L823">                        <span class="tok-kw">else</span> =&gt; <span class="tok-kw">return</span> windows.unexpectedStatus(rc),</span>
<span class="line" id="L824">                    }</span>
<span class="line" id="L825"></span>
<span class="line" id="L826">                    <span class="tok-kw">const</span> reparse_tag: windows.DWORD = reparse_blk: {</span>
<span class="line" id="L827">                        <span class="tok-kw">if</span> (info.BasicInformation.FileAttributes &amp; windows.FILE_ATTRIBUTE_REPARSE_POINT != <span class="tok-number">0</span>) {</span>
<span class="line" id="L828">                            <span class="tok-kw">var</span> reparse_buf: [windows.MAXIMUM_REPARSE_DATA_BUFFER_SIZE]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L829">                            <span class="tok-kw">try</span> windows.DeviceIoControl(self.handle, windows.FSCTL_GET_REPARSE_POINT, <span class="tok-null">null</span>, reparse_buf[<span class="tok-number">0</span>..]);</span>
<span class="line" id="L830">                            <span class="tok-kw">const</span> reparse_struct = <span class="tok-builtin">@ptrCast</span>(*<span class="tok-kw">const</span> windows.REPARSE_DATA_BUFFER, <span class="tok-builtin">@alignCast</span>(<span class="tok-builtin">@alignOf</span>(windows.REPARSE_DATA_BUFFER), &amp;reparse_buf[<span class="tok-number">0</span>]));</span>
<span class="line" id="L831">                            <span class="tok-kw">break</span> :reparse_blk reparse_struct.ReparseTag;</span>
<span class="line" id="L832">                        }</span>
<span class="line" id="L833">                        <span class="tok-kw">break</span> :reparse_blk <span class="tok-number">0</span>;</span>
<span class="line" id="L834">                    };</span>
<span class="line" id="L835"></span>
<span class="line" id="L836">                    <span class="tok-kw">break</span> :blk MetadataWindows{</span>
<span class="line" id="L837">                        .attributes = info.BasicInformation.FileAttributes,</span>
<span class="line" id="L838">                        .reparse_tag = reparse_tag,</span>
<span class="line" id="L839">                        ._size = <span class="tok-builtin">@bitCast</span>(<span class="tok-type">u64</span>, info.StandardInformation.EndOfFile),</span>
<span class="line" id="L840">                        .access_time = windows.fromSysTime(info.BasicInformation.LastAccessTime),</span>
<span class="line" id="L841">                        .modified_time = windows.fromSysTime(info.BasicInformation.LastWriteTime),</span>
<span class="line" id="L842">                        .creation_time = windows.fromSysTime(info.BasicInformation.CreationTime),</span>
<span class="line" id="L843">                    };</span>
<span class="line" id="L844">                },</span>
<span class="line" id="L845">                .linux =&gt; blk: {</span>
<span class="line" id="L846">                    <span class="tok-kw">var</span> stx = mem.zeroes(os.linux.Statx);</span>
<span class="line" id="L847">                    <span class="tok-kw">const</span> rcx = os.linux.statx(self.handle, <span class="tok-str">&quot;\x00&quot;</span>, os.linux.AT.EMPTY_PATH, os.linux.STATX_TYPE | os.linux.STATX_MODE | os.linux.STATX_ATIME | os.linux.STATX_MTIME | os.linux.STATX_BTIME, &amp;stx);</span>
<span class="line" id="L848"></span>
<span class="line" id="L849">                    <span class="tok-kw">switch</span> (os.errno(rcx)) {</span>
<span class="line" id="L850">                        .SUCCESS =&gt; {},</span>
<span class="line" id="L851">                        <span class="tok-comment">// NOSYS happens when `statx` is unsupported, which is the case on kernel versions before 4.11</span>
</span>
<span class="line" id="L852">                        <span class="tok-comment">// Here, we call `fstat` and fill `stx` with the data we need</span>
</span>
<span class="line" id="L853">                        .NOSYS =&gt; {</span>
<span class="line" id="L854">                            <span class="tok-kw">const</span> st = <span class="tok-kw">try</span> os.fstat(self.handle);</span>
<span class="line" id="L855"></span>
<span class="line" id="L856">                            stx.mode = <span class="tok-builtin">@intCast</span>(<span class="tok-type">u16</span>, st.mode);</span>
<span class="line" id="L857"></span>
<span class="line" id="L858">                            <span class="tok-comment">// Hacky conversion from timespec to statx_timestamp</span>
</span>
<span class="line" id="L859">                            stx.atime = std.mem.zeroes(os.linux.statx_timestamp);</span>
<span class="line" id="L860">                            stx.atime.tv_sec = st.atim.tv_sec;</span>
<span class="line" id="L861">                            stx.atime.tv_nsec = <span class="tok-builtin">@intCast</span>(<span class="tok-type">u32</span>, st.atim.tv_nsec); <span class="tok-comment">// Guaranteed to succeed (tv_nsec is always below 10^9)</span>
</span>
<span class="line" id="L862"></span>
<span class="line" id="L863">                            stx.mtime = std.mem.zeroes(os.linux.statx_timestamp);</span>
<span class="line" id="L864">                            stx.mtime.tv_sec = st.mtim.tv_sec;</span>
<span class="line" id="L865">                            stx.mtime.tv_nsec = <span class="tok-builtin">@intCast</span>(<span class="tok-type">u32</span>, st.mtim.tv_nsec);</span>
<span class="line" id="L866"></span>
<span class="line" id="L867">                            stx.mask = os.linux.STATX_BASIC_STATS | os.linux.STATX_MTIME;</span>
<span class="line" id="L868">                        },</span>
<span class="line" id="L869">                        .BADF =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L870">                        .FAULT =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L871">                        .NOMEM =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SystemResources,</span>
<span class="line" id="L872">                        <span class="tok-kw">else</span> =&gt; |err| <span class="tok-kw">return</span> os.unexpectedErrno(err),</span>
<span class="line" id="L873">                    }</span>
<span class="line" id="L874"></span>
<span class="line" id="L875">                    <span class="tok-kw">break</span> :blk MetadataLinux{</span>
<span class="line" id="L876">                        .statx = stx,</span>
<span class="line" id="L877">                    };</span>
<span class="line" id="L878">                },</span>
<span class="line" id="L879">                <span class="tok-kw">else</span> =&gt; blk: {</span>
<span class="line" id="L880">                    <span class="tok-kw">const</span> st = <span class="tok-kw">try</span> os.fstat(self.handle);</span>
<span class="line" id="L881">                    <span class="tok-kw">break</span> :blk MetadataUnix{</span>
<span class="line" id="L882">                        .stat = st,</span>
<span class="line" id="L883">                    };</span>
<span class="line" id="L884">                },</span>
<span class="line" id="L885">            },</span>
<span class="line" id="L886">        };</span>
<span class="line" id="L887">    }</span>
<span class="line" id="L888"></span>
<span class="line" id="L889">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> UpdateTimesError = os.FutimensError || windows.SetFileTimeError;</span>
<span class="line" id="L890"></span>
<span class="line" id="L891">    <span class="tok-comment">/// The underlying file system may have a different granularity than nanoseconds,</span></span>
<span class="line" id="L892">    <span class="tok-comment">/// and therefore this function cannot guarantee any precision will be stored.</span></span>
<span class="line" id="L893">    <span class="tok-comment">/// Further, the maximum value is limited by the system ABI. When a value is provided</span></span>
<span class="line" id="L894">    <span class="tok-comment">/// that exceeds this range, the value is clamped to the maximum.</span></span>
<span class="line" id="L895">    <span class="tok-comment">/// TODO: integrate with async I/O</span></span>
<span class="line" id="L896">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">updateTimes</span>(</span>
<span class="line" id="L897">        self: File,</span>
<span class="line" id="L898">        <span class="tok-comment">/// access timestamp in nanoseconds</span></span>
<span class="line" id="L899">        atime: <span class="tok-type">i128</span>,</span>
<span class="line" id="L900">        <span class="tok-comment">/// last modification timestamp in nanoseconds</span></span>
<span class="line" id="L901">        mtime: <span class="tok-type">i128</span>,</span>
<span class="line" id="L902">    ) UpdateTimesError!<span class="tok-type">void</span> {</span>
<span class="line" id="L903">        <span class="tok-kw">if</span> (builtin.os.tag == .windows) {</span>
<span class="line" id="L904">            <span class="tok-kw">const</span> atime_ft = windows.nanoSecondsToFileTime(atime);</span>
<span class="line" id="L905">            <span class="tok-kw">const</span> mtime_ft = windows.nanoSecondsToFileTime(mtime);</span>
<span class="line" id="L906">            <span class="tok-kw">return</span> windows.SetFileTime(self.handle, <span class="tok-null">null</span>, &amp;atime_ft, &amp;mtime_ft);</span>
<span class="line" id="L907">        }</span>
<span class="line" id="L908">        <span class="tok-kw">const</span> times = [<span class="tok-number">2</span>]os.timespec{</span>
<span class="line" id="L909">            os.timespec{</span>
<span class="line" id="L910">                .tv_sec = math.cast(<span class="tok-type">isize</span>, <span class="tok-builtin">@divFloor</span>(atime, std.time.ns_per_s)) <span class="tok-kw">orelse</span> maxInt(<span class="tok-type">isize</span>),</span>
<span class="line" id="L911">                .tv_nsec = math.cast(<span class="tok-type">isize</span>, <span class="tok-builtin">@mod</span>(atime, std.time.ns_per_s)) <span class="tok-kw">orelse</span> maxInt(<span class="tok-type">isize</span>),</span>
<span class="line" id="L912">            },</span>
<span class="line" id="L913">            os.timespec{</span>
<span class="line" id="L914">                .tv_sec = math.cast(<span class="tok-type">isize</span>, <span class="tok-builtin">@divFloor</span>(mtime, std.time.ns_per_s)) <span class="tok-kw">orelse</span> maxInt(<span class="tok-type">isize</span>),</span>
<span class="line" id="L915">                .tv_nsec = math.cast(<span class="tok-type">isize</span>, <span class="tok-builtin">@mod</span>(mtime, std.time.ns_per_s)) <span class="tok-kw">orelse</span> maxInt(<span class="tok-type">isize</span>),</span>
<span class="line" id="L916">            },</span>
<span class="line" id="L917">        };</span>
<span class="line" id="L918">        <span class="tok-kw">try</span> os.futimens(self.handle, &amp;times);</span>
<span class="line" id="L919">    }</span>
<span class="line" id="L920"></span>
<span class="line" id="L921">    <span class="tok-comment">/// Reads all the bytes from the current position to the end of the file.</span></span>
<span class="line" id="L922">    <span class="tok-comment">/// On success, caller owns returned buffer.</span></span>
<span class="line" id="L923">    <span class="tok-comment">/// If the file is larger than `max_bytes`, returns `error.FileTooBig`.</span></span>
<span class="line" id="L924">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">readToEndAlloc</span>(self: File, allocator: mem.Allocator, max_bytes: <span class="tok-type">usize</span>) ![]<span class="tok-type">u8</span> {</span>
<span class="line" id="L925">        <span class="tok-kw">return</span> self.readToEndAllocOptions(allocator, max_bytes, <span class="tok-null">null</span>, <span class="tok-builtin">@alignOf</span>(<span class="tok-type">u8</span>), <span class="tok-null">null</span>);</span>
<span class="line" id="L926">    }</span>
<span class="line" id="L927"></span>
<span class="line" id="L928">    <span class="tok-comment">/// Reads all the bytes from the current position to the end of the file.</span></span>
<span class="line" id="L929">    <span class="tok-comment">/// On success, caller owns returned buffer.</span></span>
<span class="line" id="L930">    <span class="tok-comment">/// If the file is larger than `max_bytes`, returns `error.FileTooBig`.</span></span>
<span class="line" id="L931">    <span class="tok-comment">/// If `size_hint` is specified the initial buffer size is calculated using</span></span>
<span class="line" id="L932">    <span class="tok-comment">/// that value, otherwise an arbitrary value is used instead.</span></span>
<span class="line" id="L933">    <span class="tok-comment">/// Allows specifying alignment and a sentinel value.</span></span>
<span class="line" id="L934">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">readToEndAllocOptions</span>(</span>
<span class="line" id="L935">        self: File,</span>
<span class="line" id="L936">        allocator: mem.Allocator,</span>
<span class="line" id="L937">        max_bytes: <span class="tok-type">usize</span>,</span>
<span class="line" id="L938">        size_hint: ?<span class="tok-type">usize</span>,</span>
<span class="line" id="L939">        <span class="tok-kw">comptime</span> alignment: <span class="tok-type">u29</span>,</span>
<span class="line" id="L940">        <span class="tok-kw">comptime</span> optional_sentinel: ?<span class="tok-type">u8</span>,</span>
<span class="line" id="L941">    ) !(<span class="tok-kw">if</span> (optional_sentinel) |s| [:s]<span class="tok-kw">align</span>(alignment) <span class="tok-type">u8</span> <span class="tok-kw">else</span> []<span class="tok-kw">align</span>(alignment) <span class="tok-type">u8</span>) {</span>
<span class="line" id="L942">        <span class="tok-comment">// If no size hint is provided fall back to the size=0 code path</span>
</span>
<span class="line" id="L943">        <span class="tok-kw">const</span> size = size_hint <span class="tok-kw">orelse</span> <span class="tok-number">0</span>;</span>
<span class="line" id="L944"></span>
<span class="line" id="L945">        <span class="tok-comment">// The file size returned by stat is used as hint to set the buffer</span>
</span>
<span class="line" id="L946">        <span class="tok-comment">// size. If the reported size is zero, as it happens on Linux for files</span>
</span>
<span class="line" id="L947">        <span class="tok-comment">// in /proc, a small buffer is allocated instead.</span>
</span>
<span class="line" id="L948">        <span class="tok-kw">const</span> initial_cap = (<span class="tok-kw">if</span> (size &gt; <span class="tok-number">0</span>) size <span class="tok-kw">else</span> <span class="tok-number">1024</span>) + <span class="tok-builtin">@boolToInt</span>(optional_sentinel != <span class="tok-null">null</span>);</span>
<span class="line" id="L949">        <span class="tok-kw">var</span> array_list = <span class="tok-kw">try</span> std.ArrayListAligned(<span class="tok-type">u8</span>, alignment).initCapacity(allocator, initial_cap);</span>
<span class="line" id="L950">        <span class="tok-kw">defer</span> array_list.deinit();</span>
<span class="line" id="L951"></span>
<span class="line" id="L952">        self.reader().readAllArrayListAligned(alignment, &amp;array_list, max_bytes) <span class="tok-kw">catch</span> |err| <span class="tok-kw">switch</span> (err) {</span>
<span class="line" id="L953">            <span class="tok-kw">error</span>.StreamTooLong =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.FileTooBig,</span>
<span class="line" id="L954">            <span class="tok-kw">else</span> =&gt; |e| <span class="tok-kw">return</span> e,</span>
<span class="line" id="L955">        };</span>
<span class="line" id="L956"></span>
<span class="line" id="L957">        <span class="tok-kw">if</span> (optional_sentinel) |sentinel| {</span>
<span class="line" id="L958">            <span class="tok-kw">try</span> array_list.append(sentinel);</span>
<span class="line" id="L959">            <span class="tok-kw">const</span> buf = array_list.toOwnedSlice();</span>
<span class="line" id="L960">            <span class="tok-kw">return</span> buf[<span class="tok-number">0</span> .. buf.len - <span class="tok-number">1</span> :sentinel];</span>
<span class="line" id="L961">        } <span class="tok-kw">else</span> {</span>
<span class="line" id="L962">            <span class="tok-kw">return</span> array_list.toOwnedSlice();</span>
<span class="line" id="L963">        }</span>
<span class="line" id="L964">    }</span>
<span class="line" id="L965"></span>
<span class="line" id="L966">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> ReadError = os.ReadError;</span>
<span class="line" id="L967">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> PReadError = os.PReadError;</span>
<span class="line" id="L968"></span>
<span class="line" id="L969">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">read</span>(self: File, buffer: []<span class="tok-type">u8</span>) ReadError!<span class="tok-type">usize</span> {</span>
<span class="line" id="L970">        <span class="tok-kw">if</span> (is_windows) {</span>
<span class="line" id="L971">            <span class="tok-kw">return</span> windows.ReadFile(self.handle, buffer, <span class="tok-null">null</span>, self.intended_io_mode);</span>
<span class="line" id="L972">        }</span>
<span class="line" id="L973"></span>
<span class="line" id="L974">        <span class="tok-kw">if</span> (self.intended_io_mode == .blocking) {</span>
<span class="line" id="L975">            <span class="tok-kw">return</span> os.read(self.handle, buffer);</span>
<span class="line" id="L976">        } <span class="tok-kw">else</span> {</span>
<span class="line" id="L977">            <span class="tok-kw">return</span> std.event.Loop.instance.?.read(self.handle, buffer, self.capable_io_mode != self.intended_io_mode);</span>
<span class="line" id="L978">        }</span>
<span class="line" id="L979">    }</span>
<span class="line" id="L980"></span>
<span class="line" id="L981">    <span class="tok-comment">/// Returns the number of bytes read. If the number read is smaller than `buffer.len`, it</span></span>
<span class="line" id="L982">    <span class="tok-comment">/// means the file reached the end. Reaching the end of a file is not an error condition.</span></span>
<span class="line" id="L983">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">readAll</span>(self: File, buffer: []<span class="tok-type">u8</span>) ReadError!<span class="tok-type">usize</span> {</span>
<span class="line" id="L984">        <span class="tok-kw">var</span> index: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L985">        <span class="tok-kw">while</span> (index != buffer.len) {</span>
<span class="line" id="L986">            <span class="tok-kw">const</span> amt = <span class="tok-kw">try</span> self.read(buffer[index..]);</span>
<span class="line" id="L987">            <span class="tok-kw">if</span> (amt == <span class="tok-number">0</span>) <span class="tok-kw">break</span>;</span>
<span class="line" id="L988">            index += amt;</span>
<span class="line" id="L989">        }</span>
<span class="line" id="L990">        <span class="tok-kw">return</span> index;</span>
<span class="line" id="L991">    }</span>
<span class="line" id="L992"></span>
<span class="line" id="L993">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">pread</span>(self: File, buffer: []<span class="tok-type">u8</span>, offset: <span class="tok-type">u64</span>) PReadError!<span class="tok-type">usize</span> {</span>
<span class="line" id="L994">        <span class="tok-kw">if</span> (is_windows) {</span>
<span class="line" id="L995">            <span class="tok-kw">return</span> windows.ReadFile(self.handle, buffer, offset, self.intended_io_mode);</span>
<span class="line" id="L996">        }</span>
<span class="line" id="L997"></span>
<span class="line" id="L998">        <span class="tok-kw">if</span> (self.intended_io_mode == .blocking) {</span>
<span class="line" id="L999">            <span class="tok-kw">return</span> os.pread(self.handle, buffer, offset);</span>
<span class="line" id="L1000">        } <span class="tok-kw">else</span> {</span>
<span class="line" id="L1001">            <span class="tok-kw">return</span> std.event.Loop.instance.?.pread(self.handle, buffer, offset, self.capable_io_mode != self.intended_io_mode);</span>
<span class="line" id="L1002">        }</span>
<span class="line" id="L1003">    }</span>
<span class="line" id="L1004"></span>
<span class="line" id="L1005">    <span class="tok-comment">/// Returns the number of bytes read. If the number read is smaller than `buffer.len`, it</span></span>
<span class="line" id="L1006">    <span class="tok-comment">/// means the file reached the end. Reaching the end of a file is not an error condition.</span></span>
<span class="line" id="L1007">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">preadAll</span>(self: File, buffer: []<span class="tok-type">u8</span>, offset: <span class="tok-type">u64</span>) PReadError!<span class="tok-type">usize</span> {</span>
<span class="line" id="L1008">        <span class="tok-kw">var</span> index: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L1009">        <span class="tok-kw">while</span> (index != buffer.len) {</span>
<span class="line" id="L1010">            <span class="tok-kw">const</span> amt = <span class="tok-kw">try</span> self.pread(buffer[index..], offset + index);</span>
<span class="line" id="L1011">            <span class="tok-kw">if</span> (amt == <span class="tok-number">0</span>) <span class="tok-kw">break</span>;</span>
<span class="line" id="L1012">            index += amt;</span>
<span class="line" id="L1013">        }</span>
<span class="line" id="L1014">        <span class="tok-kw">return</span> index;</span>
<span class="line" id="L1015">    }</span>
<span class="line" id="L1016"></span>
<span class="line" id="L1017">    <span class="tok-comment">/// See https://github.com/ziglang/zig/issues/7699</span></span>
<span class="line" id="L1018">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">readv</span>(self: File, iovecs: []<span class="tok-kw">const</span> os.iovec) ReadError!<span class="tok-type">usize</span> {</span>
<span class="line" id="L1019">        <span class="tok-kw">if</span> (is_windows) {</span>
<span class="line" id="L1020">            <span class="tok-comment">// TODO improve this to use ReadFileScatter</span>
</span>
<span class="line" id="L1021">            <span class="tok-kw">if</span> (iovecs.len == <span class="tok-number">0</span>) <span class="tok-kw">return</span> <span class="tok-builtin">@as</span>(<span class="tok-type">usize</span>, <span class="tok-number">0</span>);</span>
<span class="line" id="L1022">            <span class="tok-kw">const</span> first = iovecs[<span class="tok-number">0</span>];</span>
<span class="line" id="L1023">            <span class="tok-kw">return</span> windows.ReadFile(self.handle, first.iov_base[<span class="tok-number">0</span>..first.iov_len], <span class="tok-null">null</span>, self.intended_io_mode);</span>
<span class="line" id="L1024">        }</span>
<span class="line" id="L1025"></span>
<span class="line" id="L1026">        <span class="tok-kw">if</span> (self.intended_io_mode == .blocking) {</span>
<span class="line" id="L1027">            <span class="tok-kw">return</span> os.readv(self.handle, iovecs);</span>
<span class="line" id="L1028">        } <span class="tok-kw">else</span> {</span>
<span class="line" id="L1029">            <span class="tok-kw">return</span> std.event.Loop.instance.?.readv(self.handle, iovecs, self.capable_io_mode != self.intended_io_mode);</span>
<span class="line" id="L1030">        }</span>
<span class="line" id="L1031">    }</span>
<span class="line" id="L1032"></span>
<span class="line" id="L1033">    <span class="tok-comment">/// Returns the number of bytes read. If the number read is smaller than the total bytes</span></span>
<span class="line" id="L1034">    <span class="tok-comment">/// from all the buffers, it means the file reached the end. Reaching the end of a file</span></span>
<span class="line" id="L1035">    <span class="tok-comment">/// is not an error condition.</span></span>
<span class="line" id="L1036">    <span class="tok-comment">/// The `iovecs` parameter is mutable because this function needs to mutate the fields in</span></span>
<span class="line" id="L1037">    <span class="tok-comment">/// order to handle partial reads from the underlying OS layer.</span></span>
<span class="line" id="L1038">    <span class="tok-comment">/// See https://github.com/ziglang/zig/issues/7699</span></span>
<span class="line" id="L1039">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">readvAll</span>(self: File, iovecs: []os.iovec) ReadError!<span class="tok-type">usize</span> {</span>
<span class="line" id="L1040">        <span class="tok-kw">if</span> (iovecs.len == <span class="tok-number">0</span>) <span class="tok-kw">return</span> <span class="tok-number">0</span>;</span>
<span class="line" id="L1041"></span>
<span class="line" id="L1042">        <span class="tok-kw">var</span> i: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L1043">        <span class="tok-kw">var</span> off: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L1044">        <span class="tok-kw">while</span> (<span class="tok-null">true</span>) {</span>
<span class="line" id="L1045">            <span class="tok-kw">var</span> amt = <span class="tok-kw">try</span> self.readv(iovecs[i..]);</span>
<span class="line" id="L1046">            <span class="tok-kw">var</span> eof = amt == <span class="tok-number">0</span>;</span>
<span class="line" id="L1047">            off += amt;</span>
<span class="line" id="L1048">            <span class="tok-kw">while</span> (amt &gt;= iovecs[i].iov_len) {</span>
<span class="line" id="L1049">                amt -= iovecs[i].iov_len;</span>
<span class="line" id="L1050">                i += <span class="tok-number">1</span>;</span>
<span class="line" id="L1051">                <span class="tok-kw">if</span> (i &gt;= iovecs.len) <span class="tok-kw">return</span> off;</span>
<span class="line" id="L1052">                eof = <span class="tok-null">false</span>;</span>
<span class="line" id="L1053">            }</span>
<span class="line" id="L1054">            <span class="tok-kw">if</span> (eof) <span class="tok-kw">return</span> off;</span>
<span class="line" id="L1055">            iovecs[i].iov_base += amt;</span>
<span class="line" id="L1056">            iovecs[i].iov_len -= amt;</span>
<span class="line" id="L1057">        }</span>
<span class="line" id="L1058">    }</span>
<span class="line" id="L1059"></span>
<span class="line" id="L1060">    <span class="tok-comment">/// See https://github.com/ziglang/zig/issues/7699</span></span>
<span class="line" id="L1061">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">preadv</span>(self: File, iovecs: []<span class="tok-kw">const</span> os.iovec, offset: <span class="tok-type">u64</span>) PReadError!<span class="tok-type">usize</span> {</span>
<span class="line" id="L1062">        <span class="tok-kw">if</span> (is_windows) {</span>
<span class="line" id="L1063">            <span class="tok-comment">// TODO improve this to use ReadFileScatter</span>
</span>
<span class="line" id="L1064">            <span class="tok-kw">if</span> (iovecs.len == <span class="tok-number">0</span>) <span class="tok-kw">return</span> <span class="tok-builtin">@as</span>(<span class="tok-type">usize</span>, <span class="tok-number">0</span>);</span>
<span class="line" id="L1065">            <span class="tok-kw">const</span> first = iovecs[<span class="tok-number">0</span>];</span>
<span class="line" id="L1066">            <span class="tok-kw">return</span> windows.ReadFile(self.handle, first.iov_base[<span class="tok-number">0</span>..first.iov_len], offset, self.intended_io_mode);</span>
<span class="line" id="L1067">        }</span>
<span class="line" id="L1068"></span>
<span class="line" id="L1069">        <span class="tok-kw">if</span> (self.intended_io_mode == .blocking) {</span>
<span class="line" id="L1070">            <span class="tok-kw">return</span> os.preadv(self.handle, iovecs, offset);</span>
<span class="line" id="L1071">        } <span class="tok-kw">else</span> {</span>
<span class="line" id="L1072">            <span class="tok-kw">return</span> std.event.Loop.instance.?.preadv(self.handle, iovecs, offset, self.capable_io_mode != self.intended_io_mode);</span>
<span class="line" id="L1073">        }</span>
<span class="line" id="L1074">    }</span>
<span class="line" id="L1075"></span>
<span class="line" id="L1076">    <span class="tok-comment">/// Returns the number of bytes read. If the number read is smaller than the total bytes</span></span>
<span class="line" id="L1077">    <span class="tok-comment">/// from all the buffers, it means the file reached the end. Reaching the end of a file</span></span>
<span class="line" id="L1078">    <span class="tok-comment">/// is not an error condition.</span></span>
<span class="line" id="L1079">    <span class="tok-comment">/// The `iovecs` parameter is mutable because this function needs to mutate the fields in</span></span>
<span class="line" id="L1080">    <span class="tok-comment">/// order to handle partial reads from the underlying OS layer.</span></span>
<span class="line" id="L1081">    <span class="tok-comment">/// See https://github.com/ziglang/zig/issues/7699</span></span>
<span class="line" id="L1082">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">preadvAll</span>(self: File, iovecs: []os.iovec, offset: <span class="tok-type">u64</span>) PReadError!<span class="tok-type">usize</span> {</span>
<span class="line" id="L1083">        <span class="tok-kw">if</span> (iovecs.len == <span class="tok-number">0</span>) <span class="tok-kw">return</span> <span class="tok-number">0</span>;</span>
<span class="line" id="L1084"></span>
<span class="line" id="L1085">        <span class="tok-kw">var</span> i: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L1086">        <span class="tok-kw">var</span> off: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L1087">        <span class="tok-kw">while</span> (<span class="tok-null">true</span>) {</span>
<span class="line" id="L1088">            <span class="tok-kw">var</span> amt = <span class="tok-kw">try</span> self.preadv(iovecs[i..], offset + off);</span>
<span class="line" id="L1089">            <span class="tok-kw">var</span> eof = amt == <span class="tok-number">0</span>;</span>
<span class="line" id="L1090">            off += amt;</span>
<span class="line" id="L1091">            <span class="tok-kw">while</span> (amt &gt;= iovecs[i].iov_len) {</span>
<span class="line" id="L1092">                amt -= iovecs[i].iov_len;</span>
<span class="line" id="L1093">                i += <span class="tok-number">1</span>;</span>
<span class="line" id="L1094">                <span class="tok-kw">if</span> (i &gt;= iovecs.len) <span class="tok-kw">return</span> off;</span>
<span class="line" id="L1095">                eof = <span class="tok-null">false</span>;</span>
<span class="line" id="L1096">            }</span>
<span class="line" id="L1097">            <span class="tok-kw">if</span> (eof) <span class="tok-kw">return</span> off;</span>
<span class="line" id="L1098">            iovecs[i].iov_base += amt;</span>
<span class="line" id="L1099">            iovecs[i].iov_len -= amt;</span>
<span class="line" id="L1100">        }</span>
<span class="line" id="L1101">    }</span>
<span class="line" id="L1102"></span>
<span class="line" id="L1103">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> WriteError = os.WriteError;</span>
<span class="line" id="L1104">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> PWriteError = os.PWriteError;</span>
<span class="line" id="L1105"></span>
<span class="line" id="L1106">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">write</span>(self: File, bytes: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) WriteError!<span class="tok-type">usize</span> {</span>
<span class="line" id="L1107">        <span class="tok-kw">if</span> (is_windows) {</span>
<span class="line" id="L1108">            <span class="tok-kw">return</span> windows.WriteFile(self.handle, bytes, <span class="tok-null">null</span>, self.intended_io_mode);</span>
<span class="line" id="L1109">        }</span>
<span class="line" id="L1110"></span>
<span class="line" id="L1111">        <span class="tok-kw">if</span> (self.intended_io_mode == .blocking) {</span>
<span class="line" id="L1112">            <span class="tok-kw">return</span> os.write(self.handle, bytes);</span>
<span class="line" id="L1113">        } <span class="tok-kw">else</span> {</span>
<span class="line" id="L1114">            <span class="tok-kw">return</span> std.event.Loop.instance.?.write(self.handle, bytes, self.capable_io_mode != self.intended_io_mode);</span>
<span class="line" id="L1115">        }</span>
<span class="line" id="L1116">    }</span>
<span class="line" id="L1117"></span>
<span class="line" id="L1118">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">writeAll</span>(self: File, bytes: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) WriteError!<span class="tok-type">void</span> {</span>
<span class="line" id="L1119">        <span class="tok-kw">var</span> index: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L1120">        <span class="tok-kw">while</span> (index &lt; bytes.len) {</span>
<span class="line" id="L1121">            index += <span class="tok-kw">try</span> self.write(bytes[index..]);</span>
<span class="line" id="L1122">        }</span>
<span class="line" id="L1123">    }</span>
<span class="line" id="L1124"></span>
<span class="line" id="L1125">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">pwrite</span>(self: File, bytes: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, offset: <span class="tok-type">u64</span>) PWriteError!<span class="tok-type">usize</span> {</span>
<span class="line" id="L1126">        <span class="tok-kw">if</span> (is_windows) {</span>
<span class="line" id="L1127">            <span class="tok-kw">return</span> windows.WriteFile(self.handle, bytes, offset, self.intended_io_mode);</span>
<span class="line" id="L1128">        }</span>
<span class="line" id="L1129"></span>
<span class="line" id="L1130">        <span class="tok-kw">if</span> (self.intended_io_mode == .blocking) {</span>
<span class="line" id="L1131">            <span class="tok-kw">return</span> os.pwrite(self.handle, bytes, offset);</span>
<span class="line" id="L1132">        } <span class="tok-kw">else</span> {</span>
<span class="line" id="L1133">            <span class="tok-kw">return</span> std.event.Loop.instance.?.pwrite(self.handle, bytes, offset, self.capable_io_mode != self.intended_io_mode);</span>
<span class="line" id="L1134">        }</span>
<span class="line" id="L1135">    }</span>
<span class="line" id="L1136"></span>
<span class="line" id="L1137">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">pwriteAll</span>(self: File, bytes: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, offset: <span class="tok-type">u64</span>) PWriteError!<span class="tok-type">void</span> {</span>
<span class="line" id="L1138">        <span class="tok-kw">var</span> index: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L1139">        <span class="tok-kw">while</span> (index &lt; bytes.len) {</span>
<span class="line" id="L1140">            index += <span class="tok-kw">try</span> self.pwrite(bytes[index..], offset + index);</span>
<span class="line" id="L1141">        }</span>
<span class="line" id="L1142">    }</span>
<span class="line" id="L1143"></span>
<span class="line" id="L1144">    <span class="tok-comment">/// See https://github.com/ziglang/zig/issues/7699</span></span>
<span class="line" id="L1145">    <span class="tok-comment">/// See equivalent function: `std.net.Stream.writev`.</span></span>
<span class="line" id="L1146">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">writev</span>(self: File, iovecs: []<span class="tok-kw">const</span> os.iovec_const) WriteError!<span class="tok-type">usize</span> {</span>
<span class="line" id="L1147">        <span class="tok-kw">if</span> (is_windows) {</span>
<span class="line" id="L1148">            <span class="tok-comment">// TODO improve this to use WriteFileScatter</span>
</span>
<span class="line" id="L1149">            <span class="tok-kw">if</span> (iovecs.len == <span class="tok-number">0</span>) <span class="tok-kw">return</span> <span class="tok-builtin">@as</span>(<span class="tok-type">usize</span>, <span class="tok-number">0</span>);</span>
<span class="line" id="L1150">            <span class="tok-kw">const</span> first = iovecs[<span class="tok-number">0</span>];</span>
<span class="line" id="L1151">            <span class="tok-kw">return</span> windows.WriteFile(self.handle, first.iov_base[<span class="tok-number">0</span>..first.iov_len], <span class="tok-null">null</span>, self.intended_io_mode);</span>
<span class="line" id="L1152">        }</span>
<span class="line" id="L1153"></span>
<span class="line" id="L1154">        <span class="tok-kw">if</span> (self.intended_io_mode == .blocking) {</span>
<span class="line" id="L1155">            <span class="tok-kw">return</span> os.writev(self.handle, iovecs);</span>
<span class="line" id="L1156">        } <span class="tok-kw">else</span> {</span>
<span class="line" id="L1157">            <span class="tok-kw">return</span> std.event.Loop.instance.?.writev(self.handle, iovecs, self.capable_io_mode != self.intended_io_mode);</span>
<span class="line" id="L1158">        }</span>
<span class="line" id="L1159">    }</span>
<span class="line" id="L1160"></span>
<span class="line" id="L1161">    <span class="tok-comment">/// The `iovecs` parameter is mutable because this function needs to mutate the fields in</span></span>
<span class="line" id="L1162">    <span class="tok-comment">/// order to handle partial writes from the underlying OS layer.</span></span>
<span class="line" id="L1163">    <span class="tok-comment">/// See https://github.com/ziglang/zig/issues/7699</span></span>
<span class="line" id="L1164">    <span class="tok-comment">/// See equivalent function: `std.net.Stream.writevAll`.</span></span>
<span class="line" id="L1165">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">writevAll</span>(self: File, iovecs: []os.iovec_const) WriteError!<span class="tok-type">void</span> {</span>
<span class="line" id="L1166">        <span class="tok-kw">if</span> (iovecs.len == <span class="tok-number">0</span>) <span class="tok-kw">return</span>;</span>
<span class="line" id="L1167"></span>
<span class="line" id="L1168">        <span class="tok-kw">var</span> i: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L1169">        <span class="tok-kw">while</span> (<span class="tok-null">true</span>) {</span>
<span class="line" id="L1170">            <span class="tok-kw">var</span> amt = <span class="tok-kw">try</span> self.writev(iovecs[i..]);</span>
<span class="line" id="L1171">            <span class="tok-kw">while</span> (amt &gt;= iovecs[i].iov_len) {</span>
<span class="line" id="L1172">                amt -= iovecs[i].iov_len;</span>
<span class="line" id="L1173">                i += <span class="tok-number">1</span>;</span>
<span class="line" id="L1174">                <span class="tok-kw">if</span> (i &gt;= iovecs.len) <span class="tok-kw">return</span>;</span>
<span class="line" id="L1175">            }</span>
<span class="line" id="L1176">            iovecs[i].iov_base += amt;</span>
<span class="line" id="L1177">            iovecs[i].iov_len -= amt;</span>
<span class="line" id="L1178">        }</span>
<span class="line" id="L1179">    }</span>
<span class="line" id="L1180"></span>
<span class="line" id="L1181">    <span class="tok-comment">/// See https://github.com/ziglang/zig/issues/7699</span></span>
<span class="line" id="L1182">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">pwritev</span>(self: File, iovecs: []os.iovec_const, offset: <span class="tok-type">u64</span>) PWriteError!<span class="tok-type">usize</span> {</span>
<span class="line" id="L1183">        <span class="tok-kw">if</span> (is_windows) {</span>
<span class="line" id="L1184">            <span class="tok-comment">// TODO improve this to use WriteFileScatter</span>
</span>
<span class="line" id="L1185">            <span class="tok-kw">if</span> (iovecs.len == <span class="tok-number">0</span>) <span class="tok-kw">return</span> <span class="tok-builtin">@as</span>(<span class="tok-type">usize</span>, <span class="tok-number">0</span>);</span>
<span class="line" id="L1186">            <span class="tok-kw">const</span> first = iovecs[<span class="tok-number">0</span>];</span>
<span class="line" id="L1187">            <span class="tok-kw">return</span> windows.WriteFile(self.handle, first.iov_base[<span class="tok-number">0</span>..first.iov_len], offset, self.intended_io_mode);</span>
<span class="line" id="L1188">        }</span>
<span class="line" id="L1189"></span>
<span class="line" id="L1190">        <span class="tok-kw">if</span> (self.intended_io_mode == .blocking) {</span>
<span class="line" id="L1191">            <span class="tok-kw">return</span> os.pwritev(self.handle, iovecs, offset);</span>
<span class="line" id="L1192">        } <span class="tok-kw">else</span> {</span>
<span class="line" id="L1193">            <span class="tok-kw">return</span> std.event.Loop.instance.?.pwritev(self.handle, iovecs, offset, self.capable_io_mode != self.intended_io_mode);</span>
<span class="line" id="L1194">        }</span>
<span class="line" id="L1195">    }</span>
<span class="line" id="L1196"></span>
<span class="line" id="L1197">    <span class="tok-comment">/// The `iovecs` parameter is mutable because this function needs to mutate the fields in</span></span>
<span class="line" id="L1198">    <span class="tok-comment">/// order to handle partial writes from the underlying OS layer.</span></span>
<span class="line" id="L1199">    <span class="tok-comment">/// See https://github.com/ziglang/zig/issues/7699</span></span>
<span class="line" id="L1200">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">pwritevAll</span>(self: File, iovecs: []os.iovec_const, offset: <span class="tok-type">u64</span>) PWriteError!<span class="tok-type">void</span> {</span>
<span class="line" id="L1201">        <span class="tok-kw">if</span> (iovecs.len == <span class="tok-number">0</span>) <span class="tok-kw">return</span>;</span>
<span class="line" id="L1202"></span>
<span class="line" id="L1203">        <span class="tok-kw">var</span> i: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L1204">        <span class="tok-kw">var</span> off: <span class="tok-type">u64</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L1205">        <span class="tok-kw">while</span> (<span class="tok-null">true</span>) {</span>
<span class="line" id="L1206">            <span class="tok-kw">var</span> amt = <span class="tok-kw">try</span> self.pwritev(iovecs[i..], offset + off);</span>
<span class="line" id="L1207">            off += amt;</span>
<span class="line" id="L1208">            <span class="tok-kw">while</span> (amt &gt;= iovecs[i].iov_len) {</span>
<span class="line" id="L1209">                amt -= iovecs[i].iov_len;</span>
<span class="line" id="L1210">                i += <span class="tok-number">1</span>;</span>
<span class="line" id="L1211">                <span class="tok-kw">if</span> (i &gt;= iovecs.len) <span class="tok-kw">return</span>;</span>
<span class="line" id="L1212">            }</span>
<span class="line" id="L1213">            iovecs[i].iov_base += amt;</span>
<span class="line" id="L1214">            iovecs[i].iov_len -= amt;</span>
<span class="line" id="L1215">        }</span>
<span class="line" id="L1216">    }</span>
<span class="line" id="L1217"></span>
<span class="line" id="L1218">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> CopyRangeError = os.CopyFileRangeError;</span>
<span class="line" id="L1219"></span>
<span class="line" id="L1220">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">copyRange</span>(in: File, in_offset: <span class="tok-type">u64</span>, out: File, out_offset: <span class="tok-type">u64</span>, len: <span class="tok-type">u64</span>) CopyRangeError!<span class="tok-type">u64</span> {</span>
<span class="line" id="L1221">        <span class="tok-kw">const</span> adjusted_len = math.cast(<span class="tok-type">usize</span>, len) <span class="tok-kw">orelse</span> math.maxInt(<span class="tok-type">usize</span>);</span>
<span class="line" id="L1222">        <span class="tok-kw">const</span> result = <span class="tok-kw">try</span> os.copy_file_range(in.handle, in_offset, out.handle, out_offset, adjusted_len, <span class="tok-number">0</span>);</span>
<span class="line" id="L1223">        <span class="tok-kw">return</span> result;</span>
<span class="line" id="L1224">    }</span>
<span class="line" id="L1225"></span>
<span class="line" id="L1226">    <span class="tok-comment">/// Returns the number of bytes copied. If the number read is smaller than `buffer.len`, it</span></span>
<span class="line" id="L1227">    <span class="tok-comment">/// means the in file reached the end. Reaching the end of a file is not an error condition.</span></span>
<span class="line" id="L1228">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">copyRangeAll</span>(in: File, in_offset: <span class="tok-type">u64</span>, out: File, out_offset: <span class="tok-type">u64</span>, len: <span class="tok-type">u64</span>) CopyRangeError!<span class="tok-type">u64</span> {</span>
<span class="line" id="L1229">        <span class="tok-kw">var</span> total_bytes_copied: <span class="tok-type">u64</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L1230">        <span class="tok-kw">var</span> in_off = in_offset;</span>
<span class="line" id="L1231">        <span class="tok-kw">var</span> out_off = out_offset;</span>
<span class="line" id="L1232">        <span class="tok-kw">while</span> (total_bytes_copied &lt; len) {</span>
<span class="line" id="L1233">            <span class="tok-kw">const</span> amt_copied = <span class="tok-kw">try</span> copyRange(in, in_off, out, out_off, len - total_bytes_copied);</span>
<span class="line" id="L1234">            <span class="tok-kw">if</span> (amt_copied == <span class="tok-number">0</span>) <span class="tok-kw">return</span> total_bytes_copied;</span>
<span class="line" id="L1235">            total_bytes_copied += amt_copied;</span>
<span class="line" id="L1236">            in_off += amt_copied;</span>
<span class="line" id="L1237">            out_off += amt_copied;</span>
<span class="line" id="L1238">        }</span>
<span class="line" id="L1239">        <span class="tok-kw">return</span> total_bytes_copied;</span>
<span class="line" id="L1240">    }</span>
<span class="line" id="L1241"></span>
<span class="line" id="L1242">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> WriteFileOptions = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L1243">        in_offset: <span class="tok-type">u64</span> = <span class="tok-number">0</span>,</span>
<span class="line" id="L1244"></span>
<span class="line" id="L1245">        <span class="tok-comment">/// `null` means the entire file. `0` means no bytes from the file.</span></span>
<span class="line" id="L1246">        <span class="tok-comment">/// When this is `null`, trailers must be sent in a separate writev() call</span></span>
<span class="line" id="L1247">        <span class="tok-comment">/// due to a flaw in the BSD sendfile API. Other operating systems, such as</span></span>
<span class="line" id="L1248">        <span class="tok-comment">/// Linux, already do this anyway due to API limitations.</span></span>
<span class="line" id="L1249">        <span class="tok-comment">/// If the size of the source file is known, passing the size here will save one syscall.</span></span>
<span class="line" id="L1250">        in_len: ?<span class="tok-type">u64</span> = <span class="tok-null">null</span>,</span>
<span class="line" id="L1251"></span>
<span class="line" id="L1252">        headers_and_trailers: []os.iovec_const = &amp;[<span class="tok-number">0</span>]os.iovec_const{},</span>
<span class="line" id="L1253"></span>
<span class="line" id="L1254">        <span class="tok-comment">/// The trailer count is inferred from `headers_and_trailers.len - header_count`</span></span>
<span class="line" id="L1255">        header_count: <span class="tok-type">usize</span> = <span class="tok-number">0</span>,</span>
<span class="line" id="L1256">    };</span>
<span class="line" id="L1257"></span>
<span class="line" id="L1258">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> WriteFileError = ReadError || <span class="tok-kw">error</span>{EndOfStream} || WriteError;</span>
<span class="line" id="L1259"></span>
<span class="line" id="L1260">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">writeFileAll</span>(self: File, in_file: File, args: WriteFileOptions) WriteFileError!<span class="tok-type">void</span> {</span>
<span class="line" id="L1261">        <span class="tok-kw">return</span> self.writeFileAllSendfile(in_file, args) <span class="tok-kw">catch</span> |err| <span class="tok-kw">switch</span> (err) {</span>
<span class="line" id="L1262">            <span class="tok-kw">error</span>.Unseekable,</span>
<span class="line" id="L1263">            <span class="tok-kw">error</span>.FastOpenAlreadyInProgress,</span>
<span class="line" id="L1264">            <span class="tok-kw">error</span>.MessageTooBig,</span>
<span class="line" id="L1265">            <span class="tok-kw">error</span>.FileDescriptorNotASocket,</span>
<span class="line" id="L1266">            <span class="tok-kw">error</span>.NetworkUnreachable,</span>
<span class="line" id="L1267">            <span class="tok-kw">error</span>.NetworkSubsystemFailed,</span>
<span class="line" id="L1268">            =&gt; <span class="tok-kw">return</span> self.writeFileAllUnseekable(in_file, args),</span>
<span class="line" id="L1269"></span>
<span class="line" id="L1270">            <span class="tok-kw">else</span> =&gt; |e| <span class="tok-kw">return</span> e,</span>
<span class="line" id="L1271">        };</span>
<span class="line" id="L1272">    }</span>
<span class="line" id="L1273"></span>
<span class="line" id="L1274">    <span class="tok-comment">/// Does not try seeking in either of the File parameters.</span></span>
<span class="line" id="L1275">    <span class="tok-comment">/// See `writeFileAll` as an alternative to calling this.</span></span>
<span class="line" id="L1276">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">writeFileAllUnseekable</span>(self: File, in_file: File, args: WriteFileOptions) WriteFileError!<span class="tok-type">void</span> {</span>
<span class="line" id="L1277">        <span class="tok-kw">const</span> headers = args.headers_and_trailers[<span class="tok-number">0</span>..args.header_count];</span>
<span class="line" id="L1278">        <span class="tok-kw">const</span> trailers = args.headers_and_trailers[args.header_count..];</span>
<span class="line" id="L1279"></span>
<span class="line" id="L1280">        <span class="tok-kw">try</span> self.writevAll(headers);</span>
<span class="line" id="L1281"></span>
<span class="line" id="L1282">        <span class="tok-kw">try</span> in_file.reader().skipBytes(args.in_offset, .{ .buf_size = <span class="tok-number">4096</span> });</span>
<span class="line" id="L1283"></span>
<span class="line" id="L1284">        <span class="tok-kw">var</span> fifo = std.fifo.LinearFifo(<span class="tok-type">u8</span>, .{ .Static = <span class="tok-number">4096</span> }).init();</span>
<span class="line" id="L1285">        <span class="tok-kw">if</span> (args.in_len) |len| {</span>
<span class="line" id="L1286">            <span class="tok-kw">var</span> stream = std.io.limitedReader(in_file.reader(), len);</span>
<span class="line" id="L1287">            <span class="tok-kw">try</span> fifo.pump(stream.reader(), self.writer());</span>
<span class="line" id="L1288">        } <span class="tok-kw">else</span> {</span>
<span class="line" id="L1289">            <span class="tok-kw">try</span> fifo.pump(in_file.reader(), self.writer());</span>
<span class="line" id="L1290">        }</span>
<span class="line" id="L1291"></span>
<span class="line" id="L1292">        <span class="tok-kw">try</span> self.writevAll(trailers);</span>
<span class="line" id="L1293">    }</span>
<span class="line" id="L1294"></span>
<span class="line" id="L1295">    <span class="tok-comment">/// Low level function which can fail for OS-specific reasons.</span></span>
<span class="line" id="L1296">    <span class="tok-comment">/// See `writeFileAll` as an alternative to calling this.</span></span>
<span class="line" id="L1297">    <span class="tok-comment">/// TODO integrate with async I/O</span></span>
<span class="line" id="L1298">    <span class="tok-kw">fn</span> <span class="tok-fn">writeFileAllSendfile</span>(self: File, in_file: File, args: WriteFileOptions) os.SendFileError!<span class="tok-type">void</span> {</span>
<span class="line" id="L1299">        <span class="tok-kw">const</span> count = blk: {</span>
<span class="line" id="L1300">            <span class="tok-kw">if</span> (args.in_len) |l| {</span>
<span class="line" id="L1301">                <span class="tok-kw">if</span> (l == <span class="tok-number">0</span>) {</span>
<span class="line" id="L1302">                    <span class="tok-kw">return</span> self.writevAll(args.headers_and_trailers);</span>
<span class="line" id="L1303">                } <span class="tok-kw">else</span> {</span>
<span class="line" id="L1304">                    <span class="tok-kw">break</span> :blk l;</span>
<span class="line" id="L1305">                }</span>
<span class="line" id="L1306">            } <span class="tok-kw">else</span> {</span>
<span class="line" id="L1307">                <span class="tok-kw">break</span> :blk <span class="tok-number">0</span>;</span>
<span class="line" id="L1308">            }</span>
<span class="line" id="L1309">        };</span>
<span class="line" id="L1310">        <span class="tok-kw">const</span> headers = args.headers_and_trailers[<span class="tok-number">0</span>..args.header_count];</span>
<span class="line" id="L1311">        <span class="tok-kw">const</span> trailers = args.headers_and_trailers[args.header_count..];</span>
<span class="line" id="L1312">        <span class="tok-kw">const</span> zero_iovec = &amp;[<span class="tok-number">0</span>]os.iovec_const{};</span>
<span class="line" id="L1313">        <span class="tok-comment">// When reading the whole file, we cannot put the trailers in the sendfile() syscall,</span>
</span>
<span class="line" id="L1314">        <span class="tok-comment">// because we have no way to determine whether a partial write is past the end of the file or not.</span>
</span>
<span class="line" id="L1315">        <span class="tok-kw">const</span> trls = <span class="tok-kw">if</span> (count == <span class="tok-number">0</span>) zero_iovec <span class="tok-kw">else</span> trailers;</span>
<span class="line" id="L1316">        <span class="tok-kw">const</span> offset = args.in_offset;</span>
<span class="line" id="L1317">        <span class="tok-kw">const</span> out_fd = self.handle;</span>
<span class="line" id="L1318">        <span class="tok-kw">const</span> in_fd = in_file.handle;</span>
<span class="line" id="L1319">        <span class="tok-kw">const</span> flags = <span class="tok-number">0</span>;</span>
<span class="line" id="L1320">        <span class="tok-kw">var</span> amt: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L1321">        hdrs: {</span>
<span class="line" id="L1322">            <span class="tok-kw">var</span> i: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L1323">            <span class="tok-kw">while</span> (i &lt; headers.len) {</span>
<span class="line" id="L1324">                amt = <span class="tok-kw">try</span> os.sendfile(out_fd, in_fd, offset, count, headers[i..], trls, flags);</span>
<span class="line" id="L1325">                <span class="tok-kw">while</span> (amt &gt;= headers[i].iov_len) {</span>
<span class="line" id="L1326">                    amt -= headers[i].iov_len;</span>
<span class="line" id="L1327">                    i += <span class="tok-number">1</span>;</span>
<span class="line" id="L1328">                    <span class="tok-kw">if</span> (i &gt;= headers.len) <span class="tok-kw">break</span> :hdrs;</span>
<span class="line" id="L1329">                }</span>
<span class="line" id="L1330">                headers[i].iov_base += amt;</span>
<span class="line" id="L1331">                headers[i].iov_len -= amt;</span>
<span class="line" id="L1332">            }</span>
<span class="line" id="L1333">        }</span>
<span class="line" id="L1334">        <span class="tok-kw">if</span> (count == <span class="tok-number">0</span>) {</span>
<span class="line" id="L1335">            <span class="tok-kw">var</span> off: <span class="tok-type">u64</span> = amt;</span>
<span class="line" id="L1336">            <span class="tok-kw">while</span> (<span class="tok-null">true</span>) {</span>
<span class="line" id="L1337">                amt = <span class="tok-kw">try</span> os.sendfile(out_fd, in_fd, offset + off, <span class="tok-number">0</span>, zero_iovec, zero_iovec, flags);</span>
<span class="line" id="L1338">                <span class="tok-kw">if</span> (amt == <span class="tok-number">0</span>) <span class="tok-kw">break</span>;</span>
<span class="line" id="L1339">                off += amt;</span>
<span class="line" id="L1340">            }</span>
<span class="line" id="L1341">        } <span class="tok-kw">else</span> {</span>
<span class="line" id="L1342">            <span class="tok-kw">var</span> off: <span class="tok-type">u64</span> = amt;</span>
<span class="line" id="L1343">            <span class="tok-kw">while</span> (off &lt; count) {</span>
<span class="line" id="L1344">                amt = <span class="tok-kw">try</span> os.sendfile(out_fd, in_fd, offset + off, count - off, zero_iovec, trailers, flags);</span>
<span class="line" id="L1345">                off += amt;</span>
<span class="line" id="L1346">            }</span>
<span class="line" id="L1347">            amt = <span class="tok-builtin">@intCast</span>(<span class="tok-type">usize</span>, off - count);</span>
<span class="line" id="L1348">        }</span>
<span class="line" id="L1349">        <span class="tok-kw">var</span> i: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L1350">        <span class="tok-kw">while</span> (i &lt; trailers.len) {</span>
<span class="line" id="L1351">            <span class="tok-kw">while</span> (amt &gt;= trailers[i].iov_len) {</span>
<span class="line" id="L1352">                amt -= trailers[i].iov_len;</span>
<span class="line" id="L1353">                i += <span class="tok-number">1</span>;</span>
<span class="line" id="L1354">                <span class="tok-kw">if</span> (i &gt;= trailers.len) <span class="tok-kw">return</span>;</span>
<span class="line" id="L1355">            }</span>
<span class="line" id="L1356">            trailers[i].iov_base += amt;</span>
<span class="line" id="L1357">            trailers[i].iov_len -= amt;</span>
<span class="line" id="L1358">            amt = <span class="tok-kw">try</span> os.writev(self.handle, trailers[i..]);</span>
<span class="line" id="L1359">        }</span>
<span class="line" id="L1360">    }</span>
<span class="line" id="L1361"></span>
<span class="line" id="L1362">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> Reader = io.Reader(File, ReadError, read);</span>
<span class="line" id="L1363"></span>
<span class="line" id="L1364">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">reader</span>(file: File) Reader {</span>
<span class="line" id="L1365">        <span class="tok-kw">return</span> .{ .context = file };</span>
<span class="line" id="L1366">    }</span>
<span class="line" id="L1367"></span>
<span class="line" id="L1368">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> Writer = io.Writer(File, WriteError, write);</span>
<span class="line" id="L1369"></span>
<span class="line" id="L1370">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">writer</span>(file: File) Writer {</span>
<span class="line" id="L1371">        <span class="tok-kw">return</span> .{ .context = file };</span>
<span class="line" id="L1372">    }</span>
<span class="line" id="L1373"></span>
<span class="line" id="L1374">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> SeekableStream = io.SeekableStream(</span>
<span class="line" id="L1375">        File,</span>
<span class="line" id="L1376">        SeekError,</span>
<span class="line" id="L1377">        GetSeekPosError,</span>
<span class="line" id="L1378">        seekTo,</span>
<span class="line" id="L1379">        seekBy,</span>
<span class="line" id="L1380">        getPos,</span>
<span class="line" id="L1381">        getEndPos,</span>
<span class="line" id="L1382">    );</span>
<span class="line" id="L1383"></span>
<span class="line" id="L1384">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">seekableStream</span>(file: File) SeekableStream {</span>
<span class="line" id="L1385">        <span class="tok-kw">return</span> .{ .context = file };</span>
<span class="line" id="L1386">    }</span>
<span class="line" id="L1387"></span>
<span class="line" id="L1388">    <span class="tok-kw">const</span> range_off: windows.LARGE_INTEGER = <span class="tok-number">0</span>;</span>
<span class="line" id="L1389">    <span class="tok-kw">const</span> range_len: windows.LARGE_INTEGER = <span class="tok-number">1</span>;</span>
<span class="line" id="L1390"></span>
<span class="line" id="L1391">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> LockError = <span class="tok-kw">error</span>{</span>
<span class="line" id="L1392">        SystemResources,</span>
<span class="line" id="L1393">        FileLocksNotSupported,</span>
<span class="line" id="L1394">    } || os.UnexpectedError;</span>
<span class="line" id="L1395"></span>
<span class="line" id="L1396">    <span class="tok-comment">/// Blocks when an incompatible lock is held by another process.</span></span>
<span class="line" id="L1397">    <span class="tok-comment">/// A process may hold only one type of lock (shared or exclusive) on</span></span>
<span class="line" id="L1398">    <span class="tok-comment">/// a file. When a process terminates in any way, the lock is released.</span></span>
<span class="line" id="L1399">    <span class="tok-comment">///</span></span>
<span class="line" id="L1400">    <span class="tok-comment">/// Assumes the file is unlocked.</span></span>
<span class="line" id="L1401">    <span class="tok-comment">///</span></span>
<span class="line" id="L1402">    <span class="tok-comment">/// TODO: integrate with async I/O</span></span>
<span class="line" id="L1403">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">lock</span>(file: File, l: Lock) LockError!<span class="tok-type">void</span> {</span>
<span class="line" id="L1404">        <span class="tok-kw">if</span> (is_windows) {</span>
<span class="line" id="L1405">            <span class="tok-kw">var</span> io_status_block: windows.IO_STATUS_BLOCK = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L1406">            <span class="tok-kw">const</span> exclusive = <span class="tok-kw">switch</span> (l) {</span>
<span class="line" id="L1407">                .None =&gt; <span class="tok-kw">return</span>,</span>
<span class="line" id="L1408">                .Shared =&gt; <span class="tok-null">false</span>,</span>
<span class="line" id="L1409">                .Exclusive =&gt; <span class="tok-null">true</span>,</span>
<span class="line" id="L1410">            };</span>
<span class="line" id="L1411">            <span class="tok-kw">return</span> windows.LockFile(</span>
<span class="line" id="L1412">                file.handle,</span>
<span class="line" id="L1413">                <span class="tok-null">null</span>,</span>
<span class="line" id="L1414">                <span class="tok-null">null</span>,</span>
<span class="line" id="L1415">                <span class="tok-null">null</span>,</span>
<span class="line" id="L1416">                &amp;io_status_block,</span>
<span class="line" id="L1417">                &amp;range_off,</span>
<span class="line" id="L1418">                &amp;range_len,</span>
<span class="line" id="L1419">                <span class="tok-null">null</span>,</span>
<span class="line" id="L1420">                windows.FALSE, <span class="tok-comment">// non-blocking=false</span>
</span>
<span class="line" id="L1421">                <span class="tok-builtin">@boolToInt</span>(exclusive),</span>
<span class="line" id="L1422">            ) <span class="tok-kw">catch</span> |err| <span class="tok-kw">switch</span> (err) {</span>
<span class="line" id="L1423">                <span class="tok-kw">error</span>.WouldBlock =&gt; <span class="tok-kw">unreachable</span>, <span class="tok-comment">// non-blocking=false</span>
</span>
<span class="line" id="L1424">                <span class="tok-kw">else</span> =&gt; |e| <span class="tok-kw">return</span> e,</span>
<span class="line" id="L1425">            };</span>
<span class="line" id="L1426">        } <span class="tok-kw">else</span> {</span>
<span class="line" id="L1427">            <span class="tok-kw">return</span> os.flock(file.handle, <span class="tok-kw">switch</span> (l) {</span>
<span class="line" id="L1428">                .None =&gt; os.LOCK.UN,</span>
<span class="line" id="L1429">                .Shared =&gt; os.LOCK.SH,</span>
<span class="line" id="L1430">                .Exclusive =&gt; os.LOCK.EX,</span>
<span class="line" id="L1431">            }) <span class="tok-kw">catch</span> |err| <span class="tok-kw">switch</span> (err) {</span>
<span class="line" id="L1432">                <span class="tok-kw">error</span>.WouldBlock =&gt; <span class="tok-kw">unreachable</span>, <span class="tok-comment">// non-blocking=false</span>
</span>
<span class="line" id="L1433">                <span class="tok-kw">else</span> =&gt; |e| <span class="tok-kw">return</span> e,</span>
<span class="line" id="L1434">            };</span>
<span class="line" id="L1435">        }</span>
<span class="line" id="L1436">    }</span>
<span class="line" id="L1437"></span>
<span class="line" id="L1438">    <span class="tok-comment">/// Assumes the file is locked.</span></span>
<span class="line" id="L1439">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">unlock</span>(file: File) <span class="tok-type">void</span> {</span>
<span class="line" id="L1440">        <span class="tok-kw">if</span> (is_windows) {</span>
<span class="line" id="L1441">            <span class="tok-kw">var</span> io_status_block: windows.IO_STATUS_BLOCK = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L1442">            <span class="tok-kw">return</span> windows.UnlockFile(</span>
<span class="line" id="L1443">                file.handle,</span>
<span class="line" id="L1444">                &amp;io_status_block,</span>
<span class="line" id="L1445">                &amp;range_off,</span>
<span class="line" id="L1446">                &amp;range_len,</span>
<span class="line" id="L1447">                <span class="tok-null">null</span>,</span>
<span class="line" id="L1448">            ) <span class="tok-kw">catch</span> |err| <span class="tok-kw">switch</span> (err) {</span>
<span class="line" id="L1449">                <span class="tok-kw">error</span>.RangeNotLocked =&gt; <span class="tok-kw">unreachable</span>, <span class="tok-comment">// Function assumes unlocked.</span>
</span>
<span class="line" id="L1450">                <span class="tok-kw">error</span>.Unexpected =&gt; <span class="tok-kw">unreachable</span>, <span class="tok-comment">// Resource deallocation must succeed.</span>
</span>
<span class="line" id="L1451">            };</span>
<span class="line" id="L1452">        } <span class="tok-kw">else</span> {</span>
<span class="line" id="L1453">            <span class="tok-kw">return</span> os.flock(file.handle, os.LOCK.UN) <span class="tok-kw">catch</span> |err| <span class="tok-kw">switch</span> (err) {</span>
<span class="line" id="L1454">                <span class="tok-kw">error</span>.WouldBlock =&gt; <span class="tok-kw">unreachable</span>, <span class="tok-comment">// unlocking can't block</span>
</span>
<span class="line" id="L1455">                <span class="tok-kw">error</span>.SystemResources =&gt; <span class="tok-kw">unreachable</span>, <span class="tok-comment">// We are deallocating resources.</span>
</span>
<span class="line" id="L1456">                <span class="tok-kw">error</span>.FileLocksNotSupported =&gt; <span class="tok-kw">unreachable</span>, <span class="tok-comment">// We already got the lock.</span>
</span>
<span class="line" id="L1457">                <span class="tok-kw">error</span>.Unexpected =&gt; <span class="tok-kw">unreachable</span>, <span class="tok-comment">// Resource deallocation must succeed.</span>
</span>
<span class="line" id="L1458">            };</span>
<span class="line" id="L1459">        }</span>
<span class="line" id="L1460">    }</span>
<span class="line" id="L1461"></span>
<span class="line" id="L1462">    <span class="tok-comment">/// Attempts to obtain a lock, returning `true` if the lock is</span></span>
<span class="line" id="L1463">    <span class="tok-comment">/// obtained, and `false` if there was an existing incompatible lock held.</span></span>
<span class="line" id="L1464">    <span class="tok-comment">/// A process may hold only one type of lock (shared or exclusive) on</span></span>
<span class="line" id="L1465">    <span class="tok-comment">/// a file. When a process terminates in any way, the lock is released.</span></span>
<span class="line" id="L1466">    <span class="tok-comment">///</span></span>
<span class="line" id="L1467">    <span class="tok-comment">/// Assumes the file is unlocked.</span></span>
<span class="line" id="L1468">    <span class="tok-comment">///</span></span>
<span class="line" id="L1469">    <span class="tok-comment">/// TODO: integrate with async I/O</span></span>
<span class="line" id="L1470">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">tryLock</span>(file: File, l: Lock) LockError!<span class="tok-type">bool</span> {</span>
<span class="line" id="L1471">        <span class="tok-kw">if</span> (is_windows) {</span>
<span class="line" id="L1472">            <span class="tok-kw">var</span> io_status_block: windows.IO_STATUS_BLOCK = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L1473">            <span class="tok-kw">const</span> exclusive = <span class="tok-kw">switch</span> (l) {</span>
<span class="line" id="L1474">                .None =&gt; <span class="tok-kw">return</span>,</span>
<span class="line" id="L1475">                .Shared =&gt; <span class="tok-null">false</span>,</span>
<span class="line" id="L1476">                .Exclusive =&gt; <span class="tok-null">true</span>,</span>
<span class="line" id="L1477">            };</span>
<span class="line" id="L1478">            windows.LockFile(</span>
<span class="line" id="L1479">                file.handle,</span>
<span class="line" id="L1480">                <span class="tok-null">null</span>,</span>
<span class="line" id="L1481">                <span class="tok-null">null</span>,</span>
<span class="line" id="L1482">                <span class="tok-null">null</span>,</span>
<span class="line" id="L1483">                &amp;io_status_block,</span>
<span class="line" id="L1484">                &amp;range_off,</span>
<span class="line" id="L1485">                &amp;range_len,</span>
<span class="line" id="L1486">                <span class="tok-null">null</span>,</span>
<span class="line" id="L1487">                windows.TRUE, <span class="tok-comment">// non-blocking=true</span>
</span>
<span class="line" id="L1488">                <span class="tok-builtin">@boolToInt</span>(exclusive),</span>
<span class="line" id="L1489">            ) <span class="tok-kw">catch</span> |err| <span class="tok-kw">switch</span> (err) {</span>
<span class="line" id="L1490">                <span class="tok-kw">error</span>.WouldBlock =&gt; <span class="tok-kw">return</span> <span class="tok-null">false</span>,</span>
<span class="line" id="L1491">                <span class="tok-kw">else</span> =&gt; |e| <span class="tok-kw">return</span> e,</span>
<span class="line" id="L1492">            };</span>
<span class="line" id="L1493">        } <span class="tok-kw">else</span> {</span>
<span class="line" id="L1494">            os.flock(file.handle, <span class="tok-kw">switch</span> (l) {</span>
<span class="line" id="L1495">                .None =&gt; os.LOCK.UN,</span>
<span class="line" id="L1496">                .Shared =&gt; os.LOCK.SH | os.LOCK.NB,</span>
<span class="line" id="L1497">                .Exclusive =&gt; os.LOCK.EX | os.LOCK.NB,</span>
<span class="line" id="L1498">            }) <span class="tok-kw">catch</span> |err| <span class="tok-kw">switch</span> (err) {</span>
<span class="line" id="L1499">                <span class="tok-kw">error</span>.WouldBlock =&gt; <span class="tok-kw">return</span> <span class="tok-null">false</span>,</span>
<span class="line" id="L1500">                <span class="tok-kw">else</span> =&gt; |e| <span class="tok-kw">return</span> e,</span>
<span class="line" id="L1501">            };</span>
<span class="line" id="L1502">        }</span>
<span class="line" id="L1503">        <span class="tok-kw">return</span> <span class="tok-null">true</span>;</span>
<span class="line" id="L1504">    }</span>
<span class="line" id="L1505"></span>
<span class="line" id="L1506">    <span class="tok-comment">/// Assumes the file is already locked in exclusive mode.</span></span>
<span class="line" id="L1507">    <span class="tok-comment">/// Atomically modifies the lock to be in shared mode, without releasing it.</span></span>
<span class="line" id="L1508">    <span class="tok-comment">///</span></span>
<span class="line" id="L1509">    <span class="tok-comment">/// TODO: integrate with async I/O</span></span>
<span class="line" id="L1510">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">downgradeLock</span>(file: File) LockError!<span class="tok-type">void</span> {</span>
<span class="line" id="L1511">        <span class="tok-kw">if</span> (is_windows) {</span>
<span class="line" id="L1512">            <span class="tok-comment">// On Windows it works like a semaphore + exclusivity flag. To implement this</span>
</span>
<span class="line" id="L1513">            <span class="tok-comment">// function, we first obtain another lock in shared mode. This changes the</span>
</span>
<span class="line" id="L1514">            <span class="tok-comment">// exclusivity flag, but increments the semaphore to 2. So we follow up with</span>
</span>
<span class="line" id="L1515">            <span class="tok-comment">// an NtUnlockFile which decrements the semaphore but does not modify the</span>
</span>
<span class="line" id="L1516">            <span class="tok-comment">// exclusivity flag.</span>
</span>
<span class="line" id="L1517">            <span class="tok-kw">var</span> io_status_block: windows.IO_STATUS_BLOCK = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L1518">            windows.LockFile(</span>
<span class="line" id="L1519">                file.handle,</span>
<span class="line" id="L1520">                <span class="tok-null">null</span>,</span>
<span class="line" id="L1521">                <span class="tok-null">null</span>,</span>
<span class="line" id="L1522">                <span class="tok-null">null</span>,</span>
<span class="line" id="L1523">                &amp;io_status_block,</span>
<span class="line" id="L1524">                &amp;range_off,</span>
<span class="line" id="L1525">                &amp;range_len,</span>
<span class="line" id="L1526">                <span class="tok-null">null</span>,</span>
<span class="line" id="L1527">                windows.TRUE, <span class="tok-comment">// non-blocking=true</span>
</span>
<span class="line" id="L1528">                windows.FALSE, <span class="tok-comment">// exclusive=false</span>
</span>
<span class="line" id="L1529">            ) <span class="tok-kw">catch</span> |err| <span class="tok-kw">switch</span> (err) {</span>
<span class="line" id="L1530">                <span class="tok-kw">error</span>.WouldBlock =&gt; <span class="tok-kw">unreachable</span>, <span class="tok-comment">// File was not locked in exclusive mode.</span>
</span>
<span class="line" id="L1531">                <span class="tok-kw">else</span> =&gt; |e| <span class="tok-kw">return</span> e,</span>
<span class="line" id="L1532">            };</span>
<span class="line" id="L1533">            <span class="tok-kw">return</span> windows.UnlockFile(</span>
<span class="line" id="L1534">                file.handle,</span>
<span class="line" id="L1535">                &amp;io_status_block,</span>
<span class="line" id="L1536">                &amp;range_off,</span>
<span class="line" id="L1537">                &amp;range_len,</span>
<span class="line" id="L1538">                <span class="tok-null">null</span>,</span>
<span class="line" id="L1539">            ) <span class="tok-kw">catch</span> |err| <span class="tok-kw">switch</span> (err) {</span>
<span class="line" id="L1540">                <span class="tok-kw">error</span>.RangeNotLocked =&gt; <span class="tok-kw">unreachable</span>, <span class="tok-comment">// File was not locked.</span>
</span>
<span class="line" id="L1541">                <span class="tok-kw">error</span>.Unexpected =&gt; <span class="tok-kw">unreachable</span>, <span class="tok-comment">// Resource deallocation must succeed.</span>
</span>
<span class="line" id="L1542">            };</span>
<span class="line" id="L1543">        } <span class="tok-kw">else</span> {</span>
<span class="line" id="L1544">            <span class="tok-kw">return</span> os.flock(file.handle, os.LOCK.SH | os.LOCK.NB) <span class="tok-kw">catch</span> |err| <span class="tok-kw">switch</span> (err) {</span>
<span class="line" id="L1545">                <span class="tok-kw">error</span>.WouldBlock =&gt; <span class="tok-kw">unreachable</span>, <span class="tok-comment">// File was not locked in exclusive mode.</span>
</span>
<span class="line" id="L1546">                <span class="tok-kw">else</span> =&gt; |e| <span class="tok-kw">return</span> e,</span>
<span class="line" id="L1547">            };</span>
<span class="line" id="L1548">        }</span>
<span class="line" id="L1549">    }</span>
<span class="line" id="L1550">};</span>
<span class="line" id="L1551"></span>
</code></pre></body>
</html>