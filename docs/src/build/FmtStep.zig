<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">    <title>build/FmtStep.zig - source view</title>
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
<span class="line" id="L2"><span class="tok-kw">const</span> build = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;../build.zig&quot;</span>);</span>
<span class="line" id="L3"><span class="tok-kw">const</span> Step = build.Step;</span>
<span class="line" id="L4"><span class="tok-kw">const</span> Builder = build.Builder;</span>
<span class="line" id="L5"><span class="tok-kw">const</span> BufMap = std.BufMap;</span>
<span class="line" id="L6"><span class="tok-kw">const</span> mem = std.mem;</span>
<span class="line" id="L7"></span>
<span class="line" id="L8"><span class="tok-kw">const</span> FmtStep = <span class="tok-builtin">@This</span>();</span>
<span class="line" id="L9"></span>
<span class="line" id="L10"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> base_id = .fmt;</span>
<span class="line" id="L11"></span>
<span class="line" id="L12">step: Step,</span>
<span class="line" id="L13">builder: *Builder,</span>
<span class="line" id="L14">argv: [][]<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L15"></span>
<span class="line" id="L16"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">create</span>(builder: *Builder, paths: []<span class="tok-kw">const</span> []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) *FmtStep {</span>
<span class="line" id="L17">    <span class="tok-kw">const</span> self = builder.allocator.create(FmtStep) <span class="tok-kw">catch</span> <span class="tok-kw">unreachable</span>;</span>
<span class="line" id="L18">    <span class="tok-kw">const</span> name = <span class="tok-str">&quot;zig fmt&quot;</span>;</span>
<span class="line" id="L19">    self.* = FmtStep{</span>
<span class="line" id="L20">        .step = Step.init(.fmt, name, builder.allocator, make),</span>
<span class="line" id="L21">        .builder = builder,</span>
<span class="line" id="L22">        .argv = builder.allocator.alloc([]<span class="tok-type">u8</span>, paths.len + <span class="tok-number">2</span>) <span class="tok-kw">catch</span> <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L23">    };</span>
<span class="line" id="L24"></span>
<span class="line" id="L25">    self.argv[<span class="tok-number">0</span>] = builder.zig_exe;</span>
<span class="line" id="L26">    self.argv[<span class="tok-number">1</span>] = <span class="tok-str">&quot;fmt&quot;</span>;</span>
<span class="line" id="L27">    <span class="tok-kw">for</span> (paths) |path, i| {</span>
<span class="line" id="L28">        self.argv[<span class="tok-number">2</span> + i] = builder.pathFromRoot(path);</span>
<span class="line" id="L29">    }</span>
<span class="line" id="L30">    <span class="tok-kw">return</span> self;</span>
<span class="line" id="L31">}</span>
<span class="line" id="L32"></span>
<span class="line" id="L33"><span class="tok-kw">fn</span> <span class="tok-fn">make</span>(step: *Step) !<span class="tok-type">void</span> {</span>
<span class="line" id="L34">    <span class="tok-kw">const</span> self = <span class="tok-builtin">@fieldParentPtr</span>(FmtStep, <span class="tok-str">&quot;step&quot;</span>, step);</span>
<span class="line" id="L35"></span>
<span class="line" id="L36">    <span class="tok-kw">return</span> self.builder.spawnChild(self.argv);</span>
<span class="line" id="L37">}</span>
<span class="line" id="L38"></span>
</code></pre></body>
</html>