<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">    <title>event/group.zig - source view</title>
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
<span class="line" id="L3"><span class="tok-kw">const</span> Lock = std.event.Lock;</span>
<span class="line" id="L4"><span class="tok-kw">const</span> testing = std.testing;</span>
<span class="line" id="L5"><span class="tok-kw">const</span> Allocator = std.mem.Allocator;</span>
<span class="line" id="L6"></span>
<span class="line" id="L7"><span class="tok-comment">/// ReturnType must be `void` or `E!void`</span></span>
<span class="line" id="L8"><span class="tok-comment">/// TODO This API was created back with the old design of async/await, when calling any</span></span>
<span class="line" id="L9"><span class="tok-comment">/// async function required an allocator. There is an ongoing experiment to transition</span></span>
<span class="line" id="L10"><span class="tok-comment">/// all uses of this API to the simpler and more resource-aware `std.event.Batch` API.</span></span>
<span class="line" id="L11"><span class="tok-comment">/// If the transition goes well, all usages of `Group` will be gone, and this API</span></span>
<span class="line" id="L12"><span class="tok-comment">/// will be deleted.</span></span>
<span class="line" id="L13"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">Group</span>(<span class="tok-kw">comptime</span> ReturnType: <span class="tok-type">type</span>) <span class="tok-type">type</span> {</span>
<span class="line" id="L14">    <span class="tok-kw">return</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L15">        frame_stack: Stack,</span>
<span class="line" id="L16">        alloc_stack: AllocStack,</span>
<span class="line" id="L17">        lock: Lock,</span>
<span class="line" id="L18">        allocator: Allocator,</span>
<span class="line" id="L19"></span>
<span class="line" id="L20">        <span class="tok-kw">const</span> Self = <span class="tok-builtin">@This</span>();</span>
<span class="line" id="L21"></span>
<span class="line" id="L22">        <span class="tok-kw">const</span> Error = <span class="tok-kw">switch</span> (<span class="tok-builtin">@typeInfo</span>(ReturnType)) {</span>
<span class="line" id="L23">            .ErrorUnion =&gt; |payload| payload.error_set,</span>
<span class="line" id="L24">            <span class="tok-kw">else</span> =&gt; <span class="tok-type">void</span>,</span>
<span class="line" id="L25">        };</span>
<span class="line" id="L26">        <span class="tok-kw">const</span> Stack = std.atomic.Stack(<span class="tok-kw">anyframe</span>-&gt;ReturnType);</span>
<span class="line" id="L27">        <span class="tok-kw">const</span> AllocStack = std.atomic.Stack(Node);</span>
<span class="line" id="L28"></span>
<span class="line" id="L29">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> Node = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L30">            bytes: []<span class="tok-kw">const</span> <span class="tok-type">u8</span> = &amp;[<span class="tok-number">0</span>]<span class="tok-type">u8</span>{},</span>
<span class="line" id="L31">            handle: <span class="tok-kw">anyframe</span>-&gt;ReturnType,</span>
<span class="line" id="L32">        };</span>
<span class="line" id="L33"></span>
<span class="line" id="L34">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">init</span>(allocator: Allocator) Self {</span>
<span class="line" id="L35">            <span class="tok-kw">return</span> Self{</span>
<span class="line" id="L36">                .frame_stack = Stack.init(),</span>
<span class="line" id="L37">                .alloc_stack = AllocStack.init(),</span>
<span class="line" id="L38">                .lock = .{},</span>
<span class="line" id="L39">                .allocator = allocator,</span>
<span class="line" id="L40">            };</span>
<span class="line" id="L41">        }</span>
<span class="line" id="L42"></span>
<span class="line" id="L43">        <span class="tok-comment">/// Add a frame to the group. Thread-safe.</span></span>
<span class="line" id="L44">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">add</span>(self: *Self, handle: <span class="tok-kw">anyframe</span>-&gt;ReturnType) (<span class="tok-kw">error</span>{OutOfMemory}!<span class="tok-type">void</span>) {</span>
<span class="line" id="L45">            <span class="tok-kw">const</span> node = <span class="tok-kw">try</span> self.allocator.create(AllocStack.Node);</span>
<span class="line" id="L46">            node.* = AllocStack.Node{</span>
<span class="line" id="L47">                .next = <span class="tok-null">undefined</span>,</span>
<span class="line" id="L48">                .data = Node{</span>
<span class="line" id="L49">                    .handle = handle,</span>
<span class="line" id="L50">                },</span>
<span class="line" id="L51">            };</span>
<span class="line" id="L52">            self.alloc_stack.push(node);</span>
<span class="line" id="L53">        }</span>
<span class="line" id="L54"></span>
<span class="line" id="L55">        <span class="tok-comment">/// Add a node to the group. Thread-safe. Cannot fail.</span></span>
<span class="line" id="L56">        <span class="tok-comment">/// `node.data` should be the frame handle to add to the group.</span></span>
<span class="line" id="L57">        <span class="tok-comment">/// The node's memory should be in the function frame of</span></span>
<span class="line" id="L58">        <span class="tok-comment">/// the handle that is in the node, or somewhere guaranteed to live</span></span>
<span class="line" id="L59">        <span class="tok-comment">/// at least as long.</span></span>
<span class="line" id="L60">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">addNode</span>(self: *Self, node: *Stack.Node) <span class="tok-type">void</span> {</span>
<span class="line" id="L61">            self.frame_stack.push(node);</span>
<span class="line" id="L62">        }</span>
<span class="line" id="L63"></span>
<span class="line" id="L64">        <span class="tok-comment">/// This is equivalent to adding a frame to the group but the memory of its frame is</span></span>
<span class="line" id="L65">        <span class="tok-comment">/// allocated by the group and freed by `wait`.</span></span>
<span class="line" id="L66">        <span class="tok-comment">/// `func` must be async and have return type `ReturnType`.</span></span>
<span class="line" id="L67">        <span class="tok-comment">/// Thread-safe.</span></span>
<span class="line" id="L68">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">call</span>(self: *Self, <span class="tok-kw">comptime</span> func: <span class="tok-kw">anytype</span>, args: <span class="tok-kw">anytype</span>) <span class="tok-kw">error</span>{OutOfMemory}!<span class="tok-type">void</span> {</span>
<span class="line" id="L69">            <span class="tok-kw">var</span> frame = <span class="tok-kw">try</span> self.allocator.create(<span class="tok-builtin">@TypeOf</span>(<span class="tok-builtin">@call</span>(.{ .modifier = .async_kw }, func, args)));</span>
<span class="line" id="L70">            <span class="tok-kw">errdefer</span> self.allocator.destroy(frame);</span>
<span class="line" id="L71">            <span class="tok-kw">const</span> node = <span class="tok-kw">try</span> self.allocator.create(AllocStack.Node);</span>
<span class="line" id="L72">            <span class="tok-kw">errdefer</span> self.allocator.destroy(node);</span>
<span class="line" id="L73">            node.* = AllocStack.Node{</span>
<span class="line" id="L74">                .next = <span class="tok-null">undefined</span>,</span>
<span class="line" id="L75">                .data = Node{</span>
<span class="line" id="L76">                    .handle = frame,</span>
<span class="line" id="L77">                    .bytes = std.mem.asBytes(frame),</span>
<span class="line" id="L78">                },</span>
<span class="line" id="L79">            };</span>
<span class="line" id="L80">            frame.* = <span class="tok-builtin">@call</span>(.{ .modifier = .async_kw }, func, args);</span>
<span class="line" id="L81">            self.alloc_stack.push(node);</span>
<span class="line" id="L82">        }</span>
<span class="line" id="L83"></span>
<span class="line" id="L84">        <span class="tok-comment">/// Wait for all the calls and promises of the group to complete.</span></span>
<span class="line" id="L85">        <span class="tok-comment">/// Thread-safe.</span></span>
<span class="line" id="L86">        <span class="tok-comment">/// Safe to call any number of times.</span></span>
<span class="line" id="L87">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">wait</span>(self: *Self) <span class="tok-kw">callconv</span>(.Async) ReturnType {</span>
<span class="line" id="L88">            <span class="tok-kw">const</span> held = self.lock.acquire();</span>
<span class="line" id="L89">            <span class="tok-kw">defer</span> held.release();</span>
<span class="line" id="L90"></span>
<span class="line" id="L91">            <span class="tok-kw">var</span> result: ReturnType = {};</span>
<span class="line" id="L92"></span>
<span class="line" id="L93">            <span class="tok-kw">while</span> (self.frame_stack.pop()) |node| {</span>
<span class="line" id="L94">                <span class="tok-kw">if</span> (Error == <span class="tok-type">void</span>) {</span>
<span class="line" id="L95">                    <span class="tok-kw">await</span> node.data;</span>
<span class="line" id="L96">                } <span class="tok-kw">else</span> {</span>
<span class="line" id="L97">                    (<span class="tok-kw">await</span> node.data) <span class="tok-kw">catch</span> |err| {</span>
<span class="line" id="L98">                        result = err;</span>
<span class="line" id="L99">                    };</span>
<span class="line" id="L100">                }</span>
<span class="line" id="L101">            }</span>
<span class="line" id="L102">            <span class="tok-kw">while</span> (self.alloc_stack.pop()) |node| {</span>
<span class="line" id="L103">                <span class="tok-kw">const</span> handle = node.data.handle;</span>
<span class="line" id="L104">                <span class="tok-kw">if</span> (Error == <span class="tok-type">void</span>) {</span>
<span class="line" id="L105">                    <span class="tok-kw">await</span> handle;</span>
<span class="line" id="L106">                } <span class="tok-kw">else</span> {</span>
<span class="line" id="L107">                    (<span class="tok-kw">await</span> handle) <span class="tok-kw">catch</span> |err| {</span>
<span class="line" id="L108">                        result = err;</span>
<span class="line" id="L109">                    };</span>
<span class="line" id="L110">                }</span>
<span class="line" id="L111">                self.allocator.free(node.data.bytes);</span>
<span class="line" id="L112">                self.allocator.destroy(node);</span>
<span class="line" id="L113">            }</span>
<span class="line" id="L114">            <span class="tok-kw">return</span> result;</span>
<span class="line" id="L115">        }</span>
<span class="line" id="L116">    };</span>
<span class="line" id="L117">}</span>
<span class="line" id="L118"></span>
<span class="line" id="L119"><span class="tok-kw">test</span> <span class="tok-str">&quot;std.event.Group&quot;</span> {</span>
<span class="line" id="L120">    <span class="tok-comment">// https://github.com/ziglang/zig/issues/1908</span>
</span>
<span class="line" id="L121">    <span class="tok-kw">if</span> (builtin.single_threaded) <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SkipZigTest;</span>
<span class="line" id="L122"></span>
<span class="line" id="L123">    <span class="tok-kw">if</span> (!std.io.is_async) <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SkipZigTest;</span>
<span class="line" id="L124"></span>
<span class="line" id="L125">    <span class="tok-comment">// TODO this file has bit-rotted. repair it</span>
</span>
<span class="line" id="L126">    <span class="tok-kw">if</span> (<span class="tok-null">true</span>) <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SkipZigTest;</span>
<span class="line" id="L127"></span>
<span class="line" id="L128">    _ = <span class="tok-kw">async</span> testGroup(std.heap.page_allocator);</span>
<span class="line" id="L129">}</span>
<span class="line" id="L130"><span class="tok-kw">fn</span> <span class="tok-fn">testGroup</span>(allocator: Allocator) <span class="tok-kw">callconv</span>(.Async) <span class="tok-type">void</span> {</span>
<span class="line" id="L131">    <span class="tok-kw">var</span> count: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L132">    <span class="tok-kw">var</span> group = Group(<span class="tok-type">void</span>).init(allocator);</span>
<span class="line" id="L133">    <span class="tok-kw">var</span> sleep_a_little_frame = <span class="tok-kw">async</span> sleepALittle(&amp;count);</span>
<span class="line" id="L134">    group.add(&amp;sleep_a_little_frame) <span class="tok-kw">catch</span> <span class="tok-builtin">@panic</span>(<span class="tok-str">&quot;memory&quot;</span>);</span>
<span class="line" id="L135">    <span class="tok-kw">var</span> increase_by_ten_frame = <span class="tok-kw">async</span> increaseByTen(&amp;count);</span>
<span class="line" id="L136">    group.add(&amp;increase_by_ten_frame) <span class="tok-kw">catch</span> <span class="tok-builtin">@panic</span>(<span class="tok-str">&quot;memory&quot;</span>);</span>
<span class="line" id="L137">    group.wait();</span>
<span class="line" id="L138">    <span class="tok-kw">try</span> testing.expect(count == <span class="tok-number">11</span>);</span>
<span class="line" id="L139"></span>
<span class="line" id="L140">    <span class="tok-kw">var</span> another = Group(<span class="tok-type">anyerror</span>!<span class="tok-type">void</span>).init(allocator);</span>
<span class="line" id="L141">    <span class="tok-kw">var</span> something_else_frame = <span class="tok-kw">async</span> somethingElse();</span>
<span class="line" id="L142">    another.add(&amp;something_else_frame) <span class="tok-kw">catch</span> <span class="tok-builtin">@panic</span>(<span class="tok-str">&quot;memory&quot;</span>);</span>
<span class="line" id="L143">    <span class="tok-kw">var</span> something_that_fails_frame = <span class="tok-kw">async</span> doSomethingThatFails();</span>
<span class="line" id="L144">    another.add(&amp;something_that_fails_frame) <span class="tok-kw">catch</span> <span class="tok-builtin">@panic</span>(<span class="tok-str">&quot;memory&quot;</span>);</span>
<span class="line" id="L145">    <span class="tok-kw">try</span> testing.expectError(<span class="tok-kw">error</span>.ItBroke, another.wait());</span>
<span class="line" id="L146">}</span>
<span class="line" id="L147"><span class="tok-kw">fn</span> <span class="tok-fn">sleepALittle</span>(count: *<span class="tok-type">usize</span>) <span class="tok-kw">callconv</span>(.Async) <span class="tok-type">void</span> {</span>
<span class="line" id="L148">    std.time.sleep(<span class="tok-number">1</span> * std.time.ns_per_ms);</span>
<span class="line" id="L149">    _ = <span class="tok-builtin">@atomicRmw</span>(<span class="tok-type">usize</span>, count, .Add, <span class="tok-number">1</span>, .SeqCst);</span>
<span class="line" id="L150">}</span>
<span class="line" id="L151"><span class="tok-kw">fn</span> <span class="tok-fn">increaseByTen</span>(count: *<span class="tok-type">usize</span>) <span class="tok-kw">callconv</span>(.Async) <span class="tok-type">void</span> {</span>
<span class="line" id="L152">    <span class="tok-kw">var</span> i: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L153">    <span class="tok-kw">while</span> (i &lt; <span class="tok-number">10</span>) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L154">        _ = <span class="tok-builtin">@atomicRmw</span>(<span class="tok-type">usize</span>, count, .Add, <span class="tok-number">1</span>, .SeqCst);</span>
<span class="line" id="L155">    }</span>
<span class="line" id="L156">}</span>
<span class="line" id="L157"><span class="tok-kw">fn</span> <span class="tok-fn">doSomethingThatFails</span>() <span class="tok-kw">callconv</span>(.Async) <span class="tok-type">anyerror</span>!<span class="tok-type">void</span> {}</span>
<span class="line" id="L158"><span class="tok-kw">fn</span> <span class="tok-fn">somethingElse</span>() <span class="tok-kw">callconv</span>(.Async) <span class="tok-type">anyerror</span>!<span class="tok-type">void</span> {</span>
<span class="line" id="L159">    <span class="tok-kw">return</span> <span class="tok-kw">error</span>.ItBroke;</span>
<span class="line" id="L160">}</span>
<span class="line" id="L161"></span>
</code></pre></body>
</html>