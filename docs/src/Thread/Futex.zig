<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">    <title>Thread/Futex.zig - source view</title>
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
<pre><code><span class="line" id="L1"><span class="tok-comment">//! Futex is a mechanism used to block (`wait`) and unblock (`wake`) threads using a 32bit memory address as hints.</span></span>
<span class="line" id="L2"><span class="tok-comment">//! Blocking a thread is acknowledged only if the 32bit memory address is equal to a given value.</span></span>
<span class="line" id="L3"><span class="tok-comment">//! This check helps avoid block/unblock deadlocks which occur if a `wake()` happens before a `wait()`.</span></span>
<span class="line" id="L4"><span class="tok-comment">//! Using Futex, other Thread synchronization primitives can be built which efficiently wait for cross-thread events or signals.</span></span>
<span class="line" id="L5"></span>
<span class="line" id="L6"><span class="tok-kw">const</span> std = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;../std.zig&quot;</span>);</span>
<span class="line" id="L7"><span class="tok-kw">const</span> builtin = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;builtin&quot;</span>);</span>
<span class="line" id="L8"><span class="tok-kw">const</span> Futex = <span class="tok-builtin">@This</span>();</span>
<span class="line" id="L9"></span>
<span class="line" id="L10"><span class="tok-kw">const</span> os = std.os;</span>
<span class="line" id="L11"><span class="tok-kw">const</span> assert = std.debug.assert;</span>
<span class="line" id="L12"><span class="tok-kw">const</span> testing = std.testing;</span>
<span class="line" id="L13"><span class="tok-kw">const</span> Atomic = std.atomic.Atomic;</span>
<span class="line" id="L14"></span>
<span class="line" id="L15"><span class="tok-comment">/// Checks if `ptr` still contains the value `expect` and, if so, blocks the caller until either:</span></span>
<span class="line" id="L16"><span class="tok-comment">/// - The value at `ptr` is no longer equal to `expect`.</span></span>
<span class="line" id="L17"><span class="tok-comment">/// - The caller is unblocked by a matching `wake()`.</span></span>
<span class="line" id="L18"><span class="tok-comment">/// - The caller is unblocked spuriously (&quot;at random&quot;).</span></span>
<span class="line" id="L19"><span class="tok-comment">///</span></span>
<span class="line" id="L20"><span class="tok-comment">/// The checking of `ptr` and `expect`, along with blocking the caller, is done atomically</span></span>
<span class="line" id="L21"><span class="tok-comment">/// and totally ordered (sequentially consistent) with respect to other wait()/wake() calls on the same `ptr`.</span></span>
<span class="line" id="L22"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">wait</span>(ptr: *<span class="tok-kw">const</span> Atomic(<span class="tok-type">u32</span>), expect: <span class="tok-type">u32</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L23">    <span class="tok-builtin">@setCold</span>(<span class="tok-null">true</span>);</span>
<span class="line" id="L24"></span>
<span class="line" id="L25">    Impl.wait(ptr, expect, <span class="tok-null">null</span>) <span class="tok-kw">catch</span> |err| <span class="tok-kw">switch</span> (err) {</span>
<span class="line" id="L26">        <span class="tok-kw">error</span>.Timeout =&gt; <span class="tok-kw">unreachable</span>, <span class="tok-comment">// null timeout meant to wait forever</span>
</span>
<span class="line" id="L27">    };</span>
<span class="line" id="L28">}</span>
<span class="line" id="L29"></span>
<span class="line" id="L30"><span class="tok-comment">/// Checks if `ptr` still contains the value `expect` and, if so, blocks the caller until either:</span></span>
<span class="line" id="L31"><span class="tok-comment">/// - The value at `ptr` is no longer equal to `expect`.</span></span>
<span class="line" id="L32"><span class="tok-comment">/// - The caller is unblocked by a matching `wake()`.</span></span>
<span class="line" id="L33"><span class="tok-comment">/// - The caller is unblocked spuriously (&quot;at random&quot;).</span></span>
<span class="line" id="L34"><span class="tok-comment">/// - The caller blocks for longer than the given timeout. In which case, `error.Timeout` is returned.</span></span>
<span class="line" id="L35"><span class="tok-comment">///</span></span>
<span class="line" id="L36"><span class="tok-comment">/// The checking of `ptr` and `expect`, along with blocking the caller, is done atomically</span></span>
<span class="line" id="L37"><span class="tok-comment">/// and totally ordered (sequentially consistent) with respect to other wait()/wake() calls on the same `ptr`.</span></span>
<span class="line" id="L38"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">timedWait</span>(ptr: *<span class="tok-kw">const</span> Atomic(<span class="tok-type">u32</span>), expect: <span class="tok-type">u32</span>, timeout_ns: <span class="tok-type">u64</span>) <span class="tok-kw">error</span>{Timeout}!<span class="tok-type">void</span> {</span>
<span class="line" id="L39">    <span class="tok-builtin">@setCold</span>(<span class="tok-null">true</span>);</span>
<span class="line" id="L40"></span>
<span class="line" id="L41">    <span class="tok-comment">// Avoid calling into the OS for no-op timeouts.</span>
</span>
<span class="line" id="L42">    <span class="tok-kw">if</span> (timeout_ns == <span class="tok-number">0</span>) {</span>
<span class="line" id="L43">        <span class="tok-kw">if</span> (ptr.load(.SeqCst) != expect) <span class="tok-kw">return</span>;</span>
<span class="line" id="L44">        <span class="tok-kw">return</span> <span class="tok-kw">error</span>.Timeout;</span>
<span class="line" id="L45">    }</span>
<span class="line" id="L46"></span>
<span class="line" id="L47">    <span class="tok-kw">return</span> Impl.wait(ptr, expect, timeout_ns);</span>
<span class="line" id="L48">}</span>
<span class="line" id="L49"></span>
<span class="line" id="L50"><span class="tok-comment">/// Unblocks at most `max_waiters` callers blocked in a `wait()` call on `ptr`.</span></span>
<span class="line" id="L51"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">wake</span>(ptr: *<span class="tok-kw">const</span> Atomic(<span class="tok-type">u32</span>), max_waiters: <span class="tok-type">u32</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L52">    <span class="tok-builtin">@setCold</span>(<span class="tok-null">true</span>);</span>
<span class="line" id="L53"></span>
<span class="line" id="L54">    <span class="tok-comment">// Avoid calling into the OS if there's nothing to wake up.</span>
</span>
<span class="line" id="L55">    <span class="tok-kw">if</span> (max_waiters == <span class="tok-number">0</span>) {</span>
<span class="line" id="L56">        <span class="tok-kw">return</span>;</span>
<span class="line" id="L57">    }</span>
<span class="line" id="L58"></span>
<span class="line" id="L59">    Impl.wake(ptr, max_waiters);</span>
<span class="line" id="L60">}</span>
<span class="line" id="L61"></span>
<span class="line" id="L62"><span class="tok-kw">const</span> Impl = <span class="tok-kw">if</span> (builtin.single_threaded)</span>
<span class="line" id="L63">    SingleThreadedImpl</span>
<span class="line" id="L64"><span class="tok-kw">else</span> <span class="tok-kw">if</span> (builtin.os.tag == .windows)</span>
<span class="line" id="L65">    WindowsImpl</span>
<span class="line" id="L66"><span class="tok-kw">else</span> <span class="tok-kw">if</span> (builtin.os.tag.isDarwin())</span>
<span class="line" id="L67">    DarwinImpl</span>
<span class="line" id="L68"><span class="tok-kw">else</span> <span class="tok-kw">if</span> (builtin.os.tag == .linux)</span>
<span class="line" id="L69">    LinuxImpl</span>
<span class="line" id="L70"><span class="tok-kw">else</span> <span class="tok-kw">if</span> (builtin.os.tag == .freebsd)</span>
<span class="line" id="L71">    FreebsdImpl</span>
<span class="line" id="L72"><span class="tok-kw">else</span> <span class="tok-kw">if</span> (builtin.os.tag == .openbsd)</span>
<span class="line" id="L73">    OpenbsdImpl</span>
<span class="line" id="L74"><span class="tok-kw">else</span> <span class="tok-kw">if</span> (builtin.os.tag == .dragonfly)</span>
<span class="line" id="L75">    DragonflyImpl</span>
<span class="line" id="L76"><span class="tok-kw">else</span> <span class="tok-kw">if</span> (std.Thread.use_pthreads)</span>
<span class="line" id="L77">    PosixImpl</span>
<span class="line" id="L78"><span class="tok-kw">else</span></span>
<span class="line" id="L79">    UnsupportedImpl;</span>
<span class="line" id="L80"></span>
<span class="line" id="L81"><span class="tok-comment">/// We can't do @compileError() in the `Impl` switch statement above as its eagerly evaluated.</span></span>
<span class="line" id="L82"><span class="tok-comment">/// So instead, we @compileError() on the methods themselves for platforms which don't support futex.</span></span>
<span class="line" id="L83"><span class="tok-kw">const</span> UnsupportedImpl = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L84">    <span class="tok-kw">fn</span> <span class="tok-fn">wait</span>(ptr: *<span class="tok-kw">const</span> Atomic(<span class="tok-type">u32</span>), expect: <span class="tok-type">u32</span>, timeout: ?<span class="tok-type">u64</span>) <span class="tok-kw">error</span>{Timeout}!<span class="tok-type">void</span> {</span>
<span class="line" id="L85">        <span class="tok-kw">return</span> unsupported(.{ ptr, expect, timeout });</span>
<span class="line" id="L86">    }</span>
<span class="line" id="L87"></span>
<span class="line" id="L88">    <span class="tok-kw">fn</span> <span class="tok-fn">wake</span>(ptr: *<span class="tok-kw">const</span> Atomic(<span class="tok-type">u32</span>), max_waiters: <span class="tok-type">u32</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L89">        <span class="tok-kw">return</span> unsupported(.{ ptr, max_waiters });</span>
<span class="line" id="L90">    }</span>
<span class="line" id="L91"></span>
<span class="line" id="L92">    <span class="tok-kw">fn</span> <span class="tok-fn">unsupported</span>(unused: <span class="tok-kw">anytype</span>) <span class="tok-type">noreturn</span> {</span>
<span class="line" id="L93">        _ = unused;</span>
<span class="line" id="L94">        <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;Unsupported operating system &quot;</span> ++ <span class="tok-builtin">@tagName</span>(builtin.target.os.tag));</span>
<span class="line" id="L95">    }</span>
<span class="line" id="L96">};</span>
<span class="line" id="L97"></span>
<span class="line" id="L98"><span class="tok-kw">const</span> SingleThreadedImpl = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L99">    <span class="tok-kw">fn</span> <span class="tok-fn">wait</span>(ptr: *<span class="tok-kw">const</span> Atomic(<span class="tok-type">u32</span>), expect: <span class="tok-type">u32</span>, timeout: ?<span class="tok-type">u64</span>) <span class="tok-kw">error</span>{Timeout}!<span class="tok-type">void</span> {</span>
<span class="line" id="L100">        <span class="tok-kw">if</span> (ptr.loadUnchecked() != expect) {</span>
<span class="line" id="L101">            <span class="tok-kw">return</span>;</span>
<span class="line" id="L102">        }</span>
<span class="line" id="L103"></span>
<span class="line" id="L104">        <span class="tok-comment">// There are no threads to wake us up.</span>
</span>
<span class="line" id="L105">        <span class="tok-comment">// So if we wait without a timeout we would never wake up.</span>
</span>
<span class="line" id="L106">        <span class="tok-kw">const</span> delay = timeout <span class="tok-kw">orelse</span> {</span>
<span class="line" id="L107">            <span class="tok-kw">unreachable</span>; <span class="tok-comment">// deadlock detected</span>
</span>
<span class="line" id="L108">        };</span>
<span class="line" id="L109"></span>
<span class="line" id="L110">        std.time.sleep(delay);</span>
<span class="line" id="L111">        <span class="tok-kw">return</span> <span class="tok-kw">error</span>.Timeout;</span>
<span class="line" id="L112">    }</span>
<span class="line" id="L113"></span>
<span class="line" id="L114">    <span class="tok-kw">fn</span> <span class="tok-fn">wake</span>(ptr: *<span class="tok-kw">const</span> Atomic(<span class="tok-type">u32</span>), max_waiters: <span class="tok-type">u32</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L115">        <span class="tok-comment">// There are no other threads to possibly wake up</span>
</span>
<span class="line" id="L116">        _ = ptr;</span>
<span class="line" id="L117">        _ = max_waiters;</span>
<span class="line" id="L118">    }</span>
<span class="line" id="L119">};</span>
<span class="line" id="L120"></span>
<span class="line" id="L121"><span class="tok-comment">// We use WaitOnAddress through NtDll instead of API-MS-Win-Core-Synch-l1-2-0.dll</span>
</span>
<span class="line" id="L122"><span class="tok-comment">// as it's generally already a linked target and is autoloaded into all processes anyway.</span>
</span>
<span class="line" id="L123"><span class="tok-kw">const</span> WindowsImpl = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L124">    <span class="tok-kw">fn</span> <span class="tok-fn">wait</span>(ptr: *<span class="tok-kw">const</span> Atomic(<span class="tok-type">u32</span>), expect: <span class="tok-type">u32</span>, timeout: ?<span class="tok-type">u64</span>) <span class="tok-kw">error</span>{Timeout}!<span class="tok-type">void</span> {</span>
<span class="line" id="L125">        <span class="tok-kw">var</span> timeout_value: os.windows.LARGE_INTEGER = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L126">        <span class="tok-kw">var</span> timeout_ptr: ?*<span class="tok-kw">const</span> os.windows.LARGE_INTEGER = <span class="tok-null">null</span>;</span>
<span class="line" id="L127"></span>
<span class="line" id="L128">        <span class="tok-comment">// NTDLL functions work with time in units of 100 nanoseconds.</span>
</span>
<span class="line" id="L129">        <span class="tok-comment">// Positive values are absolute deadlines while negative values are relative durations.</span>
</span>
<span class="line" id="L130">        <span class="tok-kw">if</span> (timeout) |delay| {</span>
<span class="line" id="L131">            timeout_value = <span class="tok-builtin">@intCast</span>(os.windows.LARGE_INTEGER, delay / <span class="tok-number">100</span>);</span>
<span class="line" id="L132">            timeout_value = -timeout_value;</span>
<span class="line" id="L133">            timeout_ptr = &amp;timeout_value;</span>
<span class="line" id="L134">        }</span>
<span class="line" id="L135"></span>
<span class="line" id="L136">        <span class="tok-kw">const</span> rc = os.windows.ntdll.RtlWaitOnAddress(</span>
<span class="line" id="L137">            <span class="tok-builtin">@ptrCast</span>(?*<span class="tok-kw">const</span> <span class="tok-type">anyopaque</span>, ptr),</span>
<span class="line" id="L138">            <span class="tok-builtin">@ptrCast</span>(?*<span class="tok-kw">const</span> <span class="tok-type">anyopaque</span>, &amp;expect),</span>
<span class="line" id="L139">            <span class="tok-builtin">@sizeOf</span>(<span class="tok-builtin">@TypeOf</span>(expect)),</span>
<span class="line" id="L140">            timeout_ptr,</span>
<span class="line" id="L141">        );</span>
<span class="line" id="L142"></span>
<span class="line" id="L143">        <span class="tok-kw">switch</span> (rc) {</span>
<span class="line" id="L144">            .SUCCESS =&gt; {},</span>
<span class="line" id="L145">            .TIMEOUT =&gt; {</span>
<span class="line" id="L146">                assert(timeout != <span class="tok-null">null</span>);</span>
<span class="line" id="L147">                <span class="tok-kw">return</span> <span class="tok-kw">error</span>.Timeout;</span>
<span class="line" id="L148">            },</span>
<span class="line" id="L149">            <span class="tok-kw">else</span> =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L150">        }</span>
<span class="line" id="L151">    }</span>
<span class="line" id="L152"></span>
<span class="line" id="L153">    <span class="tok-kw">fn</span> <span class="tok-fn">wake</span>(ptr: *<span class="tok-kw">const</span> Atomic(<span class="tok-type">u32</span>), max_waiters: <span class="tok-type">u32</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L154">        <span class="tok-kw">const</span> address = <span class="tok-builtin">@ptrCast</span>(?*<span class="tok-kw">const</span> <span class="tok-type">anyopaque</span>, ptr);</span>
<span class="line" id="L155">        assert(max_waiters != <span class="tok-number">0</span>);</span>
<span class="line" id="L156"></span>
<span class="line" id="L157">        <span class="tok-kw">switch</span> (max_waiters) {</span>
<span class="line" id="L158">            <span class="tok-number">1</span> =&gt; os.windows.ntdll.RtlWakeAddressSingle(address),</span>
<span class="line" id="L159">            <span class="tok-kw">else</span> =&gt; os.windows.ntdll.RtlWakeAddressAll(address),</span>
<span class="line" id="L160">        }</span>
<span class="line" id="L161">    }</span>
<span class="line" id="L162">};</span>
<span class="line" id="L163"></span>
<span class="line" id="L164"><span class="tok-kw">const</span> DarwinImpl = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L165">    <span class="tok-kw">fn</span> <span class="tok-fn">wait</span>(ptr: *<span class="tok-kw">const</span> Atomic(<span class="tok-type">u32</span>), expect: <span class="tok-type">u32</span>, timeout: ?<span class="tok-type">u64</span>) <span class="tok-kw">error</span>{Timeout}!<span class="tok-type">void</span> {</span>
<span class="line" id="L166">        <span class="tok-comment">// Darwin XNU 7195.50.7.100.1 introduced __ulock_wait2 and migrated code paths (notably pthread_cond_t) towards it:</span>
</span>
<span class="line" id="L167">        <span class="tok-comment">// https://github.com/apple/darwin-xnu/commit/d4061fb0260b3ed486147341b72468f836ed6c8f#diff-08f993cc40af475663274687b7c326cc6c3031e0db3ac8de7b24624610616be6</span>
</span>
<span class="line" id="L168">        <span class="tok-comment">//</span>
</span>
<span class="line" id="L169">        <span class="tok-comment">// This XNU version appears to correspond to 11.0.1:</span>
</span>
<span class="line" id="L170">        <span class="tok-comment">// https://kernelshaman.blogspot.com/2021/01/building-xnu-for-macos-big-sur-1101.html</span>
</span>
<span class="line" id="L171">        <span class="tok-comment">//</span>
</span>
<span class="line" id="L172">        <span class="tok-comment">// ulock_wait() uses 32-bit micro-second timeouts where 0 = INFINITE or no-timeout</span>
</span>
<span class="line" id="L173">        <span class="tok-comment">// ulock_wait2() uses 64-bit nano-second timeouts (with the same convention)</span>
</span>
<span class="line" id="L174">        <span class="tok-kw">const</span> supports_ulock_wait2 = builtin.target.os.version_range.semver.min.major &gt;= <span class="tok-number">11</span>;</span>
<span class="line" id="L175"></span>
<span class="line" id="L176">        <span class="tok-kw">var</span> timeout_ns: <span class="tok-type">u64</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L177">        <span class="tok-kw">if</span> (timeout) |delay| {</span>
<span class="line" id="L178">            assert(delay != <span class="tok-number">0</span>); <span class="tok-comment">// handled by timedWait()</span>
</span>
<span class="line" id="L179">            timeout_ns = delay;</span>
<span class="line" id="L180">        }</span>
<span class="line" id="L181"></span>
<span class="line" id="L182">        <span class="tok-comment">// If we're using `__ulock_wait` and `timeout` is too big to fit inside a `u32` count of</span>
</span>
<span class="line" id="L183">        <span class="tok-comment">// micro-seconds (around 70min), we'll request a shorter timeout. This is fine (users</span>
</span>
<span class="line" id="L184">        <span class="tok-comment">// should handle spurious wakeups), but we need to remember that we did so, so that</span>
</span>
<span class="line" id="L185">        <span class="tok-comment">// we don't return `Timeout` incorrectly. If that happens, we set this variable to</span>
</span>
<span class="line" id="L186">        <span class="tok-comment">// true so that we we know to ignore the ETIMEDOUT result.</span>
</span>
<span class="line" id="L187">        <span class="tok-kw">var</span> timeout_overflowed = <span class="tok-null">false</span>;</span>
<span class="line" id="L188"></span>
<span class="line" id="L189">        <span class="tok-kw">const</span> addr = <span class="tok-builtin">@ptrCast</span>(*<span class="tok-kw">const</span> <span class="tok-type">anyopaque</span>, ptr);</span>
<span class="line" id="L190">        <span class="tok-kw">const</span> flags = os.darwin.UL_COMPARE_AND_WAIT | os.darwin.ULF_NO_ERRNO;</span>
<span class="line" id="L191">        <span class="tok-kw">const</span> status = blk: {</span>
<span class="line" id="L192">            <span class="tok-kw">if</span> (supports_ulock_wait2) {</span>
<span class="line" id="L193">                <span class="tok-kw">break</span> :blk os.darwin.__ulock_wait2(flags, addr, expect, timeout_ns, <span class="tok-number">0</span>);</span>
<span class="line" id="L194">            }</span>
<span class="line" id="L195"></span>
<span class="line" id="L196">            <span class="tok-kw">const</span> timeout_us = std.math.cast(<span class="tok-type">u32</span>, timeout_ns / std.time.ns_per_us) <span class="tok-kw">orelse</span> overflow: {</span>
<span class="line" id="L197">                timeout_overflowed = <span class="tok-null">true</span>;</span>
<span class="line" id="L198">                <span class="tok-kw">break</span> :overflow std.math.maxInt(<span class="tok-type">u32</span>);</span>
<span class="line" id="L199">            };</span>
<span class="line" id="L200"></span>
<span class="line" id="L201">            <span class="tok-kw">break</span> :blk os.darwin.__ulock_wait(flags, addr, expect, timeout_us);</span>
<span class="line" id="L202">        };</span>
<span class="line" id="L203"></span>
<span class="line" id="L204">        <span class="tok-kw">if</span> (status &gt;= <span class="tok-number">0</span>) <span class="tok-kw">return</span>;</span>
<span class="line" id="L205">        <span class="tok-kw">switch</span> (<span class="tok-builtin">@intToEnum</span>(std.os.E, -status)) {</span>
<span class="line" id="L206">            <span class="tok-comment">// Wait was interrupted by the OS or other spurious signalling.</span>
</span>
<span class="line" id="L207">            .INTR =&gt; {},</span>
<span class="line" id="L208">            <span class="tok-comment">// Address of the futex was paged out. This is unlikely, but possible in theory, and</span>
</span>
<span class="line" id="L209">            <span class="tok-comment">// pthread/libdispatch on darwin bother to handle it. In this case we'll return</span>
</span>
<span class="line" id="L210">            <span class="tok-comment">// without waiting, but the caller should retry anyway.</span>
</span>
<span class="line" id="L211">            .FAULT =&gt; {},</span>
<span class="line" id="L212">            <span class="tok-comment">// Only report Timeout if we didn't have to cap the timeout</span>
</span>
<span class="line" id="L213">            .TIMEDOUT =&gt; {</span>
<span class="line" id="L214">                assert(timeout != <span class="tok-null">null</span>);</span>
<span class="line" id="L215">                <span class="tok-kw">if</span> (!timeout_overflowed) <span class="tok-kw">return</span> <span class="tok-kw">error</span>.Timeout;</span>
<span class="line" id="L216">            },</span>
<span class="line" id="L217">            <span class="tok-kw">else</span> =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L218">        }</span>
<span class="line" id="L219">    }</span>
<span class="line" id="L220"></span>
<span class="line" id="L221">    <span class="tok-kw">fn</span> <span class="tok-fn">wake</span>(ptr: *<span class="tok-kw">const</span> Atomic(<span class="tok-type">u32</span>), max_waiters: <span class="tok-type">u32</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L222">        <span class="tok-kw">var</span> flags: <span class="tok-type">u32</span> = os.darwin.UL_COMPARE_AND_WAIT | os.darwin.ULF_NO_ERRNO;</span>
<span class="line" id="L223">        <span class="tok-kw">if</span> (max_waiters &gt; <span class="tok-number">1</span>) {</span>
<span class="line" id="L224">            flags |= os.darwin.ULF_WAKE_ALL;</span>
<span class="line" id="L225">        }</span>
<span class="line" id="L226"></span>
<span class="line" id="L227">        <span class="tok-kw">while</span> (<span class="tok-null">true</span>) {</span>
<span class="line" id="L228">            <span class="tok-kw">const</span> addr = <span class="tok-builtin">@ptrCast</span>(*<span class="tok-kw">const</span> <span class="tok-type">anyopaque</span>, ptr);</span>
<span class="line" id="L229">            <span class="tok-kw">const</span> status = os.darwin.__ulock_wake(flags, addr, <span class="tok-number">0</span>);</span>
<span class="line" id="L230"></span>
<span class="line" id="L231">            <span class="tok-kw">if</span> (status &gt;= <span class="tok-number">0</span>) <span class="tok-kw">return</span>;</span>
<span class="line" id="L232">            <span class="tok-kw">switch</span> (<span class="tok-builtin">@intToEnum</span>(std.os.E, -status)) {</span>
<span class="line" id="L233">                .INTR =&gt; <span class="tok-kw">continue</span>, <span class="tok-comment">// spurious wake()</span>
</span>
<span class="line" id="L234">                .FAULT =&gt; <span class="tok-kw">unreachable</span>, <span class="tok-comment">// __ulock_wake doesn't generate EFAULT according to darwin pthread_cond_t</span>
</span>
<span class="line" id="L235">                .NOENT =&gt; <span class="tok-kw">return</span>, <span class="tok-comment">// nothing was woken up</span>
</span>
<span class="line" id="L236">                .ALREADY =&gt; <span class="tok-kw">unreachable</span>, <span class="tok-comment">// only for ULF_WAKE_THREAD</span>
</span>
<span class="line" id="L237">                <span class="tok-kw">else</span> =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L238">            }</span>
<span class="line" id="L239">        }</span>
<span class="line" id="L240">    }</span>
<span class="line" id="L241">};</span>
<span class="line" id="L242"></span>
<span class="line" id="L243"><span class="tok-comment">// https://man7.org/linux/man-pages/man2/futex.2.html</span>
</span>
<span class="line" id="L244"><span class="tok-kw">const</span> LinuxImpl = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L245">    <span class="tok-kw">fn</span> <span class="tok-fn">wait</span>(ptr: *<span class="tok-kw">const</span> Atomic(<span class="tok-type">u32</span>), expect: <span class="tok-type">u32</span>, timeout: ?<span class="tok-type">u64</span>) <span class="tok-kw">error</span>{Timeout}!<span class="tok-type">void</span> {</span>
<span class="line" id="L246">        <span class="tok-kw">var</span> ts: os.timespec = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L247">        <span class="tok-kw">if</span> (timeout) |timeout_ns| {</span>
<span class="line" id="L248">            ts.tv_sec = <span class="tok-builtin">@intCast</span>(<span class="tok-builtin">@TypeOf</span>(ts.tv_sec), timeout_ns / std.time.ns_per_s);</span>
<span class="line" id="L249">            ts.tv_nsec = <span class="tok-builtin">@intCast</span>(<span class="tok-builtin">@TypeOf</span>(ts.tv_nsec), timeout_ns % std.time.ns_per_s);</span>
<span class="line" id="L250">        }</span>
<span class="line" id="L251"></span>
<span class="line" id="L252">        <span class="tok-kw">const</span> rc = os.linux.futex_wait(</span>
<span class="line" id="L253">            <span class="tok-builtin">@ptrCast</span>(*<span class="tok-kw">const</span> <span class="tok-type">i32</span>, &amp;ptr.value),</span>
<span class="line" id="L254">            os.linux.FUTEX.PRIVATE_FLAG | os.linux.FUTEX.WAIT,</span>
<span class="line" id="L255">            <span class="tok-builtin">@bitCast</span>(<span class="tok-type">i32</span>, expect),</span>
<span class="line" id="L256">            <span class="tok-kw">if</span> (timeout != <span class="tok-null">null</span>) &amp;ts <span class="tok-kw">else</span> <span class="tok-null">null</span>,</span>
<span class="line" id="L257">        );</span>
<span class="line" id="L258"></span>
<span class="line" id="L259">        <span class="tok-kw">switch</span> (os.linux.getErrno(rc)) {</span>
<span class="line" id="L260">            .SUCCESS =&gt; {}, <span class="tok-comment">// notified by `wake()`</span>
</span>
<span class="line" id="L261">            .INTR =&gt; {}, <span class="tok-comment">// spurious wakeup</span>
</span>
<span class="line" id="L262">            .AGAIN =&gt; {}, <span class="tok-comment">// ptr.* != expect</span>
</span>
<span class="line" id="L263">            .TIMEDOUT =&gt; {</span>
<span class="line" id="L264">                assert(timeout != <span class="tok-null">null</span>);</span>
<span class="line" id="L265">                <span class="tok-kw">return</span> <span class="tok-kw">error</span>.Timeout;</span>
<span class="line" id="L266">            },</span>
<span class="line" id="L267">            .INVAL =&gt; {}, <span class="tok-comment">// possibly timeout overflow</span>
</span>
<span class="line" id="L268">            .FAULT =&gt; <span class="tok-kw">unreachable</span>, <span class="tok-comment">// ptr was invalid</span>
</span>
<span class="line" id="L269">            <span class="tok-kw">else</span> =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L270">        }</span>
<span class="line" id="L271">    }</span>
<span class="line" id="L272"></span>
<span class="line" id="L273">    <span class="tok-kw">fn</span> <span class="tok-fn">wake</span>(ptr: *<span class="tok-kw">const</span> Atomic(<span class="tok-type">u32</span>), max_waiters: <span class="tok-type">u32</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L274">        <span class="tok-kw">const</span> rc = os.linux.futex_wake(</span>
<span class="line" id="L275">            <span class="tok-builtin">@ptrCast</span>(*<span class="tok-kw">const</span> <span class="tok-type">i32</span>, &amp;ptr.value),</span>
<span class="line" id="L276">            os.linux.FUTEX.PRIVATE_FLAG | os.linux.FUTEX.WAKE,</span>
<span class="line" id="L277">            std.math.cast(<span class="tok-type">i32</span>, max_waiters) <span class="tok-kw">orelse</span> std.math.maxInt(<span class="tok-type">i32</span>),</span>
<span class="line" id="L278">        );</span>
<span class="line" id="L279"></span>
<span class="line" id="L280">        <span class="tok-kw">switch</span> (os.linux.getErrno(rc)) {</span>
<span class="line" id="L281">            .SUCCESS =&gt; {}, <span class="tok-comment">// successful wake up</span>
</span>
<span class="line" id="L282">            .INVAL =&gt; {}, <span class="tok-comment">// invalid futex_wait() on ptr done elsewhere</span>
</span>
<span class="line" id="L283">            .FAULT =&gt; {}, <span class="tok-comment">// pointer became invalid while doing the wake</span>
</span>
<span class="line" id="L284">            <span class="tok-kw">else</span> =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L285">        }</span>
<span class="line" id="L286">    }</span>
<span class="line" id="L287">};</span>
<span class="line" id="L288"></span>
<span class="line" id="L289"><span class="tok-comment">// https://www.freebsd.org/cgi/man.cgi?query=_umtx_op&amp;sektion=2&amp;n=1</span>
</span>
<span class="line" id="L290"><span class="tok-kw">const</span> FreebsdImpl = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L291">    <span class="tok-kw">fn</span> <span class="tok-fn">wait</span>(ptr: *<span class="tok-kw">const</span> Atomic(<span class="tok-type">u32</span>), expect: <span class="tok-type">u32</span>, timeout: ?<span class="tok-type">u64</span>) <span class="tok-kw">error</span>{Timeout}!<span class="tok-type">void</span> {</span>
<span class="line" id="L292">        <span class="tok-kw">var</span> tm_size: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L293">        <span class="tok-kw">var</span> tm: os.freebsd._umtx_time = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L294">        <span class="tok-kw">var</span> tm_ptr: ?*<span class="tok-kw">const</span> os.freebsd._umtx_time = <span class="tok-null">null</span>;</span>
<span class="line" id="L295"></span>
<span class="line" id="L296">        <span class="tok-kw">if</span> (timeout) |timeout_ns| {</span>
<span class="line" id="L297">            tm_ptr = &amp;tm;</span>
<span class="line" id="L298">            tm_size = <span class="tok-builtin">@sizeOf</span>(<span class="tok-builtin">@TypeOf</span>(tm));</span>
<span class="line" id="L299"></span>
<span class="line" id="L300">            tm._flags = <span class="tok-number">0</span>; <span class="tok-comment">// use relative time not UMTX_ABSTIME</span>
</span>
<span class="line" id="L301">            tm._clockid = os.CLOCK.MONOTONIC;</span>
<span class="line" id="L302">            tm._timeout.tv_sec = <span class="tok-builtin">@intCast</span>(<span class="tok-builtin">@TypeOf</span>(tm._timeout.tv_sec), timeout_ns / std.time.ns_per_s);</span>
<span class="line" id="L303">            tm._timeout.tv_nsec = <span class="tok-builtin">@intCast</span>(<span class="tok-builtin">@TypeOf</span>(tm._timeout.tv_nsec), timeout_ns % std.time.ns_per_s);</span>
<span class="line" id="L304">        }</span>
<span class="line" id="L305"></span>
<span class="line" id="L306">        <span class="tok-kw">const</span> rc = os.freebsd._umtx_op(</span>
<span class="line" id="L307">            <span class="tok-builtin">@ptrToInt</span>(&amp;ptr.value),</span>
<span class="line" id="L308">            <span class="tok-builtin">@enumToInt</span>(os.freebsd.UMTX_OP.WAIT_UINT_PRIVATE),</span>
<span class="line" id="L309">            <span class="tok-builtin">@as</span>(<span class="tok-type">c_ulong</span>, expect),</span>
<span class="line" id="L310">            tm_size,</span>
<span class="line" id="L311">            <span class="tok-builtin">@ptrToInt</span>(tm_ptr),</span>
<span class="line" id="L312">        );</span>
<span class="line" id="L313"></span>
<span class="line" id="L314">        <span class="tok-kw">switch</span> (os.errno(rc)) {</span>
<span class="line" id="L315">            .SUCCESS =&gt; {},</span>
<span class="line" id="L316">            .FAULT =&gt; <span class="tok-kw">unreachable</span>, <span class="tok-comment">// one of the args points to invalid memory</span>
</span>
<span class="line" id="L317">            .INVAL =&gt; <span class="tok-kw">unreachable</span>, <span class="tok-comment">// arguments should be correct</span>
</span>
<span class="line" id="L318">            .TIMEDOUT =&gt; {</span>
<span class="line" id="L319">                assert(timeout != <span class="tok-null">null</span>);</span>
<span class="line" id="L320">                <span class="tok-kw">return</span> <span class="tok-kw">error</span>.Timeout;</span>
<span class="line" id="L321">            },</span>
<span class="line" id="L322">            .INTR =&gt; {}, <span class="tok-comment">// spurious wake</span>
</span>
<span class="line" id="L323">            <span class="tok-kw">else</span> =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L324">        }</span>
<span class="line" id="L325">    }</span>
<span class="line" id="L326"></span>
<span class="line" id="L327">    <span class="tok-kw">fn</span> <span class="tok-fn">wake</span>(ptr: *<span class="tok-kw">const</span> Atomic(<span class="tok-type">u32</span>), max_waiters: <span class="tok-type">u32</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L328">        <span class="tok-kw">const</span> rc = os.freebsd._umtx_op(</span>
<span class="line" id="L329">            <span class="tok-builtin">@ptrToInt</span>(&amp;ptr.value),</span>
<span class="line" id="L330">            <span class="tok-builtin">@enumToInt</span>(os.freebsd.UMTX_OP.WAKE_PRIVATE),</span>
<span class="line" id="L331">            <span class="tok-builtin">@as</span>(<span class="tok-type">c_ulong</span>, max_waiters),</span>
<span class="line" id="L332">            <span class="tok-number">0</span>, <span class="tok-comment">// there is no timeout struct</span>
</span>
<span class="line" id="L333">            <span class="tok-number">0</span>, <span class="tok-comment">// there is no timeout struct pointer</span>
</span>
<span class="line" id="L334">        );</span>
<span class="line" id="L335"></span>
<span class="line" id="L336">        <span class="tok-kw">switch</span> (os.errno(rc)) {</span>
<span class="line" id="L337">            .SUCCESS =&gt; {},</span>
<span class="line" id="L338">            .FAULT =&gt; {}, <span class="tok-comment">// it's ok if the ptr doesn't point to valid memory</span>
</span>
<span class="line" id="L339">            .INVAL =&gt; <span class="tok-kw">unreachable</span>, <span class="tok-comment">// arguments should be correct</span>
</span>
<span class="line" id="L340">            <span class="tok-kw">else</span> =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L341">        }</span>
<span class="line" id="L342">    }</span>
<span class="line" id="L343">};</span>
<span class="line" id="L344"></span>
<span class="line" id="L345"><span class="tok-comment">// https://man.openbsd.org/futex.2</span>
</span>
<span class="line" id="L346"><span class="tok-kw">const</span> OpenbsdImpl = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L347">    <span class="tok-kw">fn</span> <span class="tok-fn">wait</span>(ptr: *<span class="tok-kw">const</span> Atomic(<span class="tok-type">u32</span>), expect: <span class="tok-type">u32</span>, timeout: ?<span class="tok-type">u64</span>) <span class="tok-kw">error</span>{Timeout}!<span class="tok-type">void</span> {</span>
<span class="line" id="L348">        <span class="tok-kw">var</span> ts: os.timespec = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L349">        <span class="tok-kw">if</span> (timeout) |timeout_ns| {</span>
<span class="line" id="L350">            ts.tv_sec = <span class="tok-builtin">@intCast</span>(<span class="tok-builtin">@TypeOf</span>(ts.tv_sec), timeout_ns / std.time.ns_per_s);</span>
<span class="line" id="L351">            ts.tv_nsec = <span class="tok-builtin">@intCast</span>(<span class="tok-builtin">@TypeOf</span>(ts.tv_nsec), timeout_ns % std.time.ns_per_s);</span>
<span class="line" id="L352">        }</span>
<span class="line" id="L353"></span>
<span class="line" id="L354">        <span class="tok-kw">const</span> rc = os.openbsd.futex(</span>
<span class="line" id="L355">            <span class="tok-builtin">@ptrCast</span>(*<span class="tok-kw">const</span> <span class="tok-kw">volatile</span> <span class="tok-type">u32</span>, &amp;ptr.value),</span>
<span class="line" id="L356">            os.openbsd.FUTEX_WAIT | os.openbsd.FUTEX_PRIVATE_FLAG,</span>
<span class="line" id="L357">            <span class="tok-builtin">@bitCast</span>(<span class="tok-type">c_int</span>, expect),</span>
<span class="line" id="L358">            <span class="tok-kw">if</span> (timeout != <span class="tok-null">null</span>) &amp;ts <span class="tok-kw">else</span> <span class="tok-null">null</span>,</span>
<span class="line" id="L359">            <span class="tok-null">null</span>, <span class="tok-comment">// FUTEX_WAIT takes no requeue address</span>
</span>
<span class="line" id="L360">        );</span>
<span class="line" id="L361"></span>
<span class="line" id="L362">        <span class="tok-kw">switch</span> (os.errno(rc)) {</span>
<span class="line" id="L363">            .SUCCESS =&gt; {}, <span class="tok-comment">// woken up by wake</span>
</span>
<span class="line" id="L364">            .NOSYS =&gt; <span class="tok-kw">unreachable</span>, <span class="tok-comment">// the futex operation shouldn't be invalid</span>
</span>
<span class="line" id="L365">            .FAULT =&gt; <span class="tok-kw">unreachable</span>, <span class="tok-comment">// ptr was invalid</span>
</span>
<span class="line" id="L366">            .AGAIN =&gt; {}, <span class="tok-comment">// ptr != expect</span>
</span>
<span class="line" id="L367">            .INVAL =&gt; <span class="tok-kw">unreachable</span>, <span class="tok-comment">// invalid timeout</span>
</span>
<span class="line" id="L368">            .TIMEDOUT =&gt; {</span>
<span class="line" id="L369">                assert(timeout != <span class="tok-null">null</span>);</span>
<span class="line" id="L370">                <span class="tok-kw">return</span> <span class="tok-kw">error</span>.Timeout;</span>
<span class="line" id="L371">            },</span>
<span class="line" id="L372">            .INTR =&gt; {}, <span class="tok-comment">// spurious wake from signal</span>
</span>
<span class="line" id="L373">            .CANCELED =&gt; {}, <span class="tok-comment">// spurious wake from signal with SA_RESTART</span>
</span>
<span class="line" id="L374">            <span class="tok-kw">else</span> =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L375">        }</span>
<span class="line" id="L376">    }</span>
<span class="line" id="L377"></span>
<span class="line" id="L378">    <span class="tok-kw">fn</span> <span class="tok-fn">wake</span>(ptr: *<span class="tok-kw">const</span> Atomic(<span class="tok-type">u32</span>), max_waiters: <span class="tok-type">u32</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L379">        <span class="tok-kw">const</span> rc = os.openbsd.futex(</span>
<span class="line" id="L380">            <span class="tok-builtin">@ptrCast</span>(*<span class="tok-kw">const</span> <span class="tok-kw">volatile</span> <span class="tok-type">u32</span>, &amp;ptr.value),</span>
<span class="line" id="L381">            os.openbsd.FUTEX_WAKE | os.openbsd.FUTEX_PRIVATE_FLAG,</span>
<span class="line" id="L382">            std.math.cast(<span class="tok-type">c_int</span>, max_waiters) <span class="tok-kw">orelse</span> std.math.maxInt(<span class="tok-type">c_int</span>),</span>
<span class="line" id="L383">            <span class="tok-null">null</span>, <span class="tok-comment">// FUTEX_WAKE takes no timeout ptr</span>
</span>
<span class="line" id="L384">            <span class="tok-null">null</span>, <span class="tok-comment">// FUTEX_WAKE takes no requeue address</span>
</span>
<span class="line" id="L385">        );</span>
<span class="line" id="L386"></span>
<span class="line" id="L387">        <span class="tok-comment">// returns number of threads woken up.</span>
</span>
<span class="line" id="L388">        assert(rc &gt;= <span class="tok-number">0</span>);</span>
<span class="line" id="L389">    }</span>
<span class="line" id="L390">};</span>
<span class="line" id="L391"></span>
<span class="line" id="L392"><span class="tok-comment">// https://man.dragonflybsd.org/?command=umtx&amp;section=2</span>
</span>
<span class="line" id="L393"><span class="tok-kw">const</span> DragonflyImpl = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L394">    <span class="tok-kw">fn</span> <span class="tok-fn">wait</span>(ptr: *<span class="tok-kw">const</span> Atomic(<span class="tok-type">u32</span>), expect: <span class="tok-type">u32</span>, timeout: ?<span class="tok-type">u64</span>) <span class="tok-kw">error</span>{Timeout}!<span class="tok-type">void</span> {</span>
<span class="line" id="L395">        <span class="tok-comment">// Dragonfly uses a scheme where 0 timeout means wait until signaled or spurious wake.</span>
</span>
<span class="line" id="L396">        <span class="tok-comment">// It's reporting of timeout's is also unrealiable so we use an external timing source (Timer) instead.</span>
</span>
<span class="line" id="L397">        <span class="tok-kw">var</span> timeout_us: <span class="tok-type">c_int</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L398">        <span class="tok-kw">var</span> timeout_overflowed = <span class="tok-null">false</span>;</span>
<span class="line" id="L399">        <span class="tok-kw">var</span> sleep_timer: std.time.Timer = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L400"></span>
<span class="line" id="L401">        <span class="tok-kw">if</span> (timeout) |delay| {</span>
<span class="line" id="L402">            assert(delay != <span class="tok-number">0</span>); <span class="tok-comment">// handled by timedWait().</span>
</span>
<span class="line" id="L403">            timeout_us = std.math.cast(<span class="tok-type">c_int</span>, delay / std.time.ns_per_us) <span class="tok-kw">orelse</span> blk: {</span>
<span class="line" id="L404">                timeout_overflowed = <span class="tok-null">true</span>;</span>
<span class="line" id="L405">                <span class="tok-kw">break</span> :blk std.math.maxInt(<span class="tok-type">c_int</span>);</span>
<span class="line" id="L406">            };</span>
<span class="line" id="L407"></span>
<span class="line" id="L408">            <span class="tok-comment">// Only need to record the start time if we can provide somewhat accurate error.Timeout's</span>
</span>
<span class="line" id="L409">            <span class="tok-kw">if</span> (!timeout_overflowed) {</span>
<span class="line" id="L410">                sleep_timer = std.time.Timer.start() <span class="tok-kw">catch</span> <span class="tok-kw">unreachable</span>;</span>
<span class="line" id="L411">            }</span>
<span class="line" id="L412">        }</span>
<span class="line" id="L413"></span>
<span class="line" id="L414">        <span class="tok-kw">const</span> value = <span class="tok-builtin">@bitCast</span>(<span class="tok-type">c_int</span>, expect);</span>
<span class="line" id="L415">        <span class="tok-kw">const</span> addr = <span class="tok-builtin">@ptrCast</span>(*<span class="tok-kw">const</span> <span class="tok-kw">volatile</span> <span class="tok-type">c_int</span>, &amp;ptr.value);</span>
<span class="line" id="L416">        <span class="tok-kw">const</span> rc = os.dragonfly.umtx_sleep(addr, value, timeout_us);</span>
<span class="line" id="L417"></span>
<span class="line" id="L418">        <span class="tok-kw">switch</span> (os.errno(rc)) {</span>
<span class="line" id="L419">            .SUCCESS =&gt; {},</span>
<span class="line" id="L420">            .BUSY =&gt; {}, <span class="tok-comment">// ptr != expect</span>
</span>
<span class="line" id="L421">            .AGAIN =&gt; { <span class="tok-comment">// maybe timed out, or paged out, or hit 2s kernel refresh</span>
</span>
<span class="line" id="L422">                <span class="tok-kw">if</span> (timeout) |timeout_ns| {</span>
<span class="line" id="L423">                    <span class="tok-comment">// Report error.Timeout only if we know the timeout duration has passed.</span>
</span>
<span class="line" id="L424">                    <span class="tok-comment">// If not, there's not much choice other than treating it as a spurious wake.</span>
</span>
<span class="line" id="L425">                    <span class="tok-kw">if</span> (!timeout_overflowed <span class="tok-kw">and</span> sleep_timer.read() &gt;= timeout_ns) {</span>
<span class="line" id="L426">                        <span class="tok-kw">return</span> <span class="tok-kw">error</span>.Timeout;</span>
<span class="line" id="L427">                    }</span>
<span class="line" id="L428">                }</span>
<span class="line" id="L429">            },</span>
<span class="line" id="L430">            .INTR =&gt; {}, <span class="tok-comment">// spurious wake</span>
</span>
<span class="line" id="L431">            .INVAL =&gt; <span class="tok-kw">unreachable</span>, <span class="tok-comment">// invalid timeout</span>
</span>
<span class="line" id="L432">            <span class="tok-kw">else</span> =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L433">        }</span>
<span class="line" id="L434">    }</span>
<span class="line" id="L435"></span>
<span class="line" id="L436">    <span class="tok-kw">fn</span> <span class="tok-fn">wake</span>(ptr: *<span class="tok-kw">const</span> Atomic(<span class="tok-type">u32</span>), max_waiters: <span class="tok-type">u32</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L437">        <span class="tok-comment">// A count of zero means wake all waiters.</span>
</span>
<span class="line" id="L438">        assert(max_waiters != <span class="tok-number">0</span>);</span>
<span class="line" id="L439">        <span class="tok-kw">const</span> to_wake = std.math.cast(<span class="tok-type">c_int</span>, max_waiters) <span class="tok-kw">orelse</span> <span class="tok-number">0</span>;</span>
<span class="line" id="L440"></span>
<span class="line" id="L441">        <span class="tok-comment">// https://man.dragonflybsd.org/?command=umtx&amp;section=2</span>
</span>
<span class="line" id="L442">        <span class="tok-comment">// &gt; umtx_wakeup() will generally return 0 unless the address is bad.</span>
</span>
<span class="line" id="L443">        <span class="tok-comment">// We are fine with the address being bad (e.g. for Semaphore.post() where Semaphore.wait() frees the Semaphore)</span>
</span>
<span class="line" id="L444">        <span class="tok-kw">const</span> addr = <span class="tok-builtin">@ptrCast</span>(*<span class="tok-kw">const</span> <span class="tok-kw">volatile</span> <span class="tok-type">c_int</span>, &amp;ptr.value);</span>
<span class="line" id="L445">        _ = os.dragonfly.umtx_wakeup(addr, to_wake);</span>
<span class="line" id="L446">    }</span>
<span class="line" id="L447">};</span>
<span class="line" id="L448"></span>
<span class="line" id="L449"><span class="tok-comment">/// Modified version of linux's futex and Go's sema to implement userspace wait queues with pthread:</span></span>
<span class="line" id="L450"><span class="tok-comment">/// https://code.woboq.org/linux/linux/kernel/futex.c.html</span></span>
<span class="line" id="L451"><span class="tok-comment">/// https://go.dev/src/runtime/sema.go</span></span>
<span class="line" id="L452"><span class="tok-kw">const</span> PosixImpl = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L453">    <span class="tok-kw">const</span> Event = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L454">        cond: std.c.pthread_cond_t,</span>
<span class="line" id="L455">        mutex: std.c.pthread_mutex_t,</span>
<span class="line" id="L456">        state: <span class="tok-kw">enum</span> { empty, waiting, notified },</span>
<span class="line" id="L457"></span>
<span class="line" id="L458">        <span class="tok-kw">fn</span> <span class="tok-fn">init</span>(self: *Event) <span class="tok-type">void</span> {</span>
<span class="line" id="L459">            <span class="tok-comment">// Use static init instead of pthread_cond/mutex_init() since this is generally faster.</span>
</span>
<span class="line" id="L460">            self.cond = .{};</span>
<span class="line" id="L461">            self.mutex = .{};</span>
<span class="line" id="L462">            self.state = .empty;</span>
<span class="line" id="L463">        }</span>
<span class="line" id="L464"></span>
<span class="line" id="L465">        <span class="tok-kw">fn</span> <span class="tok-fn">deinit</span>(self: *Event) <span class="tok-type">void</span> {</span>
<span class="line" id="L466">            <span class="tok-comment">// Some platforms reportedly give EINVAL for statically initialized pthread types.</span>
</span>
<span class="line" id="L467">            <span class="tok-kw">const</span> rc = std.c.pthread_cond_destroy(&amp;self.cond);</span>
<span class="line" id="L468">            assert(rc == .SUCCESS <span class="tok-kw">or</span> rc == .INVAL);</span>
<span class="line" id="L469"></span>
<span class="line" id="L470">            <span class="tok-kw">const</span> rm = std.c.pthread_mutex_destroy(&amp;self.mutex);</span>
<span class="line" id="L471">            assert(rm == .SUCCESS <span class="tok-kw">or</span> rm == .INVAL);</span>
<span class="line" id="L472"></span>
<span class="line" id="L473">            self.* = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L474">        }</span>
<span class="line" id="L475"></span>
<span class="line" id="L476">        <span class="tok-kw">fn</span> <span class="tok-fn">wait</span>(self: *Event, timeout: ?<span class="tok-type">u64</span>) <span class="tok-kw">error</span>{Timeout}!<span class="tok-type">void</span> {</span>
<span class="line" id="L477">            assert(std.c.pthread_mutex_lock(&amp;self.mutex) == .SUCCESS);</span>
<span class="line" id="L478">            <span class="tok-kw">defer</span> assert(std.c.pthread_mutex_unlock(&amp;self.mutex) == .SUCCESS);</span>
<span class="line" id="L479"></span>
<span class="line" id="L480">            <span class="tok-comment">// Early return if the event was already set.</span>
</span>
<span class="line" id="L481">            <span class="tok-kw">if</span> (self.state == .notified) {</span>
<span class="line" id="L482">                <span class="tok-kw">return</span>;</span>
<span class="line" id="L483">            }</span>
<span class="line" id="L484"></span>
<span class="line" id="L485">            <span class="tok-comment">// Compute the absolute timeout if one was specified.</span>
</span>
<span class="line" id="L486">            <span class="tok-comment">// POSIX requires that REALTIME is used by default for the pthread timedwait functions.</span>
</span>
<span class="line" id="L487">            <span class="tok-comment">// This can be changed with pthread_condattr_setclock, but it's an extension and may not be available everywhere.</span>
</span>
<span class="line" id="L488">            <span class="tok-kw">var</span> ts: os.timespec = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L489">            <span class="tok-kw">if</span> (timeout) |timeout_ns| {</span>
<span class="line" id="L490">                os.clock_gettime(os.CLOCK.REALTIME, &amp;ts) <span class="tok-kw">catch</span> <span class="tok-kw">unreachable</span>;</span>
<span class="line" id="L491">                ts.tv_sec +|= <span class="tok-builtin">@intCast</span>(<span class="tok-builtin">@TypeOf</span>(ts.tv_sec), timeout_ns / std.time.ns_per_s);</span>
<span class="line" id="L492">                ts.tv_nsec += <span class="tok-builtin">@intCast</span>(<span class="tok-builtin">@TypeOf</span>(ts.tv_nsec), timeout_ns % std.time.ns_per_s);</span>
<span class="line" id="L493"></span>
<span class="line" id="L494">                <span class="tok-kw">if</span> (ts.tv_nsec &gt;= std.time.ns_per_s) {</span>
<span class="line" id="L495">                    ts.tv_sec +|= <span class="tok-number">1</span>;</span>
<span class="line" id="L496">                    ts.tv_nsec -= std.time.ns_per_s;</span>
<span class="line" id="L497">                }</span>
<span class="line" id="L498">            }</span>
<span class="line" id="L499"></span>
<span class="line" id="L500">            <span class="tok-comment">// Start waiting on the event - there can be only one thread waiting.</span>
</span>
<span class="line" id="L501">            assert(self.state == .empty);</span>
<span class="line" id="L502">            self.state = .waiting;</span>
<span class="line" id="L503"></span>
<span class="line" id="L504">            <span class="tok-kw">while</span> (<span class="tok-null">true</span>) {</span>
<span class="line" id="L505">                <span class="tok-comment">// Block using either pthread_cond_wait or pthread_cond_timewait if there's an absolute timeout.</span>
</span>
<span class="line" id="L506">                <span class="tok-kw">const</span> rc = blk: {</span>
<span class="line" id="L507">                    <span class="tok-kw">if</span> (timeout == <span class="tok-null">null</span>) <span class="tok-kw">break</span> :blk std.c.pthread_cond_wait(&amp;self.cond, &amp;self.mutex);</span>
<span class="line" id="L508">                    <span class="tok-kw">break</span> :blk std.c.pthread_cond_timedwait(&amp;self.cond, &amp;self.mutex, &amp;ts);</span>
<span class="line" id="L509">                };</span>
<span class="line" id="L510"></span>
<span class="line" id="L511">                <span class="tok-comment">// After waking up, check if the event was set.</span>
</span>
<span class="line" id="L512">                <span class="tok-kw">if</span> (self.state == .notified) {</span>
<span class="line" id="L513">                    <span class="tok-kw">return</span>;</span>
<span class="line" id="L514">                }</span>
<span class="line" id="L515"></span>
<span class="line" id="L516">                assert(self.state == .waiting);</span>
<span class="line" id="L517">                <span class="tok-kw">switch</span> (rc) {</span>
<span class="line" id="L518">                    .SUCCESS =&gt; {},</span>
<span class="line" id="L519">                    .TIMEDOUT =&gt; {</span>
<span class="line" id="L520">                        <span class="tok-comment">// If timed out, reset the event to avoid the set() thread doing an unnecessary signal().</span>
</span>
<span class="line" id="L521">                        self.state = .empty;</span>
<span class="line" id="L522">                        <span class="tok-kw">return</span> <span class="tok-kw">error</span>.Timeout;</span>
<span class="line" id="L523">                    },</span>
<span class="line" id="L524">                    .INVAL =&gt; <span class="tok-kw">unreachable</span>, <span class="tok-comment">// cond, mutex, and potentially ts should all be valid</span>
</span>
<span class="line" id="L525">                    .PERM =&gt; <span class="tok-kw">unreachable</span>, <span class="tok-comment">// mutex is locked when cond_*wait() functions are called</span>
</span>
<span class="line" id="L526">                    <span class="tok-kw">else</span> =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L527">                }</span>
<span class="line" id="L528">            }</span>
<span class="line" id="L529">        }</span>
<span class="line" id="L530"></span>
<span class="line" id="L531">        <span class="tok-kw">fn</span> <span class="tok-fn">set</span>(self: *Event) <span class="tok-type">void</span> {</span>
<span class="line" id="L532">            assert(std.c.pthread_mutex_lock(&amp;self.mutex) == .SUCCESS);</span>
<span class="line" id="L533">            <span class="tok-kw">defer</span> assert(std.c.pthread_mutex_unlock(&amp;self.mutex) == .SUCCESS);</span>
<span class="line" id="L534"></span>
<span class="line" id="L535">            <span class="tok-comment">// Make sure that multiple calls to set() were not done on the same Event.</span>
</span>
<span class="line" id="L536">            <span class="tok-kw">const</span> old_state = self.state;</span>
<span class="line" id="L537">            assert(old_state != .notified);</span>
<span class="line" id="L538"></span>
<span class="line" id="L539">            <span class="tok-comment">// Mark the event as set and wake up the waiting thread if there was one.</span>
</span>
<span class="line" id="L540">            <span class="tok-comment">// This must be done while the mutex as the wait() thread could deallocate</span>
</span>
<span class="line" id="L541">            <span class="tok-comment">// the condition variable once it observes the new state, potentially causing a UAF if done unlocked.</span>
</span>
<span class="line" id="L542">            self.state = .notified;</span>
<span class="line" id="L543">            <span class="tok-kw">if</span> (old_state == .waiting) {</span>
<span class="line" id="L544">                assert(std.c.pthread_cond_signal(&amp;self.cond) == .SUCCESS);</span>
<span class="line" id="L545">            }</span>
<span class="line" id="L546">        }</span>
<span class="line" id="L547">    };</span>
<span class="line" id="L548"></span>
<span class="line" id="L549">    <span class="tok-kw">const</span> Treap = std.Treap(<span class="tok-type">usize</span>, std.math.order);</span>
<span class="line" id="L550">    <span class="tok-kw">const</span> Waiter = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L551">        node: Treap.Node,</span>
<span class="line" id="L552">        prev: ?*Waiter,</span>
<span class="line" id="L553">        next: ?*Waiter,</span>
<span class="line" id="L554">        tail: ?*Waiter,</span>
<span class="line" id="L555">        is_queued: <span class="tok-type">bool</span>,</span>
<span class="line" id="L556">        event: Event,</span>
<span class="line" id="L557">    };</span>
<span class="line" id="L558"></span>
<span class="line" id="L559">    <span class="tok-comment">// An unordered set of Waiters</span>
</span>
<span class="line" id="L560">    <span class="tok-kw">const</span> WaitList = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L561">        top: ?*Waiter = <span class="tok-null">null</span>,</span>
<span class="line" id="L562">        len: <span class="tok-type">usize</span> = <span class="tok-number">0</span>,</span>
<span class="line" id="L563"></span>
<span class="line" id="L564">        <span class="tok-kw">fn</span> <span class="tok-fn">push</span>(self: *WaitList, waiter: *Waiter) <span class="tok-type">void</span> {</span>
<span class="line" id="L565">            waiter.next = self.top;</span>
<span class="line" id="L566">            self.top = waiter;</span>
<span class="line" id="L567">            self.len += <span class="tok-number">1</span>;</span>
<span class="line" id="L568">        }</span>
<span class="line" id="L569"></span>
<span class="line" id="L570">        <span class="tok-kw">fn</span> <span class="tok-fn">pop</span>(self: *WaitList) ?*Waiter {</span>
<span class="line" id="L571">            <span class="tok-kw">const</span> waiter = self.top <span class="tok-kw">orelse</span> <span class="tok-kw">return</span> <span class="tok-null">null</span>;</span>
<span class="line" id="L572">            self.top = waiter.next;</span>
<span class="line" id="L573">            self.len -= <span class="tok-number">1</span>;</span>
<span class="line" id="L574">            <span class="tok-kw">return</span> waiter;</span>
<span class="line" id="L575">        }</span>
<span class="line" id="L576">    };</span>
<span class="line" id="L577"></span>
<span class="line" id="L578">    <span class="tok-kw">const</span> WaitQueue = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L579">        <span class="tok-kw">fn</span> <span class="tok-fn">insert</span>(treap: *Treap, address: <span class="tok-type">usize</span>, waiter: *Waiter) <span class="tok-type">void</span> {</span>
<span class="line" id="L580">            <span class="tok-comment">// prepare the waiter to be inserted.</span>
</span>
<span class="line" id="L581">            waiter.next = <span class="tok-null">null</span>;</span>
<span class="line" id="L582">            waiter.is_queued = <span class="tok-null">true</span>;</span>
<span class="line" id="L583"></span>
<span class="line" id="L584">            <span class="tok-comment">// Find the wait queue entry associated with the address.</span>
</span>
<span class="line" id="L585">            <span class="tok-comment">// If there isn't a wait queue on the address, this waiter creates the queue.</span>
</span>
<span class="line" id="L586">            <span class="tok-kw">var</span> entry = treap.getEntryFor(address);</span>
<span class="line" id="L587">            <span class="tok-kw">const</span> entry_node = entry.node <span class="tok-kw">orelse</span> {</span>
<span class="line" id="L588">                waiter.prev = <span class="tok-null">null</span>;</span>
<span class="line" id="L589">                waiter.tail = waiter;</span>
<span class="line" id="L590">                entry.set(&amp;waiter.node);</span>
<span class="line" id="L591">                <span class="tok-kw">return</span>;</span>
<span class="line" id="L592">            };</span>
<span class="line" id="L593"></span>
<span class="line" id="L594">            <span class="tok-comment">// There's a wait queue on the address; get the queue head and tail.</span>
</span>
<span class="line" id="L595">            <span class="tok-kw">const</span> head = <span class="tok-builtin">@fieldParentPtr</span>(Waiter, <span class="tok-str">&quot;node&quot;</span>, entry_node);</span>
<span class="line" id="L596">            <span class="tok-kw">const</span> tail = head.tail <span class="tok-kw">orelse</span> <span class="tok-kw">unreachable</span>;</span>
<span class="line" id="L597"></span>
<span class="line" id="L598">            <span class="tok-comment">// Push the waiter to the tail by replacing it and linking to the previous tail.</span>
</span>
<span class="line" id="L599">            head.tail = waiter;</span>
<span class="line" id="L600">            tail.next = waiter;</span>
<span class="line" id="L601">            waiter.prev = tail;</span>
<span class="line" id="L602">        }</span>
<span class="line" id="L603"></span>
<span class="line" id="L604">        <span class="tok-kw">fn</span> <span class="tok-fn">remove</span>(treap: *Treap, address: <span class="tok-type">usize</span>, max_waiters: <span class="tok-type">usize</span>) WaitList {</span>
<span class="line" id="L605">            <span class="tok-comment">// Find the wait queue associated with this address and get the head/tail if any.</span>
</span>
<span class="line" id="L606">            <span class="tok-kw">var</span> entry = treap.getEntryFor(address);</span>
<span class="line" id="L607">            <span class="tok-kw">var</span> queue_head = <span class="tok-kw">if</span> (entry.node) |node| <span class="tok-builtin">@fieldParentPtr</span>(Waiter, <span class="tok-str">&quot;node&quot;</span>, node) <span class="tok-kw">else</span> <span class="tok-null">null</span>;</span>
<span class="line" id="L608">            <span class="tok-kw">const</span> queue_tail = <span class="tok-kw">if</span> (queue_head) |head| head.tail <span class="tok-kw">else</span> <span class="tok-null">null</span>;</span>
<span class="line" id="L609"></span>
<span class="line" id="L610">            <span class="tok-comment">// Once we're done updating the head, fix it's tail pointer and update the treap's queue head as well.</span>
</span>
<span class="line" id="L611">            <span class="tok-kw">defer</span> entry.set(blk: {</span>
<span class="line" id="L612">                <span class="tok-kw">const</span> new_head = queue_head <span class="tok-kw">orelse</span> <span class="tok-kw">break</span> :blk <span class="tok-null">null</span>;</span>
<span class="line" id="L613">                new_head.tail = queue_tail;</span>
<span class="line" id="L614">                <span class="tok-kw">break</span> :blk &amp;new_head.node;</span>
<span class="line" id="L615">            });</span>
<span class="line" id="L616"></span>
<span class="line" id="L617">            <span class="tok-kw">var</span> removed = WaitList{};</span>
<span class="line" id="L618">            <span class="tok-kw">while</span> (removed.len &lt; max_waiters) {</span>
<span class="line" id="L619">                <span class="tok-comment">// dequeue and collect waiters from their wait queue.</span>
</span>
<span class="line" id="L620">                <span class="tok-kw">const</span> waiter = queue_head <span class="tok-kw">orelse</span> <span class="tok-kw">break</span>;</span>
<span class="line" id="L621">                queue_head = waiter.next;</span>
<span class="line" id="L622">                removed.push(waiter);</span>
<span class="line" id="L623"></span>
<span class="line" id="L624">                <span class="tok-comment">// When dequeueing, we must mark is_queued as false.</span>
</span>
<span class="line" id="L625">                <span class="tok-comment">// This ensures that a waiter which calls tryRemove() returns false.</span>
</span>
<span class="line" id="L626">                assert(waiter.is_queued);</span>
<span class="line" id="L627">                waiter.is_queued = <span class="tok-null">false</span>;</span>
<span class="line" id="L628">            }</span>
<span class="line" id="L629"></span>
<span class="line" id="L630">            <span class="tok-kw">return</span> removed;</span>
<span class="line" id="L631">        }</span>
<span class="line" id="L632"></span>
<span class="line" id="L633">        <span class="tok-kw">fn</span> <span class="tok-fn">tryRemove</span>(treap: *Treap, address: <span class="tok-type">usize</span>, waiter: *Waiter) <span class="tok-type">bool</span> {</span>
<span class="line" id="L634">            <span class="tok-kw">if</span> (!waiter.is_queued) {</span>
<span class="line" id="L635">                <span class="tok-kw">return</span> <span class="tok-null">false</span>;</span>
<span class="line" id="L636">            }</span>
<span class="line" id="L637"></span>
<span class="line" id="L638">            queue_remove: {</span>
<span class="line" id="L639">                <span class="tok-comment">// Find the wait queue associated with the address.</span>
</span>
<span class="line" id="L640">                <span class="tok-kw">var</span> entry = blk: {</span>
<span class="line" id="L641">                    <span class="tok-comment">// A waiter without a previous link means it's the queue head that's in the treap so we can avoid lookup.</span>
</span>
<span class="line" id="L642">                    <span class="tok-kw">if</span> (waiter.prev == <span class="tok-null">null</span>) {</span>
<span class="line" id="L643">                        assert(waiter.node.key == address);</span>
<span class="line" id="L644">                        <span class="tok-kw">break</span> :blk treap.getEntryForExisting(&amp;waiter.node);</span>
<span class="line" id="L645">                    }</span>
<span class="line" id="L646">                    <span class="tok-kw">break</span> :blk treap.getEntryFor(address);</span>
<span class="line" id="L647">                };</span>
<span class="line" id="L648"></span>
<span class="line" id="L649">                <span class="tok-comment">// The queue head and tail must exist if we're removing a queued waiter.</span>
</span>
<span class="line" id="L650">                <span class="tok-kw">const</span> head = <span class="tok-builtin">@fieldParentPtr</span>(Waiter, <span class="tok-str">&quot;node&quot;</span>, entry.node <span class="tok-kw">orelse</span> <span class="tok-kw">unreachable</span>);</span>
<span class="line" id="L651">                <span class="tok-kw">const</span> tail = head.tail <span class="tok-kw">orelse</span> <span class="tok-kw">unreachable</span>;</span>
<span class="line" id="L652"></span>
<span class="line" id="L653">                <span class="tok-comment">// A waiter with a previous link is never the head of the queue.</span>
</span>
<span class="line" id="L654">                <span class="tok-kw">if</span> (waiter.prev) |prev| {</span>
<span class="line" id="L655">                    assert(waiter != head);</span>
<span class="line" id="L656">                    prev.next = waiter.next;</span>
<span class="line" id="L657"></span>
<span class="line" id="L658">                    <span class="tok-comment">// A waiter with both a previous and next link is in the middle.</span>
</span>
<span class="line" id="L659">                    <span class="tok-comment">// We only need to update the surrounding waiter's links to remove it.</span>
</span>
<span class="line" id="L660">                    <span class="tok-kw">if</span> (waiter.next) |next| {</span>
<span class="line" id="L661">                        assert(waiter != tail);</span>
<span class="line" id="L662">                        next.prev = waiter.prev;</span>
<span class="line" id="L663">                        <span class="tok-kw">break</span> :queue_remove;</span>
<span class="line" id="L664">                    }</span>
<span class="line" id="L665"></span>
<span class="line" id="L666">                    <span class="tok-comment">// A waiter with a previous but no next link means it's the tail of the queue.</span>
</span>
<span class="line" id="L667">                    <span class="tok-comment">// In that case, we need to update the head's tail reference.</span>
</span>
<span class="line" id="L668">                    assert(waiter == tail);</span>
<span class="line" id="L669">                    head.tail = waiter.prev;</span>
<span class="line" id="L670">                    <span class="tok-kw">break</span> :queue_remove;</span>
<span class="line" id="L671">                }</span>
<span class="line" id="L672"></span>
<span class="line" id="L673">                <span class="tok-comment">// A waiter with no previous link means it's the queue head of queue.</span>
</span>
<span class="line" id="L674">                <span class="tok-comment">// We must replace (or remove) the head waiter reference in the treap.</span>
</span>
<span class="line" id="L675">                assert(waiter == head);</span>
<span class="line" id="L676">                entry.set(blk: {</span>
<span class="line" id="L677">                    <span class="tok-kw">const</span> new_head = waiter.next <span class="tok-kw">orelse</span> <span class="tok-kw">break</span> :blk <span class="tok-null">null</span>;</span>
<span class="line" id="L678">                    new_head.tail = head.tail;</span>
<span class="line" id="L679">                    <span class="tok-kw">break</span> :blk &amp;new_head.node;</span>
<span class="line" id="L680">                });</span>
<span class="line" id="L681">            }</span>
<span class="line" id="L682"></span>
<span class="line" id="L683">            <span class="tok-comment">// Mark the waiter as successfully removed.</span>
</span>
<span class="line" id="L684">            waiter.is_queued = <span class="tok-null">false</span>;</span>
<span class="line" id="L685">            <span class="tok-kw">return</span> <span class="tok-null">true</span>;</span>
<span class="line" id="L686">        }</span>
<span class="line" id="L687">    };</span>
<span class="line" id="L688"></span>
<span class="line" id="L689">    <span class="tok-kw">const</span> Bucket = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L690">        mutex: std.c.pthread_mutex_t <span class="tok-kw">align</span>(std.atomic.cache_line) = .{},</span>
<span class="line" id="L691">        pending: Atomic(<span class="tok-type">usize</span>) = Atomic(<span class="tok-type">usize</span>).init(<span class="tok-number">0</span>),</span>
<span class="line" id="L692">        treap: Treap = .{},</span>
<span class="line" id="L693"></span>
<span class="line" id="L694">        <span class="tok-comment">// Global array of buckets that addresses map to.</span>
</span>
<span class="line" id="L695">        <span class="tok-comment">// Bucket array size is pretty much arbitrary here, but it must be a power of two for fibonacci hashing.</span>
</span>
<span class="line" id="L696">        <span class="tok-kw">var</span> buckets = [_]Bucket{.{}} ** <span class="tok-builtin">@bitSizeOf</span>(<span class="tok-type">usize</span>);</span>
<span class="line" id="L697"></span>
<span class="line" id="L698">        <span class="tok-comment">// https://github.com/Amanieu/parking_lot/blob/1cf12744d097233316afa6c8b7d37389e4211756/core/src/parking_lot.rs#L343-L353</span>
</span>
<span class="line" id="L699">        <span class="tok-kw">fn</span> <span class="tok-fn">from</span>(address: <span class="tok-type">usize</span>) *Bucket {</span>
<span class="line" id="L700">            <span class="tok-comment">// The upper `@bitSizeOf(usize)` bits of the fibonacci golden ratio.</span>
</span>
<span class="line" id="L701">            <span class="tok-comment">// Hashing this via (h * k) &gt;&gt; (64 - b) where k=golden-ration and b=bitsize-of-array</span>
</span>
<span class="line" id="L702">            <span class="tok-comment">// evenly lays out h=hash values over the bit range even when the hash has poor entropy (identity-hash for pointers).</span>
</span>
<span class="line" id="L703">            <span class="tok-kw">const</span> max_multiplier_bits = <span class="tok-builtin">@bitSizeOf</span>(<span class="tok-type">usize</span>);</span>
<span class="line" id="L704">            <span class="tok-kw">const</span> fibonacci_multiplier = <span class="tok-number">0x9E3779B97F4A7C15</span> &gt;&gt; (<span class="tok-number">64</span> - max_multiplier_bits);</span>
<span class="line" id="L705"></span>
<span class="line" id="L706">            <span class="tok-kw">const</span> max_bucket_bits = <span class="tok-builtin">@ctz</span>(<span class="tok-type">usize</span>, buckets.len);</span>
<span class="line" id="L707">            <span class="tok-kw">comptime</span> assert(std.math.isPowerOfTwo(buckets.len));</span>
<span class="line" id="L708"></span>
<span class="line" id="L709">            <span class="tok-kw">const</span> index = (address *% fibonacci_multiplier) &gt;&gt; (max_multiplier_bits - max_bucket_bits);</span>
<span class="line" id="L710">            <span class="tok-kw">return</span> &amp;buckets[index];</span>
<span class="line" id="L711">        }</span>
<span class="line" id="L712">    };</span>
<span class="line" id="L713"></span>
<span class="line" id="L714">    <span class="tok-kw">const</span> Address = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L715">        <span class="tok-kw">fn</span> <span class="tok-fn">from</span>(ptr: *<span class="tok-kw">const</span> Atomic(<span class="tok-type">u32</span>)) <span class="tok-type">usize</span> {</span>
<span class="line" id="L716">            <span class="tok-comment">// Get the alignment of the pointer.</span>
</span>
<span class="line" id="L717">            <span class="tok-kw">const</span> alignment = <span class="tok-builtin">@alignOf</span>(Atomic(<span class="tok-type">u32</span>));</span>
<span class="line" id="L718">            <span class="tok-kw">comptime</span> assert(std.math.isPowerOfTwo(alignment));</span>
<span class="line" id="L719"></span>
<span class="line" id="L720">            <span class="tok-comment">// Make sure the pointer is aligned,</span>
</span>
<span class="line" id="L721">            <span class="tok-comment">// then cut off the zero bits from the alignment to get the unique address.</span>
</span>
<span class="line" id="L722">            <span class="tok-kw">const</span> addr = <span class="tok-builtin">@ptrToInt</span>(ptr);</span>
<span class="line" id="L723">            assert(addr &amp; (alignment - <span class="tok-number">1</span>) == <span class="tok-number">0</span>);</span>
<span class="line" id="L724">            <span class="tok-kw">return</span> addr &gt;&gt; <span class="tok-builtin">@ctz</span>(<span class="tok-type">usize</span>, alignment);</span>
<span class="line" id="L725">        }</span>
<span class="line" id="L726">    };</span>
<span class="line" id="L727"></span>
<span class="line" id="L728">    <span class="tok-kw">fn</span> <span class="tok-fn">wait</span>(ptr: *<span class="tok-kw">const</span> Atomic(<span class="tok-type">u32</span>), expect: <span class="tok-type">u32</span>, timeout: ?<span class="tok-type">u64</span>) <span class="tok-kw">error</span>{Timeout}!<span class="tok-type">void</span> {</span>
<span class="line" id="L729">        <span class="tok-kw">const</span> address = Address.from(ptr);</span>
<span class="line" id="L730">        <span class="tok-kw">const</span> bucket = Bucket.from(address);</span>
<span class="line" id="L731"></span>
<span class="line" id="L732">        <span class="tok-comment">// Announce that there's a waiter in the bucket before checking the ptr/expect condition.</span>
</span>
<span class="line" id="L733">        <span class="tok-comment">// If the announcement is reordered after the ptr check, the waiter could deadlock:</span>
</span>
<span class="line" id="L734">        <span class="tok-comment">//</span>
</span>
<span class="line" id="L735">        <span class="tok-comment">// - T1: checks ptr == expect which is true</span>
</span>
<span class="line" id="L736">        <span class="tok-comment">// - T2: updates ptr to != expect</span>
</span>
<span class="line" id="L737">        <span class="tok-comment">// - T2: does Futex.wake(), sees no pending waiters, exits</span>
</span>
<span class="line" id="L738">        <span class="tok-comment">// - T1: bumps pending waiters (was reordered after the ptr == expect check)</span>
</span>
<span class="line" id="L739">        <span class="tok-comment">// - T1: goes to sleep and misses both the ptr change and T2's wake up</span>
</span>
<span class="line" id="L740">        <span class="tok-comment">//</span>
</span>
<span class="line" id="L741">        <span class="tok-comment">// SeqCst as Acquire barrier to ensure the announcement happens before the ptr check below.</span>
</span>
<span class="line" id="L742">        <span class="tok-comment">// SeqCst as shared modification order to form a happens-before edge with the fence(.SeqCst)+load() in wake().</span>
</span>
<span class="line" id="L743">        <span class="tok-kw">var</span> pending = bucket.pending.fetchAdd(<span class="tok-number">1</span>, .SeqCst);</span>
<span class="line" id="L744">        assert(pending &lt; std.math.maxInt(<span class="tok-type">usize</span>));</span>
<span class="line" id="L745"></span>
<span class="line" id="L746">        <span class="tok-comment">// If the wait gets cancelled, remove the pending count we previously added.</span>
</span>
<span class="line" id="L747">        <span class="tok-comment">// This is done outside the mutex lock to keep the critical section short in case of contention.</span>
</span>
<span class="line" id="L748">        <span class="tok-kw">var</span> cancelled = <span class="tok-null">false</span>;</span>
<span class="line" id="L749">        <span class="tok-kw">defer</span> <span class="tok-kw">if</span> (cancelled) {</span>
<span class="line" id="L750">            pending = bucket.pending.fetchSub(<span class="tok-number">1</span>, .Monotonic);</span>
<span class="line" id="L751">            assert(pending &gt; <span class="tok-number">0</span>);</span>
<span class="line" id="L752">        };</span>
<span class="line" id="L753"></span>
<span class="line" id="L754">        <span class="tok-kw">var</span> waiter: Waiter = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L755">        {</span>
<span class="line" id="L756">            assert(std.c.pthread_mutex_lock(&amp;bucket.mutex) == .SUCCESS);</span>
<span class="line" id="L757">            <span class="tok-kw">defer</span> assert(std.c.pthread_mutex_unlock(&amp;bucket.mutex) == .SUCCESS);</span>
<span class="line" id="L758"></span>
<span class="line" id="L759">            cancelled = ptr.load(.Monotonic) != expect;</span>
<span class="line" id="L760">            <span class="tok-kw">if</span> (cancelled) {</span>
<span class="line" id="L761">                <span class="tok-kw">return</span>;</span>
<span class="line" id="L762">            }</span>
<span class="line" id="L763"></span>
<span class="line" id="L764">            waiter.event.init();</span>
<span class="line" id="L765">            WaitQueue.insert(&amp;bucket.treap, address, &amp;waiter);</span>
<span class="line" id="L766">        }</span>
<span class="line" id="L767"></span>
<span class="line" id="L768">        <span class="tok-kw">defer</span> {</span>
<span class="line" id="L769">            assert(!waiter.is_queued);</span>
<span class="line" id="L770">            waiter.event.deinit();</span>
<span class="line" id="L771">        }</span>
<span class="line" id="L772"></span>
<span class="line" id="L773">        waiter.event.wait(timeout) <span class="tok-kw">catch</span> {</span>
<span class="line" id="L774">            <span class="tok-comment">// If we fail to cancel after a timeout, it means a wake() thread dequeued us and will wake us up.</span>
</span>
<span class="line" id="L775">            <span class="tok-comment">// We must wait until the event is set as that's a signal that the wake() thread wont access the waiter memory anymore.</span>
</span>
<span class="line" id="L776">            <span class="tok-comment">// If we return early without waiting, the waiter on the stack would be invalidated and the wake() thread risks a UAF.</span>
</span>
<span class="line" id="L777">            <span class="tok-kw">defer</span> <span class="tok-kw">if</span> (!cancelled) waiter.event.wait(<span class="tok-null">null</span>) <span class="tok-kw">catch</span> <span class="tok-kw">unreachable</span>;</span>
<span class="line" id="L778"></span>
<span class="line" id="L779">            assert(std.c.pthread_mutex_lock(&amp;bucket.mutex) == .SUCCESS);</span>
<span class="line" id="L780">            <span class="tok-kw">defer</span> assert(std.c.pthread_mutex_unlock(&amp;bucket.mutex) == .SUCCESS);</span>
<span class="line" id="L781"></span>
<span class="line" id="L782">            cancelled = WaitQueue.tryRemove(&amp;bucket.treap, address, &amp;waiter);</span>
<span class="line" id="L783">            <span class="tok-kw">if</span> (cancelled) {</span>
<span class="line" id="L784">                <span class="tok-kw">return</span> <span class="tok-kw">error</span>.Timeout;</span>
<span class="line" id="L785">            }</span>
<span class="line" id="L786">        };</span>
<span class="line" id="L787">    }</span>
<span class="line" id="L788"></span>
<span class="line" id="L789">    <span class="tok-kw">fn</span> <span class="tok-fn">wake</span>(ptr: *<span class="tok-kw">const</span> Atomic(<span class="tok-type">u32</span>), max_waiters: <span class="tok-type">u32</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L790">        <span class="tok-kw">const</span> address = Address.from(ptr);</span>
<span class="line" id="L791">        <span class="tok-kw">const</span> bucket = Bucket.from(address);</span>
<span class="line" id="L792"></span>
<span class="line" id="L793">        <span class="tok-comment">// Quick check if there's even anything to wake up.</span>
</span>
<span class="line" id="L794">        <span class="tok-comment">// The change to the ptr's value must happen before we check for pending waiters.</span>
</span>
<span class="line" id="L795">        <span class="tok-comment">// If not, the wake() thread could miss a sleeping waiter and have it deadlock:</span>
</span>
<span class="line" id="L796">        <span class="tok-comment">//</span>
</span>
<span class="line" id="L797">        <span class="tok-comment">// - T2: p = has pending waiters (reordered before the ptr update)</span>
</span>
<span class="line" id="L798">        <span class="tok-comment">// - T1: bump pending waiters</span>
</span>
<span class="line" id="L799">        <span class="tok-comment">// - T1: if ptr == expected: sleep()</span>
</span>
<span class="line" id="L800">        <span class="tok-comment">// - T2: update ptr != expected</span>
</span>
<span class="line" id="L801">        <span class="tok-comment">// - T2: p is false from earlier so doesn't wake (T1 missed ptr update and T2 missed T1 sleeping)</span>
</span>
<span class="line" id="L802">        <span class="tok-comment">//</span>
</span>
<span class="line" id="L803">        <span class="tok-comment">// What we really want here is a Release load, but that doesn't exist under the C11 memory model.</span>
</span>
<span class="line" id="L804">        <span class="tok-comment">// We could instead do `bucket.pending.fetchAdd(0, Release) == 0` which achieves effectively the same thing,</span>
</span>
<span class="line" id="L805">        <span class="tok-comment">// but the RMW operation unconditionally marks the cache-line as modified for others causing unnecessary fetching/contention.</span>
</span>
<span class="line" id="L806">        <span class="tok-comment">//</span>
</span>
<span class="line" id="L807">        <span class="tok-comment">// Instead we opt to do a full-fence + load instead which avoids taking ownership of the cache-line.</span>
</span>
<span class="line" id="L808">        <span class="tok-comment">// fence(SeqCst) effectively converts the ptr update to SeqCst and the pending load to SeqCst: creating a Store-Load barrier.</span>
</span>
<span class="line" id="L809">        <span class="tok-comment">//</span>
</span>
<span class="line" id="L810">        <span class="tok-comment">// The pending count increment in wait() must also now use SeqCst for the update + this pending load</span>
</span>
<span class="line" id="L811">        <span class="tok-comment">// to be in the same modification order as our load isn't using Release/Acquire to guarantee it.</span>
</span>
<span class="line" id="L812">        bucket.pending.fence(.SeqCst);</span>
<span class="line" id="L813">        <span class="tok-kw">if</span> (bucket.pending.load(.Monotonic) == <span class="tok-number">0</span>) {</span>
<span class="line" id="L814">            <span class="tok-kw">return</span>;</span>
<span class="line" id="L815">        }</span>
<span class="line" id="L816"></span>
<span class="line" id="L817">        <span class="tok-comment">// Keep a list of all the waiters notified and wake then up outside the mutex critical section.</span>
</span>
<span class="line" id="L818">        <span class="tok-kw">var</span> notified = WaitList{};</span>
<span class="line" id="L819">        <span class="tok-kw">defer</span> <span class="tok-kw">if</span> (notified.len &gt; <span class="tok-number">0</span>) {</span>
<span class="line" id="L820">            <span class="tok-kw">const</span> pending = bucket.pending.fetchSub(notified.len, .Monotonic);</span>
<span class="line" id="L821">            assert(pending &gt;= notified.len);</span>
<span class="line" id="L822"></span>
<span class="line" id="L823">            <span class="tok-kw">while</span> (notified.pop()) |waiter| {</span>
<span class="line" id="L824">                assert(!waiter.is_queued);</span>
<span class="line" id="L825">                waiter.event.set();</span>
<span class="line" id="L826">            }</span>
<span class="line" id="L827">        };</span>
<span class="line" id="L828"></span>
<span class="line" id="L829">        assert(std.c.pthread_mutex_lock(&amp;bucket.mutex) == .SUCCESS);</span>
<span class="line" id="L830">        <span class="tok-kw">defer</span> assert(std.c.pthread_mutex_unlock(&amp;bucket.mutex) == .SUCCESS);</span>
<span class="line" id="L831"></span>
<span class="line" id="L832">        <span class="tok-comment">// Another pending check again to avoid the WaitQueue lookup if not necessary.</span>
</span>
<span class="line" id="L833">        <span class="tok-kw">if</span> (bucket.pending.load(.Monotonic) &gt; <span class="tok-number">0</span>) {</span>
<span class="line" id="L834">            notified = WaitQueue.remove(&amp;bucket.treap, address, max_waiters);</span>
<span class="line" id="L835">        }</span>
<span class="line" id="L836">    }</span>
<span class="line" id="L837">};</span>
<span class="line" id="L838"></span>
<span class="line" id="L839"><span class="tok-kw">test</span> <span class="tok-str">&quot;Futex - smoke test&quot;</span> {</span>
<span class="line" id="L840">    <span class="tok-kw">var</span> value = Atomic(<span class="tok-type">u32</span>).init(<span class="tok-number">0</span>);</span>
<span class="line" id="L841"></span>
<span class="line" id="L842">    <span class="tok-comment">// Try waits with invalid values.</span>
</span>
<span class="line" id="L843">    Futex.wait(&amp;value, <span class="tok-number">0xdeadbeef</span>);</span>
<span class="line" id="L844">    Futex.timedWait(&amp;value, <span class="tok-number">0xdeadbeef</span>, <span class="tok-number">0</span>) <span class="tok-kw">catch</span> {};</span>
<span class="line" id="L845"></span>
<span class="line" id="L846">    <span class="tok-comment">// Try timeout waits.</span>
</span>
<span class="line" id="L847">    <span class="tok-kw">try</span> testing.expectError(<span class="tok-kw">error</span>.Timeout, Futex.timedWait(&amp;value, <span class="tok-number">0</span>, <span class="tok-number">0</span>));</span>
<span class="line" id="L848">    <span class="tok-kw">try</span> testing.expectError(<span class="tok-kw">error</span>.Timeout, Futex.timedWait(&amp;value, <span class="tok-number">0</span>, std.time.ns_per_ms));</span>
<span class="line" id="L849"></span>
<span class="line" id="L850">    <span class="tok-comment">// Try wakes</span>
</span>
<span class="line" id="L851">    Futex.wake(&amp;value, <span class="tok-number">0</span>);</span>
<span class="line" id="L852">    Futex.wake(&amp;value, <span class="tok-number">1</span>);</span>
<span class="line" id="L853">    Futex.wake(&amp;value, std.math.maxInt(<span class="tok-type">u32</span>));</span>
<span class="line" id="L854">}</span>
<span class="line" id="L855"></span>
<span class="line" id="L856"><span class="tok-kw">test</span> <span class="tok-str">&quot;Futex - signaling&quot;</span> {</span>
<span class="line" id="L857">    <span class="tok-comment">// This test requires spawning threads</span>
</span>
<span class="line" id="L858">    <span class="tok-kw">if</span> (builtin.single_threaded) {</span>
<span class="line" id="L859">        <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SkipZigTest;</span>
<span class="line" id="L860">    }</span>
<span class="line" id="L861"></span>
<span class="line" id="L862">    <span class="tok-kw">const</span> num_threads = <span class="tok-number">4</span>;</span>
<span class="line" id="L863">    <span class="tok-kw">const</span> num_iterations = <span class="tok-number">4</span>;</span>
<span class="line" id="L864"></span>
<span class="line" id="L865">    <span class="tok-kw">const</span> Paddle = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L866">        value: Atomic(<span class="tok-type">u32</span>) = Atomic(<span class="tok-type">u32</span>).init(<span class="tok-number">0</span>),</span>
<span class="line" id="L867">        current: <span class="tok-type">u32</span> = <span class="tok-number">0</span>,</span>
<span class="line" id="L868"></span>
<span class="line" id="L869">        <span class="tok-kw">fn</span> <span class="tok-fn">hit</span>(self: *<span class="tok-builtin">@This</span>()) <span class="tok-type">void</span> {</span>
<span class="line" id="L870">            _ = self.value.fetchAdd(<span class="tok-number">1</span>, .Release);</span>
<span class="line" id="L871">            Futex.wake(&amp;self.value, <span class="tok-number">1</span>);</span>
<span class="line" id="L872">        }</span>
<span class="line" id="L873"></span>
<span class="line" id="L874">        <span class="tok-kw">fn</span> <span class="tok-fn">run</span>(self: *<span class="tok-builtin">@This</span>(), hit_to: *<span class="tok-builtin">@This</span>()) !<span class="tok-type">void</span> {</span>
<span class="line" id="L875">            <span class="tok-kw">while</span> (self.current &lt; num_iterations) {</span>
<span class="line" id="L876">                <span class="tok-comment">// Wait for the value to change from hit()</span>
</span>
<span class="line" id="L877">                <span class="tok-kw">var</span> new_value: <span class="tok-type">u32</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L878">                <span class="tok-kw">while</span> (<span class="tok-null">true</span>) {</span>
<span class="line" id="L879">                    new_value = self.value.load(.Acquire);</span>
<span class="line" id="L880">                    <span class="tok-kw">if</span> (new_value != self.current) <span class="tok-kw">break</span>;</span>
<span class="line" id="L881">                    Futex.wait(&amp;self.value, self.current);</span>
<span class="line" id="L882">                }</span>
<span class="line" id="L883"></span>
<span class="line" id="L884">                <span class="tok-comment">// change the internal &quot;current&quot; value</span>
</span>
<span class="line" id="L885">                <span class="tok-kw">try</span> testing.expectEqual(new_value, self.current + <span class="tok-number">1</span>);</span>
<span class="line" id="L886">                self.current = new_value;</span>
<span class="line" id="L887"></span>
<span class="line" id="L888">                <span class="tok-comment">// hit the next paddle</span>
</span>
<span class="line" id="L889">                hit_to.hit();</span>
<span class="line" id="L890">            }</span>
<span class="line" id="L891">        }</span>
<span class="line" id="L892">    };</span>
<span class="line" id="L893"></span>
<span class="line" id="L894">    <span class="tok-kw">var</span> paddles = [_]Paddle{.{}} ** num_threads;</span>
<span class="line" id="L895">    <span class="tok-kw">var</span> threads = [_]std.Thread{<span class="tok-null">undefined</span>} ** num_threads;</span>
<span class="line" id="L896"></span>
<span class="line" id="L897">    <span class="tok-comment">// Create a circle of paddles which hit each other</span>
</span>
<span class="line" id="L898">    <span class="tok-kw">for</span> (threads) |*t, i| {</span>
<span class="line" id="L899">        <span class="tok-kw">const</span> paddle = &amp;paddles[i];</span>
<span class="line" id="L900">        <span class="tok-kw">const</span> hit_to = &amp;paddles[(i + <span class="tok-number">1</span>) % paddles.len];</span>
<span class="line" id="L901">        t.* = <span class="tok-kw">try</span> std.Thread.spawn(.{}, Paddle.run, .{ paddle, hit_to });</span>
<span class="line" id="L902">    }</span>
<span class="line" id="L903"></span>
<span class="line" id="L904">    <span class="tok-comment">// Hit the first paddle and wait for them all to complete by hitting each other for num_iterations.</span>
</span>
<span class="line" id="L905">    paddles[<span class="tok-number">0</span>].hit();</span>
<span class="line" id="L906">    <span class="tok-kw">for</span> (threads) |t| t.join();</span>
<span class="line" id="L907">    <span class="tok-kw">for</span> (paddles) |p| <span class="tok-kw">try</span> testing.expectEqual(p.current, num_iterations);</span>
<span class="line" id="L908">}</span>
<span class="line" id="L909"></span>
<span class="line" id="L910"><span class="tok-kw">test</span> <span class="tok-str">&quot;Futex - broadcasting&quot;</span> {</span>
<span class="line" id="L911">    <span class="tok-comment">// This test requires spawning threads</span>
</span>
<span class="line" id="L912">    <span class="tok-kw">if</span> (builtin.single_threaded) {</span>
<span class="line" id="L913">        <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SkipZigTest;</span>
<span class="line" id="L914">    }</span>
<span class="line" id="L915"></span>
<span class="line" id="L916">    <span class="tok-kw">const</span> num_threads = <span class="tok-number">4</span>;</span>
<span class="line" id="L917">    <span class="tok-kw">const</span> num_iterations = <span class="tok-number">4</span>;</span>
<span class="line" id="L918"></span>
<span class="line" id="L919">    <span class="tok-kw">const</span> Barrier = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L920">        count: Atomic(<span class="tok-type">u32</span>) = Atomic(<span class="tok-type">u32</span>).init(num_threads),</span>
<span class="line" id="L921">        futex: Atomic(<span class="tok-type">u32</span>) = Atomic(<span class="tok-type">u32</span>).init(<span class="tok-number">0</span>),</span>
<span class="line" id="L922"></span>
<span class="line" id="L923">        <span class="tok-kw">fn</span> <span class="tok-fn">wait</span>(self: *<span class="tok-builtin">@This</span>()) !<span class="tok-type">void</span> {</span>
<span class="line" id="L924">            <span class="tok-comment">// Decrement the counter.</span>
</span>
<span class="line" id="L925">            <span class="tok-comment">// Release ensures stuff before this barrier.wait() happens before the last one.</span>
</span>
<span class="line" id="L926">            <span class="tok-kw">const</span> count = self.count.fetchSub(<span class="tok-number">1</span>, .Release);</span>
<span class="line" id="L927">            <span class="tok-kw">try</span> testing.expect(count &lt;= num_threads);</span>
<span class="line" id="L928">            <span class="tok-kw">try</span> testing.expect(count &gt; <span class="tok-number">0</span>);</span>
<span class="line" id="L929"></span>
<span class="line" id="L930">            <span class="tok-comment">// First counter to reach zero wakes all other threads.</span>
</span>
<span class="line" id="L931">            <span class="tok-comment">// Acquire for the last counter ensures stuff before previous barrier.wait()s happened before it.</span>
</span>
<span class="line" id="L932">            <span class="tok-comment">// Release on futex update ensures stuff before all barrier.wait()'s happens before they all return.</span>
</span>
<span class="line" id="L933">            <span class="tok-kw">if</span> (count - <span class="tok-number">1</span> == <span class="tok-number">0</span>) {</span>
<span class="line" id="L934">                _ = self.count.load(.Acquire); <span class="tok-comment">// TODO: could be fence(Acquire) if not for TSAN</span>
</span>
<span class="line" id="L935">                self.futex.store(<span class="tok-number">1</span>, .Release);</span>
<span class="line" id="L936">                Futex.wake(&amp;self.futex, num_threads - <span class="tok-number">1</span>);</span>
<span class="line" id="L937">                <span class="tok-kw">return</span>;</span>
<span class="line" id="L938">            }</span>
<span class="line" id="L939"></span>
<span class="line" id="L940">            <span class="tok-comment">// Other threads wait until last counter wakes them up.</span>
</span>
<span class="line" id="L941">            <span class="tok-comment">// Acquire on futex synchronizes with last barrier count to ensure stuff before all barrier.wait()'s happen before us.</span>
</span>
<span class="line" id="L942">            <span class="tok-kw">while</span> (self.futex.load(.Acquire) == <span class="tok-number">0</span>) {</span>
<span class="line" id="L943">                Futex.wait(&amp;self.futex, <span class="tok-number">0</span>);</span>
<span class="line" id="L944">            }</span>
<span class="line" id="L945">        }</span>
<span class="line" id="L946">    };</span>
<span class="line" id="L947"></span>
<span class="line" id="L948">    <span class="tok-kw">const</span> Broadcast = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L949">        barriers: [num_iterations]Barrier = [_]Barrier{.{}} ** num_iterations,</span>
<span class="line" id="L950">        threads: [num_threads]std.Thread = <span class="tok-null">undefined</span>,</span>
<span class="line" id="L951"></span>
<span class="line" id="L952">        <span class="tok-kw">fn</span> <span class="tok-fn">run</span>(self: *<span class="tok-builtin">@This</span>()) !<span class="tok-type">void</span> {</span>
<span class="line" id="L953">            <span class="tok-kw">for</span> (self.barriers) |*barrier| {</span>
<span class="line" id="L954">                <span class="tok-kw">try</span> barrier.wait();</span>
<span class="line" id="L955">            }</span>
<span class="line" id="L956">        }</span>
<span class="line" id="L957">    };</span>
<span class="line" id="L958"></span>
<span class="line" id="L959">    <span class="tok-kw">var</span> broadcast = Broadcast{};</span>
<span class="line" id="L960">    <span class="tok-kw">for</span> (broadcast.threads) |*t| t.* = <span class="tok-kw">try</span> std.Thread.spawn(.{}, Broadcast.run, .{&amp;broadcast});</span>
<span class="line" id="L961">    <span class="tok-kw">for</span> (broadcast.threads) |t| t.join();</span>
<span class="line" id="L962">}</span>
<span class="line" id="L963"></span>
<span class="line" id="L964"><span class="tok-comment">/// Deadline is used to wait efficiently for a pointer's value to change using Futex and a fixed timeout.</span></span>
<span class="line" id="L965"><span class="tok-comment">///</span></span>
<span class="line" id="L966"><span class="tok-comment">/// Futex's timedWait() api uses a relative duration which suffers from over-waiting</span></span>
<span class="line" id="L967"><span class="tok-comment">/// when used in a loop which is often required due to the possibility of spurious wakeups.</span></span>
<span class="line" id="L968"><span class="tok-comment">///</span></span>
<span class="line" id="L969"><span class="tok-comment">/// Deadline instead converts the relative timeout to an absolute one so that multiple calls</span></span>
<span class="line" id="L970"><span class="tok-comment">/// to Futex timedWait() can block for and report more accurate error.Timeouts.</span></span>
<span class="line" id="L971"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> Deadline = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L972">    timeout: ?<span class="tok-type">u64</span>,</span>
<span class="line" id="L973">    started: std.time.Timer,</span>
<span class="line" id="L974"></span>
<span class="line" id="L975">    <span class="tok-comment">/// Create the deadline to expire after the given amount of time in nanoseconds passes.</span></span>
<span class="line" id="L976">    <span class="tok-comment">/// Pass in `null` to have the deadline call `Futex.wait()` and never expire.</span></span>
<span class="line" id="L977">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">init</span>(expires_in_ns: ?<span class="tok-type">u64</span>) Deadline {</span>
<span class="line" id="L978">        <span class="tok-kw">var</span> deadline: Deadline = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L979">        deadline.timeout = expires_in_ns;</span>
<span class="line" id="L980"></span>
<span class="line" id="L981">        <span class="tok-comment">// std.time.Timer is required to be supported for somewhat accurate reportings of error.Timeout.</span>
</span>
<span class="line" id="L982">        <span class="tok-kw">if</span> (deadline.timeout != <span class="tok-null">null</span>) {</span>
<span class="line" id="L983">            deadline.started = std.time.Timer.start() <span class="tok-kw">catch</span> <span class="tok-kw">unreachable</span>;</span>
<span class="line" id="L984">        }</span>
<span class="line" id="L985"></span>
<span class="line" id="L986">        <span class="tok-kw">return</span> deadline;</span>
<span class="line" id="L987">    }</span>
<span class="line" id="L988"></span>
<span class="line" id="L989">    <span class="tok-comment">/// Wait until either:</span></span>
<span class="line" id="L990">    <span class="tok-comment">/// - the `ptr`'s value changes from `expect`.</span></span>
<span class="line" id="L991">    <span class="tok-comment">/// - `Futex.wake()` is called on the `ptr`.</span></span>
<span class="line" id="L992">    <span class="tok-comment">/// - A spurious wake occurs.</span></span>
<span class="line" id="L993">    <span class="tok-comment">/// - The deadline expires; In which case `error.Timeout` is returned.</span></span>
<span class="line" id="L994">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">wait</span>(self: *Deadline, ptr: *<span class="tok-kw">const</span> Atomic(<span class="tok-type">u32</span>), expect: <span class="tok-type">u32</span>) <span class="tok-kw">error</span>{Timeout}!<span class="tok-type">void</span> {</span>
<span class="line" id="L995">        <span class="tok-builtin">@setCold</span>(<span class="tok-null">true</span>);</span>
<span class="line" id="L996"></span>
<span class="line" id="L997">        <span class="tok-comment">// Check if we actually have a timeout to wait until.</span>
</span>
<span class="line" id="L998">        <span class="tok-comment">// If not just wait &quot;forever&quot;.</span>
</span>
<span class="line" id="L999">        <span class="tok-kw">const</span> timeout_ns = self.timeout <span class="tok-kw">orelse</span> {</span>
<span class="line" id="L1000">            <span class="tok-kw">return</span> Futex.wait(ptr, expect);</span>
<span class="line" id="L1001">        };</span>
<span class="line" id="L1002"></span>
<span class="line" id="L1003">        <span class="tok-comment">// Get how much time has passed since we started waiting</span>
</span>
<span class="line" id="L1004">        <span class="tok-comment">// then subtract that from the init() timeout to get how much longer to wait.</span>
</span>
<span class="line" id="L1005">        <span class="tok-comment">// Use overflow to detect when we've been waiting longer than the init() timeout.</span>
</span>
<span class="line" id="L1006">        <span class="tok-kw">const</span> elapsed_ns = self.started.read();</span>
<span class="line" id="L1007">        <span class="tok-kw">const</span> until_timeout_ns = std.math.sub(<span class="tok-type">u64</span>, timeout_ns, elapsed_ns) <span class="tok-kw">catch</span> <span class="tok-number">0</span>;</span>
<span class="line" id="L1008">        <span class="tok-kw">return</span> Futex.timedWait(ptr, expect, until_timeout_ns);</span>
<span class="line" id="L1009">    }</span>
<span class="line" id="L1010">};</span>
<span class="line" id="L1011"></span>
<span class="line" id="L1012"><span class="tok-kw">test</span> <span class="tok-str">&quot;Futex - Deadline&quot;</span> {</span>
<span class="line" id="L1013">    <span class="tok-kw">var</span> deadline = Deadline.init(<span class="tok-number">100</span> * std.time.ns_per_ms);</span>
<span class="line" id="L1014">    <span class="tok-kw">var</span> futex_word = Atomic(<span class="tok-type">u32</span>).init(<span class="tok-number">0</span>);</span>
<span class="line" id="L1015"></span>
<span class="line" id="L1016">    <span class="tok-kw">while</span> (<span class="tok-null">true</span>) {</span>
<span class="line" id="L1017">        deadline.wait(&amp;futex_word, <span class="tok-number">0</span>) <span class="tok-kw">catch</span> <span class="tok-kw">break</span>;</span>
<span class="line" id="L1018">    }</span>
<span class="line" id="L1019">}</span>
<span class="line" id="L1020"></span>
</code></pre></body>
</html>