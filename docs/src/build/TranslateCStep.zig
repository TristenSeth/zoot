<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">    <title>build/TranslateCStep.zig - source view</title>
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
<span class="line" id="L2"><span class="tok-kw">const</span> build = std.build;</span>
<span class="line" id="L3"><span class="tok-kw">const</span> Step = build.Step;</span>
<span class="line" id="L4"><span class="tok-kw">const</span> Builder = build.Builder;</span>
<span class="line" id="L5"><span class="tok-kw">const</span> LibExeObjStep = build.LibExeObjStep;</span>
<span class="line" id="L6"><span class="tok-kw">const</span> CheckFileStep = build.CheckFileStep;</span>
<span class="line" id="L7"><span class="tok-kw">const</span> fs = std.fs;</span>
<span class="line" id="L8"><span class="tok-kw">const</span> mem = std.mem;</span>
<span class="line" id="L9"><span class="tok-kw">const</span> CrossTarget = std.zig.CrossTarget;</span>
<span class="line" id="L10"></span>
<span class="line" id="L11"><span class="tok-kw">const</span> TranslateCStep = <span class="tok-builtin">@This</span>();</span>
<span class="line" id="L12"></span>
<span class="line" id="L13"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> base_id = .translate_c;</span>
<span class="line" id="L14"></span>
<span class="line" id="L15">step: Step,</span>
<span class="line" id="L16">builder: *Builder,</span>
<span class="line" id="L17">source: build.FileSource,</span>
<span class="line" id="L18">include_dirs: std.ArrayList([]<span class="tok-kw">const</span> <span class="tok-type">u8</span>),</span>
<span class="line" id="L19">c_macros: std.ArrayList([]<span class="tok-kw">const</span> <span class="tok-type">u8</span>),</span>
<span class="line" id="L20">output_dir: ?[]<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L21">out_basename: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L22">target: CrossTarget = CrossTarget{},</span>
<span class="line" id="L23">output_file: build.GeneratedFile,</span>
<span class="line" id="L24"></span>
<span class="line" id="L25"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">create</span>(builder: *Builder, source: build.FileSource) *TranslateCStep {</span>
<span class="line" id="L26">    <span class="tok-kw">const</span> self = builder.allocator.create(TranslateCStep) <span class="tok-kw">catch</span> <span class="tok-kw">unreachable</span>;</span>
<span class="line" id="L27">    self.* = TranslateCStep{</span>
<span class="line" id="L28">        .step = Step.init(.translate_c, <span class="tok-str">&quot;translate-c&quot;</span>, builder.allocator, make),</span>
<span class="line" id="L29">        .builder = builder,</span>
<span class="line" id="L30">        .source = source,</span>
<span class="line" id="L31">        .include_dirs = std.ArrayList([]<span class="tok-kw">const</span> <span class="tok-type">u8</span>).init(builder.allocator),</span>
<span class="line" id="L32">        .c_macros = std.ArrayList([]<span class="tok-kw">const</span> <span class="tok-type">u8</span>).init(builder.allocator),</span>
<span class="line" id="L33">        .output_dir = <span class="tok-null">null</span>,</span>
<span class="line" id="L34">        .out_basename = <span class="tok-null">undefined</span>,</span>
<span class="line" id="L35">        .output_file = build.GeneratedFile{ .step = &amp;self.step },</span>
<span class="line" id="L36">    };</span>
<span class="line" id="L37">    source.addStepDependencies(&amp;self.step);</span>
<span class="line" id="L38">    <span class="tok-kw">return</span> self;</span>
<span class="line" id="L39">}</span>
<span class="line" id="L40"></span>
<span class="line" id="L41"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">setTarget</span>(self: *TranslateCStep, target: CrossTarget) <span class="tok-type">void</span> {</span>
<span class="line" id="L42">    self.target = target;</span>
<span class="line" id="L43">}</span>
<span class="line" id="L44"></span>
<span class="line" id="L45"><span class="tok-comment">/// Creates a step to build an executable from the translated source.</span></span>
<span class="line" id="L46"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">addExecutable</span>(self: *TranslateCStep) *LibExeObjStep {</span>
<span class="line" id="L47">    <span class="tok-kw">return</span> self.builder.addExecutableSource(<span class="tok-str">&quot;translated_c&quot;</span>, build.FileSource{ .generated = &amp;self.output_file });</span>
<span class="line" id="L48">}</span>
<span class="line" id="L49"></span>
<span class="line" id="L50"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">addIncludeDir</span>(self: *TranslateCStep, include_dir: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L51">    self.include_dirs.append(self.builder.dupePath(include_dir)) <span class="tok-kw">catch</span> <span class="tok-kw">unreachable</span>;</span>
<span class="line" id="L52">}</span>
<span class="line" id="L53"></span>
<span class="line" id="L54"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">addCheckFile</span>(self: *TranslateCStep, expected_matches: []<span class="tok-kw">const</span> []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) *CheckFileStep {</span>
<span class="line" id="L55">    <span class="tok-kw">return</span> CheckFileStep.create(self.builder, .{ .generated = &amp;self.output_file }, self.builder.dupeStrings(expected_matches));</span>
<span class="line" id="L56">}</span>
<span class="line" id="L57"></span>
<span class="line" id="L58"><span class="tok-comment">/// If the value is omitted, it is set to 1.</span></span>
<span class="line" id="L59"><span class="tok-comment">/// `name` and `value` need not live longer than the function call.</span></span>
<span class="line" id="L60"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">defineCMacro</span>(self: *TranslateCStep, name: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, value: ?[]<span class="tok-kw">const</span> <span class="tok-type">u8</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L61">    <span class="tok-kw">const</span> macro = build.constructCMacro(self.builder.allocator, name, value);</span>
<span class="line" id="L62">    self.c_macros.append(macro) <span class="tok-kw">catch</span> <span class="tok-kw">unreachable</span>;</span>
<span class="line" id="L63">}</span>
<span class="line" id="L64"></span>
<span class="line" id="L65"><span class="tok-comment">/// name_and_value looks like [name]=[value]. If the value is omitted, it is set to 1.</span></span>
<span class="line" id="L66"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">defineCMacroRaw</span>(self: *TranslateCStep, name_and_value: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L67">    self.c_macros.append(self.builder.dupe(name_and_value)) <span class="tok-kw">catch</span> <span class="tok-kw">unreachable</span>;</span>
<span class="line" id="L68">}</span>
<span class="line" id="L69"></span>
<span class="line" id="L70"><span class="tok-kw">fn</span> <span class="tok-fn">make</span>(step: *Step) !<span class="tok-type">void</span> {</span>
<span class="line" id="L71">    <span class="tok-kw">const</span> self = <span class="tok-builtin">@fieldParentPtr</span>(TranslateCStep, <span class="tok-str">&quot;step&quot;</span>, step);</span>
<span class="line" id="L72"></span>
<span class="line" id="L73">    <span class="tok-kw">var</span> argv_list = std.ArrayList([]<span class="tok-kw">const</span> <span class="tok-type">u8</span>).init(self.builder.allocator);</span>
<span class="line" id="L74">    <span class="tok-kw">try</span> argv_list.append(self.builder.zig_exe);</span>
<span class="line" id="L75">    <span class="tok-kw">try</span> argv_list.append(<span class="tok-str">&quot;translate-c&quot;</span>);</span>
<span class="line" id="L76">    <span class="tok-kw">try</span> argv_list.append(<span class="tok-str">&quot;-lc&quot;</span>);</span>
<span class="line" id="L77"></span>
<span class="line" id="L78">    <span class="tok-kw">try</span> argv_list.append(<span class="tok-str">&quot;--enable-cache&quot;</span>);</span>
<span class="line" id="L79"></span>
<span class="line" id="L80">    <span class="tok-kw">if</span> (!self.target.isNative()) {</span>
<span class="line" id="L81">        <span class="tok-kw">try</span> argv_list.append(<span class="tok-str">&quot;-target&quot;</span>);</span>
<span class="line" id="L82">        <span class="tok-kw">try</span> argv_list.append(<span class="tok-kw">try</span> self.target.zigTriple(self.builder.allocator));</span>
<span class="line" id="L83">    }</span>
<span class="line" id="L84"></span>
<span class="line" id="L85">    <span class="tok-kw">for</span> (self.include_dirs.items) |include_dir| {</span>
<span class="line" id="L86">        <span class="tok-kw">try</span> argv_list.append(<span class="tok-str">&quot;-I&quot;</span>);</span>
<span class="line" id="L87">        <span class="tok-kw">try</span> argv_list.append(include_dir);</span>
<span class="line" id="L88">    }</span>
<span class="line" id="L89"></span>
<span class="line" id="L90">    <span class="tok-kw">for</span> (self.c_macros.items) |c_macro| {</span>
<span class="line" id="L91">        <span class="tok-kw">try</span> argv_list.append(<span class="tok-str">&quot;-D&quot;</span>);</span>
<span class="line" id="L92">        <span class="tok-kw">try</span> argv_list.append(c_macro);</span>
<span class="line" id="L93">    }</span>
<span class="line" id="L94"></span>
<span class="line" id="L95">    <span class="tok-kw">try</span> argv_list.append(self.source.getPath(self.builder));</span>
<span class="line" id="L96"></span>
<span class="line" id="L97">    <span class="tok-kw">const</span> output_path_nl = <span class="tok-kw">try</span> self.builder.execFromStep(argv_list.items, &amp;self.step);</span>
<span class="line" id="L98">    <span class="tok-kw">const</span> output_path = mem.trimRight(<span class="tok-type">u8</span>, output_path_nl, <span class="tok-str">&quot;\r\n&quot;</span>);</span>
<span class="line" id="L99"></span>
<span class="line" id="L100">    self.out_basename = fs.path.basename(output_path);</span>
<span class="line" id="L101">    <span class="tok-kw">if</span> (self.output_dir) |output_dir| {</span>
<span class="line" id="L102">        <span class="tok-kw">const</span> full_dest = <span class="tok-kw">try</span> fs.path.join(self.builder.allocator, &amp;[_][]<span class="tok-kw">const</span> <span class="tok-type">u8</span>{ output_dir, self.out_basename });</span>
<span class="line" id="L103">        <span class="tok-kw">try</span> self.builder.updateFile(output_path, full_dest);</span>
<span class="line" id="L104">    } <span class="tok-kw">else</span> {</span>
<span class="line" id="L105">        self.output_dir = fs.path.dirname(output_path).?;</span>
<span class="line" id="L106">    }</span>
<span class="line" id="L107"></span>
<span class="line" id="L108">    self.output_file.path = fs.path.join(</span>
<span class="line" id="L109">        self.builder.allocator,</span>
<span class="line" id="L110">        &amp;[_][]<span class="tok-kw">const</span> <span class="tok-type">u8</span>{ self.output_dir.?, self.out_basename },</span>
<span class="line" id="L111">    ) <span class="tok-kw">catch</span> <span class="tok-kw">unreachable</span>;</span>
<span class="line" id="L112">}</span>
<span class="line" id="L113"></span>
</code></pre></body>
</html>