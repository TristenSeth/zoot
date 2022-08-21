<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">    <title>testing/failing_allocator.zig - source view</title>
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
<pre><code><span class="line" id="L1"><span class="tok-kw">const</span> std = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;../std.zig&quot;</span>);</span>
<span class="line" id="L2"><span class="tok-kw">const</span> mem = std.mem;</span>
<span class="line" id="L3"></span>
<span class="line" id="L4"><span class="tok-comment">/// Allocator that fails after N allocations, useful for making sure out of</span></span>
<span class="line" id="L5"><span class="tok-comment">/// memory conditions are handled correctly.</span></span>
<span class="line" id="L6"><span class="tok-comment">///</span></span>
<span class="line" id="L7"><span class="tok-comment">/// To use this, first initialize it and get an allocator with</span></span>
<span class="line" id="L8"><span class="tok-comment">///</span></span>
<span class="line" id="L9"><span class="tok-comment">/// `const failing_allocator = &amp;FailingAllocator.init(&lt;allocator&gt;,</span></span>
<span class="line" id="L10"><span class="tok-comment">///                                                   &lt;fail_index&gt;).allocator;`</span></span>
<span class="line" id="L11"><span class="tok-comment">///</span></span>
<span class="line" id="L12"><span class="tok-comment">/// Then use `failing_allocator` anywhere you would have used a</span></span>
<span class="line" id="L13"><span class="tok-comment">/// different allocator.</span></span>
<span class="line" id="L14"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FailingAllocator = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L15">    index: <span class="tok-type">usize</span>,</span>
<span class="line" id="L16">    fail_index: <span class="tok-type">usize</span>,</span>
<span class="line" id="L17">    internal_allocator: mem.Allocator,</span>
<span class="line" id="L18">    allocated_bytes: <span class="tok-type">usize</span>,</span>
<span class="line" id="L19">    freed_bytes: <span class="tok-type">usize</span>,</span>
<span class="line" id="L20">    allocations: <span class="tok-type">usize</span>,</span>
<span class="line" id="L21">    deallocations: <span class="tok-type">usize</span>,</span>
<span class="line" id="L22">    stack_addresses: [num_stack_frames]<span class="tok-type">usize</span>,</span>
<span class="line" id="L23">    has_induced_failure: <span class="tok-type">bool</span>,</span>
<span class="line" id="L24"></span>
<span class="line" id="L25">    <span class="tok-kw">const</span> num_stack_frames = <span class="tok-kw">if</span> (std.debug.sys_can_stack_trace) <span class="tok-number">16</span> <span class="tok-kw">else</span> <span class="tok-number">0</span>;</span>
<span class="line" id="L26"></span>
<span class="line" id="L27">    <span class="tok-comment">/// `fail_index` is the number of successful allocations you can</span></span>
<span class="line" id="L28">    <span class="tok-comment">/// expect from this allocator. The next allocation will fail.</span></span>
<span class="line" id="L29">    <span class="tok-comment">/// For example, if this is called with `fail_index` equal to 2,</span></span>
<span class="line" id="L30">    <span class="tok-comment">/// the following test will pass:</span></span>
<span class="line" id="L31">    <span class="tok-comment">///</span></span>
<span class="line" id="L32">    <span class="tok-comment">/// var a = try failing_alloc.create(i32);</span></span>
<span class="line" id="L33">    <span class="tok-comment">/// var b = try failing_alloc.create(i32);</span></span>
<span class="line" id="L34">    <span class="tok-comment">/// testing.expectError(error.OutOfMemory, failing_alloc.create(i32));</span></span>
<span class="line" id="L35">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">init</span>(internal_allocator: mem.Allocator, fail_index: <span class="tok-type">usize</span>) FailingAllocator {</span>
<span class="line" id="L36">        <span class="tok-kw">return</span> FailingAllocator{</span>
<span class="line" id="L37">            .internal_allocator = internal_allocator,</span>
<span class="line" id="L38">            .fail_index = fail_index,</span>
<span class="line" id="L39">            .index = <span class="tok-number">0</span>,</span>
<span class="line" id="L40">            .allocated_bytes = <span class="tok-number">0</span>,</span>
<span class="line" id="L41">            .freed_bytes = <span class="tok-number">0</span>,</span>
<span class="line" id="L42">            .allocations = <span class="tok-number">0</span>,</span>
<span class="line" id="L43">            .deallocations = <span class="tok-number">0</span>,</span>
<span class="line" id="L44">            .stack_addresses = <span class="tok-null">undefined</span>,</span>
<span class="line" id="L45">            .has_induced_failure = <span class="tok-null">false</span>,</span>
<span class="line" id="L46">        };</span>
<span class="line" id="L47">    }</span>
<span class="line" id="L48"></span>
<span class="line" id="L49">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">allocator</span>(self: *FailingAllocator) mem.Allocator {</span>
<span class="line" id="L50">        <span class="tok-kw">return</span> mem.Allocator.init(self, alloc, resize, free);</span>
<span class="line" id="L51">    }</span>
<span class="line" id="L52"></span>
<span class="line" id="L53">    <span class="tok-kw">fn</span> <span class="tok-fn">alloc</span>(</span>
<span class="line" id="L54">        self: *FailingAllocator,</span>
<span class="line" id="L55">        len: <span class="tok-type">usize</span>,</span>
<span class="line" id="L56">        ptr_align: <span class="tok-type">u29</span>,</span>
<span class="line" id="L57">        len_align: <span class="tok-type">u29</span>,</span>
<span class="line" id="L58">        return_address: <span class="tok-type">usize</span>,</span>
<span class="line" id="L59">    ) <span class="tok-kw">error</span>{OutOfMemory}![]<span class="tok-type">u8</span> {</span>
<span class="line" id="L60">        <span class="tok-kw">if</span> (self.index == self.fail_index) {</span>
<span class="line" id="L61">            <span class="tok-kw">if</span> (!self.has_induced_failure) {</span>
<span class="line" id="L62">                mem.set(<span class="tok-type">usize</span>, &amp;self.stack_addresses, <span class="tok-number">0</span>);</span>
<span class="line" id="L63">                <span class="tok-kw">var</span> stack_trace = std.builtin.StackTrace{</span>
<span class="line" id="L64">                    .instruction_addresses = &amp;self.stack_addresses,</span>
<span class="line" id="L65">                    .index = <span class="tok-number">0</span>,</span>
<span class="line" id="L66">                };</span>
<span class="line" id="L67">                std.debug.captureStackTrace(return_address, &amp;stack_trace);</span>
<span class="line" id="L68">                self.has_induced_failure = <span class="tok-null">true</span>;</span>
<span class="line" id="L69">            }</span>
<span class="line" id="L70">            <span class="tok-kw">return</span> <span class="tok-kw">error</span>.OutOfMemory;</span>
<span class="line" id="L71">        }</span>
<span class="line" id="L72">        <span class="tok-kw">const</span> result = <span class="tok-kw">try</span> self.internal_allocator.rawAlloc(len, ptr_align, len_align, return_address);</span>
<span class="line" id="L73">        self.allocated_bytes += result.len;</span>
<span class="line" id="L74">        self.allocations += <span class="tok-number">1</span>;</span>
<span class="line" id="L75">        self.index += <span class="tok-number">1</span>;</span>
<span class="line" id="L76">        <span class="tok-kw">return</span> result;</span>
<span class="line" id="L77">    }</span>
<span class="line" id="L78"></span>
<span class="line" id="L79">    <span class="tok-kw">fn</span> <span class="tok-fn">resize</span>(</span>
<span class="line" id="L80">        self: *FailingAllocator,</span>
<span class="line" id="L81">        old_mem: []<span class="tok-type">u8</span>,</span>
<span class="line" id="L82">        old_align: <span class="tok-type">u29</span>,</span>
<span class="line" id="L83">        new_len: <span class="tok-type">usize</span>,</span>
<span class="line" id="L84">        len_align: <span class="tok-type">u29</span>,</span>
<span class="line" id="L85">        ra: <span class="tok-type">usize</span>,</span>
<span class="line" id="L86">    ) ?<span class="tok-type">usize</span> {</span>
<span class="line" id="L87">        <span class="tok-kw">const</span> r = self.internal_allocator.rawResize(old_mem, old_align, new_len, len_align, ra) <span class="tok-kw">orelse</span> <span class="tok-kw">return</span> <span class="tok-null">null</span>;</span>
<span class="line" id="L88">        <span class="tok-kw">if</span> (r &lt; old_mem.len) {</span>
<span class="line" id="L89">            self.freed_bytes += old_mem.len - r;</span>
<span class="line" id="L90">        } <span class="tok-kw">else</span> {</span>
<span class="line" id="L91">            self.allocated_bytes += r - old_mem.len;</span>
<span class="line" id="L92">        }</span>
<span class="line" id="L93">        <span class="tok-kw">return</span> r;</span>
<span class="line" id="L94">    }</span>
<span class="line" id="L95"></span>
<span class="line" id="L96">    <span class="tok-kw">fn</span> <span class="tok-fn">free</span>(</span>
<span class="line" id="L97">        self: *FailingAllocator,</span>
<span class="line" id="L98">        old_mem: []<span class="tok-type">u8</span>,</span>
<span class="line" id="L99">        old_align: <span class="tok-type">u29</span>,</span>
<span class="line" id="L100">        ra: <span class="tok-type">usize</span>,</span>
<span class="line" id="L101">    ) <span class="tok-type">void</span> {</span>
<span class="line" id="L102">        self.internal_allocator.rawFree(old_mem, old_align, ra);</span>
<span class="line" id="L103">        self.deallocations += <span class="tok-number">1</span>;</span>
<span class="line" id="L104">        self.freed_bytes += old_mem.len;</span>
<span class="line" id="L105">    }</span>
<span class="line" id="L106"></span>
<span class="line" id="L107">    <span class="tok-comment">/// Only valid once `has_induced_failure == true`</span></span>
<span class="line" id="L108">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">getStackTrace</span>(self: *FailingAllocator) std.builtin.StackTrace {</span>
<span class="line" id="L109">        std.debug.assert(self.has_induced_failure);</span>
<span class="line" id="L110">        <span class="tok-kw">var</span> len: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L111">        <span class="tok-kw">while</span> (len &lt; self.stack_addresses.len <span class="tok-kw">and</span> self.stack_addresses[len] != <span class="tok-number">0</span>) {</span>
<span class="line" id="L112">            len += <span class="tok-number">1</span>;</span>
<span class="line" id="L113">        }</span>
<span class="line" id="L114">        <span class="tok-kw">return</span> .{</span>
<span class="line" id="L115">            .instruction_addresses = &amp;self.stack_addresses,</span>
<span class="line" id="L116">            .index = len,</span>
<span class="line" id="L117">        };</span>
<span class="line" id="L118">    }</span>
<span class="line" id="L119">};</span>
<span class="line" id="L120"></span>
</code></pre></body>
</html>