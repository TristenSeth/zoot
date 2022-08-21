<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">    <title>mem/Allocator.zig - source view</title>
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
<pre><code><span class="line" id="L1"><span class="tok-comment">//! The standard memory allocation interface.</span></span>
<span class="line" id="L2"></span>
<span class="line" id="L3"><span class="tok-kw">const</span> std = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;../std.zig&quot;</span>);</span>
<span class="line" id="L4"><span class="tok-kw">const</span> assert = std.debug.assert;</span>
<span class="line" id="L5"><span class="tok-kw">const</span> math = std.math;</span>
<span class="line" id="L6"><span class="tok-kw">const</span> mem = std.mem;</span>
<span class="line" id="L7"><span class="tok-kw">const</span> Allocator = <span class="tok-builtin">@This</span>();</span>
<span class="line" id="L8"><span class="tok-kw">const</span> builtin = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;builtin&quot;</span>);</span>
<span class="line" id="L9"></span>
<span class="line" id="L10"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> Error = <span class="tok-kw">error</span>{OutOfMemory};</span>
<span class="line" id="L11"></span>
<span class="line" id="L12"><span class="tok-comment">// The type erased pointer to the allocator implementation</span>
</span>
<span class="line" id="L13">ptr: *<span class="tok-type">anyopaque</span>,</span>
<span class="line" id="L14">vtable: *<span class="tok-kw">const</span> VTable,</span>
<span class="line" id="L15"></span>
<span class="line" id="L16"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> VTable = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L17">    <span class="tok-comment">/// Attempt to allocate at least `len` bytes aligned to `ptr_align`.</span></span>
<span class="line" id="L18">    <span class="tok-comment">///</span></span>
<span class="line" id="L19">    <span class="tok-comment">/// If `len_align` is `0`, then the length returned MUST be exactly `len` bytes,</span></span>
<span class="line" id="L20">    <span class="tok-comment">/// otherwise, the length must be aligned to `len_align`.</span></span>
<span class="line" id="L21">    <span class="tok-comment">///</span></span>
<span class="line" id="L22">    <span class="tok-comment">/// `len` must be greater than or equal to `len_align` and must be aligned by `len_align`.</span></span>
<span class="line" id="L23">    <span class="tok-comment">///</span></span>
<span class="line" id="L24">    <span class="tok-comment">/// `ret_addr` is optionally provided as the first return address of the allocation call stack.</span></span>
<span class="line" id="L25">    <span class="tok-comment">/// If the value is `0` it means no return address has been provided.</span></span>
<span class="line" id="L26">    alloc: <span class="tok-kw">switch</span> (builtin.zig_backend) {</span>
<span class="line" id="L27">        .stage1 =&gt; allocProto, <span class="tok-comment">// temporary workaround until we replace stage1 with stage2</span>
</span>
<span class="line" id="L28">        <span class="tok-kw">else</span> =&gt; *<span class="tok-kw">const</span> allocProto,</span>
<span class="line" id="L29">    },</span>
<span class="line" id="L30"></span>
<span class="line" id="L31">    <span class="tok-comment">/// Attempt to expand or shrink memory in place. `buf.len` must equal the most recent</span></span>
<span class="line" id="L32">    <span class="tok-comment">/// length returned by `alloc` or `resize`. `buf_align` must equal the same value</span></span>
<span class="line" id="L33">    <span class="tok-comment">/// that was passed as the `ptr_align` parameter to the original `alloc` call.</span></span>
<span class="line" id="L34">    <span class="tok-comment">///</span></span>
<span class="line" id="L35">    <span class="tok-comment">/// `null` can only be returned if `new_len` is greater than `buf.len`.</span></span>
<span class="line" id="L36">    <span class="tok-comment">/// If `buf` cannot be expanded to accomodate `new_len`, then the allocation MUST be</span></span>
<span class="line" id="L37">    <span class="tok-comment">/// unmodified and `null` MUST be returned.</span></span>
<span class="line" id="L38">    <span class="tok-comment">///</span></span>
<span class="line" id="L39">    <span class="tok-comment">/// If `len_align` is `0`, then the length returned MUST be exactly `len` bytes,</span></span>
<span class="line" id="L40">    <span class="tok-comment">/// otherwise, the length must be aligned to `len_align`. Note that `len_align` does *not*</span></span>
<span class="line" id="L41">    <span class="tok-comment">/// provide a way to modify the alignment of a pointer. Rather it provides an API for</span></span>
<span class="line" id="L42">    <span class="tok-comment">/// accepting more bytes of memory from the allocator than requested.</span></span>
<span class="line" id="L43">    <span class="tok-comment">///</span></span>
<span class="line" id="L44">    <span class="tok-comment">/// `new_len` must be greater than zero, greater than or equal to `len_align` and must be aligned by `len_align`.</span></span>
<span class="line" id="L45">    <span class="tok-comment">///</span></span>
<span class="line" id="L46">    <span class="tok-comment">/// `ret_addr` is optionally provided as the first return address of the allocation call stack.</span></span>
<span class="line" id="L47">    <span class="tok-comment">/// If the value is `0` it means no return address has been provided.</span></span>
<span class="line" id="L48">    resize: <span class="tok-kw">switch</span> (builtin.zig_backend) {</span>
<span class="line" id="L49">        .stage1 =&gt; resizeProto, <span class="tok-comment">// temporary workaround until we replace stage1 with stage2</span>
</span>
<span class="line" id="L50">        <span class="tok-kw">else</span> =&gt; *<span class="tok-kw">const</span> resizeProto,</span>
<span class="line" id="L51">    },</span>
<span class="line" id="L52"></span>
<span class="line" id="L53">    <span class="tok-comment">/// Free and invalidate a buffer. `buf.len` must equal the most recent length returned by `alloc` or `resize`.</span></span>
<span class="line" id="L54">    <span class="tok-comment">/// `buf_align` must equal the same value that was passed as the `ptr_align` parameter to the original `alloc` call.</span></span>
<span class="line" id="L55">    <span class="tok-comment">///</span></span>
<span class="line" id="L56">    <span class="tok-comment">/// `ret_addr` is optionally provided as the first return address of the allocation call stack.</span></span>
<span class="line" id="L57">    <span class="tok-comment">/// If the value is `0` it means no return address has been provided.</span></span>
<span class="line" id="L58">    free: <span class="tok-kw">switch</span> (builtin.zig_backend) {</span>
<span class="line" id="L59">        .stage1 =&gt; freeProto, <span class="tok-comment">// temporary workaround until we replace stage1 with stage2</span>
</span>
<span class="line" id="L60">        <span class="tok-kw">else</span> =&gt; *<span class="tok-kw">const</span> freeProto,</span>
<span class="line" id="L61">    },</span>
<span class="line" id="L62">};</span>
<span class="line" id="L63"></span>
<span class="line" id="L64"><span class="tok-kw">const</span> allocProto = <span class="tok-kw">fn</span> (ptr: *<span class="tok-type">anyopaque</span>, len: <span class="tok-type">usize</span>, ptr_align: <span class="tok-type">u29</span>, len_align: <span class="tok-type">u29</span>, ret_addr: <span class="tok-type">usize</span>) Error![]<span class="tok-type">u8</span>;</span>
<span class="line" id="L65"><span class="tok-kw">const</span> resizeProto = <span class="tok-kw">fn</span> (ptr: *<span class="tok-type">anyopaque</span>, buf: []<span class="tok-type">u8</span>, buf_align: <span class="tok-type">u29</span>, new_len: <span class="tok-type">usize</span>, len_align: <span class="tok-type">u29</span>, ret_addr: <span class="tok-type">usize</span>) ?<span class="tok-type">usize</span>;</span>
<span class="line" id="L66"><span class="tok-kw">const</span> freeProto = <span class="tok-kw">fn</span> (ptr: *<span class="tok-type">anyopaque</span>, buf: []<span class="tok-type">u8</span>, buf_align: <span class="tok-type">u29</span>, ret_addr: <span class="tok-type">usize</span>) <span class="tok-type">void</span>;</span>
<span class="line" id="L67"></span>
<span class="line" id="L68"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">init</span>(</span>
<span class="line" id="L69">    pointer: <span class="tok-kw">anytype</span>,</span>
<span class="line" id="L70">    <span class="tok-kw">comptime</span> allocFn: <span class="tok-kw">fn</span> (ptr: <span class="tok-builtin">@TypeOf</span>(pointer), len: <span class="tok-type">usize</span>, ptr_align: <span class="tok-type">u29</span>, len_align: <span class="tok-type">u29</span>, ret_addr: <span class="tok-type">usize</span>) Error![]<span class="tok-type">u8</span>,</span>
<span class="line" id="L71">    <span class="tok-kw">comptime</span> resizeFn: <span class="tok-kw">fn</span> (ptr: <span class="tok-builtin">@TypeOf</span>(pointer), buf: []<span class="tok-type">u8</span>, buf_align: <span class="tok-type">u29</span>, new_len: <span class="tok-type">usize</span>, len_align: <span class="tok-type">u29</span>, ret_addr: <span class="tok-type">usize</span>) ?<span class="tok-type">usize</span>,</span>
<span class="line" id="L72">    <span class="tok-kw">comptime</span> freeFn: <span class="tok-kw">fn</span> (ptr: <span class="tok-builtin">@TypeOf</span>(pointer), buf: []<span class="tok-type">u8</span>, buf_align: <span class="tok-type">u29</span>, ret_addr: <span class="tok-type">usize</span>) <span class="tok-type">void</span>,</span>
<span class="line" id="L73">) Allocator {</span>
<span class="line" id="L74">    <span class="tok-kw">const</span> Ptr = <span class="tok-builtin">@TypeOf</span>(pointer);</span>
<span class="line" id="L75">    <span class="tok-kw">const</span> ptr_info = <span class="tok-builtin">@typeInfo</span>(Ptr);</span>
<span class="line" id="L76"></span>
<span class="line" id="L77">    assert(ptr_info == .Pointer); <span class="tok-comment">// Must be a pointer</span>
</span>
<span class="line" id="L78">    assert(ptr_info.Pointer.size == .One); <span class="tok-comment">// Must be a single-item pointer</span>
</span>
<span class="line" id="L79"></span>
<span class="line" id="L80">    <span class="tok-kw">const</span> alignment = ptr_info.Pointer.alignment;</span>
<span class="line" id="L81"></span>
<span class="line" id="L82">    <span class="tok-kw">const</span> gen = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L83">        <span class="tok-kw">fn</span> <span class="tok-fn">allocImpl</span>(ptr: *<span class="tok-type">anyopaque</span>, len: <span class="tok-type">usize</span>, ptr_align: <span class="tok-type">u29</span>, len_align: <span class="tok-type">u29</span>, ret_addr: <span class="tok-type">usize</span>) Error![]<span class="tok-type">u8</span> {</span>
<span class="line" id="L84">            <span class="tok-kw">const</span> self = <span class="tok-builtin">@ptrCast</span>(Ptr, <span class="tok-builtin">@alignCast</span>(alignment, ptr));</span>
<span class="line" id="L85">            <span class="tok-kw">return</span> <span class="tok-builtin">@call</span>(.{ .modifier = .always_inline }, allocFn, .{ self, len, ptr_align, len_align, ret_addr });</span>
<span class="line" id="L86">        }</span>
<span class="line" id="L87">        <span class="tok-kw">fn</span> <span class="tok-fn">resizeImpl</span>(ptr: *<span class="tok-type">anyopaque</span>, buf: []<span class="tok-type">u8</span>, buf_align: <span class="tok-type">u29</span>, new_len: <span class="tok-type">usize</span>, len_align: <span class="tok-type">u29</span>, ret_addr: <span class="tok-type">usize</span>) ?<span class="tok-type">usize</span> {</span>
<span class="line" id="L88">            assert(new_len != <span class="tok-number">0</span>);</span>
<span class="line" id="L89">            <span class="tok-kw">const</span> self = <span class="tok-builtin">@ptrCast</span>(Ptr, <span class="tok-builtin">@alignCast</span>(alignment, ptr));</span>
<span class="line" id="L90">            <span class="tok-kw">return</span> <span class="tok-builtin">@call</span>(.{ .modifier = .always_inline }, resizeFn, .{ self, buf, buf_align, new_len, len_align, ret_addr });</span>
<span class="line" id="L91">        }</span>
<span class="line" id="L92">        <span class="tok-kw">fn</span> <span class="tok-fn">freeImpl</span>(ptr: *<span class="tok-type">anyopaque</span>, buf: []<span class="tok-type">u8</span>, buf_align: <span class="tok-type">u29</span>, ret_addr: <span class="tok-type">usize</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L93">            <span class="tok-kw">const</span> self = <span class="tok-builtin">@ptrCast</span>(Ptr, <span class="tok-builtin">@alignCast</span>(alignment, ptr));</span>
<span class="line" id="L94">            <span class="tok-builtin">@call</span>(.{ .modifier = .always_inline }, freeFn, .{ self, buf, buf_align, ret_addr });</span>
<span class="line" id="L95">        }</span>
<span class="line" id="L96"></span>
<span class="line" id="L97">        <span class="tok-kw">const</span> vtable = VTable{</span>
<span class="line" id="L98">            .alloc = allocImpl,</span>
<span class="line" id="L99">            .resize = resizeImpl,</span>
<span class="line" id="L100">            .free = freeImpl,</span>
<span class="line" id="L101">        };</span>
<span class="line" id="L102">    };</span>
<span class="line" id="L103"></span>
<span class="line" id="L104">    <span class="tok-kw">return</span> .{</span>
<span class="line" id="L105">        .ptr = pointer,</span>
<span class="line" id="L106">        .vtable = &amp;gen.vtable,</span>
<span class="line" id="L107">    };</span>
<span class="line" id="L108">}</span>
<span class="line" id="L109"></span>
<span class="line" id="L110"><span class="tok-comment">/// Set resizeFn to `NoResize(AllocatorType).noResize` if in-place resize is not supported.</span></span>
<span class="line" id="L111"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">NoResize</span>(<span class="tok-kw">comptime</span> AllocatorType: <span class="tok-type">type</span>) <span class="tok-type">type</span> {</span>
<span class="line" id="L112">    <span class="tok-kw">return</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L113">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">noResize</span>(</span>
<span class="line" id="L114">            self: *AllocatorType,</span>
<span class="line" id="L115">            buf: []<span class="tok-type">u8</span>,</span>
<span class="line" id="L116">            buf_align: <span class="tok-type">u29</span>,</span>
<span class="line" id="L117">            new_len: <span class="tok-type">usize</span>,</span>
<span class="line" id="L118">            len_align: <span class="tok-type">u29</span>,</span>
<span class="line" id="L119">            ret_addr: <span class="tok-type">usize</span>,</span>
<span class="line" id="L120">        ) ?<span class="tok-type">usize</span> {</span>
<span class="line" id="L121">            _ = self;</span>
<span class="line" id="L122">            _ = buf_align;</span>
<span class="line" id="L123">            _ = len_align;</span>
<span class="line" id="L124">            _ = ret_addr;</span>
<span class="line" id="L125">            <span class="tok-kw">return</span> <span class="tok-kw">if</span> (new_len &gt; buf.len) <span class="tok-null">null</span> <span class="tok-kw">else</span> new_len;</span>
<span class="line" id="L126">        }</span>
<span class="line" id="L127">    };</span>
<span class="line" id="L128">}</span>
<span class="line" id="L129"></span>
<span class="line" id="L130"><span class="tok-comment">/// Set freeFn to `NoOpFree(AllocatorType).noOpFree` if free is a no-op.</span></span>
<span class="line" id="L131"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">NoOpFree</span>(<span class="tok-kw">comptime</span> AllocatorType: <span class="tok-type">type</span>) <span class="tok-type">type</span> {</span>
<span class="line" id="L132">    <span class="tok-kw">return</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L133">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">noOpFree</span>(</span>
<span class="line" id="L134">            self: *AllocatorType,</span>
<span class="line" id="L135">            buf: []<span class="tok-type">u8</span>,</span>
<span class="line" id="L136">            buf_align: <span class="tok-type">u29</span>,</span>
<span class="line" id="L137">            ret_addr: <span class="tok-type">usize</span>,</span>
<span class="line" id="L138">        ) <span class="tok-type">void</span> {</span>
<span class="line" id="L139">            _ = self;</span>
<span class="line" id="L140">            _ = buf;</span>
<span class="line" id="L141">            _ = buf_align;</span>
<span class="line" id="L142">            _ = ret_addr;</span>
<span class="line" id="L143">        }</span>
<span class="line" id="L144">    };</span>
<span class="line" id="L145">}</span>
<span class="line" id="L146"></span>
<span class="line" id="L147"><span class="tok-comment">/// Set freeFn to `PanicFree(AllocatorType).panicFree` if free is not a supported operation.</span></span>
<span class="line" id="L148"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">PanicFree</span>(<span class="tok-kw">comptime</span> AllocatorType: <span class="tok-type">type</span>) <span class="tok-type">type</span> {</span>
<span class="line" id="L149">    <span class="tok-kw">return</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L150">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">panicFree</span>(</span>
<span class="line" id="L151">            self: *AllocatorType,</span>
<span class="line" id="L152">            buf: []<span class="tok-type">u8</span>,</span>
<span class="line" id="L153">            buf_align: <span class="tok-type">u29</span>,</span>
<span class="line" id="L154">            ret_addr: <span class="tok-type">usize</span>,</span>
<span class="line" id="L155">        ) <span class="tok-type">void</span> {</span>
<span class="line" id="L156">            _ = self;</span>
<span class="line" id="L157">            _ = buf;</span>
<span class="line" id="L158">            _ = buf_align;</span>
<span class="line" id="L159">            _ = ret_addr;</span>
<span class="line" id="L160">            <span class="tok-builtin">@panic</span>(<span class="tok-str">&quot;free is not a supported operation for the allocator: &quot;</span> ++ <span class="tok-builtin">@typeName</span>(AllocatorType));</span>
<span class="line" id="L161">        }</span>
<span class="line" id="L162">    };</span>
<span class="line" id="L163">}</span>
<span class="line" id="L164"></span>
<span class="line" id="L165"><span class="tok-comment">/// This function is not intended to be called except from within the implementation of an Allocator</span></span>
<span class="line" id="L166"><span class="tok-kw">pub</span> <span class="tok-kw">inline</span> <span class="tok-kw">fn</span> <span class="tok-fn">rawAlloc</span>(self: Allocator, len: <span class="tok-type">usize</span>, ptr_align: <span class="tok-type">u29</span>, len_align: <span class="tok-type">u29</span>, ret_addr: <span class="tok-type">usize</span>) Error![]<span class="tok-type">u8</span> {</span>
<span class="line" id="L167">    <span class="tok-kw">return</span> self.vtable.alloc(self.ptr, len, ptr_align, len_align, ret_addr);</span>
<span class="line" id="L168">}</span>
<span class="line" id="L169"></span>
<span class="line" id="L170"><span class="tok-comment">/// This function is not intended to be called except from within the implementation of an Allocator</span></span>
<span class="line" id="L171"><span class="tok-kw">pub</span> <span class="tok-kw">inline</span> <span class="tok-kw">fn</span> <span class="tok-fn">rawResize</span>(self: Allocator, buf: []<span class="tok-type">u8</span>, buf_align: <span class="tok-type">u29</span>, new_len: <span class="tok-type">usize</span>, len_align: <span class="tok-type">u29</span>, ret_addr: <span class="tok-type">usize</span>) ?<span class="tok-type">usize</span> {</span>
<span class="line" id="L172">    <span class="tok-kw">return</span> self.vtable.resize(self.ptr, buf, buf_align, new_len, len_align, ret_addr);</span>
<span class="line" id="L173">}</span>
<span class="line" id="L174"></span>
<span class="line" id="L175"><span class="tok-comment">/// This function is not intended to be called except from within the implementation of an Allocator</span></span>
<span class="line" id="L176"><span class="tok-kw">pub</span> <span class="tok-kw">inline</span> <span class="tok-kw">fn</span> <span class="tok-fn">rawFree</span>(self: Allocator, buf: []<span class="tok-type">u8</span>, buf_align: <span class="tok-type">u29</span>, ret_addr: <span class="tok-type">usize</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L177">    <span class="tok-kw">return</span> self.vtable.free(self.ptr, buf, buf_align, ret_addr);</span>
<span class="line" id="L178">}</span>
<span class="line" id="L179"></span>
<span class="line" id="L180"><span class="tok-comment">/// Returns a pointer to undefined memory.</span></span>
<span class="line" id="L181"><span class="tok-comment">/// Call `destroy` with the result to free the memory.</span></span>
<span class="line" id="L182"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">create</span>(self: Allocator, <span class="tok-kw">comptime</span> T: <span class="tok-type">type</span>) Error!*T {</span>
<span class="line" id="L183">    <span class="tok-kw">if</span> (<span class="tok-builtin">@sizeOf</span>(T) == <span class="tok-number">0</span>) <span class="tok-kw">return</span> <span class="tok-builtin">@as</span>(*T, <span class="tok-null">undefined</span>);</span>
<span class="line" id="L184">    <span class="tok-kw">const</span> slice = <span class="tok-kw">try</span> self.allocAdvancedWithRetAddr(T, <span class="tok-null">null</span>, <span class="tok-number">1</span>, .exact, <span class="tok-builtin">@returnAddress</span>());</span>
<span class="line" id="L185">    <span class="tok-kw">return</span> &amp;slice[<span class="tok-number">0</span>];</span>
<span class="line" id="L186">}</span>
<span class="line" id="L187"></span>
<span class="line" id="L188"><span class="tok-comment">/// `ptr` should be the return value of `create`, or otherwise</span></span>
<span class="line" id="L189"><span class="tok-comment">/// have the same address and alignment property.</span></span>
<span class="line" id="L190"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">destroy</span>(self: Allocator, ptr: <span class="tok-kw">anytype</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L191">    <span class="tok-kw">const</span> info = <span class="tok-builtin">@typeInfo</span>(<span class="tok-builtin">@TypeOf</span>(ptr)).Pointer;</span>
<span class="line" id="L192">    <span class="tok-kw">const</span> T = info.child;</span>
<span class="line" id="L193">    <span class="tok-kw">if</span> (<span class="tok-builtin">@sizeOf</span>(T) == <span class="tok-number">0</span>) <span class="tok-kw">return</span>;</span>
<span class="line" id="L194">    <span class="tok-kw">const</span> non_const_ptr = <span class="tok-builtin">@intToPtr</span>([*]<span class="tok-type">u8</span>, <span class="tok-builtin">@ptrToInt</span>(ptr));</span>
<span class="line" id="L195">    self.rawFree(non_const_ptr[<span class="tok-number">0</span>..<span class="tok-builtin">@sizeOf</span>(T)], info.alignment, <span class="tok-builtin">@returnAddress</span>());</span>
<span class="line" id="L196">}</span>
<span class="line" id="L197"></span>
<span class="line" id="L198"><span class="tok-comment">/// Allocates an array of `n` items of type `T` and sets all the</span></span>
<span class="line" id="L199"><span class="tok-comment">/// items to `undefined`. Depending on the Allocator</span></span>
<span class="line" id="L200"><span class="tok-comment">/// implementation, it may be required to call `free` once the</span></span>
<span class="line" id="L201"><span class="tok-comment">/// memory is no longer needed, to avoid a resource leak. If the</span></span>
<span class="line" id="L202"><span class="tok-comment">/// `Allocator` implementation is unknown, then correct code will</span></span>
<span class="line" id="L203"><span class="tok-comment">/// call `free` when done.</span></span>
<span class="line" id="L204"><span class="tok-comment">///</span></span>
<span class="line" id="L205"><span class="tok-comment">/// For allocating a single item, see `create`.</span></span>
<span class="line" id="L206"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">alloc</span>(self: Allocator, <span class="tok-kw">comptime</span> T: <span class="tok-type">type</span>, n: <span class="tok-type">usize</span>) Error![]T {</span>
<span class="line" id="L207">    <span class="tok-kw">return</span> self.allocAdvancedWithRetAddr(T, <span class="tok-null">null</span>, n, .exact, <span class="tok-builtin">@returnAddress</span>());</span>
<span class="line" id="L208">}</span>
<span class="line" id="L209"></span>
<span class="line" id="L210"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">allocWithOptions</span>(</span>
<span class="line" id="L211">    self: Allocator,</span>
<span class="line" id="L212">    <span class="tok-kw">comptime</span> Elem: <span class="tok-type">type</span>,</span>
<span class="line" id="L213">    n: <span class="tok-type">usize</span>,</span>
<span class="line" id="L214">    <span class="tok-comment">/// null means naturally aligned</span></span>
<span class="line" id="L215">    <span class="tok-kw">comptime</span> optional_alignment: ?<span class="tok-type">u29</span>,</span>
<span class="line" id="L216">    <span class="tok-kw">comptime</span> optional_sentinel: ?Elem,</span>
<span class="line" id="L217">) Error!AllocWithOptionsPayload(Elem, optional_alignment, optional_sentinel) {</span>
<span class="line" id="L218">    <span class="tok-kw">return</span> self.allocWithOptionsRetAddr(Elem, n, optional_alignment, optional_sentinel, <span class="tok-builtin">@returnAddress</span>());</span>
<span class="line" id="L219">}</span>
<span class="line" id="L220"></span>
<span class="line" id="L221"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">allocWithOptionsRetAddr</span>(</span>
<span class="line" id="L222">    self: Allocator,</span>
<span class="line" id="L223">    <span class="tok-kw">comptime</span> Elem: <span class="tok-type">type</span>,</span>
<span class="line" id="L224">    n: <span class="tok-type">usize</span>,</span>
<span class="line" id="L225">    <span class="tok-comment">/// null means naturally aligned</span></span>
<span class="line" id="L226">    <span class="tok-kw">comptime</span> optional_alignment: ?<span class="tok-type">u29</span>,</span>
<span class="line" id="L227">    <span class="tok-kw">comptime</span> optional_sentinel: ?Elem,</span>
<span class="line" id="L228">    return_address: <span class="tok-type">usize</span>,</span>
<span class="line" id="L229">) Error!AllocWithOptionsPayload(Elem, optional_alignment, optional_sentinel) {</span>
<span class="line" id="L230">    <span class="tok-kw">if</span> (optional_sentinel) |sentinel| {</span>
<span class="line" id="L231">        <span class="tok-kw">const</span> ptr = <span class="tok-kw">try</span> self.allocAdvancedWithRetAddr(Elem, optional_alignment, n + <span class="tok-number">1</span>, .exact, return_address);</span>
<span class="line" id="L232">        ptr[n] = sentinel;</span>
<span class="line" id="L233">        <span class="tok-kw">return</span> ptr[<span class="tok-number">0</span>..n :sentinel];</span>
<span class="line" id="L234">    } <span class="tok-kw">else</span> {</span>
<span class="line" id="L235">        <span class="tok-kw">return</span> self.allocAdvancedWithRetAddr(Elem, optional_alignment, n, .exact, return_address);</span>
<span class="line" id="L236">    }</span>
<span class="line" id="L237">}</span>
<span class="line" id="L238"></span>
<span class="line" id="L239"><span class="tok-kw">fn</span> <span class="tok-fn">AllocWithOptionsPayload</span>(<span class="tok-kw">comptime</span> Elem: <span class="tok-type">type</span>, <span class="tok-kw">comptime</span> alignment: ?<span class="tok-type">u29</span>, <span class="tok-kw">comptime</span> sentinel: ?Elem) <span class="tok-type">type</span> {</span>
<span class="line" id="L240">    <span class="tok-kw">if</span> (sentinel) |s| {</span>
<span class="line" id="L241">        <span class="tok-kw">return</span> [:s]<span class="tok-kw">align</span>(alignment <span class="tok-kw">orelse</span> <span class="tok-builtin">@alignOf</span>(Elem)) Elem;</span>
<span class="line" id="L242">    } <span class="tok-kw">else</span> {</span>
<span class="line" id="L243">        <span class="tok-kw">return</span> []<span class="tok-kw">align</span>(alignment <span class="tok-kw">orelse</span> <span class="tok-builtin">@alignOf</span>(Elem)) Elem;</span>
<span class="line" id="L244">    }</span>
<span class="line" id="L245">}</span>
<span class="line" id="L246"></span>
<span class="line" id="L247"><span class="tok-comment">/// Allocates an array of `n + 1` items of type `T` and sets the first `n`</span></span>
<span class="line" id="L248"><span class="tok-comment">/// items to `undefined` and the last item to `sentinel`. Depending on the</span></span>
<span class="line" id="L249"><span class="tok-comment">/// Allocator implementation, it may be required to call `free` once the</span></span>
<span class="line" id="L250"><span class="tok-comment">/// memory is no longer needed, to avoid a resource leak. If the</span></span>
<span class="line" id="L251"><span class="tok-comment">/// `Allocator` implementation is unknown, then correct code will</span></span>
<span class="line" id="L252"><span class="tok-comment">/// call `free` when done.</span></span>
<span class="line" id="L253"><span class="tok-comment">///</span></span>
<span class="line" id="L254"><span class="tok-comment">/// For allocating a single item, see `create`.</span></span>
<span class="line" id="L255"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">allocSentinel</span>(</span>
<span class="line" id="L256">    self: Allocator,</span>
<span class="line" id="L257">    <span class="tok-kw">comptime</span> Elem: <span class="tok-type">type</span>,</span>
<span class="line" id="L258">    n: <span class="tok-type">usize</span>,</span>
<span class="line" id="L259">    <span class="tok-kw">comptime</span> sentinel: Elem,</span>
<span class="line" id="L260">) Error![:sentinel]Elem {</span>
<span class="line" id="L261">    <span class="tok-kw">return</span> self.allocWithOptionsRetAddr(Elem, n, <span class="tok-null">null</span>, sentinel, <span class="tok-builtin">@returnAddress</span>());</span>
<span class="line" id="L262">}</span>
<span class="line" id="L263"></span>
<span class="line" id="L264"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">alignedAlloc</span>(</span>
<span class="line" id="L265">    self: Allocator,</span>
<span class="line" id="L266">    <span class="tok-kw">comptime</span> T: <span class="tok-type">type</span>,</span>
<span class="line" id="L267">    <span class="tok-comment">/// null means naturally aligned</span></span>
<span class="line" id="L268">    <span class="tok-kw">comptime</span> alignment: ?<span class="tok-type">u29</span>,</span>
<span class="line" id="L269">    n: <span class="tok-type">usize</span>,</span>
<span class="line" id="L270">) Error![]<span class="tok-kw">align</span>(alignment <span class="tok-kw">orelse</span> <span class="tok-builtin">@alignOf</span>(T)) T {</span>
<span class="line" id="L271">    <span class="tok-kw">return</span> self.allocAdvancedWithRetAddr(T, alignment, n, .exact, <span class="tok-builtin">@returnAddress</span>());</span>
<span class="line" id="L272">}</span>
<span class="line" id="L273"></span>
<span class="line" id="L274"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">allocAdvanced</span>(</span>
<span class="line" id="L275">    self: Allocator,</span>
<span class="line" id="L276">    <span class="tok-kw">comptime</span> T: <span class="tok-type">type</span>,</span>
<span class="line" id="L277">    <span class="tok-comment">/// null means naturally aligned</span></span>
<span class="line" id="L278">    <span class="tok-kw">comptime</span> alignment: ?<span class="tok-type">u29</span>,</span>
<span class="line" id="L279">    n: <span class="tok-type">usize</span>,</span>
<span class="line" id="L280">    exact: Exact,</span>
<span class="line" id="L281">) Error![]<span class="tok-kw">align</span>(alignment <span class="tok-kw">orelse</span> <span class="tok-builtin">@alignOf</span>(T)) T {</span>
<span class="line" id="L282">    <span class="tok-kw">return</span> self.allocAdvancedWithRetAddr(T, alignment, n, exact, <span class="tok-builtin">@returnAddress</span>());</span>
<span class="line" id="L283">}</span>
<span class="line" id="L284"></span>
<span class="line" id="L285"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> Exact = <span class="tok-kw">enum</span> { exact, at_least };</span>
<span class="line" id="L286"></span>
<span class="line" id="L287"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">allocAdvancedWithRetAddr</span>(</span>
<span class="line" id="L288">    self: Allocator,</span>
<span class="line" id="L289">    <span class="tok-kw">comptime</span> T: <span class="tok-type">type</span>,</span>
<span class="line" id="L290">    <span class="tok-comment">/// null means naturally aligned</span></span>
<span class="line" id="L291">    <span class="tok-kw">comptime</span> alignment: ?<span class="tok-type">u29</span>,</span>
<span class="line" id="L292">    n: <span class="tok-type">usize</span>,</span>
<span class="line" id="L293">    exact: Exact,</span>
<span class="line" id="L294">    return_address: <span class="tok-type">usize</span>,</span>
<span class="line" id="L295">) Error![]<span class="tok-kw">align</span>(alignment <span class="tok-kw">orelse</span> <span class="tok-builtin">@alignOf</span>(T)) T {</span>
<span class="line" id="L296">    <span class="tok-kw">const</span> a = <span class="tok-kw">if</span> (alignment) |a| blk: {</span>
<span class="line" id="L297">        <span class="tok-kw">if</span> (a == <span class="tok-builtin">@alignOf</span>(T)) <span class="tok-kw">return</span> allocAdvancedWithRetAddr(self, T, <span class="tok-null">null</span>, n, exact, return_address);</span>
<span class="line" id="L298">        <span class="tok-kw">break</span> :blk a;</span>
<span class="line" id="L299">    } <span class="tok-kw">else</span> <span class="tok-builtin">@alignOf</span>(T);</span>
<span class="line" id="L300"></span>
<span class="line" id="L301">    <span class="tok-kw">if</span> (n == <span class="tok-number">0</span>) {</span>
<span class="line" id="L302">        <span class="tok-kw">return</span> <span class="tok-builtin">@as</span>([*]<span class="tok-kw">align</span>(a) T, <span class="tok-null">undefined</span>)[<span class="tok-number">0</span>..<span class="tok-number">0</span>];</span>
<span class="line" id="L303">    }</span>
<span class="line" id="L304"></span>
<span class="line" id="L305">    <span class="tok-kw">const</span> byte_count = math.mul(<span class="tok-type">usize</span>, <span class="tok-builtin">@sizeOf</span>(T), n) <span class="tok-kw">catch</span> <span class="tok-kw">return</span> Error.OutOfMemory;</span>
<span class="line" id="L306">    <span class="tok-comment">// TODO The `if (alignment == null)` blocks are workarounds for zig not being able to</span>
</span>
<span class="line" id="L307">    <span class="tok-comment">// access certain type information about T without creating a circular dependency in async</span>
</span>
<span class="line" id="L308">    <span class="tok-comment">// functions that heap-allocate their own frame with @Frame(func).</span>
</span>
<span class="line" id="L309">    <span class="tok-kw">const</span> size_of_T = <span class="tok-kw">if</span> (alignment == <span class="tok-null">null</span>) <span class="tok-builtin">@intCast</span>(<span class="tok-type">u29</span>, <span class="tok-builtin">@divExact</span>(byte_count, n)) <span class="tok-kw">else</span> <span class="tok-builtin">@sizeOf</span>(T);</span>
<span class="line" id="L310">    <span class="tok-kw">const</span> len_align: <span class="tok-type">u29</span> = <span class="tok-kw">switch</span> (exact) {</span>
<span class="line" id="L311">        .exact =&gt; <span class="tok-number">0</span>,</span>
<span class="line" id="L312">        .at_least =&gt; size_of_T,</span>
<span class="line" id="L313">    };</span>
<span class="line" id="L314">    <span class="tok-kw">const</span> byte_slice = <span class="tok-kw">try</span> self.rawAlloc(byte_count, a, len_align, return_address);</span>
<span class="line" id="L315">    <span class="tok-kw">switch</span> (exact) {</span>
<span class="line" id="L316">        .exact =&gt; assert(byte_slice.len == byte_count),</span>
<span class="line" id="L317">        .at_least =&gt; assert(byte_slice.len &gt;= byte_count),</span>
<span class="line" id="L318">    }</span>
<span class="line" id="L319">    <span class="tok-comment">// TODO: https://github.com/ziglang/zig/issues/4298</span>
</span>
<span class="line" id="L320">    <span class="tok-builtin">@memset</span>(byte_slice.ptr, <span class="tok-null">undefined</span>, byte_slice.len);</span>
<span class="line" id="L321">    <span class="tok-kw">if</span> (alignment == <span class="tok-null">null</span>) {</span>
<span class="line" id="L322">        <span class="tok-comment">// This if block is a workaround (see comment above)</span>
</span>
<span class="line" id="L323">        <span class="tok-kw">return</span> <span class="tok-builtin">@intToPtr</span>([*]T, <span class="tok-builtin">@ptrToInt</span>(byte_slice.ptr))[<span class="tok-number">0</span>..<span class="tok-builtin">@divExact</span>(byte_slice.len, <span class="tok-builtin">@sizeOf</span>(T))];</span>
<span class="line" id="L324">    } <span class="tok-kw">else</span> {</span>
<span class="line" id="L325">        <span class="tok-kw">return</span> mem.bytesAsSlice(T, <span class="tok-builtin">@alignCast</span>(a, byte_slice));</span>
<span class="line" id="L326">    }</span>
<span class="line" id="L327">}</span>
<span class="line" id="L328"></span>
<span class="line" id="L329"><span class="tok-comment">/// Increases or decreases the size of an allocation. It is guaranteed to not move the pointer.</span></span>
<span class="line" id="L330"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">resize</span>(self: Allocator, old_mem: <span class="tok-kw">anytype</span>, new_n: <span class="tok-type">usize</span>) ?<span class="tok-builtin">@TypeOf</span>(old_mem) {</span>
<span class="line" id="L331">    <span class="tok-kw">const</span> Slice = <span class="tok-builtin">@typeInfo</span>(<span class="tok-builtin">@TypeOf</span>(old_mem)).Pointer;</span>
<span class="line" id="L332">    <span class="tok-kw">const</span> T = Slice.child;</span>
<span class="line" id="L333">    <span class="tok-kw">if</span> (new_n == <span class="tok-number">0</span>) {</span>
<span class="line" id="L334">        self.free(old_mem);</span>
<span class="line" id="L335">        <span class="tok-kw">return</span> &amp;[<span class="tok-number">0</span>]T{};</span>
<span class="line" id="L336">    }</span>
<span class="line" id="L337">    <span class="tok-kw">const</span> old_byte_slice = mem.sliceAsBytes(old_mem);</span>
<span class="line" id="L338">    <span class="tok-kw">const</span> new_byte_count = math.mul(<span class="tok-type">usize</span>, <span class="tok-builtin">@sizeOf</span>(T), new_n) <span class="tok-kw">catch</span> <span class="tok-kw">return</span> <span class="tok-null">null</span>;</span>
<span class="line" id="L339">    <span class="tok-kw">const</span> rc = self.rawResize(old_byte_slice, Slice.alignment, new_byte_count, <span class="tok-number">0</span>, <span class="tok-builtin">@returnAddress</span>()) <span class="tok-kw">orelse</span> <span class="tok-kw">return</span> <span class="tok-null">null</span>;</span>
<span class="line" id="L340">    assert(rc == new_byte_count);</span>
<span class="line" id="L341">    <span class="tok-kw">const</span> new_byte_slice = old_byte_slice.ptr[<span class="tok-number">0</span>..new_byte_count];</span>
<span class="line" id="L342">    <span class="tok-kw">return</span> mem.bytesAsSlice(T, new_byte_slice);</span>
<span class="line" id="L343">}</span>
<span class="line" id="L344"></span>
<span class="line" id="L345"><span class="tok-comment">/// This function requests a new byte size for an existing allocation,</span></span>
<span class="line" id="L346"><span class="tok-comment">/// which can be larger, smaller, or the same size as the old memory</span></span>
<span class="line" id="L347"><span class="tok-comment">/// allocation.</span></span>
<span class="line" id="L348"><span class="tok-comment">/// This function is preferred over `shrink`, because it can fail, even</span></span>
<span class="line" id="L349"><span class="tok-comment">/// when shrinking. This gives the allocator a chance to perform a</span></span>
<span class="line" id="L350"><span class="tok-comment">/// cheap shrink operation if possible, or otherwise return OutOfMemory,</span></span>
<span class="line" id="L351"><span class="tok-comment">/// indicating that the caller should keep their capacity, for example</span></span>
<span class="line" id="L352"><span class="tok-comment">/// in `std.ArrayList.shrink`.</span></span>
<span class="line" id="L353"><span class="tok-comment">/// If you need guaranteed success, call `shrink`.</span></span>
<span class="line" id="L354"><span class="tok-comment">/// If `new_n` is 0, this is the same as `free` and it always succeeds.</span></span>
<span class="line" id="L355"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">realloc</span>(self: Allocator, old_mem: <span class="tok-kw">anytype</span>, new_n: <span class="tok-type">usize</span>) t: {</span>
<span class="line" id="L356">    <span class="tok-kw">const</span> Slice = <span class="tok-builtin">@typeInfo</span>(<span class="tok-builtin">@TypeOf</span>(old_mem)).Pointer;</span>
<span class="line" id="L357">    <span class="tok-kw">break</span> :t Error![]<span class="tok-kw">align</span>(Slice.alignment) Slice.child;</span>
<span class="line" id="L358">} {</span>
<span class="line" id="L359">    <span class="tok-kw">const</span> old_alignment = <span class="tok-builtin">@typeInfo</span>(<span class="tok-builtin">@TypeOf</span>(old_mem)).Pointer.alignment;</span>
<span class="line" id="L360">    <span class="tok-kw">return</span> self.reallocAdvancedWithRetAddr(old_mem, old_alignment, new_n, .exact, <span class="tok-builtin">@returnAddress</span>());</span>
<span class="line" id="L361">}</span>
<span class="line" id="L362"></span>
<span class="line" id="L363"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">reallocAtLeast</span>(self: Allocator, old_mem: <span class="tok-kw">anytype</span>, new_n: <span class="tok-type">usize</span>) t: {</span>
<span class="line" id="L364">    <span class="tok-kw">const</span> Slice = <span class="tok-builtin">@typeInfo</span>(<span class="tok-builtin">@TypeOf</span>(old_mem)).Pointer;</span>
<span class="line" id="L365">    <span class="tok-kw">break</span> :t Error![]<span class="tok-kw">align</span>(Slice.alignment) Slice.child;</span>
<span class="line" id="L366">} {</span>
<span class="line" id="L367">    <span class="tok-kw">const</span> old_alignment = <span class="tok-builtin">@typeInfo</span>(<span class="tok-builtin">@TypeOf</span>(old_mem)).Pointer.alignment;</span>
<span class="line" id="L368">    <span class="tok-kw">return</span> self.reallocAdvancedWithRetAddr(old_mem, old_alignment, new_n, .at_least, <span class="tok-builtin">@returnAddress</span>());</span>
<span class="line" id="L369">}</span>
<span class="line" id="L370"></span>
<span class="line" id="L371"><span class="tok-comment">/// This is the same as `realloc`, except caller may additionally request</span></span>
<span class="line" id="L372"><span class="tok-comment">/// a new alignment, which can be larger, smaller, or the same as the old</span></span>
<span class="line" id="L373"><span class="tok-comment">/// allocation.</span></span>
<span class="line" id="L374"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">reallocAdvanced</span>(</span>
<span class="line" id="L375">    self: Allocator,</span>
<span class="line" id="L376">    old_mem: <span class="tok-kw">anytype</span>,</span>
<span class="line" id="L377">    <span class="tok-kw">comptime</span> new_alignment: <span class="tok-type">u29</span>,</span>
<span class="line" id="L378">    new_n: <span class="tok-type">usize</span>,</span>
<span class="line" id="L379">    exact: Exact,</span>
<span class="line" id="L380">) Error![]<span class="tok-kw">align</span>(new_alignment) <span class="tok-builtin">@typeInfo</span>(<span class="tok-builtin">@TypeOf</span>(old_mem)).Pointer.child {</span>
<span class="line" id="L381">    <span class="tok-kw">return</span> self.reallocAdvancedWithRetAddr(old_mem, new_alignment, new_n, exact, <span class="tok-builtin">@returnAddress</span>());</span>
<span class="line" id="L382">}</span>
<span class="line" id="L383"></span>
<span class="line" id="L384"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">reallocAdvancedWithRetAddr</span>(</span>
<span class="line" id="L385">    self: Allocator,</span>
<span class="line" id="L386">    old_mem: <span class="tok-kw">anytype</span>,</span>
<span class="line" id="L387">    <span class="tok-kw">comptime</span> new_alignment: <span class="tok-type">u29</span>,</span>
<span class="line" id="L388">    new_n: <span class="tok-type">usize</span>,</span>
<span class="line" id="L389">    exact: Exact,</span>
<span class="line" id="L390">    return_address: <span class="tok-type">usize</span>,</span>
<span class="line" id="L391">) Error![]<span class="tok-kw">align</span>(new_alignment) <span class="tok-builtin">@typeInfo</span>(<span class="tok-builtin">@TypeOf</span>(old_mem)).Pointer.child {</span>
<span class="line" id="L392">    <span class="tok-kw">const</span> Slice = <span class="tok-builtin">@typeInfo</span>(<span class="tok-builtin">@TypeOf</span>(old_mem)).Pointer;</span>
<span class="line" id="L393">    <span class="tok-kw">const</span> T = Slice.child;</span>
<span class="line" id="L394">    <span class="tok-kw">if</span> (old_mem.len == <span class="tok-number">0</span>) {</span>
<span class="line" id="L395">        <span class="tok-kw">return</span> self.allocAdvancedWithRetAddr(T, new_alignment, new_n, exact, return_address);</span>
<span class="line" id="L396">    }</span>
<span class="line" id="L397">    <span class="tok-kw">if</span> (new_n == <span class="tok-number">0</span>) {</span>
<span class="line" id="L398">        self.free(old_mem);</span>
<span class="line" id="L399">        <span class="tok-kw">return</span> <span class="tok-builtin">@as</span>([*]<span class="tok-kw">align</span>(new_alignment) T, <span class="tok-null">undefined</span>)[<span class="tok-number">0</span>..<span class="tok-number">0</span>];</span>
<span class="line" id="L400">    }</span>
<span class="line" id="L401"></span>
<span class="line" id="L402">    <span class="tok-kw">const</span> old_byte_slice = mem.sliceAsBytes(old_mem);</span>
<span class="line" id="L403">    <span class="tok-kw">const</span> byte_count = math.mul(<span class="tok-type">usize</span>, <span class="tok-builtin">@sizeOf</span>(T), new_n) <span class="tok-kw">catch</span> <span class="tok-kw">return</span> Error.OutOfMemory;</span>
<span class="line" id="L404">    <span class="tok-comment">// Note: can't set shrunk memory to undefined as memory shouldn't be modified on realloc failure</span>
</span>
<span class="line" id="L405">    <span class="tok-kw">const</span> len_align: <span class="tok-type">u29</span> = <span class="tok-kw">switch</span> (exact) {</span>
<span class="line" id="L406">        .exact =&gt; <span class="tok-number">0</span>,</span>
<span class="line" id="L407">        .at_least =&gt; <span class="tok-builtin">@sizeOf</span>(T),</span>
<span class="line" id="L408">    };</span>
<span class="line" id="L409"></span>
<span class="line" id="L410">    <span class="tok-kw">if</span> (mem.isAligned(<span class="tok-builtin">@ptrToInt</span>(old_byte_slice.ptr), new_alignment)) {</span>
<span class="line" id="L411">        <span class="tok-kw">if</span> (byte_count &lt;= old_byte_slice.len) {</span>
<span class="line" id="L412">            <span class="tok-kw">const</span> shrunk_len = self.shrinkBytes(old_byte_slice, Slice.alignment, byte_count, len_align, return_address);</span>
<span class="line" id="L413">            <span class="tok-kw">return</span> mem.bytesAsSlice(T, <span class="tok-builtin">@alignCast</span>(new_alignment, old_byte_slice.ptr[<span class="tok-number">0</span>..shrunk_len]));</span>
<span class="line" id="L414">        }</span>
<span class="line" id="L415"></span>
<span class="line" id="L416">        <span class="tok-kw">if</span> (self.rawResize(old_byte_slice, Slice.alignment, byte_count, len_align, return_address)) |resized_len| {</span>
<span class="line" id="L417">            <span class="tok-comment">// TODO: https://github.com/ziglang/zig/issues/4298</span>
</span>
<span class="line" id="L418">            <span class="tok-builtin">@memset</span>(old_byte_slice.ptr + byte_count, <span class="tok-null">undefined</span>, resized_len - byte_count);</span>
<span class="line" id="L419">            <span class="tok-kw">return</span> mem.bytesAsSlice(T, <span class="tok-builtin">@alignCast</span>(new_alignment, old_byte_slice.ptr[<span class="tok-number">0</span>..resized_len]));</span>
<span class="line" id="L420">        }</span>
<span class="line" id="L421">    }</span>
<span class="line" id="L422"></span>
<span class="line" id="L423">    <span class="tok-kw">if</span> (byte_count &lt;= old_byte_slice.len <span class="tok-kw">and</span> new_alignment &lt;= Slice.alignment) {</span>
<span class="line" id="L424">        <span class="tok-kw">return</span> <span class="tok-kw">error</span>.OutOfMemory;</span>
<span class="line" id="L425">    }</span>
<span class="line" id="L426"></span>
<span class="line" id="L427">    <span class="tok-kw">const</span> new_mem = <span class="tok-kw">try</span> self.rawAlloc(byte_count, new_alignment, len_align, return_address);</span>
<span class="line" id="L428">    <span class="tok-builtin">@memcpy</span>(new_mem.ptr, old_byte_slice.ptr, math.min(byte_count, old_byte_slice.len));</span>
<span class="line" id="L429">    <span class="tok-comment">// TODO https://github.com/ziglang/zig/issues/4298</span>
</span>
<span class="line" id="L430">    <span class="tok-builtin">@memset</span>(old_byte_slice.ptr, <span class="tok-null">undefined</span>, old_byte_slice.len);</span>
<span class="line" id="L431">    self.rawFree(old_byte_slice, Slice.alignment, return_address);</span>
<span class="line" id="L432"></span>
<span class="line" id="L433">    <span class="tok-kw">return</span> mem.bytesAsSlice(T, <span class="tok-builtin">@alignCast</span>(new_alignment, new_mem));</span>
<span class="line" id="L434">}</span>
<span class="line" id="L435"></span>
<span class="line" id="L436"><span class="tok-comment">/// Prefer calling realloc to shrink if you can tolerate failure, such as</span></span>
<span class="line" id="L437"><span class="tok-comment">/// in an ArrayList data structure with a storage capacity.</span></span>
<span class="line" id="L438"><span class="tok-comment">/// Shrink always succeeds, and `new_n` must be &lt;= `old_mem.len`.</span></span>
<span class="line" id="L439"><span class="tok-comment">/// Returned slice has same alignment as old_mem.</span></span>
<span class="line" id="L440"><span class="tok-comment">/// Shrinking to 0 is the same as calling `free`.</span></span>
<span class="line" id="L441"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">shrink</span>(self: Allocator, old_mem: <span class="tok-kw">anytype</span>, new_n: <span class="tok-type">usize</span>) t: {</span>
<span class="line" id="L442">    <span class="tok-kw">const</span> Slice = <span class="tok-builtin">@typeInfo</span>(<span class="tok-builtin">@TypeOf</span>(old_mem)).Pointer;</span>
<span class="line" id="L443">    <span class="tok-kw">break</span> :t []<span class="tok-kw">align</span>(Slice.alignment) Slice.child;</span>
<span class="line" id="L444">} {</span>
<span class="line" id="L445">    <span class="tok-kw">const</span> old_alignment = <span class="tok-builtin">@typeInfo</span>(<span class="tok-builtin">@TypeOf</span>(old_mem)).Pointer.alignment;</span>
<span class="line" id="L446">    <span class="tok-kw">return</span> self.alignedShrinkWithRetAddr(old_mem, old_alignment, new_n, <span class="tok-builtin">@returnAddress</span>());</span>
<span class="line" id="L447">}</span>
<span class="line" id="L448"></span>
<span class="line" id="L449"><span class="tok-comment">/// This is the same as `shrink`, except caller may additionally request</span></span>
<span class="line" id="L450"><span class="tok-comment">/// a new alignment, which must be smaller or the same as the old</span></span>
<span class="line" id="L451"><span class="tok-comment">/// allocation.</span></span>
<span class="line" id="L452"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">alignedShrink</span>(</span>
<span class="line" id="L453">    self: Allocator,</span>
<span class="line" id="L454">    old_mem: <span class="tok-kw">anytype</span>,</span>
<span class="line" id="L455">    <span class="tok-kw">comptime</span> new_alignment: <span class="tok-type">u29</span>,</span>
<span class="line" id="L456">    new_n: <span class="tok-type">usize</span>,</span>
<span class="line" id="L457">) []<span class="tok-kw">align</span>(new_alignment) <span class="tok-builtin">@typeInfo</span>(<span class="tok-builtin">@TypeOf</span>(old_mem)).Pointer.child {</span>
<span class="line" id="L458">    <span class="tok-kw">return</span> self.alignedShrinkWithRetAddr(old_mem, new_alignment, new_n, <span class="tok-builtin">@returnAddress</span>());</span>
<span class="line" id="L459">}</span>
<span class="line" id="L460"></span>
<span class="line" id="L461"><span class="tok-comment">/// This is the same as `alignedShrink`, except caller may additionally pass</span></span>
<span class="line" id="L462"><span class="tok-comment">/// the return address of the first stack frame, which may be relevant for</span></span>
<span class="line" id="L463"><span class="tok-comment">/// allocators which collect stack traces.</span></span>
<span class="line" id="L464"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">alignedShrinkWithRetAddr</span>(</span>
<span class="line" id="L465">    self: Allocator,</span>
<span class="line" id="L466">    old_mem: <span class="tok-kw">anytype</span>,</span>
<span class="line" id="L467">    <span class="tok-kw">comptime</span> new_alignment: <span class="tok-type">u29</span>,</span>
<span class="line" id="L468">    new_n: <span class="tok-type">usize</span>,</span>
<span class="line" id="L469">    return_address: <span class="tok-type">usize</span>,</span>
<span class="line" id="L470">) []<span class="tok-kw">align</span>(new_alignment) <span class="tok-builtin">@typeInfo</span>(<span class="tok-builtin">@TypeOf</span>(old_mem)).Pointer.child {</span>
<span class="line" id="L471">    <span class="tok-kw">const</span> Slice = <span class="tok-builtin">@typeInfo</span>(<span class="tok-builtin">@TypeOf</span>(old_mem)).Pointer;</span>
<span class="line" id="L472">    <span class="tok-kw">const</span> T = Slice.child;</span>
<span class="line" id="L473"></span>
<span class="line" id="L474">    <span class="tok-kw">if</span> (new_n == old_mem.len)</span>
<span class="line" id="L475">        <span class="tok-kw">return</span> old_mem;</span>
<span class="line" id="L476">    <span class="tok-kw">if</span> (new_n == <span class="tok-number">0</span>) {</span>
<span class="line" id="L477">        self.free(old_mem);</span>
<span class="line" id="L478">        <span class="tok-kw">return</span> <span class="tok-builtin">@as</span>([*]<span class="tok-kw">align</span>(new_alignment) T, <span class="tok-null">undefined</span>)[<span class="tok-number">0</span>..<span class="tok-number">0</span>];</span>
<span class="line" id="L479">    }</span>
<span class="line" id="L480"></span>
<span class="line" id="L481">    assert(new_n &lt; old_mem.len);</span>
<span class="line" id="L482">    assert(new_alignment &lt;= Slice.alignment);</span>
<span class="line" id="L483"></span>
<span class="line" id="L484">    <span class="tok-comment">// Here we skip the overflow checking on the multiplication because</span>
</span>
<span class="line" id="L485">    <span class="tok-comment">// new_n &lt;= old_mem.len and the multiplication didn't overflow for that operation.</span>
</span>
<span class="line" id="L486">    <span class="tok-kw">const</span> byte_count = <span class="tok-builtin">@sizeOf</span>(T) * new_n;</span>
<span class="line" id="L487"></span>
<span class="line" id="L488">    <span class="tok-kw">const</span> old_byte_slice = mem.sliceAsBytes(old_mem);</span>
<span class="line" id="L489">    <span class="tok-comment">// TODO: https://github.com/ziglang/zig/issues/4298</span>
</span>
<span class="line" id="L490">    <span class="tok-builtin">@memset</span>(old_byte_slice.ptr + byte_count, <span class="tok-null">undefined</span>, old_byte_slice.len - byte_count);</span>
<span class="line" id="L491">    _ = self.shrinkBytes(old_byte_slice, Slice.alignment, byte_count, <span class="tok-number">0</span>, return_address);</span>
<span class="line" id="L492">    <span class="tok-kw">return</span> old_mem[<span class="tok-number">0</span>..new_n];</span>
<span class="line" id="L493">}</span>
<span class="line" id="L494"></span>
<span class="line" id="L495"><span class="tok-comment">/// Free an array allocated with `alloc`. To free a single item,</span></span>
<span class="line" id="L496"><span class="tok-comment">/// see `destroy`.</span></span>
<span class="line" id="L497"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">free</span>(self: Allocator, memory: <span class="tok-kw">anytype</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L498">    <span class="tok-kw">const</span> Slice = <span class="tok-builtin">@typeInfo</span>(<span class="tok-builtin">@TypeOf</span>(memory)).Pointer;</span>
<span class="line" id="L499">    <span class="tok-kw">const</span> bytes = mem.sliceAsBytes(memory);</span>
<span class="line" id="L500">    <span class="tok-kw">const</span> bytes_len = bytes.len + <span class="tok-kw">if</span> (Slice.sentinel != <span class="tok-null">null</span>) <span class="tok-builtin">@sizeOf</span>(Slice.child) <span class="tok-kw">else</span> <span class="tok-number">0</span>;</span>
<span class="line" id="L501">    <span class="tok-kw">if</span> (bytes_len == <span class="tok-number">0</span>) <span class="tok-kw">return</span>;</span>
<span class="line" id="L502">    <span class="tok-kw">const</span> non_const_ptr = <span class="tok-builtin">@intToPtr</span>([*]<span class="tok-type">u8</span>, <span class="tok-builtin">@ptrToInt</span>(bytes.ptr));</span>
<span class="line" id="L503">    <span class="tok-comment">// TODO: https://github.com/ziglang/zig/issues/4298</span>
</span>
<span class="line" id="L504">    <span class="tok-builtin">@memset</span>(non_const_ptr, <span class="tok-null">undefined</span>, bytes_len);</span>
<span class="line" id="L505">    self.rawFree(non_const_ptr[<span class="tok-number">0</span>..bytes_len], Slice.alignment, <span class="tok-builtin">@returnAddress</span>());</span>
<span class="line" id="L506">}</span>
<span class="line" id="L507"></span>
<span class="line" id="L508"><span class="tok-comment">/// Copies `m` to newly allocated memory. Caller owns the memory.</span></span>
<span class="line" id="L509"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">dupe</span>(allocator: Allocator, <span class="tok-kw">comptime</span> T: <span class="tok-type">type</span>, m: []<span class="tok-kw">const</span> T) ![]T {</span>
<span class="line" id="L510">    <span class="tok-kw">const</span> new_buf = <span class="tok-kw">try</span> allocator.alloc(T, m.len);</span>
<span class="line" id="L511">    mem.copy(T, new_buf, m);</span>
<span class="line" id="L512">    <span class="tok-kw">return</span> new_buf;</span>
<span class="line" id="L513">}</span>
<span class="line" id="L514"></span>
<span class="line" id="L515"><span class="tok-comment">/// Copies `m` to newly allocated memory, with a null-terminated element. Caller owns the memory.</span></span>
<span class="line" id="L516"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">dupeZ</span>(allocator: Allocator, <span class="tok-kw">comptime</span> T: <span class="tok-type">type</span>, m: []<span class="tok-kw">const</span> T) ![:<span class="tok-number">0</span>]T {</span>
<span class="line" id="L517">    <span class="tok-kw">const</span> new_buf = <span class="tok-kw">try</span> allocator.alloc(T, m.len + <span class="tok-number">1</span>);</span>
<span class="line" id="L518">    mem.copy(T, new_buf, m);</span>
<span class="line" id="L519">    new_buf[m.len] = <span class="tok-number">0</span>;</span>
<span class="line" id="L520">    <span class="tok-kw">return</span> new_buf[<span class="tok-number">0</span>..m.len :<span class="tok-number">0</span>];</span>
<span class="line" id="L521">}</span>
<span class="line" id="L522"></span>
<span class="line" id="L523"><span class="tok-comment">/// This function allows a runtime `alignment` value. Callers should generally prefer</span></span>
<span class="line" id="L524"><span class="tok-comment">/// to call the `alloc*` functions.</span></span>
<span class="line" id="L525"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">allocBytes</span>(</span>
<span class="line" id="L526">    self: Allocator,</span>
<span class="line" id="L527">    <span class="tok-comment">/// Must be &gt;= 1.</span></span>
<span class="line" id="L528">    <span class="tok-comment">/// Must be a power of 2.</span></span>
<span class="line" id="L529">    <span class="tok-comment">/// Returned slice's pointer will have this alignment.</span></span>
<span class="line" id="L530">    alignment: <span class="tok-type">u29</span>,</span>
<span class="line" id="L531">    byte_count: <span class="tok-type">usize</span>,</span>
<span class="line" id="L532">    <span class="tok-comment">/// 0 indicates the length of the slice returned MUST match `byte_count` exactly</span></span>
<span class="line" id="L533">    <span class="tok-comment">/// non-zero means the length of the returned slice must be aligned by `len_align`</span></span>
<span class="line" id="L534">    <span class="tok-comment">/// `byte_count` must be aligned by `len_align`</span></span>
<span class="line" id="L535">    len_align: <span class="tok-type">u29</span>,</span>
<span class="line" id="L536">    return_address: <span class="tok-type">usize</span>,</span>
<span class="line" id="L537">) Error![]<span class="tok-type">u8</span> {</span>
<span class="line" id="L538">    <span class="tok-kw">const</span> new_mem = <span class="tok-kw">try</span> self.rawAlloc(byte_count, alignment, len_align, return_address);</span>
<span class="line" id="L539">    <span class="tok-comment">// TODO: https://github.com/ziglang/zig/issues/4298</span>
</span>
<span class="line" id="L540">    <span class="tok-builtin">@memset</span>(new_mem.ptr, <span class="tok-null">undefined</span>, new_mem.len);</span>
<span class="line" id="L541">    <span class="tok-kw">return</span> new_mem;</span>
<span class="line" id="L542">}</span>
<span class="line" id="L543"></span>
<span class="line" id="L544"><span class="tok-kw">test</span> <span class="tok-str">&quot;allocBytes&quot;</span> {</span>
<span class="line" id="L545">    <span class="tok-kw">const</span> number_of_bytes: <span class="tok-type">usize</span> = <span class="tok-number">10</span>;</span>
<span class="line" id="L546">    <span class="tok-kw">var</span> runtime_alignment: <span class="tok-type">u29</span> = <span class="tok-number">2</span>;</span>
<span class="line" id="L547"></span>
<span class="line" id="L548">    {</span>
<span class="line" id="L549">        <span class="tok-kw">const</span> new_mem = <span class="tok-kw">try</span> std.testing.allocator.allocBytes(runtime_alignment, number_of_bytes, <span class="tok-number">0</span>, <span class="tok-builtin">@returnAddress</span>());</span>
<span class="line" id="L550">        <span class="tok-kw">defer</span> std.testing.allocator.free(new_mem);</span>
<span class="line" id="L551"></span>
<span class="line" id="L552">        <span class="tok-kw">try</span> std.testing.expectEqual(number_of_bytes, new_mem.len);</span>
<span class="line" id="L553">        <span class="tok-kw">try</span> std.testing.expect(mem.isAligned(<span class="tok-builtin">@ptrToInt</span>(new_mem.ptr), runtime_alignment));</span>
<span class="line" id="L554">    }</span>
<span class="line" id="L555"></span>
<span class="line" id="L556">    runtime_alignment = <span class="tok-number">8</span>;</span>
<span class="line" id="L557"></span>
<span class="line" id="L558">    {</span>
<span class="line" id="L559">        <span class="tok-kw">const</span> new_mem = <span class="tok-kw">try</span> std.testing.allocator.allocBytes(runtime_alignment, number_of_bytes, <span class="tok-number">0</span>, <span class="tok-builtin">@returnAddress</span>());</span>
<span class="line" id="L560">        <span class="tok-kw">defer</span> std.testing.allocator.free(new_mem);</span>
<span class="line" id="L561"></span>
<span class="line" id="L562">        <span class="tok-kw">try</span> std.testing.expectEqual(number_of_bytes, new_mem.len);</span>
<span class="line" id="L563">        <span class="tok-kw">try</span> std.testing.expect(mem.isAligned(<span class="tok-builtin">@ptrToInt</span>(new_mem.ptr), runtime_alignment));</span>
<span class="line" id="L564">    }</span>
<span class="line" id="L565">}</span>
<span class="line" id="L566"></span>
<span class="line" id="L567"><span class="tok-kw">test</span> <span class="tok-str">&quot;allocBytes non-zero len_align&quot;</span> {</span>
<span class="line" id="L568">    <span class="tok-kw">const</span> number_of_bytes: <span class="tok-type">usize</span> = <span class="tok-number">10</span>;</span>
<span class="line" id="L569">    <span class="tok-kw">var</span> runtime_alignment: <span class="tok-type">u29</span> = <span class="tok-number">1</span>;</span>
<span class="line" id="L570">    <span class="tok-kw">var</span> len_align: <span class="tok-type">u29</span> = <span class="tok-number">2</span>;</span>
<span class="line" id="L571"></span>
<span class="line" id="L572">    {</span>
<span class="line" id="L573">        <span class="tok-kw">const</span> new_mem = <span class="tok-kw">try</span> std.testing.allocator.allocBytes(runtime_alignment, number_of_bytes, len_align, <span class="tok-builtin">@returnAddress</span>());</span>
<span class="line" id="L574">        <span class="tok-kw">defer</span> std.testing.allocator.free(new_mem);</span>
<span class="line" id="L575"></span>
<span class="line" id="L576">        <span class="tok-kw">try</span> std.testing.expect(new_mem.len &gt;= number_of_bytes);</span>
<span class="line" id="L577">        <span class="tok-kw">try</span> std.testing.expect(new_mem.len % len_align == <span class="tok-number">0</span>);</span>
<span class="line" id="L578">        <span class="tok-kw">try</span> std.testing.expect(mem.isAligned(<span class="tok-builtin">@ptrToInt</span>(new_mem.ptr), runtime_alignment));</span>
<span class="line" id="L579">    }</span>
<span class="line" id="L580"></span>
<span class="line" id="L581">    runtime_alignment = <span class="tok-number">16</span>;</span>
<span class="line" id="L582">    len_align = <span class="tok-number">5</span>;</span>
<span class="line" id="L583"></span>
<span class="line" id="L584">    {</span>
<span class="line" id="L585">        <span class="tok-kw">const</span> new_mem = <span class="tok-kw">try</span> std.testing.allocator.allocBytes(runtime_alignment, number_of_bytes, len_align, <span class="tok-builtin">@returnAddress</span>());</span>
<span class="line" id="L586">        <span class="tok-kw">defer</span> std.testing.allocator.free(new_mem);</span>
<span class="line" id="L587"></span>
<span class="line" id="L588">        <span class="tok-kw">try</span> std.testing.expect(new_mem.len &gt;= number_of_bytes);</span>
<span class="line" id="L589">        <span class="tok-kw">try</span> std.testing.expect(new_mem.len % len_align == <span class="tok-number">0</span>);</span>
<span class="line" id="L590">        <span class="tok-kw">try</span> std.testing.expect(mem.isAligned(<span class="tok-builtin">@ptrToInt</span>(new_mem.ptr), runtime_alignment));</span>
<span class="line" id="L591">    }</span>
<span class="line" id="L592">}</span>
<span class="line" id="L593"></span>
<span class="line" id="L594"><span class="tok-comment">/// Realloc is used to modify the size or alignment of an existing allocation,</span></span>
<span class="line" id="L595"><span class="tok-comment">/// as well as to provide the allocator with an opportunity to move an allocation</span></span>
<span class="line" id="L596"><span class="tok-comment">/// to a better location.</span></span>
<span class="line" id="L597"><span class="tok-comment">/// The returned slice will have its pointer aligned at least to `new_alignment` bytes.</span></span>
<span class="line" id="L598"><span class="tok-comment">///</span></span>
<span class="line" id="L599"><span class="tok-comment">/// This function allows a runtime `alignment` value. Callers should generally prefer</span></span>
<span class="line" id="L600"><span class="tok-comment">/// to call the `realloc*` functions.</span></span>
<span class="line" id="L601"><span class="tok-comment">///</span></span>
<span class="line" id="L602"><span class="tok-comment">/// If the size/alignment is greater than the previous allocation, and the requested new</span></span>
<span class="line" id="L603"><span class="tok-comment">/// allocation could not be granted this function returns `error.OutOfMemory`.</span></span>
<span class="line" id="L604"><span class="tok-comment">/// When the size/alignment is less than or equal to the previous allocation,</span></span>
<span class="line" id="L605"><span class="tok-comment">/// this function returns `error.OutOfMemory` when the allocator decides the client</span></span>
<span class="line" id="L606"><span class="tok-comment">/// would be better off keeping the extra alignment/size.</span></span>
<span class="line" id="L607"><span class="tok-comment">/// Clients will call `resizeFn` when they require the allocator to track a new alignment/size,</span></span>
<span class="line" id="L608"><span class="tok-comment">/// and so this function should only return success when the allocator considers</span></span>
<span class="line" id="L609"><span class="tok-comment">/// the reallocation desirable from the allocator's perspective.</span></span>
<span class="line" id="L610"><span class="tok-comment">///</span></span>
<span class="line" id="L611"><span class="tok-comment">/// As an example, `std.ArrayList` tracks a &quot;capacity&quot;, and therefore can handle</span></span>
<span class="line" id="L612"><span class="tok-comment">/// reallocation failure, even when `new_n` &lt;= `old_mem.len`. A `FixedBufferAllocator`</span></span>
<span class="line" id="L613"><span class="tok-comment">/// would always return `error.OutOfMemory` for `reallocFn` when the size/alignment</span></span>
<span class="line" id="L614"><span class="tok-comment">/// is less than or equal to the old allocation, because it cannot reclaim the memory,</span></span>
<span class="line" id="L615"><span class="tok-comment">/// and thus the `std.ArrayList` would be better off retaining its capacity.</span></span>
<span class="line" id="L616"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">reallocBytes</span>(</span>
<span class="line" id="L617">    self: Allocator,</span>
<span class="line" id="L618">    <span class="tok-comment">/// Must be the same as what was returned from most recent call to `allocFn` or `resizeFn`.</span></span>
<span class="line" id="L619">    <span class="tok-comment">/// If `old_mem.len == 0` then this is a new allocation and `new_byte_count` must be &gt;= 1.</span></span>
<span class="line" id="L620">    old_mem: []<span class="tok-type">u8</span>,</span>
<span class="line" id="L621">    <span class="tok-comment">/// If `old_mem.len == 0` then this is `undefined`, otherwise:</span></span>
<span class="line" id="L622">    <span class="tok-comment">/// Must be the same as what was passed to `allocFn`.</span></span>
<span class="line" id="L623">    <span class="tok-comment">/// Must be &gt;= 1.</span></span>
<span class="line" id="L624">    <span class="tok-comment">/// Must be a power of 2.</span></span>
<span class="line" id="L625">    old_alignment: <span class="tok-type">u29</span>,</span>
<span class="line" id="L626">    <span class="tok-comment">/// If `new_byte_count` is 0 then this is a free and it is required that `old_mem.len != 0`.</span></span>
<span class="line" id="L627">    new_byte_count: <span class="tok-type">usize</span>,</span>
<span class="line" id="L628">    <span class="tok-comment">/// Must be &gt;= 1.</span></span>
<span class="line" id="L629">    <span class="tok-comment">/// Must be a power of 2.</span></span>
<span class="line" id="L630">    <span class="tok-comment">/// Returned slice's pointer will have this alignment.</span></span>
<span class="line" id="L631">    new_alignment: <span class="tok-type">u29</span>,</span>
<span class="line" id="L632">    <span class="tok-comment">/// 0 indicates the length of the slice returned MUST match `new_byte_count` exactly</span></span>
<span class="line" id="L633">    <span class="tok-comment">/// non-zero means the length of the returned slice must be aligned by `len_align`</span></span>
<span class="line" id="L634">    <span class="tok-comment">/// `new_byte_count` must be aligned by `len_align`</span></span>
<span class="line" id="L635">    len_align: <span class="tok-type">u29</span>,</span>
<span class="line" id="L636">    return_address: <span class="tok-type">usize</span>,</span>
<span class="line" id="L637">) Error![]<span class="tok-type">u8</span> {</span>
<span class="line" id="L638">    <span class="tok-kw">if</span> (old_mem.len == <span class="tok-number">0</span>) {</span>
<span class="line" id="L639">        <span class="tok-kw">return</span> self.allocBytes(new_alignment, new_byte_count, len_align, return_address);</span>
<span class="line" id="L640">    }</span>
<span class="line" id="L641">    <span class="tok-kw">if</span> (new_byte_count == <span class="tok-number">0</span>) {</span>
<span class="line" id="L642">        <span class="tok-comment">// TODO https://github.com/ziglang/zig/issues/4298</span>
</span>
<span class="line" id="L643">        <span class="tok-builtin">@memset</span>(old_mem.ptr, <span class="tok-null">undefined</span>, old_mem.len);</span>
<span class="line" id="L644">        self.rawFree(old_mem, old_alignment, return_address);</span>
<span class="line" id="L645">        <span class="tok-kw">return</span> &amp;[<span class="tok-number">0</span>]<span class="tok-type">u8</span>{};</span>
<span class="line" id="L646">    }</span>
<span class="line" id="L647"></span>
<span class="line" id="L648">    <span class="tok-kw">if</span> (mem.isAligned(<span class="tok-builtin">@ptrToInt</span>(old_mem.ptr), new_alignment)) {</span>
<span class="line" id="L649">        <span class="tok-kw">if</span> (new_byte_count &lt;= old_mem.len) {</span>
<span class="line" id="L650">            <span class="tok-kw">const</span> shrunk_len = self.shrinkBytes(old_mem, old_alignment, new_byte_count, len_align, return_address);</span>
<span class="line" id="L651">            <span class="tok-kw">return</span> old_mem.ptr[<span class="tok-number">0</span>..shrunk_len];</span>
<span class="line" id="L652">        }</span>
<span class="line" id="L653"></span>
<span class="line" id="L654">        <span class="tok-kw">if</span> (self.rawResize(old_mem, old_alignment, new_byte_count, len_align, return_address)) |resized_len| {</span>
<span class="line" id="L655">            assert(resized_len &gt;= new_byte_count);</span>
<span class="line" id="L656">            <span class="tok-comment">// TODO: https://github.com/ziglang/zig/issues/4298</span>
</span>
<span class="line" id="L657">            <span class="tok-builtin">@memset</span>(old_mem.ptr + new_byte_count, <span class="tok-null">undefined</span>, resized_len - new_byte_count);</span>
<span class="line" id="L658">            <span class="tok-kw">return</span> old_mem.ptr[<span class="tok-number">0</span>..resized_len];</span>
<span class="line" id="L659">        }</span>
<span class="line" id="L660">    }</span>
<span class="line" id="L661"></span>
<span class="line" id="L662">    <span class="tok-kw">if</span> (new_byte_count &lt;= old_mem.len <span class="tok-kw">and</span> new_alignment &lt;= old_alignment) {</span>
<span class="line" id="L663">        <span class="tok-kw">return</span> <span class="tok-kw">error</span>.OutOfMemory;</span>
<span class="line" id="L664">    }</span>
<span class="line" id="L665"></span>
<span class="line" id="L666">    <span class="tok-kw">const</span> new_mem = <span class="tok-kw">try</span> self.rawAlloc(new_byte_count, new_alignment, len_align, return_address);</span>
<span class="line" id="L667">    <span class="tok-builtin">@memcpy</span>(new_mem.ptr, old_mem.ptr, math.min(new_byte_count, old_mem.len));</span>
<span class="line" id="L668"></span>
<span class="line" id="L669">    <span class="tok-comment">// TODO https://github.com/ziglang/zig/issues/4298</span>
</span>
<span class="line" id="L670">    <span class="tok-builtin">@memset</span>(old_mem.ptr, <span class="tok-null">undefined</span>, old_mem.len);</span>
<span class="line" id="L671">    self.rawFree(old_mem, old_alignment, return_address);</span>
<span class="line" id="L672"></span>
<span class="line" id="L673">    <span class="tok-kw">return</span> new_mem;</span>
<span class="line" id="L674">}</span>
<span class="line" id="L675"></span>
<span class="line" id="L676"><span class="tok-kw">test</span> <span class="tok-str">&quot;reallocBytes&quot;</span> {</span>
<span class="line" id="L677">    <span class="tok-kw">var</span> new_mem: []<span class="tok-type">u8</span> = &amp;.{};</span>
<span class="line" id="L678"></span>
<span class="line" id="L679">    <span class="tok-kw">var</span> new_byte_count: <span class="tok-type">usize</span> = <span class="tok-number">16</span>;</span>
<span class="line" id="L680">    <span class="tok-kw">var</span> runtime_alignment: <span class="tok-type">u29</span> = <span class="tok-number">4</span>;</span>
<span class="line" id="L681"></span>
<span class="line" id="L682">    <span class="tok-comment">// `new_mem.len == 0`, this is a new allocation</span>
</span>
<span class="line" id="L683">    {</span>
<span class="line" id="L684">        new_mem = <span class="tok-kw">try</span> std.testing.allocator.reallocBytes(new_mem, <span class="tok-null">undefined</span>, new_byte_count, runtime_alignment, <span class="tok-number">0</span>, <span class="tok-builtin">@returnAddress</span>());</span>
<span class="line" id="L685">        <span class="tok-kw">try</span> std.testing.expectEqual(new_byte_count, new_mem.len);</span>
<span class="line" id="L686">        <span class="tok-kw">try</span> std.testing.expect(mem.isAligned(<span class="tok-builtin">@ptrToInt</span>(new_mem.ptr), runtime_alignment));</span>
<span class="line" id="L687">    }</span>
<span class="line" id="L688"></span>
<span class="line" id="L689">    <span class="tok-comment">// `new_byte_count &lt; new_mem.len`, this is a shrink, alignment is unmodified</span>
</span>
<span class="line" id="L690">    new_byte_count = <span class="tok-number">14</span>;</span>
<span class="line" id="L691">    {</span>
<span class="line" id="L692">        new_mem = <span class="tok-kw">try</span> std.testing.allocator.reallocBytes(new_mem, runtime_alignment, new_byte_count, runtime_alignment, <span class="tok-number">0</span>, <span class="tok-builtin">@returnAddress</span>());</span>
<span class="line" id="L693">        <span class="tok-kw">try</span> std.testing.expectEqual(new_byte_count, new_mem.len);</span>
<span class="line" id="L694">        <span class="tok-kw">try</span> std.testing.expect(mem.isAligned(<span class="tok-builtin">@ptrToInt</span>(new_mem.ptr), runtime_alignment));</span>
<span class="line" id="L695">    }</span>
<span class="line" id="L696"></span>
<span class="line" id="L697">    <span class="tok-comment">// `new_byte_count &lt; new_mem.len`, this is a shrink, alignment is decreased from 4 to 2</span>
</span>
<span class="line" id="L698">    runtime_alignment = <span class="tok-number">2</span>;</span>
<span class="line" id="L699">    new_byte_count = <span class="tok-number">12</span>;</span>
<span class="line" id="L700">    {</span>
<span class="line" id="L701">        new_mem = <span class="tok-kw">try</span> std.testing.allocator.reallocBytes(new_mem, <span class="tok-number">4</span>, new_byte_count, runtime_alignment, <span class="tok-number">0</span>, <span class="tok-builtin">@returnAddress</span>());</span>
<span class="line" id="L702">        <span class="tok-kw">try</span> std.testing.expectEqual(new_byte_count, new_mem.len);</span>
<span class="line" id="L703">        <span class="tok-kw">try</span> std.testing.expect(mem.isAligned(<span class="tok-builtin">@ptrToInt</span>(new_mem.ptr), runtime_alignment));</span>
<span class="line" id="L704">    }</span>
<span class="line" id="L705"></span>
<span class="line" id="L706">    <span class="tok-comment">// `new_byte_count &gt; new_mem.len`, this is a growth, alignment is increased from 2 to 8</span>
</span>
<span class="line" id="L707">    runtime_alignment = <span class="tok-number">8</span>;</span>
<span class="line" id="L708">    new_byte_count = <span class="tok-number">32</span>;</span>
<span class="line" id="L709">    {</span>
<span class="line" id="L710">        new_mem = <span class="tok-kw">try</span> std.testing.allocator.reallocBytes(new_mem, <span class="tok-number">2</span>, new_byte_count, runtime_alignment, <span class="tok-number">0</span>, <span class="tok-builtin">@returnAddress</span>());</span>
<span class="line" id="L711">        <span class="tok-kw">try</span> std.testing.expectEqual(new_byte_count, new_mem.len);</span>
<span class="line" id="L712">        <span class="tok-kw">try</span> std.testing.expect(mem.isAligned(<span class="tok-builtin">@ptrToInt</span>(new_mem.ptr), runtime_alignment));</span>
<span class="line" id="L713">    }</span>
<span class="line" id="L714"></span>
<span class="line" id="L715">    <span class="tok-comment">// `new_byte_count == 0`, this is a free</span>
</span>
<span class="line" id="L716">    new_byte_count = <span class="tok-number">0</span>;</span>
<span class="line" id="L717">    {</span>
<span class="line" id="L718">        new_mem = <span class="tok-kw">try</span> std.testing.allocator.reallocBytes(new_mem, runtime_alignment, new_byte_count, runtime_alignment, <span class="tok-number">0</span>, <span class="tok-builtin">@returnAddress</span>());</span>
<span class="line" id="L719">        <span class="tok-kw">try</span> std.testing.expectEqual(new_byte_count, new_mem.len);</span>
<span class="line" id="L720">    }</span>
<span class="line" id="L721">}</span>
<span class="line" id="L722"></span>
<span class="line" id="L723"><span class="tok-comment">/// Call `vtable.resize`, but caller guarantees that `new_len` &lt;= `buf.len` meaning</span></span>
<span class="line" id="L724"><span class="tok-comment">/// than a `null` return value should be impossible.</span></span>
<span class="line" id="L725"><span class="tok-comment">/// This function allows a runtime `buf_align` value. Callers should generally prefer</span></span>
<span class="line" id="L726"><span class="tok-comment">/// to call `shrink`.</span></span>
<span class="line" id="L727"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">shrinkBytes</span>(</span>
<span class="line" id="L728">    self: Allocator,</span>
<span class="line" id="L729">    <span class="tok-comment">/// Must be the same as what was returned from most recent call to `allocFn` or `resizeFn`.</span></span>
<span class="line" id="L730">    buf: []<span class="tok-type">u8</span>,</span>
<span class="line" id="L731">    <span class="tok-comment">/// Must be the same as what was passed to `allocFn`.</span></span>
<span class="line" id="L732">    <span class="tok-comment">/// Must be &gt;= 1.</span></span>
<span class="line" id="L733">    <span class="tok-comment">/// Must be a power of 2.</span></span>
<span class="line" id="L734">    buf_align: <span class="tok-type">u29</span>,</span>
<span class="line" id="L735">    <span class="tok-comment">/// Must be &gt;= 1.</span></span>
<span class="line" id="L736">    new_len: <span class="tok-type">usize</span>,</span>
<span class="line" id="L737">    <span class="tok-comment">/// 0 indicates the length of the slice returned MUST match `new_len` exactly</span></span>
<span class="line" id="L738">    <span class="tok-comment">/// non-zero means the length of the returned slice must be aligned by `len_align`</span></span>
<span class="line" id="L739">    <span class="tok-comment">/// `new_len` must be aligned by `len_align`</span></span>
<span class="line" id="L740">    len_align: <span class="tok-type">u29</span>,</span>
<span class="line" id="L741">    return_address: <span class="tok-type">usize</span>,</span>
<span class="line" id="L742">) <span class="tok-type">usize</span> {</span>
<span class="line" id="L743">    assert(new_len &lt;= buf.len);</span>
<span class="line" id="L744">    <span class="tok-kw">return</span> self.rawResize(buf, buf_align, new_len, len_align, return_address) <span class="tok-kw">orelse</span> <span class="tok-kw">unreachable</span>;</span>
<span class="line" id="L745">}</span>
<span class="line" id="L746"></span>
</code></pre></body>
</html>