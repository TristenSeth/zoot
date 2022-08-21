<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">    <title>segmented_list.zig - source view</title>
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
<span class="line" id="L2"><span class="tok-kw">const</span> assert = std.debug.assert;</span>
<span class="line" id="L3"><span class="tok-kw">const</span> testing = std.testing;</span>
<span class="line" id="L4"><span class="tok-kw">const</span> Allocator = std.mem.Allocator;</span>
<span class="line" id="L5"></span>
<span class="line" id="L6"><span class="tok-comment">// Imagine that `fn at(self: *Self, index: usize) &amp;T` is a customer asking for a box</span>
</span>
<span class="line" id="L7"><span class="tok-comment">// from a warehouse, based on a flat array, boxes ordered from 0 to N - 1.</span>
</span>
<span class="line" id="L8"><span class="tok-comment">// But the warehouse actually stores boxes in shelves of increasing powers of 2 sizes.</span>
</span>
<span class="line" id="L9"><span class="tok-comment">// So when the customer requests a box index, we have to translate it to shelf index</span>
</span>
<span class="line" id="L10"><span class="tok-comment">// and box index within that shelf. Illustration:</span>
</span>
<span class="line" id="L11"><span class="tok-comment">//</span>
</span>
<span class="line" id="L12"><span class="tok-comment">// customer indexes:</span>
</span>
<span class="line" id="L13"><span class="tok-comment">// shelf 0:  0</span>
</span>
<span class="line" id="L14"><span class="tok-comment">// shelf 1:  1  2</span>
</span>
<span class="line" id="L15"><span class="tok-comment">// shelf 2:  3  4  5  6</span>
</span>
<span class="line" id="L16"><span class="tok-comment">// shelf 3:  7  8  9 10 11 12 13 14</span>
</span>
<span class="line" id="L17"><span class="tok-comment">// shelf 4: 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30</span>
</span>
<span class="line" id="L18"><span class="tok-comment">// shelf 5: 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59 60 61 62</span>
</span>
<span class="line" id="L19"><span class="tok-comment">// ...</span>
</span>
<span class="line" id="L20"><span class="tok-comment">//</span>
</span>
<span class="line" id="L21"><span class="tok-comment">// warehouse indexes:</span>
</span>
<span class="line" id="L22"><span class="tok-comment">// shelf 0:  0</span>
</span>
<span class="line" id="L23"><span class="tok-comment">// shelf 1:  0  1</span>
</span>
<span class="line" id="L24"><span class="tok-comment">// shelf 2:  0  1  2  3</span>
</span>
<span class="line" id="L25"><span class="tok-comment">// shelf 3:  0  1  2  3  4  5  6  7</span>
</span>
<span class="line" id="L26"><span class="tok-comment">// shelf 4:  0  1  2  3  4  5  6  7  8  9 10 11 12 13 14 15</span>
</span>
<span class="line" id="L27"><span class="tok-comment">// shelf 5:  0  1  2  3  4  5  6  7  8  9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31</span>
</span>
<span class="line" id="L28"><span class="tok-comment">// ...</span>
</span>
<span class="line" id="L29"><span class="tok-comment">//</span>
</span>
<span class="line" id="L30"><span class="tok-comment">// With this arrangement, here are the equations to get the shelf index and</span>
</span>
<span class="line" id="L31"><span class="tok-comment">// box index based on customer box index:</span>
</span>
<span class="line" id="L32"><span class="tok-comment">//</span>
</span>
<span class="line" id="L33"><span class="tok-comment">// shelf_index = floor(log2(customer_index + 1))</span>
</span>
<span class="line" id="L34"><span class="tok-comment">// shelf_count = ceil(log2(box_count + 1))</span>
</span>
<span class="line" id="L35"><span class="tok-comment">// box_index = customer_index + 1 - 2 ** shelf</span>
</span>
<span class="line" id="L36"><span class="tok-comment">// shelf_size = 2 ** shelf_index</span>
</span>
<span class="line" id="L37"><span class="tok-comment">//</span>
</span>
<span class="line" id="L38"><span class="tok-comment">// Now we complicate it a little bit further by adding a preallocated shelf, which must be</span>
</span>
<span class="line" id="L39"><span class="tok-comment">// a power of 2:</span>
</span>
<span class="line" id="L40"><span class="tok-comment">// prealloc=4</span>
</span>
<span class="line" id="L41"><span class="tok-comment">//</span>
</span>
<span class="line" id="L42"><span class="tok-comment">// customer indexes:</span>
</span>
<span class="line" id="L43"><span class="tok-comment">// prealloc:  0  1  2  3</span>
</span>
<span class="line" id="L44"><span class="tok-comment">//  shelf 0:  4  5  6  7  8  9 10 11</span>
</span>
<span class="line" id="L45"><span class="tok-comment">//  shelf 1: 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27</span>
</span>
<span class="line" id="L46"><span class="tok-comment">//  shelf 2: 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59</span>
</span>
<span class="line" id="L47"><span class="tok-comment">// ...</span>
</span>
<span class="line" id="L48"><span class="tok-comment">//</span>
</span>
<span class="line" id="L49"><span class="tok-comment">// warehouse indexes:</span>
</span>
<span class="line" id="L50"><span class="tok-comment">// prealloc:  0  1  2  3</span>
</span>
<span class="line" id="L51"><span class="tok-comment">//  shelf 0:  0  1  2  3  4  5  6  7</span>
</span>
<span class="line" id="L52"><span class="tok-comment">//  shelf 1:  0  1  2  3  4  5  6  7  8  9 10 11 12 13 14 15</span>
</span>
<span class="line" id="L53"><span class="tok-comment">//  shelf 2:  0  1  2  3  4  5  6  7  8  9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31</span>
</span>
<span class="line" id="L54"><span class="tok-comment">// ...</span>
</span>
<span class="line" id="L55"><span class="tok-comment">//</span>
</span>
<span class="line" id="L56"><span class="tok-comment">// Now the equations are:</span>
</span>
<span class="line" id="L57"><span class="tok-comment">//</span>
</span>
<span class="line" id="L58"><span class="tok-comment">// shelf_index = floor(log2(customer_index + prealloc)) - log2(prealloc) - 1</span>
</span>
<span class="line" id="L59"><span class="tok-comment">// shelf_count = ceil(log2(box_count + prealloc)) - log2(prealloc) - 1</span>
</span>
<span class="line" id="L60"><span class="tok-comment">// box_index = customer_index + prealloc - 2 ** (log2(prealloc) + 1 + shelf)</span>
</span>
<span class="line" id="L61"><span class="tok-comment">// shelf_size = prealloc * 2 ** (shelf_index + 1)</span>
</span>
<span class="line" id="L62"></span>
<span class="line" id="L63"><span class="tok-comment">/// This is a stack data structure where pointers to indexes have the same lifetime as the data structure</span></span>
<span class="line" id="L64"><span class="tok-comment">/// itself, unlike ArrayList where append() invalidates all existing element pointers.</span></span>
<span class="line" id="L65"><span class="tok-comment">/// The tradeoff is that elements are not guaranteed to be contiguous. For that, use ArrayList.</span></span>
<span class="line" id="L66"><span class="tok-comment">/// Note however that most elements are contiguous, making this data structure cache-friendly.</span></span>
<span class="line" id="L67"><span class="tok-comment">///</span></span>
<span class="line" id="L68"><span class="tok-comment">/// Because it never has to copy elements from an old location to a new location, it does not require</span></span>
<span class="line" id="L69"><span class="tok-comment">/// its elements to be copyable, and it avoids wasting memory when backed by an ArenaAllocator.</span></span>
<span class="line" id="L70"><span class="tok-comment">/// Note that the append() and pop() convenience methods perform a copy, but you can instead use</span></span>
<span class="line" id="L71"><span class="tok-comment">/// addOne(), at(), setCapacity(), and shrinkCapacity() to avoid copying items.</span></span>
<span class="line" id="L72"><span class="tok-comment">///</span></span>
<span class="line" id="L73"><span class="tok-comment">/// This data structure has O(1) append and O(1) pop.</span></span>
<span class="line" id="L74"><span class="tok-comment">///</span></span>
<span class="line" id="L75"><span class="tok-comment">/// It supports preallocated elements, making it especially well suited when the expected maximum</span></span>
<span class="line" id="L76"><span class="tok-comment">/// size is small. `prealloc_item_count` must be 0, or a power of 2.</span></span>
<span class="line" id="L77"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">SegmentedList</span>(<span class="tok-kw">comptime</span> T: <span class="tok-type">type</span>, <span class="tok-kw">comptime</span> prealloc_item_count: <span class="tok-type">usize</span>) <span class="tok-type">type</span> {</span>
<span class="line" id="L78">    <span class="tok-kw">return</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L79">        <span class="tok-kw">const</span> Self = <span class="tok-builtin">@This</span>();</span>
<span class="line" id="L80">        <span class="tok-kw">const</span> ShelfIndex = std.math.Log2Int(<span class="tok-type">usize</span>);</span>
<span class="line" id="L81"></span>
<span class="line" id="L82">        <span class="tok-kw">const</span> prealloc_exp: ShelfIndex = blk: {</span>
<span class="line" id="L83">            <span class="tok-comment">// we don't use the prealloc_exp constant when prealloc_item_count is 0</span>
</span>
<span class="line" id="L84">            <span class="tok-comment">// but lazy-init may still be triggered by other code so supply a value</span>
</span>
<span class="line" id="L85">            <span class="tok-kw">if</span> (prealloc_item_count == <span class="tok-number">0</span>) {</span>
<span class="line" id="L86">                <span class="tok-kw">break</span> :blk <span class="tok-number">0</span>;</span>
<span class="line" id="L87">            } <span class="tok-kw">else</span> {</span>
<span class="line" id="L88">                assert(std.math.isPowerOfTwo(prealloc_item_count));</span>
<span class="line" id="L89">                <span class="tok-kw">const</span> value = std.math.log2_int(<span class="tok-type">usize</span>, prealloc_item_count);</span>
<span class="line" id="L90">                <span class="tok-kw">break</span> :blk value;</span>
<span class="line" id="L91">            }</span>
<span class="line" id="L92">        };</span>
<span class="line" id="L93"></span>
<span class="line" id="L94">        prealloc_segment: [prealloc_item_count]T = <span class="tok-null">undefined</span>,</span>
<span class="line" id="L95">        dynamic_segments: [][*]T = &amp;[_][*]T{},</span>
<span class="line" id="L96">        len: <span class="tok-type">usize</span> = <span class="tok-number">0</span>,</span>
<span class="line" id="L97"></span>
<span class="line" id="L98">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> prealloc_count = prealloc_item_count;</span>
<span class="line" id="L99"></span>
<span class="line" id="L100">        <span class="tok-kw">fn</span> <span class="tok-fn">AtType</span>(<span class="tok-kw">comptime</span> SelfType: <span class="tok-type">type</span>) <span class="tok-type">type</span> {</span>
<span class="line" id="L101">            <span class="tok-kw">if</span> (<span class="tok-builtin">@typeInfo</span>(SelfType).Pointer.is_const) {</span>
<span class="line" id="L102">                <span class="tok-kw">return</span> *<span class="tok-kw">const</span> T;</span>
<span class="line" id="L103">            } <span class="tok-kw">else</span> {</span>
<span class="line" id="L104">                <span class="tok-kw">return</span> *T;</span>
<span class="line" id="L105">            }</span>
<span class="line" id="L106">        }</span>
<span class="line" id="L107"></span>
<span class="line" id="L108">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">deinit</span>(self: *Self, allocator: Allocator) <span class="tok-type">void</span> {</span>
<span class="line" id="L109">            self.freeShelves(allocator, <span class="tok-builtin">@intCast</span>(ShelfIndex, self.dynamic_segments.len), <span class="tok-number">0</span>);</span>
<span class="line" id="L110">            allocator.free(self.dynamic_segments);</span>
<span class="line" id="L111">            self.* = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L112">        }</span>
<span class="line" id="L113"></span>
<span class="line" id="L114">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">at</span>(self: <span class="tok-kw">anytype</span>, i: <span class="tok-type">usize</span>) AtType(<span class="tok-builtin">@TypeOf</span>(self)) {</span>
<span class="line" id="L115">            assert(i &lt; self.len);</span>
<span class="line" id="L116">            <span class="tok-kw">return</span> self.uncheckedAt(i);</span>
<span class="line" id="L117">        }</span>
<span class="line" id="L118"></span>
<span class="line" id="L119">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">count</span>(self: Self) <span class="tok-type">usize</span> {</span>
<span class="line" id="L120">            <span class="tok-kw">return</span> self.len;</span>
<span class="line" id="L121">        }</span>
<span class="line" id="L122"></span>
<span class="line" id="L123">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">append</span>(self: *Self, allocator: Allocator, item: T) Allocator.Error!<span class="tok-type">void</span> {</span>
<span class="line" id="L124">            <span class="tok-kw">const</span> new_item_ptr = <span class="tok-kw">try</span> self.addOne(allocator);</span>
<span class="line" id="L125">            new_item_ptr.* = item;</span>
<span class="line" id="L126">        }</span>
<span class="line" id="L127"></span>
<span class="line" id="L128">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">appendSlice</span>(self: *Self, allocator: Allocator, items: []<span class="tok-kw">const</span> T) Allocator.Error!<span class="tok-type">void</span> {</span>
<span class="line" id="L129">            <span class="tok-kw">for</span> (items) |item| {</span>
<span class="line" id="L130">                <span class="tok-kw">try</span> self.append(allocator, item);</span>
<span class="line" id="L131">            }</span>
<span class="line" id="L132">        }</span>
<span class="line" id="L133"></span>
<span class="line" id="L134">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">pop</span>(self: *Self) ?T {</span>
<span class="line" id="L135">            <span class="tok-kw">if</span> (self.len == <span class="tok-number">0</span>) <span class="tok-kw">return</span> <span class="tok-null">null</span>;</span>
<span class="line" id="L136"></span>
<span class="line" id="L137">            <span class="tok-kw">const</span> index = self.len - <span class="tok-number">1</span>;</span>
<span class="line" id="L138">            <span class="tok-kw">const</span> result = uncheckedAt(self, index).*;</span>
<span class="line" id="L139">            self.len = index;</span>
<span class="line" id="L140">            <span class="tok-kw">return</span> result;</span>
<span class="line" id="L141">        }</span>
<span class="line" id="L142"></span>
<span class="line" id="L143">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">addOne</span>(self: *Self, allocator: Allocator) Allocator.Error!*T {</span>
<span class="line" id="L144">            <span class="tok-kw">const</span> new_length = self.len + <span class="tok-number">1</span>;</span>
<span class="line" id="L145">            <span class="tok-kw">try</span> self.growCapacity(allocator, new_length);</span>
<span class="line" id="L146">            <span class="tok-kw">const</span> result = uncheckedAt(self, self.len);</span>
<span class="line" id="L147">            self.len = new_length;</span>
<span class="line" id="L148">            <span class="tok-kw">return</span> result;</span>
<span class="line" id="L149">        }</span>
<span class="line" id="L150"></span>
<span class="line" id="L151">        <span class="tok-comment">/// Reduce length to `new_len`.</span></span>
<span class="line" id="L152">        <span class="tok-comment">/// Invalidates pointers for the elements at index new_len and beyond.</span></span>
<span class="line" id="L153">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">shrinkRetainingCapacity</span>(self: *Self, new_len: <span class="tok-type">usize</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L154">            assert(new_len &lt;= self.len);</span>
<span class="line" id="L155">            self.len = new_len;</span>
<span class="line" id="L156">        }</span>
<span class="line" id="L157"></span>
<span class="line" id="L158">        <span class="tok-comment">/// Invalidates all element pointers.</span></span>
<span class="line" id="L159">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">clearRetainingCapacity</span>(self: *Self) <span class="tok-type">void</span> {</span>
<span class="line" id="L160">            self.items.len = <span class="tok-number">0</span>;</span>
<span class="line" id="L161">        }</span>
<span class="line" id="L162"></span>
<span class="line" id="L163">        <span class="tok-comment">/// Invalidates all element pointers.</span></span>
<span class="line" id="L164">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">clearAndFree</span>(self: *Self, allocator: Allocator) <span class="tok-type">void</span> {</span>
<span class="line" id="L165">            self.setCapacity(allocator, <span class="tok-number">0</span>) <span class="tok-kw">catch</span> <span class="tok-kw">unreachable</span>;</span>
<span class="line" id="L166">            self.items.len = <span class="tok-number">0</span>;</span>
<span class="line" id="L167">        }</span>
<span class="line" id="L168"></span>
<span class="line" id="L169">        <span class="tok-comment">/// Grows or shrinks capacity to match usage.</span></span>
<span class="line" id="L170">        <span class="tok-comment">/// TODO update this and related methods to match the conventions set by ArrayList</span></span>
<span class="line" id="L171">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">setCapacity</span>(self: *Self, allocator: Allocator, new_capacity: <span class="tok-type">usize</span>) Allocator.Error!<span class="tok-type">void</span> {</span>
<span class="line" id="L172">            <span class="tok-kw">if</span> (prealloc_item_count != <span class="tok-number">0</span>) {</span>
<span class="line" id="L173">                <span class="tok-kw">if</span> (new_capacity &lt;= <span class="tok-builtin">@as</span>(<span class="tok-type">usize</span>, <span class="tok-number">1</span>) &lt;&lt; (prealloc_exp + <span class="tok-builtin">@intCast</span>(ShelfIndex, self.dynamic_segments.len))) {</span>
<span class="line" id="L174">                    <span class="tok-kw">return</span> self.shrinkCapacity(allocator, new_capacity);</span>
<span class="line" id="L175">                }</span>
<span class="line" id="L176">            }</span>
<span class="line" id="L177">            <span class="tok-kw">return</span> self.growCapacity(allocator, new_capacity);</span>
<span class="line" id="L178">        }</span>
<span class="line" id="L179"></span>
<span class="line" id="L180">        <span class="tok-comment">/// Only grows capacity, or retains current capacity</span></span>
<span class="line" id="L181">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">growCapacity</span>(self: *Self, allocator: Allocator, new_capacity: <span class="tok-type">usize</span>) Allocator.Error!<span class="tok-type">void</span> {</span>
<span class="line" id="L182">            <span class="tok-kw">const</span> new_cap_shelf_count = shelfCount(new_capacity);</span>
<span class="line" id="L183">            <span class="tok-kw">const</span> old_shelf_count = <span class="tok-builtin">@intCast</span>(ShelfIndex, self.dynamic_segments.len);</span>
<span class="line" id="L184">            <span class="tok-kw">if</span> (new_cap_shelf_count &gt; old_shelf_count) {</span>
<span class="line" id="L185">                self.dynamic_segments = <span class="tok-kw">try</span> allocator.realloc(self.dynamic_segments, new_cap_shelf_count);</span>
<span class="line" id="L186">                <span class="tok-kw">var</span> i = old_shelf_count;</span>
<span class="line" id="L187">                <span class="tok-kw">errdefer</span> {</span>
<span class="line" id="L188">                    self.freeShelves(allocator, i, old_shelf_count);</span>
<span class="line" id="L189">                    self.dynamic_segments = allocator.shrink(self.dynamic_segments, old_shelf_count);</span>
<span class="line" id="L190">                }</span>
<span class="line" id="L191">                <span class="tok-kw">while</span> (i &lt; new_cap_shelf_count) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L192">                    self.dynamic_segments[i] = (<span class="tok-kw">try</span> allocator.alloc(T, shelfSize(i))).ptr;</span>
<span class="line" id="L193">                }</span>
<span class="line" id="L194">            }</span>
<span class="line" id="L195">        }</span>
<span class="line" id="L196"></span>
<span class="line" id="L197">        <span class="tok-comment">/// Only shrinks capacity or retains current capacity</span></span>
<span class="line" id="L198">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">shrinkCapacity</span>(self: *Self, allocator: Allocator, new_capacity: <span class="tok-type">usize</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L199">            <span class="tok-kw">if</span> (new_capacity &lt;= prealloc_item_count) {</span>
<span class="line" id="L200">                <span class="tok-kw">const</span> len = <span class="tok-builtin">@intCast</span>(ShelfIndex, self.dynamic_segments.len);</span>
<span class="line" id="L201">                self.freeShelves(allocator, len, <span class="tok-number">0</span>);</span>
<span class="line" id="L202">                allocator.free(self.dynamic_segments);</span>
<span class="line" id="L203">                self.dynamic_segments = &amp;[_][*]T{};</span>
<span class="line" id="L204">                <span class="tok-kw">return</span>;</span>
<span class="line" id="L205">            }</span>
<span class="line" id="L206"></span>
<span class="line" id="L207">            <span class="tok-kw">const</span> new_cap_shelf_count = shelfCount(new_capacity);</span>
<span class="line" id="L208">            <span class="tok-kw">const</span> old_shelf_count = <span class="tok-builtin">@intCast</span>(ShelfIndex, self.dynamic_segments.len);</span>
<span class="line" id="L209">            assert(new_cap_shelf_count &lt;= old_shelf_count);</span>
<span class="line" id="L210">            <span class="tok-kw">if</span> (new_cap_shelf_count == old_shelf_count) {</span>
<span class="line" id="L211">                <span class="tok-kw">return</span>;</span>
<span class="line" id="L212">            }</span>
<span class="line" id="L213"></span>
<span class="line" id="L214">            self.freeShelves(allocator, old_shelf_count, new_cap_shelf_count);</span>
<span class="line" id="L215">            self.dynamic_segments = allocator.shrink(self.dynamic_segments, new_cap_shelf_count);</span>
<span class="line" id="L216">        }</span>
<span class="line" id="L217"></span>
<span class="line" id="L218">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">shrink</span>(self: *Self, new_len: <span class="tok-type">usize</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L219">            assert(new_len &lt;= self.len);</span>
<span class="line" id="L220">            <span class="tok-comment">// TODO take advantage of the new realloc semantics</span>
</span>
<span class="line" id="L221">            self.len = new_len;</span>
<span class="line" id="L222">        }</span>
<span class="line" id="L223"></span>
<span class="line" id="L224">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">writeToSlice</span>(self: *Self, dest: []T, start: <span class="tok-type">usize</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L225">            <span class="tok-kw">const</span> end = start + dest.len;</span>
<span class="line" id="L226">            assert(end &lt;= self.len);</span>
<span class="line" id="L227"></span>
<span class="line" id="L228">            <span class="tok-kw">var</span> i = start;</span>
<span class="line" id="L229">            <span class="tok-kw">if</span> (end &lt;= prealloc_item_count) {</span>
<span class="line" id="L230">                std.mem.copy(T, dest[i - start ..], self.prealloc_segment[i..end]);</span>
<span class="line" id="L231">                <span class="tok-kw">return</span>;</span>
<span class="line" id="L232">            } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (i &lt; prealloc_item_count) {</span>
<span class="line" id="L233">                std.mem.copy(T, dest[i - start ..], self.prealloc_segment[i..]);</span>
<span class="line" id="L234">                i = prealloc_item_count;</span>
<span class="line" id="L235">            }</span>
<span class="line" id="L236"></span>
<span class="line" id="L237">            <span class="tok-kw">while</span> (i &lt; end) {</span>
<span class="line" id="L238">                <span class="tok-kw">const</span> shelf_index = shelfIndex(i);</span>
<span class="line" id="L239">                <span class="tok-kw">const</span> copy_start = boxIndex(i, shelf_index);</span>
<span class="line" id="L240">                <span class="tok-kw">const</span> copy_end = std.math.min(shelfSize(shelf_index), copy_start + end - i);</span>
<span class="line" id="L241"></span>
<span class="line" id="L242">                std.mem.copy(</span>
<span class="line" id="L243">                    T,</span>
<span class="line" id="L244">                    dest[i - start ..],</span>
<span class="line" id="L245">                    self.dynamic_segments[shelf_index][copy_start..copy_end],</span>
<span class="line" id="L246">                );</span>
<span class="line" id="L247"></span>
<span class="line" id="L248">                i += (copy_end - copy_start);</span>
<span class="line" id="L249">            }</span>
<span class="line" id="L250">        }</span>
<span class="line" id="L251"></span>
<span class="line" id="L252">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">uncheckedAt</span>(self: <span class="tok-kw">anytype</span>, index: <span class="tok-type">usize</span>) AtType(<span class="tok-builtin">@TypeOf</span>(self)) {</span>
<span class="line" id="L253">            <span class="tok-kw">if</span> (index &lt; prealloc_item_count) {</span>
<span class="line" id="L254">                <span class="tok-kw">return</span> &amp;self.prealloc_segment[index];</span>
<span class="line" id="L255">            }</span>
<span class="line" id="L256">            <span class="tok-kw">const</span> shelf_index = shelfIndex(index);</span>
<span class="line" id="L257">            <span class="tok-kw">const</span> box_index = boxIndex(index, shelf_index);</span>
<span class="line" id="L258">            <span class="tok-kw">return</span> &amp;self.dynamic_segments[shelf_index][box_index];</span>
<span class="line" id="L259">        }</span>
<span class="line" id="L260"></span>
<span class="line" id="L261">        <span class="tok-kw">fn</span> <span class="tok-fn">shelfCount</span>(box_count: <span class="tok-type">usize</span>) ShelfIndex {</span>
<span class="line" id="L262">            <span class="tok-kw">if</span> (prealloc_item_count == <span class="tok-number">0</span>) {</span>
<span class="line" id="L263">                <span class="tok-kw">return</span> log2_int_ceil(<span class="tok-type">usize</span>, box_count + <span class="tok-number">1</span>);</span>
<span class="line" id="L264">            }</span>
<span class="line" id="L265">            <span class="tok-kw">return</span> log2_int_ceil(<span class="tok-type">usize</span>, box_count + prealloc_item_count) - prealloc_exp - <span class="tok-number">1</span>;</span>
<span class="line" id="L266">        }</span>
<span class="line" id="L267"></span>
<span class="line" id="L268">        <span class="tok-kw">fn</span> <span class="tok-fn">shelfSize</span>(shelf_index: ShelfIndex) <span class="tok-type">usize</span> {</span>
<span class="line" id="L269">            <span class="tok-kw">if</span> (prealloc_item_count == <span class="tok-number">0</span>) {</span>
<span class="line" id="L270">                <span class="tok-kw">return</span> <span class="tok-builtin">@as</span>(<span class="tok-type">usize</span>, <span class="tok-number">1</span>) &lt;&lt; shelf_index;</span>
<span class="line" id="L271">            }</span>
<span class="line" id="L272">            <span class="tok-kw">return</span> <span class="tok-builtin">@as</span>(<span class="tok-type">usize</span>, <span class="tok-number">1</span>) &lt;&lt; (shelf_index + (prealloc_exp + <span class="tok-number">1</span>));</span>
<span class="line" id="L273">        }</span>
<span class="line" id="L274"></span>
<span class="line" id="L275">        <span class="tok-kw">fn</span> <span class="tok-fn">shelfIndex</span>(list_index: <span class="tok-type">usize</span>) ShelfIndex {</span>
<span class="line" id="L276">            <span class="tok-kw">if</span> (prealloc_item_count == <span class="tok-number">0</span>) {</span>
<span class="line" id="L277">                <span class="tok-kw">return</span> std.math.log2_int(<span class="tok-type">usize</span>, list_index + <span class="tok-number">1</span>);</span>
<span class="line" id="L278">            }</span>
<span class="line" id="L279">            <span class="tok-kw">return</span> std.math.log2_int(<span class="tok-type">usize</span>, list_index + prealloc_item_count) - prealloc_exp - <span class="tok-number">1</span>;</span>
<span class="line" id="L280">        }</span>
<span class="line" id="L281"></span>
<span class="line" id="L282">        <span class="tok-kw">fn</span> <span class="tok-fn">boxIndex</span>(list_index: <span class="tok-type">usize</span>, shelf_index: ShelfIndex) <span class="tok-type">usize</span> {</span>
<span class="line" id="L283">            <span class="tok-kw">if</span> (prealloc_item_count == <span class="tok-number">0</span>) {</span>
<span class="line" id="L284">                <span class="tok-kw">return</span> (list_index + <span class="tok-number">1</span>) - (<span class="tok-builtin">@as</span>(<span class="tok-type">usize</span>, <span class="tok-number">1</span>) &lt;&lt; shelf_index);</span>
<span class="line" id="L285">            }</span>
<span class="line" id="L286">            <span class="tok-kw">return</span> list_index + prealloc_item_count - (<span class="tok-builtin">@as</span>(<span class="tok-type">usize</span>, <span class="tok-number">1</span>) &lt;&lt; ((prealloc_exp + <span class="tok-number">1</span>) + shelf_index));</span>
<span class="line" id="L287">        }</span>
<span class="line" id="L288"></span>
<span class="line" id="L289">        <span class="tok-kw">fn</span> <span class="tok-fn">freeShelves</span>(self: *Self, allocator: Allocator, from_count: ShelfIndex, to_count: ShelfIndex) <span class="tok-type">void</span> {</span>
<span class="line" id="L290">            <span class="tok-kw">var</span> i = from_count;</span>
<span class="line" id="L291">            <span class="tok-kw">while</span> (i != to_count) {</span>
<span class="line" id="L292">                i -= <span class="tok-number">1</span>;</span>
<span class="line" id="L293">                allocator.free(self.dynamic_segments[i][<span class="tok-number">0</span>..shelfSize(i)]);</span>
<span class="line" id="L294">            }</span>
<span class="line" id="L295">        }</span>
<span class="line" id="L296"></span>
<span class="line" id="L297">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> Iterator = BaseIterator(*Self, *T);</span>
<span class="line" id="L298">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> ConstIterator = BaseIterator(*<span class="tok-kw">const</span> Self, *<span class="tok-kw">const</span> T);</span>
<span class="line" id="L299">        <span class="tok-kw">fn</span> <span class="tok-fn">BaseIterator</span>(<span class="tok-kw">comptime</span> SelfType: <span class="tok-type">type</span>, <span class="tok-kw">comptime</span> ElementPtr: <span class="tok-type">type</span>) <span class="tok-type">type</span> {</span>
<span class="line" id="L300">            <span class="tok-kw">return</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L301">                list: SelfType,</span>
<span class="line" id="L302">                index: <span class="tok-type">usize</span>,</span>
<span class="line" id="L303">                box_index: <span class="tok-type">usize</span>,</span>
<span class="line" id="L304">                shelf_index: ShelfIndex,</span>
<span class="line" id="L305">                shelf_size: <span class="tok-type">usize</span>,</span>
<span class="line" id="L306"></span>
<span class="line" id="L307">                <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">next</span>(it: *<span class="tok-builtin">@This</span>()) ?ElementPtr {</span>
<span class="line" id="L308">                    <span class="tok-kw">if</span> (it.index &gt;= it.list.len) <span class="tok-kw">return</span> <span class="tok-null">null</span>;</span>
<span class="line" id="L309">                    <span class="tok-kw">if</span> (it.index &lt; prealloc_item_count) {</span>
<span class="line" id="L310">                        <span class="tok-kw">const</span> ptr = &amp;it.list.prealloc_segment[it.index];</span>
<span class="line" id="L311">                        it.index += <span class="tok-number">1</span>;</span>
<span class="line" id="L312">                        <span class="tok-kw">if</span> (it.index == prealloc_item_count) {</span>
<span class="line" id="L313">                            it.box_index = <span class="tok-number">0</span>;</span>
<span class="line" id="L314">                            it.shelf_index = <span class="tok-number">0</span>;</span>
<span class="line" id="L315">                            it.shelf_size = prealloc_item_count * <span class="tok-number">2</span>;</span>
<span class="line" id="L316">                        }</span>
<span class="line" id="L317">                        <span class="tok-kw">return</span> ptr;</span>
<span class="line" id="L318">                    }</span>
<span class="line" id="L319"></span>
<span class="line" id="L320">                    <span class="tok-kw">const</span> ptr = &amp;it.list.dynamic_segments[it.shelf_index][it.box_index];</span>
<span class="line" id="L321">                    it.index += <span class="tok-number">1</span>;</span>
<span class="line" id="L322">                    it.box_index += <span class="tok-number">1</span>;</span>
<span class="line" id="L323">                    <span class="tok-kw">if</span> (it.box_index == it.shelf_size) {</span>
<span class="line" id="L324">                        it.shelf_index += <span class="tok-number">1</span>;</span>
<span class="line" id="L325">                        it.box_index = <span class="tok-number">0</span>;</span>
<span class="line" id="L326">                        it.shelf_size *= <span class="tok-number">2</span>;</span>
<span class="line" id="L327">                    }</span>
<span class="line" id="L328">                    <span class="tok-kw">return</span> ptr;</span>
<span class="line" id="L329">                }</span>
<span class="line" id="L330"></span>
<span class="line" id="L331">                <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">prev</span>(it: *<span class="tok-builtin">@This</span>()) ?ElementPtr {</span>
<span class="line" id="L332">                    <span class="tok-kw">if</span> (it.index == <span class="tok-number">0</span>) <span class="tok-kw">return</span> <span class="tok-null">null</span>;</span>
<span class="line" id="L333"></span>
<span class="line" id="L334">                    it.index -= <span class="tok-number">1</span>;</span>
<span class="line" id="L335">                    <span class="tok-kw">if</span> (it.index &lt; prealloc_item_count) <span class="tok-kw">return</span> &amp;it.list.prealloc_segment[it.index];</span>
<span class="line" id="L336"></span>
<span class="line" id="L337">                    <span class="tok-kw">if</span> (it.box_index == <span class="tok-number">0</span>) {</span>
<span class="line" id="L338">                        it.shelf_index -= <span class="tok-number">1</span>;</span>
<span class="line" id="L339">                        it.shelf_size /= <span class="tok-number">2</span>;</span>
<span class="line" id="L340">                        it.box_index = it.shelf_size - <span class="tok-number">1</span>;</span>
<span class="line" id="L341">                    } <span class="tok-kw">else</span> {</span>
<span class="line" id="L342">                        it.box_index -= <span class="tok-number">1</span>;</span>
<span class="line" id="L343">                    }</span>
<span class="line" id="L344"></span>
<span class="line" id="L345">                    <span class="tok-kw">return</span> &amp;it.list.dynamic_segments[it.shelf_index][it.box_index];</span>
<span class="line" id="L346">                }</span>
<span class="line" id="L347"></span>
<span class="line" id="L348">                <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">peek</span>(it: *<span class="tok-builtin">@This</span>()) ?ElementPtr {</span>
<span class="line" id="L349">                    <span class="tok-kw">if</span> (it.index &gt;= it.list.len)</span>
<span class="line" id="L350">                        <span class="tok-kw">return</span> <span class="tok-null">null</span>;</span>
<span class="line" id="L351">                    <span class="tok-kw">if</span> (it.index &lt; prealloc_item_count)</span>
<span class="line" id="L352">                        <span class="tok-kw">return</span> &amp;it.list.prealloc_segment[it.index];</span>
<span class="line" id="L353"></span>
<span class="line" id="L354">                    <span class="tok-kw">return</span> &amp;it.list.dynamic_segments[it.shelf_index][it.box_index];</span>
<span class="line" id="L355">                }</span>
<span class="line" id="L356"></span>
<span class="line" id="L357">                <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">set</span>(it: *<span class="tok-builtin">@This</span>(), index: <span class="tok-type">usize</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L358">                    it.index = index;</span>
<span class="line" id="L359">                    <span class="tok-kw">if</span> (index &lt; prealloc_item_count) <span class="tok-kw">return</span>;</span>
<span class="line" id="L360">                    it.shelf_index = shelfIndex(index);</span>
<span class="line" id="L361">                    it.box_index = boxIndex(index, it.shelf_index);</span>
<span class="line" id="L362">                    it.shelf_size = shelfSize(it.shelf_index);</span>
<span class="line" id="L363">                }</span>
<span class="line" id="L364">            };</span>
<span class="line" id="L365">        }</span>
<span class="line" id="L366"></span>
<span class="line" id="L367">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">iterator</span>(self: *Self, start_index: <span class="tok-type">usize</span>) Iterator {</span>
<span class="line" id="L368">            <span class="tok-kw">var</span> it = Iterator{</span>
<span class="line" id="L369">                .list = self,</span>
<span class="line" id="L370">                .index = <span class="tok-null">undefined</span>,</span>
<span class="line" id="L371">                .shelf_index = <span class="tok-null">undefined</span>,</span>
<span class="line" id="L372">                .box_index = <span class="tok-null">undefined</span>,</span>
<span class="line" id="L373">                .shelf_size = <span class="tok-null">undefined</span>,</span>
<span class="line" id="L374">            };</span>
<span class="line" id="L375">            it.set(start_index);</span>
<span class="line" id="L376">            <span class="tok-kw">return</span> it;</span>
<span class="line" id="L377">        }</span>
<span class="line" id="L378"></span>
<span class="line" id="L379">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">constIterator</span>(self: *<span class="tok-kw">const</span> Self, start_index: <span class="tok-type">usize</span>) ConstIterator {</span>
<span class="line" id="L380">            <span class="tok-kw">var</span> it = ConstIterator{</span>
<span class="line" id="L381">                .list = self,</span>
<span class="line" id="L382">                .index = <span class="tok-null">undefined</span>,</span>
<span class="line" id="L383">                .shelf_index = <span class="tok-null">undefined</span>,</span>
<span class="line" id="L384">                .box_index = <span class="tok-null">undefined</span>,</span>
<span class="line" id="L385">                .shelf_size = <span class="tok-null">undefined</span>,</span>
<span class="line" id="L386">            };</span>
<span class="line" id="L387">            it.set(start_index);</span>
<span class="line" id="L388">            <span class="tok-kw">return</span> it;</span>
<span class="line" id="L389">        }</span>
<span class="line" id="L390">    };</span>
<span class="line" id="L391">}</span>
<span class="line" id="L392"></span>
<span class="line" id="L393"><span class="tok-kw">test</span> <span class="tok-str">&quot;SegmentedList basic usage&quot;</span> {</span>
<span class="line" id="L394">    <span class="tok-kw">if</span> (<span class="tok-builtin">@import</span>(<span class="tok-str">&quot;builtin&quot;</span>).zig_backend == .stage1) {</span>
<span class="line" id="L395">        <span class="tok-comment">// https://github.com/ziglang/zig/issues/11787</span>
</span>
<span class="line" id="L396">        <span class="tok-kw">try</span> testSegmentedList(<span class="tok-number">0</span>);</span>
<span class="line" id="L397">    }</span>
<span class="line" id="L398">    <span class="tok-kw">try</span> testSegmentedList(<span class="tok-number">1</span>);</span>
<span class="line" id="L399">    <span class="tok-kw">try</span> testSegmentedList(<span class="tok-number">2</span>);</span>
<span class="line" id="L400">    <span class="tok-kw">try</span> testSegmentedList(<span class="tok-number">4</span>);</span>
<span class="line" id="L401">    <span class="tok-kw">try</span> testSegmentedList(<span class="tok-number">8</span>);</span>
<span class="line" id="L402">    <span class="tok-kw">try</span> testSegmentedList(<span class="tok-number">16</span>);</span>
<span class="line" id="L403">}</span>
<span class="line" id="L404"></span>
<span class="line" id="L405"><span class="tok-kw">fn</span> <span class="tok-fn">testSegmentedList</span>(<span class="tok-kw">comptime</span> prealloc: <span class="tok-type">usize</span>) !<span class="tok-type">void</span> {</span>
<span class="line" id="L406">    <span class="tok-kw">const</span> gpa = std.testing.allocator;</span>
<span class="line" id="L407"></span>
<span class="line" id="L408">    <span class="tok-kw">var</span> list: SegmentedList(<span class="tok-type">i32</span>, prealloc) = .{};</span>
<span class="line" id="L409">    <span class="tok-kw">defer</span> list.deinit(gpa);</span>
<span class="line" id="L410"></span>
<span class="line" id="L411">    {</span>
<span class="line" id="L412">        <span class="tok-kw">var</span> i: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L413">        <span class="tok-kw">while</span> (i &lt; <span class="tok-number">100</span>) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L414">            <span class="tok-kw">try</span> list.append(gpa, <span class="tok-builtin">@intCast</span>(<span class="tok-type">i32</span>, i + <span class="tok-number">1</span>));</span>
<span class="line" id="L415">            <span class="tok-kw">try</span> testing.expect(list.len == i + <span class="tok-number">1</span>);</span>
<span class="line" id="L416">        }</span>
<span class="line" id="L417">    }</span>
<span class="line" id="L418"></span>
<span class="line" id="L419">    {</span>
<span class="line" id="L420">        <span class="tok-kw">var</span> i: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L421">        <span class="tok-kw">while</span> (i &lt; <span class="tok-number">100</span>) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L422">            <span class="tok-kw">try</span> testing.expect(list.at(i).* == <span class="tok-builtin">@intCast</span>(<span class="tok-type">i32</span>, i + <span class="tok-number">1</span>));</span>
<span class="line" id="L423">        }</span>
<span class="line" id="L424">    }</span>
<span class="line" id="L425"></span>
<span class="line" id="L426">    {</span>
<span class="line" id="L427">        <span class="tok-kw">var</span> it = list.iterator(<span class="tok-number">0</span>);</span>
<span class="line" id="L428">        <span class="tok-kw">var</span> x: <span class="tok-type">i32</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L429">        <span class="tok-kw">while</span> (it.next()) |item| {</span>
<span class="line" id="L430">            x += <span class="tok-number">1</span>;</span>
<span class="line" id="L431">            <span class="tok-kw">try</span> testing.expect(item.* == x);</span>
<span class="line" id="L432">        }</span>
<span class="line" id="L433">        <span class="tok-kw">try</span> testing.expect(x == <span class="tok-number">100</span>);</span>
<span class="line" id="L434">        <span class="tok-kw">while</span> (it.prev()) |item| : (x -= <span class="tok-number">1</span>) {</span>
<span class="line" id="L435">            <span class="tok-kw">try</span> testing.expect(item.* == x);</span>
<span class="line" id="L436">        }</span>
<span class="line" id="L437">        <span class="tok-kw">try</span> testing.expect(x == <span class="tok-number">0</span>);</span>
<span class="line" id="L438">    }</span>
<span class="line" id="L439"></span>
<span class="line" id="L440">    {</span>
<span class="line" id="L441">        <span class="tok-kw">var</span> it = list.constIterator(<span class="tok-number">0</span>);</span>
<span class="line" id="L442">        <span class="tok-kw">var</span> x: <span class="tok-type">i32</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L443">        <span class="tok-kw">while</span> (it.next()) |item| {</span>
<span class="line" id="L444">            x += <span class="tok-number">1</span>;</span>
<span class="line" id="L445">            <span class="tok-kw">try</span> testing.expect(item.* == x);</span>
<span class="line" id="L446">        }</span>
<span class="line" id="L447">        <span class="tok-kw">try</span> testing.expect(x == <span class="tok-number">100</span>);</span>
<span class="line" id="L448">        <span class="tok-kw">while</span> (it.prev()) |item| : (x -= <span class="tok-number">1</span>) {</span>
<span class="line" id="L449">            <span class="tok-kw">try</span> testing.expect(item.* == x);</span>
<span class="line" id="L450">        }</span>
<span class="line" id="L451">        <span class="tok-kw">try</span> testing.expect(x == <span class="tok-number">0</span>);</span>
<span class="line" id="L452">    }</span>
<span class="line" id="L453"></span>
<span class="line" id="L454">    <span class="tok-kw">try</span> testing.expect(list.pop().? == <span class="tok-number">100</span>);</span>
<span class="line" id="L455">    <span class="tok-kw">try</span> testing.expect(list.len == <span class="tok-number">99</span>);</span>
<span class="line" id="L456"></span>
<span class="line" id="L457">    <span class="tok-kw">try</span> list.appendSlice(gpa, &amp;[_]<span class="tok-type">i32</span>{ <span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">3</span> });</span>
<span class="line" id="L458">    <span class="tok-kw">try</span> testing.expect(list.len == <span class="tok-number">102</span>);</span>
<span class="line" id="L459">    <span class="tok-kw">try</span> testing.expect(list.pop().? == <span class="tok-number">3</span>);</span>
<span class="line" id="L460">    <span class="tok-kw">try</span> testing.expect(list.pop().? == <span class="tok-number">2</span>);</span>
<span class="line" id="L461">    <span class="tok-kw">try</span> testing.expect(list.pop().? == <span class="tok-number">1</span>);</span>
<span class="line" id="L462">    <span class="tok-kw">try</span> testing.expect(list.len == <span class="tok-number">99</span>);</span>
<span class="line" id="L463"></span>
<span class="line" id="L464">    <span class="tok-kw">try</span> list.appendSlice(gpa, &amp;[_]<span class="tok-type">i32</span>{});</span>
<span class="line" id="L465">    <span class="tok-kw">try</span> testing.expect(list.len == <span class="tok-number">99</span>);</span>
<span class="line" id="L466"></span>
<span class="line" id="L467">    {</span>
<span class="line" id="L468">        <span class="tok-kw">var</span> i: <span class="tok-type">i32</span> = <span class="tok-number">99</span>;</span>
<span class="line" id="L469">        <span class="tok-kw">while</span> (list.pop()) |item| : (i -= <span class="tok-number">1</span>) {</span>
<span class="line" id="L470">            <span class="tok-kw">try</span> testing.expect(item == i);</span>
<span class="line" id="L471">            list.shrinkCapacity(gpa, list.len);</span>
<span class="line" id="L472">        }</span>
<span class="line" id="L473">    }</span>
<span class="line" id="L474"></span>
<span class="line" id="L475">    {</span>
<span class="line" id="L476">        <span class="tok-kw">var</span> control: [<span class="tok-number">100</span>]<span class="tok-type">i32</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L477">        <span class="tok-kw">var</span> dest: [<span class="tok-number">100</span>]<span class="tok-type">i32</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L478"></span>
<span class="line" id="L479">        <span class="tok-kw">var</span> i: <span class="tok-type">i32</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L480">        <span class="tok-kw">while</span> (i &lt; <span class="tok-number">100</span>) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L481">            <span class="tok-kw">try</span> list.append(gpa, i + <span class="tok-number">1</span>);</span>
<span class="line" id="L482">            control[<span class="tok-builtin">@intCast</span>(<span class="tok-type">usize</span>, i)] = i + <span class="tok-number">1</span>;</span>
<span class="line" id="L483">        }</span>
<span class="line" id="L484"></span>
<span class="line" id="L485">        std.mem.set(<span class="tok-type">i32</span>, dest[<span class="tok-number">0</span>..], <span class="tok-number">0</span>);</span>
<span class="line" id="L486">        list.writeToSlice(dest[<span class="tok-number">0</span>..], <span class="tok-number">0</span>);</span>
<span class="line" id="L487">        <span class="tok-kw">try</span> testing.expect(std.mem.eql(<span class="tok-type">i32</span>, control[<span class="tok-number">0</span>..], dest[<span class="tok-number">0</span>..]));</span>
<span class="line" id="L488"></span>
<span class="line" id="L489">        std.mem.set(<span class="tok-type">i32</span>, dest[<span class="tok-number">0</span>..], <span class="tok-number">0</span>);</span>
<span class="line" id="L490">        list.writeToSlice(dest[<span class="tok-number">50</span>..], <span class="tok-number">50</span>);</span>
<span class="line" id="L491">        <span class="tok-kw">try</span> testing.expect(std.mem.eql(<span class="tok-type">i32</span>, control[<span class="tok-number">50</span>..], dest[<span class="tok-number">50</span>..]));</span>
<span class="line" id="L492">    }</span>
<span class="line" id="L493"></span>
<span class="line" id="L494">    <span class="tok-kw">try</span> list.setCapacity(gpa, <span class="tok-number">0</span>);</span>
<span class="line" id="L495">}</span>
<span class="line" id="L496"></span>
<span class="line" id="L497"><span class="tok-comment">/// TODO look into why this std.math function was changed in</span></span>
<span class="line" id="L498"><span class="tok-comment">/// fc9430f56798a53f9393a697f4ccd6bf9981b970.</span></span>
<span class="line" id="L499"><span class="tok-kw">fn</span> <span class="tok-fn">log2_int_ceil</span>(<span class="tok-kw">comptime</span> T: <span class="tok-type">type</span>, x: T) std.math.Log2Int(T) {</span>
<span class="line" id="L500">    assert(x != <span class="tok-number">0</span>);</span>
<span class="line" id="L501">    <span class="tok-kw">const</span> log2_val = std.math.log2_int(T, x);</span>
<span class="line" id="L502">    <span class="tok-kw">if</span> (<span class="tok-builtin">@as</span>(T, <span class="tok-number">1</span>) &lt;&lt; log2_val == x)</span>
<span class="line" id="L503">        <span class="tok-kw">return</span> log2_val;</span>
<span class="line" id="L504">    <span class="tok-kw">return</span> log2_val + <span class="tok-number">1</span>;</span>
<span class="line" id="L505">}</span>
<span class="line" id="L506"></span>
</code></pre></body>
</html>