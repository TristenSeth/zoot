<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">    <title>priority_queue.zig - source view</title>
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
<span class="line" id="L10"><span class="tok-comment">/// Priority queue for storing generic data. Initialize with `init`.</span></span>
<span class="line" id="L11"><span class="tok-comment">/// Provide `compareFn` that returns `Order.lt` when its second</span></span>
<span class="line" id="L12"><span class="tok-comment">/// argument should get popped before its third argument,</span></span>
<span class="line" id="L13"><span class="tok-comment">/// `Order.eq` if the arguments are of equal priority, or `Order.gt`</span></span>
<span class="line" id="L14"><span class="tok-comment">/// if the third argument should be popped first.</span></span>
<span class="line" id="L15"><span class="tok-comment">/// For example, to make `pop` return the smallest number, provide</span></span>
<span class="line" id="L16"><span class="tok-comment">/// `fn lessThan(context: void, a: T, b: T) Order { _ = context; return std.math.order(a, b); }`</span></span>
<span class="line" id="L17"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">PriorityQueue</span>(<span class="tok-kw">comptime</span> T: <span class="tok-type">type</span>, <span class="tok-kw">comptime</span> Context: <span class="tok-type">type</span>, <span class="tok-kw">comptime</span> compareFn: <span class="tok-kw">fn</span> (context: Context, a: T, b: T) Order) <span class="tok-type">type</span> {</span>
<span class="line" id="L18">    <span class="tok-kw">return</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L19">        <span class="tok-kw">const</span> Self = <span class="tok-builtin">@This</span>();</span>
<span class="line" id="L20"></span>
<span class="line" id="L21">        items: []T,</span>
<span class="line" id="L22">        len: <span class="tok-type">usize</span>,</span>
<span class="line" id="L23">        allocator: Allocator,</span>
<span class="line" id="L24">        context: Context,</span>
<span class="line" id="L25"></span>
<span class="line" id="L26">        <span class="tok-comment">/// Initialize and return a priority queue.</span></span>
<span class="line" id="L27">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">init</span>(allocator: Allocator, context: Context) Self {</span>
<span class="line" id="L28">            <span class="tok-kw">return</span> Self{</span>
<span class="line" id="L29">                .items = &amp;[_]T{},</span>
<span class="line" id="L30">                .len = <span class="tok-number">0</span>,</span>
<span class="line" id="L31">                .allocator = allocator,</span>
<span class="line" id="L32">                .context = context,</span>
<span class="line" id="L33">            };</span>
<span class="line" id="L34">        }</span>
<span class="line" id="L35"></span>
<span class="line" id="L36">        <span class="tok-comment">/// Free memory used by the queue.</span></span>
<span class="line" id="L37">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">deinit</span>(self: Self) <span class="tok-type">void</span> {</span>
<span class="line" id="L38">            self.allocator.free(self.items);</span>
<span class="line" id="L39">        }</span>
<span class="line" id="L40"></span>
<span class="line" id="L41">        <span class="tok-comment">/// Insert a new element, maintaining priority.</span></span>
<span class="line" id="L42">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">add</span>(self: *Self, elem: T) !<span class="tok-type">void</span> {</span>
<span class="line" id="L43">            <span class="tok-kw">try</span> self.ensureUnusedCapacity(<span class="tok-number">1</span>);</span>
<span class="line" id="L44">            addUnchecked(self, elem);</span>
<span class="line" id="L45">        }</span>
<span class="line" id="L46"></span>
<span class="line" id="L47">        <span class="tok-kw">fn</span> <span class="tok-fn">addUnchecked</span>(self: *Self, elem: T) <span class="tok-type">void</span> {</span>
<span class="line" id="L48">            self.items[self.len] = elem;</span>
<span class="line" id="L49">            siftUp(self, self.len);</span>
<span class="line" id="L50">            self.len += <span class="tok-number">1</span>;</span>
<span class="line" id="L51">        }</span>
<span class="line" id="L52"></span>
<span class="line" id="L53">        <span class="tok-kw">fn</span> <span class="tok-fn">siftUp</span>(self: *Self, start_index: <span class="tok-type">usize</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L54">            <span class="tok-kw">var</span> child_index = start_index;</span>
<span class="line" id="L55">            <span class="tok-kw">while</span> (child_index &gt; <span class="tok-number">0</span>) {</span>
<span class="line" id="L56">                <span class="tok-kw">var</span> parent_index = ((child_index - <span class="tok-number">1</span>) &gt;&gt; <span class="tok-number">1</span>);</span>
<span class="line" id="L57">                <span class="tok-kw">const</span> child = self.items[child_index];</span>
<span class="line" id="L58">                <span class="tok-kw">const</span> parent = self.items[parent_index];</span>
<span class="line" id="L59"></span>
<span class="line" id="L60">                <span class="tok-kw">if</span> (compareFn(self.context, child, parent) != .lt) <span class="tok-kw">break</span>;</span>
<span class="line" id="L61"></span>
<span class="line" id="L62">                self.items[parent_index] = child;</span>
<span class="line" id="L63">                self.items[child_index] = parent;</span>
<span class="line" id="L64">                child_index = parent_index;</span>
<span class="line" id="L65">            }</span>
<span class="line" id="L66">        }</span>
<span class="line" id="L67"></span>
<span class="line" id="L68">        <span class="tok-comment">/// Add each element in `items` to the queue.</span></span>
<span class="line" id="L69">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">addSlice</span>(self: *Self, items: []<span class="tok-kw">const</span> T) !<span class="tok-type">void</span> {</span>
<span class="line" id="L70">            <span class="tok-kw">try</span> self.ensureUnusedCapacity(items.len);</span>
<span class="line" id="L71">            <span class="tok-kw">for</span> (items) |e| {</span>
<span class="line" id="L72">                self.addUnchecked(e);</span>
<span class="line" id="L73">            }</span>
<span class="line" id="L74">        }</span>
<span class="line" id="L75"></span>
<span class="line" id="L76">        <span class="tok-comment">/// Look at the highest priority element in the queue. Returns</span></span>
<span class="line" id="L77">        <span class="tok-comment">/// `null` if empty.</span></span>
<span class="line" id="L78">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">peek</span>(self: *Self) ?T {</span>
<span class="line" id="L79">            <span class="tok-kw">return</span> <span class="tok-kw">if</span> (self.len &gt; <span class="tok-number">0</span>) self.items[<span class="tok-number">0</span>] <span class="tok-kw">else</span> <span class="tok-null">null</span>;</span>
<span class="line" id="L80">        }</span>
<span class="line" id="L81"></span>
<span class="line" id="L82">        <span class="tok-comment">/// Pop the highest priority element from the queue. Returns</span></span>
<span class="line" id="L83">        <span class="tok-comment">/// `null` if empty.</span></span>
<span class="line" id="L84">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">removeOrNull</span>(self: *Self) ?T {</span>
<span class="line" id="L85">            <span class="tok-kw">return</span> <span class="tok-kw">if</span> (self.len &gt; <span class="tok-number">0</span>) self.remove() <span class="tok-kw">else</span> <span class="tok-null">null</span>;</span>
<span class="line" id="L86">        }</span>
<span class="line" id="L87"></span>
<span class="line" id="L88">        <span class="tok-comment">/// Remove and return the highest priority element from the</span></span>
<span class="line" id="L89">        <span class="tok-comment">/// queue.</span></span>
<span class="line" id="L90">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">remove</span>(self: *Self) T {</span>
<span class="line" id="L91">            <span class="tok-kw">return</span> self.removeIndex(<span class="tok-number">0</span>);</span>
<span class="line" id="L92">        }</span>
<span class="line" id="L93"></span>
<span class="line" id="L94">        <span class="tok-comment">/// Remove and return element at index. Indices are in the</span></span>
<span class="line" id="L95">        <span class="tok-comment">/// same order as iterator, which is not necessarily priority</span></span>
<span class="line" id="L96">        <span class="tok-comment">/// order.</span></span>
<span class="line" id="L97">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">removeIndex</span>(self: *Self, index: <span class="tok-type">usize</span>) T {</span>
<span class="line" id="L98">            assert(self.len &gt; index);</span>
<span class="line" id="L99">            <span class="tok-kw">const</span> last = self.items[self.len - <span class="tok-number">1</span>];</span>
<span class="line" id="L100">            <span class="tok-kw">const</span> item = self.items[index];</span>
<span class="line" id="L101">            self.items[index] = last;</span>
<span class="line" id="L102">            self.len -= <span class="tok-number">1</span>;</span>
<span class="line" id="L103"></span>
<span class="line" id="L104">            <span class="tok-kw">if</span> (index == <span class="tok-number">0</span>) {</span>
<span class="line" id="L105">                siftDown(self, index);</span>
<span class="line" id="L106">            } <span class="tok-kw">else</span> {</span>
<span class="line" id="L107">                <span class="tok-kw">const</span> parent_index = ((index - <span class="tok-number">1</span>) &gt;&gt; <span class="tok-number">1</span>);</span>
<span class="line" id="L108">                <span class="tok-kw">const</span> parent = self.items[parent_index];</span>
<span class="line" id="L109">                <span class="tok-kw">if</span> (compareFn(self.context, last, parent) == .gt) {</span>
<span class="line" id="L110">                    siftDown(self, index);</span>
<span class="line" id="L111">                } <span class="tok-kw">else</span> {</span>
<span class="line" id="L112">                    siftUp(self, index);</span>
<span class="line" id="L113">                }</span>
<span class="line" id="L114">            }</span>
<span class="line" id="L115"></span>
<span class="line" id="L116">            <span class="tok-kw">return</span> item;</span>
<span class="line" id="L117">        }</span>
<span class="line" id="L118"></span>
<span class="line" id="L119">        <span class="tok-comment">/// Return the number of elements remaining in the priority</span></span>
<span class="line" id="L120">        <span class="tok-comment">/// queue.</span></span>
<span class="line" id="L121">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">count</span>(self: Self) <span class="tok-type">usize</span> {</span>
<span class="line" id="L122">            <span class="tok-kw">return</span> self.len;</span>
<span class="line" id="L123">        }</span>
<span class="line" id="L124"></span>
<span class="line" id="L125">        <span class="tok-comment">/// Return the number of elements that can be added to the</span></span>
<span class="line" id="L126">        <span class="tok-comment">/// queue before more memory is allocated.</span></span>
<span class="line" id="L127">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">capacity</span>(self: Self) <span class="tok-type">usize</span> {</span>
<span class="line" id="L128">            <span class="tok-kw">return</span> self.items.len;</span>
<span class="line" id="L129">        }</span>
<span class="line" id="L130"></span>
<span class="line" id="L131">        <span class="tok-kw">fn</span> <span class="tok-fn">siftDown</span>(self: *Self, start_index: <span class="tok-type">usize</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L132">            <span class="tok-kw">var</span> index = start_index;</span>
<span class="line" id="L133">            <span class="tok-kw">const</span> half = self.len &gt;&gt; <span class="tok-number">1</span>;</span>
<span class="line" id="L134">            <span class="tok-kw">while</span> (<span class="tok-null">true</span>) {</span>
<span class="line" id="L135">                <span class="tok-kw">var</span> left_index = (index &lt;&lt; <span class="tok-number">1</span>) + <span class="tok-number">1</span>;</span>
<span class="line" id="L136">                <span class="tok-kw">var</span> right_index = left_index + <span class="tok-number">1</span>;</span>
<span class="line" id="L137">                <span class="tok-kw">var</span> left = <span class="tok-kw">if</span> (left_index &lt; self.len) self.items[left_index] <span class="tok-kw">else</span> <span class="tok-null">null</span>;</span>
<span class="line" id="L138">                <span class="tok-kw">var</span> right = <span class="tok-kw">if</span> (right_index &lt; self.len) self.items[right_index] <span class="tok-kw">else</span> <span class="tok-null">null</span>;</span>
<span class="line" id="L139"></span>
<span class="line" id="L140">                <span class="tok-kw">var</span> smallest_index = index;</span>
<span class="line" id="L141">                <span class="tok-kw">var</span> smallest = self.items[index];</span>
<span class="line" id="L142"></span>
<span class="line" id="L143">                <span class="tok-kw">if</span> (left) |e| {</span>
<span class="line" id="L144">                    <span class="tok-kw">if</span> (compareFn(self.context, e, smallest) == .lt) {</span>
<span class="line" id="L145">                        smallest_index = left_index;</span>
<span class="line" id="L146">                        smallest = e;</span>
<span class="line" id="L147">                    }</span>
<span class="line" id="L148">                }</span>
<span class="line" id="L149"></span>
<span class="line" id="L150">                <span class="tok-kw">if</span> (right) |e| {</span>
<span class="line" id="L151">                    <span class="tok-kw">if</span> (compareFn(self.context, e, smallest) == .lt) {</span>
<span class="line" id="L152">                        smallest_index = right_index;</span>
<span class="line" id="L153">                        smallest = e;</span>
<span class="line" id="L154">                    }</span>
<span class="line" id="L155">                }</span>
<span class="line" id="L156"></span>
<span class="line" id="L157">                <span class="tok-kw">if</span> (smallest_index == index) <span class="tok-kw">return</span>;</span>
<span class="line" id="L158"></span>
<span class="line" id="L159">                self.items[smallest_index] = self.items[index];</span>
<span class="line" id="L160">                self.items[index] = smallest;</span>
<span class="line" id="L161">                index = smallest_index;</span>
<span class="line" id="L162"></span>
<span class="line" id="L163">                <span class="tok-kw">if</span> (index &gt;= half) <span class="tok-kw">return</span>;</span>
<span class="line" id="L164">            }</span>
<span class="line" id="L165">        }</span>
<span class="line" id="L166"></span>
<span class="line" id="L167">        <span class="tok-comment">/// PriorityQueue takes ownership of the passed in slice. The slice must have been</span></span>
<span class="line" id="L168">        <span class="tok-comment">/// allocated with `allocator`.</span></span>
<span class="line" id="L169">        <span class="tok-comment">/// Deinitialize with `deinit`.</span></span>
<span class="line" id="L170">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">fromOwnedSlice</span>(allocator: Allocator, items: []T, context: Context) Self {</span>
<span class="line" id="L171">            <span class="tok-kw">var</span> queue = Self{</span>
<span class="line" id="L172">                .items = items,</span>
<span class="line" id="L173">                .len = items.len,</span>
<span class="line" id="L174">                .allocator = allocator,</span>
<span class="line" id="L175">                .context = context,</span>
<span class="line" id="L176">            };</span>
<span class="line" id="L177"></span>
<span class="line" id="L178">            <span class="tok-kw">if</span> (queue.len &lt;= <span class="tok-number">1</span>) <span class="tok-kw">return</span> queue;</span>
<span class="line" id="L179"></span>
<span class="line" id="L180">            <span class="tok-kw">const</span> half = (queue.len &gt;&gt; <span class="tok-number">1</span>) - <span class="tok-number">1</span>;</span>
<span class="line" id="L181">            <span class="tok-kw">var</span> i: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L182">            <span class="tok-kw">while</span> (i &lt;= half) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L183">                queue.siftDown(half - i);</span>
<span class="line" id="L184">            }</span>
<span class="line" id="L185">            <span class="tok-kw">return</span> queue;</span>
<span class="line" id="L186">        }</span>
<span class="line" id="L187"></span>
<span class="line" id="L188">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> ensureCapacity = <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;deprecated; use ensureUnusedCapacity or ensureTotalCapacity&quot;</span>);</span>
<span class="line" id="L189"></span>
<span class="line" id="L190">        <span class="tok-comment">/// Ensure that the queue can fit at least `new_capacity` items.</span></span>
<span class="line" id="L191">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">ensureTotalCapacity</span>(self: *Self, new_capacity: <span class="tok-type">usize</span>) !<span class="tok-type">void</span> {</span>
<span class="line" id="L192">            <span class="tok-kw">var</span> better_capacity = self.capacity();</span>
<span class="line" id="L193">            <span class="tok-kw">if</span> (better_capacity &gt;= new_capacity) <span class="tok-kw">return</span>;</span>
<span class="line" id="L194">            <span class="tok-kw">while</span> (<span class="tok-null">true</span>) {</span>
<span class="line" id="L195">                better_capacity += better_capacity / <span class="tok-number">2</span> + <span class="tok-number">8</span>;</span>
<span class="line" id="L196">                <span class="tok-kw">if</span> (better_capacity &gt;= new_capacity) <span class="tok-kw">break</span>;</span>
<span class="line" id="L197">            }</span>
<span class="line" id="L198">            self.items = <span class="tok-kw">try</span> self.allocator.realloc(self.items, better_capacity);</span>
<span class="line" id="L199">        }</span>
<span class="line" id="L200"></span>
<span class="line" id="L201">        <span class="tok-comment">/// Ensure that the queue can fit at least `additional_count` **more** item.</span></span>
<span class="line" id="L202">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">ensureUnusedCapacity</span>(self: *Self, additional_count: <span class="tok-type">usize</span>) !<span class="tok-type">void</span> {</span>
<span class="line" id="L203">            <span class="tok-kw">return</span> self.ensureTotalCapacity(self.len + additional_count);</span>
<span class="line" id="L204">        }</span>
<span class="line" id="L205"></span>
<span class="line" id="L206">        <span class="tok-comment">/// Reduce allocated capacity to `new_len`.</span></span>
<span class="line" id="L207">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">shrinkAndFree</span>(self: *Self, new_len: <span class="tok-type">usize</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L208">            assert(new_len &lt;= self.items.len);</span>
<span class="line" id="L209"></span>
<span class="line" id="L210">            <span class="tok-comment">// Cannot shrink to smaller than the current queue size without invalidating the heap property</span>
</span>
<span class="line" id="L211">            assert(new_len &gt;= self.len);</span>
<span class="line" id="L212"></span>
<span class="line" id="L213">            self.items = self.allocator.realloc(self.items[<span class="tok-number">0</span>..], new_len) <span class="tok-kw">catch</span> |e| <span class="tok-kw">switch</span> (e) {</span>
<span class="line" id="L214">                <span class="tok-kw">error</span>.OutOfMemory =&gt; { <span class="tok-comment">// no problem, capacity is still correct then.</span>
</span>
<span class="line" id="L215">                    self.items.len = new_len;</span>
<span class="line" id="L216">                    <span class="tok-kw">return</span>;</span>
<span class="line" id="L217">                },</span>
<span class="line" id="L218">            };</span>
<span class="line" id="L219">        }</span>
<span class="line" id="L220"></span>
<span class="line" id="L221">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">update</span>(self: *Self, elem: T, new_elem: T) !<span class="tok-type">void</span> {</span>
<span class="line" id="L222">            <span class="tok-kw">const</span> update_index = blk: {</span>
<span class="line" id="L223">                <span class="tok-kw">for</span> (self.items) |item, idx| {</span>
<span class="line" id="L224">                    <span class="tok-kw">if</span> (compareFn(self.context, item, elem).compare(.eq)) <span class="tok-kw">break</span> :blk idx;</span>
<span class="line" id="L225">                }</span>
<span class="line" id="L226">                <span class="tok-kw">return</span> <span class="tok-kw">error</span>.ElementNotFound;</span>
<span class="line" id="L227">            };</span>
<span class="line" id="L228">            <span class="tok-kw">const</span> old_elem: T = self.items[update_index];</span>
<span class="line" id="L229">            self.items[update_index] = new_elem;</span>
<span class="line" id="L230">            <span class="tok-kw">switch</span> (compareFn(self.context, new_elem, old_elem)) {</span>
<span class="line" id="L231">                .lt =&gt; siftUp(self, update_index),</span>
<span class="line" id="L232">                .gt =&gt; siftDown(self, update_index),</span>
<span class="line" id="L233">                .eq =&gt; {}, <span class="tok-comment">// Nothing to do as the items have equal priority</span>
</span>
<span class="line" id="L234">            }</span>
<span class="line" id="L235">        }</span>
<span class="line" id="L236"></span>
<span class="line" id="L237">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> Iterator = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L238">            queue: *PriorityQueue(T, Context, compareFn),</span>
<span class="line" id="L239">            count: <span class="tok-type">usize</span>,</span>
<span class="line" id="L240"></span>
<span class="line" id="L241">            <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">next</span>(it: *Iterator) ?T {</span>
<span class="line" id="L242">                <span class="tok-kw">if</span> (it.count &gt;= it.queue.len) <span class="tok-kw">return</span> <span class="tok-null">null</span>;</span>
<span class="line" id="L243">                <span class="tok-kw">const</span> out = it.count;</span>
<span class="line" id="L244">                it.count += <span class="tok-number">1</span>;</span>
<span class="line" id="L245">                <span class="tok-kw">return</span> it.queue.items[out];</span>
<span class="line" id="L246">            }</span>
<span class="line" id="L247"></span>
<span class="line" id="L248">            <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">reset</span>(it: *Iterator) <span class="tok-type">void</span> {</span>
<span class="line" id="L249">                it.count = <span class="tok-number">0</span>;</span>
<span class="line" id="L250">            }</span>
<span class="line" id="L251">        };</span>
<span class="line" id="L252"></span>
<span class="line" id="L253">        <span class="tok-comment">/// Return an iterator that walks the queue without consuming</span></span>
<span class="line" id="L254">        <span class="tok-comment">/// it. Invalidated if the heap is modified.</span></span>
<span class="line" id="L255">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">iterator</span>(self: *Self) Iterator {</span>
<span class="line" id="L256">            <span class="tok-kw">return</span> Iterator{</span>
<span class="line" id="L257">                .queue = self,</span>
<span class="line" id="L258">                .count = <span class="tok-number">0</span>,</span>
<span class="line" id="L259">            };</span>
<span class="line" id="L260">        }</span>
<span class="line" id="L261"></span>
<span class="line" id="L262">        <span class="tok-kw">fn</span> <span class="tok-fn">dump</span>(self: *Self) <span class="tok-type">void</span> {</span>
<span class="line" id="L263">            <span class="tok-kw">const</span> print = std.debug.print;</span>
<span class="line" id="L264">            print(<span class="tok-str">&quot;{{ &quot;</span>, .{});</span>
<span class="line" id="L265">            print(<span class="tok-str">&quot;items: &quot;</span>, .{});</span>
<span class="line" id="L266">            <span class="tok-kw">for</span> (self.items) |e, i| {</span>
<span class="line" id="L267">                <span class="tok-kw">if</span> (i &gt;= self.len) <span class="tok-kw">break</span>;</span>
<span class="line" id="L268">                print(<span class="tok-str">&quot;{}, &quot;</span>, .{e});</span>
<span class="line" id="L269">            }</span>
<span class="line" id="L270">            print(<span class="tok-str">&quot;array: &quot;</span>, .{});</span>
<span class="line" id="L271">            <span class="tok-kw">for</span> (self.items) |e| {</span>
<span class="line" id="L272">                print(<span class="tok-str">&quot;{}, &quot;</span>, .{e});</span>
<span class="line" id="L273">            }</span>
<span class="line" id="L274">            print(<span class="tok-str">&quot;len: {} &quot;</span>, .{self.len});</span>
<span class="line" id="L275">            print(<span class="tok-str">&quot;capacity: {}&quot;</span>, .{self.capacity()});</span>
<span class="line" id="L276">            print(<span class="tok-str">&quot; }}\n&quot;</span>, .{});</span>
<span class="line" id="L277">        }</span>
<span class="line" id="L278">    };</span>
<span class="line" id="L279">}</span>
<span class="line" id="L280"></span>
<span class="line" id="L281"><span class="tok-kw">fn</span> <span class="tok-fn">lessThan</span>(context: <span class="tok-type">void</span>, a: <span class="tok-type">u32</span>, b: <span class="tok-type">u32</span>) Order {</span>
<span class="line" id="L282">    _ = context;</span>
<span class="line" id="L283">    <span class="tok-kw">return</span> std.math.order(a, b);</span>
<span class="line" id="L284">}</span>
<span class="line" id="L285"></span>
<span class="line" id="L286"><span class="tok-kw">fn</span> <span class="tok-fn">greaterThan</span>(context: <span class="tok-type">void</span>, a: <span class="tok-type">u32</span>, b: <span class="tok-type">u32</span>) Order {</span>
<span class="line" id="L287">    <span class="tok-kw">return</span> lessThan(context, a, b).invert();</span>
<span class="line" id="L288">}</span>
<span class="line" id="L289"></span>
<span class="line" id="L290"><span class="tok-kw">const</span> PQlt = PriorityQueue(<span class="tok-type">u32</span>, <span class="tok-type">void</span>, lessThan);</span>
<span class="line" id="L291"><span class="tok-kw">const</span> PQgt = PriorityQueue(<span class="tok-type">u32</span>, <span class="tok-type">void</span>, greaterThan);</span>
<span class="line" id="L292"></span>
<span class="line" id="L293"><span class="tok-kw">test</span> <span class="tok-str">&quot;std.PriorityQueue: add and remove min heap&quot;</span> {</span>
<span class="line" id="L294">    <span class="tok-kw">var</span> queue = PQlt.init(testing.allocator, {});</span>
<span class="line" id="L295">    <span class="tok-kw">defer</span> queue.deinit();</span>
<span class="line" id="L296"></span>
<span class="line" id="L297">    <span class="tok-kw">try</span> queue.add(<span class="tok-number">54</span>);</span>
<span class="line" id="L298">    <span class="tok-kw">try</span> queue.add(<span class="tok-number">12</span>);</span>
<span class="line" id="L299">    <span class="tok-kw">try</span> queue.add(<span class="tok-number">7</span>);</span>
<span class="line" id="L300">    <span class="tok-kw">try</span> queue.add(<span class="tok-number">23</span>);</span>
<span class="line" id="L301">    <span class="tok-kw">try</span> queue.add(<span class="tok-number">25</span>);</span>
<span class="line" id="L302">    <span class="tok-kw">try</span> queue.add(<span class="tok-number">13</span>);</span>
<span class="line" id="L303">    <span class="tok-kw">try</span> expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">7</span>), queue.remove());</span>
<span class="line" id="L304">    <span class="tok-kw">try</span> expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">12</span>), queue.remove());</span>
<span class="line" id="L305">    <span class="tok-kw">try</span> expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">13</span>), queue.remove());</span>
<span class="line" id="L306">    <span class="tok-kw">try</span> expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">23</span>), queue.remove());</span>
<span class="line" id="L307">    <span class="tok-kw">try</span> expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">25</span>), queue.remove());</span>
<span class="line" id="L308">    <span class="tok-kw">try</span> expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">54</span>), queue.remove());</span>
<span class="line" id="L309">}</span>
<span class="line" id="L310"></span>
<span class="line" id="L311"><span class="tok-kw">test</span> <span class="tok-str">&quot;std.PriorityQueue: add and remove same min heap&quot;</span> {</span>
<span class="line" id="L312">    <span class="tok-kw">var</span> queue = PQlt.init(testing.allocator, {});</span>
<span class="line" id="L313">    <span class="tok-kw">defer</span> queue.deinit();</span>
<span class="line" id="L314"></span>
<span class="line" id="L315">    <span class="tok-kw">try</span> queue.add(<span class="tok-number">1</span>);</span>
<span class="line" id="L316">    <span class="tok-kw">try</span> queue.add(<span class="tok-number">1</span>);</span>
<span class="line" id="L317">    <span class="tok-kw">try</span> queue.add(<span class="tok-number">2</span>);</span>
<span class="line" id="L318">    <span class="tok-kw">try</span> queue.add(<span class="tok-number">2</span>);</span>
<span class="line" id="L319">    <span class="tok-kw">try</span> queue.add(<span class="tok-number">1</span>);</span>
<span class="line" id="L320">    <span class="tok-kw">try</span> queue.add(<span class="tok-number">1</span>);</span>
<span class="line" id="L321">    <span class="tok-kw">try</span> expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">1</span>), queue.remove());</span>
<span class="line" id="L322">    <span class="tok-kw">try</span> expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">1</span>), queue.remove());</span>
<span class="line" id="L323">    <span class="tok-kw">try</span> expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">1</span>), queue.remove());</span>
<span class="line" id="L324">    <span class="tok-kw">try</span> expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">1</span>), queue.remove());</span>
<span class="line" id="L325">    <span class="tok-kw">try</span> expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">2</span>), queue.remove());</span>
<span class="line" id="L326">    <span class="tok-kw">try</span> expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">2</span>), queue.remove());</span>
<span class="line" id="L327">}</span>
<span class="line" id="L328"></span>
<span class="line" id="L329"><span class="tok-kw">test</span> <span class="tok-str">&quot;std.PriorityQueue: removeOrNull on empty&quot;</span> {</span>
<span class="line" id="L330">    <span class="tok-kw">var</span> queue = PQlt.init(testing.allocator, {});</span>
<span class="line" id="L331">    <span class="tok-kw">defer</span> queue.deinit();</span>
<span class="line" id="L332"></span>
<span class="line" id="L333">    <span class="tok-kw">try</span> expect(queue.removeOrNull() == <span class="tok-null">null</span>);</span>
<span class="line" id="L334">}</span>
<span class="line" id="L335"></span>
<span class="line" id="L336"><span class="tok-kw">test</span> <span class="tok-str">&quot;std.PriorityQueue: edge case 3 elements&quot;</span> {</span>
<span class="line" id="L337">    <span class="tok-kw">var</span> queue = PQlt.init(testing.allocator, {});</span>
<span class="line" id="L338">    <span class="tok-kw">defer</span> queue.deinit();</span>
<span class="line" id="L339"></span>
<span class="line" id="L340">    <span class="tok-kw">try</span> queue.add(<span class="tok-number">9</span>);</span>
<span class="line" id="L341">    <span class="tok-kw">try</span> queue.add(<span class="tok-number">3</span>);</span>
<span class="line" id="L342">    <span class="tok-kw">try</span> queue.add(<span class="tok-number">2</span>);</span>
<span class="line" id="L343">    <span class="tok-kw">try</span> expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">2</span>), queue.remove());</span>
<span class="line" id="L344">    <span class="tok-kw">try</span> expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">3</span>), queue.remove());</span>
<span class="line" id="L345">    <span class="tok-kw">try</span> expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">9</span>), queue.remove());</span>
<span class="line" id="L346">}</span>
<span class="line" id="L347"></span>
<span class="line" id="L348"><span class="tok-kw">test</span> <span class="tok-str">&quot;std.PriorityQueue: peek&quot;</span> {</span>
<span class="line" id="L349">    <span class="tok-kw">var</span> queue = PQlt.init(testing.allocator, {});</span>
<span class="line" id="L350">    <span class="tok-kw">defer</span> queue.deinit();</span>
<span class="line" id="L351"></span>
<span class="line" id="L352">    <span class="tok-kw">try</span> expect(queue.peek() == <span class="tok-null">null</span>);</span>
<span class="line" id="L353">    <span class="tok-kw">try</span> queue.add(<span class="tok-number">9</span>);</span>
<span class="line" id="L354">    <span class="tok-kw">try</span> queue.add(<span class="tok-number">3</span>);</span>
<span class="line" id="L355">    <span class="tok-kw">try</span> queue.add(<span class="tok-number">2</span>);</span>
<span class="line" id="L356">    <span class="tok-kw">try</span> expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">2</span>), queue.peek().?);</span>
<span class="line" id="L357">    <span class="tok-kw">try</span> expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">2</span>), queue.peek().?);</span>
<span class="line" id="L358">}</span>
<span class="line" id="L359"></span>
<span class="line" id="L360"><span class="tok-kw">test</span> <span class="tok-str">&quot;std.PriorityQueue: sift up with odd indices&quot;</span> {</span>
<span class="line" id="L361">    <span class="tok-kw">var</span> queue = PQlt.init(testing.allocator, {});</span>
<span class="line" id="L362">    <span class="tok-kw">defer</span> queue.deinit();</span>
<span class="line" id="L363">    <span class="tok-kw">const</span> items = [_]<span class="tok-type">u32</span>{ <span class="tok-number">15</span>, <span class="tok-number">7</span>, <span class="tok-number">21</span>, <span class="tok-number">14</span>, <span class="tok-number">13</span>, <span class="tok-number">22</span>, <span class="tok-number">12</span>, <span class="tok-number">6</span>, <span class="tok-number">7</span>, <span class="tok-number">25</span>, <span class="tok-number">5</span>, <span class="tok-number">24</span>, <span class="tok-number">11</span>, <span class="tok-number">16</span>, <span class="tok-number">15</span>, <span class="tok-number">24</span>, <span class="tok-number">2</span>, <span class="tok-number">1</span> };</span>
<span class="line" id="L364">    <span class="tok-kw">for</span> (items) |e| {</span>
<span class="line" id="L365">        <span class="tok-kw">try</span> queue.add(e);</span>
<span class="line" id="L366">    }</span>
<span class="line" id="L367"></span>
<span class="line" id="L368">    <span class="tok-kw">const</span> sorted_items = [_]<span class="tok-type">u32</span>{ <span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">5</span>, <span class="tok-number">6</span>, <span class="tok-number">7</span>, <span class="tok-number">7</span>, <span class="tok-number">11</span>, <span class="tok-number">12</span>, <span class="tok-number">13</span>, <span class="tok-number">14</span>, <span class="tok-number">15</span>, <span class="tok-number">15</span>, <span class="tok-number">16</span>, <span class="tok-number">21</span>, <span class="tok-number">22</span>, <span class="tok-number">24</span>, <span class="tok-number">24</span>, <span class="tok-number">25</span> };</span>
<span class="line" id="L369">    <span class="tok-kw">for</span> (sorted_items) |e| {</span>
<span class="line" id="L370">        <span class="tok-kw">try</span> expectEqual(e, queue.remove());</span>
<span class="line" id="L371">    }</span>
<span class="line" id="L372">}</span>
<span class="line" id="L373"></span>
<span class="line" id="L374"><span class="tok-kw">test</span> <span class="tok-str">&quot;std.PriorityQueue: addSlice&quot;</span> {</span>
<span class="line" id="L375">    <span class="tok-kw">var</span> queue = PQlt.init(testing.allocator, {});</span>
<span class="line" id="L376">    <span class="tok-kw">defer</span> queue.deinit();</span>
<span class="line" id="L377">    <span class="tok-kw">const</span> items = [_]<span class="tok-type">u32</span>{ <span class="tok-number">15</span>, <span class="tok-number">7</span>, <span class="tok-number">21</span>, <span class="tok-number">14</span>, <span class="tok-number">13</span>, <span class="tok-number">22</span>, <span class="tok-number">12</span>, <span class="tok-number">6</span>, <span class="tok-number">7</span>, <span class="tok-number">25</span>, <span class="tok-number">5</span>, <span class="tok-number">24</span>, <span class="tok-number">11</span>, <span class="tok-number">16</span>, <span class="tok-number">15</span>, <span class="tok-number">24</span>, <span class="tok-number">2</span>, <span class="tok-number">1</span> };</span>
<span class="line" id="L378">    <span class="tok-kw">try</span> queue.addSlice(items[<span class="tok-number">0</span>..]);</span>
<span class="line" id="L379"></span>
<span class="line" id="L380">    <span class="tok-kw">const</span> sorted_items = [_]<span class="tok-type">u32</span>{ <span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">5</span>, <span class="tok-number">6</span>, <span class="tok-number">7</span>, <span class="tok-number">7</span>, <span class="tok-number">11</span>, <span class="tok-number">12</span>, <span class="tok-number">13</span>, <span class="tok-number">14</span>, <span class="tok-number">15</span>, <span class="tok-number">15</span>, <span class="tok-number">16</span>, <span class="tok-number">21</span>, <span class="tok-number">22</span>, <span class="tok-number">24</span>, <span class="tok-number">24</span>, <span class="tok-number">25</span> };</span>
<span class="line" id="L381">    <span class="tok-kw">for</span> (sorted_items) |e| {</span>
<span class="line" id="L382">        <span class="tok-kw">try</span> expectEqual(e, queue.remove());</span>
<span class="line" id="L383">    }</span>
<span class="line" id="L384">}</span>
<span class="line" id="L385"></span>
<span class="line" id="L386"><span class="tok-kw">test</span> <span class="tok-str">&quot;std.PriorityQueue: fromOwnedSlice trivial case 0&quot;</span> {</span>
<span class="line" id="L387">    <span class="tok-kw">const</span> items = [<span class="tok-number">0</span>]<span class="tok-type">u32</span>{};</span>
<span class="line" id="L388">    <span class="tok-kw">const</span> queue_items = <span class="tok-kw">try</span> testing.allocator.dupe(<span class="tok-type">u32</span>, &amp;items);</span>
<span class="line" id="L389">    <span class="tok-kw">var</span> queue = PQlt.fromOwnedSlice(testing.allocator, queue_items[<span class="tok-number">0</span>..], {});</span>
<span class="line" id="L390">    <span class="tok-kw">defer</span> queue.deinit();</span>
<span class="line" id="L391">    <span class="tok-kw">try</span> expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">usize</span>, <span class="tok-number">0</span>), queue.len);</span>
<span class="line" id="L392">    <span class="tok-kw">try</span> expect(queue.removeOrNull() == <span class="tok-null">null</span>);</span>
<span class="line" id="L393">}</span>
<span class="line" id="L394"></span>
<span class="line" id="L395"><span class="tok-kw">test</span> <span class="tok-str">&quot;std.PriorityQueue: fromOwnedSlice trivial case 1&quot;</span> {</span>
<span class="line" id="L396">    <span class="tok-kw">const</span> items = [<span class="tok-number">1</span>]<span class="tok-type">u32</span>{<span class="tok-number">1</span>};</span>
<span class="line" id="L397">    <span class="tok-kw">const</span> queue_items = <span class="tok-kw">try</span> testing.allocator.dupe(<span class="tok-type">u32</span>, &amp;items);</span>
<span class="line" id="L398">    <span class="tok-kw">var</span> queue = PQlt.fromOwnedSlice(testing.allocator, queue_items[<span class="tok-number">0</span>..], {});</span>
<span class="line" id="L399">    <span class="tok-kw">defer</span> queue.deinit();</span>
<span class="line" id="L400"></span>
<span class="line" id="L401">    <span class="tok-kw">try</span> expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">usize</span>, <span class="tok-number">1</span>), queue.len);</span>
<span class="line" id="L402">    <span class="tok-kw">try</span> expectEqual(items[<span class="tok-number">0</span>], queue.remove());</span>
<span class="line" id="L403">    <span class="tok-kw">try</span> expect(queue.removeOrNull() == <span class="tok-null">null</span>);</span>
<span class="line" id="L404">}</span>
<span class="line" id="L405"></span>
<span class="line" id="L406"><span class="tok-kw">test</span> <span class="tok-str">&quot;std.PriorityQueue: fromOwnedSlice&quot;</span> {</span>
<span class="line" id="L407">    <span class="tok-kw">const</span> items = [_]<span class="tok-type">u32</span>{ <span class="tok-number">15</span>, <span class="tok-number">7</span>, <span class="tok-number">21</span>, <span class="tok-number">14</span>, <span class="tok-number">13</span>, <span class="tok-number">22</span>, <span class="tok-number">12</span>, <span class="tok-number">6</span>, <span class="tok-number">7</span>, <span class="tok-number">25</span>, <span class="tok-number">5</span>, <span class="tok-number">24</span>, <span class="tok-number">11</span>, <span class="tok-number">16</span>, <span class="tok-number">15</span>, <span class="tok-number">24</span>, <span class="tok-number">2</span>, <span class="tok-number">1</span> };</span>
<span class="line" id="L408">    <span class="tok-kw">const</span> heap_items = <span class="tok-kw">try</span> testing.allocator.dupe(<span class="tok-type">u32</span>, items[<span class="tok-number">0</span>..]);</span>
<span class="line" id="L409">    <span class="tok-kw">var</span> queue = PQlt.fromOwnedSlice(testing.allocator, heap_items[<span class="tok-number">0</span>..], {});</span>
<span class="line" id="L410">    <span class="tok-kw">defer</span> queue.deinit();</span>
<span class="line" id="L411"></span>
<span class="line" id="L412">    <span class="tok-kw">const</span> sorted_items = [_]<span class="tok-type">u32</span>{ <span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">5</span>, <span class="tok-number">6</span>, <span class="tok-number">7</span>, <span class="tok-number">7</span>, <span class="tok-number">11</span>, <span class="tok-number">12</span>, <span class="tok-number">13</span>, <span class="tok-number">14</span>, <span class="tok-number">15</span>, <span class="tok-number">15</span>, <span class="tok-number">16</span>, <span class="tok-number">21</span>, <span class="tok-number">22</span>, <span class="tok-number">24</span>, <span class="tok-number">24</span>, <span class="tok-number">25</span> };</span>
<span class="line" id="L413">    <span class="tok-kw">for</span> (sorted_items) |e| {</span>
<span class="line" id="L414">        <span class="tok-kw">try</span> expectEqual(e, queue.remove());</span>
<span class="line" id="L415">    }</span>
<span class="line" id="L416">}</span>
<span class="line" id="L417"></span>
<span class="line" id="L418"><span class="tok-kw">test</span> <span class="tok-str">&quot;std.PriorityQueue: add and remove max heap&quot;</span> {</span>
<span class="line" id="L419">    <span class="tok-kw">var</span> queue = PQgt.init(testing.allocator, {});</span>
<span class="line" id="L420">    <span class="tok-kw">defer</span> queue.deinit();</span>
<span class="line" id="L421"></span>
<span class="line" id="L422">    <span class="tok-kw">try</span> queue.add(<span class="tok-number">54</span>);</span>
<span class="line" id="L423">    <span class="tok-kw">try</span> queue.add(<span class="tok-number">12</span>);</span>
<span class="line" id="L424">    <span class="tok-kw">try</span> queue.add(<span class="tok-number">7</span>);</span>
<span class="line" id="L425">    <span class="tok-kw">try</span> queue.add(<span class="tok-number">23</span>);</span>
<span class="line" id="L426">    <span class="tok-kw">try</span> queue.add(<span class="tok-number">25</span>);</span>
<span class="line" id="L427">    <span class="tok-kw">try</span> queue.add(<span class="tok-number">13</span>);</span>
<span class="line" id="L428">    <span class="tok-kw">try</span> expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">54</span>), queue.remove());</span>
<span class="line" id="L429">    <span class="tok-kw">try</span> expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">25</span>), queue.remove());</span>
<span class="line" id="L430">    <span class="tok-kw">try</span> expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">23</span>), queue.remove());</span>
<span class="line" id="L431">    <span class="tok-kw">try</span> expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">13</span>), queue.remove());</span>
<span class="line" id="L432">    <span class="tok-kw">try</span> expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">12</span>), queue.remove());</span>
<span class="line" id="L433">    <span class="tok-kw">try</span> expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">7</span>), queue.remove());</span>
<span class="line" id="L434">}</span>
<span class="line" id="L435"></span>
<span class="line" id="L436"><span class="tok-kw">test</span> <span class="tok-str">&quot;std.PriorityQueue: add and remove same max heap&quot;</span> {</span>
<span class="line" id="L437">    <span class="tok-kw">var</span> queue = PQgt.init(testing.allocator, {});</span>
<span class="line" id="L438">    <span class="tok-kw">defer</span> queue.deinit();</span>
<span class="line" id="L439"></span>
<span class="line" id="L440">    <span class="tok-kw">try</span> queue.add(<span class="tok-number">1</span>);</span>
<span class="line" id="L441">    <span class="tok-kw">try</span> queue.add(<span class="tok-number">1</span>);</span>
<span class="line" id="L442">    <span class="tok-kw">try</span> queue.add(<span class="tok-number">2</span>);</span>
<span class="line" id="L443">    <span class="tok-kw">try</span> queue.add(<span class="tok-number">2</span>);</span>
<span class="line" id="L444">    <span class="tok-kw">try</span> queue.add(<span class="tok-number">1</span>);</span>
<span class="line" id="L445">    <span class="tok-kw">try</span> queue.add(<span class="tok-number">1</span>);</span>
<span class="line" id="L446">    <span class="tok-kw">try</span> expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">2</span>), queue.remove());</span>
<span class="line" id="L447">    <span class="tok-kw">try</span> expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">2</span>), queue.remove());</span>
<span class="line" id="L448">    <span class="tok-kw">try</span> expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">1</span>), queue.remove());</span>
<span class="line" id="L449">    <span class="tok-kw">try</span> expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">1</span>), queue.remove());</span>
<span class="line" id="L450">    <span class="tok-kw">try</span> expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">1</span>), queue.remove());</span>
<span class="line" id="L451">    <span class="tok-kw">try</span> expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">1</span>), queue.remove());</span>
<span class="line" id="L452">}</span>
<span class="line" id="L453"></span>
<span class="line" id="L454"><span class="tok-kw">test</span> <span class="tok-str">&quot;std.PriorityQueue: iterator&quot;</span> {</span>
<span class="line" id="L455">    <span class="tok-kw">var</span> queue = PQlt.init(testing.allocator, {});</span>
<span class="line" id="L456">    <span class="tok-kw">var</span> map = std.AutoHashMap(<span class="tok-type">u32</span>, <span class="tok-type">void</span>).init(testing.allocator);</span>
<span class="line" id="L457">    <span class="tok-kw">defer</span> {</span>
<span class="line" id="L458">        queue.deinit();</span>
<span class="line" id="L459">        map.deinit();</span>
<span class="line" id="L460">    }</span>
<span class="line" id="L461"></span>
<span class="line" id="L462">    <span class="tok-kw">const</span> items = [_]<span class="tok-type">u32</span>{ <span class="tok-number">54</span>, <span class="tok-number">12</span>, <span class="tok-number">7</span>, <span class="tok-number">23</span>, <span class="tok-number">25</span>, <span class="tok-number">13</span> };</span>
<span class="line" id="L463">    <span class="tok-kw">for</span> (items) |e| {</span>
<span class="line" id="L464">        _ = <span class="tok-kw">try</span> queue.add(e);</span>
<span class="line" id="L465">        <span class="tok-kw">try</span> map.put(e, {});</span>
<span class="line" id="L466">    }</span>
<span class="line" id="L467"></span>
<span class="line" id="L468">    <span class="tok-kw">var</span> it = queue.iterator();</span>
<span class="line" id="L469">    <span class="tok-kw">while</span> (it.next()) |e| {</span>
<span class="line" id="L470">        _ = map.remove(e);</span>
<span class="line" id="L471">    }</span>
<span class="line" id="L472"></span>
<span class="line" id="L473">    <span class="tok-kw">try</span> expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">usize</span>, <span class="tok-number">0</span>), map.count());</span>
<span class="line" id="L474">}</span>
<span class="line" id="L475"></span>
<span class="line" id="L476"><span class="tok-kw">test</span> <span class="tok-str">&quot;std.PriorityQueue: remove at index&quot;</span> {</span>
<span class="line" id="L477">    <span class="tok-kw">var</span> queue = PQlt.init(testing.allocator, {});</span>
<span class="line" id="L478">    <span class="tok-kw">defer</span> queue.deinit();</span>
<span class="line" id="L479"></span>
<span class="line" id="L480">    <span class="tok-kw">const</span> items = [_]<span class="tok-type">u32</span>{ <span class="tok-number">2</span>, <span class="tok-number">1</span>, <span class="tok-number">8</span>, <span class="tok-number">9</span>, <span class="tok-number">3</span>, <span class="tok-number">4</span>, <span class="tok-number">5</span> };</span>
<span class="line" id="L481">    <span class="tok-kw">for</span> (items) |e| {</span>
<span class="line" id="L482">        _ = <span class="tok-kw">try</span> queue.add(e);</span>
<span class="line" id="L483">    }</span>
<span class="line" id="L484"></span>
<span class="line" id="L485">    <span class="tok-kw">var</span> it = queue.iterator();</span>
<span class="line" id="L486">    <span class="tok-kw">var</span> idx: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L487">    <span class="tok-kw">const</span> two_idx = <span class="tok-kw">while</span> (it.next()) |elem| {</span>
<span class="line" id="L488">        <span class="tok-kw">if</span> (elem == <span class="tok-number">2</span>)</span>
<span class="line" id="L489">            <span class="tok-kw">break</span> idx;</span>
<span class="line" id="L490">        idx += <span class="tok-number">1</span>;</span>
<span class="line" id="L491">    } <span class="tok-kw">else</span> <span class="tok-kw">unreachable</span>;</span>
<span class="line" id="L492">    <span class="tok-kw">var</span> sorted_items = [_]<span class="tok-type">u32</span>{ <span class="tok-number">1</span>, <span class="tok-number">3</span>, <span class="tok-number">4</span>, <span class="tok-number">5</span>, <span class="tok-number">8</span>, <span class="tok-number">9</span> };</span>
<span class="line" id="L493">    <span class="tok-kw">try</span> expectEqual(queue.removeIndex(two_idx), <span class="tok-number">2</span>);</span>
<span class="line" id="L494"></span>
<span class="line" id="L495">    <span class="tok-kw">var</span> i: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L496">    <span class="tok-kw">while</span> (queue.removeOrNull()) |n| : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L497">        <span class="tok-kw">try</span> expectEqual(n, sorted_items[i]);</span>
<span class="line" id="L498">    }</span>
<span class="line" id="L499">    <span class="tok-kw">try</span> expectEqual(queue.removeOrNull(), <span class="tok-null">null</span>);</span>
<span class="line" id="L500">}</span>
<span class="line" id="L501"></span>
<span class="line" id="L502"><span class="tok-kw">test</span> <span class="tok-str">&quot;std.PriorityQueue: iterator while empty&quot;</span> {</span>
<span class="line" id="L503">    <span class="tok-kw">var</span> queue = PQlt.init(testing.allocator, {});</span>
<span class="line" id="L504">    <span class="tok-kw">defer</span> queue.deinit();</span>
<span class="line" id="L505"></span>
<span class="line" id="L506">    <span class="tok-kw">var</span> it = queue.iterator();</span>
<span class="line" id="L507"></span>
<span class="line" id="L508">    <span class="tok-kw">try</span> expectEqual(it.next(), <span class="tok-null">null</span>);</span>
<span class="line" id="L509">}</span>
<span class="line" id="L510"></span>
<span class="line" id="L511"><span class="tok-kw">test</span> <span class="tok-str">&quot;std.PriorityQueue: shrinkAndFree&quot;</span> {</span>
<span class="line" id="L512">    <span class="tok-kw">var</span> queue = PQlt.init(testing.allocator, {});</span>
<span class="line" id="L513">    <span class="tok-kw">defer</span> queue.deinit();</span>
<span class="line" id="L514"></span>
<span class="line" id="L515">    <span class="tok-kw">try</span> queue.ensureTotalCapacity(<span class="tok-number">4</span>);</span>
<span class="line" id="L516">    <span class="tok-kw">try</span> expect(queue.capacity() &gt;= <span class="tok-number">4</span>);</span>
<span class="line" id="L517"></span>
<span class="line" id="L518">    <span class="tok-kw">try</span> queue.add(<span class="tok-number">1</span>);</span>
<span class="line" id="L519">    <span class="tok-kw">try</span> queue.add(<span class="tok-number">2</span>);</span>
<span class="line" id="L520">    <span class="tok-kw">try</span> queue.add(<span class="tok-number">3</span>);</span>
<span class="line" id="L521">    <span class="tok-kw">try</span> expect(queue.capacity() &gt;= <span class="tok-number">4</span>);</span>
<span class="line" id="L522">    <span class="tok-kw">try</span> expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">usize</span>, <span class="tok-number">3</span>), queue.len);</span>
<span class="line" id="L523"></span>
<span class="line" id="L524">    queue.shrinkAndFree(<span class="tok-number">3</span>);</span>
<span class="line" id="L525">    <span class="tok-kw">try</span> expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">usize</span>, <span class="tok-number">3</span>), queue.capacity());</span>
<span class="line" id="L526">    <span class="tok-kw">try</span> expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">usize</span>, <span class="tok-number">3</span>), queue.len);</span>
<span class="line" id="L527"></span>
<span class="line" id="L528">    <span class="tok-kw">try</span> expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">1</span>), queue.remove());</span>
<span class="line" id="L529">    <span class="tok-kw">try</span> expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">2</span>), queue.remove());</span>
<span class="line" id="L530">    <span class="tok-kw">try</span> expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">3</span>), queue.remove());</span>
<span class="line" id="L531">    <span class="tok-kw">try</span> expect(queue.removeOrNull() == <span class="tok-null">null</span>);</span>
<span class="line" id="L532">}</span>
<span class="line" id="L533"></span>
<span class="line" id="L534"><span class="tok-kw">test</span> <span class="tok-str">&quot;std.PriorityQueue: update min heap&quot;</span> {</span>
<span class="line" id="L535">    <span class="tok-kw">var</span> queue = PQlt.init(testing.allocator, {});</span>
<span class="line" id="L536">    <span class="tok-kw">defer</span> queue.deinit();</span>
<span class="line" id="L537"></span>
<span class="line" id="L538">    <span class="tok-kw">try</span> queue.add(<span class="tok-number">55</span>);</span>
<span class="line" id="L539">    <span class="tok-kw">try</span> queue.add(<span class="tok-number">44</span>);</span>
<span class="line" id="L540">    <span class="tok-kw">try</span> queue.add(<span class="tok-number">11</span>);</span>
<span class="line" id="L541">    <span class="tok-kw">try</span> queue.update(<span class="tok-number">55</span>, <span class="tok-number">5</span>);</span>
<span class="line" id="L542">    <span class="tok-kw">try</span> queue.update(<span class="tok-number">44</span>, <span class="tok-number">4</span>);</span>
<span class="line" id="L543">    <span class="tok-kw">try</span> queue.update(<span class="tok-number">11</span>, <span class="tok-number">1</span>);</span>
<span class="line" id="L544">    <span class="tok-kw">try</span> expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">1</span>), queue.remove());</span>
<span class="line" id="L545">    <span class="tok-kw">try</span> expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">4</span>), queue.remove());</span>
<span class="line" id="L546">    <span class="tok-kw">try</span> expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">5</span>), queue.remove());</span>
<span class="line" id="L547">}</span>
<span class="line" id="L548"></span>
<span class="line" id="L549"><span class="tok-kw">test</span> <span class="tok-str">&quot;std.PriorityQueue: update same min heap&quot;</span> {</span>
<span class="line" id="L550">    <span class="tok-kw">var</span> queue = PQlt.init(testing.allocator, {});</span>
<span class="line" id="L551">    <span class="tok-kw">defer</span> queue.deinit();</span>
<span class="line" id="L552"></span>
<span class="line" id="L553">    <span class="tok-kw">try</span> queue.add(<span class="tok-number">1</span>);</span>
<span class="line" id="L554">    <span class="tok-kw">try</span> queue.add(<span class="tok-number">1</span>);</span>
<span class="line" id="L555">    <span class="tok-kw">try</span> queue.add(<span class="tok-number">2</span>);</span>
<span class="line" id="L556">    <span class="tok-kw">try</span> queue.add(<span class="tok-number">2</span>);</span>
<span class="line" id="L557">    <span class="tok-kw">try</span> queue.update(<span class="tok-number">1</span>, <span class="tok-number">5</span>);</span>
<span class="line" id="L558">    <span class="tok-kw">try</span> queue.update(<span class="tok-number">2</span>, <span class="tok-number">4</span>);</span>
<span class="line" id="L559">    <span class="tok-kw">try</span> expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">1</span>), queue.remove());</span>
<span class="line" id="L560">    <span class="tok-kw">try</span> expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">2</span>), queue.remove());</span>
<span class="line" id="L561">    <span class="tok-kw">try</span> expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">4</span>), queue.remove());</span>
<span class="line" id="L562">    <span class="tok-kw">try</span> expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">5</span>), queue.remove());</span>
<span class="line" id="L563">}</span>
<span class="line" id="L564"></span>
<span class="line" id="L565"><span class="tok-kw">test</span> <span class="tok-str">&quot;std.PriorityQueue: update max heap&quot;</span> {</span>
<span class="line" id="L566">    <span class="tok-kw">var</span> queue = PQgt.init(testing.allocator, {});</span>
<span class="line" id="L567">    <span class="tok-kw">defer</span> queue.deinit();</span>
<span class="line" id="L568"></span>
<span class="line" id="L569">    <span class="tok-kw">try</span> queue.add(<span class="tok-number">55</span>);</span>
<span class="line" id="L570">    <span class="tok-kw">try</span> queue.add(<span class="tok-number">44</span>);</span>
<span class="line" id="L571">    <span class="tok-kw">try</span> queue.add(<span class="tok-number">11</span>);</span>
<span class="line" id="L572">    <span class="tok-kw">try</span> queue.update(<span class="tok-number">55</span>, <span class="tok-number">5</span>);</span>
<span class="line" id="L573">    <span class="tok-kw">try</span> queue.update(<span class="tok-number">44</span>, <span class="tok-number">1</span>);</span>
<span class="line" id="L574">    <span class="tok-kw">try</span> queue.update(<span class="tok-number">11</span>, <span class="tok-number">4</span>);</span>
<span class="line" id="L575">    <span class="tok-kw">try</span> expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">5</span>), queue.remove());</span>
<span class="line" id="L576">    <span class="tok-kw">try</span> expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">4</span>), queue.remove());</span>
<span class="line" id="L577">    <span class="tok-kw">try</span> expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">1</span>), queue.remove());</span>
<span class="line" id="L578">}</span>
<span class="line" id="L579"></span>
<span class="line" id="L580"><span class="tok-kw">test</span> <span class="tok-str">&quot;std.PriorityQueue: update same max heap&quot;</span> {</span>
<span class="line" id="L581">    <span class="tok-kw">var</span> queue = PQgt.init(testing.allocator, {});</span>
<span class="line" id="L582">    <span class="tok-kw">defer</span> queue.deinit();</span>
<span class="line" id="L583"></span>
<span class="line" id="L584">    <span class="tok-kw">try</span> queue.add(<span class="tok-number">1</span>);</span>
<span class="line" id="L585">    <span class="tok-kw">try</span> queue.add(<span class="tok-number">1</span>);</span>
<span class="line" id="L586">    <span class="tok-kw">try</span> queue.add(<span class="tok-number">2</span>);</span>
<span class="line" id="L587">    <span class="tok-kw">try</span> queue.add(<span class="tok-number">2</span>);</span>
<span class="line" id="L588">    <span class="tok-kw">try</span> queue.update(<span class="tok-number">1</span>, <span class="tok-number">5</span>);</span>
<span class="line" id="L589">    <span class="tok-kw">try</span> queue.update(<span class="tok-number">2</span>, <span class="tok-number">4</span>);</span>
<span class="line" id="L590">    <span class="tok-kw">try</span> expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">5</span>), queue.remove());</span>
<span class="line" id="L591">    <span class="tok-kw">try</span> expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">4</span>), queue.remove());</span>
<span class="line" id="L592">    <span class="tok-kw">try</span> expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">2</span>), queue.remove());</span>
<span class="line" id="L593">    <span class="tok-kw">try</span> expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">1</span>), queue.remove());</span>
<span class="line" id="L594">}</span>
<span class="line" id="L595"></span>
<span class="line" id="L596"><span class="tok-kw">test</span> <span class="tok-str">&quot;std.PriorityQueue: siftUp in remove&quot;</span> {</span>
<span class="line" id="L597">    <span class="tok-kw">var</span> queue = PQlt.init(testing.allocator, {});</span>
<span class="line" id="L598">    <span class="tok-kw">defer</span> queue.deinit();</span>
<span class="line" id="L599"></span>
<span class="line" id="L600">    <span class="tok-kw">try</span> queue.addSlice(&amp;.{ <span class="tok-number">0</span>, <span class="tok-number">1</span>, <span class="tok-number">100</span>, <span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">101</span>, <span class="tok-number">102</span>, <span class="tok-number">4</span>, <span class="tok-number">5</span>, <span class="tok-number">6</span>, <span class="tok-number">7</span>, <span class="tok-number">103</span>, <span class="tok-number">104</span>, <span class="tok-number">105</span>, <span class="tok-number">106</span>, <span class="tok-number">8</span> });</span>
<span class="line" id="L601"></span>
<span class="line" id="L602">    _ = queue.removeIndex(std.mem.indexOfScalar(<span class="tok-type">u32</span>, queue.items[<span class="tok-number">0</span>..queue.len], <span class="tok-number">102</span>).?);</span>
<span class="line" id="L603"></span>
<span class="line" id="L604">    <span class="tok-kw">const</span> sorted_items = [_]<span class="tok-type">u32</span>{ <span class="tok-number">0</span>, <span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">4</span>, <span class="tok-number">5</span>, <span class="tok-number">6</span>, <span class="tok-number">7</span>, <span class="tok-number">8</span>, <span class="tok-number">100</span>, <span class="tok-number">101</span>, <span class="tok-number">103</span>, <span class="tok-number">104</span>, <span class="tok-number">105</span>, <span class="tok-number">106</span> };</span>
<span class="line" id="L605">    <span class="tok-kw">for</span> (sorted_items) |e| {</span>
<span class="line" id="L606">        <span class="tok-kw">try</span> expectEqual(e, queue.remove());</span>
<span class="line" id="L607">    }</span>
<span class="line" id="L608">}</span>
<span class="line" id="L609"></span>
<span class="line" id="L610"><span class="tok-kw">fn</span> <span class="tok-fn">contextLessThan</span>(context: []<span class="tok-kw">const</span> <span class="tok-type">u32</span>, a: <span class="tok-type">usize</span>, b: <span class="tok-type">usize</span>) Order {</span>
<span class="line" id="L611">    <span class="tok-kw">return</span> std.math.order(context[a], context[b]);</span>
<span class="line" id="L612">}</span>
<span class="line" id="L613"></span>
<span class="line" id="L614"><span class="tok-kw">const</span> CPQlt = PriorityQueue(<span class="tok-type">usize</span>, []<span class="tok-kw">const</span> <span class="tok-type">u32</span>, contextLessThan);</span>
<span class="line" id="L615"></span>
<span class="line" id="L616"><span class="tok-kw">test</span> <span class="tok-str">&quot;std.PriorityQueue: add and remove min heap with contextful comparator&quot;</span> {</span>
<span class="line" id="L617">    <span class="tok-kw">const</span> context = [_]<span class="tok-type">u32</span>{ <span class="tok-number">5</span>, <span class="tok-number">3</span>, <span class="tok-number">4</span>, <span class="tok-number">2</span>, <span class="tok-number">2</span>, <span class="tok-number">8</span>, <span class="tok-number">0</span> };</span>
<span class="line" id="L618"></span>
<span class="line" id="L619">    <span class="tok-kw">var</span> queue = CPQlt.init(testing.allocator, context[<span class="tok-number">0</span>..]);</span>
<span class="line" id="L620">    <span class="tok-kw">defer</span> queue.deinit();</span>
<span class="line" id="L621"></span>
<span class="line" id="L622">    <span class="tok-kw">try</span> queue.add(<span class="tok-number">0</span>);</span>
<span class="line" id="L623">    <span class="tok-kw">try</span> queue.add(<span class="tok-number">1</span>);</span>
<span class="line" id="L624">    <span class="tok-kw">try</span> queue.add(<span class="tok-number">2</span>);</span>
<span class="line" id="L625">    <span class="tok-kw">try</span> queue.add(<span class="tok-number">3</span>);</span>
<span class="line" id="L626">    <span class="tok-kw">try</span> queue.add(<span class="tok-number">4</span>);</span>
<span class="line" id="L627">    <span class="tok-kw">try</span> queue.add(<span class="tok-number">5</span>);</span>
<span class="line" id="L628">    <span class="tok-kw">try</span> queue.add(<span class="tok-number">6</span>);</span>
<span class="line" id="L629">    <span class="tok-kw">try</span> expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">usize</span>, <span class="tok-number">6</span>), queue.remove());</span>
<span class="line" id="L630">    <span class="tok-kw">try</span> expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">usize</span>, <span class="tok-number">4</span>), queue.remove());</span>
<span class="line" id="L631">    <span class="tok-kw">try</span> expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">usize</span>, <span class="tok-number">3</span>), queue.remove());</span>
<span class="line" id="L632">    <span class="tok-kw">try</span> expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">usize</span>, <span class="tok-number">1</span>), queue.remove());</span>
<span class="line" id="L633">    <span class="tok-kw">try</span> expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">usize</span>, <span class="tok-number">2</span>), queue.remove());</span>
<span class="line" id="L634">    <span class="tok-kw">try</span> expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">usize</span>, <span class="tok-number">0</span>), queue.remove());</span>
<span class="line" id="L635">    <span class="tok-kw">try</span> expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">usize</span>, <span class="tok-number">5</span>), queue.remove());</span>
<span class="line" id="L636">}</span>
<span class="line" id="L637"></span>
</code></pre></body>
</html>