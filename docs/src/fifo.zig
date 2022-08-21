<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">    <title>fifo.zig - source view</title>
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
<pre><code><span class="line" id="L1"><span class="tok-comment">// FIFO of fixed size items</span>
</span>
<span class="line" id="L2"><span class="tok-comment">// Usually used for e.g. byte buffers</span>
</span>
<span class="line" id="L3"></span>
<span class="line" id="L4"><span class="tok-kw">const</span> std = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;std&quot;</span>);</span>
<span class="line" id="L5"><span class="tok-kw">const</span> math = std.math;</span>
<span class="line" id="L6"><span class="tok-kw">const</span> mem = std.mem;</span>
<span class="line" id="L7"><span class="tok-kw">const</span> Allocator = mem.Allocator;</span>
<span class="line" id="L8"><span class="tok-kw">const</span> debug = std.debug;</span>
<span class="line" id="L9"><span class="tok-kw">const</span> assert = debug.assert;</span>
<span class="line" id="L10"><span class="tok-kw">const</span> testing = std.testing;</span>
<span class="line" id="L11"></span>
<span class="line" id="L12"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> LinearFifoBufferType = <span class="tok-kw">union</span>(<span class="tok-kw">enum</span>) {</span>
<span class="line" id="L13">    <span class="tok-comment">/// The buffer is internal to the fifo; it is of the specified size.</span></span>
<span class="line" id="L14">    Static: <span class="tok-type">usize</span>,</span>
<span class="line" id="L15"></span>
<span class="line" id="L16">    <span class="tok-comment">/// The buffer is passed as a slice to the initialiser.</span></span>
<span class="line" id="L17">    Slice,</span>
<span class="line" id="L18"></span>
<span class="line" id="L19">    <span class="tok-comment">/// The buffer is managed dynamically using a `mem.Allocator`.</span></span>
<span class="line" id="L20">    Dynamic,</span>
<span class="line" id="L21">};</span>
<span class="line" id="L22"></span>
<span class="line" id="L23"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">LinearFifo</span>(</span>
<span class="line" id="L24">    <span class="tok-kw">comptime</span> T: <span class="tok-type">type</span>,</span>
<span class="line" id="L25">    <span class="tok-kw">comptime</span> buffer_type: LinearFifoBufferType,</span>
<span class="line" id="L26">) <span class="tok-type">type</span> {</span>
<span class="line" id="L27">    <span class="tok-kw">const</span> autoalign = <span class="tok-null">false</span>;</span>
<span class="line" id="L28"></span>
<span class="line" id="L29">    <span class="tok-kw">const</span> powers_of_two = <span class="tok-kw">switch</span> (buffer_type) {</span>
<span class="line" id="L30">        .Static =&gt; std.math.isPowerOfTwo(buffer_type.Static),</span>
<span class="line" id="L31">        .Slice =&gt; <span class="tok-null">false</span>, <span class="tok-comment">// Any size slice could be passed in</span>
</span>
<span class="line" id="L32">        .Dynamic =&gt; <span class="tok-null">true</span>, <span class="tok-comment">// This could be configurable in future</span>
</span>
<span class="line" id="L33">    };</span>
<span class="line" id="L34"></span>
<span class="line" id="L35">    <span class="tok-kw">return</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L36">        allocator: <span class="tok-kw">if</span> (buffer_type == .Dynamic) Allocator <span class="tok-kw">else</span> <span class="tok-type">void</span>,</span>
<span class="line" id="L37">        buf: <span class="tok-kw">if</span> (buffer_type == .Static) [buffer_type.Static]T <span class="tok-kw">else</span> []T,</span>
<span class="line" id="L38">        head: <span class="tok-type">usize</span>,</span>
<span class="line" id="L39">        count: <span class="tok-type">usize</span>,</span>
<span class="line" id="L40"></span>
<span class="line" id="L41">        <span class="tok-kw">const</span> Self = <span class="tok-builtin">@This</span>();</span>
<span class="line" id="L42">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> Reader = std.io.Reader(*Self, <span class="tok-kw">error</span>{}, readFn);</span>
<span class="line" id="L43">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> Writer = std.io.Writer(*Self, <span class="tok-kw">error</span>{OutOfMemory}, appendWrite);</span>
<span class="line" id="L44"></span>
<span class="line" id="L45">        <span class="tok-comment">// Type of Self argument for slice operations.</span>
</span>
<span class="line" id="L46">        <span class="tok-comment">// If buffer is inline (Static) then we need to ensure we haven't</span>
</span>
<span class="line" id="L47">        <span class="tok-comment">// returned a slice into a copy on the stack</span>
</span>
<span class="line" id="L48">        <span class="tok-kw">const</span> SliceSelfArg = <span class="tok-kw">if</span> (buffer_type == .Static) *Self <span class="tok-kw">else</span> Self;</span>
<span class="line" id="L49"></span>
<span class="line" id="L50">        <span class="tok-kw">pub</span> <span class="tok-kw">usingnamespace</span> <span class="tok-kw">switch</span> (buffer_type) {</span>
<span class="line" id="L51">            .Static =&gt; <span class="tok-kw">struct</span> {</span>
<span class="line" id="L52">                <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">init</span>() Self {</span>
<span class="line" id="L53">                    <span class="tok-kw">return</span> .{</span>
<span class="line" id="L54">                        .allocator = {},</span>
<span class="line" id="L55">                        .buf = <span class="tok-null">undefined</span>,</span>
<span class="line" id="L56">                        .head = <span class="tok-number">0</span>,</span>
<span class="line" id="L57">                        .count = <span class="tok-number">0</span>,</span>
<span class="line" id="L58">                    };</span>
<span class="line" id="L59">                }</span>
<span class="line" id="L60">            },</span>
<span class="line" id="L61">            .Slice =&gt; <span class="tok-kw">struct</span> {</span>
<span class="line" id="L62">                <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">init</span>(buf: []T) Self {</span>
<span class="line" id="L63">                    <span class="tok-kw">return</span> .{</span>
<span class="line" id="L64">                        .allocator = {},</span>
<span class="line" id="L65">                        .buf = buf,</span>
<span class="line" id="L66">                        .head = <span class="tok-number">0</span>,</span>
<span class="line" id="L67">                        .count = <span class="tok-number">0</span>,</span>
<span class="line" id="L68">                    };</span>
<span class="line" id="L69">                }</span>
<span class="line" id="L70">            },</span>
<span class="line" id="L71">            .Dynamic =&gt; <span class="tok-kw">struct</span> {</span>
<span class="line" id="L72">                <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">init</span>(allocator: Allocator) Self {</span>
<span class="line" id="L73">                    <span class="tok-kw">return</span> .{</span>
<span class="line" id="L74">                        .allocator = allocator,</span>
<span class="line" id="L75">                        .buf = &amp;[_]T{},</span>
<span class="line" id="L76">                        .head = <span class="tok-number">0</span>,</span>
<span class="line" id="L77">                        .count = <span class="tok-number">0</span>,</span>
<span class="line" id="L78">                    };</span>
<span class="line" id="L79">                }</span>
<span class="line" id="L80">            },</span>
<span class="line" id="L81">        };</span>
<span class="line" id="L82"></span>
<span class="line" id="L83">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">deinit</span>(self: Self) <span class="tok-type">void</span> {</span>
<span class="line" id="L84">            <span class="tok-kw">if</span> (buffer_type == .Dynamic) self.allocator.free(self.buf);</span>
<span class="line" id="L85">        }</span>
<span class="line" id="L86"></span>
<span class="line" id="L87">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">realign</span>(self: *Self) <span class="tok-type">void</span> {</span>
<span class="line" id="L88">            <span class="tok-kw">if</span> (self.buf.len - self.head &gt;= self.count) {</span>
<span class="line" id="L89">                <span class="tok-comment">// this copy overlaps</span>
</span>
<span class="line" id="L90">                mem.copy(T, self.buf[<span class="tok-number">0</span>..self.count], self.buf[self.head..][<span class="tok-number">0</span>..self.count]);</span>
<span class="line" id="L91">                self.head = <span class="tok-number">0</span>;</span>
<span class="line" id="L92">            } <span class="tok-kw">else</span> {</span>
<span class="line" id="L93">                <span class="tok-kw">var</span> tmp: [mem.page_size / <span class="tok-number">2</span> / <span class="tok-builtin">@sizeOf</span>(T)]T = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L94"></span>
<span class="line" id="L95">                <span class="tok-kw">while</span> (self.head != <span class="tok-number">0</span>) {</span>
<span class="line" id="L96">                    <span class="tok-kw">const</span> n = math.min(self.head, tmp.len);</span>
<span class="line" id="L97">                    <span class="tok-kw">const</span> m = self.buf.len - n;</span>
<span class="line" id="L98">                    mem.copy(T, tmp[<span class="tok-number">0</span>..n], self.buf[<span class="tok-number">0</span>..n]);</span>
<span class="line" id="L99">                    <span class="tok-comment">// this middle copy overlaps; the others here don't</span>
</span>
<span class="line" id="L100">                    mem.copy(T, self.buf[<span class="tok-number">0</span>..m], self.buf[n..][<span class="tok-number">0</span>..m]);</span>
<span class="line" id="L101">                    mem.copy(T, self.buf[m..], tmp[<span class="tok-number">0</span>..n]);</span>
<span class="line" id="L102">                    self.head -= n;</span>
<span class="line" id="L103">                }</span>
<span class="line" id="L104">            }</span>
<span class="line" id="L105">            { <span class="tok-comment">// set unused area to undefined</span>
</span>
<span class="line" id="L106">                <span class="tok-kw">const</span> unused = mem.sliceAsBytes(self.buf[self.count..]);</span>
<span class="line" id="L107">                <span class="tok-builtin">@memset</span>(unused.ptr, <span class="tok-null">undefined</span>, unused.len);</span>
<span class="line" id="L108">            }</span>
<span class="line" id="L109">        }</span>
<span class="line" id="L110"></span>
<span class="line" id="L111">        <span class="tok-comment">/// Reduce allocated capacity to `size`.</span></span>
<span class="line" id="L112">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">shrink</span>(self: *Self, size: <span class="tok-type">usize</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L113">            assert(size &gt;= self.count);</span>
<span class="line" id="L114">            <span class="tok-kw">if</span> (buffer_type == .Dynamic) {</span>
<span class="line" id="L115">                self.realign();</span>
<span class="line" id="L116">                self.buf = self.allocator.realloc(self.buf, size) <span class="tok-kw">catch</span> |e| <span class="tok-kw">switch</span> (e) {</span>
<span class="line" id="L117">                    <span class="tok-kw">error</span>.OutOfMemory =&gt; <span class="tok-kw">return</span>, <span class="tok-comment">// no problem, capacity is still correct then.</span>
</span>
<span class="line" id="L118">                };</span>
<span class="line" id="L119">            }</span>
<span class="line" id="L120">        }</span>
<span class="line" id="L121"></span>
<span class="line" id="L122">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> ensureCapacity = <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;deprecated; call `ensureUnusedCapacity` or `ensureTotalCapacity`&quot;</span>);</span>
<span class="line" id="L123"></span>
<span class="line" id="L124">        <span class="tok-comment">/// Ensure that the buffer can fit at least `size` items</span></span>
<span class="line" id="L125">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">ensureTotalCapacity</span>(self: *Self, size: <span class="tok-type">usize</span>) !<span class="tok-type">void</span> {</span>
<span class="line" id="L126">            <span class="tok-kw">if</span> (self.buf.len &gt;= size) <span class="tok-kw">return</span>;</span>
<span class="line" id="L127">            <span class="tok-kw">if</span> (buffer_type == .Dynamic) {</span>
<span class="line" id="L128">                self.realign();</span>
<span class="line" id="L129">                <span class="tok-kw">const</span> new_size = <span class="tok-kw">if</span> (powers_of_two) math.ceilPowerOfTwo(<span class="tok-type">usize</span>, size) <span class="tok-kw">catch</span> <span class="tok-kw">return</span> <span class="tok-kw">error</span>.OutOfMemory <span class="tok-kw">else</span> size;</span>
<span class="line" id="L130">                self.buf = <span class="tok-kw">try</span> self.allocator.realloc(self.buf, new_size);</span>
<span class="line" id="L131">            } <span class="tok-kw">else</span> {</span>
<span class="line" id="L132">                <span class="tok-kw">return</span> <span class="tok-kw">error</span>.OutOfMemory;</span>
<span class="line" id="L133">            }</span>
<span class="line" id="L134">        }</span>
<span class="line" id="L135"></span>
<span class="line" id="L136">        <span class="tok-comment">/// Makes sure at least `size` items are unused</span></span>
<span class="line" id="L137">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">ensureUnusedCapacity</span>(self: *Self, size: <span class="tok-type">usize</span>) <span class="tok-kw">error</span>{OutOfMemory}!<span class="tok-type">void</span> {</span>
<span class="line" id="L138">            <span class="tok-kw">if</span> (self.writableLength() &gt;= size) <span class="tok-kw">return</span>;</span>
<span class="line" id="L139"></span>
<span class="line" id="L140">            <span class="tok-kw">return</span> <span class="tok-kw">try</span> self.ensureTotalCapacity(math.add(<span class="tok-type">usize</span>, self.count, size) <span class="tok-kw">catch</span> <span class="tok-kw">return</span> <span class="tok-kw">error</span>.OutOfMemory);</span>
<span class="line" id="L141">        }</span>
<span class="line" id="L142"></span>
<span class="line" id="L143">        <span class="tok-comment">/// Returns number of items currently in fifo</span></span>
<span class="line" id="L144">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">readableLength</span>(self: Self) <span class="tok-type">usize</span> {</span>
<span class="line" id="L145">            <span class="tok-kw">return</span> self.count;</span>
<span class="line" id="L146">        }</span>
<span class="line" id="L147"></span>
<span class="line" id="L148">        <span class="tok-comment">/// Returns a writable slice from the 'read' end of the fifo</span></span>
<span class="line" id="L149">        <span class="tok-kw">fn</span> <span class="tok-fn">readableSliceMut</span>(self: SliceSelfArg, offset: <span class="tok-type">usize</span>) []T {</span>
<span class="line" id="L150">            <span class="tok-kw">if</span> (offset &gt; self.count) <span class="tok-kw">return</span> &amp;[_]T{};</span>
<span class="line" id="L151"></span>
<span class="line" id="L152">            <span class="tok-kw">var</span> start = self.head + offset;</span>
<span class="line" id="L153">            <span class="tok-kw">if</span> (start &gt;= self.buf.len) {</span>
<span class="line" id="L154">                start -= self.buf.len;</span>
<span class="line" id="L155">                <span class="tok-kw">return</span> self.buf[start .. start + (self.count - offset)];</span>
<span class="line" id="L156">            } <span class="tok-kw">else</span> {</span>
<span class="line" id="L157">                <span class="tok-kw">const</span> end = math.min(self.head + self.count, self.buf.len);</span>
<span class="line" id="L158">                <span class="tok-kw">return</span> self.buf[start..end];</span>
<span class="line" id="L159">            }</span>
<span class="line" id="L160">        }</span>
<span class="line" id="L161"></span>
<span class="line" id="L162">        <span class="tok-comment">/// Returns a readable slice from `offset`</span></span>
<span class="line" id="L163">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">readableSlice</span>(self: SliceSelfArg, offset: <span class="tok-type">usize</span>) []<span class="tok-kw">const</span> T {</span>
<span class="line" id="L164">            <span class="tok-kw">return</span> self.readableSliceMut(offset);</span>
<span class="line" id="L165">        }</span>
<span class="line" id="L166"></span>
<span class="line" id="L167">        <span class="tok-comment">/// Discard first `count` items in the fifo</span></span>
<span class="line" id="L168">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">discard</span>(self: *Self, count: <span class="tok-type">usize</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L169">            assert(count &lt;= self.count);</span>
<span class="line" id="L170">            { <span class="tok-comment">// set old range to undefined. Note: may be wrapped around</span>
</span>
<span class="line" id="L171">                <span class="tok-kw">const</span> slice = self.readableSliceMut(<span class="tok-number">0</span>);</span>
<span class="line" id="L172">                <span class="tok-kw">if</span> (slice.len &gt;= count) {</span>
<span class="line" id="L173">                    <span class="tok-kw">const</span> unused = mem.sliceAsBytes(slice[<span class="tok-number">0</span>..count]);</span>
<span class="line" id="L174">                    <span class="tok-builtin">@memset</span>(unused.ptr, <span class="tok-null">undefined</span>, unused.len);</span>
<span class="line" id="L175">                } <span class="tok-kw">else</span> {</span>
<span class="line" id="L176">                    <span class="tok-kw">const</span> unused = mem.sliceAsBytes(slice[<span class="tok-number">0</span>..]);</span>
<span class="line" id="L177">                    <span class="tok-builtin">@memset</span>(unused.ptr, <span class="tok-null">undefined</span>, unused.len);</span>
<span class="line" id="L178">                    <span class="tok-kw">const</span> unused2 = mem.sliceAsBytes(self.readableSliceMut(slice.len)[<span class="tok-number">0</span> .. count - slice.len]);</span>
<span class="line" id="L179">                    <span class="tok-builtin">@memset</span>(unused2.ptr, <span class="tok-null">undefined</span>, unused2.len);</span>
<span class="line" id="L180">                }</span>
<span class="line" id="L181">            }</span>
<span class="line" id="L182">            <span class="tok-kw">if</span> (autoalign <span class="tok-kw">and</span> self.count == count) {</span>
<span class="line" id="L183">                self.head = <span class="tok-number">0</span>;</span>
<span class="line" id="L184">                self.count = <span class="tok-number">0</span>;</span>
<span class="line" id="L185">            } <span class="tok-kw">else</span> {</span>
<span class="line" id="L186">                <span class="tok-kw">var</span> head = self.head + count;</span>
<span class="line" id="L187">                <span class="tok-kw">if</span> (powers_of_two) {</span>
<span class="line" id="L188">                    <span class="tok-comment">// Note it is safe to do a wrapping subtract as</span>
</span>
<span class="line" id="L189">                    <span class="tok-comment">// bitwise &amp; with all 1s is a noop</span>
</span>
<span class="line" id="L190">                    head &amp;= self.buf.len -% <span class="tok-number">1</span>;</span>
<span class="line" id="L191">                } <span class="tok-kw">else</span> {</span>
<span class="line" id="L192">                    head %= self.buf.len;</span>
<span class="line" id="L193">                }</span>
<span class="line" id="L194">                self.head = head;</span>
<span class="line" id="L195">                self.count -= count;</span>
<span class="line" id="L196">            }</span>
<span class="line" id="L197">        }</span>
<span class="line" id="L198"></span>
<span class="line" id="L199">        <span class="tok-comment">/// Read the next item from the fifo</span></span>
<span class="line" id="L200">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">readItem</span>(self: *Self) ?T {</span>
<span class="line" id="L201">            <span class="tok-kw">if</span> (self.count == <span class="tok-number">0</span>) <span class="tok-kw">return</span> <span class="tok-null">null</span>;</span>
<span class="line" id="L202"></span>
<span class="line" id="L203">            <span class="tok-kw">const</span> c = self.buf[self.head];</span>
<span class="line" id="L204">            self.discard(<span class="tok-number">1</span>);</span>
<span class="line" id="L205">            <span class="tok-kw">return</span> c;</span>
<span class="line" id="L206">        }</span>
<span class="line" id="L207"></span>
<span class="line" id="L208">        <span class="tok-comment">/// Read data from the fifo into `dst`, returns number of items copied.</span></span>
<span class="line" id="L209">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">read</span>(self: *Self, dst: []T) <span class="tok-type">usize</span> {</span>
<span class="line" id="L210">            <span class="tok-kw">var</span> dst_left = dst;</span>
<span class="line" id="L211"></span>
<span class="line" id="L212">            <span class="tok-kw">while</span> (dst_left.len &gt; <span class="tok-number">0</span>) {</span>
<span class="line" id="L213">                <span class="tok-kw">const</span> slice = self.readableSlice(<span class="tok-number">0</span>);</span>
<span class="line" id="L214">                <span class="tok-kw">if</span> (slice.len == <span class="tok-number">0</span>) <span class="tok-kw">break</span>;</span>
<span class="line" id="L215">                <span class="tok-kw">const</span> n = math.min(slice.len, dst_left.len);</span>
<span class="line" id="L216">                mem.copy(T, dst_left, slice[<span class="tok-number">0</span>..n]);</span>
<span class="line" id="L217">                self.discard(n);</span>
<span class="line" id="L218">                dst_left = dst_left[n..];</span>
<span class="line" id="L219">            }</span>
<span class="line" id="L220"></span>
<span class="line" id="L221">            <span class="tok-kw">return</span> dst.len - dst_left.len;</span>
<span class="line" id="L222">        }</span>
<span class="line" id="L223"></span>
<span class="line" id="L224">        <span class="tok-comment">/// Same as `read` except it returns an error union</span></span>
<span class="line" id="L225">        <span class="tok-comment">/// The purpose of this function existing is to match `std.io.Reader` API.</span></span>
<span class="line" id="L226">        <span class="tok-kw">fn</span> <span class="tok-fn">readFn</span>(self: *Self, dest: []<span class="tok-type">u8</span>) <span class="tok-kw">error</span>{}!<span class="tok-type">usize</span> {</span>
<span class="line" id="L227">            <span class="tok-kw">return</span> self.read(dest);</span>
<span class="line" id="L228">        }</span>
<span class="line" id="L229"></span>
<span class="line" id="L230">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">reader</span>(self: *Self) Reader {</span>
<span class="line" id="L231">            <span class="tok-kw">return</span> .{ .context = self };</span>
<span class="line" id="L232">        }</span>
<span class="line" id="L233"></span>
<span class="line" id="L234">        <span class="tok-comment">/// Returns number of items available in fifo</span></span>
<span class="line" id="L235">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">writableLength</span>(self: Self) <span class="tok-type">usize</span> {</span>
<span class="line" id="L236">            <span class="tok-kw">return</span> self.buf.len - self.count;</span>
<span class="line" id="L237">        }</span>
<span class="line" id="L238"></span>
<span class="line" id="L239">        <span class="tok-comment">/// Returns the first section of writable buffer</span></span>
<span class="line" id="L240">        <span class="tok-comment">/// Note that this may be of length 0</span></span>
<span class="line" id="L241">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">writableSlice</span>(self: SliceSelfArg, offset: <span class="tok-type">usize</span>) []T {</span>
<span class="line" id="L242">            <span class="tok-kw">if</span> (offset &gt; self.buf.len) <span class="tok-kw">return</span> &amp;[_]T{};</span>
<span class="line" id="L243"></span>
<span class="line" id="L244">            <span class="tok-kw">const</span> tail = self.head + offset + self.count;</span>
<span class="line" id="L245">            <span class="tok-kw">if</span> (tail &lt; self.buf.len) {</span>
<span class="line" id="L246">                <span class="tok-kw">return</span> self.buf[tail..];</span>
<span class="line" id="L247">            } <span class="tok-kw">else</span> {</span>
<span class="line" id="L248">                <span class="tok-kw">return</span> self.buf[tail - self.buf.len ..][<span class="tok-number">0</span> .. self.writableLength() - offset];</span>
<span class="line" id="L249">            }</span>
<span class="line" id="L250">        }</span>
<span class="line" id="L251"></span>
<span class="line" id="L252">        <span class="tok-comment">/// Returns a writable buffer of at least `size` items, allocating memory as needed.</span></span>
<span class="line" id="L253">        <span class="tok-comment">/// Use `fifo.update` once you've written data to it.</span></span>
<span class="line" id="L254">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">writableWithSize</span>(self: *Self, size: <span class="tok-type">usize</span>) ![]T {</span>
<span class="line" id="L255">            <span class="tok-kw">try</span> self.ensureUnusedCapacity(size);</span>
<span class="line" id="L256"></span>
<span class="line" id="L257">            <span class="tok-comment">// try to avoid realigning buffer</span>
</span>
<span class="line" id="L258">            <span class="tok-kw">var</span> slice = self.writableSlice(<span class="tok-number">0</span>);</span>
<span class="line" id="L259">            <span class="tok-kw">if</span> (slice.len &lt; size) {</span>
<span class="line" id="L260">                self.realign();</span>
<span class="line" id="L261">                slice = self.writableSlice(<span class="tok-number">0</span>);</span>
<span class="line" id="L262">            }</span>
<span class="line" id="L263">            <span class="tok-kw">return</span> slice;</span>
<span class="line" id="L264">        }</span>
<span class="line" id="L265"></span>
<span class="line" id="L266">        <span class="tok-comment">/// Update the tail location of the buffer (usually follows use of writable/writableWithSize)</span></span>
<span class="line" id="L267">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">update</span>(self: *Self, count: <span class="tok-type">usize</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L268">            assert(self.count + count &lt;= self.buf.len);</span>
<span class="line" id="L269">            self.count += count;</span>
<span class="line" id="L270">        }</span>
<span class="line" id="L271"></span>
<span class="line" id="L272">        <span class="tok-comment">/// Appends the data in `src` to the fifo.</span></span>
<span class="line" id="L273">        <span class="tok-comment">/// You must have ensured there is enough space.</span></span>
<span class="line" id="L274">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">writeAssumeCapacity</span>(self: *Self, src: []<span class="tok-kw">const</span> T) <span class="tok-type">void</span> {</span>
<span class="line" id="L275">            assert(self.writableLength() &gt;= src.len);</span>
<span class="line" id="L276"></span>
<span class="line" id="L277">            <span class="tok-kw">var</span> src_left = src;</span>
<span class="line" id="L278">            <span class="tok-kw">while</span> (src_left.len &gt; <span class="tok-number">0</span>) {</span>
<span class="line" id="L279">                <span class="tok-kw">const</span> writable_slice = self.writableSlice(<span class="tok-number">0</span>);</span>
<span class="line" id="L280">                assert(writable_slice.len != <span class="tok-number">0</span>);</span>
<span class="line" id="L281">                <span class="tok-kw">const</span> n = math.min(writable_slice.len, src_left.len);</span>
<span class="line" id="L282">                mem.copy(T, writable_slice, src_left[<span class="tok-number">0</span>..n]);</span>
<span class="line" id="L283">                self.update(n);</span>
<span class="line" id="L284">                src_left = src_left[n..];</span>
<span class="line" id="L285">            }</span>
<span class="line" id="L286">        }</span>
<span class="line" id="L287"></span>
<span class="line" id="L288">        <span class="tok-comment">/// Write a single item to the fifo</span></span>
<span class="line" id="L289">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">writeItem</span>(self: *Self, item: T) !<span class="tok-type">void</span> {</span>
<span class="line" id="L290">            <span class="tok-kw">try</span> self.ensureUnusedCapacity(<span class="tok-number">1</span>);</span>
<span class="line" id="L291">            <span class="tok-kw">return</span> self.writeItemAssumeCapacity(item);</span>
<span class="line" id="L292">        }</span>
<span class="line" id="L293"></span>
<span class="line" id="L294">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">writeItemAssumeCapacity</span>(self: *Self, item: T) <span class="tok-type">void</span> {</span>
<span class="line" id="L295">            <span class="tok-kw">var</span> tail = self.head + self.count;</span>
<span class="line" id="L296">            <span class="tok-kw">if</span> (powers_of_two) {</span>
<span class="line" id="L297">                tail &amp;= self.buf.len - <span class="tok-number">1</span>;</span>
<span class="line" id="L298">            } <span class="tok-kw">else</span> {</span>
<span class="line" id="L299">                tail %= self.buf.len;</span>
<span class="line" id="L300">            }</span>
<span class="line" id="L301">            self.buf[tail] = item;</span>
<span class="line" id="L302">            self.update(<span class="tok-number">1</span>);</span>
<span class="line" id="L303">        }</span>
<span class="line" id="L304"></span>
<span class="line" id="L305">        <span class="tok-comment">/// Appends the data in `src` to the fifo.</span></span>
<span class="line" id="L306">        <span class="tok-comment">/// Allocates more memory as necessary</span></span>
<span class="line" id="L307">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">write</span>(self: *Self, src: []<span class="tok-kw">const</span> T) !<span class="tok-type">void</span> {</span>
<span class="line" id="L308">            <span class="tok-kw">try</span> self.ensureUnusedCapacity(src.len);</span>
<span class="line" id="L309"></span>
<span class="line" id="L310">            <span class="tok-kw">return</span> self.writeAssumeCapacity(src);</span>
<span class="line" id="L311">        }</span>
<span class="line" id="L312"></span>
<span class="line" id="L313">        <span class="tok-comment">/// Same as `write` except it returns the number of bytes written, which is always the same</span></span>
<span class="line" id="L314">        <span class="tok-comment">/// as `bytes.len`. The purpose of this function existing is to match `std.io.Writer` API.</span></span>
<span class="line" id="L315">        <span class="tok-kw">fn</span> <span class="tok-fn">appendWrite</span>(self: *Self, bytes: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) <span class="tok-kw">error</span>{OutOfMemory}!<span class="tok-type">usize</span> {</span>
<span class="line" id="L316">            <span class="tok-kw">try</span> self.write(bytes);</span>
<span class="line" id="L317">            <span class="tok-kw">return</span> bytes.len;</span>
<span class="line" id="L318">        }</span>
<span class="line" id="L319"></span>
<span class="line" id="L320">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">writer</span>(self: *Self) Writer {</span>
<span class="line" id="L321">            <span class="tok-kw">return</span> .{ .context = self };</span>
<span class="line" id="L322">        }</span>
<span class="line" id="L323"></span>
<span class="line" id="L324">        <span class="tok-comment">/// Make `count` items available before the current read location</span></span>
<span class="line" id="L325">        <span class="tok-kw">fn</span> <span class="tok-fn">rewind</span>(self: *Self, count: <span class="tok-type">usize</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L326">            assert(self.writableLength() &gt;= count);</span>
<span class="line" id="L327"></span>
<span class="line" id="L328">            <span class="tok-kw">var</span> head = self.head + (self.buf.len - count);</span>
<span class="line" id="L329">            <span class="tok-kw">if</span> (powers_of_two) {</span>
<span class="line" id="L330">                head &amp;= self.buf.len - <span class="tok-number">1</span>;</span>
<span class="line" id="L331">            } <span class="tok-kw">else</span> {</span>
<span class="line" id="L332">                head %= self.buf.len;</span>
<span class="line" id="L333">            }</span>
<span class="line" id="L334">            self.head = head;</span>
<span class="line" id="L335">            self.count += count;</span>
<span class="line" id="L336">        }</span>
<span class="line" id="L337"></span>
<span class="line" id="L338">        <span class="tok-comment">/// Place data back into the read stream</span></span>
<span class="line" id="L339">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">unget</span>(self: *Self, src: []<span class="tok-kw">const</span> T) !<span class="tok-type">void</span> {</span>
<span class="line" id="L340">            <span class="tok-kw">try</span> self.ensureUnusedCapacity(src.len);</span>
<span class="line" id="L341"></span>
<span class="line" id="L342">            self.rewind(src.len);</span>
<span class="line" id="L343"></span>
<span class="line" id="L344">            <span class="tok-kw">const</span> slice = self.readableSliceMut(<span class="tok-number">0</span>);</span>
<span class="line" id="L345">            <span class="tok-kw">if</span> (src.len &lt; slice.len) {</span>
<span class="line" id="L346">                mem.copy(T, slice, src);</span>
<span class="line" id="L347">            } <span class="tok-kw">else</span> {</span>
<span class="line" id="L348">                mem.copy(T, slice, src[<span class="tok-number">0</span>..slice.len]);</span>
<span class="line" id="L349">                <span class="tok-kw">const</span> slice2 = self.readableSliceMut(slice.len);</span>
<span class="line" id="L350">                mem.copy(T, slice2, src[slice.len..]);</span>
<span class="line" id="L351">            }</span>
<span class="line" id="L352">        }</span>
<span class="line" id="L353"></span>
<span class="line" id="L354">        <span class="tok-comment">/// Returns the item at `offset`.</span></span>
<span class="line" id="L355">        <span class="tok-comment">/// Asserts offset is within bounds.</span></span>
<span class="line" id="L356">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">peekItem</span>(self: Self, offset: <span class="tok-type">usize</span>) T {</span>
<span class="line" id="L357">            assert(offset &lt; self.count);</span>
<span class="line" id="L358"></span>
<span class="line" id="L359">            <span class="tok-kw">var</span> index = self.head + offset;</span>
<span class="line" id="L360">            <span class="tok-kw">if</span> (powers_of_two) {</span>
<span class="line" id="L361">                index &amp;= self.buf.len - <span class="tok-number">1</span>;</span>
<span class="line" id="L362">            } <span class="tok-kw">else</span> {</span>
<span class="line" id="L363">                index %= self.buf.len;</span>
<span class="line" id="L364">            }</span>
<span class="line" id="L365">            <span class="tok-kw">return</span> self.buf[index];</span>
<span class="line" id="L366">        }</span>
<span class="line" id="L367"></span>
<span class="line" id="L368">        <span class="tok-comment">/// Pump data from a reader into a writer</span></span>
<span class="line" id="L369">        <span class="tok-comment">/// stops when reader returns 0 bytes (EOF)</span></span>
<span class="line" id="L370">        <span class="tok-comment">/// Buffer size must be set before calling; a buffer length of 0 is invalid.</span></span>
<span class="line" id="L371">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">pump</span>(self: *Self, src_reader: <span class="tok-kw">anytype</span>, dest_writer: <span class="tok-kw">anytype</span>) !<span class="tok-type">void</span> {</span>
<span class="line" id="L372">            assert(self.buf.len &gt; <span class="tok-number">0</span>);</span>
<span class="line" id="L373">            <span class="tok-kw">while</span> (<span class="tok-null">true</span>) {</span>
<span class="line" id="L374">                <span class="tok-kw">if</span> (self.writableLength() &gt; <span class="tok-number">0</span>) {</span>
<span class="line" id="L375">                    <span class="tok-kw">const</span> n = <span class="tok-kw">try</span> src_reader.read(self.writableSlice(<span class="tok-number">0</span>));</span>
<span class="line" id="L376">                    <span class="tok-kw">if</span> (n == <span class="tok-number">0</span>) <span class="tok-kw">break</span>; <span class="tok-comment">// EOF</span>
</span>
<span class="line" id="L377">                    self.update(n);</span>
<span class="line" id="L378">                }</span>
<span class="line" id="L379">                self.discard(<span class="tok-kw">try</span> dest_writer.write(self.readableSlice(<span class="tok-number">0</span>)));</span>
<span class="line" id="L380">            }</span>
<span class="line" id="L381">            <span class="tok-comment">// flush remaining data</span>
</span>
<span class="line" id="L382">            <span class="tok-kw">while</span> (self.readableLength() &gt; <span class="tok-number">0</span>) {</span>
<span class="line" id="L383">                self.discard(<span class="tok-kw">try</span> dest_writer.write(self.readableSlice(<span class="tok-number">0</span>)));</span>
<span class="line" id="L384">            }</span>
<span class="line" id="L385">        }</span>
<span class="line" id="L386">    };</span>
<span class="line" id="L387">}</span>
<span class="line" id="L388"></span>
<span class="line" id="L389"><span class="tok-kw">test</span> <span class="tok-str">&quot;LinearFifo(u8, .Dynamic) discard(0) from empty buffer should not error on overflow&quot;</span> {</span>
<span class="line" id="L390">    <span class="tok-kw">var</span> fifo = LinearFifo(<span class="tok-type">u8</span>, .Dynamic).init(testing.allocator);</span>
<span class="line" id="L391">    <span class="tok-kw">defer</span> fifo.deinit();</span>
<span class="line" id="L392"></span>
<span class="line" id="L393">    <span class="tok-comment">// If overflow is not explicitly allowed this will crash in debug / safe mode</span>
</span>
<span class="line" id="L394">    fifo.discard(<span class="tok-number">0</span>);</span>
<span class="line" id="L395">}</span>
<span class="line" id="L396"></span>
<span class="line" id="L397"><span class="tok-kw">test</span> <span class="tok-str">&quot;LinearFifo(u8, .Dynamic)&quot;</span> {</span>
<span class="line" id="L398">    <span class="tok-kw">var</span> fifo = LinearFifo(<span class="tok-type">u8</span>, .Dynamic).init(testing.allocator);</span>
<span class="line" id="L399">    <span class="tok-kw">defer</span> fifo.deinit();</span>
<span class="line" id="L400"></span>
<span class="line" id="L401">    <span class="tok-kw">try</span> fifo.write(<span class="tok-str">&quot;HELLO&quot;</span>);</span>
<span class="line" id="L402">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">usize</span>, <span class="tok-number">5</span>), fifo.readableLength());</span>
<span class="line" id="L403">    <span class="tok-kw">try</span> testing.expectEqualSlices(<span class="tok-type">u8</span>, <span class="tok-str">&quot;HELLO&quot;</span>, fifo.readableSlice(<span class="tok-number">0</span>));</span>
<span class="line" id="L404"></span>
<span class="line" id="L405">    {</span>
<span class="line" id="L406">        <span class="tok-kw">var</span> i: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L407">        <span class="tok-kw">while</span> (i &lt; <span class="tok-number">5</span>) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L408">            <span class="tok-kw">try</span> fifo.write(&amp;[_]<span class="tok-type">u8</span>{fifo.peekItem(i)});</span>
<span class="line" id="L409">        }</span>
<span class="line" id="L410">        <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">usize</span>, <span class="tok-number">10</span>), fifo.readableLength());</span>
<span class="line" id="L411">        <span class="tok-kw">try</span> testing.expectEqualSlices(<span class="tok-type">u8</span>, <span class="tok-str">&quot;HELLOHELLO&quot;</span>, fifo.readableSlice(<span class="tok-number">0</span>));</span>
<span class="line" id="L412">    }</span>
<span class="line" id="L413"></span>
<span class="line" id="L414">    {</span>
<span class="line" id="L415">        <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">u8</span>, <span class="tok-str">'H'</span>), fifo.readItem().?);</span>
<span class="line" id="L416">        <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">u8</span>, <span class="tok-str">'E'</span>), fifo.readItem().?);</span>
<span class="line" id="L417">        <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">u8</span>, <span class="tok-str">'L'</span>), fifo.readItem().?);</span>
<span class="line" id="L418">        <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">u8</span>, <span class="tok-str">'L'</span>), fifo.readItem().?);</span>
<span class="line" id="L419">        <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">u8</span>, <span class="tok-str">'O'</span>), fifo.readItem().?);</span>
<span class="line" id="L420">    }</span>
<span class="line" id="L421">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">usize</span>, <span class="tok-number">5</span>), fifo.readableLength());</span>
<span class="line" id="L422"></span>
<span class="line" id="L423">    { <span class="tok-comment">// Writes that wrap around</span>
</span>
<span class="line" id="L424">        <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">usize</span>, <span class="tok-number">11</span>), fifo.writableLength());</span>
<span class="line" id="L425">        <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">usize</span>, <span class="tok-number">6</span>), fifo.writableSlice(<span class="tok-number">0</span>).len);</span>
<span class="line" id="L426">        fifo.writeAssumeCapacity(<span class="tok-str">&quot;6&lt;chars&lt;11&quot;</span>);</span>
<span class="line" id="L427">        <span class="tok-kw">try</span> testing.expectEqualSlices(<span class="tok-type">u8</span>, <span class="tok-str">&quot;HELLO6&lt;char&quot;</span>, fifo.readableSlice(<span class="tok-number">0</span>));</span>
<span class="line" id="L428">        <span class="tok-kw">try</span> testing.expectEqualSlices(<span class="tok-type">u8</span>, <span class="tok-str">&quot;s&lt;11&quot;</span>, fifo.readableSlice(<span class="tok-number">11</span>));</span>
<span class="line" id="L429">        <span class="tok-kw">try</span> testing.expectEqualSlices(<span class="tok-type">u8</span>, <span class="tok-str">&quot;11&quot;</span>, fifo.readableSlice(<span class="tok-number">13</span>));</span>
<span class="line" id="L430">        <span class="tok-kw">try</span> testing.expectEqualSlices(<span class="tok-type">u8</span>, <span class="tok-str">&quot;&quot;</span>, fifo.readableSlice(<span class="tok-number">15</span>));</span>
<span class="line" id="L431">        fifo.discard(<span class="tok-number">11</span>);</span>
<span class="line" id="L432">        <span class="tok-kw">try</span> testing.expectEqualSlices(<span class="tok-type">u8</span>, <span class="tok-str">&quot;s&lt;11&quot;</span>, fifo.readableSlice(<span class="tok-number">0</span>));</span>
<span class="line" id="L433">        fifo.discard(<span class="tok-number">4</span>);</span>
<span class="line" id="L434">        <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">usize</span>, <span class="tok-number">0</span>), fifo.readableLength());</span>
<span class="line" id="L435">    }</span>
<span class="line" id="L436"></span>
<span class="line" id="L437">    {</span>
<span class="line" id="L438">        <span class="tok-kw">const</span> buf = <span class="tok-kw">try</span> fifo.writableWithSize(<span class="tok-number">12</span>);</span>
<span class="line" id="L439">        <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">usize</span>, <span class="tok-number">12</span>), buf.len);</span>
<span class="line" id="L440">        <span class="tok-kw">var</span> i: <span class="tok-type">u8</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L441">        <span class="tok-kw">while</span> (i &lt; <span class="tok-number">10</span>) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L442">            buf[i] = i + <span class="tok-str">'a'</span>;</span>
<span class="line" id="L443">        }</span>
<span class="line" id="L444">        fifo.update(<span class="tok-number">10</span>);</span>
<span class="line" id="L445">        <span class="tok-kw">try</span> testing.expectEqualSlices(<span class="tok-type">u8</span>, <span class="tok-str">&quot;abcdefghij&quot;</span>, fifo.readableSlice(<span class="tok-number">0</span>));</span>
<span class="line" id="L446">    }</span>
<span class="line" id="L447"></span>
<span class="line" id="L448">    {</span>
<span class="line" id="L449">        <span class="tok-kw">try</span> fifo.unget(<span class="tok-str">&quot;prependedstring&quot;</span>);</span>
<span class="line" id="L450">        <span class="tok-kw">var</span> result: [<span class="tok-number">30</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L451">        <span class="tok-kw">try</span> testing.expectEqualSlices(<span class="tok-type">u8</span>, <span class="tok-str">&quot;prependedstringabcdefghij&quot;</span>, result[<span class="tok-number">0</span>..fifo.read(&amp;result)]);</span>
<span class="line" id="L452">        <span class="tok-kw">try</span> fifo.unget(<span class="tok-str">&quot;b&quot;</span>);</span>
<span class="line" id="L453">        <span class="tok-kw">try</span> fifo.unget(<span class="tok-str">&quot;a&quot;</span>);</span>
<span class="line" id="L454">        <span class="tok-kw">try</span> testing.expectEqualSlices(<span class="tok-type">u8</span>, <span class="tok-str">&quot;ab&quot;</span>, result[<span class="tok-number">0</span>..fifo.read(&amp;result)]);</span>
<span class="line" id="L455">    }</span>
<span class="line" id="L456"></span>
<span class="line" id="L457">    fifo.shrink(<span class="tok-number">0</span>);</span>
<span class="line" id="L458"></span>
<span class="line" id="L459">    {</span>
<span class="line" id="L460">        <span class="tok-kw">try</span> fifo.writer().print(<span class="tok-str">&quot;{s}, {s}!&quot;</span>, .{ <span class="tok-str">&quot;Hello&quot;</span>, <span class="tok-str">&quot;World&quot;</span> });</span>
<span class="line" id="L461">        <span class="tok-kw">var</span> result: [<span class="tok-number">30</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L462">        <span class="tok-kw">try</span> testing.expectEqualSlices(<span class="tok-type">u8</span>, <span class="tok-str">&quot;Hello, World!&quot;</span>, result[<span class="tok-number">0</span>..fifo.read(&amp;result)]);</span>
<span class="line" id="L463">        <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">usize</span>, <span class="tok-number">0</span>), fifo.readableLength());</span>
<span class="line" id="L464">    }</span>
<span class="line" id="L465"></span>
<span class="line" id="L466">    {</span>
<span class="line" id="L467">        <span class="tok-kw">try</span> fifo.writer().writeAll(<span class="tok-str">&quot;This is a test&quot;</span>);</span>
<span class="line" id="L468">        <span class="tok-kw">var</span> result: [<span class="tok-number">30</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L469">        <span class="tok-kw">try</span> testing.expectEqualSlices(<span class="tok-type">u8</span>, <span class="tok-str">&quot;This&quot;</span>, (<span class="tok-kw">try</span> fifo.reader().readUntilDelimiterOrEof(&amp;result, <span class="tok-str">' '</span>)).?);</span>
<span class="line" id="L470">        <span class="tok-kw">try</span> testing.expectEqualSlices(<span class="tok-type">u8</span>, <span class="tok-str">&quot;is&quot;</span>, (<span class="tok-kw">try</span> fifo.reader().readUntilDelimiterOrEof(&amp;result, <span class="tok-str">' '</span>)).?);</span>
<span class="line" id="L471">        <span class="tok-kw">try</span> testing.expectEqualSlices(<span class="tok-type">u8</span>, <span class="tok-str">&quot;a&quot;</span>, (<span class="tok-kw">try</span> fifo.reader().readUntilDelimiterOrEof(&amp;result, <span class="tok-str">' '</span>)).?);</span>
<span class="line" id="L472">        <span class="tok-kw">try</span> testing.expectEqualSlices(<span class="tok-type">u8</span>, <span class="tok-str">&quot;test&quot;</span>, (<span class="tok-kw">try</span> fifo.reader().readUntilDelimiterOrEof(&amp;result, <span class="tok-str">' '</span>)).?);</span>
<span class="line" id="L473">    }</span>
<span class="line" id="L474"></span>
<span class="line" id="L475">    {</span>
<span class="line" id="L476">        <span class="tok-kw">try</span> fifo.ensureTotalCapacity(<span class="tok-number">1</span>);</span>
<span class="line" id="L477">        <span class="tok-kw">var</span> in_fbs = std.io.fixedBufferStream(<span class="tok-str">&quot;pump test&quot;</span>);</span>
<span class="line" id="L478">        <span class="tok-kw">var</span> out_buf: [<span class="tok-number">50</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L479">        <span class="tok-kw">var</span> out_fbs = std.io.fixedBufferStream(&amp;out_buf);</span>
<span class="line" id="L480">        <span class="tok-kw">try</span> fifo.pump(in_fbs.reader(), out_fbs.writer());</span>
<span class="line" id="L481">        <span class="tok-kw">try</span> testing.expectEqualSlices(<span class="tok-type">u8</span>, in_fbs.buffer, out_fbs.getWritten());</span>
<span class="line" id="L482">    }</span>
<span class="line" id="L483">}</span>
<span class="line" id="L484"></span>
<span class="line" id="L485"><span class="tok-kw">test</span> <span class="tok-str">&quot;LinearFifo&quot;</span> {</span>
<span class="line" id="L486">    <span class="tok-kw">inline</span> <span class="tok-kw">for</span> ([_]<span class="tok-type">type</span>{ <span class="tok-type">u1</span>, <span class="tok-type">u8</span>, <span class="tok-type">u16</span>, <span class="tok-type">u64</span> }) |T| {</span>
<span class="line" id="L487">        <span class="tok-kw">inline</span> <span class="tok-kw">for</span> ([_]LinearFifoBufferType{ LinearFifoBufferType{ .Static = <span class="tok-number">32</span> }, .Slice, .Dynamic }) |bt| {</span>
<span class="line" id="L488">            <span class="tok-kw">const</span> FifoType = LinearFifo(T, bt);</span>
<span class="line" id="L489">            <span class="tok-kw">var</span> buf: <span class="tok-kw">if</span> (bt == .Slice) [<span class="tok-number">32</span>]T <span class="tok-kw">else</span> <span class="tok-type">void</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L490">            <span class="tok-kw">var</span> fifo = <span class="tok-kw">switch</span> (bt) {</span>
<span class="line" id="L491">                .Static =&gt; FifoType.init(),</span>
<span class="line" id="L492">                .Slice =&gt; FifoType.init(buf[<span class="tok-number">0</span>..]),</span>
<span class="line" id="L493">                .Dynamic =&gt; FifoType.init(testing.allocator),</span>
<span class="line" id="L494">            };</span>
<span class="line" id="L495">            <span class="tok-kw">defer</span> fifo.deinit();</span>
<span class="line" id="L496"></span>
<span class="line" id="L497">            <span class="tok-kw">try</span> fifo.write(&amp;[_]T{ <span class="tok-number">0</span>, <span class="tok-number">1</span>, <span class="tok-number">1</span>, <span class="tok-number">0</span>, <span class="tok-number">1</span> });</span>
<span class="line" id="L498">            <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">usize</span>, <span class="tok-number">5</span>), fifo.readableLength());</span>
<span class="line" id="L499"></span>
<span class="line" id="L500">            {</span>
<span class="line" id="L501">                <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(T, <span class="tok-number">0</span>), fifo.readItem().?);</span>
<span class="line" id="L502">                <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(T, <span class="tok-number">1</span>), fifo.readItem().?);</span>
<span class="line" id="L503">                <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(T, <span class="tok-number">1</span>), fifo.readItem().?);</span>
<span class="line" id="L504">                <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(T, <span class="tok-number">0</span>), fifo.readItem().?);</span>
<span class="line" id="L505">                <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(T, <span class="tok-number">1</span>), fifo.readItem().?);</span>
<span class="line" id="L506">                <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">usize</span>, <span class="tok-number">0</span>), fifo.readableLength());</span>
<span class="line" id="L507">            }</span>
<span class="line" id="L508"></span>
<span class="line" id="L509">            {</span>
<span class="line" id="L510">                <span class="tok-kw">try</span> fifo.writeItem(<span class="tok-number">1</span>);</span>
<span class="line" id="L511">                <span class="tok-kw">try</span> fifo.writeItem(<span class="tok-number">1</span>);</span>
<span class="line" id="L512">                <span class="tok-kw">try</span> fifo.writeItem(<span class="tok-number">1</span>);</span>
<span class="line" id="L513">                <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">usize</span>, <span class="tok-number">3</span>), fifo.readableLength());</span>
<span class="line" id="L514">            }</span>
<span class="line" id="L515"></span>
<span class="line" id="L516">            {</span>
<span class="line" id="L517">                <span class="tok-kw">var</span> readBuf: [<span class="tok-number">3</span>]T = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L518">                <span class="tok-kw">const</span> n = fifo.read(&amp;readBuf);</span>
<span class="line" id="L519">                <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">usize</span>, <span class="tok-number">3</span>), n); <span class="tok-comment">// NOTE: It should be the number of items.</span>
</span>
<span class="line" id="L520">            }</span>
<span class="line" id="L521">        }</span>
<span class="line" id="L522">    }</span>
<span class="line" id="L523">}</span>
<span class="line" id="L524"></span>
</code></pre></body>
</html>