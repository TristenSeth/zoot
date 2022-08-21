<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">    <title>event/lock.zig - source view</title>
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
<span class="line" id="L3"><span class="tok-kw">const</span> assert = std.debug.assert;</span>
<span class="line" id="L4"><span class="tok-kw">const</span> testing = std.testing;</span>
<span class="line" id="L5"><span class="tok-kw">const</span> mem = std.mem;</span>
<span class="line" id="L6"><span class="tok-kw">const</span> Loop = std.event.Loop;</span>
<span class="line" id="L7"></span>
<span class="line" id="L8"><span class="tok-comment">/// Thread-safe async/await lock.</span></span>
<span class="line" id="L9"><span class="tok-comment">/// Functions which are waiting for the lock are suspended, and</span></span>
<span class="line" id="L10"><span class="tok-comment">/// are resumed when the lock is released, in order.</span></span>
<span class="line" id="L11"><span class="tok-comment">/// Allows only one actor to hold the lock.</span></span>
<span class="line" id="L12"><span class="tok-comment">/// TODO: make this API also work in blocking I/O mode.</span></span>
<span class="line" id="L13"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> Lock = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L14">    mutex: std.Thread.Mutex = std.Thread.Mutex{},</span>
<span class="line" id="L15">    head: <span class="tok-type">usize</span> = UNLOCKED,</span>
<span class="line" id="L16"></span>
<span class="line" id="L17">    <span class="tok-kw">const</span> UNLOCKED = <span class="tok-number">0</span>;</span>
<span class="line" id="L18">    <span class="tok-kw">const</span> LOCKED = <span class="tok-number">1</span>;</span>
<span class="line" id="L19"></span>
<span class="line" id="L20">    <span class="tok-kw">const</span> global_event_loop = Loop.instance <span class="tok-kw">orelse</span></span>
<span class="line" id="L21">        <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;std.event.Lock currently only works with event-based I/O&quot;</span>);</span>
<span class="line" id="L22"></span>
<span class="line" id="L23">    <span class="tok-kw">const</span> Waiter = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L24">        <span class="tok-comment">// forced Waiter alignment to ensure it doesn't clash with LOCKED</span>
</span>
<span class="line" id="L25">        next: ?*Waiter <span class="tok-kw">align</span>(<span class="tok-number">2</span>),</span>
<span class="line" id="L26">        tail: *Waiter,</span>
<span class="line" id="L27">        node: Loop.NextTickNode,</span>
<span class="line" id="L28">    };</span>
<span class="line" id="L29"></span>
<span class="line" id="L30">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">initLocked</span>() Lock {</span>
<span class="line" id="L31">        <span class="tok-kw">return</span> Lock{ .head = LOCKED };</span>
<span class="line" id="L32">    }</span>
<span class="line" id="L33"></span>
<span class="line" id="L34">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">acquire</span>(self: *Lock) Held {</span>
<span class="line" id="L35">        self.mutex.lock();</span>
<span class="line" id="L36"></span>
<span class="line" id="L37">        <span class="tok-comment">// self.head transitions from multiple stages depending on the value:</span>
</span>
<span class="line" id="L38">        <span class="tok-comment">// UNLOCKED -&gt; LOCKED:</span>
</span>
<span class="line" id="L39">        <span class="tok-comment">//   acquire Lock ownership when theres no waiters</span>
</span>
<span class="line" id="L40">        <span class="tok-comment">// LOCKED -&gt; &lt;Waiter head ptr&gt;:</span>
</span>
<span class="line" id="L41">        <span class="tok-comment">//   Lock is already owned, enqueue first Waiter</span>
</span>
<span class="line" id="L42">        <span class="tok-comment">// &lt;head ptr&gt; -&gt; &lt;head ptr&gt;:</span>
</span>
<span class="line" id="L43">        <span class="tok-comment">//   Lock is owned with pending waiters. Push our waiter to the queue.</span>
</span>
<span class="line" id="L44"></span>
<span class="line" id="L45">        <span class="tok-kw">if</span> (self.head == UNLOCKED) {</span>
<span class="line" id="L46">            self.head = LOCKED;</span>
<span class="line" id="L47">            self.mutex.unlock();</span>
<span class="line" id="L48">            <span class="tok-kw">return</span> Held{ .lock = self };</span>
<span class="line" id="L49">        }</span>
<span class="line" id="L50"></span>
<span class="line" id="L51">        <span class="tok-kw">var</span> waiter: Waiter = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L52">        waiter.next = <span class="tok-null">null</span>;</span>
<span class="line" id="L53">        waiter.tail = &amp;waiter;</span>
<span class="line" id="L54"></span>
<span class="line" id="L55">        <span class="tok-kw">const</span> head = <span class="tok-kw">switch</span> (self.head) {</span>
<span class="line" id="L56">            UNLOCKED =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L57">            LOCKED =&gt; <span class="tok-null">null</span>,</span>
<span class="line" id="L58">            <span class="tok-kw">else</span> =&gt; <span class="tok-builtin">@intToPtr</span>(*Waiter, self.head),</span>
<span class="line" id="L59">        };</span>
<span class="line" id="L60"></span>
<span class="line" id="L61">        <span class="tok-kw">if</span> (head) |h| {</span>
<span class="line" id="L62">            h.tail.next = &amp;waiter;</span>
<span class="line" id="L63">            h.tail = &amp;waiter;</span>
<span class="line" id="L64">        } <span class="tok-kw">else</span> {</span>
<span class="line" id="L65">            self.head = <span class="tok-builtin">@ptrToInt</span>(&amp;waiter);</span>
<span class="line" id="L66">        }</span>
<span class="line" id="L67"></span>
<span class="line" id="L68">        <span class="tok-kw">suspend</span> {</span>
<span class="line" id="L69">            waiter.node = Loop.NextTickNode{</span>
<span class="line" id="L70">                .prev = <span class="tok-null">undefined</span>,</span>
<span class="line" id="L71">                .next = <span class="tok-null">undefined</span>,</span>
<span class="line" id="L72">                .data = <span class="tok-builtin">@frame</span>(),</span>
<span class="line" id="L73">            };</span>
<span class="line" id="L74">            self.mutex.unlock();</span>
<span class="line" id="L75">        }</span>
<span class="line" id="L76"></span>
<span class="line" id="L77">        <span class="tok-kw">return</span> Held{ .lock = self };</span>
<span class="line" id="L78">    }</span>
<span class="line" id="L79"></span>
<span class="line" id="L80">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> Held = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L81">        lock: *Lock,</span>
<span class="line" id="L82"></span>
<span class="line" id="L83">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">release</span>(self: Held) <span class="tok-type">void</span> {</span>
<span class="line" id="L84">            <span class="tok-kw">const</span> waiter = blk: {</span>
<span class="line" id="L85">                self.lock.mutex.lock();</span>
<span class="line" id="L86">                <span class="tok-kw">defer</span> self.lock.mutex.unlock();</span>
<span class="line" id="L87"></span>
<span class="line" id="L88">                <span class="tok-comment">// self.head goes through the reverse transition from acquire():</span>
</span>
<span class="line" id="L89">                <span class="tok-comment">// &lt;head ptr&gt; -&gt; &lt;new head ptr&gt;:</span>
</span>
<span class="line" id="L90">                <span class="tok-comment">//   pop a waiter from the queue to give Lock ownership when theres still others pending</span>
</span>
<span class="line" id="L91">                <span class="tok-comment">// &lt;head ptr&gt; -&gt; LOCKED:</span>
</span>
<span class="line" id="L92">                <span class="tok-comment">//   pop the laster waiter from the queue, while also giving it lock ownership when awaken</span>
</span>
<span class="line" id="L93">                <span class="tok-comment">// LOCKED -&gt; UNLOCKED:</span>
</span>
<span class="line" id="L94">                <span class="tok-comment">//   last lock owner releases lock while no one else is waiting for it</span>
</span>
<span class="line" id="L95"></span>
<span class="line" id="L96">                <span class="tok-kw">switch</span> (self.lock.head) {</span>
<span class="line" id="L97">                    UNLOCKED =&gt; {</span>
<span class="line" id="L98">                        <span class="tok-kw">unreachable</span>; <span class="tok-comment">// Lock unlocked while unlocking</span>
</span>
<span class="line" id="L99">                    },</span>
<span class="line" id="L100">                    LOCKED =&gt; {</span>
<span class="line" id="L101">                        self.lock.head = UNLOCKED;</span>
<span class="line" id="L102">                        <span class="tok-kw">break</span> :blk <span class="tok-null">null</span>;</span>
<span class="line" id="L103">                    },</span>
<span class="line" id="L104">                    <span class="tok-kw">else</span> =&gt; {</span>
<span class="line" id="L105">                        <span class="tok-kw">const</span> waiter = <span class="tok-builtin">@intToPtr</span>(*Waiter, self.lock.head);</span>
<span class="line" id="L106">                        self.lock.head = <span class="tok-kw">if</span> (waiter.next == <span class="tok-null">null</span>) LOCKED <span class="tok-kw">else</span> <span class="tok-builtin">@ptrToInt</span>(waiter.next);</span>
<span class="line" id="L107">                        <span class="tok-kw">if</span> (waiter.next) |next|</span>
<span class="line" id="L108">                            next.tail = waiter.tail;</span>
<span class="line" id="L109">                        <span class="tok-kw">break</span> :blk waiter;</span>
<span class="line" id="L110">                    },</span>
<span class="line" id="L111">                }</span>
<span class="line" id="L112">            };</span>
<span class="line" id="L113"></span>
<span class="line" id="L114">            <span class="tok-kw">if</span> (waiter) |w| {</span>
<span class="line" id="L115">                global_event_loop.onNextTick(&amp;w.node);</span>
<span class="line" id="L116">            }</span>
<span class="line" id="L117">        }</span>
<span class="line" id="L118">    };</span>
<span class="line" id="L119">};</span>
<span class="line" id="L120"></span>
<span class="line" id="L121"><span class="tok-kw">test</span> <span class="tok-str">&quot;std.event.Lock&quot;</span> {</span>
<span class="line" id="L122">    <span class="tok-kw">if</span> (!std.io.is_async) <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SkipZigTest;</span>
<span class="line" id="L123"></span>
<span class="line" id="L124">    <span class="tok-comment">// TODO https://github.com/ziglang/zig/issues/1908</span>
</span>
<span class="line" id="L125">    <span class="tok-kw">if</span> (builtin.single_threaded) <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SkipZigTest;</span>
<span class="line" id="L126"></span>
<span class="line" id="L127">    <span class="tok-comment">// TODO https://github.com/ziglang/zig/issues/3251</span>
</span>
<span class="line" id="L128">    <span class="tok-kw">if</span> (builtin.os.tag == .freebsd) <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SkipZigTest;</span>
<span class="line" id="L129"></span>
<span class="line" id="L130">    <span class="tok-kw">var</span> lock = Lock{};</span>
<span class="line" id="L131">    testLock(&amp;lock);</span>
<span class="line" id="L132"></span>
<span class="line" id="L133">    <span class="tok-kw">const</span> expected_result = [<span class="tok-number">1</span>]<span class="tok-type">i32</span>{<span class="tok-number">3</span> * <span class="tok-builtin">@intCast</span>(<span class="tok-type">i32</span>, shared_test_data.len)} ** shared_test_data.len;</span>
<span class="line" id="L134">    <span class="tok-kw">try</span> testing.expectEqualSlices(<span class="tok-type">i32</span>, &amp;expected_result, &amp;shared_test_data);</span>
<span class="line" id="L135">}</span>
<span class="line" id="L136"><span class="tok-kw">fn</span> <span class="tok-fn">testLock</span>(lock: *Lock) <span class="tok-type">void</span> {</span>
<span class="line" id="L137">    <span class="tok-kw">var</span> handle1 = <span class="tok-kw">async</span> lockRunner(lock);</span>
<span class="line" id="L138">    <span class="tok-kw">var</span> handle2 = <span class="tok-kw">async</span> lockRunner(lock);</span>
<span class="line" id="L139">    <span class="tok-kw">var</span> handle3 = <span class="tok-kw">async</span> lockRunner(lock);</span>
<span class="line" id="L140"></span>
<span class="line" id="L141">    <span class="tok-kw">await</span> handle1;</span>
<span class="line" id="L142">    <span class="tok-kw">await</span> handle2;</span>
<span class="line" id="L143">    <span class="tok-kw">await</span> handle3;</span>
<span class="line" id="L144">}</span>
<span class="line" id="L145"></span>
<span class="line" id="L146"><span class="tok-kw">var</span> shared_test_data = [<span class="tok-number">1</span>]<span class="tok-type">i32</span>{<span class="tok-number">0</span>} ** <span class="tok-number">10</span>;</span>
<span class="line" id="L147"><span class="tok-kw">var</span> shared_test_index: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L148"></span>
<span class="line" id="L149"><span class="tok-kw">fn</span> <span class="tok-fn">lockRunner</span>(lock: *Lock) <span class="tok-type">void</span> {</span>
<span class="line" id="L150">    Lock.global_event_loop.yield();</span>
<span class="line" id="L151"></span>
<span class="line" id="L152">    <span class="tok-kw">var</span> i: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L153">    <span class="tok-kw">while</span> (i &lt; shared_test_data.len) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L154">        <span class="tok-kw">const</span> handle = lock.acquire();</span>
<span class="line" id="L155">        <span class="tok-kw">defer</span> handle.release();</span>
<span class="line" id="L156"></span>
<span class="line" id="L157">        shared_test_index = <span class="tok-number">0</span>;</span>
<span class="line" id="L158">        <span class="tok-kw">while</span> (shared_test_index &lt; shared_test_data.len) : (shared_test_index += <span class="tok-number">1</span>) {</span>
<span class="line" id="L159">            shared_test_data[shared_test_index] = shared_test_data[shared_test_index] + <span class="tok-number">1</span>;</span>
<span class="line" id="L160">        }</span>
<span class="line" id="L161">    }</span>
<span class="line" id="L162">}</span>
<span class="line" id="L163"></span>
</code></pre></body>
</html>