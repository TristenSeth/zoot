<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">    <title>heap/general_purpose_allocator.zig - source view</title>
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
<pre><code><span class="line" id="L1"><span class="tok-comment">//! # General Purpose Allocator</span></span>
<span class="line" id="L2"><span class="tok-comment">//!</span></span>
<span class="line" id="L3"><span class="tok-comment">//! ## Design Priorities</span></span>
<span class="line" id="L4"><span class="tok-comment">//!</span></span>
<span class="line" id="L5"><span class="tok-comment">//! ### `OptimizationMode.debug` and `OptimizationMode.release_safe`:</span></span>
<span class="line" id="L6"><span class="tok-comment">//!</span></span>
<span class="line" id="L7"><span class="tok-comment">//!  * Detect double free, and emit stack trace of:</span></span>
<span class="line" id="L8"><span class="tok-comment">//!    - Where it was first allocated</span></span>
<span class="line" id="L9"><span class="tok-comment">//!    - Where it was freed the first time</span></span>
<span class="line" id="L10"><span class="tok-comment">//!    - Where it was freed the second time</span></span>
<span class="line" id="L11"><span class="tok-comment">//!</span></span>
<span class="line" id="L12"><span class="tok-comment">//!  * Detect leaks and emit stack trace of:</span></span>
<span class="line" id="L13"><span class="tok-comment">//!    - Where it was allocated</span></span>
<span class="line" id="L14"><span class="tok-comment">//!</span></span>
<span class="line" id="L15"><span class="tok-comment">//!  * When a page of memory is no longer needed, give it back to resident memory</span></span>
<span class="line" id="L16"><span class="tok-comment">//!    as soon as possible, so that it causes page faults when used.</span></span>
<span class="line" id="L17"><span class="tok-comment">//!</span></span>
<span class="line" id="L18"><span class="tok-comment">//!  * Do not re-use memory slots, so that memory safety is upheld. For small</span></span>
<span class="line" id="L19"><span class="tok-comment">//!    allocations, this is handled here; for larger ones it is handled in the</span></span>
<span class="line" id="L20"><span class="tok-comment">//!    backing allocator (by default `std.heap.page_allocator`).</span></span>
<span class="line" id="L21"><span class="tok-comment">//!</span></span>
<span class="line" id="L22"><span class="tok-comment">//!  * Make pointer math errors unlikely to harm memory from</span></span>
<span class="line" id="L23"><span class="tok-comment">//!    unrelated allocations.</span></span>
<span class="line" id="L24"><span class="tok-comment">//!</span></span>
<span class="line" id="L25"><span class="tok-comment">//!  * It's OK for these mechanisms to cost some extra overhead bytes.</span></span>
<span class="line" id="L26"><span class="tok-comment">//!</span></span>
<span class="line" id="L27"><span class="tok-comment">//!  * It's OK for performance cost for these mechanisms.</span></span>
<span class="line" id="L28"><span class="tok-comment">//!</span></span>
<span class="line" id="L29"><span class="tok-comment">//!  * Rogue memory writes should not harm the allocator's state.</span></span>
<span class="line" id="L30"><span class="tok-comment">//!</span></span>
<span class="line" id="L31"><span class="tok-comment">//!  * Cross platform. Operates based on a backing allocator which makes it work</span></span>
<span class="line" id="L32"><span class="tok-comment">//!    everywhere, even freestanding.</span></span>
<span class="line" id="L33"><span class="tok-comment">//!</span></span>
<span class="line" id="L34"><span class="tok-comment">//!  * Compile-time configuration.</span></span>
<span class="line" id="L35"><span class="tok-comment">//!</span></span>
<span class="line" id="L36"><span class="tok-comment">//! ### `OptimizationMode.release_fast` (note: not much work has gone into this use case yet):</span></span>
<span class="line" id="L37"><span class="tok-comment">//!</span></span>
<span class="line" id="L38"><span class="tok-comment">//!  * Low fragmentation is primary concern</span></span>
<span class="line" id="L39"><span class="tok-comment">//!  * Performance of worst-case latency is secondary concern</span></span>
<span class="line" id="L40"><span class="tok-comment">//!  * Performance of average-case latency is next</span></span>
<span class="line" id="L41"><span class="tok-comment">//!  * Finally, having freed memory unmapped, and pointer math errors unlikely to</span></span>
<span class="line" id="L42"><span class="tok-comment">//!    harm memory from unrelated allocations are nice-to-haves.</span></span>
<span class="line" id="L43"><span class="tok-comment">//!</span></span>
<span class="line" id="L44"><span class="tok-comment">//! ### `OptimizationMode.release_small` (note: not much work has gone into this use case yet):</span></span>
<span class="line" id="L45"><span class="tok-comment">//!</span></span>
<span class="line" id="L46"><span class="tok-comment">//!  * Small binary code size of the executable is the primary concern.</span></span>
<span class="line" id="L47"><span class="tok-comment">//!  * Next, defer to the `.release_fast` priority list.</span></span>
<span class="line" id="L48"><span class="tok-comment">//!</span></span>
<span class="line" id="L49"><span class="tok-comment">//! ## Basic Design:</span></span>
<span class="line" id="L50"><span class="tok-comment">//!</span></span>
<span class="line" id="L51"><span class="tok-comment">//! Small allocations are divided into buckets:</span></span>
<span class="line" id="L52"><span class="tok-comment">//!</span></span>
<span class="line" id="L53"><span class="tok-comment">//! ```</span></span>
<span class="line" id="L54"><span class="tok-comment">//! index obj_size</span></span>
<span class="line" id="L55"><span class="tok-comment">//! 0     1</span></span>
<span class="line" id="L56"><span class="tok-comment">//! 1     2</span></span>
<span class="line" id="L57"><span class="tok-comment">//! 2     4</span></span>
<span class="line" id="L58"><span class="tok-comment">//! 3     8</span></span>
<span class="line" id="L59"><span class="tok-comment">//! 4     16</span></span>
<span class="line" id="L60"><span class="tok-comment">//! 5     32</span></span>
<span class="line" id="L61"><span class="tok-comment">//! 6     64</span></span>
<span class="line" id="L62"><span class="tok-comment">//! 7     128</span></span>
<span class="line" id="L63"><span class="tok-comment">//! 8     256</span></span>
<span class="line" id="L64"><span class="tok-comment">//! 9     512</span></span>
<span class="line" id="L65"><span class="tok-comment">//! 10    1024</span></span>
<span class="line" id="L66"><span class="tok-comment">//! 11    2048</span></span>
<span class="line" id="L67"><span class="tok-comment">//! ```</span></span>
<span class="line" id="L68"><span class="tok-comment">//!</span></span>
<span class="line" id="L69"><span class="tok-comment">//! The main allocator state has an array of all the &quot;current&quot; buckets for each</span></span>
<span class="line" id="L70"><span class="tok-comment">//! size class. Each slot in the array can be null, meaning the bucket for that</span></span>
<span class="line" id="L71"><span class="tok-comment">//! size class is not allocated. When the first object is allocated for a given</span></span>
<span class="line" id="L72"><span class="tok-comment">//! size class, it allocates 1 page of memory from the OS. This page is</span></span>
<span class="line" id="L73"><span class="tok-comment">//! divided into &quot;slots&quot; - one per allocated object. Along with the page of memory</span></span>
<span class="line" id="L74"><span class="tok-comment">//! for object slots, as many pages as necessary are allocated to store the</span></span>
<span class="line" id="L75"><span class="tok-comment">//! BucketHeader, followed by &quot;used bits&quot;, and two stack traces for each slot</span></span>
<span class="line" id="L76"><span class="tok-comment">//! (allocation trace and free trace).</span></span>
<span class="line" id="L77"><span class="tok-comment">//!</span></span>
<span class="line" id="L78"><span class="tok-comment">//! The &quot;used bits&quot; are 1 bit per slot representing whether the slot is used.</span></span>
<span class="line" id="L79"><span class="tok-comment">//! Allocations use the data to iterate to find a free slot. Frees assert that the</span></span>
<span class="line" id="L80"><span class="tok-comment">//! corresponding bit is 1 and set it to 0.</span></span>
<span class="line" id="L81"><span class="tok-comment">//!</span></span>
<span class="line" id="L82"><span class="tok-comment">//! Buckets have prev and next pointers. When there is only one bucket for a given</span></span>
<span class="line" id="L83"><span class="tok-comment">//! size class, both prev and next point to itself. When all slots of a bucket are</span></span>
<span class="line" id="L84"><span class="tok-comment">//! used, a new bucket is allocated, and enters the doubly linked list. The main</span></span>
<span class="line" id="L85"><span class="tok-comment">//! allocator state tracks the &quot;current&quot; bucket for each size class. Leak detection</span></span>
<span class="line" id="L86"><span class="tok-comment">//! currently only checks the current bucket.</span></span>
<span class="line" id="L87"><span class="tok-comment">//!</span></span>
<span class="line" id="L88"><span class="tok-comment">//! Resizing detects if the size class is unchanged or smaller, in which case the same</span></span>
<span class="line" id="L89"><span class="tok-comment">//! pointer is returned unmodified. If a larger size class is required,</span></span>
<span class="line" id="L90"><span class="tok-comment">//! `error.OutOfMemory` is returned.</span></span>
<span class="line" id="L91"><span class="tok-comment">//!</span></span>
<span class="line" id="L92"><span class="tok-comment">//! Large objects are allocated directly using the backing allocator and their metadata is stored</span></span>
<span class="line" id="L93"><span class="tok-comment">//! in a `std.HashMap` using the backing allocator.</span></span>
<span class="line" id="L94"></span>
<span class="line" id="L95"><span class="tok-kw">const</span> std = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;std&quot;</span>);</span>
<span class="line" id="L96"><span class="tok-kw">const</span> builtin = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;builtin&quot;</span>);</span>
<span class="line" id="L97"><span class="tok-kw">const</span> log = std.log.scoped(.gpa);</span>
<span class="line" id="L98"><span class="tok-kw">const</span> math = std.math;</span>
<span class="line" id="L99"><span class="tok-kw">const</span> assert = std.debug.assert;</span>
<span class="line" id="L100"><span class="tok-kw">const</span> mem = std.mem;</span>
<span class="line" id="L101"><span class="tok-kw">const</span> Allocator = std.mem.Allocator;</span>
<span class="line" id="L102"><span class="tok-kw">const</span> page_size = std.mem.page_size;</span>
<span class="line" id="L103"><span class="tok-kw">const</span> StackTrace = std.builtin.StackTrace;</span>
<span class="line" id="L104"></span>
<span class="line" id="L105"><span class="tok-comment">/// Integer type for pointing to slots in a small allocation</span></span>
<span class="line" id="L106"><span class="tok-kw">const</span> SlotIndex = std.meta.Int(.unsigned, math.log2(page_size) + <span class="tok-number">1</span>);</span>
<span class="line" id="L107"></span>
<span class="line" id="L108"><span class="tok-kw">const</span> default_test_stack_trace_frames: <span class="tok-type">usize</span> = <span class="tok-kw">if</span> (builtin.is_test) <span class="tok-number">8</span> <span class="tok-kw">else</span> <span class="tok-number">4</span>;</span>
<span class="line" id="L109"><span class="tok-kw">const</span> default_sys_stack_trace_frames: <span class="tok-type">usize</span> = <span class="tok-kw">if</span> (std.debug.sys_can_stack_trace) default_test_stack_trace_frames <span class="tok-kw">else</span> <span class="tok-number">0</span>;</span>
<span class="line" id="L110"><span class="tok-kw">const</span> default_stack_trace_frames: <span class="tok-type">usize</span> = <span class="tok-kw">switch</span> (builtin.mode) {</span>
<span class="line" id="L111">    .Debug =&gt; default_sys_stack_trace_frames,</span>
<span class="line" id="L112">    <span class="tok-kw">else</span> =&gt; <span class="tok-number">0</span>,</span>
<span class="line" id="L113">};</span>
<span class="line" id="L114"></span>
<span class="line" id="L115"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> Config = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L116">    <span class="tok-comment">/// Number of stack frames to capture.</span></span>
<span class="line" id="L117">    stack_trace_frames: <span class="tok-type">usize</span> = default_stack_trace_frames,</span>
<span class="line" id="L118"></span>
<span class="line" id="L119">    <span class="tok-comment">/// If true, the allocator will have two fields:</span></span>
<span class="line" id="L120">    <span class="tok-comment">///  * `total_requested_bytes` which tracks the total allocated bytes of memory requested.</span></span>
<span class="line" id="L121">    <span class="tok-comment">///  * `requested_memory_limit` which causes allocations to return `error.OutOfMemory`</span></span>
<span class="line" id="L122">    <span class="tok-comment">///    when the `total_requested_bytes` exceeds this limit.</span></span>
<span class="line" id="L123">    <span class="tok-comment">/// If false, these fields will be `void`.</span></span>
<span class="line" id="L124">    enable_memory_limit: <span class="tok-type">bool</span> = <span class="tok-null">false</span>,</span>
<span class="line" id="L125"></span>
<span class="line" id="L126">    <span class="tok-comment">/// Whether to enable safety checks.</span></span>
<span class="line" id="L127">    safety: <span class="tok-type">bool</span> = std.debug.runtime_safety,</span>
<span class="line" id="L128"></span>
<span class="line" id="L129">    <span class="tok-comment">/// Whether the allocator may be used simultaneously from multiple threads.</span></span>
<span class="line" id="L130">    thread_safe: <span class="tok-type">bool</span> = !builtin.single_threaded,</span>
<span class="line" id="L131"></span>
<span class="line" id="L132">    <span class="tok-comment">/// What type of mutex you'd like to use, for thread safety.</span></span>
<span class="line" id="L133">    <span class="tok-comment">/// when specfied, the mutex type must have the same shape as `std.Thread.Mutex` and</span></span>
<span class="line" id="L134">    <span class="tok-comment">/// `DummyMutex`, and have no required fields. Specifying this field causes</span></span>
<span class="line" id="L135">    <span class="tok-comment">/// the `thread_safe` field to be ignored.</span></span>
<span class="line" id="L136">    <span class="tok-comment">///</span></span>
<span class="line" id="L137">    <span class="tok-comment">/// when null (default):</span></span>
<span class="line" id="L138">    <span class="tok-comment">/// * the mutex type defaults to `std.Thread.Mutex` when thread_safe is enabled.</span></span>
<span class="line" id="L139">    <span class="tok-comment">/// * the mutex type defaults to `DummyMutex` otherwise.</span></span>
<span class="line" id="L140">    MutexType: ?<span class="tok-type">type</span> = <span class="tok-null">null</span>,</span>
<span class="line" id="L141"></span>
<span class="line" id="L142">    <span class="tok-comment">/// This is a temporary debugging trick you can use to turn segfaults into more helpful</span></span>
<span class="line" id="L143">    <span class="tok-comment">/// logged error messages with stack trace details. The downside is that every allocation</span></span>
<span class="line" id="L144">    <span class="tok-comment">/// will be leaked, unless used with retain_metadata!</span></span>
<span class="line" id="L145">    never_unmap: <span class="tok-type">bool</span> = <span class="tok-null">false</span>,</span>
<span class="line" id="L146"></span>
<span class="line" id="L147">    <span class="tok-comment">/// This is a temporary debugging aid that retains metadata about allocations indefinitely.</span></span>
<span class="line" id="L148">    <span class="tok-comment">/// This allows a greater range of double frees to be reported. All metadata is freed when</span></span>
<span class="line" id="L149">    <span class="tok-comment">/// deinit is called. When used with never_unmap, deliberately leaked memory is also freed</span></span>
<span class="line" id="L150">    <span class="tok-comment">/// during deinit. Currently should be used with never_unmap to avoid segfaults.</span></span>
<span class="line" id="L151">    <span class="tok-comment">/// TODO https://github.com/ziglang/zig/issues/4298 will allow use without never_unmap</span></span>
<span class="line" id="L152">    retain_metadata: <span class="tok-type">bool</span> = <span class="tok-null">false</span>,</span>
<span class="line" id="L153"></span>
<span class="line" id="L154">    <span class="tok-comment">/// Enables emitting info messages with the size and address of every allocation.</span></span>
<span class="line" id="L155">    verbose_log: <span class="tok-type">bool</span> = <span class="tok-null">false</span>,</span>
<span class="line" id="L156">};</span>
<span class="line" id="L157"></span>
<span class="line" id="L158"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">GeneralPurposeAllocator</span>(<span class="tok-kw">comptime</span> config: Config) <span class="tok-type">type</span> {</span>
<span class="line" id="L159">    <span class="tok-kw">return</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L160">        backing_allocator: Allocator = std.heap.page_allocator,</span>
<span class="line" id="L161">        buckets: [small_bucket_count]?*BucketHeader = [<span class="tok-number">1</span>]?*BucketHeader{<span class="tok-null">null</span>} ** small_bucket_count,</span>
<span class="line" id="L162">        large_allocations: LargeAllocTable = .{},</span>
<span class="line" id="L163">        empty_buckets: <span class="tok-kw">if</span> (config.retain_metadata) ?*BucketHeader <span class="tok-kw">else</span> <span class="tok-type">void</span> =</span>
<span class="line" id="L164">            <span class="tok-kw">if</span> (config.retain_metadata) <span class="tok-null">null</span> <span class="tok-kw">else</span> {},</span>
<span class="line" id="L165"></span>
<span class="line" id="L166">        total_requested_bytes: <span class="tok-builtin">@TypeOf</span>(total_requested_bytes_init) = total_requested_bytes_init,</span>
<span class="line" id="L167">        requested_memory_limit: <span class="tok-builtin">@TypeOf</span>(requested_memory_limit_init) = requested_memory_limit_init,</span>
<span class="line" id="L168"></span>
<span class="line" id="L169">        mutex: <span class="tok-builtin">@TypeOf</span>(mutex_init) = mutex_init,</span>
<span class="line" id="L170"></span>
<span class="line" id="L171">        <span class="tok-kw">const</span> Self = <span class="tok-builtin">@This</span>();</span>
<span class="line" id="L172"></span>
<span class="line" id="L173">        <span class="tok-kw">const</span> total_requested_bytes_init = <span class="tok-kw">if</span> (config.enable_memory_limit) <span class="tok-builtin">@as</span>(<span class="tok-type">usize</span>, <span class="tok-number">0</span>) <span class="tok-kw">else</span> {};</span>
<span class="line" id="L174">        <span class="tok-kw">const</span> requested_memory_limit_init = <span class="tok-kw">if</span> (config.enable_memory_limit) <span class="tok-builtin">@as</span>(<span class="tok-type">usize</span>, math.maxInt(<span class="tok-type">usize</span>)) <span class="tok-kw">else</span> {};</span>
<span class="line" id="L175"></span>
<span class="line" id="L176">        <span class="tok-kw">const</span> mutex_init = <span class="tok-kw">if</span> (config.MutexType) |T|</span>
<span class="line" id="L177">            T{}</span>
<span class="line" id="L178">        <span class="tok-kw">else</span> <span class="tok-kw">if</span> (config.thread_safe)</span>
<span class="line" id="L179">            std.Thread.Mutex{}</span>
<span class="line" id="L180">        <span class="tok-kw">else</span></span>
<span class="line" id="L181">            DummyMutex{};</span>
<span class="line" id="L182"></span>
<span class="line" id="L183">        <span class="tok-kw">const</span> DummyMutex = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L184">            <span class="tok-kw">fn</span> <span class="tok-fn">lock</span>(_: *DummyMutex) <span class="tok-type">void</span> {}</span>
<span class="line" id="L185">            <span class="tok-kw">fn</span> <span class="tok-fn">unlock</span>(_: *DummyMutex) <span class="tok-type">void</span> {}</span>
<span class="line" id="L186">        };</span>
<span class="line" id="L187"></span>
<span class="line" id="L188">        <span class="tok-kw">const</span> stack_n = config.stack_trace_frames;</span>
<span class="line" id="L189">        <span class="tok-kw">const</span> one_trace_size = <span class="tok-builtin">@sizeOf</span>(<span class="tok-type">usize</span>) * stack_n;</span>
<span class="line" id="L190">        <span class="tok-kw">const</span> traces_per_slot = <span class="tok-number">2</span>;</span>
<span class="line" id="L191"></span>
<span class="line" id="L192">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> Error = mem.Allocator.Error;</span>
<span class="line" id="L193"></span>
<span class="line" id="L194">        <span class="tok-kw">const</span> small_bucket_count = math.log2(page_size);</span>
<span class="line" id="L195">        <span class="tok-kw">const</span> largest_bucket_object_size = <span class="tok-number">1</span> &lt;&lt; (small_bucket_count - <span class="tok-number">1</span>);</span>
<span class="line" id="L196"></span>
<span class="line" id="L197">        <span class="tok-kw">const</span> LargeAlloc = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L198">            bytes: []<span class="tok-type">u8</span>,</span>
<span class="line" id="L199">            requested_size: <span class="tok-kw">if</span> (config.enable_memory_limit) <span class="tok-type">usize</span> <span class="tok-kw">else</span> <span class="tok-type">void</span>,</span>
<span class="line" id="L200">            stack_addresses: [trace_n][stack_n]<span class="tok-type">usize</span>,</span>
<span class="line" id="L201">            freed: <span class="tok-kw">if</span> (config.retain_metadata) <span class="tok-type">bool</span> <span class="tok-kw">else</span> <span class="tok-type">void</span>,</span>
<span class="line" id="L202">            ptr_align: <span class="tok-kw">if</span> (config.never_unmap <span class="tok-kw">and</span> config.retain_metadata) <span class="tok-type">u29</span> <span class="tok-kw">else</span> <span class="tok-type">void</span>,</span>
<span class="line" id="L203"></span>
<span class="line" id="L204">            <span class="tok-kw">const</span> trace_n = <span class="tok-kw">if</span> (config.retain_metadata) traces_per_slot <span class="tok-kw">else</span> <span class="tok-number">1</span>;</span>
<span class="line" id="L205"></span>
<span class="line" id="L206">            <span class="tok-kw">fn</span> <span class="tok-fn">dumpStackTrace</span>(self: *LargeAlloc, trace_kind: TraceKind) <span class="tok-type">void</span> {</span>
<span class="line" id="L207">                std.debug.dumpStackTrace(self.getStackTrace(trace_kind));</span>
<span class="line" id="L208">            }</span>
<span class="line" id="L209"></span>
<span class="line" id="L210">            <span class="tok-kw">fn</span> <span class="tok-fn">getStackTrace</span>(self: *LargeAlloc, trace_kind: TraceKind) std.builtin.StackTrace {</span>
<span class="line" id="L211">                assert(<span class="tok-builtin">@enumToInt</span>(trace_kind) &lt; trace_n);</span>
<span class="line" id="L212">                <span class="tok-kw">const</span> stack_addresses = &amp;self.stack_addresses[<span class="tok-builtin">@enumToInt</span>(trace_kind)];</span>
<span class="line" id="L213">                <span class="tok-kw">var</span> len: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L214">                <span class="tok-kw">while</span> (len &lt; stack_n <span class="tok-kw">and</span> stack_addresses[len] != <span class="tok-number">0</span>) {</span>
<span class="line" id="L215">                    len += <span class="tok-number">1</span>;</span>
<span class="line" id="L216">                }</span>
<span class="line" id="L217">                <span class="tok-kw">return</span> .{</span>
<span class="line" id="L218">                    .instruction_addresses = stack_addresses,</span>
<span class="line" id="L219">                    .index = len,</span>
<span class="line" id="L220">                };</span>
<span class="line" id="L221">            }</span>
<span class="line" id="L222"></span>
<span class="line" id="L223">            <span class="tok-kw">fn</span> <span class="tok-fn">captureStackTrace</span>(self: *LargeAlloc, ret_addr: <span class="tok-type">usize</span>, trace_kind: TraceKind) <span class="tok-type">void</span> {</span>
<span class="line" id="L224">                assert(<span class="tok-builtin">@enumToInt</span>(trace_kind) &lt; trace_n);</span>
<span class="line" id="L225">                <span class="tok-kw">const</span> stack_addresses = &amp;self.stack_addresses[<span class="tok-builtin">@enumToInt</span>(trace_kind)];</span>
<span class="line" id="L226">                collectStackTrace(ret_addr, stack_addresses);</span>
<span class="line" id="L227">            }</span>
<span class="line" id="L228">        };</span>
<span class="line" id="L229">        <span class="tok-kw">const</span> LargeAllocTable = std.AutoHashMapUnmanaged(<span class="tok-type">usize</span>, LargeAlloc);</span>
<span class="line" id="L230"></span>
<span class="line" id="L231">        <span class="tok-comment">// Bucket: In memory, in order:</span>
</span>
<span class="line" id="L232">        <span class="tok-comment">// * BucketHeader</span>
</span>
<span class="line" id="L233">        <span class="tok-comment">// * bucket_used_bits: [N]u8, // 1 bit for every slot; 1 byte for every 8 slots</span>
</span>
<span class="line" id="L234">        <span class="tok-comment">// * stack_trace_addresses: [N]usize, // traces_per_slot for every allocation</span>
</span>
<span class="line" id="L235"></span>
<span class="line" id="L236">        <span class="tok-kw">const</span> BucketHeader = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L237">            prev: *BucketHeader,</span>
<span class="line" id="L238">            next: *BucketHeader,</span>
<span class="line" id="L239">            page: [*]<span class="tok-kw">align</span>(page_size) <span class="tok-type">u8</span>,</span>
<span class="line" id="L240">            alloc_cursor: SlotIndex,</span>
<span class="line" id="L241">            used_count: SlotIndex,</span>
<span class="line" id="L242"></span>
<span class="line" id="L243">            <span class="tok-kw">fn</span> <span class="tok-fn">usedBits</span>(bucket: *BucketHeader, index: <span class="tok-type">usize</span>) *<span class="tok-type">u8</span> {</span>
<span class="line" id="L244">                <span class="tok-kw">return</span> <span class="tok-builtin">@intToPtr</span>(*<span class="tok-type">u8</span>, <span class="tok-builtin">@ptrToInt</span>(bucket) + <span class="tok-builtin">@sizeOf</span>(BucketHeader) + index);</span>
<span class="line" id="L245">            }</span>
<span class="line" id="L246"></span>
<span class="line" id="L247">            <span class="tok-kw">fn</span> <span class="tok-fn">stackTracePtr</span>(</span>
<span class="line" id="L248">                bucket: *BucketHeader,</span>
<span class="line" id="L249">                size_class: <span class="tok-type">usize</span>,</span>
<span class="line" id="L250">                slot_index: SlotIndex,</span>
<span class="line" id="L251">                trace_kind: TraceKind,</span>
<span class="line" id="L252">            ) *[stack_n]<span class="tok-type">usize</span> {</span>
<span class="line" id="L253">                <span class="tok-kw">const</span> start_ptr = <span class="tok-builtin">@ptrCast</span>([*]<span class="tok-type">u8</span>, bucket) + bucketStackFramesStart(size_class);</span>
<span class="line" id="L254">                <span class="tok-kw">const</span> addr = start_ptr + one_trace_size * traces_per_slot * slot_index +</span>
<span class="line" id="L255">                    <span class="tok-builtin">@enumToInt</span>(trace_kind) * <span class="tok-builtin">@as</span>(<span class="tok-type">usize</span>, one_trace_size);</span>
<span class="line" id="L256">                <span class="tok-kw">return</span> <span class="tok-builtin">@ptrCast</span>(*[stack_n]<span class="tok-type">usize</span>, <span class="tok-builtin">@alignCast</span>(<span class="tok-builtin">@alignOf</span>(<span class="tok-type">usize</span>), addr));</span>
<span class="line" id="L257">            }</span>
<span class="line" id="L258"></span>
<span class="line" id="L259">            <span class="tok-kw">fn</span> <span class="tok-fn">captureStackTrace</span>(</span>
<span class="line" id="L260">                bucket: *BucketHeader,</span>
<span class="line" id="L261">                ret_addr: <span class="tok-type">usize</span>,</span>
<span class="line" id="L262">                size_class: <span class="tok-type">usize</span>,</span>
<span class="line" id="L263">                slot_index: SlotIndex,</span>
<span class="line" id="L264">                trace_kind: TraceKind,</span>
<span class="line" id="L265">            ) <span class="tok-type">void</span> {</span>
<span class="line" id="L266">                <span class="tok-comment">// Initialize them to 0. When determining the count we must look</span>
</span>
<span class="line" id="L267">                <span class="tok-comment">// for non zero addresses.</span>
</span>
<span class="line" id="L268">                <span class="tok-kw">const</span> stack_addresses = bucket.stackTracePtr(size_class, slot_index, trace_kind);</span>
<span class="line" id="L269">                collectStackTrace(ret_addr, stack_addresses);</span>
<span class="line" id="L270">            }</span>
<span class="line" id="L271">        };</span>
<span class="line" id="L272"></span>
<span class="line" id="L273">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">allocator</span>(self: *Self) Allocator {</span>
<span class="line" id="L274">            <span class="tok-kw">return</span> Allocator.init(self, alloc, resize, free);</span>
<span class="line" id="L275">        }</span>
<span class="line" id="L276"></span>
<span class="line" id="L277">        <span class="tok-kw">fn</span> <span class="tok-fn">bucketStackTrace</span>(</span>
<span class="line" id="L278">            bucket: *BucketHeader,</span>
<span class="line" id="L279">            size_class: <span class="tok-type">usize</span>,</span>
<span class="line" id="L280">            slot_index: SlotIndex,</span>
<span class="line" id="L281">            trace_kind: TraceKind,</span>
<span class="line" id="L282">        ) StackTrace {</span>
<span class="line" id="L283">            <span class="tok-kw">const</span> stack_addresses = bucket.stackTracePtr(size_class, slot_index, trace_kind);</span>
<span class="line" id="L284">            <span class="tok-kw">var</span> len: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L285">            <span class="tok-kw">while</span> (len &lt; stack_n <span class="tok-kw">and</span> stack_addresses[len] != <span class="tok-number">0</span>) {</span>
<span class="line" id="L286">                len += <span class="tok-number">1</span>;</span>
<span class="line" id="L287">            }</span>
<span class="line" id="L288">            <span class="tok-kw">return</span> StackTrace{</span>
<span class="line" id="L289">                .instruction_addresses = stack_addresses,</span>
<span class="line" id="L290">                .index = len,</span>
<span class="line" id="L291">            };</span>
<span class="line" id="L292">        }</span>
<span class="line" id="L293"></span>
<span class="line" id="L294">        <span class="tok-kw">fn</span> <span class="tok-fn">bucketStackFramesStart</span>(size_class: <span class="tok-type">usize</span>) <span class="tok-type">usize</span> {</span>
<span class="line" id="L295">            <span class="tok-kw">return</span> mem.alignForward(</span>
<span class="line" id="L296">                <span class="tok-builtin">@sizeOf</span>(BucketHeader) + usedBitsCount(size_class),</span>
<span class="line" id="L297">                <span class="tok-builtin">@alignOf</span>(<span class="tok-type">usize</span>),</span>
<span class="line" id="L298">            );</span>
<span class="line" id="L299">        }</span>
<span class="line" id="L300"></span>
<span class="line" id="L301">        <span class="tok-kw">fn</span> <span class="tok-fn">bucketSize</span>(size_class: <span class="tok-type">usize</span>) <span class="tok-type">usize</span> {</span>
<span class="line" id="L302">            <span class="tok-kw">const</span> slot_count = <span class="tok-builtin">@divExact</span>(page_size, size_class);</span>
<span class="line" id="L303">            <span class="tok-kw">return</span> bucketStackFramesStart(size_class) + one_trace_size * traces_per_slot * slot_count;</span>
<span class="line" id="L304">        }</span>
<span class="line" id="L305"></span>
<span class="line" id="L306">        <span class="tok-kw">fn</span> <span class="tok-fn">usedBitsCount</span>(size_class: <span class="tok-type">usize</span>) <span class="tok-type">usize</span> {</span>
<span class="line" id="L307">            <span class="tok-kw">const</span> slot_count = <span class="tok-builtin">@divExact</span>(page_size, size_class);</span>
<span class="line" id="L308">            <span class="tok-kw">if</span> (slot_count &lt; <span class="tok-number">8</span>) <span class="tok-kw">return</span> <span class="tok-number">1</span>;</span>
<span class="line" id="L309">            <span class="tok-kw">return</span> <span class="tok-builtin">@divExact</span>(slot_count, <span class="tok-number">8</span>);</span>
<span class="line" id="L310">        }</span>
<span class="line" id="L311"></span>
<span class="line" id="L312">        <span class="tok-kw">fn</span> <span class="tok-fn">detectLeaksInBucket</span>(</span>
<span class="line" id="L313">            bucket: *BucketHeader,</span>
<span class="line" id="L314">            size_class: <span class="tok-type">usize</span>,</span>
<span class="line" id="L315">            used_bits_count: <span class="tok-type">usize</span>,</span>
<span class="line" id="L316">        ) <span class="tok-type">bool</span> {</span>
<span class="line" id="L317">            <span class="tok-kw">var</span> leaks = <span class="tok-null">false</span>;</span>
<span class="line" id="L318">            <span class="tok-kw">var</span> used_bits_byte: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L319">            <span class="tok-kw">while</span> (used_bits_byte &lt; used_bits_count) : (used_bits_byte += <span class="tok-number">1</span>) {</span>
<span class="line" id="L320">                <span class="tok-kw">const</span> used_byte = bucket.usedBits(used_bits_byte).*;</span>
<span class="line" id="L321">                <span class="tok-kw">if</span> (used_byte != <span class="tok-number">0</span>) {</span>
<span class="line" id="L322">                    <span class="tok-kw">var</span> bit_index: <span class="tok-type">u3</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L323">                    <span class="tok-kw">while</span> (<span class="tok-null">true</span>) : (bit_index += <span class="tok-number">1</span>) {</span>
<span class="line" id="L324">                        <span class="tok-kw">const</span> is_used = <span class="tok-builtin">@truncate</span>(<span class="tok-type">u1</span>, used_byte &gt;&gt; bit_index) != <span class="tok-number">0</span>;</span>
<span class="line" id="L325">                        <span class="tok-kw">if</span> (is_used) {</span>
<span class="line" id="L326">                            <span class="tok-kw">const</span> slot_index = <span class="tok-builtin">@intCast</span>(SlotIndex, used_bits_byte * <span class="tok-number">8</span> + bit_index);</span>
<span class="line" id="L327">                            <span class="tok-kw">const</span> stack_trace = bucketStackTrace(bucket, size_class, slot_index, .alloc);</span>
<span class="line" id="L328">                            <span class="tok-kw">const</span> addr = bucket.page + slot_index * size_class;</span>
<span class="line" id="L329">                            log.err(<span class="tok-str">&quot;memory address 0x{x} leaked: {s}&quot;</span>, .{</span>
<span class="line" id="L330">                                <span class="tok-builtin">@ptrToInt</span>(addr), stack_trace,</span>
<span class="line" id="L331">                            });</span>
<span class="line" id="L332">                            leaks = <span class="tok-null">true</span>;</span>
<span class="line" id="L333">                        }</span>
<span class="line" id="L334">                        <span class="tok-kw">if</span> (bit_index == math.maxInt(<span class="tok-type">u3</span>))</span>
<span class="line" id="L335">                            <span class="tok-kw">break</span>;</span>
<span class="line" id="L336">                    }</span>
<span class="line" id="L337">                }</span>
<span class="line" id="L338">            }</span>
<span class="line" id="L339">            <span class="tok-kw">return</span> leaks;</span>
<span class="line" id="L340">        }</span>
<span class="line" id="L341"></span>
<span class="line" id="L342">        <span class="tok-comment">/// Emits log messages for leaks and then returns whether there were any leaks.</span></span>
<span class="line" id="L343">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">detectLeaks</span>(self: *Self) <span class="tok-type">bool</span> {</span>
<span class="line" id="L344">            <span class="tok-kw">var</span> leaks = <span class="tok-null">false</span>;</span>
<span class="line" id="L345">            <span class="tok-kw">for</span> (self.buckets) |optional_bucket, bucket_i| {</span>
<span class="line" id="L346">                <span class="tok-kw">const</span> first_bucket = optional_bucket <span class="tok-kw">orelse</span> <span class="tok-kw">continue</span>;</span>
<span class="line" id="L347">                <span class="tok-kw">const</span> size_class = <span class="tok-builtin">@as</span>(<span class="tok-type">usize</span>, <span class="tok-number">1</span>) &lt;&lt; <span class="tok-builtin">@intCast</span>(math.Log2Int(<span class="tok-type">usize</span>), bucket_i);</span>
<span class="line" id="L348">                <span class="tok-kw">const</span> used_bits_count = usedBitsCount(size_class);</span>
<span class="line" id="L349">                <span class="tok-kw">var</span> bucket = first_bucket;</span>
<span class="line" id="L350">                <span class="tok-kw">while</span> (<span class="tok-null">true</span>) {</span>
<span class="line" id="L351">                    leaks = detectLeaksInBucket(bucket, size_class, used_bits_count) <span class="tok-kw">or</span> leaks;</span>
<span class="line" id="L352">                    bucket = bucket.next;</span>
<span class="line" id="L353">                    <span class="tok-kw">if</span> (bucket == first_bucket)</span>
<span class="line" id="L354">                        <span class="tok-kw">break</span>;</span>
<span class="line" id="L355">                }</span>
<span class="line" id="L356">            }</span>
<span class="line" id="L357">            <span class="tok-kw">var</span> it = self.large_allocations.valueIterator();</span>
<span class="line" id="L358">            <span class="tok-kw">while</span> (it.next()) |large_alloc| {</span>
<span class="line" id="L359">                <span class="tok-kw">if</span> (config.retain_metadata <span class="tok-kw">and</span> large_alloc.freed) <span class="tok-kw">continue</span>;</span>
<span class="line" id="L360">                <span class="tok-kw">const</span> stack_trace = large_alloc.getStackTrace(.alloc);</span>
<span class="line" id="L361">                log.err(<span class="tok-str">&quot;memory address 0x{x} leaked: {s}&quot;</span>, .{</span>
<span class="line" id="L362">                    <span class="tok-builtin">@ptrToInt</span>(large_alloc.bytes.ptr), stack_trace,</span>
<span class="line" id="L363">                });</span>
<span class="line" id="L364">                leaks = <span class="tok-null">true</span>;</span>
<span class="line" id="L365">            }</span>
<span class="line" id="L366">            <span class="tok-kw">return</span> leaks;</span>
<span class="line" id="L367">        }</span>
<span class="line" id="L368"></span>
<span class="line" id="L369">        <span class="tok-kw">fn</span> <span class="tok-fn">freeBucket</span>(self: *Self, bucket: *BucketHeader, size_class: <span class="tok-type">usize</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L370">            <span class="tok-kw">const</span> bucket_size = bucketSize(size_class);</span>
<span class="line" id="L371">            <span class="tok-kw">const</span> bucket_slice = <span class="tok-builtin">@ptrCast</span>([*]<span class="tok-kw">align</span>(<span class="tok-builtin">@alignOf</span>(BucketHeader)) <span class="tok-type">u8</span>, bucket)[<span class="tok-number">0</span>..bucket_size];</span>
<span class="line" id="L372">            self.backing_allocator.free(bucket_slice);</span>
<span class="line" id="L373">        }</span>
<span class="line" id="L374"></span>
<span class="line" id="L375">        <span class="tok-kw">fn</span> <span class="tok-fn">freeRetainedMetadata</span>(self: *Self) <span class="tok-type">void</span> {</span>
<span class="line" id="L376">            <span class="tok-kw">if</span> (config.retain_metadata) {</span>
<span class="line" id="L377">                <span class="tok-kw">if</span> (config.never_unmap) {</span>
<span class="line" id="L378">                    <span class="tok-comment">// free large allocations that were intentionally leaked by never_unmap</span>
</span>
<span class="line" id="L379">                    <span class="tok-kw">var</span> it = self.large_allocations.iterator();</span>
<span class="line" id="L380">                    <span class="tok-kw">while</span> (it.next()) |large| {</span>
<span class="line" id="L381">                        <span class="tok-kw">if</span> (large.value_ptr.freed) {</span>
<span class="line" id="L382">                            self.backing_allocator.rawFree(large.value_ptr.bytes, large.value_ptr.ptr_align, <span class="tok-builtin">@returnAddress</span>());</span>
<span class="line" id="L383">                        }</span>
<span class="line" id="L384">                    }</span>
<span class="line" id="L385">                }</span>
<span class="line" id="L386">                <span class="tok-comment">// free retained metadata for small allocations</span>
</span>
<span class="line" id="L387">                <span class="tok-kw">if</span> (self.empty_buckets) |first_bucket| {</span>
<span class="line" id="L388">                    <span class="tok-kw">var</span> bucket = first_bucket;</span>
<span class="line" id="L389">                    <span class="tok-kw">while</span> (<span class="tok-null">true</span>) {</span>
<span class="line" id="L390">                        <span class="tok-kw">const</span> prev = bucket.prev;</span>
<span class="line" id="L391">                        <span class="tok-kw">if</span> (config.never_unmap) {</span>
<span class="line" id="L392">                            <span class="tok-comment">// free page that was intentionally leaked by never_unmap</span>
</span>
<span class="line" id="L393">                            self.backing_allocator.free(bucket.page[<span class="tok-number">0</span>..page_size]);</span>
<span class="line" id="L394">                        }</span>
<span class="line" id="L395">                        <span class="tok-comment">// alloc_cursor was set to slot count when bucket added to empty_buckets</span>
</span>
<span class="line" id="L396">                        self.freeBucket(bucket, <span class="tok-builtin">@divExact</span>(page_size, bucket.alloc_cursor));</span>
<span class="line" id="L397">                        bucket = prev;</span>
<span class="line" id="L398">                        <span class="tok-kw">if</span> (bucket == first_bucket)</span>
<span class="line" id="L399">                            <span class="tok-kw">break</span>;</span>
<span class="line" id="L400">                    }</span>
<span class="line" id="L401">                    self.empty_buckets = <span class="tok-null">null</span>;</span>
<span class="line" id="L402">                }</span>
<span class="line" id="L403">            }</span>
<span class="line" id="L404">        }</span>
<span class="line" id="L405"></span>
<span class="line" id="L406">        <span class="tok-kw">pub</span> <span class="tok-kw">usingnamespace</span> <span class="tok-kw">if</span> (config.retain_metadata) <span class="tok-kw">struct</span> {</span>
<span class="line" id="L407">            <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">flushRetainedMetadata</span>(self: *Self) <span class="tok-type">void</span> {</span>
<span class="line" id="L408">                self.freeRetainedMetadata();</span>
<span class="line" id="L409">                <span class="tok-comment">// also remove entries from large_allocations</span>
</span>
<span class="line" id="L410">                <span class="tok-kw">var</span> it = self.large_allocations.iterator();</span>
<span class="line" id="L411">                <span class="tok-kw">while</span> (it.next()) |large| {</span>
<span class="line" id="L412">                    <span class="tok-kw">if</span> (large.value_ptr.freed) {</span>
<span class="line" id="L413">                        _ = self.large_allocations.remove(<span class="tok-builtin">@ptrToInt</span>(large.value_ptr.bytes.ptr));</span>
<span class="line" id="L414">                    }</span>
<span class="line" id="L415">                }</span>
<span class="line" id="L416">            }</span>
<span class="line" id="L417">        } <span class="tok-kw">else</span> <span class="tok-kw">struct</span> {};</span>
<span class="line" id="L418"></span>
<span class="line" id="L419">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">deinit</span>(self: *Self) <span class="tok-type">bool</span> {</span>
<span class="line" id="L420">            <span class="tok-kw">const</span> leaks = <span class="tok-kw">if</span> (config.safety) self.detectLeaks() <span class="tok-kw">else</span> <span class="tok-null">false</span>;</span>
<span class="line" id="L421">            <span class="tok-kw">if</span> (config.retain_metadata) {</span>
<span class="line" id="L422">                self.freeRetainedMetadata();</span>
<span class="line" id="L423">            }</span>
<span class="line" id="L424">            self.large_allocations.deinit(self.backing_allocator);</span>
<span class="line" id="L425">            self.* = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L426">            <span class="tok-kw">return</span> leaks;</span>
<span class="line" id="L427">        }</span>
<span class="line" id="L428"></span>
<span class="line" id="L429">        <span class="tok-kw">fn</span> <span class="tok-fn">collectStackTrace</span>(first_trace_addr: <span class="tok-type">usize</span>, addresses: *[stack_n]<span class="tok-type">usize</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L430">            <span class="tok-kw">if</span> (stack_n == <span class="tok-number">0</span>) <span class="tok-kw">return</span>;</span>
<span class="line" id="L431">            mem.set(<span class="tok-type">usize</span>, addresses, <span class="tok-number">0</span>);</span>
<span class="line" id="L432">            <span class="tok-kw">var</span> stack_trace = StackTrace{</span>
<span class="line" id="L433">                .instruction_addresses = addresses,</span>
<span class="line" id="L434">                .index = <span class="tok-number">0</span>,</span>
<span class="line" id="L435">            };</span>
<span class="line" id="L436">            std.debug.captureStackTrace(first_trace_addr, &amp;stack_trace);</span>
<span class="line" id="L437">        }</span>
<span class="line" id="L438"></span>
<span class="line" id="L439">        <span class="tok-kw">fn</span> <span class="tok-fn">reportDoubleFree</span>(ret_addr: <span class="tok-type">usize</span>, alloc_stack_trace: StackTrace, free_stack_trace: StackTrace) <span class="tok-type">void</span> {</span>
<span class="line" id="L440">            <span class="tok-kw">var</span> addresses: [stack_n]<span class="tok-type">usize</span> = [<span class="tok-number">1</span>]<span class="tok-type">usize</span>{<span class="tok-number">0</span>} ** stack_n;</span>
<span class="line" id="L441">            <span class="tok-kw">var</span> second_free_stack_trace = StackTrace{</span>
<span class="line" id="L442">                .instruction_addresses = &amp;addresses,</span>
<span class="line" id="L443">                .index = <span class="tok-number">0</span>,</span>
<span class="line" id="L444">            };</span>
<span class="line" id="L445">            std.debug.captureStackTrace(ret_addr, &amp;second_free_stack_trace);</span>
<span class="line" id="L446">            log.err(<span class="tok-str">&quot;Double free detected. Allocation: {s} First free: {s} Second free: {s}&quot;</span>, .{</span>
<span class="line" id="L447">                alloc_stack_trace, free_stack_trace, second_free_stack_trace,</span>
<span class="line" id="L448">            });</span>
<span class="line" id="L449">        }</span>
<span class="line" id="L450"></span>
<span class="line" id="L451">        <span class="tok-kw">fn</span> <span class="tok-fn">allocSlot</span>(self: *Self, size_class: <span class="tok-type">usize</span>, trace_addr: <span class="tok-type">usize</span>) Error![*]<span class="tok-type">u8</span> {</span>
<span class="line" id="L452">            <span class="tok-kw">const</span> bucket_index = math.log2(size_class);</span>
<span class="line" id="L453">            <span class="tok-kw">const</span> first_bucket = self.buckets[bucket_index] <span class="tok-kw">orelse</span> <span class="tok-kw">try</span> self.createBucket(</span>
<span class="line" id="L454">                size_class,</span>
<span class="line" id="L455">                bucket_index,</span>
<span class="line" id="L456">            );</span>
<span class="line" id="L457">            <span class="tok-kw">var</span> bucket = first_bucket;</span>
<span class="line" id="L458">            <span class="tok-kw">const</span> slot_count = <span class="tok-builtin">@divExact</span>(page_size, size_class);</span>
<span class="line" id="L459">            <span class="tok-kw">while</span> (bucket.alloc_cursor == slot_count) {</span>
<span class="line" id="L460">                <span class="tok-kw">const</span> prev_bucket = bucket;</span>
<span class="line" id="L461">                bucket = prev_bucket.next;</span>
<span class="line" id="L462">                <span class="tok-kw">if</span> (bucket == first_bucket) {</span>
<span class="line" id="L463">                    <span class="tok-comment">// make a new one</span>
</span>
<span class="line" id="L464">                    bucket = <span class="tok-kw">try</span> self.createBucket(size_class, bucket_index);</span>
<span class="line" id="L465">                    bucket.prev = prev_bucket;</span>
<span class="line" id="L466">                    bucket.next = prev_bucket.next;</span>
<span class="line" id="L467">                    prev_bucket.next = bucket;</span>
<span class="line" id="L468">                    bucket.next.prev = bucket;</span>
<span class="line" id="L469">                }</span>
<span class="line" id="L470">            }</span>
<span class="line" id="L471">            <span class="tok-comment">// change the allocator's current bucket to be this one</span>
</span>
<span class="line" id="L472">            self.buckets[bucket_index] = bucket;</span>
<span class="line" id="L473"></span>
<span class="line" id="L474">            <span class="tok-kw">const</span> slot_index = bucket.alloc_cursor;</span>
<span class="line" id="L475">            bucket.alloc_cursor += <span class="tok-number">1</span>;</span>
<span class="line" id="L476"></span>
<span class="line" id="L477">            <span class="tok-kw">var</span> used_bits_byte = bucket.usedBits(slot_index / <span class="tok-number">8</span>);</span>
<span class="line" id="L478">            <span class="tok-kw">const</span> used_bit_index: <span class="tok-type">u3</span> = <span class="tok-builtin">@intCast</span>(<span class="tok-type">u3</span>, slot_index % <span class="tok-number">8</span>); <span class="tok-comment">// TODO cast should be unnecessary</span>
</span>
<span class="line" id="L479">            used_bits_byte.* |= (<span class="tok-builtin">@as</span>(<span class="tok-type">u8</span>, <span class="tok-number">1</span>) &lt;&lt; used_bit_index);</span>
<span class="line" id="L480">            bucket.used_count += <span class="tok-number">1</span>;</span>
<span class="line" id="L481">            bucket.captureStackTrace(trace_addr, size_class, slot_index, .alloc);</span>
<span class="line" id="L482">            <span class="tok-kw">return</span> bucket.page + slot_index * size_class;</span>
<span class="line" id="L483">        }</span>
<span class="line" id="L484"></span>
<span class="line" id="L485">        <span class="tok-kw">fn</span> <span class="tok-fn">searchBucket</span>(</span>
<span class="line" id="L486">            bucket_list: ?*BucketHeader,</span>
<span class="line" id="L487">            addr: <span class="tok-type">usize</span>,</span>
<span class="line" id="L488">        ) ?*BucketHeader {</span>
<span class="line" id="L489">            <span class="tok-kw">const</span> first_bucket = bucket_list <span class="tok-kw">orelse</span> <span class="tok-kw">return</span> <span class="tok-null">null</span>;</span>
<span class="line" id="L490">            <span class="tok-kw">var</span> bucket = first_bucket;</span>
<span class="line" id="L491">            <span class="tok-kw">while</span> (<span class="tok-null">true</span>) {</span>
<span class="line" id="L492">                <span class="tok-kw">const</span> in_bucket_range = (addr &gt;= <span class="tok-builtin">@ptrToInt</span>(bucket.page) <span class="tok-kw">and</span></span>
<span class="line" id="L493">                    addr &lt; <span class="tok-builtin">@ptrToInt</span>(bucket.page) + page_size);</span>
<span class="line" id="L494">                <span class="tok-kw">if</span> (in_bucket_range) <span class="tok-kw">return</span> bucket;</span>
<span class="line" id="L495">                bucket = bucket.prev;</span>
<span class="line" id="L496">                <span class="tok-kw">if</span> (bucket == first_bucket) {</span>
<span class="line" id="L497">                    <span class="tok-kw">return</span> <span class="tok-null">null</span>;</span>
<span class="line" id="L498">                }</span>
<span class="line" id="L499">            }</span>
<span class="line" id="L500">        }</span>
<span class="line" id="L501"></span>
<span class="line" id="L502">        <span class="tok-comment">/// This function assumes the object is in the large object storage regardless</span></span>
<span class="line" id="L503">        <span class="tok-comment">/// of the parameters.</span></span>
<span class="line" id="L504">        <span class="tok-kw">fn</span> <span class="tok-fn">resizeLarge</span>(</span>
<span class="line" id="L505">            self: *Self,</span>
<span class="line" id="L506">            old_mem: []<span class="tok-type">u8</span>,</span>
<span class="line" id="L507">            old_align: <span class="tok-type">u29</span>,</span>
<span class="line" id="L508">            new_size: <span class="tok-type">usize</span>,</span>
<span class="line" id="L509">            len_align: <span class="tok-type">u29</span>,</span>
<span class="line" id="L510">            ret_addr: <span class="tok-type">usize</span>,</span>
<span class="line" id="L511">        ) ?<span class="tok-type">usize</span> {</span>
<span class="line" id="L512">            <span class="tok-kw">const</span> entry = self.large_allocations.getEntry(<span class="tok-builtin">@ptrToInt</span>(old_mem.ptr)) <span class="tok-kw">orelse</span> {</span>
<span class="line" id="L513">                <span class="tok-kw">if</span> (config.safety) {</span>
<span class="line" id="L514">                    <span class="tok-builtin">@panic</span>(<span class="tok-str">&quot;Invalid free&quot;</span>);</span>
<span class="line" id="L515">                } <span class="tok-kw">else</span> {</span>
<span class="line" id="L516">                    <span class="tok-kw">unreachable</span>;</span>
<span class="line" id="L517">                }</span>
<span class="line" id="L518">            };</span>
<span class="line" id="L519"></span>
<span class="line" id="L520">            <span class="tok-kw">if</span> (config.retain_metadata <span class="tok-kw">and</span> entry.value_ptr.freed) {</span>
<span class="line" id="L521">                <span class="tok-kw">if</span> (config.safety) {</span>
<span class="line" id="L522">                    reportDoubleFree(ret_addr, entry.value_ptr.getStackTrace(.alloc), entry.value_ptr.getStackTrace(.free));</span>
<span class="line" id="L523">                    <span class="tok-builtin">@panic</span>(<span class="tok-str">&quot;Unrecoverable double free&quot;</span>);</span>
<span class="line" id="L524">                } <span class="tok-kw">else</span> {</span>
<span class="line" id="L525">                    <span class="tok-kw">unreachable</span>;</span>
<span class="line" id="L526">                }</span>
<span class="line" id="L527">            }</span>
<span class="line" id="L528"></span>
<span class="line" id="L529">            <span class="tok-kw">if</span> (config.safety <span class="tok-kw">and</span> old_mem.len != entry.value_ptr.bytes.len) {</span>
<span class="line" id="L530">                <span class="tok-kw">var</span> addresses: [stack_n]<span class="tok-type">usize</span> = [<span class="tok-number">1</span>]<span class="tok-type">usize</span>{<span class="tok-number">0</span>} ** stack_n;</span>
<span class="line" id="L531">                <span class="tok-kw">var</span> free_stack_trace = StackTrace{</span>
<span class="line" id="L532">                    .instruction_addresses = &amp;addresses,</span>
<span class="line" id="L533">                    .index = <span class="tok-number">0</span>,</span>
<span class="line" id="L534">                };</span>
<span class="line" id="L535">                std.debug.captureStackTrace(ret_addr, &amp;free_stack_trace);</span>
<span class="line" id="L536">                log.err(<span class="tok-str">&quot;Allocation size {d} bytes does not match free size {d}. Allocation: {s} Free: {s}&quot;</span>, .{</span>
<span class="line" id="L537">                    entry.value_ptr.bytes.len,</span>
<span class="line" id="L538">                    old_mem.len,</span>
<span class="line" id="L539">                    entry.value_ptr.getStackTrace(.alloc),</span>
<span class="line" id="L540">                    free_stack_trace,</span>
<span class="line" id="L541">                });</span>
<span class="line" id="L542">            }</span>
<span class="line" id="L543"></span>
<span class="line" id="L544">            <span class="tok-comment">// Do memory limit accounting with requested sizes rather than what backing_allocator returns</span>
</span>
<span class="line" id="L545">            <span class="tok-comment">// because if we want to return error.OutOfMemory, we have to leave allocation untouched, and</span>
</span>
<span class="line" id="L546">            <span class="tok-comment">// that is impossible to guarantee after calling backing_allocator.rawResize.</span>
</span>
<span class="line" id="L547">            <span class="tok-kw">const</span> prev_req_bytes = self.total_requested_bytes;</span>
<span class="line" id="L548">            <span class="tok-kw">if</span> (config.enable_memory_limit) {</span>
<span class="line" id="L549">                <span class="tok-kw">const</span> new_req_bytes = prev_req_bytes + new_size - entry.value_ptr.requested_size;</span>
<span class="line" id="L550">                <span class="tok-kw">if</span> (new_req_bytes &gt; prev_req_bytes <span class="tok-kw">and</span> new_req_bytes &gt; self.requested_memory_limit) {</span>
<span class="line" id="L551">                    <span class="tok-kw">return</span> <span class="tok-null">null</span>;</span>
<span class="line" id="L552">                }</span>
<span class="line" id="L553">                self.total_requested_bytes = new_req_bytes;</span>
<span class="line" id="L554">            }</span>
<span class="line" id="L555"></span>
<span class="line" id="L556">            <span class="tok-kw">const</span> result_len = self.backing_allocator.rawResize(old_mem, old_align, new_size, len_align, ret_addr) <span class="tok-kw">orelse</span> {</span>
<span class="line" id="L557">                <span class="tok-kw">if</span> (config.enable_memory_limit) {</span>
<span class="line" id="L558">                    self.total_requested_bytes = prev_req_bytes;</span>
<span class="line" id="L559">                }</span>
<span class="line" id="L560">                <span class="tok-kw">return</span> <span class="tok-null">null</span>;</span>
<span class="line" id="L561">            };</span>
<span class="line" id="L562"></span>
<span class="line" id="L563">            <span class="tok-kw">if</span> (config.enable_memory_limit) {</span>
<span class="line" id="L564">                entry.value_ptr.requested_size = new_size;</span>
<span class="line" id="L565">            }</span>
<span class="line" id="L566"></span>
<span class="line" id="L567">            <span class="tok-kw">if</span> (config.verbose_log) {</span>
<span class="line" id="L568">                log.info(<span class="tok-str">&quot;large resize {d} bytes at {*} to {d}&quot;</span>, .{</span>
<span class="line" id="L569">                    old_mem.len, old_mem.ptr, new_size,</span>
<span class="line" id="L570">                });</span>
<span class="line" id="L571">            }</span>
<span class="line" id="L572">            entry.value_ptr.bytes = old_mem.ptr[<span class="tok-number">0</span>..result_len];</span>
<span class="line" id="L573">            entry.value_ptr.captureStackTrace(ret_addr, .alloc);</span>
<span class="line" id="L574">            <span class="tok-kw">return</span> result_len;</span>
<span class="line" id="L575">        }</span>
<span class="line" id="L576"></span>
<span class="line" id="L577">        <span class="tok-comment">/// This function assumes the object is in the large object storage regardless</span></span>
<span class="line" id="L578">        <span class="tok-comment">/// of the parameters.</span></span>
<span class="line" id="L579">        <span class="tok-kw">fn</span> <span class="tok-fn">freeLarge</span>(</span>
<span class="line" id="L580">            self: *Self,</span>
<span class="line" id="L581">            old_mem: []<span class="tok-type">u8</span>,</span>
<span class="line" id="L582">            old_align: <span class="tok-type">u29</span>,</span>
<span class="line" id="L583">            ret_addr: <span class="tok-type">usize</span>,</span>
<span class="line" id="L584">        ) <span class="tok-type">void</span> {</span>
<span class="line" id="L585">            _ = old_align;</span>
<span class="line" id="L586"></span>
<span class="line" id="L587">            <span class="tok-kw">const</span> entry = self.large_allocations.getEntry(<span class="tok-builtin">@ptrToInt</span>(old_mem.ptr)) <span class="tok-kw">orelse</span> {</span>
<span class="line" id="L588">                <span class="tok-kw">if</span> (config.safety) {</span>
<span class="line" id="L589">                    <span class="tok-builtin">@panic</span>(<span class="tok-str">&quot;Invalid free&quot;</span>);</span>
<span class="line" id="L590">                } <span class="tok-kw">else</span> {</span>
<span class="line" id="L591">                    <span class="tok-kw">unreachable</span>;</span>
<span class="line" id="L592">                }</span>
<span class="line" id="L593">            };</span>
<span class="line" id="L594"></span>
<span class="line" id="L595">            <span class="tok-kw">if</span> (config.retain_metadata <span class="tok-kw">and</span> entry.value_ptr.freed) {</span>
<span class="line" id="L596">                <span class="tok-kw">if</span> (config.safety) {</span>
<span class="line" id="L597">                    reportDoubleFree(ret_addr, entry.value_ptr.getStackTrace(.alloc), entry.value_ptr.getStackTrace(.free));</span>
<span class="line" id="L598">                    <span class="tok-kw">return</span>;</span>
<span class="line" id="L599">                } <span class="tok-kw">else</span> {</span>
<span class="line" id="L600">                    <span class="tok-kw">unreachable</span>;</span>
<span class="line" id="L601">                }</span>
<span class="line" id="L602">            }</span>
<span class="line" id="L603"></span>
<span class="line" id="L604">            <span class="tok-kw">if</span> (config.safety <span class="tok-kw">and</span> old_mem.len != entry.value_ptr.bytes.len) {</span>
<span class="line" id="L605">                <span class="tok-kw">var</span> addresses: [stack_n]<span class="tok-type">usize</span> = [<span class="tok-number">1</span>]<span class="tok-type">usize</span>{<span class="tok-number">0</span>} ** stack_n;</span>
<span class="line" id="L606">                <span class="tok-kw">var</span> free_stack_trace = StackTrace{</span>
<span class="line" id="L607">                    .instruction_addresses = &amp;addresses,</span>
<span class="line" id="L608">                    .index = <span class="tok-number">0</span>,</span>
<span class="line" id="L609">                };</span>
<span class="line" id="L610">                std.debug.captureStackTrace(ret_addr, &amp;free_stack_trace);</span>
<span class="line" id="L611">                log.err(<span class="tok-str">&quot;Allocation size {d} bytes does not match free size {d}. Allocation: {s} Free: {s}&quot;</span>, .{</span>
<span class="line" id="L612">                    entry.value_ptr.bytes.len,</span>
<span class="line" id="L613">                    old_mem.len,</span>
<span class="line" id="L614">                    entry.value_ptr.getStackTrace(.alloc),</span>
<span class="line" id="L615">                    free_stack_trace,</span>
<span class="line" id="L616">                });</span>
<span class="line" id="L617">            }</span>
<span class="line" id="L618"></span>
<span class="line" id="L619">            <span class="tok-kw">if</span> (!config.never_unmap) {</span>
<span class="line" id="L620">                self.backing_allocator.rawFree(old_mem, old_align, ret_addr);</span>
<span class="line" id="L621">            }</span>
<span class="line" id="L622"></span>
<span class="line" id="L623">            <span class="tok-kw">if</span> (config.enable_memory_limit) {</span>
<span class="line" id="L624">                self.total_requested_bytes -= entry.value_ptr.requested_size;</span>
<span class="line" id="L625">            }</span>
<span class="line" id="L626"></span>
<span class="line" id="L627">            <span class="tok-kw">if</span> (config.verbose_log) {</span>
<span class="line" id="L628">                log.info(<span class="tok-str">&quot;large free {d} bytes at {*}&quot;</span>, .{ old_mem.len, old_mem.ptr });</span>
<span class="line" id="L629">            }</span>
<span class="line" id="L630"></span>
<span class="line" id="L631">            <span class="tok-kw">if</span> (!config.retain_metadata) {</span>
<span class="line" id="L632">                assert(self.large_allocations.remove(<span class="tok-builtin">@ptrToInt</span>(old_mem.ptr)));</span>
<span class="line" id="L633">            } <span class="tok-kw">else</span> {</span>
<span class="line" id="L634">                entry.value_ptr.freed = <span class="tok-null">true</span>;</span>
<span class="line" id="L635">                entry.value_ptr.captureStackTrace(ret_addr, .free);</span>
<span class="line" id="L636">            }</span>
<span class="line" id="L637">        }</span>
<span class="line" id="L638"></span>
<span class="line" id="L639">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">setRequestedMemoryLimit</span>(self: *Self, limit: <span class="tok-type">usize</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L640">            self.requested_memory_limit = limit;</span>
<span class="line" id="L641">        }</span>
<span class="line" id="L642"></span>
<span class="line" id="L643">        <span class="tok-kw">fn</span> <span class="tok-fn">resize</span>(</span>
<span class="line" id="L644">            self: *Self,</span>
<span class="line" id="L645">            old_mem: []<span class="tok-type">u8</span>,</span>
<span class="line" id="L646">            old_align: <span class="tok-type">u29</span>,</span>
<span class="line" id="L647">            new_size: <span class="tok-type">usize</span>,</span>
<span class="line" id="L648">            len_align: <span class="tok-type">u29</span>,</span>
<span class="line" id="L649">            ret_addr: <span class="tok-type">usize</span>,</span>
<span class="line" id="L650">        ) ?<span class="tok-type">usize</span> {</span>
<span class="line" id="L651">            self.mutex.lock();</span>
<span class="line" id="L652">            <span class="tok-kw">defer</span> self.mutex.unlock();</span>
<span class="line" id="L653"></span>
<span class="line" id="L654">            assert(old_mem.len != <span class="tok-number">0</span>);</span>
<span class="line" id="L655"></span>
<span class="line" id="L656">            <span class="tok-kw">const</span> aligned_size = math.max(old_mem.len, old_align);</span>
<span class="line" id="L657">            <span class="tok-kw">if</span> (aligned_size &gt; largest_bucket_object_size) {</span>
<span class="line" id="L658">                <span class="tok-kw">return</span> self.resizeLarge(old_mem, old_align, new_size, len_align, ret_addr);</span>
<span class="line" id="L659">            }</span>
<span class="line" id="L660">            <span class="tok-kw">const</span> size_class_hint = math.ceilPowerOfTwoAssert(<span class="tok-type">usize</span>, aligned_size);</span>
<span class="line" id="L661"></span>
<span class="line" id="L662">            <span class="tok-kw">var</span> bucket_index = math.log2(size_class_hint);</span>
<span class="line" id="L663">            <span class="tok-kw">var</span> size_class: <span class="tok-type">usize</span> = size_class_hint;</span>
<span class="line" id="L664">            <span class="tok-kw">const</span> bucket = <span class="tok-kw">while</span> (bucket_index &lt; small_bucket_count) : (bucket_index += <span class="tok-number">1</span>) {</span>
<span class="line" id="L665">                <span class="tok-kw">if</span> (searchBucket(self.buckets[bucket_index], <span class="tok-builtin">@ptrToInt</span>(old_mem.ptr))) |bucket| {</span>
<span class="line" id="L666">                    <span class="tok-comment">// move bucket to head of list to optimize search for nearby allocations</span>
</span>
<span class="line" id="L667">                    self.buckets[bucket_index] = bucket;</span>
<span class="line" id="L668">                    <span class="tok-kw">break</span> bucket;</span>
<span class="line" id="L669">                }</span>
<span class="line" id="L670">                size_class *= <span class="tok-number">2</span>;</span>
<span class="line" id="L671">            } <span class="tok-kw">else</span> blk: {</span>
<span class="line" id="L672">                <span class="tok-kw">if</span> (config.retain_metadata) {</span>
<span class="line" id="L673">                    <span class="tok-kw">if</span> (!self.large_allocations.contains(<span class="tok-builtin">@ptrToInt</span>(old_mem.ptr))) {</span>
<span class="line" id="L674">                        <span class="tok-comment">// object not in active buckets or a large allocation, so search empty buckets</span>
</span>
<span class="line" id="L675">                        <span class="tok-kw">if</span> (searchBucket(self.empty_buckets, <span class="tok-builtin">@ptrToInt</span>(old_mem.ptr))) |bucket| {</span>
<span class="line" id="L676">                            <span class="tok-comment">// bucket is empty so is_used below will always be false and we exit there</span>
</span>
<span class="line" id="L677">                            <span class="tok-kw">break</span> :blk bucket;</span>
<span class="line" id="L678">                        } <span class="tok-kw">else</span> {</span>
<span class="line" id="L679">                            <span class="tok-builtin">@panic</span>(<span class="tok-str">&quot;Invalid free&quot;</span>);</span>
<span class="line" id="L680">                        }</span>
<span class="line" id="L681">                    }</span>
<span class="line" id="L682">                }</span>
<span class="line" id="L683">                <span class="tok-kw">return</span> self.resizeLarge(old_mem, old_align, new_size, len_align, ret_addr);</span>
<span class="line" id="L684">            };</span>
<span class="line" id="L685">            <span class="tok-kw">const</span> byte_offset = <span class="tok-builtin">@ptrToInt</span>(old_mem.ptr) - <span class="tok-builtin">@ptrToInt</span>(bucket.page);</span>
<span class="line" id="L686">            <span class="tok-kw">const</span> slot_index = <span class="tok-builtin">@intCast</span>(SlotIndex, byte_offset / size_class);</span>
<span class="line" id="L687">            <span class="tok-kw">const</span> used_byte_index = slot_index / <span class="tok-number">8</span>;</span>
<span class="line" id="L688">            <span class="tok-kw">const</span> used_bit_index = <span class="tok-builtin">@intCast</span>(<span class="tok-type">u3</span>, slot_index % <span class="tok-number">8</span>);</span>
<span class="line" id="L689">            <span class="tok-kw">const</span> used_byte = bucket.usedBits(used_byte_index);</span>
<span class="line" id="L690">            <span class="tok-kw">const</span> is_used = <span class="tok-builtin">@truncate</span>(<span class="tok-type">u1</span>, used_byte.* &gt;&gt; used_bit_index) != <span class="tok-number">0</span>;</span>
<span class="line" id="L691">            <span class="tok-kw">if</span> (!is_used) {</span>
<span class="line" id="L692">                <span class="tok-kw">if</span> (config.safety) {</span>
<span class="line" id="L693">                    reportDoubleFree(ret_addr, bucketStackTrace(bucket, size_class, slot_index, .alloc), bucketStackTrace(bucket, size_class, slot_index, .free));</span>
<span class="line" id="L694">                    <span class="tok-builtin">@panic</span>(<span class="tok-str">&quot;Unrecoverable double free&quot;</span>);</span>
<span class="line" id="L695">                } <span class="tok-kw">else</span> {</span>
<span class="line" id="L696">                    <span class="tok-kw">unreachable</span>;</span>
<span class="line" id="L697">                }</span>
<span class="line" id="L698">            }</span>
<span class="line" id="L699"></span>
<span class="line" id="L700">            <span class="tok-comment">// Definitely an in-use small alloc now.</span>
</span>
<span class="line" id="L701">            <span class="tok-kw">const</span> prev_req_bytes = self.total_requested_bytes;</span>
<span class="line" id="L702">            <span class="tok-kw">if</span> (config.enable_memory_limit) {</span>
<span class="line" id="L703">                <span class="tok-kw">const</span> new_req_bytes = prev_req_bytes + new_size - old_mem.len;</span>
<span class="line" id="L704">                <span class="tok-kw">if</span> (new_req_bytes &gt; prev_req_bytes <span class="tok-kw">and</span> new_req_bytes &gt; self.requested_memory_limit) {</span>
<span class="line" id="L705">                    <span class="tok-kw">return</span> <span class="tok-null">null</span>;</span>
<span class="line" id="L706">                }</span>
<span class="line" id="L707">                self.total_requested_bytes = new_req_bytes;</span>
<span class="line" id="L708">            }</span>
<span class="line" id="L709"></span>
<span class="line" id="L710">            <span class="tok-kw">const</span> new_aligned_size = math.max(new_size, old_align);</span>
<span class="line" id="L711">            <span class="tok-kw">const</span> new_size_class = math.ceilPowerOfTwoAssert(<span class="tok-type">usize</span>, new_aligned_size);</span>
<span class="line" id="L712">            <span class="tok-kw">if</span> (new_size_class &lt;= size_class) {</span>
<span class="line" id="L713">                <span class="tok-kw">if</span> (old_mem.len &gt; new_size) {</span>
<span class="line" id="L714">                    <span class="tok-builtin">@memset</span>(old_mem.ptr + new_size, <span class="tok-null">undefined</span>, old_mem.len - new_size);</span>
<span class="line" id="L715">                }</span>
<span class="line" id="L716">                <span class="tok-kw">if</span> (config.verbose_log) {</span>
<span class="line" id="L717">                    log.info(<span class="tok-str">&quot;small resize {d} bytes at {*} to {d}&quot;</span>, .{</span>
<span class="line" id="L718">                        old_mem.len, old_mem.ptr, new_size,</span>
<span class="line" id="L719">                    });</span>
<span class="line" id="L720">                }</span>
<span class="line" id="L721">                <span class="tok-kw">return</span> new_size;</span>
<span class="line" id="L722">            }</span>
<span class="line" id="L723"></span>
<span class="line" id="L724">            <span class="tok-kw">if</span> (config.enable_memory_limit) {</span>
<span class="line" id="L725">                self.total_requested_bytes = prev_req_bytes;</span>
<span class="line" id="L726">            }</span>
<span class="line" id="L727">            <span class="tok-kw">return</span> <span class="tok-null">null</span>;</span>
<span class="line" id="L728">        }</span>
<span class="line" id="L729"></span>
<span class="line" id="L730">        <span class="tok-kw">fn</span> <span class="tok-fn">free</span>(</span>
<span class="line" id="L731">            self: *Self,</span>
<span class="line" id="L732">            old_mem: []<span class="tok-type">u8</span>,</span>
<span class="line" id="L733">            old_align: <span class="tok-type">u29</span>,</span>
<span class="line" id="L734">            ret_addr: <span class="tok-type">usize</span>,</span>
<span class="line" id="L735">        ) <span class="tok-type">void</span> {</span>
<span class="line" id="L736">            self.mutex.lock();</span>
<span class="line" id="L737">            <span class="tok-kw">defer</span> self.mutex.unlock();</span>
<span class="line" id="L738"></span>
<span class="line" id="L739">            assert(old_mem.len != <span class="tok-number">0</span>);</span>
<span class="line" id="L740"></span>
<span class="line" id="L741">            <span class="tok-kw">const</span> aligned_size = math.max(old_mem.len, old_align);</span>
<span class="line" id="L742">            <span class="tok-kw">if</span> (aligned_size &gt; largest_bucket_object_size) {</span>
<span class="line" id="L743">                self.freeLarge(old_mem, old_align, ret_addr);</span>
<span class="line" id="L744">                <span class="tok-kw">return</span>;</span>
<span class="line" id="L745">            }</span>
<span class="line" id="L746">            <span class="tok-kw">const</span> size_class_hint = math.ceilPowerOfTwoAssert(<span class="tok-type">usize</span>, aligned_size);</span>
<span class="line" id="L747"></span>
<span class="line" id="L748">            <span class="tok-kw">var</span> bucket_index = math.log2(size_class_hint);</span>
<span class="line" id="L749">            <span class="tok-kw">var</span> size_class: <span class="tok-type">usize</span> = size_class_hint;</span>
<span class="line" id="L750">            <span class="tok-kw">const</span> bucket = <span class="tok-kw">while</span> (bucket_index &lt; small_bucket_count) : (bucket_index += <span class="tok-number">1</span>) {</span>
<span class="line" id="L751">                <span class="tok-kw">if</span> (searchBucket(self.buckets[bucket_index], <span class="tok-builtin">@ptrToInt</span>(old_mem.ptr))) |bucket| {</span>
<span class="line" id="L752">                    <span class="tok-comment">// move bucket to head of list to optimize search for nearby allocations</span>
</span>
<span class="line" id="L753">                    self.buckets[bucket_index] = bucket;</span>
<span class="line" id="L754">                    <span class="tok-kw">break</span> bucket;</span>
<span class="line" id="L755">                }</span>
<span class="line" id="L756">                size_class *= <span class="tok-number">2</span>;</span>
<span class="line" id="L757">            } <span class="tok-kw">else</span> blk: {</span>
<span class="line" id="L758">                <span class="tok-kw">if</span> (config.retain_metadata) {</span>
<span class="line" id="L759">                    <span class="tok-kw">if</span> (!self.large_allocations.contains(<span class="tok-builtin">@ptrToInt</span>(old_mem.ptr))) {</span>
<span class="line" id="L760">                        <span class="tok-comment">// object not in active buckets or a large allocation, so search empty buckets</span>
</span>
<span class="line" id="L761">                        <span class="tok-kw">if</span> (searchBucket(self.empty_buckets, <span class="tok-builtin">@ptrToInt</span>(old_mem.ptr))) |bucket| {</span>
<span class="line" id="L762">                            <span class="tok-comment">// bucket is empty so is_used below will always be false and we exit there</span>
</span>
<span class="line" id="L763">                            <span class="tok-kw">break</span> :blk bucket;</span>
<span class="line" id="L764">                        } <span class="tok-kw">else</span> {</span>
<span class="line" id="L765">                            <span class="tok-builtin">@panic</span>(<span class="tok-str">&quot;Invalid free&quot;</span>);</span>
<span class="line" id="L766">                        }</span>
<span class="line" id="L767">                    }</span>
<span class="line" id="L768">                }</span>
<span class="line" id="L769">                self.freeLarge(old_mem, old_align, ret_addr);</span>
<span class="line" id="L770">                <span class="tok-kw">return</span>;</span>
<span class="line" id="L771">            };</span>
<span class="line" id="L772">            <span class="tok-kw">const</span> byte_offset = <span class="tok-builtin">@ptrToInt</span>(old_mem.ptr) - <span class="tok-builtin">@ptrToInt</span>(bucket.page);</span>
<span class="line" id="L773">            <span class="tok-kw">const</span> slot_index = <span class="tok-builtin">@intCast</span>(SlotIndex, byte_offset / size_class);</span>
<span class="line" id="L774">            <span class="tok-kw">const</span> used_byte_index = slot_index / <span class="tok-number">8</span>;</span>
<span class="line" id="L775">            <span class="tok-kw">const</span> used_bit_index = <span class="tok-builtin">@intCast</span>(<span class="tok-type">u3</span>, slot_index % <span class="tok-number">8</span>);</span>
<span class="line" id="L776">            <span class="tok-kw">const</span> used_byte = bucket.usedBits(used_byte_index);</span>
<span class="line" id="L777">            <span class="tok-kw">const</span> is_used = <span class="tok-builtin">@truncate</span>(<span class="tok-type">u1</span>, used_byte.* &gt;&gt; used_bit_index) != <span class="tok-number">0</span>;</span>
<span class="line" id="L778">            <span class="tok-kw">if</span> (!is_used) {</span>
<span class="line" id="L779">                <span class="tok-kw">if</span> (config.safety) {</span>
<span class="line" id="L780">                    reportDoubleFree(ret_addr, bucketStackTrace(bucket, size_class, slot_index, .alloc), bucketStackTrace(bucket, size_class, slot_index, .free));</span>
<span class="line" id="L781">                    <span class="tok-comment">// Recoverable if this is a free.</span>
</span>
<span class="line" id="L782">                    <span class="tok-kw">return</span>;</span>
<span class="line" id="L783">                } <span class="tok-kw">else</span> {</span>
<span class="line" id="L784">                    <span class="tok-kw">unreachable</span>;</span>
<span class="line" id="L785">                }</span>
<span class="line" id="L786">            }</span>
<span class="line" id="L787"></span>
<span class="line" id="L788">            <span class="tok-comment">// Definitely an in-use small alloc now.</span>
</span>
<span class="line" id="L789">            <span class="tok-kw">if</span> (config.enable_memory_limit) {</span>
<span class="line" id="L790">                self.total_requested_bytes -= old_mem.len;</span>
<span class="line" id="L791">            }</span>
<span class="line" id="L792"></span>
<span class="line" id="L793">            <span class="tok-comment">// Capture stack trace to be the &quot;first free&quot;, in case a double free happens.</span>
</span>
<span class="line" id="L794">            bucket.captureStackTrace(ret_addr, size_class, slot_index, .free);</span>
<span class="line" id="L795"></span>
<span class="line" id="L796">            used_byte.* &amp;= ~(<span class="tok-builtin">@as</span>(<span class="tok-type">u8</span>, <span class="tok-number">1</span>) &lt;&lt; used_bit_index);</span>
<span class="line" id="L797">            bucket.used_count -= <span class="tok-number">1</span>;</span>
<span class="line" id="L798">            <span class="tok-kw">if</span> (bucket.used_count == <span class="tok-number">0</span>) {</span>
<span class="line" id="L799">                <span class="tok-kw">if</span> (bucket.next == bucket) {</span>
<span class="line" id="L800">                    <span class="tok-comment">// it's the only bucket and therefore the current one</span>
</span>
<span class="line" id="L801">                    self.buckets[bucket_index] = <span class="tok-null">null</span>;</span>
<span class="line" id="L802">                } <span class="tok-kw">else</span> {</span>
<span class="line" id="L803">                    bucket.next.prev = bucket.prev;</span>
<span class="line" id="L804">                    bucket.prev.next = bucket.next;</span>
<span class="line" id="L805">                    self.buckets[bucket_index] = bucket.prev;</span>
<span class="line" id="L806">                }</span>
<span class="line" id="L807">                <span class="tok-kw">if</span> (!config.never_unmap) {</span>
<span class="line" id="L808">                    self.backing_allocator.free(bucket.page[<span class="tok-number">0</span>..page_size]);</span>
<span class="line" id="L809">                }</span>
<span class="line" id="L810">                <span class="tok-kw">if</span> (!config.retain_metadata) {</span>
<span class="line" id="L811">                    self.freeBucket(bucket, size_class);</span>
<span class="line" id="L812">                } <span class="tok-kw">else</span> {</span>
<span class="line" id="L813">                    <span class="tok-comment">// move alloc_cursor to end so we can tell size_class later</span>
</span>
<span class="line" id="L814">                    <span class="tok-kw">const</span> slot_count = <span class="tok-builtin">@divExact</span>(page_size, size_class);</span>
<span class="line" id="L815">                    bucket.alloc_cursor = <span class="tok-builtin">@truncate</span>(SlotIndex, slot_count);</span>
<span class="line" id="L816">                    <span class="tok-kw">if</span> (self.empty_buckets) |prev_bucket| {</span>
<span class="line" id="L817">                        <span class="tok-comment">// empty_buckets is ordered newest to oldest through prev so that if</span>
</span>
<span class="line" id="L818">                        <span class="tok-comment">// config.never_unmap is false and backing_allocator reuses freed memory</span>
</span>
<span class="line" id="L819">                        <span class="tok-comment">// then searchBuckets will always return the newer, relevant bucket</span>
</span>
<span class="line" id="L820">                        bucket.prev = prev_bucket;</span>
<span class="line" id="L821">                        bucket.next = prev_bucket.next;</span>
<span class="line" id="L822">                        prev_bucket.next = bucket;</span>
<span class="line" id="L823">                        bucket.next.prev = bucket;</span>
<span class="line" id="L824">                    } <span class="tok-kw">else</span> {</span>
<span class="line" id="L825">                        bucket.prev = bucket;</span>
<span class="line" id="L826">                        bucket.next = bucket;</span>
<span class="line" id="L827">                    }</span>
<span class="line" id="L828">                    self.empty_buckets = bucket;</span>
<span class="line" id="L829">                }</span>
<span class="line" id="L830">            } <span class="tok-kw">else</span> {</span>
<span class="line" id="L831">                <span class="tok-builtin">@memset</span>(old_mem.ptr, <span class="tok-null">undefined</span>, old_mem.len);</span>
<span class="line" id="L832">            }</span>
<span class="line" id="L833">            <span class="tok-kw">if</span> (config.verbose_log) {</span>
<span class="line" id="L834">                log.info(<span class="tok-str">&quot;small free {d} bytes at {*}&quot;</span>, .{ old_mem.len, old_mem.ptr });</span>
<span class="line" id="L835">            }</span>
<span class="line" id="L836">        }</span>
<span class="line" id="L837"></span>
<span class="line" id="L838">        <span class="tok-comment">// Returns true if an allocation of `size` bytes is within the specified</span>
</span>
<span class="line" id="L839">        <span class="tok-comment">// limits if enable_memory_limit is true</span>
</span>
<span class="line" id="L840">        <span class="tok-kw">fn</span> <span class="tok-fn">isAllocationAllowed</span>(self: *Self, size: <span class="tok-type">usize</span>) <span class="tok-type">bool</span> {</span>
<span class="line" id="L841">            <span class="tok-kw">if</span> (config.enable_memory_limit) {</span>
<span class="line" id="L842">                <span class="tok-kw">const</span> new_req_bytes = self.total_requested_bytes + size;</span>
<span class="line" id="L843">                <span class="tok-kw">if</span> (new_req_bytes &gt; self.requested_memory_limit)</span>
<span class="line" id="L844">                    <span class="tok-kw">return</span> <span class="tok-null">false</span>;</span>
<span class="line" id="L845">                self.total_requested_bytes = new_req_bytes;</span>
<span class="line" id="L846">            }</span>
<span class="line" id="L847"></span>
<span class="line" id="L848">            <span class="tok-kw">return</span> <span class="tok-null">true</span>;</span>
<span class="line" id="L849">        }</span>
<span class="line" id="L850"></span>
<span class="line" id="L851">        <span class="tok-kw">fn</span> <span class="tok-fn">alloc</span>(self: *Self, len: <span class="tok-type">usize</span>, ptr_align: <span class="tok-type">u29</span>, len_align: <span class="tok-type">u29</span>, ret_addr: <span class="tok-type">usize</span>) Error![]<span class="tok-type">u8</span> {</span>
<span class="line" id="L852">            self.mutex.lock();</span>
<span class="line" id="L853">            <span class="tok-kw">defer</span> self.mutex.unlock();</span>
<span class="line" id="L854"></span>
<span class="line" id="L855">            <span class="tok-kw">if</span> (!self.isAllocationAllowed(len)) {</span>
<span class="line" id="L856">                <span class="tok-kw">return</span> <span class="tok-kw">error</span>.OutOfMemory;</span>
<span class="line" id="L857">            }</span>
<span class="line" id="L858"></span>
<span class="line" id="L859">            <span class="tok-kw">const</span> new_aligned_size = math.max(len, ptr_align);</span>
<span class="line" id="L860">            <span class="tok-kw">if</span> (new_aligned_size &gt; largest_bucket_object_size) {</span>
<span class="line" id="L861">                <span class="tok-kw">try</span> self.large_allocations.ensureUnusedCapacity(self.backing_allocator, <span class="tok-number">1</span>);</span>
<span class="line" id="L862">                <span class="tok-kw">const</span> slice = <span class="tok-kw">try</span> self.backing_allocator.rawAlloc(len, ptr_align, len_align, ret_addr);</span>
<span class="line" id="L863"></span>
<span class="line" id="L864">                <span class="tok-kw">const</span> gop = self.large_allocations.getOrPutAssumeCapacity(<span class="tok-builtin">@ptrToInt</span>(slice.ptr));</span>
<span class="line" id="L865">                <span class="tok-kw">if</span> (config.retain_metadata <span class="tok-kw">and</span> !config.never_unmap) {</span>
<span class="line" id="L866">                    <span class="tok-comment">// Backing allocator may be reusing memory that we're retaining metadata for</span>
</span>
<span class="line" id="L867">                    assert(!gop.found_existing <span class="tok-kw">or</span> gop.value_ptr.freed);</span>
<span class="line" id="L868">                } <span class="tok-kw">else</span> {</span>
<span class="line" id="L869">                    assert(!gop.found_existing); <span class="tok-comment">// This would mean the kernel double-mapped pages.</span>
</span>
<span class="line" id="L870">                }</span>
<span class="line" id="L871">                gop.value_ptr.bytes = slice;</span>
<span class="line" id="L872">                <span class="tok-kw">if</span> (config.enable_memory_limit)</span>
<span class="line" id="L873">                    gop.value_ptr.requested_size = len;</span>
<span class="line" id="L874">                gop.value_ptr.captureStackTrace(ret_addr, .alloc);</span>
<span class="line" id="L875">                <span class="tok-kw">if</span> (config.retain_metadata) {</span>
<span class="line" id="L876">                    gop.value_ptr.freed = <span class="tok-null">false</span>;</span>
<span class="line" id="L877">                    <span class="tok-kw">if</span> (config.never_unmap) {</span>
<span class="line" id="L878">                        gop.value_ptr.ptr_align = ptr_align;</span>
<span class="line" id="L879">                    }</span>
<span class="line" id="L880">                }</span>
<span class="line" id="L881"></span>
<span class="line" id="L882">                <span class="tok-kw">if</span> (config.verbose_log) {</span>
<span class="line" id="L883">                    log.info(<span class="tok-str">&quot;large alloc {d} bytes at {*}&quot;</span>, .{ slice.len, slice.ptr });</span>
<span class="line" id="L884">                }</span>
<span class="line" id="L885">                <span class="tok-kw">return</span> slice;</span>
<span class="line" id="L886">            }</span>
<span class="line" id="L887"></span>
<span class="line" id="L888">            <span class="tok-kw">const</span> new_size_class = math.ceilPowerOfTwoAssert(<span class="tok-type">usize</span>, new_aligned_size);</span>
<span class="line" id="L889">            <span class="tok-kw">const</span> ptr = <span class="tok-kw">try</span> self.allocSlot(new_size_class, ret_addr);</span>
<span class="line" id="L890">            <span class="tok-kw">if</span> (config.verbose_log) {</span>
<span class="line" id="L891">                log.info(<span class="tok-str">&quot;small alloc {d} bytes at {*}&quot;</span>, .{ len, ptr });</span>
<span class="line" id="L892">            }</span>
<span class="line" id="L893">            <span class="tok-kw">return</span> ptr[<span class="tok-number">0</span>..len];</span>
<span class="line" id="L894">        }</span>
<span class="line" id="L895"></span>
<span class="line" id="L896">        <span class="tok-kw">fn</span> <span class="tok-fn">createBucket</span>(self: *Self, size_class: <span class="tok-type">usize</span>, bucket_index: <span class="tok-type">usize</span>) Error!*BucketHeader {</span>
<span class="line" id="L897">            <span class="tok-kw">const</span> page = <span class="tok-kw">try</span> self.backing_allocator.allocAdvanced(<span class="tok-type">u8</span>, page_size, page_size, .exact);</span>
<span class="line" id="L898">            <span class="tok-kw">errdefer</span> self.backing_allocator.free(page);</span>
<span class="line" id="L899"></span>
<span class="line" id="L900">            <span class="tok-kw">const</span> bucket_size = bucketSize(size_class);</span>
<span class="line" id="L901">            <span class="tok-kw">const</span> bucket_bytes = <span class="tok-kw">try</span> self.backing_allocator.allocAdvanced(<span class="tok-type">u8</span>, <span class="tok-builtin">@alignOf</span>(BucketHeader), bucket_size, .exact);</span>
<span class="line" id="L902">            <span class="tok-kw">const</span> ptr = <span class="tok-builtin">@ptrCast</span>(*BucketHeader, bucket_bytes.ptr);</span>
<span class="line" id="L903">            ptr.* = BucketHeader{</span>
<span class="line" id="L904">                .prev = ptr,</span>
<span class="line" id="L905">                .next = ptr,</span>
<span class="line" id="L906">                .page = page.ptr,</span>
<span class="line" id="L907">                .alloc_cursor = <span class="tok-number">0</span>,</span>
<span class="line" id="L908">                .used_count = <span class="tok-number">0</span>,</span>
<span class="line" id="L909">            };</span>
<span class="line" id="L910">            self.buckets[bucket_index] = ptr;</span>
<span class="line" id="L911">            <span class="tok-comment">// Set the used bits to all zeroes</span>
</span>
<span class="line" id="L912">            <span class="tok-builtin">@memset</span>(<span class="tok-builtin">@as</span>(*[<span class="tok-number">1</span>]<span class="tok-type">u8</span>, ptr.usedBits(<span class="tok-number">0</span>)), <span class="tok-number">0</span>, usedBitsCount(size_class));</span>
<span class="line" id="L913">            <span class="tok-kw">return</span> ptr;</span>
<span class="line" id="L914">        }</span>
<span class="line" id="L915">    };</span>
<span class="line" id="L916">}</span>
<span class="line" id="L917"></span>
<span class="line" id="L918"><span class="tok-kw">const</span> TraceKind = <span class="tok-kw">enum</span> {</span>
<span class="line" id="L919">    alloc,</span>
<span class="line" id="L920">    free,</span>
<span class="line" id="L921">};</span>
<span class="line" id="L922"></span>
<span class="line" id="L923"><span class="tok-kw">const</span> test_config = Config{};</span>
<span class="line" id="L924"></span>
<span class="line" id="L925"><span class="tok-kw">test</span> <span class="tok-str">&quot;small allocations - free in same order&quot;</span> {</span>
<span class="line" id="L926">    <span class="tok-kw">var</span> gpa = GeneralPurposeAllocator(test_config){};</span>
<span class="line" id="L927">    <span class="tok-kw">defer</span> std.testing.expect(!gpa.deinit()) <span class="tok-kw">catch</span> <span class="tok-builtin">@panic</span>(<span class="tok-str">&quot;leak&quot;</span>);</span>
<span class="line" id="L928">    <span class="tok-kw">const</span> allocator = gpa.allocator();</span>
<span class="line" id="L929"></span>
<span class="line" id="L930">    <span class="tok-kw">var</span> list = std.ArrayList(*<span class="tok-type">u64</span>).init(std.testing.allocator);</span>
<span class="line" id="L931">    <span class="tok-kw">defer</span> list.deinit();</span>
<span class="line" id="L932"></span>
<span class="line" id="L933">    <span class="tok-kw">var</span> i: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L934">    <span class="tok-kw">while</span> (i &lt; <span class="tok-number">513</span>) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L935">        <span class="tok-kw">const</span> ptr = <span class="tok-kw">try</span> allocator.create(<span class="tok-type">u64</span>);</span>
<span class="line" id="L936">        <span class="tok-kw">try</span> list.append(ptr);</span>
<span class="line" id="L937">    }</span>
<span class="line" id="L938"></span>
<span class="line" id="L939">    <span class="tok-kw">for</span> (list.items) |ptr| {</span>
<span class="line" id="L940">        allocator.destroy(ptr);</span>
<span class="line" id="L941">    }</span>
<span class="line" id="L942">}</span>
<span class="line" id="L943"></span>
<span class="line" id="L944"><span class="tok-kw">test</span> <span class="tok-str">&quot;small allocations - free in reverse order&quot;</span> {</span>
<span class="line" id="L945">    <span class="tok-kw">var</span> gpa = GeneralPurposeAllocator(test_config){};</span>
<span class="line" id="L946">    <span class="tok-kw">defer</span> std.testing.expect(!gpa.deinit()) <span class="tok-kw">catch</span> <span class="tok-builtin">@panic</span>(<span class="tok-str">&quot;leak&quot;</span>);</span>
<span class="line" id="L947">    <span class="tok-kw">const</span> allocator = gpa.allocator();</span>
<span class="line" id="L948"></span>
<span class="line" id="L949">    <span class="tok-kw">var</span> list = std.ArrayList(*<span class="tok-type">u64</span>).init(std.testing.allocator);</span>
<span class="line" id="L950">    <span class="tok-kw">defer</span> list.deinit();</span>
<span class="line" id="L951"></span>
<span class="line" id="L952">    <span class="tok-kw">var</span> i: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L953">    <span class="tok-kw">while</span> (i &lt; <span class="tok-number">513</span>) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L954">        <span class="tok-kw">const</span> ptr = <span class="tok-kw">try</span> allocator.create(<span class="tok-type">u64</span>);</span>
<span class="line" id="L955">        <span class="tok-kw">try</span> list.append(ptr);</span>
<span class="line" id="L956">    }</span>
<span class="line" id="L957"></span>
<span class="line" id="L958">    <span class="tok-kw">while</span> (list.popOrNull()) |ptr| {</span>
<span class="line" id="L959">        allocator.destroy(ptr);</span>
<span class="line" id="L960">    }</span>
<span class="line" id="L961">}</span>
<span class="line" id="L962"></span>
<span class="line" id="L963"><span class="tok-kw">test</span> <span class="tok-str">&quot;large allocations&quot;</span> {</span>
<span class="line" id="L964">    <span class="tok-kw">var</span> gpa = GeneralPurposeAllocator(test_config){};</span>
<span class="line" id="L965">    <span class="tok-kw">defer</span> std.testing.expect(!gpa.deinit()) <span class="tok-kw">catch</span> <span class="tok-builtin">@panic</span>(<span class="tok-str">&quot;leak&quot;</span>);</span>
<span class="line" id="L966">    <span class="tok-kw">const</span> allocator = gpa.allocator();</span>
<span class="line" id="L967"></span>
<span class="line" id="L968">    <span class="tok-kw">const</span> ptr1 = <span class="tok-kw">try</span> allocator.alloc(<span class="tok-type">u64</span>, <span class="tok-number">42768</span>);</span>
<span class="line" id="L969">    <span class="tok-kw">const</span> ptr2 = <span class="tok-kw">try</span> allocator.alloc(<span class="tok-type">u64</span>, <span class="tok-number">52768</span>);</span>
<span class="line" id="L970">    allocator.free(ptr1);</span>
<span class="line" id="L971">    <span class="tok-kw">const</span> ptr3 = <span class="tok-kw">try</span> allocator.alloc(<span class="tok-type">u64</span>, <span class="tok-number">62768</span>);</span>
<span class="line" id="L972">    allocator.free(ptr3);</span>
<span class="line" id="L973">    allocator.free(ptr2);</span>
<span class="line" id="L974">}</span>
<span class="line" id="L975"></span>
<span class="line" id="L976"><span class="tok-kw">test</span> <span class="tok-str">&quot;realloc&quot;</span> {</span>
<span class="line" id="L977">    <span class="tok-kw">var</span> gpa = GeneralPurposeAllocator(test_config){};</span>
<span class="line" id="L978">    <span class="tok-kw">defer</span> std.testing.expect(!gpa.deinit()) <span class="tok-kw">catch</span> <span class="tok-builtin">@panic</span>(<span class="tok-str">&quot;leak&quot;</span>);</span>
<span class="line" id="L979">    <span class="tok-kw">const</span> allocator = gpa.allocator();</span>
<span class="line" id="L980"></span>
<span class="line" id="L981">    <span class="tok-kw">var</span> slice = <span class="tok-kw">try</span> allocator.alignedAlloc(<span class="tok-type">u8</span>, <span class="tok-builtin">@alignOf</span>(<span class="tok-type">u32</span>), <span class="tok-number">1</span>);</span>
<span class="line" id="L982">    <span class="tok-kw">defer</span> allocator.free(slice);</span>
<span class="line" id="L983">    slice[<span class="tok-number">0</span>] = <span class="tok-number">0x12</span>;</span>
<span class="line" id="L984"></span>
<span class="line" id="L985">    <span class="tok-comment">// This reallocation should keep its pointer address.</span>
</span>
<span class="line" id="L986">    <span class="tok-kw">const</span> old_slice = slice;</span>
<span class="line" id="L987">    slice = <span class="tok-kw">try</span> allocator.realloc(slice, <span class="tok-number">2</span>);</span>
<span class="line" id="L988">    <span class="tok-kw">try</span> std.testing.expect(old_slice.ptr == slice.ptr);</span>
<span class="line" id="L989">    <span class="tok-kw">try</span> std.testing.expect(slice[<span class="tok-number">0</span>] == <span class="tok-number">0x12</span>);</span>
<span class="line" id="L990">    slice[<span class="tok-number">1</span>] = <span class="tok-number">0x34</span>;</span>
<span class="line" id="L991"></span>
<span class="line" id="L992">    <span class="tok-comment">// This requires upgrading to a larger size class</span>
</span>
<span class="line" id="L993">    slice = <span class="tok-kw">try</span> allocator.realloc(slice, <span class="tok-number">17</span>);</span>
<span class="line" id="L994">    <span class="tok-kw">try</span> std.testing.expect(slice[<span class="tok-number">0</span>] == <span class="tok-number">0x12</span>);</span>
<span class="line" id="L995">    <span class="tok-kw">try</span> std.testing.expect(slice[<span class="tok-number">1</span>] == <span class="tok-number">0x34</span>);</span>
<span class="line" id="L996">}</span>
<span class="line" id="L997"></span>
<span class="line" id="L998"><span class="tok-kw">test</span> <span class="tok-str">&quot;shrink&quot;</span> {</span>
<span class="line" id="L999">    <span class="tok-kw">var</span> gpa = GeneralPurposeAllocator(test_config){};</span>
<span class="line" id="L1000">    <span class="tok-kw">defer</span> std.testing.expect(!gpa.deinit()) <span class="tok-kw">catch</span> <span class="tok-builtin">@panic</span>(<span class="tok-str">&quot;leak&quot;</span>);</span>
<span class="line" id="L1001">    <span class="tok-kw">const</span> allocator = gpa.allocator();</span>
<span class="line" id="L1002"></span>
<span class="line" id="L1003">    <span class="tok-kw">var</span> slice = <span class="tok-kw">try</span> allocator.alloc(<span class="tok-type">u8</span>, <span class="tok-number">20</span>);</span>
<span class="line" id="L1004">    <span class="tok-kw">defer</span> allocator.free(slice);</span>
<span class="line" id="L1005"></span>
<span class="line" id="L1006">    mem.set(<span class="tok-type">u8</span>, slice, <span class="tok-number">0x11</span>);</span>
<span class="line" id="L1007"></span>
<span class="line" id="L1008">    slice = allocator.shrink(slice, <span class="tok-number">17</span>);</span>
<span class="line" id="L1009"></span>
<span class="line" id="L1010">    <span class="tok-kw">for</span> (slice) |b| {</span>
<span class="line" id="L1011">        <span class="tok-kw">try</span> std.testing.expect(b == <span class="tok-number">0x11</span>);</span>
<span class="line" id="L1012">    }</span>
<span class="line" id="L1013"></span>
<span class="line" id="L1014">    slice = allocator.shrink(slice, <span class="tok-number">16</span>);</span>
<span class="line" id="L1015"></span>
<span class="line" id="L1016">    <span class="tok-kw">for</span> (slice) |b| {</span>
<span class="line" id="L1017">        <span class="tok-kw">try</span> std.testing.expect(b == <span class="tok-number">0x11</span>);</span>
<span class="line" id="L1018">    }</span>
<span class="line" id="L1019">}</span>
<span class="line" id="L1020"></span>
<span class="line" id="L1021"><span class="tok-kw">test</span> <span class="tok-str">&quot;large object - grow&quot;</span> {</span>
<span class="line" id="L1022">    <span class="tok-kw">var</span> gpa = GeneralPurposeAllocator(test_config){};</span>
<span class="line" id="L1023">    <span class="tok-kw">defer</span> std.testing.expect(!gpa.deinit()) <span class="tok-kw">catch</span> <span class="tok-builtin">@panic</span>(<span class="tok-str">&quot;leak&quot;</span>);</span>
<span class="line" id="L1024">    <span class="tok-kw">const</span> allocator = gpa.allocator();</span>
<span class="line" id="L1025"></span>
<span class="line" id="L1026">    <span class="tok-kw">var</span> slice1 = <span class="tok-kw">try</span> allocator.alloc(<span class="tok-type">u8</span>, page_size * <span class="tok-number">2</span> - <span class="tok-number">20</span>);</span>
<span class="line" id="L1027">    <span class="tok-kw">defer</span> allocator.free(slice1);</span>
<span class="line" id="L1028"></span>
<span class="line" id="L1029">    <span class="tok-kw">const</span> old = slice1;</span>
<span class="line" id="L1030">    slice1 = <span class="tok-kw">try</span> allocator.realloc(slice1, page_size * <span class="tok-number">2</span> - <span class="tok-number">10</span>);</span>
<span class="line" id="L1031">    <span class="tok-kw">try</span> std.testing.expect(slice1.ptr == old.ptr);</span>
<span class="line" id="L1032"></span>
<span class="line" id="L1033">    slice1 = <span class="tok-kw">try</span> allocator.realloc(slice1, page_size * <span class="tok-number">2</span>);</span>
<span class="line" id="L1034">    <span class="tok-kw">try</span> std.testing.expect(slice1.ptr == old.ptr);</span>
<span class="line" id="L1035"></span>
<span class="line" id="L1036">    slice1 = <span class="tok-kw">try</span> allocator.realloc(slice1, page_size * <span class="tok-number">2</span> + <span class="tok-number">1</span>);</span>
<span class="line" id="L1037">}</span>
<span class="line" id="L1038"></span>
<span class="line" id="L1039"><span class="tok-kw">test</span> <span class="tok-str">&quot;realloc small object to large object&quot;</span> {</span>
<span class="line" id="L1040">    <span class="tok-kw">var</span> gpa = GeneralPurposeAllocator(test_config){};</span>
<span class="line" id="L1041">    <span class="tok-kw">defer</span> std.testing.expect(!gpa.deinit()) <span class="tok-kw">catch</span> <span class="tok-builtin">@panic</span>(<span class="tok-str">&quot;leak&quot;</span>);</span>
<span class="line" id="L1042">    <span class="tok-kw">const</span> allocator = gpa.allocator();</span>
<span class="line" id="L1043"></span>
<span class="line" id="L1044">    <span class="tok-kw">var</span> slice = <span class="tok-kw">try</span> allocator.alloc(<span class="tok-type">u8</span>, <span class="tok-number">70</span>);</span>
<span class="line" id="L1045">    <span class="tok-kw">defer</span> allocator.free(slice);</span>
<span class="line" id="L1046">    slice[<span class="tok-number">0</span>] = <span class="tok-number">0x12</span>;</span>
<span class="line" id="L1047">    slice[<span class="tok-number">60</span>] = <span class="tok-number">0x34</span>;</span>
<span class="line" id="L1048"></span>
<span class="line" id="L1049">    <span class="tok-comment">// This requires upgrading to a large object</span>
</span>
<span class="line" id="L1050">    <span class="tok-kw">const</span> large_object_size = page_size * <span class="tok-number">2</span> + <span class="tok-number">50</span>;</span>
<span class="line" id="L1051">    slice = <span class="tok-kw">try</span> allocator.realloc(slice, large_object_size);</span>
<span class="line" id="L1052">    <span class="tok-kw">try</span> std.testing.expect(slice[<span class="tok-number">0</span>] == <span class="tok-number">0x12</span>);</span>
<span class="line" id="L1053">    <span class="tok-kw">try</span> std.testing.expect(slice[<span class="tok-number">60</span>] == <span class="tok-number">0x34</span>);</span>
<span class="line" id="L1054">}</span>
<span class="line" id="L1055"></span>
<span class="line" id="L1056"><span class="tok-kw">test</span> <span class="tok-str">&quot;shrink large object to large object&quot;</span> {</span>
<span class="line" id="L1057">    <span class="tok-kw">var</span> gpa = GeneralPurposeAllocator(test_config){};</span>
<span class="line" id="L1058">    <span class="tok-kw">defer</span> std.testing.expect(!gpa.deinit()) <span class="tok-kw">catch</span> <span class="tok-builtin">@panic</span>(<span class="tok-str">&quot;leak&quot;</span>);</span>
<span class="line" id="L1059">    <span class="tok-kw">const</span> allocator = gpa.allocator();</span>
<span class="line" id="L1060"></span>
<span class="line" id="L1061">    <span class="tok-kw">var</span> slice = <span class="tok-kw">try</span> allocator.alloc(<span class="tok-type">u8</span>, page_size * <span class="tok-number">2</span> + <span class="tok-number">50</span>);</span>
<span class="line" id="L1062">    <span class="tok-kw">defer</span> allocator.free(slice);</span>
<span class="line" id="L1063">    slice[<span class="tok-number">0</span>] = <span class="tok-number">0x12</span>;</span>
<span class="line" id="L1064">    slice[<span class="tok-number">60</span>] = <span class="tok-number">0x34</span>;</span>
<span class="line" id="L1065"></span>
<span class="line" id="L1066">    slice = allocator.resize(slice, page_size * <span class="tok-number">2</span> + <span class="tok-number">1</span>) <span class="tok-kw">orelse</span> <span class="tok-kw">return</span>;</span>
<span class="line" id="L1067">    <span class="tok-kw">try</span> std.testing.expect(slice[<span class="tok-number">0</span>] == <span class="tok-number">0x12</span>);</span>
<span class="line" id="L1068">    <span class="tok-kw">try</span> std.testing.expect(slice[<span class="tok-number">60</span>] == <span class="tok-number">0x34</span>);</span>
<span class="line" id="L1069"></span>
<span class="line" id="L1070">    slice = allocator.shrink(slice, page_size * <span class="tok-number">2</span> + <span class="tok-number">1</span>);</span>
<span class="line" id="L1071">    <span class="tok-kw">try</span> std.testing.expect(slice[<span class="tok-number">0</span>] == <span class="tok-number">0x12</span>);</span>
<span class="line" id="L1072">    <span class="tok-kw">try</span> std.testing.expect(slice[<span class="tok-number">60</span>] == <span class="tok-number">0x34</span>);</span>
<span class="line" id="L1073"></span>
<span class="line" id="L1074">    slice = <span class="tok-kw">try</span> allocator.realloc(slice, page_size * <span class="tok-number">2</span>);</span>
<span class="line" id="L1075">    <span class="tok-kw">try</span> std.testing.expect(slice[<span class="tok-number">0</span>] == <span class="tok-number">0x12</span>);</span>
<span class="line" id="L1076">    <span class="tok-kw">try</span> std.testing.expect(slice[<span class="tok-number">60</span>] == <span class="tok-number">0x34</span>);</span>
<span class="line" id="L1077">}</span>
<span class="line" id="L1078"></span>
<span class="line" id="L1079"><span class="tok-kw">test</span> <span class="tok-str">&quot;shrink large object to large object with larger alignment&quot;</span> {</span>
<span class="line" id="L1080">    <span class="tok-kw">var</span> gpa = GeneralPurposeAllocator(test_config){};</span>
<span class="line" id="L1081">    <span class="tok-kw">defer</span> std.testing.expect(!gpa.deinit()) <span class="tok-kw">catch</span> <span class="tok-builtin">@panic</span>(<span class="tok-str">&quot;leak&quot;</span>);</span>
<span class="line" id="L1082">    <span class="tok-kw">const</span> allocator = gpa.allocator();</span>
<span class="line" id="L1083"></span>
<span class="line" id="L1084">    <span class="tok-kw">var</span> debug_buffer: [<span class="tok-number">1000</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L1085">    <span class="tok-kw">var</span> fba = std.heap.FixedBufferAllocator.init(&amp;debug_buffer);</span>
<span class="line" id="L1086">    <span class="tok-kw">const</span> debug_allocator = fba.allocator();</span>
<span class="line" id="L1087"></span>
<span class="line" id="L1088">    <span class="tok-kw">const</span> alloc_size = page_size * <span class="tok-number">2</span> + <span class="tok-number">50</span>;</span>
<span class="line" id="L1089">    <span class="tok-kw">var</span> slice = <span class="tok-kw">try</span> allocator.alignedAlloc(<span class="tok-type">u8</span>, <span class="tok-number">16</span>, alloc_size);</span>
<span class="line" id="L1090">    <span class="tok-kw">defer</span> allocator.free(slice);</span>
<span class="line" id="L1091"></span>
<span class="line" id="L1092">    <span class="tok-kw">const</span> big_alignment: <span class="tok-type">usize</span> = <span class="tok-kw">switch</span> (builtin.os.tag) {</span>
<span class="line" id="L1093">        .windows =&gt; page_size * <span class="tok-number">32</span>, <span class="tok-comment">// Windows aligns to 64K.</span>
</span>
<span class="line" id="L1094">        <span class="tok-kw">else</span> =&gt; page_size * <span class="tok-number">2</span>,</span>
<span class="line" id="L1095">    };</span>
<span class="line" id="L1096">    <span class="tok-comment">// This loop allocates until we find a page that is not aligned to the big</span>
</span>
<span class="line" id="L1097">    <span class="tok-comment">// alignment. Then we shrink the allocation after the loop, but increase the</span>
</span>
<span class="line" id="L1098">    <span class="tok-comment">// alignment to the higher one, that we know will force it to realloc.</span>
</span>
<span class="line" id="L1099">    <span class="tok-kw">var</span> stuff_to_free = std.ArrayList([]<span class="tok-kw">align</span>(<span class="tok-number">16</span>) <span class="tok-type">u8</span>).init(debug_allocator);</span>
<span class="line" id="L1100">    <span class="tok-kw">while</span> (mem.isAligned(<span class="tok-builtin">@ptrToInt</span>(slice.ptr), big_alignment)) {</span>
<span class="line" id="L1101">        <span class="tok-kw">try</span> stuff_to_free.append(slice);</span>
<span class="line" id="L1102">        slice = <span class="tok-kw">try</span> allocator.alignedAlloc(<span class="tok-type">u8</span>, <span class="tok-number">16</span>, alloc_size);</span>
<span class="line" id="L1103">    }</span>
<span class="line" id="L1104">    <span class="tok-kw">while</span> (stuff_to_free.popOrNull()) |item| {</span>
<span class="line" id="L1105">        allocator.free(item);</span>
<span class="line" id="L1106">    }</span>
<span class="line" id="L1107">    slice[<span class="tok-number">0</span>] = <span class="tok-number">0x12</span>;</span>
<span class="line" id="L1108">    slice[<span class="tok-number">60</span>] = <span class="tok-number">0x34</span>;</span>
<span class="line" id="L1109"></span>
<span class="line" id="L1110">    slice = <span class="tok-kw">try</span> allocator.reallocAdvanced(slice, big_alignment, alloc_size / <span class="tok-number">2</span>, .exact);</span>
<span class="line" id="L1111">    <span class="tok-kw">try</span> std.testing.expect(slice[<span class="tok-number">0</span>] == <span class="tok-number">0x12</span>);</span>
<span class="line" id="L1112">    <span class="tok-kw">try</span> std.testing.expect(slice[<span class="tok-number">60</span>] == <span class="tok-number">0x34</span>);</span>
<span class="line" id="L1113">}</span>
<span class="line" id="L1114"></span>
<span class="line" id="L1115"><span class="tok-kw">test</span> <span class="tok-str">&quot;realloc large object to small object&quot;</span> {</span>
<span class="line" id="L1116">    <span class="tok-kw">var</span> gpa = GeneralPurposeAllocator(test_config){};</span>
<span class="line" id="L1117">    <span class="tok-kw">defer</span> std.testing.expect(!gpa.deinit()) <span class="tok-kw">catch</span> <span class="tok-builtin">@panic</span>(<span class="tok-str">&quot;leak&quot;</span>);</span>
<span class="line" id="L1118">    <span class="tok-kw">const</span> allocator = gpa.allocator();</span>
<span class="line" id="L1119"></span>
<span class="line" id="L1120">    <span class="tok-kw">var</span> slice = <span class="tok-kw">try</span> allocator.alloc(<span class="tok-type">u8</span>, page_size * <span class="tok-number">2</span> + <span class="tok-number">50</span>);</span>
<span class="line" id="L1121">    <span class="tok-kw">defer</span> allocator.free(slice);</span>
<span class="line" id="L1122">    slice[<span class="tok-number">0</span>] = <span class="tok-number">0x12</span>;</span>
<span class="line" id="L1123">    slice[<span class="tok-number">16</span>] = <span class="tok-number">0x34</span>;</span>
<span class="line" id="L1124"></span>
<span class="line" id="L1125">    slice = <span class="tok-kw">try</span> allocator.realloc(slice, <span class="tok-number">19</span>);</span>
<span class="line" id="L1126">    <span class="tok-kw">try</span> std.testing.expect(slice[<span class="tok-number">0</span>] == <span class="tok-number">0x12</span>);</span>
<span class="line" id="L1127">    <span class="tok-kw">try</span> std.testing.expect(slice[<span class="tok-number">16</span>] == <span class="tok-number">0x34</span>);</span>
<span class="line" id="L1128">}</span>
<span class="line" id="L1129"></span>
<span class="line" id="L1130"><span class="tok-kw">test</span> <span class="tok-str">&quot;overrideable mutexes&quot;</span> {</span>
<span class="line" id="L1131">    <span class="tok-kw">var</span> gpa = GeneralPurposeAllocator(.{ .MutexType = std.Thread.Mutex }){</span>
<span class="line" id="L1132">        .backing_allocator = std.testing.allocator,</span>
<span class="line" id="L1133">        .mutex = std.Thread.Mutex{},</span>
<span class="line" id="L1134">    };</span>
<span class="line" id="L1135">    <span class="tok-kw">defer</span> std.testing.expect(!gpa.deinit()) <span class="tok-kw">catch</span> <span class="tok-builtin">@panic</span>(<span class="tok-str">&quot;leak&quot;</span>);</span>
<span class="line" id="L1136">    <span class="tok-kw">const</span> allocator = gpa.allocator();</span>
<span class="line" id="L1137"></span>
<span class="line" id="L1138">    <span class="tok-kw">const</span> ptr = <span class="tok-kw">try</span> allocator.create(<span class="tok-type">i32</span>);</span>
<span class="line" id="L1139">    <span class="tok-kw">defer</span> allocator.destroy(ptr);</span>
<span class="line" id="L1140">}</span>
<span class="line" id="L1141"></span>
<span class="line" id="L1142"><span class="tok-kw">test</span> <span class="tok-str">&quot;non-page-allocator backing allocator&quot;</span> {</span>
<span class="line" id="L1143">    <span class="tok-kw">var</span> gpa = GeneralPurposeAllocator(.{}){ .backing_allocator = std.testing.allocator };</span>
<span class="line" id="L1144">    <span class="tok-kw">defer</span> std.testing.expect(!gpa.deinit()) <span class="tok-kw">catch</span> <span class="tok-builtin">@panic</span>(<span class="tok-str">&quot;leak&quot;</span>);</span>
<span class="line" id="L1145">    <span class="tok-kw">const</span> allocator = gpa.allocator();</span>
<span class="line" id="L1146"></span>
<span class="line" id="L1147">    <span class="tok-kw">const</span> ptr = <span class="tok-kw">try</span> allocator.create(<span class="tok-type">i32</span>);</span>
<span class="line" id="L1148">    <span class="tok-kw">defer</span> allocator.destroy(ptr);</span>
<span class="line" id="L1149">}</span>
<span class="line" id="L1150"></span>
<span class="line" id="L1151"><span class="tok-kw">test</span> <span class="tok-str">&quot;realloc large object to larger alignment&quot;</span> {</span>
<span class="line" id="L1152">    <span class="tok-kw">var</span> gpa = GeneralPurposeAllocator(test_config){};</span>
<span class="line" id="L1153">    <span class="tok-kw">defer</span> std.testing.expect(!gpa.deinit()) <span class="tok-kw">catch</span> <span class="tok-builtin">@panic</span>(<span class="tok-str">&quot;leak&quot;</span>);</span>
<span class="line" id="L1154">    <span class="tok-kw">const</span> allocator = gpa.allocator();</span>
<span class="line" id="L1155"></span>
<span class="line" id="L1156">    <span class="tok-kw">var</span> debug_buffer: [<span class="tok-number">1000</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L1157">    <span class="tok-kw">var</span> fba = std.heap.FixedBufferAllocator.init(&amp;debug_buffer);</span>
<span class="line" id="L1158">    <span class="tok-kw">const</span> debug_allocator = fba.allocator();</span>
<span class="line" id="L1159"></span>
<span class="line" id="L1160">    <span class="tok-kw">var</span> slice = <span class="tok-kw">try</span> allocator.alignedAlloc(<span class="tok-type">u8</span>, <span class="tok-number">16</span>, page_size * <span class="tok-number">2</span> + <span class="tok-number">50</span>);</span>
<span class="line" id="L1161">    <span class="tok-kw">defer</span> allocator.free(slice);</span>
<span class="line" id="L1162"></span>
<span class="line" id="L1163">    <span class="tok-kw">const</span> big_alignment: <span class="tok-type">usize</span> = <span class="tok-kw">switch</span> (builtin.os.tag) {</span>
<span class="line" id="L1164">        .windows =&gt; page_size * <span class="tok-number">32</span>, <span class="tok-comment">// Windows aligns to 64K.</span>
</span>
<span class="line" id="L1165">        <span class="tok-kw">else</span> =&gt; page_size * <span class="tok-number">2</span>,</span>
<span class="line" id="L1166">    };</span>
<span class="line" id="L1167">    <span class="tok-comment">// This loop allocates until we find a page that is not aligned to the big alignment.</span>
</span>
<span class="line" id="L1168">    <span class="tok-kw">var</span> stuff_to_free = std.ArrayList([]<span class="tok-kw">align</span>(<span class="tok-number">16</span>) <span class="tok-type">u8</span>).init(debug_allocator);</span>
<span class="line" id="L1169">    <span class="tok-kw">while</span> (mem.isAligned(<span class="tok-builtin">@ptrToInt</span>(slice.ptr), big_alignment)) {</span>
<span class="line" id="L1170">        <span class="tok-kw">try</span> stuff_to_free.append(slice);</span>
<span class="line" id="L1171">        slice = <span class="tok-kw">try</span> allocator.alignedAlloc(<span class="tok-type">u8</span>, <span class="tok-number">16</span>, page_size * <span class="tok-number">2</span> + <span class="tok-number">50</span>);</span>
<span class="line" id="L1172">    }</span>
<span class="line" id="L1173">    <span class="tok-kw">while</span> (stuff_to_free.popOrNull()) |item| {</span>
<span class="line" id="L1174">        allocator.free(item);</span>
<span class="line" id="L1175">    }</span>
<span class="line" id="L1176">    slice[<span class="tok-number">0</span>] = <span class="tok-number">0x12</span>;</span>
<span class="line" id="L1177">    slice[<span class="tok-number">16</span>] = <span class="tok-number">0x34</span>;</span>
<span class="line" id="L1178"></span>
<span class="line" id="L1179">    slice = <span class="tok-kw">try</span> allocator.reallocAdvanced(slice, <span class="tok-number">32</span>, page_size * <span class="tok-number">2</span> + <span class="tok-number">100</span>, .exact);</span>
<span class="line" id="L1180">    <span class="tok-kw">try</span> std.testing.expect(slice[<span class="tok-number">0</span>] == <span class="tok-number">0x12</span>);</span>
<span class="line" id="L1181">    <span class="tok-kw">try</span> std.testing.expect(slice[<span class="tok-number">16</span>] == <span class="tok-number">0x34</span>);</span>
<span class="line" id="L1182"></span>
<span class="line" id="L1183">    slice = <span class="tok-kw">try</span> allocator.reallocAdvanced(slice, <span class="tok-number">32</span>, page_size * <span class="tok-number">2</span> + <span class="tok-number">25</span>, .exact);</span>
<span class="line" id="L1184">    <span class="tok-kw">try</span> std.testing.expect(slice[<span class="tok-number">0</span>] == <span class="tok-number">0x12</span>);</span>
<span class="line" id="L1185">    <span class="tok-kw">try</span> std.testing.expect(slice[<span class="tok-number">16</span>] == <span class="tok-number">0x34</span>);</span>
<span class="line" id="L1186"></span>
<span class="line" id="L1187">    slice = <span class="tok-kw">try</span> allocator.reallocAdvanced(slice, big_alignment, page_size * <span class="tok-number">2</span> + <span class="tok-number">100</span>, .exact);</span>
<span class="line" id="L1188">    <span class="tok-kw">try</span> std.testing.expect(slice[<span class="tok-number">0</span>] == <span class="tok-number">0x12</span>);</span>
<span class="line" id="L1189">    <span class="tok-kw">try</span> std.testing.expect(slice[<span class="tok-number">16</span>] == <span class="tok-number">0x34</span>);</span>
<span class="line" id="L1190">}</span>
<span class="line" id="L1191"></span>
<span class="line" id="L1192"><span class="tok-kw">test</span> <span class="tok-str">&quot;large object shrinks to small but allocation fails during shrink&quot;</span> {</span>
<span class="line" id="L1193">    <span class="tok-kw">var</span> failing_allocator = std.testing.FailingAllocator.init(std.heap.page_allocator, <span class="tok-number">3</span>);</span>
<span class="line" id="L1194">    <span class="tok-kw">var</span> gpa = GeneralPurposeAllocator(.{}){ .backing_allocator = failing_allocator.allocator() };</span>
<span class="line" id="L1195">    <span class="tok-kw">defer</span> std.testing.expect(!gpa.deinit()) <span class="tok-kw">catch</span> <span class="tok-builtin">@panic</span>(<span class="tok-str">&quot;leak&quot;</span>);</span>
<span class="line" id="L1196">    <span class="tok-kw">const</span> allocator = gpa.allocator();</span>
<span class="line" id="L1197"></span>
<span class="line" id="L1198">    <span class="tok-kw">var</span> slice = <span class="tok-kw">try</span> allocator.alloc(<span class="tok-type">u8</span>, page_size * <span class="tok-number">2</span> + <span class="tok-number">50</span>);</span>
<span class="line" id="L1199">    <span class="tok-kw">defer</span> allocator.free(slice);</span>
<span class="line" id="L1200">    slice[<span class="tok-number">0</span>] = <span class="tok-number">0x12</span>;</span>
<span class="line" id="L1201">    slice[<span class="tok-number">3</span>] = <span class="tok-number">0x34</span>;</span>
<span class="line" id="L1202"></span>
<span class="line" id="L1203">    <span class="tok-comment">// Next allocation will fail in the backing allocator of the GeneralPurposeAllocator</span>
</span>
<span class="line" id="L1204"></span>
<span class="line" id="L1205">    slice = allocator.shrink(slice, <span class="tok-number">4</span>);</span>
<span class="line" id="L1206">    <span class="tok-kw">try</span> std.testing.expect(slice[<span class="tok-number">0</span>] == <span class="tok-number">0x12</span>);</span>
<span class="line" id="L1207">    <span class="tok-kw">try</span> std.testing.expect(slice[<span class="tok-number">3</span>] == <span class="tok-number">0x34</span>);</span>
<span class="line" id="L1208">}</span>
<span class="line" id="L1209"></span>
<span class="line" id="L1210"><span class="tok-kw">test</span> <span class="tok-str">&quot;objects of size 1024 and 2048&quot;</span> {</span>
<span class="line" id="L1211">    <span class="tok-kw">var</span> gpa = GeneralPurposeAllocator(test_config){};</span>
<span class="line" id="L1212">    <span class="tok-kw">defer</span> std.testing.expect(!gpa.deinit()) <span class="tok-kw">catch</span> <span class="tok-builtin">@panic</span>(<span class="tok-str">&quot;leak&quot;</span>);</span>
<span class="line" id="L1213">    <span class="tok-kw">const</span> allocator = gpa.allocator();</span>
<span class="line" id="L1214"></span>
<span class="line" id="L1215">    <span class="tok-kw">const</span> slice = <span class="tok-kw">try</span> allocator.alloc(<span class="tok-type">u8</span>, <span class="tok-number">1025</span>);</span>
<span class="line" id="L1216">    <span class="tok-kw">const</span> slice2 = <span class="tok-kw">try</span> allocator.alloc(<span class="tok-type">u8</span>, <span class="tok-number">3000</span>);</span>
<span class="line" id="L1217"></span>
<span class="line" id="L1218">    allocator.free(slice);</span>
<span class="line" id="L1219">    allocator.free(slice2);</span>
<span class="line" id="L1220">}</span>
<span class="line" id="L1221"></span>
<span class="line" id="L1222"><span class="tok-kw">test</span> <span class="tok-str">&quot;setting a memory cap&quot;</span> {</span>
<span class="line" id="L1223">    <span class="tok-kw">var</span> gpa = GeneralPurposeAllocator(.{ .enable_memory_limit = <span class="tok-null">true</span> }){};</span>
<span class="line" id="L1224">    <span class="tok-kw">defer</span> std.testing.expect(!gpa.deinit()) <span class="tok-kw">catch</span> <span class="tok-builtin">@panic</span>(<span class="tok-str">&quot;leak&quot;</span>);</span>
<span class="line" id="L1225">    <span class="tok-kw">const</span> allocator = gpa.allocator();</span>
<span class="line" id="L1226"></span>
<span class="line" id="L1227">    gpa.setRequestedMemoryLimit(<span class="tok-number">1010</span>);</span>
<span class="line" id="L1228"></span>
<span class="line" id="L1229">    <span class="tok-kw">const</span> small = <span class="tok-kw">try</span> allocator.create(<span class="tok-type">i32</span>);</span>
<span class="line" id="L1230">    <span class="tok-kw">try</span> std.testing.expect(gpa.total_requested_bytes == <span class="tok-number">4</span>);</span>
<span class="line" id="L1231"></span>
<span class="line" id="L1232">    <span class="tok-kw">const</span> big = <span class="tok-kw">try</span> allocator.alloc(<span class="tok-type">u8</span>, <span class="tok-number">1000</span>);</span>
<span class="line" id="L1233">    <span class="tok-kw">try</span> std.testing.expect(gpa.total_requested_bytes == <span class="tok-number">1004</span>);</span>
<span class="line" id="L1234"></span>
<span class="line" id="L1235">    <span class="tok-kw">try</span> std.testing.expectError(<span class="tok-kw">error</span>.OutOfMemory, allocator.create(<span class="tok-type">u64</span>));</span>
<span class="line" id="L1236"></span>
<span class="line" id="L1237">    allocator.destroy(small);</span>
<span class="line" id="L1238">    <span class="tok-kw">try</span> std.testing.expect(gpa.total_requested_bytes == <span class="tok-number">1000</span>);</span>
<span class="line" id="L1239"></span>
<span class="line" id="L1240">    allocator.free(big);</span>
<span class="line" id="L1241">    <span class="tok-kw">try</span> std.testing.expect(gpa.total_requested_bytes == <span class="tok-number">0</span>);</span>
<span class="line" id="L1242"></span>
<span class="line" id="L1243">    <span class="tok-kw">const</span> exact = <span class="tok-kw">try</span> allocator.alloc(<span class="tok-type">u8</span>, <span class="tok-number">1010</span>);</span>
<span class="line" id="L1244">    <span class="tok-kw">try</span> std.testing.expect(gpa.total_requested_bytes == <span class="tok-number">1010</span>);</span>
<span class="line" id="L1245">    allocator.free(exact);</span>
<span class="line" id="L1246">}</span>
<span class="line" id="L1247"></span>
<span class="line" id="L1248"><span class="tok-kw">test</span> <span class="tok-str">&quot;double frees&quot;</span> {</span>
<span class="line" id="L1249">    <span class="tok-comment">// use a GPA to back a GPA to check for leaks of the latter's metadata</span>
</span>
<span class="line" id="L1250">    <span class="tok-kw">var</span> backing_gpa = GeneralPurposeAllocator(.{ .safety = <span class="tok-null">true</span> }){};</span>
<span class="line" id="L1251">    <span class="tok-kw">defer</span> std.testing.expect(!backing_gpa.deinit()) <span class="tok-kw">catch</span> <span class="tok-builtin">@panic</span>(<span class="tok-str">&quot;leak&quot;</span>);</span>
<span class="line" id="L1252"></span>
<span class="line" id="L1253">    <span class="tok-kw">const</span> GPA = GeneralPurposeAllocator(.{ .safety = <span class="tok-null">true</span>, .never_unmap = <span class="tok-null">true</span>, .retain_metadata = <span class="tok-null">true</span> });</span>
<span class="line" id="L1254">    <span class="tok-kw">var</span> gpa = GPA{ .backing_allocator = backing_gpa.allocator() };</span>
<span class="line" id="L1255">    <span class="tok-kw">defer</span> std.testing.expect(!gpa.deinit()) <span class="tok-kw">catch</span> <span class="tok-builtin">@panic</span>(<span class="tok-str">&quot;leak&quot;</span>);</span>
<span class="line" id="L1256">    <span class="tok-kw">const</span> allocator = gpa.allocator();</span>
<span class="line" id="L1257"></span>
<span class="line" id="L1258">    <span class="tok-comment">// detect a small allocation double free, even though bucket is emptied</span>
</span>
<span class="line" id="L1259">    <span class="tok-kw">const</span> index: <span class="tok-type">usize</span> = <span class="tok-number">6</span>;</span>
<span class="line" id="L1260">    <span class="tok-kw">const</span> size_class: <span class="tok-type">usize</span> = <span class="tok-builtin">@as</span>(<span class="tok-type">usize</span>, <span class="tok-number">1</span>) &lt;&lt; <span class="tok-number">6</span>;</span>
<span class="line" id="L1261">    <span class="tok-kw">const</span> small = <span class="tok-kw">try</span> allocator.alloc(<span class="tok-type">u8</span>, size_class);</span>
<span class="line" id="L1262">    <span class="tok-kw">try</span> std.testing.expect(GPA.searchBucket(gpa.buckets[index], <span class="tok-builtin">@ptrToInt</span>(small.ptr)) != <span class="tok-null">null</span>);</span>
<span class="line" id="L1263">    allocator.free(small);</span>
<span class="line" id="L1264">    <span class="tok-kw">try</span> std.testing.expect(GPA.searchBucket(gpa.buckets[index], <span class="tok-builtin">@ptrToInt</span>(small.ptr)) == <span class="tok-null">null</span>);</span>
<span class="line" id="L1265">    <span class="tok-kw">try</span> std.testing.expect(GPA.searchBucket(gpa.empty_buckets, <span class="tok-builtin">@ptrToInt</span>(small.ptr)) != <span class="tok-null">null</span>);</span>
<span class="line" id="L1266"></span>
<span class="line" id="L1267">    <span class="tok-comment">// detect a large allocation double free</span>
</span>
<span class="line" id="L1268">    <span class="tok-kw">const</span> large = <span class="tok-kw">try</span> allocator.alloc(<span class="tok-type">u8</span>, <span class="tok-number">2</span> * page_size);</span>
<span class="line" id="L1269">    <span class="tok-kw">try</span> std.testing.expect(gpa.large_allocations.contains(<span class="tok-builtin">@ptrToInt</span>(large.ptr)));</span>
<span class="line" id="L1270">    <span class="tok-kw">try</span> std.testing.expectEqual(gpa.large_allocations.getEntry(<span class="tok-builtin">@ptrToInt</span>(large.ptr)).?.value_ptr.bytes, large);</span>
<span class="line" id="L1271">    allocator.free(large);</span>
<span class="line" id="L1272">    <span class="tok-kw">try</span> std.testing.expect(gpa.large_allocations.contains(<span class="tok-builtin">@ptrToInt</span>(large.ptr)));</span>
<span class="line" id="L1273">    <span class="tok-kw">try</span> std.testing.expect(gpa.large_allocations.getEntry(<span class="tok-builtin">@ptrToInt</span>(large.ptr)).?.value_ptr.freed);</span>
<span class="line" id="L1274"></span>
<span class="line" id="L1275">    <span class="tok-kw">const</span> normal_small = <span class="tok-kw">try</span> allocator.alloc(<span class="tok-type">u8</span>, size_class);</span>
<span class="line" id="L1276">    <span class="tok-kw">defer</span> allocator.free(normal_small);</span>
<span class="line" id="L1277">    <span class="tok-kw">const</span> normal_large = <span class="tok-kw">try</span> allocator.alloc(<span class="tok-type">u8</span>, <span class="tok-number">2</span> * page_size);</span>
<span class="line" id="L1278">    <span class="tok-kw">defer</span> allocator.free(normal_large);</span>
<span class="line" id="L1279"></span>
<span class="line" id="L1280">    <span class="tok-comment">// check that flushing retained metadata doesn't disturb live allocations</span>
</span>
<span class="line" id="L1281">    gpa.flushRetainedMetadata();</span>
<span class="line" id="L1282">    <span class="tok-kw">try</span> std.testing.expect(gpa.empty_buckets == <span class="tok-null">null</span>);</span>
<span class="line" id="L1283">    <span class="tok-kw">try</span> std.testing.expect(GPA.searchBucket(gpa.buckets[index], <span class="tok-builtin">@ptrToInt</span>(normal_small.ptr)) != <span class="tok-null">null</span>);</span>
<span class="line" id="L1284">    <span class="tok-kw">try</span> std.testing.expect(gpa.large_allocations.contains(<span class="tok-builtin">@ptrToInt</span>(normal_large.ptr)));</span>
<span class="line" id="L1285">    <span class="tok-kw">try</span> std.testing.expect(!gpa.large_allocations.contains(<span class="tok-builtin">@ptrToInt</span>(large.ptr)));</span>
<span class="line" id="L1286">}</span>
<span class="line" id="L1287"></span>
<span class="line" id="L1288"><span class="tok-kw">test</span> <span class="tok-str">&quot;bug 9995 fix, large allocs count requested size not backing size&quot;</span> {</span>
<span class="line" id="L1289">    <span class="tok-comment">// with AtLeast, buffer likely to be larger than requested, especially when shrinking</span>
</span>
<span class="line" id="L1290">    <span class="tok-kw">var</span> gpa = GeneralPurposeAllocator(.{ .enable_memory_limit = <span class="tok-null">true</span> }){};</span>
<span class="line" id="L1291">    <span class="tok-kw">const</span> allocator = gpa.allocator();</span>
<span class="line" id="L1292"></span>
<span class="line" id="L1293">    <span class="tok-kw">var</span> buf = <span class="tok-kw">try</span> allocator.allocAdvanced(<span class="tok-type">u8</span>, <span class="tok-number">1</span>, page_size + <span class="tok-number">1</span>, .at_least);</span>
<span class="line" id="L1294">    <span class="tok-kw">try</span> std.testing.expect(gpa.total_requested_bytes == page_size + <span class="tok-number">1</span>);</span>
<span class="line" id="L1295">    buf = <span class="tok-kw">try</span> allocator.reallocAtLeast(buf, <span class="tok-number">1</span>);</span>
<span class="line" id="L1296">    <span class="tok-kw">try</span> std.testing.expect(gpa.total_requested_bytes == <span class="tok-number">1</span>);</span>
<span class="line" id="L1297">    buf = <span class="tok-kw">try</span> allocator.reallocAtLeast(buf, <span class="tok-number">2</span>);</span>
<span class="line" id="L1298">    <span class="tok-kw">try</span> std.testing.expect(gpa.total_requested_bytes == <span class="tok-number">2</span>);</span>
<span class="line" id="L1299">}</span>
<span class="line" id="L1300"></span>
</code></pre></body>
</html>