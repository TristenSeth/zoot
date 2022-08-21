<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">    <title>array_list.zig - source view</title>
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
<span class="line" id="L2"><span class="tok-kw">const</span> debug = std.debug;</span>
<span class="line" id="L3"><span class="tok-kw">const</span> assert = debug.assert;</span>
<span class="line" id="L4"><span class="tok-kw">const</span> testing = std.testing;</span>
<span class="line" id="L5"><span class="tok-kw">const</span> mem = std.mem;</span>
<span class="line" id="L6"><span class="tok-kw">const</span> Allocator = mem.Allocator;</span>
<span class="line" id="L7"></span>
<span class="line" id="L8"><span class="tok-comment">/// A contiguous, growable list of items in memory.</span></span>
<span class="line" id="L9"><span class="tok-comment">/// This is a wrapper around an array of T values. Initialize with `init`.</span></span>
<span class="line" id="L10"><span class="tok-comment">///</span></span>
<span class="line" id="L11"><span class="tok-comment">/// This struct internally stores a `std.mem.Allocator` for memory management.</span></span>
<span class="line" id="L12"><span class="tok-comment">/// To manually specify an allocator with each method call see `ArrayListUnmanaged`.</span></span>
<span class="line" id="L13"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">ArrayList</span>(<span class="tok-kw">comptime</span> T: <span class="tok-type">type</span>) <span class="tok-type">type</span> {</span>
<span class="line" id="L14">    <span class="tok-kw">return</span> ArrayListAligned(T, <span class="tok-null">null</span>);</span>
<span class="line" id="L15">}</span>
<span class="line" id="L16"></span>
<span class="line" id="L17"><span class="tok-comment">/// A contiguous, growable list of arbitrarily aligned items in memory.</span></span>
<span class="line" id="L18"><span class="tok-comment">/// This is a wrapper around an array of T values aligned to `alignment`-byte</span></span>
<span class="line" id="L19"><span class="tok-comment">/// addresses. If the specified alignment is `null`, then `@alignOf(T)` is used.</span></span>
<span class="line" id="L20"><span class="tok-comment">/// Initialize with `init`.</span></span>
<span class="line" id="L21"><span class="tok-comment">///</span></span>
<span class="line" id="L22"><span class="tok-comment">/// This struct internally stores a `std.mem.Allocator` for memory management.</span></span>
<span class="line" id="L23"><span class="tok-comment">/// To manually specify an allocator with each method call see `ArrayListAlignedUnmanaged`.</span></span>
<span class="line" id="L24"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">ArrayListAligned</span>(<span class="tok-kw">comptime</span> T: <span class="tok-type">type</span>, <span class="tok-kw">comptime</span> alignment: ?<span class="tok-type">u29</span>) <span class="tok-type">type</span> {</span>
<span class="line" id="L25">    <span class="tok-kw">if</span> (alignment) |a| {</span>
<span class="line" id="L26">        <span class="tok-kw">if</span> (a == <span class="tok-builtin">@alignOf</span>(T)) {</span>
<span class="line" id="L27">            <span class="tok-kw">return</span> ArrayListAligned(T, <span class="tok-null">null</span>);</span>
<span class="line" id="L28">        }</span>
<span class="line" id="L29">    }</span>
<span class="line" id="L30">    <span class="tok-kw">return</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L31">        <span class="tok-kw">const</span> Self = <span class="tok-builtin">@This</span>();</span>
<span class="line" id="L32">        <span class="tok-comment">/// Contents of the list. Pointers to elements in this slice are</span></span>
<span class="line" id="L33">        <span class="tok-comment">/// **invalid after resizing operations** on the ArrayList, unless the</span></span>
<span class="line" id="L34">        <span class="tok-comment">/// operation explicitly either: (1) states otherwise or (2) lists the</span></span>
<span class="line" id="L35">        <span class="tok-comment">/// invalidated pointers.</span></span>
<span class="line" id="L36">        <span class="tok-comment">///</span></span>
<span class="line" id="L37">        <span class="tok-comment">/// The allocator used determines how element pointers are</span></span>
<span class="line" id="L38">        <span class="tok-comment">/// invalidated, so the behavior may vary between lists. To avoid</span></span>
<span class="line" id="L39">        <span class="tok-comment">/// illegal behavior, take into account the above paragraph plus the</span></span>
<span class="line" id="L40">        <span class="tok-comment">/// explicit statements given in each method.</span></span>
<span class="line" id="L41">        items: Slice,</span>
<span class="line" id="L42">        <span class="tok-comment">/// How many T values this list can hold without allocating</span></span>
<span class="line" id="L43">        <span class="tok-comment">/// additional memory.</span></span>
<span class="line" id="L44">        capacity: <span class="tok-type">usize</span>,</span>
<span class="line" id="L45">        allocator: Allocator,</span>
<span class="line" id="L46"></span>
<span class="line" id="L47">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> Slice = <span class="tok-kw">if</span> (alignment) |a| ([]<span class="tok-kw">align</span>(a) T) <span class="tok-kw">else</span> []T;</span>
<span class="line" id="L48"></span>
<span class="line" id="L49">        <span class="tok-comment">/// Deinitialize with `deinit` or use `toOwnedSlice`.</span></span>
<span class="line" id="L50">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">init</span>(allocator: Allocator) Self {</span>
<span class="line" id="L51">            <span class="tok-kw">return</span> Self{</span>
<span class="line" id="L52">                .items = &amp;[_]T{},</span>
<span class="line" id="L53">                .capacity = <span class="tok-number">0</span>,</span>
<span class="line" id="L54">                .allocator = allocator,</span>
<span class="line" id="L55">            };</span>
<span class="line" id="L56">        }</span>
<span class="line" id="L57"></span>
<span class="line" id="L58">        <span class="tok-comment">/// Initialize with capacity to hold at least `num` elements.</span></span>
<span class="line" id="L59">        <span class="tok-comment">/// The resulting capacity is likely to be equal to `num`.</span></span>
<span class="line" id="L60">        <span class="tok-comment">/// Deinitialize with `deinit` or use `toOwnedSlice`.</span></span>
<span class="line" id="L61">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">initCapacity</span>(allocator: Allocator, num: <span class="tok-type">usize</span>) Allocator.Error!Self {</span>
<span class="line" id="L62">            <span class="tok-kw">var</span> self = Self.init(allocator);</span>
<span class="line" id="L63">            <span class="tok-kw">try</span> self.ensureTotalCapacityPrecise(num);</span>
<span class="line" id="L64">            <span class="tok-kw">return</span> self;</span>
<span class="line" id="L65">        }</span>
<span class="line" id="L66"></span>
<span class="line" id="L67">        <span class="tok-comment">/// Release all allocated memory.</span></span>
<span class="line" id="L68">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">deinit</span>(self: Self) <span class="tok-type">void</span> {</span>
<span class="line" id="L69">            <span class="tok-kw">if</span> (<span class="tok-builtin">@sizeOf</span>(T) &gt; <span class="tok-number">0</span>) {</span>
<span class="line" id="L70">                self.allocator.free(self.allocatedSlice());</span>
<span class="line" id="L71">            }</span>
<span class="line" id="L72">        }</span>
<span class="line" id="L73"></span>
<span class="line" id="L74">        <span class="tok-comment">/// ArrayList takes ownership of the passed in slice. The slice must have been</span></span>
<span class="line" id="L75">        <span class="tok-comment">/// allocated with `allocator`.</span></span>
<span class="line" id="L76">        <span class="tok-comment">/// Deinitialize with `deinit` or use `toOwnedSlice`.</span></span>
<span class="line" id="L77">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">fromOwnedSlice</span>(allocator: Allocator, slice: Slice) Self {</span>
<span class="line" id="L78">            <span class="tok-kw">return</span> Self{</span>
<span class="line" id="L79">                .items = slice,</span>
<span class="line" id="L80">                .capacity = slice.len,</span>
<span class="line" id="L81">                .allocator = allocator,</span>
<span class="line" id="L82">            };</span>
<span class="line" id="L83">        }</span>
<span class="line" id="L84"></span>
<span class="line" id="L85">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> toUnmanaged = <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;deprecated; use `moveToUnmanaged` which has different semantics.&quot;</span>);</span>
<span class="line" id="L86"></span>
<span class="line" id="L87">        <span class="tok-comment">/// Initializes an ArrayListUnmanaged with the `items` and `capacity` fields</span></span>
<span class="line" id="L88">        <span class="tok-comment">/// of this ArrayList. Empties this ArrayList.</span></span>
<span class="line" id="L89">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">moveToUnmanaged</span>(self: *Self) ArrayListAlignedUnmanaged(T, alignment) {</span>
<span class="line" id="L90">            <span class="tok-kw">const</span> allocator = self.allocator;</span>
<span class="line" id="L91">            <span class="tok-kw">const</span> result = .{ .items = self.items, .capacity = self.capacity };</span>
<span class="line" id="L92">            self.* = init(allocator);</span>
<span class="line" id="L93">            <span class="tok-kw">return</span> result;</span>
<span class="line" id="L94">        }</span>
<span class="line" id="L95"></span>
<span class="line" id="L96">        <span class="tok-comment">/// The caller owns the returned memory. Empties this ArrayList.</span></span>
<span class="line" id="L97">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">toOwnedSlice</span>(self: *Self) Slice {</span>
<span class="line" id="L98">            <span class="tok-kw">const</span> allocator = self.allocator;</span>
<span class="line" id="L99">            <span class="tok-kw">const</span> result = allocator.shrink(self.allocatedSlice(), self.items.len);</span>
<span class="line" id="L100">            self.* = init(allocator);</span>
<span class="line" id="L101">            <span class="tok-kw">return</span> result;</span>
<span class="line" id="L102">        }</span>
<span class="line" id="L103"></span>
<span class="line" id="L104">        <span class="tok-comment">/// The caller owns the returned memory. Empties this ArrayList.</span></span>
<span class="line" id="L105">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">toOwnedSliceSentinel</span>(self: *Self, <span class="tok-kw">comptime</span> sentinel: T) Allocator.Error![:sentinel]T {</span>
<span class="line" id="L106">            <span class="tok-kw">try</span> self.append(sentinel);</span>
<span class="line" id="L107">            <span class="tok-kw">const</span> result = self.toOwnedSlice();</span>
<span class="line" id="L108">            <span class="tok-kw">return</span> result[<span class="tok-number">0</span> .. result.len - <span class="tok-number">1</span> :sentinel];</span>
<span class="line" id="L109">        }</span>
<span class="line" id="L110"></span>
<span class="line" id="L111">        <span class="tok-comment">/// Creates a copy of this ArrayList, using the same allocator.</span></span>
<span class="line" id="L112">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">clone</span>(self: *Self) Allocator.Error!Self {</span>
<span class="line" id="L113">            <span class="tok-kw">var</span> cloned = <span class="tok-kw">try</span> Self.initCapacity(self.allocator, self.capacity);</span>
<span class="line" id="L114">            cloned.appendSliceAssumeCapacity(self.items);</span>
<span class="line" id="L115">            <span class="tok-kw">return</span> cloned;</span>
<span class="line" id="L116">        }</span>
<span class="line" id="L117"></span>
<span class="line" id="L118">        <span class="tok-comment">/// Insert `item` at index `n` by moving `list[n .. list.len]` to make room.</span></span>
<span class="line" id="L119">        <span class="tok-comment">/// This operation is O(N).</span></span>
<span class="line" id="L120">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">insert</span>(self: *Self, n: <span class="tok-type">usize</span>, item: T) Allocator.Error!<span class="tok-type">void</span> {</span>
<span class="line" id="L121">            <span class="tok-kw">try</span> self.ensureUnusedCapacity(<span class="tok-number">1</span>);</span>
<span class="line" id="L122">            self.items.len += <span class="tok-number">1</span>;</span>
<span class="line" id="L123"></span>
<span class="line" id="L124">            mem.copyBackwards(T, self.items[n + <span class="tok-number">1</span> .. self.items.len], self.items[n .. self.items.len - <span class="tok-number">1</span>]);</span>
<span class="line" id="L125">            self.items[n] = item;</span>
<span class="line" id="L126">        }</span>
<span class="line" id="L127"></span>
<span class="line" id="L128">        <span class="tok-comment">/// Insert slice `items` at index `i` by moving `list[i .. list.len]` to make room.</span></span>
<span class="line" id="L129">        <span class="tok-comment">/// This operation is O(N).</span></span>
<span class="line" id="L130">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">insertSlice</span>(self: *Self, i: <span class="tok-type">usize</span>, items: []<span class="tok-kw">const</span> T) Allocator.Error!<span class="tok-type">void</span> {</span>
<span class="line" id="L131">            <span class="tok-kw">try</span> self.ensureUnusedCapacity(items.len);</span>
<span class="line" id="L132">            self.items.len += items.len;</span>
<span class="line" id="L133"></span>
<span class="line" id="L134">            mem.copyBackwards(T, self.items[i + items.len .. self.items.len], self.items[i .. self.items.len - items.len]);</span>
<span class="line" id="L135">            mem.copy(T, self.items[i .. i + items.len], items);</span>
<span class="line" id="L136">        }</span>
<span class="line" id="L137"></span>
<span class="line" id="L138">        <span class="tok-comment">/// Replace range of elements `list[start..start+len]` with `new_items`.</span></span>
<span class="line" id="L139">        <span class="tok-comment">/// Grows list if `len &lt; new_items.len`.</span></span>
<span class="line" id="L140">        <span class="tok-comment">/// Shrinks list if `len &gt; new_items.len`.</span></span>
<span class="line" id="L141">        <span class="tok-comment">/// Invalidates pointers if this ArrayList is resized.</span></span>
<span class="line" id="L142">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">replaceRange</span>(self: *Self, start: <span class="tok-type">usize</span>, len: <span class="tok-type">usize</span>, new_items: []<span class="tok-kw">const</span> T) Allocator.Error!<span class="tok-type">void</span> {</span>
<span class="line" id="L143">            <span class="tok-kw">const</span> after_range = start + len;</span>
<span class="line" id="L144">            <span class="tok-kw">const</span> range = self.items[start..after_range];</span>
<span class="line" id="L145"></span>
<span class="line" id="L146">            <span class="tok-kw">if</span> (range.len == new_items.len)</span>
<span class="line" id="L147">                mem.copy(T, range, new_items)</span>
<span class="line" id="L148">            <span class="tok-kw">else</span> <span class="tok-kw">if</span> (range.len &lt; new_items.len) {</span>
<span class="line" id="L149">                <span class="tok-kw">const</span> first = new_items[<span class="tok-number">0</span>..range.len];</span>
<span class="line" id="L150">                <span class="tok-kw">const</span> rest = new_items[range.len..];</span>
<span class="line" id="L151"></span>
<span class="line" id="L152">                mem.copy(T, range, first);</span>
<span class="line" id="L153">                <span class="tok-kw">try</span> self.insertSlice(after_range, rest);</span>
<span class="line" id="L154">            } <span class="tok-kw">else</span> {</span>
<span class="line" id="L155">                mem.copy(T, range, new_items);</span>
<span class="line" id="L156">                <span class="tok-kw">const</span> after_subrange = start + new_items.len;</span>
<span class="line" id="L157"></span>
<span class="line" id="L158">                <span class="tok-kw">for</span> (self.items[after_range..]) |item, i| {</span>
<span class="line" id="L159">                    self.items[after_subrange..][i] = item;</span>
<span class="line" id="L160">                }</span>
<span class="line" id="L161"></span>
<span class="line" id="L162">                self.items.len -= len - new_items.len;</span>
<span class="line" id="L163">            }</span>
<span class="line" id="L164">        }</span>
<span class="line" id="L165"></span>
<span class="line" id="L166">        <span class="tok-comment">/// Extend the list by 1 element. Allocates more memory as necessary.</span></span>
<span class="line" id="L167">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">append</span>(self: *Self, item: T) Allocator.Error!<span class="tok-type">void</span> {</span>
<span class="line" id="L168">            <span class="tok-kw">const</span> new_item_ptr = <span class="tok-kw">try</span> self.addOne();</span>
<span class="line" id="L169">            new_item_ptr.* = item;</span>
<span class="line" id="L170">        }</span>
<span class="line" id="L171"></span>
<span class="line" id="L172">        <span class="tok-comment">/// Extend the list by 1 element, but assert `self.capacity`</span></span>
<span class="line" id="L173">        <span class="tok-comment">/// is sufficient to hold an additional item. **Does not**</span></span>
<span class="line" id="L174">        <span class="tok-comment">/// invalidate pointers.</span></span>
<span class="line" id="L175">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">appendAssumeCapacity</span>(self: *Self, item: T) <span class="tok-type">void</span> {</span>
<span class="line" id="L176">            <span class="tok-kw">const</span> new_item_ptr = self.addOneAssumeCapacity();</span>
<span class="line" id="L177">            new_item_ptr.* = item;</span>
<span class="line" id="L178">        }</span>
<span class="line" id="L179"></span>
<span class="line" id="L180">        <span class="tok-comment">/// Remove the element at index `i`, shift elements after index</span></span>
<span class="line" id="L181">        <span class="tok-comment">/// `i` forward, and return the removed element.</span></span>
<span class="line" id="L182">        <span class="tok-comment">/// Asserts the array has at least one item.</span></span>
<span class="line" id="L183">        <span class="tok-comment">/// Invalidates pointers to end of list.</span></span>
<span class="line" id="L184">        <span class="tok-comment">/// This operation is O(N).</span></span>
<span class="line" id="L185">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">orderedRemove</span>(self: *Self, i: <span class="tok-type">usize</span>) T {</span>
<span class="line" id="L186">            <span class="tok-kw">const</span> newlen = self.items.len - <span class="tok-number">1</span>;</span>
<span class="line" id="L187">            <span class="tok-kw">if</span> (newlen == i) <span class="tok-kw">return</span> self.pop();</span>
<span class="line" id="L188"></span>
<span class="line" id="L189">            <span class="tok-kw">const</span> old_item = self.items[i];</span>
<span class="line" id="L190">            <span class="tok-kw">for</span> (self.items[i..newlen]) |*b, j| b.* = self.items[i + <span class="tok-number">1</span> + j];</span>
<span class="line" id="L191">            self.items[newlen] = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L192">            self.items.len = newlen;</span>
<span class="line" id="L193">            <span class="tok-kw">return</span> old_item;</span>
<span class="line" id="L194">        }</span>
<span class="line" id="L195"></span>
<span class="line" id="L196">        <span class="tok-comment">/// Removes the element at the specified index and returns it.</span></span>
<span class="line" id="L197">        <span class="tok-comment">/// The empty slot is filled from the end of the list.</span></span>
<span class="line" id="L198">        <span class="tok-comment">/// This operation is O(1).</span></span>
<span class="line" id="L199">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">swapRemove</span>(self: *Self, i: <span class="tok-type">usize</span>) T {</span>
<span class="line" id="L200">            <span class="tok-kw">if</span> (self.items.len - <span class="tok-number">1</span> == i) <span class="tok-kw">return</span> self.pop();</span>
<span class="line" id="L201"></span>
<span class="line" id="L202">            <span class="tok-kw">const</span> old_item = self.items[i];</span>
<span class="line" id="L203">            self.items[i] = self.pop();</span>
<span class="line" id="L204">            <span class="tok-kw">return</span> old_item;</span>
<span class="line" id="L205">        }</span>
<span class="line" id="L206"></span>
<span class="line" id="L207">        <span class="tok-comment">/// Append the slice of items to the list. Allocates more</span></span>
<span class="line" id="L208">        <span class="tok-comment">/// memory as necessary.</span></span>
<span class="line" id="L209">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">appendSlice</span>(self: *Self, items: []<span class="tok-kw">const</span> T) Allocator.Error!<span class="tok-type">void</span> {</span>
<span class="line" id="L210">            <span class="tok-kw">try</span> self.ensureUnusedCapacity(items.len);</span>
<span class="line" id="L211">            self.appendSliceAssumeCapacity(items);</span>
<span class="line" id="L212">        }</span>
<span class="line" id="L213"></span>
<span class="line" id="L214">        <span class="tok-comment">/// Append the slice of items to the list, asserting the capacity is already</span></span>
<span class="line" id="L215">        <span class="tok-comment">/// enough to store the new items. **Does not** invalidate pointers.</span></span>
<span class="line" id="L216">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">appendSliceAssumeCapacity</span>(self: *Self, items: []<span class="tok-kw">const</span> T) <span class="tok-type">void</span> {</span>
<span class="line" id="L217">            <span class="tok-kw">const</span> old_len = self.items.len;</span>
<span class="line" id="L218">            <span class="tok-kw">const</span> new_len = old_len + items.len;</span>
<span class="line" id="L219">            assert(new_len &lt;= self.capacity);</span>
<span class="line" id="L220">            self.items.len = new_len;</span>
<span class="line" id="L221">            mem.copy(T, self.items[old_len..], items);</span>
<span class="line" id="L222">        }</span>
<span class="line" id="L223"></span>
<span class="line" id="L224">        <span class="tok-comment">/// Append an unaligned slice of items to the list. Allocates more</span></span>
<span class="line" id="L225">        <span class="tok-comment">/// memory as necessary. Only call this function if calling</span></span>
<span class="line" id="L226">        <span class="tok-comment">/// `appendSlice` instead would be a compile error.</span></span>
<span class="line" id="L227">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">appendUnalignedSlice</span>(self: *Self, items: []<span class="tok-kw">align</span>(<span class="tok-number">1</span>) <span class="tok-kw">const</span> T) Allocator.Error!<span class="tok-type">void</span> {</span>
<span class="line" id="L228">            <span class="tok-kw">try</span> self.ensureUnusedCapacity(items.len);</span>
<span class="line" id="L229">            self.appendUnalignedSliceAssumeCapacity(items);</span>
<span class="line" id="L230">        }</span>
<span class="line" id="L231"></span>
<span class="line" id="L232">        <span class="tok-comment">/// Append the slice of items to the list, asserting the capacity is already</span></span>
<span class="line" id="L233">        <span class="tok-comment">/// enough to store the new items. **Does not** invalidate pointers.</span></span>
<span class="line" id="L234">        <span class="tok-comment">/// Only call this function if calling `appendSliceAssumeCapacity` instead</span></span>
<span class="line" id="L235">        <span class="tok-comment">/// would be a compile error.</span></span>
<span class="line" id="L236">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">appendUnalignedSliceAssumeCapacity</span>(self: *Self, items: []<span class="tok-kw">align</span>(<span class="tok-number">1</span>) <span class="tok-kw">const</span> T) <span class="tok-type">void</span> {</span>
<span class="line" id="L237">            <span class="tok-kw">const</span> old_len = self.items.len;</span>
<span class="line" id="L238">            <span class="tok-kw">const</span> new_len = old_len + items.len;</span>
<span class="line" id="L239">            assert(new_len &lt;= self.capacity);</span>
<span class="line" id="L240">            self.items.len = new_len;</span>
<span class="line" id="L241">            <span class="tok-builtin">@memcpy</span>(</span>
<span class="line" id="L242">                <span class="tok-builtin">@ptrCast</span>([*]<span class="tok-kw">align</span>(<span class="tok-builtin">@alignOf</span>(T)) <span class="tok-type">u8</span>, self.items.ptr + old_len),</span>
<span class="line" id="L243">                <span class="tok-builtin">@ptrCast</span>([*]<span class="tok-kw">const</span> <span class="tok-type">u8</span>, items.ptr),</span>
<span class="line" id="L244">                items.len * <span class="tok-builtin">@sizeOf</span>(T),</span>
<span class="line" id="L245">            );</span>
<span class="line" id="L246">        }</span>
<span class="line" id="L247"></span>
<span class="line" id="L248">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> Writer = <span class="tok-kw">if</span> (T != <span class="tok-type">u8</span>)</span>
<span class="line" id="L249">            <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;The Writer interface is only defined for ArrayList(u8) &quot;</span> ++</span>
<span class="line" id="L250">                <span class="tok-str">&quot;but the given type is ArrayList(&quot;</span> ++ <span class="tok-builtin">@typeName</span>(T) ++ <span class="tok-str">&quot;)&quot;</span>)</span>
<span class="line" id="L251">        <span class="tok-kw">else</span></span>
<span class="line" id="L252">            std.io.Writer(*Self, <span class="tok-kw">error</span>{OutOfMemory}, appendWrite);</span>
<span class="line" id="L253"></span>
<span class="line" id="L254">        <span class="tok-comment">/// Initializes a Writer which will append to the list.</span></span>
<span class="line" id="L255">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">writer</span>(self: *Self) Writer {</span>
<span class="line" id="L256">            <span class="tok-kw">return</span> .{ .context = self };</span>
<span class="line" id="L257">        }</span>
<span class="line" id="L258"></span>
<span class="line" id="L259">        <span class="tok-comment">/// Same as `append` except it returns the number of bytes written, which is always the same</span></span>
<span class="line" id="L260">        <span class="tok-comment">/// as `m.len`. The purpose of this function existing is to match `std.io.Writer` API.</span></span>
<span class="line" id="L261">        <span class="tok-kw">fn</span> <span class="tok-fn">appendWrite</span>(self: *Self, m: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) Allocator.Error!<span class="tok-type">usize</span> {</span>
<span class="line" id="L262">            <span class="tok-kw">try</span> self.appendSlice(m);</span>
<span class="line" id="L263">            <span class="tok-kw">return</span> m.len;</span>
<span class="line" id="L264">        }</span>
<span class="line" id="L265"></span>
<span class="line" id="L266">        <span class="tok-comment">/// Append a value to the list `n` times.</span></span>
<span class="line" id="L267">        <span class="tok-comment">/// Allocates more memory as necessary.</span></span>
<span class="line" id="L268">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">appendNTimes</span>(self: *Self, value: T, n: <span class="tok-type">usize</span>) Allocator.Error!<span class="tok-type">void</span> {</span>
<span class="line" id="L269">            <span class="tok-kw">const</span> old_len = self.items.len;</span>
<span class="line" id="L270">            <span class="tok-kw">try</span> self.resize(self.items.len + n);</span>
<span class="line" id="L271">            mem.set(T, self.items[old_len..self.items.len], value);</span>
<span class="line" id="L272">        }</span>
<span class="line" id="L273"></span>
<span class="line" id="L274">        <span class="tok-comment">/// Append a value to the list `n` times.</span></span>
<span class="line" id="L275">        <span class="tok-comment">/// Asserts the capacity is enough. **Does not** invalidate pointers.</span></span>
<span class="line" id="L276">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">appendNTimesAssumeCapacity</span>(self: *Self, value: T, n: <span class="tok-type">usize</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L277">            <span class="tok-kw">const</span> new_len = self.items.len + n;</span>
<span class="line" id="L278">            assert(new_len &lt;= self.capacity);</span>
<span class="line" id="L279">            mem.set(T, self.items.ptr[self.items.len..new_len], value);</span>
<span class="line" id="L280">            self.items.len = new_len;</span>
<span class="line" id="L281">        }</span>
<span class="line" id="L282"></span>
<span class="line" id="L283">        <span class="tok-comment">/// Adjust the list's length to `new_len`.</span></span>
<span class="line" id="L284">        <span class="tok-comment">/// Does not initialize added items if any.</span></span>
<span class="line" id="L285">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">resize</span>(self: *Self, new_len: <span class="tok-type">usize</span>) Allocator.Error!<span class="tok-type">void</span> {</span>
<span class="line" id="L286">            <span class="tok-kw">try</span> self.ensureTotalCapacity(new_len);</span>
<span class="line" id="L287">            self.items.len = new_len;</span>
<span class="line" id="L288">        }</span>
<span class="line" id="L289"></span>
<span class="line" id="L290">        <span class="tok-comment">/// Reduce allocated capacity to `new_len`.</span></span>
<span class="line" id="L291">        <span class="tok-comment">/// May invalidate element pointers.</span></span>
<span class="line" id="L292">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">shrinkAndFree</span>(self: *Self, new_len: <span class="tok-type">usize</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L293">            assert(new_len &lt;= self.items.len);</span>
<span class="line" id="L294"></span>
<span class="line" id="L295">            <span class="tok-kw">if</span> (<span class="tok-builtin">@sizeOf</span>(T) &gt; <span class="tok-number">0</span>) {</span>
<span class="line" id="L296">                self.items = self.allocator.realloc(self.allocatedSlice(), new_len) <span class="tok-kw">catch</span> |e| <span class="tok-kw">switch</span> (e) {</span>
<span class="line" id="L297">                    <span class="tok-kw">error</span>.OutOfMemory =&gt; { <span class="tok-comment">// no problem, capacity is still correct then.</span>
</span>
<span class="line" id="L298">                        self.items.len = new_len;</span>
<span class="line" id="L299">                        <span class="tok-kw">return</span>;</span>
<span class="line" id="L300">                    },</span>
<span class="line" id="L301">                };</span>
<span class="line" id="L302">                self.capacity = new_len;</span>
<span class="line" id="L303">            } <span class="tok-kw">else</span> {</span>
<span class="line" id="L304">                self.items.len = new_len;</span>
<span class="line" id="L305">            }</span>
<span class="line" id="L306">        }</span>
<span class="line" id="L307"></span>
<span class="line" id="L308">        <span class="tok-comment">/// Reduce length to `new_len`.</span></span>
<span class="line" id="L309">        <span class="tok-comment">/// Invalidates pointers for the elements `items[new_len..]`.</span></span>
<span class="line" id="L310">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">shrinkRetainingCapacity</span>(self: *Self, new_len: <span class="tok-type">usize</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L311">            assert(new_len &lt;= self.items.len);</span>
<span class="line" id="L312">            self.items.len = new_len;</span>
<span class="line" id="L313">        }</span>
<span class="line" id="L314"></span>
<span class="line" id="L315">        <span class="tok-comment">/// Invalidates all element pointers.</span></span>
<span class="line" id="L316">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">clearRetainingCapacity</span>(self: *Self) <span class="tok-type">void</span> {</span>
<span class="line" id="L317">            self.items.len = <span class="tok-number">0</span>;</span>
<span class="line" id="L318">        }</span>
<span class="line" id="L319"></span>
<span class="line" id="L320">        <span class="tok-comment">/// Invalidates all element pointers.</span></span>
<span class="line" id="L321">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">clearAndFree</span>(self: *Self) <span class="tok-type">void</span> {</span>
<span class="line" id="L322">            self.allocator.free(self.allocatedSlice());</span>
<span class="line" id="L323">            self.items.len = <span class="tok-number">0</span>;</span>
<span class="line" id="L324">            self.capacity = <span class="tok-number">0</span>;</span>
<span class="line" id="L325">        }</span>
<span class="line" id="L326"></span>
<span class="line" id="L327">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> ensureCapacity = <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;deprecated; call `ensureUnusedCapacity` or `ensureTotalCapacity`&quot;</span>);</span>
<span class="line" id="L328"></span>
<span class="line" id="L329">        <span class="tok-comment">/// Modify the array so that it can hold at least `new_capacity` items.</span></span>
<span class="line" id="L330">        <span class="tok-comment">/// Invalidates pointers if additional memory is needed.</span></span>
<span class="line" id="L331">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">ensureTotalCapacity</span>(self: *Self, new_capacity: <span class="tok-type">usize</span>) Allocator.Error!<span class="tok-type">void</span> {</span>
<span class="line" id="L332">            <span class="tok-kw">if</span> (<span class="tok-builtin">@sizeOf</span>(T) &gt; <span class="tok-number">0</span>) {</span>
<span class="line" id="L333">                <span class="tok-kw">var</span> better_capacity = self.capacity;</span>
<span class="line" id="L334">                <span class="tok-kw">if</span> (better_capacity &gt;= new_capacity) <span class="tok-kw">return</span>;</span>
<span class="line" id="L335"></span>
<span class="line" id="L336">                <span class="tok-kw">while</span> (<span class="tok-null">true</span>) {</span>
<span class="line" id="L337">                    better_capacity += better_capacity / <span class="tok-number">2</span> + <span class="tok-number">8</span>;</span>
<span class="line" id="L338">                    <span class="tok-kw">if</span> (better_capacity &gt;= new_capacity) <span class="tok-kw">break</span>;</span>
<span class="line" id="L339">                }</span>
<span class="line" id="L340"></span>
<span class="line" id="L341">                <span class="tok-kw">return</span> self.ensureTotalCapacityPrecise(better_capacity);</span>
<span class="line" id="L342">            } <span class="tok-kw">else</span> {</span>
<span class="line" id="L343">                self.capacity = std.math.maxInt(<span class="tok-type">usize</span>);</span>
<span class="line" id="L344">            }</span>
<span class="line" id="L345">        }</span>
<span class="line" id="L346"></span>
<span class="line" id="L347">        <span class="tok-comment">/// Modify the array so that it can hold at least `new_capacity` items.</span></span>
<span class="line" id="L348">        <span class="tok-comment">/// Like `ensureTotalCapacity`, but the resulting capacity is much more likely</span></span>
<span class="line" id="L349">        <span class="tok-comment">/// (but not guaranteed) to be equal to `new_capacity`.</span></span>
<span class="line" id="L350">        <span class="tok-comment">/// Invalidates pointers if additional memory is needed.</span></span>
<span class="line" id="L351">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">ensureTotalCapacityPrecise</span>(self: *Self, new_capacity: <span class="tok-type">usize</span>) Allocator.Error!<span class="tok-type">void</span> {</span>
<span class="line" id="L352">            <span class="tok-kw">if</span> (<span class="tok-builtin">@sizeOf</span>(T) &gt; <span class="tok-number">0</span>) {</span>
<span class="line" id="L353">                <span class="tok-kw">if</span> (self.capacity &gt;= new_capacity) <span class="tok-kw">return</span>;</span>
<span class="line" id="L354"></span>
<span class="line" id="L355">                <span class="tok-comment">// TODO This can be optimized to avoid needlessly copying undefined memory.</span>
</span>
<span class="line" id="L356">                <span class="tok-kw">const</span> new_memory = <span class="tok-kw">try</span> self.allocator.reallocAtLeast(self.allocatedSlice(), new_capacity);</span>
<span class="line" id="L357">                self.items.ptr = new_memory.ptr;</span>
<span class="line" id="L358">                self.capacity = new_memory.len;</span>
<span class="line" id="L359">            } <span class="tok-kw">else</span> {</span>
<span class="line" id="L360">                self.capacity = std.math.maxInt(<span class="tok-type">usize</span>);</span>
<span class="line" id="L361">            }</span>
<span class="line" id="L362">        }</span>
<span class="line" id="L363"></span>
<span class="line" id="L364">        <span class="tok-comment">/// Modify the array so that it can hold at least `additional_count` **more** items.</span></span>
<span class="line" id="L365">        <span class="tok-comment">/// Invalidates pointers if additional memory is needed.</span></span>
<span class="line" id="L366">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">ensureUnusedCapacity</span>(self: *Self, additional_count: <span class="tok-type">usize</span>) Allocator.Error!<span class="tok-type">void</span> {</span>
<span class="line" id="L367">            <span class="tok-kw">return</span> self.ensureTotalCapacity(self.items.len + additional_count);</span>
<span class="line" id="L368">        }</span>
<span class="line" id="L369"></span>
<span class="line" id="L370">        <span class="tok-comment">/// Increases the array's length to match the full capacity that is already allocated.</span></span>
<span class="line" id="L371">        <span class="tok-comment">/// The new elements have `undefined` values. **Does not** invalidate pointers.</span></span>
<span class="line" id="L372">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">expandToCapacity</span>(self: *Self) <span class="tok-type">void</span> {</span>
<span class="line" id="L373">            self.items.len = self.capacity;</span>
<span class="line" id="L374">        }</span>
<span class="line" id="L375"></span>
<span class="line" id="L376">        <span class="tok-comment">/// Increase length by 1, returning pointer to the new item.</span></span>
<span class="line" id="L377">        <span class="tok-comment">/// The returned pointer becomes invalid when the list resized.</span></span>
<span class="line" id="L378">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">addOne</span>(self: *Self) Allocator.Error!*T {</span>
<span class="line" id="L379">            <span class="tok-kw">const</span> newlen = self.items.len + <span class="tok-number">1</span>;</span>
<span class="line" id="L380">            <span class="tok-kw">try</span> self.ensureTotalCapacity(newlen);</span>
<span class="line" id="L381">            <span class="tok-kw">return</span> self.addOneAssumeCapacity();</span>
<span class="line" id="L382">        }</span>
<span class="line" id="L383"></span>
<span class="line" id="L384">        <span class="tok-comment">/// Increase length by 1, returning pointer to the new item.</span></span>
<span class="line" id="L385">        <span class="tok-comment">/// Asserts that there is already space for the new item without allocating more.</span></span>
<span class="line" id="L386">        <span class="tok-comment">/// The returned pointer becomes invalid when the list is resized.</span></span>
<span class="line" id="L387">        <span class="tok-comment">/// **Does not** invalidate element pointers.</span></span>
<span class="line" id="L388">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">addOneAssumeCapacity</span>(self: *Self) *T {</span>
<span class="line" id="L389">            assert(self.items.len &lt; self.capacity);</span>
<span class="line" id="L390"></span>
<span class="line" id="L391">            self.items.len += <span class="tok-number">1</span>;</span>
<span class="line" id="L392">            <span class="tok-kw">return</span> &amp;self.items[self.items.len - <span class="tok-number">1</span>];</span>
<span class="line" id="L393">        }</span>
<span class="line" id="L394"></span>
<span class="line" id="L395">        <span class="tok-comment">/// Resize the array, adding `n` new elements, which have `undefined` values.</span></span>
<span class="line" id="L396">        <span class="tok-comment">/// The return value is an array pointing to the newly allocated elements.</span></span>
<span class="line" id="L397">        <span class="tok-comment">/// The returned pointer becomes invalid when the list is resized.</span></span>
<span class="line" id="L398">        <span class="tok-comment">/// Resizes list if `self.capacity` is not large enough.</span></span>
<span class="line" id="L399">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">addManyAsArray</span>(self: *Self, <span class="tok-kw">comptime</span> n: <span class="tok-type">usize</span>) Allocator.Error!*[n]T {</span>
<span class="line" id="L400">            <span class="tok-kw">const</span> prev_len = self.items.len;</span>
<span class="line" id="L401">            <span class="tok-kw">try</span> self.resize(self.items.len + n);</span>
<span class="line" id="L402">            <span class="tok-kw">return</span> self.items[prev_len..][<span class="tok-number">0</span>..n];</span>
<span class="line" id="L403">        }</span>
<span class="line" id="L404"></span>
<span class="line" id="L405">        <span class="tok-comment">/// Resize the array, adding `n` new elements, which have `undefined` values.</span></span>
<span class="line" id="L406">        <span class="tok-comment">/// The return value is an array pointing to the newly allocated elements.</span></span>
<span class="line" id="L407">        <span class="tok-comment">/// Asserts that there is already space for the new item without allocating more.</span></span>
<span class="line" id="L408">        <span class="tok-comment">/// **Does not** invalidate element pointers.</span></span>
<span class="line" id="L409">        <span class="tok-comment">/// The returned pointer becomes invalid when the list is resized.</span></span>
<span class="line" id="L410">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">addManyAsArrayAssumeCapacity</span>(self: *Self, <span class="tok-kw">comptime</span> n: <span class="tok-type">usize</span>) *[n]T {</span>
<span class="line" id="L411">            assert(self.items.len + n &lt;= self.capacity);</span>
<span class="line" id="L412">            <span class="tok-kw">const</span> prev_len = self.items.len;</span>
<span class="line" id="L413">            self.items.len += n;</span>
<span class="line" id="L414">            <span class="tok-kw">return</span> self.items[prev_len..][<span class="tok-number">0</span>..n];</span>
<span class="line" id="L415">        }</span>
<span class="line" id="L416"></span>
<span class="line" id="L417">        <span class="tok-comment">/// Remove and return the last element from the list.</span></span>
<span class="line" id="L418">        <span class="tok-comment">/// Asserts the list has at least one item.</span></span>
<span class="line" id="L419">        <span class="tok-comment">/// Invalidates pointers to the removed element.</span></span>
<span class="line" id="L420">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">pop</span>(self: *Self) T {</span>
<span class="line" id="L421">            <span class="tok-kw">const</span> val = self.items[self.items.len - <span class="tok-number">1</span>];</span>
<span class="line" id="L422">            self.items.len -= <span class="tok-number">1</span>;</span>
<span class="line" id="L423">            <span class="tok-kw">return</span> val;</span>
<span class="line" id="L424">        }</span>
<span class="line" id="L425"></span>
<span class="line" id="L426">        <span class="tok-comment">/// Remove and return the last element from the list, or</span></span>
<span class="line" id="L427">        <span class="tok-comment">/// return `null` if list is empty.</span></span>
<span class="line" id="L428">        <span class="tok-comment">/// Invalidates pointers to the removed element, if any.</span></span>
<span class="line" id="L429">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">popOrNull</span>(self: *Self) ?T {</span>
<span class="line" id="L430">            <span class="tok-kw">if</span> (self.items.len == <span class="tok-number">0</span>) <span class="tok-kw">return</span> <span class="tok-null">null</span>;</span>
<span class="line" id="L431">            <span class="tok-kw">return</span> self.pop();</span>
<span class="line" id="L432">        }</span>
<span class="line" id="L433"></span>
<span class="line" id="L434">        <span class="tok-comment">/// Returns a slice of all the items plus the extra capacity, whose memory</span></span>
<span class="line" id="L435">        <span class="tok-comment">/// contents are `undefined`.</span></span>
<span class="line" id="L436">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">allocatedSlice</span>(self: Self) Slice {</span>
<span class="line" id="L437">            <span class="tok-comment">// For a nicer API, `items.len` is the length, not the capacity.</span>
</span>
<span class="line" id="L438">            <span class="tok-comment">// This requires &quot;unsafe&quot; slicing.</span>
</span>
<span class="line" id="L439">            <span class="tok-kw">return</span> self.items.ptr[<span class="tok-number">0</span>..self.capacity];</span>
<span class="line" id="L440">        }</span>
<span class="line" id="L441"></span>
<span class="line" id="L442">        <span class="tok-comment">/// Returns a slice of only the extra capacity after items.</span></span>
<span class="line" id="L443">        <span class="tok-comment">/// This can be useful for writing directly into an ArrayList.</span></span>
<span class="line" id="L444">        <span class="tok-comment">/// Note that such an operation must be followed up with a direct</span></span>
<span class="line" id="L445">        <span class="tok-comment">/// modification of `self.items.len`.</span></span>
<span class="line" id="L446">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">unusedCapacitySlice</span>(self: Self) Slice {</span>
<span class="line" id="L447">            <span class="tok-kw">return</span> self.allocatedSlice()[self.items.len..];</span>
<span class="line" id="L448">        }</span>
<span class="line" id="L449">    };</span>
<span class="line" id="L450">}</span>
<span class="line" id="L451"></span>
<span class="line" id="L452"><span class="tok-comment">/// An ArrayList, but the allocator is passed as a parameter to the relevant functions</span></span>
<span class="line" id="L453"><span class="tok-comment">/// rather than stored in the struct itself. The same allocator **must** be used throughout</span></span>
<span class="line" id="L454"><span class="tok-comment">/// the entire lifetime of an ArrayListUnmanaged. Initialize directly or with</span></span>
<span class="line" id="L455"><span class="tok-comment">/// `initCapacity`, and deinitialize with `deinit` or use `toOwnedSlice`.</span></span>
<span class="line" id="L456"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">ArrayListUnmanaged</span>(<span class="tok-kw">comptime</span> T: <span class="tok-type">type</span>) <span class="tok-type">type</span> {</span>
<span class="line" id="L457">    <span class="tok-kw">return</span> ArrayListAlignedUnmanaged(T, <span class="tok-null">null</span>);</span>
<span class="line" id="L458">}</span>
<span class="line" id="L459"></span>
<span class="line" id="L460"><span class="tok-comment">/// An ArrayListAligned, but the allocator is passed as a parameter to the relevant</span></span>
<span class="line" id="L461"><span class="tok-comment">/// functions rather than stored  in the struct itself. The same allocator **must**</span></span>
<span class="line" id="L462"><span class="tok-comment">/// be used throughout the entire lifetime of an ArrayListAlignedUnmanaged.</span></span>
<span class="line" id="L463"><span class="tok-comment">/// Initialize directly or with `initCapacity`, and deinitialize with `deinit` or use `toOwnedSlice`.</span></span>
<span class="line" id="L464"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">ArrayListAlignedUnmanaged</span>(<span class="tok-kw">comptime</span> T: <span class="tok-type">type</span>, <span class="tok-kw">comptime</span> alignment: ?<span class="tok-type">u29</span>) <span class="tok-type">type</span> {</span>
<span class="line" id="L465">    <span class="tok-kw">if</span> (alignment) |a| {</span>
<span class="line" id="L466">        <span class="tok-kw">if</span> (a == <span class="tok-builtin">@alignOf</span>(T)) {</span>
<span class="line" id="L467">            <span class="tok-kw">return</span> ArrayListAlignedUnmanaged(T, <span class="tok-null">null</span>);</span>
<span class="line" id="L468">        }</span>
<span class="line" id="L469">    }</span>
<span class="line" id="L470">    <span class="tok-kw">return</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L471">        <span class="tok-kw">const</span> Self = <span class="tok-builtin">@This</span>();</span>
<span class="line" id="L472">        <span class="tok-comment">/// Contents of the list. Pointers to elements in this slice are</span></span>
<span class="line" id="L473">        <span class="tok-comment">/// **invalid after resizing operations** on the ArrayList, unless the</span></span>
<span class="line" id="L474">        <span class="tok-comment">/// operation explicitly either: (1) states otherwise or (2) lists the</span></span>
<span class="line" id="L475">        <span class="tok-comment">/// invalidated pointers.</span></span>
<span class="line" id="L476">        <span class="tok-comment">///</span></span>
<span class="line" id="L477">        <span class="tok-comment">/// The allocator used determines how element pointers are</span></span>
<span class="line" id="L478">        <span class="tok-comment">/// invalidated, so the behavior may vary between lists. To avoid</span></span>
<span class="line" id="L479">        <span class="tok-comment">/// illegal behavior, take into account the above paragraph plus the</span></span>
<span class="line" id="L480">        <span class="tok-comment">/// explicit statements given in each method.</span></span>
<span class="line" id="L481">        items: Slice = &amp;[_]T{},</span>
<span class="line" id="L482">        <span class="tok-comment">/// How many T values this list can hold without allocating</span></span>
<span class="line" id="L483">        <span class="tok-comment">/// additional memory.</span></span>
<span class="line" id="L484">        capacity: <span class="tok-type">usize</span> = <span class="tok-number">0</span>,</span>
<span class="line" id="L485"></span>
<span class="line" id="L486">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> Slice = <span class="tok-kw">if</span> (alignment) |a| ([]<span class="tok-kw">align</span>(a) T) <span class="tok-kw">else</span> []T;</span>
<span class="line" id="L487"></span>
<span class="line" id="L488">        <span class="tok-comment">/// Initialize with capacity to hold at least num elements.</span></span>
<span class="line" id="L489">        <span class="tok-comment">/// The resulting capacity is likely to be equal to `num`.</span></span>
<span class="line" id="L490">        <span class="tok-comment">/// Deinitialize with `deinit` or use `toOwnedSlice`.</span></span>
<span class="line" id="L491">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">initCapacity</span>(allocator: Allocator, num: <span class="tok-type">usize</span>) Allocator.Error!Self {</span>
<span class="line" id="L492">            <span class="tok-kw">var</span> self = Self{};</span>
<span class="line" id="L493">            <span class="tok-kw">try</span> self.ensureTotalCapacityPrecise(allocator, num);</span>
<span class="line" id="L494">            <span class="tok-kw">return</span> self;</span>
<span class="line" id="L495">        }</span>
<span class="line" id="L496"></span>
<span class="line" id="L497">        <span class="tok-comment">/// Release all allocated memory.</span></span>
<span class="line" id="L498">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">deinit</span>(self: *Self, allocator: Allocator) <span class="tok-type">void</span> {</span>
<span class="line" id="L499">            allocator.free(self.allocatedSlice());</span>
<span class="line" id="L500">            self.* = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L501">        }</span>
<span class="line" id="L502"></span>
<span class="line" id="L503">        <span class="tok-comment">/// Convert this list into an analogous memory-managed one.</span></span>
<span class="line" id="L504">        <span class="tok-comment">/// The returned list has ownership of the underlying memory.</span></span>
<span class="line" id="L505">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">toManaged</span>(self: *Self, allocator: Allocator) ArrayListAligned(T, alignment) {</span>
<span class="line" id="L506">            <span class="tok-kw">return</span> .{ .items = self.items, .capacity = self.capacity, .allocator = allocator };</span>
<span class="line" id="L507">        }</span>
<span class="line" id="L508"></span>
<span class="line" id="L509">        <span class="tok-comment">/// The caller owns the returned memory. ArrayList becomes empty.</span></span>
<span class="line" id="L510">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">toOwnedSlice</span>(self: *Self, allocator: Allocator) Slice {</span>
<span class="line" id="L511">            <span class="tok-kw">const</span> result = allocator.shrink(self.allocatedSlice(), self.items.len);</span>
<span class="line" id="L512">            self.* = Self{};</span>
<span class="line" id="L513">            <span class="tok-kw">return</span> result;</span>
<span class="line" id="L514">        }</span>
<span class="line" id="L515"></span>
<span class="line" id="L516">        <span class="tok-comment">/// The caller owns the returned memory. ArrayList becomes empty.</span></span>
<span class="line" id="L517">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">toOwnedSliceSentinel</span>(self: *Self, allocator: Allocator, <span class="tok-kw">comptime</span> sentinel: T) Allocator.Error![:sentinel]T {</span>
<span class="line" id="L518">            <span class="tok-kw">try</span> self.append(allocator, sentinel);</span>
<span class="line" id="L519">            <span class="tok-kw">const</span> result = self.toOwnedSlice(allocator);</span>
<span class="line" id="L520">            <span class="tok-kw">return</span> result[<span class="tok-number">0</span> .. result.len - <span class="tok-number">1</span> :sentinel];</span>
<span class="line" id="L521">        }</span>
<span class="line" id="L522"></span>
<span class="line" id="L523">        <span class="tok-comment">/// Creates a copy of this ArrayList.</span></span>
<span class="line" id="L524">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">clone</span>(self: *Self, allocator: Allocator) Allocator.Error!Self {</span>
<span class="line" id="L525">            <span class="tok-kw">var</span> cloned = <span class="tok-kw">try</span> Self.initCapacity(allocator, self.capacity);</span>
<span class="line" id="L526">            cloned.appendSliceAssumeCapacity(self.items);</span>
<span class="line" id="L527">            <span class="tok-kw">return</span> cloned;</span>
<span class="line" id="L528">        }</span>
<span class="line" id="L529"></span>
<span class="line" id="L530">        <span class="tok-comment">/// Insert `item` at index `n`. Moves `list[n .. list.len]`</span></span>
<span class="line" id="L531">        <span class="tok-comment">/// to higher indices to make room.</span></span>
<span class="line" id="L532">        <span class="tok-comment">/// This operation is O(N).</span></span>
<span class="line" id="L533">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">insert</span>(self: *Self, allocator: Allocator, n: <span class="tok-type">usize</span>, item: T) Allocator.Error!<span class="tok-type">void</span> {</span>
<span class="line" id="L534">            <span class="tok-kw">try</span> self.ensureUnusedCapacity(allocator, <span class="tok-number">1</span>);</span>
<span class="line" id="L535">            self.items.len += <span class="tok-number">1</span>;</span>
<span class="line" id="L536"></span>
<span class="line" id="L537">            mem.copyBackwards(T, self.items[n + <span class="tok-number">1</span> .. self.items.len], self.items[n .. self.items.len - <span class="tok-number">1</span>]);</span>
<span class="line" id="L538">            self.items[n] = item;</span>
<span class="line" id="L539">        }</span>
<span class="line" id="L540"></span>
<span class="line" id="L541">        <span class="tok-comment">/// Insert slice `items` at index `i`. Moves `list[i .. list.len]` to</span></span>
<span class="line" id="L542">        <span class="tok-comment">/// higher indicices make room.</span></span>
<span class="line" id="L543">        <span class="tok-comment">/// This operation is O(N).</span></span>
<span class="line" id="L544">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">insertSlice</span>(self: *Self, allocator: Allocator, i: <span class="tok-type">usize</span>, items: []<span class="tok-kw">const</span> T) Allocator.Error!<span class="tok-type">void</span> {</span>
<span class="line" id="L545">            <span class="tok-kw">try</span> self.ensureUnusedCapacity(allocator, items.len);</span>
<span class="line" id="L546">            self.items.len += items.len;</span>
<span class="line" id="L547"></span>
<span class="line" id="L548">            mem.copyBackwards(T, self.items[i + items.len .. self.items.len], self.items[i .. self.items.len - items.len]);</span>
<span class="line" id="L549">            mem.copy(T, self.items[i .. i + items.len], items);</span>
<span class="line" id="L550">        }</span>
<span class="line" id="L551"></span>
<span class="line" id="L552">        <span class="tok-comment">/// Replace range of elements `list[start..start+len]` with `new_items`</span></span>
<span class="line" id="L553">        <span class="tok-comment">/// Grows list if `len &lt; new_items.len`.</span></span>
<span class="line" id="L554">        <span class="tok-comment">/// Shrinks list if `len &gt; new_items.len`</span></span>
<span class="line" id="L555">        <span class="tok-comment">/// Invalidates pointers if this ArrayList is resized.</span></span>
<span class="line" id="L556">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">replaceRange</span>(self: *Self, allocator: Allocator, start: <span class="tok-type">usize</span>, len: <span class="tok-type">usize</span>, new_items: []<span class="tok-kw">const</span> T) Allocator.Error!<span class="tok-type">void</span> {</span>
<span class="line" id="L557">            <span class="tok-kw">var</span> managed = self.toManaged(allocator);</span>
<span class="line" id="L558">            <span class="tok-kw">try</span> managed.replaceRange(start, len, new_items);</span>
<span class="line" id="L559">            self.* = managed.moveToUnmanaged();</span>
<span class="line" id="L560">        }</span>
<span class="line" id="L561"></span>
<span class="line" id="L562">        <span class="tok-comment">/// Extend the list by 1 element. Allocates more memory as necessary.</span></span>
<span class="line" id="L563">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">append</span>(self: *Self, allocator: Allocator, item: T) Allocator.Error!<span class="tok-type">void</span> {</span>
<span class="line" id="L564">            <span class="tok-kw">const</span> new_item_ptr = <span class="tok-kw">try</span> self.addOne(allocator);</span>
<span class="line" id="L565">            new_item_ptr.* = item;</span>
<span class="line" id="L566">        }</span>
<span class="line" id="L567"></span>
<span class="line" id="L568">        <span class="tok-comment">/// Extend the list by 1 element, but asserting `self.capacity`</span></span>
<span class="line" id="L569">        <span class="tok-comment">/// is sufficient to hold an additional item.</span></span>
<span class="line" id="L570">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">appendAssumeCapacity</span>(self: *Self, item: T) <span class="tok-type">void</span> {</span>
<span class="line" id="L571">            <span class="tok-kw">const</span> new_item_ptr = self.addOneAssumeCapacity();</span>
<span class="line" id="L572">            new_item_ptr.* = item;</span>
<span class="line" id="L573">        }</span>
<span class="line" id="L574"></span>
<span class="line" id="L575">        <span class="tok-comment">/// Remove the element at index `i` from the list and return its value.</span></span>
<span class="line" id="L576">        <span class="tok-comment">/// Asserts the array has at least one item. Invalidates pointers to</span></span>
<span class="line" id="L577">        <span class="tok-comment">/// last element.</span></span>
<span class="line" id="L578">        <span class="tok-comment">/// This operation is O(N).</span></span>
<span class="line" id="L579">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">orderedRemove</span>(self: *Self, i: <span class="tok-type">usize</span>) T {</span>
<span class="line" id="L580">            <span class="tok-kw">const</span> newlen = self.items.len - <span class="tok-number">1</span>;</span>
<span class="line" id="L581">            <span class="tok-kw">if</span> (newlen == i) <span class="tok-kw">return</span> self.pop();</span>
<span class="line" id="L582"></span>
<span class="line" id="L583">            <span class="tok-kw">const</span> old_item = self.items[i];</span>
<span class="line" id="L584">            <span class="tok-kw">for</span> (self.items[i..newlen]) |*b, j| b.* = self.items[i + <span class="tok-number">1</span> + j];</span>
<span class="line" id="L585">            self.items[newlen] = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L586">            self.items.len = newlen;</span>
<span class="line" id="L587">            <span class="tok-kw">return</span> old_item;</span>
<span class="line" id="L588">        }</span>
<span class="line" id="L589"></span>
<span class="line" id="L590">        <span class="tok-comment">/// Removes the element at the specified index and returns it.</span></span>
<span class="line" id="L591">        <span class="tok-comment">/// The empty slot is filled from the end of the list.</span></span>
<span class="line" id="L592">        <span class="tok-comment">/// Invalidates pointers to last element.</span></span>
<span class="line" id="L593">        <span class="tok-comment">/// This operation is O(1).</span></span>
<span class="line" id="L594">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">swapRemove</span>(self: *Self, i: <span class="tok-type">usize</span>) T {</span>
<span class="line" id="L595">            <span class="tok-kw">if</span> (self.items.len - <span class="tok-number">1</span> == i) <span class="tok-kw">return</span> self.pop();</span>
<span class="line" id="L596"></span>
<span class="line" id="L597">            <span class="tok-kw">const</span> old_item = self.items[i];</span>
<span class="line" id="L598">            self.items[i] = self.pop();</span>
<span class="line" id="L599">            <span class="tok-kw">return</span> old_item;</span>
<span class="line" id="L600">        }</span>
<span class="line" id="L601"></span>
<span class="line" id="L602">        <span class="tok-comment">/// Append the slice of items to the list. Allocates more</span></span>
<span class="line" id="L603">        <span class="tok-comment">/// memory as necessary.</span></span>
<span class="line" id="L604">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">appendSlice</span>(self: *Self, allocator: Allocator, items: []<span class="tok-kw">const</span> T) Allocator.Error!<span class="tok-type">void</span> {</span>
<span class="line" id="L605">            <span class="tok-kw">try</span> self.ensureUnusedCapacity(allocator, items.len);</span>
<span class="line" id="L606">            self.appendSliceAssumeCapacity(items);</span>
<span class="line" id="L607">        }</span>
<span class="line" id="L608"></span>
<span class="line" id="L609">        <span class="tok-comment">/// Append the slice of items to the list, asserting the capacity is enough</span></span>
<span class="line" id="L610">        <span class="tok-comment">/// to store the new items.</span></span>
<span class="line" id="L611">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">appendSliceAssumeCapacity</span>(self: *Self, items: []<span class="tok-kw">const</span> T) <span class="tok-type">void</span> {</span>
<span class="line" id="L612">            <span class="tok-kw">const</span> old_len = self.items.len;</span>
<span class="line" id="L613">            <span class="tok-kw">const</span> new_len = old_len + items.len;</span>
<span class="line" id="L614">            assert(new_len &lt;= self.capacity);</span>
<span class="line" id="L615">            self.items.len = new_len;</span>
<span class="line" id="L616">            mem.copy(T, self.items[old_len..], items);</span>
<span class="line" id="L617">        }</span>
<span class="line" id="L618"></span>
<span class="line" id="L619">        <span class="tok-comment">/// Append the slice of items to the list. Allocates more</span></span>
<span class="line" id="L620">        <span class="tok-comment">/// memory as necessary. Only call this function if a call to `appendSlice` instead would</span></span>
<span class="line" id="L621">        <span class="tok-comment">/// be a compile error.</span></span>
<span class="line" id="L622">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">appendUnalignedSlice</span>(self: *Self, allocator: Allocator, items: []<span class="tok-kw">align</span>(<span class="tok-number">1</span>) <span class="tok-kw">const</span> T) Allocator.Error!<span class="tok-type">void</span> {</span>
<span class="line" id="L623">            <span class="tok-kw">try</span> self.ensureUnusedCapacity(allocator, items.len);</span>
<span class="line" id="L624">            self.appendUnalignedSliceAssumeCapacity(items);</span>
<span class="line" id="L625">        }</span>
<span class="line" id="L626"></span>
<span class="line" id="L627">        <span class="tok-comment">/// Append an unaligned slice of items to the list, asserting the capacity is enough</span></span>
<span class="line" id="L628">        <span class="tok-comment">/// to store the new items. Only call this function if a call to `appendSliceAssumeCapacity`</span></span>
<span class="line" id="L629">        <span class="tok-comment">/// instead would be a compile error.</span></span>
<span class="line" id="L630">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">appendUnalignedSliceAssumeCapacity</span>(self: *Self, items: []<span class="tok-kw">align</span>(<span class="tok-number">1</span>) <span class="tok-kw">const</span> T) <span class="tok-type">void</span> {</span>
<span class="line" id="L631">            <span class="tok-kw">const</span> old_len = self.items.len;</span>
<span class="line" id="L632">            <span class="tok-kw">const</span> new_len = old_len + items.len;</span>
<span class="line" id="L633">            assert(new_len &lt;= self.capacity);</span>
<span class="line" id="L634">            self.items.len = new_len;</span>
<span class="line" id="L635">            <span class="tok-builtin">@memcpy</span>(</span>
<span class="line" id="L636">                <span class="tok-builtin">@ptrCast</span>([*]<span class="tok-kw">align</span>(<span class="tok-builtin">@alignOf</span>(T)) <span class="tok-type">u8</span>, self.items.ptr + old_len),</span>
<span class="line" id="L637">                <span class="tok-builtin">@ptrCast</span>([*]<span class="tok-kw">const</span> <span class="tok-type">u8</span>, items.ptr),</span>
<span class="line" id="L638">                items.len * <span class="tok-builtin">@sizeOf</span>(T),</span>
<span class="line" id="L639">            );</span>
<span class="line" id="L640">        }</span>
<span class="line" id="L641"></span>
<span class="line" id="L642">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> WriterContext = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L643">            self: *Self,</span>
<span class="line" id="L644">            allocator: Allocator,</span>
<span class="line" id="L645">        };</span>
<span class="line" id="L646"></span>
<span class="line" id="L647">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> Writer = <span class="tok-kw">if</span> (T != <span class="tok-type">u8</span>)</span>
<span class="line" id="L648">            <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;The Writer interface is only defined for ArrayList(u8) &quot;</span> ++</span>
<span class="line" id="L649">                <span class="tok-str">&quot;but the given type is ArrayList(&quot;</span> ++ <span class="tok-builtin">@typeName</span>(T) ++ <span class="tok-str">&quot;)&quot;</span>)</span>
<span class="line" id="L650">        <span class="tok-kw">else</span></span>
<span class="line" id="L651">            std.io.Writer(WriterContext, <span class="tok-kw">error</span>{OutOfMemory}, appendWrite);</span>
<span class="line" id="L652"></span>
<span class="line" id="L653">        <span class="tok-comment">/// Initializes a Writer which will append to the list.</span></span>
<span class="line" id="L654">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">writer</span>(self: *Self, allocator: Allocator) Writer {</span>
<span class="line" id="L655">            <span class="tok-kw">return</span> .{ .context = .{ .self = self, .allocator = allocator } };</span>
<span class="line" id="L656">        }</span>
<span class="line" id="L657"></span>
<span class="line" id="L658">        <span class="tok-comment">/// Same as `append` except it returns the number of bytes written, which is always the same</span></span>
<span class="line" id="L659">        <span class="tok-comment">/// as `m.len`. The purpose of this function existing is to match `std.io.Writer` API.</span></span>
<span class="line" id="L660">        <span class="tok-kw">fn</span> <span class="tok-fn">appendWrite</span>(context: WriterContext, m: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) Allocator.Error!<span class="tok-type">usize</span> {</span>
<span class="line" id="L661">            <span class="tok-kw">try</span> context.self.appendSlice(context.allocator, m);</span>
<span class="line" id="L662">            <span class="tok-kw">return</span> m.len;</span>
<span class="line" id="L663">        }</span>
<span class="line" id="L664"></span>
<span class="line" id="L665">        <span class="tok-comment">/// Append a value to the list `n` times.</span></span>
<span class="line" id="L666">        <span class="tok-comment">/// Allocates more memory as necessary.</span></span>
<span class="line" id="L667">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">appendNTimes</span>(self: *Self, allocator: Allocator, value: T, n: <span class="tok-type">usize</span>) Allocator.Error!<span class="tok-type">void</span> {</span>
<span class="line" id="L668">            <span class="tok-kw">const</span> old_len = self.items.len;</span>
<span class="line" id="L669">            <span class="tok-kw">try</span> self.resize(allocator, self.items.len + n);</span>
<span class="line" id="L670">            mem.set(T, self.items[old_len..self.items.len], value);</span>
<span class="line" id="L671">        }</span>
<span class="line" id="L672"></span>
<span class="line" id="L673">        <span class="tok-comment">/// Append a value to the list `n` times.</span></span>
<span class="line" id="L674">        <span class="tok-comment">/// **Does not** invalidate pointers.</span></span>
<span class="line" id="L675">        <span class="tok-comment">/// Asserts the capacity is enough.</span></span>
<span class="line" id="L676">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">appendNTimesAssumeCapacity</span>(self: *Self, value: T, n: <span class="tok-type">usize</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L677">            <span class="tok-kw">const</span> new_len = self.items.len + n;</span>
<span class="line" id="L678">            assert(new_len &lt;= self.capacity);</span>
<span class="line" id="L679">            mem.set(T, self.items.ptr[self.items.len..new_len], value);</span>
<span class="line" id="L680">            self.items.len = new_len;</span>
<span class="line" id="L681">        }</span>
<span class="line" id="L682"></span>
<span class="line" id="L683">        <span class="tok-comment">/// Adjust the list's length to `new_len`.</span></span>
<span class="line" id="L684">        <span class="tok-comment">/// Does not initialize added items, if any.</span></span>
<span class="line" id="L685">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">resize</span>(self: *Self, allocator: Allocator, new_len: <span class="tok-type">usize</span>) Allocator.Error!<span class="tok-type">void</span> {</span>
<span class="line" id="L686">            <span class="tok-kw">try</span> self.ensureTotalCapacity(allocator, new_len);</span>
<span class="line" id="L687">            self.items.len = new_len;</span>
<span class="line" id="L688">        }</span>
<span class="line" id="L689"></span>
<span class="line" id="L690">        <span class="tok-comment">/// Reduce allocated capacity to `new_len`.</span></span>
<span class="line" id="L691">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">shrinkAndFree</span>(self: *Self, allocator: Allocator, new_len: <span class="tok-type">usize</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L692">            assert(new_len &lt;= self.items.len);</span>
<span class="line" id="L693"></span>
<span class="line" id="L694">            self.items = allocator.realloc(self.allocatedSlice(), new_len) <span class="tok-kw">catch</span> |e| <span class="tok-kw">switch</span> (e) {</span>
<span class="line" id="L695">                <span class="tok-kw">error</span>.OutOfMemory =&gt; { <span class="tok-comment">// no problem, capacity is still correct then.</span>
</span>
<span class="line" id="L696">                    self.items.len = new_len;</span>
<span class="line" id="L697">                    <span class="tok-kw">return</span>;</span>
<span class="line" id="L698">                },</span>
<span class="line" id="L699">            };</span>
<span class="line" id="L700">            self.capacity = new_len;</span>
<span class="line" id="L701">        }</span>
<span class="line" id="L702"></span>
<span class="line" id="L703">        <span class="tok-comment">/// Reduce length to `new_len`.</span></span>
<span class="line" id="L704">        <span class="tok-comment">/// Invalidates pointers to elements `items[new_len..]`.</span></span>
<span class="line" id="L705">        <span class="tok-comment">/// Keeps capacity the same.</span></span>
<span class="line" id="L706">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">shrinkRetainingCapacity</span>(self: *Self, new_len: <span class="tok-type">usize</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L707">            assert(new_len &lt;= self.items.len);</span>
<span class="line" id="L708">            self.items.len = new_len;</span>
<span class="line" id="L709">        }</span>
<span class="line" id="L710"></span>
<span class="line" id="L711">        <span class="tok-comment">/// Invalidates all element pointers.</span></span>
<span class="line" id="L712">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">clearRetainingCapacity</span>(self: *Self) <span class="tok-type">void</span> {</span>
<span class="line" id="L713">            self.items.len = <span class="tok-number">0</span>;</span>
<span class="line" id="L714">        }</span>
<span class="line" id="L715"></span>
<span class="line" id="L716">        <span class="tok-comment">/// Invalidates all element pointers.</span></span>
<span class="line" id="L717">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">clearAndFree</span>(self: *Self, allocator: Allocator) <span class="tok-type">void</span> {</span>
<span class="line" id="L718">            allocator.free(self.allocatedSlice());</span>
<span class="line" id="L719">            self.items.len = <span class="tok-number">0</span>;</span>
<span class="line" id="L720">            self.capacity = <span class="tok-number">0</span>;</span>
<span class="line" id="L721">        }</span>
<span class="line" id="L722"></span>
<span class="line" id="L723">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> ensureCapacity = <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;deprecated; call `ensureUnusedCapacity` or `ensureTotalCapacity`&quot;</span>);</span>
<span class="line" id="L724"></span>
<span class="line" id="L725">        <span class="tok-comment">/// Modify the array so that it can hold at least `new_capacity` items.</span></span>
<span class="line" id="L726">        <span class="tok-comment">/// Invalidates pointers if additional memory is needed.</span></span>
<span class="line" id="L727">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">ensureTotalCapacity</span>(self: *Self, allocator: Allocator, new_capacity: <span class="tok-type">usize</span>) Allocator.Error!<span class="tok-type">void</span> {</span>
<span class="line" id="L728">            <span class="tok-kw">var</span> better_capacity = self.capacity;</span>
<span class="line" id="L729">            <span class="tok-kw">if</span> (better_capacity &gt;= new_capacity) <span class="tok-kw">return</span>;</span>
<span class="line" id="L730"></span>
<span class="line" id="L731">            <span class="tok-kw">while</span> (<span class="tok-null">true</span>) {</span>
<span class="line" id="L732">                better_capacity += better_capacity / <span class="tok-number">2</span> + <span class="tok-number">8</span>;</span>
<span class="line" id="L733">                <span class="tok-kw">if</span> (better_capacity &gt;= new_capacity) <span class="tok-kw">break</span>;</span>
<span class="line" id="L734">            }</span>
<span class="line" id="L735"></span>
<span class="line" id="L736">            <span class="tok-kw">return</span> self.ensureTotalCapacityPrecise(allocator, better_capacity);</span>
<span class="line" id="L737">        }</span>
<span class="line" id="L738"></span>
<span class="line" id="L739">        <span class="tok-comment">/// Modify the array so that it can hold at least `new_capacity` items.</span></span>
<span class="line" id="L740">        <span class="tok-comment">/// Like `ensureTotalCapacity`, but the resulting capacity is much more likely</span></span>
<span class="line" id="L741">        <span class="tok-comment">/// (but not guaranteed) to be equal to `new_capacity`.</span></span>
<span class="line" id="L742">        <span class="tok-comment">/// Invalidates pointers if additional memory is needed.</span></span>
<span class="line" id="L743">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">ensureTotalCapacityPrecise</span>(self: *Self, allocator: Allocator, new_capacity: <span class="tok-type">usize</span>) Allocator.Error!<span class="tok-type">void</span> {</span>
<span class="line" id="L744">            <span class="tok-kw">if</span> (self.capacity &gt;= new_capacity) <span class="tok-kw">return</span>;</span>
<span class="line" id="L745"></span>
<span class="line" id="L746">            <span class="tok-kw">const</span> new_memory = <span class="tok-kw">try</span> allocator.reallocAtLeast(self.allocatedSlice(), new_capacity);</span>
<span class="line" id="L747">            self.items.ptr = new_memory.ptr;</span>
<span class="line" id="L748">            self.capacity = new_memory.len;</span>
<span class="line" id="L749">        }</span>
<span class="line" id="L750"></span>
<span class="line" id="L751">        <span class="tok-comment">/// Modify the array so that it can hold at least `additional_count` **more** items.</span></span>
<span class="line" id="L752">        <span class="tok-comment">/// Invalidates pointers if additional memory is needed.</span></span>
<span class="line" id="L753">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">ensureUnusedCapacity</span>(</span>
<span class="line" id="L754">            self: *Self,</span>
<span class="line" id="L755">            allocator: Allocator,</span>
<span class="line" id="L756">            additional_count: <span class="tok-type">usize</span>,</span>
<span class="line" id="L757">        ) Allocator.Error!<span class="tok-type">void</span> {</span>
<span class="line" id="L758">            <span class="tok-kw">return</span> self.ensureTotalCapacity(allocator, self.items.len + additional_count);</span>
<span class="line" id="L759">        }</span>
<span class="line" id="L760"></span>
<span class="line" id="L761">        <span class="tok-comment">/// Increases the array's length to match the full capacity that is already allocated.</span></span>
<span class="line" id="L762">        <span class="tok-comment">/// The new elements have `undefined` values.</span></span>
<span class="line" id="L763">        <span class="tok-comment">/// **Does not** invalidate pointers.</span></span>
<span class="line" id="L764">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">expandToCapacity</span>(self: *Self) <span class="tok-type">void</span> {</span>
<span class="line" id="L765">            self.items.len = self.capacity;</span>
<span class="line" id="L766">        }</span>
<span class="line" id="L767"></span>
<span class="line" id="L768">        <span class="tok-comment">/// Increase length by 1, returning pointer to the new item.</span></span>
<span class="line" id="L769">        <span class="tok-comment">/// The returned pointer becomes invalid when the list resized.</span></span>
<span class="line" id="L770">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">addOne</span>(self: *Self, allocator: Allocator) Allocator.Error!*T {</span>
<span class="line" id="L771">            <span class="tok-kw">const</span> newlen = self.items.len + <span class="tok-number">1</span>;</span>
<span class="line" id="L772">            <span class="tok-kw">try</span> self.ensureTotalCapacity(allocator, newlen);</span>
<span class="line" id="L773">            <span class="tok-kw">return</span> self.addOneAssumeCapacity();</span>
<span class="line" id="L774">        }</span>
<span class="line" id="L775"></span>
<span class="line" id="L776">        <span class="tok-comment">/// Increase length by 1, returning pointer to the new item.</span></span>
<span class="line" id="L777">        <span class="tok-comment">/// Asserts that there is already space for the new item without allocating more.</span></span>
<span class="line" id="L778">        <span class="tok-comment">/// **Does not** invalidate pointers.</span></span>
<span class="line" id="L779">        <span class="tok-comment">/// The returned pointer becomes invalid when the list resized.</span></span>
<span class="line" id="L780">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">addOneAssumeCapacity</span>(self: *Self) *T {</span>
<span class="line" id="L781">            assert(self.items.len &lt; self.capacity);</span>
<span class="line" id="L782"></span>
<span class="line" id="L783">            self.items.len += <span class="tok-number">1</span>;</span>
<span class="line" id="L784">            <span class="tok-kw">return</span> &amp;self.items[self.items.len - <span class="tok-number">1</span>];</span>
<span class="line" id="L785">        }</span>
<span class="line" id="L786"></span>
<span class="line" id="L787">        <span class="tok-comment">/// Resize the array, adding `n` new elements, which have `undefined` values.</span></span>
<span class="line" id="L788">        <span class="tok-comment">/// The return value is an array pointing to the newly allocated elements.</span></span>
<span class="line" id="L789">        <span class="tok-comment">/// The returned pointer becomes invalid when the list is resized.</span></span>
<span class="line" id="L790">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">addManyAsArray</span>(self: *Self, allocator: Allocator, <span class="tok-kw">comptime</span> n: <span class="tok-type">usize</span>) Allocator.Error!*[n]T {</span>
<span class="line" id="L791">            <span class="tok-kw">const</span> prev_len = self.items.len;</span>
<span class="line" id="L792">            <span class="tok-kw">try</span> self.resize(allocator, self.items.len + n);</span>
<span class="line" id="L793">            <span class="tok-kw">return</span> self.items[prev_len..][<span class="tok-number">0</span>..n];</span>
<span class="line" id="L794">        }</span>
<span class="line" id="L795"></span>
<span class="line" id="L796">        <span class="tok-comment">/// Resize the array, adding `n` new elements, which have `undefined` values.</span></span>
<span class="line" id="L797">        <span class="tok-comment">/// The return value is an array pointing to the newly allocated elements.</span></span>
<span class="line" id="L798">        <span class="tok-comment">/// Asserts that there is already space for the new item without allocating more.</span></span>
<span class="line" id="L799">        <span class="tok-comment">/// **Does not** invalidate pointers.</span></span>
<span class="line" id="L800">        <span class="tok-comment">/// The returned pointer becomes invalid when the list is resized.</span></span>
<span class="line" id="L801">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">addManyAsArrayAssumeCapacity</span>(self: *Self, <span class="tok-kw">comptime</span> n: <span class="tok-type">usize</span>) *[n]T {</span>
<span class="line" id="L802">            assert(self.items.len + n &lt;= self.capacity);</span>
<span class="line" id="L803">            <span class="tok-kw">const</span> prev_len = self.items.len;</span>
<span class="line" id="L804">            self.items.len += n;</span>
<span class="line" id="L805">            <span class="tok-kw">return</span> self.items[prev_len..][<span class="tok-number">0</span>..n];</span>
<span class="line" id="L806">        }</span>
<span class="line" id="L807"></span>
<span class="line" id="L808">        <span class="tok-comment">/// Remove and return the last element from the list.</span></span>
<span class="line" id="L809">        <span class="tok-comment">/// Asserts the list has at least one item.</span></span>
<span class="line" id="L810">        <span class="tok-comment">/// Invalidates pointers to last element.</span></span>
<span class="line" id="L811">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">pop</span>(self: *Self) T {</span>
<span class="line" id="L812">            <span class="tok-kw">const</span> val = self.items[self.items.len - <span class="tok-number">1</span>];</span>
<span class="line" id="L813">            self.items.len -= <span class="tok-number">1</span>;</span>
<span class="line" id="L814">            <span class="tok-kw">return</span> val;</span>
<span class="line" id="L815">        }</span>
<span class="line" id="L816"></span>
<span class="line" id="L817">        <span class="tok-comment">/// Remove and return the last element from the list.</span></span>
<span class="line" id="L818">        <span class="tok-comment">/// If the list is empty, returns `null`.</span></span>
<span class="line" id="L819">        <span class="tok-comment">/// Invalidates pointers to last element.</span></span>
<span class="line" id="L820">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">popOrNull</span>(self: *Self) ?T {</span>
<span class="line" id="L821">            <span class="tok-kw">if</span> (self.items.len == <span class="tok-number">0</span>) <span class="tok-kw">return</span> <span class="tok-null">null</span>;</span>
<span class="line" id="L822">            <span class="tok-kw">return</span> self.pop();</span>
<span class="line" id="L823">        }</span>
<span class="line" id="L824"></span>
<span class="line" id="L825">        <span class="tok-comment">/// For a nicer API, `items.len` is the length, not the capacity.</span></span>
<span class="line" id="L826">        <span class="tok-comment">/// This requires &quot;unsafe&quot; slicing.</span></span>
<span class="line" id="L827">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">allocatedSlice</span>(self: Self) Slice {</span>
<span class="line" id="L828">            <span class="tok-kw">return</span> self.items.ptr[<span class="tok-number">0</span>..self.capacity];</span>
<span class="line" id="L829">        }</span>
<span class="line" id="L830"></span>
<span class="line" id="L831">        <span class="tok-comment">/// Returns a slice of only the extra capacity after items.</span></span>
<span class="line" id="L832">        <span class="tok-comment">/// This can be useful for writing directly into an ArrayList.</span></span>
<span class="line" id="L833">        <span class="tok-comment">/// Note that such an operation must be followed up with a direct</span></span>
<span class="line" id="L834">        <span class="tok-comment">/// modification of `self.items.len`.</span></span>
<span class="line" id="L835">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">unusedCapacitySlice</span>(self: Self) Slice {</span>
<span class="line" id="L836">            <span class="tok-kw">return</span> self.allocatedSlice()[self.items.len..];</span>
<span class="line" id="L837">        }</span>
<span class="line" id="L838">    };</span>
<span class="line" id="L839">}</span>
<span class="line" id="L840"></span>
<span class="line" id="L841"><span class="tok-kw">test</span> <span class="tok-str">&quot;std.ArrayList/ArrayListUnmanaged.init&quot;</span> {</span>
<span class="line" id="L842">    {</span>
<span class="line" id="L843">        <span class="tok-kw">var</span> list = ArrayList(<span class="tok-type">i32</span>).init(testing.allocator);</span>
<span class="line" id="L844">        <span class="tok-kw">defer</span> list.deinit();</span>
<span class="line" id="L845"></span>
<span class="line" id="L846">        <span class="tok-kw">try</span> testing.expect(list.items.len == <span class="tok-number">0</span>);</span>
<span class="line" id="L847">        <span class="tok-kw">try</span> testing.expect(list.capacity == <span class="tok-number">0</span>);</span>
<span class="line" id="L848">    }</span>
<span class="line" id="L849"></span>
<span class="line" id="L850">    {</span>
<span class="line" id="L851">        <span class="tok-kw">var</span> list = ArrayListUnmanaged(<span class="tok-type">i32</span>){};</span>
<span class="line" id="L852"></span>
<span class="line" id="L853">        <span class="tok-kw">try</span> testing.expect(list.items.len == <span class="tok-number">0</span>);</span>
<span class="line" id="L854">        <span class="tok-kw">try</span> testing.expect(list.capacity == <span class="tok-number">0</span>);</span>
<span class="line" id="L855">    }</span>
<span class="line" id="L856">}</span>
<span class="line" id="L857"></span>
<span class="line" id="L858"><span class="tok-kw">test</span> <span class="tok-str">&quot;std.ArrayList/ArrayListUnmanaged.initCapacity&quot;</span> {</span>
<span class="line" id="L859">    <span class="tok-kw">const</span> a = testing.allocator;</span>
<span class="line" id="L860">    {</span>
<span class="line" id="L861">        <span class="tok-kw">var</span> list = <span class="tok-kw">try</span> ArrayList(<span class="tok-type">i8</span>).initCapacity(a, <span class="tok-number">200</span>);</span>
<span class="line" id="L862">        <span class="tok-kw">defer</span> list.deinit();</span>
<span class="line" id="L863">        <span class="tok-kw">try</span> testing.expect(list.items.len == <span class="tok-number">0</span>);</span>
<span class="line" id="L864">        <span class="tok-kw">try</span> testing.expect(list.capacity &gt;= <span class="tok-number">200</span>);</span>
<span class="line" id="L865">    }</span>
<span class="line" id="L866">    {</span>
<span class="line" id="L867">        <span class="tok-kw">var</span> list = <span class="tok-kw">try</span> ArrayListUnmanaged(<span class="tok-type">i8</span>).initCapacity(a, <span class="tok-number">200</span>);</span>
<span class="line" id="L868">        <span class="tok-kw">defer</span> list.deinit(a);</span>
<span class="line" id="L869">        <span class="tok-kw">try</span> testing.expect(list.items.len == <span class="tok-number">0</span>);</span>
<span class="line" id="L870">        <span class="tok-kw">try</span> testing.expect(list.capacity &gt;= <span class="tok-number">200</span>);</span>
<span class="line" id="L871">    }</span>
<span class="line" id="L872">}</span>
<span class="line" id="L873"></span>
<span class="line" id="L874"><span class="tok-kw">test</span> <span class="tok-str">&quot;std.ArrayList/ArrayListUnmanaged.clone&quot;</span> {</span>
<span class="line" id="L875">    <span class="tok-kw">const</span> a = testing.allocator;</span>
<span class="line" id="L876">    {</span>
<span class="line" id="L877">        <span class="tok-kw">var</span> array = ArrayList(<span class="tok-type">i32</span>).init(a);</span>
<span class="line" id="L878">        <span class="tok-kw">try</span> array.append(-<span class="tok-number">1</span>);</span>
<span class="line" id="L879">        <span class="tok-kw">try</span> array.append(<span class="tok-number">3</span>);</span>
<span class="line" id="L880">        <span class="tok-kw">try</span> array.append(<span class="tok-number">5</span>);</span>
<span class="line" id="L881"></span>
<span class="line" id="L882">        <span class="tok-kw">const</span> cloned = <span class="tok-kw">try</span> array.clone();</span>
<span class="line" id="L883">        <span class="tok-kw">defer</span> cloned.deinit();</span>
<span class="line" id="L884"></span>
<span class="line" id="L885">        <span class="tok-kw">try</span> testing.expectEqualSlices(<span class="tok-type">i32</span>, array.items, cloned.items);</span>
<span class="line" id="L886">        <span class="tok-kw">try</span> testing.expectEqual(array.allocator, cloned.allocator);</span>
<span class="line" id="L887">        <span class="tok-kw">try</span> testing.expect(cloned.capacity &gt;= array.capacity);</span>
<span class="line" id="L888"></span>
<span class="line" id="L889">        array.deinit();</span>
<span class="line" id="L890"></span>
<span class="line" id="L891">        <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">i32</span>, -<span class="tok-number">1</span>), cloned.items[<span class="tok-number">0</span>]);</span>
<span class="line" id="L892">        <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">i32</span>, <span class="tok-number">3</span>), cloned.items[<span class="tok-number">1</span>]);</span>
<span class="line" id="L893">        <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">i32</span>, <span class="tok-number">5</span>), cloned.items[<span class="tok-number">2</span>]);</span>
<span class="line" id="L894">    }</span>
<span class="line" id="L895">    {</span>
<span class="line" id="L896">        <span class="tok-kw">var</span> array = ArrayListUnmanaged(<span class="tok-type">i32</span>){};</span>
<span class="line" id="L897">        <span class="tok-kw">try</span> array.append(a, -<span class="tok-number">1</span>);</span>
<span class="line" id="L898">        <span class="tok-kw">try</span> array.append(a, <span class="tok-number">3</span>);</span>
<span class="line" id="L899">        <span class="tok-kw">try</span> array.append(a, <span class="tok-number">5</span>);</span>
<span class="line" id="L900"></span>
<span class="line" id="L901">        <span class="tok-kw">var</span> cloned = <span class="tok-kw">try</span> array.clone(a);</span>
<span class="line" id="L902">        <span class="tok-kw">defer</span> cloned.deinit(a);</span>
<span class="line" id="L903"></span>
<span class="line" id="L904">        <span class="tok-kw">try</span> testing.expectEqualSlices(<span class="tok-type">i32</span>, array.items, cloned.items);</span>
<span class="line" id="L905">        <span class="tok-kw">try</span> testing.expect(cloned.capacity &gt;= array.capacity);</span>
<span class="line" id="L906"></span>
<span class="line" id="L907">        array.deinit(a);</span>
<span class="line" id="L908"></span>
<span class="line" id="L909">        <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">i32</span>, -<span class="tok-number">1</span>), cloned.items[<span class="tok-number">0</span>]);</span>
<span class="line" id="L910">        <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">i32</span>, <span class="tok-number">3</span>), cloned.items[<span class="tok-number">1</span>]);</span>
<span class="line" id="L911">        <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">i32</span>, <span class="tok-number">5</span>), cloned.items[<span class="tok-number">2</span>]);</span>
<span class="line" id="L912">    }</span>
<span class="line" id="L913">}</span>
<span class="line" id="L914"></span>
<span class="line" id="L915"><span class="tok-kw">test</span> <span class="tok-str">&quot;std.ArrayList/ArrayListUnmanaged.basic&quot;</span> {</span>
<span class="line" id="L916">    <span class="tok-kw">const</span> a = testing.allocator;</span>
<span class="line" id="L917">    {</span>
<span class="line" id="L918">        <span class="tok-kw">var</span> list = ArrayList(<span class="tok-type">i32</span>).init(a);</span>
<span class="line" id="L919">        <span class="tok-kw">defer</span> list.deinit();</span>
<span class="line" id="L920"></span>
<span class="line" id="L921">        {</span>
<span class="line" id="L922">            <span class="tok-kw">var</span> i: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L923">            <span class="tok-kw">while</span> (i &lt; <span class="tok-number">10</span>) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L924">                list.append(<span class="tok-builtin">@intCast</span>(<span class="tok-type">i32</span>, i + <span class="tok-number">1</span>)) <span class="tok-kw">catch</span> <span class="tok-kw">unreachable</span>;</span>
<span class="line" id="L925">            }</span>
<span class="line" id="L926">        }</span>
<span class="line" id="L927"></span>
<span class="line" id="L928">        {</span>
<span class="line" id="L929">            <span class="tok-kw">var</span> i: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L930">            <span class="tok-kw">while</span> (i &lt; <span class="tok-number">10</span>) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L931">                <span class="tok-kw">try</span> testing.expect(list.items[i] == <span class="tok-builtin">@intCast</span>(<span class="tok-type">i32</span>, i + <span class="tok-number">1</span>));</span>
<span class="line" id="L932">            }</span>
<span class="line" id="L933">        }</span>
<span class="line" id="L934"></span>
<span class="line" id="L935">        <span class="tok-kw">for</span> (list.items) |v, i| {</span>
<span class="line" id="L936">            <span class="tok-kw">try</span> testing.expect(v == <span class="tok-builtin">@intCast</span>(<span class="tok-type">i32</span>, i + <span class="tok-number">1</span>));</span>
<span class="line" id="L937">        }</span>
<span class="line" id="L938"></span>
<span class="line" id="L939">        <span class="tok-kw">try</span> testing.expect(list.pop() == <span class="tok-number">10</span>);</span>
<span class="line" id="L940">        <span class="tok-kw">try</span> testing.expect(list.items.len == <span class="tok-number">9</span>);</span>
<span class="line" id="L941"></span>
<span class="line" id="L942">        list.appendSlice(&amp;[_]<span class="tok-type">i32</span>{ <span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">3</span> }) <span class="tok-kw">catch</span> <span class="tok-kw">unreachable</span>;</span>
<span class="line" id="L943">        <span class="tok-kw">try</span> testing.expect(list.items.len == <span class="tok-number">12</span>);</span>
<span class="line" id="L944">        <span class="tok-kw">try</span> testing.expect(list.pop() == <span class="tok-number">3</span>);</span>
<span class="line" id="L945">        <span class="tok-kw">try</span> testing.expect(list.pop() == <span class="tok-number">2</span>);</span>
<span class="line" id="L946">        <span class="tok-kw">try</span> testing.expect(list.pop() == <span class="tok-number">1</span>);</span>
<span class="line" id="L947">        <span class="tok-kw">try</span> testing.expect(list.items.len == <span class="tok-number">9</span>);</span>
<span class="line" id="L948"></span>
<span class="line" id="L949">        <span class="tok-kw">var</span> unaligned: [<span class="tok-number">3</span>]<span class="tok-type">i32</span> <span class="tok-kw">align</span>(<span class="tok-number">1</span>) = [_]<span class="tok-type">i32</span>{ <span class="tok-number">4</span>, <span class="tok-number">5</span>, <span class="tok-number">6</span> };</span>
<span class="line" id="L950">        list.appendUnalignedSlice(&amp;unaligned) <span class="tok-kw">catch</span> <span class="tok-kw">unreachable</span>;</span>
<span class="line" id="L951">        <span class="tok-kw">try</span> testing.expect(list.items.len == <span class="tok-number">12</span>);</span>
<span class="line" id="L952">        <span class="tok-kw">try</span> testing.expect(list.pop() == <span class="tok-number">6</span>);</span>
<span class="line" id="L953">        <span class="tok-kw">try</span> testing.expect(list.pop() == <span class="tok-number">5</span>);</span>
<span class="line" id="L954">        <span class="tok-kw">try</span> testing.expect(list.pop() == <span class="tok-number">4</span>);</span>
<span class="line" id="L955">        <span class="tok-kw">try</span> testing.expect(list.items.len == <span class="tok-number">9</span>);</span>
<span class="line" id="L956"></span>
<span class="line" id="L957">        list.appendSlice(&amp;[_]<span class="tok-type">i32</span>{}) <span class="tok-kw">catch</span> <span class="tok-kw">unreachable</span>;</span>
<span class="line" id="L958">        <span class="tok-kw">try</span> testing.expect(list.items.len == <span class="tok-number">9</span>);</span>
<span class="line" id="L959"></span>
<span class="line" id="L960">        <span class="tok-comment">// can only set on indices &lt; self.items.len</span>
</span>
<span class="line" id="L961">        list.items[<span class="tok-number">7</span>] = <span class="tok-number">33</span>;</span>
<span class="line" id="L962">        list.items[<span class="tok-number">8</span>] = <span class="tok-number">42</span>;</span>
<span class="line" id="L963"></span>
<span class="line" id="L964">        <span class="tok-kw">try</span> testing.expect(list.pop() == <span class="tok-number">42</span>);</span>
<span class="line" id="L965">        <span class="tok-kw">try</span> testing.expect(list.pop() == <span class="tok-number">33</span>);</span>
<span class="line" id="L966">    }</span>
<span class="line" id="L967">    {</span>
<span class="line" id="L968">        <span class="tok-kw">var</span> list = ArrayListUnmanaged(<span class="tok-type">i32</span>){};</span>
<span class="line" id="L969">        <span class="tok-kw">defer</span> list.deinit(a);</span>
<span class="line" id="L970"></span>
<span class="line" id="L971">        {</span>
<span class="line" id="L972">            <span class="tok-kw">var</span> i: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L973">            <span class="tok-kw">while</span> (i &lt; <span class="tok-number">10</span>) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L974">                list.append(a, <span class="tok-builtin">@intCast</span>(<span class="tok-type">i32</span>, i + <span class="tok-number">1</span>)) <span class="tok-kw">catch</span> <span class="tok-kw">unreachable</span>;</span>
<span class="line" id="L975">            }</span>
<span class="line" id="L976">        }</span>
<span class="line" id="L977"></span>
<span class="line" id="L978">        {</span>
<span class="line" id="L979">            <span class="tok-kw">var</span> i: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L980">            <span class="tok-kw">while</span> (i &lt; <span class="tok-number">10</span>) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L981">                <span class="tok-kw">try</span> testing.expect(list.items[i] == <span class="tok-builtin">@intCast</span>(<span class="tok-type">i32</span>, i + <span class="tok-number">1</span>));</span>
<span class="line" id="L982">            }</span>
<span class="line" id="L983">        }</span>
<span class="line" id="L984"></span>
<span class="line" id="L985">        <span class="tok-kw">for</span> (list.items) |v, i| {</span>
<span class="line" id="L986">            <span class="tok-kw">try</span> testing.expect(v == <span class="tok-builtin">@intCast</span>(<span class="tok-type">i32</span>, i + <span class="tok-number">1</span>));</span>
<span class="line" id="L987">        }</span>
<span class="line" id="L988"></span>
<span class="line" id="L989">        <span class="tok-kw">try</span> testing.expect(list.pop() == <span class="tok-number">10</span>);</span>
<span class="line" id="L990">        <span class="tok-kw">try</span> testing.expect(list.items.len == <span class="tok-number">9</span>);</span>
<span class="line" id="L991"></span>
<span class="line" id="L992">        list.appendSlice(a, &amp;[_]<span class="tok-type">i32</span>{ <span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">3</span> }) <span class="tok-kw">catch</span> <span class="tok-kw">unreachable</span>;</span>
<span class="line" id="L993">        <span class="tok-kw">try</span> testing.expect(list.items.len == <span class="tok-number">12</span>);</span>
<span class="line" id="L994">        <span class="tok-kw">try</span> testing.expect(list.pop() == <span class="tok-number">3</span>);</span>
<span class="line" id="L995">        <span class="tok-kw">try</span> testing.expect(list.pop() == <span class="tok-number">2</span>);</span>
<span class="line" id="L996">        <span class="tok-kw">try</span> testing.expect(list.pop() == <span class="tok-number">1</span>);</span>
<span class="line" id="L997">        <span class="tok-kw">try</span> testing.expect(list.items.len == <span class="tok-number">9</span>);</span>
<span class="line" id="L998"></span>
<span class="line" id="L999">        <span class="tok-kw">var</span> unaligned: [<span class="tok-number">3</span>]<span class="tok-type">i32</span> <span class="tok-kw">align</span>(<span class="tok-number">1</span>) = [_]<span class="tok-type">i32</span>{ <span class="tok-number">4</span>, <span class="tok-number">5</span>, <span class="tok-number">6</span> };</span>
<span class="line" id="L1000">        list.appendUnalignedSlice(a, &amp;unaligned) <span class="tok-kw">catch</span> <span class="tok-kw">unreachable</span>;</span>
<span class="line" id="L1001">        <span class="tok-kw">try</span> testing.expect(list.items.len == <span class="tok-number">12</span>);</span>
<span class="line" id="L1002">        <span class="tok-kw">try</span> testing.expect(list.pop() == <span class="tok-number">6</span>);</span>
<span class="line" id="L1003">        <span class="tok-kw">try</span> testing.expect(list.pop() == <span class="tok-number">5</span>);</span>
<span class="line" id="L1004">        <span class="tok-kw">try</span> testing.expect(list.pop() == <span class="tok-number">4</span>);</span>
<span class="line" id="L1005">        <span class="tok-kw">try</span> testing.expect(list.items.len == <span class="tok-number">9</span>);</span>
<span class="line" id="L1006"></span>
<span class="line" id="L1007">        list.appendSlice(a, &amp;[_]<span class="tok-type">i32</span>{}) <span class="tok-kw">catch</span> <span class="tok-kw">unreachable</span>;</span>
<span class="line" id="L1008">        <span class="tok-kw">try</span> testing.expect(list.items.len == <span class="tok-number">9</span>);</span>
<span class="line" id="L1009"></span>
<span class="line" id="L1010">        <span class="tok-comment">// can only set on indices &lt; self.items.len</span>
</span>
<span class="line" id="L1011">        list.items[<span class="tok-number">7</span>] = <span class="tok-number">33</span>;</span>
<span class="line" id="L1012">        list.items[<span class="tok-number">8</span>] = <span class="tok-number">42</span>;</span>
<span class="line" id="L1013"></span>
<span class="line" id="L1014">        <span class="tok-kw">try</span> testing.expect(list.pop() == <span class="tok-number">42</span>);</span>
<span class="line" id="L1015">        <span class="tok-kw">try</span> testing.expect(list.pop() == <span class="tok-number">33</span>);</span>
<span class="line" id="L1016">    }</span>
<span class="line" id="L1017">}</span>
<span class="line" id="L1018"></span>
<span class="line" id="L1019"><span class="tok-kw">test</span> <span class="tok-str">&quot;std.ArrayList/ArrayListUnmanaged.appendNTimes&quot;</span> {</span>
<span class="line" id="L1020">    <span class="tok-kw">const</span> a = testing.allocator;</span>
<span class="line" id="L1021">    {</span>
<span class="line" id="L1022">        <span class="tok-kw">var</span> list = ArrayList(<span class="tok-type">i32</span>).init(a);</span>
<span class="line" id="L1023">        <span class="tok-kw">defer</span> list.deinit();</span>
<span class="line" id="L1024"></span>
<span class="line" id="L1025">        <span class="tok-kw">try</span> list.appendNTimes(<span class="tok-number">2</span>, <span class="tok-number">10</span>);</span>
<span class="line" id="L1026">        <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">usize</span>, <span class="tok-number">10</span>), list.items.len);</span>
<span class="line" id="L1027">        <span class="tok-kw">for</span> (list.items) |element| {</span>
<span class="line" id="L1028">            <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">i32</span>, <span class="tok-number">2</span>), element);</span>
<span class="line" id="L1029">        }</span>
<span class="line" id="L1030">    }</span>
<span class="line" id="L1031">    {</span>
<span class="line" id="L1032">        <span class="tok-kw">var</span> list = ArrayListUnmanaged(<span class="tok-type">i32</span>){};</span>
<span class="line" id="L1033">        <span class="tok-kw">defer</span> list.deinit(a);</span>
<span class="line" id="L1034"></span>
<span class="line" id="L1035">        <span class="tok-kw">try</span> list.appendNTimes(a, <span class="tok-number">2</span>, <span class="tok-number">10</span>);</span>
<span class="line" id="L1036">        <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">usize</span>, <span class="tok-number">10</span>), list.items.len);</span>
<span class="line" id="L1037">        <span class="tok-kw">for</span> (list.items) |element| {</span>
<span class="line" id="L1038">            <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">i32</span>, <span class="tok-number">2</span>), element);</span>
<span class="line" id="L1039">        }</span>
<span class="line" id="L1040">    }</span>
<span class="line" id="L1041">}</span>
<span class="line" id="L1042"></span>
<span class="line" id="L1043"><span class="tok-kw">test</span> <span class="tok-str">&quot;std.ArrayList/ArrayListUnmanaged.appendNTimes with failing allocator&quot;</span> {</span>
<span class="line" id="L1044">    <span class="tok-kw">const</span> a = testing.failing_allocator;</span>
<span class="line" id="L1045">    {</span>
<span class="line" id="L1046">        <span class="tok-kw">var</span> list = ArrayList(<span class="tok-type">i32</span>).init(a);</span>
<span class="line" id="L1047">        <span class="tok-kw">defer</span> list.deinit();</span>
<span class="line" id="L1048">        <span class="tok-kw">try</span> testing.expectError(<span class="tok-kw">error</span>.OutOfMemory, list.appendNTimes(<span class="tok-number">2</span>, <span class="tok-number">10</span>));</span>
<span class="line" id="L1049">    }</span>
<span class="line" id="L1050">    {</span>
<span class="line" id="L1051">        <span class="tok-kw">var</span> list = ArrayListUnmanaged(<span class="tok-type">i32</span>){};</span>
<span class="line" id="L1052">        <span class="tok-kw">defer</span> list.deinit(a);</span>
<span class="line" id="L1053">        <span class="tok-kw">try</span> testing.expectError(<span class="tok-kw">error</span>.OutOfMemory, list.appendNTimes(a, <span class="tok-number">2</span>, <span class="tok-number">10</span>));</span>
<span class="line" id="L1054">    }</span>
<span class="line" id="L1055">}</span>
<span class="line" id="L1056"></span>
<span class="line" id="L1057"><span class="tok-kw">test</span> <span class="tok-str">&quot;std.ArrayList/ArrayListUnmanaged.orderedRemove&quot;</span> {</span>
<span class="line" id="L1058">    <span class="tok-kw">const</span> a = testing.allocator;</span>
<span class="line" id="L1059">    {</span>
<span class="line" id="L1060">        <span class="tok-kw">var</span> list = ArrayList(<span class="tok-type">i32</span>).init(a);</span>
<span class="line" id="L1061">        <span class="tok-kw">defer</span> list.deinit();</span>
<span class="line" id="L1062"></span>
<span class="line" id="L1063">        <span class="tok-kw">try</span> list.append(<span class="tok-number">1</span>);</span>
<span class="line" id="L1064">        <span class="tok-kw">try</span> list.append(<span class="tok-number">2</span>);</span>
<span class="line" id="L1065">        <span class="tok-kw">try</span> list.append(<span class="tok-number">3</span>);</span>
<span class="line" id="L1066">        <span class="tok-kw">try</span> list.append(<span class="tok-number">4</span>);</span>
<span class="line" id="L1067">        <span class="tok-kw">try</span> list.append(<span class="tok-number">5</span>);</span>
<span class="line" id="L1068">        <span class="tok-kw">try</span> list.append(<span class="tok-number">6</span>);</span>
<span class="line" id="L1069">        <span class="tok-kw">try</span> list.append(<span class="tok-number">7</span>);</span>
<span class="line" id="L1070"></span>
<span class="line" id="L1071">        <span class="tok-comment">//remove from middle</span>
</span>
<span class="line" id="L1072">        <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">i32</span>, <span class="tok-number">4</span>), list.orderedRemove(<span class="tok-number">3</span>));</span>
<span class="line" id="L1073">        <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">i32</span>, <span class="tok-number">5</span>), list.items[<span class="tok-number">3</span>]);</span>
<span class="line" id="L1074">        <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">usize</span>, <span class="tok-number">6</span>), list.items.len);</span>
<span class="line" id="L1075"></span>
<span class="line" id="L1076">        <span class="tok-comment">//remove from end</span>
</span>
<span class="line" id="L1077">        <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">i32</span>, <span class="tok-number">7</span>), list.orderedRemove(<span class="tok-number">5</span>));</span>
<span class="line" id="L1078">        <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">usize</span>, <span class="tok-number">5</span>), list.items.len);</span>
<span class="line" id="L1079"></span>
<span class="line" id="L1080">        <span class="tok-comment">//remove from front</span>
</span>
<span class="line" id="L1081">        <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">i32</span>, <span class="tok-number">1</span>), list.orderedRemove(<span class="tok-number">0</span>));</span>
<span class="line" id="L1082">        <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">i32</span>, <span class="tok-number">2</span>), list.items[<span class="tok-number">0</span>]);</span>
<span class="line" id="L1083">        <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">usize</span>, <span class="tok-number">4</span>), list.items.len);</span>
<span class="line" id="L1084">    }</span>
<span class="line" id="L1085">    {</span>
<span class="line" id="L1086">        <span class="tok-kw">var</span> list = ArrayListUnmanaged(<span class="tok-type">i32</span>){};</span>
<span class="line" id="L1087">        <span class="tok-kw">defer</span> list.deinit(a);</span>
<span class="line" id="L1088"></span>
<span class="line" id="L1089">        <span class="tok-kw">try</span> list.append(a, <span class="tok-number">1</span>);</span>
<span class="line" id="L1090">        <span class="tok-kw">try</span> list.append(a, <span class="tok-number">2</span>);</span>
<span class="line" id="L1091">        <span class="tok-kw">try</span> list.append(a, <span class="tok-number">3</span>);</span>
<span class="line" id="L1092">        <span class="tok-kw">try</span> list.append(a, <span class="tok-number">4</span>);</span>
<span class="line" id="L1093">        <span class="tok-kw">try</span> list.append(a, <span class="tok-number">5</span>);</span>
<span class="line" id="L1094">        <span class="tok-kw">try</span> list.append(a, <span class="tok-number">6</span>);</span>
<span class="line" id="L1095">        <span class="tok-kw">try</span> list.append(a, <span class="tok-number">7</span>);</span>
<span class="line" id="L1096"></span>
<span class="line" id="L1097">        <span class="tok-comment">//remove from middle</span>
</span>
<span class="line" id="L1098">        <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">i32</span>, <span class="tok-number">4</span>), list.orderedRemove(<span class="tok-number">3</span>));</span>
<span class="line" id="L1099">        <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">i32</span>, <span class="tok-number">5</span>), list.items[<span class="tok-number">3</span>]);</span>
<span class="line" id="L1100">        <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">usize</span>, <span class="tok-number">6</span>), list.items.len);</span>
<span class="line" id="L1101"></span>
<span class="line" id="L1102">        <span class="tok-comment">//remove from end</span>
</span>
<span class="line" id="L1103">        <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">i32</span>, <span class="tok-number">7</span>), list.orderedRemove(<span class="tok-number">5</span>));</span>
<span class="line" id="L1104">        <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">usize</span>, <span class="tok-number">5</span>), list.items.len);</span>
<span class="line" id="L1105"></span>
<span class="line" id="L1106">        <span class="tok-comment">//remove from front</span>
</span>
<span class="line" id="L1107">        <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">i32</span>, <span class="tok-number">1</span>), list.orderedRemove(<span class="tok-number">0</span>));</span>
<span class="line" id="L1108">        <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">i32</span>, <span class="tok-number">2</span>), list.items[<span class="tok-number">0</span>]);</span>
<span class="line" id="L1109">        <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">usize</span>, <span class="tok-number">4</span>), list.items.len);</span>
<span class="line" id="L1110">    }</span>
<span class="line" id="L1111">}</span>
<span class="line" id="L1112"></span>
<span class="line" id="L1113"><span class="tok-kw">test</span> <span class="tok-str">&quot;std.ArrayList/ArrayListUnmanaged.swapRemove&quot;</span> {</span>
<span class="line" id="L1114">    <span class="tok-kw">const</span> a = testing.allocator;</span>
<span class="line" id="L1115">    {</span>
<span class="line" id="L1116">        <span class="tok-kw">var</span> list = ArrayList(<span class="tok-type">i32</span>).init(a);</span>
<span class="line" id="L1117">        <span class="tok-kw">defer</span> list.deinit();</span>
<span class="line" id="L1118"></span>
<span class="line" id="L1119">        <span class="tok-kw">try</span> list.append(<span class="tok-number">1</span>);</span>
<span class="line" id="L1120">        <span class="tok-kw">try</span> list.append(<span class="tok-number">2</span>);</span>
<span class="line" id="L1121">        <span class="tok-kw">try</span> list.append(<span class="tok-number">3</span>);</span>
<span class="line" id="L1122">        <span class="tok-kw">try</span> list.append(<span class="tok-number">4</span>);</span>
<span class="line" id="L1123">        <span class="tok-kw">try</span> list.append(<span class="tok-number">5</span>);</span>
<span class="line" id="L1124">        <span class="tok-kw">try</span> list.append(<span class="tok-number">6</span>);</span>
<span class="line" id="L1125">        <span class="tok-kw">try</span> list.append(<span class="tok-number">7</span>);</span>
<span class="line" id="L1126"></span>
<span class="line" id="L1127">        <span class="tok-comment">//remove from middle</span>
</span>
<span class="line" id="L1128">        <span class="tok-kw">try</span> testing.expect(list.swapRemove(<span class="tok-number">3</span>) == <span class="tok-number">4</span>);</span>
<span class="line" id="L1129">        <span class="tok-kw">try</span> testing.expect(list.items[<span class="tok-number">3</span>] == <span class="tok-number">7</span>);</span>
<span class="line" id="L1130">        <span class="tok-kw">try</span> testing.expect(list.items.len == <span class="tok-number">6</span>);</span>
<span class="line" id="L1131"></span>
<span class="line" id="L1132">        <span class="tok-comment">//remove from end</span>
</span>
<span class="line" id="L1133">        <span class="tok-kw">try</span> testing.expect(list.swapRemove(<span class="tok-number">5</span>) == <span class="tok-number">6</span>);</span>
<span class="line" id="L1134">        <span class="tok-kw">try</span> testing.expect(list.items.len == <span class="tok-number">5</span>);</span>
<span class="line" id="L1135"></span>
<span class="line" id="L1136">        <span class="tok-comment">//remove from front</span>
</span>
<span class="line" id="L1137">        <span class="tok-kw">try</span> testing.expect(list.swapRemove(<span class="tok-number">0</span>) == <span class="tok-number">1</span>);</span>
<span class="line" id="L1138">        <span class="tok-kw">try</span> testing.expect(list.items[<span class="tok-number">0</span>] == <span class="tok-number">5</span>);</span>
<span class="line" id="L1139">        <span class="tok-kw">try</span> testing.expect(list.items.len == <span class="tok-number">4</span>);</span>
<span class="line" id="L1140">    }</span>
<span class="line" id="L1141">    {</span>
<span class="line" id="L1142">        <span class="tok-kw">var</span> list = ArrayListUnmanaged(<span class="tok-type">i32</span>){};</span>
<span class="line" id="L1143">        <span class="tok-kw">defer</span> list.deinit(a);</span>
<span class="line" id="L1144"></span>
<span class="line" id="L1145">        <span class="tok-kw">try</span> list.append(a, <span class="tok-number">1</span>);</span>
<span class="line" id="L1146">        <span class="tok-kw">try</span> list.append(a, <span class="tok-number">2</span>);</span>
<span class="line" id="L1147">        <span class="tok-kw">try</span> list.append(a, <span class="tok-number">3</span>);</span>
<span class="line" id="L1148">        <span class="tok-kw">try</span> list.append(a, <span class="tok-number">4</span>);</span>
<span class="line" id="L1149">        <span class="tok-kw">try</span> list.append(a, <span class="tok-number">5</span>);</span>
<span class="line" id="L1150">        <span class="tok-kw">try</span> list.append(a, <span class="tok-number">6</span>);</span>
<span class="line" id="L1151">        <span class="tok-kw">try</span> list.append(a, <span class="tok-number">7</span>);</span>
<span class="line" id="L1152"></span>
<span class="line" id="L1153">        <span class="tok-comment">//remove from middle</span>
</span>
<span class="line" id="L1154">        <span class="tok-kw">try</span> testing.expect(list.swapRemove(<span class="tok-number">3</span>) == <span class="tok-number">4</span>);</span>
<span class="line" id="L1155">        <span class="tok-kw">try</span> testing.expect(list.items[<span class="tok-number">3</span>] == <span class="tok-number">7</span>);</span>
<span class="line" id="L1156">        <span class="tok-kw">try</span> testing.expect(list.items.len == <span class="tok-number">6</span>);</span>
<span class="line" id="L1157"></span>
<span class="line" id="L1158">        <span class="tok-comment">//remove from end</span>
</span>
<span class="line" id="L1159">        <span class="tok-kw">try</span> testing.expect(list.swapRemove(<span class="tok-number">5</span>) == <span class="tok-number">6</span>);</span>
<span class="line" id="L1160">        <span class="tok-kw">try</span> testing.expect(list.items.len == <span class="tok-number">5</span>);</span>
<span class="line" id="L1161"></span>
<span class="line" id="L1162">        <span class="tok-comment">//remove from front</span>
</span>
<span class="line" id="L1163">        <span class="tok-kw">try</span> testing.expect(list.swapRemove(<span class="tok-number">0</span>) == <span class="tok-number">1</span>);</span>
<span class="line" id="L1164">        <span class="tok-kw">try</span> testing.expect(list.items[<span class="tok-number">0</span>] == <span class="tok-number">5</span>);</span>
<span class="line" id="L1165">        <span class="tok-kw">try</span> testing.expect(list.items.len == <span class="tok-number">4</span>);</span>
<span class="line" id="L1166">    }</span>
<span class="line" id="L1167">}</span>
<span class="line" id="L1168"></span>
<span class="line" id="L1169"><span class="tok-kw">test</span> <span class="tok-str">&quot;std.ArrayList/ArrayListUnmanaged.insert&quot;</span> {</span>
<span class="line" id="L1170">    <span class="tok-kw">const</span> a = testing.allocator;</span>
<span class="line" id="L1171">    {</span>
<span class="line" id="L1172">        <span class="tok-kw">var</span> list = ArrayList(<span class="tok-type">i32</span>).init(a);</span>
<span class="line" id="L1173">        <span class="tok-kw">defer</span> list.deinit();</span>
<span class="line" id="L1174"></span>
<span class="line" id="L1175">        <span class="tok-kw">try</span> list.append(<span class="tok-number">1</span>);</span>
<span class="line" id="L1176">        <span class="tok-kw">try</span> list.append(<span class="tok-number">2</span>);</span>
<span class="line" id="L1177">        <span class="tok-kw">try</span> list.append(<span class="tok-number">3</span>);</span>
<span class="line" id="L1178">        <span class="tok-kw">try</span> list.insert(<span class="tok-number">0</span>, <span class="tok-number">5</span>);</span>
<span class="line" id="L1179">        <span class="tok-kw">try</span> testing.expect(list.items[<span class="tok-number">0</span>] == <span class="tok-number">5</span>);</span>
<span class="line" id="L1180">        <span class="tok-kw">try</span> testing.expect(list.items[<span class="tok-number">1</span>] == <span class="tok-number">1</span>);</span>
<span class="line" id="L1181">        <span class="tok-kw">try</span> testing.expect(list.items[<span class="tok-number">2</span>] == <span class="tok-number">2</span>);</span>
<span class="line" id="L1182">        <span class="tok-kw">try</span> testing.expect(list.items[<span class="tok-number">3</span>] == <span class="tok-number">3</span>);</span>
<span class="line" id="L1183">    }</span>
<span class="line" id="L1184">    {</span>
<span class="line" id="L1185">        <span class="tok-kw">var</span> list = ArrayListUnmanaged(<span class="tok-type">i32</span>){};</span>
<span class="line" id="L1186">        <span class="tok-kw">defer</span> list.deinit(a);</span>
<span class="line" id="L1187"></span>
<span class="line" id="L1188">        <span class="tok-kw">try</span> list.append(a, <span class="tok-number">1</span>);</span>
<span class="line" id="L1189">        <span class="tok-kw">try</span> list.append(a, <span class="tok-number">2</span>);</span>
<span class="line" id="L1190">        <span class="tok-kw">try</span> list.append(a, <span class="tok-number">3</span>);</span>
<span class="line" id="L1191">        <span class="tok-kw">try</span> list.insert(a, <span class="tok-number">0</span>, <span class="tok-number">5</span>);</span>
<span class="line" id="L1192">        <span class="tok-kw">try</span> testing.expect(list.items[<span class="tok-number">0</span>] == <span class="tok-number">5</span>);</span>
<span class="line" id="L1193">        <span class="tok-kw">try</span> testing.expect(list.items[<span class="tok-number">1</span>] == <span class="tok-number">1</span>);</span>
<span class="line" id="L1194">        <span class="tok-kw">try</span> testing.expect(list.items[<span class="tok-number">2</span>] == <span class="tok-number">2</span>);</span>
<span class="line" id="L1195">        <span class="tok-kw">try</span> testing.expect(list.items[<span class="tok-number">3</span>] == <span class="tok-number">3</span>);</span>
<span class="line" id="L1196">    }</span>
<span class="line" id="L1197">}</span>
<span class="line" id="L1198"></span>
<span class="line" id="L1199"><span class="tok-kw">test</span> <span class="tok-str">&quot;std.ArrayList/ArrayListUnmanaged.insertSlice&quot;</span> {</span>
<span class="line" id="L1200">    <span class="tok-kw">const</span> a = testing.allocator;</span>
<span class="line" id="L1201">    {</span>
<span class="line" id="L1202">        <span class="tok-kw">var</span> list = ArrayList(<span class="tok-type">i32</span>).init(a);</span>
<span class="line" id="L1203">        <span class="tok-kw">defer</span> list.deinit();</span>
<span class="line" id="L1204"></span>
<span class="line" id="L1205">        <span class="tok-kw">try</span> list.append(<span class="tok-number">1</span>);</span>
<span class="line" id="L1206">        <span class="tok-kw">try</span> list.append(<span class="tok-number">2</span>);</span>
<span class="line" id="L1207">        <span class="tok-kw">try</span> list.append(<span class="tok-number">3</span>);</span>
<span class="line" id="L1208">        <span class="tok-kw">try</span> list.append(<span class="tok-number">4</span>);</span>
<span class="line" id="L1209">        <span class="tok-kw">try</span> list.insertSlice(<span class="tok-number">1</span>, &amp;[_]<span class="tok-type">i32</span>{ <span class="tok-number">9</span>, <span class="tok-number">8</span> });</span>
<span class="line" id="L1210">        <span class="tok-kw">try</span> testing.expect(list.items[<span class="tok-number">0</span>] == <span class="tok-number">1</span>);</span>
<span class="line" id="L1211">        <span class="tok-kw">try</span> testing.expect(list.items[<span class="tok-number">1</span>] == <span class="tok-number">9</span>);</span>
<span class="line" id="L1212">        <span class="tok-kw">try</span> testing.expect(list.items[<span class="tok-number">2</span>] == <span class="tok-number">8</span>);</span>
<span class="line" id="L1213">        <span class="tok-kw">try</span> testing.expect(list.items[<span class="tok-number">3</span>] == <span class="tok-number">2</span>);</span>
<span class="line" id="L1214">        <span class="tok-kw">try</span> testing.expect(list.items[<span class="tok-number">4</span>] == <span class="tok-number">3</span>);</span>
<span class="line" id="L1215">        <span class="tok-kw">try</span> testing.expect(list.items[<span class="tok-number">5</span>] == <span class="tok-number">4</span>);</span>
<span class="line" id="L1216"></span>
<span class="line" id="L1217">        <span class="tok-kw">const</span> items = [_]<span class="tok-type">i32</span>{<span class="tok-number">1</span>};</span>
<span class="line" id="L1218">        <span class="tok-kw">try</span> list.insertSlice(<span class="tok-number">0</span>, items[<span class="tok-number">0</span>..<span class="tok-number">0</span>]);</span>
<span class="line" id="L1219">        <span class="tok-kw">try</span> testing.expect(list.items.len == <span class="tok-number">6</span>);</span>
<span class="line" id="L1220">        <span class="tok-kw">try</span> testing.expect(list.items[<span class="tok-number">0</span>] == <span class="tok-number">1</span>);</span>
<span class="line" id="L1221">    }</span>
<span class="line" id="L1222">    {</span>
<span class="line" id="L1223">        <span class="tok-kw">var</span> list = ArrayListUnmanaged(<span class="tok-type">i32</span>){};</span>
<span class="line" id="L1224">        <span class="tok-kw">defer</span> list.deinit(a);</span>
<span class="line" id="L1225"></span>
<span class="line" id="L1226">        <span class="tok-kw">try</span> list.append(a, <span class="tok-number">1</span>);</span>
<span class="line" id="L1227">        <span class="tok-kw">try</span> list.append(a, <span class="tok-number">2</span>);</span>
<span class="line" id="L1228">        <span class="tok-kw">try</span> list.append(a, <span class="tok-number">3</span>);</span>
<span class="line" id="L1229">        <span class="tok-kw">try</span> list.append(a, <span class="tok-number">4</span>);</span>
<span class="line" id="L1230">        <span class="tok-kw">try</span> list.insertSlice(a, <span class="tok-number">1</span>, &amp;[_]<span class="tok-type">i32</span>{ <span class="tok-number">9</span>, <span class="tok-number">8</span> });</span>
<span class="line" id="L1231">        <span class="tok-kw">try</span> testing.expect(list.items[<span class="tok-number">0</span>] == <span class="tok-number">1</span>);</span>
<span class="line" id="L1232">        <span class="tok-kw">try</span> testing.expect(list.items[<span class="tok-number">1</span>] == <span class="tok-number">9</span>);</span>
<span class="line" id="L1233">        <span class="tok-kw">try</span> testing.expect(list.items[<span class="tok-number">2</span>] == <span class="tok-number">8</span>);</span>
<span class="line" id="L1234">        <span class="tok-kw">try</span> testing.expect(list.items[<span class="tok-number">3</span>] == <span class="tok-number">2</span>);</span>
<span class="line" id="L1235">        <span class="tok-kw">try</span> testing.expect(list.items[<span class="tok-number">4</span>] == <span class="tok-number">3</span>);</span>
<span class="line" id="L1236">        <span class="tok-kw">try</span> testing.expect(list.items[<span class="tok-number">5</span>] == <span class="tok-number">4</span>);</span>
<span class="line" id="L1237"></span>
<span class="line" id="L1238">        <span class="tok-kw">const</span> items = [_]<span class="tok-type">i32</span>{<span class="tok-number">1</span>};</span>
<span class="line" id="L1239">        <span class="tok-kw">try</span> list.insertSlice(a, <span class="tok-number">0</span>, items[<span class="tok-number">0</span>..<span class="tok-number">0</span>]);</span>
<span class="line" id="L1240">        <span class="tok-kw">try</span> testing.expect(list.items.len == <span class="tok-number">6</span>);</span>
<span class="line" id="L1241">        <span class="tok-kw">try</span> testing.expect(list.items[<span class="tok-number">0</span>] == <span class="tok-number">1</span>);</span>
<span class="line" id="L1242">    }</span>
<span class="line" id="L1243">}</span>
<span class="line" id="L1244"></span>
<span class="line" id="L1245"><span class="tok-kw">test</span> <span class="tok-str">&quot;std.ArrayList/ArrayListUnmanaged.replaceRange&quot;</span> {</span>
<span class="line" id="L1246">    <span class="tok-kw">var</span> arena = std.heap.ArenaAllocator.init(testing.allocator);</span>
<span class="line" id="L1247">    <span class="tok-kw">defer</span> arena.deinit();</span>
<span class="line" id="L1248">    <span class="tok-kw">const</span> a = arena.allocator();</span>
<span class="line" id="L1249"></span>
<span class="line" id="L1250">    <span class="tok-kw">const</span> init = [_]<span class="tok-type">i32</span>{ <span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">4</span>, <span class="tok-number">5</span> };</span>
<span class="line" id="L1251">    <span class="tok-kw">const</span> new = [_]<span class="tok-type">i32</span>{ <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span> };</span>
<span class="line" id="L1252"></span>
<span class="line" id="L1253">    <span class="tok-kw">const</span> result_zero = [_]<span class="tok-type">i32</span>{ <span class="tok-number">1</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">4</span>, <span class="tok-number">5</span> };</span>
<span class="line" id="L1254">    <span class="tok-kw">const</span> result_eq = [_]<span class="tok-type">i32</span>{ <span class="tok-number">1</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">5</span> };</span>
<span class="line" id="L1255">    <span class="tok-kw">const</span> result_le = [_]<span class="tok-type">i32</span>{ <span class="tok-number">1</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">4</span>, <span class="tok-number">5</span> };</span>
<span class="line" id="L1256">    <span class="tok-kw">const</span> result_gt = [_]<span class="tok-type">i32</span>{ <span class="tok-number">1</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span> };</span>
<span class="line" id="L1257"></span>
<span class="line" id="L1258">    {</span>
<span class="line" id="L1259">        <span class="tok-kw">var</span> list_zero = ArrayList(<span class="tok-type">i32</span>).init(a);</span>
<span class="line" id="L1260">        <span class="tok-kw">var</span> list_eq = ArrayList(<span class="tok-type">i32</span>).init(a);</span>
<span class="line" id="L1261">        <span class="tok-kw">var</span> list_lt = ArrayList(<span class="tok-type">i32</span>).init(a);</span>
<span class="line" id="L1262">        <span class="tok-kw">var</span> list_gt = ArrayList(<span class="tok-type">i32</span>).init(a);</span>
<span class="line" id="L1263"></span>
<span class="line" id="L1264">        <span class="tok-kw">try</span> list_zero.appendSlice(&amp;init);</span>
<span class="line" id="L1265">        <span class="tok-kw">try</span> list_eq.appendSlice(&amp;init);</span>
<span class="line" id="L1266">        <span class="tok-kw">try</span> list_lt.appendSlice(&amp;init);</span>
<span class="line" id="L1267">        <span class="tok-kw">try</span> list_gt.appendSlice(&amp;init);</span>
<span class="line" id="L1268"></span>
<span class="line" id="L1269">        <span class="tok-kw">try</span> list_zero.replaceRange(<span class="tok-number">1</span>, <span class="tok-number">0</span>, &amp;new);</span>
<span class="line" id="L1270">        <span class="tok-kw">try</span> list_eq.replaceRange(<span class="tok-number">1</span>, <span class="tok-number">3</span>, &amp;new);</span>
<span class="line" id="L1271">        <span class="tok-kw">try</span> list_lt.replaceRange(<span class="tok-number">1</span>, <span class="tok-number">2</span>, &amp;new);</span>
<span class="line" id="L1272"></span>
<span class="line" id="L1273">        <span class="tok-comment">// after_range &gt; new_items.len in function body</span>
</span>
<span class="line" id="L1274">        <span class="tok-kw">try</span> testing.expect(<span class="tok-number">1</span> + <span class="tok-number">4</span> &gt; new.len);</span>
<span class="line" id="L1275">        <span class="tok-kw">try</span> list_gt.replaceRange(<span class="tok-number">1</span>, <span class="tok-number">4</span>, &amp;new);</span>
<span class="line" id="L1276"></span>
<span class="line" id="L1277">        <span class="tok-kw">try</span> testing.expectEqualSlices(<span class="tok-type">i32</span>, list_zero.items, &amp;result_zero);</span>
<span class="line" id="L1278">        <span class="tok-kw">try</span> testing.expectEqualSlices(<span class="tok-type">i32</span>, list_eq.items, &amp;result_eq);</span>
<span class="line" id="L1279">        <span class="tok-kw">try</span> testing.expectEqualSlices(<span class="tok-type">i32</span>, list_lt.items, &amp;result_le);</span>
<span class="line" id="L1280">        <span class="tok-kw">try</span> testing.expectEqualSlices(<span class="tok-type">i32</span>, list_gt.items, &amp;result_gt);</span>
<span class="line" id="L1281">    }</span>
<span class="line" id="L1282">    {</span>
<span class="line" id="L1283">        <span class="tok-kw">var</span> list_zero = ArrayListUnmanaged(<span class="tok-type">i32</span>){};</span>
<span class="line" id="L1284">        <span class="tok-kw">var</span> list_eq = ArrayListUnmanaged(<span class="tok-type">i32</span>){};</span>
<span class="line" id="L1285">        <span class="tok-kw">var</span> list_lt = ArrayListUnmanaged(<span class="tok-type">i32</span>){};</span>
<span class="line" id="L1286">        <span class="tok-kw">var</span> list_gt = ArrayListUnmanaged(<span class="tok-type">i32</span>){};</span>
<span class="line" id="L1287"></span>
<span class="line" id="L1288">        <span class="tok-kw">try</span> list_zero.appendSlice(a, &amp;init);</span>
<span class="line" id="L1289">        <span class="tok-kw">try</span> list_eq.appendSlice(a, &amp;init);</span>
<span class="line" id="L1290">        <span class="tok-kw">try</span> list_lt.appendSlice(a, &amp;init);</span>
<span class="line" id="L1291">        <span class="tok-kw">try</span> list_gt.appendSlice(a, &amp;init);</span>
<span class="line" id="L1292"></span>
<span class="line" id="L1293">        <span class="tok-kw">try</span> list_zero.replaceRange(a, <span class="tok-number">1</span>, <span class="tok-number">0</span>, &amp;new);</span>
<span class="line" id="L1294">        <span class="tok-kw">try</span> list_eq.replaceRange(a, <span class="tok-number">1</span>, <span class="tok-number">3</span>, &amp;new);</span>
<span class="line" id="L1295">        <span class="tok-kw">try</span> list_lt.replaceRange(a, <span class="tok-number">1</span>, <span class="tok-number">2</span>, &amp;new);</span>
<span class="line" id="L1296"></span>
<span class="line" id="L1297">        <span class="tok-comment">// after_range &gt; new_items.len in function body</span>
</span>
<span class="line" id="L1298">        <span class="tok-kw">try</span> testing.expect(<span class="tok-number">1</span> + <span class="tok-number">4</span> &gt; new.len);</span>
<span class="line" id="L1299">        <span class="tok-kw">try</span> list_gt.replaceRange(a, <span class="tok-number">1</span>, <span class="tok-number">4</span>, &amp;new);</span>
<span class="line" id="L1300"></span>
<span class="line" id="L1301">        <span class="tok-kw">try</span> testing.expectEqualSlices(<span class="tok-type">i32</span>, list_zero.items, &amp;result_zero);</span>
<span class="line" id="L1302">        <span class="tok-kw">try</span> testing.expectEqualSlices(<span class="tok-type">i32</span>, list_eq.items, &amp;result_eq);</span>
<span class="line" id="L1303">        <span class="tok-kw">try</span> testing.expectEqualSlices(<span class="tok-type">i32</span>, list_lt.items, &amp;result_le);</span>
<span class="line" id="L1304">        <span class="tok-kw">try</span> testing.expectEqualSlices(<span class="tok-type">i32</span>, list_gt.items, &amp;result_gt);</span>
<span class="line" id="L1305">    }</span>
<span class="line" id="L1306">}</span>
<span class="line" id="L1307"></span>
<span class="line" id="L1308"><span class="tok-kw">const</span> Item = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L1309">    integer: <span class="tok-type">i32</span>,</span>
<span class="line" id="L1310">    sub_items: ArrayList(Item),</span>
<span class="line" id="L1311">};</span>
<span class="line" id="L1312"></span>
<span class="line" id="L1313"><span class="tok-kw">const</span> ItemUnmanaged = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L1314">    integer: <span class="tok-type">i32</span>,</span>
<span class="line" id="L1315">    sub_items: ArrayListUnmanaged(ItemUnmanaged),</span>
<span class="line" id="L1316">};</span>
<span class="line" id="L1317"></span>
<span class="line" id="L1318"><span class="tok-kw">test</span> <span class="tok-str">&quot;std.ArrayList/ArrayListUnmanaged: ArrayList(T) of struct T&quot;</span> {</span>
<span class="line" id="L1319">    <span class="tok-kw">const</span> a = std.testing.allocator;</span>
<span class="line" id="L1320">    {</span>
<span class="line" id="L1321">        <span class="tok-kw">var</span> root = Item{ .integer = <span class="tok-number">1</span>, .sub_items = ArrayList(Item).init(a) };</span>
<span class="line" id="L1322">        <span class="tok-kw">defer</span> root.sub_items.deinit();</span>
<span class="line" id="L1323">        <span class="tok-kw">try</span> root.sub_items.append(Item{ .integer = <span class="tok-number">42</span>, .sub_items = ArrayList(Item).init(a) });</span>
<span class="line" id="L1324">        <span class="tok-kw">try</span> testing.expect(root.sub_items.items[<span class="tok-number">0</span>].integer == <span class="tok-number">42</span>);</span>
<span class="line" id="L1325">    }</span>
<span class="line" id="L1326">    {</span>
<span class="line" id="L1327">        <span class="tok-kw">var</span> root = ItemUnmanaged{ .integer = <span class="tok-number">1</span>, .sub_items = ArrayListUnmanaged(ItemUnmanaged){} };</span>
<span class="line" id="L1328">        <span class="tok-kw">defer</span> root.sub_items.deinit(a);</span>
<span class="line" id="L1329">        <span class="tok-kw">try</span> root.sub_items.append(a, ItemUnmanaged{ .integer = <span class="tok-number">42</span>, .sub_items = ArrayListUnmanaged(ItemUnmanaged){} });</span>
<span class="line" id="L1330">        <span class="tok-kw">try</span> testing.expect(root.sub_items.items[<span class="tok-number">0</span>].integer == <span class="tok-number">42</span>);</span>
<span class="line" id="L1331">    }</span>
<span class="line" id="L1332">}</span>
<span class="line" id="L1333"></span>
<span class="line" id="L1334"><span class="tok-kw">test</span> <span class="tok-str">&quot;std.ArrayList(u8)/ArrayListAligned implements writer&quot;</span> {</span>
<span class="line" id="L1335">    <span class="tok-kw">const</span> a = testing.allocator;</span>
<span class="line" id="L1336"></span>
<span class="line" id="L1337">    {</span>
<span class="line" id="L1338">        <span class="tok-kw">var</span> buffer = ArrayList(<span class="tok-type">u8</span>).init(a);</span>
<span class="line" id="L1339">        <span class="tok-kw">defer</span> buffer.deinit();</span>
<span class="line" id="L1340"></span>
<span class="line" id="L1341">        <span class="tok-kw">const</span> x: <span class="tok-type">i32</span> = <span class="tok-number">42</span>;</span>
<span class="line" id="L1342">        <span class="tok-kw">const</span> y: <span class="tok-type">i32</span> = <span class="tok-number">1234</span>;</span>
<span class="line" id="L1343">        <span class="tok-kw">try</span> buffer.writer().print(<span class="tok-str">&quot;x: {}\ny: {}\n&quot;</span>, .{ x, y });</span>
<span class="line" id="L1344"></span>
<span class="line" id="L1345">        <span class="tok-kw">try</span> testing.expectEqualSlices(<span class="tok-type">u8</span>, <span class="tok-str">&quot;x: 42\ny: 1234\n&quot;</span>, buffer.items);</span>
<span class="line" id="L1346">    }</span>
<span class="line" id="L1347">    {</span>
<span class="line" id="L1348">        <span class="tok-kw">var</span> list = ArrayListAligned(<span class="tok-type">u8</span>, <span class="tok-number">2</span>).init(a);</span>
<span class="line" id="L1349">        <span class="tok-kw">defer</span> list.deinit();</span>
<span class="line" id="L1350"></span>
<span class="line" id="L1351">        <span class="tok-kw">const</span> writer = list.writer();</span>
<span class="line" id="L1352">        <span class="tok-kw">try</span> writer.writeAll(<span class="tok-str">&quot;a&quot;</span>);</span>
<span class="line" id="L1353">        <span class="tok-kw">try</span> writer.writeAll(<span class="tok-str">&quot;bc&quot;</span>);</span>
<span class="line" id="L1354">        <span class="tok-kw">try</span> writer.writeAll(<span class="tok-str">&quot;d&quot;</span>);</span>
<span class="line" id="L1355">        <span class="tok-kw">try</span> writer.writeAll(<span class="tok-str">&quot;efg&quot;</span>);</span>
<span class="line" id="L1356"></span>
<span class="line" id="L1357">        <span class="tok-kw">try</span> testing.expectEqualSlices(<span class="tok-type">u8</span>, list.items, <span class="tok-str">&quot;abcdefg&quot;</span>);</span>
<span class="line" id="L1358">    }</span>
<span class="line" id="L1359">}</span>
<span class="line" id="L1360"></span>
<span class="line" id="L1361"><span class="tok-kw">test</span> <span class="tok-str">&quot;std.ArrayListUnmanaged(u8) implements writer&quot;</span> {</span>
<span class="line" id="L1362">    <span class="tok-kw">const</span> a = testing.allocator;</span>
<span class="line" id="L1363"></span>
<span class="line" id="L1364">    {</span>
<span class="line" id="L1365">        <span class="tok-kw">var</span> buffer: ArrayListUnmanaged(<span class="tok-type">u8</span>) = .{};</span>
<span class="line" id="L1366">        <span class="tok-kw">defer</span> buffer.deinit(a);</span>
<span class="line" id="L1367"></span>
<span class="line" id="L1368">        <span class="tok-kw">const</span> x: <span class="tok-type">i32</span> = <span class="tok-number">42</span>;</span>
<span class="line" id="L1369">        <span class="tok-kw">const</span> y: <span class="tok-type">i32</span> = <span class="tok-number">1234</span>;</span>
<span class="line" id="L1370">        <span class="tok-kw">try</span> buffer.writer(a).print(<span class="tok-str">&quot;x: {}\ny: {}\n&quot;</span>, .{ x, y });</span>
<span class="line" id="L1371"></span>
<span class="line" id="L1372">        <span class="tok-kw">try</span> testing.expectEqualSlices(<span class="tok-type">u8</span>, <span class="tok-str">&quot;x: 42\ny: 1234\n&quot;</span>, buffer.items);</span>
<span class="line" id="L1373">    }</span>
<span class="line" id="L1374">    {</span>
<span class="line" id="L1375">        <span class="tok-kw">var</span> list: ArrayListAlignedUnmanaged(<span class="tok-type">u8</span>, <span class="tok-number">2</span>) = .{};</span>
<span class="line" id="L1376">        <span class="tok-kw">defer</span> list.deinit(a);</span>
<span class="line" id="L1377"></span>
<span class="line" id="L1378">        <span class="tok-kw">const</span> writer = list.writer(a);</span>
<span class="line" id="L1379">        <span class="tok-kw">try</span> writer.writeAll(<span class="tok-str">&quot;a&quot;</span>);</span>
<span class="line" id="L1380">        <span class="tok-kw">try</span> writer.writeAll(<span class="tok-str">&quot;bc&quot;</span>);</span>
<span class="line" id="L1381">        <span class="tok-kw">try</span> writer.writeAll(<span class="tok-str">&quot;d&quot;</span>);</span>
<span class="line" id="L1382">        <span class="tok-kw">try</span> writer.writeAll(<span class="tok-str">&quot;efg&quot;</span>);</span>
<span class="line" id="L1383"></span>
<span class="line" id="L1384">        <span class="tok-kw">try</span> testing.expectEqualSlices(<span class="tok-type">u8</span>, list.items, <span class="tok-str">&quot;abcdefg&quot;</span>);</span>
<span class="line" id="L1385">    }</span>
<span class="line" id="L1386">}</span>
<span class="line" id="L1387"></span>
<span class="line" id="L1388"><span class="tok-kw">test</span> <span class="tok-str">&quot;std.ArrayList/ArrayListUnmanaged.shrink still sets length on error.OutOfMemory&quot;</span> {</span>
<span class="line" id="L1389">    <span class="tok-comment">// use an arena allocator to make sure realloc returns error.OutOfMemory</span>
</span>
<span class="line" id="L1390">    <span class="tok-kw">var</span> arena = std.heap.ArenaAllocator.init(testing.allocator);</span>
<span class="line" id="L1391">    <span class="tok-kw">defer</span> arena.deinit();</span>
<span class="line" id="L1392">    <span class="tok-kw">const</span> a = arena.allocator();</span>
<span class="line" id="L1393"></span>
<span class="line" id="L1394">    {</span>
<span class="line" id="L1395">        <span class="tok-kw">var</span> list = ArrayList(<span class="tok-type">i32</span>).init(a);</span>
<span class="line" id="L1396"></span>
<span class="line" id="L1397">        <span class="tok-kw">try</span> list.append(<span class="tok-number">1</span>);</span>
<span class="line" id="L1398">        <span class="tok-kw">try</span> list.append(<span class="tok-number">2</span>);</span>
<span class="line" id="L1399">        <span class="tok-kw">try</span> list.append(<span class="tok-number">3</span>);</span>
<span class="line" id="L1400"></span>
<span class="line" id="L1401">        list.shrinkAndFree(<span class="tok-number">1</span>);</span>
<span class="line" id="L1402">        <span class="tok-kw">try</span> testing.expect(list.items.len == <span class="tok-number">1</span>);</span>
<span class="line" id="L1403">    }</span>
<span class="line" id="L1404">    {</span>
<span class="line" id="L1405">        <span class="tok-kw">var</span> list = ArrayListUnmanaged(<span class="tok-type">i32</span>){};</span>
<span class="line" id="L1406"></span>
<span class="line" id="L1407">        <span class="tok-kw">try</span> list.append(a, <span class="tok-number">1</span>);</span>
<span class="line" id="L1408">        <span class="tok-kw">try</span> list.append(a, <span class="tok-number">2</span>);</span>
<span class="line" id="L1409">        <span class="tok-kw">try</span> list.append(a, <span class="tok-number">3</span>);</span>
<span class="line" id="L1410"></span>
<span class="line" id="L1411">        list.shrinkAndFree(a, <span class="tok-number">1</span>);</span>
<span class="line" id="L1412">        <span class="tok-kw">try</span> testing.expect(list.items.len == <span class="tok-number">1</span>);</span>
<span class="line" id="L1413">    }</span>
<span class="line" id="L1414">}</span>
<span class="line" id="L1415"></span>
<span class="line" id="L1416"><span class="tok-kw">test</span> <span class="tok-str">&quot;std.ArrayList/ArrayListUnmanaged.addManyAsArray&quot;</span> {</span>
<span class="line" id="L1417">    <span class="tok-kw">const</span> a = std.testing.allocator;</span>
<span class="line" id="L1418">    {</span>
<span class="line" id="L1419">        <span class="tok-kw">var</span> list = ArrayList(<span class="tok-type">u8</span>).init(a);</span>
<span class="line" id="L1420">        <span class="tok-kw">defer</span> list.deinit();</span>
<span class="line" id="L1421"></span>
<span class="line" id="L1422">        (<span class="tok-kw">try</span> list.addManyAsArray(<span class="tok-number">4</span>)).* = <span class="tok-str">&quot;aoeu&quot;</span>.*;</span>
<span class="line" id="L1423">        <span class="tok-kw">try</span> list.ensureTotalCapacity(<span class="tok-number">8</span>);</span>
<span class="line" id="L1424">        list.addManyAsArrayAssumeCapacity(<span class="tok-number">4</span>).* = <span class="tok-str">&quot;asdf&quot;</span>.*;</span>
<span class="line" id="L1425"></span>
<span class="line" id="L1426">        <span class="tok-kw">try</span> testing.expectEqualSlices(<span class="tok-type">u8</span>, list.items, <span class="tok-str">&quot;aoeuasdf&quot;</span>);</span>
<span class="line" id="L1427">    }</span>
<span class="line" id="L1428">    {</span>
<span class="line" id="L1429">        <span class="tok-kw">var</span> list = ArrayListUnmanaged(<span class="tok-type">u8</span>){};</span>
<span class="line" id="L1430">        <span class="tok-kw">defer</span> list.deinit(a);</span>
<span class="line" id="L1431"></span>
<span class="line" id="L1432">        (<span class="tok-kw">try</span> list.addManyAsArray(a, <span class="tok-number">4</span>)).* = <span class="tok-str">&quot;aoeu&quot;</span>.*;</span>
<span class="line" id="L1433">        <span class="tok-kw">try</span> list.ensureTotalCapacity(a, <span class="tok-number">8</span>);</span>
<span class="line" id="L1434">        list.addManyAsArrayAssumeCapacity(<span class="tok-number">4</span>).* = <span class="tok-str">&quot;asdf&quot;</span>.*;</span>
<span class="line" id="L1435"></span>
<span class="line" id="L1436">        <span class="tok-kw">try</span> testing.expectEqualSlices(<span class="tok-type">u8</span>, list.items, <span class="tok-str">&quot;aoeuasdf&quot;</span>);</span>
<span class="line" id="L1437">    }</span>
<span class="line" id="L1438">}</span>
<span class="line" id="L1439"></span>
<span class="line" id="L1440"><span class="tok-kw">test</span> <span class="tok-str">&quot;std.ArrayList/ArrayListUnmanaged.toOwnedSliceSentinel&quot;</span> {</span>
<span class="line" id="L1441">    <span class="tok-kw">const</span> a = testing.allocator;</span>
<span class="line" id="L1442">    {</span>
<span class="line" id="L1443">        <span class="tok-kw">var</span> list = ArrayList(<span class="tok-type">u8</span>).init(a);</span>
<span class="line" id="L1444">        <span class="tok-kw">defer</span> list.deinit();</span>
<span class="line" id="L1445"></span>
<span class="line" id="L1446">        <span class="tok-kw">try</span> list.appendSlice(<span class="tok-str">&quot;foobar&quot;</span>);</span>
<span class="line" id="L1447"></span>
<span class="line" id="L1448">        <span class="tok-kw">const</span> result = <span class="tok-kw">try</span> list.toOwnedSliceSentinel(<span class="tok-number">0</span>);</span>
<span class="line" id="L1449">        <span class="tok-kw">defer</span> a.free(result);</span>
<span class="line" id="L1450">        <span class="tok-kw">try</span> testing.expectEqualStrings(result, mem.sliceTo(result.ptr, <span class="tok-number">0</span>));</span>
<span class="line" id="L1451">    }</span>
<span class="line" id="L1452">    {</span>
<span class="line" id="L1453">        <span class="tok-kw">var</span> list = ArrayListUnmanaged(<span class="tok-type">u8</span>){};</span>
<span class="line" id="L1454">        <span class="tok-kw">defer</span> list.deinit(a);</span>
<span class="line" id="L1455"></span>
<span class="line" id="L1456">        <span class="tok-kw">try</span> list.appendSlice(a, <span class="tok-str">&quot;foobar&quot;</span>);</span>
<span class="line" id="L1457"></span>
<span class="line" id="L1458">        <span class="tok-kw">const</span> result = <span class="tok-kw">try</span> list.toOwnedSliceSentinel(a, <span class="tok-number">0</span>);</span>
<span class="line" id="L1459">        <span class="tok-kw">defer</span> a.free(result);</span>
<span class="line" id="L1460">        <span class="tok-kw">try</span> testing.expectEqualStrings(result, mem.sliceTo(result.ptr, <span class="tok-number">0</span>));</span>
<span class="line" id="L1461">    }</span>
<span class="line" id="L1462">}</span>
<span class="line" id="L1463"></span>
<span class="line" id="L1464"><span class="tok-kw">test</span> <span class="tok-str">&quot;ArrayListAligned/ArrayListAlignedUnmanaged accepts unaligned slices&quot;</span> {</span>
<span class="line" id="L1465">    <span class="tok-kw">const</span> a = testing.allocator;</span>
<span class="line" id="L1466">    {</span>
<span class="line" id="L1467">        <span class="tok-kw">var</span> list = std.ArrayListAligned(<span class="tok-type">u8</span>, <span class="tok-number">8</span>).init(a);</span>
<span class="line" id="L1468">        <span class="tok-kw">defer</span> list.deinit();</span>
<span class="line" id="L1469"></span>
<span class="line" id="L1470">        <span class="tok-kw">try</span> list.appendSlice(&amp;.{ <span class="tok-number">0</span>, <span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">3</span> });</span>
<span class="line" id="L1471">        <span class="tok-kw">try</span> list.insertSlice(<span class="tok-number">2</span>, &amp;.{ <span class="tok-number">4</span>, <span class="tok-number">5</span>, <span class="tok-number">6</span>, <span class="tok-number">7</span> });</span>
<span class="line" id="L1472">        <span class="tok-kw">try</span> list.replaceRange(<span class="tok-number">1</span>, <span class="tok-number">3</span>, &amp;.{ <span class="tok-number">8</span>, <span class="tok-number">9</span> });</span>
<span class="line" id="L1473"></span>
<span class="line" id="L1474">        <span class="tok-kw">try</span> testing.expectEqualSlices(<span class="tok-type">u8</span>, list.items, &amp;.{ <span class="tok-number">0</span>, <span class="tok-number">8</span>, <span class="tok-number">9</span>, <span class="tok-number">6</span>, <span class="tok-number">7</span>, <span class="tok-number">2</span>, <span class="tok-number">3</span> });</span>
<span class="line" id="L1475">    }</span>
<span class="line" id="L1476">    {</span>
<span class="line" id="L1477">        <span class="tok-kw">var</span> list = std.ArrayListAlignedUnmanaged(<span class="tok-type">u8</span>, <span class="tok-number">8</span>){};</span>
<span class="line" id="L1478">        <span class="tok-kw">defer</span> list.deinit(a);</span>
<span class="line" id="L1479"></span>
<span class="line" id="L1480">        <span class="tok-kw">try</span> list.appendSlice(a, &amp;.{ <span class="tok-number">0</span>, <span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">3</span> });</span>
<span class="line" id="L1481">        <span class="tok-kw">try</span> list.insertSlice(a, <span class="tok-number">2</span>, &amp;.{ <span class="tok-number">4</span>, <span class="tok-number">5</span>, <span class="tok-number">6</span>, <span class="tok-number">7</span> });</span>
<span class="line" id="L1482">        <span class="tok-kw">try</span> list.replaceRange(a, <span class="tok-number">1</span>, <span class="tok-number">3</span>, &amp;.{ <span class="tok-number">8</span>, <span class="tok-number">9</span> });</span>
<span class="line" id="L1483"></span>
<span class="line" id="L1484">        <span class="tok-kw">try</span> testing.expectEqualSlices(<span class="tok-type">u8</span>, list.items, &amp;.{ <span class="tok-number">0</span>, <span class="tok-number">8</span>, <span class="tok-number">9</span>, <span class="tok-number">6</span>, <span class="tok-number">7</span>, <span class="tok-number">2</span>, <span class="tok-number">3</span> });</span>
<span class="line" id="L1485">    }</span>
<span class="line" id="L1486">}</span>
<span class="line" id="L1487"></span>
<span class="line" id="L1488"><span class="tok-kw">test</span> <span class="tok-str">&quot;std.ArrayList(u0)&quot;</span> {</span>
<span class="line" id="L1489">    <span class="tok-comment">// An ArrayList on zero-sized types should not need to allocate</span>
</span>
<span class="line" id="L1490">    <span class="tok-kw">var</span> failing_allocator = testing.FailingAllocator.init(testing.allocator, <span class="tok-number">0</span>);</span>
<span class="line" id="L1491">    <span class="tok-kw">const</span> a = failing_allocator.allocator();</span>
<span class="line" id="L1492"></span>
<span class="line" id="L1493">    <span class="tok-kw">var</span> list = ArrayList(<span class="tok-type">u0</span>).init(a);</span>
<span class="line" id="L1494">    <span class="tok-kw">defer</span> list.deinit();</span>
<span class="line" id="L1495"></span>
<span class="line" id="L1496">    <span class="tok-kw">try</span> list.append(<span class="tok-number">0</span>);</span>
<span class="line" id="L1497">    <span class="tok-kw">try</span> list.append(<span class="tok-number">0</span>);</span>
<span class="line" id="L1498">    <span class="tok-kw">try</span> list.append(<span class="tok-number">0</span>);</span>
<span class="line" id="L1499">    <span class="tok-kw">try</span> testing.expectEqual(list.items.len, <span class="tok-number">3</span>);</span>
<span class="line" id="L1500"></span>
<span class="line" id="L1501">    <span class="tok-kw">var</span> count: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L1502">    <span class="tok-kw">for</span> (list.items) |x| {</span>
<span class="line" id="L1503">        <span class="tok-kw">try</span> testing.expectEqual(x, <span class="tok-number">0</span>);</span>
<span class="line" id="L1504">        count += <span class="tok-number">1</span>;</span>
<span class="line" id="L1505">    }</span>
<span class="line" id="L1506">    <span class="tok-kw">try</span> testing.expectEqual(count, <span class="tok-number">3</span>);</span>
<span class="line" id="L1507">}</span>
<span class="line" id="L1508"></span>
</code></pre></body>
</html>