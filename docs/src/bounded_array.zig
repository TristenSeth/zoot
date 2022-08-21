<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">    <title>bounded_array.zig - source view</title>
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
<span class="line" id="L3"><span class="tok-kw">const</span> mem = std.mem;</span>
<span class="line" id="L4"><span class="tok-kw">const</span> testing = std.testing;</span>
<span class="line" id="L5"></span>
<span class="line" id="L6"><span class="tok-comment">/// A structure with an array and a length, that can be used as a slice.</span></span>
<span class="line" id="L7"><span class="tok-comment">///</span></span>
<span class="line" id="L8"><span class="tok-comment">/// Useful to pass around small arrays whose exact size is only known at</span></span>
<span class="line" id="L9"><span class="tok-comment">/// runtime, but whose maximum size is known at comptime, without requiring</span></span>
<span class="line" id="L10"><span class="tok-comment">/// an `Allocator`.</span></span>
<span class="line" id="L11"><span class="tok-comment">///</span></span>
<span class="line" id="L12"><span class="tok-comment">/// ```zig</span></span>
<span class="line" id="L13"><span class="tok-comment">/// var actual_size = 32;</span></span>
<span class="line" id="L14"><span class="tok-comment">/// var a = try BoundedArray(u8, 64).init(actual_size);</span></span>
<span class="line" id="L15"><span class="tok-comment">/// var slice = a.slice(); // a slice of the 64-byte array</span></span>
<span class="line" id="L16"><span class="tok-comment">/// var a_clone = a; // creates a copy - the structure doesn't use any internal pointers</span></span>
<span class="line" id="L17"><span class="tok-comment">/// ```</span></span>
<span class="line" id="L18"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">BoundedArray</span>(<span class="tok-kw">comptime</span> T: <span class="tok-type">type</span>, <span class="tok-kw">comptime</span> buffer_capacity: <span class="tok-type">usize</span>) <span class="tok-type">type</span> {</span>
<span class="line" id="L19">    <span class="tok-kw">return</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L20">        <span class="tok-kw">const</span> Self = <span class="tok-builtin">@This</span>();</span>
<span class="line" id="L21">        buffer: [buffer_capacity]T = <span class="tok-null">undefined</span>,</span>
<span class="line" id="L22">        len: <span class="tok-type">usize</span> = <span class="tok-number">0</span>,</span>
<span class="line" id="L23"></span>
<span class="line" id="L24">        <span class="tok-comment">/// Set the actual length of the slice.</span></span>
<span class="line" id="L25">        <span class="tok-comment">/// Returns error.Overflow if it exceeds the length of the backing array.</span></span>
<span class="line" id="L26">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">init</span>(len: <span class="tok-type">usize</span>) <span class="tok-kw">error</span>{Overflow}!Self {</span>
<span class="line" id="L27">            <span class="tok-kw">if</span> (len &gt; buffer_capacity) <span class="tok-kw">return</span> <span class="tok-kw">error</span>.Overflow;</span>
<span class="line" id="L28">            <span class="tok-kw">return</span> Self{ .len = len };</span>
<span class="line" id="L29">        }</span>
<span class="line" id="L30"></span>
<span class="line" id="L31">        <span class="tok-comment">/// View the internal array as a slice whose size was previously set.</span></span>
<span class="line" id="L32">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">slice</span>(self: <span class="tok-kw">anytype</span>) mem.Span(<span class="tok-builtin">@TypeOf</span>(&amp;self.buffer)) {</span>
<span class="line" id="L33">            <span class="tok-kw">return</span> self.buffer[<span class="tok-number">0</span>..self.len];</span>
<span class="line" id="L34">        }</span>
<span class="line" id="L35"></span>
<span class="line" id="L36">        <span class="tok-comment">/// View the internal array as a constant slice whose size was previously set.</span></span>
<span class="line" id="L37">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">constSlice</span>(self: *<span class="tok-kw">const</span> Self) []<span class="tok-kw">const</span> T {</span>
<span class="line" id="L38">            <span class="tok-kw">return</span> self.slice();</span>
<span class="line" id="L39">        }</span>
<span class="line" id="L40"></span>
<span class="line" id="L41">        <span class="tok-comment">/// Adjust the slice's length to `len`.</span></span>
<span class="line" id="L42">        <span class="tok-comment">/// Does not initialize added items if any.</span></span>
<span class="line" id="L43">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">resize</span>(self: *Self, len: <span class="tok-type">usize</span>) <span class="tok-kw">error</span>{Overflow}!<span class="tok-type">void</span> {</span>
<span class="line" id="L44">            <span class="tok-kw">if</span> (len &gt; buffer_capacity) <span class="tok-kw">return</span> <span class="tok-kw">error</span>.Overflow;</span>
<span class="line" id="L45">            self.len = len;</span>
<span class="line" id="L46">        }</span>
<span class="line" id="L47"></span>
<span class="line" id="L48">        <span class="tok-comment">/// Copy the content of an existing slice.</span></span>
<span class="line" id="L49">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">fromSlice</span>(m: []<span class="tok-kw">const</span> T) <span class="tok-kw">error</span>{Overflow}!Self {</span>
<span class="line" id="L50">            <span class="tok-kw">var</span> list = <span class="tok-kw">try</span> init(m.len);</span>
<span class="line" id="L51">            std.mem.copy(T, list.slice(), m);</span>
<span class="line" id="L52">            <span class="tok-kw">return</span> list;</span>
<span class="line" id="L53">        }</span>
<span class="line" id="L54"></span>
<span class="line" id="L55">        <span class="tok-comment">/// Return the element at index `i` of the slice.</span></span>
<span class="line" id="L56">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">get</span>(self: Self, i: <span class="tok-type">usize</span>) T {</span>
<span class="line" id="L57">            <span class="tok-kw">return</span> self.constSlice()[i];</span>
<span class="line" id="L58">        }</span>
<span class="line" id="L59"></span>
<span class="line" id="L60">        <span class="tok-comment">/// Set the value of the element at index `i` of the slice.</span></span>
<span class="line" id="L61">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">set</span>(self: *Self, i: <span class="tok-type">usize</span>, item: T) <span class="tok-type">void</span> {</span>
<span class="line" id="L62">            self.slice()[i] = item;</span>
<span class="line" id="L63">        }</span>
<span class="line" id="L64"></span>
<span class="line" id="L65">        <span class="tok-comment">/// Return the maximum length of a slice.</span></span>
<span class="line" id="L66">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">capacity</span>(self: Self) <span class="tok-type">usize</span> {</span>
<span class="line" id="L67">            <span class="tok-kw">return</span> self.buffer.len;</span>
<span class="line" id="L68">        }</span>
<span class="line" id="L69"></span>
<span class="line" id="L70">        <span class="tok-comment">/// Check that the slice can hold at least `additional_count` items.</span></span>
<span class="line" id="L71">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">ensureUnusedCapacity</span>(self: Self, additional_count: <span class="tok-type">usize</span>) <span class="tok-kw">error</span>{Overflow}!<span class="tok-type">void</span> {</span>
<span class="line" id="L72">            <span class="tok-kw">if</span> (self.len + additional_count &gt; buffer_capacity) {</span>
<span class="line" id="L73">                <span class="tok-kw">return</span> <span class="tok-kw">error</span>.Overflow;</span>
<span class="line" id="L74">            }</span>
<span class="line" id="L75">        }</span>
<span class="line" id="L76"></span>
<span class="line" id="L77">        <span class="tok-comment">/// Increase length by 1, returning a pointer to the new item.</span></span>
<span class="line" id="L78">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">addOne</span>(self: *Self) <span class="tok-kw">error</span>{Overflow}!*T {</span>
<span class="line" id="L79">            <span class="tok-kw">try</span> self.ensureUnusedCapacity(<span class="tok-number">1</span>);</span>
<span class="line" id="L80">            <span class="tok-kw">return</span> self.addOneAssumeCapacity();</span>
<span class="line" id="L81">        }</span>
<span class="line" id="L82"></span>
<span class="line" id="L83">        <span class="tok-comment">/// Increase length by 1, returning pointer to the new item.</span></span>
<span class="line" id="L84">        <span class="tok-comment">/// Asserts that there is space for the new item.</span></span>
<span class="line" id="L85">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">addOneAssumeCapacity</span>(self: *Self) *T {</span>
<span class="line" id="L86">            assert(self.len &lt; buffer_capacity);</span>
<span class="line" id="L87">            self.len += <span class="tok-number">1</span>;</span>
<span class="line" id="L88">            <span class="tok-kw">return</span> &amp;self.slice()[self.len - <span class="tok-number">1</span>];</span>
<span class="line" id="L89">        }</span>
<span class="line" id="L90"></span>
<span class="line" id="L91">        <span class="tok-comment">/// Resize the slice, adding `n` new elements, which have `undefined` values.</span></span>
<span class="line" id="L92">        <span class="tok-comment">/// The return value is a slice pointing to the uninitialized elements.</span></span>
<span class="line" id="L93">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">addManyAsArray</span>(self: *Self, <span class="tok-kw">comptime</span> n: <span class="tok-type">usize</span>) <span class="tok-kw">error</span>{Overflow}!*[n]T {</span>
<span class="line" id="L94">            <span class="tok-kw">const</span> prev_len = self.len;</span>
<span class="line" id="L95">            <span class="tok-kw">try</span> self.resize(self.len + n);</span>
<span class="line" id="L96">            <span class="tok-kw">return</span> self.slice()[prev_len..][<span class="tok-number">0</span>..n];</span>
<span class="line" id="L97">        }</span>
<span class="line" id="L98"></span>
<span class="line" id="L99">        <span class="tok-comment">/// Remove and return the last element from the slice.</span></span>
<span class="line" id="L100">        <span class="tok-comment">/// Asserts the slice has at least one item.</span></span>
<span class="line" id="L101">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">pop</span>(self: *Self) T {</span>
<span class="line" id="L102">            <span class="tok-kw">const</span> item = self.get(self.len - <span class="tok-number">1</span>);</span>
<span class="line" id="L103">            self.len -= <span class="tok-number">1</span>;</span>
<span class="line" id="L104">            <span class="tok-kw">return</span> item;</span>
<span class="line" id="L105">        }</span>
<span class="line" id="L106"></span>
<span class="line" id="L107">        <span class="tok-comment">/// Remove and return the last element from the slice, or</span></span>
<span class="line" id="L108">        <span class="tok-comment">/// return `null` if the slice is empty.</span></span>
<span class="line" id="L109">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">popOrNull</span>(self: *Self) ?T {</span>
<span class="line" id="L110">            <span class="tok-kw">return</span> <span class="tok-kw">if</span> (self.len == <span class="tok-number">0</span>) <span class="tok-null">null</span> <span class="tok-kw">else</span> self.pop();</span>
<span class="line" id="L111">        }</span>
<span class="line" id="L112"></span>
<span class="line" id="L113">        <span class="tok-comment">/// Return a slice of only the extra capacity after items.</span></span>
<span class="line" id="L114">        <span class="tok-comment">/// This can be useful for writing directly into it.</span></span>
<span class="line" id="L115">        <span class="tok-comment">/// Note that such an operation must be followed up with a</span></span>
<span class="line" id="L116">        <span class="tok-comment">/// call to `resize()`</span></span>
<span class="line" id="L117">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">unusedCapacitySlice</span>(self: *Self) []T {</span>
<span class="line" id="L118">            <span class="tok-kw">return</span> self.buffer[self.len..];</span>
<span class="line" id="L119">        }</span>
<span class="line" id="L120"></span>
<span class="line" id="L121">        <span class="tok-comment">/// Insert `item` at index `i` by moving `slice[n .. slice.len]` to make room.</span></span>
<span class="line" id="L122">        <span class="tok-comment">/// This operation is O(N).</span></span>
<span class="line" id="L123">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">insert</span>(</span>
<span class="line" id="L124">            self: *Self,</span>
<span class="line" id="L125">            i: <span class="tok-type">usize</span>,</span>
<span class="line" id="L126">            item: T,</span>
<span class="line" id="L127">        ) <span class="tok-kw">error</span>{Overflow}!<span class="tok-type">void</span> {</span>
<span class="line" id="L128">            <span class="tok-kw">if</span> (i &gt; self.len) {</span>
<span class="line" id="L129">                <span class="tok-kw">return</span> <span class="tok-kw">error</span>.Overflow;</span>
<span class="line" id="L130">            }</span>
<span class="line" id="L131">            _ = <span class="tok-kw">try</span> self.addOne();</span>
<span class="line" id="L132">            <span class="tok-kw">var</span> s = self.slice();</span>
<span class="line" id="L133">            mem.copyBackwards(T, s[i + <span class="tok-number">1</span> .. s.len], s[i .. s.len - <span class="tok-number">1</span>]);</span>
<span class="line" id="L134">            self.buffer[i] = item;</span>
<span class="line" id="L135">        }</span>
<span class="line" id="L136"></span>
<span class="line" id="L137">        <span class="tok-comment">/// Insert slice `items` at index `i` by moving `slice[i .. slice.len]` to make room.</span></span>
<span class="line" id="L138">        <span class="tok-comment">/// This operation is O(N).</span></span>
<span class="line" id="L139">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">insertSlice</span>(self: *Self, i: <span class="tok-type">usize</span>, items: []<span class="tok-kw">const</span> T) <span class="tok-kw">error</span>{Overflow}!<span class="tok-type">void</span> {</span>
<span class="line" id="L140">            <span class="tok-kw">try</span> self.ensureUnusedCapacity(items.len);</span>
<span class="line" id="L141">            self.len += items.len;</span>
<span class="line" id="L142">            mem.copyBackwards(T, self.slice()[i + items.len .. self.len], self.constSlice()[i .. self.len - items.len]);</span>
<span class="line" id="L143">            mem.copy(T, self.slice()[i .. i + items.len], items);</span>
<span class="line" id="L144">        }</span>
<span class="line" id="L145"></span>
<span class="line" id="L146">        <span class="tok-comment">/// Replace range of elements `slice[start..start+len]` with `new_items`.</span></span>
<span class="line" id="L147">        <span class="tok-comment">/// Grows slice if `len &lt; new_items.len`.</span></span>
<span class="line" id="L148">        <span class="tok-comment">/// Shrinks slice if `len &gt; new_items.len`.</span></span>
<span class="line" id="L149">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">replaceRange</span>(</span>
<span class="line" id="L150">            self: *Self,</span>
<span class="line" id="L151">            start: <span class="tok-type">usize</span>,</span>
<span class="line" id="L152">            len: <span class="tok-type">usize</span>,</span>
<span class="line" id="L153">            new_items: []<span class="tok-kw">const</span> T,</span>
<span class="line" id="L154">        ) <span class="tok-kw">error</span>{Overflow}!<span class="tok-type">void</span> {</span>
<span class="line" id="L155">            <span class="tok-kw">const</span> after_range = start + len;</span>
<span class="line" id="L156">            <span class="tok-kw">var</span> range = self.slice()[start..after_range];</span>
<span class="line" id="L157"></span>
<span class="line" id="L158">            <span class="tok-kw">if</span> (range.len == new_items.len) {</span>
<span class="line" id="L159">                mem.copy(T, range, new_items);</span>
<span class="line" id="L160">            } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (range.len &lt; new_items.len) {</span>
<span class="line" id="L161">                <span class="tok-kw">const</span> first = new_items[<span class="tok-number">0</span>..range.len];</span>
<span class="line" id="L162">                <span class="tok-kw">const</span> rest = new_items[range.len..];</span>
<span class="line" id="L163">                mem.copy(T, range, first);</span>
<span class="line" id="L164">                <span class="tok-kw">try</span> self.insertSlice(after_range, rest);</span>
<span class="line" id="L165">            } <span class="tok-kw">else</span> {</span>
<span class="line" id="L166">                mem.copy(T, range, new_items);</span>
<span class="line" id="L167">                <span class="tok-kw">const</span> after_subrange = start + new_items.len;</span>
<span class="line" id="L168">                <span class="tok-kw">for</span> (self.constSlice()[after_range..]) |item, i| {</span>
<span class="line" id="L169">                    self.slice()[after_subrange..][i] = item;</span>
<span class="line" id="L170">                }</span>
<span class="line" id="L171">                self.len -= len - new_items.len;</span>
<span class="line" id="L172">            }</span>
<span class="line" id="L173">        }</span>
<span class="line" id="L174"></span>
<span class="line" id="L175">        <span class="tok-comment">/// Extend the slice by 1 element.</span></span>
<span class="line" id="L176">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">append</span>(self: *Self, item: T) <span class="tok-kw">error</span>{Overflow}!<span class="tok-type">void</span> {</span>
<span class="line" id="L177">            <span class="tok-kw">const</span> new_item_ptr = <span class="tok-kw">try</span> self.addOne();</span>
<span class="line" id="L178">            new_item_ptr.* = item;</span>
<span class="line" id="L179">        }</span>
<span class="line" id="L180"></span>
<span class="line" id="L181">        <span class="tok-comment">/// Extend the slice by 1 element, asserting the capacity is already</span></span>
<span class="line" id="L182">        <span class="tok-comment">/// enough to store the new item.</span></span>
<span class="line" id="L183">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">appendAssumeCapacity</span>(self: *Self, item: T) <span class="tok-type">void</span> {</span>
<span class="line" id="L184">            <span class="tok-kw">const</span> new_item_ptr = self.addOneAssumeCapacity();</span>
<span class="line" id="L185">            new_item_ptr.* = item;</span>
<span class="line" id="L186">        }</span>
<span class="line" id="L187"></span>
<span class="line" id="L188">        <span class="tok-comment">/// Remove the element at index `i`, shift elements after index</span></span>
<span class="line" id="L189">        <span class="tok-comment">/// `i` forward, and return the removed element.</span></span>
<span class="line" id="L190">        <span class="tok-comment">/// Asserts the slice has at least one item.</span></span>
<span class="line" id="L191">        <span class="tok-comment">/// This operation is O(N).</span></span>
<span class="line" id="L192">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">orderedRemove</span>(self: *Self, i: <span class="tok-type">usize</span>) T {</span>
<span class="line" id="L193">            <span class="tok-kw">const</span> newlen = self.len - <span class="tok-number">1</span>;</span>
<span class="line" id="L194">            <span class="tok-kw">if</span> (newlen == i) <span class="tok-kw">return</span> self.pop();</span>
<span class="line" id="L195">            <span class="tok-kw">const</span> old_item = self.get(i);</span>
<span class="line" id="L196">            <span class="tok-kw">for</span> (self.slice()[i..newlen]) |*b, j| b.* = self.get(i + <span class="tok-number">1</span> + j);</span>
<span class="line" id="L197">            self.set(newlen, <span class="tok-null">undefined</span>);</span>
<span class="line" id="L198">            self.len = newlen;</span>
<span class="line" id="L199">            <span class="tok-kw">return</span> old_item;</span>
<span class="line" id="L200">        }</span>
<span class="line" id="L201"></span>
<span class="line" id="L202">        <span class="tok-comment">/// Remove the element at the specified index and return it.</span></span>
<span class="line" id="L203">        <span class="tok-comment">/// The empty slot is filled from the end of the slice.</span></span>
<span class="line" id="L204">        <span class="tok-comment">/// This operation is O(1).</span></span>
<span class="line" id="L205">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">swapRemove</span>(self: *Self, i: <span class="tok-type">usize</span>) T {</span>
<span class="line" id="L206">            <span class="tok-kw">if</span> (self.len - <span class="tok-number">1</span> == i) <span class="tok-kw">return</span> self.pop();</span>
<span class="line" id="L207">            <span class="tok-kw">const</span> old_item = self.get(i);</span>
<span class="line" id="L208">            self.set(i, self.pop());</span>
<span class="line" id="L209">            <span class="tok-kw">return</span> old_item;</span>
<span class="line" id="L210">        }</span>
<span class="line" id="L211"></span>
<span class="line" id="L212">        <span class="tok-comment">/// Append the slice of items to the slice.</span></span>
<span class="line" id="L213">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">appendSlice</span>(self: *Self, items: []<span class="tok-kw">const</span> T) <span class="tok-kw">error</span>{Overflow}!<span class="tok-type">void</span> {</span>
<span class="line" id="L214">            <span class="tok-kw">try</span> self.ensureUnusedCapacity(items.len);</span>
<span class="line" id="L215">            self.appendSliceAssumeCapacity(items);</span>
<span class="line" id="L216">        }</span>
<span class="line" id="L217"></span>
<span class="line" id="L218">        <span class="tok-comment">/// Append the slice of items to the slice, asserting the capacity is already</span></span>
<span class="line" id="L219">        <span class="tok-comment">/// enough to store the new items.</span></span>
<span class="line" id="L220">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">appendSliceAssumeCapacity</span>(self: *Self, items: []<span class="tok-kw">const</span> T) <span class="tok-type">void</span> {</span>
<span class="line" id="L221">            <span class="tok-kw">const</span> oldlen = self.len;</span>
<span class="line" id="L222">            self.len += items.len;</span>
<span class="line" id="L223">            mem.copy(T, self.slice()[oldlen..], items);</span>
<span class="line" id="L224">        }</span>
<span class="line" id="L225"></span>
<span class="line" id="L226">        <span class="tok-comment">/// Append a value to the slice `n` times.</span></span>
<span class="line" id="L227">        <span class="tok-comment">/// Allocates more memory as necessary.</span></span>
<span class="line" id="L228">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">appendNTimes</span>(self: *Self, value: T, n: <span class="tok-type">usize</span>) <span class="tok-kw">error</span>{Overflow}!<span class="tok-type">void</span> {</span>
<span class="line" id="L229">            <span class="tok-kw">const</span> old_len = self.len;</span>
<span class="line" id="L230">            <span class="tok-kw">try</span> self.resize(old_len + n);</span>
<span class="line" id="L231">            mem.set(T, self.slice()[old_len..self.len], value);</span>
<span class="line" id="L232">        }</span>
<span class="line" id="L233"></span>
<span class="line" id="L234">        <span class="tok-comment">/// Append a value to the slice `n` times.</span></span>
<span class="line" id="L235">        <span class="tok-comment">/// Asserts the capacity is enough.</span></span>
<span class="line" id="L236">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">appendNTimesAssumeCapacity</span>(self: *Self, value: T, n: <span class="tok-type">usize</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L237">            <span class="tok-kw">const</span> old_len = self.len;</span>
<span class="line" id="L238">            self.len += n;</span>
<span class="line" id="L239">            assert(self.len &lt;= buffer_capacity);</span>
<span class="line" id="L240">            mem.set(T, self.slice()[old_len..self.len], value);</span>
<span class="line" id="L241">        }</span>
<span class="line" id="L242"></span>
<span class="line" id="L243">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> Writer = <span class="tok-kw">if</span> (T != <span class="tok-type">u8</span>)</span>
<span class="line" id="L244">            <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;The Writer interface is only defined for BoundedArray(u8, ...) &quot;</span> ++</span>
<span class="line" id="L245">                <span class="tok-str">&quot;but the given type is BoundedArray(&quot;</span> ++ <span class="tok-builtin">@typeName</span>(T) ++ <span class="tok-str">&quot;, ...)&quot;</span>)</span>
<span class="line" id="L246">        <span class="tok-kw">else</span></span>
<span class="line" id="L247">            std.io.Writer(*Self, <span class="tok-kw">error</span>{Overflow}, appendWrite);</span>
<span class="line" id="L248"></span>
<span class="line" id="L249">        <span class="tok-comment">/// Initializes a writer which will write into the array.</span></span>
<span class="line" id="L250">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">writer</span>(self: *Self) Writer {</span>
<span class="line" id="L251">            <span class="tok-kw">return</span> .{ .context = self };</span>
<span class="line" id="L252">        }</span>
<span class="line" id="L253"></span>
<span class="line" id="L254">        <span class="tok-comment">/// Same as `appendSlice` except it returns the number of bytes written, which is always the same</span></span>
<span class="line" id="L255">        <span class="tok-comment">/// as `m.len`. The purpose of this function existing is to match `std.io.Writer` API.</span></span>
<span class="line" id="L256">        <span class="tok-kw">fn</span> <span class="tok-fn">appendWrite</span>(self: *Self, m: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) <span class="tok-kw">error</span>{Overflow}!<span class="tok-type">usize</span> {</span>
<span class="line" id="L257">            <span class="tok-kw">try</span> self.appendSlice(m);</span>
<span class="line" id="L258">            <span class="tok-kw">return</span> m.len;</span>
<span class="line" id="L259">        }</span>
<span class="line" id="L260">    };</span>
<span class="line" id="L261">}</span>
<span class="line" id="L262"></span>
<span class="line" id="L263"><span class="tok-kw">test</span> <span class="tok-str">&quot;BoundedArray&quot;</span> {</span>
<span class="line" id="L264">    <span class="tok-kw">var</span> a = <span class="tok-kw">try</span> BoundedArray(<span class="tok-type">u8</span>, <span class="tok-number">64</span>).init(<span class="tok-number">32</span>);</span>
<span class="line" id="L265"></span>
<span class="line" id="L266">    <span class="tok-kw">try</span> testing.expectEqual(a.capacity(), <span class="tok-number">64</span>);</span>
<span class="line" id="L267">    <span class="tok-kw">try</span> testing.expectEqual(a.slice().len, <span class="tok-number">32</span>);</span>
<span class="line" id="L268">    <span class="tok-kw">try</span> testing.expectEqual(a.constSlice().len, <span class="tok-number">32</span>);</span>
<span class="line" id="L269"></span>
<span class="line" id="L270">    <span class="tok-kw">try</span> a.resize(<span class="tok-number">48</span>);</span>
<span class="line" id="L271">    <span class="tok-kw">try</span> testing.expectEqual(a.len, <span class="tok-number">48</span>);</span>
<span class="line" id="L272"></span>
<span class="line" id="L273">    <span class="tok-kw">const</span> x = [_]<span class="tok-type">u8</span>{<span class="tok-number">1</span>} ** <span class="tok-number">10</span>;</span>
<span class="line" id="L274">    a = <span class="tok-kw">try</span> BoundedArray(<span class="tok-type">u8</span>, <span class="tok-number">64</span>).fromSlice(&amp;x);</span>
<span class="line" id="L275">    <span class="tok-kw">try</span> testing.expectEqualSlices(<span class="tok-type">u8</span>, &amp;x, a.constSlice());</span>
<span class="line" id="L276"></span>
<span class="line" id="L277">    <span class="tok-kw">var</span> a2 = a;</span>
<span class="line" id="L278">    <span class="tok-kw">try</span> testing.expectEqualSlices(<span class="tok-type">u8</span>, a.constSlice(), a2.constSlice());</span>
<span class="line" id="L279">    a2.set(<span class="tok-number">0</span>, <span class="tok-number">0</span>);</span>
<span class="line" id="L280">    <span class="tok-kw">try</span> testing.expect(a.get(<span class="tok-number">0</span>) != a2.get(<span class="tok-number">0</span>));</span>
<span class="line" id="L281"></span>
<span class="line" id="L282">    <span class="tok-kw">try</span> testing.expectError(<span class="tok-kw">error</span>.Overflow, a.resize(<span class="tok-number">100</span>));</span>
<span class="line" id="L283">    <span class="tok-kw">try</span> testing.expectError(<span class="tok-kw">error</span>.Overflow, BoundedArray(<span class="tok-type">u8</span>, x.len - <span class="tok-number">1</span>).fromSlice(&amp;x));</span>
<span class="line" id="L284"></span>
<span class="line" id="L285">    <span class="tok-kw">try</span> a.resize(<span class="tok-number">0</span>);</span>
<span class="line" id="L286">    <span class="tok-kw">try</span> a.ensureUnusedCapacity(a.capacity());</span>
<span class="line" id="L287">    (<span class="tok-kw">try</span> a.addOne()).* = <span class="tok-number">0</span>;</span>
<span class="line" id="L288">    <span class="tok-kw">try</span> a.ensureUnusedCapacity(a.capacity() - <span class="tok-number">1</span>);</span>
<span class="line" id="L289">    <span class="tok-kw">try</span> testing.expectEqual(a.len, <span class="tok-number">1</span>);</span>
<span class="line" id="L290"></span>
<span class="line" id="L291">    <span class="tok-kw">const</span> uninitialized = <span class="tok-kw">try</span> a.addManyAsArray(<span class="tok-number">4</span>);</span>
<span class="line" id="L292">    <span class="tok-kw">try</span> testing.expectEqual(uninitialized.len, <span class="tok-number">4</span>);</span>
<span class="line" id="L293">    <span class="tok-kw">try</span> testing.expectEqual(a.len, <span class="tok-number">5</span>);</span>
<span class="line" id="L294"></span>
<span class="line" id="L295">    <span class="tok-kw">try</span> a.append(<span class="tok-number">0xff</span>);</span>
<span class="line" id="L296">    <span class="tok-kw">try</span> testing.expectEqual(a.len, <span class="tok-number">6</span>);</span>
<span class="line" id="L297">    <span class="tok-kw">try</span> testing.expectEqual(a.pop(), <span class="tok-number">0xff</span>);</span>
<span class="line" id="L298"></span>
<span class="line" id="L299">    a.appendAssumeCapacity(<span class="tok-number">0xff</span>);</span>
<span class="line" id="L300">    <span class="tok-kw">try</span> testing.expectEqual(a.len, <span class="tok-number">6</span>);</span>
<span class="line" id="L301">    <span class="tok-kw">try</span> testing.expectEqual(a.pop(), <span class="tok-number">0xff</span>);</span>
<span class="line" id="L302"></span>
<span class="line" id="L303">    <span class="tok-kw">try</span> a.resize(<span class="tok-number">1</span>);</span>
<span class="line" id="L304">    <span class="tok-kw">try</span> testing.expectEqual(a.popOrNull(), <span class="tok-number">0</span>);</span>
<span class="line" id="L305">    <span class="tok-kw">try</span> testing.expectEqual(a.popOrNull(), <span class="tok-null">null</span>);</span>
<span class="line" id="L306">    <span class="tok-kw">var</span> unused = a.unusedCapacitySlice();</span>
<span class="line" id="L307">    mem.set(<span class="tok-type">u8</span>, unused[<span class="tok-number">0</span>..<span class="tok-number">8</span>], <span class="tok-number">2</span>);</span>
<span class="line" id="L308">    unused[<span class="tok-number">8</span>] = <span class="tok-number">3</span>;</span>
<span class="line" id="L309">    unused[<span class="tok-number">9</span>] = <span class="tok-number">4</span>;</span>
<span class="line" id="L310">    <span class="tok-kw">try</span> testing.expectEqual(unused.len, a.capacity());</span>
<span class="line" id="L311">    <span class="tok-kw">try</span> a.resize(<span class="tok-number">10</span>);</span>
<span class="line" id="L312"></span>
<span class="line" id="L313">    <span class="tok-kw">try</span> a.insert(<span class="tok-number">5</span>, <span class="tok-number">0xaa</span>);</span>
<span class="line" id="L314">    <span class="tok-kw">try</span> testing.expectEqual(a.len, <span class="tok-number">11</span>);</span>
<span class="line" id="L315">    <span class="tok-kw">try</span> testing.expectEqual(a.get(<span class="tok-number">5</span>), <span class="tok-number">0xaa</span>);</span>
<span class="line" id="L316">    <span class="tok-kw">try</span> testing.expectEqual(a.get(<span class="tok-number">9</span>), <span class="tok-number">3</span>);</span>
<span class="line" id="L317">    <span class="tok-kw">try</span> testing.expectEqual(a.get(<span class="tok-number">10</span>), <span class="tok-number">4</span>);</span>
<span class="line" id="L318"></span>
<span class="line" id="L319">    <span class="tok-kw">try</span> a.insert(<span class="tok-number">11</span>, <span class="tok-number">0xbb</span>);</span>
<span class="line" id="L320">    <span class="tok-kw">try</span> testing.expectEqual(a.len, <span class="tok-number">12</span>);</span>
<span class="line" id="L321">    <span class="tok-kw">try</span> testing.expectEqual(a.pop(), <span class="tok-number">0xbb</span>);</span>
<span class="line" id="L322"></span>
<span class="line" id="L323">    <span class="tok-kw">try</span> a.appendSlice(&amp;x);</span>
<span class="line" id="L324">    <span class="tok-kw">try</span> testing.expectEqual(a.len, <span class="tok-number">11</span> + x.len);</span>
<span class="line" id="L325"></span>
<span class="line" id="L326">    <span class="tok-kw">try</span> a.appendNTimes(<span class="tok-number">0xbb</span>, <span class="tok-number">5</span>);</span>
<span class="line" id="L327">    <span class="tok-kw">try</span> testing.expectEqual(a.len, <span class="tok-number">11</span> + x.len + <span class="tok-number">5</span>);</span>
<span class="line" id="L328">    <span class="tok-kw">try</span> testing.expectEqual(a.pop(), <span class="tok-number">0xbb</span>);</span>
<span class="line" id="L329"></span>
<span class="line" id="L330">    a.appendNTimesAssumeCapacity(<span class="tok-number">0xcc</span>, <span class="tok-number">5</span>);</span>
<span class="line" id="L331">    <span class="tok-kw">try</span> testing.expectEqual(a.len, <span class="tok-number">11</span> + x.len + <span class="tok-number">5</span> - <span class="tok-number">1</span> + <span class="tok-number">5</span>);</span>
<span class="line" id="L332">    <span class="tok-kw">try</span> testing.expectEqual(a.pop(), <span class="tok-number">0xcc</span>);</span>
<span class="line" id="L333"></span>
<span class="line" id="L334">    <span class="tok-kw">try</span> testing.expectEqual(a.len, <span class="tok-number">29</span>);</span>
<span class="line" id="L335">    <span class="tok-kw">try</span> a.replaceRange(<span class="tok-number">1</span>, <span class="tok-number">20</span>, &amp;x);</span>
<span class="line" id="L336">    <span class="tok-kw">try</span> testing.expectEqual(a.len, <span class="tok-number">29</span> + x.len - <span class="tok-number">20</span>);</span>
<span class="line" id="L337"></span>
<span class="line" id="L338">    <span class="tok-kw">try</span> a.insertSlice(<span class="tok-number">0</span>, &amp;x);</span>
<span class="line" id="L339">    <span class="tok-kw">try</span> testing.expectEqual(a.len, <span class="tok-number">29</span> + x.len - <span class="tok-number">20</span> + x.len);</span>
<span class="line" id="L340"></span>
<span class="line" id="L341">    <span class="tok-kw">try</span> a.replaceRange(<span class="tok-number">1</span>, <span class="tok-number">5</span>, &amp;x);</span>
<span class="line" id="L342">    <span class="tok-kw">try</span> testing.expectEqual(a.len, <span class="tok-number">29</span> + x.len - <span class="tok-number">20</span> + x.len + x.len - <span class="tok-number">5</span>);</span>
<span class="line" id="L343"></span>
<span class="line" id="L344">    <span class="tok-kw">try</span> a.append(<span class="tok-number">10</span>);</span>
<span class="line" id="L345">    <span class="tok-kw">try</span> testing.expectEqual(a.pop(), <span class="tok-number">10</span>);</span>
<span class="line" id="L346"></span>
<span class="line" id="L347">    <span class="tok-kw">try</span> a.append(<span class="tok-number">20</span>);</span>
<span class="line" id="L348">    <span class="tok-kw">const</span> removed = a.orderedRemove(<span class="tok-number">5</span>);</span>
<span class="line" id="L349">    <span class="tok-kw">try</span> testing.expectEqual(removed, <span class="tok-number">1</span>);</span>
<span class="line" id="L350">    <span class="tok-kw">try</span> testing.expectEqual(a.len, <span class="tok-number">34</span>);</span>
<span class="line" id="L351"></span>
<span class="line" id="L352">    a.set(<span class="tok-number">0</span>, <span class="tok-number">0xdd</span>);</span>
<span class="line" id="L353">    a.set(a.len - <span class="tok-number">1</span>, <span class="tok-number">0xee</span>);</span>
<span class="line" id="L354">    <span class="tok-kw">const</span> swapped = a.swapRemove(<span class="tok-number">0</span>);</span>
<span class="line" id="L355">    <span class="tok-kw">try</span> testing.expectEqual(swapped, <span class="tok-number">0xdd</span>);</span>
<span class="line" id="L356">    <span class="tok-kw">try</span> testing.expectEqual(a.get(<span class="tok-number">0</span>), <span class="tok-number">0xee</span>);</span>
<span class="line" id="L357"></span>
<span class="line" id="L358">    <span class="tok-kw">while</span> (a.popOrNull()) |_| {}</span>
<span class="line" id="L359">    <span class="tok-kw">const</span> w = a.writer();</span>
<span class="line" id="L360">    <span class="tok-kw">const</span> s = <span class="tok-str">&quot;hello, this is a test string&quot;</span>;</span>
<span class="line" id="L361">    <span class="tok-kw">try</span> w.writeAll(s);</span>
<span class="line" id="L362">    <span class="tok-kw">try</span> testing.expectEqualStrings(s, a.constSlice());</span>
<span class="line" id="L363">}</span>
<span class="line" id="L364"></span>
</code></pre></body>
</html>