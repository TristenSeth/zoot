<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">    <title>mem.zig - source view</title>
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
<span class="line" id="L3"><span class="tok-kw">const</span> debug = std.debug;</span>
<span class="line" id="L4"><span class="tok-kw">const</span> assert = debug.assert;</span>
<span class="line" id="L5"><span class="tok-kw">const</span> math = std.math;</span>
<span class="line" id="L6"><span class="tok-kw">const</span> mem = <span class="tok-builtin">@This</span>();</span>
<span class="line" id="L7"><span class="tok-kw">const</span> meta = std.meta;</span>
<span class="line" id="L8"><span class="tok-kw">const</span> trait = meta.trait;</span>
<span class="line" id="L9"><span class="tok-kw">const</span> testing = std.testing;</span>
<span class="line" id="L10"><span class="tok-kw">const</span> Endian = std.builtin.Endian;</span>
<span class="line" id="L11"><span class="tok-kw">const</span> native_endian = builtin.cpu.arch.endian();</span>
<span class="line" id="L12"></span>
<span class="line" id="L13"><span class="tok-comment">/// Compile time known minimum page size.</span></span>
<span class="line" id="L14"><span class="tok-comment">/// https://github.com/ziglang/zig/issues/4082</span></span>
<span class="line" id="L15"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> page_size = <span class="tok-kw">switch</span> (builtin.cpu.arch) {</span>
<span class="line" id="L16">    .wasm32, .wasm64 =&gt; <span class="tok-number">64</span> * <span class="tok-number">1024</span>,</span>
<span class="line" id="L17">    .aarch64 =&gt; <span class="tok-kw">switch</span> (builtin.os.tag) {</span>
<span class="line" id="L18">        .macos, .ios, .watchos, .tvos =&gt; <span class="tok-number">16</span> * <span class="tok-number">1024</span>,</span>
<span class="line" id="L19">        <span class="tok-kw">else</span> =&gt; <span class="tok-number">4</span> * <span class="tok-number">1024</span>,</span>
<span class="line" id="L20">    },</span>
<span class="line" id="L21">    .sparc64 =&gt; <span class="tok-number">8</span> * <span class="tok-number">1024</span>,</span>
<span class="line" id="L22">    <span class="tok-kw">else</span> =&gt; <span class="tok-number">4</span> * <span class="tok-number">1024</span>,</span>
<span class="line" id="L23">};</span>
<span class="line" id="L24"></span>
<span class="line" id="L25"><span class="tok-comment">/// The standard library currently thoroughly depends on byte size</span></span>
<span class="line" id="L26"><span class="tok-comment">/// being 8 bits.  (see the use of u8 throughout allocation code as</span></span>
<span class="line" id="L27"><span class="tok-comment">/// the &quot;byte&quot; type.)  Code which depends on this can reference this</span></span>
<span class="line" id="L28"><span class="tok-comment">/// declaration.  If we ever try to port the standard library to a</span></span>
<span class="line" id="L29"><span class="tok-comment">/// non-8-bit-byte platform, this will allow us to search for things</span></span>
<span class="line" id="L30"><span class="tok-comment">/// which need to be updated.</span></span>
<span class="line" id="L31"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> byte_size_in_bits = <span class="tok-number">8</span>;</span>
<span class="line" id="L32"></span>
<span class="line" id="L33"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> Allocator = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;mem/Allocator.zig&quot;</span>);</span>
<span class="line" id="L34"></span>
<span class="line" id="L35"><span class="tok-comment">/// Detects and asserts if the std.mem.Allocator interface is violated by the caller</span></span>
<span class="line" id="L36"><span class="tok-comment">/// or the allocator.</span></span>
<span class="line" id="L37"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">ValidationAllocator</span>(<span class="tok-kw">comptime</span> T: <span class="tok-type">type</span>) <span class="tok-type">type</span> {</span>
<span class="line" id="L38">    <span class="tok-kw">return</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L39">        <span class="tok-kw">const</span> Self = <span class="tok-builtin">@This</span>();</span>
<span class="line" id="L40"></span>
<span class="line" id="L41">        underlying_allocator: T,</span>
<span class="line" id="L42"></span>
<span class="line" id="L43">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">init</span>(underlying_allocator: T) <span class="tok-builtin">@This</span>() {</span>
<span class="line" id="L44">            <span class="tok-kw">return</span> .{</span>
<span class="line" id="L45">                .underlying_allocator = underlying_allocator,</span>
<span class="line" id="L46">            };</span>
<span class="line" id="L47">        }</span>
<span class="line" id="L48"></span>
<span class="line" id="L49">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">allocator</span>(self: *Self) Allocator {</span>
<span class="line" id="L50">            <span class="tok-kw">return</span> Allocator.init(self, alloc, resize, free);</span>
<span class="line" id="L51">        }</span>
<span class="line" id="L52"></span>
<span class="line" id="L53">        <span class="tok-kw">fn</span> <span class="tok-fn">getUnderlyingAllocatorPtr</span>(self: *Self) Allocator {</span>
<span class="line" id="L54">            <span class="tok-kw">if</span> (T == Allocator) <span class="tok-kw">return</span> self.underlying_allocator;</span>
<span class="line" id="L55">            <span class="tok-kw">return</span> self.underlying_allocator.allocator();</span>
<span class="line" id="L56">        }</span>
<span class="line" id="L57"></span>
<span class="line" id="L58">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">alloc</span>(</span>
<span class="line" id="L59">            self: *Self,</span>
<span class="line" id="L60">            n: <span class="tok-type">usize</span>,</span>
<span class="line" id="L61">            ptr_align: <span class="tok-type">u29</span>,</span>
<span class="line" id="L62">            len_align: <span class="tok-type">u29</span>,</span>
<span class="line" id="L63">            ret_addr: <span class="tok-type">usize</span>,</span>
<span class="line" id="L64">        ) Allocator.Error![]<span class="tok-type">u8</span> {</span>
<span class="line" id="L65">            assert(n &gt; <span class="tok-number">0</span>);</span>
<span class="line" id="L66">            assert(mem.isValidAlign(ptr_align));</span>
<span class="line" id="L67">            <span class="tok-kw">if</span> (len_align != <span class="tok-number">0</span>) {</span>
<span class="line" id="L68">                assert(mem.isAlignedAnyAlign(n, len_align));</span>
<span class="line" id="L69">                assert(n &gt;= len_align);</span>
<span class="line" id="L70">            }</span>
<span class="line" id="L71"></span>
<span class="line" id="L72">            <span class="tok-kw">const</span> underlying = self.getUnderlyingAllocatorPtr();</span>
<span class="line" id="L73">            <span class="tok-kw">const</span> result = <span class="tok-kw">try</span> underlying.rawAlloc(n, ptr_align, len_align, ret_addr);</span>
<span class="line" id="L74">            assert(mem.isAligned(<span class="tok-builtin">@ptrToInt</span>(result.ptr), ptr_align));</span>
<span class="line" id="L75">            <span class="tok-kw">if</span> (len_align == <span class="tok-number">0</span>) {</span>
<span class="line" id="L76">                assert(result.len == n);</span>
<span class="line" id="L77">            } <span class="tok-kw">else</span> {</span>
<span class="line" id="L78">                assert(result.len &gt;= n);</span>
<span class="line" id="L79">                assert(mem.isAlignedAnyAlign(result.len, len_align));</span>
<span class="line" id="L80">            }</span>
<span class="line" id="L81">            <span class="tok-kw">return</span> result;</span>
<span class="line" id="L82">        }</span>
<span class="line" id="L83"></span>
<span class="line" id="L84">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">resize</span>(</span>
<span class="line" id="L85">            self: *Self,</span>
<span class="line" id="L86">            buf: []<span class="tok-type">u8</span>,</span>
<span class="line" id="L87">            buf_align: <span class="tok-type">u29</span>,</span>
<span class="line" id="L88">            new_len: <span class="tok-type">usize</span>,</span>
<span class="line" id="L89">            len_align: <span class="tok-type">u29</span>,</span>
<span class="line" id="L90">            ret_addr: <span class="tok-type">usize</span>,</span>
<span class="line" id="L91">        ) ?<span class="tok-type">usize</span> {</span>
<span class="line" id="L92">            assert(buf.len &gt; <span class="tok-number">0</span>);</span>
<span class="line" id="L93">            <span class="tok-kw">if</span> (len_align != <span class="tok-number">0</span>) {</span>
<span class="line" id="L94">                assert(mem.isAlignedAnyAlign(new_len, len_align));</span>
<span class="line" id="L95">                assert(new_len &gt;= len_align);</span>
<span class="line" id="L96">            }</span>
<span class="line" id="L97">            <span class="tok-kw">const</span> underlying = self.getUnderlyingAllocatorPtr();</span>
<span class="line" id="L98">            <span class="tok-kw">const</span> result = underlying.rawResize(buf, buf_align, new_len, len_align, ret_addr) <span class="tok-kw">orelse</span> <span class="tok-kw">return</span> <span class="tok-null">null</span>;</span>
<span class="line" id="L99">            <span class="tok-kw">if</span> (len_align == <span class="tok-number">0</span>) {</span>
<span class="line" id="L100">                assert(result == new_len);</span>
<span class="line" id="L101">            } <span class="tok-kw">else</span> {</span>
<span class="line" id="L102">                assert(result &gt;= new_len);</span>
<span class="line" id="L103">                assert(mem.isAlignedAnyAlign(result, len_align));</span>
<span class="line" id="L104">            }</span>
<span class="line" id="L105">            <span class="tok-kw">return</span> result;</span>
<span class="line" id="L106">        }</span>
<span class="line" id="L107"></span>
<span class="line" id="L108">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">free</span>(</span>
<span class="line" id="L109">            self: *Self,</span>
<span class="line" id="L110">            buf: []<span class="tok-type">u8</span>,</span>
<span class="line" id="L111">            buf_align: <span class="tok-type">u29</span>,</span>
<span class="line" id="L112">            ret_addr: <span class="tok-type">usize</span>,</span>
<span class="line" id="L113">        ) <span class="tok-type">void</span> {</span>
<span class="line" id="L114">            _ = self;</span>
<span class="line" id="L115">            _ = buf_align;</span>
<span class="line" id="L116">            _ = ret_addr;</span>
<span class="line" id="L117">            assert(buf.len &gt; <span class="tok-number">0</span>);</span>
<span class="line" id="L118">        }</span>
<span class="line" id="L119"></span>
<span class="line" id="L120">        <span class="tok-kw">pub</span> <span class="tok-kw">usingnamespace</span> <span class="tok-kw">if</span> (T == Allocator <span class="tok-kw">or</span> !<span class="tok-builtin">@hasDecl</span>(T, <span class="tok-str">&quot;reset&quot;</span>)) <span class="tok-kw">struct</span> {} <span class="tok-kw">else</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L121">            <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">reset</span>(self: *Self) <span class="tok-type">void</span> {</span>
<span class="line" id="L122">                self.underlying_allocator.reset();</span>
<span class="line" id="L123">            }</span>
<span class="line" id="L124">        };</span>
<span class="line" id="L125">    };</span>
<span class="line" id="L126">}</span>
<span class="line" id="L127"></span>
<span class="line" id="L128"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">validationWrap</span>(allocator: <span class="tok-kw">anytype</span>) ValidationAllocator(<span class="tok-builtin">@TypeOf</span>(allocator)) {</span>
<span class="line" id="L129">    <span class="tok-kw">return</span> ValidationAllocator(<span class="tok-builtin">@TypeOf</span>(allocator)).init(allocator);</span>
<span class="line" id="L130">}</span>
<span class="line" id="L131"></span>
<span class="line" id="L132"><span class="tok-comment">/// An allocator helper function.  Adjusts an allocation length satisfy `len_align`.</span></span>
<span class="line" id="L133"><span class="tok-comment">/// `full_len` should be the full capacity of the allocation which may be greater</span></span>
<span class="line" id="L134"><span class="tok-comment">/// than the `len` that was requsted.  This function should only be used by allocators</span></span>
<span class="line" id="L135"><span class="tok-comment">/// that are unaffected by `len_align`.</span></span>
<span class="line" id="L136"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">alignAllocLen</span>(full_len: <span class="tok-type">usize</span>, alloc_len: <span class="tok-type">usize</span>, len_align: <span class="tok-type">u29</span>) <span class="tok-type">usize</span> {</span>
<span class="line" id="L137">    assert(alloc_len &gt; <span class="tok-number">0</span>);</span>
<span class="line" id="L138">    assert(alloc_len &gt;= len_align);</span>
<span class="line" id="L139">    assert(full_len &gt;= alloc_len);</span>
<span class="line" id="L140">    <span class="tok-kw">if</span> (len_align == <span class="tok-number">0</span>)</span>
<span class="line" id="L141">        <span class="tok-kw">return</span> alloc_len;</span>
<span class="line" id="L142">    <span class="tok-kw">const</span> adjusted = alignBackwardAnyAlign(full_len, len_align);</span>
<span class="line" id="L143">    assert(adjusted &gt;= alloc_len);</span>
<span class="line" id="L144">    <span class="tok-kw">return</span> adjusted;</span>
<span class="line" id="L145">}</span>
<span class="line" id="L146"></span>
<span class="line" id="L147"><span class="tok-kw">const</span> fail_allocator = Allocator{</span>
<span class="line" id="L148">    .ptr = <span class="tok-null">undefined</span>,</span>
<span class="line" id="L149">    .vtable = &amp;failAllocator_vtable,</span>
<span class="line" id="L150">};</span>
<span class="line" id="L151"></span>
<span class="line" id="L152"><span class="tok-kw">const</span> failAllocator_vtable = Allocator.VTable{</span>
<span class="line" id="L153">    .alloc = failAllocatorAlloc,</span>
<span class="line" id="L154">    .resize = Allocator.NoResize(<span class="tok-type">anyopaque</span>).noResize,</span>
<span class="line" id="L155">    .free = Allocator.NoOpFree(<span class="tok-type">anyopaque</span>).noOpFree,</span>
<span class="line" id="L156">};</span>
<span class="line" id="L157"></span>
<span class="line" id="L158"><span class="tok-kw">fn</span> <span class="tok-fn">failAllocatorAlloc</span>(_: *<span class="tok-type">anyopaque</span>, n: <span class="tok-type">usize</span>, alignment: <span class="tok-type">u29</span>, len_align: <span class="tok-type">u29</span>, ra: <span class="tok-type">usize</span>) Allocator.Error![]<span class="tok-type">u8</span> {</span>
<span class="line" id="L159">    _ = n;</span>
<span class="line" id="L160">    _ = alignment;</span>
<span class="line" id="L161">    _ = len_align;</span>
<span class="line" id="L162">    _ = ra;</span>
<span class="line" id="L163">    <span class="tok-kw">return</span> <span class="tok-kw">error</span>.OutOfMemory;</span>
<span class="line" id="L164">}</span>
<span class="line" id="L165"></span>
<span class="line" id="L166"><span class="tok-kw">test</span> <span class="tok-str">&quot;Allocator basics&quot;</span> {</span>
<span class="line" id="L167">    <span class="tok-kw">try</span> testing.expectError(<span class="tok-kw">error</span>.OutOfMemory, fail_allocator.alloc(<span class="tok-type">u8</span>, <span class="tok-number">1</span>));</span>
<span class="line" id="L168">    <span class="tok-kw">try</span> testing.expectError(<span class="tok-kw">error</span>.OutOfMemory, fail_allocator.allocSentinel(<span class="tok-type">u8</span>, <span class="tok-number">1</span>, <span class="tok-number">0</span>));</span>
<span class="line" id="L169">}</span>
<span class="line" id="L170"></span>
<span class="line" id="L171"><span class="tok-kw">test</span> <span class="tok-str">&quot;Allocator.resize&quot;</span> {</span>
<span class="line" id="L172">    <span class="tok-kw">const</span> primitiveIntTypes = .{</span>
<span class="line" id="L173">        <span class="tok-type">i8</span>,</span>
<span class="line" id="L174">        <span class="tok-type">u8</span>,</span>
<span class="line" id="L175">        <span class="tok-type">i16</span>,</span>
<span class="line" id="L176">        <span class="tok-type">u16</span>,</span>
<span class="line" id="L177">        <span class="tok-type">i32</span>,</span>
<span class="line" id="L178">        <span class="tok-type">u32</span>,</span>
<span class="line" id="L179">        <span class="tok-type">i64</span>,</span>
<span class="line" id="L180">        <span class="tok-type">u64</span>,</span>
<span class="line" id="L181">        <span class="tok-type">i128</span>,</span>
<span class="line" id="L182">        <span class="tok-type">u128</span>,</span>
<span class="line" id="L183">        <span class="tok-type">isize</span>,</span>
<span class="line" id="L184">        <span class="tok-type">usize</span>,</span>
<span class="line" id="L185">    };</span>
<span class="line" id="L186">    <span class="tok-kw">inline</span> <span class="tok-kw">for</span> (primitiveIntTypes) |T| {</span>
<span class="line" id="L187">        <span class="tok-kw">var</span> values = <span class="tok-kw">try</span> testing.allocator.alloc(T, <span class="tok-number">100</span>);</span>
<span class="line" id="L188">        <span class="tok-kw">defer</span> testing.allocator.free(values);</span>
<span class="line" id="L189"></span>
<span class="line" id="L190">        <span class="tok-kw">for</span> (values) |*v, i| v.* = <span class="tok-builtin">@intCast</span>(T, i);</span>
<span class="line" id="L191">        values = testing.allocator.resize(values, values.len + <span class="tok-number">10</span>) <span class="tok-kw">orelse</span> <span class="tok-kw">return</span> <span class="tok-kw">error</span>.OutOfMemory;</span>
<span class="line" id="L192">        <span class="tok-kw">try</span> testing.expect(values.len == <span class="tok-number">110</span>);</span>
<span class="line" id="L193">    }</span>
<span class="line" id="L194"></span>
<span class="line" id="L195">    <span class="tok-kw">const</span> primitiveFloatTypes = .{</span>
<span class="line" id="L196">        <span class="tok-type">f16</span>,</span>
<span class="line" id="L197">        <span class="tok-type">f32</span>,</span>
<span class="line" id="L198">        <span class="tok-type">f64</span>,</span>
<span class="line" id="L199">        <span class="tok-type">f128</span>,</span>
<span class="line" id="L200">    };</span>
<span class="line" id="L201">    <span class="tok-kw">inline</span> <span class="tok-kw">for</span> (primitiveFloatTypes) |T| {</span>
<span class="line" id="L202">        <span class="tok-kw">var</span> values = <span class="tok-kw">try</span> testing.allocator.alloc(T, <span class="tok-number">100</span>);</span>
<span class="line" id="L203">        <span class="tok-kw">defer</span> testing.allocator.free(values);</span>
<span class="line" id="L204"></span>
<span class="line" id="L205">        <span class="tok-kw">for</span> (values) |*v, i| v.* = <span class="tok-builtin">@intToFloat</span>(T, i);</span>
<span class="line" id="L206">        values = testing.allocator.resize(values, values.len + <span class="tok-number">10</span>) <span class="tok-kw">orelse</span> <span class="tok-kw">return</span> <span class="tok-kw">error</span>.OutOfMemory;</span>
<span class="line" id="L207">        <span class="tok-kw">try</span> testing.expect(values.len == <span class="tok-number">110</span>);</span>
<span class="line" id="L208">    }</span>
<span class="line" id="L209">}</span>
<span class="line" id="L210"></span>
<span class="line" id="L211"><span class="tok-comment">/// Copy all of source into dest at position 0.</span></span>
<span class="line" id="L212"><span class="tok-comment">/// dest.len must be &gt;= source.len.</span></span>
<span class="line" id="L213"><span class="tok-comment">/// If the slices overlap, dest.ptr must be &lt;= src.ptr.</span></span>
<span class="line" id="L214"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">copy</span>(<span class="tok-kw">comptime</span> T: <span class="tok-type">type</span>, dest: []T, source: []<span class="tok-kw">const</span> T) <span class="tok-type">void</span> {</span>
<span class="line" id="L215">    <span class="tok-comment">// TODO instead of manually doing this check for the whole array</span>
</span>
<span class="line" id="L216">    <span class="tok-comment">// and turning off runtime safety, the compiler should detect loops like</span>
</span>
<span class="line" id="L217">    <span class="tok-comment">// this and automatically omit safety checks for loops</span>
</span>
<span class="line" id="L218">    <span class="tok-builtin">@setRuntimeSafety</span>(<span class="tok-null">false</span>);</span>
<span class="line" id="L219">    assert(dest.len &gt;= source.len);</span>
<span class="line" id="L220">    <span class="tok-kw">for</span> (source) |s, i|</span>
<span class="line" id="L221">        dest[i] = s;</span>
<span class="line" id="L222">}</span>
<span class="line" id="L223"></span>
<span class="line" id="L224"><span class="tok-comment">/// Copy all of source into dest at position 0.</span></span>
<span class="line" id="L225"><span class="tok-comment">/// dest.len must be &gt;= source.len.</span></span>
<span class="line" id="L226"><span class="tok-comment">/// If the slices overlap, dest.ptr must be &gt;= src.ptr.</span></span>
<span class="line" id="L227"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">copyBackwards</span>(<span class="tok-kw">comptime</span> T: <span class="tok-type">type</span>, dest: []T, source: []<span class="tok-kw">const</span> T) <span class="tok-type">void</span> {</span>
<span class="line" id="L228">    <span class="tok-comment">// TODO instead of manually doing this check for the whole array</span>
</span>
<span class="line" id="L229">    <span class="tok-comment">// and turning off runtime safety, the compiler should detect loops like</span>
</span>
<span class="line" id="L230">    <span class="tok-comment">// this and automatically omit safety checks for loops</span>
</span>
<span class="line" id="L231">    <span class="tok-builtin">@setRuntimeSafety</span>(<span class="tok-null">false</span>);</span>
<span class="line" id="L232">    assert(dest.len &gt;= source.len);</span>
<span class="line" id="L233">    <span class="tok-kw">var</span> i = source.len;</span>
<span class="line" id="L234">    <span class="tok-kw">while</span> (i &gt; <span class="tok-number">0</span>) {</span>
<span class="line" id="L235">        i -= <span class="tok-number">1</span>;</span>
<span class="line" id="L236">        dest[i] = source[i];</span>
<span class="line" id="L237">    }</span>
<span class="line" id="L238">}</span>
<span class="line" id="L239"></span>
<span class="line" id="L240"><span class="tok-comment">/// Sets all elements of `dest` to `value`.</span></span>
<span class="line" id="L241"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">set</span>(<span class="tok-kw">comptime</span> T: <span class="tok-type">type</span>, dest: []T, value: T) <span class="tok-type">void</span> {</span>
<span class="line" id="L242">    <span class="tok-kw">for</span> (dest) |*d|</span>
<span class="line" id="L243">        d.* = value;</span>
<span class="line" id="L244">}</span>
<span class="line" id="L245"></span>
<span class="line" id="L246"><span class="tok-comment">/// Generally, Zig users are encouraged to explicitly initialize all fields of a struct explicitly rather than using this function.</span></span>
<span class="line" id="L247"><span class="tok-comment">/// However, it is recognized that there are sometimes use cases for initializing all fields to a &quot;zero&quot; value. For example, when</span></span>
<span class="line" id="L248"><span class="tok-comment">/// interfacing with a C API where this practice is more common and relied upon. If you are performing code review and see this</span></span>
<span class="line" id="L249"><span class="tok-comment">/// function used, examine closely - it may be a code smell.</span></span>
<span class="line" id="L250"><span class="tok-comment">/// Zero initializes the type.</span></span>
<span class="line" id="L251"><span class="tok-comment">/// This can be used to zero initialize a any type for which it makes sense. Structs will be initialized recursively.</span></span>
<span class="line" id="L252"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">zeroes</span>(<span class="tok-kw">comptime</span> T: <span class="tok-type">type</span>) T {</span>
<span class="line" id="L253">    <span class="tok-kw">switch</span> (<span class="tok-builtin">@typeInfo</span>(T)) {</span>
<span class="line" id="L254">        .ComptimeInt, .Int, .ComptimeFloat, .Float =&gt; {</span>
<span class="line" id="L255">            <span class="tok-kw">return</span> <span class="tok-builtin">@as</span>(T, <span class="tok-number">0</span>);</span>
<span class="line" id="L256">        },</span>
<span class="line" id="L257">        .Enum, .EnumLiteral =&gt; {</span>
<span class="line" id="L258">            <span class="tok-kw">return</span> <span class="tok-builtin">@intToEnum</span>(T, <span class="tok-number">0</span>);</span>
<span class="line" id="L259">        },</span>
<span class="line" id="L260">        .Void =&gt; {</span>
<span class="line" id="L261">            <span class="tok-kw">return</span> {};</span>
<span class="line" id="L262">        },</span>
<span class="line" id="L263">        .Bool =&gt; {</span>
<span class="line" id="L264">            <span class="tok-kw">return</span> <span class="tok-null">false</span>;</span>
<span class="line" id="L265">        },</span>
<span class="line" id="L266">        .Optional, .Null =&gt; {</span>
<span class="line" id="L267">            <span class="tok-kw">return</span> <span class="tok-null">null</span>;</span>
<span class="line" id="L268">        },</span>
<span class="line" id="L269">        .Struct =&gt; |struct_info| {</span>
<span class="line" id="L270">            <span class="tok-kw">if</span> (<span class="tok-builtin">@sizeOf</span>(T) == <span class="tok-number">0</span>) <span class="tok-kw">return</span> <span class="tok-null">undefined</span>;</span>
<span class="line" id="L271">            <span class="tok-kw">if</span> (struct_info.layout == .Extern) {</span>
<span class="line" id="L272">                <span class="tok-kw">var</span> item: T = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L273">                set(<span class="tok-type">u8</span>, asBytes(&amp;item), <span class="tok-number">0</span>);</span>
<span class="line" id="L274">                <span class="tok-kw">return</span> item;</span>
<span class="line" id="L275">            } <span class="tok-kw">else</span> {</span>
<span class="line" id="L276">                <span class="tok-kw">var</span> structure: T = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L277">                <span class="tok-kw">inline</span> <span class="tok-kw">for</span> (struct_info.fields) |field| {</span>
<span class="line" id="L278">                    <span class="tok-kw">if</span> (!field.is_comptime) {</span>
<span class="line" id="L279">                        <span class="tok-builtin">@field</span>(structure, field.name) = zeroes(<span class="tok-builtin">@TypeOf</span>(<span class="tok-builtin">@field</span>(structure, field.name)));</span>
<span class="line" id="L280">                    }</span>
<span class="line" id="L281">                }</span>
<span class="line" id="L282">                <span class="tok-kw">return</span> structure;</span>
<span class="line" id="L283">            }</span>
<span class="line" id="L284">        },</span>
<span class="line" id="L285">        .Pointer =&gt; |ptr_info| {</span>
<span class="line" id="L286">            <span class="tok-kw">switch</span> (ptr_info.size) {</span>
<span class="line" id="L287">                .Slice =&gt; {</span>
<span class="line" id="L288">                    <span class="tok-kw">return</span> &amp;[_]ptr_info.child{};</span>
<span class="line" id="L289">                },</span>
<span class="line" id="L290">                .C =&gt; {</span>
<span class="line" id="L291">                    <span class="tok-kw">return</span> <span class="tok-null">null</span>;</span>
<span class="line" id="L292">                },</span>
<span class="line" id="L293">                .One, .Many =&gt; {</span>
<span class="line" id="L294">                    <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;Can't set a non nullable pointer to zero.&quot;</span>);</span>
<span class="line" id="L295">                },</span>
<span class="line" id="L296">            }</span>
<span class="line" id="L297">        },</span>
<span class="line" id="L298">        .Array =&gt; |info| {</span>
<span class="line" id="L299">            <span class="tok-kw">if</span> (info.sentinel) |sentinel_ptr| {</span>
<span class="line" id="L300">                <span class="tok-kw">const</span> sentinel = <span class="tok-builtin">@ptrCast</span>(*<span class="tok-kw">const</span> info.child, sentinel_ptr).*;</span>
<span class="line" id="L301">                <span class="tok-kw">return</span> [_:sentinel]info.child{zeroes(info.child)} ** info.len;</span>
<span class="line" id="L302">            }</span>
<span class="line" id="L303">            <span class="tok-kw">return</span> [_]info.child{zeroes(info.child)} ** info.len;</span>
<span class="line" id="L304">        },</span>
<span class="line" id="L305">        .Vector =&gt; |info| {</span>
<span class="line" id="L306">            <span class="tok-kw">return</span> <span class="tok-builtin">@splat</span>(info.len, zeroes(info.child));</span>
<span class="line" id="L307">        },</span>
<span class="line" id="L308">        .Union =&gt; |info| {</span>
<span class="line" id="L309">            <span class="tok-kw">if</span> (<span class="tok-kw">comptime</span> meta.containerLayout(T) == .Extern) {</span>
<span class="line" id="L310">                <span class="tok-comment">// The C language specification states that (global) unions</span>
</span>
<span class="line" id="L311">                <span class="tok-comment">// should be zero initialized to the first named member.</span>
</span>
<span class="line" id="L312">                <span class="tok-kw">return</span> <span class="tok-builtin">@unionInit</span>(T, info.fields[<span class="tok-number">0</span>].name, zeroes(info.fields[<span class="tok-number">0</span>].field_type));</span>
<span class="line" id="L313">            }</span>
<span class="line" id="L314"></span>
<span class="line" id="L315">            <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;Can't set a &quot;</span> ++ <span class="tok-builtin">@typeName</span>(T) ++ <span class="tok-str">&quot; to zero.&quot;</span>);</span>
<span class="line" id="L316">        },</span>
<span class="line" id="L317">        .ErrorUnion,</span>
<span class="line" id="L318">        .ErrorSet,</span>
<span class="line" id="L319">        .Fn,</span>
<span class="line" id="L320">        .BoundFn,</span>
<span class="line" id="L321">        .Type,</span>
<span class="line" id="L322">        .NoReturn,</span>
<span class="line" id="L323">        .Undefined,</span>
<span class="line" id="L324">        .Opaque,</span>
<span class="line" id="L325">        .Frame,</span>
<span class="line" id="L326">        .AnyFrame,</span>
<span class="line" id="L327">        =&gt; {</span>
<span class="line" id="L328">            <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;Can't set a &quot;</span> ++ <span class="tok-builtin">@typeName</span>(T) ++ <span class="tok-str">&quot; to zero.&quot;</span>);</span>
<span class="line" id="L329">        },</span>
<span class="line" id="L330">    }</span>
<span class="line" id="L331">}</span>
<span class="line" id="L332"></span>
<span class="line" id="L333"><span class="tok-kw">test</span> <span class="tok-str">&quot;zeroes&quot;</span> {</span>
<span class="line" id="L334">    <span class="tok-kw">if</span> (builtin.zig_backend == .stage1 <span class="tok-kw">or</span> builtin.zig_backend == .stage2_llvm) {</span>
<span class="line" id="L335">        <span class="tok-comment">// Regressed in LLVM 14:</span>
</span>
<span class="line" id="L336">        <span class="tok-comment">// https://github.com/llvm/llvm-project/issues/55522</span>
</span>
<span class="line" id="L337">        <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SkipZigTest;</span>
<span class="line" id="L338">    }</span>
<span class="line" id="L339"></span>
<span class="line" id="L340">    <span class="tok-kw">const</span> C_struct = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L341">        x: <span class="tok-type">u32</span>,</span>
<span class="line" id="L342">        y: <span class="tok-type">u32</span>,</span>
<span class="line" id="L343">    };</span>
<span class="line" id="L344"></span>
<span class="line" id="L345">    <span class="tok-kw">var</span> a = zeroes(C_struct);</span>
<span class="line" id="L346">    a.y += <span class="tok-number">10</span>;</span>
<span class="line" id="L347"></span>
<span class="line" id="L348">    <span class="tok-kw">try</span> testing.expect(a.x == <span class="tok-number">0</span>);</span>
<span class="line" id="L349">    <span class="tok-kw">try</span> testing.expect(a.y == <span class="tok-number">10</span>);</span>
<span class="line" id="L350"></span>
<span class="line" id="L351">    <span class="tok-kw">const</span> ZigStruct = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L352">        <span class="tok-kw">comptime</span> comptime_field: <span class="tok-type">u8</span> = <span class="tok-number">5</span>,</span>
<span class="line" id="L353"></span>
<span class="line" id="L354">        integral_types: <span class="tok-kw">struct</span> {</span>
<span class="line" id="L355">            integer_0: <span class="tok-type">i0</span>,</span>
<span class="line" id="L356">            integer_8: <span class="tok-type">i8</span>,</span>
<span class="line" id="L357">            integer_16: <span class="tok-type">i16</span>,</span>
<span class="line" id="L358">            integer_32: <span class="tok-type">i32</span>,</span>
<span class="line" id="L359">            integer_64: <span class="tok-type">i64</span>,</span>
<span class="line" id="L360">            integer_128: <span class="tok-type">i128</span>,</span>
<span class="line" id="L361">            unsigned_0: <span class="tok-type">u0</span>,</span>
<span class="line" id="L362">            unsigned_8: <span class="tok-type">u8</span>,</span>
<span class="line" id="L363">            unsigned_16: <span class="tok-type">u16</span>,</span>
<span class="line" id="L364">            unsigned_32: <span class="tok-type">u32</span>,</span>
<span class="line" id="L365">            unsigned_64: <span class="tok-type">u64</span>,</span>
<span class="line" id="L366">            unsigned_128: <span class="tok-type">u128</span>,</span>
<span class="line" id="L367"></span>
<span class="line" id="L368">            float_32: <span class="tok-type">f32</span>,</span>
<span class="line" id="L369">            float_64: <span class="tok-type">f64</span>,</span>
<span class="line" id="L370">        },</span>
<span class="line" id="L371"></span>
<span class="line" id="L372">        pointers: <span class="tok-kw">struct</span> {</span>
<span class="line" id="L373">            optional: ?*<span class="tok-type">u8</span>,</span>
<span class="line" id="L374">            c_pointer: [*c]<span class="tok-type">u8</span>,</span>
<span class="line" id="L375">            slice: []<span class="tok-type">u8</span>,</span>
<span class="line" id="L376">        },</span>
<span class="line" id="L377"></span>
<span class="line" id="L378">        array: [<span class="tok-number">2</span>]<span class="tok-type">u32</span>,</span>
<span class="line" id="L379">        vector_u32: <span class="tok-builtin">@Vector</span>(<span class="tok-number">2</span>, <span class="tok-type">u32</span>),</span>
<span class="line" id="L380">        vector_f32: <span class="tok-builtin">@Vector</span>(<span class="tok-number">2</span>, <span class="tok-type">f32</span>),</span>
<span class="line" id="L381">        vector_bool: <span class="tok-builtin">@Vector</span>(<span class="tok-number">2</span>, <span class="tok-type">bool</span>),</span>
<span class="line" id="L382">        optional_int: ?<span class="tok-type">u8</span>,</span>
<span class="line" id="L383">        empty: <span class="tok-type">void</span>,</span>
<span class="line" id="L384">        sentinel: [<span class="tok-number">3</span>:<span class="tok-number">0</span>]<span class="tok-type">u8</span>,</span>
<span class="line" id="L385">    };</span>
<span class="line" id="L386"></span>
<span class="line" id="L387">    <span class="tok-kw">const</span> b = zeroes(ZigStruct);</span>
<span class="line" id="L388">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">u8</span>, <span class="tok-number">5</span>), b.comptime_field);</span>
<span class="line" id="L389">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">i8</span>, <span class="tok-number">0</span>), b.integral_types.integer_0);</span>
<span class="line" id="L390">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">i8</span>, <span class="tok-number">0</span>), b.integral_types.integer_8);</span>
<span class="line" id="L391">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">i16</span>, <span class="tok-number">0</span>), b.integral_types.integer_16);</span>
<span class="line" id="L392">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">i32</span>, <span class="tok-number">0</span>), b.integral_types.integer_32);</span>
<span class="line" id="L393">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">i64</span>, <span class="tok-number">0</span>), b.integral_types.integer_64);</span>
<span class="line" id="L394">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">i128</span>, <span class="tok-number">0</span>), b.integral_types.integer_128);</span>
<span class="line" id="L395">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">u8</span>, <span class="tok-number">0</span>), b.integral_types.unsigned_0);</span>
<span class="line" id="L396">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">u8</span>, <span class="tok-number">0</span>), b.integral_types.unsigned_8);</span>
<span class="line" id="L397">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">u16</span>, <span class="tok-number">0</span>), b.integral_types.unsigned_16);</span>
<span class="line" id="L398">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">0</span>), b.integral_types.unsigned_32);</span>
<span class="line" id="L399">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">u64</span>, <span class="tok-number">0</span>), b.integral_types.unsigned_64);</span>
<span class="line" id="L400">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">u128</span>, <span class="tok-number">0</span>), b.integral_types.unsigned_128);</span>
<span class="line" id="L401">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">f32</span>, <span class="tok-number">0</span>), b.integral_types.float_32);</span>
<span class="line" id="L402">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">f64</span>, <span class="tok-number">0</span>), b.integral_types.float_64);</span>
<span class="line" id="L403">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(?*<span class="tok-type">u8</span>, <span class="tok-null">null</span>), b.pointers.optional);</span>
<span class="line" id="L404">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>([*c]<span class="tok-type">u8</span>, <span class="tok-null">null</span>), b.pointers.c_pointer);</span>
<span class="line" id="L405">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>([]<span class="tok-type">u8</span>, &amp;[_]<span class="tok-type">u8</span>{}), b.pointers.slice);</span>
<span class="line" id="L406">    <span class="tok-kw">for</span> (b.array) |e| {</span>
<span class="line" id="L407">        <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">0</span>), e);</span>
<span class="line" id="L408">    }</span>
<span class="line" id="L409">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@splat</span>(<span class="tok-number">2</span>, <span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">0</span>)), b.vector_u32);</span>
<span class="line" id="L410">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@splat</span>(<span class="tok-number">2</span>, <span class="tok-builtin">@as</span>(<span class="tok-type">f32</span>, <span class="tok-number">0.0</span>)), b.vector_f32);</span>
<span class="line" id="L411">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@splat</span>(<span class="tok-number">2</span>, <span class="tok-builtin">@as</span>(<span class="tok-type">bool</span>, <span class="tok-null">false</span>)), b.vector_bool);</span>
<span class="line" id="L412">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(?<span class="tok-type">u8</span>, <span class="tok-null">null</span>), b.optional_int);</span>
<span class="line" id="L413">    <span class="tok-kw">for</span> (b.sentinel) |e| {</span>
<span class="line" id="L414">        <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">u8</span>, <span class="tok-number">0</span>), e);</span>
<span class="line" id="L415">    }</span>
<span class="line" id="L416"></span>
<span class="line" id="L417">    <span class="tok-kw">const</span> C_union = <span class="tok-kw">extern</span> <span class="tok-kw">union</span> {</span>
<span class="line" id="L418">        a: <span class="tok-type">u8</span>,</span>
<span class="line" id="L419">        b: <span class="tok-type">u32</span>,</span>
<span class="line" id="L420">    };</span>
<span class="line" id="L421"></span>
<span class="line" id="L422">    <span class="tok-kw">var</span> c = zeroes(C_union);</span>
<span class="line" id="L423">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">u8</span>, <span class="tok-number">0</span>), c.a);</span>
<span class="line" id="L424"></span>
<span class="line" id="L425">    <span class="tok-kw">comptime</span> <span class="tok-kw">var</span> comptime_union = zeroes(C_union);</span>
<span class="line" id="L426">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">u8</span>, <span class="tok-number">0</span>), comptime_union.a);</span>
<span class="line" id="L427"></span>
<span class="line" id="L428">    <span class="tok-comment">// Ensure zero sized struct with fields is initialized correctly.</span>
</span>
<span class="line" id="L429">    _ = zeroes(<span class="tok-kw">struct</span> { handle: <span class="tok-type">void</span> });</span>
<span class="line" id="L430">}</span>
<span class="line" id="L431"></span>
<span class="line" id="L432"><span class="tok-comment">/// Initializes all fields of the struct with their default value, or zero values if no default value is present.</span></span>
<span class="line" id="L433"><span class="tok-comment">/// If the field is present in the provided initial values, it will have that value instead.</span></span>
<span class="line" id="L434"><span class="tok-comment">/// Structs are initialized recursively.</span></span>
<span class="line" id="L435"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">zeroInit</span>(<span class="tok-kw">comptime</span> T: <span class="tok-type">type</span>, init: <span class="tok-kw">anytype</span>) T {</span>
<span class="line" id="L436">    <span class="tok-kw">const</span> Init = <span class="tok-builtin">@TypeOf</span>(init);</span>
<span class="line" id="L437"></span>
<span class="line" id="L438">    <span class="tok-kw">switch</span> (<span class="tok-builtin">@typeInfo</span>(T)) {</span>
<span class="line" id="L439">        .Struct =&gt; |struct_info| {</span>
<span class="line" id="L440">            <span class="tok-kw">switch</span> (<span class="tok-builtin">@typeInfo</span>(Init)) {</span>
<span class="line" id="L441">                .Struct =&gt; |init_info| {</span>
<span class="line" id="L442">                    <span class="tok-kw">var</span> value = std.mem.zeroes(T);</span>
<span class="line" id="L443"></span>
<span class="line" id="L444">                    <span class="tok-kw">inline</span> <span class="tok-kw">for</span> (struct_info.fields) |field| {</span>
<span class="line" id="L445">                        <span class="tok-kw">if</span> (field.default_value) |default_value_ptr| {</span>
<span class="line" id="L446">                            <span class="tok-kw">const</span> default_value = <span class="tok-builtin">@ptrCast</span>(*<span class="tok-kw">const</span> field.field_type, default_value_ptr).*;</span>
<span class="line" id="L447">                            <span class="tok-builtin">@field</span>(value, field.name) = default_value;</span>
<span class="line" id="L448">                        }</span>
<span class="line" id="L449">                    }</span>
<span class="line" id="L450"></span>
<span class="line" id="L451">                    <span class="tok-kw">if</span> (init_info.is_tuple) {</span>
<span class="line" id="L452">                        <span class="tok-kw">inline</span> <span class="tok-kw">for</span> (init_info.fields) |field, i| {</span>
<span class="line" id="L453">                            <span class="tok-builtin">@field</span>(value, struct_info.fields[i].name) = <span class="tok-builtin">@field</span>(init, field.name);</span>
<span class="line" id="L454">                        }</span>
<span class="line" id="L455">                        <span class="tok-kw">return</span> value;</span>
<span class="line" id="L456">                    }</span>
<span class="line" id="L457"></span>
<span class="line" id="L458">                    <span class="tok-kw">inline</span> <span class="tok-kw">for</span> (init_info.fields) |field| {</span>
<span class="line" id="L459">                        <span class="tok-kw">if</span> (!<span class="tok-builtin">@hasField</span>(T, field.name)) {</span>
<span class="line" id="L460">                            <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;Encountered an initializer for `&quot;</span> ++ field.name ++ <span class="tok-str">&quot;`, but it is not a field of &quot;</span> ++ <span class="tok-builtin">@typeName</span>(T));</span>
<span class="line" id="L461">                        }</span>
<span class="line" id="L462"></span>
<span class="line" id="L463">                        <span class="tok-kw">switch</span> (<span class="tok-builtin">@typeInfo</span>(field.field_type)) {</span>
<span class="line" id="L464">                            .Struct =&gt; {</span>
<span class="line" id="L465">                                <span class="tok-builtin">@field</span>(value, field.name) = zeroInit(field.field_type, <span class="tok-builtin">@field</span>(init, field.name));</span>
<span class="line" id="L466">                            },</span>
<span class="line" id="L467">                            <span class="tok-kw">else</span> =&gt; {</span>
<span class="line" id="L468">                                <span class="tok-builtin">@field</span>(value, field.name) = <span class="tok-builtin">@field</span>(init, field.name);</span>
<span class="line" id="L469">                            },</span>
<span class="line" id="L470">                        }</span>
<span class="line" id="L471">                    }</span>
<span class="line" id="L472"></span>
<span class="line" id="L473">                    <span class="tok-kw">return</span> value;</span>
<span class="line" id="L474">                },</span>
<span class="line" id="L475">                <span class="tok-kw">else</span> =&gt; {</span>
<span class="line" id="L476">                    <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;The initializer must be a struct&quot;</span>);</span>
<span class="line" id="L477">                },</span>
<span class="line" id="L478">            }</span>
<span class="line" id="L479">        },</span>
<span class="line" id="L480">        <span class="tok-kw">else</span> =&gt; {</span>
<span class="line" id="L481">            <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;Can't default init a &quot;</span> ++ <span class="tok-builtin">@typeName</span>(T));</span>
<span class="line" id="L482">        },</span>
<span class="line" id="L483">    }</span>
<span class="line" id="L484">}</span>
<span class="line" id="L485"></span>
<span class="line" id="L486"><span class="tok-kw">test</span> <span class="tok-str">&quot;zeroInit&quot;</span> {</span>
<span class="line" id="L487">    <span class="tok-kw">const</span> I = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L488">        d: <span class="tok-type">f64</span>,</span>
<span class="line" id="L489">    };</span>
<span class="line" id="L490"></span>
<span class="line" id="L491">    <span class="tok-kw">const</span> S = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L492">        a: <span class="tok-type">u32</span>,</span>
<span class="line" id="L493">        b: ?<span class="tok-type">bool</span>,</span>
<span class="line" id="L494">        c: I,</span>
<span class="line" id="L495">        e: [<span class="tok-number">3</span>]<span class="tok-type">u8</span>,</span>
<span class="line" id="L496">        f: <span class="tok-type">i64</span> = -<span class="tok-number">1</span>,</span>
<span class="line" id="L497">    };</span>
<span class="line" id="L498"></span>
<span class="line" id="L499">    <span class="tok-kw">const</span> s = zeroInit(S, .{</span>
<span class="line" id="L500">        .a = <span class="tok-number">42</span>,</span>
<span class="line" id="L501">    });</span>
<span class="line" id="L502"></span>
<span class="line" id="L503">    <span class="tok-kw">try</span> testing.expectEqual(S{</span>
<span class="line" id="L504">        .a = <span class="tok-number">42</span>,</span>
<span class="line" id="L505">        .b = <span class="tok-null">null</span>,</span>
<span class="line" id="L506">        .c = .{</span>
<span class="line" id="L507">            .d = <span class="tok-number">0</span>,</span>
<span class="line" id="L508">        },</span>
<span class="line" id="L509">        .e = [<span class="tok-number">3</span>]<span class="tok-type">u8</span>{ <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span> },</span>
<span class="line" id="L510">        .f = -<span class="tok-number">1</span>,</span>
<span class="line" id="L511">    }, s);</span>
<span class="line" id="L512"></span>
<span class="line" id="L513">    <span class="tok-kw">const</span> Color = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L514">        r: <span class="tok-type">u8</span>,</span>
<span class="line" id="L515">        g: <span class="tok-type">u8</span>,</span>
<span class="line" id="L516">        b: <span class="tok-type">u8</span>,</span>
<span class="line" id="L517">        a: <span class="tok-type">u8</span>,</span>
<span class="line" id="L518">    };</span>
<span class="line" id="L519"></span>
<span class="line" id="L520">    <span class="tok-kw">const</span> c = zeroInit(Color, .{ <span class="tok-number">255</span>, <span class="tok-number">255</span> });</span>
<span class="line" id="L521">    <span class="tok-kw">try</span> testing.expectEqual(Color{</span>
<span class="line" id="L522">        .r = <span class="tok-number">255</span>,</span>
<span class="line" id="L523">        .g = <span class="tok-number">255</span>,</span>
<span class="line" id="L524">        .b = <span class="tok-number">0</span>,</span>
<span class="line" id="L525">        .a = <span class="tok-number">0</span>,</span>
<span class="line" id="L526">    }, c);</span>
<span class="line" id="L527"></span>
<span class="line" id="L528">    <span class="tok-kw">const</span> Foo = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L529">        foo: <span class="tok-type">u8</span> = <span class="tok-number">69</span>,</span>
<span class="line" id="L530">        bar: <span class="tok-type">u8</span>,</span>
<span class="line" id="L531">    };</span>
<span class="line" id="L532"></span>
<span class="line" id="L533">    <span class="tok-kw">const</span> f = zeroInit(Foo, .{});</span>
<span class="line" id="L534">    <span class="tok-kw">try</span> testing.expectEqual(Foo{</span>
<span class="line" id="L535">        .foo = <span class="tok-number">69</span>,</span>
<span class="line" id="L536">        .bar = <span class="tok-number">0</span>,</span>
<span class="line" id="L537">    }, f);</span>
<span class="line" id="L538"></span>
<span class="line" id="L539">    <span class="tok-kw">const</span> Bar = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L540">        foo: <span class="tok-type">u32</span> = <span class="tok-number">666</span>,</span>
<span class="line" id="L541">        bar: <span class="tok-type">u32</span> = <span class="tok-number">420</span>,</span>
<span class="line" id="L542">    };</span>
<span class="line" id="L543"></span>
<span class="line" id="L544">    <span class="tok-kw">const</span> b = zeroInit(Bar, .{<span class="tok-number">69</span>});</span>
<span class="line" id="L545">    <span class="tok-kw">try</span> testing.expectEqual(Bar{</span>
<span class="line" id="L546">        .foo = <span class="tok-number">69</span>,</span>
<span class="line" id="L547">        .bar = <span class="tok-number">420</span>,</span>
<span class="line" id="L548">    }, b);</span>
<span class="line" id="L549">}</span>
<span class="line" id="L550"></span>
<span class="line" id="L551"><span class="tok-comment">/// Compares two slices of numbers lexicographically. O(n).</span></span>
<span class="line" id="L552"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">order</span>(<span class="tok-kw">comptime</span> T: <span class="tok-type">type</span>, lhs: []<span class="tok-kw">const</span> T, rhs: []<span class="tok-kw">const</span> T) math.Order {</span>
<span class="line" id="L553">    <span class="tok-kw">const</span> n = math.min(lhs.len, rhs.len);</span>
<span class="line" id="L554">    <span class="tok-kw">var</span> i: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L555">    <span class="tok-kw">while</span> (i &lt; n) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L556">        <span class="tok-kw">switch</span> (math.order(lhs[i], rhs[i])) {</span>
<span class="line" id="L557">            .eq =&gt; <span class="tok-kw">continue</span>,</span>
<span class="line" id="L558">            .lt =&gt; <span class="tok-kw">return</span> .lt,</span>
<span class="line" id="L559">            .gt =&gt; <span class="tok-kw">return</span> .gt,</span>
<span class="line" id="L560">        }</span>
<span class="line" id="L561">    }</span>
<span class="line" id="L562">    <span class="tok-kw">return</span> math.order(lhs.len, rhs.len);</span>
<span class="line" id="L563">}</span>
<span class="line" id="L564"></span>
<span class="line" id="L565"><span class="tok-kw">test</span> <span class="tok-str">&quot;order&quot;</span> {</span>
<span class="line" id="L566">    <span class="tok-kw">try</span> testing.expect(order(<span class="tok-type">u8</span>, <span class="tok-str">&quot;abcd&quot;</span>, <span class="tok-str">&quot;bee&quot;</span>) == .lt);</span>
<span class="line" id="L567">    <span class="tok-kw">try</span> testing.expect(order(<span class="tok-type">u8</span>, <span class="tok-str">&quot;abc&quot;</span>, <span class="tok-str">&quot;abc&quot;</span>) == .eq);</span>
<span class="line" id="L568">    <span class="tok-kw">try</span> testing.expect(order(<span class="tok-type">u8</span>, <span class="tok-str">&quot;abc&quot;</span>, <span class="tok-str">&quot;abc0&quot;</span>) == .lt);</span>
<span class="line" id="L569">    <span class="tok-kw">try</span> testing.expect(order(<span class="tok-type">u8</span>, <span class="tok-str">&quot;&quot;</span>, <span class="tok-str">&quot;&quot;</span>) == .eq);</span>
<span class="line" id="L570">    <span class="tok-kw">try</span> testing.expect(order(<span class="tok-type">u8</span>, <span class="tok-str">&quot;&quot;</span>, <span class="tok-str">&quot;a&quot;</span>) == .lt);</span>
<span class="line" id="L571">}</span>
<span class="line" id="L572"></span>
<span class="line" id="L573"><span class="tok-comment">/// Returns true if lhs &lt; rhs, false otherwise</span></span>
<span class="line" id="L574"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">lessThan</span>(<span class="tok-kw">comptime</span> T: <span class="tok-type">type</span>, lhs: []<span class="tok-kw">const</span> T, rhs: []<span class="tok-kw">const</span> T) <span class="tok-type">bool</span> {</span>
<span class="line" id="L575">    <span class="tok-kw">return</span> order(T, lhs, rhs) == .lt;</span>
<span class="line" id="L576">}</span>
<span class="line" id="L577"></span>
<span class="line" id="L578"><span class="tok-kw">test</span> <span class="tok-str">&quot;lessThan&quot;</span> {</span>
<span class="line" id="L579">    <span class="tok-kw">try</span> testing.expect(lessThan(<span class="tok-type">u8</span>, <span class="tok-str">&quot;abcd&quot;</span>, <span class="tok-str">&quot;bee&quot;</span>));</span>
<span class="line" id="L580">    <span class="tok-kw">try</span> testing.expect(!lessThan(<span class="tok-type">u8</span>, <span class="tok-str">&quot;abc&quot;</span>, <span class="tok-str">&quot;abc&quot;</span>));</span>
<span class="line" id="L581">    <span class="tok-kw">try</span> testing.expect(lessThan(<span class="tok-type">u8</span>, <span class="tok-str">&quot;abc&quot;</span>, <span class="tok-str">&quot;abc0&quot;</span>));</span>
<span class="line" id="L582">    <span class="tok-kw">try</span> testing.expect(!lessThan(<span class="tok-type">u8</span>, <span class="tok-str">&quot;&quot;</span>, <span class="tok-str">&quot;&quot;</span>));</span>
<span class="line" id="L583">    <span class="tok-kw">try</span> testing.expect(lessThan(<span class="tok-type">u8</span>, <span class="tok-str">&quot;&quot;</span>, <span class="tok-str">&quot;a&quot;</span>));</span>
<span class="line" id="L584">}</span>
<span class="line" id="L585"></span>
<span class="line" id="L586"><span class="tok-comment">/// Compares two slices and returns whether they are equal.</span></span>
<span class="line" id="L587"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">eql</span>(<span class="tok-kw">comptime</span> T: <span class="tok-type">type</span>, a: []<span class="tok-kw">const</span> T, b: []<span class="tok-kw">const</span> T) <span class="tok-type">bool</span> {</span>
<span class="line" id="L588">    <span class="tok-kw">if</span> (a.len != b.len) <span class="tok-kw">return</span> <span class="tok-null">false</span>;</span>
<span class="line" id="L589">    <span class="tok-kw">if</span> (a.ptr == b.ptr) <span class="tok-kw">return</span> <span class="tok-null">true</span>;</span>
<span class="line" id="L590">    <span class="tok-kw">for</span> (a) |item, index| {</span>
<span class="line" id="L591">        <span class="tok-kw">if</span> (b[index] != item) <span class="tok-kw">return</span> <span class="tok-null">false</span>;</span>
<span class="line" id="L592">    }</span>
<span class="line" id="L593">    <span class="tok-kw">return</span> <span class="tok-null">true</span>;</span>
<span class="line" id="L594">}</span>
<span class="line" id="L595"></span>
<span class="line" id="L596"><span class="tok-comment">/// Compares two slices and returns the index of the first inequality.</span></span>
<span class="line" id="L597"><span class="tok-comment">/// Returns null if the slices are equal.</span></span>
<span class="line" id="L598"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">indexOfDiff</span>(<span class="tok-kw">comptime</span> T: <span class="tok-type">type</span>, a: []<span class="tok-kw">const</span> T, b: []<span class="tok-kw">const</span> T) ?<span class="tok-type">usize</span> {</span>
<span class="line" id="L599">    <span class="tok-kw">const</span> shortest = math.min(a.len, b.len);</span>
<span class="line" id="L600">    <span class="tok-kw">if</span> (a.ptr == b.ptr)</span>
<span class="line" id="L601">        <span class="tok-kw">return</span> <span class="tok-kw">if</span> (a.len == b.len) <span class="tok-null">null</span> <span class="tok-kw">else</span> shortest;</span>
<span class="line" id="L602">    <span class="tok-kw">var</span> index: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L603">    <span class="tok-kw">while</span> (index &lt; shortest) : (index += <span class="tok-number">1</span>) <span class="tok-kw">if</span> (a[index] != b[index]) <span class="tok-kw">return</span> index;</span>
<span class="line" id="L604">    <span class="tok-kw">return</span> <span class="tok-kw">if</span> (a.len == b.len) <span class="tok-null">null</span> <span class="tok-kw">else</span> shortest;</span>
<span class="line" id="L605">}</span>
<span class="line" id="L606"></span>
<span class="line" id="L607"><span class="tok-kw">test</span> <span class="tok-str">&quot;indexOfDiff&quot;</span> {</span>
<span class="line" id="L608">    <span class="tok-kw">try</span> testing.expectEqual(indexOfDiff(<span class="tok-type">u8</span>, <span class="tok-str">&quot;one&quot;</span>, <span class="tok-str">&quot;one&quot;</span>), <span class="tok-null">null</span>);</span>
<span class="line" id="L609">    <span class="tok-kw">try</span> testing.expectEqual(indexOfDiff(<span class="tok-type">u8</span>, <span class="tok-str">&quot;one two&quot;</span>, <span class="tok-str">&quot;one&quot;</span>), <span class="tok-number">3</span>);</span>
<span class="line" id="L610">    <span class="tok-kw">try</span> testing.expectEqual(indexOfDiff(<span class="tok-type">u8</span>, <span class="tok-str">&quot;one&quot;</span>, <span class="tok-str">&quot;one two&quot;</span>), <span class="tok-number">3</span>);</span>
<span class="line" id="L611">    <span class="tok-kw">try</span> testing.expectEqual(indexOfDiff(<span class="tok-type">u8</span>, <span class="tok-str">&quot;one twx&quot;</span>, <span class="tok-str">&quot;one two&quot;</span>), <span class="tok-number">6</span>);</span>
<span class="line" id="L612">    <span class="tok-kw">try</span> testing.expectEqual(indexOfDiff(<span class="tok-type">u8</span>, <span class="tok-str">&quot;xne&quot;</span>, <span class="tok-str">&quot;one&quot;</span>), <span class="tok-number">0</span>);</span>
<span class="line" id="L613">}</span>
<span class="line" id="L614"></span>
<span class="line" id="L615"><span class="tok-comment">/// Takes a pointer to an array, a sentinel-terminated pointer, or a slice, and</span></span>
<span class="line" id="L616"><span class="tok-comment">/// returns a slice. If there is a sentinel on the input type, there will be a</span></span>
<span class="line" id="L617"><span class="tok-comment">/// sentinel on the output type. The constness of the output type matches</span></span>
<span class="line" id="L618"><span class="tok-comment">/// the constness of the input type. `[*c]` pointers are assumed to be 0-terminated,</span></span>
<span class="line" id="L619"><span class="tok-comment">/// and assumed to not allow null.</span></span>
<span class="line" id="L620"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">Span</span>(<span class="tok-kw">comptime</span> T: <span class="tok-type">type</span>) <span class="tok-type">type</span> {</span>
<span class="line" id="L621">    <span class="tok-kw">switch</span> (<span class="tok-builtin">@typeInfo</span>(T)) {</span>
<span class="line" id="L622">        .Optional =&gt; |optional_info| {</span>
<span class="line" id="L623">            <span class="tok-kw">return</span> ?Span(optional_info.child);</span>
<span class="line" id="L624">        },</span>
<span class="line" id="L625">        .Pointer =&gt; |ptr_info| {</span>
<span class="line" id="L626">            <span class="tok-kw">var</span> new_ptr_info = ptr_info;</span>
<span class="line" id="L627">            <span class="tok-kw">switch</span> (ptr_info.size) {</span>
<span class="line" id="L628">                .One =&gt; <span class="tok-kw">switch</span> (<span class="tok-builtin">@typeInfo</span>(ptr_info.child)) {</span>
<span class="line" id="L629">                    .Array =&gt; |info| {</span>
<span class="line" id="L630">                        new_ptr_info.child = info.child;</span>
<span class="line" id="L631">                        new_ptr_info.sentinel = info.sentinel;</span>
<span class="line" id="L632">                    },</span>
<span class="line" id="L633">                    <span class="tok-kw">else</span> =&gt; <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;invalid type given to std.mem.Span&quot;</span>),</span>
<span class="line" id="L634">                },</span>
<span class="line" id="L635">                .C =&gt; {</span>
<span class="line" id="L636">                    new_ptr_info.sentinel = &amp;<span class="tok-builtin">@as</span>(ptr_info.child, <span class="tok-number">0</span>);</span>
<span class="line" id="L637">                    new_ptr_info.is_allowzero = <span class="tok-null">false</span>;</span>
<span class="line" id="L638">                },</span>
<span class="line" id="L639">                .Many, .Slice =&gt; {},</span>
<span class="line" id="L640">            }</span>
<span class="line" id="L641">            new_ptr_info.size = .Slice;</span>
<span class="line" id="L642">            <span class="tok-kw">return</span> <span class="tok-builtin">@Type</span>(.{ .Pointer = new_ptr_info });</span>
<span class="line" id="L643">        },</span>
<span class="line" id="L644">        <span class="tok-kw">else</span> =&gt; <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;invalid type given to std.mem.Span&quot;</span>),</span>
<span class="line" id="L645">    }</span>
<span class="line" id="L646">}</span>
<span class="line" id="L647"></span>
<span class="line" id="L648"><span class="tok-kw">test</span> <span class="tok-str">&quot;Span&quot;</span> {</span>
<span class="line" id="L649">    <span class="tok-kw">try</span> testing.expect(Span(*[<span class="tok-number">5</span>]<span class="tok-type">u16</span>) == []<span class="tok-type">u16</span>);</span>
<span class="line" id="L650">    <span class="tok-kw">try</span> testing.expect(Span(?*[<span class="tok-number">5</span>]<span class="tok-type">u16</span>) == ?[]<span class="tok-type">u16</span>);</span>
<span class="line" id="L651">    <span class="tok-kw">try</span> testing.expect(Span(*<span class="tok-kw">const</span> [<span class="tok-number">5</span>]<span class="tok-type">u16</span>) == []<span class="tok-kw">const</span> <span class="tok-type">u16</span>);</span>
<span class="line" id="L652">    <span class="tok-kw">try</span> testing.expect(Span(?*<span class="tok-kw">const</span> [<span class="tok-number">5</span>]<span class="tok-type">u16</span>) == ?[]<span class="tok-kw">const</span> <span class="tok-type">u16</span>);</span>
<span class="line" id="L653">    <span class="tok-kw">try</span> testing.expect(Span([]<span class="tok-type">u16</span>) == []<span class="tok-type">u16</span>);</span>
<span class="line" id="L654">    <span class="tok-kw">try</span> testing.expect(Span(?[]<span class="tok-type">u16</span>) == ?[]<span class="tok-type">u16</span>);</span>
<span class="line" id="L655">    <span class="tok-kw">try</span> testing.expect(Span([]<span class="tok-kw">const</span> <span class="tok-type">u8</span>) == []<span class="tok-kw">const</span> <span class="tok-type">u8</span>);</span>
<span class="line" id="L656">    <span class="tok-kw">try</span> testing.expect(Span(?[]<span class="tok-kw">const</span> <span class="tok-type">u8</span>) == ?[]<span class="tok-kw">const</span> <span class="tok-type">u8</span>);</span>
<span class="line" id="L657">    <span class="tok-kw">try</span> testing.expect(Span([:<span class="tok-number">1</span>]<span class="tok-type">u16</span>) == [:<span class="tok-number">1</span>]<span class="tok-type">u16</span>);</span>
<span class="line" id="L658">    <span class="tok-kw">try</span> testing.expect(Span(?[:<span class="tok-number">1</span>]<span class="tok-type">u16</span>) == ?[:<span class="tok-number">1</span>]<span class="tok-type">u16</span>);</span>
<span class="line" id="L659">    <span class="tok-kw">try</span> testing.expect(Span([:<span class="tok-number">1</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span>) == [:<span class="tok-number">1</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span>);</span>
<span class="line" id="L660">    <span class="tok-kw">try</span> testing.expect(Span(?[:<span class="tok-number">1</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span>) == ?[:<span class="tok-number">1</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span>);</span>
<span class="line" id="L661">    <span class="tok-kw">try</span> testing.expect(Span([*:<span class="tok-number">1</span>]<span class="tok-type">u16</span>) == [:<span class="tok-number">1</span>]<span class="tok-type">u16</span>);</span>
<span class="line" id="L662">    <span class="tok-kw">try</span> testing.expect(Span(?[*:<span class="tok-number">1</span>]<span class="tok-type">u16</span>) == ?[:<span class="tok-number">1</span>]<span class="tok-type">u16</span>);</span>
<span class="line" id="L663">    <span class="tok-kw">try</span> testing.expect(Span([*:<span class="tok-number">1</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span>) == [:<span class="tok-number">1</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span>);</span>
<span class="line" id="L664">    <span class="tok-kw">try</span> testing.expect(Span(?[*:<span class="tok-number">1</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span>) == ?[:<span class="tok-number">1</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span>);</span>
<span class="line" id="L665">    <span class="tok-kw">try</span> testing.expect(Span([*c]<span class="tok-type">u16</span>) == [:<span class="tok-number">0</span>]<span class="tok-type">u16</span>);</span>
<span class="line" id="L666">    <span class="tok-kw">try</span> testing.expect(Span(?[*c]<span class="tok-type">u16</span>) == ?[:<span class="tok-number">0</span>]<span class="tok-type">u16</span>);</span>
<span class="line" id="L667">    <span class="tok-kw">try</span> testing.expect(Span([*c]<span class="tok-kw">const</span> <span class="tok-type">u8</span>) == [:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span>);</span>
<span class="line" id="L668">    <span class="tok-kw">try</span> testing.expect(Span(?[*c]<span class="tok-kw">const</span> <span class="tok-type">u8</span>) == ?[:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span>);</span>
<span class="line" id="L669">}</span>
<span class="line" id="L670"></span>
<span class="line" id="L671"><span class="tok-comment">/// Takes a pointer to an array, a sentinel-terminated pointer, or a slice, and</span></span>
<span class="line" id="L672"><span class="tok-comment">/// returns a slice. If there is a sentinel on the input type, there will be a</span></span>
<span class="line" id="L673"><span class="tok-comment">/// sentinel on the output type. The constness of the output type matches</span></span>
<span class="line" id="L674"><span class="tok-comment">/// the constness of the input type.</span></span>
<span class="line" id="L675"><span class="tok-comment">///</span></span>
<span class="line" id="L676"><span class="tok-comment">/// When there is both a sentinel and an array length or slice length, the</span></span>
<span class="line" id="L677"><span class="tok-comment">/// length value is used instead of the sentinel.</span></span>
<span class="line" id="L678"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">span</span>(ptr: <span class="tok-kw">anytype</span>) Span(<span class="tok-builtin">@TypeOf</span>(ptr)) {</span>
<span class="line" id="L679">    <span class="tok-kw">if</span> (<span class="tok-builtin">@typeInfo</span>(<span class="tok-builtin">@TypeOf</span>(ptr)) == .Optional) {</span>
<span class="line" id="L680">        <span class="tok-kw">if</span> (ptr) |non_null| {</span>
<span class="line" id="L681">            <span class="tok-kw">return</span> span(non_null);</span>
<span class="line" id="L682">        } <span class="tok-kw">else</span> {</span>
<span class="line" id="L683">            <span class="tok-kw">return</span> <span class="tok-null">null</span>;</span>
<span class="line" id="L684">        }</span>
<span class="line" id="L685">    }</span>
<span class="line" id="L686">    <span class="tok-kw">const</span> Result = Span(<span class="tok-builtin">@TypeOf</span>(ptr));</span>
<span class="line" id="L687">    <span class="tok-kw">const</span> l = len(ptr);</span>
<span class="line" id="L688">    <span class="tok-kw">const</span> ptr_info = <span class="tok-builtin">@typeInfo</span>(Result).Pointer;</span>
<span class="line" id="L689">    <span class="tok-kw">if</span> (ptr_info.sentinel) |s_ptr| {</span>
<span class="line" id="L690">        <span class="tok-kw">const</span> s = <span class="tok-builtin">@ptrCast</span>(*<span class="tok-kw">const</span> ptr_info.child, s_ptr).*;</span>
<span class="line" id="L691">        <span class="tok-kw">return</span> ptr[<span class="tok-number">0</span>..l :s];</span>
<span class="line" id="L692">    } <span class="tok-kw">else</span> {</span>
<span class="line" id="L693">        <span class="tok-kw">return</span> ptr[<span class="tok-number">0</span>..l];</span>
<span class="line" id="L694">    }</span>
<span class="line" id="L695">}</span>
<span class="line" id="L696"></span>
<span class="line" id="L697"><span class="tok-kw">test</span> <span class="tok-str">&quot;span&quot;</span> {</span>
<span class="line" id="L698">    <span class="tok-kw">var</span> array: [<span class="tok-number">5</span>]<span class="tok-type">u16</span> = [_]<span class="tok-type">u16</span>{ <span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">4</span>, <span class="tok-number">5</span> };</span>
<span class="line" id="L699">    <span class="tok-kw">const</span> ptr = <span class="tok-builtin">@as</span>([*:<span class="tok-number">3</span>]<span class="tok-type">u16</span>, array[<span class="tok-number">0</span>..<span class="tok-number">2</span> :<span class="tok-number">3</span>]);</span>
<span class="line" id="L700">    <span class="tok-kw">try</span> testing.expect(eql(<span class="tok-type">u16</span>, span(ptr), &amp;[_]<span class="tok-type">u16</span>{ <span class="tok-number">1</span>, <span class="tok-number">2</span> }));</span>
<span class="line" id="L701">    <span class="tok-kw">try</span> testing.expect(eql(<span class="tok-type">u16</span>, span(&amp;array), &amp;[_]<span class="tok-type">u16</span>{ <span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">4</span>, <span class="tok-number">5</span> }));</span>
<span class="line" id="L702">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(?[:<span class="tok-number">0</span>]<span class="tok-type">u16</span>, <span class="tok-null">null</span>), span(<span class="tok-builtin">@as</span>(?[*:<span class="tok-number">0</span>]<span class="tok-type">u16</span>, <span class="tok-null">null</span>)));</span>
<span class="line" id="L703">}</span>
<span class="line" id="L704"></span>
<span class="line" id="L705"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> spanZ = <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;deprecated; use use std.mem.span() or std.mem.sliceTo()&quot;</span>);</span>
<span class="line" id="L706"></span>
<span class="line" id="L707"><span class="tok-comment">/// Helper for the return type of sliceTo()</span></span>
<span class="line" id="L708"><span class="tok-kw">fn</span> <span class="tok-fn">SliceTo</span>(<span class="tok-kw">comptime</span> T: <span class="tok-type">type</span>, <span class="tok-kw">comptime</span> end: meta.Elem(T)) <span class="tok-type">type</span> {</span>
<span class="line" id="L709">    <span class="tok-kw">switch</span> (<span class="tok-builtin">@typeInfo</span>(T)) {</span>
<span class="line" id="L710">        .Optional =&gt; |optional_info| {</span>
<span class="line" id="L711">            <span class="tok-kw">return</span> ?SliceTo(optional_info.child, end);</span>
<span class="line" id="L712">        },</span>
<span class="line" id="L713">        .Pointer =&gt; |ptr_info| {</span>
<span class="line" id="L714">            <span class="tok-kw">var</span> new_ptr_info = ptr_info;</span>
<span class="line" id="L715">            new_ptr_info.size = .Slice;</span>
<span class="line" id="L716">            <span class="tok-kw">switch</span> (ptr_info.size) {</span>
<span class="line" id="L717">                .One =&gt; <span class="tok-kw">switch</span> (<span class="tok-builtin">@typeInfo</span>(ptr_info.child)) {</span>
<span class="line" id="L718">                    .Array =&gt; |array_info| {</span>
<span class="line" id="L719">                        new_ptr_info.child = array_info.child;</span>
<span class="line" id="L720">                        <span class="tok-comment">// The return type must only be sentinel terminated if we are guaranteed</span>
</span>
<span class="line" id="L721">                        <span class="tok-comment">// to find the value searched for, which is only the case if it matches</span>
</span>
<span class="line" id="L722">                        <span class="tok-comment">// the sentinel of the type passed.</span>
</span>
<span class="line" id="L723">                        <span class="tok-kw">if</span> (array_info.sentinel) |sentinel_ptr| {</span>
<span class="line" id="L724">                            <span class="tok-kw">const</span> sentinel = <span class="tok-builtin">@ptrCast</span>(*<span class="tok-kw">const</span> array_info.child, sentinel_ptr).*;</span>
<span class="line" id="L725">                            <span class="tok-kw">if</span> (end == sentinel) {</span>
<span class="line" id="L726">                                new_ptr_info.sentinel = &amp;end;</span>
<span class="line" id="L727">                            } <span class="tok-kw">else</span> {</span>
<span class="line" id="L728">                                new_ptr_info.sentinel = <span class="tok-null">null</span>;</span>
<span class="line" id="L729">                            }</span>
<span class="line" id="L730">                        }</span>
<span class="line" id="L731">                    },</span>
<span class="line" id="L732">                    <span class="tok-kw">else</span> =&gt; {},</span>
<span class="line" id="L733">                },</span>
<span class="line" id="L734">                .Many, .Slice =&gt; {</span>
<span class="line" id="L735">                    <span class="tok-comment">// The return type must only be sentinel terminated if we are guaranteed</span>
</span>
<span class="line" id="L736">                    <span class="tok-comment">// to find the value searched for, which is only the case if it matches</span>
</span>
<span class="line" id="L737">                    <span class="tok-comment">// the sentinel of the type passed.</span>
</span>
<span class="line" id="L738">                    <span class="tok-kw">if</span> (ptr_info.sentinel) |sentinel_ptr| {</span>
<span class="line" id="L739">                        <span class="tok-kw">const</span> sentinel = <span class="tok-builtin">@ptrCast</span>(*<span class="tok-kw">const</span> ptr_info.child, sentinel_ptr).*;</span>
<span class="line" id="L740">                        <span class="tok-kw">if</span> (end == sentinel) {</span>
<span class="line" id="L741">                            new_ptr_info.sentinel = &amp;end;</span>
<span class="line" id="L742">                        } <span class="tok-kw">else</span> {</span>
<span class="line" id="L743">                            new_ptr_info.sentinel = <span class="tok-null">null</span>;</span>
<span class="line" id="L744">                        }</span>
<span class="line" id="L745">                    }</span>
<span class="line" id="L746">                },</span>
<span class="line" id="L747">                .C =&gt; {</span>
<span class="line" id="L748">                    new_ptr_info.sentinel = &amp;end;</span>
<span class="line" id="L749">                    <span class="tok-comment">// C pointers are always allowzero, but we don't want the return type to be.</span>
</span>
<span class="line" id="L750">                    assert(new_ptr_info.is_allowzero);</span>
<span class="line" id="L751">                    new_ptr_info.is_allowzero = <span class="tok-null">false</span>;</span>
<span class="line" id="L752">                },</span>
<span class="line" id="L753">            }</span>
<span class="line" id="L754">            <span class="tok-kw">return</span> <span class="tok-builtin">@Type</span>(.{ .Pointer = new_ptr_info });</span>
<span class="line" id="L755">        },</span>
<span class="line" id="L756">        <span class="tok-kw">else</span> =&gt; {},</span>
<span class="line" id="L757">    }</span>
<span class="line" id="L758">    <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;invalid type given to std.mem.sliceTo: &quot;</span> ++ <span class="tok-builtin">@typeName</span>(T));</span>
<span class="line" id="L759">}</span>
<span class="line" id="L760"></span>
<span class="line" id="L761"><span class="tok-comment">/// Takes an array, a pointer to an array, a sentinel-terminated pointer, or a slice and</span></span>
<span class="line" id="L762"><span class="tok-comment">/// iterates searching for the first occurrence of `end`, returning the scanned slice.</span></span>
<span class="line" id="L763"><span class="tok-comment">/// If `end` is not found, the full length of the array/slice/sentinel terminated pointer is returned.</span></span>
<span class="line" id="L764"><span class="tok-comment">/// If the pointer type is sentinel terminated and `end` matches that terminator, the</span></span>
<span class="line" id="L765"><span class="tok-comment">/// resulting slice is also sentinel terminated.</span></span>
<span class="line" id="L766"><span class="tok-comment">/// Pointer properties such as mutability and alignment are preserved.</span></span>
<span class="line" id="L767"><span class="tok-comment">/// C pointers are assumed to be non-null.</span></span>
<span class="line" id="L768"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">sliceTo</span>(ptr: <span class="tok-kw">anytype</span>, <span class="tok-kw">comptime</span> end: meta.Elem(<span class="tok-builtin">@TypeOf</span>(ptr))) SliceTo(<span class="tok-builtin">@TypeOf</span>(ptr), end) {</span>
<span class="line" id="L769">    <span class="tok-kw">if</span> (<span class="tok-builtin">@typeInfo</span>(<span class="tok-builtin">@TypeOf</span>(ptr)) == .Optional) {</span>
<span class="line" id="L770">        <span class="tok-kw">const</span> non_null = ptr <span class="tok-kw">orelse</span> <span class="tok-kw">return</span> <span class="tok-null">null</span>;</span>
<span class="line" id="L771">        <span class="tok-kw">return</span> sliceTo(non_null, end);</span>
<span class="line" id="L772">    }</span>
<span class="line" id="L773">    <span class="tok-kw">const</span> Result = SliceTo(<span class="tok-builtin">@TypeOf</span>(ptr), end);</span>
<span class="line" id="L774">    <span class="tok-kw">const</span> length = lenSliceTo(ptr, end);</span>
<span class="line" id="L775">    <span class="tok-kw">const</span> ptr_info = <span class="tok-builtin">@typeInfo</span>(Result).Pointer;</span>
<span class="line" id="L776">    <span class="tok-kw">if</span> (ptr_info.sentinel) |s_ptr| {</span>
<span class="line" id="L777">        <span class="tok-kw">const</span> s = <span class="tok-builtin">@ptrCast</span>(*<span class="tok-kw">const</span> ptr_info.child, s_ptr).*;</span>
<span class="line" id="L778">        <span class="tok-kw">return</span> ptr[<span class="tok-number">0</span>..length :s];</span>
<span class="line" id="L779">    } <span class="tok-kw">else</span> {</span>
<span class="line" id="L780">        <span class="tok-kw">return</span> ptr[<span class="tok-number">0</span>..length];</span>
<span class="line" id="L781">    }</span>
<span class="line" id="L782">}</span>
<span class="line" id="L783"></span>
<span class="line" id="L784"><span class="tok-kw">test</span> <span class="tok-str">&quot;sliceTo&quot;</span> {</span>
<span class="line" id="L785">    <span class="tok-kw">try</span> testing.expectEqualSlices(<span class="tok-type">u8</span>, <span class="tok-str">&quot;aoeu&quot;</span>, sliceTo(<span class="tok-str">&quot;aoeu&quot;</span>, <span class="tok-number">0</span>));</span>
<span class="line" id="L786"></span>
<span class="line" id="L787">    {</span>
<span class="line" id="L788">        <span class="tok-kw">var</span> array: [<span class="tok-number">5</span>]<span class="tok-type">u16</span> = [_]<span class="tok-type">u16</span>{ <span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">4</span>, <span class="tok-number">5</span> };</span>
<span class="line" id="L789">        <span class="tok-kw">try</span> testing.expectEqualSlices(<span class="tok-type">u16</span>, &amp;array, sliceTo(&amp;array, <span class="tok-number">0</span>));</span>
<span class="line" id="L790">        <span class="tok-kw">try</span> testing.expectEqualSlices(<span class="tok-type">u16</span>, array[<span class="tok-number">0</span>..<span class="tok-number">3</span>], sliceTo(array[<span class="tok-number">0</span>..<span class="tok-number">3</span>], <span class="tok-number">0</span>));</span>
<span class="line" id="L791">        <span class="tok-kw">try</span> testing.expectEqualSlices(<span class="tok-type">u16</span>, array[<span class="tok-number">0</span>..<span class="tok-number">2</span>], sliceTo(&amp;array, <span class="tok-number">3</span>));</span>
<span class="line" id="L792">        <span class="tok-kw">try</span> testing.expectEqualSlices(<span class="tok-type">u16</span>, array[<span class="tok-number">0</span>..<span class="tok-number">2</span>], sliceTo(array[<span class="tok-number">0</span>..<span class="tok-number">3</span>], <span class="tok-number">3</span>));</span>
<span class="line" id="L793"></span>
<span class="line" id="L794">        <span class="tok-kw">const</span> sentinel_ptr = <span class="tok-builtin">@ptrCast</span>([*:<span class="tok-number">5</span>]<span class="tok-type">u16</span>, &amp;array);</span>
<span class="line" id="L795">        <span class="tok-kw">try</span> testing.expectEqualSlices(<span class="tok-type">u16</span>, array[<span class="tok-number">0</span>..<span class="tok-number">2</span>], sliceTo(sentinel_ptr, <span class="tok-number">3</span>));</span>
<span class="line" id="L796">        <span class="tok-kw">try</span> testing.expectEqualSlices(<span class="tok-type">u16</span>, array[<span class="tok-number">0</span>..<span class="tok-number">4</span>], sliceTo(sentinel_ptr, <span class="tok-number">99</span>));</span>
<span class="line" id="L797"></span>
<span class="line" id="L798">        <span class="tok-kw">const</span> optional_sentinel_ptr = <span class="tok-builtin">@ptrCast</span>(?[*:<span class="tok-number">5</span>]<span class="tok-type">u16</span>, &amp;array);</span>
<span class="line" id="L799">        <span class="tok-kw">try</span> testing.expectEqualSlices(<span class="tok-type">u16</span>, array[<span class="tok-number">0</span>..<span class="tok-number">2</span>], sliceTo(optional_sentinel_ptr, <span class="tok-number">3</span>).?);</span>
<span class="line" id="L800">        <span class="tok-kw">try</span> testing.expectEqualSlices(<span class="tok-type">u16</span>, array[<span class="tok-number">0</span>..<span class="tok-number">4</span>], sliceTo(optional_sentinel_ptr, <span class="tok-number">99</span>).?);</span>
<span class="line" id="L801"></span>
<span class="line" id="L802">        <span class="tok-kw">const</span> c_ptr = <span class="tok-builtin">@as</span>([*c]<span class="tok-type">u16</span>, &amp;array);</span>
<span class="line" id="L803">        <span class="tok-kw">try</span> testing.expectEqualSlices(<span class="tok-type">u16</span>, array[<span class="tok-number">0</span>..<span class="tok-number">2</span>], sliceTo(c_ptr, <span class="tok-number">3</span>));</span>
<span class="line" id="L804"></span>
<span class="line" id="L805">        <span class="tok-kw">const</span> slice: []<span class="tok-type">u16</span> = &amp;array;</span>
<span class="line" id="L806">        <span class="tok-kw">try</span> testing.expectEqualSlices(<span class="tok-type">u16</span>, array[<span class="tok-number">0</span>..<span class="tok-number">2</span>], sliceTo(slice, <span class="tok-number">3</span>));</span>
<span class="line" id="L807">        <span class="tok-kw">try</span> testing.expectEqualSlices(<span class="tok-type">u16</span>, &amp;array, sliceTo(slice, <span class="tok-number">99</span>));</span>
<span class="line" id="L808"></span>
<span class="line" id="L809">        <span class="tok-kw">const</span> sentinel_slice: [:<span class="tok-number">5</span>]<span class="tok-type">u16</span> = array[<span class="tok-number">0</span>..<span class="tok-number">4</span> :<span class="tok-number">5</span>];</span>
<span class="line" id="L810">        <span class="tok-kw">try</span> testing.expectEqualSlices(<span class="tok-type">u16</span>, array[<span class="tok-number">0</span>..<span class="tok-number">2</span>], sliceTo(sentinel_slice, <span class="tok-number">3</span>));</span>
<span class="line" id="L811">        <span class="tok-kw">try</span> testing.expectEqualSlices(<span class="tok-type">u16</span>, array[<span class="tok-number">0</span>..<span class="tok-number">4</span>], sliceTo(sentinel_slice, <span class="tok-number">99</span>));</span>
<span class="line" id="L812">    }</span>
<span class="line" id="L813">    {</span>
<span class="line" id="L814">        <span class="tok-kw">var</span> sentinel_array: [<span class="tok-number">5</span>:<span class="tok-number">0</span>]<span class="tok-type">u16</span> = [_:<span class="tok-number">0</span>]<span class="tok-type">u16</span>{ <span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">4</span>, <span class="tok-number">5</span> };</span>
<span class="line" id="L815">        <span class="tok-kw">try</span> testing.expectEqualSlices(<span class="tok-type">u16</span>, sentinel_array[<span class="tok-number">0</span>..<span class="tok-number">2</span>], sliceTo(&amp;sentinel_array, <span class="tok-number">3</span>));</span>
<span class="line" id="L816">        <span class="tok-kw">try</span> testing.expectEqualSlices(<span class="tok-type">u16</span>, &amp;sentinel_array, sliceTo(&amp;sentinel_array, <span class="tok-number">0</span>));</span>
<span class="line" id="L817">        <span class="tok-kw">try</span> testing.expectEqualSlices(<span class="tok-type">u16</span>, &amp;sentinel_array, sliceTo(&amp;sentinel_array, <span class="tok-number">99</span>));</span>
<span class="line" id="L818">    }</span>
<span class="line" id="L819"></span>
<span class="line" id="L820">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(?[]<span class="tok-type">u8</span>, <span class="tok-null">null</span>), sliceTo(<span class="tok-builtin">@as</span>(?[]<span class="tok-type">u8</span>, <span class="tok-null">null</span>), <span class="tok-number">0</span>));</span>
<span class="line" id="L821">}</span>
<span class="line" id="L822"></span>
<span class="line" id="L823"><span class="tok-comment">/// Private helper for sliceTo(). If you want the length, use sliceTo(foo, x).len</span></span>
<span class="line" id="L824"><span class="tok-kw">fn</span> <span class="tok-fn">lenSliceTo</span>(ptr: <span class="tok-kw">anytype</span>, <span class="tok-kw">comptime</span> end: meta.Elem(<span class="tok-builtin">@TypeOf</span>(ptr))) <span class="tok-type">usize</span> {</span>
<span class="line" id="L825">    <span class="tok-kw">switch</span> (<span class="tok-builtin">@typeInfo</span>(<span class="tok-builtin">@TypeOf</span>(ptr))) {</span>
<span class="line" id="L826">        .Pointer =&gt; |ptr_info| <span class="tok-kw">switch</span> (ptr_info.size) {</span>
<span class="line" id="L827">            .One =&gt; <span class="tok-kw">switch</span> (<span class="tok-builtin">@typeInfo</span>(ptr_info.child)) {</span>
<span class="line" id="L828">                .Array =&gt; |array_info| {</span>
<span class="line" id="L829">                    <span class="tok-kw">if</span> (array_info.sentinel) |sentinel_ptr| {</span>
<span class="line" id="L830">                        <span class="tok-kw">const</span> sentinel = <span class="tok-builtin">@ptrCast</span>(*<span class="tok-kw">const</span> array_info.child, sentinel_ptr).*;</span>
<span class="line" id="L831">                        <span class="tok-kw">if</span> (sentinel == end) {</span>
<span class="line" id="L832">                            <span class="tok-kw">return</span> indexOfSentinel(array_info.child, end, ptr);</span>
<span class="line" id="L833">                        }</span>
<span class="line" id="L834">                    }</span>
<span class="line" id="L835">                    <span class="tok-kw">return</span> indexOfScalar(array_info.child, ptr, end) <span class="tok-kw">orelse</span> array_info.len;</span>
<span class="line" id="L836">                },</span>
<span class="line" id="L837">                <span class="tok-kw">else</span> =&gt; {},</span>
<span class="line" id="L838">            },</span>
<span class="line" id="L839">            .Many =&gt; <span class="tok-kw">if</span> (ptr_info.sentinel) |sentinel_ptr| {</span>
<span class="line" id="L840">                <span class="tok-kw">const</span> sentinel = <span class="tok-builtin">@ptrCast</span>(*<span class="tok-kw">const</span> ptr_info.child, sentinel_ptr).*;</span>
<span class="line" id="L841">                <span class="tok-comment">// We may be looking for something other than the sentinel,</span>
</span>
<span class="line" id="L842">                <span class="tok-comment">// but iterating past the sentinel would be a bug so we need</span>
</span>
<span class="line" id="L843">                <span class="tok-comment">// to check for both.</span>
</span>
<span class="line" id="L844">                <span class="tok-kw">var</span> i: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L845">                <span class="tok-kw">while</span> (ptr[i] != end <span class="tok-kw">and</span> ptr[i] != sentinel) i += <span class="tok-number">1</span>;</span>
<span class="line" id="L846">                <span class="tok-kw">return</span> i;</span>
<span class="line" id="L847">            },</span>
<span class="line" id="L848">            .C =&gt; {</span>
<span class="line" id="L849">                assert(ptr != <span class="tok-null">null</span>);</span>
<span class="line" id="L850">                <span class="tok-kw">return</span> indexOfSentinel(ptr_info.child, end, ptr);</span>
<span class="line" id="L851">            },</span>
<span class="line" id="L852">            .Slice =&gt; {</span>
<span class="line" id="L853">                <span class="tok-kw">if</span> (ptr_info.sentinel) |sentinel_ptr| {</span>
<span class="line" id="L854">                    <span class="tok-kw">const</span> sentinel = <span class="tok-builtin">@ptrCast</span>(*<span class="tok-kw">const</span> ptr_info.child, sentinel_ptr).*;</span>
<span class="line" id="L855">                    <span class="tok-kw">if</span> (sentinel == end) {</span>
<span class="line" id="L856">                        <span class="tok-kw">return</span> indexOfSentinel(ptr_info.child, sentinel, ptr);</span>
<span class="line" id="L857">                    }</span>
<span class="line" id="L858">                }</span>
<span class="line" id="L859">                <span class="tok-kw">return</span> indexOfScalar(ptr_info.child, ptr, end) <span class="tok-kw">orelse</span> ptr.len;</span>
<span class="line" id="L860">            },</span>
<span class="line" id="L861">        },</span>
<span class="line" id="L862">        <span class="tok-kw">else</span> =&gt; {},</span>
<span class="line" id="L863">    }</span>
<span class="line" id="L864">    <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;invalid type given to std.mem.sliceTo: &quot;</span> ++ <span class="tok-builtin">@typeName</span>(<span class="tok-builtin">@TypeOf</span>(ptr)));</span>
<span class="line" id="L865">}</span>
<span class="line" id="L866"></span>
<span class="line" id="L867"><span class="tok-kw">test</span> <span class="tok-str">&quot;lenSliceTo&quot;</span> {</span>
<span class="line" id="L868">    <span class="tok-kw">try</span> testing.expect(lenSliceTo(<span class="tok-str">&quot;aoeu&quot;</span>, <span class="tok-number">0</span>) == <span class="tok-number">4</span>);</span>
<span class="line" id="L869"></span>
<span class="line" id="L870">    {</span>
<span class="line" id="L871">        <span class="tok-kw">var</span> array: [<span class="tok-number">5</span>]<span class="tok-type">u16</span> = [_]<span class="tok-type">u16</span>{ <span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">4</span>, <span class="tok-number">5</span> };</span>
<span class="line" id="L872">        <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">usize</span>, <span class="tok-number">5</span>), lenSliceTo(&amp;array, <span class="tok-number">0</span>));</span>
<span class="line" id="L873">        <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">usize</span>, <span class="tok-number">3</span>), lenSliceTo(array[<span class="tok-number">0</span>..<span class="tok-number">3</span>], <span class="tok-number">0</span>));</span>
<span class="line" id="L874">        <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">usize</span>, <span class="tok-number">2</span>), lenSliceTo(&amp;array, <span class="tok-number">3</span>));</span>
<span class="line" id="L875">        <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">usize</span>, <span class="tok-number">2</span>), lenSliceTo(array[<span class="tok-number">0</span>..<span class="tok-number">3</span>], <span class="tok-number">3</span>));</span>
<span class="line" id="L876"></span>
<span class="line" id="L877">        <span class="tok-kw">const</span> sentinel_ptr = <span class="tok-builtin">@ptrCast</span>([*:<span class="tok-number">5</span>]<span class="tok-type">u16</span>, &amp;array);</span>
<span class="line" id="L878">        <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">usize</span>, <span class="tok-number">2</span>), lenSliceTo(sentinel_ptr, <span class="tok-number">3</span>));</span>
<span class="line" id="L879">        <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">usize</span>, <span class="tok-number">4</span>), lenSliceTo(sentinel_ptr, <span class="tok-number">99</span>));</span>
<span class="line" id="L880"></span>
<span class="line" id="L881">        <span class="tok-kw">const</span> c_ptr = <span class="tok-builtin">@as</span>([*c]<span class="tok-type">u16</span>, &amp;array);</span>
<span class="line" id="L882">        <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">usize</span>, <span class="tok-number">2</span>), lenSliceTo(c_ptr, <span class="tok-number">3</span>));</span>
<span class="line" id="L883"></span>
<span class="line" id="L884">        <span class="tok-kw">const</span> slice: []<span class="tok-type">u16</span> = &amp;array;</span>
<span class="line" id="L885">        <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">usize</span>, <span class="tok-number">2</span>), lenSliceTo(slice, <span class="tok-number">3</span>));</span>
<span class="line" id="L886">        <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">usize</span>, <span class="tok-number">5</span>), lenSliceTo(slice, <span class="tok-number">99</span>));</span>
<span class="line" id="L887"></span>
<span class="line" id="L888">        <span class="tok-kw">const</span> sentinel_slice: [:<span class="tok-number">5</span>]<span class="tok-type">u16</span> = array[<span class="tok-number">0</span>..<span class="tok-number">4</span> :<span class="tok-number">5</span>];</span>
<span class="line" id="L889">        <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">usize</span>, <span class="tok-number">2</span>), lenSliceTo(sentinel_slice, <span class="tok-number">3</span>));</span>
<span class="line" id="L890">        <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">usize</span>, <span class="tok-number">4</span>), lenSliceTo(sentinel_slice, <span class="tok-number">99</span>));</span>
<span class="line" id="L891">    }</span>
<span class="line" id="L892">    {</span>
<span class="line" id="L893">        <span class="tok-kw">var</span> sentinel_array: [<span class="tok-number">5</span>:<span class="tok-number">0</span>]<span class="tok-type">u16</span> = [_:<span class="tok-number">0</span>]<span class="tok-type">u16</span>{ <span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">4</span>, <span class="tok-number">5</span> };</span>
<span class="line" id="L894">        <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">usize</span>, <span class="tok-number">2</span>), lenSliceTo(&amp;sentinel_array, <span class="tok-number">3</span>));</span>
<span class="line" id="L895">        <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">usize</span>, <span class="tok-number">5</span>), lenSliceTo(&amp;sentinel_array, <span class="tok-number">0</span>));</span>
<span class="line" id="L896">        <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">usize</span>, <span class="tok-number">5</span>), lenSliceTo(&amp;sentinel_array, <span class="tok-number">99</span>));</span>
<span class="line" id="L897">    }</span>
<span class="line" id="L898">}</span>
<span class="line" id="L899"></span>
<span class="line" id="L900"><span class="tok-comment">/// Takes a pointer to an array, an array, a vector, a sentinel-terminated pointer,</span></span>
<span class="line" id="L901"><span class="tok-comment">/// a slice or a tuple, and returns the length.</span></span>
<span class="line" id="L902"><span class="tok-comment">/// In the case of a sentinel-terminated array, it uses the array length.</span></span>
<span class="line" id="L903"><span class="tok-comment">/// For C pointers it assumes it is a pointer-to-many with a 0 sentinel.</span></span>
<span class="line" id="L904"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">len</span>(value: <span class="tok-kw">anytype</span>) <span class="tok-type">usize</span> {</span>
<span class="line" id="L905">    <span class="tok-kw">return</span> <span class="tok-kw">switch</span> (<span class="tok-builtin">@typeInfo</span>(<span class="tok-builtin">@TypeOf</span>(value))) {</span>
<span class="line" id="L906">        .Array =&gt; |info| info.len,</span>
<span class="line" id="L907">        .Vector =&gt; |info| info.len,</span>
<span class="line" id="L908">        .Pointer =&gt; |info| <span class="tok-kw">switch</span> (info.size) {</span>
<span class="line" id="L909">            .One =&gt; <span class="tok-kw">switch</span> (<span class="tok-builtin">@typeInfo</span>(info.child)) {</span>
<span class="line" id="L910">                .Array =&gt; value.len,</span>
<span class="line" id="L911">                <span class="tok-kw">else</span> =&gt; <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;invalid type given to std.mem.len&quot;</span>),</span>
<span class="line" id="L912">            },</span>
<span class="line" id="L913">            .Many =&gt; {</span>
<span class="line" id="L914">                <span class="tok-kw">const</span> sentinel_ptr = info.sentinel <span class="tok-kw">orelse</span></span>
<span class="line" id="L915">                    <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;length of pointer with no sentinel&quot;</span>);</span>
<span class="line" id="L916">                <span class="tok-kw">const</span> sentinel = <span class="tok-builtin">@ptrCast</span>(*<span class="tok-kw">const</span> info.child, sentinel_ptr).*;</span>
<span class="line" id="L917">                <span class="tok-kw">return</span> indexOfSentinel(info.child, sentinel, value);</span>
<span class="line" id="L918">            },</span>
<span class="line" id="L919">            .C =&gt; {</span>
<span class="line" id="L920">                assert(value != <span class="tok-null">null</span>);</span>
<span class="line" id="L921">                <span class="tok-kw">return</span> indexOfSentinel(info.child, <span class="tok-number">0</span>, value);</span>
<span class="line" id="L922">            },</span>
<span class="line" id="L923">            .Slice =&gt; value.len,</span>
<span class="line" id="L924">        },</span>
<span class="line" id="L925">        .Struct =&gt; |info| <span class="tok-kw">if</span> (info.is_tuple) {</span>
<span class="line" id="L926">            <span class="tok-kw">return</span> info.fields.len;</span>
<span class="line" id="L927">        } <span class="tok-kw">else</span> <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;invalid type given to std.mem.len&quot;</span>),</span>
<span class="line" id="L928">        <span class="tok-kw">else</span> =&gt; <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;invalid type given to std.mem.len&quot;</span>),</span>
<span class="line" id="L929">    };</span>
<span class="line" id="L930">}</span>
<span class="line" id="L931"></span>
<span class="line" id="L932"><span class="tok-kw">test</span> <span class="tok-str">&quot;len&quot;</span> {</span>
<span class="line" id="L933">    <span class="tok-kw">try</span> testing.expect(len(<span class="tok-str">&quot;aoeu&quot;</span>) == <span class="tok-number">4</span>);</span>
<span class="line" id="L934"></span>
<span class="line" id="L935">    {</span>
<span class="line" id="L936">        <span class="tok-kw">var</span> array: [<span class="tok-number">5</span>]<span class="tok-type">u16</span> = [_]<span class="tok-type">u16</span>{ <span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">4</span>, <span class="tok-number">5</span> };</span>
<span class="line" id="L937">        <span class="tok-kw">try</span> testing.expect(len(&amp;array) == <span class="tok-number">5</span>);</span>
<span class="line" id="L938">        <span class="tok-kw">try</span> testing.expect(len(array[<span class="tok-number">0</span>..<span class="tok-number">3</span>]) == <span class="tok-number">3</span>);</span>
<span class="line" id="L939">        array[<span class="tok-number">2</span>] = <span class="tok-number">0</span>;</span>
<span class="line" id="L940">        <span class="tok-kw">const</span> ptr = <span class="tok-builtin">@as</span>([*:<span class="tok-number">0</span>]<span class="tok-type">u16</span>, array[<span class="tok-number">0</span>..<span class="tok-number">2</span> :<span class="tok-number">0</span>]);</span>
<span class="line" id="L941">        <span class="tok-kw">try</span> testing.expect(len(ptr) == <span class="tok-number">2</span>);</span>
<span class="line" id="L942">    }</span>
<span class="line" id="L943">    {</span>
<span class="line" id="L944">        <span class="tok-kw">var</span> array: [<span class="tok-number">5</span>:<span class="tok-number">0</span>]<span class="tok-type">u16</span> = [_:<span class="tok-number">0</span>]<span class="tok-type">u16</span>{ <span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">4</span>, <span class="tok-number">5</span> };</span>
<span class="line" id="L945">        <span class="tok-kw">try</span> testing.expect(len(&amp;array) == <span class="tok-number">5</span>);</span>
<span class="line" id="L946">        array[<span class="tok-number">2</span>] = <span class="tok-number">0</span>;</span>
<span class="line" id="L947">        <span class="tok-kw">try</span> testing.expect(len(&amp;array) == <span class="tok-number">5</span>);</span>
<span class="line" id="L948">    }</span>
<span class="line" id="L949">    {</span>
<span class="line" id="L950">        <span class="tok-kw">const</span> vector: meta.Vector(<span class="tok-number">2</span>, <span class="tok-type">u32</span>) = [<span class="tok-number">2</span>]<span class="tok-type">u32</span>{ <span class="tok-number">1</span>, <span class="tok-number">2</span> };</span>
<span class="line" id="L951">        <span class="tok-kw">try</span> testing.expect(len(vector) == <span class="tok-number">2</span>);</span>
<span class="line" id="L952">    }</span>
<span class="line" id="L953">    {</span>
<span class="line" id="L954">        <span class="tok-kw">const</span> tuple = .{ <span class="tok-number">1</span>, <span class="tok-number">2</span> };</span>
<span class="line" id="L955">        <span class="tok-kw">try</span> testing.expect(len(tuple) == <span class="tok-number">2</span>);</span>
<span class="line" id="L956">        <span class="tok-kw">try</span> testing.expect(tuple[<span class="tok-number">0</span>] == <span class="tok-number">1</span>);</span>
<span class="line" id="L957">    }</span>
<span class="line" id="L958">}</span>
<span class="line" id="L959"></span>
<span class="line" id="L960"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> lenZ = <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;deprecated; use std.mem.len() or std.mem.sliceTo().len&quot;</span>);</span>
<span class="line" id="L961"></span>
<span class="line" id="L962"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">indexOfSentinel</span>(<span class="tok-kw">comptime</span> Elem: <span class="tok-type">type</span>, <span class="tok-kw">comptime</span> sentinel: Elem, ptr: [*:sentinel]<span class="tok-kw">const</span> Elem) <span class="tok-type">usize</span> {</span>
<span class="line" id="L963">    <span class="tok-kw">var</span> i: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L964">    <span class="tok-kw">while</span> (ptr[i] != sentinel) {</span>
<span class="line" id="L965">        i += <span class="tok-number">1</span>;</span>
<span class="line" id="L966">    }</span>
<span class="line" id="L967">    <span class="tok-kw">return</span> i;</span>
<span class="line" id="L968">}</span>
<span class="line" id="L969"></span>
<span class="line" id="L970"><span class="tok-comment">/// Returns true if all elements in a slice are equal to the scalar value provided</span></span>
<span class="line" id="L971"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">allEqual</span>(<span class="tok-kw">comptime</span> T: <span class="tok-type">type</span>, slice: []<span class="tok-kw">const</span> T, scalar: T) <span class="tok-type">bool</span> {</span>
<span class="line" id="L972">    <span class="tok-kw">for</span> (slice) |item| {</span>
<span class="line" id="L973">        <span class="tok-kw">if</span> (item != scalar) <span class="tok-kw">return</span> <span class="tok-null">false</span>;</span>
<span class="line" id="L974">    }</span>
<span class="line" id="L975">    <span class="tok-kw">return</span> <span class="tok-null">true</span>;</span>
<span class="line" id="L976">}</span>
<span class="line" id="L977"></span>
<span class="line" id="L978"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> dupe = <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;deprecated; use `Allocator.dupe`&quot;</span>);</span>
<span class="line" id="L979"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> dupeZ = <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;deprecated; use `Allocator.dupeZ`&quot;</span>);</span>
<span class="line" id="L980"></span>
<span class="line" id="L981"><span class="tok-comment">/// Remove values from the beginning of a slice.</span></span>
<span class="line" id="L982"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">trimLeft</span>(<span class="tok-kw">comptime</span> T: <span class="tok-type">type</span>, slice: []<span class="tok-kw">const</span> T, values_to_strip: []<span class="tok-kw">const</span> T) []<span class="tok-kw">const</span> T {</span>
<span class="line" id="L983">    <span class="tok-kw">var</span> begin: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L984">    <span class="tok-kw">while</span> (begin &lt; slice.len <span class="tok-kw">and</span> indexOfScalar(T, values_to_strip, slice[begin]) != <span class="tok-null">null</span>) : (begin += <span class="tok-number">1</span>) {}</span>
<span class="line" id="L985">    <span class="tok-kw">return</span> slice[begin..];</span>
<span class="line" id="L986">}</span>
<span class="line" id="L987"></span>
<span class="line" id="L988"><span class="tok-comment">/// Remove values from the end of a slice.</span></span>
<span class="line" id="L989"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">trimRight</span>(<span class="tok-kw">comptime</span> T: <span class="tok-type">type</span>, slice: []<span class="tok-kw">const</span> T, values_to_strip: []<span class="tok-kw">const</span> T) []<span class="tok-kw">const</span> T {</span>
<span class="line" id="L990">    <span class="tok-kw">var</span> end: <span class="tok-type">usize</span> = slice.len;</span>
<span class="line" id="L991">    <span class="tok-kw">while</span> (end &gt; <span class="tok-number">0</span> <span class="tok-kw">and</span> indexOfScalar(T, values_to_strip, slice[end - <span class="tok-number">1</span>]) != <span class="tok-null">null</span>) : (end -= <span class="tok-number">1</span>) {}</span>
<span class="line" id="L992">    <span class="tok-kw">return</span> slice[<span class="tok-number">0</span>..end];</span>
<span class="line" id="L993">}</span>
<span class="line" id="L994"></span>
<span class="line" id="L995"><span class="tok-comment">/// Remove values from the beginning and end of a slice.</span></span>
<span class="line" id="L996"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">trim</span>(<span class="tok-kw">comptime</span> T: <span class="tok-type">type</span>, slice: []<span class="tok-kw">const</span> T, values_to_strip: []<span class="tok-kw">const</span> T) []<span class="tok-kw">const</span> T {</span>
<span class="line" id="L997">    <span class="tok-kw">var</span> begin: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L998">    <span class="tok-kw">var</span> end: <span class="tok-type">usize</span> = slice.len;</span>
<span class="line" id="L999">    <span class="tok-kw">while</span> (begin &lt; end <span class="tok-kw">and</span> indexOfScalar(T, values_to_strip, slice[begin]) != <span class="tok-null">null</span>) : (begin += <span class="tok-number">1</span>) {}</span>
<span class="line" id="L1000">    <span class="tok-kw">while</span> (end &gt; begin <span class="tok-kw">and</span> indexOfScalar(T, values_to_strip, slice[end - <span class="tok-number">1</span>]) != <span class="tok-null">null</span>) : (end -= <span class="tok-number">1</span>) {}</span>
<span class="line" id="L1001">    <span class="tok-kw">return</span> slice[begin..end];</span>
<span class="line" id="L1002">}</span>
<span class="line" id="L1003"></span>
<span class="line" id="L1004"><span class="tok-kw">test</span> <span class="tok-str">&quot;trim&quot;</span> {</span>
<span class="line" id="L1005">    <span class="tok-kw">try</span> testing.expectEqualSlices(<span class="tok-type">u8</span>, <span class="tok-str">&quot;foo\n &quot;</span>, trimLeft(<span class="tok-type">u8</span>, <span class="tok-str">&quot; foo\n &quot;</span>, <span class="tok-str">&quot; \n&quot;</span>));</span>
<span class="line" id="L1006">    <span class="tok-kw">try</span> testing.expectEqualSlices(<span class="tok-type">u8</span>, <span class="tok-str">&quot; foo&quot;</span>, trimRight(<span class="tok-type">u8</span>, <span class="tok-str">&quot; foo\n &quot;</span>, <span class="tok-str">&quot; \n&quot;</span>));</span>
<span class="line" id="L1007">    <span class="tok-kw">try</span> testing.expectEqualSlices(<span class="tok-type">u8</span>, <span class="tok-str">&quot;foo&quot;</span>, trim(<span class="tok-type">u8</span>, <span class="tok-str">&quot; foo\n &quot;</span>, <span class="tok-str">&quot; \n&quot;</span>));</span>
<span class="line" id="L1008">    <span class="tok-kw">try</span> testing.expectEqualSlices(<span class="tok-type">u8</span>, <span class="tok-str">&quot;foo&quot;</span>, trim(<span class="tok-type">u8</span>, <span class="tok-str">&quot;foo&quot;</span>, <span class="tok-str">&quot; \n&quot;</span>));</span>
<span class="line" id="L1009">}</span>
<span class="line" id="L1010"></span>
<span class="line" id="L1011"><span class="tok-comment">/// Linear search for the index of a scalar value inside a slice.</span></span>
<span class="line" id="L1012"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">indexOfScalar</span>(<span class="tok-kw">comptime</span> T: <span class="tok-type">type</span>, slice: []<span class="tok-kw">const</span> T, value: T) ?<span class="tok-type">usize</span> {</span>
<span class="line" id="L1013">    <span class="tok-kw">return</span> indexOfScalarPos(T, slice, <span class="tok-number">0</span>, value);</span>
<span class="line" id="L1014">}</span>
<span class="line" id="L1015"></span>
<span class="line" id="L1016"><span class="tok-comment">/// Linear search for the last index of a scalar value inside a slice.</span></span>
<span class="line" id="L1017"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">lastIndexOfScalar</span>(<span class="tok-kw">comptime</span> T: <span class="tok-type">type</span>, slice: []<span class="tok-kw">const</span> T, value: T) ?<span class="tok-type">usize</span> {</span>
<span class="line" id="L1018">    <span class="tok-kw">var</span> i: <span class="tok-type">usize</span> = slice.len;</span>
<span class="line" id="L1019">    <span class="tok-kw">while</span> (i != <span class="tok-number">0</span>) {</span>
<span class="line" id="L1020">        i -= <span class="tok-number">1</span>;</span>
<span class="line" id="L1021">        <span class="tok-kw">if</span> (slice[i] == value) <span class="tok-kw">return</span> i;</span>
<span class="line" id="L1022">    }</span>
<span class="line" id="L1023">    <span class="tok-kw">return</span> <span class="tok-null">null</span>;</span>
<span class="line" id="L1024">}</span>
<span class="line" id="L1025"></span>
<span class="line" id="L1026"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">indexOfScalarPos</span>(<span class="tok-kw">comptime</span> T: <span class="tok-type">type</span>, slice: []<span class="tok-kw">const</span> T, start_index: <span class="tok-type">usize</span>, value: T) ?<span class="tok-type">usize</span> {</span>
<span class="line" id="L1027">    <span class="tok-kw">var</span> i: <span class="tok-type">usize</span> = start_index;</span>
<span class="line" id="L1028">    <span class="tok-kw">while</span> (i &lt; slice.len) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L1029">        <span class="tok-kw">if</span> (slice[i] == value) <span class="tok-kw">return</span> i;</span>
<span class="line" id="L1030">    }</span>
<span class="line" id="L1031">    <span class="tok-kw">return</span> <span class="tok-null">null</span>;</span>
<span class="line" id="L1032">}</span>
<span class="line" id="L1033"></span>
<span class="line" id="L1034"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">indexOfAny</span>(<span class="tok-kw">comptime</span> T: <span class="tok-type">type</span>, slice: []<span class="tok-kw">const</span> T, values: []<span class="tok-kw">const</span> T) ?<span class="tok-type">usize</span> {</span>
<span class="line" id="L1035">    <span class="tok-kw">return</span> indexOfAnyPos(T, slice, <span class="tok-number">0</span>, values);</span>
<span class="line" id="L1036">}</span>
<span class="line" id="L1037"></span>
<span class="line" id="L1038"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">lastIndexOfAny</span>(<span class="tok-kw">comptime</span> T: <span class="tok-type">type</span>, slice: []<span class="tok-kw">const</span> T, values: []<span class="tok-kw">const</span> T) ?<span class="tok-type">usize</span> {</span>
<span class="line" id="L1039">    <span class="tok-kw">var</span> i: <span class="tok-type">usize</span> = slice.len;</span>
<span class="line" id="L1040">    <span class="tok-kw">while</span> (i != <span class="tok-number">0</span>) {</span>
<span class="line" id="L1041">        i -= <span class="tok-number">1</span>;</span>
<span class="line" id="L1042">        <span class="tok-kw">for</span> (values) |value| {</span>
<span class="line" id="L1043">            <span class="tok-kw">if</span> (slice[i] == value) <span class="tok-kw">return</span> i;</span>
<span class="line" id="L1044">        }</span>
<span class="line" id="L1045">    }</span>
<span class="line" id="L1046">    <span class="tok-kw">return</span> <span class="tok-null">null</span>;</span>
<span class="line" id="L1047">}</span>
<span class="line" id="L1048"></span>
<span class="line" id="L1049"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">indexOfAnyPos</span>(<span class="tok-kw">comptime</span> T: <span class="tok-type">type</span>, slice: []<span class="tok-kw">const</span> T, start_index: <span class="tok-type">usize</span>, values: []<span class="tok-kw">const</span> T) ?<span class="tok-type">usize</span> {</span>
<span class="line" id="L1050">    <span class="tok-kw">var</span> i: <span class="tok-type">usize</span> = start_index;</span>
<span class="line" id="L1051">    <span class="tok-kw">while</span> (i &lt; slice.len) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L1052">        <span class="tok-kw">for</span> (values) |value| {</span>
<span class="line" id="L1053">            <span class="tok-kw">if</span> (slice[i] == value) <span class="tok-kw">return</span> i;</span>
<span class="line" id="L1054">        }</span>
<span class="line" id="L1055">    }</span>
<span class="line" id="L1056">    <span class="tok-kw">return</span> <span class="tok-null">null</span>;</span>
<span class="line" id="L1057">}</span>
<span class="line" id="L1058"></span>
<span class="line" id="L1059"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">indexOf</span>(<span class="tok-kw">comptime</span> T: <span class="tok-type">type</span>, haystack: []<span class="tok-kw">const</span> T, needle: []<span class="tok-kw">const</span> T) ?<span class="tok-type">usize</span> {</span>
<span class="line" id="L1060">    <span class="tok-kw">return</span> indexOfPos(T, haystack, <span class="tok-number">0</span>, needle);</span>
<span class="line" id="L1061">}</span>
<span class="line" id="L1062"></span>
<span class="line" id="L1063"><span class="tok-comment">/// Find the index in a slice of a sub-slice, searching from the end backwards.</span></span>
<span class="line" id="L1064"><span class="tok-comment">/// To start looking at a different index, slice the haystack first.</span></span>
<span class="line" id="L1065"><span class="tok-comment">/// Consider using `lastIndexOf` instead of this, which will automatically use a</span></span>
<span class="line" id="L1066"><span class="tok-comment">/// more sophisticated algorithm on larger inputs.</span></span>
<span class="line" id="L1067"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">lastIndexOfLinear</span>(<span class="tok-kw">comptime</span> T: <span class="tok-type">type</span>, haystack: []<span class="tok-kw">const</span> T, needle: []<span class="tok-kw">const</span> T) ?<span class="tok-type">usize</span> {</span>
<span class="line" id="L1068">    <span class="tok-kw">var</span> i: <span class="tok-type">usize</span> = haystack.len - needle.len;</span>
<span class="line" id="L1069">    <span class="tok-kw">while</span> (<span class="tok-null">true</span>) : (i -= <span class="tok-number">1</span>) {</span>
<span class="line" id="L1070">        <span class="tok-kw">if</span> (mem.eql(T, haystack[i .. i + needle.len], needle)) <span class="tok-kw">return</span> i;</span>
<span class="line" id="L1071">        <span class="tok-kw">if</span> (i == <span class="tok-number">0</span>) <span class="tok-kw">return</span> <span class="tok-null">null</span>;</span>
<span class="line" id="L1072">    }</span>
<span class="line" id="L1073">}</span>
<span class="line" id="L1074"></span>
<span class="line" id="L1075"><span class="tok-comment">/// Consider using `indexOfPos` instead of this, which will automatically use a</span></span>
<span class="line" id="L1076"><span class="tok-comment">/// more sophisticated algorithm on larger inputs.</span></span>
<span class="line" id="L1077"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">indexOfPosLinear</span>(<span class="tok-kw">comptime</span> T: <span class="tok-type">type</span>, haystack: []<span class="tok-kw">const</span> T, start_index: <span class="tok-type">usize</span>, needle: []<span class="tok-kw">const</span> T) ?<span class="tok-type">usize</span> {</span>
<span class="line" id="L1078">    <span class="tok-kw">var</span> i: <span class="tok-type">usize</span> = start_index;</span>
<span class="line" id="L1079">    <span class="tok-kw">const</span> end = haystack.len - needle.len;</span>
<span class="line" id="L1080">    <span class="tok-kw">while</span> (i &lt;= end) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L1081">        <span class="tok-kw">if</span> (eql(T, haystack[i .. i + needle.len], needle)) <span class="tok-kw">return</span> i;</span>
<span class="line" id="L1082">    }</span>
<span class="line" id="L1083">    <span class="tok-kw">return</span> <span class="tok-null">null</span>;</span>
<span class="line" id="L1084">}</span>
<span class="line" id="L1085"></span>
<span class="line" id="L1086"><span class="tok-kw">fn</span> <span class="tok-fn">boyerMooreHorspoolPreprocessReverse</span>(pattern: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, table: *[<span class="tok-number">256</span>]<span class="tok-type">usize</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L1087">    <span class="tok-kw">for</span> (table) |*c| {</span>
<span class="line" id="L1088">        c.* = pattern.len;</span>
<span class="line" id="L1089">    }</span>
<span class="line" id="L1090"></span>
<span class="line" id="L1091">    <span class="tok-kw">var</span> i: <span class="tok-type">usize</span> = pattern.len - <span class="tok-number">1</span>;</span>
<span class="line" id="L1092">    <span class="tok-comment">// The first item is intentionally ignored and the skip size will be pattern.len.</span>
</span>
<span class="line" id="L1093">    <span class="tok-comment">// This is the standard way boyer-moore-horspool is implemented.</span>
</span>
<span class="line" id="L1094">    <span class="tok-kw">while</span> (i &gt; <span class="tok-number">0</span>) : (i -= <span class="tok-number">1</span>) {</span>
<span class="line" id="L1095">        table[pattern[i]] = i;</span>
<span class="line" id="L1096">    }</span>
<span class="line" id="L1097">}</span>
<span class="line" id="L1098"></span>
<span class="line" id="L1099"><span class="tok-kw">fn</span> <span class="tok-fn">boyerMooreHorspoolPreprocess</span>(pattern: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, table: *[<span class="tok-number">256</span>]<span class="tok-type">usize</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L1100">    <span class="tok-kw">for</span> (table) |*c| {</span>
<span class="line" id="L1101">        c.* = pattern.len;</span>
<span class="line" id="L1102">    }</span>
<span class="line" id="L1103"></span>
<span class="line" id="L1104">    <span class="tok-kw">var</span> i: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L1105">    <span class="tok-comment">// The last item is intentionally ignored and the skip size will be pattern.len.</span>
</span>
<span class="line" id="L1106">    <span class="tok-comment">// This is the standard way boyer-moore-horspool is implemented.</span>
</span>
<span class="line" id="L1107">    <span class="tok-kw">while</span> (i &lt; pattern.len - <span class="tok-number">1</span>) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L1108">        table[pattern[i]] = pattern.len - <span class="tok-number">1</span> - i;</span>
<span class="line" id="L1109">    }</span>
<span class="line" id="L1110">}</span>
<span class="line" id="L1111"><span class="tok-comment">/// Find the index in a slice of a sub-slice, searching from the end backwards.</span></span>
<span class="line" id="L1112"><span class="tok-comment">/// To start looking at a different index, slice the haystack first.</span></span>
<span class="line" id="L1113"><span class="tok-comment">/// Uses the Reverse boyer-moore-horspool algorithm on large inputs;</span></span>
<span class="line" id="L1114"><span class="tok-comment">/// `lastIndexOfLinear` on small inputs.</span></span>
<span class="line" id="L1115"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">lastIndexOf</span>(<span class="tok-kw">comptime</span> T: <span class="tok-type">type</span>, haystack: []<span class="tok-kw">const</span> T, needle: []<span class="tok-kw">const</span> T) ?<span class="tok-type">usize</span> {</span>
<span class="line" id="L1116">    <span class="tok-kw">if</span> (needle.len &gt; haystack.len) <span class="tok-kw">return</span> <span class="tok-null">null</span>;</span>
<span class="line" id="L1117">    <span class="tok-kw">if</span> (needle.len == <span class="tok-number">0</span>) <span class="tok-kw">return</span> haystack.len;</span>
<span class="line" id="L1118"></span>
<span class="line" id="L1119">    <span class="tok-kw">if</span> (!meta.trait.hasUniqueRepresentation(T) <span class="tok-kw">or</span> haystack.len &lt; <span class="tok-number">52</span> <span class="tok-kw">or</span> needle.len &lt;= <span class="tok-number">4</span>)</span>
<span class="line" id="L1120">        <span class="tok-kw">return</span> lastIndexOfLinear(T, haystack, needle);</span>
<span class="line" id="L1121"></span>
<span class="line" id="L1122">    <span class="tok-kw">const</span> haystack_bytes = sliceAsBytes(haystack);</span>
<span class="line" id="L1123">    <span class="tok-kw">const</span> needle_bytes = sliceAsBytes(needle);</span>
<span class="line" id="L1124"></span>
<span class="line" id="L1125">    <span class="tok-kw">var</span> skip_table: [<span class="tok-number">256</span>]<span class="tok-type">usize</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L1126">    boyerMooreHorspoolPreprocessReverse(needle_bytes, skip_table[<span class="tok-number">0</span>..]);</span>
<span class="line" id="L1127"></span>
<span class="line" id="L1128">    <span class="tok-kw">var</span> i: <span class="tok-type">usize</span> = haystack_bytes.len - needle_bytes.len;</span>
<span class="line" id="L1129">    <span class="tok-kw">while</span> (<span class="tok-null">true</span>) {</span>
<span class="line" id="L1130">        <span class="tok-kw">if</span> (i % <span class="tok-builtin">@sizeOf</span>(T) == <span class="tok-number">0</span> <span class="tok-kw">and</span> mem.eql(<span class="tok-type">u8</span>, haystack_bytes[i .. i + needle_bytes.len], needle_bytes)) {</span>
<span class="line" id="L1131">            <span class="tok-kw">return</span> <span class="tok-builtin">@divExact</span>(i, <span class="tok-builtin">@sizeOf</span>(T));</span>
<span class="line" id="L1132">        }</span>
<span class="line" id="L1133">        <span class="tok-kw">const</span> skip = skip_table[haystack_bytes[i]];</span>
<span class="line" id="L1134">        <span class="tok-kw">if</span> (skip &gt; i) <span class="tok-kw">break</span>;</span>
<span class="line" id="L1135">        i -= skip;</span>
<span class="line" id="L1136">    }</span>
<span class="line" id="L1137"></span>
<span class="line" id="L1138">    <span class="tok-kw">return</span> <span class="tok-null">null</span>;</span>
<span class="line" id="L1139">}</span>
<span class="line" id="L1140"></span>
<span class="line" id="L1141"><span class="tok-comment">/// Uses Boyer-moore-horspool algorithm on large inputs; `indexOfPosLinear` on small inputs.</span></span>
<span class="line" id="L1142"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">indexOfPos</span>(<span class="tok-kw">comptime</span> T: <span class="tok-type">type</span>, haystack: []<span class="tok-kw">const</span> T, start_index: <span class="tok-type">usize</span>, needle: []<span class="tok-kw">const</span> T) ?<span class="tok-type">usize</span> {</span>
<span class="line" id="L1143">    <span class="tok-kw">if</span> (needle.len &gt; haystack.len) <span class="tok-kw">return</span> <span class="tok-null">null</span>;</span>
<span class="line" id="L1144">    <span class="tok-kw">if</span> (needle.len == <span class="tok-number">0</span>) <span class="tok-kw">return</span> start_index;</span>
<span class="line" id="L1145"></span>
<span class="line" id="L1146">    <span class="tok-kw">if</span> (!meta.trait.hasUniqueRepresentation(T) <span class="tok-kw">or</span> haystack.len &lt; <span class="tok-number">52</span> <span class="tok-kw">or</span> needle.len &lt;= <span class="tok-number">4</span>)</span>
<span class="line" id="L1147">        <span class="tok-kw">return</span> indexOfPosLinear(T, haystack, start_index, needle);</span>
<span class="line" id="L1148"></span>
<span class="line" id="L1149">    <span class="tok-kw">const</span> haystack_bytes = sliceAsBytes(haystack);</span>
<span class="line" id="L1150">    <span class="tok-kw">const</span> needle_bytes = sliceAsBytes(needle);</span>
<span class="line" id="L1151"></span>
<span class="line" id="L1152">    <span class="tok-kw">var</span> skip_table: [<span class="tok-number">256</span>]<span class="tok-type">usize</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L1153">    boyerMooreHorspoolPreprocess(needle_bytes, skip_table[<span class="tok-number">0</span>..]);</span>
<span class="line" id="L1154"></span>
<span class="line" id="L1155">    <span class="tok-kw">var</span> i: <span class="tok-type">usize</span> = start_index * <span class="tok-builtin">@sizeOf</span>(T);</span>
<span class="line" id="L1156">    <span class="tok-kw">while</span> (i &lt;= haystack_bytes.len - needle_bytes.len) {</span>
<span class="line" id="L1157">        <span class="tok-kw">if</span> (i % <span class="tok-builtin">@sizeOf</span>(T) == <span class="tok-number">0</span> <span class="tok-kw">and</span> mem.eql(<span class="tok-type">u8</span>, haystack_bytes[i .. i + needle_bytes.len], needle_bytes)) {</span>
<span class="line" id="L1158">            <span class="tok-kw">return</span> <span class="tok-builtin">@divExact</span>(i, <span class="tok-builtin">@sizeOf</span>(T));</span>
<span class="line" id="L1159">        }</span>
<span class="line" id="L1160">        i += skip_table[haystack_bytes[i + needle_bytes.len - <span class="tok-number">1</span>]];</span>
<span class="line" id="L1161">    }</span>
<span class="line" id="L1162"></span>
<span class="line" id="L1163">    <span class="tok-kw">return</span> <span class="tok-null">null</span>;</span>
<span class="line" id="L1164">}</span>
<span class="line" id="L1165"></span>
<span class="line" id="L1166"><span class="tok-kw">test</span> <span class="tok-str">&quot;indexOf&quot;</span> {</span>
<span class="line" id="L1167">    <span class="tok-kw">try</span> testing.expect(indexOf(<span class="tok-type">u8</span>, <span class="tok-str">&quot;one two three four five six seven eight nine ten eleven&quot;</span>, <span class="tok-str">&quot;three four&quot;</span>).? == <span class="tok-number">8</span>);</span>
<span class="line" id="L1168">    <span class="tok-kw">try</span> testing.expect(lastIndexOf(<span class="tok-type">u8</span>, <span class="tok-str">&quot;one two three four five six seven eight nine ten eleven&quot;</span>, <span class="tok-str">&quot;three four&quot;</span>).? == <span class="tok-number">8</span>);</span>
<span class="line" id="L1169">    <span class="tok-kw">try</span> testing.expect(indexOf(<span class="tok-type">u8</span>, <span class="tok-str">&quot;one two three four five six seven eight nine ten eleven&quot;</span>, <span class="tok-str">&quot;two two&quot;</span>) == <span class="tok-null">null</span>);</span>
<span class="line" id="L1170">    <span class="tok-kw">try</span> testing.expect(lastIndexOf(<span class="tok-type">u8</span>, <span class="tok-str">&quot;one two three four five six seven eight nine ten eleven&quot;</span>, <span class="tok-str">&quot;two two&quot;</span>) == <span class="tok-null">null</span>);</span>
<span class="line" id="L1171"></span>
<span class="line" id="L1172">    <span class="tok-kw">try</span> testing.expect(indexOf(<span class="tok-type">u8</span>, <span class="tok-str">&quot;one two three four five six seven eight nine ten&quot;</span>, <span class="tok-str">&quot;&quot;</span>).? == <span class="tok-number">0</span>);</span>
<span class="line" id="L1173">    <span class="tok-kw">try</span> testing.expect(lastIndexOf(<span class="tok-type">u8</span>, <span class="tok-str">&quot;one two three four five six seven eight nine ten&quot;</span>, <span class="tok-str">&quot;&quot;</span>).? == <span class="tok-number">48</span>);</span>
<span class="line" id="L1174"></span>
<span class="line" id="L1175">    <span class="tok-kw">try</span> testing.expect(indexOf(<span class="tok-type">u8</span>, <span class="tok-str">&quot;one two three four&quot;</span>, <span class="tok-str">&quot;four&quot;</span>).? == <span class="tok-number">14</span>);</span>
<span class="line" id="L1176">    <span class="tok-kw">try</span> testing.expect(lastIndexOf(<span class="tok-type">u8</span>, <span class="tok-str">&quot;one two three two four&quot;</span>, <span class="tok-str">&quot;two&quot;</span>).? == <span class="tok-number">14</span>);</span>
<span class="line" id="L1177">    <span class="tok-kw">try</span> testing.expect(indexOf(<span class="tok-type">u8</span>, <span class="tok-str">&quot;one two three four&quot;</span>, <span class="tok-str">&quot;gour&quot;</span>) == <span class="tok-null">null</span>);</span>
<span class="line" id="L1178">    <span class="tok-kw">try</span> testing.expect(lastIndexOf(<span class="tok-type">u8</span>, <span class="tok-str">&quot;one two three four&quot;</span>, <span class="tok-str">&quot;gour&quot;</span>) == <span class="tok-null">null</span>);</span>
<span class="line" id="L1179">    <span class="tok-kw">try</span> testing.expect(indexOf(<span class="tok-type">u8</span>, <span class="tok-str">&quot;foo&quot;</span>, <span class="tok-str">&quot;foo&quot;</span>).? == <span class="tok-number">0</span>);</span>
<span class="line" id="L1180">    <span class="tok-kw">try</span> testing.expect(lastIndexOf(<span class="tok-type">u8</span>, <span class="tok-str">&quot;foo&quot;</span>, <span class="tok-str">&quot;foo&quot;</span>).? == <span class="tok-number">0</span>);</span>
<span class="line" id="L1181">    <span class="tok-kw">try</span> testing.expect(indexOf(<span class="tok-type">u8</span>, <span class="tok-str">&quot;foo&quot;</span>, <span class="tok-str">&quot;fool&quot;</span>) == <span class="tok-null">null</span>);</span>
<span class="line" id="L1182">    <span class="tok-kw">try</span> testing.expect(lastIndexOf(<span class="tok-type">u8</span>, <span class="tok-str">&quot;foo&quot;</span>, <span class="tok-str">&quot;lfoo&quot;</span>) == <span class="tok-null">null</span>);</span>
<span class="line" id="L1183">    <span class="tok-kw">try</span> testing.expect(lastIndexOf(<span class="tok-type">u8</span>, <span class="tok-str">&quot;foo&quot;</span>, <span class="tok-str">&quot;fool&quot;</span>) == <span class="tok-null">null</span>);</span>
<span class="line" id="L1184"></span>
<span class="line" id="L1185">    <span class="tok-kw">try</span> testing.expect(indexOf(<span class="tok-type">u8</span>, <span class="tok-str">&quot;foo foo&quot;</span>, <span class="tok-str">&quot;foo&quot;</span>).? == <span class="tok-number">0</span>);</span>
<span class="line" id="L1186">    <span class="tok-kw">try</span> testing.expect(lastIndexOf(<span class="tok-type">u8</span>, <span class="tok-str">&quot;foo foo&quot;</span>, <span class="tok-str">&quot;foo&quot;</span>).? == <span class="tok-number">4</span>);</span>
<span class="line" id="L1187">    <span class="tok-kw">try</span> testing.expect(lastIndexOfAny(<span class="tok-type">u8</span>, <span class="tok-str">&quot;boo, cat&quot;</span>, <span class="tok-str">&quot;abo&quot;</span>).? == <span class="tok-number">6</span>);</span>
<span class="line" id="L1188">    <span class="tok-kw">try</span> testing.expect(lastIndexOfScalar(<span class="tok-type">u8</span>, <span class="tok-str">&quot;boo&quot;</span>, <span class="tok-str">'o'</span>).? == <span class="tok-number">2</span>);</span>
<span class="line" id="L1189">}</span>
<span class="line" id="L1190"></span>
<span class="line" id="L1191"><span class="tok-kw">test</span> <span class="tok-str">&quot;indexOf multibyte&quot;</span> {</span>
<span class="line" id="L1192">    {</span>
<span class="line" id="L1193">        <span class="tok-comment">// make haystack and needle long enough to trigger boyer-moore-horspool algorithm</span>
</span>
<span class="line" id="L1194">        <span class="tok-kw">const</span> haystack = [<span class="tok-number">1</span>]<span class="tok-type">u16</span>{<span class="tok-number">0</span>} ** <span class="tok-number">100</span> ++ [_]<span class="tok-type">u16</span>{ <span class="tok-number">0xbbaa</span>, <span class="tok-number">0xccbb</span>, <span class="tok-number">0xddcc</span>, <span class="tok-number">0xeedd</span>, <span class="tok-number">0xffee</span>, <span class="tok-number">0x00ff</span> };</span>
<span class="line" id="L1195">        <span class="tok-kw">const</span> needle = [_]<span class="tok-type">u16</span>{ <span class="tok-number">0xbbaa</span>, <span class="tok-number">0xccbb</span>, <span class="tok-number">0xddcc</span>, <span class="tok-number">0xeedd</span>, <span class="tok-number">0xffee</span> };</span>
<span class="line" id="L1196">        <span class="tok-kw">try</span> testing.expectEqual(indexOfPos(<span class="tok-type">u16</span>, &amp;haystack, <span class="tok-number">0</span>, &amp;needle), <span class="tok-number">100</span>);</span>
<span class="line" id="L1197"></span>
<span class="line" id="L1198">        <span class="tok-comment">// check for misaligned false positives (little and big endian)</span>
</span>
<span class="line" id="L1199">        <span class="tok-kw">const</span> needleLE = [_]<span class="tok-type">u16</span>{ <span class="tok-number">0xbbbb</span>, <span class="tok-number">0xcccc</span>, <span class="tok-number">0xdddd</span>, <span class="tok-number">0xeeee</span>, <span class="tok-number">0xffff</span> };</span>
<span class="line" id="L1200">        <span class="tok-kw">try</span> testing.expectEqual(indexOfPos(<span class="tok-type">u16</span>, &amp;haystack, <span class="tok-number">0</span>, &amp;needleLE), <span class="tok-null">null</span>);</span>
<span class="line" id="L1201">        <span class="tok-kw">const</span> needleBE = [_]<span class="tok-type">u16</span>{ <span class="tok-number">0xaacc</span>, <span class="tok-number">0xbbdd</span>, <span class="tok-number">0xccee</span>, <span class="tok-number">0xddff</span>, <span class="tok-number">0xee00</span> };</span>
<span class="line" id="L1202">        <span class="tok-kw">try</span> testing.expectEqual(indexOfPos(<span class="tok-type">u16</span>, &amp;haystack, <span class="tok-number">0</span>, &amp;needleBE), <span class="tok-null">null</span>);</span>
<span class="line" id="L1203">    }</span>
<span class="line" id="L1204"></span>
<span class="line" id="L1205">    {</span>
<span class="line" id="L1206">        <span class="tok-comment">// make haystack and needle long enough to trigger boyer-moore-horspool algorithm</span>
</span>
<span class="line" id="L1207">        <span class="tok-kw">const</span> haystack = [_]<span class="tok-type">u16</span>{ <span class="tok-number">0xbbaa</span>, <span class="tok-number">0xccbb</span>, <span class="tok-number">0xddcc</span>, <span class="tok-number">0xeedd</span>, <span class="tok-number">0xffee</span>, <span class="tok-number">0x00ff</span> } ++ [<span class="tok-number">1</span>]<span class="tok-type">u16</span>{<span class="tok-number">0</span>} ** <span class="tok-number">100</span>;</span>
<span class="line" id="L1208">        <span class="tok-kw">const</span> needle = [_]<span class="tok-type">u16</span>{ <span class="tok-number">0xbbaa</span>, <span class="tok-number">0xccbb</span>, <span class="tok-number">0xddcc</span>, <span class="tok-number">0xeedd</span>, <span class="tok-number">0xffee</span> };</span>
<span class="line" id="L1209">        <span class="tok-kw">try</span> testing.expectEqual(lastIndexOf(<span class="tok-type">u16</span>, &amp;haystack, &amp;needle), <span class="tok-number">0</span>);</span>
<span class="line" id="L1210"></span>
<span class="line" id="L1211">        <span class="tok-comment">// check for misaligned false positives (little and big endian)</span>
</span>
<span class="line" id="L1212">        <span class="tok-kw">const</span> needleLE = [_]<span class="tok-type">u16</span>{ <span class="tok-number">0xbbbb</span>, <span class="tok-number">0xcccc</span>, <span class="tok-number">0xdddd</span>, <span class="tok-number">0xeeee</span>, <span class="tok-number">0xffff</span> };</span>
<span class="line" id="L1213">        <span class="tok-kw">try</span> testing.expectEqual(lastIndexOf(<span class="tok-type">u16</span>, &amp;haystack, &amp;needleLE), <span class="tok-null">null</span>);</span>
<span class="line" id="L1214">        <span class="tok-kw">const</span> needleBE = [_]<span class="tok-type">u16</span>{ <span class="tok-number">0xaacc</span>, <span class="tok-number">0xbbdd</span>, <span class="tok-number">0xccee</span>, <span class="tok-number">0xddff</span>, <span class="tok-number">0xee00</span> };</span>
<span class="line" id="L1215">        <span class="tok-kw">try</span> testing.expectEqual(lastIndexOf(<span class="tok-type">u16</span>, &amp;haystack, &amp;needleBE), <span class="tok-null">null</span>);</span>
<span class="line" id="L1216">    }</span>
<span class="line" id="L1217">}</span>
<span class="line" id="L1218"></span>
<span class="line" id="L1219"><span class="tok-kw">test</span> <span class="tok-str">&quot;indexOfPos empty needle&quot;</span> {</span>
<span class="line" id="L1220">    <span class="tok-kw">try</span> testing.expectEqual(indexOfPos(<span class="tok-type">u8</span>, <span class="tok-str">&quot;abracadabra&quot;</span>, <span class="tok-number">5</span>, <span class="tok-str">&quot;&quot;</span>), <span class="tok-number">5</span>);</span>
<span class="line" id="L1221">}</span>
<span class="line" id="L1222"></span>
<span class="line" id="L1223"><span class="tok-comment">/// Returns the number of needles inside the haystack</span></span>
<span class="line" id="L1224"><span class="tok-comment">/// needle.len must be &gt; 0</span></span>
<span class="line" id="L1225"><span class="tok-comment">/// does not count overlapping needles</span></span>
<span class="line" id="L1226"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">count</span>(<span class="tok-kw">comptime</span> T: <span class="tok-type">type</span>, haystack: []<span class="tok-kw">const</span> T, needle: []<span class="tok-kw">const</span> T) <span class="tok-type">usize</span> {</span>
<span class="line" id="L1227">    assert(needle.len &gt; <span class="tok-number">0</span>);</span>
<span class="line" id="L1228">    <span class="tok-kw">var</span> i: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L1229">    <span class="tok-kw">var</span> found: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L1230"></span>
<span class="line" id="L1231">    <span class="tok-kw">while</span> (indexOfPos(T, haystack, i, needle)) |idx| {</span>
<span class="line" id="L1232">        i = idx + needle.len;</span>
<span class="line" id="L1233">        found += <span class="tok-number">1</span>;</span>
<span class="line" id="L1234">    }</span>
<span class="line" id="L1235"></span>
<span class="line" id="L1236">    <span class="tok-kw">return</span> found;</span>
<span class="line" id="L1237">}</span>
<span class="line" id="L1238"></span>
<span class="line" id="L1239"><span class="tok-kw">test</span> <span class="tok-str">&quot;count&quot;</span> {</span>
<span class="line" id="L1240">    <span class="tok-kw">try</span> testing.expect(count(<span class="tok-type">u8</span>, <span class="tok-str">&quot;&quot;</span>, <span class="tok-str">&quot;h&quot;</span>) == <span class="tok-number">0</span>);</span>
<span class="line" id="L1241">    <span class="tok-kw">try</span> testing.expect(count(<span class="tok-type">u8</span>, <span class="tok-str">&quot;h&quot;</span>, <span class="tok-str">&quot;h&quot;</span>) == <span class="tok-number">1</span>);</span>
<span class="line" id="L1242">    <span class="tok-kw">try</span> testing.expect(count(<span class="tok-type">u8</span>, <span class="tok-str">&quot;hh&quot;</span>, <span class="tok-str">&quot;h&quot;</span>) == <span class="tok-number">2</span>);</span>
<span class="line" id="L1243">    <span class="tok-kw">try</span> testing.expect(count(<span class="tok-type">u8</span>, <span class="tok-str">&quot;world!&quot;</span>, <span class="tok-str">&quot;hello&quot;</span>) == <span class="tok-number">0</span>);</span>
<span class="line" id="L1244">    <span class="tok-kw">try</span> testing.expect(count(<span class="tok-type">u8</span>, <span class="tok-str">&quot;hello world!&quot;</span>, <span class="tok-str">&quot;hello&quot;</span>) == <span class="tok-number">1</span>);</span>
<span class="line" id="L1245">    <span class="tok-kw">try</span> testing.expect(count(<span class="tok-type">u8</span>, <span class="tok-str">&quot;   abcabc   abc&quot;</span>, <span class="tok-str">&quot;abc&quot;</span>) == <span class="tok-number">3</span>);</span>
<span class="line" id="L1246">    <span class="tok-kw">try</span> testing.expect(count(<span class="tok-type">u8</span>, <span class="tok-str">&quot;udexdcbvbruhasdrw&quot;</span>, <span class="tok-str">&quot;bruh&quot;</span>) == <span class="tok-number">1</span>);</span>
<span class="line" id="L1247">    <span class="tok-kw">try</span> testing.expect(count(<span class="tok-type">u8</span>, <span class="tok-str">&quot;foo bar&quot;</span>, <span class="tok-str">&quot;o bar&quot;</span>) == <span class="tok-number">1</span>);</span>
<span class="line" id="L1248">    <span class="tok-kw">try</span> testing.expect(count(<span class="tok-type">u8</span>, <span class="tok-str">&quot;foofoofoo&quot;</span>, <span class="tok-str">&quot;foo&quot;</span>) == <span class="tok-number">3</span>);</span>
<span class="line" id="L1249">    <span class="tok-kw">try</span> testing.expect(count(<span class="tok-type">u8</span>, <span class="tok-str">&quot;fffffff&quot;</span>, <span class="tok-str">&quot;ff&quot;</span>) == <span class="tok-number">3</span>);</span>
<span class="line" id="L1250">    <span class="tok-kw">try</span> testing.expect(count(<span class="tok-type">u8</span>, <span class="tok-str">&quot;owowowu&quot;</span>, <span class="tok-str">&quot;owowu&quot;</span>) == <span class="tok-number">1</span>);</span>
<span class="line" id="L1251">}</span>
<span class="line" id="L1252"></span>
<span class="line" id="L1253"><span class="tok-comment">/// Returns true if the haystack contains expected_count or more needles</span></span>
<span class="line" id="L1254"><span class="tok-comment">/// needle.len must be &gt; 0</span></span>
<span class="line" id="L1255"><span class="tok-comment">/// does not count overlapping needles</span></span>
<span class="line" id="L1256"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">containsAtLeast</span>(<span class="tok-kw">comptime</span> T: <span class="tok-type">type</span>, haystack: []<span class="tok-kw">const</span> T, expected_count: <span class="tok-type">usize</span>, needle: []<span class="tok-kw">const</span> T) <span class="tok-type">bool</span> {</span>
<span class="line" id="L1257">    assert(needle.len &gt; <span class="tok-number">0</span>);</span>
<span class="line" id="L1258">    <span class="tok-kw">if</span> (expected_count == <span class="tok-number">0</span>) <span class="tok-kw">return</span> <span class="tok-null">true</span>;</span>
<span class="line" id="L1259"></span>
<span class="line" id="L1260">    <span class="tok-kw">var</span> i: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L1261">    <span class="tok-kw">var</span> found: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L1262"></span>
<span class="line" id="L1263">    <span class="tok-kw">while</span> (indexOfPos(T, haystack, i, needle)) |idx| {</span>
<span class="line" id="L1264">        i = idx + needle.len;</span>
<span class="line" id="L1265">        found += <span class="tok-number">1</span>;</span>
<span class="line" id="L1266">        <span class="tok-kw">if</span> (found == expected_count) <span class="tok-kw">return</span> <span class="tok-null">true</span>;</span>
<span class="line" id="L1267">    }</span>
<span class="line" id="L1268">    <span class="tok-kw">return</span> <span class="tok-null">false</span>;</span>
<span class="line" id="L1269">}</span>
<span class="line" id="L1270"></span>
<span class="line" id="L1271"><span class="tok-kw">test</span> <span class="tok-str">&quot;containsAtLeast&quot;</span> {</span>
<span class="line" id="L1272">    <span class="tok-kw">try</span> testing.expect(containsAtLeast(<span class="tok-type">u8</span>, <span class="tok-str">&quot;aa&quot;</span>, <span class="tok-number">0</span>, <span class="tok-str">&quot;a&quot;</span>));</span>
<span class="line" id="L1273">    <span class="tok-kw">try</span> testing.expect(containsAtLeast(<span class="tok-type">u8</span>, <span class="tok-str">&quot;aa&quot;</span>, <span class="tok-number">1</span>, <span class="tok-str">&quot;a&quot;</span>));</span>
<span class="line" id="L1274">    <span class="tok-kw">try</span> testing.expect(containsAtLeast(<span class="tok-type">u8</span>, <span class="tok-str">&quot;aa&quot;</span>, <span class="tok-number">2</span>, <span class="tok-str">&quot;a&quot;</span>));</span>
<span class="line" id="L1275">    <span class="tok-kw">try</span> testing.expect(!containsAtLeast(<span class="tok-type">u8</span>, <span class="tok-str">&quot;aa&quot;</span>, <span class="tok-number">3</span>, <span class="tok-str">&quot;a&quot;</span>));</span>
<span class="line" id="L1276"></span>
<span class="line" id="L1277">    <span class="tok-kw">try</span> testing.expect(containsAtLeast(<span class="tok-type">u8</span>, <span class="tok-str">&quot;radaradar&quot;</span>, <span class="tok-number">1</span>, <span class="tok-str">&quot;radar&quot;</span>));</span>
<span class="line" id="L1278">    <span class="tok-kw">try</span> testing.expect(!containsAtLeast(<span class="tok-type">u8</span>, <span class="tok-str">&quot;radaradar&quot;</span>, <span class="tok-number">2</span>, <span class="tok-str">&quot;radar&quot;</span>));</span>
<span class="line" id="L1279"></span>
<span class="line" id="L1280">    <span class="tok-kw">try</span> testing.expect(containsAtLeast(<span class="tok-type">u8</span>, <span class="tok-str">&quot;radarradaradarradar&quot;</span>, <span class="tok-number">3</span>, <span class="tok-str">&quot;radar&quot;</span>));</span>
<span class="line" id="L1281">    <span class="tok-kw">try</span> testing.expect(!containsAtLeast(<span class="tok-type">u8</span>, <span class="tok-str">&quot;radarradaradarradar&quot;</span>, <span class="tok-number">4</span>, <span class="tok-str">&quot;radar&quot;</span>));</span>
<span class="line" id="L1282"></span>
<span class="line" id="L1283">    <span class="tok-kw">try</span> testing.expect(containsAtLeast(<span class="tok-type">u8</span>, <span class="tok-str">&quot;   radar      radar   &quot;</span>, <span class="tok-number">2</span>, <span class="tok-str">&quot;radar&quot;</span>));</span>
<span class="line" id="L1284">    <span class="tok-kw">try</span> testing.expect(!containsAtLeast(<span class="tok-type">u8</span>, <span class="tok-str">&quot;   radar      radar   &quot;</span>, <span class="tok-number">3</span>, <span class="tok-str">&quot;radar&quot;</span>));</span>
<span class="line" id="L1285">}</span>
<span class="line" id="L1286"></span>
<span class="line" id="L1287"><span class="tok-comment">/// Reads an integer from memory with size equal to bytes.len.</span></span>
<span class="line" id="L1288"><span class="tok-comment">/// T specifies the return type, which must be large enough to store</span></span>
<span class="line" id="L1289"><span class="tok-comment">/// the result.</span></span>
<span class="line" id="L1290"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">readVarInt</span>(<span class="tok-kw">comptime</span> ReturnType: <span class="tok-type">type</span>, bytes: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, endian: Endian) ReturnType {</span>
<span class="line" id="L1291">    <span class="tok-kw">var</span> result: ReturnType = <span class="tok-number">0</span>;</span>
<span class="line" id="L1292">    <span class="tok-kw">switch</span> (endian) {</span>
<span class="line" id="L1293">        .Big =&gt; {</span>
<span class="line" id="L1294">            <span class="tok-kw">for</span> (bytes) |b| {</span>
<span class="line" id="L1295">                result = (result &lt;&lt; <span class="tok-number">8</span>) | b;</span>
<span class="line" id="L1296">            }</span>
<span class="line" id="L1297">        },</span>
<span class="line" id="L1298">        .Little =&gt; {</span>
<span class="line" id="L1299">            <span class="tok-kw">const</span> ShiftType = math.Log2Int(ReturnType);</span>
<span class="line" id="L1300">            <span class="tok-kw">for</span> (bytes) |b, index| {</span>
<span class="line" id="L1301">                result = result | (<span class="tok-builtin">@as</span>(ReturnType, b) &lt;&lt; <span class="tok-builtin">@intCast</span>(ShiftType, index * <span class="tok-number">8</span>));</span>
<span class="line" id="L1302">            }</span>
<span class="line" id="L1303">        },</span>
<span class="line" id="L1304">    }</span>
<span class="line" id="L1305">    <span class="tok-kw">return</span> result;</span>
<span class="line" id="L1306">}</span>
<span class="line" id="L1307"></span>
<span class="line" id="L1308"><span class="tok-comment">/// Reads an integer from memory with bit count specified by T.</span></span>
<span class="line" id="L1309"><span class="tok-comment">/// The bit count of T must be evenly divisible by 8.</span></span>
<span class="line" id="L1310"><span class="tok-comment">/// This function cannot fail and cannot cause undefined behavior.</span></span>
<span class="line" id="L1311"><span class="tok-comment">/// Assumes the endianness of memory is native. This means the function can</span></span>
<span class="line" id="L1312"><span class="tok-comment">/// simply pointer cast memory.</span></span>
<span class="line" id="L1313"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">readIntNative</span>(<span class="tok-kw">comptime</span> T: <span class="tok-type">type</span>, bytes: *<span class="tok-kw">const</span> [<span class="tok-builtin">@divExact</span>(<span class="tok-builtin">@typeInfo</span>(T).Int.bits, <span class="tok-number">8</span>)]<span class="tok-type">u8</span>) T {</span>
<span class="line" id="L1314">    <span class="tok-kw">return</span> <span class="tok-builtin">@ptrCast</span>(*<span class="tok-kw">align</span>(<span class="tok-number">1</span>) <span class="tok-kw">const</span> T, bytes).*;</span>
<span class="line" id="L1315">}</span>
<span class="line" id="L1316"></span>
<span class="line" id="L1317"><span class="tok-comment">/// Reads an integer from memory with bit count specified by T.</span></span>
<span class="line" id="L1318"><span class="tok-comment">/// The bit count of T must be evenly divisible by 8.</span></span>
<span class="line" id="L1319"><span class="tok-comment">/// This function cannot fail and cannot cause undefined behavior.</span></span>
<span class="line" id="L1320"><span class="tok-comment">/// Assumes the endianness of memory is foreign, so it must byte-swap.</span></span>
<span class="line" id="L1321"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">readIntForeign</span>(<span class="tok-kw">comptime</span> T: <span class="tok-type">type</span>, bytes: *<span class="tok-kw">const</span> [<span class="tok-builtin">@divExact</span>(<span class="tok-builtin">@typeInfo</span>(T).Int.bits, <span class="tok-number">8</span>)]<span class="tok-type">u8</span>) T {</span>
<span class="line" id="L1322">    <span class="tok-kw">return</span> <span class="tok-builtin">@byteSwap</span>(T, readIntNative(T, bytes));</span>
<span class="line" id="L1323">}</span>
<span class="line" id="L1324"></span>
<span class="line" id="L1325"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> readIntLittle = <span class="tok-kw">switch</span> (native_endian) {</span>
<span class="line" id="L1326">    .Little =&gt; readIntNative,</span>
<span class="line" id="L1327">    .Big =&gt; readIntForeign,</span>
<span class="line" id="L1328">};</span>
<span class="line" id="L1329"></span>
<span class="line" id="L1330"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> readIntBig = <span class="tok-kw">switch</span> (native_endian) {</span>
<span class="line" id="L1331">    .Little =&gt; readIntForeign,</span>
<span class="line" id="L1332">    .Big =&gt; readIntNative,</span>
<span class="line" id="L1333">};</span>
<span class="line" id="L1334"></span>
<span class="line" id="L1335"><span class="tok-comment">/// Asserts that bytes.len &gt;= @typeInfo(T).Int.bits / 8. Reads the integer starting from index 0</span></span>
<span class="line" id="L1336"><span class="tok-comment">/// and ignores extra bytes.</span></span>
<span class="line" id="L1337"><span class="tok-comment">/// The bit count of T must be evenly divisible by 8.</span></span>
<span class="line" id="L1338"><span class="tok-comment">/// Assumes the endianness of memory is native. This means the function can</span></span>
<span class="line" id="L1339"><span class="tok-comment">/// simply pointer cast memory.</span></span>
<span class="line" id="L1340"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">readIntSliceNative</span>(<span class="tok-kw">comptime</span> T: <span class="tok-type">type</span>, bytes: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) T {</span>
<span class="line" id="L1341">    <span class="tok-kw">const</span> n = <span class="tok-builtin">@divExact</span>(<span class="tok-builtin">@typeInfo</span>(T).Int.bits, <span class="tok-number">8</span>);</span>
<span class="line" id="L1342">    assert(bytes.len &gt;= n);</span>
<span class="line" id="L1343">    <span class="tok-kw">return</span> readIntNative(T, bytes[<span class="tok-number">0</span>..n]);</span>
<span class="line" id="L1344">}</span>
<span class="line" id="L1345"></span>
<span class="line" id="L1346"><span class="tok-comment">/// Asserts that bytes.len &gt;= @typeInfo(T).Int.bits / 8. Reads the integer starting from index 0</span></span>
<span class="line" id="L1347"><span class="tok-comment">/// and ignores extra bytes.</span></span>
<span class="line" id="L1348"><span class="tok-comment">/// The bit count of T must be evenly divisible by 8.</span></span>
<span class="line" id="L1349"><span class="tok-comment">/// Assumes the endianness of memory is foreign, so it must byte-swap.</span></span>
<span class="line" id="L1350"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">readIntSliceForeign</span>(<span class="tok-kw">comptime</span> T: <span class="tok-type">type</span>, bytes: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) T {</span>
<span class="line" id="L1351">    <span class="tok-kw">return</span> <span class="tok-builtin">@byteSwap</span>(T, readIntSliceNative(T, bytes));</span>
<span class="line" id="L1352">}</span>
<span class="line" id="L1353"></span>
<span class="line" id="L1354"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> readIntSliceLittle = <span class="tok-kw">switch</span> (native_endian) {</span>
<span class="line" id="L1355">    .Little =&gt; readIntSliceNative,</span>
<span class="line" id="L1356">    .Big =&gt; readIntSliceForeign,</span>
<span class="line" id="L1357">};</span>
<span class="line" id="L1358"></span>
<span class="line" id="L1359"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> readIntSliceBig = <span class="tok-kw">switch</span> (native_endian) {</span>
<span class="line" id="L1360">    .Little =&gt; readIntSliceForeign,</span>
<span class="line" id="L1361">    .Big =&gt; readIntSliceNative,</span>
<span class="line" id="L1362">};</span>
<span class="line" id="L1363"></span>
<span class="line" id="L1364"><span class="tok-comment">/// Reads an integer from memory with bit count specified by T.</span></span>
<span class="line" id="L1365"><span class="tok-comment">/// The bit count of T must be evenly divisible by 8.</span></span>
<span class="line" id="L1366"><span class="tok-comment">/// This function cannot fail and cannot cause undefined behavior.</span></span>
<span class="line" id="L1367"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">readInt</span>(<span class="tok-kw">comptime</span> T: <span class="tok-type">type</span>, bytes: *<span class="tok-kw">const</span> [<span class="tok-builtin">@divExact</span>(<span class="tok-builtin">@typeInfo</span>(T).Int.bits, <span class="tok-number">8</span>)]<span class="tok-type">u8</span>, endian: Endian) T {</span>
<span class="line" id="L1368">    <span class="tok-kw">if</span> (endian == native_endian) {</span>
<span class="line" id="L1369">        <span class="tok-kw">return</span> readIntNative(T, bytes);</span>
<span class="line" id="L1370">    } <span class="tok-kw">else</span> {</span>
<span class="line" id="L1371">        <span class="tok-kw">return</span> readIntForeign(T, bytes);</span>
<span class="line" id="L1372">    }</span>
<span class="line" id="L1373">}</span>
<span class="line" id="L1374"></span>
<span class="line" id="L1375"><span class="tok-comment">/// Asserts that bytes.len &gt;= @typeInfo(T).Int.bits / 8. Reads the integer starting from index 0</span></span>
<span class="line" id="L1376"><span class="tok-comment">/// and ignores extra bytes.</span></span>
<span class="line" id="L1377"><span class="tok-comment">/// The bit count of T must be evenly divisible by 8.</span></span>
<span class="line" id="L1378"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">readIntSlice</span>(<span class="tok-kw">comptime</span> T: <span class="tok-type">type</span>, bytes: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, endian: Endian) T {</span>
<span class="line" id="L1379">    <span class="tok-kw">const</span> n = <span class="tok-builtin">@divExact</span>(<span class="tok-builtin">@typeInfo</span>(T).Int.bits, <span class="tok-number">8</span>);</span>
<span class="line" id="L1380">    assert(bytes.len &gt;= n);</span>
<span class="line" id="L1381">    <span class="tok-kw">return</span> readInt(T, bytes[<span class="tok-number">0</span>..n], endian);</span>
<span class="line" id="L1382">}</span>
<span class="line" id="L1383"></span>
<span class="line" id="L1384"><span class="tok-kw">test</span> <span class="tok-str">&quot;comptime read/write int&quot;</span> {</span>
<span class="line" id="L1385">    <span class="tok-kw">comptime</span> {</span>
<span class="line" id="L1386">        <span class="tok-kw">var</span> bytes: [<span class="tok-number">2</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L1387">        writeIntLittle(<span class="tok-type">u16</span>, &amp;bytes, <span class="tok-number">0x1234</span>);</span>
<span class="line" id="L1388">        <span class="tok-kw">const</span> result = readIntBig(<span class="tok-type">u16</span>, &amp;bytes);</span>
<span class="line" id="L1389">        <span class="tok-kw">try</span> testing.expect(result == <span class="tok-number">0x3412</span>);</span>
<span class="line" id="L1390">    }</span>
<span class="line" id="L1391">    <span class="tok-kw">comptime</span> {</span>
<span class="line" id="L1392">        <span class="tok-kw">var</span> bytes: [<span class="tok-number">2</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L1393">        writeIntBig(<span class="tok-type">u16</span>, &amp;bytes, <span class="tok-number">0x1234</span>);</span>
<span class="line" id="L1394">        <span class="tok-kw">const</span> result = readIntLittle(<span class="tok-type">u16</span>, &amp;bytes);</span>
<span class="line" id="L1395">        <span class="tok-kw">try</span> testing.expect(result == <span class="tok-number">0x3412</span>);</span>
<span class="line" id="L1396">    }</span>
<span class="line" id="L1397">}</span>
<span class="line" id="L1398"></span>
<span class="line" id="L1399"><span class="tok-kw">test</span> <span class="tok-str">&quot;readIntBig and readIntLittle&quot;</span> {</span>
<span class="line" id="L1400">    <span class="tok-kw">try</span> testing.expect(readIntSliceBig(<span class="tok-type">u0</span>, &amp;[_]<span class="tok-type">u8</span>{}) == <span class="tok-number">0x0</span>);</span>
<span class="line" id="L1401">    <span class="tok-kw">try</span> testing.expect(readIntSliceLittle(<span class="tok-type">u0</span>, &amp;[_]<span class="tok-type">u8</span>{}) == <span class="tok-number">0x0</span>);</span>
<span class="line" id="L1402"></span>
<span class="line" id="L1403">    <span class="tok-kw">try</span> testing.expect(readIntSliceBig(<span class="tok-type">u8</span>, &amp;[_]<span class="tok-type">u8</span>{<span class="tok-number">0x32</span>}) == <span class="tok-number">0x32</span>);</span>
<span class="line" id="L1404">    <span class="tok-kw">try</span> testing.expect(readIntSliceLittle(<span class="tok-type">u8</span>, &amp;[_]<span class="tok-type">u8</span>{<span class="tok-number">0x12</span>}) == <span class="tok-number">0x12</span>);</span>
<span class="line" id="L1405"></span>
<span class="line" id="L1406">    <span class="tok-kw">try</span> testing.expect(readIntSliceBig(<span class="tok-type">u16</span>, &amp;[_]<span class="tok-type">u8</span>{ <span class="tok-number">0x12</span>, <span class="tok-number">0x34</span> }) == <span class="tok-number">0x1234</span>);</span>
<span class="line" id="L1407">    <span class="tok-kw">try</span> testing.expect(readIntSliceLittle(<span class="tok-type">u16</span>, &amp;[_]<span class="tok-type">u8</span>{ <span class="tok-number">0x12</span>, <span class="tok-number">0x34</span> }) == <span class="tok-number">0x3412</span>);</span>
<span class="line" id="L1408"></span>
<span class="line" id="L1409">    <span class="tok-kw">try</span> testing.expect(readIntSliceBig(<span class="tok-type">u72</span>, &amp;[_]<span class="tok-type">u8</span>{ <span class="tok-number">0x12</span>, <span class="tok-number">0x34</span>, <span class="tok-number">0x56</span>, <span class="tok-number">0x78</span>, <span class="tok-number">0x9a</span>, <span class="tok-number">0xbc</span>, <span class="tok-number">0xde</span>, <span class="tok-number">0xf0</span>, <span class="tok-number">0x24</span> }) == <span class="tok-number">0x123456789abcdef024</span>);</span>
<span class="line" id="L1410">    <span class="tok-kw">try</span> testing.expect(readIntSliceLittle(<span class="tok-type">u72</span>, &amp;[_]<span class="tok-type">u8</span>{ <span class="tok-number">0xec</span>, <span class="tok-number">0x10</span>, <span class="tok-number">0x32</span>, <span class="tok-number">0x54</span>, <span class="tok-number">0x76</span>, <span class="tok-number">0x98</span>, <span class="tok-number">0xba</span>, <span class="tok-number">0xdc</span>, <span class="tok-number">0xfe</span> }) == <span class="tok-number">0xfedcba9876543210ec</span>);</span>
<span class="line" id="L1411"></span>
<span class="line" id="L1412">    <span class="tok-kw">try</span> testing.expect(readIntSliceBig(<span class="tok-type">i8</span>, &amp;[_]<span class="tok-type">u8</span>{<span class="tok-number">0xff</span>}) == -<span class="tok-number">1</span>);</span>
<span class="line" id="L1413">    <span class="tok-kw">try</span> testing.expect(readIntSliceLittle(<span class="tok-type">i8</span>, &amp;[_]<span class="tok-type">u8</span>{<span class="tok-number">0xfe</span>}) == -<span class="tok-number">2</span>);</span>
<span class="line" id="L1414"></span>
<span class="line" id="L1415">    <span class="tok-kw">try</span> testing.expect(readIntSliceBig(<span class="tok-type">i16</span>, &amp;[_]<span class="tok-type">u8</span>{ <span class="tok-number">0xff</span>, <span class="tok-number">0xfd</span> }) == -<span class="tok-number">3</span>);</span>
<span class="line" id="L1416">    <span class="tok-kw">try</span> testing.expect(readIntSliceLittle(<span class="tok-type">i16</span>, &amp;[_]<span class="tok-type">u8</span>{ <span class="tok-number">0xfc</span>, <span class="tok-number">0xff</span> }) == -<span class="tok-number">4</span>);</span>
<span class="line" id="L1417">}</span>
<span class="line" id="L1418"></span>
<span class="line" id="L1419"><span class="tok-comment">/// Writes an integer to memory, storing it in twos-complement.</span></span>
<span class="line" id="L1420"><span class="tok-comment">/// This function always succeeds, has defined behavior for all inputs, and</span></span>
<span class="line" id="L1421"><span class="tok-comment">/// accepts any integer bit width.</span></span>
<span class="line" id="L1422"><span class="tok-comment">/// This function stores in native endian, which means it is implemented as a simple</span></span>
<span class="line" id="L1423"><span class="tok-comment">/// memory store.</span></span>
<span class="line" id="L1424"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">writeIntNative</span>(<span class="tok-kw">comptime</span> T: <span class="tok-type">type</span>, buf: *[(<span class="tok-builtin">@typeInfo</span>(T).Int.bits + <span class="tok-number">7</span>) / <span class="tok-number">8</span>]<span class="tok-type">u8</span>, value: T) <span class="tok-type">void</span> {</span>
<span class="line" id="L1425">    <span class="tok-builtin">@ptrCast</span>(*<span class="tok-kw">align</span>(<span class="tok-number">1</span>) T, buf).* = value;</span>
<span class="line" id="L1426">}</span>
<span class="line" id="L1427"></span>
<span class="line" id="L1428"><span class="tok-comment">/// Writes an integer to memory, storing it in twos-complement.</span></span>
<span class="line" id="L1429"><span class="tok-comment">/// This function always succeeds, has defined behavior for all inputs, but</span></span>
<span class="line" id="L1430"><span class="tok-comment">/// the integer bit width must be divisible by 8.</span></span>
<span class="line" id="L1431"><span class="tok-comment">/// This function stores in foreign endian, which means it does a @byteSwap first.</span></span>
<span class="line" id="L1432"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">writeIntForeign</span>(<span class="tok-kw">comptime</span> T: <span class="tok-type">type</span>, buf: *[<span class="tok-builtin">@divExact</span>(<span class="tok-builtin">@typeInfo</span>(T).Int.bits, <span class="tok-number">8</span>)]<span class="tok-type">u8</span>, value: T) <span class="tok-type">void</span> {</span>
<span class="line" id="L1433">    writeIntNative(T, buf, <span class="tok-builtin">@byteSwap</span>(T, value));</span>
<span class="line" id="L1434">}</span>
<span class="line" id="L1435"></span>
<span class="line" id="L1436"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> writeIntLittle = <span class="tok-kw">switch</span> (native_endian) {</span>
<span class="line" id="L1437">    .Little =&gt; writeIntNative,</span>
<span class="line" id="L1438">    .Big =&gt; writeIntForeign,</span>
<span class="line" id="L1439">};</span>
<span class="line" id="L1440"></span>
<span class="line" id="L1441"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> writeIntBig = <span class="tok-kw">switch</span> (native_endian) {</span>
<span class="line" id="L1442">    .Little =&gt; writeIntForeign,</span>
<span class="line" id="L1443">    .Big =&gt; writeIntNative,</span>
<span class="line" id="L1444">};</span>
<span class="line" id="L1445"></span>
<span class="line" id="L1446"><span class="tok-comment">/// Writes an integer to memory, storing it in twos-complement.</span></span>
<span class="line" id="L1447"><span class="tok-comment">/// This function always succeeds, has defined behavior for all inputs, but</span></span>
<span class="line" id="L1448"><span class="tok-comment">/// the integer bit width must be divisible by 8.</span></span>
<span class="line" id="L1449"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">writeInt</span>(<span class="tok-kw">comptime</span> T: <span class="tok-type">type</span>, buffer: *[<span class="tok-builtin">@divExact</span>(<span class="tok-builtin">@typeInfo</span>(T).Int.bits, <span class="tok-number">8</span>)]<span class="tok-type">u8</span>, value: T, endian: Endian) <span class="tok-type">void</span> {</span>
<span class="line" id="L1450">    <span class="tok-kw">if</span> (endian == native_endian) {</span>
<span class="line" id="L1451">        <span class="tok-kw">return</span> writeIntNative(T, buffer, value);</span>
<span class="line" id="L1452">    } <span class="tok-kw">else</span> {</span>
<span class="line" id="L1453">        <span class="tok-kw">return</span> writeIntForeign(T, buffer, value);</span>
<span class="line" id="L1454">    }</span>
<span class="line" id="L1455">}</span>
<span class="line" id="L1456"></span>
<span class="line" id="L1457"><span class="tok-comment">/// Writes a twos-complement little-endian integer to memory.</span></span>
<span class="line" id="L1458"><span class="tok-comment">/// Asserts that buf.len &gt;= @typeInfo(T).Int.bits / 8.</span></span>
<span class="line" id="L1459"><span class="tok-comment">/// The bit count of T must be divisible by 8.</span></span>
<span class="line" id="L1460"><span class="tok-comment">/// Any extra bytes in buffer after writing the integer are set to zero. To</span></span>
<span class="line" id="L1461"><span class="tok-comment">/// avoid the branch to check for extra buffer bytes, use writeIntLittle</span></span>
<span class="line" id="L1462"><span class="tok-comment">/// instead.</span></span>
<span class="line" id="L1463"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">writeIntSliceLittle</span>(<span class="tok-kw">comptime</span> T: <span class="tok-type">type</span>, buffer: []<span class="tok-type">u8</span>, value: T) <span class="tok-type">void</span> {</span>
<span class="line" id="L1464">    assert(buffer.len &gt;= <span class="tok-builtin">@divExact</span>(<span class="tok-builtin">@typeInfo</span>(T).Int.bits, <span class="tok-number">8</span>));</span>
<span class="line" id="L1465"></span>
<span class="line" id="L1466">    <span class="tok-kw">if</span> (<span class="tok-builtin">@typeInfo</span>(T).Int.bits == <span class="tok-number">0</span>) {</span>
<span class="line" id="L1467">        <span class="tok-kw">return</span> set(<span class="tok-type">u8</span>, buffer, <span class="tok-number">0</span>);</span>
<span class="line" id="L1468">    } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (<span class="tok-builtin">@typeInfo</span>(T).Int.bits == <span class="tok-number">8</span>) {</span>
<span class="line" id="L1469">        set(<span class="tok-type">u8</span>, buffer, <span class="tok-number">0</span>);</span>
<span class="line" id="L1470">        buffer[<span class="tok-number">0</span>] = <span class="tok-builtin">@bitCast</span>(<span class="tok-type">u8</span>, value);</span>
<span class="line" id="L1471">        <span class="tok-kw">return</span>;</span>
<span class="line" id="L1472">    }</span>
<span class="line" id="L1473">    <span class="tok-comment">// TODO I want to call writeIntLittle here but comptime eval facilities aren't good enough</span>
</span>
<span class="line" id="L1474">    <span class="tok-kw">const</span> uint = std.meta.Int(.unsigned, <span class="tok-builtin">@typeInfo</span>(T).Int.bits);</span>
<span class="line" id="L1475">    <span class="tok-kw">var</span> bits = <span class="tok-builtin">@bitCast</span>(uint, value);</span>
<span class="line" id="L1476">    <span class="tok-kw">for</span> (buffer) |*b| {</span>
<span class="line" id="L1477">        b.* = <span class="tok-builtin">@truncate</span>(<span class="tok-type">u8</span>, bits);</span>
<span class="line" id="L1478">        bits &gt;&gt;= <span class="tok-number">8</span>;</span>
<span class="line" id="L1479">    }</span>
<span class="line" id="L1480">}</span>
<span class="line" id="L1481"></span>
<span class="line" id="L1482"><span class="tok-comment">/// Writes a twos-complement big-endian integer to memory.</span></span>
<span class="line" id="L1483"><span class="tok-comment">/// Asserts that buffer.len &gt;= @typeInfo(T).Int.bits / 8.</span></span>
<span class="line" id="L1484"><span class="tok-comment">/// The bit count of T must be divisible by 8.</span></span>
<span class="line" id="L1485"><span class="tok-comment">/// Any extra bytes in buffer before writing the integer are set to zero. To</span></span>
<span class="line" id="L1486"><span class="tok-comment">/// avoid the branch to check for extra buffer bytes, use writeIntBig instead.</span></span>
<span class="line" id="L1487"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">writeIntSliceBig</span>(<span class="tok-kw">comptime</span> T: <span class="tok-type">type</span>, buffer: []<span class="tok-type">u8</span>, value: T) <span class="tok-type">void</span> {</span>
<span class="line" id="L1488">    assert(buffer.len &gt;= <span class="tok-builtin">@divExact</span>(<span class="tok-builtin">@typeInfo</span>(T).Int.bits, <span class="tok-number">8</span>));</span>
<span class="line" id="L1489"></span>
<span class="line" id="L1490">    <span class="tok-kw">if</span> (<span class="tok-builtin">@typeInfo</span>(T).Int.bits == <span class="tok-number">0</span>) {</span>
<span class="line" id="L1491">        <span class="tok-kw">return</span> set(<span class="tok-type">u8</span>, buffer, <span class="tok-number">0</span>);</span>
<span class="line" id="L1492">    } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (<span class="tok-builtin">@typeInfo</span>(T).Int.bits == <span class="tok-number">8</span>) {</span>
<span class="line" id="L1493">        set(<span class="tok-type">u8</span>, buffer, <span class="tok-number">0</span>);</span>
<span class="line" id="L1494">        buffer[buffer.len - <span class="tok-number">1</span>] = <span class="tok-builtin">@bitCast</span>(<span class="tok-type">u8</span>, value);</span>
<span class="line" id="L1495">        <span class="tok-kw">return</span>;</span>
<span class="line" id="L1496">    }</span>
<span class="line" id="L1497"></span>
<span class="line" id="L1498">    <span class="tok-comment">// TODO I want to call writeIntBig here but comptime eval facilities aren't good enough</span>
</span>
<span class="line" id="L1499">    <span class="tok-kw">const</span> uint = std.meta.Int(.unsigned, <span class="tok-builtin">@typeInfo</span>(T).Int.bits);</span>
<span class="line" id="L1500">    <span class="tok-kw">var</span> bits = <span class="tok-builtin">@bitCast</span>(uint, value);</span>
<span class="line" id="L1501">    <span class="tok-kw">var</span> index: <span class="tok-type">usize</span> = buffer.len;</span>
<span class="line" id="L1502">    <span class="tok-kw">while</span> (index != <span class="tok-number">0</span>) {</span>
<span class="line" id="L1503">        index -= <span class="tok-number">1</span>;</span>
<span class="line" id="L1504">        buffer[index] = <span class="tok-builtin">@truncate</span>(<span class="tok-type">u8</span>, bits);</span>
<span class="line" id="L1505">        bits &gt;&gt;= <span class="tok-number">8</span>;</span>
<span class="line" id="L1506">    }</span>
<span class="line" id="L1507">}</span>
<span class="line" id="L1508"></span>
<span class="line" id="L1509"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> writeIntSliceNative = <span class="tok-kw">switch</span> (native_endian) {</span>
<span class="line" id="L1510">    .Little =&gt; writeIntSliceLittle,</span>
<span class="line" id="L1511">    .Big =&gt; writeIntSliceBig,</span>
<span class="line" id="L1512">};</span>
<span class="line" id="L1513"></span>
<span class="line" id="L1514"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> writeIntSliceForeign = <span class="tok-kw">switch</span> (native_endian) {</span>
<span class="line" id="L1515">    .Little =&gt; writeIntSliceBig,</span>
<span class="line" id="L1516">    .Big =&gt; writeIntSliceLittle,</span>
<span class="line" id="L1517">};</span>
<span class="line" id="L1518"></span>
<span class="line" id="L1519"><span class="tok-comment">/// Writes a twos-complement integer to memory, with the specified endianness.</span></span>
<span class="line" id="L1520"><span class="tok-comment">/// Asserts that buf.len &gt;= @typeInfo(T).Int.bits / 8.</span></span>
<span class="line" id="L1521"><span class="tok-comment">/// The bit count of T must be evenly divisible by 8.</span></span>
<span class="line" id="L1522"><span class="tok-comment">/// Any extra bytes in buffer not part of the integer are set to zero, with</span></span>
<span class="line" id="L1523"><span class="tok-comment">/// respect to endianness. To avoid the branch to check for extra buffer bytes,</span></span>
<span class="line" id="L1524"><span class="tok-comment">/// use writeInt instead.</span></span>
<span class="line" id="L1525"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">writeIntSlice</span>(<span class="tok-kw">comptime</span> T: <span class="tok-type">type</span>, buffer: []<span class="tok-type">u8</span>, value: T, endian: Endian) <span class="tok-type">void</span> {</span>
<span class="line" id="L1526">    <span class="tok-kw">comptime</span> assert(<span class="tok-builtin">@typeInfo</span>(T).Int.bits % <span class="tok-number">8</span> == <span class="tok-number">0</span>);</span>
<span class="line" id="L1527">    <span class="tok-kw">return</span> <span class="tok-kw">switch</span> (endian) {</span>
<span class="line" id="L1528">        .Little =&gt; writeIntSliceLittle(T, buffer, value),</span>
<span class="line" id="L1529">        .Big =&gt; writeIntSliceBig(T, buffer, value),</span>
<span class="line" id="L1530">    };</span>
<span class="line" id="L1531">}</span>
<span class="line" id="L1532"></span>
<span class="line" id="L1533"><span class="tok-kw">test</span> <span class="tok-str">&quot;writeIntBig and writeIntLittle&quot;</span> {</span>
<span class="line" id="L1534">    <span class="tok-kw">var</span> buf0: [<span class="tok-number">0</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L1535">    <span class="tok-kw">var</span> buf1: [<span class="tok-number">1</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L1536">    <span class="tok-kw">var</span> buf2: [<span class="tok-number">2</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L1537">    <span class="tok-kw">var</span> buf9: [<span class="tok-number">9</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L1538"></span>
<span class="line" id="L1539">    writeIntBig(<span class="tok-type">u0</span>, &amp;buf0, <span class="tok-number">0x0</span>);</span>
<span class="line" id="L1540">    <span class="tok-kw">try</span> testing.expect(eql(<span class="tok-type">u8</span>, buf0[<span class="tok-number">0</span>..], &amp;[_]<span class="tok-type">u8</span>{}));</span>
<span class="line" id="L1541">    writeIntLittle(<span class="tok-type">u0</span>, &amp;buf0, <span class="tok-number">0x0</span>);</span>
<span class="line" id="L1542">    <span class="tok-kw">try</span> testing.expect(eql(<span class="tok-type">u8</span>, buf0[<span class="tok-number">0</span>..], &amp;[_]<span class="tok-type">u8</span>{}));</span>
<span class="line" id="L1543"></span>
<span class="line" id="L1544">    writeIntBig(<span class="tok-type">u8</span>, &amp;buf1, <span class="tok-number">0x12</span>);</span>
<span class="line" id="L1545">    <span class="tok-kw">try</span> testing.expect(eql(<span class="tok-type">u8</span>, buf1[<span class="tok-number">0</span>..], &amp;[_]<span class="tok-type">u8</span>{<span class="tok-number">0x12</span>}));</span>
<span class="line" id="L1546">    writeIntLittle(<span class="tok-type">u8</span>, &amp;buf1, <span class="tok-number">0x34</span>);</span>
<span class="line" id="L1547">    <span class="tok-kw">try</span> testing.expect(eql(<span class="tok-type">u8</span>, buf1[<span class="tok-number">0</span>..], &amp;[_]<span class="tok-type">u8</span>{<span class="tok-number">0x34</span>}));</span>
<span class="line" id="L1548"></span>
<span class="line" id="L1549">    writeIntBig(<span class="tok-type">u16</span>, &amp;buf2, <span class="tok-number">0x1234</span>);</span>
<span class="line" id="L1550">    <span class="tok-kw">try</span> testing.expect(eql(<span class="tok-type">u8</span>, buf2[<span class="tok-number">0</span>..], &amp;[_]<span class="tok-type">u8</span>{ <span class="tok-number">0x12</span>, <span class="tok-number">0x34</span> }));</span>
<span class="line" id="L1551">    writeIntLittle(<span class="tok-type">u16</span>, &amp;buf2, <span class="tok-number">0x5678</span>);</span>
<span class="line" id="L1552">    <span class="tok-kw">try</span> testing.expect(eql(<span class="tok-type">u8</span>, buf2[<span class="tok-number">0</span>..], &amp;[_]<span class="tok-type">u8</span>{ <span class="tok-number">0x78</span>, <span class="tok-number">0x56</span> }));</span>
<span class="line" id="L1553"></span>
<span class="line" id="L1554">    writeIntBig(<span class="tok-type">u72</span>, &amp;buf9, <span class="tok-number">0x123456789abcdef024</span>);</span>
<span class="line" id="L1555">    <span class="tok-kw">try</span> testing.expect(eql(<span class="tok-type">u8</span>, buf9[<span class="tok-number">0</span>..], &amp;[_]<span class="tok-type">u8</span>{ <span class="tok-number">0x12</span>, <span class="tok-number">0x34</span>, <span class="tok-number">0x56</span>, <span class="tok-number">0x78</span>, <span class="tok-number">0x9a</span>, <span class="tok-number">0xbc</span>, <span class="tok-number">0xde</span>, <span class="tok-number">0xf0</span>, <span class="tok-number">0x24</span> }));</span>
<span class="line" id="L1556">    writeIntLittle(<span class="tok-type">u72</span>, &amp;buf9, <span class="tok-number">0xfedcba9876543210ec</span>);</span>
<span class="line" id="L1557">    <span class="tok-kw">try</span> testing.expect(eql(<span class="tok-type">u8</span>, buf9[<span class="tok-number">0</span>..], &amp;[_]<span class="tok-type">u8</span>{ <span class="tok-number">0xec</span>, <span class="tok-number">0x10</span>, <span class="tok-number">0x32</span>, <span class="tok-number">0x54</span>, <span class="tok-number">0x76</span>, <span class="tok-number">0x98</span>, <span class="tok-number">0xba</span>, <span class="tok-number">0xdc</span>, <span class="tok-number">0xfe</span> }));</span>
<span class="line" id="L1558"></span>
<span class="line" id="L1559">    writeIntBig(<span class="tok-type">i8</span>, &amp;buf1, -<span class="tok-number">1</span>);</span>
<span class="line" id="L1560">    <span class="tok-kw">try</span> testing.expect(eql(<span class="tok-type">u8</span>, buf1[<span class="tok-number">0</span>..], &amp;[_]<span class="tok-type">u8</span>{<span class="tok-number">0xff</span>}));</span>
<span class="line" id="L1561">    writeIntLittle(<span class="tok-type">i8</span>, &amp;buf1, -<span class="tok-number">2</span>);</span>
<span class="line" id="L1562">    <span class="tok-kw">try</span> testing.expect(eql(<span class="tok-type">u8</span>, buf1[<span class="tok-number">0</span>..], &amp;[_]<span class="tok-type">u8</span>{<span class="tok-number">0xfe</span>}));</span>
<span class="line" id="L1563"></span>
<span class="line" id="L1564">    writeIntBig(<span class="tok-type">i16</span>, &amp;buf2, -<span class="tok-number">3</span>);</span>
<span class="line" id="L1565">    <span class="tok-kw">try</span> testing.expect(eql(<span class="tok-type">u8</span>, buf2[<span class="tok-number">0</span>..], &amp;[_]<span class="tok-type">u8</span>{ <span class="tok-number">0xff</span>, <span class="tok-number">0xfd</span> }));</span>
<span class="line" id="L1566">    writeIntLittle(<span class="tok-type">i16</span>, &amp;buf2, -<span class="tok-number">4</span>);</span>
<span class="line" id="L1567">    <span class="tok-kw">try</span> testing.expect(eql(<span class="tok-type">u8</span>, buf2[<span class="tok-number">0</span>..], &amp;[_]<span class="tok-type">u8</span>{ <span class="tok-number">0xfc</span>, <span class="tok-number">0xff</span> }));</span>
<span class="line" id="L1568">}</span>
<span class="line" id="L1569"></span>
<span class="line" id="L1570"><span class="tok-comment">/// TODO delete this deprecated declaration after 0.10.0 is released</span></span>
<span class="line" id="L1571"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> bswapAllFields = <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;bswapAllFields has been renamed to byteSwapAllFields&quot;</span>);</span>
<span class="line" id="L1572"></span>
<span class="line" id="L1573"><span class="tok-comment">/// Swap the byte order of all the members of the fields of a struct</span></span>
<span class="line" id="L1574"><span class="tok-comment">/// (Changing their endianess)</span></span>
<span class="line" id="L1575"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">byteSwapAllFields</span>(<span class="tok-kw">comptime</span> S: <span class="tok-type">type</span>, ptr: *S) <span class="tok-type">void</span> {</span>
<span class="line" id="L1576">    <span class="tok-kw">if</span> (<span class="tok-builtin">@typeInfo</span>(S) != .Struct) <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;byteSwapAllFields expects a struct as the first argument&quot;</span>);</span>
<span class="line" id="L1577">    <span class="tok-kw">inline</span> <span class="tok-kw">for</span> (std.meta.fields(S)) |f| {</span>
<span class="line" id="L1578">        <span class="tok-builtin">@field</span>(ptr, f.name) = <span class="tok-builtin">@byteSwap</span>(f.field_type, <span class="tok-builtin">@field</span>(ptr, f.name));</span>
<span class="line" id="L1579">    }</span>
<span class="line" id="L1580">}</span>
<span class="line" id="L1581"></span>
<span class="line" id="L1582"><span class="tok-kw">test</span> <span class="tok-str">&quot;byteSwapAllFields&quot;</span> {</span>
<span class="line" id="L1583">    <span class="tok-kw">const</span> T = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L1584">        f0: <span class="tok-type">u8</span>,</span>
<span class="line" id="L1585">        f1: <span class="tok-type">u16</span>,</span>
<span class="line" id="L1586">        f2: <span class="tok-type">u32</span>,</span>
<span class="line" id="L1587">    };</span>
<span class="line" id="L1588">    <span class="tok-kw">var</span> s = T{</span>
<span class="line" id="L1589">        .f0 = <span class="tok-number">0x12</span>,</span>
<span class="line" id="L1590">        .f1 = <span class="tok-number">0x1234</span>,</span>
<span class="line" id="L1591">        .f2 = <span class="tok-number">0x12345678</span>,</span>
<span class="line" id="L1592">    };</span>
<span class="line" id="L1593">    byteSwapAllFields(T, &amp;s);</span>
<span class="line" id="L1594">    <span class="tok-kw">try</span> std.testing.expectEqual(T{</span>
<span class="line" id="L1595">        .f0 = <span class="tok-number">0x12</span>,</span>
<span class="line" id="L1596">        .f1 = <span class="tok-number">0x3412</span>,</span>
<span class="line" id="L1597">        .f2 = <span class="tok-number">0x78563412</span>,</span>
<span class="line" id="L1598">    }, s);</span>
<span class="line" id="L1599">}</span>
<span class="line" id="L1600"></span>
<span class="line" id="L1601"><span class="tok-comment">/// Returns an iterator that iterates over the slices of `buffer` that are not</span></span>
<span class="line" id="L1602"><span class="tok-comment">/// any of the bytes in `delimiter_bytes`.</span></span>
<span class="line" id="L1603"><span class="tok-comment">///</span></span>
<span class="line" id="L1604"><span class="tok-comment">/// `tokenize(u8, &quot;   abc def    ghi  &quot;, &quot; &quot;)` will return slices</span></span>
<span class="line" id="L1605"><span class="tok-comment">/// for &quot;abc&quot;, &quot;def&quot;, &quot;ghi&quot;, null, in that order.</span></span>
<span class="line" id="L1606"><span class="tok-comment">///</span></span>
<span class="line" id="L1607"><span class="tok-comment">/// If `buffer` is empty, the iterator will return null.</span></span>
<span class="line" id="L1608"><span class="tok-comment">/// If `delimiter_bytes` does not exist in buffer,</span></span>
<span class="line" id="L1609"><span class="tok-comment">/// the iterator will return `buffer`, null, in that order.</span></span>
<span class="line" id="L1610"><span class="tok-comment">///</span></span>
<span class="line" id="L1611"><span class="tok-comment">/// See also: `split` and `splitBackwards`.</span></span>
<span class="line" id="L1612"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">tokenize</span>(<span class="tok-kw">comptime</span> T: <span class="tok-type">type</span>, buffer: []<span class="tok-kw">const</span> T, delimiter_bytes: []<span class="tok-kw">const</span> T) TokenIterator(T) {</span>
<span class="line" id="L1613">    <span class="tok-kw">return</span> .{</span>
<span class="line" id="L1614">        .index = <span class="tok-number">0</span>,</span>
<span class="line" id="L1615">        .buffer = buffer,</span>
<span class="line" id="L1616">        .delimiter_bytes = delimiter_bytes,</span>
<span class="line" id="L1617">    };</span>
<span class="line" id="L1618">}</span>
<span class="line" id="L1619"></span>
<span class="line" id="L1620"><span class="tok-kw">test</span> <span class="tok-str">&quot;tokenize&quot;</span> {</span>
<span class="line" id="L1621">    <span class="tok-kw">var</span> it = tokenize(<span class="tok-type">u8</span>, <span class="tok-str">&quot;   abc def   ghi  &quot;</span>, <span class="tok-str">&quot; &quot;</span>);</span>
<span class="line" id="L1622">    <span class="tok-kw">try</span> testing.expect(eql(<span class="tok-type">u8</span>, it.next().?, <span class="tok-str">&quot;abc&quot;</span>));</span>
<span class="line" id="L1623">    <span class="tok-kw">try</span> testing.expect(eql(<span class="tok-type">u8</span>, it.peek().?, <span class="tok-str">&quot;def&quot;</span>));</span>
<span class="line" id="L1624">    <span class="tok-kw">try</span> testing.expect(eql(<span class="tok-type">u8</span>, it.next().?, <span class="tok-str">&quot;def&quot;</span>));</span>
<span class="line" id="L1625">    <span class="tok-kw">try</span> testing.expect(eql(<span class="tok-type">u8</span>, it.next().?, <span class="tok-str">&quot;ghi&quot;</span>));</span>
<span class="line" id="L1626">    <span class="tok-kw">try</span> testing.expect(it.next() == <span class="tok-null">null</span>);</span>
<span class="line" id="L1627"></span>
<span class="line" id="L1628">    it = tokenize(<span class="tok-type">u8</span>, <span class="tok-str">&quot;..\\bob&quot;</span>, <span class="tok-str">&quot;\\&quot;</span>);</span>
<span class="line" id="L1629">    <span class="tok-kw">try</span> testing.expect(eql(<span class="tok-type">u8</span>, it.next().?, <span class="tok-str">&quot;..&quot;</span>));</span>
<span class="line" id="L1630">    <span class="tok-kw">try</span> testing.expect(eql(<span class="tok-type">u8</span>, <span class="tok-str">&quot;..&quot;</span>, <span class="tok-str">&quot;..\\bob&quot;</span>[<span class="tok-number">0</span>..it.index]));</span>
<span class="line" id="L1631">    <span class="tok-kw">try</span> testing.expect(eql(<span class="tok-type">u8</span>, it.next().?, <span class="tok-str">&quot;bob&quot;</span>));</span>
<span class="line" id="L1632">    <span class="tok-kw">try</span> testing.expect(it.next() == <span class="tok-null">null</span>);</span>
<span class="line" id="L1633"></span>
<span class="line" id="L1634">    it = tokenize(<span class="tok-type">u8</span>, <span class="tok-str">&quot;//a/b&quot;</span>, <span class="tok-str">&quot;/&quot;</span>);</span>
<span class="line" id="L1635">    <span class="tok-kw">try</span> testing.expect(eql(<span class="tok-type">u8</span>, it.next().?, <span class="tok-str">&quot;a&quot;</span>));</span>
<span class="line" id="L1636">    <span class="tok-kw">try</span> testing.expect(eql(<span class="tok-type">u8</span>, it.next().?, <span class="tok-str">&quot;b&quot;</span>));</span>
<span class="line" id="L1637">    <span class="tok-kw">try</span> testing.expect(eql(<span class="tok-type">u8</span>, <span class="tok-str">&quot;//a/b&quot;</span>, <span class="tok-str">&quot;//a/b&quot;</span>[<span class="tok-number">0</span>..it.index]));</span>
<span class="line" id="L1638">    <span class="tok-kw">try</span> testing.expect(it.next() == <span class="tok-null">null</span>);</span>
<span class="line" id="L1639"></span>
<span class="line" id="L1640">    it = tokenize(<span class="tok-type">u8</span>, <span class="tok-str">&quot;|&quot;</span>, <span class="tok-str">&quot;|&quot;</span>);</span>
<span class="line" id="L1641">    <span class="tok-kw">try</span> testing.expect(it.next() == <span class="tok-null">null</span>);</span>
<span class="line" id="L1642">    <span class="tok-kw">try</span> testing.expect(it.peek() == <span class="tok-null">null</span>);</span>
<span class="line" id="L1643"></span>
<span class="line" id="L1644">    it = tokenize(<span class="tok-type">u8</span>, <span class="tok-str">&quot;&quot;</span>, <span class="tok-str">&quot;|&quot;</span>);</span>
<span class="line" id="L1645">    <span class="tok-kw">try</span> testing.expect(it.next() == <span class="tok-null">null</span>);</span>
<span class="line" id="L1646">    <span class="tok-kw">try</span> testing.expect(it.peek() == <span class="tok-null">null</span>);</span>
<span class="line" id="L1647"></span>
<span class="line" id="L1648">    it = tokenize(<span class="tok-type">u8</span>, <span class="tok-str">&quot;hello&quot;</span>, <span class="tok-str">&quot;&quot;</span>);</span>
<span class="line" id="L1649">    <span class="tok-kw">try</span> testing.expect(eql(<span class="tok-type">u8</span>, it.next().?, <span class="tok-str">&quot;hello&quot;</span>));</span>
<span class="line" id="L1650">    <span class="tok-kw">try</span> testing.expect(it.next() == <span class="tok-null">null</span>);</span>
<span class="line" id="L1651"></span>
<span class="line" id="L1652">    it = tokenize(<span class="tok-type">u8</span>, <span class="tok-str">&quot;hello&quot;</span>, <span class="tok-str">&quot; &quot;</span>);</span>
<span class="line" id="L1653">    <span class="tok-kw">try</span> testing.expect(eql(<span class="tok-type">u8</span>, it.next().?, <span class="tok-str">&quot;hello&quot;</span>));</span>
<span class="line" id="L1654">    <span class="tok-kw">try</span> testing.expect(it.next() == <span class="tok-null">null</span>);</span>
<span class="line" id="L1655"></span>
<span class="line" id="L1656">    <span class="tok-kw">var</span> it16 = tokenize(</span>
<span class="line" id="L1657">        <span class="tok-type">u16</span>,</span>
<span class="line" id="L1658">        std.unicode.utf8ToUtf16LeStringLiteral(<span class="tok-str">&quot;hello&quot;</span>),</span>
<span class="line" id="L1659">        std.unicode.utf8ToUtf16LeStringLiteral(<span class="tok-str">&quot; &quot;</span>),</span>
<span class="line" id="L1660">    );</span>
<span class="line" id="L1661">    <span class="tok-kw">try</span> testing.expect(eql(<span class="tok-type">u16</span>, it16.next().?, std.unicode.utf8ToUtf16LeStringLiteral(<span class="tok-str">&quot;hello&quot;</span>)));</span>
<span class="line" id="L1662">    <span class="tok-kw">try</span> testing.expect(it16.next() == <span class="tok-null">null</span>);</span>
<span class="line" id="L1663">}</span>
<span class="line" id="L1664"></span>
<span class="line" id="L1665"><span class="tok-kw">test</span> <span class="tok-str">&quot;tokenize (multibyte)&quot;</span> {</span>
<span class="line" id="L1666">    <span class="tok-kw">var</span> it = tokenize(<span class="tok-type">u8</span>, <span class="tok-str">&quot;a|b,c/d e&quot;</span>, <span class="tok-str">&quot; /,|&quot;</span>);</span>
<span class="line" id="L1667">    <span class="tok-kw">try</span> testing.expect(eql(<span class="tok-type">u8</span>, it.next().?, <span class="tok-str">&quot;a&quot;</span>));</span>
<span class="line" id="L1668">    <span class="tok-kw">try</span> testing.expect(eql(<span class="tok-type">u8</span>, it.peek().?, <span class="tok-str">&quot;b&quot;</span>));</span>
<span class="line" id="L1669">    <span class="tok-kw">try</span> testing.expect(eql(<span class="tok-type">u8</span>, it.next().?, <span class="tok-str">&quot;b&quot;</span>));</span>
<span class="line" id="L1670">    <span class="tok-kw">try</span> testing.expect(eql(<span class="tok-type">u8</span>, it.next().?, <span class="tok-str">&quot;c&quot;</span>));</span>
<span class="line" id="L1671">    <span class="tok-kw">try</span> testing.expect(eql(<span class="tok-type">u8</span>, it.next().?, <span class="tok-str">&quot;d&quot;</span>));</span>
<span class="line" id="L1672">    <span class="tok-kw">try</span> testing.expect(eql(<span class="tok-type">u8</span>, it.next().?, <span class="tok-str">&quot;e&quot;</span>));</span>
<span class="line" id="L1673">    <span class="tok-kw">try</span> testing.expect(it.next() == <span class="tok-null">null</span>);</span>
<span class="line" id="L1674">    <span class="tok-kw">try</span> testing.expect(it.peek() == <span class="tok-null">null</span>);</span>
<span class="line" id="L1675"></span>
<span class="line" id="L1676">    <span class="tok-kw">var</span> it16 = tokenize(</span>
<span class="line" id="L1677">        <span class="tok-type">u16</span>,</span>
<span class="line" id="L1678">        std.unicode.utf8ToUtf16LeStringLiteral(<span class="tok-str">&quot;a|b,c/d e&quot;</span>),</span>
<span class="line" id="L1679">        std.unicode.utf8ToUtf16LeStringLiteral(<span class="tok-str">&quot; /,|&quot;</span>),</span>
<span class="line" id="L1680">    );</span>
<span class="line" id="L1681">    <span class="tok-kw">try</span> testing.expect(eql(<span class="tok-type">u16</span>, it16.next().?, std.unicode.utf8ToUtf16LeStringLiteral(<span class="tok-str">&quot;a&quot;</span>)));</span>
<span class="line" id="L1682">    <span class="tok-kw">try</span> testing.expect(eql(<span class="tok-type">u16</span>, it16.next().?, std.unicode.utf8ToUtf16LeStringLiteral(<span class="tok-str">&quot;b&quot;</span>)));</span>
<span class="line" id="L1683">    <span class="tok-kw">try</span> testing.expect(eql(<span class="tok-type">u16</span>, it16.next().?, std.unicode.utf8ToUtf16LeStringLiteral(<span class="tok-str">&quot;c&quot;</span>)));</span>
<span class="line" id="L1684">    <span class="tok-kw">try</span> testing.expect(eql(<span class="tok-type">u16</span>, it16.next().?, std.unicode.utf8ToUtf16LeStringLiteral(<span class="tok-str">&quot;d&quot;</span>)));</span>
<span class="line" id="L1685">    <span class="tok-kw">try</span> testing.expect(eql(<span class="tok-type">u16</span>, it16.next().?, std.unicode.utf8ToUtf16LeStringLiteral(<span class="tok-str">&quot;e&quot;</span>)));</span>
<span class="line" id="L1686">    <span class="tok-kw">try</span> testing.expect(it16.next() == <span class="tok-null">null</span>);</span>
<span class="line" id="L1687">}</span>
<span class="line" id="L1688"></span>
<span class="line" id="L1689"><span class="tok-kw">test</span> <span class="tok-str">&quot;tokenize (reset)&quot;</span> {</span>
<span class="line" id="L1690">    <span class="tok-kw">var</span> it = tokenize(<span class="tok-type">u8</span>, <span class="tok-str">&quot;   abc def   ghi  &quot;</span>, <span class="tok-str">&quot; &quot;</span>);</span>
<span class="line" id="L1691">    <span class="tok-kw">try</span> testing.expect(eql(<span class="tok-type">u8</span>, it.next().?, <span class="tok-str">&quot;abc&quot;</span>));</span>
<span class="line" id="L1692">    <span class="tok-kw">try</span> testing.expect(eql(<span class="tok-type">u8</span>, it.next().?, <span class="tok-str">&quot;def&quot;</span>));</span>
<span class="line" id="L1693">    <span class="tok-kw">try</span> testing.expect(eql(<span class="tok-type">u8</span>, it.next().?, <span class="tok-str">&quot;ghi&quot;</span>));</span>
<span class="line" id="L1694"></span>
<span class="line" id="L1695">    it.reset();</span>
<span class="line" id="L1696"></span>
<span class="line" id="L1697">    <span class="tok-kw">try</span> testing.expect(eql(<span class="tok-type">u8</span>, it.next().?, <span class="tok-str">&quot;abc&quot;</span>));</span>
<span class="line" id="L1698">    <span class="tok-kw">try</span> testing.expect(eql(<span class="tok-type">u8</span>, it.next().?, <span class="tok-str">&quot;def&quot;</span>));</span>
<span class="line" id="L1699">    <span class="tok-kw">try</span> testing.expect(eql(<span class="tok-type">u8</span>, it.next().?, <span class="tok-str">&quot;ghi&quot;</span>));</span>
<span class="line" id="L1700">    <span class="tok-kw">try</span> testing.expect(it.next() == <span class="tok-null">null</span>);</span>
<span class="line" id="L1701">}</span>
<span class="line" id="L1702"></span>
<span class="line" id="L1703"><span class="tok-comment">/// Returns an iterator that iterates over the slices of `buffer` that</span></span>
<span class="line" id="L1704"><span class="tok-comment">/// are separated by bytes in `delimiter`.</span></span>
<span class="line" id="L1705"><span class="tok-comment">///</span></span>
<span class="line" id="L1706"><span class="tok-comment">/// `split(u8, &quot;abc|def||ghi&quot;, &quot;|&quot;)` will return slices</span></span>
<span class="line" id="L1707"><span class="tok-comment">/// for &quot;abc&quot;, &quot;def&quot;, &quot;&quot;, &quot;ghi&quot;, null, in that order.</span></span>
<span class="line" id="L1708"><span class="tok-comment">///</span></span>
<span class="line" id="L1709"><span class="tok-comment">/// If `delimiter` does not exist in buffer,</span></span>
<span class="line" id="L1710"><span class="tok-comment">/// the iterator will return `buffer`, null, in that order.</span></span>
<span class="line" id="L1711"><span class="tok-comment">/// The delimiter length must not be zero.</span></span>
<span class="line" id="L1712"><span class="tok-comment">///</span></span>
<span class="line" id="L1713"><span class="tok-comment">/// See also: `tokenize` and `splitBackwards`.</span></span>
<span class="line" id="L1714"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">split</span>(<span class="tok-kw">comptime</span> T: <span class="tok-type">type</span>, buffer: []<span class="tok-kw">const</span> T, delimiter: []<span class="tok-kw">const</span> T) SplitIterator(T) {</span>
<span class="line" id="L1715">    assert(delimiter.len != <span class="tok-number">0</span>);</span>
<span class="line" id="L1716">    <span class="tok-kw">return</span> .{</span>
<span class="line" id="L1717">        .index = <span class="tok-number">0</span>,</span>
<span class="line" id="L1718">        .buffer = buffer,</span>
<span class="line" id="L1719">        .delimiter = delimiter,</span>
<span class="line" id="L1720">    };</span>
<span class="line" id="L1721">}</span>
<span class="line" id="L1722"></span>
<span class="line" id="L1723"><span class="tok-kw">test</span> <span class="tok-str">&quot;split&quot;</span> {</span>
<span class="line" id="L1724">    <span class="tok-kw">var</span> it = split(<span class="tok-type">u8</span>, <span class="tok-str">&quot;abc|def||ghi&quot;</span>, <span class="tok-str">&quot;|&quot;</span>);</span>
<span class="line" id="L1725">    <span class="tok-kw">try</span> testing.expectEqualSlices(<span class="tok-type">u8</span>, it.rest(), <span class="tok-str">&quot;abc|def||ghi&quot;</span>);</span>
<span class="line" id="L1726">    <span class="tok-kw">try</span> testing.expectEqualSlices(<span class="tok-type">u8</span>, it.first(), <span class="tok-str">&quot;abc&quot;</span>);</span>
<span class="line" id="L1727"></span>
<span class="line" id="L1728">    <span class="tok-kw">try</span> testing.expectEqualSlices(<span class="tok-type">u8</span>, it.rest(), <span class="tok-str">&quot;def||ghi&quot;</span>);</span>
<span class="line" id="L1729">    <span class="tok-kw">try</span> testing.expectEqualSlices(<span class="tok-type">u8</span>, it.next().?, <span class="tok-str">&quot;def&quot;</span>);</span>
<span class="line" id="L1730"></span>
<span class="line" id="L1731">    <span class="tok-kw">try</span> testing.expectEqualSlices(<span class="tok-type">u8</span>, it.rest(), <span class="tok-str">&quot;|ghi&quot;</span>);</span>
<span class="line" id="L1732">    <span class="tok-kw">try</span> testing.expectEqualSlices(<span class="tok-type">u8</span>, it.next().?, <span class="tok-str">&quot;&quot;</span>);</span>
<span class="line" id="L1733"></span>
<span class="line" id="L1734">    <span class="tok-kw">try</span> testing.expectEqualSlices(<span class="tok-type">u8</span>, it.rest(), <span class="tok-str">&quot;ghi&quot;</span>);</span>
<span class="line" id="L1735">    <span class="tok-kw">try</span> testing.expectEqualSlices(<span class="tok-type">u8</span>, it.next().?, <span class="tok-str">&quot;ghi&quot;</span>);</span>
<span class="line" id="L1736"></span>
<span class="line" id="L1737">    <span class="tok-kw">try</span> testing.expectEqualSlices(<span class="tok-type">u8</span>, it.rest(), <span class="tok-str">&quot;&quot;</span>);</span>
<span class="line" id="L1738">    <span class="tok-kw">try</span> testing.expect(it.next() == <span class="tok-null">null</span>);</span>
<span class="line" id="L1739"></span>
<span class="line" id="L1740">    it = split(<span class="tok-type">u8</span>, <span class="tok-str">&quot;&quot;</span>, <span class="tok-str">&quot;|&quot;</span>);</span>
<span class="line" id="L1741">    <span class="tok-kw">try</span> testing.expectEqualSlices(<span class="tok-type">u8</span>, it.first(), <span class="tok-str">&quot;&quot;</span>);</span>
<span class="line" id="L1742">    <span class="tok-kw">try</span> testing.expect(it.next() == <span class="tok-null">null</span>);</span>
<span class="line" id="L1743"></span>
<span class="line" id="L1744">    it = split(<span class="tok-type">u8</span>, <span class="tok-str">&quot;|&quot;</span>, <span class="tok-str">&quot;|&quot;</span>);</span>
<span class="line" id="L1745">    <span class="tok-kw">try</span> testing.expectEqualSlices(<span class="tok-type">u8</span>, it.first(), <span class="tok-str">&quot;&quot;</span>);</span>
<span class="line" id="L1746">    <span class="tok-kw">try</span> testing.expectEqualSlices(<span class="tok-type">u8</span>, it.next().?, <span class="tok-str">&quot;&quot;</span>);</span>
<span class="line" id="L1747">    <span class="tok-kw">try</span> testing.expect(it.next() == <span class="tok-null">null</span>);</span>
<span class="line" id="L1748"></span>
<span class="line" id="L1749">    it = split(<span class="tok-type">u8</span>, <span class="tok-str">&quot;hello&quot;</span>, <span class="tok-str">&quot; &quot;</span>);</span>
<span class="line" id="L1750">    <span class="tok-kw">try</span> testing.expectEqualSlices(<span class="tok-type">u8</span>, it.first(), <span class="tok-str">&quot;hello&quot;</span>);</span>
<span class="line" id="L1751">    <span class="tok-kw">try</span> testing.expect(it.next() == <span class="tok-null">null</span>);</span>
<span class="line" id="L1752"></span>
<span class="line" id="L1753">    <span class="tok-kw">var</span> it16 = split(</span>
<span class="line" id="L1754">        <span class="tok-type">u16</span>,</span>
<span class="line" id="L1755">        std.unicode.utf8ToUtf16LeStringLiteral(<span class="tok-str">&quot;hello&quot;</span>),</span>
<span class="line" id="L1756">        std.unicode.utf8ToUtf16LeStringLiteral(<span class="tok-str">&quot; &quot;</span>),</span>
<span class="line" id="L1757">    );</span>
<span class="line" id="L1758">    <span class="tok-kw">try</span> testing.expectEqualSlices(<span class="tok-type">u16</span>, it16.first(), std.unicode.utf8ToUtf16LeStringLiteral(<span class="tok-str">&quot;hello&quot;</span>));</span>
<span class="line" id="L1759">    <span class="tok-kw">try</span> testing.expect(it16.next() == <span class="tok-null">null</span>);</span>
<span class="line" id="L1760">}</span>
<span class="line" id="L1761"></span>
<span class="line" id="L1762"><span class="tok-kw">test</span> <span class="tok-str">&quot;split (multibyte)&quot;</span> {</span>
<span class="line" id="L1763">    <span class="tok-kw">var</span> it = split(<span class="tok-type">u8</span>, <span class="tok-str">&quot;a, b ,, c, d, e&quot;</span>, <span class="tok-str">&quot;, &quot;</span>);</span>
<span class="line" id="L1764">    <span class="tok-kw">try</span> testing.expectEqualSlices(<span class="tok-type">u8</span>, it.first(), <span class="tok-str">&quot;a&quot;</span>);</span>
<span class="line" id="L1765">    <span class="tok-kw">try</span> testing.expectEqualSlices(<span class="tok-type">u8</span>, it.rest(), <span class="tok-str">&quot;b ,, c, d, e&quot;</span>);</span>
<span class="line" id="L1766">    <span class="tok-kw">try</span> testing.expectEqualSlices(<span class="tok-type">u8</span>, it.next().?, <span class="tok-str">&quot;b ,&quot;</span>);</span>
<span class="line" id="L1767">    <span class="tok-kw">try</span> testing.expectEqualSlices(<span class="tok-type">u8</span>, it.next().?, <span class="tok-str">&quot;c&quot;</span>);</span>
<span class="line" id="L1768">    <span class="tok-kw">try</span> testing.expectEqualSlices(<span class="tok-type">u8</span>, it.next().?, <span class="tok-str">&quot;d&quot;</span>);</span>
<span class="line" id="L1769">    <span class="tok-kw">try</span> testing.expectEqualSlices(<span class="tok-type">u8</span>, it.next().?, <span class="tok-str">&quot;e&quot;</span>);</span>
<span class="line" id="L1770">    <span class="tok-kw">try</span> testing.expect(it.next() == <span class="tok-null">null</span>);</span>
<span class="line" id="L1771"></span>
<span class="line" id="L1772">    <span class="tok-kw">var</span> it16 = split(</span>
<span class="line" id="L1773">        <span class="tok-type">u16</span>,</span>
<span class="line" id="L1774">        std.unicode.utf8ToUtf16LeStringLiteral(<span class="tok-str">&quot;a, b ,, c, d, e&quot;</span>),</span>
<span class="line" id="L1775">        std.unicode.utf8ToUtf16LeStringLiteral(<span class="tok-str">&quot;, &quot;</span>),</span>
<span class="line" id="L1776">    );</span>
<span class="line" id="L1777">    <span class="tok-kw">try</span> testing.expectEqualSlices(<span class="tok-type">u16</span>, it16.first(), std.unicode.utf8ToUtf16LeStringLiteral(<span class="tok-str">&quot;a&quot;</span>));</span>
<span class="line" id="L1778">    <span class="tok-kw">try</span> testing.expectEqualSlices(<span class="tok-type">u16</span>, it16.next().?, std.unicode.utf8ToUtf16LeStringLiteral(<span class="tok-str">&quot;b ,&quot;</span>));</span>
<span class="line" id="L1779">    <span class="tok-kw">try</span> testing.expectEqualSlices(<span class="tok-type">u16</span>, it16.next().?, std.unicode.utf8ToUtf16LeStringLiteral(<span class="tok-str">&quot;c&quot;</span>));</span>
<span class="line" id="L1780">    <span class="tok-kw">try</span> testing.expectEqualSlices(<span class="tok-type">u16</span>, it16.next().?, std.unicode.utf8ToUtf16LeStringLiteral(<span class="tok-str">&quot;d&quot;</span>));</span>
<span class="line" id="L1781">    <span class="tok-kw">try</span> testing.expectEqualSlices(<span class="tok-type">u16</span>, it16.next().?, std.unicode.utf8ToUtf16LeStringLiteral(<span class="tok-str">&quot;e&quot;</span>));</span>
<span class="line" id="L1782">    <span class="tok-kw">try</span> testing.expect(it16.next() == <span class="tok-null">null</span>);</span>
<span class="line" id="L1783">}</span>
<span class="line" id="L1784"></span>
<span class="line" id="L1785"><span class="tok-kw">test</span> <span class="tok-str">&quot;split (reset)&quot;</span> {</span>
<span class="line" id="L1786">    <span class="tok-kw">var</span> it = split(<span class="tok-type">u8</span>, <span class="tok-str">&quot;abc def ghi&quot;</span>, <span class="tok-str">&quot; &quot;</span>);</span>
<span class="line" id="L1787">    <span class="tok-kw">try</span> testing.expect(eql(<span class="tok-type">u8</span>, it.first(), <span class="tok-str">&quot;abc&quot;</span>));</span>
<span class="line" id="L1788">    <span class="tok-kw">try</span> testing.expect(eql(<span class="tok-type">u8</span>, it.next().?, <span class="tok-str">&quot;def&quot;</span>));</span>
<span class="line" id="L1789">    <span class="tok-kw">try</span> testing.expect(eql(<span class="tok-type">u8</span>, it.next().?, <span class="tok-str">&quot;ghi&quot;</span>));</span>
<span class="line" id="L1790"></span>
<span class="line" id="L1791">    it.reset();</span>
<span class="line" id="L1792"></span>
<span class="line" id="L1793">    <span class="tok-kw">try</span> testing.expect(eql(<span class="tok-type">u8</span>, it.first(), <span class="tok-str">&quot;abc&quot;</span>));</span>
<span class="line" id="L1794">    <span class="tok-kw">try</span> testing.expect(eql(<span class="tok-type">u8</span>, it.next().?, <span class="tok-str">&quot;def&quot;</span>));</span>
<span class="line" id="L1795">    <span class="tok-kw">try</span> testing.expect(eql(<span class="tok-type">u8</span>, it.next().?, <span class="tok-str">&quot;ghi&quot;</span>));</span>
<span class="line" id="L1796">    <span class="tok-kw">try</span> testing.expect(it.next() == <span class="tok-null">null</span>);</span>
<span class="line" id="L1797">}</span>
<span class="line" id="L1798"></span>
<span class="line" id="L1799"><span class="tok-comment">/// Returns an iterator that iterates backwards over the slices of `buffer`</span></span>
<span class="line" id="L1800"><span class="tok-comment">/// that are separated by bytes in `delimiter`.</span></span>
<span class="line" id="L1801"><span class="tok-comment">///</span></span>
<span class="line" id="L1802"><span class="tok-comment">/// `splitBackwards(u8, &quot;abc|def||ghi&quot;, &quot;|&quot;)` will return slices</span></span>
<span class="line" id="L1803"><span class="tok-comment">/// for &quot;ghi&quot;, &quot;&quot;, &quot;def&quot;, &quot;abc&quot;, null, in that order.</span></span>
<span class="line" id="L1804"><span class="tok-comment">///</span></span>
<span class="line" id="L1805"><span class="tok-comment">/// If `delimiter` does not exist in buffer,</span></span>
<span class="line" id="L1806"><span class="tok-comment">/// the iterator will return `buffer`, null, in that order.</span></span>
<span class="line" id="L1807"><span class="tok-comment">/// The delimiter length must not be zero.</span></span>
<span class="line" id="L1808"><span class="tok-comment">///</span></span>
<span class="line" id="L1809"><span class="tok-comment">/// See also: `tokenize` and `split`.</span></span>
<span class="line" id="L1810"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">splitBackwards</span>(<span class="tok-kw">comptime</span> T: <span class="tok-type">type</span>, buffer: []<span class="tok-kw">const</span> T, delimiter: []<span class="tok-kw">const</span> T) SplitBackwardsIterator(T) {</span>
<span class="line" id="L1811">    assert(delimiter.len != <span class="tok-number">0</span>);</span>
<span class="line" id="L1812">    <span class="tok-kw">return</span> SplitBackwardsIterator(T){</span>
<span class="line" id="L1813">        .index = buffer.len,</span>
<span class="line" id="L1814">        .buffer = buffer,</span>
<span class="line" id="L1815">        .delimiter = delimiter,</span>
<span class="line" id="L1816">    };</span>
<span class="line" id="L1817">}</span>
<span class="line" id="L1818"></span>
<span class="line" id="L1819"><span class="tok-kw">test</span> <span class="tok-str">&quot;splitBackwards&quot;</span> {</span>
<span class="line" id="L1820">    <span class="tok-kw">var</span> it = splitBackwards(<span class="tok-type">u8</span>, <span class="tok-str">&quot;abc|def||ghi&quot;</span>, <span class="tok-str">&quot;|&quot;</span>);</span>
<span class="line" id="L1821">    <span class="tok-kw">try</span> testing.expectEqualSlices(<span class="tok-type">u8</span>, it.rest(), <span class="tok-str">&quot;abc|def||ghi&quot;</span>);</span>
<span class="line" id="L1822">    <span class="tok-kw">try</span> testing.expectEqualSlices(<span class="tok-type">u8</span>, it.first(), <span class="tok-str">&quot;ghi&quot;</span>);</span>
<span class="line" id="L1823"></span>
<span class="line" id="L1824">    <span class="tok-kw">try</span> testing.expectEqualSlices(<span class="tok-type">u8</span>, it.rest(), <span class="tok-str">&quot;abc|def|&quot;</span>);</span>
<span class="line" id="L1825">    <span class="tok-kw">try</span> testing.expectEqualSlices(<span class="tok-type">u8</span>, it.next().?, <span class="tok-str">&quot;&quot;</span>);</span>
<span class="line" id="L1826"></span>
<span class="line" id="L1827">    <span class="tok-kw">try</span> testing.expectEqualSlices(<span class="tok-type">u8</span>, it.rest(), <span class="tok-str">&quot;abc|def&quot;</span>);</span>
<span class="line" id="L1828">    <span class="tok-kw">try</span> testing.expectEqualSlices(<span class="tok-type">u8</span>, it.next().?, <span class="tok-str">&quot;def&quot;</span>);</span>
<span class="line" id="L1829"></span>
<span class="line" id="L1830">    <span class="tok-kw">try</span> testing.expectEqualSlices(<span class="tok-type">u8</span>, it.rest(), <span class="tok-str">&quot;abc&quot;</span>);</span>
<span class="line" id="L1831">    <span class="tok-kw">try</span> testing.expectEqualSlices(<span class="tok-type">u8</span>, it.next().?, <span class="tok-str">&quot;abc&quot;</span>);</span>
<span class="line" id="L1832"></span>
<span class="line" id="L1833">    <span class="tok-kw">try</span> testing.expectEqualSlices(<span class="tok-type">u8</span>, it.rest(), <span class="tok-str">&quot;&quot;</span>);</span>
<span class="line" id="L1834">    <span class="tok-kw">try</span> testing.expect(it.next() == <span class="tok-null">null</span>);</span>
<span class="line" id="L1835"></span>
<span class="line" id="L1836">    it = splitBackwards(<span class="tok-type">u8</span>, <span class="tok-str">&quot;&quot;</span>, <span class="tok-str">&quot;|&quot;</span>);</span>
<span class="line" id="L1837">    <span class="tok-kw">try</span> testing.expectEqualSlices(<span class="tok-type">u8</span>, it.first(), <span class="tok-str">&quot;&quot;</span>);</span>
<span class="line" id="L1838">    <span class="tok-kw">try</span> testing.expect(it.next() == <span class="tok-null">null</span>);</span>
<span class="line" id="L1839"></span>
<span class="line" id="L1840">    it = splitBackwards(<span class="tok-type">u8</span>, <span class="tok-str">&quot;|&quot;</span>, <span class="tok-str">&quot;|&quot;</span>);</span>
<span class="line" id="L1841">    <span class="tok-kw">try</span> testing.expectEqualSlices(<span class="tok-type">u8</span>, it.first(), <span class="tok-str">&quot;&quot;</span>);</span>
<span class="line" id="L1842">    <span class="tok-kw">try</span> testing.expectEqualSlices(<span class="tok-type">u8</span>, it.next().?, <span class="tok-str">&quot;&quot;</span>);</span>
<span class="line" id="L1843">    <span class="tok-kw">try</span> testing.expect(it.next() == <span class="tok-null">null</span>);</span>
<span class="line" id="L1844"></span>
<span class="line" id="L1845">    it = splitBackwards(<span class="tok-type">u8</span>, <span class="tok-str">&quot;hello&quot;</span>, <span class="tok-str">&quot; &quot;</span>);</span>
<span class="line" id="L1846">    <span class="tok-kw">try</span> testing.expectEqualSlices(<span class="tok-type">u8</span>, it.first(), <span class="tok-str">&quot;hello&quot;</span>);</span>
<span class="line" id="L1847">    <span class="tok-kw">try</span> testing.expect(it.next() == <span class="tok-null">null</span>);</span>
<span class="line" id="L1848"></span>
<span class="line" id="L1849">    <span class="tok-kw">var</span> it16 = splitBackwards(</span>
<span class="line" id="L1850">        <span class="tok-type">u16</span>,</span>
<span class="line" id="L1851">        std.unicode.utf8ToUtf16LeStringLiteral(<span class="tok-str">&quot;hello&quot;</span>),</span>
<span class="line" id="L1852">        std.unicode.utf8ToUtf16LeStringLiteral(<span class="tok-str">&quot; &quot;</span>),</span>
<span class="line" id="L1853">    );</span>
<span class="line" id="L1854">    <span class="tok-kw">try</span> testing.expectEqualSlices(<span class="tok-type">u16</span>, it16.first(), std.unicode.utf8ToUtf16LeStringLiteral(<span class="tok-str">&quot;hello&quot;</span>));</span>
<span class="line" id="L1855">    <span class="tok-kw">try</span> testing.expect(it16.next() == <span class="tok-null">null</span>);</span>
<span class="line" id="L1856">}</span>
<span class="line" id="L1857"></span>
<span class="line" id="L1858"><span class="tok-kw">test</span> <span class="tok-str">&quot;splitBackwards (multibyte)&quot;</span> {</span>
<span class="line" id="L1859">    <span class="tok-kw">var</span> it = splitBackwards(<span class="tok-type">u8</span>, <span class="tok-str">&quot;a, b ,, c, d, e&quot;</span>, <span class="tok-str">&quot;, &quot;</span>);</span>
<span class="line" id="L1860">    <span class="tok-kw">try</span> testing.expectEqualSlices(<span class="tok-type">u8</span>, it.rest(), <span class="tok-str">&quot;a, b ,, c, d, e&quot;</span>);</span>
<span class="line" id="L1861">    <span class="tok-kw">try</span> testing.expectEqualSlices(<span class="tok-type">u8</span>, it.first(), <span class="tok-str">&quot;e&quot;</span>);</span>
<span class="line" id="L1862"></span>
<span class="line" id="L1863">    <span class="tok-kw">try</span> testing.expectEqualSlices(<span class="tok-type">u8</span>, it.rest(), <span class="tok-str">&quot;a, b ,, c, d&quot;</span>);</span>
<span class="line" id="L1864">    <span class="tok-kw">try</span> testing.expectEqualSlices(<span class="tok-type">u8</span>, it.next().?, <span class="tok-str">&quot;d&quot;</span>);</span>
<span class="line" id="L1865"></span>
<span class="line" id="L1866">    <span class="tok-kw">try</span> testing.expectEqualSlices(<span class="tok-type">u8</span>, it.rest(), <span class="tok-str">&quot;a, b ,, c&quot;</span>);</span>
<span class="line" id="L1867">    <span class="tok-kw">try</span> testing.expectEqualSlices(<span class="tok-type">u8</span>, it.next().?, <span class="tok-str">&quot;c&quot;</span>);</span>
<span class="line" id="L1868"></span>
<span class="line" id="L1869">    <span class="tok-kw">try</span> testing.expectEqualSlices(<span class="tok-type">u8</span>, it.rest(), <span class="tok-str">&quot;a, b ,&quot;</span>);</span>
<span class="line" id="L1870">    <span class="tok-kw">try</span> testing.expectEqualSlices(<span class="tok-type">u8</span>, it.next().?, <span class="tok-str">&quot;b ,&quot;</span>);</span>
<span class="line" id="L1871"></span>
<span class="line" id="L1872">    <span class="tok-kw">try</span> testing.expectEqualSlices(<span class="tok-type">u8</span>, it.rest(), <span class="tok-str">&quot;a&quot;</span>);</span>
<span class="line" id="L1873">    <span class="tok-kw">try</span> testing.expectEqualSlices(<span class="tok-type">u8</span>, it.next().?, <span class="tok-str">&quot;a&quot;</span>);</span>
<span class="line" id="L1874"></span>
<span class="line" id="L1875">    <span class="tok-kw">try</span> testing.expectEqualSlices(<span class="tok-type">u8</span>, it.rest(), <span class="tok-str">&quot;&quot;</span>);</span>
<span class="line" id="L1876">    <span class="tok-kw">try</span> testing.expect(it.next() == <span class="tok-null">null</span>);</span>
<span class="line" id="L1877"></span>
<span class="line" id="L1878">    <span class="tok-kw">var</span> it16 = splitBackwards(</span>
<span class="line" id="L1879">        <span class="tok-type">u16</span>,</span>
<span class="line" id="L1880">        std.unicode.utf8ToUtf16LeStringLiteral(<span class="tok-str">&quot;a, b ,, c, d, e&quot;</span>),</span>
<span class="line" id="L1881">        std.unicode.utf8ToUtf16LeStringLiteral(<span class="tok-str">&quot;, &quot;</span>),</span>
<span class="line" id="L1882">    );</span>
<span class="line" id="L1883">    <span class="tok-kw">try</span> testing.expectEqualSlices(<span class="tok-type">u16</span>, it16.first(), std.unicode.utf8ToUtf16LeStringLiteral(<span class="tok-str">&quot;e&quot;</span>));</span>
<span class="line" id="L1884">    <span class="tok-kw">try</span> testing.expectEqualSlices(<span class="tok-type">u16</span>, it16.next().?, std.unicode.utf8ToUtf16LeStringLiteral(<span class="tok-str">&quot;d&quot;</span>));</span>
<span class="line" id="L1885">    <span class="tok-kw">try</span> testing.expectEqualSlices(<span class="tok-type">u16</span>, it16.next().?, std.unicode.utf8ToUtf16LeStringLiteral(<span class="tok-str">&quot;c&quot;</span>));</span>
<span class="line" id="L1886">    <span class="tok-kw">try</span> testing.expectEqualSlices(<span class="tok-type">u16</span>, it16.next().?, std.unicode.utf8ToUtf16LeStringLiteral(<span class="tok-str">&quot;b ,&quot;</span>));</span>
<span class="line" id="L1887">    <span class="tok-kw">try</span> testing.expectEqualSlices(<span class="tok-type">u16</span>, it16.next().?, std.unicode.utf8ToUtf16LeStringLiteral(<span class="tok-str">&quot;a&quot;</span>));</span>
<span class="line" id="L1888">    <span class="tok-kw">try</span> testing.expect(it16.next() == <span class="tok-null">null</span>);</span>
<span class="line" id="L1889">}</span>
<span class="line" id="L1890"></span>
<span class="line" id="L1891"><span class="tok-kw">test</span> <span class="tok-str">&quot;splitBackwards (reset)&quot;</span> {</span>
<span class="line" id="L1892">    <span class="tok-kw">var</span> it = splitBackwards(<span class="tok-type">u8</span>, <span class="tok-str">&quot;abc def ghi&quot;</span>, <span class="tok-str">&quot; &quot;</span>);</span>
<span class="line" id="L1893">    <span class="tok-kw">try</span> testing.expect(eql(<span class="tok-type">u8</span>, it.first(), <span class="tok-str">&quot;ghi&quot;</span>));</span>
<span class="line" id="L1894">    <span class="tok-kw">try</span> testing.expect(eql(<span class="tok-type">u8</span>, it.next().?, <span class="tok-str">&quot;def&quot;</span>));</span>
<span class="line" id="L1895">    <span class="tok-kw">try</span> testing.expect(eql(<span class="tok-type">u8</span>, it.next().?, <span class="tok-str">&quot;abc&quot;</span>));</span>
<span class="line" id="L1896"></span>
<span class="line" id="L1897">    it.reset();</span>
<span class="line" id="L1898"></span>
<span class="line" id="L1899">    <span class="tok-kw">try</span> testing.expect(eql(<span class="tok-type">u8</span>, it.first(), <span class="tok-str">&quot;ghi&quot;</span>));</span>
<span class="line" id="L1900">    <span class="tok-kw">try</span> testing.expect(eql(<span class="tok-type">u8</span>, it.next().?, <span class="tok-str">&quot;def&quot;</span>));</span>
<span class="line" id="L1901">    <span class="tok-kw">try</span> testing.expect(eql(<span class="tok-type">u8</span>, it.next().?, <span class="tok-str">&quot;abc&quot;</span>));</span>
<span class="line" id="L1902">    <span class="tok-kw">try</span> testing.expect(it.next() == <span class="tok-null">null</span>);</span>
<span class="line" id="L1903">}</span>
<span class="line" id="L1904"></span>
<span class="line" id="L1905"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">startsWith</span>(<span class="tok-kw">comptime</span> T: <span class="tok-type">type</span>, haystack: []<span class="tok-kw">const</span> T, needle: []<span class="tok-kw">const</span> T) <span class="tok-type">bool</span> {</span>
<span class="line" id="L1906">    <span class="tok-kw">return</span> <span class="tok-kw">if</span> (needle.len &gt; haystack.len) <span class="tok-null">false</span> <span class="tok-kw">else</span> eql(T, haystack[<span class="tok-number">0</span>..needle.len], needle);</span>
<span class="line" id="L1907">}</span>
<span class="line" id="L1908"></span>
<span class="line" id="L1909"><span class="tok-kw">test</span> <span class="tok-str">&quot;startsWith&quot;</span> {</span>
<span class="line" id="L1910">    <span class="tok-kw">try</span> testing.expect(startsWith(<span class="tok-type">u8</span>, <span class="tok-str">&quot;Bob&quot;</span>, <span class="tok-str">&quot;Bo&quot;</span>));</span>
<span class="line" id="L1911">    <span class="tok-kw">try</span> testing.expect(!startsWith(<span class="tok-type">u8</span>, <span class="tok-str">&quot;Needle in haystack&quot;</span>, <span class="tok-str">&quot;haystack&quot;</span>));</span>
<span class="line" id="L1912">}</span>
<span class="line" id="L1913"></span>
<span class="line" id="L1914"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">endsWith</span>(<span class="tok-kw">comptime</span> T: <span class="tok-type">type</span>, haystack: []<span class="tok-kw">const</span> T, needle: []<span class="tok-kw">const</span> T) <span class="tok-type">bool</span> {</span>
<span class="line" id="L1915">    <span class="tok-kw">return</span> <span class="tok-kw">if</span> (needle.len &gt; haystack.len) <span class="tok-null">false</span> <span class="tok-kw">else</span> eql(T, haystack[haystack.len - needle.len ..], needle);</span>
<span class="line" id="L1916">}</span>
<span class="line" id="L1917"></span>
<span class="line" id="L1918"><span class="tok-kw">test</span> <span class="tok-str">&quot;endsWith&quot;</span> {</span>
<span class="line" id="L1919">    <span class="tok-kw">try</span> testing.expect(endsWith(<span class="tok-type">u8</span>, <span class="tok-str">&quot;Needle in haystack&quot;</span>, <span class="tok-str">&quot;haystack&quot;</span>));</span>
<span class="line" id="L1920">    <span class="tok-kw">try</span> testing.expect(!endsWith(<span class="tok-type">u8</span>, <span class="tok-str">&quot;Bob&quot;</span>, <span class="tok-str">&quot;Bo&quot;</span>));</span>
<span class="line" id="L1921">}</span>
<span class="line" id="L1922"></span>
<span class="line" id="L1923"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">TokenIterator</span>(<span class="tok-kw">comptime</span> T: <span class="tok-type">type</span>) <span class="tok-type">type</span> {</span>
<span class="line" id="L1924">    <span class="tok-kw">return</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L1925">        buffer: []<span class="tok-kw">const</span> T,</span>
<span class="line" id="L1926">        delimiter_bytes: []<span class="tok-kw">const</span> T,</span>
<span class="line" id="L1927">        index: <span class="tok-type">usize</span>,</span>
<span class="line" id="L1928"></span>
<span class="line" id="L1929">        <span class="tok-kw">const</span> Self = <span class="tok-builtin">@This</span>();</span>
<span class="line" id="L1930"></span>
<span class="line" id="L1931">        <span class="tok-comment">/// Returns a slice of the current token, or null if tokenization is</span></span>
<span class="line" id="L1932">        <span class="tok-comment">/// complete, and advances to the next token.</span></span>
<span class="line" id="L1933">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">next</span>(self: *Self) ?[]<span class="tok-kw">const</span> T {</span>
<span class="line" id="L1934">            <span class="tok-kw">const</span> result = self.peek() <span class="tok-kw">orelse</span> <span class="tok-kw">return</span> <span class="tok-null">null</span>;</span>
<span class="line" id="L1935">            self.index += result.len;</span>
<span class="line" id="L1936">            <span class="tok-kw">return</span> result;</span>
<span class="line" id="L1937">        }</span>
<span class="line" id="L1938"></span>
<span class="line" id="L1939">        <span class="tok-comment">/// Returns a slice of the current token, or null if tokenization is</span></span>
<span class="line" id="L1940">        <span class="tok-comment">/// complete. Does not advance to the next token.</span></span>
<span class="line" id="L1941">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">peek</span>(self: *Self) ?[]<span class="tok-kw">const</span> T {</span>
<span class="line" id="L1942">            <span class="tok-comment">// move to beginning of token</span>
</span>
<span class="line" id="L1943">            <span class="tok-kw">while</span> (self.index &lt; self.buffer.len <span class="tok-kw">and</span> self.isSplitByte(self.buffer[self.index])) : (self.index += <span class="tok-number">1</span>) {}</span>
<span class="line" id="L1944">            <span class="tok-kw">const</span> start = self.index;</span>
<span class="line" id="L1945">            <span class="tok-kw">if</span> (start == self.buffer.len) {</span>
<span class="line" id="L1946">                <span class="tok-kw">return</span> <span class="tok-null">null</span>;</span>
<span class="line" id="L1947">            }</span>
<span class="line" id="L1948"></span>
<span class="line" id="L1949">            <span class="tok-comment">// move to end of token</span>
</span>
<span class="line" id="L1950">            <span class="tok-kw">var</span> end = start;</span>
<span class="line" id="L1951">            <span class="tok-kw">while</span> (end &lt; self.buffer.len <span class="tok-kw">and</span> !self.isSplitByte(self.buffer[end])) : (end += <span class="tok-number">1</span>) {}</span>
<span class="line" id="L1952"></span>
<span class="line" id="L1953">            <span class="tok-kw">return</span> self.buffer[start..end];</span>
<span class="line" id="L1954">        }</span>
<span class="line" id="L1955"></span>
<span class="line" id="L1956">        <span class="tok-comment">/// Returns a slice of the remaining bytes. Does not affect iterator state.</span></span>
<span class="line" id="L1957">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">rest</span>(self: Self) []<span class="tok-kw">const</span> T {</span>
<span class="line" id="L1958">            <span class="tok-comment">// move to beginning of token</span>
</span>
<span class="line" id="L1959">            <span class="tok-kw">var</span> index: <span class="tok-type">usize</span> = self.index;</span>
<span class="line" id="L1960">            <span class="tok-kw">while</span> (index &lt; self.buffer.len <span class="tok-kw">and</span> self.isSplitByte(self.buffer[index])) : (index += <span class="tok-number">1</span>) {}</span>
<span class="line" id="L1961">            <span class="tok-kw">return</span> self.buffer[index..];</span>
<span class="line" id="L1962">        }</span>
<span class="line" id="L1963"></span>
<span class="line" id="L1964">        <span class="tok-comment">/// Resets the iterator to the initial token.</span></span>
<span class="line" id="L1965">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">reset</span>(self: *Self) <span class="tok-type">void</span> {</span>
<span class="line" id="L1966">            self.index = <span class="tok-number">0</span>;</span>
<span class="line" id="L1967">        }</span>
<span class="line" id="L1968"></span>
<span class="line" id="L1969">        <span class="tok-kw">fn</span> <span class="tok-fn">isSplitByte</span>(self: Self, byte: T) <span class="tok-type">bool</span> {</span>
<span class="line" id="L1970">            <span class="tok-kw">for</span> (self.delimiter_bytes) |delimiter_byte| {</span>
<span class="line" id="L1971">                <span class="tok-kw">if</span> (byte == delimiter_byte) {</span>
<span class="line" id="L1972">                    <span class="tok-kw">return</span> <span class="tok-null">true</span>;</span>
<span class="line" id="L1973">                }</span>
<span class="line" id="L1974">            }</span>
<span class="line" id="L1975">            <span class="tok-kw">return</span> <span class="tok-null">false</span>;</span>
<span class="line" id="L1976">        }</span>
<span class="line" id="L1977">    };</span>
<span class="line" id="L1978">}</span>
<span class="line" id="L1979"></span>
<span class="line" id="L1980"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">SplitIterator</span>(<span class="tok-kw">comptime</span> T: <span class="tok-type">type</span>) <span class="tok-type">type</span> {</span>
<span class="line" id="L1981">    <span class="tok-kw">return</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L1982">        buffer: []<span class="tok-kw">const</span> T,</span>
<span class="line" id="L1983">        index: ?<span class="tok-type">usize</span>,</span>
<span class="line" id="L1984">        delimiter: []<span class="tok-kw">const</span> T,</span>
<span class="line" id="L1985"></span>
<span class="line" id="L1986">        <span class="tok-kw">const</span> Self = <span class="tok-builtin">@This</span>();</span>
<span class="line" id="L1987"></span>
<span class="line" id="L1988">        <span class="tok-comment">/// Returns a slice of the first field. This never fails.</span></span>
<span class="line" id="L1989">        <span class="tok-comment">/// Call this only to get the first field and then use `next` to get all subsequent fields.</span></span>
<span class="line" id="L1990">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">first</span>(self: *Self) []<span class="tok-kw">const</span> T {</span>
<span class="line" id="L1991">            assert(self.index.? == <span class="tok-number">0</span>);</span>
<span class="line" id="L1992">            <span class="tok-kw">return</span> self.next().?;</span>
<span class="line" id="L1993">        }</span>
<span class="line" id="L1994"></span>
<span class="line" id="L1995">        <span class="tok-comment">/// Returns a slice of the next field, or null if splitting is complete.</span></span>
<span class="line" id="L1996">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">next</span>(self: *Self) ?[]<span class="tok-kw">const</span> T {</span>
<span class="line" id="L1997">            <span class="tok-kw">const</span> start = self.index <span class="tok-kw">orelse</span> <span class="tok-kw">return</span> <span class="tok-null">null</span>;</span>
<span class="line" id="L1998">            <span class="tok-kw">const</span> end = <span class="tok-kw">if</span> (indexOfPos(T, self.buffer, start, self.delimiter)) |delim_start| blk: {</span>
<span class="line" id="L1999">                self.index = delim_start + self.delimiter.len;</span>
<span class="line" id="L2000">                <span class="tok-kw">break</span> :blk delim_start;</span>
<span class="line" id="L2001">            } <span class="tok-kw">else</span> blk: {</span>
<span class="line" id="L2002">                self.index = <span class="tok-null">null</span>;</span>
<span class="line" id="L2003">                <span class="tok-kw">break</span> :blk self.buffer.len;</span>
<span class="line" id="L2004">            };</span>
<span class="line" id="L2005">            <span class="tok-kw">return</span> self.buffer[start..end];</span>
<span class="line" id="L2006">        }</span>
<span class="line" id="L2007"></span>
<span class="line" id="L2008">        <span class="tok-comment">/// Returns a slice of the remaining bytes. Does not affect iterator state.</span></span>
<span class="line" id="L2009">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">rest</span>(self: Self) []<span class="tok-kw">const</span> T {</span>
<span class="line" id="L2010">            <span class="tok-kw">const</span> end = self.buffer.len;</span>
<span class="line" id="L2011">            <span class="tok-kw">const</span> start = self.index <span class="tok-kw">orelse</span> end;</span>
<span class="line" id="L2012">            <span class="tok-kw">return</span> self.buffer[start..end];</span>
<span class="line" id="L2013">        }</span>
<span class="line" id="L2014"></span>
<span class="line" id="L2015">        <span class="tok-comment">/// Resets the iterator to the initial slice.</span></span>
<span class="line" id="L2016">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">reset</span>(self: *Self) <span class="tok-type">void</span> {</span>
<span class="line" id="L2017">            self.index = <span class="tok-number">0</span>;</span>
<span class="line" id="L2018">        }</span>
<span class="line" id="L2019">    };</span>
<span class="line" id="L2020">}</span>
<span class="line" id="L2021"></span>
<span class="line" id="L2022"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">SplitBackwardsIterator</span>(<span class="tok-kw">comptime</span> T: <span class="tok-type">type</span>) <span class="tok-type">type</span> {</span>
<span class="line" id="L2023">    <span class="tok-kw">return</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L2024">        buffer: []<span class="tok-kw">const</span> T,</span>
<span class="line" id="L2025">        index: ?<span class="tok-type">usize</span>,</span>
<span class="line" id="L2026">        delimiter: []<span class="tok-kw">const</span> T,</span>
<span class="line" id="L2027"></span>
<span class="line" id="L2028">        <span class="tok-kw">const</span> Self = <span class="tok-builtin">@This</span>();</span>
<span class="line" id="L2029"></span>
<span class="line" id="L2030">        <span class="tok-comment">/// Returns a slice of the first field. This never fails.</span></span>
<span class="line" id="L2031">        <span class="tok-comment">/// Call this only to get the first field and then use `next` to get all subsequent fields.</span></span>
<span class="line" id="L2032">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">first</span>(self: *Self) []<span class="tok-kw">const</span> T {</span>
<span class="line" id="L2033">            assert(self.index.? == self.buffer.len);</span>
<span class="line" id="L2034">            <span class="tok-kw">return</span> self.next().?;</span>
<span class="line" id="L2035">        }</span>
<span class="line" id="L2036"></span>
<span class="line" id="L2037">        <span class="tok-comment">/// Returns a slice of the next field, or null if splitting is complete.</span></span>
<span class="line" id="L2038">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">next</span>(self: *Self) ?[]<span class="tok-kw">const</span> T {</span>
<span class="line" id="L2039">            <span class="tok-kw">const</span> end = self.index <span class="tok-kw">orelse</span> <span class="tok-kw">return</span> <span class="tok-null">null</span>;</span>
<span class="line" id="L2040">            <span class="tok-kw">const</span> start = <span class="tok-kw">if</span> (lastIndexOf(T, self.buffer[<span class="tok-number">0</span>..end], self.delimiter)) |delim_start| blk: {</span>
<span class="line" id="L2041">                self.index = delim_start;</span>
<span class="line" id="L2042">                <span class="tok-kw">break</span> :blk delim_start + self.delimiter.len;</span>
<span class="line" id="L2043">            } <span class="tok-kw">else</span> blk: {</span>
<span class="line" id="L2044">                self.index = <span class="tok-null">null</span>;</span>
<span class="line" id="L2045">                <span class="tok-kw">break</span> :blk <span class="tok-number">0</span>;</span>
<span class="line" id="L2046">            };</span>
<span class="line" id="L2047">            <span class="tok-kw">return</span> self.buffer[start..end];</span>
<span class="line" id="L2048">        }</span>
<span class="line" id="L2049"></span>
<span class="line" id="L2050">        <span class="tok-comment">/// Returns a slice of the remaining bytes. Does not affect iterator state.</span></span>
<span class="line" id="L2051">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">rest</span>(self: Self) []<span class="tok-kw">const</span> T {</span>
<span class="line" id="L2052">            <span class="tok-kw">const</span> end = self.index <span class="tok-kw">orelse</span> <span class="tok-number">0</span>;</span>
<span class="line" id="L2053">            <span class="tok-kw">return</span> self.buffer[<span class="tok-number">0</span>..end];</span>
<span class="line" id="L2054">        }</span>
<span class="line" id="L2055"></span>
<span class="line" id="L2056">        <span class="tok-comment">/// Resets the iterator to the initial slice.</span></span>
<span class="line" id="L2057">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">reset</span>(self: *Self) <span class="tok-type">void</span> {</span>
<span class="line" id="L2058">            self.index = self.buffer.len;</span>
<span class="line" id="L2059">        }</span>
<span class="line" id="L2060">    };</span>
<span class="line" id="L2061">}</span>
<span class="line" id="L2062"></span>
<span class="line" id="L2063"><span class="tok-comment">/// Naively combines a series of slices with a separator.</span></span>
<span class="line" id="L2064"><span class="tok-comment">/// Allocates memory for the result, which must be freed by the caller.</span></span>
<span class="line" id="L2065"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">join</span>(allocator: Allocator, separator: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, slices: []<span class="tok-kw">const</span> []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) ![]<span class="tok-type">u8</span> {</span>
<span class="line" id="L2066">    <span class="tok-kw">return</span> joinMaybeZ(allocator, separator, slices, <span class="tok-null">false</span>);</span>
<span class="line" id="L2067">}</span>
<span class="line" id="L2068"></span>
<span class="line" id="L2069"><span class="tok-comment">/// Naively combines a series of slices with a separator and null terminator.</span></span>
<span class="line" id="L2070"><span class="tok-comment">/// Allocates memory for the result, which must be freed by the caller.</span></span>
<span class="line" id="L2071"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">joinZ</span>(allocator: Allocator, separator: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, slices: []<span class="tok-kw">const</span> []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) ![:<span class="tok-number">0</span>]<span class="tok-type">u8</span> {</span>
<span class="line" id="L2072">    <span class="tok-kw">const</span> out = <span class="tok-kw">try</span> joinMaybeZ(allocator, separator, slices, <span class="tok-null">true</span>);</span>
<span class="line" id="L2073">    <span class="tok-kw">return</span> out[<span class="tok-number">0</span> .. out.len - <span class="tok-number">1</span> :<span class="tok-number">0</span>];</span>
<span class="line" id="L2074">}</span>
<span class="line" id="L2075"></span>
<span class="line" id="L2076"><span class="tok-kw">fn</span> <span class="tok-fn">joinMaybeZ</span>(allocator: Allocator, separator: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, slices: []<span class="tok-kw">const</span> []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, zero: <span class="tok-type">bool</span>) ![]<span class="tok-type">u8</span> {</span>
<span class="line" id="L2077">    <span class="tok-kw">if</span> (slices.len == <span class="tok-number">0</span>) <span class="tok-kw">return</span> <span class="tok-kw">if</span> (zero) <span class="tok-kw">try</span> allocator.dupe(<span class="tok-type">u8</span>, &amp;[<span class="tok-number">1</span>]<span class="tok-type">u8</span>{<span class="tok-number">0</span>}) <span class="tok-kw">else</span> &amp;[<span class="tok-number">0</span>]<span class="tok-type">u8</span>{};</span>
<span class="line" id="L2078"></span>
<span class="line" id="L2079">    <span class="tok-kw">const</span> total_len = blk: {</span>
<span class="line" id="L2080">        <span class="tok-kw">var</span> sum: <span class="tok-type">usize</span> = separator.len * (slices.len - <span class="tok-number">1</span>);</span>
<span class="line" id="L2081">        <span class="tok-kw">for</span> (slices) |slice| sum += slice.len;</span>
<span class="line" id="L2082">        <span class="tok-kw">if</span> (zero) sum += <span class="tok-number">1</span>;</span>
<span class="line" id="L2083">        <span class="tok-kw">break</span> :blk sum;</span>
<span class="line" id="L2084">    };</span>
<span class="line" id="L2085"></span>
<span class="line" id="L2086">    <span class="tok-kw">const</span> buf = <span class="tok-kw">try</span> allocator.alloc(<span class="tok-type">u8</span>, total_len);</span>
<span class="line" id="L2087">    <span class="tok-kw">errdefer</span> allocator.free(buf);</span>
<span class="line" id="L2088"></span>
<span class="line" id="L2089">    copy(<span class="tok-type">u8</span>, buf, slices[<span class="tok-number">0</span>]);</span>
<span class="line" id="L2090">    <span class="tok-kw">var</span> buf_index: <span class="tok-type">usize</span> = slices[<span class="tok-number">0</span>].len;</span>
<span class="line" id="L2091">    <span class="tok-kw">for</span> (slices[<span class="tok-number">1</span>..]) |slice| {</span>
<span class="line" id="L2092">        copy(<span class="tok-type">u8</span>, buf[buf_index..], separator);</span>
<span class="line" id="L2093">        buf_index += separator.len;</span>
<span class="line" id="L2094">        copy(<span class="tok-type">u8</span>, buf[buf_index..], slice);</span>
<span class="line" id="L2095">        buf_index += slice.len;</span>
<span class="line" id="L2096">    }</span>
<span class="line" id="L2097"></span>
<span class="line" id="L2098">    <span class="tok-kw">if</span> (zero) buf[buf.len - <span class="tok-number">1</span>] = <span class="tok-number">0</span>;</span>
<span class="line" id="L2099"></span>
<span class="line" id="L2100">    <span class="tok-comment">// No need for shrink since buf is exactly the correct size.</span>
</span>
<span class="line" id="L2101">    <span class="tok-kw">return</span> buf;</span>
<span class="line" id="L2102">}</span>
<span class="line" id="L2103"></span>
<span class="line" id="L2104"><span class="tok-kw">test</span> <span class="tok-str">&quot;join&quot;</span> {</span>
<span class="line" id="L2105">    {</span>
<span class="line" id="L2106">        <span class="tok-kw">const</span> str = <span class="tok-kw">try</span> join(testing.allocator, <span class="tok-str">&quot;,&quot;</span>, &amp;[_][]<span class="tok-kw">const</span> <span class="tok-type">u8</span>{});</span>
<span class="line" id="L2107">        <span class="tok-kw">defer</span> testing.allocator.free(str);</span>
<span class="line" id="L2108">        <span class="tok-kw">try</span> testing.expect(eql(<span class="tok-type">u8</span>, str, <span class="tok-str">&quot;&quot;</span>));</span>
<span class="line" id="L2109">    }</span>
<span class="line" id="L2110">    {</span>
<span class="line" id="L2111">        <span class="tok-kw">const</span> str = <span class="tok-kw">try</span> join(testing.allocator, <span class="tok-str">&quot;,&quot;</span>, &amp;[_][]<span class="tok-kw">const</span> <span class="tok-type">u8</span>{ <span class="tok-str">&quot;a&quot;</span>, <span class="tok-str">&quot;b&quot;</span>, <span class="tok-str">&quot;c&quot;</span> });</span>
<span class="line" id="L2112">        <span class="tok-kw">defer</span> testing.allocator.free(str);</span>
<span class="line" id="L2113">        <span class="tok-kw">try</span> testing.expect(eql(<span class="tok-type">u8</span>, str, <span class="tok-str">&quot;a,b,c&quot;</span>));</span>
<span class="line" id="L2114">    }</span>
<span class="line" id="L2115">    {</span>
<span class="line" id="L2116">        <span class="tok-kw">const</span> str = <span class="tok-kw">try</span> join(testing.allocator, <span class="tok-str">&quot;,&quot;</span>, &amp;[_][]<span class="tok-kw">const</span> <span class="tok-type">u8</span>{<span class="tok-str">&quot;a&quot;</span>});</span>
<span class="line" id="L2117">        <span class="tok-kw">defer</span> testing.allocator.free(str);</span>
<span class="line" id="L2118">        <span class="tok-kw">try</span> testing.expect(eql(<span class="tok-type">u8</span>, str, <span class="tok-str">&quot;a&quot;</span>));</span>
<span class="line" id="L2119">    }</span>
<span class="line" id="L2120">    {</span>
<span class="line" id="L2121">        <span class="tok-kw">const</span> str = <span class="tok-kw">try</span> join(testing.allocator, <span class="tok-str">&quot;,&quot;</span>, &amp;[_][]<span class="tok-kw">const</span> <span class="tok-type">u8</span>{ <span class="tok-str">&quot;a&quot;</span>, <span class="tok-str">&quot;&quot;</span>, <span class="tok-str">&quot;b&quot;</span>, <span class="tok-str">&quot;&quot;</span>, <span class="tok-str">&quot;c&quot;</span> });</span>
<span class="line" id="L2122">        <span class="tok-kw">defer</span> testing.allocator.free(str);</span>
<span class="line" id="L2123">        <span class="tok-kw">try</span> testing.expect(eql(<span class="tok-type">u8</span>, str, <span class="tok-str">&quot;a,,b,,c&quot;</span>));</span>
<span class="line" id="L2124">    }</span>
<span class="line" id="L2125">}</span>
<span class="line" id="L2126"></span>
<span class="line" id="L2127"><span class="tok-kw">test</span> <span class="tok-str">&quot;joinZ&quot;</span> {</span>
<span class="line" id="L2128">    {</span>
<span class="line" id="L2129">        <span class="tok-kw">const</span> str = <span class="tok-kw">try</span> joinZ(testing.allocator, <span class="tok-str">&quot;,&quot;</span>, &amp;[_][]<span class="tok-kw">const</span> <span class="tok-type">u8</span>{});</span>
<span class="line" id="L2130">        <span class="tok-kw">defer</span> testing.allocator.free(str);</span>
<span class="line" id="L2131">        <span class="tok-kw">try</span> testing.expect(eql(<span class="tok-type">u8</span>, str, <span class="tok-str">&quot;&quot;</span>));</span>
<span class="line" id="L2132">        <span class="tok-kw">try</span> testing.expectEqual(str[str.len], <span class="tok-number">0</span>);</span>
<span class="line" id="L2133">    }</span>
<span class="line" id="L2134">    {</span>
<span class="line" id="L2135">        <span class="tok-kw">const</span> str = <span class="tok-kw">try</span> joinZ(testing.allocator, <span class="tok-str">&quot;,&quot;</span>, &amp;[_][]<span class="tok-kw">const</span> <span class="tok-type">u8</span>{ <span class="tok-str">&quot;a&quot;</span>, <span class="tok-str">&quot;b&quot;</span>, <span class="tok-str">&quot;c&quot;</span> });</span>
<span class="line" id="L2136">        <span class="tok-kw">defer</span> testing.allocator.free(str);</span>
<span class="line" id="L2137">        <span class="tok-kw">try</span> testing.expect(eql(<span class="tok-type">u8</span>, str, <span class="tok-str">&quot;a,b,c&quot;</span>));</span>
<span class="line" id="L2138">        <span class="tok-kw">try</span> testing.expectEqual(str[str.len], <span class="tok-number">0</span>);</span>
<span class="line" id="L2139">    }</span>
<span class="line" id="L2140">    {</span>
<span class="line" id="L2141">        <span class="tok-kw">const</span> str = <span class="tok-kw">try</span> joinZ(testing.allocator, <span class="tok-str">&quot;,&quot;</span>, &amp;[_][]<span class="tok-kw">const</span> <span class="tok-type">u8</span>{<span class="tok-str">&quot;a&quot;</span>});</span>
<span class="line" id="L2142">        <span class="tok-kw">defer</span> testing.allocator.free(str);</span>
<span class="line" id="L2143">        <span class="tok-kw">try</span> testing.expect(eql(<span class="tok-type">u8</span>, str, <span class="tok-str">&quot;a&quot;</span>));</span>
<span class="line" id="L2144">        <span class="tok-kw">try</span> testing.expectEqual(str[str.len], <span class="tok-number">0</span>);</span>
<span class="line" id="L2145">    }</span>
<span class="line" id="L2146">    {</span>
<span class="line" id="L2147">        <span class="tok-kw">const</span> str = <span class="tok-kw">try</span> joinZ(testing.allocator, <span class="tok-str">&quot;,&quot;</span>, &amp;[_][]<span class="tok-kw">const</span> <span class="tok-type">u8</span>{ <span class="tok-str">&quot;a&quot;</span>, <span class="tok-str">&quot;&quot;</span>, <span class="tok-str">&quot;b&quot;</span>, <span class="tok-str">&quot;&quot;</span>, <span class="tok-str">&quot;c&quot;</span> });</span>
<span class="line" id="L2148">        <span class="tok-kw">defer</span> testing.allocator.free(str);</span>
<span class="line" id="L2149">        <span class="tok-kw">try</span> testing.expect(eql(<span class="tok-type">u8</span>, str, <span class="tok-str">&quot;a,,b,,c&quot;</span>));</span>
<span class="line" id="L2150">        <span class="tok-kw">try</span> testing.expectEqual(str[str.len], <span class="tok-number">0</span>);</span>
<span class="line" id="L2151">    }</span>
<span class="line" id="L2152">}</span>
<span class="line" id="L2153"></span>
<span class="line" id="L2154"><span class="tok-comment">/// Copies each T from slices into a new slice that exactly holds all the elements.</span></span>
<span class="line" id="L2155"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">concat</span>(allocator: Allocator, <span class="tok-kw">comptime</span> T: <span class="tok-type">type</span>, slices: []<span class="tok-kw">const</span> []<span class="tok-kw">const</span> T) ![]T {</span>
<span class="line" id="L2156">    <span class="tok-kw">return</span> concatMaybeSentinel(allocator, T, slices, <span class="tok-null">null</span>);</span>
<span class="line" id="L2157">}</span>
<span class="line" id="L2158"></span>
<span class="line" id="L2159"><span class="tok-comment">/// Copies each T from slices into a new slice that exactly holds all the elements.</span></span>
<span class="line" id="L2160"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">concatWithSentinel</span>(allocator: Allocator, <span class="tok-kw">comptime</span> T: <span class="tok-type">type</span>, slices: []<span class="tok-kw">const</span> []<span class="tok-kw">const</span> T, <span class="tok-kw">comptime</span> s: T) ![:s]T {</span>
<span class="line" id="L2161">    <span class="tok-kw">const</span> ret = <span class="tok-kw">try</span> concatMaybeSentinel(allocator, T, slices, s);</span>
<span class="line" id="L2162">    <span class="tok-kw">return</span> ret[<span class="tok-number">0</span> .. ret.len - <span class="tok-number">1</span> :s];</span>
<span class="line" id="L2163">}</span>
<span class="line" id="L2164"></span>
<span class="line" id="L2165"><span class="tok-comment">/// Copies each T from slices into a new slice that exactly holds all the elements as well as the sentinel.</span></span>
<span class="line" id="L2166"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">concatMaybeSentinel</span>(allocator: Allocator, <span class="tok-kw">comptime</span> T: <span class="tok-type">type</span>, slices: []<span class="tok-kw">const</span> []<span class="tok-kw">const</span> T, <span class="tok-kw">comptime</span> s: ?T) ![]T {</span>
<span class="line" id="L2167">    <span class="tok-kw">if</span> (slices.len == <span class="tok-number">0</span>) <span class="tok-kw">return</span> <span class="tok-kw">if</span> (s) |sentinel| <span class="tok-kw">try</span> allocator.dupe(T, &amp;[<span class="tok-number">1</span>]T{sentinel}) <span class="tok-kw">else</span> &amp;[<span class="tok-number">0</span>]T{};</span>
<span class="line" id="L2168"></span>
<span class="line" id="L2169">    <span class="tok-kw">const</span> total_len = blk: {</span>
<span class="line" id="L2170">        <span class="tok-kw">var</span> sum: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L2171">        <span class="tok-kw">for</span> (slices) |slice| {</span>
<span class="line" id="L2172">            sum += slice.len;</span>
<span class="line" id="L2173">        }</span>
<span class="line" id="L2174"></span>
<span class="line" id="L2175">        <span class="tok-kw">if</span> (s) |_| {</span>
<span class="line" id="L2176">            sum += <span class="tok-number">1</span>;</span>
<span class="line" id="L2177">        }</span>
<span class="line" id="L2178"></span>
<span class="line" id="L2179">        <span class="tok-kw">break</span> :blk sum;</span>
<span class="line" id="L2180">    };</span>
<span class="line" id="L2181"></span>
<span class="line" id="L2182">    <span class="tok-kw">const</span> buf = <span class="tok-kw">try</span> allocator.alloc(T, total_len);</span>
<span class="line" id="L2183">    <span class="tok-kw">errdefer</span> allocator.free(buf);</span>
<span class="line" id="L2184"></span>
<span class="line" id="L2185">    <span class="tok-kw">var</span> buf_index: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L2186">    <span class="tok-kw">for</span> (slices) |slice| {</span>
<span class="line" id="L2187">        copy(T, buf[buf_index..], slice);</span>
<span class="line" id="L2188">        buf_index += slice.len;</span>
<span class="line" id="L2189">    }</span>
<span class="line" id="L2190"></span>
<span class="line" id="L2191">    <span class="tok-kw">if</span> (s) |sentinel| {</span>
<span class="line" id="L2192">        buf[buf.len - <span class="tok-number">1</span>] = sentinel;</span>
<span class="line" id="L2193">    }</span>
<span class="line" id="L2194"></span>
<span class="line" id="L2195">    <span class="tok-comment">// No need for shrink since buf is exactly the correct size.</span>
</span>
<span class="line" id="L2196">    <span class="tok-kw">return</span> buf;</span>
<span class="line" id="L2197">}</span>
<span class="line" id="L2198"></span>
<span class="line" id="L2199"><span class="tok-kw">test</span> <span class="tok-str">&quot;concat&quot;</span> {</span>
<span class="line" id="L2200">    {</span>
<span class="line" id="L2201">        <span class="tok-kw">const</span> str = <span class="tok-kw">try</span> concat(testing.allocator, <span class="tok-type">u8</span>, &amp;[_][]<span class="tok-kw">const</span> <span class="tok-type">u8</span>{ <span class="tok-str">&quot;abc&quot;</span>, <span class="tok-str">&quot;def&quot;</span>, <span class="tok-str">&quot;ghi&quot;</span> });</span>
<span class="line" id="L2202">        <span class="tok-kw">defer</span> testing.allocator.free(str);</span>
<span class="line" id="L2203">        <span class="tok-kw">try</span> testing.expect(eql(<span class="tok-type">u8</span>, str, <span class="tok-str">&quot;abcdefghi&quot;</span>));</span>
<span class="line" id="L2204">    }</span>
<span class="line" id="L2205">    {</span>
<span class="line" id="L2206">        <span class="tok-kw">const</span> str = <span class="tok-kw">try</span> concat(testing.allocator, <span class="tok-type">u32</span>, &amp;[_][]<span class="tok-kw">const</span> <span class="tok-type">u32</span>{</span>
<span class="line" id="L2207">            &amp;[_]<span class="tok-type">u32</span>{ <span class="tok-number">0</span>, <span class="tok-number">1</span> },</span>
<span class="line" id="L2208">            &amp;[_]<span class="tok-type">u32</span>{ <span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">4</span> },</span>
<span class="line" id="L2209">            &amp;[_]<span class="tok-type">u32</span>{},</span>
<span class="line" id="L2210">            &amp;[_]<span class="tok-type">u32</span>{<span class="tok-number">5</span>},</span>
<span class="line" id="L2211">        });</span>
<span class="line" id="L2212">        <span class="tok-kw">defer</span> testing.allocator.free(str);</span>
<span class="line" id="L2213">        <span class="tok-kw">try</span> testing.expect(eql(<span class="tok-type">u32</span>, str, &amp;[_]<span class="tok-type">u32</span>{ <span class="tok-number">0</span>, <span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">4</span>, <span class="tok-number">5</span> }));</span>
<span class="line" id="L2214">    }</span>
<span class="line" id="L2215">    {</span>
<span class="line" id="L2216">        <span class="tok-kw">const</span> str = <span class="tok-kw">try</span> concatWithSentinel(testing.allocator, <span class="tok-type">u8</span>, &amp;[_][]<span class="tok-kw">const</span> <span class="tok-type">u8</span>{ <span class="tok-str">&quot;abc&quot;</span>, <span class="tok-str">&quot;def&quot;</span>, <span class="tok-str">&quot;ghi&quot;</span> }, <span class="tok-number">0</span>);</span>
<span class="line" id="L2217">        <span class="tok-kw">defer</span> testing.allocator.free(str);</span>
<span class="line" id="L2218">        <span class="tok-kw">try</span> testing.expectEqualSentinel(<span class="tok-type">u8</span>, <span class="tok-number">0</span>, str, <span class="tok-str">&quot;abcdefghi&quot;</span>);</span>
<span class="line" id="L2219">    }</span>
<span class="line" id="L2220">    {</span>
<span class="line" id="L2221">        <span class="tok-kw">const</span> slice = <span class="tok-kw">try</span> concatWithSentinel(testing.allocator, <span class="tok-type">u8</span>, &amp;[_][]<span class="tok-kw">const</span> <span class="tok-type">u8</span>{}, <span class="tok-number">0</span>);</span>
<span class="line" id="L2222">        <span class="tok-kw">defer</span> testing.allocator.free(slice);</span>
<span class="line" id="L2223">        <span class="tok-kw">try</span> testing.expectEqualSentinel(<span class="tok-type">u8</span>, <span class="tok-number">0</span>, slice, &amp;[_:<span class="tok-number">0</span>]<span class="tok-type">u8</span>{});</span>
<span class="line" id="L2224">    }</span>
<span class="line" id="L2225">    {</span>
<span class="line" id="L2226">        <span class="tok-kw">const</span> slice = <span class="tok-kw">try</span> concatWithSentinel(testing.allocator, <span class="tok-type">u32</span>, &amp;[_][]<span class="tok-kw">const</span> <span class="tok-type">u32</span>{</span>
<span class="line" id="L2227">            &amp;[_]<span class="tok-type">u32</span>{ <span class="tok-number">0</span>, <span class="tok-number">1</span> },</span>
<span class="line" id="L2228">            &amp;[_]<span class="tok-type">u32</span>{ <span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">4</span> },</span>
<span class="line" id="L2229">            &amp;[_]<span class="tok-type">u32</span>{},</span>
<span class="line" id="L2230">            &amp;[_]<span class="tok-type">u32</span>{<span class="tok-number">5</span>},</span>
<span class="line" id="L2231">        }, <span class="tok-number">2</span>);</span>
<span class="line" id="L2232">        <span class="tok-kw">defer</span> testing.allocator.free(slice);</span>
<span class="line" id="L2233">        <span class="tok-kw">try</span> testing.expectEqualSentinel(<span class="tok-type">u32</span>, <span class="tok-number">2</span>, slice, &amp;[_:<span class="tok-number">2</span>]<span class="tok-type">u32</span>{ <span class="tok-number">0</span>, <span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">4</span>, <span class="tok-number">5</span> });</span>
<span class="line" id="L2234">    }</span>
<span class="line" id="L2235">}</span>
<span class="line" id="L2236"></span>
<span class="line" id="L2237"><span class="tok-kw">test</span> <span class="tok-str">&quot;testStringEquality&quot;</span> {</span>
<span class="line" id="L2238">    <span class="tok-kw">try</span> testing.expect(eql(<span class="tok-type">u8</span>, <span class="tok-str">&quot;abcd&quot;</span>, <span class="tok-str">&quot;abcd&quot;</span>));</span>
<span class="line" id="L2239">    <span class="tok-kw">try</span> testing.expect(!eql(<span class="tok-type">u8</span>, <span class="tok-str">&quot;abcdef&quot;</span>, <span class="tok-str">&quot;abZdef&quot;</span>));</span>
<span class="line" id="L2240">    <span class="tok-kw">try</span> testing.expect(!eql(<span class="tok-type">u8</span>, <span class="tok-str">&quot;abcdefg&quot;</span>, <span class="tok-str">&quot;abcdef&quot;</span>));</span>
<span class="line" id="L2241">}</span>
<span class="line" id="L2242"></span>
<span class="line" id="L2243"><span class="tok-kw">test</span> <span class="tok-str">&quot;testReadInt&quot;</span> {</span>
<span class="line" id="L2244">    <span class="tok-kw">try</span> testReadIntImpl();</span>
<span class="line" id="L2245">    <span class="tok-kw">comptime</span> <span class="tok-kw">try</span> testReadIntImpl();</span>
<span class="line" id="L2246">}</span>
<span class="line" id="L2247"><span class="tok-kw">fn</span> <span class="tok-fn">testReadIntImpl</span>() !<span class="tok-type">void</span> {</span>
<span class="line" id="L2248">    {</span>
<span class="line" id="L2249">        <span class="tok-kw">const</span> bytes = [_]<span class="tok-type">u8</span>{</span>
<span class="line" id="L2250">            <span class="tok-number">0x12</span>,</span>
<span class="line" id="L2251">            <span class="tok-number">0x34</span>,</span>
<span class="line" id="L2252">            <span class="tok-number">0x56</span>,</span>
<span class="line" id="L2253">            <span class="tok-number">0x78</span>,</span>
<span class="line" id="L2254">        };</span>
<span class="line" id="L2255">        <span class="tok-kw">try</span> testing.expect(readInt(<span class="tok-type">u32</span>, &amp;bytes, Endian.Big) == <span class="tok-number">0x12345678</span>);</span>
<span class="line" id="L2256">        <span class="tok-kw">try</span> testing.expect(readIntBig(<span class="tok-type">u32</span>, &amp;bytes) == <span class="tok-number">0x12345678</span>);</span>
<span class="line" id="L2257">        <span class="tok-kw">try</span> testing.expect(readIntBig(<span class="tok-type">i32</span>, &amp;bytes) == <span class="tok-number">0x12345678</span>);</span>
<span class="line" id="L2258">        <span class="tok-kw">try</span> testing.expect(readInt(<span class="tok-type">u32</span>, &amp;bytes, Endian.Little) == <span class="tok-number">0x78563412</span>);</span>
<span class="line" id="L2259">        <span class="tok-kw">try</span> testing.expect(readIntLittle(<span class="tok-type">u32</span>, &amp;bytes) == <span class="tok-number">0x78563412</span>);</span>
<span class="line" id="L2260">        <span class="tok-kw">try</span> testing.expect(readIntLittle(<span class="tok-type">i32</span>, &amp;bytes) == <span class="tok-number">0x78563412</span>);</span>
<span class="line" id="L2261">    }</span>
<span class="line" id="L2262">    {</span>
<span class="line" id="L2263">        <span class="tok-kw">const</span> buf = [_]<span class="tok-type">u8</span>{</span>
<span class="line" id="L2264">            <span class="tok-number">0x00</span>,</span>
<span class="line" id="L2265">            <span class="tok-number">0x00</span>,</span>
<span class="line" id="L2266">            <span class="tok-number">0x12</span>,</span>
<span class="line" id="L2267">            <span class="tok-number">0x34</span>,</span>
<span class="line" id="L2268">        };</span>
<span class="line" id="L2269">        <span class="tok-kw">const</span> answer = readInt(<span class="tok-type">u32</span>, &amp;buf, Endian.Big);</span>
<span class="line" id="L2270">        <span class="tok-kw">try</span> testing.expect(answer == <span class="tok-number">0x00001234</span>);</span>
<span class="line" id="L2271">    }</span>
<span class="line" id="L2272">    {</span>
<span class="line" id="L2273">        <span class="tok-kw">const</span> buf = [_]<span class="tok-type">u8</span>{</span>
<span class="line" id="L2274">            <span class="tok-number">0x12</span>,</span>
<span class="line" id="L2275">            <span class="tok-number">0x34</span>,</span>
<span class="line" id="L2276">            <span class="tok-number">0x00</span>,</span>
<span class="line" id="L2277">            <span class="tok-number">0x00</span>,</span>
<span class="line" id="L2278">        };</span>
<span class="line" id="L2279">        <span class="tok-kw">const</span> answer = readInt(<span class="tok-type">u32</span>, &amp;buf, Endian.Little);</span>
<span class="line" id="L2280">        <span class="tok-kw">try</span> testing.expect(answer == <span class="tok-number">0x00003412</span>);</span>
<span class="line" id="L2281">    }</span>
<span class="line" id="L2282">    {</span>
<span class="line" id="L2283">        <span class="tok-kw">const</span> bytes = [_]<span class="tok-type">u8</span>{</span>
<span class="line" id="L2284">            <span class="tok-number">0xff</span>,</span>
<span class="line" id="L2285">            <span class="tok-number">0xfe</span>,</span>
<span class="line" id="L2286">        };</span>
<span class="line" id="L2287">        <span class="tok-kw">try</span> testing.expect(readIntBig(<span class="tok-type">u16</span>, &amp;bytes) == <span class="tok-number">0xfffe</span>);</span>
<span class="line" id="L2288">        <span class="tok-kw">try</span> testing.expect(readIntBig(<span class="tok-type">i16</span>, &amp;bytes) == -<span class="tok-number">0x0002</span>);</span>
<span class="line" id="L2289">        <span class="tok-kw">try</span> testing.expect(readIntLittle(<span class="tok-type">u16</span>, &amp;bytes) == <span class="tok-number">0xfeff</span>);</span>
<span class="line" id="L2290">        <span class="tok-kw">try</span> testing.expect(readIntLittle(<span class="tok-type">i16</span>, &amp;bytes) == -<span class="tok-number">0x0101</span>);</span>
<span class="line" id="L2291">    }</span>
<span class="line" id="L2292">}</span>
<span class="line" id="L2293"></span>
<span class="line" id="L2294"><span class="tok-kw">test</span> <span class="tok-str">&quot;writeIntSlice&quot;</span> {</span>
<span class="line" id="L2295">    <span class="tok-kw">try</span> testWriteIntImpl();</span>
<span class="line" id="L2296">    <span class="tok-kw">comptime</span> <span class="tok-kw">try</span> testWriteIntImpl();</span>
<span class="line" id="L2297">}</span>
<span class="line" id="L2298"><span class="tok-kw">fn</span> <span class="tok-fn">testWriteIntImpl</span>() !<span class="tok-type">void</span> {</span>
<span class="line" id="L2299">    <span class="tok-kw">var</span> bytes: [<span class="tok-number">8</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L2300"></span>
<span class="line" id="L2301">    writeIntSlice(<span class="tok-type">u0</span>, bytes[<span class="tok-number">0</span>..], <span class="tok-number">0</span>, Endian.Big);</span>
<span class="line" id="L2302">    <span class="tok-kw">try</span> testing.expect(eql(<span class="tok-type">u8</span>, &amp;bytes, &amp;[_]<span class="tok-type">u8</span>{</span>
<span class="line" id="L2303">        <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>,</span>
<span class="line" id="L2304">        <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>,</span>
<span class="line" id="L2305">    }));</span>
<span class="line" id="L2306"></span>
<span class="line" id="L2307">    writeIntSlice(<span class="tok-type">u0</span>, bytes[<span class="tok-number">0</span>..], <span class="tok-number">0</span>, Endian.Little);</span>
<span class="line" id="L2308">    <span class="tok-kw">try</span> testing.expect(eql(<span class="tok-type">u8</span>, &amp;bytes, &amp;[_]<span class="tok-type">u8</span>{</span>
<span class="line" id="L2309">        <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>,</span>
<span class="line" id="L2310">        <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>,</span>
<span class="line" id="L2311">    }));</span>
<span class="line" id="L2312"></span>
<span class="line" id="L2313">    writeIntSlice(<span class="tok-type">u64</span>, bytes[<span class="tok-number">0</span>..], <span class="tok-number">0x12345678CAFEBABE</span>, Endian.Big);</span>
<span class="line" id="L2314">    <span class="tok-kw">try</span> testing.expect(eql(<span class="tok-type">u8</span>, &amp;bytes, &amp;[_]<span class="tok-type">u8</span>{</span>
<span class="line" id="L2315">        <span class="tok-number">0x12</span>,</span>
<span class="line" id="L2316">        <span class="tok-number">0x34</span>,</span>
<span class="line" id="L2317">        <span class="tok-number">0x56</span>,</span>
<span class="line" id="L2318">        <span class="tok-number">0x78</span>,</span>
<span class="line" id="L2319">        <span class="tok-number">0xCA</span>,</span>
<span class="line" id="L2320">        <span class="tok-number">0xFE</span>,</span>
<span class="line" id="L2321">        <span class="tok-number">0xBA</span>,</span>
<span class="line" id="L2322">        <span class="tok-number">0xBE</span>,</span>
<span class="line" id="L2323">    }));</span>
<span class="line" id="L2324"></span>
<span class="line" id="L2325">    writeIntSlice(<span class="tok-type">u64</span>, bytes[<span class="tok-number">0</span>..], <span class="tok-number">0xBEBAFECA78563412</span>, Endian.Little);</span>
<span class="line" id="L2326">    <span class="tok-kw">try</span> testing.expect(eql(<span class="tok-type">u8</span>, &amp;bytes, &amp;[_]<span class="tok-type">u8</span>{</span>
<span class="line" id="L2327">        <span class="tok-number">0x12</span>,</span>
<span class="line" id="L2328">        <span class="tok-number">0x34</span>,</span>
<span class="line" id="L2329">        <span class="tok-number">0x56</span>,</span>
<span class="line" id="L2330">        <span class="tok-number">0x78</span>,</span>
<span class="line" id="L2331">        <span class="tok-number">0xCA</span>,</span>
<span class="line" id="L2332">        <span class="tok-number">0xFE</span>,</span>
<span class="line" id="L2333">        <span class="tok-number">0xBA</span>,</span>
<span class="line" id="L2334">        <span class="tok-number">0xBE</span>,</span>
<span class="line" id="L2335">    }));</span>
<span class="line" id="L2336"></span>
<span class="line" id="L2337">    writeIntSlice(<span class="tok-type">u32</span>, bytes[<span class="tok-number">0</span>..], <span class="tok-number">0x12345678</span>, Endian.Big);</span>
<span class="line" id="L2338">    <span class="tok-kw">try</span> testing.expect(eql(<span class="tok-type">u8</span>, &amp;bytes, &amp;[_]<span class="tok-type">u8</span>{</span>
<span class="line" id="L2339">        <span class="tok-number">0x00</span>,</span>
<span class="line" id="L2340">        <span class="tok-number">0x00</span>,</span>
<span class="line" id="L2341">        <span class="tok-number">0x00</span>,</span>
<span class="line" id="L2342">        <span class="tok-number">0x00</span>,</span>
<span class="line" id="L2343">        <span class="tok-number">0x12</span>,</span>
<span class="line" id="L2344">        <span class="tok-number">0x34</span>,</span>
<span class="line" id="L2345">        <span class="tok-number">0x56</span>,</span>
<span class="line" id="L2346">        <span class="tok-number">0x78</span>,</span>
<span class="line" id="L2347">    }));</span>
<span class="line" id="L2348"></span>
<span class="line" id="L2349">    writeIntSlice(<span class="tok-type">u32</span>, bytes[<span class="tok-number">0</span>..], <span class="tok-number">0x78563412</span>, Endian.Little);</span>
<span class="line" id="L2350">    <span class="tok-kw">try</span> testing.expect(eql(<span class="tok-type">u8</span>, &amp;bytes, &amp;[_]<span class="tok-type">u8</span>{</span>
<span class="line" id="L2351">        <span class="tok-number">0x12</span>,</span>
<span class="line" id="L2352">        <span class="tok-number">0x34</span>,</span>
<span class="line" id="L2353">        <span class="tok-number">0x56</span>,</span>
<span class="line" id="L2354">        <span class="tok-number">0x78</span>,</span>
<span class="line" id="L2355">        <span class="tok-number">0x00</span>,</span>
<span class="line" id="L2356">        <span class="tok-number">0x00</span>,</span>
<span class="line" id="L2357">        <span class="tok-number">0x00</span>,</span>
<span class="line" id="L2358">        <span class="tok-number">0x00</span>,</span>
<span class="line" id="L2359">    }));</span>
<span class="line" id="L2360"></span>
<span class="line" id="L2361">    writeIntSlice(<span class="tok-type">u16</span>, bytes[<span class="tok-number">0</span>..], <span class="tok-number">0x1234</span>, Endian.Big);</span>
<span class="line" id="L2362">    <span class="tok-kw">try</span> testing.expect(eql(<span class="tok-type">u8</span>, &amp;bytes, &amp;[_]<span class="tok-type">u8</span>{</span>
<span class="line" id="L2363">        <span class="tok-number">0x00</span>,</span>
<span class="line" id="L2364">        <span class="tok-number">0x00</span>,</span>
<span class="line" id="L2365">        <span class="tok-number">0x00</span>,</span>
<span class="line" id="L2366">        <span class="tok-number">0x00</span>,</span>
<span class="line" id="L2367">        <span class="tok-number">0x00</span>,</span>
<span class="line" id="L2368">        <span class="tok-number">0x00</span>,</span>
<span class="line" id="L2369">        <span class="tok-number">0x12</span>,</span>
<span class="line" id="L2370">        <span class="tok-number">0x34</span>,</span>
<span class="line" id="L2371">    }));</span>
<span class="line" id="L2372"></span>
<span class="line" id="L2373">    writeIntSlice(<span class="tok-type">u16</span>, bytes[<span class="tok-number">0</span>..], <span class="tok-number">0x1234</span>, Endian.Little);</span>
<span class="line" id="L2374">    <span class="tok-kw">try</span> testing.expect(eql(<span class="tok-type">u8</span>, &amp;bytes, &amp;[_]<span class="tok-type">u8</span>{</span>
<span class="line" id="L2375">        <span class="tok-number">0x34</span>,</span>
<span class="line" id="L2376">        <span class="tok-number">0x12</span>,</span>
<span class="line" id="L2377">        <span class="tok-number">0x00</span>,</span>
<span class="line" id="L2378">        <span class="tok-number">0x00</span>,</span>
<span class="line" id="L2379">        <span class="tok-number">0x00</span>,</span>
<span class="line" id="L2380">        <span class="tok-number">0x00</span>,</span>
<span class="line" id="L2381">        <span class="tok-number">0x00</span>,</span>
<span class="line" id="L2382">        <span class="tok-number">0x00</span>,</span>
<span class="line" id="L2383">    }));</span>
<span class="line" id="L2384"></span>
<span class="line" id="L2385">    writeIntSlice(<span class="tok-type">i16</span>, bytes[<span class="tok-number">0</span>..], <span class="tok-builtin">@as</span>(<span class="tok-type">i16</span>, -<span class="tok-number">21555</span>), Endian.Little);</span>
<span class="line" id="L2386">    <span class="tok-kw">try</span> testing.expect(eql(<span class="tok-type">u8</span>, &amp;bytes, &amp;[_]<span class="tok-type">u8</span>{</span>
<span class="line" id="L2387">        <span class="tok-number">0xCD</span>,</span>
<span class="line" id="L2388">        <span class="tok-number">0xAB</span>,</span>
<span class="line" id="L2389">        <span class="tok-number">0x00</span>,</span>
<span class="line" id="L2390">        <span class="tok-number">0x00</span>,</span>
<span class="line" id="L2391">        <span class="tok-number">0x00</span>,</span>
<span class="line" id="L2392">        <span class="tok-number">0x00</span>,</span>
<span class="line" id="L2393">        <span class="tok-number">0x00</span>,</span>
<span class="line" id="L2394">        <span class="tok-number">0x00</span>,</span>
<span class="line" id="L2395">    }));</span>
<span class="line" id="L2396"></span>
<span class="line" id="L2397">    writeIntSlice(<span class="tok-type">i16</span>, bytes[<span class="tok-number">0</span>..], <span class="tok-builtin">@as</span>(<span class="tok-type">i16</span>, -<span class="tok-number">21555</span>), Endian.Big);</span>
<span class="line" id="L2398">    <span class="tok-kw">try</span> testing.expect(eql(<span class="tok-type">u8</span>, &amp;bytes, &amp;[_]<span class="tok-type">u8</span>{</span>
<span class="line" id="L2399">        <span class="tok-number">0x00</span>,</span>
<span class="line" id="L2400">        <span class="tok-number">0x00</span>,</span>
<span class="line" id="L2401">        <span class="tok-number">0x00</span>,</span>
<span class="line" id="L2402">        <span class="tok-number">0x00</span>,</span>
<span class="line" id="L2403">        <span class="tok-number">0x00</span>,</span>
<span class="line" id="L2404">        <span class="tok-number">0x00</span>,</span>
<span class="line" id="L2405">        <span class="tok-number">0xAB</span>,</span>
<span class="line" id="L2406">        <span class="tok-number">0xCD</span>,</span>
<span class="line" id="L2407">    }));</span>
<span class="line" id="L2408"></span>
<span class="line" id="L2409">    writeIntSlice(<span class="tok-type">u8</span>, bytes[<span class="tok-number">0</span>..], <span class="tok-number">0x12</span>, Endian.Big);</span>
<span class="line" id="L2410">    <span class="tok-kw">try</span> testing.expect(eql(<span class="tok-type">u8</span>, &amp;bytes, &amp;[_]<span class="tok-type">u8</span>{</span>
<span class="line" id="L2411">        <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>,</span>
<span class="line" id="L2412">        <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x12</span>,</span>
<span class="line" id="L2413">    }));</span>
<span class="line" id="L2414"></span>
<span class="line" id="L2415">    writeIntSlice(<span class="tok-type">u8</span>, bytes[<span class="tok-number">0</span>..], <span class="tok-number">0x12</span>, Endian.Little);</span>
<span class="line" id="L2416">    <span class="tok-kw">try</span> testing.expect(eql(<span class="tok-type">u8</span>, &amp;bytes, &amp;[_]<span class="tok-type">u8</span>{</span>
<span class="line" id="L2417">        <span class="tok-number">0x12</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>,</span>
<span class="line" id="L2418">        <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>,</span>
<span class="line" id="L2419">    }));</span>
<span class="line" id="L2420"></span>
<span class="line" id="L2421">    writeIntSlice(<span class="tok-type">i8</span>, bytes[<span class="tok-number">0</span>..], -<span class="tok-number">1</span>, Endian.Big);</span>
<span class="line" id="L2422">    <span class="tok-kw">try</span> testing.expect(eql(<span class="tok-type">u8</span>, &amp;bytes, &amp;[_]<span class="tok-type">u8</span>{</span>
<span class="line" id="L2423">        <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>,</span>
<span class="line" id="L2424">        <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0xff</span>,</span>
<span class="line" id="L2425">    }));</span>
<span class="line" id="L2426"></span>
<span class="line" id="L2427">    writeIntSlice(<span class="tok-type">i8</span>, bytes[<span class="tok-number">0</span>..], -<span class="tok-number">1</span>, Endian.Little);</span>
<span class="line" id="L2428">    <span class="tok-kw">try</span> testing.expect(eql(<span class="tok-type">u8</span>, &amp;bytes, &amp;[_]<span class="tok-type">u8</span>{</span>
<span class="line" id="L2429">        <span class="tok-number">0xff</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>,</span>
<span class="line" id="L2430">        <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>,</span>
<span class="line" id="L2431">    }));</span>
<span class="line" id="L2432">}</span>
<span class="line" id="L2433"></span>
<span class="line" id="L2434"><span class="tok-comment">/// Returns the smallest number in a slice. O(n).</span></span>
<span class="line" id="L2435"><span class="tok-comment">/// `slice` must not be empty.</span></span>
<span class="line" id="L2436"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">min</span>(<span class="tok-kw">comptime</span> T: <span class="tok-type">type</span>, slice: []<span class="tok-kw">const</span> T) T {</span>
<span class="line" id="L2437">    assert(slice.len &gt; <span class="tok-number">0</span>);</span>
<span class="line" id="L2438">    <span class="tok-kw">var</span> best = slice[<span class="tok-number">0</span>];</span>
<span class="line" id="L2439">    <span class="tok-kw">for</span> (slice[<span class="tok-number">1</span>..]) |item| {</span>
<span class="line" id="L2440">        best = math.min(best, item);</span>
<span class="line" id="L2441">    }</span>
<span class="line" id="L2442">    <span class="tok-kw">return</span> best;</span>
<span class="line" id="L2443">}</span>
<span class="line" id="L2444"></span>
<span class="line" id="L2445"><span class="tok-kw">test</span> <span class="tok-str">&quot;min&quot;</span> {</span>
<span class="line" id="L2446">    <span class="tok-kw">try</span> testing.expectEqual(min(<span class="tok-type">u8</span>, <span class="tok-str">&quot;abcdefg&quot;</span>), <span class="tok-str">'a'</span>);</span>
<span class="line" id="L2447">    <span class="tok-kw">try</span> testing.expectEqual(min(<span class="tok-type">u8</span>, <span class="tok-str">&quot;bcdefga&quot;</span>), <span class="tok-str">'a'</span>);</span>
<span class="line" id="L2448">    <span class="tok-kw">try</span> testing.expectEqual(min(<span class="tok-type">u8</span>, <span class="tok-str">&quot;a&quot;</span>), <span class="tok-str">'a'</span>);</span>
<span class="line" id="L2449">}</span>
<span class="line" id="L2450"></span>
<span class="line" id="L2451"><span class="tok-comment">/// Returns the largest number in a slice. O(n).</span></span>
<span class="line" id="L2452"><span class="tok-comment">/// `slice` must not be empty.</span></span>
<span class="line" id="L2453"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">max</span>(<span class="tok-kw">comptime</span> T: <span class="tok-type">type</span>, slice: []<span class="tok-kw">const</span> T) T {</span>
<span class="line" id="L2454">    assert(slice.len &gt; <span class="tok-number">0</span>);</span>
<span class="line" id="L2455">    <span class="tok-kw">var</span> best = slice[<span class="tok-number">0</span>];</span>
<span class="line" id="L2456">    <span class="tok-kw">for</span> (slice[<span class="tok-number">1</span>..]) |item| {</span>
<span class="line" id="L2457">        best = math.max(best, item);</span>
<span class="line" id="L2458">    }</span>
<span class="line" id="L2459">    <span class="tok-kw">return</span> best;</span>
<span class="line" id="L2460">}</span>
<span class="line" id="L2461"></span>
<span class="line" id="L2462"><span class="tok-kw">test</span> <span class="tok-str">&quot;max&quot;</span> {</span>
<span class="line" id="L2463">    <span class="tok-kw">try</span> testing.expectEqual(max(<span class="tok-type">u8</span>, <span class="tok-str">&quot;abcdefg&quot;</span>), <span class="tok-str">'g'</span>);</span>
<span class="line" id="L2464">    <span class="tok-kw">try</span> testing.expectEqual(max(<span class="tok-type">u8</span>, <span class="tok-str">&quot;gabcdef&quot;</span>), <span class="tok-str">'g'</span>);</span>
<span class="line" id="L2465">    <span class="tok-kw">try</span> testing.expectEqual(max(<span class="tok-type">u8</span>, <span class="tok-str">&quot;g&quot;</span>), <span class="tok-str">'g'</span>);</span>
<span class="line" id="L2466">}</span>
<span class="line" id="L2467"></span>
<span class="line" id="L2468"><span class="tok-comment">/// Finds the smallest and largest number in a slice. O(n).</span></span>
<span class="line" id="L2469"><span class="tok-comment">/// Returns an anonymous struct with the fields `min` and `max`.</span></span>
<span class="line" id="L2470"><span class="tok-comment">/// `slice` must not be empty.</span></span>
<span class="line" id="L2471"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">minMax</span>(<span class="tok-kw">comptime</span> T: <span class="tok-type">type</span>, slice: []<span class="tok-kw">const</span> T) <span class="tok-kw">struct</span> { min: T, max: T } {</span>
<span class="line" id="L2472">    assert(slice.len &gt; <span class="tok-number">0</span>);</span>
<span class="line" id="L2473">    <span class="tok-kw">var</span> minVal = slice[<span class="tok-number">0</span>];</span>
<span class="line" id="L2474">    <span class="tok-kw">var</span> maxVal = slice[<span class="tok-number">0</span>];</span>
<span class="line" id="L2475">    <span class="tok-kw">for</span> (slice[<span class="tok-number">1</span>..]) |item| {</span>
<span class="line" id="L2476">        minVal = math.min(minVal, item);</span>
<span class="line" id="L2477">        maxVal = math.max(maxVal, item);</span>
<span class="line" id="L2478">    }</span>
<span class="line" id="L2479">    <span class="tok-kw">return</span> .{ .min = minVal, .max = maxVal };</span>
<span class="line" id="L2480">}</span>
<span class="line" id="L2481"></span>
<span class="line" id="L2482"><span class="tok-kw">test</span> <span class="tok-str">&quot;minMax&quot;</span> {</span>
<span class="line" id="L2483">    <span class="tok-kw">try</span> testing.expectEqual(minMax(<span class="tok-type">u8</span>, <span class="tok-str">&quot;abcdefg&quot;</span>), .{ .min = <span class="tok-str">'a'</span>, .max = <span class="tok-str">'g'</span> });</span>
<span class="line" id="L2484">    <span class="tok-kw">try</span> testing.expectEqual(minMax(<span class="tok-type">u8</span>, <span class="tok-str">&quot;bcdefga&quot;</span>), .{ .min = <span class="tok-str">'a'</span>, .max = <span class="tok-str">'g'</span> });</span>
<span class="line" id="L2485">    <span class="tok-kw">try</span> testing.expectEqual(minMax(<span class="tok-type">u8</span>, <span class="tok-str">&quot;a&quot;</span>), .{ .min = <span class="tok-str">'a'</span>, .max = <span class="tok-str">'a'</span> });</span>
<span class="line" id="L2486">}</span>
<span class="line" id="L2487"></span>
<span class="line" id="L2488"><span class="tok-comment">/// Returns the index of the smallest number in a slice. O(n).</span></span>
<span class="line" id="L2489"><span class="tok-comment">/// `slice` must not be empty.</span></span>
<span class="line" id="L2490"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">indexOfMin</span>(<span class="tok-kw">comptime</span> T: <span class="tok-type">type</span>, slice: []<span class="tok-kw">const</span> T) <span class="tok-type">usize</span> {</span>
<span class="line" id="L2491">    assert(slice.len &gt; <span class="tok-number">0</span>);</span>
<span class="line" id="L2492">    <span class="tok-kw">var</span> best = slice[<span class="tok-number">0</span>];</span>
<span class="line" id="L2493">    <span class="tok-kw">var</span> index: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L2494">    <span class="tok-kw">for</span> (slice[<span class="tok-number">1</span>..]) |item, i| {</span>
<span class="line" id="L2495">        <span class="tok-kw">if</span> (item &lt; best) {</span>
<span class="line" id="L2496">            best = item;</span>
<span class="line" id="L2497">            index = i + <span class="tok-number">1</span>;</span>
<span class="line" id="L2498">        }</span>
<span class="line" id="L2499">    }</span>
<span class="line" id="L2500">    <span class="tok-kw">return</span> index;</span>
<span class="line" id="L2501">}</span>
<span class="line" id="L2502"></span>
<span class="line" id="L2503"><span class="tok-kw">test</span> <span class="tok-str">&quot;indexOfMin&quot;</span> {</span>
<span class="line" id="L2504">    <span class="tok-kw">try</span> testing.expectEqual(indexOfMin(<span class="tok-type">u8</span>, <span class="tok-str">&quot;abcdefg&quot;</span>), <span class="tok-number">0</span>);</span>
<span class="line" id="L2505">    <span class="tok-kw">try</span> testing.expectEqual(indexOfMin(<span class="tok-type">u8</span>, <span class="tok-str">&quot;bcdefga&quot;</span>), <span class="tok-number">6</span>);</span>
<span class="line" id="L2506">    <span class="tok-kw">try</span> testing.expectEqual(indexOfMin(<span class="tok-type">u8</span>, <span class="tok-str">&quot;a&quot;</span>), <span class="tok-number">0</span>);</span>
<span class="line" id="L2507">}</span>
<span class="line" id="L2508"></span>
<span class="line" id="L2509"><span class="tok-comment">/// Returns the index of the largest number in a slice. O(n).</span></span>
<span class="line" id="L2510"><span class="tok-comment">/// `slice` must not be empty.</span></span>
<span class="line" id="L2511"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">indexOfMax</span>(<span class="tok-kw">comptime</span> T: <span class="tok-type">type</span>, slice: []<span class="tok-kw">const</span> T) <span class="tok-type">usize</span> {</span>
<span class="line" id="L2512">    assert(slice.len &gt; <span class="tok-number">0</span>);</span>
<span class="line" id="L2513">    <span class="tok-kw">var</span> best = slice[<span class="tok-number">0</span>];</span>
<span class="line" id="L2514">    <span class="tok-kw">var</span> index: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L2515">    <span class="tok-kw">for</span> (slice[<span class="tok-number">1</span>..]) |item, i| {</span>
<span class="line" id="L2516">        <span class="tok-kw">if</span> (item &gt; best) {</span>
<span class="line" id="L2517">            best = item;</span>
<span class="line" id="L2518">            index = i + <span class="tok-number">1</span>;</span>
<span class="line" id="L2519">        }</span>
<span class="line" id="L2520">    }</span>
<span class="line" id="L2521">    <span class="tok-kw">return</span> index;</span>
<span class="line" id="L2522">}</span>
<span class="line" id="L2523"></span>
<span class="line" id="L2524"><span class="tok-kw">test</span> <span class="tok-str">&quot;indexOfMax&quot;</span> {</span>
<span class="line" id="L2525">    <span class="tok-kw">try</span> testing.expectEqual(indexOfMax(<span class="tok-type">u8</span>, <span class="tok-str">&quot;abcdefg&quot;</span>), <span class="tok-number">6</span>);</span>
<span class="line" id="L2526">    <span class="tok-kw">try</span> testing.expectEqual(indexOfMax(<span class="tok-type">u8</span>, <span class="tok-str">&quot;gabcdef&quot;</span>), <span class="tok-number">0</span>);</span>
<span class="line" id="L2527">    <span class="tok-kw">try</span> testing.expectEqual(indexOfMax(<span class="tok-type">u8</span>, <span class="tok-str">&quot;a&quot;</span>), <span class="tok-number">0</span>);</span>
<span class="line" id="L2528">}</span>
<span class="line" id="L2529"></span>
<span class="line" id="L2530"><span class="tok-comment">/// Finds the indices of the smallest and largest number in a slice. O(n).</span></span>
<span class="line" id="L2531"><span class="tok-comment">/// Returns an anonymous struct with the fields `index_min` and `index_max`.</span></span>
<span class="line" id="L2532"><span class="tok-comment">/// `slice` must not be empty.</span></span>
<span class="line" id="L2533"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">indexOfMinMax</span>(<span class="tok-kw">comptime</span> T: <span class="tok-type">type</span>, slice: []<span class="tok-kw">const</span> T) <span class="tok-kw">struct</span> { index_min: <span class="tok-type">usize</span>, index_max: <span class="tok-type">usize</span> } {</span>
<span class="line" id="L2534">    assert(slice.len &gt; <span class="tok-number">0</span>);</span>
<span class="line" id="L2535">    <span class="tok-kw">var</span> minVal = slice[<span class="tok-number">0</span>];</span>
<span class="line" id="L2536">    <span class="tok-kw">var</span> maxVal = slice[<span class="tok-number">0</span>];</span>
<span class="line" id="L2537">    <span class="tok-kw">var</span> minIdx: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L2538">    <span class="tok-kw">var</span> maxIdx: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L2539">    <span class="tok-kw">for</span> (slice[<span class="tok-number">1</span>..]) |item, i| {</span>
<span class="line" id="L2540">        <span class="tok-kw">if</span> (item &lt; minVal) {</span>
<span class="line" id="L2541">            minVal = item;</span>
<span class="line" id="L2542">            minIdx = i + <span class="tok-number">1</span>;</span>
<span class="line" id="L2543">        }</span>
<span class="line" id="L2544">        <span class="tok-kw">if</span> (item &gt; maxVal) {</span>
<span class="line" id="L2545">            maxVal = item;</span>
<span class="line" id="L2546">            maxIdx = i + <span class="tok-number">1</span>;</span>
<span class="line" id="L2547">        }</span>
<span class="line" id="L2548">    }</span>
<span class="line" id="L2549">    <span class="tok-kw">return</span> .{ .index_min = minIdx, .index_max = maxIdx };</span>
<span class="line" id="L2550">}</span>
<span class="line" id="L2551"></span>
<span class="line" id="L2552"><span class="tok-kw">test</span> <span class="tok-str">&quot;indexOfMinMax&quot;</span> {</span>
<span class="line" id="L2553">    <span class="tok-kw">try</span> testing.expectEqual(indexOfMinMax(<span class="tok-type">u8</span>, <span class="tok-str">&quot;abcdefg&quot;</span>), .{ .index_min = <span class="tok-number">0</span>, .index_max = <span class="tok-number">6</span> });</span>
<span class="line" id="L2554">    <span class="tok-kw">try</span> testing.expectEqual(indexOfMinMax(<span class="tok-type">u8</span>, <span class="tok-str">&quot;gabcdef&quot;</span>), .{ .index_min = <span class="tok-number">1</span>, .index_max = <span class="tok-number">0</span> });</span>
<span class="line" id="L2555">    <span class="tok-kw">try</span> testing.expectEqual(indexOfMinMax(<span class="tok-type">u8</span>, <span class="tok-str">&quot;a&quot;</span>), .{ .index_min = <span class="tok-number">0</span>, .index_max = <span class="tok-number">0</span> });</span>
<span class="line" id="L2556">}</span>
<span class="line" id="L2557"></span>
<span class="line" id="L2558"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">swap</span>(<span class="tok-kw">comptime</span> T: <span class="tok-type">type</span>, a: *T, b: *T) <span class="tok-type">void</span> {</span>
<span class="line" id="L2559">    <span class="tok-kw">const</span> tmp = a.*;</span>
<span class="line" id="L2560">    a.* = b.*;</span>
<span class="line" id="L2561">    b.* = tmp;</span>
<span class="line" id="L2562">}</span>
<span class="line" id="L2563"></span>
<span class="line" id="L2564"><span class="tok-comment">/// In-place order reversal of a slice</span></span>
<span class="line" id="L2565"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">reverse</span>(<span class="tok-kw">comptime</span> T: <span class="tok-type">type</span>, items: []T) <span class="tok-type">void</span> {</span>
<span class="line" id="L2566">    <span class="tok-kw">var</span> i: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L2567">    <span class="tok-kw">const</span> end = items.len / <span class="tok-number">2</span>;</span>
<span class="line" id="L2568">    <span class="tok-kw">while</span> (i &lt; end) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L2569">        swap(T, &amp;items[i], &amp;items[items.len - i - <span class="tok-number">1</span>]);</span>
<span class="line" id="L2570">    }</span>
<span class="line" id="L2571">}</span>
<span class="line" id="L2572"></span>
<span class="line" id="L2573"><span class="tok-kw">test</span> <span class="tok-str">&quot;reverse&quot;</span> {</span>
<span class="line" id="L2574">    <span class="tok-kw">var</span> arr = [_]<span class="tok-type">i32</span>{ <span class="tok-number">5</span>, <span class="tok-number">3</span>, <span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">4</span> };</span>
<span class="line" id="L2575">    reverse(<span class="tok-type">i32</span>, arr[<span class="tok-number">0</span>..]);</span>
<span class="line" id="L2576"></span>
<span class="line" id="L2577">    <span class="tok-kw">try</span> testing.expect(eql(<span class="tok-type">i32</span>, &amp;arr, &amp;[_]<span class="tok-type">i32</span>{ <span class="tok-number">4</span>, <span class="tok-number">2</span>, <span class="tok-number">1</span>, <span class="tok-number">3</span>, <span class="tok-number">5</span> }));</span>
<span class="line" id="L2578">}</span>
<span class="line" id="L2579"></span>
<span class="line" id="L2580"><span class="tok-comment">/// In-place rotation of the values in an array ([0 1 2 3] becomes [1 2 3 0] if we rotate by 1)</span></span>
<span class="line" id="L2581"><span class="tok-comment">/// Assumes 0 &lt;= amount &lt;= items.len</span></span>
<span class="line" id="L2582"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">rotate</span>(<span class="tok-kw">comptime</span> T: <span class="tok-type">type</span>, items: []T, amount: <span class="tok-type">usize</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L2583">    reverse(T, items[<span class="tok-number">0</span>..amount]);</span>
<span class="line" id="L2584">    reverse(T, items[amount..]);</span>
<span class="line" id="L2585">    reverse(T, items);</span>
<span class="line" id="L2586">}</span>
<span class="line" id="L2587"></span>
<span class="line" id="L2588"><span class="tok-kw">test</span> <span class="tok-str">&quot;rotate&quot;</span> {</span>
<span class="line" id="L2589">    <span class="tok-kw">var</span> arr = [_]<span class="tok-type">i32</span>{ <span class="tok-number">5</span>, <span class="tok-number">3</span>, <span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">4</span> };</span>
<span class="line" id="L2590">    rotate(<span class="tok-type">i32</span>, arr[<span class="tok-number">0</span>..], <span class="tok-number">2</span>);</span>
<span class="line" id="L2591"></span>
<span class="line" id="L2592">    <span class="tok-kw">try</span> testing.expect(eql(<span class="tok-type">i32</span>, &amp;arr, &amp;[_]<span class="tok-type">i32</span>{ <span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">4</span>, <span class="tok-number">5</span>, <span class="tok-number">3</span> }));</span>
<span class="line" id="L2593">}</span>
<span class="line" id="L2594"></span>
<span class="line" id="L2595"><span class="tok-comment">/// Replace needle with replacement as many times as possible, writing to an output buffer which is assumed to be of</span></span>
<span class="line" id="L2596"><span class="tok-comment">/// appropriate size. Use replacementSize to calculate an appropriate buffer size.</span></span>
<span class="line" id="L2597"><span class="tok-comment">/// The needle must not be empty.</span></span>
<span class="line" id="L2598"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">replace</span>(<span class="tok-kw">comptime</span> T: <span class="tok-type">type</span>, input: []<span class="tok-kw">const</span> T, needle: []<span class="tok-kw">const</span> T, replacement: []<span class="tok-kw">const</span> T, output: []T) <span class="tok-type">usize</span> {</span>
<span class="line" id="L2599">    <span class="tok-comment">// Empty needle will loop until output buffer overflows.</span>
</span>
<span class="line" id="L2600">    assert(needle.len &gt; <span class="tok-number">0</span>);</span>
<span class="line" id="L2601"></span>
<span class="line" id="L2602">    <span class="tok-kw">var</span> i: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L2603">    <span class="tok-kw">var</span> slide: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L2604">    <span class="tok-kw">var</span> replacements: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L2605">    <span class="tok-kw">while</span> (slide &lt; input.len) {</span>
<span class="line" id="L2606">        <span class="tok-kw">if</span> (mem.startsWith(T, input[slide..], needle)) {</span>
<span class="line" id="L2607">            mem.copy(T, output[i .. i + replacement.len], replacement);</span>
<span class="line" id="L2608">            i += replacement.len;</span>
<span class="line" id="L2609">            slide += needle.len;</span>
<span class="line" id="L2610">            replacements += <span class="tok-number">1</span>;</span>
<span class="line" id="L2611">        } <span class="tok-kw">else</span> {</span>
<span class="line" id="L2612">            output[i] = input[slide];</span>
<span class="line" id="L2613">            i += <span class="tok-number">1</span>;</span>
<span class="line" id="L2614">            slide += <span class="tok-number">1</span>;</span>
<span class="line" id="L2615">        }</span>
<span class="line" id="L2616">    }</span>
<span class="line" id="L2617"></span>
<span class="line" id="L2618">    <span class="tok-kw">return</span> replacements;</span>
<span class="line" id="L2619">}</span>
<span class="line" id="L2620"></span>
<span class="line" id="L2621"><span class="tok-kw">test</span> <span class="tok-str">&quot;replace&quot;</span> {</span>
<span class="line" id="L2622">    <span class="tok-kw">var</span> output: [<span class="tok-number">29</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L2623">    <span class="tok-kw">var</span> replacements = replace(<span class="tok-type">u8</span>, <span class="tok-str">&quot;All your base are belong to us&quot;</span>, <span class="tok-str">&quot;base&quot;</span>, <span class="tok-str">&quot;Zig&quot;</span>, output[<span class="tok-number">0</span>..]);</span>
<span class="line" id="L2624">    <span class="tok-kw">var</span> expected: []<span class="tok-kw">const</span> <span class="tok-type">u8</span> = <span class="tok-str">&quot;All your Zig are belong to us&quot;</span>;</span>
<span class="line" id="L2625">    <span class="tok-kw">try</span> testing.expect(replacements == <span class="tok-number">1</span>);</span>
<span class="line" id="L2626">    <span class="tok-kw">try</span> testing.expectEqualStrings(expected, output[<span class="tok-number">0</span>..expected.len]);</span>
<span class="line" id="L2627"></span>
<span class="line" id="L2628">    replacements = replace(<span class="tok-type">u8</span>, <span class="tok-str">&quot;Favor reading code over writing code.&quot;</span>, <span class="tok-str">&quot;code&quot;</span>, <span class="tok-str">&quot;&quot;</span>, output[<span class="tok-number">0</span>..]);</span>
<span class="line" id="L2629">    expected = <span class="tok-str">&quot;Favor reading  over writing .&quot;</span>;</span>
<span class="line" id="L2630">    <span class="tok-kw">try</span> testing.expect(replacements == <span class="tok-number">2</span>);</span>
<span class="line" id="L2631">    <span class="tok-kw">try</span> testing.expectEqualStrings(expected, output[<span class="tok-number">0</span>..expected.len]);</span>
<span class="line" id="L2632"></span>
<span class="line" id="L2633">    <span class="tok-comment">// Empty needle is not allowed but input may be empty.</span>
</span>
<span class="line" id="L2634">    replacements = replace(<span class="tok-type">u8</span>, <span class="tok-str">&quot;&quot;</span>, <span class="tok-str">&quot;x&quot;</span>, <span class="tok-str">&quot;y&quot;</span>, output[<span class="tok-number">0</span>..<span class="tok-number">0</span>]);</span>
<span class="line" id="L2635">    expected = <span class="tok-str">&quot;&quot;</span>;</span>
<span class="line" id="L2636">    <span class="tok-kw">try</span> testing.expect(replacements == <span class="tok-number">0</span>);</span>
<span class="line" id="L2637">    <span class="tok-kw">try</span> testing.expectEqualStrings(expected, output[<span class="tok-number">0</span>..expected.len]);</span>
<span class="line" id="L2638"></span>
<span class="line" id="L2639">    <span class="tok-comment">// Adjacent replacements.</span>
</span>
<span class="line" id="L2640"></span>
<span class="line" id="L2641">    replacements = replace(<span class="tok-type">u8</span>, <span class="tok-str">&quot;\\n\\n&quot;</span>, <span class="tok-str">&quot;\\n&quot;</span>, <span class="tok-str">&quot;\n&quot;</span>, output[<span class="tok-number">0</span>..]);</span>
<span class="line" id="L2642">    expected = <span class="tok-str">&quot;\n\n&quot;</span>;</span>
<span class="line" id="L2643">    <span class="tok-kw">try</span> testing.expect(replacements == <span class="tok-number">2</span>);</span>
<span class="line" id="L2644">    <span class="tok-kw">try</span> testing.expectEqualStrings(expected, output[<span class="tok-number">0</span>..expected.len]);</span>
<span class="line" id="L2645"></span>
<span class="line" id="L2646">    replacements = replace(<span class="tok-type">u8</span>, <span class="tok-str">&quot;abbba&quot;</span>, <span class="tok-str">&quot;b&quot;</span>, <span class="tok-str">&quot;cd&quot;</span>, output[<span class="tok-number">0</span>..]);</span>
<span class="line" id="L2647">    expected = <span class="tok-str">&quot;acdcdcda&quot;</span>;</span>
<span class="line" id="L2648">    <span class="tok-kw">try</span> testing.expect(replacements == <span class="tok-number">3</span>);</span>
<span class="line" id="L2649">    <span class="tok-kw">try</span> testing.expectEqualStrings(expected, output[<span class="tok-number">0</span>..expected.len]);</span>
<span class="line" id="L2650">}</span>
<span class="line" id="L2651"></span>
<span class="line" id="L2652"><span class="tok-comment">/// Replace all occurences of `needle` with `replacement`.</span></span>
<span class="line" id="L2653"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">replaceScalar</span>(<span class="tok-kw">comptime</span> T: <span class="tok-type">type</span>, slice: []T, needle: T, replacement: T) <span class="tok-type">void</span> {</span>
<span class="line" id="L2654">    <span class="tok-kw">for</span> (slice) |e, i| {</span>
<span class="line" id="L2655">        <span class="tok-kw">if</span> (e == needle) {</span>
<span class="line" id="L2656">            slice[i] = replacement;</span>
<span class="line" id="L2657">        }</span>
<span class="line" id="L2658">    }</span>
<span class="line" id="L2659">}</span>
<span class="line" id="L2660"></span>
<span class="line" id="L2661"><span class="tok-comment">/// Collapse consecutive duplicate elements into one entry.</span></span>
<span class="line" id="L2662"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">collapseRepeatsLen</span>(<span class="tok-kw">comptime</span> T: <span class="tok-type">type</span>, slice: []T, elem: T) <span class="tok-type">usize</span> {</span>
<span class="line" id="L2663">    <span class="tok-kw">if</span> (slice.len == <span class="tok-number">0</span>) <span class="tok-kw">return</span> <span class="tok-number">0</span>;</span>
<span class="line" id="L2664">    <span class="tok-kw">var</span> write_idx: <span class="tok-type">usize</span> = <span class="tok-number">1</span>;</span>
<span class="line" id="L2665">    <span class="tok-kw">var</span> read_idx: <span class="tok-type">usize</span> = <span class="tok-number">1</span>;</span>
<span class="line" id="L2666">    <span class="tok-kw">while</span> (read_idx &lt; slice.len) : (read_idx += <span class="tok-number">1</span>) {</span>
<span class="line" id="L2667">        <span class="tok-kw">if</span> (slice[read_idx - <span class="tok-number">1</span>] != elem <span class="tok-kw">or</span> slice[read_idx] != elem) {</span>
<span class="line" id="L2668">            slice[write_idx] = slice[read_idx];</span>
<span class="line" id="L2669">            write_idx += <span class="tok-number">1</span>;</span>
<span class="line" id="L2670">        }</span>
<span class="line" id="L2671">    }</span>
<span class="line" id="L2672">    <span class="tok-kw">return</span> write_idx;</span>
<span class="line" id="L2673">}</span>
<span class="line" id="L2674"></span>
<span class="line" id="L2675"><span class="tok-comment">/// Collapse consecutive duplicate elements into one entry.</span></span>
<span class="line" id="L2676"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">collapseRepeats</span>(<span class="tok-kw">comptime</span> T: <span class="tok-type">type</span>, slice: []T, elem: T) []T {</span>
<span class="line" id="L2677">    <span class="tok-kw">return</span> slice[<span class="tok-number">0</span>..collapseRepeatsLen(T, slice, elem)];</span>
<span class="line" id="L2678">}</span>
<span class="line" id="L2679"></span>
<span class="line" id="L2680"><span class="tok-kw">fn</span> <span class="tok-fn">testCollapseRepeats</span>(str: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, elem: <span class="tok-type">u8</span>, expected: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) !<span class="tok-type">void</span> {</span>
<span class="line" id="L2681">    <span class="tok-kw">const</span> mutable = <span class="tok-kw">try</span> std.testing.allocator.dupe(<span class="tok-type">u8</span>, str);</span>
<span class="line" id="L2682">    <span class="tok-kw">defer</span> std.testing.allocator.free(mutable);</span>
<span class="line" id="L2683">    <span class="tok-kw">try</span> testing.expect(std.mem.eql(<span class="tok-type">u8</span>, collapseRepeats(<span class="tok-type">u8</span>, mutable, elem), expected));</span>
<span class="line" id="L2684">}</span>
<span class="line" id="L2685"><span class="tok-kw">test</span> <span class="tok-str">&quot;collapseRepeats&quot;</span> {</span>
<span class="line" id="L2686">    <span class="tok-kw">try</span> testCollapseRepeats(<span class="tok-str">&quot;&quot;</span>, <span class="tok-str">'/'</span>, <span class="tok-str">&quot;&quot;</span>);</span>
<span class="line" id="L2687">    <span class="tok-kw">try</span> testCollapseRepeats(<span class="tok-str">&quot;a&quot;</span>, <span class="tok-str">'/'</span>, <span class="tok-str">&quot;a&quot;</span>);</span>
<span class="line" id="L2688">    <span class="tok-kw">try</span> testCollapseRepeats(<span class="tok-str">&quot;/&quot;</span>, <span class="tok-str">'/'</span>, <span class="tok-str">&quot;/&quot;</span>);</span>
<span class="line" id="L2689">    <span class="tok-kw">try</span> testCollapseRepeats(<span class="tok-str">&quot;//&quot;</span>, <span class="tok-str">'/'</span>, <span class="tok-str">&quot;/&quot;</span>);</span>
<span class="line" id="L2690">    <span class="tok-kw">try</span> testCollapseRepeats(<span class="tok-str">&quot;/a&quot;</span>, <span class="tok-str">'/'</span>, <span class="tok-str">&quot;/a&quot;</span>);</span>
<span class="line" id="L2691">    <span class="tok-kw">try</span> testCollapseRepeats(<span class="tok-str">&quot;//a&quot;</span>, <span class="tok-str">'/'</span>, <span class="tok-str">&quot;/a&quot;</span>);</span>
<span class="line" id="L2692">    <span class="tok-kw">try</span> testCollapseRepeats(<span class="tok-str">&quot;a/&quot;</span>, <span class="tok-str">'/'</span>, <span class="tok-str">&quot;a/&quot;</span>);</span>
<span class="line" id="L2693">    <span class="tok-kw">try</span> testCollapseRepeats(<span class="tok-str">&quot;a//&quot;</span>, <span class="tok-str">'/'</span>, <span class="tok-str">&quot;a/&quot;</span>);</span>
<span class="line" id="L2694">    <span class="tok-kw">try</span> testCollapseRepeats(<span class="tok-str">&quot;a/a&quot;</span>, <span class="tok-str">'/'</span>, <span class="tok-str">&quot;a/a&quot;</span>);</span>
<span class="line" id="L2695">    <span class="tok-kw">try</span> testCollapseRepeats(<span class="tok-str">&quot;a//a&quot;</span>, <span class="tok-str">'/'</span>, <span class="tok-str">&quot;a/a&quot;</span>);</span>
<span class="line" id="L2696">    <span class="tok-kw">try</span> testCollapseRepeats(<span class="tok-str">&quot;//a///a////&quot;</span>, <span class="tok-str">'/'</span>, <span class="tok-str">&quot;/a/a/&quot;</span>);</span>
<span class="line" id="L2697">}</span>
<span class="line" id="L2698"></span>
<span class="line" id="L2699"><span class="tok-comment">/// Calculate the size needed in an output buffer to perform a replacement.</span></span>
<span class="line" id="L2700"><span class="tok-comment">/// The needle must not be empty.</span></span>
<span class="line" id="L2701"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">replacementSize</span>(<span class="tok-kw">comptime</span> T: <span class="tok-type">type</span>, input: []<span class="tok-kw">const</span> T, needle: []<span class="tok-kw">const</span> T, replacement: []<span class="tok-kw">const</span> T) <span class="tok-type">usize</span> {</span>
<span class="line" id="L2702">    <span class="tok-comment">// Empty needle will loop forever.</span>
</span>
<span class="line" id="L2703">    assert(needle.len &gt; <span class="tok-number">0</span>);</span>
<span class="line" id="L2704"></span>
<span class="line" id="L2705">    <span class="tok-kw">var</span> i: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L2706">    <span class="tok-kw">var</span> size: <span class="tok-type">usize</span> = input.len;</span>
<span class="line" id="L2707">    <span class="tok-kw">while</span> (i &lt; input.len) {</span>
<span class="line" id="L2708">        <span class="tok-kw">if</span> (mem.startsWith(T, input[i..], needle)) {</span>
<span class="line" id="L2709">            size = size - needle.len + replacement.len;</span>
<span class="line" id="L2710">            i += needle.len;</span>
<span class="line" id="L2711">        } <span class="tok-kw">else</span> {</span>
<span class="line" id="L2712">            i += <span class="tok-number">1</span>;</span>
<span class="line" id="L2713">        }</span>
<span class="line" id="L2714">    }</span>
<span class="line" id="L2715"></span>
<span class="line" id="L2716">    <span class="tok-kw">return</span> size;</span>
<span class="line" id="L2717">}</span>
<span class="line" id="L2718"></span>
<span class="line" id="L2719"><span class="tok-kw">test</span> <span class="tok-str">&quot;replacementSize&quot;</span> {</span>
<span class="line" id="L2720">    <span class="tok-kw">try</span> testing.expect(replacementSize(<span class="tok-type">u8</span>, <span class="tok-str">&quot;All your base are belong to us&quot;</span>, <span class="tok-str">&quot;base&quot;</span>, <span class="tok-str">&quot;Zig&quot;</span>) == <span class="tok-number">29</span>);</span>
<span class="line" id="L2721">    <span class="tok-kw">try</span> testing.expect(replacementSize(<span class="tok-type">u8</span>, <span class="tok-str">&quot;Favor reading code over writing code.&quot;</span>, <span class="tok-str">&quot;code&quot;</span>, <span class="tok-str">&quot;&quot;</span>) == <span class="tok-number">29</span>);</span>
<span class="line" id="L2722">    <span class="tok-kw">try</span> testing.expect(replacementSize(<span class="tok-type">u8</span>, <span class="tok-str">&quot;Only one obvious way to do things.&quot;</span>, <span class="tok-str">&quot;things.&quot;</span>, <span class="tok-str">&quot;things in Zig.&quot;</span>) == <span class="tok-number">41</span>);</span>
<span class="line" id="L2723"></span>
<span class="line" id="L2724">    <span class="tok-comment">// Empty needle is not allowed but input may be empty.</span>
</span>
<span class="line" id="L2725">    <span class="tok-kw">try</span> testing.expect(replacementSize(<span class="tok-type">u8</span>, <span class="tok-str">&quot;&quot;</span>, <span class="tok-str">&quot;x&quot;</span>, <span class="tok-str">&quot;y&quot;</span>) == <span class="tok-number">0</span>);</span>
<span class="line" id="L2726"></span>
<span class="line" id="L2727">    <span class="tok-comment">// Adjacent replacements.</span>
</span>
<span class="line" id="L2728">    <span class="tok-kw">try</span> testing.expect(replacementSize(<span class="tok-type">u8</span>, <span class="tok-str">&quot;\\n\\n&quot;</span>, <span class="tok-str">&quot;\\n&quot;</span>, <span class="tok-str">&quot;\n&quot;</span>) == <span class="tok-number">2</span>);</span>
<span class="line" id="L2729">    <span class="tok-kw">try</span> testing.expect(replacementSize(<span class="tok-type">u8</span>, <span class="tok-str">&quot;abbba&quot;</span>, <span class="tok-str">&quot;b&quot;</span>, <span class="tok-str">&quot;cd&quot;</span>) == <span class="tok-number">8</span>);</span>
<span class="line" id="L2730">}</span>
<span class="line" id="L2731"></span>
<span class="line" id="L2732"><span class="tok-comment">/// Perform a replacement on an allocated buffer of pre-determined size. Caller must free returned memory.</span></span>
<span class="line" id="L2733"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">replaceOwned</span>(<span class="tok-kw">comptime</span> T: <span class="tok-type">type</span>, allocator: Allocator, input: []<span class="tok-kw">const</span> T, needle: []<span class="tok-kw">const</span> T, replacement: []<span class="tok-kw">const</span> T) Allocator.Error![]T {</span>
<span class="line" id="L2734">    <span class="tok-kw">var</span> output = <span class="tok-kw">try</span> allocator.alloc(T, replacementSize(T, input, needle, replacement));</span>
<span class="line" id="L2735">    _ = replace(T, input, needle, replacement, output);</span>
<span class="line" id="L2736">    <span class="tok-kw">return</span> output;</span>
<span class="line" id="L2737">}</span>
<span class="line" id="L2738"></span>
<span class="line" id="L2739"><span class="tok-kw">test</span> <span class="tok-str">&quot;replaceOwned&quot;</span> {</span>
<span class="line" id="L2740">    <span class="tok-kw">const</span> gpa = std.testing.allocator;</span>
<span class="line" id="L2741"></span>
<span class="line" id="L2742">    <span class="tok-kw">const</span> base_replace = replaceOwned(<span class="tok-type">u8</span>, gpa, <span class="tok-str">&quot;All your base are belong to us&quot;</span>, <span class="tok-str">&quot;base&quot;</span>, <span class="tok-str">&quot;Zig&quot;</span>) <span class="tok-kw">catch</span> <span class="tok-builtin">@panic</span>(<span class="tok-str">&quot;out of memory&quot;</span>);</span>
<span class="line" id="L2743">    <span class="tok-kw">defer</span> gpa.free(base_replace);</span>
<span class="line" id="L2744">    <span class="tok-kw">try</span> testing.expect(eql(<span class="tok-type">u8</span>, base_replace, <span class="tok-str">&quot;All your Zig are belong to us&quot;</span>));</span>
<span class="line" id="L2745"></span>
<span class="line" id="L2746">    <span class="tok-kw">const</span> zen_replace = replaceOwned(<span class="tok-type">u8</span>, gpa, <span class="tok-str">&quot;Favor reading code over writing code.&quot;</span>, <span class="tok-str">&quot; code&quot;</span>, <span class="tok-str">&quot;&quot;</span>) <span class="tok-kw">catch</span> <span class="tok-builtin">@panic</span>(<span class="tok-str">&quot;out of memory&quot;</span>);</span>
<span class="line" id="L2747">    <span class="tok-kw">defer</span> gpa.free(zen_replace);</span>
<span class="line" id="L2748">    <span class="tok-kw">try</span> testing.expect(eql(<span class="tok-type">u8</span>, zen_replace, <span class="tok-str">&quot;Favor reading over writing.&quot;</span>));</span>
<span class="line" id="L2749">}</span>
<span class="line" id="L2750"></span>
<span class="line" id="L2751"><span class="tok-comment">/// Converts a little-endian integer to host endianness.</span></span>
<span class="line" id="L2752"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">littleToNative</span>(<span class="tok-kw">comptime</span> T: <span class="tok-type">type</span>, x: T) T {</span>
<span class="line" id="L2753">    <span class="tok-kw">return</span> <span class="tok-kw">switch</span> (native_endian) {</span>
<span class="line" id="L2754">        .Little =&gt; x,</span>
<span class="line" id="L2755">        .Big =&gt; <span class="tok-builtin">@byteSwap</span>(T, x),</span>
<span class="line" id="L2756">    };</span>
<span class="line" id="L2757">}</span>
<span class="line" id="L2758"></span>
<span class="line" id="L2759"><span class="tok-comment">/// Converts a big-endian integer to host endianness.</span></span>
<span class="line" id="L2760"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">bigToNative</span>(<span class="tok-kw">comptime</span> T: <span class="tok-type">type</span>, x: T) T {</span>
<span class="line" id="L2761">    <span class="tok-kw">return</span> <span class="tok-kw">switch</span> (native_endian) {</span>
<span class="line" id="L2762">        .Little =&gt; <span class="tok-builtin">@byteSwap</span>(T, x),</span>
<span class="line" id="L2763">        .Big =&gt; x,</span>
<span class="line" id="L2764">    };</span>
<span class="line" id="L2765">}</span>
<span class="line" id="L2766"></span>
<span class="line" id="L2767"><span class="tok-comment">/// Converts an integer from specified endianness to host endianness.</span></span>
<span class="line" id="L2768"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">toNative</span>(<span class="tok-kw">comptime</span> T: <span class="tok-type">type</span>, x: T, endianness_of_x: Endian) T {</span>
<span class="line" id="L2769">    <span class="tok-kw">return</span> <span class="tok-kw">switch</span> (endianness_of_x) {</span>
<span class="line" id="L2770">        .Little =&gt; littleToNative(T, x),</span>
<span class="line" id="L2771">        .Big =&gt; bigToNative(T, x),</span>
<span class="line" id="L2772">    };</span>
<span class="line" id="L2773">}</span>
<span class="line" id="L2774"></span>
<span class="line" id="L2775"><span class="tok-comment">/// Converts an integer which has host endianness to the desired endianness.</span></span>
<span class="line" id="L2776"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">nativeTo</span>(<span class="tok-kw">comptime</span> T: <span class="tok-type">type</span>, x: T, desired_endianness: Endian) T {</span>
<span class="line" id="L2777">    <span class="tok-kw">return</span> <span class="tok-kw">switch</span> (desired_endianness) {</span>
<span class="line" id="L2778">        .Little =&gt; nativeToLittle(T, x),</span>
<span class="line" id="L2779">        .Big =&gt; nativeToBig(T, x),</span>
<span class="line" id="L2780">    };</span>
<span class="line" id="L2781">}</span>
<span class="line" id="L2782"></span>
<span class="line" id="L2783"><span class="tok-comment">/// Converts an integer which has host endianness to little endian.</span></span>
<span class="line" id="L2784"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">nativeToLittle</span>(<span class="tok-kw">comptime</span> T: <span class="tok-type">type</span>, x: T) T {</span>
<span class="line" id="L2785">    <span class="tok-kw">return</span> <span class="tok-kw">switch</span> (native_endian) {</span>
<span class="line" id="L2786">        .Little =&gt; x,</span>
<span class="line" id="L2787">        .Big =&gt; <span class="tok-builtin">@byteSwap</span>(T, x),</span>
<span class="line" id="L2788">    };</span>
<span class="line" id="L2789">}</span>
<span class="line" id="L2790"></span>
<span class="line" id="L2791"><span class="tok-comment">/// Converts an integer which has host endianness to big endian.</span></span>
<span class="line" id="L2792"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">nativeToBig</span>(<span class="tok-kw">comptime</span> T: <span class="tok-type">type</span>, x: T) T {</span>
<span class="line" id="L2793">    <span class="tok-kw">return</span> <span class="tok-kw">switch</span> (native_endian) {</span>
<span class="line" id="L2794">        .Little =&gt; <span class="tok-builtin">@byteSwap</span>(T, x),</span>
<span class="line" id="L2795">        .Big =&gt; x,</span>
<span class="line" id="L2796">    };</span>
<span class="line" id="L2797">}</span>
<span class="line" id="L2798"></span>
<span class="line" id="L2799"><span class="tok-comment">/// Returns the number of elements that, if added to the given pointer, align it</span></span>
<span class="line" id="L2800"><span class="tok-comment">/// to a multiple of the given quantity, or `null` if one of the following</span></span>
<span class="line" id="L2801"><span class="tok-comment">/// conditions is met:</span></span>
<span class="line" id="L2802"><span class="tok-comment">/// - The aligned pointer would not fit the address space,</span></span>
<span class="line" id="L2803"><span class="tok-comment">/// - The delta required to align the pointer is not a multiple of the pointee's</span></span>
<span class="line" id="L2804"><span class="tok-comment">///   type.</span></span>
<span class="line" id="L2805"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">alignPointerOffset</span>(ptr: <span class="tok-kw">anytype</span>, align_to: <span class="tok-type">u29</span>) ?<span class="tok-type">usize</span> {</span>
<span class="line" id="L2806">    assert(align_to != <span class="tok-number">0</span> <span class="tok-kw">and</span> <span class="tok-builtin">@popCount</span>(<span class="tok-type">u29</span>, align_to) == <span class="tok-number">1</span>);</span>
<span class="line" id="L2807"></span>
<span class="line" id="L2808">    <span class="tok-kw">const</span> T = <span class="tok-builtin">@TypeOf</span>(ptr);</span>
<span class="line" id="L2809">    <span class="tok-kw">const</span> info = <span class="tok-builtin">@typeInfo</span>(T);</span>
<span class="line" id="L2810">    <span class="tok-kw">if</span> (info != .Pointer <span class="tok-kw">or</span> info.Pointer.size != .Many)</span>
<span class="line" id="L2811">        <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;expected many item pointer, got &quot;</span> ++ <span class="tok-builtin">@typeName</span>(T));</span>
<span class="line" id="L2812"></span>
<span class="line" id="L2813">    <span class="tok-comment">// Do nothing if the pointer is already well-aligned.</span>
</span>
<span class="line" id="L2814">    <span class="tok-kw">if</span> (align_to &lt;= info.Pointer.alignment)</span>
<span class="line" id="L2815">        <span class="tok-kw">return</span> <span class="tok-number">0</span>;</span>
<span class="line" id="L2816"></span>
<span class="line" id="L2817">    <span class="tok-comment">// Calculate the aligned base address with an eye out for overflow.</span>
</span>
<span class="line" id="L2818">    <span class="tok-kw">const</span> addr = <span class="tok-builtin">@ptrToInt</span>(ptr);</span>
<span class="line" id="L2819">    <span class="tok-kw">var</span> new_addr: <span class="tok-type">usize</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L2820">    <span class="tok-kw">if</span> (<span class="tok-builtin">@addWithOverflow</span>(<span class="tok-type">usize</span>, addr, align_to - <span class="tok-number">1</span>, &amp;new_addr)) <span class="tok-kw">return</span> <span class="tok-null">null</span>;</span>
<span class="line" id="L2821">    new_addr &amp;= ~<span class="tok-builtin">@as</span>(<span class="tok-type">usize</span>, align_to - <span class="tok-number">1</span>);</span>
<span class="line" id="L2822"></span>
<span class="line" id="L2823">    <span class="tok-comment">// The delta is expressed in terms of bytes, turn it into a number of child</span>
</span>
<span class="line" id="L2824">    <span class="tok-comment">// type elements.</span>
</span>
<span class="line" id="L2825">    <span class="tok-kw">const</span> delta = new_addr - addr;</span>
<span class="line" id="L2826">    <span class="tok-kw">const</span> pointee_size = <span class="tok-builtin">@sizeOf</span>(info.Pointer.child);</span>
<span class="line" id="L2827">    <span class="tok-kw">if</span> (delta % pointee_size != <span class="tok-number">0</span>) <span class="tok-kw">return</span> <span class="tok-null">null</span>;</span>
<span class="line" id="L2828">    <span class="tok-kw">return</span> delta / pointee_size;</span>
<span class="line" id="L2829">}</span>
<span class="line" id="L2830"></span>
<span class="line" id="L2831"><span class="tok-comment">/// Aligns a given pointer value to a specified alignment factor.</span></span>
<span class="line" id="L2832"><span class="tok-comment">/// Returns an aligned pointer or null if one of the following conditions is</span></span>
<span class="line" id="L2833"><span class="tok-comment">/// met:</span></span>
<span class="line" id="L2834"><span class="tok-comment">/// - The aligned pointer would not fit the address space,</span></span>
<span class="line" id="L2835"><span class="tok-comment">/// - The delta required to align the pointer is not a multiple of the pointee's</span></span>
<span class="line" id="L2836"><span class="tok-comment">///   type.</span></span>
<span class="line" id="L2837"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">alignPointer</span>(ptr: <span class="tok-kw">anytype</span>, align_to: <span class="tok-type">u29</span>) ?<span class="tok-builtin">@TypeOf</span>(ptr) {</span>
<span class="line" id="L2838">    <span class="tok-kw">const</span> adjust_off = alignPointerOffset(ptr, align_to) <span class="tok-kw">orelse</span> <span class="tok-kw">return</span> <span class="tok-null">null</span>;</span>
<span class="line" id="L2839">    <span class="tok-kw">const</span> T = <span class="tok-builtin">@TypeOf</span>(ptr);</span>
<span class="line" id="L2840">    <span class="tok-comment">// Avoid the use of intToPtr to avoid losing the pointer provenance info.</span>
</span>
<span class="line" id="L2841">    <span class="tok-kw">return</span> <span class="tok-builtin">@alignCast</span>(<span class="tok-builtin">@typeInfo</span>(T).Pointer.alignment, ptr + adjust_off);</span>
<span class="line" id="L2842">}</span>
<span class="line" id="L2843"></span>
<span class="line" id="L2844"><span class="tok-kw">test</span> <span class="tok-str">&quot;alignPointer&quot;</span> {</span>
<span class="line" id="L2845">    <span class="tok-kw">const</span> S = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L2846">        <span class="tok-kw">fn</span> <span class="tok-fn">checkAlign</span>(<span class="tok-kw">comptime</span> T: <span class="tok-type">type</span>, base: <span class="tok-type">usize</span>, align_to: <span class="tok-type">u29</span>, expected: <span class="tok-type">usize</span>) !<span class="tok-type">void</span> {</span>
<span class="line" id="L2847">            <span class="tok-kw">var</span> ptr = <span class="tok-builtin">@intToPtr</span>(T, base);</span>
<span class="line" id="L2848">            <span class="tok-kw">var</span> aligned = alignPointer(ptr, align_to);</span>
<span class="line" id="L2849">            <span class="tok-kw">try</span> testing.expectEqual(expected, <span class="tok-builtin">@ptrToInt</span>(aligned));</span>
<span class="line" id="L2850">        }</span>
<span class="line" id="L2851">    };</span>
<span class="line" id="L2852"></span>
<span class="line" id="L2853">    <span class="tok-kw">try</span> S.checkAlign([*]<span class="tok-type">u8</span>, <span class="tok-number">0x123</span>, <span class="tok-number">0x200</span>, <span class="tok-number">0x200</span>);</span>
<span class="line" id="L2854">    <span class="tok-kw">try</span> S.checkAlign([*]<span class="tok-kw">align</span>(<span class="tok-number">4</span>) <span class="tok-type">u8</span>, <span class="tok-number">0x10</span>, <span class="tok-number">2</span>, <span class="tok-number">0x10</span>);</span>
<span class="line" id="L2855">    <span class="tok-kw">try</span> S.checkAlign([*]<span class="tok-type">u32</span>, <span class="tok-number">0x10</span>, <span class="tok-number">2</span>, <span class="tok-number">0x10</span>);</span>
<span class="line" id="L2856">    <span class="tok-kw">try</span> S.checkAlign([*]<span class="tok-type">u32</span>, <span class="tok-number">0x4</span>, <span class="tok-number">16</span>, <span class="tok-number">0x10</span>);</span>
<span class="line" id="L2857">    <span class="tok-comment">// Misaligned.</span>
</span>
<span class="line" id="L2858">    <span class="tok-kw">try</span> S.checkAlign([*]<span class="tok-kw">align</span>(<span class="tok-number">1</span>) <span class="tok-type">u32</span>, <span class="tok-number">0x3</span>, <span class="tok-number">2</span>, <span class="tok-number">0</span>);</span>
<span class="line" id="L2859">    <span class="tok-comment">// Overflow.</span>
</span>
<span class="line" id="L2860">    <span class="tok-kw">try</span> S.checkAlign([*]<span class="tok-type">u32</span>, math.maxInt(<span class="tok-type">usize</span>) - <span class="tok-number">3</span>, <span class="tok-number">8</span>, <span class="tok-number">0</span>);</span>
<span class="line" id="L2861">}</span>
<span class="line" id="L2862"></span>
<span class="line" id="L2863"><span class="tok-kw">fn</span> <span class="tok-fn">CopyPtrAttrs</span>(</span>
<span class="line" id="L2864">    <span class="tok-kw">comptime</span> source: <span class="tok-type">type</span>,</span>
<span class="line" id="L2865">    <span class="tok-kw">comptime</span> size: std.builtin.Type.Pointer.Size,</span>
<span class="line" id="L2866">    <span class="tok-kw">comptime</span> child: <span class="tok-type">type</span>,</span>
<span class="line" id="L2867">) <span class="tok-type">type</span> {</span>
<span class="line" id="L2868">    <span class="tok-kw">const</span> info = <span class="tok-builtin">@typeInfo</span>(source).Pointer;</span>
<span class="line" id="L2869">    <span class="tok-kw">return</span> <span class="tok-builtin">@Type</span>(.{</span>
<span class="line" id="L2870">        .Pointer = .{</span>
<span class="line" id="L2871">            .size = size,</span>
<span class="line" id="L2872">            .is_const = info.is_const,</span>
<span class="line" id="L2873">            .is_volatile = info.is_volatile,</span>
<span class="line" id="L2874">            .is_allowzero = info.is_allowzero,</span>
<span class="line" id="L2875">            .alignment = info.alignment,</span>
<span class="line" id="L2876">            .address_space = info.address_space,</span>
<span class="line" id="L2877">            .child = child,</span>
<span class="line" id="L2878">            .sentinel = <span class="tok-null">null</span>,</span>
<span class="line" id="L2879">        },</span>
<span class="line" id="L2880">    });</span>
<span class="line" id="L2881">}</span>
<span class="line" id="L2882"></span>
<span class="line" id="L2883"><span class="tok-kw">fn</span> <span class="tok-fn">AsBytesReturnType</span>(<span class="tok-kw">comptime</span> P: <span class="tok-type">type</span>) <span class="tok-type">type</span> {</span>
<span class="line" id="L2884">    <span class="tok-kw">if</span> (!trait.isSingleItemPtr(P))</span>
<span class="line" id="L2885">        <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;expected single item pointer, passed &quot;</span> ++ <span class="tok-builtin">@typeName</span>(P));</span>
<span class="line" id="L2886"></span>
<span class="line" id="L2887">    <span class="tok-kw">const</span> size = <span class="tok-builtin">@sizeOf</span>(meta.Child(P));</span>
<span class="line" id="L2888"></span>
<span class="line" id="L2889">    <span class="tok-kw">return</span> CopyPtrAttrs(P, .One, [size]<span class="tok-type">u8</span>);</span>
<span class="line" id="L2890">}</span>
<span class="line" id="L2891"></span>
<span class="line" id="L2892"><span class="tok-comment">/// Given a pointer to a single item, returns a slice of the underlying bytes, preserving pointer attributes.</span></span>
<span class="line" id="L2893"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">asBytes</span>(ptr: <span class="tok-kw">anytype</span>) AsBytesReturnType(<span class="tok-builtin">@TypeOf</span>(ptr)) {</span>
<span class="line" id="L2894">    <span class="tok-kw">const</span> P = <span class="tok-builtin">@TypeOf</span>(ptr);</span>
<span class="line" id="L2895">    <span class="tok-kw">return</span> <span class="tok-builtin">@ptrCast</span>(AsBytesReturnType(P), ptr);</span>
<span class="line" id="L2896">}</span>
<span class="line" id="L2897"></span>
<span class="line" id="L2898"><span class="tok-kw">test</span> <span class="tok-str">&quot;asBytes&quot;</span> {</span>
<span class="line" id="L2899">    <span class="tok-kw">if</span> (builtin.zig_backend == .stage1) <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SkipZigTest;</span>
<span class="line" id="L2900"></span>
<span class="line" id="L2901">    <span class="tok-kw">const</span> deadbeef = <span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">0xDEADBEEF</span>);</span>
<span class="line" id="L2902">    <span class="tok-kw">const</span> deadbeef_bytes = <span class="tok-kw">switch</span> (native_endian) {</span>
<span class="line" id="L2903">        .Big =&gt; <span class="tok-str">&quot;\xDE\xAD\xBE\xEF&quot;</span>,</span>
<span class="line" id="L2904">        .Little =&gt; <span class="tok-str">&quot;\xEF\xBE\xAD\xDE&quot;</span>,</span>
<span class="line" id="L2905">    };</span>
<span class="line" id="L2906"></span>
<span class="line" id="L2907">    <span class="tok-kw">try</span> testing.expect(eql(<span class="tok-type">u8</span>, asBytes(&amp;deadbeef), deadbeef_bytes));</span>
<span class="line" id="L2908"></span>
<span class="line" id="L2909">    <span class="tok-kw">var</span> codeface = <span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">0xC0DEFACE</span>);</span>
<span class="line" id="L2910">    <span class="tok-kw">for</span> (asBytes(&amp;codeface).*) |*b|</span>
<span class="line" id="L2911">        b.* = <span class="tok-number">0</span>;</span>
<span class="line" id="L2912">    <span class="tok-kw">try</span> testing.expect(codeface == <span class="tok-number">0</span>);</span>
<span class="line" id="L2913"></span>
<span class="line" id="L2914">    <span class="tok-kw">const</span> S = <span class="tok-kw">packed</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L2915">        a: <span class="tok-type">u8</span>,</span>
<span class="line" id="L2916">        b: <span class="tok-type">u8</span>,</span>
<span class="line" id="L2917">        c: <span class="tok-type">u8</span>,</span>
<span class="line" id="L2918">        d: <span class="tok-type">u8</span>,</span>
<span class="line" id="L2919">    };</span>
<span class="line" id="L2920"></span>
<span class="line" id="L2921">    <span class="tok-kw">const</span> inst = S{</span>
<span class="line" id="L2922">        .a = <span class="tok-number">0xBE</span>,</span>
<span class="line" id="L2923">        .b = <span class="tok-number">0xEF</span>,</span>
<span class="line" id="L2924">        .c = <span class="tok-number">0xDE</span>,</span>
<span class="line" id="L2925">        .d = <span class="tok-number">0xA1</span>,</span>
<span class="line" id="L2926">    };</span>
<span class="line" id="L2927">    <span class="tok-kw">switch</span> (native_endian) {</span>
<span class="line" id="L2928">        .Little =&gt; {</span>
<span class="line" id="L2929">            <span class="tok-kw">try</span> testing.expect(eql(<span class="tok-type">u8</span>, asBytes(&amp;inst), <span class="tok-str">&quot;\xBE\xEF\xDE\xA1&quot;</span>));</span>
<span class="line" id="L2930">        },</span>
<span class="line" id="L2931">        .Big =&gt; {</span>
<span class="line" id="L2932">            <span class="tok-kw">try</span> testing.expect(eql(<span class="tok-type">u8</span>, asBytes(&amp;inst), <span class="tok-str">&quot;\xA1\xDE\xEF\xBE&quot;</span>));</span>
<span class="line" id="L2933">        },</span>
<span class="line" id="L2934">    }</span>
<span class="line" id="L2935"></span>
<span class="line" id="L2936">    <span class="tok-kw">const</span> ZST = <span class="tok-kw">struct</span> {};</span>
<span class="line" id="L2937">    <span class="tok-kw">const</span> zero = ZST{};</span>
<span class="line" id="L2938">    <span class="tok-kw">try</span> testing.expect(eql(<span class="tok-type">u8</span>, asBytes(&amp;zero), <span class="tok-str">&quot;&quot;</span>));</span>
<span class="line" id="L2939">}</span>
<span class="line" id="L2940"></span>
<span class="line" id="L2941"><span class="tok-kw">test</span> <span class="tok-str">&quot;asBytes preserves pointer attributes&quot;</span> {</span>
<span class="line" id="L2942">    <span class="tok-kw">const</span> inArr: <span class="tok-type">u32</span> <span class="tok-kw">align</span>(<span class="tok-number">16</span>) = <span class="tok-number">0xDEADBEEF</span>;</span>
<span class="line" id="L2943">    <span class="tok-kw">const</span> inPtr = <span class="tok-builtin">@ptrCast</span>(*<span class="tok-kw">align</span>(<span class="tok-number">16</span>) <span class="tok-kw">const</span> <span class="tok-kw">volatile</span> <span class="tok-type">u32</span>, &amp;inArr);</span>
<span class="line" id="L2944">    <span class="tok-kw">const</span> outSlice = asBytes(inPtr);</span>
<span class="line" id="L2945"></span>
<span class="line" id="L2946">    <span class="tok-kw">const</span> in = <span class="tok-builtin">@typeInfo</span>(<span class="tok-builtin">@TypeOf</span>(inPtr)).Pointer;</span>
<span class="line" id="L2947">    <span class="tok-kw">const</span> out = <span class="tok-builtin">@typeInfo</span>(<span class="tok-builtin">@TypeOf</span>(outSlice)).Pointer;</span>
<span class="line" id="L2948"></span>
<span class="line" id="L2949">    <span class="tok-kw">try</span> testing.expectEqual(in.is_const, out.is_const);</span>
<span class="line" id="L2950">    <span class="tok-kw">try</span> testing.expectEqual(in.is_volatile, out.is_volatile);</span>
<span class="line" id="L2951">    <span class="tok-kw">try</span> testing.expectEqual(in.is_allowzero, out.is_allowzero);</span>
<span class="line" id="L2952">    <span class="tok-kw">try</span> testing.expectEqual(in.alignment, out.alignment);</span>
<span class="line" id="L2953">}</span>
<span class="line" id="L2954"></span>
<span class="line" id="L2955"><span class="tok-comment">/// Given any value, returns a copy of its bytes in an array.</span></span>
<span class="line" id="L2956"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">toBytes</span>(value: <span class="tok-kw">anytype</span>) [<span class="tok-builtin">@sizeOf</span>(<span class="tok-builtin">@TypeOf</span>(value))]<span class="tok-type">u8</span> {</span>
<span class="line" id="L2957">    <span class="tok-kw">return</span> asBytes(&amp;value).*;</span>
<span class="line" id="L2958">}</span>
<span class="line" id="L2959"></span>
<span class="line" id="L2960"><span class="tok-kw">test</span> <span class="tok-str">&quot;toBytes&quot;</span> {</span>
<span class="line" id="L2961">    <span class="tok-kw">var</span> my_bytes = toBytes(<span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">0x12345678</span>));</span>
<span class="line" id="L2962">    <span class="tok-kw">switch</span> (native_endian) {</span>
<span class="line" id="L2963">        .Big =&gt; <span class="tok-kw">try</span> testing.expect(eql(<span class="tok-type">u8</span>, &amp;my_bytes, <span class="tok-str">&quot;\x12\x34\x56\x78&quot;</span>)),</span>
<span class="line" id="L2964">        .Little =&gt; <span class="tok-kw">try</span> testing.expect(eql(<span class="tok-type">u8</span>, &amp;my_bytes, <span class="tok-str">&quot;\x78\x56\x34\x12&quot;</span>)),</span>
<span class="line" id="L2965">    }</span>
<span class="line" id="L2966"></span>
<span class="line" id="L2967">    my_bytes[<span class="tok-number">0</span>] = <span class="tok-str">'\x99'</span>;</span>
<span class="line" id="L2968">    <span class="tok-kw">switch</span> (native_endian) {</span>
<span class="line" id="L2969">        .Big =&gt; <span class="tok-kw">try</span> testing.expect(eql(<span class="tok-type">u8</span>, &amp;my_bytes, <span class="tok-str">&quot;\x99\x34\x56\x78&quot;</span>)),</span>
<span class="line" id="L2970">        .Little =&gt; <span class="tok-kw">try</span> testing.expect(eql(<span class="tok-type">u8</span>, &amp;my_bytes, <span class="tok-str">&quot;\x99\x56\x34\x12&quot;</span>)),</span>
<span class="line" id="L2971">    }</span>
<span class="line" id="L2972">}</span>
<span class="line" id="L2973"></span>
<span class="line" id="L2974"><span class="tok-kw">fn</span> <span class="tok-fn">BytesAsValueReturnType</span>(<span class="tok-kw">comptime</span> T: <span class="tok-type">type</span>, <span class="tok-kw">comptime</span> B: <span class="tok-type">type</span>) <span class="tok-type">type</span> {</span>
<span class="line" id="L2975">    <span class="tok-kw">const</span> size = <span class="tok-builtin">@as</span>(<span class="tok-type">usize</span>, <span class="tok-builtin">@sizeOf</span>(T));</span>
<span class="line" id="L2976"></span>
<span class="line" id="L2977">    <span class="tok-kw">if</span> (<span class="tok-kw">comptime</span> !trait.is(.Pointer)(B) <span class="tok-kw">or</span></span>
<span class="line" id="L2978">        (meta.Child(B) != [size]<span class="tok-type">u8</span> <span class="tok-kw">and</span> meta.Child(B) != [size:<span class="tok-number">0</span>]<span class="tok-type">u8</span>))</span>
<span class="line" id="L2979">    {</span>
<span class="line" id="L2980">        <span class="tok-kw">comptime</span> <span class="tok-kw">var</span> buf: [<span class="tok-number">100</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L2981">        <span class="tok-builtin">@compileError</span>(std.fmt.bufPrint(&amp;buf, <span class="tok-str">&quot;expected *[{}]u8, passed &quot;</span> ++ <span class="tok-builtin">@typeName</span>(B), .{size}) <span class="tok-kw">catch</span> <span class="tok-kw">unreachable</span>);</span>
<span class="line" id="L2982">    }</span>
<span class="line" id="L2983"></span>
<span class="line" id="L2984">    <span class="tok-kw">return</span> CopyPtrAttrs(B, .One, T);</span>
<span class="line" id="L2985">}</span>
<span class="line" id="L2986"></span>
<span class="line" id="L2987"><span class="tok-comment">/// Given a pointer to an array of bytes, returns a pointer to a value of the specified type</span></span>
<span class="line" id="L2988"><span class="tok-comment">/// backed by those bytes, preserving pointer attributes.</span></span>
<span class="line" id="L2989"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">bytesAsValue</span>(<span class="tok-kw">comptime</span> T: <span class="tok-type">type</span>, bytes: <span class="tok-kw">anytype</span>) BytesAsValueReturnType(T, <span class="tok-builtin">@TypeOf</span>(bytes)) {</span>
<span class="line" id="L2990">    <span class="tok-kw">return</span> <span class="tok-builtin">@ptrCast</span>(BytesAsValueReturnType(T, <span class="tok-builtin">@TypeOf</span>(bytes)), bytes);</span>
<span class="line" id="L2991">}</span>
<span class="line" id="L2992"></span>
<span class="line" id="L2993"><span class="tok-kw">test</span> <span class="tok-str">&quot;bytesAsValue&quot;</span> {</span>
<span class="line" id="L2994">    <span class="tok-kw">if</span> (builtin.zig_backend == .stage1) <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SkipZigTest;</span>
<span class="line" id="L2995"></span>
<span class="line" id="L2996">    <span class="tok-kw">const</span> deadbeef = <span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">0xDEADBEEF</span>);</span>
<span class="line" id="L2997">    <span class="tok-kw">const</span> deadbeef_bytes = <span class="tok-kw">switch</span> (native_endian) {</span>
<span class="line" id="L2998">        .Big =&gt; <span class="tok-str">&quot;\xDE\xAD\xBE\xEF&quot;</span>,</span>
<span class="line" id="L2999">        .Little =&gt; <span class="tok-str">&quot;\xEF\xBE\xAD\xDE&quot;</span>,</span>
<span class="line" id="L3000">    };</span>
<span class="line" id="L3001"></span>
<span class="line" id="L3002">    <span class="tok-kw">try</span> testing.expect(deadbeef == bytesAsValue(<span class="tok-type">u32</span>, deadbeef_bytes).*);</span>
<span class="line" id="L3003"></span>
<span class="line" id="L3004">    <span class="tok-kw">var</span> codeface_bytes: [<span class="tok-number">4</span>]<span class="tok-type">u8</span> = <span class="tok-kw">switch</span> (native_endian) {</span>
<span class="line" id="L3005">        .Big =&gt; <span class="tok-str">&quot;\xC0\xDE\xFA\xCE&quot;</span>,</span>
<span class="line" id="L3006">        .Little =&gt; <span class="tok-str">&quot;\xCE\xFA\xDE\xC0&quot;</span>,</span>
<span class="line" id="L3007">    }.*;</span>
<span class="line" id="L3008">    <span class="tok-kw">var</span> codeface = bytesAsValue(<span class="tok-type">u32</span>, &amp;codeface_bytes);</span>
<span class="line" id="L3009">    <span class="tok-kw">try</span> testing.expect(codeface.* == <span class="tok-number">0xC0DEFACE</span>);</span>
<span class="line" id="L3010">    codeface.* = <span class="tok-number">0</span>;</span>
<span class="line" id="L3011">    <span class="tok-kw">for</span> (codeface_bytes) |b|</span>
<span class="line" id="L3012">        <span class="tok-kw">try</span> testing.expect(b == <span class="tok-number">0</span>);</span>
<span class="line" id="L3013"></span>
<span class="line" id="L3014">    <span class="tok-kw">const</span> S = <span class="tok-kw">packed</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L3015">        a: <span class="tok-type">u8</span>,</span>
<span class="line" id="L3016">        b: <span class="tok-type">u8</span>,</span>
<span class="line" id="L3017">        c: <span class="tok-type">u8</span>,</span>
<span class="line" id="L3018">        d: <span class="tok-type">u8</span>,</span>
<span class="line" id="L3019">    };</span>
<span class="line" id="L3020"></span>
<span class="line" id="L3021">    <span class="tok-kw">const</span> inst = S{</span>
<span class="line" id="L3022">        .a = <span class="tok-number">0xBE</span>,</span>
<span class="line" id="L3023">        .b = <span class="tok-number">0xEF</span>,</span>
<span class="line" id="L3024">        .c = <span class="tok-number">0xDE</span>,</span>
<span class="line" id="L3025">        .d = <span class="tok-number">0xA1</span>,</span>
<span class="line" id="L3026">    };</span>
<span class="line" id="L3027">    <span class="tok-kw">const</span> inst_bytes = <span class="tok-kw">switch</span> (native_endian) {</span>
<span class="line" id="L3028">        .Little =&gt; <span class="tok-str">&quot;\xBE\xEF\xDE\xA1&quot;</span>,</span>
<span class="line" id="L3029">        .Big =&gt; <span class="tok-str">&quot;\xA1\xDE\xEF\xBE&quot;</span>,</span>
<span class="line" id="L3030">    };</span>
<span class="line" id="L3031">    <span class="tok-kw">const</span> inst2 = bytesAsValue(S, inst_bytes);</span>
<span class="line" id="L3032">    <span class="tok-kw">try</span> testing.expect(meta.eql(inst, inst2.*));</span>
<span class="line" id="L3033">}</span>
<span class="line" id="L3034"></span>
<span class="line" id="L3035"><span class="tok-kw">test</span> <span class="tok-str">&quot;bytesAsValue preserves pointer attributes&quot;</span> {</span>
<span class="line" id="L3036">    <span class="tok-kw">const</span> inArr <span class="tok-kw">align</span>(<span class="tok-number">16</span>) = [<span class="tok-number">4</span>]<span class="tok-type">u8</span>{ <span class="tok-number">0xDE</span>, <span class="tok-number">0xAD</span>, <span class="tok-number">0xBE</span>, <span class="tok-number">0xEF</span> };</span>
<span class="line" id="L3037">    <span class="tok-kw">const</span> inSlice = <span class="tok-builtin">@ptrCast</span>(*<span class="tok-kw">align</span>(<span class="tok-number">16</span>) <span class="tok-kw">const</span> <span class="tok-kw">volatile</span> [<span class="tok-number">4</span>]<span class="tok-type">u8</span>, &amp;inArr)[<span class="tok-number">0</span>..];</span>
<span class="line" id="L3038">    <span class="tok-kw">const</span> outPtr = bytesAsValue(<span class="tok-type">u32</span>, inSlice);</span>
<span class="line" id="L3039"></span>
<span class="line" id="L3040">    <span class="tok-kw">const</span> in = <span class="tok-builtin">@typeInfo</span>(<span class="tok-builtin">@TypeOf</span>(inSlice)).Pointer;</span>
<span class="line" id="L3041">    <span class="tok-kw">const</span> out = <span class="tok-builtin">@typeInfo</span>(<span class="tok-builtin">@TypeOf</span>(outPtr)).Pointer;</span>
<span class="line" id="L3042"></span>
<span class="line" id="L3043">    <span class="tok-kw">try</span> testing.expectEqual(in.is_const, out.is_const);</span>
<span class="line" id="L3044">    <span class="tok-kw">try</span> testing.expectEqual(in.is_volatile, out.is_volatile);</span>
<span class="line" id="L3045">    <span class="tok-kw">try</span> testing.expectEqual(in.is_allowzero, out.is_allowzero);</span>
<span class="line" id="L3046">    <span class="tok-kw">try</span> testing.expectEqual(in.alignment, out.alignment);</span>
<span class="line" id="L3047">}</span>
<span class="line" id="L3048"></span>
<span class="line" id="L3049"><span class="tok-comment">/// Given a pointer to an array of bytes, returns a value of the specified type backed by a</span></span>
<span class="line" id="L3050"><span class="tok-comment">/// copy of those bytes.</span></span>
<span class="line" id="L3051"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">bytesToValue</span>(<span class="tok-kw">comptime</span> T: <span class="tok-type">type</span>, bytes: <span class="tok-kw">anytype</span>) T {</span>
<span class="line" id="L3052">    <span class="tok-kw">return</span> bytesAsValue(T, bytes).*;</span>
<span class="line" id="L3053">}</span>
<span class="line" id="L3054"><span class="tok-kw">test</span> <span class="tok-str">&quot;bytesToValue&quot;</span> {</span>
<span class="line" id="L3055">    <span class="tok-kw">const</span> deadbeef_bytes = <span class="tok-kw">switch</span> (native_endian) {</span>
<span class="line" id="L3056">        .Big =&gt; <span class="tok-str">&quot;\xDE\xAD\xBE\xEF&quot;</span>,</span>
<span class="line" id="L3057">        .Little =&gt; <span class="tok-str">&quot;\xEF\xBE\xAD\xDE&quot;</span>,</span>
<span class="line" id="L3058">    };</span>
<span class="line" id="L3059"></span>
<span class="line" id="L3060">    <span class="tok-kw">const</span> deadbeef = bytesToValue(<span class="tok-type">u32</span>, deadbeef_bytes);</span>
<span class="line" id="L3061">    <span class="tok-kw">try</span> testing.expect(deadbeef == <span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">0xDEADBEEF</span>));</span>
<span class="line" id="L3062">}</span>
<span class="line" id="L3063"></span>
<span class="line" id="L3064"><span class="tok-kw">fn</span> <span class="tok-fn">BytesAsSliceReturnType</span>(<span class="tok-kw">comptime</span> T: <span class="tok-type">type</span>, <span class="tok-kw">comptime</span> bytesType: <span class="tok-type">type</span>) <span class="tok-type">type</span> {</span>
<span class="line" id="L3065">    <span class="tok-kw">if</span> (!(trait.isSlice(bytesType) <span class="tok-kw">or</span> trait.isPtrTo(.Array)(bytesType)) <span class="tok-kw">or</span> meta.Elem(bytesType) != <span class="tok-type">u8</span>) {</span>
<span class="line" id="L3066">        <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;expected []u8 or *[_]u8, passed &quot;</span> ++ <span class="tok-builtin">@typeName</span>(bytesType));</span>
<span class="line" id="L3067">    }</span>
<span class="line" id="L3068"></span>
<span class="line" id="L3069">    <span class="tok-kw">if</span> (trait.isPtrTo(.Array)(bytesType) <span class="tok-kw">and</span> <span class="tok-builtin">@typeInfo</span>(meta.Child(bytesType)).Array.len % <span class="tok-builtin">@sizeOf</span>(T) != <span class="tok-number">0</span>) {</span>
<span class="line" id="L3070">        <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;number of bytes in &quot;</span> ++ <span class="tok-builtin">@typeName</span>(bytesType) ++ <span class="tok-str">&quot; is not divisible by size of &quot;</span> ++ <span class="tok-builtin">@typeName</span>(T));</span>
<span class="line" id="L3071">    }</span>
<span class="line" id="L3072"></span>
<span class="line" id="L3073">    <span class="tok-kw">return</span> CopyPtrAttrs(bytesType, .Slice, T);</span>
<span class="line" id="L3074">}</span>
<span class="line" id="L3075"></span>
<span class="line" id="L3076"><span class="tok-comment">/// Given a slice of bytes, returns a slice of the specified type</span></span>
<span class="line" id="L3077"><span class="tok-comment">/// backed by those bytes, preserving pointer attributes.</span></span>
<span class="line" id="L3078"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">bytesAsSlice</span>(<span class="tok-kw">comptime</span> T: <span class="tok-type">type</span>, bytes: <span class="tok-kw">anytype</span>) BytesAsSliceReturnType(T, <span class="tok-builtin">@TypeOf</span>(bytes)) {</span>
<span class="line" id="L3079">    <span class="tok-comment">// let's not give an undefined pointer to @ptrCast</span>
</span>
<span class="line" id="L3080">    <span class="tok-comment">// it may be equal to zero and fail a null check</span>
</span>
<span class="line" id="L3081">    <span class="tok-kw">if</span> (bytes.len == <span class="tok-number">0</span>) {</span>
<span class="line" id="L3082">        <span class="tok-kw">return</span> &amp;[<span class="tok-number">0</span>]T{};</span>
<span class="line" id="L3083">    }</span>
<span class="line" id="L3084"></span>
<span class="line" id="L3085">    <span class="tok-kw">const</span> cast_target = CopyPtrAttrs(<span class="tok-builtin">@TypeOf</span>(bytes), .Many, T);</span>
<span class="line" id="L3086"></span>
<span class="line" id="L3087">    <span class="tok-kw">return</span> <span class="tok-builtin">@ptrCast</span>(cast_target, bytes)[<span class="tok-number">0</span>..<span class="tok-builtin">@divExact</span>(bytes.len, <span class="tok-builtin">@sizeOf</span>(T))];</span>
<span class="line" id="L3088">}</span>
<span class="line" id="L3089"></span>
<span class="line" id="L3090"><span class="tok-kw">test</span> <span class="tok-str">&quot;bytesAsSlice&quot;</span> {</span>
<span class="line" id="L3091">    {</span>
<span class="line" id="L3092">        <span class="tok-kw">const</span> bytes = [_]<span class="tok-type">u8</span>{ <span class="tok-number">0xDE</span>, <span class="tok-number">0xAD</span>, <span class="tok-number">0xBE</span>, <span class="tok-number">0xEF</span> };</span>
<span class="line" id="L3093">        <span class="tok-kw">const</span> slice = bytesAsSlice(<span class="tok-type">u16</span>, bytes[<span class="tok-number">0</span>..]);</span>
<span class="line" id="L3094">        <span class="tok-kw">try</span> testing.expect(slice.len == <span class="tok-number">2</span>);</span>
<span class="line" id="L3095">        <span class="tok-kw">try</span> testing.expect(bigToNative(<span class="tok-type">u16</span>, slice[<span class="tok-number">0</span>]) == <span class="tok-number">0xDEAD</span>);</span>
<span class="line" id="L3096">        <span class="tok-kw">try</span> testing.expect(bigToNative(<span class="tok-type">u16</span>, slice[<span class="tok-number">1</span>]) == <span class="tok-number">0xBEEF</span>);</span>
<span class="line" id="L3097">    }</span>
<span class="line" id="L3098">    {</span>
<span class="line" id="L3099">        <span class="tok-kw">const</span> bytes = [_]<span class="tok-type">u8</span>{ <span class="tok-number">0xDE</span>, <span class="tok-number">0xAD</span>, <span class="tok-number">0xBE</span>, <span class="tok-number">0xEF</span> };</span>
<span class="line" id="L3100">        <span class="tok-kw">var</span> runtime_zero: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L3101">        <span class="tok-kw">const</span> slice = bytesAsSlice(<span class="tok-type">u16</span>, bytes[runtime_zero..]);</span>
<span class="line" id="L3102">        <span class="tok-kw">try</span> testing.expect(slice.len == <span class="tok-number">2</span>);</span>
<span class="line" id="L3103">        <span class="tok-kw">try</span> testing.expect(bigToNative(<span class="tok-type">u16</span>, slice[<span class="tok-number">0</span>]) == <span class="tok-number">0xDEAD</span>);</span>
<span class="line" id="L3104">        <span class="tok-kw">try</span> testing.expect(bigToNative(<span class="tok-type">u16</span>, slice[<span class="tok-number">1</span>]) == <span class="tok-number">0xBEEF</span>);</span>
<span class="line" id="L3105">    }</span>
<span class="line" id="L3106">}</span>
<span class="line" id="L3107"></span>
<span class="line" id="L3108"><span class="tok-kw">test</span> <span class="tok-str">&quot;bytesAsSlice keeps pointer alignment&quot;</span> {</span>
<span class="line" id="L3109">    {</span>
<span class="line" id="L3110">        <span class="tok-kw">var</span> bytes = [_]<span class="tok-type">u8</span>{ <span class="tok-number">0x01</span>, <span class="tok-number">0x02</span>, <span class="tok-number">0x03</span>, <span class="tok-number">0x04</span> };</span>
<span class="line" id="L3111">        <span class="tok-kw">const</span> numbers = bytesAsSlice(<span class="tok-type">u32</span>, bytes[<span class="tok-number">0</span>..]);</span>
<span class="line" id="L3112">        <span class="tok-kw">comptime</span> <span class="tok-kw">try</span> testing.expect(<span class="tok-builtin">@TypeOf</span>(numbers) == []<span class="tok-kw">align</span>(<span class="tok-builtin">@alignOf</span>(<span class="tok-builtin">@TypeOf</span>(bytes))) <span class="tok-type">u32</span>);</span>
<span class="line" id="L3113">    }</span>
<span class="line" id="L3114">    {</span>
<span class="line" id="L3115">        <span class="tok-kw">var</span> bytes = [_]<span class="tok-type">u8</span>{ <span class="tok-number">0x01</span>, <span class="tok-number">0x02</span>, <span class="tok-number">0x03</span>, <span class="tok-number">0x04</span> };</span>
<span class="line" id="L3116">        <span class="tok-kw">var</span> runtime_zero: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L3117">        <span class="tok-kw">const</span> numbers = bytesAsSlice(<span class="tok-type">u32</span>, bytes[runtime_zero..]);</span>
<span class="line" id="L3118">        <span class="tok-kw">comptime</span> <span class="tok-kw">try</span> testing.expect(<span class="tok-builtin">@TypeOf</span>(numbers) == []<span class="tok-kw">align</span>(<span class="tok-builtin">@alignOf</span>(<span class="tok-builtin">@TypeOf</span>(bytes))) <span class="tok-type">u32</span>);</span>
<span class="line" id="L3119">    }</span>
<span class="line" id="L3120">}</span>
<span class="line" id="L3121"></span>
<span class="line" id="L3122"><span class="tok-kw">test</span> <span class="tok-str">&quot;bytesAsSlice on a packed struct&quot;</span> {</span>
<span class="line" id="L3123">    <span class="tok-kw">const</span> F = <span class="tok-kw">packed</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L3124">        a: <span class="tok-type">u8</span>,</span>
<span class="line" id="L3125">    };</span>
<span class="line" id="L3126"></span>
<span class="line" id="L3127">    <span class="tok-kw">var</span> b = [<span class="tok-number">1</span>]<span class="tok-type">u8</span>{<span class="tok-number">9</span>};</span>
<span class="line" id="L3128">    <span class="tok-kw">var</span> f = bytesAsSlice(F, &amp;b);</span>
<span class="line" id="L3129">    <span class="tok-kw">try</span> testing.expect(f[<span class="tok-number">0</span>].a == <span class="tok-number">9</span>);</span>
<span class="line" id="L3130">}</span>
<span class="line" id="L3131"></span>
<span class="line" id="L3132"><span class="tok-kw">test</span> <span class="tok-str">&quot;bytesAsSlice with specified alignment&quot;</span> {</span>
<span class="line" id="L3133">    <span class="tok-kw">var</span> bytes <span class="tok-kw">align</span>(<span class="tok-number">4</span>) = [_]<span class="tok-type">u8</span>{</span>
<span class="line" id="L3134">        <span class="tok-number">0x33</span>,</span>
<span class="line" id="L3135">        <span class="tok-number">0x33</span>,</span>
<span class="line" id="L3136">        <span class="tok-number">0x33</span>,</span>
<span class="line" id="L3137">        <span class="tok-number">0x33</span>,</span>
<span class="line" id="L3138">    };</span>
<span class="line" id="L3139">    <span class="tok-kw">const</span> slice: []<span class="tok-type">u32</span> = std.mem.bytesAsSlice(<span class="tok-type">u32</span>, bytes[<span class="tok-number">0</span>..]);</span>
<span class="line" id="L3140">    <span class="tok-kw">try</span> testing.expect(slice[<span class="tok-number">0</span>] == <span class="tok-number">0x33333333</span>);</span>
<span class="line" id="L3141">}</span>
<span class="line" id="L3142"></span>
<span class="line" id="L3143"><span class="tok-kw">test</span> <span class="tok-str">&quot;bytesAsSlice preserves pointer attributes&quot;</span> {</span>
<span class="line" id="L3144">    <span class="tok-kw">const</span> inArr <span class="tok-kw">align</span>(<span class="tok-number">16</span>) = [<span class="tok-number">4</span>]<span class="tok-type">u8</span>{ <span class="tok-number">0xDE</span>, <span class="tok-number">0xAD</span>, <span class="tok-number">0xBE</span>, <span class="tok-number">0xEF</span> };</span>
<span class="line" id="L3145">    <span class="tok-kw">const</span> inSlice = <span class="tok-builtin">@ptrCast</span>(*<span class="tok-kw">align</span>(<span class="tok-number">16</span>) <span class="tok-kw">const</span> <span class="tok-kw">volatile</span> [<span class="tok-number">4</span>]<span class="tok-type">u8</span>, &amp;inArr)[<span class="tok-number">0</span>..];</span>
<span class="line" id="L3146">    <span class="tok-kw">const</span> outSlice = bytesAsSlice(<span class="tok-type">u16</span>, inSlice);</span>
<span class="line" id="L3147"></span>
<span class="line" id="L3148">    <span class="tok-kw">const</span> in = <span class="tok-builtin">@typeInfo</span>(<span class="tok-builtin">@TypeOf</span>(inSlice)).Pointer;</span>
<span class="line" id="L3149">    <span class="tok-kw">const</span> out = <span class="tok-builtin">@typeInfo</span>(<span class="tok-builtin">@TypeOf</span>(outSlice)).Pointer;</span>
<span class="line" id="L3150"></span>
<span class="line" id="L3151">    <span class="tok-kw">try</span> testing.expectEqual(in.is_const, out.is_const);</span>
<span class="line" id="L3152">    <span class="tok-kw">try</span> testing.expectEqual(in.is_volatile, out.is_volatile);</span>
<span class="line" id="L3153">    <span class="tok-kw">try</span> testing.expectEqual(in.is_allowzero, out.is_allowzero);</span>
<span class="line" id="L3154">    <span class="tok-kw">try</span> testing.expectEqual(in.alignment, out.alignment);</span>
<span class="line" id="L3155">}</span>
<span class="line" id="L3156"></span>
<span class="line" id="L3157"><span class="tok-kw">fn</span> <span class="tok-fn">SliceAsBytesReturnType</span>(<span class="tok-kw">comptime</span> sliceType: <span class="tok-type">type</span>) <span class="tok-type">type</span> {</span>
<span class="line" id="L3158">    <span class="tok-kw">if</span> (!trait.isSlice(sliceType) <span class="tok-kw">and</span> !trait.isPtrTo(.Array)(sliceType)) {</span>
<span class="line" id="L3159">        <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;expected []T or *[_]T, passed &quot;</span> ++ <span class="tok-builtin">@typeName</span>(sliceType));</span>
<span class="line" id="L3160">    }</span>
<span class="line" id="L3161"></span>
<span class="line" id="L3162">    <span class="tok-kw">return</span> CopyPtrAttrs(sliceType, .Slice, <span class="tok-type">u8</span>);</span>
<span class="line" id="L3163">}</span>
<span class="line" id="L3164"></span>
<span class="line" id="L3165"><span class="tok-comment">/// Given a slice, returns a slice of the underlying bytes, preserving pointer attributes.</span></span>
<span class="line" id="L3166"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">sliceAsBytes</span>(slice: <span class="tok-kw">anytype</span>) SliceAsBytesReturnType(<span class="tok-builtin">@TypeOf</span>(slice)) {</span>
<span class="line" id="L3167">    <span class="tok-kw">const</span> Slice = <span class="tok-builtin">@TypeOf</span>(slice);</span>
<span class="line" id="L3168"></span>
<span class="line" id="L3169">    <span class="tok-comment">// let's not give an undefined pointer to @ptrCast</span>
</span>
<span class="line" id="L3170">    <span class="tok-comment">// it may be equal to zero and fail a null check</span>
</span>
<span class="line" id="L3171">    <span class="tok-kw">if</span> (slice.len == <span class="tok-number">0</span> <span class="tok-kw">and</span> <span class="tok-kw">comptime</span> meta.sentinel(Slice) == <span class="tok-null">null</span>) {</span>
<span class="line" id="L3172">        <span class="tok-kw">return</span> &amp;[<span class="tok-number">0</span>]<span class="tok-type">u8</span>{};</span>
<span class="line" id="L3173">    }</span>
<span class="line" id="L3174"></span>
<span class="line" id="L3175">    <span class="tok-kw">const</span> cast_target = CopyPtrAttrs(Slice, .Many, <span class="tok-type">u8</span>);</span>
<span class="line" id="L3176"></span>
<span class="line" id="L3177">    <span class="tok-kw">return</span> <span class="tok-builtin">@ptrCast</span>(cast_target, slice)[<span class="tok-number">0</span> .. slice.len * <span class="tok-builtin">@sizeOf</span>(meta.Elem(Slice))];</span>
<span class="line" id="L3178">}</span>
<span class="line" id="L3179"></span>
<span class="line" id="L3180"><span class="tok-kw">test</span> <span class="tok-str">&quot;sliceAsBytes&quot;</span> {</span>
<span class="line" id="L3181">    <span class="tok-kw">const</span> bytes = [_]<span class="tok-type">u16</span>{ <span class="tok-number">0xDEAD</span>, <span class="tok-number">0xBEEF</span> };</span>
<span class="line" id="L3182">    <span class="tok-kw">const</span> slice = sliceAsBytes(bytes[<span class="tok-number">0</span>..]);</span>
<span class="line" id="L3183">    <span class="tok-kw">try</span> testing.expect(slice.len == <span class="tok-number">4</span>);</span>
<span class="line" id="L3184">    <span class="tok-kw">try</span> testing.expect(eql(<span class="tok-type">u8</span>, slice, <span class="tok-kw">switch</span> (native_endian) {</span>
<span class="line" id="L3185">        .Big =&gt; <span class="tok-str">&quot;\xDE\xAD\xBE\xEF&quot;</span>,</span>
<span class="line" id="L3186">        .Little =&gt; <span class="tok-str">&quot;\xAD\xDE\xEF\xBE&quot;</span>,</span>
<span class="line" id="L3187">    }));</span>
<span class="line" id="L3188">}</span>
<span class="line" id="L3189"></span>
<span class="line" id="L3190"><span class="tok-kw">test</span> <span class="tok-str">&quot;sliceAsBytes with sentinel slice&quot;</span> {</span>
<span class="line" id="L3191">    <span class="tok-kw">const</span> empty_string: [:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span> = <span class="tok-str">&quot;&quot;</span>;</span>
<span class="line" id="L3192">    <span class="tok-kw">const</span> bytes = sliceAsBytes(empty_string);</span>
<span class="line" id="L3193">    <span class="tok-kw">try</span> testing.expect(bytes.len == <span class="tok-number">0</span>);</span>
<span class="line" id="L3194">}</span>
<span class="line" id="L3195"></span>
<span class="line" id="L3196"><span class="tok-kw">test</span> <span class="tok-str">&quot;sliceAsBytes packed struct at runtime and comptime&quot;</span> {</span>
<span class="line" id="L3197">    <span class="tok-kw">if</span> (builtin.zig_backend == .stage1) <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SkipZigTest;</span>
<span class="line" id="L3198"></span>
<span class="line" id="L3199">    <span class="tok-kw">const</span> Foo = <span class="tok-kw">packed</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L3200">        a: <span class="tok-type">u4</span>,</span>
<span class="line" id="L3201">        b: <span class="tok-type">u4</span>,</span>
<span class="line" id="L3202">    };</span>
<span class="line" id="L3203">    <span class="tok-kw">const</span> S = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L3204">        <span class="tok-kw">fn</span> <span class="tok-fn">doTheTest</span>() !<span class="tok-type">void</span> {</span>
<span class="line" id="L3205">            <span class="tok-kw">var</span> foo: Foo = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L3206">            <span class="tok-kw">var</span> slice = sliceAsBytes(<span class="tok-builtin">@as</span>(*[<span class="tok-number">1</span>]Foo, &amp;foo)[<span class="tok-number">0</span>..<span class="tok-number">1</span>]);</span>
<span class="line" id="L3207">            slice[<span class="tok-number">0</span>] = <span class="tok-number">0x13</span>;</span>
<span class="line" id="L3208">            <span class="tok-kw">try</span> testing.expect(foo.a == <span class="tok-number">0x3</span>);</span>
<span class="line" id="L3209">            <span class="tok-kw">try</span> testing.expect(foo.b == <span class="tok-number">0x1</span>);</span>
<span class="line" id="L3210">        }</span>
<span class="line" id="L3211">    };</span>
<span class="line" id="L3212">    <span class="tok-kw">try</span> S.doTheTest();</span>
<span class="line" id="L3213">    <span class="tok-kw">comptime</span> <span class="tok-kw">try</span> S.doTheTest();</span>
<span class="line" id="L3214">}</span>
<span class="line" id="L3215"></span>
<span class="line" id="L3216"><span class="tok-kw">test</span> <span class="tok-str">&quot;sliceAsBytes and bytesAsSlice back&quot;</span> {</span>
<span class="line" id="L3217">    <span class="tok-kw">try</span> testing.expect(<span class="tok-builtin">@sizeOf</span>(<span class="tok-type">i32</span>) == <span class="tok-number">4</span>);</span>
<span class="line" id="L3218"></span>
<span class="line" id="L3219">    <span class="tok-kw">var</span> big_thing_array = [_]<span class="tok-type">i32</span>{ <span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">4</span> };</span>
<span class="line" id="L3220">    <span class="tok-kw">const</span> big_thing_slice: []<span class="tok-type">i32</span> = big_thing_array[<span class="tok-number">0</span>..];</span>
<span class="line" id="L3221"></span>
<span class="line" id="L3222">    <span class="tok-kw">const</span> bytes = sliceAsBytes(big_thing_slice);</span>
<span class="line" id="L3223">    <span class="tok-kw">try</span> testing.expect(bytes.len == <span class="tok-number">4</span> * <span class="tok-number">4</span>);</span>
<span class="line" id="L3224"></span>
<span class="line" id="L3225">    bytes[<span class="tok-number">4</span>] = <span class="tok-number">0</span>;</span>
<span class="line" id="L3226">    bytes[<span class="tok-number">5</span>] = <span class="tok-number">0</span>;</span>
<span class="line" id="L3227">    bytes[<span class="tok-number">6</span>] = <span class="tok-number">0</span>;</span>
<span class="line" id="L3228">    bytes[<span class="tok-number">7</span>] = <span class="tok-number">0</span>;</span>
<span class="line" id="L3229">    <span class="tok-kw">try</span> testing.expect(big_thing_slice[<span class="tok-number">1</span>] == <span class="tok-number">0</span>);</span>
<span class="line" id="L3230"></span>
<span class="line" id="L3231">    <span class="tok-kw">const</span> big_thing_again = bytesAsSlice(<span class="tok-type">i32</span>, bytes);</span>
<span class="line" id="L3232">    <span class="tok-kw">try</span> testing.expect(big_thing_again[<span class="tok-number">2</span>] == <span class="tok-number">3</span>);</span>
<span class="line" id="L3233"></span>
<span class="line" id="L3234">    big_thing_again[<span class="tok-number">2</span>] = -<span class="tok-number">1</span>;</span>
<span class="line" id="L3235">    <span class="tok-kw">try</span> testing.expect(bytes[<span class="tok-number">8</span>] == math.maxInt(<span class="tok-type">u8</span>));</span>
<span class="line" id="L3236">    <span class="tok-kw">try</span> testing.expect(bytes[<span class="tok-number">9</span>] == math.maxInt(<span class="tok-type">u8</span>));</span>
<span class="line" id="L3237">    <span class="tok-kw">try</span> testing.expect(bytes[<span class="tok-number">10</span>] == math.maxInt(<span class="tok-type">u8</span>));</span>
<span class="line" id="L3238">    <span class="tok-kw">try</span> testing.expect(bytes[<span class="tok-number">11</span>] == math.maxInt(<span class="tok-type">u8</span>));</span>
<span class="line" id="L3239">}</span>
<span class="line" id="L3240"></span>
<span class="line" id="L3241"><span class="tok-kw">test</span> <span class="tok-str">&quot;sliceAsBytes preserves pointer attributes&quot;</span> {</span>
<span class="line" id="L3242">    <span class="tok-kw">const</span> inArr <span class="tok-kw">align</span>(<span class="tok-number">16</span>) = [<span class="tok-number">2</span>]<span class="tok-type">u16</span>{ <span class="tok-number">0xDEAD</span>, <span class="tok-number">0xBEEF</span> };</span>
<span class="line" id="L3243">    <span class="tok-kw">const</span> inSlice = <span class="tok-builtin">@ptrCast</span>(*<span class="tok-kw">align</span>(<span class="tok-number">16</span>) <span class="tok-kw">const</span> <span class="tok-kw">volatile</span> [<span class="tok-number">2</span>]<span class="tok-type">u16</span>, &amp;inArr)[<span class="tok-number">0</span>..];</span>
<span class="line" id="L3244">    <span class="tok-kw">const</span> outSlice = sliceAsBytes(inSlice);</span>
<span class="line" id="L3245"></span>
<span class="line" id="L3246">    <span class="tok-kw">const</span> in = <span class="tok-builtin">@typeInfo</span>(<span class="tok-builtin">@TypeOf</span>(inSlice)).Pointer;</span>
<span class="line" id="L3247">    <span class="tok-kw">const</span> out = <span class="tok-builtin">@typeInfo</span>(<span class="tok-builtin">@TypeOf</span>(outSlice)).Pointer;</span>
<span class="line" id="L3248"></span>
<span class="line" id="L3249">    <span class="tok-kw">try</span> testing.expectEqual(in.is_const, out.is_const);</span>
<span class="line" id="L3250">    <span class="tok-kw">try</span> testing.expectEqual(in.is_volatile, out.is_volatile);</span>
<span class="line" id="L3251">    <span class="tok-kw">try</span> testing.expectEqual(in.is_allowzero, out.is_allowzero);</span>
<span class="line" id="L3252">    <span class="tok-kw">try</span> testing.expectEqual(in.alignment, out.alignment);</span>
<span class="line" id="L3253">}</span>
<span class="line" id="L3254"></span>
<span class="line" id="L3255"><span class="tok-comment">/// Round an address up to the nearest aligned address</span></span>
<span class="line" id="L3256"><span class="tok-comment">/// The alignment must be a power of 2 and greater than 0.</span></span>
<span class="line" id="L3257"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">alignForward</span>(addr: <span class="tok-type">usize</span>, alignment: <span class="tok-type">usize</span>) <span class="tok-type">usize</span> {</span>
<span class="line" id="L3258">    <span class="tok-kw">return</span> alignForwardGeneric(<span class="tok-type">usize</span>, addr, alignment);</span>
<span class="line" id="L3259">}</span>
<span class="line" id="L3260"></span>
<span class="line" id="L3261"><span class="tok-comment">/// Round an address up to the nearest aligned address</span></span>
<span class="line" id="L3262"><span class="tok-comment">/// The alignment must be a power of 2 and greater than 0.</span></span>
<span class="line" id="L3263"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">alignForwardGeneric</span>(<span class="tok-kw">comptime</span> T: <span class="tok-type">type</span>, addr: T, alignment: T) T {</span>
<span class="line" id="L3264">    <span class="tok-kw">return</span> alignBackwardGeneric(T, addr + (alignment - <span class="tok-number">1</span>), alignment);</span>
<span class="line" id="L3265">}</span>
<span class="line" id="L3266"></span>
<span class="line" id="L3267"><span class="tok-comment">/// Force an evaluation of the expression; this tries to prevent</span></span>
<span class="line" id="L3268"><span class="tok-comment">/// the compiler from optimizing the computation away even if the</span></span>
<span class="line" id="L3269"><span class="tok-comment">/// result eventually gets discarded.</span></span>
<span class="line" id="L3270"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">doNotOptimizeAway</span>(val: <span class="tok-kw">anytype</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L3271">    <span class="tok-kw">asm</span> <span class="tok-kw">volatile</span> (<span class="tok-str">&quot;&quot;</span></span>
<span class="line" id="L3272">        :</span>
<span class="line" id="L3273">        : [val] <span class="tok-str">&quot;rm&quot;</span> (val),</span>
<span class="line" id="L3274">        : <span class="tok-str">&quot;memory&quot;</span></span>
<span class="line" id="L3275">    );</span>
<span class="line" id="L3276">}</span>
<span class="line" id="L3277"></span>
<span class="line" id="L3278"><span class="tok-kw">test</span> <span class="tok-str">&quot;alignForward&quot;</span> {</span>
<span class="line" id="L3279">    <span class="tok-kw">try</span> testing.expect(alignForward(<span class="tok-number">1</span>, <span class="tok-number">1</span>) == <span class="tok-number">1</span>);</span>
<span class="line" id="L3280">    <span class="tok-kw">try</span> testing.expect(alignForward(<span class="tok-number">2</span>, <span class="tok-number">1</span>) == <span class="tok-number">2</span>);</span>
<span class="line" id="L3281">    <span class="tok-kw">try</span> testing.expect(alignForward(<span class="tok-number">1</span>, <span class="tok-number">2</span>) == <span class="tok-number">2</span>);</span>
<span class="line" id="L3282">    <span class="tok-kw">try</span> testing.expect(alignForward(<span class="tok-number">2</span>, <span class="tok-number">2</span>) == <span class="tok-number">2</span>);</span>
<span class="line" id="L3283">    <span class="tok-kw">try</span> testing.expect(alignForward(<span class="tok-number">3</span>, <span class="tok-number">2</span>) == <span class="tok-number">4</span>);</span>
<span class="line" id="L3284">    <span class="tok-kw">try</span> testing.expect(alignForward(<span class="tok-number">4</span>, <span class="tok-number">2</span>) == <span class="tok-number">4</span>);</span>
<span class="line" id="L3285">    <span class="tok-kw">try</span> testing.expect(alignForward(<span class="tok-number">7</span>, <span class="tok-number">8</span>) == <span class="tok-number">8</span>);</span>
<span class="line" id="L3286">    <span class="tok-kw">try</span> testing.expect(alignForward(<span class="tok-number">8</span>, <span class="tok-number">8</span>) == <span class="tok-number">8</span>);</span>
<span class="line" id="L3287">    <span class="tok-kw">try</span> testing.expect(alignForward(<span class="tok-number">9</span>, <span class="tok-number">8</span>) == <span class="tok-number">16</span>);</span>
<span class="line" id="L3288">    <span class="tok-kw">try</span> testing.expect(alignForward(<span class="tok-number">15</span>, <span class="tok-number">8</span>) == <span class="tok-number">16</span>);</span>
<span class="line" id="L3289">    <span class="tok-kw">try</span> testing.expect(alignForward(<span class="tok-number">16</span>, <span class="tok-number">8</span>) == <span class="tok-number">16</span>);</span>
<span class="line" id="L3290">    <span class="tok-kw">try</span> testing.expect(alignForward(<span class="tok-number">17</span>, <span class="tok-number">8</span>) == <span class="tok-number">24</span>);</span>
<span class="line" id="L3291">}</span>
<span class="line" id="L3292"></span>
<span class="line" id="L3293"><span class="tok-comment">/// Round an address up to the previous aligned address</span></span>
<span class="line" id="L3294"><span class="tok-comment">/// Unlike `alignBackward`, `alignment` can be any positive number, not just a power of 2.</span></span>
<span class="line" id="L3295"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">alignBackwardAnyAlign</span>(i: <span class="tok-type">usize</span>, alignment: <span class="tok-type">usize</span>) <span class="tok-type">usize</span> {</span>
<span class="line" id="L3296">    <span class="tok-kw">if</span> (<span class="tok-builtin">@popCount</span>(<span class="tok-type">usize</span>, alignment) == <span class="tok-number">1</span>)</span>
<span class="line" id="L3297">        <span class="tok-kw">return</span> alignBackward(i, alignment);</span>
<span class="line" id="L3298">    assert(alignment != <span class="tok-number">0</span>);</span>
<span class="line" id="L3299">    <span class="tok-kw">return</span> i - <span class="tok-builtin">@mod</span>(i, alignment);</span>
<span class="line" id="L3300">}</span>
<span class="line" id="L3301"></span>
<span class="line" id="L3302"><span class="tok-comment">/// Round an address up to the previous aligned address</span></span>
<span class="line" id="L3303"><span class="tok-comment">/// The alignment must be a power of 2 and greater than 0.</span></span>
<span class="line" id="L3304"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">alignBackward</span>(addr: <span class="tok-type">usize</span>, alignment: <span class="tok-type">usize</span>) <span class="tok-type">usize</span> {</span>
<span class="line" id="L3305">    <span class="tok-kw">return</span> alignBackwardGeneric(<span class="tok-type">usize</span>, addr, alignment);</span>
<span class="line" id="L3306">}</span>
<span class="line" id="L3307"></span>
<span class="line" id="L3308"><span class="tok-comment">/// Round an address up to the previous aligned address</span></span>
<span class="line" id="L3309"><span class="tok-comment">/// The alignment must be a power of 2 and greater than 0.</span></span>
<span class="line" id="L3310"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">alignBackwardGeneric</span>(<span class="tok-kw">comptime</span> T: <span class="tok-type">type</span>, addr: T, alignment: T) T {</span>
<span class="line" id="L3311">    assert(<span class="tok-builtin">@popCount</span>(T, alignment) == <span class="tok-number">1</span>);</span>
<span class="line" id="L3312">    <span class="tok-comment">// 000010000 // example alignment</span>
</span>
<span class="line" id="L3313">    <span class="tok-comment">// 000001111 // subtract 1</span>
</span>
<span class="line" id="L3314">    <span class="tok-comment">// 111110000 // binary not</span>
</span>
<span class="line" id="L3315">    <span class="tok-kw">return</span> addr &amp; ~(alignment - <span class="tok-number">1</span>);</span>
<span class="line" id="L3316">}</span>
<span class="line" id="L3317"></span>
<span class="line" id="L3318"><span class="tok-comment">/// Returns whether `alignment` is a valid alignment, meaning it is</span></span>
<span class="line" id="L3319"><span class="tok-comment">/// a positive power of 2.</span></span>
<span class="line" id="L3320"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">isValidAlign</span>(alignment: <span class="tok-type">u29</span>) <span class="tok-type">bool</span> {</span>
<span class="line" id="L3321">    <span class="tok-kw">return</span> <span class="tok-builtin">@popCount</span>(<span class="tok-type">u29</span>, alignment) == <span class="tok-number">1</span>;</span>
<span class="line" id="L3322">}</span>
<span class="line" id="L3323"></span>
<span class="line" id="L3324"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">isAlignedAnyAlign</span>(i: <span class="tok-type">usize</span>, alignment: <span class="tok-type">usize</span>) <span class="tok-type">bool</span> {</span>
<span class="line" id="L3325">    <span class="tok-kw">if</span> (<span class="tok-builtin">@popCount</span>(<span class="tok-type">usize</span>, alignment) == <span class="tok-number">1</span>)</span>
<span class="line" id="L3326">        <span class="tok-kw">return</span> isAligned(i, alignment);</span>
<span class="line" id="L3327">    assert(alignment != <span class="tok-number">0</span>);</span>
<span class="line" id="L3328">    <span class="tok-kw">return</span> <span class="tok-number">0</span> == <span class="tok-builtin">@mod</span>(i, alignment);</span>
<span class="line" id="L3329">}</span>
<span class="line" id="L3330"></span>
<span class="line" id="L3331"><span class="tok-comment">/// Given an address and an alignment, return true if the address is a multiple of the alignment</span></span>
<span class="line" id="L3332"><span class="tok-comment">/// The alignment must be a power of 2 and greater than 0.</span></span>
<span class="line" id="L3333"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">isAligned</span>(addr: <span class="tok-type">usize</span>, alignment: <span class="tok-type">usize</span>) <span class="tok-type">bool</span> {</span>
<span class="line" id="L3334">    <span class="tok-kw">return</span> isAlignedGeneric(<span class="tok-type">u64</span>, addr, alignment);</span>
<span class="line" id="L3335">}</span>
<span class="line" id="L3336"></span>
<span class="line" id="L3337"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">isAlignedGeneric</span>(<span class="tok-kw">comptime</span> T: <span class="tok-type">type</span>, addr: T, alignment: T) <span class="tok-type">bool</span> {</span>
<span class="line" id="L3338">    <span class="tok-kw">return</span> alignBackwardGeneric(T, addr, alignment) == addr;</span>
<span class="line" id="L3339">}</span>
<span class="line" id="L3340"></span>
<span class="line" id="L3341"><span class="tok-kw">test</span> <span class="tok-str">&quot;isAligned&quot;</span> {</span>
<span class="line" id="L3342">    <span class="tok-kw">try</span> testing.expect(isAligned(<span class="tok-number">0</span>, <span class="tok-number">4</span>));</span>
<span class="line" id="L3343">    <span class="tok-kw">try</span> testing.expect(isAligned(<span class="tok-number">1</span>, <span class="tok-number">1</span>));</span>
<span class="line" id="L3344">    <span class="tok-kw">try</span> testing.expect(isAligned(<span class="tok-number">2</span>, <span class="tok-number">1</span>));</span>
<span class="line" id="L3345">    <span class="tok-kw">try</span> testing.expect(isAligned(<span class="tok-number">2</span>, <span class="tok-number">2</span>));</span>
<span class="line" id="L3346">    <span class="tok-kw">try</span> testing.expect(!isAligned(<span class="tok-number">2</span>, <span class="tok-number">4</span>));</span>
<span class="line" id="L3347">    <span class="tok-kw">try</span> testing.expect(isAligned(<span class="tok-number">3</span>, <span class="tok-number">1</span>));</span>
<span class="line" id="L3348">    <span class="tok-kw">try</span> testing.expect(!isAligned(<span class="tok-number">3</span>, <span class="tok-number">2</span>));</span>
<span class="line" id="L3349">    <span class="tok-kw">try</span> testing.expect(!isAligned(<span class="tok-number">3</span>, <span class="tok-number">4</span>));</span>
<span class="line" id="L3350">    <span class="tok-kw">try</span> testing.expect(isAligned(<span class="tok-number">4</span>, <span class="tok-number">4</span>));</span>
<span class="line" id="L3351">    <span class="tok-kw">try</span> testing.expect(isAligned(<span class="tok-number">4</span>, <span class="tok-number">2</span>));</span>
<span class="line" id="L3352">    <span class="tok-kw">try</span> testing.expect(isAligned(<span class="tok-number">4</span>, <span class="tok-number">1</span>));</span>
<span class="line" id="L3353">    <span class="tok-kw">try</span> testing.expect(!isAligned(<span class="tok-number">4</span>, <span class="tok-number">8</span>));</span>
<span class="line" id="L3354">    <span class="tok-kw">try</span> testing.expect(!isAligned(<span class="tok-number">4</span>, <span class="tok-number">16</span>));</span>
<span class="line" id="L3355">}</span>
<span class="line" id="L3356"></span>
<span class="line" id="L3357"><span class="tok-kw">test</span> <span class="tok-str">&quot;freeing empty string with null-terminated sentinel&quot;</span> {</span>
<span class="line" id="L3358">    <span class="tok-kw">const</span> empty_string = <span class="tok-kw">try</span> testing.allocator.dupeZ(<span class="tok-type">u8</span>, <span class="tok-str">&quot;&quot;</span>);</span>
<span class="line" id="L3359">    testing.allocator.free(empty_string);</span>
<span class="line" id="L3360">}</span>
<span class="line" id="L3361"></span>
<span class="line" id="L3362"><span class="tok-comment">/// Returns a slice with the given new alignment,</span></span>
<span class="line" id="L3363"><span class="tok-comment">/// all other pointer attributes copied from `AttributeSource`.</span></span>
<span class="line" id="L3364"><span class="tok-kw">fn</span> <span class="tok-fn">AlignedSlice</span>(<span class="tok-kw">comptime</span> AttributeSource: <span class="tok-type">type</span>, <span class="tok-kw">comptime</span> new_alignment: <span class="tok-type">u29</span>) <span class="tok-type">type</span> {</span>
<span class="line" id="L3365">    <span class="tok-kw">const</span> info = <span class="tok-builtin">@typeInfo</span>(AttributeSource).Pointer;</span>
<span class="line" id="L3366">    <span class="tok-kw">return</span> <span class="tok-builtin">@Type</span>(.{</span>
<span class="line" id="L3367">        .Pointer = .{</span>
<span class="line" id="L3368">            .size = .Slice,</span>
<span class="line" id="L3369">            .is_const = info.is_const,</span>
<span class="line" id="L3370">            .is_volatile = info.is_volatile,</span>
<span class="line" id="L3371">            .is_allowzero = info.is_allowzero,</span>
<span class="line" id="L3372">            .alignment = new_alignment,</span>
<span class="line" id="L3373">            .address_space = info.address_space,</span>
<span class="line" id="L3374">            .child = info.child,</span>
<span class="line" id="L3375">            .sentinel = <span class="tok-null">null</span>,</span>
<span class="line" id="L3376">        },</span>
<span class="line" id="L3377">    });</span>
<span class="line" id="L3378">}</span>
<span class="line" id="L3379"></span>
<span class="line" id="L3380"><span class="tok-comment">/// Returns the largest slice in the given bytes that conforms to the new alignment,</span></span>
<span class="line" id="L3381"><span class="tok-comment">/// or `null` if the given bytes contain no conforming address.</span></span>
<span class="line" id="L3382"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">alignInBytes</span>(bytes: []<span class="tok-type">u8</span>, <span class="tok-kw">comptime</span> new_alignment: <span class="tok-type">usize</span>) ?[]<span class="tok-kw">align</span>(new_alignment) <span class="tok-type">u8</span> {</span>
<span class="line" id="L3383">    <span class="tok-kw">const</span> begin_address = <span class="tok-builtin">@ptrToInt</span>(bytes.ptr);</span>
<span class="line" id="L3384">    <span class="tok-kw">const</span> end_address = begin_address + bytes.len;</span>
<span class="line" id="L3385"></span>
<span class="line" id="L3386">    <span class="tok-kw">const</span> begin_address_aligned = mem.alignForward(begin_address, new_alignment);</span>
<span class="line" id="L3387">    <span class="tok-kw">const</span> new_length = std.math.sub(<span class="tok-type">usize</span>, end_address, begin_address_aligned) <span class="tok-kw">catch</span> |e| <span class="tok-kw">switch</span> (e) {</span>
<span class="line" id="L3388">        <span class="tok-kw">error</span>.Overflow =&gt; <span class="tok-kw">return</span> <span class="tok-null">null</span>,</span>
<span class="line" id="L3389">    };</span>
<span class="line" id="L3390">    <span class="tok-kw">const</span> alignment_offset = begin_address_aligned - begin_address;</span>
<span class="line" id="L3391">    <span class="tok-kw">return</span> <span class="tok-builtin">@alignCast</span>(new_alignment, bytes[alignment_offset .. alignment_offset + new_length]);</span>
<span class="line" id="L3392">}</span>
<span class="line" id="L3393"></span>
<span class="line" id="L3394"><span class="tok-comment">/// Returns the largest sub-slice within the given slice that conforms to the new alignment,</span></span>
<span class="line" id="L3395"><span class="tok-comment">/// or `null` if the given slice contains no conforming address.</span></span>
<span class="line" id="L3396"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">alignInSlice</span>(slice: <span class="tok-kw">anytype</span>, <span class="tok-kw">comptime</span> new_alignment: <span class="tok-type">usize</span>) ?AlignedSlice(<span class="tok-builtin">@TypeOf</span>(slice), new_alignment) {</span>
<span class="line" id="L3397">    <span class="tok-kw">const</span> bytes = sliceAsBytes(slice);</span>
<span class="line" id="L3398">    <span class="tok-kw">const</span> aligned_bytes = alignInBytes(bytes, new_alignment) <span class="tok-kw">orelse</span> <span class="tok-kw">return</span> <span class="tok-null">null</span>;</span>
<span class="line" id="L3399"></span>
<span class="line" id="L3400">    <span class="tok-kw">const</span> Element = <span class="tok-builtin">@TypeOf</span>(slice[<span class="tok-number">0</span>]);</span>
<span class="line" id="L3401">    <span class="tok-kw">const</span> slice_length_bytes = aligned_bytes.len - (aligned_bytes.len % <span class="tok-builtin">@sizeOf</span>(Element));</span>
<span class="line" id="L3402">    <span class="tok-kw">const</span> aligned_slice = bytesAsSlice(Element, aligned_bytes[<span class="tok-number">0</span>..slice_length_bytes]);</span>
<span class="line" id="L3403">    <span class="tok-kw">return</span> <span class="tok-builtin">@alignCast</span>(new_alignment, aligned_slice);</span>
<span class="line" id="L3404">}</span>
<span class="line" id="L3405"></span>
</code></pre></body>
</html>