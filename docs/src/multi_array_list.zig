<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">    <title>multi_array_list.zig - source view</title>
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
<span class="line" id="L2"><span class="tok-kw">const</span> builtin = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;builtin&quot;</span>);</span>
<span class="line" id="L3"><span class="tok-kw">const</span> assert = std.debug.assert;</span>
<span class="line" id="L4"><span class="tok-kw">const</span> meta = std.meta;</span>
<span class="line" id="L5"><span class="tok-kw">const</span> mem = std.mem;</span>
<span class="line" id="L6"><span class="tok-kw">const</span> Allocator = mem.Allocator;</span>
<span class="line" id="L7"><span class="tok-kw">const</span> testing = std.testing;</span>
<span class="line" id="L8"></span>
<span class="line" id="L9"><span class="tok-comment">/// A MultiArrayList stores a list of a struct type.</span></span>
<span class="line" id="L10"><span class="tok-comment">/// Instead of storing a single list of items, MultiArrayList</span></span>
<span class="line" id="L11"><span class="tok-comment">/// stores separate lists for each field of the struct.</span></span>
<span class="line" id="L12"><span class="tok-comment">/// This allows for memory savings if the struct has padding,</span></span>
<span class="line" id="L13"><span class="tok-comment">/// and also improves cache usage if only some fields are needed</span></span>
<span class="line" id="L14"><span class="tok-comment">/// for a computation.  The primary API for accessing fields is</span></span>
<span class="line" id="L15"><span class="tok-comment">/// the `slice()` function, which computes the start pointers</span></span>
<span class="line" id="L16"><span class="tok-comment">/// for the array of each field.  From the slice you can call</span></span>
<span class="line" id="L17"><span class="tok-comment">/// `.items(.&lt;field_name&gt;)` to obtain a slice of field values.</span></span>
<span class="line" id="L18"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">MultiArrayList</span>(<span class="tok-kw">comptime</span> S: <span class="tok-type">type</span>) <span class="tok-type">type</span> {</span>
<span class="line" id="L19">    <span class="tok-kw">return</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L20">        bytes: [*]<span class="tok-kw">align</span>(<span class="tok-builtin">@alignOf</span>(S)) <span class="tok-type">u8</span> = <span class="tok-null">undefined</span>,</span>
<span class="line" id="L21">        len: <span class="tok-type">usize</span> = <span class="tok-number">0</span>,</span>
<span class="line" id="L22">        capacity: <span class="tok-type">usize</span> = <span class="tok-number">0</span>,</span>
<span class="line" id="L23"></span>
<span class="line" id="L24">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> Elem = S;</span>
<span class="line" id="L25"></span>
<span class="line" id="L26">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> Field = meta.FieldEnum(S);</span>
<span class="line" id="L27"></span>
<span class="line" id="L28">        <span class="tok-comment">/// A MultiArrayList.Slice contains cached start pointers for each field in the list.</span></span>
<span class="line" id="L29">        <span class="tok-comment">/// These pointers are not normally stored to reduce the size of the list in memory.</span></span>
<span class="line" id="L30">        <span class="tok-comment">/// If you are accessing multiple fields, call slice() first to compute the pointers,</span></span>
<span class="line" id="L31">        <span class="tok-comment">/// and then get the field arrays from the slice.</span></span>
<span class="line" id="L32">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> Slice = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L33">            <span class="tok-comment">/// This array is indexed by the field index which can be obtained</span></span>
<span class="line" id="L34">            <span class="tok-comment">/// by using @enumToInt() on the Field enum</span></span>
<span class="line" id="L35">            ptrs: [fields.len][*]<span class="tok-type">u8</span>,</span>
<span class="line" id="L36">            len: <span class="tok-type">usize</span>,</span>
<span class="line" id="L37">            capacity: <span class="tok-type">usize</span>,</span>
<span class="line" id="L38"></span>
<span class="line" id="L39">            <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">items</span>(self: Slice, <span class="tok-kw">comptime</span> field: Field) []FieldType(field) {</span>
<span class="line" id="L40">                <span class="tok-kw">const</span> F = FieldType(field);</span>
<span class="line" id="L41">                <span class="tok-kw">if</span> (self.capacity == <span class="tok-number">0</span>) {</span>
<span class="line" id="L42">                    <span class="tok-kw">return</span> &amp;[_]F{};</span>
<span class="line" id="L43">                }</span>
<span class="line" id="L44">                <span class="tok-kw">const</span> byte_ptr = self.ptrs[<span class="tok-builtin">@enumToInt</span>(field)];</span>
<span class="line" id="L45">                <span class="tok-kw">const</span> casted_ptr: [*]F = <span class="tok-kw">if</span> (<span class="tok-builtin">@sizeOf</span>(F) == <span class="tok-number">0</span>)</span>
<span class="line" id="L46">                    <span class="tok-null">undefined</span></span>
<span class="line" id="L47">                <span class="tok-kw">else</span></span>
<span class="line" id="L48">                    <span class="tok-builtin">@ptrCast</span>([*]F, <span class="tok-builtin">@alignCast</span>(<span class="tok-builtin">@alignOf</span>(F), byte_ptr));</span>
<span class="line" id="L49">                <span class="tok-kw">return</span> casted_ptr[<span class="tok-number">0</span>..self.len];</span>
<span class="line" id="L50">            }</span>
<span class="line" id="L51"></span>
<span class="line" id="L52">            <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">toMultiArrayList</span>(self: Slice) Self {</span>
<span class="line" id="L53">                <span class="tok-kw">if</span> (self.ptrs.len == <span class="tok-number">0</span>) {</span>
<span class="line" id="L54">                    <span class="tok-kw">return</span> .{};</span>
<span class="line" id="L55">                }</span>
<span class="line" id="L56">                <span class="tok-kw">const</span> unaligned_ptr = self.ptrs[sizes.fields[<span class="tok-number">0</span>]];</span>
<span class="line" id="L57">                <span class="tok-kw">const</span> aligned_ptr = <span class="tok-builtin">@alignCast</span>(<span class="tok-builtin">@alignOf</span>(S), unaligned_ptr);</span>
<span class="line" id="L58">                <span class="tok-kw">const</span> casted_ptr = <span class="tok-builtin">@ptrCast</span>([*]<span class="tok-kw">align</span>(<span class="tok-builtin">@alignOf</span>(S)) <span class="tok-type">u8</span>, aligned_ptr);</span>
<span class="line" id="L59">                <span class="tok-kw">return</span> .{</span>
<span class="line" id="L60">                    .bytes = casted_ptr,</span>
<span class="line" id="L61">                    .len = self.len,</span>
<span class="line" id="L62">                    .capacity = self.capacity,</span>
<span class="line" id="L63">                };</span>
<span class="line" id="L64">            }</span>
<span class="line" id="L65"></span>
<span class="line" id="L66">            <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">deinit</span>(self: *Slice, gpa: Allocator) <span class="tok-type">void</span> {</span>
<span class="line" id="L67">                <span class="tok-kw">var</span> other = self.toMultiArrayList();</span>
<span class="line" id="L68">                other.deinit(gpa);</span>
<span class="line" id="L69">                self.* = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L70">            }</span>
<span class="line" id="L71">        };</span>
<span class="line" id="L72"></span>
<span class="line" id="L73">        <span class="tok-kw">const</span> Self = <span class="tok-builtin">@This</span>();</span>
<span class="line" id="L74"></span>
<span class="line" id="L75">        <span class="tok-kw">const</span> fields = meta.fields(S);</span>
<span class="line" id="L76">        <span class="tok-comment">/// `sizes.bytes` is an array of @sizeOf each S field. Sorted by alignment, descending.</span></span>
<span class="line" id="L77">        <span class="tok-comment">/// `sizes.fields` is an array mapping from `sizes.bytes` array index to field index.</span></span>
<span class="line" id="L78">        <span class="tok-kw">const</span> sizes = blk: {</span>
<span class="line" id="L79">            <span class="tok-kw">const</span> Data = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L80">                size: <span class="tok-type">usize</span>,</span>
<span class="line" id="L81">                size_index: <span class="tok-type">usize</span>,</span>
<span class="line" id="L82">                alignment: <span class="tok-type">usize</span>,</span>
<span class="line" id="L83">            };</span>
<span class="line" id="L84">            <span class="tok-kw">var</span> data: [fields.len]Data = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L85">            <span class="tok-kw">for</span> (fields) |field_info, i| {</span>
<span class="line" id="L86">                data[i] = .{</span>
<span class="line" id="L87">                    .size = <span class="tok-builtin">@sizeOf</span>(field_info.field_type),</span>
<span class="line" id="L88">                    .size_index = i,</span>
<span class="line" id="L89">                    .alignment = <span class="tok-kw">if</span> (<span class="tok-builtin">@sizeOf</span>(field_info.field_type) == <span class="tok-number">0</span>) <span class="tok-number">1</span> <span class="tok-kw">else</span> field_info.alignment,</span>
<span class="line" id="L90">                };</span>
<span class="line" id="L91">            }</span>
<span class="line" id="L92">            <span class="tok-kw">const</span> Sort = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L93">                <span class="tok-kw">fn</span> <span class="tok-fn">lessThan</span>(trash: *<span class="tok-type">i32</span>, lhs: Data, rhs: Data) <span class="tok-type">bool</span> {</span>
<span class="line" id="L94">                    _ = trash;</span>
<span class="line" id="L95">                    <span class="tok-kw">return</span> lhs.alignment &gt; rhs.alignment;</span>
<span class="line" id="L96">                }</span>
<span class="line" id="L97">            };</span>
<span class="line" id="L98">            <span class="tok-kw">var</span> trash: <span class="tok-type">i32</span> = <span class="tok-null">undefined</span>; <span class="tok-comment">// workaround for stage1 compiler bug</span>
</span>
<span class="line" id="L99">            std.sort.sort(Data, &amp;data, &amp;trash, Sort.lessThan);</span>
<span class="line" id="L100">            <span class="tok-kw">var</span> sizes_bytes: [fields.len]<span class="tok-type">usize</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L101">            <span class="tok-kw">var</span> field_indexes: [fields.len]<span class="tok-type">usize</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L102">            <span class="tok-kw">for</span> (data) |elem, i| {</span>
<span class="line" id="L103">                sizes_bytes[i] = elem.size;</span>
<span class="line" id="L104">                field_indexes[i] = elem.size_index;</span>
<span class="line" id="L105">            }</span>
<span class="line" id="L106">            <span class="tok-kw">break</span> :blk .{</span>
<span class="line" id="L107">                .bytes = sizes_bytes,</span>
<span class="line" id="L108">                .fields = field_indexes,</span>
<span class="line" id="L109">            };</span>
<span class="line" id="L110">        };</span>
<span class="line" id="L111"></span>
<span class="line" id="L112">        <span class="tok-comment">/// Release all allocated memory.</span></span>
<span class="line" id="L113">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">deinit</span>(self: *Self, gpa: Allocator) <span class="tok-type">void</span> {</span>
<span class="line" id="L114">            gpa.free(self.allocatedBytes());</span>
<span class="line" id="L115">            self.* = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L116">        }</span>
<span class="line" id="L117"></span>
<span class="line" id="L118">        <span class="tok-comment">/// The caller owns the returned memory. Empties this MultiArrayList.</span></span>
<span class="line" id="L119">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">toOwnedSlice</span>(self: *Self) Slice {</span>
<span class="line" id="L120">            <span class="tok-kw">const</span> result = self.slice();</span>
<span class="line" id="L121">            self.* = .{};</span>
<span class="line" id="L122">            <span class="tok-kw">return</span> result;</span>
<span class="line" id="L123">        }</span>
<span class="line" id="L124"></span>
<span class="line" id="L125">        <span class="tok-comment">/// Compute pointers to the start of each field of the array.</span></span>
<span class="line" id="L126">        <span class="tok-comment">/// If you need to access multiple fields, calling this may</span></span>
<span class="line" id="L127">        <span class="tok-comment">/// be more efficient than calling `items()` multiple times.</span></span>
<span class="line" id="L128">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">slice</span>(self: Self) Slice {</span>
<span class="line" id="L129">            <span class="tok-kw">var</span> result: Slice = .{</span>
<span class="line" id="L130">                .ptrs = <span class="tok-null">undefined</span>,</span>
<span class="line" id="L131">                .len = self.len,</span>
<span class="line" id="L132">                .capacity = self.capacity,</span>
<span class="line" id="L133">            };</span>
<span class="line" id="L134">            <span class="tok-kw">var</span> ptr: [*]<span class="tok-type">u8</span> = self.bytes;</span>
<span class="line" id="L135">            <span class="tok-kw">for</span> (sizes.bytes) |field_size, i| {</span>
<span class="line" id="L136">                result.ptrs[sizes.fields[i]] = ptr;</span>
<span class="line" id="L137">                ptr += field_size * self.capacity;</span>
<span class="line" id="L138">            }</span>
<span class="line" id="L139">            <span class="tok-kw">return</span> result;</span>
<span class="line" id="L140">        }</span>
<span class="line" id="L141"></span>
<span class="line" id="L142">        <span class="tok-comment">/// Get the slice of values for a specified field.</span></span>
<span class="line" id="L143">        <span class="tok-comment">/// If you need multiple fields, consider calling slice()</span></span>
<span class="line" id="L144">        <span class="tok-comment">/// instead.</span></span>
<span class="line" id="L145">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">items</span>(self: Self, <span class="tok-kw">comptime</span> field: Field) []FieldType(field) {</span>
<span class="line" id="L146">            <span class="tok-kw">return</span> self.slice().items(field);</span>
<span class="line" id="L147">        }</span>
<span class="line" id="L148"></span>
<span class="line" id="L149">        <span class="tok-comment">/// Overwrite one array element with new data.</span></span>
<span class="line" id="L150">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">set</span>(self: *Self, index: <span class="tok-type">usize</span>, elem: S) <span class="tok-type">void</span> {</span>
<span class="line" id="L151">            <span class="tok-kw">const</span> slices = self.slice();</span>
<span class="line" id="L152">            <span class="tok-kw">inline</span> <span class="tok-kw">for</span> (fields) |field_info, i| {</span>
<span class="line" id="L153">                slices.items(<span class="tok-builtin">@intToEnum</span>(Field, i))[index] = <span class="tok-builtin">@field</span>(elem, field_info.name);</span>
<span class="line" id="L154">            }</span>
<span class="line" id="L155">        }</span>
<span class="line" id="L156"></span>
<span class="line" id="L157">        <span class="tok-comment">/// Obtain all the data for one array element.</span></span>
<span class="line" id="L158">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">get</span>(self: Self, index: <span class="tok-type">usize</span>) S {</span>
<span class="line" id="L159">            <span class="tok-kw">const</span> slices = self.slice();</span>
<span class="line" id="L160">            <span class="tok-kw">var</span> result: S = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L161">            <span class="tok-kw">inline</span> <span class="tok-kw">for</span> (fields) |field_info, i| {</span>
<span class="line" id="L162">                <span class="tok-builtin">@field</span>(result, field_info.name) = slices.items(<span class="tok-builtin">@intToEnum</span>(Field, i))[index];</span>
<span class="line" id="L163">            }</span>
<span class="line" id="L164">            <span class="tok-kw">return</span> result;</span>
<span class="line" id="L165">        }</span>
<span class="line" id="L166"></span>
<span class="line" id="L167">        <span class="tok-comment">/// Extend the list by 1 element. Allocates more memory as necessary.</span></span>
<span class="line" id="L168">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">append</span>(self: *Self, gpa: Allocator, elem: S) !<span class="tok-type">void</span> {</span>
<span class="line" id="L169">            <span class="tok-kw">try</span> self.ensureUnusedCapacity(gpa, <span class="tok-number">1</span>);</span>
<span class="line" id="L170">            self.appendAssumeCapacity(elem);</span>
<span class="line" id="L171">        }</span>
<span class="line" id="L172"></span>
<span class="line" id="L173">        <span class="tok-comment">/// Extend the list by 1 element, but asserting `self.capacity`</span></span>
<span class="line" id="L174">        <span class="tok-comment">/// is sufficient to hold an additional item.</span></span>
<span class="line" id="L175">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">appendAssumeCapacity</span>(self: *Self, elem: S) <span class="tok-type">void</span> {</span>
<span class="line" id="L176">            assert(self.len &lt; self.capacity);</span>
<span class="line" id="L177">            self.len += <span class="tok-number">1</span>;</span>
<span class="line" id="L178">            self.set(self.len - <span class="tok-number">1</span>, elem);</span>
<span class="line" id="L179">        }</span>
<span class="line" id="L180"></span>
<span class="line" id="L181">        <span class="tok-comment">/// Extend the list by 1 element, returning the newly reserved</span></span>
<span class="line" id="L182">        <span class="tok-comment">/// index with uninitialized data.</span></span>
<span class="line" id="L183">        <span class="tok-comment">/// Allocates more memory as necesasry.</span></span>
<span class="line" id="L184">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">addOne</span>(self: *Self, allocator: Allocator) Allocator.Error!<span class="tok-type">usize</span> {</span>
<span class="line" id="L185">            <span class="tok-kw">try</span> self.ensureUnusedCapacity(allocator, <span class="tok-number">1</span>);</span>
<span class="line" id="L186">            <span class="tok-kw">return</span> self.addOneAssumeCapacity();</span>
<span class="line" id="L187">        }</span>
<span class="line" id="L188"></span>
<span class="line" id="L189">        <span class="tok-comment">/// Extend the list by 1 element, asserting `self.capacity`</span></span>
<span class="line" id="L190">        <span class="tok-comment">/// is sufficient to hold an additional item.  Returns the</span></span>
<span class="line" id="L191">        <span class="tok-comment">/// newly reserved index with uninitialized data.</span></span>
<span class="line" id="L192">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">addOneAssumeCapacity</span>(self: *Self) <span class="tok-type">usize</span> {</span>
<span class="line" id="L193">            assert(self.len &lt; self.capacity);</span>
<span class="line" id="L194">            <span class="tok-kw">const</span> index = self.len;</span>
<span class="line" id="L195">            self.len += <span class="tok-number">1</span>;</span>
<span class="line" id="L196">            <span class="tok-kw">return</span> index;</span>
<span class="line" id="L197">        }</span>
<span class="line" id="L198"></span>
<span class="line" id="L199">        <span class="tok-comment">/// Remove and return the last element from the list.</span></span>
<span class="line" id="L200">        <span class="tok-comment">/// Asserts the list has at least one item.</span></span>
<span class="line" id="L201">        <span class="tok-comment">/// Invalidates pointers to fields of the removed element.</span></span>
<span class="line" id="L202">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">pop</span>(self: *Self) S {</span>
<span class="line" id="L203">            <span class="tok-kw">const</span> val = self.get(self.len - <span class="tok-number">1</span>);</span>
<span class="line" id="L204">            self.len -= <span class="tok-number">1</span>;</span>
<span class="line" id="L205">            <span class="tok-kw">return</span> val;</span>
<span class="line" id="L206">        }</span>
<span class="line" id="L207"></span>
<span class="line" id="L208">        <span class="tok-comment">/// Remove and return the last element from the list, or</span></span>
<span class="line" id="L209">        <span class="tok-comment">/// return `null` if list is empty.</span></span>
<span class="line" id="L210">        <span class="tok-comment">/// Invalidates pointers to fields of the removed element, if any.</span></span>
<span class="line" id="L211">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">popOrNull</span>(self: *Self) ?S {</span>
<span class="line" id="L212">            <span class="tok-kw">if</span> (self.len == <span class="tok-number">0</span>) <span class="tok-kw">return</span> <span class="tok-null">null</span>;</span>
<span class="line" id="L213">            <span class="tok-kw">return</span> self.pop();</span>
<span class="line" id="L214">        }</span>
<span class="line" id="L215"></span>
<span class="line" id="L216">        <span class="tok-comment">/// Inserts an item into an ordered list.  Shifts all elements</span></span>
<span class="line" id="L217">        <span class="tok-comment">/// after and including the specified index back by one and</span></span>
<span class="line" id="L218">        <span class="tok-comment">/// sets the given index to the specified element.  May reallocate</span></span>
<span class="line" id="L219">        <span class="tok-comment">/// and invalidate iterators.</span></span>
<span class="line" id="L220">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">insert</span>(self: *Self, gpa: Allocator, index: <span class="tok-type">usize</span>, elem: S) !<span class="tok-type">void</span> {</span>
<span class="line" id="L221">            <span class="tok-kw">try</span> self.ensureUnusedCapacity(gpa, <span class="tok-number">1</span>);</span>
<span class="line" id="L222">            self.insertAssumeCapacity(index, elem);</span>
<span class="line" id="L223">        }</span>
<span class="line" id="L224"></span>
<span class="line" id="L225">        <span class="tok-comment">/// Inserts an item into an ordered list which has room for it.</span></span>
<span class="line" id="L226">        <span class="tok-comment">/// Shifts all elements after and including the specified index</span></span>
<span class="line" id="L227">        <span class="tok-comment">/// back by one and sets the given index to the specified element.</span></span>
<span class="line" id="L228">        <span class="tok-comment">/// Will not reallocate the array, does not invalidate iterators.</span></span>
<span class="line" id="L229">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">insertAssumeCapacity</span>(self: *Self, index: <span class="tok-type">usize</span>, elem: S) <span class="tok-type">void</span> {</span>
<span class="line" id="L230">            assert(self.len &lt; self.capacity);</span>
<span class="line" id="L231">            assert(index &lt;= self.len);</span>
<span class="line" id="L232">            self.len += <span class="tok-number">1</span>;</span>
<span class="line" id="L233">            <span class="tok-kw">const</span> slices = self.slice();</span>
<span class="line" id="L234">            <span class="tok-kw">inline</span> <span class="tok-kw">for</span> (fields) |field_info, field_index| {</span>
<span class="line" id="L235">                <span class="tok-kw">const</span> field_slice = slices.items(<span class="tok-builtin">@intToEnum</span>(Field, field_index));</span>
<span class="line" id="L236">                <span class="tok-kw">var</span> i: <span class="tok-type">usize</span> = self.len - <span class="tok-number">1</span>;</span>
<span class="line" id="L237">                <span class="tok-kw">while</span> (i &gt; index) : (i -= <span class="tok-number">1</span>) {</span>
<span class="line" id="L238">                    field_slice[i] = field_slice[i - <span class="tok-number">1</span>];</span>
<span class="line" id="L239">                }</span>
<span class="line" id="L240">                field_slice[index] = <span class="tok-builtin">@field</span>(elem, field_info.name);</span>
<span class="line" id="L241">            }</span>
<span class="line" id="L242">        }</span>
<span class="line" id="L243"></span>
<span class="line" id="L244">        <span class="tok-comment">/// Remove the specified item from the list, swapping the last</span></span>
<span class="line" id="L245">        <span class="tok-comment">/// item in the list into its position.  Fast, but does not</span></span>
<span class="line" id="L246">        <span class="tok-comment">/// retain list ordering.</span></span>
<span class="line" id="L247">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">swapRemove</span>(self: *Self, index: <span class="tok-type">usize</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L248">            <span class="tok-kw">const</span> slices = self.slice();</span>
<span class="line" id="L249">            <span class="tok-kw">inline</span> <span class="tok-kw">for</span> (fields) |_, i| {</span>
<span class="line" id="L250">                <span class="tok-kw">const</span> field_slice = slices.items(<span class="tok-builtin">@intToEnum</span>(Field, i));</span>
<span class="line" id="L251">                field_slice[index] = field_slice[self.len - <span class="tok-number">1</span>];</span>
<span class="line" id="L252">                field_slice[self.len - <span class="tok-number">1</span>] = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L253">            }</span>
<span class="line" id="L254">            self.len -= <span class="tok-number">1</span>;</span>
<span class="line" id="L255">        }</span>
<span class="line" id="L256"></span>
<span class="line" id="L257">        <span class="tok-comment">/// Remove the specified item from the list, shifting items</span></span>
<span class="line" id="L258">        <span class="tok-comment">/// after it to preserve order.</span></span>
<span class="line" id="L259">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">orderedRemove</span>(self: *Self, index: <span class="tok-type">usize</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L260">            <span class="tok-kw">const</span> slices = self.slice();</span>
<span class="line" id="L261">            <span class="tok-kw">inline</span> <span class="tok-kw">for</span> (fields) |_, field_index| {</span>
<span class="line" id="L262">                <span class="tok-kw">const</span> field_slice = slices.items(<span class="tok-builtin">@intToEnum</span>(Field, field_index));</span>
<span class="line" id="L263">                <span class="tok-kw">var</span> i = index;</span>
<span class="line" id="L264">                <span class="tok-kw">while</span> (i &lt; self.len - <span class="tok-number">1</span>) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L265">                    field_slice[i] = field_slice[i + <span class="tok-number">1</span>];</span>
<span class="line" id="L266">                }</span>
<span class="line" id="L267">                field_slice[i] = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L268">            }</span>
<span class="line" id="L269">            self.len -= <span class="tok-number">1</span>;</span>
<span class="line" id="L270">        }</span>
<span class="line" id="L271"></span>
<span class="line" id="L272">        <span class="tok-comment">/// Adjust the list's length to `new_len`.</span></span>
<span class="line" id="L273">        <span class="tok-comment">/// Does not initialize added items, if any.</span></span>
<span class="line" id="L274">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">resize</span>(self: *Self, gpa: Allocator, new_len: <span class="tok-type">usize</span>) !<span class="tok-type">void</span> {</span>
<span class="line" id="L275">            <span class="tok-kw">try</span> self.ensureTotalCapacity(gpa, new_len);</span>
<span class="line" id="L276">            self.len = new_len;</span>
<span class="line" id="L277">        }</span>
<span class="line" id="L278"></span>
<span class="line" id="L279">        <span class="tok-comment">/// Attempt to reduce allocated capacity to `new_len`.</span></span>
<span class="line" id="L280">        <span class="tok-comment">/// If `new_len` is greater than zero, this may fail to reduce the capacity,</span></span>
<span class="line" id="L281">        <span class="tok-comment">/// but the data remains intact and the length is updated to new_len.</span></span>
<span class="line" id="L282">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">shrinkAndFree</span>(self: *Self, gpa: Allocator, new_len: <span class="tok-type">usize</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L283">            <span class="tok-kw">if</span> (new_len == <span class="tok-number">0</span>) {</span>
<span class="line" id="L284">                gpa.free(self.allocatedBytes());</span>
<span class="line" id="L285">                self.* = .{};</span>
<span class="line" id="L286">                <span class="tok-kw">return</span>;</span>
<span class="line" id="L287">            }</span>
<span class="line" id="L288">            assert(new_len &lt;= self.capacity);</span>
<span class="line" id="L289">            assert(new_len &lt;= self.len);</span>
<span class="line" id="L290"></span>
<span class="line" id="L291">            <span class="tok-kw">const</span> other_bytes = gpa.allocAdvanced(</span>
<span class="line" id="L292">                <span class="tok-type">u8</span>,</span>
<span class="line" id="L293">                <span class="tok-builtin">@alignOf</span>(S),</span>
<span class="line" id="L294">                capacityInBytes(new_len),</span>
<span class="line" id="L295">                .exact,</span>
<span class="line" id="L296">            ) <span class="tok-kw">catch</span> {</span>
<span class="line" id="L297">                <span class="tok-kw">const</span> self_slice = self.slice();</span>
<span class="line" id="L298">                <span class="tok-kw">inline</span> <span class="tok-kw">for</span> (fields) |field_info, i| {</span>
<span class="line" id="L299">                    <span class="tok-kw">if</span> (<span class="tok-builtin">@sizeOf</span>(field_info.field_type) != <span class="tok-number">0</span>) {</span>
<span class="line" id="L300">                        <span class="tok-kw">const</span> field = <span class="tok-builtin">@intToEnum</span>(Field, i);</span>
<span class="line" id="L301">                        <span class="tok-kw">const</span> dest_slice = self_slice.items(field)[new_len..];</span>
<span class="line" id="L302">                        <span class="tok-kw">const</span> byte_count = dest_slice.len * <span class="tok-builtin">@sizeOf</span>(field_info.field_type);</span>
<span class="line" id="L303">                        <span class="tok-comment">// We use memset here for more efficient codegen in safety-checked,</span>
</span>
<span class="line" id="L304">                        <span class="tok-comment">// valgrind-enabled builds. Otherwise the valgrind client request</span>
</span>
<span class="line" id="L305">                        <span class="tok-comment">// will be repeated for every element.</span>
</span>
<span class="line" id="L306">                        <span class="tok-builtin">@memset</span>(<span class="tok-builtin">@ptrCast</span>([*]<span class="tok-type">u8</span>, dest_slice.ptr), <span class="tok-null">undefined</span>, byte_count);</span>
<span class="line" id="L307">                    }</span>
<span class="line" id="L308">                }</span>
<span class="line" id="L309">                self.len = new_len;</span>
<span class="line" id="L310">                <span class="tok-kw">return</span>;</span>
<span class="line" id="L311">            };</span>
<span class="line" id="L312">            <span class="tok-kw">var</span> other = Self{</span>
<span class="line" id="L313">                .bytes = other_bytes.ptr,</span>
<span class="line" id="L314">                .capacity = new_len,</span>
<span class="line" id="L315">                .len = new_len,</span>
<span class="line" id="L316">            };</span>
<span class="line" id="L317">            self.len = new_len;</span>
<span class="line" id="L318">            <span class="tok-kw">const</span> self_slice = self.slice();</span>
<span class="line" id="L319">            <span class="tok-kw">const</span> other_slice = other.slice();</span>
<span class="line" id="L320">            <span class="tok-kw">inline</span> <span class="tok-kw">for</span> (fields) |field_info, i| {</span>
<span class="line" id="L321">                <span class="tok-kw">if</span> (<span class="tok-builtin">@sizeOf</span>(field_info.field_type) != <span class="tok-number">0</span>) {</span>
<span class="line" id="L322">                    <span class="tok-kw">const</span> field = <span class="tok-builtin">@intToEnum</span>(Field, i);</span>
<span class="line" id="L323">                    <span class="tok-comment">// TODO we should be able to use std.mem.copy here but it causes a</span>
</span>
<span class="line" id="L324">                    <span class="tok-comment">// test failure on aarch64 with -OReleaseFast</span>
</span>
<span class="line" id="L325">                    <span class="tok-kw">const</span> src_slice = mem.sliceAsBytes(self_slice.items(field));</span>
<span class="line" id="L326">                    <span class="tok-kw">const</span> dst_slice = mem.sliceAsBytes(other_slice.items(field));</span>
<span class="line" id="L327">                    <span class="tok-builtin">@memcpy</span>(dst_slice.ptr, src_slice.ptr, src_slice.len);</span>
<span class="line" id="L328">                }</span>
<span class="line" id="L329">            }</span>
<span class="line" id="L330">            gpa.free(self.allocatedBytes());</span>
<span class="line" id="L331">            self.* = other;</span>
<span class="line" id="L332">        }</span>
<span class="line" id="L333"></span>
<span class="line" id="L334">        <span class="tok-comment">/// Reduce length to `new_len`.</span></span>
<span class="line" id="L335">        <span class="tok-comment">/// Invalidates pointers to elements `items[new_len..]`.</span></span>
<span class="line" id="L336">        <span class="tok-comment">/// Keeps capacity the same.</span></span>
<span class="line" id="L337">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">shrinkRetainingCapacity</span>(self: *Self, new_len: <span class="tok-type">usize</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L338">            self.len = new_len;</span>
<span class="line" id="L339">        }</span>
<span class="line" id="L340"></span>
<span class="line" id="L341">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> ensureCapacity = <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;deprecated; call `ensureUnusedCapacity` or `ensureTotalCapacity`&quot;</span>);</span>
<span class="line" id="L342"></span>
<span class="line" id="L343">        <span class="tok-comment">/// Modify the array so that it can hold at least `new_capacity` items.</span></span>
<span class="line" id="L344">        <span class="tok-comment">/// Implements super-linear growth to achieve amortized O(1) append operations.</span></span>
<span class="line" id="L345">        <span class="tok-comment">/// Invalidates pointers if additional memory is needed.</span></span>
<span class="line" id="L346">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">ensureTotalCapacity</span>(self: *Self, gpa: Allocator, new_capacity: <span class="tok-type">usize</span>) !<span class="tok-type">void</span> {</span>
<span class="line" id="L347">            <span class="tok-kw">var</span> better_capacity = self.capacity;</span>
<span class="line" id="L348">            <span class="tok-kw">if</span> (better_capacity &gt;= new_capacity) <span class="tok-kw">return</span>;</span>
<span class="line" id="L349"></span>
<span class="line" id="L350">            <span class="tok-kw">while</span> (<span class="tok-null">true</span>) {</span>
<span class="line" id="L351">                better_capacity += better_capacity / <span class="tok-number">2</span> + <span class="tok-number">8</span>;</span>
<span class="line" id="L352">                <span class="tok-kw">if</span> (better_capacity &gt;= new_capacity) <span class="tok-kw">break</span>;</span>
<span class="line" id="L353">            }</span>
<span class="line" id="L354"></span>
<span class="line" id="L355">            <span class="tok-kw">return</span> self.setCapacity(gpa, better_capacity);</span>
<span class="line" id="L356">        }</span>
<span class="line" id="L357"></span>
<span class="line" id="L358">        <span class="tok-comment">/// Modify the array so that it can hold at least `additional_count` **more** items.</span></span>
<span class="line" id="L359">        <span class="tok-comment">/// Invalidates pointers if additional memory is needed.</span></span>
<span class="line" id="L360">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">ensureUnusedCapacity</span>(self: *Self, gpa: Allocator, additional_count: <span class="tok-type">usize</span>) !<span class="tok-type">void</span> {</span>
<span class="line" id="L361">            <span class="tok-kw">return</span> self.ensureTotalCapacity(gpa, self.len + additional_count);</span>
<span class="line" id="L362">        }</span>
<span class="line" id="L363"></span>
<span class="line" id="L364">        <span class="tok-comment">/// Modify the array so that it can hold exactly `new_capacity` items.</span></span>
<span class="line" id="L365">        <span class="tok-comment">/// Invalidates pointers if additional memory is needed.</span></span>
<span class="line" id="L366">        <span class="tok-comment">/// `new_capacity` must be greater or equal to `len`.</span></span>
<span class="line" id="L367">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">setCapacity</span>(self: *Self, gpa: Allocator, new_capacity: <span class="tok-type">usize</span>) !<span class="tok-type">void</span> {</span>
<span class="line" id="L368">            assert(new_capacity &gt;= self.len);</span>
<span class="line" id="L369">            <span class="tok-kw">const</span> new_bytes = <span class="tok-kw">try</span> gpa.allocAdvanced(</span>
<span class="line" id="L370">                <span class="tok-type">u8</span>,</span>
<span class="line" id="L371">                <span class="tok-builtin">@alignOf</span>(S),</span>
<span class="line" id="L372">                capacityInBytes(new_capacity),</span>
<span class="line" id="L373">                .exact,</span>
<span class="line" id="L374">            );</span>
<span class="line" id="L375">            <span class="tok-kw">if</span> (self.len == <span class="tok-number">0</span>) {</span>
<span class="line" id="L376">                gpa.free(self.allocatedBytes());</span>
<span class="line" id="L377">                self.bytes = new_bytes.ptr;</span>
<span class="line" id="L378">                self.capacity = new_capacity;</span>
<span class="line" id="L379">                <span class="tok-kw">return</span>;</span>
<span class="line" id="L380">            }</span>
<span class="line" id="L381">            <span class="tok-kw">var</span> other = Self{</span>
<span class="line" id="L382">                .bytes = new_bytes.ptr,</span>
<span class="line" id="L383">                .capacity = new_capacity,</span>
<span class="line" id="L384">                .len = self.len,</span>
<span class="line" id="L385">            };</span>
<span class="line" id="L386">            <span class="tok-kw">const</span> self_slice = self.slice();</span>
<span class="line" id="L387">            <span class="tok-kw">const</span> other_slice = other.slice();</span>
<span class="line" id="L388">            <span class="tok-kw">inline</span> <span class="tok-kw">for</span> (fields) |field_info, i| {</span>
<span class="line" id="L389">                <span class="tok-kw">if</span> (<span class="tok-builtin">@sizeOf</span>(field_info.field_type) != <span class="tok-number">0</span>) {</span>
<span class="line" id="L390">                    <span class="tok-kw">const</span> field = <span class="tok-builtin">@intToEnum</span>(Field, i);</span>
<span class="line" id="L391">                    <span class="tok-comment">// TODO we should be able to use std.mem.copy here but it causes a</span>
</span>
<span class="line" id="L392">                    <span class="tok-comment">// test failure on aarch64 with -OReleaseFast</span>
</span>
<span class="line" id="L393">                    <span class="tok-kw">const</span> src_slice = mem.sliceAsBytes(self_slice.items(field));</span>
<span class="line" id="L394">                    <span class="tok-kw">const</span> dst_slice = mem.sliceAsBytes(other_slice.items(field));</span>
<span class="line" id="L395">                    <span class="tok-builtin">@memcpy</span>(dst_slice.ptr, src_slice.ptr, src_slice.len);</span>
<span class="line" id="L396">                }</span>
<span class="line" id="L397">            }</span>
<span class="line" id="L398">            gpa.free(self.allocatedBytes());</span>
<span class="line" id="L399">            self.* = other;</span>
<span class="line" id="L400">        }</span>
<span class="line" id="L401"></span>
<span class="line" id="L402">        <span class="tok-comment">/// Create a copy of this list with a new backing store,</span></span>
<span class="line" id="L403">        <span class="tok-comment">/// using the specified allocator.</span></span>
<span class="line" id="L404">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">clone</span>(self: Self, gpa: Allocator) !Self {</span>
<span class="line" id="L405">            <span class="tok-kw">var</span> result = Self{};</span>
<span class="line" id="L406">            <span class="tok-kw">errdefer</span> result.deinit(gpa);</span>
<span class="line" id="L407">            <span class="tok-kw">try</span> result.ensureTotalCapacity(gpa, self.len);</span>
<span class="line" id="L408">            result.len = self.len;</span>
<span class="line" id="L409">            <span class="tok-kw">const</span> self_slice = self.slice();</span>
<span class="line" id="L410">            <span class="tok-kw">const</span> result_slice = result.slice();</span>
<span class="line" id="L411">            <span class="tok-kw">inline</span> <span class="tok-kw">for</span> (fields) |field_info, i| {</span>
<span class="line" id="L412">                <span class="tok-kw">if</span> (<span class="tok-builtin">@sizeOf</span>(field_info.field_type) != <span class="tok-number">0</span>) {</span>
<span class="line" id="L413">                    <span class="tok-kw">const</span> field = <span class="tok-builtin">@intToEnum</span>(Field, i);</span>
<span class="line" id="L414">                    <span class="tok-comment">// TODO we should be able to use std.mem.copy here but it causes a</span>
</span>
<span class="line" id="L415">                    <span class="tok-comment">// test failure on aarch64 with -OReleaseFast</span>
</span>
<span class="line" id="L416">                    <span class="tok-kw">const</span> src_slice = mem.sliceAsBytes(self_slice.items(field));</span>
<span class="line" id="L417">                    <span class="tok-kw">const</span> dst_slice = mem.sliceAsBytes(result_slice.items(field));</span>
<span class="line" id="L418">                    <span class="tok-builtin">@memcpy</span>(dst_slice.ptr, src_slice.ptr, src_slice.len);</span>
<span class="line" id="L419">                }</span>
<span class="line" id="L420">            }</span>
<span class="line" id="L421">            <span class="tok-kw">return</span> result;</span>
<span class="line" id="L422">        }</span>
<span class="line" id="L423"></span>
<span class="line" id="L424">        <span class="tok-comment">/// `ctx` has the following method:</span></span>
<span class="line" id="L425">        <span class="tok-comment">/// `fn lessThan(ctx: @TypeOf(ctx), a_index: usize, b_index: usize) bool`</span></span>
<span class="line" id="L426">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">sort</span>(self: Self, ctx: <span class="tok-kw">anytype</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L427">            <span class="tok-kw">const</span> SortContext = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L428">                sub_ctx: <span class="tok-builtin">@TypeOf</span>(ctx),</span>
<span class="line" id="L429">                slice: Slice,</span>
<span class="line" id="L430"></span>
<span class="line" id="L431">                <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">swap</span>(sc: <span class="tok-builtin">@This</span>(), a_index: <span class="tok-type">usize</span>, b_index: <span class="tok-type">usize</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L432">                    <span class="tok-kw">inline</span> <span class="tok-kw">for</span> (fields) |field_info, i| {</span>
<span class="line" id="L433">                        <span class="tok-kw">if</span> (<span class="tok-builtin">@sizeOf</span>(field_info.field_type) != <span class="tok-number">0</span>) {</span>
<span class="line" id="L434">                            <span class="tok-kw">const</span> field = <span class="tok-builtin">@intToEnum</span>(Field, i);</span>
<span class="line" id="L435">                            <span class="tok-kw">const</span> ptr = sc.slice.items(field);</span>
<span class="line" id="L436">                            mem.swap(field_info.field_type, &amp;ptr[a_index], &amp;ptr[b_index]);</span>
<span class="line" id="L437">                        }</span>
<span class="line" id="L438">                    }</span>
<span class="line" id="L439">                }</span>
<span class="line" id="L440"></span>
<span class="line" id="L441">                <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">lessThan</span>(sc: <span class="tok-builtin">@This</span>(), a_index: <span class="tok-type">usize</span>, b_index: <span class="tok-type">usize</span>) <span class="tok-type">bool</span> {</span>
<span class="line" id="L442">                    <span class="tok-kw">return</span> sc.sub_ctx.lessThan(a_index, b_index);</span>
<span class="line" id="L443">                }</span>
<span class="line" id="L444">            };</span>
<span class="line" id="L445"></span>
<span class="line" id="L446">            std.sort.sortContext(self.len, SortContext{</span>
<span class="line" id="L447">                .sub_ctx = ctx,</span>
<span class="line" id="L448">                .slice = self.slice(),</span>
<span class="line" id="L449">            });</span>
<span class="line" id="L450">        }</span>
<span class="line" id="L451"></span>
<span class="line" id="L452">        <span class="tok-kw">fn</span> <span class="tok-fn">capacityInBytes</span>(capacity: <span class="tok-type">usize</span>) <span class="tok-type">usize</span> {</span>
<span class="line" id="L453">            <span class="tok-kw">const</span> sizes_vector: <span class="tok-builtin">@Vector</span>(sizes.bytes.len, <span class="tok-type">usize</span>) = sizes.bytes;</span>
<span class="line" id="L454">            <span class="tok-kw">const</span> capacity_vector = <span class="tok-builtin">@splat</span>(sizes.bytes.len, capacity);</span>
<span class="line" id="L455">            <span class="tok-kw">return</span> <span class="tok-builtin">@reduce</span>(.Add, capacity_vector * sizes_vector);</span>
<span class="line" id="L456">        }</span>
<span class="line" id="L457"></span>
<span class="line" id="L458">        <span class="tok-kw">fn</span> <span class="tok-fn">allocatedBytes</span>(self: Self) []<span class="tok-kw">align</span>(<span class="tok-builtin">@alignOf</span>(S)) <span class="tok-type">u8</span> {</span>
<span class="line" id="L459">            <span class="tok-kw">return</span> self.bytes[<span class="tok-number">0</span>..capacityInBytes(self.capacity)];</span>
<span class="line" id="L460">        }</span>
<span class="line" id="L461"></span>
<span class="line" id="L462">        <span class="tok-kw">fn</span> <span class="tok-fn">FieldType</span>(field: Field) <span class="tok-type">type</span> {</span>
<span class="line" id="L463">            <span class="tok-kw">return</span> meta.fieldInfo(S, field).field_type;</span>
<span class="line" id="L464">        }</span>
<span class="line" id="L465"></span>
<span class="line" id="L466">        <span class="tok-comment">/// This function is used in tools/zig-gdb.py to fetch the child type to facilitate</span></span>
<span class="line" id="L467">        <span class="tok-comment">/// fancy debug printing for this type.</span></span>
<span class="line" id="L468">        <span class="tok-kw">fn</span> <span class="tok-fn">gdbHelper</span>(self: *Self, child: *S) <span class="tok-type">void</span> {</span>
<span class="line" id="L469">            _ = self;</span>
<span class="line" id="L470">            _ = child;</span>
<span class="line" id="L471">        }</span>
<span class="line" id="L472"></span>
<span class="line" id="L473">        <span class="tok-kw">comptime</span> {</span>
<span class="line" id="L474">            <span class="tok-kw">if</span> (builtin.mode == .Debug) {</span>
<span class="line" id="L475">                _ = gdbHelper;</span>
<span class="line" id="L476">            }</span>
<span class="line" id="L477">        }</span>
<span class="line" id="L478">    };</span>
<span class="line" id="L479">}</span>
<span class="line" id="L480"></span>
<span class="line" id="L481"><span class="tok-kw">test</span> <span class="tok-str">&quot;basic usage&quot;</span> {</span>
<span class="line" id="L482">    <span class="tok-kw">const</span> ally = testing.allocator;</span>
<span class="line" id="L483"></span>
<span class="line" id="L484">    <span class="tok-kw">const</span> Foo = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L485">        a: <span class="tok-type">u32</span>,</span>
<span class="line" id="L486">        b: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L487">        c: <span class="tok-type">u8</span>,</span>
<span class="line" id="L488">    };</span>
<span class="line" id="L489"></span>
<span class="line" id="L490">    <span class="tok-kw">var</span> list = MultiArrayList(Foo){};</span>
<span class="line" id="L491">    <span class="tok-kw">defer</span> list.deinit(ally);</span>
<span class="line" id="L492"></span>
<span class="line" id="L493">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">usize</span>, <span class="tok-number">0</span>), list.items(.a).len);</span>
<span class="line" id="L494"></span>
<span class="line" id="L495">    <span class="tok-kw">try</span> list.ensureTotalCapacity(ally, <span class="tok-number">2</span>);</span>
<span class="line" id="L496"></span>
<span class="line" id="L497">    list.appendAssumeCapacity(.{</span>
<span class="line" id="L498">        .a = <span class="tok-number">1</span>,</span>
<span class="line" id="L499">        .b = <span class="tok-str">&quot;foobar&quot;</span>,</span>
<span class="line" id="L500">        .c = <span class="tok-str">'a'</span>,</span>
<span class="line" id="L501">    });</span>
<span class="line" id="L502"></span>
<span class="line" id="L503">    list.appendAssumeCapacity(.{</span>
<span class="line" id="L504">        .a = <span class="tok-number">2</span>,</span>
<span class="line" id="L505">        .b = <span class="tok-str">&quot;zigzag&quot;</span>,</span>
<span class="line" id="L506">        .c = <span class="tok-str">'b'</span>,</span>
<span class="line" id="L507">    });</span>
<span class="line" id="L508"></span>
<span class="line" id="L509">    <span class="tok-kw">try</span> testing.expectEqualSlices(<span class="tok-type">u32</span>, list.items(.a), &amp;[_]<span class="tok-type">u32</span>{ <span class="tok-number">1</span>, <span class="tok-number">2</span> });</span>
<span class="line" id="L510">    <span class="tok-kw">try</span> testing.expectEqualSlices(<span class="tok-type">u8</span>, list.items(.c), &amp;[_]<span class="tok-type">u8</span>{ <span class="tok-str">'a'</span>, <span class="tok-str">'b'</span> });</span>
<span class="line" id="L511"></span>
<span class="line" id="L512">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">usize</span>, <span class="tok-number">2</span>), list.items(.b).len);</span>
<span class="line" id="L513">    <span class="tok-kw">try</span> testing.expectEqualStrings(<span class="tok-str">&quot;foobar&quot;</span>, list.items(.b)[<span class="tok-number">0</span>]);</span>
<span class="line" id="L514">    <span class="tok-kw">try</span> testing.expectEqualStrings(<span class="tok-str">&quot;zigzag&quot;</span>, list.items(.b)[<span class="tok-number">1</span>]);</span>
<span class="line" id="L515"></span>
<span class="line" id="L516">    <span class="tok-kw">try</span> list.append(ally, .{</span>
<span class="line" id="L517">        .a = <span class="tok-number">3</span>,</span>
<span class="line" id="L518">        .b = <span class="tok-str">&quot;fizzbuzz&quot;</span>,</span>
<span class="line" id="L519">        .c = <span class="tok-str">'c'</span>,</span>
<span class="line" id="L520">    });</span>
<span class="line" id="L521"></span>
<span class="line" id="L522">    <span class="tok-kw">try</span> testing.expectEqualSlices(<span class="tok-type">u32</span>, list.items(.a), &amp;[_]<span class="tok-type">u32</span>{ <span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">3</span> });</span>
<span class="line" id="L523">    <span class="tok-kw">try</span> testing.expectEqualSlices(<span class="tok-type">u8</span>, list.items(.c), &amp;[_]<span class="tok-type">u8</span>{ <span class="tok-str">'a'</span>, <span class="tok-str">'b'</span>, <span class="tok-str">'c'</span> });</span>
<span class="line" id="L524"></span>
<span class="line" id="L525">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">usize</span>, <span class="tok-number">3</span>), list.items(.b).len);</span>
<span class="line" id="L526">    <span class="tok-kw">try</span> testing.expectEqualStrings(<span class="tok-str">&quot;foobar&quot;</span>, list.items(.b)[<span class="tok-number">0</span>]);</span>
<span class="line" id="L527">    <span class="tok-kw">try</span> testing.expectEqualStrings(<span class="tok-str">&quot;zigzag&quot;</span>, list.items(.b)[<span class="tok-number">1</span>]);</span>
<span class="line" id="L528">    <span class="tok-kw">try</span> testing.expectEqualStrings(<span class="tok-str">&quot;fizzbuzz&quot;</span>, list.items(.b)[<span class="tok-number">2</span>]);</span>
<span class="line" id="L529"></span>
<span class="line" id="L530">    <span class="tok-comment">// Add 6 more things to force a capacity increase.</span>
</span>
<span class="line" id="L531">    <span class="tok-kw">var</span> i: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L532">    <span class="tok-kw">while</span> (i &lt; <span class="tok-number">6</span>) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L533">        <span class="tok-kw">try</span> list.append(ally, .{</span>
<span class="line" id="L534">            .a = <span class="tok-builtin">@intCast</span>(<span class="tok-type">u32</span>, <span class="tok-number">4</span> + i),</span>
<span class="line" id="L535">            .b = <span class="tok-str">&quot;whatever&quot;</span>,</span>
<span class="line" id="L536">            .c = <span class="tok-builtin">@intCast</span>(<span class="tok-type">u8</span>, <span class="tok-str">'d'</span> + i),</span>
<span class="line" id="L537">        });</span>
<span class="line" id="L538">    }</span>
<span class="line" id="L539"></span>
<span class="line" id="L540">    <span class="tok-kw">try</span> testing.expectEqualSlices(</span>
<span class="line" id="L541">        <span class="tok-type">u32</span>,</span>
<span class="line" id="L542">        &amp;[_]<span class="tok-type">u32</span>{ <span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">4</span>, <span class="tok-number">5</span>, <span class="tok-number">6</span>, <span class="tok-number">7</span>, <span class="tok-number">8</span>, <span class="tok-number">9</span> },</span>
<span class="line" id="L543">        list.items(.a),</span>
<span class="line" id="L544">    );</span>
<span class="line" id="L545">    <span class="tok-kw">try</span> testing.expectEqualSlices(</span>
<span class="line" id="L546">        <span class="tok-type">u8</span>,</span>
<span class="line" id="L547">        &amp;[_]<span class="tok-type">u8</span>{ <span class="tok-str">'a'</span>, <span class="tok-str">'b'</span>, <span class="tok-str">'c'</span>, <span class="tok-str">'d'</span>, <span class="tok-str">'e'</span>, <span class="tok-str">'f'</span>, <span class="tok-str">'g'</span>, <span class="tok-str">'h'</span>, <span class="tok-str">'i'</span> },</span>
<span class="line" id="L548">        list.items(.c),</span>
<span class="line" id="L549">    );</span>
<span class="line" id="L550"></span>
<span class="line" id="L551">    list.shrinkAndFree(ally, <span class="tok-number">3</span>);</span>
<span class="line" id="L552"></span>
<span class="line" id="L553">    <span class="tok-kw">try</span> testing.expectEqualSlices(<span class="tok-type">u32</span>, list.items(.a), &amp;[_]<span class="tok-type">u32</span>{ <span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">3</span> });</span>
<span class="line" id="L554">    <span class="tok-kw">try</span> testing.expectEqualSlices(<span class="tok-type">u8</span>, list.items(.c), &amp;[_]<span class="tok-type">u8</span>{ <span class="tok-str">'a'</span>, <span class="tok-str">'b'</span>, <span class="tok-str">'c'</span> });</span>
<span class="line" id="L555"></span>
<span class="line" id="L556">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">usize</span>, <span class="tok-number">3</span>), list.items(.b).len);</span>
<span class="line" id="L557">    <span class="tok-kw">try</span> testing.expectEqualStrings(<span class="tok-str">&quot;foobar&quot;</span>, list.items(.b)[<span class="tok-number">0</span>]);</span>
<span class="line" id="L558">    <span class="tok-kw">try</span> testing.expectEqualStrings(<span class="tok-str">&quot;zigzag&quot;</span>, list.items(.b)[<span class="tok-number">1</span>]);</span>
<span class="line" id="L559">    <span class="tok-kw">try</span> testing.expectEqualStrings(<span class="tok-str">&quot;fizzbuzz&quot;</span>, list.items(.b)[<span class="tok-number">2</span>]);</span>
<span class="line" id="L560"></span>
<span class="line" id="L561">    list.set(<span class="tok-kw">try</span> list.addOne(ally), .{</span>
<span class="line" id="L562">        .a = <span class="tok-number">4</span>,</span>
<span class="line" id="L563">        .b = <span class="tok-str">&quot;xnopyt&quot;</span>,</span>
<span class="line" id="L564">        .c = <span class="tok-str">'d'</span>,</span>
<span class="line" id="L565">    });</span>
<span class="line" id="L566">    <span class="tok-kw">try</span> testing.expectEqualStrings(<span class="tok-str">&quot;xnopyt&quot;</span>, list.pop().b);</span>
<span class="line" id="L567">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(?<span class="tok-type">u8</span>, <span class="tok-str">'c'</span>), <span class="tok-kw">if</span> (list.popOrNull()) |elem| elem.c <span class="tok-kw">else</span> <span class="tok-null">null</span>);</span>
<span class="line" id="L568">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">2</span>), list.pop().a);</span>
<span class="line" id="L569">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">u8</span>, <span class="tok-str">'a'</span>), list.pop().c);</span>
<span class="line" id="L570">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(?Foo, <span class="tok-null">null</span>), list.popOrNull());</span>
<span class="line" id="L571">}</span>
<span class="line" id="L572"></span>
<span class="line" id="L573"><span class="tok-comment">// This was observed to fail on aarch64 with LLVM 11, when the capacityInBytes</span>
</span>
<span class="line" id="L574"><span class="tok-comment">// function used the @reduce code path.</span>
</span>
<span class="line" id="L575"><span class="tok-kw">test</span> <span class="tok-str">&quot;regression test for @reduce bug&quot;</span> {</span>
<span class="line" id="L576">    <span class="tok-kw">const</span> ally = testing.allocator;</span>
<span class="line" id="L577">    <span class="tok-kw">var</span> list = MultiArrayList(<span class="tok-kw">struct</span> {</span>
<span class="line" id="L578">        tag: std.zig.Token.Tag,</span>
<span class="line" id="L579">        start: <span class="tok-type">u32</span>,</span>
<span class="line" id="L580">    }){};</span>
<span class="line" id="L581">    <span class="tok-kw">defer</span> list.deinit(ally);</span>
<span class="line" id="L582"></span>
<span class="line" id="L583">    <span class="tok-kw">try</span> list.ensureTotalCapacity(ally, <span class="tok-number">20</span>);</span>
<span class="line" id="L584"></span>
<span class="line" id="L585">    <span class="tok-kw">try</span> list.append(ally, .{ .tag = .keyword_const, .start = <span class="tok-number">0</span> });</span>
<span class="line" id="L586">    <span class="tok-kw">try</span> list.append(ally, .{ .tag = .identifier, .start = <span class="tok-number">6</span> });</span>
<span class="line" id="L587">    <span class="tok-kw">try</span> list.append(ally, .{ .tag = .equal, .start = <span class="tok-number">10</span> });</span>
<span class="line" id="L588">    <span class="tok-kw">try</span> list.append(ally, .{ .tag = .builtin, .start = <span class="tok-number">12</span> });</span>
<span class="line" id="L589">    <span class="tok-kw">try</span> list.append(ally, .{ .tag = .l_paren, .start = <span class="tok-number">19</span> });</span>
<span class="line" id="L590">    <span class="tok-kw">try</span> list.append(ally, .{ .tag = .string_literal, .start = <span class="tok-number">20</span> });</span>
<span class="line" id="L591">    <span class="tok-kw">try</span> list.append(ally, .{ .tag = .r_paren, .start = <span class="tok-number">25</span> });</span>
<span class="line" id="L592">    <span class="tok-kw">try</span> list.append(ally, .{ .tag = .semicolon, .start = <span class="tok-number">26</span> });</span>
<span class="line" id="L593">    <span class="tok-kw">try</span> list.append(ally, .{ .tag = .keyword_pub, .start = <span class="tok-number">29</span> });</span>
<span class="line" id="L594">    <span class="tok-kw">try</span> list.append(ally, .{ .tag = .keyword_fn, .start = <span class="tok-number">33</span> });</span>
<span class="line" id="L595">    <span class="tok-kw">try</span> list.append(ally, .{ .tag = .identifier, .start = <span class="tok-number">36</span> });</span>
<span class="line" id="L596">    <span class="tok-kw">try</span> list.append(ally, .{ .tag = .l_paren, .start = <span class="tok-number">40</span> });</span>
<span class="line" id="L597">    <span class="tok-kw">try</span> list.append(ally, .{ .tag = .r_paren, .start = <span class="tok-number">41</span> });</span>
<span class="line" id="L598">    <span class="tok-kw">try</span> list.append(ally, .{ .tag = .identifier, .start = <span class="tok-number">43</span> });</span>
<span class="line" id="L599">    <span class="tok-kw">try</span> list.append(ally, .{ .tag = .bang, .start = <span class="tok-number">51</span> });</span>
<span class="line" id="L600">    <span class="tok-kw">try</span> list.append(ally, .{ .tag = .identifier, .start = <span class="tok-number">52</span> });</span>
<span class="line" id="L601">    <span class="tok-kw">try</span> list.append(ally, .{ .tag = .l_brace, .start = <span class="tok-number">57</span> });</span>
<span class="line" id="L602">    <span class="tok-kw">try</span> list.append(ally, .{ .tag = .identifier, .start = <span class="tok-number">63</span> });</span>
<span class="line" id="L603">    <span class="tok-kw">try</span> list.append(ally, .{ .tag = .period, .start = <span class="tok-number">66</span> });</span>
<span class="line" id="L604">    <span class="tok-kw">try</span> list.append(ally, .{ .tag = .identifier, .start = <span class="tok-number">67</span> });</span>
<span class="line" id="L605">    <span class="tok-kw">try</span> list.append(ally, .{ .tag = .period, .start = <span class="tok-number">70</span> });</span>
<span class="line" id="L606">    <span class="tok-kw">try</span> list.append(ally, .{ .tag = .identifier, .start = <span class="tok-number">71</span> });</span>
<span class="line" id="L607">    <span class="tok-kw">try</span> list.append(ally, .{ .tag = .l_paren, .start = <span class="tok-number">75</span> });</span>
<span class="line" id="L608">    <span class="tok-kw">try</span> list.append(ally, .{ .tag = .string_literal, .start = <span class="tok-number">76</span> });</span>
<span class="line" id="L609">    <span class="tok-kw">try</span> list.append(ally, .{ .tag = .comma, .start = <span class="tok-number">113</span> });</span>
<span class="line" id="L610">    <span class="tok-kw">try</span> list.append(ally, .{ .tag = .period, .start = <span class="tok-number">115</span> });</span>
<span class="line" id="L611">    <span class="tok-kw">try</span> list.append(ally, .{ .tag = .l_brace, .start = <span class="tok-number">116</span> });</span>
<span class="line" id="L612">    <span class="tok-kw">try</span> list.append(ally, .{ .tag = .r_brace, .start = <span class="tok-number">117</span> });</span>
<span class="line" id="L613">    <span class="tok-kw">try</span> list.append(ally, .{ .tag = .r_paren, .start = <span class="tok-number">118</span> });</span>
<span class="line" id="L614">    <span class="tok-kw">try</span> list.append(ally, .{ .tag = .semicolon, .start = <span class="tok-number">119</span> });</span>
<span class="line" id="L615">    <span class="tok-kw">try</span> list.append(ally, .{ .tag = .r_brace, .start = <span class="tok-number">121</span> });</span>
<span class="line" id="L616">    <span class="tok-kw">try</span> list.append(ally, .{ .tag = .eof, .start = <span class="tok-number">123</span> });</span>
<span class="line" id="L617"></span>
<span class="line" id="L618">    <span class="tok-kw">const</span> tags = list.items(.tag);</span>
<span class="line" id="L619">    <span class="tok-kw">try</span> testing.expectEqual(tags[<span class="tok-number">1</span>], .identifier);</span>
<span class="line" id="L620">    <span class="tok-kw">try</span> testing.expectEqual(tags[<span class="tok-number">2</span>], .equal);</span>
<span class="line" id="L621">    <span class="tok-kw">try</span> testing.expectEqual(tags[<span class="tok-number">3</span>], .builtin);</span>
<span class="line" id="L622">    <span class="tok-kw">try</span> testing.expectEqual(tags[<span class="tok-number">4</span>], .l_paren);</span>
<span class="line" id="L623">    <span class="tok-kw">try</span> testing.expectEqual(tags[<span class="tok-number">5</span>], .string_literal);</span>
<span class="line" id="L624">    <span class="tok-kw">try</span> testing.expectEqual(tags[<span class="tok-number">6</span>], .r_paren);</span>
<span class="line" id="L625">    <span class="tok-kw">try</span> testing.expectEqual(tags[<span class="tok-number">7</span>], .semicolon);</span>
<span class="line" id="L626">    <span class="tok-kw">try</span> testing.expectEqual(tags[<span class="tok-number">8</span>], .keyword_pub);</span>
<span class="line" id="L627">    <span class="tok-kw">try</span> testing.expectEqual(tags[<span class="tok-number">9</span>], .keyword_fn);</span>
<span class="line" id="L628">    <span class="tok-kw">try</span> testing.expectEqual(tags[<span class="tok-number">10</span>], .identifier);</span>
<span class="line" id="L629">    <span class="tok-kw">try</span> testing.expectEqual(tags[<span class="tok-number">11</span>], .l_paren);</span>
<span class="line" id="L630">    <span class="tok-kw">try</span> testing.expectEqual(tags[<span class="tok-number">12</span>], .r_paren);</span>
<span class="line" id="L631">    <span class="tok-kw">try</span> testing.expectEqual(tags[<span class="tok-number">13</span>], .identifier);</span>
<span class="line" id="L632">    <span class="tok-kw">try</span> testing.expectEqual(tags[<span class="tok-number">14</span>], .bang);</span>
<span class="line" id="L633">    <span class="tok-kw">try</span> testing.expectEqual(tags[<span class="tok-number">15</span>], .identifier);</span>
<span class="line" id="L634">    <span class="tok-kw">try</span> testing.expectEqual(tags[<span class="tok-number">16</span>], .l_brace);</span>
<span class="line" id="L635">    <span class="tok-kw">try</span> testing.expectEqual(tags[<span class="tok-number">17</span>], .identifier);</span>
<span class="line" id="L636">    <span class="tok-kw">try</span> testing.expectEqual(tags[<span class="tok-number">18</span>], .period);</span>
<span class="line" id="L637">    <span class="tok-kw">try</span> testing.expectEqual(tags[<span class="tok-number">19</span>], .identifier);</span>
<span class="line" id="L638">    <span class="tok-kw">try</span> testing.expectEqual(tags[<span class="tok-number">20</span>], .period);</span>
<span class="line" id="L639">    <span class="tok-kw">try</span> testing.expectEqual(tags[<span class="tok-number">21</span>], .identifier);</span>
<span class="line" id="L640">    <span class="tok-kw">try</span> testing.expectEqual(tags[<span class="tok-number">22</span>], .l_paren);</span>
<span class="line" id="L641">    <span class="tok-kw">try</span> testing.expectEqual(tags[<span class="tok-number">23</span>], .string_literal);</span>
<span class="line" id="L642">    <span class="tok-kw">try</span> testing.expectEqual(tags[<span class="tok-number">24</span>], .comma);</span>
<span class="line" id="L643">    <span class="tok-kw">try</span> testing.expectEqual(tags[<span class="tok-number">25</span>], .period);</span>
<span class="line" id="L644">    <span class="tok-kw">try</span> testing.expectEqual(tags[<span class="tok-number">26</span>], .l_brace);</span>
<span class="line" id="L645">    <span class="tok-kw">try</span> testing.expectEqual(tags[<span class="tok-number">27</span>], .r_brace);</span>
<span class="line" id="L646">    <span class="tok-kw">try</span> testing.expectEqual(tags[<span class="tok-number">28</span>], .r_paren);</span>
<span class="line" id="L647">    <span class="tok-kw">try</span> testing.expectEqual(tags[<span class="tok-number">29</span>], .semicolon);</span>
<span class="line" id="L648">    <span class="tok-kw">try</span> testing.expectEqual(tags[<span class="tok-number">30</span>], .r_brace);</span>
<span class="line" id="L649">    <span class="tok-kw">try</span> testing.expectEqual(tags[<span class="tok-number">31</span>], .eof);</span>
<span class="line" id="L650">}</span>
<span class="line" id="L651"></span>
<span class="line" id="L652"><span class="tok-kw">test</span> <span class="tok-str">&quot;ensure capacity on empty list&quot;</span> {</span>
<span class="line" id="L653">    <span class="tok-kw">const</span> ally = testing.allocator;</span>
<span class="line" id="L654"></span>
<span class="line" id="L655">    <span class="tok-kw">const</span> Foo = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L656">        a: <span class="tok-type">u32</span>,</span>
<span class="line" id="L657">        b: <span class="tok-type">u8</span>,</span>
<span class="line" id="L658">    };</span>
<span class="line" id="L659"></span>
<span class="line" id="L660">    <span class="tok-kw">var</span> list = MultiArrayList(Foo){};</span>
<span class="line" id="L661">    <span class="tok-kw">defer</span> list.deinit(ally);</span>
<span class="line" id="L662"></span>
<span class="line" id="L663">    <span class="tok-kw">try</span> list.ensureTotalCapacity(ally, <span class="tok-number">2</span>);</span>
<span class="line" id="L664">    list.appendAssumeCapacity(.{ .a = <span class="tok-number">1</span>, .b = <span class="tok-number">2</span> });</span>
<span class="line" id="L665">    list.appendAssumeCapacity(.{ .a = <span class="tok-number">3</span>, .b = <span class="tok-number">4</span> });</span>
<span class="line" id="L666"></span>
<span class="line" id="L667">    <span class="tok-kw">try</span> testing.expectEqualSlices(<span class="tok-type">u32</span>, &amp;[_]<span class="tok-type">u32</span>{ <span class="tok-number">1</span>, <span class="tok-number">3</span> }, list.items(.a));</span>
<span class="line" id="L668">    <span class="tok-kw">try</span> testing.expectEqualSlices(<span class="tok-type">u8</span>, &amp;[_]<span class="tok-type">u8</span>{ <span class="tok-number">2</span>, <span class="tok-number">4</span> }, list.items(.b));</span>
<span class="line" id="L669"></span>
<span class="line" id="L670">    list.len = <span class="tok-number">0</span>;</span>
<span class="line" id="L671">    list.appendAssumeCapacity(.{ .a = <span class="tok-number">5</span>, .b = <span class="tok-number">6</span> });</span>
<span class="line" id="L672">    list.appendAssumeCapacity(.{ .a = <span class="tok-number">7</span>, .b = <span class="tok-number">8</span> });</span>
<span class="line" id="L673"></span>
<span class="line" id="L674">    <span class="tok-kw">try</span> testing.expectEqualSlices(<span class="tok-type">u32</span>, &amp;[_]<span class="tok-type">u32</span>{ <span class="tok-number">5</span>, <span class="tok-number">7</span> }, list.items(.a));</span>
<span class="line" id="L675">    <span class="tok-kw">try</span> testing.expectEqualSlices(<span class="tok-type">u8</span>, &amp;[_]<span class="tok-type">u8</span>{ <span class="tok-number">6</span>, <span class="tok-number">8</span> }, list.items(.b));</span>
<span class="line" id="L676"></span>
<span class="line" id="L677">    list.len = <span class="tok-number">0</span>;</span>
<span class="line" id="L678">    <span class="tok-kw">try</span> list.ensureTotalCapacity(ally, <span class="tok-number">16</span>);</span>
<span class="line" id="L679"></span>
<span class="line" id="L680">    list.appendAssumeCapacity(.{ .a = <span class="tok-number">9</span>, .b = <span class="tok-number">10</span> });</span>
<span class="line" id="L681">    list.appendAssumeCapacity(.{ .a = <span class="tok-number">11</span>, .b = <span class="tok-number">12</span> });</span>
<span class="line" id="L682"></span>
<span class="line" id="L683">    <span class="tok-kw">try</span> testing.expectEqualSlices(<span class="tok-type">u32</span>, &amp;[_]<span class="tok-type">u32</span>{ <span class="tok-number">9</span>, <span class="tok-number">11</span> }, list.items(.a));</span>
<span class="line" id="L684">    <span class="tok-kw">try</span> testing.expectEqualSlices(<span class="tok-type">u8</span>, &amp;[_]<span class="tok-type">u8</span>{ <span class="tok-number">10</span>, <span class="tok-number">12</span> }, list.items(.b));</span>
<span class="line" id="L685">}</span>
<span class="line" id="L686"></span>
<span class="line" id="L687"><span class="tok-kw">test</span> <span class="tok-str">&quot;insert elements&quot;</span> {</span>
<span class="line" id="L688">    <span class="tok-kw">const</span> ally = testing.allocator;</span>
<span class="line" id="L689"></span>
<span class="line" id="L690">    <span class="tok-kw">const</span> Foo = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L691">        a: <span class="tok-type">u8</span>,</span>
<span class="line" id="L692">        b: <span class="tok-type">u32</span>,</span>
<span class="line" id="L693">    };</span>
<span class="line" id="L694"></span>
<span class="line" id="L695">    <span class="tok-kw">var</span> list = MultiArrayList(Foo){};</span>
<span class="line" id="L696">    <span class="tok-kw">defer</span> list.deinit(ally);</span>
<span class="line" id="L697"></span>
<span class="line" id="L698">    <span class="tok-kw">try</span> list.insert(ally, <span class="tok-number">0</span>, .{ .a = <span class="tok-number">1</span>, .b = <span class="tok-number">2</span> });</span>
<span class="line" id="L699">    <span class="tok-kw">try</span> list.ensureUnusedCapacity(ally, <span class="tok-number">1</span>);</span>
<span class="line" id="L700">    list.insertAssumeCapacity(<span class="tok-number">1</span>, .{ .a = <span class="tok-number">2</span>, .b = <span class="tok-number">3</span> });</span>
<span class="line" id="L701"></span>
<span class="line" id="L702">    <span class="tok-kw">try</span> testing.expectEqualSlices(<span class="tok-type">u8</span>, &amp;[_]<span class="tok-type">u8</span>{ <span class="tok-number">1</span>, <span class="tok-number">2</span> }, list.items(.a));</span>
<span class="line" id="L703">    <span class="tok-kw">try</span> testing.expectEqualSlices(<span class="tok-type">u32</span>, &amp;[_]<span class="tok-type">u32</span>{ <span class="tok-number">2</span>, <span class="tok-number">3</span> }, list.items(.b));</span>
<span class="line" id="L704">}</span>
<span class="line" id="L705"></span>
</code></pre></body>
</html>