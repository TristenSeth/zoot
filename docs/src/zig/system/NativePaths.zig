<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">    <title>zig/system/NativePaths.zig - source view</title>
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
<pre><code><span class="line" id="L1"><span class="tok-kw">const</span> std = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;../../std.zig&quot;</span>);</span>
<span class="line" id="L2"><span class="tok-kw">const</span> builtin = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;builtin&quot;</span>);</span>
<span class="line" id="L3"><span class="tok-kw">const</span> ArrayList = std.ArrayList;</span>
<span class="line" id="L4"><span class="tok-kw">const</span> Allocator = std.mem.Allocator;</span>
<span class="line" id="L5"><span class="tok-kw">const</span> process = std.process;</span>
<span class="line" id="L6"><span class="tok-kw">const</span> mem = std.mem;</span>
<span class="line" id="L7"></span>
<span class="line" id="L8"><span class="tok-kw">const</span> NativePaths = <span class="tok-builtin">@This</span>();</span>
<span class="line" id="L9"><span class="tok-kw">const</span> NativeTargetInfo = std.zig.system.NativeTargetInfo;</span>
<span class="line" id="L10"></span>
<span class="line" id="L11">include_dirs: ArrayList([:<span class="tok-number">0</span>]<span class="tok-type">u8</span>),</span>
<span class="line" id="L12">lib_dirs: ArrayList([:<span class="tok-number">0</span>]<span class="tok-type">u8</span>),</span>
<span class="line" id="L13">framework_dirs: ArrayList([:<span class="tok-number">0</span>]<span class="tok-type">u8</span>),</span>
<span class="line" id="L14">rpaths: ArrayList([:<span class="tok-number">0</span>]<span class="tok-type">u8</span>),</span>
<span class="line" id="L15">warnings: ArrayList([:<span class="tok-number">0</span>]<span class="tok-type">u8</span>),</span>
<span class="line" id="L16"></span>
<span class="line" id="L17"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">detect</span>(allocator: Allocator, native_info: NativeTargetInfo) !NativePaths {</span>
<span class="line" id="L18">    <span class="tok-kw">const</span> native_target = native_info.target;</span>
<span class="line" id="L19"></span>
<span class="line" id="L20">    <span class="tok-kw">var</span> self: NativePaths = .{</span>
<span class="line" id="L21">        .include_dirs = ArrayList([:<span class="tok-number">0</span>]<span class="tok-type">u8</span>).init(allocator),</span>
<span class="line" id="L22">        .lib_dirs = ArrayList([:<span class="tok-number">0</span>]<span class="tok-type">u8</span>).init(allocator),</span>
<span class="line" id="L23">        .framework_dirs = ArrayList([:<span class="tok-number">0</span>]<span class="tok-type">u8</span>).init(allocator),</span>
<span class="line" id="L24">        .rpaths = ArrayList([:<span class="tok-number">0</span>]<span class="tok-type">u8</span>).init(allocator),</span>
<span class="line" id="L25">        .warnings = ArrayList([:<span class="tok-number">0</span>]<span class="tok-type">u8</span>).init(allocator),</span>
<span class="line" id="L26">    };</span>
<span class="line" id="L27">    <span class="tok-kw">errdefer</span> self.deinit();</span>
<span class="line" id="L28"></span>
<span class="line" id="L29">    <span class="tok-kw">var</span> is_nix = <span class="tok-null">false</span>;</span>
<span class="line" id="L30">    <span class="tok-kw">if</span> (process.getEnvVarOwned(allocator, <span class="tok-str">&quot;NIX_CFLAGS_COMPILE&quot;</span>)) |nix_cflags_compile| {</span>
<span class="line" id="L31">        <span class="tok-kw">defer</span> allocator.free(nix_cflags_compile);</span>
<span class="line" id="L32"></span>
<span class="line" id="L33">        is_nix = <span class="tok-null">true</span>;</span>
<span class="line" id="L34">        <span class="tok-kw">var</span> it = mem.tokenize(<span class="tok-type">u8</span>, nix_cflags_compile, <span class="tok-str">&quot; &quot;</span>);</span>
<span class="line" id="L35">        <span class="tok-kw">while</span> (<span class="tok-null">true</span>) {</span>
<span class="line" id="L36">            <span class="tok-kw">const</span> word = it.next() <span class="tok-kw">orelse</span> <span class="tok-kw">break</span>;</span>
<span class="line" id="L37">            <span class="tok-kw">if</span> (mem.eql(<span class="tok-type">u8</span>, word, <span class="tok-str">&quot;-isystem&quot;</span>)) {</span>
<span class="line" id="L38">                <span class="tok-kw">const</span> include_path = it.next() <span class="tok-kw">orelse</span> {</span>
<span class="line" id="L39">                    <span class="tok-kw">try</span> self.addWarning(<span class="tok-str">&quot;Expected argument after -isystem in NIX_CFLAGS_COMPILE&quot;</span>);</span>
<span class="line" id="L40">                    <span class="tok-kw">break</span>;</span>
<span class="line" id="L41">                };</span>
<span class="line" id="L42">                <span class="tok-kw">try</span> self.addIncludeDir(include_path);</span>
<span class="line" id="L43">            } <span class="tok-kw">else</span> {</span>
<span class="line" id="L44">                <span class="tok-kw">if</span> (mem.startsWith(<span class="tok-type">u8</span>, word, <span class="tok-str">&quot;-frandom-seed=&quot;</span>)) {</span>
<span class="line" id="L45">                    <span class="tok-kw">continue</span>;</span>
<span class="line" id="L46">                }</span>
<span class="line" id="L47">                <span class="tok-kw">try</span> self.addWarningFmt(<span class="tok-str">&quot;Unrecognized C flag from NIX_CFLAGS_COMPILE: {s}&quot;</span>, .{word});</span>
<span class="line" id="L48">            }</span>
<span class="line" id="L49">        }</span>
<span class="line" id="L50">    } <span class="tok-kw">else</span> |err| <span class="tok-kw">switch</span> (err) {</span>
<span class="line" id="L51">        <span class="tok-kw">error</span>.InvalidUtf8 =&gt; {},</span>
<span class="line" id="L52">        <span class="tok-kw">error</span>.EnvironmentVariableNotFound =&gt; {},</span>
<span class="line" id="L53">        <span class="tok-kw">error</span>.OutOfMemory =&gt; |e| <span class="tok-kw">return</span> e,</span>
<span class="line" id="L54">    }</span>
<span class="line" id="L55">    <span class="tok-kw">if</span> (process.getEnvVarOwned(allocator, <span class="tok-str">&quot;NIX_LDFLAGS&quot;</span>)) |nix_ldflags| {</span>
<span class="line" id="L56">        <span class="tok-kw">defer</span> allocator.free(nix_ldflags);</span>
<span class="line" id="L57"></span>
<span class="line" id="L58">        is_nix = <span class="tok-null">true</span>;</span>
<span class="line" id="L59">        <span class="tok-kw">var</span> it = mem.tokenize(<span class="tok-type">u8</span>, nix_ldflags, <span class="tok-str">&quot; &quot;</span>);</span>
<span class="line" id="L60">        <span class="tok-kw">while</span> (<span class="tok-null">true</span>) {</span>
<span class="line" id="L61">            <span class="tok-kw">const</span> word = it.next() <span class="tok-kw">orelse</span> <span class="tok-kw">break</span>;</span>
<span class="line" id="L62">            <span class="tok-kw">if</span> (mem.eql(<span class="tok-type">u8</span>, word, <span class="tok-str">&quot;-rpath&quot;</span>)) {</span>
<span class="line" id="L63">                <span class="tok-kw">const</span> rpath = it.next() <span class="tok-kw">orelse</span> {</span>
<span class="line" id="L64">                    <span class="tok-kw">try</span> self.addWarning(<span class="tok-str">&quot;Expected argument after -rpath in NIX_LDFLAGS&quot;</span>);</span>
<span class="line" id="L65">                    <span class="tok-kw">break</span>;</span>
<span class="line" id="L66">                };</span>
<span class="line" id="L67">                <span class="tok-kw">try</span> self.addRPath(rpath);</span>
<span class="line" id="L68">            } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (word.len &gt; <span class="tok-number">2</span> <span class="tok-kw">and</span> word[<span class="tok-number">0</span>] == <span class="tok-str">'-'</span> <span class="tok-kw">and</span> word[<span class="tok-number">1</span>] == <span class="tok-str">'L'</span>) {</span>
<span class="line" id="L69">                <span class="tok-kw">const</span> lib_path = word[<span class="tok-number">2</span>..];</span>
<span class="line" id="L70">                <span class="tok-kw">try</span> self.addLibDir(lib_path);</span>
<span class="line" id="L71">            } <span class="tok-kw">else</span> {</span>
<span class="line" id="L72">                <span class="tok-kw">try</span> self.addWarningFmt(<span class="tok-str">&quot;Unrecognized C flag from NIX_LDFLAGS: {s}&quot;</span>, .{word});</span>
<span class="line" id="L73">                <span class="tok-kw">break</span>;</span>
<span class="line" id="L74">            }</span>
<span class="line" id="L75">        }</span>
<span class="line" id="L76">    } <span class="tok-kw">else</span> |err| <span class="tok-kw">switch</span> (err) {</span>
<span class="line" id="L77">        <span class="tok-kw">error</span>.InvalidUtf8 =&gt; {},</span>
<span class="line" id="L78">        <span class="tok-kw">error</span>.EnvironmentVariableNotFound =&gt; {},</span>
<span class="line" id="L79">        <span class="tok-kw">error</span>.OutOfMemory =&gt; |e| <span class="tok-kw">return</span> e,</span>
<span class="line" id="L80">    }</span>
<span class="line" id="L81">    <span class="tok-kw">if</span> (is_nix) {</span>
<span class="line" id="L82">        <span class="tok-kw">return</span> self;</span>
<span class="line" id="L83">    }</span>
<span class="line" id="L84"></span>
<span class="line" id="L85">    <span class="tok-kw">if</span> (<span class="tok-kw">comptime</span> builtin.target.isDarwin()) {</span>
<span class="line" id="L86">        <span class="tok-kw">try</span> self.addIncludeDir(<span class="tok-str">&quot;/usr/include&quot;</span>);</span>
<span class="line" id="L87">        <span class="tok-kw">try</span> self.addLibDir(<span class="tok-str">&quot;/usr/lib&quot;</span>);</span>
<span class="line" id="L88">        <span class="tok-kw">try</span> self.addFrameworkDir(<span class="tok-str">&quot;/System/Library/Frameworks&quot;</span>);</span>
<span class="line" id="L89"></span>
<span class="line" id="L90">        <span class="tok-kw">if</span> (builtin.target.os.version_range.semver.min.major &lt; <span class="tok-number">11</span>) {</span>
<span class="line" id="L91">            <span class="tok-kw">try</span> self.addIncludeDir(<span class="tok-str">&quot;/usr/local/include&quot;</span>);</span>
<span class="line" id="L92">            <span class="tok-kw">try</span> self.addLibDir(<span class="tok-str">&quot;/usr/local/lib&quot;</span>);</span>
<span class="line" id="L93">            <span class="tok-kw">try</span> self.addFrameworkDir(<span class="tok-str">&quot;/Library/Frameworks&quot;</span>);</span>
<span class="line" id="L94">        }</span>
<span class="line" id="L95"></span>
<span class="line" id="L96">        <span class="tok-kw">return</span> self;</span>
<span class="line" id="L97">    }</span>
<span class="line" id="L98"></span>
<span class="line" id="L99">    <span class="tok-kw">if</span> (<span class="tok-kw">comptime</span> native_target.os.tag == .solaris) {</span>
<span class="line" id="L100">        <span class="tok-kw">try</span> self.addLibDir(<span class="tok-str">&quot;/usr/lib/64&quot;</span>);</span>
<span class="line" id="L101">        <span class="tok-kw">try</span> self.addLibDir(<span class="tok-str">&quot;/usr/local/lib/64&quot;</span>);</span>
<span class="line" id="L102">        <span class="tok-kw">try</span> self.addLibDir(<span class="tok-str">&quot;/lib/64&quot;</span>);</span>
<span class="line" id="L103"></span>
<span class="line" id="L104">        <span class="tok-kw">try</span> self.addIncludeDir(<span class="tok-str">&quot;/usr/include&quot;</span>);</span>
<span class="line" id="L105">        <span class="tok-kw">try</span> self.addIncludeDir(<span class="tok-str">&quot;/usr/local/include&quot;</span>);</span>
<span class="line" id="L106"></span>
<span class="line" id="L107">        <span class="tok-kw">return</span> self;</span>
<span class="line" id="L108">    }</span>
<span class="line" id="L109"></span>
<span class="line" id="L110">    <span class="tok-kw">if</span> (native_target.os.tag != .windows) {</span>
<span class="line" id="L111">        <span class="tok-kw">const</span> triple = <span class="tok-kw">try</span> native_target.linuxTriple(allocator);</span>
<span class="line" id="L112">        <span class="tok-kw">defer</span> allocator.free(triple);</span>
<span class="line" id="L113"></span>
<span class="line" id="L114">        <span class="tok-kw">const</span> qual = native_target.cpu.arch.ptrBitWidth();</span>
<span class="line" id="L115"></span>
<span class="line" id="L116">        <span class="tok-comment">// TODO: $ ld --verbose | grep SEARCH_DIR</span>
</span>
<span class="line" id="L117">        <span class="tok-comment">// the output contains some paths that end with lib64, maybe include them too?</span>
</span>
<span class="line" id="L118">        <span class="tok-comment">// TODO: what is the best possible order of things?</span>
</span>
<span class="line" id="L119">        <span class="tok-comment">// TODO: some of these are suspect and should only be added on some systems. audit needed.</span>
</span>
<span class="line" id="L120"></span>
<span class="line" id="L121">        <span class="tok-kw">try</span> self.addIncludeDir(<span class="tok-str">&quot;/usr/local/include&quot;</span>);</span>
<span class="line" id="L122">        <span class="tok-kw">try</span> self.addLibDirFmt(<span class="tok-str">&quot;/usr/local/lib{d}&quot;</span>, .{qual});</span>
<span class="line" id="L123">        <span class="tok-kw">try</span> self.addLibDir(<span class="tok-str">&quot;/usr/local/lib&quot;</span>);</span>
<span class="line" id="L124"></span>
<span class="line" id="L125">        <span class="tok-kw">try</span> self.addIncludeDirFmt(<span class="tok-str">&quot;/usr/include/{s}&quot;</span>, .{triple});</span>
<span class="line" id="L126">        <span class="tok-kw">try</span> self.addLibDirFmt(<span class="tok-str">&quot;/usr/lib/{s}&quot;</span>, .{triple});</span>
<span class="line" id="L127"></span>
<span class="line" id="L128">        <span class="tok-kw">try</span> self.addIncludeDir(<span class="tok-str">&quot;/usr/include&quot;</span>);</span>
<span class="line" id="L129">        <span class="tok-kw">try</span> self.addLibDirFmt(<span class="tok-str">&quot;/lib{d}&quot;</span>, .{qual});</span>
<span class="line" id="L130">        <span class="tok-kw">try</span> self.addLibDir(<span class="tok-str">&quot;/lib&quot;</span>);</span>
<span class="line" id="L131">        <span class="tok-kw">try</span> self.addLibDirFmt(<span class="tok-str">&quot;/usr/lib{d}&quot;</span>, .{qual});</span>
<span class="line" id="L132">        <span class="tok-kw">try</span> self.addLibDir(<span class="tok-str">&quot;/usr/lib&quot;</span>);</span>
<span class="line" id="L133"></span>
<span class="line" id="L134">        <span class="tok-comment">// example: on a 64-bit debian-based linux distro, with zlib installed from apt:</span>
</span>
<span class="line" id="L135">        <span class="tok-comment">// zlib.h is in /usr/include (added above)</span>
</span>
<span class="line" id="L136">        <span class="tok-comment">// libz.so.1 is in /lib/x86_64-linux-gnu (added here)</span>
</span>
<span class="line" id="L137">        <span class="tok-kw">try</span> self.addLibDirFmt(<span class="tok-str">&quot;/lib/{s}&quot;</span>, .{triple});</span>
<span class="line" id="L138">    }</span>
<span class="line" id="L139"></span>
<span class="line" id="L140">    <span class="tok-kw">return</span> self;</span>
<span class="line" id="L141">}</span>
<span class="line" id="L142"></span>
<span class="line" id="L143"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">deinit</span>(self: *NativePaths) <span class="tok-type">void</span> {</span>
<span class="line" id="L144">    deinitArray(&amp;self.include_dirs);</span>
<span class="line" id="L145">    deinitArray(&amp;self.lib_dirs);</span>
<span class="line" id="L146">    deinitArray(&amp;self.framework_dirs);</span>
<span class="line" id="L147">    deinitArray(&amp;self.rpaths);</span>
<span class="line" id="L148">    deinitArray(&amp;self.warnings);</span>
<span class="line" id="L149">    self.* = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L150">}</span>
<span class="line" id="L151"></span>
<span class="line" id="L152"><span class="tok-kw">fn</span> <span class="tok-fn">deinitArray</span>(array: *ArrayList([:<span class="tok-number">0</span>]<span class="tok-type">u8</span>)) <span class="tok-type">void</span> {</span>
<span class="line" id="L153">    <span class="tok-kw">for</span> (array.items) |item| {</span>
<span class="line" id="L154">        array.allocator.free(item);</span>
<span class="line" id="L155">    }</span>
<span class="line" id="L156">    array.deinit();</span>
<span class="line" id="L157">}</span>
<span class="line" id="L158"></span>
<span class="line" id="L159"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">addIncludeDir</span>(self: *NativePaths, s: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) !<span class="tok-type">void</span> {</span>
<span class="line" id="L160">    <span class="tok-kw">return</span> self.appendArray(&amp;self.include_dirs, s);</span>
<span class="line" id="L161">}</span>
<span class="line" id="L162"></span>
<span class="line" id="L163"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">addIncludeDirFmt</span>(self: *NativePaths, <span class="tok-kw">comptime</span> fmt: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, args: <span class="tok-kw">anytype</span>) !<span class="tok-type">void</span> {</span>
<span class="line" id="L164">    <span class="tok-kw">const</span> item = <span class="tok-kw">try</span> std.fmt.allocPrintZ(self.include_dirs.allocator, fmt, args);</span>
<span class="line" id="L165">    <span class="tok-kw">errdefer</span> self.include_dirs.allocator.free(item);</span>
<span class="line" id="L166">    <span class="tok-kw">try</span> self.include_dirs.append(item);</span>
<span class="line" id="L167">}</span>
<span class="line" id="L168"></span>
<span class="line" id="L169"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">addLibDir</span>(self: *NativePaths, s: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) !<span class="tok-type">void</span> {</span>
<span class="line" id="L170">    <span class="tok-kw">return</span> self.appendArray(&amp;self.lib_dirs, s);</span>
<span class="line" id="L171">}</span>
<span class="line" id="L172"></span>
<span class="line" id="L173"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">addLibDirFmt</span>(self: *NativePaths, <span class="tok-kw">comptime</span> fmt: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, args: <span class="tok-kw">anytype</span>) !<span class="tok-type">void</span> {</span>
<span class="line" id="L174">    <span class="tok-kw">const</span> item = <span class="tok-kw">try</span> std.fmt.allocPrintZ(self.lib_dirs.allocator, fmt, args);</span>
<span class="line" id="L175">    <span class="tok-kw">errdefer</span> self.lib_dirs.allocator.free(item);</span>
<span class="line" id="L176">    <span class="tok-kw">try</span> self.lib_dirs.append(item);</span>
<span class="line" id="L177">}</span>
<span class="line" id="L178"></span>
<span class="line" id="L179"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">addWarning</span>(self: *NativePaths, s: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) !<span class="tok-type">void</span> {</span>
<span class="line" id="L180">    <span class="tok-kw">return</span> self.appendArray(&amp;self.warnings, s);</span>
<span class="line" id="L181">}</span>
<span class="line" id="L182"></span>
<span class="line" id="L183"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">addFrameworkDir</span>(self: *NativePaths, s: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) !<span class="tok-type">void</span> {</span>
<span class="line" id="L184">    <span class="tok-kw">return</span> self.appendArray(&amp;self.framework_dirs, s);</span>
<span class="line" id="L185">}</span>
<span class="line" id="L186"></span>
<span class="line" id="L187"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">addFrameworkDirFmt</span>(self: *NativePaths, <span class="tok-kw">comptime</span> fmt: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, args: <span class="tok-kw">anytype</span>) !<span class="tok-type">void</span> {</span>
<span class="line" id="L188">    <span class="tok-kw">const</span> item = <span class="tok-kw">try</span> std.fmt.allocPrintZ(self.framework_dirs.allocator, fmt, args);</span>
<span class="line" id="L189">    <span class="tok-kw">errdefer</span> self.framework_dirs.allocator.free(item);</span>
<span class="line" id="L190">    <span class="tok-kw">try</span> self.framework_dirs.append(item);</span>
<span class="line" id="L191">}</span>
<span class="line" id="L192"></span>
<span class="line" id="L193"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">addWarningFmt</span>(self: *NativePaths, <span class="tok-kw">comptime</span> fmt: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, args: <span class="tok-kw">anytype</span>) !<span class="tok-type">void</span> {</span>
<span class="line" id="L194">    <span class="tok-kw">const</span> item = <span class="tok-kw">try</span> std.fmt.allocPrintZ(self.warnings.allocator, fmt, args);</span>
<span class="line" id="L195">    <span class="tok-kw">errdefer</span> self.warnings.allocator.free(item);</span>
<span class="line" id="L196">    <span class="tok-kw">try</span> self.warnings.append(item);</span>
<span class="line" id="L197">}</span>
<span class="line" id="L198"></span>
<span class="line" id="L199"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">addRPath</span>(self: *NativePaths, s: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) !<span class="tok-type">void</span> {</span>
<span class="line" id="L200">    <span class="tok-kw">return</span> self.appendArray(&amp;self.rpaths, s);</span>
<span class="line" id="L201">}</span>
<span class="line" id="L202"></span>
<span class="line" id="L203"><span class="tok-kw">fn</span> <span class="tok-fn">appendArray</span>(self: *NativePaths, array: *ArrayList([:<span class="tok-number">0</span>]<span class="tok-type">u8</span>), s: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) !<span class="tok-type">void</span> {</span>
<span class="line" id="L204">    _ = self;</span>
<span class="line" id="L205">    <span class="tok-kw">const</span> item = <span class="tok-kw">try</span> array.allocator.dupeZ(<span class="tok-type">u8</span>, s);</span>
<span class="line" id="L206">    <span class="tok-kw">errdefer</span> array.allocator.free(item);</span>
<span class="line" id="L207">    <span class="tok-kw">try</span> array.append(item);</span>
<span class="line" id="L208">}</span>
<span class="line" id="L209"></span>
</code></pre></body>
</html>