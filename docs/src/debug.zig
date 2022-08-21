<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">    <title>debug.zig - source view</title>
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
<span class="line" id="L3"><span class="tok-kw">const</span> math = std.math;</span>
<span class="line" id="L4"><span class="tok-kw">const</span> mem = std.mem;</span>
<span class="line" id="L5"><span class="tok-kw">const</span> io = std.io;</span>
<span class="line" id="L6"><span class="tok-kw">const</span> os = std.os;</span>
<span class="line" id="L7"><span class="tok-kw">const</span> fs = std.fs;</span>
<span class="line" id="L8"><span class="tok-kw">const</span> process = std.process;</span>
<span class="line" id="L9"><span class="tok-kw">const</span> testing = std.testing;</span>
<span class="line" id="L10"><span class="tok-kw">const</span> elf = std.elf;</span>
<span class="line" id="L11"><span class="tok-kw">const</span> DW = std.dwarf;</span>
<span class="line" id="L12"><span class="tok-kw">const</span> macho = std.macho;</span>
<span class="line" id="L13"><span class="tok-kw">const</span> coff = std.coff;</span>
<span class="line" id="L14"><span class="tok-kw">const</span> pdb = std.pdb;</span>
<span class="line" id="L15"><span class="tok-kw">const</span> ArrayList = std.ArrayList;</span>
<span class="line" id="L16"><span class="tok-kw">const</span> root = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;root&quot;</span>);</span>
<span class="line" id="L17"><span class="tok-kw">const</span> maxInt = std.math.maxInt;</span>
<span class="line" id="L18"><span class="tok-kw">const</span> File = std.fs.File;</span>
<span class="line" id="L19"><span class="tok-kw">const</span> windows = std.os.windows;</span>
<span class="line" id="L20"><span class="tok-kw">const</span> native_arch = builtin.cpu.arch;</span>
<span class="line" id="L21"><span class="tok-kw">const</span> native_os = builtin.os.tag;</span>
<span class="line" id="L22"><span class="tok-kw">const</span> native_endian = native_arch.endian();</span>
<span class="line" id="L23"></span>
<span class="line" id="L24"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> runtime_safety = <span class="tok-kw">switch</span> (builtin.mode) {</span>
<span class="line" id="L25">    .Debug, .ReleaseSafe =&gt; <span class="tok-null">true</span>,</span>
<span class="line" id="L26">    .ReleaseFast, .ReleaseSmall =&gt; <span class="tok-null">false</span>,</span>
<span class="line" id="L27">};</span>
<span class="line" id="L28"></span>
<span class="line" id="L29"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> sys_can_stack_trace = <span class="tok-kw">switch</span> (builtin.cpu.arch) {</span>
<span class="line" id="L30">    <span class="tok-comment">// Observed to go into an infinite loop.</span>
</span>
<span class="line" id="L31">    <span class="tok-comment">// TODO: Make this work.</span>
</span>
<span class="line" id="L32">    .mips,</span>
<span class="line" id="L33">    .mipsel,</span>
<span class="line" id="L34">    =&gt; <span class="tok-null">false</span>,</span>
<span class="line" id="L35"></span>
<span class="line" id="L36">    <span class="tok-comment">// `@returnAddress()` in LLVM 10 gives</span>
</span>
<span class="line" id="L37">    <span class="tok-comment">// &quot;Non-Emscripten WebAssembly hasn't implemented __builtin_return_address&quot;.</span>
</span>
<span class="line" id="L38">    .wasm32,</span>
<span class="line" id="L39">    .wasm64,</span>
<span class="line" id="L40">    =&gt; builtin.os.tag == .emscripten,</span>
<span class="line" id="L41"></span>
<span class="line" id="L42">    <span class="tok-comment">// `@returnAddress()` is unsupported in LLVM 13.</span>
</span>
<span class="line" id="L43">    .bpfel,</span>
<span class="line" id="L44">    .bpfeb,</span>
<span class="line" id="L45">    =&gt; <span class="tok-null">false</span>,</span>
<span class="line" id="L46"></span>
<span class="line" id="L47">    <span class="tok-kw">else</span> =&gt; <span class="tok-null">true</span>,</span>
<span class="line" id="L48">};</span>
<span class="line" id="L49"></span>
<span class="line" id="L50"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> LineInfo = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L51">    line: <span class="tok-type">u64</span>,</span>
<span class="line" id="L52">    column: <span class="tok-type">u64</span>,</span>
<span class="line" id="L53">    file_name: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L54"></span>
<span class="line" id="L55">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">deinit</span>(self: LineInfo, allocator: mem.Allocator) <span class="tok-type">void</span> {</span>
<span class="line" id="L56">        allocator.free(self.file_name);</span>
<span class="line" id="L57">    }</span>
<span class="line" id="L58">};</span>
<span class="line" id="L59"></span>
<span class="line" id="L60"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SymbolInfo = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L61">    symbol_name: []<span class="tok-kw">const</span> <span class="tok-type">u8</span> = <span class="tok-str">&quot;???&quot;</span>,</span>
<span class="line" id="L62">    compile_unit_name: []<span class="tok-kw">const</span> <span class="tok-type">u8</span> = <span class="tok-str">&quot;???&quot;</span>,</span>
<span class="line" id="L63">    line_info: ?LineInfo = <span class="tok-null">null</span>,</span>
<span class="line" id="L64"></span>
<span class="line" id="L65">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">deinit</span>(self: SymbolInfo, allocator: mem.Allocator) <span class="tok-type">void</span> {</span>
<span class="line" id="L66">        <span class="tok-kw">if</span> (self.line_info) |li| {</span>
<span class="line" id="L67">            li.deinit(allocator);</span>
<span class="line" id="L68">        }</span>
<span class="line" id="L69">    }</span>
<span class="line" id="L70">};</span>
<span class="line" id="L71"><span class="tok-kw">const</span> PdbOrDwarf = <span class="tok-kw">union</span>(<span class="tok-kw">enum</span>) {</span>
<span class="line" id="L72">    pdb: pdb.Pdb,</span>
<span class="line" id="L73">    dwarf: DW.DwarfInfo,</span>
<span class="line" id="L74"></span>
<span class="line" id="L75">    <span class="tok-kw">fn</span> <span class="tok-fn">deinit</span>(self: *PdbOrDwarf, allocator: mem.Allocator) <span class="tok-type">void</span> {</span>
<span class="line" id="L76">        <span class="tok-kw">switch</span> (self.*) {</span>
<span class="line" id="L77">            .pdb =&gt; |*inner| inner.deinit(),</span>
<span class="line" id="L78">            .dwarf =&gt; |*inner| inner.deinit(allocator),</span>
<span class="line" id="L79">        }</span>
<span class="line" id="L80">    }</span>
<span class="line" id="L81">};</span>
<span class="line" id="L82"></span>
<span class="line" id="L83"><span class="tok-kw">var</span> stderr_mutex = std.Thread.Mutex{};</span>
<span class="line" id="L84"></span>
<span class="line" id="L85"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> warn = <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;deprecated; use `std.log` functions for logging or `std.debug.print` for 'printf debugging'&quot;</span>);</span>
<span class="line" id="L86"></span>
<span class="line" id="L87"><span class="tok-comment">/// Print to stderr, unbuffered, and silently returning on failure. Intended</span></span>
<span class="line" id="L88"><span class="tok-comment">/// for use in &quot;printf debugging.&quot; Use `std.log` functions for proper logging.</span></span>
<span class="line" id="L89"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">print</span>(<span class="tok-kw">comptime</span> fmt: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, args: <span class="tok-kw">anytype</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L90">    stderr_mutex.lock();</span>
<span class="line" id="L91">    <span class="tok-kw">defer</span> stderr_mutex.unlock();</span>
<span class="line" id="L92">    <span class="tok-kw">const</span> stderr = io.getStdErr().writer();</span>
<span class="line" id="L93">    <span class="tok-kw">nosuspend</span> stderr.print(fmt, args) <span class="tok-kw">catch</span> <span class="tok-kw">return</span>;</span>
<span class="line" id="L94">}</span>
<span class="line" id="L95"></span>
<span class="line" id="L96"><span class="tok-comment">/// Indicates code that is unfinshed. It will throw a compiler error by default in Release mode.</span></span>
<span class="line" id="L97"><span class="tok-comment">/// This behaviour can be controlled with `root.allow_todo_in_release`.</span></span>
<span class="line" id="L98"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">todo</span>(<span class="tok-kw">comptime</span> desc: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) <span class="tok-type">noreturn</span> {</span>
<span class="line" id="L99">    <span class="tok-kw">if</span> (builtin.mode != .Debug <span class="tok-kw">and</span> !(<span class="tok-builtin">@hasDecl</span>(root, <span class="tok-str">&quot;allow_todo_in_release&quot;</span>) <span class="tok-kw">and</span> root.allow_todo_in_release)) {</span>
<span class="line" id="L100">        <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;TODO: &quot;</span> ++ desc);</span>
<span class="line" id="L101">    }</span>
<span class="line" id="L102">    <span class="tok-builtin">@panic</span>(<span class="tok-str">&quot;TODO: &quot;</span> ++ desc);</span>
<span class="line" id="L103">}</span>
<span class="line" id="L104"></span>
<span class="line" id="L105"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">getStderrMutex</span>() *std.Thread.Mutex {</span>
<span class="line" id="L106">    <span class="tok-kw">return</span> &amp;stderr_mutex;</span>
<span class="line" id="L107">}</span>
<span class="line" id="L108"></span>
<span class="line" id="L109"><span class="tok-comment">/// TODO multithreaded awareness</span></span>
<span class="line" id="L110"><span class="tok-kw">var</span> self_debug_info: ?DebugInfo = <span class="tok-null">null</span>;</span>
<span class="line" id="L111"></span>
<span class="line" id="L112"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">getSelfDebugInfo</span>() !*DebugInfo {</span>
<span class="line" id="L113">    <span class="tok-kw">if</span> (self_debug_info) |*info| {</span>
<span class="line" id="L114">        <span class="tok-kw">return</span> info;</span>
<span class="line" id="L115">    } <span class="tok-kw">else</span> {</span>
<span class="line" id="L116">        self_debug_info = <span class="tok-kw">try</span> openSelfDebugInfo(getDebugInfoAllocator());</span>
<span class="line" id="L117">        <span class="tok-kw">return</span> &amp;self_debug_info.?;</span>
<span class="line" id="L118">    }</span>
<span class="line" id="L119">}</span>
<span class="line" id="L120"></span>
<span class="line" id="L121"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">detectTTYConfig</span>() TTY.Config {</span>
<span class="line" id="L122">    <span class="tok-kw">if</span> (process.hasEnvVarConstant(<span class="tok-str">&quot;ZIG_DEBUG_COLOR&quot;</span>)) {</span>
<span class="line" id="L123">        <span class="tok-kw">return</span> .escape_codes;</span>
<span class="line" id="L124">    } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (process.hasEnvVarConstant(<span class="tok-str">&quot;NO_COLOR&quot;</span>)) {</span>
<span class="line" id="L125">        <span class="tok-kw">return</span> .no_color;</span>
<span class="line" id="L126">    } <span class="tok-kw">else</span> {</span>
<span class="line" id="L127">        <span class="tok-kw">const</span> stderr_file = io.getStdErr();</span>
<span class="line" id="L128">        <span class="tok-kw">if</span> (stderr_file.supportsAnsiEscapeCodes()) {</span>
<span class="line" id="L129">            <span class="tok-kw">return</span> .escape_codes;</span>
<span class="line" id="L130">        } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (native_os == .windows <span class="tok-kw">and</span> stderr_file.isTty()) {</span>
<span class="line" id="L131">            <span class="tok-kw">return</span> .windows_api;</span>
<span class="line" id="L132">        } <span class="tok-kw">else</span> {</span>
<span class="line" id="L133">            <span class="tok-kw">return</span> .no_color;</span>
<span class="line" id="L134">        }</span>
<span class="line" id="L135">    }</span>
<span class="line" id="L136">}</span>
<span class="line" id="L137"></span>
<span class="line" id="L138"><span class="tok-comment">/// Tries to print the current stack trace to stderr, unbuffered, and ignores any error returned.</span></span>
<span class="line" id="L139"><span class="tok-comment">/// TODO multithreaded awareness</span></span>
<span class="line" id="L140"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">dumpCurrentStackTrace</span>(start_addr: ?<span class="tok-type">usize</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L141">    <span class="tok-kw">nosuspend</span> {</span>
<span class="line" id="L142">        <span class="tok-kw">if</span> (<span class="tok-kw">comptime</span> builtin.target.isWasm()) {</span>
<span class="line" id="L143">            <span class="tok-kw">if</span> (native_os == .wasi) {</span>
<span class="line" id="L144">                <span class="tok-kw">const</span> stderr = io.getStdErr().writer();</span>
<span class="line" id="L145">                stderr.print(<span class="tok-str">&quot;Unable to dump stack trace: not implemented for Wasm\n&quot;</span>, .{}) <span class="tok-kw">catch</span> <span class="tok-kw">return</span>;</span>
<span class="line" id="L146">            }</span>
<span class="line" id="L147">            <span class="tok-kw">return</span>;</span>
<span class="line" id="L148">        }</span>
<span class="line" id="L149">        <span class="tok-kw">const</span> stderr = io.getStdErr().writer();</span>
<span class="line" id="L150">        <span class="tok-kw">if</span> (builtin.strip_debug_info) {</span>
<span class="line" id="L151">            stderr.print(<span class="tok-str">&quot;Unable to dump stack trace: debug info stripped\n&quot;</span>, .{}) <span class="tok-kw">catch</span> <span class="tok-kw">return</span>;</span>
<span class="line" id="L152">            <span class="tok-kw">return</span>;</span>
<span class="line" id="L153">        }</span>
<span class="line" id="L154">        <span class="tok-kw">const</span> debug_info = getSelfDebugInfo() <span class="tok-kw">catch</span> |err| {</span>
<span class="line" id="L155">            stderr.print(<span class="tok-str">&quot;Unable to dump stack trace: Unable to open debug info: {s}\n&quot;</span>, .{<span class="tok-builtin">@errorName</span>(err)}) <span class="tok-kw">catch</span> <span class="tok-kw">return</span>;</span>
<span class="line" id="L156">            <span class="tok-kw">return</span>;</span>
<span class="line" id="L157">        };</span>
<span class="line" id="L158">        writeCurrentStackTrace(stderr, debug_info, detectTTYConfig(), start_addr) <span class="tok-kw">catch</span> |err| {</span>
<span class="line" id="L159">            stderr.print(<span class="tok-str">&quot;Unable to dump stack trace: {s}\n&quot;</span>, .{<span class="tok-builtin">@errorName</span>(err)}) <span class="tok-kw">catch</span> <span class="tok-kw">return</span>;</span>
<span class="line" id="L160">            <span class="tok-kw">return</span>;</span>
<span class="line" id="L161">        };</span>
<span class="line" id="L162">    }</span>
<span class="line" id="L163">}</span>
<span class="line" id="L164"></span>
<span class="line" id="L165"><span class="tok-comment">/// Tries to print the stack trace starting from the supplied base pointer to stderr,</span></span>
<span class="line" id="L166"><span class="tok-comment">/// unbuffered, and ignores any error returned.</span></span>
<span class="line" id="L167"><span class="tok-comment">/// TODO multithreaded awareness</span></span>
<span class="line" id="L168"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">dumpStackTraceFromBase</span>(bp: <span class="tok-type">usize</span>, ip: <span class="tok-type">usize</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L169">    <span class="tok-kw">nosuspend</span> {</span>
<span class="line" id="L170">        <span class="tok-kw">if</span> (<span class="tok-kw">comptime</span> builtin.target.isWasm()) {</span>
<span class="line" id="L171">            <span class="tok-kw">if</span> (native_os == .wasi) {</span>
<span class="line" id="L172">                <span class="tok-kw">const</span> stderr = io.getStdErr().writer();</span>
<span class="line" id="L173">                stderr.print(<span class="tok-str">&quot;Unable to dump stack trace: not implemented for Wasm\n&quot;</span>, .{}) <span class="tok-kw">catch</span> <span class="tok-kw">return</span>;</span>
<span class="line" id="L174">            }</span>
<span class="line" id="L175">            <span class="tok-kw">return</span>;</span>
<span class="line" id="L176">        }</span>
<span class="line" id="L177">        <span class="tok-kw">const</span> stderr = io.getStdErr().writer();</span>
<span class="line" id="L178">        <span class="tok-kw">if</span> (builtin.strip_debug_info) {</span>
<span class="line" id="L179">            stderr.print(<span class="tok-str">&quot;Unable to dump stack trace: debug info stripped\n&quot;</span>, .{}) <span class="tok-kw">catch</span> <span class="tok-kw">return</span>;</span>
<span class="line" id="L180">            <span class="tok-kw">return</span>;</span>
<span class="line" id="L181">        }</span>
<span class="line" id="L182">        <span class="tok-kw">const</span> debug_info = getSelfDebugInfo() <span class="tok-kw">catch</span> |err| {</span>
<span class="line" id="L183">            stderr.print(<span class="tok-str">&quot;Unable to dump stack trace: Unable to open debug info: {s}\n&quot;</span>, .{<span class="tok-builtin">@errorName</span>(err)}) <span class="tok-kw">catch</span> <span class="tok-kw">return</span>;</span>
<span class="line" id="L184">            <span class="tok-kw">return</span>;</span>
<span class="line" id="L185">        };</span>
<span class="line" id="L186">        <span class="tok-kw">const</span> tty_config = detectTTYConfig();</span>
<span class="line" id="L187">        printSourceAtAddress(debug_info, stderr, ip, tty_config) <span class="tok-kw">catch</span> <span class="tok-kw">return</span>;</span>
<span class="line" id="L188">        <span class="tok-kw">var</span> it = StackIterator.init(<span class="tok-null">null</span>, bp);</span>
<span class="line" id="L189">        <span class="tok-kw">while</span> (it.next()) |return_address| {</span>
<span class="line" id="L190">            printSourceAtAddress(debug_info, stderr, return_address - <span class="tok-number">1</span>, tty_config) <span class="tok-kw">catch</span> <span class="tok-kw">return</span>;</span>
<span class="line" id="L191">        }</span>
<span class="line" id="L192">    }</span>
<span class="line" id="L193">}</span>
<span class="line" id="L194"></span>
<span class="line" id="L195"><span class="tok-comment">/// Returns a slice with the same pointer as addresses, with a potentially smaller len.</span></span>
<span class="line" id="L196"><span class="tok-comment">/// On Windows, when first_address is not null, we ask for at least 32 stack frames,</span></span>
<span class="line" id="L197"><span class="tok-comment">/// and then try to find the first address. If addresses.len is more than 32, we</span></span>
<span class="line" id="L198"><span class="tok-comment">/// capture that many stack frames exactly, and then look for the first address,</span></span>
<span class="line" id="L199"><span class="tok-comment">/// chopping off the irrelevant frames and shifting so that the returned addresses pointer</span></span>
<span class="line" id="L200"><span class="tok-comment">/// equals the passed in addresses pointer.</span></span>
<span class="line" id="L201"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">captureStackTrace</span>(first_address: ?<span class="tok-type">usize</span>, stack_trace: *std.builtin.StackTrace) <span class="tok-type">void</span> {</span>
<span class="line" id="L202">    <span class="tok-kw">if</span> (native_os == .windows) {</span>
<span class="line" id="L203">        <span class="tok-kw">const</span> addrs = stack_trace.instruction_addresses;</span>
<span class="line" id="L204">        <span class="tok-kw">const</span> first_addr = first_address <span class="tok-kw">orelse</span> {</span>
<span class="line" id="L205">            stack_trace.index = windows.ntdll.RtlCaptureStackBackTrace(</span>
<span class="line" id="L206">                <span class="tok-number">0</span>,</span>
<span class="line" id="L207">                <span class="tok-builtin">@intCast</span>(<span class="tok-type">u32</span>, addrs.len),</span>
<span class="line" id="L208">                <span class="tok-builtin">@ptrCast</span>(**<span class="tok-type">anyopaque</span>, addrs.ptr),</span>
<span class="line" id="L209">                <span class="tok-null">null</span>,</span>
<span class="line" id="L210">            );</span>
<span class="line" id="L211">            <span class="tok-kw">return</span>;</span>
<span class="line" id="L212">        };</span>
<span class="line" id="L213">        <span class="tok-kw">var</span> addr_buf_stack: [<span class="tok-number">32</span>]<span class="tok-type">usize</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L214">        <span class="tok-kw">const</span> addr_buf = <span class="tok-kw">if</span> (addr_buf_stack.len &gt; addrs.len) addr_buf_stack[<span class="tok-number">0</span>..] <span class="tok-kw">else</span> addrs;</span>
<span class="line" id="L215">        <span class="tok-kw">const</span> n = windows.ntdll.RtlCaptureStackBackTrace(<span class="tok-number">0</span>, <span class="tok-builtin">@intCast</span>(<span class="tok-type">u32</span>, addr_buf.len), <span class="tok-builtin">@ptrCast</span>(**<span class="tok-type">anyopaque</span>, addr_buf.ptr), <span class="tok-null">null</span>);</span>
<span class="line" id="L216">        <span class="tok-kw">const</span> first_index = <span class="tok-kw">for</span> (addr_buf[<span class="tok-number">0</span>..n]) |addr, i| {</span>
<span class="line" id="L217">            <span class="tok-kw">if</span> (addr == first_addr) {</span>
<span class="line" id="L218">                <span class="tok-kw">break</span> i;</span>
<span class="line" id="L219">            }</span>
<span class="line" id="L220">        } <span class="tok-kw">else</span> {</span>
<span class="line" id="L221">            stack_trace.index = <span class="tok-number">0</span>;</span>
<span class="line" id="L222">            <span class="tok-kw">return</span>;</span>
<span class="line" id="L223">        };</span>
<span class="line" id="L224">        <span class="tok-kw">const</span> end_index = math.min(first_index + addrs.len, n);</span>
<span class="line" id="L225">        <span class="tok-kw">const</span> slice = addr_buf[first_index..end_index];</span>
<span class="line" id="L226">        <span class="tok-comment">// We use a for loop here because slice and addrs may alias.</span>
</span>
<span class="line" id="L227">        <span class="tok-kw">for</span> (slice) |addr, i| {</span>
<span class="line" id="L228">            addrs[i] = addr;</span>
<span class="line" id="L229">        }</span>
<span class="line" id="L230">        stack_trace.index = slice.len;</span>
<span class="line" id="L231">    } <span class="tok-kw">else</span> {</span>
<span class="line" id="L232">        <span class="tok-kw">var</span> it = StackIterator.init(first_address, <span class="tok-null">null</span>);</span>
<span class="line" id="L233">        <span class="tok-kw">for</span> (stack_trace.instruction_addresses) |*addr, i| {</span>
<span class="line" id="L234">            addr.* = it.next() <span class="tok-kw">orelse</span> {</span>
<span class="line" id="L235">                stack_trace.index = i;</span>
<span class="line" id="L236">                <span class="tok-kw">return</span>;</span>
<span class="line" id="L237">            };</span>
<span class="line" id="L238">        }</span>
<span class="line" id="L239">        stack_trace.index = stack_trace.instruction_addresses.len;</span>
<span class="line" id="L240">    }</span>
<span class="line" id="L241">}</span>
<span class="line" id="L242"></span>
<span class="line" id="L243"><span class="tok-comment">/// Tries to print a stack trace to stderr, unbuffered, and ignores any error returned.</span></span>
<span class="line" id="L244"><span class="tok-comment">/// TODO multithreaded awareness</span></span>
<span class="line" id="L245"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">dumpStackTrace</span>(stack_trace: std.builtin.StackTrace) <span class="tok-type">void</span> {</span>
<span class="line" id="L246">    <span class="tok-kw">nosuspend</span> {</span>
<span class="line" id="L247">        <span class="tok-kw">if</span> (<span class="tok-kw">comptime</span> builtin.target.isWasm()) {</span>
<span class="line" id="L248">            <span class="tok-kw">if</span> (native_os == .wasi) {</span>
<span class="line" id="L249">                <span class="tok-kw">const</span> stderr = io.getStdErr().writer();</span>
<span class="line" id="L250">                stderr.print(<span class="tok-str">&quot;Unable to dump stack trace: not implemented for Wasm\n&quot;</span>, .{}) <span class="tok-kw">catch</span> <span class="tok-kw">return</span>;</span>
<span class="line" id="L251">            }</span>
<span class="line" id="L252">            <span class="tok-kw">return</span>;</span>
<span class="line" id="L253">        }</span>
<span class="line" id="L254">        <span class="tok-kw">const</span> stderr = io.getStdErr().writer();</span>
<span class="line" id="L255">        <span class="tok-kw">if</span> (builtin.strip_debug_info) {</span>
<span class="line" id="L256">            stderr.print(<span class="tok-str">&quot;Unable to dump stack trace: debug info stripped\n&quot;</span>, .{}) <span class="tok-kw">catch</span> <span class="tok-kw">return</span>;</span>
<span class="line" id="L257">            <span class="tok-kw">return</span>;</span>
<span class="line" id="L258">        }</span>
<span class="line" id="L259">        <span class="tok-kw">const</span> debug_info = getSelfDebugInfo() <span class="tok-kw">catch</span> |err| {</span>
<span class="line" id="L260">            stderr.print(<span class="tok-str">&quot;Unable to dump stack trace: Unable to open debug info: {s}\n&quot;</span>, .{<span class="tok-builtin">@errorName</span>(err)}) <span class="tok-kw">catch</span> <span class="tok-kw">return</span>;</span>
<span class="line" id="L261">            <span class="tok-kw">return</span>;</span>
<span class="line" id="L262">        };</span>
<span class="line" id="L263">        writeStackTrace(stack_trace, stderr, getDebugInfoAllocator(), debug_info, detectTTYConfig()) <span class="tok-kw">catch</span> |err| {</span>
<span class="line" id="L264">            stderr.print(<span class="tok-str">&quot;Unable to dump stack trace: {s}\n&quot;</span>, .{<span class="tok-builtin">@errorName</span>(err)}) <span class="tok-kw">catch</span> <span class="tok-kw">return</span>;</span>
<span class="line" id="L265">            <span class="tok-kw">return</span>;</span>
<span class="line" id="L266">        };</span>
<span class="line" id="L267">    }</span>
<span class="line" id="L268">}</span>
<span class="line" id="L269"></span>
<span class="line" id="L270"><span class="tok-comment">/// This function invokes undefined behavior when `ok` is `false`.</span></span>
<span class="line" id="L271"><span class="tok-comment">/// In Debug and ReleaseSafe modes, calls to this function are always</span></span>
<span class="line" id="L272"><span class="tok-comment">/// generated, and the `unreachable` statement triggers a panic.</span></span>
<span class="line" id="L273"><span class="tok-comment">/// In ReleaseFast and ReleaseSmall modes, calls to this function are</span></span>
<span class="line" id="L274"><span class="tok-comment">/// optimized away, and in fact the optimizer is able to use the assertion</span></span>
<span class="line" id="L275"><span class="tok-comment">/// in its heuristics.</span></span>
<span class="line" id="L276"><span class="tok-comment">/// Inside a test block, it is best to use the `std.testing` module rather</span></span>
<span class="line" id="L277"><span class="tok-comment">/// than this function, because this function may not detect a test failure</span></span>
<span class="line" id="L278"><span class="tok-comment">/// in ReleaseFast and ReleaseSmall mode. Outside of a test block, this assert</span></span>
<span class="line" id="L279"><span class="tok-comment">/// function is the correct function to use.</span></span>
<span class="line" id="L280"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">assert</span>(ok: <span class="tok-type">bool</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L281">    <span class="tok-kw">if</span> (!ok) <span class="tok-kw">unreachable</span>; <span class="tok-comment">// assertion failure</span>
</span>
<span class="line" id="L282">}</span>
<span class="line" id="L283"></span>
<span class="line" id="L284"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">panic</span>(<span class="tok-kw">comptime</span> format: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, args: <span class="tok-kw">anytype</span>) <span class="tok-type">noreturn</span> {</span>
<span class="line" id="L285">    <span class="tok-builtin">@setCold</span>(<span class="tok-null">true</span>);</span>
<span class="line" id="L286"></span>
<span class="line" id="L287">    panicExtra(<span class="tok-null">null</span>, format, args);</span>
<span class="line" id="L288">}</span>
<span class="line" id="L289"></span>
<span class="line" id="L290"><span class="tok-comment">/// `panicExtra` is useful when you want to print out an `@errorReturnTrace`</span></span>
<span class="line" id="L291"><span class="tok-comment">/// and also print out some values.</span></span>
<span class="line" id="L292"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">panicExtra</span>(</span>
<span class="line" id="L293">    trace: ?*std.builtin.StackTrace,</span>
<span class="line" id="L294">    <span class="tok-kw">comptime</span> format: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L295">    args: <span class="tok-kw">anytype</span>,</span>
<span class="line" id="L296">) <span class="tok-type">noreturn</span> {</span>
<span class="line" id="L297">    <span class="tok-builtin">@setCold</span>(<span class="tok-null">true</span>);</span>
<span class="line" id="L298"></span>
<span class="line" id="L299">    <span class="tok-kw">const</span> size = <span class="tok-number">0x1000</span>;</span>
<span class="line" id="L300">    <span class="tok-kw">const</span> trunc_msg = <span class="tok-str">&quot;(msg truncated)&quot;</span>;</span>
<span class="line" id="L301">    <span class="tok-kw">var</span> buf: [size + trunc_msg.len]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L302">    <span class="tok-comment">// a minor annoyance with this is that it will result in the NoSpaceLeft</span>
</span>
<span class="line" id="L303">    <span class="tok-comment">// error being part of the @panic stack trace (but that error should</span>
</span>
<span class="line" id="L304">    <span class="tok-comment">// only happen rarely)</span>
</span>
<span class="line" id="L305">    <span class="tok-kw">const</span> msg = std.fmt.bufPrint(buf[<span class="tok-number">0</span>..size], format, args) <span class="tok-kw">catch</span> |err| <span class="tok-kw">switch</span> (err) {</span>
<span class="line" id="L306">        std.fmt.BufPrintError.NoSpaceLeft =&gt; blk: {</span>
<span class="line" id="L307">            std.mem.copy(<span class="tok-type">u8</span>, buf[size..], trunc_msg);</span>
<span class="line" id="L308">            <span class="tok-kw">break</span> :blk &amp;buf;</span>
<span class="line" id="L309">        },</span>
<span class="line" id="L310">    };</span>
<span class="line" id="L311">    std.builtin.panic(msg, trace);</span>
<span class="line" id="L312">}</span>
<span class="line" id="L313"></span>
<span class="line" id="L314"><span class="tok-comment">/// Non-zero whenever the program triggered a panic.</span></span>
<span class="line" id="L315"><span class="tok-comment">/// The counter is incremented/decremented atomically.</span></span>
<span class="line" id="L316"><span class="tok-kw">var</span> panicking = std.atomic.Atomic(<span class="tok-type">u8</span>).init(<span class="tok-number">0</span>);</span>
<span class="line" id="L317"></span>
<span class="line" id="L318"><span class="tok-comment">// Locked to avoid interleaving panic messages from multiple threads.</span>
</span>
<span class="line" id="L319"><span class="tok-kw">var</span> panic_mutex = std.Thread.Mutex{};</span>
<span class="line" id="L320"></span>
<span class="line" id="L321"><span class="tok-comment">/// Counts how many times the panic handler is invoked by this thread.</span></span>
<span class="line" id="L322"><span class="tok-comment">/// This is used to catch and handle panics triggered by the panic handler.</span></span>
<span class="line" id="L323"><span class="tok-kw">threadlocal</span> <span class="tok-kw">var</span> panic_stage: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L324"></span>
<span class="line" id="L325"><span class="tok-comment">// `panicImpl` could be useful in implementing a custom panic handler which</span>
</span>
<span class="line" id="L326"><span class="tok-comment">// calls the default handler (on supported platforms)</span>
</span>
<span class="line" id="L327"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">panicImpl</span>(trace: ?*<span class="tok-kw">const</span> std.builtin.StackTrace, first_trace_addr: ?<span class="tok-type">usize</span>, msg: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) <span class="tok-type">noreturn</span> {</span>
<span class="line" id="L328">    <span class="tok-builtin">@setCold</span>(<span class="tok-null">true</span>);</span>
<span class="line" id="L329"></span>
<span class="line" id="L330">    <span class="tok-kw">if</span> (enable_segfault_handler) {</span>
<span class="line" id="L331">        <span class="tok-comment">// If a segfault happens while panicking, we want it to actually segfault, not trigger</span>
</span>
<span class="line" id="L332">        <span class="tok-comment">// the handler.</span>
</span>
<span class="line" id="L333">        resetSegfaultHandler();</span>
<span class="line" id="L334">    }</span>
<span class="line" id="L335"></span>
<span class="line" id="L336">    <span class="tok-kw">nosuspend</span> <span class="tok-kw">switch</span> (panic_stage) {</span>
<span class="line" id="L337">        <span class="tok-number">0</span> =&gt; {</span>
<span class="line" id="L338">            panic_stage = <span class="tok-number">1</span>;</span>
<span class="line" id="L339"></span>
<span class="line" id="L340">            _ = panicking.fetchAdd(<span class="tok-number">1</span>, .SeqCst);</span>
<span class="line" id="L341"></span>
<span class="line" id="L342">            <span class="tok-comment">// Make sure to release the mutex when done</span>
</span>
<span class="line" id="L343">            {</span>
<span class="line" id="L344">                panic_mutex.lock();</span>
<span class="line" id="L345">                <span class="tok-kw">defer</span> panic_mutex.unlock();</span>
<span class="line" id="L346"></span>
<span class="line" id="L347">                <span class="tok-kw">const</span> stderr = io.getStdErr().writer();</span>
<span class="line" id="L348">                <span class="tok-kw">if</span> (builtin.single_threaded) {</span>
<span class="line" id="L349">                    stderr.print(<span class="tok-str">&quot;panic: &quot;</span>, .{}) <span class="tok-kw">catch</span> os.abort();</span>
<span class="line" id="L350">                } <span class="tok-kw">else</span> {</span>
<span class="line" id="L351">                    <span class="tok-kw">const</span> current_thread_id = std.Thread.getCurrentId();</span>
<span class="line" id="L352">                    stderr.print(<span class="tok-str">&quot;thread {} panic: &quot;</span>, .{current_thread_id}) <span class="tok-kw">catch</span> os.abort();</span>
<span class="line" id="L353">                }</span>
<span class="line" id="L354">                stderr.print(<span class="tok-str">&quot;{s}\n&quot;</span>, .{msg}) <span class="tok-kw">catch</span> os.abort();</span>
<span class="line" id="L355">                <span class="tok-kw">if</span> (trace) |t| {</span>
<span class="line" id="L356">                    dumpStackTrace(t.*);</span>
<span class="line" id="L357">                }</span>
<span class="line" id="L358">                dumpCurrentStackTrace(first_trace_addr);</span>
<span class="line" id="L359">            }</span>
<span class="line" id="L360"></span>
<span class="line" id="L361">            <span class="tok-kw">if</span> (panicking.fetchSub(<span class="tok-number">1</span>, .SeqCst) != <span class="tok-number">1</span>) {</span>
<span class="line" id="L362">                <span class="tok-comment">// Another thread is panicking, wait for the last one to finish</span>
</span>
<span class="line" id="L363">                <span class="tok-comment">// and call abort()</span>
</span>
<span class="line" id="L364">                <span class="tok-kw">if</span> (builtin.single_threaded) <span class="tok-kw">unreachable</span>;</span>
<span class="line" id="L365"></span>
<span class="line" id="L366">                <span class="tok-comment">// Sleep forever without hammering the CPU</span>
</span>
<span class="line" id="L367">                <span class="tok-kw">var</span> futex = std.atomic.Atomic(<span class="tok-type">u32</span>).init(<span class="tok-number">0</span>);</span>
<span class="line" id="L368">                <span class="tok-kw">while</span> (<span class="tok-null">true</span>) std.Thread.Futex.wait(&amp;futex, <span class="tok-number">0</span>);</span>
<span class="line" id="L369">                <span class="tok-kw">unreachable</span>;</span>
<span class="line" id="L370">            }</span>
<span class="line" id="L371">        },</span>
<span class="line" id="L372">        <span class="tok-number">1</span> =&gt; {</span>
<span class="line" id="L373">            panic_stage = <span class="tok-number">2</span>;</span>
<span class="line" id="L374"></span>
<span class="line" id="L375">            <span class="tok-comment">// A panic happened while trying to print a previous panic message,</span>
</span>
<span class="line" id="L376">            <span class="tok-comment">// we're still holding the mutex but that's fine as we're going to</span>
</span>
<span class="line" id="L377">            <span class="tok-comment">// call abort()</span>
</span>
<span class="line" id="L378">            <span class="tok-kw">const</span> stderr = io.getStdErr().writer();</span>
<span class="line" id="L379">            stderr.print(<span class="tok-str">&quot;Panicked during a panic. Aborting.\n&quot;</span>, .{}) <span class="tok-kw">catch</span> os.abort();</span>
<span class="line" id="L380">        },</span>
<span class="line" id="L381">        <span class="tok-kw">else</span> =&gt; {</span>
<span class="line" id="L382">            <span class="tok-comment">// Panicked while printing &quot;Panicked during a panic.&quot;</span>
</span>
<span class="line" id="L383">        },</span>
<span class="line" id="L384">    };</span>
<span class="line" id="L385"></span>
<span class="line" id="L386">    os.abort();</span>
<span class="line" id="L387">}</span>
<span class="line" id="L388"></span>
<span class="line" id="L389"><span class="tok-kw">const</span> RED = <span class="tok-str">&quot;\x1b[31;1m&quot;</span>;</span>
<span class="line" id="L390"><span class="tok-kw">const</span> GREEN = <span class="tok-str">&quot;\x1b[32;1m&quot;</span>;</span>
<span class="line" id="L391"><span class="tok-kw">const</span> CYAN = <span class="tok-str">&quot;\x1b[36;1m&quot;</span>;</span>
<span class="line" id="L392"><span class="tok-kw">const</span> WHITE = <span class="tok-str">&quot;\x1b[37;1m&quot;</span>;</span>
<span class="line" id="L393"><span class="tok-kw">const</span> BOLD = <span class="tok-str">&quot;\x1b[1m&quot;</span>;</span>
<span class="line" id="L394"><span class="tok-kw">const</span> DIM = <span class="tok-str">&quot;\x1b[2m&quot;</span>;</span>
<span class="line" id="L395"><span class="tok-kw">const</span> RESET = <span class="tok-str">&quot;\x1b[0m&quot;</span>;</span>
<span class="line" id="L396"></span>
<span class="line" id="L397"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">writeStackTrace</span>(</span>
<span class="line" id="L398">    stack_trace: std.builtin.StackTrace,</span>
<span class="line" id="L399">    out_stream: <span class="tok-kw">anytype</span>,</span>
<span class="line" id="L400">    allocator: mem.Allocator,</span>
<span class="line" id="L401">    debug_info: *DebugInfo,</span>
<span class="line" id="L402">    tty_config: TTY.Config,</span>
<span class="line" id="L403">) !<span class="tok-type">void</span> {</span>
<span class="line" id="L404">    _ = allocator;</span>
<span class="line" id="L405">    <span class="tok-kw">if</span> (builtin.strip_debug_info) <span class="tok-kw">return</span> <span class="tok-kw">error</span>.MissingDebugInfo;</span>
<span class="line" id="L406">    <span class="tok-kw">var</span> frame_index: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L407">    <span class="tok-kw">var</span> frames_left: <span class="tok-type">usize</span> = std.math.min(stack_trace.index, stack_trace.instruction_addresses.len);</span>
<span class="line" id="L408"></span>
<span class="line" id="L409">    <span class="tok-kw">while</span> (frames_left != <span class="tok-number">0</span>) : ({</span>
<span class="line" id="L410">        frames_left -= <span class="tok-number">1</span>;</span>
<span class="line" id="L411">        frame_index = (frame_index + <span class="tok-number">1</span>) % stack_trace.instruction_addresses.len;</span>
<span class="line" id="L412">    }) {</span>
<span class="line" id="L413">        <span class="tok-kw">const</span> return_address = stack_trace.instruction_addresses[frame_index];</span>
<span class="line" id="L414">        <span class="tok-kw">try</span> printSourceAtAddress(debug_info, out_stream, return_address - <span class="tok-number">1</span>, tty_config);</span>
<span class="line" id="L415">    }</span>
<span class="line" id="L416">}</span>
<span class="line" id="L417"></span>
<span class="line" id="L418"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> StackIterator = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L419">    <span class="tok-comment">// Skip every frame before this address is found.</span>
</span>
<span class="line" id="L420">    first_address: ?<span class="tok-type">usize</span>,</span>
<span class="line" id="L421">    <span class="tok-comment">// Last known value of the frame pointer register.</span>
</span>
<span class="line" id="L422">    fp: <span class="tok-type">usize</span>,</span>
<span class="line" id="L423"></span>
<span class="line" id="L424">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">init</span>(first_address: ?<span class="tok-type">usize</span>, fp: ?<span class="tok-type">usize</span>) StackIterator {</span>
<span class="line" id="L425">        <span class="tok-kw">if</span> (native_arch == .sparc64) {</span>
<span class="line" id="L426">            <span class="tok-comment">// Flush all the register windows on stack.</span>
</span>
<span class="line" id="L427">            <span class="tok-kw">asm</span> <span class="tok-kw">volatile</span> (</span>
<span class="line" id="L428">                <span class="tok-str">\\ flushw</span></span>

<span class="line" id="L429">                ::: <span class="tok-str">&quot;memory&quot;</span>);</span>
<span class="line" id="L430">        }</span>
<span class="line" id="L431"></span>
<span class="line" id="L432">        <span class="tok-kw">return</span> StackIterator{</span>
<span class="line" id="L433">            .first_address = first_address,</span>
<span class="line" id="L434">            .fp = fp <span class="tok-kw">orelse</span> <span class="tok-builtin">@frameAddress</span>(),</span>
<span class="line" id="L435">        };</span>
<span class="line" id="L436">    }</span>
<span class="line" id="L437"></span>
<span class="line" id="L438">    <span class="tok-comment">// Offset of the saved BP wrt the frame pointer.</span>
</span>
<span class="line" id="L439">    <span class="tok-kw">const</span> fp_offset = <span class="tok-kw">if</span> (native_arch.isRISCV())</span>
<span class="line" id="L440">        <span class="tok-comment">// On RISC-V the frame pointer points to the top of the saved register</span>
</span>
<span class="line" id="L441">        <span class="tok-comment">// area, on pretty much every other architecture it points to the stack</span>
</span>
<span class="line" id="L442">        <span class="tok-comment">// slot where the previous frame pointer is saved.</span>
</span>
<span class="line" id="L443">        <span class="tok-number">2</span> * <span class="tok-builtin">@sizeOf</span>(<span class="tok-type">usize</span>)</span>
<span class="line" id="L444">    <span class="tok-kw">else</span> <span class="tok-kw">if</span> (native_arch.isSPARC())</span>
<span class="line" id="L445">        <span class="tok-comment">// On SPARC the previous frame pointer is stored at 14 slots past %fp+BIAS.</span>
</span>
<span class="line" id="L446">        <span class="tok-number">14</span> * <span class="tok-builtin">@sizeOf</span>(<span class="tok-type">usize</span>)</span>
<span class="line" id="L447">    <span class="tok-kw">else</span></span>
<span class="line" id="L448">        <span class="tok-number">0</span>;</span>
<span class="line" id="L449"></span>
<span class="line" id="L450">    <span class="tok-kw">const</span> fp_bias = <span class="tok-kw">if</span> (native_arch.isSPARC())</span>
<span class="line" id="L451">        <span class="tok-comment">// On SPARC frame pointers are biased by a constant.</span>
</span>
<span class="line" id="L452">        <span class="tok-number">2047</span></span>
<span class="line" id="L453">    <span class="tok-kw">else</span></span>
<span class="line" id="L454">        <span class="tok-number">0</span>;</span>
<span class="line" id="L455"></span>
<span class="line" id="L456">    <span class="tok-comment">// Positive offset of the saved PC wrt the frame pointer.</span>
</span>
<span class="line" id="L457">    <span class="tok-kw">const</span> pc_offset = <span class="tok-kw">if</span> (native_arch == .powerpc64le)</span>
<span class="line" id="L458">        <span class="tok-number">2</span> * <span class="tok-builtin">@sizeOf</span>(<span class="tok-type">usize</span>)</span>
<span class="line" id="L459">    <span class="tok-kw">else</span></span>
<span class="line" id="L460">        <span class="tok-builtin">@sizeOf</span>(<span class="tok-type">usize</span>);</span>
<span class="line" id="L461"></span>
<span class="line" id="L462">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">next</span>(self: *StackIterator) ?<span class="tok-type">usize</span> {</span>
<span class="line" id="L463">        <span class="tok-kw">var</span> address = self.next_internal() <span class="tok-kw">orelse</span> <span class="tok-kw">return</span> <span class="tok-null">null</span>;</span>
<span class="line" id="L464"></span>
<span class="line" id="L465">        <span class="tok-kw">if</span> (self.first_address) |first_address| {</span>
<span class="line" id="L466">            <span class="tok-kw">while</span> (address != first_address) {</span>
<span class="line" id="L467">                address = self.next_internal() <span class="tok-kw">orelse</span> <span class="tok-kw">return</span> <span class="tok-null">null</span>;</span>
<span class="line" id="L468">            }</span>
<span class="line" id="L469">            self.first_address = <span class="tok-null">null</span>;</span>
<span class="line" id="L470">        }</span>
<span class="line" id="L471"></span>
<span class="line" id="L472">        <span class="tok-kw">return</span> address;</span>
<span class="line" id="L473">    }</span>
<span class="line" id="L474"></span>
<span class="line" id="L475">    <span class="tok-kw">fn</span> <span class="tok-fn">isValidMemory</span>(address: <span class="tok-type">usize</span>) <span class="tok-type">bool</span> {</span>
<span class="line" id="L476">        <span class="tok-comment">// We are unable to determine validity of memory for freestanding targets</span>
</span>
<span class="line" id="L477">        <span class="tok-kw">if</span> (native_os == .freestanding) <span class="tok-kw">return</span> <span class="tok-null">true</span>;</span>
<span class="line" id="L478"></span>
<span class="line" id="L479">        <span class="tok-kw">const</span> aligned_address = address &amp; ~<span class="tok-builtin">@intCast</span>(<span class="tok-type">usize</span>, (mem.page_size - <span class="tok-number">1</span>));</span>
<span class="line" id="L480">        <span class="tok-kw">const</span> aligned_memory = <span class="tok-builtin">@intToPtr</span>([*]<span class="tok-kw">align</span>(mem.page_size) <span class="tok-type">u8</span>, aligned_address)[<span class="tok-number">0</span>..mem.page_size];</span>
<span class="line" id="L481"></span>
<span class="line" id="L482">        <span class="tok-kw">if</span> (native_os != .windows) {</span>
<span class="line" id="L483">            <span class="tok-kw">if</span> (native_os != .wasi) {</span>
<span class="line" id="L484">                os.msync(aligned_memory, os.MSF.ASYNC) <span class="tok-kw">catch</span> |err| {</span>
<span class="line" id="L485">                    <span class="tok-kw">switch</span> (err) {</span>
<span class="line" id="L486">                        os.MSyncError.UnmappedMemory =&gt; {</span>
<span class="line" id="L487">                            <span class="tok-kw">return</span> <span class="tok-null">false</span>;</span>
<span class="line" id="L488">                        },</span>
<span class="line" id="L489">                        <span class="tok-kw">else</span> =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L490">                    }</span>
<span class="line" id="L491">                };</span>
<span class="line" id="L492">            }</span>
<span class="line" id="L493"></span>
<span class="line" id="L494">            <span class="tok-kw">return</span> <span class="tok-null">true</span>;</span>
<span class="line" id="L495">        } <span class="tok-kw">else</span> {</span>
<span class="line" id="L496">            <span class="tok-kw">const</span> w = os.windows;</span>
<span class="line" id="L497">            <span class="tok-kw">var</span> memory_info: w.MEMORY_BASIC_INFORMATION = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L498"></span>
<span class="line" id="L499">            <span class="tok-comment">// The only error this function can throw is ERROR_INVALID_PARAMETER.</span>
</span>
<span class="line" id="L500">            <span class="tok-comment">// supply an address that invalid i'll be thrown.</span>
</span>
<span class="line" id="L501">            <span class="tok-kw">const</span> rc = w.VirtualQuery(aligned_memory, &amp;memory_info, aligned_memory.len) <span class="tok-kw">catch</span> {</span>
<span class="line" id="L502">                <span class="tok-kw">return</span> <span class="tok-null">false</span>;</span>
<span class="line" id="L503">            };</span>
<span class="line" id="L504"></span>
<span class="line" id="L505">            <span class="tok-comment">// Result code has to be bigger than zero (number of bytes written)</span>
</span>
<span class="line" id="L506">            <span class="tok-kw">if</span> (rc == <span class="tok-number">0</span>) {</span>
<span class="line" id="L507">                <span class="tok-kw">return</span> <span class="tok-null">false</span>;</span>
<span class="line" id="L508">            }</span>
<span class="line" id="L509"></span>
<span class="line" id="L510">            <span class="tok-comment">// Free pages cannot be read, they are unmapped</span>
</span>
<span class="line" id="L511">            <span class="tok-kw">if</span> (memory_info.State == w.MEM_FREE) {</span>
<span class="line" id="L512">                <span class="tok-kw">return</span> <span class="tok-null">false</span>;</span>
<span class="line" id="L513">            }</span>
<span class="line" id="L514"></span>
<span class="line" id="L515">            <span class="tok-kw">return</span> <span class="tok-null">true</span>;</span>
<span class="line" id="L516">        }</span>
<span class="line" id="L517">    }</span>
<span class="line" id="L518"></span>
<span class="line" id="L519">    <span class="tok-kw">fn</span> <span class="tok-fn">next_internal</span>(self: *StackIterator) ?<span class="tok-type">usize</span> {</span>
<span class="line" id="L520">        <span class="tok-kw">const</span> fp = <span class="tok-kw">if</span> (<span class="tok-kw">comptime</span> native_arch.isSPARC())</span>
<span class="line" id="L521">            <span class="tok-comment">// On SPARC the offset is positive. (!)</span>
</span>
<span class="line" id="L522">            math.add(<span class="tok-type">usize</span>, self.fp, fp_offset) <span class="tok-kw">catch</span> <span class="tok-kw">return</span> <span class="tok-null">null</span></span>
<span class="line" id="L523">        <span class="tok-kw">else</span></span>
<span class="line" id="L524">            math.sub(<span class="tok-type">usize</span>, self.fp, fp_offset) <span class="tok-kw">catch</span> <span class="tok-kw">return</span> <span class="tok-null">null</span>;</span>
<span class="line" id="L525"></span>
<span class="line" id="L526">        <span class="tok-comment">// Sanity check.</span>
</span>
<span class="line" id="L527">        <span class="tok-kw">if</span> (fp == <span class="tok-number">0</span> <span class="tok-kw">or</span> !mem.isAligned(fp, <span class="tok-builtin">@alignOf</span>(<span class="tok-type">usize</span>)) <span class="tok-kw">or</span> !isValidMemory(fp))</span>
<span class="line" id="L528">            <span class="tok-kw">return</span> <span class="tok-null">null</span>;</span>
<span class="line" id="L529"></span>
<span class="line" id="L530">        <span class="tok-kw">const</span> new_fp = math.add(<span class="tok-type">usize</span>, <span class="tok-builtin">@intToPtr</span>(*<span class="tok-kw">const</span> <span class="tok-type">usize</span>, fp).*, fp_bias) <span class="tok-kw">catch</span> <span class="tok-kw">return</span> <span class="tok-null">null</span>;</span>
<span class="line" id="L531"></span>
<span class="line" id="L532">        <span class="tok-comment">// Sanity check: the stack grows down thus all the parent frames must be</span>
</span>
<span class="line" id="L533">        <span class="tok-comment">// be at addresses that are greater (or equal) than the previous one.</span>
</span>
<span class="line" id="L534">        <span class="tok-comment">// A zero frame pointer often signals this is the last frame, that case</span>
</span>
<span class="line" id="L535">        <span class="tok-comment">// is gracefully handled by the next call to next_internal.</span>
</span>
<span class="line" id="L536">        <span class="tok-kw">if</span> (new_fp != <span class="tok-number">0</span> <span class="tok-kw">and</span> new_fp &lt; self.fp)</span>
<span class="line" id="L537">            <span class="tok-kw">return</span> <span class="tok-null">null</span>;</span>
<span class="line" id="L538"></span>
<span class="line" id="L539">        <span class="tok-kw">const</span> new_pc = <span class="tok-builtin">@intToPtr</span>(</span>
<span class="line" id="L540">            *<span class="tok-kw">const</span> <span class="tok-type">usize</span>,</span>
<span class="line" id="L541">            math.add(<span class="tok-type">usize</span>, fp, pc_offset) <span class="tok-kw">catch</span> <span class="tok-kw">return</span> <span class="tok-null">null</span>,</span>
<span class="line" id="L542">        ).*;</span>
<span class="line" id="L543"></span>
<span class="line" id="L544">        self.fp = new_fp;</span>
<span class="line" id="L545"></span>
<span class="line" id="L546">        <span class="tok-kw">return</span> new_pc;</span>
<span class="line" id="L547">    }</span>
<span class="line" id="L548">};</span>
<span class="line" id="L549"></span>
<span class="line" id="L550"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">writeCurrentStackTrace</span>(</span>
<span class="line" id="L551">    out_stream: <span class="tok-kw">anytype</span>,</span>
<span class="line" id="L552">    debug_info: *DebugInfo,</span>
<span class="line" id="L553">    tty_config: TTY.Config,</span>
<span class="line" id="L554">    start_addr: ?<span class="tok-type">usize</span>,</span>
<span class="line" id="L555">) !<span class="tok-type">void</span> {</span>
<span class="line" id="L556">    <span class="tok-kw">if</span> (native_os == .windows) {</span>
<span class="line" id="L557">        <span class="tok-kw">return</span> writeCurrentStackTraceWindows(out_stream, debug_info, tty_config, start_addr);</span>
<span class="line" id="L558">    }</span>
<span class="line" id="L559">    <span class="tok-kw">var</span> it = StackIterator.init(start_addr, <span class="tok-null">null</span>);</span>
<span class="line" id="L560">    <span class="tok-kw">while</span> (it.next()) |return_address| {</span>
<span class="line" id="L561">        <span class="tok-comment">// On arm64 macOS, the address of the last frame is 0x0 rather than 0x1 as on x86_64 macOS,</span>
</span>
<span class="line" id="L562">        <span class="tok-comment">// therefore, we do a check for `return_address == 0` before subtracting 1 from it to avoid</span>
</span>
<span class="line" id="L563">        <span class="tok-comment">// an overflow. We do not need to signal `StackIterator` as it will correctly detect this</span>
</span>
<span class="line" id="L564">        <span class="tok-comment">// condition on the subsequent iteration and return `null` thus terminating the loop.</span>
</span>
<span class="line" id="L565">        <span class="tok-kw">const</span> address = <span class="tok-kw">if</span> (return_address == <span class="tok-number">0</span>) return_address <span class="tok-kw">else</span> return_address - <span class="tok-number">1</span>;</span>
<span class="line" id="L566">        <span class="tok-kw">try</span> printSourceAtAddress(debug_info, out_stream, address, tty_config);</span>
<span class="line" id="L567">    }</span>
<span class="line" id="L568">}</span>
<span class="line" id="L569"></span>
<span class="line" id="L570"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">writeCurrentStackTraceWindows</span>(</span>
<span class="line" id="L571">    out_stream: <span class="tok-kw">anytype</span>,</span>
<span class="line" id="L572">    debug_info: *DebugInfo,</span>
<span class="line" id="L573">    tty_config: TTY.Config,</span>
<span class="line" id="L574">    start_addr: ?<span class="tok-type">usize</span>,</span>
<span class="line" id="L575">) !<span class="tok-type">void</span> {</span>
<span class="line" id="L576">    <span class="tok-kw">var</span> addr_buf: [<span class="tok-number">1024</span>]<span class="tok-type">usize</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L577">    <span class="tok-kw">const</span> n = windows.ntdll.RtlCaptureStackBackTrace(<span class="tok-number">0</span>, addr_buf.len, <span class="tok-builtin">@ptrCast</span>(**<span class="tok-type">anyopaque</span>, &amp;addr_buf), <span class="tok-null">null</span>);</span>
<span class="line" id="L578">    <span class="tok-kw">const</span> addrs = addr_buf[<span class="tok-number">0</span>..n];</span>
<span class="line" id="L579">    <span class="tok-kw">var</span> start_i: <span class="tok-type">usize</span> = <span class="tok-kw">if</span> (start_addr) |saddr| blk: {</span>
<span class="line" id="L580">        <span class="tok-kw">for</span> (addrs) |addr, i| {</span>
<span class="line" id="L581">            <span class="tok-kw">if</span> (addr == saddr) <span class="tok-kw">break</span> :blk i;</span>
<span class="line" id="L582">        }</span>
<span class="line" id="L583">        <span class="tok-kw">return</span>;</span>
<span class="line" id="L584">    } <span class="tok-kw">else</span> <span class="tok-number">0</span>;</span>
<span class="line" id="L585">    <span class="tok-kw">for</span> (addrs[start_i..]) |addr| {</span>
<span class="line" id="L586">        <span class="tok-kw">try</span> printSourceAtAddress(debug_info, out_stream, addr - <span class="tok-number">1</span>, tty_config);</span>
<span class="line" id="L587">    }</span>
<span class="line" id="L588">}</span>
<span class="line" id="L589"></span>
<span class="line" id="L590"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> TTY = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L591">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> Color = <span class="tok-kw">enum</span> {</span>
<span class="line" id="L592">        Red,</span>
<span class="line" id="L593">        Green,</span>
<span class="line" id="L594">        Cyan,</span>
<span class="line" id="L595">        White,</span>
<span class="line" id="L596">        Dim,</span>
<span class="line" id="L597">        Bold,</span>
<span class="line" id="L598">        Reset,</span>
<span class="line" id="L599">    };</span>
<span class="line" id="L600"></span>
<span class="line" id="L601">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> Config = <span class="tok-kw">enum</span> {</span>
<span class="line" id="L602">        no_color,</span>
<span class="line" id="L603">        escape_codes,</span>
<span class="line" id="L604">        <span class="tok-comment">// TODO give this a payload of file handle</span>
</span>
<span class="line" id="L605">        windows_api,</span>
<span class="line" id="L606"></span>
<span class="line" id="L607">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">setColor</span>(conf: Config, out_stream: <span class="tok-kw">anytype</span>, color: Color) <span class="tok-type">void</span> {</span>
<span class="line" id="L608">            <span class="tok-kw">nosuspend</span> <span class="tok-kw">switch</span> (conf) {</span>
<span class="line" id="L609">                .no_color =&gt; <span class="tok-kw">return</span>,</span>
<span class="line" id="L610">                .escape_codes =&gt; <span class="tok-kw">switch</span> (color) {</span>
<span class="line" id="L611">                    .Red =&gt; out_stream.writeAll(RED) <span class="tok-kw">catch</span> <span class="tok-kw">return</span>,</span>
<span class="line" id="L612">                    .Green =&gt; out_stream.writeAll(GREEN) <span class="tok-kw">catch</span> <span class="tok-kw">return</span>,</span>
<span class="line" id="L613">                    .Cyan =&gt; out_stream.writeAll(CYAN) <span class="tok-kw">catch</span> <span class="tok-kw">return</span>,</span>
<span class="line" id="L614">                    .White =&gt; out_stream.writeAll(WHITE) <span class="tok-kw">catch</span> <span class="tok-kw">return</span>,</span>
<span class="line" id="L615">                    .Dim =&gt; out_stream.writeAll(DIM) <span class="tok-kw">catch</span> <span class="tok-kw">return</span>,</span>
<span class="line" id="L616">                    .Bold =&gt; out_stream.writeAll(BOLD) <span class="tok-kw">catch</span> <span class="tok-kw">return</span>,</span>
<span class="line" id="L617">                    .Reset =&gt; out_stream.writeAll(RESET) <span class="tok-kw">catch</span> <span class="tok-kw">return</span>,</span>
<span class="line" id="L618">                },</span>
<span class="line" id="L619">                .windows_api =&gt; <span class="tok-kw">if</span> (native_os == .windows) {</span>
<span class="line" id="L620">                    <span class="tok-kw">const</span> stderr_file = io.getStdErr();</span>
<span class="line" id="L621">                    <span class="tok-kw">const</span> S = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L622">                        <span class="tok-kw">var</span> attrs: windows.WORD = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L623">                        <span class="tok-kw">var</span> init_attrs = <span class="tok-null">false</span>;</span>
<span class="line" id="L624">                    };</span>
<span class="line" id="L625">                    <span class="tok-kw">if</span> (!S.init_attrs) {</span>
<span class="line" id="L626">                        S.init_attrs = <span class="tok-null">true</span>;</span>
<span class="line" id="L627">                        <span class="tok-kw">var</span> info: windows.CONSOLE_SCREEN_BUFFER_INFO = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L628">                        <span class="tok-comment">// TODO handle error</span>
</span>
<span class="line" id="L629">                        _ = windows.kernel32.GetConsoleScreenBufferInfo(stderr_file.handle, &amp;info);</span>
<span class="line" id="L630">                        S.attrs = info.wAttributes;</span>
<span class="line" id="L631">                    }</span>
<span class="line" id="L632"></span>
<span class="line" id="L633">                    <span class="tok-comment">// TODO handle errors</span>
</span>
<span class="line" id="L634">                    <span class="tok-kw">switch</span> (color) {</span>
<span class="line" id="L635">                        .Red =&gt; {</span>
<span class="line" id="L636">                            _ = windows.SetConsoleTextAttribute(stderr_file.handle, windows.FOREGROUND_RED | windows.FOREGROUND_INTENSITY) <span class="tok-kw">catch</span> {};</span>
<span class="line" id="L637">                        },</span>
<span class="line" id="L638">                        .Green =&gt; {</span>
<span class="line" id="L639">                            _ = windows.SetConsoleTextAttribute(stderr_file.handle, windows.FOREGROUND_GREEN | windows.FOREGROUND_INTENSITY) <span class="tok-kw">catch</span> {};</span>
<span class="line" id="L640">                        },</span>
<span class="line" id="L641">                        .Cyan =&gt; {</span>
<span class="line" id="L642">                            _ = windows.SetConsoleTextAttribute(stderr_file.handle, windows.FOREGROUND_GREEN | windows.FOREGROUND_BLUE | windows.FOREGROUND_INTENSITY) <span class="tok-kw">catch</span> {};</span>
<span class="line" id="L643">                        },</span>
<span class="line" id="L644">                        .White, .Bold =&gt; {</span>
<span class="line" id="L645">                            _ = windows.SetConsoleTextAttribute(stderr_file.handle, windows.FOREGROUND_RED | windows.FOREGROUND_GREEN | windows.FOREGROUND_BLUE | windows.FOREGROUND_INTENSITY) <span class="tok-kw">catch</span> {};</span>
<span class="line" id="L646">                        },</span>
<span class="line" id="L647">                        .Dim =&gt; {</span>
<span class="line" id="L648">                            _ = windows.SetConsoleTextAttribute(stderr_file.handle, windows.FOREGROUND_INTENSITY) <span class="tok-kw">catch</span> {};</span>
<span class="line" id="L649">                        },</span>
<span class="line" id="L650">                        .Reset =&gt; {</span>
<span class="line" id="L651">                            _ = windows.SetConsoleTextAttribute(stderr_file.handle, S.attrs) <span class="tok-kw">catch</span> {};</span>
<span class="line" id="L652">                        },</span>
<span class="line" id="L653">                    }</span>
<span class="line" id="L654">                } <span class="tok-kw">else</span> {</span>
<span class="line" id="L655">                    <span class="tok-kw">unreachable</span>;</span>
<span class="line" id="L656">                },</span>
<span class="line" id="L657">            };</span>
<span class="line" id="L658">        }</span>
<span class="line" id="L659">    };</span>
<span class="line" id="L660">};</span>
<span class="line" id="L661"></span>
<span class="line" id="L662"><span class="tok-kw">fn</span> <span class="tok-fn">machoSearchSymbols</span>(symbols: []<span class="tok-kw">const</span> MachoSymbol, address: <span class="tok-type">usize</span>) ?*<span class="tok-kw">const</span> MachoSymbol {</span>
<span class="line" id="L663">    <span class="tok-kw">var</span> min: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L664">    <span class="tok-kw">var</span> max: <span class="tok-type">usize</span> = symbols.len - <span class="tok-number">1</span>;</span>
<span class="line" id="L665">    <span class="tok-kw">while</span> (min &lt; max) {</span>
<span class="line" id="L666">        <span class="tok-kw">const</span> mid = min + (max - min) / <span class="tok-number">2</span>;</span>
<span class="line" id="L667">        <span class="tok-kw">const</span> curr = &amp;symbols[mid];</span>
<span class="line" id="L668">        <span class="tok-kw">const</span> next = &amp;symbols[mid + <span class="tok-number">1</span>];</span>
<span class="line" id="L669">        <span class="tok-kw">if</span> (address &gt;= next.address()) {</span>
<span class="line" id="L670">            min = mid + <span class="tok-number">1</span>;</span>
<span class="line" id="L671">        } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (address &lt; curr.address()) {</span>
<span class="line" id="L672">            max = mid;</span>
<span class="line" id="L673">        } <span class="tok-kw">else</span> {</span>
<span class="line" id="L674">            <span class="tok-kw">return</span> curr;</span>
<span class="line" id="L675">        }</span>
<span class="line" id="L676">    }</span>
<span class="line" id="L677"></span>
<span class="line" id="L678">    <span class="tok-kw">const</span> max_sym = &amp;symbols[symbols.len - <span class="tok-number">1</span>];</span>
<span class="line" id="L679">    <span class="tok-kw">if</span> (address &gt;= max_sym.address())</span>
<span class="line" id="L680">        <span class="tok-kw">return</span> max_sym;</span>
<span class="line" id="L681"></span>
<span class="line" id="L682">    <span class="tok-kw">return</span> <span class="tok-null">null</span>;</span>
<span class="line" id="L683">}</span>
<span class="line" id="L684"></span>
<span class="line" id="L685"><span class="tok-kw">test</span> <span class="tok-str">&quot;machoSearchSymbols&quot;</span> {</span>
<span class="line" id="L686">    <span class="tok-kw">const</span> symbols = [_]MachoSymbol{</span>
<span class="line" id="L687">        .{ .addr = <span class="tok-number">100</span>, .strx = <span class="tok-null">undefined</span>, .size = <span class="tok-null">undefined</span>, .ofile = <span class="tok-null">undefined</span> },</span>
<span class="line" id="L688">        .{ .addr = <span class="tok-number">200</span>, .strx = <span class="tok-null">undefined</span>, .size = <span class="tok-null">undefined</span>, .ofile = <span class="tok-null">undefined</span> },</span>
<span class="line" id="L689">        .{ .addr = <span class="tok-number">300</span>, .strx = <span class="tok-null">undefined</span>, .size = <span class="tok-null">undefined</span>, .ofile = <span class="tok-null">undefined</span> },</span>
<span class="line" id="L690">    };</span>
<span class="line" id="L691"></span>
<span class="line" id="L692">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(?*<span class="tok-kw">const</span> MachoSymbol, <span class="tok-null">null</span>), machoSearchSymbols(&amp;symbols, <span class="tok-number">0</span>));</span>
<span class="line" id="L693">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(?*<span class="tok-kw">const</span> MachoSymbol, <span class="tok-null">null</span>), machoSearchSymbols(&amp;symbols, <span class="tok-number">99</span>));</span>
<span class="line" id="L694">    <span class="tok-kw">try</span> testing.expectEqual(&amp;symbols[<span class="tok-number">0</span>], machoSearchSymbols(&amp;symbols, <span class="tok-number">100</span>).?);</span>
<span class="line" id="L695">    <span class="tok-kw">try</span> testing.expectEqual(&amp;symbols[<span class="tok-number">0</span>], machoSearchSymbols(&amp;symbols, <span class="tok-number">150</span>).?);</span>
<span class="line" id="L696">    <span class="tok-kw">try</span> testing.expectEqual(&amp;symbols[<span class="tok-number">0</span>], machoSearchSymbols(&amp;symbols, <span class="tok-number">199</span>).?);</span>
<span class="line" id="L697"></span>
<span class="line" id="L698">    <span class="tok-kw">try</span> testing.expectEqual(&amp;symbols[<span class="tok-number">1</span>], machoSearchSymbols(&amp;symbols, <span class="tok-number">200</span>).?);</span>
<span class="line" id="L699">    <span class="tok-kw">try</span> testing.expectEqual(&amp;symbols[<span class="tok-number">1</span>], machoSearchSymbols(&amp;symbols, <span class="tok-number">250</span>).?);</span>
<span class="line" id="L700">    <span class="tok-kw">try</span> testing.expectEqual(&amp;symbols[<span class="tok-number">1</span>], machoSearchSymbols(&amp;symbols, <span class="tok-number">299</span>).?);</span>
<span class="line" id="L701"></span>
<span class="line" id="L702">    <span class="tok-kw">try</span> testing.expectEqual(&amp;symbols[<span class="tok-number">2</span>], machoSearchSymbols(&amp;symbols, <span class="tok-number">300</span>).?);</span>
<span class="line" id="L703">    <span class="tok-kw">try</span> testing.expectEqual(&amp;symbols[<span class="tok-number">2</span>], machoSearchSymbols(&amp;symbols, <span class="tok-number">301</span>).?);</span>
<span class="line" id="L704">    <span class="tok-kw">try</span> testing.expectEqual(&amp;symbols[<span class="tok-number">2</span>], machoSearchSymbols(&amp;symbols, <span class="tok-number">5000</span>).?);</span>
<span class="line" id="L705">}</span>
<span class="line" id="L706"></span>
<span class="line" id="L707"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">printSourceAtAddress</span>(debug_info: *DebugInfo, out_stream: <span class="tok-kw">anytype</span>, address: <span class="tok-type">usize</span>, tty_config: TTY.Config) !<span class="tok-type">void</span> {</span>
<span class="line" id="L708">    <span class="tok-kw">const</span> module = debug_info.getModuleForAddress(address) <span class="tok-kw">catch</span> |err| <span class="tok-kw">switch</span> (err) {</span>
<span class="line" id="L709">        <span class="tok-kw">error</span>.MissingDebugInfo, <span class="tok-kw">error</span>.InvalidDebugInfo =&gt; {</span>
<span class="line" id="L710">            <span class="tok-kw">return</span> printLineInfo(</span>
<span class="line" id="L711">                out_stream,</span>
<span class="line" id="L712">                <span class="tok-null">null</span>,</span>
<span class="line" id="L713">                address,</span>
<span class="line" id="L714">                <span class="tok-str">&quot;???&quot;</span>,</span>
<span class="line" id="L715">                <span class="tok-str">&quot;???&quot;</span>,</span>
<span class="line" id="L716">                tty_config,</span>
<span class="line" id="L717">                printLineFromFileAnyOs,</span>
<span class="line" id="L718">            );</span>
<span class="line" id="L719">        },</span>
<span class="line" id="L720">        <span class="tok-kw">else</span> =&gt; <span class="tok-kw">return</span> err,</span>
<span class="line" id="L721">    };</span>
<span class="line" id="L722"></span>
<span class="line" id="L723">    <span class="tok-kw">const</span> symbol_info = <span class="tok-kw">try</span> module.getSymbolAtAddress(debug_info.allocator, address);</span>
<span class="line" id="L724">    <span class="tok-kw">defer</span> symbol_info.deinit(debug_info.allocator);</span>
<span class="line" id="L725"></span>
<span class="line" id="L726">    <span class="tok-kw">return</span> printLineInfo(</span>
<span class="line" id="L727">        out_stream,</span>
<span class="line" id="L728">        symbol_info.line_info,</span>
<span class="line" id="L729">        address,</span>
<span class="line" id="L730">        symbol_info.symbol_name,</span>
<span class="line" id="L731">        symbol_info.compile_unit_name,</span>
<span class="line" id="L732">        tty_config,</span>
<span class="line" id="L733">        printLineFromFileAnyOs,</span>
<span class="line" id="L734">    );</span>
<span class="line" id="L735">}</span>
<span class="line" id="L736"></span>
<span class="line" id="L737"><span class="tok-kw">fn</span> <span class="tok-fn">printLineInfo</span>(</span>
<span class="line" id="L738">    out_stream: <span class="tok-kw">anytype</span>,</span>
<span class="line" id="L739">    line_info: ?LineInfo,</span>
<span class="line" id="L740">    address: <span class="tok-type">usize</span>,</span>
<span class="line" id="L741">    symbol_name: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L742">    compile_unit_name: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L743">    tty_config: TTY.Config,</span>
<span class="line" id="L744">    <span class="tok-kw">comptime</span> printLineFromFile: <span class="tok-kw">anytype</span>,</span>
<span class="line" id="L745">) !<span class="tok-type">void</span> {</span>
<span class="line" id="L746">    <span class="tok-kw">nosuspend</span> {</span>
<span class="line" id="L747">        tty_config.setColor(out_stream, .Bold);</span>
<span class="line" id="L748"></span>
<span class="line" id="L749">        <span class="tok-kw">if</span> (line_info) |*li| {</span>
<span class="line" id="L750">            <span class="tok-kw">try</span> out_stream.print(<span class="tok-str">&quot;{s}:{d}:{d}&quot;</span>, .{ li.file_name, li.line, li.column });</span>
<span class="line" id="L751">        } <span class="tok-kw">else</span> {</span>
<span class="line" id="L752">            <span class="tok-kw">try</span> out_stream.writeAll(<span class="tok-str">&quot;???:?:?&quot;</span>);</span>
<span class="line" id="L753">        }</span>
<span class="line" id="L754"></span>
<span class="line" id="L755">        tty_config.setColor(out_stream, .Reset);</span>
<span class="line" id="L756">        <span class="tok-kw">try</span> out_stream.writeAll(<span class="tok-str">&quot;: &quot;</span>);</span>
<span class="line" id="L757">        tty_config.setColor(out_stream, .Dim);</span>
<span class="line" id="L758">        <span class="tok-kw">try</span> out_stream.print(<span class="tok-str">&quot;0x{x} in {s} ({s})&quot;</span>, .{ address, symbol_name, compile_unit_name });</span>
<span class="line" id="L759">        tty_config.setColor(out_stream, .Reset);</span>
<span class="line" id="L760">        <span class="tok-kw">try</span> out_stream.writeAll(<span class="tok-str">&quot;\n&quot;</span>);</span>
<span class="line" id="L761"></span>
<span class="line" id="L762">        <span class="tok-comment">// Show the matching source code line if possible</span>
</span>
<span class="line" id="L763">        <span class="tok-kw">if</span> (line_info) |li| {</span>
<span class="line" id="L764">            <span class="tok-kw">if</span> (printLineFromFile(out_stream, li)) {</span>
<span class="line" id="L765">                <span class="tok-kw">if</span> (li.column &gt; <span class="tok-number">0</span>) {</span>
<span class="line" id="L766">                    <span class="tok-comment">// The caret already takes one char</span>
</span>
<span class="line" id="L767">                    <span class="tok-kw">const</span> space_needed = <span class="tok-builtin">@intCast</span>(<span class="tok-type">usize</span>, li.column - <span class="tok-number">1</span>);</span>
<span class="line" id="L768"></span>
<span class="line" id="L769">                    <span class="tok-kw">try</span> out_stream.writeByteNTimes(<span class="tok-str">' '</span>, space_needed);</span>
<span class="line" id="L770">                    tty_config.setColor(out_stream, .Green);</span>
<span class="line" id="L771">                    <span class="tok-kw">try</span> out_stream.writeAll(<span class="tok-str">&quot;^&quot;</span>);</span>
<span class="line" id="L772">                    tty_config.setColor(out_stream, .Reset);</span>
<span class="line" id="L773">                }</span>
<span class="line" id="L774">                <span class="tok-kw">try</span> out_stream.writeAll(<span class="tok-str">&quot;\n&quot;</span>);</span>
<span class="line" id="L775">            } <span class="tok-kw">else</span> |err| <span class="tok-kw">switch</span> (err) {</span>
<span class="line" id="L776">                <span class="tok-kw">error</span>.EndOfFile, <span class="tok-kw">error</span>.FileNotFound =&gt; {},</span>
<span class="line" id="L777">                <span class="tok-kw">error</span>.BadPathName =&gt; {},</span>
<span class="line" id="L778">                <span class="tok-kw">error</span>.AccessDenied =&gt; {},</span>
<span class="line" id="L779">                <span class="tok-kw">else</span> =&gt; <span class="tok-kw">return</span> err,</span>
<span class="line" id="L780">            }</span>
<span class="line" id="L781">        }</span>
<span class="line" id="L782">    }</span>
<span class="line" id="L783">}</span>
<span class="line" id="L784"></span>
<span class="line" id="L785"><span class="tok-comment">// TODO use this</span>
</span>
<span class="line" id="L786"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> OpenSelfDebugInfoError = <span class="tok-kw">error</span>{</span>
<span class="line" id="L787">    MissingDebugInfo,</span>
<span class="line" id="L788">    OutOfMemory,</span>
<span class="line" id="L789">    UnsupportedOperatingSystem,</span>
<span class="line" id="L790">};</span>
<span class="line" id="L791"></span>
<span class="line" id="L792"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">openSelfDebugInfo</span>(allocator: mem.Allocator) <span class="tok-type">anyerror</span>!DebugInfo {</span>
<span class="line" id="L793">    <span class="tok-kw">nosuspend</span> {</span>
<span class="line" id="L794">        <span class="tok-kw">if</span> (builtin.strip_debug_info)</span>
<span class="line" id="L795">            <span class="tok-kw">return</span> <span class="tok-kw">error</span>.MissingDebugInfo;</span>
<span class="line" id="L796">        <span class="tok-kw">if</span> (<span class="tok-builtin">@hasDecl</span>(root, <span class="tok-str">&quot;os&quot;</span>) <span class="tok-kw">and</span> <span class="tok-builtin">@hasDecl</span>(root.os, <span class="tok-str">&quot;debug&quot;</span>) <span class="tok-kw">and</span> <span class="tok-builtin">@hasDecl</span>(root.os.debug, <span class="tok-str">&quot;openSelfDebugInfo&quot;</span>)) {</span>
<span class="line" id="L797">            <span class="tok-kw">return</span> root.os.debug.openSelfDebugInfo(allocator);</span>
<span class="line" id="L798">        }</span>
<span class="line" id="L799">        <span class="tok-kw">switch</span> (native_os) {</span>
<span class="line" id="L800">            .linux,</span>
<span class="line" id="L801">            .freebsd,</span>
<span class="line" id="L802">            .netbsd,</span>
<span class="line" id="L803">            .dragonfly,</span>
<span class="line" id="L804">            .openbsd,</span>
<span class="line" id="L805">            .macos,</span>
<span class="line" id="L806">            .windows,</span>
<span class="line" id="L807">            .solaris,</span>
<span class="line" id="L808">            =&gt; <span class="tok-kw">return</span> DebugInfo.init(allocator),</span>
<span class="line" id="L809">            <span class="tok-kw">else</span> =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.UnsupportedDebugInfo,</span>
<span class="line" id="L810">        }</span>
<span class="line" id="L811">    }</span>
<span class="line" id="L812">}</span>
<span class="line" id="L813"></span>
<span class="line" id="L814"><span class="tok-comment">/// This takes ownership of coff_file: users of this function should not close</span></span>
<span class="line" id="L815"><span class="tok-comment">/// it themselves, even on error.</span></span>
<span class="line" id="L816"><span class="tok-comment">/// TODO it's weird to take ownership even on error, rework this code.</span></span>
<span class="line" id="L817"><span class="tok-kw">fn</span> <span class="tok-fn">readCoffDebugInfo</span>(allocator: mem.Allocator, coff_file: File) !ModuleDebugInfo {</span>
<span class="line" id="L818">    <span class="tok-kw">nosuspend</span> {</span>
<span class="line" id="L819">        <span class="tok-kw">errdefer</span> coff_file.close();</span>
<span class="line" id="L820"></span>
<span class="line" id="L821">        <span class="tok-kw">const</span> coff_obj = <span class="tok-kw">try</span> allocator.create(coff.Coff);</span>
<span class="line" id="L822">        <span class="tok-kw">errdefer</span> allocator.destroy(coff_obj);</span>
<span class="line" id="L823">        coff_obj.* = coff.Coff.init(allocator, coff_file);</span>
<span class="line" id="L824"></span>
<span class="line" id="L825">        <span class="tok-kw">var</span> di = ModuleDebugInfo{</span>
<span class="line" id="L826">            .base_address = <span class="tok-null">undefined</span>,</span>
<span class="line" id="L827">            .coff = coff_obj,</span>
<span class="line" id="L828">            .debug_data = <span class="tok-null">undefined</span>,</span>
<span class="line" id="L829">        };</span>
<span class="line" id="L830"></span>
<span class="line" id="L831">        <span class="tok-kw">try</span> di.coff.loadHeader();</span>
<span class="line" id="L832">        <span class="tok-kw">try</span> di.coff.loadSections();</span>
<span class="line" id="L833">        <span class="tok-kw">if</span> (di.coff.getSection(<span class="tok-str">&quot;.debug_info&quot;</span>)) |sec| {</span>
<span class="line" id="L834">            <span class="tok-comment">// This coff file has embedded DWARF debug info</span>
</span>
<span class="line" id="L835">            _ = sec;</span>
<span class="line" id="L836">            <span class="tok-comment">// TODO: free the section data slices</span>
</span>
<span class="line" id="L837">            <span class="tok-kw">const</span> debug_info_data = di.coff.getSectionData(<span class="tok-str">&quot;.debug_info&quot;</span>, allocator) <span class="tok-kw">catch</span> <span class="tok-null">null</span>;</span>
<span class="line" id="L838">            <span class="tok-kw">const</span> debug_abbrev_data = di.coff.getSectionData(<span class="tok-str">&quot;.debug_abbrev&quot;</span>, allocator) <span class="tok-kw">catch</span> <span class="tok-null">null</span>;</span>
<span class="line" id="L839">            <span class="tok-kw">const</span> debug_str_data = di.coff.getSectionData(<span class="tok-str">&quot;.debug_str&quot;</span>, allocator) <span class="tok-kw">catch</span> <span class="tok-null">null</span>;</span>
<span class="line" id="L840">            <span class="tok-kw">const</span> debug_line_data = di.coff.getSectionData(<span class="tok-str">&quot;.debug_line&quot;</span>, allocator) <span class="tok-kw">catch</span> <span class="tok-null">null</span>;</span>
<span class="line" id="L841">            <span class="tok-kw">const</span> debug_line_str_data = di.coff.getSectionData(<span class="tok-str">&quot;.debug_line_str&quot;</span>, allocator) <span class="tok-kw">catch</span> <span class="tok-null">null</span>;</span>
<span class="line" id="L842">            <span class="tok-kw">const</span> debug_ranges_data = di.coff.getSectionData(<span class="tok-str">&quot;.debug_ranges&quot;</span>, allocator) <span class="tok-kw">catch</span> <span class="tok-null">null</span>;</span>
<span class="line" id="L843"></span>
<span class="line" id="L844">            <span class="tok-kw">var</span> dwarf = DW.DwarfInfo{</span>
<span class="line" id="L845">                .endian = native_endian,</span>
<span class="line" id="L846">                .debug_info = debug_info_data <span class="tok-kw">orelse</span> <span class="tok-kw">return</span> <span class="tok-kw">error</span>.MissingDebugInfo,</span>
<span class="line" id="L847">                .debug_abbrev = debug_abbrev_data <span class="tok-kw">orelse</span> <span class="tok-kw">return</span> <span class="tok-kw">error</span>.MissingDebugInfo,</span>
<span class="line" id="L848">                .debug_str = debug_str_data <span class="tok-kw">orelse</span> <span class="tok-kw">return</span> <span class="tok-kw">error</span>.MissingDebugInfo,</span>
<span class="line" id="L849">                .debug_line = debug_line_data <span class="tok-kw">orelse</span> <span class="tok-kw">return</span> <span class="tok-kw">error</span>.MissingDebugInfo,</span>
<span class="line" id="L850">                .debug_line_str = debug_line_str_data,</span>
<span class="line" id="L851">                .debug_ranges = debug_ranges_data,</span>
<span class="line" id="L852">            };</span>
<span class="line" id="L853">            <span class="tok-kw">try</span> DW.openDwarfDebugInfo(&amp;dwarf, allocator);</span>
<span class="line" id="L854">            di.debug_data = PdbOrDwarf{ .dwarf = dwarf };</span>
<span class="line" id="L855">            <span class="tok-kw">return</span> di;</span>
<span class="line" id="L856">        }</span>
<span class="line" id="L857"></span>
<span class="line" id="L858">        <span class="tok-kw">var</span> path_buf: [windows.MAX_PATH]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L859">        <span class="tok-kw">const</span> len = <span class="tok-kw">try</span> di.coff.getPdbPath(path_buf[<span class="tok-number">0</span>..]);</span>
<span class="line" id="L860">        <span class="tok-kw">const</span> raw_path = path_buf[<span class="tok-number">0</span>..len];</span>
<span class="line" id="L861"></span>
<span class="line" id="L862">        <span class="tok-kw">const</span> path = <span class="tok-kw">try</span> fs.path.resolve(allocator, &amp;[_][]<span class="tok-kw">const</span> <span class="tok-type">u8</span>{raw_path});</span>
<span class="line" id="L863">        <span class="tok-kw">defer</span> allocator.free(path);</span>
<span class="line" id="L864"></span>
<span class="line" id="L865">        di.debug_data = PdbOrDwarf{ .pdb = <span class="tok-null">undefined</span> };</span>
<span class="line" id="L866">        di.debug_data.pdb = <span class="tok-kw">try</span> pdb.Pdb.init(allocator, path);</span>
<span class="line" id="L867">        <span class="tok-kw">try</span> di.debug_data.pdb.parseInfoStream();</span>
<span class="line" id="L868">        <span class="tok-kw">try</span> di.debug_data.pdb.parseDbiStream();</span>
<span class="line" id="L869"></span>
<span class="line" id="L870">        <span class="tok-kw">if</span> (!mem.eql(<span class="tok-type">u8</span>, &amp;di.coff.guid, &amp;di.debug_data.pdb.guid) <span class="tok-kw">or</span> di.coff.age != di.debug_data.pdb.age)</span>
<span class="line" id="L871">            <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InvalidDebugInfo;</span>
<span class="line" id="L872"></span>
<span class="line" id="L873">        <span class="tok-kw">return</span> di;</span>
<span class="line" id="L874">    }</span>
<span class="line" id="L875">}</span>
<span class="line" id="L876"></span>
<span class="line" id="L877"><span class="tok-kw">fn</span> <span class="tok-fn">chopSlice</span>(ptr: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, offset: <span class="tok-type">u64</span>, size: <span class="tok-type">u64</span>) <span class="tok-kw">error</span>{Overflow}![]<span class="tok-kw">const</span> <span class="tok-type">u8</span> {</span>
<span class="line" id="L878">    <span class="tok-kw">const</span> start = math.cast(<span class="tok-type">usize</span>, offset) <span class="tok-kw">orelse</span> <span class="tok-kw">return</span> <span class="tok-kw">error</span>.Overflow;</span>
<span class="line" id="L879">    <span class="tok-kw">const</span> end = start + (math.cast(<span class="tok-type">usize</span>, size) <span class="tok-kw">orelse</span> <span class="tok-kw">return</span> <span class="tok-kw">error</span>.Overflow);</span>
<span class="line" id="L880">    <span class="tok-kw">return</span> ptr[start..end];</span>
<span class="line" id="L881">}</span>
<span class="line" id="L882"></span>
<span class="line" id="L883"><span class="tok-comment">/// This takes ownership of elf_file: users of this function should not close</span></span>
<span class="line" id="L884"><span class="tok-comment">/// it themselves, even on error.</span></span>
<span class="line" id="L885"><span class="tok-comment">/// TODO it's weird to take ownership even on error, rework this code.</span></span>
<span class="line" id="L886"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">readElfDebugInfo</span>(allocator: mem.Allocator, elf_file: File) !ModuleDebugInfo {</span>
<span class="line" id="L887">    <span class="tok-kw">nosuspend</span> {</span>
<span class="line" id="L888">        <span class="tok-kw">const</span> mapped_mem = <span class="tok-kw">try</span> mapWholeFile(elf_file);</span>
<span class="line" id="L889">        <span class="tok-kw">const</span> hdr = <span class="tok-builtin">@ptrCast</span>(*<span class="tok-kw">const</span> elf.Ehdr, &amp;mapped_mem[<span class="tok-number">0</span>]);</span>
<span class="line" id="L890">        <span class="tok-kw">if</span> (!mem.eql(<span class="tok-type">u8</span>, hdr.e_ident[<span class="tok-number">0</span>..<span class="tok-number">4</span>], elf.MAGIC)) <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InvalidElfMagic;</span>
<span class="line" id="L891">        <span class="tok-kw">if</span> (hdr.e_ident[elf.EI_VERSION] != <span class="tok-number">1</span>) <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InvalidElfVersion;</span>
<span class="line" id="L892"></span>
<span class="line" id="L893">        <span class="tok-kw">const</span> endian: std.builtin.Endian = <span class="tok-kw">switch</span> (hdr.e_ident[elf.EI_DATA]) {</span>
<span class="line" id="L894">            elf.ELFDATA2LSB =&gt; .Little,</span>
<span class="line" id="L895">            elf.ELFDATA2MSB =&gt; .Big,</span>
<span class="line" id="L896">            <span class="tok-kw">else</span> =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InvalidElfEndian,</span>
<span class="line" id="L897">        };</span>
<span class="line" id="L898">        assert(endian == native_endian); <span class="tok-comment">// this is our own debug info</span>
</span>
<span class="line" id="L899"></span>
<span class="line" id="L900">        <span class="tok-kw">const</span> shoff = hdr.e_shoff;</span>
<span class="line" id="L901">        <span class="tok-kw">const</span> str_section_off = shoff + <span class="tok-builtin">@as</span>(<span class="tok-type">u64</span>, hdr.e_shentsize) * <span class="tok-builtin">@as</span>(<span class="tok-type">u64</span>, hdr.e_shstrndx);</span>
<span class="line" id="L902">        <span class="tok-kw">const</span> str_shdr = <span class="tok-builtin">@ptrCast</span>(</span>
<span class="line" id="L903">            *<span class="tok-kw">const</span> elf.Shdr,</span>
<span class="line" id="L904">            <span class="tok-builtin">@alignCast</span>(<span class="tok-builtin">@alignOf</span>(elf.Shdr), &amp;mapped_mem[math.cast(<span class="tok-type">usize</span>, str_section_off) <span class="tok-kw">orelse</span> <span class="tok-kw">return</span> <span class="tok-kw">error</span>.Overflow]),</span>
<span class="line" id="L905">        );</span>
<span class="line" id="L906">        <span class="tok-kw">const</span> header_strings = mapped_mem[str_shdr.sh_offset .. str_shdr.sh_offset + str_shdr.sh_size];</span>
<span class="line" id="L907">        <span class="tok-kw">const</span> shdrs = <span class="tok-builtin">@ptrCast</span>(</span>
<span class="line" id="L908">            [*]<span class="tok-kw">const</span> elf.Shdr,</span>
<span class="line" id="L909">            <span class="tok-builtin">@alignCast</span>(<span class="tok-builtin">@alignOf</span>(elf.Shdr), &amp;mapped_mem[shoff]),</span>
<span class="line" id="L910">        )[<span class="tok-number">0</span>..hdr.e_shnum];</span>
<span class="line" id="L911"></span>
<span class="line" id="L912">        <span class="tok-kw">var</span> opt_debug_info: ?[]<span class="tok-kw">const</span> <span class="tok-type">u8</span> = <span class="tok-null">null</span>;</span>
<span class="line" id="L913">        <span class="tok-kw">var</span> opt_debug_abbrev: ?[]<span class="tok-kw">const</span> <span class="tok-type">u8</span> = <span class="tok-null">null</span>;</span>
<span class="line" id="L914">        <span class="tok-kw">var</span> opt_debug_str: ?[]<span class="tok-kw">const</span> <span class="tok-type">u8</span> = <span class="tok-null">null</span>;</span>
<span class="line" id="L915">        <span class="tok-kw">var</span> opt_debug_line: ?[]<span class="tok-kw">const</span> <span class="tok-type">u8</span> = <span class="tok-null">null</span>;</span>
<span class="line" id="L916">        <span class="tok-kw">var</span> opt_debug_line_str: ?[]<span class="tok-kw">const</span> <span class="tok-type">u8</span> = <span class="tok-null">null</span>;</span>
<span class="line" id="L917">        <span class="tok-kw">var</span> opt_debug_ranges: ?[]<span class="tok-kw">const</span> <span class="tok-type">u8</span> = <span class="tok-null">null</span>;</span>
<span class="line" id="L918"></span>
<span class="line" id="L919">        <span class="tok-kw">for</span> (shdrs) |*shdr| {</span>
<span class="line" id="L920">            <span class="tok-kw">if</span> (shdr.sh_type == elf.SHT_NULL) <span class="tok-kw">continue</span>;</span>
<span class="line" id="L921"></span>
<span class="line" id="L922">            <span class="tok-kw">const</span> name = std.mem.span(std.meta.assumeSentinel(header_strings[shdr.sh_name..].ptr, <span class="tok-number">0</span>));</span>
<span class="line" id="L923">            <span class="tok-kw">if</span> (mem.eql(<span class="tok-type">u8</span>, name, <span class="tok-str">&quot;.debug_info&quot;</span>)) {</span>
<span class="line" id="L924">                opt_debug_info = <span class="tok-kw">try</span> chopSlice(mapped_mem, shdr.sh_offset, shdr.sh_size);</span>
<span class="line" id="L925">            } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (mem.eql(<span class="tok-type">u8</span>, name, <span class="tok-str">&quot;.debug_abbrev&quot;</span>)) {</span>
<span class="line" id="L926">                opt_debug_abbrev = <span class="tok-kw">try</span> chopSlice(mapped_mem, shdr.sh_offset, shdr.sh_size);</span>
<span class="line" id="L927">            } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (mem.eql(<span class="tok-type">u8</span>, name, <span class="tok-str">&quot;.debug_str&quot;</span>)) {</span>
<span class="line" id="L928">                opt_debug_str = <span class="tok-kw">try</span> chopSlice(mapped_mem, shdr.sh_offset, shdr.sh_size);</span>
<span class="line" id="L929">            } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (mem.eql(<span class="tok-type">u8</span>, name, <span class="tok-str">&quot;.debug_line&quot;</span>)) {</span>
<span class="line" id="L930">                opt_debug_line = <span class="tok-kw">try</span> chopSlice(mapped_mem, shdr.sh_offset, shdr.sh_size);</span>
<span class="line" id="L931">            } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (mem.eql(<span class="tok-type">u8</span>, name, <span class="tok-str">&quot;.debug_line_str&quot;</span>)) {</span>
<span class="line" id="L932">                opt_debug_line_str = <span class="tok-kw">try</span> chopSlice(mapped_mem, shdr.sh_offset, shdr.sh_size);</span>
<span class="line" id="L933">            } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (mem.eql(<span class="tok-type">u8</span>, name, <span class="tok-str">&quot;.debug_ranges&quot;</span>)) {</span>
<span class="line" id="L934">                opt_debug_ranges = <span class="tok-kw">try</span> chopSlice(mapped_mem, shdr.sh_offset, shdr.sh_size);</span>
<span class="line" id="L935">            }</span>
<span class="line" id="L936">        }</span>
<span class="line" id="L937"></span>
<span class="line" id="L938">        <span class="tok-kw">var</span> di = DW.DwarfInfo{</span>
<span class="line" id="L939">            .endian = endian,</span>
<span class="line" id="L940">            .debug_info = opt_debug_info <span class="tok-kw">orelse</span> <span class="tok-kw">return</span> <span class="tok-kw">error</span>.MissingDebugInfo,</span>
<span class="line" id="L941">            .debug_abbrev = opt_debug_abbrev <span class="tok-kw">orelse</span> <span class="tok-kw">return</span> <span class="tok-kw">error</span>.MissingDebugInfo,</span>
<span class="line" id="L942">            .debug_str = opt_debug_str <span class="tok-kw">orelse</span> <span class="tok-kw">return</span> <span class="tok-kw">error</span>.MissingDebugInfo,</span>
<span class="line" id="L943">            .debug_line = opt_debug_line <span class="tok-kw">orelse</span> <span class="tok-kw">return</span> <span class="tok-kw">error</span>.MissingDebugInfo,</span>
<span class="line" id="L944">            .debug_line_str = opt_debug_line_str,</span>
<span class="line" id="L945">            .debug_ranges = opt_debug_ranges,</span>
<span class="line" id="L946">        };</span>
<span class="line" id="L947"></span>
<span class="line" id="L948">        <span class="tok-kw">try</span> DW.openDwarfDebugInfo(&amp;di, allocator);</span>
<span class="line" id="L949"></span>
<span class="line" id="L950">        <span class="tok-kw">return</span> ModuleDebugInfo{</span>
<span class="line" id="L951">            .base_address = <span class="tok-null">undefined</span>,</span>
<span class="line" id="L952">            .dwarf = di,</span>
<span class="line" id="L953">            .mapped_memory = mapped_mem,</span>
<span class="line" id="L954">        };</span>
<span class="line" id="L955">    }</span>
<span class="line" id="L956">}</span>
<span class="line" id="L957"></span>
<span class="line" id="L958"><span class="tok-comment">/// This takes ownership of macho_file: users of this function should not close</span></span>
<span class="line" id="L959"><span class="tok-comment">/// it themselves, even on error.</span></span>
<span class="line" id="L960"><span class="tok-comment">/// TODO it's weird to take ownership even on error, rework this code.</span></span>
<span class="line" id="L961"><span class="tok-kw">fn</span> <span class="tok-fn">readMachODebugInfo</span>(allocator: mem.Allocator, macho_file: File) !ModuleDebugInfo {</span>
<span class="line" id="L962">    <span class="tok-kw">const</span> mapped_mem = <span class="tok-kw">try</span> mapWholeFile(macho_file);</span>
<span class="line" id="L963"></span>
<span class="line" id="L964">    <span class="tok-kw">const</span> hdr = <span class="tok-builtin">@ptrCast</span>(</span>
<span class="line" id="L965">        *<span class="tok-kw">const</span> macho.mach_header_64,</span>
<span class="line" id="L966">        <span class="tok-builtin">@alignCast</span>(<span class="tok-builtin">@alignOf</span>(macho.mach_header_64), mapped_mem.ptr),</span>
<span class="line" id="L967">    );</span>
<span class="line" id="L968">    <span class="tok-kw">if</span> (hdr.magic != macho.MH_MAGIC_64)</span>
<span class="line" id="L969">        <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InvalidDebugInfo;</span>
<span class="line" id="L970"></span>
<span class="line" id="L971">    <span class="tok-kw">var</span> it = macho.LoadCommandIterator{</span>
<span class="line" id="L972">        .ncmds = hdr.ncmds,</span>
<span class="line" id="L973">        .buffer = mapped_mem[<span class="tok-builtin">@sizeOf</span>(macho.mach_header_64)..][<span class="tok-number">0</span>..hdr.sizeofcmds],</span>
<span class="line" id="L974">    };</span>
<span class="line" id="L975">    <span class="tok-kw">const</span> symtab = <span class="tok-kw">while</span> (it.next()) |cmd| <span class="tok-kw">switch</span> (cmd.cmd()) {</span>
<span class="line" id="L976">        .SYMTAB =&gt; <span class="tok-kw">break</span> cmd.cast(macho.symtab_command).?,</span>
<span class="line" id="L977">        <span class="tok-kw">else</span> =&gt; {},</span>
<span class="line" id="L978">    } <span class="tok-kw">else</span> <span class="tok-kw">return</span> <span class="tok-kw">error</span>.MissingDebugInfo;</span>
<span class="line" id="L979"></span>
<span class="line" id="L980">    <span class="tok-kw">const</span> syms = <span class="tok-builtin">@ptrCast</span>(</span>
<span class="line" id="L981">        [*]<span class="tok-kw">const</span> macho.nlist_64,</span>
<span class="line" id="L982">        <span class="tok-builtin">@alignCast</span>(<span class="tok-builtin">@alignOf</span>(macho.nlist_64), &amp;mapped_mem[symtab.symoff]),</span>
<span class="line" id="L983">    )[<span class="tok-number">0</span>..symtab.nsyms];</span>
<span class="line" id="L984">    <span class="tok-kw">const</span> strings = mapped_mem[symtab.stroff..][<span class="tok-number">0</span> .. symtab.strsize - <span class="tok-number">1</span> :<span class="tok-number">0</span>];</span>
<span class="line" id="L985"></span>
<span class="line" id="L986">    <span class="tok-kw">const</span> symbols_buf = <span class="tok-kw">try</span> allocator.alloc(MachoSymbol, syms.len);</span>
<span class="line" id="L987"></span>
<span class="line" id="L988">    <span class="tok-kw">var</span> ofile: <span class="tok-type">u32</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L989">    <span class="tok-kw">var</span> last_sym: MachoSymbol = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L990">    <span class="tok-kw">var</span> symbol_index: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L991">    <span class="tok-kw">var</span> state: <span class="tok-kw">enum</span> {</span>
<span class="line" id="L992">        init,</span>
<span class="line" id="L993">        oso_open,</span>
<span class="line" id="L994">        oso_close,</span>
<span class="line" id="L995">        bnsym,</span>
<span class="line" id="L996">        fun_strx,</span>
<span class="line" id="L997">        fun_size,</span>
<span class="line" id="L998">        ensym,</span>
<span class="line" id="L999">    } = .init;</span>
<span class="line" id="L1000"></span>
<span class="line" id="L1001">    <span class="tok-kw">for</span> (syms) |*sym| {</span>
<span class="line" id="L1002">        <span class="tok-kw">if</span> (!sym.stab()) <span class="tok-kw">continue</span>;</span>
<span class="line" id="L1003"></span>
<span class="line" id="L1004">        <span class="tok-comment">// TODO handle globals N_GSYM, and statics N_STSYM</span>
</span>
<span class="line" id="L1005">        <span class="tok-kw">switch</span> (sym.n_type) {</span>
<span class="line" id="L1006">            macho.N_OSO =&gt; {</span>
<span class="line" id="L1007">                <span class="tok-kw">switch</span> (state) {</span>
<span class="line" id="L1008">                    .init, .oso_close =&gt; {</span>
<span class="line" id="L1009">                        state = .oso_open;</span>
<span class="line" id="L1010">                        ofile = sym.n_strx;</span>
<span class="line" id="L1011">                    },</span>
<span class="line" id="L1012">                    <span class="tok-kw">else</span> =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InvalidDebugInfo,</span>
<span class="line" id="L1013">                }</span>
<span class="line" id="L1014">            },</span>
<span class="line" id="L1015">            macho.N_BNSYM =&gt; {</span>
<span class="line" id="L1016">                <span class="tok-kw">switch</span> (state) {</span>
<span class="line" id="L1017">                    .oso_open, .ensym =&gt; {</span>
<span class="line" id="L1018">                        state = .bnsym;</span>
<span class="line" id="L1019">                        last_sym = .{</span>
<span class="line" id="L1020">                            .strx = <span class="tok-number">0</span>,</span>
<span class="line" id="L1021">                            .addr = sym.n_value,</span>
<span class="line" id="L1022">                            .size = <span class="tok-number">0</span>,</span>
<span class="line" id="L1023">                            .ofile = ofile,</span>
<span class="line" id="L1024">                        };</span>
<span class="line" id="L1025">                    },</span>
<span class="line" id="L1026">                    <span class="tok-kw">else</span> =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InvalidDebugInfo,</span>
<span class="line" id="L1027">                }</span>
<span class="line" id="L1028">            },</span>
<span class="line" id="L1029">            macho.N_FUN =&gt; {</span>
<span class="line" id="L1030">                <span class="tok-kw">switch</span> (state) {</span>
<span class="line" id="L1031">                    .bnsym =&gt; {</span>
<span class="line" id="L1032">                        state = .fun_strx;</span>
<span class="line" id="L1033">                        last_sym.strx = sym.n_strx;</span>
<span class="line" id="L1034">                    },</span>
<span class="line" id="L1035">                    .fun_strx =&gt; {</span>
<span class="line" id="L1036">                        state = .fun_size;</span>
<span class="line" id="L1037">                        last_sym.size = <span class="tok-builtin">@intCast</span>(<span class="tok-type">u32</span>, sym.n_value);</span>
<span class="line" id="L1038">                    },</span>
<span class="line" id="L1039">                    <span class="tok-kw">else</span> =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InvalidDebugInfo,</span>
<span class="line" id="L1040">                }</span>
<span class="line" id="L1041">            },</span>
<span class="line" id="L1042">            macho.N_ENSYM =&gt; {</span>
<span class="line" id="L1043">                <span class="tok-kw">switch</span> (state) {</span>
<span class="line" id="L1044">                    .fun_size =&gt; {</span>
<span class="line" id="L1045">                        state = .ensym;</span>
<span class="line" id="L1046">                        symbols_buf[symbol_index] = last_sym;</span>
<span class="line" id="L1047">                        symbol_index += <span class="tok-number">1</span>;</span>
<span class="line" id="L1048">                    },</span>
<span class="line" id="L1049">                    <span class="tok-kw">else</span> =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InvalidDebugInfo,</span>
<span class="line" id="L1050">                }</span>
<span class="line" id="L1051">            },</span>
<span class="line" id="L1052">            macho.N_SO =&gt; {</span>
<span class="line" id="L1053">                <span class="tok-kw">switch</span> (state) {</span>
<span class="line" id="L1054">                    .init, .oso_close =&gt; {},</span>
<span class="line" id="L1055">                    .oso_open, .ensym =&gt; {</span>
<span class="line" id="L1056">                        state = .oso_close;</span>
<span class="line" id="L1057">                    },</span>
<span class="line" id="L1058">                    <span class="tok-kw">else</span> =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InvalidDebugInfo,</span>
<span class="line" id="L1059">                }</span>
<span class="line" id="L1060">            },</span>
<span class="line" id="L1061">            <span class="tok-kw">else</span> =&gt; {},</span>
<span class="line" id="L1062">        }</span>
<span class="line" id="L1063">    }</span>
<span class="line" id="L1064">    assert(state == .oso_close);</span>
<span class="line" id="L1065"></span>
<span class="line" id="L1066">    <span class="tok-kw">const</span> symbols = allocator.shrink(symbols_buf, symbol_index);</span>
<span class="line" id="L1067"></span>
<span class="line" id="L1068">    <span class="tok-comment">// Even though lld emits symbols in ascending order, this debug code</span>
</span>
<span class="line" id="L1069">    <span class="tok-comment">// should work for programs linked in any valid way.</span>
</span>
<span class="line" id="L1070">    <span class="tok-comment">// This sort is so that we can binary search later.</span>
</span>
<span class="line" id="L1071">    std.sort.sort(MachoSymbol, symbols, {}, MachoSymbol.addressLessThan);</span>
<span class="line" id="L1072"></span>
<span class="line" id="L1073">    <span class="tok-kw">return</span> ModuleDebugInfo{</span>
<span class="line" id="L1074">        .base_address = <span class="tok-null">undefined</span>,</span>
<span class="line" id="L1075">        .mapped_memory = mapped_mem,</span>
<span class="line" id="L1076">        .ofiles = ModuleDebugInfo.OFileTable.init(allocator),</span>
<span class="line" id="L1077">        .symbols = symbols,</span>
<span class="line" id="L1078">        .strings = strings,</span>
<span class="line" id="L1079">    };</span>
<span class="line" id="L1080">}</span>
<span class="line" id="L1081"></span>
<span class="line" id="L1082"><span class="tok-kw">fn</span> <span class="tok-fn">printLineFromFileAnyOs</span>(out_stream: <span class="tok-kw">anytype</span>, line_info: LineInfo) !<span class="tok-type">void</span> {</span>
<span class="line" id="L1083">    <span class="tok-comment">// Need this to always block even in async I/O mode, because this could potentially</span>
</span>
<span class="line" id="L1084">    <span class="tok-comment">// be called from e.g. the event loop code crashing.</span>
</span>
<span class="line" id="L1085">    <span class="tok-kw">var</span> f = <span class="tok-kw">try</span> fs.cwd().openFile(line_info.file_name, .{ .intended_io_mode = .blocking });</span>
<span class="line" id="L1086">    <span class="tok-kw">defer</span> f.close();</span>
<span class="line" id="L1087">    <span class="tok-comment">// TODO fstat and make sure that the file has the correct size</span>
</span>
<span class="line" id="L1088"></span>
<span class="line" id="L1089">    <span class="tok-kw">var</span> buf: [mem.page_size]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L1090">    <span class="tok-kw">var</span> line: <span class="tok-type">usize</span> = <span class="tok-number">1</span>;</span>
<span class="line" id="L1091">    <span class="tok-kw">var</span> column: <span class="tok-type">usize</span> = <span class="tok-number">1</span>;</span>
<span class="line" id="L1092">    <span class="tok-kw">while</span> (<span class="tok-null">true</span>) {</span>
<span class="line" id="L1093">        <span class="tok-kw">const</span> amt_read = <span class="tok-kw">try</span> f.read(buf[<span class="tok-number">0</span>..]);</span>
<span class="line" id="L1094">        <span class="tok-kw">const</span> slice = buf[<span class="tok-number">0</span>..amt_read];</span>
<span class="line" id="L1095"></span>
<span class="line" id="L1096">        <span class="tok-kw">for</span> (slice) |byte| {</span>
<span class="line" id="L1097">            <span class="tok-kw">if</span> (line == line_info.line) {</span>
<span class="line" id="L1098">                <span class="tok-kw">try</span> out_stream.writeByte(byte);</span>
<span class="line" id="L1099">                <span class="tok-kw">if</span> (byte == <span class="tok-str">'\n'</span>) {</span>
<span class="line" id="L1100">                    <span class="tok-kw">return</span>;</span>
<span class="line" id="L1101">                }</span>
<span class="line" id="L1102">            }</span>
<span class="line" id="L1103">            <span class="tok-kw">if</span> (byte == <span class="tok-str">'\n'</span>) {</span>
<span class="line" id="L1104">                line += <span class="tok-number">1</span>;</span>
<span class="line" id="L1105">                column = <span class="tok-number">1</span>;</span>
<span class="line" id="L1106">            } <span class="tok-kw">else</span> {</span>
<span class="line" id="L1107">                column += <span class="tok-number">1</span>;</span>
<span class="line" id="L1108">            }</span>
<span class="line" id="L1109">        }</span>
<span class="line" id="L1110"></span>
<span class="line" id="L1111">        <span class="tok-kw">if</span> (amt_read &lt; buf.len) <span class="tok-kw">return</span> <span class="tok-kw">error</span>.EndOfFile;</span>
<span class="line" id="L1112">    }</span>
<span class="line" id="L1113">}</span>
<span class="line" id="L1114"></span>
<span class="line" id="L1115"><span class="tok-kw">const</span> MachoSymbol = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L1116">    strx: <span class="tok-type">u32</span>,</span>
<span class="line" id="L1117">    addr: <span class="tok-type">u64</span>,</span>
<span class="line" id="L1118">    size: <span class="tok-type">u32</span>,</span>
<span class="line" id="L1119">    ofile: <span class="tok-type">u32</span>,</span>
<span class="line" id="L1120"></span>
<span class="line" id="L1121">    <span class="tok-comment">/// Returns the address from the macho file</span></span>
<span class="line" id="L1122">    <span class="tok-kw">fn</span> <span class="tok-fn">address</span>(self: MachoSymbol) <span class="tok-type">u64</span> {</span>
<span class="line" id="L1123">        <span class="tok-kw">return</span> self.addr;</span>
<span class="line" id="L1124">    }</span>
<span class="line" id="L1125"></span>
<span class="line" id="L1126">    <span class="tok-kw">fn</span> <span class="tok-fn">addressLessThan</span>(context: <span class="tok-type">void</span>, lhs: MachoSymbol, rhs: MachoSymbol) <span class="tok-type">bool</span> {</span>
<span class="line" id="L1127">        _ = context;</span>
<span class="line" id="L1128">        <span class="tok-kw">return</span> lhs.addr &lt; rhs.addr;</span>
<span class="line" id="L1129">    }</span>
<span class="line" id="L1130">};</span>
<span class="line" id="L1131"></span>
<span class="line" id="L1132"><span class="tok-comment">/// `file` is expected to have been opened with .intended_io_mode == .blocking.</span></span>
<span class="line" id="L1133"><span class="tok-comment">/// Takes ownership of file, even on error.</span></span>
<span class="line" id="L1134"><span class="tok-comment">/// TODO it's weird to take ownership even on error, rework this code.</span></span>
<span class="line" id="L1135"><span class="tok-kw">fn</span> <span class="tok-fn">mapWholeFile</span>(file: File) ![]<span class="tok-kw">align</span>(mem.page_size) <span class="tok-kw">const</span> <span class="tok-type">u8</span> {</span>
<span class="line" id="L1136">    <span class="tok-kw">nosuspend</span> {</span>
<span class="line" id="L1137">        <span class="tok-kw">defer</span> file.close();</span>
<span class="line" id="L1138"></span>
<span class="line" id="L1139">        <span class="tok-kw">const</span> file_len = math.cast(<span class="tok-type">usize</span>, <span class="tok-kw">try</span> file.getEndPos()) <span class="tok-kw">orelse</span> math.maxInt(<span class="tok-type">usize</span>);</span>
<span class="line" id="L1140">        <span class="tok-kw">const</span> mapped_mem = <span class="tok-kw">try</span> os.mmap(</span>
<span class="line" id="L1141">            <span class="tok-null">null</span>,</span>
<span class="line" id="L1142">            file_len,</span>
<span class="line" id="L1143">            os.PROT.READ,</span>
<span class="line" id="L1144">            os.MAP.SHARED,</span>
<span class="line" id="L1145">            file.handle,</span>
<span class="line" id="L1146">            <span class="tok-number">0</span>,</span>
<span class="line" id="L1147">        );</span>
<span class="line" id="L1148">        <span class="tok-kw">errdefer</span> os.munmap(mapped_mem);</span>
<span class="line" id="L1149"></span>
<span class="line" id="L1150">        <span class="tok-kw">return</span> mapped_mem;</span>
<span class="line" id="L1151">    }</span>
<span class="line" id="L1152">}</span>
<span class="line" id="L1153"></span>
<span class="line" id="L1154"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> DebugInfo = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L1155">    allocator: mem.Allocator,</span>
<span class="line" id="L1156">    address_map: std.AutoHashMap(<span class="tok-type">usize</span>, *ModuleDebugInfo),</span>
<span class="line" id="L1157"></span>
<span class="line" id="L1158">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">init</span>(allocator: mem.Allocator) DebugInfo {</span>
<span class="line" id="L1159">        <span class="tok-kw">return</span> DebugInfo{</span>
<span class="line" id="L1160">            .allocator = allocator,</span>
<span class="line" id="L1161">            .address_map = std.AutoHashMap(<span class="tok-type">usize</span>, *ModuleDebugInfo).init(allocator),</span>
<span class="line" id="L1162">        };</span>
<span class="line" id="L1163">    }</span>
<span class="line" id="L1164"></span>
<span class="line" id="L1165">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">deinit</span>(self: *DebugInfo) <span class="tok-type">void</span> {</span>
<span class="line" id="L1166">        <span class="tok-kw">var</span> it = self.address_map.iterator();</span>
<span class="line" id="L1167">        <span class="tok-kw">while</span> (it.next()) |entry| {</span>
<span class="line" id="L1168">            <span class="tok-kw">const</span> mdi = entry.value_ptr.*;</span>
<span class="line" id="L1169">            mdi.deinit(self.allocator);</span>
<span class="line" id="L1170">            self.allocator.destroy(mdi);</span>
<span class="line" id="L1171">        }</span>
<span class="line" id="L1172">        self.address_map.deinit();</span>
<span class="line" id="L1173">    }</span>
<span class="line" id="L1174"></span>
<span class="line" id="L1175">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">getModuleForAddress</span>(self: *DebugInfo, address: <span class="tok-type">usize</span>) !*ModuleDebugInfo {</span>
<span class="line" id="L1176">        <span class="tok-kw">if</span> (<span class="tok-kw">comptime</span> builtin.target.isDarwin()) {</span>
<span class="line" id="L1177">            <span class="tok-kw">return</span> self.lookupModuleDyld(address);</span>
<span class="line" id="L1178">        } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (native_os == .windows) {</span>
<span class="line" id="L1179">            <span class="tok-kw">return</span> self.lookupModuleWin32(address);</span>
<span class="line" id="L1180">        } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (native_os == .haiku) {</span>
<span class="line" id="L1181">            <span class="tok-kw">return</span> self.lookupModuleHaiku(address);</span>
<span class="line" id="L1182">        } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (<span class="tok-kw">comptime</span> builtin.target.isWasm()) {</span>
<span class="line" id="L1183">            <span class="tok-kw">return</span> self.lookupModuleWasm(address);</span>
<span class="line" id="L1184">        } <span class="tok-kw">else</span> {</span>
<span class="line" id="L1185">            <span class="tok-kw">return</span> self.lookupModuleDl(address);</span>
<span class="line" id="L1186">        }</span>
<span class="line" id="L1187">    }</span>
<span class="line" id="L1188"></span>
<span class="line" id="L1189">    <span class="tok-kw">fn</span> <span class="tok-fn">lookupModuleDyld</span>(self: *DebugInfo, address: <span class="tok-type">usize</span>) !*ModuleDebugInfo {</span>
<span class="line" id="L1190">        <span class="tok-kw">const</span> image_count = std.c._dyld_image_count();</span>
<span class="line" id="L1191"></span>
<span class="line" id="L1192">        <span class="tok-kw">var</span> i: <span class="tok-type">u32</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L1193">        <span class="tok-kw">while</span> (i &lt; image_count) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L1194">            <span class="tok-kw">const</span> base_address = std.c._dyld_get_image_vmaddr_slide(i);</span>
<span class="line" id="L1195"></span>
<span class="line" id="L1196">            <span class="tok-kw">if</span> (address &lt; base_address) <span class="tok-kw">continue</span>;</span>
<span class="line" id="L1197"></span>
<span class="line" id="L1198">            <span class="tok-kw">const</span> header = std.c._dyld_get_image_header(i) <span class="tok-kw">orelse</span> <span class="tok-kw">continue</span>;</span>
<span class="line" id="L1199"></span>
<span class="line" id="L1200">            <span class="tok-kw">var</span> it = macho.LoadCommandIterator{</span>
<span class="line" id="L1201">                .ncmds = header.ncmds,</span>
<span class="line" id="L1202">                .buffer = <span class="tok-builtin">@alignCast</span>(<span class="tok-builtin">@alignOf</span>(<span class="tok-type">u64</span>), <span class="tok-builtin">@intToPtr</span>(</span>
<span class="line" id="L1203">                    [*]<span class="tok-type">u8</span>,</span>
<span class="line" id="L1204">                    <span class="tok-builtin">@ptrToInt</span>(header) + <span class="tok-builtin">@sizeOf</span>(macho.mach_header_64),</span>
<span class="line" id="L1205">                ))[<span class="tok-number">0</span>..header.sizeofcmds],</span>
<span class="line" id="L1206">            };</span>
<span class="line" id="L1207">            <span class="tok-kw">while</span> (it.next()) |cmd| <span class="tok-kw">switch</span> (cmd.cmd()) {</span>
<span class="line" id="L1208">                .SEGMENT_64 =&gt; {</span>
<span class="line" id="L1209">                    <span class="tok-kw">const</span> segment_cmd = cmd.cast(macho.segment_command_64).?;</span>
<span class="line" id="L1210">                    <span class="tok-kw">const</span> rebased_address = address - base_address;</span>
<span class="line" id="L1211">                    <span class="tok-kw">const</span> seg_start = segment_cmd.vmaddr;</span>
<span class="line" id="L1212">                    <span class="tok-kw">const</span> seg_end = seg_start + segment_cmd.vmsize;</span>
<span class="line" id="L1213"></span>
<span class="line" id="L1214">                    <span class="tok-kw">if</span> (rebased_address &gt;= seg_start <span class="tok-kw">and</span> rebased_address &lt; seg_end) {</span>
<span class="line" id="L1215">                        <span class="tok-kw">if</span> (self.address_map.get(base_address)) |obj_di| {</span>
<span class="line" id="L1216">                            <span class="tok-kw">return</span> obj_di;</span>
<span class="line" id="L1217">                        }</span>
<span class="line" id="L1218"></span>
<span class="line" id="L1219">                        <span class="tok-kw">const</span> obj_di = <span class="tok-kw">try</span> self.allocator.create(ModuleDebugInfo);</span>
<span class="line" id="L1220">                        <span class="tok-kw">errdefer</span> self.allocator.destroy(obj_di);</span>
<span class="line" id="L1221"></span>
<span class="line" id="L1222">                        <span class="tok-kw">const</span> macho_path = mem.sliceTo(std.c._dyld_get_image_name(i), <span class="tok-number">0</span>);</span>
<span class="line" id="L1223">                        <span class="tok-kw">const</span> macho_file = fs.cwd().openFile(macho_path, .{</span>
<span class="line" id="L1224">                            .intended_io_mode = .blocking,</span>
<span class="line" id="L1225">                        }) <span class="tok-kw">catch</span> |err| <span class="tok-kw">switch</span> (err) {</span>
<span class="line" id="L1226">                            <span class="tok-kw">error</span>.FileNotFound =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.MissingDebugInfo,</span>
<span class="line" id="L1227">                            <span class="tok-kw">else</span> =&gt; <span class="tok-kw">return</span> err,</span>
<span class="line" id="L1228">                        };</span>
<span class="line" id="L1229">                        obj_di.* = <span class="tok-kw">try</span> readMachODebugInfo(self.allocator, macho_file);</span>
<span class="line" id="L1230">                        obj_di.base_address = base_address;</span>
<span class="line" id="L1231"></span>
<span class="line" id="L1232">                        <span class="tok-kw">try</span> self.address_map.putNoClobber(base_address, obj_di);</span>
<span class="line" id="L1233"></span>
<span class="line" id="L1234">                        <span class="tok-kw">return</span> obj_di;</span>
<span class="line" id="L1235">                    }</span>
<span class="line" id="L1236">                },</span>
<span class="line" id="L1237">                <span class="tok-kw">else</span> =&gt; {},</span>
<span class="line" id="L1238">            };</span>
<span class="line" id="L1239">        }</span>
<span class="line" id="L1240"></span>
<span class="line" id="L1241">        <span class="tok-kw">return</span> <span class="tok-kw">error</span>.MissingDebugInfo;</span>
<span class="line" id="L1242">    }</span>
<span class="line" id="L1243"></span>
<span class="line" id="L1244">    <span class="tok-kw">fn</span> <span class="tok-fn">lookupModuleWin32</span>(self: *DebugInfo, address: <span class="tok-type">usize</span>) !*ModuleDebugInfo {</span>
<span class="line" id="L1245">        <span class="tok-kw">const</span> process_handle = windows.kernel32.GetCurrentProcess();</span>
<span class="line" id="L1246"></span>
<span class="line" id="L1247">        <span class="tok-comment">// Find how many modules are actually loaded</span>
</span>
<span class="line" id="L1248">        <span class="tok-kw">var</span> dummy: windows.HMODULE = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L1249">        <span class="tok-kw">var</span> bytes_needed: windows.DWORD = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L1250">        <span class="tok-kw">if</span> (windows.kernel32.K32EnumProcessModules(</span>
<span class="line" id="L1251">            process_handle,</span>
<span class="line" id="L1252">            <span class="tok-builtin">@ptrCast</span>([*]windows.HMODULE, &amp;dummy),</span>
<span class="line" id="L1253">            <span class="tok-number">0</span>,</span>
<span class="line" id="L1254">            &amp;bytes_needed,</span>
<span class="line" id="L1255">        ) == <span class="tok-number">0</span>)</span>
<span class="line" id="L1256">            <span class="tok-kw">return</span> <span class="tok-kw">error</span>.MissingDebugInfo;</span>
<span class="line" id="L1257"></span>
<span class="line" id="L1258">        <span class="tok-kw">const</span> needed_modules = bytes_needed / <span class="tok-builtin">@sizeOf</span>(windows.HMODULE);</span>
<span class="line" id="L1259"></span>
<span class="line" id="L1260">        <span class="tok-comment">// Fetch the complete module list</span>
</span>
<span class="line" id="L1261">        <span class="tok-kw">var</span> modules = <span class="tok-kw">try</span> self.allocator.alloc(windows.HMODULE, needed_modules);</span>
<span class="line" id="L1262">        <span class="tok-kw">defer</span> self.allocator.free(modules);</span>
<span class="line" id="L1263">        <span class="tok-kw">if</span> (windows.kernel32.K32EnumProcessModules(</span>
<span class="line" id="L1264">            process_handle,</span>
<span class="line" id="L1265">            modules.ptr,</span>
<span class="line" id="L1266">            math.cast(windows.DWORD, modules.len * <span class="tok-builtin">@sizeOf</span>(windows.HMODULE)) <span class="tok-kw">orelse</span> <span class="tok-kw">return</span> <span class="tok-kw">error</span>.Overflow,</span>
<span class="line" id="L1267">            &amp;bytes_needed,</span>
<span class="line" id="L1268">        ) == <span class="tok-number">0</span>)</span>
<span class="line" id="L1269">            <span class="tok-kw">return</span> <span class="tok-kw">error</span>.MissingDebugInfo;</span>
<span class="line" id="L1270"></span>
<span class="line" id="L1271">        <span class="tok-comment">// There's an unavoidable TOCTOU problem here, the module list may have</span>
</span>
<span class="line" id="L1272">        <span class="tok-comment">// changed between the two EnumProcessModules call.</span>
</span>
<span class="line" id="L1273">        <span class="tok-comment">// Pick the smallest amount of elements to avoid processing garbage.</span>
</span>
<span class="line" id="L1274">        <span class="tok-kw">const</span> needed_modules_after = bytes_needed / <span class="tok-builtin">@sizeOf</span>(windows.HMODULE);</span>
<span class="line" id="L1275">        <span class="tok-kw">const</span> loaded_modules = math.min(needed_modules, needed_modules_after);</span>
<span class="line" id="L1276"></span>
<span class="line" id="L1277">        <span class="tok-kw">for</span> (modules[<span class="tok-number">0</span>..loaded_modules]) |module| {</span>
<span class="line" id="L1278">            <span class="tok-kw">var</span> info: windows.MODULEINFO = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L1279">            <span class="tok-kw">if</span> (windows.kernel32.K32GetModuleInformation(</span>
<span class="line" id="L1280">                process_handle,</span>
<span class="line" id="L1281">                module,</span>
<span class="line" id="L1282">                &amp;info,</span>
<span class="line" id="L1283">                <span class="tok-builtin">@sizeOf</span>(<span class="tok-builtin">@TypeOf</span>(info)),</span>
<span class="line" id="L1284">            ) == <span class="tok-number">0</span>)</span>
<span class="line" id="L1285">                <span class="tok-kw">return</span> <span class="tok-kw">error</span>.MissingDebugInfo;</span>
<span class="line" id="L1286"></span>
<span class="line" id="L1287">            <span class="tok-kw">const</span> seg_start = <span class="tok-builtin">@ptrToInt</span>(info.lpBaseOfDll);</span>
<span class="line" id="L1288">            <span class="tok-kw">const</span> seg_end = seg_start + info.SizeOfImage;</span>
<span class="line" id="L1289"></span>
<span class="line" id="L1290">            <span class="tok-kw">if</span> (address &gt;= seg_start <span class="tok-kw">and</span> address &lt; seg_end) {</span>
<span class="line" id="L1291">                <span class="tok-kw">if</span> (self.address_map.get(seg_start)) |obj_di| {</span>
<span class="line" id="L1292">                    <span class="tok-kw">return</span> obj_di;</span>
<span class="line" id="L1293">                }</span>
<span class="line" id="L1294"></span>
<span class="line" id="L1295">                <span class="tok-kw">var</span> name_buffer: [windows.PATH_MAX_WIDE + <span class="tok-number">4</span>:<span class="tok-number">0</span>]<span class="tok-type">u16</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L1296">                <span class="tok-comment">// openFileAbsoluteW requires the prefix to be present</span>
</span>
<span class="line" id="L1297">                mem.copy(<span class="tok-type">u16</span>, name_buffer[<span class="tok-number">0</span>..<span class="tok-number">4</span>], &amp;[_]<span class="tok-type">u16</span>{ <span class="tok-str">'\\'</span>, <span class="tok-str">'?'</span>, <span class="tok-str">'?'</span>, <span class="tok-str">'\\'</span> });</span>
<span class="line" id="L1298">                <span class="tok-kw">const</span> len = windows.kernel32.K32GetModuleFileNameExW(</span>
<span class="line" id="L1299">                    process_handle,</span>
<span class="line" id="L1300">                    module,</span>
<span class="line" id="L1301">                    <span class="tok-builtin">@ptrCast</span>(windows.LPWSTR, &amp;name_buffer[<span class="tok-number">4</span>]),</span>
<span class="line" id="L1302">                    windows.PATH_MAX_WIDE,</span>
<span class="line" id="L1303">                );</span>
<span class="line" id="L1304">                assert(len &gt; <span class="tok-number">0</span>);</span>
<span class="line" id="L1305"></span>
<span class="line" id="L1306">                <span class="tok-kw">const</span> obj_di = <span class="tok-kw">try</span> self.allocator.create(ModuleDebugInfo);</span>
<span class="line" id="L1307">                <span class="tok-kw">errdefer</span> self.allocator.destroy(obj_di);</span>
<span class="line" id="L1308"></span>
<span class="line" id="L1309">                <span class="tok-kw">const</span> coff_file = fs.openFileAbsoluteW(name_buffer[<span class="tok-number">0</span> .. len + <span class="tok-number">4</span> :<span class="tok-number">0</span>], .{}) <span class="tok-kw">catch</span> |err| <span class="tok-kw">switch</span> (err) {</span>
<span class="line" id="L1310">                    <span class="tok-kw">error</span>.FileNotFound =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.MissingDebugInfo,</span>
<span class="line" id="L1311">                    <span class="tok-kw">else</span> =&gt; <span class="tok-kw">return</span> err,</span>
<span class="line" id="L1312">                };</span>
<span class="line" id="L1313">                obj_di.* = <span class="tok-kw">try</span> readCoffDebugInfo(self.allocator, coff_file);</span>
<span class="line" id="L1314">                obj_di.base_address = seg_start;</span>
<span class="line" id="L1315"></span>
<span class="line" id="L1316">                <span class="tok-kw">try</span> self.address_map.putNoClobber(seg_start, obj_di);</span>
<span class="line" id="L1317"></span>
<span class="line" id="L1318">                <span class="tok-kw">return</span> obj_di;</span>
<span class="line" id="L1319">            }</span>
<span class="line" id="L1320">        }</span>
<span class="line" id="L1321"></span>
<span class="line" id="L1322">        <span class="tok-kw">return</span> <span class="tok-kw">error</span>.MissingDebugInfo;</span>
<span class="line" id="L1323">    }</span>
<span class="line" id="L1324"></span>
<span class="line" id="L1325">    <span class="tok-kw">fn</span> <span class="tok-fn">lookupModuleDl</span>(self: *DebugInfo, address: <span class="tok-type">usize</span>) !*ModuleDebugInfo {</span>
<span class="line" id="L1326">        <span class="tok-kw">var</span> ctx: <span class="tok-kw">struct</span> {</span>
<span class="line" id="L1327">            <span class="tok-comment">// Input</span>
</span>
<span class="line" id="L1328">            address: <span class="tok-type">usize</span>,</span>
<span class="line" id="L1329">            <span class="tok-comment">// Output</span>
</span>
<span class="line" id="L1330">            base_address: <span class="tok-type">usize</span> = <span class="tok-null">undefined</span>,</span>
<span class="line" id="L1331">            name: []<span class="tok-kw">const</span> <span class="tok-type">u8</span> = <span class="tok-null">undefined</span>,</span>
<span class="line" id="L1332">        } = .{ .address = address };</span>
<span class="line" id="L1333">        <span class="tok-kw">const</span> CtxTy = <span class="tok-builtin">@TypeOf</span>(ctx);</span>
<span class="line" id="L1334"></span>
<span class="line" id="L1335">        <span class="tok-kw">if</span> (os.dl_iterate_phdr(&amp;ctx, <span class="tok-type">anyerror</span>, <span class="tok-kw">struct</span> {</span>
<span class="line" id="L1336">            <span class="tok-kw">fn</span> <span class="tok-fn">callback</span>(info: *os.dl_phdr_info, size: <span class="tok-type">usize</span>, context: *CtxTy) !<span class="tok-type">void</span> {</span>
<span class="line" id="L1337">                _ = size;</span>
<span class="line" id="L1338">                <span class="tok-comment">// The base address is too high</span>
</span>
<span class="line" id="L1339">                <span class="tok-kw">if</span> (context.address &lt; info.dlpi_addr)</span>
<span class="line" id="L1340">                    <span class="tok-kw">return</span>;</span>
<span class="line" id="L1341"></span>
<span class="line" id="L1342">                <span class="tok-kw">const</span> phdrs = info.dlpi_phdr[<span class="tok-number">0</span>..info.dlpi_phnum];</span>
<span class="line" id="L1343">                <span class="tok-kw">for</span> (phdrs) |*phdr| {</span>
<span class="line" id="L1344">                    <span class="tok-kw">if</span> (phdr.p_type != elf.PT_LOAD) <span class="tok-kw">continue</span>;</span>
<span class="line" id="L1345"></span>
<span class="line" id="L1346">                    <span class="tok-kw">const</span> seg_start = info.dlpi_addr + phdr.p_vaddr;</span>
<span class="line" id="L1347">                    <span class="tok-kw">const</span> seg_end = seg_start + phdr.p_memsz;</span>
<span class="line" id="L1348"></span>
<span class="line" id="L1349">                    <span class="tok-kw">if</span> (context.address &gt;= seg_start <span class="tok-kw">and</span> context.address &lt; seg_end) {</span>
<span class="line" id="L1350">                        <span class="tok-comment">// Android libc uses NULL instead of an empty string to mark the</span>
</span>
<span class="line" id="L1351">                        <span class="tok-comment">// main program</span>
</span>
<span class="line" id="L1352">                        context.name = mem.sliceTo(info.dlpi_name, <span class="tok-number">0</span>) <span class="tok-kw">orelse</span> <span class="tok-str">&quot;&quot;</span>;</span>
<span class="line" id="L1353">                        context.base_address = info.dlpi_addr;</span>
<span class="line" id="L1354">                        <span class="tok-comment">// Stop the iteration</span>
</span>
<span class="line" id="L1355">                        <span class="tok-kw">return</span> <span class="tok-kw">error</span>.Found;</span>
<span class="line" id="L1356">                    }</span>
<span class="line" id="L1357">                }</span>
<span class="line" id="L1358">            }</span>
<span class="line" id="L1359">        }.callback)) {</span>
<span class="line" id="L1360">            <span class="tok-kw">return</span> <span class="tok-kw">error</span>.MissingDebugInfo;</span>
<span class="line" id="L1361">        } <span class="tok-kw">else</span> |err| <span class="tok-kw">switch</span> (err) {</span>
<span class="line" id="L1362">            <span class="tok-kw">error</span>.Found =&gt; {},</span>
<span class="line" id="L1363">            <span class="tok-kw">else</span> =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.MissingDebugInfo,</span>
<span class="line" id="L1364">        }</span>
<span class="line" id="L1365"></span>
<span class="line" id="L1366">        <span class="tok-kw">if</span> (self.address_map.get(ctx.base_address)) |obj_di| {</span>
<span class="line" id="L1367">            <span class="tok-kw">return</span> obj_di;</span>
<span class="line" id="L1368">        }</span>
<span class="line" id="L1369"></span>
<span class="line" id="L1370">        <span class="tok-kw">const</span> obj_di = <span class="tok-kw">try</span> self.allocator.create(ModuleDebugInfo);</span>
<span class="line" id="L1371">        <span class="tok-kw">errdefer</span> self.allocator.destroy(obj_di);</span>
<span class="line" id="L1372"></span>
<span class="line" id="L1373">        <span class="tok-comment">// TODO https://github.com/ziglang/zig/issues/5525</span>
</span>
<span class="line" id="L1374">        <span class="tok-kw">const</span> copy = <span class="tok-kw">if</span> (ctx.name.len &gt; <span class="tok-number">0</span>)</span>
<span class="line" id="L1375">            fs.cwd().openFile(ctx.name, .{ .intended_io_mode = .blocking })</span>
<span class="line" id="L1376">        <span class="tok-kw">else</span></span>
<span class="line" id="L1377">            fs.openSelfExe(.{ .intended_io_mode = .blocking });</span>
<span class="line" id="L1378"></span>
<span class="line" id="L1379">        <span class="tok-kw">const</span> elf_file = copy <span class="tok-kw">catch</span> |err| <span class="tok-kw">switch</span> (err) {</span>
<span class="line" id="L1380">            <span class="tok-kw">error</span>.FileNotFound =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.MissingDebugInfo,</span>
<span class="line" id="L1381">            <span class="tok-kw">else</span> =&gt; <span class="tok-kw">return</span> err,</span>
<span class="line" id="L1382">        };</span>
<span class="line" id="L1383"></span>
<span class="line" id="L1384">        obj_di.* = <span class="tok-kw">try</span> readElfDebugInfo(self.allocator, elf_file);</span>
<span class="line" id="L1385">        obj_di.base_address = ctx.base_address;</span>
<span class="line" id="L1386"></span>
<span class="line" id="L1387">        <span class="tok-kw">try</span> self.address_map.putNoClobber(ctx.base_address, obj_di);</span>
<span class="line" id="L1388"></span>
<span class="line" id="L1389">        <span class="tok-kw">return</span> obj_di;</span>
<span class="line" id="L1390">    }</span>
<span class="line" id="L1391"></span>
<span class="line" id="L1392">    <span class="tok-kw">fn</span> <span class="tok-fn">lookupModuleHaiku</span>(self: *DebugInfo, address: <span class="tok-type">usize</span>) !*ModuleDebugInfo {</span>
<span class="line" id="L1393">        _ = self;</span>
<span class="line" id="L1394">        _ = address;</span>
<span class="line" id="L1395">        <span class="tok-builtin">@panic</span>(<span class="tok-str">&quot;TODO implement lookup module for Haiku&quot;</span>);</span>
<span class="line" id="L1396">    }</span>
<span class="line" id="L1397"></span>
<span class="line" id="L1398">    <span class="tok-kw">fn</span> <span class="tok-fn">lookupModuleWasm</span>(self: *DebugInfo, address: <span class="tok-type">usize</span>) !*ModuleDebugInfo {</span>
<span class="line" id="L1399">        _ = self;</span>
<span class="line" id="L1400">        _ = address;</span>
<span class="line" id="L1401">        <span class="tok-builtin">@panic</span>(<span class="tok-str">&quot;TODO implement lookup module for Wasm&quot;</span>);</span>
<span class="line" id="L1402">    }</span>
<span class="line" id="L1403">};</span>
<span class="line" id="L1404"></span>
<span class="line" id="L1405"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> ModuleDebugInfo = <span class="tok-kw">switch</span> (native_os) {</span>
<span class="line" id="L1406">    .macos, .ios, .watchos, .tvos =&gt; <span class="tok-kw">struct</span> {</span>
<span class="line" id="L1407">        base_address: <span class="tok-type">usize</span>,</span>
<span class="line" id="L1408">        mapped_memory: []<span class="tok-kw">align</span>(mem.page_size) <span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L1409">        symbols: []<span class="tok-kw">const</span> MachoSymbol,</span>
<span class="line" id="L1410">        strings: [:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L1411">        ofiles: OFileTable,</span>
<span class="line" id="L1412"></span>
<span class="line" id="L1413">        <span class="tok-kw">const</span> OFileTable = std.StringHashMap(OFileInfo);</span>
<span class="line" id="L1414">        <span class="tok-kw">const</span> OFileInfo = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L1415">            di: DW.DwarfInfo,</span>
<span class="line" id="L1416">            addr_table: std.StringHashMap(<span class="tok-type">u64</span>),</span>
<span class="line" id="L1417">        };</span>
<span class="line" id="L1418"></span>
<span class="line" id="L1419">        <span class="tok-kw">fn</span> <span class="tok-fn">deinit</span>(self: *<span class="tok-builtin">@This</span>(), allocator: mem.Allocator) <span class="tok-type">void</span> {</span>
<span class="line" id="L1420">            <span class="tok-kw">var</span> it = self.ofiles.iterator();</span>
<span class="line" id="L1421">            <span class="tok-kw">while</span> (it.next()) |entry| {</span>
<span class="line" id="L1422">                <span class="tok-kw">const</span> ofile = entry.value_ptr;</span>
<span class="line" id="L1423">                ofile.di.deinit(allocator);</span>
<span class="line" id="L1424">                ofile.addr_table.deinit();</span>
<span class="line" id="L1425">            }</span>
<span class="line" id="L1426">            self.ofiles.deinit();</span>
<span class="line" id="L1427">            allocator.free(self.symbols);</span>
<span class="line" id="L1428">            os.munmap(self.mapped_memory);</span>
<span class="line" id="L1429">        }</span>
<span class="line" id="L1430"></span>
<span class="line" id="L1431">        <span class="tok-kw">fn</span> <span class="tok-fn">loadOFile</span>(self: *<span class="tok-builtin">@This</span>(), allocator: mem.Allocator, o_file_path: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) !OFileInfo {</span>
<span class="line" id="L1432">            <span class="tok-kw">const</span> o_file = <span class="tok-kw">try</span> fs.cwd().openFile(o_file_path, .{ .intended_io_mode = .blocking });</span>
<span class="line" id="L1433">            <span class="tok-kw">const</span> mapped_mem = <span class="tok-kw">try</span> mapWholeFile(o_file);</span>
<span class="line" id="L1434"></span>
<span class="line" id="L1435">            <span class="tok-kw">const</span> hdr = <span class="tok-builtin">@ptrCast</span>(</span>
<span class="line" id="L1436">                *<span class="tok-kw">const</span> macho.mach_header_64,</span>
<span class="line" id="L1437">                <span class="tok-builtin">@alignCast</span>(<span class="tok-builtin">@alignOf</span>(macho.mach_header_64), mapped_mem.ptr),</span>
<span class="line" id="L1438">            );</span>
<span class="line" id="L1439">            <span class="tok-kw">if</span> (hdr.magic != std.macho.MH_MAGIC_64)</span>
<span class="line" id="L1440">                <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InvalidDebugInfo;</span>
<span class="line" id="L1441"></span>
<span class="line" id="L1442">            <span class="tok-kw">var</span> segcmd: ?macho.LoadCommandIterator.LoadCommand = <span class="tok-null">null</span>;</span>
<span class="line" id="L1443">            <span class="tok-kw">var</span> symtabcmd: ?macho.symtab_command = <span class="tok-null">null</span>;</span>
<span class="line" id="L1444">            <span class="tok-kw">var</span> it = macho.LoadCommandIterator{</span>
<span class="line" id="L1445">                .ncmds = hdr.ncmds,</span>
<span class="line" id="L1446">                .buffer = mapped_mem[<span class="tok-builtin">@sizeOf</span>(macho.mach_header_64)..][<span class="tok-number">0</span>..hdr.sizeofcmds],</span>
<span class="line" id="L1447">            };</span>
<span class="line" id="L1448">            <span class="tok-kw">while</span> (it.next()) |cmd| <span class="tok-kw">switch</span> (cmd.cmd()) {</span>
<span class="line" id="L1449">                .SEGMENT_64 =&gt; segcmd = cmd,</span>
<span class="line" id="L1450">                .SYMTAB =&gt; symtabcmd = cmd.cast(macho.symtab_command).?,</span>
<span class="line" id="L1451">                <span class="tok-kw">else</span> =&gt; {},</span>
<span class="line" id="L1452">            };</span>
<span class="line" id="L1453"></span>
<span class="line" id="L1454">            <span class="tok-kw">if</span> (segcmd == <span class="tok-null">null</span> <span class="tok-kw">or</span> symtabcmd == <span class="tok-null">null</span>) <span class="tok-kw">return</span> <span class="tok-kw">error</span>.MissingDebugInfo;</span>
<span class="line" id="L1455"></span>
<span class="line" id="L1456">            <span class="tok-comment">// Parse symbols</span>
</span>
<span class="line" id="L1457">            <span class="tok-kw">const</span> strtab = <span class="tok-builtin">@ptrCast</span>(</span>
<span class="line" id="L1458">                [*]<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L1459">                &amp;mapped_mem[symtabcmd.?.stroff],</span>
<span class="line" id="L1460">            )[<span class="tok-number">0</span> .. symtabcmd.?.strsize - <span class="tok-number">1</span> :<span class="tok-number">0</span>];</span>
<span class="line" id="L1461">            <span class="tok-kw">const</span> symtab = <span class="tok-builtin">@ptrCast</span>(</span>
<span class="line" id="L1462">                [*]<span class="tok-kw">const</span> macho.nlist_64,</span>
<span class="line" id="L1463">                <span class="tok-builtin">@alignCast</span>(</span>
<span class="line" id="L1464">                    <span class="tok-builtin">@alignOf</span>(macho.nlist_64),</span>
<span class="line" id="L1465">                    &amp;mapped_mem[symtabcmd.?.symoff],</span>
<span class="line" id="L1466">                ),</span>
<span class="line" id="L1467">            )[<span class="tok-number">0</span>..symtabcmd.?.nsyms];</span>
<span class="line" id="L1468"></span>
<span class="line" id="L1469">            <span class="tok-comment">// TODO handle tentative (common) symbols</span>
</span>
<span class="line" id="L1470">            <span class="tok-kw">var</span> addr_table = std.StringHashMap(<span class="tok-type">u64</span>).init(allocator);</span>
<span class="line" id="L1471">            <span class="tok-kw">try</span> addr_table.ensureTotalCapacity(<span class="tok-builtin">@intCast</span>(<span class="tok-type">u32</span>, symtab.len));</span>
<span class="line" id="L1472">            <span class="tok-kw">for</span> (symtab) |sym| {</span>
<span class="line" id="L1473">                <span class="tok-kw">if</span> (sym.n_strx == <span class="tok-number">0</span>) <span class="tok-kw">continue</span>;</span>
<span class="line" id="L1474">                <span class="tok-kw">if</span> (sym.undf() <span class="tok-kw">or</span> sym.tentative() <span class="tok-kw">or</span> sym.abs()) <span class="tok-kw">continue</span>;</span>
<span class="line" id="L1475">                <span class="tok-kw">const</span> sym_name = mem.sliceTo(strtab[sym.n_strx..], <span class="tok-number">0</span>);</span>
<span class="line" id="L1476">                <span class="tok-comment">// TODO is it possible to have a symbol collision?</span>
</span>
<span class="line" id="L1477">                addr_table.putAssumeCapacityNoClobber(sym_name, sym.n_value);</span>
<span class="line" id="L1478">            }</span>
<span class="line" id="L1479"></span>
<span class="line" id="L1480">            <span class="tok-kw">var</span> opt_debug_line: ?macho.section_64 = <span class="tok-null">null</span>;</span>
<span class="line" id="L1481">            <span class="tok-kw">var</span> opt_debug_info: ?macho.section_64 = <span class="tok-null">null</span>;</span>
<span class="line" id="L1482">            <span class="tok-kw">var</span> opt_debug_abbrev: ?macho.section_64 = <span class="tok-null">null</span>;</span>
<span class="line" id="L1483">            <span class="tok-kw">var</span> opt_debug_str: ?macho.section_64 = <span class="tok-null">null</span>;</span>
<span class="line" id="L1484">            <span class="tok-kw">var</span> opt_debug_line_str: ?macho.section_64 = <span class="tok-null">null</span>;</span>
<span class="line" id="L1485">            <span class="tok-kw">var</span> opt_debug_ranges: ?macho.section_64 = <span class="tok-null">null</span>;</span>
<span class="line" id="L1486"></span>
<span class="line" id="L1487">            <span class="tok-kw">for</span> (segcmd.?.getSections()) |sect| {</span>
<span class="line" id="L1488">                <span class="tok-kw">const</span> name = sect.sectName();</span>
<span class="line" id="L1489">                <span class="tok-kw">if</span> (mem.eql(<span class="tok-type">u8</span>, name, <span class="tok-str">&quot;__debug_line&quot;</span>)) {</span>
<span class="line" id="L1490">                    opt_debug_line = sect;</span>
<span class="line" id="L1491">                } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (mem.eql(<span class="tok-type">u8</span>, name, <span class="tok-str">&quot;__debug_info&quot;</span>)) {</span>
<span class="line" id="L1492">                    opt_debug_info = sect;</span>
<span class="line" id="L1493">                } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (mem.eql(<span class="tok-type">u8</span>, name, <span class="tok-str">&quot;__debug_abbrev&quot;</span>)) {</span>
<span class="line" id="L1494">                    opt_debug_abbrev = sect;</span>
<span class="line" id="L1495">                } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (mem.eql(<span class="tok-type">u8</span>, name, <span class="tok-str">&quot;__debug_str&quot;</span>)) {</span>
<span class="line" id="L1496">                    opt_debug_str = sect;</span>
<span class="line" id="L1497">                } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (mem.eql(<span class="tok-type">u8</span>, name, <span class="tok-str">&quot;__debug_line_str&quot;</span>)) {</span>
<span class="line" id="L1498">                    opt_debug_line_str = sect;</span>
<span class="line" id="L1499">                } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (mem.eql(<span class="tok-type">u8</span>, name, <span class="tok-str">&quot;__debug_ranges&quot;</span>)) {</span>
<span class="line" id="L1500">                    opt_debug_ranges = sect;</span>
<span class="line" id="L1501">                }</span>
<span class="line" id="L1502">            }</span>
<span class="line" id="L1503"></span>
<span class="line" id="L1504">            <span class="tok-kw">const</span> debug_line = opt_debug_line <span class="tok-kw">orelse</span></span>
<span class="line" id="L1505">                <span class="tok-kw">return</span> <span class="tok-kw">error</span>.MissingDebugInfo;</span>
<span class="line" id="L1506">            <span class="tok-kw">const</span> debug_info = opt_debug_info <span class="tok-kw">orelse</span></span>
<span class="line" id="L1507">                <span class="tok-kw">return</span> <span class="tok-kw">error</span>.MissingDebugInfo;</span>
<span class="line" id="L1508">            <span class="tok-kw">const</span> debug_str = opt_debug_str <span class="tok-kw">orelse</span></span>
<span class="line" id="L1509">                <span class="tok-kw">return</span> <span class="tok-kw">error</span>.MissingDebugInfo;</span>
<span class="line" id="L1510">            <span class="tok-kw">const</span> debug_abbrev = opt_debug_abbrev <span class="tok-kw">orelse</span></span>
<span class="line" id="L1511">                <span class="tok-kw">return</span> <span class="tok-kw">error</span>.MissingDebugInfo;</span>
<span class="line" id="L1512"></span>
<span class="line" id="L1513">            <span class="tok-kw">var</span> di = DW.DwarfInfo{</span>
<span class="line" id="L1514">                .endian = .Little,</span>
<span class="line" id="L1515">                .debug_info = <span class="tok-kw">try</span> chopSlice(mapped_mem, debug_info.offset, debug_info.size),</span>
<span class="line" id="L1516">                .debug_abbrev = <span class="tok-kw">try</span> chopSlice(mapped_mem, debug_abbrev.offset, debug_abbrev.size),</span>
<span class="line" id="L1517">                .debug_str = <span class="tok-kw">try</span> chopSlice(mapped_mem, debug_str.offset, debug_str.size),</span>
<span class="line" id="L1518">                .debug_line = <span class="tok-kw">try</span> chopSlice(mapped_mem, debug_line.offset, debug_line.size),</span>
<span class="line" id="L1519">                .debug_line_str = <span class="tok-kw">if</span> (opt_debug_line_str) |debug_line_str|</span>
<span class="line" id="L1520">                    <span class="tok-kw">try</span> chopSlice(mapped_mem, debug_line_str.offset, debug_line_str.size)</span>
<span class="line" id="L1521">                <span class="tok-kw">else</span></span>
<span class="line" id="L1522">                    <span class="tok-null">null</span>,</span>
<span class="line" id="L1523">                .debug_ranges = <span class="tok-kw">if</span> (opt_debug_ranges) |debug_ranges|</span>
<span class="line" id="L1524">                    <span class="tok-kw">try</span> chopSlice(mapped_mem, debug_ranges.offset, debug_ranges.size)</span>
<span class="line" id="L1525">                <span class="tok-kw">else</span></span>
<span class="line" id="L1526">                    <span class="tok-null">null</span>,</span>
<span class="line" id="L1527">            };</span>
<span class="line" id="L1528"></span>
<span class="line" id="L1529">            <span class="tok-kw">try</span> DW.openDwarfDebugInfo(&amp;di, allocator);</span>
<span class="line" id="L1530">            <span class="tok-kw">var</span> info = OFileInfo{</span>
<span class="line" id="L1531">                .di = di,</span>
<span class="line" id="L1532">                .addr_table = addr_table,</span>
<span class="line" id="L1533">            };</span>
<span class="line" id="L1534"></span>
<span class="line" id="L1535">            <span class="tok-comment">// Add the debug info to the cache</span>
</span>
<span class="line" id="L1536">            <span class="tok-kw">try</span> self.ofiles.putNoClobber(o_file_path, info);</span>
<span class="line" id="L1537"></span>
<span class="line" id="L1538">            <span class="tok-kw">return</span> info;</span>
<span class="line" id="L1539">        }</span>
<span class="line" id="L1540"></span>
<span class="line" id="L1541">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">getSymbolAtAddress</span>(self: *<span class="tok-builtin">@This</span>(), allocator: mem.Allocator, address: <span class="tok-type">usize</span>) !SymbolInfo {</span>
<span class="line" id="L1542">            <span class="tok-kw">nosuspend</span> {</span>
<span class="line" id="L1543">                <span class="tok-comment">// Translate the VA into an address into this object</span>
</span>
<span class="line" id="L1544">                <span class="tok-kw">const</span> relocated_address = address - self.base_address;</span>
<span class="line" id="L1545"></span>
<span class="line" id="L1546">                <span class="tok-comment">// Find the .o file where this symbol is defined</span>
</span>
<span class="line" id="L1547">                <span class="tok-kw">const</span> symbol = machoSearchSymbols(self.symbols, relocated_address) <span class="tok-kw">orelse</span></span>
<span class="line" id="L1548">                    <span class="tok-kw">return</span> SymbolInfo{};</span>
<span class="line" id="L1549">                <span class="tok-kw">const</span> addr_off = relocated_address - symbol.addr;</span>
<span class="line" id="L1550"></span>
<span class="line" id="L1551">                <span class="tok-comment">// Take the symbol name from the N_FUN STAB entry, we're going to</span>
</span>
<span class="line" id="L1552">                <span class="tok-comment">// use it if we fail to find the DWARF infos</span>
</span>
<span class="line" id="L1553">                <span class="tok-kw">const</span> stab_symbol = mem.sliceTo(self.strings[symbol.strx..], <span class="tok-number">0</span>);</span>
<span class="line" id="L1554">                <span class="tok-kw">const</span> o_file_path = mem.sliceTo(self.strings[symbol.ofile..], <span class="tok-number">0</span>);</span>
<span class="line" id="L1555"></span>
<span class="line" id="L1556">                <span class="tok-comment">// Check if its debug infos are already in the cache</span>
</span>
<span class="line" id="L1557">                <span class="tok-kw">var</span> o_file_info = self.ofiles.get(o_file_path) <span class="tok-kw">orelse</span></span>
<span class="line" id="L1558">                    (self.loadOFile(allocator, o_file_path) <span class="tok-kw">catch</span> |err| <span class="tok-kw">switch</span> (err) {</span>
<span class="line" id="L1559">                    <span class="tok-kw">error</span>.FileNotFound,</span>
<span class="line" id="L1560">                    <span class="tok-kw">error</span>.MissingDebugInfo,</span>
<span class="line" id="L1561">                    <span class="tok-kw">error</span>.InvalidDebugInfo,</span>
<span class="line" id="L1562">                    =&gt; {</span>
<span class="line" id="L1563">                        <span class="tok-kw">return</span> SymbolInfo{ .symbol_name = stab_symbol };</span>
<span class="line" id="L1564">                    },</span>
<span class="line" id="L1565">                    <span class="tok-kw">else</span> =&gt; <span class="tok-kw">return</span> err,</span>
<span class="line" id="L1566">                });</span>
<span class="line" id="L1567">                <span class="tok-kw">const</span> o_file_di = &amp;o_file_info.di;</span>
<span class="line" id="L1568"></span>
<span class="line" id="L1569">                <span class="tok-comment">// Translate again the address, this time into an address inside the</span>
</span>
<span class="line" id="L1570">                <span class="tok-comment">// .o file</span>
</span>
<span class="line" id="L1571">                <span class="tok-kw">const</span> relocated_address_o = o_file_info.addr_table.get(stab_symbol) <span class="tok-kw">orelse</span> <span class="tok-kw">return</span> SymbolInfo{</span>
<span class="line" id="L1572">                    .symbol_name = <span class="tok-str">&quot;???&quot;</span>,</span>
<span class="line" id="L1573">                };</span>
<span class="line" id="L1574"></span>
<span class="line" id="L1575">                <span class="tok-kw">if</span> (o_file_di.findCompileUnit(relocated_address_o)) |compile_unit| {</span>
<span class="line" id="L1576">                    <span class="tok-kw">return</span> SymbolInfo{</span>
<span class="line" id="L1577">                        .symbol_name = o_file_di.getSymbolName(relocated_address_o) <span class="tok-kw">orelse</span> <span class="tok-str">&quot;???&quot;</span>,</span>
<span class="line" id="L1578">                        .compile_unit_name = compile_unit.die.getAttrString(</span>
<span class="line" id="L1579">                            o_file_di,</span>
<span class="line" id="L1580">                            DW.AT.name,</span>
<span class="line" id="L1581">                        ) <span class="tok-kw">catch</span> |err| <span class="tok-kw">switch</span> (err) {</span>
<span class="line" id="L1582">                            <span class="tok-kw">error</span>.MissingDebugInfo, <span class="tok-kw">error</span>.InvalidDebugInfo =&gt; <span class="tok-str">&quot;???&quot;</span>,</span>
<span class="line" id="L1583">                        },</span>
<span class="line" id="L1584">                        .line_info = o_file_di.getLineNumberInfo(</span>
<span class="line" id="L1585">                            allocator,</span>
<span class="line" id="L1586">                            compile_unit.*,</span>
<span class="line" id="L1587">                            relocated_address_o + addr_off,</span>
<span class="line" id="L1588">                        ) <span class="tok-kw">catch</span> |err| <span class="tok-kw">switch</span> (err) {</span>
<span class="line" id="L1589">                            <span class="tok-kw">error</span>.MissingDebugInfo, <span class="tok-kw">error</span>.InvalidDebugInfo =&gt; <span class="tok-null">null</span>,</span>
<span class="line" id="L1590">                            <span class="tok-kw">else</span> =&gt; <span class="tok-kw">return</span> err,</span>
<span class="line" id="L1591">                        },</span>
<span class="line" id="L1592">                    };</span>
<span class="line" id="L1593">                } <span class="tok-kw">else</span> |err| <span class="tok-kw">switch</span> (err) {</span>
<span class="line" id="L1594">                    <span class="tok-kw">error</span>.MissingDebugInfo, <span class="tok-kw">error</span>.InvalidDebugInfo =&gt; {</span>
<span class="line" id="L1595">                        <span class="tok-kw">return</span> SymbolInfo{ .symbol_name = stab_symbol };</span>
<span class="line" id="L1596">                    },</span>
<span class="line" id="L1597">                    <span class="tok-kw">else</span> =&gt; <span class="tok-kw">return</span> err,</span>
<span class="line" id="L1598">                }</span>
<span class="line" id="L1599"></span>
<span class="line" id="L1600">                <span class="tok-kw">unreachable</span>;</span>
<span class="line" id="L1601">            }</span>
<span class="line" id="L1602">        }</span>
<span class="line" id="L1603">    },</span>
<span class="line" id="L1604">    .uefi, .windows =&gt; <span class="tok-kw">struct</span> {</span>
<span class="line" id="L1605">        base_address: <span class="tok-type">usize</span>,</span>
<span class="line" id="L1606">        debug_data: PdbOrDwarf,</span>
<span class="line" id="L1607">        coff: *coff.Coff,</span>
<span class="line" id="L1608"></span>
<span class="line" id="L1609">        <span class="tok-kw">fn</span> <span class="tok-fn">deinit</span>(self: *<span class="tok-builtin">@This</span>(), allocator: mem.Allocator) <span class="tok-type">void</span> {</span>
<span class="line" id="L1610">            self.debug_data.deinit(allocator);</span>
<span class="line" id="L1611">            self.coff.deinit();</span>
<span class="line" id="L1612">            allocator.destroy(self.coff);</span>
<span class="line" id="L1613">        }</span>
<span class="line" id="L1614"></span>
<span class="line" id="L1615">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">getSymbolAtAddress</span>(self: *<span class="tok-builtin">@This</span>(), allocator: mem.Allocator, address: <span class="tok-type">usize</span>) !SymbolInfo {</span>
<span class="line" id="L1616">            <span class="tok-comment">// Translate the VA into an address into this object</span>
</span>
<span class="line" id="L1617">            <span class="tok-kw">const</span> relocated_address = address - self.base_address;</span>
<span class="line" id="L1618"></span>
<span class="line" id="L1619">            <span class="tok-kw">switch</span> (self.debug_data) {</span>
<span class="line" id="L1620">                .dwarf =&gt; |*dwarf| {</span>
<span class="line" id="L1621">                    <span class="tok-kw">const</span> dwarf_address = relocated_address + self.coff.pe_header.image_base;</span>
<span class="line" id="L1622">                    <span class="tok-kw">return</span> getSymbolFromDwarf(allocator, dwarf_address, dwarf);</span>
<span class="line" id="L1623">                },</span>
<span class="line" id="L1624">                .pdb =&gt; {</span>
<span class="line" id="L1625">                    <span class="tok-comment">// fallthrough to pdb handling</span>
</span>
<span class="line" id="L1626">                },</span>
<span class="line" id="L1627">            }</span>
<span class="line" id="L1628"></span>
<span class="line" id="L1629">            <span class="tok-kw">var</span> coff_section: *coff.Section = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L1630">            <span class="tok-kw">const</span> mod_index = <span class="tok-kw">for</span> (self.debug_data.pdb.sect_contribs) |sect_contrib| {</span>
<span class="line" id="L1631">                <span class="tok-kw">if</span> (sect_contrib.Section &gt; self.coff.sections.items.len) <span class="tok-kw">continue</span>;</span>
<span class="line" id="L1632">                <span class="tok-comment">// Remember that SectionContribEntry.Section is 1-based.</span>
</span>
<span class="line" id="L1633">                coff_section = &amp;self.coff.sections.items[sect_contrib.Section - <span class="tok-number">1</span>];</span>
<span class="line" id="L1634"></span>
<span class="line" id="L1635">                <span class="tok-kw">const</span> vaddr_start = coff_section.header.virtual_address + sect_contrib.Offset;</span>
<span class="line" id="L1636">                <span class="tok-kw">const</span> vaddr_end = vaddr_start + sect_contrib.Size;</span>
<span class="line" id="L1637">                <span class="tok-kw">if</span> (relocated_address &gt;= vaddr_start <span class="tok-kw">and</span> relocated_address &lt; vaddr_end) {</span>
<span class="line" id="L1638">                    <span class="tok-kw">break</span> sect_contrib.ModuleIndex;</span>
<span class="line" id="L1639">                }</span>
<span class="line" id="L1640">            } <span class="tok-kw">else</span> {</span>
<span class="line" id="L1641">                <span class="tok-comment">// we have no information to add to the address</span>
</span>
<span class="line" id="L1642">                <span class="tok-kw">return</span> SymbolInfo{};</span>
<span class="line" id="L1643">            };</span>
<span class="line" id="L1644"></span>
<span class="line" id="L1645">            <span class="tok-kw">const</span> module = (<span class="tok-kw">try</span> self.debug_data.pdb.getModule(mod_index)) <span class="tok-kw">orelse</span></span>
<span class="line" id="L1646">                <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InvalidDebugInfo;</span>
<span class="line" id="L1647">            <span class="tok-kw">const</span> obj_basename = fs.path.basename(module.obj_file_name);</span>
<span class="line" id="L1648"></span>
<span class="line" id="L1649">            <span class="tok-kw">const</span> symbol_name = self.debug_data.pdb.getSymbolName(</span>
<span class="line" id="L1650">                module,</span>
<span class="line" id="L1651">                relocated_address - coff_section.header.virtual_address,</span>
<span class="line" id="L1652">            ) <span class="tok-kw">orelse</span> <span class="tok-str">&quot;???&quot;</span>;</span>
<span class="line" id="L1653">            <span class="tok-kw">const</span> opt_line_info = <span class="tok-kw">try</span> self.debug_data.pdb.getLineNumberInfo(</span>
<span class="line" id="L1654">                module,</span>
<span class="line" id="L1655">                relocated_address - coff_section.header.virtual_address,</span>
<span class="line" id="L1656">            );</span>
<span class="line" id="L1657"></span>
<span class="line" id="L1658">            <span class="tok-kw">return</span> SymbolInfo{</span>
<span class="line" id="L1659">                .symbol_name = symbol_name,</span>
<span class="line" id="L1660">                .compile_unit_name = obj_basename,</span>
<span class="line" id="L1661">                .line_info = opt_line_info,</span>
<span class="line" id="L1662">            };</span>
<span class="line" id="L1663">        }</span>
<span class="line" id="L1664">    },</span>
<span class="line" id="L1665">    .linux, .netbsd, .freebsd, .dragonfly, .openbsd, .haiku, .solaris =&gt; <span class="tok-kw">struct</span> {</span>
<span class="line" id="L1666">        base_address: <span class="tok-type">usize</span>,</span>
<span class="line" id="L1667">        dwarf: DW.DwarfInfo,</span>
<span class="line" id="L1668">        mapped_memory: []<span class="tok-kw">align</span>(mem.page_size) <span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L1669"></span>
<span class="line" id="L1670">        <span class="tok-kw">fn</span> <span class="tok-fn">deinit</span>(self: *<span class="tok-builtin">@This</span>(), allocator: mem.Allocator) <span class="tok-type">void</span> {</span>
<span class="line" id="L1671">            self.dwarf.deinit(allocator);</span>
<span class="line" id="L1672">            os.munmap(self.mapped_memory);</span>
<span class="line" id="L1673">        }</span>
<span class="line" id="L1674"></span>
<span class="line" id="L1675">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">getSymbolAtAddress</span>(self: *<span class="tok-builtin">@This</span>(), allocator: mem.Allocator, address: <span class="tok-type">usize</span>) !SymbolInfo {</span>
<span class="line" id="L1676">            <span class="tok-comment">// Translate the VA into an address into this object</span>
</span>
<span class="line" id="L1677">            <span class="tok-kw">const</span> relocated_address = address - self.base_address;</span>
<span class="line" id="L1678">            <span class="tok-kw">return</span> getSymbolFromDwarf(allocator, relocated_address, &amp;self.dwarf);</span>
<span class="line" id="L1679">        }</span>
<span class="line" id="L1680">    },</span>
<span class="line" id="L1681">    .wasi =&gt; <span class="tok-kw">struct</span> {</span>
<span class="line" id="L1682">        <span class="tok-kw">fn</span> <span class="tok-fn">deinit</span>(self: *<span class="tok-builtin">@This</span>(), allocator: mem.Allocator) <span class="tok-type">void</span> {</span>
<span class="line" id="L1683">            _ = self;</span>
<span class="line" id="L1684">            _ = allocator;</span>
<span class="line" id="L1685">        }</span>
<span class="line" id="L1686"></span>
<span class="line" id="L1687">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">getSymbolAtAddress</span>(self: *<span class="tok-builtin">@This</span>(), allocator: mem.Allocator, address: <span class="tok-type">usize</span>) !SymbolInfo {</span>
<span class="line" id="L1688">            _ = self;</span>
<span class="line" id="L1689">            _ = allocator;</span>
<span class="line" id="L1690">            _ = address;</span>
<span class="line" id="L1691">            <span class="tok-kw">return</span> SymbolInfo{};</span>
<span class="line" id="L1692">        }</span>
<span class="line" id="L1693">    },</span>
<span class="line" id="L1694">    <span class="tok-kw">else</span> =&gt; DW.DwarfInfo,</span>
<span class="line" id="L1695">};</span>
<span class="line" id="L1696"></span>
<span class="line" id="L1697"><span class="tok-kw">fn</span> <span class="tok-fn">getSymbolFromDwarf</span>(allocator: mem.Allocator, address: <span class="tok-type">u64</span>, di: *DW.DwarfInfo) !SymbolInfo {</span>
<span class="line" id="L1698">    <span class="tok-kw">if</span> (<span class="tok-kw">nosuspend</span> di.findCompileUnit(address)) |compile_unit| {</span>
<span class="line" id="L1699">        <span class="tok-kw">return</span> SymbolInfo{</span>
<span class="line" id="L1700">            .symbol_name = <span class="tok-kw">nosuspend</span> di.getSymbolName(address) <span class="tok-kw">orelse</span> <span class="tok-str">&quot;???&quot;</span>,</span>
<span class="line" id="L1701">            .compile_unit_name = compile_unit.die.getAttrString(di, DW.AT.name) <span class="tok-kw">catch</span> |err| <span class="tok-kw">switch</span> (err) {</span>
<span class="line" id="L1702">                <span class="tok-kw">error</span>.MissingDebugInfo, <span class="tok-kw">error</span>.InvalidDebugInfo =&gt; <span class="tok-str">&quot;???&quot;</span>,</span>
<span class="line" id="L1703">            },</span>
<span class="line" id="L1704">            .line_info = <span class="tok-kw">nosuspend</span> di.getLineNumberInfo(allocator, compile_unit.*, address) <span class="tok-kw">catch</span> |err| <span class="tok-kw">switch</span> (err) {</span>
<span class="line" id="L1705">                <span class="tok-kw">error</span>.MissingDebugInfo, <span class="tok-kw">error</span>.InvalidDebugInfo =&gt; <span class="tok-null">null</span>,</span>
<span class="line" id="L1706">                <span class="tok-kw">else</span> =&gt; <span class="tok-kw">return</span> err,</span>
<span class="line" id="L1707">            },</span>
<span class="line" id="L1708">        };</span>
<span class="line" id="L1709">    } <span class="tok-kw">else</span> |err| <span class="tok-kw">switch</span> (err) {</span>
<span class="line" id="L1710">        <span class="tok-kw">error</span>.MissingDebugInfo, <span class="tok-kw">error</span>.InvalidDebugInfo =&gt; {</span>
<span class="line" id="L1711">            <span class="tok-kw">return</span> SymbolInfo{};</span>
<span class="line" id="L1712">        },</span>
<span class="line" id="L1713">        <span class="tok-kw">else</span> =&gt; <span class="tok-kw">return</span> err,</span>
<span class="line" id="L1714">    }</span>
<span class="line" id="L1715">}</span>
<span class="line" id="L1716"></span>
<span class="line" id="L1717"><span class="tok-comment">/// TODO multithreaded awareness</span></span>
<span class="line" id="L1718"><span class="tok-kw">var</span> debug_info_allocator: ?mem.Allocator = <span class="tok-null">null</span>;</span>
<span class="line" id="L1719"><span class="tok-kw">var</span> debug_info_arena_allocator: std.heap.ArenaAllocator = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L1720"><span class="tok-kw">fn</span> <span class="tok-fn">getDebugInfoAllocator</span>() mem.Allocator {</span>
<span class="line" id="L1721">    <span class="tok-kw">if</span> (debug_info_allocator) |a| <span class="tok-kw">return</span> a;</span>
<span class="line" id="L1722"></span>
<span class="line" id="L1723">    debug_info_arena_allocator = std.heap.ArenaAllocator.init(std.heap.page_allocator);</span>
<span class="line" id="L1724">    <span class="tok-kw">const</span> allocator = debug_info_arena_allocator.allocator();</span>
<span class="line" id="L1725">    debug_info_allocator = allocator;</span>
<span class="line" id="L1726">    <span class="tok-kw">return</span> allocator;</span>
<span class="line" id="L1727">}</span>
<span class="line" id="L1728"></span>
<span class="line" id="L1729"><span class="tok-comment">/// Whether or not the current target can print useful debug information when a segfault occurs.</span></span>
<span class="line" id="L1730"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> have_segfault_handling_support = <span class="tok-kw">switch</span> (native_os) {</span>
<span class="line" id="L1731">    .linux,</span>
<span class="line" id="L1732">    .macos,</span>
<span class="line" id="L1733">    .netbsd,</span>
<span class="line" id="L1734">    .solaris,</span>
<span class="line" id="L1735">    .windows,</span>
<span class="line" id="L1736">    =&gt; <span class="tok-null">true</span>,</span>
<span class="line" id="L1737"></span>
<span class="line" id="L1738">    .freebsd, .openbsd =&gt; <span class="tok-builtin">@hasDecl</span>(os.system, <span class="tok-str">&quot;ucontext_t&quot;</span>),</span>
<span class="line" id="L1739">    <span class="tok-kw">else</span> =&gt; <span class="tok-null">false</span>,</span>
<span class="line" id="L1740">};</span>
<span class="line" id="L1741"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> enable_segfault_handler: <span class="tok-type">bool</span> = <span class="tok-kw">if</span> (<span class="tok-builtin">@hasDecl</span>(root, <span class="tok-str">&quot;enable_segfault_handler&quot;</span>))</span>
<span class="line" id="L1742">    root.enable_segfault_handler</span>
<span class="line" id="L1743"><span class="tok-kw">else</span></span>
<span class="line" id="L1744">    runtime_safety <span class="tok-kw">and</span> have_segfault_handling_support;</span>
<span class="line" id="L1745"></span>
<span class="line" id="L1746"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">maybeEnableSegfaultHandler</span>() <span class="tok-type">void</span> {</span>
<span class="line" id="L1747">    <span class="tok-kw">if</span> (enable_segfault_handler) {</span>
<span class="line" id="L1748">        std.debug.attachSegfaultHandler();</span>
<span class="line" id="L1749">    }</span>
<span class="line" id="L1750">}</span>
<span class="line" id="L1751"></span>
<span class="line" id="L1752"><span class="tok-kw">var</span> windows_segfault_handle: ?windows.HANDLE = <span class="tok-null">null</span>;</span>
<span class="line" id="L1753"></span>
<span class="line" id="L1754"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">updateSegfaultHandler</span>(act: ?*<span class="tok-kw">const</span> os.Sigaction) <span class="tok-kw">error</span>{OperationNotSupported}!<span class="tok-type">void</span> {</span>
<span class="line" id="L1755">    <span class="tok-kw">try</span> os.sigaction(os.SIG.SEGV, act, <span class="tok-null">null</span>);</span>
<span class="line" id="L1756">    <span class="tok-kw">try</span> os.sigaction(os.SIG.ILL, act, <span class="tok-null">null</span>);</span>
<span class="line" id="L1757">    <span class="tok-kw">try</span> os.sigaction(os.SIG.BUS, act, <span class="tok-null">null</span>);</span>
<span class="line" id="L1758">    <span class="tok-kw">try</span> os.sigaction(os.SIG.FPE, act, <span class="tok-null">null</span>);</span>
<span class="line" id="L1759">}</span>
<span class="line" id="L1760"></span>
<span class="line" id="L1761"><span class="tok-comment">/// Attaches a global SIGSEGV handler which calls @panic(&quot;segmentation fault&quot;);</span></span>
<span class="line" id="L1762"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">attachSegfaultHandler</span>() <span class="tok-type">void</span> {</span>
<span class="line" id="L1763">    <span class="tok-kw">if</span> (!have_segfault_handling_support) {</span>
<span class="line" id="L1764">        <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;segfault handler not supported for this target&quot;</span>);</span>
<span class="line" id="L1765">    }</span>
<span class="line" id="L1766">    <span class="tok-kw">if</span> (native_os == .windows) {</span>
<span class="line" id="L1767">        windows_segfault_handle = windows.kernel32.AddVectoredExceptionHandler(<span class="tok-number">0</span>, handleSegfaultWindows);</span>
<span class="line" id="L1768">        <span class="tok-kw">return</span>;</span>
<span class="line" id="L1769">    }</span>
<span class="line" id="L1770">    <span class="tok-kw">var</span> act = os.Sigaction{</span>
<span class="line" id="L1771">        .handler = .{ .sigaction = handleSegfaultPosix },</span>
<span class="line" id="L1772">        .mask = os.empty_sigset,</span>
<span class="line" id="L1773">        .flags = (os.SA.SIGINFO | os.SA.RESTART | os.SA.RESETHAND),</span>
<span class="line" id="L1774">    };</span>
<span class="line" id="L1775"></span>
<span class="line" id="L1776">    updateSegfaultHandler(&amp;act) <span class="tok-kw">catch</span> {</span>
<span class="line" id="L1777">        <span class="tok-builtin">@panic</span>(<span class="tok-str">&quot;unable to install segfault handler, maybe adjust have_segfault_handling_support in std/debug.zig&quot;</span>);</span>
<span class="line" id="L1778">    };</span>
<span class="line" id="L1779">}</span>
<span class="line" id="L1780"></span>
<span class="line" id="L1781"><span class="tok-kw">fn</span> <span class="tok-fn">resetSegfaultHandler</span>() <span class="tok-type">void</span> {</span>
<span class="line" id="L1782">    <span class="tok-kw">if</span> (native_os == .windows) {</span>
<span class="line" id="L1783">        <span class="tok-kw">if</span> (windows_segfault_handle) |handle| {</span>
<span class="line" id="L1784">            assert(windows.kernel32.RemoveVectoredExceptionHandler(handle) != <span class="tok-number">0</span>);</span>
<span class="line" id="L1785">            windows_segfault_handle = <span class="tok-null">null</span>;</span>
<span class="line" id="L1786">        }</span>
<span class="line" id="L1787">        <span class="tok-kw">return</span>;</span>
<span class="line" id="L1788">    }</span>
<span class="line" id="L1789">    <span class="tok-kw">var</span> act = os.Sigaction{</span>
<span class="line" id="L1790">        .handler = .{ .handler = os.SIG.DFL },</span>
<span class="line" id="L1791">        .mask = os.empty_sigset,</span>
<span class="line" id="L1792">        .flags = <span class="tok-number">0</span>,</span>
<span class="line" id="L1793">    };</span>
<span class="line" id="L1794">    <span class="tok-comment">// To avoid a double-panic, do nothing if an error happens here.</span>
</span>
<span class="line" id="L1795">    updateSegfaultHandler(&amp;act) <span class="tok-kw">catch</span> {};</span>
<span class="line" id="L1796">}</span>
<span class="line" id="L1797"></span>
<span class="line" id="L1798"><span class="tok-kw">fn</span> <span class="tok-fn">handleSegfaultPosix</span>(sig: <span class="tok-type">i32</span>, info: *<span class="tok-kw">const</span> os.siginfo_t, ctx_ptr: ?*<span class="tok-kw">const</span> <span class="tok-type">anyopaque</span>) <span class="tok-kw">callconv</span>(.C) <span class="tok-type">noreturn</span> {</span>
<span class="line" id="L1799">    <span class="tok-comment">// Reset to the default handler so that if a segfault happens in this handler it will crash</span>
</span>
<span class="line" id="L1800">    <span class="tok-comment">// the process. Also when this handler returns, the original instruction will be repeated</span>
</span>
<span class="line" id="L1801">    <span class="tok-comment">// and the resulting segfault will crash the process rather than continually dump stack traces.</span>
</span>
<span class="line" id="L1802">    resetSegfaultHandler();</span>
<span class="line" id="L1803"></span>
<span class="line" id="L1804">    <span class="tok-kw">const</span> addr = <span class="tok-kw">switch</span> (native_os) {</span>
<span class="line" id="L1805">        .linux =&gt; <span class="tok-builtin">@ptrToInt</span>(info.fields.sigfault.addr),</span>
<span class="line" id="L1806">        .freebsd, .macos =&gt; <span class="tok-builtin">@ptrToInt</span>(info.addr),</span>
<span class="line" id="L1807">        .netbsd =&gt; <span class="tok-builtin">@ptrToInt</span>(info.info.reason.fault.addr),</span>
<span class="line" id="L1808">        .openbsd =&gt; <span class="tok-builtin">@ptrToInt</span>(info.data.fault.addr),</span>
<span class="line" id="L1809">        .solaris =&gt; <span class="tok-builtin">@ptrToInt</span>(info.reason.fault.addr),</span>
<span class="line" id="L1810">        <span class="tok-kw">else</span> =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L1811">    };</span>
<span class="line" id="L1812"></span>
<span class="line" id="L1813">    <span class="tok-comment">// Don't use std.debug.print() as stderr_mutex may still be locked.</span>
</span>
<span class="line" id="L1814">    <span class="tok-kw">nosuspend</span> {</span>
<span class="line" id="L1815">        <span class="tok-kw">const</span> stderr = io.getStdErr().writer();</span>
<span class="line" id="L1816">        _ = <span class="tok-kw">switch</span> (sig) {</span>
<span class="line" id="L1817">            os.SIG.SEGV =&gt; stderr.print(<span class="tok-str">&quot;Segmentation fault at address 0x{x}\n&quot;</span>, .{addr}),</span>
<span class="line" id="L1818">            os.SIG.ILL =&gt; stderr.print(<span class="tok-str">&quot;Illegal instruction at address 0x{x}\n&quot;</span>, .{addr}),</span>
<span class="line" id="L1819">            os.SIG.BUS =&gt; stderr.print(<span class="tok-str">&quot;Bus error at address 0x{x}\n&quot;</span>, .{addr}),</span>
<span class="line" id="L1820">            os.SIG.FPE =&gt; stderr.print(<span class="tok-str">&quot;Arithmetic exception at address 0x{x}\n&quot;</span>, .{addr}),</span>
<span class="line" id="L1821">            <span class="tok-kw">else</span> =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L1822">        } <span class="tok-kw">catch</span> os.abort();</span>
<span class="line" id="L1823">    }</span>
<span class="line" id="L1824"></span>
<span class="line" id="L1825">    <span class="tok-kw">switch</span> (native_arch) {</span>
<span class="line" id="L1826">        .<span class="tok-type">i386</span> =&gt; {</span>
<span class="line" id="L1827">            <span class="tok-kw">const</span> ctx = <span class="tok-builtin">@ptrCast</span>(*<span class="tok-kw">const</span> os.ucontext_t, <span class="tok-builtin">@alignCast</span>(<span class="tok-builtin">@alignOf</span>(os.ucontext_t), ctx_ptr));</span>
<span class="line" id="L1828">            <span class="tok-kw">const</span> ip = <span class="tok-builtin">@intCast</span>(<span class="tok-type">usize</span>, ctx.mcontext.gregs[os.REG.EIP]);</span>
<span class="line" id="L1829">            <span class="tok-kw">const</span> bp = <span class="tok-builtin">@intCast</span>(<span class="tok-type">usize</span>, ctx.mcontext.gregs[os.REG.EBP]);</span>
<span class="line" id="L1830">            dumpStackTraceFromBase(bp, ip);</span>
<span class="line" id="L1831">        },</span>
<span class="line" id="L1832">        .x86_64 =&gt; {</span>
<span class="line" id="L1833">            <span class="tok-kw">const</span> ctx = <span class="tok-builtin">@ptrCast</span>(*<span class="tok-kw">const</span> os.ucontext_t, <span class="tok-builtin">@alignCast</span>(<span class="tok-builtin">@alignOf</span>(os.ucontext_t), ctx_ptr));</span>
<span class="line" id="L1834">            <span class="tok-kw">const</span> ip = <span class="tok-kw">switch</span> (native_os) {</span>
<span class="line" id="L1835">                .linux, .netbsd, .solaris =&gt; <span class="tok-builtin">@intCast</span>(<span class="tok-type">usize</span>, ctx.mcontext.gregs[os.REG.RIP]),</span>
<span class="line" id="L1836">                .freebsd =&gt; <span class="tok-builtin">@intCast</span>(<span class="tok-type">usize</span>, ctx.mcontext.rip),</span>
<span class="line" id="L1837">                .openbsd =&gt; <span class="tok-builtin">@intCast</span>(<span class="tok-type">usize</span>, ctx.sc_rip),</span>
<span class="line" id="L1838">                .macos =&gt; <span class="tok-builtin">@intCast</span>(<span class="tok-type">usize</span>, ctx.mcontext.ss.rip),</span>
<span class="line" id="L1839">                <span class="tok-kw">else</span> =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L1840">            };</span>
<span class="line" id="L1841">            <span class="tok-kw">const</span> bp = <span class="tok-kw">switch</span> (native_os) {</span>
<span class="line" id="L1842">                .linux, .netbsd, .solaris =&gt; <span class="tok-builtin">@intCast</span>(<span class="tok-type">usize</span>, ctx.mcontext.gregs[os.REG.RBP]),</span>
<span class="line" id="L1843">                .openbsd =&gt; <span class="tok-builtin">@intCast</span>(<span class="tok-type">usize</span>, ctx.sc_rbp),</span>
<span class="line" id="L1844">                .freebsd =&gt; <span class="tok-builtin">@intCast</span>(<span class="tok-type">usize</span>, ctx.mcontext.rbp),</span>
<span class="line" id="L1845">                .macos =&gt; <span class="tok-builtin">@intCast</span>(<span class="tok-type">usize</span>, ctx.mcontext.ss.rbp),</span>
<span class="line" id="L1846">                <span class="tok-kw">else</span> =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L1847">            };</span>
<span class="line" id="L1848">            dumpStackTraceFromBase(bp, ip);</span>
<span class="line" id="L1849">        },</span>
<span class="line" id="L1850">        .arm =&gt; {</span>
<span class="line" id="L1851">            <span class="tok-kw">const</span> ctx = <span class="tok-builtin">@ptrCast</span>(*<span class="tok-kw">const</span> os.ucontext_t, <span class="tok-builtin">@alignCast</span>(<span class="tok-builtin">@alignOf</span>(os.ucontext_t), ctx_ptr));</span>
<span class="line" id="L1852">            <span class="tok-kw">const</span> ip = <span class="tok-builtin">@intCast</span>(<span class="tok-type">usize</span>, ctx.mcontext.arm_pc);</span>
<span class="line" id="L1853">            <span class="tok-kw">const</span> bp = <span class="tok-builtin">@intCast</span>(<span class="tok-type">usize</span>, ctx.mcontext.arm_fp);</span>
<span class="line" id="L1854">            dumpStackTraceFromBase(bp, ip);</span>
<span class="line" id="L1855">        },</span>
<span class="line" id="L1856">        .aarch64 =&gt; {</span>
<span class="line" id="L1857">            <span class="tok-kw">const</span> ctx = <span class="tok-builtin">@ptrCast</span>(*<span class="tok-kw">const</span> os.ucontext_t, <span class="tok-builtin">@alignCast</span>(<span class="tok-builtin">@alignOf</span>(os.ucontext_t), ctx_ptr));</span>
<span class="line" id="L1858">            <span class="tok-kw">const</span> ip = <span class="tok-kw">switch</span> (native_os) {</span>
<span class="line" id="L1859">                .macos =&gt; <span class="tok-builtin">@intCast</span>(<span class="tok-type">usize</span>, ctx.mcontext.ss.pc),</span>
<span class="line" id="L1860">                <span class="tok-kw">else</span> =&gt; <span class="tok-builtin">@intCast</span>(<span class="tok-type">usize</span>, ctx.mcontext.pc),</span>
<span class="line" id="L1861">            };</span>
<span class="line" id="L1862">            <span class="tok-comment">// x29 is the ABI-designated frame pointer</span>
</span>
<span class="line" id="L1863">            <span class="tok-kw">const</span> bp = <span class="tok-kw">switch</span> (native_os) {</span>
<span class="line" id="L1864">                .macos =&gt; <span class="tok-builtin">@intCast</span>(<span class="tok-type">usize</span>, ctx.mcontext.ss.fp),</span>
<span class="line" id="L1865">                <span class="tok-kw">else</span> =&gt; <span class="tok-builtin">@intCast</span>(<span class="tok-type">usize</span>, ctx.mcontext.regs[<span class="tok-number">29</span>]),</span>
<span class="line" id="L1866">            };</span>
<span class="line" id="L1867">            dumpStackTraceFromBase(bp, ip);</span>
<span class="line" id="L1868">        },</span>
<span class="line" id="L1869">        <span class="tok-kw">else</span> =&gt; {},</span>
<span class="line" id="L1870">    }</span>
<span class="line" id="L1871"></span>
<span class="line" id="L1872">    <span class="tok-comment">// We cannot allow the signal handler to return because when it runs the original instruction</span>
</span>
<span class="line" id="L1873">    <span class="tok-comment">// again, the memory may be mapped and undefined behavior would occur rather than repeating</span>
</span>
<span class="line" id="L1874">    <span class="tok-comment">// the segfault. So we simply abort here.</span>
</span>
<span class="line" id="L1875">    os.abort();</span>
<span class="line" id="L1876">}</span>
<span class="line" id="L1877"></span>
<span class="line" id="L1878"><span class="tok-kw">fn</span> <span class="tok-fn">handleSegfaultWindows</span>(info: *windows.EXCEPTION_POINTERS) <span class="tok-kw">callconv</span>(windows.WINAPI) <span class="tok-type">c_long</span> {</span>
<span class="line" id="L1879">    <span class="tok-kw">switch</span> (info.ExceptionRecord.ExceptionCode) {</span>
<span class="line" id="L1880">        windows.EXCEPTION_DATATYPE_MISALIGNMENT =&gt; handleSegfaultWindowsExtra(info, <span class="tok-number">0</span>, <span class="tok-str">&quot;Unaligned Memory Access&quot;</span>),</span>
<span class="line" id="L1881">        windows.EXCEPTION_ACCESS_VIOLATION =&gt; handleSegfaultWindowsExtra(info, <span class="tok-number">1</span>, <span class="tok-null">null</span>),</span>
<span class="line" id="L1882">        windows.EXCEPTION_ILLEGAL_INSTRUCTION =&gt; handleSegfaultWindowsExtra(info, <span class="tok-number">2</span>, <span class="tok-null">null</span>),</span>
<span class="line" id="L1883">        windows.EXCEPTION_STACK_OVERFLOW =&gt; handleSegfaultWindowsExtra(info, <span class="tok-number">0</span>, <span class="tok-str">&quot;Stack Overflow&quot;</span>),</span>
<span class="line" id="L1884">        <span class="tok-kw">else</span> =&gt; <span class="tok-kw">return</span> windows.EXCEPTION_CONTINUE_SEARCH,</span>
<span class="line" id="L1885">    }</span>
<span class="line" id="L1886">}</span>
<span class="line" id="L1887"></span>
<span class="line" id="L1888"><span class="tok-comment">// zig won't let me use an anon enum here https://github.com/ziglang/zig/issues/3707</span>
</span>
<span class="line" id="L1889"><span class="tok-kw">fn</span> <span class="tok-fn">handleSegfaultWindowsExtra</span>(info: *windows.EXCEPTION_POINTERS, <span class="tok-kw">comptime</span> msg: <span class="tok-type">u8</span>, <span class="tok-kw">comptime</span> format: ?[]<span class="tok-kw">const</span> <span class="tok-type">u8</span>) <span class="tok-type">noreturn</span> {</span>
<span class="line" id="L1890">    <span class="tok-kw">const</span> exception_address = <span class="tok-builtin">@ptrToInt</span>(info.ExceptionRecord.ExceptionAddress);</span>
<span class="line" id="L1891">    <span class="tok-kw">if</span> (<span class="tok-builtin">@hasDecl</span>(windows, <span class="tok-str">&quot;CONTEXT&quot;</span>)) {</span>
<span class="line" id="L1892">        <span class="tok-kw">const</span> regs = info.ContextRecord.getRegs();</span>
<span class="line" id="L1893">        <span class="tok-comment">// Don't use std.debug.print() as stderr_mutex may still be locked.</span>
</span>
<span class="line" id="L1894">        <span class="tok-kw">nosuspend</span> {</span>
<span class="line" id="L1895">            <span class="tok-kw">const</span> stderr = io.getStdErr().writer();</span>
<span class="line" id="L1896">            _ = <span class="tok-kw">switch</span> (msg) {</span>
<span class="line" id="L1897">                <span class="tok-number">0</span> =&gt; stderr.print(<span class="tok-str">&quot;{s}\n&quot;</span>, .{format.?}),</span>
<span class="line" id="L1898">                <span class="tok-number">1</span> =&gt; stderr.print(<span class="tok-str">&quot;Segmentation fault at address 0x{x}\n&quot;</span>, .{info.ExceptionRecord.ExceptionInformation[<span class="tok-number">1</span>]}),</span>
<span class="line" id="L1899">                <span class="tok-number">2</span> =&gt; stderr.print(<span class="tok-str">&quot;Illegal instruction at address 0x{x}\n&quot;</span>, .{regs.ip}),</span>
<span class="line" id="L1900">                <span class="tok-kw">else</span> =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L1901">            } <span class="tok-kw">catch</span> os.abort();</span>
<span class="line" id="L1902">        }</span>
<span class="line" id="L1903"></span>
<span class="line" id="L1904">        dumpStackTraceFromBase(regs.bp, regs.ip);</span>
<span class="line" id="L1905">        os.abort();</span>
<span class="line" id="L1906">    } <span class="tok-kw">else</span> {</span>
<span class="line" id="L1907">        <span class="tok-kw">switch</span> (msg) {</span>
<span class="line" id="L1908">            <span class="tok-number">0</span> =&gt; panicImpl(<span class="tok-null">null</span>, exception_address, format.?),</span>
<span class="line" id="L1909">            <span class="tok-number">1</span> =&gt; {</span>
<span class="line" id="L1910">                <span class="tok-kw">const</span> format_item = <span class="tok-str">&quot;Segmentation fault at address 0x{x}&quot;</span>;</span>
<span class="line" id="L1911">                <span class="tok-kw">var</span> buf: [format_item.len + <span class="tok-number">64</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>; <span class="tok-comment">// 64 is arbitrary, but sufficiently large</span>
</span>
<span class="line" id="L1912">                <span class="tok-kw">const</span> to_print = std.fmt.bufPrint(buf[<span class="tok-number">0</span>..buf.len], format_item, .{info.ExceptionRecord.ExceptionInformation[<span class="tok-number">1</span>]}) <span class="tok-kw">catch</span> <span class="tok-kw">unreachable</span>;</span>
<span class="line" id="L1913">                panicImpl(<span class="tok-null">null</span>, exception_address, to_print);</span>
<span class="line" id="L1914">            },</span>
<span class="line" id="L1915">            <span class="tok-number">2</span> =&gt; panicImpl(<span class="tok-null">null</span>, exception_address, <span class="tok-str">&quot;Illegal Instruction&quot;</span>),</span>
<span class="line" id="L1916">            <span class="tok-kw">else</span> =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L1917">        }</span>
<span class="line" id="L1918">    }</span>
<span class="line" id="L1919">}</span>
<span class="line" id="L1920"></span>
<span class="line" id="L1921"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">dumpStackPointerAddr</span>(prefix: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L1922">    <span class="tok-kw">const</span> sp = <span class="tok-kw">asm</span> (<span class="tok-str">&quot;&quot;</span></span>
<span class="line" id="L1923">        : [argc] <span class="tok-str">&quot;={rsp}&quot;</span> (-&gt; <span class="tok-type">usize</span>),</span>
<span class="line" id="L1924">    );</span>
<span class="line" id="L1925">    std.debug.print(<span class="tok-str">&quot;{} sp = 0x{x}\n&quot;</span>, .{ prefix, sp });</span>
<span class="line" id="L1926">}</span>
<span class="line" id="L1927"></span>
<span class="line" id="L1928"><span class="tok-kw">test</span> <span class="tok-str">&quot;#4353: std.debug should manage resources correctly&quot;</span> {</span>
<span class="line" id="L1929">    <span class="tok-kw">if</span> (builtin.os.tag == .wasi) <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SkipZigTest;</span>
<span class="line" id="L1930"></span>
<span class="line" id="L1931">    <span class="tok-kw">const</span> writer = std.io.null_writer;</span>
<span class="line" id="L1932">    <span class="tok-kw">var</span> di = <span class="tok-kw">try</span> openSelfDebugInfo(testing.allocator);</span>
<span class="line" id="L1933">    <span class="tok-kw">defer</span> di.deinit();</span>
<span class="line" id="L1934">    <span class="tok-kw">try</span> printSourceAtAddress(&amp;di, writer, showMyTrace(), detectTTYConfig());</span>
<span class="line" id="L1935">}</span>
<span class="line" id="L1936"></span>
<span class="line" id="L1937"><span class="tok-kw">noinline</span> <span class="tok-kw">fn</span> <span class="tok-fn">showMyTrace</span>() <span class="tok-type">usize</span> {</span>
<span class="line" id="L1938">    <span class="tok-kw">return</span> <span class="tok-builtin">@returnAddress</span>();</span>
<span class="line" id="L1939">}</span>
<span class="line" id="L1940"></span>
<span class="line" id="L1941"><span class="tok-comment">/// This API helps you track where a value originated and where it was mutated,</span></span>
<span class="line" id="L1942"><span class="tok-comment">/// or any other points of interest.</span></span>
<span class="line" id="L1943"><span class="tok-comment">/// In debug mode, it adds a small size penalty (104 bytes on 64-bit architectures)</span></span>
<span class="line" id="L1944"><span class="tok-comment">/// to the aggregate that you add it to.</span></span>
<span class="line" id="L1945"><span class="tok-comment">/// In release mode, it is size 0 and all methods are no-ops.</span></span>
<span class="line" id="L1946"><span class="tok-comment">/// This is a pre-made type with default settings.</span></span>
<span class="line" id="L1947"><span class="tok-comment">/// For more advanced usage, see `ConfigurableTrace`.</span></span>
<span class="line" id="L1948"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> Trace = ConfigurableTrace(<span class="tok-number">2</span>, <span class="tok-number">4</span>, builtin.mode == .Debug);</span>
<span class="line" id="L1949"></span>
<span class="line" id="L1950"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">ConfigurableTrace</span>(<span class="tok-kw">comptime</span> size: <span class="tok-type">usize</span>, <span class="tok-kw">comptime</span> stack_frame_count: <span class="tok-type">usize</span>, <span class="tok-kw">comptime</span> is_enabled: <span class="tok-type">bool</span>) <span class="tok-type">type</span> {</span>
<span class="line" id="L1951">    <span class="tok-kw">return</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L1952">        addrs: [actual_size][stack_frame_count]<span class="tok-type">usize</span> = <span class="tok-null">undefined</span>,</span>
<span class="line" id="L1953">        notes: [actual_size][]<span class="tok-kw">const</span> <span class="tok-type">u8</span> = <span class="tok-null">undefined</span>,</span>
<span class="line" id="L1954">        index: Index = <span class="tok-number">0</span>,</span>
<span class="line" id="L1955"></span>
<span class="line" id="L1956">        <span class="tok-kw">const</span> actual_size = <span class="tok-kw">if</span> (enabled) size <span class="tok-kw">else</span> <span class="tok-number">0</span>;</span>
<span class="line" id="L1957">        <span class="tok-kw">const</span> Index = <span class="tok-kw">if</span> (enabled) <span class="tok-type">usize</span> <span class="tok-kw">else</span> <span class="tok-type">u0</span>;</span>
<span class="line" id="L1958"></span>
<span class="line" id="L1959">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> enabled = is_enabled;</span>
<span class="line" id="L1960"></span>
<span class="line" id="L1961">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> add = <span class="tok-kw">if</span> (enabled) addNoInline <span class="tok-kw">else</span> addNoOp;</span>
<span class="line" id="L1962"></span>
<span class="line" id="L1963">        <span class="tok-kw">pub</span> <span class="tok-kw">noinline</span> <span class="tok-kw">fn</span> <span class="tok-fn">addNoInline</span>(t: *<span class="tok-builtin">@This</span>(), note: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L1964">            <span class="tok-kw">comptime</span> assert(enabled);</span>
<span class="line" id="L1965">            <span class="tok-kw">return</span> addAddr(t, <span class="tok-builtin">@returnAddress</span>(), note);</span>
<span class="line" id="L1966">        }</span>
<span class="line" id="L1967"></span>
<span class="line" id="L1968">        <span class="tok-kw">pub</span> <span class="tok-kw">inline</span> <span class="tok-kw">fn</span> <span class="tok-fn">addNoOp</span>(t: *<span class="tok-builtin">@This</span>(), note: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L1969">            _ = t;</span>
<span class="line" id="L1970">            _ = note;</span>
<span class="line" id="L1971">            <span class="tok-kw">comptime</span> assert(!enabled);</span>
<span class="line" id="L1972">        }</span>
<span class="line" id="L1973"></span>
<span class="line" id="L1974">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">addAddr</span>(t: *<span class="tok-builtin">@This</span>(), addr: <span class="tok-type">usize</span>, note: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L1975">            <span class="tok-kw">if</span> (!enabled) <span class="tok-kw">return</span>;</span>
<span class="line" id="L1976"></span>
<span class="line" id="L1977">            <span class="tok-kw">if</span> (t.index &lt; size) {</span>
<span class="line" id="L1978">                t.notes[t.index] = note;</span>
<span class="line" id="L1979">                t.addrs[t.index] = [<span class="tok-number">1</span>]<span class="tok-type">usize</span>{<span class="tok-number">0</span>} ** stack_frame_count;</span>
<span class="line" id="L1980">                <span class="tok-kw">var</span> stack_trace: std.builtin.StackTrace = .{</span>
<span class="line" id="L1981">                    .index = <span class="tok-number">0</span>,</span>
<span class="line" id="L1982">                    .instruction_addresses = &amp;t.addrs[t.index],</span>
<span class="line" id="L1983">                };</span>
<span class="line" id="L1984">                captureStackTrace(addr, &amp;stack_trace);</span>
<span class="line" id="L1985">            }</span>
<span class="line" id="L1986">            <span class="tok-comment">// Keep counting even if the end is reached so that the</span>
</span>
<span class="line" id="L1987">            <span class="tok-comment">// user can find out how much more size they need.</span>
</span>
<span class="line" id="L1988">            t.index += <span class="tok-number">1</span>;</span>
<span class="line" id="L1989">        }</span>
<span class="line" id="L1990"></span>
<span class="line" id="L1991">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">dump</span>(t: <span class="tok-builtin">@This</span>()) <span class="tok-type">void</span> {</span>
<span class="line" id="L1992">            <span class="tok-kw">if</span> (!enabled) <span class="tok-kw">return</span>;</span>
<span class="line" id="L1993"></span>
<span class="line" id="L1994">            <span class="tok-kw">const</span> tty_config = detectTTYConfig();</span>
<span class="line" id="L1995">            <span class="tok-kw">const</span> stderr = io.getStdErr().writer();</span>
<span class="line" id="L1996">            <span class="tok-kw">const</span> end = <span class="tok-builtin">@minimum</span>(t.index, size);</span>
<span class="line" id="L1997">            <span class="tok-kw">const</span> debug_info = getSelfDebugInfo() <span class="tok-kw">catch</span> |err| {</span>
<span class="line" id="L1998">                stderr.print(</span>
<span class="line" id="L1999">                    <span class="tok-str">&quot;Unable to dump stack trace: Unable to open debug info: {s}\n&quot;</span>,</span>
<span class="line" id="L2000">                    .{<span class="tok-builtin">@errorName</span>(err)},</span>
<span class="line" id="L2001">                ) <span class="tok-kw">catch</span> <span class="tok-kw">return</span>;</span>
<span class="line" id="L2002">                <span class="tok-kw">return</span>;</span>
<span class="line" id="L2003">            };</span>
<span class="line" id="L2004">            <span class="tok-kw">for</span> (t.addrs[<span class="tok-number">0</span>..end]) |frames_array, i| {</span>
<span class="line" id="L2005">                stderr.print(<span class="tok-str">&quot;{s}:\n&quot;</span>, .{t.notes[i]}) <span class="tok-kw">catch</span> <span class="tok-kw">return</span>;</span>
<span class="line" id="L2006">                <span class="tok-kw">var</span> frames_array_mutable = frames_array;</span>
<span class="line" id="L2007">                <span class="tok-kw">const</span> frames = mem.sliceTo(frames_array_mutable[<span class="tok-number">0</span>..], <span class="tok-number">0</span>);</span>
<span class="line" id="L2008">                <span class="tok-kw">const</span> stack_trace: std.builtin.StackTrace = .{</span>
<span class="line" id="L2009">                    .index = frames.len,</span>
<span class="line" id="L2010">                    .instruction_addresses = frames,</span>
<span class="line" id="L2011">                };</span>
<span class="line" id="L2012">                writeStackTrace(stack_trace, stderr, getDebugInfoAllocator(), debug_info, tty_config) <span class="tok-kw">catch</span> <span class="tok-kw">continue</span>;</span>
<span class="line" id="L2013">            }</span>
<span class="line" id="L2014">            <span class="tok-kw">if</span> (t.index &gt; end) {</span>
<span class="line" id="L2015">                stderr.print(<span class="tok-str">&quot;{d} more traces not shown; consider increasing trace size\n&quot;</span>, .{</span>
<span class="line" id="L2016">                    t.index - end,</span>
<span class="line" id="L2017">                }) <span class="tok-kw">catch</span> <span class="tok-kw">return</span>;</span>
<span class="line" id="L2018">            }</span>
<span class="line" id="L2019">        }</span>
<span class="line" id="L2020"></span>
<span class="line" id="L2021">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">format</span>(</span>
<span class="line" id="L2022">            t: Trace,</span>
<span class="line" id="L2023">            <span class="tok-kw">comptime</span> fmt: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L2024">            options: std.fmt.FormatOptions,</span>
<span class="line" id="L2025">            writer: <span class="tok-kw">anytype</span>,</span>
<span class="line" id="L2026">        ) !<span class="tok-type">void</span> {</span>
<span class="line" id="L2027">            _ = fmt;</span>
<span class="line" id="L2028">            _ = options;</span>
<span class="line" id="L2029">            <span class="tok-kw">if</span> (enabled) {</span>
<span class="line" id="L2030">                <span class="tok-kw">try</span> writer.writeAll(<span class="tok-str">&quot;\n&quot;</span>);</span>
<span class="line" id="L2031">                t.dump();</span>
<span class="line" id="L2032">                <span class="tok-kw">try</span> writer.writeAll(<span class="tok-str">&quot;\n&quot;</span>);</span>
<span class="line" id="L2033">            } <span class="tok-kw">else</span> {</span>
<span class="line" id="L2034">                <span class="tok-kw">return</span> writer.writeAll(<span class="tok-str">&quot;(value tracing disabled)&quot;</span>);</span>
<span class="line" id="L2035">            }</span>
<span class="line" id="L2036">        }</span>
<span class="line" id="L2037">    };</span>
<span class="line" id="L2038">}</span>
<span class="line" id="L2039"></span>
</code></pre></body>
</html>