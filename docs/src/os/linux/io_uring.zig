<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">    <title>os/linux/io_uring.zig - source view</title>
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
<span class="line" id="L2"><span class="tok-kw">const</span> builtin = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;builtin&quot;</span>);</span>
<span class="line" id="L3"><span class="tok-kw">const</span> assert = std.debug.assert;</span>
<span class="line" id="L4"><span class="tok-kw">const</span> mem = std.mem;</span>
<span class="line" id="L5"><span class="tok-kw">const</span> net = std.net;</span>
<span class="line" id="L6"><span class="tok-kw">const</span> os = std.os;</span>
<span class="line" id="L7"><span class="tok-kw">const</span> linux = os.linux;</span>
<span class="line" id="L8"><span class="tok-kw">const</span> testing = std.testing;</span>
<span class="line" id="L9"></span>
<span class="line" id="L10"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IO_Uring = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L11">    fd: os.fd_t = -<span class="tok-number">1</span>,</span>
<span class="line" id="L12">    sq: SubmissionQueue,</span>
<span class="line" id="L13">    cq: CompletionQueue,</span>
<span class="line" id="L14">    flags: <span class="tok-type">u32</span>,</span>
<span class="line" id="L15">    features: <span class="tok-type">u32</span>,</span>
<span class="line" id="L16"></span>
<span class="line" id="L17">    <span class="tok-comment">/// A friendly way to setup an io_uring, with default linux.io_uring_params.</span></span>
<span class="line" id="L18">    <span class="tok-comment">/// `entries` must be a power of two between 1 and 4096, although the kernel will make the final</span></span>
<span class="line" id="L19">    <span class="tok-comment">/// call on how many entries the submission and completion queues will ultimately have,</span></span>
<span class="line" id="L20">    <span class="tok-comment">/// see https://github.com/torvalds/linux/blob/v5.8/fs/io_uring.c#L8027-L8050.</span></span>
<span class="line" id="L21">    <span class="tok-comment">/// Matches the interface of io_uring_queue_init() in liburing.</span></span>
<span class="line" id="L22">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">init</span>(entries: <span class="tok-type">u13</span>, flags: <span class="tok-type">u32</span>) !IO_Uring {</span>
<span class="line" id="L23">        <span class="tok-kw">var</span> params = mem.zeroInit(linux.io_uring_params, .{</span>
<span class="line" id="L24">            .flags = flags,</span>
<span class="line" id="L25">            .sq_thread_idle = <span class="tok-number">1000</span>,</span>
<span class="line" id="L26">        });</span>
<span class="line" id="L27">        <span class="tok-kw">return</span> <span class="tok-kw">try</span> IO_Uring.init_params(entries, &amp;params);</span>
<span class="line" id="L28">    }</span>
<span class="line" id="L29"></span>
<span class="line" id="L30">    <span class="tok-comment">/// A powerful way to setup an io_uring, if you want to tweak linux.io_uring_params such as submission</span></span>
<span class="line" id="L31">    <span class="tok-comment">/// queue thread cpu affinity or thread idle timeout (the kernel and our default is 1 second).</span></span>
<span class="line" id="L32">    <span class="tok-comment">/// `params` is passed by reference because the kernel needs to modify the parameters.</span></span>
<span class="line" id="L33">    <span class="tok-comment">/// Matches the interface of io_uring_queue_init_params() in liburing.</span></span>
<span class="line" id="L34">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">init_params</span>(entries: <span class="tok-type">u13</span>, p: *linux.io_uring_params) !IO_Uring {</span>
<span class="line" id="L35">        <span class="tok-kw">if</span> (entries == <span class="tok-number">0</span>) <span class="tok-kw">return</span> <span class="tok-kw">error</span>.EntriesZero;</span>
<span class="line" id="L36">        <span class="tok-kw">if</span> (!std.math.isPowerOfTwo(entries)) <span class="tok-kw">return</span> <span class="tok-kw">error</span>.EntriesNotPowerOfTwo;</span>
<span class="line" id="L37"></span>
<span class="line" id="L38">        assert(p.sq_entries == <span class="tok-number">0</span>);</span>
<span class="line" id="L39">        assert(p.cq_entries == <span class="tok-number">0</span> <span class="tok-kw">or</span> p.flags &amp; linux.IORING_SETUP_CQSIZE != <span class="tok-number">0</span>);</span>
<span class="line" id="L40">        assert(p.features == <span class="tok-number">0</span>);</span>
<span class="line" id="L41">        assert(p.wq_fd == <span class="tok-number">0</span> <span class="tok-kw">or</span> p.flags &amp; linux.IORING_SETUP_ATTACH_WQ != <span class="tok-number">0</span>);</span>
<span class="line" id="L42">        assert(p.resv[<span class="tok-number">0</span>] == <span class="tok-number">0</span>);</span>
<span class="line" id="L43">        assert(p.resv[<span class="tok-number">1</span>] == <span class="tok-number">0</span>);</span>
<span class="line" id="L44">        assert(p.resv[<span class="tok-number">2</span>] == <span class="tok-number">0</span>);</span>
<span class="line" id="L45"></span>
<span class="line" id="L46">        <span class="tok-kw">const</span> res = linux.io_uring_setup(entries, p);</span>
<span class="line" id="L47">        <span class="tok-kw">switch</span> (linux.getErrno(res)) {</span>
<span class="line" id="L48">            .SUCCESS =&gt; {},</span>
<span class="line" id="L49">            .FAULT =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.ParamsOutsideAccessibleAddressSpace,</span>
<span class="line" id="L50">            <span class="tok-comment">// The resv array contains non-zero data, p.flags contains an unsupported flag,</span>
</span>
<span class="line" id="L51">            <span class="tok-comment">// entries out of bounds, IORING_SETUP_SQ_AFF was specified without IORING_SETUP_SQPOLL,</span>
</span>
<span class="line" id="L52">            <span class="tok-comment">// or IORING_SETUP_CQSIZE was specified but linux.io_uring_params.cq_entries was invalid:</span>
</span>
<span class="line" id="L53">            .INVAL =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.ArgumentsInvalid,</span>
<span class="line" id="L54">            .MFILE =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.ProcessFdQuotaExceeded,</span>
<span class="line" id="L55">            .NFILE =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SystemFdQuotaExceeded,</span>
<span class="line" id="L56">            .NOMEM =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SystemResources,</span>
<span class="line" id="L57">            <span class="tok-comment">// IORING_SETUP_SQPOLL was specified but effective user ID lacks sufficient privileges,</span>
</span>
<span class="line" id="L58">            <span class="tok-comment">// or a container seccomp policy prohibits io_uring syscalls:</span>
</span>
<span class="line" id="L59">            .PERM =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.PermissionDenied,</span>
<span class="line" id="L60">            .NOSYS =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SystemOutdated,</span>
<span class="line" id="L61">            <span class="tok-kw">else</span> =&gt; |errno| <span class="tok-kw">return</span> os.unexpectedErrno(errno),</span>
<span class="line" id="L62">        }</span>
<span class="line" id="L63">        <span class="tok-kw">const</span> fd = <span class="tok-builtin">@intCast</span>(os.fd_t, res);</span>
<span class="line" id="L64">        assert(fd &gt;= <span class="tok-number">0</span>);</span>
<span class="line" id="L65">        <span class="tok-kw">errdefer</span> os.close(fd);</span>
<span class="line" id="L66"></span>
<span class="line" id="L67">        <span class="tok-comment">// Kernel versions 5.4 and up use only one mmap() for the submission and completion queues.</span>
</span>
<span class="line" id="L68">        <span class="tok-comment">// This is not an optional feature for us... if the kernel does it, we have to do it.</span>
</span>
<span class="line" id="L69">        <span class="tok-comment">// The thinking on this by the kernel developers was that both the submission and the</span>
</span>
<span class="line" id="L70">        <span class="tok-comment">// completion queue rings have sizes just over a power of two, but the submission queue ring</span>
</span>
<span class="line" id="L71">        <span class="tok-comment">// is significantly smaller with u32 slots. By bundling both in a single mmap, the kernel</span>
</span>
<span class="line" id="L72">        <span class="tok-comment">// gets the submission queue ring for free.</span>
</span>
<span class="line" id="L73">        <span class="tok-comment">// See https://patchwork.kernel.org/patch/11115257 for the kernel patch.</span>
</span>
<span class="line" id="L74">        <span class="tok-comment">// We do not support the double mmap() done before 5.4, because we want to keep the</span>
</span>
<span class="line" id="L75">        <span class="tok-comment">// init/deinit mmap paths simple and because io_uring has had many bug fixes even since 5.4.</span>
</span>
<span class="line" id="L76">        <span class="tok-kw">if</span> ((p.features &amp; linux.IORING_FEAT_SINGLE_MMAP) == <span class="tok-number">0</span>) {</span>
<span class="line" id="L77">            <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SystemOutdated;</span>
<span class="line" id="L78">        }</span>
<span class="line" id="L79"></span>
<span class="line" id="L80">        <span class="tok-comment">// Check that the kernel has actually set params and that &quot;impossible is nothing&quot;.</span>
</span>
<span class="line" id="L81">        assert(p.sq_entries != <span class="tok-number">0</span>);</span>
<span class="line" id="L82">        assert(p.cq_entries != <span class="tok-number">0</span>);</span>
<span class="line" id="L83">        assert(p.cq_entries &gt;= p.sq_entries);</span>
<span class="line" id="L84"></span>
<span class="line" id="L85">        <span class="tok-comment">// From here on, we only need to read from params, so pass `p` by value as immutable.</span>
</span>
<span class="line" id="L86">        <span class="tok-comment">// The completion queue shares the mmap with the submission queue, so pass `sq` there too.</span>
</span>
<span class="line" id="L87">        <span class="tok-kw">var</span> sq = <span class="tok-kw">try</span> SubmissionQueue.init(fd, p.*);</span>
<span class="line" id="L88">        <span class="tok-kw">errdefer</span> sq.deinit();</span>
<span class="line" id="L89">        <span class="tok-kw">var</span> cq = <span class="tok-kw">try</span> CompletionQueue.init(fd, p.*, sq);</span>
<span class="line" id="L90">        <span class="tok-kw">errdefer</span> cq.deinit();</span>
<span class="line" id="L91"></span>
<span class="line" id="L92">        <span class="tok-comment">// Check that our starting state is as we expect.</span>
</span>
<span class="line" id="L93">        assert(sq.head.* == <span class="tok-number">0</span>);</span>
<span class="line" id="L94">        assert(sq.tail.* == <span class="tok-number">0</span>);</span>
<span class="line" id="L95">        assert(sq.mask == p.sq_entries - <span class="tok-number">1</span>);</span>
<span class="line" id="L96">        <span class="tok-comment">// Allow flags.* to be non-zero, since the kernel may set IORING_SQ_NEED_WAKEUP at any time.</span>
</span>
<span class="line" id="L97">        assert(sq.dropped.* == <span class="tok-number">0</span>);</span>
<span class="line" id="L98">        assert(sq.array.len == p.sq_entries);</span>
<span class="line" id="L99">        assert(sq.sqes.len == p.sq_entries);</span>
<span class="line" id="L100">        assert(sq.sqe_head == <span class="tok-number">0</span>);</span>
<span class="line" id="L101">        assert(sq.sqe_tail == <span class="tok-number">0</span>);</span>
<span class="line" id="L102"></span>
<span class="line" id="L103">        assert(cq.head.* == <span class="tok-number">0</span>);</span>
<span class="line" id="L104">        assert(cq.tail.* == <span class="tok-number">0</span>);</span>
<span class="line" id="L105">        assert(cq.mask == p.cq_entries - <span class="tok-number">1</span>);</span>
<span class="line" id="L106">        assert(cq.overflow.* == <span class="tok-number">0</span>);</span>
<span class="line" id="L107">        assert(cq.cqes.len == p.cq_entries);</span>
<span class="line" id="L108"></span>
<span class="line" id="L109">        <span class="tok-kw">return</span> IO_Uring{</span>
<span class="line" id="L110">            .fd = fd,</span>
<span class="line" id="L111">            .sq = sq,</span>
<span class="line" id="L112">            .cq = cq,</span>
<span class="line" id="L113">            .flags = p.flags,</span>
<span class="line" id="L114">            .features = p.features,</span>
<span class="line" id="L115">        };</span>
<span class="line" id="L116">    }</span>
<span class="line" id="L117"></span>
<span class="line" id="L118">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">deinit</span>(self: *IO_Uring) <span class="tok-type">void</span> {</span>
<span class="line" id="L119">        assert(self.fd &gt;= <span class="tok-number">0</span>);</span>
<span class="line" id="L120">        <span class="tok-comment">// The mmaps depend on the fd, so the order of these calls is important:</span>
</span>
<span class="line" id="L121">        self.cq.deinit();</span>
<span class="line" id="L122">        self.sq.deinit();</span>
<span class="line" id="L123">        os.close(self.fd);</span>
<span class="line" id="L124">        self.fd = -<span class="tok-number">1</span>;</span>
<span class="line" id="L125">    }</span>
<span class="line" id="L126"></span>
<span class="line" id="L127">    <span class="tok-comment">/// Returns a pointer to a vacant SQE, or an error if the submission queue is full.</span></span>
<span class="line" id="L128">    <span class="tok-comment">/// We follow the implementation (and atomics) of liburing's `io_uring_get_sqe()` exactly.</span></span>
<span class="line" id="L129">    <span class="tok-comment">/// However, instead of a null we return an error to force safe handling.</span></span>
<span class="line" id="L130">    <span class="tok-comment">/// Any situation where the submission queue is full tends more towards a control flow error,</span></span>
<span class="line" id="L131">    <span class="tok-comment">/// and the null return in liburing is more a C idiom than anything else, for lack of a better</span></span>
<span class="line" id="L132">    <span class="tok-comment">/// alternative. In Zig, we have first-class error handling... so let's use it.</span></span>
<span class="line" id="L133">    <span class="tok-comment">/// Matches the implementation of io_uring_get_sqe() in liburing.</span></span>
<span class="line" id="L134">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">get_sqe</span>(self: *IO_Uring) !*linux.io_uring_sqe {</span>
<span class="line" id="L135">        <span class="tok-kw">const</span> head = <span class="tok-builtin">@atomicLoad</span>(<span class="tok-type">u32</span>, self.sq.head, .Acquire);</span>
<span class="line" id="L136">        <span class="tok-comment">// Remember that these head and tail offsets wrap around every four billion operations.</span>
</span>
<span class="line" id="L137">        <span class="tok-comment">// We must therefore use wrapping addition and subtraction to avoid a runtime crash.</span>
</span>
<span class="line" id="L138">        <span class="tok-kw">const</span> next = self.sq.sqe_tail +% <span class="tok-number">1</span>;</span>
<span class="line" id="L139">        <span class="tok-kw">if</span> (next -% head &gt; self.sq.sqes.len) <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SubmissionQueueFull;</span>
<span class="line" id="L140">        <span class="tok-kw">var</span> sqe = &amp;self.sq.sqes[self.sq.sqe_tail &amp; self.sq.mask];</span>
<span class="line" id="L141">        self.sq.sqe_tail = next;</span>
<span class="line" id="L142">        <span class="tok-kw">return</span> sqe;</span>
<span class="line" id="L143">    }</span>
<span class="line" id="L144"></span>
<span class="line" id="L145">    <span class="tok-comment">/// Submits the SQEs acquired via get_sqe() to the kernel. You can call this once after you have</span></span>
<span class="line" id="L146">    <span class="tok-comment">/// called get_sqe() multiple times to setup multiple I/O requests.</span></span>
<span class="line" id="L147">    <span class="tok-comment">/// Returns the number of SQEs submitted.</span></span>
<span class="line" id="L148">    <span class="tok-comment">/// Matches the implementation of io_uring_submit() in liburing.</span></span>
<span class="line" id="L149">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">submit</span>(self: *IO_Uring) !<span class="tok-type">u32</span> {</span>
<span class="line" id="L150">        <span class="tok-kw">return</span> self.submit_and_wait(<span class="tok-number">0</span>);</span>
<span class="line" id="L151">    }</span>
<span class="line" id="L152"></span>
<span class="line" id="L153">    <span class="tok-comment">/// Like submit(), but allows waiting for events as well.</span></span>
<span class="line" id="L154">    <span class="tok-comment">/// Returns the number of SQEs submitted.</span></span>
<span class="line" id="L155">    <span class="tok-comment">/// Matches the implementation of io_uring_submit_and_wait() in liburing.</span></span>
<span class="line" id="L156">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">submit_and_wait</span>(self: *IO_Uring, wait_nr: <span class="tok-type">u32</span>) !<span class="tok-type">u32</span> {</span>
<span class="line" id="L157">        <span class="tok-kw">const</span> submitted = self.flush_sq();</span>
<span class="line" id="L158">        <span class="tok-kw">var</span> flags: <span class="tok-type">u32</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L159">        <span class="tok-kw">if</span> (self.sq_ring_needs_enter(&amp;flags) <span class="tok-kw">or</span> wait_nr &gt; <span class="tok-number">0</span>) {</span>
<span class="line" id="L160">            <span class="tok-kw">if</span> (wait_nr &gt; <span class="tok-number">0</span> <span class="tok-kw">or</span> (self.flags &amp; linux.IORING_SETUP_IOPOLL) != <span class="tok-number">0</span>) {</span>
<span class="line" id="L161">                flags |= linux.IORING_ENTER_GETEVENTS;</span>
<span class="line" id="L162">            }</span>
<span class="line" id="L163">            <span class="tok-kw">return</span> <span class="tok-kw">try</span> self.enter(submitted, wait_nr, flags);</span>
<span class="line" id="L164">        }</span>
<span class="line" id="L165">        <span class="tok-kw">return</span> submitted;</span>
<span class="line" id="L166">    }</span>
<span class="line" id="L167"></span>
<span class="line" id="L168">    <span class="tok-comment">/// Tell the kernel we have submitted SQEs and/or want to wait for CQEs.</span></span>
<span class="line" id="L169">    <span class="tok-comment">/// Returns the number of SQEs submitted.</span></span>
<span class="line" id="L170">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">enter</span>(self: *IO_Uring, to_submit: <span class="tok-type">u32</span>, min_complete: <span class="tok-type">u32</span>, flags: <span class="tok-type">u32</span>) !<span class="tok-type">u32</span> {</span>
<span class="line" id="L171">        assert(self.fd &gt;= <span class="tok-number">0</span>);</span>
<span class="line" id="L172">        <span class="tok-kw">const</span> res = linux.io_uring_enter(self.fd, to_submit, min_complete, flags, <span class="tok-null">null</span>);</span>
<span class="line" id="L173">        <span class="tok-kw">switch</span> (linux.getErrno(res)) {</span>
<span class="line" id="L174">            .SUCCESS =&gt; {},</span>
<span class="line" id="L175">            <span class="tok-comment">// The kernel was unable to allocate memory or ran out of resources for the request.</span>
</span>
<span class="line" id="L176">            <span class="tok-comment">// The application should wait for some completions and try again:</span>
</span>
<span class="line" id="L177">            .AGAIN =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SystemResources,</span>
<span class="line" id="L178">            <span class="tok-comment">// The SQE `fd` is invalid, or IOSQE_FIXED_FILE was set but no files were registered:</span>
</span>
<span class="line" id="L179">            .BADF =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.FileDescriptorInvalid,</span>
<span class="line" id="L180">            <span class="tok-comment">// The file descriptor is valid, but the ring is not in the right state.</span>
</span>
<span class="line" id="L181">            <span class="tok-comment">// See io_uring_register(2) for how to enable the ring.</span>
</span>
<span class="line" id="L182">            .BADFD =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.FileDescriptorInBadState,</span>
<span class="line" id="L183">            <span class="tok-comment">// The application attempted to overcommit the number of requests it can have pending.</span>
</span>
<span class="line" id="L184">            <span class="tok-comment">// The application should wait for some completions and try again:</span>
</span>
<span class="line" id="L185">            .BUSY =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.CompletionQueueOvercommitted,</span>
<span class="line" id="L186">            <span class="tok-comment">// The SQE is invalid, or valid but the ring was setup with IORING_SETUP_IOPOLL:</span>
</span>
<span class="line" id="L187">            .INVAL =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SubmissionQueueEntryInvalid,</span>
<span class="line" id="L188">            <span class="tok-comment">// The buffer is outside the process' accessible address space, or IORING_OP_READ_FIXED</span>
</span>
<span class="line" id="L189">            <span class="tok-comment">// or IORING_OP_WRITE_FIXED was specified but no buffers were registered, or the range</span>
</span>
<span class="line" id="L190">            <span class="tok-comment">// described by `addr` and `len` is not within the buffer registered at `buf_index`:</span>
</span>
<span class="line" id="L191">            .FAULT =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.BufferInvalid,</span>
<span class="line" id="L192">            .NXIO =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.RingShuttingDown,</span>
<span class="line" id="L193">            <span class="tok-comment">// The kernel believes our `self.fd` does not refer to an io_uring instance,</span>
</span>
<span class="line" id="L194">            <span class="tok-comment">// or the opcode is valid but not supported by this kernel (more likely):</span>
</span>
<span class="line" id="L195">            .OPNOTSUPP =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.OpcodeNotSupported,</span>
<span class="line" id="L196">            <span class="tok-comment">// The operation was interrupted by a delivery of a signal before it could complete.</span>
</span>
<span class="line" id="L197">            <span class="tok-comment">// This can happen while waiting for events with IORING_ENTER_GETEVENTS:</span>
</span>
<span class="line" id="L198">            .INTR =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SignalInterrupt,</span>
<span class="line" id="L199">            <span class="tok-kw">else</span> =&gt; |errno| <span class="tok-kw">return</span> os.unexpectedErrno(errno),</span>
<span class="line" id="L200">        }</span>
<span class="line" id="L201">        <span class="tok-kw">return</span> <span class="tok-builtin">@intCast</span>(<span class="tok-type">u32</span>, res);</span>
<span class="line" id="L202">    }</span>
<span class="line" id="L203"></span>
<span class="line" id="L204">    <span class="tok-comment">/// Sync internal state with kernel ring state on the SQ side.</span></span>
<span class="line" id="L205">    <span class="tok-comment">/// Returns the number of all pending events in the SQ ring, for the shared ring.</span></span>
<span class="line" id="L206">    <span class="tok-comment">/// This return value includes previously flushed SQEs, as per liburing.</span></span>
<span class="line" id="L207">    <span class="tok-comment">/// The rationale is to suggest that an io_uring_enter() call is needed rather than not.</span></span>
<span class="line" id="L208">    <span class="tok-comment">/// Matches the implementation of __io_uring_flush_sq() in liburing.</span></span>
<span class="line" id="L209">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">flush_sq</span>(self: *IO_Uring) <span class="tok-type">u32</span> {</span>
<span class="line" id="L210">        <span class="tok-kw">if</span> (self.sq.sqe_head != self.sq.sqe_tail) {</span>
<span class="line" id="L211">            <span class="tok-comment">// Fill in SQEs that we have queued up, adding them to the kernel ring.</span>
</span>
<span class="line" id="L212">            <span class="tok-kw">const</span> to_submit = self.sq.sqe_tail -% self.sq.sqe_head;</span>
<span class="line" id="L213">            <span class="tok-kw">var</span> tail = self.sq.tail.*;</span>
<span class="line" id="L214">            <span class="tok-kw">var</span> i: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L215">            <span class="tok-kw">while</span> (i &lt; to_submit) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L216">                self.sq.array[tail &amp; self.sq.mask] = self.sq.sqe_head &amp; self.sq.mask;</span>
<span class="line" id="L217">                tail +%= <span class="tok-number">1</span>;</span>
<span class="line" id="L218">                self.sq.sqe_head +%= <span class="tok-number">1</span>;</span>
<span class="line" id="L219">            }</span>
<span class="line" id="L220">            <span class="tok-comment">// Ensure that the kernel can actually see the SQE updates when it sees the tail update.</span>
</span>
<span class="line" id="L221">            <span class="tok-builtin">@atomicStore</span>(<span class="tok-type">u32</span>, self.sq.tail, tail, .Release);</span>
<span class="line" id="L222">        }</span>
<span class="line" id="L223">        <span class="tok-kw">return</span> self.sq_ready();</span>
<span class="line" id="L224">    }</span>
<span class="line" id="L225"></span>
<span class="line" id="L226">    <span class="tok-comment">/// Returns true if we are not using an SQ thread (thus nobody submits but us),</span></span>
<span class="line" id="L227">    <span class="tok-comment">/// or if IORING_SQ_NEED_WAKEUP is set and the SQ thread must be explicitly awakened.</span></span>
<span class="line" id="L228">    <span class="tok-comment">/// For the latter case, we set the SQ thread wakeup flag.</span></span>
<span class="line" id="L229">    <span class="tok-comment">/// Matches the implementation of sq_ring_needs_enter() in liburing.</span></span>
<span class="line" id="L230">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">sq_ring_needs_enter</span>(self: *IO_Uring, flags: *<span class="tok-type">u32</span>) <span class="tok-type">bool</span> {</span>
<span class="line" id="L231">        assert(flags.* == <span class="tok-number">0</span>);</span>
<span class="line" id="L232">        <span class="tok-kw">if</span> ((self.flags &amp; linux.IORING_SETUP_SQPOLL) == <span class="tok-number">0</span>) <span class="tok-kw">return</span> <span class="tok-null">true</span>;</span>
<span class="line" id="L233">        <span class="tok-kw">if</span> ((<span class="tok-builtin">@atomicLoad</span>(<span class="tok-type">u32</span>, self.sq.flags, .Unordered) &amp; linux.IORING_SQ_NEED_WAKEUP) != <span class="tok-number">0</span>) {</span>
<span class="line" id="L234">            flags.* |= linux.IORING_ENTER_SQ_WAKEUP;</span>
<span class="line" id="L235">            <span class="tok-kw">return</span> <span class="tok-null">true</span>;</span>
<span class="line" id="L236">        }</span>
<span class="line" id="L237">        <span class="tok-kw">return</span> <span class="tok-null">false</span>;</span>
<span class="line" id="L238">    }</span>
<span class="line" id="L239"></span>
<span class="line" id="L240">    <span class="tok-comment">/// Returns the number of flushed and unflushed SQEs pending in the submission queue.</span></span>
<span class="line" id="L241">    <span class="tok-comment">/// In other words, this is the number of SQEs in the submission queue, i.e. its length.</span></span>
<span class="line" id="L242">    <span class="tok-comment">/// These are SQEs that the kernel is yet to consume.</span></span>
<span class="line" id="L243">    <span class="tok-comment">/// Matches the implementation of io_uring_sq_ready in liburing.</span></span>
<span class="line" id="L244">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">sq_ready</span>(self: *IO_Uring) <span class="tok-type">u32</span> {</span>
<span class="line" id="L245">        <span class="tok-comment">// Always use the shared ring state (i.e. head and not sqe_head) to avoid going out of sync,</span>
</span>
<span class="line" id="L246">        <span class="tok-comment">// see https://github.com/axboe/liburing/issues/92.</span>
</span>
<span class="line" id="L247">        <span class="tok-kw">return</span> self.sq.sqe_tail -% <span class="tok-builtin">@atomicLoad</span>(<span class="tok-type">u32</span>, self.sq.head, .Acquire);</span>
<span class="line" id="L248">    }</span>
<span class="line" id="L249"></span>
<span class="line" id="L250">    <span class="tok-comment">/// Returns the number of CQEs in the completion queue, i.e. its length.</span></span>
<span class="line" id="L251">    <span class="tok-comment">/// These are CQEs that the application is yet to consume.</span></span>
<span class="line" id="L252">    <span class="tok-comment">/// Matches the implementation of io_uring_cq_ready in liburing.</span></span>
<span class="line" id="L253">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">cq_ready</span>(self: *IO_Uring) <span class="tok-type">u32</span> {</span>
<span class="line" id="L254">        <span class="tok-kw">return</span> <span class="tok-builtin">@atomicLoad</span>(<span class="tok-type">u32</span>, self.cq.tail, .Acquire) -% self.cq.head.*;</span>
<span class="line" id="L255">    }</span>
<span class="line" id="L256"></span>
<span class="line" id="L257">    <span class="tok-comment">/// Copies as many CQEs as are ready, and that can fit into the destination `cqes` slice.</span></span>
<span class="line" id="L258">    <span class="tok-comment">/// If none are available, enters into the kernel to wait for at most `wait_nr` CQEs.</span></span>
<span class="line" id="L259">    <span class="tok-comment">/// Returns the number of CQEs copied, advancing the CQ ring.</span></span>
<span class="line" id="L260">    <span class="tok-comment">/// Provides all the wait/peek methods found in liburing, but with batching and a single method.</span></span>
<span class="line" id="L261">    <span class="tok-comment">/// The rationale for copying CQEs rather than copying pointers is that pointers are 8 bytes</span></span>
<span class="line" id="L262">    <span class="tok-comment">/// whereas CQEs are not much more at only 16 bytes, and this provides a safer faster interface.</span></span>
<span class="line" id="L263">    <span class="tok-comment">/// Safer, because you no longer need to call cqe_seen(), avoiding idempotency bugs.</span></span>
<span class="line" id="L264">    <span class="tok-comment">/// Faster, because we can now amortize the atomic store release to `cq.head` across the batch.</span></span>
<span class="line" id="L265">    <span class="tok-comment">/// See https://github.com/axboe/liburing/issues/103#issuecomment-686665007.</span></span>
<span class="line" id="L266">    <span class="tok-comment">/// Matches the implementation of io_uring_peek_batch_cqe() in liburing, but supports waiting.</span></span>
<span class="line" id="L267">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">copy_cqes</span>(self: *IO_Uring, cqes: []linux.io_uring_cqe, wait_nr: <span class="tok-type">u32</span>) !<span class="tok-type">u32</span> {</span>
<span class="line" id="L268">        <span class="tok-kw">const</span> count = self.copy_cqes_ready(cqes, wait_nr);</span>
<span class="line" id="L269">        <span class="tok-kw">if</span> (count &gt; <span class="tok-number">0</span>) <span class="tok-kw">return</span> count;</span>
<span class="line" id="L270">        <span class="tok-kw">if</span> (self.cq_ring_needs_flush() <span class="tok-kw">or</span> wait_nr &gt; <span class="tok-number">0</span>) {</span>
<span class="line" id="L271">            _ = <span class="tok-kw">try</span> self.enter(<span class="tok-number">0</span>, wait_nr, linux.IORING_ENTER_GETEVENTS);</span>
<span class="line" id="L272">            <span class="tok-kw">return</span> self.copy_cqes_ready(cqes, wait_nr);</span>
<span class="line" id="L273">        }</span>
<span class="line" id="L274">        <span class="tok-kw">return</span> <span class="tok-number">0</span>;</span>
<span class="line" id="L275">    }</span>
<span class="line" id="L276"></span>
<span class="line" id="L277">    <span class="tok-kw">fn</span> <span class="tok-fn">copy_cqes_ready</span>(self: *IO_Uring, cqes: []linux.io_uring_cqe, wait_nr: <span class="tok-type">u32</span>) <span class="tok-type">u32</span> {</span>
<span class="line" id="L278">        _ = wait_nr;</span>
<span class="line" id="L279">        <span class="tok-kw">const</span> ready = self.cq_ready();</span>
<span class="line" id="L280">        <span class="tok-kw">const</span> count = std.math.min(cqes.len, ready);</span>
<span class="line" id="L281">        <span class="tok-kw">var</span> head = self.cq.head.*;</span>
<span class="line" id="L282">        <span class="tok-kw">var</span> tail = head +% count;</span>
<span class="line" id="L283">        <span class="tok-comment">// TODO Optimize this by using 1 or 2 memcpy's (if the tail wraps) rather than a loop.</span>
</span>
<span class="line" id="L284">        <span class="tok-kw">var</span> i: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L285">        <span class="tok-comment">// Do not use &quot;less-than&quot; operator since head and tail may wrap:</span>
</span>
<span class="line" id="L286">        <span class="tok-kw">while</span> (head != tail) {</span>
<span class="line" id="L287">            cqes[i] = self.cq.cqes[head &amp; self.cq.mask]; <span class="tok-comment">// Copy struct by value.</span>
</span>
<span class="line" id="L288">            head +%= <span class="tok-number">1</span>;</span>
<span class="line" id="L289">            i += <span class="tok-number">1</span>;</span>
<span class="line" id="L290">        }</span>
<span class="line" id="L291">        self.cq_advance(count);</span>
<span class="line" id="L292">        <span class="tok-kw">return</span> count;</span>
<span class="line" id="L293">    }</span>
<span class="line" id="L294"></span>
<span class="line" id="L295">    <span class="tok-comment">/// Returns a copy of an I/O completion, waiting for it if necessary, and advancing the CQ ring.</span></span>
<span class="line" id="L296">    <span class="tok-comment">/// A convenience method for `copy_cqes()` for when you don't need to batch or peek.</span></span>
<span class="line" id="L297">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">copy_cqe</span>(ring: *IO_Uring) !linux.io_uring_cqe {</span>
<span class="line" id="L298">        <span class="tok-kw">var</span> cqes: [<span class="tok-number">1</span>]linux.io_uring_cqe = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L299">        <span class="tok-kw">while</span> (<span class="tok-null">true</span>) {</span>
<span class="line" id="L300">            <span class="tok-kw">const</span> count = <span class="tok-kw">try</span> ring.copy_cqes(&amp;cqes, <span class="tok-number">1</span>);</span>
<span class="line" id="L301">            <span class="tok-kw">if</span> (count &gt; <span class="tok-number">0</span>) <span class="tok-kw">return</span> cqes[<span class="tok-number">0</span>];</span>
<span class="line" id="L302">        }</span>
<span class="line" id="L303">    }</span>
<span class="line" id="L304"></span>
<span class="line" id="L305">    <span class="tok-comment">/// Matches the implementation of cq_ring_needs_flush() in liburing.</span></span>
<span class="line" id="L306">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">cq_ring_needs_flush</span>(self: *IO_Uring) <span class="tok-type">bool</span> {</span>
<span class="line" id="L307">        <span class="tok-kw">return</span> (<span class="tok-builtin">@atomicLoad</span>(<span class="tok-type">u32</span>, self.sq.flags, .Unordered) &amp; linux.IORING_SQ_CQ_OVERFLOW) != <span class="tok-number">0</span>;</span>
<span class="line" id="L308">    }</span>
<span class="line" id="L309"></span>
<span class="line" id="L310">    <span class="tok-comment">/// For advanced use cases only that implement custom completion queue methods.</span></span>
<span class="line" id="L311">    <span class="tok-comment">/// If you use copy_cqes() or copy_cqe() you must not call cqe_seen() or cq_advance().</span></span>
<span class="line" id="L312">    <span class="tok-comment">/// Must be called exactly once after a zero-copy CQE has been processed by your application.</span></span>
<span class="line" id="L313">    <span class="tok-comment">/// Not idempotent, calling more than once will result in other CQEs being lost.</span></span>
<span class="line" id="L314">    <span class="tok-comment">/// Matches the implementation of cqe_seen() in liburing.</span></span>
<span class="line" id="L315">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">cqe_seen</span>(self: *IO_Uring, cqe: *linux.io_uring_cqe) <span class="tok-type">void</span> {</span>
<span class="line" id="L316">        _ = cqe;</span>
<span class="line" id="L317">        self.cq_advance(<span class="tok-number">1</span>);</span>
<span class="line" id="L318">    }</span>
<span class="line" id="L319"></span>
<span class="line" id="L320">    <span class="tok-comment">/// For advanced use cases only that implement custom completion queue methods.</span></span>
<span class="line" id="L321">    <span class="tok-comment">/// Matches the implementation of cq_advance() in liburing.</span></span>
<span class="line" id="L322">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">cq_advance</span>(self: *IO_Uring, count: <span class="tok-type">u32</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L323">        <span class="tok-kw">if</span> (count &gt; <span class="tok-number">0</span>) {</span>
<span class="line" id="L324">            <span class="tok-comment">// Ensure the kernel only sees the new head value after the CQEs have been read.</span>
</span>
<span class="line" id="L325">            <span class="tok-builtin">@atomicStore</span>(<span class="tok-type">u32</span>, self.cq.head, self.cq.head.* +% count, .Release);</span>
<span class="line" id="L326">        }</span>
<span class="line" id="L327">    }</span>
<span class="line" id="L328"></span>
<span class="line" id="L329">    <span class="tok-comment">/// Queues (but does not submit) an SQE to perform an `fsync(2)`.</span></span>
<span class="line" id="L330">    <span class="tok-comment">/// Returns a pointer to the SQE so that you can further modify the SQE for advanced use cases.</span></span>
<span class="line" id="L331">    <span class="tok-comment">/// For example, for `fdatasync()` you can set `IORING_FSYNC_DATASYNC` in the SQE's `rw_flags`.</span></span>
<span class="line" id="L332">    <span class="tok-comment">/// N.B. While SQEs are initiated in the order in which they appear in the submission queue,</span></span>
<span class="line" id="L333">    <span class="tok-comment">/// operations execute in parallel and completions are unordered. Therefore, an application that</span></span>
<span class="line" id="L334">    <span class="tok-comment">/// submits a write followed by an fsync in the submission queue cannot expect the fsync to</span></span>
<span class="line" id="L335">    <span class="tok-comment">/// apply to the write, since the fsync may complete before the write is issued to the disk.</span></span>
<span class="line" id="L336">    <span class="tok-comment">/// You should preferably use `link_with_next_sqe()` on a write's SQE to link it with an fsync,</span></span>
<span class="line" id="L337">    <span class="tok-comment">/// or else insert a full write barrier using `drain_previous_sqes()` when queueing an fsync.</span></span>
<span class="line" id="L338">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">fsync</span>(self: *IO_Uring, user_data: <span class="tok-type">u64</span>, fd: os.fd_t, flags: <span class="tok-type">u32</span>) !*linux.io_uring_sqe {</span>
<span class="line" id="L339">        <span class="tok-kw">const</span> sqe = <span class="tok-kw">try</span> self.get_sqe();</span>
<span class="line" id="L340">        io_uring_prep_fsync(sqe, fd, flags);</span>
<span class="line" id="L341">        sqe.user_data = user_data;</span>
<span class="line" id="L342">        <span class="tok-kw">return</span> sqe;</span>
<span class="line" id="L343">    }</span>
<span class="line" id="L344"></span>
<span class="line" id="L345">    <span class="tok-comment">/// Queues (but does not submit) an SQE to perform a no-op.</span></span>
<span class="line" id="L346">    <span class="tok-comment">/// Returns a pointer to the SQE so that you can further modify the SQE for advanced use cases.</span></span>
<span class="line" id="L347">    <span class="tok-comment">/// A no-op is more useful than may appear at first glance.</span></span>
<span class="line" id="L348">    <span class="tok-comment">/// For example, you could call `drain_previous_sqes()` on the returned SQE, to use the no-op to</span></span>
<span class="line" id="L349">    <span class="tok-comment">/// know when the ring is idle before acting on a kill signal.</span></span>
<span class="line" id="L350">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">nop</span>(self: *IO_Uring, user_data: <span class="tok-type">u64</span>) !*linux.io_uring_sqe {</span>
<span class="line" id="L351">        <span class="tok-kw">const</span> sqe = <span class="tok-kw">try</span> self.get_sqe();</span>
<span class="line" id="L352">        io_uring_prep_nop(sqe);</span>
<span class="line" id="L353">        sqe.user_data = user_data;</span>
<span class="line" id="L354">        <span class="tok-kw">return</span> sqe;</span>
<span class="line" id="L355">    }</span>
<span class="line" id="L356"></span>
<span class="line" id="L357">    <span class="tok-comment">/// Used to select how the read should be handled.</span></span>
<span class="line" id="L358">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> ReadBuffer = <span class="tok-kw">union</span>(<span class="tok-kw">enum</span>) {</span>
<span class="line" id="L359">        <span class="tok-comment">/// io_uring will read directly into this buffer</span></span>
<span class="line" id="L360">        buffer: []<span class="tok-type">u8</span>,</span>
<span class="line" id="L361"></span>
<span class="line" id="L362">        <span class="tok-comment">/// io_uring will read directly into these buffers using readv.</span></span>
<span class="line" id="L363">        iovecs: []<span class="tok-kw">const</span> os.iovec,</span>
<span class="line" id="L364"></span>
<span class="line" id="L365">        <span class="tok-comment">/// io_uring will select a buffer that has previously been provided with `provide_buffers`.</span></span>
<span class="line" id="L366">        <span class="tok-comment">/// The buffer group reference by `group_id` must contain at least one buffer for the read to work.</span></span>
<span class="line" id="L367">        <span class="tok-comment">/// `len` controls the number of bytes to read into the selected buffer.</span></span>
<span class="line" id="L368">        buffer_selection: <span class="tok-kw">struct</span> {</span>
<span class="line" id="L369">            group_id: <span class="tok-type">u16</span>,</span>
<span class="line" id="L370">            len: <span class="tok-type">usize</span>,</span>
<span class="line" id="L371">        },</span>
<span class="line" id="L372">    };</span>
<span class="line" id="L373"></span>
<span class="line" id="L374">    <span class="tok-comment">/// Queues (but does not submit) an SQE to perform a `read(2)` or `preadv` depending on the buffer type.</span></span>
<span class="line" id="L375">    <span class="tok-comment">/// * Reading into a `ReadBuffer.buffer` uses `read(2)`</span></span>
<span class="line" id="L376">    <span class="tok-comment">/// * Reading into a `ReadBuffer.iovecs` uses `preadv(2)`</span></span>
<span class="line" id="L377">    <span class="tok-comment">///   If you want to do a `preadv2()` then set `rw_flags` on the returned SQE. See https://linux.die.net/man/2/preadv.</span></span>
<span class="line" id="L378">    <span class="tok-comment">///</span></span>
<span class="line" id="L379">    <span class="tok-comment">/// Returns a pointer to the SQE.</span></span>
<span class="line" id="L380">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">read</span>(</span>
<span class="line" id="L381">        self: *IO_Uring,</span>
<span class="line" id="L382">        user_data: <span class="tok-type">u64</span>,</span>
<span class="line" id="L383">        fd: os.fd_t,</span>
<span class="line" id="L384">        buffer: ReadBuffer,</span>
<span class="line" id="L385">        offset: <span class="tok-type">u64</span>,</span>
<span class="line" id="L386">    ) !*linux.io_uring_sqe {</span>
<span class="line" id="L387">        <span class="tok-kw">const</span> sqe = <span class="tok-kw">try</span> self.get_sqe();</span>
<span class="line" id="L388">        <span class="tok-kw">switch</span> (buffer) {</span>
<span class="line" id="L389">            .buffer =&gt; |slice| io_uring_prep_read(sqe, fd, slice, offset),</span>
<span class="line" id="L390">            .iovecs =&gt; |vecs| io_uring_prep_readv(sqe, fd, vecs, offset),</span>
<span class="line" id="L391">            .buffer_selection =&gt; |selection| {</span>
<span class="line" id="L392">                io_uring_prep_rw(.READ, sqe, fd, <span class="tok-number">0</span>, selection.len, offset);</span>
<span class="line" id="L393">                sqe.flags |= linux.IOSQE_BUFFER_SELECT;</span>
<span class="line" id="L394">                sqe.buf_index = selection.group_id;</span>
<span class="line" id="L395">            },</span>
<span class="line" id="L396">        }</span>
<span class="line" id="L397">        sqe.user_data = user_data;</span>
<span class="line" id="L398">        <span class="tok-kw">return</span> sqe;</span>
<span class="line" id="L399">    }</span>
<span class="line" id="L400"></span>
<span class="line" id="L401">    <span class="tok-comment">/// Queues (but does not submit) an SQE to perform a `write(2)`.</span></span>
<span class="line" id="L402">    <span class="tok-comment">/// Returns a pointer to the SQE.</span></span>
<span class="line" id="L403">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">write</span>(</span>
<span class="line" id="L404">        self: *IO_Uring,</span>
<span class="line" id="L405">        user_data: <span class="tok-type">u64</span>,</span>
<span class="line" id="L406">        fd: os.fd_t,</span>
<span class="line" id="L407">        buffer: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L408">        offset: <span class="tok-type">u64</span>,</span>
<span class="line" id="L409">    ) !*linux.io_uring_sqe {</span>
<span class="line" id="L410">        <span class="tok-kw">const</span> sqe = <span class="tok-kw">try</span> self.get_sqe();</span>
<span class="line" id="L411">        io_uring_prep_write(sqe, fd, buffer, offset);</span>
<span class="line" id="L412">        sqe.user_data = user_data;</span>
<span class="line" id="L413">        <span class="tok-kw">return</span> sqe;</span>
<span class="line" id="L414">    }</span>
<span class="line" id="L415"></span>
<span class="line" id="L416">    <span class="tok-comment">/// Queues (but does not submit) an SQE to perform a IORING_OP_READ_FIXED.</span></span>
<span class="line" id="L417">    <span class="tok-comment">/// The `buffer` provided must be registered with the kernel by calling `register_buffers` first.</span></span>
<span class="line" id="L418">    <span class="tok-comment">/// The `buffer_index` must be the same as its index in the array provided to `register_buffers`.</span></span>
<span class="line" id="L419">    <span class="tok-comment">///</span></span>
<span class="line" id="L420">    <span class="tok-comment">/// Returns a pointer to the SQE so that you can further modify the SQE for advanced use cases.</span></span>
<span class="line" id="L421">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">read_fixed</span>(</span>
<span class="line" id="L422">        self: *IO_Uring,</span>
<span class="line" id="L423">        user_data: <span class="tok-type">u64</span>,</span>
<span class="line" id="L424">        fd: os.fd_t,</span>
<span class="line" id="L425">        buffer: *os.iovec,</span>
<span class="line" id="L426">        offset: <span class="tok-type">u64</span>,</span>
<span class="line" id="L427">        buffer_index: <span class="tok-type">u16</span>,</span>
<span class="line" id="L428">    ) !*linux.io_uring_sqe {</span>
<span class="line" id="L429">        <span class="tok-kw">const</span> sqe = <span class="tok-kw">try</span> self.get_sqe();</span>
<span class="line" id="L430">        io_uring_prep_read_fixed(sqe, fd, buffer, offset, buffer_index);</span>
<span class="line" id="L431">        sqe.user_data = user_data;</span>
<span class="line" id="L432">        <span class="tok-kw">return</span> sqe;</span>
<span class="line" id="L433">    }</span>
<span class="line" id="L434"></span>
<span class="line" id="L435">    <span class="tok-comment">/// Queues (but does not submit) an SQE to perform a `pwritev()`.</span></span>
<span class="line" id="L436">    <span class="tok-comment">/// Returns a pointer to the SQE so that you can further modify the SQE for advanced use cases.</span></span>
<span class="line" id="L437">    <span class="tok-comment">/// For example, if you want to do a `pwritev2()` then set `rw_flags` on the returned SQE.</span></span>
<span class="line" id="L438">    <span class="tok-comment">/// See https://linux.die.net/man/2/pwritev.</span></span>
<span class="line" id="L439">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">writev</span>(</span>
<span class="line" id="L440">        self: *IO_Uring,</span>
<span class="line" id="L441">        user_data: <span class="tok-type">u64</span>,</span>
<span class="line" id="L442">        fd: os.fd_t,</span>
<span class="line" id="L443">        iovecs: []<span class="tok-kw">const</span> os.iovec_const,</span>
<span class="line" id="L444">        offset: <span class="tok-type">u64</span>,</span>
<span class="line" id="L445">    ) !*linux.io_uring_sqe {</span>
<span class="line" id="L446">        <span class="tok-kw">const</span> sqe = <span class="tok-kw">try</span> self.get_sqe();</span>
<span class="line" id="L447">        io_uring_prep_writev(sqe, fd, iovecs, offset);</span>
<span class="line" id="L448">        sqe.user_data = user_data;</span>
<span class="line" id="L449">        <span class="tok-kw">return</span> sqe;</span>
<span class="line" id="L450">    }</span>
<span class="line" id="L451"></span>
<span class="line" id="L452">    <span class="tok-comment">/// Queues (but does not submit) an SQE to perform a IORING_OP_WRITE_FIXED.</span></span>
<span class="line" id="L453">    <span class="tok-comment">/// The `buffer` provided must be registered with the kernel by calling `register_buffers` first.</span></span>
<span class="line" id="L454">    <span class="tok-comment">/// The `buffer_index` must be the same as its index in the array provided to `register_buffers`.</span></span>
<span class="line" id="L455">    <span class="tok-comment">///</span></span>
<span class="line" id="L456">    <span class="tok-comment">/// Returns a pointer to the SQE so that you can further modify the SQE for advanced use cases.</span></span>
<span class="line" id="L457">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">write_fixed</span>(</span>
<span class="line" id="L458">        self: *IO_Uring,</span>
<span class="line" id="L459">        user_data: <span class="tok-type">u64</span>,</span>
<span class="line" id="L460">        fd: os.fd_t,</span>
<span class="line" id="L461">        buffer: *os.iovec,</span>
<span class="line" id="L462">        offset: <span class="tok-type">u64</span>,</span>
<span class="line" id="L463">        buffer_index: <span class="tok-type">u16</span>,</span>
<span class="line" id="L464">    ) !*linux.io_uring_sqe {</span>
<span class="line" id="L465">        <span class="tok-kw">const</span> sqe = <span class="tok-kw">try</span> self.get_sqe();</span>
<span class="line" id="L466">        io_uring_prep_write_fixed(sqe, fd, buffer, offset, buffer_index);</span>
<span class="line" id="L467">        sqe.user_data = user_data;</span>
<span class="line" id="L468">        <span class="tok-kw">return</span> sqe;</span>
<span class="line" id="L469">    }</span>
<span class="line" id="L470"></span>
<span class="line" id="L471">    <span class="tok-comment">/// Queues (but does not submit) an SQE to perform an `accept4(2)` on a socket.</span></span>
<span class="line" id="L472">    <span class="tok-comment">/// Returns a pointer to the SQE.</span></span>
<span class="line" id="L473">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">accept</span>(</span>
<span class="line" id="L474">        self: *IO_Uring,</span>
<span class="line" id="L475">        user_data: <span class="tok-type">u64</span>,</span>
<span class="line" id="L476">        fd: os.fd_t,</span>
<span class="line" id="L477">        addr: *os.sockaddr,</span>
<span class="line" id="L478">        addrlen: *os.socklen_t,</span>
<span class="line" id="L479">        flags: <span class="tok-type">u32</span>,</span>
<span class="line" id="L480">    ) !*linux.io_uring_sqe {</span>
<span class="line" id="L481">        <span class="tok-kw">const</span> sqe = <span class="tok-kw">try</span> self.get_sqe();</span>
<span class="line" id="L482">        io_uring_prep_accept(sqe, fd, addr, addrlen, flags);</span>
<span class="line" id="L483">        sqe.user_data = user_data;</span>
<span class="line" id="L484">        <span class="tok-kw">return</span> sqe;</span>
<span class="line" id="L485">    }</span>
<span class="line" id="L486"></span>
<span class="line" id="L487">    <span class="tok-comment">/// Queue (but does not submit) an SQE to perform a `connect(2)` on a socket.</span></span>
<span class="line" id="L488">    <span class="tok-comment">/// Returns a pointer to the SQE.</span></span>
<span class="line" id="L489">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">connect</span>(</span>
<span class="line" id="L490">        self: *IO_Uring,</span>
<span class="line" id="L491">        user_data: <span class="tok-type">u64</span>,</span>
<span class="line" id="L492">        fd: os.fd_t,</span>
<span class="line" id="L493">        addr: *<span class="tok-kw">const</span> os.sockaddr,</span>
<span class="line" id="L494">        addrlen: os.socklen_t,</span>
<span class="line" id="L495">    ) !*linux.io_uring_sqe {</span>
<span class="line" id="L496">        <span class="tok-kw">const</span> sqe = <span class="tok-kw">try</span> self.get_sqe();</span>
<span class="line" id="L497">        io_uring_prep_connect(sqe, fd, addr, addrlen);</span>
<span class="line" id="L498">        sqe.user_data = user_data;</span>
<span class="line" id="L499">        <span class="tok-kw">return</span> sqe;</span>
<span class="line" id="L500">    }</span>
<span class="line" id="L501"></span>
<span class="line" id="L502">    <span class="tok-comment">/// Queues (but does not submit) an SQE to perform a `epoll_ctl(2)`.</span></span>
<span class="line" id="L503">    <span class="tok-comment">/// Returns a pointer to the SQE.</span></span>
<span class="line" id="L504">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">epoll_ctl</span>(</span>
<span class="line" id="L505">        self: *IO_Uring,</span>
<span class="line" id="L506">        user_data: <span class="tok-type">u64</span>,</span>
<span class="line" id="L507">        epfd: os.fd_t,</span>
<span class="line" id="L508">        fd: os.fd_t,</span>
<span class="line" id="L509">        op: <span class="tok-type">u32</span>,</span>
<span class="line" id="L510">        ev: ?*linux.epoll_event,</span>
<span class="line" id="L511">    ) !*linux.io_uring_sqe {</span>
<span class="line" id="L512">        <span class="tok-kw">const</span> sqe = <span class="tok-kw">try</span> self.get_sqe();</span>
<span class="line" id="L513">        io_uring_prep_epoll_ctl(sqe, epfd, fd, op, ev);</span>
<span class="line" id="L514">        sqe.user_data = user_data;</span>
<span class="line" id="L515">        <span class="tok-kw">return</span> sqe;</span>
<span class="line" id="L516">    }</span>
<span class="line" id="L517"></span>
<span class="line" id="L518">    <span class="tok-comment">/// Used to select how the recv call should be handled.</span></span>
<span class="line" id="L519">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> RecvBuffer = <span class="tok-kw">union</span>(<span class="tok-kw">enum</span>) {</span>
<span class="line" id="L520">        <span class="tok-comment">/// io_uring will recv directly into this buffer</span></span>
<span class="line" id="L521">        buffer: []<span class="tok-type">u8</span>,</span>
<span class="line" id="L522"></span>
<span class="line" id="L523">        <span class="tok-comment">/// io_uring will select a buffer that has previously been provided with `provide_buffers`.</span></span>
<span class="line" id="L524">        <span class="tok-comment">/// The buffer group referenced by `group_id` must contain at least one buffer for the recv call to work.</span></span>
<span class="line" id="L525">        <span class="tok-comment">/// `len` controls the number of bytes to read into the selected buffer.</span></span>
<span class="line" id="L526">        buffer_selection: <span class="tok-kw">struct</span> {</span>
<span class="line" id="L527">            group_id: <span class="tok-type">u16</span>,</span>
<span class="line" id="L528">            len: <span class="tok-type">usize</span>,</span>
<span class="line" id="L529">        },</span>
<span class="line" id="L530">    };</span>
<span class="line" id="L531"></span>
<span class="line" id="L532">    <span class="tok-comment">/// Queues (but does not submit) an SQE to perform a `recv(2)`.</span></span>
<span class="line" id="L533">    <span class="tok-comment">/// Returns a pointer to the SQE.</span></span>
<span class="line" id="L534">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">recv</span>(</span>
<span class="line" id="L535">        self: *IO_Uring,</span>
<span class="line" id="L536">        user_data: <span class="tok-type">u64</span>,</span>
<span class="line" id="L537">        fd: os.fd_t,</span>
<span class="line" id="L538">        buffer: RecvBuffer,</span>
<span class="line" id="L539">        flags: <span class="tok-type">u32</span>,</span>
<span class="line" id="L540">    ) !*linux.io_uring_sqe {</span>
<span class="line" id="L541">        <span class="tok-kw">const</span> sqe = <span class="tok-kw">try</span> self.get_sqe();</span>
<span class="line" id="L542">        <span class="tok-kw">switch</span> (buffer) {</span>
<span class="line" id="L543">            .buffer =&gt; |slice| io_uring_prep_recv(sqe, fd, slice, flags),</span>
<span class="line" id="L544">            .buffer_selection =&gt; |selection| {</span>
<span class="line" id="L545">                io_uring_prep_rw(.RECV, sqe, fd, <span class="tok-number">0</span>, selection.len, <span class="tok-number">0</span>);</span>
<span class="line" id="L546">                sqe.rw_flags = flags;</span>
<span class="line" id="L547">                sqe.flags |= linux.IOSQE_BUFFER_SELECT;</span>
<span class="line" id="L548">                sqe.buf_index = selection.group_id;</span>
<span class="line" id="L549">            },</span>
<span class="line" id="L550">        }</span>
<span class="line" id="L551">        sqe.user_data = user_data;</span>
<span class="line" id="L552">        <span class="tok-kw">return</span> sqe;</span>
<span class="line" id="L553">    }</span>
<span class="line" id="L554"></span>
<span class="line" id="L555">    <span class="tok-comment">/// Queues (but does not submit) an SQE to perform a `send(2)`.</span></span>
<span class="line" id="L556">    <span class="tok-comment">/// Returns a pointer to the SQE.</span></span>
<span class="line" id="L557">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">send</span>(</span>
<span class="line" id="L558">        self: *IO_Uring,</span>
<span class="line" id="L559">        user_data: <span class="tok-type">u64</span>,</span>
<span class="line" id="L560">        fd: os.fd_t,</span>
<span class="line" id="L561">        buffer: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L562">        flags: <span class="tok-type">u32</span>,</span>
<span class="line" id="L563">    ) !*linux.io_uring_sqe {</span>
<span class="line" id="L564">        <span class="tok-kw">const</span> sqe = <span class="tok-kw">try</span> self.get_sqe();</span>
<span class="line" id="L565">        io_uring_prep_send(sqe, fd, buffer, flags);</span>
<span class="line" id="L566">        sqe.user_data = user_data;</span>
<span class="line" id="L567">        <span class="tok-kw">return</span> sqe;</span>
<span class="line" id="L568">    }</span>
<span class="line" id="L569"></span>
<span class="line" id="L570">    <span class="tok-comment">/// Queues (but does not submit) an SQE to perform a `recvmsg(2)`.</span></span>
<span class="line" id="L571">    <span class="tok-comment">/// Returns a pointer to the SQE.</span></span>
<span class="line" id="L572">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">recvmsg</span>(</span>
<span class="line" id="L573">        self: *IO_Uring,</span>
<span class="line" id="L574">        user_data: <span class="tok-type">u64</span>,</span>
<span class="line" id="L575">        fd: os.fd_t,</span>
<span class="line" id="L576">        msg: *os.msghdr,</span>
<span class="line" id="L577">        flags: <span class="tok-type">u32</span>,</span>
<span class="line" id="L578">    ) !*linux.io_uring_sqe {</span>
<span class="line" id="L579">        <span class="tok-kw">const</span> sqe = <span class="tok-kw">try</span> self.get_sqe();</span>
<span class="line" id="L580">        io_uring_prep_recvmsg(sqe, fd, msg, flags);</span>
<span class="line" id="L581">        sqe.user_data = user_data;</span>
<span class="line" id="L582">        <span class="tok-kw">return</span> sqe;</span>
<span class="line" id="L583">    }</span>
<span class="line" id="L584"></span>
<span class="line" id="L585">    <span class="tok-comment">/// Queues (but does not submit) an SQE to perform a `sendmsg(2)`.</span></span>
<span class="line" id="L586">    <span class="tok-comment">/// Returns a pointer to the SQE.</span></span>
<span class="line" id="L587">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">sendmsg</span>(</span>
<span class="line" id="L588">        self: *IO_Uring,</span>
<span class="line" id="L589">        user_data: <span class="tok-type">u64</span>,</span>
<span class="line" id="L590">        fd: os.fd_t,</span>
<span class="line" id="L591">        msg: *<span class="tok-kw">const</span> os.msghdr_const,</span>
<span class="line" id="L592">        flags: <span class="tok-type">u32</span>,</span>
<span class="line" id="L593">    ) !*linux.io_uring_sqe {</span>
<span class="line" id="L594">        <span class="tok-kw">const</span> sqe = <span class="tok-kw">try</span> self.get_sqe();</span>
<span class="line" id="L595">        io_uring_prep_sendmsg(sqe, fd, msg, flags);</span>
<span class="line" id="L596">        sqe.user_data = user_data;</span>
<span class="line" id="L597">        <span class="tok-kw">return</span> sqe;</span>
<span class="line" id="L598">    }</span>
<span class="line" id="L599"></span>
<span class="line" id="L600">    <span class="tok-comment">/// Queues (but does not submit) an SQE to perform an `openat(2)`.</span></span>
<span class="line" id="L601">    <span class="tok-comment">/// Returns a pointer to the SQE.</span></span>
<span class="line" id="L602">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">openat</span>(</span>
<span class="line" id="L603">        self: *IO_Uring,</span>
<span class="line" id="L604">        user_data: <span class="tok-type">u64</span>,</span>
<span class="line" id="L605">        fd: os.fd_t,</span>
<span class="line" id="L606">        path: [*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L607">        flags: <span class="tok-type">u32</span>,</span>
<span class="line" id="L608">        mode: os.mode_t,</span>
<span class="line" id="L609">    ) !*linux.io_uring_sqe {</span>
<span class="line" id="L610">        <span class="tok-kw">const</span> sqe = <span class="tok-kw">try</span> self.get_sqe();</span>
<span class="line" id="L611">        io_uring_prep_openat(sqe, fd, path, flags, mode);</span>
<span class="line" id="L612">        sqe.user_data = user_data;</span>
<span class="line" id="L613">        <span class="tok-kw">return</span> sqe;</span>
<span class="line" id="L614">    }</span>
<span class="line" id="L615"></span>
<span class="line" id="L616">    <span class="tok-comment">/// Queues (but does not submit) an SQE to perform a `close(2)`.</span></span>
<span class="line" id="L617">    <span class="tok-comment">/// Returns a pointer to the SQE.</span></span>
<span class="line" id="L618">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">close</span>(self: *IO_Uring, user_data: <span class="tok-type">u64</span>, fd: os.fd_t) !*linux.io_uring_sqe {</span>
<span class="line" id="L619">        <span class="tok-kw">const</span> sqe = <span class="tok-kw">try</span> self.get_sqe();</span>
<span class="line" id="L620">        io_uring_prep_close(sqe, fd);</span>
<span class="line" id="L621">        sqe.user_data = user_data;</span>
<span class="line" id="L622">        <span class="tok-kw">return</span> sqe;</span>
<span class="line" id="L623">    }</span>
<span class="line" id="L624"></span>
<span class="line" id="L625">    <span class="tok-comment">/// Queues (but does not submit) an SQE to register a timeout operation.</span></span>
<span class="line" id="L626">    <span class="tok-comment">/// Returns a pointer to the SQE.</span></span>
<span class="line" id="L627">    <span class="tok-comment">///</span></span>
<span class="line" id="L628">    <span class="tok-comment">/// The timeout will complete when either the timeout expires, or after the specified number of</span></span>
<span class="line" id="L629">    <span class="tok-comment">/// events complete (if `count` is greater than `0`).</span></span>
<span class="line" id="L630">    <span class="tok-comment">///</span></span>
<span class="line" id="L631">    <span class="tok-comment">/// `flags` may be `0` for a relative timeout, or `IORING_TIMEOUT_ABS` for an absolute timeout.</span></span>
<span class="line" id="L632">    <span class="tok-comment">///</span></span>
<span class="line" id="L633">    <span class="tok-comment">/// The completion event result will be `-ETIME` if the timeout completed through expiration,</span></span>
<span class="line" id="L634">    <span class="tok-comment">/// `0` if the timeout completed after the specified number of events, or `-ECANCELED` if the</span></span>
<span class="line" id="L635">    <span class="tok-comment">/// timeout was removed before it expired.</span></span>
<span class="line" id="L636">    <span class="tok-comment">///</span></span>
<span class="line" id="L637">    <span class="tok-comment">/// io_uring timeouts use the `CLOCK.MONOTONIC` clock source.</span></span>
<span class="line" id="L638">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">timeout</span>(</span>
<span class="line" id="L639">        self: *IO_Uring,</span>
<span class="line" id="L640">        user_data: <span class="tok-type">u64</span>,</span>
<span class="line" id="L641">        ts: *<span class="tok-kw">const</span> os.linux.kernel_timespec,</span>
<span class="line" id="L642">        count: <span class="tok-type">u32</span>,</span>
<span class="line" id="L643">        flags: <span class="tok-type">u32</span>,</span>
<span class="line" id="L644">    ) !*linux.io_uring_sqe {</span>
<span class="line" id="L645">        <span class="tok-kw">const</span> sqe = <span class="tok-kw">try</span> self.get_sqe();</span>
<span class="line" id="L646">        io_uring_prep_timeout(sqe, ts, count, flags);</span>
<span class="line" id="L647">        sqe.user_data = user_data;</span>
<span class="line" id="L648">        <span class="tok-kw">return</span> sqe;</span>
<span class="line" id="L649">    }</span>
<span class="line" id="L650"></span>
<span class="line" id="L651">    <span class="tok-comment">/// Queues (but does not submit) an SQE to remove an existing timeout operation.</span></span>
<span class="line" id="L652">    <span class="tok-comment">/// Returns a pointer to the SQE.</span></span>
<span class="line" id="L653">    <span class="tok-comment">///</span></span>
<span class="line" id="L654">    <span class="tok-comment">/// The timeout is identified by its `user_data`.</span></span>
<span class="line" id="L655">    <span class="tok-comment">///</span></span>
<span class="line" id="L656">    <span class="tok-comment">/// The completion event result will be `0` if the timeout was found and cancelled successfully,</span></span>
<span class="line" id="L657">    <span class="tok-comment">/// `-EBUSY` if the timeout was found but expiration was already in progress, or</span></span>
<span class="line" id="L658">    <span class="tok-comment">/// `-ENOENT` if the timeout was not found.</span></span>
<span class="line" id="L659">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">timeout_remove</span>(</span>
<span class="line" id="L660">        self: *IO_Uring,</span>
<span class="line" id="L661">        user_data: <span class="tok-type">u64</span>,</span>
<span class="line" id="L662">        timeout_user_data: <span class="tok-type">u64</span>,</span>
<span class="line" id="L663">        flags: <span class="tok-type">u32</span>,</span>
<span class="line" id="L664">    ) !*linux.io_uring_sqe {</span>
<span class="line" id="L665">        <span class="tok-kw">const</span> sqe = <span class="tok-kw">try</span> self.get_sqe();</span>
<span class="line" id="L666">        io_uring_prep_timeout_remove(sqe, timeout_user_data, flags);</span>
<span class="line" id="L667">        sqe.user_data = user_data;</span>
<span class="line" id="L668">        <span class="tok-kw">return</span> sqe;</span>
<span class="line" id="L669">    }</span>
<span class="line" id="L670"></span>
<span class="line" id="L671">    <span class="tok-comment">/// Queues (but does not submit) an SQE to add a link timeout operation.</span></span>
<span class="line" id="L672">    <span class="tok-comment">/// Returns a pointer to the SQE.</span></span>
<span class="line" id="L673">    <span class="tok-comment">///</span></span>
<span class="line" id="L674">    <span class="tok-comment">/// You need to set linux.IOSQE_IO_LINK to flags of the target operation</span></span>
<span class="line" id="L675">    <span class="tok-comment">/// and then call this method right after the target operation.</span></span>
<span class="line" id="L676">    <span class="tok-comment">/// See https://lwn.net/Articles/803932/ for detail.</span></span>
<span class="line" id="L677">    <span class="tok-comment">///</span></span>
<span class="line" id="L678">    <span class="tok-comment">/// If the dependent request finishes before the linked timeout, the timeout</span></span>
<span class="line" id="L679">    <span class="tok-comment">/// is canceled. If the timeout finishes before the dependent request, the</span></span>
<span class="line" id="L680">    <span class="tok-comment">/// dependent request will be canceled.</span></span>
<span class="line" id="L681">    <span class="tok-comment">///</span></span>
<span class="line" id="L682">    <span class="tok-comment">/// The completion event result of the link_timeout will be</span></span>
<span class="line" id="L683">    <span class="tok-comment">/// `-ETIME` if the timeout finishes before the dependent request</span></span>
<span class="line" id="L684">    <span class="tok-comment">/// (in this case, the completion event result of the dependent request will</span></span>
<span class="line" id="L685">    <span class="tok-comment">/// be `-ECANCELED`), or</span></span>
<span class="line" id="L686">    <span class="tok-comment">/// `-EALREADY` if the dependent request finishes before the linked timeout.</span></span>
<span class="line" id="L687">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">link_timeout</span>(</span>
<span class="line" id="L688">        self: *IO_Uring,</span>
<span class="line" id="L689">        user_data: <span class="tok-type">u64</span>,</span>
<span class="line" id="L690">        ts: *<span class="tok-kw">const</span> os.linux.kernel_timespec,</span>
<span class="line" id="L691">        flags: <span class="tok-type">u32</span>,</span>
<span class="line" id="L692">    ) !*linux.io_uring_sqe {</span>
<span class="line" id="L693">        <span class="tok-kw">const</span> sqe = <span class="tok-kw">try</span> self.get_sqe();</span>
<span class="line" id="L694">        io_uring_prep_link_timeout(sqe, ts, flags);</span>
<span class="line" id="L695">        sqe.user_data = user_data;</span>
<span class="line" id="L696">        <span class="tok-kw">return</span> sqe;</span>
<span class="line" id="L697">    }</span>
<span class="line" id="L698"></span>
<span class="line" id="L699">    <span class="tok-comment">/// Queues (but does not submit) an SQE to perform a `poll(2)`.</span></span>
<span class="line" id="L700">    <span class="tok-comment">/// Returns a pointer to the SQE.</span></span>
<span class="line" id="L701">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">poll_add</span>(</span>
<span class="line" id="L702">        self: *IO_Uring,</span>
<span class="line" id="L703">        user_data: <span class="tok-type">u64</span>,</span>
<span class="line" id="L704">        fd: os.fd_t,</span>
<span class="line" id="L705">        poll_mask: <span class="tok-type">u32</span>,</span>
<span class="line" id="L706">    ) !*linux.io_uring_sqe {</span>
<span class="line" id="L707">        <span class="tok-kw">const</span> sqe = <span class="tok-kw">try</span> self.get_sqe();</span>
<span class="line" id="L708">        io_uring_prep_poll_add(sqe, fd, poll_mask);</span>
<span class="line" id="L709">        sqe.user_data = user_data;</span>
<span class="line" id="L710">        <span class="tok-kw">return</span> sqe;</span>
<span class="line" id="L711">    }</span>
<span class="line" id="L712"></span>
<span class="line" id="L713">    <span class="tok-comment">/// Queues (but does not submit) an SQE to remove an existing poll operation.</span></span>
<span class="line" id="L714">    <span class="tok-comment">/// Returns a pointer to the SQE.</span></span>
<span class="line" id="L715">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">poll_remove</span>(</span>
<span class="line" id="L716">        self: *IO_Uring,</span>
<span class="line" id="L717">        user_data: <span class="tok-type">u64</span>,</span>
<span class="line" id="L718">        target_user_data: <span class="tok-type">u64</span>,</span>
<span class="line" id="L719">    ) !*linux.io_uring_sqe {</span>
<span class="line" id="L720">        <span class="tok-kw">const</span> sqe = <span class="tok-kw">try</span> self.get_sqe();</span>
<span class="line" id="L721">        io_uring_prep_poll_remove(sqe, target_user_data);</span>
<span class="line" id="L722">        sqe.user_data = user_data;</span>
<span class="line" id="L723">        <span class="tok-kw">return</span> sqe;</span>
<span class="line" id="L724">    }</span>
<span class="line" id="L725"></span>
<span class="line" id="L726">    <span class="tok-comment">/// Queues (but does not submit) an SQE to update the user data of an existing poll</span></span>
<span class="line" id="L727">    <span class="tok-comment">/// operation. Returns a pointer to the SQE.</span></span>
<span class="line" id="L728">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">poll_update</span>(</span>
<span class="line" id="L729">        self: *IO_Uring,</span>
<span class="line" id="L730">        user_data: <span class="tok-type">u64</span>,</span>
<span class="line" id="L731">        old_user_data: <span class="tok-type">u64</span>,</span>
<span class="line" id="L732">        new_user_data: <span class="tok-type">u64</span>,</span>
<span class="line" id="L733">        poll_mask: <span class="tok-type">u32</span>,</span>
<span class="line" id="L734">        flags: <span class="tok-type">u32</span>,</span>
<span class="line" id="L735">    ) !*linux.io_uring_sqe {</span>
<span class="line" id="L736">        <span class="tok-kw">const</span> sqe = <span class="tok-kw">try</span> self.get_sqe();</span>
<span class="line" id="L737">        io_uring_prep_poll_update(sqe, old_user_data, new_user_data, poll_mask, flags);</span>
<span class="line" id="L738">        sqe.user_data = user_data;</span>
<span class="line" id="L739">        <span class="tok-kw">return</span> sqe;</span>
<span class="line" id="L740">    }</span>
<span class="line" id="L741"></span>
<span class="line" id="L742">    <span class="tok-comment">/// Queues (but does not submit) an SQE to perform an `fallocate(2)`.</span></span>
<span class="line" id="L743">    <span class="tok-comment">/// Returns a pointer to the SQE.</span></span>
<span class="line" id="L744">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">fallocate</span>(</span>
<span class="line" id="L745">        self: *IO_Uring,</span>
<span class="line" id="L746">        user_data: <span class="tok-type">u64</span>,</span>
<span class="line" id="L747">        fd: os.fd_t,</span>
<span class="line" id="L748">        mode: <span class="tok-type">i32</span>,</span>
<span class="line" id="L749">        offset: <span class="tok-type">u64</span>,</span>
<span class="line" id="L750">        len: <span class="tok-type">u64</span>,</span>
<span class="line" id="L751">    ) !*linux.io_uring_sqe {</span>
<span class="line" id="L752">        <span class="tok-kw">const</span> sqe = <span class="tok-kw">try</span> self.get_sqe();</span>
<span class="line" id="L753">        io_uring_prep_fallocate(sqe, fd, mode, offset, len);</span>
<span class="line" id="L754">        sqe.user_data = user_data;</span>
<span class="line" id="L755">        <span class="tok-kw">return</span> sqe;</span>
<span class="line" id="L756">    }</span>
<span class="line" id="L757"></span>
<span class="line" id="L758">    <span class="tok-comment">/// Queues (but does not submit) an SQE to perform an `statx(2)`.</span></span>
<span class="line" id="L759">    <span class="tok-comment">/// Returns a pointer to the SQE.</span></span>
<span class="line" id="L760">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">statx</span>(</span>
<span class="line" id="L761">        self: *IO_Uring,</span>
<span class="line" id="L762">        user_data: <span class="tok-type">u64</span>,</span>
<span class="line" id="L763">        fd: os.fd_t,</span>
<span class="line" id="L764">        path: [:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L765">        flags: <span class="tok-type">u32</span>,</span>
<span class="line" id="L766">        mask: <span class="tok-type">u32</span>,</span>
<span class="line" id="L767">        buf: *linux.Statx,</span>
<span class="line" id="L768">    ) !*linux.io_uring_sqe {</span>
<span class="line" id="L769">        <span class="tok-kw">const</span> sqe = <span class="tok-kw">try</span> self.get_sqe();</span>
<span class="line" id="L770">        io_uring_prep_statx(sqe, fd, path, flags, mask, buf);</span>
<span class="line" id="L771">        sqe.user_data = user_data;</span>
<span class="line" id="L772">        <span class="tok-kw">return</span> sqe;</span>
<span class="line" id="L773">    }</span>
<span class="line" id="L774"></span>
<span class="line" id="L775">    <span class="tok-comment">/// Queues (but does not submit) an SQE to remove an existing operation.</span></span>
<span class="line" id="L776">    <span class="tok-comment">/// Returns a pointer to the SQE.</span></span>
<span class="line" id="L777">    <span class="tok-comment">///</span></span>
<span class="line" id="L778">    <span class="tok-comment">/// The operation is identified by its `user_data`.</span></span>
<span class="line" id="L779">    <span class="tok-comment">///</span></span>
<span class="line" id="L780">    <span class="tok-comment">/// The completion event result will be `0` if the operation was found and cancelled successfully,</span></span>
<span class="line" id="L781">    <span class="tok-comment">/// `-EALREADY` if the operation was found but was already in progress, or</span></span>
<span class="line" id="L782">    <span class="tok-comment">/// `-ENOENT` if the operation was not found.</span></span>
<span class="line" id="L783">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">cancel</span>(</span>
<span class="line" id="L784">        self: *IO_Uring,</span>
<span class="line" id="L785">        user_data: <span class="tok-type">u64</span>,</span>
<span class="line" id="L786">        cancel_user_data: <span class="tok-type">u64</span>,</span>
<span class="line" id="L787">        flags: <span class="tok-type">u32</span>,</span>
<span class="line" id="L788">    ) !*linux.io_uring_sqe {</span>
<span class="line" id="L789">        <span class="tok-kw">const</span> sqe = <span class="tok-kw">try</span> self.get_sqe();</span>
<span class="line" id="L790">        io_uring_prep_cancel(sqe, cancel_user_data, flags);</span>
<span class="line" id="L791">        sqe.user_data = user_data;</span>
<span class="line" id="L792">        <span class="tok-kw">return</span> sqe;</span>
<span class="line" id="L793">    }</span>
<span class="line" id="L794"></span>
<span class="line" id="L795">    <span class="tok-comment">/// Queues (but does not submit) an SQE to perform a `shutdown(2)`.</span></span>
<span class="line" id="L796">    <span class="tok-comment">/// Returns a pointer to the SQE.</span></span>
<span class="line" id="L797">    <span class="tok-comment">///</span></span>
<span class="line" id="L798">    <span class="tok-comment">/// The operation is identified by its `user_data`.</span></span>
<span class="line" id="L799">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">shutdown</span>(</span>
<span class="line" id="L800">        self: *IO_Uring,</span>
<span class="line" id="L801">        user_data: <span class="tok-type">u64</span>,</span>
<span class="line" id="L802">        sockfd: os.socket_t,</span>
<span class="line" id="L803">        how: <span class="tok-type">u32</span>,</span>
<span class="line" id="L804">    ) !*linux.io_uring_sqe {</span>
<span class="line" id="L805">        <span class="tok-kw">const</span> sqe = <span class="tok-kw">try</span> self.get_sqe();</span>
<span class="line" id="L806">        io_uring_prep_shutdown(sqe, sockfd, how);</span>
<span class="line" id="L807">        sqe.user_data = user_data;</span>
<span class="line" id="L808">        <span class="tok-kw">return</span> sqe;</span>
<span class="line" id="L809">    }</span>
<span class="line" id="L810"></span>
<span class="line" id="L811">    <span class="tok-comment">/// Queues (but does not submit) an SQE to perform a `renameat2(2)`.</span></span>
<span class="line" id="L812">    <span class="tok-comment">/// Returns a pointer to the SQE.</span></span>
<span class="line" id="L813">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">renameat</span>(</span>
<span class="line" id="L814">        self: *IO_Uring,</span>
<span class="line" id="L815">        user_data: <span class="tok-type">u64</span>,</span>
<span class="line" id="L816">        old_dir_fd: os.fd_t,</span>
<span class="line" id="L817">        old_path: [*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L818">        new_dir_fd: os.fd_t,</span>
<span class="line" id="L819">        new_path: [*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L820">        flags: <span class="tok-type">u32</span>,</span>
<span class="line" id="L821">    ) !*linux.io_uring_sqe {</span>
<span class="line" id="L822">        <span class="tok-kw">const</span> sqe = <span class="tok-kw">try</span> self.get_sqe();</span>
<span class="line" id="L823">        io_uring_prep_renameat(sqe, old_dir_fd, old_path, new_dir_fd, new_path, flags);</span>
<span class="line" id="L824">        sqe.user_data = user_data;</span>
<span class="line" id="L825">        <span class="tok-kw">return</span> sqe;</span>
<span class="line" id="L826">    }</span>
<span class="line" id="L827"></span>
<span class="line" id="L828">    <span class="tok-comment">/// Queues (but does not submit) an SQE to perform a `unlinkat(2)`.</span></span>
<span class="line" id="L829">    <span class="tok-comment">/// Returns a pointer to the SQE.</span></span>
<span class="line" id="L830">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">unlinkat</span>(</span>
<span class="line" id="L831">        self: *IO_Uring,</span>
<span class="line" id="L832">        user_data: <span class="tok-type">u64</span>,</span>
<span class="line" id="L833">        dir_fd: os.fd_t,</span>
<span class="line" id="L834">        path: [*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L835">        flags: <span class="tok-type">u32</span>,</span>
<span class="line" id="L836">    ) !*linux.io_uring_sqe {</span>
<span class="line" id="L837">        <span class="tok-kw">const</span> sqe = <span class="tok-kw">try</span> self.get_sqe();</span>
<span class="line" id="L838">        io_uring_prep_unlinkat(sqe, dir_fd, path, flags);</span>
<span class="line" id="L839">        sqe.user_data = user_data;</span>
<span class="line" id="L840">        <span class="tok-kw">return</span> sqe;</span>
<span class="line" id="L841">    }</span>
<span class="line" id="L842"></span>
<span class="line" id="L843">    <span class="tok-comment">/// Queues (but does not submit) an SQE to perform a `mkdirat(2)`.</span></span>
<span class="line" id="L844">    <span class="tok-comment">/// Returns a pointer to the SQE.</span></span>
<span class="line" id="L845">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">mkdirat</span>(</span>
<span class="line" id="L846">        self: *IO_Uring,</span>
<span class="line" id="L847">        user_data: <span class="tok-type">u64</span>,</span>
<span class="line" id="L848">        dir_fd: os.fd_t,</span>
<span class="line" id="L849">        path: [*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L850">        mode: os.mode_t,</span>
<span class="line" id="L851">    ) !*linux.io_uring_sqe {</span>
<span class="line" id="L852">        <span class="tok-kw">const</span> sqe = <span class="tok-kw">try</span> self.get_sqe();</span>
<span class="line" id="L853">        io_uring_prep_mkdirat(sqe, dir_fd, path, mode);</span>
<span class="line" id="L854">        sqe.user_data = user_data;</span>
<span class="line" id="L855">        <span class="tok-kw">return</span> sqe;</span>
<span class="line" id="L856">    }</span>
<span class="line" id="L857"></span>
<span class="line" id="L858">    <span class="tok-comment">/// Queues (but does not submit) an SQE to perform a `symlinkat(2)`.</span></span>
<span class="line" id="L859">    <span class="tok-comment">/// Returns a pointer to the SQE.</span></span>
<span class="line" id="L860">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">symlinkat</span>(</span>
<span class="line" id="L861">        self: *IO_Uring,</span>
<span class="line" id="L862">        user_data: <span class="tok-type">u64</span>,</span>
<span class="line" id="L863">        target: [*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L864">        new_dir_fd: os.fd_t,</span>
<span class="line" id="L865">        link_path: [*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L866">    ) !*linux.io_uring_sqe {</span>
<span class="line" id="L867">        <span class="tok-kw">const</span> sqe = <span class="tok-kw">try</span> self.get_sqe();</span>
<span class="line" id="L868">        io_uring_prep_symlinkat(sqe, target, new_dir_fd, link_path);</span>
<span class="line" id="L869">        sqe.user_data = user_data;</span>
<span class="line" id="L870">        <span class="tok-kw">return</span> sqe;</span>
<span class="line" id="L871">    }</span>
<span class="line" id="L872"></span>
<span class="line" id="L873">    <span class="tok-comment">/// Queues (but does not submit) an SQE to perform a `linkat(2)`.</span></span>
<span class="line" id="L874">    <span class="tok-comment">/// Returns a pointer to the SQE.</span></span>
<span class="line" id="L875">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">linkat</span>(</span>
<span class="line" id="L876">        self: *IO_Uring,</span>
<span class="line" id="L877">        user_data: <span class="tok-type">u64</span>,</span>
<span class="line" id="L878">        old_dir_fd: os.fd_t,</span>
<span class="line" id="L879">        old_path: [*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L880">        new_dir_fd: os.fd_t,</span>
<span class="line" id="L881">        new_path: [*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L882">        flags: <span class="tok-type">u32</span>,</span>
<span class="line" id="L883">    ) !*linux.io_uring_sqe {</span>
<span class="line" id="L884">        <span class="tok-kw">const</span> sqe = <span class="tok-kw">try</span> self.get_sqe();</span>
<span class="line" id="L885">        io_uring_prep_linkat(sqe, old_dir_fd, old_path, new_dir_fd, new_path, flags);</span>
<span class="line" id="L886">        sqe.user_data = user_data;</span>
<span class="line" id="L887">        <span class="tok-kw">return</span> sqe;</span>
<span class="line" id="L888">    }</span>
<span class="line" id="L889"></span>
<span class="line" id="L890">    <span class="tok-comment">/// Queues (but does not submit) an SQE to provide a group of buffers used for commands that read/receive data.</span></span>
<span class="line" id="L891">    <span class="tok-comment">/// Returns a pointer to the SQE.</span></span>
<span class="line" id="L892">    <span class="tok-comment">///</span></span>
<span class="line" id="L893">    <span class="tok-comment">/// Provided buffers can be used in `read`, `recv` or `recvmsg` commands via .buffer_selection.</span></span>
<span class="line" id="L894">    <span class="tok-comment">///</span></span>
<span class="line" id="L895">    <span class="tok-comment">/// The kernel expects a contiguous block of memory of size (buffers_count * buffer_size).</span></span>
<span class="line" id="L896">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">provide_buffers</span>(</span>
<span class="line" id="L897">        self: *IO_Uring,</span>
<span class="line" id="L898">        user_data: <span class="tok-type">u64</span>,</span>
<span class="line" id="L899">        buffers: [*]<span class="tok-type">u8</span>,</span>
<span class="line" id="L900">        buffers_count: <span class="tok-type">usize</span>,</span>
<span class="line" id="L901">        buffer_size: <span class="tok-type">usize</span>,</span>
<span class="line" id="L902">        group_id: <span class="tok-type">usize</span>,</span>
<span class="line" id="L903">        buffer_id: <span class="tok-type">usize</span>,</span>
<span class="line" id="L904">    ) !*linux.io_uring_sqe {</span>
<span class="line" id="L905">        <span class="tok-kw">const</span> sqe = <span class="tok-kw">try</span> self.get_sqe();</span>
<span class="line" id="L906">        io_uring_prep_provide_buffers(sqe, buffers, buffers_count, buffer_size, group_id, buffer_id);</span>
<span class="line" id="L907">        sqe.user_data = user_data;</span>
<span class="line" id="L908">        <span class="tok-kw">return</span> sqe;</span>
<span class="line" id="L909">    }</span>
<span class="line" id="L910"></span>
<span class="line" id="L911">    <span class="tok-comment">/// Queues (but does not submit) an SQE to remove a group of provided buffers.</span></span>
<span class="line" id="L912">    <span class="tok-comment">/// Returns a pointer to the SQE.</span></span>
<span class="line" id="L913">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">remove_buffers</span>(</span>
<span class="line" id="L914">        self: *IO_Uring,</span>
<span class="line" id="L915">        user_data: <span class="tok-type">u64</span>,</span>
<span class="line" id="L916">        buffers_count: <span class="tok-type">usize</span>,</span>
<span class="line" id="L917">        group_id: <span class="tok-type">usize</span>,</span>
<span class="line" id="L918">    ) !*linux.io_uring_sqe {</span>
<span class="line" id="L919">        <span class="tok-kw">const</span> sqe = <span class="tok-kw">try</span> self.get_sqe();</span>
<span class="line" id="L920">        io_uring_prep_remove_buffers(sqe, buffers_count, group_id);</span>
<span class="line" id="L921">        sqe.user_data = user_data;</span>
<span class="line" id="L922">        <span class="tok-kw">return</span> sqe;</span>
<span class="line" id="L923">    }</span>
<span class="line" id="L924"></span>
<span class="line" id="L925">    <span class="tok-comment">/// Registers an array of file descriptors.</span></span>
<span class="line" id="L926">    <span class="tok-comment">/// Every time a file descriptor is put in an SQE and submitted to the kernel, the kernel must</span></span>
<span class="line" id="L927">    <span class="tok-comment">/// retrieve a reference to the file, and once I/O has completed the file reference must be</span></span>
<span class="line" id="L928">    <span class="tok-comment">/// dropped. The atomic nature of this file reference can be a slowdown for high IOPS workloads.</span></span>
<span class="line" id="L929">    <span class="tok-comment">/// This slowdown can be avoided by pre-registering file descriptors.</span></span>
<span class="line" id="L930">    <span class="tok-comment">/// To refer to a registered file descriptor, IOSQE_FIXED_FILE must be set in the SQE's flags,</span></span>
<span class="line" id="L931">    <span class="tok-comment">/// and the SQE's fd must be set to the index of the file descriptor in the registered array.</span></span>
<span class="line" id="L932">    <span class="tok-comment">/// Registering file descriptors will wait for the ring to idle.</span></span>
<span class="line" id="L933">    <span class="tok-comment">/// Files are automatically unregistered by the kernel when the ring is torn down.</span></span>
<span class="line" id="L934">    <span class="tok-comment">/// An application need unregister only if it wants to register a new array of file descriptors.</span></span>
<span class="line" id="L935">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">register_files</span>(self: *IO_Uring, fds: []<span class="tok-kw">const</span> os.fd_t) !<span class="tok-type">void</span> {</span>
<span class="line" id="L936">        assert(self.fd &gt;= <span class="tok-number">0</span>);</span>
<span class="line" id="L937">        <span class="tok-kw">const</span> res = linux.io_uring_register(</span>
<span class="line" id="L938">            self.fd,</span>
<span class="line" id="L939">            .REGISTER_FILES,</span>
<span class="line" id="L940">            <span class="tok-builtin">@ptrCast</span>(*<span class="tok-kw">const</span> <span class="tok-type">anyopaque</span>, fds.ptr),</span>
<span class="line" id="L941">            <span class="tok-builtin">@intCast</span>(<span class="tok-type">u32</span>, fds.len),</span>
<span class="line" id="L942">        );</span>
<span class="line" id="L943">        <span class="tok-kw">try</span> handle_registration_result(res);</span>
<span class="line" id="L944">    }</span>
<span class="line" id="L945"></span>
<span class="line" id="L946">    <span class="tok-comment">/// Updates registered file descriptors.</span></span>
<span class="line" id="L947">    <span class="tok-comment">///</span></span>
<span class="line" id="L948">    <span class="tok-comment">/// Updates are applied starting at the provided offset in the original file descriptors slice.</span></span>
<span class="line" id="L949">    <span class="tok-comment">/// There are three kind of updates:</span></span>
<span class="line" id="L950">    <span class="tok-comment">/// * turning a sparse entry (where the fd is -1) into a real one</span></span>
<span class="line" id="L951">    <span class="tok-comment">/// * removing an existing entry (set the fd to -1)</span></span>
<span class="line" id="L952">    <span class="tok-comment">/// * replacing an existing entry with a new fd</span></span>
<span class="line" id="L953">    <span class="tok-comment">/// Adding new file descriptors must be done with `register_files`.</span></span>
<span class="line" id="L954">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">register_files_update</span>(self: *IO_Uring, offset: <span class="tok-type">u32</span>, fds: []<span class="tok-kw">const</span> os.fd_t) !<span class="tok-type">void</span> {</span>
<span class="line" id="L955">        assert(self.fd &gt;= <span class="tok-number">0</span>);</span>
<span class="line" id="L956"></span>
<span class="line" id="L957">        <span class="tok-kw">const</span> FilesUpdate = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L958">            offset: <span class="tok-type">u32</span>,</span>
<span class="line" id="L959">            resv: <span class="tok-type">u32</span>,</span>
<span class="line" id="L960">            fds: <span class="tok-type">u64</span> <span class="tok-kw">align</span>(<span class="tok-number">8</span>),</span>
<span class="line" id="L961">        };</span>
<span class="line" id="L962">        <span class="tok-kw">var</span> update = FilesUpdate{</span>
<span class="line" id="L963">            .offset = offset,</span>
<span class="line" id="L964">            .resv = <span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">0</span>),</span>
<span class="line" id="L965">            .fds = <span class="tok-builtin">@as</span>(<span class="tok-type">u64</span>, <span class="tok-builtin">@ptrToInt</span>(fds.ptr)),</span>
<span class="line" id="L966">        };</span>
<span class="line" id="L967"></span>
<span class="line" id="L968">        <span class="tok-kw">const</span> res = linux.io_uring_register(</span>
<span class="line" id="L969">            self.fd,</span>
<span class="line" id="L970">            .REGISTER_FILES_UPDATE,</span>
<span class="line" id="L971">            <span class="tok-builtin">@ptrCast</span>(*<span class="tok-kw">const</span> <span class="tok-type">anyopaque</span>, &amp;update),</span>
<span class="line" id="L972">            <span class="tok-builtin">@intCast</span>(<span class="tok-type">u32</span>, fds.len),</span>
<span class="line" id="L973">        );</span>
<span class="line" id="L974">        <span class="tok-kw">try</span> handle_registration_result(res);</span>
<span class="line" id="L975">    }</span>
<span class="line" id="L976"></span>
<span class="line" id="L977">    <span class="tok-comment">/// Registers the file descriptor for an eventfd that will be notified of completion events on</span></span>
<span class="line" id="L978">    <span class="tok-comment">///  an io_uring instance.</span></span>
<span class="line" id="L979">    <span class="tok-comment">/// Only a single a eventfd can be registered at any given point in time.</span></span>
<span class="line" id="L980">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">register_eventfd</span>(self: *IO_Uring, fd: os.fd_t) !<span class="tok-type">void</span> {</span>
<span class="line" id="L981">        assert(self.fd &gt;= <span class="tok-number">0</span>);</span>
<span class="line" id="L982">        <span class="tok-kw">const</span> res = linux.io_uring_register(</span>
<span class="line" id="L983">            self.fd,</span>
<span class="line" id="L984">            .REGISTER_EVENTFD,</span>
<span class="line" id="L985">            <span class="tok-builtin">@ptrCast</span>(*<span class="tok-kw">const</span> <span class="tok-type">anyopaque</span>, &amp;fd),</span>
<span class="line" id="L986">            <span class="tok-number">1</span>,</span>
<span class="line" id="L987">        );</span>
<span class="line" id="L988">        <span class="tok-kw">try</span> handle_registration_result(res);</span>
<span class="line" id="L989">    }</span>
<span class="line" id="L990"></span>
<span class="line" id="L991">    <span class="tok-comment">/// Registers the file descriptor for an eventfd that will be notified of completion events on</span></span>
<span class="line" id="L992">    <span class="tok-comment">/// an io_uring instance. Notifications are only posted for events that complete in an async manner.</span></span>
<span class="line" id="L993">    <span class="tok-comment">/// This means that events that complete inline while being submitted do not trigger a notification event.</span></span>
<span class="line" id="L994">    <span class="tok-comment">/// Only a single eventfd can be registered at any given point in time.</span></span>
<span class="line" id="L995">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">register_eventfd_async</span>(self: *IO_Uring, fd: os.fd_t) !<span class="tok-type">void</span> {</span>
<span class="line" id="L996">        assert(self.fd &gt;= <span class="tok-number">0</span>);</span>
<span class="line" id="L997">        <span class="tok-kw">const</span> res = linux.io_uring_register(</span>
<span class="line" id="L998">            self.fd,</span>
<span class="line" id="L999">            .REGISTER_EVENTFD_ASYNC,</span>
<span class="line" id="L1000">            <span class="tok-builtin">@ptrCast</span>(*<span class="tok-kw">const</span> <span class="tok-type">anyopaque</span>, &amp;fd),</span>
<span class="line" id="L1001">            <span class="tok-number">1</span>,</span>
<span class="line" id="L1002">        );</span>
<span class="line" id="L1003">        <span class="tok-kw">try</span> handle_registration_result(res);</span>
<span class="line" id="L1004">    }</span>
<span class="line" id="L1005"></span>
<span class="line" id="L1006">    <span class="tok-comment">/// Unregister the registered eventfd file descriptor.</span></span>
<span class="line" id="L1007">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">unregister_eventfd</span>(self: *IO_Uring) !<span class="tok-type">void</span> {</span>
<span class="line" id="L1008">        assert(self.fd &gt;= <span class="tok-number">0</span>);</span>
<span class="line" id="L1009">        <span class="tok-kw">const</span> res = linux.io_uring_register(</span>
<span class="line" id="L1010">            self.fd,</span>
<span class="line" id="L1011">            .UNREGISTER_EVENTFD,</span>
<span class="line" id="L1012">            <span class="tok-null">null</span>,</span>
<span class="line" id="L1013">            <span class="tok-number">0</span>,</span>
<span class="line" id="L1014">        );</span>
<span class="line" id="L1015">        <span class="tok-kw">try</span> handle_registration_result(res);</span>
<span class="line" id="L1016">    }</span>
<span class="line" id="L1017"></span>
<span class="line" id="L1018">    <span class="tok-comment">/// Registers an array of buffers for use with `read_fixed` and `write_fixed`.</span></span>
<span class="line" id="L1019">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">register_buffers</span>(self: *IO_Uring, buffers: []<span class="tok-kw">const</span> os.iovec) !<span class="tok-type">void</span> {</span>
<span class="line" id="L1020">        assert(self.fd &gt;= <span class="tok-number">0</span>);</span>
<span class="line" id="L1021">        <span class="tok-kw">const</span> res = linux.io_uring_register(</span>
<span class="line" id="L1022">            self.fd,</span>
<span class="line" id="L1023">            .REGISTER_BUFFERS,</span>
<span class="line" id="L1024">            buffers.ptr,</span>
<span class="line" id="L1025">            <span class="tok-builtin">@intCast</span>(<span class="tok-type">u32</span>, buffers.len),</span>
<span class="line" id="L1026">        );</span>
<span class="line" id="L1027">        <span class="tok-kw">try</span> handle_registration_result(res);</span>
<span class="line" id="L1028">    }</span>
<span class="line" id="L1029"></span>
<span class="line" id="L1030">    <span class="tok-comment">/// Unregister the registered buffers.</span></span>
<span class="line" id="L1031">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">unregister_buffers</span>(self: *IO_Uring) !<span class="tok-type">void</span> {</span>
<span class="line" id="L1032">        assert(self.fd &gt;= <span class="tok-number">0</span>);</span>
<span class="line" id="L1033">        <span class="tok-kw">const</span> res = linux.io_uring_register(self.fd, .UNREGISTER_BUFFERS, <span class="tok-null">null</span>, <span class="tok-number">0</span>);</span>
<span class="line" id="L1034">        <span class="tok-kw">switch</span> (linux.getErrno(res)) {</span>
<span class="line" id="L1035">            .SUCCESS =&gt; {},</span>
<span class="line" id="L1036">            .NXIO =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.BuffersNotRegistered,</span>
<span class="line" id="L1037">            <span class="tok-kw">else</span> =&gt; |errno| <span class="tok-kw">return</span> os.unexpectedErrno(errno),</span>
<span class="line" id="L1038">        }</span>
<span class="line" id="L1039">    }</span>
<span class="line" id="L1040"></span>
<span class="line" id="L1041">    <span class="tok-kw">fn</span> <span class="tok-fn">handle_registration_result</span>(res: <span class="tok-type">usize</span>) !<span class="tok-type">void</span> {</span>
<span class="line" id="L1042">        <span class="tok-kw">switch</span> (linux.getErrno(res)) {</span>
<span class="line" id="L1043">            .SUCCESS =&gt; {},</span>
<span class="line" id="L1044">            <span class="tok-comment">// One or more fds in the array are invalid, or the kernel does not support sparse sets:</span>
</span>
<span class="line" id="L1045">            .BADF =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.FileDescriptorInvalid,</span>
<span class="line" id="L1046">            .BUSY =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.FilesAlreadyRegistered,</span>
<span class="line" id="L1047">            .INVAL =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.FilesEmpty,</span>
<span class="line" id="L1048">            <span class="tok-comment">// Adding `nr_args` file references would exceed the maximum allowed number of files the</span>
</span>
<span class="line" id="L1049">            <span class="tok-comment">// user is allowed to have according to the per-user RLIMIT_NOFILE resource limit and</span>
</span>
<span class="line" id="L1050">            <span class="tok-comment">// the CAP_SYS_RESOURCE capability is not set, or `nr_args` exceeds the maximum allowed</span>
</span>
<span class="line" id="L1051">            <span class="tok-comment">// for a fixed file set (older kernels have a limit of 1024 files vs 64K files):</span>
</span>
<span class="line" id="L1052">            .MFILE =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.UserFdQuotaExceeded,</span>
<span class="line" id="L1053">            <span class="tok-comment">// Insufficient kernel resources, or the caller had a non-zero RLIMIT_MEMLOCK soft</span>
</span>
<span class="line" id="L1054">            <span class="tok-comment">// resource limit but tried to lock more memory than the limit permitted (not enforced</span>
</span>
<span class="line" id="L1055">            <span class="tok-comment">// when the process is privileged with CAP_IPC_LOCK):</span>
</span>
<span class="line" id="L1056">            .NOMEM =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SystemResources,</span>
<span class="line" id="L1057">            <span class="tok-comment">// Attempt to register files on a ring already registering files or being torn down:</span>
</span>
<span class="line" id="L1058">            .NXIO =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.RingShuttingDownOrAlreadyRegisteringFiles,</span>
<span class="line" id="L1059">            <span class="tok-kw">else</span> =&gt; |errno| <span class="tok-kw">return</span> os.unexpectedErrno(errno),</span>
<span class="line" id="L1060">        }</span>
<span class="line" id="L1061">    }</span>
<span class="line" id="L1062"></span>
<span class="line" id="L1063">    <span class="tok-comment">/// Unregisters all registered file descriptors previously associated with the ring.</span></span>
<span class="line" id="L1064">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">unregister_files</span>(self: *IO_Uring) !<span class="tok-type">void</span> {</span>
<span class="line" id="L1065">        assert(self.fd &gt;= <span class="tok-number">0</span>);</span>
<span class="line" id="L1066">        <span class="tok-kw">const</span> res = linux.io_uring_register(self.fd, .UNREGISTER_FILES, <span class="tok-null">null</span>, <span class="tok-number">0</span>);</span>
<span class="line" id="L1067">        <span class="tok-kw">switch</span> (linux.getErrno(res)) {</span>
<span class="line" id="L1068">            .SUCCESS =&gt; {},</span>
<span class="line" id="L1069">            .NXIO =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.FilesNotRegistered,</span>
<span class="line" id="L1070">            <span class="tok-kw">else</span> =&gt; |errno| <span class="tok-kw">return</span> os.unexpectedErrno(errno),</span>
<span class="line" id="L1071">        }</span>
<span class="line" id="L1072">    }</span>
<span class="line" id="L1073">};</span>
<span class="line" id="L1074"></span>
<span class="line" id="L1075"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SubmissionQueue = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L1076">    head: *<span class="tok-type">u32</span>,</span>
<span class="line" id="L1077">    tail: *<span class="tok-type">u32</span>,</span>
<span class="line" id="L1078">    mask: <span class="tok-type">u32</span>,</span>
<span class="line" id="L1079">    flags: *<span class="tok-type">u32</span>,</span>
<span class="line" id="L1080">    dropped: *<span class="tok-type">u32</span>,</span>
<span class="line" id="L1081">    array: []<span class="tok-type">u32</span>,</span>
<span class="line" id="L1082">    sqes: []linux.io_uring_sqe,</span>
<span class="line" id="L1083">    mmap: []<span class="tok-kw">align</span>(mem.page_size) <span class="tok-type">u8</span>,</span>
<span class="line" id="L1084">    mmap_sqes: []<span class="tok-kw">align</span>(mem.page_size) <span class="tok-type">u8</span>,</span>
<span class="line" id="L1085"></span>
<span class="line" id="L1086">    <span class="tok-comment">// We use `sqe_head` and `sqe_tail` in the same way as liburing:</span>
</span>
<span class="line" id="L1087">    <span class="tok-comment">// We increment `sqe_tail` (but not `tail`) for each call to `get_sqe()`.</span>
</span>
<span class="line" id="L1088">    <span class="tok-comment">// We then set `tail` to `sqe_tail` once, only when these events are actually submitted.</span>
</span>
<span class="line" id="L1089">    <span class="tok-comment">// This allows us to amortize the cost of the @atomicStore to `tail` across multiple SQEs.</span>
</span>
<span class="line" id="L1090">    sqe_head: <span class="tok-type">u32</span> = <span class="tok-number">0</span>,</span>
<span class="line" id="L1091">    sqe_tail: <span class="tok-type">u32</span> = <span class="tok-number">0</span>,</span>
<span class="line" id="L1092"></span>
<span class="line" id="L1093">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">init</span>(fd: os.fd_t, p: linux.io_uring_params) !SubmissionQueue {</span>
<span class="line" id="L1094">        assert(fd &gt;= <span class="tok-number">0</span>);</span>
<span class="line" id="L1095">        assert((p.features &amp; linux.IORING_FEAT_SINGLE_MMAP) != <span class="tok-number">0</span>);</span>
<span class="line" id="L1096">        <span class="tok-kw">const</span> size = std.math.max(</span>
<span class="line" id="L1097">            p.sq_off.array + p.sq_entries * <span class="tok-builtin">@sizeOf</span>(<span class="tok-type">u32</span>),</span>
<span class="line" id="L1098">            p.cq_off.cqes + p.cq_entries * <span class="tok-builtin">@sizeOf</span>(linux.io_uring_cqe),</span>
<span class="line" id="L1099">        );</span>
<span class="line" id="L1100">        <span class="tok-kw">const</span> mmap = <span class="tok-kw">try</span> os.mmap(</span>
<span class="line" id="L1101">            <span class="tok-null">null</span>,</span>
<span class="line" id="L1102">            size,</span>
<span class="line" id="L1103">            os.PROT.READ | os.PROT.WRITE,</span>
<span class="line" id="L1104">            os.MAP.SHARED | os.MAP.POPULATE,</span>
<span class="line" id="L1105">            fd,</span>
<span class="line" id="L1106">            linux.IORING_OFF_SQ_RING,</span>
<span class="line" id="L1107">        );</span>
<span class="line" id="L1108">        <span class="tok-kw">errdefer</span> os.munmap(mmap);</span>
<span class="line" id="L1109">        assert(mmap.len == size);</span>
<span class="line" id="L1110"></span>
<span class="line" id="L1111">        <span class="tok-comment">// The motivation for the `sqes` and `array` indirection is to make it possible for the</span>
</span>
<span class="line" id="L1112">        <span class="tok-comment">// application to preallocate static linux.io_uring_sqe entries and then replay them when needed.</span>
</span>
<span class="line" id="L1113">        <span class="tok-kw">const</span> size_sqes = p.sq_entries * <span class="tok-builtin">@sizeOf</span>(linux.io_uring_sqe);</span>
<span class="line" id="L1114">        <span class="tok-kw">const</span> mmap_sqes = <span class="tok-kw">try</span> os.mmap(</span>
<span class="line" id="L1115">            <span class="tok-null">null</span>,</span>
<span class="line" id="L1116">            size_sqes,</span>
<span class="line" id="L1117">            os.PROT.READ | os.PROT.WRITE,</span>
<span class="line" id="L1118">            os.MAP.SHARED | os.MAP.POPULATE,</span>
<span class="line" id="L1119">            fd,</span>
<span class="line" id="L1120">            linux.IORING_OFF_SQES,</span>
<span class="line" id="L1121">        );</span>
<span class="line" id="L1122">        <span class="tok-kw">errdefer</span> os.munmap(mmap_sqes);</span>
<span class="line" id="L1123">        assert(mmap_sqes.len == size_sqes);</span>
<span class="line" id="L1124"></span>
<span class="line" id="L1125">        <span class="tok-kw">const</span> array = <span class="tok-builtin">@ptrCast</span>([*]<span class="tok-type">u32</span>, <span class="tok-builtin">@alignCast</span>(<span class="tok-builtin">@alignOf</span>(<span class="tok-type">u32</span>), &amp;mmap[p.sq_off.array]));</span>
<span class="line" id="L1126">        <span class="tok-kw">const</span> sqes = <span class="tok-builtin">@ptrCast</span>([*]linux.io_uring_sqe, <span class="tok-builtin">@alignCast</span>(<span class="tok-builtin">@alignOf</span>(linux.io_uring_sqe), &amp;mmap_sqes[<span class="tok-number">0</span>]));</span>
<span class="line" id="L1127">        <span class="tok-comment">// We expect the kernel copies p.sq_entries to the u32 pointed to by p.sq_off.ring_entries,</span>
</span>
<span class="line" id="L1128">        <span class="tok-comment">// see https://github.com/torvalds/linux/blob/v5.8/fs/io_uring.c#L7843-L7844.</span>
</span>
<span class="line" id="L1129">        assert(</span>
<span class="line" id="L1130">            p.sq_entries ==</span>
<span class="line" id="L1131">                <span class="tok-builtin">@ptrCast</span>(*<span class="tok-type">u32</span>, <span class="tok-builtin">@alignCast</span>(<span class="tok-builtin">@alignOf</span>(<span class="tok-type">u32</span>), &amp;mmap[p.sq_off.ring_entries])).*,</span>
<span class="line" id="L1132">        );</span>
<span class="line" id="L1133">        <span class="tok-kw">return</span> SubmissionQueue{</span>
<span class="line" id="L1134">            .head = <span class="tok-builtin">@ptrCast</span>(*<span class="tok-type">u32</span>, <span class="tok-builtin">@alignCast</span>(<span class="tok-builtin">@alignOf</span>(<span class="tok-type">u32</span>), &amp;mmap[p.sq_off.head])),</span>
<span class="line" id="L1135">            .tail = <span class="tok-builtin">@ptrCast</span>(*<span class="tok-type">u32</span>, <span class="tok-builtin">@alignCast</span>(<span class="tok-builtin">@alignOf</span>(<span class="tok-type">u32</span>), &amp;mmap[p.sq_off.tail])),</span>
<span class="line" id="L1136">            .mask = <span class="tok-builtin">@ptrCast</span>(*<span class="tok-type">u32</span>, <span class="tok-builtin">@alignCast</span>(<span class="tok-builtin">@alignOf</span>(<span class="tok-type">u32</span>), &amp;mmap[p.sq_off.ring_mask])).*,</span>
<span class="line" id="L1137">            .flags = <span class="tok-builtin">@ptrCast</span>(*<span class="tok-type">u32</span>, <span class="tok-builtin">@alignCast</span>(<span class="tok-builtin">@alignOf</span>(<span class="tok-type">u32</span>), &amp;mmap[p.sq_off.flags])),</span>
<span class="line" id="L1138">            .dropped = <span class="tok-builtin">@ptrCast</span>(*<span class="tok-type">u32</span>, <span class="tok-builtin">@alignCast</span>(<span class="tok-builtin">@alignOf</span>(<span class="tok-type">u32</span>), &amp;mmap[p.sq_off.dropped])),</span>
<span class="line" id="L1139">            .array = array[<span class="tok-number">0</span>..p.sq_entries],</span>
<span class="line" id="L1140">            .sqes = sqes[<span class="tok-number">0</span>..p.sq_entries],</span>
<span class="line" id="L1141">            .mmap = mmap,</span>
<span class="line" id="L1142">            .mmap_sqes = mmap_sqes,</span>
<span class="line" id="L1143">        };</span>
<span class="line" id="L1144">    }</span>
<span class="line" id="L1145"></span>
<span class="line" id="L1146">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">deinit</span>(self: *SubmissionQueue) <span class="tok-type">void</span> {</span>
<span class="line" id="L1147">        os.munmap(self.mmap_sqes);</span>
<span class="line" id="L1148">        os.munmap(self.mmap);</span>
<span class="line" id="L1149">    }</span>
<span class="line" id="L1150">};</span>
<span class="line" id="L1151"></span>
<span class="line" id="L1152"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> CompletionQueue = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L1153">    head: *<span class="tok-type">u32</span>,</span>
<span class="line" id="L1154">    tail: *<span class="tok-type">u32</span>,</span>
<span class="line" id="L1155">    mask: <span class="tok-type">u32</span>,</span>
<span class="line" id="L1156">    overflow: *<span class="tok-type">u32</span>,</span>
<span class="line" id="L1157">    cqes: []linux.io_uring_cqe,</span>
<span class="line" id="L1158"></span>
<span class="line" id="L1159">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">init</span>(fd: os.fd_t, p: linux.io_uring_params, sq: SubmissionQueue) !CompletionQueue {</span>
<span class="line" id="L1160">        assert(fd &gt;= <span class="tok-number">0</span>);</span>
<span class="line" id="L1161">        assert((p.features &amp; linux.IORING_FEAT_SINGLE_MMAP) != <span class="tok-number">0</span>);</span>
<span class="line" id="L1162">        <span class="tok-kw">const</span> mmap = sq.mmap;</span>
<span class="line" id="L1163">        <span class="tok-kw">const</span> cqes = <span class="tok-builtin">@ptrCast</span>(</span>
<span class="line" id="L1164">            [*]linux.io_uring_cqe,</span>
<span class="line" id="L1165">            <span class="tok-builtin">@alignCast</span>(<span class="tok-builtin">@alignOf</span>(linux.io_uring_cqe), &amp;mmap[p.cq_off.cqes]),</span>
<span class="line" id="L1166">        );</span>
<span class="line" id="L1167">        assert(p.cq_entries ==</span>
<span class="line" id="L1168">            <span class="tok-builtin">@ptrCast</span>(*<span class="tok-type">u32</span>, <span class="tok-builtin">@alignCast</span>(<span class="tok-builtin">@alignOf</span>(<span class="tok-type">u32</span>), &amp;mmap[p.cq_off.ring_entries])).*);</span>
<span class="line" id="L1169">        <span class="tok-kw">return</span> CompletionQueue{</span>
<span class="line" id="L1170">            .head = <span class="tok-builtin">@ptrCast</span>(*<span class="tok-type">u32</span>, <span class="tok-builtin">@alignCast</span>(<span class="tok-builtin">@alignOf</span>(<span class="tok-type">u32</span>), &amp;mmap[p.cq_off.head])),</span>
<span class="line" id="L1171">            .tail = <span class="tok-builtin">@ptrCast</span>(*<span class="tok-type">u32</span>, <span class="tok-builtin">@alignCast</span>(<span class="tok-builtin">@alignOf</span>(<span class="tok-type">u32</span>), &amp;mmap[p.cq_off.tail])),</span>
<span class="line" id="L1172">            .mask = <span class="tok-builtin">@ptrCast</span>(*<span class="tok-type">u32</span>, <span class="tok-builtin">@alignCast</span>(<span class="tok-builtin">@alignOf</span>(<span class="tok-type">u32</span>), &amp;mmap[p.cq_off.ring_mask])).*,</span>
<span class="line" id="L1173">            .overflow = <span class="tok-builtin">@ptrCast</span>(*<span class="tok-type">u32</span>, <span class="tok-builtin">@alignCast</span>(<span class="tok-builtin">@alignOf</span>(<span class="tok-type">u32</span>), &amp;mmap[p.cq_off.overflow])),</span>
<span class="line" id="L1174">            .cqes = cqes[<span class="tok-number">0</span>..p.cq_entries],</span>
<span class="line" id="L1175">        };</span>
<span class="line" id="L1176">    }</span>
<span class="line" id="L1177"></span>
<span class="line" id="L1178">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">deinit</span>(self: *CompletionQueue) <span class="tok-type">void</span> {</span>
<span class="line" id="L1179">        _ = self;</span>
<span class="line" id="L1180">        <span class="tok-comment">// A no-op since we now share the mmap with the submission queue.</span>
</span>
<span class="line" id="L1181">        <span class="tok-comment">// Here for symmetry with the submission queue, and for any future feature support.</span>
</span>
<span class="line" id="L1182">    }</span>
<span class="line" id="L1183">};</span>
<span class="line" id="L1184"></span>
<span class="line" id="L1185"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">io_uring_prep_nop</span>(sqe: *linux.io_uring_sqe) <span class="tok-type">void</span> {</span>
<span class="line" id="L1186">    sqe.* = .{</span>
<span class="line" id="L1187">        .opcode = .NOP,</span>
<span class="line" id="L1188">        .flags = <span class="tok-number">0</span>,</span>
<span class="line" id="L1189">        .ioprio = <span class="tok-number">0</span>,</span>
<span class="line" id="L1190">        .fd = <span class="tok-number">0</span>,</span>
<span class="line" id="L1191">        .off = <span class="tok-number">0</span>,</span>
<span class="line" id="L1192">        .addr = <span class="tok-number">0</span>,</span>
<span class="line" id="L1193">        .len = <span class="tok-number">0</span>,</span>
<span class="line" id="L1194">        .rw_flags = <span class="tok-number">0</span>,</span>
<span class="line" id="L1195">        .user_data = <span class="tok-number">0</span>,</span>
<span class="line" id="L1196">        .buf_index = <span class="tok-number">0</span>,</span>
<span class="line" id="L1197">        .personality = <span class="tok-number">0</span>,</span>
<span class="line" id="L1198">        .splice_fd_in = <span class="tok-number">0</span>,</span>
<span class="line" id="L1199">        .__pad2 = [<span class="tok-number">2</span>]<span class="tok-type">u64</span>{ <span class="tok-number">0</span>, <span class="tok-number">0</span> },</span>
<span class="line" id="L1200">    };</span>
<span class="line" id="L1201">}</span>
<span class="line" id="L1202"></span>
<span class="line" id="L1203"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">io_uring_prep_fsync</span>(sqe: *linux.io_uring_sqe, fd: os.fd_t, flags: <span class="tok-type">u32</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L1204">    sqe.* = .{</span>
<span class="line" id="L1205">        .opcode = .FSYNC,</span>
<span class="line" id="L1206">        .flags = <span class="tok-number">0</span>,</span>
<span class="line" id="L1207">        .ioprio = <span class="tok-number">0</span>,</span>
<span class="line" id="L1208">        .fd = fd,</span>
<span class="line" id="L1209">        .off = <span class="tok-number">0</span>,</span>
<span class="line" id="L1210">        .addr = <span class="tok-number">0</span>,</span>
<span class="line" id="L1211">        .len = <span class="tok-number">0</span>,</span>
<span class="line" id="L1212">        .rw_flags = flags,</span>
<span class="line" id="L1213">        .user_data = <span class="tok-number">0</span>,</span>
<span class="line" id="L1214">        .buf_index = <span class="tok-number">0</span>,</span>
<span class="line" id="L1215">        .personality = <span class="tok-number">0</span>,</span>
<span class="line" id="L1216">        .splice_fd_in = <span class="tok-number">0</span>,</span>
<span class="line" id="L1217">        .__pad2 = [<span class="tok-number">2</span>]<span class="tok-type">u64</span>{ <span class="tok-number">0</span>, <span class="tok-number">0</span> },</span>
<span class="line" id="L1218">    };</span>
<span class="line" id="L1219">}</span>
<span class="line" id="L1220"></span>
<span class="line" id="L1221"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">io_uring_prep_rw</span>(</span>
<span class="line" id="L1222">    op: linux.IORING_OP,</span>
<span class="line" id="L1223">    sqe: *linux.io_uring_sqe,</span>
<span class="line" id="L1224">    fd: os.fd_t,</span>
<span class="line" id="L1225">    addr: <span class="tok-type">u64</span>,</span>
<span class="line" id="L1226">    len: <span class="tok-type">usize</span>,</span>
<span class="line" id="L1227">    offset: <span class="tok-type">u64</span>,</span>
<span class="line" id="L1228">) <span class="tok-type">void</span> {</span>
<span class="line" id="L1229">    sqe.* = .{</span>
<span class="line" id="L1230">        .opcode = op,</span>
<span class="line" id="L1231">        .flags = <span class="tok-number">0</span>,</span>
<span class="line" id="L1232">        .ioprio = <span class="tok-number">0</span>,</span>
<span class="line" id="L1233">        .fd = fd,</span>
<span class="line" id="L1234">        .off = offset,</span>
<span class="line" id="L1235">        .addr = addr,</span>
<span class="line" id="L1236">        .len = <span class="tok-builtin">@intCast</span>(<span class="tok-type">u32</span>, len),</span>
<span class="line" id="L1237">        .rw_flags = <span class="tok-number">0</span>,</span>
<span class="line" id="L1238">        .user_data = <span class="tok-number">0</span>,</span>
<span class="line" id="L1239">        .buf_index = <span class="tok-number">0</span>,</span>
<span class="line" id="L1240">        .personality = <span class="tok-number">0</span>,</span>
<span class="line" id="L1241">        .splice_fd_in = <span class="tok-number">0</span>,</span>
<span class="line" id="L1242">        .__pad2 = [<span class="tok-number">2</span>]<span class="tok-type">u64</span>{ <span class="tok-number">0</span>, <span class="tok-number">0</span> },</span>
<span class="line" id="L1243">    };</span>
<span class="line" id="L1244">}</span>
<span class="line" id="L1245"></span>
<span class="line" id="L1246"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">io_uring_prep_read</span>(sqe: *linux.io_uring_sqe, fd: os.fd_t, buffer: []<span class="tok-type">u8</span>, offset: <span class="tok-type">u64</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L1247">    io_uring_prep_rw(.READ, sqe, fd, <span class="tok-builtin">@ptrToInt</span>(buffer.ptr), buffer.len, offset);</span>
<span class="line" id="L1248">}</span>
<span class="line" id="L1249"></span>
<span class="line" id="L1250"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">io_uring_prep_write</span>(sqe: *linux.io_uring_sqe, fd: os.fd_t, buffer: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, offset: <span class="tok-type">u64</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L1251">    io_uring_prep_rw(.WRITE, sqe, fd, <span class="tok-builtin">@ptrToInt</span>(buffer.ptr), buffer.len, offset);</span>
<span class="line" id="L1252">}</span>
<span class="line" id="L1253"></span>
<span class="line" id="L1254"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">io_uring_prep_readv</span>(</span>
<span class="line" id="L1255">    sqe: *linux.io_uring_sqe,</span>
<span class="line" id="L1256">    fd: os.fd_t,</span>
<span class="line" id="L1257">    iovecs: []<span class="tok-kw">const</span> os.iovec,</span>
<span class="line" id="L1258">    offset: <span class="tok-type">u64</span>,</span>
<span class="line" id="L1259">) <span class="tok-type">void</span> {</span>
<span class="line" id="L1260">    io_uring_prep_rw(.READV, sqe, fd, <span class="tok-builtin">@ptrToInt</span>(iovecs.ptr), iovecs.len, offset);</span>
<span class="line" id="L1261">}</span>
<span class="line" id="L1262"></span>
<span class="line" id="L1263"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">io_uring_prep_writev</span>(</span>
<span class="line" id="L1264">    sqe: *linux.io_uring_sqe,</span>
<span class="line" id="L1265">    fd: os.fd_t,</span>
<span class="line" id="L1266">    iovecs: []<span class="tok-kw">const</span> os.iovec_const,</span>
<span class="line" id="L1267">    offset: <span class="tok-type">u64</span>,</span>
<span class="line" id="L1268">) <span class="tok-type">void</span> {</span>
<span class="line" id="L1269">    io_uring_prep_rw(.WRITEV, sqe, fd, <span class="tok-builtin">@ptrToInt</span>(iovecs.ptr), iovecs.len, offset);</span>
<span class="line" id="L1270">}</span>
<span class="line" id="L1271"></span>
<span class="line" id="L1272"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">io_uring_prep_read_fixed</span>(sqe: *linux.io_uring_sqe, fd: os.fd_t, buffer: *os.iovec, offset: <span class="tok-type">u64</span>, buffer_index: <span class="tok-type">u16</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L1273">    io_uring_prep_rw(.READ_FIXED, sqe, fd, <span class="tok-builtin">@ptrToInt</span>(buffer.iov_base), buffer.iov_len, offset);</span>
<span class="line" id="L1274">    sqe.buf_index = buffer_index;</span>
<span class="line" id="L1275">}</span>
<span class="line" id="L1276"></span>
<span class="line" id="L1277"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">io_uring_prep_write_fixed</span>(sqe: *linux.io_uring_sqe, fd: os.fd_t, buffer: *os.iovec, offset: <span class="tok-type">u64</span>, buffer_index: <span class="tok-type">u16</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L1278">    io_uring_prep_rw(.WRITE_FIXED, sqe, fd, <span class="tok-builtin">@ptrToInt</span>(buffer.iov_base), buffer.iov_len, offset);</span>
<span class="line" id="L1279">    sqe.buf_index = buffer_index;</span>
<span class="line" id="L1280">}</span>
<span class="line" id="L1281"></span>
<span class="line" id="L1282"><span class="tok-comment">/// Poll masks previously used to comprise of 16 bits in the flags union of</span></span>
<span class="line" id="L1283"><span class="tok-comment">/// a SQE, but were then extended to comprise of 32 bits in order to make</span></span>
<span class="line" id="L1284"><span class="tok-comment">/// room for additional option flags. To ensure that the correct bits of</span></span>
<span class="line" id="L1285"><span class="tok-comment">/// poll masks are consistently and properly read across multiple kernel</span></span>
<span class="line" id="L1286"><span class="tok-comment">/// versions, poll masks are enforced to be little-endian.</span></span>
<span class="line" id="L1287"><span class="tok-comment">/// https://www.spinics.net/lists/io-uring/msg02848.html</span></span>
<span class="line" id="L1288"><span class="tok-kw">pub</span> <span class="tok-kw">inline</span> <span class="tok-kw">fn</span> <span class="tok-fn">__io_uring_prep_poll_mask</span>(poll_mask: <span class="tok-type">u32</span>) <span class="tok-type">u32</span> {</span>
<span class="line" id="L1289">    <span class="tok-kw">return</span> std.mem.nativeToLittle(<span class="tok-type">u32</span>, poll_mask);</span>
<span class="line" id="L1290">}</span>
<span class="line" id="L1291"></span>
<span class="line" id="L1292"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">io_uring_prep_accept</span>(</span>
<span class="line" id="L1293">    sqe: *linux.io_uring_sqe,</span>
<span class="line" id="L1294">    fd: os.fd_t,</span>
<span class="line" id="L1295">    addr: *os.sockaddr,</span>
<span class="line" id="L1296">    addrlen: *os.socklen_t,</span>
<span class="line" id="L1297">    flags: <span class="tok-type">u32</span>,</span>
<span class="line" id="L1298">) <span class="tok-type">void</span> {</span>
<span class="line" id="L1299">    <span class="tok-comment">// `addr` holds a pointer to `sockaddr`, and `addr2` holds a pointer to socklen_t`.</span>
</span>
<span class="line" id="L1300">    <span class="tok-comment">// `addr2` maps to `sqe.off` (u64) instead of `sqe.len` (which is only a u32).</span>
</span>
<span class="line" id="L1301">    io_uring_prep_rw(.ACCEPT, sqe, fd, <span class="tok-builtin">@ptrToInt</span>(addr), <span class="tok-number">0</span>, <span class="tok-builtin">@ptrToInt</span>(addrlen));</span>
<span class="line" id="L1302">    sqe.rw_flags = flags;</span>
<span class="line" id="L1303">}</span>
<span class="line" id="L1304"></span>
<span class="line" id="L1305"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">io_uring_prep_connect</span>(</span>
<span class="line" id="L1306">    sqe: *linux.io_uring_sqe,</span>
<span class="line" id="L1307">    fd: os.fd_t,</span>
<span class="line" id="L1308">    addr: *<span class="tok-kw">const</span> os.sockaddr,</span>
<span class="line" id="L1309">    addrlen: os.socklen_t,</span>
<span class="line" id="L1310">) <span class="tok-type">void</span> {</span>
<span class="line" id="L1311">    <span class="tok-comment">// `addrlen` maps to `sqe.off` (u64) instead of `sqe.len` (which is only a u32).</span>
</span>
<span class="line" id="L1312">    io_uring_prep_rw(.CONNECT, sqe, fd, <span class="tok-builtin">@ptrToInt</span>(addr), <span class="tok-number">0</span>, addrlen);</span>
<span class="line" id="L1313">}</span>
<span class="line" id="L1314"></span>
<span class="line" id="L1315"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">io_uring_prep_epoll_ctl</span>(</span>
<span class="line" id="L1316">    sqe: *linux.io_uring_sqe,</span>
<span class="line" id="L1317">    epfd: os.fd_t,</span>
<span class="line" id="L1318">    fd: os.fd_t,</span>
<span class="line" id="L1319">    op: <span class="tok-type">u32</span>,</span>
<span class="line" id="L1320">    ev: ?*linux.epoll_event,</span>
<span class="line" id="L1321">) <span class="tok-type">void</span> {</span>
<span class="line" id="L1322">    io_uring_prep_rw(.EPOLL_CTL, sqe, epfd, <span class="tok-builtin">@ptrToInt</span>(ev), op, <span class="tok-builtin">@intCast</span>(<span class="tok-type">u64</span>, fd));</span>
<span class="line" id="L1323">}</span>
<span class="line" id="L1324"></span>
<span class="line" id="L1325"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">io_uring_prep_recv</span>(sqe: *linux.io_uring_sqe, fd: os.fd_t, buffer: []<span class="tok-type">u8</span>, flags: <span class="tok-type">u32</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L1326">    io_uring_prep_rw(.RECV, sqe, fd, <span class="tok-builtin">@ptrToInt</span>(buffer.ptr), buffer.len, <span class="tok-number">0</span>);</span>
<span class="line" id="L1327">    sqe.rw_flags = flags;</span>
<span class="line" id="L1328">}</span>
<span class="line" id="L1329"></span>
<span class="line" id="L1330"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">io_uring_prep_send</span>(sqe: *linux.io_uring_sqe, fd: os.fd_t, buffer: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, flags: <span class="tok-type">u32</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L1331">    io_uring_prep_rw(.SEND, sqe, fd, <span class="tok-builtin">@ptrToInt</span>(buffer.ptr), buffer.len, <span class="tok-number">0</span>);</span>
<span class="line" id="L1332">    sqe.rw_flags = flags;</span>
<span class="line" id="L1333">}</span>
<span class="line" id="L1334"></span>
<span class="line" id="L1335"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">io_uring_prep_recvmsg</span>(</span>
<span class="line" id="L1336">    sqe: *linux.io_uring_sqe,</span>
<span class="line" id="L1337">    fd: os.fd_t,</span>
<span class="line" id="L1338">    msg: *os.msghdr,</span>
<span class="line" id="L1339">    flags: <span class="tok-type">u32</span>,</span>
<span class="line" id="L1340">) <span class="tok-type">void</span> {</span>
<span class="line" id="L1341">    linux.io_uring_prep_rw(.RECVMSG, sqe, fd, <span class="tok-builtin">@ptrToInt</span>(msg), <span class="tok-number">1</span>, <span class="tok-number">0</span>);</span>
<span class="line" id="L1342">    sqe.rw_flags = flags;</span>
<span class="line" id="L1343">}</span>
<span class="line" id="L1344"></span>
<span class="line" id="L1345"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">io_uring_prep_sendmsg</span>(</span>
<span class="line" id="L1346">    sqe: *linux.io_uring_sqe,</span>
<span class="line" id="L1347">    fd: os.fd_t,</span>
<span class="line" id="L1348">    msg: *<span class="tok-kw">const</span> os.msghdr_const,</span>
<span class="line" id="L1349">    flags: <span class="tok-type">u32</span>,</span>
<span class="line" id="L1350">) <span class="tok-type">void</span> {</span>
<span class="line" id="L1351">    linux.io_uring_prep_rw(.SENDMSG, sqe, fd, <span class="tok-builtin">@ptrToInt</span>(msg), <span class="tok-number">1</span>, <span class="tok-number">0</span>);</span>
<span class="line" id="L1352">    sqe.rw_flags = flags;</span>
<span class="line" id="L1353">}</span>
<span class="line" id="L1354"></span>
<span class="line" id="L1355"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">io_uring_prep_openat</span>(</span>
<span class="line" id="L1356">    sqe: *linux.io_uring_sqe,</span>
<span class="line" id="L1357">    fd: os.fd_t,</span>
<span class="line" id="L1358">    path: [*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L1359">    flags: <span class="tok-type">u32</span>,</span>
<span class="line" id="L1360">    mode: os.mode_t,</span>
<span class="line" id="L1361">) <span class="tok-type">void</span> {</span>
<span class="line" id="L1362">    io_uring_prep_rw(.OPENAT, sqe, fd, <span class="tok-builtin">@ptrToInt</span>(path), mode, <span class="tok-number">0</span>);</span>
<span class="line" id="L1363">    sqe.rw_flags = flags;</span>
<span class="line" id="L1364">}</span>
<span class="line" id="L1365"></span>
<span class="line" id="L1366"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">io_uring_prep_close</span>(sqe: *linux.io_uring_sqe, fd: os.fd_t) <span class="tok-type">void</span> {</span>
<span class="line" id="L1367">    sqe.* = .{</span>
<span class="line" id="L1368">        .opcode = .CLOSE,</span>
<span class="line" id="L1369">        .flags = <span class="tok-number">0</span>,</span>
<span class="line" id="L1370">        .ioprio = <span class="tok-number">0</span>,</span>
<span class="line" id="L1371">        .fd = fd,</span>
<span class="line" id="L1372">        .off = <span class="tok-number">0</span>,</span>
<span class="line" id="L1373">        .addr = <span class="tok-number">0</span>,</span>
<span class="line" id="L1374">        .len = <span class="tok-number">0</span>,</span>
<span class="line" id="L1375">        .rw_flags = <span class="tok-number">0</span>,</span>
<span class="line" id="L1376">        .user_data = <span class="tok-number">0</span>,</span>
<span class="line" id="L1377">        .buf_index = <span class="tok-number">0</span>,</span>
<span class="line" id="L1378">        .personality = <span class="tok-number">0</span>,</span>
<span class="line" id="L1379">        .splice_fd_in = <span class="tok-number">0</span>,</span>
<span class="line" id="L1380">        .__pad2 = [<span class="tok-number">2</span>]<span class="tok-type">u64</span>{ <span class="tok-number">0</span>, <span class="tok-number">0</span> },</span>
<span class="line" id="L1381">    };</span>
<span class="line" id="L1382">}</span>
<span class="line" id="L1383"></span>
<span class="line" id="L1384"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">io_uring_prep_timeout</span>(</span>
<span class="line" id="L1385">    sqe: *linux.io_uring_sqe,</span>
<span class="line" id="L1386">    ts: *<span class="tok-kw">const</span> os.linux.kernel_timespec,</span>
<span class="line" id="L1387">    count: <span class="tok-type">u32</span>,</span>
<span class="line" id="L1388">    flags: <span class="tok-type">u32</span>,</span>
<span class="line" id="L1389">) <span class="tok-type">void</span> {</span>
<span class="line" id="L1390">    io_uring_prep_rw(.TIMEOUT, sqe, -<span class="tok-number">1</span>, <span class="tok-builtin">@ptrToInt</span>(ts), <span class="tok-number">1</span>, count);</span>
<span class="line" id="L1391">    sqe.rw_flags = flags;</span>
<span class="line" id="L1392">}</span>
<span class="line" id="L1393"></span>
<span class="line" id="L1394"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">io_uring_prep_timeout_remove</span>(sqe: *linux.io_uring_sqe, timeout_user_data: <span class="tok-type">u64</span>, flags: <span class="tok-type">u32</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L1395">    sqe.* = .{</span>
<span class="line" id="L1396">        .opcode = .TIMEOUT_REMOVE,</span>
<span class="line" id="L1397">        .flags = <span class="tok-number">0</span>,</span>
<span class="line" id="L1398">        .ioprio = <span class="tok-number">0</span>,</span>
<span class="line" id="L1399">        .fd = -<span class="tok-number">1</span>,</span>
<span class="line" id="L1400">        .off = <span class="tok-number">0</span>,</span>
<span class="line" id="L1401">        .addr = timeout_user_data,</span>
<span class="line" id="L1402">        .len = <span class="tok-number">0</span>,</span>
<span class="line" id="L1403">        .rw_flags = flags,</span>
<span class="line" id="L1404">        .user_data = <span class="tok-number">0</span>,</span>
<span class="line" id="L1405">        .buf_index = <span class="tok-number">0</span>,</span>
<span class="line" id="L1406">        .personality = <span class="tok-number">0</span>,</span>
<span class="line" id="L1407">        .splice_fd_in = <span class="tok-number">0</span>,</span>
<span class="line" id="L1408">        .__pad2 = [<span class="tok-number">2</span>]<span class="tok-type">u64</span>{ <span class="tok-number">0</span>, <span class="tok-number">0</span> },</span>
<span class="line" id="L1409">    };</span>
<span class="line" id="L1410">}</span>
<span class="line" id="L1411"></span>
<span class="line" id="L1412"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">io_uring_prep_link_timeout</span>(</span>
<span class="line" id="L1413">    sqe: *linux.io_uring_sqe,</span>
<span class="line" id="L1414">    ts: *<span class="tok-kw">const</span> os.linux.kernel_timespec,</span>
<span class="line" id="L1415">    flags: <span class="tok-type">u32</span>,</span>
<span class="line" id="L1416">) <span class="tok-type">void</span> {</span>
<span class="line" id="L1417">    linux.io_uring_prep_rw(.LINK_TIMEOUT, sqe, -<span class="tok-number">1</span>, <span class="tok-builtin">@ptrToInt</span>(ts), <span class="tok-number">1</span>, <span class="tok-number">0</span>);</span>
<span class="line" id="L1418">    sqe.rw_flags = flags;</span>
<span class="line" id="L1419">}</span>
<span class="line" id="L1420"></span>
<span class="line" id="L1421"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">io_uring_prep_poll_add</span>(</span>
<span class="line" id="L1422">    sqe: *linux.io_uring_sqe,</span>
<span class="line" id="L1423">    fd: os.fd_t,</span>
<span class="line" id="L1424">    poll_mask: <span class="tok-type">u32</span>,</span>
<span class="line" id="L1425">) <span class="tok-type">void</span> {</span>
<span class="line" id="L1426">    io_uring_prep_rw(.POLL_ADD, sqe, fd, <span class="tok-builtin">@ptrToInt</span>(<span class="tok-builtin">@as</span>(?*<span class="tok-type">anyopaque</span>, <span class="tok-null">null</span>)), <span class="tok-number">0</span>, <span class="tok-number">0</span>);</span>
<span class="line" id="L1427">    sqe.rw_flags = __io_uring_prep_poll_mask(poll_mask);</span>
<span class="line" id="L1428">}</span>
<span class="line" id="L1429"></span>
<span class="line" id="L1430"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">io_uring_prep_poll_remove</span>(</span>
<span class="line" id="L1431">    sqe: *linux.io_uring_sqe,</span>
<span class="line" id="L1432">    target_user_data: <span class="tok-type">u64</span>,</span>
<span class="line" id="L1433">) <span class="tok-type">void</span> {</span>
<span class="line" id="L1434">    io_uring_prep_rw(.POLL_REMOVE, sqe, -<span class="tok-number">1</span>, target_user_data, <span class="tok-number">0</span>, <span class="tok-number">0</span>);</span>
<span class="line" id="L1435">}</span>
<span class="line" id="L1436"></span>
<span class="line" id="L1437"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">io_uring_prep_poll_update</span>(</span>
<span class="line" id="L1438">    sqe: *linux.io_uring_sqe,</span>
<span class="line" id="L1439">    old_user_data: <span class="tok-type">u64</span>,</span>
<span class="line" id="L1440">    new_user_data: <span class="tok-type">u64</span>,</span>
<span class="line" id="L1441">    poll_mask: <span class="tok-type">u32</span>,</span>
<span class="line" id="L1442">    flags: <span class="tok-type">u32</span>,</span>
<span class="line" id="L1443">) <span class="tok-type">void</span> {</span>
<span class="line" id="L1444">    io_uring_prep_rw(.POLL_REMOVE, sqe, -<span class="tok-number">1</span>, old_user_data, flags, new_user_data);</span>
<span class="line" id="L1445">    sqe.rw_flags = __io_uring_prep_poll_mask(poll_mask);</span>
<span class="line" id="L1446">}</span>
<span class="line" id="L1447"></span>
<span class="line" id="L1448"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">io_uring_prep_fallocate</span>(</span>
<span class="line" id="L1449">    sqe: *linux.io_uring_sqe,</span>
<span class="line" id="L1450">    fd: os.fd_t,</span>
<span class="line" id="L1451">    mode: <span class="tok-type">i32</span>,</span>
<span class="line" id="L1452">    offset: <span class="tok-type">u64</span>,</span>
<span class="line" id="L1453">    len: <span class="tok-type">u64</span>,</span>
<span class="line" id="L1454">) <span class="tok-type">void</span> {</span>
<span class="line" id="L1455">    sqe.* = .{</span>
<span class="line" id="L1456">        .opcode = .FALLOCATE,</span>
<span class="line" id="L1457">        .flags = <span class="tok-number">0</span>,</span>
<span class="line" id="L1458">        .ioprio = <span class="tok-number">0</span>,</span>
<span class="line" id="L1459">        .fd = fd,</span>
<span class="line" id="L1460">        .off = offset,</span>
<span class="line" id="L1461">        .addr = len,</span>
<span class="line" id="L1462">        .len = <span class="tok-builtin">@intCast</span>(<span class="tok-type">u32</span>, mode),</span>
<span class="line" id="L1463">        .rw_flags = <span class="tok-number">0</span>,</span>
<span class="line" id="L1464">        .user_data = <span class="tok-number">0</span>,</span>
<span class="line" id="L1465">        .buf_index = <span class="tok-number">0</span>,</span>
<span class="line" id="L1466">        .personality = <span class="tok-number">0</span>,</span>
<span class="line" id="L1467">        .splice_fd_in = <span class="tok-number">0</span>,</span>
<span class="line" id="L1468">        .__pad2 = [<span class="tok-number">2</span>]<span class="tok-type">u64</span>{ <span class="tok-number">0</span>, <span class="tok-number">0</span> },</span>
<span class="line" id="L1469">    };</span>
<span class="line" id="L1470">}</span>
<span class="line" id="L1471"></span>
<span class="line" id="L1472"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">io_uring_prep_statx</span>(</span>
<span class="line" id="L1473">    sqe: *linux.io_uring_sqe,</span>
<span class="line" id="L1474">    fd: os.fd_t,</span>
<span class="line" id="L1475">    path: [*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L1476">    flags: <span class="tok-type">u32</span>,</span>
<span class="line" id="L1477">    mask: <span class="tok-type">u32</span>,</span>
<span class="line" id="L1478">    buf: *linux.Statx,</span>
<span class="line" id="L1479">) <span class="tok-type">void</span> {</span>
<span class="line" id="L1480">    io_uring_prep_rw(.STATX, sqe, fd, <span class="tok-builtin">@ptrToInt</span>(path), mask, <span class="tok-builtin">@ptrToInt</span>(buf));</span>
<span class="line" id="L1481">    sqe.rw_flags = flags;</span>
<span class="line" id="L1482">}</span>
<span class="line" id="L1483"></span>
<span class="line" id="L1484"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">io_uring_prep_cancel</span>(</span>
<span class="line" id="L1485">    sqe: *linux.io_uring_sqe,</span>
<span class="line" id="L1486">    cancel_user_data: <span class="tok-type">u64</span>,</span>
<span class="line" id="L1487">    flags: <span class="tok-type">u32</span>,</span>
<span class="line" id="L1488">) <span class="tok-type">void</span> {</span>
<span class="line" id="L1489">    io_uring_prep_rw(.ASYNC_CANCEL, sqe, -<span class="tok-number">1</span>, cancel_user_data, <span class="tok-number">0</span>, <span class="tok-number">0</span>);</span>
<span class="line" id="L1490">    sqe.rw_flags = flags;</span>
<span class="line" id="L1491">}</span>
<span class="line" id="L1492"></span>
<span class="line" id="L1493"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">io_uring_prep_shutdown</span>(</span>
<span class="line" id="L1494">    sqe: *linux.io_uring_sqe,</span>
<span class="line" id="L1495">    sockfd: os.socket_t,</span>
<span class="line" id="L1496">    how: <span class="tok-type">u32</span>,</span>
<span class="line" id="L1497">) <span class="tok-type">void</span> {</span>
<span class="line" id="L1498">    io_uring_prep_rw(.SHUTDOWN, sqe, sockfd, <span class="tok-number">0</span>, how, <span class="tok-number">0</span>);</span>
<span class="line" id="L1499">}</span>
<span class="line" id="L1500"></span>
<span class="line" id="L1501"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">io_uring_prep_renameat</span>(</span>
<span class="line" id="L1502">    sqe: *linux.io_uring_sqe,</span>
<span class="line" id="L1503">    old_dir_fd: os.fd_t,</span>
<span class="line" id="L1504">    old_path: [*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L1505">    new_dir_fd: os.fd_t,</span>
<span class="line" id="L1506">    new_path: [*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L1507">    flags: <span class="tok-type">u32</span>,</span>
<span class="line" id="L1508">) <span class="tok-type">void</span> {</span>
<span class="line" id="L1509">    io_uring_prep_rw(</span>
<span class="line" id="L1510">        .RENAMEAT,</span>
<span class="line" id="L1511">        sqe,</span>
<span class="line" id="L1512">        old_dir_fd,</span>
<span class="line" id="L1513">        <span class="tok-builtin">@ptrToInt</span>(old_path),</span>
<span class="line" id="L1514">        <span class="tok-number">0</span>,</span>
<span class="line" id="L1515">        <span class="tok-builtin">@ptrToInt</span>(new_path),</span>
<span class="line" id="L1516">    );</span>
<span class="line" id="L1517">    sqe.len = <span class="tok-builtin">@bitCast</span>(<span class="tok-type">u32</span>, new_dir_fd);</span>
<span class="line" id="L1518">    sqe.rw_flags = flags;</span>
<span class="line" id="L1519">}</span>
<span class="line" id="L1520"></span>
<span class="line" id="L1521"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">io_uring_prep_unlinkat</span>(</span>
<span class="line" id="L1522">    sqe: *linux.io_uring_sqe,</span>
<span class="line" id="L1523">    dir_fd: os.fd_t,</span>
<span class="line" id="L1524">    path: [*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L1525">    flags: <span class="tok-type">u32</span>,</span>
<span class="line" id="L1526">) <span class="tok-type">void</span> {</span>
<span class="line" id="L1527">    io_uring_prep_rw(.UNLINKAT, sqe, dir_fd, <span class="tok-builtin">@ptrToInt</span>(path), <span class="tok-number">0</span>, <span class="tok-number">0</span>);</span>
<span class="line" id="L1528">    sqe.rw_flags = flags;</span>
<span class="line" id="L1529">}</span>
<span class="line" id="L1530"></span>
<span class="line" id="L1531"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">io_uring_prep_mkdirat</span>(</span>
<span class="line" id="L1532">    sqe: *linux.io_uring_sqe,</span>
<span class="line" id="L1533">    dir_fd: os.fd_t,</span>
<span class="line" id="L1534">    path: [*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L1535">    mode: os.mode_t,</span>
<span class="line" id="L1536">) <span class="tok-type">void</span> {</span>
<span class="line" id="L1537">    io_uring_prep_rw(.MKDIRAT, sqe, dir_fd, <span class="tok-builtin">@ptrToInt</span>(path), mode, <span class="tok-number">0</span>);</span>
<span class="line" id="L1538">}</span>
<span class="line" id="L1539"></span>
<span class="line" id="L1540"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">io_uring_prep_symlinkat</span>(</span>
<span class="line" id="L1541">    sqe: *linux.io_uring_sqe,</span>
<span class="line" id="L1542">    target: [*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L1543">    new_dir_fd: os.fd_t,</span>
<span class="line" id="L1544">    link_path: [*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L1545">) <span class="tok-type">void</span> {</span>
<span class="line" id="L1546">    io_uring_prep_rw(</span>
<span class="line" id="L1547">        .SYMLINKAT,</span>
<span class="line" id="L1548">        sqe,</span>
<span class="line" id="L1549">        new_dir_fd,</span>
<span class="line" id="L1550">        <span class="tok-builtin">@ptrToInt</span>(target),</span>
<span class="line" id="L1551">        <span class="tok-number">0</span>,</span>
<span class="line" id="L1552">        <span class="tok-builtin">@ptrToInt</span>(link_path),</span>
<span class="line" id="L1553">    );</span>
<span class="line" id="L1554">}</span>
<span class="line" id="L1555"></span>
<span class="line" id="L1556"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">io_uring_prep_linkat</span>(</span>
<span class="line" id="L1557">    sqe: *linux.io_uring_sqe,</span>
<span class="line" id="L1558">    old_dir_fd: os.fd_t,</span>
<span class="line" id="L1559">    old_path: [*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L1560">    new_dir_fd: os.fd_t,</span>
<span class="line" id="L1561">    new_path: [*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L1562">    flags: <span class="tok-type">u32</span>,</span>
<span class="line" id="L1563">) <span class="tok-type">void</span> {</span>
<span class="line" id="L1564">    io_uring_prep_rw(</span>
<span class="line" id="L1565">        .LINKAT,</span>
<span class="line" id="L1566">        sqe,</span>
<span class="line" id="L1567">        old_dir_fd,</span>
<span class="line" id="L1568">        <span class="tok-builtin">@ptrToInt</span>(old_path),</span>
<span class="line" id="L1569">        <span class="tok-number">0</span>,</span>
<span class="line" id="L1570">        <span class="tok-builtin">@ptrToInt</span>(new_path),</span>
<span class="line" id="L1571">    );</span>
<span class="line" id="L1572">    sqe.len = <span class="tok-builtin">@bitCast</span>(<span class="tok-type">u32</span>, new_dir_fd);</span>
<span class="line" id="L1573">    sqe.rw_flags = flags;</span>
<span class="line" id="L1574">}</span>
<span class="line" id="L1575"></span>
<span class="line" id="L1576"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">io_uring_prep_provide_buffers</span>(</span>
<span class="line" id="L1577">    sqe: *linux.io_uring_sqe,</span>
<span class="line" id="L1578">    buffers: [*]<span class="tok-type">u8</span>,</span>
<span class="line" id="L1579">    num: <span class="tok-type">usize</span>,</span>
<span class="line" id="L1580">    buffer_len: <span class="tok-type">usize</span>,</span>
<span class="line" id="L1581">    group_id: <span class="tok-type">usize</span>,</span>
<span class="line" id="L1582">    buffer_id: <span class="tok-type">usize</span>,</span>
<span class="line" id="L1583">) <span class="tok-type">void</span> {</span>
<span class="line" id="L1584">    <span class="tok-kw">const</span> ptr = <span class="tok-builtin">@ptrToInt</span>(buffers);</span>
<span class="line" id="L1585">    io_uring_prep_rw(.PROVIDE_BUFFERS, sqe, <span class="tok-builtin">@intCast</span>(<span class="tok-type">i32</span>, num), ptr, buffer_len, buffer_id);</span>
<span class="line" id="L1586">    sqe.buf_index = <span class="tok-builtin">@intCast</span>(<span class="tok-type">u16</span>, group_id);</span>
<span class="line" id="L1587">}</span>
<span class="line" id="L1588"></span>
<span class="line" id="L1589"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">io_uring_prep_remove_buffers</span>(</span>
<span class="line" id="L1590">    sqe: *linux.io_uring_sqe,</span>
<span class="line" id="L1591">    num: <span class="tok-type">usize</span>,</span>
<span class="line" id="L1592">    group_id: <span class="tok-type">usize</span>,</span>
<span class="line" id="L1593">) <span class="tok-type">void</span> {</span>
<span class="line" id="L1594">    io_uring_prep_rw(.REMOVE_BUFFERS, sqe, <span class="tok-builtin">@intCast</span>(<span class="tok-type">i32</span>, num), <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>);</span>
<span class="line" id="L1595">    sqe.buf_index = <span class="tok-builtin">@intCast</span>(<span class="tok-type">u16</span>, group_id);</span>
<span class="line" id="L1596">}</span>
<span class="line" id="L1597"></span>
<span class="line" id="L1598"><span class="tok-kw">test</span> <span class="tok-str">&quot;structs/offsets/entries&quot;</span> {</span>
<span class="line" id="L1599">    <span class="tok-kw">if</span> (builtin.os.tag != .linux) <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SkipZigTest;</span>
<span class="line" id="L1600"></span>
<span class="line" id="L1601">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">usize</span>, <span class="tok-number">120</span>), <span class="tok-builtin">@sizeOf</span>(linux.io_uring_params));</span>
<span class="line" id="L1602">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">usize</span>, <span class="tok-number">64</span>), <span class="tok-builtin">@sizeOf</span>(linux.io_uring_sqe));</span>
<span class="line" id="L1603">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">usize</span>, <span class="tok-number">16</span>), <span class="tok-builtin">@sizeOf</span>(linux.io_uring_cqe));</span>
<span class="line" id="L1604"></span>
<span class="line" id="L1605">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-number">0</span>, linux.IORING_OFF_SQ_RING);</span>
<span class="line" id="L1606">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-number">0x8000000</span>, linux.IORING_OFF_CQ_RING);</span>
<span class="line" id="L1607">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-number">0x10000000</span>, linux.IORING_OFF_SQES);</span>
<span class="line" id="L1608"></span>
<span class="line" id="L1609">    <span class="tok-kw">try</span> testing.expectError(<span class="tok-kw">error</span>.EntriesZero, IO_Uring.init(<span class="tok-number">0</span>, <span class="tok-number">0</span>));</span>
<span class="line" id="L1610">    <span class="tok-kw">try</span> testing.expectError(<span class="tok-kw">error</span>.EntriesNotPowerOfTwo, IO_Uring.init(<span class="tok-number">3</span>, <span class="tok-number">0</span>));</span>
<span class="line" id="L1611">}</span>
<span class="line" id="L1612"></span>
<span class="line" id="L1613"><span class="tok-kw">test</span> <span class="tok-str">&quot;nop&quot;</span> {</span>
<span class="line" id="L1614">    <span class="tok-kw">if</span> (builtin.os.tag != .linux) <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SkipZigTest;</span>
<span class="line" id="L1615"></span>
<span class="line" id="L1616">    <span class="tok-kw">var</span> ring = IO_Uring.init(<span class="tok-number">1</span>, <span class="tok-number">0</span>) <span class="tok-kw">catch</span> |err| <span class="tok-kw">switch</span> (err) {</span>
<span class="line" id="L1617">        <span class="tok-kw">error</span>.SystemOutdated =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SkipZigTest,</span>
<span class="line" id="L1618">        <span class="tok-kw">error</span>.PermissionDenied =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SkipZigTest,</span>
<span class="line" id="L1619">        <span class="tok-kw">else</span> =&gt; <span class="tok-kw">return</span> err,</span>
<span class="line" id="L1620">    };</span>
<span class="line" id="L1621">    <span class="tok-kw">defer</span> {</span>
<span class="line" id="L1622">        ring.deinit();</span>
<span class="line" id="L1623">        testing.expectEqual(<span class="tok-builtin">@as</span>(os.fd_t, -<span class="tok-number">1</span>), ring.fd) <span class="tok-kw">catch</span> <span class="tok-builtin">@panic</span>(<span class="tok-str">&quot;test failed&quot;</span>);</span>
<span class="line" id="L1624">    }</span>
<span class="line" id="L1625"></span>
<span class="line" id="L1626">    <span class="tok-kw">const</span> sqe = <span class="tok-kw">try</span> ring.nop(<span class="tok-number">0xaaaaaaaa</span>);</span>
<span class="line" id="L1627">    <span class="tok-kw">try</span> testing.expectEqual(linux.io_uring_sqe{</span>
<span class="line" id="L1628">        .opcode = .NOP,</span>
<span class="line" id="L1629">        .flags = <span class="tok-number">0</span>,</span>
<span class="line" id="L1630">        .ioprio = <span class="tok-number">0</span>,</span>
<span class="line" id="L1631">        .fd = <span class="tok-number">0</span>,</span>
<span class="line" id="L1632">        .off = <span class="tok-number">0</span>,</span>
<span class="line" id="L1633">        .addr = <span class="tok-number">0</span>,</span>
<span class="line" id="L1634">        .len = <span class="tok-number">0</span>,</span>
<span class="line" id="L1635">        .rw_flags = <span class="tok-number">0</span>,</span>
<span class="line" id="L1636">        .user_data = <span class="tok-number">0xaaaaaaaa</span>,</span>
<span class="line" id="L1637">        .buf_index = <span class="tok-number">0</span>,</span>
<span class="line" id="L1638">        .personality = <span class="tok-number">0</span>,</span>
<span class="line" id="L1639">        .splice_fd_in = <span class="tok-number">0</span>,</span>
<span class="line" id="L1640">        .__pad2 = [<span class="tok-number">2</span>]<span class="tok-type">u64</span>{ <span class="tok-number">0</span>, <span class="tok-number">0</span> },</span>
<span class="line" id="L1641">    }, sqe.*);</span>
<span class="line" id="L1642"></span>
<span class="line" id="L1643">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">0</span>), ring.sq.sqe_head);</span>
<span class="line" id="L1644">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">1</span>), ring.sq.sqe_tail);</span>
<span class="line" id="L1645">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">0</span>), ring.sq.tail.*);</span>
<span class="line" id="L1646">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">0</span>), ring.cq.head.*);</span>
<span class="line" id="L1647">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">1</span>), ring.sq_ready());</span>
<span class="line" id="L1648">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">0</span>), ring.cq_ready());</span>
<span class="line" id="L1649"></span>
<span class="line" id="L1650">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">1</span>), <span class="tok-kw">try</span> ring.submit());</span>
<span class="line" id="L1651">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">1</span>), ring.sq.sqe_head);</span>
<span class="line" id="L1652">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">1</span>), ring.sq.sqe_tail);</span>
<span class="line" id="L1653">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">1</span>), ring.sq.tail.*);</span>
<span class="line" id="L1654">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">0</span>), ring.cq.head.*);</span>
<span class="line" id="L1655">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">0</span>), ring.sq_ready());</span>
<span class="line" id="L1656"></span>
<span class="line" id="L1657">    <span class="tok-kw">try</span> testing.expectEqual(linux.io_uring_cqe{</span>
<span class="line" id="L1658">        .user_data = <span class="tok-number">0xaaaaaaaa</span>,</span>
<span class="line" id="L1659">        .res = <span class="tok-number">0</span>,</span>
<span class="line" id="L1660">        .flags = <span class="tok-number">0</span>,</span>
<span class="line" id="L1661">    }, <span class="tok-kw">try</span> ring.copy_cqe());</span>
<span class="line" id="L1662">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">1</span>), ring.cq.head.*);</span>
<span class="line" id="L1663">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">0</span>), ring.cq_ready());</span>
<span class="line" id="L1664"></span>
<span class="line" id="L1665">    <span class="tok-kw">const</span> sqe_barrier = <span class="tok-kw">try</span> ring.nop(<span class="tok-number">0xbbbbbbbb</span>);</span>
<span class="line" id="L1666">    sqe_barrier.flags |= linux.IOSQE_IO_DRAIN;</span>
<span class="line" id="L1667">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">1</span>), <span class="tok-kw">try</span> ring.submit());</span>
<span class="line" id="L1668">    <span class="tok-kw">try</span> testing.expectEqual(linux.io_uring_cqe{</span>
<span class="line" id="L1669">        .user_data = <span class="tok-number">0xbbbbbbbb</span>,</span>
<span class="line" id="L1670">        .res = <span class="tok-number">0</span>,</span>
<span class="line" id="L1671">        .flags = <span class="tok-number">0</span>,</span>
<span class="line" id="L1672">    }, <span class="tok-kw">try</span> ring.copy_cqe());</span>
<span class="line" id="L1673">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">2</span>), ring.sq.sqe_head);</span>
<span class="line" id="L1674">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">2</span>), ring.sq.sqe_tail);</span>
<span class="line" id="L1675">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">2</span>), ring.sq.tail.*);</span>
<span class="line" id="L1676">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">2</span>), ring.cq.head.*);</span>
<span class="line" id="L1677">}</span>
<span class="line" id="L1678"></span>
<span class="line" id="L1679"><span class="tok-kw">test</span> <span class="tok-str">&quot;readv&quot;</span> {</span>
<span class="line" id="L1680">    <span class="tok-kw">if</span> (builtin.os.tag != .linux) <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SkipZigTest;</span>
<span class="line" id="L1681"></span>
<span class="line" id="L1682">    <span class="tok-kw">var</span> ring = IO_Uring.init(<span class="tok-number">1</span>, <span class="tok-number">0</span>) <span class="tok-kw">catch</span> |err| <span class="tok-kw">switch</span> (err) {</span>
<span class="line" id="L1683">        <span class="tok-kw">error</span>.SystemOutdated =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SkipZigTest,</span>
<span class="line" id="L1684">        <span class="tok-kw">error</span>.PermissionDenied =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SkipZigTest,</span>
<span class="line" id="L1685">        <span class="tok-kw">else</span> =&gt; <span class="tok-kw">return</span> err,</span>
<span class="line" id="L1686">    };</span>
<span class="line" id="L1687">    <span class="tok-kw">defer</span> ring.deinit();</span>
<span class="line" id="L1688"></span>
<span class="line" id="L1689">    <span class="tok-kw">const</span> fd = <span class="tok-kw">try</span> os.openZ(<span class="tok-str">&quot;/dev/zero&quot;</span>, os.O.RDONLY | os.O.CLOEXEC, <span class="tok-number">0</span>);</span>
<span class="line" id="L1690">    <span class="tok-kw">defer</span> os.close(fd);</span>
<span class="line" id="L1691"></span>
<span class="line" id="L1692">    <span class="tok-comment">// Linux Kernel 5.4 supports IORING_REGISTER_FILES but not sparse fd sets (i.e. an fd of -1).</span>
</span>
<span class="line" id="L1693">    <span class="tok-comment">// Linux Kernel 5.5 adds support for sparse fd sets.</span>
</span>
<span class="line" id="L1694">    <span class="tok-comment">// Compare:</span>
</span>
<span class="line" id="L1695">    <span class="tok-comment">// https://github.com/torvalds/linux/blob/v5.4/fs/io_uring.c#L3119-L3124 vs</span>
</span>
<span class="line" id="L1696">    <span class="tok-comment">// https://github.com/torvalds/linux/blob/v5.8/fs/io_uring.c#L6687-L6691</span>
</span>
<span class="line" id="L1697">    <span class="tok-comment">// We therefore avoid stressing sparse fd sets here:</span>
</span>
<span class="line" id="L1698">    <span class="tok-kw">var</span> registered_fds = [_]os.fd_t{<span class="tok-number">0</span>} ** <span class="tok-number">1</span>;</span>
<span class="line" id="L1699">    <span class="tok-kw">const</span> fd_index = <span class="tok-number">0</span>;</span>
<span class="line" id="L1700">    registered_fds[fd_index] = fd;</span>
<span class="line" id="L1701">    <span class="tok-kw">try</span> ring.register_files(registered_fds[<span class="tok-number">0</span>..]);</span>
<span class="line" id="L1702"></span>
<span class="line" id="L1703">    <span class="tok-kw">var</span> buffer = [_]<span class="tok-type">u8</span>{<span class="tok-number">42</span>} ** <span class="tok-number">128</span>;</span>
<span class="line" id="L1704">    <span class="tok-kw">var</span> iovecs = [_]os.iovec{os.iovec{ .iov_base = &amp;buffer, .iov_len = buffer.len }};</span>
<span class="line" id="L1705">    <span class="tok-kw">const</span> sqe = <span class="tok-kw">try</span> ring.read(<span class="tok-number">0xcccccccc</span>, fd_index, .{ .iovecs = iovecs[<span class="tok-number">0</span>..] }, <span class="tok-number">0</span>);</span>
<span class="line" id="L1706">    <span class="tok-kw">try</span> testing.expectEqual(linux.IORING_OP.READV, sqe.opcode);</span>
<span class="line" id="L1707">    sqe.flags |= linux.IOSQE_FIXED_FILE;</span>
<span class="line" id="L1708"></span>
<span class="line" id="L1709">    <span class="tok-kw">try</span> testing.expectError(<span class="tok-kw">error</span>.SubmissionQueueFull, ring.nop(<span class="tok-number">0</span>));</span>
<span class="line" id="L1710">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">1</span>), <span class="tok-kw">try</span> ring.submit());</span>
<span class="line" id="L1711">    <span class="tok-kw">try</span> testing.expectEqual(linux.io_uring_cqe{</span>
<span class="line" id="L1712">        .user_data = <span class="tok-number">0xcccccccc</span>,</span>
<span class="line" id="L1713">        .res = buffer.len,</span>
<span class="line" id="L1714">        .flags = <span class="tok-number">0</span>,</span>
<span class="line" id="L1715">    }, <span class="tok-kw">try</span> ring.copy_cqe());</span>
<span class="line" id="L1716">    <span class="tok-kw">try</span> testing.expectEqualSlices(<span class="tok-type">u8</span>, &amp;([_]<span class="tok-type">u8</span>{<span class="tok-number">0</span>} ** buffer.len), buffer[<span class="tok-number">0</span>..]);</span>
<span class="line" id="L1717"></span>
<span class="line" id="L1718">    <span class="tok-kw">try</span> ring.unregister_files();</span>
<span class="line" id="L1719">}</span>
<span class="line" id="L1720"></span>
<span class="line" id="L1721"><span class="tok-kw">test</span> <span class="tok-str">&quot;writev/fsync/readv&quot;</span> {</span>
<span class="line" id="L1722">    <span class="tok-kw">if</span> (builtin.os.tag != .linux) <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SkipZigTest;</span>
<span class="line" id="L1723"></span>
<span class="line" id="L1724">    <span class="tok-kw">var</span> ring = IO_Uring.init(<span class="tok-number">4</span>, <span class="tok-number">0</span>) <span class="tok-kw">catch</span> |err| <span class="tok-kw">switch</span> (err) {</span>
<span class="line" id="L1725">        <span class="tok-kw">error</span>.SystemOutdated =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SkipZigTest,</span>
<span class="line" id="L1726">        <span class="tok-kw">error</span>.PermissionDenied =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SkipZigTest,</span>
<span class="line" id="L1727">        <span class="tok-kw">else</span> =&gt; <span class="tok-kw">return</span> err,</span>
<span class="line" id="L1728">    };</span>
<span class="line" id="L1729">    <span class="tok-kw">defer</span> ring.deinit();</span>
<span class="line" id="L1730"></span>
<span class="line" id="L1731">    <span class="tok-kw">const</span> path = <span class="tok-str">&quot;test_io_uring_writev_fsync_readv&quot;</span>;</span>
<span class="line" id="L1732">    <span class="tok-kw">const</span> file = <span class="tok-kw">try</span> std.fs.cwd().createFile(path, .{ .read = <span class="tok-null">true</span>, .truncate = <span class="tok-null">true</span> });</span>
<span class="line" id="L1733">    <span class="tok-kw">defer</span> file.close();</span>
<span class="line" id="L1734">    <span class="tok-kw">defer</span> std.fs.cwd().deleteFile(path) <span class="tok-kw">catch</span> {};</span>
<span class="line" id="L1735">    <span class="tok-kw">const</span> fd = file.handle;</span>
<span class="line" id="L1736"></span>
<span class="line" id="L1737">    <span class="tok-kw">const</span> buffer_write = [_]<span class="tok-type">u8</span>{<span class="tok-number">42</span>} ** <span class="tok-number">128</span>;</span>
<span class="line" id="L1738">    <span class="tok-kw">const</span> iovecs_write = [_]os.iovec_const{</span>
<span class="line" id="L1739">        os.iovec_const{ .iov_base = &amp;buffer_write, .iov_len = buffer_write.len },</span>
<span class="line" id="L1740">    };</span>
<span class="line" id="L1741">    <span class="tok-kw">var</span> buffer_read = [_]<span class="tok-type">u8</span>{<span class="tok-number">0</span>} ** <span class="tok-number">128</span>;</span>
<span class="line" id="L1742">    <span class="tok-kw">var</span> iovecs_read = [_]os.iovec{</span>
<span class="line" id="L1743">        os.iovec{ .iov_base = &amp;buffer_read, .iov_len = buffer_read.len },</span>
<span class="line" id="L1744">    };</span>
<span class="line" id="L1745"></span>
<span class="line" id="L1746">    <span class="tok-kw">const</span> sqe_writev = <span class="tok-kw">try</span> ring.writev(<span class="tok-number">0xdddddddd</span>, fd, iovecs_write[<span class="tok-number">0</span>..], <span class="tok-number">17</span>);</span>
<span class="line" id="L1747">    <span class="tok-kw">try</span> testing.expectEqual(linux.IORING_OP.WRITEV, sqe_writev.opcode);</span>
<span class="line" id="L1748">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">u64</span>, <span class="tok-number">17</span>), sqe_writev.off);</span>
<span class="line" id="L1749">    sqe_writev.flags |= linux.IOSQE_IO_LINK;</span>
<span class="line" id="L1750"></span>
<span class="line" id="L1751">    <span class="tok-kw">const</span> sqe_fsync = <span class="tok-kw">try</span> ring.fsync(<span class="tok-number">0xeeeeeeee</span>, fd, <span class="tok-number">0</span>);</span>
<span class="line" id="L1752">    <span class="tok-kw">try</span> testing.expectEqual(linux.IORING_OP.FSYNC, sqe_fsync.opcode);</span>
<span class="line" id="L1753">    <span class="tok-kw">try</span> testing.expectEqual(fd, sqe_fsync.fd);</span>
<span class="line" id="L1754">    sqe_fsync.flags |= linux.IOSQE_IO_LINK;</span>
<span class="line" id="L1755"></span>
<span class="line" id="L1756">    <span class="tok-kw">const</span> sqe_readv = <span class="tok-kw">try</span> ring.read(<span class="tok-number">0xffffffff</span>, fd, .{ .iovecs = iovecs_read[<span class="tok-number">0</span>..] }, <span class="tok-number">17</span>);</span>
<span class="line" id="L1757">    <span class="tok-kw">try</span> testing.expectEqual(linux.IORING_OP.READV, sqe_readv.opcode);</span>
<span class="line" id="L1758">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">u64</span>, <span class="tok-number">17</span>), sqe_readv.off);</span>
<span class="line" id="L1759"></span>
<span class="line" id="L1760">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">3</span>), ring.sq_ready());</span>
<span class="line" id="L1761">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">3</span>), <span class="tok-kw">try</span> ring.submit_and_wait(<span class="tok-number">3</span>));</span>
<span class="line" id="L1762">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">0</span>), ring.sq_ready());</span>
<span class="line" id="L1763">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">3</span>), ring.cq_ready());</span>
<span class="line" id="L1764"></span>
<span class="line" id="L1765">    <span class="tok-kw">try</span> testing.expectEqual(linux.io_uring_cqe{</span>
<span class="line" id="L1766">        .user_data = <span class="tok-number">0xdddddddd</span>,</span>
<span class="line" id="L1767">        .res = buffer_write.len,</span>
<span class="line" id="L1768">        .flags = <span class="tok-number">0</span>,</span>
<span class="line" id="L1769">    }, <span class="tok-kw">try</span> ring.copy_cqe());</span>
<span class="line" id="L1770">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">2</span>), ring.cq_ready());</span>
<span class="line" id="L1771"></span>
<span class="line" id="L1772">    <span class="tok-kw">try</span> testing.expectEqual(linux.io_uring_cqe{</span>
<span class="line" id="L1773">        .user_data = <span class="tok-number">0xeeeeeeee</span>,</span>
<span class="line" id="L1774">        .res = <span class="tok-number">0</span>,</span>
<span class="line" id="L1775">        .flags = <span class="tok-number">0</span>,</span>
<span class="line" id="L1776">    }, <span class="tok-kw">try</span> ring.copy_cqe());</span>
<span class="line" id="L1777">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">1</span>), ring.cq_ready());</span>
<span class="line" id="L1778"></span>
<span class="line" id="L1779">    <span class="tok-kw">try</span> testing.expectEqual(linux.io_uring_cqe{</span>
<span class="line" id="L1780">        .user_data = <span class="tok-number">0xffffffff</span>,</span>
<span class="line" id="L1781">        .res = buffer_read.len,</span>
<span class="line" id="L1782">        .flags = <span class="tok-number">0</span>,</span>
<span class="line" id="L1783">    }, <span class="tok-kw">try</span> ring.copy_cqe());</span>
<span class="line" id="L1784">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">0</span>), ring.cq_ready());</span>
<span class="line" id="L1785"></span>
<span class="line" id="L1786">    <span class="tok-kw">try</span> testing.expectEqualSlices(<span class="tok-type">u8</span>, buffer_write[<span class="tok-number">0</span>..], buffer_read[<span class="tok-number">0</span>..]);</span>
<span class="line" id="L1787">}</span>
<span class="line" id="L1788"></span>
<span class="line" id="L1789"><span class="tok-kw">test</span> <span class="tok-str">&quot;write/read&quot;</span> {</span>
<span class="line" id="L1790">    <span class="tok-kw">if</span> (builtin.os.tag != .linux) <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SkipZigTest;</span>
<span class="line" id="L1791"></span>
<span class="line" id="L1792">    <span class="tok-kw">var</span> ring = IO_Uring.init(<span class="tok-number">2</span>, <span class="tok-number">0</span>) <span class="tok-kw">catch</span> |err| <span class="tok-kw">switch</span> (err) {</span>
<span class="line" id="L1793">        <span class="tok-kw">error</span>.SystemOutdated =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SkipZigTest,</span>
<span class="line" id="L1794">        <span class="tok-kw">error</span>.PermissionDenied =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SkipZigTest,</span>
<span class="line" id="L1795">        <span class="tok-kw">else</span> =&gt; <span class="tok-kw">return</span> err,</span>
<span class="line" id="L1796">    };</span>
<span class="line" id="L1797">    <span class="tok-kw">defer</span> ring.deinit();</span>
<span class="line" id="L1798"></span>
<span class="line" id="L1799">    <span class="tok-kw">const</span> path = <span class="tok-str">&quot;test_io_uring_write_read&quot;</span>;</span>
<span class="line" id="L1800">    <span class="tok-kw">const</span> file = <span class="tok-kw">try</span> std.fs.cwd().createFile(path, .{ .read = <span class="tok-null">true</span>, .truncate = <span class="tok-null">true</span> });</span>
<span class="line" id="L1801">    <span class="tok-kw">defer</span> file.close();</span>
<span class="line" id="L1802">    <span class="tok-kw">defer</span> std.fs.cwd().deleteFile(path) <span class="tok-kw">catch</span> {};</span>
<span class="line" id="L1803">    <span class="tok-kw">const</span> fd = file.handle;</span>
<span class="line" id="L1804"></span>
<span class="line" id="L1805">    <span class="tok-kw">const</span> buffer_write = [_]<span class="tok-type">u8</span>{<span class="tok-number">97</span>} ** <span class="tok-number">20</span>;</span>
<span class="line" id="L1806">    <span class="tok-kw">var</span> buffer_read = [_]<span class="tok-type">u8</span>{<span class="tok-number">98</span>} ** <span class="tok-number">20</span>;</span>
<span class="line" id="L1807">    <span class="tok-kw">const</span> sqe_write = <span class="tok-kw">try</span> ring.write(<span class="tok-number">0x11111111</span>, fd, buffer_write[<span class="tok-number">0</span>..], <span class="tok-number">10</span>);</span>
<span class="line" id="L1808">    <span class="tok-kw">try</span> testing.expectEqual(linux.IORING_OP.WRITE, sqe_write.opcode);</span>
<span class="line" id="L1809">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">u64</span>, <span class="tok-number">10</span>), sqe_write.off);</span>
<span class="line" id="L1810">    sqe_write.flags |= linux.IOSQE_IO_LINK;</span>
<span class="line" id="L1811">    <span class="tok-kw">const</span> sqe_read = <span class="tok-kw">try</span> ring.read(<span class="tok-number">0x22222222</span>, fd, .{ .buffer = buffer_read[<span class="tok-number">0</span>..] }, <span class="tok-number">10</span>);</span>
<span class="line" id="L1812">    <span class="tok-kw">try</span> testing.expectEqual(linux.IORING_OP.READ, sqe_read.opcode);</span>
<span class="line" id="L1813">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">u64</span>, <span class="tok-number">10</span>), sqe_read.off);</span>
<span class="line" id="L1814">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">2</span>), <span class="tok-kw">try</span> ring.submit());</span>
<span class="line" id="L1815"></span>
<span class="line" id="L1816">    <span class="tok-kw">const</span> cqe_write = <span class="tok-kw">try</span> ring.copy_cqe();</span>
<span class="line" id="L1817">    <span class="tok-kw">const</span> cqe_read = <span class="tok-kw">try</span> ring.copy_cqe();</span>
<span class="line" id="L1818">    <span class="tok-comment">// Prior to Linux Kernel 5.6 this is the only way to test for read/write support:</span>
</span>
<span class="line" id="L1819">    <span class="tok-comment">// https://lwn.net/Articles/809820/</span>
</span>
<span class="line" id="L1820">    <span class="tok-kw">if</span> (cqe_write.err() == .INVAL) <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SkipZigTest;</span>
<span class="line" id="L1821">    <span class="tok-kw">if</span> (cqe_read.err() == .INVAL) <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SkipZigTest;</span>
<span class="line" id="L1822">    <span class="tok-kw">try</span> testing.expectEqual(linux.io_uring_cqe{</span>
<span class="line" id="L1823">        .user_data = <span class="tok-number">0x11111111</span>,</span>
<span class="line" id="L1824">        .res = buffer_write.len,</span>
<span class="line" id="L1825">        .flags = <span class="tok-number">0</span>,</span>
<span class="line" id="L1826">    }, cqe_write);</span>
<span class="line" id="L1827">    <span class="tok-kw">try</span> testing.expectEqual(linux.io_uring_cqe{</span>
<span class="line" id="L1828">        .user_data = <span class="tok-number">0x22222222</span>,</span>
<span class="line" id="L1829">        .res = buffer_read.len,</span>
<span class="line" id="L1830">        .flags = <span class="tok-number">0</span>,</span>
<span class="line" id="L1831">    }, cqe_read);</span>
<span class="line" id="L1832">    <span class="tok-kw">try</span> testing.expectEqualSlices(<span class="tok-type">u8</span>, buffer_write[<span class="tok-number">0</span>..], buffer_read[<span class="tok-number">0</span>..]);</span>
<span class="line" id="L1833">}</span>
<span class="line" id="L1834"></span>
<span class="line" id="L1835"><span class="tok-kw">test</span> <span class="tok-str">&quot;write_fixed/read_fixed&quot;</span> {</span>
<span class="line" id="L1836">    <span class="tok-kw">if</span> (builtin.os.tag != .linux) <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SkipZigTest;</span>
<span class="line" id="L1837"></span>
<span class="line" id="L1838">    <span class="tok-kw">var</span> ring = IO_Uring.init(<span class="tok-number">2</span>, <span class="tok-number">0</span>) <span class="tok-kw">catch</span> |err| <span class="tok-kw">switch</span> (err) {</span>
<span class="line" id="L1839">        <span class="tok-kw">error</span>.SystemOutdated =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SkipZigTest,</span>
<span class="line" id="L1840">        <span class="tok-kw">error</span>.PermissionDenied =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SkipZigTest,</span>
<span class="line" id="L1841">        <span class="tok-kw">else</span> =&gt; <span class="tok-kw">return</span> err,</span>
<span class="line" id="L1842">    };</span>
<span class="line" id="L1843">    <span class="tok-kw">defer</span> ring.deinit();</span>
<span class="line" id="L1844"></span>
<span class="line" id="L1845">    <span class="tok-kw">const</span> path = <span class="tok-str">&quot;test_io_uring_write_read_fixed&quot;</span>;</span>
<span class="line" id="L1846">    <span class="tok-kw">const</span> file = <span class="tok-kw">try</span> std.fs.cwd().createFile(path, .{ .read = <span class="tok-null">true</span>, .truncate = <span class="tok-null">true</span> });</span>
<span class="line" id="L1847">    <span class="tok-kw">defer</span> file.close();</span>
<span class="line" id="L1848">    <span class="tok-kw">defer</span> std.fs.cwd().deleteFile(path) <span class="tok-kw">catch</span> {};</span>
<span class="line" id="L1849">    <span class="tok-kw">const</span> fd = file.handle;</span>
<span class="line" id="L1850"></span>
<span class="line" id="L1851">    <span class="tok-kw">var</span> raw_buffers: [<span class="tok-number">2</span>][<span class="tok-number">11</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L1852">    <span class="tok-comment">// First buffer will be written to the file.</span>
</span>
<span class="line" id="L1853">    std.mem.set(<span class="tok-type">u8</span>, &amp;raw_buffers[<span class="tok-number">0</span>], <span class="tok-str">'z'</span>);</span>
<span class="line" id="L1854">    std.mem.copy(<span class="tok-type">u8</span>, &amp;raw_buffers[<span class="tok-number">0</span>], <span class="tok-str">&quot;foobar&quot;</span>);</span>
<span class="line" id="L1855"></span>
<span class="line" id="L1856">    <span class="tok-kw">var</span> buffers = [<span class="tok-number">2</span>]os.iovec{</span>
<span class="line" id="L1857">        .{ .iov_base = &amp;raw_buffers[<span class="tok-number">0</span>], .iov_len = raw_buffers[<span class="tok-number">0</span>].len },</span>
<span class="line" id="L1858">        .{ .iov_base = &amp;raw_buffers[<span class="tok-number">1</span>], .iov_len = raw_buffers[<span class="tok-number">1</span>].len },</span>
<span class="line" id="L1859">    };</span>
<span class="line" id="L1860">    <span class="tok-kw">try</span> ring.register_buffers(&amp;buffers);</span>
<span class="line" id="L1861"></span>
<span class="line" id="L1862">    <span class="tok-kw">const</span> sqe_write = <span class="tok-kw">try</span> ring.write_fixed(<span class="tok-number">0x45454545</span>, fd, &amp;buffers[<span class="tok-number">0</span>], <span class="tok-number">3</span>, <span class="tok-number">0</span>);</span>
<span class="line" id="L1863">    <span class="tok-kw">try</span> testing.expectEqual(linux.IORING_OP.WRITE_FIXED, sqe_write.opcode);</span>
<span class="line" id="L1864">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">u64</span>, <span class="tok-number">3</span>), sqe_write.off);</span>
<span class="line" id="L1865">    sqe_write.flags |= linux.IOSQE_IO_LINK;</span>
<span class="line" id="L1866"></span>
<span class="line" id="L1867">    <span class="tok-kw">const</span> sqe_read = <span class="tok-kw">try</span> ring.read_fixed(<span class="tok-number">0x12121212</span>, fd, &amp;buffers[<span class="tok-number">1</span>], <span class="tok-number">0</span>, <span class="tok-number">1</span>);</span>
<span class="line" id="L1868">    <span class="tok-kw">try</span> testing.expectEqual(linux.IORING_OP.READ_FIXED, sqe_read.opcode);</span>
<span class="line" id="L1869">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">u64</span>, <span class="tok-number">0</span>), sqe_read.off);</span>
<span class="line" id="L1870"></span>
<span class="line" id="L1871">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">2</span>), <span class="tok-kw">try</span> ring.submit());</span>
<span class="line" id="L1872"></span>
<span class="line" id="L1873">    <span class="tok-kw">const</span> cqe_write = <span class="tok-kw">try</span> ring.copy_cqe();</span>
<span class="line" id="L1874">    <span class="tok-kw">const</span> cqe_read = <span class="tok-kw">try</span> ring.copy_cqe();</span>
<span class="line" id="L1875"></span>
<span class="line" id="L1876">    <span class="tok-kw">try</span> testing.expectEqual(linux.io_uring_cqe{</span>
<span class="line" id="L1877">        .user_data = <span class="tok-number">0x45454545</span>,</span>
<span class="line" id="L1878">        .res = <span class="tok-builtin">@intCast</span>(<span class="tok-type">i32</span>, buffers[<span class="tok-number">0</span>].iov_len),</span>
<span class="line" id="L1879">        .flags = <span class="tok-number">0</span>,</span>
<span class="line" id="L1880">    }, cqe_write);</span>
<span class="line" id="L1881">    <span class="tok-kw">try</span> testing.expectEqual(linux.io_uring_cqe{</span>
<span class="line" id="L1882">        .user_data = <span class="tok-number">0x12121212</span>,</span>
<span class="line" id="L1883">        .res = <span class="tok-builtin">@intCast</span>(<span class="tok-type">i32</span>, buffers[<span class="tok-number">1</span>].iov_len),</span>
<span class="line" id="L1884">        .flags = <span class="tok-number">0</span>,</span>
<span class="line" id="L1885">    }, cqe_read);</span>
<span class="line" id="L1886"></span>
<span class="line" id="L1887">    <span class="tok-kw">try</span> testing.expectEqualSlices(<span class="tok-type">u8</span>, <span class="tok-str">&quot;\x00\x00\x00&quot;</span>, buffers[<span class="tok-number">1</span>].iov_base[<span class="tok-number">0</span>..<span class="tok-number">3</span>]);</span>
<span class="line" id="L1888">    <span class="tok-kw">try</span> testing.expectEqualSlices(<span class="tok-type">u8</span>, <span class="tok-str">&quot;foobar&quot;</span>, buffers[<span class="tok-number">1</span>].iov_base[<span class="tok-number">3</span>..<span class="tok-number">9</span>]);</span>
<span class="line" id="L1889">    <span class="tok-kw">try</span> testing.expectEqualSlices(<span class="tok-type">u8</span>, <span class="tok-str">&quot;zz&quot;</span>, buffers[<span class="tok-number">1</span>].iov_base[<span class="tok-number">9</span>..<span class="tok-number">11</span>]);</span>
<span class="line" id="L1890">}</span>
<span class="line" id="L1891"></span>
<span class="line" id="L1892"><span class="tok-kw">test</span> <span class="tok-str">&quot;openat&quot;</span> {</span>
<span class="line" id="L1893">    <span class="tok-kw">if</span> (builtin.os.tag != .linux) <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SkipZigTest;</span>
<span class="line" id="L1894"></span>
<span class="line" id="L1895">    <span class="tok-kw">var</span> ring = IO_Uring.init(<span class="tok-number">1</span>, <span class="tok-number">0</span>) <span class="tok-kw">catch</span> |err| <span class="tok-kw">switch</span> (err) {</span>
<span class="line" id="L1896">        <span class="tok-kw">error</span>.SystemOutdated =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SkipZigTest,</span>
<span class="line" id="L1897">        <span class="tok-kw">error</span>.PermissionDenied =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SkipZigTest,</span>
<span class="line" id="L1898">        <span class="tok-kw">else</span> =&gt; <span class="tok-kw">return</span> err,</span>
<span class="line" id="L1899">    };</span>
<span class="line" id="L1900">    <span class="tok-kw">defer</span> ring.deinit();</span>
<span class="line" id="L1901"></span>
<span class="line" id="L1902">    <span class="tok-kw">const</span> path = <span class="tok-str">&quot;test_io_uring_openat&quot;</span>;</span>
<span class="line" id="L1903">    <span class="tok-kw">defer</span> std.fs.cwd().deleteFile(path) <span class="tok-kw">catch</span> {};</span>
<span class="line" id="L1904"></span>
<span class="line" id="L1905">    <span class="tok-comment">// Workaround for LLVM bug: https://github.com/ziglang/zig/issues/12014</span>
</span>
<span class="line" id="L1906">    <span class="tok-kw">const</span> path_addr = <span class="tok-kw">if</span> (builtin.zig_backend == .stage2_llvm) p: {</span>
<span class="line" id="L1907">        <span class="tok-kw">var</span> workaround = path;</span>
<span class="line" id="L1908">        <span class="tok-kw">break</span> :p <span class="tok-builtin">@ptrToInt</span>(workaround);</span>
<span class="line" id="L1909">    } <span class="tok-kw">else</span> <span class="tok-builtin">@ptrToInt</span>(path);</span>
<span class="line" id="L1910"></span>
<span class="line" id="L1911">    <span class="tok-kw">const</span> flags: <span class="tok-type">u32</span> = os.O.CLOEXEC | os.O.RDWR | os.O.CREAT;</span>
<span class="line" id="L1912">    <span class="tok-kw">const</span> mode: os.mode_t = <span class="tok-number">0o666</span>;</span>
<span class="line" id="L1913">    <span class="tok-kw">const</span> sqe_openat = <span class="tok-kw">try</span> ring.openat(<span class="tok-number">0x33333333</span>, linux.AT.FDCWD, path, flags, mode);</span>
<span class="line" id="L1914">    <span class="tok-kw">try</span> testing.expectEqual(linux.io_uring_sqe{</span>
<span class="line" id="L1915">        .opcode = .OPENAT,</span>
<span class="line" id="L1916">        .flags = <span class="tok-number">0</span>,</span>
<span class="line" id="L1917">        .ioprio = <span class="tok-number">0</span>,</span>
<span class="line" id="L1918">        .fd = linux.AT.FDCWD,</span>
<span class="line" id="L1919">        .off = <span class="tok-number">0</span>,</span>
<span class="line" id="L1920">        .addr = path_addr,</span>
<span class="line" id="L1921">        .len = mode,</span>
<span class="line" id="L1922">        .rw_flags = flags,</span>
<span class="line" id="L1923">        .user_data = <span class="tok-number">0x33333333</span>,</span>
<span class="line" id="L1924">        .buf_index = <span class="tok-number">0</span>,</span>
<span class="line" id="L1925">        .personality = <span class="tok-number">0</span>,</span>
<span class="line" id="L1926">        .splice_fd_in = <span class="tok-number">0</span>,</span>
<span class="line" id="L1927">        .__pad2 = [<span class="tok-number">2</span>]<span class="tok-type">u64</span>{ <span class="tok-number">0</span>, <span class="tok-number">0</span> },</span>
<span class="line" id="L1928">    }, sqe_openat.*);</span>
<span class="line" id="L1929">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">1</span>), <span class="tok-kw">try</span> ring.submit());</span>
<span class="line" id="L1930"></span>
<span class="line" id="L1931">    <span class="tok-kw">const</span> cqe_openat = <span class="tok-kw">try</span> ring.copy_cqe();</span>
<span class="line" id="L1932">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">u64</span>, <span class="tok-number">0x33333333</span>), cqe_openat.user_data);</span>
<span class="line" id="L1933">    <span class="tok-kw">if</span> (cqe_openat.err() == .INVAL) <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SkipZigTest;</span>
<span class="line" id="L1934">    <span class="tok-comment">// AT.FDCWD is not fully supported before kernel 5.6:</span>
</span>
<span class="line" id="L1935">    <span class="tok-comment">// See https://lore.kernel.org/io-uring/20200207155039.12819-1-axboe@kernel.dk/T/</span>
</span>
<span class="line" id="L1936">    <span class="tok-comment">// We use IORING_FEAT_RW_CUR_POS to know if we are pre-5.6 since that feature was added in 5.6.</span>
</span>
<span class="line" id="L1937">    <span class="tok-kw">if</span> (cqe_openat.err() == .BADF <span class="tok-kw">and</span> (ring.features &amp; linux.IORING_FEAT_RW_CUR_POS) == <span class="tok-number">0</span>) {</span>
<span class="line" id="L1938">        <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SkipZigTest;</span>
<span class="line" id="L1939">    }</span>
<span class="line" id="L1940">    <span class="tok-kw">if</span> (cqe_openat.res &lt;= <span class="tok-number">0</span>) std.debug.print(<span class="tok-str">&quot;\ncqe_openat.res={}\n&quot;</span>, .{cqe_openat.res});</span>
<span class="line" id="L1941">    <span class="tok-kw">try</span> testing.expect(cqe_openat.res &gt; <span class="tok-number">0</span>);</span>
<span class="line" id="L1942">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">0</span>), cqe_openat.flags);</span>
<span class="line" id="L1943"></span>
<span class="line" id="L1944">    os.close(cqe_openat.res);</span>
<span class="line" id="L1945">}</span>
<span class="line" id="L1946"></span>
<span class="line" id="L1947"><span class="tok-kw">test</span> <span class="tok-str">&quot;close&quot;</span> {</span>
<span class="line" id="L1948">    <span class="tok-kw">if</span> (builtin.os.tag != .linux) <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SkipZigTest;</span>
<span class="line" id="L1949"></span>
<span class="line" id="L1950">    <span class="tok-kw">var</span> ring = IO_Uring.init(<span class="tok-number">1</span>, <span class="tok-number">0</span>) <span class="tok-kw">catch</span> |err| <span class="tok-kw">switch</span> (err) {</span>
<span class="line" id="L1951">        <span class="tok-kw">error</span>.SystemOutdated =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SkipZigTest,</span>
<span class="line" id="L1952">        <span class="tok-kw">error</span>.PermissionDenied =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SkipZigTest,</span>
<span class="line" id="L1953">        <span class="tok-kw">else</span> =&gt; <span class="tok-kw">return</span> err,</span>
<span class="line" id="L1954">    };</span>
<span class="line" id="L1955">    <span class="tok-kw">defer</span> ring.deinit();</span>
<span class="line" id="L1956"></span>
<span class="line" id="L1957">    <span class="tok-kw">const</span> path = <span class="tok-str">&quot;test_io_uring_close&quot;</span>;</span>
<span class="line" id="L1958">    <span class="tok-kw">const</span> file = <span class="tok-kw">try</span> std.fs.cwd().createFile(path, .{});</span>
<span class="line" id="L1959">    <span class="tok-kw">errdefer</span> file.close();</span>
<span class="line" id="L1960">    <span class="tok-kw">defer</span> std.fs.cwd().deleteFile(path) <span class="tok-kw">catch</span> {};</span>
<span class="line" id="L1961"></span>
<span class="line" id="L1962">    <span class="tok-kw">const</span> sqe_close = <span class="tok-kw">try</span> ring.close(<span class="tok-number">0x44444444</span>, file.handle);</span>
<span class="line" id="L1963">    <span class="tok-kw">try</span> testing.expectEqual(linux.IORING_OP.CLOSE, sqe_close.opcode);</span>
<span class="line" id="L1964">    <span class="tok-kw">try</span> testing.expectEqual(file.handle, sqe_close.fd);</span>
<span class="line" id="L1965">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">1</span>), <span class="tok-kw">try</span> ring.submit());</span>
<span class="line" id="L1966"></span>
<span class="line" id="L1967">    <span class="tok-kw">const</span> cqe_close = <span class="tok-kw">try</span> ring.copy_cqe();</span>
<span class="line" id="L1968">    <span class="tok-kw">if</span> (cqe_close.err() == .INVAL) <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SkipZigTest;</span>
<span class="line" id="L1969">    <span class="tok-kw">try</span> testing.expectEqual(linux.io_uring_cqe{</span>
<span class="line" id="L1970">        .user_data = <span class="tok-number">0x44444444</span>,</span>
<span class="line" id="L1971">        .res = <span class="tok-number">0</span>,</span>
<span class="line" id="L1972">        .flags = <span class="tok-number">0</span>,</span>
<span class="line" id="L1973">    }, cqe_close);</span>
<span class="line" id="L1974">}</span>
<span class="line" id="L1975"></span>
<span class="line" id="L1976"><span class="tok-kw">test</span> <span class="tok-str">&quot;accept/connect/send/recv&quot;</span> {</span>
<span class="line" id="L1977">    <span class="tok-kw">if</span> (builtin.os.tag != .linux) <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SkipZigTest;</span>
<span class="line" id="L1978"></span>
<span class="line" id="L1979">    <span class="tok-kw">var</span> ring = IO_Uring.init(<span class="tok-number">16</span>, <span class="tok-number">0</span>) <span class="tok-kw">catch</span> |err| <span class="tok-kw">switch</span> (err) {</span>
<span class="line" id="L1980">        <span class="tok-kw">error</span>.SystemOutdated =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SkipZigTest,</span>
<span class="line" id="L1981">        <span class="tok-kw">error</span>.PermissionDenied =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SkipZigTest,</span>
<span class="line" id="L1982">        <span class="tok-kw">else</span> =&gt; <span class="tok-kw">return</span> err,</span>
<span class="line" id="L1983">    };</span>
<span class="line" id="L1984">    <span class="tok-kw">defer</span> ring.deinit();</span>
<span class="line" id="L1985"></span>
<span class="line" id="L1986">    <span class="tok-kw">const</span> socket_test_harness = <span class="tok-kw">try</span> createSocketTestHarness(&amp;ring);</span>
<span class="line" id="L1987">    <span class="tok-kw">defer</span> socket_test_harness.close();</span>
<span class="line" id="L1988"></span>
<span class="line" id="L1989">    <span class="tok-kw">const</span> buffer_send = [_]<span class="tok-type">u8</span>{ <span class="tok-number">1</span>, <span class="tok-number">0</span>, <span class="tok-number">1</span>, <span class="tok-number">0</span>, <span class="tok-number">1</span>, <span class="tok-number">0</span>, <span class="tok-number">1</span>, <span class="tok-number">0</span>, <span class="tok-number">1</span>, <span class="tok-number">0</span> };</span>
<span class="line" id="L1990">    <span class="tok-kw">var</span> buffer_recv = [_]<span class="tok-type">u8</span>{ <span class="tok-number">0</span>, <span class="tok-number">1</span>, <span class="tok-number">0</span>, <span class="tok-number">1</span>, <span class="tok-number">0</span> };</span>
<span class="line" id="L1991"></span>
<span class="line" id="L1992">    <span class="tok-kw">const</span> send = <span class="tok-kw">try</span> ring.send(<span class="tok-number">0xeeeeeeee</span>, socket_test_harness.client, buffer_send[<span class="tok-number">0</span>..], <span class="tok-number">0</span>);</span>
<span class="line" id="L1993">    send.flags |= linux.IOSQE_IO_LINK;</span>
<span class="line" id="L1994">    _ = <span class="tok-kw">try</span> ring.recv(<span class="tok-number">0xffffffff</span>, socket_test_harness.server, .{ .buffer = buffer_recv[<span class="tok-number">0</span>..] }, <span class="tok-number">0</span>);</span>
<span class="line" id="L1995">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">2</span>), <span class="tok-kw">try</span> ring.submit());</span>
<span class="line" id="L1996"></span>
<span class="line" id="L1997">    <span class="tok-kw">const</span> cqe_send = <span class="tok-kw">try</span> ring.copy_cqe();</span>
<span class="line" id="L1998">    <span class="tok-kw">if</span> (cqe_send.err() == .INVAL) <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SkipZigTest;</span>
<span class="line" id="L1999">    <span class="tok-kw">try</span> testing.expectEqual(linux.io_uring_cqe{</span>
<span class="line" id="L2000">        .user_data = <span class="tok-number">0xeeeeeeee</span>,</span>
<span class="line" id="L2001">        .res = buffer_send.len,</span>
<span class="line" id="L2002">        .flags = <span class="tok-number">0</span>,</span>
<span class="line" id="L2003">    }, cqe_send);</span>
<span class="line" id="L2004"></span>
<span class="line" id="L2005">    <span class="tok-kw">const</span> cqe_recv = <span class="tok-kw">try</span> ring.copy_cqe();</span>
<span class="line" id="L2006">    <span class="tok-kw">if</span> (cqe_recv.err() == .INVAL) <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SkipZigTest;</span>
<span class="line" id="L2007">    <span class="tok-kw">try</span> testing.expectEqual(linux.io_uring_cqe{</span>
<span class="line" id="L2008">        .user_data = <span class="tok-number">0xffffffff</span>,</span>
<span class="line" id="L2009">        .res = buffer_recv.len,</span>
<span class="line" id="L2010">        .flags = <span class="tok-number">0</span>,</span>
<span class="line" id="L2011">    }, cqe_recv);</span>
<span class="line" id="L2012"></span>
<span class="line" id="L2013">    <span class="tok-kw">try</span> testing.expectEqualSlices(<span class="tok-type">u8</span>, buffer_send[<span class="tok-number">0</span>..buffer_recv.len], buffer_recv[<span class="tok-number">0</span>..]);</span>
<span class="line" id="L2014">}</span>
<span class="line" id="L2015"></span>
<span class="line" id="L2016"><span class="tok-kw">test</span> <span class="tok-str">&quot;sendmsg/recvmsg&quot;</span> {</span>
<span class="line" id="L2017">    <span class="tok-kw">if</span> (builtin.os.tag != .linux) <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SkipZigTest;</span>
<span class="line" id="L2018"></span>
<span class="line" id="L2019">    <span class="tok-kw">var</span> ring = IO_Uring.init(<span class="tok-number">2</span>, <span class="tok-number">0</span>) <span class="tok-kw">catch</span> |err| <span class="tok-kw">switch</span> (err) {</span>
<span class="line" id="L2020">        <span class="tok-kw">error</span>.SystemOutdated =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SkipZigTest,</span>
<span class="line" id="L2021">        <span class="tok-kw">error</span>.PermissionDenied =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SkipZigTest,</span>
<span class="line" id="L2022">        <span class="tok-kw">else</span> =&gt; <span class="tok-kw">return</span> err,</span>
<span class="line" id="L2023">    };</span>
<span class="line" id="L2024">    <span class="tok-kw">defer</span> ring.deinit();</span>
<span class="line" id="L2025"></span>
<span class="line" id="L2026">    <span class="tok-kw">const</span> address_server = <span class="tok-kw">try</span> net.Address.parseIp4(<span class="tok-str">&quot;127.0.0.1&quot;</span>, <span class="tok-number">3131</span>);</span>
<span class="line" id="L2027"></span>
<span class="line" id="L2028">    <span class="tok-kw">const</span> server = <span class="tok-kw">try</span> os.socket(address_server.any.family, os.SOCK.DGRAM, <span class="tok-number">0</span>);</span>
<span class="line" id="L2029">    <span class="tok-kw">defer</span> os.close(server);</span>
<span class="line" id="L2030">    <span class="tok-kw">try</span> os.setsockopt(server, os.SOL.SOCKET, os.SO.REUSEPORT, &amp;mem.toBytes(<span class="tok-builtin">@as</span>(<span class="tok-type">c_int</span>, <span class="tok-number">1</span>)));</span>
<span class="line" id="L2031">    <span class="tok-kw">try</span> os.setsockopt(server, os.SOL.SOCKET, os.SO.REUSEADDR, &amp;mem.toBytes(<span class="tok-builtin">@as</span>(<span class="tok-type">c_int</span>, <span class="tok-number">1</span>)));</span>
<span class="line" id="L2032">    <span class="tok-kw">try</span> os.bind(server, &amp;address_server.any, address_server.getOsSockLen());</span>
<span class="line" id="L2033"></span>
<span class="line" id="L2034">    <span class="tok-kw">const</span> client = <span class="tok-kw">try</span> os.socket(address_server.any.family, os.SOCK.DGRAM, <span class="tok-number">0</span>);</span>
<span class="line" id="L2035">    <span class="tok-kw">defer</span> os.close(client);</span>
<span class="line" id="L2036"></span>
<span class="line" id="L2037">    <span class="tok-kw">const</span> buffer_send = [_]<span class="tok-type">u8</span>{<span class="tok-number">42</span>} ** <span class="tok-number">128</span>;</span>
<span class="line" id="L2038">    <span class="tok-kw">const</span> iovecs_send = [_]os.iovec_const{</span>
<span class="line" id="L2039">        os.iovec_const{ .iov_base = &amp;buffer_send, .iov_len = buffer_send.len },</span>
<span class="line" id="L2040">    };</span>
<span class="line" id="L2041">    <span class="tok-kw">const</span> msg_send = os.msghdr_const{</span>
<span class="line" id="L2042">        .name = &amp;address_server.any,</span>
<span class="line" id="L2043">        .namelen = address_server.getOsSockLen(),</span>
<span class="line" id="L2044">        .iov = &amp;iovecs_send,</span>
<span class="line" id="L2045">        .iovlen = <span class="tok-number">1</span>,</span>
<span class="line" id="L2046">        .control = <span class="tok-null">null</span>,</span>
<span class="line" id="L2047">        .controllen = <span class="tok-number">0</span>,</span>
<span class="line" id="L2048">        .flags = <span class="tok-number">0</span>,</span>
<span class="line" id="L2049">    };</span>
<span class="line" id="L2050">    <span class="tok-kw">const</span> sqe_sendmsg = <span class="tok-kw">try</span> ring.sendmsg(<span class="tok-number">0x11111111</span>, client, &amp;msg_send, <span class="tok-number">0</span>);</span>
<span class="line" id="L2051">    sqe_sendmsg.flags |= linux.IOSQE_IO_LINK;</span>
<span class="line" id="L2052">    <span class="tok-kw">try</span> testing.expectEqual(linux.IORING_OP.SENDMSG, sqe_sendmsg.opcode);</span>
<span class="line" id="L2053">    <span class="tok-kw">try</span> testing.expectEqual(client, sqe_sendmsg.fd);</span>
<span class="line" id="L2054"></span>
<span class="line" id="L2055">    <span class="tok-kw">var</span> buffer_recv = [_]<span class="tok-type">u8</span>{<span class="tok-number">0</span>} ** <span class="tok-number">128</span>;</span>
<span class="line" id="L2056">    <span class="tok-kw">var</span> iovecs_recv = [_]os.iovec{</span>
<span class="line" id="L2057">        os.iovec{ .iov_base = &amp;buffer_recv, .iov_len = buffer_recv.len },</span>
<span class="line" id="L2058">    };</span>
<span class="line" id="L2059">    <span class="tok-kw">var</span> addr = [_]<span class="tok-type">u8</span>{<span class="tok-number">0</span>} ** <span class="tok-number">4</span>;</span>
<span class="line" id="L2060">    <span class="tok-kw">var</span> address_recv = net.Address.initIp4(addr, <span class="tok-number">0</span>);</span>
<span class="line" id="L2061">    <span class="tok-kw">var</span> msg_recv: os.msghdr = os.msghdr{</span>
<span class="line" id="L2062">        .name = &amp;address_recv.any,</span>
<span class="line" id="L2063">        .namelen = address_recv.getOsSockLen(),</span>
<span class="line" id="L2064">        .iov = &amp;iovecs_recv,</span>
<span class="line" id="L2065">        .iovlen = <span class="tok-number">1</span>,</span>
<span class="line" id="L2066">        .control = <span class="tok-null">null</span>,</span>
<span class="line" id="L2067">        .controllen = <span class="tok-number">0</span>,</span>
<span class="line" id="L2068">        .flags = <span class="tok-number">0</span>,</span>
<span class="line" id="L2069">    };</span>
<span class="line" id="L2070">    <span class="tok-kw">const</span> sqe_recvmsg = <span class="tok-kw">try</span> ring.recvmsg(<span class="tok-number">0x22222222</span>, server, &amp;msg_recv, <span class="tok-number">0</span>);</span>
<span class="line" id="L2071">    <span class="tok-kw">try</span> testing.expectEqual(linux.IORING_OP.RECVMSG, sqe_recvmsg.opcode);</span>
<span class="line" id="L2072">    <span class="tok-kw">try</span> testing.expectEqual(server, sqe_recvmsg.fd);</span>
<span class="line" id="L2073"></span>
<span class="line" id="L2074">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">2</span>), ring.sq_ready());</span>
<span class="line" id="L2075">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">2</span>), <span class="tok-kw">try</span> ring.submit_and_wait(<span class="tok-number">2</span>));</span>
<span class="line" id="L2076">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">0</span>), ring.sq_ready());</span>
<span class="line" id="L2077">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">2</span>), ring.cq_ready());</span>
<span class="line" id="L2078"></span>
<span class="line" id="L2079">    <span class="tok-kw">const</span> cqe_sendmsg = <span class="tok-kw">try</span> ring.copy_cqe();</span>
<span class="line" id="L2080">    <span class="tok-kw">if</span> (cqe_sendmsg.res == -<span class="tok-builtin">@as</span>(<span class="tok-type">i32</span>, <span class="tok-builtin">@enumToInt</span>(linux.E.INVAL))) <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SkipZigTest;</span>
<span class="line" id="L2081">    <span class="tok-kw">try</span> testing.expectEqual(linux.io_uring_cqe{</span>
<span class="line" id="L2082">        .user_data = <span class="tok-number">0x11111111</span>,</span>
<span class="line" id="L2083">        .res = buffer_send.len,</span>
<span class="line" id="L2084">        .flags = <span class="tok-number">0</span>,</span>
<span class="line" id="L2085">    }, cqe_sendmsg);</span>
<span class="line" id="L2086"></span>
<span class="line" id="L2087">    <span class="tok-kw">const</span> cqe_recvmsg = <span class="tok-kw">try</span> ring.copy_cqe();</span>
<span class="line" id="L2088">    <span class="tok-kw">if</span> (cqe_recvmsg.res == -<span class="tok-builtin">@as</span>(<span class="tok-type">i32</span>, <span class="tok-builtin">@enumToInt</span>(linux.E.INVAL))) <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SkipZigTest;</span>
<span class="line" id="L2089">    <span class="tok-kw">try</span> testing.expectEqual(linux.io_uring_cqe{</span>
<span class="line" id="L2090">        .user_data = <span class="tok-number">0x22222222</span>,</span>
<span class="line" id="L2091">        .res = buffer_recv.len,</span>
<span class="line" id="L2092">        .flags = <span class="tok-number">0</span>,</span>
<span class="line" id="L2093">    }, cqe_recvmsg);</span>
<span class="line" id="L2094"></span>
<span class="line" id="L2095">    <span class="tok-kw">try</span> testing.expectEqualSlices(<span class="tok-type">u8</span>, buffer_send[<span class="tok-number">0</span>..buffer_recv.len], buffer_recv[<span class="tok-number">0</span>..]);</span>
<span class="line" id="L2096">}</span>
<span class="line" id="L2097"></span>
<span class="line" id="L2098"><span class="tok-kw">test</span> <span class="tok-str">&quot;timeout (after a relative time)&quot;</span> {</span>
<span class="line" id="L2099">    <span class="tok-kw">if</span> (builtin.os.tag != .linux) <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SkipZigTest;</span>
<span class="line" id="L2100"></span>
<span class="line" id="L2101">    <span class="tok-kw">var</span> ring = IO_Uring.init(<span class="tok-number">1</span>, <span class="tok-number">0</span>) <span class="tok-kw">catch</span> |err| <span class="tok-kw">switch</span> (err) {</span>
<span class="line" id="L2102">        <span class="tok-kw">error</span>.SystemOutdated =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SkipZigTest,</span>
<span class="line" id="L2103">        <span class="tok-kw">error</span>.PermissionDenied =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SkipZigTest,</span>
<span class="line" id="L2104">        <span class="tok-kw">else</span> =&gt; <span class="tok-kw">return</span> err,</span>
<span class="line" id="L2105">    };</span>
<span class="line" id="L2106">    <span class="tok-kw">defer</span> ring.deinit();</span>
<span class="line" id="L2107"></span>
<span class="line" id="L2108">    <span class="tok-kw">const</span> ms = <span class="tok-number">10</span>;</span>
<span class="line" id="L2109">    <span class="tok-kw">const</span> margin = <span class="tok-number">5</span>;</span>
<span class="line" id="L2110">    <span class="tok-kw">const</span> ts = os.linux.kernel_timespec{ .tv_sec = <span class="tok-number">0</span>, .tv_nsec = ms * <span class="tok-number">1000000</span> };</span>
<span class="line" id="L2111"></span>
<span class="line" id="L2112">    <span class="tok-kw">const</span> started = std.time.milliTimestamp();</span>
<span class="line" id="L2113">    <span class="tok-kw">const</span> sqe = <span class="tok-kw">try</span> ring.timeout(<span class="tok-number">0x55555555</span>, &amp;ts, <span class="tok-number">0</span>, <span class="tok-number">0</span>);</span>
<span class="line" id="L2114">    <span class="tok-kw">try</span> testing.expectEqual(linux.IORING_OP.TIMEOUT, sqe.opcode);</span>
<span class="line" id="L2115">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">1</span>), <span class="tok-kw">try</span> ring.submit());</span>
<span class="line" id="L2116">    <span class="tok-kw">const</span> cqe = <span class="tok-kw">try</span> ring.copy_cqe();</span>
<span class="line" id="L2117">    <span class="tok-kw">const</span> stopped = std.time.milliTimestamp();</span>
<span class="line" id="L2118"></span>
<span class="line" id="L2119">    <span class="tok-kw">try</span> testing.expectEqual(linux.io_uring_cqe{</span>
<span class="line" id="L2120">        .user_data = <span class="tok-number">0x55555555</span>,</span>
<span class="line" id="L2121">        .res = -<span class="tok-builtin">@as</span>(<span class="tok-type">i32</span>, <span class="tok-builtin">@enumToInt</span>(linux.E.TIME)),</span>
<span class="line" id="L2122">        .flags = <span class="tok-number">0</span>,</span>
<span class="line" id="L2123">    }, cqe);</span>
<span class="line" id="L2124"></span>
<span class="line" id="L2125">    <span class="tok-comment">// Tests should not depend on timings: skip test if outside margin.</span>
</span>
<span class="line" id="L2126">    <span class="tok-kw">if</span> (!std.math.approxEqAbs(<span class="tok-type">f64</span>, ms, <span class="tok-builtin">@intToFloat</span>(<span class="tok-type">f64</span>, stopped - started), margin)) <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SkipZigTest;</span>
<span class="line" id="L2127">}</span>
<span class="line" id="L2128"></span>
<span class="line" id="L2129"><span class="tok-kw">test</span> <span class="tok-str">&quot;timeout (after a number of completions)&quot;</span> {</span>
<span class="line" id="L2130">    <span class="tok-kw">if</span> (builtin.os.tag != .linux) <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SkipZigTest;</span>
<span class="line" id="L2131"></span>
<span class="line" id="L2132">    <span class="tok-kw">var</span> ring = IO_Uring.init(<span class="tok-number">2</span>, <span class="tok-number">0</span>) <span class="tok-kw">catch</span> |err| <span class="tok-kw">switch</span> (err) {</span>
<span class="line" id="L2133">        <span class="tok-kw">error</span>.SystemOutdated =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SkipZigTest,</span>
<span class="line" id="L2134">        <span class="tok-kw">error</span>.PermissionDenied =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SkipZigTest,</span>
<span class="line" id="L2135">        <span class="tok-kw">else</span> =&gt; <span class="tok-kw">return</span> err,</span>
<span class="line" id="L2136">    };</span>
<span class="line" id="L2137">    <span class="tok-kw">defer</span> ring.deinit();</span>
<span class="line" id="L2138"></span>
<span class="line" id="L2139">    <span class="tok-kw">const</span> ts = os.linux.kernel_timespec{ .tv_sec = <span class="tok-number">3</span>, .tv_nsec = <span class="tok-number">0</span> };</span>
<span class="line" id="L2140">    <span class="tok-kw">const</span> count_completions: <span class="tok-type">u64</span> = <span class="tok-number">1</span>;</span>
<span class="line" id="L2141">    <span class="tok-kw">const</span> sqe_timeout = <span class="tok-kw">try</span> ring.timeout(<span class="tok-number">0x66666666</span>, &amp;ts, count_completions, <span class="tok-number">0</span>);</span>
<span class="line" id="L2142">    <span class="tok-kw">try</span> testing.expectEqual(linux.IORING_OP.TIMEOUT, sqe_timeout.opcode);</span>
<span class="line" id="L2143">    <span class="tok-kw">try</span> testing.expectEqual(count_completions, sqe_timeout.off);</span>
<span class="line" id="L2144">    _ = <span class="tok-kw">try</span> ring.nop(<span class="tok-number">0x77777777</span>);</span>
<span class="line" id="L2145">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">2</span>), <span class="tok-kw">try</span> ring.submit());</span>
<span class="line" id="L2146"></span>
<span class="line" id="L2147">    <span class="tok-kw">const</span> cqe_nop = <span class="tok-kw">try</span> ring.copy_cqe();</span>
<span class="line" id="L2148">    <span class="tok-kw">try</span> testing.expectEqual(linux.io_uring_cqe{</span>
<span class="line" id="L2149">        .user_data = <span class="tok-number">0x77777777</span>,</span>
<span class="line" id="L2150">        .res = <span class="tok-number">0</span>,</span>
<span class="line" id="L2151">        .flags = <span class="tok-number">0</span>,</span>
<span class="line" id="L2152">    }, cqe_nop);</span>
<span class="line" id="L2153"></span>
<span class="line" id="L2154">    <span class="tok-kw">const</span> cqe_timeout = <span class="tok-kw">try</span> ring.copy_cqe();</span>
<span class="line" id="L2155">    <span class="tok-kw">try</span> testing.expectEqual(linux.io_uring_cqe{</span>
<span class="line" id="L2156">        .user_data = <span class="tok-number">0x66666666</span>,</span>
<span class="line" id="L2157">        .res = <span class="tok-number">0</span>,</span>
<span class="line" id="L2158">        .flags = <span class="tok-number">0</span>,</span>
<span class="line" id="L2159">    }, cqe_timeout);</span>
<span class="line" id="L2160">}</span>
<span class="line" id="L2161"></span>
<span class="line" id="L2162"><span class="tok-kw">test</span> <span class="tok-str">&quot;timeout_remove&quot;</span> {</span>
<span class="line" id="L2163">    <span class="tok-kw">if</span> (builtin.os.tag != .linux) <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SkipZigTest;</span>
<span class="line" id="L2164"></span>
<span class="line" id="L2165">    <span class="tok-kw">var</span> ring = IO_Uring.init(<span class="tok-number">2</span>, <span class="tok-number">0</span>) <span class="tok-kw">catch</span> |err| <span class="tok-kw">switch</span> (err) {</span>
<span class="line" id="L2166">        <span class="tok-kw">error</span>.SystemOutdated =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SkipZigTest,</span>
<span class="line" id="L2167">        <span class="tok-kw">error</span>.PermissionDenied =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SkipZigTest,</span>
<span class="line" id="L2168">        <span class="tok-kw">else</span> =&gt; <span class="tok-kw">return</span> err,</span>
<span class="line" id="L2169">    };</span>
<span class="line" id="L2170">    <span class="tok-kw">defer</span> ring.deinit();</span>
<span class="line" id="L2171"></span>
<span class="line" id="L2172">    <span class="tok-kw">const</span> ts = os.linux.kernel_timespec{ .tv_sec = <span class="tok-number">3</span>, .tv_nsec = <span class="tok-number">0</span> };</span>
<span class="line" id="L2173">    <span class="tok-kw">const</span> sqe_timeout = <span class="tok-kw">try</span> ring.timeout(<span class="tok-number">0x88888888</span>, &amp;ts, <span class="tok-number">0</span>, <span class="tok-number">0</span>);</span>
<span class="line" id="L2174">    <span class="tok-kw">try</span> testing.expectEqual(linux.IORING_OP.TIMEOUT, sqe_timeout.opcode);</span>
<span class="line" id="L2175">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">u64</span>, <span class="tok-number">0x88888888</span>), sqe_timeout.user_data);</span>
<span class="line" id="L2176"></span>
<span class="line" id="L2177">    <span class="tok-kw">const</span> sqe_timeout_remove = <span class="tok-kw">try</span> ring.timeout_remove(<span class="tok-number">0x99999999</span>, <span class="tok-number">0x88888888</span>, <span class="tok-number">0</span>);</span>
<span class="line" id="L2178">    <span class="tok-kw">try</span> testing.expectEqual(linux.IORING_OP.TIMEOUT_REMOVE, sqe_timeout_remove.opcode);</span>
<span class="line" id="L2179">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">u64</span>, <span class="tok-number">0x88888888</span>), sqe_timeout_remove.addr);</span>
<span class="line" id="L2180">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">u64</span>, <span class="tok-number">0x99999999</span>), sqe_timeout_remove.user_data);</span>
<span class="line" id="L2181"></span>
<span class="line" id="L2182">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">2</span>), <span class="tok-kw">try</span> ring.submit());</span>
<span class="line" id="L2183"></span>
<span class="line" id="L2184">    <span class="tok-comment">// The order in which the CQE arrive is not clearly documented and it changed with kernel 5.18:</span>
</span>
<span class="line" id="L2185">    <span class="tok-comment">// * kernel 5.10 gives user data 0x88888888 first, 0x99999999 second</span>
</span>
<span class="line" id="L2186">    <span class="tok-comment">// * kernel 5.18 gives user data 0x99999999 first, 0x88888888 second</span>
</span>
<span class="line" id="L2187"></span>
<span class="line" id="L2188">    <span class="tok-kw">var</span> cqes: [<span class="tok-number">2</span>]os.linux.io_uring_cqe = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L2189">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">2</span>), <span class="tok-kw">try</span> ring.copy_cqes(cqes[<span class="tok-number">0</span>..], <span class="tok-number">2</span>));</span>
<span class="line" id="L2190"></span>
<span class="line" id="L2191">    <span class="tok-kw">for</span> (cqes) |cqe| {</span>
<span class="line" id="L2192">        <span class="tok-comment">// IORING_OP_TIMEOUT_REMOVE is not supported by this kernel version:</span>
</span>
<span class="line" id="L2193">        <span class="tok-comment">// Timeout remove operations set the fd to -1, which results in EBADF before EINVAL.</span>
</span>
<span class="line" id="L2194">        <span class="tok-comment">// We use IORING_FEAT_RW_CUR_POS as a safety check here to make sure we are at least pre-5.6.</span>
</span>
<span class="line" id="L2195">        <span class="tok-comment">// We don't want to skip this test for newer kernels.</span>
</span>
<span class="line" id="L2196">        <span class="tok-kw">if</span> (cqe.user_data == <span class="tok-number">0x99999999</span> <span class="tok-kw">and</span></span>
<span class="line" id="L2197">            cqe.err() == .BADF <span class="tok-kw">and</span></span>
<span class="line" id="L2198">            (ring.features &amp; linux.IORING_FEAT_RW_CUR_POS) == <span class="tok-number">0</span>)</span>
<span class="line" id="L2199">        {</span>
<span class="line" id="L2200">            <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SkipZigTest;</span>
<span class="line" id="L2201">        }</span>
<span class="line" id="L2202"></span>
<span class="line" id="L2203">        <span class="tok-kw">try</span> testing.expect(cqe.user_data == <span class="tok-number">0x88888888</span> <span class="tok-kw">or</span> cqe.user_data == <span class="tok-number">0x99999999</span>);</span>
<span class="line" id="L2204"></span>
<span class="line" id="L2205">        <span class="tok-kw">if</span> (cqe.user_data == <span class="tok-number">0x88888888</span>) {</span>
<span class="line" id="L2206">            <span class="tok-kw">try</span> testing.expectEqual(linux.io_uring_cqe{</span>
<span class="line" id="L2207">                .user_data = <span class="tok-number">0x88888888</span>,</span>
<span class="line" id="L2208">                .res = -<span class="tok-builtin">@as</span>(<span class="tok-type">i32</span>, <span class="tok-builtin">@enumToInt</span>(linux.E.CANCELED)),</span>
<span class="line" id="L2209">                .flags = <span class="tok-number">0</span>,</span>
<span class="line" id="L2210">            }, cqe);</span>
<span class="line" id="L2211">        } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (cqe.user_data == <span class="tok-number">0x99999999</span>) {</span>
<span class="line" id="L2212">            <span class="tok-kw">try</span> testing.expectEqual(linux.io_uring_cqe{</span>
<span class="line" id="L2213">                .user_data = <span class="tok-number">0x99999999</span>,</span>
<span class="line" id="L2214">                .res = <span class="tok-number">0</span>,</span>
<span class="line" id="L2215">                .flags = <span class="tok-number">0</span>,</span>
<span class="line" id="L2216">            }, cqe);</span>
<span class="line" id="L2217">        }</span>
<span class="line" id="L2218">    }</span>
<span class="line" id="L2219">}</span>
<span class="line" id="L2220"></span>
<span class="line" id="L2221"><span class="tok-kw">test</span> <span class="tok-str">&quot;accept/connect/recv/link_timeout&quot;</span> {</span>
<span class="line" id="L2222">    <span class="tok-kw">if</span> (builtin.os.tag != .linux) <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SkipZigTest;</span>
<span class="line" id="L2223"></span>
<span class="line" id="L2224">    <span class="tok-kw">var</span> ring = IO_Uring.init(<span class="tok-number">16</span>, <span class="tok-number">0</span>) <span class="tok-kw">catch</span> |err| <span class="tok-kw">switch</span> (err) {</span>
<span class="line" id="L2225">        <span class="tok-kw">error</span>.SystemOutdated =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SkipZigTest,</span>
<span class="line" id="L2226">        <span class="tok-kw">error</span>.PermissionDenied =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SkipZigTest,</span>
<span class="line" id="L2227">        <span class="tok-kw">else</span> =&gt; <span class="tok-kw">return</span> err,</span>
<span class="line" id="L2228">    };</span>
<span class="line" id="L2229">    <span class="tok-kw">defer</span> ring.deinit();</span>
<span class="line" id="L2230"></span>
<span class="line" id="L2231">    <span class="tok-kw">const</span> socket_test_harness = <span class="tok-kw">try</span> createSocketTestHarness(&amp;ring);</span>
<span class="line" id="L2232">    <span class="tok-kw">defer</span> socket_test_harness.close();</span>
<span class="line" id="L2233"></span>
<span class="line" id="L2234">    <span class="tok-kw">var</span> buffer_recv = [_]<span class="tok-type">u8</span>{ <span class="tok-number">0</span>, <span class="tok-number">1</span>, <span class="tok-number">0</span>, <span class="tok-number">1</span>, <span class="tok-number">0</span> };</span>
<span class="line" id="L2235"></span>
<span class="line" id="L2236">    <span class="tok-kw">const</span> sqe_recv = <span class="tok-kw">try</span> ring.recv(<span class="tok-number">0xffffffff</span>, socket_test_harness.server, .{ .buffer = buffer_recv[<span class="tok-number">0</span>..] }, <span class="tok-number">0</span>);</span>
<span class="line" id="L2237">    sqe_recv.flags |= linux.IOSQE_IO_LINK;</span>
<span class="line" id="L2238"></span>
<span class="line" id="L2239">    <span class="tok-kw">const</span> ts = os.linux.kernel_timespec{ .tv_sec = <span class="tok-number">0</span>, .tv_nsec = <span class="tok-number">1000000</span> };</span>
<span class="line" id="L2240">    _ = <span class="tok-kw">try</span> ring.link_timeout(<span class="tok-number">0x22222222</span>, &amp;ts, <span class="tok-number">0</span>);</span>
<span class="line" id="L2241"></span>
<span class="line" id="L2242">    <span class="tok-kw">const</span> nr_wait = <span class="tok-kw">try</span> ring.submit();</span>
<span class="line" id="L2243">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">2</span>), nr_wait);</span>
<span class="line" id="L2244"></span>
<span class="line" id="L2245">    <span class="tok-kw">var</span> i: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L2246">    <span class="tok-kw">while</span> (i &lt; nr_wait) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L2247">        <span class="tok-kw">const</span> cqe = <span class="tok-kw">try</span> ring.copy_cqe();</span>
<span class="line" id="L2248">        <span class="tok-kw">switch</span> (cqe.user_data) {</span>
<span class="line" id="L2249">            <span class="tok-number">0xffffffff</span> =&gt; {</span>
<span class="line" id="L2250">                <span class="tok-kw">if</span> (cqe.res != -<span class="tok-builtin">@as</span>(<span class="tok-type">i32</span>, <span class="tok-builtin">@enumToInt</span>(linux.E.INTR)) <span class="tok-kw">and</span></span>
<span class="line" id="L2251">                    cqe.res != -<span class="tok-builtin">@as</span>(<span class="tok-type">i32</span>, <span class="tok-builtin">@enumToInt</span>(linux.E.CANCELED)))</span>
<span class="line" id="L2252">                {</span>
<span class="line" id="L2253">                    std.debug.print(<span class="tok-str">&quot;Req 0x{x} got {d}\n&quot;</span>, .{ cqe.user_data, cqe.res });</span>
<span class="line" id="L2254">                    <span class="tok-kw">try</span> testing.expect(<span class="tok-null">false</span>);</span>
<span class="line" id="L2255">                }</span>
<span class="line" id="L2256">            },</span>
<span class="line" id="L2257">            <span class="tok-number">0x22222222</span> =&gt; {</span>
<span class="line" id="L2258">                <span class="tok-kw">if</span> (cqe.res != -<span class="tok-builtin">@as</span>(<span class="tok-type">i32</span>, <span class="tok-builtin">@enumToInt</span>(linux.E.ALREADY)) <span class="tok-kw">and</span></span>
<span class="line" id="L2259">                    cqe.res != -<span class="tok-builtin">@as</span>(<span class="tok-type">i32</span>, <span class="tok-builtin">@enumToInt</span>(linux.E.TIME)))</span>
<span class="line" id="L2260">                {</span>
<span class="line" id="L2261">                    std.debug.print(<span class="tok-str">&quot;Req 0x{x} got {d}\n&quot;</span>, .{ cqe.user_data, cqe.res });</span>
<span class="line" id="L2262">                    <span class="tok-kw">try</span> testing.expect(<span class="tok-null">false</span>);</span>
<span class="line" id="L2263">                }</span>
<span class="line" id="L2264">            },</span>
<span class="line" id="L2265">            <span class="tok-kw">else</span> =&gt; <span class="tok-builtin">@panic</span>(<span class="tok-str">&quot;should not happen&quot;</span>),</span>
<span class="line" id="L2266">        }</span>
<span class="line" id="L2267">    }</span>
<span class="line" id="L2268">}</span>
<span class="line" id="L2269"></span>
<span class="line" id="L2270"><span class="tok-kw">test</span> <span class="tok-str">&quot;fallocate&quot;</span> {</span>
<span class="line" id="L2271">    <span class="tok-kw">if</span> (builtin.os.tag != .linux) <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SkipZigTest;</span>
<span class="line" id="L2272"></span>
<span class="line" id="L2273">    <span class="tok-kw">var</span> ring = IO_Uring.init(<span class="tok-number">1</span>, <span class="tok-number">0</span>) <span class="tok-kw">catch</span> |err| <span class="tok-kw">switch</span> (err) {</span>
<span class="line" id="L2274">        <span class="tok-kw">error</span>.SystemOutdated =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SkipZigTest,</span>
<span class="line" id="L2275">        <span class="tok-kw">error</span>.PermissionDenied =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SkipZigTest,</span>
<span class="line" id="L2276">        <span class="tok-kw">else</span> =&gt; <span class="tok-kw">return</span> err,</span>
<span class="line" id="L2277">    };</span>
<span class="line" id="L2278">    <span class="tok-kw">defer</span> ring.deinit();</span>
<span class="line" id="L2279"></span>
<span class="line" id="L2280">    <span class="tok-kw">const</span> path = <span class="tok-str">&quot;test_io_uring_fallocate&quot;</span>;</span>
<span class="line" id="L2281">    <span class="tok-kw">const</span> file = <span class="tok-kw">try</span> std.fs.cwd().createFile(path, .{ .truncate = <span class="tok-null">true</span>, .mode = <span class="tok-number">0o666</span> });</span>
<span class="line" id="L2282">    <span class="tok-kw">defer</span> file.close();</span>
<span class="line" id="L2283">    <span class="tok-kw">defer</span> std.fs.cwd().deleteFile(path) <span class="tok-kw">catch</span> {};</span>
<span class="line" id="L2284"></span>
<span class="line" id="L2285">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">u64</span>, <span class="tok-number">0</span>), (<span class="tok-kw">try</span> file.stat()).size);</span>
<span class="line" id="L2286"></span>
<span class="line" id="L2287">    <span class="tok-kw">const</span> len: <span class="tok-type">u64</span> = <span class="tok-number">65536</span>;</span>
<span class="line" id="L2288">    <span class="tok-kw">const</span> sqe = <span class="tok-kw">try</span> ring.fallocate(<span class="tok-number">0xaaaaaaaa</span>, file.handle, <span class="tok-number">0</span>, <span class="tok-number">0</span>, len);</span>
<span class="line" id="L2289">    <span class="tok-kw">try</span> testing.expectEqual(linux.IORING_OP.FALLOCATE, sqe.opcode);</span>
<span class="line" id="L2290">    <span class="tok-kw">try</span> testing.expectEqual(file.handle, sqe.fd);</span>
<span class="line" id="L2291">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">1</span>), <span class="tok-kw">try</span> ring.submit());</span>
<span class="line" id="L2292"></span>
<span class="line" id="L2293">    <span class="tok-kw">const</span> cqe = <span class="tok-kw">try</span> ring.copy_cqe();</span>
<span class="line" id="L2294">    <span class="tok-kw">switch</span> (cqe.err()) {</span>
<span class="line" id="L2295">        .SUCCESS =&gt; {},</span>
<span class="line" id="L2296">        <span class="tok-comment">// This kernel's io_uring does not yet implement fallocate():</span>
</span>
<span class="line" id="L2297">        .INVAL =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SkipZigTest,</span>
<span class="line" id="L2298">        <span class="tok-comment">// This kernel does not implement fallocate():</span>
</span>
<span class="line" id="L2299">        .NOSYS =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SkipZigTest,</span>
<span class="line" id="L2300">        <span class="tok-comment">// The filesystem containing the file referred to by fd does not support this operation;</span>
</span>
<span class="line" id="L2301">        <span class="tok-comment">// or the mode is not supported by the filesystem containing the file referred to by fd:</span>
</span>
<span class="line" id="L2302">        .OPNOTSUPP =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SkipZigTest,</span>
<span class="line" id="L2303">        <span class="tok-kw">else</span> =&gt; |errno| std.debug.panic(<span class="tok-str">&quot;unhandled errno: {}&quot;</span>, .{errno}),</span>
<span class="line" id="L2304">    }</span>
<span class="line" id="L2305">    <span class="tok-kw">try</span> testing.expectEqual(linux.io_uring_cqe{</span>
<span class="line" id="L2306">        .user_data = <span class="tok-number">0xaaaaaaaa</span>,</span>
<span class="line" id="L2307">        .res = <span class="tok-number">0</span>,</span>
<span class="line" id="L2308">        .flags = <span class="tok-number">0</span>,</span>
<span class="line" id="L2309">    }, cqe);</span>
<span class="line" id="L2310"></span>
<span class="line" id="L2311">    <span class="tok-kw">try</span> testing.expectEqual(len, (<span class="tok-kw">try</span> file.stat()).size);</span>
<span class="line" id="L2312">}</span>
<span class="line" id="L2313"></span>
<span class="line" id="L2314"><span class="tok-kw">test</span> <span class="tok-str">&quot;statx&quot;</span> {</span>
<span class="line" id="L2315">    <span class="tok-kw">if</span> (builtin.os.tag != .linux) <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SkipZigTest;</span>
<span class="line" id="L2316"></span>
<span class="line" id="L2317">    <span class="tok-kw">var</span> ring = IO_Uring.init(<span class="tok-number">1</span>, <span class="tok-number">0</span>) <span class="tok-kw">catch</span> |err| <span class="tok-kw">switch</span> (err) {</span>
<span class="line" id="L2318">        <span class="tok-kw">error</span>.SystemOutdated =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SkipZigTest,</span>
<span class="line" id="L2319">        <span class="tok-kw">error</span>.PermissionDenied =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SkipZigTest,</span>
<span class="line" id="L2320">        <span class="tok-kw">else</span> =&gt; <span class="tok-kw">return</span> err,</span>
<span class="line" id="L2321">    };</span>
<span class="line" id="L2322">    <span class="tok-kw">defer</span> ring.deinit();</span>
<span class="line" id="L2323"></span>
<span class="line" id="L2324">    <span class="tok-kw">const</span> path = <span class="tok-str">&quot;test_io_uring_statx&quot;</span>;</span>
<span class="line" id="L2325">    <span class="tok-kw">const</span> file = <span class="tok-kw">try</span> std.fs.cwd().createFile(path, .{ .truncate = <span class="tok-null">true</span>, .mode = <span class="tok-number">0o666</span> });</span>
<span class="line" id="L2326">    <span class="tok-kw">defer</span> file.close();</span>
<span class="line" id="L2327">    <span class="tok-kw">defer</span> std.fs.cwd().deleteFile(path) <span class="tok-kw">catch</span> {};</span>
<span class="line" id="L2328"></span>
<span class="line" id="L2329">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">u64</span>, <span class="tok-number">0</span>), (<span class="tok-kw">try</span> file.stat()).size);</span>
<span class="line" id="L2330"></span>
<span class="line" id="L2331">    <span class="tok-kw">try</span> file.writeAll(<span class="tok-str">&quot;foobar&quot;</span>);</span>
<span class="line" id="L2332"></span>
<span class="line" id="L2333">    <span class="tok-kw">var</span> buf: linux.Statx = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L2334">    <span class="tok-kw">const</span> sqe = <span class="tok-kw">try</span> ring.statx(</span>
<span class="line" id="L2335">        <span class="tok-number">0xaaaaaaaa</span>,</span>
<span class="line" id="L2336">        linux.AT.FDCWD,</span>
<span class="line" id="L2337">        path,</span>
<span class="line" id="L2338">        <span class="tok-number">0</span>,</span>
<span class="line" id="L2339">        linux.STATX_SIZE,</span>
<span class="line" id="L2340">        &amp;buf,</span>
<span class="line" id="L2341">    );</span>
<span class="line" id="L2342">    <span class="tok-kw">try</span> testing.expectEqual(linux.IORING_OP.STATX, sqe.opcode);</span>
<span class="line" id="L2343">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">i32</span>, linux.AT.FDCWD), sqe.fd);</span>
<span class="line" id="L2344">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">1</span>), <span class="tok-kw">try</span> ring.submit());</span>
<span class="line" id="L2345"></span>
<span class="line" id="L2346">    <span class="tok-kw">const</span> cqe = <span class="tok-kw">try</span> ring.copy_cqe();</span>
<span class="line" id="L2347">    <span class="tok-kw">switch</span> (cqe.err()) {</span>
<span class="line" id="L2348">        .SUCCESS =&gt; {},</span>
<span class="line" id="L2349">        <span class="tok-comment">// This kernel's io_uring does not yet implement statx():</span>
</span>
<span class="line" id="L2350">        .INVAL =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SkipZigTest,</span>
<span class="line" id="L2351">        <span class="tok-comment">// This kernel does not implement statx():</span>
</span>
<span class="line" id="L2352">        .NOSYS =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SkipZigTest,</span>
<span class="line" id="L2353">        <span class="tok-comment">// The filesystem containing the file referred to by fd does not support this operation;</span>
</span>
<span class="line" id="L2354">        <span class="tok-comment">// or the mode is not supported by the filesystem containing the file referred to by fd:</span>
</span>
<span class="line" id="L2355">        .OPNOTSUPP =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SkipZigTest,</span>
<span class="line" id="L2356">        <span class="tok-comment">// The kernel is too old to support FDCWD for dir_fd</span>
</span>
<span class="line" id="L2357">        .BADF =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SkipZigTest,</span>
<span class="line" id="L2358">        <span class="tok-kw">else</span> =&gt; |errno| std.debug.panic(<span class="tok-str">&quot;unhandled errno: {}&quot;</span>, .{errno}),</span>
<span class="line" id="L2359">    }</span>
<span class="line" id="L2360">    <span class="tok-kw">try</span> testing.expectEqual(linux.io_uring_cqe{</span>
<span class="line" id="L2361">        .user_data = <span class="tok-number">0xaaaaaaaa</span>,</span>
<span class="line" id="L2362">        .res = <span class="tok-number">0</span>,</span>
<span class="line" id="L2363">        .flags = <span class="tok-number">0</span>,</span>
<span class="line" id="L2364">    }, cqe);</span>
<span class="line" id="L2365"></span>
<span class="line" id="L2366">    <span class="tok-kw">try</span> testing.expect(buf.mask &amp; os.linux.STATX_SIZE == os.linux.STATX_SIZE);</span>
<span class="line" id="L2367">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">u64</span>, <span class="tok-number">6</span>), buf.size);</span>
<span class="line" id="L2368">}</span>
<span class="line" id="L2369"></span>
<span class="line" id="L2370"><span class="tok-kw">test</span> <span class="tok-str">&quot;accept/connect/recv/cancel&quot;</span> {</span>
<span class="line" id="L2371">    <span class="tok-kw">if</span> (builtin.os.tag != .linux) <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SkipZigTest;</span>
<span class="line" id="L2372"></span>
<span class="line" id="L2373">    <span class="tok-kw">var</span> ring = IO_Uring.init(<span class="tok-number">16</span>, <span class="tok-number">0</span>) <span class="tok-kw">catch</span> |err| <span class="tok-kw">switch</span> (err) {</span>
<span class="line" id="L2374">        <span class="tok-kw">error</span>.SystemOutdated =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SkipZigTest,</span>
<span class="line" id="L2375">        <span class="tok-kw">error</span>.PermissionDenied =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SkipZigTest,</span>
<span class="line" id="L2376">        <span class="tok-kw">else</span> =&gt; <span class="tok-kw">return</span> err,</span>
<span class="line" id="L2377">    };</span>
<span class="line" id="L2378">    <span class="tok-kw">defer</span> ring.deinit();</span>
<span class="line" id="L2379"></span>
<span class="line" id="L2380">    <span class="tok-kw">const</span> socket_test_harness = <span class="tok-kw">try</span> createSocketTestHarness(&amp;ring);</span>
<span class="line" id="L2381">    <span class="tok-kw">defer</span> socket_test_harness.close();</span>
<span class="line" id="L2382"></span>
<span class="line" id="L2383">    <span class="tok-kw">var</span> buffer_recv = [_]<span class="tok-type">u8</span>{ <span class="tok-number">0</span>, <span class="tok-number">1</span>, <span class="tok-number">0</span>, <span class="tok-number">1</span>, <span class="tok-number">0</span> };</span>
<span class="line" id="L2384"></span>
<span class="line" id="L2385">    _ = <span class="tok-kw">try</span> ring.recv(<span class="tok-number">0xffffffff</span>, socket_test_harness.server, .{ .buffer = buffer_recv[<span class="tok-number">0</span>..] }, <span class="tok-number">0</span>);</span>
<span class="line" id="L2386">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">1</span>), <span class="tok-kw">try</span> ring.submit());</span>
<span class="line" id="L2387"></span>
<span class="line" id="L2388">    <span class="tok-kw">const</span> sqe_cancel = <span class="tok-kw">try</span> ring.cancel(<span class="tok-number">0x99999999</span>, <span class="tok-number">0xffffffff</span>, <span class="tok-number">0</span>);</span>
<span class="line" id="L2389">    <span class="tok-kw">try</span> testing.expectEqual(linux.IORING_OP.ASYNC_CANCEL, sqe_cancel.opcode);</span>
<span class="line" id="L2390">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">u64</span>, <span class="tok-number">0xffffffff</span>), sqe_cancel.addr);</span>
<span class="line" id="L2391">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">u64</span>, <span class="tok-number">0x99999999</span>), sqe_cancel.user_data);</span>
<span class="line" id="L2392">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">1</span>), <span class="tok-kw">try</span> ring.submit());</span>
<span class="line" id="L2393"></span>
<span class="line" id="L2394">    <span class="tok-kw">var</span> cqe_recv = <span class="tok-kw">try</span> ring.copy_cqe();</span>
<span class="line" id="L2395">    <span class="tok-kw">if</span> (cqe_recv.err() == .INVAL) <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SkipZigTest;</span>
<span class="line" id="L2396">    <span class="tok-kw">var</span> cqe_cancel = <span class="tok-kw">try</span> ring.copy_cqe();</span>
<span class="line" id="L2397">    <span class="tok-kw">if</span> (cqe_cancel.err() == .INVAL) <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SkipZigTest;</span>
<span class="line" id="L2398"></span>
<span class="line" id="L2399">    <span class="tok-comment">// The recv/cancel CQEs may arrive in any order, the recv CQE will sometimes come first:</span>
</span>
<span class="line" id="L2400">    <span class="tok-kw">if</span> (cqe_recv.user_data == <span class="tok-number">0x99999999</span> <span class="tok-kw">and</span> cqe_cancel.user_data == <span class="tok-number">0xffffffff</span>) {</span>
<span class="line" id="L2401">        <span class="tok-kw">const</span> a = cqe_recv;</span>
<span class="line" id="L2402">        <span class="tok-kw">const</span> b = cqe_cancel;</span>
<span class="line" id="L2403">        cqe_recv = b;</span>
<span class="line" id="L2404">        cqe_cancel = a;</span>
<span class="line" id="L2405">    }</span>
<span class="line" id="L2406"></span>
<span class="line" id="L2407">    <span class="tok-kw">try</span> testing.expectEqual(linux.io_uring_cqe{</span>
<span class="line" id="L2408">        .user_data = <span class="tok-number">0xffffffff</span>,</span>
<span class="line" id="L2409">        .res = -<span class="tok-builtin">@as</span>(<span class="tok-type">i32</span>, <span class="tok-builtin">@enumToInt</span>(linux.E.CANCELED)),</span>
<span class="line" id="L2410">        .flags = <span class="tok-number">0</span>,</span>
<span class="line" id="L2411">    }, cqe_recv);</span>
<span class="line" id="L2412"></span>
<span class="line" id="L2413">    <span class="tok-kw">try</span> testing.expectEqual(linux.io_uring_cqe{</span>
<span class="line" id="L2414">        .user_data = <span class="tok-number">0x99999999</span>,</span>
<span class="line" id="L2415">        .res = <span class="tok-number">0</span>,</span>
<span class="line" id="L2416">        .flags = <span class="tok-number">0</span>,</span>
<span class="line" id="L2417">    }, cqe_cancel);</span>
<span class="line" id="L2418">}</span>
<span class="line" id="L2419"></span>
<span class="line" id="L2420"><span class="tok-kw">test</span> <span class="tok-str">&quot;register_files_update&quot;</span> {</span>
<span class="line" id="L2421">    <span class="tok-kw">if</span> (builtin.os.tag != .linux) <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SkipZigTest;</span>
<span class="line" id="L2422"></span>
<span class="line" id="L2423">    <span class="tok-kw">var</span> ring = IO_Uring.init(<span class="tok-number">1</span>, <span class="tok-number">0</span>) <span class="tok-kw">catch</span> |err| <span class="tok-kw">switch</span> (err) {</span>
<span class="line" id="L2424">        <span class="tok-kw">error</span>.SystemOutdated =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SkipZigTest,</span>
<span class="line" id="L2425">        <span class="tok-kw">error</span>.PermissionDenied =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SkipZigTest,</span>
<span class="line" id="L2426">        <span class="tok-kw">else</span> =&gt; <span class="tok-kw">return</span> err,</span>
<span class="line" id="L2427">    };</span>
<span class="line" id="L2428">    <span class="tok-kw">defer</span> ring.deinit();</span>
<span class="line" id="L2429"></span>
<span class="line" id="L2430">    <span class="tok-kw">const</span> fd = <span class="tok-kw">try</span> os.openZ(<span class="tok-str">&quot;/dev/zero&quot;</span>, os.O.RDONLY | os.O.CLOEXEC, <span class="tok-number">0</span>);</span>
<span class="line" id="L2431">    <span class="tok-kw">defer</span> os.close(fd);</span>
<span class="line" id="L2432"></span>
<span class="line" id="L2433">    <span class="tok-kw">var</span> registered_fds = [_]os.fd_t{<span class="tok-number">0</span>} ** <span class="tok-number">2</span>;</span>
<span class="line" id="L2434">    <span class="tok-kw">const</span> fd_index = <span class="tok-number">0</span>;</span>
<span class="line" id="L2435">    <span class="tok-kw">const</span> fd_index2 = <span class="tok-number">1</span>;</span>
<span class="line" id="L2436">    registered_fds[fd_index] = fd;</span>
<span class="line" id="L2437">    registered_fds[fd_index2] = -<span class="tok-number">1</span>;</span>
<span class="line" id="L2438"></span>
<span class="line" id="L2439">    ring.register_files(registered_fds[<span class="tok-number">0</span>..]) <span class="tok-kw">catch</span> |err| <span class="tok-kw">switch</span> (err) {</span>
<span class="line" id="L2440">        <span class="tok-comment">// Happens when the kernel doesn't support sparse entry (-1) in the file descriptors array.</span>
</span>
<span class="line" id="L2441">        <span class="tok-kw">error</span>.FileDescriptorInvalid =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SkipZigTest,</span>
<span class="line" id="L2442">        <span class="tok-kw">else</span> =&gt; |errno| std.debug.panic(<span class="tok-str">&quot;unhandled errno: {}&quot;</span>, .{errno}),</span>
<span class="line" id="L2443">    };</span>
<span class="line" id="L2444"></span>
<span class="line" id="L2445">    <span class="tok-comment">// Test IORING_REGISTER_FILES_UPDATE</span>
</span>
<span class="line" id="L2446">    <span class="tok-comment">// Only available since Linux 5.5</span>
</span>
<span class="line" id="L2447"></span>
<span class="line" id="L2448">    <span class="tok-kw">const</span> fd2 = <span class="tok-kw">try</span> os.openZ(<span class="tok-str">&quot;/dev/zero&quot;</span>, os.O.RDONLY | os.O.CLOEXEC, <span class="tok-number">0</span>);</span>
<span class="line" id="L2449">    <span class="tok-kw">defer</span> os.close(fd2);</span>
<span class="line" id="L2450"></span>
<span class="line" id="L2451">    registered_fds[fd_index] = fd2;</span>
<span class="line" id="L2452">    registered_fds[fd_index2] = -<span class="tok-number">1</span>;</span>
<span class="line" id="L2453">    <span class="tok-kw">try</span> ring.register_files_update(<span class="tok-number">0</span>, registered_fds[<span class="tok-number">0</span>..]);</span>
<span class="line" id="L2454"></span>
<span class="line" id="L2455">    <span class="tok-kw">var</span> buffer = [_]<span class="tok-type">u8</span>{<span class="tok-number">42</span>} ** <span class="tok-number">128</span>;</span>
<span class="line" id="L2456">    {</span>
<span class="line" id="L2457">        <span class="tok-kw">const</span> sqe = <span class="tok-kw">try</span> ring.read(<span class="tok-number">0xcccccccc</span>, fd_index, .{ .buffer = &amp;buffer }, <span class="tok-number">0</span>);</span>
<span class="line" id="L2458">        <span class="tok-kw">try</span> testing.expectEqual(linux.IORING_OP.READ, sqe.opcode);</span>
<span class="line" id="L2459">        sqe.flags |= linux.IOSQE_FIXED_FILE;</span>
<span class="line" id="L2460"></span>
<span class="line" id="L2461">        <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">1</span>), <span class="tok-kw">try</span> ring.submit());</span>
<span class="line" id="L2462">        <span class="tok-kw">try</span> testing.expectEqual(linux.io_uring_cqe{</span>
<span class="line" id="L2463">            .user_data = <span class="tok-number">0xcccccccc</span>,</span>
<span class="line" id="L2464">            .res = buffer.len,</span>
<span class="line" id="L2465">            .flags = <span class="tok-number">0</span>,</span>
<span class="line" id="L2466">        }, <span class="tok-kw">try</span> ring.copy_cqe());</span>
<span class="line" id="L2467">        <span class="tok-kw">try</span> testing.expectEqualSlices(<span class="tok-type">u8</span>, &amp;([_]<span class="tok-type">u8</span>{<span class="tok-number">0</span>} ** buffer.len), buffer[<span class="tok-number">0</span>..]);</span>
<span class="line" id="L2468">    }</span>
<span class="line" id="L2469"></span>
<span class="line" id="L2470">    <span class="tok-comment">// Test with a non-zero offset</span>
</span>
<span class="line" id="L2471"></span>
<span class="line" id="L2472">    registered_fds[fd_index] = -<span class="tok-number">1</span>;</span>
<span class="line" id="L2473">    registered_fds[fd_index2] = -<span class="tok-number">1</span>;</span>
<span class="line" id="L2474">    <span class="tok-kw">try</span> ring.register_files_update(<span class="tok-number">1</span>, registered_fds[<span class="tok-number">1</span>..]);</span>
<span class="line" id="L2475"></span>
<span class="line" id="L2476">    {</span>
<span class="line" id="L2477">        <span class="tok-comment">// Next read should still work since fd_index in the registered file descriptors hasn't been updated yet.</span>
</span>
<span class="line" id="L2478">        <span class="tok-kw">const</span> sqe = <span class="tok-kw">try</span> ring.read(<span class="tok-number">0xcccccccc</span>, fd_index, .{ .buffer = &amp;buffer }, <span class="tok-number">0</span>);</span>
<span class="line" id="L2479">        <span class="tok-kw">try</span> testing.expectEqual(linux.IORING_OP.READ, sqe.opcode);</span>
<span class="line" id="L2480">        sqe.flags |= linux.IOSQE_FIXED_FILE;</span>
<span class="line" id="L2481"></span>
<span class="line" id="L2482">        <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">1</span>), <span class="tok-kw">try</span> ring.submit());</span>
<span class="line" id="L2483">        <span class="tok-kw">try</span> testing.expectEqual(linux.io_uring_cqe{</span>
<span class="line" id="L2484">            .user_data = <span class="tok-number">0xcccccccc</span>,</span>
<span class="line" id="L2485">            .res = buffer.len,</span>
<span class="line" id="L2486">            .flags = <span class="tok-number">0</span>,</span>
<span class="line" id="L2487">        }, <span class="tok-kw">try</span> ring.copy_cqe());</span>
<span class="line" id="L2488">        <span class="tok-kw">try</span> testing.expectEqualSlices(<span class="tok-type">u8</span>, &amp;([_]<span class="tok-type">u8</span>{<span class="tok-number">0</span>} ** buffer.len), buffer[<span class="tok-number">0</span>..]);</span>
<span class="line" id="L2489">    }</span>
<span class="line" id="L2490"></span>
<span class="line" id="L2491">    <span class="tok-kw">try</span> ring.register_files_update(<span class="tok-number">0</span>, registered_fds[<span class="tok-number">0</span>..]);</span>
<span class="line" id="L2492"></span>
<span class="line" id="L2493">    {</span>
<span class="line" id="L2494">        <span class="tok-comment">// Now this should fail since both fds are sparse (-1)</span>
</span>
<span class="line" id="L2495">        <span class="tok-kw">const</span> sqe = <span class="tok-kw">try</span> ring.read(<span class="tok-number">0xcccccccc</span>, fd_index, .{ .buffer = &amp;buffer }, <span class="tok-number">0</span>);</span>
<span class="line" id="L2496">        <span class="tok-kw">try</span> testing.expectEqual(linux.IORING_OP.READ, sqe.opcode);</span>
<span class="line" id="L2497">        sqe.flags |= linux.IOSQE_FIXED_FILE;</span>
<span class="line" id="L2498"></span>
<span class="line" id="L2499">        <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">1</span>), <span class="tok-kw">try</span> ring.submit());</span>
<span class="line" id="L2500">        <span class="tok-kw">const</span> cqe = <span class="tok-kw">try</span> ring.copy_cqe();</span>
<span class="line" id="L2501">        <span class="tok-kw">try</span> testing.expectEqual(os.linux.E.BADF, cqe.err());</span>
<span class="line" id="L2502">    }</span>
<span class="line" id="L2503"></span>
<span class="line" id="L2504">    <span class="tok-kw">try</span> ring.unregister_files();</span>
<span class="line" id="L2505">}</span>
<span class="line" id="L2506"></span>
<span class="line" id="L2507"><span class="tok-kw">test</span> <span class="tok-str">&quot;shutdown&quot;</span> {</span>
<span class="line" id="L2508">    <span class="tok-kw">if</span> (builtin.os.tag != .linux) <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SkipZigTest;</span>
<span class="line" id="L2509"></span>
<span class="line" id="L2510">    <span class="tok-kw">var</span> ring = IO_Uring.init(<span class="tok-number">16</span>, <span class="tok-number">0</span>) <span class="tok-kw">catch</span> |err| <span class="tok-kw">switch</span> (err) {</span>
<span class="line" id="L2511">        <span class="tok-kw">error</span>.SystemOutdated =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SkipZigTest,</span>
<span class="line" id="L2512">        <span class="tok-kw">error</span>.PermissionDenied =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SkipZigTest,</span>
<span class="line" id="L2513">        <span class="tok-kw">else</span> =&gt; <span class="tok-kw">return</span> err,</span>
<span class="line" id="L2514">    };</span>
<span class="line" id="L2515">    <span class="tok-kw">defer</span> ring.deinit();</span>
<span class="line" id="L2516"></span>
<span class="line" id="L2517">    <span class="tok-kw">const</span> address = <span class="tok-kw">try</span> net.Address.parseIp4(<span class="tok-str">&quot;127.0.0.1&quot;</span>, <span class="tok-number">3131</span>);</span>
<span class="line" id="L2518"></span>
<span class="line" id="L2519">    <span class="tok-comment">// Socket bound, expect shutdown to work</span>
</span>
<span class="line" id="L2520">    {</span>
<span class="line" id="L2521">        <span class="tok-kw">const</span> server = <span class="tok-kw">try</span> os.socket(address.any.family, os.SOCK.STREAM | os.SOCK.CLOEXEC, <span class="tok-number">0</span>);</span>
<span class="line" id="L2522">        <span class="tok-kw">defer</span> os.close(server);</span>
<span class="line" id="L2523">        <span class="tok-kw">try</span> os.setsockopt(server, os.SOL.SOCKET, os.SO.REUSEADDR, &amp;mem.toBytes(<span class="tok-builtin">@as</span>(<span class="tok-type">c_int</span>, <span class="tok-number">1</span>)));</span>
<span class="line" id="L2524">        <span class="tok-kw">try</span> os.bind(server, &amp;address.any, address.getOsSockLen());</span>
<span class="line" id="L2525">        <span class="tok-kw">try</span> os.listen(server, <span class="tok-number">1</span>);</span>
<span class="line" id="L2526"></span>
<span class="line" id="L2527">        <span class="tok-kw">var</span> shutdown_sqe = <span class="tok-kw">try</span> ring.shutdown(<span class="tok-number">0x445445445</span>, server, os.linux.SHUT.RD);</span>
<span class="line" id="L2528">        <span class="tok-kw">try</span> testing.expectEqual(linux.IORING_OP.SHUTDOWN, shutdown_sqe.opcode);</span>
<span class="line" id="L2529">        <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">i32</span>, server), shutdown_sqe.fd);</span>
<span class="line" id="L2530"></span>
<span class="line" id="L2531">        <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">1</span>), <span class="tok-kw">try</span> ring.submit());</span>
<span class="line" id="L2532"></span>
<span class="line" id="L2533">        <span class="tok-kw">const</span> cqe = <span class="tok-kw">try</span> ring.copy_cqe();</span>
<span class="line" id="L2534">        <span class="tok-kw">switch</span> (cqe.err()) {</span>
<span class="line" id="L2535">            .SUCCESS =&gt; {},</span>
<span class="line" id="L2536">            <span class="tok-comment">// This kernel's io_uring does not yet implement shutdown (kernel version &lt; 5.11)</span>
</span>
<span class="line" id="L2537">            .INVAL =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SkipZigTest,</span>
<span class="line" id="L2538">            <span class="tok-kw">else</span> =&gt; |errno| std.debug.panic(<span class="tok-str">&quot;unhandled errno: {}&quot;</span>, .{errno}),</span>
<span class="line" id="L2539">        }</span>
<span class="line" id="L2540"></span>
<span class="line" id="L2541">        <span class="tok-kw">try</span> testing.expectEqual(linux.io_uring_cqe{</span>
<span class="line" id="L2542">            .user_data = <span class="tok-number">0x445445445</span>,</span>
<span class="line" id="L2543">            .res = <span class="tok-number">0</span>,</span>
<span class="line" id="L2544">            .flags = <span class="tok-number">0</span>,</span>
<span class="line" id="L2545">        }, cqe);</span>
<span class="line" id="L2546">    }</span>
<span class="line" id="L2547"></span>
<span class="line" id="L2548">    <span class="tok-comment">// Socket not bound, expect to fail with ENOTCONN</span>
</span>
<span class="line" id="L2549">    {</span>
<span class="line" id="L2550">        <span class="tok-kw">const</span> server = <span class="tok-kw">try</span> os.socket(address.any.family, os.SOCK.STREAM | os.SOCK.CLOEXEC, <span class="tok-number">0</span>);</span>
<span class="line" id="L2551">        <span class="tok-kw">defer</span> os.close(server);</span>
<span class="line" id="L2552"></span>
<span class="line" id="L2553">        <span class="tok-kw">var</span> shutdown_sqe = ring.shutdown(<span class="tok-number">0x445445445</span>, server, os.linux.SHUT.RD) <span class="tok-kw">catch</span> |err| <span class="tok-kw">switch</span> (err) {</span>
<span class="line" id="L2554">            <span class="tok-kw">else</span> =&gt; |errno| std.debug.panic(<span class="tok-str">&quot;unhandled errno: {}&quot;</span>, .{errno}),</span>
<span class="line" id="L2555">        };</span>
<span class="line" id="L2556">        <span class="tok-kw">try</span> testing.expectEqual(linux.IORING_OP.SHUTDOWN, shutdown_sqe.opcode);</span>
<span class="line" id="L2557">        <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">i32</span>, server), shutdown_sqe.fd);</span>
<span class="line" id="L2558"></span>
<span class="line" id="L2559">        <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">1</span>), <span class="tok-kw">try</span> ring.submit());</span>
<span class="line" id="L2560"></span>
<span class="line" id="L2561">        <span class="tok-kw">const</span> cqe = <span class="tok-kw">try</span> ring.copy_cqe();</span>
<span class="line" id="L2562">        <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">u64</span>, <span class="tok-number">0x445445445</span>), cqe.user_data);</span>
<span class="line" id="L2563">        <span class="tok-kw">try</span> testing.expectEqual(os.linux.E.NOTCONN, cqe.err());</span>
<span class="line" id="L2564">    }</span>
<span class="line" id="L2565">}</span>
<span class="line" id="L2566"></span>
<span class="line" id="L2567"><span class="tok-kw">test</span> <span class="tok-str">&quot;renameat&quot;</span> {</span>
<span class="line" id="L2568">    <span class="tok-kw">if</span> (builtin.os.tag != .linux) <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SkipZigTest;</span>
<span class="line" id="L2569"></span>
<span class="line" id="L2570">    <span class="tok-kw">var</span> ring = IO_Uring.init(<span class="tok-number">1</span>, <span class="tok-number">0</span>) <span class="tok-kw">catch</span> |err| <span class="tok-kw">switch</span> (err) {</span>
<span class="line" id="L2571">        <span class="tok-kw">error</span>.SystemOutdated =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SkipZigTest,</span>
<span class="line" id="L2572">        <span class="tok-kw">error</span>.PermissionDenied =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SkipZigTest,</span>
<span class="line" id="L2573">        <span class="tok-kw">else</span> =&gt; <span class="tok-kw">return</span> err,</span>
<span class="line" id="L2574">    };</span>
<span class="line" id="L2575">    <span class="tok-kw">defer</span> ring.deinit();</span>
<span class="line" id="L2576"></span>
<span class="line" id="L2577">    <span class="tok-kw">const</span> old_path = <span class="tok-str">&quot;test_io_uring_renameat_old&quot;</span>;</span>
<span class="line" id="L2578">    <span class="tok-kw">const</span> new_path = <span class="tok-str">&quot;test_io_uring_renameat_new&quot;</span>;</span>
<span class="line" id="L2579"></span>
<span class="line" id="L2580">    <span class="tok-comment">// Write old file with data</span>
</span>
<span class="line" id="L2581"></span>
<span class="line" id="L2582">    <span class="tok-kw">const</span> old_file = <span class="tok-kw">try</span> std.fs.cwd().createFile(old_path, .{ .truncate = <span class="tok-null">true</span>, .mode = <span class="tok-number">0o666</span> });</span>
<span class="line" id="L2583">    <span class="tok-kw">defer</span> {</span>
<span class="line" id="L2584">        old_file.close();</span>
<span class="line" id="L2585">        std.fs.cwd().deleteFile(new_path) <span class="tok-kw">catch</span> {};</span>
<span class="line" id="L2586">    }</span>
<span class="line" id="L2587">    <span class="tok-kw">try</span> old_file.writeAll(<span class="tok-str">&quot;hello&quot;</span>);</span>
<span class="line" id="L2588"></span>
<span class="line" id="L2589">    <span class="tok-comment">// Submit renameat</span>
</span>
<span class="line" id="L2590"></span>
<span class="line" id="L2591">    <span class="tok-kw">var</span> sqe = <span class="tok-kw">try</span> ring.renameat(</span>
<span class="line" id="L2592">        <span class="tok-number">0x12121212</span>,</span>
<span class="line" id="L2593">        linux.AT.FDCWD,</span>
<span class="line" id="L2594">        old_path,</span>
<span class="line" id="L2595">        linux.AT.FDCWD,</span>
<span class="line" id="L2596">        new_path,</span>
<span class="line" id="L2597">        <span class="tok-number">0</span>,</span>
<span class="line" id="L2598">    );</span>
<span class="line" id="L2599">    <span class="tok-kw">try</span> testing.expectEqual(linux.IORING_OP.RENAMEAT, sqe.opcode);</span>
<span class="line" id="L2600">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">i32</span>, linux.AT.FDCWD), sqe.fd);</span>
<span class="line" id="L2601">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">i32</span>, linux.AT.FDCWD), <span class="tok-builtin">@bitCast</span>(<span class="tok-type">i32</span>, sqe.len));</span>
<span class="line" id="L2602">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">1</span>), <span class="tok-kw">try</span> ring.submit());</span>
<span class="line" id="L2603"></span>
<span class="line" id="L2604">    <span class="tok-kw">const</span> cqe = <span class="tok-kw">try</span> ring.copy_cqe();</span>
<span class="line" id="L2605">    <span class="tok-kw">switch</span> (cqe.err()) {</span>
<span class="line" id="L2606">        .SUCCESS =&gt; {},</span>
<span class="line" id="L2607">        <span class="tok-comment">// This kernel's io_uring does not yet implement renameat (kernel version &lt; 5.11)</span>
</span>
<span class="line" id="L2608">        .BADF, .INVAL =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SkipZigTest,</span>
<span class="line" id="L2609">        <span class="tok-kw">else</span> =&gt; |errno| std.debug.panic(<span class="tok-str">&quot;unhandled errno: {}&quot;</span>, .{errno}),</span>
<span class="line" id="L2610">    }</span>
<span class="line" id="L2611">    <span class="tok-kw">try</span> testing.expectEqual(linux.io_uring_cqe{</span>
<span class="line" id="L2612">        .user_data = <span class="tok-number">0x12121212</span>,</span>
<span class="line" id="L2613">        .res = <span class="tok-number">0</span>,</span>
<span class="line" id="L2614">        .flags = <span class="tok-number">0</span>,</span>
<span class="line" id="L2615">    }, cqe);</span>
<span class="line" id="L2616"></span>
<span class="line" id="L2617">    <span class="tok-comment">// Validate that the old file doesn't exist anymore</span>
</span>
<span class="line" id="L2618">    {</span>
<span class="line" id="L2619">        _ = std.fs.cwd().openFile(old_path, .{}) <span class="tok-kw">catch</span> |err| <span class="tok-kw">switch</span> (err) {</span>
<span class="line" id="L2620">            <span class="tok-kw">error</span>.FileNotFound =&gt; {},</span>
<span class="line" id="L2621">            <span class="tok-kw">else</span> =&gt; std.debug.panic(<span class="tok-str">&quot;unexpected error: {}&quot;</span>, .{err}),</span>
<span class="line" id="L2622">        };</span>
<span class="line" id="L2623">    }</span>
<span class="line" id="L2624"></span>
<span class="line" id="L2625">    <span class="tok-comment">// Validate that the new file exists with the proper content</span>
</span>
<span class="line" id="L2626">    {</span>
<span class="line" id="L2627">        <span class="tok-kw">const</span> new_file = <span class="tok-kw">try</span> std.fs.cwd().openFile(new_path, .{});</span>
<span class="line" id="L2628">        <span class="tok-kw">defer</span> new_file.close();</span>
<span class="line" id="L2629"></span>
<span class="line" id="L2630">        <span class="tok-kw">var</span> new_file_data: [<span class="tok-number">16</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L2631">        <span class="tok-kw">const</span> read = <span class="tok-kw">try</span> new_file.readAll(&amp;new_file_data);</span>
<span class="line" id="L2632">        <span class="tok-kw">try</span> testing.expectEqualStrings(<span class="tok-str">&quot;hello&quot;</span>, new_file_data[<span class="tok-number">0</span>..read]);</span>
<span class="line" id="L2633">    }</span>
<span class="line" id="L2634">}</span>
<span class="line" id="L2635"></span>
<span class="line" id="L2636"><span class="tok-kw">test</span> <span class="tok-str">&quot;unlinkat&quot;</span> {</span>
<span class="line" id="L2637">    <span class="tok-kw">if</span> (builtin.os.tag != .linux) <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SkipZigTest;</span>
<span class="line" id="L2638"></span>
<span class="line" id="L2639">    <span class="tok-kw">var</span> ring = IO_Uring.init(<span class="tok-number">1</span>, <span class="tok-number">0</span>) <span class="tok-kw">catch</span> |err| <span class="tok-kw">switch</span> (err) {</span>
<span class="line" id="L2640">        <span class="tok-kw">error</span>.SystemOutdated =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SkipZigTest,</span>
<span class="line" id="L2641">        <span class="tok-kw">error</span>.PermissionDenied =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SkipZigTest,</span>
<span class="line" id="L2642">        <span class="tok-kw">else</span> =&gt; <span class="tok-kw">return</span> err,</span>
<span class="line" id="L2643">    };</span>
<span class="line" id="L2644">    <span class="tok-kw">defer</span> ring.deinit();</span>
<span class="line" id="L2645"></span>
<span class="line" id="L2646">    <span class="tok-kw">const</span> path = <span class="tok-str">&quot;test_io_uring_unlinkat&quot;</span>;</span>
<span class="line" id="L2647"></span>
<span class="line" id="L2648">    <span class="tok-comment">// Write old file with data</span>
</span>
<span class="line" id="L2649"></span>
<span class="line" id="L2650">    <span class="tok-kw">const</span> file = <span class="tok-kw">try</span> std.fs.cwd().createFile(path, .{ .truncate = <span class="tok-null">true</span>, .mode = <span class="tok-number">0o666</span> });</span>
<span class="line" id="L2651">    <span class="tok-kw">defer</span> file.close();</span>
<span class="line" id="L2652">    <span class="tok-kw">defer</span> std.fs.cwd().deleteFile(path) <span class="tok-kw">catch</span> {};</span>
<span class="line" id="L2653"></span>
<span class="line" id="L2654">    <span class="tok-comment">// Submit unlinkat</span>
</span>
<span class="line" id="L2655"></span>
<span class="line" id="L2656">    <span class="tok-kw">var</span> sqe = <span class="tok-kw">try</span> ring.unlinkat(</span>
<span class="line" id="L2657">        <span class="tok-number">0x12121212</span>,</span>
<span class="line" id="L2658">        linux.AT.FDCWD,</span>
<span class="line" id="L2659">        path,</span>
<span class="line" id="L2660">        <span class="tok-number">0</span>,</span>
<span class="line" id="L2661">    );</span>
<span class="line" id="L2662">    <span class="tok-kw">try</span> testing.expectEqual(linux.IORING_OP.UNLINKAT, sqe.opcode);</span>
<span class="line" id="L2663">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">i32</span>, linux.AT.FDCWD), sqe.fd);</span>
<span class="line" id="L2664">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">1</span>), <span class="tok-kw">try</span> ring.submit());</span>
<span class="line" id="L2665"></span>
<span class="line" id="L2666">    <span class="tok-kw">const</span> cqe = <span class="tok-kw">try</span> ring.copy_cqe();</span>
<span class="line" id="L2667">    <span class="tok-kw">switch</span> (cqe.err()) {</span>
<span class="line" id="L2668">        .SUCCESS =&gt; {},</span>
<span class="line" id="L2669">        <span class="tok-comment">// This kernel's io_uring does not yet implement unlinkat (kernel version &lt; 5.11)</span>
</span>
<span class="line" id="L2670">        .BADF, .INVAL =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SkipZigTest,</span>
<span class="line" id="L2671">        <span class="tok-kw">else</span> =&gt; |errno| std.debug.panic(<span class="tok-str">&quot;unhandled errno: {}&quot;</span>, .{errno}),</span>
<span class="line" id="L2672">    }</span>
<span class="line" id="L2673">    <span class="tok-kw">try</span> testing.expectEqual(linux.io_uring_cqe{</span>
<span class="line" id="L2674">        .user_data = <span class="tok-number">0x12121212</span>,</span>
<span class="line" id="L2675">        .res = <span class="tok-number">0</span>,</span>
<span class="line" id="L2676">        .flags = <span class="tok-number">0</span>,</span>
<span class="line" id="L2677">    }, cqe);</span>
<span class="line" id="L2678"></span>
<span class="line" id="L2679">    <span class="tok-comment">// Validate that the file doesn't exist anymore</span>
</span>
<span class="line" id="L2680">    _ = std.fs.cwd().openFile(path, .{}) <span class="tok-kw">catch</span> |err| <span class="tok-kw">switch</span> (err) {</span>
<span class="line" id="L2681">        <span class="tok-kw">error</span>.FileNotFound =&gt; {},</span>
<span class="line" id="L2682">        <span class="tok-kw">else</span> =&gt; std.debug.panic(<span class="tok-str">&quot;unexpected error: {}&quot;</span>, .{err}),</span>
<span class="line" id="L2683">    };</span>
<span class="line" id="L2684">}</span>
<span class="line" id="L2685"></span>
<span class="line" id="L2686"><span class="tok-kw">test</span> <span class="tok-str">&quot;mkdirat&quot;</span> {</span>
<span class="line" id="L2687">    <span class="tok-kw">if</span> (builtin.os.tag != .linux) <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SkipZigTest;</span>
<span class="line" id="L2688"></span>
<span class="line" id="L2689">    <span class="tok-kw">var</span> ring = IO_Uring.init(<span class="tok-number">1</span>, <span class="tok-number">0</span>) <span class="tok-kw">catch</span> |err| <span class="tok-kw">switch</span> (err) {</span>
<span class="line" id="L2690">        <span class="tok-kw">error</span>.SystemOutdated =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SkipZigTest,</span>
<span class="line" id="L2691">        <span class="tok-kw">error</span>.PermissionDenied =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SkipZigTest,</span>
<span class="line" id="L2692">        <span class="tok-kw">else</span> =&gt; <span class="tok-kw">return</span> err,</span>
<span class="line" id="L2693">    };</span>
<span class="line" id="L2694">    <span class="tok-kw">defer</span> ring.deinit();</span>
<span class="line" id="L2695"></span>
<span class="line" id="L2696">    <span class="tok-kw">const</span> path = <span class="tok-str">&quot;test_io_uring_mkdirat&quot;</span>;</span>
<span class="line" id="L2697"></span>
<span class="line" id="L2698">    <span class="tok-kw">defer</span> std.fs.cwd().deleteDir(path) <span class="tok-kw">catch</span> {};</span>
<span class="line" id="L2699"></span>
<span class="line" id="L2700">    <span class="tok-comment">// Submit mkdirat</span>
</span>
<span class="line" id="L2701"></span>
<span class="line" id="L2702">    <span class="tok-kw">var</span> sqe = <span class="tok-kw">try</span> ring.mkdirat(</span>
<span class="line" id="L2703">        <span class="tok-number">0x12121212</span>,</span>
<span class="line" id="L2704">        linux.AT.FDCWD,</span>
<span class="line" id="L2705">        path,</span>
<span class="line" id="L2706">        <span class="tok-number">0o0755</span>,</span>
<span class="line" id="L2707">    );</span>
<span class="line" id="L2708">    <span class="tok-kw">try</span> testing.expectEqual(linux.IORING_OP.MKDIRAT, sqe.opcode);</span>
<span class="line" id="L2709">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">i32</span>, linux.AT.FDCWD), sqe.fd);</span>
<span class="line" id="L2710">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">1</span>), <span class="tok-kw">try</span> ring.submit());</span>
<span class="line" id="L2711"></span>
<span class="line" id="L2712">    <span class="tok-kw">const</span> cqe = <span class="tok-kw">try</span> ring.copy_cqe();</span>
<span class="line" id="L2713">    <span class="tok-kw">switch</span> (cqe.err()) {</span>
<span class="line" id="L2714">        .SUCCESS =&gt; {},</span>
<span class="line" id="L2715">        <span class="tok-comment">// This kernel's io_uring does not yet implement mkdirat (kernel version &lt; 5.15)</span>
</span>
<span class="line" id="L2716">        .BADF, .INVAL =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SkipZigTest,</span>
<span class="line" id="L2717">        <span class="tok-kw">else</span> =&gt; |errno| std.debug.panic(<span class="tok-str">&quot;unhandled errno: {}&quot;</span>, .{errno}),</span>
<span class="line" id="L2718">    }</span>
<span class="line" id="L2719">    <span class="tok-kw">try</span> testing.expectEqual(linux.io_uring_cqe{</span>
<span class="line" id="L2720">        .user_data = <span class="tok-number">0x12121212</span>,</span>
<span class="line" id="L2721">        .res = <span class="tok-number">0</span>,</span>
<span class="line" id="L2722">        .flags = <span class="tok-number">0</span>,</span>
<span class="line" id="L2723">    }, cqe);</span>
<span class="line" id="L2724"></span>
<span class="line" id="L2725">    <span class="tok-comment">// Validate that the directory exist</span>
</span>
<span class="line" id="L2726">    _ = <span class="tok-kw">try</span> std.fs.cwd().openDir(path, .{});</span>
<span class="line" id="L2727">}</span>
<span class="line" id="L2728"></span>
<span class="line" id="L2729"><span class="tok-kw">test</span> <span class="tok-str">&quot;symlinkat&quot;</span> {</span>
<span class="line" id="L2730">    <span class="tok-kw">if</span> (builtin.os.tag != .linux) <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SkipZigTest;</span>
<span class="line" id="L2731"></span>
<span class="line" id="L2732">    <span class="tok-kw">var</span> ring = IO_Uring.init(<span class="tok-number">1</span>, <span class="tok-number">0</span>) <span class="tok-kw">catch</span> |err| <span class="tok-kw">switch</span> (err) {</span>
<span class="line" id="L2733">        <span class="tok-kw">error</span>.SystemOutdated =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SkipZigTest,</span>
<span class="line" id="L2734">        <span class="tok-kw">error</span>.PermissionDenied =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SkipZigTest,</span>
<span class="line" id="L2735">        <span class="tok-kw">else</span> =&gt; <span class="tok-kw">return</span> err,</span>
<span class="line" id="L2736">    };</span>
<span class="line" id="L2737">    <span class="tok-kw">defer</span> ring.deinit();</span>
<span class="line" id="L2738"></span>
<span class="line" id="L2739">    <span class="tok-kw">const</span> path = <span class="tok-str">&quot;test_io_uring_symlinkat&quot;</span>;</span>
<span class="line" id="L2740">    <span class="tok-kw">const</span> link_path = <span class="tok-str">&quot;test_io_uring_symlinkat_link&quot;</span>;</span>
<span class="line" id="L2741"></span>
<span class="line" id="L2742">    <span class="tok-kw">const</span> file = <span class="tok-kw">try</span> std.fs.cwd().createFile(path, .{ .truncate = <span class="tok-null">true</span>, .mode = <span class="tok-number">0o666</span> });</span>
<span class="line" id="L2743">    <span class="tok-kw">defer</span> {</span>
<span class="line" id="L2744">        file.close();</span>
<span class="line" id="L2745">        std.fs.cwd().deleteFile(path) <span class="tok-kw">catch</span> {};</span>
<span class="line" id="L2746">        std.fs.cwd().deleteFile(link_path) <span class="tok-kw">catch</span> {};</span>
<span class="line" id="L2747">    }</span>
<span class="line" id="L2748"></span>
<span class="line" id="L2749">    <span class="tok-comment">// Submit symlinkat</span>
</span>
<span class="line" id="L2750"></span>
<span class="line" id="L2751">    <span class="tok-kw">var</span> sqe = <span class="tok-kw">try</span> ring.symlinkat(</span>
<span class="line" id="L2752">        <span class="tok-number">0x12121212</span>,</span>
<span class="line" id="L2753">        path,</span>
<span class="line" id="L2754">        linux.AT.FDCWD,</span>
<span class="line" id="L2755">        link_path,</span>
<span class="line" id="L2756">    );</span>
<span class="line" id="L2757">    <span class="tok-kw">try</span> testing.expectEqual(linux.IORING_OP.SYMLINKAT, sqe.opcode);</span>
<span class="line" id="L2758">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">i32</span>, linux.AT.FDCWD), sqe.fd);</span>
<span class="line" id="L2759">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">1</span>), <span class="tok-kw">try</span> ring.submit());</span>
<span class="line" id="L2760"></span>
<span class="line" id="L2761">    <span class="tok-kw">const</span> cqe = <span class="tok-kw">try</span> ring.copy_cqe();</span>
<span class="line" id="L2762">    <span class="tok-kw">switch</span> (cqe.err()) {</span>
<span class="line" id="L2763">        .SUCCESS =&gt; {},</span>
<span class="line" id="L2764">        <span class="tok-comment">// This kernel's io_uring does not yet implement symlinkat (kernel version &lt; 5.15)</span>
</span>
<span class="line" id="L2765">        .BADF, .INVAL =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SkipZigTest,</span>
<span class="line" id="L2766">        <span class="tok-kw">else</span> =&gt; |errno| std.debug.panic(<span class="tok-str">&quot;unhandled errno: {}&quot;</span>, .{errno}),</span>
<span class="line" id="L2767">    }</span>
<span class="line" id="L2768">    <span class="tok-kw">try</span> testing.expectEqual(linux.io_uring_cqe{</span>
<span class="line" id="L2769">        .user_data = <span class="tok-number">0x12121212</span>,</span>
<span class="line" id="L2770">        .res = <span class="tok-number">0</span>,</span>
<span class="line" id="L2771">        .flags = <span class="tok-number">0</span>,</span>
<span class="line" id="L2772">    }, cqe);</span>
<span class="line" id="L2773"></span>
<span class="line" id="L2774">    <span class="tok-comment">// Validate that the symlink exist</span>
</span>
<span class="line" id="L2775">    _ = <span class="tok-kw">try</span> std.fs.cwd().openFile(link_path, .{});</span>
<span class="line" id="L2776">}</span>
<span class="line" id="L2777"></span>
<span class="line" id="L2778"><span class="tok-kw">test</span> <span class="tok-str">&quot;linkat&quot;</span> {</span>
<span class="line" id="L2779">    <span class="tok-kw">if</span> (builtin.os.tag != .linux) <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SkipZigTest;</span>
<span class="line" id="L2780"></span>
<span class="line" id="L2781">    <span class="tok-kw">var</span> ring = IO_Uring.init(<span class="tok-number">1</span>, <span class="tok-number">0</span>) <span class="tok-kw">catch</span> |err| <span class="tok-kw">switch</span> (err) {</span>
<span class="line" id="L2782">        <span class="tok-kw">error</span>.SystemOutdated =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SkipZigTest,</span>
<span class="line" id="L2783">        <span class="tok-kw">error</span>.PermissionDenied =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SkipZigTest,</span>
<span class="line" id="L2784">        <span class="tok-kw">else</span> =&gt; <span class="tok-kw">return</span> err,</span>
<span class="line" id="L2785">    };</span>
<span class="line" id="L2786">    <span class="tok-kw">defer</span> ring.deinit();</span>
<span class="line" id="L2787"></span>
<span class="line" id="L2788">    <span class="tok-kw">const</span> first_path = <span class="tok-str">&quot;test_io_uring_linkat_first&quot;</span>;</span>
<span class="line" id="L2789">    <span class="tok-kw">const</span> second_path = <span class="tok-str">&quot;test_io_uring_linkat_second&quot;</span>;</span>
<span class="line" id="L2790"></span>
<span class="line" id="L2791">    <span class="tok-comment">// Write file with data</span>
</span>
<span class="line" id="L2792"></span>
<span class="line" id="L2793">    <span class="tok-kw">const</span> first_file = <span class="tok-kw">try</span> std.fs.cwd().createFile(first_path, .{ .truncate = <span class="tok-null">true</span>, .mode = <span class="tok-number">0o666</span> });</span>
<span class="line" id="L2794">    <span class="tok-kw">defer</span> {</span>
<span class="line" id="L2795">        first_file.close();</span>
<span class="line" id="L2796">        std.fs.cwd().deleteFile(first_path) <span class="tok-kw">catch</span> {};</span>
<span class="line" id="L2797">        std.fs.cwd().deleteFile(second_path) <span class="tok-kw">catch</span> {};</span>
<span class="line" id="L2798">    }</span>
<span class="line" id="L2799">    <span class="tok-kw">try</span> first_file.writeAll(<span class="tok-str">&quot;hello&quot;</span>);</span>
<span class="line" id="L2800"></span>
<span class="line" id="L2801">    <span class="tok-comment">// Submit linkat</span>
</span>
<span class="line" id="L2802"></span>
<span class="line" id="L2803">    <span class="tok-kw">var</span> sqe = <span class="tok-kw">try</span> ring.linkat(</span>
<span class="line" id="L2804">        <span class="tok-number">0x12121212</span>,</span>
<span class="line" id="L2805">        linux.AT.FDCWD,</span>
<span class="line" id="L2806">        first_path,</span>
<span class="line" id="L2807">        linux.AT.FDCWD,</span>
<span class="line" id="L2808">        second_path,</span>
<span class="line" id="L2809">        <span class="tok-number">0</span>,</span>
<span class="line" id="L2810">    );</span>
<span class="line" id="L2811">    <span class="tok-kw">try</span> testing.expectEqual(linux.IORING_OP.LINKAT, sqe.opcode);</span>
<span class="line" id="L2812">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">i32</span>, linux.AT.FDCWD), sqe.fd);</span>
<span class="line" id="L2813">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">i32</span>, linux.AT.FDCWD), <span class="tok-builtin">@bitCast</span>(<span class="tok-type">i32</span>, sqe.len));</span>
<span class="line" id="L2814">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">1</span>), <span class="tok-kw">try</span> ring.submit());</span>
<span class="line" id="L2815"></span>
<span class="line" id="L2816">    <span class="tok-kw">const</span> cqe = <span class="tok-kw">try</span> ring.copy_cqe();</span>
<span class="line" id="L2817">    <span class="tok-kw">switch</span> (cqe.err()) {</span>
<span class="line" id="L2818">        .SUCCESS =&gt; {},</span>
<span class="line" id="L2819">        <span class="tok-comment">// This kernel's io_uring does not yet implement linkat (kernel version &lt; 5.15)</span>
</span>
<span class="line" id="L2820">        .BADF, .INVAL =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SkipZigTest,</span>
<span class="line" id="L2821">        <span class="tok-kw">else</span> =&gt; |errno| std.debug.panic(<span class="tok-str">&quot;unhandled errno: {}&quot;</span>, .{errno}),</span>
<span class="line" id="L2822">    }</span>
<span class="line" id="L2823">    <span class="tok-kw">try</span> testing.expectEqual(linux.io_uring_cqe{</span>
<span class="line" id="L2824">        .user_data = <span class="tok-number">0x12121212</span>,</span>
<span class="line" id="L2825">        .res = <span class="tok-number">0</span>,</span>
<span class="line" id="L2826">        .flags = <span class="tok-number">0</span>,</span>
<span class="line" id="L2827">    }, cqe);</span>
<span class="line" id="L2828"></span>
<span class="line" id="L2829">    <span class="tok-comment">// Validate the second file</span>
</span>
<span class="line" id="L2830">    <span class="tok-kw">const</span> second_file = <span class="tok-kw">try</span> std.fs.cwd().openFile(second_path, .{});</span>
<span class="line" id="L2831">    <span class="tok-kw">defer</span> second_file.close();</span>
<span class="line" id="L2832"></span>
<span class="line" id="L2833">    <span class="tok-kw">var</span> second_file_data: [<span class="tok-number">16</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L2834">    <span class="tok-kw">const</span> read = <span class="tok-kw">try</span> second_file.readAll(&amp;second_file_data);</span>
<span class="line" id="L2835">    <span class="tok-kw">try</span> testing.expectEqualStrings(<span class="tok-str">&quot;hello&quot;</span>, second_file_data[<span class="tok-number">0</span>..read]);</span>
<span class="line" id="L2836">}</span>
<span class="line" id="L2837"></span>
<span class="line" id="L2838"><span class="tok-kw">test</span> <span class="tok-str">&quot;provide_buffers: read&quot;</span> {</span>
<span class="line" id="L2839">    <span class="tok-kw">if</span> (builtin.os.tag != .linux) <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SkipZigTest;</span>
<span class="line" id="L2840"></span>
<span class="line" id="L2841">    <span class="tok-kw">var</span> ring = IO_Uring.init(<span class="tok-number">1</span>, <span class="tok-number">0</span>) <span class="tok-kw">catch</span> |err| <span class="tok-kw">switch</span> (err) {</span>
<span class="line" id="L2842">        <span class="tok-kw">error</span>.SystemOutdated =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SkipZigTest,</span>
<span class="line" id="L2843">        <span class="tok-kw">error</span>.PermissionDenied =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SkipZigTest,</span>
<span class="line" id="L2844">        <span class="tok-kw">else</span> =&gt; <span class="tok-kw">return</span> err,</span>
<span class="line" id="L2845">    };</span>
<span class="line" id="L2846">    <span class="tok-kw">defer</span> ring.deinit();</span>
<span class="line" id="L2847"></span>
<span class="line" id="L2848">    <span class="tok-kw">const</span> fd = <span class="tok-kw">try</span> os.openZ(<span class="tok-str">&quot;/dev/zero&quot;</span>, os.O.RDONLY | os.O.CLOEXEC, <span class="tok-number">0</span>);</span>
<span class="line" id="L2849">    <span class="tok-kw">defer</span> os.close(fd);</span>
<span class="line" id="L2850"></span>
<span class="line" id="L2851">    <span class="tok-kw">const</span> group_id = <span class="tok-number">1337</span>;</span>
<span class="line" id="L2852">    <span class="tok-kw">const</span> buffer_id = <span class="tok-number">0</span>;</span>
<span class="line" id="L2853"></span>
<span class="line" id="L2854">    <span class="tok-kw">const</span> buffer_len = <span class="tok-number">128</span>;</span>
<span class="line" id="L2855"></span>
<span class="line" id="L2856">    <span class="tok-kw">var</span> buffers: [<span class="tok-number">4</span>][buffer_len]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L2857"></span>
<span class="line" id="L2858">    <span class="tok-comment">// Provide 4 buffers</span>
</span>
<span class="line" id="L2859"></span>
<span class="line" id="L2860">    {</span>
<span class="line" id="L2861">        <span class="tok-kw">const</span> sqe = <span class="tok-kw">try</span> ring.provide_buffers(<span class="tok-number">0xcccccccc</span>, <span class="tok-builtin">@ptrCast</span>([*]<span class="tok-type">u8</span>, &amp;buffers), buffers.len, buffer_len, group_id, buffer_id);</span>
<span class="line" id="L2862">        <span class="tok-kw">try</span> testing.expectEqual(linux.IORING_OP.PROVIDE_BUFFERS, sqe.opcode);</span>
<span class="line" id="L2863">        <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">i32</span>, buffers.len), sqe.fd);</span>
<span class="line" id="L2864">        <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, buffers[<span class="tok-number">0</span>].len), sqe.len);</span>
<span class="line" id="L2865">        <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">u16</span>, group_id), sqe.buf_index);</span>
<span class="line" id="L2866">        <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">1</span>), <span class="tok-kw">try</span> ring.submit());</span>
<span class="line" id="L2867"></span>
<span class="line" id="L2868">        <span class="tok-kw">const</span> cqe = <span class="tok-kw">try</span> ring.copy_cqe();</span>
<span class="line" id="L2869">        <span class="tok-kw">switch</span> (cqe.err()) {</span>
<span class="line" id="L2870">            <span class="tok-comment">// Happens when the kernel is &lt; 5.7</span>
</span>
<span class="line" id="L2871">            .INVAL =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SkipZigTest,</span>
<span class="line" id="L2872">            .SUCCESS =&gt; {},</span>
<span class="line" id="L2873">            <span class="tok-kw">else</span> =&gt; |errno| std.debug.panic(<span class="tok-str">&quot;unhandled errno: {}&quot;</span>, .{errno}),</span>
<span class="line" id="L2874">        }</span>
<span class="line" id="L2875">        <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">u64</span>, <span class="tok-number">0xcccccccc</span>), cqe.user_data);</span>
<span class="line" id="L2876">    }</span>
<span class="line" id="L2877"></span>
<span class="line" id="L2878">    <span class="tok-comment">// Do 4 reads which should consume all buffers</span>
</span>
<span class="line" id="L2879"></span>
<span class="line" id="L2880">    <span class="tok-kw">var</span> i: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L2881">    <span class="tok-kw">while</span> (i &lt; buffers.len) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L2882">        <span class="tok-kw">var</span> sqe = <span class="tok-kw">try</span> ring.read(<span class="tok-number">0xdededede</span>, fd, .{ .buffer_selection = .{ .group_id = group_id, .len = buffer_len } }, <span class="tok-number">0</span>);</span>
<span class="line" id="L2883">        <span class="tok-kw">try</span> testing.expectEqual(linux.IORING_OP.READ, sqe.opcode);</span>
<span class="line" id="L2884">        <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">i32</span>, fd), sqe.fd);</span>
<span class="line" id="L2885">        <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">u64</span>, <span class="tok-number">0</span>), sqe.addr);</span>
<span class="line" id="L2886">        <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, buffer_len), sqe.len);</span>
<span class="line" id="L2887">        <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">u16</span>, group_id), sqe.buf_index);</span>
<span class="line" id="L2888">        <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">1</span>), <span class="tok-kw">try</span> ring.submit());</span>
<span class="line" id="L2889"></span>
<span class="line" id="L2890">        <span class="tok-kw">const</span> cqe = <span class="tok-kw">try</span> ring.copy_cqe();</span>
<span class="line" id="L2891">        <span class="tok-kw">switch</span> (cqe.err()) {</span>
<span class="line" id="L2892">            .SUCCESS =&gt; {},</span>
<span class="line" id="L2893">            <span class="tok-kw">else</span> =&gt; |errno| std.debug.panic(<span class="tok-str">&quot;unhandled errno: {}&quot;</span>, .{errno}),</span>
<span class="line" id="L2894">        }</span>
<span class="line" id="L2895"></span>
<span class="line" id="L2896">        <span class="tok-kw">try</span> testing.expect(cqe.flags &amp; linux.IORING_CQE_F_BUFFER == linux.IORING_CQE_F_BUFFER);</span>
<span class="line" id="L2897">        <span class="tok-kw">const</span> used_buffer_id = cqe.flags &gt;&gt; <span class="tok-number">16</span>;</span>
<span class="line" id="L2898">        <span class="tok-kw">try</span> testing.expect(used_buffer_id &gt;= <span class="tok-number">0</span> <span class="tok-kw">and</span> used_buffer_id &lt;= <span class="tok-number">3</span>);</span>
<span class="line" id="L2899">        <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">i32</span>, buffer_len), cqe.res);</span>
<span class="line" id="L2900"></span>
<span class="line" id="L2901">        <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">u64</span>, <span class="tok-number">0xdededede</span>), cqe.user_data);</span>
<span class="line" id="L2902">        <span class="tok-kw">try</span> testing.expectEqualSlices(<span class="tok-type">u8</span>, &amp;([_]<span class="tok-type">u8</span>{<span class="tok-number">0</span>} ** buffer_len), buffers[used_buffer_id][<span class="tok-number">0</span>..<span class="tok-builtin">@intCast</span>(<span class="tok-type">usize</span>, cqe.res)]);</span>
<span class="line" id="L2903">    }</span>
<span class="line" id="L2904"></span>
<span class="line" id="L2905">    <span class="tok-comment">// This read should fail</span>
</span>
<span class="line" id="L2906"></span>
<span class="line" id="L2907">    {</span>
<span class="line" id="L2908">        <span class="tok-kw">var</span> sqe = <span class="tok-kw">try</span> ring.read(<span class="tok-number">0xdfdfdfdf</span>, fd, .{ .buffer_selection = .{ .group_id = group_id, .len = buffer_len } }, <span class="tok-number">0</span>);</span>
<span class="line" id="L2909">        <span class="tok-kw">try</span> testing.expectEqual(linux.IORING_OP.READ, sqe.opcode);</span>
<span class="line" id="L2910">        <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">i32</span>, fd), sqe.fd);</span>
<span class="line" id="L2911">        <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">u64</span>, <span class="tok-number">0</span>), sqe.addr);</span>
<span class="line" id="L2912">        <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, buffer_len), sqe.len);</span>
<span class="line" id="L2913">        <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">u16</span>, group_id), sqe.buf_index);</span>
<span class="line" id="L2914">        <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">1</span>), <span class="tok-kw">try</span> ring.submit());</span>
<span class="line" id="L2915"></span>
<span class="line" id="L2916">        <span class="tok-kw">const</span> cqe = <span class="tok-kw">try</span> ring.copy_cqe();</span>
<span class="line" id="L2917">        <span class="tok-kw">switch</span> (cqe.err()) {</span>
<span class="line" id="L2918">            <span class="tok-comment">// Expected</span>
</span>
<span class="line" id="L2919">            .NOBUFS =&gt; {},</span>
<span class="line" id="L2920">            .SUCCESS =&gt; std.debug.panic(<span class="tok-str">&quot;unexpected success&quot;</span>, .{}),</span>
<span class="line" id="L2921">            <span class="tok-kw">else</span> =&gt; |errno| std.debug.panic(<span class="tok-str">&quot;unhandled errno: {}&quot;</span>, .{errno}),</span>
<span class="line" id="L2922">        }</span>
<span class="line" id="L2923">        <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">u64</span>, <span class="tok-number">0xdfdfdfdf</span>), cqe.user_data);</span>
<span class="line" id="L2924">    }</span>
<span class="line" id="L2925"></span>
<span class="line" id="L2926">    <span class="tok-comment">// Provide 1 buffer again</span>
</span>
<span class="line" id="L2927"></span>
<span class="line" id="L2928">    <span class="tok-comment">// Deliberately put something we don't expect in the buffers</span>
</span>
<span class="line" id="L2929">    mem.set(<span class="tok-type">u8</span>, mem.sliceAsBytes(&amp;buffers), <span class="tok-number">42</span>);</span>
<span class="line" id="L2930"></span>
<span class="line" id="L2931">    <span class="tok-kw">const</span> reprovided_buffer_id = <span class="tok-number">2</span>;</span>
<span class="line" id="L2932"></span>
<span class="line" id="L2933">    {</span>
<span class="line" id="L2934">        _ = <span class="tok-kw">try</span> ring.provide_buffers(<span class="tok-number">0xabababab</span>, <span class="tok-builtin">@ptrCast</span>([*]<span class="tok-type">u8</span>, &amp;buffers[reprovided_buffer_id]), <span class="tok-number">1</span>, buffer_len, group_id, reprovided_buffer_id);</span>
<span class="line" id="L2935">        <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">1</span>), <span class="tok-kw">try</span> ring.submit());</span>
<span class="line" id="L2936"></span>
<span class="line" id="L2937">        <span class="tok-kw">const</span> cqe = <span class="tok-kw">try</span> ring.copy_cqe();</span>
<span class="line" id="L2938">        <span class="tok-kw">switch</span> (cqe.err()) {</span>
<span class="line" id="L2939">            .SUCCESS =&gt; {},</span>
<span class="line" id="L2940">            <span class="tok-kw">else</span> =&gt; |errno| std.debug.panic(<span class="tok-str">&quot;unhandled errno: {}&quot;</span>, .{errno}),</span>
<span class="line" id="L2941">        }</span>
<span class="line" id="L2942">    }</span>
<span class="line" id="L2943"></span>
<span class="line" id="L2944">    <span class="tok-comment">// Final read which should work</span>
</span>
<span class="line" id="L2945"></span>
<span class="line" id="L2946">    {</span>
<span class="line" id="L2947">        <span class="tok-kw">var</span> sqe = <span class="tok-kw">try</span> ring.read(<span class="tok-number">0xdfdfdfdf</span>, fd, .{ .buffer_selection = .{ .group_id = group_id, .len = buffer_len } }, <span class="tok-number">0</span>);</span>
<span class="line" id="L2948">        <span class="tok-kw">try</span> testing.expectEqual(linux.IORING_OP.READ, sqe.opcode);</span>
<span class="line" id="L2949">        <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">i32</span>, fd), sqe.fd);</span>
<span class="line" id="L2950">        <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">u64</span>, <span class="tok-number">0</span>), sqe.addr);</span>
<span class="line" id="L2951">        <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, buffer_len), sqe.len);</span>
<span class="line" id="L2952">        <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">u16</span>, group_id), sqe.buf_index);</span>
<span class="line" id="L2953">        <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">1</span>), <span class="tok-kw">try</span> ring.submit());</span>
<span class="line" id="L2954"></span>
<span class="line" id="L2955">        <span class="tok-kw">const</span> cqe = <span class="tok-kw">try</span> ring.copy_cqe();</span>
<span class="line" id="L2956">        <span class="tok-kw">switch</span> (cqe.err()) {</span>
<span class="line" id="L2957">            .SUCCESS =&gt; {},</span>
<span class="line" id="L2958">            <span class="tok-kw">else</span> =&gt; |errno| std.debug.panic(<span class="tok-str">&quot;unhandled errno: {}&quot;</span>, .{errno}),</span>
<span class="line" id="L2959">        }</span>
<span class="line" id="L2960"></span>
<span class="line" id="L2961">        <span class="tok-kw">try</span> testing.expect(cqe.flags &amp; linux.IORING_CQE_F_BUFFER == linux.IORING_CQE_F_BUFFER);</span>
<span class="line" id="L2962">        <span class="tok-kw">const</span> used_buffer_id = cqe.flags &gt;&gt; <span class="tok-number">16</span>;</span>
<span class="line" id="L2963">        <span class="tok-kw">try</span> testing.expectEqual(used_buffer_id, reprovided_buffer_id);</span>
<span class="line" id="L2964">        <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">i32</span>, buffer_len), cqe.res);</span>
<span class="line" id="L2965">        <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">u64</span>, <span class="tok-number">0xdfdfdfdf</span>), cqe.user_data);</span>
<span class="line" id="L2966">        <span class="tok-kw">try</span> testing.expectEqualSlices(<span class="tok-type">u8</span>, &amp;([_]<span class="tok-type">u8</span>{<span class="tok-number">0</span>} ** buffer_len), buffers[used_buffer_id][<span class="tok-number">0</span>..<span class="tok-builtin">@intCast</span>(<span class="tok-type">usize</span>, cqe.res)]);</span>
<span class="line" id="L2967">    }</span>
<span class="line" id="L2968">}</span>
<span class="line" id="L2969"></span>
<span class="line" id="L2970"><span class="tok-kw">test</span> <span class="tok-str">&quot;remove_buffers&quot;</span> {</span>
<span class="line" id="L2971">    <span class="tok-kw">if</span> (builtin.os.tag != .linux) <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SkipZigTest;</span>
<span class="line" id="L2972"></span>
<span class="line" id="L2973">    <span class="tok-kw">var</span> ring = IO_Uring.init(<span class="tok-number">1</span>, <span class="tok-number">0</span>) <span class="tok-kw">catch</span> |err| <span class="tok-kw">switch</span> (err) {</span>
<span class="line" id="L2974">        <span class="tok-kw">error</span>.SystemOutdated =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SkipZigTest,</span>
<span class="line" id="L2975">        <span class="tok-kw">error</span>.PermissionDenied =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SkipZigTest,</span>
<span class="line" id="L2976">        <span class="tok-kw">else</span> =&gt; <span class="tok-kw">return</span> err,</span>
<span class="line" id="L2977">    };</span>
<span class="line" id="L2978">    <span class="tok-kw">defer</span> ring.deinit();</span>
<span class="line" id="L2979"></span>
<span class="line" id="L2980">    <span class="tok-kw">const</span> fd = <span class="tok-kw">try</span> os.openZ(<span class="tok-str">&quot;/dev/zero&quot;</span>, os.O.RDONLY | os.O.CLOEXEC, <span class="tok-number">0</span>);</span>
<span class="line" id="L2981">    <span class="tok-kw">defer</span> os.close(fd);</span>
<span class="line" id="L2982"></span>
<span class="line" id="L2983">    <span class="tok-kw">const</span> group_id = <span class="tok-number">1337</span>;</span>
<span class="line" id="L2984">    <span class="tok-kw">const</span> buffer_id = <span class="tok-number">0</span>;</span>
<span class="line" id="L2985"></span>
<span class="line" id="L2986">    <span class="tok-kw">const</span> buffer_len = <span class="tok-number">128</span>;</span>
<span class="line" id="L2987"></span>
<span class="line" id="L2988">    <span class="tok-kw">var</span> buffers: [<span class="tok-number">4</span>][buffer_len]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L2989"></span>
<span class="line" id="L2990">    <span class="tok-comment">// Provide 4 buffers</span>
</span>
<span class="line" id="L2991"></span>
<span class="line" id="L2992">    {</span>
<span class="line" id="L2993">        _ = <span class="tok-kw">try</span> ring.provide_buffers(<span class="tok-number">0xcccccccc</span>, <span class="tok-builtin">@ptrCast</span>([*]<span class="tok-type">u8</span>, &amp;buffers), buffers.len, buffer_len, group_id, buffer_id);</span>
<span class="line" id="L2994">        <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">1</span>), <span class="tok-kw">try</span> ring.submit());</span>
<span class="line" id="L2995"></span>
<span class="line" id="L2996">        <span class="tok-kw">const</span> cqe = <span class="tok-kw">try</span> ring.copy_cqe();</span>
<span class="line" id="L2997">        <span class="tok-kw">switch</span> (cqe.err()) {</span>
<span class="line" id="L2998">            .SUCCESS =&gt; {},</span>
<span class="line" id="L2999">            <span class="tok-kw">else</span> =&gt; |errno| std.debug.panic(<span class="tok-str">&quot;unhandled errno: {}&quot;</span>, .{errno}),</span>
<span class="line" id="L3000">        }</span>
<span class="line" id="L3001">        <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">u64</span>, <span class="tok-number">0xcccccccc</span>), cqe.user_data);</span>
<span class="line" id="L3002">    }</span>
<span class="line" id="L3003"></span>
<span class="line" id="L3004">    <span class="tok-comment">// Remove 3 buffers</span>
</span>
<span class="line" id="L3005"></span>
<span class="line" id="L3006">    {</span>
<span class="line" id="L3007">        <span class="tok-kw">var</span> sqe = <span class="tok-kw">try</span> ring.remove_buffers(<span class="tok-number">0xbababababa</span>, <span class="tok-number">3</span>, group_id);</span>
<span class="line" id="L3008">        <span class="tok-kw">try</span> testing.expectEqual(linux.IORING_OP.REMOVE_BUFFERS, sqe.opcode);</span>
<span class="line" id="L3009">        <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">i32</span>, <span class="tok-number">3</span>), sqe.fd);</span>
<span class="line" id="L3010">        <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">u64</span>, <span class="tok-number">0</span>), sqe.addr);</span>
<span class="line" id="L3011">        <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">u16</span>, group_id), sqe.buf_index);</span>
<span class="line" id="L3012">        <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">1</span>), <span class="tok-kw">try</span> ring.submit());</span>
<span class="line" id="L3013"></span>
<span class="line" id="L3014">        <span class="tok-kw">const</span> cqe = <span class="tok-kw">try</span> ring.copy_cqe();</span>
<span class="line" id="L3015">        <span class="tok-kw">switch</span> (cqe.err()) {</span>
<span class="line" id="L3016">            .SUCCESS =&gt; {},</span>
<span class="line" id="L3017">            <span class="tok-kw">else</span> =&gt; |errno| std.debug.panic(<span class="tok-str">&quot;unhandled errno: {}&quot;</span>, .{errno}),</span>
<span class="line" id="L3018">        }</span>
<span class="line" id="L3019">        <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">u64</span>, <span class="tok-number">0xbababababa</span>), cqe.user_data);</span>
<span class="line" id="L3020">    }</span>
<span class="line" id="L3021"></span>
<span class="line" id="L3022">    <span class="tok-comment">// This read should work</span>
</span>
<span class="line" id="L3023"></span>
<span class="line" id="L3024">    {</span>
<span class="line" id="L3025">        _ = <span class="tok-kw">try</span> ring.read(<span class="tok-number">0xdfdfdfdf</span>, fd, .{ .buffer_selection = .{ .group_id = group_id, .len = buffer_len } }, <span class="tok-number">0</span>);</span>
<span class="line" id="L3026">        <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">1</span>), <span class="tok-kw">try</span> ring.submit());</span>
<span class="line" id="L3027"></span>
<span class="line" id="L3028">        <span class="tok-kw">const</span> cqe = <span class="tok-kw">try</span> ring.copy_cqe();</span>
<span class="line" id="L3029">        <span class="tok-kw">switch</span> (cqe.err()) {</span>
<span class="line" id="L3030">            .SUCCESS =&gt; {},</span>
<span class="line" id="L3031">            <span class="tok-kw">else</span> =&gt; |errno| std.debug.panic(<span class="tok-str">&quot;unhandled errno: {}&quot;</span>, .{errno}),</span>
<span class="line" id="L3032">        }</span>
<span class="line" id="L3033"></span>
<span class="line" id="L3034">        <span class="tok-kw">try</span> testing.expect(cqe.flags &amp; linux.IORING_CQE_F_BUFFER == linux.IORING_CQE_F_BUFFER);</span>
<span class="line" id="L3035">        <span class="tok-kw">const</span> used_buffer_id = cqe.flags &gt;&gt; <span class="tok-number">16</span>;</span>
<span class="line" id="L3036">        <span class="tok-kw">try</span> testing.expect(used_buffer_id &gt;= <span class="tok-number">0</span> <span class="tok-kw">and</span> used_buffer_id &lt; <span class="tok-number">4</span>);</span>
<span class="line" id="L3037">        <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">i32</span>, buffer_len), cqe.res);</span>
<span class="line" id="L3038">        <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">u64</span>, <span class="tok-number">0xdfdfdfdf</span>), cqe.user_data);</span>
<span class="line" id="L3039">        <span class="tok-kw">try</span> testing.expectEqualSlices(<span class="tok-type">u8</span>, &amp;([_]<span class="tok-type">u8</span>{<span class="tok-number">0</span>} ** buffer_len), buffers[used_buffer_id][<span class="tok-number">0</span>..<span class="tok-builtin">@intCast</span>(<span class="tok-type">usize</span>, cqe.res)]);</span>
<span class="line" id="L3040">    }</span>
<span class="line" id="L3041"></span>
<span class="line" id="L3042">    <span class="tok-comment">// Final read should _not_ work</span>
</span>
<span class="line" id="L3043"></span>
<span class="line" id="L3044">    {</span>
<span class="line" id="L3045">        _ = <span class="tok-kw">try</span> ring.read(<span class="tok-number">0xdfdfdfdf</span>, fd, .{ .buffer_selection = .{ .group_id = group_id, .len = buffer_len } }, <span class="tok-number">0</span>);</span>
<span class="line" id="L3046">        <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">1</span>), <span class="tok-kw">try</span> ring.submit());</span>
<span class="line" id="L3047"></span>
<span class="line" id="L3048">        <span class="tok-kw">const</span> cqe = <span class="tok-kw">try</span> ring.copy_cqe();</span>
<span class="line" id="L3049">        <span class="tok-kw">switch</span> (cqe.err()) {</span>
<span class="line" id="L3050">            <span class="tok-comment">// Expected</span>
</span>
<span class="line" id="L3051">            .NOBUFS =&gt; {},</span>
<span class="line" id="L3052">            .SUCCESS =&gt; std.debug.panic(<span class="tok-str">&quot;unexpected success&quot;</span>, .{}),</span>
<span class="line" id="L3053">            <span class="tok-kw">else</span> =&gt; |errno| std.debug.panic(<span class="tok-str">&quot;unhandled errno: {}&quot;</span>, .{errno}),</span>
<span class="line" id="L3054">        }</span>
<span class="line" id="L3055">    }</span>
<span class="line" id="L3056">}</span>
<span class="line" id="L3057"></span>
<span class="line" id="L3058"><span class="tok-kw">test</span> <span class="tok-str">&quot;provide_buffers: accept/connect/send/recv&quot;</span> {</span>
<span class="line" id="L3059">    <span class="tok-kw">if</span> (builtin.os.tag != .linux) <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SkipZigTest;</span>
<span class="line" id="L3060"></span>
<span class="line" id="L3061">    <span class="tok-kw">var</span> ring = IO_Uring.init(<span class="tok-number">16</span>, <span class="tok-number">0</span>) <span class="tok-kw">catch</span> |err| <span class="tok-kw">switch</span> (err) {</span>
<span class="line" id="L3062">        <span class="tok-kw">error</span>.SystemOutdated =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SkipZigTest,</span>
<span class="line" id="L3063">        <span class="tok-kw">error</span>.PermissionDenied =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SkipZigTest,</span>
<span class="line" id="L3064">        <span class="tok-kw">else</span> =&gt; <span class="tok-kw">return</span> err,</span>
<span class="line" id="L3065">    };</span>
<span class="line" id="L3066">    <span class="tok-kw">defer</span> ring.deinit();</span>
<span class="line" id="L3067"></span>
<span class="line" id="L3068">    <span class="tok-kw">const</span> group_id = <span class="tok-number">1337</span>;</span>
<span class="line" id="L3069">    <span class="tok-kw">const</span> buffer_id = <span class="tok-number">0</span>;</span>
<span class="line" id="L3070"></span>
<span class="line" id="L3071">    <span class="tok-kw">const</span> buffer_len = <span class="tok-number">128</span>;</span>
<span class="line" id="L3072">    <span class="tok-kw">var</span> buffers: [<span class="tok-number">4</span>][buffer_len]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L3073"></span>
<span class="line" id="L3074">    <span class="tok-comment">// Provide 4 buffers</span>
</span>
<span class="line" id="L3075"></span>
<span class="line" id="L3076">    {</span>
<span class="line" id="L3077">        <span class="tok-kw">const</span> sqe = <span class="tok-kw">try</span> ring.provide_buffers(<span class="tok-number">0xcccccccc</span>, <span class="tok-builtin">@ptrCast</span>([*]<span class="tok-type">u8</span>, &amp;buffers), buffers.len, buffer_len, group_id, buffer_id);</span>
<span class="line" id="L3078">        <span class="tok-kw">try</span> testing.expectEqual(linux.IORING_OP.PROVIDE_BUFFERS, sqe.opcode);</span>
<span class="line" id="L3079">        <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">i32</span>, buffers.len), sqe.fd);</span>
<span class="line" id="L3080">        <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, buffer_len), sqe.len);</span>
<span class="line" id="L3081">        <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">u16</span>, group_id), sqe.buf_index);</span>
<span class="line" id="L3082">        <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">1</span>), <span class="tok-kw">try</span> ring.submit());</span>
<span class="line" id="L3083"></span>
<span class="line" id="L3084">        <span class="tok-kw">const</span> cqe = <span class="tok-kw">try</span> ring.copy_cqe();</span>
<span class="line" id="L3085">        <span class="tok-kw">switch</span> (cqe.err()) {</span>
<span class="line" id="L3086">            <span class="tok-comment">// Happens when the kernel is &lt; 5.7</span>
</span>
<span class="line" id="L3087">            .INVAL =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SkipZigTest,</span>
<span class="line" id="L3088">            .SUCCESS =&gt; {},</span>
<span class="line" id="L3089">            <span class="tok-kw">else</span> =&gt; |errno| std.debug.panic(<span class="tok-str">&quot;unhandled errno: {}&quot;</span>, .{errno}),</span>
<span class="line" id="L3090">        }</span>
<span class="line" id="L3091">        <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">u64</span>, <span class="tok-number">0xcccccccc</span>), cqe.user_data);</span>
<span class="line" id="L3092">    }</span>
<span class="line" id="L3093"></span>
<span class="line" id="L3094">    <span class="tok-kw">const</span> socket_test_harness = <span class="tok-kw">try</span> createSocketTestHarness(&amp;ring);</span>
<span class="line" id="L3095">    <span class="tok-kw">defer</span> socket_test_harness.close();</span>
<span class="line" id="L3096"></span>
<span class="line" id="L3097">    <span class="tok-comment">// Do 4 send on the socket</span>
</span>
<span class="line" id="L3098"></span>
<span class="line" id="L3099">    {</span>
<span class="line" id="L3100">        <span class="tok-kw">var</span> i: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L3101">        <span class="tok-kw">while</span> (i &lt; buffers.len) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L3102">            _ = <span class="tok-kw">try</span> ring.send(<span class="tok-number">0xdeaddead</span>, socket_test_harness.server, &amp;([_]<span class="tok-type">u8</span>{<span class="tok-str">'z'</span>} ** buffer_len), <span class="tok-number">0</span>);</span>
<span class="line" id="L3103">            <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">1</span>), <span class="tok-kw">try</span> ring.submit());</span>
<span class="line" id="L3104">        }</span>
<span class="line" id="L3105"></span>
<span class="line" id="L3106">        <span class="tok-kw">var</span> cqes: [<span class="tok-number">4</span>]linux.io_uring_cqe = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L3107">        <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">4</span>), <span class="tok-kw">try</span> ring.copy_cqes(&amp;cqes, <span class="tok-number">4</span>));</span>
<span class="line" id="L3108">    }</span>
<span class="line" id="L3109"></span>
<span class="line" id="L3110">    <span class="tok-comment">// Do 4 recv which should consume all buffers</span>
</span>
<span class="line" id="L3111"></span>
<span class="line" id="L3112">    <span class="tok-comment">// Deliberately put something we don't expect in the buffers</span>
</span>
<span class="line" id="L3113">    mem.set(<span class="tok-type">u8</span>, mem.sliceAsBytes(&amp;buffers), <span class="tok-number">1</span>);</span>
<span class="line" id="L3114"></span>
<span class="line" id="L3115">    <span class="tok-kw">var</span> i: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L3116">    <span class="tok-kw">while</span> (i &lt; buffers.len) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L3117">        <span class="tok-kw">var</span> sqe = <span class="tok-kw">try</span> ring.recv(<span class="tok-number">0xdededede</span>, socket_test_harness.client, .{ .buffer_selection = .{ .group_id = group_id, .len = buffer_len } }, <span class="tok-number">0</span>);</span>
<span class="line" id="L3118">        <span class="tok-kw">try</span> testing.expectEqual(linux.IORING_OP.RECV, sqe.opcode);</span>
<span class="line" id="L3119">        <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">i32</span>, socket_test_harness.client), sqe.fd);</span>
<span class="line" id="L3120">        <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">u64</span>, <span class="tok-number">0</span>), sqe.addr);</span>
<span class="line" id="L3121">        <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, buffer_len), sqe.len);</span>
<span class="line" id="L3122">        <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">u16</span>, group_id), sqe.buf_index);</span>
<span class="line" id="L3123">        <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">0</span>), sqe.rw_flags);</span>
<span class="line" id="L3124">        <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, linux.IOSQE_BUFFER_SELECT), sqe.flags);</span>
<span class="line" id="L3125">        <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">1</span>), <span class="tok-kw">try</span> ring.submit());</span>
<span class="line" id="L3126"></span>
<span class="line" id="L3127">        <span class="tok-kw">const</span> cqe = <span class="tok-kw">try</span> ring.copy_cqe();</span>
<span class="line" id="L3128">        <span class="tok-kw">switch</span> (cqe.err()) {</span>
<span class="line" id="L3129">            .SUCCESS =&gt; {},</span>
<span class="line" id="L3130">            <span class="tok-kw">else</span> =&gt; |errno| std.debug.panic(<span class="tok-str">&quot;unhandled errno: {}&quot;</span>, .{errno}),</span>
<span class="line" id="L3131">        }</span>
<span class="line" id="L3132"></span>
<span class="line" id="L3133">        <span class="tok-kw">try</span> testing.expect(cqe.flags &amp; linux.IORING_CQE_F_BUFFER == linux.IORING_CQE_F_BUFFER);</span>
<span class="line" id="L3134">        <span class="tok-kw">const</span> used_buffer_id = cqe.flags &gt;&gt; <span class="tok-number">16</span>;</span>
<span class="line" id="L3135">        <span class="tok-kw">try</span> testing.expect(used_buffer_id &gt;= <span class="tok-number">0</span> <span class="tok-kw">and</span> used_buffer_id &lt;= <span class="tok-number">3</span>);</span>
<span class="line" id="L3136">        <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">i32</span>, buffer_len), cqe.res);</span>
<span class="line" id="L3137"></span>
<span class="line" id="L3138">        <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">u64</span>, <span class="tok-number">0xdededede</span>), cqe.user_data);</span>
<span class="line" id="L3139">        <span class="tok-kw">const</span> buffer = buffers[used_buffer_id][<span class="tok-number">0</span>..<span class="tok-builtin">@intCast</span>(<span class="tok-type">usize</span>, cqe.res)];</span>
<span class="line" id="L3140">        <span class="tok-kw">try</span> testing.expectEqualSlices(<span class="tok-type">u8</span>, &amp;([_]<span class="tok-type">u8</span>{<span class="tok-str">'z'</span>} ** buffer_len), buffer);</span>
<span class="line" id="L3141">    }</span>
<span class="line" id="L3142"></span>
<span class="line" id="L3143">    <span class="tok-comment">// This recv should fail</span>
</span>
<span class="line" id="L3144"></span>
<span class="line" id="L3145">    {</span>
<span class="line" id="L3146">        <span class="tok-kw">var</span> sqe = <span class="tok-kw">try</span> ring.recv(<span class="tok-number">0xdfdfdfdf</span>, socket_test_harness.client, .{ .buffer_selection = .{ .group_id = group_id, .len = buffer_len } }, <span class="tok-number">0</span>);</span>
<span class="line" id="L3147">        <span class="tok-kw">try</span> testing.expectEqual(linux.IORING_OP.RECV, sqe.opcode);</span>
<span class="line" id="L3148">        <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">i32</span>, socket_test_harness.client), sqe.fd);</span>
<span class="line" id="L3149">        <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">u64</span>, <span class="tok-number">0</span>), sqe.addr);</span>
<span class="line" id="L3150">        <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, buffer_len), sqe.len);</span>
<span class="line" id="L3151">        <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">u16</span>, group_id), sqe.buf_index);</span>
<span class="line" id="L3152">        <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">0</span>), sqe.rw_flags);</span>
<span class="line" id="L3153">        <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, linux.IOSQE_BUFFER_SELECT), sqe.flags);</span>
<span class="line" id="L3154">        <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">1</span>), <span class="tok-kw">try</span> ring.submit());</span>
<span class="line" id="L3155"></span>
<span class="line" id="L3156">        <span class="tok-kw">const</span> cqe = <span class="tok-kw">try</span> ring.copy_cqe();</span>
<span class="line" id="L3157">        <span class="tok-kw">switch</span> (cqe.err()) {</span>
<span class="line" id="L3158">            <span class="tok-comment">// Expected</span>
</span>
<span class="line" id="L3159">            .NOBUFS =&gt; {},</span>
<span class="line" id="L3160">            .SUCCESS =&gt; std.debug.panic(<span class="tok-str">&quot;unexpected success&quot;</span>, .{}),</span>
<span class="line" id="L3161">            <span class="tok-kw">else</span> =&gt; |errno| std.debug.panic(<span class="tok-str">&quot;unhandled errno: {}&quot;</span>, .{errno}),</span>
<span class="line" id="L3162">        }</span>
<span class="line" id="L3163">        <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">u64</span>, <span class="tok-number">0xdfdfdfdf</span>), cqe.user_data);</span>
<span class="line" id="L3164">    }</span>
<span class="line" id="L3165"></span>
<span class="line" id="L3166">    <span class="tok-comment">// Provide 1 buffer again</span>
</span>
<span class="line" id="L3167"></span>
<span class="line" id="L3168">    <span class="tok-kw">const</span> reprovided_buffer_id = <span class="tok-number">2</span>;</span>
<span class="line" id="L3169"></span>
<span class="line" id="L3170">    {</span>
<span class="line" id="L3171">        _ = <span class="tok-kw">try</span> ring.provide_buffers(<span class="tok-number">0xabababab</span>, <span class="tok-builtin">@ptrCast</span>([*]<span class="tok-type">u8</span>, &amp;buffers[reprovided_buffer_id]), <span class="tok-number">1</span>, buffer_len, group_id, reprovided_buffer_id);</span>
<span class="line" id="L3172">        <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">1</span>), <span class="tok-kw">try</span> ring.submit());</span>
<span class="line" id="L3173"></span>
<span class="line" id="L3174">        <span class="tok-kw">const</span> cqe = <span class="tok-kw">try</span> ring.copy_cqe();</span>
<span class="line" id="L3175">        <span class="tok-kw">switch</span> (cqe.err()) {</span>
<span class="line" id="L3176">            .SUCCESS =&gt; {},</span>
<span class="line" id="L3177">            <span class="tok-kw">else</span> =&gt; |errno| std.debug.panic(<span class="tok-str">&quot;unhandled errno: {}&quot;</span>, .{errno}),</span>
<span class="line" id="L3178">        }</span>
<span class="line" id="L3179">    }</span>
<span class="line" id="L3180"></span>
<span class="line" id="L3181">    <span class="tok-comment">// Redo 1 send on the server socket</span>
</span>
<span class="line" id="L3182"></span>
<span class="line" id="L3183">    {</span>
<span class="line" id="L3184">        _ = <span class="tok-kw">try</span> ring.send(<span class="tok-number">0xdeaddead</span>, socket_test_harness.server, &amp;([_]<span class="tok-type">u8</span>{<span class="tok-str">'w'</span>} ** buffer_len), <span class="tok-number">0</span>);</span>
<span class="line" id="L3185">        <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">1</span>), <span class="tok-kw">try</span> ring.submit());</span>
<span class="line" id="L3186"></span>
<span class="line" id="L3187">        _ = <span class="tok-kw">try</span> ring.copy_cqe();</span>
<span class="line" id="L3188">    }</span>
<span class="line" id="L3189"></span>
<span class="line" id="L3190">    <span class="tok-comment">// Final recv which should work</span>
</span>
<span class="line" id="L3191"></span>
<span class="line" id="L3192">    <span class="tok-comment">// Deliberately put something we don't expect in the buffers</span>
</span>
<span class="line" id="L3193">    mem.set(<span class="tok-type">u8</span>, mem.sliceAsBytes(&amp;buffers), <span class="tok-number">1</span>);</span>
<span class="line" id="L3194"></span>
<span class="line" id="L3195">    {</span>
<span class="line" id="L3196">        <span class="tok-kw">var</span> sqe = <span class="tok-kw">try</span> ring.recv(<span class="tok-number">0xdfdfdfdf</span>, socket_test_harness.client, .{ .buffer_selection = .{ .group_id = group_id, .len = buffer_len } }, <span class="tok-number">0</span>);</span>
<span class="line" id="L3197">        <span class="tok-kw">try</span> testing.expectEqual(linux.IORING_OP.RECV, sqe.opcode);</span>
<span class="line" id="L3198">        <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">i32</span>, socket_test_harness.client), sqe.fd);</span>
<span class="line" id="L3199">        <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">u64</span>, <span class="tok-number">0</span>), sqe.addr);</span>
<span class="line" id="L3200">        <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, buffer_len), sqe.len);</span>
<span class="line" id="L3201">        <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">u16</span>, group_id), sqe.buf_index);</span>
<span class="line" id="L3202">        <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">0</span>), sqe.rw_flags);</span>
<span class="line" id="L3203">        <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, linux.IOSQE_BUFFER_SELECT), sqe.flags);</span>
<span class="line" id="L3204">        <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">1</span>), <span class="tok-kw">try</span> ring.submit());</span>
<span class="line" id="L3205"></span>
<span class="line" id="L3206">        <span class="tok-kw">const</span> cqe = <span class="tok-kw">try</span> ring.copy_cqe();</span>
<span class="line" id="L3207">        <span class="tok-kw">switch</span> (cqe.err()) {</span>
<span class="line" id="L3208">            .SUCCESS =&gt; {},</span>
<span class="line" id="L3209">            <span class="tok-kw">else</span> =&gt; |errno| std.debug.panic(<span class="tok-str">&quot;unhandled errno: {}&quot;</span>, .{errno}),</span>
<span class="line" id="L3210">        }</span>
<span class="line" id="L3211"></span>
<span class="line" id="L3212">        <span class="tok-kw">try</span> testing.expect(cqe.flags &amp; linux.IORING_CQE_F_BUFFER == linux.IORING_CQE_F_BUFFER);</span>
<span class="line" id="L3213">        <span class="tok-kw">const</span> used_buffer_id = cqe.flags &gt;&gt; <span class="tok-number">16</span>;</span>
<span class="line" id="L3214">        <span class="tok-kw">try</span> testing.expectEqual(used_buffer_id, reprovided_buffer_id);</span>
<span class="line" id="L3215">        <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">i32</span>, buffer_len), cqe.res);</span>
<span class="line" id="L3216">        <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">u64</span>, <span class="tok-number">0xdfdfdfdf</span>), cqe.user_data);</span>
<span class="line" id="L3217">        <span class="tok-kw">const</span> buffer = buffers[used_buffer_id][<span class="tok-number">0</span>..<span class="tok-builtin">@intCast</span>(<span class="tok-type">usize</span>, cqe.res)];</span>
<span class="line" id="L3218">        <span class="tok-kw">try</span> testing.expectEqualSlices(<span class="tok-type">u8</span>, &amp;([_]<span class="tok-type">u8</span>{<span class="tok-str">'w'</span>} ** buffer_len), buffer);</span>
<span class="line" id="L3219">    }</span>
<span class="line" id="L3220">}</span>
<span class="line" id="L3221"></span>
<span class="line" id="L3222"><span class="tok-comment">/// Used for testing server/client interactions.</span></span>
<span class="line" id="L3223"><span class="tok-kw">const</span> SocketTestHarness = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L3224">    listener: os.socket_t,</span>
<span class="line" id="L3225">    server: os.socket_t,</span>
<span class="line" id="L3226">    client: os.socket_t,</span>
<span class="line" id="L3227"></span>
<span class="line" id="L3228">    <span class="tok-kw">fn</span> <span class="tok-fn">close</span>(self: SocketTestHarness) <span class="tok-type">void</span> {</span>
<span class="line" id="L3229">        os.closeSocket(self.client);</span>
<span class="line" id="L3230">        os.closeSocket(self.listener);</span>
<span class="line" id="L3231">    }</span>
<span class="line" id="L3232">};</span>
<span class="line" id="L3233"></span>
<span class="line" id="L3234"><span class="tok-kw">fn</span> <span class="tok-fn">createSocketTestHarness</span>(ring: *IO_Uring) !SocketTestHarness {</span>
<span class="line" id="L3235">    <span class="tok-comment">// Create a TCP server socket</span>
</span>
<span class="line" id="L3236"></span>
<span class="line" id="L3237">    <span class="tok-kw">const</span> address = <span class="tok-kw">try</span> net.Address.parseIp4(<span class="tok-str">&quot;127.0.0.1&quot;</span>, <span class="tok-number">3131</span>);</span>
<span class="line" id="L3238">    <span class="tok-kw">const</span> kernel_backlog = <span class="tok-number">1</span>;</span>
<span class="line" id="L3239">    <span class="tok-kw">const</span> listener_socket = <span class="tok-kw">try</span> os.socket(address.any.family, os.SOCK.STREAM | os.SOCK.CLOEXEC, <span class="tok-number">0</span>);</span>
<span class="line" id="L3240">    <span class="tok-kw">errdefer</span> os.closeSocket(listener_socket);</span>
<span class="line" id="L3241"></span>
<span class="line" id="L3242">    <span class="tok-kw">try</span> os.setsockopt(listener_socket, os.SOL.SOCKET, os.SO.REUSEADDR, &amp;mem.toBytes(<span class="tok-builtin">@as</span>(<span class="tok-type">c_int</span>, <span class="tok-number">1</span>)));</span>
<span class="line" id="L3243">    <span class="tok-kw">try</span> os.bind(listener_socket, &amp;address.any, address.getOsSockLen());</span>
<span class="line" id="L3244">    <span class="tok-kw">try</span> os.listen(listener_socket, kernel_backlog);</span>
<span class="line" id="L3245"></span>
<span class="line" id="L3246">    <span class="tok-comment">// Submit 1 accept</span>
</span>
<span class="line" id="L3247">    <span class="tok-kw">var</span> accept_addr: os.sockaddr = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L3248">    <span class="tok-kw">var</span> accept_addr_len: os.socklen_t = <span class="tok-builtin">@sizeOf</span>(<span class="tok-builtin">@TypeOf</span>(accept_addr));</span>
<span class="line" id="L3249">    _ = <span class="tok-kw">try</span> ring.accept(<span class="tok-number">0xaaaaaaaa</span>, listener_socket, &amp;accept_addr, &amp;accept_addr_len, <span class="tok-number">0</span>);</span>
<span class="line" id="L3250"></span>
<span class="line" id="L3251">    <span class="tok-comment">// Create a TCP client socket</span>
</span>
<span class="line" id="L3252">    <span class="tok-kw">const</span> client = <span class="tok-kw">try</span> os.socket(address.any.family, os.SOCK.STREAM | os.SOCK.CLOEXEC, <span class="tok-number">0</span>);</span>
<span class="line" id="L3253">    <span class="tok-kw">errdefer</span> os.closeSocket(client);</span>
<span class="line" id="L3254">    _ = <span class="tok-kw">try</span> ring.connect(<span class="tok-number">0xcccccccc</span>, client, &amp;address.any, address.getOsSockLen());</span>
<span class="line" id="L3255"></span>
<span class="line" id="L3256">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">2</span>), <span class="tok-kw">try</span> ring.submit());</span>
<span class="line" id="L3257"></span>
<span class="line" id="L3258">    <span class="tok-kw">var</span> cqe_accept = <span class="tok-kw">try</span> ring.copy_cqe();</span>
<span class="line" id="L3259">    <span class="tok-kw">if</span> (cqe_accept.err() == .INVAL) <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SkipZigTest;</span>
<span class="line" id="L3260">    <span class="tok-kw">var</span> cqe_connect = <span class="tok-kw">try</span> ring.copy_cqe();</span>
<span class="line" id="L3261">    <span class="tok-kw">if</span> (cqe_connect.err() == .INVAL) <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SkipZigTest;</span>
<span class="line" id="L3262"></span>
<span class="line" id="L3263">    <span class="tok-comment">// The accept/connect CQEs may arrive in any order, the connect CQE will sometimes come first:</span>
</span>
<span class="line" id="L3264">    <span class="tok-kw">if</span> (cqe_accept.user_data == <span class="tok-number">0xcccccccc</span> <span class="tok-kw">and</span> cqe_connect.user_data == <span class="tok-number">0xaaaaaaaa</span>) {</span>
<span class="line" id="L3265">        <span class="tok-kw">const</span> a = cqe_accept;</span>
<span class="line" id="L3266">        <span class="tok-kw">const</span> b = cqe_connect;</span>
<span class="line" id="L3267">        cqe_accept = b;</span>
<span class="line" id="L3268">        cqe_connect = a;</span>
<span class="line" id="L3269">    }</span>
<span class="line" id="L3270"></span>
<span class="line" id="L3271">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">u64</span>, <span class="tok-number">0xaaaaaaaa</span>), cqe_accept.user_data);</span>
<span class="line" id="L3272">    <span class="tok-kw">if</span> (cqe_accept.res &lt;= <span class="tok-number">0</span>) std.debug.print(<span class="tok-str">&quot;\ncqe_accept.res={}\n&quot;</span>, .{cqe_accept.res});</span>
<span class="line" id="L3273">    <span class="tok-kw">try</span> testing.expect(cqe_accept.res &gt; <span class="tok-number">0</span>);</span>
<span class="line" id="L3274">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">0</span>), cqe_accept.flags);</span>
<span class="line" id="L3275">    <span class="tok-kw">try</span> testing.expectEqual(linux.io_uring_cqe{</span>
<span class="line" id="L3276">        .user_data = <span class="tok-number">0xcccccccc</span>,</span>
<span class="line" id="L3277">        .res = <span class="tok-number">0</span>,</span>
<span class="line" id="L3278">        .flags = <span class="tok-number">0</span>,</span>
<span class="line" id="L3279">    }, cqe_connect);</span>
<span class="line" id="L3280"></span>
<span class="line" id="L3281">    <span class="tok-comment">// All good</span>
</span>
<span class="line" id="L3282"></span>
<span class="line" id="L3283">    <span class="tok-kw">return</span> SocketTestHarness{</span>
<span class="line" id="L3284">        .listener = listener_socket,</span>
<span class="line" id="L3285">        .server = cqe_accept.res,</span>
<span class="line" id="L3286">        .client = client,</span>
<span class="line" id="L3287">    };</span>
<span class="line" id="L3288">}</span>
<span class="line" id="L3289"></span>
</code></pre></body>
</html>