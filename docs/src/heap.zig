<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">    <title>heap.zig - source view</title>
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
<span class="line" id="L3"><span class="tok-kw">const</span> root = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;root&quot;</span>);</span>
<span class="line" id="L4"><span class="tok-kw">const</span> debug = std.debug;</span>
<span class="line" id="L5"><span class="tok-kw">const</span> assert = debug.assert;</span>
<span class="line" id="L6"><span class="tok-kw">const</span> testing = std.testing;</span>
<span class="line" id="L7"><span class="tok-kw">const</span> mem = std.mem;</span>
<span class="line" id="L8"><span class="tok-kw">const</span> os = std.os;</span>
<span class="line" id="L9"><span class="tok-kw">const</span> c = std.c;</span>
<span class="line" id="L10"><span class="tok-kw">const</span> maxInt = std.math.maxInt;</span>
<span class="line" id="L11"></span>
<span class="line" id="L12"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> LoggingAllocator = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;heap/logging_allocator.zig&quot;</span>).LoggingAllocator;</span>
<span class="line" id="L13"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> loggingAllocator = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;heap/logging_allocator.zig&quot;</span>).loggingAllocator;</span>
<span class="line" id="L14"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> ScopedLoggingAllocator = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;heap/logging_allocator.zig&quot;</span>).ScopedLoggingAllocator;</span>
<span class="line" id="L15"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> LogToWriterAllocator = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;heap/log_to_writer_allocator.zig&quot;</span>).LogToWriterAllocator;</span>
<span class="line" id="L16"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> logToWriterAllocator = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;heap/log_to_writer_allocator.zig&quot;</span>).logToWriterAllocator;</span>
<span class="line" id="L17"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> ArenaAllocator = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;heap/arena_allocator.zig&quot;</span>).ArenaAllocator;</span>
<span class="line" id="L18"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> GeneralPurposeAllocator = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;heap/general_purpose_allocator.zig&quot;</span>).GeneralPurposeAllocator;</span>
<span class="line" id="L19"></span>
<span class="line" id="L20"><span class="tok-kw">const</span> Allocator = mem.Allocator;</span>
<span class="line" id="L21"></span>
<span class="line" id="L22"><span class="tok-kw">const</span> CAllocator = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L23">    <span class="tok-kw">comptime</span> {</span>
<span class="line" id="L24">        <span class="tok-kw">if</span> (!builtin.link_libc) {</span>
<span class="line" id="L25">            <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;C allocator is only available when linking against libc&quot;</span>);</span>
<span class="line" id="L26">        }</span>
<span class="line" id="L27">    }</span>
<span class="line" id="L28"></span>
<span class="line" id="L29">    <span class="tok-kw">usingnamespace</span> <span class="tok-kw">if</span> (<span class="tok-builtin">@hasDecl</span>(c, <span class="tok-str">&quot;malloc_size&quot;</span>))</span>
<span class="line" id="L30">        <span class="tok-kw">struct</span> {</span>
<span class="line" id="L31">            <span class="tok-kw">pub</span> <span class="tok-kw">const</span> supports_malloc_size = <span class="tok-null">true</span>;</span>
<span class="line" id="L32">            <span class="tok-kw">pub</span> <span class="tok-kw">const</span> malloc_size = c.malloc_size;</span>
<span class="line" id="L33">        }</span>
<span class="line" id="L34">    <span class="tok-kw">else</span> <span class="tok-kw">if</span> (<span class="tok-builtin">@hasDecl</span>(c, <span class="tok-str">&quot;malloc_usable_size&quot;</span>))</span>
<span class="line" id="L35">        <span class="tok-kw">struct</span> {</span>
<span class="line" id="L36">            <span class="tok-kw">pub</span> <span class="tok-kw">const</span> supports_malloc_size = <span class="tok-null">true</span>;</span>
<span class="line" id="L37">            <span class="tok-kw">pub</span> <span class="tok-kw">const</span> malloc_size = c.malloc_usable_size;</span>
<span class="line" id="L38">        }</span>
<span class="line" id="L39">    <span class="tok-kw">else</span> <span class="tok-kw">if</span> (<span class="tok-builtin">@hasDecl</span>(c, <span class="tok-str">&quot;_msize&quot;</span>))</span>
<span class="line" id="L40">        <span class="tok-kw">struct</span> {</span>
<span class="line" id="L41">            <span class="tok-kw">pub</span> <span class="tok-kw">const</span> supports_malloc_size = <span class="tok-null">true</span>;</span>
<span class="line" id="L42">            <span class="tok-kw">pub</span> <span class="tok-kw">const</span> malloc_size = c._msize;</span>
<span class="line" id="L43">        }</span>
<span class="line" id="L44">    <span class="tok-kw">else</span></span>
<span class="line" id="L45">        <span class="tok-kw">struct</span> {</span>
<span class="line" id="L46">            <span class="tok-kw">pub</span> <span class="tok-kw">const</span> supports_malloc_size = <span class="tok-null">false</span>;</span>
<span class="line" id="L47">        };</span>
<span class="line" id="L48"></span>
<span class="line" id="L49">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> supports_posix_memalign = <span class="tok-builtin">@hasDecl</span>(c, <span class="tok-str">&quot;posix_memalign&quot;</span>);</span>
<span class="line" id="L50"></span>
<span class="line" id="L51">    <span class="tok-kw">fn</span> <span class="tok-fn">getHeader</span>(ptr: [*]<span class="tok-type">u8</span>) *[*]<span class="tok-type">u8</span> {</span>
<span class="line" id="L52">        <span class="tok-kw">return</span> <span class="tok-builtin">@intToPtr</span>(*[*]<span class="tok-type">u8</span>, <span class="tok-builtin">@ptrToInt</span>(ptr) - <span class="tok-builtin">@sizeOf</span>(<span class="tok-type">usize</span>));</span>
<span class="line" id="L53">    }</span>
<span class="line" id="L54"></span>
<span class="line" id="L55">    <span class="tok-kw">fn</span> <span class="tok-fn">alignedAlloc</span>(len: <span class="tok-type">usize</span>, alignment: <span class="tok-type">usize</span>) ?[*]<span class="tok-type">u8</span> {</span>
<span class="line" id="L56">        <span class="tok-kw">if</span> (supports_posix_memalign) {</span>
<span class="line" id="L57">            <span class="tok-comment">// The posix_memalign only accepts alignment values that are a</span>
</span>
<span class="line" id="L58">            <span class="tok-comment">// multiple of the pointer size</span>
</span>
<span class="line" id="L59">            <span class="tok-kw">const</span> eff_alignment = std.math.max(alignment, <span class="tok-builtin">@sizeOf</span>(<span class="tok-type">usize</span>));</span>
<span class="line" id="L60"></span>
<span class="line" id="L61">            <span class="tok-kw">var</span> aligned_ptr: ?*<span class="tok-type">anyopaque</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L62">            <span class="tok-kw">if</span> (c.posix_memalign(&amp;aligned_ptr, eff_alignment, len) != <span class="tok-number">0</span>)</span>
<span class="line" id="L63">                <span class="tok-kw">return</span> <span class="tok-null">null</span>;</span>
<span class="line" id="L64"></span>
<span class="line" id="L65">            <span class="tok-kw">return</span> <span class="tok-builtin">@ptrCast</span>([*]<span class="tok-type">u8</span>, aligned_ptr);</span>
<span class="line" id="L66">        }</span>
<span class="line" id="L67"></span>
<span class="line" id="L68">        <span class="tok-comment">// Thin wrapper around regular malloc, overallocate to account for</span>
</span>
<span class="line" id="L69">        <span class="tok-comment">// alignment padding and store the orignal malloc()'ed pointer before</span>
</span>
<span class="line" id="L70">        <span class="tok-comment">// the aligned address.</span>
</span>
<span class="line" id="L71">        <span class="tok-kw">var</span> unaligned_ptr = <span class="tok-builtin">@ptrCast</span>([*]<span class="tok-type">u8</span>, c.malloc(len + alignment - <span class="tok-number">1</span> + <span class="tok-builtin">@sizeOf</span>(<span class="tok-type">usize</span>)) <span class="tok-kw">orelse</span> <span class="tok-kw">return</span> <span class="tok-null">null</span>);</span>
<span class="line" id="L72">        <span class="tok-kw">const</span> unaligned_addr = <span class="tok-builtin">@ptrToInt</span>(unaligned_ptr);</span>
<span class="line" id="L73">        <span class="tok-kw">const</span> aligned_addr = mem.alignForward(unaligned_addr + <span class="tok-builtin">@sizeOf</span>(<span class="tok-type">usize</span>), alignment);</span>
<span class="line" id="L74">        <span class="tok-kw">var</span> aligned_ptr = unaligned_ptr + (aligned_addr - unaligned_addr);</span>
<span class="line" id="L75">        getHeader(aligned_ptr).* = unaligned_ptr;</span>
<span class="line" id="L76"></span>
<span class="line" id="L77">        <span class="tok-kw">return</span> aligned_ptr;</span>
<span class="line" id="L78">    }</span>
<span class="line" id="L79"></span>
<span class="line" id="L80">    <span class="tok-kw">fn</span> <span class="tok-fn">alignedFree</span>(ptr: [*]<span class="tok-type">u8</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L81">        <span class="tok-kw">if</span> (supports_posix_memalign) {</span>
<span class="line" id="L82">            <span class="tok-kw">return</span> c.free(ptr);</span>
<span class="line" id="L83">        }</span>
<span class="line" id="L84"></span>
<span class="line" id="L85">        <span class="tok-kw">const</span> unaligned_ptr = getHeader(ptr).*;</span>
<span class="line" id="L86">        c.free(unaligned_ptr);</span>
<span class="line" id="L87">    }</span>
<span class="line" id="L88"></span>
<span class="line" id="L89">    <span class="tok-kw">fn</span> <span class="tok-fn">alignedAllocSize</span>(ptr: [*]<span class="tok-type">u8</span>) <span class="tok-type">usize</span> {</span>
<span class="line" id="L90">        <span class="tok-kw">if</span> (supports_posix_memalign) {</span>
<span class="line" id="L91">            <span class="tok-kw">return</span> CAllocator.malloc_size(ptr);</span>
<span class="line" id="L92">        }</span>
<span class="line" id="L93"></span>
<span class="line" id="L94">        <span class="tok-kw">const</span> unaligned_ptr = getHeader(ptr).*;</span>
<span class="line" id="L95">        <span class="tok-kw">const</span> delta = <span class="tok-builtin">@ptrToInt</span>(ptr) - <span class="tok-builtin">@ptrToInt</span>(unaligned_ptr);</span>
<span class="line" id="L96">        <span class="tok-kw">return</span> CAllocator.malloc_size(unaligned_ptr) - delta;</span>
<span class="line" id="L97">    }</span>
<span class="line" id="L98"></span>
<span class="line" id="L99">    <span class="tok-kw">fn</span> <span class="tok-fn">alloc</span>(</span>
<span class="line" id="L100">        _: *<span class="tok-type">anyopaque</span>,</span>
<span class="line" id="L101">        len: <span class="tok-type">usize</span>,</span>
<span class="line" id="L102">        alignment: <span class="tok-type">u29</span>,</span>
<span class="line" id="L103">        len_align: <span class="tok-type">u29</span>,</span>
<span class="line" id="L104">        return_address: <span class="tok-type">usize</span>,</span>
<span class="line" id="L105">    ) <span class="tok-kw">error</span>{OutOfMemory}![]<span class="tok-type">u8</span> {</span>
<span class="line" id="L106">        _ = return_address;</span>
<span class="line" id="L107">        assert(len &gt; <span class="tok-number">0</span>);</span>
<span class="line" id="L108">        assert(std.math.isPowerOfTwo(alignment));</span>
<span class="line" id="L109"></span>
<span class="line" id="L110">        <span class="tok-kw">var</span> ptr = alignedAlloc(len, alignment) <span class="tok-kw">orelse</span> <span class="tok-kw">return</span> <span class="tok-kw">error</span>.OutOfMemory;</span>
<span class="line" id="L111">        <span class="tok-kw">if</span> (len_align == <span class="tok-number">0</span>) {</span>
<span class="line" id="L112">            <span class="tok-kw">return</span> ptr[<span class="tok-number">0</span>..len];</span>
<span class="line" id="L113">        }</span>
<span class="line" id="L114">        <span class="tok-kw">const</span> full_len = init: {</span>
<span class="line" id="L115">            <span class="tok-kw">if</span> (CAllocator.supports_malloc_size) {</span>
<span class="line" id="L116">                <span class="tok-kw">const</span> s = alignedAllocSize(ptr);</span>
<span class="line" id="L117">                assert(s &gt;= len);</span>
<span class="line" id="L118">                <span class="tok-kw">break</span> :init s;</span>
<span class="line" id="L119">            }</span>
<span class="line" id="L120">            <span class="tok-kw">break</span> :init len;</span>
<span class="line" id="L121">        };</span>
<span class="line" id="L122">        <span class="tok-kw">return</span> ptr[<span class="tok-number">0</span>..mem.alignBackwardAnyAlign(full_len, len_align)];</span>
<span class="line" id="L123">    }</span>
<span class="line" id="L124"></span>
<span class="line" id="L125">    <span class="tok-kw">fn</span> <span class="tok-fn">resize</span>(</span>
<span class="line" id="L126">        _: *<span class="tok-type">anyopaque</span>,</span>
<span class="line" id="L127">        buf: []<span class="tok-type">u8</span>,</span>
<span class="line" id="L128">        buf_align: <span class="tok-type">u29</span>,</span>
<span class="line" id="L129">        new_len: <span class="tok-type">usize</span>,</span>
<span class="line" id="L130">        len_align: <span class="tok-type">u29</span>,</span>
<span class="line" id="L131">        return_address: <span class="tok-type">usize</span>,</span>
<span class="line" id="L132">    ) ?<span class="tok-type">usize</span> {</span>
<span class="line" id="L133">        _ = buf_align;</span>
<span class="line" id="L134">        _ = return_address;</span>
<span class="line" id="L135">        <span class="tok-kw">if</span> (new_len &lt;= buf.len) {</span>
<span class="line" id="L136">            <span class="tok-kw">return</span> mem.alignAllocLen(buf.len, new_len, len_align);</span>
<span class="line" id="L137">        }</span>
<span class="line" id="L138">        <span class="tok-kw">if</span> (CAllocator.supports_malloc_size) {</span>
<span class="line" id="L139">            <span class="tok-kw">const</span> full_len = alignedAllocSize(buf.ptr);</span>
<span class="line" id="L140">            <span class="tok-kw">if</span> (new_len &lt;= full_len) {</span>
<span class="line" id="L141">                <span class="tok-kw">return</span> mem.alignAllocLen(full_len, new_len, len_align);</span>
<span class="line" id="L142">            }</span>
<span class="line" id="L143">        }</span>
<span class="line" id="L144">        <span class="tok-kw">return</span> <span class="tok-null">null</span>;</span>
<span class="line" id="L145">    }</span>
<span class="line" id="L146"></span>
<span class="line" id="L147">    <span class="tok-kw">fn</span> <span class="tok-fn">free</span>(</span>
<span class="line" id="L148">        _: *<span class="tok-type">anyopaque</span>,</span>
<span class="line" id="L149">        buf: []<span class="tok-type">u8</span>,</span>
<span class="line" id="L150">        buf_align: <span class="tok-type">u29</span>,</span>
<span class="line" id="L151">        return_address: <span class="tok-type">usize</span>,</span>
<span class="line" id="L152">    ) <span class="tok-type">void</span> {</span>
<span class="line" id="L153">        _ = buf_align;</span>
<span class="line" id="L154">        _ = return_address;</span>
<span class="line" id="L155">        alignedFree(buf.ptr);</span>
<span class="line" id="L156">    }</span>
<span class="line" id="L157">};</span>
<span class="line" id="L158"></span>
<span class="line" id="L159"><span class="tok-comment">/// Supports the full Allocator interface, including alignment, and exploiting</span></span>
<span class="line" id="L160"><span class="tok-comment">/// `malloc_usable_size` if available. For an allocator that directly calls</span></span>
<span class="line" id="L161"><span class="tok-comment">/// `malloc`/`free`, see `raw_c_allocator`.</span></span>
<span class="line" id="L162"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> c_allocator = Allocator{</span>
<span class="line" id="L163">    .ptr = <span class="tok-null">undefined</span>,</span>
<span class="line" id="L164">    .vtable = &amp;c_allocator_vtable,</span>
<span class="line" id="L165">};</span>
<span class="line" id="L166"><span class="tok-kw">const</span> c_allocator_vtable = Allocator.VTable{</span>
<span class="line" id="L167">    .alloc = CAllocator.alloc,</span>
<span class="line" id="L168">    .resize = CAllocator.resize,</span>
<span class="line" id="L169">    .free = CAllocator.free,</span>
<span class="line" id="L170">};</span>
<span class="line" id="L171"></span>
<span class="line" id="L172"><span class="tok-comment">/// Asserts allocations are within `@alignOf(std.c.max_align_t)` and directly calls</span></span>
<span class="line" id="L173"><span class="tok-comment">/// `malloc`/`free`. Does not attempt to utilize `malloc_usable_size`.</span></span>
<span class="line" id="L174"><span class="tok-comment">/// This allocator is safe to use as the backing allocator with</span></span>
<span class="line" id="L175"><span class="tok-comment">/// `ArenaAllocator` for example and is more optimal in such a case</span></span>
<span class="line" id="L176"><span class="tok-comment">/// than `c_allocator`.</span></span>
<span class="line" id="L177"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> raw_c_allocator = Allocator{</span>
<span class="line" id="L178">    .ptr = <span class="tok-null">undefined</span>,</span>
<span class="line" id="L179">    .vtable = &amp;raw_c_allocator_vtable,</span>
<span class="line" id="L180">};</span>
<span class="line" id="L181"><span class="tok-kw">const</span> raw_c_allocator_vtable = Allocator.VTable{</span>
<span class="line" id="L182">    .alloc = rawCAlloc,</span>
<span class="line" id="L183">    .resize = rawCResize,</span>
<span class="line" id="L184">    .free = rawCFree,</span>
<span class="line" id="L185">};</span>
<span class="line" id="L186"></span>
<span class="line" id="L187"><span class="tok-kw">fn</span> <span class="tok-fn">rawCAlloc</span>(</span>
<span class="line" id="L188">    _: *<span class="tok-type">anyopaque</span>,</span>
<span class="line" id="L189">    len: <span class="tok-type">usize</span>,</span>
<span class="line" id="L190">    ptr_align: <span class="tok-type">u29</span>,</span>
<span class="line" id="L191">    len_align: <span class="tok-type">u29</span>,</span>
<span class="line" id="L192">    ret_addr: <span class="tok-type">usize</span>,</span>
<span class="line" id="L193">) Allocator.Error![]<span class="tok-type">u8</span> {</span>
<span class="line" id="L194">    _ = len_align;</span>
<span class="line" id="L195">    _ = ret_addr;</span>
<span class="line" id="L196">    assert(ptr_align &lt;= <span class="tok-builtin">@alignOf</span>(std.c.max_align_t));</span>
<span class="line" id="L197">    <span class="tok-kw">const</span> ptr = <span class="tok-builtin">@ptrCast</span>([*]<span class="tok-type">u8</span>, c.malloc(len) <span class="tok-kw">orelse</span> <span class="tok-kw">return</span> <span class="tok-kw">error</span>.OutOfMemory);</span>
<span class="line" id="L198">    <span class="tok-kw">return</span> ptr[<span class="tok-number">0</span>..len];</span>
<span class="line" id="L199">}</span>
<span class="line" id="L200"></span>
<span class="line" id="L201"><span class="tok-kw">fn</span> <span class="tok-fn">rawCResize</span>(</span>
<span class="line" id="L202">    _: *<span class="tok-type">anyopaque</span>,</span>
<span class="line" id="L203">    buf: []<span class="tok-type">u8</span>,</span>
<span class="line" id="L204">    old_align: <span class="tok-type">u29</span>,</span>
<span class="line" id="L205">    new_len: <span class="tok-type">usize</span>,</span>
<span class="line" id="L206">    len_align: <span class="tok-type">u29</span>,</span>
<span class="line" id="L207">    ret_addr: <span class="tok-type">usize</span>,</span>
<span class="line" id="L208">) ?<span class="tok-type">usize</span> {</span>
<span class="line" id="L209">    _ = old_align;</span>
<span class="line" id="L210">    _ = ret_addr;</span>
<span class="line" id="L211">    <span class="tok-kw">if</span> (new_len &lt;= buf.len) {</span>
<span class="line" id="L212">        <span class="tok-kw">return</span> mem.alignAllocLen(buf.len, new_len, len_align);</span>
<span class="line" id="L213">    }</span>
<span class="line" id="L214">    <span class="tok-kw">return</span> <span class="tok-null">null</span>;</span>
<span class="line" id="L215">}</span>
<span class="line" id="L216"></span>
<span class="line" id="L217"><span class="tok-kw">fn</span> <span class="tok-fn">rawCFree</span>(</span>
<span class="line" id="L218">    _: *<span class="tok-type">anyopaque</span>,</span>
<span class="line" id="L219">    buf: []<span class="tok-type">u8</span>,</span>
<span class="line" id="L220">    old_align: <span class="tok-type">u29</span>,</span>
<span class="line" id="L221">    ret_addr: <span class="tok-type">usize</span>,</span>
<span class="line" id="L222">) <span class="tok-type">void</span> {</span>
<span class="line" id="L223">    _ = old_align;</span>
<span class="line" id="L224">    _ = ret_addr;</span>
<span class="line" id="L225">    c.free(buf.ptr);</span>
<span class="line" id="L226">}</span>
<span class="line" id="L227"></span>
<span class="line" id="L228"><span class="tok-comment">/// This allocator makes a syscall directly for every allocation and free.</span></span>
<span class="line" id="L229"><span class="tok-comment">/// Thread-safe and lock-free.</span></span>
<span class="line" id="L230"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> page_allocator = <span class="tok-kw">if</span> (builtin.target.isWasm())</span>
<span class="line" id="L231">    Allocator{</span>
<span class="line" id="L232">        .ptr = <span class="tok-null">undefined</span>,</span>
<span class="line" id="L233">        .vtable = &amp;WasmPageAllocator.vtable,</span>
<span class="line" id="L234">    }</span>
<span class="line" id="L235"><span class="tok-kw">else</span> <span class="tok-kw">if</span> (builtin.target.os.tag == .freestanding)</span>
<span class="line" id="L236">    root.os.heap.page_allocator</span>
<span class="line" id="L237"><span class="tok-kw">else</span></span>
<span class="line" id="L238">    Allocator{</span>
<span class="line" id="L239">        .ptr = <span class="tok-null">undefined</span>,</span>
<span class="line" id="L240">        .vtable = &amp;PageAllocator.vtable,</span>
<span class="line" id="L241">    };</span>
<span class="line" id="L242"></span>
<span class="line" id="L243"><span class="tok-comment">/// Verifies that the adjusted length will still map to the full length</span></span>
<span class="line" id="L244"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">alignPageAllocLen</span>(full_len: <span class="tok-type">usize</span>, len: <span class="tok-type">usize</span>, len_align: <span class="tok-type">u29</span>) <span class="tok-type">usize</span> {</span>
<span class="line" id="L245">    <span class="tok-kw">const</span> aligned_len = mem.alignAllocLen(full_len, len, len_align);</span>
<span class="line" id="L246">    assert(mem.alignForward(aligned_len, mem.page_size) == full_len);</span>
<span class="line" id="L247">    <span class="tok-kw">return</span> aligned_len;</span>
<span class="line" id="L248">}</span>
<span class="line" id="L249"></span>
<span class="line" id="L250"><span class="tok-comment">/// TODO Utilize this on Windows.</span></span>
<span class="line" id="L251"><span class="tok-kw">pub</span> <span class="tok-kw">var</span> next_mmap_addr_hint: ?[*]<span class="tok-kw">align</span>(mem.page_size) <span class="tok-type">u8</span> = <span class="tok-null">null</span>;</span>
<span class="line" id="L252"></span>
<span class="line" id="L253"><span class="tok-kw">const</span> PageAllocator = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L254">    <span class="tok-kw">const</span> vtable = Allocator.VTable{</span>
<span class="line" id="L255">        .alloc = alloc,</span>
<span class="line" id="L256">        .resize = resize,</span>
<span class="line" id="L257">        .free = free,</span>
<span class="line" id="L258">    };</span>
<span class="line" id="L259"></span>
<span class="line" id="L260">    <span class="tok-kw">fn</span> <span class="tok-fn">alloc</span>(_: *<span class="tok-type">anyopaque</span>, n: <span class="tok-type">usize</span>, alignment: <span class="tok-type">u29</span>, len_align: <span class="tok-type">u29</span>, ra: <span class="tok-type">usize</span>) <span class="tok-kw">error</span>{OutOfMemory}![]<span class="tok-type">u8</span> {</span>
<span class="line" id="L261">        _ = ra;</span>
<span class="line" id="L262">        assert(n &gt; <span class="tok-number">0</span>);</span>
<span class="line" id="L263">        <span class="tok-kw">const</span> aligned_len = mem.alignForward(n, mem.page_size);</span>
<span class="line" id="L264"></span>
<span class="line" id="L265">        <span class="tok-kw">if</span> (builtin.os.tag == .windows) {</span>
<span class="line" id="L266">            <span class="tok-kw">const</span> w = os.windows;</span>
<span class="line" id="L267"></span>
<span class="line" id="L268">            <span class="tok-comment">// Although officially it's at least aligned to page boundary,</span>
</span>
<span class="line" id="L269">            <span class="tok-comment">// Windows is known to reserve pages on a 64K boundary. It's</span>
</span>
<span class="line" id="L270">            <span class="tok-comment">// even more likely that the requested alignment is &lt;= 64K than</span>
</span>
<span class="line" id="L271">            <span class="tok-comment">// 4K, so we're just allocating blindly and hoping for the best.</span>
</span>
<span class="line" id="L272">            <span class="tok-comment">// see https://devblogs.microsoft.com/oldnewthing/?p=42223</span>
</span>
<span class="line" id="L273">            <span class="tok-kw">const</span> addr = w.VirtualAlloc(</span>
<span class="line" id="L274">                <span class="tok-null">null</span>,</span>
<span class="line" id="L275">                aligned_len,</span>
<span class="line" id="L276">                w.MEM_COMMIT | w.MEM_RESERVE,</span>
<span class="line" id="L277">                w.PAGE_READWRITE,</span>
<span class="line" id="L278">            ) <span class="tok-kw">catch</span> <span class="tok-kw">return</span> <span class="tok-kw">error</span>.OutOfMemory;</span>
<span class="line" id="L279"></span>
<span class="line" id="L280">            <span class="tok-comment">// If the allocation is sufficiently aligned, use it.</span>
</span>
<span class="line" id="L281">            <span class="tok-kw">if</span> (mem.isAligned(<span class="tok-builtin">@ptrToInt</span>(addr), alignment)) {</span>
<span class="line" id="L282">                <span class="tok-kw">return</span> <span class="tok-builtin">@ptrCast</span>([*]<span class="tok-type">u8</span>, addr)[<span class="tok-number">0</span>..alignPageAllocLen(aligned_len, n, len_align)];</span>
<span class="line" id="L283">            }</span>
<span class="line" id="L284"></span>
<span class="line" id="L285">            <span class="tok-comment">// If it wasn't, actually do an explicitly aligned allocation.</span>
</span>
<span class="line" id="L286">            w.VirtualFree(addr, <span class="tok-number">0</span>, w.MEM_RELEASE);</span>
<span class="line" id="L287">            <span class="tok-kw">const</span> alloc_size = n + alignment - mem.page_size;</span>
<span class="line" id="L288"></span>
<span class="line" id="L289">            <span class="tok-kw">while</span> (<span class="tok-null">true</span>) {</span>
<span class="line" id="L290">                <span class="tok-comment">// Reserve a range of memory large enough to find a sufficiently</span>
</span>
<span class="line" id="L291">                <span class="tok-comment">// aligned address.</span>
</span>
<span class="line" id="L292">                <span class="tok-kw">const</span> reserved_addr = w.VirtualAlloc(</span>
<span class="line" id="L293">                    <span class="tok-null">null</span>,</span>
<span class="line" id="L294">                    alloc_size,</span>
<span class="line" id="L295">                    w.MEM_RESERVE,</span>
<span class="line" id="L296">                    w.PAGE_NOACCESS,</span>
<span class="line" id="L297">                ) <span class="tok-kw">catch</span> <span class="tok-kw">return</span> <span class="tok-kw">error</span>.OutOfMemory;</span>
<span class="line" id="L298">                <span class="tok-kw">const</span> aligned_addr = mem.alignForward(<span class="tok-builtin">@ptrToInt</span>(reserved_addr), alignment);</span>
<span class="line" id="L299"></span>
<span class="line" id="L300">                <span class="tok-comment">// Release the reserved pages (not actually used).</span>
</span>
<span class="line" id="L301">                w.VirtualFree(reserved_addr, <span class="tok-number">0</span>, w.MEM_RELEASE);</span>
<span class="line" id="L302"></span>
<span class="line" id="L303">                <span class="tok-comment">// At this point, it is possible that another thread has</span>
</span>
<span class="line" id="L304">                <span class="tok-comment">// obtained some memory space that will cause the next</span>
</span>
<span class="line" id="L305">                <span class="tok-comment">// VirtualAlloc call to fail. To handle this, we will retry</span>
</span>
<span class="line" id="L306">                <span class="tok-comment">// until it succeeds.</span>
</span>
<span class="line" id="L307">                <span class="tok-kw">const</span> ptr = w.VirtualAlloc(</span>
<span class="line" id="L308">                    <span class="tok-builtin">@intToPtr</span>(*<span class="tok-type">anyopaque</span>, aligned_addr),</span>
<span class="line" id="L309">                    aligned_len,</span>
<span class="line" id="L310">                    w.MEM_COMMIT | w.MEM_RESERVE,</span>
<span class="line" id="L311">                    w.PAGE_READWRITE,</span>
<span class="line" id="L312">                ) <span class="tok-kw">catch</span> <span class="tok-kw">continue</span>;</span>
<span class="line" id="L313"></span>
<span class="line" id="L314">                <span class="tok-kw">return</span> <span class="tok-builtin">@ptrCast</span>([*]<span class="tok-type">u8</span>, ptr)[<span class="tok-number">0</span>..alignPageAllocLen(aligned_len, n, len_align)];</span>
<span class="line" id="L315">            }</span>
<span class="line" id="L316">        }</span>
<span class="line" id="L317"></span>
<span class="line" id="L318">        <span class="tok-kw">const</span> max_drop_len = alignment - <span class="tok-builtin">@minimum</span>(alignment, mem.page_size);</span>
<span class="line" id="L319">        <span class="tok-kw">const</span> alloc_len = <span class="tok-kw">if</span> (max_drop_len &lt;= aligned_len - n)</span>
<span class="line" id="L320">            aligned_len</span>
<span class="line" id="L321">        <span class="tok-kw">else</span></span>
<span class="line" id="L322">            mem.alignForward(aligned_len + max_drop_len, mem.page_size);</span>
<span class="line" id="L323">        <span class="tok-kw">const</span> hint = <span class="tok-builtin">@atomicLoad</span>(<span class="tok-builtin">@TypeOf</span>(next_mmap_addr_hint), &amp;next_mmap_addr_hint, .Unordered);</span>
<span class="line" id="L324">        <span class="tok-kw">const</span> slice = os.mmap(</span>
<span class="line" id="L325">            hint,</span>
<span class="line" id="L326">            alloc_len,</span>
<span class="line" id="L327">            os.PROT.READ | os.PROT.WRITE,</span>
<span class="line" id="L328">            os.MAP.PRIVATE | os.MAP.ANONYMOUS,</span>
<span class="line" id="L329">            -<span class="tok-number">1</span>,</span>
<span class="line" id="L330">            <span class="tok-number">0</span>,</span>
<span class="line" id="L331">        ) <span class="tok-kw">catch</span> <span class="tok-kw">return</span> <span class="tok-kw">error</span>.OutOfMemory;</span>
<span class="line" id="L332">        assert(mem.isAligned(<span class="tok-builtin">@ptrToInt</span>(slice.ptr), mem.page_size));</span>
<span class="line" id="L333"></span>
<span class="line" id="L334">        <span class="tok-kw">const</span> result_ptr = mem.alignPointer(slice.ptr, alignment) <span class="tok-kw">orelse</span></span>
<span class="line" id="L335">            <span class="tok-kw">return</span> <span class="tok-kw">error</span>.OutOfMemory;</span>
<span class="line" id="L336"></span>
<span class="line" id="L337">        <span class="tok-comment">// Unmap the extra bytes that were only requested in order to guarantee</span>
</span>
<span class="line" id="L338">        <span class="tok-comment">// that the range of memory we were provided had a proper alignment in</span>
</span>
<span class="line" id="L339">        <span class="tok-comment">// it somewhere. The extra bytes could be at the beginning, or end, or both.</span>
</span>
<span class="line" id="L340">        <span class="tok-kw">const</span> drop_len = <span class="tok-builtin">@ptrToInt</span>(result_ptr) - <span class="tok-builtin">@ptrToInt</span>(slice.ptr);</span>
<span class="line" id="L341">        <span class="tok-kw">if</span> (drop_len != <span class="tok-number">0</span>) {</span>
<span class="line" id="L342">            os.munmap(slice[<span class="tok-number">0</span>..drop_len]);</span>
<span class="line" id="L343">        }</span>
<span class="line" id="L344"></span>
<span class="line" id="L345">        <span class="tok-comment">// Unmap extra pages</span>
</span>
<span class="line" id="L346">        <span class="tok-kw">const</span> aligned_buffer_len = alloc_len - drop_len;</span>
<span class="line" id="L347">        <span class="tok-kw">if</span> (aligned_buffer_len &gt; aligned_len) {</span>
<span class="line" id="L348">            os.munmap(<span class="tok-builtin">@alignCast</span>(mem.page_size, result_ptr[aligned_len..aligned_buffer_len]));</span>
<span class="line" id="L349">        }</span>
<span class="line" id="L350"></span>
<span class="line" id="L351">        <span class="tok-kw">const</span> new_hint = <span class="tok-builtin">@alignCast</span>(mem.page_size, result_ptr + aligned_len);</span>
<span class="line" id="L352">        _ = <span class="tok-builtin">@cmpxchgStrong</span>(<span class="tok-builtin">@TypeOf</span>(next_mmap_addr_hint), &amp;next_mmap_addr_hint, hint, new_hint, .Monotonic, .Monotonic);</span>
<span class="line" id="L353"></span>
<span class="line" id="L354">        <span class="tok-kw">return</span> result_ptr[<span class="tok-number">0</span>..alignPageAllocLen(aligned_len, n, len_align)];</span>
<span class="line" id="L355">    }</span>
<span class="line" id="L356"></span>
<span class="line" id="L357">    <span class="tok-kw">fn</span> <span class="tok-fn">resize</span>(</span>
<span class="line" id="L358">        _: *<span class="tok-type">anyopaque</span>,</span>
<span class="line" id="L359">        buf_unaligned: []<span class="tok-type">u8</span>,</span>
<span class="line" id="L360">        buf_align: <span class="tok-type">u29</span>,</span>
<span class="line" id="L361">        new_size: <span class="tok-type">usize</span>,</span>
<span class="line" id="L362">        len_align: <span class="tok-type">u29</span>,</span>
<span class="line" id="L363">        return_address: <span class="tok-type">usize</span>,</span>
<span class="line" id="L364">    ) ?<span class="tok-type">usize</span> {</span>
<span class="line" id="L365">        _ = buf_align;</span>
<span class="line" id="L366">        _ = return_address;</span>
<span class="line" id="L367">        <span class="tok-kw">const</span> new_size_aligned = mem.alignForward(new_size, mem.page_size);</span>
<span class="line" id="L368"></span>
<span class="line" id="L369">        <span class="tok-kw">if</span> (builtin.os.tag == .windows) {</span>
<span class="line" id="L370">            <span class="tok-kw">const</span> w = os.windows;</span>
<span class="line" id="L371">            <span class="tok-kw">if</span> (new_size &lt;= buf_unaligned.len) {</span>
<span class="line" id="L372">                <span class="tok-kw">const</span> base_addr = <span class="tok-builtin">@ptrToInt</span>(buf_unaligned.ptr);</span>
<span class="line" id="L373">                <span class="tok-kw">const</span> old_addr_end = base_addr + buf_unaligned.len;</span>
<span class="line" id="L374">                <span class="tok-kw">const</span> new_addr_end = mem.alignForward(base_addr + new_size, mem.page_size);</span>
<span class="line" id="L375">                <span class="tok-kw">if</span> (old_addr_end &gt; new_addr_end) {</span>
<span class="line" id="L376">                    <span class="tok-comment">// For shrinking that is not releasing, we will only</span>
</span>
<span class="line" id="L377">                    <span class="tok-comment">// decommit the pages not needed anymore.</span>
</span>
<span class="line" id="L378">                    w.VirtualFree(</span>
<span class="line" id="L379">                        <span class="tok-builtin">@intToPtr</span>(*<span class="tok-type">anyopaque</span>, new_addr_end),</span>
<span class="line" id="L380">                        old_addr_end - new_addr_end,</span>
<span class="line" id="L381">                        w.MEM_DECOMMIT,</span>
<span class="line" id="L382">                    );</span>
<span class="line" id="L383">                }</span>
<span class="line" id="L384">                <span class="tok-kw">return</span> alignPageAllocLen(new_size_aligned, new_size, len_align);</span>
<span class="line" id="L385">            }</span>
<span class="line" id="L386">            <span class="tok-kw">const</span> old_size_aligned = mem.alignForward(buf_unaligned.len, mem.page_size);</span>
<span class="line" id="L387">            <span class="tok-kw">if</span> (new_size_aligned &lt;= old_size_aligned) {</span>
<span class="line" id="L388">                <span class="tok-kw">return</span> alignPageAllocLen(new_size_aligned, new_size, len_align);</span>
<span class="line" id="L389">            }</span>
<span class="line" id="L390">            <span class="tok-kw">return</span> <span class="tok-null">null</span>;</span>
<span class="line" id="L391">        }</span>
<span class="line" id="L392"></span>
<span class="line" id="L393">        <span class="tok-kw">const</span> buf_aligned_len = mem.alignForward(buf_unaligned.len, mem.page_size);</span>
<span class="line" id="L394">        <span class="tok-kw">if</span> (new_size_aligned == buf_aligned_len)</span>
<span class="line" id="L395">            <span class="tok-kw">return</span> alignPageAllocLen(new_size_aligned, new_size, len_align);</span>
<span class="line" id="L396"></span>
<span class="line" id="L397">        <span class="tok-kw">if</span> (new_size_aligned &lt; buf_aligned_len) {</span>
<span class="line" id="L398">            <span class="tok-kw">const</span> ptr = <span class="tok-builtin">@alignCast</span>(mem.page_size, buf_unaligned.ptr + new_size_aligned);</span>
<span class="line" id="L399">            <span class="tok-comment">// TODO: if the next_mmap_addr_hint is within the unmapped range, update it</span>
</span>
<span class="line" id="L400">            os.munmap(ptr[<span class="tok-number">0</span> .. buf_aligned_len - new_size_aligned]);</span>
<span class="line" id="L401">            <span class="tok-kw">return</span> alignPageAllocLen(new_size_aligned, new_size, len_align);</span>
<span class="line" id="L402">        }</span>
<span class="line" id="L403"></span>
<span class="line" id="L404">        <span class="tok-comment">// TODO: call mremap</span>
</span>
<span class="line" id="L405">        <span class="tok-comment">// TODO: if the next_mmap_addr_hint is within the remapped range, update it</span>
</span>
<span class="line" id="L406">        <span class="tok-kw">return</span> <span class="tok-null">null</span>;</span>
<span class="line" id="L407">    }</span>
<span class="line" id="L408"></span>
<span class="line" id="L409">    <span class="tok-kw">fn</span> <span class="tok-fn">free</span>(_: *<span class="tok-type">anyopaque</span>, buf_unaligned: []<span class="tok-type">u8</span>, buf_align: <span class="tok-type">u29</span>, return_address: <span class="tok-type">usize</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L410">        _ = buf_align;</span>
<span class="line" id="L411">        _ = return_address;</span>
<span class="line" id="L412"></span>
<span class="line" id="L413">        <span class="tok-kw">if</span> (builtin.os.tag == .windows) {</span>
<span class="line" id="L414">            os.windows.VirtualFree(buf_unaligned.ptr, <span class="tok-number">0</span>, os.windows.MEM_RELEASE);</span>
<span class="line" id="L415">        } <span class="tok-kw">else</span> {</span>
<span class="line" id="L416">            <span class="tok-kw">const</span> buf_aligned_len = mem.alignForward(buf_unaligned.len, mem.page_size);</span>
<span class="line" id="L417">            <span class="tok-kw">const</span> ptr = <span class="tok-builtin">@alignCast</span>(mem.page_size, buf_unaligned.ptr);</span>
<span class="line" id="L418">            os.munmap(ptr[<span class="tok-number">0</span>..buf_aligned_len]);</span>
<span class="line" id="L419">        }</span>
<span class="line" id="L420">    }</span>
<span class="line" id="L421">};</span>
<span class="line" id="L422"></span>
<span class="line" id="L423"><span class="tok-kw">const</span> WasmPageAllocator = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L424">    <span class="tok-kw">comptime</span> {</span>
<span class="line" id="L425">        <span class="tok-kw">if</span> (!builtin.target.isWasm()) {</span>
<span class="line" id="L426">            <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;WasmPageAllocator is only available for wasm32 arch&quot;</span>);</span>
<span class="line" id="L427">        }</span>
<span class="line" id="L428">    }</span>
<span class="line" id="L429"></span>
<span class="line" id="L430">    <span class="tok-kw">const</span> vtable = Allocator.VTable{</span>
<span class="line" id="L431">        .alloc = alloc,</span>
<span class="line" id="L432">        .resize = resize,</span>
<span class="line" id="L433">        .free = free,</span>
<span class="line" id="L434">    };</span>
<span class="line" id="L435"></span>
<span class="line" id="L436">    <span class="tok-kw">const</span> PageStatus = <span class="tok-kw">enum</span>(<span class="tok-type">u1</span>) {</span>
<span class="line" id="L437">        used = <span class="tok-number">0</span>,</span>
<span class="line" id="L438">        free = <span class="tok-number">1</span>,</span>
<span class="line" id="L439"></span>
<span class="line" id="L440">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> none_free: <span class="tok-type">u8</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L441">    };</span>
<span class="line" id="L442"></span>
<span class="line" id="L443">    <span class="tok-kw">const</span> FreeBlock = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L444">        data: []<span class="tok-type">u128</span>,</span>
<span class="line" id="L445"></span>
<span class="line" id="L446">        <span class="tok-kw">const</span> Io = std.packed_int_array.PackedIntIo(<span class="tok-type">u1</span>, .Little);</span>
<span class="line" id="L447"></span>
<span class="line" id="L448">        <span class="tok-kw">fn</span> <span class="tok-fn">totalPages</span>(self: FreeBlock) <span class="tok-type">usize</span> {</span>
<span class="line" id="L449">            <span class="tok-kw">return</span> self.data.len * <span class="tok-number">128</span>;</span>
<span class="line" id="L450">        }</span>
<span class="line" id="L451"></span>
<span class="line" id="L452">        <span class="tok-kw">fn</span> <span class="tok-fn">isInitialized</span>(self: FreeBlock) <span class="tok-type">bool</span> {</span>
<span class="line" id="L453">            <span class="tok-kw">return</span> self.data.len &gt; <span class="tok-number">0</span>;</span>
<span class="line" id="L454">        }</span>
<span class="line" id="L455"></span>
<span class="line" id="L456">        <span class="tok-kw">fn</span> <span class="tok-fn">getBit</span>(self: FreeBlock, idx: <span class="tok-type">usize</span>) PageStatus {</span>
<span class="line" id="L457">            <span class="tok-kw">const</span> bit_offset = <span class="tok-number">0</span>;</span>
<span class="line" id="L458">            <span class="tok-kw">return</span> <span class="tok-builtin">@intToEnum</span>(PageStatus, Io.get(mem.sliceAsBytes(self.data), idx, bit_offset));</span>
<span class="line" id="L459">        }</span>
<span class="line" id="L460"></span>
<span class="line" id="L461">        <span class="tok-kw">fn</span> <span class="tok-fn">setBits</span>(self: FreeBlock, start_idx: <span class="tok-type">usize</span>, len: <span class="tok-type">usize</span>, val: PageStatus) <span class="tok-type">void</span> {</span>
<span class="line" id="L462">            <span class="tok-kw">const</span> bit_offset = <span class="tok-number">0</span>;</span>
<span class="line" id="L463">            <span class="tok-kw">var</span> i: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L464">            <span class="tok-kw">while</span> (i &lt; len) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L465">                Io.set(mem.sliceAsBytes(self.data), start_idx + i, bit_offset, <span class="tok-builtin">@enumToInt</span>(val));</span>
<span class="line" id="L466">            }</span>
<span class="line" id="L467">        }</span>
<span class="line" id="L468"></span>
<span class="line" id="L469">        <span class="tok-comment">// Use '0xFFFFFFFF' as a _missing_ sentinel</span>
</span>
<span class="line" id="L470">        <span class="tok-comment">// This saves ~50 bytes compared to returning a nullable</span>
</span>
<span class="line" id="L471"></span>
<span class="line" id="L472">        <span class="tok-comment">// We can guarantee that conventional memory never gets this big,</span>
</span>
<span class="line" id="L473">        <span class="tok-comment">// and wasm32 would not be able to address this memory (32 GB &gt; usize).</span>
</span>
<span class="line" id="L474"></span>
<span class="line" id="L475">        <span class="tok-comment">// Revisit if this is settled: https://github.com/ziglang/zig/issues/3806</span>
</span>
<span class="line" id="L476">        <span class="tok-kw">const</span> not_found = std.math.maxInt(<span class="tok-type">usize</span>);</span>
<span class="line" id="L477"></span>
<span class="line" id="L478">        <span class="tok-kw">fn</span> <span class="tok-fn">useRecycled</span>(self: FreeBlock, num_pages: <span class="tok-type">usize</span>, alignment: <span class="tok-type">u29</span>) <span class="tok-type">usize</span> {</span>
<span class="line" id="L479">            <span class="tok-builtin">@setCold</span>(<span class="tok-null">true</span>);</span>
<span class="line" id="L480">            <span class="tok-kw">for</span> (self.data) |segment, i| {</span>
<span class="line" id="L481">                <span class="tok-kw">const</span> spills_into_next = <span class="tok-builtin">@bitCast</span>(<span class="tok-type">i128</span>, segment) &lt; <span class="tok-number">0</span>;</span>
<span class="line" id="L482">                <span class="tok-kw">const</span> has_enough_bits = <span class="tok-builtin">@popCount</span>(<span class="tok-type">u128</span>, segment) &gt;= num_pages;</span>
<span class="line" id="L483"></span>
<span class="line" id="L484">                <span class="tok-kw">if</span> (!spills_into_next <span class="tok-kw">and</span> !has_enough_bits) <span class="tok-kw">continue</span>;</span>
<span class="line" id="L485"></span>
<span class="line" id="L486">                <span class="tok-kw">var</span> j: <span class="tok-type">usize</span> = i * <span class="tok-number">128</span>;</span>
<span class="line" id="L487">                <span class="tok-kw">while</span> (j &lt; (i + <span class="tok-number">1</span>) * <span class="tok-number">128</span>) : (j += <span class="tok-number">1</span>) {</span>
<span class="line" id="L488">                    <span class="tok-kw">var</span> count: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L489">                    <span class="tok-kw">while</span> (j + count &lt; self.totalPages() <span class="tok-kw">and</span> self.getBit(j + count) == .free) {</span>
<span class="line" id="L490">                        count += <span class="tok-number">1</span>;</span>
<span class="line" id="L491">                        <span class="tok-kw">const</span> addr = j * mem.page_size;</span>
<span class="line" id="L492">                        <span class="tok-kw">if</span> (count &gt;= num_pages <span class="tok-kw">and</span> mem.isAligned(addr, alignment)) {</span>
<span class="line" id="L493">                            self.setBits(j, num_pages, .used);</span>
<span class="line" id="L494">                            <span class="tok-kw">return</span> j;</span>
<span class="line" id="L495">                        }</span>
<span class="line" id="L496">                    }</span>
<span class="line" id="L497">                    j += count;</span>
<span class="line" id="L498">                }</span>
<span class="line" id="L499">            }</span>
<span class="line" id="L500">            <span class="tok-kw">return</span> not_found;</span>
<span class="line" id="L501">        }</span>
<span class="line" id="L502"></span>
<span class="line" id="L503">        <span class="tok-kw">fn</span> <span class="tok-fn">recycle</span>(self: FreeBlock, start_idx: <span class="tok-type">usize</span>, len: <span class="tok-type">usize</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L504">            self.setBits(start_idx, len, .free);</span>
<span class="line" id="L505">        }</span>
<span class="line" id="L506">    };</span>
<span class="line" id="L507"></span>
<span class="line" id="L508">    <span class="tok-kw">var</span> _conventional_data = [_]<span class="tok-type">u128</span>{<span class="tok-number">0</span>} ** <span class="tok-number">16</span>;</span>
<span class="line" id="L509">    <span class="tok-comment">// Marking `conventional` as const saves ~40 bytes</span>
</span>
<span class="line" id="L510">    <span class="tok-kw">const</span> conventional = FreeBlock{ .data = &amp;_conventional_data };</span>
<span class="line" id="L511">    <span class="tok-kw">var</span> extended = FreeBlock{ .data = &amp;[_]<span class="tok-type">u128</span>{} };</span>
<span class="line" id="L512"></span>
<span class="line" id="L513">    <span class="tok-kw">fn</span> <span class="tok-fn">extendedOffset</span>() <span class="tok-type">usize</span> {</span>
<span class="line" id="L514">        <span class="tok-kw">return</span> conventional.totalPages();</span>
<span class="line" id="L515">    }</span>
<span class="line" id="L516"></span>
<span class="line" id="L517">    <span class="tok-kw">fn</span> <span class="tok-fn">nPages</span>(memsize: <span class="tok-type">usize</span>) <span class="tok-type">usize</span> {</span>
<span class="line" id="L518">        <span class="tok-kw">return</span> mem.alignForward(memsize, mem.page_size) / mem.page_size;</span>
<span class="line" id="L519">    }</span>
<span class="line" id="L520"></span>
<span class="line" id="L521">    <span class="tok-kw">fn</span> <span class="tok-fn">alloc</span>(_: *<span class="tok-type">anyopaque</span>, len: <span class="tok-type">usize</span>, alignment: <span class="tok-type">u29</span>, len_align: <span class="tok-type">u29</span>, ra: <span class="tok-type">usize</span>) <span class="tok-kw">error</span>{OutOfMemory}![]<span class="tok-type">u8</span> {</span>
<span class="line" id="L522">        _ = ra;</span>
<span class="line" id="L523">        <span class="tok-kw">const</span> page_count = nPages(len);</span>
<span class="line" id="L524">        <span class="tok-kw">const</span> page_idx = <span class="tok-kw">try</span> allocPages(page_count, alignment);</span>
<span class="line" id="L525">        <span class="tok-kw">return</span> <span class="tok-builtin">@intToPtr</span>([*]<span class="tok-type">u8</span>, page_idx * mem.page_size)[<span class="tok-number">0</span>..alignPageAllocLen(page_count * mem.page_size, len, len_align)];</span>
<span class="line" id="L526">    }</span>
<span class="line" id="L527">    <span class="tok-kw">fn</span> <span class="tok-fn">allocPages</span>(page_count: <span class="tok-type">usize</span>, alignment: <span class="tok-type">u29</span>) !<span class="tok-type">usize</span> {</span>
<span class="line" id="L528">        {</span>
<span class="line" id="L529">            <span class="tok-kw">const</span> idx = conventional.useRecycled(page_count, alignment);</span>
<span class="line" id="L530">            <span class="tok-kw">if</span> (idx != FreeBlock.not_found) {</span>
<span class="line" id="L531">                <span class="tok-kw">return</span> idx;</span>
<span class="line" id="L532">            }</span>
<span class="line" id="L533">        }</span>
<span class="line" id="L534"></span>
<span class="line" id="L535">        <span class="tok-kw">const</span> idx = extended.useRecycled(page_count, alignment);</span>
<span class="line" id="L536">        <span class="tok-kw">if</span> (idx != FreeBlock.not_found) {</span>
<span class="line" id="L537">            <span class="tok-kw">return</span> idx + extendedOffset();</span>
<span class="line" id="L538">        }</span>
<span class="line" id="L539"></span>
<span class="line" id="L540">        <span class="tok-kw">const</span> next_page_idx = <span class="tok-builtin">@wasmMemorySize</span>(<span class="tok-number">0</span>);</span>
<span class="line" id="L541">        <span class="tok-kw">const</span> next_page_addr = next_page_idx * mem.page_size;</span>
<span class="line" id="L542">        <span class="tok-kw">const</span> aligned_addr = mem.alignForward(next_page_addr, alignment);</span>
<span class="line" id="L543">        <span class="tok-kw">const</span> drop_page_count = <span class="tok-builtin">@divExact</span>(aligned_addr - next_page_addr, mem.page_size);</span>
<span class="line" id="L544">        <span class="tok-kw">const</span> result = <span class="tok-builtin">@wasmMemoryGrow</span>(<span class="tok-number">0</span>, <span class="tok-builtin">@intCast</span>(<span class="tok-type">u32</span>, drop_page_count + page_count));</span>
<span class="line" id="L545">        <span class="tok-kw">if</span> (result &lt;= <span class="tok-number">0</span>)</span>
<span class="line" id="L546">            <span class="tok-kw">return</span> <span class="tok-kw">error</span>.OutOfMemory;</span>
<span class="line" id="L547">        assert(result == next_page_idx);</span>
<span class="line" id="L548">        <span class="tok-kw">const</span> aligned_page_idx = next_page_idx + drop_page_count;</span>
<span class="line" id="L549">        <span class="tok-kw">if</span> (drop_page_count &gt; <span class="tok-number">0</span>) {</span>
<span class="line" id="L550">            freePages(next_page_idx, aligned_page_idx);</span>
<span class="line" id="L551">        }</span>
<span class="line" id="L552">        <span class="tok-kw">return</span> <span class="tok-builtin">@intCast</span>(<span class="tok-type">usize</span>, aligned_page_idx);</span>
<span class="line" id="L553">    }</span>
<span class="line" id="L554"></span>
<span class="line" id="L555">    <span class="tok-kw">fn</span> <span class="tok-fn">freePages</span>(start: <span class="tok-type">usize</span>, end: <span class="tok-type">usize</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L556">        <span class="tok-kw">if</span> (start &lt; extendedOffset()) {</span>
<span class="line" id="L557">            conventional.recycle(start, <span class="tok-builtin">@minimum</span>(extendedOffset(), end) - start);</span>
<span class="line" id="L558">        }</span>
<span class="line" id="L559">        <span class="tok-kw">if</span> (end &gt; extendedOffset()) {</span>
<span class="line" id="L560">            <span class="tok-kw">var</span> new_end = end;</span>
<span class="line" id="L561">            <span class="tok-kw">if</span> (!extended.isInitialized()) {</span>
<span class="line" id="L562">                <span class="tok-comment">// Steal the last page from the memory currently being recycled</span>
</span>
<span class="line" id="L563">                <span class="tok-comment">// TODO: would it be better if we use the first page instead?</span>
</span>
<span class="line" id="L564">                new_end -= <span class="tok-number">1</span>;</span>
<span class="line" id="L565"></span>
<span class="line" id="L566">                extended.data = <span class="tok-builtin">@intToPtr</span>([*]<span class="tok-type">u128</span>, new_end * mem.page_size)[<span class="tok-number">0</span> .. mem.page_size / <span class="tok-builtin">@sizeOf</span>(<span class="tok-type">u128</span>)];</span>
<span class="line" id="L567">                <span class="tok-comment">// Since this is the first page being freed and we consume it, assume *nothing* is free.</span>
</span>
<span class="line" id="L568">                mem.set(<span class="tok-type">u128</span>, extended.data, PageStatus.none_free);</span>
<span class="line" id="L569">            }</span>
<span class="line" id="L570">            <span class="tok-kw">const</span> clamped_start = std.math.max(extendedOffset(), start);</span>
<span class="line" id="L571">            extended.recycle(clamped_start - extendedOffset(), new_end - clamped_start);</span>
<span class="line" id="L572">        }</span>
<span class="line" id="L573">    }</span>
<span class="line" id="L574"></span>
<span class="line" id="L575">    <span class="tok-kw">fn</span> <span class="tok-fn">resize</span>(</span>
<span class="line" id="L576">        _: *<span class="tok-type">anyopaque</span>,</span>
<span class="line" id="L577">        buf: []<span class="tok-type">u8</span>,</span>
<span class="line" id="L578">        buf_align: <span class="tok-type">u29</span>,</span>
<span class="line" id="L579">        new_len: <span class="tok-type">usize</span>,</span>
<span class="line" id="L580">        len_align: <span class="tok-type">u29</span>,</span>
<span class="line" id="L581">        return_address: <span class="tok-type">usize</span>,</span>
<span class="line" id="L582">    ) ?<span class="tok-type">usize</span> {</span>
<span class="line" id="L583">        _ = buf_align;</span>
<span class="line" id="L584">        _ = return_address;</span>
<span class="line" id="L585">        <span class="tok-kw">const</span> aligned_len = mem.alignForward(buf.len, mem.page_size);</span>
<span class="line" id="L586">        <span class="tok-kw">if</span> (new_len &gt; aligned_len) <span class="tok-kw">return</span> <span class="tok-null">null</span>;</span>
<span class="line" id="L587">        <span class="tok-kw">const</span> current_n = nPages(aligned_len);</span>
<span class="line" id="L588">        <span class="tok-kw">const</span> new_n = nPages(new_len);</span>
<span class="line" id="L589">        <span class="tok-kw">if</span> (new_n != current_n) {</span>
<span class="line" id="L590">            <span class="tok-kw">const</span> base = nPages(<span class="tok-builtin">@ptrToInt</span>(buf.ptr));</span>
<span class="line" id="L591">            freePages(base + new_n, base + current_n);</span>
<span class="line" id="L592">        }</span>
<span class="line" id="L593">        <span class="tok-kw">return</span> alignPageAllocLen(new_n * mem.page_size, new_len, len_align);</span>
<span class="line" id="L594">    }</span>
<span class="line" id="L595"></span>
<span class="line" id="L596">    <span class="tok-kw">fn</span> <span class="tok-fn">free</span>(</span>
<span class="line" id="L597">        _: *<span class="tok-type">anyopaque</span>,</span>
<span class="line" id="L598">        buf: []<span class="tok-type">u8</span>,</span>
<span class="line" id="L599">        buf_align: <span class="tok-type">u29</span>,</span>
<span class="line" id="L600">        return_address: <span class="tok-type">usize</span>,</span>
<span class="line" id="L601">    ) <span class="tok-type">void</span> {</span>
<span class="line" id="L602">        _ = buf_align;</span>
<span class="line" id="L603">        _ = return_address;</span>
<span class="line" id="L604">        <span class="tok-kw">const</span> aligned_len = mem.alignForward(buf.len, mem.page_size);</span>
<span class="line" id="L605">        <span class="tok-kw">const</span> current_n = nPages(aligned_len);</span>
<span class="line" id="L606">        <span class="tok-kw">const</span> base = nPages(<span class="tok-builtin">@ptrToInt</span>(buf.ptr));</span>
<span class="line" id="L607">        freePages(base, base + current_n);</span>
<span class="line" id="L608">    }</span>
<span class="line" id="L609">};</span>
<span class="line" id="L610"></span>
<span class="line" id="L611"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> HeapAllocator = <span class="tok-kw">switch</span> (builtin.os.tag) {</span>
<span class="line" id="L612">    .windows =&gt; <span class="tok-kw">struct</span> {</span>
<span class="line" id="L613">        heap_handle: ?HeapHandle,</span>
<span class="line" id="L614"></span>
<span class="line" id="L615">        <span class="tok-kw">const</span> HeapHandle = os.windows.HANDLE;</span>
<span class="line" id="L616"></span>
<span class="line" id="L617">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">init</span>() HeapAllocator {</span>
<span class="line" id="L618">            <span class="tok-kw">return</span> HeapAllocator{</span>
<span class="line" id="L619">                .heap_handle = <span class="tok-null">null</span>,</span>
<span class="line" id="L620">            };</span>
<span class="line" id="L621">        }</span>
<span class="line" id="L622"></span>
<span class="line" id="L623">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">allocator</span>(self: *HeapAllocator) Allocator {</span>
<span class="line" id="L624">            <span class="tok-kw">return</span> Allocator.init(self, alloc, resize, free);</span>
<span class="line" id="L625">        }</span>
<span class="line" id="L626"></span>
<span class="line" id="L627">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">deinit</span>(self: *HeapAllocator) <span class="tok-type">void</span> {</span>
<span class="line" id="L628">            <span class="tok-kw">if</span> (self.heap_handle) |heap_handle| {</span>
<span class="line" id="L629">                os.windows.HeapDestroy(heap_handle);</span>
<span class="line" id="L630">            }</span>
<span class="line" id="L631">        }</span>
<span class="line" id="L632"></span>
<span class="line" id="L633">        <span class="tok-kw">fn</span> <span class="tok-fn">getRecordPtr</span>(buf: []<span class="tok-type">u8</span>) *<span class="tok-kw">align</span>(<span class="tok-number">1</span>) <span class="tok-type">usize</span> {</span>
<span class="line" id="L634">            <span class="tok-kw">return</span> <span class="tok-builtin">@intToPtr</span>(*<span class="tok-kw">align</span>(<span class="tok-number">1</span>) <span class="tok-type">usize</span>, <span class="tok-builtin">@ptrToInt</span>(buf.ptr) + buf.len);</span>
<span class="line" id="L635">        }</span>
<span class="line" id="L636"></span>
<span class="line" id="L637">        <span class="tok-kw">fn</span> <span class="tok-fn">alloc</span>(</span>
<span class="line" id="L638">            self: *HeapAllocator,</span>
<span class="line" id="L639">            n: <span class="tok-type">usize</span>,</span>
<span class="line" id="L640">            ptr_align: <span class="tok-type">u29</span>,</span>
<span class="line" id="L641">            len_align: <span class="tok-type">u29</span>,</span>
<span class="line" id="L642">            return_address: <span class="tok-type">usize</span>,</span>
<span class="line" id="L643">        ) <span class="tok-kw">error</span>{OutOfMemory}![]<span class="tok-type">u8</span> {</span>
<span class="line" id="L644">            _ = return_address;</span>
<span class="line" id="L645"></span>
<span class="line" id="L646">            <span class="tok-kw">const</span> amt = n + ptr_align - <span class="tok-number">1</span> + <span class="tok-builtin">@sizeOf</span>(<span class="tok-type">usize</span>);</span>
<span class="line" id="L647">            <span class="tok-kw">const</span> optional_heap_handle = <span class="tok-builtin">@atomicLoad</span>(?HeapHandle, &amp;self.heap_handle, .SeqCst);</span>
<span class="line" id="L648">            <span class="tok-kw">const</span> heap_handle = optional_heap_handle <span class="tok-kw">orelse</span> blk: {</span>
<span class="line" id="L649">                <span class="tok-kw">const</span> options = <span class="tok-kw">if</span> (builtin.single_threaded) os.windows.HEAP_NO_SERIALIZE <span class="tok-kw">else</span> <span class="tok-number">0</span>;</span>
<span class="line" id="L650">                <span class="tok-kw">const</span> hh = os.windows.kernel32.HeapCreate(options, amt, <span class="tok-number">0</span>) <span class="tok-kw">orelse</span> <span class="tok-kw">return</span> <span class="tok-kw">error</span>.OutOfMemory;</span>
<span class="line" id="L651">                <span class="tok-kw">const</span> other_hh = <span class="tok-builtin">@cmpxchgStrong</span>(?HeapHandle, &amp;self.heap_handle, <span class="tok-null">null</span>, hh, .SeqCst, .SeqCst) <span class="tok-kw">orelse</span> <span class="tok-kw">break</span> :blk hh;</span>
<span class="line" id="L652">                os.windows.HeapDestroy(hh);</span>
<span class="line" id="L653">                <span class="tok-kw">break</span> :blk other_hh.?; <span class="tok-comment">// can't be null because of the cmpxchg</span>
</span>
<span class="line" id="L654">            };</span>
<span class="line" id="L655">            <span class="tok-kw">const</span> ptr = os.windows.kernel32.HeapAlloc(heap_handle, <span class="tok-number">0</span>, amt) <span class="tok-kw">orelse</span> <span class="tok-kw">return</span> <span class="tok-kw">error</span>.OutOfMemory;</span>
<span class="line" id="L656">            <span class="tok-kw">const</span> root_addr = <span class="tok-builtin">@ptrToInt</span>(ptr);</span>
<span class="line" id="L657">            <span class="tok-kw">const</span> aligned_addr = mem.alignForward(root_addr, ptr_align);</span>
<span class="line" id="L658">            <span class="tok-kw">const</span> return_len = init: {</span>
<span class="line" id="L659">                <span class="tok-kw">if</span> (len_align == <span class="tok-number">0</span>) <span class="tok-kw">break</span> :init n;</span>
<span class="line" id="L660">                <span class="tok-kw">const</span> full_len = os.windows.kernel32.HeapSize(heap_handle, <span class="tok-number">0</span>, ptr);</span>
<span class="line" id="L661">                assert(full_len != std.math.maxInt(<span class="tok-type">usize</span>));</span>
<span class="line" id="L662">                assert(full_len &gt;= amt);</span>
<span class="line" id="L663">                <span class="tok-kw">break</span> :init mem.alignBackwardAnyAlign(full_len - (aligned_addr - root_addr) - <span class="tok-builtin">@sizeOf</span>(<span class="tok-type">usize</span>), len_align);</span>
<span class="line" id="L664">            };</span>
<span class="line" id="L665">            <span class="tok-kw">const</span> buf = <span class="tok-builtin">@intToPtr</span>([*]<span class="tok-type">u8</span>, aligned_addr)[<span class="tok-number">0</span>..return_len];</span>
<span class="line" id="L666">            getRecordPtr(buf).* = root_addr;</span>
<span class="line" id="L667">            <span class="tok-kw">return</span> buf;</span>
<span class="line" id="L668">        }</span>
<span class="line" id="L669"></span>
<span class="line" id="L670">        <span class="tok-kw">fn</span> <span class="tok-fn">resize</span>(</span>
<span class="line" id="L671">            self: *HeapAllocator,</span>
<span class="line" id="L672">            buf: []<span class="tok-type">u8</span>,</span>
<span class="line" id="L673">            buf_align: <span class="tok-type">u29</span>,</span>
<span class="line" id="L674">            new_size: <span class="tok-type">usize</span>,</span>
<span class="line" id="L675">            len_align: <span class="tok-type">u29</span>,</span>
<span class="line" id="L676">            return_address: <span class="tok-type">usize</span>,</span>
<span class="line" id="L677">        ) ?<span class="tok-type">usize</span> {</span>
<span class="line" id="L678">            _ = buf_align;</span>
<span class="line" id="L679">            _ = return_address;</span>
<span class="line" id="L680"></span>
<span class="line" id="L681">            <span class="tok-kw">const</span> root_addr = getRecordPtr(buf).*;</span>
<span class="line" id="L682">            <span class="tok-kw">const</span> align_offset = <span class="tok-builtin">@ptrToInt</span>(buf.ptr) - root_addr;</span>
<span class="line" id="L683">            <span class="tok-kw">const</span> amt = align_offset + new_size + <span class="tok-builtin">@sizeOf</span>(<span class="tok-type">usize</span>);</span>
<span class="line" id="L684">            <span class="tok-kw">const</span> new_ptr = os.windows.kernel32.HeapReAlloc(</span>
<span class="line" id="L685">                self.heap_handle.?,</span>
<span class="line" id="L686">                os.windows.HEAP_REALLOC_IN_PLACE_ONLY,</span>
<span class="line" id="L687">                <span class="tok-builtin">@intToPtr</span>(*<span class="tok-type">anyopaque</span>, root_addr),</span>
<span class="line" id="L688">                amt,</span>
<span class="line" id="L689">            ) <span class="tok-kw">orelse</span> <span class="tok-kw">return</span> <span class="tok-null">null</span>;</span>
<span class="line" id="L690">            assert(new_ptr == <span class="tok-builtin">@intToPtr</span>(*<span class="tok-type">anyopaque</span>, root_addr));</span>
<span class="line" id="L691">            <span class="tok-kw">const</span> return_len = init: {</span>
<span class="line" id="L692">                <span class="tok-kw">if</span> (len_align == <span class="tok-number">0</span>) <span class="tok-kw">break</span> :init new_size;</span>
<span class="line" id="L693">                <span class="tok-kw">const</span> full_len = os.windows.kernel32.HeapSize(self.heap_handle.?, <span class="tok-number">0</span>, new_ptr);</span>
<span class="line" id="L694">                assert(full_len != std.math.maxInt(<span class="tok-type">usize</span>));</span>
<span class="line" id="L695">                assert(full_len &gt;= amt);</span>
<span class="line" id="L696">                <span class="tok-kw">break</span> :init mem.alignBackwardAnyAlign(full_len - align_offset, len_align);</span>
<span class="line" id="L697">            };</span>
<span class="line" id="L698">            getRecordPtr(buf.ptr[<span class="tok-number">0</span>..return_len]).* = root_addr;</span>
<span class="line" id="L699">            <span class="tok-kw">return</span> return_len;</span>
<span class="line" id="L700">        }</span>
<span class="line" id="L701"></span>
<span class="line" id="L702">        <span class="tok-kw">fn</span> <span class="tok-fn">free</span>(</span>
<span class="line" id="L703">            self: *HeapAllocator,</span>
<span class="line" id="L704">            buf: []<span class="tok-type">u8</span>,</span>
<span class="line" id="L705">            buf_align: <span class="tok-type">u29</span>,</span>
<span class="line" id="L706">            return_address: <span class="tok-type">usize</span>,</span>
<span class="line" id="L707">        ) <span class="tok-type">void</span> {</span>
<span class="line" id="L708">            _ = buf_align;</span>
<span class="line" id="L709">            _ = return_address;</span>
<span class="line" id="L710">            os.windows.HeapFree(self.heap_handle.?, <span class="tok-number">0</span>, <span class="tok-builtin">@intToPtr</span>(*<span class="tok-type">anyopaque</span>, getRecordPtr(buf).*));</span>
<span class="line" id="L711">        }</span>
<span class="line" id="L712">    },</span>
<span class="line" id="L713">    <span class="tok-kw">else</span> =&gt; <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;Unsupported OS&quot;</span>),</span>
<span class="line" id="L714">};</span>
<span class="line" id="L715"></span>
<span class="line" id="L716"><span class="tok-kw">fn</span> <span class="tok-fn">sliceContainsPtr</span>(container: []<span class="tok-type">u8</span>, ptr: [*]<span class="tok-type">u8</span>) <span class="tok-type">bool</span> {</span>
<span class="line" id="L717">    <span class="tok-kw">return</span> <span class="tok-builtin">@ptrToInt</span>(ptr) &gt;= <span class="tok-builtin">@ptrToInt</span>(container.ptr) <span class="tok-kw">and</span></span>
<span class="line" id="L718">        <span class="tok-builtin">@ptrToInt</span>(ptr) &lt; (<span class="tok-builtin">@ptrToInt</span>(container.ptr) + container.len);</span>
<span class="line" id="L719">}</span>
<span class="line" id="L720"></span>
<span class="line" id="L721"><span class="tok-kw">fn</span> <span class="tok-fn">sliceContainsSlice</span>(container: []<span class="tok-type">u8</span>, slice: []<span class="tok-type">u8</span>) <span class="tok-type">bool</span> {</span>
<span class="line" id="L722">    <span class="tok-kw">return</span> <span class="tok-builtin">@ptrToInt</span>(slice.ptr) &gt;= <span class="tok-builtin">@ptrToInt</span>(container.ptr) <span class="tok-kw">and</span></span>
<span class="line" id="L723">        (<span class="tok-builtin">@ptrToInt</span>(slice.ptr) + slice.len) &lt;= (<span class="tok-builtin">@ptrToInt</span>(container.ptr) + container.len);</span>
<span class="line" id="L724">}</span>
<span class="line" id="L725"></span>
<span class="line" id="L726"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FixedBufferAllocator = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L727">    end_index: <span class="tok-type">usize</span>,</span>
<span class="line" id="L728">    buffer: []<span class="tok-type">u8</span>,</span>
<span class="line" id="L729"></span>
<span class="line" id="L730">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">init</span>(buffer: []<span class="tok-type">u8</span>) FixedBufferAllocator {</span>
<span class="line" id="L731">        <span class="tok-kw">return</span> FixedBufferAllocator{</span>
<span class="line" id="L732">            .buffer = buffer,</span>
<span class="line" id="L733">            .end_index = <span class="tok-number">0</span>,</span>
<span class="line" id="L734">        };</span>
<span class="line" id="L735">    }</span>
<span class="line" id="L736"></span>
<span class="line" id="L737">    <span class="tok-comment">/// *WARNING* using this at the same time as the interface returned by `threadSafeAllocator` is not thread safe</span></span>
<span class="line" id="L738">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">allocator</span>(self: *FixedBufferAllocator) Allocator {</span>
<span class="line" id="L739">        <span class="tok-kw">return</span> Allocator.init(self, alloc, resize, free);</span>
<span class="line" id="L740">    }</span>
<span class="line" id="L741"></span>
<span class="line" id="L742">    <span class="tok-comment">/// Provides a lock free thread safe `Allocator` interface to the underlying `FixedBufferAllocator`</span></span>
<span class="line" id="L743">    <span class="tok-comment">/// *WARNING* using this at the same time as the interface returned by `getAllocator` is not thread safe</span></span>
<span class="line" id="L744">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">threadSafeAllocator</span>(self: *FixedBufferAllocator) Allocator {</span>
<span class="line" id="L745">        <span class="tok-kw">return</span> Allocator.init(</span>
<span class="line" id="L746">            self,</span>
<span class="line" id="L747">            threadSafeAlloc,</span>
<span class="line" id="L748">            Allocator.NoResize(FixedBufferAllocator).noResize,</span>
<span class="line" id="L749">            Allocator.NoOpFree(FixedBufferAllocator).noOpFree,</span>
<span class="line" id="L750">        );</span>
<span class="line" id="L751">    }</span>
<span class="line" id="L752"></span>
<span class="line" id="L753">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">ownsPtr</span>(self: *FixedBufferAllocator, ptr: [*]<span class="tok-type">u8</span>) <span class="tok-type">bool</span> {</span>
<span class="line" id="L754">        <span class="tok-kw">return</span> sliceContainsPtr(self.buffer, ptr);</span>
<span class="line" id="L755">    }</span>
<span class="line" id="L756"></span>
<span class="line" id="L757">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">ownsSlice</span>(self: *FixedBufferAllocator, slice: []<span class="tok-type">u8</span>) <span class="tok-type">bool</span> {</span>
<span class="line" id="L758">        <span class="tok-kw">return</span> sliceContainsSlice(self.buffer, slice);</span>
<span class="line" id="L759">    }</span>
<span class="line" id="L760"></span>
<span class="line" id="L761">    <span class="tok-comment">/// NOTE: this will not work in all cases, if the last allocation had an adjusted_index</span></span>
<span class="line" id="L762">    <span class="tok-comment">///       then we won't be able to determine what the last allocation was.  This is because</span></span>
<span class="line" id="L763">    <span class="tok-comment">///       the alignForward operation done in alloc is not reversible.</span></span>
<span class="line" id="L764">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">isLastAllocation</span>(self: *FixedBufferAllocator, buf: []<span class="tok-type">u8</span>) <span class="tok-type">bool</span> {</span>
<span class="line" id="L765">        <span class="tok-kw">return</span> buf.ptr + buf.len == self.buffer.ptr + self.end_index;</span>
<span class="line" id="L766">    }</span>
<span class="line" id="L767"></span>
<span class="line" id="L768">    <span class="tok-kw">fn</span> <span class="tok-fn">alloc</span>(self: *FixedBufferAllocator, n: <span class="tok-type">usize</span>, ptr_align: <span class="tok-type">u29</span>, len_align: <span class="tok-type">u29</span>, ra: <span class="tok-type">usize</span>) ![]<span class="tok-type">u8</span> {</span>
<span class="line" id="L769">        _ = len_align;</span>
<span class="line" id="L770">        _ = ra;</span>
<span class="line" id="L771">        <span class="tok-kw">const</span> adjust_off = mem.alignPointerOffset(self.buffer.ptr + self.end_index, ptr_align) <span class="tok-kw">orelse</span></span>
<span class="line" id="L772">            <span class="tok-kw">return</span> <span class="tok-kw">error</span>.OutOfMemory;</span>
<span class="line" id="L773">        <span class="tok-kw">const</span> adjusted_index = self.end_index + adjust_off;</span>
<span class="line" id="L774">        <span class="tok-kw">const</span> new_end_index = adjusted_index + n;</span>
<span class="line" id="L775">        <span class="tok-kw">if</span> (new_end_index &gt; self.buffer.len) {</span>
<span class="line" id="L776">            <span class="tok-kw">return</span> <span class="tok-kw">error</span>.OutOfMemory;</span>
<span class="line" id="L777">        }</span>
<span class="line" id="L778">        <span class="tok-kw">const</span> result = self.buffer[adjusted_index..new_end_index];</span>
<span class="line" id="L779">        self.end_index = new_end_index;</span>
<span class="line" id="L780"></span>
<span class="line" id="L781">        <span class="tok-kw">return</span> result;</span>
<span class="line" id="L782">    }</span>
<span class="line" id="L783"></span>
<span class="line" id="L784">    <span class="tok-kw">fn</span> <span class="tok-fn">resize</span>(</span>
<span class="line" id="L785">        self: *FixedBufferAllocator,</span>
<span class="line" id="L786">        buf: []<span class="tok-type">u8</span>,</span>
<span class="line" id="L787">        buf_align: <span class="tok-type">u29</span>,</span>
<span class="line" id="L788">        new_size: <span class="tok-type">usize</span>,</span>
<span class="line" id="L789">        len_align: <span class="tok-type">u29</span>,</span>
<span class="line" id="L790">        return_address: <span class="tok-type">usize</span>,</span>
<span class="line" id="L791">    ) ?<span class="tok-type">usize</span> {</span>
<span class="line" id="L792">        _ = buf_align;</span>
<span class="line" id="L793">        _ = return_address;</span>
<span class="line" id="L794">        assert(self.ownsSlice(buf)); <span class="tok-comment">// sanity check</span>
</span>
<span class="line" id="L795"></span>
<span class="line" id="L796">        <span class="tok-kw">if</span> (!self.isLastAllocation(buf)) {</span>
<span class="line" id="L797">            <span class="tok-kw">if</span> (new_size &gt; buf.len) <span class="tok-kw">return</span> <span class="tok-null">null</span>;</span>
<span class="line" id="L798">            <span class="tok-kw">return</span> mem.alignAllocLen(buf.len, new_size, len_align);</span>
<span class="line" id="L799">        }</span>
<span class="line" id="L800"></span>
<span class="line" id="L801">        <span class="tok-kw">if</span> (new_size &lt;= buf.len) {</span>
<span class="line" id="L802">            <span class="tok-kw">const</span> sub = buf.len - new_size;</span>
<span class="line" id="L803">            self.end_index -= sub;</span>
<span class="line" id="L804">            <span class="tok-kw">return</span> mem.alignAllocLen(buf.len - sub, new_size, len_align);</span>
<span class="line" id="L805">        }</span>
<span class="line" id="L806"></span>
<span class="line" id="L807">        <span class="tok-kw">const</span> add = new_size - buf.len;</span>
<span class="line" id="L808">        <span class="tok-kw">if</span> (add + self.end_index &gt; self.buffer.len) <span class="tok-kw">return</span> <span class="tok-null">null</span>;</span>
<span class="line" id="L809"></span>
<span class="line" id="L810">        self.end_index += add;</span>
<span class="line" id="L811">        <span class="tok-kw">return</span> new_size;</span>
<span class="line" id="L812">    }</span>
<span class="line" id="L813"></span>
<span class="line" id="L814">    <span class="tok-kw">fn</span> <span class="tok-fn">free</span>(</span>
<span class="line" id="L815">        self: *FixedBufferAllocator,</span>
<span class="line" id="L816">        buf: []<span class="tok-type">u8</span>,</span>
<span class="line" id="L817">        buf_align: <span class="tok-type">u29</span>,</span>
<span class="line" id="L818">        return_address: <span class="tok-type">usize</span>,</span>
<span class="line" id="L819">    ) <span class="tok-type">void</span> {</span>
<span class="line" id="L820">        _ = buf_align;</span>
<span class="line" id="L821">        _ = return_address;</span>
<span class="line" id="L822">        assert(self.ownsSlice(buf)); <span class="tok-comment">// sanity check</span>
</span>
<span class="line" id="L823"></span>
<span class="line" id="L824">        <span class="tok-kw">if</span> (self.isLastAllocation(buf)) {</span>
<span class="line" id="L825">            self.end_index -= buf.len;</span>
<span class="line" id="L826">        }</span>
<span class="line" id="L827">    }</span>
<span class="line" id="L828"></span>
<span class="line" id="L829">    <span class="tok-kw">fn</span> <span class="tok-fn">threadSafeAlloc</span>(self: *FixedBufferAllocator, n: <span class="tok-type">usize</span>, ptr_align: <span class="tok-type">u29</span>, len_align: <span class="tok-type">u29</span>, ra: <span class="tok-type">usize</span>) ![]<span class="tok-type">u8</span> {</span>
<span class="line" id="L830">        _ = len_align;</span>
<span class="line" id="L831">        _ = ra;</span>
<span class="line" id="L832">        <span class="tok-kw">var</span> end_index = <span class="tok-builtin">@atomicLoad</span>(<span class="tok-type">usize</span>, &amp;self.end_index, .SeqCst);</span>
<span class="line" id="L833">        <span class="tok-kw">while</span> (<span class="tok-null">true</span>) {</span>
<span class="line" id="L834">            <span class="tok-kw">const</span> adjust_off = mem.alignPointerOffset(self.buffer.ptr + end_index, ptr_align) <span class="tok-kw">orelse</span></span>
<span class="line" id="L835">                <span class="tok-kw">return</span> <span class="tok-kw">error</span>.OutOfMemory;</span>
<span class="line" id="L836">            <span class="tok-kw">const</span> adjusted_index = end_index + adjust_off;</span>
<span class="line" id="L837">            <span class="tok-kw">const</span> new_end_index = adjusted_index + n;</span>
<span class="line" id="L838">            <span class="tok-kw">if</span> (new_end_index &gt; self.buffer.len) {</span>
<span class="line" id="L839">                <span class="tok-kw">return</span> <span class="tok-kw">error</span>.OutOfMemory;</span>
<span class="line" id="L840">            }</span>
<span class="line" id="L841">            end_index = <span class="tok-builtin">@cmpxchgWeak</span>(<span class="tok-type">usize</span>, &amp;self.end_index, end_index, new_end_index, .SeqCst, .SeqCst) <span class="tok-kw">orelse</span> <span class="tok-kw">return</span> self.buffer[adjusted_index..new_end_index];</span>
<span class="line" id="L842">        }</span>
<span class="line" id="L843">    }</span>
<span class="line" id="L844"></span>
<span class="line" id="L845">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">reset</span>(self: *FixedBufferAllocator) <span class="tok-type">void</span> {</span>
<span class="line" id="L846">        self.end_index = <span class="tok-number">0</span>;</span>
<span class="line" id="L847">    }</span>
<span class="line" id="L848">};</span>
<span class="line" id="L849"></span>
<span class="line" id="L850"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> ThreadSafeFixedBufferAllocator = <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;ThreadSafeFixedBufferAllocator has been replaced with `threadSafeAllocator` on FixedBufferAllocator&quot;</span>);</span>
<span class="line" id="L851"></span>
<span class="line" id="L852"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">stackFallback</span>(<span class="tok-kw">comptime</span> size: <span class="tok-type">usize</span>, fallback_allocator: Allocator) StackFallbackAllocator(size) {</span>
<span class="line" id="L853">    <span class="tok-kw">return</span> StackFallbackAllocator(size){</span>
<span class="line" id="L854">        .buffer = <span class="tok-null">undefined</span>,</span>
<span class="line" id="L855">        .fallback_allocator = fallback_allocator,</span>
<span class="line" id="L856">        .fixed_buffer_allocator = <span class="tok-null">undefined</span>,</span>
<span class="line" id="L857">    };</span>
<span class="line" id="L858">}</span>
<span class="line" id="L859"></span>
<span class="line" id="L860"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">StackFallbackAllocator</span>(<span class="tok-kw">comptime</span> size: <span class="tok-type">usize</span>) <span class="tok-type">type</span> {</span>
<span class="line" id="L861">    <span class="tok-kw">return</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L862">        <span class="tok-kw">const</span> Self = <span class="tok-builtin">@This</span>();</span>
<span class="line" id="L863"></span>
<span class="line" id="L864">        buffer: [size]<span class="tok-type">u8</span>,</span>
<span class="line" id="L865">        fallback_allocator: Allocator,</span>
<span class="line" id="L866">        fixed_buffer_allocator: FixedBufferAllocator,</span>
<span class="line" id="L867"></span>
<span class="line" id="L868">        <span class="tok-comment">/// WARNING: This functions both fetches a `std.mem.Allocator` interface to this allocator *and* resets the internal buffer allocator</span></span>
<span class="line" id="L869">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">get</span>(self: *Self) Allocator {</span>
<span class="line" id="L870">            self.fixed_buffer_allocator = FixedBufferAllocator.init(self.buffer[<span class="tok-number">0</span>..]);</span>
<span class="line" id="L871">            <span class="tok-kw">return</span> Allocator.init(self, alloc, resize, free);</span>
<span class="line" id="L872">        }</span>
<span class="line" id="L873"></span>
<span class="line" id="L874">        <span class="tok-kw">fn</span> <span class="tok-fn">alloc</span>(</span>
<span class="line" id="L875">            self: *Self,</span>
<span class="line" id="L876">            len: <span class="tok-type">usize</span>,</span>
<span class="line" id="L877">            ptr_align: <span class="tok-type">u29</span>,</span>
<span class="line" id="L878">            len_align: <span class="tok-type">u29</span>,</span>
<span class="line" id="L879">            return_address: <span class="tok-type">usize</span>,</span>
<span class="line" id="L880">        ) <span class="tok-kw">error</span>{OutOfMemory}![]<span class="tok-type">u8</span> {</span>
<span class="line" id="L881">            <span class="tok-kw">return</span> FixedBufferAllocator.alloc(&amp;self.fixed_buffer_allocator, len, ptr_align, len_align, return_address) <span class="tok-kw">catch</span></span>
<span class="line" id="L882">                <span class="tok-kw">return</span> self.fallback_allocator.rawAlloc(len, ptr_align, len_align, return_address);</span>
<span class="line" id="L883">        }</span>
<span class="line" id="L884"></span>
<span class="line" id="L885">        <span class="tok-kw">fn</span> <span class="tok-fn">resize</span>(</span>
<span class="line" id="L886">            self: *Self,</span>
<span class="line" id="L887">            buf: []<span class="tok-type">u8</span>,</span>
<span class="line" id="L888">            buf_align: <span class="tok-type">u29</span>,</span>
<span class="line" id="L889">            new_len: <span class="tok-type">usize</span>,</span>
<span class="line" id="L890">            len_align: <span class="tok-type">u29</span>,</span>
<span class="line" id="L891">            return_address: <span class="tok-type">usize</span>,</span>
<span class="line" id="L892">        ) ?<span class="tok-type">usize</span> {</span>
<span class="line" id="L893">            <span class="tok-kw">if</span> (self.fixed_buffer_allocator.ownsPtr(buf.ptr)) {</span>
<span class="line" id="L894">                <span class="tok-kw">return</span> FixedBufferAllocator.resize(&amp;self.fixed_buffer_allocator, buf, buf_align, new_len, len_align, return_address);</span>
<span class="line" id="L895">            } <span class="tok-kw">else</span> {</span>
<span class="line" id="L896">                <span class="tok-kw">return</span> self.fallback_allocator.rawResize(buf, buf_align, new_len, len_align, return_address);</span>
<span class="line" id="L897">            }</span>
<span class="line" id="L898">        }</span>
<span class="line" id="L899"></span>
<span class="line" id="L900">        <span class="tok-kw">fn</span> <span class="tok-fn">free</span>(</span>
<span class="line" id="L901">            self: *Self,</span>
<span class="line" id="L902">            buf: []<span class="tok-type">u8</span>,</span>
<span class="line" id="L903">            buf_align: <span class="tok-type">u29</span>,</span>
<span class="line" id="L904">            return_address: <span class="tok-type">usize</span>,</span>
<span class="line" id="L905">        ) <span class="tok-type">void</span> {</span>
<span class="line" id="L906">            <span class="tok-kw">if</span> (self.fixed_buffer_allocator.ownsPtr(buf.ptr)) {</span>
<span class="line" id="L907">                <span class="tok-kw">return</span> FixedBufferAllocator.free(&amp;self.fixed_buffer_allocator, buf, buf_align, return_address);</span>
<span class="line" id="L908">            } <span class="tok-kw">else</span> {</span>
<span class="line" id="L909">                <span class="tok-kw">return</span> self.fallback_allocator.rawFree(buf, buf_align, return_address);</span>
<span class="line" id="L910">            }</span>
<span class="line" id="L911">        }</span>
<span class="line" id="L912">    };</span>
<span class="line" id="L913">}</span>
<span class="line" id="L914"></span>
<span class="line" id="L915"><span class="tok-kw">test</span> <span class="tok-str">&quot;c_allocator&quot;</span> {</span>
<span class="line" id="L916">    <span class="tok-kw">if</span> (builtin.link_libc) {</span>
<span class="line" id="L917">        <span class="tok-kw">try</span> testAllocator(c_allocator);</span>
<span class="line" id="L918">        <span class="tok-kw">try</span> testAllocatorAligned(c_allocator);</span>
<span class="line" id="L919">        <span class="tok-kw">try</span> testAllocatorLargeAlignment(c_allocator);</span>
<span class="line" id="L920">        <span class="tok-kw">try</span> testAllocatorAlignedShrink(c_allocator);</span>
<span class="line" id="L921">    }</span>
<span class="line" id="L922">}</span>
<span class="line" id="L923"></span>
<span class="line" id="L924"><span class="tok-kw">test</span> <span class="tok-str">&quot;raw_c_allocator&quot;</span> {</span>
<span class="line" id="L925">    <span class="tok-kw">if</span> (builtin.link_libc) {</span>
<span class="line" id="L926">        <span class="tok-kw">try</span> testAllocator(raw_c_allocator);</span>
<span class="line" id="L927">    }</span>
<span class="line" id="L928">}</span>
<span class="line" id="L929"></span>
<span class="line" id="L930"><span class="tok-kw">test</span> <span class="tok-str">&quot;WasmPageAllocator internals&quot;</span> {</span>
<span class="line" id="L931">    <span class="tok-kw">if</span> (<span class="tok-kw">comptime</span> builtin.target.isWasm()) {</span>
<span class="line" id="L932">        <span class="tok-kw">const</span> conventional_memsize = WasmPageAllocator.conventional.totalPages() * mem.page_size;</span>
<span class="line" id="L933">        <span class="tok-kw">const</span> initial = <span class="tok-kw">try</span> page_allocator.alloc(<span class="tok-type">u8</span>, mem.page_size);</span>
<span class="line" id="L934">        <span class="tok-kw">try</span> testing.expect(<span class="tok-builtin">@ptrToInt</span>(initial.ptr) &lt; conventional_memsize); <span class="tok-comment">// If this isn't conventional, the rest of these tests don't make sense. Also we have a serious memory leak in the test suite.</span>
</span>
<span class="line" id="L935"></span>
<span class="line" id="L936">        <span class="tok-kw">var</span> inplace = <span class="tok-kw">try</span> page_allocator.realloc(initial, <span class="tok-number">1</span>);</span>
<span class="line" id="L937">        <span class="tok-kw">try</span> testing.expectEqual(initial.ptr, inplace.ptr);</span>
<span class="line" id="L938">        inplace = <span class="tok-kw">try</span> page_allocator.realloc(inplace, <span class="tok-number">4</span>);</span>
<span class="line" id="L939">        <span class="tok-kw">try</span> testing.expectEqual(initial.ptr, inplace.ptr);</span>
<span class="line" id="L940">        page_allocator.free(inplace);</span>
<span class="line" id="L941"></span>
<span class="line" id="L942">        <span class="tok-kw">const</span> reuse = <span class="tok-kw">try</span> page_allocator.alloc(<span class="tok-type">u8</span>, <span class="tok-number">1</span>);</span>
<span class="line" id="L943">        <span class="tok-kw">try</span> testing.expectEqual(initial.ptr, reuse.ptr);</span>
<span class="line" id="L944">        page_allocator.free(reuse);</span>
<span class="line" id="L945"></span>
<span class="line" id="L946">        <span class="tok-comment">// This segment may span conventional and extended which has really complex rules so we're just ignoring it for now.</span>
</span>
<span class="line" id="L947">        <span class="tok-kw">const</span> padding = <span class="tok-kw">try</span> page_allocator.alloc(<span class="tok-type">u8</span>, conventional_memsize);</span>
<span class="line" id="L948">        page_allocator.free(padding);</span>
<span class="line" id="L949"></span>
<span class="line" id="L950">        <span class="tok-kw">const</span> extended = <span class="tok-kw">try</span> page_allocator.alloc(<span class="tok-type">u8</span>, conventional_memsize);</span>
<span class="line" id="L951">        <span class="tok-kw">try</span> testing.expect(<span class="tok-builtin">@ptrToInt</span>(extended.ptr) &gt;= conventional_memsize);</span>
<span class="line" id="L952"></span>
<span class="line" id="L953">        <span class="tok-kw">const</span> use_small = <span class="tok-kw">try</span> page_allocator.alloc(<span class="tok-type">u8</span>, <span class="tok-number">1</span>);</span>
<span class="line" id="L954">        <span class="tok-kw">try</span> testing.expectEqual(initial.ptr, use_small.ptr);</span>
<span class="line" id="L955">        page_allocator.free(use_small);</span>
<span class="line" id="L956"></span>
<span class="line" id="L957">        inplace = <span class="tok-kw">try</span> page_allocator.realloc(extended, <span class="tok-number">1</span>);</span>
<span class="line" id="L958">        <span class="tok-kw">try</span> testing.expectEqual(extended.ptr, inplace.ptr);</span>
<span class="line" id="L959">        page_allocator.free(inplace);</span>
<span class="line" id="L960"></span>
<span class="line" id="L961">        <span class="tok-kw">const</span> reuse_extended = <span class="tok-kw">try</span> page_allocator.alloc(<span class="tok-type">u8</span>, conventional_memsize);</span>
<span class="line" id="L962">        <span class="tok-kw">try</span> testing.expectEqual(extended.ptr, reuse_extended.ptr);</span>
<span class="line" id="L963">        page_allocator.free(reuse_extended);</span>
<span class="line" id="L964">    }</span>
<span class="line" id="L965">}</span>
<span class="line" id="L966"></span>
<span class="line" id="L967"><span class="tok-kw">test</span> <span class="tok-str">&quot;PageAllocator&quot;</span> {</span>
<span class="line" id="L968">    <span class="tok-kw">const</span> allocator = page_allocator;</span>
<span class="line" id="L969">    <span class="tok-kw">try</span> testAllocator(allocator);</span>
<span class="line" id="L970">    <span class="tok-kw">try</span> testAllocatorAligned(allocator);</span>
<span class="line" id="L971">    <span class="tok-kw">if</span> (!builtin.target.isWasm()) {</span>
<span class="line" id="L972">        <span class="tok-kw">try</span> testAllocatorLargeAlignment(allocator);</span>
<span class="line" id="L973">        <span class="tok-kw">try</span> testAllocatorAlignedShrink(allocator);</span>
<span class="line" id="L974">    }</span>
<span class="line" id="L975"></span>
<span class="line" id="L976">    <span class="tok-kw">if</span> (builtin.os.tag == .windows) {</span>
<span class="line" id="L977">        <span class="tok-comment">// Trying really large alignment. As mentionned in the implementation,</span>
</span>
<span class="line" id="L978">        <span class="tok-comment">// VirtualAlloc returns 64K aligned addresses. We want to make sure</span>
</span>
<span class="line" id="L979">        <span class="tok-comment">// PageAllocator works beyond that, as it's not tested by</span>
</span>
<span class="line" id="L980">        <span class="tok-comment">// `testAllocatorLargeAlignment`.</span>
</span>
<span class="line" id="L981">        <span class="tok-kw">const</span> slice = <span class="tok-kw">try</span> allocator.alignedAlloc(<span class="tok-type">u8</span>, <span class="tok-number">1</span> &lt;&lt; <span class="tok-number">20</span>, <span class="tok-number">128</span>);</span>
<span class="line" id="L982">        slice[<span class="tok-number">0</span>] = <span class="tok-number">0x12</span>;</span>
<span class="line" id="L983">        slice[<span class="tok-number">127</span>] = <span class="tok-number">0x34</span>;</span>
<span class="line" id="L984">        allocator.free(slice);</span>
<span class="line" id="L985">    }</span>
<span class="line" id="L986">    {</span>
<span class="line" id="L987">        <span class="tok-kw">var</span> buf = <span class="tok-kw">try</span> allocator.alloc(<span class="tok-type">u8</span>, mem.page_size + <span class="tok-number">1</span>);</span>
<span class="line" id="L988">        <span class="tok-kw">defer</span> allocator.free(buf);</span>
<span class="line" id="L989">        buf = <span class="tok-kw">try</span> allocator.realloc(buf, <span class="tok-number">1</span>); <span class="tok-comment">// shrink past the page boundary</span>
</span>
<span class="line" id="L990">    }</span>
<span class="line" id="L991">}</span>
<span class="line" id="L992"></span>
<span class="line" id="L993"><span class="tok-kw">test</span> <span class="tok-str">&quot;HeapAllocator&quot;</span> {</span>
<span class="line" id="L994">    <span class="tok-kw">if</span> (builtin.os.tag == .windows) {</span>
<span class="line" id="L995">        <span class="tok-kw">var</span> heap_allocator = HeapAllocator.init();</span>
<span class="line" id="L996">        <span class="tok-kw">defer</span> heap_allocator.deinit();</span>
<span class="line" id="L997">        <span class="tok-kw">const</span> allocator = heap_allocator.allocator();</span>
<span class="line" id="L998"></span>
<span class="line" id="L999">        <span class="tok-kw">try</span> testAllocator(allocator);</span>
<span class="line" id="L1000">        <span class="tok-kw">try</span> testAllocatorAligned(allocator);</span>
<span class="line" id="L1001">        <span class="tok-kw">try</span> testAllocatorLargeAlignment(allocator);</span>
<span class="line" id="L1002">        <span class="tok-kw">try</span> testAllocatorAlignedShrink(allocator);</span>
<span class="line" id="L1003">    }</span>
<span class="line" id="L1004">}</span>
<span class="line" id="L1005"></span>
<span class="line" id="L1006"><span class="tok-kw">test</span> <span class="tok-str">&quot;ArenaAllocator&quot;</span> {</span>
<span class="line" id="L1007">    <span class="tok-kw">var</span> arena_allocator = ArenaAllocator.init(page_allocator);</span>
<span class="line" id="L1008">    <span class="tok-kw">defer</span> arena_allocator.deinit();</span>
<span class="line" id="L1009">    <span class="tok-kw">const</span> allocator = arena_allocator.allocator();</span>
<span class="line" id="L1010"></span>
<span class="line" id="L1011">    <span class="tok-kw">try</span> testAllocator(allocator);</span>
<span class="line" id="L1012">    <span class="tok-kw">try</span> testAllocatorAligned(allocator);</span>
<span class="line" id="L1013">    <span class="tok-kw">try</span> testAllocatorLargeAlignment(allocator);</span>
<span class="line" id="L1014">    <span class="tok-kw">try</span> testAllocatorAlignedShrink(allocator);</span>
<span class="line" id="L1015">}</span>
<span class="line" id="L1016"></span>
<span class="line" id="L1017"><span class="tok-kw">var</span> test_fixed_buffer_allocator_memory: [<span class="tok-number">800000</span> * <span class="tok-builtin">@sizeOf</span>(<span class="tok-type">u64</span>)]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L1018"><span class="tok-kw">test</span> <span class="tok-str">&quot;FixedBufferAllocator&quot;</span> {</span>
<span class="line" id="L1019">    <span class="tok-kw">var</span> fixed_buffer_allocator = mem.validationWrap(FixedBufferAllocator.init(test_fixed_buffer_allocator_memory[<span class="tok-number">0</span>..]));</span>
<span class="line" id="L1020">    <span class="tok-kw">const</span> allocator = fixed_buffer_allocator.allocator();</span>
<span class="line" id="L1021"></span>
<span class="line" id="L1022">    <span class="tok-kw">try</span> testAllocator(allocator);</span>
<span class="line" id="L1023">    <span class="tok-kw">try</span> testAllocatorAligned(allocator);</span>
<span class="line" id="L1024">    <span class="tok-kw">try</span> testAllocatorLargeAlignment(allocator);</span>
<span class="line" id="L1025">    <span class="tok-kw">try</span> testAllocatorAlignedShrink(allocator);</span>
<span class="line" id="L1026">}</span>
<span class="line" id="L1027"></span>
<span class="line" id="L1028"><span class="tok-kw">test</span> <span class="tok-str">&quot;FixedBufferAllocator.reset&quot;</span> {</span>
<span class="line" id="L1029">    <span class="tok-kw">var</span> buf: [<span class="tok-number">8</span>]<span class="tok-type">u8</span> <span class="tok-kw">align</span>(<span class="tok-builtin">@alignOf</span>(<span class="tok-type">u64</span>)) = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L1030">    <span class="tok-kw">var</span> fba = FixedBufferAllocator.init(buf[<span class="tok-number">0</span>..]);</span>
<span class="line" id="L1031">    <span class="tok-kw">const</span> allocator = fba.allocator();</span>
<span class="line" id="L1032"></span>
<span class="line" id="L1033">    <span class="tok-kw">const</span> X = <span class="tok-number">0xeeeeeeeeeeeeeeee</span>;</span>
<span class="line" id="L1034">    <span class="tok-kw">const</span> Y = <span class="tok-number">0xffffffffffffffff</span>;</span>
<span class="line" id="L1035"></span>
<span class="line" id="L1036">    <span class="tok-kw">var</span> x = <span class="tok-kw">try</span> allocator.create(<span class="tok-type">u64</span>);</span>
<span class="line" id="L1037">    x.* = X;</span>
<span class="line" id="L1038">    <span class="tok-kw">try</span> testing.expectError(<span class="tok-kw">error</span>.OutOfMemory, allocator.create(<span class="tok-type">u64</span>));</span>
<span class="line" id="L1039"></span>
<span class="line" id="L1040">    fba.reset();</span>
<span class="line" id="L1041">    <span class="tok-kw">var</span> y = <span class="tok-kw">try</span> allocator.create(<span class="tok-type">u64</span>);</span>
<span class="line" id="L1042">    y.* = Y;</span>
<span class="line" id="L1043"></span>
<span class="line" id="L1044">    <span class="tok-comment">// we expect Y to have overwritten X.</span>
</span>
<span class="line" id="L1045">    <span class="tok-kw">try</span> testing.expect(x.* == y.*);</span>
<span class="line" id="L1046">    <span class="tok-kw">try</span> testing.expect(y.* == Y);</span>
<span class="line" id="L1047">}</span>
<span class="line" id="L1048"></span>
<span class="line" id="L1049"><span class="tok-kw">test</span> <span class="tok-str">&quot;StackFallbackAllocator&quot;</span> {</span>
<span class="line" id="L1050">    <span class="tok-kw">const</span> fallback_allocator = page_allocator;</span>
<span class="line" id="L1051">    <span class="tok-kw">var</span> stack_allocator = stackFallback(<span class="tok-number">4096</span>, fallback_allocator);</span>
<span class="line" id="L1052"></span>
<span class="line" id="L1053">    <span class="tok-kw">try</span> testAllocator(stack_allocator.get());</span>
<span class="line" id="L1054">    <span class="tok-kw">try</span> testAllocatorAligned(stack_allocator.get());</span>
<span class="line" id="L1055">    <span class="tok-kw">try</span> testAllocatorLargeAlignment(stack_allocator.get());</span>
<span class="line" id="L1056">    <span class="tok-kw">try</span> testAllocatorAlignedShrink(stack_allocator.get());</span>
<span class="line" id="L1057">}</span>
<span class="line" id="L1058"></span>
<span class="line" id="L1059"><span class="tok-kw">test</span> <span class="tok-str">&quot;FixedBufferAllocator Reuse memory on realloc&quot;</span> {</span>
<span class="line" id="L1060">    <span class="tok-kw">var</span> small_fixed_buffer: [<span class="tok-number">10</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L1061">    <span class="tok-comment">// check if we re-use the memory</span>
</span>
<span class="line" id="L1062">    {</span>
<span class="line" id="L1063">        <span class="tok-kw">var</span> fixed_buffer_allocator = FixedBufferAllocator.init(small_fixed_buffer[<span class="tok-number">0</span>..]);</span>
<span class="line" id="L1064">        <span class="tok-kw">const</span> allocator = fixed_buffer_allocator.allocator();</span>
<span class="line" id="L1065"></span>
<span class="line" id="L1066">        <span class="tok-kw">var</span> slice0 = <span class="tok-kw">try</span> allocator.alloc(<span class="tok-type">u8</span>, <span class="tok-number">5</span>);</span>
<span class="line" id="L1067">        <span class="tok-kw">try</span> testing.expect(slice0.len == <span class="tok-number">5</span>);</span>
<span class="line" id="L1068">        <span class="tok-kw">var</span> slice1 = <span class="tok-kw">try</span> allocator.realloc(slice0, <span class="tok-number">10</span>);</span>
<span class="line" id="L1069">        <span class="tok-kw">try</span> testing.expect(slice1.ptr == slice0.ptr);</span>
<span class="line" id="L1070">        <span class="tok-kw">try</span> testing.expect(slice1.len == <span class="tok-number">10</span>);</span>
<span class="line" id="L1071">        <span class="tok-kw">try</span> testing.expectError(<span class="tok-kw">error</span>.OutOfMemory, allocator.realloc(slice1, <span class="tok-number">11</span>));</span>
<span class="line" id="L1072">    }</span>
<span class="line" id="L1073">    <span class="tok-comment">// check that we don't re-use the memory if it's not the most recent block</span>
</span>
<span class="line" id="L1074">    {</span>
<span class="line" id="L1075">        <span class="tok-kw">var</span> fixed_buffer_allocator = FixedBufferAllocator.init(small_fixed_buffer[<span class="tok-number">0</span>..]);</span>
<span class="line" id="L1076">        <span class="tok-kw">const</span> allocator = fixed_buffer_allocator.allocator();</span>
<span class="line" id="L1077"></span>
<span class="line" id="L1078">        <span class="tok-kw">var</span> slice0 = <span class="tok-kw">try</span> allocator.alloc(<span class="tok-type">u8</span>, <span class="tok-number">2</span>);</span>
<span class="line" id="L1079">        slice0[<span class="tok-number">0</span>] = <span class="tok-number">1</span>;</span>
<span class="line" id="L1080">        slice0[<span class="tok-number">1</span>] = <span class="tok-number">2</span>;</span>
<span class="line" id="L1081">        <span class="tok-kw">var</span> slice1 = <span class="tok-kw">try</span> allocator.alloc(<span class="tok-type">u8</span>, <span class="tok-number">2</span>);</span>
<span class="line" id="L1082">        <span class="tok-kw">var</span> slice2 = <span class="tok-kw">try</span> allocator.realloc(slice0, <span class="tok-number">4</span>);</span>
<span class="line" id="L1083">        <span class="tok-kw">try</span> testing.expect(slice0.ptr != slice2.ptr);</span>
<span class="line" id="L1084">        <span class="tok-kw">try</span> testing.expect(slice1.ptr != slice2.ptr);</span>
<span class="line" id="L1085">        <span class="tok-kw">try</span> testing.expect(slice2[<span class="tok-number">0</span>] == <span class="tok-number">1</span>);</span>
<span class="line" id="L1086">        <span class="tok-kw">try</span> testing.expect(slice2[<span class="tok-number">1</span>] == <span class="tok-number">2</span>);</span>
<span class="line" id="L1087">    }</span>
<span class="line" id="L1088">}</span>
<span class="line" id="L1089"></span>
<span class="line" id="L1090"><span class="tok-kw">test</span> <span class="tok-str">&quot;Thread safe FixedBufferAllocator&quot;</span> {</span>
<span class="line" id="L1091">    <span class="tok-kw">var</span> fixed_buffer_allocator = FixedBufferAllocator.init(test_fixed_buffer_allocator_memory[<span class="tok-number">0</span>..]);</span>
<span class="line" id="L1092"></span>
<span class="line" id="L1093">    <span class="tok-kw">try</span> testAllocator(fixed_buffer_allocator.threadSafeAllocator());</span>
<span class="line" id="L1094">    <span class="tok-kw">try</span> testAllocatorAligned(fixed_buffer_allocator.threadSafeAllocator());</span>
<span class="line" id="L1095">    <span class="tok-kw">try</span> testAllocatorLargeAlignment(fixed_buffer_allocator.threadSafeAllocator());</span>
<span class="line" id="L1096">    <span class="tok-kw">try</span> testAllocatorAlignedShrink(fixed_buffer_allocator.threadSafeAllocator());</span>
<span class="line" id="L1097">}</span>
<span class="line" id="L1098"></span>
<span class="line" id="L1099"><span class="tok-comment">/// This one should not try alignments that exceed what C malloc can handle.</span></span>
<span class="line" id="L1100"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">testAllocator</span>(base_allocator: mem.Allocator) !<span class="tok-type">void</span> {</span>
<span class="line" id="L1101">    <span class="tok-kw">var</span> validationAllocator = mem.validationWrap(base_allocator);</span>
<span class="line" id="L1102">    <span class="tok-kw">const</span> allocator = validationAllocator.allocator();</span>
<span class="line" id="L1103"></span>
<span class="line" id="L1104">    <span class="tok-kw">var</span> slice = <span class="tok-kw">try</span> allocator.alloc(*<span class="tok-type">i32</span>, <span class="tok-number">100</span>);</span>
<span class="line" id="L1105">    <span class="tok-kw">try</span> testing.expect(slice.len == <span class="tok-number">100</span>);</span>
<span class="line" id="L1106">    <span class="tok-kw">for</span> (slice) |*item, i| {</span>
<span class="line" id="L1107">        item.* = <span class="tok-kw">try</span> allocator.create(<span class="tok-type">i32</span>);</span>
<span class="line" id="L1108">        item.*.* = <span class="tok-builtin">@intCast</span>(<span class="tok-type">i32</span>, i);</span>
<span class="line" id="L1109">    }</span>
<span class="line" id="L1110"></span>
<span class="line" id="L1111">    slice = <span class="tok-kw">try</span> allocator.realloc(slice, <span class="tok-number">20000</span>);</span>
<span class="line" id="L1112">    <span class="tok-kw">try</span> testing.expect(slice.len == <span class="tok-number">20000</span>);</span>
<span class="line" id="L1113"></span>
<span class="line" id="L1114">    <span class="tok-kw">for</span> (slice[<span class="tok-number">0</span>..<span class="tok-number">100</span>]) |item, i| {</span>
<span class="line" id="L1115">        <span class="tok-kw">try</span> testing.expect(item.* == <span class="tok-builtin">@intCast</span>(<span class="tok-type">i32</span>, i));</span>
<span class="line" id="L1116">        allocator.destroy(item);</span>
<span class="line" id="L1117">    }</span>
<span class="line" id="L1118"></span>
<span class="line" id="L1119">    slice = allocator.shrink(slice, <span class="tok-number">50</span>);</span>
<span class="line" id="L1120">    <span class="tok-kw">try</span> testing.expect(slice.len == <span class="tok-number">50</span>);</span>
<span class="line" id="L1121">    slice = allocator.shrink(slice, <span class="tok-number">25</span>);</span>
<span class="line" id="L1122">    <span class="tok-kw">try</span> testing.expect(slice.len == <span class="tok-number">25</span>);</span>
<span class="line" id="L1123">    slice = allocator.shrink(slice, <span class="tok-number">0</span>);</span>
<span class="line" id="L1124">    <span class="tok-kw">try</span> testing.expect(slice.len == <span class="tok-number">0</span>);</span>
<span class="line" id="L1125">    slice = <span class="tok-kw">try</span> allocator.realloc(slice, <span class="tok-number">10</span>);</span>
<span class="line" id="L1126">    <span class="tok-kw">try</span> testing.expect(slice.len == <span class="tok-number">10</span>);</span>
<span class="line" id="L1127"></span>
<span class="line" id="L1128">    allocator.free(slice);</span>
<span class="line" id="L1129"></span>
<span class="line" id="L1130">    <span class="tok-comment">// Zero-length allocation</span>
</span>
<span class="line" id="L1131">    <span class="tok-kw">var</span> empty = <span class="tok-kw">try</span> allocator.alloc(<span class="tok-type">u8</span>, <span class="tok-number">0</span>);</span>
<span class="line" id="L1132">    allocator.free(empty);</span>
<span class="line" id="L1133">    <span class="tok-comment">// Allocation with zero-sized types</span>
</span>
<span class="line" id="L1134">    <span class="tok-kw">const</span> zero_bit_ptr = <span class="tok-kw">try</span> allocator.create(<span class="tok-type">u0</span>);</span>
<span class="line" id="L1135">    zero_bit_ptr.* = <span class="tok-number">0</span>;</span>
<span class="line" id="L1136">    allocator.destroy(zero_bit_ptr);</span>
<span class="line" id="L1137"></span>
<span class="line" id="L1138">    <span class="tok-kw">const</span> oversize = <span class="tok-kw">try</span> allocator.allocAdvanced(<span class="tok-type">u32</span>, <span class="tok-null">null</span>, <span class="tok-number">5</span>, .at_least);</span>
<span class="line" id="L1139">    <span class="tok-kw">try</span> testing.expect(oversize.len &gt;= <span class="tok-number">5</span>);</span>
<span class="line" id="L1140">    <span class="tok-kw">for</span> (oversize) |*item| {</span>
<span class="line" id="L1141">        item.* = <span class="tok-number">0xDEADBEEF</span>;</span>
<span class="line" id="L1142">    }</span>
<span class="line" id="L1143">    allocator.free(oversize);</span>
<span class="line" id="L1144">}</span>
<span class="line" id="L1145"></span>
<span class="line" id="L1146"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">testAllocatorAligned</span>(base_allocator: mem.Allocator) !<span class="tok-type">void</span> {</span>
<span class="line" id="L1147">    <span class="tok-kw">var</span> validationAllocator = mem.validationWrap(base_allocator);</span>
<span class="line" id="L1148">    <span class="tok-kw">const</span> allocator = validationAllocator.allocator();</span>
<span class="line" id="L1149"></span>
<span class="line" id="L1150">    <span class="tok-comment">// Test a few alignment values, smaller and bigger than the type's one</span>
</span>
<span class="line" id="L1151">    <span class="tok-kw">inline</span> <span class="tok-kw">for</span> ([_]<span class="tok-type">u29</span>{ <span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">4</span>, <span class="tok-number">8</span>, <span class="tok-number">16</span>, <span class="tok-number">32</span>, <span class="tok-number">64</span> }) |alignment| {</span>
<span class="line" id="L1152">        <span class="tok-comment">// initial</span>
</span>
<span class="line" id="L1153">        <span class="tok-kw">var</span> slice = <span class="tok-kw">try</span> allocator.alignedAlloc(<span class="tok-type">u8</span>, alignment, <span class="tok-number">10</span>);</span>
<span class="line" id="L1154">        <span class="tok-kw">try</span> testing.expect(slice.len == <span class="tok-number">10</span>);</span>
<span class="line" id="L1155">        <span class="tok-comment">// grow</span>
</span>
<span class="line" id="L1156">        slice = <span class="tok-kw">try</span> allocator.realloc(slice, <span class="tok-number">100</span>);</span>
<span class="line" id="L1157">        <span class="tok-kw">try</span> testing.expect(slice.len == <span class="tok-number">100</span>);</span>
<span class="line" id="L1158">        <span class="tok-comment">// shrink</span>
</span>
<span class="line" id="L1159">        slice = allocator.shrink(slice, <span class="tok-number">10</span>);</span>
<span class="line" id="L1160">        <span class="tok-kw">try</span> testing.expect(slice.len == <span class="tok-number">10</span>);</span>
<span class="line" id="L1161">        <span class="tok-comment">// go to zero</span>
</span>
<span class="line" id="L1162">        slice = allocator.shrink(slice, <span class="tok-number">0</span>);</span>
<span class="line" id="L1163">        <span class="tok-kw">try</span> testing.expect(slice.len == <span class="tok-number">0</span>);</span>
<span class="line" id="L1164">        <span class="tok-comment">// realloc from zero</span>
</span>
<span class="line" id="L1165">        slice = <span class="tok-kw">try</span> allocator.realloc(slice, <span class="tok-number">100</span>);</span>
<span class="line" id="L1166">        <span class="tok-kw">try</span> testing.expect(slice.len == <span class="tok-number">100</span>);</span>
<span class="line" id="L1167">        <span class="tok-comment">// shrink with shrink</span>
</span>
<span class="line" id="L1168">        slice = allocator.shrink(slice, <span class="tok-number">10</span>);</span>
<span class="line" id="L1169">        <span class="tok-kw">try</span> testing.expect(slice.len == <span class="tok-number">10</span>);</span>
<span class="line" id="L1170">        <span class="tok-comment">// shrink to zero</span>
</span>
<span class="line" id="L1171">        slice = allocator.shrink(slice, <span class="tok-number">0</span>);</span>
<span class="line" id="L1172">        <span class="tok-kw">try</span> testing.expect(slice.len == <span class="tok-number">0</span>);</span>
<span class="line" id="L1173">    }</span>
<span class="line" id="L1174">}</span>
<span class="line" id="L1175"></span>
<span class="line" id="L1176"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">testAllocatorLargeAlignment</span>(base_allocator: mem.Allocator) !<span class="tok-type">void</span> {</span>
<span class="line" id="L1177">    <span class="tok-kw">var</span> validationAllocator = mem.validationWrap(base_allocator);</span>
<span class="line" id="L1178">    <span class="tok-kw">const</span> allocator = validationAllocator.allocator();</span>
<span class="line" id="L1179"></span>
<span class="line" id="L1180">    <span class="tok-comment">//Maybe a platform's page_size is actually the same as or</span>
</span>
<span class="line" id="L1181">    <span class="tok-comment">//  very near usize?</span>
</span>
<span class="line" id="L1182">    <span class="tok-kw">if</span> (mem.page_size &lt;&lt; <span class="tok-number">2</span> &gt; maxInt(<span class="tok-type">usize</span>)) <span class="tok-kw">return</span>;</span>
<span class="line" id="L1183"></span>
<span class="line" id="L1184">    <span class="tok-kw">const</span> USizeShift = std.meta.Int(.unsigned, std.math.log2(<span class="tok-builtin">@bitSizeOf</span>(<span class="tok-type">usize</span>)));</span>
<span class="line" id="L1185">    <span class="tok-kw">const</span> large_align = <span class="tok-builtin">@as</span>(<span class="tok-type">u29</span>, mem.page_size &lt;&lt; <span class="tok-number">2</span>);</span>
<span class="line" id="L1186"></span>
<span class="line" id="L1187">    <span class="tok-kw">var</span> align_mask: <span class="tok-type">usize</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L1188">    _ = <span class="tok-builtin">@shlWithOverflow</span>(<span class="tok-type">usize</span>, ~<span class="tok-builtin">@as</span>(<span class="tok-type">usize</span>, <span class="tok-number">0</span>), <span class="tok-builtin">@as</span>(USizeShift, <span class="tok-builtin">@ctz</span>(<span class="tok-type">u29</span>, large_align)), &amp;align_mask);</span>
<span class="line" id="L1189"></span>
<span class="line" id="L1190">    <span class="tok-kw">var</span> slice = <span class="tok-kw">try</span> allocator.alignedAlloc(<span class="tok-type">u8</span>, large_align, <span class="tok-number">500</span>);</span>
<span class="line" id="L1191">    <span class="tok-kw">try</span> testing.expect(<span class="tok-builtin">@ptrToInt</span>(slice.ptr) &amp; align_mask == <span class="tok-builtin">@ptrToInt</span>(slice.ptr));</span>
<span class="line" id="L1192"></span>
<span class="line" id="L1193">    slice = allocator.shrink(slice, <span class="tok-number">100</span>);</span>
<span class="line" id="L1194">    <span class="tok-kw">try</span> testing.expect(<span class="tok-builtin">@ptrToInt</span>(slice.ptr) &amp; align_mask == <span class="tok-builtin">@ptrToInt</span>(slice.ptr));</span>
<span class="line" id="L1195"></span>
<span class="line" id="L1196">    slice = <span class="tok-kw">try</span> allocator.realloc(slice, <span class="tok-number">5000</span>);</span>
<span class="line" id="L1197">    <span class="tok-kw">try</span> testing.expect(<span class="tok-builtin">@ptrToInt</span>(slice.ptr) &amp; align_mask == <span class="tok-builtin">@ptrToInt</span>(slice.ptr));</span>
<span class="line" id="L1198"></span>
<span class="line" id="L1199">    slice = allocator.shrink(slice, <span class="tok-number">10</span>);</span>
<span class="line" id="L1200">    <span class="tok-kw">try</span> testing.expect(<span class="tok-builtin">@ptrToInt</span>(slice.ptr) &amp; align_mask == <span class="tok-builtin">@ptrToInt</span>(slice.ptr));</span>
<span class="line" id="L1201"></span>
<span class="line" id="L1202">    slice = <span class="tok-kw">try</span> allocator.realloc(slice, <span class="tok-number">20000</span>);</span>
<span class="line" id="L1203">    <span class="tok-kw">try</span> testing.expect(<span class="tok-builtin">@ptrToInt</span>(slice.ptr) &amp; align_mask == <span class="tok-builtin">@ptrToInt</span>(slice.ptr));</span>
<span class="line" id="L1204"></span>
<span class="line" id="L1205">    allocator.free(slice);</span>
<span class="line" id="L1206">}</span>
<span class="line" id="L1207"></span>
<span class="line" id="L1208"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">testAllocatorAlignedShrink</span>(base_allocator: mem.Allocator) !<span class="tok-type">void</span> {</span>
<span class="line" id="L1209">    <span class="tok-kw">var</span> validationAllocator = mem.validationWrap(base_allocator);</span>
<span class="line" id="L1210">    <span class="tok-kw">const</span> allocator = validationAllocator.allocator();</span>
<span class="line" id="L1211"></span>
<span class="line" id="L1212">    <span class="tok-kw">var</span> debug_buffer: [<span class="tok-number">1000</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L1213">    <span class="tok-kw">var</span> fib = FixedBufferAllocator.init(&amp;debug_buffer);</span>
<span class="line" id="L1214">    <span class="tok-kw">const</span> debug_allocator = fib.allocator();</span>
<span class="line" id="L1215"></span>
<span class="line" id="L1216">    <span class="tok-kw">const</span> alloc_size = mem.page_size * <span class="tok-number">2</span> + <span class="tok-number">50</span>;</span>
<span class="line" id="L1217">    <span class="tok-kw">var</span> slice = <span class="tok-kw">try</span> allocator.alignedAlloc(<span class="tok-type">u8</span>, <span class="tok-number">16</span>, alloc_size);</span>
<span class="line" id="L1218">    <span class="tok-kw">defer</span> allocator.free(slice);</span>
<span class="line" id="L1219"></span>
<span class="line" id="L1220">    <span class="tok-kw">var</span> stuff_to_free = std.ArrayList([]<span class="tok-kw">align</span>(<span class="tok-number">16</span>) <span class="tok-type">u8</span>).init(debug_allocator);</span>
<span class="line" id="L1221">    <span class="tok-comment">// On Windows, VirtualAlloc returns addresses aligned to a 64K boundary,</span>
</span>
<span class="line" id="L1222">    <span class="tok-comment">// which is 16 pages, hence the 32. This test may require to increase</span>
</span>
<span class="line" id="L1223">    <span class="tok-comment">// the size of the allocations feeding the `allocator` parameter if they</span>
</span>
<span class="line" id="L1224">    <span class="tok-comment">// fail, because of this high over-alignment we want to have.</span>
</span>
<span class="line" id="L1225">    <span class="tok-kw">while</span> (<span class="tok-builtin">@ptrToInt</span>(slice.ptr) == mem.alignForward(<span class="tok-builtin">@ptrToInt</span>(slice.ptr), mem.page_size * <span class="tok-number">32</span>)) {</span>
<span class="line" id="L1226">        <span class="tok-kw">try</span> stuff_to_free.append(slice);</span>
<span class="line" id="L1227">        slice = <span class="tok-kw">try</span> allocator.alignedAlloc(<span class="tok-type">u8</span>, <span class="tok-number">16</span>, alloc_size);</span>
<span class="line" id="L1228">    }</span>
<span class="line" id="L1229">    <span class="tok-kw">while</span> (stuff_to_free.popOrNull()) |item| {</span>
<span class="line" id="L1230">        allocator.free(item);</span>
<span class="line" id="L1231">    }</span>
<span class="line" id="L1232">    slice[<span class="tok-number">0</span>] = <span class="tok-number">0x12</span>;</span>
<span class="line" id="L1233">    slice[<span class="tok-number">60</span>] = <span class="tok-number">0x34</span>;</span>
<span class="line" id="L1234"></span>
<span class="line" id="L1235">    <span class="tok-comment">// realloc to a smaller size but with a larger alignment</span>
</span>
<span class="line" id="L1236">    slice = <span class="tok-kw">try</span> allocator.reallocAdvanced(slice, mem.page_size * <span class="tok-number">32</span>, alloc_size / <span class="tok-number">2</span>, .exact);</span>
<span class="line" id="L1237">    <span class="tok-kw">try</span> testing.expect(slice[<span class="tok-number">0</span>] == <span class="tok-number">0x12</span>);</span>
<span class="line" id="L1238">    <span class="tok-kw">try</span> testing.expect(slice[<span class="tok-number">60</span>] == <span class="tok-number">0x34</span>);</span>
<span class="line" id="L1239">}</span>
<span class="line" id="L1240"></span>
<span class="line" id="L1241"><span class="tok-kw">test</span> <span class="tok-str">&quot;heap&quot;</span> {</span>
<span class="line" id="L1242">    _ = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;heap/logging_allocator.zig&quot;</span>);</span>
<span class="line" id="L1243">    _ = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;heap/log_to_writer_allocator.zig&quot;</span>);</span>
<span class="line" id="L1244">}</span>
<span class="line" id="L1245"></span>
</code></pre></body>
</html>