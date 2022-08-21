<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">    <title>Thread/Condition.zig - source view</title>
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
<pre><code><span class="line" id="L1"><span class="tok-comment">//! Condition variables are used with a Mutex to efficiently wait for an arbitrary condition to occur.</span></span>
<span class="line" id="L2"><span class="tok-comment">//! It does this by atomically unlocking the mutex, blocking the thread until notified, and finally re-locking the mutex.</span></span>
<span class="line" id="L3"><span class="tok-comment">//! Condition can be statically initialized and is at most `@sizeOf(u64)` large.</span></span>
<span class="line" id="L4"><span class="tok-comment">//!</span></span>
<span class="line" id="L5"><span class="tok-comment">//! Example:</span></span>
<span class="line" id="L6"><span class="tok-comment">//! ```</span></span>
<span class="line" id="L7"><span class="tok-comment">//! var m = Mutex{};</span></span>
<span class="line" id="L8"><span class="tok-comment">//! var c = Condition{};</span></span>
<span class="line" id="L9"><span class="tok-comment">//! var predicate = false;</span></span>
<span class="line" id="L10"><span class="tok-comment">//!</span></span>
<span class="line" id="L11"><span class="tok-comment">//! fn consumer() void {</span></span>
<span class="line" id="L12"><span class="tok-comment">//!     m.lock();</span></span>
<span class="line" id="L13"><span class="tok-comment">//!     defer m.unlock();</span></span>
<span class="line" id="L14"><span class="tok-comment">//!</span></span>
<span class="line" id="L15"><span class="tok-comment">//!     while (!predicate) {</span></span>
<span class="line" id="L16"><span class="tok-comment">//!         c.wait(&amp;mutex);</span></span>
<span class="line" id="L17"><span class="tok-comment">//!     }</span></span>
<span class="line" id="L18"><span class="tok-comment">//! }</span></span>
<span class="line" id="L19"><span class="tok-comment">//!</span></span>
<span class="line" id="L20"><span class="tok-comment">//! fn producer() void {</span></span>
<span class="line" id="L21"><span class="tok-comment">//!     m.lock();</span></span>
<span class="line" id="L22"><span class="tok-comment">//!     defer m.unlock();</span></span>
<span class="line" id="L23"><span class="tok-comment">//!</span></span>
<span class="line" id="L24"><span class="tok-comment">//!     predicate = true;</span></span>
<span class="line" id="L25"><span class="tok-comment">//!     c.signal();</span></span>
<span class="line" id="L26"><span class="tok-comment">//! }</span></span>
<span class="line" id="L27"><span class="tok-comment">//!</span></span>
<span class="line" id="L28"><span class="tok-comment">//! const thread = try std.Thread.spawn(.{}, producer, .{});</span></span>
<span class="line" id="L29"><span class="tok-comment">//! consumer();</span></span>
<span class="line" id="L30"><span class="tok-comment">//! thread.join();</span></span>
<span class="line" id="L31"><span class="tok-comment">//! ```</span></span>
<span class="line" id="L32"><span class="tok-comment">//!</span></span>
<span class="line" id="L33"><span class="tok-comment">//! Note that condition variables can only reliably unblock threads that are sequenced before them using the same Mutex.</span></span>
<span class="line" id="L34"><span class="tok-comment">//! This means that the following is allowed to deadlock:</span></span>
<span class="line" id="L35"><span class="tok-comment">//! ```</span></span>
<span class="line" id="L36"><span class="tok-comment">//! thread-1: mutex.lock()</span></span>
<span class="line" id="L37"><span class="tok-comment">//! thread-1: condition.wait(&amp;mutex)</span></span>
<span class="line" id="L38"><span class="tok-comment">//!</span></span>
<span class="line" id="L39"><span class="tok-comment">//! thread-2: // mutex.lock() (without this, the following signal may not see the waiting thread-1)</span></span>
<span class="line" id="L40"><span class="tok-comment">//! thread-2: // mutex.unlock() (this is optional for correctness once locked above, as signal can be called without holding the mutex)</span></span>
<span class="line" id="L41"><span class="tok-comment">//! thread-2: condition.signal()</span></span>
<span class="line" id="L42"><span class="tok-comment">//! ```</span></span>
<span class="line" id="L43"></span>
<span class="line" id="L44"><span class="tok-kw">const</span> std = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;../std.zig&quot;</span>);</span>
<span class="line" id="L45"><span class="tok-kw">const</span> builtin = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;builtin&quot;</span>);</span>
<span class="line" id="L46"><span class="tok-kw">const</span> Condition = <span class="tok-builtin">@This</span>();</span>
<span class="line" id="L47"><span class="tok-kw">const</span> Mutex = std.Thread.Mutex;</span>
<span class="line" id="L48"></span>
<span class="line" id="L49"><span class="tok-kw">const</span> os = std.os;</span>
<span class="line" id="L50"><span class="tok-kw">const</span> assert = std.debug.assert;</span>
<span class="line" id="L51"><span class="tok-kw">const</span> testing = std.testing;</span>
<span class="line" id="L52"><span class="tok-kw">const</span> Atomic = std.atomic.Atomic;</span>
<span class="line" id="L53"><span class="tok-kw">const</span> Futex = std.Thread.Futex;</span>
<span class="line" id="L54"></span>
<span class="line" id="L55">impl: Impl = .{},</span>
<span class="line" id="L56"></span>
<span class="line" id="L57"><span class="tok-comment">/// Atomically releases the Mutex, blocks the caller thread, then re-acquires the Mutex on return.</span></span>
<span class="line" id="L58"><span class="tok-comment">/// &quot;Atomically&quot; here refers to accesses done on the Condition after acquiring the Mutex.</span></span>
<span class="line" id="L59"><span class="tok-comment">///</span></span>
<span class="line" id="L60"><span class="tok-comment">/// The Mutex must be locked by the caller's thread when this function is called.</span></span>
<span class="line" id="L61"><span class="tok-comment">/// A Mutex can have multiple Conditions waiting with it concurrently, but not the opposite.</span></span>
<span class="line" id="L62"><span class="tok-comment">/// It is undefined behavior for multiple threads to wait ith different mutexes using the same Condition concurrently.</span></span>
<span class="line" id="L63"><span class="tok-comment">/// Once threads have finished waiting with one Mutex, the Condition can be used to wait with another Mutex.</span></span>
<span class="line" id="L64"><span class="tok-comment">///</span></span>
<span class="line" id="L65"><span class="tok-comment">/// A blocking call to wait() is unblocked from one of the following conditions:</span></span>
<span class="line" id="L66"><span class="tok-comment">/// - a spurious (&quot;at random&quot;) wake up occurs</span></span>
<span class="line" id="L67"><span class="tok-comment">/// - a future call to `signal()` or `broadcast()` which has acquired the Mutex and is sequenced after this `wait()`.</span></span>
<span class="line" id="L68"><span class="tok-comment">///</span></span>
<span class="line" id="L69"><span class="tok-comment">/// Given wait() can be interrupted spuriously, the blocking condition should be checked continuously</span></span>
<span class="line" id="L70"><span class="tok-comment">/// irrespective of any notifications from `signal()` or `broadcast()`.</span></span>
<span class="line" id="L71"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">wait</span>(self: *Condition, mutex: *Mutex) <span class="tok-type">void</span> {</span>
<span class="line" id="L72">    self.impl.wait(mutex, <span class="tok-null">null</span>) <span class="tok-kw">catch</span> |err| <span class="tok-kw">switch</span> (err) {</span>
<span class="line" id="L73">        <span class="tok-kw">error</span>.Timeout =&gt; <span class="tok-kw">unreachable</span>, <span class="tok-comment">// no timeout provided so we shouldn't have timed-out</span>
</span>
<span class="line" id="L74">    };</span>
<span class="line" id="L75">}</span>
<span class="line" id="L76"></span>
<span class="line" id="L77"><span class="tok-comment">/// Atomically releases the Mutex, blocks the caller thread, then re-acquires the Mutex on return.</span></span>
<span class="line" id="L78"><span class="tok-comment">/// &quot;Atomically&quot; here refers to accesses done on the Condition after acquiring the Mutex.</span></span>
<span class="line" id="L79"><span class="tok-comment">///</span></span>
<span class="line" id="L80"><span class="tok-comment">/// The Mutex must be locked by the caller's thread when this function is called.</span></span>
<span class="line" id="L81"><span class="tok-comment">/// A Mutex can have multiple Conditions waiting with it concurrently, but not the opposite.</span></span>
<span class="line" id="L82"><span class="tok-comment">/// It is undefined behavior for multiple threads to wait ith different mutexes using the same Condition concurrently.</span></span>
<span class="line" id="L83"><span class="tok-comment">/// Once threads have finished waiting with one Mutex, the Condition can be used to wait with another Mutex.</span></span>
<span class="line" id="L84"><span class="tok-comment">///</span></span>
<span class="line" id="L85"><span class="tok-comment">/// A blocking call to `timedWait()` is unblocked from one of the following conditions:</span></span>
<span class="line" id="L86"><span class="tok-comment">/// - a spurious (&quot;at random&quot;) wake occurs</span></span>
<span class="line" id="L87"><span class="tok-comment">/// - the caller was blocked for around `timeout_ns` nanoseconds, in which `error.Timeout` is returned.</span></span>
<span class="line" id="L88"><span class="tok-comment">/// - a future call to `signal()` or `broadcast()` which has acquired the Mutex and is sequenced after this `timedWait()`.</span></span>
<span class="line" id="L89"><span class="tok-comment">///</span></span>
<span class="line" id="L90"><span class="tok-comment">/// Given `timedWait()` can be interrupted spuriously, the blocking condition should be checked continuously</span></span>
<span class="line" id="L91"><span class="tok-comment">/// irrespective of any notifications from `signal()` or `broadcast()`.</span></span>
<span class="line" id="L92"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">timedWait</span>(self: *Condition, mutex: *Mutex, timeout_ns: <span class="tok-type">u64</span>) <span class="tok-kw">error</span>{Timeout}!<span class="tok-type">void</span> {</span>
<span class="line" id="L93">    <span class="tok-kw">return</span> self.impl.wait(mutex, timeout_ns);</span>
<span class="line" id="L94">}</span>
<span class="line" id="L95"></span>
<span class="line" id="L96"><span class="tok-comment">/// Unblocks at least one thread blocked in a call to `wait()` or `timedWait()` with a given Mutex.</span></span>
<span class="line" id="L97"><span class="tok-comment">/// The blocked thread must be sequenced before this call with respect to acquiring the same Mutex in order to be observable for unblocking.</span></span>
<span class="line" id="L98"><span class="tok-comment">/// `signal()` can be called with or without the relevant Mutex being acquired and have no &quot;effect&quot; if there's no observable blocked threads.</span></span>
<span class="line" id="L99"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">signal</span>(self: *Condition) <span class="tok-type">void</span> {</span>
<span class="line" id="L100">    self.impl.wake(.one);</span>
<span class="line" id="L101">}</span>
<span class="line" id="L102"></span>
<span class="line" id="L103"><span class="tok-comment">/// Unblocks all threads currently blocked in a call to `wait()` or `timedWait()` with a given Mutex.</span></span>
<span class="line" id="L104"><span class="tok-comment">/// The blocked threads must be sequenced before this call with respect to acquiring the same Mutex in order to be observable for unblocking.</span></span>
<span class="line" id="L105"><span class="tok-comment">/// `broadcast()` can be called with or without the relevant Mutex being acquired and have no &quot;effect&quot; if there's no observable blocked threads.</span></span>
<span class="line" id="L106"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">broadcast</span>(self: *Condition) <span class="tok-type">void</span> {</span>
<span class="line" id="L107">    self.impl.wake(.all);</span>
<span class="line" id="L108">}</span>
<span class="line" id="L109"></span>
<span class="line" id="L110"><span class="tok-kw">const</span> Impl = <span class="tok-kw">if</span> (builtin.single_threaded)</span>
<span class="line" id="L111">    SingleThreadedImpl</span>
<span class="line" id="L112"><span class="tok-kw">else</span> <span class="tok-kw">if</span> (builtin.os.tag == .windows)</span>
<span class="line" id="L113">    WindowsImpl</span>
<span class="line" id="L114"><span class="tok-kw">else</span></span>
<span class="line" id="L115">    FutexImpl;</span>
<span class="line" id="L116"></span>
<span class="line" id="L117"><span class="tok-kw">const</span> Notify = <span class="tok-kw">enum</span> {</span>
<span class="line" id="L118">    one, <span class="tok-comment">// wake up only one thread</span>
</span>
<span class="line" id="L119">    all, <span class="tok-comment">// wake up all threads</span>
</span>
<span class="line" id="L120">};</span>
<span class="line" id="L121"></span>
<span class="line" id="L122"><span class="tok-kw">const</span> SingleThreadedImpl = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L123">    <span class="tok-kw">fn</span> <span class="tok-fn">wait</span>(self: *Impl, mutex: *Mutex, timeout: ?<span class="tok-type">u64</span>) <span class="tok-kw">error</span>{Timeout}!<span class="tok-type">void</span> {</span>
<span class="line" id="L124">        _ = self;</span>
<span class="line" id="L125">        _ = mutex;</span>
<span class="line" id="L126"></span>
<span class="line" id="L127">        <span class="tok-comment">// There are no other threads to wake us up.</span>
</span>
<span class="line" id="L128">        <span class="tok-comment">// So if we wait without a timeout we would never wake up.</span>
</span>
<span class="line" id="L129">        <span class="tok-kw">const</span> timeout_ns = timeout <span class="tok-kw">orelse</span> {</span>
<span class="line" id="L130">            <span class="tok-kw">unreachable</span>; <span class="tok-comment">// deadlock detected</span>
</span>
<span class="line" id="L131">        };</span>
<span class="line" id="L132"></span>
<span class="line" id="L133">        std.time.sleep(timeout_ns);</span>
<span class="line" id="L134">        <span class="tok-kw">return</span> <span class="tok-kw">error</span>.Timeout;</span>
<span class="line" id="L135">    }</span>
<span class="line" id="L136"></span>
<span class="line" id="L137">    <span class="tok-kw">fn</span> <span class="tok-fn">wake</span>(self: *Impl, <span class="tok-kw">comptime</span> notify: Notify) <span class="tok-type">void</span> {</span>
<span class="line" id="L138">        <span class="tok-comment">// There are no other threads to wake up.</span>
</span>
<span class="line" id="L139">        _ = self;</span>
<span class="line" id="L140">        _ = notify;</span>
<span class="line" id="L141">    }</span>
<span class="line" id="L142">};</span>
<span class="line" id="L143"></span>
<span class="line" id="L144"><span class="tok-kw">const</span> WindowsImpl = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L145">    condition: os.windows.CONDITION_VARIABLE = .{},</span>
<span class="line" id="L146"></span>
<span class="line" id="L147">    <span class="tok-kw">fn</span> <span class="tok-fn">wait</span>(self: *Impl, mutex: *Mutex, timeout: ?<span class="tok-type">u64</span>) <span class="tok-kw">error</span>{Timeout}!<span class="tok-type">void</span> {</span>
<span class="line" id="L148">        <span class="tok-kw">var</span> timeout_overflowed = <span class="tok-null">false</span>;</span>
<span class="line" id="L149">        <span class="tok-kw">var</span> timeout_ms: os.windows.DWORD = os.windows.INFINITE;</span>
<span class="line" id="L150"></span>
<span class="line" id="L151">        <span class="tok-kw">if</span> (timeout) |timeout_ns| {</span>
<span class="line" id="L152">            <span class="tok-comment">// Round the nanoseconds to the nearest millisecond,</span>
</span>
<span class="line" id="L153">            <span class="tok-comment">// then saturating cast it to windows DWORD for use in kernel32 call.</span>
</span>
<span class="line" id="L154">            <span class="tok-kw">const</span> ms = (timeout_ns +| (std.time.ns_per_ms / <span class="tok-number">2</span>)) / std.time.ns_per_ms;</span>
<span class="line" id="L155">            timeout_ms = std.math.cast(os.windows.DWORD, ms) <span class="tok-kw">orelse</span> std.math.maxInt(os.windows.DWORD);</span>
<span class="line" id="L156"></span>
<span class="line" id="L157">            <span class="tok-comment">// Track if the timeout overflowed into INFINITE and make sure not to wait forever.</span>
</span>
<span class="line" id="L158">            <span class="tok-kw">if</span> (timeout_ms == os.windows.INFINITE) {</span>
<span class="line" id="L159">                timeout_overflowed = <span class="tok-null">true</span>;</span>
<span class="line" id="L160">                timeout_ms -= <span class="tok-number">1</span>;</span>
<span class="line" id="L161">            }</span>
<span class="line" id="L162">        }</span>
<span class="line" id="L163"></span>
<span class="line" id="L164">        <span class="tok-kw">const</span> rc = os.windows.kernel32.SleepConditionVariableSRW(</span>
<span class="line" id="L165">            &amp;self.condition,</span>
<span class="line" id="L166">            &amp;mutex.impl.srwlock,</span>
<span class="line" id="L167">            timeout_ms,</span>
<span class="line" id="L168">            <span class="tok-number">0</span>, <span class="tok-comment">// the srwlock was assumed to acquired in exclusive mode not shared</span>
</span>
<span class="line" id="L169">        );</span>
<span class="line" id="L170"></span>
<span class="line" id="L171">        <span class="tok-comment">// Return error.Timeout if we know the timeout elapsed correctly.</span>
</span>
<span class="line" id="L172">        <span class="tok-kw">if</span> (rc == os.windows.FALSE) {</span>
<span class="line" id="L173">            assert(os.windows.kernel32.GetLastError() == .TIMEOUT);</span>
<span class="line" id="L174">            <span class="tok-kw">if</span> (!timeout_overflowed) <span class="tok-kw">return</span> <span class="tok-kw">error</span>.Timeout;</span>
<span class="line" id="L175">        }</span>
<span class="line" id="L176">    }</span>
<span class="line" id="L177"></span>
<span class="line" id="L178">    <span class="tok-kw">fn</span> <span class="tok-fn">wake</span>(self: *Impl, <span class="tok-kw">comptime</span> notify: Notify) <span class="tok-type">void</span> {</span>
<span class="line" id="L179">        <span class="tok-kw">switch</span> (notify) {</span>
<span class="line" id="L180">            .one =&gt; os.windows.kernel32.WakeConditionVariable(&amp;self.condition),</span>
<span class="line" id="L181">            .all =&gt; os.windows.kernel32.WakeAllConditionVariable(&amp;self.condition),</span>
<span class="line" id="L182">        }</span>
<span class="line" id="L183">    }</span>
<span class="line" id="L184">};</span>
<span class="line" id="L185"></span>
<span class="line" id="L186"><span class="tok-kw">const</span> FutexImpl = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L187">    state: Atomic(<span class="tok-type">u32</span>) = Atomic(<span class="tok-type">u32</span>).init(<span class="tok-number">0</span>),</span>
<span class="line" id="L188">    epoch: Atomic(<span class="tok-type">u32</span>) = Atomic(<span class="tok-type">u32</span>).init(<span class="tok-number">0</span>),</span>
<span class="line" id="L189"></span>
<span class="line" id="L190">    <span class="tok-kw">const</span> one_waiter = <span class="tok-number">1</span>;</span>
<span class="line" id="L191">    <span class="tok-kw">const</span> waiter_mask = <span class="tok-number">0xffff</span>;</span>
<span class="line" id="L192"></span>
<span class="line" id="L193">    <span class="tok-kw">const</span> one_signal = <span class="tok-number">1</span> &lt;&lt; <span class="tok-number">16</span>;</span>
<span class="line" id="L194">    <span class="tok-kw">const</span> signal_mask = <span class="tok-number">0xffff</span> &lt;&lt; <span class="tok-number">16</span>;</span>
<span class="line" id="L195"></span>
<span class="line" id="L196">    <span class="tok-kw">fn</span> <span class="tok-fn">wait</span>(self: *Impl, mutex: *Mutex, timeout: ?<span class="tok-type">u64</span>) <span class="tok-kw">error</span>{Timeout}!<span class="tok-type">void</span> {</span>
<span class="line" id="L197">        <span class="tok-comment">// Register that we're waiting on the state by incrementing the wait count.</span>
</span>
<span class="line" id="L198">        <span class="tok-comment">// This assumes that there can be at most ((1&lt;&lt;16)-1) or 65,355 threads concurrently waiting on the same Condvar.</span>
</span>
<span class="line" id="L199">        <span class="tok-comment">// If this is hit in practice, then this condvar not working is the least of your concerns.</span>
</span>
<span class="line" id="L200">        <span class="tok-kw">var</span> state = self.state.fetchAdd(one_waiter, .Monotonic);</span>
<span class="line" id="L201">        assert(state &amp; waiter_mask != waiter_mask);</span>
<span class="line" id="L202">        state += one_waiter;</span>
<span class="line" id="L203"></span>
<span class="line" id="L204">        <span class="tok-comment">// Temporarily release the mutex in order to block on the condition variable.</span>
</span>
<span class="line" id="L205">        mutex.unlock();</span>
<span class="line" id="L206">        <span class="tok-kw">defer</span> mutex.lock();</span>
<span class="line" id="L207"></span>
<span class="line" id="L208">        <span class="tok-kw">var</span> futex_deadline = Futex.Deadline.init(timeout);</span>
<span class="line" id="L209">        <span class="tok-kw">while</span> (<span class="tok-null">true</span>) {</span>
<span class="line" id="L210">            <span class="tok-comment">// Try to wake up by consuming a signal and decremented the waiter we added previously.</span>
</span>
<span class="line" id="L211">            <span class="tok-comment">// Acquire barrier ensures code before the wake() which added the signal happens before we decrement it and return.</span>
</span>
<span class="line" id="L212">            <span class="tok-kw">while</span> (state &amp; signal_mask != <span class="tok-number">0</span>) {</span>
<span class="line" id="L213">                <span class="tok-kw">const</span> new_state = state - one_waiter - one_signal;</span>
<span class="line" id="L214">                state = self.state.tryCompareAndSwap(state, new_state, .Acquire, .Monotonic) <span class="tok-kw">orelse</span> <span class="tok-kw">return</span>;</span>
<span class="line" id="L215">            }</span>
<span class="line" id="L216"></span>
<span class="line" id="L217">            <span class="tok-comment">// Observe the epoch, then check the state again to see if we should wake up.</span>
</span>
<span class="line" id="L218">            <span class="tok-comment">// The epoch must be observed before we check the state or we could potentially miss a wake() and deadlock:</span>
</span>
<span class="line" id="L219">            <span class="tok-comment">//</span>
</span>
<span class="line" id="L220">            <span class="tok-comment">// - T1: s = LOAD(&amp;state)</span>
</span>
<span class="line" id="L221">            <span class="tok-comment">// - T2: UPDATE(&amp;s, signal)</span>
</span>
<span class="line" id="L222">            <span class="tok-comment">// - T2: UPDATE(&amp;epoch, 1) + FUTEX_WAKE(&amp;epoch)</span>
</span>
<span class="line" id="L223">            <span class="tok-comment">// - T1: e = LOAD(&amp;epoch) (was reordered after the state load)</span>
</span>
<span class="line" id="L224">            <span class="tok-comment">// - T1: s &amp; signals == 0 -&gt; FUTEX_WAIT(&amp;epoch, e) (missed the state update + the epoch change)</span>
</span>
<span class="line" id="L225">            <span class="tok-comment">//</span>
</span>
<span class="line" id="L226">            <span class="tok-comment">// Acquire barrier to ensure the epoch load happens before the state load.</span>
</span>
<span class="line" id="L227">            <span class="tok-kw">const</span> epoch = self.epoch.load(.Acquire);</span>
<span class="line" id="L228">            state = self.state.load(.Monotonic);</span>
<span class="line" id="L229">            <span class="tok-kw">if</span> (state &amp; signal_mask != <span class="tok-number">0</span>) {</span>
<span class="line" id="L230">                <span class="tok-kw">continue</span>;</span>
<span class="line" id="L231">            }</span>
<span class="line" id="L232"></span>
<span class="line" id="L233">            futex_deadline.wait(&amp;self.epoch, epoch) <span class="tok-kw">catch</span> |err| <span class="tok-kw">switch</span> (err) {</span>
<span class="line" id="L234">                <span class="tok-comment">// On timeout, we must decrement the waiter we added above.</span>
</span>
<span class="line" id="L235">                <span class="tok-kw">error</span>.Timeout =&gt; {</span>
<span class="line" id="L236">                    <span class="tok-kw">while</span> (<span class="tok-null">true</span>) {</span>
<span class="line" id="L237">                        <span class="tok-comment">// If there's a signal when we're timing out, consume it and report being woken up instead.</span>
</span>
<span class="line" id="L238">                        <span class="tok-comment">// Acquire barrier ensures code before the wake() which added the signal happens before we decrement it and return.</span>
</span>
<span class="line" id="L239">                        <span class="tok-kw">while</span> (state &amp; signal_mask != <span class="tok-number">0</span>) {</span>
<span class="line" id="L240">                            <span class="tok-kw">const</span> new_state = state - one_waiter - one_signal;</span>
<span class="line" id="L241">                            state = self.state.tryCompareAndSwap(state, new_state, .Acquire, .Monotonic) <span class="tok-kw">orelse</span> <span class="tok-kw">return</span>;</span>
<span class="line" id="L242">                        }</span>
<span class="line" id="L243"></span>
<span class="line" id="L244">                        <span class="tok-comment">// Remove the waiter we added and officially return timed out.</span>
</span>
<span class="line" id="L245">                        <span class="tok-kw">const</span> new_state = state - one_waiter;</span>
<span class="line" id="L246">                        state = self.state.tryCompareAndSwap(state, new_state, .Monotonic, .Monotonic) <span class="tok-kw">orelse</span> <span class="tok-kw">return</span> err;</span>
<span class="line" id="L247">                    }</span>
<span class="line" id="L248">                },</span>
<span class="line" id="L249">            };</span>
<span class="line" id="L250">        }</span>
<span class="line" id="L251">    }</span>
<span class="line" id="L252"></span>
<span class="line" id="L253">    <span class="tok-kw">fn</span> <span class="tok-fn">wake</span>(self: *Impl, <span class="tok-kw">comptime</span> notify: Notify) <span class="tok-type">void</span> {</span>
<span class="line" id="L254">        <span class="tok-kw">var</span> state = self.state.load(.Monotonic);</span>
<span class="line" id="L255">        <span class="tok-kw">while</span> (<span class="tok-null">true</span>) {</span>
<span class="line" id="L256">            <span class="tok-kw">const</span> waiters = (state &amp; waiter_mask) / one_waiter;</span>
<span class="line" id="L257">            <span class="tok-kw">const</span> signals = (state &amp; signal_mask) / one_signal;</span>
<span class="line" id="L258"></span>
<span class="line" id="L259">            <span class="tok-comment">// Reserves which waiters to wake up by incrementing the signals count.</span>
</span>
<span class="line" id="L260">            <span class="tok-comment">// Therefor, the signals count is always less than or equal to the waiters count.</span>
</span>
<span class="line" id="L261">            <span class="tok-comment">// We don't need to Futex.wake if there's nothing to wake up or if other wake() threads have reserved to wake up the current waiters.</span>
</span>
<span class="line" id="L262">            <span class="tok-kw">const</span> wakeable = waiters - signals;</span>
<span class="line" id="L263">            <span class="tok-kw">if</span> (wakeable == <span class="tok-number">0</span>) {</span>
<span class="line" id="L264">                <span class="tok-kw">return</span>;</span>
<span class="line" id="L265">            }</span>
<span class="line" id="L266"></span>
<span class="line" id="L267">            <span class="tok-kw">const</span> to_wake = <span class="tok-kw">switch</span> (notify) {</span>
<span class="line" id="L268">                .one =&gt; <span class="tok-number">1</span>,</span>
<span class="line" id="L269">                .all =&gt; wakeable,</span>
<span class="line" id="L270">            };</span>
<span class="line" id="L271"></span>
<span class="line" id="L272">            <span class="tok-comment">// Reserve the amount of waiters to wake by incrementing the signals count.</span>
</span>
<span class="line" id="L273">            <span class="tok-comment">// Release barrier ensures code before the wake() happens before the signal it posted and consumed by the wait() threads.</span>
</span>
<span class="line" id="L274">            <span class="tok-kw">const</span> new_state = state + (one_signal * to_wake);</span>
<span class="line" id="L275">            state = self.state.tryCompareAndSwap(state, new_state, .Release, .Monotonic) <span class="tok-kw">orelse</span> {</span>
<span class="line" id="L276">                <span class="tok-comment">// Wake up the waiting threads we reserved above by changing the epoch value.</span>
</span>
<span class="line" id="L277">                <span class="tok-comment">// NOTE: a waiting thread could miss a wake up if *exactly* ((1&lt;&lt;32)-1) wake()s happen between it observing the epoch and sleeping on it.</span>
</span>
<span class="line" id="L278">                <span class="tok-comment">// This is very unlikely due to how many precise amount of Futex.wake() calls that would be between the waiting thread's potential preemption.</span>
</span>
<span class="line" id="L279">                <span class="tok-comment">//</span>
</span>
<span class="line" id="L280">                <span class="tok-comment">// Release barrier ensures the signal being added to the state happens before the epoch is changed.</span>
</span>
<span class="line" id="L281">                <span class="tok-comment">// If not, the waiting thread could potentially deadlock from missing both the state and epoch change:</span>
</span>
<span class="line" id="L282">                <span class="tok-comment">//</span>
</span>
<span class="line" id="L283">                <span class="tok-comment">// - T2: UPDATE(&amp;epoch, 1) (reordered before the state change)</span>
</span>
<span class="line" id="L284">                <span class="tok-comment">// - T1: e = LOAD(&amp;epoch)</span>
</span>
<span class="line" id="L285">                <span class="tok-comment">// - T1: s = LOAD(&amp;state)</span>
</span>
<span class="line" id="L286">                <span class="tok-comment">// - T2: UPDATE(&amp;state, signal) + FUTEX_WAKE(&amp;epoch)</span>
</span>
<span class="line" id="L287">                <span class="tok-comment">// - T1: s &amp; signals == 0 -&gt; FUTEX_WAIT(&amp;epoch, e) (missed both epoch change and state change)</span>
</span>
<span class="line" id="L288">                _ = self.epoch.fetchAdd(<span class="tok-number">1</span>, .Release);</span>
<span class="line" id="L289">                Futex.wake(&amp;self.epoch, to_wake);</span>
<span class="line" id="L290">                <span class="tok-kw">return</span>;</span>
<span class="line" id="L291">            };</span>
<span class="line" id="L292">        }</span>
<span class="line" id="L293">    }</span>
<span class="line" id="L294">};</span>
<span class="line" id="L295"></span>
<span class="line" id="L296"><span class="tok-kw">test</span> <span class="tok-str">&quot;Condition - smoke test&quot;</span> {</span>
<span class="line" id="L297">    <span class="tok-kw">var</span> mutex = Mutex{};</span>
<span class="line" id="L298">    <span class="tok-kw">var</span> cond = Condition{};</span>
<span class="line" id="L299"></span>
<span class="line" id="L300">    <span class="tok-comment">// Try to wake outside the mutex</span>
</span>
<span class="line" id="L301">    <span class="tok-kw">defer</span> cond.signal();</span>
<span class="line" id="L302">    <span class="tok-kw">defer</span> cond.broadcast();</span>
<span class="line" id="L303"></span>
<span class="line" id="L304">    mutex.lock();</span>
<span class="line" id="L305">    <span class="tok-kw">defer</span> mutex.unlock();</span>
<span class="line" id="L306"></span>
<span class="line" id="L307">    <span class="tok-comment">// Try to wait with a timeout (should not deadlock)</span>
</span>
<span class="line" id="L308">    <span class="tok-kw">try</span> testing.expectError(<span class="tok-kw">error</span>.Timeout, cond.timedWait(&amp;mutex, <span class="tok-number">0</span>));</span>
<span class="line" id="L309">    <span class="tok-kw">try</span> testing.expectError(<span class="tok-kw">error</span>.Timeout, cond.timedWait(&amp;mutex, std.time.ns_per_ms));</span>
<span class="line" id="L310"></span>
<span class="line" id="L311">    <span class="tok-comment">// Try to wake inside the mutex.</span>
</span>
<span class="line" id="L312">    cond.signal();</span>
<span class="line" id="L313">    cond.broadcast();</span>
<span class="line" id="L314">}</span>
<span class="line" id="L315"></span>
<span class="line" id="L316"><span class="tok-comment">// Inspired from: https://github.com/Amanieu/parking_lot/pull/129</span>
</span>
<span class="line" id="L317"><span class="tok-kw">test</span> <span class="tok-str">&quot;Condition - wait and signal&quot;</span> {</span>
<span class="line" id="L318">    <span class="tok-comment">// This test requires spawning threads</span>
</span>
<span class="line" id="L319">    <span class="tok-kw">if</span> (builtin.single_threaded) {</span>
<span class="line" id="L320">        <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SkipZigTest;</span>
<span class="line" id="L321">    }</span>
<span class="line" id="L322"></span>
<span class="line" id="L323">    <span class="tok-kw">const</span> num_threads = <span class="tok-number">4</span>;</span>
<span class="line" id="L324"></span>
<span class="line" id="L325">    <span class="tok-kw">const</span> MultiWait = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L326">        mutex: Mutex = .{},</span>
<span class="line" id="L327">        cond: Condition = .{},</span>
<span class="line" id="L328">        threads: [num_threads]std.Thread = <span class="tok-null">undefined</span>,</span>
<span class="line" id="L329"></span>
<span class="line" id="L330">        <span class="tok-kw">fn</span> <span class="tok-fn">run</span>(self: *<span class="tok-builtin">@This</span>()) <span class="tok-type">void</span> {</span>
<span class="line" id="L331">            self.mutex.lock();</span>
<span class="line" id="L332">            <span class="tok-kw">defer</span> self.mutex.unlock();</span>
<span class="line" id="L333"></span>
<span class="line" id="L334">            self.cond.wait(&amp;self.mutex);</span>
<span class="line" id="L335">            self.cond.timedWait(&amp;self.mutex, std.time.ns_per_ms) <span class="tok-kw">catch</span> {};</span>
<span class="line" id="L336">            self.cond.signal();</span>
<span class="line" id="L337">        }</span>
<span class="line" id="L338">    };</span>
<span class="line" id="L339"></span>
<span class="line" id="L340">    <span class="tok-kw">var</span> multi_wait = MultiWait{};</span>
<span class="line" id="L341">    <span class="tok-kw">for</span> (multi_wait.threads) |*t| {</span>
<span class="line" id="L342">        t.* = <span class="tok-kw">try</span> std.Thread.spawn(.{}, MultiWait.run, .{&amp;multi_wait});</span>
<span class="line" id="L343">    }</span>
<span class="line" id="L344"></span>
<span class="line" id="L345">    std.time.sleep(<span class="tok-number">100</span> * std.time.ns_per_ms);</span>
<span class="line" id="L346"></span>
<span class="line" id="L347">    multi_wait.cond.signal();</span>
<span class="line" id="L348">    <span class="tok-kw">for</span> (multi_wait.threads) |t| {</span>
<span class="line" id="L349">        t.join();</span>
<span class="line" id="L350">    }</span>
<span class="line" id="L351">}</span>
<span class="line" id="L352"></span>
<span class="line" id="L353"><span class="tok-kw">test</span> <span class="tok-str">&quot;Condition - signal&quot;</span> {</span>
<span class="line" id="L354">    <span class="tok-comment">// This test requires spawning threads</span>
</span>
<span class="line" id="L355">    <span class="tok-kw">if</span> (builtin.single_threaded) {</span>
<span class="line" id="L356">        <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SkipZigTest;</span>
<span class="line" id="L357">    }</span>
<span class="line" id="L358"></span>
<span class="line" id="L359">    <span class="tok-kw">const</span> num_threads = <span class="tok-number">4</span>;</span>
<span class="line" id="L360"></span>
<span class="line" id="L361">    <span class="tok-kw">const</span> SignalTest = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L362">        mutex: Mutex = .{},</span>
<span class="line" id="L363">        cond: Condition = .{},</span>
<span class="line" id="L364">        notified: <span class="tok-type">bool</span> = <span class="tok-null">false</span>,</span>
<span class="line" id="L365">        threads: [num_threads]std.Thread = <span class="tok-null">undefined</span>,</span>
<span class="line" id="L366"></span>
<span class="line" id="L367">        <span class="tok-kw">fn</span> <span class="tok-fn">run</span>(self: *<span class="tok-builtin">@This</span>()) <span class="tok-type">void</span> {</span>
<span class="line" id="L368">            self.mutex.lock();</span>
<span class="line" id="L369">            <span class="tok-kw">defer</span> self.mutex.unlock();</span>
<span class="line" id="L370"></span>
<span class="line" id="L371">            <span class="tok-comment">// Use timedWait() a few times before using wait()</span>
</span>
<span class="line" id="L372">            <span class="tok-comment">// to test multiple threads timing out frequently.</span>
</span>
<span class="line" id="L373">            <span class="tok-kw">var</span> i: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L374">            <span class="tok-kw">while</span> (!self.notified) : (i +%= <span class="tok-number">1</span>) {</span>
<span class="line" id="L375">                <span class="tok-kw">if</span> (i &lt; <span class="tok-number">5</span>) {</span>
<span class="line" id="L376">                    self.cond.timedWait(&amp;self.mutex, <span class="tok-number">1</span>) <span class="tok-kw">catch</span> {};</span>
<span class="line" id="L377">                } <span class="tok-kw">else</span> {</span>
<span class="line" id="L378">                    self.cond.wait(&amp;self.mutex);</span>
<span class="line" id="L379">                }</span>
<span class="line" id="L380">            }</span>
<span class="line" id="L381"></span>
<span class="line" id="L382">            <span class="tok-comment">// Once we received the signal, notify another thread (inside the lock).</span>
</span>
<span class="line" id="L383">            assert(self.notified);</span>
<span class="line" id="L384">            self.cond.signal();</span>
<span class="line" id="L385">        }</span>
<span class="line" id="L386">    };</span>
<span class="line" id="L387"></span>
<span class="line" id="L388">    <span class="tok-kw">var</span> signal_test = SignalTest{};</span>
<span class="line" id="L389">    <span class="tok-kw">for</span> (signal_test.threads) |*t| {</span>
<span class="line" id="L390">        t.* = <span class="tok-kw">try</span> std.Thread.spawn(.{}, SignalTest.run, .{&amp;signal_test});</span>
<span class="line" id="L391">    }</span>
<span class="line" id="L392"></span>
<span class="line" id="L393">    {</span>
<span class="line" id="L394">        <span class="tok-comment">// Wait for a bit in hopes that the spawned threads start queuing up on the condvar</span>
</span>
<span class="line" id="L395">        std.time.sleep(<span class="tok-number">10</span> * std.time.ns_per_ms);</span>
<span class="line" id="L396"></span>
<span class="line" id="L397">        <span class="tok-comment">// Wake up one of them (outside the lock) after setting notified=true.</span>
</span>
<span class="line" id="L398">        <span class="tok-kw">defer</span> signal_test.cond.signal();</span>
<span class="line" id="L399"></span>
<span class="line" id="L400">        signal_test.mutex.lock();</span>
<span class="line" id="L401">        <span class="tok-kw">defer</span> signal_test.mutex.unlock();</span>
<span class="line" id="L402"></span>
<span class="line" id="L403">        <span class="tok-kw">try</span> testing.expect(!signal_test.notified);</span>
<span class="line" id="L404">        signal_test.notified = <span class="tok-null">true</span>;</span>
<span class="line" id="L405">    }</span>
<span class="line" id="L406"></span>
<span class="line" id="L407">    <span class="tok-kw">for</span> (signal_test.threads) |t| {</span>
<span class="line" id="L408">        t.join();</span>
<span class="line" id="L409">    }</span>
<span class="line" id="L410">}</span>
<span class="line" id="L411"></span>
<span class="line" id="L412"><span class="tok-kw">test</span> <span class="tok-str">&quot;Condition - multi signal&quot;</span> {</span>
<span class="line" id="L413">    <span class="tok-comment">// This test requires spawning threads</span>
</span>
<span class="line" id="L414">    <span class="tok-kw">if</span> (builtin.single_threaded) {</span>
<span class="line" id="L415">        <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SkipZigTest;</span>
<span class="line" id="L416">    }</span>
<span class="line" id="L417"></span>
<span class="line" id="L418">    <span class="tok-kw">const</span> num_threads = <span class="tok-number">4</span>;</span>
<span class="line" id="L419">    <span class="tok-kw">const</span> num_iterations = <span class="tok-number">4</span>;</span>
<span class="line" id="L420"></span>
<span class="line" id="L421">    <span class="tok-kw">const</span> Paddle = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L422">        mutex: Mutex = .{},</span>
<span class="line" id="L423">        cond: Condition = .{},</span>
<span class="line" id="L424">        value: <span class="tok-type">u32</span> = <span class="tok-number">0</span>,</span>
<span class="line" id="L425"></span>
<span class="line" id="L426">        <span class="tok-kw">fn</span> <span class="tok-fn">hit</span>(self: *<span class="tok-builtin">@This</span>()) <span class="tok-type">void</span> {</span>
<span class="line" id="L427">            <span class="tok-kw">defer</span> self.cond.signal();</span>
<span class="line" id="L428"></span>
<span class="line" id="L429">            self.mutex.lock();</span>
<span class="line" id="L430">            <span class="tok-kw">defer</span> self.mutex.unlock();</span>
<span class="line" id="L431"></span>
<span class="line" id="L432">            self.value += <span class="tok-number">1</span>;</span>
<span class="line" id="L433">        }</span>
<span class="line" id="L434"></span>
<span class="line" id="L435">        <span class="tok-kw">fn</span> <span class="tok-fn">run</span>(self: *<span class="tok-builtin">@This</span>(), hit_to: *<span class="tok-builtin">@This</span>()) !<span class="tok-type">void</span> {</span>
<span class="line" id="L436">            self.mutex.lock();</span>
<span class="line" id="L437">            <span class="tok-kw">defer</span> self.mutex.unlock();</span>
<span class="line" id="L438"></span>
<span class="line" id="L439">            <span class="tok-kw">var</span> current: <span class="tok-type">u32</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L440">            <span class="tok-kw">while</span> (current &lt; num_iterations) : (current += <span class="tok-number">1</span>) {</span>
<span class="line" id="L441">                <span class="tok-comment">// Wait for the value to change from hit()</span>
</span>
<span class="line" id="L442">                <span class="tok-kw">while</span> (self.value == current) {</span>
<span class="line" id="L443">                    self.cond.wait(&amp;self.mutex);</span>
<span class="line" id="L444">                }</span>
<span class="line" id="L445"></span>
<span class="line" id="L446">                <span class="tok-comment">// hit the next paddle</span>
</span>
<span class="line" id="L447">                <span class="tok-kw">try</span> testing.expectEqual(self.value, current + <span class="tok-number">1</span>);</span>
<span class="line" id="L448">                hit_to.hit();</span>
<span class="line" id="L449">            }</span>
<span class="line" id="L450">        }</span>
<span class="line" id="L451">    };</span>
<span class="line" id="L452"></span>
<span class="line" id="L453">    <span class="tok-kw">var</span> paddles = [_]Paddle{.{}} ** num_threads;</span>
<span class="line" id="L454">    <span class="tok-kw">var</span> threads = [_]std.Thread{<span class="tok-null">undefined</span>} ** num_threads;</span>
<span class="line" id="L455"></span>
<span class="line" id="L456">    <span class="tok-comment">// Create a circle of paddles which hit each other</span>
</span>
<span class="line" id="L457">    <span class="tok-kw">for</span> (threads) |*t, i| {</span>
<span class="line" id="L458">        <span class="tok-kw">const</span> paddle = &amp;paddles[i];</span>
<span class="line" id="L459">        <span class="tok-kw">const</span> hit_to = &amp;paddles[(i + <span class="tok-number">1</span>) % paddles.len];</span>
<span class="line" id="L460">        t.* = <span class="tok-kw">try</span> std.Thread.spawn(.{}, Paddle.run, .{ paddle, hit_to });</span>
<span class="line" id="L461">    }</span>
<span class="line" id="L462"></span>
<span class="line" id="L463">    <span class="tok-comment">// Hit the first paddle and wait for them all to complete by hitting each other for num_iterations.</span>
</span>
<span class="line" id="L464">    paddles[<span class="tok-number">0</span>].hit();</span>
<span class="line" id="L465">    <span class="tok-kw">for</span> (threads) |t| t.join();</span>
<span class="line" id="L466"></span>
<span class="line" id="L467">    <span class="tok-comment">// The first paddle will be hit one last time by the last paddle.</span>
</span>
<span class="line" id="L468">    <span class="tok-kw">for</span> (paddles) |p, i| {</span>
<span class="line" id="L469">        <span class="tok-kw">const</span> expected = <span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, num_iterations) + <span class="tok-builtin">@boolToInt</span>(i == <span class="tok-number">0</span>);</span>
<span class="line" id="L470">        <span class="tok-kw">try</span> testing.expectEqual(p.value, expected);</span>
<span class="line" id="L471">    }</span>
<span class="line" id="L472">}</span>
<span class="line" id="L473"></span>
<span class="line" id="L474"><span class="tok-kw">test</span> <span class="tok-str">&quot;Condition - broadcasting&quot;</span> {</span>
<span class="line" id="L475">    <span class="tok-comment">// This test requires spawning threads</span>
</span>
<span class="line" id="L476">    <span class="tok-kw">if</span> (builtin.single_threaded) {</span>
<span class="line" id="L477">        <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SkipZigTest;</span>
<span class="line" id="L478">    }</span>
<span class="line" id="L479"></span>
<span class="line" id="L480">    <span class="tok-kw">const</span> num_threads = <span class="tok-number">10</span>;</span>
<span class="line" id="L481"></span>
<span class="line" id="L482">    <span class="tok-kw">const</span> BroadcastTest = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L483">        mutex: Mutex = .{},</span>
<span class="line" id="L484">        cond: Condition = .{},</span>
<span class="line" id="L485">        completed: Condition = .{},</span>
<span class="line" id="L486">        count: <span class="tok-type">usize</span> = <span class="tok-number">0</span>,</span>
<span class="line" id="L487">        threads: [num_threads]std.Thread = <span class="tok-null">undefined</span>,</span>
<span class="line" id="L488"></span>
<span class="line" id="L489">        <span class="tok-kw">fn</span> <span class="tok-fn">run</span>(self: *<span class="tok-builtin">@This</span>()) <span class="tok-type">void</span> {</span>
<span class="line" id="L490">            self.mutex.lock();</span>
<span class="line" id="L491">            <span class="tok-kw">defer</span> self.mutex.unlock();</span>
<span class="line" id="L492"></span>
<span class="line" id="L493">            <span class="tok-comment">// The last broadcast thread to start tells the main test thread it's completed.</span>
</span>
<span class="line" id="L494">            self.count += <span class="tok-number">1</span>;</span>
<span class="line" id="L495">            <span class="tok-kw">if</span> (self.count == num_threads) {</span>
<span class="line" id="L496">                self.completed.signal();</span>
<span class="line" id="L497">            }</span>
<span class="line" id="L498"></span>
<span class="line" id="L499">            <span class="tok-comment">// Waits for the count to reach zero after the main test thread observes it at num_threads.</span>
</span>
<span class="line" id="L500">            <span class="tok-comment">// Tries to use timedWait() a bit before falling back to wait() to test multiple threads timing out.</span>
</span>
<span class="line" id="L501">            <span class="tok-kw">var</span> i: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L502">            <span class="tok-kw">while</span> (self.count != <span class="tok-number">0</span>) : (i +%= <span class="tok-number">1</span>) {</span>
<span class="line" id="L503">                <span class="tok-kw">if</span> (i &lt; <span class="tok-number">10</span>) {</span>
<span class="line" id="L504">                    self.cond.timedWait(&amp;self.mutex, <span class="tok-number">1</span>) <span class="tok-kw">catch</span> {};</span>
<span class="line" id="L505">                } <span class="tok-kw">else</span> {</span>
<span class="line" id="L506">                    self.cond.wait(&amp;self.mutex);</span>
<span class="line" id="L507">                }</span>
<span class="line" id="L508">            }</span>
<span class="line" id="L509">        }</span>
<span class="line" id="L510">    };</span>
<span class="line" id="L511"></span>
<span class="line" id="L512">    <span class="tok-kw">var</span> broadcast_test = BroadcastTest{};</span>
<span class="line" id="L513">    <span class="tok-kw">for</span> (broadcast_test.threads) |*t| {</span>
<span class="line" id="L514">        t.* = <span class="tok-kw">try</span> std.Thread.spawn(.{}, BroadcastTest.run, .{&amp;broadcast_test});</span>
<span class="line" id="L515">    }</span>
<span class="line" id="L516"></span>
<span class="line" id="L517">    {</span>
<span class="line" id="L518">        broadcast_test.mutex.lock();</span>
<span class="line" id="L519">        <span class="tok-kw">defer</span> broadcast_test.mutex.unlock();</span>
<span class="line" id="L520"></span>
<span class="line" id="L521">        <span class="tok-comment">// Wait for all the broadcast threads to spawn.</span>
</span>
<span class="line" id="L522">        <span class="tok-comment">// timedWait() to detect any potential deadlocks.</span>
</span>
<span class="line" id="L523">        <span class="tok-kw">while</span> (broadcast_test.count != num_threads) {</span>
<span class="line" id="L524">            <span class="tok-kw">try</span> broadcast_test.completed.timedWait(</span>
<span class="line" id="L525">                &amp;broadcast_test.mutex,</span>
<span class="line" id="L526">                <span class="tok-number">1</span> * std.time.ns_per_s,</span>
<span class="line" id="L527">            );</span>
<span class="line" id="L528">        }</span>
<span class="line" id="L529"></span>
<span class="line" id="L530">        <span class="tok-comment">// Reset the counter and wake all the threads to exit.</span>
</span>
<span class="line" id="L531">        broadcast_test.count = <span class="tok-number">0</span>;</span>
<span class="line" id="L532">        broadcast_test.cond.broadcast();</span>
<span class="line" id="L533">    }</span>
<span class="line" id="L534"></span>
<span class="line" id="L535">    <span class="tok-kw">for</span> (broadcast_test.threads) |t| {</span>
<span class="line" id="L536">        t.join();</span>
<span class="line" id="L537">    }</span>
<span class="line" id="L538">}</span>
<span class="line" id="L539"></span>
</code></pre></body>
</html>