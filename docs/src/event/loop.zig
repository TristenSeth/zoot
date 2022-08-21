<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">    <title>event/loop.zig - source view</title>
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
<span class="line" id="L3"><span class="tok-kw">const</span> root = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;root&quot;</span>);</span>
<span class="line" id="L4"><span class="tok-kw">const</span> assert = std.debug.assert;</span>
<span class="line" id="L5"><span class="tok-kw">const</span> testing = std.testing;</span>
<span class="line" id="L6"><span class="tok-kw">const</span> mem = std.mem;</span>
<span class="line" id="L7"><span class="tok-kw">const</span> os = std.os;</span>
<span class="line" id="L8"><span class="tok-kw">const</span> windows = os.windows;</span>
<span class="line" id="L9"><span class="tok-kw">const</span> maxInt = std.math.maxInt;</span>
<span class="line" id="L10"><span class="tok-kw">const</span> Thread = std.Thread;</span>
<span class="line" id="L11"><span class="tok-kw">const</span> Atomic = std.atomic.Atomic;</span>
<span class="line" id="L12"></span>
<span class="line" id="L13"><span class="tok-kw">const</span> is_windows = builtin.os.tag == .windows;</span>
<span class="line" id="L14"></span>
<span class="line" id="L15"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> Loop = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L16">    next_tick_queue: std.atomic.Queue(<span class="tok-kw">anyframe</span>),</span>
<span class="line" id="L17">    os_data: OsData,</span>
<span class="line" id="L18">    final_resume_node: ResumeNode,</span>
<span class="line" id="L19">    pending_event_count: <span class="tok-type">usize</span>,</span>
<span class="line" id="L20">    extra_threads: []Thread,</span>
<span class="line" id="L21">    <span class="tok-comment">/// TODO change this to a pool of configurable number of threads</span></span>
<span class="line" id="L22">    <span class="tok-comment">/// and rename it to be not file-system-specific. it will become</span></span>
<span class="line" id="L23">    <span class="tok-comment">/// a thread pool for turning non-CPU-bound blocking things into</span></span>
<span class="line" id="L24">    <span class="tok-comment">/// async things. A fallback for any missing OS-specific API.</span></span>
<span class="line" id="L25">    fs_thread: Thread,</span>
<span class="line" id="L26">    fs_queue: std.atomic.Queue(Request),</span>
<span class="line" id="L27">    fs_end_request: Request.Node,</span>
<span class="line" id="L28">    fs_thread_wakeup: std.Thread.ResetEvent,</span>
<span class="line" id="L29"></span>
<span class="line" id="L30">    <span class="tok-comment">/// For resources that have the same lifetime as the `Loop`.</span></span>
<span class="line" id="L31">    <span class="tok-comment">/// This is only used by `Loop` for the thread pool and associated resources.</span></span>
<span class="line" id="L32">    arena: std.heap.ArenaAllocator,</span>
<span class="line" id="L33"></span>
<span class="line" id="L34">    <span class="tok-comment">/// State which manages frames that are sleeping on timers</span></span>
<span class="line" id="L35">    delay_queue: DelayQueue,</span>
<span class="line" id="L36"></span>
<span class="line" id="L37">    <span class="tok-comment">/// Pre-allocated eventfds. All permanently active.</span></span>
<span class="line" id="L38">    <span class="tok-comment">/// This is how `Loop` sends promises to be resumed on other threads.</span></span>
<span class="line" id="L39">    available_eventfd_resume_nodes: std.atomic.Stack(ResumeNode.EventFd),</span>
<span class="line" id="L40">    eventfd_resume_nodes: []std.atomic.Stack(ResumeNode.EventFd).Node,</span>
<span class="line" id="L41"></span>
<span class="line" id="L42">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> NextTickNode = std.atomic.Queue(<span class="tok-kw">anyframe</span>).Node;</span>
<span class="line" id="L43"></span>
<span class="line" id="L44">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> ResumeNode = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L45">        id: Id,</span>
<span class="line" id="L46">        handle: <span class="tok-kw">anyframe</span>,</span>
<span class="line" id="L47">        overlapped: Overlapped,</span>
<span class="line" id="L48"></span>
<span class="line" id="L49">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> overlapped_init = <span class="tok-kw">switch</span> (builtin.os.tag) {</span>
<span class="line" id="L50">            .windows =&gt; windows.OVERLAPPED{</span>
<span class="line" id="L51">                .Internal = <span class="tok-number">0</span>,</span>
<span class="line" id="L52">                .InternalHigh = <span class="tok-number">0</span>,</span>
<span class="line" id="L53">                .DUMMYUNIONNAME = .{</span>
<span class="line" id="L54">                    .DUMMYSTRUCTNAME = .{</span>
<span class="line" id="L55">                        .Offset = <span class="tok-number">0</span>,</span>
<span class="line" id="L56">                        .OffsetHigh = <span class="tok-number">0</span>,</span>
<span class="line" id="L57">                    },</span>
<span class="line" id="L58">                },</span>
<span class="line" id="L59">                .hEvent = <span class="tok-null">null</span>,</span>
<span class="line" id="L60">            },</span>
<span class="line" id="L61">            <span class="tok-kw">else</span> =&gt; {},</span>
<span class="line" id="L62">        };</span>
<span class="line" id="L63">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> Overlapped = <span class="tok-builtin">@TypeOf</span>(overlapped_init);</span>
<span class="line" id="L64"></span>
<span class="line" id="L65">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> Id = <span class="tok-kw">enum</span> {</span>
<span class="line" id="L66">            Basic,</span>
<span class="line" id="L67">            Stop,</span>
<span class="line" id="L68">            EventFd,</span>
<span class="line" id="L69">        };</span>
<span class="line" id="L70"></span>
<span class="line" id="L71">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> EventFd = <span class="tok-kw">switch</span> (builtin.os.tag) {</span>
<span class="line" id="L72">            .macos, .freebsd, .netbsd, .dragonfly, .openbsd =&gt; KEventFd,</span>
<span class="line" id="L73">            .linux =&gt; <span class="tok-kw">struct</span> {</span>
<span class="line" id="L74">                base: ResumeNode,</span>
<span class="line" id="L75">                epoll_op: <span class="tok-type">u32</span>,</span>
<span class="line" id="L76">                eventfd: <span class="tok-type">i32</span>,</span>
<span class="line" id="L77">            },</span>
<span class="line" id="L78">            .windows =&gt; <span class="tok-kw">struct</span> {</span>
<span class="line" id="L79">                base: ResumeNode,</span>
<span class="line" id="L80">                completion_key: <span class="tok-type">usize</span>,</span>
<span class="line" id="L81">            },</span>
<span class="line" id="L82">            <span class="tok-kw">else</span> =&gt; <span class="tok-kw">struct</span> {},</span>
<span class="line" id="L83">        };</span>
<span class="line" id="L84"></span>
<span class="line" id="L85">        <span class="tok-kw">const</span> KEventFd = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L86">            base: ResumeNode,</span>
<span class="line" id="L87">            kevent: os.Kevent,</span>
<span class="line" id="L88">        };</span>
<span class="line" id="L89"></span>
<span class="line" id="L90">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> Basic = <span class="tok-kw">switch</span> (builtin.os.tag) {</span>
<span class="line" id="L91">            .macos, .freebsd, .netbsd, .dragonfly, .openbsd =&gt; KEventBasic,</span>
<span class="line" id="L92">            .linux =&gt; <span class="tok-kw">struct</span> {</span>
<span class="line" id="L93">                base: ResumeNode,</span>
<span class="line" id="L94">            },</span>
<span class="line" id="L95">            .windows =&gt; <span class="tok-kw">struct</span> {</span>
<span class="line" id="L96">                base: ResumeNode,</span>
<span class="line" id="L97">            },</span>
<span class="line" id="L98">            <span class="tok-kw">else</span> =&gt; <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;unsupported OS&quot;</span>),</span>
<span class="line" id="L99">        };</span>
<span class="line" id="L100"></span>
<span class="line" id="L101">        <span class="tok-kw">const</span> KEventBasic = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L102">            base: ResumeNode,</span>
<span class="line" id="L103">            kev: os.Kevent,</span>
<span class="line" id="L104">        };</span>
<span class="line" id="L105">    };</span>
<span class="line" id="L106"></span>
<span class="line" id="L107">    <span class="tok-kw">const</span> LoopOrVoid = <span class="tok-kw">switch</span> (std.io.mode) {</span>
<span class="line" id="L108">        .blocking =&gt; <span class="tok-type">void</span>,</span>
<span class="line" id="L109">        .evented =&gt; Loop,</span>
<span class="line" id="L110">    };</span>
<span class="line" id="L111"></span>
<span class="line" id="L112">    <span class="tok-kw">var</span> global_instance_state: LoopOrVoid = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L113">    <span class="tok-kw">const</span> default_instance: ?*LoopOrVoid = <span class="tok-kw">switch</span> (std.io.mode) {</span>
<span class="line" id="L114">        .blocking =&gt; <span class="tok-null">null</span>,</span>
<span class="line" id="L115">        .evented =&gt; &amp;global_instance_state,</span>
<span class="line" id="L116">    };</span>
<span class="line" id="L117">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> instance: ?*LoopOrVoid = <span class="tok-kw">if</span> (<span class="tok-builtin">@hasDecl</span>(root, <span class="tok-str">&quot;event_loop&quot;</span>)) root.event_loop <span class="tok-kw">else</span> default_instance;</span>
<span class="line" id="L118"></span>
<span class="line" id="L119">    <span class="tok-comment">/// TODO copy elision / named return values so that the threads referencing *Loop</span></span>
<span class="line" id="L120">    <span class="tok-comment">/// have the correct pointer value.</span></span>
<span class="line" id="L121">    <span class="tok-comment">/// https://github.com/ziglang/zig/issues/2761 and https://github.com/ziglang/zig/issues/2765</span></span>
<span class="line" id="L122">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">init</span>(self: *Loop) !<span class="tok-type">void</span> {</span>
<span class="line" id="L123">        <span class="tok-kw">if</span> (builtin.single_threaded <span class="tok-kw">or</span></span>
<span class="line" id="L124">            (<span class="tok-builtin">@hasDecl</span>(root, <span class="tok-str">&quot;event_loop_mode&quot;</span>) <span class="tok-kw">and</span> root.event_loop_mode == .single_threaded))</span>
<span class="line" id="L125">        {</span>
<span class="line" id="L126">            <span class="tok-kw">return</span> self.initSingleThreaded();</span>
<span class="line" id="L127">        } <span class="tok-kw">else</span> {</span>
<span class="line" id="L128">            <span class="tok-kw">return</span> self.initMultiThreaded();</span>
<span class="line" id="L129">        }</span>
<span class="line" id="L130">    }</span>
<span class="line" id="L131"></span>
<span class="line" id="L132">    <span class="tok-comment">/// After initialization, call run().</span></span>
<span class="line" id="L133">    <span class="tok-comment">/// TODO copy elision / named return values so that the threads referencing *Loop</span></span>
<span class="line" id="L134">    <span class="tok-comment">/// have the correct pointer value.</span></span>
<span class="line" id="L135">    <span class="tok-comment">/// https://github.com/ziglang/zig/issues/2761 and https://github.com/ziglang/zig/issues/2765</span></span>
<span class="line" id="L136">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">initSingleThreaded</span>(self: *Loop) !<span class="tok-type">void</span> {</span>
<span class="line" id="L137">        <span class="tok-kw">return</span> self.initThreadPool(<span class="tok-number">1</span>);</span>
<span class="line" id="L138">    }</span>
<span class="line" id="L139"></span>
<span class="line" id="L140">    <span class="tok-comment">/// After initialization, call run().</span></span>
<span class="line" id="L141">    <span class="tok-comment">/// This is the same as `initThreadPool` using `Thread.getCpuCount` to determine the thread</span></span>
<span class="line" id="L142">    <span class="tok-comment">/// pool size.</span></span>
<span class="line" id="L143">    <span class="tok-comment">/// TODO copy elision / named return values so that the threads referencing *Loop</span></span>
<span class="line" id="L144">    <span class="tok-comment">/// have the correct pointer value.</span></span>
<span class="line" id="L145">    <span class="tok-comment">/// https://github.com/ziglang/zig/issues/2761 and https://github.com/ziglang/zig/issues/2765</span></span>
<span class="line" id="L146">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">initMultiThreaded</span>(self: *Loop) !<span class="tok-type">void</span> {</span>
<span class="line" id="L147">        <span class="tok-kw">if</span> (builtin.single_threaded)</span>
<span class="line" id="L148">            <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;initMultiThreaded unavailable when building in single-threaded mode&quot;</span>);</span>
<span class="line" id="L149">        <span class="tok-kw">const</span> core_count = <span class="tok-kw">try</span> Thread.getCpuCount();</span>
<span class="line" id="L150">        <span class="tok-kw">return</span> self.initThreadPool(core_count);</span>
<span class="line" id="L151">    }</span>
<span class="line" id="L152"></span>
<span class="line" id="L153">    <span class="tok-comment">/// Thread count is the total thread count. The thread pool size will be</span></span>
<span class="line" id="L154">    <span class="tok-comment">/// max(thread_count - 1, 0)</span></span>
<span class="line" id="L155">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">initThreadPool</span>(self: *Loop, thread_count: <span class="tok-type">usize</span>) !<span class="tok-type">void</span> {</span>
<span class="line" id="L156">        self.* = Loop{</span>
<span class="line" id="L157">            .arena = std.heap.ArenaAllocator.init(std.heap.page_allocator),</span>
<span class="line" id="L158">            .pending_event_count = <span class="tok-number">1</span>,</span>
<span class="line" id="L159">            .os_data = <span class="tok-null">undefined</span>,</span>
<span class="line" id="L160">            .next_tick_queue = std.atomic.Queue(<span class="tok-kw">anyframe</span>).init(),</span>
<span class="line" id="L161">            .extra_threads = <span class="tok-null">undefined</span>,</span>
<span class="line" id="L162">            .available_eventfd_resume_nodes = std.atomic.Stack(ResumeNode.EventFd).init(),</span>
<span class="line" id="L163">            .eventfd_resume_nodes = <span class="tok-null">undefined</span>,</span>
<span class="line" id="L164">            .final_resume_node = ResumeNode{</span>
<span class="line" id="L165">                .id = ResumeNode.Id.Stop,</span>
<span class="line" id="L166">                .handle = <span class="tok-null">undefined</span>,</span>
<span class="line" id="L167">                .overlapped = ResumeNode.overlapped_init,</span>
<span class="line" id="L168">            },</span>
<span class="line" id="L169">            .fs_end_request = .{ .data = .{ .msg = .end, .finish = .NoAction } },</span>
<span class="line" id="L170">            .fs_queue = std.atomic.Queue(Request).init(),</span>
<span class="line" id="L171">            .fs_thread = <span class="tok-null">undefined</span>,</span>
<span class="line" id="L172">            .fs_thread_wakeup = .{},</span>
<span class="line" id="L173">            .delay_queue = <span class="tok-null">undefined</span>,</span>
<span class="line" id="L174">        };</span>
<span class="line" id="L175">        <span class="tok-kw">errdefer</span> self.arena.deinit();</span>
<span class="line" id="L176"></span>
<span class="line" id="L177">        <span class="tok-comment">// We need at least one of these in case the fs thread wants to use onNextTick</span>
</span>
<span class="line" id="L178">        <span class="tok-kw">const</span> extra_thread_count = thread_count - <span class="tok-number">1</span>;</span>
<span class="line" id="L179">        <span class="tok-kw">const</span> resume_node_count = std.math.max(extra_thread_count, <span class="tok-number">1</span>);</span>
<span class="line" id="L180">        self.eventfd_resume_nodes = <span class="tok-kw">try</span> self.arena.allocator().alloc(</span>
<span class="line" id="L181">            std.atomic.Stack(ResumeNode.EventFd).Node,</span>
<span class="line" id="L182">            resume_node_count,</span>
<span class="line" id="L183">        );</span>
<span class="line" id="L184"></span>
<span class="line" id="L185">        self.extra_threads = <span class="tok-kw">try</span> self.arena.allocator().alloc(Thread, extra_thread_count);</span>
<span class="line" id="L186"></span>
<span class="line" id="L187">        <span class="tok-kw">try</span> self.initOsData(extra_thread_count);</span>
<span class="line" id="L188">        <span class="tok-kw">errdefer</span> self.deinitOsData();</span>
<span class="line" id="L189"></span>
<span class="line" id="L190">        <span class="tok-kw">if</span> (!builtin.single_threaded) {</span>
<span class="line" id="L191">            self.fs_thread = <span class="tok-kw">try</span> Thread.spawn(.{}, posixFsRun, .{self});</span>
<span class="line" id="L192">        }</span>
<span class="line" id="L193">        <span class="tok-kw">errdefer</span> <span class="tok-kw">if</span> (!builtin.single_threaded) {</span>
<span class="line" id="L194">            self.posixFsRequest(&amp;self.fs_end_request);</span>
<span class="line" id="L195">            self.fs_thread.join();</span>
<span class="line" id="L196">        };</span>
<span class="line" id="L197"></span>
<span class="line" id="L198">        <span class="tok-kw">if</span> (!builtin.single_threaded)</span>
<span class="line" id="L199">            <span class="tok-kw">try</span> self.delay_queue.init();</span>
<span class="line" id="L200">    }</span>
<span class="line" id="L201"></span>
<span class="line" id="L202">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">deinit</span>(self: *Loop) <span class="tok-type">void</span> {</span>
<span class="line" id="L203">        self.deinitOsData();</span>
<span class="line" id="L204">        self.arena.deinit();</span>
<span class="line" id="L205">        self.* = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L206">    }</span>
<span class="line" id="L207"></span>
<span class="line" id="L208">    <span class="tok-kw">const</span> InitOsDataError = os.EpollCreateError || mem.Allocator.Error || os.EventFdError ||</span>
<span class="line" id="L209">        Thread.SpawnError || os.EpollCtlError || os.KEventError ||</span>
<span class="line" id="L210">        windows.CreateIoCompletionPortError;</span>
<span class="line" id="L211"></span>
<span class="line" id="L212">    <span class="tok-kw">const</span> wakeup_bytes = [_]<span class="tok-type">u8</span>{<span class="tok-number">0x1</span>} ** <span class="tok-number">8</span>;</span>
<span class="line" id="L213"></span>
<span class="line" id="L214">    <span class="tok-kw">fn</span> <span class="tok-fn">initOsData</span>(self: *Loop, extra_thread_count: <span class="tok-type">usize</span>) InitOsDataError!<span class="tok-type">void</span> {</span>
<span class="line" id="L215">        <span class="tok-kw">nosuspend</span> <span class="tok-kw">switch</span> (builtin.os.tag) {</span>
<span class="line" id="L216">            .linux =&gt; {</span>
<span class="line" id="L217">                <span class="tok-kw">errdefer</span> {</span>
<span class="line" id="L218">                    <span class="tok-kw">while</span> (self.available_eventfd_resume_nodes.pop()) |node| os.close(node.data.eventfd);</span>
<span class="line" id="L219">                }</span>
<span class="line" id="L220">                <span class="tok-kw">for</span> (self.eventfd_resume_nodes) |*eventfd_node| {</span>
<span class="line" id="L221">                    eventfd_node.* = std.atomic.Stack(ResumeNode.EventFd).Node{</span>
<span class="line" id="L222">                        .data = ResumeNode.EventFd{</span>
<span class="line" id="L223">                            .base = ResumeNode{</span>
<span class="line" id="L224">                                .id = .EventFd,</span>
<span class="line" id="L225">                                .handle = <span class="tok-null">undefined</span>,</span>
<span class="line" id="L226">                                .overlapped = ResumeNode.overlapped_init,</span>
<span class="line" id="L227">                            },</span>
<span class="line" id="L228">                            .eventfd = <span class="tok-kw">try</span> os.eventfd(<span class="tok-number">1</span>, os.linux.EFD.CLOEXEC | os.linux.EFD.NONBLOCK),</span>
<span class="line" id="L229">                            .epoll_op = os.linux.EPOLL.CTL_ADD,</span>
<span class="line" id="L230">                        },</span>
<span class="line" id="L231">                        .next = <span class="tok-null">undefined</span>,</span>
<span class="line" id="L232">                    };</span>
<span class="line" id="L233">                    self.available_eventfd_resume_nodes.push(eventfd_node);</span>
<span class="line" id="L234">                }</span>
<span class="line" id="L235"></span>
<span class="line" id="L236">                self.os_data.epollfd = <span class="tok-kw">try</span> os.epoll_create1(os.linux.EPOLL.CLOEXEC);</span>
<span class="line" id="L237">                <span class="tok-kw">errdefer</span> os.close(self.os_data.epollfd);</span>
<span class="line" id="L238"></span>
<span class="line" id="L239">                self.os_data.final_eventfd = <span class="tok-kw">try</span> os.eventfd(<span class="tok-number">0</span>, os.linux.EFD.CLOEXEC | os.linux.EFD.NONBLOCK);</span>
<span class="line" id="L240">                <span class="tok-kw">errdefer</span> os.close(self.os_data.final_eventfd);</span>
<span class="line" id="L241"></span>
<span class="line" id="L242">                self.os_data.final_eventfd_event = os.linux.epoll_event{</span>
<span class="line" id="L243">                    .events = os.linux.EPOLL.IN,</span>
<span class="line" id="L244">                    .data = os.linux.epoll_data{ .ptr = <span class="tok-builtin">@ptrToInt</span>(&amp;self.final_resume_node) },</span>
<span class="line" id="L245">                };</span>
<span class="line" id="L246">                <span class="tok-kw">try</span> os.epoll_ctl(</span>
<span class="line" id="L247">                    self.os_data.epollfd,</span>
<span class="line" id="L248">                    os.linux.EPOLL.CTL_ADD,</span>
<span class="line" id="L249">                    self.os_data.final_eventfd,</span>
<span class="line" id="L250">                    &amp;self.os_data.final_eventfd_event,</span>
<span class="line" id="L251">                );</span>
<span class="line" id="L252"></span>
<span class="line" id="L253">                <span class="tok-kw">if</span> (builtin.single_threaded) {</span>
<span class="line" id="L254">                    assert(extra_thread_count == <span class="tok-number">0</span>);</span>
<span class="line" id="L255">                    <span class="tok-kw">return</span>;</span>
<span class="line" id="L256">                }</span>
<span class="line" id="L257"></span>
<span class="line" id="L258">                <span class="tok-kw">var</span> extra_thread_index: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L259">                <span class="tok-kw">errdefer</span> {</span>
<span class="line" id="L260">                    <span class="tok-comment">// writing 8 bytes to an eventfd cannot fail</span>
</span>
<span class="line" id="L261">                    <span class="tok-kw">const</span> amt = os.write(self.os_data.final_eventfd, &amp;wakeup_bytes) <span class="tok-kw">catch</span> <span class="tok-kw">unreachable</span>;</span>
<span class="line" id="L262">                    assert(amt == wakeup_bytes.len);</span>
<span class="line" id="L263">                    <span class="tok-kw">while</span> (extra_thread_index != <span class="tok-number">0</span>) {</span>
<span class="line" id="L264">                        extra_thread_index -= <span class="tok-number">1</span>;</span>
<span class="line" id="L265">                        self.extra_threads[extra_thread_index].join();</span>
<span class="line" id="L266">                    }</span>
<span class="line" id="L267">                }</span>
<span class="line" id="L268">                <span class="tok-kw">while</span> (extra_thread_index &lt; extra_thread_count) : (extra_thread_index += <span class="tok-number">1</span>) {</span>
<span class="line" id="L269">                    self.extra_threads[extra_thread_index] = <span class="tok-kw">try</span> Thread.spawn(.{}, workerRun, .{self});</span>
<span class="line" id="L270">                }</span>
<span class="line" id="L271">            },</span>
<span class="line" id="L272">            .macos, .freebsd, .netbsd, .dragonfly =&gt; {</span>
<span class="line" id="L273">                self.os_data.kqfd = <span class="tok-kw">try</span> os.kqueue();</span>
<span class="line" id="L274">                <span class="tok-kw">errdefer</span> os.close(self.os_data.kqfd);</span>
<span class="line" id="L275"></span>
<span class="line" id="L276">                <span class="tok-kw">const</span> empty_kevs = &amp;[<span class="tok-number">0</span>]os.Kevent{};</span>
<span class="line" id="L277"></span>
<span class="line" id="L278">                <span class="tok-kw">for</span> (self.eventfd_resume_nodes) |*eventfd_node, i| {</span>
<span class="line" id="L279">                    eventfd_node.* = std.atomic.Stack(ResumeNode.EventFd).Node{</span>
<span class="line" id="L280">                        .data = ResumeNode.EventFd{</span>
<span class="line" id="L281">                            .base = ResumeNode{</span>
<span class="line" id="L282">                                .id = ResumeNode.Id.EventFd,</span>
<span class="line" id="L283">                                .handle = <span class="tok-null">undefined</span>,</span>
<span class="line" id="L284">                                .overlapped = ResumeNode.overlapped_init,</span>
<span class="line" id="L285">                            },</span>
<span class="line" id="L286">                            <span class="tok-comment">// this one is for sending events</span>
</span>
<span class="line" id="L287">                            .kevent = os.Kevent{</span>
<span class="line" id="L288">                                .ident = i,</span>
<span class="line" id="L289">                                .filter = os.system.EVFILT_USER,</span>
<span class="line" id="L290">                                .flags = os.system.EV_CLEAR | os.system.EV_ADD | os.system.EV_DISABLE,</span>
<span class="line" id="L291">                                .fflags = <span class="tok-number">0</span>,</span>
<span class="line" id="L292">                                .data = <span class="tok-number">0</span>,</span>
<span class="line" id="L293">                                .udata = <span class="tok-builtin">@ptrToInt</span>(&amp;eventfd_node.data.base),</span>
<span class="line" id="L294">                            },</span>
<span class="line" id="L295">                        },</span>
<span class="line" id="L296">                        .next = <span class="tok-null">undefined</span>,</span>
<span class="line" id="L297">                    };</span>
<span class="line" id="L298">                    self.available_eventfd_resume_nodes.push(eventfd_node);</span>
<span class="line" id="L299">                    <span class="tok-kw">const</span> kevent_array = <span class="tok-builtin">@as</span>(*<span class="tok-kw">const</span> [<span class="tok-number">1</span>]os.Kevent, &amp;eventfd_node.data.kevent);</span>
<span class="line" id="L300">                    _ = <span class="tok-kw">try</span> os.kevent(self.os_data.kqfd, kevent_array, empty_kevs, <span class="tok-null">null</span>);</span>
<span class="line" id="L301">                    eventfd_node.data.kevent.flags = os.system.EV_CLEAR | os.system.EV_ENABLE;</span>
<span class="line" id="L302">                    eventfd_node.data.kevent.fflags = os.system.NOTE_TRIGGER;</span>
<span class="line" id="L303">                }</span>
<span class="line" id="L304"></span>
<span class="line" id="L305">                <span class="tok-comment">// Pre-add so that we cannot get error.SystemResources</span>
</span>
<span class="line" id="L306">                <span class="tok-comment">// later when we try to activate it.</span>
</span>
<span class="line" id="L307">                self.os_data.final_kevent = os.Kevent{</span>
<span class="line" id="L308">                    .ident = extra_thread_count,</span>
<span class="line" id="L309">                    .filter = os.system.EVFILT_USER,</span>
<span class="line" id="L310">                    .flags = os.system.EV_ADD | os.system.EV_DISABLE,</span>
<span class="line" id="L311">                    .fflags = <span class="tok-number">0</span>,</span>
<span class="line" id="L312">                    .data = <span class="tok-number">0</span>,</span>
<span class="line" id="L313">                    .udata = <span class="tok-builtin">@ptrToInt</span>(&amp;self.final_resume_node),</span>
<span class="line" id="L314">                };</span>
<span class="line" id="L315">                <span class="tok-kw">const</span> final_kev_arr = <span class="tok-builtin">@as</span>(*<span class="tok-kw">const</span> [<span class="tok-number">1</span>]os.Kevent, &amp;self.os_data.final_kevent);</span>
<span class="line" id="L316">                _ = <span class="tok-kw">try</span> os.kevent(self.os_data.kqfd, final_kev_arr, empty_kevs, <span class="tok-null">null</span>);</span>
<span class="line" id="L317">                self.os_data.final_kevent.flags = os.system.EV_ENABLE;</span>
<span class="line" id="L318">                self.os_data.final_kevent.fflags = os.system.NOTE_TRIGGER;</span>
<span class="line" id="L319"></span>
<span class="line" id="L320">                <span class="tok-kw">if</span> (builtin.single_threaded) {</span>
<span class="line" id="L321">                    assert(extra_thread_count == <span class="tok-number">0</span>);</span>
<span class="line" id="L322">                    <span class="tok-kw">return</span>;</span>
<span class="line" id="L323">                }</span>
<span class="line" id="L324"></span>
<span class="line" id="L325">                <span class="tok-kw">var</span> extra_thread_index: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L326">                <span class="tok-kw">errdefer</span> {</span>
<span class="line" id="L327">                    _ = os.kevent(self.os_data.kqfd, final_kev_arr, empty_kevs, <span class="tok-null">null</span>) <span class="tok-kw">catch</span> <span class="tok-kw">unreachable</span>;</span>
<span class="line" id="L328">                    <span class="tok-kw">while</span> (extra_thread_index != <span class="tok-number">0</span>) {</span>
<span class="line" id="L329">                        extra_thread_index -= <span class="tok-number">1</span>;</span>
<span class="line" id="L330">                        self.extra_threads[extra_thread_index].join();</span>
<span class="line" id="L331">                    }</span>
<span class="line" id="L332">                }</span>
<span class="line" id="L333">                <span class="tok-kw">while</span> (extra_thread_index &lt; extra_thread_count) : (extra_thread_index += <span class="tok-number">1</span>) {</span>
<span class="line" id="L334">                    self.extra_threads[extra_thread_index] = <span class="tok-kw">try</span> Thread.spawn(.{}, workerRun, .{self});</span>
<span class="line" id="L335">                }</span>
<span class="line" id="L336">            },</span>
<span class="line" id="L337">            .openbsd =&gt; {</span>
<span class="line" id="L338">                self.os_data.kqfd = <span class="tok-kw">try</span> os.kqueue();</span>
<span class="line" id="L339">                <span class="tok-kw">errdefer</span> os.close(self.os_data.kqfd);</span>
<span class="line" id="L340"></span>
<span class="line" id="L341">                <span class="tok-kw">const</span> empty_kevs = &amp;[<span class="tok-number">0</span>]os.Kevent{};</span>
<span class="line" id="L342"></span>
<span class="line" id="L343">                <span class="tok-kw">for</span> (self.eventfd_resume_nodes) |*eventfd_node, i| {</span>
<span class="line" id="L344">                    eventfd_node.* = std.atomic.Stack(ResumeNode.EventFd).Node{</span>
<span class="line" id="L345">                        .data = ResumeNode.EventFd{</span>
<span class="line" id="L346">                            .base = ResumeNode{</span>
<span class="line" id="L347">                                .id = ResumeNode.Id.EventFd,</span>
<span class="line" id="L348">                                .handle = <span class="tok-null">undefined</span>,</span>
<span class="line" id="L349">                                .overlapped = ResumeNode.overlapped_init,</span>
<span class="line" id="L350">                            },</span>
<span class="line" id="L351">                            <span class="tok-comment">// this one is for sending events</span>
</span>
<span class="line" id="L352">                            .kevent = os.Kevent{</span>
<span class="line" id="L353">                                .ident = i,</span>
<span class="line" id="L354">                                .filter = os.system.EVFILT_TIMER,</span>
<span class="line" id="L355">                                .flags = os.system.EV_CLEAR | os.system.EV_ADD | os.system.EV_DISABLE | os.system.EV_ONESHOT,</span>
<span class="line" id="L356">                                .fflags = <span class="tok-number">0</span>,</span>
<span class="line" id="L357">                                .data = <span class="tok-number">0</span>,</span>
<span class="line" id="L358">                                .udata = <span class="tok-builtin">@ptrToInt</span>(&amp;eventfd_node.data.base),</span>
<span class="line" id="L359">                            },</span>
<span class="line" id="L360">                        },</span>
<span class="line" id="L361">                        .next = <span class="tok-null">undefined</span>,</span>
<span class="line" id="L362">                    };</span>
<span class="line" id="L363">                    self.available_eventfd_resume_nodes.push(eventfd_node);</span>
<span class="line" id="L364">                    <span class="tok-kw">const</span> kevent_array = <span class="tok-builtin">@as</span>(*<span class="tok-kw">const</span> [<span class="tok-number">1</span>]os.Kevent, &amp;eventfd_node.data.kevent);</span>
<span class="line" id="L365">                    _ = <span class="tok-kw">try</span> os.kevent(self.os_data.kqfd, kevent_array, empty_kevs, <span class="tok-null">null</span>);</span>
<span class="line" id="L366">                    eventfd_node.data.kevent.flags = os.system.EV_CLEAR | os.system.EV_ENABLE;</span>
<span class="line" id="L367">                }</span>
<span class="line" id="L368"></span>
<span class="line" id="L369">                <span class="tok-comment">// Pre-add so that we cannot get error.SystemResources</span>
</span>
<span class="line" id="L370">                <span class="tok-comment">// later when we try to activate it.</span>
</span>
<span class="line" id="L371">                self.os_data.final_kevent = os.Kevent{</span>
<span class="line" id="L372">                    .ident = extra_thread_count,</span>
<span class="line" id="L373">                    .filter = os.system.EVFILT_TIMER,</span>
<span class="line" id="L374">                    .flags = os.system.EV_ADD | os.system.EV_ONESHOT | os.system.EV_DISABLE,</span>
<span class="line" id="L375">                    .fflags = <span class="tok-number">0</span>,</span>
<span class="line" id="L376">                    .data = <span class="tok-number">0</span>,</span>
<span class="line" id="L377">                    .udata = <span class="tok-builtin">@ptrToInt</span>(&amp;self.final_resume_node),</span>
<span class="line" id="L378">                };</span>
<span class="line" id="L379">                <span class="tok-kw">const</span> final_kev_arr = <span class="tok-builtin">@as</span>(*<span class="tok-kw">const</span> [<span class="tok-number">1</span>]os.Kevent, &amp;self.os_data.final_kevent);</span>
<span class="line" id="L380">                _ = <span class="tok-kw">try</span> os.kevent(self.os_data.kqfd, final_kev_arr, empty_kevs, <span class="tok-null">null</span>);</span>
<span class="line" id="L381">                self.os_data.final_kevent.flags = os.system.EV_ENABLE;</span>
<span class="line" id="L382"></span>
<span class="line" id="L383">                <span class="tok-kw">if</span> (builtin.single_threaded) {</span>
<span class="line" id="L384">                    assert(extra_thread_count == <span class="tok-number">0</span>);</span>
<span class="line" id="L385">                    <span class="tok-kw">return</span>;</span>
<span class="line" id="L386">                }</span>
<span class="line" id="L387"></span>
<span class="line" id="L388">                <span class="tok-kw">var</span> extra_thread_index: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L389">                <span class="tok-kw">errdefer</span> {</span>
<span class="line" id="L390">                    _ = os.kevent(self.os_data.kqfd, final_kev_arr, empty_kevs, <span class="tok-null">null</span>) <span class="tok-kw">catch</span> <span class="tok-kw">unreachable</span>;</span>
<span class="line" id="L391">                    <span class="tok-kw">while</span> (extra_thread_index != <span class="tok-number">0</span>) {</span>
<span class="line" id="L392">                        extra_thread_index -= <span class="tok-number">1</span>;</span>
<span class="line" id="L393">                        self.extra_threads[extra_thread_index].join();</span>
<span class="line" id="L394">                    }</span>
<span class="line" id="L395">                }</span>
<span class="line" id="L396">                <span class="tok-kw">while</span> (extra_thread_index &lt; extra_thread_count) : (extra_thread_index += <span class="tok-number">1</span>) {</span>
<span class="line" id="L397">                    self.extra_threads[extra_thread_index] = <span class="tok-kw">try</span> Thread.spawn(.{}, workerRun, .{self});</span>
<span class="line" id="L398">                }</span>
<span class="line" id="L399">            },</span>
<span class="line" id="L400">            .windows =&gt; {</span>
<span class="line" id="L401">                self.os_data.io_port = <span class="tok-kw">try</span> windows.CreateIoCompletionPort(</span>
<span class="line" id="L402">                    windows.INVALID_HANDLE_VALUE,</span>
<span class="line" id="L403">                    <span class="tok-null">null</span>,</span>
<span class="line" id="L404">                    <span class="tok-null">undefined</span>,</span>
<span class="line" id="L405">                    maxInt(windows.DWORD),</span>
<span class="line" id="L406">                );</span>
<span class="line" id="L407">                <span class="tok-kw">errdefer</span> windows.CloseHandle(self.os_data.io_port);</span>
<span class="line" id="L408"></span>
<span class="line" id="L409">                <span class="tok-kw">for</span> (self.eventfd_resume_nodes) |*eventfd_node| {</span>
<span class="line" id="L410">                    eventfd_node.* = std.atomic.Stack(ResumeNode.EventFd).Node{</span>
<span class="line" id="L411">                        .data = ResumeNode.EventFd{</span>
<span class="line" id="L412">                            .base = ResumeNode{</span>
<span class="line" id="L413">                                .id = ResumeNode.Id.EventFd,</span>
<span class="line" id="L414">                                .handle = <span class="tok-null">undefined</span>,</span>
<span class="line" id="L415">                                .overlapped = ResumeNode.overlapped_init,</span>
<span class="line" id="L416">                            },</span>
<span class="line" id="L417">                            <span class="tok-comment">// this one is for sending events</span>
</span>
<span class="line" id="L418">                            .completion_key = <span class="tok-builtin">@ptrToInt</span>(&amp;eventfd_node.data.base),</span>
<span class="line" id="L419">                        },</span>
<span class="line" id="L420">                        .next = <span class="tok-null">undefined</span>,</span>
<span class="line" id="L421">                    };</span>
<span class="line" id="L422">                    self.available_eventfd_resume_nodes.push(eventfd_node);</span>
<span class="line" id="L423">                }</span>
<span class="line" id="L424"></span>
<span class="line" id="L425">                <span class="tok-kw">if</span> (builtin.single_threaded) {</span>
<span class="line" id="L426">                    assert(extra_thread_count == <span class="tok-number">0</span>);</span>
<span class="line" id="L427">                    <span class="tok-kw">return</span>;</span>
<span class="line" id="L428">                }</span>
<span class="line" id="L429"></span>
<span class="line" id="L430">                <span class="tok-kw">var</span> extra_thread_index: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L431">                <span class="tok-kw">errdefer</span> {</span>
<span class="line" id="L432">                    <span class="tok-kw">var</span> i: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L433">                    <span class="tok-kw">while</span> (i &lt; extra_thread_index) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L434">                        <span class="tok-kw">while</span> (<span class="tok-null">true</span>) {</span>
<span class="line" id="L435">                            <span class="tok-kw">const</span> overlapped = &amp;self.final_resume_node.overlapped;</span>
<span class="line" id="L436">                            windows.PostQueuedCompletionStatus(self.os_data.io_port, <span class="tok-null">undefined</span>, <span class="tok-null">undefined</span>, overlapped) <span class="tok-kw">catch</span> <span class="tok-kw">continue</span>;</span>
<span class="line" id="L437">                            <span class="tok-kw">break</span>;</span>
<span class="line" id="L438">                        }</span>
<span class="line" id="L439">                    }</span>
<span class="line" id="L440">                    <span class="tok-kw">while</span> (extra_thread_index != <span class="tok-number">0</span>) {</span>
<span class="line" id="L441">                        extra_thread_index -= <span class="tok-number">1</span>;</span>
<span class="line" id="L442">                        self.extra_threads[extra_thread_index].join();</span>
<span class="line" id="L443">                    }</span>
<span class="line" id="L444">                }</span>
<span class="line" id="L445">                <span class="tok-kw">while</span> (extra_thread_index &lt; extra_thread_count) : (extra_thread_index += <span class="tok-number">1</span>) {</span>
<span class="line" id="L446">                    self.extra_threads[extra_thread_index] = <span class="tok-kw">try</span> Thread.spawn(.{}, workerRun, .{self});</span>
<span class="line" id="L447">                }</span>
<span class="line" id="L448">            },</span>
<span class="line" id="L449">            <span class="tok-kw">else</span> =&gt; {},</span>
<span class="line" id="L450">        };</span>
<span class="line" id="L451">    }</span>
<span class="line" id="L452"></span>
<span class="line" id="L453">    <span class="tok-kw">fn</span> <span class="tok-fn">deinitOsData</span>(self: *Loop) <span class="tok-type">void</span> {</span>
<span class="line" id="L454">        <span class="tok-kw">nosuspend</span> <span class="tok-kw">switch</span> (builtin.os.tag) {</span>
<span class="line" id="L455">            .linux =&gt; {</span>
<span class="line" id="L456">                os.close(self.os_data.final_eventfd);</span>
<span class="line" id="L457">                <span class="tok-kw">while</span> (self.available_eventfd_resume_nodes.pop()) |node| os.close(node.data.eventfd);</span>
<span class="line" id="L458">                os.close(self.os_data.epollfd);</span>
<span class="line" id="L459">            },</span>
<span class="line" id="L460">            .macos, .freebsd, .netbsd, .dragonfly, .openbsd =&gt; {</span>
<span class="line" id="L461">                os.close(self.os_data.kqfd);</span>
<span class="line" id="L462">            },</span>
<span class="line" id="L463">            .windows =&gt; {</span>
<span class="line" id="L464">                windows.CloseHandle(self.os_data.io_port);</span>
<span class="line" id="L465">            },</span>
<span class="line" id="L466">            <span class="tok-kw">else</span> =&gt; {},</span>
<span class="line" id="L467">        };</span>
<span class="line" id="L468">    }</span>
<span class="line" id="L469"></span>
<span class="line" id="L470">    <span class="tok-comment">/// resume_node must live longer than the anyframe that it holds a reference to.</span></span>
<span class="line" id="L471">    <span class="tok-comment">/// flags must contain EPOLLET</span></span>
<span class="line" id="L472">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">linuxAddFd</span>(self: *Loop, fd: <span class="tok-type">i32</span>, resume_node: *ResumeNode, flags: <span class="tok-type">u32</span>) !<span class="tok-type">void</span> {</span>
<span class="line" id="L473">        assert(flags &amp; os.linux.EPOLL.ET == os.linux.EPOLL.ET);</span>
<span class="line" id="L474">        self.beginOneEvent();</span>
<span class="line" id="L475">        <span class="tok-kw">errdefer</span> self.finishOneEvent();</span>
<span class="line" id="L476">        <span class="tok-kw">try</span> self.linuxModFd(</span>
<span class="line" id="L477">            fd,</span>
<span class="line" id="L478">            os.linux.EPOLL.CTL_ADD,</span>
<span class="line" id="L479">            flags,</span>
<span class="line" id="L480">            resume_node,</span>
<span class="line" id="L481">        );</span>
<span class="line" id="L482">    }</span>
<span class="line" id="L483"></span>
<span class="line" id="L484">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">linuxModFd</span>(self: *Loop, fd: <span class="tok-type">i32</span>, op: <span class="tok-type">u32</span>, flags: <span class="tok-type">u32</span>, resume_node: *ResumeNode) !<span class="tok-type">void</span> {</span>
<span class="line" id="L485">        assert(flags &amp; os.linux.EPOLL.ET == os.linux.EPOLL.ET);</span>
<span class="line" id="L486">        <span class="tok-kw">var</span> ev = os.linux.epoll_event{</span>
<span class="line" id="L487">            .events = flags,</span>
<span class="line" id="L488">            .data = os.linux.epoll_data{ .ptr = <span class="tok-builtin">@ptrToInt</span>(resume_node) },</span>
<span class="line" id="L489">        };</span>
<span class="line" id="L490">        <span class="tok-kw">try</span> os.epoll_ctl(self.os_data.epollfd, op, fd, &amp;ev);</span>
<span class="line" id="L491">    }</span>
<span class="line" id="L492"></span>
<span class="line" id="L493">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">linuxRemoveFd</span>(self: *Loop, fd: <span class="tok-type">i32</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L494">        os.epoll_ctl(self.os_data.epollfd, os.linux.EPOLL.CTL_DEL, fd, <span class="tok-null">null</span>) <span class="tok-kw">catch</span> {};</span>
<span class="line" id="L495">        self.finishOneEvent();</span>
<span class="line" id="L496">    }</span>
<span class="line" id="L497"></span>
<span class="line" id="L498">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">linuxWaitFd</span>(self: *Loop, fd: <span class="tok-type">i32</span>, flags: <span class="tok-type">u32</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L499">        assert(flags &amp; os.linux.EPOLL.ET == os.linux.EPOLL.ET);</span>
<span class="line" id="L500">        assert(flags &amp; os.linux.EPOLL.ONESHOT == os.linux.EPOLL.ONESHOT);</span>
<span class="line" id="L501">        <span class="tok-kw">var</span> resume_node = ResumeNode.Basic{</span>
<span class="line" id="L502">            .base = ResumeNode{</span>
<span class="line" id="L503">                .id = .Basic,</span>
<span class="line" id="L504">                .handle = <span class="tok-builtin">@frame</span>(),</span>
<span class="line" id="L505">                .overlapped = ResumeNode.overlapped_init,</span>
<span class="line" id="L506">            },</span>
<span class="line" id="L507">        };</span>
<span class="line" id="L508">        <span class="tok-kw">var</span> need_to_delete = <span class="tok-null">true</span>;</span>
<span class="line" id="L509">        <span class="tok-kw">defer</span> <span class="tok-kw">if</span> (need_to_delete) self.linuxRemoveFd(fd);</span>
<span class="line" id="L510"></span>
<span class="line" id="L511">        <span class="tok-kw">suspend</span> {</span>
<span class="line" id="L512">            self.linuxAddFd(fd, &amp;resume_node.base, flags) <span class="tok-kw">catch</span> |err| <span class="tok-kw">switch</span> (err) {</span>
<span class="line" id="L513">                <span class="tok-kw">error</span>.FileDescriptorNotRegistered =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L514">                <span class="tok-kw">error</span>.OperationCausesCircularLoop =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L515">                <span class="tok-kw">error</span>.FileDescriptorIncompatibleWithEpoll =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L516">                <span class="tok-kw">error</span>.FileDescriptorAlreadyPresentInSet =&gt; <span class="tok-kw">unreachable</span>, <span class="tok-comment">// evented writes to the same fd is not thread-safe</span>
</span>
<span class="line" id="L517"></span>
<span class="line" id="L518">                <span class="tok-kw">error</span>.SystemResources,</span>
<span class="line" id="L519">                <span class="tok-kw">error</span>.UserResourceLimitReached,</span>
<span class="line" id="L520">                <span class="tok-kw">error</span>.Unexpected,</span>
<span class="line" id="L521">                =&gt; {</span>
<span class="line" id="L522">                    need_to_delete = <span class="tok-null">false</span>;</span>
<span class="line" id="L523">                    <span class="tok-comment">// Fall back to a blocking poll(). Ideally this codepath is never hit, since</span>
</span>
<span class="line" id="L524">                    <span class="tok-comment">// epoll should be just fine. But this is better than incorrect behavior.</span>
</span>
<span class="line" id="L525">                    <span class="tok-kw">var</span> poll_flags: <span class="tok-type">i16</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L526">                    <span class="tok-kw">if</span> ((flags &amp; os.linux.EPOLL.IN) != <span class="tok-number">0</span>) poll_flags |= os.POLL.IN;</span>
<span class="line" id="L527">                    <span class="tok-kw">if</span> ((flags &amp; os.linux.EPOLL.OUT) != <span class="tok-number">0</span>) poll_flags |= os.POLL.OUT;</span>
<span class="line" id="L528">                    <span class="tok-kw">var</span> pfd = [<span class="tok-number">1</span>]os.pollfd{os.pollfd{</span>
<span class="line" id="L529">                        .fd = fd,</span>
<span class="line" id="L530">                        .events = poll_flags,</span>
<span class="line" id="L531">                        .revents = <span class="tok-null">undefined</span>,</span>
<span class="line" id="L532">                    }};</span>
<span class="line" id="L533">                    _ = os.poll(&amp;pfd, -<span class="tok-number">1</span>) <span class="tok-kw">catch</span> |poll_err| <span class="tok-kw">switch</span> (poll_err) {</span>
<span class="line" id="L534">                        <span class="tok-kw">error</span>.NetworkSubsystemFailed =&gt; <span class="tok-kw">unreachable</span>, <span class="tok-comment">// only possible on windows</span>
</span>
<span class="line" id="L535"></span>
<span class="line" id="L536">                        <span class="tok-kw">error</span>.SystemResources,</span>
<span class="line" id="L537">                        <span class="tok-kw">error</span>.Unexpected,</span>
<span class="line" id="L538">                        =&gt; {</span>
<span class="line" id="L539">                            <span class="tok-comment">// Even poll() didn't work. The best we can do now is sleep for a</span>
</span>
<span class="line" id="L540">                            <span class="tok-comment">// small duration and then hope that something changed.</span>
</span>
<span class="line" id="L541">                            std.time.sleep(<span class="tok-number">1</span> * std.time.ns_per_ms);</span>
<span class="line" id="L542">                        },</span>
<span class="line" id="L543">                    };</span>
<span class="line" id="L544">                    <span class="tok-kw">resume</span> <span class="tok-builtin">@frame</span>();</span>
<span class="line" id="L545">                },</span>
<span class="line" id="L546">            };</span>
<span class="line" id="L547">        }</span>
<span class="line" id="L548">    }</span>
<span class="line" id="L549"></span>
<span class="line" id="L550">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">waitUntilFdReadable</span>(self: *Loop, fd: os.fd_t) <span class="tok-type">void</span> {</span>
<span class="line" id="L551">        <span class="tok-kw">switch</span> (builtin.os.tag) {</span>
<span class="line" id="L552">            .linux =&gt; {</span>
<span class="line" id="L553">                self.linuxWaitFd(fd, os.linux.EPOLL.ET | os.linux.EPOLL.ONESHOT | os.linux.EPOLL.IN);</span>
<span class="line" id="L554">            },</span>
<span class="line" id="L555">            .macos, .freebsd, .netbsd, .dragonfly, .openbsd =&gt; {</span>
<span class="line" id="L556">                self.bsdWaitKev(<span class="tok-builtin">@intCast</span>(<span class="tok-type">usize</span>, fd), os.system.EVFILT_READ, os.system.EV_ONESHOT);</span>
<span class="line" id="L557">            },</span>
<span class="line" id="L558">            <span class="tok-kw">else</span> =&gt; <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;Unsupported OS&quot;</span>),</span>
<span class="line" id="L559">        }</span>
<span class="line" id="L560">    }</span>
<span class="line" id="L561"></span>
<span class="line" id="L562">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">waitUntilFdWritable</span>(self: *Loop, fd: os.fd_t) <span class="tok-type">void</span> {</span>
<span class="line" id="L563">        <span class="tok-kw">switch</span> (builtin.os.tag) {</span>
<span class="line" id="L564">            .linux =&gt; {</span>
<span class="line" id="L565">                self.linuxWaitFd(fd, os.linux.EPOLL.ET | os.linux.EPOLL.ONESHOT | os.linux.EPOLL.OUT);</span>
<span class="line" id="L566">            },</span>
<span class="line" id="L567">            .macos, .freebsd, .netbsd, .dragonfly, .openbsd =&gt; {</span>
<span class="line" id="L568">                self.bsdWaitKev(<span class="tok-builtin">@intCast</span>(<span class="tok-type">usize</span>, fd), os.system.EVFILT_WRITE, os.system.EV_ONESHOT);</span>
<span class="line" id="L569">            },</span>
<span class="line" id="L570">            <span class="tok-kw">else</span> =&gt; <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;Unsupported OS&quot;</span>),</span>
<span class="line" id="L571">        }</span>
<span class="line" id="L572">    }</span>
<span class="line" id="L573"></span>
<span class="line" id="L574">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">waitUntilFdWritableOrReadable</span>(self: *Loop, fd: os.fd_t) <span class="tok-type">void</span> {</span>
<span class="line" id="L575">        <span class="tok-kw">switch</span> (builtin.os.tag) {</span>
<span class="line" id="L576">            .linux =&gt; {</span>
<span class="line" id="L577">                self.linuxWaitFd(fd, os.linux.EPOLL.ET | os.linux.EPOLL.ONESHOT | os.linux.EPOLL.OUT | os.linux.EPOLL.IN);</span>
<span class="line" id="L578">            },</span>
<span class="line" id="L579">            .macos, .freebsd, .netbsd, .dragonfly, .openbsd =&gt; {</span>
<span class="line" id="L580">                self.bsdWaitKev(<span class="tok-builtin">@intCast</span>(<span class="tok-type">usize</span>, fd), os.system.EVFILT_READ, os.system.EV_ONESHOT);</span>
<span class="line" id="L581">                self.bsdWaitKev(<span class="tok-builtin">@intCast</span>(<span class="tok-type">usize</span>, fd), os.system.EVFILT_WRITE, os.system.EV_ONESHOT);</span>
<span class="line" id="L582">            },</span>
<span class="line" id="L583">            <span class="tok-kw">else</span> =&gt; <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;Unsupported OS&quot;</span>),</span>
<span class="line" id="L584">        }</span>
<span class="line" id="L585">    }</span>
<span class="line" id="L586"></span>
<span class="line" id="L587">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">bsdWaitKev</span>(self: *Loop, ident: <span class="tok-type">usize</span>, filter: <span class="tok-type">i16</span>, flags: <span class="tok-type">u16</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L588">        <span class="tok-kw">var</span> resume_node = ResumeNode.Basic{</span>
<span class="line" id="L589">            .base = ResumeNode{</span>
<span class="line" id="L590">                .id = ResumeNode.Id.Basic,</span>
<span class="line" id="L591">                .handle = <span class="tok-builtin">@frame</span>(),</span>
<span class="line" id="L592">                .overlapped = ResumeNode.overlapped_init,</span>
<span class="line" id="L593">            },</span>
<span class="line" id="L594">            .kev = <span class="tok-null">undefined</span>,</span>
<span class="line" id="L595">        };</span>
<span class="line" id="L596"></span>
<span class="line" id="L597">        <span class="tok-kw">defer</span> {</span>
<span class="line" id="L598">            <span class="tok-comment">// If the kevent was set to be ONESHOT, it doesn't need to be deleted manually.</span>
</span>
<span class="line" id="L599">            <span class="tok-kw">if</span> (flags &amp; os.system.EV_ONESHOT != <span class="tok-number">0</span>) {</span>
<span class="line" id="L600">                self.bsdRemoveKev(ident, filter);</span>
<span class="line" id="L601">            }</span>
<span class="line" id="L602">        }</span>
<span class="line" id="L603"></span>
<span class="line" id="L604">        <span class="tok-kw">suspend</span> {</span>
<span class="line" id="L605">            self.bsdAddKev(&amp;resume_node, ident, filter, flags) <span class="tok-kw">catch</span> <span class="tok-kw">unreachable</span>;</span>
<span class="line" id="L606">        }</span>
<span class="line" id="L607">    }</span>
<span class="line" id="L608"></span>
<span class="line" id="L609">    <span class="tok-comment">/// resume_node must live longer than the anyframe that it holds a reference to.</span></span>
<span class="line" id="L610">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">bsdAddKev</span>(self: *Loop, resume_node: *ResumeNode.Basic, ident: <span class="tok-type">usize</span>, filter: <span class="tok-type">i16</span>, flags: <span class="tok-type">u16</span>) !<span class="tok-type">void</span> {</span>
<span class="line" id="L611">        self.beginOneEvent();</span>
<span class="line" id="L612">        <span class="tok-kw">errdefer</span> self.finishOneEvent();</span>
<span class="line" id="L613">        <span class="tok-kw">var</span> kev = [<span class="tok-number">1</span>]os.Kevent{os.Kevent{</span>
<span class="line" id="L614">            .ident = ident,</span>
<span class="line" id="L615">            .filter = filter,</span>
<span class="line" id="L616">            .flags = os.system.EV_ADD | os.system.EV_ENABLE | os.system.EV_CLEAR | flags,</span>
<span class="line" id="L617">            .fflags = <span class="tok-number">0</span>,</span>
<span class="line" id="L618">            .data = <span class="tok-number">0</span>,</span>
<span class="line" id="L619">            .udata = <span class="tok-builtin">@ptrToInt</span>(&amp;resume_node.base),</span>
<span class="line" id="L620">        }};</span>
<span class="line" id="L621">        <span class="tok-kw">const</span> empty_kevs = &amp;[<span class="tok-number">0</span>]os.Kevent{};</span>
<span class="line" id="L622">        _ = <span class="tok-kw">try</span> os.kevent(self.os_data.kqfd, &amp;kev, empty_kevs, <span class="tok-null">null</span>);</span>
<span class="line" id="L623">    }</span>
<span class="line" id="L624"></span>
<span class="line" id="L625">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">bsdRemoveKev</span>(self: *Loop, ident: <span class="tok-type">usize</span>, filter: <span class="tok-type">i16</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L626">        <span class="tok-kw">var</span> kev = [<span class="tok-number">1</span>]os.Kevent{os.Kevent{</span>
<span class="line" id="L627">            .ident = ident,</span>
<span class="line" id="L628">            .filter = filter,</span>
<span class="line" id="L629">            .flags = os.system.EV_DELETE,</span>
<span class="line" id="L630">            .fflags = <span class="tok-number">0</span>,</span>
<span class="line" id="L631">            .data = <span class="tok-number">0</span>,</span>
<span class="line" id="L632">            .udata = <span class="tok-number">0</span>,</span>
<span class="line" id="L633">        }};</span>
<span class="line" id="L634">        <span class="tok-kw">const</span> empty_kevs = &amp;[<span class="tok-number">0</span>]os.Kevent{};</span>
<span class="line" id="L635">        _ = os.kevent(self.os_data.kqfd, &amp;kev, empty_kevs, <span class="tok-null">null</span>) <span class="tok-kw">catch</span> <span class="tok-null">undefined</span>;</span>
<span class="line" id="L636">        self.finishOneEvent();</span>
<span class="line" id="L637">    }</span>
<span class="line" id="L638"></span>
<span class="line" id="L639">    <span class="tok-kw">fn</span> <span class="tok-fn">dispatch</span>(self: *Loop) <span class="tok-type">void</span> {</span>
<span class="line" id="L640">        <span class="tok-kw">while</span> (self.available_eventfd_resume_nodes.pop()) |resume_stack_node| {</span>
<span class="line" id="L641">            <span class="tok-kw">const</span> next_tick_node = self.next_tick_queue.get() <span class="tok-kw">orelse</span> {</span>
<span class="line" id="L642">                self.available_eventfd_resume_nodes.push(resume_stack_node);</span>
<span class="line" id="L643">                <span class="tok-kw">return</span>;</span>
<span class="line" id="L644">            };</span>
<span class="line" id="L645">            <span class="tok-kw">const</span> eventfd_node = &amp;resume_stack_node.data;</span>
<span class="line" id="L646">            eventfd_node.base.handle = next_tick_node.data;</span>
<span class="line" id="L647">            <span class="tok-kw">switch</span> (builtin.os.tag) {</span>
<span class="line" id="L648">                .macos, .freebsd, .netbsd, .dragonfly, .openbsd =&gt; {</span>
<span class="line" id="L649">                    <span class="tok-kw">const</span> kevent_array = <span class="tok-builtin">@as</span>(*<span class="tok-kw">const</span> [<span class="tok-number">1</span>]os.Kevent, &amp;eventfd_node.kevent);</span>
<span class="line" id="L650">                    <span class="tok-kw">const</span> empty_kevs = &amp;[<span class="tok-number">0</span>]os.Kevent{};</span>
<span class="line" id="L651">                    _ = os.kevent(self.os_data.kqfd, kevent_array, empty_kevs, <span class="tok-null">null</span>) <span class="tok-kw">catch</span> {</span>
<span class="line" id="L652">                        self.next_tick_queue.unget(next_tick_node);</span>
<span class="line" id="L653">                        self.available_eventfd_resume_nodes.push(resume_stack_node);</span>
<span class="line" id="L654">                        <span class="tok-kw">return</span>;</span>
<span class="line" id="L655">                    };</span>
<span class="line" id="L656">                },</span>
<span class="line" id="L657">                .linux =&gt; {</span>
<span class="line" id="L658">                    <span class="tok-comment">// the pending count is already accounted for</span>
</span>
<span class="line" id="L659">                    <span class="tok-kw">const</span> epoll_events = os.linux.EPOLL.ONESHOT | os.linux.EPOLL.IN | os.linux.EPOLL.OUT |</span>
<span class="line" id="L660">                        os.linux.EPOLL.ET;</span>
<span class="line" id="L661">                    self.linuxModFd(</span>
<span class="line" id="L662">                        eventfd_node.eventfd,</span>
<span class="line" id="L663">                        eventfd_node.epoll_op,</span>
<span class="line" id="L664">                        epoll_events,</span>
<span class="line" id="L665">                        &amp;eventfd_node.base,</span>
<span class="line" id="L666">                    ) <span class="tok-kw">catch</span> {</span>
<span class="line" id="L667">                        self.next_tick_queue.unget(next_tick_node);</span>
<span class="line" id="L668">                        self.available_eventfd_resume_nodes.push(resume_stack_node);</span>
<span class="line" id="L669">                        <span class="tok-kw">return</span>;</span>
<span class="line" id="L670">                    };</span>
<span class="line" id="L671">                },</span>
<span class="line" id="L672">                .windows =&gt; {</span>
<span class="line" id="L673">                    windows.PostQueuedCompletionStatus(</span>
<span class="line" id="L674">                        self.os_data.io_port,</span>
<span class="line" id="L675">                        <span class="tok-null">undefined</span>,</span>
<span class="line" id="L676">                        <span class="tok-null">undefined</span>,</span>
<span class="line" id="L677">                        &amp;eventfd_node.base.overlapped,</span>
<span class="line" id="L678">                    ) <span class="tok-kw">catch</span> {</span>
<span class="line" id="L679">                        self.next_tick_queue.unget(next_tick_node);</span>
<span class="line" id="L680">                        self.available_eventfd_resume_nodes.push(resume_stack_node);</span>
<span class="line" id="L681">                        <span class="tok-kw">return</span>;</span>
<span class="line" id="L682">                    };</span>
<span class="line" id="L683">                },</span>
<span class="line" id="L684">                <span class="tok-kw">else</span> =&gt; <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;unsupported OS&quot;</span>),</span>
<span class="line" id="L685">            }</span>
<span class="line" id="L686">        }</span>
<span class="line" id="L687">    }</span>
<span class="line" id="L688"></span>
<span class="line" id="L689">    <span class="tok-comment">/// Bring your own linked list node. This means it can't fail.</span></span>
<span class="line" id="L690">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">onNextTick</span>(self: *Loop, node: *NextTickNode) <span class="tok-type">void</span> {</span>
<span class="line" id="L691">        self.beginOneEvent(); <span class="tok-comment">// finished in dispatch()</span>
</span>
<span class="line" id="L692">        self.next_tick_queue.put(node);</span>
<span class="line" id="L693">        self.dispatch();</span>
<span class="line" id="L694">    }</span>
<span class="line" id="L695"></span>
<span class="line" id="L696">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">cancelOnNextTick</span>(self: *Loop, node: *NextTickNode) <span class="tok-type">void</span> {</span>
<span class="line" id="L697">        <span class="tok-kw">if</span> (self.next_tick_queue.remove(node)) {</span>
<span class="line" id="L698">            self.finishOneEvent();</span>
<span class="line" id="L699">        }</span>
<span class="line" id="L700">    }</span>
<span class="line" id="L701"></span>
<span class="line" id="L702">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">run</span>(self: *Loop) <span class="tok-type">void</span> {</span>
<span class="line" id="L703">        self.finishOneEvent(); <span class="tok-comment">// the reference we start with</span>
</span>
<span class="line" id="L704"></span>
<span class="line" id="L705">        self.workerRun();</span>
<span class="line" id="L706"></span>
<span class="line" id="L707">        <span class="tok-kw">if</span> (!builtin.single_threaded) {</span>
<span class="line" id="L708">            <span class="tok-kw">switch</span> (builtin.os.tag) {</span>
<span class="line" id="L709">                .linux,</span>
<span class="line" id="L710">                .macos,</span>
<span class="line" id="L711">                .freebsd,</span>
<span class="line" id="L712">                .netbsd,</span>
<span class="line" id="L713">                .dragonfly,</span>
<span class="line" id="L714">                .openbsd,</span>
<span class="line" id="L715">                =&gt; self.fs_thread.join(),</span>
<span class="line" id="L716">                <span class="tok-kw">else</span> =&gt; {},</span>
<span class="line" id="L717">            }</span>
<span class="line" id="L718">        }</span>
<span class="line" id="L719"></span>
<span class="line" id="L720">        <span class="tok-kw">for</span> (self.extra_threads) |extra_thread| {</span>
<span class="line" id="L721">            extra_thread.join();</span>
<span class="line" id="L722">        }</span>
<span class="line" id="L723"></span>
<span class="line" id="L724">        self.delay_queue.deinit();</span>
<span class="line" id="L725">    }</span>
<span class="line" id="L726"></span>
<span class="line" id="L727">    <span class="tok-comment">/// Runs the provided function asynchronously. The function's frame is allocated</span></span>
<span class="line" id="L728">    <span class="tok-comment">/// with `allocator` and freed when the function returns.</span></span>
<span class="line" id="L729">    <span class="tok-comment">/// `func` must return void and it can be an async function.</span></span>
<span class="line" id="L730">    <span class="tok-comment">/// Yields to the event loop, running the function on the next tick.</span></span>
<span class="line" id="L731">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">runDetached</span>(self: *Loop, alloc: mem.Allocator, <span class="tok-kw">comptime</span> func: <span class="tok-kw">anytype</span>, args: <span class="tok-kw">anytype</span>) <span class="tok-kw">error</span>{OutOfMemory}!<span class="tok-type">void</span> {</span>
<span class="line" id="L732">        <span class="tok-kw">if</span> (!std.io.is_async) <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;Can't use runDetached in non-async mode!&quot;</span>);</span>
<span class="line" id="L733">        <span class="tok-kw">if</span> (<span class="tok-builtin">@TypeOf</span>(<span class="tok-builtin">@call</span>(.{}, func, args)) != <span class="tok-type">void</span>) {</span>
<span class="line" id="L734">            <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;`func` must not have a return value&quot;</span>);</span>
<span class="line" id="L735">        }</span>
<span class="line" id="L736"></span>
<span class="line" id="L737">        <span class="tok-kw">const</span> Wrapper = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L738">            <span class="tok-kw">const</span> Args = <span class="tok-builtin">@TypeOf</span>(args);</span>
<span class="line" id="L739">            <span class="tok-kw">fn</span> <span class="tok-fn">run</span>(func_args: Args, loop: *Loop, allocator: mem.Allocator) <span class="tok-type">void</span> {</span>
<span class="line" id="L740">                loop.beginOneEvent();</span>
<span class="line" id="L741">                loop.yield();</span>
<span class="line" id="L742">                <span class="tok-builtin">@call</span>(.{}, func, func_args); <span class="tok-comment">// compile error when called with non-void ret type</span>
</span>
<span class="line" id="L743">                <span class="tok-kw">suspend</span> {</span>
<span class="line" id="L744">                    loop.finishOneEvent();</span>
<span class="line" id="L745">                    allocator.destroy(<span class="tok-builtin">@frame</span>());</span>
<span class="line" id="L746">                }</span>
<span class="line" id="L747">            }</span>
<span class="line" id="L748">        };</span>
<span class="line" id="L749"></span>
<span class="line" id="L750">        <span class="tok-kw">var</span> run_frame = <span class="tok-kw">try</span> alloc.create(<span class="tok-builtin">@Frame</span>(Wrapper.run));</span>
<span class="line" id="L751">        run_frame.* = <span class="tok-kw">async</span> Wrapper.run(args, self, alloc);</span>
<span class="line" id="L752">    }</span>
<span class="line" id="L753"></span>
<span class="line" id="L754">    <span class="tok-comment">/// Yielding lets the event loop run, starting any unstarted async operations.</span></span>
<span class="line" id="L755">    <span class="tok-comment">/// Note that async operations automatically start when a function yields for any other reason,</span></span>
<span class="line" id="L756">    <span class="tok-comment">/// for example, when async I/O is performed. This function is intended to be used only when</span></span>
<span class="line" id="L757">    <span class="tok-comment">/// CPU bound tasks would be waiting in the event loop but never get started because no async I/O</span></span>
<span class="line" id="L758">    <span class="tok-comment">/// is performed.</span></span>
<span class="line" id="L759">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">yield</span>(self: *Loop) <span class="tok-type">void</span> {</span>
<span class="line" id="L760">        <span class="tok-kw">suspend</span> {</span>
<span class="line" id="L761">            <span class="tok-kw">var</span> my_tick_node = NextTickNode{</span>
<span class="line" id="L762">                .prev = <span class="tok-null">undefined</span>,</span>
<span class="line" id="L763">                .next = <span class="tok-null">undefined</span>,</span>
<span class="line" id="L764">                .data = <span class="tok-builtin">@frame</span>(),</span>
<span class="line" id="L765">            };</span>
<span class="line" id="L766">            self.onNextTick(&amp;my_tick_node);</span>
<span class="line" id="L767">        }</span>
<span class="line" id="L768">    }</span>
<span class="line" id="L769"></span>
<span class="line" id="L770">    <span class="tok-comment">/// If the build is multi-threaded and there is an event loop, then it calls `yield`. Otherwise,</span></span>
<span class="line" id="L771">    <span class="tok-comment">/// does nothing.</span></span>
<span class="line" id="L772">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">startCpuBoundOperation</span>() <span class="tok-type">void</span> {</span>
<span class="line" id="L773">        <span class="tok-kw">if</span> (builtin.single_threaded) {</span>
<span class="line" id="L774">            <span class="tok-kw">return</span>;</span>
<span class="line" id="L775">        } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (instance) |event_loop| {</span>
<span class="line" id="L776">            event_loop.yield();</span>
<span class="line" id="L777">        }</span>
<span class="line" id="L778">    }</span>
<span class="line" id="L779"></span>
<span class="line" id="L780">    <span class="tok-comment">/// call finishOneEvent when done</span></span>
<span class="line" id="L781">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">beginOneEvent</span>(self: *Loop) <span class="tok-type">void</span> {</span>
<span class="line" id="L782">        _ = <span class="tok-builtin">@atomicRmw</span>(<span class="tok-type">usize</span>, &amp;self.pending_event_count, .Add, <span class="tok-number">1</span>, .SeqCst);</span>
<span class="line" id="L783">    }</span>
<span class="line" id="L784"></span>
<span class="line" id="L785">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">finishOneEvent</span>(self: *Loop) <span class="tok-type">void</span> {</span>
<span class="line" id="L786">        <span class="tok-kw">nosuspend</span> {</span>
<span class="line" id="L787">            <span class="tok-kw">const</span> prev = <span class="tok-builtin">@atomicRmw</span>(<span class="tok-type">usize</span>, &amp;self.pending_event_count, .Sub, <span class="tok-number">1</span>, .SeqCst);</span>
<span class="line" id="L788">            <span class="tok-kw">if</span> (prev != <span class="tok-number">1</span>) <span class="tok-kw">return</span>;</span>
<span class="line" id="L789"></span>
<span class="line" id="L790">            <span class="tok-comment">// cause all the threads to stop</span>
</span>
<span class="line" id="L791">            self.posixFsRequest(&amp;self.fs_end_request);</span>
<span class="line" id="L792"></span>
<span class="line" id="L793">            <span class="tok-kw">switch</span> (builtin.os.tag) {</span>
<span class="line" id="L794">                .linux =&gt; {</span>
<span class="line" id="L795">                    <span class="tok-comment">// writing to the eventfd will only wake up one thread, thus multiple writes</span>
</span>
<span class="line" id="L796">                    <span class="tok-comment">// are needed to wakeup all the threads</span>
</span>
<span class="line" id="L797">                    <span class="tok-kw">var</span> i: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L798">                    <span class="tok-kw">while</span> (i &lt; self.extra_threads.len + <span class="tok-number">1</span>) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L799">                        <span class="tok-comment">// writing 8 bytes to an eventfd cannot fail</span>
</span>
<span class="line" id="L800">                        <span class="tok-kw">const</span> amt = os.write(self.os_data.final_eventfd, &amp;wakeup_bytes) <span class="tok-kw">catch</span> <span class="tok-kw">unreachable</span>;</span>
<span class="line" id="L801">                        assert(amt == wakeup_bytes.len);</span>
<span class="line" id="L802">                    }</span>
<span class="line" id="L803">                    <span class="tok-kw">return</span>;</span>
<span class="line" id="L804">                },</span>
<span class="line" id="L805">                .macos, .freebsd, .netbsd, .dragonfly, .openbsd =&gt; {</span>
<span class="line" id="L806">                    <span class="tok-kw">const</span> final_kevent = <span class="tok-builtin">@as</span>(*<span class="tok-kw">const</span> [<span class="tok-number">1</span>]os.Kevent, &amp;self.os_data.final_kevent);</span>
<span class="line" id="L807">                    <span class="tok-kw">const</span> empty_kevs = &amp;[<span class="tok-number">0</span>]os.Kevent{};</span>
<span class="line" id="L808">                    <span class="tok-comment">// cannot fail because we already added it and this just enables it</span>
</span>
<span class="line" id="L809">                    _ = os.kevent(self.os_data.kqfd, final_kevent, empty_kevs, <span class="tok-null">null</span>) <span class="tok-kw">catch</span> <span class="tok-kw">unreachable</span>;</span>
<span class="line" id="L810">                    <span class="tok-kw">return</span>;</span>
<span class="line" id="L811">                },</span>
<span class="line" id="L812">                .windows =&gt; {</span>
<span class="line" id="L813">                    <span class="tok-kw">var</span> i: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L814">                    <span class="tok-kw">while</span> (i &lt; self.extra_threads.len + <span class="tok-number">1</span>) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L815">                        <span class="tok-kw">while</span> (<span class="tok-null">true</span>) {</span>
<span class="line" id="L816">                            <span class="tok-kw">const</span> overlapped = &amp;self.final_resume_node.overlapped;</span>
<span class="line" id="L817">                            windows.PostQueuedCompletionStatus(self.os_data.io_port, <span class="tok-null">undefined</span>, <span class="tok-null">undefined</span>, overlapped) <span class="tok-kw">catch</span> <span class="tok-kw">continue</span>;</span>
<span class="line" id="L818">                            <span class="tok-kw">break</span>;</span>
<span class="line" id="L819">                        }</span>
<span class="line" id="L820">                    }</span>
<span class="line" id="L821">                    <span class="tok-kw">return</span>;</span>
<span class="line" id="L822">                },</span>
<span class="line" id="L823">                <span class="tok-kw">else</span> =&gt; <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;unsupported OS&quot;</span>),</span>
<span class="line" id="L824">            }</span>
<span class="line" id="L825">        }</span>
<span class="line" id="L826">    }</span>
<span class="line" id="L827"></span>
<span class="line" id="L828">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">sleep</span>(self: *Loop, nanoseconds: <span class="tok-type">u64</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L829">        <span class="tok-kw">if</span> (builtin.single_threaded)</span>
<span class="line" id="L830">            <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;TODO: integrate timers with epoll/kevent/iocp for single-threaded&quot;</span>);</span>
<span class="line" id="L831"></span>
<span class="line" id="L832">        <span class="tok-kw">suspend</span> {</span>
<span class="line" id="L833">            <span class="tok-kw">const</span> now = self.delay_queue.timer.read();</span>
<span class="line" id="L834"></span>
<span class="line" id="L835">            <span class="tok-kw">var</span> entry: DelayQueue.Waiters.Entry = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L836">            entry.init(<span class="tok-builtin">@frame</span>(), now + nanoseconds);</span>
<span class="line" id="L837">            self.delay_queue.waiters.insert(&amp;entry);</span>
<span class="line" id="L838"></span>
<span class="line" id="L839">            <span class="tok-comment">// Speculatively wake up the timer thread when we add a new entry.</span>
</span>
<span class="line" id="L840">            <span class="tok-comment">// If the timer thread is sleeping on a longer entry, we need to</span>
</span>
<span class="line" id="L841">            <span class="tok-comment">// interrupt it so that our entry can be expired in time.</span>
</span>
<span class="line" id="L842">            self.delay_queue.event.set();</span>
<span class="line" id="L843">        }</span>
<span class="line" id="L844">    }</span>
<span class="line" id="L845"></span>
<span class="line" id="L846">    <span class="tok-kw">const</span> DelayQueue = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L847">        timer: std.time.Timer,</span>
<span class="line" id="L848">        waiters: Waiters,</span>
<span class="line" id="L849">        thread: std.Thread,</span>
<span class="line" id="L850">        event: std.Thread.ResetEvent,</span>
<span class="line" id="L851">        is_running: Atomic(<span class="tok-type">bool</span>),</span>
<span class="line" id="L852"></span>
<span class="line" id="L853">        <span class="tok-comment">/// Initialize the delay queue by spawning the timer thread</span></span>
<span class="line" id="L854">        <span class="tok-comment">/// and starting any timer resources.</span></span>
<span class="line" id="L855">        <span class="tok-kw">fn</span> <span class="tok-fn">init</span>(self: *DelayQueue) !<span class="tok-type">void</span> {</span>
<span class="line" id="L856">            self.* = DelayQueue{</span>
<span class="line" id="L857">                .timer = <span class="tok-kw">try</span> std.time.Timer.start(),</span>
<span class="line" id="L858">                .waiters = DelayQueue.Waiters{</span>
<span class="line" id="L859">                    .entries = std.atomic.Queue(<span class="tok-kw">anyframe</span>).init(),</span>
<span class="line" id="L860">                },</span>
<span class="line" id="L861">                .thread = <span class="tok-null">undefined</span>,</span>
<span class="line" id="L862">                .event = .{},</span>
<span class="line" id="L863">                .is_running = Atomic(<span class="tok-type">bool</span>).init(<span class="tok-null">true</span>),</span>
<span class="line" id="L864">            };</span>
<span class="line" id="L865"></span>
<span class="line" id="L866">            <span class="tok-comment">// Must be after init so that it can read the other state, such as `is_running`.</span>
</span>
<span class="line" id="L867">            self.thread = <span class="tok-kw">try</span> std.Thread.spawn(.{}, DelayQueue.run, .{self});</span>
<span class="line" id="L868">        }</span>
<span class="line" id="L869"></span>
<span class="line" id="L870">        <span class="tok-kw">fn</span> <span class="tok-fn">deinit</span>(self: *DelayQueue) <span class="tok-type">void</span> {</span>
<span class="line" id="L871">            self.is_running.store(<span class="tok-null">false</span>, .SeqCst);</span>
<span class="line" id="L872">            self.event.set();</span>
<span class="line" id="L873">            self.thread.join();</span>
<span class="line" id="L874">        }</span>
<span class="line" id="L875"></span>
<span class="line" id="L876">        <span class="tok-comment">/// Entry point for the timer thread</span></span>
<span class="line" id="L877">        <span class="tok-comment">/// which waits for timer entries to expire and reschedules them.</span></span>
<span class="line" id="L878">        <span class="tok-kw">fn</span> <span class="tok-fn">run</span>(self: *DelayQueue) <span class="tok-type">void</span> {</span>
<span class="line" id="L879">            <span class="tok-kw">const</span> loop = <span class="tok-builtin">@fieldParentPtr</span>(Loop, <span class="tok-str">&quot;delay_queue&quot;</span>, self);</span>
<span class="line" id="L880"></span>
<span class="line" id="L881">            <span class="tok-kw">while</span> (self.is_running.load(.SeqCst)) {</span>
<span class="line" id="L882">                self.event.reset();</span>
<span class="line" id="L883">                <span class="tok-kw">const</span> now = self.timer.read();</span>
<span class="line" id="L884"></span>
<span class="line" id="L885">                <span class="tok-kw">if</span> (self.waiters.popExpired(now)) |entry| {</span>
<span class="line" id="L886">                    loop.onNextTick(&amp;entry.node);</span>
<span class="line" id="L887">                    <span class="tok-kw">continue</span>;</span>
<span class="line" id="L888">                }</span>
<span class="line" id="L889"></span>
<span class="line" id="L890">                <span class="tok-kw">if</span> (self.waiters.nextExpire()) |expires| {</span>
<span class="line" id="L891">                    <span class="tok-kw">if</span> (now &gt;= expires)</span>
<span class="line" id="L892">                        <span class="tok-kw">continue</span>;</span>
<span class="line" id="L893">                    self.event.timedWait(expires - now) <span class="tok-kw">catch</span> {};</span>
<span class="line" id="L894">                } <span class="tok-kw">else</span> {</span>
<span class="line" id="L895">                    self.event.wait();</span>
<span class="line" id="L896">                }</span>
<span class="line" id="L897">            }</span>
<span class="line" id="L898">        }</span>
<span class="line" id="L899"></span>
<span class="line" id="L900">        <span class="tok-comment">// TODO: use a tickless heirarchical timer wheel:</span>
</span>
<span class="line" id="L901">        <span class="tok-comment">// https://github.com/wahern/timeout/</span>
</span>
<span class="line" id="L902">        <span class="tok-kw">const</span> Waiters = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L903">            entries: std.atomic.Queue(<span class="tok-kw">anyframe</span>),</span>
<span class="line" id="L904"></span>
<span class="line" id="L905">            <span class="tok-kw">const</span> Entry = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L906">                node: NextTickNode,</span>
<span class="line" id="L907">                expires: <span class="tok-type">u64</span>,</span>
<span class="line" id="L908"></span>
<span class="line" id="L909">                <span class="tok-kw">fn</span> <span class="tok-fn">init</span>(self: *Entry, frame: <span class="tok-kw">anyframe</span>, expires: <span class="tok-type">u64</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L910">                    self.node.data = frame;</span>
<span class="line" id="L911">                    self.expires = expires;</span>
<span class="line" id="L912">                }</span>
<span class="line" id="L913">            };</span>
<span class="line" id="L914"></span>
<span class="line" id="L915">            <span class="tok-comment">/// Registers the entry into the queue of waiting frames</span></span>
<span class="line" id="L916">            <span class="tok-kw">fn</span> <span class="tok-fn">insert</span>(self: *Waiters, entry: *Entry) <span class="tok-type">void</span> {</span>
<span class="line" id="L917">                self.entries.put(&amp;entry.node);</span>
<span class="line" id="L918">            }</span>
<span class="line" id="L919"></span>
<span class="line" id="L920">            <span class="tok-comment">/// Dequeues one expired event relative to `now`</span></span>
<span class="line" id="L921">            <span class="tok-kw">fn</span> <span class="tok-fn">popExpired</span>(self: *Waiters, now: <span class="tok-type">u64</span>) ?*Entry {</span>
<span class="line" id="L922">                <span class="tok-kw">const</span> entry = self.peekExpiringEntry() <span class="tok-kw">orelse</span> <span class="tok-kw">return</span> <span class="tok-null">null</span>;</span>
<span class="line" id="L923">                <span class="tok-kw">if</span> (entry.expires &gt; now)</span>
<span class="line" id="L924">                    <span class="tok-kw">return</span> <span class="tok-null">null</span>;</span>
<span class="line" id="L925"></span>
<span class="line" id="L926">                assert(self.entries.remove(&amp;entry.node));</span>
<span class="line" id="L927">                <span class="tok-kw">return</span> entry;</span>
<span class="line" id="L928">            }</span>
<span class="line" id="L929"></span>
<span class="line" id="L930">            <span class="tok-comment">/// Returns an estimate for the amount of time</span></span>
<span class="line" id="L931">            <span class="tok-comment">/// to wait until the next waiting entry expires.</span></span>
<span class="line" id="L932">            <span class="tok-kw">fn</span> <span class="tok-fn">nextExpire</span>(self: *Waiters) ?<span class="tok-type">u64</span> {</span>
<span class="line" id="L933">                <span class="tok-kw">const</span> entry = self.peekExpiringEntry() <span class="tok-kw">orelse</span> <span class="tok-kw">return</span> <span class="tok-null">null</span>;</span>
<span class="line" id="L934">                <span class="tok-kw">return</span> entry.expires;</span>
<span class="line" id="L935">            }</span>
<span class="line" id="L936"></span>
<span class="line" id="L937">            <span class="tok-kw">fn</span> <span class="tok-fn">peekExpiringEntry</span>(self: *Waiters) ?*Entry {</span>
<span class="line" id="L938">                self.entries.mutex.lock();</span>
<span class="line" id="L939">                <span class="tok-kw">defer</span> self.entries.mutex.unlock();</span>
<span class="line" id="L940"></span>
<span class="line" id="L941">                <span class="tok-comment">// starting from the head</span>
</span>
<span class="line" id="L942">                <span class="tok-kw">var</span> head = self.entries.head <span class="tok-kw">orelse</span> <span class="tok-kw">return</span> <span class="tok-null">null</span>;</span>
<span class="line" id="L943"></span>
<span class="line" id="L944">                <span class="tok-comment">// traverse the list of waiting entires to</span>
</span>
<span class="line" id="L945">                <span class="tok-comment">// find the Node with the smallest `expires` field</span>
</span>
<span class="line" id="L946">                <span class="tok-kw">var</span> min = head;</span>
<span class="line" id="L947">                <span class="tok-kw">while</span> (head.next) |node| {</span>
<span class="line" id="L948">                    <span class="tok-kw">const</span> minEntry = <span class="tok-builtin">@fieldParentPtr</span>(Entry, <span class="tok-str">&quot;node&quot;</span>, min);</span>
<span class="line" id="L949">                    <span class="tok-kw">const</span> nodeEntry = <span class="tok-builtin">@fieldParentPtr</span>(Entry, <span class="tok-str">&quot;node&quot;</span>, node);</span>
<span class="line" id="L950">                    <span class="tok-kw">if</span> (nodeEntry.expires &lt; minEntry.expires)</span>
<span class="line" id="L951">                        min = node;</span>
<span class="line" id="L952">                    head = node;</span>
<span class="line" id="L953">                }</span>
<span class="line" id="L954"></span>
<span class="line" id="L955">                <span class="tok-kw">return</span> <span class="tok-builtin">@fieldParentPtr</span>(Entry, <span class="tok-str">&quot;node&quot;</span>, min);</span>
<span class="line" id="L956">            }</span>
<span class="line" id="L957">        };</span>
<span class="line" id="L958">    };</span>
<span class="line" id="L959"></span>
<span class="line" id="L960">    <span class="tok-comment">/// ------- I/0 APIs -------</span></span>
<span class="line" id="L961">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">accept</span>(</span>
<span class="line" id="L962">        self: *Loop,</span>
<span class="line" id="L963">        <span class="tok-comment">/// This argument is a socket that has been created with `socket`, bound to a local address</span></span>
<span class="line" id="L964">        <span class="tok-comment">/// with `bind`, and is listening for connections after a `listen`.</span></span>
<span class="line" id="L965">        sockfd: os.socket_t,</span>
<span class="line" id="L966">        <span class="tok-comment">/// This argument is a pointer to a sockaddr structure.  This structure is filled in with  the</span></span>
<span class="line" id="L967">        <span class="tok-comment">/// address  of  the  peer  socket, as known to the communications layer.  The exact format of the</span></span>
<span class="line" id="L968">        <span class="tok-comment">/// address returned addr is determined by the socket's address  family  (see  `socket`  and  the</span></span>
<span class="line" id="L969">        <span class="tok-comment">/// respective  protocol  man  pages).</span></span>
<span class="line" id="L970">        addr: *os.sockaddr,</span>
<span class="line" id="L971">        <span class="tok-comment">/// This argument is a value-result argument: the caller must initialize it to contain  the</span></span>
<span class="line" id="L972">        <span class="tok-comment">/// size (in bytes) of the structure pointed to by addr; on return it will contain the actual size</span></span>
<span class="line" id="L973">        <span class="tok-comment">/// of the peer address.</span></span>
<span class="line" id="L974">        <span class="tok-comment">///</span></span>
<span class="line" id="L975">        <span class="tok-comment">/// The returned address is truncated if the buffer provided is too small; in this  case,  `addr_size`</span></span>
<span class="line" id="L976">        <span class="tok-comment">/// will return a value greater than was supplied to the call.</span></span>
<span class="line" id="L977">        addr_size: *os.socklen_t,</span>
<span class="line" id="L978">        <span class="tok-comment">/// The following values can be bitwise ORed in flags to obtain different behavior:</span></span>
<span class="line" id="L979">        <span class="tok-comment">/// * `SOCK.CLOEXEC`  - Set the close-on-exec (`FD_CLOEXEC`) flag on the new file descriptor.   See  the</span></span>
<span class="line" id="L980">        <span class="tok-comment">///   description  of the `O.CLOEXEC` flag in `open` for reasons why this may be useful.</span></span>
<span class="line" id="L981">        flags: <span class="tok-type">u32</span>,</span>
<span class="line" id="L982">    ) os.AcceptError!os.socket_t {</span>
<span class="line" id="L983">        <span class="tok-kw">while</span> (<span class="tok-null">true</span>) {</span>
<span class="line" id="L984">            <span class="tok-kw">return</span> os.accept(sockfd, addr, addr_size, flags | os.SOCK.NONBLOCK) <span class="tok-kw">catch</span> |err| <span class="tok-kw">switch</span> (err) {</span>
<span class="line" id="L985">                <span class="tok-kw">error</span>.WouldBlock =&gt; {</span>
<span class="line" id="L986">                    self.waitUntilFdReadable(sockfd);</span>
<span class="line" id="L987">                    <span class="tok-kw">continue</span>;</span>
<span class="line" id="L988">                },</span>
<span class="line" id="L989">                <span class="tok-kw">else</span> =&gt; <span class="tok-kw">return</span> err,</span>
<span class="line" id="L990">            };</span>
<span class="line" id="L991">        }</span>
<span class="line" id="L992">    }</span>
<span class="line" id="L993"></span>
<span class="line" id="L994">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">connect</span>(self: *Loop, sockfd: os.socket_t, sock_addr: *<span class="tok-kw">const</span> os.sockaddr, len: os.socklen_t) os.ConnectError!<span class="tok-type">void</span> {</span>
<span class="line" id="L995">        os.connect(sockfd, sock_addr, len) <span class="tok-kw">catch</span> |err| <span class="tok-kw">switch</span> (err) {</span>
<span class="line" id="L996">            <span class="tok-kw">error</span>.WouldBlock =&gt; {</span>
<span class="line" id="L997">                self.waitUntilFdWritable(sockfd);</span>
<span class="line" id="L998">                <span class="tok-kw">return</span> os.getsockoptError(sockfd);</span>
<span class="line" id="L999">            },</span>
<span class="line" id="L1000">            <span class="tok-kw">else</span> =&gt; <span class="tok-kw">return</span> err,</span>
<span class="line" id="L1001">        };</span>
<span class="line" id="L1002">    }</span>
<span class="line" id="L1003"></span>
<span class="line" id="L1004">    <span class="tok-comment">/// Performs an async `os.open` using a separate thread.</span></span>
<span class="line" id="L1005">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">openZ</span>(self: *Loop, file_path: [*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span>, flags: <span class="tok-type">u32</span>, mode: os.mode_t) os.OpenError!os.fd_t {</span>
<span class="line" id="L1006">        <span class="tok-kw">var</span> req_node = Request.Node{</span>
<span class="line" id="L1007">            .data = .{</span>
<span class="line" id="L1008">                .msg = .{</span>
<span class="line" id="L1009">                    .open = .{</span>
<span class="line" id="L1010">                        .path = file_path,</span>
<span class="line" id="L1011">                        .flags = flags,</span>
<span class="line" id="L1012">                        .mode = mode,</span>
<span class="line" id="L1013">                        .result = <span class="tok-null">undefined</span>,</span>
<span class="line" id="L1014">                    },</span>
<span class="line" id="L1015">                },</span>
<span class="line" id="L1016">                .finish = .{ .TickNode = .{ .data = <span class="tok-builtin">@frame</span>() } },</span>
<span class="line" id="L1017">            },</span>
<span class="line" id="L1018">        };</span>
<span class="line" id="L1019">        <span class="tok-kw">suspend</span> {</span>
<span class="line" id="L1020">            self.posixFsRequest(&amp;req_node);</span>
<span class="line" id="L1021">        }</span>
<span class="line" id="L1022">        <span class="tok-kw">return</span> req_node.data.msg.open.result;</span>
<span class="line" id="L1023">    }</span>
<span class="line" id="L1024"></span>
<span class="line" id="L1025">    <span class="tok-comment">/// Performs an async `os.opent` using a separate thread.</span></span>
<span class="line" id="L1026">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">openatZ</span>(self: *Loop, fd: os.fd_t, file_path: [*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span>, flags: <span class="tok-type">u32</span>, mode: os.mode_t) os.OpenError!os.fd_t {</span>
<span class="line" id="L1027">        <span class="tok-kw">var</span> req_node = Request.Node{</span>
<span class="line" id="L1028">            .data = .{</span>
<span class="line" id="L1029">                .msg = .{</span>
<span class="line" id="L1030">                    .openat = .{</span>
<span class="line" id="L1031">                        .fd = fd,</span>
<span class="line" id="L1032">                        .path = file_path,</span>
<span class="line" id="L1033">                        .flags = flags,</span>
<span class="line" id="L1034">                        .mode = mode,</span>
<span class="line" id="L1035">                        .result = <span class="tok-null">undefined</span>,</span>
<span class="line" id="L1036">                    },</span>
<span class="line" id="L1037">                },</span>
<span class="line" id="L1038">                .finish = .{ .TickNode = .{ .data = <span class="tok-builtin">@frame</span>() } },</span>
<span class="line" id="L1039">            },</span>
<span class="line" id="L1040">        };</span>
<span class="line" id="L1041">        <span class="tok-kw">suspend</span> {</span>
<span class="line" id="L1042">            self.posixFsRequest(&amp;req_node);</span>
<span class="line" id="L1043">        }</span>
<span class="line" id="L1044">        <span class="tok-kw">return</span> req_node.data.msg.openat.result;</span>
<span class="line" id="L1045">    }</span>
<span class="line" id="L1046"></span>
<span class="line" id="L1047">    <span class="tok-comment">/// Performs an async `os.close` using a separate thread.</span></span>
<span class="line" id="L1048">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">close</span>(self: *Loop, fd: os.fd_t) <span class="tok-type">void</span> {</span>
<span class="line" id="L1049">        <span class="tok-kw">var</span> req_node = Request.Node{</span>
<span class="line" id="L1050">            .data = .{</span>
<span class="line" id="L1051">                .msg = .{ .close = .{ .fd = fd } },</span>
<span class="line" id="L1052">                .finish = .{ .TickNode = .{ .data = <span class="tok-builtin">@frame</span>() } },</span>
<span class="line" id="L1053">            },</span>
<span class="line" id="L1054">        };</span>
<span class="line" id="L1055">        <span class="tok-kw">suspend</span> {</span>
<span class="line" id="L1056">            self.posixFsRequest(&amp;req_node);</span>
<span class="line" id="L1057">        }</span>
<span class="line" id="L1058">    }</span>
<span class="line" id="L1059"></span>
<span class="line" id="L1060">    <span class="tok-comment">/// Performs an async `os.read` using a separate thread.</span></span>
<span class="line" id="L1061">    <span class="tok-comment">/// `fd` must block and not return EAGAIN.</span></span>
<span class="line" id="L1062">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">read</span>(self: *Loop, fd: os.fd_t, buf: []<span class="tok-type">u8</span>, simulate_evented: <span class="tok-type">bool</span>) os.ReadError!<span class="tok-type">usize</span> {</span>
<span class="line" id="L1063">        <span class="tok-kw">if</span> (simulate_evented) {</span>
<span class="line" id="L1064">            <span class="tok-kw">var</span> req_node = Request.Node{</span>
<span class="line" id="L1065">                .data = .{</span>
<span class="line" id="L1066">                    .msg = .{</span>
<span class="line" id="L1067">                        .read = .{</span>
<span class="line" id="L1068">                            .fd = fd,</span>
<span class="line" id="L1069">                            .buf = buf,</span>
<span class="line" id="L1070">                            .result = <span class="tok-null">undefined</span>,</span>
<span class="line" id="L1071">                        },</span>
<span class="line" id="L1072">                    },</span>
<span class="line" id="L1073">                    .finish = .{ .TickNode = .{ .data = <span class="tok-builtin">@frame</span>() } },</span>
<span class="line" id="L1074">                },</span>
<span class="line" id="L1075">            };</span>
<span class="line" id="L1076">            <span class="tok-kw">suspend</span> {</span>
<span class="line" id="L1077">                self.posixFsRequest(&amp;req_node);</span>
<span class="line" id="L1078">            }</span>
<span class="line" id="L1079">            <span class="tok-kw">return</span> req_node.data.msg.read.result;</span>
<span class="line" id="L1080">        } <span class="tok-kw">else</span> {</span>
<span class="line" id="L1081">            <span class="tok-kw">while</span> (<span class="tok-null">true</span>) {</span>
<span class="line" id="L1082">                <span class="tok-kw">return</span> os.read(fd, buf) <span class="tok-kw">catch</span> |err| <span class="tok-kw">switch</span> (err) {</span>
<span class="line" id="L1083">                    <span class="tok-kw">error</span>.WouldBlock =&gt; {</span>
<span class="line" id="L1084">                        self.waitUntilFdReadable(fd);</span>
<span class="line" id="L1085">                        <span class="tok-kw">continue</span>;</span>
<span class="line" id="L1086">                    },</span>
<span class="line" id="L1087">                    <span class="tok-kw">else</span> =&gt; <span class="tok-kw">return</span> err,</span>
<span class="line" id="L1088">                };</span>
<span class="line" id="L1089">            }</span>
<span class="line" id="L1090">        }</span>
<span class="line" id="L1091">    }</span>
<span class="line" id="L1092"></span>
<span class="line" id="L1093">    <span class="tok-comment">/// Performs an async `os.readv` using a separate thread.</span></span>
<span class="line" id="L1094">    <span class="tok-comment">/// `fd` must block and not return EAGAIN.</span></span>
<span class="line" id="L1095">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">readv</span>(self: *Loop, fd: os.fd_t, iov: []<span class="tok-kw">const</span> os.iovec, simulate_evented: <span class="tok-type">bool</span>) os.ReadError!<span class="tok-type">usize</span> {</span>
<span class="line" id="L1096">        <span class="tok-kw">if</span> (simulate_evented) {</span>
<span class="line" id="L1097">            <span class="tok-kw">var</span> req_node = Request.Node{</span>
<span class="line" id="L1098">                .data = .{</span>
<span class="line" id="L1099">                    .msg = .{</span>
<span class="line" id="L1100">                        .readv = .{</span>
<span class="line" id="L1101">                            .fd = fd,</span>
<span class="line" id="L1102">                            .iov = iov,</span>
<span class="line" id="L1103">                            .result = <span class="tok-null">undefined</span>,</span>
<span class="line" id="L1104">                        },</span>
<span class="line" id="L1105">                    },</span>
<span class="line" id="L1106">                    .finish = .{ .TickNode = .{ .data = <span class="tok-builtin">@frame</span>() } },</span>
<span class="line" id="L1107">                },</span>
<span class="line" id="L1108">            };</span>
<span class="line" id="L1109">            <span class="tok-kw">suspend</span> {</span>
<span class="line" id="L1110">                self.posixFsRequest(&amp;req_node);</span>
<span class="line" id="L1111">            }</span>
<span class="line" id="L1112">            <span class="tok-kw">return</span> req_node.data.msg.readv.result;</span>
<span class="line" id="L1113">        } <span class="tok-kw">else</span> {</span>
<span class="line" id="L1114">            <span class="tok-kw">while</span> (<span class="tok-null">true</span>) {</span>
<span class="line" id="L1115">                <span class="tok-kw">return</span> os.readv(fd, iov) <span class="tok-kw">catch</span> |err| <span class="tok-kw">switch</span> (err) {</span>
<span class="line" id="L1116">                    <span class="tok-kw">error</span>.WouldBlock =&gt; {</span>
<span class="line" id="L1117">                        self.waitUntilFdReadable(fd);</span>
<span class="line" id="L1118">                        <span class="tok-kw">continue</span>;</span>
<span class="line" id="L1119">                    },</span>
<span class="line" id="L1120">                    <span class="tok-kw">else</span> =&gt; <span class="tok-kw">return</span> err,</span>
<span class="line" id="L1121">                };</span>
<span class="line" id="L1122">            }</span>
<span class="line" id="L1123">        }</span>
<span class="line" id="L1124">    }</span>
<span class="line" id="L1125"></span>
<span class="line" id="L1126">    <span class="tok-comment">/// Performs an async `os.pread` using a separate thread.</span></span>
<span class="line" id="L1127">    <span class="tok-comment">/// `fd` must block and not return EAGAIN.</span></span>
<span class="line" id="L1128">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">pread</span>(self: *Loop, fd: os.fd_t, buf: []<span class="tok-type">u8</span>, offset: <span class="tok-type">u64</span>, simulate_evented: <span class="tok-type">bool</span>) os.PReadError!<span class="tok-type">usize</span> {</span>
<span class="line" id="L1129">        <span class="tok-kw">if</span> (simulate_evented) {</span>
<span class="line" id="L1130">            <span class="tok-kw">var</span> req_node = Request.Node{</span>
<span class="line" id="L1131">                .data = .{</span>
<span class="line" id="L1132">                    .msg = .{</span>
<span class="line" id="L1133">                        .pread = .{</span>
<span class="line" id="L1134">                            .fd = fd,</span>
<span class="line" id="L1135">                            .buf = buf,</span>
<span class="line" id="L1136">                            .offset = offset,</span>
<span class="line" id="L1137">                            .result = <span class="tok-null">undefined</span>,</span>
<span class="line" id="L1138">                        },</span>
<span class="line" id="L1139">                    },</span>
<span class="line" id="L1140">                    .finish = .{ .TickNode = .{ .data = <span class="tok-builtin">@frame</span>() } },</span>
<span class="line" id="L1141">                },</span>
<span class="line" id="L1142">            };</span>
<span class="line" id="L1143">            <span class="tok-kw">suspend</span> {</span>
<span class="line" id="L1144">                self.posixFsRequest(&amp;req_node);</span>
<span class="line" id="L1145">            }</span>
<span class="line" id="L1146">            <span class="tok-kw">return</span> req_node.data.msg.pread.result;</span>
<span class="line" id="L1147">        } <span class="tok-kw">else</span> {</span>
<span class="line" id="L1148">            <span class="tok-kw">while</span> (<span class="tok-null">true</span>) {</span>
<span class="line" id="L1149">                <span class="tok-kw">return</span> os.pread(fd, buf, offset) <span class="tok-kw">catch</span> |err| <span class="tok-kw">switch</span> (err) {</span>
<span class="line" id="L1150">                    <span class="tok-kw">error</span>.WouldBlock =&gt; {</span>
<span class="line" id="L1151">                        self.waitUntilFdReadable(fd);</span>
<span class="line" id="L1152">                        <span class="tok-kw">continue</span>;</span>
<span class="line" id="L1153">                    },</span>
<span class="line" id="L1154">                    <span class="tok-kw">else</span> =&gt; <span class="tok-kw">return</span> err,</span>
<span class="line" id="L1155">                };</span>
<span class="line" id="L1156">            }</span>
<span class="line" id="L1157">        }</span>
<span class="line" id="L1158">    }</span>
<span class="line" id="L1159"></span>
<span class="line" id="L1160">    <span class="tok-comment">/// Performs an async `os.preadv` using a separate thread.</span></span>
<span class="line" id="L1161">    <span class="tok-comment">/// `fd` must block and not return EAGAIN.</span></span>
<span class="line" id="L1162">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">preadv</span>(self: *Loop, fd: os.fd_t, iov: []<span class="tok-kw">const</span> os.iovec, offset: <span class="tok-type">u64</span>, simulate_evented: <span class="tok-type">bool</span>) os.ReadError!<span class="tok-type">usize</span> {</span>
<span class="line" id="L1163">        <span class="tok-kw">if</span> (simulate_evented) {</span>
<span class="line" id="L1164">            <span class="tok-kw">var</span> req_node = Request.Node{</span>
<span class="line" id="L1165">                .data = .{</span>
<span class="line" id="L1166">                    .msg = .{</span>
<span class="line" id="L1167">                        .preadv = .{</span>
<span class="line" id="L1168">                            .fd = fd,</span>
<span class="line" id="L1169">                            .iov = iov,</span>
<span class="line" id="L1170">                            .offset = offset,</span>
<span class="line" id="L1171">                            .result = <span class="tok-null">undefined</span>,</span>
<span class="line" id="L1172">                        },</span>
<span class="line" id="L1173">                    },</span>
<span class="line" id="L1174">                    .finish = .{ .TickNode = .{ .data = <span class="tok-builtin">@frame</span>() } },</span>
<span class="line" id="L1175">                },</span>
<span class="line" id="L1176">            };</span>
<span class="line" id="L1177">            <span class="tok-kw">suspend</span> {</span>
<span class="line" id="L1178">                self.posixFsRequest(&amp;req_node);</span>
<span class="line" id="L1179">            }</span>
<span class="line" id="L1180">            <span class="tok-kw">return</span> req_node.data.msg.preadv.result;</span>
<span class="line" id="L1181">        } <span class="tok-kw">else</span> {</span>
<span class="line" id="L1182">            <span class="tok-kw">while</span> (<span class="tok-null">true</span>) {</span>
<span class="line" id="L1183">                <span class="tok-kw">return</span> os.preadv(fd, iov, offset) <span class="tok-kw">catch</span> |err| <span class="tok-kw">switch</span> (err) {</span>
<span class="line" id="L1184">                    <span class="tok-kw">error</span>.WouldBlock =&gt; {</span>
<span class="line" id="L1185">                        self.waitUntilFdReadable(fd);</span>
<span class="line" id="L1186">                        <span class="tok-kw">continue</span>;</span>
<span class="line" id="L1187">                    },</span>
<span class="line" id="L1188">                    <span class="tok-kw">else</span> =&gt; <span class="tok-kw">return</span> err,</span>
<span class="line" id="L1189">                };</span>
<span class="line" id="L1190">            }</span>
<span class="line" id="L1191">        }</span>
<span class="line" id="L1192">    }</span>
<span class="line" id="L1193"></span>
<span class="line" id="L1194">    <span class="tok-comment">/// Performs an async `os.write` using a separate thread.</span></span>
<span class="line" id="L1195">    <span class="tok-comment">/// `fd` must block and not return EAGAIN.</span></span>
<span class="line" id="L1196">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">write</span>(self: *Loop, fd: os.fd_t, bytes: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, simulate_evented: <span class="tok-type">bool</span>) os.WriteError!<span class="tok-type">usize</span> {</span>
<span class="line" id="L1197">        <span class="tok-kw">if</span> (simulate_evented) {</span>
<span class="line" id="L1198">            <span class="tok-kw">var</span> req_node = Request.Node{</span>
<span class="line" id="L1199">                .data = .{</span>
<span class="line" id="L1200">                    .msg = .{</span>
<span class="line" id="L1201">                        .write = .{</span>
<span class="line" id="L1202">                            .fd = fd,</span>
<span class="line" id="L1203">                            .bytes = bytes,</span>
<span class="line" id="L1204">                            .result = <span class="tok-null">undefined</span>,</span>
<span class="line" id="L1205">                        },</span>
<span class="line" id="L1206">                    },</span>
<span class="line" id="L1207">                    .finish = .{ .TickNode = .{ .data = <span class="tok-builtin">@frame</span>() } },</span>
<span class="line" id="L1208">                },</span>
<span class="line" id="L1209">            };</span>
<span class="line" id="L1210">            <span class="tok-kw">suspend</span> {</span>
<span class="line" id="L1211">                self.posixFsRequest(&amp;req_node);</span>
<span class="line" id="L1212">            }</span>
<span class="line" id="L1213">            <span class="tok-kw">return</span> req_node.data.msg.write.result;</span>
<span class="line" id="L1214">        } <span class="tok-kw">else</span> {</span>
<span class="line" id="L1215">            <span class="tok-kw">while</span> (<span class="tok-null">true</span>) {</span>
<span class="line" id="L1216">                <span class="tok-kw">return</span> os.write(fd, bytes) <span class="tok-kw">catch</span> |err| <span class="tok-kw">switch</span> (err) {</span>
<span class="line" id="L1217">                    <span class="tok-kw">error</span>.WouldBlock =&gt; {</span>
<span class="line" id="L1218">                        self.waitUntilFdWritable(fd);</span>
<span class="line" id="L1219">                        <span class="tok-kw">continue</span>;</span>
<span class="line" id="L1220">                    },</span>
<span class="line" id="L1221">                    <span class="tok-kw">else</span> =&gt; <span class="tok-kw">return</span> err,</span>
<span class="line" id="L1222">                };</span>
<span class="line" id="L1223">            }</span>
<span class="line" id="L1224">        }</span>
<span class="line" id="L1225">    }</span>
<span class="line" id="L1226"></span>
<span class="line" id="L1227">    <span class="tok-comment">/// Performs an async `os.writev` using a separate thread.</span></span>
<span class="line" id="L1228">    <span class="tok-comment">/// `fd` must block and not return EAGAIN.</span></span>
<span class="line" id="L1229">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">writev</span>(self: *Loop, fd: os.fd_t, iov: []<span class="tok-kw">const</span> os.iovec_const, simulate_evented: <span class="tok-type">bool</span>) os.WriteError!<span class="tok-type">usize</span> {</span>
<span class="line" id="L1230">        <span class="tok-kw">if</span> (simulate_evented) {</span>
<span class="line" id="L1231">            <span class="tok-kw">var</span> req_node = Request.Node{</span>
<span class="line" id="L1232">                .data = .{</span>
<span class="line" id="L1233">                    .msg = .{</span>
<span class="line" id="L1234">                        .writev = .{</span>
<span class="line" id="L1235">                            .fd = fd,</span>
<span class="line" id="L1236">                            .iov = iov,</span>
<span class="line" id="L1237">                            .result = <span class="tok-null">undefined</span>,</span>
<span class="line" id="L1238">                        },</span>
<span class="line" id="L1239">                    },</span>
<span class="line" id="L1240">                    .finish = .{ .TickNode = .{ .data = <span class="tok-builtin">@frame</span>() } },</span>
<span class="line" id="L1241">                },</span>
<span class="line" id="L1242">            };</span>
<span class="line" id="L1243">            <span class="tok-kw">suspend</span> {</span>
<span class="line" id="L1244">                self.posixFsRequest(&amp;req_node);</span>
<span class="line" id="L1245">            }</span>
<span class="line" id="L1246">            <span class="tok-kw">return</span> req_node.data.msg.writev.result;</span>
<span class="line" id="L1247">        } <span class="tok-kw">else</span> {</span>
<span class="line" id="L1248">            <span class="tok-kw">while</span> (<span class="tok-null">true</span>) {</span>
<span class="line" id="L1249">                <span class="tok-kw">return</span> os.writev(fd, iov) <span class="tok-kw">catch</span> |err| <span class="tok-kw">switch</span> (err) {</span>
<span class="line" id="L1250">                    <span class="tok-kw">error</span>.WouldBlock =&gt; {</span>
<span class="line" id="L1251">                        self.waitUntilFdWritable(fd);</span>
<span class="line" id="L1252">                        <span class="tok-kw">continue</span>;</span>
<span class="line" id="L1253">                    },</span>
<span class="line" id="L1254">                    <span class="tok-kw">else</span> =&gt; <span class="tok-kw">return</span> err,</span>
<span class="line" id="L1255">                };</span>
<span class="line" id="L1256">            }</span>
<span class="line" id="L1257">        }</span>
<span class="line" id="L1258">    }</span>
<span class="line" id="L1259"></span>
<span class="line" id="L1260">    <span class="tok-comment">/// Performs an async `os.pwrite` using a separate thread.</span></span>
<span class="line" id="L1261">    <span class="tok-comment">/// `fd` must block and not return EAGAIN.</span></span>
<span class="line" id="L1262">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">pwrite</span>(self: *Loop, fd: os.fd_t, bytes: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, offset: <span class="tok-type">u64</span>, simulate_evented: <span class="tok-type">bool</span>) os.PerformsWriteError!<span class="tok-type">usize</span> {</span>
<span class="line" id="L1263">        <span class="tok-kw">if</span> (simulate_evented) {</span>
<span class="line" id="L1264">            <span class="tok-kw">var</span> req_node = Request.Node{</span>
<span class="line" id="L1265">                .data = .{</span>
<span class="line" id="L1266">                    .msg = .{</span>
<span class="line" id="L1267">                        .pwrite = .{</span>
<span class="line" id="L1268">                            .fd = fd,</span>
<span class="line" id="L1269">                            .bytes = bytes,</span>
<span class="line" id="L1270">                            .offset = offset,</span>
<span class="line" id="L1271">                            .result = <span class="tok-null">undefined</span>,</span>
<span class="line" id="L1272">                        },</span>
<span class="line" id="L1273">                    },</span>
<span class="line" id="L1274">                    .finish = .{ .TickNode = .{ .data = <span class="tok-builtin">@frame</span>() } },</span>
<span class="line" id="L1275">                },</span>
<span class="line" id="L1276">            };</span>
<span class="line" id="L1277">            <span class="tok-kw">suspend</span> {</span>
<span class="line" id="L1278">                self.posixFsRequest(&amp;req_node);</span>
<span class="line" id="L1279">            }</span>
<span class="line" id="L1280">            <span class="tok-kw">return</span> req_node.data.msg.pwrite.result;</span>
<span class="line" id="L1281">        } <span class="tok-kw">else</span> {</span>
<span class="line" id="L1282">            <span class="tok-kw">while</span> (<span class="tok-null">true</span>) {</span>
<span class="line" id="L1283">                <span class="tok-kw">return</span> os.pwrite(fd, bytes, offset) <span class="tok-kw">catch</span> |err| <span class="tok-kw">switch</span> (err) {</span>
<span class="line" id="L1284">                    <span class="tok-kw">error</span>.WouldBlock =&gt; {</span>
<span class="line" id="L1285">                        self.waitUntilFdWritable(fd);</span>
<span class="line" id="L1286">                        <span class="tok-kw">continue</span>;</span>
<span class="line" id="L1287">                    },</span>
<span class="line" id="L1288">                    <span class="tok-kw">else</span> =&gt; <span class="tok-kw">return</span> err,</span>
<span class="line" id="L1289">                };</span>
<span class="line" id="L1290">            }</span>
<span class="line" id="L1291">        }</span>
<span class="line" id="L1292">    }</span>
<span class="line" id="L1293"></span>
<span class="line" id="L1294">    <span class="tok-comment">/// Performs an async `os.pwritev` using a separate thread.</span></span>
<span class="line" id="L1295">    <span class="tok-comment">/// `fd` must block and not return EAGAIN.</span></span>
<span class="line" id="L1296">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">pwritev</span>(self: *Loop, fd: os.fd_t, iov: []<span class="tok-kw">const</span> os.iovec_const, offset: <span class="tok-type">u64</span>, simulate_evented: <span class="tok-type">bool</span>) os.PWriteError!<span class="tok-type">usize</span> {</span>
<span class="line" id="L1297">        <span class="tok-kw">if</span> (simulate_evented) {</span>
<span class="line" id="L1298">            <span class="tok-kw">var</span> req_node = Request.Node{</span>
<span class="line" id="L1299">                .data = .{</span>
<span class="line" id="L1300">                    .msg = .{</span>
<span class="line" id="L1301">                        .pwritev = .{</span>
<span class="line" id="L1302">                            .fd = fd,</span>
<span class="line" id="L1303">                            .iov = iov,</span>
<span class="line" id="L1304">                            .offset = offset,</span>
<span class="line" id="L1305">                            .result = <span class="tok-null">undefined</span>,</span>
<span class="line" id="L1306">                        },</span>
<span class="line" id="L1307">                    },</span>
<span class="line" id="L1308">                    .finish = .{ .TickNode = .{ .data = <span class="tok-builtin">@frame</span>() } },</span>
<span class="line" id="L1309">                },</span>
<span class="line" id="L1310">            };</span>
<span class="line" id="L1311">            <span class="tok-kw">suspend</span> {</span>
<span class="line" id="L1312">                self.posixFsRequest(&amp;req_node);</span>
<span class="line" id="L1313">            }</span>
<span class="line" id="L1314">            <span class="tok-kw">return</span> req_node.data.msg.pwritev.result;</span>
<span class="line" id="L1315">        } <span class="tok-kw">else</span> {</span>
<span class="line" id="L1316">            <span class="tok-kw">while</span> (<span class="tok-null">true</span>) {</span>
<span class="line" id="L1317">                <span class="tok-kw">return</span> os.pwritev(fd, iov, offset) <span class="tok-kw">catch</span> |err| <span class="tok-kw">switch</span> (err) {</span>
<span class="line" id="L1318">                    <span class="tok-kw">error</span>.WouldBlock =&gt; {</span>
<span class="line" id="L1319">                        self.waitUntilFdWritable(fd);</span>
<span class="line" id="L1320">                        <span class="tok-kw">continue</span>;</span>
<span class="line" id="L1321">                    },</span>
<span class="line" id="L1322">                    <span class="tok-kw">else</span> =&gt; <span class="tok-kw">return</span> err,</span>
<span class="line" id="L1323">                };</span>
<span class="line" id="L1324">            }</span>
<span class="line" id="L1325">        }</span>
<span class="line" id="L1326">    }</span>
<span class="line" id="L1327"></span>
<span class="line" id="L1328">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">sendto</span>(</span>
<span class="line" id="L1329">        self: *Loop,</span>
<span class="line" id="L1330">        <span class="tok-comment">/// The file descriptor of the sending socket.</span></span>
<span class="line" id="L1331">        sockfd: os.fd_t,</span>
<span class="line" id="L1332">        <span class="tok-comment">/// Message to send.</span></span>
<span class="line" id="L1333">        buf: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L1334">        flags: <span class="tok-type">u32</span>,</span>
<span class="line" id="L1335">        dest_addr: ?*<span class="tok-kw">const</span> os.sockaddr,</span>
<span class="line" id="L1336">        addrlen: os.socklen_t,</span>
<span class="line" id="L1337">    ) os.SendToError!<span class="tok-type">usize</span> {</span>
<span class="line" id="L1338">        <span class="tok-kw">while</span> (<span class="tok-null">true</span>) {</span>
<span class="line" id="L1339">            <span class="tok-kw">return</span> os.sendto(sockfd, buf, flags, dest_addr, addrlen) <span class="tok-kw">catch</span> |err| <span class="tok-kw">switch</span> (err) {</span>
<span class="line" id="L1340">                <span class="tok-kw">error</span>.WouldBlock =&gt; {</span>
<span class="line" id="L1341">                    self.waitUntilFdWritable(sockfd);</span>
<span class="line" id="L1342">                    <span class="tok-kw">continue</span>;</span>
<span class="line" id="L1343">                },</span>
<span class="line" id="L1344">                <span class="tok-kw">else</span> =&gt; <span class="tok-kw">return</span> err,</span>
<span class="line" id="L1345">            };</span>
<span class="line" id="L1346">        }</span>
<span class="line" id="L1347">    }</span>
<span class="line" id="L1348"></span>
<span class="line" id="L1349">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">recvfrom</span>(</span>
<span class="line" id="L1350">        self: *Loop,</span>
<span class="line" id="L1351">        sockfd: os.fd_t,</span>
<span class="line" id="L1352">        buf: []<span class="tok-type">u8</span>,</span>
<span class="line" id="L1353">        flags: <span class="tok-type">u32</span>,</span>
<span class="line" id="L1354">        src_addr: ?*os.sockaddr,</span>
<span class="line" id="L1355">        addrlen: ?*os.socklen_t,</span>
<span class="line" id="L1356">    ) os.RecvFromError!<span class="tok-type">usize</span> {</span>
<span class="line" id="L1357">        <span class="tok-kw">while</span> (<span class="tok-null">true</span>) {</span>
<span class="line" id="L1358">            <span class="tok-kw">return</span> os.recvfrom(sockfd, buf, flags, src_addr, addrlen) <span class="tok-kw">catch</span> |err| <span class="tok-kw">switch</span> (err) {</span>
<span class="line" id="L1359">                <span class="tok-kw">error</span>.WouldBlock =&gt; {</span>
<span class="line" id="L1360">                    self.waitUntilFdReadable(sockfd);</span>
<span class="line" id="L1361">                    <span class="tok-kw">continue</span>;</span>
<span class="line" id="L1362">                },</span>
<span class="line" id="L1363">                <span class="tok-kw">else</span> =&gt; <span class="tok-kw">return</span> err,</span>
<span class="line" id="L1364">            };</span>
<span class="line" id="L1365">        }</span>
<span class="line" id="L1366">    }</span>
<span class="line" id="L1367"></span>
<span class="line" id="L1368">    <span class="tok-comment">/// Performs an async `os.faccessatZ` using a separate thread.</span></span>
<span class="line" id="L1369">    <span class="tok-comment">/// `fd` must block and not return EAGAIN.</span></span>
<span class="line" id="L1370">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">faccessatZ</span>(</span>
<span class="line" id="L1371">        self: *Loop,</span>
<span class="line" id="L1372">        dirfd: os.fd_t,</span>
<span class="line" id="L1373">        path_z: [*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L1374">        mode: <span class="tok-type">u32</span>,</span>
<span class="line" id="L1375">        flags: <span class="tok-type">u32</span>,</span>
<span class="line" id="L1376">    ) os.AccessError!<span class="tok-type">void</span> {</span>
<span class="line" id="L1377">        <span class="tok-kw">var</span> req_node = Request.Node{</span>
<span class="line" id="L1378">            .data = .{</span>
<span class="line" id="L1379">                .msg = .{</span>
<span class="line" id="L1380">                    .faccessat = .{</span>
<span class="line" id="L1381">                        .dirfd = dirfd,</span>
<span class="line" id="L1382">                        .path = path_z,</span>
<span class="line" id="L1383">                        .mode = mode,</span>
<span class="line" id="L1384">                        .flags = flags,</span>
<span class="line" id="L1385">                        .result = <span class="tok-null">undefined</span>,</span>
<span class="line" id="L1386">                    },</span>
<span class="line" id="L1387">                },</span>
<span class="line" id="L1388">                .finish = .{ .TickNode = .{ .data = <span class="tok-builtin">@frame</span>() } },</span>
<span class="line" id="L1389">            },</span>
<span class="line" id="L1390">        };</span>
<span class="line" id="L1391">        <span class="tok-kw">suspend</span> {</span>
<span class="line" id="L1392">            self.posixFsRequest(&amp;req_node);</span>
<span class="line" id="L1393">        }</span>
<span class="line" id="L1394">        <span class="tok-kw">return</span> req_node.data.msg.faccessat.result;</span>
<span class="line" id="L1395">    }</span>
<span class="line" id="L1396"></span>
<span class="line" id="L1397">    <span class="tok-kw">fn</span> <span class="tok-fn">workerRun</span>(self: *Loop) <span class="tok-type">void</span> {</span>
<span class="line" id="L1398">        <span class="tok-kw">while</span> (<span class="tok-null">true</span>) {</span>
<span class="line" id="L1399">            <span class="tok-kw">while</span> (<span class="tok-null">true</span>) {</span>
<span class="line" id="L1400">                <span class="tok-kw">const</span> next_tick_node = self.next_tick_queue.get() <span class="tok-kw">orelse</span> <span class="tok-kw">break</span>;</span>
<span class="line" id="L1401">                self.dispatch();</span>
<span class="line" id="L1402">                <span class="tok-kw">resume</span> next_tick_node.data;</span>
<span class="line" id="L1403">                self.finishOneEvent();</span>
<span class="line" id="L1404">            }</span>
<span class="line" id="L1405"></span>
<span class="line" id="L1406">            <span class="tok-kw">switch</span> (builtin.os.tag) {</span>
<span class="line" id="L1407">                .linux =&gt; {</span>
<span class="line" id="L1408">                    <span class="tok-comment">// only process 1 event so we don't steal from other threads</span>
</span>
<span class="line" id="L1409">                    <span class="tok-kw">var</span> events: [<span class="tok-number">1</span>]os.linux.epoll_event = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L1410">                    <span class="tok-kw">const</span> count = os.epoll_wait(self.os_data.epollfd, events[<span class="tok-number">0</span>..], -<span class="tok-number">1</span>);</span>
<span class="line" id="L1411">                    <span class="tok-kw">for</span> (events[<span class="tok-number">0</span>..count]) |ev| {</span>
<span class="line" id="L1412">                        <span class="tok-kw">const</span> resume_node = <span class="tok-builtin">@intToPtr</span>(*ResumeNode, ev.data.ptr);</span>
<span class="line" id="L1413">                        <span class="tok-kw">const</span> handle = resume_node.handle;</span>
<span class="line" id="L1414">                        <span class="tok-kw">const</span> resume_node_id = resume_node.id;</span>
<span class="line" id="L1415">                        <span class="tok-kw">switch</span> (resume_node_id) {</span>
<span class="line" id="L1416">                            .Basic =&gt; {},</span>
<span class="line" id="L1417">                            .Stop =&gt; <span class="tok-kw">return</span>,</span>
<span class="line" id="L1418">                            .EventFd =&gt; {</span>
<span class="line" id="L1419">                                <span class="tok-kw">const</span> event_fd_node = <span class="tok-builtin">@fieldParentPtr</span>(ResumeNode.EventFd, <span class="tok-str">&quot;base&quot;</span>, resume_node);</span>
<span class="line" id="L1420">                                event_fd_node.epoll_op = os.linux.EPOLL.CTL_MOD;</span>
<span class="line" id="L1421">                                <span class="tok-kw">const</span> stack_node = <span class="tok-builtin">@fieldParentPtr</span>(std.atomic.Stack(ResumeNode.EventFd).Node, <span class="tok-str">&quot;data&quot;</span>, event_fd_node);</span>
<span class="line" id="L1422">                                self.available_eventfd_resume_nodes.push(stack_node);</span>
<span class="line" id="L1423">                            },</span>
<span class="line" id="L1424">                        }</span>
<span class="line" id="L1425">                        <span class="tok-kw">resume</span> handle;</span>
<span class="line" id="L1426">                        <span class="tok-kw">if</span> (resume_node_id == ResumeNode.Id.EventFd) {</span>
<span class="line" id="L1427">                            self.finishOneEvent();</span>
<span class="line" id="L1428">                        }</span>
<span class="line" id="L1429">                    }</span>
<span class="line" id="L1430">                },</span>
<span class="line" id="L1431">                .macos, .freebsd, .netbsd, .dragonfly, .openbsd =&gt; {</span>
<span class="line" id="L1432">                    <span class="tok-kw">var</span> eventlist: [<span class="tok-number">1</span>]os.Kevent = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L1433">                    <span class="tok-kw">const</span> empty_kevs = &amp;[<span class="tok-number">0</span>]os.Kevent{};</span>
<span class="line" id="L1434">                    <span class="tok-kw">const</span> count = os.kevent(self.os_data.kqfd, empty_kevs, eventlist[<span class="tok-number">0</span>..], <span class="tok-null">null</span>) <span class="tok-kw">catch</span> <span class="tok-kw">unreachable</span>;</span>
<span class="line" id="L1435">                    <span class="tok-kw">for</span> (eventlist[<span class="tok-number">0</span>..count]) |ev| {</span>
<span class="line" id="L1436">                        <span class="tok-kw">const</span> resume_node = <span class="tok-builtin">@intToPtr</span>(*ResumeNode, ev.udata);</span>
<span class="line" id="L1437">                        <span class="tok-kw">const</span> handle = resume_node.handle;</span>
<span class="line" id="L1438">                        <span class="tok-kw">const</span> resume_node_id = resume_node.id;</span>
<span class="line" id="L1439">                        <span class="tok-kw">switch</span> (resume_node_id) {</span>
<span class="line" id="L1440">                            .Basic =&gt; {</span>
<span class="line" id="L1441">                                <span class="tok-kw">const</span> basic_node = <span class="tok-builtin">@fieldParentPtr</span>(ResumeNode.Basic, <span class="tok-str">&quot;base&quot;</span>, resume_node);</span>
<span class="line" id="L1442">                                basic_node.kev = ev;</span>
<span class="line" id="L1443">                            },</span>
<span class="line" id="L1444">                            .Stop =&gt; <span class="tok-kw">return</span>,</span>
<span class="line" id="L1445">                            .EventFd =&gt; {</span>
<span class="line" id="L1446">                                <span class="tok-kw">const</span> event_fd_node = <span class="tok-builtin">@fieldParentPtr</span>(ResumeNode.EventFd, <span class="tok-str">&quot;base&quot;</span>, resume_node);</span>
<span class="line" id="L1447">                                <span class="tok-kw">const</span> stack_node = <span class="tok-builtin">@fieldParentPtr</span>(std.atomic.Stack(ResumeNode.EventFd).Node, <span class="tok-str">&quot;data&quot;</span>, event_fd_node);</span>
<span class="line" id="L1448">                                self.available_eventfd_resume_nodes.push(stack_node);</span>
<span class="line" id="L1449">                            },</span>
<span class="line" id="L1450">                        }</span>
<span class="line" id="L1451">                        <span class="tok-kw">resume</span> handle;</span>
<span class="line" id="L1452">                        <span class="tok-kw">if</span> (resume_node_id == ResumeNode.Id.EventFd) {</span>
<span class="line" id="L1453">                            self.finishOneEvent();</span>
<span class="line" id="L1454">                        }</span>
<span class="line" id="L1455">                    }</span>
<span class="line" id="L1456">                },</span>
<span class="line" id="L1457">                .windows =&gt; {</span>
<span class="line" id="L1458">                    <span class="tok-kw">var</span> completion_key: <span class="tok-type">usize</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L1459">                    <span class="tok-kw">const</span> overlapped = <span class="tok-kw">while</span> (<span class="tok-null">true</span>) {</span>
<span class="line" id="L1460">                        <span class="tok-kw">var</span> nbytes: windows.DWORD = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L1461">                        <span class="tok-kw">var</span> overlapped: ?*windows.OVERLAPPED = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L1462">                        <span class="tok-kw">switch</span> (windows.GetQueuedCompletionStatus(self.os_data.io_port, &amp;nbytes, &amp;completion_key, &amp;overlapped, windows.INFINITE)) {</span>
<span class="line" id="L1463">                            .Aborted =&gt; <span class="tok-kw">return</span>,</span>
<span class="line" id="L1464">                            .Normal =&gt; {},</span>
<span class="line" id="L1465">                            .EOF =&gt; {},</span>
<span class="line" id="L1466">                            .Cancelled =&gt; <span class="tok-kw">continue</span>,</span>
<span class="line" id="L1467">                        }</span>
<span class="line" id="L1468">                        <span class="tok-kw">if</span> (overlapped) |o| <span class="tok-kw">break</span> o;</span>
<span class="line" id="L1469">                    } <span class="tok-kw">else</span> <span class="tok-kw">unreachable</span>; <span class="tok-comment">// TODO else unreachable should not be necessary</span>
</span>
<span class="line" id="L1470">                    <span class="tok-kw">const</span> resume_node = <span class="tok-builtin">@fieldParentPtr</span>(ResumeNode, <span class="tok-str">&quot;overlapped&quot;</span>, overlapped);</span>
<span class="line" id="L1471">                    <span class="tok-kw">const</span> handle = resume_node.handle;</span>
<span class="line" id="L1472">                    <span class="tok-kw">const</span> resume_node_id = resume_node.id;</span>
<span class="line" id="L1473">                    <span class="tok-kw">switch</span> (resume_node_id) {</span>
<span class="line" id="L1474">                        .Basic =&gt; {},</span>
<span class="line" id="L1475">                        .Stop =&gt; <span class="tok-kw">return</span>,</span>
<span class="line" id="L1476">                        .EventFd =&gt; {</span>
<span class="line" id="L1477">                            <span class="tok-kw">const</span> event_fd_node = <span class="tok-builtin">@fieldParentPtr</span>(ResumeNode.EventFd, <span class="tok-str">&quot;base&quot;</span>, resume_node);</span>
<span class="line" id="L1478">                            <span class="tok-kw">const</span> stack_node = <span class="tok-builtin">@fieldParentPtr</span>(std.atomic.Stack(ResumeNode.EventFd).Node, <span class="tok-str">&quot;data&quot;</span>, event_fd_node);</span>
<span class="line" id="L1479">                            self.available_eventfd_resume_nodes.push(stack_node);</span>
<span class="line" id="L1480">                        },</span>
<span class="line" id="L1481">                    }</span>
<span class="line" id="L1482">                    <span class="tok-kw">resume</span> handle;</span>
<span class="line" id="L1483">                    self.finishOneEvent();</span>
<span class="line" id="L1484">                },</span>
<span class="line" id="L1485">                <span class="tok-kw">else</span> =&gt; <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;unsupported OS&quot;</span>),</span>
<span class="line" id="L1486">            }</span>
<span class="line" id="L1487">        }</span>
<span class="line" id="L1488">    }</span>
<span class="line" id="L1489"></span>
<span class="line" id="L1490">    <span class="tok-kw">fn</span> <span class="tok-fn">posixFsRequest</span>(self: *Loop, request_node: *Request.Node) <span class="tok-type">void</span> {</span>
<span class="line" id="L1491">        self.beginOneEvent(); <span class="tok-comment">// finished in posixFsRun after processing the msg</span>
</span>
<span class="line" id="L1492">        self.fs_queue.put(request_node);</span>
<span class="line" id="L1493">        self.fs_thread_wakeup.set();</span>
<span class="line" id="L1494">    }</span>
<span class="line" id="L1495"></span>
<span class="line" id="L1496">    <span class="tok-kw">fn</span> <span class="tok-fn">posixFsCancel</span>(self: *Loop, request_node: *Request.Node) <span class="tok-type">void</span> {</span>
<span class="line" id="L1497">        <span class="tok-kw">if</span> (self.fs_queue.remove(request_node)) {</span>
<span class="line" id="L1498">            self.finishOneEvent();</span>
<span class="line" id="L1499">        }</span>
<span class="line" id="L1500">    }</span>
<span class="line" id="L1501"></span>
<span class="line" id="L1502">    <span class="tok-kw">fn</span> <span class="tok-fn">posixFsRun</span>(self: *Loop) <span class="tok-type">void</span> {</span>
<span class="line" id="L1503">        <span class="tok-kw">nosuspend</span> <span class="tok-kw">while</span> (<span class="tok-null">true</span>) {</span>
<span class="line" id="L1504">            self.fs_thread_wakeup.reset();</span>
<span class="line" id="L1505">            <span class="tok-kw">while</span> (self.fs_queue.get()) |node| {</span>
<span class="line" id="L1506">                <span class="tok-kw">switch</span> (node.data.msg) {</span>
<span class="line" id="L1507">                    .end =&gt; <span class="tok-kw">return</span>,</span>
<span class="line" id="L1508">                    .read =&gt; |*msg| {</span>
<span class="line" id="L1509">                        msg.result = os.read(msg.fd, msg.buf);</span>
<span class="line" id="L1510">                    },</span>
<span class="line" id="L1511">                    .readv =&gt; |*msg| {</span>
<span class="line" id="L1512">                        msg.result = os.readv(msg.fd, msg.iov);</span>
<span class="line" id="L1513">                    },</span>
<span class="line" id="L1514">                    .write =&gt; |*msg| {</span>
<span class="line" id="L1515">                        msg.result = os.write(msg.fd, msg.bytes);</span>
<span class="line" id="L1516">                    },</span>
<span class="line" id="L1517">                    .writev =&gt; |*msg| {</span>
<span class="line" id="L1518">                        msg.result = os.writev(msg.fd, msg.iov);</span>
<span class="line" id="L1519">                    },</span>
<span class="line" id="L1520">                    .pwrite =&gt; |*msg| {</span>
<span class="line" id="L1521">                        msg.result = os.pwrite(msg.fd, msg.bytes, msg.offset);</span>
<span class="line" id="L1522">                    },</span>
<span class="line" id="L1523">                    .pwritev =&gt; |*msg| {</span>
<span class="line" id="L1524">                        msg.result = os.pwritev(msg.fd, msg.iov, msg.offset);</span>
<span class="line" id="L1525">                    },</span>
<span class="line" id="L1526">                    .pread =&gt; |*msg| {</span>
<span class="line" id="L1527">                        msg.result = os.pread(msg.fd, msg.buf, msg.offset);</span>
<span class="line" id="L1528">                    },</span>
<span class="line" id="L1529">                    .preadv =&gt; |*msg| {</span>
<span class="line" id="L1530">                        msg.result = os.preadv(msg.fd, msg.iov, msg.offset);</span>
<span class="line" id="L1531">                    },</span>
<span class="line" id="L1532">                    .open =&gt; |*msg| {</span>
<span class="line" id="L1533">                        <span class="tok-kw">if</span> (is_windows) <span class="tok-kw">unreachable</span>; <span class="tok-comment">// TODO</span>
</span>
<span class="line" id="L1534">                        msg.result = os.openZ(msg.path, msg.flags, msg.mode);</span>
<span class="line" id="L1535">                    },</span>
<span class="line" id="L1536">                    .openat =&gt; |*msg| {</span>
<span class="line" id="L1537">                        <span class="tok-kw">if</span> (is_windows) <span class="tok-kw">unreachable</span>; <span class="tok-comment">// TODO</span>
</span>
<span class="line" id="L1538">                        msg.result = os.openatZ(msg.fd, msg.path, msg.flags, msg.mode);</span>
<span class="line" id="L1539">                    },</span>
<span class="line" id="L1540">                    .faccessat =&gt; |*msg| {</span>
<span class="line" id="L1541">                        msg.result = os.faccessatZ(msg.dirfd, msg.path, msg.mode, msg.flags);</span>
<span class="line" id="L1542">                    },</span>
<span class="line" id="L1543">                    .close =&gt; |*msg| os.close(msg.fd),</span>
<span class="line" id="L1544">                }</span>
<span class="line" id="L1545">                <span class="tok-kw">switch</span> (node.data.finish) {</span>
<span class="line" id="L1546">                    .TickNode =&gt; |*tick_node| self.onNextTick(tick_node),</span>
<span class="line" id="L1547">                    .NoAction =&gt; {},</span>
<span class="line" id="L1548">                }</span>
<span class="line" id="L1549">                self.finishOneEvent();</span>
<span class="line" id="L1550">            }</span>
<span class="line" id="L1551">            self.fs_thread_wakeup.wait();</span>
<span class="line" id="L1552">        };</span>
<span class="line" id="L1553">    }</span>
<span class="line" id="L1554"></span>
<span class="line" id="L1555">    <span class="tok-kw">const</span> OsData = <span class="tok-kw">switch</span> (builtin.os.tag) {</span>
<span class="line" id="L1556">        .linux =&gt; LinuxOsData,</span>
<span class="line" id="L1557">        .macos, .freebsd, .netbsd, .dragonfly, .openbsd =&gt; KEventData,</span>
<span class="line" id="L1558">        .windows =&gt; <span class="tok-kw">struct</span> {</span>
<span class="line" id="L1559">            io_port: windows.HANDLE,</span>
<span class="line" id="L1560">            extra_thread_count: <span class="tok-type">usize</span>,</span>
<span class="line" id="L1561">        },</span>
<span class="line" id="L1562">        <span class="tok-kw">else</span> =&gt; <span class="tok-kw">struct</span> {},</span>
<span class="line" id="L1563">    };</span>
<span class="line" id="L1564"></span>
<span class="line" id="L1565">    <span class="tok-kw">const</span> KEventData = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L1566">        kqfd: <span class="tok-type">i32</span>,</span>
<span class="line" id="L1567">        final_kevent: os.Kevent,</span>
<span class="line" id="L1568">    };</span>
<span class="line" id="L1569"></span>
<span class="line" id="L1570">    <span class="tok-kw">const</span> LinuxOsData = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L1571">        epollfd: <span class="tok-type">i32</span>,</span>
<span class="line" id="L1572">        final_eventfd: <span class="tok-type">i32</span>,</span>
<span class="line" id="L1573">        final_eventfd_event: os.linux.epoll_event,</span>
<span class="line" id="L1574">    };</span>
<span class="line" id="L1575"></span>
<span class="line" id="L1576">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> Request = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L1577">        msg: Msg,</span>
<span class="line" id="L1578">        finish: Finish,</span>
<span class="line" id="L1579"></span>
<span class="line" id="L1580">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> Node = std.atomic.Queue(Request).Node;</span>
<span class="line" id="L1581"></span>
<span class="line" id="L1582">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> Finish = <span class="tok-kw">union</span>(<span class="tok-kw">enum</span>) {</span>
<span class="line" id="L1583">            TickNode: Loop.NextTickNode,</span>
<span class="line" id="L1584">            NoAction,</span>
<span class="line" id="L1585">        };</span>
<span class="line" id="L1586"></span>
<span class="line" id="L1587">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> Msg = <span class="tok-kw">union</span>(<span class="tok-kw">enum</span>) {</span>
<span class="line" id="L1588">            read: Read,</span>
<span class="line" id="L1589">            readv: ReadV,</span>
<span class="line" id="L1590">            write: Write,</span>
<span class="line" id="L1591">            writev: WriteV,</span>
<span class="line" id="L1592">            pwrite: PWrite,</span>
<span class="line" id="L1593">            pwritev: PWriteV,</span>
<span class="line" id="L1594">            pread: PRead,</span>
<span class="line" id="L1595">            preadv: PReadV,</span>
<span class="line" id="L1596">            open: Open,</span>
<span class="line" id="L1597">            openat: OpenAt,</span>
<span class="line" id="L1598">            close: Close,</span>
<span class="line" id="L1599">            faccessat: FAccessAt,</span>
<span class="line" id="L1600"></span>
<span class="line" id="L1601">            <span class="tok-comment">/// special - means the fs thread should exit</span></span>
<span class="line" id="L1602">            end,</span>
<span class="line" id="L1603"></span>
<span class="line" id="L1604">            <span class="tok-kw">pub</span> <span class="tok-kw">const</span> Read = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L1605">                fd: os.fd_t,</span>
<span class="line" id="L1606">                buf: []<span class="tok-type">u8</span>,</span>
<span class="line" id="L1607">                result: Error!<span class="tok-type">usize</span>,</span>
<span class="line" id="L1608"></span>
<span class="line" id="L1609">                <span class="tok-kw">pub</span> <span class="tok-kw">const</span> Error = os.ReadError;</span>
<span class="line" id="L1610">            };</span>
<span class="line" id="L1611"></span>
<span class="line" id="L1612">            <span class="tok-kw">pub</span> <span class="tok-kw">const</span> ReadV = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L1613">                fd: os.fd_t,</span>
<span class="line" id="L1614">                iov: []<span class="tok-kw">const</span> os.iovec,</span>
<span class="line" id="L1615">                result: Error!<span class="tok-type">usize</span>,</span>
<span class="line" id="L1616"></span>
<span class="line" id="L1617">                <span class="tok-kw">pub</span> <span class="tok-kw">const</span> Error = os.ReadError;</span>
<span class="line" id="L1618">            };</span>
<span class="line" id="L1619"></span>
<span class="line" id="L1620">            <span class="tok-kw">pub</span> <span class="tok-kw">const</span> Write = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L1621">                fd: os.fd_t,</span>
<span class="line" id="L1622">                bytes: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L1623">                result: Error!<span class="tok-type">usize</span>,</span>
<span class="line" id="L1624"></span>
<span class="line" id="L1625">                <span class="tok-kw">pub</span> <span class="tok-kw">const</span> Error = os.WriteError;</span>
<span class="line" id="L1626">            };</span>
<span class="line" id="L1627"></span>
<span class="line" id="L1628">            <span class="tok-kw">pub</span> <span class="tok-kw">const</span> WriteV = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L1629">                fd: os.fd_t,</span>
<span class="line" id="L1630">                iov: []<span class="tok-kw">const</span> os.iovec_const,</span>
<span class="line" id="L1631">                result: Error!<span class="tok-type">usize</span>,</span>
<span class="line" id="L1632"></span>
<span class="line" id="L1633">                <span class="tok-kw">pub</span> <span class="tok-kw">const</span> Error = os.WriteError;</span>
<span class="line" id="L1634">            };</span>
<span class="line" id="L1635"></span>
<span class="line" id="L1636">            <span class="tok-kw">pub</span> <span class="tok-kw">const</span> PWrite = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L1637">                fd: os.fd_t,</span>
<span class="line" id="L1638">                bytes: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L1639">                offset: <span class="tok-type">usize</span>,</span>
<span class="line" id="L1640">                result: Error!<span class="tok-type">usize</span>,</span>
<span class="line" id="L1641"></span>
<span class="line" id="L1642">                <span class="tok-kw">pub</span> <span class="tok-kw">const</span> Error = os.PWriteError;</span>
<span class="line" id="L1643">            };</span>
<span class="line" id="L1644"></span>
<span class="line" id="L1645">            <span class="tok-kw">pub</span> <span class="tok-kw">const</span> PWriteV = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L1646">                fd: os.fd_t,</span>
<span class="line" id="L1647">                iov: []<span class="tok-kw">const</span> os.iovec_const,</span>
<span class="line" id="L1648">                offset: <span class="tok-type">usize</span>,</span>
<span class="line" id="L1649">                result: Error!<span class="tok-type">usize</span>,</span>
<span class="line" id="L1650"></span>
<span class="line" id="L1651">                <span class="tok-kw">pub</span> <span class="tok-kw">const</span> Error = os.PWriteError;</span>
<span class="line" id="L1652">            };</span>
<span class="line" id="L1653"></span>
<span class="line" id="L1654">            <span class="tok-kw">pub</span> <span class="tok-kw">const</span> PRead = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L1655">                fd: os.fd_t,</span>
<span class="line" id="L1656">                buf: []<span class="tok-type">u8</span>,</span>
<span class="line" id="L1657">                offset: <span class="tok-type">usize</span>,</span>
<span class="line" id="L1658">                result: Error!<span class="tok-type">usize</span>,</span>
<span class="line" id="L1659"></span>
<span class="line" id="L1660">                <span class="tok-kw">pub</span> <span class="tok-kw">const</span> Error = os.PReadError;</span>
<span class="line" id="L1661">            };</span>
<span class="line" id="L1662"></span>
<span class="line" id="L1663">            <span class="tok-kw">pub</span> <span class="tok-kw">const</span> PReadV = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L1664">                fd: os.fd_t,</span>
<span class="line" id="L1665">                iov: []<span class="tok-kw">const</span> os.iovec,</span>
<span class="line" id="L1666">                offset: <span class="tok-type">usize</span>,</span>
<span class="line" id="L1667">                result: Error!<span class="tok-type">usize</span>,</span>
<span class="line" id="L1668"></span>
<span class="line" id="L1669">                <span class="tok-kw">pub</span> <span class="tok-kw">const</span> Error = os.PReadError;</span>
<span class="line" id="L1670">            };</span>
<span class="line" id="L1671"></span>
<span class="line" id="L1672">            <span class="tok-kw">pub</span> <span class="tok-kw">const</span> Open = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L1673">                path: [*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L1674">                flags: <span class="tok-type">u32</span>,</span>
<span class="line" id="L1675">                mode: os.mode_t,</span>
<span class="line" id="L1676">                result: Error!os.fd_t,</span>
<span class="line" id="L1677"></span>
<span class="line" id="L1678">                <span class="tok-kw">pub</span> <span class="tok-kw">const</span> Error = os.OpenError;</span>
<span class="line" id="L1679">            };</span>
<span class="line" id="L1680"></span>
<span class="line" id="L1681">            <span class="tok-kw">pub</span> <span class="tok-kw">const</span> OpenAt = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L1682">                fd: os.fd_t,</span>
<span class="line" id="L1683">                path: [*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L1684">                flags: <span class="tok-type">u32</span>,</span>
<span class="line" id="L1685">                mode: os.mode_t,</span>
<span class="line" id="L1686">                result: Error!os.fd_t,</span>
<span class="line" id="L1687"></span>
<span class="line" id="L1688">                <span class="tok-kw">pub</span> <span class="tok-kw">const</span> Error = os.OpenError;</span>
<span class="line" id="L1689">            };</span>
<span class="line" id="L1690"></span>
<span class="line" id="L1691">            <span class="tok-kw">pub</span> <span class="tok-kw">const</span> Close = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L1692">                fd: os.fd_t,</span>
<span class="line" id="L1693">            };</span>
<span class="line" id="L1694"></span>
<span class="line" id="L1695">            <span class="tok-kw">pub</span> <span class="tok-kw">const</span> FAccessAt = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L1696">                dirfd: os.fd_t,</span>
<span class="line" id="L1697">                path: [*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L1698">                mode: <span class="tok-type">u32</span>,</span>
<span class="line" id="L1699">                flags: <span class="tok-type">u32</span>,</span>
<span class="line" id="L1700">                result: Error!<span class="tok-type">void</span>,</span>
<span class="line" id="L1701"></span>
<span class="line" id="L1702">                <span class="tok-kw">pub</span> <span class="tok-kw">const</span> Error = os.AccessError;</span>
<span class="line" id="L1703">            };</span>
<span class="line" id="L1704">        };</span>
<span class="line" id="L1705">    };</span>
<span class="line" id="L1706">};</span>
<span class="line" id="L1707"></span>
<span class="line" id="L1708"><span class="tok-kw">test</span> <span class="tok-str">&quot;std.event.Loop - basic&quot;</span> {</span>
<span class="line" id="L1709">    <span class="tok-comment">// https://github.com/ziglang/zig/issues/1908</span>
</span>
<span class="line" id="L1710">    <span class="tok-kw">if</span> (builtin.single_threaded) <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SkipZigTest;</span>
<span class="line" id="L1711"></span>
<span class="line" id="L1712">    <span class="tok-kw">if</span> (<span class="tok-null">true</span>) {</span>
<span class="line" id="L1713">        <span class="tok-comment">// https://github.com/ziglang/zig/issues/4922</span>
</span>
<span class="line" id="L1714">        <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SkipZigTest;</span>
<span class="line" id="L1715">    }</span>
<span class="line" id="L1716"></span>
<span class="line" id="L1717">    <span class="tok-kw">var</span> loop: Loop = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L1718">    <span class="tok-kw">try</span> loop.initMultiThreaded();</span>
<span class="line" id="L1719">    <span class="tok-kw">defer</span> loop.deinit();</span>
<span class="line" id="L1720"></span>
<span class="line" id="L1721">    loop.run();</span>
<span class="line" id="L1722">}</span>
<span class="line" id="L1723"></span>
<span class="line" id="L1724"><span class="tok-kw">fn</span> <span class="tok-fn">testEventLoop</span>() <span class="tok-type">i32</span> {</span>
<span class="line" id="L1725">    <span class="tok-kw">return</span> <span class="tok-number">1234</span>;</span>
<span class="line" id="L1726">}</span>
<span class="line" id="L1727"></span>
<span class="line" id="L1728"><span class="tok-kw">fn</span> <span class="tok-fn">testEventLoop2</span>(h: <span class="tok-kw">anyframe</span>-&gt;<span class="tok-type">i32</span>, did_it: *<span class="tok-type">bool</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L1729">    <span class="tok-kw">const</span> value = <span class="tok-kw">await</span> h;</span>
<span class="line" id="L1730">    <span class="tok-kw">try</span> testing.expect(value == <span class="tok-number">1234</span>);</span>
<span class="line" id="L1731">    did_it.* = <span class="tok-null">true</span>;</span>
<span class="line" id="L1732">}</span>
<span class="line" id="L1733"></span>
<span class="line" id="L1734"><span class="tok-kw">var</span> testRunDetachedData: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L1735"><span class="tok-kw">test</span> <span class="tok-str">&quot;std.event.Loop - runDetached&quot;</span> {</span>
<span class="line" id="L1736">    <span class="tok-comment">// https://github.com/ziglang/zig/issues/1908</span>
</span>
<span class="line" id="L1737">    <span class="tok-kw">if</span> (builtin.single_threaded) <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SkipZigTest;</span>
<span class="line" id="L1738">    <span class="tok-kw">if</span> (!std.io.is_async) <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SkipZigTest;</span>
<span class="line" id="L1739">    <span class="tok-kw">if</span> (<span class="tok-null">true</span>) {</span>
<span class="line" id="L1740">        <span class="tok-comment">// https://github.com/ziglang/zig/issues/4922</span>
</span>
<span class="line" id="L1741">        <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SkipZigTest;</span>
<span class="line" id="L1742">    }</span>
<span class="line" id="L1743"></span>
<span class="line" id="L1744">    <span class="tok-kw">var</span> loop: Loop = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L1745">    <span class="tok-kw">try</span> loop.initMultiThreaded();</span>
<span class="line" id="L1746">    <span class="tok-kw">defer</span> loop.deinit();</span>
<span class="line" id="L1747"></span>
<span class="line" id="L1748">    <span class="tok-comment">// Schedule the execution, won't actually start until we start the</span>
</span>
<span class="line" id="L1749">    <span class="tok-comment">// event loop.</span>
</span>
<span class="line" id="L1750">    <span class="tok-kw">try</span> loop.runDetached(std.testing.allocator, testRunDetached, .{});</span>
<span class="line" id="L1751"></span>
<span class="line" id="L1752">    <span class="tok-comment">// Now we can start the event loop. The function will return only</span>
</span>
<span class="line" id="L1753">    <span class="tok-comment">// after all tasks have been completed, allowing us to synchonize</span>
</span>
<span class="line" id="L1754">    <span class="tok-comment">// with the previous runDetached.</span>
</span>
<span class="line" id="L1755">    loop.run();</span>
<span class="line" id="L1756"></span>
<span class="line" id="L1757">    <span class="tok-kw">try</span> testing.expect(testRunDetachedData == <span class="tok-number">1</span>);</span>
<span class="line" id="L1758">}</span>
<span class="line" id="L1759"></span>
<span class="line" id="L1760"><span class="tok-kw">fn</span> <span class="tok-fn">testRunDetached</span>() <span class="tok-type">void</span> {</span>
<span class="line" id="L1761">    testRunDetachedData += <span class="tok-number">1</span>;</span>
<span class="line" id="L1762">}</span>
<span class="line" id="L1763"></span>
<span class="line" id="L1764"><span class="tok-kw">test</span> <span class="tok-str">&quot;std.event.Loop - sleep&quot;</span> {</span>
<span class="line" id="L1765">    <span class="tok-comment">// https://github.com/ziglang/zig/issues/1908</span>
</span>
<span class="line" id="L1766">    <span class="tok-kw">if</span> (builtin.single_threaded) <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SkipZigTest;</span>
<span class="line" id="L1767">    <span class="tok-kw">if</span> (!std.io.is_async) <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SkipZigTest;</span>
<span class="line" id="L1768"></span>
<span class="line" id="L1769">    <span class="tok-kw">const</span> frames = <span class="tok-kw">try</span> testing.allocator.alloc(<span class="tok-builtin">@Frame</span>(testSleep), <span class="tok-number">10</span>);</span>
<span class="line" id="L1770">    <span class="tok-kw">defer</span> testing.allocator.free(frames);</span>
<span class="line" id="L1771"></span>
<span class="line" id="L1772">    <span class="tok-kw">const</span> wait_time = <span class="tok-number">100</span> * std.time.ns_per_ms;</span>
<span class="line" id="L1773">    <span class="tok-kw">var</span> sleep_count: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L1774"></span>
<span class="line" id="L1775">    <span class="tok-kw">for</span> (frames) |*frame|</span>
<span class="line" id="L1776">        frame.* = <span class="tok-kw">async</span> testSleep(wait_time, &amp;sleep_count);</span>
<span class="line" id="L1777">    <span class="tok-kw">for</span> (frames) |*frame|</span>
<span class="line" id="L1778">        <span class="tok-kw">await</span> frame;</span>
<span class="line" id="L1779"></span>
<span class="line" id="L1780">    <span class="tok-kw">try</span> testing.expect(sleep_count == frames.len);</span>
<span class="line" id="L1781">}</span>
<span class="line" id="L1782"></span>
<span class="line" id="L1783"><span class="tok-kw">fn</span> <span class="tok-fn">testSleep</span>(wait_ns: <span class="tok-type">u64</span>, sleep_count: *<span class="tok-type">usize</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L1784">    Loop.instance.?.sleep(wait_ns);</span>
<span class="line" id="L1785">    _ = <span class="tok-builtin">@atomicRmw</span>(<span class="tok-type">usize</span>, sleep_count, .Add, <span class="tok-number">1</span>, .SeqCst);</span>
<span class="line" id="L1786">}</span>
<span class="line" id="L1787"></span>
</code></pre></body>
</html>