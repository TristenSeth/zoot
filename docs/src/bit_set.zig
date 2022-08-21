<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">    <title>bit_set.zig - source view</title>
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
<pre><code><span class="line" id="L1"><span class="tok-comment">//! This file defines several variants of bit sets.  A bit set</span></span>
<span class="line" id="L2"><span class="tok-comment">//! is a densely stored set of integers with a known maximum,</span></span>
<span class="line" id="L3"><span class="tok-comment">//! in which each integer gets a single bit.  Bit sets have very</span></span>
<span class="line" id="L4"><span class="tok-comment">//! fast presence checks, update operations, and union and intersection</span></span>
<span class="line" id="L5"><span class="tok-comment">//! operations.  However, if the number of possible items is very</span></span>
<span class="line" id="L6"><span class="tok-comment">//! large and the number of actual items in a given set is usually</span></span>
<span class="line" id="L7"><span class="tok-comment">//! small, they may be less memory efficient than an array set.</span></span>
<span class="line" id="L8"><span class="tok-comment">//!</span></span>
<span class="line" id="L9"><span class="tok-comment">//! There are five variants defined here:</span></span>
<span class="line" id="L10"><span class="tok-comment">//!</span></span>
<span class="line" id="L11"><span class="tok-comment">//! IntegerBitSet:</span></span>
<span class="line" id="L12"><span class="tok-comment">//!   A bit set with static size, which is backed by a single integer.</span></span>
<span class="line" id="L13"><span class="tok-comment">//!   This set is good for sets with a small size, but may generate</span></span>
<span class="line" id="L14"><span class="tok-comment">//!   inefficient code for larger sets, especially in debug mode.</span></span>
<span class="line" id="L15"><span class="tok-comment">//!</span></span>
<span class="line" id="L16"><span class="tok-comment">//! ArrayBitSet:</span></span>
<span class="line" id="L17"><span class="tok-comment">//!   A bit set with static size, which is backed by an array of usize.</span></span>
<span class="line" id="L18"><span class="tok-comment">//!   This set is good for sets with a larger size, but may use</span></span>
<span class="line" id="L19"><span class="tok-comment">//!   more bytes than necessary if your set is small.</span></span>
<span class="line" id="L20"><span class="tok-comment">//!</span></span>
<span class="line" id="L21"><span class="tok-comment">//! StaticBitSet:</span></span>
<span class="line" id="L22"><span class="tok-comment">//!   Picks either IntegerBitSet or ArrayBitSet depending on the requested</span></span>
<span class="line" id="L23"><span class="tok-comment">//!   size.  The interfaces of these two types match exactly, except for fields.</span></span>
<span class="line" id="L24"><span class="tok-comment">//!</span></span>
<span class="line" id="L25"><span class="tok-comment">//! DynamicBitSet:</span></span>
<span class="line" id="L26"><span class="tok-comment">//!   A bit set with runtime known size, backed by an allocated slice</span></span>
<span class="line" id="L27"><span class="tok-comment">//!   of usize.</span></span>
<span class="line" id="L28"><span class="tok-comment">//!</span></span>
<span class="line" id="L29"><span class="tok-comment">//! DynamicBitSetUnmanaged:</span></span>
<span class="line" id="L30"><span class="tok-comment">//!   A variant of DynamicBitSet which does not store a pointer to its</span></span>
<span class="line" id="L31"><span class="tok-comment">//!   allocator, in order to save space.</span></span>
<span class="line" id="L32"></span>
<span class="line" id="L33"><span class="tok-kw">const</span> std = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;std&quot;</span>);</span>
<span class="line" id="L34"><span class="tok-kw">const</span> assert = std.debug.assert;</span>
<span class="line" id="L35"><span class="tok-kw">const</span> Allocator = std.mem.Allocator;</span>
<span class="line" id="L36"></span>
<span class="line" id="L37"><span class="tok-comment">/// Returns the optimal static bit set type for the specified number</span></span>
<span class="line" id="L38"><span class="tok-comment">/// of elements.  The returned type will perform no allocations,</span></span>
<span class="line" id="L39"><span class="tok-comment">/// can be copied by value, and does not require deinitialization.</span></span>
<span class="line" id="L40"><span class="tok-comment">/// Both possible implementations fulfill the same interface.</span></span>
<span class="line" id="L41"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">StaticBitSet</span>(<span class="tok-kw">comptime</span> size: <span class="tok-type">usize</span>) <span class="tok-type">type</span> {</span>
<span class="line" id="L42">    <span class="tok-kw">if</span> (size &lt;= <span class="tok-builtin">@bitSizeOf</span>(<span class="tok-type">usize</span>)) {</span>
<span class="line" id="L43">        <span class="tok-kw">return</span> IntegerBitSet(size);</span>
<span class="line" id="L44">    } <span class="tok-kw">else</span> {</span>
<span class="line" id="L45">        <span class="tok-kw">return</span> ArrayBitSet(<span class="tok-type">usize</span>, size);</span>
<span class="line" id="L46">    }</span>
<span class="line" id="L47">}</span>
<span class="line" id="L48"></span>
<span class="line" id="L49"><span class="tok-comment">/// A bit set with static size, which is backed by a single integer.</span></span>
<span class="line" id="L50"><span class="tok-comment">/// This set is good for sets with a small size, but may generate</span></span>
<span class="line" id="L51"><span class="tok-comment">/// inefficient code for larger sets, especially in debug mode.</span></span>
<span class="line" id="L52"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">IntegerBitSet</span>(<span class="tok-kw">comptime</span> size: <span class="tok-type">u16</span>) <span class="tok-type">type</span> {</span>
<span class="line" id="L53">    <span class="tok-kw">return</span> <span class="tok-kw">packed</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L54">        <span class="tok-kw">const</span> Self = <span class="tok-builtin">@This</span>();</span>
<span class="line" id="L55"></span>
<span class="line" id="L56">        <span class="tok-comment">// TODO: Make this a comptime field once those are fixed</span>
</span>
<span class="line" id="L57">        <span class="tok-comment">/// The number of items in this bit set</span></span>
<span class="line" id="L58">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> bit_length: <span class="tok-type">usize</span> = size;</span>
<span class="line" id="L59"></span>
<span class="line" id="L60">        <span class="tok-comment">/// The integer type used to represent a mask in this bit set</span></span>
<span class="line" id="L61">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> MaskInt = std.meta.Int(.unsigned, size);</span>
<span class="line" id="L62"></span>
<span class="line" id="L63">        <span class="tok-comment">/// The integer type used to shift a mask in this bit set</span></span>
<span class="line" id="L64">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> ShiftInt = std.math.Log2Int(MaskInt);</span>
<span class="line" id="L65"></span>
<span class="line" id="L66">        <span class="tok-comment">/// The bit mask, as a single integer</span></span>
<span class="line" id="L67">        mask: MaskInt,</span>
<span class="line" id="L68"></span>
<span class="line" id="L69">        <span class="tok-comment">/// Creates a bit set with no elements present.</span></span>
<span class="line" id="L70">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">initEmpty</span>() Self {</span>
<span class="line" id="L71">            <span class="tok-kw">return</span> .{ .mask = <span class="tok-number">0</span> };</span>
<span class="line" id="L72">        }</span>
<span class="line" id="L73"></span>
<span class="line" id="L74">        <span class="tok-comment">/// Creates a bit set with all elements present.</span></span>
<span class="line" id="L75">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">initFull</span>() Self {</span>
<span class="line" id="L76">            <span class="tok-kw">return</span> .{ .mask = ~<span class="tok-builtin">@as</span>(MaskInt, <span class="tok-number">0</span>) };</span>
<span class="line" id="L77">        }</span>
<span class="line" id="L78"></span>
<span class="line" id="L79">        <span class="tok-comment">/// Returns the number of bits in this bit set</span></span>
<span class="line" id="L80">        <span class="tok-kw">pub</span> <span class="tok-kw">inline</span> <span class="tok-kw">fn</span> <span class="tok-fn">capacity</span>(self: Self) <span class="tok-type">usize</span> {</span>
<span class="line" id="L81">            _ = self;</span>
<span class="line" id="L82">            <span class="tok-kw">return</span> bit_length;</span>
<span class="line" id="L83">        }</span>
<span class="line" id="L84"></span>
<span class="line" id="L85">        <span class="tok-comment">/// Returns true if the bit at the specified index</span></span>
<span class="line" id="L86">        <span class="tok-comment">/// is present in the set, false otherwise.</span></span>
<span class="line" id="L87">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">isSet</span>(self: Self, index: <span class="tok-type">usize</span>) <span class="tok-type">bool</span> {</span>
<span class="line" id="L88">            assert(index &lt; bit_length);</span>
<span class="line" id="L89">            <span class="tok-kw">return</span> (self.mask &amp; maskBit(index)) != <span class="tok-number">0</span>;</span>
<span class="line" id="L90">        }</span>
<span class="line" id="L91"></span>
<span class="line" id="L92">        <span class="tok-comment">/// Returns the total number of set bits in this bit set.</span></span>
<span class="line" id="L93">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">count</span>(self: Self) <span class="tok-type">usize</span> {</span>
<span class="line" id="L94">            <span class="tok-kw">return</span> <span class="tok-builtin">@popCount</span>(MaskInt, self.mask);</span>
<span class="line" id="L95">        }</span>
<span class="line" id="L96"></span>
<span class="line" id="L97">        <span class="tok-comment">/// Changes the value of the specified bit of the bit</span></span>
<span class="line" id="L98">        <span class="tok-comment">/// set to match the passed boolean.</span></span>
<span class="line" id="L99">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">setValue</span>(self: *Self, index: <span class="tok-type">usize</span>, value: <span class="tok-type">bool</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L100">            assert(index &lt; bit_length);</span>
<span class="line" id="L101">            <span class="tok-kw">if</span> (MaskInt == <span class="tok-type">u0</span>) <span class="tok-kw">return</span>;</span>
<span class="line" id="L102">            <span class="tok-kw">const</span> bit = maskBit(index);</span>
<span class="line" id="L103">            <span class="tok-kw">const</span> new_bit = bit &amp; std.math.boolMask(MaskInt, value);</span>
<span class="line" id="L104">            self.mask = (self.mask &amp; ~bit) | new_bit;</span>
<span class="line" id="L105">        }</span>
<span class="line" id="L106"></span>
<span class="line" id="L107">        <span class="tok-comment">/// Adds a specific bit to the bit set</span></span>
<span class="line" id="L108">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">set</span>(self: *Self, index: <span class="tok-type">usize</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L109">            assert(index &lt; bit_length);</span>
<span class="line" id="L110">            self.mask |= maskBit(index);</span>
<span class="line" id="L111">        }</span>
<span class="line" id="L112"></span>
<span class="line" id="L113">        <span class="tok-comment">/// Changes the value of all bits in the specified range to</span></span>
<span class="line" id="L114">        <span class="tok-comment">/// match the passed boolean.</span></span>
<span class="line" id="L115">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">setRangeValue</span>(self: *Self, range: Range, value: <span class="tok-type">bool</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L116">            assert(range.end &lt;= bit_length);</span>
<span class="line" id="L117">            assert(range.start &lt;= range.end);</span>
<span class="line" id="L118">            <span class="tok-kw">if</span> (range.start == range.end) <span class="tok-kw">return</span>;</span>
<span class="line" id="L119">            <span class="tok-kw">if</span> (MaskInt == <span class="tok-type">u0</span>) <span class="tok-kw">return</span>;</span>
<span class="line" id="L120"></span>
<span class="line" id="L121">            <span class="tok-kw">const</span> start_bit = <span class="tok-builtin">@intCast</span>(ShiftInt, range.start);</span>
<span class="line" id="L122"></span>
<span class="line" id="L123">            <span class="tok-kw">var</span> mask = std.math.boolMask(MaskInt, <span class="tok-null">true</span>) &lt;&lt; start_bit;</span>
<span class="line" id="L124">            <span class="tok-kw">if</span> (range.end != bit_length) {</span>
<span class="line" id="L125">                <span class="tok-kw">const</span> end_bit = <span class="tok-builtin">@intCast</span>(ShiftInt, range.end);</span>
<span class="line" id="L126">                mask &amp;= std.math.boolMask(MaskInt, <span class="tok-null">true</span>) &gt;&gt; <span class="tok-builtin">@truncate</span>(ShiftInt, <span class="tok-builtin">@as</span>(<span class="tok-type">usize</span>, <span class="tok-builtin">@bitSizeOf</span>(MaskInt)) - <span class="tok-builtin">@as</span>(<span class="tok-type">usize</span>, end_bit));</span>
<span class="line" id="L127">            }</span>
<span class="line" id="L128">            self.mask &amp;= ~mask;</span>
<span class="line" id="L129"></span>
<span class="line" id="L130">            mask = std.math.boolMask(MaskInt, value) &lt;&lt; start_bit;</span>
<span class="line" id="L131">            <span class="tok-kw">if</span> (range.end != bit_length) {</span>
<span class="line" id="L132">                <span class="tok-kw">const</span> end_bit = <span class="tok-builtin">@intCast</span>(ShiftInt, range.end);</span>
<span class="line" id="L133">                mask &amp;= std.math.boolMask(MaskInt, value) &gt;&gt; <span class="tok-builtin">@truncate</span>(ShiftInt, <span class="tok-builtin">@as</span>(<span class="tok-type">usize</span>, <span class="tok-builtin">@bitSizeOf</span>(MaskInt)) - <span class="tok-builtin">@as</span>(<span class="tok-type">usize</span>, end_bit));</span>
<span class="line" id="L134">            }</span>
<span class="line" id="L135">            self.mask |= mask;</span>
<span class="line" id="L136">        }</span>
<span class="line" id="L137"></span>
<span class="line" id="L138">        <span class="tok-comment">/// Removes a specific bit from the bit set</span></span>
<span class="line" id="L139">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">unset</span>(self: *Self, index: <span class="tok-type">usize</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L140">            assert(index &lt; bit_length);</span>
<span class="line" id="L141">            <span class="tok-comment">// Workaround for #7953</span>
</span>
<span class="line" id="L142">            <span class="tok-kw">if</span> (MaskInt == <span class="tok-type">u0</span>) <span class="tok-kw">return</span>;</span>
<span class="line" id="L143">            self.mask &amp;= ~maskBit(index);</span>
<span class="line" id="L144">        }</span>
<span class="line" id="L145"></span>
<span class="line" id="L146">        <span class="tok-comment">/// Flips a specific bit in the bit set</span></span>
<span class="line" id="L147">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">toggle</span>(self: *Self, index: <span class="tok-type">usize</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L148">            assert(index &lt; bit_length);</span>
<span class="line" id="L149">            self.mask ^= maskBit(index);</span>
<span class="line" id="L150">        }</span>
<span class="line" id="L151"></span>
<span class="line" id="L152">        <span class="tok-comment">/// Flips all bits in this bit set which are present</span></span>
<span class="line" id="L153">        <span class="tok-comment">/// in the toggles bit set.</span></span>
<span class="line" id="L154">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">toggleSet</span>(self: *Self, toggles: Self) <span class="tok-type">void</span> {</span>
<span class="line" id="L155">            self.mask ^= toggles.mask;</span>
<span class="line" id="L156">        }</span>
<span class="line" id="L157"></span>
<span class="line" id="L158">        <span class="tok-comment">/// Flips every bit in the bit set.</span></span>
<span class="line" id="L159">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">toggleAll</span>(self: *Self) <span class="tok-type">void</span> {</span>
<span class="line" id="L160">            self.mask = ~self.mask;</span>
<span class="line" id="L161">        }</span>
<span class="line" id="L162"></span>
<span class="line" id="L163">        <span class="tok-comment">/// Performs a union of two bit sets, and stores the</span></span>
<span class="line" id="L164">        <span class="tok-comment">/// result in the first one.  Bits in the result are</span></span>
<span class="line" id="L165">        <span class="tok-comment">/// set if the corresponding bits were set in either input.</span></span>
<span class="line" id="L166">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">setUnion</span>(self: *Self, other: Self) <span class="tok-type">void</span> {</span>
<span class="line" id="L167">            self.mask |= other.mask;</span>
<span class="line" id="L168">        }</span>
<span class="line" id="L169"></span>
<span class="line" id="L170">        <span class="tok-comment">/// Performs an intersection of two bit sets, and stores</span></span>
<span class="line" id="L171">        <span class="tok-comment">/// the result in the first one.  Bits in the result are</span></span>
<span class="line" id="L172">        <span class="tok-comment">/// set if the corresponding bits were set in both inputs.</span></span>
<span class="line" id="L173">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">setIntersection</span>(self: *Self, other: Self) <span class="tok-type">void</span> {</span>
<span class="line" id="L174">            self.mask &amp;= other.mask;</span>
<span class="line" id="L175">        }</span>
<span class="line" id="L176"></span>
<span class="line" id="L177">        <span class="tok-comment">/// Finds the index of the first set bit.</span></span>
<span class="line" id="L178">        <span class="tok-comment">/// If no bits are set, returns null.</span></span>
<span class="line" id="L179">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">findFirstSet</span>(self: Self) ?<span class="tok-type">usize</span> {</span>
<span class="line" id="L180">            <span class="tok-kw">const</span> mask = self.mask;</span>
<span class="line" id="L181">            <span class="tok-kw">if</span> (mask == <span class="tok-number">0</span>) <span class="tok-kw">return</span> <span class="tok-null">null</span>;</span>
<span class="line" id="L182">            <span class="tok-kw">return</span> <span class="tok-builtin">@ctz</span>(MaskInt, mask);</span>
<span class="line" id="L183">        }</span>
<span class="line" id="L184"></span>
<span class="line" id="L185">        <span class="tok-comment">/// Finds the index of the first set bit, and unsets it.</span></span>
<span class="line" id="L186">        <span class="tok-comment">/// If no bits are set, returns null.</span></span>
<span class="line" id="L187">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">toggleFirstSet</span>(self: *Self) ?<span class="tok-type">usize</span> {</span>
<span class="line" id="L188">            <span class="tok-kw">const</span> mask = self.mask;</span>
<span class="line" id="L189">            <span class="tok-kw">if</span> (mask == <span class="tok-number">0</span>) <span class="tok-kw">return</span> <span class="tok-null">null</span>;</span>
<span class="line" id="L190">            <span class="tok-kw">const</span> index = <span class="tok-builtin">@ctz</span>(MaskInt, mask);</span>
<span class="line" id="L191">            self.mask = mask &amp; (mask - <span class="tok-number">1</span>);</span>
<span class="line" id="L192">            <span class="tok-kw">return</span> index;</span>
<span class="line" id="L193">        }</span>
<span class="line" id="L194"></span>
<span class="line" id="L195">        <span class="tok-comment">/// Iterates through the items in the set, according to the options.</span></span>
<span class="line" id="L196">        <span class="tok-comment">/// The default options (.{}) will iterate indices of set bits in</span></span>
<span class="line" id="L197">        <span class="tok-comment">/// ascending order.  Modifications to the underlying bit set may</span></span>
<span class="line" id="L198">        <span class="tok-comment">/// or may not be observed by the iterator.</span></span>
<span class="line" id="L199">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">iterator</span>(self: *<span class="tok-kw">const</span> Self, <span class="tok-kw">comptime</span> options: IteratorOptions) Iterator(options) {</span>
<span class="line" id="L200">            <span class="tok-kw">return</span> .{</span>
<span class="line" id="L201">                .bits_remain = <span class="tok-kw">switch</span> (options.kind) {</span>
<span class="line" id="L202">                    .set =&gt; self.mask,</span>
<span class="line" id="L203">                    .unset =&gt; ~self.mask,</span>
<span class="line" id="L204">                },</span>
<span class="line" id="L205">            };</span>
<span class="line" id="L206">        }</span>
<span class="line" id="L207"></span>
<span class="line" id="L208">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">Iterator</span>(<span class="tok-kw">comptime</span> options: IteratorOptions) <span class="tok-type">type</span> {</span>
<span class="line" id="L209">            <span class="tok-kw">return</span> SingleWordIterator(options.direction);</span>
<span class="line" id="L210">        }</span>
<span class="line" id="L211"></span>
<span class="line" id="L212">        <span class="tok-kw">fn</span> <span class="tok-fn">SingleWordIterator</span>(<span class="tok-kw">comptime</span> direction: IteratorOptions.Direction) <span class="tok-type">type</span> {</span>
<span class="line" id="L213">            <span class="tok-kw">return</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L214">                <span class="tok-kw">const</span> IterSelf = <span class="tok-builtin">@This</span>();</span>
<span class="line" id="L215">                <span class="tok-comment">// all bits which have not yet been iterated over</span>
</span>
<span class="line" id="L216">                bits_remain: MaskInt,</span>
<span class="line" id="L217"></span>
<span class="line" id="L218">                <span class="tok-comment">/// Returns the index of the next unvisited set bit</span></span>
<span class="line" id="L219">                <span class="tok-comment">/// in the bit set, in ascending order.</span></span>
<span class="line" id="L220">                <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">next</span>(self: *IterSelf) ?<span class="tok-type">usize</span> {</span>
<span class="line" id="L221">                    <span class="tok-kw">if</span> (self.bits_remain == <span class="tok-number">0</span>) <span class="tok-kw">return</span> <span class="tok-null">null</span>;</span>
<span class="line" id="L222"></span>
<span class="line" id="L223">                    <span class="tok-kw">switch</span> (direction) {</span>
<span class="line" id="L224">                        .forward =&gt; {</span>
<span class="line" id="L225">                            <span class="tok-kw">const</span> next_index = <span class="tok-builtin">@ctz</span>(MaskInt, self.bits_remain);</span>
<span class="line" id="L226">                            self.bits_remain &amp;= self.bits_remain - <span class="tok-number">1</span>;</span>
<span class="line" id="L227">                            <span class="tok-kw">return</span> next_index;</span>
<span class="line" id="L228">                        },</span>
<span class="line" id="L229">                        .reverse =&gt; {</span>
<span class="line" id="L230">                            <span class="tok-kw">const</span> leading_zeroes = <span class="tok-builtin">@clz</span>(MaskInt, self.bits_remain);</span>
<span class="line" id="L231">                            <span class="tok-kw">const</span> top_bit = (<span class="tok-builtin">@bitSizeOf</span>(MaskInt) - <span class="tok-number">1</span>) - leading_zeroes;</span>
<span class="line" id="L232">                            self.bits_remain &amp;= (<span class="tok-builtin">@as</span>(MaskInt, <span class="tok-number">1</span>) &lt;&lt; <span class="tok-builtin">@intCast</span>(ShiftInt, top_bit)) - <span class="tok-number">1</span>;</span>
<span class="line" id="L233">                            <span class="tok-kw">return</span> top_bit;</span>
<span class="line" id="L234">                        },</span>
<span class="line" id="L235">                    }</span>
<span class="line" id="L236">                }</span>
<span class="line" id="L237">            };</span>
<span class="line" id="L238">        }</span>
<span class="line" id="L239"></span>
<span class="line" id="L240">        <span class="tok-kw">fn</span> <span class="tok-fn">maskBit</span>(index: <span class="tok-type">usize</span>) MaskInt {</span>
<span class="line" id="L241">            <span class="tok-kw">if</span> (MaskInt == <span class="tok-type">u0</span>) <span class="tok-kw">return</span> <span class="tok-number">0</span>;</span>
<span class="line" id="L242">            <span class="tok-kw">return</span> <span class="tok-builtin">@as</span>(MaskInt, <span class="tok-number">1</span>) &lt;&lt; <span class="tok-builtin">@intCast</span>(ShiftInt, index);</span>
<span class="line" id="L243">        }</span>
<span class="line" id="L244">        <span class="tok-kw">fn</span> <span class="tok-fn">boolMaskBit</span>(index: <span class="tok-type">usize</span>, value: <span class="tok-type">bool</span>) MaskInt {</span>
<span class="line" id="L245">            <span class="tok-kw">if</span> (MaskInt == <span class="tok-type">u0</span>) <span class="tok-kw">return</span> <span class="tok-number">0</span>;</span>
<span class="line" id="L246">            <span class="tok-kw">return</span> <span class="tok-builtin">@as</span>(MaskInt, <span class="tok-builtin">@boolToInt</span>(value)) &lt;&lt; <span class="tok-builtin">@intCast</span>(ShiftInt, index);</span>
<span class="line" id="L247">        }</span>
<span class="line" id="L248">    };</span>
<span class="line" id="L249">}</span>
<span class="line" id="L250"></span>
<span class="line" id="L251"><span class="tok-comment">/// A bit set with static size, which is backed by an array of usize.</span></span>
<span class="line" id="L252"><span class="tok-comment">/// This set is good for sets with a larger size, but may use</span></span>
<span class="line" id="L253"><span class="tok-comment">/// more bytes than necessary if your set is small.</span></span>
<span class="line" id="L254"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">ArrayBitSet</span>(<span class="tok-kw">comptime</span> MaskIntType: <span class="tok-type">type</span>, <span class="tok-kw">comptime</span> size: <span class="tok-type">usize</span>) <span class="tok-type">type</span> {</span>
<span class="line" id="L255">    <span class="tok-kw">const</span> mask_info: std.builtin.Type = <span class="tok-builtin">@typeInfo</span>(MaskIntType);</span>
<span class="line" id="L256"></span>
<span class="line" id="L257">    <span class="tok-comment">// Make sure the mask int is indeed an int</span>
</span>
<span class="line" id="L258">    <span class="tok-kw">if</span> (mask_info != .Int) <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;ArrayBitSet can only operate on integer masks, but was passed &quot;</span> ++ <span class="tok-builtin">@typeName</span>(MaskIntType));</span>
<span class="line" id="L259"></span>
<span class="line" id="L260">    <span class="tok-comment">// It must also be unsigned.</span>
</span>
<span class="line" id="L261">    <span class="tok-kw">if</span> (mask_info.Int.signedness != .unsigned) <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;ArrayBitSet requires an unsigned integer mask type, but was passed &quot;</span> ++ <span class="tok-builtin">@typeName</span>(MaskIntType));</span>
<span class="line" id="L262"></span>
<span class="line" id="L263">    <span class="tok-comment">// And it must not be empty.</span>
</span>
<span class="line" id="L264">    <span class="tok-kw">if</span> (MaskIntType == <span class="tok-type">u0</span>)</span>
<span class="line" id="L265">        <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;ArrayBitSet requires a sized integer for its mask int.  u0 does not work.&quot;</span>);</span>
<span class="line" id="L266"></span>
<span class="line" id="L267">    <span class="tok-kw">const</span> byte_size = std.mem.byte_size_in_bits;</span>
<span class="line" id="L268"></span>
<span class="line" id="L269">    <span class="tok-comment">// We use shift and truncate to decompose indices into mask indices and bit indices.</span>
</span>
<span class="line" id="L270">    <span class="tok-comment">// This operation requires that the mask has an exact power of two number of bits.</span>
</span>
<span class="line" id="L271">    <span class="tok-kw">if</span> (!std.math.isPowerOfTwo(<span class="tok-builtin">@bitSizeOf</span>(MaskIntType))) {</span>
<span class="line" id="L272">        <span class="tok-kw">var</span> desired_bits = std.math.ceilPowerOfTwoAssert(<span class="tok-type">usize</span>, <span class="tok-builtin">@bitSizeOf</span>(MaskIntType));</span>
<span class="line" id="L273">        <span class="tok-kw">if</span> (desired_bits &lt; byte_size) desired_bits = byte_size;</span>
<span class="line" id="L274">        <span class="tok-kw">const</span> FixedMaskType = std.meta.Int(.unsigned, desired_bits);</span>
<span class="line" id="L275">        <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;ArrayBitSet was passed integer type &quot;</span> ++ <span class="tok-builtin">@typeName</span>(MaskIntType) ++</span>
<span class="line" id="L276">            <span class="tok-str">&quot;, which is not a power of two.  Please round this up to a power of two integer size (i.e. &quot;</span> ++ <span class="tok-builtin">@typeName</span>(FixedMaskType) ++ <span class="tok-str">&quot;).&quot;</span>);</span>
<span class="line" id="L277">    }</span>
<span class="line" id="L278"></span>
<span class="line" id="L279">    <span class="tok-comment">// Make sure the integer has no padding bits.</span>
</span>
<span class="line" id="L280">    <span class="tok-comment">// Those would be wasteful here and are probably a mistake by the user.</span>
</span>
<span class="line" id="L281">    <span class="tok-comment">// This case may be hit with small powers of two, like u4.</span>
</span>
<span class="line" id="L282">    <span class="tok-kw">if</span> (<span class="tok-builtin">@bitSizeOf</span>(MaskIntType) != <span class="tok-builtin">@sizeOf</span>(MaskIntType) * byte_size) {</span>
<span class="line" id="L283">        <span class="tok-kw">var</span> desired_bits = <span class="tok-builtin">@sizeOf</span>(MaskIntType) * byte_size;</span>
<span class="line" id="L284">        desired_bits = std.math.ceilPowerOfTwoAssert(<span class="tok-type">usize</span>, desired_bits);</span>
<span class="line" id="L285">        <span class="tok-kw">const</span> FixedMaskType = std.meta.Int(.unsigned, desired_bits);</span>
<span class="line" id="L286">        <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;ArrayBitSet was passed integer type &quot;</span> ++ <span class="tok-builtin">@typeName</span>(MaskIntType) ++</span>
<span class="line" id="L287">            <span class="tok-str">&quot;, which contains padding bits.  Please round this up to an unpadded integer size (i.e. &quot;</span> ++ <span class="tok-builtin">@typeName</span>(FixedMaskType) ++ <span class="tok-str">&quot;).&quot;</span>);</span>
<span class="line" id="L288">    }</span>
<span class="line" id="L289"></span>
<span class="line" id="L290">    <span class="tok-kw">return</span> <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L291">        <span class="tok-kw">const</span> Self = <span class="tok-builtin">@This</span>();</span>
<span class="line" id="L292"></span>
<span class="line" id="L293">        <span class="tok-comment">// TODO: Make this a comptime field once those are fixed</span>
</span>
<span class="line" id="L294">        <span class="tok-comment">/// The number of items in this bit set</span></span>
<span class="line" id="L295">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> bit_length: <span class="tok-type">usize</span> = size;</span>
<span class="line" id="L296"></span>
<span class="line" id="L297">        <span class="tok-comment">/// The integer type used to represent a mask in this bit set</span></span>
<span class="line" id="L298">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> MaskInt = MaskIntType;</span>
<span class="line" id="L299"></span>
<span class="line" id="L300">        <span class="tok-comment">/// The integer type used to shift a mask in this bit set</span></span>
<span class="line" id="L301">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> ShiftInt = std.math.Log2Int(MaskInt);</span>
<span class="line" id="L302"></span>
<span class="line" id="L303">        <span class="tok-comment">// bits in one mask</span>
</span>
<span class="line" id="L304">        <span class="tok-kw">const</span> mask_len = <span class="tok-builtin">@bitSizeOf</span>(MaskInt);</span>
<span class="line" id="L305">        <span class="tok-comment">// total number of masks</span>
</span>
<span class="line" id="L306">        <span class="tok-kw">const</span> num_masks = (size + mask_len - <span class="tok-number">1</span>) / mask_len;</span>
<span class="line" id="L307">        <span class="tok-comment">// padding bits in the last mask (may be 0)</span>
</span>
<span class="line" id="L308">        <span class="tok-kw">const</span> last_pad_bits = mask_len * num_masks - size;</span>
<span class="line" id="L309">        <span class="tok-comment">// Mask of valid bits in the last mask.</span>
</span>
<span class="line" id="L310">        <span class="tok-comment">// All functions will ensure that the invalid</span>
</span>
<span class="line" id="L311">        <span class="tok-comment">// bits in the last mask are zero.</span>
</span>
<span class="line" id="L312">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> last_item_mask = ~<span class="tok-builtin">@as</span>(MaskInt, <span class="tok-number">0</span>) &gt;&gt; last_pad_bits;</span>
<span class="line" id="L313"></span>
<span class="line" id="L314">        <span class="tok-comment">/// The bit masks, ordered with lower indices first.</span></span>
<span class="line" id="L315">        <span class="tok-comment">/// Padding bits at the end are undefined.</span></span>
<span class="line" id="L316">        masks: [num_masks]MaskInt,</span>
<span class="line" id="L317"></span>
<span class="line" id="L318">        <span class="tok-comment">/// Creates a bit set with no elements present.</span></span>
<span class="line" id="L319">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">initEmpty</span>() Self {</span>
<span class="line" id="L320">            <span class="tok-kw">return</span> .{ .masks = [_]MaskInt{<span class="tok-number">0</span>} ** num_masks };</span>
<span class="line" id="L321">        }</span>
<span class="line" id="L322"></span>
<span class="line" id="L323">        <span class="tok-comment">/// Creates a bit set with all elements present.</span></span>
<span class="line" id="L324">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">initFull</span>() Self {</span>
<span class="line" id="L325">            <span class="tok-kw">if</span> (num_masks == <span class="tok-number">0</span>) {</span>
<span class="line" id="L326">                <span class="tok-kw">return</span> .{ .masks = .{} };</span>
<span class="line" id="L327">            } <span class="tok-kw">else</span> {</span>
<span class="line" id="L328">                <span class="tok-kw">return</span> .{ .masks = [_]MaskInt{~<span class="tok-builtin">@as</span>(MaskInt, <span class="tok-number">0</span>)} ** (num_masks - <span class="tok-number">1</span>) ++ [_]MaskInt{last_item_mask} };</span>
<span class="line" id="L329">            }</span>
<span class="line" id="L330">        }</span>
<span class="line" id="L331"></span>
<span class="line" id="L332">        <span class="tok-comment">/// Returns the number of bits in this bit set</span></span>
<span class="line" id="L333">        <span class="tok-kw">pub</span> <span class="tok-kw">inline</span> <span class="tok-kw">fn</span> <span class="tok-fn">capacity</span>(self: Self) <span class="tok-type">usize</span> {</span>
<span class="line" id="L334">            _ = self;</span>
<span class="line" id="L335">            <span class="tok-kw">return</span> bit_length;</span>
<span class="line" id="L336">        }</span>
<span class="line" id="L337"></span>
<span class="line" id="L338">        <span class="tok-comment">/// Returns true if the bit at the specified index</span></span>
<span class="line" id="L339">        <span class="tok-comment">/// is present in the set, false otherwise.</span></span>
<span class="line" id="L340">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">isSet</span>(self: Self, index: <span class="tok-type">usize</span>) <span class="tok-type">bool</span> {</span>
<span class="line" id="L341">            assert(index &lt; bit_length);</span>
<span class="line" id="L342">            <span class="tok-kw">if</span> (num_masks == <span class="tok-number">0</span>) <span class="tok-kw">return</span> <span class="tok-null">false</span>; <span class="tok-comment">// doesn't compile in this case</span>
</span>
<span class="line" id="L343">            <span class="tok-kw">return</span> (self.masks[maskIndex(index)] &amp; maskBit(index)) != <span class="tok-number">0</span>;</span>
<span class="line" id="L344">        }</span>
<span class="line" id="L345"></span>
<span class="line" id="L346">        <span class="tok-comment">/// Returns the total number of set bits in this bit set.</span></span>
<span class="line" id="L347">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">count</span>(self: Self) <span class="tok-type">usize</span> {</span>
<span class="line" id="L348">            <span class="tok-kw">var</span> total: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L349">            <span class="tok-kw">for</span> (self.masks) |mask| {</span>
<span class="line" id="L350">                total += <span class="tok-builtin">@popCount</span>(MaskInt, mask);</span>
<span class="line" id="L351">            }</span>
<span class="line" id="L352">            <span class="tok-kw">return</span> total;</span>
<span class="line" id="L353">        }</span>
<span class="line" id="L354"></span>
<span class="line" id="L355">        <span class="tok-comment">/// Changes the value of the specified bit of the bit</span></span>
<span class="line" id="L356">        <span class="tok-comment">/// set to match the passed boolean.</span></span>
<span class="line" id="L357">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">setValue</span>(self: *Self, index: <span class="tok-type">usize</span>, value: <span class="tok-type">bool</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L358">            assert(index &lt; bit_length);</span>
<span class="line" id="L359">            <span class="tok-kw">if</span> (num_masks == <span class="tok-number">0</span>) <span class="tok-kw">return</span>; <span class="tok-comment">// doesn't compile in this case</span>
</span>
<span class="line" id="L360">            <span class="tok-kw">const</span> bit = maskBit(index);</span>
<span class="line" id="L361">            <span class="tok-kw">const</span> mask_index = maskIndex(index);</span>
<span class="line" id="L362">            <span class="tok-kw">const</span> new_bit = bit &amp; std.math.boolMask(MaskInt, value);</span>
<span class="line" id="L363">            self.masks[mask_index] = (self.masks[mask_index] &amp; ~bit) | new_bit;</span>
<span class="line" id="L364">        }</span>
<span class="line" id="L365"></span>
<span class="line" id="L366">        <span class="tok-comment">/// Adds a specific bit to the bit set</span></span>
<span class="line" id="L367">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">set</span>(self: *Self, index: <span class="tok-type">usize</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L368">            assert(index &lt; bit_length);</span>
<span class="line" id="L369">            <span class="tok-kw">if</span> (num_masks == <span class="tok-number">0</span>) <span class="tok-kw">return</span>; <span class="tok-comment">// doesn't compile in this case</span>
</span>
<span class="line" id="L370">            self.masks[maskIndex(index)] |= maskBit(index);</span>
<span class="line" id="L371">        }</span>
<span class="line" id="L372"></span>
<span class="line" id="L373">        <span class="tok-comment">/// Changes the value of all bits in the specified range to</span></span>
<span class="line" id="L374">        <span class="tok-comment">/// match the passed boolean.</span></span>
<span class="line" id="L375">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">setRangeValue</span>(self: *Self, range: Range, value: <span class="tok-type">bool</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L376">            assert(range.end &lt;= bit_length);</span>
<span class="line" id="L377">            assert(range.start &lt;= range.end);</span>
<span class="line" id="L378">            <span class="tok-kw">if</span> (range.start == range.end) <span class="tok-kw">return</span>;</span>
<span class="line" id="L379">            <span class="tok-kw">if</span> (num_masks == <span class="tok-number">0</span>) <span class="tok-kw">return</span>;</span>
<span class="line" id="L380"></span>
<span class="line" id="L381">            <span class="tok-kw">const</span> start_mask_index = maskIndex(range.start);</span>
<span class="line" id="L382">            <span class="tok-kw">const</span> start_bit = <span class="tok-builtin">@truncate</span>(ShiftInt, range.start);</span>
<span class="line" id="L383"></span>
<span class="line" id="L384">            <span class="tok-kw">const</span> end_mask_index = maskIndex(range.end);</span>
<span class="line" id="L385">            <span class="tok-kw">const</span> end_bit = <span class="tok-builtin">@truncate</span>(ShiftInt, range.end);</span>
<span class="line" id="L386"></span>
<span class="line" id="L387">            <span class="tok-kw">if</span> (start_mask_index == end_mask_index) {</span>
<span class="line" id="L388">                <span class="tok-kw">var</span> mask1 = std.math.boolMask(MaskInt, <span class="tok-null">true</span>) &lt;&lt; start_bit;</span>
<span class="line" id="L389">                <span class="tok-kw">var</span> mask2 = std.math.boolMask(MaskInt, <span class="tok-null">true</span>) &gt;&gt; (mask_len - <span class="tok-number">1</span>) - (end_bit - <span class="tok-number">1</span>);</span>
<span class="line" id="L390">                self.masks[start_mask_index] &amp;= ~(mask1 &amp; mask2);</span>
<span class="line" id="L391"></span>
<span class="line" id="L392">                mask1 = std.math.boolMask(MaskInt, value) &lt;&lt; start_bit;</span>
<span class="line" id="L393">                mask2 = std.math.boolMask(MaskInt, value) &gt;&gt; (mask_len - <span class="tok-number">1</span>) - (end_bit - <span class="tok-number">1</span>);</span>
<span class="line" id="L394">                self.masks[start_mask_index] |= mask1 &amp; mask2;</span>
<span class="line" id="L395">            } <span class="tok-kw">else</span> {</span>
<span class="line" id="L396">                <span class="tok-kw">var</span> bulk_mask_index: <span class="tok-type">usize</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L397">                <span class="tok-kw">if</span> (start_bit &gt; <span class="tok-number">0</span>) {</span>
<span class="line" id="L398">                    self.masks[start_mask_index] =</span>
<span class="line" id="L399">                        (self.masks[start_mask_index] &amp; ~(std.math.boolMask(MaskInt, <span class="tok-null">true</span>) &lt;&lt; start_bit)) |</span>
<span class="line" id="L400">                        (std.math.boolMask(MaskInt, value) &lt;&lt; start_bit);</span>
<span class="line" id="L401">                    bulk_mask_index = start_mask_index + <span class="tok-number">1</span>;</span>
<span class="line" id="L402">                } <span class="tok-kw">else</span> {</span>
<span class="line" id="L403">                    bulk_mask_index = start_mask_index;</span>
<span class="line" id="L404">                }</span>
<span class="line" id="L405"></span>
<span class="line" id="L406">                <span class="tok-kw">while</span> (bulk_mask_index &lt; end_mask_index) : (bulk_mask_index += <span class="tok-number">1</span>) {</span>
<span class="line" id="L407">                    self.masks[bulk_mask_index] = std.math.boolMask(MaskInt, value);</span>
<span class="line" id="L408">                }</span>
<span class="line" id="L409"></span>
<span class="line" id="L410">                <span class="tok-kw">if</span> (end_bit &gt; <span class="tok-number">0</span>) {</span>
<span class="line" id="L411">                    self.masks[end_mask_index] =</span>
<span class="line" id="L412">                        (self.masks[end_mask_index] &amp; (std.math.boolMask(MaskInt, <span class="tok-null">true</span>) &lt;&lt; end_bit)) |</span>
<span class="line" id="L413">                        (std.math.boolMask(MaskInt, value) &gt;&gt; ((<span class="tok-builtin">@bitSizeOf</span>(MaskInt) - <span class="tok-number">1</span>) - (end_bit - <span class="tok-number">1</span>)));</span>
<span class="line" id="L414">                }</span>
<span class="line" id="L415">            }</span>
<span class="line" id="L416">        }</span>
<span class="line" id="L417"></span>
<span class="line" id="L418">        <span class="tok-comment">/// Removes a specific bit from the bit set</span></span>
<span class="line" id="L419">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">unset</span>(self: *Self, index: <span class="tok-type">usize</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L420">            assert(index &lt; bit_length);</span>
<span class="line" id="L421">            <span class="tok-kw">if</span> (num_masks == <span class="tok-number">0</span>) <span class="tok-kw">return</span>; <span class="tok-comment">// doesn't compile in this case</span>
</span>
<span class="line" id="L422">            self.masks[maskIndex(index)] &amp;= ~maskBit(index);</span>
<span class="line" id="L423">        }</span>
<span class="line" id="L424"></span>
<span class="line" id="L425">        <span class="tok-comment">/// Flips a specific bit in the bit set</span></span>
<span class="line" id="L426">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">toggle</span>(self: *Self, index: <span class="tok-type">usize</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L427">            assert(index &lt; bit_length);</span>
<span class="line" id="L428">            <span class="tok-kw">if</span> (num_masks == <span class="tok-number">0</span>) <span class="tok-kw">return</span>; <span class="tok-comment">// doesn't compile in this case</span>
</span>
<span class="line" id="L429">            self.masks[maskIndex(index)] ^= maskBit(index);</span>
<span class="line" id="L430">        }</span>
<span class="line" id="L431"></span>
<span class="line" id="L432">        <span class="tok-comment">/// Flips all bits in this bit set which are present</span></span>
<span class="line" id="L433">        <span class="tok-comment">/// in the toggles bit set.</span></span>
<span class="line" id="L434">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">toggleSet</span>(self: *Self, toggles: Self) <span class="tok-type">void</span> {</span>
<span class="line" id="L435">            <span class="tok-kw">for</span> (self.masks) |*mask, i| {</span>
<span class="line" id="L436">                mask.* ^= toggles.masks[i];</span>
<span class="line" id="L437">            }</span>
<span class="line" id="L438">        }</span>
<span class="line" id="L439"></span>
<span class="line" id="L440">        <span class="tok-comment">/// Flips every bit in the bit set.</span></span>
<span class="line" id="L441">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">toggleAll</span>(self: *Self) <span class="tok-type">void</span> {</span>
<span class="line" id="L442">            <span class="tok-kw">for</span> (self.masks) |*mask| {</span>
<span class="line" id="L443">                mask.* = ~mask.*;</span>
<span class="line" id="L444">            }</span>
<span class="line" id="L445"></span>
<span class="line" id="L446">            <span class="tok-comment">// Zero the padding bits</span>
</span>
<span class="line" id="L447">            <span class="tok-kw">if</span> (num_masks &gt; <span class="tok-number">0</span>) {</span>
<span class="line" id="L448">                self.masks[num_masks - <span class="tok-number">1</span>] &amp;= last_item_mask;</span>
<span class="line" id="L449">            }</span>
<span class="line" id="L450">        }</span>
<span class="line" id="L451"></span>
<span class="line" id="L452">        <span class="tok-comment">/// Performs a union of two bit sets, and stores the</span></span>
<span class="line" id="L453">        <span class="tok-comment">/// result in the first one.  Bits in the result are</span></span>
<span class="line" id="L454">        <span class="tok-comment">/// set if the corresponding bits were set in either input.</span></span>
<span class="line" id="L455">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">setUnion</span>(self: *Self, other: Self) <span class="tok-type">void</span> {</span>
<span class="line" id="L456">            <span class="tok-kw">for</span> (self.masks) |*mask, i| {</span>
<span class="line" id="L457">                mask.* |= other.masks[i];</span>
<span class="line" id="L458">            }</span>
<span class="line" id="L459">        }</span>
<span class="line" id="L460"></span>
<span class="line" id="L461">        <span class="tok-comment">/// Performs an intersection of two bit sets, and stores</span></span>
<span class="line" id="L462">        <span class="tok-comment">/// the result in the first one.  Bits in the result are</span></span>
<span class="line" id="L463">        <span class="tok-comment">/// set if the corresponding bits were set in both inputs.</span></span>
<span class="line" id="L464">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">setIntersection</span>(self: *Self, other: Self) <span class="tok-type">void</span> {</span>
<span class="line" id="L465">            <span class="tok-kw">for</span> (self.masks) |*mask, i| {</span>
<span class="line" id="L466">                mask.* &amp;= other.masks[i];</span>
<span class="line" id="L467">            }</span>
<span class="line" id="L468">        }</span>
<span class="line" id="L469"></span>
<span class="line" id="L470">        <span class="tok-comment">/// Finds the index of the first set bit.</span></span>
<span class="line" id="L471">        <span class="tok-comment">/// If no bits are set, returns null.</span></span>
<span class="line" id="L472">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">findFirstSet</span>(self: Self) ?<span class="tok-type">usize</span> {</span>
<span class="line" id="L473">            <span class="tok-kw">var</span> offset: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L474">            <span class="tok-kw">const</span> mask = <span class="tok-kw">for</span> (self.masks) |mask| {</span>
<span class="line" id="L475">                <span class="tok-kw">if</span> (mask != <span class="tok-number">0</span>) <span class="tok-kw">break</span> mask;</span>
<span class="line" id="L476">                offset += <span class="tok-builtin">@bitSizeOf</span>(MaskInt);</span>
<span class="line" id="L477">            } <span class="tok-kw">else</span> <span class="tok-kw">return</span> <span class="tok-null">null</span>;</span>
<span class="line" id="L478">            <span class="tok-kw">return</span> offset + <span class="tok-builtin">@ctz</span>(MaskInt, mask);</span>
<span class="line" id="L479">        }</span>
<span class="line" id="L480"></span>
<span class="line" id="L481">        <span class="tok-comment">/// Finds the index of the first set bit, and unsets it.</span></span>
<span class="line" id="L482">        <span class="tok-comment">/// If no bits are set, returns null.</span></span>
<span class="line" id="L483">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">toggleFirstSet</span>(self: *Self) ?<span class="tok-type">usize</span> {</span>
<span class="line" id="L484">            <span class="tok-kw">var</span> offset: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L485">            <span class="tok-kw">const</span> mask = <span class="tok-kw">for</span> (self.masks) |*mask| {</span>
<span class="line" id="L486">                <span class="tok-kw">if</span> (mask.* != <span class="tok-number">0</span>) <span class="tok-kw">break</span> mask;</span>
<span class="line" id="L487">                offset += <span class="tok-builtin">@bitSizeOf</span>(MaskInt);</span>
<span class="line" id="L488">            } <span class="tok-kw">else</span> <span class="tok-kw">return</span> <span class="tok-null">null</span>;</span>
<span class="line" id="L489">            <span class="tok-kw">const</span> index = <span class="tok-builtin">@ctz</span>(MaskInt, mask.*);</span>
<span class="line" id="L490">            mask.* &amp;= (mask.* - <span class="tok-number">1</span>);</span>
<span class="line" id="L491">            <span class="tok-kw">return</span> offset + index;</span>
<span class="line" id="L492">        }</span>
<span class="line" id="L493"></span>
<span class="line" id="L494">        <span class="tok-comment">/// Iterates through the items in the set, according to the options.</span></span>
<span class="line" id="L495">        <span class="tok-comment">/// The default options (.{}) will iterate indices of set bits in</span></span>
<span class="line" id="L496">        <span class="tok-comment">/// ascending order.  Modifications to the underlying bit set may</span></span>
<span class="line" id="L497">        <span class="tok-comment">/// or may not be observed by the iterator.</span></span>
<span class="line" id="L498">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">iterator</span>(self: *<span class="tok-kw">const</span> Self, <span class="tok-kw">comptime</span> options: IteratorOptions) Iterator(options) {</span>
<span class="line" id="L499">            <span class="tok-kw">return</span> Iterator(options).init(&amp;self.masks, last_item_mask);</span>
<span class="line" id="L500">        }</span>
<span class="line" id="L501"></span>
<span class="line" id="L502">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">Iterator</span>(<span class="tok-kw">comptime</span> options: IteratorOptions) <span class="tok-type">type</span> {</span>
<span class="line" id="L503">            <span class="tok-kw">return</span> BitSetIterator(MaskInt, options);</span>
<span class="line" id="L504">        }</span>
<span class="line" id="L505"></span>
<span class="line" id="L506">        <span class="tok-kw">fn</span> <span class="tok-fn">maskBit</span>(index: <span class="tok-type">usize</span>) MaskInt {</span>
<span class="line" id="L507">            <span class="tok-kw">return</span> <span class="tok-builtin">@as</span>(MaskInt, <span class="tok-number">1</span>) &lt;&lt; <span class="tok-builtin">@truncate</span>(ShiftInt, index);</span>
<span class="line" id="L508">        }</span>
<span class="line" id="L509">        <span class="tok-kw">fn</span> <span class="tok-fn">maskIndex</span>(index: <span class="tok-type">usize</span>) <span class="tok-type">usize</span> {</span>
<span class="line" id="L510">            <span class="tok-kw">return</span> index &gt;&gt; <span class="tok-builtin">@bitSizeOf</span>(ShiftInt);</span>
<span class="line" id="L511">        }</span>
<span class="line" id="L512">        <span class="tok-kw">fn</span> <span class="tok-fn">boolMaskBit</span>(index: <span class="tok-type">usize</span>, value: <span class="tok-type">bool</span>) MaskInt {</span>
<span class="line" id="L513">            <span class="tok-kw">return</span> <span class="tok-builtin">@as</span>(MaskInt, <span class="tok-builtin">@boolToInt</span>(value)) &lt;&lt; <span class="tok-builtin">@intCast</span>(ShiftInt, index);</span>
<span class="line" id="L514">        }</span>
<span class="line" id="L515">    };</span>
<span class="line" id="L516">}</span>
<span class="line" id="L517"></span>
<span class="line" id="L518"><span class="tok-comment">/// A bit set with runtime known size, backed by an allocated slice</span></span>
<span class="line" id="L519"><span class="tok-comment">/// of usize.  The allocator must be tracked externally by the user.</span></span>
<span class="line" id="L520"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> DynamicBitSetUnmanaged = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L521">    <span class="tok-kw">const</span> Self = <span class="tok-builtin">@This</span>();</span>
<span class="line" id="L522"></span>
<span class="line" id="L523">    <span class="tok-comment">/// The integer type used to represent a mask in this bit set</span></span>
<span class="line" id="L524">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> MaskInt = <span class="tok-type">usize</span>;</span>
<span class="line" id="L525"></span>
<span class="line" id="L526">    <span class="tok-comment">/// The integer type used to shift a mask in this bit set</span></span>
<span class="line" id="L527">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> ShiftInt = std.math.Log2Int(MaskInt);</span>
<span class="line" id="L528"></span>
<span class="line" id="L529">    <span class="tok-comment">/// The number of valid items in this bit set</span></span>
<span class="line" id="L530">    bit_length: <span class="tok-type">usize</span> = <span class="tok-number">0</span>,</span>
<span class="line" id="L531"></span>
<span class="line" id="L532">    <span class="tok-comment">/// The bit masks, ordered with lower indices first.</span></span>
<span class="line" id="L533">    <span class="tok-comment">/// Padding bits at the end must be zeroed.</span></span>
<span class="line" id="L534">    masks: [*]MaskInt = empty_masks_ptr,</span>
<span class="line" id="L535">    <span class="tok-comment">// This pointer is one usize after the actual allocation.</span>
</span>
<span class="line" id="L536">    <span class="tok-comment">// That slot holds the size of the true allocation, which</span>
</span>
<span class="line" id="L537">    <span class="tok-comment">// is needed by Zig's allocator interface in case a shrink</span>
</span>
<span class="line" id="L538">    <span class="tok-comment">// fails.</span>
</span>
<span class="line" id="L539"></span>
<span class="line" id="L540">    <span class="tok-comment">// Don't modify this value.  Ideally it would go in const data so</span>
</span>
<span class="line" id="L541">    <span class="tok-comment">// modifications would cause a bus error, but the only way</span>
</span>
<span class="line" id="L542">    <span class="tok-comment">// to discard a const qualifier is through ptrToInt, which</span>
</span>
<span class="line" id="L543">    <span class="tok-comment">// cannot currently round trip at comptime.</span>
</span>
<span class="line" id="L544">    <span class="tok-kw">var</span> empty_masks_data = [_]MaskInt{ <span class="tok-number">0</span>, <span class="tok-null">undefined</span> };</span>
<span class="line" id="L545">    <span class="tok-kw">const</span> empty_masks_ptr = empty_masks_data[<span class="tok-number">1</span>..<span class="tok-number">2</span>];</span>
<span class="line" id="L546"></span>
<span class="line" id="L547">    <span class="tok-comment">/// Creates a bit set with no elements present.</span></span>
<span class="line" id="L548">    <span class="tok-comment">/// If bit_length is not zero, deinit must eventually be called.</span></span>
<span class="line" id="L549">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">initEmpty</span>(allocator: Allocator, bit_length: <span class="tok-type">usize</span>) !Self {</span>
<span class="line" id="L550">        <span class="tok-kw">var</span> self = Self{};</span>
<span class="line" id="L551">        <span class="tok-kw">try</span> self.resize(allocator, bit_length, <span class="tok-null">false</span>);</span>
<span class="line" id="L552">        <span class="tok-kw">return</span> self;</span>
<span class="line" id="L553">    }</span>
<span class="line" id="L554"></span>
<span class="line" id="L555">    <span class="tok-comment">/// Creates a bit set with all elements present.</span></span>
<span class="line" id="L556">    <span class="tok-comment">/// If bit_length is not zero, deinit must eventually be called.</span></span>
<span class="line" id="L557">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">initFull</span>(allocator: Allocator, bit_length: <span class="tok-type">usize</span>) !Self {</span>
<span class="line" id="L558">        <span class="tok-kw">var</span> self = Self{};</span>
<span class="line" id="L559">        <span class="tok-kw">try</span> self.resize(allocator, bit_length, <span class="tok-null">true</span>);</span>
<span class="line" id="L560">        <span class="tok-kw">return</span> self;</span>
<span class="line" id="L561">    }</span>
<span class="line" id="L562"></span>
<span class="line" id="L563">    <span class="tok-comment">/// Resizes to a new bit_length.  If the new length is larger</span></span>
<span class="line" id="L564">    <span class="tok-comment">/// than the old length, fills any added bits with `fill`.</span></span>
<span class="line" id="L565">    <span class="tok-comment">/// If new_len is not zero, deinit must eventually be called.</span></span>
<span class="line" id="L566">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">resize</span>(self: *<span class="tok-builtin">@This</span>(), allocator: Allocator, new_len: <span class="tok-type">usize</span>, fill: <span class="tok-type">bool</span>) !<span class="tok-type">void</span> {</span>
<span class="line" id="L567">        <span class="tok-kw">const</span> old_len = self.bit_length;</span>
<span class="line" id="L568"></span>
<span class="line" id="L569">        <span class="tok-kw">const</span> old_masks = numMasks(old_len);</span>
<span class="line" id="L570">        <span class="tok-kw">const</span> new_masks = numMasks(new_len);</span>
<span class="line" id="L571"></span>
<span class="line" id="L572">        <span class="tok-kw">const</span> old_allocation = (self.masks - <span class="tok-number">1</span>)[<span class="tok-number">0</span>..(self.masks - <span class="tok-number">1</span>)[<span class="tok-number">0</span>]];</span>
<span class="line" id="L573"></span>
<span class="line" id="L574">        <span class="tok-kw">if</span> (new_masks == <span class="tok-number">0</span>) {</span>
<span class="line" id="L575">            assert(new_len == <span class="tok-number">0</span>);</span>
<span class="line" id="L576">            allocator.free(old_allocation);</span>
<span class="line" id="L577">            self.masks = empty_masks_ptr;</span>
<span class="line" id="L578">            self.bit_length = <span class="tok-number">0</span>;</span>
<span class="line" id="L579">            <span class="tok-kw">return</span>;</span>
<span class="line" id="L580">        }</span>
<span class="line" id="L581"></span>
<span class="line" id="L582">        <span class="tok-kw">if</span> (old_allocation.len != new_masks + <span class="tok-number">1</span>) realloc: {</span>
<span class="line" id="L583">            <span class="tok-comment">// If realloc fails, it may mean one of two things.</span>
</span>
<span class="line" id="L584">            <span class="tok-comment">// If we are growing, it means we are out of memory.</span>
</span>
<span class="line" id="L585">            <span class="tok-comment">// If we are shrinking, it means the allocator doesn't</span>
</span>
<span class="line" id="L586">            <span class="tok-comment">// want to move the allocation.  This means we need to</span>
</span>
<span class="line" id="L587">            <span class="tok-comment">// hold on to the extra 8 bytes required to be able to free</span>
</span>
<span class="line" id="L588">            <span class="tok-comment">// this allocation properly.</span>
</span>
<span class="line" id="L589">            <span class="tok-kw">const</span> new_allocation = allocator.realloc(old_allocation, new_masks + <span class="tok-number">1</span>) <span class="tok-kw">catch</span> |err| {</span>
<span class="line" id="L590">                <span class="tok-kw">if</span> (new_masks + <span class="tok-number">1</span> &gt; old_allocation.len) <span class="tok-kw">return</span> err;</span>
<span class="line" id="L591">                <span class="tok-kw">break</span> :realloc;</span>
<span class="line" id="L592">            };</span>
<span class="line" id="L593"></span>
<span class="line" id="L594">            new_allocation[<span class="tok-number">0</span>] = new_allocation.len;</span>
<span class="line" id="L595">            self.masks = new_allocation.ptr + <span class="tok-number">1</span>;</span>
<span class="line" id="L596">        }</span>
<span class="line" id="L597"></span>
<span class="line" id="L598">        <span class="tok-comment">// If we increased in size, we need to set any new bits</span>
</span>
<span class="line" id="L599">        <span class="tok-comment">// to the fill value.</span>
</span>
<span class="line" id="L600">        <span class="tok-kw">if</span> (new_len &gt; old_len) {</span>
<span class="line" id="L601">            <span class="tok-comment">// set the padding bits in the old last item to 1</span>
</span>
<span class="line" id="L602">            <span class="tok-kw">if</span> (fill <span class="tok-kw">and</span> old_masks &gt; <span class="tok-number">0</span>) {</span>
<span class="line" id="L603">                <span class="tok-kw">const</span> old_padding_bits = old_masks * <span class="tok-builtin">@bitSizeOf</span>(MaskInt) - old_len;</span>
<span class="line" id="L604">                <span class="tok-kw">const</span> old_mask = (~<span class="tok-builtin">@as</span>(MaskInt, <span class="tok-number">0</span>)) &gt;&gt; <span class="tok-builtin">@intCast</span>(ShiftInt, old_padding_bits);</span>
<span class="line" id="L605">                self.masks[old_masks - <span class="tok-number">1</span>] |= ~old_mask;</span>
<span class="line" id="L606">            }</span>
<span class="line" id="L607"></span>
<span class="line" id="L608">            <span class="tok-comment">// fill in any new masks</span>
</span>
<span class="line" id="L609">            <span class="tok-kw">if</span> (new_masks &gt; old_masks) {</span>
<span class="line" id="L610">                <span class="tok-kw">const</span> fill_value = std.math.boolMask(MaskInt, fill);</span>
<span class="line" id="L611">                std.mem.set(MaskInt, self.masks[old_masks..new_masks], fill_value);</span>
<span class="line" id="L612">            }</span>
<span class="line" id="L613">        }</span>
<span class="line" id="L614"></span>
<span class="line" id="L615">        <span class="tok-comment">// Zero out the padding bits</span>
</span>
<span class="line" id="L616">        <span class="tok-kw">if</span> (new_len &gt; <span class="tok-number">0</span>) {</span>
<span class="line" id="L617">            <span class="tok-kw">const</span> padding_bits = new_masks * <span class="tok-builtin">@bitSizeOf</span>(MaskInt) - new_len;</span>
<span class="line" id="L618">            <span class="tok-kw">const</span> last_item_mask = (~<span class="tok-builtin">@as</span>(MaskInt, <span class="tok-number">0</span>)) &gt;&gt; <span class="tok-builtin">@intCast</span>(ShiftInt, padding_bits);</span>
<span class="line" id="L619">            self.masks[new_masks - <span class="tok-number">1</span>] &amp;= last_item_mask;</span>
<span class="line" id="L620">        }</span>
<span class="line" id="L621"></span>
<span class="line" id="L622">        <span class="tok-comment">// And finally, save the new length.</span>
</span>
<span class="line" id="L623">        self.bit_length = new_len;</span>
<span class="line" id="L624">    }</span>
<span class="line" id="L625"></span>
<span class="line" id="L626">    <span class="tok-comment">/// deinitializes the array and releases its memory.</span></span>
<span class="line" id="L627">    <span class="tok-comment">/// The passed allocator must be the same one used for</span></span>
<span class="line" id="L628">    <span class="tok-comment">/// init* or resize in the past.</span></span>
<span class="line" id="L629">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">deinit</span>(self: *Self, allocator: Allocator) <span class="tok-type">void</span> {</span>
<span class="line" id="L630">        self.resize(allocator, <span class="tok-number">0</span>, <span class="tok-null">false</span>) <span class="tok-kw">catch</span> <span class="tok-kw">unreachable</span>;</span>
<span class="line" id="L631">    }</span>
<span class="line" id="L632"></span>
<span class="line" id="L633">    <span class="tok-comment">/// Creates a duplicate of this bit set, using the new allocator.</span></span>
<span class="line" id="L634">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">clone</span>(self: *<span class="tok-kw">const</span> Self, new_allocator: Allocator) !Self {</span>
<span class="line" id="L635">        <span class="tok-kw">const</span> num_masks = numMasks(self.bit_length);</span>
<span class="line" id="L636">        <span class="tok-kw">var</span> copy = Self{};</span>
<span class="line" id="L637">        <span class="tok-kw">try</span> copy.resize(new_allocator, self.bit_length, <span class="tok-null">false</span>);</span>
<span class="line" id="L638">        std.mem.copy(MaskInt, copy.masks[<span class="tok-number">0</span>..num_masks], self.masks[<span class="tok-number">0</span>..num_masks]);</span>
<span class="line" id="L639">        <span class="tok-kw">return</span> copy;</span>
<span class="line" id="L640">    }</span>
<span class="line" id="L641"></span>
<span class="line" id="L642">    <span class="tok-comment">/// Returns the number of bits in this bit set</span></span>
<span class="line" id="L643">    <span class="tok-kw">pub</span> <span class="tok-kw">inline</span> <span class="tok-kw">fn</span> <span class="tok-fn">capacity</span>(self: Self) <span class="tok-type">usize</span> {</span>
<span class="line" id="L644">        <span class="tok-kw">return</span> self.bit_length;</span>
<span class="line" id="L645">    }</span>
<span class="line" id="L646"></span>
<span class="line" id="L647">    <span class="tok-comment">/// Returns true if the bit at the specified index</span></span>
<span class="line" id="L648">    <span class="tok-comment">/// is present in the set, false otherwise.</span></span>
<span class="line" id="L649">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">isSet</span>(self: Self, index: <span class="tok-type">usize</span>) <span class="tok-type">bool</span> {</span>
<span class="line" id="L650">        assert(index &lt; self.bit_length);</span>
<span class="line" id="L651">        <span class="tok-kw">return</span> (self.masks[maskIndex(index)] &amp; maskBit(index)) != <span class="tok-number">0</span>;</span>
<span class="line" id="L652">    }</span>
<span class="line" id="L653"></span>
<span class="line" id="L654">    <span class="tok-comment">/// Returns the total number of set bits in this bit set.</span></span>
<span class="line" id="L655">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">count</span>(self: Self) <span class="tok-type">usize</span> {</span>
<span class="line" id="L656">        <span class="tok-kw">const</span> num_masks = (self.bit_length + (<span class="tok-builtin">@bitSizeOf</span>(MaskInt) - <span class="tok-number">1</span>)) / <span class="tok-builtin">@bitSizeOf</span>(MaskInt);</span>
<span class="line" id="L657">        <span class="tok-kw">var</span> total: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L658">        <span class="tok-kw">for</span> (self.masks[<span class="tok-number">0</span>..num_masks]) |mask| {</span>
<span class="line" id="L659">            <span class="tok-comment">// Note: This is where we depend on padding bits being zero</span>
</span>
<span class="line" id="L660">            total += <span class="tok-builtin">@popCount</span>(MaskInt, mask);</span>
<span class="line" id="L661">        }</span>
<span class="line" id="L662">        <span class="tok-kw">return</span> total;</span>
<span class="line" id="L663">    }</span>
<span class="line" id="L664"></span>
<span class="line" id="L665">    <span class="tok-comment">/// Changes the value of the specified bit of the bit</span></span>
<span class="line" id="L666">    <span class="tok-comment">/// set to match the passed boolean.</span></span>
<span class="line" id="L667">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">setValue</span>(self: *Self, index: <span class="tok-type">usize</span>, value: <span class="tok-type">bool</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L668">        assert(index &lt; self.bit_length);</span>
<span class="line" id="L669">        <span class="tok-kw">const</span> bit = maskBit(index);</span>
<span class="line" id="L670">        <span class="tok-kw">const</span> mask_index = maskIndex(index);</span>
<span class="line" id="L671">        <span class="tok-kw">const</span> new_bit = bit &amp; std.math.boolMask(MaskInt, value);</span>
<span class="line" id="L672">        self.masks[mask_index] = (self.masks[mask_index] &amp; ~bit) | new_bit;</span>
<span class="line" id="L673">    }</span>
<span class="line" id="L674"></span>
<span class="line" id="L675">    <span class="tok-comment">/// Adds a specific bit to the bit set</span></span>
<span class="line" id="L676">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">set</span>(self: *Self, index: <span class="tok-type">usize</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L677">        assert(index &lt; self.bit_length);</span>
<span class="line" id="L678">        self.masks[maskIndex(index)] |= maskBit(index);</span>
<span class="line" id="L679">    }</span>
<span class="line" id="L680"></span>
<span class="line" id="L681">    <span class="tok-comment">/// Changes the value of all bits in the specified range to</span></span>
<span class="line" id="L682">    <span class="tok-comment">/// match the passed boolean.</span></span>
<span class="line" id="L683">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">setRangeValue</span>(self: *Self, range: Range, value: <span class="tok-type">bool</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L684">        assert(range.end &lt;= self.bit_length);</span>
<span class="line" id="L685">        assert(range.start &lt;= range.end);</span>
<span class="line" id="L686">        <span class="tok-kw">if</span> (range.start == range.end) <span class="tok-kw">return</span>;</span>
<span class="line" id="L687"></span>
<span class="line" id="L688">        <span class="tok-kw">const</span> start_mask_index = maskIndex(range.start);</span>
<span class="line" id="L689">        <span class="tok-kw">const</span> start_bit = <span class="tok-builtin">@truncate</span>(ShiftInt, range.start);</span>
<span class="line" id="L690"></span>
<span class="line" id="L691">        <span class="tok-kw">const</span> end_mask_index = maskIndex(range.end);</span>
<span class="line" id="L692">        <span class="tok-kw">const</span> end_bit = <span class="tok-builtin">@truncate</span>(ShiftInt, range.end);</span>
<span class="line" id="L693"></span>
<span class="line" id="L694">        <span class="tok-kw">if</span> (start_mask_index == end_mask_index) {</span>
<span class="line" id="L695">            <span class="tok-kw">var</span> mask1 = std.math.boolMask(MaskInt, <span class="tok-null">true</span>) &lt;&lt; start_bit;</span>
<span class="line" id="L696">            <span class="tok-kw">var</span> mask2 = std.math.boolMask(MaskInt, <span class="tok-null">true</span>) &gt;&gt; (<span class="tok-builtin">@bitSizeOf</span>(MaskInt) - <span class="tok-number">1</span>) - (end_bit - <span class="tok-number">1</span>);</span>
<span class="line" id="L697">            self.masks[start_mask_index] &amp;= ~(mask1 &amp; mask2);</span>
<span class="line" id="L698"></span>
<span class="line" id="L699">            mask1 = std.math.boolMask(MaskInt, value) &lt;&lt; start_bit;</span>
<span class="line" id="L700">            mask2 = std.math.boolMask(MaskInt, value) &gt;&gt; (<span class="tok-builtin">@bitSizeOf</span>(MaskInt) - <span class="tok-number">1</span>) - (end_bit - <span class="tok-number">1</span>);</span>
<span class="line" id="L701">            self.masks[start_mask_index] |= mask1 &amp; mask2;</span>
<span class="line" id="L702">        } <span class="tok-kw">else</span> {</span>
<span class="line" id="L703">            <span class="tok-kw">var</span> bulk_mask_index: <span class="tok-type">usize</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L704">            <span class="tok-kw">if</span> (start_bit &gt; <span class="tok-number">0</span>) {</span>
<span class="line" id="L705">                self.masks[start_mask_index] =</span>
<span class="line" id="L706">                    (self.masks[start_mask_index] &amp; ~(std.math.boolMask(MaskInt, <span class="tok-null">true</span>) &lt;&lt; start_bit)) |</span>
<span class="line" id="L707">                    (std.math.boolMask(MaskInt, value) &lt;&lt; start_bit);</span>
<span class="line" id="L708">                bulk_mask_index = start_mask_index + <span class="tok-number">1</span>;</span>
<span class="line" id="L709">            } <span class="tok-kw">else</span> {</span>
<span class="line" id="L710">                bulk_mask_index = start_mask_index;</span>
<span class="line" id="L711">            }</span>
<span class="line" id="L712"></span>
<span class="line" id="L713">            <span class="tok-kw">while</span> (bulk_mask_index &lt; end_mask_index) : (bulk_mask_index += <span class="tok-number">1</span>) {</span>
<span class="line" id="L714">                self.masks[bulk_mask_index] = std.math.boolMask(MaskInt, value);</span>
<span class="line" id="L715">            }</span>
<span class="line" id="L716"></span>
<span class="line" id="L717">            <span class="tok-kw">if</span> (end_bit &gt; <span class="tok-number">0</span>) {</span>
<span class="line" id="L718">                self.masks[end_mask_index] =</span>
<span class="line" id="L719">                    (self.masks[end_mask_index] &amp; (std.math.boolMask(MaskInt, <span class="tok-null">true</span>) &lt;&lt; end_bit)) |</span>
<span class="line" id="L720">                    (std.math.boolMask(MaskInt, value) &gt;&gt; ((<span class="tok-builtin">@bitSizeOf</span>(MaskInt) - <span class="tok-number">1</span>) - (end_bit - <span class="tok-number">1</span>)));</span>
<span class="line" id="L721">            }</span>
<span class="line" id="L722">        }</span>
<span class="line" id="L723">    }</span>
<span class="line" id="L724"></span>
<span class="line" id="L725">    <span class="tok-comment">/// Removes a specific bit from the bit set</span></span>
<span class="line" id="L726">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">unset</span>(self: *Self, index: <span class="tok-type">usize</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L727">        assert(index &lt; self.bit_length);</span>
<span class="line" id="L728">        self.masks[maskIndex(index)] &amp;= ~maskBit(index);</span>
<span class="line" id="L729">    }</span>
<span class="line" id="L730"></span>
<span class="line" id="L731">    <span class="tok-comment">/// Flips a specific bit in the bit set</span></span>
<span class="line" id="L732">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">toggle</span>(self: *Self, index: <span class="tok-type">usize</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L733">        assert(index &lt; self.bit_length);</span>
<span class="line" id="L734">        self.masks[maskIndex(index)] ^= maskBit(index);</span>
<span class="line" id="L735">    }</span>
<span class="line" id="L736"></span>
<span class="line" id="L737">    <span class="tok-comment">/// Flips all bits in this bit set which are present</span></span>
<span class="line" id="L738">    <span class="tok-comment">/// in the toggles bit set.  Both sets must have the</span></span>
<span class="line" id="L739">    <span class="tok-comment">/// same bit_length.</span></span>
<span class="line" id="L740">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">toggleSet</span>(self: *Self, toggles: Self) <span class="tok-type">void</span> {</span>
<span class="line" id="L741">        assert(toggles.bit_length == self.bit_length);</span>
<span class="line" id="L742">        <span class="tok-kw">const</span> num_masks = numMasks(self.bit_length);</span>
<span class="line" id="L743">        <span class="tok-kw">for</span> (self.masks[<span class="tok-number">0</span>..num_masks]) |*mask, i| {</span>
<span class="line" id="L744">            mask.* ^= toggles.masks[i];</span>
<span class="line" id="L745">        }</span>
<span class="line" id="L746">    }</span>
<span class="line" id="L747"></span>
<span class="line" id="L748">    <span class="tok-comment">/// Flips every bit in the bit set.</span></span>
<span class="line" id="L749">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">toggleAll</span>(self: *Self) <span class="tok-type">void</span> {</span>
<span class="line" id="L750">        <span class="tok-kw">const</span> bit_length = self.bit_length;</span>
<span class="line" id="L751">        <span class="tok-comment">// avoid underflow if bit_length is zero</span>
</span>
<span class="line" id="L752">        <span class="tok-kw">if</span> (bit_length == <span class="tok-number">0</span>) <span class="tok-kw">return</span>;</span>
<span class="line" id="L753"></span>
<span class="line" id="L754">        <span class="tok-kw">const</span> num_masks = numMasks(self.bit_length);</span>
<span class="line" id="L755">        <span class="tok-kw">for</span> (self.masks[<span class="tok-number">0</span>..num_masks]) |*mask| {</span>
<span class="line" id="L756">            mask.* = ~mask.*;</span>
<span class="line" id="L757">        }</span>
<span class="line" id="L758"></span>
<span class="line" id="L759">        <span class="tok-kw">const</span> padding_bits = num_masks * <span class="tok-builtin">@bitSizeOf</span>(MaskInt) - bit_length;</span>
<span class="line" id="L760">        <span class="tok-kw">const</span> last_item_mask = (~<span class="tok-builtin">@as</span>(MaskInt, <span class="tok-number">0</span>)) &gt;&gt; <span class="tok-builtin">@intCast</span>(ShiftInt, padding_bits);</span>
<span class="line" id="L761">        self.masks[num_masks - <span class="tok-number">1</span>] &amp;= last_item_mask;</span>
<span class="line" id="L762">    }</span>
<span class="line" id="L763"></span>
<span class="line" id="L764">    <span class="tok-comment">/// Performs a union of two bit sets, and stores the</span></span>
<span class="line" id="L765">    <span class="tok-comment">/// result in the first one.  Bits in the result are</span></span>
<span class="line" id="L766">    <span class="tok-comment">/// set if the corresponding bits were set in either input.</span></span>
<span class="line" id="L767">    <span class="tok-comment">/// The two sets must both be the same bit_length.</span></span>
<span class="line" id="L768">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">setUnion</span>(self: *Self, other: Self) <span class="tok-type">void</span> {</span>
<span class="line" id="L769">        assert(other.bit_length == self.bit_length);</span>
<span class="line" id="L770">        <span class="tok-kw">const</span> num_masks = numMasks(self.bit_length);</span>
<span class="line" id="L771">        <span class="tok-kw">for</span> (self.masks[<span class="tok-number">0</span>..num_masks]) |*mask, i| {</span>
<span class="line" id="L772">            mask.* |= other.masks[i];</span>
<span class="line" id="L773">        }</span>
<span class="line" id="L774">    }</span>
<span class="line" id="L775"></span>
<span class="line" id="L776">    <span class="tok-comment">/// Performs an intersection of two bit sets, and stores</span></span>
<span class="line" id="L777">    <span class="tok-comment">/// the result in the first one.  Bits in the result are</span></span>
<span class="line" id="L778">    <span class="tok-comment">/// set if the corresponding bits were set in both inputs.</span></span>
<span class="line" id="L779">    <span class="tok-comment">/// The two sets must both be the same bit_length.</span></span>
<span class="line" id="L780">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">setIntersection</span>(self: *Self, other: Self) <span class="tok-type">void</span> {</span>
<span class="line" id="L781">        assert(other.bit_length == self.bit_length);</span>
<span class="line" id="L782">        <span class="tok-kw">const</span> num_masks = numMasks(self.bit_length);</span>
<span class="line" id="L783">        <span class="tok-kw">for</span> (self.masks[<span class="tok-number">0</span>..num_masks]) |*mask, i| {</span>
<span class="line" id="L784">            mask.* &amp;= other.masks[i];</span>
<span class="line" id="L785">        }</span>
<span class="line" id="L786">    }</span>
<span class="line" id="L787"></span>
<span class="line" id="L788">    <span class="tok-comment">/// Finds the index of the first set bit.</span></span>
<span class="line" id="L789">    <span class="tok-comment">/// If no bits are set, returns null.</span></span>
<span class="line" id="L790">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">findFirstSet</span>(self: Self) ?<span class="tok-type">usize</span> {</span>
<span class="line" id="L791">        <span class="tok-kw">var</span> offset: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L792">        <span class="tok-kw">var</span> mask = self.masks;</span>
<span class="line" id="L793">        <span class="tok-kw">while</span> (offset &lt; self.bit_length) {</span>
<span class="line" id="L794">            <span class="tok-kw">if</span> (mask[<span class="tok-number">0</span>] != <span class="tok-number">0</span>) <span class="tok-kw">break</span>;</span>
<span class="line" id="L795">            mask += <span class="tok-number">1</span>;</span>
<span class="line" id="L796">            offset += <span class="tok-builtin">@bitSizeOf</span>(MaskInt);</span>
<span class="line" id="L797">        } <span class="tok-kw">else</span> <span class="tok-kw">return</span> <span class="tok-null">null</span>;</span>
<span class="line" id="L798">        <span class="tok-kw">return</span> offset + <span class="tok-builtin">@ctz</span>(MaskInt, mask[<span class="tok-number">0</span>]);</span>
<span class="line" id="L799">    }</span>
<span class="line" id="L800"></span>
<span class="line" id="L801">    <span class="tok-comment">/// Finds the index of the first set bit, and unsets it.</span></span>
<span class="line" id="L802">    <span class="tok-comment">/// If no bits are set, returns null.</span></span>
<span class="line" id="L803">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">toggleFirstSet</span>(self: *Self) ?<span class="tok-type">usize</span> {</span>
<span class="line" id="L804">        <span class="tok-kw">var</span> offset: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L805">        <span class="tok-kw">var</span> mask = self.masks;</span>
<span class="line" id="L806">        <span class="tok-kw">while</span> (offset &lt; self.bit_length) {</span>
<span class="line" id="L807">            <span class="tok-kw">if</span> (mask[<span class="tok-number">0</span>] != <span class="tok-number">0</span>) <span class="tok-kw">break</span>;</span>
<span class="line" id="L808">            mask += <span class="tok-number">1</span>;</span>
<span class="line" id="L809">            offset += <span class="tok-builtin">@bitSizeOf</span>(MaskInt);</span>
<span class="line" id="L810">        } <span class="tok-kw">else</span> <span class="tok-kw">return</span> <span class="tok-null">null</span>;</span>
<span class="line" id="L811">        <span class="tok-kw">const</span> index = <span class="tok-builtin">@ctz</span>(MaskInt, mask[<span class="tok-number">0</span>]);</span>
<span class="line" id="L812">        mask[<span class="tok-number">0</span>] &amp;= (mask[<span class="tok-number">0</span>] - <span class="tok-number">1</span>);</span>
<span class="line" id="L813">        <span class="tok-kw">return</span> offset + index;</span>
<span class="line" id="L814">    }</span>
<span class="line" id="L815"></span>
<span class="line" id="L816">    <span class="tok-comment">/// Iterates through the items in the set, according to the options.</span></span>
<span class="line" id="L817">    <span class="tok-comment">/// The default options (.{}) will iterate indices of set bits in</span></span>
<span class="line" id="L818">    <span class="tok-comment">/// ascending order.  Modifications to the underlying bit set may</span></span>
<span class="line" id="L819">    <span class="tok-comment">/// or may not be observed by the iterator.  Resizing the underlying</span></span>
<span class="line" id="L820">    <span class="tok-comment">/// bit set invalidates the iterator.</span></span>
<span class="line" id="L821">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">iterator</span>(self: *<span class="tok-kw">const</span> Self, <span class="tok-kw">comptime</span> options: IteratorOptions) Iterator(options) {</span>
<span class="line" id="L822">        <span class="tok-kw">const</span> num_masks = numMasks(self.bit_length);</span>
<span class="line" id="L823">        <span class="tok-kw">const</span> padding_bits = num_masks * <span class="tok-builtin">@bitSizeOf</span>(MaskInt) - self.bit_length;</span>
<span class="line" id="L824">        <span class="tok-kw">const</span> last_item_mask = (~<span class="tok-builtin">@as</span>(MaskInt, <span class="tok-number">0</span>)) &gt;&gt; <span class="tok-builtin">@intCast</span>(ShiftInt, padding_bits);</span>
<span class="line" id="L825">        <span class="tok-kw">return</span> Iterator(options).init(self.masks[<span class="tok-number">0</span>..num_masks], last_item_mask);</span>
<span class="line" id="L826">    }</span>
<span class="line" id="L827"></span>
<span class="line" id="L828">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">Iterator</span>(<span class="tok-kw">comptime</span> options: IteratorOptions) <span class="tok-type">type</span> {</span>
<span class="line" id="L829">        <span class="tok-kw">return</span> BitSetIterator(MaskInt, options);</span>
<span class="line" id="L830">    }</span>
<span class="line" id="L831"></span>
<span class="line" id="L832">    <span class="tok-kw">fn</span> <span class="tok-fn">maskBit</span>(index: <span class="tok-type">usize</span>) MaskInt {</span>
<span class="line" id="L833">        <span class="tok-kw">return</span> <span class="tok-builtin">@as</span>(MaskInt, <span class="tok-number">1</span>) &lt;&lt; <span class="tok-builtin">@truncate</span>(ShiftInt, index);</span>
<span class="line" id="L834">    }</span>
<span class="line" id="L835">    <span class="tok-kw">fn</span> <span class="tok-fn">maskIndex</span>(index: <span class="tok-type">usize</span>) <span class="tok-type">usize</span> {</span>
<span class="line" id="L836">        <span class="tok-kw">return</span> index &gt;&gt; <span class="tok-builtin">@bitSizeOf</span>(ShiftInt);</span>
<span class="line" id="L837">    }</span>
<span class="line" id="L838">    <span class="tok-kw">fn</span> <span class="tok-fn">boolMaskBit</span>(index: <span class="tok-type">usize</span>, value: <span class="tok-type">bool</span>) MaskInt {</span>
<span class="line" id="L839">        <span class="tok-kw">return</span> <span class="tok-builtin">@as</span>(MaskInt, <span class="tok-builtin">@boolToInt</span>(value)) &lt;&lt; <span class="tok-builtin">@intCast</span>(ShiftInt, index);</span>
<span class="line" id="L840">    }</span>
<span class="line" id="L841">    <span class="tok-kw">fn</span> <span class="tok-fn">numMasks</span>(bit_length: <span class="tok-type">usize</span>) <span class="tok-type">usize</span> {</span>
<span class="line" id="L842">        <span class="tok-kw">return</span> (bit_length + (<span class="tok-builtin">@bitSizeOf</span>(MaskInt) - <span class="tok-number">1</span>)) / <span class="tok-builtin">@bitSizeOf</span>(MaskInt);</span>
<span class="line" id="L843">    }</span>
<span class="line" id="L844">};</span>
<span class="line" id="L845"></span>
<span class="line" id="L846"><span class="tok-comment">/// A bit set with runtime known size, backed by an allocated slice</span></span>
<span class="line" id="L847"><span class="tok-comment">/// of usize.  Thin wrapper around DynamicBitSetUnmanaged which keeps</span></span>
<span class="line" id="L848"><span class="tok-comment">/// track of the allocator instance.</span></span>
<span class="line" id="L849"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> DynamicBitSet = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L850">    <span class="tok-kw">const</span> Self = <span class="tok-builtin">@This</span>();</span>
<span class="line" id="L851"></span>
<span class="line" id="L852">    <span class="tok-comment">/// The integer type used to represent a mask in this bit set</span></span>
<span class="line" id="L853">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> MaskInt = <span class="tok-type">usize</span>;</span>
<span class="line" id="L854"></span>
<span class="line" id="L855">    <span class="tok-comment">/// The integer type used to shift a mask in this bit set</span></span>
<span class="line" id="L856">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> ShiftInt = std.math.Log2Int(MaskInt);</span>
<span class="line" id="L857"></span>
<span class="line" id="L858">    <span class="tok-comment">/// The allocator used by this bit set</span></span>
<span class="line" id="L859">    allocator: Allocator,</span>
<span class="line" id="L860"></span>
<span class="line" id="L861">    <span class="tok-comment">/// The number of valid items in this bit set</span></span>
<span class="line" id="L862">    unmanaged: DynamicBitSetUnmanaged = .{},</span>
<span class="line" id="L863"></span>
<span class="line" id="L864">    <span class="tok-comment">/// Creates a bit set with no elements present.</span></span>
<span class="line" id="L865">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">initEmpty</span>(allocator: Allocator, bit_length: <span class="tok-type">usize</span>) !Self {</span>
<span class="line" id="L866">        <span class="tok-kw">return</span> Self{</span>
<span class="line" id="L867">            .unmanaged = <span class="tok-kw">try</span> DynamicBitSetUnmanaged.initEmpty(allocator, bit_length),</span>
<span class="line" id="L868">            .allocator = allocator,</span>
<span class="line" id="L869">        };</span>
<span class="line" id="L870">    }</span>
<span class="line" id="L871"></span>
<span class="line" id="L872">    <span class="tok-comment">/// Creates a bit set with all elements present.</span></span>
<span class="line" id="L873">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">initFull</span>(allocator: Allocator, bit_length: <span class="tok-type">usize</span>) !Self {</span>
<span class="line" id="L874">        <span class="tok-kw">return</span> Self{</span>
<span class="line" id="L875">            .unmanaged = <span class="tok-kw">try</span> DynamicBitSetUnmanaged.initFull(allocator, bit_length),</span>
<span class="line" id="L876">            .allocator = allocator,</span>
<span class="line" id="L877">        };</span>
<span class="line" id="L878">    }</span>
<span class="line" id="L879"></span>
<span class="line" id="L880">    <span class="tok-comment">/// Resizes to a new length.  If the new length is larger</span></span>
<span class="line" id="L881">    <span class="tok-comment">/// than the old length, fills any added bits with `fill`.</span></span>
<span class="line" id="L882">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">resize</span>(self: *<span class="tok-builtin">@This</span>(), new_len: <span class="tok-type">usize</span>, fill: <span class="tok-type">bool</span>) !<span class="tok-type">void</span> {</span>
<span class="line" id="L883">        <span class="tok-kw">try</span> self.unmanaged.resize(self.allocator, new_len, fill);</span>
<span class="line" id="L884">    }</span>
<span class="line" id="L885"></span>
<span class="line" id="L886">    <span class="tok-comment">/// deinitializes the array and releases its memory.</span></span>
<span class="line" id="L887">    <span class="tok-comment">/// The passed allocator must be the same one used for</span></span>
<span class="line" id="L888">    <span class="tok-comment">/// init* or resize in the past.</span></span>
<span class="line" id="L889">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">deinit</span>(self: *Self) <span class="tok-type">void</span> {</span>
<span class="line" id="L890">        self.unmanaged.deinit(self.allocator);</span>
<span class="line" id="L891">    }</span>
<span class="line" id="L892"></span>
<span class="line" id="L893">    <span class="tok-comment">/// Creates a duplicate of this bit set, using the new allocator.</span></span>
<span class="line" id="L894">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">clone</span>(self: *<span class="tok-kw">const</span> Self, new_allocator: Allocator) !Self {</span>
<span class="line" id="L895">        <span class="tok-kw">return</span> Self{</span>
<span class="line" id="L896">            .unmanaged = <span class="tok-kw">try</span> self.unmanaged.clone(new_allocator),</span>
<span class="line" id="L897">            .allocator = new_allocator,</span>
<span class="line" id="L898">        };</span>
<span class="line" id="L899">    }</span>
<span class="line" id="L900"></span>
<span class="line" id="L901">    <span class="tok-comment">/// Returns the number of bits in this bit set</span></span>
<span class="line" id="L902">    <span class="tok-kw">pub</span> <span class="tok-kw">inline</span> <span class="tok-kw">fn</span> <span class="tok-fn">capacity</span>(self: Self) <span class="tok-type">usize</span> {</span>
<span class="line" id="L903">        <span class="tok-kw">return</span> self.unmanaged.capacity();</span>
<span class="line" id="L904">    }</span>
<span class="line" id="L905"></span>
<span class="line" id="L906">    <span class="tok-comment">/// Returns true if the bit at the specified index</span></span>
<span class="line" id="L907">    <span class="tok-comment">/// is present in the set, false otherwise.</span></span>
<span class="line" id="L908">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">isSet</span>(self: Self, index: <span class="tok-type">usize</span>) <span class="tok-type">bool</span> {</span>
<span class="line" id="L909">        <span class="tok-kw">return</span> self.unmanaged.isSet(index);</span>
<span class="line" id="L910">    }</span>
<span class="line" id="L911"></span>
<span class="line" id="L912">    <span class="tok-comment">/// Returns the total number of set bits in this bit set.</span></span>
<span class="line" id="L913">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">count</span>(self: Self) <span class="tok-type">usize</span> {</span>
<span class="line" id="L914">        <span class="tok-kw">return</span> self.unmanaged.count();</span>
<span class="line" id="L915">    }</span>
<span class="line" id="L916"></span>
<span class="line" id="L917">    <span class="tok-comment">/// Changes the value of the specified bit of the bit</span></span>
<span class="line" id="L918">    <span class="tok-comment">/// set to match the passed boolean.</span></span>
<span class="line" id="L919">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">setValue</span>(self: *Self, index: <span class="tok-type">usize</span>, value: <span class="tok-type">bool</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L920">        self.unmanaged.setValue(index, value);</span>
<span class="line" id="L921">    }</span>
<span class="line" id="L922"></span>
<span class="line" id="L923">    <span class="tok-comment">/// Adds a specific bit to the bit set</span></span>
<span class="line" id="L924">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">set</span>(self: *Self, index: <span class="tok-type">usize</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L925">        self.unmanaged.set(index);</span>
<span class="line" id="L926">    }</span>
<span class="line" id="L927"></span>
<span class="line" id="L928">    <span class="tok-comment">/// Changes the value of all bits in the specified range to</span></span>
<span class="line" id="L929">    <span class="tok-comment">/// match the passed boolean.</span></span>
<span class="line" id="L930">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">setRangeValue</span>(self: *Self, range: Range, value: <span class="tok-type">bool</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L931">        self.unmanaged.setRangeValue(range, value);</span>
<span class="line" id="L932">    }</span>
<span class="line" id="L933"></span>
<span class="line" id="L934">    <span class="tok-comment">/// Removes a specific bit from the bit set</span></span>
<span class="line" id="L935">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">unset</span>(self: *Self, index: <span class="tok-type">usize</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L936">        self.unmanaged.unset(index);</span>
<span class="line" id="L937">    }</span>
<span class="line" id="L938"></span>
<span class="line" id="L939">    <span class="tok-comment">/// Flips a specific bit in the bit set</span></span>
<span class="line" id="L940">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">toggle</span>(self: *Self, index: <span class="tok-type">usize</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L941">        self.unmanaged.toggle(index);</span>
<span class="line" id="L942">    }</span>
<span class="line" id="L943"></span>
<span class="line" id="L944">    <span class="tok-comment">/// Flips all bits in this bit set which are present</span></span>
<span class="line" id="L945">    <span class="tok-comment">/// in the toggles bit set.  Both sets must have the</span></span>
<span class="line" id="L946">    <span class="tok-comment">/// same bit_length.</span></span>
<span class="line" id="L947">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">toggleSet</span>(self: *Self, toggles: Self) <span class="tok-type">void</span> {</span>
<span class="line" id="L948">        self.unmanaged.toggleSet(toggles.unmanaged);</span>
<span class="line" id="L949">    }</span>
<span class="line" id="L950"></span>
<span class="line" id="L951">    <span class="tok-comment">/// Flips every bit in the bit set.</span></span>
<span class="line" id="L952">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">toggleAll</span>(self: *Self) <span class="tok-type">void</span> {</span>
<span class="line" id="L953">        self.unmanaged.toggleAll();</span>
<span class="line" id="L954">    }</span>
<span class="line" id="L955"></span>
<span class="line" id="L956">    <span class="tok-comment">/// Performs a union of two bit sets, and stores the</span></span>
<span class="line" id="L957">    <span class="tok-comment">/// result in the first one.  Bits in the result are</span></span>
<span class="line" id="L958">    <span class="tok-comment">/// set if the corresponding bits were set in either input.</span></span>
<span class="line" id="L959">    <span class="tok-comment">/// The two sets must both be the same bit_length.</span></span>
<span class="line" id="L960">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">setUnion</span>(self: *Self, other: Self) <span class="tok-type">void</span> {</span>
<span class="line" id="L961">        self.unmanaged.setUnion(other.unmanaged);</span>
<span class="line" id="L962">    }</span>
<span class="line" id="L963"></span>
<span class="line" id="L964">    <span class="tok-comment">/// Performs an intersection of two bit sets, and stores</span></span>
<span class="line" id="L965">    <span class="tok-comment">/// the result in the first one.  Bits in the result are</span></span>
<span class="line" id="L966">    <span class="tok-comment">/// set if the corresponding bits were set in both inputs.</span></span>
<span class="line" id="L967">    <span class="tok-comment">/// The two sets must both be the same bit_length.</span></span>
<span class="line" id="L968">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">setIntersection</span>(self: *Self, other: Self) <span class="tok-type">void</span> {</span>
<span class="line" id="L969">        self.unmanaged.setIntersection(other.unmanaged);</span>
<span class="line" id="L970">    }</span>
<span class="line" id="L971"></span>
<span class="line" id="L972">    <span class="tok-comment">/// Finds the index of the first set bit.</span></span>
<span class="line" id="L973">    <span class="tok-comment">/// If no bits are set, returns null.</span></span>
<span class="line" id="L974">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">findFirstSet</span>(self: Self) ?<span class="tok-type">usize</span> {</span>
<span class="line" id="L975">        <span class="tok-kw">return</span> self.unmanaged.findFirstSet();</span>
<span class="line" id="L976">    }</span>
<span class="line" id="L977"></span>
<span class="line" id="L978">    <span class="tok-comment">/// Finds the index of the first set bit, and unsets it.</span></span>
<span class="line" id="L979">    <span class="tok-comment">/// If no bits are set, returns null.</span></span>
<span class="line" id="L980">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">toggleFirstSet</span>(self: *Self) ?<span class="tok-type">usize</span> {</span>
<span class="line" id="L981">        <span class="tok-kw">return</span> self.unmanaged.toggleFirstSet();</span>
<span class="line" id="L982">    }</span>
<span class="line" id="L983"></span>
<span class="line" id="L984">    <span class="tok-comment">/// Iterates through the items in the set, according to the options.</span></span>
<span class="line" id="L985">    <span class="tok-comment">/// The default options (.{}) will iterate indices of set bits in</span></span>
<span class="line" id="L986">    <span class="tok-comment">/// ascending order.  Modifications to the underlying bit set may</span></span>
<span class="line" id="L987">    <span class="tok-comment">/// or may not be observed by the iterator.  Resizing the underlying</span></span>
<span class="line" id="L988">    <span class="tok-comment">/// bit set invalidates the iterator.</span></span>
<span class="line" id="L989">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">iterator</span>(self: *<span class="tok-kw">const</span> Self, <span class="tok-kw">comptime</span> options: IteratorOptions) Iterator(options) {</span>
<span class="line" id="L990">        <span class="tok-kw">return</span> self.unmanaged.iterator(options);</span>
<span class="line" id="L991">    }</span>
<span class="line" id="L992"></span>
<span class="line" id="L993">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> Iterator = DynamicBitSetUnmanaged.Iterator;</span>
<span class="line" id="L994">};</span>
<span class="line" id="L995"></span>
<span class="line" id="L996"><span class="tok-comment">/// Options for configuring an iterator over a bit set</span></span>
<span class="line" id="L997"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IteratorOptions = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L998">    <span class="tok-comment">/// determines which bits should be visited</span></span>
<span class="line" id="L999">    kind: Type = .set,</span>
<span class="line" id="L1000">    <span class="tok-comment">/// determines the order in which bit indices should be visited</span></span>
<span class="line" id="L1001">    direction: Direction = .forward,</span>
<span class="line" id="L1002"></span>
<span class="line" id="L1003">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> Type = <span class="tok-kw">enum</span> {</span>
<span class="line" id="L1004">        <span class="tok-comment">/// visit indexes of set bits</span></span>
<span class="line" id="L1005">        set,</span>
<span class="line" id="L1006">        <span class="tok-comment">/// visit indexes of unset bits</span></span>
<span class="line" id="L1007">        unset,</span>
<span class="line" id="L1008">    };</span>
<span class="line" id="L1009"></span>
<span class="line" id="L1010">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> Direction = <span class="tok-kw">enum</span> {</span>
<span class="line" id="L1011">        <span class="tok-comment">/// visit indices in ascending order</span></span>
<span class="line" id="L1012">        forward,</span>
<span class="line" id="L1013">        <span class="tok-comment">/// visit indices in descending order.</span></span>
<span class="line" id="L1014">        <span class="tok-comment">/// Note that this may be slightly more expensive than forward iteration.</span></span>
<span class="line" id="L1015">        reverse,</span>
<span class="line" id="L1016">    };</span>
<span class="line" id="L1017">};</span>
<span class="line" id="L1018"></span>
<span class="line" id="L1019"><span class="tok-comment">// The iterator is reusable between several bit set types</span>
</span>
<span class="line" id="L1020"><span class="tok-kw">fn</span> <span class="tok-fn">BitSetIterator</span>(<span class="tok-kw">comptime</span> MaskInt: <span class="tok-type">type</span>, <span class="tok-kw">comptime</span> options: IteratorOptions) <span class="tok-type">type</span> {</span>
<span class="line" id="L1021">    <span class="tok-kw">const</span> ShiftInt = std.math.Log2Int(MaskInt);</span>
<span class="line" id="L1022">    <span class="tok-kw">const</span> kind = options.kind;</span>
<span class="line" id="L1023">    <span class="tok-kw">const</span> direction = options.direction;</span>
<span class="line" id="L1024">    <span class="tok-kw">return</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L1025">        <span class="tok-kw">const</span> Self = <span class="tok-builtin">@This</span>();</span>
<span class="line" id="L1026"></span>
<span class="line" id="L1027">        <span class="tok-comment">// all bits which have not yet been iterated over</span>
</span>
<span class="line" id="L1028">        bits_remain: MaskInt,</span>
<span class="line" id="L1029">        <span class="tok-comment">// all words which have not yet been iterated over</span>
</span>
<span class="line" id="L1030">        words_remain: []<span class="tok-kw">const</span> MaskInt,</span>
<span class="line" id="L1031">        <span class="tok-comment">// the offset of the current word</span>
</span>
<span class="line" id="L1032">        bit_offset: <span class="tok-type">usize</span>,</span>
<span class="line" id="L1033">        <span class="tok-comment">// the mask of the last word</span>
</span>
<span class="line" id="L1034">        last_word_mask: MaskInt,</span>
<span class="line" id="L1035"></span>
<span class="line" id="L1036">        <span class="tok-kw">fn</span> <span class="tok-fn">init</span>(masks: []<span class="tok-kw">const</span> MaskInt, last_word_mask: MaskInt) Self {</span>
<span class="line" id="L1037">            <span class="tok-kw">if</span> (masks.len == <span class="tok-number">0</span>) {</span>
<span class="line" id="L1038">                <span class="tok-kw">return</span> Self{</span>
<span class="line" id="L1039">                    .bits_remain = <span class="tok-number">0</span>,</span>
<span class="line" id="L1040">                    .words_remain = &amp;[_]MaskInt{},</span>
<span class="line" id="L1041">                    .last_word_mask = last_word_mask,</span>
<span class="line" id="L1042">                    .bit_offset = <span class="tok-number">0</span>,</span>
<span class="line" id="L1043">                };</span>
<span class="line" id="L1044">            } <span class="tok-kw">else</span> {</span>
<span class="line" id="L1045">                <span class="tok-kw">var</span> result = Self{</span>
<span class="line" id="L1046">                    .bits_remain = <span class="tok-number">0</span>,</span>
<span class="line" id="L1047">                    .words_remain = masks,</span>
<span class="line" id="L1048">                    .last_word_mask = last_word_mask,</span>
<span class="line" id="L1049">                    .bit_offset = <span class="tok-kw">if</span> (direction == .forward) <span class="tok-number">0</span> <span class="tok-kw">else</span> (masks.len - <span class="tok-number">1</span>) * <span class="tok-builtin">@bitSizeOf</span>(MaskInt),</span>
<span class="line" id="L1050">                };</span>
<span class="line" id="L1051">                result.nextWord(<span class="tok-null">true</span>);</span>
<span class="line" id="L1052">                <span class="tok-kw">return</span> result;</span>
<span class="line" id="L1053">            }</span>
<span class="line" id="L1054">        }</span>
<span class="line" id="L1055"></span>
<span class="line" id="L1056">        <span class="tok-comment">/// Returns the index of the next unvisited set bit</span></span>
<span class="line" id="L1057">        <span class="tok-comment">/// in the bit set, in ascending order.</span></span>
<span class="line" id="L1058">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">next</span>(self: *Self) ?<span class="tok-type">usize</span> {</span>
<span class="line" id="L1059">            <span class="tok-kw">while</span> (self.bits_remain == <span class="tok-number">0</span>) {</span>
<span class="line" id="L1060">                <span class="tok-kw">if</span> (self.words_remain.len == <span class="tok-number">0</span>) <span class="tok-kw">return</span> <span class="tok-null">null</span>;</span>
<span class="line" id="L1061">                self.nextWord(<span class="tok-null">false</span>);</span>
<span class="line" id="L1062">                <span class="tok-kw">switch</span> (direction) {</span>
<span class="line" id="L1063">                    .forward =&gt; self.bit_offset += <span class="tok-builtin">@bitSizeOf</span>(MaskInt),</span>
<span class="line" id="L1064">                    .reverse =&gt; self.bit_offset -= <span class="tok-builtin">@bitSizeOf</span>(MaskInt),</span>
<span class="line" id="L1065">                }</span>
<span class="line" id="L1066">            }</span>
<span class="line" id="L1067"></span>
<span class="line" id="L1068">            <span class="tok-kw">switch</span> (direction) {</span>
<span class="line" id="L1069">                .forward =&gt; {</span>
<span class="line" id="L1070">                    <span class="tok-kw">const</span> next_index = <span class="tok-builtin">@ctz</span>(MaskInt, self.bits_remain) + self.bit_offset;</span>
<span class="line" id="L1071">                    self.bits_remain &amp;= self.bits_remain - <span class="tok-number">1</span>;</span>
<span class="line" id="L1072">                    <span class="tok-kw">return</span> next_index;</span>
<span class="line" id="L1073">                },</span>
<span class="line" id="L1074">                .reverse =&gt; {</span>
<span class="line" id="L1075">                    <span class="tok-kw">const</span> leading_zeroes = <span class="tok-builtin">@clz</span>(MaskInt, self.bits_remain);</span>
<span class="line" id="L1076">                    <span class="tok-kw">const</span> top_bit = (<span class="tok-builtin">@bitSizeOf</span>(MaskInt) - <span class="tok-number">1</span>) - leading_zeroes;</span>
<span class="line" id="L1077">                    <span class="tok-kw">const</span> no_top_bit_mask = (<span class="tok-builtin">@as</span>(MaskInt, <span class="tok-number">1</span>) &lt;&lt; <span class="tok-builtin">@intCast</span>(ShiftInt, top_bit)) - <span class="tok-number">1</span>;</span>
<span class="line" id="L1078">                    self.bits_remain &amp;= no_top_bit_mask;</span>
<span class="line" id="L1079">                    <span class="tok-kw">return</span> top_bit + self.bit_offset;</span>
<span class="line" id="L1080">                },</span>
<span class="line" id="L1081">            }</span>
<span class="line" id="L1082">        }</span>
<span class="line" id="L1083"></span>
<span class="line" id="L1084">        <span class="tok-comment">// Load the next word.  Don't call this if there</span>
</span>
<span class="line" id="L1085">        <span class="tok-comment">// isn't a next word.  If the next word is the</span>
</span>
<span class="line" id="L1086">        <span class="tok-comment">// last word, mask off the padding bits so we</span>
</span>
<span class="line" id="L1087">        <span class="tok-comment">// don't visit them.</span>
</span>
<span class="line" id="L1088">        <span class="tok-kw">inline</span> <span class="tok-kw">fn</span> <span class="tok-fn">nextWord</span>(self: *Self, <span class="tok-kw">comptime</span> is_first_word: <span class="tok-type">bool</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L1089">            <span class="tok-kw">var</span> word = <span class="tok-kw">switch</span> (direction) {</span>
<span class="line" id="L1090">                .forward =&gt; self.words_remain[<span class="tok-number">0</span>],</span>
<span class="line" id="L1091">                .reverse =&gt; self.words_remain[self.words_remain.len - <span class="tok-number">1</span>],</span>
<span class="line" id="L1092">            };</span>
<span class="line" id="L1093">            <span class="tok-kw">switch</span> (kind) {</span>
<span class="line" id="L1094">                .set =&gt; {},</span>
<span class="line" id="L1095">                .unset =&gt; {</span>
<span class="line" id="L1096">                    word = ~word;</span>
<span class="line" id="L1097">                    <span class="tok-kw">if</span> ((direction == .reverse <span class="tok-kw">and</span> is_first_word) <span class="tok-kw">or</span></span>
<span class="line" id="L1098">                        (direction == .forward <span class="tok-kw">and</span> self.words_remain.len == <span class="tok-number">1</span>))</span>
<span class="line" id="L1099">                    {</span>
<span class="line" id="L1100">                        word &amp;= self.last_word_mask;</span>
<span class="line" id="L1101">                    }</span>
<span class="line" id="L1102">                },</span>
<span class="line" id="L1103">            }</span>
<span class="line" id="L1104">            <span class="tok-kw">switch</span> (direction) {</span>
<span class="line" id="L1105">                .forward =&gt; self.words_remain = self.words_remain[<span class="tok-number">1</span>..],</span>
<span class="line" id="L1106">                .reverse =&gt; self.words_remain.len -= <span class="tok-number">1</span>,</span>
<span class="line" id="L1107">            }</span>
<span class="line" id="L1108">            self.bits_remain = word;</span>
<span class="line" id="L1109">        }</span>
<span class="line" id="L1110">    };</span>
<span class="line" id="L1111">}</span>
<span class="line" id="L1112"></span>
<span class="line" id="L1113"><span class="tok-comment">/// A range of indices within a bitset.</span></span>
<span class="line" id="L1114"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> Range = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L1115">    <span class="tok-comment">/// The index of the first bit of interest.</span></span>
<span class="line" id="L1116">    start: <span class="tok-type">usize</span>,</span>
<span class="line" id="L1117">    <span class="tok-comment">/// The index immediately after the last bit of interest.</span></span>
<span class="line" id="L1118">    end: <span class="tok-type">usize</span>,</span>
<span class="line" id="L1119">};</span>
<span class="line" id="L1120"></span>
<span class="line" id="L1121"><span class="tok-comment">// ---------------- Tests -----------------</span>
</span>
<span class="line" id="L1122"></span>
<span class="line" id="L1123"><span class="tok-kw">const</span> testing = std.testing;</span>
<span class="line" id="L1124"></span>
<span class="line" id="L1125"><span class="tok-kw">fn</span> <span class="tok-fn">testBitSet</span>(a: <span class="tok-kw">anytype</span>, b: <span class="tok-kw">anytype</span>, len: <span class="tok-type">usize</span>) !<span class="tok-type">void</span> {</span>
<span class="line" id="L1126">    <span class="tok-kw">try</span> testing.expectEqual(len, a.capacity());</span>
<span class="line" id="L1127">    <span class="tok-kw">try</span> testing.expectEqual(len, b.capacity());</span>
<span class="line" id="L1128"></span>
<span class="line" id="L1129">    {</span>
<span class="line" id="L1130">        <span class="tok-kw">var</span> i: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L1131">        <span class="tok-kw">while</span> (i &lt; len) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L1132">            a.setValue(i, i &amp; <span class="tok-number">1</span> == <span class="tok-number">0</span>);</span>
<span class="line" id="L1133">            b.setValue(i, i &amp; <span class="tok-number">2</span> == <span class="tok-number">0</span>);</span>
<span class="line" id="L1134">        }</span>
<span class="line" id="L1135">    }</span>
<span class="line" id="L1136"></span>
<span class="line" id="L1137">    <span class="tok-kw">try</span> testing.expectEqual((len + <span class="tok-number">1</span>) / <span class="tok-number">2</span>, a.count());</span>
<span class="line" id="L1138">    <span class="tok-kw">try</span> testing.expectEqual((len + <span class="tok-number">3</span>) / <span class="tok-number">4</span> + (len + <span class="tok-number">2</span>) / <span class="tok-number">4</span>, b.count());</span>
<span class="line" id="L1139"></span>
<span class="line" id="L1140">    {</span>
<span class="line" id="L1141">        <span class="tok-kw">var</span> iter = a.iterator(.{});</span>
<span class="line" id="L1142">        <span class="tok-kw">var</span> i: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L1143">        <span class="tok-kw">while</span> (i &lt; len) : (i += <span class="tok-number">2</span>) {</span>
<span class="line" id="L1144">            <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(?<span class="tok-type">usize</span>, i), iter.next());</span>
<span class="line" id="L1145">        }</span>
<span class="line" id="L1146">        <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(?<span class="tok-type">usize</span>, <span class="tok-null">null</span>), iter.next());</span>
<span class="line" id="L1147">        <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(?<span class="tok-type">usize</span>, <span class="tok-null">null</span>), iter.next());</span>
<span class="line" id="L1148">        <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(?<span class="tok-type">usize</span>, <span class="tok-null">null</span>), iter.next());</span>
<span class="line" id="L1149">    }</span>
<span class="line" id="L1150">    a.toggleAll();</span>
<span class="line" id="L1151">    {</span>
<span class="line" id="L1152">        <span class="tok-kw">var</span> iter = a.iterator(.{});</span>
<span class="line" id="L1153">        <span class="tok-kw">var</span> i: <span class="tok-type">usize</span> = <span class="tok-number">1</span>;</span>
<span class="line" id="L1154">        <span class="tok-kw">while</span> (i &lt; len) : (i += <span class="tok-number">2</span>) {</span>
<span class="line" id="L1155">            <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(?<span class="tok-type">usize</span>, i), iter.next());</span>
<span class="line" id="L1156">        }</span>
<span class="line" id="L1157">        <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(?<span class="tok-type">usize</span>, <span class="tok-null">null</span>), iter.next());</span>
<span class="line" id="L1158">        <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(?<span class="tok-type">usize</span>, <span class="tok-null">null</span>), iter.next());</span>
<span class="line" id="L1159">        <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(?<span class="tok-type">usize</span>, <span class="tok-null">null</span>), iter.next());</span>
<span class="line" id="L1160">    }</span>
<span class="line" id="L1161"></span>
<span class="line" id="L1162">    {</span>
<span class="line" id="L1163">        <span class="tok-kw">var</span> iter = b.iterator(.{ .kind = .unset });</span>
<span class="line" id="L1164">        <span class="tok-kw">var</span> i: <span class="tok-type">usize</span> = <span class="tok-number">2</span>;</span>
<span class="line" id="L1165">        <span class="tok-kw">while</span> (i &lt; len) : (i += <span class="tok-number">4</span>) {</span>
<span class="line" id="L1166">            <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(?<span class="tok-type">usize</span>, i), iter.next());</span>
<span class="line" id="L1167">            <span class="tok-kw">if</span> (i + <span class="tok-number">1</span> &lt; len) {</span>
<span class="line" id="L1168">                <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(?<span class="tok-type">usize</span>, i + <span class="tok-number">1</span>), iter.next());</span>
<span class="line" id="L1169">            }</span>
<span class="line" id="L1170">        }</span>
<span class="line" id="L1171">        <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(?<span class="tok-type">usize</span>, <span class="tok-null">null</span>), iter.next());</span>
<span class="line" id="L1172">        <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(?<span class="tok-type">usize</span>, <span class="tok-null">null</span>), iter.next());</span>
<span class="line" id="L1173">        <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(?<span class="tok-type">usize</span>, <span class="tok-null">null</span>), iter.next());</span>
<span class="line" id="L1174">    }</span>
<span class="line" id="L1175"></span>
<span class="line" id="L1176">    {</span>
<span class="line" id="L1177">        <span class="tok-kw">var</span> i: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L1178">        <span class="tok-kw">while</span> (i &lt; len) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L1179">            <span class="tok-kw">try</span> testing.expectEqual(i &amp; <span class="tok-number">1</span> != <span class="tok-number">0</span>, a.isSet(i));</span>
<span class="line" id="L1180">            <span class="tok-kw">try</span> testing.expectEqual(i &amp; <span class="tok-number">2</span> == <span class="tok-number">0</span>, b.isSet(i));</span>
<span class="line" id="L1181">        }</span>
<span class="line" id="L1182">    }</span>
<span class="line" id="L1183"></span>
<span class="line" id="L1184">    a.setUnion(b.*);</span>
<span class="line" id="L1185">    {</span>
<span class="line" id="L1186">        <span class="tok-kw">var</span> i: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L1187">        <span class="tok-kw">while</span> (i &lt; len) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L1188">            <span class="tok-kw">try</span> testing.expectEqual(i &amp; <span class="tok-number">1</span> != <span class="tok-number">0</span> <span class="tok-kw">or</span> i &amp; <span class="tok-number">2</span> == <span class="tok-number">0</span>, a.isSet(i));</span>
<span class="line" id="L1189">            <span class="tok-kw">try</span> testing.expectEqual(i &amp; <span class="tok-number">2</span> == <span class="tok-number">0</span>, b.isSet(i));</span>
<span class="line" id="L1190">        }</span>
<span class="line" id="L1191"></span>
<span class="line" id="L1192">        i = len;</span>
<span class="line" id="L1193">        <span class="tok-kw">var</span> set = a.iterator(.{ .direction = .reverse });</span>
<span class="line" id="L1194">        <span class="tok-kw">var</span> unset = a.iterator(.{ .kind = .unset, .direction = .reverse });</span>
<span class="line" id="L1195">        <span class="tok-kw">while</span> (i &gt; <span class="tok-number">0</span>) {</span>
<span class="line" id="L1196">            i -= <span class="tok-number">1</span>;</span>
<span class="line" id="L1197">            <span class="tok-kw">if</span> (i &amp; <span class="tok-number">1</span> != <span class="tok-number">0</span> <span class="tok-kw">or</span> i &amp; <span class="tok-number">2</span> == <span class="tok-number">0</span>) {</span>
<span class="line" id="L1198">                <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(?<span class="tok-type">usize</span>, i), set.next());</span>
<span class="line" id="L1199">            } <span class="tok-kw">else</span> {</span>
<span class="line" id="L1200">                <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(?<span class="tok-type">usize</span>, i), unset.next());</span>
<span class="line" id="L1201">            }</span>
<span class="line" id="L1202">        }</span>
<span class="line" id="L1203">        <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(?<span class="tok-type">usize</span>, <span class="tok-null">null</span>), set.next());</span>
<span class="line" id="L1204">        <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(?<span class="tok-type">usize</span>, <span class="tok-null">null</span>), set.next());</span>
<span class="line" id="L1205">        <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(?<span class="tok-type">usize</span>, <span class="tok-null">null</span>), set.next());</span>
<span class="line" id="L1206">        <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(?<span class="tok-type">usize</span>, <span class="tok-null">null</span>), unset.next());</span>
<span class="line" id="L1207">        <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(?<span class="tok-type">usize</span>, <span class="tok-null">null</span>), unset.next());</span>
<span class="line" id="L1208">        <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(?<span class="tok-type">usize</span>, <span class="tok-null">null</span>), unset.next());</span>
<span class="line" id="L1209">    }</span>
<span class="line" id="L1210"></span>
<span class="line" id="L1211">    a.toggleSet(b.*);</span>
<span class="line" id="L1212">    {</span>
<span class="line" id="L1213">        <span class="tok-kw">try</span> testing.expectEqual(len / <span class="tok-number">4</span>, a.count());</span>
<span class="line" id="L1214"></span>
<span class="line" id="L1215">        <span class="tok-kw">var</span> i: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L1216">        <span class="tok-kw">while</span> (i &lt; len) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L1217">            <span class="tok-kw">try</span> testing.expectEqual(i &amp; <span class="tok-number">1</span> != <span class="tok-number">0</span> <span class="tok-kw">and</span> i &amp; <span class="tok-number">2</span> != <span class="tok-number">0</span>, a.isSet(i));</span>
<span class="line" id="L1218">            <span class="tok-kw">try</span> testing.expectEqual(i &amp; <span class="tok-number">2</span> == <span class="tok-number">0</span>, b.isSet(i));</span>
<span class="line" id="L1219">            <span class="tok-kw">if</span> (i &amp; <span class="tok-number">1</span> == <span class="tok-number">0</span>) {</span>
<span class="line" id="L1220">                a.set(i);</span>
<span class="line" id="L1221">            } <span class="tok-kw">else</span> {</span>
<span class="line" id="L1222">                a.unset(i);</span>
<span class="line" id="L1223">            }</span>
<span class="line" id="L1224">        }</span>
<span class="line" id="L1225">    }</span>
<span class="line" id="L1226"></span>
<span class="line" id="L1227">    a.setIntersection(b.*);</span>
<span class="line" id="L1228">    {</span>
<span class="line" id="L1229">        <span class="tok-kw">try</span> testing.expectEqual((len + <span class="tok-number">3</span>) / <span class="tok-number">4</span>, a.count());</span>
<span class="line" id="L1230"></span>
<span class="line" id="L1231">        <span class="tok-kw">var</span> i: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L1232">        <span class="tok-kw">while</span> (i &lt; len) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L1233">            <span class="tok-kw">try</span> testing.expectEqual(i &amp; <span class="tok-number">1</span> == <span class="tok-number">0</span> <span class="tok-kw">and</span> i &amp; <span class="tok-number">2</span> == <span class="tok-number">0</span>, a.isSet(i));</span>
<span class="line" id="L1234">            <span class="tok-kw">try</span> testing.expectEqual(i &amp; <span class="tok-number">2</span> == <span class="tok-number">0</span>, b.isSet(i));</span>
<span class="line" id="L1235">        }</span>
<span class="line" id="L1236">    }</span>
<span class="line" id="L1237"></span>
<span class="line" id="L1238">    a.toggleSet(a.*);</span>
<span class="line" id="L1239">    {</span>
<span class="line" id="L1240">        <span class="tok-kw">var</span> iter = a.iterator(.{});</span>
<span class="line" id="L1241">        <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(?<span class="tok-type">usize</span>, <span class="tok-null">null</span>), iter.next());</span>
<span class="line" id="L1242">        <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(?<span class="tok-type">usize</span>, <span class="tok-null">null</span>), iter.next());</span>
<span class="line" id="L1243">        <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(?<span class="tok-type">usize</span>, <span class="tok-null">null</span>), iter.next());</span>
<span class="line" id="L1244">        <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">usize</span>, <span class="tok-number">0</span>), a.count());</span>
<span class="line" id="L1245">    }</span>
<span class="line" id="L1246">    {</span>
<span class="line" id="L1247">        <span class="tok-kw">var</span> iter = a.iterator(.{ .direction = .reverse });</span>
<span class="line" id="L1248">        <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(?<span class="tok-type">usize</span>, <span class="tok-null">null</span>), iter.next());</span>
<span class="line" id="L1249">        <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(?<span class="tok-type">usize</span>, <span class="tok-null">null</span>), iter.next());</span>
<span class="line" id="L1250">        <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(?<span class="tok-type">usize</span>, <span class="tok-null">null</span>), iter.next());</span>
<span class="line" id="L1251">        <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">usize</span>, <span class="tok-number">0</span>), a.count());</span>
<span class="line" id="L1252">    }</span>
<span class="line" id="L1253"></span>
<span class="line" id="L1254">    <span class="tok-kw">const</span> test_bits = [_]<span class="tok-type">usize</span>{</span>
<span class="line" id="L1255">        <span class="tok-number">0</span>,  <span class="tok-number">1</span>,  <span class="tok-number">2</span>,   <span class="tok-number">3</span>,   <span class="tok-number">4</span>,   <span class="tok-number">5</span>,    <span class="tok-number">6</span>, <span class="tok-number">7</span>, <span class="tok-number">9</span>, <span class="tok-number">10</span>, <span class="tok-number">11</span>, <span class="tok-number">22</span>, <span class="tok-number">31</span>, <span class="tok-number">32</span>, <span class="tok-number">63</span>, <span class="tok-number">64</span>,</span>
<span class="line" id="L1256">        <span class="tok-number">66</span>, <span class="tok-number">95</span>, <span class="tok-number">127</span>, <span class="tok-number">160</span>, <span class="tok-number">192</span>, <span class="tok-number">1000</span>,</span>
<span class="line" id="L1257">    };</span>
<span class="line" id="L1258">    <span class="tok-kw">for</span> (test_bits) |i| {</span>
<span class="line" id="L1259">        <span class="tok-kw">if</span> (i &lt; a.capacity()) {</span>
<span class="line" id="L1260">            a.set(i);</span>
<span class="line" id="L1261">        }</span>
<span class="line" id="L1262">    }</span>
<span class="line" id="L1263"></span>
<span class="line" id="L1264">    <span class="tok-kw">for</span> (test_bits) |i| {</span>
<span class="line" id="L1265">        <span class="tok-kw">if</span> (i &lt; a.capacity()) {</span>
<span class="line" id="L1266">            <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(?<span class="tok-type">usize</span>, i), a.findFirstSet());</span>
<span class="line" id="L1267">            <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(?<span class="tok-type">usize</span>, i), a.toggleFirstSet());</span>
<span class="line" id="L1268">        }</span>
<span class="line" id="L1269">    }</span>
<span class="line" id="L1270">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(?<span class="tok-type">usize</span>, <span class="tok-null">null</span>), a.findFirstSet());</span>
<span class="line" id="L1271">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(?<span class="tok-type">usize</span>, <span class="tok-null">null</span>), a.toggleFirstSet());</span>
<span class="line" id="L1272">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(?<span class="tok-type">usize</span>, <span class="tok-null">null</span>), a.findFirstSet());</span>
<span class="line" id="L1273">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(?<span class="tok-type">usize</span>, <span class="tok-null">null</span>), a.toggleFirstSet());</span>
<span class="line" id="L1274">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">usize</span>, <span class="tok-number">0</span>), a.count());</span>
<span class="line" id="L1275"></span>
<span class="line" id="L1276">    a.setRangeValue(.{ .start = <span class="tok-number">0</span>, .end = len }, <span class="tok-null">false</span>);</span>
<span class="line" id="L1277">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">usize</span>, <span class="tok-number">0</span>), a.count());</span>
<span class="line" id="L1278"></span>
<span class="line" id="L1279">    a.setRangeValue(.{ .start = <span class="tok-number">0</span>, .end = len }, <span class="tok-null">true</span>);</span>
<span class="line" id="L1280">    <span class="tok-kw">try</span> testing.expectEqual(len, a.count());</span>
<span class="line" id="L1281"></span>
<span class="line" id="L1282">    a.setRangeValue(.{ .start = <span class="tok-number">0</span>, .end = len }, <span class="tok-null">false</span>);</span>
<span class="line" id="L1283">    a.setRangeValue(.{ .start = <span class="tok-number">0</span>, .end = <span class="tok-number">0</span> }, <span class="tok-null">true</span>);</span>
<span class="line" id="L1284">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">usize</span>, <span class="tok-number">0</span>), a.count());</span>
<span class="line" id="L1285"></span>
<span class="line" id="L1286">    a.setRangeValue(.{ .start = len, .end = len }, <span class="tok-null">true</span>);</span>
<span class="line" id="L1287">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">usize</span>, <span class="tok-number">0</span>), a.count());</span>
<span class="line" id="L1288"></span>
<span class="line" id="L1289">    <span class="tok-kw">if</span> (len &gt;= <span class="tok-number">1</span>) {</span>
<span class="line" id="L1290">        a.setRangeValue(.{ .start = <span class="tok-number">0</span>, .end = len }, <span class="tok-null">false</span>);</span>
<span class="line" id="L1291">        a.setRangeValue(.{ .start = <span class="tok-number">0</span>, .end = <span class="tok-number">1</span> }, <span class="tok-null">true</span>);</span>
<span class="line" id="L1292">        <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">usize</span>, <span class="tok-number">1</span>), a.count());</span>
<span class="line" id="L1293">        <span class="tok-kw">try</span> testing.expect(a.isSet(<span class="tok-number">0</span>));</span>
<span class="line" id="L1294"></span>
<span class="line" id="L1295">        a.setRangeValue(.{ .start = <span class="tok-number">0</span>, .end = len }, <span class="tok-null">false</span>);</span>
<span class="line" id="L1296">        a.setRangeValue(.{ .start = <span class="tok-number">0</span>, .end = len - <span class="tok-number">1</span> }, <span class="tok-null">true</span>);</span>
<span class="line" id="L1297">        <span class="tok-kw">try</span> testing.expectEqual(len - <span class="tok-number">1</span>, a.count());</span>
<span class="line" id="L1298">        <span class="tok-kw">try</span> testing.expect(!a.isSet(len - <span class="tok-number">1</span>));</span>
<span class="line" id="L1299"></span>
<span class="line" id="L1300">        a.setRangeValue(.{ .start = <span class="tok-number">0</span>, .end = len }, <span class="tok-null">false</span>);</span>
<span class="line" id="L1301">        a.setRangeValue(.{ .start = <span class="tok-number">1</span>, .end = len }, <span class="tok-null">true</span>);</span>
<span class="line" id="L1302">        <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">usize</span>, len - <span class="tok-number">1</span>), a.count());</span>
<span class="line" id="L1303">        <span class="tok-kw">try</span> testing.expect(!a.isSet(<span class="tok-number">0</span>));</span>
<span class="line" id="L1304"></span>
<span class="line" id="L1305">        a.setRangeValue(.{ .start = <span class="tok-number">0</span>, .end = len }, <span class="tok-null">false</span>);</span>
<span class="line" id="L1306">        a.setRangeValue(.{ .start = len - <span class="tok-number">1</span>, .end = len }, <span class="tok-null">true</span>);</span>
<span class="line" id="L1307">        <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">usize</span>, <span class="tok-number">1</span>), a.count());</span>
<span class="line" id="L1308">        <span class="tok-kw">try</span> testing.expect(a.isSet(len - <span class="tok-number">1</span>));</span>
<span class="line" id="L1309"></span>
<span class="line" id="L1310">        <span class="tok-kw">if</span> (len &gt;= <span class="tok-number">4</span>) {</span>
<span class="line" id="L1311">            a.setRangeValue(.{ .start = <span class="tok-number">0</span>, .end = len }, <span class="tok-null">false</span>);</span>
<span class="line" id="L1312">            a.setRangeValue(.{ .start = <span class="tok-number">1</span>, .end = len - <span class="tok-number">2</span> }, <span class="tok-null">true</span>);</span>
<span class="line" id="L1313">            <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">usize</span>, len - <span class="tok-number">3</span>), a.count());</span>
<span class="line" id="L1314">            <span class="tok-kw">try</span> testing.expect(!a.isSet(<span class="tok-number">0</span>));</span>
<span class="line" id="L1315">            <span class="tok-kw">try</span> testing.expect(a.isSet(<span class="tok-number">1</span>));</span>
<span class="line" id="L1316">            <span class="tok-kw">try</span> testing.expect(a.isSet(len - <span class="tok-number">3</span>));</span>
<span class="line" id="L1317">            <span class="tok-kw">try</span> testing.expect(!a.isSet(len - <span class="tok-number">2</span>));</span>
<span class="line" id="L1318">            <span class="tok-kw">try</span> testing.expect(!a.isSet(len - <span class="tok-number">1</span>));</span>
<span class="line" id="L1319">        }</span>
<span class="line" id="L1320">    }</span>
<span class="line" id="L1321">}</span>
<span class="line" id="L1322"></span>
<span class="line" id="L1323"><span class="tok-kw">fn</span> <span class="tok-fn">testStaticBitSet</span>(<span class="tok-kw">comptime</span> Set: <span class="tok-type">type</span>) !<span class="tok-type">void</span> {</span>
<span class="line" id="L1324">    <span class="tok-kw">var</span> a = Set.initEmpty();</span>
<span class="line" id="L1325">    <span class="tok-kw">var</span> b = Set.initFull();</span>
<span class="line" id="L1326">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">usize</span>, <span class="tok-number">0</span>), a.count());</span>
<span class="line" id="L1327">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">usize</span>, Set.bit_length), b.count());</span>
<span class="line" id="L1328"></span>
<span class="line" id="L1329">    <span class="tok-kw">try</span> testBitSet(&amp;a, &amp;b, Set.bit_length);</span>
<span class="line" id="L1330">}</span>
<span class="line" id="L1331"></span>
<span class="line" id="L1332"><span class="tok-kw">test</span> <span class="tok-str">&quot;IntegerBitSet&quot;</span> {</span>
<span class="line" id="L1333">    <span class="tok-kw">try</span> testStaticBitSet(IntegerBitSet(<span class="tok-number">0</span>));</span>
<span class="line" id="L1334">    <span class="tok-kw">try</span> testStaticBitSet(IntegerBitSet(<span class="tok-number">1</span>));</span>
<span class="line" id="L1335">    <span class="tok-kw">try</span> testStaticBitSet(IntegerBitSet(<span class="tok-number">2</span>));</span>
<span class="line" id="L1336">    <span class="tok-kw">try</span> testStaticBitSet(IntegerBitSet(<span class="tok-number">5</span>));</span>
<span class="line" id="L1337">    <span class="tok-kw">try</span> testStaticBitSet(IntegerBitSet(<span class="tok-number">8</span>));</span>
<span class="line" id="L1338">    <span class="tok-kw">try</span> testStaticBitSet(IntegerBitSet(<span class="tok-number">32</span>));</span>
<span class="line" id="L1339">    <span class="tok-kw">try</span> testStaticBitSet(IntegerBitSet(<span class="tok-number">64</span>));</span>
<span class="line" id="L1340">    <span class="tok-kw">try</span> testStaticBitSet(IntegerBitSet(<span class="tok-number">127</span>));</span>
<span class="line" id="L1341">}</span>
<span class="line" id="L1342"></span>
<span class="line" id="L1343"><span class="tok-kw">test</span> <span class="tok-str">&quot;ArrayBitSet&quot;</span> {</span>
<span class="line" id="L1344">    <span class="tok-kw">if</span> (<span class="tok-builtin">@import</span>(<span class="tok-str">&quot;builtin&quot;</span>).cpu.arch == .aarch64) {</span>
<span class="line" id="L1345">        <span class="tok-comment">// https://github.com/ziglang/zig/issues/9879</span>
</span>
<span class="line" id="L1346">        <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SkipZigTest;</span>
<span class="line" id="L1347">    }</span>
<span class="line" id="L1348">    <span class="tok-kw">inline</span> <span class="tok-kw">for</span> (.{ <span class="tok-number">0</span>, <span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">31</span>, <span class="tok-number">32</span>, <span class="tok-number">33</span>, <span class="tok-number">63</span>, <span class="tok-number">64</span>, <span class="tok-number">65</span>, <span class="tok-number">254</span>, <span class="tok-number">500</span>, <span class="tok-number">3000</span> }) |size| {</span>
<span class="line" id="L1349">        <span class="tok-kw">try</span> testStaticBitSet(ArrayBitSet(<span class="tok-type">u8</span>, size));</span>
<span class="line" id="L1350">        <span class="tok-kw">try</span> testStaticBitSet(ArrayBitSet(<span class="tok-type">u16</span>, size));</span>
<span class="line" id="L1351">        <span class="tok-kw">try</span> testStaticBitSet(ArrayBitSet(<span class="tok-type">u32</span>, size));</span>
<span class="line" id="L1352">        <span class="tok-kw">try</span> testStaticBitSet(ArrayBitSet(<span class="tok-type">u64</span>, size));</span>
<span class="line" id="L1353">        <span class="tok-kw">try</span> testStaticBitSet(ArrayBitSet(<span class="tok-type">u128</span>, size));</span>
<span class="line" id="L1354">    }</span>
<span class="line" id="L1355">}</span>
<span class="line" id="L1356"></span>
<span class="line" id="L1357"><span class="tok-kw">test</span> <span class="tok-str">&quot;DynamicBitSetUnmanaged&quot;</span> {</span>
<span class="line" id="L1358">    <span class="tok-kw">const</span> allocator = std.testing.allocator;</span>
<span class="line" id="L1359">    <span class="tok-kw">var</span> a = <span class="tok-kw">try</span> DynamicBitSetUnmanaged.initEmpty(allocator, <span class="tok-number">300</span>);</span>
<span class="line" id="L1360">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">usize</span>, <span class="tok-number">0</span>), a.count());</span>
<span class="line" id="L1361">    a.deinit(allocator);</span>
<span class="line" id="L1362"></span>
<span class="line" id="L1363">    a = <span class="tok-kw">try</span> DynamicBitSetUnmanaged.initEmpty(allocator, <span class="tok-number">0</span>);</span>
<span class="line" id="L1364">    <span class="tok-kw">defer</span> a.deinit(allocator);</span>
<span class="line" id="L1365">    <span class="tok-kw">for</span> ([_]<span class="tok-type">usize</span>{ <span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">31</span>, <span class="tok-number">32</span>, <span class="tok-number">33</span>, <span class="tok-number">0</span>, <span class="tok-number">65</span>, <span class="tok-number">64</span>, <span class="tok-number">63</span>, <span class="tok-number">500</span>, <span class="tok-number">254</span>, <span class="tok-number">3000</span> }) |size| {</span>
<span class="line" id="L1366">        <span class="tok-kw">const</span> old_len = a.capacity();</span>
<span class="line" id="L1367"></span>
<span class="line" id="L1368">        <span class="tok-kw">var</span> tmp = <span class="tok-kw">try</span> a.clone(allocator);</span>
<span class="line" id="L1369">        <span class="tok-kw">defer</span> tmp.deinit(allocator);</span>
<span class="line" id="L1370">        <span class="tok-kw">try</span> testing.expectEqual(old_len, tmp.capacity());</span>
<span class="line" id="L1371">        <span class="tok-kw">var</span> i: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L1372">        <span class="tok-kw">while</span> (i &lt; old_len) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L1373">            <span class="tok-kw">try</span> testing.expectEqual(a.isSet(i), tmp.isSet(i));</span>
<span class="line" id="L1374">        }</span>
<span class="line" id="L1375"></span>
<span class="line" id="L1376">        a.toggleSet(a); <span class="tok-comment">// zero a</span>
</span>
<span class="line" id="L1377">        tmp.toggleSet(tmp);</span>
<span class="line" id="L1378"></span>
<span class="line" id="L1379">        <span class="tok-kw">try</span> a.resize(allocator, size, <span class="tok-null">true</span>);</span>
<span class="line" id="L1380">        <span class="tok-kw">try</span> tmp.resize(allocator, size, <span class="tok-null">false</span>);</span>
<span class="line" id="L1381"></span>
<span class="line" id="L1382">        <span class="tok-kw">if</span> (size &gt; old_len) {</span>
<span class="line" id="L1383">            <span class="tok-kw">try</span> testing.expectEqual(size - old_len, a.count());</span>
<span class="line" id="L1384">        } <span class="tok-kw">else</span> {</span>
<span class="line" id="L1385">            <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">usize</span>, <span class="tok-number">0</span>), a.count());</span>
<span class="line" id="L1386">        }</span>
<span class="line" id="L1387">        <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">usize</span>, <span class="tok-number">0</span>), tmp.count());</span>
<span class="line" id="L1388"></span>
<span class="line" id="L1389">        <span class="tok-kw">var</span> b = <span class="tok-kw">try</span> DynamicBitSetUnmanaged.initFull(allocator, size);</span>
<span class="line" id="L1390">        <span class="tok-kw">defer</span> b.deinit(allocator);</span>
<span class="line" id="L1391">        <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">usize</span>, size), b.count());</span>
<span class="line" id="L1392"></span>
<span class="line" id="L1393">        <span class="tok-kw">try</span> testBitSet(&amp;a, &amp;b, size);</span>
<span class="line" id="L1394">    }</span>
<span class="line" id="L1395">}</span>
<span class="line" id="L1396"></span>
<span class="line" id="L1397"><span class="tok-kw">test</span> <span class="tok-str">&quot;DynamicBitSet&quot;</span> {</span>
<span class="line" id="L1398">    <span class="tok-kw">const</span> allocator = std.testing.allocator;</span>
<span class="line" id="L1399">    <span class="tok-kw">var</span> a = <span class="tok-kw">try</span> DynamicBitSet.initEmpty(allocator, <span class="tok-number">300</span>);</span>
<span class="line" id="L1400">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">usize</span>, <span class="tok-number">0</span>), a.count());</span>
<span class="line" id="L1401">    a.deinit();</span>
<span class="line" id="L1402"></span>
<span class="line" id="L1403">    a = <span class="tok-kw">try</span> DynamicBitSet.initEmpty(allocator, <span class="tok-number">0</span>);</span>
<span class="line" id="L1404">    <span class="tok-kw">defer</span> a.deinit();</span>
<span class="line" id="L1405">    <span class="tok-kw">for</span> ([_]<span class="tok-type">usize</span>{ <span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">31</span>, <span class="tok-number">32</span>, <span class="tok-number">33</span>, <span class="tok-number">0</span>, <span class="tok-number">65</span>, <span class="tok-number">64</span>, <span class="tok-number">63</span>, <span class="tok-number">500</span>, <span class="tok-number">254</span>, <span class="tok-number">3000</span> }) |size| {</span>
<span class="line" id="L1406">        <span class="tok-kw">const</span> old_len = a.capacity();</span>
<span class="line" id="L1407"></span>
<span class="line" id="L1408">        <span class="tok-kw">var</span> tmp = <span class="tok-kw">try</span> a.clone(allocator);</span>
<span class="line" id="L1409">        <span class="tok-kw">defer</span> tmp.deinit();</span>
<span class="line" id="L1410">        <span class="tok-kw">try</span> testing.expectEqual(old_len, tmp.capacity());</span>
<span class="line" id="L1411">        <span class="tok-kw">var</span> i: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L1412">        <span class="tok-kw">while</span> (i &lt; old_len) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L1413">            <span class="tok-kw">try</span> testing.expectEqual(a.isSet(i), tmp.isSet(i));</span>
<span class="line" id="L1414">        }</span>
<span class="line" id="L1415"></span>
<span class="line" id="L1416">        a.toggleSet(a); <span class="tok-comment">// zero a</span>
</span>
<span class="line" id="L1417">        tmp.toggleSet(tmp); <span class="tok-comment">// zero tmp</span>
</span>
<span class="line" id="L1418"></span>
<span class="line" id="L1419">        <span class="tok-kw">try</span> a.resize(size, <span class="tok-null">true</span>);</span>
<span class="line" id="L1420">        <span class="tok-kw">try</span> tmp.resize(size, <span class="tok-null">false</span>);</span>
<span class="line" id="L1421"></span>
<span class="line" id="L1422">        <span class="tok-kw">if</span> (size &gt; old_len) {</span>
<span class="line" id="L1423">            <span class="tok-kw">try</span> testing.expectEqual(size - old_len, a.count());</span>
<span class="line" id="L1424">        } <span class="tok-kw">else</span> {</span>
<span class="line" id="L1425">            <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">usize</span>, <span class="tok-number">0</span>), a.count());</span>
<span class="line" id="L1426">        }</span>
<span class="line" id="L1427">        <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">usize</span>, <span class="tok-number">0</span>), tmp.count());</span>
<span class="line" id="L1428"></span>
<span class="line" id="L1429">        <span class="tok-kw">var</span> b = <span class="tok-kw">try</span> DynamicBitSet.initFull(allocator, size);</span>
<span class="line" id="L1430">        <span class="tok-kw">defer</span> b.deinit();</span>
<span class="line" id="L1431">        <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">usize</span>, size), b.count());</span>
<span class="line" id="L1432"></span>
<span class="line" id="L1433">        <span class="tok-kw">try</span> testBitSet(&amp;a, &amp;b, size);</span>
<span class="line" id="L1434">    }</span>
<span class="line" id="L1435">}</span>
<span class="line" id="L1436"></span>
<span class="line" id="L1437"><span class="tok-kw">test</span> <span class="tok-str">&quot;StaticBitSet&quot;</span> {</span>
<span class="line" id="L1438">    <span class="tok-kw">try</span> testing.expectEqual(IntegerBitSet(<span class="tok-number">0</span>), StaticBitSet(<span class="tok-number">0</span>));</span>
<span class="line" id="L1439">    <span class="tok-kw">try</span> testing.expectEqual(IntegerBitSet(<span class="tok-number">5</span>), StaticBitSet(<span class="tok-number">5</span>));</span>
<span class="line" id="L1440">    <span class="tok-kw">try</span> testing.expectEqual(IntegerBitSet(<span class="tok-builtin">@bitSizeOf</span>(<span class="tok-type">usize</span>)), StaticBitSet(<span class="tok-builtin">@bitSizeOf</span>(<span class="tok-type">usize</span>)));</span>
<span class="line" id="L1441">    <span class="tok-kw">try</span> testing.expectEqual(ArrayBitSet(<span class="tok-type">usize</span>, <span class="tok-builtin">@bitSizeOf</span>(<span class="tok-type">usize</span>) + <span class="tok-number">1</span>), StaticBitSet(<span class="tok-builtin">@bitSizeOf</span>(<span class="tok-type">usize</span>) + <span class="tok-number">1</span>));</span>
<span class="line" id="L1442">    <span class="tok-kw">try</span> testing.expectEqual(ArrayBitSet(<span class="tok-type">usize</span>, <span class="tok-number">500</span>), StaticBitSet(<span class="tok-number">500</span>));</span>
<span class="line" id="L1443">}</span>
<span class="line" id="L1444"></span>
</code></pre></body>
</html>