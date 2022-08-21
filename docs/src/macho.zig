<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">    <title>macho.zig - source view</title>
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
<pre><code><span class="line" id="L1"><span class="tok-kw">const</span> std = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;std&quot;</span>);</span>
<span class="line" id="L2"><span class="tok-kw">const</span> builtin = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;builtin&quot;</span>);</span>
<span class="line" id="L3"><span class="tok-kw">const</span> assert = std.debug.assert;</span>
<span class="line" id="L4"><span class="tok-kw">const</span> io = std.io;</span>
<span class="line" id="L5"><span class="tok-kw">const</span> mem = std.mem;</span>
<span class="line" id="L6"><span class="tok-kw">const</span> meta = std.meta;</span>
<span class="line" id="L7"><span class="tok-kw">const</span> testing = std.testing;</span>
<span class="line" id="L8"></span>
<span class="line" id="L9"><span class="tok-kw">const</span> Allocator = mem.Allocator;</span>
<span class="line" id="L10"></span>
<span class="line" id="L11"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> cpu_type_t = <span class="tok-type">c_int</span>;</span>
<span class="line" id="L12"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> cpu_subtype_t = <span class="tok-type">c_int</span>;</span>
<span class="line" id="L13"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> vm_prot_t = <span class="tok-type">c_int</span>;</span>
<span class="line" id="L14"></span>
<span class="line" id="L15"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> mach_header = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L16">    magic: <span class="tok-type">u32</span>,</span>
<span class="line" id="L17">    cputype: cpu_type_t,</span>
<span class="line" id="L18">    cpusubtype: cpu_subtype_t,</span>
<span class="line" id="L19">    filetype: <span class="tok-type">u32</span>,</span>
<span class="line" id="L20">    ncmds: <span class="tok-type">u32</span>,</span>
<span class="line" id="L21">    sizeofcmds: <span class="tok-type">u32</span>,</span>
<span class="line" id="L22">    flags: <span class="tok-type">u32</span>,</span>
<span class="line" id="L23">};</span>
<span class="line" id="L24"></span>
<span class="line" id="L25"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> mach_header_64 = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L26">    magic: <span class="tok-type">u32</span> = MH_MAGIC_64,</span>
<span class="line" id="L27">    cputype: cpu_type_t = <span class="tok-number">0</span>,</span>
<span class="line" id="L28">    cpusubtype: cpu_subtype_t = <span class="tok-number">0</span>,</span>
<span class="line" id="L29">    filetype: <span class="tok-type">u32</span> = <span class="tok-number">0</span>,</span>
<span class="line" id="L30">    ncmds: <span class="tok-type">u32</span> = <span class="tok-number">0</span>,</span>
<span class="line" id="L31">    sizeofcmds: <span class="tok-type">u32</span> = <span class="tok-number">0</span>,</span>
<span class="line" id="L32">    flags: <span class="tok-type">u32</span> = <span class="tok-number">0</span>,</span>
<span class="line" id="L33">    reserved: <span class="tok-type">u32</span> = <span class="tok-number">0</span>,</span>
<span class="line" id="L34">};</span>
<span class="line" id="L35"></span>
<span class="line" id="L36"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> fat_header = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L37">    magic: <span class="tok-type">u32</span>,</span>
<span class="line" id="L38">    nfat_arch: <span class="tok-type">u32</span>,</span>
<span class="line" id="L39">};</span>
<span class="line" id="L40"></span>
<span class="line" id="L41"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> fat_arch = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L42">    cputype: cpu_type_t,</span>
<span class="line" id="L43">    cpusubtype: cpu_subtype_t,</span>
<span class="line" id="L44">    offset: <span class="tok-type">u32</span>,</span>
<span class="line" id="L45">    size: <span class="tok-type">u32</span>,</span>
<span class="line" id="L46">    @&quot;align&quot;: <span class="tok-type">u32</span>,</span>
<span class="line" id="L47">};</span>
<span class="line" id="L48"></span>
<span class="line" id="L49"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> load_command = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L50">    cmd: LC,</span>
<span class="line" id="L51">    cmdsize: <span class="tok-type">u32</span>,</span>
<span class="line" id="L52">};</span>
<span class="line" id="L53"></span>
<span class="line" id="L54"><span class="tok-comment">/// The uuid load command contains a single 128-bit unique random number that</span></span>
<span class="line" id="L55"><span class="tok-comment">/// identifies an object produced by the static link editor.</span></span>
<span class="line" id="L56"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> uuid_command = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L57">    <span class="tok-comment">/// LC_UUID</span></span>
<span class="line" id="L58">    cmd: LC = .UUID,</span>
<span class="line" id="L59"></span>
<span class="line" id="L60">    <span class="tok-comment">/// sizeof(struct uuid_command)</span></span>
<span class="line" id="L61">    cmdsize: <span class="tok-type">u32</span>,</span>
<span class="line" id="L62"></span>
<span class="line" id="L63">    <span class="tok-comment">/// the 128-bit uuid</span></span>
<span class="line" id="L64">    uuid: [<span class="tok-number">16</span>]<span class="tok-type">u8</span>,</span>
<span class="line" id="L65">};</span>
<span class="line" id="L66"></span>
<span class="line" id="L67"><span class="tok-comment">/// The version_min_command contains the min OS version on which this</span></span>
<span class="line" id="L68"><span class="tok-comment">/// binary was built to run.</span></span>
<span class="line" id="L69"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> version_min_command = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L70">    <span class="tok-comment">/// LC_VERSION_MIN_MACOSX or LC_VERSION_MIN_IPHONEOS or LC_VERSION_MIN_WATCHOS or LC_VERSION_MIN_TVOS</span></span>
<span class="line" id="L71">    cmd: LC,</span>
<span class="line" id="L72"></span>
<span class="line" id="L73">    <span class="tok-comment">/// sizeof(struct version_min_command)</span></span>
<span class="line" id="L74">    cmdsize: <span class="tok-type">u32</span>,</span>
<span class="line" id="L75"></span>
<span class="line" id="L76">    <span class="tok-comment">/// X.Y.Z is encoded in nibbles xxxx.yy.zz</span></span>
<span class="line" id="L77">    version: <span class="tok-type">u32</span>,</span>
<span class="line" id="L78"></span>
<span class="line" id="L79">    <span class="tok-comment">/// X.Y.Z is encoded in nibbles xxxx.yy.zz</span></span>
<span class="line" id="L80">    sdk: <span class="tok-type">u32</span>,</span>
<span class="line" id="L81">};</span>
<span class="line" id="L82"></span>
<span class="line" id="L83"><span class="tok-comment">/// The source_version_command is an optional load command containing</span></span>
<span class="line" id="L84"><span class="tok-comment">/// the version of the sources used to build the binary.</span></span>
<span class="line" id="L85"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> source_version_command = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L86">    <span class="tok-comment">/// LC_SOURCE_VERSION</span></span>
<span class="line" id="L87">    cmd: LC = .SOURCE_VERSION,</span>
<span class="line" id="L88"></span>
<span class="line" id="L89">    <span class="tok-comment">/// sizeof(source_version_command)</span></span>
<span class="line" id="L90">    cmdsize: <span class="tok-type">u32</span>,</span>
<span class="line" id="L91"></span>
<span class="line" id="L92">    <span class="tok-comment">/// A.B.C.D.E packed as a24.b10.c10.d10.e10</span></span>
<span class="line" id="L93">    version: <span class="tok-type">u64</span>,</span>
<span class="line" id="L94">};</span>
<span class="line" id="L95"></span>
<span class="line" id="L96"><span class="tok-comment">/// The build_version_command contains the min OS version on which this</span></span>
<span class="line" id="L97"><span class="tok-comment">/// binary was built to run for its platform. The list of known platforms and</span></span>
<span class="line" id="L98"><span class="tok-comment">/// tool values following it.</span></span>
<span class="line" id="L99"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> build_version_command = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L100">    <span class="tok-comment">/// LC_BUILD_VERSION</span></span>
<span class="line" id="L101">    cmd: LC = .BUILD_VERSION,</span>
<span class="line" id="L102"></span>
<span class="line" id="L103">    <span class="tok-comment">/// sizeof(struct build_version_command) plus</span></span>
<span class="line" id="L104">    <span class="tok-comment">/// ntools * sizeof(struct build_version_command)</span></span>
<span class="line" id="L105">    cmdsize: <span class="tok-type">u32</span>,</span>
<span class="line" id="L106"></span>
<span class="line" id="L107">    <span class="tok-comment">/// platform</span></span>
<span class="line" id="L108">    platform: PLATFORM,</span>
<span class="line" id="L109"></span>
<span class="line" id="L110">    <span class="tok-comment">/// X.Y.Z is encoded in nibbles xxxx.yy.zz</span></span>
<span class="line" id="L111">    minos: <span class="tok-type">u32</span>,</span>
<span class="line" id="L112"></span>
<span class="line" id="L113">    <span class="tok-comment">/// X.Y.Z is encoded in nibbles xxxx.yy.zz</span></span>
<span class="line" id="L114">    sdk: <span class="tok-type">u32</span>,</span>
<span class="line" id="L115"></span>
<span class="line" id="L116">    <span class="tok-comment">/// number of tool entries following this</span></span>
<span class="line" id="L117">    ntools: <span class="tok-type">u32</span>,</span>
<span class="line" id="L118">};</span>
<span class="line" id="L119"></span>
<span class="line" id="L120"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> build_tool_version = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L121">    <span class="tok-comment">/// enum for the tool</span></span>
<span class="line" id="L122">    tool: TOOL,</span>
<span class="line" id="L123"></span>
<span class="line" id="L124">    <span class="tok-comment">/// version number of the tool</span></span>
<span class="line" id="L125">    version: <span class="tok-type">u32</span>,</span>
<span class="line" id="L126">};</span>
<span class="line" id="L127"></span>
<span class="line" id="L128"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> PLATFORM = <span class="tok-kw">enum</span>(<span class="tok-type">u32</span>) {</span>
<span class="line" id="L129">    MACOS = <span class="tok-number">0x1</span>,</span>
<span class="line" id="L130">    IOS = <span class="tok-number">0x2</span>,</span>
<span class="line" id="L131">    TVOS = <span class="tok-number">0x3</span>,</span>
<span class="line" id="L132">    WATCHOS = <span class="tok-number">0x4</span>,</span>
<span class="line" id="L133">    BRIDGEOS = <span class="tok-number">0x5</span>,</span>
<span class="line" id="L134">    MACCATALYST = <span class="tok-number">0x6</span>,</span>
<span class="line" id="L135">    IOSSIMULATOR = <span class="tok-number">0x7</span>,</span>
<span class="line" id="L136">    TVOSSIMULATOR = <span class="tok-number">0x8</span>,</span>
<span class="line" id="L137">    WATCHOSSIMULATOR = <span class="tok-number">0x9</span>,</span>
<span class="line" id="L138">    DRIVERKIT = <span class="tok-number">0x10</span>,</span>
<span class="line" id="L139">    _,</span>
<span class="line" id="L140">};</span>
<span class="line" id="L141"></span>
<span class="line" id="L142"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> TOOL = <span class="tok-kw">enum</span>(<span class="tok-type">u32</span>) {</span>
<span class="line" id="L143">    CLANG = <span class="tok-number">0x1</span>,</span>
<span class="line" id="L144">    SWIFT = <span class="tok-number">0x2</span>,</span>
<span class="line" id="L145">    LD = <span class="tok-number">0x3</span>,</span>
<span class="line" id="L146">    _,</span>
<span class="line" id="L147">};</span>
<span class="line" id="L148"></span>
<span class="line" id="L149"><span class="tok-comment">/// The entry_point_command is a replacement for thread_command.</span></span>
<span class="line" id="L150"><span class="tok-comment">/// It is used for main executables to specify the location (file offset)</span></span>
<span class="line" id="L151"><span class="tok-comment">/// of main(). If -stack_size was used at link time, the stacksize</span></span>
<span class="line" id="L152"><span class="tok-comment">/// field will contain the stack size needed for the main thread.</span></span>
<span class="line" id="L153"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> entry_point_command = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L154">    <span class="tok-comment">/// LC_MAIN only used in MH_EXECUTE filetypes</span></span>
<span class="line" id="L155">    cmd: LC = .MAIN,</span>
<span class="line" id="L156"></span>
<span class="line" id="L157">    <span class="tok-comment">/// sizeof(struct entry_point_command)</span></span>
<span class="line" id="L158">    cmdsize: <span class="tok-type">u32</span>,</span>
<span class="line" id="L159"></span>
<span class="line" id="L160">    <span class="tok-comment">/// file (__TEXT) offset of main()</span></span>
<span class="line" id="L161">    entryoff: <span class="tok-type">u64</span>,</span>
<span class="line" id="L162"></span>
<span class="line" id="L163">    <span class="tok-comment">/// if not zero, initial stack size</span></span>
<span class="line" id="L164">    stacksize: <span class="tok-type">u64</span>,</span>
<span class="line" id="L165">};</span>
<span class="line" id="L166"></span>
<span class="line" id="L167"><span class="tok-comment">/// The symtab_command contains the offsets and sizes of the link-edit 4.3BSD</span></span>
<span class="line" id="L168"><span class="tok-comment">/// &quot;stab&quot; style symbol table information as described in the header files</span></span>
<span class="line" id="L169"><span class="tok-comment">/// &lt;nlist.h&gt; and &lt;stab.h&gt;.</span></span>
<span class="line" id="L170"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> symtab_command = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L171">    <span class="tok-comment">/// LC_SYMTAB</span></span>
<span class="line" id="L172">    cmd: LC = .SYMTAB,</span>
<span class="line" id="L173"></span>
<span class="line" id="L174">    <span class="tok-comment">/// sizeof(struct symtab_command)</span></span>
<span class="line" id="L175">    cmdsize: <span class="tok-type">u32</span>,</span>
<span class="line" id="L176"></span>
<span class="line" id="L177">    <span class="tok-comment">/// symbol table offset</span></span>
<span class="line" id="L178">    symoff: <span class="tok-type">u32</span>,</span>
<span class="line" id="L179"></span>
<span class="line" id="L180">    <span class="tok-comment">/// number of symbol table entries</span></span>
<span class="line" id="L181">    nsyms: <span class="tok-type">u32</span>,</span>
<span class="line" id="L182"></span>
<span class="line" id="L183">    <span class="tok-comment">/// string table offset</span></span>
<span class="line" id="L184">    stroff: <span class="tok-type">u32</span>,</span>
<span class="line" id="L185"></span>
<span class="line" id="L186">    <span class="tok-comment">/// string table size in bytes</span></span>
<span class="line" id="L187">    strsize: <span class="tok-type">u32</span>,</span>
<span class="line" id="L188">};</span>
<span class="line" id="L189"></span>
<span class="line" id="L190"><span class="tok-comment">/// This is the second set of the symbolic information which is used to support</span></span>
<span class="line" id="L191"><span class="tok-comment">/// the data structures for the dynamically link editor.</span></span>
<span class="line" id="L192"><span class="tok-comment">///</span></span>
<span class="line" id="L193"><span class="tok-comment">/// The original set of symbolic information in the symtab_command which contains</span></span>
<span class="line" id="L194"><span class="tok-comment">/// the symbol and string tables must also be present when this load command is</span></span>
<span class="line" id="L195"><span class="tok-comment">/// present.  When this load command is present the symbol table is organized</span></span>
<span class="line" id="L196"><span class="tok-comment">/// into three groups of symbols:</span></span>
<span class="line" id="L197"><span class="tok-comment">///  local symbols (static and debugging symbols) - grouped by module</span></span>
<span class="line" id="L198"><span class="tok-comment">///  defined external symbols - grouped by module (sorted by name if not lib)</span></span>
<span class="line" id="L199"><span class="tok-comment">///  undefined external symbols (sorted by name if MH_BINDATLOAD is not set,</span></span>
<span class="line" id="L200"><span class="tok-comment">///       			    and in order the were seen by the static</span></span>
<span class="line" id="L201"><span class="tok-comment">///  			    linker if MH_BINDATLOAD is set)</span></span>
<span class="line" id="L202"><span class="tok-comment">/// In this load command there are offsets and counts to each of the three groups</span></span>
<span class="line" id="L203"><span class="tok-comment">/// of symbols.</span></span>
<span class="line" id="L204"><span class="tok-comment">///</span></span>
<span class="line" id="L205"><span class="tok-comment">/// This load command contains a the offsets and sizes of the following new</span></span>
<span class="line" id="L206"><span class="tok-comment">/// symbolic information tables:</span></span>
<span class="line" id="L207"><span class="tok-comment">///  table of contents</span></span>
<span class="line" id="L208"><span class="tok-comment">///  module table</span></span>
<span class="line" id="L209"><span class="tok-comment">///  reference symbol table</span></span>
<span class="line" id="L210"><span class="tok-comment">///  indirect symbol table</span></span>
<span class="line" id="L211"><span class="tok-comment">/// The first three tables above (the table of contents, module table and</span></span>
<span class="line" id="L212"><span class="tok-comment">/// reference symbol table) are only present if the file is a dynamically linked</span></span>
<span class="line" id="L213"><span class="tok-comment">/// shared library.  For executable and object modules, which are files</span></span>
<span class="line" id="L214"><span class="tok-comment">/// containing only one module, the information that would be in these three</span></span>
<span class="line" id="L215"><span class="tok-comment">/// tables is determined as follows:</span></span>
<span class="line" id="L216"><span class="tok-comment">/// 	table of contents - the defined external symbols are sorted by name</span></span>
<span class="line" id="L217"><span class="tok-comment">///  module table - the file contains only one module so everything in the</span></span>
<span class="line" id="L218"><span class="tok-comment">///  	       file is part of the module.</span></span>
<span class="line" id="L219"><span class="tok-comment">///  reference symbol table - is the defined and undefined external symbols</span></span>
<span class="line" id="L220"><span class="tok-comment">///</span></span>
<span class="line" id="L221"><span class="tok-comment">/// For dynamically linked shared library files this load command also contains</span></span>
<span class="line" id="L222"><span class="tok-comment">/// offsets and sizes to the pool of relocation entries for all sections</span></span>
<span class="line" id="L223"><span class="tok-comment">/// separated into two groups:</span></span>
<span class="line" id="L224"><span class="tok-comment">///  external relocation entries</span></span>
<span class="line" id="L225"><span class="tok-comment">///  local relocation entries</span></span>
<span class="line" id="L226"><span class="tok-comment">/// For executable and object modules the relocation entries continue to hang</span></span>
<span class="line" id="L227"><span class="tok-comment">/// off the section structures.</span></span>
<span class="line" id="L228"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> dysymtab_command = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L229">    <span class="tok-comment">/// LC_DYSYMTAB</span></span>
<span class="line" id="L230">    cmd: LC = .DYSYMTAB,</span>
<span class="line" id="L231"></span>
<span class="line" id="L232">    <span class="tok-comment">/// sizeof(struct dysymtab_command)</span></span>
<span class="line" id="L233">    cmdsize: <span class="tok-type">u32</span>,</span>
<span class="line" id="L234"></span>
<span class="line" id="L235">    <span class="tok-comment">// The symbols indicated by symoff and nsyms of the LC_SYMTAB load command</span>
</span>
<span class="line" id="L236">    <span class="tok-comment">// are grouped into the following three groups:</span>
</span>
<span class="line" id="L237">    <span class="tok-comment">//    local symbols (further grouped by the module they are from)</span>
</span>
<span class="line" id="L238">    <span class="tok-comment">//    defined external symbols (further grouped by the module they are from)</span>
</span>
<span class="line" id="L239">    <span class="tok-comment">//    undefined symbols</span>
</span>
<span class="line" id="L240">    <span class="tok-comment">//</span>
</span>
<span class="line" id="L241">    <span class="tok-comment">// The local symbols are used only for debugging.  The dynamic binding</span>
</span>
<span class="line" id="L242">    <span class="tok-comment">// process may have to use them to indicate to the debugger the local</span>
</span>
<span class="line" id="L243">    <span class="tok-comment">// symbols for a module that is being bound.</span>
</span>
<span class="line" id="L244">    <span class="tok-comment">//</span>
</span>
<span class="line" id="L245">    <span class="tok-comment">// The last two groups are used by the dynamic binding process to do the</span>
</span>
<span class="line" id="L246">    <span class="tok-comment">// binding (indirectly through the module table and the reference symbol</span>
</span>
<span class="line" id="L247">    <span class="tok-comment">// table when this is a dynamically linked shared library file).</span>
</span>
<span class="line" id="L248"></span>
<span class="line" id="L249">    <span class="tok-comment">/// index of local symbols</span></span>
<span class="line" id="L250">    ilocalsym: <span class="tok-type">u32</span>,</span>
<span class="line" id="L251"></span>
<span class="line" id="L252">    <span class="tok-comment">/// number of local symbols</span></span>
<span class="line" id="L253">    nlocalsym: <span class="tok-type">u32</span>,</span>
<span class="line" id="L254"></span>
<span class="line" id="L255">    <span class="tok-comment">/// index to externally defined symbols</span></span>
<span class="line" id="L256">    iextdefsym: <span class="tok-type">u32</span>,</span>
<span class="line" id="L257"></span>
<span class="line" id="L258">    <span class="tok-comment">/// number of externally defined symbols</span></span>
<span class="line" id="L259">    nextdefsym: <span class="tok-type">u32</span>,</span>
<span class="line" id="L260"></span>
<span class="line" id="L261">    <span class="tok-comment">/// index to undefined symbols</span></span>
<span class="line" id="L262">    iundefsym: <span class="tok-type">u32</span>,</span>
<span class="line" id="L263"></span>
<span class="line" id="L264">    <span class="tok-comment">/// number of undefined symbols</span></span>
<span class="line" id="L265">    nundefsym: <span class="tok-type">u32</span>,</span>
<span class="line" id="L266"></span>
<span class="line" id="L267">    <span class="tok-comment">// For the for the dynamic binding process to find which module a symbol</span>
</span>
<span class="line" id="L268">    <span class="tok-comment">// is defined in the table of contents is used (analogous to the ranlib</span>
</span>
<span class="line" id="L269">    <span class="tok-comment">// structure in an archive) which maps defined external symbols to modules</span>
</span>
<span class="line" id="L270">    <span class="tok-comment">// they are defined in.  This exists only in a dynamically linked shared</span>
</span>
<span class="line" id="L271">    <span class="tok-comment">// library file.  For executable and object modules the defined external</span>
</span>
<span class="line" id="L272">    <span class="tok-comment">// symbols are sorted by name and is use as the table of contents.</span>
</span>
<span class="line" id="L273"></span>
<span class="line" id="L274">    <span class="tok-comment">/// file offset to table of contents</span></span>
<span class="line" id="L275">    tocoff: <span class="tok-type">u32</span>,</span>
<span class="line" id="L276"></span>
<span class="line" id="L277">    <span class="tok-comment">/// number of entries in table of contents</span></span>
<span class="line" id="L278">    ntoc: <span class="tok-type">u32</span>,</span>
<span class="line" id="L279"></span>
<span class="line" id="L280">    <span class="tok-comment">// To support dynamic binding of &quot;modules&quot; (whole object files) the symbol</span>
</span>
<span class="line" id="L281">    <span class="tok-comment">// table must reflect the modules that the file was created from.  This is</span>
</span>
<span class="line" id="L282">    <span class="tok-comment">// done by having a module table that has indexes and counts into the merged</span>
</span>
<span class="line" id="L283">    <span class="tok-comment">// tables for each module.  The module structure that these two entries</span>
</span>
<span class="line" id="L284">    <span class="tok-comment">// refer to is described below.  This exists only in a dynamically linked</span>
</span>
<span class="line" id="L285">    <span class="tok-comment">// shared library file.  For executable and object modules the file only</span>
</span>
<span class="line" id="L286">    <span class="tok-comment">// contains one module so everything in the file belongs to the module.</span>
</span>
<span class="line" id="L287"></span>
<span class="line" id="L288">    <span class="tok-comment">/// file offset to module table</span></span>
<span class="line" id="L289">    modtaboff: <span class="tok-type">u32</span>,</span>
<span class="line" id="L290"></span>
<span class="line" id="L291">    <span class="tok-comment">/// number of module table entries</span></span>
<span class="line" id="L292">    nmodtab: <span class="tok-type">u32</span>,</span>
<span class="line" id="L293"></span>
<span class="line" id="L294">    <span class="tok-comment">// To support dynamic module binding the module structure for each module</span>
</span>
<span class="line" id="L295">    <span class="tok-comment">// indicates the external references (defined and undefined) each module</span>
</span>
<span class="line" id="L296">    <span class="tok-comment">// makes.  For each module there is an offset and a count into the</span>
</span>
<span class="line" id="L297">    <span class="tok-comment">// reference symbol table for the symbols that the module references.</span>
</span>
<span class="line" id="L298">    <span class="tok-comment">// This exists only in a dynamically linked shared library file.  For</span>
</span>
<span class="line" id="L299">    <span class="tok-comment">// executable and object modules the defined external symbols and the</span>
</span>
<span class="line" id="L300">    <span class="tok-comment">// undefined external symbols indicates the external references.</span>
</span>
<span class="line" id="L301"></span>
<span class="line" id="L302">    <span class="tok-comment">/// offset to referenced symbol table</span></span>
<span class="line" id="L303">    extrefsymoff: <span class="tok-type">u32</span>,</span>
<span class="line" id="L304"></span>
<span class="line" id="L305">    <span class="tok-comment">/// number of referenced symbol table entries</span></span>
<span class="line" id="L306">    nextrefsyms: <span class="tok-type">u32</span>,</span>
<span class="line" id="L307"></span>
<span class="line" id="L308">    <span class="tok-comment">// The sections that contain &quot;symbol pointers&quot; and &quot;routine stubs&quot; have</span>
</span>
<span class="line" id="L309">    <span class="tok-comment">// indexes and (implied counts based on the size of the section and fixed</span>
</span>
<span class="line" id="L310">    <span class="tok-comment">// size of the entry) into the &quot;indirect symbol&quot; table for each pointer</span>
</span>
<span class="line" id="L311">    <span class="tok-comment">// and stub.  For every section of these two types the index into the</span>
</span>
<span class="line" id="L312">    <span class="tok-comment">// indirect symbol table is stored in the section header in the field</span>
</span>
<span class="line" id="L313">    <span class="tok-comment">// reserved1.  An indirect symbol table entry is simply a 32bit index into</span>
</span>
<span class="line" id="L314">    <span class="tok-comment">// the symbol table to the symbol that the pointer or stub is referring to.</span>
</span>
<span class="line" id="L315">    <span class="tok-comment">// The indirect symbol table is ordered to match the entries in the section.</span>
</span>
<span class="line" id="L316"></span>
<span class="line" id="L317">    <span class="tok-comment">/// file offset to the indirect symbol table</span></span>
<span class="line" id="L318">    indirectsymoff: <span class="tok-type">u32</span>,</span>
<span class="line" id="L319"></span>
<span class="line" id="L320">    <span class="tok-comment">/// number of indirect symbol table entries</span></span>
<span class="line" id="L321">    nindirectsyms: <span class="tok-type">u32</span>,</span>
<span class="line" id="L322"></span>
<span class="line" id="L323">    <span class="tok-comment">// To support relocating an individual module in a library file quickly the</span>
</span>
<span class="line" id="L324">    <span class="tok-comment">// external relocation entries for each module in the library need to be</span>
</span>
<span class="line" id="L325">    <span class="tok-comment">// accessed efficiently.  Since the relocation entries can't be accessed</span>
</span>
<span class="line" id="L326">    <span class="tok-comment">// through the section headers for a library file they are separated into</span>
</span>
<span class="line" id="L327">    <span class="tok-comment">// groups of local and external entries further grouped by module.  In this</span>
</span>
<span class="line" id="L328">    <span class="tok-comment">// case the presents of this load command who's extreloff, nextrel,</span>
</span>
<span class="line" id="L329">    <span class="tok-comment">// locreloff and nlocrel fields are non-zero indicates that the relocation</span>
</span>
<span class="line" id="L330">    <span class="tok-comment">// entries of non-merged sections are not referenced through the section</span>
</span>
<span class="line" id="L331">    <span class="tok-comment">// structures (and the reloff and nreloc fields in the section headers are</span>
</span>
<span class="line" id="L332">    <span class="tok-comment">// set to zero).</span>
</span>
<span class="line" id="L333">    <span class="tok-comment">//</span>
</span>
<span class="line" id="L334">    <span class="tok-comment">// Since the relocation entries are not accessed through the section headers</span>
</span>
<span class="line" id="L335">    <span class="tok-comment">// this requires the r_address field to be something other than a section</span>
</span>
<span class="line" id="L336">    <span class="tok-comment">// offset to identify the item to be relocated.  In this case r_address is</span>
</span>
<span class="line" id="L337">    <span class="tok-comment">// set to the offset from the vmaddr of the first LC_SEGMENT command.</span>
</span>
<span class="line" id="L338">    <span class="tok-comment">// For MH_SPLIT_SEGS images r_address is set to the the offset from the</span>
</span>
<span class="line" id="L339">    <span class="tok-comment">// vmaddr of the first read-write LC_SEGMENT command.</span>
</span>
<span class="line" id="L340">    <span class="tok-comment">//</span>
</span>
<span class="line" id="L341">    <span class="tok-comment">// The relocation entries are grouped by module and the module table</span>
</span>
<span class="line" id="L342">    <span class="tok-comment">// entries have indexes and counts into them for the group of external</span>
</span>
<span class="line" id="L343">    <span class="tok-comment">// relocation entries for that the module.</span>
</span>
<span class="line" id="L344">    <span class="tok-comment">//</span>
</span>
<span class="line" id="L345">    <span class="tok-comment">// For sections that are merged across modules there must not be any</span>
</span>
<span class="line" id="L346">    <span class="tok-comment">// remaining external relocation entries for them (for merged sections</span>
</span>
<span class="line" id="L347">    <span class="tok-comment">// remaining relocation entries must be local).</span>
</span>
<span class="line" id="L348"></span>
<span class="line" id="L349">    <span class="tok-comment">/// offset to external relocation entries</span></span>
<span class="line" id="L350">    extreloff: <span class="tok-type">u32</span>,</span>
<span class="line" id="L351"></span>
<span class="line" id="L352">    <span class="tok-comment">/// number of external relocation entries</span></span>
<span class="line" id="L353">    nextrel: <span class="tok-type">u32</span>,</span>
<span class="line" id="L354"></span>
<span class="line" id="L355">    <span class="tok-comment">// All the local relocation entries are grouped together (they are not</span>
</span>
<span class="line" id="L356">    <span class="tok-comment">// grouped by their module since they are only used if the object is moved</span>
</span>
<span class="line" id="L357">    <span class="tok-comment">// from it staticly link edited address).</span>
</span>
<span class="line" id="L358"></span>
<span class="line" id="L359">    <span class="tok-comment">/// offset to local relocation entries</span></span>
<span class="line" id="L360">    locreloff: <span class="tok-type">u32</span>,</span>
<span class="line" id="L361"></span>
<span class="line" id="L362">    <span class="tok-comment">/// number of local relocation entries</span></span>
<span class="line" id="L363">    nlocrel: <span class="tok-type">u32</span>,</span>
<span class="line" id="L364">};</span>
<span class="line" id="L365"></span>
<span class="line" id="L366"><span class="tok-comment">/// The linkedit_data_command contains the offsets and sizes of a blob</span></span>
<span class="line" id="L367"><span class="tok-comment">/// of data in the __LINKEDIT segment.</span></span>
<span class="line" id="L368"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> linkedit_data_command = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L369">    <span class="tok-comment">/// LC_CODE_SIGNATURE, LC_SEGMENT_SPLIT_INFO, LC_FUNCTION_STARTS, LC_DATA_IN_CODE, LC_DYLIB_CODE_SIGN_DRS or LC_LINKER_OPTIMIZATION_HINT.</span></span>
<span class="line" id="L370">    cmd: LC,</span>
<span class="line" id="L371"></span>
<span class="line" id="L372">    <span class="tok-comment">/// sizeof(struct linkedit_data_command)</span></span>
<span class="line" id="L373">    cmdsize: <span class="tok-type">u32</span>,</span>
<span class="line" id="L374"></span>
<span class="line" id="L375">    <span class="tok-comment">/// file offset of data in __LINKEDIT segment</span></span>
<span class="line" id="L376">    dataoff: <span class="tok-type">u32</span>,</span>
<span class="line" id="L377"></span>
<span class="line" id="L378">    <span class="tok-comment">/// file size of data in __LINKEDIT segment</span></span>
<span class="line" id="L379">    datasize: <span class="tok-type">u32</span>,</span>
<span class="line" id="L380">};</span>
<span class="line" id="L381"></span>
<span class="line" id="L382"><span class="tok-comment">/// The dyld_info_command contains the file offsets and sizes of</span></span>
<span class="line" id="L383"><span class="tok-comment">/// the new compressed form of the information dyld needs to</span></span>
<span class="line" id="L384"><span class="tok-comment">/// load the image.  This information is used by dyld on Mac OS X</span></span>
<span class="line" id="L385"><span class="tok-comment">/// 10.6 and later.  All information pointed to by this command</span></span>
<span class="line" id="L386"><span class="tok-comment">/// is encoded using byte streams, so no endian swapping is needed</span></span>
<span class="line" id="L387"><span class="tok-comment">/// to interpret it.</span></span>
<span class="line" id="L388"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> dyld_info_command = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L389">    <span class="tok-comment">/// LC_DYLD_INFO or LC_DYLD_INFO_ONLY</span></span>
<span class="line" id="L390">    cmd: LC,</span>
<span class="line" id="L391"></span>
<span class="line" id="L392">    <span class="tok-comment">/// sizeof(struct dyld_info_command)</span></span>
<span class="line" id="L393">    cmdsize: <span class="tok-type">u32</span>,</span>
<span class="line" id="L394"></span>
<span class="line" id="L395">    <span class="tok-comment">// Dyld rebases an image whenever dyld loads it at an address different</span>
</span>
<span class="line" id="L396">    <span class="tok-comment">// from its preferred address.  The rebase information is a stream</span>
</span>
<span class="line" id="L397">    <span class="tok-comment">// of byte sized opcodes whose symbolic names start with REBASE_OPCODE_.</span>
</span>
<span class="line" id="L398">    <span class="tok-comment">// Conceptually the rebase information is a table of tuples:</span>
</span>
<span class="line" id="L399">    <span class="tok-comment">//    &lt;seg-index, seg-offset, type&gt;</span>
</span>
<span class="line" id="L400">    <span class="tok-comment">// The opcodes are a compressed way to encode the table by only</span>
</span>
<span class="line" id="L401">    <span class="tok-comment">// encoding when a column changes.  In addition simple patterns</span>
</span>
<span class="line" id="L402">    <span class="tok-comment">// like &quot;every n'th offset for m times&quot; can be encoded in a few</span>
</span>
<span class="line" id="L403">    <span class="tok-comment">// bytes.</span>
</span>
<span class="line" id="L404"></span>
<span class="line" id="L405">    <span class="tok-comment">/// file offset to rebase info</span></span>
<span class="line" id="L406">    rebase_off: <span class="tok-type">u32</span>,</span>
<span class="line" id="L407"></span>
<span class="line" id="L408">    <span class="tok-comment">/// size of rebase info</span></span>
<span class="line" id="L409">    rebase_size: <span class="tok-type">u32</span>,</span>
<span class="line" id="L410"></span>
<span class="line" id="L411">    <span class="tok-comment">// Dyld binds an image during the loading process, if the image</span>
</span>
<span class="line" id="L412">    <span class="tok-comment">// requires any pointers to be initialized to symbols in other images.</span>
</span>
<span class="line" id="L413">    <span class="tok-comment">// The bind information is a stream of byte sized</span>
</span>
<span class="line" id="L414">    <span class="tok-comment">// opcodes whose symbolic names start with BIND_OPCODE_.</span>
</span>
<span class="line" id="L415">    <span class="tok-comment">// Conceptually the bind information is a table of tuples:</span>
</span>
<span class="line" id="L416">    <span class="tok-comment">//    &lt;seg-index, seg-offset, type, symbol-library-ordinal, symbol-name, addend&gt;</span>
</span>
<span class="line" id="L417">    <span class="tok-comment">// The opcodes are a compressed way to encode the table by only</span>
</span>
<span class="line" id="L418">    <span class="tok-comment">// encoding when a column changes.  In addition simple patterns</span>
</span>
<span class="line" id="L419">    <span class="tok-comment">// like for runs of pointers initialzed to the same value can be</span>
</span>
<span class="line" id="L420">    <span class="tok-comment">// encoded in a few bytes.</span>
</span>
<span class="line" id="L421"></span>
<span class="line" id="L422">    <span class="tok-comment">/// file offset to binding info</span></span>
<span class="line" id="L423">    bind_off: <span class="tok-type">u32</span>,</span>
<span class="line" id="L424"></span>
<span class="line" id="L425">    <span class="tok-comment">/// size of binding info</span></span>
<span class="line" id="L426">    bind_size: <span class="tok-type">u32</span>,</span>
<span class="line" id="L427"></span>
<span class="line" id="L428">    <span class="tok-comment">// Some C++ programs require dyld to unique symbols so that all</span>
</span>
<span class="line" id="L429">    <span class="tok-comment">// images in the process use the same copy of some code/data.</span>
</span>
<span class="line" id="L430">    <span class="tok-comment">// This step is done after binding. The content of the weak_bind</span>
</span>
<span class="line" id="L431">    <span class="tok-comment">// info is an opcode stream like the bind_info.  But it is sorted</span>
</span>
<span class="line" id="L432">    <span class="tok-comment">// alphabetically by symbol name.  This enable dyld to walk</span>
</span>
<span class="line" id="L433">    <span class="tok-comment">// all images with weak binding information in order and look</span>
</span>
<span class="line" id="L434">    <span class="tok-comment">// for collisions.  If there are no collisions, dyld does</span>
</span>
<span class="line" id="L435">    <span class="tok-comment">// no updating.  That means that some fixups are also encoded</span>
</span>
<span class="line" id="L436">    <span class="tok-comment">// in the bind_info.  For instance, all calls to &quot;operator new&quot;</span>
</span>
<span class="line" id="L437">    <span class="tok-comment">// are first bound to libstdc++.dylib using the information</span>
</span>
<span class="line" id="L438">    <span class="tok-comment">// in bind_info.  Then if some image overrides operator new</span>
</span>
<span class="line" id="L439">    <span class="tok-comment">// that is detected when the weak_bind information is processed</span>
</span>
<span class="line" id="L440">    <span class="tok-comment">// and the call to operator new is then rebound.</span>
</span>
<span class="line" id="L441"></span>
<span class="line" id="L442">    <span class="tok-comment">/// file offset to weak binding info</span></span>
<span class="line" id="L443">    weak_bind_off: <span class="tok-type">u32</span>,</span>
<span class="line" id="L444"></span>
<span class="line" id="L445">    <span class="tok-comment">/// size of weak binding info</span></span>
<span class="line" id="L446">    weak_bind_size: <span class="tok-type">u32</span>,</span>
<span class="line" id="L447"></span>
<span class="line" id="L448">    <span class="tok-comment">// Some uses of external symbols do not need to be bound immediately.</span>
</span>
<span class="line" id="L449">    <span class="tok-comment">// Instead they can be lazily bound on first use.  The lazy_bind</span>
</span>
<span class="line" id="L450">    <span class="tok-comment">// are contains a stream of BIND opcodes to bind all lazy symbols.</span>
</span>
<span class="line" id="L451">    <span class="tok-comment">// Normal use is that dyld ignores the lazy_bind section when</span>
</span>
<span class="line" id="L452">    <span class="tok-comment">// loading an image.  Instead the static linker arranged for the</span>
</span>
<span class="line" id="L453">    <span class="tok-comment">// lazy pointer to initially point to a helper function which</span>
</span>
<span class="line" id="L454">    <span class="tok-comment">// pushes the offset into the lazy_bind area for the symbol</span>
</span>
<span class="line" id="L455">    <span class="tok-comment">// needing to be bound, then jumps to dyld which simply adds</span>
</span>
<span class="line" id="L456">    <span class="tok-comment">// the offset to lazy_bind_off to get the information on what</span>
</span>
<span class="line" id="L457">    <span class="tok-comment">// to bind.</span>
</span>
<span class="line" id="L458"></span>
<span class="line" id="L459">    <span class="tok-comment">/// file offset to lazy binding info</span></span>
<span class="line" id="L460">    lazy_bind_off: <span class="tok-type">u32</span>,</span>
<span class="line" id="L461"></span>
<span class="line" id="L462">    <span class="tok-comment">/// size of lazy binding info</span></span>
<span class="line" id="L463">    lazy_bind_size: <span class="tok-type">u32</span>,</span>
<span class="line" id="L464"></span>
<span class="line" id="L465">    <span class="tok-comment">// The symbols exported by a dylib are encoded in a trie.  This</span>
</span>
<span class="line" id="L466">    <span class="tok-comment">// is a compact representation that factors out common prefixes.</span>
</span>
<span class="line" id="L467">    <span class="tok-comment">// It also reduces LINKEDIT pages in RAM because it encodes all</span>
</span>
<span class="line" id="L468">    <span class="tok-comment">// information (name, address, flags) in one small, contiguous range.</span>
</span>
<span class="line" id="L469">    <span class="tok-comment">// The export area is a stream of nodes.  The first node sequentially</span>
</span>
<span class="line" id="L470">    <span class="tok-comment">// is the start node for the trie.</span>
</span>
<span class="line" id="L471">    <span class="tok-comment">//</span>
</span>
<span class="line" id="L472">    <span class="tok-comment">// Nodes for a symbol start with a uleb128 that is the length of</span>
</span>
<span class="line" id="L473">    <span class="tok-comment">// the exported symbol information for the string so far.</span>
</span>
<span class="line" id="L474">    <span class="tok-comment">// If there is no exported symbol, the node starts with a zero byte.</span>
</span>
<span class="line" id="L475">    <span class="tok-comment">// If there is exported info, it follows the length.</span>
</span>
<span class="line" id="L476">    <span class="tok-comment">//</span>
</span>
<span class="line" id="L477">    <span class="tok-comment">// First is a uleb128 containing flags. Normally, it is followed by</span>
</span>
<span class="line" id="L478">    <span class="tok-comment">// a uleb128 encoded offset which is location of the content named</span>
</span>
<span class="line" id="L479">    <span class="tok-comment">// by the symbol from the mach_header for the image.  If the flags</span>
</span>
<span class="line" id="L480">    <span class="tok-comment">// is EXPORT_SYMBOL_FLAGS_REEXPORT, then following the flags is</span>
</span>
<span class="line" id="L481">    <span class="tok-comment">// a uleb128 encoded library ordinal, then a zero terminated</span>
</span>
<span class="line" id="L482">    <span class="tok-comment">// UTF8 string.  If the string is zero length, then the symbol</span>
</span>
<span class="line" id="L483">    <span class="tok-comment">// is re-export from the specified dylib with the same name.</span>
</span>
<span class="line" id="L484">    <span class="tok-comment">// If the flags is EXPORT_SYMBOL_FLAGS_STUB_AND_RESOLVER, then following</span>
</span>
<span class="line" id="L485">    <span class="tok-comment">// the flags is two uleb128s: the stub offset and the resolver offset.</span>
</span>
<span class="line" id="L486">    <span class="tok-comment">// The stub is used by non-lazy pointers.  The resolver is used</span>
</span>
<span class="line" id="L487">    <span class="tok-comment">// by lazy pointers and must be called to get the actual address to use.</span>
</span>
<span class="line" id="L488">    <span class="tok-comment">//</span>
</span>
<span class="line" id="L489">    <span class="tok-comment">// After the optional exported symbol information is a byte of</span>
</span>
<span class="line" id="L490">    <span class="tok-comment">// how many edges (0-255) that this node has leaving it,</span>
</span>
<span class="line" id="L491">    <span class="tok-comment">// followed by each edge.</span>
</span>
<span class="line" id="L492">    <span class="tok-comment">// Each edge is a zero terminated UTF8 of the addition chars</span>
</span>
<span class="line" id="L493">    <span class="tok-comment">// in the symbol, followed by a uleb128 offset for the node that</span>
</span>
<span class="line" id="L494">    <span class="tok-comment">// edge points to.</span>
</span>
<span class="line" id="L495"></span>
<span class="line" id="L496">    <span class="tok-comment">/// file offset to lazy binding info</span></span>
<span class="line" id="L497">    export_off: <span class="tok-type">u32</span>,</span>
<span class="line" id="L498"></span>
<span class="line" id="L499">    <span class="tok-comment">/// size of lazy binding info</span></span>
<span class="line" id="L500">    export_size: <span class="tok-type">u32</span>,</span>
<span class="line" id="L501">};</span>
<span class="line" id="L502"></span>
<span class="line" id="L503"><span class="tok-comment">/// A program that uses a dynamic linker contains a dylinker_command to identify</span></span>
<span class="line" id="L504"><span class="tok-comment">/// the name of the dynamic linker (LC_LOAD_DYLINKER). And a dynamic linker</span></span>
<span class="line" id="L505"><span class="tok-comment">/// contains a dylinker_command to identify the dynamic linker (LC_ID_DYLINKER).</span></span>
<span class="line" id="L506"><span class="tok-comment">/// A file can have at most one of these.</span></span>
<span class="line" id="L507"><span class="tok-comment">/// This struct is also used for the LC_DYLD_ENVIRONMENT load command and contains</span></span>
<span class="line" id="L508"><span class="tok-comment">/// string for dyld to treat like an environment variable.</span></span>
<span class="line" id="L509"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> dylinker_command = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L510">    <span class="tok-comment">/// LC_ID_DYLINKER, LC_LOAD_DYLINKER, or LC_DYLD_ENVIRONMENT</span></span>
<span class="line" id="L511">    cmd: LC,</span>
<span class="line" id="L512"></span>
<span class="line" id="L513">    <span class="tok-comment">/// includes pathname string</span></span>
<span class="line" id="L514">    cmdsize: <span class="tok-type">u32</span>,</span>
<span class="line" id="L515"></span>
<span class="line" id="L516">    <span class="tok-comment">/// A variable length string in a load command is represented by an lc_str</span></span>
<span class="line" id="L517">    <span class="tok-comment">/// union.  The strings are stored just after the load command structure and</span></span>
<span class="line" id="L518">    <span class="tok-comment">/// the offset is from the start of the load command structure.  The size</span></span>
<span class="line" id="L519">    <span class="tok-comment">/// of the string is reflected in the cmdsize field of the load command.</span></span>
<span class="line" id="L520">    <span class="tok-comment">/// Once again any padded bytes to bring the cmdsize field to a multiple</span></span>
<span class="line" id="L521">    <span class="tok-comment">/// of 4 bytes must be zero.</span></span>
<span class="line" id="L522">    name: <span class="tok-type">u32</span>,</span>
<span class="line" id="L523">};</span>
<span class="line" id="L524"></span>
<span class="line" id="L525"><span class="tok-comment">/// A dynamically linked shared library (filetype == MH_DYLIB in the mach header)</span></span>
<span class="line" id="L526"><span class="tok-comment">/// contains a dylib_command (cmd == LC_ID_DYLIB) to identify the library.</span></span>
<span class="line" id="L527"><span class="tok-comment">/// An object that uses a dynamically linked shared library also contains a</span></span>
<span class="line" id="L528"><span class="tok-comment">/// dylib_command (cmd == LC_LOAD_DYLIB, LC_LOAD_WEAK_DYLIB, or</span></span>
<span class="line" id="L529"><span class="tok-comment">/// LC_REEXPORT_DYLIB) for each library it uses.</span></span>
<span class="line" id="L530"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> dylib_command = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L531">    <span class="tok-comment">/// LC_ID_DYLIB, LC_LOAD_WEAK_DYLIB, LC_LOAD_DYLIB, LC_REEXPORT_DYLIB</span></span>
<span class="line" id="L532">    cmd: LC,</span>
<span class="line" id="L533"></span>
<span class="line" id="L534">    <span class="tok-comment">/// includes pathname string</span></span>
<span class="line" id="L535">    cmdsize: <span class="tok-type">u32</span>,</span>
<span class="line" id="L536"></span>
<span class="line" id="L537">    <span class="tok-comment">/// the library identification</span></span>
<span class="line" id="L538">    dylib: dylib,</span>
<span class="line" id="L539">};</span>
<span class="line" id="L540"></span>
<span class="line" id="L541"><span class="tok-comment">/// Dynamicaly linked shared libraries are identified by two things.  The</span></span>
<span class="line" id="L542"><span class="tok-comment">/// pathname (the name of the library as found for execution), and the</span></span>
<span class="line" id="L543"><span class="tok-comment">/// compatibility version number.  The pathname must match and the compatibility</span></span>
<span class="line" id="L544"><span class="tok-comment">/// number in the user of the library must be greater than or equal to the</span></span>
<span class="line" id="L545"><span class="tok-comment">/// library being used.  The time stamp is used to record the time a library was</span></span>
<span class="line" id="L546"><span class="tok-comment">/// built and copied into user so it can be use to determined if the library used</span></span>
<span class="line" id="L547"><span class="tok-comment">/// at runtime is exactly the same as used to built the program.</span></span>
<span class="line" id="L548"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> dylib = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L549">    <span class="tok-comment">/// library's pathname (offset pointing at the end of dylib_command)</span></span>
<span class="line" id="L550">    name: <span class="tok-type">u32</span>,</span>
<span class="line" id="L551"></span>
<span class="line" id="L552">    <span class="tok-comment">/// library's build timestamp</span></span>
<span class="line" id="L553">    timestamp: <span class="tok-type">u32</span>,</span>
<span class="line" id="L554"></span>
<span class="line" id="L555">    <span class="tok-comment">/// library's current version number</span></span>
<span class="line" id="L556">    current_version: <span class="tok-type">u32</span>,</span>
<span class="line" id="L557"></span>
<span class="line" id="L558">    <span class="tok-comment">/// library's compatibility version number</span></span>
<span class="line" id="L559">    compatibility_version: <span class="tok-type">u32</span>,</span>
<span class="line" id="L560">};</span>
<span class="line" id="L561"></span>
<span class="line" id="L562"><span class="tok-comment">/// The rpath_command contains a path which at runtime should be added to the current</span></span>
<span class="line" id="L563"><span class="tok-comment">/// run path used to find @rpath prefixed dylibs.</span></span>
<span class="line" id="L564"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> rpath_command = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L565">    <span class="tok-comment">/// LC_RPATH</span></span>
<span class="line" id="L566">    cmd: LC = .RPATH,</span>
<span class="line" id="L567"></span>
<span class="line" id="L568">    <span class="tok-comment">/// includes string</span></span>
<span class="line" id="L569">    cmdsize: <span class="tok-type">u32</span>,</span>
<span class="line" id="L570"></span>
<span class="line" id="L571">    <span class="tok-comment">/// path to add to run path</span></span>
<span class="line" id="L572">    path: <span class="tok-type">u32</span>,</span>
<span class="line" id="L573">};</span>
<span class="line" id="L574"></span>
<span class="line" id="L575"><span class="tok-comment">/// The segment load command indicates that a part of this file is to be</span></span>
<span class="line" id="L576"><span class="tok-comment">/// mapped into the task's address space.  The size of this segment in memory,</span></span>
<span class="line" id="L577"><span class="tok-comment">/// vmsize, maybe equal to or larger than the amount to map from this file,</span></span>
<span class="line" id="L578"><span class="tok-comment">/// filesize.  The file is mapped starting at fileoff to the beginning of</span></span>
<span class="line" id="L579"><span class="tok-comment">/// the segment in memory, vmaddr.  The rest of the memory of the segment,</span></span>
<span class="line" id="L580"><span class="tok-comment">/// if any, is allocated zero fill on demand.  The segment's maximum virtual</span></span>
<span class="line" id="L581"><span class="tok-comment">/// memory protection and initial virtual memory protection are specified</span></span>
<span class="line" id="L582"><span class="tok-comment">/// by the maxprot and initprot fields.  If the segment has sections then the</span></span>
<span class="line" id="L583"><span class="tok-comment">/// section structures directly follow the segment command and their size is</span></span>
<span class="line" id="L584"><span class="tok-comment">/// reflected in cmdsize.</span></span>
<span class="line" id="L585"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> segment_command = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L586">    <span class="tok-comment">/// LC_SEGMENT</span></span>
<span class="line" id="L587">    cmd: LC = .SEGMENT,</span>
<span class="line" id="L588"></span>
<span class="line" id="L589">    <span class="tok-comment">/// includes sizeof section structs</span></span>
<span class="line" id="L590">    cmdsize: <span class="tok-type">u32</span>,</span>
<span class="line" id="L591"></span>
<span class="line" id="L592">    <span class="tok-comment">/// segment name</span></span>
<span class="line" id="L593">    segname: [<span class="tok-number">16</span>]<span class="tok-type">u8</span>,</span>
<span class="line" id="L594"></span>
<span class="line" id="L595">    <span class="tok-comment">/// memory address of this segment</span></span>
<span class="line" id="L596">    vmaddr: <span class="tok-type">u32</span>,</span>
<span class="line" id="L597"></span>
<span class="line" id="L598">    <span class="tok-comment">/// memory size of this segment</span></span>
<span class="line" id="L599">    vmsize: <span class="tok-type">u32</span>,</span>
<span class="line" id="L600"></span>
<span class="line" id="L601">    <span class="tok-comment">/// file offset of this segment</span></span>
<span class="line" id="L602">    fileoff: <span class="tok-type">u32</span>,</span>
<span class="line" id="L603"></span>
<span class="line" id="L604">    <span class="tok-comment">/// amount to map from the file</span></span>
<span class="line" id="L605">    filesize: <span class="tok-type">u32</span>,</span>
<span class="line" id="L606"></span>
<span class="line" id="L607">    <span class="tok-comment">/// maximum VM protection</span></span>
<span class="line" id="L608">    maxprot: vm_prot_t,</span>
<span class="line" id="L609"></span>
<span class="line" id="L610">    <span class="tok-comment">/// initial VM protection</span></span>
<span class="line" id="L611">    initprot: vm_prot_t,</span>
<span class="line" id="L612"></span>
<span class="line" id="L613">    <span class="tok-comment">/// number of sections in segment</span></span>
<span class="line" id="L614">    nsects: <span class="tok-type">u32</span>,</span>
<span class="line" id="L615">    flags: <span class="tok-type">u32</span>,</span>
<span class="line" id="L616">};</span>
<span class="line" id="L617"></span>
<span class="line" id="L618"><span class="tok-comment">/// The 64-bit segment load command indicates that a part of this file is to be</span></span>
<span class="line" id="L619"><span class="tok-comment">/// mapped into a 64-bit task's address space.  If the 64-bit segment has</span></span>
<span class="line" id="L620"><span class="tok-comment">/// sections then section_64 structures directly follow the 64-bit segment</span></span>
<span class="line" id="L621"><span class="tok-comment">/// command and their size is reflected in cmdsize.</span></span>
<span class="line" id="L622"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> segment_command_64 = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L623">    <span class="tok-comment">/// LC_SEGMENT_64</span></span>
<span class="line" id="L624">    cmd: LC = .SEGMENT_64,</span>
<span class="line" id="L625"></span>
<span class="line" id="L626">    <span class="tok-comment">/// includes sizeof section_64 structs</span></span>
<span class="line" id="L627">    cmdsize: <span class="tok-type">u32</span>,</span>
<span class="line" id="L628">    <span class="tok-comment">// TODO lazy values in stage2</span>
</span>
<span class="line" id="L629">    <span class="tok-comment">// cmdsize: u32 = @sizeOf(segment_command_64),</span>
</span>
<span class="line" id="L630"></span>
<span class="line" id="L631">    <span class="tok-comment">/// segment name</span></span>
<span class="line" id="L632">    segname: [<span class="tok-number">16</span>]<span class="tok-type">u8</span>,</span>
<span class="line" id="L633"></span>
<span class="line" id="L634">    <span class="tok-comment">/// memory address of this segment</span></span>
<span class="line" id="L635">    vmaddr: <span class="tok-type">u64</span> = <span class="tok-number">0</span>,</span>
<span class="line" id="L636"></span>
<span class="line" id="L637">    <span class="tok-comment">/// memory size of this segment</span></span>
<span class="line" id="L638">    vmsize: <span class="tok-type">u64</span> = <span class="tok-number">0</span>,</span>
<span class="line" id="L639"></span>
<span class="line" id="L640">    <span class="tok-comment">/// file offset of this segment</span></span>
<span class="line" id="L641">    fileoff: <span class="tok-type">u64</span> = <span class="tok-number">0</span>,</span>
<span class="line" id="L642"></span>
<span class="line" id="L643">    <span class="tok-comment">/// amount to map from the file</span></span>
<span class="line" id="L644">    filesize: <span class="tok-type">u64</span> = <span class="tok-number">0</span>,</span>
<span class="line" id="L645"></span>
<span class="line" id="L646">    <span class="tok-comment">/// maximum VM protection</span></span>
<span class="line" id="L647">    maxprot: vm_prot_t = PROT.NONE,</span>
<span class="line" id="L648"></span>
<span class="line" id="L649">    <span class="tok-comment">/// initial VM protection</span></span>
<span class="line" id="L650">    initprot: vm_prot_t = PROT.NONE,</span>
<span class="line" id="L651"></span>
<span class="line" id="L652">    <span class="tok-comment">/// number of sections in segment</span></span>
<span class="line" id="L653">    nsects: <span class="tok-type">u32</span> = <span class="tok-number">0</span>,</span>
<span class="line" id="L654">    flags: <span class="tok-type">u32</span> = <span class="tok-number">0</span>,</span>
<span class="line" id="L655"></span>
<span class="line" id="L656">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">segName</span>(seg: *<span class="tok-kw">const</span> segment_command_64) []<span class="tok-kw">const</span> <span class="tok-type">u8</span> {</span>
<span class="line" id="L657">        <span class="tok-kw">return</span> parseName(&amp;seg.segname);</span>
<span class="line" id="L658">    }</span>
<span class="line" id="L659">};</span>
<span class="line" id="L660"></span>
<span class="line" id="L661"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> PROT = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L662">    <span class="tok-comment">/// [MC2] no permissions</span></span>
<span class="line" id="L663">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> NONE: vm_prot_t = <span class="tok-number">0x00</span>;</span>
<span class="line" id="L664">    <span class="tok-comment">/// [MC2] pages can be read</span></span>
<span class="line" id="L665">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> READ: vm_prot_t = <span class="tok-number">0x01</span>;</span>
<span class="line" id="L666">    <span class="tok-comment">/// [MC2] pages can be written</span></span>
<span class="line" id="L667">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> WRITE: vm_prot_t = <span class="tok-number">0x02</span>;</span>
<span class="line" id="L668">    <span class="tok-comment">/// [MC2] pages can be executed</span></span>
<span class="line" id="L669">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> EXEC: vm_prot_t = <span class="tok-number">0x04</span>;</span>
<span class="line" id="L670">    <span class="tok-comment">/// When a caller finds that they cannot obtain write permission on a</span></span>
<span class="line" id="L671">    <span class="tok-comment">/// mapped entry, the following flag can be used. The entry will be</span></span>
<span class="line" id="L672">    <span class="tok-comment">/// made &quot;needs copy&quot; effectively copying the object (using COW),</span></span>
<span class="line" id="L673">    <span class="tok-comment">/// and write permission will be added to the maximum protections for</span></span>
<span class="line" id="L674">    <span class="tok-comment">/// the associated entry.</span></span>
<span class="line" id="L675">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> COPY: vm_prot_t = <span class="tok-number">0x10</span>;</span>
<span class="line" id="L676">};</span>
<span class="line" id="L677"></span>
<span class="line" id="L678"><span class="tok-comment">/// A segment is made up of zero or more sections.  Non-MH_OBJECT files have</span></span>
<span class="line" id="L679"><span class="tok-comment">/// all of their segments with the proper sections in each, and padded to the</span></span>
<span class="line" id="L680"><span class="tok-comment">/// specified segment alignment when produced by the link editor.  The first</span></span>
<span class="line" id="L681"><span class="tok-comment">/// segment of a MH_EXECUTE and MH_FVMLIB format file contains the mach_header</span></span>
<span class="line" id="L682"><span class="tok-comment">/// and load commands of the object file before its first section.  The zero</span></span>
<span class="line" id="L683"><span class="tok-comment">/// fill sections are always last in their segment (in all formats).  This</span></span>
<span class="line" id="L684"><span class="tok-comment">/// allows the zeroed segment padding to be mapped into memory where zero fill</span></span>
<span class="line" id="L685"><span class="tok-comment">/// sections might be. The gigabyte zero fill sections, those with the section</span></span>
<span class="line" id="L686"><span class="tok-comment">/// type S_GB_ZEROFILL, can only be in a segment with sections of this type.</span></span>
<span class="line" id="L687"><span class="tok-comment">/// These segments are then placed after all other segments.</span></span>
<span class="line" id="L688"><span class="tok-comment">///</span></span>
<span class="line" id="L689"><span class="tok-comment">/// The MH_OBJECT format has all of its sections in one segment for</span></span>
<span class="line" id="L690"><span class="tok-comment">/// compactness.  There is no padding to a specified segment boundary and the</span></span>
<span class="line" id="L691"><span class="tok-comment">/// mach_header and load commands are not part of the segment.</span></span>
<span class="line" id="L692"><span class="tok-comment">///</span></span>
<span class="line" id="L693"><span class="tok-comment">/// Sections with the same section name, sectname, going into the same segment,</span></span>
<span class="line" id="L694"><span class="tok-comment">/// segname, are combined by the link editor.  The resulting section is aligned</span></span>
<span class="line" id="L695"><span class="tok-comment">/// to the maximum alignment of the combined sections and is the new section's</span></span>
<span class="line" id="L696"><span class="tok-comment">/// alignment.  The combined sections are aligned to their original alignment in</span></span>
<span class="line" id="L697"><span class="tok-comment">/// the combined section.  Any padded bytes to get the specified alignment are</span></span>
<span class="line" id="L698"><span class="tok-comment">/// zeroed.</span></span>
<span class="line" id="L699"><span class="tok-comment">///</span></span>
<span class="line" id="L700"><span class="tok-comment">/// The format of the relocation entries referenced by the reloff and nreloc</span></span>
<span class="line" id="L701"><span class="tok-comment">/// fields of the section structure for mach object files is described in the</span></span>
<span class="line" id="L702"><span class="tok-comment">/// header file &lt;reloc.h&gt;.</span></span>
<span class="line" id="L703"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> @&quot;section&quot; = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L704">    <span class="tok-comment">/// name of this section</span></span>
<span class="line" id="L705">    sectname: [<span class="tok-number">16</span>]<span class="tok-type">u8</span>,</span>
<span class="line" id="L706"></span>
<span class="line" id="L707">    <span class="tok-comment">/// segment this section goes in</span></span>
<span class="line" id="L708">    segname: [<span class="tok-number">16</span>]<span class="tok-type">u8</span>,</span>
<span class="line" id="L709"></span>
<span class="line" id="L710">    <span class="tok-comment">/// memory address of this section</span></span>
<span class="line" id="L711">    addr: <span class="tok-type">u32</span>,</span>
<span class="line" id="L712"></span>
<span class="line" id="L713">    <span class="tok-comment">/// size in bytes of this section</span></span>
<span class="line" id="L714">    size: <span class="tok-type">u32</span>,</span>
<span class="line" id="L715"></span>
<span class="line" id="L716">    <span class="tok-comment">/// file offset of this section</span></span>
<span class="line" id="L717">    offset: <span class="tok-type">u32</span>,</span>
<span class="line" id="L718"></span>
<span class="line" id="L719">    <span class="tok-comment">/// section alignment (power of 2)</span></span>
<span class="line" id="L720">    @&quot;align&quot;: <span class="tok-type">u32</span>,</span>
<span class="line" id="L721"></span>
<span class="line" id="L722">    <span class="tok-comment">/// file offset of relocation entries</span></span>
<span class="line" id="L723">    reloff: <span class="tok-type">u32</span>,</span>
<span class="line" id="L724"></span>
<span class="line" id="L725">    <span class="tok-comment">/// number of relocation entries</span></span>
<span class="line" id="L726">    nreloc: <span class="tok-type">u32</span>,</span>
<span class="line" id="L727"></span>
<span class="line" id="L728">    <span class="tok-comment">/// flags (section type and attributes</span></span>
<span class="line" id="L729">    flags: <span class="tok-type">u32</span>,</span>
<span class="line" id="L730"></span>
<span class="line" id="L731">    <span class="tok-comment">/// reserved (for offset or index)</span></span>
<span class="line" id="L732">    reserved1: <span class="tok-type">u32</span>,</span>
<span class="line" id="L733"></span>
<span class="line" id="L734">    <span class="tok-comment">/// reserved (for count or sizeof)</span></span>
<span class="line" id="L735">    reserved2: <span class="tok-type">u32</span>,</span>
<span class="line" id="L736">};</span>
<span class="line" id="L737"></span>
<span class="line" id="L738"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> section_64 = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L739">    <span class="tok-comment">/// name of this section</span></span>
<span class="line" id="L740">    sectname: [<span class="tok-number">16</span>]<span class="tok-type">u8</span>,</span>
<span class="line" id="L741"></span>
<span class="line" id="L742">    <span class="tok-comment">/// segment this section goes in</span></span>
<span class="line" id="L743">    segname: [<span class="tok-number">16</span>]<span class="tok-type">u8</span>,</span>
<span class="line" id="L744"></span>
<span class="line" id="L745">    <span class="tok-comment">/// memory address of this section</span></span>
<span class="line" id="L746">    addr: <span class="tok-type">u64</span> = <span class="tok-number">0</span>,</span>
<span class="line" id="L747"></span>
<span class="line" id="L748">    <span class="tok-comment">/// size in bytes of this section</span></span>
<span class="line" id="L749">    size: <span class="tok-type">u64</span> = <span class="tok-number">0</span>,</span>
<span class="line" id="L750"></span>
<span class="line" id="L751">    <span class="tok-comment">/// file offset of this section</span></span>
<span class="line" id="L752">    offset: <span class="tok-type">u32</span> = <span class="tok-number">0</span>,</span>
<span class="line" id="L753"></span>
<span class="line" id="L754">    <span class="tok-comment">/// section alignment (power of 2)</span></span>
<span class="line" id="L755">    @&quot;align&quot;: <span class="tok-type">u32</span> = <span class="tok-number">0</span>,</span>
<span class="line" id="L756"></span>
<span class="line" id="L757">    <span class="tok-comment">/// file offset of relocation entries</span></span>
<span class="line" id="L758">    reloff: <span class="tok-type">u32</span> = <span class="tok-number">0</span>,</span>
<span class="line" id="L759"></span>
<span class="line" id="L760">    <span class="tok-comment">/// number of relocation entries</span></span>
<span class="line" id="L761">    nreloc: <span class="tok-type">u32</span> = <span class="tok-number">0</span>,</span>
<span class="line" id="L762"></span>
<span class="line" id="L763">    <span class="tok-comment">/// flags (section type and attributes</span></span>
<span class="line" id="L764">    flags: <span class="tok-type">u32</span> = S_REGULAR,</span>
<span class="line" id="L765"></span>
<span class="line" id="L766">    <span class="tok-comment">/// reserved (for offset or index)</span></span>
<span class="line" id="L767">    reserved1: <span class="tok-type">u32</span> = <span class="tok-number">0</span>,</span>
<span class="line" id="L768"></span>
<span class="line" id="L769">    <span class="tok-comment">/// reserved (for count or sizeof)</span></span>
<span class="line" id="L770">    reserved2: <span class="tok-type">u32</span> = <span class="tok-number">0</span>,</span>
<span class="line" id="L771"></span>
<span class="line" id="L772">    <span class="tok-comment">/// reserved</span></span>
<span class="line" id="L773">    reserved3: <span class="tok-type">u32</span> = <span class="tok-number">0</span>,</span>
<span class="line" id="L774"></span>
<span class="line" id="L775">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">sectName</span>(sect: *<span class="tok-kw">const</span> section_64) []<span class="tok-kw">const</span> <span class="tok-type">u8</span> {</span>
<span class="line" id="L776">        <span class="tok-kw">return</span> parseName(&amp;sect.sectname);</span>
<span class="line" id="L777">    }</span>
<span class="line" id="L778"></span>
<span class="line" id="L779">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">segName</span>(sect: *<span class="tok-kw">const</span> section_64) []<span class="tok-kw">const</span> <span class="tok-type">u8</span> {</span>
<span class="line" id="L780">        <span class="tok-kw">return</span> parseName(&amp;sect.segname);</span>
<span class="line" id="L781">    }</span>
<span class="line" id="L782"></span>
<span class="line" id="L783">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">@&quot;type&quot;</span>(sect: section_64) <span class="tok-type">u8</span> {</span>
<span class="line" id="L784">        <span class="tok-kw">return</span> <span class="tok-builtin">@truncate</span>(<span class="tok-type">u8</span>, sect.flags &amp; <span class="tok-number">0xff</span>);</span>
<span class="line" id="L785">    }</span>
<span class="line" id="L786"></span>
<span class="line" id="L787">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">attrs</span>(sect: section_64) <span class="tok-type">u32</span> {</span>
<span class="line" id="L788">        <span class="tok-kw">return</span> sect.flags &amp; <span class="tok-number">0xffffff00</span>;</span>
<span class="line" id="L789">    }</span>
<span class="line" id="L790"></span>
<span class="line" id="L791">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">isCode</span>(sect: section_64) <span class="tok-type">bool</span> {</span>
<span class="line" id="L792">        <span class="tok-kw">const</span> attr = sect.attrs();</span>
<span class="line" id="L793">        <span class="tok-kw">return</span> attr &amp; S_ATTR_PURE_INSTRUCTIONS != <span class="tok-number">0</span> <span class="tok-kw">or</span> attr &amp; S_ATTR_SOME_INSTRUCTIONS != <span class="tok-number">0</span>;</span>
<span class="line" id="L794">    }</span>
<span class="line" id="L795"></span>
<span class="line" id="L796">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">isZerofill</span>(sect: section_64) <span class="tok-type">bool</span> {</span>
<span class="line" id="L797">        <span class="tok-kw">const</span> tt = sect.@&quot;type&quot;();</span>
<span class="line" id="L798">        <span class="tok-kw">return</span> tt == S_ZEROFILL <span class="tok-kw">or</span> tt == S_GB_ZEROFILL <span class="tok-kw">or</span> tt == S_THREAD_LOCAL_ZEROFILL;</span>
<span class="line" id="L799">    }</span>
<span class="line" id="L800"></span>
<span class="line" id="L801">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">isDebug</span>(sect: section_64) <span class="tok-type">bool</span> {</span>
<span class="line" id="L802">        <span class="tok-kw">return</span> sect.attrs() &amp; S_ATTR_DEBUG != <span class="tok-number">0</span>;</span>
<span class="line" id="L803">    }</span>
<span class="line" id="L804"></span>
<span class="line" id="L805">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">isDontDeadStrip</span>(sect: section_64) <span class="tok-type">bool</span> {</span>
<span class="line" id="L806">        <span class="tok-kw">return</span> sect.attrs() &amp; S_ATTR_NO_DEAD_STRIP != <span class="tok-number">0</span>;</span>
<span class="line" id="L807">    }</span>
<span class="line" id="L808"></span>
<span class="line" id="L809">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">isDontDeadStripIfReferencesLive</span>(sect: section_64) <span class="tok-type">bool</span> {</span>
<span class="line" id="L810">        <span class="tok-kw">return</span> sect.attrs() &amp; S_ATTR_LIVE_SUPPORT != <span class="tok-number">0</span>;</span>
<span class="line" id="L811">    }</span>
<span class="line" id="L812">};</span>
<span class="line" id="L813"></span>
<span class="line" id="L814"><span class="tok-kw">fn</span> <span class="tok-fn">parseName</span>(name: *<span class="tok-kw">const</span> [<span class="tok-number">16</span>]<span class="tok-type">u8</span>) []<span class="tok-kw">const</span> <span class="tok-type">u8</span> {</span>
<span class="line" id="L815">    <span class="tok-kw">const</span> len = mem.indexOfScalar(<span class="tok-type">u8</span>, name, <span class="tok-builtin">@as</span>(<span class="tok-type">u8</span>, <span class="tok-number">0</span>)) <span class="tok-kw">orelse</span> name.len;</span>
<span class="line" id="L816">    <span class="tok-kw">return</span> name[<span class="tok-number">0</span>..len];</span>
<span class="line" id="L817">}</span>
<span class="line" id="L818"></span>
<span class="line" id="L819"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> nlist = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L820">    n_strx: <span class="tok-type">u32</span>,</span>
<span class="line" id="L821">    n_type: <span class="tok-type">u8</span>,</span>
<span class="line" id="L822">    n_sect: <span class="tok-type">u8</span>,</span>
<span class="line" id="L823">    n_desc: <span class="tok-type">i16</span>,</span>
<span class="line" id="L824">    n_value: <span class="tok-type">u32</span>,</span>
<span class="line" id="L825">};</span>
<span class="line" id="L826"></span>
<span class="line" id="L827"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> nlist_64 = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L828">    n_strx: <span class="tok-type">u32</span>,</span>
<span class="line" id="L829">    n_type: <span class="tok-type">u8</span>,</span>
<span class="line" id="L830">    n_sect: <span class="tok-type">u8</span>,</span>
<span class="line" id="L831">    n_desc: <span class="tok-type">u16</span>,</span>
<span class="line" id="L832">    n_value: <span class="tok-type">u64</span>,</span>
<span class="line" id="L833"></span>
<span class="line" id="L834">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">stab</span>(sym: nlist_64) <span class="tok-type">bool</span> {</span>
<span class="line" id="L835">        <span class="tok-kw">return</span> (N_STAB &amp; sym.n_type) != <span class="tok-number">0</span>;</span>
<span class="line" id="L836">    }</span>
<span class="line" id="L837"></span>
<span class="line" id="L838">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">pext</span>(sym: nlist_64) <span class="tok-type">bool</span> {</span>
<span class="line" id="L839">        <span class="tok-kw">return</span> (N_PEXT &amp; sym.n_type) != <span class="tok-number">0</span>;</span>
<span class="line" id="L840">    }</span>
<span class="line" id="L841"></span>
<span class="line" id="L842">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">ext</span>(sym: nlist_64) <span class="tok-type">bool</span> {</span>
<span class="line" id="L843">        <span class="tok-kw">return</span> (N_EXT &amp; sym.n_type) != <span class="tok-number">0</span>;</span>
<span class="line" id="L844">    }</span>
<span class="line" id="L845"></span>
<span class="line" id="L846">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">sect</span>(sym: nlist_64) <span class="tok-type">bool</span> {</span>
<span class="line" id="L847">        <span class="tok-kw">const</span> type_ = N_TYPE &amp; sym.n_type;</span>
<span class="line" id="L848">        <span class="tok-kw">return</span> type_ == N_SECT;</span>
<span class="line" id="L849">    }</span>
<span class="line" id="L850"></span>
<span class="line" id="L851">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">undf</span>(sym: nlist_64) <span class="tok-type">bool</span> {</span>
<span class="line" id="L852">        <span class="tok-kw">const</span> type_ = N_TYPE &amp; sym.n_type;</span>
<span class="line" id="L853">        <span class="tok-kw">return</span> type_ == N_UNDF;</span>
<span class="line" id="L854">    }</span>
<span class="line" id="L855"></span>
<span class="line" id="L856">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">indr</span>(sym: nlist_64) <span class="tok-type">bool</span> {</span>
<span class="line" id="L857">        <span class="tok-kw">const</span> type_ = N_TYPE &amp; sym.n_type;</span>
<span class="line" id="L858">        <span class="tok-kw">return</span> type_ == N_INDR;</span>
<span class="line" id="L859">    }</span>
<span class="line" id="L860"></span>
<span class="line" id="L861">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">abs</span>(sym: nlist_64) <span class="tok-type">bool</span> {</span>
<span class="line" id="L862">        <span class="tok-kw">const</span> type_ = N_TYPE &amp; sym.n_type;</span>
<span class="line" id="L863">        <span class="tok-kw">return</span> type_ == N_ABS;</span>
<span class="line" id="L864">    }</span>
<span class="line" id="L865"></span>
<span class="line" id="L866">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">weakDef</span>(sym: nlist_64) <span class="tok-type">bool</span> {</span>
<span class="line" id="L867">        <span class="tok-kw">return</span> (sym.n_desc &amp; N_WEAK_DEF) != <span class="tok-number">0</span>;</span>
<span class="line" id="L868">    }</span>
<span class="line" id="L869"></span>
<span class="line" id="L870">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">weakRef</span>(sym: nlist_64) <span class="tok-type">bool</span> {</span>
<span class="line" id="L871">        <span class="tok-kw">return</span> (sym.n_desc &amp; N_WEAK_REF) != <span class="tok-number">0</span>;</span>
<span class="line" id="L872">    }</span>
<span class="line" id="L873"></span>
<span class="line" id="L874">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">discarded</span>(sym: nlist_64) <span class="tok-type">bool</span> {</span>
<span class="line" id="L875">        <span class="tok-kw">return</span> (sym.n_desc &amp; N_DESC_DISCARDED) != <span class="tok-number">0</span>;</span>
<span class="line" id="L876">    }</span>
<span class="line" id="L877"></span>
<span class="line" id="L878">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">tentative</span>(sym: nlist_64) <span class="tok-type">bool</span> {</span>
<span class="line" id="L879">        <span class="tok-kw">if</span> (!sym.undf()) <span class="tok-kw">return</span> <span class="tok-null">false</span>;</span>
<span class="line" id="L880">        <span class="tok-kw">return</span> sym.n_value != <span class="tok-number">0</span>;</span>
<span class="line" id="L881">    }</span>
<span class="line" id="L882">};</span>
<span class="line" id="L883"></span>
<span class="line" id="L884"><span class="tok-comment">/// Format of a relocation entry of a Mach-O file.  Modified from the 4.3BSD</span></span>
<span class="line" id="L885"><span class="tok-comment">/// format.  The modifications from the original format were changing the value</span></span>
<span class="line" id="L886"><span class="tok-comment">/// of the r_symbolnum field for &quot;local&quot; (r_extern == 0) relocation entries.</span></span>
<span class="line" id="L887"><span class="tok-comment">/// This modification is required to support symbols in an arbitrary number of</span></span>
<span class="line" id="L888"><span class="tok-comment">/// sections not just the three sections (text, data and bss) in a 4.3BSD file.</span></span>
<span class="line" id="L889"><span class="tok-comment">/// Also the last 4 bits have had the r_type tag added to them.</span></span>
<span class="line" id="L890"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> relocation_info = <span class="tok-kw">packed</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L891">    <span class="tok-comment">/// offset in the section to what is being relocated</span></span>
<span class="line" id="L892">    r_address: <span class="tok-type">i32</span>,</span>
<span class="line" id="L893"></span>
<span class="line" id="L894">    <span class="tok-comment">/// symbol index if r_extern == 1 or section ordinal if r_extern == 0</span></span>
<span class="line" id="L895">    r_symbolnum: <span class="tok-type">u24</span>,</span>
<span class="line" id="L896"></span>
<span class="line" id="L897">    <span class="tok-comment">/// was relocated pc relative already</span></span>
<span class="line" id="L898">    r_pcrel: <span class="tok-type">u1</span>,</span>
<span class="line" id="L899"></span>
<span class="line" id="L900">    <span class="tok-comment">/// 0=byte, 1=word, 2=long, 3=quad</span></span>
<span class="line" id="L901">    r_length: <span class="tok-type">u2</span>,</span>
<span class="line" id="L902"></span>
<span class="line" id="L903">    <span class="tok-comment">/// does not include value of sym referenced</span></span>
<span class="line" id="L904">    r_extern: <span class="tok-type">u1</span>,</span>
<span class="line" id="L905"></span>
<span class="line" id="L906">    <span class="tok-comment">/// if not 0, machine specific relocation type</span></span>
<span class="line" id="L907">    r_type: <span class="tok-type">u4</span>,</span>
<span class="line" id="L908">};</span>
<span class="line" id="L909"></span>
<span class="line" id="L910"><span class="tok-comment">/// After MacOS X 10.1 when a new load command is added that is required to be</span></span>
<span class="line" id="L911"><span class="tok-comment">/// understood by the dynamic linker for the image to execute properly the</span></span>
<span class="line" id="L912"><span class="tok-comment">/// LC_REQ_DYLD bit will be or'ed into the load command constant.  If the dynamic</span></span>
<span class="line" id="L913"><span class="tok-comment">/// linker sees such a load command it it does not understand will issue a</span></span>
<span class="line" id="L914"><span class="tok-comment">/// &quot;unknown load command required for execution&quot; error and refuse to use the</span></span>
<span class="line" id="L915"><span class="tok-comment">/// image.  Other load commands without this bit that are not understood will</span></span>
<span class="line" id="L916"><span class="tok-comment">/// simply be ignored.</span></span>
<span class="line" id="L917"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> LC_REQ_DYLD = <span class="tok-number">0x80000000</span>;</span>
<span class="line" id="L918"></span>
<span class="line" id="L919"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> LC = <span class="tok-kw">enum</span>(<span class="tok-type">u32</span>) {</span>
<span class="line" id="L920">    <span class="tok-comment">/// No load command - invalid</span></span>
<span class="line" id="L921">    NONE = <span class="tok-number">0x0</span>,</span>
<span class="line" id="L922"></span>
<span class="line" id="L923">    <span class="tok-comment">/// segment of this file to be mapped</span></span>
<span class="line" id="L924">    SEGMENT = <span class="tok-number">0x1</span>,</span>
<span class="line" id="L925"></span>
<span class="line" id="L926">    <span class="tok-comment">/// link-edit stab symbol table info</span></span>
<span class="line" id="L927">    SYMTAB = <span class="tok-number">0x2</span>,</span>
<span class="line" id="L928"></span>
<span class="line" id="L929">    <span class="tok-comment">/// link-edit gdb symbol table info (obsolete)</span></span>
<span class="line" id="L930">    SYMSEG = <span class="tok-number">0x3</span>,</span>
<span class="line" id="L931"></span>
<span class="line" id="L932">    <span class="tok-comment">/// thread</span></span>
<span class="line" id="L933">    THREAD = <span class="tok-number">0x4</span>,</span>
<span class="line" id="L934"></span>
<span class="line" id="L935">    <span class="tok-comment">/// unix thread (includes a stack)</span></span>
<span class="line" id="L936">    UNIXTHREAD = <span class="tok-number">0x5</span>,</span>
<span class="line" id="L937"></span>
<span class="line" id="L938">    <span class="tok-comment">/// load a specified fixed VM shared library</span></span>
<span class="line" id="L939">    LOADFVMLIB = <span class="tok-number">0x6</span>,</span>
<span class="line" id="L940"></span>
<span class="line" id="L941">    <span class="tok-comment">/// fixed VM shared library identification</span></span>
<span class="line" id="L942">    IDFVMLIB = <span class="tok-number">0x7</span>,</span>
<span class="line" id="L943"></span>
<span class="line" id="L944">    <span class="tok-comment">/// object identification info (obsolete)</span></span>
<span class="line" id="L945">    IDENT = <span class="tok-number">0x8</span>,</span>
<span class="line" id="L946"></span>
<span class="line" id="L947">    <span class="tok-comment">/// fixed VM file inclusion (internal use)</span></span>
<span class="line" id="L948">    FVMFILE = <span class="tok-number">0x9</span>,</span>
<span class="line" id="L949"></span>
<span class="line" id="L950">    <span class="tok-comment">/// prepage command (internal use)</span></span>
<span class="line" id="L951">    PREPAGE = <span class="tok-number">0xa</span>,</span>
<span class="line" id="L952"></span>
<span class="line" id="L953">    <span class="tok-comment">/// dynamic link-edit symbol table info</span></span>
<span class="line" id="L954">    DYSYMTAB = <span class="tok-number">0xb</span>,</span>
<span class="line" id="L955"></span>
<span class="line" id="L956">    <span class="tok-comment">/// load a dynamically linked shared library</span></span>
<span class="line" id="L957">    LOAD_DYLIB = <span class="tok-number">0xc</span>,</span>
<span class="line" id="L958"></span>
<span class="line" id="L959">    <span class="tok-comment">/// dynamically linked shared lib ident</span></span>
<span class="line" id="L960">    ID_DYLIB = <span class="tok-number">0xd</span>,</span>
<span class="line" id="L961"></span>
<span class="line" id="L962">    <span class="tok-comment">/// load a dynamic linker</span></span>
<span class="line" id="L963">    LOAD_DYLINKER = <span class="tok-number">0xe</span>,</span>
<span class="line" id="L964"></span>
<span class="line" id="L965">    <span class="tok-comment">/// dynamic linker identification</span></span>
<span class="line" id="L966">    ID_DYLINKER = <span class="tok-number">0xf</span>,</span>
<span class="line" id="L967"></span>
<span class="line" id="L968">    <span class="tok-comment">/// modules prebound for a dynamically</span></span>
<span class="line" id="L969">    PREBOUND_DYLIB = <span class="tok-number">0x10</span>,</span>
<span class="line" id="L970"></span>
<span class="line" id="L971">    <span class="tok-comment">/// image routines</span></span>
<span class="line" id="L972">    ROUTINES = <span class="tok-number">0x11</span>,</span>
<span class="line" id="L973"></span>
<span class="line" id="L974">    <span class="tok-comment">/// sub framework</span></span>
<span class="line" id="L975">    SUB_FRAMEWORK = <span class="tok-number">0x12</span>,</span>
<span class="line" id="L976"></span>
<span class="line" id="L977">    <span class="tok-comment">/// sub umbrella</span></span>
<span class="line" id="L978">    SUB_UMBRELLA = <span class="tok-number">0x13</span>,</span>
<span class="line" id="L979"></span>
<span class="line" id="L980">    <span class="tok-comment">/// sub client</span></span>
<span class="line" id="L981">    SUB_CLIENT = <span class="tok-number">0x14</span>,</span>
<span class="line" id="L982"></span>
<span class="line" id="L983">    <span class="tok-comment">/// sub library</span></span>
<span class="line" id="L984">    SUB_LIBRARY = <span class="tok-number">0x15</span>,</span>
<span class="line" id="L985"></span>
<span class="line" id="L986">    <span class="tok-comment">/// two-level namespace lookup hints</span></span>
<span class="line" id="L987">    TWOLEVEL_HINTS = <span class="tok-number">0x16</span>,</span>
<span class="line" id="L988"></span>
<span class="line" id="L989">    <span class="tok-comment">/// prebind checksum</span></span>
<span class="line" id="L990">    PREBIND_CKSUM = <span class="tok-number">0x17</span>,</span>
<span class="line" id="L991"></span>
<span class="line" id="L992">    <span class="tok-comment">/// load a dynamically linked shared library that is allowed to be missing</span></span>
<span class="line" id="L993">    <span class="tok-comment">/// (all symbols are weak imported).</span></span>
<span class="line" id="L994">    LOAD_WEAK_DYLIB = (<span class="tok-number">0x18</span> | LC_REQ_DYLD),</span>
<span class="line" id="L995"></span>
<span class="line" id="L996">    <span class="tok-comment">/// 64-bit segment of this file to be mapped</span></span>
<span class="line" id="L997">    SEGMENT_64 = <span class="tok-number">0x19</span>,</span>
<span class="line" id="L998"></span>
<span class="line" id="L999">    <span class="tok-comment">/// 64-bit image routines</span></span>
<span class="line" id="L1000">    ROUTINES_64 = <span class="tok-number">0x1a</span>,</span>
<span class="line" id="L1001"></span>
<span class="line" id="L1002">    <span class="tok-comment">/// the uuid</span></span>
<span class="line" id="L1003">    UUID = <span class="tok-number">0x1b</span>,</span>
<span class="line" id="L1004"></span>
<span class="line" id="L1005">    <span class="tok-comment">/// runpath additions</span></span>
<span class="line" id="L1006">    RPATH = (<span class="tok-number">0x1c</span> | LC_REQ_DYLD),</span>
<span class="line" id="L1007"></span>
<span class="line" id="L1008">    <span class="tok-comment">/// local of code signature</span></span>
<span class="line" id="L1009">    CODE_SIGNATURE = <span class="tok-number">0x1d</span>,</span>
<span class="line" id="L1010"></span>
<span class="line" id="L1011">    <span class="tok-comment">/// local of info to split segments</span></span>
<span class="line" id="L1012">    SEGMENT_SPLIT_INFO = <span class="tok-number">0x1e</span>,</span>
<span class="line" id="L1013"></span>
<span class="line" id="L1014">    <span class="tok-comment">/// load and re-export dylib</span></span>
<span class="line" id="L1015">    REEXPORT_DYLIB = (<span class="tok-number">0x1f</span> | LC_REQ_DYLD),</span>
<span class="line" id="L1016"></span>
<span class="line" id="L1017">    <span class="tok-comment">/// delay load of dylib until first use</span></span>
<span class="line" id="L1018">    LAZY_LOAD_DYLIB = <span class="tok-number">0x20</span>,</span>
<span class="line" id="L1019"></span>
<span class="line" id="L1020">    <span class="tok-comment">/// encrypted segment information</span></span>
<span class="line" id="L1021">    ENCRYPTION_INFO = <span class="tok-number">0x21</span>,</span>
<span class="line" id="L1022"></span>
<span class="line" id="L1023">    <span class="tok-comment">/// compressed dyld information</span></span>
<span class="line" id="L1024">    DYLD_INFO = <span class="tok-number">0x22</span>,</span>
<span class="line" id="L1025"></span>
<span class="line" id="L1026">    <span class="tok-comment">/// compressed dyld information only</span></span>
<span class="line" id="L1027">    DYLD_INFO_ONLY = (<span class="tok-number">0x22</span> | LC_REQ_DYLD),</span>
<span class="line" id="L1028"></span>
<span class="line" id="L1029">    <span class="tok-comment">/// load upward dylib</span></span>
<span class="line" id="L1030">    LOAD_UPWARD_DYLIB = (<span class="tok-number">0x23</span> | LC_REQ_DYLD),</span>
<span class="line" id="L1031"></span>
<span class="line" id="L1032">    <span class="tok-comment">/// build for MacOSX min OS version</span></span>
<span class="line" id="L1033">    VERSION_MIN_MACOSX = <span class="tok-number">0x24</span>,</span>
<span class="line" id="L1034"></span>
<span class="line" id="L1035">    <span class="tok-comment">/// build for iPhoneOS min OS version</span></span>
<span class="line" id="L1036">    VERSION_MIN_IPHONEOS = <span class="tok-number">0x25</span>,</span>
<span class="line" id="L1037"></span>
<span class="line" id="L1038">    <span class="tok-comment">/// compressed table of function start addresses</span></span>
<span class="line" id="L1039">    FUNCTION_STARTS = <span class="tok-number">0x26</span>,</span>
<span class="line" id="L1040"></span>
<span class="line" id="L1041">    <span class="tok-comment">/// string for dyld to treat like environment variable</span></span>
<span class="line" id="L1042">    DYLD_ENVIRONMENT = <span class="tok-number">0x27</span>,</span>
<span class="line" id="L1043"></span>
<span class="line" id="L1044">    <span class="tok-comment">/// replacement for LC_UNIXTHREAD</span></span>
<span class="line" id="L1045">    MAIN = (<span class="tok-number">0x28</span> | LC_REQ_DYLD),</span>
<span class="line" id="L1046"></span>
<span class="line" id="L1047">    <span class="tok-comment">/// table of non-instructions in __text</span></span>
<span class="line" id="L1048">    DATA_IN_CODE = <span class="tok-number">0x29</span>,</span>
<span class="line" id="L1049"></span>
<span class="line" id="L1050">    <span class="tok-comment">/// source version used to build binary</span></span>
<span class="line" id="L1051">    SOURCE_VERSION = <span class="tok-number">0x2A</span>,</span>
<span class="line" id="L1052"></span>
<span class="line" id="L1053">    <span class="tok-comment">/// Code signing DRs copied from linked dylibs</span></span>
<span class="line" id="L1054">    DYLIB_CODE_SIGN_DRS = <span class="tok-number">0x2B</span>,</span>
<span class="line" id="L1055"></span>
<span class="line" id="L1056">    <span class="tok-comment">/// 64-bit encrypted segment information</span></span>
<span class="line" id="L1057">    ENCRYPTION_INFO_64 = <span class="tok-number">0x2C</span>,</span>
<span class="line" id="L1058"></span>
<span class="line" id="L1059">    <span class="tok-comment">/// linker options in MH_OBJECT files</span></span>
<span class="line" id="L1060">    LINKER_OPTION = <span class="tok-number">0x2D</span>,</span>
<span class="line" id="L1061"></span>
<span class="line" id="L1062">    <span class="tok-comment">/// optimization hints in MH_OBJECT files</span></span>
<span class="line" id="L1063">    LINKER_OPTIMIZATION_HINT = <span class="tok-number">0x2E</span>,</span>
<span class="line" id="L1064"></span>
<span class="line" id="L1065">    <span class="tok-comment">/// build for AppleTV min OS version</span></span>
<span class="line" id="L1066">    VERSION_MIN_TVOS = <span class="tok-number">0x2F</span>,</span>
<span class="line" id="L1067"></span>
<span class="line" id="L1068">    <span class="tok-comment">/// build for Watch min OS version</span></span>
<span class="line" id="L1069">    VERSION_MIN_WATCHOS = <span class="tok-number">0x30</span>,</span>
<span class="line" id="L1070"></span>
<span class="line" id="L1071">    <span class="tok-comment">/// arbitrary data included within a Mach-O file</span></span>
<span class="line" id="L1072">    NOTE = <span class="tok-number">0x31</span>,</span>
<span class="line" id="L1073"></span>
<span class="line" id="L1074">    <span class="tok-comment">/// build for platform min OS version</span></span>
<span class="line" id="L1075">    BUILD_VERSION = <span class="tok-number">0x32</span>,</span>
<span class="line" id="L1076"></span>
<span class="line" id="L1077">    _,</span>
<span class="line" id="L1078">};</span>
<span class="line" id="L1079"></span>
<span class="line" id="L1080"><span class="tok-comment">/// the mach magic number</span></span>
<span class="line" id="L1081"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> MH_MAGIC = <span class="tok-number">0xfeedface</span>;</span>
<span class="line" id="L1082"></span>
<span class="line" id="L1083"><span class="tok-comment">/// NXSwapInt(MH_MAGIC)</span></span>
<span class="line" id="L1084"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> MH_CIGAM = <span class="tok-number">0xcefaedfe</span>;</span>
<span class="line" id="L1085"></span>
<span class="line" id="L1086"><span class="tok-comment">/// the 64-bit mach magic number</span></span>
<span class="line" id="L1087"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> MH_MAGIC_64 = <span class="tok-number">0xfeedfacf</span>;</span>
<span class="line" id="L1088"></span>
<span class="line" id="L1089"><span class="tok-comment">/// NXSwapInt(MH_MAGIC_64)</span></span>
<span class="line" id="L1090"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> MH_CIGAM_64 = <span class="tok-number">0xcffaedfe</span>;</span>
<span class="line" id="L1091"></span>
<span class="line" id="L1092"><span class="tok-comment">/// relocatable object file</span></span>
<span class="line" id="L1093"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> MH_OBJECT = <span class="tok-number">0x1</span>;</span>
<span class="line" id="L1094"></span>
<span class="line" id="L1095"><span class="tok-comment">/// demand paged executable file</span></span>
<span class="line" id="L1096"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> MH_EXECUTE = <span class="tok-number">0x2</span>;</span>
<span class="line" id="L1097"></span>
<span class="line" id="L1098"><span class="tok-comment">/// fixed VM shared library file</span></span>
<span class="line" id="L1099"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> MH_FVMLIB = <span class="tok-number">0x3</span>;</span>
<span class="line" id="L1100"></span>
<span class="line" id="L1101"><span class="tok-comment">/// core file</span></span>
<span class="line" id="L1102"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> MH_CORE = <span class="tok-number">0x4</span>;</span>
<span class="line" id="L1103"></span>
<span class="line" id="L1104"><span class="tok-comment">/// preloaded executable file</span></span>
<span class="line" id="L1105"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> MH_PRELOAD = <span class="tok-number">0x5</span>;</span>
<span class="line" id="L1106"></span>
<span class="line" id="L1107"><span class="tok-comment">/// dynamically bound shared library</span></span>
<span class="line" id="L1108"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> MH_DYLIB = <span class="tok-number">0x6</span>;</span>
<span class="line" id="L1109"></span>
<span class="line" id="L1110"><span class="tok-comment">/// dynamic link editor</span></span>
<span class="line" id="L1111"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> MH_DYLINKER = <span class="tok-number">0x7</span>;</span>
<span class="line" id="L1112"></span>
<span class="line" id="L1113"><span class="tok-comment">/// dynamically bound bundle file</span></span>
<span class="line" id="L1114"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> MH_BUNDLE = <span class="tok-number">0x8</span>;</span>
<span class="line" id="L1115"></span>
<span class="line" id="L1116"><span class="tok-comment">/// shared library stub for static linking only, no section contents</span></span>
<span class="line" id="L1117"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> MH_DYLIB_STUB = <span class="tok-number">0x9</span>;</span>
<span class="line" id="L1118"></span>
<span class="line" id="L1119"><span class="tok-comment">/// companion file with only debug sections</span></span>
<span class="line" id="L1120"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> MH_DSYM = <span class="tok-number">0xa</span>;</span>
<span class="line" id="L1121"></span>
<span class="line" id="L1122"><span class="tok-comment">/// x86_64 kexts</span></span>
<span class="line" id="L1123"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> MH_KEXT_BUNDLE = <span class="tok-number">0xb</span>;</span>
<span class="line" id="L1124"></span>
<span class="line" id="L1125"><span class="tok-comment">// Constants for the flags field of the mach_header</span>
</span>
<span class="line" id="L1126"></span>
<span class="line" id="L1127"><span class="tok-comment">/// the object file has no undefined references</span></span>
<span class="line" id="L1128"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> MH_NOUNDEFS = <span class="tok-number">0x1</span>;</span>
<span class="line" id="L1129"></span>
<span class="line" id="L1130"><span class="tok-comment">/// the object file is the output of an incremental link against a base file and can't be link edited again</span></span>
<span class="line" id="L1131"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> MH_INCRLINK = <span class="tok-number">0x2</span>;</span>
<span class="line" id="L1132"></span>
<span class="line" id="L1133"><span class="tok-comment">/// the object file is input for the dynamic linker and can't be staticly link edited again</span></span>
<span class="line" id="L1134"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> MH_DYLDLINK = <span class="tok-number">0x4</span>;</span>
<span class="line" id="L1135"></span>
<span class="line" id="L1136"><span class="tok-comment">/// the object file's undefined references are bound by the dynamic linker when loaded.</span></span>
<span class="line" id="L1137"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> MH_BINDATLOAD = <span class="tok-number">0x8</span>;</span>
<span class="line" id="L1138"></span>
<span class="line" id="L1139"><span class="tok-comment">/// the file has its dynamic undefined references prebound.</span></span>
<span class="line" id="L1140"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> MH_PREBOUND = <span class="tok-number">0x10</span>;</span>
<span class="line" id="L1141"></span>
<span class="line" id="L1142"><span class="tok-comment">/// the file has its read-only and read-write segments split</span></span>
<span class="line" id="L1143"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> MH_SPLIT_SEGS = <span class="tok-number">0x20</span>;</span>
<span class="line" id="L1144"></span>
<span class="line" id="L1145"><span class="tok-comment">/// the shared library init routine is to be run lazily via catching memory faults to its writeable segments (obsolete)</span></span>
<span class="line" id="L1146"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> MH_LAZY_INIT = <span class="tok-number">0x40</span>;</span>
<span class="line" id="L1147"></span>
<span class="line" id="L1148"><span class="tok-comment">/// the image is using two-level name space bindings</span></span>
<span class="line" id="L1149"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> MH_TWOLEVEL = <span class="tok-number">0x80</span>;</span>
<span class="line" id="L1150"></span>
<span class="line" id="L1151"><span class="tok-comment">/// the executable is forcing all images to use flat name space bindings</span></span>
<span class="line" id="L1152"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> MH_FORCE_FLAT = <span class="tok-number">0x100</span>;</span>
<span class="line" id="L1153"></span>
<span class="line" id="L1154"><span class="tok-comment">/// this umbrella guarantees no multiple defintions of symbols in its sub-images so the two-level namespace hints can always be used.</span></span>
<span class="line" id="L1155"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> MH_NOMULTIDEFS = <span class="tok-number">0x200</span>;</span>
<span class="line" id="L1156"></span>
<span class="line" id="L1157"><span class="tok-comment">/// do not have dyld notify the prebinding agent about this executable</span></span>
<span class="line" id="L1158"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> MH_NOFIXPREBINDING = <span class="tok-number">0x400</span>;</span>
<span class="line" id="L1159"></span>
<span class="line" id="L1160"><span class="tok-comment">/// the binary is not prebound but can have its prebinding redone. only used when MH_PREBOUND is not set.</span></span>
<span class="line" id="L1161"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> MH_PREBINDABLE = <span class="tok-number">0x800</span>;</span>
<span class="line" id="L1162"></span>
<span class="line" id="L1163"><span class="tok-comment">/// indicates that this binary binds to all two-level namespace modules of its dependent libraries. only used when MH_PREBINDABLE and MH_TWOLEVEL are both set.</span></span>
<span class="line" id="L1164"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> MH_ALLMODSBOUND = <span class="tok-number">0x1000</span>;</span>
<span class="line" id="L1165"></span>
<span class="line" id="L1166"><span class="tok-comment">/// safe to divide up the sections into sub-sections via symbols for dead code stripping</span></span>
<span class="line" id="L1167"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> MH_SUBSECTIONS_VIA_SYMBOLS = <span class="tok-number">0x2000</span>;</span>
<span class="line" id="L1168"></span>
<span class="line" id="L1169"><span class="tok-comment">/// the binary has been canonicalized via the unprebind operation</span></span>
<span class="line" id="L1170"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> MH_CANONICAL = <span class="tok-number">0x4000</span>;</span>
<span class="line" id="L1171"></span>
<span class="line" id="L1172"><span class="tok-comment">/// the final linked image contains external weak symbols</span></span>
<span class="line" id="L1173"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> MH_WEAK_DEFINES = <span class="tok-number">0x8000</span>;</span>
<span class="line" id="L1174"></span>
<span class="line" id="L1175"><span class="tok-comment">/// the final linked image uses weak symbols</span></span>
<span class="line" id="L1176"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> MH_BINDS_TO_WEAK = <span class="tok-number">0x10000</span>;</span>
<span class="line" id="L1177"></span>
<span class="line" id="L1178"><span class="tok-comment">/// When this bit is set, all stacks in the task will be given stack execution privilege.  Only used in MH_EXECUTE filetypes.</span></span>
<span class="line" id="L1179"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> MH_ALLOW_STACK_EXECUTION = <span class="tok-number">0x20000</span>;</span>
<span class="line" id="L1180"></span>
<span class="line" id="L1181"><span class="tok-comment">/// When this bit is set, the binary declares it is safe for use in processes with uid zero</span></span>
<span class="line" id="L1182"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> MH_ROOT_SAFE = <span class="tok-number">0x40000</span>;</span>
<span class="line" id="L1183"></span>
<span class="line" id="L1184"><span class="tok-comment">/// When this bit is set, the binary declares it is safe for use in processes when issetugid() is true</span></span>
<span class="line" id="L1185"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> MH_SETUID_SAFE = <span class="tok-number">0x80000</span>;</span>
<span class="line" id="L1186"></span>
<span class="line" id="L1187"><span class="tok-comment">/// When this bit is set on a dylib, the static linker does not need to examine dependent dylibs to see if any are re-exported</span></span>
<span class="line" id="L1188"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> MH_NO_REEXPORTED_DYLIBS = <span class="tok-number">0x100000</span>;</span>
<span class="line" id="L1189"></span>
<span class="line" id="L1190"><span class="tok-comment">/// When this bit is set, the OS will load the main executable at a random address.  Only used in MH_EXECUTE filetypes.</span></span>
<span class="line" id="L1191"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> MH_PIE = <span class="tok-number">0x200000</span>;</span>
<span class="line" id="L1192"></span>
<span class="line" id="L1193"><span class="tok-comment">/// Only for use on dylibs.  When linking against a dylib that has this bit set, the static linker will automatically not create a LC_LOAD_DYLIB load command to the dylib if no symbols are being referenced from the dylib.</span></span>
<span class="line" id="L1194"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> MH_DEAD_STRIPPABLE_DYLIB = <span class="tok-number">0x400000</span>;</span>
<span class="line" id="L1195"></span>
<span class="line" id="L1196"><span class="tok-comment">/// Contains a section of type S_THREAD_LOCAL_VARIABLES</span></span>
<span class="line" id="L1197"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> MH_HAS_TLV_DESCRIPTORS = <span class="tok-number">0x800000</span>;</span>
<span class="line" id="L1198"></span>
<span class="line" id="L1199"><span class="tok-comment">/// When this bit is set, the OS will run the main executable with a non-executable heap even on platforms (e.g. i386) that don't require it. Only used in MH_EXECUTE filetypes.</span></span>
<span class="line" id="L1200"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> MH_NO_HEAP_EXECUTION = <span class="tok-number">0x1000000</span>;</span>
<span class="line" id="L1201"></span>
<span class="line" id="L1202"><span class="tok-comment">/// The code was linked for use in an application extension.</span></span>
<span class="line" id="L1203"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> MH_APP_EXTENSION_SAFE = <span class="tok-number">0x02000000</span>;</span>
<span class="line" id="L1204"></span>
<span class="line" id="L1205"><span class="tok-comment">/// The external symbols listed in the nlist symbol table do not include all the symbols listed in the dyld info.</span></span>
<span class="line" id="L1206"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> MH_NLIST_OUTOFSYNC_WITH_DYLDINFO = <span class="tok-number">0x04000000</span>;</span>
<span class="line" id="L1207"></span>
<span class="line" id="L1208"><span class="tok-comment">// Constants for the flags field of the fat_header</span>
</span>
<span class="line" id="L1209"></span>
<span class="line" id="L1210"><span class="tok-comment">/// the fat magic number</span></span>
<span class="line" id="L1211"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FAT_MAGIC = <span class="tok-number">0xcafebabe</span>;</span>
<span class="line" id="L1212"></span>
<span class="line" id="L1213"><span class="tok-comment">/// NXSwapLong(FAT_MAGIC)</span></span>
<span class="line" id="L1214"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FAT_CIGAM = <span class="tok-number">0xbebafeca</span>;</span>
<span class="line" id="L1215"></span>
<span class="line" id="L1216"><span class="tok-comment">/// the 64-bit fat magic number</span></span>
<span class="line" id="L1217"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FAT_MAGIC_64 = <span class="tok-number">0xcafebabf</span>;</span>
<span class="line" id="L1218"></span>
<span class="line" id="L1219"><span class="tok-comment">/// NXSwapLong(FAT_MAGIC_64)</span></span>
<span class="line" id="L1220"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FAT_CIGAM_64 = <span class="tok-number">0xbfbafeca</span>;</span>
<span class="line" id="L1221"></span>
<span class="line" id="L1222"><span class="tok-comment">/// The flags field of a section structure is separated into two parts a section</span></span>
<span class="line" id="L1223"><span class="tok-comment">/// type and section attributes.  The section types are mutually exclusive (it</span></span>
<span class="line" id="L1224"><span class="tok-comment">/// can only have one type) but the section attributes are not (it may have more</span></span>
<span class="line" id="L1225"><span class="tok-comment">/// than one attribute).</span></span>
<span class="line" id="L1226"><span class="tok-comment">/// 256 section types</span></span>
<span class="line" id="L1227"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SECTION_TYPE = <span class="tok-number">0x000000ff</span>;</span>
<span class="line" id="L1228"></span>
<span class="line" id="L1229"><span class="tok-comment">///  24 section attributes</span></span>
<span class="line" id="L1230"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SECTION_ATTRIBUTES = <span class="tok-number">0xffffff00</span>;</span>
<span class="line" id="L1231"></span>
<span class="line" id="L1232"><span class="tok-comment">/// regular section</span></span>
<span class="line" id="L1233"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> S_REGULAR = <span class="tok-number">0x0</span>;</span>
<span class="line" id="L1234"></span>
<span class="line" id="L1235"><span class="tok-comment">/// zero fill on demand section</span></span>
<span class="line" id="L1236"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> S_ZEROFILL = <span class="tok-number">0x1</span>;</span>
<span class="line" id="L1237"></span>
<span class="line" id="L1238"><span class="tok-comment">/// section with only literal C string</span></span>
<span class="line" id="L1239"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> S_CSTRING_LITERALS = <span class="tok-number">0x2</span>;</span>
<span class="line" id="L1240"></span>
<span class="line" id="L1241"><span class="tok-comment">/// section with only 4 byte literals</span></span>
<span class="line" id="L1242"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> S_4BYTE_LITERALS = <span class="tok-number">0x3</span>;</span>
<span class="line" id="L1243"></span>
<span class="line" id="L1244"><span class="tok-comment">/// section with only 8 byte literals</span></span>
<span class="line" id="L1245"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> S_8BYTE_LITERALS = <span class="tok-number">0x4</span>;</span>
<span class="line" id="L1246"></span>
<span class="line" id="L1247"><span class="tok-comment">/// section with only pointers to</span></span>
<span class="line" id="L1248"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> S_LITERAL_POINTERS = <span class="tok-number">0x5</span>;</span>
<span class="line" id="L1249"></span>
<span class="line" id="L1250"><span class="tok-comment">/// if any of these bits set, a symbolic debugging entry</span></span>
<span class="line" id="L1251"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> N_STAB = <span class="tok-number">0xe0</span>;</span>
<span class="line" id="L1252"></span>
<span class="line" id="L1253"><span class="tok-comment">/// private external symbol bit</span></span>
<span class="line" id="L1254"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> N_PEXT = <span class="tok-number">0x10</span>;</span>
<span class="line" id="L1255"></span>
<span class="line" id="L1256"><span class="tok-comment">/// mask for the type bits</span></span>
<span class="line" id="L1257"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> N_TYPE = <span class="tok-number">0x0e</span>;</span>
<span class="line" id="L1258"></span>
<span class="line" id="L1259"><span class="tok-comment">/// external symbol bit, set for external symbols</span></span>
<span class="line" id="L1260"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> N_EXT = <span class="tok-number">0x01</span>;</span>
<span class="line" id="L1261"></span>
<span class="line" id="L1262"><span class="tok-comment">/// symbol is undefined</span></span>
<span class="line" id="L1263"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> N_UNDF = <span class="tok-number">0x0</span>;</span>
<span class="line" id="L1264"></span>
<span class="line" id="L1265"><span class="tok-comment">/// symbol is absolute</span></span>
<span class="line" id="L1266"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> N_ABS = <span class="tok-number">0x2</span>;</span>
<span class="line" id="L1267"></span>
<span class="line" id="L1268"><span class="tok-comment">/// symbol is defined in the section number given in n_sect</span></span>
<span class="line" id="L1269"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> N_SECT = <span class="tok-number">0xe</span>;</span>
<span class="line" id="L1270"></span>
<span class="line" id="L1271"><span class="tok-comment">/// symbol is undefined  and the image is using a prebound</span></span>
<span class="line" id="L1272"><span class="tok-comment">/// value  for the symbol</span></span>
<span class="line" id="L1273"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> N_PBUD = <span class="tok-number">0xc</span>;</span>
<span class="line" id="L1274"></span>
<span class="line" id="L1275"><span class="tok-comment">/// symbol is defined to be the same as another symbol; the n_value</span></span>
<span class="line" id="L1276"><span class="tok-comment">/// field is an index into the string table specifying the name of the</span></span>
<span class="line" id="L1277"><span class="tok-comment">/// other symbol</span></span>
<span class="line" id="L1278"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> N_INDR = <span class="tok-number">0xa</span>;</span>
<span class="line" id="L1279"></span>
<span class="line" id="L1280"><span class="tok-comment">/// global symbol: name,,NO_SECT,type,0</span></span>
<span class="line" id="L1281"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> N_GSYM = <span class="tok-number">0x20</span>;</span>
<span class="line" id="L1282"></span>
<span class="line" id="L1283"><span class="tok-comment">/// procedure name (f77 kludge): name,,NO_SECT,0,0</span></span>
<span class="line" id="L1284"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> N_FNAME = <span class="tok-number">0x22</span>;</span>
<span class="line" id="L1285"></span>
<span class="line" id="L1286"><span class="tok-comment">/// procedure: name,,n_sect,linenumber,address</span></span>
<span class="line" id="L1287"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> N_FUN = <span class="tok-number">0x24</span>;</span>
<span class="line" id="L1288"></span>
<span class="line" id="L1289"><span class="tok-comment">/// static symbol: name,,n_sect,type,address</span></span>
<span class="line" id="L1290"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> N_STSYM = <span class="tok-number">0x26</span>;</span>
<span class="line" id="L1291"></span>
<span class="line" id="L1292"><span class="tok-comment">/// .lcomm symbol: name,,n_sect,type,address</span></span>
<span class="line" id="L1293"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> N_LCSYM = <span class="tok-number">0x28</span>;</span>
<span class="line" id="L1294"></span>
<span class="line" id="L1295"><span class="tok-comment">/// begin nsect sym: 0,,n_sect,0,address</span></span>
<span class="line" id="L1296"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> N_BNSYM = <span class="tok-number">0x2e</span>;</span>
<span class="line" id="L1297"></span>
<span class="line" id="L1298"><span class="tok-comment">/// AST file path: name,,NO_SECT,0,0</span></span>
<span class="line" id="L1299"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> N_AST = <span class="tok-number">0x32</span>;</span>
<span class="line" id="L1300"></span>
<span class="line" id="L1301"><span class="tok-comment">/// emitted with gcc2_compiled and in gcc source</span></span>
<span class="line" id="L1302"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> N_OPT = <span class="tok-number">0x3c</span>;</span>
<span class="line" id="L1303"></span>
<span class="line" id="L1304"><span class="tok-comment">/// register sym: name,,NO_SECT,type,register</span></span>
<span class="line" id="L1305"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> N_RSYM = <span class="tok-number">0x40</span>;</span>
<span class="line" id="L1306"></span>
<span class="line" id="L1307"><span class="tok-comment">/// src line: 0,,n_sect,linenumber,address</span></span>
<span class="line" id="L1308"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> N_SLINE = <span class="tok-number">0x44</span>;</span>
<span class="line" id="L1309"></span>
<span class="line" id="L1310"><span class="tok-comment">/// end nsect sym: 0,,n_sect,0,address</span></span>
<span class="line" id="L1311"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> N_ENSYM = <span class="tok-number">0x4e</span>;</span>
<span class="line" id="L1312"></span>
<span class="line" id="L1313"><span class="tok-comment">/// structure elt: name,,NO_SECT,type,struct_offset</span></span>
<span class="line" id="L1314"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> N_SSYM = <span class="tok-number">0x60</span>;</span>
<span class="line" id="L1315"></span>
<span class="line" id="L1316"><span class="tok-comment">/// source file name: name,,n_sect,0,address</span></span>
<span class="line" id="L1317"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> N_SO = <span class="tok-number">0x64</span>;</span>
<span class="line" id="L1318"></span>
<span class="line" id="L1319"><span class="tok-comment">/// object file name: name,,0,0,st_mtime</span></span>
<span class="line" id="L1320"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> N_OSO = <span class="tok-number">0x66</span>;</span>
<span class="line" id="L1321"></span>
<span class="line" id="L1322"><span class="tok-comment">/// local sym: name,,NO_SECT,type,offset</span></span>
<span class="line" id="L1323"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> N_LSYM = <span class="tok-number">0x80</span>;</span>
<span class="line" id="L1324"></span>
<span class="line" id="L1325"><span class="tok-comment">/// include file beginning: name,,NO_SECT,0,sum</span></span>
<span class="line" id="L1326"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> N_BINCL = <span class="tok-number">0x82</span>;</span>
<span class="line" id="L1327"></span>
<span class="line" id="L1328"><span class="tok-comment">/// #included file name: name,,n_sect,0,address</span></span>
<span class="line" id="L1329"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> N_SOL = <span class="tok-number">0x84</span>;</span>
<span class="line" id="L1330"></span>
<span class="line" id="L1331"><span class="tok-comment">/// compiler parameters: name,,NO_SECT,0,0</span></span>
<span class="line" id="L1332"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> N_PARAMS = <span class="tok-number">0x86</span>;</span>
<span class="line" id="L1333"></span>
<span class="line" id="L1334"><span class="tok-comment">/// compiler version: name,,NO_SECT,0,0</span></span>
<span class="line" id="L1335"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> N_VERSION = <span class="tok-number">0x88</span>;</span>
<span class="line" id="L1336"></span>
<span class="line" id="L1337"><span class="tok-comment">/// compiler -O level: name,,NO_SECT,0,0</span></span>
<span class="line" id="L1338"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> N_OLEVEL = <span class="tok-number">0x8A</span>;</span>
<span class="line" id="L1339"></span>
<span class="line" id="L1340"><span class="tok-comment">/// parameter: name,,NO_SECT,type,offset</span></span>
<span class="line" id="L1341"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> N_PSYM = <span class="tok-number">0xa0</span>;</span>
<span class="line" id="L1342"></span>
<span class="line" id="L1343"><span class="tok-comment">/// include file end: name,,NO_SECT,0,0</span></span>
<span class="line" id="L1344"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> N_EINCL = <span class="tok-number">0xa2</span>;</span>
<span class="line" id="L1345"></span>
<span class="line" id="L1346"><span class="tok-comment">/// alternate entry: name,,n_sect,linenumber,address</span></span>
<span class="line" id="L1347"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> N_ENTRY = <span class="tok-number">0xa4</span>;</span>
<span class="line" id="L1348"></span>
<span class="line" id="L1349"><span class="tok-comment">/// left bracket: 0,,NO_SECT,nesting level,address</span></span>
<span class="line" id="L1350"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> N_LBRAC = <span class="tok-number">0xc0</span>;</span>
<span class="line" id="L1351"></span>
<span class="line" id="L1352"><span class="tok-comment">/// deleted include file: name,,NO_SECT,0,sum</span></span>
<span class="line" id="L1353"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> N_EXCL = <span class="tok-number">0xc2</span>;</span>
<span class="line" id="L1354"></span>
<span class="line" id="L1355"><span class="tok-comment">/// right bracket: 0,,NO_SECT,nesting level,address</span></span>
<span class="line" id="L1356"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> N_RBRAC = <span class="tok-number">0xe0</span>;</span>
<span class="line" id="L1357"></span>
<span class="line" id="L1358"><span class="tok-comment">/// begin common: name,,NO_SECT,0,0</span></span>
<span class="line" id="L1359"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> N_BCOMM = <span class="tok-number">0xe2</span>;</span>
<span class="line" id="L1360"></span>
<span class="line" id="L1361"><span class="tok-comment">/// end common: name,,n_sect,0,0</span></span>
<span class="line" id="L1362"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> N_ECOMM = <span class="tok-number">0xe4</span>;</span>
<span class="line" id="L1363"></span>
<span class="line" id="L1364"><span class="tok-comment">/// end common (local name): 0,,n_sect,0,address</span></span>
<span class="line" id="L1365"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> N_ECOML = <span class="tok-number">0xe8</span>;</span>
<span class="line" id="L1366"></span>
<span class="line" id="L1367"><span class="tok-comment">/// second stab entry with length information</span></span>
<span class="line" id="L1368"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> N_LENG = <span class="tok-number">0xfe</span>;</span>
<span class="line" id="L1369"></span>
<span class="line" id="L1370"><span class="tok-comment">// For the two types of symbol pointers sections and the symbol stubs section</span>
</span>
<span class="line" id="L1371"><span class="tok-comment">// they have indirect symbol table entries.  For each of the entries in the</span>
</span>
<span class="line" id="L1372"><span class="tok-comment">// section the indirect symbol table entries, in corresponding order in the</span>
</span>
<span class="line" id="L1373"><span class="tok-comment">// indirect symbol table, start at the index stored in the reserved1 field</span>
</span>
<span class="line" id="L1374"><span class="tok-comment">// of the section structure.  Since the indirect symbol table entries</span>
</span>
<span class="line" id="L1375"><span class="tok-comment">// correspond to the entries in the section the number of indirect symbol table</span>
</span>
<span class="line" id="L1376"><span class="tok-comment">// entries is inferred from the size of the section divided by the size of the</span>
</span>
<span class="line" id="L1377"><span class="tok-comment">// entries in the section.  For symbol pointers sections the size of the entries</span>
</span>
<span class="line" id="L1378"><span class="tok-comment">// in the section is 4 bytes and for symbol stubs sections the byte size of the</span>
</span>
<span class="line" id="L1379"><span class="tok-comment">// stubs is stored in the reserved2 field of the section structure.</span>
</span>
<span class="line" id="L1380"></span>
<span class="line" id="L1381"><span class="tok-comment">/// section with only non-lazy symbol pointers</span></span>
<span class="line" id="L1382"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> S_NON_LAZY_SYMBOL_POINTERS = <span class="tok-number">0x6</span>;</span>
<span class="line" id="L1383"></span>
<span class="line" id="L1384"><span class="tok-comment">/// section with only lazy symbol pointers</span></span>
<span class="line" id="L1385"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> S_LAZY_SYMBOL_POINTERS = <span class="tok-number">0x7</span>;</span>
<span class="line" id="L1386"></span>
<span class="line" id="L1387"><span class="tok-comment">/// section with only symbol stubs, byte size of stub in the reserved2 field</span></span>
<span class="line" id="L1388"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> S_SYMBOL_STUBS = <span class="tok-number">0x8</span>;</span>
<span class="line" id="L1389"></span>
<span class="line" id="L1390"><span class="tok-comment">/// section with only function pointers for initialization</span></span>
<span class="line" id="L1391"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> S_MOD_INIT_FUNC_POINTERS = <span class="tok-number">0x9</span>;</span>
<span class="line" id="L1392"></span>
<span class="line" id="L1393"><span class="tok-comment">/// section with only function pointers for termination</span></span>
<span class="line" id="L1394"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> S_MOD_TERM_FUNC_POINTERS = <span class="tok-number">0xa</span>;</span>
<span class="line" id="L1395"></span>
<span class="line" id="L1396"><span class="tok-comment">/// section contains symbols that are to be coalesced</span></span>
<span class="line" id="L1397"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> S_COALESCED = <span class="tok-number">0xb</span>;</span>
<span class="line" id="L1398"></span>
<span class="line" id="L1399"><span class="tok-comment">/// zero fill on demand section (that can be larger than 4 gigabytes)</span></span>
<span class="line" id="L1400"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> S_GB_ZEROFILL = <span class="tok-number">0xc</span>;</span>
<span class="line" id="L1401"></span>
<span class="line" id="L1402"><span class="tok-comment">/// section with only pairs of function pointers for interposing</span></span>
<span class="line" id="L1403"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> S_INTERPOSING = <span class="tok-number">0xd</span>;</span>
<span class="line" id="L1404"></span>
<span class="line" id="L1405"><span class="tok-comment">/// section with only 16 byte literals</span></span>
<span class="line" id="L1406"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> S_16BYTE_LITERALS = <span class="tok-number">0xe</span>;</span>
<span class="line" id="L1407"></span>
<span class="line" id="L1408"><span class="tok-comment">/// section contains DTrace Object Format</span></span>
<span class="line" id="L1409"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> S_DTRACE_DOF = <span class="tok-number">0xf</span>;</span>
<span class="line" id="L1410"></span>
<span class="line" id="L1411"><span class="tok-comment">/// section with only lazy symbol pointers to lazy loaded dylibs</span></span>
<span class="line" id="L1412"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> S_LAZY_DYLIB_SYMBOL_POINTERS = <span class="tok-number">0x10</span>;</span>
<span class="line" id="L1413"></span>
<span class="line" id="L1414"><span class="tok-comment">// If a segment contains any sections marked with S_ATTR_DEBUG then all</span>
</span>
<span class="line" id="L1415"><span class="tok-comment">// sections in that segment must have this attribute.  No section other than</span>
</span>
<span class="line" id="L1416"><span class="tok-comment">// a section marked with this attribute may reference the contents of this</span>
</span>
<span class="line" id="L1417"><span class="tok-comment">// section.  A section with this attribute may contain no symbols and must have</span>
</span>
<span class="line" id="L1418"><span class="tok-comment">// a section type S_REGULAR.  The static linker will not copy section contents</span>
</span>
<span class="line" id="L1419"><span class="tok-comment">// from sections with this attribute into its output file.  These sections</span>
</span>
<span class="line" id="L1420"><span class="tok-comment">// generally contain DWARF debugging info.</span>
</span>
<span class="line" id="L1421"></span>
<span class="line" id="L1422"><span class="tok-comment">/// a debug section</span></span>
<span class="line" id="L1423"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> S_ATTR_DEBUG = <span class="tok-number">0x02000000</span>;</span>
<span class="line" id="L1424"></span>
<span class="line" id="L1425"><span class="tok-comment">/// section contains only true machine instructions</span></span>
<span class="line" id="L1426"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> S_ATTR_PURE_INSTRUCTIONS = <span class="tok-number">0x80000000</span>;</span>
<span class="line" id="L1427"></span>
<span class="line" id="L1428"><span class="tok-comment">/// section contains coalesced symbols that are not to be in a ranlib</span></span>
<span class="line" id="L1429"><span class="tok-comment">/// table of contents</span></span>
<span class="line" id="L1430"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> S_ATTR_NO_TOC = <span class="tok-number">0x40000000</span>;</span>
<span class="line" id="L1431"></span>
<span class="line" id="L1432"><span class="tok-comment">/// ok to strip static symbols in this section in files with the</span></span>
<span class="line" id="L1433"><span class="tok-comment">/// MH_DYLDLINK flag</span></span>
<span class="line" id="L1434"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> S_ATTR_STRIP_STATIC_SYMS = <span class="tok-number">0x20000000</span>;</span>
<span class="line" id="L1435"></span>
<span class="line" id="L1436"><span class="tok-comment">/// no dead stripping</span></span>
<span class="line" id="L1437"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> S_ATTR_NO_DEAD_STRIP = <span class="tok-number">0x10000000</span>;</span>
<span class="line" id="L1438"></span>
<span class="line" id="L1439"><span class="tok-comment">/// blocks are live if they reference live blocks</span></span>
<span class="line" id="L1440"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> S_ATTR_LIVE_SUPPORT = <span class="tok-number">0x8000000</span>;</span>
<span class="line" id="L1441"></span>
<span class="line" id="L1442"><span class="tok-comment">/// used with i386 code stubs written on by dyld</span></span>
<span class="line" id="L1443"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> S_ATTR_SELF_MODIFYING_CODE = <span class="tok-number">0x4000000</span>;</span>
<span class="line" id="L1444"></span>
<span class="line" id="L1445"><span class="tok-comment">/// section contains some machine instructions</span></span>
<span class="line" id="L1446"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> S_ATTR_SOME_INSTRUCTIONS = <span class="tok-number">0x400</span>;</span>
<span class="line" id="L1447"></span>
<span class="line" id="L1448"><span class="tok-comment">/// section has external relocation entries</span></span>
<span class="line" id="L1449"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> S_ATTR_EXT_RELOC = <span class="tok-number">0x200</span>;</span>
<span class="line" id="L1450"></span>
<span class="line" id="L1451"><span class="tok-comment">/// section has local relocation entries</span></span>
<span class="line" id="L1452"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> S_ATTR_LOC_RELOC = <span class="tok-number">0x100</span>;</span>
<span class="line" id="L1453"></span>
<span class="line" id="L1454"><span class="tok-comment">/// template of initial values for TLVs</span></span>
<span class="line" id="L1455"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> S_THREAD_LOCAL_REGULAR = <span class="tok-number">0x11</span>;</span>
<span class="line" id="L1456"></span>
<span class="line" id="L1457"><span class="tok-comment">/// template of initial values for TLVs</span></span>
<span class="line" id="L1458"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> S_THREAD_LOCAL_ZEROFILL = <span class="tok-number">0x12</span>;</span>
<span class="line" id="L1459"></span>
<span class="line" id="L1460"><span class="tok-comment">/// TLV descriptors</span></span>
<span class="line" id="L1461"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> S_THREAD_LOCAL_VARIABLES = <span class="tok-number">0x13</span>;</span>
<span class="line" id="L1462"></span>
<span class="line" id="L1463"><span class="tok-comment">/// pointers to TLV descriptors</span></span>
<span class="line" id="L1464"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> S_THREAD_LOCAL_VARIABLE_POINTERS = <span class="tok-number">0x14</span>;</span>
<span class="line" id="L1465"></span>
<span class="line" id="L1466"><span class="tok-comment">/// functions to call to initialize TLV values</span></span>
<span class="line" id="L1467"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> S_THREAD_LOCAL_INIT_FUNCTION_POINTERS = <span class="tok-number">0x15</span>;</span>
<span class="line" id="L1468"></span>
<span class="line" id="L1469"><span class="tok-comment">/// 32-bit offsets to initializers</span></span>
<span class="line" id="L1470"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> S_INIT_FUNC_OFFSETS = <span class="tok-number">0x16</span>;</span>
<span class="line" id="L1471"></span>
<span class="line" id="L1472"><span class="tok-comment">/// CPU type targeting 64-bit Intel-based Macs</span></span>
<span class="line" id="L1473"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> CPU_TYPE_X86_64: cpu_type_t = <span class="tok-number">0x01000007</span>;</span>
<span class="line" id="L1474"></span>
<span class="line" id="L1475"><span class="tok-comment">/// CPU type targeting 64-bit ARM-based Macs</span></span>
<span class="line" id="L1476"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> CPU_TYPE_ARM64: cpu_type_t = <span class="tok-number">0x0100000C</span>;</span>
<span class="line" id="L1477"></span>
<span class="line" id="L1478"><span class="tok-comment">/// All Intel-based Macs</span></span>
<span class="line" id="L1479"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> CPU_SUBTYPE_X86_64_ALL: cpu_subtype_t = <span class="tok-number">0x3</span>;</span>
<span class="line" id="L1480"></span>
<span class="line" id="L1481"><span class="tok-comment">/// All ARM-based Macs</span></span>
<span class="line" id="L1482"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> CPU_SUBTYPE_ARM_ALL: cpu_subtype_t = <span class="tok-number">0x0</span>;</span>
<span class="line" id="L1483"></span>
<span class="line" id="L1484"><span class="tok-comment">// The following are used to encode rebasing information</span>
</span>
<span class="line" id="L1485"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> REBASE_TYPE_POINTER: <span class="tok-type">u8</span> = <span class="tok-number">1</span>;</span>
<span class="line" id="L1486"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> REBASE_TYPE_TEXT_ABSOLUTE32: <span class="tok-type">u8</span> = <span class="tok-number">2</span>;</span>
<span class="line" id="L1487"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> REBASE_TYPE_TEXT_PCREL32: <span class="tok-type">u8</span> = <span class="tok-number">3</span>;</span>
<span class="line" id="L1488"></span>
<span class="line" id="L1489"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> REBASE_OPCODE_MASK: <span class="tok-type">u8</span> = <span class="tok-number">0xF0</span>;</span>
<span class="line" id="L1490"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> REBASE_IMMEDIATE_MASK: <span class="tok-type">u8</span> = <span class="tok-number">0x0F</span>;</span>
<span class="line" id="L1491"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> REBASE_OPCODE_DONE: <span class="tok-type">u8</span> = <span class="tok-number">0x00</span>;</span>
<span class="line" id="L1492"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> REBASE_OPCODE_SET_TYPE_IMM: <span class="tok-type">u8</span> = <span class="tok-number">0x10</span>;</span>
<span class="line" id="L1493"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> REBASE_OPCODE_SET_SEGMENT_AND_OFFSET_ULEB: <span class="tok-type">u8</span> = <span class="tok-number">0x20</span>;</span>
<span class="line" id="L1494"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> REBASE_OPCODE_ADD_ADDR_ULEB: <span class="tok-type">u8</span> = <span class="tok-number">0x30</span>;</span>
<span class="line" id="L1495"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> REBASE_OPCODE_ADD_ADDR_IMM_SCALED: <span class="tok-type">u8</span> = <span class="tok-number">0x40</span>;</span>
<span class="line" id="L1496"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> REBASE_OPCODE_DO_REBASE_IMM_TIMES: <span class="tok-type">u8</span> = <span class="tok-number">0x50</span>;</span>
<span class="line" id="L1497"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> REBASE_OPCODE_DO_REBASE_ULEB_TIMES: <span class="tok-type">u8</span> = <span class="tok-number">0x60</span>;</span>
<span class="line" id="L1498"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> REBASE_OPCODE_DO_REBASE_ADD_ADDR_ULEB: <span class="tok-type">u8</span> = <span class="tok-number">0x70</span>;</span>
<span class="line" id="L1499"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> REBASE_OPCODE_DO_REBASE_ULEB_TIMES_SKIPPING_ULEB: <span class="tok-type">u8</span> = <span class="tok-number">0x80</span>;</span>
<span class="line" id="L1500"></span>
<span class="line" id="L1501"><span class="tok-comment">// The following are used to encode binding information</span>
</span>
<span class="line" id="L1502"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> BIND_TYPE_POINTER: <span class="tok-type">u8</span> = <span class="tok-number">1</span>;</span>
<span class="line" id="L1503"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> BIND_TYPE_TEXT_ABSOLUTE32: <span class="tok-type">u8</span> = <span class="tok-number">2</span>;</span>
<span class="line" id="L1504"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> BIND_TYPE_TEXT_PCREL32: <span class="tok-type">u8</span> = <span class="tok-number">3</span>;</span>
<span class="line" id="L1505"></span>
<span class="line" id="L1506"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> BIND_SPECIAL_DYLIB_SELF: <span class="tok-type">i8</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L1507"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> BIND_SPECIAL_DYLIB_MAIN_EXECUTABLE: <span class="tok-type">i8</span> = -<span class="tok-number">1</span>;</span>
<span class="line" id="L1508"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> BIND_SPECIAL_DYLIB_FLAT_LOOKUP: <span class="tok-type">i8</span> = -<span class="tok-number">2</span>;</span>
<span class="line" id="L1509"></span>
<span class="line" id="L1510"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> BIND_SYMBOL_FLAGS_WEAK_IMPORT: <span class="tok-type">u8</span> = <span class="tok-number">0x1</span>;</span>
<span class="line" id="L1511"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> BIND_SYMBOL_FLAGS_NON_WEAK_DEFINITION: <span class="tok-type">u8</span> = <span class="tok-number">0x8</span>;</span>
<span class="line" id="L1512"></span>
<span class="line" id="L1513"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> BIND_OPCODE_MASK: <span class="tok-type">u8</span> = <span class="tok-number">0xf0</span>;</span>
<span class="line" id="L1514"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> BIND_IMMEDIATE_MASK: <span class="tok-type">u8</span> = <span class="tok-number">0x0f</span>;</span>
<span class="line" id="L1515"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> BIND_OPCODE_DONE: <span class="tok-type">u8</span> = <span class="tok-number">0x00</span>;</span>
<span class="line" id="L1516"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> BIND_OPCODE_SET_DYLIB_ORDINAL_IMM: <span class="tok-type">u8</span> = <span class="tok-number">0x10</span>;</span>
<span class="line" id="L1517"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> BIND_OPCODE_SET_DYLIB_ORDINAL_ULEB: <span class="tok-type">u8</span> = <span class="tok-number">0x20</span>;</span>
<span class="line" id="L1518"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> BIND_OPCODE_SET_DYLIB_SPECIAL_IMM: <span class="tok-type">u8</span> = <span class="tok-number">0x30</span>;</span>
<span class="line" id="L1519"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> BIND_OPCODE_SET_SYMBOL_TRAILING_FLAGS_IMM: <span class="tok-type">u8</span> = <span class="tok-number">0x40</span>;</span>
<span class="line" id="L1520"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> BIND_OPCODE_SET_TYPE_IMM: <span class="tok-type">u8</span> = <span class="tok-number">0x50</span>;</span>
<span class="line" id="L1521"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> BIND_OPCODE_SET_ADDEND_SLEB: <span class="tok-type">u8</span> = <span class="tok-number">0x60</span>;</span>
<span class="line" id="L1522"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> BIND_OPCODE_SET_SEGMENT_AND_OFFSET_ULEB: <span class="tok-type">u8</span> = <span class="tok-number">0x70</span>;</span>
<span class="line" id="L1523"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> BIND_OPCODE_ADD_ADDR_ULEB: <span class="tok-type">u8</span> = <span class="tok-number">0x80</span>;</span>
<span class="line" id="L1524"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> BIND_OPCODE_DO_BIND: <span class="tok-type">u8</span> = <span class="tok-number">0x90</span>;</span>
<span class="line" id="L1525"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> BIND_OPCODE_DO_BIND_ADD_ADDR_ULEB: <span class="tok-type">u8</span> = <span class="tok-number">0xa0</span>;</span>
<span class="line" id="L1526"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> BIND_OPCODE_DO_BIND_ADD_ADDR_IMM_SCALED: <span class="tok-type">u8</span> = <span class="tok-number">0xb0</span>;</span>
<span class="line" id="L1527"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> BIND_OPCODE_DO_BIND_ULEB_TIMES_SKIPPING_ULEB: <span class="tok-type">u8</span> = <span class="tok-number">0xc0</span>;</span>
<span class="line" id="L1528"></span>
<span class="line" id="L1529"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> reloc_type_x86_64 = <span class="tok-kw">enum</span>(<span class="tok-type">u4</span>) {</span>
<span class="line" id="L1530">    <span class="tok-comment">/// for absolute addresses</span></span>
<span class="line" id="L1531">    X86_64_RELOC_UNSIGNED = <span class="tok-number">0</span>,</span>
<span class="line" id="L1532"></span>
<span class="line" id="L1533">    <span class="tok-comment">/// for signed 32-bit displacement</span></span>
<span class="line" id="L1534">    X86_64_RELOC_SIGNED,</span>
<span class="line" id="L1535"></span>
<span class="line" id="L1536">    <span class="tok-comment">/// a CALL/JMP instruction with 32-bit displacement</span></span>
<span class="line" id="L1537">    X86_64_RELOC_BRANCH,</span>
<span class="line" id="L1538"></span>
<span class="line" id="L1539">    <span class="tok-comment">/// a MOVQ load of a GOT entry</span></span>
<span class="line" id="L1540">    X86_64_RELOC_GOT_LOAD,</span>
<span class="line" id="L1541"></span>
<span class="line" id="L1542">    <span class="tok-comment">/// other GOT references</span></span>
<span class="line" id="L1543">    X86_64_RELOC_GOT,</span>
<span class="line" id="L1544"></span>
<span class="line" id="L1545">    <span class="tok-comment">/// must be followed by a X86_64_RELOC_UNSIGNED</span></span>
<span class="line" id="L1546">    X86_64_RELOC_SUBTRACTOR,</span>
<span class="line" id="L1547"></span>
<span class="line" id="L1548">    <span class="tok-comment">/// for signed 32-bit displacement with a -1 addend</span></span>
<span class="line" id="L1549">    X86_64_RELOC_SIGNED_1,</span>
<span class="line" id="L1550"></span>
<span class="line" id="L1551">    <span class="tok-comment">/// for signed 32-bit displacement with a -2 addend</span></span>
<span class="line" id="L1552">    X86_64_RELOC_SIGNED_2,</span>
<span class="line" id="L1553"></span>
<span class="line" id="L1554">    <span class="tok-comment">/// for signed 32-bit displacement with a -4 addend</span></span>
<span class="line" id="L1555">    X86_64_RELOC_SIGNED_4,</span>
<span class="line" id="L1556"></span>
<span class="line" id="L1557">    <span class="tok-comment">/// for thread local variables</span></span>
<span class="line" id="L1558">    X86_64_RELOC_TLV,</span>
<span class="line" id="L1559">};</span>
<span class="line" id="L1560"></span>
<span class="line" id="L1561"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> reloc_type_arm64 = <span class="tok-kw">enum</span>(<span class="tok-type">u4</span>) {</span>
<span class="line" id="L1562">    <span class="tok-comment">/// For pointers.</span></span>
<span class="line" id="L1563">    ARM64_RELOC_UNSIGNED = <span class="tok-number">0</span>,</span>
<span class="line" id="L1564"></span>
<span class="line" id="L1565">    <span class="tok-comment">/// Must be followed by a ARM64_RELOC_UNSIGNED.</span></span>
<span class="line" id="L1566">    ARM64_RELOC_SUBTRACTOR,</span>
<span class="line" id="L1567"></span>
<span class="line" id="L1568">    <span class="tok-comment">/// A B/BL instruction with 26-bit displacement.</span></span>
<span class="line" id="L1569">    ARM64_RELOC_BRANCH26,</span>
<span class="line" id="L1570"></span>
<span class="line" id="L1571">    <span class="tok-comment">/// Pc-rel distance to page of target.</span></span>
<span class="line" id="L1572">    ARM64_RELOC_PAGE21,</span>
<span class="line" id="L1573"></span>
<span class="line" id="L1574">    <span class="tok-comment">/// Offset within page, scaled by r_length.</span></span>
<span class="line" id="L1575">    ARM64_RELOC_PAGEOFF12,</span>
<span class="line" id="L1576"></span>
<span class="line" id="L1577">    <span class="tok-comment">/// Pc-rel distance to page of GOT slot.</span></span>
<span class="line" id="L1578">    ARM64_RELOC_GOT_LOAD_PAGE21,</span>
<span class="line" id="L1579"></span>
<span class="line" id="L1580">    <span class="tok-comment">/// Offset within page of GOT slot, scaled by r_length.</span></span>
<span class="line" id="L1581">    ARM64_RELOC_GOT_LOAD_PAGEOFF12,</span>
<span class="line" id="L1582"></span>
<span class="line" id="L1583">    <span class="tok-comment">/// For pointers to GOT slots.</span></span>
<span class="line" id="L1584">    ARM64_RELOC_POINTER_TO_GOT,</span>
<span class="line" id="L1585"></span>
<span class="line" id="L1586">    <span class="tok-comment">/// Pc-rel distance to page of TLVP slot.</span></span>
<span class="line" id="L1587">    ARM64_RELOC_TLVP_LOAD_PAGE21,</span>
<span class="line" id="L1588"></span>
<span class="line" id="L1589">    <span class="tok-comment">/// Offset within page of TLVP slot, scaled by r_length.</span></span>
<span class="line" id="L1590">    ARM64_RELOC_TLVP_LOAD_PAGEOFF12,</span>
<span class="line" id="L1591"></span>
<span class="line" id="L1592">    <span class="tok-comment">/// Must be followed by PAGE21 or PAGEOFF12.</span></span>
<span class="line" id="L1593">    ARM64_RELOC_ADDEND,</span>
<span class="line" id="L1594">};</span>
<span class="line" id="L1595"></span>
<span class="line" id="L1596"><span class="tok-comment">/// This symbol is a reference to an external non-lazy (data) symbol.</span></span>
<span class="line" id="L1597"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> REFERENCE_FLAG_UNDEFINED_NON_LAZY: <span class="tok-type">u16</span> = <span class="tok-number">0x0</span>;</span>
<span class="line" id="L1598"></span>
<span class="line" id="L1599"><span class="tok-comment">/// This symbol is a reference to an external lazy symbol—that is, to a function call.</span></span>
<span class="line" id="L1600"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> REFERENCE_FLAG_UNDEFINED_LAZY: <span class="tok-type">u16</span> = <span class="tok-number">0x1</span>;</span>
<span class="line" id="L1601"></span>
<span class="line" id="L1602"><span class="tok-comment">/// This symbol is defined in this module.</span></span>
<span class="line" id="L1603"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> REFERENCE_FLAG_DEFINED: <span class="tok-type">u16</span> = <span class="tok-number">0x2</span>;</span>
<span class="line" id="L1604"></span>
<span class="line" id="L1605"><span class="tok-comment">/// This symbol is defined in this module and is visible only to modules within this shared library.</span></span>
<span class="line" id="L1606"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> REFERENCE_FLAG_PRIVATE_DEFINED: <span class="tok-type">u16</span> = <span class="tok-number">3</span>;</span>
<span class="line" id="L1607"></span>
<span class="line" id="L1608"><span class="tok-comment">/// This symbol is defined in another module in this file, is a non-lazy (data) symbol, and is visible</span></span>
<span class="line" id="L1609"><span class="tok-comment">/// only to modules within this shared library.</span></span>
<span class="line" id="L1610"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> REFERENCE_FLAG_PRIVATE_UNDEFINED_NON_LAZY: <span class="tok-type">u16</span> = <span class="tok-number">4</span>;</span>
<span class="line" id="L1611"></span>
<span class="line" id="L1612"><span class="tok-comment">/// This symbol is defined in another module in this file, is a lazy (function) symbol, and is visible</span></span>
<span class="line" id="L1613"><span class="tok-comment">/// only to modules within this shared library.</span></span>
<span class="line" id="L1614"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> REFERENCE_FLAG_PRIVATE_UNDEFINED_LAZY: <span class="tok-type">u16</span> = <span class="tok-number">5</span>;</span>
<span class="line" id="L1615"></span>
<span class="line" id="L1616"><span class="tok-comment">/// Must be set for any defined symbol that is referenced by dynamic-loader APIs (such as dlsym and</span></span>
<span class="line" id="L1617"><span class="tok-comment">/// NSLookupSymbolInImage) and not ordinary undefined symbol references. The strip tool uses this bit</span></span>
<span class="line" id="L1618"><span class="tok-comment">/// to avoid removing symbols that must exist: If the symbol has this bit set, strip does not strip it.</span></span>
<span class="line" id="L1619"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> REFERENCED_DYNAMICALLY: <span class="tok-type">u16</span> = <span class="tok-number">0x10</span>;</span>
<span class="line" id="L1620"></span>
<span class="line" id="L1621"><span class="tok-comment">/// Used by the dynamic linker at runtime. Do not set this bit.</span></span>
<span class="line" id="L1622"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> N_DESC_DISCARDED: <span class="tok-type">u16</span> = <span class="tok-number">0x20</span>;</span>
<span class="line" id="L1623"></span>
<span class="line" id="L1624"><span class="tok-comment">/// Indicates that this symbol is a weak reference. If the dynamic linker cannot find a definition</span></span>
<span class="line" id="L1625"><span class="tok-comment">/// for this symbol, it sets the address of this symbol to 0. The static linker sets this symbol given</span></span>
<span class="line" id="L1626"><span class="tok-comment">/// the appropriate weak-linking flags.</span></span>
<span class="line" id="L1627"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> N_WEAK_REF: <span class="tok-type">u16</span> = <span class="tok-number">0x40</span>;</span>
<span class="line" id="L1628"></span>
<span class="line" id="L1629"><span class="tok-comment">/// Indicates that this symbol is a weak definition. If the static linker or the dynamic linker finds</span></span>
<span class="line" id="L1630"><span class="tok-comment">/// another (non-weak) definition for this symbol, the weak definition is ignored. Only symbols in a</span></span>
<span class="line" id="L1631"><span class="tok-comment">/// coalesced section (page 23) can be marked as a weak definition.</span></span>
<span class="line" id="L1632"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> N_WEAK_DEF: <span class="tok-type">u16</span> = <span class="tok-number">0x80</span>;</span>
<span class="line" id="L1633"></span>
<span class="line" id="L1634"><span class="tok-comment">/// The N_SYMBOL_RESOLVER bit of the n_desc field indicates that the</span></span>
<span class="line" id="L1635"><span class="tok-comment">/// that the function is actually a resolver function and should</span></span>
<span class="line" id="L1636"><span class="tok-comment">/// be called to get the address of the real function to use.</span></span>
<span class="line" id="L1637"><span class="tok-comment">/// This bit is only available in .o files (MH_OBJECT filetype)</span></span>
<span class="line" id="L1638"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> N_SYMBOL_RESOLVER: <span class="tok-type">u16</span> = <span class="tok-number">0x100</span>;</span>
<span class="line" id="L1639"></span>
<span class="line" id="L1640"><span class="tok-comment">// The following are used on the flags byte of a terminal node in the export information.</span>
</span>
<span class="line" id="L1641"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> EXPORT_SYMBOL_FLAGS_KIND_MASK: <span class="tok-type">u8</span> = <span class="tok-number">0x03</span>;</span>
<span class="line" id="L1642"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> EXPORT_SYMBOL_FLAGS_KIND_REGULAR: <span class="tok-type">u8</span> = <span class="tok-number">0x00</span>;</span>
<span class="line" id="L1643"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> EXPORT_SYMBOL_FLAGS_KIND_THREAD_LOCAL: <span class="tok-type">u8</span> = <span class="tok-number">0x01</span>;</span>
<span class="line" id="L1644"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> EXPORT_SYMBOL_FLAGS_KIND_ABSOLUTE: <span class="tok-type">u8</span> = <span class="tok-number">0x02</span>;</span>
<span class="line" id="L1645"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> EXPORT_SYMBOL_FLAGS_KIND_WEAK_DEFINITION: <span class="tok-type">u8</span> = <span class="tok-number">0x04</span>;</span>
<span class="line" id="L1646"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> EXPORT_SYMBOL_FLAGS_REEXPORT: <span class="tok-type">u8</span> = <span class="tok-number">0x08</span>;</span>
<span class="line" id="L1647"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> EXPORT_SYMBOL_FLAGS_STUB_AND_RESOLVER: <span class="tok-type">u8</span> = <span class="tok-number">0x10</span>;</span>
<span class="line" id="L1648"></span>
<span class="line" id="L1649"><span class="tok-comment">// An indirect symbol table entry is simply a 32bit index into the symbol table</span>
</span>
<span class="line" id="L1650"><span class="tok-comment">// to the symbol that the pointer or stub is refering to.  Unless it is for a</span>
</span>
<span class="line" id="L1651"><span class="tok-comment">// non-lazy symbol pointer section for a defined symbol which strip(1) as</span>
</span>
<span class="line" id="L1652"><span class="tok-comment">// removed.  In which case it has the value INDIRECT_SYMBOL_LOCAL.  If the</span>
</span>
<span class="line" id="L1653"><span class="tok-comment">// symbol was also absolute INDIRECT_SYMBOL_ABS is or'ed with that.</span>
</span>
<span class="line" id="L1654"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> INDIRECT_SYMBOL_LOCAL: <span class="tok-type">u32</span> = <span class="tok-number">0x80000000</span>;</span>
<span class="line" id="L1655"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> INDIRECT_SYMBOL_ABS: <span class="tok-type">u32</span> = <span class="tok-number">0x40000000</span>;</span>
<span class="line" id="L1656"></span>
<span class="line" id="L1657"><span class="tok-comment">// Codesign consts and structs taken from:</span>
</span>
<span class="line" id="L1658"><span class="tok-comment">// https://opensource.apple.com/source/xnu/xnu-6153.81.5/osfmk/kern/cs_blobs.h.auto.html</span>
</span>
<span class="line" id="L1659"></span>
<span class="line" id="L1660"><span class="tok-comment">/// Single Requirement blob</span></span>
<span class="line" id="L1661"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> CSMAGIC_REQUIREMENT: <span class="tok-type">u32</span> = <span class="tok-number">0xfade0c00</span>;</span>
<span class="line" id="L1662"><span class="tok-comment">/// Requirements vector (internal requirements)</span></span>
<span class="line" id="L1663"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> CSMAGIC_REQUIREMENTS: <span class="tok-type">u32</span> = <span class="tok-number">0xfade0c01</span>;</span>
<span class="line" id="L1664"><span class="tok-comment">/// CodeDirectory blob</span></span>
<span class="line" id="L1665"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> CSMAGIC_CODEDIRECTORY: <span class="tok-type">u32</span> = <span class="tok-number">0xfade0c02</span>;</span>
<span class="line" id="L1666"><span class="tok-comment">/// embedded form of signature data</span></span>
<span class="line" id="L1667"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> CSMAGIC_EMBEDDED_SIGNATURE: <span class="tok-type">u32</span> = <span class="tok-number">0xfade0cc0</span>;</span>
<span class="line" id="L1668"><span class="tok-comment">/// XXX</span></span>
<span class="line" id="L1669"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> CSMAGIC_EMBEDDED_SIGNATURE_OLD: <span class="tok-type">u32</span> = <span class="tok-number">0xfade0b02</span>;</span>
<span class="line" id="L1670"><span class="tok-comment">/// Embedded entitlements</span></span>
<span class="line" id="L1671"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> CSMAGIC_EMBEDDED_ENTITLEMENTS: <span class="tok-type">u32</span> = <span class="tok-number">0xfade7171</span>;</span>
<span class="line" id="L1672"><span class="tok-comment">/// Embedded DER encoded entitlements</span></span>
<span class="line" id="L1673"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> CSMAGIC_EMBEDDED_DER_ENTITLEMENTS: <span class="tok-type">u32</span> = <span class="tok-number">0xfade7172</span>;</span>
<span class="line" id="L1674"><span class="tok-comment">/// Multi-arch collection of embedded signatures</span></span>
<span class="line" id="L1675"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> CSMAGIC_DETACHED_SIGNATURE: <span class="tok-type">u32</span> = <span class="tok-number">0xfade0cc1</span>;</span>
<span class="line" id="L1676"><span class="tok-comment">/// CMS Signature, among other things</span></span>
<span class="line" id="L1677"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> CSMAGIC_BLOBWRAPPER: <span class="tok-type">u32</span> = <span class="tok-number">0xfade0b01</span>;</span>
<span class="line" id="L1678"></span>
<span class="line" id="L1679"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> CS_SUPPORTSSCATTER: <span class="tok-type">u32</span> = <span class="tok-number">0x20100</span>;</span>
<span class="line" id="L1680"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> CS_SUPPORTSTEAMID: <span class="tok-type">u32</span> = <span class="tok-number">0x20200</span>;</span>
<span class="line" id="L1681"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> CS_SUPPORTSCODELIMIT64: <span class="tok-type">u32</span> = <span class="tok-number">0x20300</span>;</span>
<span class="line" id="L1682"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> CS_SUPPORTSEXECSEG: <span class="tok-type">u32</span> = <span class="tok-number">0x20400</span>;</span>
<span class="line" id="L1683"></span>
<span class="line" id="L1684"><span class="tok-comment">/// Slot index for CodeDirectory</span></span>
<span class="line" id="L1685"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> CSSLOT_CODEDIRECTORY: <span class="tok-type">u32</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L1686"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> CSSLOT_INFOSLOT: <span class="tok-type">u32</span> = <span class="tok-number">1</span>;</span>
<span class="line" id="L1687"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> CSSLOT_REQUIREMENTS: <span class="tok-type">u32</span> = <span class="tok-number">2</span>;</span>
<span class="line" id="L1688"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> CSSLOT_RESOURCEDIR: <span class="tok-type">u32</span> = <span class="tok-number">3</span>;</span>
<span class="line" id="L1689"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> CSSLOT_APPLICATION: <span class="tok-type">u32</span> = <span class="tok-number">4</span>;</span>
<span class="line" id="L1690"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> CSSLOT_ENTITLEMENTS: <span class="tok-type">u32</span> = <span class="tok-number">5</span>;</span>
<span class="line" id="L1691"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> CSSLOT_DER_ENTITLEMENTS: <span class="tok-type">u32</span> = <span class="tok-number">7</span>;</span>
<span class="line" id="L1692"></span>
<span class="line" id="L1693"><span class="tok-comment">/// first alternate CodeDirectory, if any</span></span>
<span class="line" id="L1694"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> CSSLOT_ALTERNATE_CODEDIRECTORIES: <span class="tok-type">u32</span> = <span class="tok-number">0x1000</span>;</span>
<span class="line" id="L1695"><span class="tok-comment">/// Max number of alternate CD slots</span></span>
<span class="line" id="L1696"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> CSSLOT_ALTERNATE_CODEDIRECTORY_MAX: <span class="tok-type">u32</span> = <span class="tok-number">5</span>;</span>
<span class="line" id="L1697"><span class="tok-comment">/// One past the last</span></span>
<span class="line" id="L1698"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> CSSLOT_ALTERNATE_CODEDIRECTORY_LIMIT: <span class="tok-type">u32</span> = CSSLOT_ALTERNATE_CODEDIRECTORIES + CSSLOT_ALTERNATE_CODEDIRECTORY_MAX;</span>
<span class="line" id="L1699"></span>
<span class="line" id="L1700"><span class="tok-comment">/// CMS Signature</span></span>
<span class="line" id="L1701"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> CSSLOT_SIGNATURESLOT: <span class="tok-type">u32</span> = <span class="tok-number">0x10000</span>;</span>
<span class="line" id="L1702"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> CSSLOT_IDENTIFICATIONSLOT: <span class="tok-type">u32</span> = <span class="tok-number">0x10001</span>;</span>
<span class="line" id="L1703"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> CSSLOT_TICKETSLOT: <span class="tok-type">u32</span> = <span class="tok-number">0x10002</span>;</span>
<span class="line" id="L1704"></span>
<span class="line" id="L1705"><span class="tok-comment">/// Compat with amfi</span></span>
<span class="line" id="L1706"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> CSTYPE_INDEX_REQUIREMENTS: <span class="tok-type">u32</span> = <span class="tok-number">0x00000002</span>;</span>
<span class="line" id="L1707"><span class="tok-comment">/// Compat with amfi</span></span>
<span class="line" id="L1708"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> CSTYPE_INDEX_ENTITLEMENTS: <span class="tok-type">u32</span> = <span class="tok-number">0x00000005</span>;</span>
<span class="line" id="L1709"></span>
<span class="line" id="L1710"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> CS_HASHTYPE_SHA1: <span class="tok-type">u8</span> = <span class="tok-number">1</span>;</span>
<span class="line" id="L1711"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> CS_HASHTYPE_SHA256: <span class="tok-type">u8</span> = <span class="tok-number">2</span>;</span>
<span class="line" id="L1712"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> CS_HASHTYPE_SHA256_TRUNCATED: <span class="tok-type">u8</span> = <span class="tok-number">3</span>;</span>
<span class="line" id="L1713"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> CS_HASHTYPE_SHA384: <span class="tok-type">u8</span> = <span class="tok-number">4</span>;</span>
<span class="line" id="L1714"></span>
<span class="line" id="L1715"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> CS_SHA1_LEN: <span class="tok-type">u32</span> = <span class="tok-number">20</span>;</span>
<span class="line" id="L1716"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> CS_SHA256_LEN: <span class="tok-type">u32</span> = <span class="tok-number">32</span>;</span>
<span class="line" id="L1717"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> CS_SHA256_TRUNCATED_LEN: <span class="tok-type">u32</span> = <span class="tok-number">20</span>;</span>
<span class="line" id="L1718"></span>
<span class="line" id="L1719"><span class="tok-comment">/// Always - larger hashes are truncated</span></span>
<span class="line" id="L1720"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> CS_CDHASH_LEN: <span class="tok-type">u32</span> = <span class="tok-number">20</span>;</span>
<span class="line" id="L1721"><span class="tok-comment">/// Max size of the hash we'll support</span></span>
<span class="line" id="L1722"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> CS_HASH_MAX_SIZE: <span class="tok-type">u32</span> = <span class="tok-number">48</span>;</span>
<span class="line" id="L1723"></span>
<span class="line" id="L1724"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> CS_SIGNER_TYPE_UNKNOWN: <span class="tok-type">u32</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L1725"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> CS_SIGNER_TYPE_LEGACYVPN: <span class="tok-type">u32</span> = <span class="tok-number">5</span>;</span>
<span class="line" id="L1726"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> CS_SIGNER_TYPE_MAC_APP_STORE: <span class="tok-type">u32</span> = <span class="tok-number">6</span>;</span>
<span class="line" id="L1727"></span>
<span class="line" id="L1728"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> CS_ADHOC: <span class="tok-type">u32</span> = <span class="tok-number">0x2</span>;</span>
<span class="line" id="L1729"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> CS_LINKER_SIGNED: <span class="tok-type">u32</span> = <span class="tok-number">0x20000</span>;</span>
<span class="line" id="L1730"></span>
<span class="line" id="L1731"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> CS_EXECSEG_MAIN_BINARY: <span class="tok-type">u32</span> = <span class="tok-number">0x1</span>;</span>
<span class="line" id="L1732"></span>
<span class="line" id="L1733"><span class="tok-comment">/// This CodeDirectory is tailored specfically at version 0x20400.</span></span>
<span class="line" id="L1734"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> CodeDirectory = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L1735">    <span class="tok-comment">/// Magic number (CSMAGIC_CODEDIRECTORY)</span></span>
<span class="line" id="L1736">    magic: <span class="tok-type">u32</span>,</span>
<span class="line" id="L1737"></span>
<span class="line" id="L1738">    <span class="tok-comment">/// Total length of CodeDirectory blob</span></span>
<span class="line" id="L1739">    length: <span class="tok-type">u32</span>,</span>
<span class="line" id="L1740"></span>
<span class="line" id="L1741">    <span class="tok-comment">/// Compatibility version</span></span>
<span class="line" id="L1742">    version: <span class="tok-type">u32</span>,</span>
<span class="line" id="L1743"></span>
<span class="line" id="L1744">    <span class="tok-comment">/// Setup and mode flags</span></span>
<span class="line" id="L1745">    flags: <span class="tok-type">u32</span>,</span>
<span class="line" id="L1746"></span>
<span class="line" id="L1747">    <span class="tok-comment">/// Offset of hash slot element at index zero</span></span>
<span class="line" id="L1748">    hashOffset: <span class="tok-type">u32</span>,</span>
<span class="line" id="L1749"></span>
<span class="line" id="L1750">    <span class="tok-comment">/// Offset of identifier string</span></span>
<span class="line" id="L1751">    identOffset: <span class="tok-type">u32</span>,</span>
<span class="line" id="L1752"></span>
<span class="line" id="L1753">    <span class="tok-comment">/// Number of special hash slots</span></span>
<span class="line" id="L1754">    nSpecialSlots: <span class="tok-type">u32</span>,</span>
<span class="line" id="L1755"></span>
<span class="line" id="L1756">    <span class="tok-comment">/// Number of ordinary (code) hash slots</span></span>
<span class="line" id="L1757">    nCodeSlots: <span class="tok-type">u32</span>,</span>
<span class="line" id="L1758"></span>
<span class="line" id="L1759">    <span class="tok-comment">/// Limit to main image signature range</span></span>
<span class="line" id="L1760">    codeLimit: <span class="tok-type">u32</span>,</span>
<span class="line" id="L1761"></span>
<span class="line" id="L1762">    <span class="tok-comment">/// Size of each hash in bytes</span></span>
<span class="line" id="L1763">    hashSize: <span class="tok-type">u8</span>,</span>
<span class="line" id="L1764"></span>
<span class="line" id="L1765">    <span class="tok-comment">/// Type of hash (cdHashType* constants)</span></span>
<span class="line" id="L1766">    hashType: <span class="tok-type">u8</span>,</span>
<span class="line" id="L1767"></span>
<span class="line" id="L1768">    <span class="tok-comment">/// Platform identifier; zero if not platform binary</span></span>
<span class="line" id="L1769">    platform: <span class="tok-type">u8</span>,</span>
<span class="line" id="L1770"></span>
<span class="line" id="L1771">    <span class="tok-comment">/// log2(page size in bytes); 0 =&gt; infinite</span></span>
<span class="line" id="L1772">    pageSize: <span class="tok-type">u8</span>,</span>
<span class="line" id="L1773"></span>
<span class="line" id="L1774">    <span class="tok-comment">/// Unused (must be zero)</span></span>
<span class="line" id="L1775">    spare2: <span class="tok-type">u32</span>,</span>
<span class="line" id="L1776"></span>
<span class="line" id="L1777">    <span class="tok-comment">///</span></span>
<span class="line" id="L1778">    scatterOffset: <span class="tok-type">u32</span>,</span>
<span class="line" id="L1779"></span>
<span class="line" id="L1780">    <span class="tok-comment">///</span></span>
<span class="line" id="L1781">    teamOffset: <span class="tok-type">u32</span>,</span>
<span class="line" id="L1782"></span>
<span class="line" id="L1783">    <span class="tok-comment">///</span></span>
<span class="line" id="L1784">    spare3: <span class="tok-type">u32</span>,</span>
<span class="line" id="L1785"></span>
<span class="line" id="L1786">    <span class="tok-comment">///</span></span>
<span class="line" id="L1787">    codeLimit64: <span class="tok-type">u64</span>,</span>
<span class="line" id="L1788"></span>
<span class="line" id="L1789">    <span class="tok-comment">/// Offset of executable segment</span></span>
<span class="line" id="L1790">    execSegBase: <span class="tok-type">u64</span>,</span>
<span class="line" id="L1791"></span>
<span class="line" id="L1792">    <span class="tok-comment">/// Limit of executable segment</span></span>
<span class="line" id="L1793">    execSegLimit: <span class="tok-type">u64</span>,</span>
<span class="line" id="L1794"></span>
<span class="line" id="L1795">    <span class="tok-comment">/// Executable segment flags</span></span>
<span class="line" id="L1796">    execSegFlags: <span class="tok-type">u64</span>,</span>
<span class="line" id="L1797">};</span>
<span class="line" id="L1798"></span>
<span class="line" id="L1799"><span class="tok-comment">/// Structure of an embedded-signature SuperBlob</span></span>
<span class="line" id="L1800"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> BlobIndex = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L1801">    <span class="tok-comment">/// Type of entry</span></span>
<span class="line" id="L1802">    @&quot;type&quot;: <span class="tok-type">u32</span>,</span>
<span class="line" id="L1803"></span>
<span class="line" id="L1804">    <span class="tok-comment">/// Offset of entry</span></span>
<span class="line" id="L1805">    offset: <span class="tok-type">u32</span>,</span>
<span class="line" id="L1806">};</span>
<span class="line" id="L1807"></span>
<span class="line" id="L1808"><span class="tok-comment">/// This structure is followed by GenericBlobs in no particular</span></span>
<span class="line" id="L1809"><span class="tok-comment">/// order as indicated by offsets in index</span></span>
<span class="line" id="L1810"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SuperBlob = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L1811">    <span class="tok-comment">/// Magic number</span></span>
<span class="line" id="L1812">    magic: <span class="tok-type">u32</span>,</span>
<span class="line" id="L1813"></span>
<span class="line" id="L1814">    <span class="tok-comment">/// Total length of SuperBlob</span></span>
<span class="line" id="L1815">    length: <span class="tok-type">u32</span>,</span>
<span class="line" id="L1816"></span>
<span class="line" id="L1817">    <span class="tok-comment">/// Number of index BlobIndex entries following this struct</span></span>
<span class="line" id="L1818">    count: <span class="tok-type">u32</span>,</span>
<span class="line" id="L1819">};</span>
<span class="line" id="L1820"></span>
<span class="line" id="L1821"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> GenericBlob = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L1822">    <span class="tok-comment">/// Magic number</span></span>
<span class="line" id="L1823">    magic: <span class="tok-type">u32</span>,</span>
<span class="line" id="L1824"></span>
<span class="line" id="L1825">    <span class="tok-comment">/// Total length of blob</span></span>
<span class="line" id="L1826">    length: <span class="tok-type">u32</span>,</span>
<span class="line" id="L1827">};</span>
<span class="line" id="L1828"></span>
<span class="line" id="L1829"><span class="tok-comment">/// The LC_DATA_IN_CODE load commands uses a linkedit_data_command</span></span>
<span class="line" id="L1830"><span class="tok-comment">/// to point to an array of data_in_code_entry entries. Each entry</span></span>
<span class="line" id="L1831"><span class="tok-comment">/// describes a range of data in a code section.</span></span>
<span class="line" id="L1832"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> data_in_code_entry = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L1833">    <span class="tok-comment">/// From mach_header to start of data range.</span></span>
<span class="line" id="L1834">    offset: <span class="tok-type">u32</span>,</span>
<span class="line" id="L1835"></span>
<span class="line" id="L1836">    <span class="tok-comment">/// Number of bytes in data range.</span></span>
<span class="line" id="L1837">    length: <span class="tok-type">u16</span>,</span>
<span class="line" id="L1838"></span>
<span class="line" id="L1839">    <span class="tok-comment">/// A DICE_KIND value.</span></span>
<span class="line" id="L1840">    kind: <span class="tok-type">u16</span>,</span>
<span class="line" id="L1841">};</span>
<span class="line" id="L1842"></span>
<span class="line" id="L1843"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> LoadCommandIterator = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L1844">    ncmds: <span class="tok-type">usize</span>,</span>
<span class="line" id="L1845">    buffer: []<span class="tok-kw">align</span>(<span class="tok-builtin">@alignOf</span>(<span class="tok-type">u64</span>)) <span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L1846">    index: <span class="tok-type">usize</span> = <span class="tok-number">0</span>,</span>
<span class="line" id="L1847"></span>
<span class="line" id="L1848">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> LoadCommand = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L1849">        hdr: load_command,</span>
<span class="line" id="L1850">        data: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L1851"></span>
<span class="line" id="L1852">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">cmd</span>(lc: LoadCommand) LC {</span>
<span class="line" id="L1853">            <span class="tok-kw">return</span> lc.hdr.cmd;</span>
<span class="line" id="L1854">        }</span>
<span class="line" id="L1855"></span>
<span class="line" id="L1856">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">cmdsize</span>(lc: LoadCommand) <span class="tok-type">u32</span> {</span>
<span class="line" id="L1857">            <span class="tok-kw">return</span> lc.hdr.cmdsize;</span>
<span class="line" id="L1858">        }</span>
<span class="line" id="L1859"></span>
<span class="line" id="L1860">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">cast</span>(lc: LoadCommand, <span class="tok-kw">comptime</span> Cmd: <span class="tok-type">type</span>) ?Cmd {</span>
<span class="line" id="L1861">            <span class="tok-kw">if</span> (lc.data.len &lt; <span class="tok-builtin">@sizeOf</span>(Cmd)) <span class="tok-kw">return</span> <span class="tok-null">null</span>;</span>
<span class="line" id="L1862">            <span class="tok-kw">return</span> <span class="tok-builtin">@ptrCast</span>(*<span class="tok-kw">const</span> Cmd, <span class="tok-builtin">@alignCast</span>(<span class="tok-builtin">@alignOf</span>(Cmd), &amp;lc.data[<span class="tok-number">0</span>])).*;</span>
<span class="line" id="L1863">        }</span>
<span class="line" id="L1864"></span>
<span class="line" id="L1865">        <span class="tok-comment">/// Asserts LoadCommand is of type segment_command_64.</span></span>
<span class="line" id="L1866">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">getSections</span>(lc: LoadCommand) []<span class="tok-kw">const</span> section_64 {</span>
<span class="line" id="L1867">            <span class="tok-kw">const</span> segment_lc = lc.cast(segment_command_64).?;</span>
<span class="line" id="L1868">            <span class="tok-kw">if</span> (segment_lc.nsects == <span class="tok-number">0</span>) <span class="tok-kw">return</span> &amp;[<span class="tok-number">0</span>]section_64{};</span>
<span class="line" id="L1869">            <span class="tok-kw">const</span> data = lc.data[<span class="tok-builtin">@sizeOf</span>(segment_command_64)..];</span>
<span class="line" id="L1870">            <span class="tok-kw">const</span> sections = <span class="tok-builtin">@ptrCast</span>(</span>
<span class="line" id="L1871">                [*]<span class="tok-kw">const</span> section_64,</span>
<span class="line" id="L1872">                <span class="tok-builtin">@alignCast</span>(<span class="tok-builtin">@alignOf</span>(section_64), &amp;data[<span class="tok-number">0</span>]),</span>
<span class="line" id="L1873">            )[<span class="tok-number">0</span>..segment_lc.nsects];</span>
<span class="line" id="L1874">            <span class="tok-kw">return</span> sections;</span>
<span class="line" id="L1875">        }</span>
<span class="line" id="L1876"></span>
<span class="line" id="L1877">        <span class="tok-comment">/// Asserts LoadCommand is of type dylib_command.</span></span>
<span class="line" id="L1878">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">getDylibPathName</span>(lc: LoadCommand) []<span class="tok-kw">const</span> <span class="tok-type">u8</span> {</span>
<span class="line" id="L1879">            <span class="tok-kw">const</span> dylib_lc = lc.cast(dylib_command).?;</span>
<span class="line" id="L1880">            <span class="tok-kw">const</span> data = lc.data[dylib_lc.dylib.name..];</span>
<span class="line" id="L1881">            <span class="tok-kw">return</span> mem.sliceTo(data, <span class="tok-number">0</span>);</span>
<span class="line" id="L1882">        }</span>
<span class="line" id="L1883"></span>
<span class="line" id="L1884">        <span class="tok-comment">/// Asserts LoadCommand is of type rpath_command.</span></span>
<span class="line" id="L1885">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">getRpathPathName</span>(lc: LoadCommand) []<span class="tok-kw">const</span> <span class="tok-type">u8</span> {</span>
<span class="line" id="L1886">            <span class="tok-kw">const</span> rpath_lc = lc.cast(rpath_command).?;</span>
<span class="line" id="L1887">            <span class="tok-kw">const</span> data = lc.data[rpath_lc.path..];</span>
<span class="line" id="L1888">            <span class="tok-kw">return</span> mem.sliceTo(data, <span class="tok-number">0</span>);</span>
<span class="line" id="L1889">        }</span>
<span class="line" id="L1890">    };</span>
<span class="line" id="L1891"></span>
<span class="line" id="L1892">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">next</span>(it: *LoadCommandIterator) ?LoadCommand {</span>
<span class="line" id="L1893">        <span class="tok-kw">if</span> (it.index &gt;= it.ncmds) <span class="tok-kw">return</span> <span class="tok-null">null</span>;</span>
<span class="line" id="L1894"></span>
<span class="line" id="L1895">        <span class="tok-kw">const</span> hdr = <span class="tok-builtin">@ptrCast</span>(</span>
<span class="line" id="L1896">            *<span class="tok-kw">const</span> load_command,</span>
<span class="line" id="L1897">            <span class="tok-builtin">@alignCast</span>(<span class="tok-builtin">@alignOf</span>(load_command), &amp;it.buffer[<span class="tok-number">0</span>]),</span>
<span class="line" id="L1898">        ).*;</span>
<span class="line" id="L1899">        <span class="tok-kw">const</span> cmd = LoadCommand{</span>
<span class="line" id="L1900">            .hdr = hdr,</span>
<span class="line" id="L1901">            .data = it.buffer[<span class="tok-number">0</span>..hdr.cmdsize],</span>
<span class="line" id="L1902">        };</span>
<span class="line" id="L1903"></span>
<span class="line" id="L1904">        it.buffer = <span class="tok-builtin">@alignCast</span>(<span class="tok-builtin">@alignOf</span>(<span class="tok-type">u64</span>), it.buffer[hdr.cmdsize..]);</span>
<span class="line" id="L1905">        it.index += <span class="tok-number">1</span>;</span>
<span class="line" id="L1906"></span>
<span class="line" id="L1907">        <span class="tok-kw">return</span> cmd;</span>
<span class="line" id="L1908">    }</span>
<span class="line" id="L1909">};</span>
<span class="line" id="L1910"></span>
</code></pre></body>
</html>