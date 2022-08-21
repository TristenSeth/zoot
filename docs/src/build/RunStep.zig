<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">    <title>build/RunStep.zig - source view</title>
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
<span class="line" id="L3"><span class="tok-kw">const</span> build = std.build;</span>
<span class="line" id="L4"><span class="tok-kw">const</span> Step = build.Step;</span>
<span class="line" id="L5"><span class="tok-kw">const</span> Builder = build.Builder;</span>
<span class="line" id="L6"><span class="tok-kw">const</span> LibExeObjStep = build.LibExeObjStep;</span>
<span class="line" id="L7"><span class="tok-kw">const</span> WriteFileStep = build.WriteFileStep;</span>
<span class="line" id="L8"><span class="tok-kw">const</span> fs = std.fs;</span>
<span class="line" id="L9"><span class="tok-kw">const</span> mem = std.mem;</span>
<span class="line" id="L10"><span class="tok-kw">const</span> process = std.process;</span>
<span class="line" id="L11"><span class="tok-kw">const</span> ArrayList = std.ArrayList;</span>
<span class="line" id="L12"><span class="tok-kw">const</span> EnvMap = process.EnvMap;</span>
<span class="line" id="L13"><span class="tok-kw">const</span> Allocator = mem.Allocator;</span>
<span class="line" id="L14"><span class="tok-kw">const</span> ExecError = build.Builder.ExecError;</span>
<span class="line" id="L15"></span>
<span class="line" id="L16"><span class="tok-kw">const</span> max_stdout_size = <span class="tok-number">1</span> * <span class="tok-number">1024</span> * <span class="tok-number">1024</span>; <span class="tok-comment">// 1 MiB</span>
</span>
<span class="line" id="L17"></span>
<span class="line" id="L18"><span class="tok-kw">const</span> RunStep = <span class="tok-builtin">@This</span>();</span>
<span class="line" id="L19"></span>
<span class="line" id="L20"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> base_id = .run;</span>
<span class="line" id="L21"></span>
<span class="line" id="L22">step: Step,</span>
<span class="line" id="L23">builder: *Builder,</span>
<span class="line" id="L24"></span>
<span class="line" id="L25"><span class="tok-comment">/// See also addArg and addArgs to modifying this directly</span></span>
<span class="line" id="L26">argv: ArrayList(Arg),</span>
<span class="line" id="L27"></span>
<span class="line" id="L28"><span class="tok-comment">/// Set this to modify the current working directory</span></span>
<span class="line" id="L29">cwd: ?[]<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L30"></span>
<span class="line" id="L31"><span class="tok-comment">/// Override this field to modify the environment, or use setEnvironmentVariable</span></span>
<span class="line" id="L32">env_map: ?*EnvMap,</span>
<span class="line" id="L33"></span>
<span class="line" id="L34">stdout_action: StdIoAction = .inherit,</span>
<span class="line" id="L35">stderr_action: StdIoAction = .inherit,</span>
<span class="line" id="L36"></span>
<span class="line" id="L37">stdin_behavior: std.ChildProcess.StdIo = .Inherit,</span>
<span class="line" id="L38"></span>
<span class="line" id="L39"><span class="tok-comment">/// Set this to `null` to ignore the exit code for the purpose of determining a successful execution</span></span>
<span class="line" id="L40">expected_exit_code: ?<span class="tok-type">u8</span> = <span class="tok-number">0</span>,</span>
<span class="line" id="L41"></span>
<span class="line" id="L42"><span class="tok-comment">/// Print the command before running it</span></span>
<span class="line" id="L43">print: <span class="tok-type">bool</span>,</span>
<span class="line" id="L44"></span>
<span class="line" id="L45"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> StdIoAction = <span class="tok-kw">union</span>(<span class="tok-kw">enum</span>) {</span>
<span class="line" id="L46">    inherit,</span>
<span class="line" id="L47">    ignore,</span>
<span class="line" id="L48">    expect_exact: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L49">    expect_matches: []<span class="tok-kw">const</span> []<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L50">};</span>
<span class="line" id="L51"></span>
<span class="line" id="L52"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> Arg = <span class="tok-kw">union</span>(<span class="tok-kw">enum</span>) {</span>
<span class="line" id="L53">    artifact: *LibExeObjStep,</span>
<span class="line" id="L54">    file_source: build.FileSource,</span>
<span class="line" id="L55">    bytes: []<span class="tok-type">u8</span>,</span>
<span class="line" id="L56">};</span>
<span class="line" id="L57"></span>
<span class="line" id="L58"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">create</span>(builder: *Builder, name: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) *RunStep {</span>
<span class="line" id="L59">    <span class="tok-kw">const</span> self = builder.allocator.create(RunStep) <span class="tok-kw">catch</span> <span class="tok-kw">unreachable</span>;</span>
<span class="line" id="L60">    self.* = RunStep{</span>
<span class="line" id="L61">        .builder = builder,</span>
<span class="line" id="L62">        .step = Step.init(.run, name, builder.allocator, make),</span>
<span class="line" id="L63">        .argv = ArrayList(Arg).init(builder.allocator),</span>
<span class="line" id="L64">        .cwd = <span class="tok-null">null</span>,</span>
<span class="line" id="L65">        .env_map = <span class="tok-null">null</span>,</span>
<span class="line" id="L66">        .print = builder.verbose,</span>
<span class="line" id="L67">    };</span>
<span class="line" id="L68">    <span class="tok-kw">return</span> self;</span>
<span class="line" id="L69">}</span>
<span class="line" id="L70"></span>
<span class="line" id="L71"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">addArtifactArg</span>(self: *RunStep, artifact: *LibExeObjStep) <span class="tok-type">void</span> {</span>
<span class="line" id="L72">    self.argv.append(Arg{ .artifact = artifact }) <span class="tok-kw">catch</span> <span class="tok-kw">unreachable</span>;</span>
<span class="line" id="L73">    self.step.dependOn(&amp;artifact.step);</span>
<span class="line" id="L74">}</span>
<span class="line" id="L75"></span>
<span class="line" id="L76"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">addFileSourceArg</span>(self: *RunStep, file_source: build.FileSource) <span class="tok-type">void</span> {</span>
<span class="line" id="L77">    self.argv.append(Arg{</span>
<span class="line" id="L78">        .file_source = file_source.dupe(self.builder),</span>
<span class="line" id="L79">    }) <span class="tok-kw">catch</span> <span class="tok-kw">unreachable</span>;</span>
<span class="line" id="L80">    file_source.addStepDependencies(&amp;self.step);</span>
<span class="line" id="L81">}</span>
<span class="line" id="L82"></span>
<span class="line" id="L83"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">addArg</span>(self: *RunStep, arg: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L84">    self.argv.append(Arg{ .bytes = self.builder.dupe(arg) }) <span class="tok-kw">catch</span> <span class="tok-kw">unreachable</span>;</span>
<span class="line" id="L85">}</span>
<span class="line" id="L86"></span>
<span class="line" id="L87"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">addArgs</span>(self: *RunStep, args: []<span class="tok-kw">const</span> []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L88">    <span class="tok-kw">for</span> (args) |arg| {</span>
<span class="line" id="L89">        self.addArg(arg);</span>
<span class="line" id="L90">    }</span>
<span class="line" id="L91">}</span>
<span class="line" id="L92"></span>
<span class="line" id="L93"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">clearEnvironment</span>(self: *RunStep) <span class="tok-type">void</span> {</span>
<span class="line" id="L94">    <span class="tok-kw">const</span> new_env_map = self.builder.allocator.create(EnvMap) <span class="tok-kw">catch</span> <span class="tok-kw">unreachable</span>;</span>
<span class="line" id="L95">    new_env_map.* = EnvMap.init(self.builder.allocator);</span>
<span class="line" id="L96">    self.env_map = new_env_map;</span>
<span class="line" id="L97">}</span>
<span class="line" id="L98"></span>
<span class="line" id="L99"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">addPathDir</span>(self: *RunStep, search_path: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L100">    addPathDirInternal(&amp;self.step, self.builder, search_path);</span>
<span class="line" id="L101">}</span>
<span class="line" id="L102"></span>
<span class="line" id="L103"><span class="tok-comment">/// For internal use only, users of `RunStep` should use `addPathDir` directly.</span></span>
<span class="line" id="L104"><span class="tok-kw">fn</span> <span class="tok-fn">addPathDirInternal</span>(step: *Step, builder: *Builder, search_path: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L105">    <span class="tok-kw">const</span> env_map = getEnvMapInternal(step, builder.allocator);</span>
<span class="line" id="L106"></span>
<span class="line" id="L107">    <span class="tok-kw">const</span> key = <span class="tok-str">&quot;PATH&quot;</span>;</span>
<span class="line" id="L108">    <span class="tok-kw">var</span> prev_path = env_map.get(key);</span>
<span class="line" id="L109"></span>
<span class="line" id="L110">    <span class="tok-kw">if</span> (prev_path) |pp| {</span>
<span class="line" id="L111">        <span class="tok-kw">const</span> new_path = builder.fmt(<span class="tok-str">&quot;{s}&quot;</span> ++ [<span class="tok-number">1</span>]<span class="tok-type">u8</span>{fs.path.delimiter} ++ <span class="tok-str">&quot;{s}&quot;</span>, .{ pp, search_path });</span>
<span class="line" id="L112">        env_map.put(key, new_path) <span class="tok-kw">catch</span> <span class="tok-kw">unreachable</span>;</span>
<span class="line" id="L113">    } <span class="tok-kw">else</span> {</span>
<span class="line" id="L114">        env_map.put(key, builder.dupePath(search_path)) <span class="tok-kw">catch</span> <span class="tok-kw">unreachable</span>;</span>
<span class="line" id="L115">    }</span>
<span class="line" id="L116">}</span>
<span class="line" id="L117"></span>
<span class="line" id="L118"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">getEnvMap</span>(self: *RunStep) *EnvMap {</span>
<span class="line" id="L119">    <span class="tok-kw">return</span> getEnvMapInternal(&amp;self.step, self.builder.allocator);</span>
<span class="line" id="L120">}</span>
<span class="line" id="L121"></span>
<span class="line" id="L122"><span class="tok-kw">fn</span> <span class="tok-fn">getEnvMapInternal</span>(step: *Step, allocator: Allocator) *EnvMap {</span>
<span class="line" id="L123">    <span class="tok-kw">const</span> maybe_env_map = <span class="tok-kw">switch</span> (step.id) {</span>
<span class="line" id="L124">        .run =&gt; step.cast(RunStep).?.env_map,</span>
<span class="line" id="L125">        .emulatable_run =&gt; step.cast(build.EmulatableRunStep).?.env_map,</span>
<span class="line" id="L126">        <span class="tok-kw">else</span> =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L127">    };</span>
<span class="line" id="L128">    <span class="tok-kw">return</span> maybe_env_map <span class="tok-kw">orelse</span> {</span>
<span class="line" id="L129">        <span class="tok-kw">const</span> env_map = allocator.create(EnvMap) <span class="tok-kw">catch</span> <span class="tok-kw">unreachable</span>;</span>
<span class="line" id="L130">        env_map.* = process.getEnvMap(allocator) <span class="tok-kw">catch</span> <span class="tok-kw">unreachable</span>;</span>
<span class="line" id="L131">        <span class="tok-kw">switch</span> (step.id) {</span>
<span class="line" id="L132">            .run =&gt; step.cast(RunStep).?.env_map = env_map,</span>
<span class="line" id="L133">            .emulatable_run =&gt; step.cast(RunStep).?.env_map = env_map,</span>
<span class="line" id="L134">            <span class="tok-kw">else</span> =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L135">        }</span>
<span class="line" id="L136">        <span class="tok-kw">return</span> env_map;</span>
<span class="line" id="L137">    };</span>
<span class="line" id="L138">}</span>
<span class="line" id="L139"></span>
<span class="line" id="L140"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">setEnvironmentVariable</span>(self: *RunStep, key: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, value: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L141">    <span class="tok-kw">const</span> env_map = self.getEnvMap();</span>
<span class="line" id="L142">    env_map.put(</span>
<span class="line" id="L143">        self.builder.dupe(key),</span>
<span class="line" id="L144">        self.builder.dupe(value),</span>
<span class="line" id="L145">    ) <span class="tok-kw">catch</span> <span class="tok-kw">unreachable</span>;</span>
<span class="line" id="L146">}</span>
<span class="line" id="L147"></span>
<span class="line" id="L148"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">expectStdErrEqual</span>(self: *RunStep, bytes: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L149">    self.stderr_action = .{ .expect_exact = self.builder.dupe(bytes) };</span>
<span class="line" id="L150">}</span>
<span class="line" id="L151"></span>
<span class="line" id="L152"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">expectStdOutEqual</span>(self: *RunStep, bytes: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L153">    self.stdout_action = .{ .expect_exact = self.builder.dupe(bytes) };</span>
<span class="line" id="L154">}</span>
<span class="line" id="L155"></span>
<span class="line" id="L156"><span class="tok-kw">fn</span> <span class="tok-fn">stdIoActionToBehavior</span>(action: StdIoAction) std.ChildProcess.StdIo {</span>
<span class="line" id="L157">    <span class="tok-kw">return</span> <span class="tok-kw">switch</span> (action) {</span>
<span class="line" id="L158">        .ignore =&gt; .Ignore,</span>
<span class="line" id="L159">        .inherit =&gt; .Inherit,</span>
<span class="line" id="L160">        .expect_exact, .expect_matches =&gt; .Pipe,</span>
<span class="line" id="L161">    };</span>
<span class="line" id="L162">}</span>
<span class="line" id="L163"></span>
<span class="line" id="L164"><span class="tok-kw">fn</span> <span class="tok-fn">make</span>(step: *Step) !<span class="tok-type">void</span> {</span>
<span class="line" id="L165">    <span class="tok-kw">const</span> self = <span class="tok-builtin">@fieldParentPtr</span>(RunStep, <span class="tok-str">&quot;step&quot;</span>, step);</span>
<span class="line" id="L166"></span>
<span class="line" id="L167">    <span class="tok-kw">var</span> argv_list = ArrayList([]<span class="tok-kw">const</span> <span class="tok-type">u8</span>).init(self.builder.allocator);</span>
<span class="line" id="L168">    <span class="tok-kw">for</span> (self.argv.items) |arg| {</span>
<span class="line" id="L169">        <span class="tok-kw">switch</span> (arg) {</span>
<span class="line" id="L170">            .bytes =&gt; |bytes| <span class="tok-kw">try</span> argv_list.append(bytes),</span>
<span class="line" id="L171">            .file_source =&gt; |file| <span class="tok-kw">try</span> argv_list.append(file.getPath(self.builder)),</span>
<span class="line" id="L172">            .artifact =&gt; |artifact| {</span>
<span class="line" id="L173">                <span class="tok-kw">if</span> (artifact.target.isWindows()) {</span>
<span class="line" id="L174">                    <span class="tok-comment">// On Windows we don't have rpaths so we have to add .dll search paths to PATH</span>
</span>
<span class="line" id="L175">                    self.addPathForDynLibs(artifact);</span>
<span class="line" id="L176">                }</span>
<span class="line" id="L177">                <span class="tok-kw">const</span> executable_path = artifact.installed_path <span class="tok-kw">orelse</span> artifact.getOutputSource().getPath(self.builder);</span>
<span class="line" id="L178">                <span class="tok-kw">try</span> argv_list.append(executable_path);</span>
<span class="line" id="L179">            },</span>
<span class="line" id="L180">        }</span>
<span class="line" id="L181">    }</span>
<span class="line" id="L182"></span>
<span class="line" id="L183">    <span class="tok-kw">try</span> runCommand(</span>
<span class="line" id="L184">        argv_list.items,</span>
<span class="line" id="L185">        self.builder,</span>
<span class="line" id="L186">        self.expected_exit_code,</span>
<span class="line" id="L187">        self.stdout_action,</span>
<span class="line" id="L188">        self.stderr_action,</span>
<span class="line" id="L189">        self.stdin_behavior,</span>
<span class="line" id="L190">        self.env_map,</span>
<span class="line" id="L191">        self.cwd,</span>
<span class="line" id="L192">        self.print,</span>
<span class="line" id="L193">    );</span>
<span class="line" id="L194">}</span>
<span class="line" id="L195"></span>
<span class="line" id="L196"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">runCommand</span>(</span>
<span class="line" id="L197">    argv: []<span class="tok-kw">const</span> []<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L198">    builder: *Builder,</span>
<span class="line" id="L199">    expected_exit_code: ?<span class="tok-type">u8</span>,</span>
<span class="line" id="L200">    stdout_action: StdIoAction,</span>
<span class="line" id="L201">    stderr_action: StdIoAction,</span>
<span class="line" id="L202">    stdin_behavior: std.ChildProcess.StdIo,</span>
<span class="line" id="L203">    env_map: ?*EnvMap,</span>
<span class="line" id="L204">    maybe_cwd: ?[]<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L205">    print: <span class="tok-type">bool</span>,</span>
<span class="line" id="L206">) !<span class="tok-type">void</span> {</span>
<span class="line" id="L207">    <span class="tok-kw">const</span> cwd = <span class="tok-kw">if</span> (maybe_cwd) |cwd| builder.pathFromRoot(cwd) <span class="tok-kw">else</span> builder.build_root;</span>
<span class="line" id="L208"></span>
<span class="line" id="L209">    <span class="tok-kw">if</span> (!std.process.can_spawn) {</span>
<span class="line" id="L210">        <span class="tok-kw">const</span> cmd = <span class="tok-kw">try</span> std.mem.join(builder.addInstallDirectory, <span class="tok-str">&quot; &quot;</span>, argv);</span>
<span class="line" id="L211">        std.debug.print(<span class="tok-str">&quot;the following command cannot be executed ({s} does not support spawning a child process):\n{s}&quot;</span>, .{ <span class="tok-builtin">@tagName</span>(builtin.os.tag), cmd });</span>
<span class="line" id="L212">        builder.allocator.free(cmd);</span>
<span class="line" id="L213">        <span class="tok-kw">return</span> ExecError.ExecNotSupported;</span>
<span class="line" id="L214">    }</span>
<span class="line" id="L215"></span>
<span class="line" id="L216">    <span class="tok-kw">var</span> child = std.ChildProcess.init(argv, builder.allocator);</span>
<span class="line" id="L217">    child.cwd = cwd;</span>
<span class="line" id="L218">    child.env_map = env_map <span class="tok-kw">orelse</span> builder.env_map;</span>
<span class="line" id="L219"></span>
<span class="line" id="L220">    child.stdin_behavior = stdin_behavior;</span>
<span class="line" id="L221">    child.stdout_behavior = stdIoActionToBehavior(stdout_action);</span>
<span class="line" id="L222">    child.stderr_behavior = stdIoActionToBehavior(stderr_action);</span>
<span class="line" id="L223"></span>
<span class="line" id="L224">    <span class="tok-kw">if</span> (print)</span>
<span class="line" id="L225">        printCmd(cwd, argv);</span>
<span class="line" id="L226"></span>
<span class="line" id="L227">    child.spawn() <span class="tok-kw">catch</span> |err| {</span>
<span class="line" id="L228">        std.debug.print(<span class="tok-str">&quot;Unable to spawn {s}: {s}\n&quot;</span>, .{ argv[<span class="tok-number">0</span>], <span class="tok-builtin">@errorName</span>(err) });</span>
<span class="line" id="L229">        <span class="tok-kw">return</span> err;</span>
<span class="line" id="L230">    };</span>
<span class="line" id="L231"></span>
<span class="line" id="L232">    <span class="tok-comment">// TODO need to poll to read these streams to prevent a deadlock (or rely on evented I/O).</span>
</span>
<span class="line" id="L233"></span>
<span class="line" id="L234">    <span class="tok-kw">var</span> stdout: ?[]<span class="tok-kw">const</span> <span class="tok-type">u8</span> = <span class="tok-null">null</span>;</span>
<span class="line" id="L235">    <span class="tok-kw">defer</span> <span class="tok-kw">if</span> (stdout) |s| builder.allocator.free(s);</span>
<span class="line" id="L236"></span>
<span class="line" id="L237">    <span class="tok-kw">switch</span> (stdout_action) {</span>
<span class="line" id="L238">        .expect_exact, .expect_matches =&gt; {</span>
<span class="line" id="L239">            stdout = child.stdout.?.reader().readAllAlloc(builder.allocator, max_stdout_size) <span class="tok-kw">catch</span> <span class="tok-kw">unreachable</span>;</span>
<span class="line" id="L240">        },</span>
<span class="line" id="L241">        .inherit, .ignore =&gt; {},</span>
<span class="line" id="L242">    }</span>
<span class="line" id="L243"></span>
<span class="line" id="L244">    <span class="tok-kw">var</span> stderr: ?[]<span class="tok-kw">const</span> <span class="tok-type">u8</span> = <span class="tok-null">null</span>;</span>
<span class="line" id="L245">    <span class="tok-kw">defer</span> <span class="tok-kw">if</span> (stderr) |s| builder.allocator.free(s);</span>
<span class="line" id="L246"></span>
<span class="line" id="L247">    <span class="tok-kw">switch</span> (stderr_action) {</span>
<span class="line" id="L248">        .expect_exact, .expect_matches =&gt; {</span>
<span class="line" id="L249">            stderr = child.stderr.?.reader().readAllAlloc(builder.allocator, max_stdout_size) <span class="tok-kw">catch</span> <span class="tok-kw">unreachable</span>;</span>
<span class="line" id="L250">        },</span>
<span class="line" id="L251">        .inherit, .ignore =&gt; {},</span>
<span class="line" id="L252">    }</span>
<span class="line" id="L253"></span>
<span class="line" id="L254">    <span class="tok-kw">const</span> term = child.wait() <span class="tok-kw">catch</span> |err| {</span>
<span class="line" id="L255">        std.debug.print(<span class="tok-str">&quot;Unable to spawn {s}: {s}\n&quot;</span>, .{ argv[<span class="tok-number">0</span>], <span class="tok-builtin">@errorName</span>(err) });</span>
<span class="line" id="L256">        <span class="tok-kw">return</span> err;</span>
<span class="line" id="L257">    };</span>
<span class="line" id="L258"></span>
<span class="line" id="L259">    <span class="tok-kw">switch</span> (term) {</span>
<span class="line" id="L260">        .Exited =&gt; |code| blk: {</span>
<span class="line" id="L261">            <span class="tok-kw">const</span> expected_code = expected_exit_code <span class="tok-kw">orelse</span> <span class="tok-kw">break</span> :blk;</span>
<span class="line" id="L262"></span>
<span class="line" id="L263">            <span class="tok-kw">if</span> (code != expected_code) {</span>
<span class="line" id="L264">                <span class="tok-kw">if</span> (builder.prominent_compile_errors) {</span>
<span class="line" id="L265">                    std.debug.print(<span class="tok-str">&quot;Run step exited with error code {} (expected {})\n&quot;</span>, .{</span>
<span class="line" id="L266">                        code,</span>
<span class="line" id="L267">                        expected_code,</span>
<span class="line" id="L268">                    });</span>
<span class="line" id="L269">                } <span class="tok-kw">else</span> {</span>
<span class="line" id="L270">                    std.debug.print(<span class="tok-str">&quot;The following command exited with error code {} (expected {}):\n&quot;</span>, .{</span>
<span class="line" id="L271">                        code,</span>
<span class="line" id="L272">                        expected_code,</span>
<span class="line" id="L273">                    });</span>
<span class="line" id="L274">                    printCmd(cwd, argv);</span>
<span class="line" id="L275">                }</span>
<span class="line" id="L276"></span>
<span class="line" id="L277">                <span class="tok-kw">return</span> <span class="tok-kw">error</span>.UnexpectedExitCode;</span>
<span class="line" id="L278">            }</span>
<span class="line" id="L279">        },</span>
<span class="line" id="L280">        <span class="tok-kw">else</span> =&gt; {</span>
<span class="line" id="L281">            std.debug.print(<span class="tok-str">&quot;The following command terminated unexpectedly:\n&quot;</span>, .{});</span>
<span class="line" id="L282">            printCmd(cwd, argv);</span>
<span class="line" id="L283">            <span class="tok-kw">return</span> <span class="tok-kw">error</span>.UncleanExit;</span>
<span class="line" id="L284">        },</span>
<span class="line" id="L285">    }</span>
<span class="line" id="L286"></span>
<span class="line" id="L287">    <span class="tok-kw">switch</span> (stderr_action) {</span>
<span class="line" id="L288">        .inherit, .ignore =&gt; {},</span>
<span class="line" id="L289">        .expect_exact =&gt; |expected_bytes| {</span>
<span class="line" id="L290">            <span class="tok-kw">if</span> (!mem.eql(<span class="tok-type">u8</span>, expected_bytes, stderr.?)) {</span>
<span class="line" id="L291">                std.debug.print(</span>
<span class="line" id="L292">                    <span class="tok-str">\\</span></span>

<span class="line" id="L293">                    <span class="tok-str">\\========= Expected this stderr: =========</span></span>

<span class="line" id="L294">                    <span class="tok-str">\\{s}</span></span>

<span class="line" id="L295">                    <span class="tok-str">\\========= But found: ====================</span></span>

<span class="line" id="L296">                    <span class="tok-str">\\{s}</span></span>

<span class="line" id="L297">                    <span class="tok-str">\\</span></span>

<span class="line" id="L298">                , .{ expected_bytes, stderr.? });</span>
<span class="line" id="L299">                printCmd(cwd, argv);</span>
<span class="line" id="L300">                <span class="tok-kw">return</span> <span class="tok-kw">error</span>.TestFailed;</span>
<span class="line" id="L301">            }</span>
<span class="line" id="L302">        },</span>
<span class="line" id="L303">        .expect_matches =&gt; |matches| <span class="tok-kw">for</span> (matches) |match| {</span>
<span class="line" id="L304">            <span class="tok-kw">if</span> (mem.indexOf(<span class="tok-type">u8</span>, stderr.?, match) == <span class="tok-null">null</span>) {</span>
<span class="line" id="L305">                std.debug.print(</span>
<span class="line" id="L306">                    <span class="tok-str">\\</span></span>

<span class="line" id="L307">                    <span class="tok-str">\\========= Expected to find in stderr: =========</span></span>

<span class="line" id="L308">                    <span class="tok-str">\\{s}</span></span>

<span class="line" id="L309">                    <span class="tok-str">\\========= But stderr does not contain it: =====</span></span>

<span class="line" id="L310">                    <span class="tok-str">\\{s}</span></span>

<span class="line" id="L311">                    <span class="tok-str">\\</span></span>

<span class="line" id="L312">                , .{ match, stderr.? });</span>
<span class="line" id="L313">                printCmd(cwd, argv);</span>
<span class="line" id="L314">                <span class="tok-kw">return</span> <span class="tok-kw">error</span>.TestFailed;</span>
<span class="line" id="L315">            }</span>
<span class="line" id="L316">        },</span>
<span class="line" id="L317">    }</span>
<span class="line" id="L318"></span>
<span class="line" id="L319">    <span class="tok-kw">switch</span> (stdout_action) {</span>
<span class="line" id="L320">        .inherit, .ignore =&gt; {},</span>
<span class="line" id="L321">        .expect_exact =&gt; |expected_bytes| {</span>
<span class="line" id="L322">            <span class="tok-kw">if</span> (!mem.eql(<span class="tok-type">u8</span>, expected_bytes, stdout.?)) {</span>
<span class="line" id="L323">                std.debug.print(</span>
<span class="line" id="L324">                    <span class="tok-str">\\</span></span>

<span class="line" id="L325">                    <span class="tok-str">\\========= Expected this stdout: =========</span></span>

<span class="line" id="L326">                    <span class="tok-str">\\{s}</span></span>

<span class="line" id="L327">                    <span class="tok-str">\\========= But found: ====================</span></span>

<span class="line" id="L328">                    <span class="tok-str">\\{s}</span></span>

<span class="line" id="L329">                    <span class="tok-str">\\</span></span>

<span class="line" id="L330">                , .{ expected_bytes, stdout.? });</span>
<span class="line" id="L331">                printCmd(cwd, argv);</span>
<span class="line" id="L332">                <span class="tok-kw">return</span> <span class="tok-kw">error</span>.TestFailed;</span>
<span class="line" id="L333">            }</span>
<span class="line" id="L334">        },</span>
<span class="line" id="L335">        .expect_matches =&gt; |matches| <span class="tok-kw">for</span> (matches) |match| {</span>
<span class="line" id="L336">            <span class="tok-kw">if</span> (mem.indexOf(<span class="tok-type">u8</span>, stdout.?, match) == <span class="tok-null">null</span>) {</span>
<span class="line" id="L337">                std.debug.print(</span>
<span class="line" id="L338">                    <span class="tok-str">\\</span></span>

<span class="line" id="L339">                    <span class="tok-str">\\========= Expected to find in stdout: =========</span></span>

<span class="line" id="L340">                    <span class="tok-str">\\{s}</span></span>

<span class="line" id="L341">                    <span class="tok-str">\\========= But stdout does not contain it: =====</span></span>

<span class="line" id="L342">                    <span class="tok-str">\\{s}</span></span>

<span class="line" id="L343">                    <span class="tok-str">\\</span></span>

<span class="line" id="L344">                , .{ match, stdout.? });</span>
<span class="line" id="L345">                printCmd(cwd, argv);</span>
<span class="line" id="L346">                <span class="tok-kw">return</span> <span class="tok-kw">error</span>.TestFailed;</span>
<span class="line" id="L347">            }</span>
<span class="line" id="L348">        },</span>
<span class="line" id="L349">    }</span>
<span class="line" id="L350">}</span>
<span class="line" id="L351"></span>
<span class="line" id="L352"><span class="tok-kw">fn</span> <span class="tok-fn">printCmd</span>(cwd: ?[]<span class="tok-kw">const</span> <span class="tok-type">u8</span>, argv: []<span class="tok-kw">const</span> []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L353">    <span class="tok-kw">if</span> (cwd) |yes_cwd| std.debug.print(<span class="tok-str">&quot;cd {s} &amp;&amp; &quot;</span>, .{yes_cwd});</span>
<span class="line" id="L354">    <span class="tok-kw">for</span> (argv) |arg| {</span>
<span class="line" id="L355">        std.debug.print(<span class="tok-str">&quot;{s} &quot;</span>, .{arg});</span>
<span class="line" id="L356">    }</span>
<span class="line" id="L357">    std.debug.print(<span class="tok-str">&quot;\n&quot;</span>, .{});</span>
<span class="line" id="L358">}</span>
<span class="line" id="L359"></span>
<span class="line" id="L360"><span class="tok-kw">fn</span> <span class="tok-fn">addPathForDynLibs</span>(self: *RunStep, artifact: *LibExeObjStep) <span class="tok-type">void</span> {</span>
<span class="line" id="L361">    addPathForDynLibsInternal(&amp;self.step, self.builder, artifact);</span>
<span class="line" id="L362">}</span>
<span class="line" id="L363"></span>
<span class="line" id="L364"><span class="tok-comment">/// This should only be used for internal usage, this is called automatically</span></span>
<span class="line" id="L365"><span class="tok-comment">/// for the user.</span></span>
<span class="line" id="L366"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">addPathForDynLibsInternal</span>(step: *Step, builder: *Builder, artifact: *LibExeObjStep) <span class="tok-type">void</span> {</span>
<span class="line" id="L367">    <span class="tok-kw">for</span> (artifact.link_objects.items) |link_object| {</span>
<span class="line" id="L368">        <span class="tok-kw">switch</span> (link_object) {</span>
<span class="line" id="L369">            .other_step =&gt; |other| {</span>
<span class="line" id="L370">                <span class="tok-kw">if</span> (other.target.isWindows() <span class="tok-kw">and</span> other.isDynamicLibrary()) {</span>
<span class="line" id="L371">                    addPathDirInternal(step, builder, fs.path.dirname(other.getOutputSource().getPath(builder)).?);</span>
<span class="line" id="L372">                    addPathForDynLibsInternal(step, builder, other);</span>
<span class="line" id="L373">                }</span>
<span class="line" id="L374">            },</span>
<span class="line" id="L375">            <span class="tok-kw">else</span> =&gt; {},</span>
<span class="line" id="L376">        }</span>
<span class="line" id="L377">    }</span>
<span class="line" id="L378">}</span>
<span class="line" id="L379"></span>
</code></pre></body>
</html>