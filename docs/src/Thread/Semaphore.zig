<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">    <title>Thread/Semaphore.zig - source view</title>
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
<pre><code><span class="line" id="L1"><span class="tok-comment">//! A semaphore is an unsigned integer that blocks the kernel thread if</span></span>
<span class="line" id="L2"><span class="tok-comment">//! the number would become negative.</span></span>
<span class="line" id="L3"><span class="tok-comment">//! This API supports static initialization and does not require deinitialization.</span></span>
<span class="line" id="L4"></span>
<span class="line" id="L5">mutex: Mutex = .{},</span>
<span class="line" id="L6">cond: Condition = .{},</span>
<span class="line" id="L7"><span class="tok-comment">/// It is OK to initialize this field to any value.</span></span>
<span class="line" id="L8">permits: <span class="tok-type">usize</span> = <span class="tok-number">0</span>,</span>
<span class="line" id="L9"></span>
<span class="line" id="L10"><span class="tok-kw">const</span> Semaphore = <span class="tok-builtin">@This</span>();</span>
<span class="line" id="L11"><span class="tok-kw">const</span> std = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;../std.zig&quot;</span>);</span>
<span class="line" id="L12"><span class="tok-kw">const</span> Mutex = std.Thread.Mutex;</span>
<span class="line" id="L13"><span class="tok-kw">const</span> Condition = std.Thread.Condition;</span>
<span class="line" id="L14"><span class="tok-kw">const</span> builtin = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;builtin&quot;</span>);</span>
<span class="line" id="L15"><span class="tok-kw">const</span> testing = std.testing;</span>
<span class="line" id="L16"></span>
<span class="line" id="L17"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">wait</span>(sem: *Semaphore) <span class="tok-type">void</span> {</span>
<span class="line" id="L18">    sem.mutex.lock();</span>
<span class="line" id="L19">    <span class="tok-kw">defer</span> sem.mutex.unlock();</span>
<span class="line" id="L20"></span>
<span class="line" id="L21">    <span class="tok-kw">while</span> (sem.permits == <span class="tok-number">0</span>)</span>
<span class="line" id="L22">        sem.cond.wait(&amp;sem.mutex);</span>
<span class="line" id="L23"></span>
<span class="line" id="L24">    sem.permits -= <span class="tok-number">1</span>;</span>
<span class="line" id="L25">    <span class="tok-kw">if</span> (sem.permits &gt; <span class="tok-number">0</span>)</span>
<span class="line" id="L26">        sem.cond.signal();</span>
<span class="line" id="L27">}</span>
<span class="line" id="L28"></span>
<span class="line" id="L29"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">post</span>(sem: *Semaphore) <span class="tok-type">void</span> {</span>
<span class="line" id="L30">    sem.mutex.lock();</span>
<span class="line" id="L31">    <span class="tok-kw">defer</span> sem.mutex.unlock();</span>
<span class="line" id="L32"></span>
<span class="line" id="L33">    sem.permits += <span class="tok-number">1</span>;</span>
<span class="line" id="L34">    sem.cond.signal();</span>
<span class="line" id="L35">}</span>
<span class="line" id="L36"></span>
<span class="line" id="L37"><span class="tok-kw">test</span> <span class="tok-str">&quot;Thread.Semaphore&quot;</span> {</span>
<span class="line" id="L38">    <span class="tok-kw">if</span> (builtin.single_threaded) {</span>
<span class="line" id="L39">        <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SkipZigTest;</span>
<span class="line" id="L40">    }</span>
<span class="line" id="L41"></span>
<span class="line" id="L42">    <span class="tok-kw">const</span> TestContext = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L43">        sem: *Semaphore,</span>
<span class="line" id="L44">        n: *<span class="tok-type">i32</span>,</span>
<span class="line" id="L45">        <span class="tok-kw">fn</span> <span class="tok-fn">worker</span>(ctx: *<span class="tok-builtin">@This</span>()) <span class="tok-type">void</span> {</span>
<span class="line" id="L46">            ctx.sem.wait();</span>
<span class="line" id="L47">            ctx.n.* += <span class="tok-number">1</span>;</span>
<span class="line" id="L48">            ctx.sem.post();</span>
<span class="line" id="L49">        }</span>
<span class="line" id="L50">    };</span>
<span class="line" id="L51">    <span class="tok-kw">const</span> num_threads = <span class="tok-number">3</span>;</span>
<span class="line" id="L52">    <span class="tok-kw">var</span> sem = Semaphore{ .permits = <span class="tok-number">1</span> };</span>
<span class="line" id="L53">    <span class="tok-kw">var</span> threads: [num_threads]std.Thread = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L54">    <span class="tok-kw">var</span> n: <span class="tok-type">i32</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L55">    <span class="tok-kw">var</span> ctx = TestContext{ .sem = &amp;sem, .n = &amp;n };</span>
<span class="line" id="L56"></span>
<span class="line" id="L57">    <span class="tok-kw">for</span> (threads) |*t| t.* = <span class="tok-kw">try</span> std.Thread.spawn(.{}, TestContext.worker, .{&amp;ctx});</span>
<span class="line" id="L58">    <span class="tok-kw">for</span> (threads) |t| t.join();</span>
<span class="line" id="L59">    sem.wait();</span>
<span class="line" id="L60">    <span class="tok-kw">try</span> testing.expect(n == num_threads);</span>
<span class="line" id="L61">}</span>
<span class="line" id="L62"></span>
</code></pre></body>
</html>