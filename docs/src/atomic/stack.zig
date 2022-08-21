<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">    <title>atomic/stack.zig - source view</title>
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
<span class="line" id="L6"><span class="tok-comment">/// Many reader, many writer, non-allocating, thread-safe</span></span>
<span class="line" id="L7"><span class="tok-comment">/// Uses a spinlock to protect push() and pop()</span></span>
<span class="line" id="L8"><span class="tok-comment">/// When building in single threaded mode, this is a simple linked list.</span></span>
<span class="line" id="L9"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">Stack</span>(<span class="tok-kw">comptime</span> T: <span class="tok-type">type</span>) <span class="tok-type">type</span> {</span>
<span class="line" id="L10">    <span class="tok-kw">return</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L11">        root: ?*Node,</span>
<span class="line" id="L12">        lock: <span class="tok-builtin">@TypeOf</span>(lock_init),</span>
<span class="line" id="L13"></span>
<span class="line" id="L14">        <span class="tok-kw">const</span> lock_init = <span class="tok-kw">if</span> (builtin.single_threaded) {} <span class="tok-kw">else</span> <span class="tok-null">false</span>;</span>
<span class="line" id="L15"></span>
<span class="line" id="L16">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> Self = <span class="tok-builtin">@This</span>();</span>
<span class="line" id="L17"></span>
<span class="line" id="L18">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> Node = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L19">            next: ?*Node,</span>
<span class="line" id="L20">            data: T,</span>
<span class="line" id="L21">        };</span>
<span class="line" id="L22"></span>
<span class="line" id="L23">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">init</span>() Self {</span>
<span class="line" id="L24">            <span class="tok-kw">return</span> Self{</span>
<span class="line" id="L25">                .root = <span class="tok-null">null</span>,</span>
<span class="line" id="L26">                .lock = lock_init,</span>
<span class="line" id="L27">            };</span>
<span class="line" id="L28">        }</span>
<span class="line" id="L29"></span>
<span class="line" id="L30">        <span class="tok-comment">/// push operation, but only if you are the first item in the stack. if you did not succeed in</span></span>
<span class="line" id="L31">        <span class="tok-comment">/// being the first item in the stack, returns the other item that was there.</span></span>
<span class="line" id="L32">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">pushFirst</span>(self: *Self, node: *Node) ?*Node {</span>
<span class="line" id="L33">            node.next = <span class="tok-null">null</span>;</span>
<span class="line" id="L34">            <span class="tok-kw">return</span> <span class="tok-builtin">@cmpxchgStrong</span>(?*Node, &amp;self.root, <span class="tok-null">null</span>, node, .SeqCst, .SeqCst);</span>
<span class="line" id="L35">        }</span>
<span class="line" id="L36"></span>
<span class="line" id="L37">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">push</span>(self: *Self, node: *Node) <span class="tok-type">void</span> {</span>
<span class="line" id="L38">            <span class="tok-kw">if</span> (builtin.single_threaded) {</span>
<span class="line" id="L39">                node.next = self.root;</span>
<span class="line" id="L40">                self.root = node;</span>
<span class="line" id="L41">            } <span class="tok-kw">else</span> {</span>
<span class="line" id="L42">                <span class="tok-kw">while</span> (<span class="tok-builtin">@atomicRmw</span>(<span class="tok-type">bool</span>, &amp;self.lock, .Xchg, <span class="tok-null">true</span>, .SeqCst)) {}</span>
<span class="line" id="L43">                <span class="tok-kw">defer</span> assert(<span class="tok-builtin">@atomicRmw</span>(<span class="tok-type">bool</span>, &amp;self.lock, .Xchg, <span class="tok-null">false</span>, .SeqCst));</span>
<span class="line" id="L44"></span>
<span class="line" id="L45">                node.next = self.root;</span>
<span class="line" id="L46">                self.root = node;</span>
<span class="line" id="L47">            }</span>
<span class="line" id="L48">        }</span>
<span class="line" id="L49"></span>
<span class="line" id="L50">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">pop</span>(self: *Self) ?*Node {</span>
<span class="line" id="L51">            <span class="tok-kw">if</span> (builtin.single_threaded) {</span>
<span class="line" id="L52">                <span class="tok-kw">const</span> root = self.root <span class="tok-kw">orelse</span> <span class="tok-kw">return</span> <span class="tok-null">null</span>;</span>
<span class="line" id="L53">                self.root = root.next;</span>
<span class="line" id="L54">                <span class="tok-kw">return</span> root;</span>
<span class="line" id="L55">            } <span class="tok-kw">else</span> {</span>
<span class="line" id="L56">                <span class="tok-kw">while</span> (<span class="tok-builtin">@atomicRmw</span>(<span class="tok-type">bool</span>, &amp;self.lock, .Xchg, <span class="tok-null">true</span>, .SeqCst)) {}</span>
<span class="line" id="L57">                <span class="tok-kw">defer</span> assert(<span class="tok-builtin">@atomicRmw</span>(<span class="tok-type">bool</span>, &amp;self.lock, .Xchg, <span class="tok-null">false</span>, .SeqCst));</span>
<span class="line" id="L58"></span>
<span class="line" id="L59">                <span class="tok-kw">const</span> root = self.root <span class="tok-kw">orelse</span> <span class="tok-kw">return</span> <span class="tok-null">null</span>;</span>
<span class="line" id="L60">                self.root = root.next;</span>
<span class="line" id="L61">                <span class="tok-kw">return</span> root;</span>
<span class="line" id="L62">            }</span>
<span class="line" id="L63">        }</span>
<span class="line" id="L64"></span>
<span class="line" id="L65">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">isEmpty</span>(self: *Self) <span class="tok-type">bool</span> {</span>
<span class="line" id="L66">            <span class="tok-kw">return</span> <span class="tok-builtin">@atomicLoad</span>(?*Node, &amp;self.root, .SeqCst) == <span class="tok-null">null</span>;</span>
<span class="line" id="L67">        }</span>
<span class="line" id="L68">    };</span>
<span class="line" id="L69">}</span>
<span class="line" id="L70"></span>
<span class="line" id="L71"><span class="tok-kw">const</span> Context = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L72">    allocator: std.mem.Allocator,</span>
<span class="line" id="L73">    stack: *Stack(<span class="tok-type">i32</span>),</span>
<span class="line" id="L74">    put_sum: <span class="tok-type">isize</span>,</span>
<span class="line" id="L75">    get_sum: <span class="tok-type">isize</span>,</span>
<span class="line" id="L76">    get_count: <span class="tok-type">usize</span>,</span>
<span class="line" id="L77">    puts_done: <span class="tok-type">bool</span>,</span>
<span class="line" id="L78">};</span>
<span class="line" id="L79"><span class="tok-comment">// TODO add lazy evaluated build options and then put puts_per_thread behind</span>
</span>
<span class="line" id="L80"><span class="tok-comment">// some option such as: &quot;AggressiveMultithreadedFuzzTest&quot;. In the AppVeyor</span>
</span>
<span class="line" id="L81"><span class="tok-comment">// CI we would use a less aggressive setting since at 1 core, while we still</span>
</span>
<span class="line" id="L82"><span class="tok-comment">// want this test to pass, we need a smaller value since there is so much thrashing</span>
</span>
<span class="line" id="L83"><span class="tok-comment">// we would also use a less aggressive setting when running in valgrind</span>
</span>
<span class="line" id="L84"><span class="tok-kw">const</span> puts_per_thread = <span class="tok-number">500</span>;</span>
<span class="line" id="L85"><span class="tok-kw">const</span> put_thread_count = <span class="tok-number">3</span>;</span>
<span class="line" id="L86"></span>
<span class="line" id="L87"><span class="tok-kw">test</span> <span class="tok-str">&quot;std.atomic.stack&quot;</span> {</span>
<span class="line" id="L88">    <span class="tok-kw">var</span> plenty_of_memory = <span class="tok-kw">try</span> std.heap.page_allocator.alloc(<span class="tok-type">u8</span>, <span class="tok-number">300</span> * <span class="tok-number">1024</span>);</span>
<span class="line" id="L89">    <span class="tok-kw">defer</span> std.heap.page_allocator.free(plenty_of_memory);</span>
<span class="line" id="L90"></span>
<span class="line" id="L91">    <span class="tok-kw">var</span> fixed_buffer_allocator = std.heap.FixedBufferAllocator.init(plenty_of_memory);</span>
<span class="line" id="L92">    <span class="tok-kw">var</span> a = fixed_buffer_allocator.threadSafeAllocator();</span>
<span class="line" id="L93"></span>
<span class="line" id="L94">    <span class="tok-kw">var</span> stack = Stack(<span class="tok-type">i32</span>).init();</span>
<span class="line" id="L95">    <span class="tok-kw">var</span> context = Context{</span>
<span class="line" id="L96">        .allocator = a,</span>
<span class="line" id="L97">        .stack = &amp;stack,</span>
<span class="line" id="L98">        .put_sum = <span class="tok-number">0</span>,</span>
<span class="line" id="L99">        .get_sum = <span class="tok-number">0</span>,</span>
<span class="line" id="L100">        .puts_done = <span class="tok-null">false</span>,</span>
<span class="line" id="L101">        .get_count = <span class="tok-number">0</span>,</span>
<span class="line" id="L102">    };</span>
<span class="line" id="L103"></span>
<span class="line" id="L104">    <span class="tok-kw">if</span> (builtin.single_threaded) {</span>
<span class="line" id="L105">        {</span>
<span class="line" id="L106">            <span class="tok-kw">var</span> i: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L107">            <span class="tok-kw">while</span> (i &lt; put_thread_count) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L108">                <span class="tok-kw">try</span> expect(startPuts(&amp;context) == <span class="tok-number">0</span>);</span>
<span class="line" id="L109">            }</span>
<span class="line" id="L110">        }</span>
<span class="line" id="L111">        context.puts_done = <span class="tok-null">true</span>;</span>
<span class="line" id="L112">        {</span>
<span class="line" id="L113">            <span class="tok-kw">var</span> i: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L114">            <span class="tok-kw">while</span> (i &lt; put_thread_count) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L115">                <span class="tok-kw">try</span> expect(startGets(&amp;context) == <span class="tok-number">0</span>);</span>
<span class="line" id="L116">            }</span>
<span class="line" id="L117">        }</span>
<span class="line" id="L118">    } <span class="tok-kw">else</span> {</span>
<span class="line" id="L119">        <span class="tok-kw">var</span> putters: [put_thread_count]std.Thread = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L120">        <span class="tok-kw">for</span> (putters) |*t| {</span>
<span class="line" id="L121">            t.* = <span class="tok-kw">try</span> std.Thread.spawn(.{}, startPuts, .{&amp;context});</span>
<span class="line" id="L122">        }</span>
<span class="line" id="L123">        <span class="tok-kw">var</span> getters: [put_thread_count]std.Thread = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L124">        <span class="tok-kw">for</span> (getters) |*t| {</span>
<span class="line" id="L125">            t.* = <span class="tok-kw">try</span> std.Thread.spawn(.{}, startGets, .{&amp;context});</span>
<span class="line" id="L126">        }</span>
<span class="line" id="L127"></span>
<span class="line" id="L128">        <span class="tok-kw">for</span> (putters) |t|</span>
<span class="line" id="L129">            t.join();</span>
<span class="line" id="L130">        <span class="tok-builtin">@atomicStore</span>(<span class="tok-type">bool</span>, &amp;context.puts_done, <span class="tok-null">true</span>, .SeqCst);</span>
<span class="line" id="L131">        <span class="tok-kw">for</span> (getters) |t|</span>
<span class="line" id="L132">            t.join();</span>
<span class="line" id="L133">    }</span>
<span class="line" id="L134"></span>
<span class="line" id="L135">    <span class="tok-kw">if</span> (context.put_sum != context.get_sum) {</span>
<span class="line" id="L136">        std.debug.panic(<span class="tok-str">&quot;failure\nput_sum:{} != get_sum:{}&quot;</span>, .{ context.put_sum, context.get_sum });</span>
<span class="line" id="L137">    }</span>
<span class="line" id="L138"></span>
<span class="line" id="L139">    <span class="tok-kw">if</span> (context.get_count != puts_per_thread * put_thread_count) {</span>
<span class="line" id="L140">        std.debug.panic(<span class="tok-str">&quot;failure\nget_count:{} != puts_per_thread:{} * put_thread_count:{}&quot;</span>, .{</span>
<span class="line" id="L141">            context.get_count,</span>
<span class="line" id="L142">            <span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, puts_per_thread),</span>
<span class="line" id="L143">            <span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, put_thread_count),</span>
<span class="line" id="L144">        });</span>
<span class="line" id="L145">    }</span>
<span class="line" id="L146">}</span>
<span class="line" id="L147"></span>
<span class="line" id="L148"><span class="tok-kw">fn</span> <span class="tok-fn">startPuts</span>(ctx: *Context) <span class="tok-type">u8</span> {</span>
<span class="line" id="L149">    <span class="tok-kw">var</span> put_count: <span class="tok-type">usize</span> = puts_per_thread;</span>
<span class="line" id="L150">    <span class="tok-kw">var</span> prng = std.rand.DefaultPrng.init(<span class="tok-number">0xdeadbeef</span>);</span>
<span class="line" id="L151">    <span class="tok-kw">const</span> random = prng.random();</span>
<span class="line" id="L152">    <span class="tok-kw">while</span> (put_count != <span class="tok-number">0</span>) : (put_count -= <span class="tok-number">1</span>) {</span>
<span class="line" id="L153">        std.time.sleep(<span class="tok-number">1</span>); <span class="tok-comment">// let the os scheduler be our fuzz</span>
</span>
<span class="line" id="L154">        <span class="tok-kw">const</span> x = <span class="tok-builtin">@bitCast</span>(<span class="tok-type">i32</span>, random.int(<span class="tok-type">u32</span>));</span>
<span class="line" id="L155">        <span class="tok-kw">const</span> node = ctx.allocator.create(Stack(<span class="tok-type">i32</span>).Node) <span class="tok-kw">catch</span> <span class="tok-kw">unreachable</span>;</span>
<span class="line" id="L156">        node.* = Stack(<span class="tok-type">i32</span>).Node{</span>
<span class="line" id="L157">            .next = <span class="tok-null">undefined</span>,</span>
<span class="line" id="L158">            .data = x,</span>
<span class="line" id="L159">        };</span>
<span class="line" id="L160">        ctx.stack.push(node);</span>
<span class="line" id="L161">        _ = <span class="tok-builtin">@atomicRmw</span>(<span class="tok-type">isize</span>, &amp;ctx.put_sum, .Add, x, .SeqCst);</span>
<span class="line" id="L162">    }</span>
<span class="line" id="L163">    <span class="tok-kw">return</span> <span class="tok-number">0</span>;</span>
<span class="line" id="L164">}</span>
<span class="line" id="L165"></span>
<span class="line" id="L166"><span class="tok-kw">fn</span> <span class="tok-fn">startGets</span>(ctx: *Context) <span class="tok-type">u8</span> {</span>
<span class="line" id="L167">    <span class="tok-kw">while</span> (<span class="tok-null">true</span>) {</span>
<span class="line" id="L168">        <span class="tok-kw">const</span> last = <span class="tok-builtin">@atomicLoad</span>(<span class="tok-type">bool</span>, &amp;ctx.puts_done, .SeqCst);</span>
<span class="line" id="L169"></span>
<span class="line" id="L170">        <span class="tok-kw">while</span> (ctx.stack.pop()) |node| {</span>
<span class="line" id="L171">            std.time.sleep(<span class="tok-number">1</span>); <span class="tok-comment">// let the os scheduler be our fuzz</span>
</span>
<span class="line" id="L172">            _ = <span class="tok-builtin">@atomicRmw</span>(<span class="tok-type">isize</span>, &amp;ctx.get_sum, .Add, node.data, .SeqCst);</span>
<span class="line" id="L173">            _ = <span class="tok-builtin">@atomicRmw</span>(<span class="tok-type">usize</span>, &amp;ctx.get_count, .Add, <span class="tok-number">1</span>, .SeqCst);</span>
<span class="line" id="L174">        }</span>
<span class="line" id="L175"></span>
<span class="line" id="L176">        <span class="tok-kw">if</span> (last) <span class="tok-kw">return</span> <span class="tok-number">0</span>;</span>
<span class="line" id="L177">    }</span>
<span class="line" id="L178">}</span>
<span class="line" id="L179"></span>
</code></pre></body>
</html>