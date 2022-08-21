<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">    <title>once.zig - source view</title>
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
<span class="line" id="L3"><span class="tok-kw">const</span> testing = std.testing;</span>
<span class="line" id="L4"></span>
<span class="line" id="L5"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">once</span>(<span class="tok-kw">comptime</span> f: <span class="tok-kw">fn</span> () <span class="tok-type">void</span>) Once(f) {</span>
<span class="line" id="L6">    <span class="tok-kw">return</span> Once(f){};</span>
<span class="line" id="L7">}</span>
<span class="line" id="L8"></span>
<span class="line" id="L9"><span class="tok-comment">/// An object that executes the function `f` just once.</span></span>
<span class="line" id="L10"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">Once</span>(<span class="tok-kw">comptime</span> f: <span class="tok-kw">fn</span> () <span class="tok-type">void</span>) <span class="tok-type">type</span> {</span>
<span class="line" id="L11">    <span class="tok-kw">return</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L12">        done: <span class="tok-type">bool</span> = <span class="tok-null">false</span>,</span>
<span class="line" id="L13">        mutex: std.Thread.Mutex = std.Thread.Mutex{},</span>
<span class="line" id="L14"></span>
<span class="line" id="L15">        <span class="tok-comment">/// Call the function `f`.</span></span>
<span class="line" id="L16">        <span class="tok-comment">/// If `call` is invoked multiple times `f` will be executed only the</span></span>
<span class="line" id="L17">        <span class="tok-comment">/// first time.</span></span>
<span class="line" id="L18">        <span class="tok-comment">/// The invocations are thread-safe.</span></span>
<span class="line" id="L19">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">call</span>(self: *<span class="tok-builtin">@This</span>()) <span class="tok-type">void</span> {</span>
<span class="line" id="L20">            <span class="tok-kw">if</span> (<span class="tok-builtin">@atomicLoad</span>(<span class="tok-type">bool</span>, &amp;self.done, .Acquire))</span>
<span class="line" id="L21">                <span class="tok-kw">return</span>;</span>
<span class="line" id="L22"></span>
<span class="line" id="L23">            <span class="tok-kw">return</span> self.callSlow();</span>
<span class="line" id="L24">        }</span>
<span class="line" id="L25"></span>
<span class="line" id="L26">        <span class="tok-kw">fn</span> <span class="tok-fn">callSlow</span>(self: *<span class="tok-builtin">@This</span>()) <span class="tok-type">void</span> {</span>
<span class="line" id="L27">            <span class="tok-builtin">@setCold</span>(<span class="tok-null">true</span>);</span>
<span class="line" id="L28"></span>
<span class="line" id="L29">            self.mutex.lock();</span>
<span class="line" id="L30">            <span class="tok-kw">defer</span> self.mutex.unlock();</span>
<span class="line" id="L31"></span>
<span class="line" id="L32">            <span class="tok-comment">// The first thread to acquire the mutex gets to run the initializer</span>
</span>
<span class="line" id="L33">            <span class="tok-kw">if</span> (!self.done) {</span>
<span class="line" id="L34">                f();</span>
<span class="line" id="L35">                <span class="tok-builtin">@atomicStore</span>(<span class="tok-type">bool</span>, &amp;self.done, <span class="tok-null">true</span>, .Release);</span>
<span class="line" id="L36">            }</span>
<span class="line" id="L37">        }</span>
<span class="line" id="L38">    };</span>
<span class="line" id="L39">}</span>
<span class="line" id="L40"></span>
<span class="line" id="L41"><span class="tok-kw">var</span> global_number: <span class="tok-type">i32</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L42"><span class="tok-kw">var</span> global_once = once(incr);</span>
<span class="line" id="L43"></span>
<span class="line" id="L44"><span class="tok-kw">fn</span> <span class="tok-fn">incr</span>() <span class="tok-type">void</span> {</span>
<span class="line" id="L45">    global_number += <span class="tok-number">1</span>;</span>
<span class="line" id="L46">}</span>
<span class="line" id="L47"></span>
<span class="line" id="L48"><span class="tok-kw">test</span> <span class="tok-str">&quot;Once executes its function just once&quot;</span> {</span>
<span class="line" id="L49">    <span class="tok-kw">if</span> (builtin.single_threaded) {</span>
<span class="line" id="L50">        global_once.call();</span>
<span class="line" id="L51">        global_once.call();</span>
<span class="line" id="L52">    } <span class="tok-kw">else</span> {</span>
<span class="line" id="L53">        <span class="tok-kw">var</span> threads: [<span class="tok-number">10</span>]std.Thread = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L54">        <span class="tok-kw">defer</span> <span class="tok-kw">for</span> (threads) |handle| handle.join();</span>
<span class="line" id="L55"></span>
<span class="line" id="L56">        <span class="tok-kw">for</span> (threads) |*handle| {</span>
<span class="line" id="L57">            handle.* = <span class="tok-kw">try</span> std.Thread.spawn(.{}, <span class="tok-kw">struct</span> {</span>
<span class="line" id="L58">                <span class="tok-kw">fn</span> <span class="tok-fn">thread_fn</span>(x: <span class="tok-type">u8</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L59">                    _ = x;</span>
<span class="line" id="L60">                    global_once.call();</span>
<span class="line" id="L61">                }</span>
<span class="line" id="L62">            }.thread_fn, .{<span class="tok-number">0</span>});</span>
<span class="line" id="L63">        }</span>
<span class="line" id="L64">    }</span>
<span class="line" id="L65"></span>
<span class="line" id="L66">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">i32</span>, <span class="tok-number">1</span>), global_number);</span>
<span class="line" id="L67">}</span>
<span class="line" id="L68"></span>
</code></pre></body>
</html>