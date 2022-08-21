<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">    <title>priority_dequeue.zig - source view</title>
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
<pre><code><span class="line" id="L1"><span class="tok-kw">const</span> std = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;std.zig&quot;</span>);</span>
<span class="line" id="L2"><span class="tok-kw">const</span> Allocator = std.mem.Allocator;</span>
<span class="line" id="L3"><span class="tok-kw">const</span> assert = std.debug.assert;</span>
<span class="line" id="L4"><span class="tok-kw">const</span> Order = std.math.Order;</span>
<span class="line" id="L5"><span class="tok-kw">const</span> testing = std.testing;</span>
<span class="line" id="L6"><span class="tok-kw">const</span> expect = testing.expect;</span>
<span class="line" id="L7"><span class="tok-kw">const</span> expectEqual = testing.expectEqual;</span>
<span class="line" id="L8"><span class="tok-kw">const</span> expectError = testing.expectError;</span>
<span class="line" id="L9"></span>
<span class="line" id="L10"><span class="tok-comment">/// Priority Dequeue for storing generic data. Initialize with `init`.</span></span>
<span class="line" id="L11"><span class="tok-comment">/// Provide `compareFn` that returns `Order.lt` when its second</span></span>
<span class="line" id="L12"><span class="tok-comment">/// argument should get min-popped before its third argument,</span></span>
<span class="line" id="L13"><span class="tok-comment">/// `Order.eq` if the arguments are of equal priority, or `Order.gt`</span></span>
<span class="line" id="L14"><span class="tok-comment">/// if the third argument should be min-popped second.</span></span>
<span class="line" id="L15"><span class="tok-comment">/// Popping the max element works in reverse. For example,</span></span>
<span class="line" id="L16"><span class="tok-comment">/// to make `popMin` return the smallest number, provide</span></span>
<span class="line" id="L17"><span class="tok-comment">/// `fn lessThan(context: void, a: T, b: T) Order { _ = context; return std.math.order(a, b); }`</span></span>
<span class="line" id="L18"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">PriorityDequeue</span>(<span class="tok-kw">comptime</span> T: <span class="tok-type">type</span>, <span class="tok-kw">comptime</span> Context: <span class="tok-type">type</span>, <span class="tok-kw">comptime</span> compareFn: <span class="tok-kw">fn</span> (context: Context, a: T, b: T) Order) <span class="tok-type">type</span> {</span>
<span class="line" id="L19">    <span class="tok-kw">return</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L20">        <span class="tok-kw">const</span> Self = <span class="tok-builtin">@This</span>();</span>
<span class="line" id="L21"></span>
<span class="line" id="L22">        items: []T,</span>
<span class="line" id="L23">        len: <span class="tok-type">usize</span>,</span>
<span class="line" id="L24">        allocator: Allocator,</span>
<span class="line" id="L25">        context: Context,</span>
<span class="line" id="L26"></span>
<span class="line" id="L27">        <span class="tok-comment">/// Initialize and return a new priority dequeue.</span></span>
<span class="line" id="L28">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">init</span>(allocator: Allocator, context: Context) Self {</span>
<span class="line" id="L29">            <span class="tok-kw">return</span> Self{</span>
<span class="line" id="L30">                .items = &amp;[_]T{},</span>
<span class="line" id="L31">                .len = <span class="tok-number">0</span>,</span>
<span class="line" id="L32">                .allocator = allocator,</span>
<span class="line" id="L33">                .context = context,</span>
<span class="line" id="L34">            };</span>
<span class="line" id="L35">        }</span>
<span class="line" id="L36"></span>
<span class="line" id="L37">        <span class="tok-comment">/// Free memory used by the dequeue.</span></span>
<span class="line" id="L38">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">deinit</span>(self: Self) <span class="tok-type">void</span> {</span>
<span class="line" id="L39">            self.allocator.free(self.items);</span>
<span class="line" id="L40">        }</span>
<span class="line" id="L41"></span>
<span class="line" id="L42">        <span class="tok-comment">/// Insert a new element, maintaining priority.</span></span>
<span class="line" id="L43">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">add</span>(self: *Self, elem: T) !<span class="tok-type">void</span> {</span>
<span class="line" id="L44">            <span class="tok-kw">try</span> self.ensureUnusedCapacity(<span class="tok-number">1</span>);</span>
<span class="line" id="L45">            addUnchecked(self, elem);</span>
<span class="line" id="L46">        }</span>
<span class="line" id="L47"></span>
<span class="line" id="L48">        <span class="tok-comment">/// Add each element in `items` to the dequeue.</span></span>
<span class="line" id="L49">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">addSlice</span>(self: *Self, items: []<span class="tok-kw">const</span> T) !<span class="tok-type">void</span> {</span>
<span class="line" id="L50">            <span class="tok-kw">try</span> self.ensureUnusedCapacity(items.len);</span>
<span class="line" id="L51">            <span class="tok-kw">for</span> (items) |e| {</span>
<span class="line" id="L52">                self.addUnchecked(e);</span>
<span class="line" id="L53">            }</span>
<span class="line" id="L54">        }</span>
<span class="line" id="L55"></span>
<span class="line" id="L56">        <span class="tok-kw">fn</span> <span class="tok-fn">addUnchecked</span>(self: *Self, elem: T) <span class="tok-type">void</span> {</span>
<span class="line" id="L57">            self.items[self.len] = elem;</span>
<span class="line" id="L58"></span>
<span class="line" id="L59">            <span class="tok-kw">if</span> (self.len &gt; <span class="tok-number">0</span>) {</span>
<span class="line" id="L60">                <span class="tok-kw">const</span> start = self.getStartForSiftUp(elem, self.len);</span>
<span class="line" id="L61">                self.siftUp(start);</span>
<span class="line" id="L62">            }</span>
<span class="line" id="L63"></span>
<span class="line" id="L64">            self.len += <span class="tok-number">1</span>;</span>
<span class="line" id="L65">        }</span>
<span class="line" id="L66"></span>
<span class="line" id="L67">        <span class="tok-kw">fn</span> <span class="tok-fn">isMinLayer</span>(index: <span class="tok-type">usize</span>) <span class="tok-type">bool</span> {</span>
<span class="line" id="L68">            <span class="tok-comment">// In the min-max heap structure:</span>
</span>
<span class="line" id="L69">            <span class="tok-comment">// The first element is on a min layer;</span>
</span>
<span class="line" id="L70">            <span class="tok-comment">// next two are on a max layer;</span>
</span>
<span class="line" id="L71">            <span class="tok-comment">// next four are on a min layer, and so on.</span>
</span>
<span class="line" id="L72">            <span class="tok-kw">const</span> leading_zeros = <span class="tok-builtin">@clz</span>(<span class="tok-type">usize</span>, index + <span class="tok-number">1</span>);</span>
<span class="line" id="L73">            <span class="tok-kw">const</span> highest_set_bit = <span class="tok-builtin">@bitSizeOf</span>(<span class="tok-type">usize</span>) - <span class="tok-number">1</span> - leading_zeros;</span>
<span class="line" id="L74">            <span class="tok-kw">return</span> (highest_set_bit &amp; <span class="tok-number">1</span>) == <span class="tok-number">0</span>;</span>
<span class="line" id="L75">        }</span>
<span class="line" id="L76"></span>
<span class="line" id="L77">        <span class="tok-kw">fn</span> <span class="tok-fn">nextIsMinLayer</span>(self: Self) <span class="tok-type">bool</span> {</span>
<span class="line" id="L78">            <span class="tok-kw">return</span> isMinLayer(self.len);</span>
<span class="line" id="L79">        }</span>
<span class="line" id="L80"></span>
<span class="line" id="L81">        <span class="tok-kw">const</span> StartIndexAndLayer = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L82">            index: <span class="tok-type">usize</span>,</span>
<span class="line" id="L83">            min_layer: <span class="tok-type">bool</span>,</span>
<span class="line" id="L84">        };</span>
<span class="line" id="L85"></span>
<span class="line" id="L86">        <span class="tok-kw">fn</span> <span class="tok-fn">getStartForSiftUp</span>(self: Self, child: T, index: <span class="tok-type">usize</span>) StartIndexAndLayer {</span>
<span class="line" id="L87">            <span class="tok-kw">var</span> child_index = index;</span>
<span class="line" id="L88">            <span class="tok-kw">var</span> parent_index = parentIndex(child_index);</span>
<span class="line" id="L89">            <span class="tok-kw">const</span> parent = self.items[parent_index];</span>
<span class="line" id="L90"></span>
<span class="line" id="L91">            <span class="tok-kw">const</span> min_layer = self.nextIsMinLayer();</span>
<span class="line" id="L92">            <span class="tok-kw">const</span> order = compareFn(self.context, child, parent);</span>
<span class="line" id="L93">            <span class="tok-kw">if</span> ((min_layer <span class="tok-kw">and</span> order == .gt) <span class="tok-kw">or</span> (!min_layer <span class="tok-kw">and</span> order == .lt)) {</span>
<span class="line" id="L94">                <span class="tok-comment">// We must swap the item with it's parent if it is on the &quot;wrong&quot; layer</span>
</span>
<span class="line" id="L95">                self.items[parent_index] = child;</span>
<span class="line" id="L96">                self.items[child_index] = parent;</span>
<span class="line" id="L97">                <span class="tok-kw">return</span> .{</span>
<span class="line" id="L98">                    .index = parent_index,</span>
<span class="line" id="L99">                    .min_layer = !min_layer,</span>
<span class="line" id="L100">                };</span>
<span class="line" id="L101">            } <span class="tok-kw">else</span> {</span>
<span class="line" id="L102">                <span class="tok-kw">return</span> .{</span>
<span class="line" id="L103">                    .index = child_index,</span>
<span class="line" id="L104">                    .min_layer = min_layer,</span>
<span class="line" id="L105">                };</span>
<span class="line" id="L106">            }</span>
<span class="line" id="L107">        }</span>
<span class="line" id="L108"></span>
<span class="line" id="L109">        <span class="tok-kw">fn</span> <span class="tok-fn">siftUp</span>(self: *Self, start: StartIndexAndLayer) <span class="tok-type">void</span> {</span>
<span class="line" id="L110">            <span class="tok-kw">if</span> (start.min_layer) {</span>
<span class="line" id="L111">                doSiftUp(self, start.index, .lt);</span>
<span class="line" id="L112">            } <span class="tok-kw">else</span> {</span>
<span class="line" id="L113">                doSiftUp(self, start.index, .gt);</span>
<span class="line" id="L114">            }</span>
<span class="line" id="L115">        }</span>
<span class="line" id="L116"></span>
<span class="line" id="L117">        <span class="tok-kw">fn</span> <span class="tok-fn">doSiftUp</span>(self: *Self, start_index: <span class="tok-type">usize</span>, target_order: Order) <span class="tok-type">void</span> {</span>
<span class="line" id="L118">            <span class="tok-kw">var</span> child_index = start_index;</span>
<span class="line" id="L119">            <span class="tok-kw">while</span> (child_index &gt; <span class="tok-number">2</span>) {</span>
<span class="line" id="L120">                <span class="tok-kw">var</span> grandparent_index = grandparentIndex(child_index);</span>
<span class="line" id="L121">                <span class="tok-kw">const</span> child = self.items[child_index];</span>
<span class="line" id="L122">                <span class="tok-kw">const</span> grandparent = self.items[grandparent_index];</span>
<span class="line" id="L123"></span>
<span class="line" id="L124">                <span class="tok-comment">// If the grandparent is already better or equal, we have gone as far as we need to</span>
</span>
<span class="line" id="L125">                <span class="tok-kw">if</span> (compareFn(self.context, child, grandparent) != target_order) <span class="tok-kw">break</span>;</span>
<span class="line" id="L126"></span>
<span class="line" id="L127">                <span class="tok-comment">// Otherwise swap the item with it's grandparent</span>
</span>
<span class="line" id="L128">                self.items[grandparent_index] = child;</span>
<span class="line" id="L129">                self.items[child_index] = grandparent;</span>
<span class="line" id="L130">                child_index = grandparent_index;</span>
<span class="line" id="L131">            }</span>
<span class="line" id="L132">        }</span>
<span class="line" id="L133"></span>
<span class="line" id="L134">        <span class="tok-comment">/// Look at the smallest element in the dequeue. Returns</span></span>
<span class="line" id="L135">        <span class="tok-comment">/// `null` if empty.</span></span>
<span class="line" id="L136">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">peekMin</span>(self: *Self) ?T {</span>
<span class="line" id="L137">            <span class="tok-kw">return</span> <span class="tok-kw">if</span> (self.len &gt; <span class="tok-number">0</span>) self.items[<span class="tok-number">0</span>] <span class="tok-kw">else</span> <span class="tok-null">null</span>;</span>
<span class="line" id="L138">        }</span>
<span class="line" id="L139"></span>
<span class="line" id="L140">        <span class="tok-comment">/// Look at the largest element in the dequeue. Returns</span></span>
<span class="line" id="L141">        <span class="tok-comment">/// `null` if empty.</span></span>
<span class="line" id="L142">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">peekMax</span>(self: *Self) ?T {</span>
<span class="line" id="L143">            <span class="tok-kw">if</span> (self.len == <span class="tok-number">0</span>) <span class="tok-kw">return</span> <span class="tok-null">null</span>;</span>
<span class="line" id="L144">            <span class="tok-kw">if</span> (self.len == <span class="tok-number">1</span>) <span class="tok-kw">return</span> self.items[<span class="tok-number">0</span>];</span>
<span class="line" id="L145">            <span class="tok-kw">if</span> (self.len == <span class="tok-number">2</span>) <span class="tok-kw">return</span> self.items[<span class="tok-number">1</span>];</span>
<span class="line" id="L146">            <span class="tok-kw">return</span> self.bestItemAtIndices(<span class="tok-number">1</span>, <span class="tok-number">2</span>, .gt).item;</span>
<span class="line" id="L147">        }</span>
<span class="line" id="L148"></span>
<span class="line" id="L149">        <span class="tok-kw">fn</span> <span class="tok-fn">maxIndex</span>(self: Self) ?<span class="tok-type">usize</span> {</span>
<span class="line" id="L150">            <span class="tok-kw">if</span> (self.len == <span class="tok-number">0</span>) <span class="tok-kw">return</span> <span class="tok-null">null</span>;</span>
<span class="line" id="L151">            <span class="tok-kw">if</span> (self.len == <span class="tok-number">1</span>) <span class="tok-kw">return</span> <span class="tok-number">0</span>;</span>
<span class="line" id="L152">            <span class="tok-kw">if</span> (self.len == <span class="tok-number">2</span>) <span class="tok-kw">return</span> <span class="tok-number">1</span>;</span>
<span class="line" id="L153">            <span class="tok-kw">return</span> self.bestItemAtIndices(<span class="tok-number">1</span>, <span class="tok-number">2</span>, .gt).index;</span>
<span class="line" id="L154">        }</span>
<span class="line" id="L155"></span>
<span class="line" id="L156">        <span class="tok-comment">/// Pop the smallest element from the dequeue. Returns</span></span>
<span class="line" id="L157">        <span class="tok-comment">/// `null` if empty.</span></span>
<span class="line" id="L158">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">removeMinOrNull</span>(self: *Self) ?T {</span>
<span class="line" id="L159">            <span class="tok-kw">return</span> <span class="tok-kw">if</span> (self.len &gt; <span class="tok-number">0</span>) self.removeMin() <span class="tok-kw">else</span> <span class="tok-null">null</span>;</span>
<span class="line" id="L160">        }</span>
<span class="line" id="L161"></span>
<span class="line" id="L162">        <span class="tok-comment">/// Remove and return the smallest element from the</span></span>
<span class="line" id="L163">        <span class="tok-comment">/// dequeue.</span></span>
<span class="line" id="L164">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">removeMin</span>(self: *Self) T {</span>
<span class="line" id="L165">            <span class="tok-kw">return</span> self.removeIndex(<span class="tok-number">0</span>);</span>
<span class="line" id="L166">        }</span>
<span class="line" id="L167"></span>
<span class="line" id="L168">        <span class="tok-comment">/// Pop the largest element from the dequeue. Returns</span></span>
<span class="line" id="L169">        <span class="tok-comment">/// `null` if empty.</span></span>
<span class="line" id="L170">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">removeMaxOrNull</span>(self: *Self) ?T {</span>
<span class="line" id="L171">            <span class="tok-kw">return</span> <span class="tok-kw">if</span> (self.len &gt; <span class="tok-number">0</span>) self.removeMax() <span class="tok-kw">else</span> <span class="tok-null">null</span>;</span>
<span class="line" id="L172">        }</span>
<span class="line" id="L173"></span>
<span class="line" id="L174">        <span class="tok-comment">/// Remove and return the largest element from the</span></span>
<span class="line" id="L175">        <span class="tok-comment">/// dequeue.</span></span>
<span class="line" id="L176">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">removeMax</span>(self: *Self) T {</span>
<span class="line" id="L177">            <span class="tok-kw">return</span> self.removeIndex(self.maxIndex().?);</span>
<span class="line" id="L178">        }</span>
<span class="line" id="L179"></span>
<span class="line" id="L180">        <span class="tok-comment">/// Remove and return element at index. Indices are in the</span></span>
<span class="line" id="L181">        <span class="tok-comment">/// same order as iterator, which is not necessarily priority</span></span>
<span class="line" id="L182">        <span class="tok-comment">/// order.</span></span>
<span class="line" id="L183">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">removeIndex</span>(self: *Self, index: <span class="tok-type">usize</span>) T {</span>
<span class="line" id="L184">            assert(self.len &gt; index);</span>
<span class="line" id="L185">            <span class="tok-kw">const</span> item = self.items[index];</span>
<span class="line" id="L186">            <span class="tok-kw">const</span> last = self.items[self.len - <span class="tok-number">1</span>];</span>
<span class="line" id="L187"></span>
<span class="line" id="L188">            self.items[index] = last;</span>
<span class="line" id="L189">            self.len -= <span class="tok-number">1</span>;</span>
<span class="line" id="L190">            siftDown(self, index);</span>
<span class="line" id="L191"></span>
<span class="line" id="L192">            <span class="tok-kw">return</span> item;</span>
<span class="line" id="L193">        }</span>
<span class="line" id="L194"></span>
<span class="line" id="L195">        <span class="tok-kw">fn</span> <span class="tok-fn">siftDown</span>(self: *Self, index: <span class="tok-type">usize</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L196">            <span class="tok-kw">if</span> (isMinLayer(index)) {</span>
<span class="line" id="L197">                self.doSiftDown(index, .lt);</span>
<span class="line" id="L198">            } <span class="tok-kw">else</span> {</span>
<span class="line" id="L199">                self.doSiftDown(index, .gt);</span>
<span class="line" id="L200">            }</span>
<span class="line" id="L201">        }</span>
<span class="line" id="L202"></span>
<span class="line" id="L203">        <span class="tok-kw">fn</span> <span class="tok-fn">doSiftDown</span>(self: *Self, start_index: <span class="tok-type">usize</span>, target_order: Order) <span class="tok-type">void</span> {</span>
<span class="line" id="L204">            <span class="tok-kw">var</span> index = start_index;</span>
<span class="line" id="L205">            <span class="tok-kw">const</span> half = self.len &gt;&gt; <span class="tok-number">1</span>;</span>
<span class="line" id="L206">            <span class="tok-kw">while</span> (<span class="tok-null">true</span>) {</span>
<span class="line" id="L207">                <span class="tok-kw">const</span> first_grandchild_index = firstGrandchildIndex(index);</span>
<span class="line" id="L208">                <span class="tok-kw">const</span> last_grandchild_index = first_grandchild_index + <span class="tok-number">3</span>;</span>
<span class="line" id="L209"></span>
<span class="line" id="L210">                <span class="tok-kw">const</span> elem = self.items[index];</span>
<span class="line" id="L211"></span>
<span class="line" id="L212">                <span class="tok-kw">if</span> (last_grandchild_index &lt; self.len) {</span>
<span class="line" id="L213">                    <span class="tok-comment">// All four grandchildren exist</span>
</span>
<span class="line" id="L214">                    <span class="tok-kw">const</span> index2 = first_grandchild_index + <span class="tok-number">1</span>;</span>
<span class="line" id="L215">                    <span class="tok-kw">const</span> index3 = index2 + <span class="tok-number">1</span>;</span>
<span class="line" id="L216"></span>
<span class="line" id="L217">                    <span class="tok-comment">// Find the best grandchild</span>
</span>
<span class="line" id="L218">                    <span class="tok-kw">const</span> best_left = self.bestItemAtIndices(first_grandchild_index, index2, target_order);</span>
<span class="line" id="L219">                    <span class="tok-kw">const</span> best_right = self.bestItemAtIndices(index3, last_grandchild_index, target_order);</span>
<span class="line" id="L220">                    <span class="tok-kw">const</span> best_grandchild = self.bestItem(best_left, best_right, target_order);</span>
<span class="line" id="L221"></span>
<span class="line" id="L222">                    <span class="tok-comment">// If the item is better than or equal to its best grandchild, we are done</span>
</span>
<span class="line" id="L223">                    <span class="tok-kw">if</span> (compareFn(self.context, best_grandchild.item, elem) != target_order) <span class="tok-kw">return</span>;</span>
<span class="line" id="L224"></span>
<span class="line" id="L225">                    <span class="tok-comment">// Otherwise, swap them</span>
</span>
<span class="line" id="L226">                    self.items[best_grandchild.index] = elem;</span>
<span class="line" id="L227">                    self.items[index] = best_grandchild.item;</span>
<span class="line" id="L228">                    index = best_grandchild.index;</span>
<span class="line" id="L229"></span>
<span class="line" id="L230">                    <span class="tok-comment">// We might need to swap the element with it's parent</span>
</span>
<span class="line" id="L231">                    self.swapIfParentIsBetter(elem, index, target_order);</span>
<span class="line" id="L232">                } <span class="tok-kw">else</span> {</span>
<span class="line" id="L233">                    <span class="tok-comment">// The children or grandchildren are the last layer</span>
</span>
<span class="line" id="L234">                    <span class="tok-kw">const</span> first_child_index = firstChildIndex(index);</span>
<span class="line" id="L235">                    <span class="tok-kw">if</span> (first_child_index &gt; self.len) <span class="tok-kw">return</span>;</span>
<span class="line" id="L236"></span>
<span class="line" id="L237">                    <span class="tok-kw">const</span> best_descendent = self.bestDescendent(first_child_index, first_grandchild_index, target_order);</span>
<span class="line" id="L238"></span>
<span class="line" id="L239">                    <span class="tok-comment">// If the item is better than or equal to its best descendant, we are done</span>
</span>
<span class="line" id="L240">                    <span class="tok-kw">if</span> (compareFn(self.context, best_descendent.item, elem) != target_order) <span class="tok-kw">return</span>;</span>
<span class="line" id="L241"></span>
<span class="line" id="L242">                    <span class="tok-comment">// Otherwise swap them</span>
</span>
<span class="line" id="L243">                    self.items[best_descendent.index] = elem;</span>
<span class="line" id="L244">                    self.items[index] = best_descendent.item;</span>
<span class="line" id="L245">                    index = best_descendent.index;</span>
<span class="line" id="L246"></span>
<span class="line" id="L247">                    <span class="tok-comment">// If we didn't swap a grandchild, we are done</span>
</span>
<span class="line" id="L248">                    <span class="tok-kw">if</span> (index &lt; first_grandchild_index) <span class="tok-kw">return</span>;</span>
<span class="line" id="L249"></span>
<span class="line" id="L250">                    <span class="tok-comment">// We might need to swap the element with it's parent</span>
</span>
<span class="line" id="L251">                    self.swapIfParentIsBetter(elem, index, target_order);</span>
<span class="line" id="L252">                    <span class="tok-kw">return</span>;</span>
<span class="line" id="L253">                }</span>
<span class="line" id="L254"></span>
<span class="line" id="L255">                <span class="tok-comment">// If we are now in the last layer, we are done</span>
</span>
<span class="line" id="L256">                <span class="tok-kw">if</span> (index &gt;= half) <span class="tok-kw">return</span>;</span>
<span class="line" id="L257">            }</span>
<span class="line" id="L258">        }</span>
<span class="line" id="L259"></span>
<span class="line" id="L260">        <span class="tok-kw">fn</span> <span class="tok-fn">swapIfParentIsBetter</span>(self: *Self, child: T, child_index: <span class="tok-type">usize</span>, target_order: Order) <span class="tok-type">void</span> {</span>
<span class="line" id="L261">            <span class="tok-kw">const</span> parent_index = parentIndex(child_index);</span>
<span class="line" id="L262">            <span class="tok-kw">const</span> parent = self.items[parent_index];</span>
<span class="line" id="L263"></span>
<span class="line" id="L264">            <span class="tok-kw">if</span> (compareFn(self.context, parent, child) == target_order) {</span>
<span class="line" id="L265">                self.items[parent_index] = child;</span>
<span class="line" id="L266">                self.items[child_index] = parent;</span>
<span class="line" id="L267">            }</span>
<span class="line" id="L268">        }</span>
<span class="line" id="L269"></span>
<span class="line" id="L270">        <span class="tok-kw">const</span> ItemAndIndex = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L271">            item: T,</span>
<span class="line" id="L272">            index: <span class="tok-type">usize</span>,</span>
<span class="line" id="L273">        };</span>
<span class="line" id="L274"></span>
<span class="line" id="L275">        <span class="tok-kw">fn</span> <span class="tok-fn">getItem</span>(self: Self, index: <span class="tok-type">usize</span>) ItemAndIndex {</span>
<span class="line" id="L276">            <span class="tok-kw">return</span> .{</span>
<span class="line" id="L277">                .item = self.items[index],</span>
<span class="line" id="L278">                .index = index,</span>
<span class="line" id="L279">            };</span>
<span class="line" id="L280">        }</span>
<span class="line" id="L281"></span>
<span class="line" id="L282">        <span class="tok-kw">fn</span> <span class="tok-fn">bestItem</span>(self: Self, item1: ItemAndIndex, item2: ItemAndIndex, target_order: Order) ItemAndIndex {</span>
<span class="line" id="L283">            <span class="tok-kw">if</span> (compareFn(self.context, item1.item, item2.item) == target_order) {</span>
<span class="line" id="L284">                <span class="tok-kw">return</span> item1;</span>
<span class="line" id="L285">            } <span class="tok-kw">else</span> {</span>
<span class="line" id="L286">                <span class="tok-kw">return</span> item2;</span>
<span class="line" id="L287">            }</span>
<span class="line" id="L288">        }</span>
<span class="line" id="L289"></span>
<span class="line" id="L290">        <span class="tok-kw">fn</span> <span class="tok-fn">bestItemAtIndices</span>(self: Self, index1: <span class="tok-type">usize</span>, index2: <span class="tok-type">usize</span>, target_order: Order) ItemAndIndex {</span>
<span class="line" id="L291">            <span class="tok-kw">var</span> item1 = self.getItem(index1);</span>
<span class="line" id="L292">            <span class="tok-kw">var</span> item2 = self.getItem(index2);</span>
<span class="line" id="L293">            <span class="tok-kw">return</span> self.bestItem(item1, item2, target_order);</span>
<span class="line" id="L294">        }</span>
<span class="line" id="L295"></span>
<span class="line" id="L296">        <span class="tok-kw">fn</span> <span class="tok-fn">bestDescendent</span>(self: Self, first_child_index: <span class="tok-type">usize</span>, first_grandchild_index: <span class="tok-type">usize</span>, target_order: Order) ItemAndIndex {</span>
<span class="line" id="L297">            <span class="tok-kw">const</span> second_child_index = first_child_index + <span class="tok-number">1</span>;</span>
<span class="line" id="L298">            <span class="tok-kw">if</span> (first_grandchild_index &gt;= self.len) {</span>
<span class="line" id="L299">                <span class="tok-comment">// No grandchildren, find the best child (second may not exist)</span>
</span>
<span class="line" id="L300">                <span class="tok-kw">if</span> (second_child_index &gt;= self.len) {</span>
<span class="line" id="L301">                    <span class="tok-kw">return</span> .{</span>
<span class="line" id="L302">                        .item = self.items[first_child_index],</span>
<span class="line" id="L303">                        .index = first_child_index,</span>
<span class="line" id="L304">                    };</span>
<span class="line" id="L305">                } <span class="tok-kw">else</span> {</span>
<span class="line" id="L306">                    <span class="tok-kw">return</span> self.bestItemAtIndices(first_child_index, second_child_index, target_order);</span>
<span class="line" id="L307">                }</span>
<span class="line" id="L308">            }</span>
<span class="line" id="L309"></span>
<span class="line" id="L310">            <span class="tok-kw">const</span> second_grandchild_index = first_grandchild_index + <span class="tok-number">1</span>;</span>
<span class="line" id="L311">            <span class="tok-kw">if</span> (second_grandchild_index &gt;= self.len) {</span>
<span class="line" id="L312">                <span class="tok-comment">// One grandchild, so we know there is a second child. Compare first grandchild and second child</span>
</span>
<span class="line" id="L313">                <span class="tok-kw">return</span> self.bestItemAtIndices(first_grandchild_index, second_child_index, target_order);</span>
<span class="line" id="L314">            }</span>
<span class="line" id="L315"></span>
<span class="line" id="L316">            <span class="tok-kw">const</span> best_left_grandchild_index = self.bestItemAtIndices(first_grandchild_index, second_grandchild_index, target_order).index;</span>
<span class="line" id="L317">            <span class="tok-kw">const</span> third_grandchild_index = second_grandchild_index + <span class="tok-number">1</span>;</span>
<span class="line" id="L318">            <span class="tok-kw">if</span> (third_grandchild_index &gt;= self.len) {</span>
<span class="line" id="L319">                <span class="tok-comment">// Two grandchildren, and we know the best. Compare this to second child.</span>
</span>
<span class="line" id="L320">                <span class="tok-kw">return</span> self.bestItemAtIndices(best_left_grandchild_index, second_child_index, target_order);</span>
<span class="line" id="L321">            } <span class="tok-kw">else</span> {</span>
<span class="line" id="L322">                <span class="tok-comment">// Three grandchildren, compare the min of the first two with the third</span>
</span>
<span class="line" id="L323">                <span class="tok-kw">return</span> self.bestItemAtIndices(best_left_grandchild_index, third_grandchild_index, target_order);</span>
<span class="line" id="L324">            }</span>
<span class="line" id="L325">        }</span>
<span class="line" id="L326"></span>
<span class="line" id="L327">        <span class="tok-comment">/// Return the number of elements remaining in the dequeue</span></span>
<span class="line" id="L328">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">count</span>(self: Self) <span class="tok-type">usize</span> {</span>
<span class="line" id="L329">            <span class="tok-kw">return</span> self.len;</span>
<span class="line" id="L330">        }</span>
<span class="line" id="L331"></span>
<span class="line" id="L332">        <span class="tok-comment">/// Return the number of elements that can be added to the</span></span>
<span class="line" id="L333">        <span class="tok-comment">/// dequeue before more memory is allocated.</span></span>
<span class="line" id="L334">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">capacity</span>(self: Self) <span class="tok-type">usize</span> {</span>
<span class="line" id="L335">            <span class="tok-kw">return</span> self.items.len;</span>
<span class="line" id="L336">        }</span>
<span class="line" id="L337"></span>
<span class="line" id="L338">        <span class="tok-comment">/// Dequeue takes ownership of the passed in slice. The slice must have been</span></span>
<span class="line" id="L339">        <span class="tok-comment">/// allocated with `allocator`.</span></span>
<span class="line" id="L340">        <span class="tok-comment">/// De-initialize with `deinit`.</span></span>
<span class="line" id="L341">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">fromOwnedSlice</span>(allocator: Allocator, items: []T, context: Context) Self {</span>
<span class="line" id="L342">            <span class="tok-kw">var</span> queue = Self{</span>
<span class="line" id="L343">                .items = items,</span>
<span class="line" id="L344">                .len = items.len,</span>
<span class="line" id="L345">                .allocator = allocator,</span>
<span class="line" id="L346">                .context = context,</span>
<span class="line" id="L347">            };</span>
<span class="line" id="L348"></span>
<span class="line" id="L349">            <span class="tok-kw">if</span> (queue.len &lt;= <span class="tok-number">1</span>) <span class="tok-kw">return</span> queue;</span>
<span class="line" id="L350"></span>
<span class="line" id="L351">            <span class="tok-kw">const</span> half = (queue.len &gt;&gt; <span class="tok-number">1</span>) - <span class="tok-number">1</span>;</span>
<span class="line" id="L352">            <span class="tok-kw">var</span> i: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L353">            <span class="tok-kw">while</span> (i &lt;= half) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L354">                <span class="tok-kw">const</span> index = half - i;</span>
<span class="line" id="L355">                queue.siftDown(index);</span>
<span class="line" id="L356">            }</span>
<span class="line" id="L357">            <span class="tok-kw">return</span> queue;</span>
<span class="line" id="L358">        }</span>
<span class="line" id="L359"></span>
<span class="line" id="L360">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> ensureCapacity = <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;deprecated; call `ensureUnusedCapacity` or `ensureTotalCapacity`&quot;</span>);</span>
<span class="line" id="L361"></span>
<span class="line" id="L362">        <span class="tok-comment">/// Ensure that the dequeue can fit at least `new_capacity` items.</span></span>
<span class="line" id="L363">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">ensureTotalCapacity</span>(self: *Self, new_capacity: <span class="tok-type">usize</span>) !<span class="tok-type">void</span> {</span>
<span class="line" id="L364">            <span class="tok-kw">var</span> better_capacity = self.capacity();</span>
<span class="line" id="L365">            <span class="tok-kw">if</span> (better_capacity &gt;= new_capacity) <span class="tok-kw">return</span>;</span>
<span class="line" id="L366">            <span class="tok-kw">while</span> (<span class="tok-null">true</span>) {</span>
<span class="line" id="L367">                better_capacity += better_capacity / <span class="tok-number">2</span> + <span class="tok-number">8</span>;</span>
<span class="line" id="L368">                <span class="tok-kw">if</span> (better_capacity &gt;= new_capacity) <span class="tok-kw">break</span>;</span>
<span class="line" id="L369">            }</span>
<span class="line" id="L370">            self.items = <span class="tok-kw">try</span> self.allocator.realloc(self.items, better_capacity);</span>
<span class="line" id="L371">        }</span>
<span class="line" id="L372"></span>
<span class="line" id="L373">        <span class="tok-comment">/// Ensure that the dequeue can fit at least `additional_count` **more** items.</span></span>
<span class="line" id="L374">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">ensureUnusedCapacity</span>(self: *Self, additional_count: <span class="tok-type">usize</span>) !<span class="tok-type">void</span> {</span>
<span class="line" id="L375">            <span class="tok-kw">return</span> self.ensureTotalCapacity(self.len + additional_count);</span>
<span class="line" id="L376">        }</span>
<span class="line" id="L377"></span>
<span class="line" id="L378">        <span class="tok-comment">/// Reduce allocated capacity to `new_len`.</span></span>
<span class="line" id="L379">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">shrinkAndFree</span>(self: *Self, new_len: <span class="tok-type">usize</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L380">            assert(new_len &lt;= self.items.len);</span>
<span class="line" id="L381"></span>
<span class="line" id="L382">            <span class="tok-comment">// Cannot shrink to smaller than the current queue size without invalidating the heap property</span>
</span>
<span class="line" id="L383">            assert(new_len &gt;= self.len);</span>
<span class="line" id="L384"></span>
<span class="line" id="L385">            self.items = self.allocator.realloc(self.items[<span class="tok-number">0</span>..], new_len) <span class="tok-kw">catch</span> |e| <span class="tok-kw">switch</span> (e) {</span>
<span class="line" id="L386">                <span class="tok-kw">error</span>.OutOfMemory =&gt; { <span class="tok-comment">// no problem, capacity is still correct then.</span>
</span>
<span class="line" id="L387">                    self.items.len = new_len;</span>
<span class="line" id="L388">                    <span class="tok-kw">return</span>;</span>
<span class="line" id="L389">                },</span>
<span class="line" id="L390">            };</span>
<span class="line" id="L391">        }</span>
<span class="line" id="L392"></span>
<span class="line" id="L393">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">update</span>(self: *Self, elem: T, new_elem: T) !<span class="tok-type">void</span> {</span>
<span class="line" id="L394">            <span class="tok-kw">const</span> old_index = blk: {</span>
<span class="line" id="L395">                <span class="tok-kw">for</span> (self.items) |item, idx| {</span>
<span class="line" id="L396">                    <span class="tok-kw">if</span> (compareFn(self.context, item, elem).compare(.eq)) <span class="tok-kw">break</span> :blk idx;</span>
<span class="line" id="L397">                }</span>
<span class="line" id="L398">                <span class="tok-kw">return</span> <span class="tok-kw">error</span>.ElementNotFound;</span>
<span class="line" id="L399">            };</span>
<span class="line" id="L400">            _ = self.removeIndex(old_index);</span>
<span class="line" id="L401">            self.addUnchecked(new_elem);</span>
<span class="line" id="L402">        }</span>
<span class="line" id="L403"></span>
<span class="line" id="L404">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> Iterator = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L405">            queue: *PriorityDequeue(T, Context, compareFn),</span>
<span class="line" id="L406">            count: <span class="tok-type">usize</span>,</span>
<span class="line" id="L407"></span>
<span class="line" id="L408">            <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">next</span>(it: *Iterator) ?T {</span>
<span class="line" id="L409">                <span class="tok-kw">if</span> (it.count &gt;= it.queue.len) <span class="tok-kw">return</span> <span class="tok-null">null</span>;</span>
<span class="line" id="L410">                <span class="tok-kw">const</span> out = it.count;</span>
<span class="line" id="L411">                it.count += <span class="tok-number">1</span>;</span>
<span class="line" id="L412">                <span class="tok-kw">return</span> it.queue.items[out];</span>
<span class="line" id="L413">            }</span>
<span class="line" id="L414"></span>
<span class="line" id="L415">            <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">reset</span>(it: *Iterator) <span class="tok-type">void</span> {</span>
<span class="line" id="L416">                it.count = <span class="tok-number">0</span>;</span>
<span class="line" id="L417">            }</span>
<span class="line" id="L418">        };</span>
<span class="line" id="L419"></span>
<span class="line" id="L420">        <span class="tok-comment">/// Return an iterator that walks the queue without consuming</span></span>
<span class="line" id="L421">        <span class="tok-comment">/// it. Invalidated if the queue is modified.</span></span>
<span class="line" id="L422">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">iterator</span>(self: *Self) Iterator {</span>
<span class="line" id="L423">            <span class="tok-kw">return</span> Iterator{</span>
<span class="line" id="L424">                .queue = self,</span>
<span class="line" id="L425">                .count = <span class="tok-number">0</span>,</span>
<span class="line" id="L426">            };</span>
<span class="line" id="L427">        }</span>
<span class="line" id="L428"></span>
<span class="line" id="L429">        <span class="tok-kw">fn</span> <span class="tok-fn">dump</span>(self: *Self) <span class="tok-type">void</span> {</span>
<span class="line" id="L430">            <span class="tok-kw">const</span> print = std.debug.print;</span>
<span class="line" id="L431">            print(<span class="tok-str">&quot;{{ &quot;</span>, .{});</span>
<span class="line" id="L432">            print(<span class="tok-str">&quot;items: &quot;</span>, .{});</span>
<span class="line" id="L433">            <span class="tok-kw">for</span> (self.items) |e, i| {</span>
<span class="line" id="L434">                <span class="tok-kw">if</span> (i &gt;= self.len) <span class="tok-kw">break</span>;</span>
<span class="line" id="L435">                print(<span class="tok-str">&quot;{}, &quot;</span>, .{e});</span>
<span class="line" id="L436">            }</span>
<span class="line" id="L437">            print(<span class="tok-str">&quot;array: &quot;</span>, .{});</span>
<span class="line" id="L438">            <span class="tok-kw">for</span> (self.items) |e| {</span>
<span class="line" id="L439">                print(<span class="tok-str">&quot;{}, &quot;</span>, .{e});</span>
<span class="line" id="L440">            }</span>
<span class="line" id="L441">            print(<span class="tok-str">&quot;len: {} &quot;</span>, .{self.len});</span>
<span class="line" id="L442">            print(<span class="tok-str">&quot;capacity: {}&quot;</span>, .{self.capacity()});</span>
<span class="line" id="L443">            print(<span class="tok-str">&quot; }}\n&quot;</span>, .{});</span>
<span class="line" id="L444">        }</span>
<span class="line" id="L445"></span>
<span class="line" id="L446">        <span class="tok-kw">fn</span> <span class="tok-fn">parentIndex</span>(index: <span class="tok-type">usize</span>) <span class="tok-type">usize</span> {</span>
<span class="line" id="L447">            <span class="tok-kw">return</span> (index - <span class="tok-number">1</span>) &gt;&gt; <span class="tok-number">1</span>;</span>
<span class="line" id="L448">        }</span>
<span class="line" id="L449"></span>
<span class="line" id="L450">        <span class="tok-kw">fn</span> <span class="tok-fn">grandparentIndex</span>(index: <span class="tok-type">usize</span>) <span class="tok-type">usize</span> {</span>
<span class="line" id="L451">            <span class="tok-kw">return</span> parentIndex(parentIndex(index));</span>
<span class="line" id="L452">        }</span>
<span class="line" id="L453"></span>
<span class="line" id="L454">        <span class="tok-kw">fn</span> <span class="tok-fn">firstChildIndex</span>(index: <span class="tok-type">usize</span>) <span class="tok-type">usize</span> {</span>
<span class="line" id="L455">            <span class="tok-kw">return</span> (index &lt;&lt; <span class="tok-number">1</span>) + <span class="tok-number">1</span>;</span>
<span class="line" id="L456">        }</span>
<span class="line" id="L457"></span>
<span class="line" id="L458">        <span class="tok-kw">fn</span> <span class="tok-fn">firstGrandchildIndex</span>(index: <span class="tok-type">usize</span>) <span class="tok-type">usize</span> {</span>
<span class="line" id="L459">            <span class="tok-kw">return</span> firstChildIndex(firstChildIndex(index));</span>
<span class="line" id="L460">        }</span>
<span class="line" id="L461">    };</span>
<span class="line" id="L462">}</span>
<span class="line" id="L463"></span>
<span class="line" id="L464"><span class="tok-kw">fn</span> <span class="tok-fn">lessThanComparison</span>(context: <span class="tok-type">void</span>, a: <span class="tok-type">u32</span>, b: <span class="tok-type">u32</span>) Order {</span>
<span class="line" id="L465">    _ = context;</span>
<span class="line" id="L466">    <span class="tok-kw">return</span> std.math.order(a, b);</span>
<span class="line" id="L467">}</span>
<span class="line" id="L468"></span>
<span class="line" id="L469"><span class="tok-kw">const</span> PDQ = PriorityDequeue(<span class="tok-type">u32</span>, <span class="tok-type">void</span>, lessThanComparison);</span>
<span class="line" id="L470"></span>
<span class="line" id="L471"><span class="tok-kw">test</span> <span class="tok-str">&quot;std.PriorityDequeue: add and remove min&quot;</span> {</span>
<span class="line" id="L472">    <span class="tok-kw">var</span> queue = PDQ.init(testing.allocator, {});</span>
<span class="line" id="L473">    <span class="tok-kw">defer</span> queue.deinit();</span>
<span class="line" id="L474"></span>
<span class="line" id="L475">    <span class="tok-kw">try</span> queue.add(<span class="tok-number">54</span>);</span>
<span class="line" id="L476">    <span class="tok-kw">try</span> queue.add(<span class="tok-number">12</span>);</span>
<span class="line" id="L477">    <span class="tok-kw">try</span> queue.add(<span class="tok-number">7</span>);</span>
<span class="line" id="L478">    <span class="tok-kw">try</span> queue.add(<span class="tok-number">23</span>);</span>
<span class="line" id="L479">    <span class="tok-kw">try</span> queue.add(<span class="tok-number">25</span>);</span>
<span class="line" id="L480">    <span class="tok-kw">try</span> queue.add(<span class="tok-number">13</span>);</span>
<span class="line" id="L481"></span>
<span class="line" id="L482">    <span class="tok-kw">try</span> expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">7</span>), queue.removeMin());</span>
<span class="line" id="L483">    <span class="tok-kw">try</span> expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">12</span>), queue.removeMin());</span>
<span class="line" id="L484">    <span class="tok-kw">try</span> expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">13</span>), queue.removeMin());</span>
<span class="line" id="L485">    <span class="tok-kw">try</span> expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">23</span>), queue.removeMin());</span>
<span class="line" id="L486">    <span class="tok-kw">try</span> expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">25</span>), queue.removeMin());</span>
<span class="line" id="L487">    <span class="tok-kw">try</span> expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">54</span>), queue.removeMin());</span>
<span class="line" id="L488">}</span>
<span class="line" id="L489"></span>
<span class="line" id="L490"><span class="tok-kw">test</span> <span class="tok-str">&quot;std.PriorityDequeue: add and remove min structs&quot;</span> {</span>
<span class="line" id="L491">    <span class="tok-kw">const</span> S = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L492">        size: <span class="tok-type">u32</span>,</span>
<span class="line" id="L493">    };</span>
<span class="line" id="L494">    <span class="tok-kw">var</span> queue = PriorityDequeue(S, <span class="tok-type">void</span>, <span class="tok-kw">struct</span> {</span>
<span class="line" id="L495">        <span class="tok-kw">fn</span> <span class="tok-fn">order</span>(context: <span class="tok-type">void</span>, a: S, b: S) Order {</span>
<span class="line" id="L496">            _ = context;</span>
<span class="line" id="L497">            <span class="tok-kw">return</span> std.math.order(a.size, b.size);</span>
<span class="line" id="L498">        }</span>
<span class="line" id="L499">    }.order).init(testing.allocator, {});</span>
<span class="line" id="L500">    <span class="tok-kw">defer</span> queue.deinit();</span>
<span class="line" id="L501"></span>
<span class="line" id="L502">    <span class="tok-kw">try</span> queue.add(.{ .size = <span class="tok-number">54</span> });</span>
<span class="line" id="L503">    <span class="tok-kw">try</span> queue.add(.{ .size = <span class="tok-number">12</span> });</span>
<span class="line" id="L504">    <span class="tok-kw">try</span> queue.add(.{ .size = <span class="tok-number">7</span> });</span>
<span class="line" id="L505">    <span class="tok-kw">try</span> queue.add(.{ .size = <span class="tok-number">23</span> });</span>
<span class="line" id="L506">    <span class="tok-kw">try</span> queue.add(.{ .size = <span class="tok-number">25</span> });</span>
<span class="line" id="L507">    <span class="tok-kw">try</span> queue.add(.{ .size = <span class="tok-number">13</span> });</span>
<span class="line" id="L508"></span>
<span class="line" id="L509">    <span class="tok-kw">try</span> expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">7</span>), queue.removeMin().size);</span>
<span class="line" id="L510">    <span class="tok-kw">try</span> expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">12</span>), queue.removeMin().size);</span>
<span class="line" id="L511">    <span class="tok-kw">try</span> expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">13</span>), queue.removeMin().size);</span>
<span class="line" id="L512">    <span class="tok-kw">try</span> expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">23</span>), queue.removeMin().size);</span>
<span class="line" id="L513">    <span class="tok-kw">try</span> expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">25</span>), queue.removeMin().size);</span>
<span class="line" id="L514">    <span class="tok-kw">try</span> expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">54</span>), queue.removeMin().size);</span>
<span class="line" id="L515">}</span>
<span class="line" id="L516"></span>
<span class="line" id="L517"><span class="tok-kw">test</span> <span class="tok-str">&quot;std.PriorityDequeue: add and remove max&quot;</span> {</span>
<span class="line" id="L518">    <span class="tok-kw">var</span> queue = PDQ.init(testing.allocator, {});</span>
<span class="line" id="L519">    <span class="tok-kw">defer</span> queue.deinit();</span>
<span class="line" id="L520"></span>
<span class="line" id="L521">    <span class="tok-kw">try</span> queue.add(<span class="tok-number">54</span>);</span>
<span class="line" id="L522">    <span class="tok-kw">try</span> queue.add(<span class="tok-number">12</span>);</span>
<span class="line" id="L523">    <span class="tok-kw">try</span> queue.add(<span class="tok-number">7</span>);</span>
<span class="line" id="L524">    <span class="tok-kw">try</span> queue.add(<span class="tok-number">23</span>);</span>
<span class="line" id="L525">    <span class="tok-kw">try</span> queue.add(<span class="tok-number">25</span>);</span>
<span class="line" id="L526">    <span class="tok-kw">try</span> queue.add(<span class="tok-number">13</span>);</span>
<span class="line" id="L527"></span>
<span class="line" id="L528">    <span class="tok-kw">try</span> expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">54</span>), queue.removeMax());</span>
<span class="line" id="L529">    <span class="tok-kw">try</span> expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">25</span>), queue.removeMax());</span>
<span class="line" id="L530">    <span class="tok-kw">try</span> expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">23</span>), queue.removeMax());</span>
<span class="line" id="L531">    <span class="tok-kw">try</span> expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">13</span>), queue.removeMax());</span>
<span class="line" id="L532">    <span class="tok-kw">try</span> expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">12</span>), queue.removeMax());</span>
<span class="line" id="L533">    <span class="tok-kw">try</span> expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">7</span>), queue.removeMax());</span>
<span class="line" id="L534">}</span>
<span class="line" id="L535"></span>
<span class="line" id="L536"><span class="tok-kw">test</span> <span class="tok-str">&quot;std.PriorityDequeue: add and remove same min&quot;</span> {</span>
<span class="line" id="L537">    <span class="tok-kw">var</span> queue = PDQ.init(testing.allocator, {});</span>
<span class="line" id="L538">    <span class="tok-kw">defer</span> queue.deinit();</span>
<span class="line" id="L539"></span>
<span class="line" id="L540">    <span class="tok-kw">try</span> queue.add(<span class="tok-number">1</span>);</span>
<span class="line" id="L541">    <span class="tok-kw">try</span> queue.add(<span class="tok-number">1</span>);</span>
<span class="line" id="L542">    <span class="tok-kw">try</span> queue.add(<span class="tok-number">2</span>);</span>
<span class="line" id="L543">    <span class="tok-kw">try</span> queue.add(<span class="tok-number">2</span>);</span>
<span class="line" id="L544">    <span class="tok-kw">try</span> queue.add(<span class="tok-number">1</span>);</span>
<span class="line" id="L545">    <span class="tok-kw">try</span> queue.add(<span class="tok-number">1</span>);</span>
<span class="line" id="L546"></span>
<span class="line" id="L547">    <span class="tok-kw">try</span> expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">1</span>), queue.removeMin());</span>
<span class="line" id="L548">    <span class="tok-kw">try</span> expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">1</span>), queue.removeMin());</span>
<span class="line" id="L549">    <span class="tok-kw">try</span> expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">1</span>), queue.removeMin());</span>
<span class="line" id="L550">    <span class="tok-kw">try</span> expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">1</span>), queue.removeMin());</span>
<span class="line" id="L551">    <span class="tok-kw">try</span> expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">2</span>), queue.removeMin());</span>
<span class="line" id="L552">    <span class="tok-kw">try</span> expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">2</span>), queue.removeMin());</span>
<span class="line" id="L553">}</span>
<span class="line" id="L554"></span>
<span class="line" id="L555"><span class="tok-kw">test</span> <span class="tok-str">&quot;std.PriorityDequeue: add and remove same max&quot;</span> {</span>
<span class="line" id="L556">    <span class="tok-kw">var</span> queue = PDQ.init(testing.allocator, {});</span>
<span class="line" id="L557">    <span class="tok-kw">defer</span> queue.deinit();</span>
<span class="line" id="L558"></span>
<span class="line" id="L559">    <span class="tok-kw">try</span> queue.add(<span class="tok-number">1</span>);</span>
<span class="line" id="L560">    <span class="tok-kw">try</span> queue.add(<span class="tok-number">1</span>);</span>
<span class="line" id="L561">    <span class="tok-kw">try</span> queue.add(<span class="tok-number">2</span>);</span>
<span class="line" id="L562">    <span class="tok-kw">try</span> queue.add(<span class="tok-number">2</span>);</span>
<span class="line" id="L563">    <span class="tok-kw">try</span> queue.add(<span class="tok-number">1</span>);</span>
<span class="line" id="L564">    <span class="tok-kw">try</span> queue.add(<span class="tok-number">1</span>);</span>
<span class="line" id="L565"></span>
<span class="line" id="L566">    <span class="tok-kw">try</span> expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">2</span>), queue.removeMax());</span>
<span class="line" id="L567">    <span class="tok-kw">try</span> expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">2</span>), queue.removeMax());</span>
<span class="line" id="L568">    <span class="tok-kw">try</span> expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">1</span>), queue.removeMax());</span>
<span class="line" id="L569">    <span class="tok-kw">try</span> expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">1</span>), queue.removeMax());</span>
<span class="line" id="L570">    <span class="tok-kw">try</span> expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">1</span>), queue.removeMax());</span>
<span class="line" id="L571">    <span class="tok-kw">try</span> expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">1</span>), queue.removeMax());</span>
<span class="line" id="L572">}</span>
<span class="line" id="L573"></span>
<span class="line" id="L574"><span class="tok-kw">test</span> <span class="tok-str">&quot;std.PriorityDequeue: removeOrNull empty&quot;</span> {</span>
<span class="line" id="L575">    <span class="tok-kw">var</span> queue = PDQ.init(testing.allocator, {});</span>
<span class="line" id="L576">    <span class="tok-kw">defer</span> queue.deinit();</span>
<span class="line" id="L577"></span>
<span class="line" id="L578">    <span class="tok-kw">try</span> expect(queue.removeMinOrNull() == <span class="tok-null">null</span>);</span>
<span class="line" id="L579">    <span class="tok-kw">try</span> expect(queue.removeMaxOrNull() == <span class="tok-null">null</span>);</span>
<span class="line" id="L580">}</span>
<span class="line" id="L581"></span>
<span class="line" id="L582"><span class="tok-kw">test</span> <span class="tok-str">&quot;std.PriorityDequeue: edge case 3 elements&quot;</span> {</span>
<span class="line" id="L583">    <span class="tok-kw">var</span> queue = PDQ.init(testing.allocator, {});</span>
<span class="line" id="L584">    <span class="tok-kw">defer</span> queue.deinit();</span>
<span class="line" id="L585"></span>
<span class="line" id="L586">    <span class="tok-kw">try</span> queue.add(<span class="tok-number">9</span>);</span>
<span class="line" id="L587">    <span class="tok-kw">try</span> queue.add(<span class="tok-number">3</span>);</span>
<span class="line" id="L588">    <span class="tok-kw">try</span> queue.add(<span class="tok-number">2</span>);</span>
<span class="line" id="L589"></span>
<span class="line" id="L590">    <span class="tok-kw">try</span> expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">2</span>), queue.removeMin());</span>
<span class="line" id="L591">    <span class="tok-kw">try</span> expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">3</span>), queue.removeMin());</span>
<span class="line" id="L592">    <span class="tok-kw">try</span> expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">9</span>), queue.removeMin());</span>
<span class="line" id="L593">}</span>
<span class="line" id="L594"></span>
<span class="line" id="L595"><span class="tok-kw">test</span> <span class="tok-str">&quot;std.PriorityDequeue: edge case 3 elements max&quot;</span> {</span>
<span class="line" id="L596">    <span class="tok-kw">var</span> queue = PDQ.init(testing.allocator, {});</span>
<span class="line" id="L597">    <span class="tok-kw">defer</span> queue.deinit();</span>
<span class="line" id="L598"></span>
<span class="line" id="L599">    <span class="tok-kw">try</span> queue.add(<span class="tok-number">9</span>);</span>
<span class="line" id="L600">    <span class="tok-kw">try</span> queue.add(<span class="tok-number">3</span>);</span>
<span class="line" id="L601">    <span class="tok-kw">try</span> queue.add(<span class="tok-number">2</span>);</span>
<span class="line" id="L602"></span>
<span class="line" id="L603">    <span class="tok-kw">try</span> expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">9</span>), queue.removeMax());</span>
<span class="line" id="L604">    <span class="tok-kw">try</span> expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">3</span>), queue.removeMax());</span>
<span class="line" id="L605">    <span class="tok-kw">try</span> expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">2</span>), queue.removeMax());</span>
<span class="line" id="L606">}</span>
<span class="line" id="L607"></span>
<span class="line" id="L608"><span class="tok-kw">test</span> <span class="tok-str">&quot;std.PriorityDequeue: peekMin&quot;</span> {</span>
<span class="line" id="L609">    <span class="tok-kw">var</span> queue = PDQ.init(testing.allocator, {});</span>
<span class="line" id="L610">    <span class="tok-kw">defer</span> queue.deinit();</span>
<span class="line" id="L611"></span>
<span class="line" id="L612">    <span class="tok-kw">try</span> expect(queue.peekMin() == <span class="tok-null">null</span>);</span>
<span class="line" id="L613"></span>
<span class="line" id="L614">    <span class="tok-kw">try</span> queue.add(<span class="tok-number">9</span>);</span>
<span class="line" id="L615">    <span class="tok-kw">try</span> queue.add(<span class="tok-number">3</span>);</span>
<span class="line" id="L616">    <span class="tok-kw">try</span> queue.add(<span class="tok-number">2</span>);</span>
<span class="line" id="L617"></span>
<span class="line" id="L618">    <span class="tok-kw">try</span> expect(queue.peekMin().? == <span class="tok-number">2</span>);</span>
<span class="line" id="L619">    <span class="tok-kw">try</span> expect(queue.peekMin().? == <span class="tok-number">2</span>);</span>
<span class="line" id="L620">}</span>
<span class="line" id="L621"></span>
<span class="line" id="L622"><span class="tok-kw">test</span> <span class="tok-str">&quot;std.PriorityDequeue: peekMax&quot;</span> {</span>
<span class="line" id="L623">    <span class="tok-kw">var</span> queue = PDQ.init(testing.allocator, {});</span>
<span class="line" id="L624">    <span class="tok-kw">defer</span> queue.deinit();</span>
<span class="line" id="L625"></span>
<span class="line" id="L626">    <span class="tok-kw">try</span> expect(queue.peekMin() == <span class="tok-null">null</span>);</span>
<span class="line" id="L627"></span>
<span class="line" id="L628">    <span class="tok-kw">try</span> queue.add(<span class="tok-number">9</span>);</span>
<span class="line" id="L629">    <span class="tok-kw">try</span> queue.add(<span class="tok-number">3</span>);</span>
<span class="line" id="L630">    <span class="tok-kw">try</span> queue.add(<span class="tok-number">2</span>);</span>
<span class="line" id="L631"></span>
<span class="line" id="L632">    <span class="tok-kw">try</span> expect(queue.peekMax().? == <span class="tok-number">9</span>);</span>
<span class="line" id="L633">    <span class="tok-kw">try</span> expect(queue.peekMax().? == <span class="tok-number">9</span>);</span>
<span class="line" id="L634">}</span>
<span class="line" id="L635"></span>
<span class="line" id="L636"><span class="tok-kw">test</span> <span class="tok-str">&quot;std.PriorityDequeue: sift up with odd indices&quot;</span> {</span>
<span class="line" id="L637">    <span class="tok-kw">var</span> queue = PDQ.init(testing.allocator, {});</span>
<span class="line" id="L638">    <span class="tok-kw">defer</span> queue.deinit();</span>
<span class="line" id="L639">    <span class="tok-kw">const</span> items = [_]<span class="tok-type">u32</span>{ <span class="tok-number">15</span>, <span class="tok-number">7</span>, <span class="tok-number">21</span>, <span class="tok-number">14</span>, <span class="tok-number">13</span>, <span class="tok-number">22</span>, <span class="tok-number">12</span>, <span class="tok-number">6</span>, <span class="tok-number">7</span>, <span class="tok-number">25</span>, <span class="tok-number">5</span>, <span class="tok-number">24</span>, <span class="tok-number">11</span>, <span class="tok-number">16</span>, <span class="tok-number">15</span>, <span class="tok-number">24</span>, <span class="tok-number">2</span>, <span class="tok-number">1</span> };</span>
<span class="line" id="L640">    <span class="tok-kw">for</span> (items) |e| {</span>
<span class="line" id="L641">        <span class="tok-kw">try</span> queue.add(e);</span>
<span class="line" id="L642">    }</span>
<span class="line" id="L643"></span>
<span class="line" id="L644">    <span class="tok-kw">const</span> sorted_items = [_]<span class="tok-type">u32</span>{ <span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">5</span>, <span class="tok-number">6</span>, <span class="tok-number">7</span>, <span class="tok-number">7</span>, <span class="tok-number">11</span>, <span class="tok-number">12</span>, <span class="tok-number">13</span>, <span class="tok-number">14</span>, <span class="tok-number">15</span>, <span class="tok-number">15</span>, <span class="tok-number">16</span>, <span class="tok-number">21</span>, <span class="tok-number">22</span>, <span class="tok-number">24</span>, <span class="tok-number">24</span>, <span class="tok-number">25</span> };</span>
<span class="line" id="L645">    <span class="tok-kw">for</span> (sorted_items) |e| {</span>
<span class="line" id="L646">        <span class="tok-kw">try</span> expectEqual(e, queue.removeMin());</span>
<span class="line" id="L647">    }</span>
<span class="line" id="L648">}</span>
<span class="line" id="L649"></span>
<span class="line" id="L650"><span class="tok-kw">test</span> <span class="tok-str">&quot;std.PriorityDequeue: sift up with odd indices&quot;</span> {</span>
<span class="line" id="L651">    <span class="tok-kw">var</span> queue = PDQ.init(testing.allocator, {});</span>
<span class="line" id="L652">    <span class="tok-kw">defer</span> queue.deinit();</span>
<span class="line" id="L653">    <span class="tok-kw">const</span> items = [_]<span class="tok-type">u32</span>{ <span class="tok-number">15</span>, <span class="tok-number">7</span>, <span class="tok-number">21</span>, <span class="tok-number">14</span>, <span class="tok-number">13</span>, <span class="tok-number">22</span>, <span class="tok-number">12</span>, <span class="tok-number">6</span>, <span class="tok-number">7</span>, <span class="tok-number">25</span>, <span class="tok-number">5</span>, <span class="tok-number">24</span>, <span class="tok-number">11</span>, <span class="tok-number">16</span>, <span class="tok-number">15</span>, <span class="tok-number">24</span>, <span class="tok-number">2</span>, <span class="tok-number">1</span> };</span>
<span class="line" id="L654">    <span class="tok-kw">for</span> (items) |e| {</span>
<span class="line" id="L655">        <span class="tok-kw">try</span> queue.add(e);</span>
<span class="line" id="L656">    }</span>
<span class="line" id="L657"></span>
<span class="line" id="L658">    <span class="tok-kw">const</span> sorted_items = [_]<span class="tok-type">u32</span>{ <span class="tok-number">25</span>, <span class="tok-number">24</span>, <span class="tok-number">24</span>, <span class="tok-number">22</span>, <span class="tok-number">21</span>, <span class="tok-number">16</span>, <span class="tok-number">15</span>, <span class="tok-number">15</span>, <span class="tok-number">14</span>, <span class="tok-number">13</span>, <span class="tok-number">12</span>, <span class="tok-number">11</span>, <span class="tok-number">7</span>, <span class="tok-number">7</span>, <span class="tok-number">6</span>, <span class="tok-number">5</span>, <span class="tok-number">2</span>, <span class="tok-number">1</span> };</span>
<span class="line" id="L659">    <span class="tok-kw">for</span> (sorted_items) |e| {</span>
<span class="line" id="L660">        <span class="tok-kw">try</span> expectEqual(e, queue.removeMax());</span>
<span class="line" id="L661">    }</span>
<span class="line" id="L662">}</span>
<span class="line" id="L663"></span>
<span class="line" id="L664"><span class="tok-kw">test</span> <span class="tok-str">&quot;std.PriorityDequeue: addSlice min&quot;</span> {</span>
<span class="line" id="L665">    <span class="tok-kw">var</span> queue = PDQ.init(testing.allocator, {});</span>
<span class="line" id="L666">    <span class="tok-kw">defer</span> queue.deinit();</span>
<span class="line" id="L667">    <span class="tok-kw">const</span> items = [_]<span class="tok-type">u32</span>{ <span class="tok-number">15</span>, <span class="tok-number">7</span>, <span class="tok-number">21</span>, <span class="tok-number">14</span>, <span class="tok-number">13</span>, <span class="tok-number">22</span>, <span class="tok-number">12</span>, <span class="tok-number">6</span>, <span class="tok-number">7</span>, <span class="tok-number">25</span>, <span class="tok-number">5</span>, <span class="tok-number">24</span>, <span class="tok-number">11</span>, <span class="tok-number">16</span>, <span class="tok-number">15</span>, <span class="tok-number">24</span>, <span class="tok-number">2</span>, <span class="tok-number">1</span> };</span>
<span class="line" id="L668">    <span class="tok-kw">try</span> queue.addSlice(items[<span class="tok-number">0</span>..]);</span>
<span class="line" id="L669"></span>
<span class="line" id="L670">    <span class="tok-kw">const</span> sorted_items = [_]<span class="tok-type">u32</span>{ <span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">5</span>, <span class="tok-number">6</span>, <span class="tok-number">7</span>, <span class="tok-number">7</span>, <span class="tok-number">11</span>, <span class="tok-number">12</span>, <span class="tok-number">13</span>, <span class="tok-number">14</span>, <span class="tok-number">15</span>, <span class="tok-number">15</span>, <span class="tok-number">16</span>, <span class="tok-number">21</span>, <span class="tok-number">22</span>, <span class="tok-number">24</span>, <span class="tok-number">24</span>, <span class="tok-number">25</span> };</span>
<span class="line" id="L671">    <span class="tok-kw">for</span> (sorted_items) |e| {</span>
<span class="line" id="L672">        <span class="tok-kw">try</span> expectEqual(e, queue.removeMin());</span>
<span class="line" id="L673">    }</span>
<span class="line" id="L674">}</span>
<span class="line" id="L675"></span>
<span class="line" id="L676"><span class="tok-kw">test</span> <span class="tok-str">&quot;std.PriorityDequeue: addSlice max&quot;</span> {</span>
<span class="line" id="L677">    <span class="tok-kw">var</span> queue = PDQ.init(testing.allocator, {});</span>
<span class="line" id="L678">    <span class="tok-kw">defer</span> queue.deinit();</span>
<span class="line" id="L679">    <span class="tok-kw">const</span> items = [_]<span class="tok-type">u32</span>{ <span class="tok-number">15</span>, <span class="tok-number">7</span>, <span class="tok-number">21</span>, <span class="tok-number">14</span>, <span class="tok-number">13</span>, <span class="tok-number">22</span>, <span class="tok-number">12</span>, <span class="tok-number">6</span>, <span class="tok-number">7</span>, <span class="tok-number">25</span>, <span class="tok-number">5</span>, <span class="tok-number">24</span>, <span class="tok-number">11</span>, <span class="tok-number">16</span>, <span class="tok-number">15</span>, <span class="tok-number">24</span>, <span class="tok-number">2</span>, <span class="tok-number">1</span> };</span>
<span class="line" id="L680">    <span class="tok-kw">try</span> queue.addSlice(items[<span class="tok-number">0</span>..]);</span>
<span class="line" id="L681"></span>
<span class="line" id="L682">    <span class="tok-kw">const</span> sorted_items = [_]<span class="tok-type">u32</span>{ <span class="tok-number">25</span>, <span class="tok-number">24</span>, <span class="tok-number">24</span>, <span class="tok-number">22</span>, <span class="tok-number">21</span>, <span class="tok-number">16</span>, <span class="tok-number">15</span>, <span class="tok-number">15</span>, <span class="tok-number">14</span>, <span class="tok-number">13</span>, <span class="tok-number">12</span>, <span class="tok-number">11</span>, <span class="tok-number">7</span>, <span class="tok-number">7</span>, <span class="tok-number">6</span>, <span class="tok-number">5</span>, <span class="tok-number">2</span>, <span class="tok-number">1</span> };</span>
<span class="line" id="L683">    <span class="tok-kw">for</span> (sorted_items) |e| {</span>
<span class="line" id="L684">        <span class="tok-kw">try</span> expectEqual(e, queue.removeMax());</span>
<span class="line" id="L685">    }</span>
<span class="line" id="L686">}</span>
<span class="line" id="L687"></span>
<span class="line" id="L688"><span class="tok-kw">test</span> <span class="tok-str">&quot;std.PriorityDequeue: fromOwnedSlice trivial case 0&quot;</span> {</span>
<span class="line" id="L689">    <span class="tok-kw">const</span> items = [<span class="tok-number">0</span>]<span class="tok-type">u32</span>{};</span>
<span class="line" id="L690">    <span class="tok-kw">const</span> queue_items = <span class="tok-kw">try</span> testing.allocator.dupe(<span class="tok-type">u32</span>, &amp;items);</span>
<span class="line" id="L691">    <span class="tok-kw">var</span> queue = PDQ.fromOwnedSlice(testing.allocator, queue_items[<span class="tok-number">0</span>..], {});</span>
<span class="line" id="L692">    <span class="tok-kw">defer</span> queue.deinit();</span>
<span class="line" id="L693">    <span class="tok-kw">try</span> expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">usize</span>, <span class="tok-number">0</span>), queue.len);</span>
<span class="line" id="L694">    <span class="tok-kw">try</span> expect(queue.removeMinOrNull() == <span class="tok-null">null</span>);</span>
<span class="line" id="L695">}</span>
<span class="line" id="L696"></span>
<span class="line" id="L697"><span class="tok-kw">test</span> <span class="tok-str">&quot;std.PriorityDequeue: fromOwnedSlice trivial case 1&quot;</span> {</span>
<span class="line" id="L698">    <span class="tok-kw">const</span> items = [<span class="tok-number">1</span>]<span class="tok-type">u32</span>{<span class="tok-number">1</span>};</span>
<span class="line" id="L699">    <span class="tok-kw">const</span> queue_items = <span class="tok-kw">try</span> testing.allocator.dupe(<span class="tok-type">u32</span>, &amp;items);</span>
<span class="line" id="L700">    <span class="tok-kw">var</span> queue = PDQ.fromOwnedSlice(testing.allocator, queue_items[<span class="tok-number">0</span>..], {});</span>
<span class="line" id="L701">    <span class="tok-kw">defer</span> queue.deinit();</span>
<span class="line" id="L702"></span>
<span class="line" id="L703">    <span class="tok-kw">try</span> expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">usize</span>, <span class="tok-number">1</span>), queue.len);</span>
<span class="line" id="L704">    <span class="tok-kw">try</span> expectEqual(items[<span class="tok-number">0</span>], queue.removeMin());</span>
<span class="line" id="L705">    <span class="tok-kw">try</span> expect(queue.removeMinOrNull() == <span class="tok-null">null</span>);</span>
<span class="line" id="L706">}</span>
<span class="line" id="L707"></span>
<span class="line" id="L708"><span class="tok-kw">test</span> <span class="tok-str">&quot;std.PriorityDequeue: fromOwnedSlice&quot;</span> {</span>
<span class="line" id="L709">    <span class="tok-kw">const</span> items = [_]<span class="tok-type">u32</span>{ <span class="tok-number">15</span>, <span class="tok-number">7</span>, <span class="tok-number">21</span>, <span class="tok-number">14</span>, <span class="tok-number">13</span>, <span class="tok-number">22</span>, <span class="tok-number">12</span>, <span class="tok-number">6</span>, <span class="tok-number">7</span>, <span class="tok-number">25</span>, <span class="tok-number">5</span>, <span class="tok-number">24</span>, <span class="tok-number">11</span>, <span class="tok-number">16</span>, <span class="tok-number">15</span>, <span class="tok-number">24</span>, <span class="tok-number">2</span>, <span class="tok-number">1</span> };</span>
<span class="line" id="L710">    <span class="tok-kw">const</span> queue_items = <span class="tok-kw">try</span> testing.allocator.dupe(<span class="tok-type">u32</span>, items[<span class="tok-number">0</span>..]);</span>
<span class="line" id="L711">    <span class="tok-kw">var</span> queue = PDQ.fromOwnedSlice(testing.allocator, queue_items[<span class="tok-number">0</span>..], {});</span>
<span class="line" id="L712">    <span class="tok-kw">defer</span> queue.deinit();</span>
<span class="line" id="L713"></span>
<span class="line" id="L714">    <span class="tok-kw">const</span> sorted_items = [_]<span class="tok-type">u32</span>{ <span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">5</span>, <span class="tok-number">6</span>, <span class="tok-number">7</span>, <span class="tok-number">7</span>, <span class="tok-number">11</span>, <span class="tok-number">12</span>, <span class="tok-number">13</span>, <span class="tok-number">14</span>, <span class="tok-number">15</span>, <span class="tok-number">15</span>, <span class="tok-number">16</span>, <span class="tok-number">21</span>, <span class="tok-number">22</span>, <span class="tok-number">24</span>, <span class="tok-number">24</span>, <span class="tok-number">25</span> };</span>
<span class="line" id="L715">    <span class="tok-kw">for</span> (sorted_items) |e| {</span>
<span class="line" id="L716">        <span class="tok-kw">try</span> expectEqual(e, queue.removeMin());</span>
<span class="line" id="L717">    }</span>
<span class="line" id="L718">}</span>
<span class="line" id="L719"></span>
<span class="line" id="L720"><span class="tok-kw">test</span> <span class="tok-str">&quot;std.PriorityDequeue: update min queue&quot;</span> {</span>
<span class="line" id="L721">    <span class="tok-kw">var</span> queue = PDQ.init(testing.allocator, {});</span>
<span class="line" id="L722">    <span class="tok-kw">defer</span> queue.deinit();</span>
<span class="line" id="L723"></span>
<span class="line" id="L724">    <span class="tok-kw">try</span> queue.add(<span class="tok-number">55</span>);</span>
<span class="line" id="L725">    <span class="tok-kw">try</span> queue.add(<span class="tok-number">44</span>);</span>
<span class="line" id="L726">    <span class="tok-kw">try</span> queue.add(<span class="tok-number">11</span>);</span>
<span class="line" id="L727">    <span class="tok-kw">try</span> queue.update(<span class="tok-number">55</span>, <span class="tok-number">5</span>);</span>
<span class="line" id="L728">    <span class="tok-kw">try</span> queue.update(<span class="tok-number">44</span>, <span class="tok-number">4</span>);</span>
<span class="line" id="L729">    <span class="tok-kw">try</span> queue.update(<span class="tok-number">11</span>, <span class="tok-number">1</span>);</span>
<span class="line" id="L730">    <span class="tok-kw">try</span> expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">1</span>), queue.removeMin());</span>
<span class="line" id="L731">    <span class="tok-kw">try</span> expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">4</span>), queue.removeMin());</span>
<span class="line" id="L732">    <span class="tok-kw">try</span> expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">5</span>), queue.removeMin());</span>
<span class="line" id="L733">}</span>
<span class="line" id="L734"></span>
<span class="line" id="L735"><span class="tok-kw">test</span> <span class="tok-str">&quot;std.PriorityDequeue: update same min queue&quot;</span> {</span>
<span class="line" id="L736">    <span class="tok-kw">var</span> queue = PDQ.init(testing.allocator, {});</span>
<span class="line" id="L737">    <span class="tok-kw">defer</span> queue.deinit();</span>
<span class="line" id="L738"></span>
<span class="line" id="L739">    <span class="tok-kw">try</span> queue.add(<span class="tok-number">1</span>);</span>
<span class="line" id="L740">    <span class="tok-kw">try</span> queue.add(<span class="tok-number">1</span>);</span>
<span class="line" id="L741">    <span class="tok-kw">try</span> queue.add(<span class="tok-number">2</span>);</span>
<span class="line" id="L742">    <span class="tok-kw">try</span> queue.add(<span class="tok-number">2</span>);</span>
<span class="line" id="L743">    <span class="tok-kw">try</span> queue.update(<span class="tok-number">1</span>, <span class="tok-number">5</span>);</span>
<span class="line" id="L744">    <span class="tok-kw">try</span> queue.update(<span class="tok-number">2</span>, <span class="tok-number">4</span>);</span>
<span class="line" id="L745">    <span class="tok-kw">try</span> expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">1</span>), queue.removeMin());</span>
<span class="line" id="L746">    <span class="tok-kw">try</span> expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">2</span>), queue.removeMin());</span>
<span class="line" id="L747">    <span class="tok-kw">try</span> expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">4</span>), queue.removeMin());</span>
<span class="line" id="L748">    <span class="tok-kw">try</span> expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">5</span>), queue.removeMin());</span>
<span class="line" id="L749">}</span>
<span class="line" id="L750"></span>
<span class="line" id="L751"><span class="tok-kw">test</span> <span class="tok-str">&quot;std.PriorityDequeue: update max queue&quot;</span> {</span>
<span class="line" id="L752">    <span class="tok-kw">var</span> queue = PDQ.init(testing.allocator, {});</span>
<span class="line" id="L753">    <span class="tok-kw">defer</span> queue.deinit();</span>
<span class="line" id="L754"></span>
<span class="line" id="L755">    <span class="tok-kw">try</span> queue.add(<span class="tok-number">55</span>);</span>
<span class="line" id="L756">    <span class="tok-kw">try</span> queue.add(<span class="tok-number">44</span>);</span>
<span class="line" id="L757">    <span class="tok-kw">try</span> queue.add(<span class="tok-number">11</span>);</span>
<span class="line" id="L758">    <span class="tok-kw">try</span> queue.update(<span class="tok-number">55</span>, <span class="tok-number">5</span>);</span>
<span class="line" id="L759">    <span class="tok-kw">try</span> queue.update(<span class="tok-number">44</span>, <span class="tok-number">1</span>);</span>
<span class="line" id="L760">    <span class="tok-kw">try</span> queue.update(<span class="tok-number">11</span>, <span class="tok-number">4</span>);</span>
<span class="line" id="L761"></span>
<span class="line" id="L762">    <span class="tok-kw">try</span> expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">5</span>), queue.removeMax());</span>
<span class="line" id="L763">    <span class="tok-kw">try</span> expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">4</span>), queue.removeMax());</span>
<span class="line" id="L764">    <span class="tok-kw">try</span> expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">1</span>), queue.removeMax());</span>
<span class="line" id="L765">}</span>
<span class="line" id="L766"></span>
<span class="line" id="L767"><span class="tok-kw">test</span> <span class="tok-str">&quot;std.PriorityDequeue: update same max queue&quot;</span> {</span>
<span class="line" id="L768">    <span class="tok-kw">var</span> queue = PDQ.init(testing.allocator, {});</span>
<span class="line" id="L769">    <span class="tok-kw">defer</span> queue.deinit();</span>
<span class="line" id="L770"></span>
<span class="line" id="L771">    <span class="tok-kw">try</span> queue.add(<span class="tok-number">1</span>);</span>
<span class="line" id="L772">    <span class="tok-kw">try</span> queue.add(<span class="tok-number">1</span>);</span>
<span class="line" id="L773">    <span class="tok-kw">try</span> queue.add(<span class="tok-number">2</span>);</span>
<span class="line" id="L774">    <span class="tok-kw">try</span> queue.add(<span class="tok-number">2</span>);</span>
<span class="line" id="L775">    <span class="tok-kw">try</span> queue.update(<span class="tok-number">1</span>, <span class="tok-number">5</span>);</span>
<span class="line" id="L776">    <span class="tok-kw">try</span> queue.update(<span class="tok-number">2</span>, <span class="tok-number">4</span>);</span>
<span class="line" id="L777">    <span class="tok-kw">try</span> expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">5</span>), queue.removeMax());</span>
<span class="line" id="L778">    <span class="tok-kw">try</span> expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">4</span>), queue.removeMax());</span>
<span class="line" id="L779">    <span class="tok-kw">try</span> expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">2</span>), queue.removeMax());</span>
<span class="line" id="L780">    <span class="tok-kw">try</span> expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">1</span>), queue.removeMax());</span>
<span class="line" id="L781">}</span>
<span class="line" id="L782"></span>
<span class="line" id="L783"><span class="tok-kw">test</span> <span class="tok-str">&quot;std.PriorityDequeue: iterator&quot;</span> {</span>
<span class="line" id="L784">    <span class="tok-kw">var</span> queue = PDQ.init(testing.allocator, {});</span>
<span class="line" id="L785">    <span class="tok-kw">var</span> map = std.AutoHashMap(<span class="tok-type">u32</span>, <span class="tok-type">void</span>).init(testing.allocator);</span>
<span class="line" id="L786">    <span class="tok-kw">defer</span> {</span>
<span class="line" id="L787">        queue.deinit();</span>
<span class="line" id="L788">        map.deinit();</span>
<span class="line" id="L789">    }</span>
<span class="line" id="L790"></span>
<span class="line" id="L791">    <span class="tok-kw">const</span> items = [_]<span class="tok-type">u32</span>{ <span class="tok-number">54</span>, <span class="tok-number">12</span>, <span class="tok-number">7</span>, <span class="tok-number">23</span>, <span class="tok-number">25</span>, <span class="tok-number">13</span> };</span>
<span class="line" id="L792">    <span class="tok-kw">for</span> (items) |e| {</span>
<span class="line" id="L793">        _ = <span class="tok-kw">try</span> queue.add(e);</span>
<span class="line" id="L794">        _ = <span class="tok-kw">try</span> map.put(e, {});</span>
<span class="line" id="L795">    }</span>
<span class="line" id="L796"></span>
<span class="line" id="L797">    <span class="tok-kw">var</span> it = queue.iterator();</span>
<span class="line" id="L798">    <span class="tok-kw">while</span> (it.next()) |e| {</span>
<span class="line" id="L799">        _ = map.remove(e);</span>
<span class="line" id="L800">    }</span>
<span class="line" id="L801"></span>
<span class="line" id="L802">    <span class="tok-kw">try</span> expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">usize</span>, <span class="tok-number">0</span>), map.count());</span>
<span class="line" id="L803">}</span>
<span class="line" id="L804"></span>
<span class="line" id="L805"><span class="tok-kw">test</span> <span class="tok-str">&quot;std.PriorityDequeue: remove at index&quot;</span> {</span>
<span class="line" id="L806">    <span class="tok-kw">var</span> queue = PDQ.init(testing.allocator, {});</span>
<span class="line" id="L807">    <span class="tok-kw">defer</span> queue.deinit();</span>
<span class="line" id="L808"></span>
<span class="line" id="L809">    <span class="tok-kw">try</span> queue.add(<span class="tok-number">3</span>);</span>
<span class="line" id="L810">    <span class="tok-kw">try</span> queue.add(<span class="tok-number">2</span>);</span>
<span class="line" id="L811">    <span class="tok-kw">try</span> queue.add(<span class="tok-number">1</span>);</span>
<span class="line" id="L812"></span>
<span class="line" id="L813">    <span class="tok-kw">var</span> it = queue.iterator();</span>
<span class="line" id="L814">    <span class="tok-kw">var</span> elem = it.next();</span>
<span class="line" id="L815">    <span class="tok-kw">var</span> idx: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L816">    <span class="tok-kw">const</span> two_idx = <span class="tok-kw">while</span> (elem != <span class="tok-null">null</span>) : (elem = it.next()) {</span>
<span class="line" id="L817">        <span class="tok-kw">if</span> (elem.? == <span class="tok-number">2</span>)</span>
<span class="line" id="L818">            <span class="tok-kw">break</span> idx;</span>
<span class="line" id="L819">        idx += <span class="tok-number">1</span>;</span>
<span class="line" id="L820">    } <span class="tok-kw">else</span> <span class="tok-kw">unreachable</span>;</span>
<span class="line" id="L821"></span>
<span class="line" id="L822">    <span class="tok-kw">try</span> expectEqual(queue.removeIndex(two_idx), <span class="tok-number">2</span>);</span>
<span class="line" id="L823">    <span class="tok-kw">try</span> expectEqual(queue.removeMin(), <span class="tok-number">1</span>);</span>
<span class="line" id="L824">    <span class="tok-kw">try</span> expectEqual(queue.removeMin(), <span class="tok-number">3</span>);</span>
<span class="line" id="L825">    <span class="tok-kw">try</span> expectEqual(queue.removeMinOrNull(), <span class="tok-null">null</span>);</span>
<span class="line" id="L826">}</span>
<span class="line" id="L827"></span>
<span class="line" id="L828"><span class="tok-kw">test</span> <span class="tok-str">&quot;std.PriorityDequeue: iterator while empty&quot;</span> {</span>
<span class="line" id="L829">    <span class="tok-kw">var</span> queue = PDQ.init(testing.allocator, {});</span>
<span class="line" id="L830">    <span class="tok-kw">defer</span> queue.deinit();</span>
<span class="line" id="L831"></span>
<span class="line" id="L832">    <span class="tok-kw">var</span> it = queue.iterator();</span>
<span class="line" id="L833"></span>
<span class="line" id="L834">    <span class="tok-kw">try</span> expectEqual(it.next(), <span class="tok-null">null</span>);</span>
<span class="line" id="L835">}</span>
<span class="line" id="L836"></span>
<span class="line" id="L837"><span class="tok-kw">test</span> <span class="tok-str">&quot;std.PriorityDequeue: shrinkAndFree&quot;</span> {</span>
<span class="line" id="L838">    <span class="tok-kw">var</span> queue = PDQ.init(testing.allocator, {});</span>
<span class="line" id="L839">    <span class="tok-kw">defer</span> queue.deinit();</span>
<span class="line" id="L840"></span>
<span class="line" id="L841">    <span class="tok-kw">try</span> queue.ensureTotalCapacity(<span class="tok-number">4</span>);</span>
<span class="line" id="L842">    <span class="tok-kw">try</span> expect(queue.capacity() &gt;= <span class="tok-number">4</span>);</span>
<span class="line" id="L843"></span>
<span class="line" id="L844">    <span class="tok-kw">try</span> queue.add(<span class="tok-number">1</span>);</span>
<span class="line" id="L845">    <span class="tok-kw">try</span> queue.add(<span class="tok-number">2</span>);</span>
<span class="line" id="L846">    <span class="tok-kw">try</span> queue.add(<span class="tok-number">3</span>);</span>
<span class="line" id="L847">    <span class="tok-kw">try</span> expect(queue.capacity() &gt;= <span class="tok-number">4</span>);</span>
<span class="line" id="L848">    <span class="tok-kw">try</span> expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">usize</span>, <span class="tok-number">3</span>), queue.len);</span>
<span class="line" id="L849"></span>
<span class="line" id="L850">    queue.shrinkAndFree(<span class="tok-number">3</span>);</span>
<span class="line" id="L851">    <span class="tok-kw">try</span> expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">usize</span>, <span class="tok-number">3</span>), queue.capacity());</span>
<span class="line" id="L852">    <span class="tok-kw">try</span> expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">usize</span>, <span class="tok-number">3</span>), queue.len);</span>
<span class="line" id="L853"></span>
<span class="line" id="L854">    <span class="tok-kw">try</span> expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">3</span>), queue.removeMax());</span>
<span class="line" id="L855">    <span class="tok-kw">try</span> expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">2</span>), queue.removeMax());</span>
<span class="line" id="L856">    <span class="tok-kw">try</span> expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">1</span>), queue.removeMax());</span>
<span class="line" id="L857">    <span class="tok-kw">try</span> expect(queue.removeMaxOrNull() == <span class="tok-null">null</span>);</span>
<span class="line" id="L858">}</span>
<span class="line" id="L859"></span>
<span class="line" id="L860"><span class="tok-kw">test</span> <span class="tok-str">&quot;std.PriorityDequeue: fuzz testing min&quot;</span> {</span>
<span class="line" id="L861">    <span class="tok-kw">var</span> prng = std.rand.DefaultPrng.init(<span class="tok-number">0x12345678</span>);</span>
<span class="line" id="L862">    <span class="tok-kw">const</span> random = prng.random();</span>
<span class="line" id="L863"></span>
<span class="line" id="L864">    <span class="tok-kw">const</span> test_case_count = <span class="tok-number">100</span>;</span>
<span class="line" id="L865">    <span class="tok-kw">const</span> queue_size = <span class="tok-number">1_000</span>;</span>
<span class="line" id="L866"></span>
<span class="line" id="L867">    <span class="tok-kw">var</span> i: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L868">    <span class="tok-kw">while</span> (i &lt; test_case_count) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L869">        <span class="tok-kw">try</span> fuzzTestMin(random, queue_size);</span>
<span class="line" id="L870">    }</span>
<span class="line" id="L871">}</span>
<span class="line" id="L872"></span>
<span class="line" id="L873"><span class="tok-kw">fn</span> <span class="tok-fn">fuzzTestMin</span>(rng: std.rand.Random, <span class="tok-kw">comptime</span> queue_size: <span class="tok-type">usize</span>) !<span class="tok-type">void</span> {</span>
<span class="line" id="L874">    <span class="tok-kw">const</span> allocator = testing.allocator;</span>
<span class="line" id="L875">    <span class="tok-kw">const</span> items = <span class="tok-kw">try</span> generateRandomSlice(allocator, rng, queue_size);</span>
<span class="line" id="L876"></span>
<span class="line" id="L877">    <span class="tok-kw">var</span> queue = PDQ.fromOwnedSlice(allocator, items, {});</span>
<span class="line" id="L878">    <span class="tok-kw">defer</span> queue.deinit();</span>
<span class="line" id="L879"></span>
<span class="line" id="L880">    <span class="tok-kw">var</span> last_removed: ?<span class="tok-type">u32</span> = <span class="tok-null">null</span>;</span>
<span class="line" id="L881">    <span class="tok-kw">while</span> (queue.removeMinOrNull()) |next| {</span>
<span class="line" id="L882">        <span class="tok-kw">if</span> (last_removed) |last| {</span>
<span class="line" id="L883">            <span class="tok-kw">try</span> expect(last &lt;= next);</span>
<span class="line" id="L884">        }</span>
<span class="line" id="L885">        last_removed = next;</span>
<span class="line" id="L886">    }</span>
<span class="line" id="L887">}</span>
<span class="line" id="L888"></span>
<span class="line" id="L889"><span class="tok-kw">test</span> <span class="tok-str">&quot;std.PriorityDequeue: fuzz testing max&quot;</span> {</span>
<span class="line" id="L890">    <span class="tok-kw">var</span> prng = std.rand.DefaultPrng.init(<span class="tok-number">0x87654321</span>);</span>
<span class="line" id="L891">    <span class="tok-kw">const</span> random = prng.random();</span>
<span class="line" id="L892"></span>
<span class="line" id="L893">    <span class="tok-kw">const</span> test_case_count = <span class="tok-number">100</span>;</span>
<span class="line" id="L894">    <span class="tok-kw">const</span> queue_size = <span class="tok-number">1_000</span>;</span>
<span class="line" id="L895"></span>
<span class="line" id="L896">    <span class="tok-kw">var</span> i: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L897">    <span class="tok-kw">while</span> (i &lt; test_case_count) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L898">        <span class="tok-kw">try</span> fuzzTestMax(random, queue_size);</span>
<span class="line" id="L899">    }</span>
<span class="line" id="L900">}</span>
<span class="line" id="L901"></span>
<span class="line" id="L902"><span class="tok-kw">fn</span> <span class="tok-fn">fuzzTestMax</span>(rng: std.rand.Random, queue_size: <span class="tok-type">usize</span>) !<span class="tok-type">void</span> {</span>
<span class="line" id="L903">    <span class="tok-kw">const</span> allocator = testing.allocator;</span>
<span class="line" id="L904">    <span class="tok-kw">const</span> items = <span class="tok-kw">try</span> generateRandomSlice(allocator, rng, queue_size);</span>
<span class="line" id="L905"></span>
<span class="line" id="L906">    <span class="tok-kw">var</span> queue = PDQ.fromOwnedSlice(testing.allocator, items, {});</span>
<span class="line" id="L907">    <span class="tok-kw">defer</span> queue.deinit();</span>
<span class="line" id="L908"></span>
<span class="line" id="L909">    <span class="tok-kw">var</span> last_removed: ?<span class="tok-type">u32</span> = <span class="tok-null">null</span>;</span>
<span class="line" id="L910">    <span class="tok-kw">while</span> (queue.removeMaxOrNull()) |next| {</span>
<span class="line" id="L911">        <span class="tok-kw">if</span> (last_removed) |last| {</span>
<span class="line" id="L912">            <span class="tok-kw">try</span> expect(last &gt;= next);</span>
<span class="line" id="L913">        }</span>
<span class="line" id="L914">        last_removed = next;</span>
<span class="line" id="L915">    }</span>
<span class="line" id="L916">}</span>
<span class="line" id="L917"></span>
<span class="line" id="L918"><span class="tok-kw">test</span> <span class="tok-str">&quot;std.PriorityDequeue: fuzz testing min and max&quot;</span> {</span>
<span class="line" id="L919">    <span class="tok-kw">var</span> prng = std.rand.DefaultPrng.init(<span class="tok-number">0x87654321</span>);</span>
<span class="line" id="L920">    <span class="tok-kw">const</span> random = prng.random();</span>
<span class="line" id="L921"></span>
<span class="line" id="L922">    <span class="tok-kw">const</span> test_case_count = <span class="tok-number">100</span>;</span>
<span class="line" id="L923">    <span class="tok-kw">const</span> queue_size = <span class="tok-number">1_000</span>;</span>
<span class="line" id="L924"></span>
<span class="line" id="L925">    <span class="tok-kw">var</span> i: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L926">    <span class="tok-kw">while</span> (i &lt; test_case_count) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L927">        <span class="tok-kw">try</span> fuzzTestMinMax(random, queue_size);</span>
<span class="line" id="L928">    }</span>
<span class="line" id="L929">}</span>
<span class="line" id="L930"></span>
<span class="line" id="L931"><span class="tok-kw">fn</span> <span class="tok-fn">fuzzTestMinMax</span>(rng: std.rand.Random, queue_size: <span class="tok-type">usize</span>) !<span class="tok-type">void</span> {</span>
<span class="line" id="L932">    <span class="tok-kw">const</span> allocator = testing.allocator;</span>
<span class="line" id="L933">    <span class="tok-kw">const</span> items = <span class="tok-kw">try</span> generateRandomSlice(allocator, rng, queue_size);</span>
<span class="line" id="L934"></span>
<span class="line" id="L935">    <span class="tok-kw">var</span> queue = PDQ.fromOwnedSlice(allocator, items, {});</span>
<span class="line" id="L936">    <span class="tok-kw">defer</span> queue.deinit();</span>
<span class="line" id="L937"></span>
<span class="line" id="L938">    <span class="tok-kw">var</span> last_min: ?<span class="tok-type">u32</span> = <span class="tok-null">null</span>;</span>
<span class="line" id="L939">    <span class="tok-kw">var</span> last_max: ?<span class="tok-type">u32</span> = <span class="tok-null">null</span>;</span>
<span class="line" id="L940">    <span class="tok-kw">var</span> i: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L941">    <span class="tok-kw">while</span> (i &lt; queue_size) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L942">        <span class="tok-kw">if</span> (i % <span class="tok-number">2</span> == <span class="tok-number">0</span>) {</span>
<span class="line" id="L943">            <span class="tok-kw">const</span> next = queue.removeMin();</span>
<span class="line" id="L944">            <span class="tok-kw">if</span> (last_min) |last| {</span>
<span class="line" id="L945">                <span class="tok-kw">try</span> expect(last &lt;= next);</span>
<span class="line" id="L946">            }</span>
<span class="line" id="L947">            last_min = next;</span>
<span class="line" id="L948">        } <span class="tok-kw">else</span> {</span>
<span class="line" id="L949">            <span class="tok-kw">const</span> next = queue.removeMax();</span>
<span class="line" id="L950">            <span class="tok-kw">if</span> (last_max) |last| {</span>
<span class="line" id="L951">                <span class="tok-kw">try</span> expect(last &gt;= next);</span>
<span class="line" id="L952">            }</span>
<span class="line" id="L953">            last_max = next;</span>
<span class="line" id="L954">        }</span>
<span class="line" id="L955">    }</span>
<span class="line" id="L956">}</span>
<span class="line" id="L957"></span>
<span class="line" id="L958"><span class="tok-kw">fn</span> <span class="tok-fn">generateRandomSlice</span>(allocator: std.mem.Allocator, rng: std.rand.Random, size: <span class="tok-type">usize</span>) ![]<span class="tok-type">u32</span> {</span>
<span class="line" id="L959">    <span class="tok-kw">var</span> array = std.ArrayList(<span class="tok-type">u32</span>).init(allocator);</span>
<span class="line" id="L960">    <span class="tok-kw">try</span> array.ensureTotalCapacity(size);</span>
<span class="line" id="L961"></span>
<span class="line" id="L962">    <span class="tok-kw">var</span> i: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L963">    <span class="tok-kw">while</span> (i &lt; size) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L964">        <span class="tok-kw">const</span> elem = rng.int(<span class="tok-type">u32</span>);</span>
<span class="line" id="L965">        <span class="tok-kw">try</span> array.append(elem);</span>
<span class="line" id="L966">    }</span>
<span class="line" id="L967"></span>
<span class="line" id="L968">    <span class="tok-kw">return</span> array.toOwnedSlice();</span>
<span class="line" id="L969">}</span>
<span class="line" id="L970"></span>
<span class="line" id="L971"><span class="tok-kw">fn</span> <span class="tok-fn">contextLessThanComparison</span>(context: []<span class="tok-kw">const</span> <span class="tok-type">u32</span>, a: <span class="tok-type">usize</span>, b: <span class="tok-type">usize</span>) Order {</span>
<span class="line" id="L972">    <span class="tok-kw">return</span> std.math.order(context[a], context[b]);</span>
<span class="line" id="L973">}</span>
<span class="line" id="L974"></span>
<span class="line" id="L975"><span class="tok-kw">const</span> CPDQ = PriorityDequeue(<span class="tok-type">usize</span>, []<span class="tok-kw">const</span> <span class="tok-type">u32</span>, contextLessThanComparison);</span>
<span class="line" id="L976"></span>
<span class="line" id="L977"><span class="tok-kw">test</span> <span class="tok-str">&quot;std.PriorityDequeue: add and remove&quot;</span> {</span>
<span class="line" id="L978">    <span class="tok-kw">const</span> context = [_]<span class="tok-type">u32</span>{ <span class="tok-number">5</span>, <span class="tok-number">3</span>, <span class="tok-number">4</span>, <span class="tok-number">2</span>, <span class="tok-number">2</span>, <span class="tok-number">8</span>, <span class="tok-number">0</span> };</span>
<span class="line" id="L979"></span>
<span class="line" id="L980">    <span class="tok-kw">var</span> queue = CPDQ.init(testing.allocator, context[<span class="tok-number">0</span>..]);</span>
<span class="line" id="L981">    <span class="tok-kw">defer</span> queue.deinit();</span>
<span class="line" id="L982"></span>
<span class="line" id="L983">    <span class="tok-kw">try</span> queue.add(<span class="tok-number">0</span>);</span>
<span class="line" id="L984">    <span class="tok-kw">try</span> queue.add(<span class="tok-number">1</span>);</span>
<span class="line" id="L985">    <span class="tok-kw">try</span> queue.add(<span class="tok-number">2</span>);</span>
<span class="line" id="L986">    <span class="tok-kw">try</span> queue.add(<span class="tok-number">3</span>);</span>
<span class="line" id="L987">    <span class="tok-kw">try</span> queue.add(<span class="tok-number">4</span>);</span>
<span class="line" id="L988">    <span class="tok-kw">try</span> queue.add(<span class="tok-number">5</span>);</span>
<span class="line" id="L989">    <span class="tok-kw">try</span> queue.add(<span class="tok-number">6</span>);</span>
<span class="line" id="L990">    <span class="tok-kw">try</span> expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">usize</span>, <span class="tok-number">6</span>), queue.removeMin());</span>
<span class="line" id="L991">    <span class="tok-kw">try</span> expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">usize</span>, <span class="tok-number">5</span>), queue.removeMax());</span>
<span class="line" id="L992">    <span class="tok-kw">try</span> expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">usize</span>, <span class="tok-number">3</span>), queue.removeMin());</span>
<span class="line" id="L993">    <span class="tok-kw">try</span> expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">usize</span>, <span class="tok-number">0</span>), queue.removeMax());</span>
<span class="line" id="L994">    <span class="tok-kw">try</span> expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">usize</span>, <span class="tok-number">4</span>), queue.removeMin());</span>
<span class="line" id="L995">    <span class="tok-kw">try</span> expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">usize</span>, <span class="tok-number">2</span>), queue.removeMax());</span>
<span class="line" id="L996">    <span class="tok-kw">try</span> expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">usize</span>, <span class="tok-number">1</span>), queue.removeMin());</span>
<span class="line" id="L997">}</span>
<span class="line" id="L998"></span>
</code></pre></body>
</html>