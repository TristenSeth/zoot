<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">    <title>event/future.zig - source view</title>
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
<span class="line" id="L5"><span class="tok-kw">const</span> Lock = std.event.Lock;</span>
<span class="line" id="L6"></span>
<span class="line" id="L7"><span class="tok-comment">/// This is a value that starts out unavailable, until resolve() is called</span></span>
<span class="line" id="L8"><span class="tok-comment">/// While it is unavailable, functions suspend when they try to get() it,</span></span>
<span class="line" id="L9"><span class="tok-comment">/// and then are resumed when resolve() is called.</span></span>
<span class="line" id="L10"><span class="tok-comment">/// At this point the value remains forever available, and another resolve() is not allowed.</span></span>
<span class="line" id="L11"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">Future</span>(<span class="tok-kw">comptime</span> T: <span class="tok-type">type</span>) <span class="tok-type">type</span> {</span>
<span class="line" id="L12">    <span class="tok-kw">return</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L13">        lock: Lock,</span>
<span class="line" id="L14">        data: T,</span>
<span class="line" id="L15">        available: Available,</span>
<span class="line" id="L16"></span>
<span class="line" id="L17">        <span class="tok-kw">const</span> Available = <span class="tok-kw">enum</span>(<span class="tok-type">u8</span>) {</span>
<span class="line" id="L18">            NotStarted,</span>
<span class="line" id="L19">            Started,</span>
<span class="line" id="L20">            Finished,</span>
<span class="line" id="L21">        };</span>
<span class="line" id="L22"></span>
<span class="line" id="L23">        <span class="tok-kw">const</span> Self = <span class="tok-builtin">@This</span>();</span>
<span class="line" id="L24">        <span class="tok-kw">const</span> Queue = std.atomic.Queue(<span class="tok-kw">anyframe</span>);</span>
<span class="line" id="L25"></span>
<span class="line" id="L26">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">init</span>() Self {</span>
<span class="line" id="L27">            <span class="tok-kw">return</span> Self{</span>
<span class="line" id="L28">                .lock = Lock.initLocked(),</span>
<span class="line" id="L29">                .available = .NotStarted,</span>
<span class="line" id="L30">                .data = <span class="tok-null">undefined</span>,</span>
<span class="line" id="L31">            };</span>
<span class="line" id="L32">        }</span>
<span class="line" id="L33"></span>
<span class="line" id="L34">        <span class="tok-comment">/// Obtain the value. If it's not available, wait until it becomes</span></span>
<span class="line" id="L35">        <span class="tok-comment">/// available.</span></span>
<span class="line" id="L36">        <span class="tok-comment">/// Thread-safe.</span></span>
<span class="line" id="L37">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">get</span>(self: *Self) <span class="tok-kw">callconv</span>(.Async) *T {</span>
<span class="line" id="L38">            <span class="tok-kw">if</span> (<span class="tok-builtin">@atomicLoad</span>(Available, &amp;self.available, .SeqCst) == .Finished) {</span>
<span class="line" id="L39">                <span class="tok-kw">return</span> &amp;self.data;</span>
<span class="line" id="L40">            }</span>
<span class="line" id="L41">            <span class="tok-kw">const</span> held = self.lock.acquire();</span>
<span class="line" id="L42">            held.release();</span>
<span class="line" id="L43"></span>
<span class="line" id="L44">            <span class="tok-kw">return</span> &amp;self.data;</span>
<span class="line" id="L45">        }</span>
<span class="line" id="L46"></span>
<span class="line" id="L47">        <span class="tok-comment">/// Gets the data without waiting for it. If it's available, a pointer is</span></span>
<span class="line" id="L48">        <span class="tok-comment">/// returned. Otherwise, null is returned.</span></span>
<span class="line" id="L49">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">getOrNull</span>(self: *Self) ?*T {</span>
<span class="line" id="L50">            <span class="tok-kw">if</span> (<span class="tok-builtin">@atomicLoad</span>(Available, &amp;self.available, .SeqCst) == .Finished) {</span>
<span class="line" id="L51">                <span class="tok-kw">return</span> &amp;self.data;</span>
<span class="line" id="L52">            } <span class="tok-kw">else</span> {</span>
<span class="line" id="L53">                <span class="tok-kw">return</span> <span class="tok-null">null</span>;</span>
<span class="line" id="L54">            }</span>
<span class="line" id="L55">        }</span>
<span class="line" id="L56"></span>
<span class="line" id="L57">        <span class="tok-comment">/// If someone else has started working on the data, wait for them to complete</span></span>
<span class="line" id="L58">        <span class="tok-comment">/// and return a pointer to the data. Otherwise, return null, and the caller</span></span>
<span class="line" id="L59">        <span class="tok-comment">/// should start working on the data.</span></span>
<span class="line" id="L60">        <span class="tok-comment">/// It's not required to call start() before resolve() but it can be useful since</span></span>
<span class="line" id="L61">        <span class="tok-comment">/// this method is thread-safe.</span></span>
<span class="line" id="L62">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">start</span>(self: *Self) <span class="tok-kw">callconv</span>(.Async) ?*T {</span>
<span class="line" id="L63">            <span class="tok-kw">const</span> state = <span class="tok-builtin">@cmpxchgStrong</span>(Available, &amp;self.available, .NotStarted, .Started, .SeqCst, .SeqCst) <span class="tok-kw">orelse</span> <span class="tok-kw">return</span> <span class="tok-null">null</span>;</span>
<span class="line" id="L64">            <span class="tok-kw">switch</span> (state) {</span>
<span class="line" id="L65">                .Started =&gt; {</span>
<span class="line" id="L66">                    <span class="tok-kw">const</span> held = self.lock.acquire();</span>
<span class="line" id="L67">                    held.release();</span>
<span class="line" id="L68">                    <span class="tok-kw">return</span> &amp;self.data;</span>
<span class="line" id="L69">                },</span>
<span class="line" id="L70">                .Finished =&gt; <span class="tok-kw">return</span> &amp;self.data,</span>
<span class="line" id="L71">                <span class="tok-kw">else</span> =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L72">            }</span>
<span class="line" id="L73">        }</span>
<span class="line" id="L74"></span>
<span class="line" id="L75">        <span class="tok-comment">/// Make the data become available. May be called only once.</span></span>
<span class="line" id="L76">        <span class="tok-comment">/// Before calling this, modify the `data` property.</span></span>
<span class="line" id="L77">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">resolve</span>(self: *Self) <span class="tok-type">void</span> {</span>
<span class="line" id="L78">            <span class="tok-kw">const</span> prev = <span class="tok-builtin">@atomicRmw</span>(Available, &amp;self.available, .Xchg, .Finished, .SeqCst);</span>
<span class="line" id="L79">            assert(prev != .Finished); <span class="tok-comment">// resolve() called twice</span>
</span>
<span class="line" id="L80">            Lock.Held.release(Lock.Held{ .lock = &amp;self.lock });</span>
<span class="line" id="L81">        }</span>
<span class="line" id="L82">    };</span>
<span class="line" id="L83">}</span>
<span class="line" id="L84"></span>
<span class="line" id="L85"><span class="tok-kw">test</span> <span class="tok-str">&quot;std.event.Future&quot;</span> {</span>
<span class="line" id="L86">    <span class="tok-comment">// https://github.com/ziglang/zig/issues/1908</span>
</span>
<span class="line" id="L87">    <span class="tok-kw">if</span> (builtin.single_threaded) <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SkipZigTest;</span>
<span class="line" id="L88">    <span class="tok-comment">// https://github.com/ziglang/zig/issues/3251</span>
</span>
<span class="line" id="L89">    <span class="tok-kw">if</span> (builtin.os.tag == .freebsd) <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SkipZigTest;</span>
<span class="line" id="L90">    <span class="tok-comment">// TODO provide a way to run tests in evented I/O mode</span>
</span>
<span class="line" id="L91">    <span class="tok-kw">if</span> (!std.io.is_async) <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SkipZigTest;</span>
<span class="line" id="L92"></span>
<span class="line" id="L93">    testFuture();</span>
<span class="line" id="L94">}</span>
<span class="line" id="L95"></span>
<span class="line" id="L96"><span class="tok-kw">fn</span> <span class="tok-fn">testFuture</span>() <span class="tok-type">void</span> {</span>
<span class="line" id="L97">    <span class="tok-kw">var</span> future = Future(<span class="tok-type">i32</span>).init();</span>
<span class="line" id="L98"></span>
<span class="line" id="L99">    <span class="tok-kw">var</span> a = <span class="tok-kw">async</span> waitOnFuture(&amp;future);</span>
<span class="line" id="L100">    <span class="tok-kw">var</span> b = <span class="tok-kw">async</span> waitOnFuture(&amp;future);</span>
<span class="line" id="L101">    resolveFuture(&amp;future);</span>
<span class="line" id="L102"></span>
<span class="line" id="L103">    <span class="tok-kw">const</span> result = (<span class="tok-kw">await</span> a) + (<span class="tok-kw">await</span> b);</span>
<span class="line" id="L104"></span>
<span class="line" id="L105">    <span class="tok-kw">try</span> testing.expect(result == <span class="tok-number">12</span>);</span>
<span class="line" id="L106">}</span>
<span class="line" id="L107"></span>
<span class="line" id="L108"><span class="tok-kw">fn</span> <span class="tok-fn">waitOnFuture</span>(future: *Future(<span class="tok-type">i32</span>)) <span class="tok-type">i32</span> {</span>
<span class="line" id="L109">    <span class="tok-kw">return</span> future.get().*;</span>
<span class="line" id="L110">}</span>
<span class="line" id="L111"></span>
<span class="line" id="L112"><span class="tok-kw">fn</span> <span class="tok-fn">resolveFuture</span>(future: *Future(<span class="tok-type">i32</span>)) <span class="tok-type">void</span> {</span>
<span class="line" id="L113">    future.data = <span class="tok-number">6</span>;</span>
<span class="line" id="L114">    future.resolve();</span>
<span class="line" id="L115">}</span>
<span class="line" id="L116"></span>
</code></pre></body>
</html>