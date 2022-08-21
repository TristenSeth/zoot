<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">    <title>fs/watch.zig - source view</title>
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
<pre><code><span class="line" id="L1"><span class="tok-kw">const</span> std = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;std&quot;</span>);</span>
<span class="line" id="L2"><span class="tok-kw">const</span> builtin = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;builtin&quot;</span>);</span>
<span class="line" id="L3"><span class="tok-kw">const</span> event = std.event;</span>
<span class="line" id="L4"><span class="tok-kw">const</span> assert = std.debug.assert;</span>
<span class="line" id="L5"><span class="tok-kw">const</span> testing = std.testing;</span>
<span class="line" id="L6"><span class="tok-kw">const</span> os = std.os;</span>
<span class="line" id="L7"><span class="tok-kw">const</span> mem = std.mem;</span>
<span class="line" id="L8"><span class="tok-kw">const</span> windows = os.windows;</span>
<span class="line" id="L9"><span class="tok-kw">const</span> Loop = event.Loop;</span>
<span class="line" id="L10"><span class="tok-kw">const</span> fd_t = os.fd_t;</span>
<span class="line" id="L11"><span class="tok-kw">const</span> File = std.fs.File;</span>
<span class="line" id="L12"><span class="tok-kw">const</span> Allocator = mem.Allocator;</span>
<span class="line" id="L13"></span>
<span class="line" id="L14"><span class="tok-kw">const</span> global_event_loop = Loop.instance <span class="tok-kw">orelse</span></span>
<span class="line" id="L15">    <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;std.fs.Watch currently only works with event-based I/O&quot;</span>);</span>
<span class="line" id="L16"></span>
<span class="line" id="L17"><span class="tok-kw">const</span> WatchEventId = <span class="tok-kw">enum</span> {</span>
<span class="line" id="L18">    CloseWrite,</span>
<span class="line" id="L19">    Delete,</span>
<span class="line" id="L20">};</span>
<span class="line" id="L21"></span>
<span class="line" id="L22"><span class="tok-kw">const</span> WatchEventError = <span class="tok-kw">error</span>{</span>
<span class="line" id="L23">    UserResourceLimitReached,</span>
<span class="line" id="L24">    SystemResources,</span>
<span class="line" id="L25">    AccessDenied,</span>
<span class="line" id="L26">    Unexpected, <span class="tok-comment">// TODO remove this possibility</span>
</span>
<span class="line" id="L27">};</span>
<span class="line" id="L28"></span>
<span class="line" id="L29"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">Watch</span>(<span class="tok-kw">comptime</span> V: <span class="tok-type">type</span>) <span class="tok-type">type</span> {</span>
<span class="line" id="L30">    <span class="tok-kw">return</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L31">        channel: event.Channel(Event.Error!Event),</span>
<span class="line" id="L32">        os_data: OsData,</span>
<span class="line" id="L33">        allocator: Allocator,</span>
<span class="line" id="L34"></span>
<span class="line" id="L35">        <span class="tok-kw">const</span> OsData = <span class="tok-kw">switch</span> (builtin.os.tag) {</span>
<span class="line" id="L36">            <span class="tok-comment">// TODO https://github.com/ziglang/zig/issues/3778</span>
</span>
<span class="line" id="L37">            .macos, .freebsd, .netbsd, .dragonfly, .openbsd =&gt; KqOsData,</span>
<span class="line" id="L38">            .linux =&gt; LinuxOsData,</span>
<span class="line" id="L39">            .windows =&gt; WindowsOsData,</span>
<span class="line" id="L40"></span>
<span class="line" id="L41">            <span class="tok-kw">else</span> =&gt; <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;Unsupported OS&quot;</span>),</span>
<span class="line" id="L42">        };</span>
<span class="line" id="L43"></span>
<span class="line" id="L44">        <span class="tok-kw">const</span> KqOsData = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L45">            table_lock: event.Lock,</span>
<span class="line" id="L46">            file_table: FileTable,</span>
<span class="line" id="L47"></span>
<span class="line" id="L48">            <span class="tok-kw">const</span> FileTable = std.StringHashMapUnmanaged(*Put);</span>
<span class="line" id="L49">            <span class="tok-kw">const</span> Put = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L50">                putter_frame: <span class="tok-builtin">@Frame</span>(kqPutEvents),</span>
<span class="line" id="L51">                cancelled: <span class="tok-type">bool</span> = <span class="tok-null">false</span>,</span>
<span class="line" id="L52">                value: V,</span>
<span class="line" id="L53">            };</span>
<span class="line" id="L54">        };</span>
<span class="line" id="L55"></span>
<span class="line" id="L56">        <span class="tok-kw">const</span> WindowsOsData = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L57">            table_lock: event.Lock,</span>
<span class="line" id="L58">            dir_table: DirTable,</span>
<span class="line" id="L59">            cancelled: <span class="tok-type">bool</span> = <span class="tok-null">false</span>,</span>
<span class="line" id="L60"></span>
<span class="line" id="L61">            <span class="tok-kw">const</span> DirTable = std.StringHashMapUnmanaged(*Dir);</span>
<span class="line" id="L62">            <span class="tok-kw">const</span> FileTable = std.StringHashMapUnmanaged(V);</span>
<span class="line" id="L63"></span>
<span class="line" id="L64">            <span class="tok-kw">const</span> Dir = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L65">                putter_frame: <span class="tok-builtin">@Frame</span>(windowsDirReader),</span>
<span class="line" id="L66">                file_table: FileTable,</span>
<span class="line" id="L67">                dir_handle: os.windows.HANDLE,</span>
<span class="line" id="L68">            };</span>
<span class="line" id="L69">        };</span>
<span class="line" id="L70"></span>
<span class="line" id="L71">        <span class="tok-kw">const</span> LinuxOsData = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L72">            putter_frame: <span class="tok-builtin">@Frame</span>(linuxEventPutter),</span>
<span class="line" id="L73">            inotify_fd: <span class="tok-type">i32</span>,</span>
<span class="line" id="L74">            wd_table: WdTable,</span>
<span class="line" id="L75">            table_lock: event.Lock,</span>
<span class="line" id="L76">            cancelled: <span class="tok-type">bool</span> = <span class="tok-null">false</span>,</span>
<span class="line" id="L77"></span>
<span class="line" id="L78">            <span class="tok-kw">const</span> WdTable = std.AutoHashMapUnmanaged(<span class="tok-type">i32</span>, Dir);</span>
<span class="line" id="L79">            <span class="tok-kw">const</span> FileTable = std.StringHashMapUnmanaged(V);</span>
<span class="line" id="L80"></span>
<span class="line" id="L81">            <span class="tok-kw">const</span> Dir = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L82">                dirname: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L83">                file_table: FileTable,</span>
<span class="line" id="L84">            };</span>
<span class="line" id="L85">        };</span>
<span class="line" id="L86"></span>
<span class="line" id="L87">        <span class="tok-kw">const</span> Self = <span class="tok-builtin">@This</span>();</span>
<span class="line" id="L88"></span>
<span class="line" id="L89">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> Event = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L90">            id: Id,</span>
<span class="line" id="L91">            data: V,</span>
<span class="line" id="L92">            dirname: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L93">            basename: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L94"></span>
<span class="line" id="L95">            <span class="tok-kw">pub</span> <span class="tok-kw">const</span> Id = WatchEventId;</span>
<span class="line" id="L96">            <span class="tok-kw">pub</span> <span class="tok-kw">const</span> Error = WatchEventError;</span>
<span class="line" id="L97">        };</span>
<span class="line" id="L98"></span>
<span class="line" id="L99">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">init</span>(allocator: Allocator, event_buf_count: <span class="tok-type">usize</span>) !*Self {</span>
<span class="line" id="L100">            <span class="tok-kw">const</span> self = <span class="tok-kw">try</span> allocator.create(Self);</span>
<span class="line" id="L101">            <span class="tok-kw">errdefer</span> allocator.destroy(self);</span>
<span class="line" id="L102"></span>
<span class="line" id="L103">            <span class="tok-kw">switch</span> (builtin.os.tag) {</span>
<span class="line" id="L104">                .linux =&gt; {</span>
<span class="line" id="L105">                    <span class="tok-kw">const</span> inotify_fd = <span class="tok-kw">try</span> os.inotify_init1(os.linux.IN_NONBLOCK | os.linux.IN_CLOEXEC);</span>
<span class="line" id="L106">                    <span class="tok-kw">errdefer</span> os.close(inotify_fd);</span>
<span class="line" id="L107"></span>
<span class="line" id="L108">                    self.* = Self{</span>
<span class="line" id="L109">                        .allocator = allocator,</span>
<span class="line" id="L110">                        .channel = <span class="tok-null">undefined</span>,</span>
<span class="line" id="L111">                        .os_data = OsData{</span>
<span class="line" id="L112">                            .putter_frame = <span class="tok-null">undefined</span>,</span>
<span class="line" id="L113">                            .inotify_fd = inotify_fd,</span>
<span class="line" id="L114">                            .wd_table = OsData.WdTable.init(allocator),</span>
<span class="line" id="L115">                            .table_lock = event.Lock{},</span>
<span class="line" id="L116">                        },</span>
<span class="line" id="L117">                    };</span>
<span class="line" id="L118"></span>
<span class="line" id="L119">                    <span class="tok-kw">var</span> buf = <span class="tok-kw">try</span> allocator.alloc(Event.Error!Event, event_buf_count);</span>
<span class="line" id="L120">                    self.channel.init(buf);</span>
<span class="line" id="L121">                    self.os_data.putter_frame = <span class="tok-kw">async</span> self.linuxEventPutter();</span>
<span class="line" id="L122">                    <span class="tok-kw">return</span> self;</span>
<span class="line" id="L123">                },</span>
<span class="line" id="L124"></span>
<span class="line" id="L125">                .windows =&gt; {</span>
<span class="line" id="L126">                    self.* = Self{</span>
<span class="line" id="L127">                        .allocator = allocator,</span>
<span class="line" id="L128">                        .channel = <span class="tok-null">undefined</span>,</span>
<span class="line" id="L129">                        .os_data = OsData{</span>
<span class="line" id="L130">                            .table_lock = event.Lock{},</span>
<span class="line" id="L131">                            .dir_table = OsData.DirTable.init(allocator),</span>
<span class="line" id="L132">                        },</span>
<span class="line" id="L133">                    };</span>
<span class="line" id="L134"></span>
<span class="line" id="L135">                    <span class="tok-kw">var</span> buf = <span class="tok-kw">try</span> allocator.alloc(Event.Error!Event, event_buf_count);</span>
<span class="line" id="L136">                    self.channel.init(buf);</span>
<span class="line" id="L137">                    <span class="tok-kw">return</span> self;</span>
<span class="line" id="L138">                },</span>
<span class="line" id="L139"></span>
<span class="line" id="L140">                .macos, .freebsd, .netbsd, .dragonfly, .openbsd =&gt; {</span>
<span class="line" id="L141">                    self.* = Self{</span>
<span class="line" id="L142">                        .allocator = allocator,</span>
<span class="line" id="L143">                        .channel = <span class="tok-null">undefined</span>,</span>
<span class="line" id="L144">                        .os_data = OsData{</span>
<span class="line" id="L145">                            .table_lock = event.Lock{},</span>
<span class="line" id="L146">                            .file_table = OsData.FileTable.init(allocator),</span>
<span class="line" id="L147">                        },</span>
<span class="line" id="L148">                    };</span>
<span class="line" id="L149"></span>
<span class="line" id="L150">                    <span class="tok-kw">var</span> buf = <span class="tok-kw">try</span> allocator.alloc(Event.Error!Event, event_buf_count);</span>
<span class="line" id="L151">                    self.channel.init(buf);</span>
<span class="line" id="L152">                    <span class="tok-kw">return</span> self;</span>
<span class="line" id="L153">                },</span>
<span class="line" id="L154">                <span class="tok-kw">else</span> =&gt; <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;Unsupported OS&quot;</span>),</span>
<span class="line" id="L155">            }</span>
<span class="line" id="L156">        }</span>
<span class="line" id="L157"></span>
<span class="line" id="L158">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">deinit</span>(self: *Self) <span class="tok-type">void</span> {</span>
<span class="line" id="L159">            <span class="tok-kw">switch</span> (builtin.os.tag) {</span>
<span class="line" id="L160">                .macos, .freebsd, .netbsd, .dragonfly, .openbsd =&gt; {</span>
<span class="line" id="L161">                    <span class="tok-kw">var</span> it = self.os_data.file_table.iterator();</span>
<span class="line" id="L162">                    <span class="tok-kw">while</span> (it.next()) |entry| {</span>
<span class="line" id="L163">                        <span class="tok-kw">const</span> key = entry.key_ptr.*;</span>
<span class="line" id="L164">                        <span class="tok-kw">const</span> value = entry.value_ptr.*;</span>
<span class="line" id="L165">                        value.cancelled = <span class="tok-null">true</span>;</span>
<span class="line" id="L166">                        <span class="tok-comment">// @TODO Close the fd here?</span>
</span>
<span class="line" id="L167">                        <span class="tok-kw">await</span> value.putter_frame;</span>
<span class="line" id="L168">                        self.allocator.free(key);</span>
<span class="line" id="L169">                        self.allocator.destroy(value);</span>
<span class="line" id="L170">                    }</span>
<span class="line" id="L171">                },</span>
<span class="line" id="L172">                .linux =&gt; {</span>
<span class="line" id="L173">                    self.os_data.cancelled = <span class="tok-null">true</span>;</span>
<span class="line" id="L174">                    {</span>
<span class="line" id="L175">                        <span class="tok-comment">// Remove all directory watches linuxEventPutter will take care of</span>
</span>
<span class="line" id="L176">                        <span class="tok-comment">// cleaning up the memory and closing the inotify fd.</span>
</span>
<span class="line" id="L177">                        <span class="tok-kw">var</span> dir_it = self.os_data.wd_table.keyIterator();</span>
<span class="line" id="L178">                        <span class="tok-kw">while</span> (dir_it.next()) |wd_key| {</span>
<span class="line" id="L179">                            <span class="tok-kw">const</span> rc = os.linux.inotify_rm_watch(self.os_data.inotify_fd, wd_key.*);</span>
<span class="line" id="L180">                            <span class="tok-comment">// Errno can only be EBADF, EINVAL if either the inotify fs or the wd are invalid</span>
</span>
<span class="line" id="L181">                            std.debug.assert(rc == <span class="tok-number">0</span>);</span>
<span class="line" id="L182">                        }</span>
<span class="line" id="L183">                    }</span>
<span class="line" id="L184">                    <span class="tok-kw">await</span> self.os_data.putter_frame;</span>
<span class="line" id="L185">                },</span>
<span class="line" id="L186">                .windows =&gt; {</span>
<span class="line" id="L187">                    self.os_data.cancelled = <span class="tok-null">true</span>;</span>
<span class="line" id="L188">                    <span class="tok-kw">var</span> dir_it = self.os_data.dir_table.iterator();</span>
<span class="line" id="L189">                    <span class="tok-kw">while</span> (dir_it.next()) |dir_entry| {</span>
<span class="line" id="L190">                        <span class="tok-kw">if</span> (windows.kernel32.CancelIoEx(dir_entry.value.dir_handle, <span class="tok-null">null</span>) != <span class="tok-number">0</span>) {</span>
<span class="line" id="L191">                            <span class="tok-comment">// We canceled the pending ReadDirectoryChangesW operation, but our</span>
</span>
<span class="line" id="L192">                            <span class="tok-comment">// frame is still suspending, now waiting indefinitely.</span>
</span>
<span class="line" id="L193">                            <span class="tok-comment">// Thus, it is safe to resume it ourslves</span>
</span>
<span class="line" id="L194">                            <span class="tok-kw">resume</span> dir_entry.value.putter_frame;</span>
<span class="line" id="L195">                        } <span class="tok-kw">else</span> {</span>
<span class="line" id="L196">                            std.debug.assert(windows.kernel32.GetLastError() == .NOT_FOUND);</span>
<span class="line" id="L197">                            <span class="tok-comment">// We are at another suspend point, we can await safely for the</span>
</span>
<span class="line" id="L198">                            <span class="tok-comment">// function to exit the loop</span>
</span>
<span class="line" id="L199">                            <span class="tok-kw">await</span> dir_entry.value.putter_frame;</span>
<span class="line" id="L200">                        }</span>
<span class="line" id="L201"></span>
<span class="line" id="L202">                        self.allocator.free(dir_entry.key_ptr.*);</span>
<span class="line" id="L203">                        <span class="tok-kw">var</span> file_it = dir_entry.value.file_table.keyIterator();</span>
<span class="line" id="L204">                        <span class="tok-kw">while</span> (file_it.next()) |file_entry| {</span>
<span class="line" id="L205">                            self.allocator.free(file_entry.*);</span>
<span class="line" id="L206">                        }</span>
<span class="line" id="L207">                        dir_entry.value.file_table.deinit(self.allocator);</span>
<span class="line" id="L208">                        self.allocator.destroy(dir_entry.value_ptr.*);</span>
<span class="line" id="L209">                    }</span>
<span class="line" id="L210">                    self.os_data.dir_table.deinit(self.allocator);</span>
<span class="line" id="L211">                },</span>
<span class="line" id="L212">                <span class="tok-kw">else</span> =&gt; <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;Unsupported OS&quot;</span>),</span>
<span class="line" id="L213">            }</span>
<span class="line" id="L214">            self.allocator.free(self.channel.buffer_nodes);</span>
<span class="line" id="L215">            self.channel.deinit();</span>
<span class="line" id="L216">            self.allocator.destroy(self);</span>
<span class="line" id="L217">        }</span>
<span class="line" id="L218"></span>
<span class="line" id="L219">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">addFile</span>(self: *Self, file_path: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, value: V) !?V {</span>
<span class="line" id="L220">            <span class="tok-kw">switch</span> (builtin.os.tag) {</span>
<span class="line" id="L221">                .macos, .freebsd, .netbsd, .dragonfly, .openbsd =&gt; <span class="tok-kw">return</span> addFileKEvent(self, file_path, value),</span>
<span class="line" id="L222">                .linux =&gt; <span class="tok-kw">return</span> addFileLinux(self, file_path, value),</span>
<span class="line" id="L223">                .windows =&gt; <span class="tok-kw">return</span> addFileWindows(self, file_path, value),</span>
<span class="line" id="L224">                <span class="tok-kw">else</span> =&gt; <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;Unsupported OS&quot;</span>),</span>
<span class="line" id="L225">            }</span>
<span class="line" id="L226">        }</span>
<span class="line" id="L227"></span>
<span class="line" id="L228">        <span class="tok-kw">fn</span> <span class="tok-fn">addFileKEvent</span>(self: *Self, file_path: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, value: V) !?V {</span>
<span class="line" id="L229">            <span class="tok-kw">var</span> realpath_buf: [std.fs.MAX_PATH_BYTES]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L230">            <span class="tok-kw">const</span> realpath = <span class="tok-kw">try</span> os.realpath(file_path, &amp;realpath_buf);</span>
<span class="line" id="L231"></span>
<span class="line" id="L232">            <span class="tok-kw">const</span> held = self.os_data.table_lock.acquire();</span>
<span class="line" id="L233">            <span class="tok-kw">defer</span> held.release();</span>
<span class="line" id="L234"></span>
<span class="line" id="L235">            <span class="tok-kw">const</span> gop = <span class="tok-kw">try</span> self.os_data.file_table.getOrPut(self.allocator, realpath);</span>
<span class="line" id="L236">            <span class="tok-kw">errdefer</span> assert(self.os_data.file_table.remove(realpath));</span>
<span class="line" id="L237">            <span class="tok-kw">if</span> (gop.found_existing) {</span>
<span class="line" id="L238">                <span class="tok-kw">const</span> prev_value = gop.value_ptr.value;</span>
<span class="line" id="L239">                gop.value_ptr.value = value;</span>
<span class="line" id="L240">                <span class="tok-kw">return</span> prev_value;</span>
<span class="line" id="L241">            }</span>
<span class="line" id="L242"></span>
<span class="line" id="L243">            gop.key_ptr.* = <span class="tok-kw">try</span> self.allocator.dupe(<span class="tok-type">u8</span>, realpath);</span>
<span class="line" id="L244">            <span class="tok-kw">errdefer</span> self.allocator.free(gop.key_ptr.*);</span>
<span class="line" id="L245">            gop.value_ptr.* = <span class="tok-kw">try</span> self.allocator.create(OsData.Put);</span>
<span class="line" id="L246">            <span class="tok-kw">errdefer</span> self.allocator.destroy(gop.value_ptr.*);</span>
<span class="line" id="L247">            gop.value_ptr.* = .{</span>
<span class="line" id="L248">                .putter_frame = <span class="tok-null">undefined</span>,</span>
<span class="line" id="L249">                .value = value,</span>
<span class="line" id="L250">            };</span>
<span class="line" id="L251"></span>
<span class="line" id="L252">            <span class="tok-comment">// @TODO Can I close this fd and get an error from bsdWaitKev?</span>
</span>
<span class="line" id="L253">            <span class="tok-kw">const</span> flags = <span class="tok-kw">if</span> (<span class="tok-kw">comptime</span> builtin.target.isDarwin()) os.O.SYMLINK | os.O.EVTONLY <span class="tok-kw">else</span> <span class="tok-number">0</span>;</span>
<span class="line" id="L254">            <span class="tok-kw">const</span> fd = <span class="tok-kw">try</span> os.open(realpath, flags, <span class="tok-number">0</span>);</span>
<span class="line" id="L255">            gop.value_ptr.putter_frame = <span class="tok-kw">async</span> self.kqPutEvents(fd, gop.key_ptr.*, gop.value_ptr.*);</span>
<span class="line" id="L256">            <span class="tok-kw">return</span> <span class="tok-null">null</span>;</span>
<span class="line" id="L257">        }</span>
<span class="line" id="L258"></span>
<span class="line" id="L259">        <span class="tok-kw">fn</span> <span class="tok-fn">kqPutEvents</span>(self: *Self, fd: os.fd_t, file_path: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, put: *OsData.Put) <span class="tok-type">void</span> {</span>
<span class="line" id="L260">            global_event_loop.beginOneEvent();</span>
<span class="line" id="L261">            <span class="tok-kw">defer</span> {</span>
<span class="line" id="L262">                global_event_loop.finishOneEvent();</span>
<span class="line" id="L263">                <span class="tok-comment">// @TODO: Remove this if we force close otherwise</span>
</span>
<span class="line" id="L264">                os.close(fd);</span>
<span class="line" id="L265">            }</span>
<span class="line" id="L266"></span>
<span class="line" id="L267">            <span class="tok-comment">// We need to manually do a bsdWaitKev to access the fflags.</span>
</span>
<span class="line" id="L268">            <span class="tok-kw">var</span> resume_node = event.Loop.ResumeNode.Basic{</span>
<span class="line" id="L269">                .base = .{</span>
<span class="line" id="L270">                    .id = .Basic,</span>
<span class="line" id="L271">                    .handle = <span class="tok-builtin">@frame</span>(),</span>
<span class="line" id="L272">                    .overlapped = event.Loop.ResumeNode.overlapped_init,</span>
<span class="line" id="L273">                },</span>
<span class="line" id="L274">                .kev = <span class="tok-null">undefined</span>,</span>
<span class="line" id="L275">            };</span>
<span class="line" id="L276"></span>
<span class="line" id="L277">            <span class="tok-kw">var</span> kevs = [<span class="tok-number">1</span>]os.Kevent{<span class="tok-null">undefined</span>};</span>
<span class="line" id="L278">            <span class="tok-kw">const</span> kev = &amp;kevs[<span class="tok-number">0</span>];</span>
<span class="line" id="L279"></span>
<span class="line" id="L280">            <span class="tok-kw">while</span> (!put.cancelled) {</span>
<span class="line" id="L281">                kev.* = os.Kevent{</span>
<span class="line" id="L282">                    .ident = <span class="tok-builtin">@intCast</span>(<span class="tok-type">usize</span>, fd),</span>
<span class="line" id="L283">                    .filter = os.EVFILT_VNODE,</span>
<span class="line" id="L284">                    .flags = os.EV_ADD | os.EV_ENABLE | os.EV_CLEAR | os.EV_ONESHOT |</span>
<span class="line" id="L285">                        os.NOTE_WRITE | os.NOTE_DELETE | os.NOTE_REVOKE,</span>
<span class="line" id="L286">                    .fflags = <span class="tok-number">0</span>,</span>
<span class="line" id="L287">                    .data = <span class="tok-number">0</span>,</span>
<span class="line" id="L288">                    .udata = <span class="tok-builtin">@ptrToInt</span>(&amp;resume_node.base),</span>
<span class="line" id="L289">                };</span>
<span class="line" id="L290">                <span class="tok-kw">suspend</span> {</span>
<span class="line" id="L291">                    global_event_loop.beginOneEvent();</span>
<span class="line" id="L292">                    <span class="tok-kw">errdefer</span> global_event_loop.finishOneEvent();</span>
<span class="line" id="L293"></span>
<span class="line" id="L294">                    <span class="tok-kw">const</span> empty_kevs = &amp;[<span class="tok-number">0</span>]os.Kevent{};</span>
<span class="line" id="L295">                    _ = os.kevent(global_event_loop.os_data.kqfd, &amp;kevs, empty_kevs, <span class="tok-null">null</span>) <span class="tok-kw">catch</span> |err| <span class="tok-kw">switch</span> (err) {</span>
<span class="line" id="L296">                        <span class="tok-kw">error</span>.EventNotFound,</span>
<span class="line" id="L297">                        <span class="tok-kw">error</span>.ProcessNotFound,</span>
<span class="line" id="L298">                        <span class="tok-kw">error</span>.Overflow,</span>
<span class="line" id="L299">                        =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L300">                        <span class="tok-kw">error</span>.AccessDenied, <span class="tok-kw">error</span>.SystemResources =&gt; |e| {</span>
<span class="line" id="L301">                            self.channel.put(e);</span>
<span class="line" id="L302">                            <span class="tok-kw">continue</span>;</span>
<span class="line" id="L303">                        },</span>
<span class="line" id="L304">                    };</span>
<span class="line" id="L305">                }</span>
<span class="line" id="L306"></span>
<span class="line" id="L307">                <span class="tok-kw">if</span> (kev.flags &amp; os.EV_ERROR != <span class="tok-number">0</span>) {</span>
<span class="line" id="L308">                    self.channel.put(os.unexpectedErrno(os.errno(kev.data)));</span>
<span class="line" id="L309">                    <span class="tok-kw">continue</span>;</span>
<span class="line" id="L310">                }</span>
<span class="line" id="L311"></span>
<span class="line" id="L312">                <span class="tok-kw">if</span> (kev.fflags &amp; os.NOTE_DELETE != <span class="tok-number">0</span> <span class="tok-kw">or</span> kev.fflags &amp; os.NOTE_REVOKE != <span class="tok-number">0</span>) {</span>
<span class="line" id="L313">                    self.channel.put(Self.Event{</span>
<span class="line" id="L314">                        .id = .Delete,</span>
<span class="line" id="L315">                        .data = put.value,</span>
<span class="line" id="L316">                        .dirname = std.fs.path.dirname(file_path) <span class="tok-kw">orelse</span> <span class="tok-str">&quot;/&quot;</span>,</span>
<span class="line" id="L317">                        .basename = std.fs.path.basename(file_path),</span>
<span class="line" id="L318">                    });</span>
<span class="line" id="L319">                } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (kev.fflags &amp; os.NOTE_WRITE != <span class="tok-number">0</span>) {</span>
<span class="line" id="L320">                    self.channel.put(Self.Event{</span>
<span class="line" id="L321">                        .id = .CloseWrite,</span>
<span class="line" id="L322">                        .data = put.value,</span>
<span class="line" id="L323">                        .dirname = std.fs.path.dirname(file_path) <span class="tok-kw">orelse</span> <span class="tok-str">&quot;/&quot;</span>,</span>
<span class="line" id="L324">                        .basename = std.fs.path.basename(file_path),</span>
<span class="line" id="L325">                    });</span>
<span class="line" id="L326">                }</span>
<span class="line" id="L327">            }</span>
<span class="line" id="L328">        }</span>
<span class="line" id="L329"></span>
<span class="line" id="L330">        <span class="tok-kw">fn</span> <span class="tok-fn">addFileLinux</span>(self: *Self, file_path: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, value: V) !?V {</span>
<span class="line" id="L331">            <span class="tok-kw">const</span> dirname = std.fs.path.dirname(file_path) <span class="tok-kw">orelse</span> <span class="tok-kw">if</span> (file_path[<span class="tok-number">0</span>] == <span class="tok-str">'/'</span>) <span class="tok-str">&quot;/&quot;</span> <span class="tok-kw">else</span> <span class="tok-str">&quot;.&quot;</span>;</span>
<span class="line" id="L332">            <span class="tok-kw">const</span> basename = std.fs.path.basename(file_path);</span>
<span class="line" id="L333"></span>
<span class="line" id="L334">            <span class="tok-kw">const</span> wd = <span class="tok-kw">try</span> os.inotify_add_watch(</span>
<span class="line" id="L335">                self.os_data.inotify_fd,</span>
<span class="line" id="L336">                dirname,</span>
<span class="line" id="L337">                os.linux.IN_CLOSE_WRITE | os.linux.IN_ONLYDIR | os.linux.IN_DELETE | os.linux.IN_EXCL_UNLINK,</span>
<span class="line" id="L338">            );</span>
<span class="line" id="L339">            <span class="tok-comment">// wd is either a newly created watch or an existing one.</span>
</span>
<span class="line" id="L340"></span>
<span class="line" id="L341">            <span class="tok-kw">const</span> held = self.os_data.table_lock.acquire();</span>
<span class="line" id="L342">            <span class="tok-kw">defer</span> held.release();</span>
<span class="line" id="L343"></span>
<span class="line" id="L344">            <span class="tok-kw">const</span> gop = <span class="tok-kw">try</span> self.os_data.wd_table.getOrPut(self.allocator, wd);</span>
<span class="line" id="L345">            <span class="tok-kw">errdefer</span> assert(self.os_data.wd_table.remove(wd));</span>
<span class="line" id="L346">            <span class="tok-kw">if</span> (!gop.found_existing) {</span>
<span class="line" id="L347">                gop.value_ptr.* = OsData.Dir{</span>
<span class="line" id="L348">                    .dirname = <span class="tok-kw">try</span> self.allocator.dupe(<span class="tok-type">u8</span>, dirname),</span>
<span class="line" id="L349">                    .file_table = OsData.FileTable.init(self.allocator),</span>
<span class="line" id="L350">                };</span>
<span class="line" id="L351">            }</span>
<span class="line" id="L352"></span>
<span class="line" id="L353">            <span class="tok-kw">const</span> dir = gop.value_ptr;</span>
<span class="line" id="L354">            <span class="tok-kw">const</span> file_table_gop = <span class="tok-kw">try</span> dir.file_table.getOrPut(self.allocator, basename);</span>
<span class="line" id="L355">            <span class="tok-kw">errdefer</span> assert(dir.file_table.remove(basename));</span>
<span class="line" id="L356">            <span class="tok-kw">if</span> (file_table_gop.found_existing) {</span>
<span class="line" id="L357">                <span class="tok-kw">const</span> prev_value = file_table_gop.value_ptr.*;</span>
<span class="line" id="L358">                file_table_gop.value_ptr.* = value;</span>
<span class="line" id="L359">                <span class="tok-kw">return</span> prev_value;</span>
<span class="line" id="L360">            } <span class="tok-kw">else</span> {</span>
<span class="line" id="L361">                file_table_gop.key_ptr.* = <span class="tok-kw">try</span> self.allocator.dupe(<span class="tok-type">u8</span>, basename);</span>
<span class="line" id="L362">                file_table_gop.value_ptr.* = value;</span>
<span class="line" id="L363">                <span class="tok-kw">return</span> <span class="tok-null">null</span>;</span>
<span class="line" id="L364">            }</span>
<span class="line" id="L365">        }</span>
<span class="line" id="L366"></span>
<span class="line" id="L367">        <span class="tok-kw">fn</span> <span class="tok-fn">addFileWindows</span>(self: *Self, file_path: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, value: V) !?V {</span>
<span class="line" id="L368">            <span class="tok-comment">// TODO we might need to convert dirname and basename to canonical file paths (&quot;short&quot;?)</span>
</span>
<span class="line" id="L369">            <span class="tok-kw">const</span> dirname = std.fs.path.dirname(file_path) <span class="tok-kw">orelse</span> <span class="tok-kw">if</span> (file_path[<span class="tok-number">0</span>] == <span class="tok-str">'/'</span>) <span class="tok-str">&quot;/&quot;</span> <span class="tok-kw">else</span> <span class="tok-str">&quot;.&quot;</span>;</span>
<span class="line" id="L370">            <span class="tok-kw">var</span> dirname_path_space: windows.PathSpace = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L371">            dirname_path_space.len = <span class="tok-kw">try</span> std.unicode.utf8ToUtf16Le(&amp;dirname_path_space.data, dirname);</span>
<span class="line" id="L372">            dirname_path_space.data[dirname_path_space.len] = <span class="tok-number">0</span>;</span>
<span class="line" id="L373"></span>
<span class="line" id="L374">            <span class="tok-kw">const</span> basename = std.fs.path.basename(file_path);</span>
<span class="line" id="L375">            <span class="tok-kw">var</span> basename_path_space: windows.PathSpace = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L376">            basename_path_space.len = <span class="tok-kw">try</span> std.unicode.utf8ToUtf16Le(&amp;basename_path_space.data, basename);</span>
<span class="line" id="L377">            basename_path_space.data[basename_path_space.len] = <span class="tok-number">0</span>;</span>
<span class="line" id="L378"></span>
<span class="line" id="L379">            <span class="tok-kw">const</span> held = self.os_data.table_lock.acquire();</span>
<span class="line" id="L380">            <span class="tok-kw">defer</span> held.release();</span>
<span class="line" id="L381"></span>
<span class="line" id="L382">            <span class="tok-kw">const</span> gop = <span class="tok-kw">try</span> self.os_data.dir_table.getOrPut(self.allocator, dirname);</span>
<span class="line" id="L383">            <span class="tok-kw">errdefer</span> assert(self.os_data.dir_table.remove(dirname));</span>
<span class="line" id="L384">            <span class="tok-kw">if</span> (gop.found_existing) {</span>
<span class="line" id="L385">                <span class="tok-kw">const</span> dir = gop.value_ptr.*;</span>
<span class="line" id="L386"></span>
<span class="line" id="L387">                <span class="tok-kw">const</span> file_gop = <span class="tok-kw">try</span> dir.file_table.getOrPut(self.allocator, basename);</span>
<span class="line" id="L388">                <span class="tok-kw">errdefer</span> assert(dir.file_table.remove(basename));</span>
<span class="line" id="L389">                <span class="tok-kw">if</span> (file_gop.found_existing) {</span>
<span class="line" id="L390">                    <span class="tok-kw">const</span> prev_value = file_gop.value_ptr.*;</span>
<span class="line" id="L391">                    file_gop.value_ptr.* = value;</span>
<span class="line" id="L392">                    <span class="tok-kw">return</span> prev_value;</span>
<span class="line" id="L393">                } <span class="tok-kw">else</span> {</span>
<span class="line" id="L394">                    file_gop.value_ptr.* = value;</span>
<span class="line" id="L395">                    file_gop.key_ptr.* = <span class="tok-kw">try</span> self.allocator.dupe(<span class="tok-type">u8</span>, basename);</span>
<span class="line" id="L396">                    <span class="tok-kw">return</span> <span class="tok-null">null</span>;</span>
<span class="line" id="L397">                }</span>
<span class="line" id="L398">            } <span class="tok-kw">else</span> {</span>
<span class="line" id="L399">                <span class="tok-kw">const</span> dir_handle = <span class="tok-kw">try</span> windows.OpenFile(dirname_path_space.span(), .{</span>
<span class="line" id="L400">                    .dir = std.fs.cwd().fd,</span>
<span class="line" id="L401">                    .access_mask = windows.FILE_LIST_DIRECTORY,</span>
<span class="line" id="L402">                    .creation = windows.FILE_OPEN,</span>
<span class="line" id="L403">                    .io_mode = .evented,</span>
<span class="line" id="L404">                    .filter = .dir_only,</span>
<span class="line" id="L405">                });</span>
<span class="line" id="L406">                <span class="tok-kw">errdefer</span> windows.CloseHandle(dir_handle);</span>
<span class="line" id="L407"></span>
<span class="line" id="L408">                <span class="tok-kw">const</span> dir = <span class="tok-kw">try</span> self.allocator.create(OsData.Dir);</span>
<span class="line" id="L409">                <span class="tok-kw">errdefer</span> self.allocator.destroy(dir);</span>
<span class="line" id="L410"></span>
<span class="line" id="L411">                gop.key_ptr.* = <span class="tok-kw">try</span> self.allocator.dupe(<span class="tok-type">u8</span>, dirname);</span>
<span class="line" id="L412">                <span class="tok-kw">errdefer</span> self.allocator.free(gop.key_ptr.*);</span>
<span class="line" id="L413"></span>
<span class="line" id="L414">                dir.* = OsData.Dir{</span>
<span class="line" id="L415">                    .file_table = OsData.FileTable.init(self.allocator),</span>
<span class="line" id="L416">                    .putter_frame = <span class="tok-null">undefined</span>,</span>
<span class="line" id="L417">                    .dir_handle = dir_handle,</span>
<span class="line" id="L418">                };</span>
<span class="line" id="L419">                gop.value_ptr.* = dir;</span>
<span class="line" id="L420">                <span class="tok-kw">try</span> dir.file_table.put(self.allocator, <span class="tok-kw">try</span> self.allocator.dupe(<span class="tok-type">u8</span>, basename), value);</span>
<span class="line" id="L421">                dir.putter_frame = <span class="tok-kw">async</span> self.windowsDirReader(dir, gop.key_ptr.*);</span>
<span class="line" id="L422">                <span class="tok-kw">return</span> <span class="tok-null">null</span>;</span>
<span class="line" id="L423">            }</span>
<span class="line" id="L424">        }</span>
<span class="line" id="L425"></span>
<span class="line" id="L426">        <span class="tok-kw">fn</span> <span class="tok-fn">windowsDirReader</span>(self: *Self, dir: *OsData.Dir, dirname: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L427">            <span class="tok-kw">defer</span> os.close(dir.dir_handle);</span>
<span class="line" id="L428">            <span class="tok-kw">var</span> resume_node = Loop.ResumeNode.Basic{</span>
<span class="line" id="L429">                .base = Loop.ResumeNode{</span>
<span class="line" id="L430">                    .id = .Basic,</span>
<span class="line" id="L431">                    .handle = <span class="tok-builtin">@frame</span>(),</span>
<span class="line" id="L432">                    .overlapped = windows.OVERLAPPED{</span>
<span class="line" id="L433">                        .Internal = <span class="tok-number">0</span>,</span>
<span class="line" id="L434">                        .InternalHigh = <span class="tok-number">0</span>,</span>
<span class="line" id="L435">                        .DUMMYUNIONNAME = .{</span>
<span class="line" id="L436">                            .DUMMYSTRUCTNAME = .{</span>
<span class="line" id="L437">                                .Offset = <span class="tok-number">0</span>,</span>
<span class="line" id="L438">                                .OffsetHigh = <span class="tok-number">0</span>,</span>
<span class="line" id="L439">                            },</span>
<span class="line" id="L440">                        },</span>
<span class="line" id="L441">                        .hEvent = <span class="tok-null">null</span>,</span>
<span class="line" id="L442">                    },</span>
<span class="line" id="L443">                },</span>
<span class="line" id="L444">            };</span>
<span class="line" id="L445"></span>
<span class="line" id="L446">            <span class="tok-kw">var</span> event_buf: [<span class="tok-number">4096</span>]<span class="tok-type">u8</span> <span class="tok-kw">align</span>(<span class="tok-builtin">@alignOf</span>(windows.FILE_NOTIFY_INFORMATION)) = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L447"></span>
<span class="line" id="L448">            global_event_loop.beginOneEvent();</span>
<span class="line" id="L449">            <span class="tok-kw">defer</span> global_event_loop.finishOneEvent();</span>
<span class="line" id="L450"></span>
<span class="line" id="L451">            <span class="tok-kw">while</span> (!self.os_data.cancelled) main_loop: {</span>
<span class="line" id="L452">                <span class="tok-kw">suspend</span> {</span>
<span class="line" id="L453">                    _ = windows.kernel32.ReadDirectoryChangesW(</span>
<span class="line" id="L454">                        dir.dir_handle,</span>
<span class="line" id="L455">                        &amp;event_buf,</span>
<span class="line" id="L456">                        event_buf.len,</span>
<span class="line" id="L457">                        windows.FALSE, <span class="tok-comment">// watch subtree</span>
</span>
<span class="line" id="L458">                        windows.FILE_NOTIFY_CHANGE_FILE_NAME | windows.FILE_NOTIFY_CHANGE_DIR_NAME |</span>
<span class="line" id="L459">                            windows.FILE_NOTIFY_CHANGE_ATTRIBUTES | windows.FILE_NOTIFY_CHANGE_SIZE |</span>
<span class="line" id="L460">                            windows.FILE_NOTIFY_CHANGE_LAST_WRITE | windows.FILE_NOTIFY_CHANGE_LAST_ACCESS |</span>
<span class="line" id="L461">                            windows.FILE_NOTIFY_CHANGE_CREATION | windows.FILE_NOTIFY_CHANGE_SECURITY,</span>
<span class="line" id="L462">                        <span class="tok-null">null</span>, <span class="tok-comment">// number of bytes transferred (unused for async)</span>
</span>
<span class="line" id="L463">                        &amp;resume_node.base.overlapped,</span>
<span class="line" id="L464">                        <span class="tok-null">null</span>, <span class="tok-comment">// completion routine - unused because we use IOCP</span>
</span>
<span class="line" id="L465">                    );</span>
<span class="line" id="L466">                }</span>
<span class="line" id="L467"></span>
<span class="line" id="L468">                <span class="tok-kw">var</span> bytes_transferred: windows.DWORD = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L469">                <span class="tok-kw">if</span> (windows.kernel32.GetOverlappedResult(</span>
<span class="line" id="L470">                    dir.dir_handle,</span>
<span class="line" id="L471">                    &amp;resume_node.base.overlapped,</span>
<span class="line" id="L472">                    &amp;bytes_transferred,</span>
<span class="line" id="L473">                    windows.FALSE,</span>
<span class="line" id="L474">                ) == <span class="tok-number">0</span>) {</span>
<span class="line" id="L475">                    <span class="tok-kw">const</span> potential_error = windows.kernel32.GetLastError();</span>
<span class="line" id="L476">                    <span class="tok-kw">const</span> err = <span class="tok-kw">switch</span> (potential_error) {</span>
<span class="line" id="L477">                        .OPERATION_ABORTED, .IO_INCOMPLETE =&gt; err_blk: {</span>
<span class="line" id="L478">                            <span class="tok-kw">if</span> (self.os_data.cancelled)</span>
<span class="line" id="L479">                                <span class="tok-kw">break</span> :main_loop</span>
<span class="line" id="L480">                            <span class="tok-kw">else</span></span>
<span class="line" id="L481">                                <span class="tok-kw">break</span> :err_blk windows.unexpectedError(potential_error);</span>
<span class="line" id="L482">                        },</span>
<span class="line" id="L483">                        <span class="tok-kw">else</span> =&gt; |err| windows.unexpectedError(err),</span>
<span class="line" id="L484">                    };</span>
<span class="line" id="L485">                    self.channel.put(err);</span>
<span class="line" id="L486">                } <span class="tok-kw">else</span> {</span>
<span class="line" id="L487">                    <span class="tok-kw">var</span> ptr: [*]<span class="tok-type">u8</span> = &amp;event_buf;</span>
<span class="line" id="L488">                    <span class="tok-kw">const</span> end_ptr = ptr + bytes_transferred;</span>
<span class="line" id="L489">                    <span class="tok-kw">while</span> (<span class="tok-builtin">@ptrToInt</span>(ptr) &lt; <span class="tok-builtin">@ptrToInt</span>(end_ptr)) {</span>
<span class="line" id="L490">                        <span class="tok-kw">const</span> ev = <span class="tok-builtin">@ptrCast</span>(*<span class="tok-kw">const</span> windows.FILE_NOTIFY_INFORMATION, ptr);</span>
<span class="line" id="L491">                        <span class="tok-kw">const</span> emit = <span class="tok-kw">switch</span> (ev.Action) {</span>
<span class="line" id="L492">                            windows.FILE_ACTION_REMOVED =&gt; WatchEventId.Delete,</span>
<span class="line" id="L493">                            windows.FILE_ACTION_MODIFIED =&gt; .CloseWrite,</span>
<span class="line" id="L494">                            <span class="tok-kw">else</span> =&gt; <span class="tok-null">null</span>,</span>
<span class="line" id="L495">                        };</span>
<span class="line" id="L496">                        <span class="tok-kw">if</span> (emit) |id| {</span>
<span class="line" id="L497">                            <span class="tok-kw">const</span> basename_ptr = <span class="tok-builtin">@ptrCast</span>([*]<span class="tok-type">u16</span>, ptr + <span class="tok-builtin">@sizeOf</span>(windows.FILE_NOTIFY_INFORMATION));</span>
<span class="line" id="L498">                            <span class="tok-kw">const</span> basename_utf16le = basename_ptr[<span class="tok-number">0</span> .. ev.FileNameLength / <span class="tok-number">2</span>];</span>
<span class="line" id="L499">                            <span class="tok-kw">var</span> basename_data: [std.fs.MAX_PATH_BYTES]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L500">                            <span class="tok-kw">const</span> basename = basename_data[<span class="tok-number">0</span> .. std.unicode.utf16leToUtf8(&amp;basename_data, basename_utf16le) <span class="tok-kw">catch</span> <span class="tok-kw">unreachable</span>];</span>
<span class="line" id="L501"></span>
<span class="line" id="L502">                            <span class="tok-kw">if</span> (dir.file_table.getEntry(basename)) |entry| {</span>
<span class="line" id="L503">                                self.channel.put(Event{</span>
<span class="line" id="L504">                                    .id = id,</span>
<span class="line" id="L505">                                    .data = entry.value_ptr.*,</span>
<span class="line" id="L506">                                    .dirname = dirname,</span>
<span class="line" id="L507">                                    .basename = entry.key_ptr.*,</span>
<span class="line" id="L508">                                });</span>
<span class="line" id="L509">                            }</span>
<span class="line" id="L510">                        }</span>
<span class="line" id="L511"></span>
<span class="line" id="L512">                        <span class="tok-kw">if</span> (ev.NextEntryOffset == <span class="tok-number">0</span>) <span class="tok-kw">break</span>;</span>
<span class="line" id="L513">                        ptr = <span class="tok-builtin">@alignCast</span>(<span class="tok-builtin">@alignOf</span>(windows.FILE_NOTIFY_INFORMATION), ptr + ev.NextEntryOffset);</span>
<span class="line" id="L514">                    }</span>
<span class="line" id="L515">                }</span>
<span class="line" id="L516">            }</span>
<span class="line" id="L517">        }</span>
<span class="line" id="L518"></span>
<span class="line" id="L519">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">removeFile</span>(self: *Self, file_path: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) !?V {</span>
<span class="line" id="L520">            <span class="tok-kw">switch</span> (builtin.os.tag) {</span>
<span class="line" id="L521">                .linux =&gt; {</span>
<span class="line" id="L522">                    <span class="tok-kw">const</span> dirname = std.fs.path.dirname(file_path) <span class="tok-kw">orelse</span> <span class="tok-kw">if</span> (file_path[<span class="tok-number">0</span>] == <span class="tok-str">'/'</span>) <span class="tok-str">&quot;/&quot;</span> <span class="tok-kw">else</span> <span class="tok-str">&quot;.&quot;</span>;</span>
<span class="line" id="L523">                    <span class="tok-kw">const</span> basename = std.fs.path.basename(file_path);</span>
<span class="line" id="L524"></span>
<span class="line" id="L525">                    <span class="tok-kw">const</span> held = self.os_data.table_lock.acquire();</span>
<span class="line" id="L526">                    <span class="tok-kw">defer</span> held.release();</span>
<span class="line" id="L527"></span>
<span class="line" id="L528">                    <span class="tok-kw">const</span> dir = self.os_data.wd_table.get(dirname) <span class="tok-kw">orelse</span> <span class="tok-kw">return</span> <span class="tok-null">null</span>;</span>
<span class="line" id="L529">                    <span class="tok-kw">if</span> (dir.file_table.fetchRemove(basename)) |file_entry| {</span>
<span class="line" id="L530">                        self.allocator.free(file_entry.key);</span>
<span class="line" id="L531">                        <span class="tok-kw">return</span> file_entry.value;</span>
<span class="line" id="L532">                    }</span>
<span class="line" id="L533">                    <span class="tok-kw">return</span> <span class="tok-null">null</span>;</span>
<span class="line" id="L534">                },</span>
<span class="line" id="L535">                .windows =&gt; {</span>
<span class="line" id="L536">                    <span class="tok-kw">const</span> dirname = std.fs.path.dirname(file_path) <span class="tok-kw">orelse</span> <span class="tok-kw">if</span> (file_path[<span class="tok-number">0</span>] == <span class="tok-str">'/'</span>) <span class="tok-str">&quot;/&quot;</span> <span class="tok-kw">else</span> <span class="tok-str">&quot;.&quot;</span>;</span>
<span class="line" id="L537">                    <span class="tok-kw">const</span> basename = std.fs.path.basename(file_path);</span>
<span class="line" id="L538"></span>
<span class="line" id="L539">                    <span class="tok-kw">const</span> held = self.os_data.table_lock.acquire();</span>
<span class="line" id="L540">                    <span class="tok-kw">defer</span> held.release();</span>
<span class="line" id="L541"></span>
<span class="line" id="L542">                    <span class="tok-kw">const</span> dir = self.os_data.dir_table.get(dirname) <span class="tok-kw">orelse</span> <span class="tok-kw">return</span> <span class="tok-null">null</span>;</span>
<span class="line" id="L543">                    <span class="tok-kw">if</span> (dir.file_table.fetchRemove(basename)) |file_entry| {</span>
<span class="line" id="L544">                        self.allocator.free(file_entry.key);</span>
<span class="line" id="L545">                        <span class="tok-kw">return</span> file_entry.value;</span>
<span class="line" id="L546">                    }</span>
<span class="line" id="L547">                    <span class="tok-kw">return</span> <span class="tok-null">null</span>;</span>
<span class="line" id="L548">                },</span>
<span class="line" id="L549">                .macos, .freebsd, .netbsd, .dragonfly, .openbsd =&gt; {</span>
<span class="line" id="L550">                    <span class="tok-kw">var</span> realpath_buf: [std.fs.MAX_PATH_BYTES]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L551">                    <span class="tok-kw">const</span> realpath = <span class="tok-kw">try</span> os.realpath(file_path, &amp;realpath_buf);</span>
<span class="line" id="L552"></span>
<span class="line" id="L553">                    <span class="tok-kw">const</span> held = self.os_data.table_lock.acquire();</span>
<span class="line" id="L554">                    <span class="tok-kw">defer</span> held.release();</span>
<span class="line" id="L555"></span>
<span class="line" id="L556">                    <span class="tok-kw">const</span> entry = self.os_data.file_table.getEntry(realpath) <span class="tok-kw">orelse</span> <span class="tok-kw">return</span> <span class="tok-null">null</span>;</span>
<span class="line" id="L557">                    entry.value_ptr.cancelled = <span class="tok-null">true</span>;</span>
<span class="line" id="L558">                    <span class="tok-comment">// @TODO Close the fd here?</span>
</span>
<span class="line" id="L559">                    <span class="tok-kw">await</span> entry.value_ptr.putter_frame;</span>
<span class="line" id="L560">                    self.allocator.free(entry.key_ptr.*);</span>
<span class="line" id="L561">                    self.allocator.destroy(entry.value_ptr.*);</span>
<span class="line" id="L562"></span>
<span class="line" id="L563">                    assert(self.os_data.file_table.remove(realpath));</span>
<span class="line" id="L564">                },</span>
<span class="line" id="L565">                <span class="tok-kw">else</span> =&gt; <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;Unsupported OS&quot;</span>),</span>
<span class="line" id="L566">            }</span>
<span class="line" id="L567">        }</span>
<span class="line" id="L568"></span>
<span class="line" id="L569">        <span class="tok-kw">fn</span> <span class="tok-fn">linuxEventPutter</span>(self: *Self) <span class="tok-type">void</span> {</span>
<span class="line" id="L570">            global_event_loop.beginOneEvent();</span>
<span class="line" id="L571"></span>
<span class="line" id="L572">            <span class="tok-kw">defer</span> {</span>
<span class="line" id="L573">                std.debug.assert(self.os_data.wd_table.count() == <span class="tok-number">0</span>);</span>
<span class="line" id="L574">                self.os_data.wd_table.deinit(self.allocator);</span>
<span class="line" id="L575">                os.close(self.os_data.inotify_fd);</span>
<span class="line" id="L576">                self.allocator.free(self.channel.buffer_nodes);</span>
<span class="line" id="L577">                self.channel.deinit();</span>
<span class="line" id="L578">                global_event_loop.finishOneEvent();</span>
<span class="line" id="L579">            }</span>
<span class="line" id="L580"></span>
<span class="line" id="L581">            <span class="tok-kw">var</span> event_buf: [<span class="tok-number">4096</span>]<span class="tok-type">u8</span> <span class="tok-kw">align</span>(<span class="tok-builtin">@alignOf</span>(os.linux.inotify_event)) = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L582"></span>
<span class="line" id="L583">            <span class="tok-kw">while</span> (!self.os_data.cancelled) {</span>
<span class="line" id="L584">                <span class="tok-kw">const</span> bytes_read = global_event_loop.read(self.os_data.inotify_fd, &amp;event_buf, <span class="tok-null">false</span>) <span class="tok-kw">catch</span> <span class="tok-kw">unreachable</span>;</span>
<span class="line" id="L585"></span>
<span class="line" id="L586">                <span class="tok-kw">var</span> ptr: [*]<span class="tok-type">u8</span> = &amp;event_buf;</span>
<span class="line" id="L587">                <span class="tok-kw">const</span> end_ptr = ptr + bytes_read;</span>
<span class="line" id="L588">                <span class="tok-kw">while</span> (<span class="tok-builtin">@ptrToInt</span>(ptr) &lt; <span class="tok-builtin">@ptrToInt</span>(end_ptr)) {</span>
<span class="line" id="L589">                    <span class="tok-kw">const</span> ev = <span class="tok-builtin">@ptrCast</span>(*<span class="tok-kw">const</span> os.linux.inotify_event, ptr);</span>
<span class="line" id="L590">                    <span class="tok-kw">if</span> (ev.mask &amp; os.linux.IN_CLOSE_WRITE == os.linux.IN_CLOSE_WRITE) {</span>
<span class="line" id="L591">                        <span class="tok-kw">const</span> basename_ptr = ptr + <span class="tok-builtin">@sizeOf</span>(os.linux.inotify_event);</span>
<span class="line" id="L592">                        <span class="tok-kw">const</span> basename = std.mem.span(<span class="tok-builtin">@ptrCast</span>([*:<span class="tok-number">0</span>]<span class="tok-type">u8</span>, basename_ptr));</span>
<span class="line" id="L593"></span>
<span class="line" id="L594">                        <span class="tok-kw">const</span> dir = &amp;self.os_data.wd_table.get(ev.wd).?;</span>
<span class="line" id="L595">                        <span class="tok-kw">if</span> (dir.file_table.getEntry(basename)) |file_value| {</span>
<span class="line" id="L596">                            self.channel.put(Event{</span>
<span class="line" id="L597">                                .id = .CloseWrite,</span>
<span class="line" id="L598">                                .data = file_value.value_ptr.*,</span>
<span class="line" id="L599">                                .dirname = dir.dirname,</span>
<span class="line" id="L600">                                .basename = file_value.key_ptr.*,</span>
<span class="line" id="L601">                            });</span>
<span class="line" id="L602">                        }</span>
<span class="line" id="L603">                    } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (ev.mask &amp; os.linux.IN_IGNORED == os.linux.IN_IGNORED) {</span>
<span class="line" id="L604">                        <span class="tok-comment">// Directory watch was removed</span>
</span>
<span class="line" id="L605">                        <span class="tok-kw">const</span> held = self.os_data.table_lock.acquire();</span>
<span class="line" id="L606">                        <span class="tok-kw">defer</span> held.release();</span>
<span class="line" id="L607">                        <span class="tok-kw">if</span> (self.os_data.wd_table.fetchRemove(ev.wd)) |wd_entry| {</span>
<span class="line" id="L608">                            <span class="tok-kw">var</span> file_it = wd_entry.value.file_table.keyIterator();</span>
<span class="line" id="L609">                            <span class="tok-kw">while</span> (file_it.next()) |file_entry| {</span>
<span class="line" id="L610">                                self.allocator.free(file_entry.*);</span>
<span class="line" id="L611">                            }</span>
<span class="line" id="L612">                            self.allocator.free(wd_entry.value.dirname);</span>
<span class="line" id="L613">                            wd_entry.value.file_table.deinit(self.allocator);</span>
<span class="line" id="L614">                        }</span>
<span class="line" id="L615">                    } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (ev.mask &amp; os.linux.IN_DELETE == os.linux.IN_DELETE) {</span>
<span class="line" id="L616">                        <span class="tok-comment">// File or directory was removed or deleted</span>
</span>
<span class="line" id="L617">                        <span class="tok-kw">const</span> basename_ptr = ptr + <span class="tok-builtin">@sizeOf</span>(os.linux.inotify_event);</span>
<span class="line" id="L618">                        <span class="tok-kw">const</span> basename = std.mem.span(<span class="tok-builtin">@ptrCast</span>([*:<span class="tok-number">0</span>]<span class="tok-type">u8</span>, basename_ptr));</span>
<span class="line" id="L619"></span>
<span class="line" id="L620">                        <span class="tok-kw">const</span> dir = &amp;self.os_data.wd_table.get(ev.wd).?;</span>
<span class="line" id="L621">                        <span class="tok-kw">if</span> (dir.file_table.getEntry(basename)) |file_value| {</span>
<span class="line" id="L622">                            self.channel.put(Event{</span>
<span class="line" id="L623">                                .id = .Delete,</span>
<span class="line" id="L624">                                .data = file_value.value_ptr.*,</span>
<span class="line" id="L625">                                .dirname = dir.dirname,</span>
<span class="line" id="L626">                                .basename = file_value.key_ptr.*,</span>
<span class="line" id="L627">                            });</span>
<span class="line" id="L628">                        }</span>
<span class="line" id="L629">                    }</span>
<span class="line" id="L630"></span>
<span class="line" id="L631">                    ptr = <span class="tok-builtin">@alignCast</span>(<span class="tok-builtin">@alignOf</span>(os.linux.inotify_event), ptr + <span class="tok-builtin">@sizeOf</span>(os.linux.inotify_event) + ev.len);</span>
<span class="line" id="L632">                }</span>
<span class="line" id="L633">            }</span>
<span class="line" id="L634">        }</span>
<span class="line" id="L635">    };</span>
<span class="line" id="L636">}</span>
<span class="line" id="L637"></span>
<span class="line" id="L638"><span class="tok-kw">const</span> test_tmp_dir = <span class="tok-str">&quot;std_event_fs_test&quot;</span>;</span>
<span class="line" id="L639"></span>
<span class="line" id="L640"><span class="tok-kw">test</span> <span class="tok-str">&quot;write a file, watch it, write it again, delete it&quot;</span> {</span>
<span class="line" id="L641">    <span class="tok-kw">if</span> (!std.io.is_async) <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SkipZigTest;</span>
<span class="line" id="L642">    <span class="tok-comment">// TODO https://github.com/ziglang/zig/issues/1908</span>
</span>
<span class="line" id="L643">    <span class="tok-kw">if</span> (builtin.single_threaded) <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SkipZigTest;</span>
<span class="line" id="L644"></span>
<span class="line" id="L645">    <span class="tok-kw">try</span> std.fs.cwd().makePath(test_tmp_dir);</span>
<span class="line" id="L646">    <span class="tok-kw">defer</span> std.fs.cwd().deleteTree(test_tmp_dir) <span class="tok-kw">catch</span> {};</span>
<span class="line" id="L647"></span>
<span class="line" id="L648">    <span class="tok-kw">return</span> testWriteWatchWriteDelete(std.testing.allocator);</span>
<span class="line" id="L649">}</span>
<span class="line" id="L650"></span>
<span class="line" id="L651"><span class="tok-kw">fn</span> <span class="tok-fn">testWriteWatchWriteDelete</span>(allocator: Allocator) !<span class="tok-type">void</span> {</span>
<span class="line" id="L652">    <span class="tok-kw">const</span> file_path = <span class="tok-kw">try</span> std.fs.path.join(allocator, &amp;[_][]<span class="tok-kw">const</span> <span class="tok-type">u8</span>{ test_tmp_dir, <span class="tok-str">&quot;file.txt&quot;</span> });</span>
<span class="line" id="L653">    <span class="tok-kw">defer</span> allocator.free(file_path);</span>
<span class="line" id="L654"></span>
<span class="line" id="L655">    <span class="tok-kw">const</span> contents =</span>
<span class="line" id="L656">        <span class="tok-str">\\line 1</span></span>

<span class="line" id="L657">        <span class="tok-str">\\line 2</span></span>

<span class="line" id="L658">    ;</span>
<span class="line" id="L659">    <span class="tok-kw">const</span> line2_offset = <span class="tok-number">7</span>;</span>
<span class="line" id="L660"></span>
<span class="line" id="L661">    <span class="tok-comment">// first just write then read the file</span>
</span>
<span class="line" id="L662">    <span class="tok-kw">try</span> std.fs.cwd().writeFile(file_path, contents);</span>
<span class="line" id="L663"></span>
<span class="line" id="L664">    <span class="tok-kw">const</span> read_contents = <span class="tok-kw">try</span> std.fs.cwd().readFileAlloc(allocator, file_path, <span class="tok-number">1024</span> * <span class="tok-number">1024</span>);</span>
<span class="line" id="L665">    <span class="tok-kw">defer</span> allocator.free(read_contents);</span>
<span class="line" id="L666">    <span class="tok-kw">try</span> testing.expectEqualSlices(<span class="tok-type">u8</span>, contents, read_contents);</span>
<span class="line" id="L667"></span>
<span class="line" id="L668">    <span class="tok-comment">// now watch the file</span>
</span>
<span class="line" id="L669">    <span class="tok-kw">var</span> watch = <span class="tok-kw">try</span> Watch(<span class="tok-type">void</span>).init(allocator, <span class="tok-number">0</span>);</span>
<span class="line" id="L670">    <span class="tok-kw">defer</span> watch.deinit();</span>
<span class="line" id="L671"></span>
<span class="line" id="L672">    <span class="tok-kw">try</span> testing.expect((<span class="tok-kw">try</span> watch.addFile(file_path, {})) == <span class="tok-null">null</span>);</span>
<span class="line" id="L673"></span>
<span class="line" id="L674">    <span class="tok-kw">var</span> ev = <span class="tok-kw">async</span> watch.channel.get();</span>
<span class="line" id="L675">    <span class="tok-kw">var</span> ev_consumed = <span class="tok-null">false</span>;</span>
<span class="line" id="L676">    <span class="tok-kw">defer</span> <span class="tok-kw">if</span> (!ev_consumed) {</span>
<span class="line" id="L677">        _ = <span class="tok-kw">await</span> ev;</span>
<span class="line" id="L678">    };</span>
<span class="line" id="L679"></span>
<span class="line" id="L680">    <span class="tok-comment">// overwrite line 2</span>
</span>
<span class="line" id="L681">    <span class="tok-kw">const</span> file = <span class="tok-kw">try</span> std.fs.cwd().openFile(file_path, .{ .mode = .read_write });</span>
<span class="line" id="L682">    {</span>
<span class="line" id="L683">        <span class="tok-kw">defer</span> file.close();</span>
<span class="line" id="L684">        <span class="tok-kw">const</span> write_contents = <span class="tok-str">&quot;lorem ipsum&quot;</span>;</span>
<span class="line" id="L685">        <span class="tok-kw">var</span> iovec = [_]os.iovec_const{.{</span>
<span class="line" id="L686">            .iov_base = write_contents,</span>
<span class="line" id="L687">            .iov_len = write_contents.len,</span>
<span class="line" id="L688">        }};</span>
<span class="line" id="L689">        _ = <span class="tok-kw">try</span> file.pwritevAll(&amp;iovec, line2_offset);</span>
<span class="line" id="L690">    }</span>
<span class="line" id="L691"></span>
<span class="line" id="L692">    <span class="tok-kw">switch</span> ((<span class="tok-kw">try</span> <span class="tok-kw">await</span> ev).id) {</span>
<span class="line" id="L693">        .CloseWrite =&gt; {</span>
<span class="line" id="L694">            ev_consumed = <span class="tok-null">true</span>;</span>
<span class="line" id="L695">        },</span>
<span class="line" id="L696">        .Delete =&gt; <span class="tok-builtin">@panic</span>(<span class="tok-str">&quot;wrong event&quot;</span>),</span>
<span class="line" id="L697">    }</span>
<span class="line" id="L698"></span>
<span class="line" id="L699">    <span class="tok-kw">const</span> contents_updated = <span class="tok-kw">try</span> std.fs.cwd().readFileAlloc(allocator, file_path, <span class="tok-number">1024</span> * <span class="tok-number">1024</span>);</span>
<span class="line" id="L700">    <span class="tok-kw">defer</span> allocator.free(contents_updated);</span>
<span class="line" id="L701"></span>
<span class="line" id="L702">    <span class="tok-kw">try</span> testing.expectEqualSlices(<span class="tok-type">u8</span>,</span>
<span class="line" id="L703">        <span class="tok-str">\\line 1</span></span>

<span class="line" id="L704">        <span class="tok-str">\\lorem ipsum</span></span>

<span class="line" id="L705">    , contents_updated);</span>
<span class="line" id="L706"></span>
<span class="line" id="L707">    ev = <span class="tok-kw">async</span> watch.channel.get();</span>
<span class="line" id="L708">    ev_consumed = <span class="tok-null">false</span>;</span>
<span class="line" id="L709"></span>
<span class="line" id="L710">    <span class="tok-kw">try</span> std.fs.cwd().deleteFile(file_path);</span>
<span class="line" id="L711">    <span class="tok-kw">switch</span> ((<span class="tok-kw">try</span> <span class="tok-kw">await</span> ev).id) {</span>
<span class="line" id="L712">        .Delete =&gt; {</span>
<span class="line" id="L713">            ev_consumed = <span class="tok-null">true</span>;</span>
<span class="line" id="L714">        },</span>
<span class="line" id="L715">        .CloseWrite =&gt; <span class="tok-builtin">@panic</span>(<span class="tok-str">&quot;wrong event&quot;</span>),</span>
<span class="line" id="L716">    }</span>
<span class="line" id="L717">}</span>
<span class="line" id="L718"></span>
<span class="line" id="L719"><span class="tok-comment">// TODO Test: Add another file watch, remove the old file watch, get an event in the new</span>
</span>
<span class="line" id="L720"></span>
</code></pre></body>
</html>