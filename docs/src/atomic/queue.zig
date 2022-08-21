<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">    <title>atomic/queue.zig - source view</title>
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
<span class="line" id="L3"><span class="tok-kw">const</span> assert = std.debug.assert;</span>
<span class="line" id="L4"><span class="tok-kw">const</span> expect = std.testing.expect;</span>
<span class="line" id="L5"></span>
<span class="line" id="L6"><span class="tok-comment">/// Many producer, many consumer, non-allocating, thread-safe.</span></span>
<span class="line" id="L7"><span class="tok-comment">/// Uses a mutex to protect access.</span></span>
<span class="line" id="L8"><span class="tok-comment">/// The queue does not manage ownership and the user is responsible to</span></span>
<span class="line" id="L9"><span class="tok-comment">/// manage the storage of the nodes.</span></span>
<span class="line" id="L10"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">Queue</span>(<span class="tok-kw">comptime</span> T: <span class="tok-type">type</span>) <span class="tok-type">type</span> {</span>
<span class="line" id="L11">    <span class="tok-kw">return</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L12">        head: ?*Node,</span>
<span class="line" id="L13">        tail: ?*Node,</span>
<span class="line" id="L14">        mutex: std.Thread.Mutex,</span>
<span class="line" id="L15"></span>
<span class="line" id="L16">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> Self = <span class="tok-builtin">@This</span>();</span>
<span class="line" id="L17">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> Node = std.TailQueue(T).Node;</span>
<span class="line" id="L18"></span>
<span class="line" id="L19">        <span class="tok-comment">/// Initializes a new queue. The queue does not provide a `deinit()`</span></span>
<span class="line" id="L20">        <span class="tok-comment">/// function, so the user must take care of cleaning up the queue elements.</span></span>
<span class="line" id="L21">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">init</span>() Self {</span>
<span class="line" id="L22">            <span class="tok-kw">return</span> Self{</span>
<span class="line" id="L23">                .head = <span class="tok-null">null</span>,</span>
<span class="line" id="L24">                .tail = <span class="tok-null">null</span>,</span>
<span class="line" id="L25">                .mutex = std.Thread.Mutex{},</span>
<span class="line" id="L26">            };</span>
<span class="line" id="L27">        }</span>
<span class="line" id="L28"></span>
<span class="line" id="L29">        <span class="tok-comment">/// Appends `node` to the queue.</span></span>
<span class="line" id="L30">        <span class="tok-comment">/// The lifetime of `node` must be longer than lifetime of queue.</span></span>
<span class="line" id="L31">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">put</span>(self: *Self, node: *Node) <span class="tok-type">void</span> {</span>
<span class="line" id="L32">            node.next = <span class="tok-null">null</span>;</span>
<span class="line" id="L33"></span>
<span class="line" id="L34">            self.mutex.lock();</span>
<span class="line" id="L35">            <span class="tok-kw">defer</span> self.mutex.unlock();</span>
<span class="line" id="L36"></span>
<span class="line" id="L37">            node.prev = self.tail;</span>
<span class="line" id="L38">            self.tail = node;</span>
<span class="line" id="L39">            <span class="tok-kw">if</span> (node.prev) |prev_tail| {</span>
<span class="line" id="L40">                prev_tail.next = node;</span>
<span class="line" id="L41">            } <span class="tok-kw">else</span> {</span>
<span class="line" id="L42">                assert(self.head == <span class="tok-null">null</span>);</span>
<span class="line" id="L43">                self.head = node;</span>
<span class="line" id="L44">            }</span>
<span class="line" id="L45">        }</span>
<span class="line" id="L46"></span>
<span class="line" id="L47">        <span class="tok-comment">/// Gets a previously inserted node or returns `null` if there is none.</span></span>
<span class="line" id="L48">        <span class="tok-comment">/// It is safe to `get()` a node from the queue while another thread tries</span></span>
<span class="line" id="L49">        <span class="tok-comment">/// to `remove()` the same node at the same time.</span></span>
<span class="line" id="L50">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">get</span>(self: *Self) ?*Node {</span>
<span class="line" id="L51">            self.mutex.lock();</span>
<span class="line" id="L52">            <span class="tok-kw">defer</span> self.mutex.unlock();</span>
<span class="line" id="L53"></span>
<span class="line" id="L54">            <span class="tok-kw">const</span> head = self.head <span class="tok-kw">orelse</span> <span class="tok-kw">return</span> <span class="tok-null">null</span>;</span>
<span class="line" id="L55">            self.head = head.next;</span>
<span class="line" id="L56">            <span class="tok-kw">if</span> (head.next) |new_head| {</span>
<span class="line" id="L57">                new_head.prev = <span class="tok-null">null</span>;</span>
<span class="line" id="L58">            } <span class="tok-kw">else</span> {</span>
<span class="line" id="L59">                self.tail = <span class="tok-null">null</span>;</span>
<span class="line" id="L60">            }</span>
<span class="line" id="L61">            <span class="tok-comment">// This way, a get() and a remove() are thread-safe with each other.</span>
</span>
<span class="line" id="L62">            head.prev = <span class="tok-null">null</span>;</span>
<span class="line" id="L63">            head.next = <span class="tok-null">null</span>;</span>
<span class="line" id="L64">            <span class="tok-kw">return</span> head;</span>
<span class="line" id="L65">        }</span>
<span class="line" id="L66"></span>
<span class="line" id="L67">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">unget</span>(self: *Self, node: *Node) <span class="tok-type">void</span> {</span>
<span class="line" id="L68">            node.prev = <span class="tok-null">null</span>;</span>
<span class="line" id="L69"></span>
<span class="line" id="L70">            self.mutex.lock();</span>
<span class="line" id="L71">            <span class="tok-kw">defer</span> self.mutex.unlock();</span>
<span class="line" id="L72"></span>
<span class="line" id="L73">            <span class="tok-kw">const</span> opt_head = self.head;</span>
<span class="line" id="L74">            self.head = node;</span>
<span class="line" id="L75">            <span class="tok-kw">if</span> (opt_head) |head| {</span>
<span class="line" id="L76">                head.next = node;</span>
<span class="line" id="L77">            } <span class="tok-kw">else</span> {</span>
<span class="line" id="L78">                assert(self.tail == <span class="tok-null">null</span>);</span>
<span class="line" id="L79">                self.tail = node;</span>
<span class="line" id="L80">            }</span>
<span class="line" id="L81">        }</span>
<span class="line" id="L82"></span>
<span class="line" id="L83">        <span class="tok-comment">/// Removes a node from the queue, returns whether node was actually removed.</span></span>
<span class="line" id="L84">        <span class="tok-comment">/// It is safe to `remove()` a node from the queue while another thread tries</span></span>
<span class="line" id="L85">        <span class="tok-comment">/// to `get()` the same node at the same time.</span></span>
<span class="line" id="L86">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">remove</span>(self: *Self, node: *Node) <span class="tok-type">bool</span> {</span>
<span class="line" id="L87">            self.mutex.lock();</span>
<span class="line" id="L88">            <span class="tok-kw">defer</span> self.mutex.unlock();</span>
<span class="line" id="L89"></span>
<span class="line" id="L90">            <span class="tok-kw">if</span> (node.prev == <span class="tok-null">null</span> <span class="tok-kw">and</span> node.next == <span class="tok-null">null</span> <span class="tok-kw">and</span> self.head != node) {</span>
<span class="line" id="L91">                <span class="tok-kw">return</span> <span class="tok-null">false</span>;</span>
<span class="line" id="L92">            }</span>
<span class="line" id="L93"></span>
<span class="line" id="L94">            <span class="tok-kw">if</span> (node.prev) |prev| {</span>
<span class="line" id="L95">                prev.next = node.next;</span>
<span class="line" id="L96">            } <span class="tok-kw">else</span> {</span>
<span class="line" id="L97">                self.head = node.next;</span>
<span class="line" id="L98">            }</span>
<span class="line" id="L99">            <span class="tok-kw">if</span> (node.next) |next| {</span>
<span class="line" id="L100">                next.prev = node.prev;</span>
<span class="line" id="L101">            } <span class="tok-kw">else</span> {</span>
<span class="line" id="L102">                self.tail = node.prev;</span>
<span class="line" id="L103">            }</span>
<span class="line" id="L104">            node.prev = <span class="tok-null">null</span>;</span>
<span class="line" id="L105">            node.next = <span class="tok-null">null</span>;</span>
<span class="line" id="L106">            <span class="tok-kw">return</span> <span class="tok-null">true</span>;</span>
<span class="line" id="L107">        }</span>
<span class="line" id="L108"></span>
<span class="line" id="L109">        <span class="tok-comment">/// Returns `true` if the queue is currently empty.</span></span>
<span class="line" id="L110">        <span class="tok-comment">/// Note that in a multi-consumer environment a return value of `false`</span></span>
<span class="line" id="L111">        <span class="tok-comment">/// does not mean that `get` will yield a non-`null` value!</span></span>
<span class="line" id="L112">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">isEmpty</span>(self: *Self) <span class="tok-type">bool</span> {</span>
<span class="line" id="L113">            self.mutex.lock();</span>
<span class="line" id="L114">            <span class="tok-kw">defer</span> self.mutex.unlock();</span>
<span class="line" id="L115">            <span class="tok-kw">return</span> self.head == <span class="tok-null">null</span>;</span>
<span class="line" id="L116">        }</span>
<span class="line" id="L117"></span>
<span class="line" id="L118">        <span class="tok-comment">/// Dumps the contents of the queue to `stderr`.</span></span>
<span class="line" id="L119">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">dump</span>(self: *Self) <span class="tok-type">void</span> {</span>
<span class="line" id="L120">            self.dumpToStream(std.io.getStdErr().writer()) <span class="tok-kw">catch</span> <span class="tok-kw">return</span>;</span>
<span class="line" id="L121">        }</span>
<span class="line" id="L122"></span>
<span class="line" id="L123">        <span class="tok-comment">/// Dumps the contents of the queue to `stream`.</span></span>
<span class="line" id="L124">        <span class="tok-comment">/// Up to 4 elements from the head are dumped and the tail of the queue is</span></span>
<span class="line" id="L125">        <span class="tok-comment">/// dumped as well.</span></span>
<span class="line" id="L126">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">dumpToStream</span>(self: *Self, stream: <span class="tok-kw">anytype</span>) !<span class="tok-type">void</span> {</span>
<span class="line" id="L127">            <span class="tok-kw">const</span> S = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L128">                <span class="tok-kw">fn</span> <span class="tok-fn">dumpRecursive</span>(</span>
<span class="line" id="L129">                    s: <span class="tok-kw">anytype</span>,</span>
<span class="line" id="L130">                    optional_node: ?*Node,</span>
<span class="line" id="L131">                    indent: <span class="tok-type">usize</span>,</span>
<span class="line" id="L132">                    <span class="tok-kw">comptime</span> depth: <span class="tok-type">comptime_int</span>,</span>
<span class="line" id="L133">                ) !<span class="tok-type">void</span> {</span>
<span class="line" id="L134">                    <span class="tok-kw">try</span> s.writeByteNTimes(<span class="tok-str">' '</span>, indent);</span>
<span class="line" id="L135">                    <span class="tok-kw">if</span> (optional_node) |node| {</span>
<span class="line" id="L136">                        <span class="tok-kw">try</span> s.print(<span class="tok-str">&quot;0x{x}={}\n&quot;</span>, .{ <span class="tok-builtin">@ptrToInt</span>(node), node.data });</span>
<span class="line" id="L137">                        <span class="tok-kw">if</span> (depth == <span class="tok-number">0</span>) {</span>
<span class="line" id="L138">                            <span class="tok-kw">try</span> s.print(<span class="tok-str">&quot;(max depth)\n&quot;</span>, .{});</span>
<span class="line" id="L139">                            <span class="tok-kw">return</span>;</span>
<span class="line" id="L140">                        }</span>
<span class="line" id="L141">                        <span class="tok-kw">try</span> dumpRecursive(s, node.next, indent + <span class="tok-number">1</span>, depth - <span class="tok-number">1</span>);</span>
<span class="line" id="L142">                    } <span class="tok-kw">else</span> {</span>
<span class="line" id="L143">                        <span class="tok-kw">try</span> s.print(<span class="tok-str">&quot;(null)\n&quot;</span>, .{});</span>
<span class="line" id="L144">                    }</span>
<span class="line" id="L145">                }</span>
<span class="line" id="L146">            };</span>
<span class="line" id="L147">            self.mutex.lock();</span>
<span class="line" id="L148">            <span class="tok-kw">defer</span> self.mutex.unlock();</span>
<span class="line" id="L149"></span>
<span class="line" id="L150">            <span class="tok-kw">try</span> stream.print(<span class="tok-str">&quot;head: &quot;</span>, .{});</span>
<span class="line" id="L151">            <span class="tok-kw">try</span> S.dumpRecursive(stream, self.head, <span class="tok-number">0</span>, <span class="tok-number">4</span>);</span>
<span class="line" id="L152">            <span class="tok-kw">try</span> stream.print(<span class="tok-str">&quot;tail: &quot;</span>, .{});</span>
<span class="line" id="L153">            <span class="tok-kw">try</span> S.dumpRecursive(stream, self.tail, <span class="tok-number">0</span>, <span class="tok-number">4</span>);</span>
<span class="line" id="L154">        }</span>
<span class="line" id="L155">    };</span>
<span class="line" id="L156">}</span>
<span class="line" id="L157"></span>
<span class="line" id="L158"><span class="tok-kw">const</span> Context = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L159">    allocator: std.mem.Allocator,</span>
<span class="line" id="L160">    queue: *Queue(<span class="tok-type">i32</span>),</span>
<span class="line" id="L161">    put_sum: <span class="tok-type">isize</span>,</span>
<span class="line" id="L162">    get_sum: <span class="tok-type">isize</span>,</span>
<span class="line" id="L163">    get_count: <span class="tok-type">usize</span>,</span>
<span class="line" id="L164">    puts_done: <span class="tok-type">bool</span>,</span>
<span class="line" id="L165">};</span>
<span class="line" id="L166"></span>
<span class="line" id="L167"><span class="tok-comment">// TODO add lazy evaluated build options and then put puts_per_thread behind</span>
</span>
<span class="line" id="L168"><span class="tok-comment">// some option such as: &quot;AggressiveMultithreadedFuzzTest&quot;. In the AppVeyor</span>
</span>
<span class="line" id="L169"><span class="tok-comment">// CI we would use a less aggressive setting since at 1 core, while we still</span>
</span>
<span class="line" id="L170"><span class="tok-comment">// want this test to pass, we need a smaller value since there is so much thrashing</span>
</span>
<span class="line" id="L171"><span class="tok-comment">// we would also use a less aggressive setting when running in valgrind</span>
</span>
<span class="line" id="L172"><span class="tok-kw">const</span> puts_per_thread = <span class="tok-number">500</span>;</span>
<span class="line" id="L173"><span class="tok-kw">const</span> put_thread_count = <span class="tok-number">3</span>;</span>
<span class="line" id="L174"></span>
<span class="line" id="L175"><span class="tok-kw">test</span> <span class="tok-str">&quot;std.atomic.Queue&quot;</span> {</span>
<span class="line" id="L176">    <span class="tok-kw">var</span> plenty_of_memory = <span class="tok-kw">try</span> std.heap.page_allocator.alloc(<span class="tok-type">u8</span>, <span class="tok-number">300</span> * <span class="tok-number">1024</span>);</span>
<span class="line" id="L177">    <span class="tok-kw">defer</span> std.heap.page_allocator.free(plenty_of_memory);</span>
<span class="line" id="L178"></span>
<span class="line" id="L179">    <span class="tok-kw">var</span> fixed_buffer_allocator = std.heap.FixedBufferAllocator.init(plenty_of_memory);</span>
<span class="line" id="L180">    <span class="tok-kw">var</span> a = fixed_buffer_allocator.threadSafeAllocator();</span>
<span class="line" id="L181"></span>
<span class="line" id="L182">    <span class="tok-kw">var</span> queue = Queue(<span class="tok-type">i32</span>).init();</span>
<span class="line" id="L183">    <span class="tok-kw">var</span> context = Context{</span>
<span class="line" id="L184">        .allocator = a,</span>
<span class="line" id="L185">        .queue = &amp;queue,</span>
<span class="line" id="L186">        .put_sum = <span class="tok-number">0</span>,</span>
<span class="line" id="L187">        .get_sum = <span class="tok-number">0</span>,</span>
<span class="line" id="L188">        .puts_done = <span class="tok-null">false</span>,</span>
<span class="line" id="L189">        .get_count = <span class="tok-number">0</span>,</span>
<span class="line" id="L190">    };</span>
<span class="line" id="L191"></span>
<span class="line" id="L192">    <span class="tok-kw">if</span> (builtin.single_threaded) {</span>
<span class="line" id="L193">        <span class="tok-kw">try</span> expect(context.queue.isEmpty());</span>
<span class="line" id="L194">        {</span>
<span class="line" id="L195">            <span class="tok-kw">var</span> i: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L196">            <span class="tok-kw">while</span> (i &lt; put_thread_count) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L197">                <span class="tok-kw">try</span> expect(startPuts(&amp;context) == <span class="tok-number">0</span>);</span>
<span class="line" id="L198">            }</span>
<span class="line" id="L199">        }</span>
<span class="line" id="L200">        <span class="tok-kw">try</span> expect(!context.queue.isEmpty());</span>
<span class="line" id="L201">        context.puts_done = <span class="tok-null">true</span>;</span>
<span class="line" id="L202">        {</span>
<span class="line" id="L203">            <span class="tok-kw">var</span> i: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L204">            <span class="tok-kw">while</span> (i &lt; put_thread_count) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L205">                <span class="tok-kw">try</span> expect(startGets(&amp;context) == <span class="tok-number">0</span>);</span>
<span class="line" id="L206">            }</span>
<span class="line" id="L207">        }</span>
<span class="line" id="L208">        <span class="tok-kw">try</span> expect(context.queue.isEmpty());</span>
<span class="line" id="L209">    } <span class="tok-kw">else</span> {</span>
<span class="line" id="L210">        <span class="tok-kw">try</span> expect(context.queue.isEmpty());</span>
<span class="line" id="L211"></span>
<span class="line" id="L212">        <span class="tok-kw">var</span> putters: [put_thread_count]std.Thread = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L213">        <span class="tok-kw">for</span> (putters) |*t| {</span>
<span class="line" id="L214">            t.* = <span class="tok-kw">try</span> std.Thread.spawn(.{}, startPuts, .{&amp;context});</span>
<span class="line" id="L215">        }</span>
<span class="line" id="L216">        <span class="tok-kw">var</span> getters: [put_thread_count]std.Thread = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L217">        <span class="tok-kw">for</span> (getters) |*t| {</span>
<span class="line" id="L218">            t.* = <span class="tok-kw">try</span> std.Thread.spawn(.{}, startGets, .{&amp;context});</span>
<span class="line" id="L219">        }</span>
<span class="line" id="L220"></span>
<span class="line" id="L221">        <span class="tok-kw">for</span> (putters) |t|</span>
<span class="line" id="L222">            t.join();</span>
<span class="line" id="L223">        <span class="tok-builtin">@atomicStore</span>(<span class="tok-type">bool</span>, &amp;context.puts_done, <span class="tok-null">true</span>, .SeqCst);</span>
<span class="line" id="L224">        <span class="tok-kw">for</span> (getters) |t|</span>
<span class="line" id="L225">            t.join();</span>
<span class="line" id="L226"></span>
<span class="line" id="L227">        <span class="tok-kw">try</span> expect(context.queue.isEmpty());</span>
<span class="line" id="L228">    }</span>
<span class="line" id="L229"></span>
<span class="line" id="L230">    <span class="tok-kw">if</span> (context.put_sum != context.get_sum) {</span>
<span class="line" id="L231">        std.debug.panic(<span class="tok-str">&quot;failure\nput_sum:{} != get_sum:{}&quot;</span>, .{ context.put_sum, context.get_sum });</span>
<span class="line" id="L232">    }</span>
<span class="line" id="L233"></span>
<span class="line" id="L234">    <span class="tok-kw">if</span> (context.get_count != puts_per_thread * put_thread_count) {</span>
<span class="line" id="L235">        std.debug.panic(<span class="tok-str">&quot;failure\nget_count:{} != puts_per_thread:{} * put_thread_count:{}&quot;</span>, .{</span>
<span class="line" id="L236">            context.get_count,</span>
<span class="line" id="L237">            <span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, puts_per_thread),</span>
<span class="line" id="L238">            <span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, put_thread_count),</span>
<span class="line" id="L239">        });</span>
<span class="line" id="L240">    }</span>
<span class="line" id="L241">}</span>
<span class="line" id="L242"></span>
<span class="line" id="L243"><span class="tok-kw">fn</span> <span class="tok-fn">startPuts</span>(ctx: *Context) <span class="tok-type">u8</span> {</span>
<span class="line" id="L244">    <span class="tok-kw">var</span> put_count: <span class="tok-type">usize</span> = puts_per_thread;</span>
<span class="line" id="L245">    <span class="tok-kw">var</span> prng = std.rand.DefaultPrng.init(<span class="tok-number">0xdeadbeef</span>);</span>
<span class="line" id="L246">    <span class="tok-kw">const</span> random = prng.random();</span>
<span class="line" id="L247">    <span class="tok-kw">while</span> (put_count != <span class="tok-number">0</span>) : (put_count -= <span class="tok-number">1</span>) {</span>
<span class="line" id="L248">        std.time.sleep(<span class="tok-number">1</span>); <span class="tok-comment">// let the os scheduler be our fuzz</span>
</span>
<span class="line" id="L249">        <span class="tok-kw">const</span> x = <span class="tok-builtin">@bitCast</span>(<span class="tok-type">i32</span>, random.int(<span class="tok-type">u32</span>));</span>
<span class="line" id="L250">        <span class="tok-kw">const</span> node = ctx.allocator.create(Queue(<span class="tok-type">i32</span>).Node) <span class="tok-kw">catch</span> <span class="tok-kw">unreachable</span>;</span>
<span class="line" id="L251">        node.* = .{</span>
<span class="line" id="L252">            .prev = <span class="tok-null">undefined</span>,</span>
<span class="line" id="L253">            .next = <span class="tok-null">undefined</span>,</span>
<span class="line" id="L254">            .data = x,</span>
<span class="line" id="L255">        };</span>
<span class="line" id="L256">        ctx.queue.put(node);</span>
<span class="line" id="L257">        _ = <span class="tok-builtin">@atomicRmw</span>(<span class="tok-type">isize</span>, &amp;ctx.put_sum, .Add, x, .SeqCst);</span>
<span class="line" id="L258">    }</span>
<span class="line" id="L259">    <span class="tok-kw">return</span> <span class="tok-number">0</span>;</span>
<span class="line" id="L260">}</span>
<span class="line" id="L261"></span>
<span class="line" id="L262"><span class="tok-kw">fn</span> <span class="tok-fn">startGets</span>(ctx: *Context) <span class="tok-type">u8</span> {</span>
<span class="line" id="L263">    <span class="tok-kw">while</span> (<span class="tok-null">true</span>) {</span>
<span class="line" id="L264">        <span class="tok-kw">const</span> last = <span class="tok-builtin">@atomicLoad</span>(<span class="tok-type">bool</span>, &amp;ctx.puts_done, .SeqCst);</span>
<span class="line" id="L265"></span>
<span class="line" id="L266">        <span class="tok-kw">while</span> (ctx.queue.get()) |node| {</span>
<span class="line" id="L267">            std.time.sleep(<span class="tok-number">1</span>); <span class="tok-comment">// let the os scheduler be our fuzz</span>
</span>
<span class="line" id="L268">            _ = <span class="tok-builtin">@atomicRmw</span>(<span class="tok-type">isize</span>, &amp;ctx.get_sum, .Add, node.data, .SeqCst);</span>
<span class="line" id="L269">            _ = <span class="tok-builtin">@atomicRmw</span>(<span class="tok-type">usize</span>, &amp;ctx.get_count, .Add, <span class="tok-number">1</span>, .SeqCst);</span>
<span class="line" id="L270">        }</span>
<span class="line" id="L271"></span>
<span class="line" id="L272">        <span class="tok-kw">if</span> (last) <span class="tok-kw">return</span> <span class="tok-number">0</span>;</span>
<span class="line" id="L273">    }</span>
<span class="line" id="L274">}</span>
<span class="line" id="L275"></span>
<span class="line" id="L276"><span class="tok-kw">test</span> <span class="tok-str">&quot;std.atomic.Queue single-threaded&quot;</span> {</span>
<span class="line" id="L277">    <span class="tok-kw">var</span> queue = Queue(<span class="tok-type">i32</span>).init();</span>
<span class="line" id="L278">    <span class="tok-kw">try</span> expect(queue.isEmpty());</span>
<span class="line" id="L279"></span>
<span class="line" id="L280">    <span class="tok-kw">var</span> node_0 = Queue(<span class="tok-type">i32</span>).Node{</span>
<span class="line" id="L281">        .data = <span class="tok-number">0</span>,</span>
<span class="line" id="L282">        .next = <span class="tok-null">undefined</span>,</span>
<span class="line" id="L283">        .prev = <span class="tok-null">undefined</span>,</span>
<span class="line" id="L284">    };</span>
<span class="line" id="L285">    queue.put(&amp;node_0);</span>
<span class="line" id="L286">    <span class="tok-kw">try</span> expect(!queue.isEmpty());</span>
<span class="line" id="L287"></span>
<span class="line" id="L288">    <span class="tok-kw">var</span> node_1 = Queue(<span class="tok-type">i32</span>).Node{</span>
<span class="line" id="L289">        .data = <span class="tok-number">1</span>,</span>
<span class="line" id="L290">        .next = <span class="tok-null">undefined</span>,</span>
<span class="line" id="L291">        .prev = <span class="tok-null">undefined</span>,</span>
<span class="line" id="L292">    };</span>
<span class="line" id="L293">    queue.put(&amp;node_1);</span>
<span class="line" id="L294">    <span class="tok-kw">try</span> expect(!queue.isEmpty());</span>
<span class="line" id="L295"></span>
<span class="line" id="L296">    <span class="tok-kw">try</span> expect(queue.get().?.data == <span class="tok-number">0</span>);</span>
<span class="line" id="L297">    <span class="tok-kw">try</span> expect(!queue.isEmpty());</span>
<span class="line" id="L298"></span>
<span class="line" id="L299">    <span class="tok-kw">var</span> node_2 = Queue(<span class="tok-type">i32</span>).Node{</span>
<span class="line" id="L300">        .data = <span class="tok-number">2</span>,</span>
<span class="line" id="L301">        .next = <span class="tok-null">undefined</span>,</span>
<span class="line" id="L302">        .prev = <span class="tok-null">undefined</span>,</span>
<span class="line" id="L303">    };</span>
<span class="line" id="L304">    queue.put(&amp;node_2);</span>
<span class="line" id="L305">    <span class="tok-kw">try</span> expect(!queue.isEmpty());</span>
<span class="line" id="L306"></span>
<span class="line" id="L307">    <span class="tok-kw">var</span> node_3 = Queue(<span class="tok-type">i32</span>).Node{</span>
<span class="line" id="L308">        .data = <span class="tok-number">3</span>,</span>
<span class="line" id="L309">        .next = <span class="tok-null">undefined</span>,</span>
<span class="line" id="L310">        .prev = <span class="tok-null">undefined</span>,</span>
<span class="line" id="L311">    };</span>
<span class="line" id="L312">    queue.put(&amp;node_3);</span>
<span class="line" id="L313">    <span class="tok-kw">try</span> expect(!queue.isEmpty());</span>
<span class="line" id="L314"></span>
<span class="line" id="L315">    <span class="tok-kw">try</span> expect(queue.get().?.data == <span class="tok-number">1</span>);</span>
<span class="line" id="L316">    <span class="tok-kw">try</span> expect(!queue.isEmpty());</span>
<span class="line" id="L317"></span>
<span class="line" id="L318">    <span class="tok-kw">try</span> expect(queue.get().?.data == <span class="tok-number">2</span>);</span>
<span class="line" id="L319">    <span class="tok-kw">try</span> expect(!queue.isEmpty());</span>
<span class="line" id="L320"></span>
<span class="line" id="L321">    <span class="tok-kw">var</span> node_4 = Queue(<span class="tok-type">i32</span>).Node{</span>
<span class="line" id="L322">        .data = <span class="tok-number">4</span>,</span>
<span class="line" id="L323">        .next = <span class="tok-null">undefined</span>,</span>
<span class="line" id="L324">        .prev = <span class="tok-null">undefined</span>,</span>
<span class="line" id="L325">    };</span>
<span class="line" id="L326">    queue.put(&amp;node_4);</span>
<span class="line" id="L327">    <span class="tok-kw">try</span> expect(!queue.isEmpty());</span>
<span class="line" id="L328"></span>
<span class="line" id="L329">    <span class="tok-kw">try</span> expect(queue.get().?.data == <span class="tok-number">3</span>);</span>
<span class="line" id="L330">    node_3.next = <span class="tok-null">null</span>;</span>
<span class="line" id="L331">    <span class="tok-kw">try</span> expect(!queue.isEmpty());</span>
<span class="line" id="L332"></span>
<span class="line" id="L333">    <span class="tok-kw">try</span> expect(queue.get().?.data == <span class="tok-number">4</span>);</span>
<span class="line" id="L334">    <span class="tok-kw">try</span> expect(queue.isEmpty());</span>
<span class="line" id="L335"></span>
<span class="line" id="L336">    <span class="tok-kw">try</span> expect(queue.get() == <span class="tok-null">null</span>);</span>
<span class="line" id="L337">    <span class="tok-kw">try</span> expect(queue.isEmpty());</span>
<span class="line" id="L338">}</span>
<span class="line" id="L339"></span>
<span class="line" id="L340"><span class="tok-kw">test</span> <span class="tok-str">&quot;std.atomic.Queue dump&quot;</span> {</span>
<span class="line" id="L341">    <span class="tok-kw">const</span> mem = std.mem;</span>
<span class="line" id="L342">    <span class="tok-kw">var</span> buffer: [<span class="tok-number">1024</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L343">    <span class="tok-kw">var</span> expected_buffer: [<span class="tok-number">1024</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L344">    <span class="tok-kw">var</span> fbs = std.io.fixedBufferStream(&amp;buffer);</span>
<span class="line" id="L345"></span>
<span class="line" id="L346">    <span class="tok-kw">var</span> queue = Queue(<span class="tok-type">i32</span>).init();</span>
<span class="line" id="L347"></span>
<span class="line" id="L348">    <span class="tok-comment">// Test empty stream</span>
</span>
<span class="line" id="L349">    fbs.reset();</span>
<span class="line" id="L350">    <span class="tok-kw">try</span> queue.dumpToStream(fbs.writer());</span>
<span class="line" id="L351">    <span class="tok-kw">try</span> expect(mem.eql(<span class="tok-type">u8</span>, buffer[<span class="tok-number">0</span>..fbs.pos],</span>
<span class="line" id="L352">        <span class="tok-str">\\head: (null)</span></span>

<span class="line" id="L353">        <span class="tok-str">\\tail: (null)</span></span>

<span class="line" id="L354">        <span class="tok-str">\\</span></span>

<span class="line" id="L355">    ));</span>
<span class="line" id="L356"></span>
<span class="line" id="L357">    <span class="tok-comment">// Test a stream with one element</span>
</span>
<span class="line" id="L358">    <span class="tok-kw">var</span> node_0 = Queue(<span class="tok-type">i32</span>).Node{</span>
<span class="line" id="L359">        .data = <span class="tok-number">1</span>,</span>
<span class="line" id="L360">        .next = <span class="tok-null">undefined</span>,</span>
<span class="line" id="L361">        .prev = <span class="tok-null">undefined</span>,</span>
<span class="line" id="L362">    };</span>
<span class="line" id="L363">    queue.put(&amp;node_0);</span>
<span class="line" id="L364"></span>
<span class="line" id="L365">    fbs.reset();</span>
<span class="line" id="L366">    <span class="tok-kw">try</span> queue.dumpToStream(fbs.writer());</span>
<span class="line" id="L367"></span>
<span class="line" id="L368">    <span class="tok-kw">var</span> expected = <span class="tok-kw">try</span> std.fmt.bufPrint(expected_buffer[<span class="tok-number">0</span>..],</span>
<span class="line" id="L369">        <span class="tok-str">\\head: 0x{x}=1</span></span>

<span class="line" id="L370">        <span class="tok-str">\\ (null)</span></span>

<span class="line" id="L371">        <span class="tok-str">\\tail: 0x{x}=1</span></span>

<span class="line" id="L372">        <span class="tok-str">\\ (null)</span></span>

<span class="line" id="L373">        <span class="tok-str">\\</span></span>

<span class="line" id="L374">    , .{ <span class="tok-builtin">@ptrToInt</span>(queue.head), <span class="tok-builtin">@ptrToInt</span>(queue.tail) });</span>
<span class="line" id="L375">    <span class="tok-kw">try</span> expect(mem.eql(<span class="tok-type">u8</span>, buffer[<span class="tok-number">0</span>..fbs.pos], expected));</span>
<span class="line" id="L376"></span>
<span class="line" id="L377">    <span class="tok-comment">// Test a stream with two elements</span>
</span>
<span class="line" id="L378">    <span class="tok-kw">var</span> node_1 = Queue(<span class="tok-type">i32</span>).Node{</span>
<span class="line" id="L379">        .data = <span class="tok-number">2</span>,</span>
<span class="line" id="L380">        .next = <span class="tok-null">undefined</span>,</span>
<span class="line" id="L381">        .prev = <span class="tok-null">undefined</span>,</span>
<span class="line" id="L382">    };</span>
<span class="line" id="L383">    queue.put(&amp;node_1);</span>
<span class="line" id="L384"></span>
<span class="line" id="L385">    fbs.reset();</span>
<span class="line" id="L386">    <span class="tok-kw">try</span> queue.dumpToStream(fbs.writer());</span>
<span class="line" id="L387"></span>
<span class="line" id="L388">    expected = <span class="tok-kw">try</span> std.fmt.bufPrint(expected_buffer[<span class="tok-number">0</span>..],</span>
<span class="line" id="L389">        <span class="tok-str">\\head: 0x{x}=1</span></span>

<span class="line" id="L390">        <span class="tok-str">\\ 0x{x}=2</span></span>

<span class="line" id="L391">        <span class="tok-str">\\  (null)</span></span>

<span class="line" id="L392">        <span class="tok-str">\\tail: 0x{x}=2</span></span>

<span class="line" id="L393">        <span class="tok-str">\\ (null)</span></span>

<span class="line" id="L394">        <span class="tok-str">\\</span></span>

<span class="line" id="L395">    , .{ <span class="tok-builtin">@ptrToInt</span>(queue.head), <span class="tok-builtin">@ptrToInt</span>(queue.head.?.next), <span class="tok-builtin">@ptrToInt</span>(queue.tail) });</span>
<span class="line" id="L396">    <span class="tok-kw">try</span> expect(mem.eql(<span class="tok-type">u8</span>, buffer[<span class="tok-number">0</span>..fbs.pos], expected));</span>
<span class="line" id="L397">}</span>
<span class="line" id="L398"></span>
</code></pre></body>
</html>