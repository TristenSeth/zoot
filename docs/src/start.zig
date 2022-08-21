<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">    <title>start.zig - source view</title>
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
<pre><code><span class="line" id="L1"><span class="tok-comment">// This file is included in the compilation unit when exporting an executable.</span>
</span>
<span class="line" id="L2"></span>
<span class="line" id="L3"><span class="tok-kw">const</span> root = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;root&quot;</span>);</span>
<span class="line" id="L4"><span class="tok-kw">const</span> std = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;std.zig&quot;</span>);</span>
<span class="line" id="L5"><span class="tok-kw">const</span> builtin = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;builtin&quot;</span>);</span>
<span class="line" id="L6"><span class="tok-kw">const</span> assert = std.debug.assert;</span>
<span class="line" id="L7"><span class="tok-kw">const</span> uefi = std.os.uefi;</span>
<span class="line" id="L8"><span class="tok-kw">const</span> elf = std.elf;</span>
<span class="line" id="L9"><span class="tok-kw">const</span> tlcsprng = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;crypto/tlcsprng.zig&quot;</span>);</span>
<span class="line" id="L10"><span class="tok-kw">const</span> native_arch = builtin.cpu.arch;</span>
<span class="line" id="L11"><span class="tok-kw">const</span> native_os = builtin.os.tag;</span>
<span class="line" id="L12"></span>
<span class="line" id="L13"><span class="tok-kw">var</span> argc_argv_ptr: [*]<span class="tok-type">usize</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L14"></span>
<span class="line" id="L15"><span class="tok-kw">const</span> start_sym_name = <span class="tok-kw">if</span> (native_arch.isMIPS()) <span class="tok-str">&quot;__start&quot;</span> <span class="tok-kw">else</span> <span class="tok-str">&quot;_start&quot;</span>;</span>
<span class="line" id="L16"></span>
<span class="line" id="L17"><span class="tok-kw">comptime</span> {</span>
<span class="line" id="L18">    <span class="tok-comment">// No matter what, we import the root file, so that any export, test, comptime</span>
</span>
<span class="line" id="L19">    <span class="tok-comment">// decls there get run.</span>
</span>
<span class="line" id="L20">    _ = root;</span>
<span class="line" id="L21"></span>
<span class="line" id="L22">    <span class="tok-comment">// The self-hosted compiler is not fully capable of handling all of this start.zig file.</span>
</span>
<span class="line" id="L23">    <span class="tok-comment">// Until then, we have simplified logic here for self-hosted. TODO remove this once</span>
</span>
<span class="line" id="L24">    <span class="tok-comment">// self-hosted is capable enough to handle all of the real start.zig logic.</span>
</span>
<span class="line" id="L25">    <span class="tok-kw">if</span> (builtin.zig_backend == .stage2_wasm <span class="tok-kw">or</span></span>
<span class="line" id="L26">        builtin.zig_backend == .stage2_c <span class="tok-kw">or</span></span>
<span class="line" id="L27">        builtin.zig_backend == .stage2_x86_64 <span class="tok-kw">or</span></span>
<span class="line" id="L28">        builtin.zig_backend == .stage2_x86 <span class="tok-kw">or</span></span>
<span class="line" id="L29">        builtin.zig_backend == .stage2_aarch64 <span class="tok-kw">or</span></span>
<span class="line" id="L30">        builtin.zig_backend == .stage2_arm <span class="tok-kw">or</span></span>
<span class="line" id="L31">        builtin.zig_backend == .stage2_riscv64 <span class="tok-kw">or</span></span>
<span class="line" id="L32">        builtin.zig_backend == .stage2_sparc64)</span>
<span class="line" id="L33">    {</span>
<span class="line" id="L34">        <span class="tok-kw">if</span> (builtin.output_mode == .Exe) {</span>
<span class="line" id="L35">            <span class="tok-kw">if</span> ((builtin.link_libc <span class="tok-kw">or</span> builtin.object_format == .c) <span class="tok-kw">and</span> <span class="tok-builtin">@hasDecl</span>(root, <span class="tok-str">&quot;main&quot;</span>)) {</span>
<span class="line" id="L36">                <span class="tok-kw">if</span> (<span class="tok-builtin">@typeInfo</span>(<span class="tok-builtin">@TypeOf</span>(root.main)).Fn.calling_convention != .C) {</span>
<span class="line" id="L37">                    <span class="tok-builtin">@export</span>(main2, .{ .name = <span class="tok-str">&quot;main&quot;</span> });</span>
<span class="line" id="L38">                }</span>
<span class="line" id="L39">            } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (builtin.os.tag == .windows) {</span>
<span class="line" id="L40">                <span class="tok-builtin">@export</span>(wWinMainCRTStartup2, .{ .name = <span class="tok-str">&quot;wWinMainCRTStartup&quot;</span> });</span>
<span class="line" id="L41">            } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (builtin.os.tag == .wasi <span class="tok-kw">and</span> <span class="tok-builtin">@hasDecl</span>(root, <span class="tok-str">&quot;main&quot;</span>)) {</span>
<span class="line" id="L42">                <span class="tok-builtin">@export</span>(wasiMain2, .{ .name = <span class="tok-str">&quot;_start&quot;</span> });</span>
<span class="line" id="L43">            } <span class="tok-kw">else</span> {</span>
<span class="line" id="L44">                <span class="tok-kw">if</span> (!<span class="tok-builtin">@hasDecl</span>(root, <span class="tok-str">&quot;_start&quot;</span>)) {</span>
<span class="line" id="L45">                    <span class="tok-builtin">@export</span>(_start2, .{ .name = <span class="tok-str">&quot;_start&quot;</span> });</span>
<span class="line" id="L46">                }</span>
<span class="line" id="L47">            }</span>
<span class="line" id="L48">        }</span>
<span class="line" id="L49">    } <span class="tok-kw">else</span> {</span>
<span class="line" id="L50">        <span class="tok-kw">if</span> (builtin.output_mode == .Lib <span class="tok-kw">and</span> builtin.link_mode == .Dynamic) {</span>
<span class="line" id="L51">            <span class="tok-kw">if</span> (native_os == .windows <span class="tok-kw">and</span> !<span class="tok-builtin">@hasDecl</span>(root, <span class="tok-str">&quot;_DllMainCRTStartup&quot;</span>)) {</span>
<span class="line" id="L52">                <span class="tok-builtin">@export</span>(_DllMainCRTStartup, .{ .name = <span class="tok-str">&quot;_DllMainCRTStartup&quot;</span> });</span>
<span class="line" id="L53">            }</span>
<span class="line" id="L54">        } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (builtin.output_mode == .Exe <span class="tok-kw">or</span> <span class="tok-builtin">@hasDecl</span>(root, <span class="tok-str">&quot;main&quot;</span>)) {</span>
<span class="line" id="L55">            <span class="tok-kw">if</span> (builtin.link_libc <span class="tok-kw">and</span> <span class="tok-builtin">@hasDecl</span>(root, <span class="tok-str">&quot;main&quot;</span>)) {</span>
<span class="line" id="L56">                <span class="tok-kw">if</span> (native_arch.isWasm()) {</span>
<span class="line" id="L57">                    <span class="tok-builtin">@export</span>(mainWithoutEnv, .{ .name = <span class="tok-str">&quot;main&quot;</span> });</span>
<span class="line" id="L58">                } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (<span class="tok-builtin">@typeInfo</span>(<span class="tok-builtin">@TypeOf</span>(root.main)).Fn.calling_convention != .C) {</span>
<span class="line" id="L59">                    <span class="tok-builtin">@export</span>(main, .{ .name = <span class="tok-str">&quot;main&quot;</span> });</span>
<span class="line" id="L60">                }</span>
<span class="line" id="L61">            } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (native_os == .windows) {</span>
<span class="line" id="L62">                <span class="tok-kw">if</span> (!<span class="tok-builtin">@hasDecl</span>(root, <span class="tok-str">&quot;WinMain&quot;</span>) <span class="tok-kw">and</span> !<span class="tok-builtin">@hasDecl</span>(root, <span class="tok-str">&quot;WinMainCRTStartup&quot;</span>) <span class="tok-kw">and</span></span>
<span class="line" id="L63">                    !<span class="tok-builtin">@hasDecl</span>(root, <span class="tok-str">&quot;wWinMain&quot;</span>) <span class="tok-kw">and</span> !<span class="tok-builtin">@hasDecl</span>(root, <span class="tok-str">&quot;wWinMainCRTStartup&quot;</span>))</span>
<span class="line" id="L64">                {</span>
<span class="line" id="L65">                    <span class="tok-builtin">@export</span>(WinStartup, .{ .name = <span class="tok-str">&quot;wWinMainCRTStartup&quot;</span> });</span>
<span class="line" id="L66">                } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (<span class="tok-builtin">@hasDecl</span>(root, <span class="tok-str">&quot;WinMain&quot;</span>) <span class="tok-kw">and</span> !<span class="tok-builtin">@hasDecl</span>(root, <span class="tok-str">&quot;WinMainCRTStartup&quot;</span>) <span class="tok-kw">and</span></span>
<span class="line" id="L67">                    !<span class="tok-builtin">@hasDecl</span>(root, <span class="tok-str">&quot;wWinMain&quot;</span>) <span class="tok-kw">and</span> !<span class="tok-builtin">@hasDecl</span>(root, <span class="tok-str">&quot;wWinMainCRTStartup&quot;</span>))</span>
<span class="line" id="L68">                {</span>
<span class="line" id="L69">                    <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;WinMain not supported; declare wWinMain or main instead&quot;</span>);</span>
<span class="line" id="L70">                } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (<span class="tok-builtin">@hasDecl</span>(root, <span class="tok-str">&quot;wWinMain&quot;</span>) <span class="tok-kw">and</span> !<span class="tok-builtin">@hasDecl</span>(root, <span class="tok-str">&quot;wWinMainCRTStartup&quot;</span>) <span class="tok-kw">and</span></span>
<span class="line" id="L71">                    !<span class="tok-builtin">@hasDecl</span>(root, <span class="tok-str">&quot;WinMain&quot;</span>) <span class="tok-kw">and</span> !<span class="tok-builtin">@hasDecl</span>(root, <span class="tok-str">&quot;WinMainCRTStartup&quot;</span>))</span>
<span class="line" id="L72">                {</span>
<span class="line" id="L73">                    <span class="tok-builtin">@export</span>(wWinMainCRTStartup, .{ .name = <span class="tok-str">&quot;wWinMainCRTStartup&quot;</span> });</span>
<span class="line" id="L74">                }</span>
<span class="line" id="L75">            } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (native_os == .uefi) {</span>
<span class="line" id="L76">                <span class="tok-kw">if</span> (!<span class="tok-builtin">@hasDecl</span>(root, <span class="tok-str">&quot;EfiMain&quot;</span>)) <span class="tok-builtin">@export</span>(EfiMain, .{ .name = <span class="tok-str">&quot;EfiMain&quot;</span> });</span>
<span class="line" id="L77">            } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (native_os == .wasi) {</span>
<span class="line" id="L78">                <span class="tok-kw">const</span> wasm_start_sym = <span class="tok-kw">switch</span> (builtin.wasi_exec_model) {</span>
<span class="line" id="L79">                    .reactor =&gt; <span class="tok-str">&quot;_initialize&quot;</span>,</span>
<span class="line" id="L80">                    .command =&gt; <span class="tok-str">&quot;_start&quot;</span>,</span>
<span class="line" id="L81">                };</span>
<span class="line" id="L82">                <span class="tok-kw">if</span> (!<span class="tok-builtin">@hasDecl</span>(root, wasm_start_sym)) {</span>
<span class="line" id="L83">                    <span class="tok-builtin">@export</span>(wasi_start, .{ .name = wasm_start_sym });</span>
<span class="line" id="L84">                }</span>
<span class="line" id="L85">            } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (native_arch.isWasm() <span class="tok-kw">and</span> native_os == .freestanding) {</span>
<span class="line" id="L86">                <span class="tok-kw">if</span> (!<span class="tok-builtin">@hasDecl</span>(root, start_sym_name)) <span class="tok-builtin">@export</span>(wasm_freestanding_start, .{ .name = start_sym_name });</span>
<span class="line" id="L87">            } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (native_os != .other <span class="tok-kw">and</span> native_os != .freestanding) {</span>
<span class="line" id="L88">                <span class="tok-kw">if</span> (!<span class="tok-builtin">@hasDecl</span>(root, start_sym_name)) <span class="tok-builtin">@export</span>(_start, .{ .name = start_sym_name });</span>
<span class="line" id="L89">            }</span>
<span class="line" id="L90">        }</span>
<span class="line" id="L91">    }</span>
<span class="line" id="L92">}</span>
<span class="line" id="L93"></span>
<span class="line" id="L94"><span class="tok-comment">// Simplified start code for stage2 until it supports more language features ///</span>
</span>
<span class="line" id="L95"></span>
<span class="line" id="L96"><span class="tok-kw">fn</span> <span class="tok-fn">main2</span>() <span class="tok-kw">callconv</span>(.C) <span class="tok-type">c_int</span> {</span>
<span class="line" id="L97">    root.main();</span>
<span class="line" id="L98">    <span class="tok-kw">return</span> <span class="tok-number">0</span>;</span>
<span class="line" id="L99">}</span>
<span class="line" id="L100"></span>
<span class="line" id="L101"><span class="tok-kw">fn</span> <span class="tok-fn">_start2</span>() <span class="tok-kw">callconv</span>(.Naked) <span class="tok-type">noreturn</span> {</span>
<span class="line" id="L102">    callMain2();</span>
<span class="line" id="L103">}</span>
<span class="line" id="L104"></span>
<span class="line" id="L105"><span class="tok-kw">fn</span> <span class="tok-fn">callMain2</span>() <span class="tok-type">noreturn</span> {</span>
<span class="line" id="L106">    <span class="tok-builtin">@setAlignStack</span>(<span class="tok-number">16</span>);</span>
<span class="line" id="L107">    root.main();</span>
<span class="line" id="L108">    exit2(<span class="tok-number">0</span>);</span>
<span class="line" id="L109">}</span>
<span class="line" id="L110"></span>
<span class="line" id="L111"><span class="tok-kw">fn</span> <span class="tok-fn">wasiMain2</span>() <span class="tok-kw">callconv</span>(.C) <span class="tok-type">noreturn</span> {</span>
<span class="line" id="L112">    <span class="tok-kw">switch</span> (<span class="tok-builtin">@typeInfo</span>(<span class="tok-builtin">@typeInfo</span>(<span class="tok-builtin">@TypeOf</span>(root.main)).Fn.return_type.?)) {</span>
<span class="line" id="L113">        .Void =&gt; {</span>
<span class="line" id="L114">            root.main();</span>
<span class="line" id="L115">            std.os.wasi.proc_exit(<span class="tok-number">0</span>);</span>
<span class="line" id="L116">        },</span>
<span class="line" id="L117">        .Int =&gt; |info| {</span>
<span class="line" id="L118">            <span class="tok-kw">if</span> (info.bits != <span class="tok-number">8</span> <span class="tok-kw">or</span> info.signedness == .signed) {</span>
<span class="line" id="L119">                <span class="tok-builtin">@compileError</span>(bad_main_ret);</span>
<span class="line" id="L120">            }</span>
<span class="line" id="L121">            std.os.wasi.proc_exit(root.main());</span>
<span class="line" id="L122">        },</span>
<span class="line" id="L123">        <span class="tok-kw">else</span> =&gt; <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;Bad return type main&quot;</span>),</span>
<span class="line" id="L124">    }</span>
<span class="line" id="L125">}</span>
<span class="line" id="L126"></span>
<span class="line" id="L127"><span class="tok-kw">fn</span> <span class="tok-fn">wWinMainCRTStartup2</span>() <span class="tok-kw">callconv</span>(.C) <span class="tok-type">noreturn</span> {</span>
<span class="line" id="L128">    root.main();</span>
<span class="line" id="L129">    exit2(<span class="tok-number">0</span>);</span>
<span class="line" id="L130">}</span>
<span class="line" id="L131"></span>
<span class="line" id="L132"><span class="tok-kw">fn</span> <span class="tok-fn">exit2</span>(code: <span class="tok-type">usize</span>) <span class="tok-type">noreturn</span> {</span>
<span class="line" id="L133">    <span class="tok-kw">switch</span> (native_os) {</span>
<span class="line" id="L134">        .linux =&gt; <span class="tok-kw">switch</span> (builtin.cpu.arch) {</span>
<span class="line" id="L135">            .x86_64 =&gt; {</span>
<span class="line" id="L136">                <span class="tok-kw">asm</span> <span class="tok-kw">volatile</span> (<span class="tok-str">&quot;syscall&quot;</span></span>
<span class="line" id="L137">                    :</span>
<span class="line" id="L138">                    : [number] <span class="tok-str">&quot;{rax}&quot;</span> (<span class="tok-number">231</span>),</span>
<span class="line" id="L139">                      [arg1] <span class="tok-str">&quot;{rdi}&quot;</span> (code),</span>
<span class="line" id="L140">                    : <span class="tok-str">&quot;rcx&quot;</span>, <span class="tok-str">&quot;r11&quot;</span>, <span class="tok-str">&quot;memory&quot;</span></span>
<span class="line" id="L141">                );</span>
<span class="line" id="L142">            },</span>
<span class="line" id="L143">            .arm =&gt; {</span>
<span class="line" id="L144">                <span class="tok-kw">asm</span> <span class="tok-kw">volatile</span> (<span class="tok-str">&quot;svc #0&quot;</span></span>
<span class="line" id="L145">                    :</span>
<span class="line" id="L146">                    : [number] <span class="tok-str">&quot;{r7}&quot;</span> (<span class="tok-number">1</span>),</span>
<span class="line" id="L147">                      [arg1] <span class="tok-str">&quot;{r0}&quot;</span> (code),</span>
<span class="line" id="L148">                    : <span class="tok-str">&quot;memory&quot;</span></span>
<span class="line" id="L149">                );</span>
<span class="line" id="L150">            },</span>
<span class="line" id="L151">            .aarch64 =&gt; {</span>
<span class="line" id="L152">                <span class="tok-kw">asm</span> <span class="tok-kw">volatile</span> (<span class="tok-str">&quot;svc #0&quot;</span></span>
<span class="line" id="L153">                    :</span>
<span class="line" id="L154">                    : [number] <span class="tok-str">&quot;{x8}&quot;</span> (<span class="tok-number">93</span>),</span>
<span class="line" id="L155">                      [arg1] <span class="tok-str">&quot;{x0}&quot;</span> (code),</span>
<span class="line" id="L156">                    : <span class="tok-str">&quot;memory&quot;</span>, <span class="tok-str">&quot;cc&quot;</span></span>
<span class="line" id="L157">                );</span>
<span class="line" id="L158">            },</span>
<span class="line" id="L159">            .riscv64 =&gt; {</span>
<span class="line" id="L160">                <span class="tok-kw">asm</span> <span class="tok-kw">volatile</span> (<span class="tok-str">&quot;ecall&quot;</span></span>
<span class="line" id="L161">                    :</span>
<span class="line" id="L162">                    : [number] <span class="tok-str">&quot;{a7}&quot;</span> (<span class="tok-number">94</span>),</span>
<span class="line" id="L163">                      [arg1] <span class="tok-str">&quot;{a0}&quot;</span> (<span class="tok-number">0</span>),</span>
<span class="line" id="L164">                    : <span class="tok-str">&quot;rcx&quot;</span>, <span class="tok-str">&quot;r11&quot;</span>, <span class="tok-str">&quot;memory&quot;</span></span>
<span class="line" id="L165">                );</span>
<span class="line" id="L166">            },</span>
<span class="line" id="L167">            .sparc64 =&gt; {</span>
<span class="line" id="L168">                <span class="tok-kw">asm</span> <span class="tok-kw">volatile</span> (<span class="tok-str">&quot;ta 0x6d&quot;</span></span>
<span class="line" id="L169">                    :</span>
<span class="line" id="L170">                    : [number] <span class="tok-str">&quot;{g1}&quot;</span> (<span class="tok-number">1</span>),</span>
<span class="line" id="L171">                      [arg1] <span class="tok-str">&quot;{o0}&quot;</span> (code),</span>
<span class="line" id="L172">                    : <span class="tok-str">&quot;o0&quot;</span>, <span class="tok-str">&quot;o1&quot;</span>, <span class="tok-str">&quot;o2&quot;</span>, <span class="tok-str">&quot;o3&quot;</span>, <span class="tok-str">&quot;o4&quot;</span>, <span class="tok-str">&quot;o5&quot;</span>, <span class="tok-str">&quot;o6&quot;</span>, <span class="tok-str">&quot;o7&quot;</span>, <span class="tok-str">&quot;memory&quot;</span></span>
<span class="line" id="L173">                );</span>
<span class="line" id="L174">            },</span>
<span class="line" id="L175">            <span class="tok-kw">else</span> =&gt; <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;TODO&quot;</span>),</span>
<span class="line" id="L176">        },</span>
<span class="line" id="L177">        <span class="tok-comment">// exits(0)</span>
</span>
<span class="line" id="L178">        .plan9 =&gt; <span class="tok-kw">switch</span> (builtin.cpu.arch) {</span>
<span class="line" id="L179">            .x86_64 =&gt; {</span>
<span class="line" id="L180">                <span class="tok-kw">asm</span> <span class="tok-kw">volatile</span> (</span>
<span class="line" id="L181">                    <span class="tok-str">\\push $0</span></span>

<span class="line" id="L182">                    <span class="tok-str">\\push $0</span></span>

<span class="line" id="L183">                    <span class="tok-str">\\syscall</span></span>

<span class="line" id="L184">                    :</span>
<span class="line" id="L185">                    : [syscall_number] <span class="tok-str">&quot;{rbp}&quot;</span> (<span class="tok-number">8</span>),</span>
<span class="line" id="L186">                    : <span class="tok-str">&quot;rcx&quot;</span>, <span class="tok-str">&quot;r11&quot;</span>, <span class="tok-str">&quot;memory&quot;</span></span>
<span class="line" id="L187">                );</span>
<span class="line" id="L188">            },</span>
<span class="line" id="L189">            <span class="tok-comment">// TODO once we get stack setting with assembly on</span>
</span>
<span class="line" id="L190">            <span class="tok-comment">// arm, exit with 0 instead of stack garbage</span>
</span>
<span class="line" id="L191">            .aarch64 =&gt; {</span>
<span class="line" id="L192">                <span class="tok-kw">asm</span> <span class="tok-kw">volatile</span> (<span class="tok-str">&quot;svc #0&quot;</span></span>
<span class="line" id="L193">                    :</span>
<span class="line" id="L194">                    : [exit] <span class="tok-str">&quot;{x0}&quot;</span> (<span class="tok-number">0x08</span>),</span>
<span class="line" id="L195">                    : <span class="tok-str">&quot;memory&quot;</span>, <span class="tok-str">&quot;cc&quot;</span></span>
<span class="line" id="L196">                );</span>
<span class="line" id="L197">            },</span>
<span class="line" id="L198">            <span class="tok-kw">else</span> =&gt; <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;TODO&quot;</span>),</span>
<span class="line" id="L199">        },</span>
<span class="line" id="L200">        .windows =&gt; {</span>
<span class="line" id="L201">            ExitProcess(<span class="tok-builtin">@truncate</span>(<span class="tok-type">u32</span>, code));</span>
<span class="line" id="L202">        },</span>
<span class="line" id="L203">        <span class="tok-kw">else</span> =&gt; <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;TODO&quot;</span>),</span>
<span class="line" id="L204">    }</span>
<span class="line" id="L205">    <span class="tok-kw">unreachable</span>;</span>
<span class="line" id="L206">}</span>
<span class="line" id="L207"></span>
<span class="line" id="L208"><span class="tok-kw">extern</span> <span class="tok-str">&quot;kernel32&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">ExitProcess</span>(exit_code: <span class="tok-type">u32</span>) <span class="tok-kw">callconv</span>(.C) <span class="tok-type">noreturn</span>;</span>
<span class="line" id="L209"></span>
<span class="line" id="L210"><span class="tok-comment">////////////////////////////////////////////////////////////////////////////////</span>
</span>
<span class="line" id="L211"></span>
<span class="line" id="L212"><span class="tok-kw">fn</span> <span class="tok-fn">_DllMainCRTStartup</span>(</span>
<span class="line" id="L213">    hinstDLL: std.os.windows.HINSTANCE,</span>
<span class="line" id="L214">    fdwReason: std.os.windows.DWORD,</span>
<span class="line" id="L215">    lpReserved: std.os.windows.LPVOID,</span>
<span class="line" id="L216">) <span class="tok-kw">callconv</span>(std.os.windows.WINAPI) std.os.windows.BOOL {</span>
<span class="line" id="L217">    <span class="tok-kw">if</span> (!builtin.single_threaded <span class="tok-kw">and</span> !builtin.link_libc) {</span>
<span class="line" id="L218">        _ = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;start_windows_tls.zig&quot;</span>);</span>
<span class="line" id="L219">    }</span>
<span class="line" id="L220"></span>
<span class="line" id="L221">    <span class="tok-kw">if</span> (<span class="tok-builtin">@hasDecl</span>(root, <span class="tok-str">&quot;DllMain&quot;</span>)) {</span>
<span class="line" id="L222">        <span class="tok-kw">return</span> root.DllMain(hinstDLL, fdwReason, lpReserved);</span>
<span class="line" id="L223">    }</span>
<span class="line" id="L224"></span>
<span class="line" id="L225">    <span class="tok-kw">return</span> std.os.windows.TRUE;</span>
<span class="line" id="L226">}</span>
<span class="line" id="L227"></span>
<span class="line" id="L228"><span class="tok-kw">fn</span> <span class="tok-fn">wasm_freestanding_start</span>() <span class="tok-kw">callconv</span>(.C) <span class="tok-type">void</span> {</span>
<span class="line" id="L229">    <span class="tok-comment">// This is marked inline because for some reason LLVM in</span>
</span>
<span class="line" id="L230">    <span class="tok-comment">// release mode fails to inline it, and we want fewer call frames in stack traces.</span>
</span>
<span class="line" id="L231">    _ = <span class="tok-builtin">@call</span>(.{ .modifier = .always_inline }, callMain, .{});</span>
<span class="line" id="L232">}</span>
<span class="line" id="L233"></span>
<span class="line" id="L234"><span class="tok-kw">fn</span> <span class="tok-fn">wasi_start</span>() <span class="tok-kw">callconv</span>(.C) <span class="tok-type">void</span> {</span>
<span class="line" id="L235">    <span class="tok-comment">// The function call is marked inline because for some reason LLVM in</span>
</span>
<span class="line" id="L236">    <span class="tok-comment">// release mode fails to inline it, and we want fewer call frames in stack traces.</span>
</span>
<span class="line" id="L237">    <span class="tok-kw">switch</span> (builtin.wasi_exec_model) {</span>
<span class="line" id="L238">        .reactor =&gt; _ = <span class="tok-builtin">@call</span>(.{ .modifier = .always_inline }, callMain, .{}),</span>
<span class="line" id="L239">        .command =&gt; std.os.wasi.proc_exit(<span class="tok-builtin">@call</span>(.{ .modifier = .always_inline }, callMain, .{})),</span>
<span class="line" id="L240">    }</span>
<span class="line" id="L241">}</span>
<span class="line" id="L242"></span>
<span class="line" id="L243"><span class="tok-kw">fn</span> <span class="tok-fn">EfiMain</span>(handle: uefi.Handle, system_table: *uefi.tables.SystemTable) <span class="tok-kw">callconv</span>(.C) <span class="tok-type">usize</span> {</span>
<span class="line" id="L244">    uefi.handle = handle;</span>
<span class="line" id="L245">    uefi.system_table = system_table;</span>
<span class="line" id="L246"></span>
<span class="line" id="L247">    <span class="tok-kw">switch</span> (<span class="tok-builtin">@typeInfo</span>(<span class="tok-builtin">@TypeOf</span>(root.main)).Fn.return_type.?) {</span>
<span class="line" id="L248">        <span class="tok-type">noreturn</span> =&gt; {</span>
<span class="line" id="L249">            root.main();</span>
<span class="line" id="L250">        },</span>
<span class="line" id="L251">        <span class="tok-type">void</span> =&gt; {</span>
<span class="line" id="L252">            root.main();</span>
<span class="line" id="L253">            <span class="tok-kw">return</span> <span class="tok-number">0</span>;</span>
<span class="line" id="L254">        },</span>
<span class="line" id="L255">        <span class="tok-type">usize</span> =&gt; {</span>
<span class="line" id="L256">            <span class="tok-kw">return</span> root.main();</span>
<span class="line" id="L257">        },</span>
<span class="line" id="L258">        uefi.Status =&gt; {</span>
<span class="line" id="L259">            <span class="tok-kw">return</span> <span class="tok-builtin">@enumToInt</span>(root.main());</span>
<span class="line" id="L260">        },</span>
<span class="line" id="L261">        <span class="tok-kw">else</span> =&gt; <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;expected return type of main to be 'void', 'noreturn', 'usize', or 'std.os.uefi.Status'&quot;</span>),</span>
<span class="line" id="L262">    }</span>
<span class="line" id="L263">}</span>
<span class="line" id="L264"></span>
<span class="line" id="L265"><span class="tok-kw">fn</span> <span class="tok-fn">_start</span>() <span class="tok-kw">callconv</span>(.Naked) <span class="tok-type">noreturn</span> {</span>
<span class="line" id="L266">    <span class="tok-kw">switch</span> (native_arch) {</span>
<span class="line" id="L267">        .x86_64 =&gt; {</span>
<span class="line" id="L268">            argc_argv_ptr = <span class="tok-kw">asm</span> <span class="tok-kw">volatile</span> (</span>
<span class="line" id="L269">                <span class="tok-str">\\ xor %%rbp, %%rbp</span></span>

<span class="line" id="L270">                : [argc] <span class="tok-str">&quot;={rsp}&quot;</span> (-&gt; [*]<span class="tok-type">usize</span>),</span>
<span class="line" id="L271">            );</span>
<span class="line" id="L272">        },</span>
<span class="line" id="L273">        .<span class="tok-type">i386</span> =&gt; {</span>
<span class="line" id="L274">            argc_argv_ptr = <span class="tok-kw">asm</span> <span class="tok-kw">volatile</span> (</span>
<span class="line" id="L275">                <span class="tok-str">\\ xor %%ebp, %%ebp</span></span>

<span class="line" id="L276">                : [argc] <span class="tok-str">&quot;={esp}&quot;</span> (-&gt; [*]<span class="tok-type">usize</span>),</span>
<span class="line" id="L277">            );</span>
<span class="line" id="L278">        },</span>
<span class="line" id="L279">        .aarch64, .aarch64_be, .arm, .armeb, .thumb =&gt; {</span>
<span class="line" id="L280">            argc_argv_ptr = <span class="tok-kw">asm</span> <span class="tok-kw">volatile</span> (</span>
<span class="line" id="L281">                <span class="tok-str">\\ mov fp, #0</span></span>

<span class="line" id="L282">                <span class="tok-str">\\ mov lr, #0</span></span>

<span class="line" id="L283">                : [argc] <span class="tok-str">&quot;={sp}&quot;</span> (-&gt; [*]<span class="tok-type">usize</span>),</span>
<span class="line" id="L284">            );</span>
<span class="line" id="L285">        },</span>
<span class="line" id="L286">        .riscv64 =&gt; {</span>
<span class="line" id="L287">            argc_argv_ptr = <span class="tok-kw">asm</span> <span class="tok-kw">volatile</span> (</span>
<span class="line" id="L288">                <span class="tok-str">\\ li s0, 0</span></span>

<span class="line" id="L289">                <span class="tok-str">\\ li ra, 0</span></span>

<span class="line" id="L290">                : [argc] <span class="tok-str">&quot;={sp}&quot;</span> (-&gt; [*]<span class="tok-type">usize</span>),</span>
<span class="line" id="L291">            );</span>
<span class="line" id="L292">        },</span>
<span class="line" id="L293">        .mips, .mipsel =&gt; {</span>
<span class="line" id="L294">            <span class="tok-comment">// The lr is already zeroed on entry, as specified by the ABI.</span>
</span>
<span class="line" id="L295">            argc_argv_ptr = <span class="tok-kw">asm</span> <span class="tok-kw">volatile</span> (</span>
<span class="line" id="L296">                <span class="tok-str">\\ move $fp, $0</span></span>

<span class="line" id="L297">                : [argc] <span class="tok-str">&quot;={sp}&quot;</span> (-&gt; [*]<span class="tok-type">usize</span>),</span>
<span class="line" id="L298">            );</span>
<span class="line" id="L299">        },</span>
<span class="line" id="L300">        .powerpc =&gt; {</span>
<span class="line" id="L301">            <span class="tok-comment">// Setup the initial stack frame and clear the back chain pointer.</span>
</span>
<span class="line" id="L302">            argc_argv_ptr = <span class="tok-kw">asm</span> <span class="tok-kw">volatile</span> (</span>
<span class="line" id="L303">                <span class="tok-str">\\ mr 4, 1</span></span>

<span class="line" id="L304">                <span class="tok-str">\\ li 0, 0</span></span>

<span class="line" id="L305">                <span class="tok-str">\\ stwu 1,-16(1)</span></span>

<span class="line" id="L306">                <span class="tok-str">\\ stw 0, 0(1)</span></span>

<span class="line" id="L307">                <span class="tok-str">\\ mtlr 0</span></span>

<span class="line" id="L308">                : [argc] <span class="tok-str">&quot;={r4}&quot;</span> (-&gt; [*]<span class="tok-type">usize</span>),</span>
<span class="line" id="L309">                :</span>
<span class="line" id="L310">                : <span class="tok-str">&quot;r0&quot;</span></span>
<span class="line" id="L311">            );</span>
<span class="line" id="L312">        },</span>
<span class="line" id="L313">        .powerpc64le =&gt; {</span>
<span class="line" id="L314">            <span class="tok-comment">// Setup the initial stack frame and clear the back chain pointer.</span>
</span>
<span class="line" id="L315">            <span class="tok-comment">// TODO: Support powerpc64 (big endian) on ELFv2.</span>
</span>
<span class="line" id="L316">            argc_argv_ptr = <span class="tok-kw">asm</span> <span class="tok-kw">volatile</span> (</span>
<span class="line" id="L317">                <span class="tok-str">\\ mr 4, 1</span></span>

<span class="line" id="L318">                <span class="tok-str">\\ li 0, 0</span></span>

<span class="line" id="L319">                <span class="tok-str">\\ stdu 0, -32(1)</span></span>

<span class="line" id="L320">                <span class="tok-str">\\ mtlr 0</span></span>

<span class="line" id="L321">                : [argc] <span class="tok-str">&quot;={r4}&quot;</span> (-&gt; [*]<span class="tok-type">usize</span>),</span>
<span class="line" id="L322">                :</span>
<span class="line" id="L323">                : <span class="tok-str">&quot;r0&quot;</span></span>
<span class="line" id="L324">            );</span>
<span class="line" id="L325">        },</span>
<span class="line" id="L326">        .sparc64 =&gt; {</span>
<span class="line" id="L327">            <span class="tok-comment">// argc is stored after a register window (16 registers) plus stack bias</span>
</span>
<span class="line" id="L328">            argc_argv_ptr = <span class="tok-kw">asm</span> (</span>
<span class="line" id="L329">                <span class="tok-str">\\ mov %%g0, %%i6</span></span>

<span class="line" id="L330">                <span class="tok-str">\\ add %%o6, 2175, %[argc]</span></span>

<span class="line" id="L331">                : [argc] <span class="tok-str">&quot;=r&quot;</span> (-&gt; [*]<span class="tok-type">usize</span>),</span>
<span class="line" id="L332">            );</span>
<span class="line" id="L333">        },</span>
<span class="line" id="L334">        <span class="tok-kw">else</span> =&gt; <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;unsupported arch&quot;</span>),</span>
<span class="line" id="L335">    }</span>
<span class="line" id="L336">    <span class="tok-comment">// If LLVM inlines stack variables into _start, they will overwrite</span>
</span>
<span class="line" id="L337">    <span class="tok-comment">// the command line argument data.</span>
</span>
<span class="line" id="L338">    <span class="tok-builtin">@call</span>(.{ .modifier = .never_inline }, posixCallMainAndExit, .{});</span>
<span class="line" id="L339">}</span>
<span class="line" id="L340"></span>
<span class="line" id="L341"><span class="tok-kw">fn</span> <span class="tok-fn">WinStartup</span>() <span class="tok-kw">callconv</span>(std.os.windows.WINAPI) <span class="tok-type">noreturn</span> {</span>
<span class="line" id="L342">    <span class="tok-builtin">@setAlignStack</span>(<span class="tok-number">16</span>);</span>
<span class="line" id="L343">    <span class="tok-kw">if</span> (!builtin.single_threaded <span class="tok-kw">and</span> !builtin.link_libc) {</span>
<span class="line" id="L344">        _ = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;start_windows_tls.zig&quot;</span>);</span>
<span class="line" id="L345">    }</span>
<span class="line" id="L346"></span>
<span class="line" id="L347">    std.debug.maybeEnableSegfaultHandler();</span>
<span class="line" id="L348"></span>
<span class="line" id="L349">    std.os.windows.kernel32.ExitProcess(initEventLoopAndCallMain());</span>
<span class="line" id="L350">}</span>
<span class="line" id="L351"></span>
<span class="line" id="L352"><span class="tok-kw">fn</span> <span class="tok-fn">wWinMainCRTStartup</span>() <span class="tok-kw">callconv</span>(std.os.windows.WINAPI) <span class="tok-type">noreturn</span> {</span>
<span class="line" id="L353">    <span class="tok-builtin">@setAlignStack</span>(<span class="tok-number">16</span>);</span>
<span class="line" id="L354">    <span class="tok-kw">if</span> (!builtin.single_threaded <span class="tok-kw">and</span> !builtin.link_libc) {</span>
<span class="line" id="L355">        _ = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;start_windows_tls.zig&quot;</span>);</span>
<span class="line" id="L356">    }</span>
<span class="line" id="L357"></span>
<span class="line" id="L358">    std.debug.maybeEnableSegfaultHandler();</span>
<span class="line" id="L359"></span>
<span class="line" id="L360">    <span class="tok-kw">const</span> result: std.os.windows.INT = initEventLoopAndCallWinMain();</span>
<span class="line" id="L361">    std.os.windows.kernel32.ExitProcess(<span class="tok-builtin">@bitCast</span>(std.os.windows.UINT, result));</span>
<span class="line" id="L362">}</span>
<span class="line" id="L363"></span>
<span class="line" id="L364"><span class="tok-kw">fn</span> <span class="tok-fn">posixCallMainAndExit</span>() <span class="tok-type">noreturn</span> {</span>
<span class="line" id="L365">    <span class="tok-builtin">@setAlignStack</span>(<span class="tok-number">16</span>);</span>
<span class="line" id="L366"></span>
<span class="line" id="L367">    <span class="tok-kw">const</span> argc = argc_argv_ptr[<span class="tok-number">0</span>];</span>
<span class="line" id="L368">    <span class="tok-kw">const</span> argv = <span class="tok-builtin">@ptrCast</span>([*][*:<span class="tok-number">0</span>]<span class="tok-type">u8</span>, argc_argv_ptr + <span class="tok-number">1</span>);</span>
<span class="line" id="L369"></span>
<span class="line" id="L370">    <span class="tok-kw">const</span> envp_optional = <span class="tok-builtin">@ptrCast</span>([*:<span class="tok-null">null</span>]?[*:<span class="tok-number">0</span>]<span class="tok-type">u8</span>, <span class="tok-builtin">@alignCast</span>(<span class="tok-builtin">@alignOf</span>(<span class="tok-type">usize</span>), argv + argc + <span class="tok-number">1</span>));</span>
<span class="line" id="L371">    <span class="tok-kw">var</span> envp_count: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L372">    <span class="tok-kw">while</span> (envp_optional[envp_count]) |_| : (envp_count += <span class="tok-number">1</span>) {}</span>
<span class="line" id="L373">    <span class="tok-kw">const</span> envp = <span class="tok-builtin">@ptrCast</span>([*][*:<span class="tok-number">0</span>]<span class="tok-type">u8</span>, envp_optional)[<span class="tok-number">0</span>..envp_count];</span>
<span class="line" id="L374"></span>
<span class="line" id="L375">    <span class="tok-kw">if</span> (native_os == .linux) {</span>
<span class="line" id="L376">        <span class="tok-comment">// Find the beginning of the auxiliary vector</span>
</span>
<span class="line" id="L377">        <span class="tok-kw">const</span> auxv = <span class="tok-builtin">@ptrCast</span>([*]elf.Auxv, <span class="tok-builtin">@alignCast</span>(<span class="tok-builtin">@alignOf</span>(<span class="tok-type">usize</span>), envp.ptr + envp_count + <span class="tok-number">1</span>));</span>
<span class="line" id="L378">        std.os.linux.elf_aux_maybe = auxv;</span>
<span class="line" id="L379"></span>
<span class="line" id="L380">        <span class="tok-kw">var</span> at_hwcap: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L381">        <span class="tok-kw">const</span> phdrs = init: {</span>
<span class="line" id="L382">            <span class="tok-kw">var</span> i: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L383">            <span class="tok-kw">var</span> at_phdr: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L384">            <span class="tok-kw">var</span> at_phnum: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L385">            <span class="tok-kw">while</span> (auxv[i].a_type != elf.AT_NULL) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L386">                <span class="tok-kw">switch</span> (auxv[i].a_type) {</span>
<span class="line" id="L387">                    elf.AT_PHNUM =&gt; at_phnum = auxv[i].a_un.a_val,</span>
<span class="line" id="L388">                    elf.AT_PHDR =&gt; at_phdr = auxv[i].a_un.a_val,</span>
<span class="line" id="L389">                    elf.AT_HWCAP =&gt; at_hwcap = auxv[i].a_un.a_val,</span>
<span class="line" id="L390">                    <span class="tok-kw">else</span> =&gt; <span class="tok-kw">continue</span>,</span>
<span class="line" id="L391">                }</span>
<span class="line" id="L392">            }</span>
<span class="line" id="L393">            <span class="tok-kw">break</span> :init <span class="tok-builtin">@intToPtr</span>([*]elf.Phdr, at_phdr)[<span class="tok-number">0</span>..at_phnum];</span>
<span class="line" id="L394">        };</span>
<span class="line" id="L395"></span>
<span class="line" id="L396">        <span class="tok-comment">// Apply the initial relocations as early as possible in the startup</span>
</span>
<span class="line" id="L397">        <span class="tok-comment">// process.</span>
</span>
<span class="line" id="L398">        <span class="tok-kw">if</span> (builtin.position_independent_executable) {</span>
<span class="line" id="L399">            std.os.linux.pie.relocate(phdrs);</span>
<span class="line" id="L400">        }</span>
<span class="line" id="L401"></span>
<span class="line" id="L402">        <span class="tok-comment">// ARMv6 targets (and earlier) have no support for TLS in hardware.</span>
</span>
<span class="line" id="L403">        <span class="tok-comment">// FIXME: Elide the check for targets &gt;= ARMv7 when the target feature API</span>
</span>
<span class="line" id="L404">        <span class="tok-comment">// becomes less verbose (and more usable).</span>
</span>
<span class="line" id="L405">        <span class="tok-kw">if</span> (<span class="tok-kw">comptime</span> native_arch.isARM()) {</span>
<span class="line" id="L406">            <span class="tok-kw">if</span> (at_hwcap &amp; std.os.linux.HWCAP.TLS == <span class="tok-number">0</span>) {</span>
<span class="line" id="L407">                <span class="tok-comment">// FIXME: Make __aeabi_read_tp call the kernel helper kuser_get_tls</span>
</span>
<span class="line" id="L408">                <span class="tok-comment">// For the time being use a simple abort instead of a @panic call to</span>
</span>
<span class="line" id="L409">                <span class="tok-comment">// keep the binary bloat under control.</span>
</span>
<span class="line" id="L410">                std.os.abort();</span>
<span class="line" id="L411">            }</span>
<span class="line" id="L412">        }</span>
<span class="line" id="L413"></span>
<span class="line" id="L414">        <span class="tok-comment">// Initialize the TLS area.</span>
</span>
<span class="line" id="L415">        std.os.linux.tls.initStaticTLS(phdrs);</span>
<span class="line" id="L416"></span>
<span class="line" id="L417">        <span class="tok-comment">// The way Linux executables represent stack size is via the PT_GNU_STACK</span>
</span>
<span class="line" id="L418">        <span class="tok-comment">// program header. However the kernel does not recognize it; it always gives 8 MiB.</span>
</span>
<span class="line" id="L419">        <span class="tok-comment">// Here we look for the stack size in our program headers and use setrlimit</span>
</span>
<span class="line" id="L420">        <span class="tok-comment">// to ask for more stack space.</span>
</span>
<span class="line" id="L421">        expandStackSize(phdrs);</span>
<span class="line" id="L422">    }</span>
<span class="line" id="L423"></span>
<span class="line" id="L424">    std.os.exit(<span class="tok-builtin">@call</span>(.{ .modifier = .always_inline }, callMainWithArgs, .{ argc, argv, envp }));</span>
<span class="line" id="L425">}</span>
<span class="line" id="L426"></span>
<span class="line" id="L427"><span class="tok-kw">fn</span> <span class="tok-fn">expandStackSize</span>(phdrs: []elf.Phdr) <span class="tok-type">void</span> {</span>
<span class="line" id="L428">    <span class="tok-kw">for</span> (phdrs) |*phdr| {</span>
<span class="line" id="L429">        <span class="tok-kw">switch</span> (phdr.p_type) {</span>
<span class="line" id="L430">            elf.PT_GNU_STACK =&gt; {</span>
<span class="line" id="L431">                <span class="tok-kw">const</span> wanted_stack_size = phdr.p_memsz;</span>
<span class="line" id="L432">                assert(wanted_stack_size % std.mem.page_size == <span class="tok-number">0</span>);</span>
<span class="line" id="L433"></span>
<span class="line" id="L434">                std.os.setrlimit(.STACK, .{</span>
<span class="line" id="L435">                    .cur = wanted_stack_size,</span>
<span class="line" id="L436">                    .max = wanted_stack_size,</span>
<span class="line" id="L437">                }) <span class="tok-kw">catch</span> {</span>
<span class="line" id="L438">                    <span class="tok-comment">// Because we could not increase the stack size to the upper bound,</span>
</span>
<span class="line" id="L439">                    <span class="tok-comment">// depending on what happens at runtime, a stack overflow may occur.</span>
</span>
<span class="line" id="L440">                    <span class="tok-comment">// However it would cause a segmentation fault, thanks to stack probing,</span>
</span>
<span class="line" id="L441">                    <span class="tok-comment">// so we do not have a memory safety issue here.</span>
</span>
<span class="line" id="L442">                    <span class="tok-comment">// This is intentional silent failure.</span>
</span>
<span class="line" id="L443">                    <span class="tok-comment">// This logic should be revisited when the following issues are addressed:</span>
</span>
<span class="line" id="L444">                    <span class="tok-comment">// https://github.com/ziglang/zig/issues/157</span>
</span>
<span class="line" id="L445">                    <span class="tok-comment">// https://github.com/ziglang/zig/issues/1006</span>
</span>
<span class="line" id="L446">                };</span>
<span class="line" id="L447">                <span class="tok-kw">break</span>;</span>
<span class="line" id="L448">            },</span>
<span class="line" id="L449">            <span class="tok-kw">else</span> =&gt; {},</span>
<span class="line" id="L450">        }</span>
<span class="line" id="L451">    }</span>
<span class="line" id="L452">}</span>
<span class="line" id="L453"></span>
<span class="line" id="L454"><span class="tok-kw">fn</span> <span class="tok-fn">callMainWithArgs</span>(argc: <span class="tok-type">usize</span>, argv: [*][*:<span class="tok-number">0</span>]<span class="tok-type">u8</span>, envp: [][*:<span class="tok-number">0</span>]<span class="tok-type">u8</span>) <span class="tok-type">u8</span> {</span>
<span class="line" id="L455">    std.os.argv = argv[<span class="tok-number">0</span>..argc];</span>
<span class="line" id="L456">    std.os.environ = envp;</span>
<span class="line" id="L457"></span>
<span class="line" id="L458">    std.debug.maybeEnableSegfaultHandler();</span>
<span class="line" id="L459"></span>
<span class="line" id="L460">    <span class="tok-kw">return</span> initEventLoopAndCallMain();</span>
<span class="line" id="L461">}</span>
<span class="line" id="L462"></span>
<span class="line" id="L463"><span class="tok-kw">fn</span> <span class="tok-fn">main</span>(c_argc: <span class="tok-type">i32</span>, c_argv: [*][*:<span class="tok-number">0</span>]<span class="tok-type">u8</span>, c_envp: [*:<span class="tok-null">null</span>]?[*:<span class="tok-number">0</span>]<span class="tok-type">u8</span>) <span class="tok-kw">callconv</span>(.C) <span class="tok-type">i32</span> {</span>
<span class="line" id="L464">    <span class="tok-kw">var</span> env_count: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L465">    <span class="tok-kw">while</span> (c_envp[env_count] != <span class="tok-null">null</span>) : (env_count += <span class="tok-number">1</span>) {}</span>
<span class="line" id="L466">    <span class="tok-kw">const</span> envp = <span class="tok-builtin">@ptrCast</span>([*][*:<span class="tok-number">0</span>]<span class="tok-type">u8</span>, c_envp)[<span class="tok-number">0</span>..env_count];</span>
<span class="line" id="L467"></span>
<span class="line" id="L468">    <span class="tok-kw">if</span> (builtin.os.tag == .linux) {</span>
<span class="line" id="L469">        <span class="tok-kw">const</span> at_phdr = std.c.getauxval(elf.AT_PHDR);</span>
<span class="line" id="L470">        <span class="tok-kw">const</span> at_phnum = std.c.getauxval(elf.AT_PHNUM);</span>
<span class="line" id="L471">        <span class="tok-kw">const</span> phdrs = (<span class="tok-builtin">@intToPtr</span>([*]elf.Phdr, at_phdr))[<span class="tok-number">0</span>..at_phnum];</span>
<span class="line" id="L472">        expandStackSize(phdrs);</span>
<span class="line" id="L473">    }</span>
<span class="line" id="L474"></span>
<span class="line" id="L475">    <span class="tok-kw">return</span> <span class="tok-builtin">@call</span>(.{ .modifier = .always_inline }, callMainWithArgs, .{ <span class="tok-builtin">@intCast</span>(<span class="tok-type">usize</span>, c_argc), c_argv, envp });</span>
<span class="line" id="L476">}</span>
<span class="line" id="L477"></span>
<span class="line" id="L478"><span class="tok-kw">fn</span> <span class="tok-fn">mainWithoutEnv</span>(c_argc: <span class="tok-type">i32</span>, c_argv: [*][*:<span class="tok-number">0</span>]<span class="tok-type">u8</span>) <span class="tok-kw">callconv</span>(.C) <span class="tok-type">usize</span> {</span>
<span class="line" id="L479">    std.os.argv = c_argv[<span class="tok-number">0</span>..<span class="tok-builtin">@intCast</span>(<span class="tok-type">usize</span>, c_argc)];</span>
<span class="line" id="L480">    <span class="tok-kw">return</span> <span class="tok-builtin">@call</span>(.{ .modifier = .always_inline }, callMain, .{});</span>
<span class="line" id="L481">}</span>
<span class="line" id="L482"></span>
<span class="line" id="L483"><span class="tok-comment">// General error message for a malformed return type</span>
</span>
<span class="line" id="L484"><span class="tok-kw">const</span> bad_main_ret = <span class="tok-str">&quot;expected return type of main to be 'void', '!void', 'noreturn', 'u8', or '!u8'&quot;</span>;</span>
<span class="line" id="L485"></span>
<span class="line" id="L486"><span class="tok-comment">// This is marked inline because for some reason LLVM in release mode fails to inline it,</span>
</span>
<span class="line" id="L487"><span class="tok-comment">// and we want fewer call frames in stack traces.</span>
</span>
<span class="line" id="L488"><span class="tok-kw">inline</span> <span class="tok-kw">fn</span> <span class="tok-fn">initEventLoopAndCallMain</span>() <span class="tok-type">u8</span> {</span>
<span class="line" id="L489">    <span class="tok-kw">if</span> (std.event.Loop.instance) |loop| {</span>
<span class="line" id="L490">        <span class="tok-kw">if</span> (!<span class="tok-builtin">@hasDecl</span>(root, <span class="tok-str">&quot;event_loop&quot;</span>)) {</span>
<span class="line" id="L491">            loop.init() <span class="tok-kw">catch</span> |err| {</span>
<span class="line" id="L492">                std.log.err(<span class="tok-str">&quot;{s}&quot;</span>, .{<span class="tok-builtin">@errorName</span>(err)});</span>
<span class="line" id="L493">                <span class="tok-kw">if</span> (<span class="tok-builtin">@errorReturnTrace</span>()) |trace| {</span>
<span class="line" id="L494">                    std.debug.dumpStackTrace(trace.*);</span>
<span class="line" id="L495">                }</span>
<span class="line" id="L496">                <span class="tok-kw">return</span> <span class="tok-number">1</span>;</span>
<span class="line" id="L497">            };</span>
<span class="line" id="L498">            <span class="tok-kw">defer</span> loop.deinit();</span>
<span class="line" id="L499"></span>
<span class="line" id="L500">            <span class="tok-kw">var</span> result: <span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L501">            <span class="tok-kw">var</span> frame: <span class="tok-builtin">@Frame</span>(callMainAsync) = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L502">            _ = <span class="tok-builtin">@asyncCall</span>(&amp;frame, &amp;result, callMainAsync, .{loop});</span>
<span class="line" id="L503">            loop.run();</span>
<span class="line" id="L504">            <span class="tok-kw">return</span> result;</span>
<span class="line" id="L505">        }</span>
<span class="line" id="L506">    }</span>
<span class="line" id="L507"></span>
<span class="line" id="L508">    <span class="tok-comment">// This is marked inline because for some reason LLVM in release mode fails to inline it,</span>
</span>
<span class="line" id="L509">    <span class="tok-comment">// and we want fewer call frames in stack traces.</span>
</span>
<span class="line" id="L510">    <span class="tok-kw">return</span> <span class="tok-builtin">@call</span>(.{ .modifier = .always_inline }, callMain, .{});</span>
<span class="line" id="L511">}</span>
<span class="line" id="L512"></span>
<span class="line" id="L513"><span class="tok-comment">// This is marked inline because for some reason LLVM in release mode fails to inline it,</span>
</span>
<span class="line" id="L514"><span class="tok-comment">// and we want fewer call frames in stack traces.</span>
</span>
<span class="line" id="L515"><span class="tok-comment">// TODO This function is duplicated from initEventLoopAndCallMain instead of using generics</span>
</span>
<span class="line" id="L516"><span class="tok-comment">// because it is working around stage1 compiler bugs.</span>
</span>
<span class="line" id="L517"><span class="tok-kw">inline</span> <span class="tok-kw">fn</span> <span class="tok-fn">initEventLoopAndCallWinMain</span>() std.os.windows.INT {</span>
<span class="line" id="L518">    <span class="tok-kw">if</span> (std.event.Loop.instance) |loop| {</span>
<span class="line" id="L519">        <span class="tok-kw">if</span> (!<span class="tok-builtin">@hasDecl</span>(root, <span class="tok-str">&quot;event_loop&quot;</span>)) {</span>
<span class="line" id="L520">            loop.init() <span class="tok-kw">catch</span> |err| {</span>
<span class="line" id="L521">                std.log.err(<span class="tok-str">&quot;{s}&quot;</span>, .{<span class="tok-builtin">@errorName</span>(err)});</span>
<span class="line" id="L522">                <span class="tok-kw">if</span> (<span class="tok-builtin">@errorReturnTrace</span>()) |trace| {</span>
<span class="line" id="L523">                    std.debug.dumpStackTrace(trace.*);</span>
<span class="line" id="L524">                }</span>
<span class="line" id="L525">                <span class="tok-kw">return</span> <span class="tok-number">1</span>;</span>
<span class="line" id="L526">            };</span>
<span class="line" id="L527">            <span class="tok-kw">defer</span> loop.deinit();</span>
<span class="line" id="L528"></span>
<span class="line" id="L529">            <span class="tok-kw">var</span> result: std.os.windows.INT = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L530">            <span class="tok-kw">var</span> frame: <span class="tok-builtin">@Frame</span>(callWinMainAsync) = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L531">            _ = <span class="tok-builtin">@asyncCall</span>(&amp;frame, &amp;result, callWinMainAsync, .{loop});</span>
<span class="line" id="L532">            loop.run();</span>
<span class="line" id="L533">            <span class="tok-kw">return</span> result;</span>
<span class="line" id="L534">        }</span>
<span class="line" id="L535">    }</span>
<span class="line" id="L536"></span>
<span class="line" id="L537">    <span class="tok-comment">// This is marked inline because for some reason LLVM in release mode fails to inline it,</span>
</span>
<span class="line" id="L538">    <span class="tok-comment">// and we want fewer call frames in stack traces.</span>
</span>
<span class="line" id="L539">    <span class="tok-kw">return</span> <span class="tok-builtin">@call</span>(.{ .modifier = .always_inline }, call_wWinMain, .{});</span>
<span class="line" id="L540">}</span>
<span class="line" id="L541"></span>
<span class="line" id="L542"><span class="tok-kw">fn</span> <span class="tok-fn">callMainAsync</span>(loop: *std.event.Loop) <span class="tok-kw">callconv</span>(.Async) <span class="tok-type">u8</span> {</span>
<span class="line" id="L543">    <span class="tok-comment">// This prevents the event loop from terminating at least until main() has returned.</span>
</span>
<span class="line" id="L544">    <span class="tok-comment">// TODO This shouldn't be needed here; it should be in the event loop code.</span>
</span>
<span class="line" id="L545">    loop.beginOneEvent();</span>
<span class="line" id="L546">    <span class="tok-kw">defer</span> loop.finishOneEvent();</span>
<span class="line" id="L547">    <span class="tok-kw">return</span> callMain();</span>
<span class="line" id="L548">}</span>
<span class="line" id="L549"></span>
<span class="line" id="L550"><span class="tok-kw">fn</span> <span class="tok-fn">callWinMainAsync</span>(loop: *std.event.Loop) <span class="tok-kw">callconv</span>(.Async) std.os.windows.INT {</span>
<span class="line" id="L551">    <span class="tok-comment">// This prevents the event loop from terminating at least until main() has returned.</span>
</span>
<span class="line" id="L552">    <span class="tok-comment">// TODO This shouldn't be needed here; it should be in the event loop code.</span>
</span>
<span class="line" id="L553">    loop.beginOneEvent();</span>
<span class="line" id="L554">    <span class="tok-kw">defer</span> loop.finishOneEvent();</span>
<span class="line" id="L555">    <span class="tok-kw">return</span> call_wWinMain();</span>
<span class="line" id="L556">}</span>
<span class="line" id="L557"></span>
<span class="line" id="L558"><span class="tok-comment">// This is not marked inline because it is called with @asyncCall when</span>
</span>
<span class="line" id="L559"><span class="tok-comment">// there is an event loop.</span>
</span>
<span class="line" id="L560"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">callMain</span>() <span class="tok-type">u8</span> {</span>
<span class="line" id="L561">    <span class="tok-kw">switch</span> (<span class="tok-builtin">@typeInfo</span>(<span class="tok-builtin">@typeInfo</span>(<span class="tok-builtin">@TypeOf</span>(root.main)).Fn.return_type.?)) {</span>
<span class="line" id="L562">        .NoReturn =&gt; {</span>
<span class="line" id="L563">            root.main();</span>
<span class="line" id="L564">        },</span>
<span class="line" id="L565">        .Void =&gt; {</span>
<span class="line" id="L566">            root.main();</span>
<span class="line" id="L567">            <span class="tok-kw">return</span> <span class="tok-number">0</span>;</span>
<span class="line" id="L568">        },</span>
<span class="line" id="L569">        .Int =&gt; |info| {</span>
<span class="line" id="L570">            <span class="tok-kw">if</span> (info.bits != <span class="tok-number">8</span> <span class="tok-kw">or</span> info.signedness == .signed) {</span>
<span class="line" id="L571">                <span class="tok-builtin">@compileError</span>(bad_main_ret);</span>
<span class="line" id="L572">            }</span>
<span class="line" id="L573">            <span class="tok-kw">return</span> root.main();</span>
<span class="line" id="L574">        },</span>
<span class="line" id="L575">        .ErrorUnion =&gt; {</span>
<span class="line" id="L576">            <span class="tok-kw">const</span> result = root.main() <span class="tok-kw">catch</span> |err| {</span>
<span class="line" id="L577">                std.log.err(<span class="tok-str">&quot;{s}&quot;</span>, .{<span class="tok-builtin">@errorName</span>(err)});</span>
<span class="line" id="L578">                <span class="tok-kw">if</span> (<span class="tok-builtin">@errorReturnTrace</span>()) |trace| {</span>
<span class="line" id="L579">                    std.debug.dumpStackTrace(trace.*);</span>
<span class="line" id="L580">                }</span>
<span class="line" id="L581">                <span class="tok-kw">return</span> <span class="tok-number">1</span>;</span>
<span class="line" id="L582">            };</span>
<span class="line" id="L583">            <span class="tok-kw">switch</span> (<span class="tok-builtin">@typeInfo</span>(<span class="tok-builtin">@TypeOf</span>(result))) {</span>
<span class="line" id="L584">                .Void =&gt; <span class="tok-kw">return</span> <span class="tok-number">0</span>,</span>
<span class="line" id="L585">                .Int =&gt; |info| {</span>
<span class="line" id="L586">                    <span class="tok-kw">if</span> (info.bits != <span class="tok-number">8</span> <span class="tok-kw">or</span> info.signedness == .signed) {</span>
<span class="line" id="L587">                        <span class="tok-builtin">@compileError</span>(bad_main_ret);</span>
<span class="line" id="L588">                    }</span>
<span class="line" id="L589">                    <span class="tok-kw">return</span> result;</span>
<span class="line" id="L590">                },</span>
<span class="line" id="L591">                <span class="tok-kw">else</span> =&gt; <span class="tok-builtin">@compileError</span>(bad_main_ret),</span>
<span class="line" id="L592">            }</span>
<span class="line" id="L593">        },</span>
<span class="line" id="L594">        <span class="tok-kw">else</span> =&gt; <span class="tok-builtin">@compileError</span>(bad_main_ret),</span>
<span class="line" id="L595">    }</span>
<span class="line" id="L596">}</span>
<span class="line" id="L597"></span>
<span class="line" id="L598"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">call_wWinMain</span>() std.os.windows.INT {</span>
<span class="line" id="L599">    <span class="tok-kw">const</span> MAIN_HINSTANCE = <span class="tok-builtin">@typeInfo</span>(<span class="tok-builtin">@TypeOf</span>(root.wWinMain)).Fn.args[<span class="tok-number">0</span>].arg_type.?;</span>
<span class="line" id="L600">    <span class="tok-kw">const</span> hInstance = <span class="tok-builtin">@ptrCast</span>(MAIN_HINSTANCE, std.os.windows.kernel32.GetModuleHandleW(<span class="tok-null">null</span>).?);</span>
<span class="line" id="L601">    <span class="tok-kw">const</span> lpCmdLine = std.os.windows.kernel32.GetCommandLineW();</span>
<span class="line" id="L602"></span>
<span class="line" id="L603">    <span class="tok-comment">// There's no (documented) way to get the nCmdShow parameter, so we're</span>
</span>
<span class="line" id="L604">    <span class="tok-comment">// using this fairly standard default.</span>
</span>
<span class="line" id="L605">    <span class="tok-kw">const</span> nCmdShow = std.os.windows.user32.SW_SHOW;</span>
<span class="line" id="L606"></span>
<span class="line" id="L607">    <span class="tok-comment">// second parameter hPrevInstance, MSDN: &quot;This parameter is always NULL&quot;</span>
</span>
<span class="line" id="L608">    <span class="tok-kw">return</span> root.wWinMain(hInstance, <span class="tok-null">null</span>, lpCmdLine, nCmdShow);</span>
<span class="line" id="L609">}</span>
<span class="line" id="L610"></span>
</code></pre></body>
</html>