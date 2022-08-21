<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">    <title>event/locked.zig - source view</title>
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
<span class="line" id="L2"><span class="tok-kw">const</span> Lock = std.event.Lock;</span>
<span class="line" id="L3"></span>
<span class="line" id="L4"><span class="tok-comment">/// Thread-safe async/await lock that protects one piece of data.</span></span>
<span class="line" id="L5"><span class="tok-comment">/// Functions which are waiting for the lock are suspended, and</span></span>
<span class="line" id="L6"><span class="tok-comment">/// are resumed when the lock is released, in order.</span></span>
<span class="line" id="L7"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">Locked</span>(<span class="tok-kw">comptime</span> T: <span class="tok-type">type</span>) <span class="tok-type">type</span> {</span>
<span class="line" id="L8">    <span class="tok-kw">return</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L9">        lock: Lock,</span>
<span class="line" id="L10">        private_data: T,</span>
<span class="line" id="L11"></span>
<span class="line" id="L12">        <span class="tok-kw">const</span> Self = <span class="tok-builtin">@This</span>();</span>
<span class="line" id="L13"></span>
<span class="line" id="L14">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> HeldLock = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L15">            value: *T,</span>
<span class="line" id="L16">            held: Lock.Held,</span>
<span class="line" id="L17"></span>
<span class="line" id="L18">            <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">release</span>(self: HeldLock) <span class="tok-type">void</span> {</span>
<span class="line" id="L19">                self.held.release();</span>
<span class="line" id="L20">            }</span>
<span class="line" id="L21">        };</span>
<span class="line" id="L22"></span>
<span class="line" id="L23">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">init</span>(data: T) Self {</span>
<span class="line" id="L24">            <span class="tok-kw">return</span> Self{</span>
<span class="line" id="L25">                .lock = .{},</span>
<span class="line" id="L26">                .private_data = data,</span>
<span class="line" id="L27">            };</span>
<span class="line" id="L28">        }</span>
<span class="line" id="L29"></span>
<span class="line" id="L30">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">deinit</span>(self: *Self) <span class="tok-type">void</span> {</span>
<span class="line" id="L31">            self.lock.deinit();</span>
<span class="line" id="L32">        }</span>
<span class="line" id="L33"></span>
<span class="line" id="L34">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">acquire</span>(self: *Self) <span class="tok-kw">callconv</span>(.Async) HeldLock {</span>
<span class="line" id="L35">            <span class="tok-kw">return</span> HeldLock{</span>
<span class="line" id="L36">                <span class="tok-comment">// TODO guaranteed allocation elision</span>
</span>
<span class="line" id="L37">                .held = self.lock.acquire(),</span>
<span class="line" id="L38">                .value = &amp;self.private_data,</span>
<span class="line" id="L39">            };</span>
<span class="line" id="L40">        }</span>
<span class="line" id="L41">    };</span>
<span class="line" id="L42">}</span>
<span class="line" id="L43"></span>
</code></pre></body>
</html>