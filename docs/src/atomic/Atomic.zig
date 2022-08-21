<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">    <title>atomic/Atomic.zig - source view</title>
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
<span class="line" id="L2"><span class="tok-kw">const</span> builtin = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;builtin&quot;</span>);</span>
<span class="line" id="L3"></span>
<span class="line" id="L4"><span class="tok-kw">const</span> testing = std.testing;</span>
<span class="line" id="L5"><span class="tok-kw">const</span> Ordering = std.atomic.Ordering;</span>
<span class="line" id="L6"></span>
<span class="line" id="L7"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">Atomic</span>(<span class="tok-kw">comptime</span> T: <span class="tok-type">type</span>) <span class="tok-type">type</span> {</span>
<span class="line" id="L8">    <span class="tok-kw">return</span> <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L9">        value: T,</span>
<span class="line" id="L10"></span>
<span class="line" id="L11">        <span class="tok-kw">const</span> Self = <span class="tok-builtin">@This</span>();</span>
<span class="line" id="L12"></span>
<span class="line" id="L13">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">init</span>(value: T) Self {</span>
<span class="line" id="L14">            <span class="tok-kw">return</span> .{ .value = value };</span>
<span class="line" id="L15">        }</span>
<span class="line" id="L16"></span>
<span class="line" id="L17">        <span class="tok-comment">/// Perform an atomic fence which uses the atomic value as a hint for the modification order.</span></span>
<span class="line" id="L18">        <span class="tok-comment">/// Use this when you want to imply a fence on an atomic variable without necessarily performing a memory access.</span></span>
<span class="line" id="L19">        <span class="tok-comment">///</span></span>
<span class="line" id="L20">        <span class="tok-comment">/// Example:</span></span>
<span class="line" id="L21">        <span class="tok-comment">/// ```</span></span>
<span class="line" id="L22">        <span class="tok-comment">/// const RefCount = struct {</span></span>
<span class="line" id="L23">        <span class="tok-comment">///     count: Atomic(usize),</span></span>
<span class="line" id="L24">        <span class="tok-comment">///     dropFn: *const fn(*RefCount) void,</span></span>
<span class="line" id="L25">        <span class="tok-comment">///</span></span>
<span class="line" id="L26">        <span class="tok-comment">///     fn ref(self: *RefCount) void {</span></span>
<span class="line" id="L27">        <span class="tok-comment">///         _ =  self.count.fetchAdd(1, .Monotonic); // no ordering necessary, just updating a counter</span></span>
<span class="line" id="L28">        <span class="tok-comment">///     }</span></span>
<span class="line" id="L29">        <span class="tok-comment">///</span></span>
<span class="line" id="L30">        <span class="tok-comment">///     fn unref(self: *RefCount) void {</span></span>
<span class="line" id="L31">        <span class="tok-comment">///         // Release ensures code before unref() happens-before the count is decremented as dropFn could be called by then.</span></span>
<span class="line" id="L32">        <span class="tok-comment">///         if (self.count.fetchSub(1, .Release)) {</span></span>
<span class="line" id="L33">        <span class="tok-comment">///             // Acquire ensures count decrement and code before previous unrefs()s happens-before we call dropFn below.</span></span>
<span class="line" id="L34">        <span class="tok-comment">///             // NOTE: another alterative is to use .AcqRel on the fetchSub count decrement but it's extra barrier in possibly hot path.</span></span>
<span class="line" id="L35">        <span class="tok-comment">///             self.count.fence(.Acquire);</span></span>
<span class="line" id="L36">        <span class="tok-comment">///             (self.dropFn)(self);</span></span>
<span class="line" id="L37">        <span class="tok-comment">///         }</span></span>
<span class="line" id="L38">        <span class="tok-comment">///     }</span></span>
<span class="line" id="L39">        <span class="tok-comment">/// };</span></span>
<span class="line" id="L40">        <span class="tok-comment">/// ```</span></span>
<span class="line" id="L41">        <span class="tok-kw">pub</span> <span class="tok-kw">inline</span> <span class="tok-kw">fn</span> <span class="tok-fn">fence</span>(self: *Self, <span class="tok-kw">comptime</span> ordering: Ordering) <span class="tok-type">void</span> {</span>
<span class="line" id="L42">            <span class="tok-comment">// LLVM's ThreadSanitizer doesn't support the normal fences so we specialize for it.</span>
</span>
<span class="line" id="L43">            <span class="tok-kw">if</span> (builtin.sanitize_thread) {</span>
<span class="line" id="L44">                <span class="tok-kw">const</span> tsan = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L45">                    <span class="tok-kw">extern</span> <span class="tok-str">&quot;c&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">__tsan_acquire</span>(addr: *<span class="tok-type">anyopaque</span>) <span class="tok-type">void</span>;</span>
<span class="line" id="L46">                    <span class="tok-kw">extern</span> <span class="tok-str">&quot;c&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">__tsan_release</span>(addr: *<span class="tok-type">anyopaque</span>) <span class="tok-type">void</span>;</span>
<span class="line" id="L47">                };</span>
<span class="line" id="L48"></span>
<span class="line" id="L49">                <span class="tok-kw">const</span> addr = <span class="tok-builtin">@ptrCast</span>(*<span class="tok-type">anyopaque</span>, self);</span>
<span class="line" id="L50">                <span class="tok-kw">return</span> <span class="tok-kw">switch</span> (ordering) {</span>
<span class="line" id="L51">                    .Unordered, .Monotonic =&gt; <span class="tok-builtin">@compileError</span>(<span class="tok-builtin">@tagName</span>(ordering) ++ <span class="tok-str">&quot; only applies to atomic loads and stores&quot;</span>),</span>
<span class="line" id="L52">                    .Acquire =&gt; tsan.__tsan_acquire(addr),</span>
<span class="line" id="L53">                    .Release =&gt; tsan.__tsan_release(addr),</span>
<span class="line" id="L54">                    .AcqRel, .SeqCst =&gt; {</span>
<span class="line" id="L55">                        tsan.__tsan_acquire(addr);</span>
<span class="line" id="L56">                        tsan.__tsan_release(addr);</span>
<span class="line" id="L57">                    },</span>
<span class="line" id="L58">                };</span>
<span class="line" id="L59">            }</span>
<span class="line" id="L60"></span>
<span class="line" id="L61">            <span class="tok-kw">return</span> std.atomic.fence(ordering);</span>
<span class="line" id="L62">        }</span>
<span class="line" id="L63"></span>
<span class="line" id="L64">        <span class="tok-comment">/// Non-atomically load from the atomic value without synchronization.</span></span>
<span class="line" id="L65">        <span class="tok-comment">/// Care must be taken to avoid data-races when interacting with other atomic operations.</span></span>
<span class="line" id="L66">        <span class="tok-kw">pub</span> <span class="tok-kw">inline</span> <span class="tok-kw">fn</span> <span class="tok-fn">loadUnchecked</span>(self: Self) T {</span>
<span class="line" id="L67">            <span class="tok-kw">return</span> self.value;</span>
<span class="line" id="L68">        }</span>
<span class="line" id="L69"></span>
<span class="line" id="L70">        <span class="tok-comment">/// Non-atomically store to the atomic value without synchronization.</span></span>
<span class="line" id="L71">        <span class="tok-comment">/// Care must be taken to avoid data-races when interacting with other atomic operations.</span></span>
<span class="line" id="L72">        <span class="tok-kw">pub</span> <span class="tok-kw">inline</span> <span class="tok-kw">fn</span> <span class="tok-fn">storeUnchecked</span>(self: *Self, value: T) <span class="tok-type">void</span> {</span>
<span class="line" id="L73">            self.value = value;</span>
<span class="line" id="L74">        }</span>
<span class="line" id="L75"></span>
<span class="line" id="L76">        <span class="tok-kw">pub</span> <span class="tok-kw">inline</span> <span class="tok-kw">fn</span> <span class="tok-fn">load</span>(self: *<span class="tok-kw">const</span> Self, <span class="tok-kw">comptime</span> ordering: Ordering) T {</span>
<span class="line" id="L77">            <span class="tok-kw">return</span> <span class="tok-kw">switch</span> (ordering) {</span>
<span class="line" id="L78">                .AcqRel =&gt; <span class="tok-builtin">@compileError</span>(<span class="tok-builtin">@tagName</span>(ordering) ++ <span class="tok-str">&quot; implies &quot;</span> ++ <span class="tok-builtin">@tagName</span>(Ordering.Release) ++ <span class="tok-str">&quot; which is only allowed on atomic stores&quot;</span>),</span>
<span class="line" id="L79">                .Release =&gt; <span class="tok-builtin">@compileError</span>(<span class="tok-builtin">@tagName</span>(ordering) ++ <span class="tok-str">&quot; is only allowed on atomic stores&quot;</span>),</span>
<span class="line" id="L80">                <span class="tok-kw">else</span> =&gt; <span class="tok-builtin">@atomicLoad</span>(T, &amp;self.value, ordering),</span>
<span class="line" id="L81">            };</span>
<span class="line" id="L82">        }</span>
<span class="line" id="L83"></span>
<span class="line" id="L84">        <span class="tok-kw">pub</span> <span class="tok-kw">inline</span> <span class="tok-kw">fn</span> <span class="tok-fn">store</span>(self: *Self, value: T, <span class="tok-kw">comptime</span> ordering: Ordering) <span class="tok-type">void</span> {</span>
<span class="line" id="L85">            <span class="tok-kw">return</span> <span class="tok-kw">switch</span> (ordering) {</span>
<span class="line" id="L86">                .AcqRel =&gt; <span class="tok-builtin">@compileError</span>(<span class="tok-builtin">@tagName</span>(ordering) ++ <span class="tok-str">&quot; implies &quot;</span> ++ <span class="tok-builtin">@tagName</span>(Ordering.Acquire) ++ <span class="tok-str">&quot; which is only allowed on atomic loads&quot;</span>),</span>
<span class="line" id="L87">                .Acquire =&gt; <span class="tok-builtin">@compileError</span>(<span class="tok-builtin">@tagName</span>(ordering) ++ <span class="tok-str">&quot; is only allowed on atomic loads&quot;</span>),</span>
<span class="line" id="L88">                <span class="tok-kw">else</span> =&gt; <span class="tok-builtin">@atomicStore</span>(T, &amp;self.value, value, ordering),</span>
<span class="line" id="L89">            };</span>
<span class="line" id="L90">        }</span>
<span class="line" id="L91"></span>
<span class="line" id="L92">        <span class="tok-kw">pub</span> <span class="tok-kw">inline</span> <span class="tok-kw">fn</span> <span class="tok-fn">swap</span>(self: *Self, value: T, <span class="tok-kw">comptime</span> ordering: Ordering) T {</span>
<span class="line" id="L93">            <span class="tok-kw">return</span> self.rmw(.Xchg, value, ordering);</span>
<span class="line" id="L94">        }</span>
<span class="line" id="L95"></span>
<span class="line" id="L96">        <span class="tok-kw">pub</span> <span class="tok-kw">inline</span> <span class="tok-kw">fn</span> <span class="tok-fn">compareAndSwap</span>(</span>
<span class="line" id="L97">            self: *Self,</span>
<span class="line" id="L98">            compare: T,</span>
<span class="line" id="L99">            exchange: T,</span>
<span class="line" id="L100">            <span class="tok-kw">comptime</span> success: Ordering,</span>
<span class="line" id="L101">            <span class="tok-kw">comptime</span> failure: Ordering,</span>
<span class="line" id="L102">        ) ?T {</span>
<span class="line" id="L103">            <span class="tok-kw">return</span> self.cmpxchg(<span class="tok-null">true</span>, compare, exchange, success, failure);</span>
<span class="line" id="L104">        }</span>
<span class="line" id="L105"></span>
<span class="line" id="L106">        <span class="tok-kw">pub</span> <span class="tok-kw">inline</span> <span class="tok-kw">fn</span> <span class="tok-fn">tryCompareAndSwap</span>(</span>
<span class="line" id="L107">            self: *Self,</span>
<span class="line" id="L108">            compare: T,</span>
<span class="line" id="L109">            exchange: T,</span>
<span class="line" id="L110">            <span class="tok-kw">comptime</span> success: Ordering,</span>
<span class="line" id="L111">            <span class="tok-kw">comptime</span> failure: Ordering,</span>
<span class="line" id="L112">        ) ?T {</span>
<span class="line" id="L113">            <span class="tok-kw">return</span> self.cmpxchg(<span class="tok-null">false</span>, compare, exchange, success, failure);</span>
<span class="line" id="L114">        }</span>
<span class="line" id="L115"></span>
<span class="line" id="L116">        <span class="tok-kw">inline</span> <span class="tok-kw">fn</span> <span class="tok-fn">cmpxchg</span>(</span>
<span class="line" id="L117">            self: *Self,</span>
<span class="line" id="L118">            <span class="tok-kw">comptime</span> is_strong: <span class="tok-type">bool</span>,</span>
<span class="line" id="L119">            compare: T,</span>
<span class="line" id="L120">            exchange: T,</span>
<span class="line" id="L121">            <span class="tok-kw">comptime</span> success: Ordering,</span>
<span class="line" id="L122">            <span class="tok-kw">comptime</span> failure: Ordering,</span>
<span class="line" id="L123">        ) ?T {</span>
<span class="line" id="L124">            <span class="tok-kw">if</span> (success == .Unordered <span class="tok-kw">or</span> failure == .Unordered) {</span>
<span class="line" id="L125">                <span class="tok-builtin">@compileError</span>(<span class="tok-builtin">@tagName</span>(Ordering.Unordered) ++ <span class="tok-str">&quot; is only allowed on atomic loads and stores&quot;</span>);</span>
<span class="line" id="L126">            }</span>
<span class="line" id="L127"></span>
<span class="line" id="L128">            <span class="tok-kw">comptime</span> <span class="tok-kw">var</span> success_is_stronger = <span class="tok-kw">switch</span> (failure) {</span>
<span class="line" id="L129">                .SeqCst =&gt; success == .SeqCst,</span>
<span class="line" id="L130">                .AcqRel =&gt; <span class="tok-builtin">@compileError</span>(<span class="tok-builtin">@tagName</span>(failure) ++ <span class="tok-str">&quot; implies &quot;</span> ++ <span class="tok-builtin">@tagName</span>(Ordering.Release) ++ <span class="tok-str">&quot; which is only allowed on success&quot;</span>),</span>
<span class="line" id="L131">                .Acquire =&gt; success == .SeqCst <span class="tok-kw">or</span> success == .AcqRel <span class="tok-kw">or</span> success == .Acquire,</span>
<span class="line" id="L132">                .Release =&gt; <span class="tok-builtin">@compileError</span>(<span class="tok-builtin">@tagName</span>(failure) ++ <span class="tok-str">&quot; is only allowed on success&quot;</span>),</span>
<span class="line" id="L133">                .Monotonic =&gt; <span class="tok-null">true</span>,</span>
<span class="line" id="L134">                .Unordered =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L135">            };</span>
<span class="line" id="L136"></span>
<span class="line" id="L137">            <span class="tok-kw">if</span> (!success_is_stronger) {</span>
<span class="line" id="L138">                <span class="tok-builtin">@compileError</span>(<span class="tok-builtin">@tagName</span>(success) ++ <span class="tok-str">&quot; must be stronger than &quot;</span> ++ <span class="tok-builtin">@tagName</span>(failure));</span>
<span class="line" id="L139">            }</span>
<span class="line" id="L140"></span>
<span class="line" id="L141">            <span class="tok-kw">return</span> <span class="tok-kw">switch</span> (is_strong) {</span>
<span class="line" id="L142">                <span class="tok-null">true</span> =&gt; <span class="tok-builtin">@cmpxchgStrong</span>(T, &amp;self.value, compare, exchange, success, failure),</span>
<span class="line" id="L143">                <span class="tok-null">false</span> =&gt; <span class="tok-builtin">@cmpxchgWeak</span>(T, &amp;self.value, compare, exchange, success, failure),</span>
<span class="line" id="L144">            };</span>
<span class="line" id="L145">        }</span>
<span class="line" id="L146"></span>
<span class="line" id="L147">        <span class="tok-kw">inline</span> <span class="tok-kw">fn</span> <span class="tok-fn">rmw</span>(</span>
<span class="line" id="L148">            self: *Self,</span>
<span class="line" id="L149">            <span class="tok-kw">comptime</span> op: std.builtin.AtomicRmwOp,</span>
<span class="line" id="L150">            value: T,</span>
<span class="line" id="L151">            <span class="tok-kw">comptime</span> ordering: Ordering,</span>
<span class="line" id="L152">        ) T {</span>
<span class="line" id="L153">            <span class="tok-kw">return</span> <span class="tok-builtin">@atomicRmw</span>(T, &amp;self.value, op, value, ordering);</span>
<span class="line" id="L154">        }</span>
<span class="line" id="L155"></span>
<span class="line" id="L156">        <span class="tok-kw">fn</span> <span class="tok-fn">exportWhen</span>(<span class="tok-kw">comptime</span> condition: <span class="tok-type">bool</span>, <span class="tok-kw">comptime</span> functions: <span class="tok-type">type</span>) <span class="tok-type">type</span> {</span>
<span class="line" id="L157">            <span class="tok-kw">return</span> <span class="tok-kw">if</span> (condition) functions <span class="tok-kw">else</span> <span class="tok-kw">struct</span> {};</span>
<span class="line" id="L158">        }</span>
<span class="line" id="L159"></span>
<span class="line" id="L160">        <span class="tok-kw">pub</span> <span class="tok-kw">usingnamespace</span> exportWhen(std.meta.trait.isNumber(T), <span class="tok-kw">struct</span> {</span>
<span class="line" id="L161">            <span class="tok-kw">pub</span> <span class="tok-kw">inline</span> <span class="tok-kw">fn</span> <span class="tok-fn">fetchAdd</span>(self: *Self, value: T, <span class="tok-kw">comptime</span> ordering: Ordering) T {</span>
<span class="line" id="L162">                <span class="tok-kw">return</span> self.rmw(.Add, value, ordering);</span>
<span class="line" id="L163">            }</span>
<span class="line" id="L164"></span>
<span class="line" id="L165">            <span class="tok-kw">pub</span> <span class="tok-kw">inline</span> <span class="tok-kw">fn</span> <span class="tok-fn">fetchSub</span>(self: *Self, value: T, <span class="tok-kw">comptime</span> ordering: Ordering) T {</span>
<span class="line" id="L166">                <span class="tok-kw">return</span> self.rmw(.Sub, value, ordering);</span>
<span class="line" id="L167">            }</span>
<span class="line" id="L168"></span>
<span class="line" id="L169">            <span class="tok-kw">pub</span> <span class="tok-kw">inline</span> <span class="tok-kw">fn</span> <span class="tok-fn">fetchMin</span>(self: *Self, value: T, <span class="tok-kw">comptime</span> ordering: Ordering) T {</span>
<span class="line" id="L170">                <span class="tok-kw">return</span> self.rmw(.Min, value, ordering);</span>
<span class="line" id="L171">            }</span>
<span class="line" id="L172"></span>
<span class="line" id="L173">            <span class="tok-kw">pub</span> <span class="tok-kw">inline</span> <span class="tok-kw">fn</span> <span class="tok-fn">fetchMax</span>(self: *Self, value: T, <span class="tok-kw">comptime</span> ordering: Ordering) T {</span>
<span class="line" id="L174">                <span class="tok-kw">return</span> self.rmw(.Max, value, ordering);</span>
<span class="line" id="L175">            }</span>
<span class="line" id="L176">        });</span>
<span class="line" id="L177"></span>
<span class="line" id="L178">        <span class="tok-kw">pub</span> <span class="tok-kw">usingnamespace</span> exportWhen(std.meta.trait.isIntegral(T), <span class="tok-kw">struct</span> {</span>
<span class="line" id="L179">            <span class="tok-kw">pub</span> <span class="tok-kw">inline</span> <span class="tok-kw">fn</span> <span class="tok-fn">fetchAnd</span>(self: *Self, value: T, <span class="tok-kw">comptime</span> ordering: Ordering) T {</span>
<span class="line" id="L180">                <span class="tok-kw">return</span> self.rmw(.And, value, ordering);</span>
<span class="line" id="L181">            }</span>
<span class="line" id="L182"></span>
<span class="line" id="L183">            <span class="tok-kw">pub</span> <span class="tok-kw">inline</span> <span class="tok-kw">fn</span> <span class="tok-fn">fetchNand</span>(self: *Self, value: T, <span class="tok-kw">comptime</span> ordering: Ordering) T {</span>
<span class="line" id="L184">                <span class="tok-kw">return</span> self.rmw(.Nand, value, ordering);</span>
<span class="line" id="L185">            }</span>
<span class="line" id="L186"></span>
<span class="line" id="L187">            <span class="tok-kw">pub</span> <span class="tok-kw">inline</span> <span class="tok-kw">fn</span> <span class="tok-fn">fetchOr</span>(self: *Self, value: T, <span class="tok-kw">comptime</span> ordering: Ordering) T {</span>
<span class="line" id="L188">                <span class="tok-kw">return</span> self.rmw(.Or, value, ordering);</span>
<span class="line" id="L189">            }</span>
<span class="line" id="L190"></span>
<span class="line" id="L191">            <span class="tok-kw">pub</span> <span class="tok-kw">inline</span> <span class="tok-kw">fn</span> <span class="tok-fn">fetchXor</span>(self: *Self, value: T, <span class="tok-kw">comptime</span> ordering: Ordering) T {</span>
<span class="line" id="L192">                <span class="tok-kw">return</span> self.rmw(.Xor, value, ordering);</span>
<span class="line" id="L193">            }</span>
<span class="line" id="L194"></span>
<span class="line" id="L195">            <span class="tok-kw">const</span> Bit = std.math.Log2Int(T);</span>
<span class="line" id="L196">            <span class="tok-kw">const</span> BitRmwOp = <span class="tok-kw">enum</span> {</span>
<span class="line" id="L197">                Set,</span>
<span class="line" id="L198">                Reset,</span>
<span class="line" id="L199">                Toggle,</span>
<span class="line" id="L200">            };</span>
<span class="line" id="L201"></span>
<span class="line" id="L202">            <span class="tok-kw">pub</span> <span class="tok-kw">inline</span> <span class="tok-kw">fn</span> <span class="tok-fn">bitSet</span>(self: *Self, bit: Bit, <span class="tok-kw">comptime</span> ordering: Ordering) <span class="tok-type">u1</span> {</span>
<span class="line" id="L203">                <span class="tok-kw">return</span> bitRmw(self, .Set, bit, ordering);</span>
<span class="line" id="L204">            }</span>
<span class="line" id="L205"></span>
<span class="line" id="L206">            <span class="tok-kw">pub</span> <span class="tok-kw">inline</span> <span class="tok-kw">fn</span> <span class="tok-fn">bitReset</span>(self: *Self, bit: Bit, <span class="tok-kw">comptime</span> ordering: Ordering) <span class="tok-type">u1</span> {</span>
<span class="line" id="L207">                <span class="tok-kw">return</span> bitRmw(self, .Reset, bit, ordering);</span>
<span class="line" id="L208">            }</span>
<span class="line" id="L209"></span>
<span class="line" id="L210">            <span class="tok-kw">pub</span> <span class="tok-kw">inline</span> <span class="tok-kw">fn</span> <span class="tok-fn">bitToggle</span>(self: *Self, bit: Bit, <span class="tok-kw">comptime</span> ordering: Ordering) <span class="tok-type">u1</span> {</span>
<span class="line" id="L211">                <span class="tok-kw">return</span> bitRmw(self, .Toggle, bit, ordering);</span>
<span class="line" id="L212">            }</span>
<span class="line" id="L213"></span>
<span class="line" id="L214">            <span class="tok-kw">inline</span> <span class="tok-kw">fn</span> <span class="tok-fn">bitRmw</span>(self: *Self, <span class="tok-kw">comptime</span> op: BitRmwOp, bit: Bit, <span class="tok-kw">comptime</span> ordering: Ordering) <span class="tok-type">u1</span> {</span>
<span class="line" id="L215">                <span class="tok-comment">// x86 supports dedicated bitwise instructions</span>
</span>
<span class="line" id="L216">                <span class="tok-kw">if</span> (<span class="tok-kw">comptime</span> builtin.target.cpu.arch.isX86() <span class="tok-kw">and</span> <span class="tok-builtin">@sizeOf</span>(T) &gt;= <span class="tok-number">2</span> <span class="tok-kw">and</span> <span class="tok-builtin">@sizeOf</span>(T) &lt;= <span class="tok-number">8</span>) {</span>
<span class="line" id="L217">                    <span class="tok-comment">// TODO: stage2 currently doesn't like the inline asm this function emits.</span>
</span>
<span class="line" id="L218">                    <span class="tok-kw">if</span> (builtin.zig_backend == .stage1) {</span>
<span class="line" id="L219">                        <span class="tok-kw">return</span> x86BitRmw(self, op, bit, ordering);</span>
<span class="line" id="L220">                    }</span>
<span class="line" id="L221">                }</span>
<span class="line" id="L222"></span>
<span class="line" id="L223">                <span class="tok-kw">const</span> mask = <span class="tok-builtin">@as</span>(T, <span class="tok-number">1</span>) &lt;&lt; bit;</span>
<span class="line" id="L224">                <span class="tok-kw">const</span> value = <span class="tok-kw">switch</span> (op) {</span>
<span class="line" id="L225">                    .Set =&gt; self.fetchOr(mask, ordering),</span>
<span class="line" id="L226">                    .Reset =&gt; self.fetchAnd(~mask, ordering),</span>
<span class="line" id="L227">                    .Toggle =&gt; self.fetchXor(mask, ordering),</span>
<span class="line" id="L228">                };</span>
<span class="line" id="L229"></span>
<span class="line" id="L230">                <span class="tok-kw">return</span> <span class="tok-builtin">@boolToInt</span>(value &amp; mask != <span class="tok-number">0</span>);</span>
<span class="line" id="L231">            }</span>
<span class="line" id="L232"></span>
<span class="line" id="L233">            <span class="tok-kw">inline</span> <span class="tok-kw">fn</span> <span class="tok-fn">x86BitRmw</span>(self: *Self, <span class="tok-kw">comptime</span> op: BitRmwOp, bit: Bit, <span class="tok-kw">comptime</span> ordering: Ordering) <span class="tok-type">u1</span> {</span>
<span class="line" id="L234">                <span class="tok-kw">const</span> old_bit: <span class="tok-type">u8</span> = <span class="tok-kw">switch</span> (<span class="tok-builtin">@sizeOf</span>(T)) {</span>
<span class="line" id="L235">                    <span class="tok-number">2</span> =&gt; <span class="tok-kw">switch</span> (op) {</span>
<span class="line" id="L236">                        .Set =&gt; <span class="tok-kw">asm</span> <span class="tok-kw">volatile</span> (<span class="tok-str">&quot;lock btsw %[bit], %[ptr]&quot;</span></span>
<span class="line" id="L237">                            <span class="tok-comment">// LLVM doesn't support u1 flag register return values</span>
</span>
<span class="line" id="L238">                            : [result] <span class="tok-str">&quot;={@ccc}&quot;</span> (-&gt; <span class="tok-type">u8</span>),</span>
<span class="line" id="L239">                            : [ptr] <span class="tok-str">&quot;*m&quot;</span> (&amp;self.value),</span>
<span class="line" id="L240">                              [bit] <span class="tok-str">&quot;X&quot;</span> (<span class="tok-builtin">@as</span>(T, bit)),</span>
<span class="line" id="L241">                            : <span class="tok-str">&quot;cc&quot;</span>, <span class="tok-str">&quot;memory&quot;</span></span>
<span class="line" id="L242">                        ),</span>
<span class="line" id="L243">                        .Reset =&gt; <span class="tok-kw">asm</span> <span class="tok-kw">volatile</span> (<span class="tok-str">&quot;lock btrw %[bit], %[ptr]&quot;</span></span>
<span class="line" id="L244">                            <span class="tok-comment">// LLVM doesn't support u1 flag register return values</span>
</span>
<span class="line" id="L245">                            : [result] <span class="tok-str">&quot;={@ccc}&quot;</span> (-&gt; <span class="tok-type">u8</span>),</span>
<span class="line" id="L246">                            : [ptr] <span class="tok-str">&quot;*m&quot;</span> (&amp;self.value),</span>
<span class="line" id="L247">                              [bit] <span class="tok-str">&quot;X&quot;</span> (<span class="tok-builtin">@as</span>(T, bit)),</span>
<span class="line" id="L248">                            : <span class="tok-str">&quot;cc&quot;</span>, <span class="tok-str">&quot;memory&quot;</span></span>
<span class="line" id="L249">                        ),</span>
<span class="line" id="L250">                        .Toggle =&gt; <span class="tok-kw">asm</span> <span class="tok-kw">volatile</span> (<span class="tok-str">&quot;lock btcw %[bit], %[ptr]&quot;</span></span>
<span class="line" id="L251">                            <span class="tok-comment">// LLVM doesn't support u1 flag register return values</span>
</span>
<span class="line" id="L252">                            : [result] <span class="tok-str">&quot;={@ccc}&quot;</span> (-&gt; <span class="tok-type">u8</span>),</span>
<span class="line" id="L253">                            : [ptr] <span class="tok-str">&quot;*m&quot;</span> (&amp;self.value),</span>
<span class="line" id="L254">                              [bit] <span class="tok-str">&quot;X&quot;</span> (<span class="tok-builtin">@as</span>(T, bit)),</span>
<span class="line" id="L255">                            : <span class="tok-str">&quot;cc&quot;</span>, <span class="tok-str">&quot;memory&quot;</span></span>
<span class="line" id="L256">                        ),</span>
<span class="line" id="L257">                    },</span>
<span class="line" id="L258">                    <span class="tok-number">4</span> =&gt; <span class="tok-kw">switch</span> (op) {</span>
<span class="line" id="L259">                        .Set =&gt; <span class="tok-kw">asm</span> <span class="tok-kw">volatile</span> (<span class="tok-str">&quot;lock btsl %[bit], %[ptr]&quot;</span></span>
<span class="line" id="L260">                            <span class="tok-comment">// LLVM doesn't support u1 flag register return values</span>
</span>
<span class="line" id="L261">                            : [result] <span class="tok-str">&quot;={@ccc}&quot;</span> (-&gt; <span class="tok-type">u8</span>),</span>
<span class="line" id="L262">                            : [ptr] <span class="tok-str">&quot;*m&quot;</span> (&amp;self.value),</span>
<span class="line" id="L263">                              [bit] <span class="tok-str">&quot;X&quot;</span> (<span class="tok-builtin">@as</span>(T, bit)),</span>
<span class="line" id="L264">                            : <span class="tok-str">&quot;cc&quot;</span>, <span class="tok-str">&quot;memory&quot;</span></span>
<span class="line" id="L265">                        ),</span>
<span class="line" id="L266">                        .Reset =&gt; <span class="tok-kw">asm</span> <span class="tok-kw">volatile</span> (<span class="tok-str">&quot;lock btrl %[bit], %[ptr]&quot;</span></span>
<span class="line" id="L267">                            <span class="tok-comment">// LLVM doesn't support u1 flag register return values</span>
</span>
<span class="line" id="L268">                            : [result] <span class="tok-str">&quot;={@ccc}&quot;</span> (-&gt; <span class="tok-type">u8</span>),</span>
<span class="line" id="L269">                            : [ptr] <span class="tok-str">&quot;*m&quot;</span> (&amp;self.value),</span>
<span class="line" id="L270">                              [bit] <span class="tok-str">&quot;X&quot;</span> (<span class="tok-builtin">@as</span>(T, bit)),</span>
<span class="line" id="L271">                            : <span class="tok-str">&quot;cc&quot;</span>, <span class="tok-str">&quot;memory&quot;</span></span>
<span class="line" id="L272">                        ),</span>
<span class="line" id="L273">                        .Toggle =&gt; <span class="tok-kw">asm</span> <span class="tok-kw">volatile</span> (<span class="tok-str">&quot;lock btcl %[bit], %[ptr]&quot;</span></span>
<span class="line" id="L274">                            <span class="tok-comment">// LLVM doesn't support u1 flag register return values</span>
</span>
<span class="line" id="L275">                            : [result] <span class="tok-str">&quot;={@ccc}&quot;</span> (-&gt; <span class="tok-type">u8</span>),</span>
<span class="line" id="L276">                            : [ptr] <span class="tok-str">&quot;*m&quot;</span> (&amp;self.value),</span>
<span class="line" id="L277">                              [bit] <span class="tok-str">&quot;X&quot;</span> (<span class="tok-builtin">@as</span>(T, bit)),</span>
<span class="line" id="L278">                            : <span class="tok-str">&quot;cc&quot;</span>, <span class="tok-str">&quot;memory&quot;</span></span>
<span class="line" id="L279">                        ),</span>
<span class="line" id="L280">                    },</span>
<span class="line" id="L281">                    <span class="tok-number">8</span> =&gt; <span class="tok-kw">switch</span> (op) {</span>
<span class="line" id="L282">                        .Set =&gt; <span class="tok-kw">asm</span> <span class="tok-kw">volatile</span> (<span class="tok-str">&quot;lock btsq %[bit], %[ptr]&quot;</span></span>
<span class="line" id="L283">                            <span class="tok-comment">// LLVM doesn't support u1 flag register return values</span>
</span>
<span class="line" id="L284">                            : [result] <span class="tok-str">&quot;={@ccc}&quot;</span> (-&gt; <span class="tok-type">u8</span>),</span>
<span class="line" id="L285">                            : [ptr] <span class="tok-str">&quot;*m&quot;</span> (&amp;self.value),</span>
<span class="line" id="L286">                              [bit] <span class="tok-str">&quot;X&quot;</span> (<span class="tok-builtin">@as</span>(T, bit)),</span>
<span class="line" id="L287">                            : <span class="tok-str">&quot;cc&quot;</span>, <span class="tok-str">&quot;memory&quot;</span></span>
<span class="line" id="L288">                        ),</span>
<span class="line" id="L289">                        .Reset =&gt; <span class="tok-kw">asm</span> <span class="tok-kw">volatile</span> (<span class="tok-str">&quot;lock btrq %[bit], %[ptr]&quot;</span></span>
<span class="line" id="L290">                            <span class="tok-comment">// LLVM doesn't support u1 flag register return values</span>
</span>
<span class="line" id="L291">                            : [result] <span class="tok-str">&quot;={@ccc}&quot;</span> (-&gt; <span class="tok-type">u8</span>),</span>
<span class="line" id="L292">                            : [ptr] <span class="tok-str">&quot;*m&quot;</span> (&amp;self.value),</span>
<span class="line" id="L293">                              [bit] <span class="tok-str">&quot;X&quot;</span> (<span class="tok-builtin">@as</span>(T, bit)),</span>
<span class="line" id="L294">                            : <span class="tok-str">&quot;cc&quot;</span>, <span class="tok-str">&quot;memory&quot;</span></span>
<span class="line" id="L295">                        ),</span>
<span class="line" id="L296">                        .Toggle =&gt; <span class="tok-kw">asm</span> <span class="tok-kw">volatile</span> (<span class="tok-str">&quot;lock btcq %[bit], %[ptr]&quot;</span></span>
<span class="line" id="L297">                            <span class="tok-comment">// LLVM doesn't support u1 flag register return values</span>
</span>
<span class="line" id="L298">                            : [result] <span class="tok-str">&quot;={@ccc}&quot;</span> (-&gt; <span class="tok-type">u8</span>),</span>
<span class="line" id="L299">                            : [ptr] <span class="tok-str">&quot;*m&quot;</span> (&amp;self.value),</span>
<span class="line" id="L300">                              [bit] <span class="tok-str">&quot;X&quot;</span> (<span class="tok-builtin">@as</span>(T, bit)),</span>
<span class="line" id="L301">                            : <span class="tok-str">&quot;cc&quot;</span>, <span class="tok-str">&quot;memory&quot;</span></span>
<span class="line" id="L302">                        ),</span>
<span class="line" id="L303">                    },</span>
<span class="line" id="L304">                    <span class="tok-kw">else</span> =&gt; <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;Invalid atomic type &quot;</span> ++ <span class="tok-builtin">@typeName</span>(T)),</span>
<span class="line" id="L305">                };</span>
<span class="line" id="L306"></span>
<span class="line" id="L307">                <span class="tok-comment">// TODO: emit appropriate tsan fence if compiling with tsan</span>
</span>
<span class="line" id="L308">                _ = ordering;</span>
<span class="line" id="L309"></span>
<span class="line" id="L310">                <span class="tok-kw">return</span> <span class="tok-builtin">@intCast</span>(<span class="tok-type">u1</span>, old_bit);</span>
<span class="line" id="L311">            }</span>
<span class="line" id="L312">        });</span>
<span class="line" id="L313">    };</span>
<span class="line" id="L314">}</span>
<span class="line" id="L315"></span>
<span class="line" id="L316"><span class="tok-kw">test</span> <span class="tok-str">&quot;Atomic.fence&quot;</span> {</span>
<span class="line" id="L317">    <span class="tok-kw">inline</span> <span class="tok-kw">for</span> (.{ .Acquire, .Release, .AcqRel, .SeqCst }) |ordering| {</span>
<span class="line" id="L318">        <span class="tok-kw">var</span> x = Atomic(<span class="tok-type">usize</span>).init(<span class="tok-number">0</span>);</span>
<span class="line" id="L319">        x.fence(ordering);</span>
<span class="line" id="L320">    }</span>
<span class="line" id="L321">}</span>
<span class="line" id="L322"></span>
<span class="line" id="L323"><span class="tok-kw">fn</span> <span class="tok-fn">atomicIntTypes</span>() []<span class="tok-kw">const</span> <span class="tok-type">type</span> {</span>
<span class="line" id="L324">    <span class="tok-kw">comptime</span> <span class="tok-kw">var</span> bytes = <span class="tok-number">1</span>;</span>
<span class="line" id="L325">    <span class="tok-kw">comptime</span> <span class="tok-kw">var</span> types: []<span class="tok-kw">const</span> <span class="tok-type">type</span> = &amp;[_]<span class="tok-type">type</span>{};</span>
<span class="line" id="L326">    <span class="tok-kw">inline</span> <span class="tok-kw">while</span> (bytes &lt;= <span class="tok-builtin">@sizeOf</span>(<span class="tok-type">usize</span>)) : (bytes *= <span class="tok-number">2</span>) {</span>
<span class="line" id="L327">        types = types ++ &amp;[_]<span class="tok-type">type</span>{std.meta.Int(.unsigned, bytes * <span class="tok-number">8</span>)};</span>
<span class="line" id="L328">    }</span>
<span class="line" id="L329">    <span class="tok-kw">return</span> types;</span>
<span class="line" id="L330">}</span>
<span class="line" id="L331"></span>
<span class="line" id="L332"><span class="tok-kw">test</span> <span class="tok-str">&quot;Atomic.loadUnchecked&quot;</span> {</span>
<span class="line" id="L333">    <span class="tok-kw">inline</span> <span class="tok-kw">for</span> (atomicIntTypes()) |Int| {</span>
<span class="line" id="L334">        <span class="tok-kw">var</span> x = Atomic(Int).init(<span class="tok-number">5</span>);</span>
<span class="line" id="L335">        <span class="tok-kw">try</span> testing.expectEqual(x.loadUnchecked(), <span class="tok-number">5</span>);</span>
<span class="line" id="L336">    }</span>
<span class="line" id="L337">}</span>
<span class="line" id="L338"></span>
<span class="line" id="L339"><span class="tok-kw">test</span> <span class="tok-str">&quot;Atomic.storeUnchecked&quot;</span> {</span>
<span class="line" id="L340">    <span class="tok-kw">inline</span> <span class="tok-kw">for</span> (atomicIntTypes()) |Int| {</span>
<span class="line" id="L341">        _ = Int;</span>
<span class="line" id="L342">        <span class="tok-kw">var</span> x = Atomic(<span class="tok-type">usize</span>).init(<span class="tok-number">5</span>);</span>
<span class="line" id="L343">        x.storeUnchecked(<span class="tok-number">10</span>);</span>
<span class="line" id="L344">        <span class="tok-kw">try</span> testing.expectEqual(x.loadUnchecked(), <span class="tok-number">10</span>);</span>
<span class="line" id="L345">    }</span>
<span class="line" id="L346">}</span>
<span class="line" id="L347"></span>
<span class="line" id="L348"><span class="tok-kw">test</span> <span class="tok-str">&quot;Atomic.load&quot;</span> {</span>
<span class="line" id="L349">    <span class="tok-kw">inline</span> <span class="tok-kw">for</span> (atomicIntTypes()) |Int| {</span>
<span class="line" id="L350">        <span class="tok-kw">inline</span> <span class="tok-kw">for</span> (.{ .Unordered, .Monotonic, .Acquire, .SeqCst }) |ordering| {</span>
<span class="line" id="L351">            <span class="tok-kw">var</span> x = Atomic(Int).init(<span class="tok-number">5</span>);</span>
<span class="line" id="L352">            <span class="tok-kw">try</span> testing.expectEqual(x.load(ordering), <span class="tok-number">5</span>);</span>
<span class="line" id="L353">        }</span>
<span class="line" id="L354">    }</span>
<span class="line" id="L355">}</span>
<span class="line" id="L356"></span>
<span class="line" id="L357"><span class="tok-kw">test</span> <span class="tok-str">&quot;Atomic.store&quot;</span> {</span>
<span class="line" id="L358">    <span class="tok-kw">inline</span> <span class="tok-kw">for</span> (atomicIntTypes()) |Int| {</span>
<span class="line" id="L359">        <span class="tok-kw">inline</span> <span class="tok-kw">for</span> (.{ .Unordered, .Monotonic, .Release, .SeqCst }) |ordering| {</span>
<span class="line" id="L360">            _ = Int;</span>
<span class="line" id="L361">            <span class="tok-kw">var</span> x = Atomic(<span class="tok-type">usize</span>).init(<span class="tok-number">5</span>);</span>
<span class="line" id="L362">            x.store(<span class="tok-number">10</span>, ordering);</span>
<span class="line" id="L363">            <span class="tok-kw">try</span> testing.expectEqual(x.load(.SeqCst), <span class="tok-number">10</span>);</span>
<span class="line" id="L364">        }</span>
<span class="line" id="L365">    }</span>
<span class="line" id="L366">}</span>
<span class="line" id="L367"></span>
<span class="line" id="L368"><span class="tok-kw">const</span> atomic_rmw_orderings = [_]Ordering{</span>
<span class="line" id="L369">    .Monotonic,</span>
<span class="line" id="L370">    .Acquire,</span>
<span class="line" id="L371">    .Release,</span>
<span class="line" id="L372">    .AcqRel,</span>
<span class="line" id="L373">    .SeqCst,</span>
<span class="line" id="L374">};</span>
<span class="line" id="L375"></span>
<span class="line" id="L376"><span class="tok-kw">test</span> <span class="tok-str">&quot;Atomic.swap&quot;</span> {</span>
<span class="line" id="L377">    <span class="tok-kw">inline</span> <span class="tok-kw">for</span> (atomic_rmw_orderings) |ordering| {</span>
<span class="line" id="L378">        <span class="tok-kw">var</span> x = Atomic(<span class="tok-type">usize</span>).init(<span class="tok-number">5</span>);</span>
<span class="line" id="L379">        <span class="tok-kw">try</span> testing.expectEqual(x.swap(<span class="tok-number">10</span>, ordering), <span class="tok-number">5</span>);</span>
<span class="line" id="L380">        <span class="tok-kw">try</span> testing.expectEqual(x.load(.SeqCst), <span class="tok-number">10</span>);</span>
<span class="line" id="L381"></span>
<span class="line" id="L382">        <span class="tok-kw">var</span> y = Atomic(<span class="tok-kw">enum</span>(<span class="tok-type">usize</span>) { a, b, c }).init(.c);</span>
<span class="line" id="L383">        <span class="tok-kw">try</span> testing.expectEqual(y.swap(.a, ordering), .c);</span>
<span class="line" id="L384">        <span class="tok-kw">try</span> testing.expectEqual(y.load(.SeqCst), .a);</span>
<span class="line" id="L385"></span>
<span class="line" id="L386">        <span class="tok-kw">var</span> z = Atomic(<span class="tok-type">f32</span>).init(<span class="tok-number">5.0</span>);</span>
<span class="line" id="L387">        <span class="tok-kw">try</span> testing.expectEqual(z.swap(<span class="tok-number">10.0</span>, ordering), <span class="tok-number">5.0</span>);</span>
<span class="line" id="L388">        <span class="tok-kw">try</span> testing.expectEqual(z.load(.SeqCst), <span class="tok-number">10.0</span>);</span>
<span class="line" id="L389"></span>
<span class="line" id="L390">        <span class="tok-kw">var</span> a = Atomic(<span class="tok-type">bool</span>).init(<span class="tok-null">false</span>);</span>
<span class="line" id="L391">        <span class="tok-kw">try</span> testing.expectEqual(a.swap(<span class="tok-null">true</span>, ordering), <span class="tok-null">false</span>);</span>
<span class="line" id="L392">        <span class="tok-kw">try</span> testing.expectEqual(a.load(.SeqCst), <span class="tok-null">true</span>);</span>
<span class="line" id="L393"></span>
<span class="line" id="L394">        <span class="tok-kw">var</span> b = Atomic(?*<span class="tok-type">u8</span>).init(<span class="tok-null">null</span>);</span>
<span class="line" id="L395">        <span class="tok-kw">try</span> testing.expectEqual(b.swap(<span class="tok-builtin">@intToPtr</span>(?*<span class="tok-type">u8</span>, <span class="tok-builtin">@alignOf</span>(<span class="tok-type">u8</span>)), ordering), <span class="tok-null">null</span>);</span>
<span class="line" id="L396">        <span class="tok-kw">try</span> testing.expectEqual(b.load(.SeqCst), <span class="tok-builtin">@intToPtr</span>(?*<span class="tok-type">u8</span>, <span class="tok-builtin">@alignOf</span>(<span class="tok-type">u8</span>)));</span>
<span class="line" id="L397">    }</span>
<span class="line" id="L398">}</span>
<span class="line" id="L399"></span>
<span class="line" id="L400"><span class="tok-kw">const</span> atomic_cmpxchg_orderings = [_][<span class="tok-number">2</span>]Ordering{</span>
<span class="line" id="L401">    .{ .Monotonic, .Monotonic },</span>
<span class="line" id="L402">    .{ .Acquire, .Monotonic },</span>
<span class="line" id="L403">    .{ .Acquire, .Acquire },</span>
<span class="line" id="L404">    .{ .Release, .Monotonic },</span>
<span class="line" id="L405">    <span class="tok-comment">// Although accepted by LLVM, acquire failure implies AcqRel success</span>
</span>
<span class="line" id="L406">    <span class="tok-comment">// .{ .Release, .Acquire },</span>
</span>
<span class="line" id="L407">    .{ .AcqRel, .Monotonic },</span>
<span class="line" id="L408">    .{ .AcqRel, .Acquire },</span>
<span class="line" id="L409">    .{ .SeqCst, .Monotonic },</span>
<span class="line" id="L410">    .{ .SeqCst, .Acquire },</span>
<span class="line" id="L411">    .{ .SeqCst, .SeqCst },</span>
<span class="line" id="L412">};</span>
<span class="line" id="L413"></span>
<span class="line" id="L414"><span class="tok-kw">test</span> <span class="tok-str">&quot;Atomic.compareAndSwap&quot;</span> {</span>
<span class="line" id="L415">    <span class="tok-kw">inline</span> <span class="tok-kw">for</span> (atomicIntTypes()) |Int| {</span>
<span class="line" id="L416">        <span class="tok-kw">inline</span> <span class="tok-kw">for</span> (atomic_cmpxchg_orderings) |ordering| {</span>
<span class="line" id="L417">            <span class="tok-kw">var</span> x = Atomic(Int).init(<span class="tok-number">0</span>);</span>
<span class="line" id="L418">            <span class="tok-kw">try</span> testing.expectEqual(x.compareAndSwap(<span class="tok-number">1</span>, <span class="tok-number">0</span>, ordering[<span class="tok-number">0</span>], ordering[<span class="tok-number">1</span>]), <span class="tok-number">0</span>);</span>
<span class="line" id="L419">            <span class="tok-kw">try</span> testing.expectEqual(x.load(.SeqCst), <span class="tok-number">0</span>);</span>
<span class="line" id="L420">            <span class="tok-kw">try</span> testing.expectEqual(x.compareAndSwap(<span class="tok-number">0</span>, <span class="tok-number">1</span>, ordering[<span class="tok-number">0</span>], ordering[<span class="tok-number">1</span>]), <span class="tok-null">null</span>);</span>
<span class="line" id="L421">            <span class="tok-kw">try</span> testing.expectEqual(x.load(.SeqCst), <span class="tok-number">1</span>);</span>
<span class="line" id="L422">            <span class="tok-kw">try</span> testing.expectEqual(x.compareAndSwap(<span class="tok-number">1</span>, <span class="tok-number">0</span>, ordering[<span class="tok-number">0</span>], ordering[<span class="tok-number">1</span>]), <span class="tok-null">null</span>);</span>
<span class="line" id="L423">            <span class="tok-kw">try</span> testing.expectEqual(x.load(.SeqCst), <span class="tok-number">0</span>);</span>
<span class="line" id="L424">        }</span>
<span class="line" id="L425">    }</span>
<span class="line" id="L426">}</span>
<span class="line" id="L427"></span>
<span class="line" id="L428"><span class="tok-kw">test</span> <span class="tok-str">&quot;Atomic.tryCompareAndSwap&quot;</span> {</span>
<span class="line" id="L429">    <span class="tok-kw">inline</span> <span class="tok-kw">for</span> (atomicIntTypes()) |Int| {</span>
<span class="line" id="L430">        <span class="tok-kw">inline</span> <span class="tok-kw">for</span> (atomic_cmpxchg_orderings) |ordering| {</span>
<span class="line" id="L431">            <span class="tok-kw">var</span> x = Atomic(Int).init(<span class="tok-number">0</span>);</span>
<span class="line" id="L432"></span>
<span class="line" id="L433">            <span class="tok-kw">try</span> testing.expectEqual(x.tryCompareAndSwap(<span class="tok-number">1</span>, <span class="tok-number">0</span>, ordering[<span class="tok-number">0</span>], ordering[<span class="tok-number">1</span>]), <span class="tok-number">0</span>);</span>
<span class="line" id="L434">            <span class="tok-kw">try</span> testing.expectEqual(x.load(.SeqCst), <span class="tok-number">0</span>);</span>
<span class="line" id="L435"></span>
<span class="line" id="L436">            <span class="tok-kw">while</span> (x.tryCompareAndSwap(<span class="tok-number">0</span>, <span class="tok-number">1</span>, ordering[<span class="tok-number">0</span>], ordering[<span class="tok-number">1</span>])) |_| {}</span>
<span class="line" id="L437">            <span class="tok-kw">try</span> testing.expectEqual(x.load(.SeqCst), <span class="tok-number">1</span>);</span>
<span class="line" id="L438"></span>
<span class="line" id="L439">            <span class="tok-kw">while</span> (x.tryCompareAndSwap(<span class="tok-number">1</span>, <span class="tok-number">0</span>, ordering[<span class="tok-number">0</span>], ordering[<span class="tok-number">1</span>])) |_| {}</span>
<span class="line" id="L440">            <span class="tok-kw">try</span> testing.expectEqual(x.load(.SeqCst), <span class="tok-number">0</span>);</span>
<span class="line" id="L441">        }</span>
<span class="line" id="L442">    }</span>
<span class="line" id="L443">}</span>
<span class="line" id="L444"></span>
<span class="line" id="L445"><span class="tok-kw">test</span> <span class="tok-str">&quot;Atomic.fetchAdd&quot;</span> {</span>
<span class="line" id="L446">    <span class="tok-kw">inline</span> <span class="tok-kw">for</span> (atomicIntTypes()) |Int| {</span>
<span class="line" id="L447">        <span class="tok-kw">inline</span> <span class="tok-kw">for</span> (atomic_rmw_orderings) |ordering| {</span>
<span class="line" id="L448">            <span class="tok-kw">var</span> x = Atomic(Int).init(<span class="tok-number">5</span>);</span>
<span class="line" id="L449">            <span class="tok-kw">try</span> testing.expectEqual(x.fetchAdd(<span class="tok-number">5</span>, ordering), <span class="tok-number">5</span>);</span>
<span class="line" id="L450">            <span class="tok-kw">try</span> testing.expectEqual(x.load(.SeqCst), <span class="tok-number">10</span>);</span>
<span class="line" id="L451">            <span class="tok-kw">try</span> testing.expectEqual(x.fetchAdd(std.math.maxInt(Int), ordering), <span class="tok-number">10</span>);</span>
<span class="line" id="L452">            <span class="tok-kw">try</span> testing.expectEqual(x.load(.SeqCst), <span class="tok-number">9</span>);</span>
<span class="line" id="L453">        }</span>
<span class="line" id="L454">    }</span>
<span class="line" id="L455">}</span>
<span class="line" id="L456"></span>
<span class="line" id="L457"><span class="tok-kw">test</span> <span class="tok-str">&quot;Atomic.fetchSub&quot;</span> {</span>
<span class="line" id="L458">    <span class="tok-kw">inline</span> <span class="tok-kw">for</span> (atomicIntTypes()) |Int| {</span>
<span class="line" id="L459">        <span class="tok-kw">inline</span> <span class="tok-kw">for</span> (atomic_rmw_orderings) |ordering| {</span>
<span class="line" id="L460">            <span class="tok-kw">var</span> x = Atomic(Int).init(<span class="tok-number">5</span>);</span>
<span class="line" id="L461">            <span class="tok-kw">try</span> testing.expectEqual(x.fetchSub(<span class="tok-number">5</span>, ordering), <span class="tok-number">5</span>);</span>
<span class="line" id="L462">            <span class="tok-kw">try</span> testing.expectEqual(x.load(.SeqCst), <span class="tok-number">0</span>);</span>
<span class="line" id="L463">            <span class="tok-kw">try</span> testing.expectEqual(x.fetchSub(<span class="tok-number">1</span>, ordering), <span class="tok-number">0</span>);</span>
<span class="line" id="L464">            <span class="tok-kw">try</span> testing.expectEqual(x.load(.SeqCst), std.math.maxInt(Int));</span>
<span class="line" id="L465">        }</span>
<span class="line" id="L466">    }</span>
<span class="line" id="L467">}</span>
<span class="line" id="L468"></span>
<span class="line" id="L469"><span class="tok-kw">test</span> <span class="tok-str">&quot;Atomic.fetchMin&quot;</span> {</span>
<span class="line" id="L470">    <span class="tok-kw">inline</span> <span class="tok-kw">for</span> (atomicIntTypes()) |Int| {</span>
<span class="line" id="L471">        <span class="tok-kw">inline</span> <span class="tok-kw">for</span> (atomic_rmw_orderings) |ordering| {</span>
<span class="line" id="L472">            <span class="tok-kw">var</span> x = Atomic(Int).init(<span class="tok-number">5</span>);</span>
<span class="line" id="L473">            <span class="tok-kw">try</span> testing.expectEqual(x.fetchMin(<span class="tok-number">0</span>, ordering), <span class="tok-number">5</span>);</span>
<span class="line" id="L474">            <span class="tok-kw">try</span> testing.expectEqual(x.load(.SeqCst), <span class="tok-number">0</span>);</span>
<span class="line" id="L475">            <span class="tok-kw">try</span> testing.expectEqual(x.fetchMin(<span class="tok-number">10</span>, ordering), <span class="tok-number">0</span>);</span>
<span class="line" id="L476">            <span class="tok-kw">try</span> testing.expectEqual(x.load(.SeqCst), <span class="tok-number">0</span>);</span>
<span class="line" id="L477">        }</span>
<span class="line" id="L478">    }</span>
<span class="line" id="L479">}</span>
<span class="line" id="L480"></span>
<span class="line" id="L481"><span class="tok-kw">test</span> <span class="tok-str">&quot;Atomic.fetchMax&quot;</span> {</span>
<span class="line" id="L482">    <span class="tok-kw">inline</span> <span class="tok-kw">for</span> (atomicIntTypes()) |Int| {</span>
<span class="line" id="L483">        <span class="tok-kw">inline</span> <span class="tok-kw">for</span> (atomic_rmw_orderings) |ordering| {</span>
<span class="line" id="L484">            <span class="tok-kw">var</span> x = Atomic(Int).init(<span class="tok-number">5</span>);</span>
<span class="line" id="L485">            <span class="tok-kw">try</span> testing.expectEqual(x.fetchMax(<span class="tok-number">10</span>, ordering), <span class="tok-number">5</span>);</span>
<span class="line" id="L486">            <span class="tok-kw">try</span> testing.expectEqual(x.load(.SeqCst), <span class="tok-number">10</span>);</span>
<span class="line" id="L487">            <span class="tok-kw">try</span> testing.expectEqual(x.fetchMax(<span class="tok-number">5</span>, ordering), <span class="tok-number">10</span>);</span>
<span class="line" id="L488">            <span class="tok-kw">try</span> testing.expectEqual(x.load(.SeqCst), <span class="tok-number">10</span>);</span>
<span class="line" id="L489">        }</span>
<span class="line" id="L490">    }</span>
<span class="line" id="L491">}</span>
<span class="line" id="L492"></span>
<span class="line" id="L493"><span class="tok-kw">test</span> <span class="tok-str">&quot;Atomic.fetchAnd&quot;</span> {</span>
<span class="line" id="L494">    <span class="tok-kw">inline</span> <span class="tok-kw">for</span> (atomicIntTypes()) |Int| {</span>
<span class="line" id="L495">        <span class="tok-kw">inline</span> <span class="tok-kw">for</span> (atomic_rmw_orderings) |ordering| {</span>
<span class="line" id="L496">            <span class="tok-kw">var</span> x = Atomic(Int).init(<span class="tok-number">0b11</span>);</span>
<span class="line" id="L497">            <span class="tok-kw">try</span> testing.expectEqual(x.fetchAnd(<span class="tok-number">0b10</span>, ordering), <span class="tok-number">0b11</span>);</span>
<span class="line" id="L498">            <span class="tok-kw">try</span> testing.expectEqual(x.load(.SeqCst), <span class="tok-number">0b10</span>);</span>
<span class="line" id="L499">            <span class="tok-kw">try</span> testing.expectEqual(x.fetchAnd(<span class="tok-number">0b00</span>, ordering), <span class="tok-number">0b10</span>);</span>
<span class="line" id="L500">            <span class="tok-kw">try</span> testing.expectEqual(x.load(.SeqCst), <span class="tok-number">0b00</span>);</span>
<span class="line" id="L501">        }</span>
<span class="line" id="L502">    }</span>
<span class="line" id="L503">}</span>
<span class="line" id="L504"></span>
<span class="line" id="L505"><span class="tok-kw">test</span> <span class="tok-str">&quot;Atomic.fetchNand&quot;</span> {</span>
<span class="line" id="L506">    <span class="tok-kw">inline</span> <span class="tok-kw">for</span> (atomicIntTypes()) |Int| {</span>
<span class="line" id="L507">        <span class="tok-kw">inline</span> <span class="tok-kw">for</span> (atomic_rmw_orderings) |ordering| {</span>
<span class="line" id="L508">            <span class="tok-kw">var</span> x = Atomic(Int).init(<span class="tok-number">0b11</span>);</span>
<span class="line" id="L509">            <span class="tok-kw">try</span> testing.expectEqual(x.fetchNand(<span class="tok-number">0b10</span>, ordering), <span class="tok-number">0b11</span>);</span>
<span class="line" id="L510">            <span class="tok-kw">try</span> testing.expectEqual(x.load(.SeqCst), ~<span class="tok-builtin">@as</span>(Int, <span class="tok-number">0b10</span>));</span>
<span class="line" id="L511">            <span class="tok-kw">try</span> testing.expectEqual(x.fetchNand(<span class="tok-number">0b00</span>, ordering), ~<span class="tok-builtin">@as</span>(Int, <span class="tok-number">0b10</span>));</span>
<span class="line" id="L512">            <span class="tok-kw">try</span> testing.expectEqual(x.load(.SeqCst), ~<span class="tok-builtin">@as</span>(Int, <span class="tok-number">0b00</span>));</span>
<span class="line" id="L513">        }</span>
<span class="line" id="L514">    }</span>
<span class="line" id="L515">}</span>
<span class="line" id="L516"></span>
<span class="line" id="L517"><span class="tok-kw">test</span> <span class="tok-str">&quot;Atomic.fetchOr&quot;</span> {</span>
<span class="line" id="L518">    <span class="tok-kw">inline</span> <span class="tok-kw">for</span> (atomicIntTypes()) |Int| {</span>
<span class="line" id="L519">        <span class="tok-kw">inline</span> <span class="tok-kw">for</span> (atomic_rmw_orderings) |ordering| {</span>
<span class="line" id="L520">            <span class="tok-kw">var</span> x = Atomic(Int).init(<span class="tok-number">0b11</span>);</span>
<span class="line" id="L521">            <span class="tok-kw">try</span> testing.expectEqual(x.fetchOr(<span class="tok-number">0b100</span>, ordering), <span class="tok-number">0b11</span>);</span>
<span class="line" id="L522">            <span class="tok-kw">try</span> testing.expectEqual(x.load(.SeqCst), <span class="tok-number">0b111</span>);</span>
<span class="line" id="L523">            <span class="tok-kw">try</span> testing.expectEqual(x.fetchOr(<span class="tok-number">0b010</span>, ordering), <span class="tok-number">0b111</span>);</span>
<span class="line" id="L524">            <span class="tok-kw">try</span> testing.expectEqual(x.load(.SeqCst), <span class="tok-number">0b111</span>);</span>
<span class="line" id="L525">        }</span>
<span class="line" id="L526">    }</span>
<span class="line" id="L527">}</span>
<span class="line" id="L528"></span>
<span class="line" id="L529"><span class="tok-kw">test</span> <span class="tok-str">&quot;Atomic.fetchXor&quot;</span> {</span>
<span class="line" id="L530">    <span class="tok-kw">inline</span> <span class="tok-kw">for</span> (atomicIntTypes()) |Int| {</span>
<span class="line" id="L531">        <span class="tok-kw">inline</span> <span class="tok-kw">for</span> (atomic_rmw_orderings) |ordering| {</span>
<span class="line" id="L532">            <span class="tok-kw">var</span> x = Atomic(Int).init(<span class="tok-number">0b11</span>);</span>
<span class="line" id="L533">            <span class="tok-kw">try</span> testing.expectEqual(x.fetchXor(<span class="tok-number">0b10</span>, ordering), <span class="tok-number">0b11</span>);</span>
<span class="line" id="L534">            <span class="tok-kw">try</span> testing.expectEqual(x.load(.SeqCst), <span class="tok-number">0b01</span>);</span>
<span class="line" id="L535">            <span class="tok-kw">try</span> testing.expectEqual(x.fetchXor(<span class="tok-number">0b01</span>, ordering), <span class="tok-number">0b01</span>);</span>
<span class="line" id="L536">            <span class="tok-kw">try</span> testing.expectEqual(x.load(.SeqCst), <span class="tok-number">0b00</span>);</span>
<span class="line" id="L537">        }</span>
<span class="line" id="L538">    }</span>
<span class="line" id="L539">}</span>
<span class="line" id="L540"></span>
<span class="line" id="L541"><span class="tok-kw">test</span> <span class="tok-str">&quot;Atomic.bitSet&quot;</span> {</span>
<span class="line" id="L542">    <span class="tok-kw">inline</span> <span class="tok-kw">for</span> (atomicIntTypes()) |Int| {</span>
<span class="line" id="L543">        <span class="tok-kw">inline</span> <span class="tok-kw">for</span> (atomic_rmw_orderings) |ordering| {</span>
<span class="line" id="L544">            <span class="tok-kw">var</span> x = Atomic(Int).init(<span class="tok-number">0</span>);</span>
<span class="line" id="L545">            <span class="tok-kw">const</span> bit_array = <span class="tok-builtin">@as</span>([<span class="tok-builtin">@bitSizeOf</span>(Int)]<span class="tok-type">void</span>, <span class="tok-null">undefined</span>);</span>
<span class="line" id="L546"></span>
<span class="line" id="L547">            <span class="tok-kw">for</span> (bit_array) |_, bit_index| {</span>
<span class="line" id="L548">                <span class="tok-kw">const</span> bit = <span class="tok-builtin">@intCast</span>(std.math.Log2Int(Int), bit_index);</span>
<span class="line" id="L549">                <span class="tok-kw">const</span> mask = <span class="tok-builtin">@as</span>(Int, <span class="tok-number">1</span>) &lt;&lt; bit;</span>
<span class="line" id="L550"></span>
<span class="line" id="L551">                <span class="tok-comment">// setting the bit should change the bit</span>
</span>
<span class="line" id="L552">                <span class="tok-kw">try</span> testing.expect(x.load(.SeqCst) &amp; mask == <span class="tok-number">0</span>);</span>
<span class="line" id="L553">                <span class="tok-kw">try</span> testing.expectEqual(x.bitSet(bit, ordering), <span class="tok-number">0</span>);</span>
<span class="line" id="L554">                <span class="tok-kw">try</span> testing.expect(x.load(.SeqCst) &amp; mask != <span class="tok-number">0</span>);</span>
<span class="line" id="L555"></span>
<span class="line" id="L556">                <span class="tok-comment">// setting it again shouldn't change the bit</span>
</span>
<span class="line" id="L557">                <span class="tok-kw">try</span> testing.expectEqual(x.bitSet(bit, ordering), <span class="tok-number">1</span>);</span>
<span class="line" id="L558">                <span class="tok-kw">try</span> testing.expect(x.load(.SeqCst) &amp; mask != <span class="tok-number">0</span>);</span>
<span class="line" id="L559"></span>
<span class="line" id="L560">                <span class="tok-comment">// all the previous bits should have not changed (still be set)</span>
</span>
<span class="line" id="L561">                <span class="tok-kw">for</span> (bit_array[<span class="tok-number">0</span>..bit_index]) |_, prev_bit_index| {</span>
<span class="line" id="L562">                    <span class="tok-kw">const</span> prev_bit = <span class="tok-builtin">@intCast</span>(std.math.Log2Int(Int), prev_bit_index);</span>
<span class="line" id="L563">                    <span class="tok-kw">const</span> prev_mask = <span class="tok-builtin">@as</span>(Int, <span class="tok-number">1</span>) &lt;&lt; prev_bit;</span>
<span class="line" id="L564">                    <span class="tok-kw">try</span> testing.expect(x.load(.SeqCst) &amp; prev_mask != <span class="tok-number">0</span>);</span>
<span class="line" id="L565">                }</span>
<span class="line" id="L566">            }</span>
<span class="line" id="L567">        }</span>
<span class="line" id="L568">    }</span>
<span class="line" id="L569">}</span>
<span class="line" id="L570"></span>
<span class="line" id="L571"><span class="tok-kw">test</span> <span class="tok-str">&quot;Atomic.bitReset&quot;</span> {</span>
<span class="line" id="L572">    <span class="tok-kw">inline</span> <span class="tok-kw">for</span> (atomicIntTypes()) |Int| {</span>
<span class="line" id="L573">        <span class="tok-kw">inline</span> <span class="tok-kw">for</span> (atomic_rmw_orderings) |ordering| {</span>
<span class="line" id="L574">            <span class="tok-kw">var</span> x = Atomic(Int).init(<span class="tok-number">0</span>);</span>
<span class="line" id="L575">            <span class="tok-kw">const</span> bit_array = <span class="tok-builtin">@as</span>([<span class="tok-builtin">@bitSizeOf</span>(Int)]<span class="tok-type">void</span>, <span class="tok-null">undefined</span>);</span>
<span class="line" id="L576"></span>
<span class="line" id="L577">            <span class="tok-kw">for</span> (bit_array) |_, bit_index| {</span>
<span class="line" id="L578">                <span class="tok-kw">const</span> bit = <span class="tok-builtin">@intCast</span>(std.math.Log2Int(Int), bit_index);</span>
<span class="line" id="L579">                <span class="tok-kw">const</span> mask = <span class="tok-builtin">@as</span>(Int, <span class="tok-number">1</span>) &lt;&lt; bit;</span>
<span class="line" id="L580">                x.storeUnchecked(x.loadUnchecked() | mask);</span>
<span class="line" id="L581"></span>
<span class="line" id="L582">                <span class="tok-comment">// unsetting the bit should change the bit</span>
</span>
<span class="line" id="L583">                <span class="tok-kw">try</span> testing.expect(x.load(.SeqCst) &amp; mask != <span class="tok-number">0</span>);</span>
<span class="line" id="L584">                <span class="tok-kw">try</span> testing.expectEqual(x.bitReset(bit, ordering), <span class="tok-number">1</span>);</span>
<span class="line" id="L585">                <span class="tok-kw">try</span> testing.expect(x.load(.SeqCst) &amp; mask == <span class="tok-number">0</span>);</span>
<span class="line" id="L586"></span>
<span class="line" id="L587">                <span class="tok-comment">// unsetting it again shouldn't change the bit</span>
</span>
<span class="line" id="L588">                <span class="tok-kw">try</span> testing.expectEqual(x.bitReset(bit, ordering), <span class="tok-number">0</span>);</span>
<span class="line" id="L589">                <span class="tok-kw">try</span> testing.expect(x.load(.SeqCst) &amp; mask == <span class="tok-number">0</span>);</span>
<span class="line" id="L590"></span>
<span class="line" id="L591">                <span class="tok-comment">// all the previous bits should have not changed (still be reset)</span>
</span>
<span class="line" id="L592">                <span class="tok-kw">for</span> (bit_array[<span class="tok-number">0</span>..bit_index]) |_, prev_bit_index| {</span>
<span class="line" id="L593">                    <span class="tok-kw">const</span> prev_bit = <span class="tok-builtin">@intCast</span>(std.math.Log2Int(Int), prev_bit_index);</span>
<span class="line" id="L594">                    <span class="tok-kw">const</span> prev_mask = <span class="tok-builtin">@as</span>(Int, <span class="tok-number">1</span>) &lt;&lt; prev_bit;</span>
<span class="line" id="L595">                    <span class="tok-kw">try</span> testing.expect(x.load(.SeqCst) &amp; prev_mask == <span class="tok-number">0</span>);</span>
<span class="line" id="L596">                }</span>
<span class="line" id="L597">            }</span>
<span class="line" id="L598">        }</span>
<span class="line" id="L599">    }</span>
<span class="line" id="L600">}</span>
<span class="line" id="L601"></span>
<span class="line" id="L602"><span class="tok-kw">test</span> <span class="tok-str">&quot;Atomic.bitToggle&quot;</span> {</span>
<span class="line" id="L603">    <span class="tok-kw">inline</span> <span class="tok-kw">for</span> (atomicIntTypes()) |Int| {</span>
<span class="line" id="L604">        <span class="tok-kw">inline</span> <span class="tok-kw">for</span> (atomic_rmw_orderings) |ordering| {</span>
<span class="line" id="L605">            <span class="tok-kw">var</span> x = Atomic(Int).init(<span class="tok-number">0</span>);</span>
<span class="line" id="L606">            <span class="tok-kw">const</span> bit_array = <span class="tok-builtin">@as</span>([<span class="tok-builtin">@bitSizeOf</span>(Int)]<span class="tok-type">void</span>, <span class="tok-null">undefined</span>);</span>
<span class="line" id="L607"></span>
<span class="line" id="L608">            <span class="tok-kw">for</span> (bit_array) |_, bit_index| {</span>
<span class="line" id="L609">                <span class="tok-kw">const</span> bit = <span class="tok-builtin">@intCast</span>(std.math.Log2Int(Int), bit_index);</span>
<span class="line" id="L610">                <span class="tok-kw">const</span> mask = <span class="tok-builtin">@as</span>(Int, <span class="tok-number">1</span>) &lt;&lt; bit;</span>
<span class="line" id="L611"></span>
<span class="line" id="L612">                <span class="tok-comment">// toggling the bit should change the bit</span>
</span>
<span class="line" id="L613">                <span class="tok-kw">try</span> testing.expect(x.load(.SeqCst) &amp; mask == <span class="tok-number">0</span>);</span>
<span class="line" id="L614">                <span class="tok-kw">try</span> testing.expectEqual(x.bitToggle(bit, ordering), <span class="tok-number">0</span>);</span>
<span class="line" id="L615">                <span class="tok-kw">try</span> testing.expect(x.load(.SeqCst) &amp; mask != <span class="tok-number">0</span>);</span>
<span class="line" id="L616"></span>
<span class="line" id="L617">                <span class="tok-comment">// toggling it again *should* change the bit</span>
</span>
<span class="line" id="L618">                <span class="tok-kw">try</span> testing.expectEqual(x.bitToggle(bit, ordering), <span class="tok-number">1</span>);</span>
<span class="line" id="L619">                <span class="tok-kw">try</span> testing.expect(x.load(.SeqCst) &amp; mask == <span class="tok-number">0</span>);</span>
<span class="line" id="L620"></span>
<span class="line" id="L621">                <span class="tok-comment">// all the previous bits should have not changed (still be toggled back)</span>
</span>
<span class="line" id="L622">                <span class="tok-kw">for</span> (bit_array[<span class="tok-number">0</span>..bit_index]) |_, prev_bit_index| {</span>
<span class="line" id="L623">                    <span class="tok-kw">const</span> prev_bit = <span class="tok-builtin">@intCast</span>(std.math.Log2Int(Int), prev_bit_index);</span>
<span class="line" id="L624">                    <span class="tok-kw">const</span> prev_mask = <span class="tok-builtin">@as</span>(Int, <span class="tok-number">1</span>) &lt;&lt; prev_bit;</span>
<span class="line" id="L625">                    <span class="tok-kw">try</span> testing.expect(x.load(.SeqCst) &amp; prev_mask == <span class="tok-number">0</span>);</span>
<span class="line" id="L626">                }</span>
<span class="line" id="L627">            }</span>
<span class="line" id="L628">        }</span>
<span class="line" id="L629">    }</span>
<span class="line" id="L630">}</span>
<span class="line" id="L631"></span>
</code></pre></body>
</html>