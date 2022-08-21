<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">    <title>zig/CrossTarget.zig - source view</title>
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
<pre><code><span class="line" id="L1"><span class="tok-comment">//! Contains all the same data as `Target`, additionally introducing the concept of &quot;the native target&quot;.</span></span>
<span class="line" id="L2"><span class="tok-comment">//! The purpose of this abstraction is to provide meaningful and unsurprising defaults.</span></span>
<span class="line" id="L3"><span class="tok-comment">//! This struct does reference any resources and it is copyable.</span></span>
<span class="line" id="L4"></span>
<span class="line" id="L5"><span class="tok-kw">const</span> CrossTarget = <span class="tok-builtin">@This</span>();</span>
<span class="line" id="L6"><span class="tok-kw">const</span> std = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;../std.zig&quot;</span>);</span>
<span class="line" id="L7"><span class="tok-kw">const</span> builtin = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;builtin&quot;</span>);</span>
<span class="line" id="L8"><span class="tok-kw">const</span> assert = std.debug.assert;</span>
<span class="line" id="L9"><span class="tok-kw">const</span> Target = std.Target;</span>
<span class="line" id="L10"><span class="tok-kw">const</span> mem = std.mem;</span>
<span class="line" id="L11"></span>
<span class="line" id="L12"><span class="tok-comment">/// `null` means native.</span></span>
<span class="line" id="L13">cpu_arch: ?Target.Cpu.Arch = <span class="tok-null">null</span>,</span>
<span class="line" id="L14"></span>
<span class="line" id="L15">cpu_model: CpuModel = CpuModel.determined_by_cpu_arch,</span>
<span class="line" id="L16"></span>
<span class="line" id="L17"><span class="tok-comment">/// Sparse set of CPU features to add to the set from `cpu_model`.</span></span>
<span class="line" id="L18">cpu_features_add: Target.Cpu.Feature.Set = Target.Cpu.Feature.Set.empty,</span>
<span class="line" id="L19"></span>
<span class="line" id="L20"><span class="tok-comment">/// Sparse set of CPU features to remove from the set from `cpu_model`.</span></span>
<span class="line" id="L21">cpu_features_sub: Target.Cpu.Feature.Set = Target.Cpu.Feature.Set.empty,</span>
<span class="line" id="L22"></span>
<span class="line" id="L23"><span class="tok-comment">/// `null` means native.</span></span>
<span class="line" id="L24">os_tag: ?Target.Os.Tag = <span class="tok-null">null</span>,</span>
<span class="line" id="L25"></span>
<span class="line" id="L26"><span class="tok-comment">/// `null` means the default version range for `os_tag`. If `os_tag` is `null` (native)</span></span>
<span class="line" id="L27"><span class="tok-comment">/// then `null` for this field means native.</span></span>
<span class="line" id="L28">os_version_min: ?OsVersion = <span class="tok-null">null</span>,</span>
<span class="line" id="L29"></span>
<span class="line" id="L30"><span class="tok-comment">/// When cross compiling, `null` means default (latest known OS version).</span></span>
<span class="line" id="L31"><span class="tok-comment">/// When `os_tag` is native, `null` means equal to the native OS version.</span></span>
<span class="line" id="L32">os_version_max: ?OsVersion = <span class="tok-null">null</span>,</span>
<span class="line" id="L33"></span>
<span class="line" id="L34"><span class="tok-comment">/// `null` means default when cross compiling, or native when os_tag is native.</span></span>
<span class="line" id="L35"><span class="tok-comment">/// If `isGnuLibC()` is `false`, this must be `null` and is ignored.</span></span>
<span class="line" id="L36">glibc_version: ?SemVer = <span class="tok-null">null</span>,</span>
<span class="line" id="L37"></span>
<span class="line" id="L38"><span class="tok-comment">/// `null` means the native C ABI, if `os_tag` is native, otherwise it means the default C ABI.</span></span>
<span class="line" id="L39">abi: ?Target.Abi = <span class="tok-null">null</span>,</span>
<span class="line" id="L40"></span>
<span class="line" id="L41"><span class="tok-comment">/// When `os_tag` is `null`, then `null` means native. Otherwise it means the standard path</span></span>
<span class="line" id="L42"><span class="tok-comment">/// based on the `os_tag`.</span></span>
<span class="line" id="L43">dynamic_linker: DynamicLinker = DynamicLinker{},</span>
<span class="line" id="L44"></span>
<span class="line" id="L45"><span class="tok-comment">/// `null` means default for the cpu/arch/os combo.</span></span>
<span class="line" id="L46">ofmt: ?Target.ObjectFormat = <span class="tok-null">null</span>,</span>
<span class="line" id="L47"></span>
<span class="line" id="L48"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> CpuModel = <span class="tok-kw">union</span>(<span class="tok-kw">enum</span>) {</span>
<span class="line" id="L49">    <span class="tok-comment">/// Always native</span></span>
<span class="line" id="L50">    native,</span>
<span class="line" id="L51"></span>
<span class="line" id="L52">    <span class="tok-comment">/// Always baseline</span></span>
<span class="line" id="L53">    baseline,</span>
<span class="line" id="L54"></span>
<span class="line" id="L55">    <span class="tok-comment">/// If CPU Architecture is native, then the CPU model will be native. Otherwise,</span></span>
<span class="line" id="L56">    <span class="tok-comment">/// it will be baseline.</span></span>
<span class="line" id="L57">    determined_by_cpu_arch,</span>
<span class="line" id="L58"></span>
<span class="line" id="L59">    explicit: *<span class="tok-kw">const</span> Target.Cpu.Model,</span>
<span class="line" id="L60">};</span>
<span class="line" id="L61"></span>
<span class="line" id="L62"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> OsVersion = <span class="tok-kw">union</span>(<span class="tok-kw">enum</span>) {</span>
<span class="line" id="L63">    none: <span class="tok-type">void</span>,</span>
<span class="line" id="L64">    semver: SemVer,</span>
<span class="line" id="L65">    windows: Target.Os.WindowsVersion,</span>
<span class="line" id="L66">};</span>
<span class="line" id="L67"></span>
<span class="line" id="L68"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SemVer = std.builtin.Version;</span>
<span class="line" id="L69"></span>
<span class="line" id="L70"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> DynamicLinker = Target.DynamicLinker;</span>
<span class="line" id="L71"></span>
<span class="line" id="L72"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">fromTarget</span>(target: Target) CrossTarget {</span>
<span class="line" id="L73">    <span class="tok-kw">var</span> result: CrossTarget = .{</span>
<span class="line" id="L74">        .cpu_arch = target.cpu.arch,</span>
<span class="line" id="L75">        .cpu_model = .{ .explicit = target.cpu.model },</span>
<span class="line" id="L76">        .os_tag = target.os.tag,</span>
<span class="line" id="L77">        .os_version_min = <span class="tok-null">undefined</span>,</span>
<span class="line" id="L78">        .os_version_max = <span class="tok-null">undefined</span>,</span>
<span class="line" id="L79">        .abi = target.abi,</span>
<span class="line" id="L80">        .glibc_version = <span class="tok-kw">if</span> (target.isGnuLibC())</span>
<span class="line" id="L81">            target.os.version_range.linux.glibc</span>
<span class="line" id="L82">        <span class="tok-kw">else</span></span>
<span class="line" id="L83">            <span class="tok-null">null</span>,</span>
<span class="line" id="L84">    };</span>
<span class="line" id="L85">    result.updateOsVersionRange(target.os);</span>
<span class="line" id="L86"></span>
<span class="line" id="L87">    <span class="tok-kw">const</span> all_features = target.cpu.arch.allFeaturesList();</span>
<span class="line" id="L88">    <span class="tok-kw">var</span> cpu_model_set = target.cpu.model.features;</span>
<span class="line" id="L89">    cpu_model_set.populateDependencies(all_features);</span>
<span class="line" id="L90">    {</span>
<span class="line" id="L91">        <span class="tok-comment">// The &quot;add&quot; set is the full set with the CPU Model set removed.</span>
</span>
<span class="line" id="L92">        <span class="tok-kw">const</span> add_set = &amp;result.cpu_features_add;</span>
<span class="line" id="L93">        add_set.* = target.cpu.features;</span>
<span class="line" id="L94">        add_set.removeFeatureSet(cpu_model_set);</span>
<span class="line" id="L95">    }</span>
<span class="line" id="L96">    {</span>
<span class="line" id="L97">        <span class="tok-comment">// The &quot;sub&quot; set is the features that are on in CPU Model set and off in the full set.</span>
</span>
<span class="line" id="L98">        <span class="tok-kw">const</span> sub_set = &amp;result.cpu_features_sub;</span>
<span class="line" id="L99">        sub_set.* = cpu_model_set;</span>
<span class="line" id="L100">        sub_set.removeFeatureSet(target.cpu.features);</span>
<span class="line" id="L101">    }</span>
<span class="line" id="L102">    <span class="tok-kw">return</span> result;</span>
<span class="line" id="L103">}</span>
<span class="line" id="L104"></span>
<span class="line" id="L105"><span class="tok-kw">fn</span> <span class="tok-fn">updateOsVersionRange</span>(self: *CrossTarget, os: Target.Os) <span class="tok-type">void</span> {</span>
<span class="line" id="L106">    <span class="tok-kw">switch</span> (os.tag) {</span>
<span class="line" id="L107">        .freestanding,</span>
<span class="line" id="L108">        .ananas,</span>
<span class="line" id="L109">        .cloudabi,</span>
<span class="line" id="L110">        .fuchsia,</span>
<span class="line" id="L111">        .kfreebsd,</span>
<span class="line" id="L112">        .lv2,</span>
<span class="line" id="L113">        .solaris,</span>
<span class="line" id="L114">        .zos,</span>
<span class="line" id="L115">        .haiku,</span>
<span class="line" id="L116">        .minix,</span>
<span class="line" id="L117">        .rtems,</span>
<span class="line" id="L118">        .nacl,</span>
<span class="line" id="L119">        .aix,</span>
<span class="line" id="L120">        .cuda,</span>
<span class="line" id="L121">        .nvcl,</span>
<span class="line" id="L122">        .amdhsa,</span>
<span class="line" id="L123">        .ps4,</span>
<span class="line" id="L124">        .elfiamcu,</span>
<span class="line" id="L125">        .mesa3d,</span>
<span class="line" id="L126">        .contiki,</span>
<span class="line" id="L127">        .amdpal,</span>
<span class="line" id="L128">        .hermit,</span>
<span class="line" id="L129">        .hurd,</span>
<span class="line" id="L130">        .wasi,</span>
<span class="line" id="L131">        .emscripten,</span>
<span class="line" id="L132">        .uefi,</span>
<span class="line" id="L133">        .opencl,</span>
<span class="line" id="L134">        .glsl450,</span>
<span class="line" id="L135">        .vulkan,</span>
<span class="line" id="L136">        .plan9,</span>
<span class="line" id="L137">        .other,</span>
<span class="line" id="L138">        =&gt; {</span>
<span class="line" id="L139">            self.os_version_min = .{ .none = {} };</span>
<span class="line" id="L140">            self.os_version_max = .{ .none = {} };</span>
<span class="line" id="L141">        },</span>
<span class="line" id="L142"></span>
<span class="line" id="L143">        .freebsd,</span>
<span class="line" id="L144">        .macos,</span>
<span class="line" id="L145">        .ios,</span>
<span class="line" id="L146">        .tvos,</span>
<span class="line" id="L147">        .watchos,</span>
<span class="line" id="L148">        .netbsd,</span>
<span class="line" id="L149">        .openbsd,</span>
<span class="line" id="L150">        .dragonfly,</span>
<span class="line" id="L151">        =&gt; {</span>
<span class="line" id="L152">            self.os_version_min = .{ .semver = os.version_range.semver.min };</span>
<span class="line" id="L153">            self.os_version_max = .{ .semver = os.version_range.semver.max };</span>
<span class="line" id="L154">        },</span>
<span class="line" id="L155"></span>
<span class="line" id="L156">        .linux =&gt; {</span>
<span class="line" id="L157">            self.os_version_min = .{ .semver = os.version_range.linux.range.min };</span>
<span class="line" id="L158">            self.os_version_max = .{ .semver = os.version_range.linux.range.max };</span>
<span class="line" id="L159">        },</span>
<span class="line" id="L160"></span>
<span class="line" id="L161">        .windows =&gt; {</span>
<span class="line" id="L162">            self.os_version_min = .{ .windows = os.version_range.windows.min };</span>
<span class="line" id="L163">            self.os_version_max = .{ .windows = os.version_range.windows.max };</span>
<span class="line" id="L164">        },</span>
<span class="line" id="L165">    }</span>
<span class="line" id="L166">}</span>
<span class="line" id="L167"></span>
<span class="line" id="L168"><span class="tok-comment">/// TODO deprecated, use `std.zig.system.NativeTargetInfo.detect`.</span></span>
<span class="line" id="L169"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">toTarget</span>(self: CrossTarget) Target {</span>
<span class="line" id="L170">    <span class="tok-kw">return</span> .{</span>
<span class="line" id="L171">        .cpu = self.getCpu(),</span>
<span class="line" id="L172">        .os = self.getOs(),</span>
<span class="line" id="L173">        .abi = self.getAbi(),</span>
<span class="line" id="L174">        .ofmt = self.getObjectFormat(),</span>
<span class="line" id="L175">    };</span>
<span class="line" id="L176">}</span>
<span class="line" id="L177"></span>
<span class="line" id="L178"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> ParseOptions = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L179">    <span class="tok-comment">/// This is sometimes called a &quot;triple&quot;. It looks roughly like this:</span></span>
<span class="line" id="L180">    <span class="tok-comment">///     riscv64-linux-musl</span></span>
<span class="line" id="L181">    <span class="tok-comment">/// The fields are, respectively:</span></span>
<span class="line" id="L182">    <span class="tok-comment">/// * CPU Architecture</span></span>
<span class="line" id="L183">    <span class="tok-comment">/// * Operating System (and optional version range)</span></span>
<span class="line" id="L184">    <span class="tok-comment">/// * C ABI (optional, with optional glibc version)</span></span>
<span class="line" id="L185">    <span class="tok-comment">/// The string &quot;native&quot; can be used for CPU architecture as well as Operating System.</span></span>
<span class="line" id="L186">    <span class="tok-comment">/// If the CPU Architecture is specified as &quot;native&quot;, then the Operating System and C ABI may be omitted.</span></span>
<span class="line" id="L187">    arch_os_abi: []<span class="tok-kw">const</span> <span class="tok-type">u8</span> = <span class="tok-str">&quot;native&quot;</span>,</span>
<span class="line" id="L188"></span>
<span class="line" id="L189">    <span class="tok-comment">/// Looks like &quot;name+a+b-c-d+e&quot;, where &quot;name&quot; is a CPU Model name, &quot;a&quot;, &quot;b&quot;, and &quot;e&quot;</span></span>
<span class="line" id="L190">    <span class="tok-comment">/// are examples of CPU features to add to the set, and &quot;c&quot; and &quot;d&quot; are examples of CPU features</span></span>
<span class="line" id="L191">    <span class="tok-comment">/// to remove from the set.</span></span>
<span class="line" id="L192">    <span class="tok-comment">/// The following special strings are recognized for CPU Model name:</span></span>
<span class="line" id="L193">    <span class="tok-comment">/// * &quot;baseline&quot; - The &quot;default&quot; set of CPU features for cross-compiling. A conservative set</span></span>
<span class="line" id="L194">    <span class="tok-comment">///                of features that is expected to be supported on most available hardware.</span></span>
<span class="line" id="L195">    <span class="tok-comment">/// * &quot;native&quot;   - The native CPU model is to be detected when compiling.</span></span>
<span class="line" id="L196">    <span class="tok-comment">/// If this field is not provided (`null`), then the value will depend on the</span></span>
<span class="line" id="L197">    <span class="tok-comment">/// parsed CPU Architecture. If native, then this will be &quot;native&quot;. Otherwise, it will be &quot;baseline&quot;.</span></span>
<span class="line" id="L198">    cpu_features: ?[]<span class="tok-kw">const</span> <span class="tok-type">u8</span> = <span class="tok-null">null</span>,</span>
<span class="line" id="L199"></span>
<span class="line" id="L200">    <span class="tok-comment">/// Absolute path to dynamic linker, to override the default, which is either a natively</span></span>
<span class="line" id="L201">    <span class="tok-comment">/// detected path, or a standard path.</span></span>
<span class="line" id="L202">    dynamic_linker: ?[]<span class="tok-kw">const</span> <span class="tok-type">u8</span> = <span class="tok-null">null</span>,</span>
<span class="line" id="L203"></span>
<span class="line" id="L204">    object_format: ?[]<span class="tok-kw">const</span> <span class="tok-type">u8</span> = <span class="tok-null">null</span>,</span>
<span class="line" id="L205"></span>
<span class="line" id="L206">    <span class="tok-comment">/// If this is provided, the function will populate some information about parsing failures,</span></span>
<span class="line" id="L207">    <span class="tok-comment">/// so that user-friendly error messages can be delivered.</span></span>
<span class="line" id="L208">    diagnostics: ?*Diagnostics = <span class="tok-null">null</span>,</span>
<span class="line" id="L209"></span>
<span class="line" id="L210">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> Diagnostics = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L211">        <span class="tok-comment">/// If the architecture was determined, this will be populated.</span></span>
<span class="line" id="L212">        arch: ?Target.Cpu.Arch = <span class="tok-null">null</span>,</span>
<span class="line" id="L213"></span>
<span class="line" id="L214">        <span class="tok-comment">/// If the OS name was determined, this will be populated.</span></span>
<span class="line" id="L215">        os_name: ?[]<span class="tok-kw">const</span> <span class="tok-type">u8</span> = <span class="tok-null">null</span>,</span>
<span class="line" id="L216"></span>
<span class="line" id="L217">        <span class="tok-comment">/// If the OS tag was determined, this will be populated.</span></span>
<span class="line" id="L218">        os_tag: ?Target.Os.Tag = <span class="tok-null">null</span>,</span>
<span class="line" id="L219"></span>
<span class="line" id="L220">        <span class="tok-comment">/// If the ABI was determined, this will be populated.</span></span>
<span class="line" id="L221">        abi: ?Target.Abi = <span class="tok-null">null</span>,</span>
<span class="line" id="L222"></span>
<span class="line" id="L223">        <span class="tok-comment">/// If the CPU name was determined, this will be populated.</span></span>
<span class="line" id="L224">        cpu_name: ?[]<span class="tok-kw">const</span> <span class="tok-type">u8</span> = <span class="tok-null">null</span>,</span>
<span class="line" id="L225"></span>
<span class="line" id="L226">        <span class="tok-comment">/// If error.UnknownCpuFeature is returned, this will be populated.</span></span>
<span class="line" id="L227">        unknown_feature_name: ?[]<span class="tok-kw">const</span> <span class="tok-type">u8</span> = <span class="tok-null">null</span>,</span>
<span class="line" id="L228">    };</span>
<span class="line" id="L229">};</span>
<span class="line" id="L230"></span>
<span class="line" id="L231"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">parse</span>(args: ParseOptions) !CrossTarget {</span>
<span class="line" id="L232">    <span class="tok-kw">var</span> dummy_diags: ParseOptions.Diagnostics = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L233">    <span class="tok-kw">const</span> diags = args.diagnostics <span class="tok-kw">orelse</span> &amp;dummy_diags;</span>
<span class="line" id="L234"></span>
<span class="line" id="L235">    <span class="tok-kw">var</span> result: CrossTarget = .{</span>
<span class="line" id="L236">        .dynamic_linker = DynamicLinker.init(args.dynamic_linker),</span>
<span class="line" id="L237">    };</span>
<span class="line" id="L238"></span>
<span class="line" id="L239">    <span class="tok-kw">var</span> it = mem.split(<span class="tok-type">u8</span>, args.arch_os_abi, <span class="tok-str">&quot;-&quot;</span>);</span>
<span class="line" id="L240">    <span class="tok-kw">const</span> arch_name = it.first();</span>
<span class="line" id="L241">    <span class="tok-kw">const</span> arch_is_native = mem.eql(<span class="tok-type">u8</span>, arch_name, <span class="tok-str">&quot;native&quot;</span>);</span>
<span class="line" id="L242">    <span class="tok-kw">if</span> (!arch_is_native) {</span>
<span class="line" id="L243">        result.cpu_arch = std.meta.stringToEnum(Target.Cpu.Arch, arch_name) <span class="tok-kw">orelse</span></span>
<span class="line" id="L244">            <span class="tok-kw">return</span> <span class="tok-kw">error</span>.UnknownArchitecture;</span>
<span class="line" id="L245">    }</span>
<span class="line" id="L246">    <span class="tok-kw">const</span> arch = result.getCpuArch();</span>
<span class="line" id="L247">    diags.arch = arch;</span>
<span class="line" id="L248"></span>
<span class="line" id="L249">    <span class="tok-kw">if</span> (it.next()) |os_text| {</span>
<span class="line" id="L250">        <span class="tok-kw">try</span> parseOs(&amp;result, diags, os_text);</span>
<span class="line" id="L251">    } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (!arch_is_native) {</span>
<span class="line" id="L252">        <span class="tok-kw">return</span> <span class="tok-kw">error</span>.MissingOperatingSystem;</span>
<span class="line" id="L253">    }</span>
<span class="line" id="L254"></span>
<span class="line" id="L255">    <span class="tok-kw">const</span> opt_abi_text = it.next();</span>
<span class="line" id="L256">    <span class="tok-kw">if</span> (opt_abi_text) |abi_text| {</span>
<span class="line" id="L257">        <span class="tok-kw">var</span> abi_it = mem.split(<span class="tok-type">u8</span>, abi_text, <span class="tok-str">&quot;.&quot;</span>);</span>
<span class="line" id="L258">        <span class="tok-kw">const</span> abi = std.meta.stringToEnum(Target.Abi, abi_it.first()) <span class="tok-kw">orelse</span></span>
<span class="line" id="L259">            <span class="tok-kw">return</span> <span class="tok-kw">error</span>.UnknownApplicationBinaryInterface;</span>
<span class="line" id="L260">        result.abi = abi;</span>
<span class="line" id="L261">        diags.abi = abi;</span>
<span class="line" id="L262"></span>
<span class="line" id="L263">        <span class="tok-kw">const</span> abi_ver_text = abi_it.rest();</span>
<span class="line" id="L264">        <span class="tok-kw">if</span> (abi_it.next() != <span class="tok-null">null</span>) {</span>
<span class="line" id="L265">            <span class="tok-kw">if</span> (result.isGnuLibC()) {</span>
<span class="line" id="L266">                result.glibc_version = SemVer.parse(abi_ver_text) <span class="tok-kw">catch</span> |err| <span class="tok-kw">switch</span> (err) {</span>
<span class="line" id="L267">                    <span class="tok-kw">error</span>.Overflow =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InvalidAbiVersion,</span>
<span class="line" id="L268">                    <span class="tok-kw">error</span>.InvalidCharacter =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InvalidAbiVersion,</span>
<span class="line" id="L269">                    <span class="tok-kw">error</span>.InvalidVersion =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InvalidAbiVersion,</span>
<span class="line" id="L270">                };</span>
<span class="line" id="L271">            } <span class="tok-kw">else</span> {</span>
<span class="line" id="L272">                <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InvalidAbiVersion;</span>
<span class="line" id="L273">            }</span>
<span class="line" id="L274">        }</span>
<span class="line" id="L275">    }</span>
<span class="line" id="L276"></span>
<span class="line" id="L277">    <span class="tok-kw">if</span> (it.next() != <span class="tok-null">null</span>) <span class="tok-kw">return</span> <span class="tok-kw">error</span>.UnexpectedExtraField;</span>
<span class="line" id="L278"></span>
<span class="line" id="L279">    <span class="tok-kw">if</span> (args.cpu_features) |cpu_features| {</span>
<span class="line" id="L280">        <span class="tok-kw">const</span> all_features = arch.allFeaturesList();</span>
<span class="line" id="L281">        <span class="tok-kw">var</span> index: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L282">        <span class="tok-kw">while</span> (index &lt; cpu_features.len <span class="tok-kw">and</span></span>
<span class="line" id="L283">            cpu_features[index] != <span class="tok-str">'+'</span> <span class="tok-kw">and</span></span>
<span class="line" id="L284">            cpu_features[index] != <span class="tok-str">'-'</span>)</span>
<span class="line" id="L285">        {</span>
<span class="line" id="L286">            index += <span class="tok-number">1</span>;</span>
<span class="line" id="L287">        }</span>
<span class="line" id="L288">        <span class="tok-kw">const</span> cpu_name = cpu_features[<span class="tok-number">0</span>..index];</span>
<span class="line" id="L289">        diags.cpu_name = cpu_name;</span>
<span class="line" id="L290"></span>
<span class="line" id="L291">        <span class="tok-kw">const</span> add_set = &amp;result.cpu_features_add;</span>
<span class="line" id="L292">        <span class="tok-kw">const</span> sub_set = &amp;result.cpu_features_sub;</span>
<span class="line" id="L293">        <span class="tok-kw">if</span> (mem.eql(<span class="tok-type">u8</span>, cpu_name, <span class="tok-str">&quot;native&quot;</span>)) {</span>
<span class="line" id="L294">            result.cpu_model = .native;</span>
<span class="line" id="L295">        } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (mem.eql(<span class="tok-type">u8</span>, cpu_name, <span class="tok-str">&quot;baseline&quot;</span>)) {</span>
<span class="line" id="L296">            result.cpu_model = .baseline;</span>
<span class="line" id="L297">        } <span class="tok-kw">else</span> {</span>
<span class="line" id="L298">            result.cpu_model = .{ .explicit = <span class="tok-kw">try</span> arch.parseCpuModel(cpu_name) };</span>
<span class="line" id="L299">        }</span>
<span class="line" id="L300"></span>
<span class="line" id="L301">        <span class="tok-kw">while</span> (index &lt; cpu_features.len) {</span>
<span class="line" id="L302">            <span class="tok-kw">const</span> op = cpu_features[index];</span>
<span class="line" id="L303">            <span class="tok-kw">const</span> set = <span class="tok-kw">switch</span> (op) {</span>
<span class="line" id="L304">                <span class="tok-str">'+'</span> =&gt; add_set,</span>
<span class="line" id="L305">                <span class="tok-str">'-'</span> =&gt; sub_set,</span>
<span class="line" id="L306">                <span class="tok-kw">else</span> =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L307">            };</span>
<span class="line" id="L308">            index += <span class="tok-number">1</span>;</span>
<span class="line" id="L309">            <span class="tok-kw">const</span> start = index;</span>
<span class="line" id="L310">            <span class="tok-kw">while</span> (index &lt; cpu_features.len <span class="tok-kw">and</span></span>
<span class="line" id="L311">                cpu_features[index] != <span class="tok-str">'+'</span> <span class="tok-kw">and</span></span>
<span class="line" id="L312">                cpu_features[index] != <span class="tok-str">'-'</span>)</span>
<span class="line" id="L313">            {</span>
<span class="line" id="L314">                index += <span class="tok-number">1</span>;</span>
<span class="line" id="L315">            }</span>
<span class="line" id="L316">            <span class="tok-kw">const</span> feature_name = cpu_features[start..index];</span>
<span class="line" id="L317">            <span class="tok-kw">for</span> (all_features) |feature, feat_index_usize| {</span>
<span class="line" id="L318">                <span class="tok-kw">const</span> feat_index = <span class="tok-builtin">@intCast</span>(Target.Cpu.Feature.Set.Index, feat_index_usize);</span>
<span class="line" id="L319">                <span class="tok-kw">if</span> (mem.eql(<span class="tok-type">u8</span>, feature_name, feature.name)) {</span>
<span class="line" id="L320">                    set.addFeature(feat_index);</span>
<span class="line" id="L321">                    <span class="tok-kw">break</span>;</span>
<span class="line" id="L322">                }</span>
<span class="line" id="L323">            } <span class="tok-kw">else</span> {</span>
<span class="line" id="L324">                diags.unknown_feature_name = feature_name;</span>
<span class="line" id="L325">                <span class="tok-kw">return</span> <span class="tok-kw">error</span>.UnknownCpuFeature;</span>
<span class="line" id="L326">            }</span>
<span class="line" id="L327">        }</span>
<span class="line" id="L328">    }</span>
<span class="line" id="L329"></span>
<span class="line" id="L330">    <span class="tok-kw">if</span> (args.object_format) |ofmt_name| {</span>
<span class="line" id="L331">        result.ofmt = std.meta.stringToEnum(Target.ObjectFormat, ofmt_name) <span class="tok-kw">orelse</span></span>
<span class="line" id="L332">            <span class="tok-kw">return</span> <span class="tok-kw">error</span>.UnknownObjectFormat;</span>
<span class="line" id="L333">    }</span>
<span class="line" id="L334"></span>
<span class="line" id="L335">    <span class="tok-kw">return</span> result;</span>
<span class="line" id="L336">}</span>
<span class="line" id="L337"></span>
<span class="line" id="L338"><span class="tok-comment">/// Similar to `parse` except instead of fully parsing, it only determines the CPU</span></span>
<span class="line" id="L339"><span class="tok-comment">/// architecture and returns it if it can be determined, and returns `null` otherwise.</span></span>
<span class="line" id="L340"><span class="tok-comment">/// This is intended to be used if the API user of CrossTarget needs to learn the</span></span>
<span class="line" id="L341"><span class="tok-comment">/// target CPU architecture in order to fully populate `ParseOptions`.</span></span>
<span class="line" id="L342"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">parseCpuArch</span>(args: ParseOptions) ?Target.Cpu.Arch {</span>
<span class="line" id="L343">    <span class="tok-kw">var</span> it = mem.split(<span class="tok-type">u8</span>, args.arch_os_abi, <span class="tok-str">&quot;-&quot;</span>);</span>
<span class="line" id="L344">    <span class="tok-kw">const</span> arch_name = it.first();</span>
<span class="line" id="L345">    <span class="tok-kw">const</span> arch_is_native = mem.eql(<span class="tok-type">u8</span>, arch_name, <span class="tok-str">&quot;native&quot;</span>);</span>
<span class="line" id="L346">    <span class="tok-kw">if</span> (arch_is_native) {</span>
<span class="line" id="L347">        <span class="tok-kw">return</span> builtin.cpu.arch;</span>
<span class="line" id="L348">    } <span class="tok-kw">else</span> {</span>
<span class="line" id="L349">        <span class="tok-kw">return</span> std.meta.stringToEnum(Target.Cpu.Arch, arch_name);</span>
<span class="line" id="L350">    }</span>
<span class="line" id="L351">}</span>
<span class="line" id="L352"></span>
<span class="line" id="L353"><span class="tok-comment">/// TODO deprecated, use `std.zig.system.NativeTargetInfo.detect`.</span></span>
<span class="line" id="L354"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">getCpu</span>(self: CrossTarget) Target.Cpu {</span>
<span class="line" id="L355">    <span class="tok-kw">switch</span> (self.cpu_model) {</span>
<span class="line" id="L356">        .native =&gt; {</span>
<span class="line" id="L357">            <span class="tok-comment">// This works when doing `zig build` because Zig generates a build executable using</span>
</span>
<span class="line" id="L358">            <span class="tok-comment">// native CPU model &amp; features. However this will not be accurate otherwise, and</span>
</span>
<span class="line" id="L359">            <span class="tok-comment">// will need to be integrated with `std.zig.system.NativeTargetInfo.detect`.</span>
</span>
<span class="line" id="L360">            <span class="tok-kw">return</span> builtin.cpu;</span>
<span class="line" id="L361">        },</span>
<span class="line" id="L362">        .baseline =&gt; {</span>
<span class="line" id="L363">            <span class="tok-kw">var</span> adjusted_baseline = Target.Cpu.baseline(self.getCpuArch());</span>
<span class="line" id="L364">            self.updateCpuFeatures(&amp;adjusted_baseline.features);</span>
<span class="line" id="L365">            <span class="tok-kw">return</span> adjusted_baseline;</span>
<span class="line" id="L366">        },</span>
<span class="line" id="L367">        .determined_by_cpu_arch =&gt; <span class="tok-kw">if</span> (self.cpu_arch == <span class="tok-null">null</span>) {</span>
<span class="line" id="L368">            <span class="tok-comment">// This works when doing `zig build` because Zig generates a build executable using</span>
</span>
<span class="line" id="L369">            <span class="tok-comment">// native CPU model &amp; features. However this will not be accurate otherwise, and</span>
</span>
<span class="line" id="L370">            <span class="tok-comment">// will need to be integrated with `std.zig.system.NativeTargetInfo.detect`.</span>
</span>
<span class="line" id="L371">            <span class="tok-kw">return</span> builtin.cpu;</span>
<span class="line" id="L372">        } <span class="tok-kw">else</span> {</span>
<span class="line" id="L373">            <span class="tok-kw">var</span> adjusted_baseline = Target.Cpu.baseline(self.getCpuArch());</span>
<span class="line" id="L374">            self.updateCpuFeatures(&amp;adjusted_baseline.features);</span>
<span class="line" id="L375">            <span class="tok-kw">return</span> adjusted_baseline;</span>
<span class="line" id="L376">        },</span>
<span class="line" id="L377">        .explicit =&gt; |model| {</span>
<span class="line" id="L378">            <span class="tok-kw">var</span> adjusted_model = model.toCpu(self.getCpuArch());</span>
<span class="line" id="L379">            self.updateCpuFeatures(&amp;adjusted_model.features);</span>
<span class="line" id="L380">            <span class="tok-kw">return</span> adjusted_model;</span>
<span class="line" id="L381">        },</span>
<span class="line" id="L382">    }</span>
<span class="line" id="L383">}</span>
<span class="line" id="L384"></span>
<span class="line" id="L385"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">getCpuArch</span>(self: CrossTarget) Target.Cpu.Arch {</span>
<span class="line" id="L386">    <span class="tok-kw">return</span> self.cpu_arch <span class="tok-kw">orelse</span> builtin.cpu.arch;</span>
<span class="line" id="L387">}</span>
<span class="line" id="L388"></span>
<span class="line" id="L389"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">getCpuModel</span>(self: CrossTarget) *<span class="tok-kw">const</span> Target.Cpu.Model {</span>
<span class="line" id="L390">    <span class="tok-kw">return</span> <span class="tok-kw">switch</span> (self.cpu_model) {</span>
<span class="line" id="L391">        .explicit =&gt; |cpu_model| cpu_model,</span>
<span class="line" id="L392">        <span class="tok-kw">else</span> =&gt; self.getCpu().model,</span>
<span class="line" id="L393">    };</span>
<span class="line" id="L394">}</span>
<span class="line" id="L395"></span>
<span class="line" id="L396"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">getCpuFeatures</span>(self: CrossTarget) Target.Cpu.Feature.Set {</span>
<span class="line" id="L397">    <span class="tok-kw">return</span> self.getCpu().features;</span>
<span class="line" id="L398">}</span>
<span class="line" id="L399"></span>
<span class="line" id="L400"><span class="tok-comment">/// TODO deprecated, use `std.zig.system.NativeTargetInfo.detect`.</span></span>
<span class="line" id="L401"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">getOs</span>(self: CrossTarget) Target.Os {</span>
<span class="line" id="L402">    <span class="tok-comment">// `builtin.os` works when doing `zig build` because Zig generates a build executable using</span>
</span>
<span class="line" id="L403">    <span class="tok-comment">// native OS version range. However this will not be accurate otherwise, and</span>
</span>
<span class="line" id="L404">    <span class="tok-comment">// will need to be integrated with `std.zig.system.NativeTargetInfo.detect`.</span>
</span>
<span class="line" id="L405">    <span class="tok-kw">var</span> adjusted_os = <span class="tok-kw">if</span> (self.os_tag) |os_tag| os_tag.defaultVersionRange(self.getCpuArch()) <span class="tok-kw">else</span> builtin.os;</span>
<span class="line" id="L406"></span>
<span class="line" id="L407">    <span class="tok-kw">if</span> (self.os_version_min) |min| <span class="tok-kw">switch</span> (min) {</span>
<span class="line" id="L408">        .none =&gt; {},</span>
<span class="line" id="L409">        .semver =&gt; |semver| <span class="tok-kw">switch</span> (self.getOsTag()) {</span>
<span class="line" id="L410">            .linux =&gt; adjusted_os.version_range.linux.range.min = semver,</span>
<span class="line" id="L411">            <span class="tok-kw">else</span> =&gt; adjusted_os.version_range.semver.min = semver,</span>
<span class="line" id="L412">        },</span>
<span class="line" id="L413">        .windows =&gt; |win_ver| adjusted_os.version_range.windows.min = win_ver,</span>
<span class="line" id="L414">    };</span>
<span class="line" id="L415"></span>
<span class="line" id="L416">    <span class="tok-kw">if</span> (self.os_version_max) |max| <span class="tok-kw">switch</span> (max) {</span>
<span class="line" id="L417">        .none =&gt; {},</span>
<span class="line" id="L418">        .semver =&gt; |semver| <span class="tok-kw">switch</span> (self.getOsTag()) {</span>
<span class="line" id="L419">            .linux =&gt; adjusted_os.version_range.linux.range.max = semver,</span>
<span class="line" id="L420">            <span class="tok-kw">else</span> =&gt; adjusted_os.version_range.semver.max = semver,</span>
<span class="line" id="L421">        },</span>
<span class="line" id="L422">        .windows =&gt; |win_ver| adjusted_os.version_range.windows.max = win_ver,</span>
<span class="line" id="L423">    };</span>
<span class="line" id="L424"></span>
<span class="line" id="L425">    <span class="tok-kw">if</span> (self.glibc_version) |glibc| {</span>
<span class="line" id="L426">        assert(self.isGnuLibC());</span>
<span class="line" id="L427">        adjusted_os.version_range.linux.glibc = glibc;</span>
<span class="line" id="L428">    }</span>
<span class="line" id="L429"></span>
<span class="line" id="L430">    <span class="tok-kw">return</span> adjusted_os;</span>
<span class="line" id="L431">}</span>
<span class="line" id="L432"></span>
<span class="line" id="L433"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">getOsTag</span>(self: CrossTarget) Target.Os.Tag {</span>
<span class="line" id="L434">    <span class="tok-kw">return</span> self.os_tag <span class="tok-kw">orelse</span> builtin.os.tag;</span>
<span class="line" id="L435">}</span>
<span class="line" id="L436"></span>
<span class="line" id="L437"><span class="tok-comment">/// TODO deprecated, use `std.zig.system.NativeTargetInfo.detect`.</span></span>
<span class="line" id="L438"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">getOsVersionMin</span>(self: CrossTarget) OsVersion {</span>
<span class="line" id="L439">    <span class="tok-kw">if</span> (self.os_version_min) |version_min| <span class="tok-kw">return</span> version_min;</span>
<span class="line" id="L440">    <span class="tok-kw">var</span> tmp: CrossTarget = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L441">    tmp.updateOsVersionRange(self.getOs());</span>
<span class="line" id="L442">    <span class="tok-kw">return</span> tmp.os_version_min.?;</span>
<span class="line" id="L443">}</span>
<span class="line" id="L444"></span>
<span class="line" id="L445"><span class="tok-comment">/// TODO deprecated, use `std.zig.system.NativeTargetInfo.detect`.</span></span>
<span class="line" id="L446"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">getOsVersionMax</span>(self: CrossTarget) OsVersion {</span>
<span class="line" id="L447">    <span class="tok-kw">if</span> (self.os_version_max) |version_max| <span class="tok-kw">return</span> version_max;</span>
<span class="line" id="L448">    <span class="tok-kw">var</span> tmp: CrossTarget = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L449">    tmp.updateOsVersionRange(self.getOs());</span>
<span class="line" id="L450">    <span class="tok-kw">return</span> tmp.os_version_max.?;</span>
<span class="line" id="L451">}</span>
<span class="line" id="L452"></span>
<span class="line" id="L453"><span class="tok-comment">/// TODO deprecated, use `std.zig.system.NativeTargetInfo.detect`.</span></span>
<span class="line" id="L454"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">getAbi</span>(self: CrossTarget) Target.Abi {</span>
<span class="line" id="L455">    <span class="tok-kw">if</span> (self.abi) |abi| <span class="tok-kw">return</span> abi;</span>
<span class="line" id="L456"></span>
<span class="line" id="L457">    <span class="tok-kw">if</span> (self.os_tag == <span class="tok-null">null</span>) {</span>
<span class="line" id="L458">        <span class="tok-comment">// This works when doing `zig build` because Zig generates a build executable using</span>
</span>
<span class="line" id="L459">        <span class="tok-comment">// native CPU model &amp; features. However this will not be accurate otherwise, and</span>
</span>
<span class="line" id="L460">        <span class="tok-comment">// will need to be integrated with `std.zig.system.NativeTargetInfo.detect`.</span>
</span>
<span class="line" id="L461">        <span class="tok-kw">return</span> builtin.abi;</span>
<span class="line" id="L462">    }</span>
<span class="line" id="L463"></span>
<span class="line" id="L464">    <span class="tok-kw">return</span> Target.Abi.default(self.getCpuArch(), self.getOs());</span>
<span class="line" id="L465">}</span>
<span class="line" id="L466"></span>
<span class="line" id="L467"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">isFreeBSD</span>(self: CrossTarget) <span class="tok-type">bool</span> {</span>
<span class="line" id="L468">    <span class="tok-kw">return</span> self.getOsTag() == .freebsd;</span>
<span class="line" id="L469">}</span>
<span class="line" id="L470"></span>
<span class="line" id="L471"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">isDarwin</span>(self: CrossTarget) <span class="tok-type">bool</span> {</span>
<span class="line" id="L472">    <span class="tok-kw">return</span> self.getOsTag().isDarwin();</span>
<span class="line" id="L473">}</span>
<span class="line" id="L474"></span>
<span class="line" id="L475"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">isNetBSD</span>(self: CrossTarget) <span class="tok-type">bool</span> {</span>
<span class="line" id="L476">    <span class="tok-kw">return</span> self.getOsTag() == .netbsd;</span>
<span class="line" id="L477">}</span>
<span class="line" id="L478"></span>
<span class="line" id="L479"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">isOpenBSD</span>(self: CrossTarget) <span class="tok-type">bool</span> {</span>
<span class="line" id="L480">    <span class="tok-kw">return</span> self.getOsTag() == .openbsd;</span>
<span class="line" id="L481">}</span>
<span class="line" id="L482"></span>
<span class="line" id="L483"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">isUefi</span>(self: CrossTarget) <span class="tok-type">bool</span> {</span>
<span class="line" id="L484">    <span class="tok-kw">return</span> self.getOsTag() == .uefi;</span>
<span class="line" id="L485">}</span>
<span class="line" id="L486"></span>
<span class="line" id="L487"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">isDragonFlyBSD</span>(self: CrossTarget) <span class="tok-type">bool</span> {</span>
<span class="line" id="L488">    <span class="tok-kw">return</span> self.getOsTag() == .dragonfly;</span>
<span class="line" id="L489">}</span>
<span class="line" id="L490"></span>
<span class="line" id="L491"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">isLinux</span>(self: CrossTarget) <span class="tok-type">bool</span> {</span>
<span class="line" id="L492">    <span class="tok-kw">return</span> self.getOsTag() == .linux;</span>
<span class="line" id="L493">}</span>
<span class="line" id="L494"></span>
<span class="line" id="L495"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">isWindows</span>(self: CrossTarget) <span class="tok-type">bool</span> {</span>
<span class="line" id="L496">    <span class="tok-kw">return</span> self.getOsTag() == .windows;</span>
<span class="line" id="L497">}</span>
<span class="line" id="L498"></span>
<span class="line" id="L499"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">exeFileExt</span>(self: CrossTarget) [:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span> {</span>
<span class="line" id="L500">    <span class="tok-kw">return</span> Target.exeFileExtSimple(self.getCpuArch(), self.getOsTag());</span>
<span class="line" id="L501">}</span>
<span class="line" id="L502"></span>
<span class="line" id="L503"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">staticLibSuffix</span>(self: CrossTarget) [:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span> {</span>
<span class="line" id="L504">    <span class="tok-kw">return</span> Target.staticLibSuffix_os_abi(self.getOsTag(), self.getAbi());</span>
<span class="line" id="L505">}</span>
<span class="line" id="L506"></span>
<span class="line" id="L507"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">dynamicLibSuffix</span>(self: CrossTarget) [:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span> {</span>
<span class="line" id="L508">    <span class="tok-kw">return</span> self.getOsTag().dynamicLibSuffix();</span>
<span class="line" id="L509">}</span>
<span class="line" id="L510"></span>
<span class="line" id="L511"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">libPrefix</span>(self: CrossTarget) [:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span> {</span>
<span class="line" id="L512">    <span class="tok-kw">return</span> Target.libPrefix_os_abi(self.getOsTag(), self.getAbi());</span>
<span class="line" id="L513">}</span>
<span class="line" id="L514"></span>
<span class="line" id="L515"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">isNativeCpu</span>(self: CrossTarget) <span class="tok-type">bool</span> {</span>
<span class="line" id="L516">    <span class="tok-kw">return</span> self.cpu_arch == <span class="tok-null">null</span> <span class="tok-kw">and</span></span>
<span class="line" id="L517">        (self.cpu_model == .native <span class="tok-kw">or</span> self.cpu_model == .determined_by_cpu_arch) <span class="tok-kw">and</span></span>
<span class="line" id="L518">        self.cpu_features_sub.isEmpty() <span class="tok-kw">and</span> self.cpu_features_add.isEmpty();</span>
<span class="line" id="L519">}</span>
<span class="line" id="L520"></span>
<span class="line" id="L521"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">isNativeOs</span>(self: CrossTarget) <span class="tok-type">bool</span> {</span>
<span class="line" id="L522">    <span class="tok-kw">return</span> self.os_tag == <span class="tok-null">null</span> <span class="tok-kw">and</span> self.os_version_min == <span class="tok-null">null</span> <span class="tok-kw">and</span> self.os_version_max == <span class="tok-null">null</span> <span class="tok-kw">and</span></span>
<span class="line" id="L523">        self.dynamic_linker.get() == <span class="tok-null">null</span> <span class="tok-kw">and</span> self.glibc_version == <span class="tok-null">null</span>;</span>
<span class="line" id="L524">}</span>
<span class="line" id="L525"></span>
<span class="line" id="L526"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">isNativeAbi</span>(self: CrossTarget) <span class="tok-type">bool</span> {</span>
<span class="line" id="L527">    <span class="tok-kw">return</span> self.os_tag == <span class="tok-null">null</span> <span class="tok-kw">and</span> self.abi == <span class="tok-null">null</span>;</span>
<span class="line" id="L528">}</span>
<span class="line" id="L529"></span>
<span class="line" id="L530"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">isNative</span>(self: CrossTarget) <span class="tok-type">bool</span> {</span>
<span class="line" id="L531">    <span class="tok-kw">return</span> self.isNativeCpu() <span class="tok-kw">and</span> self.isNativeOs() <span class="tok-kw">and</span> self.isNativeAbi();</span>
<span class="line" id="L532">}</span>
<span class="line" id="L533"></span>
<span class="line" id="L534"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">zigTriple</span>(self: CrossTarget, allocator: mem.Allocator) <span class="tok-kw">error</span>{OutOfMemory}![]<span class="tok-type">u8</span> {</span>
<span class="line" id="L535">    <span class="tok-kw">if</span> (self.isNative()) {</span>
<span class="line" id="L536">        <span class="tok-kw">return</span> allocator.dupe(<span class="tok-type">u8</span>, <span class="tok-str">&quot;native&quot;</span>);</span>
<span class="line" id="L537">    }</span>
<span class="line" id="L538"></span>
<span class="line" id="L539">    <span class="tok-kw">const</span> arch_name = <span class="tok-kw">if</span> (self.cpu_arch) |arch| <span class="tok-builtin">@tagName</span>(arch) <span class="tok-kw">else</span> <span class="tok-str">&quot;native&quot;</span>;</span>
<span class="line" id="L540">    <span class="tok-kw">const</span> os_name = <span class="tok-kw">if</span> (self.os_tag) |os_tag| <span class="tok-builtin">@tagName</span>(os_tag) <span class="tok-kw">else</span> <span class="tok-str">&quot;native&quot;</span>;</span>
<span class="line" id="L541"></span>
<span class="line" id="L542">    <span class="tok-kw">var</span> result = std.ArrayList(<span class="tok-type">u8</span>).init(allocator);</span>
<span class="line" id="L543">    <span class="tok-kw">defer</span> result.deinit();</span>
<span class="line" id="L544"></span>
<span class="line" id="L545">    <span class="tok-kw">try</span> result.writer().print(<span class="tok-str">&quot;{s}-{s}&quot;</span>, .{ arch_name, os_name });</span>
<span class="line" id="L546"></span>
<span class="line" id="L547">    <span class="tok-comment">// The zig target syntax does not allow specifying a max os version with no min, so</span>
</span>
<span class="line" id="L548">    <span class="tok-comment">// if either are present, we need the min.</span>
</span>
<span class="line" id="L549">    <span class="tok-kw">if</span> (self.os_version_min != <span class="tok-null">null</span> <span class="tok-kw">or</span> self.os_version_max != <span class="tok-null">null</span>) {</span>
<span class="line" id="L550">        <span class="tok-kw">switch</span> (self.getOsVersionMin()) {</span>
<span class="line" id="L551">            .none =&gt; {},</span>
<span class="line" id="L552">            .semver =&gt; |v| <span class="tok-kw">try</span> result.writer().print(<span class="tok-str">&quot;.{}&quot;</span>, .{v}),</span>
<span class="line" id="L553">            .windows =&gt; |v| <span class="tok-kw">try</span> result.writer().print(<span class="tok-str">&quot;{s}&quot;</span>, .{v}),</span>
<span class="line" id="L554">        }</span>
<span class="line" id="L555">    }</span>
<span class="line" id="L556">    <span class="tok-kw">if</span> (self.os_version_max) |max| {</span>
<span class="line" id="L557">        <span class="tok-kw">switch</span> (max) {</span>
<span class="line" id="L558">            .none =&gt; {},</span>
<span class="line" id="L559">            .semver =&gt; |v| <span class="tok-kw">try</span> result.writer().print(<span class="tok-str">&quot;...{}&quot;</span>, .{v}),</span>
<span class="line" id="L560">            .windows =&gt; |v| <span class="tok-kw">try</span> result.writer().print(<span class="tok-str">&quot;..{s}&quot;</span>, .{v}),</span>
<span class="line" id="L561">        }</span>
<span class="line" id="L562">    }</span>
<span class="line" id="L563"></span>
<span class="line" id="L564">    <span class="tok-kw">if</span> (self.glibc_version) |v| {</span>
<span class="line" id="L565">        <span class="tok-kw">try</span> result.writer().print(<span class="tok-str">&quot;-{s}.{}&quot;</span>, .{ <span class="tok-builtin">@tagName</span>(self.getAbi()), v });</span>
<span class="line" id="L566">    } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (self.abi) |abi| {</span>
<span class="line" id="L567">        <span class="tok-kw">try</span> result.writer().print(<span class="tok-str">&quot;-{s}&quot;</span>, .{<span class="tok-builtin">@tagName</span>(abi)});</span>
<span class="line" id="L568">    }</span>
<span class="line" id="L569"></span>
<span class="line" id="L570">    <span class="tok-kw">return</span> result.toOwnedSlice();</span>
<span class="line" id="L571">}</span>
<span class="line" id="L572"></span>
<span class="line" id="L573"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">allocDescription</span>(self: CrossTarget, allocator: mem.Allocator) ![]<span class="tok-type">u8</span> {</span>
<span class="line" id="L574">    <span class="tok-comment">// TODO is there anything else worthy of the description that is not</span>
</span>
<span class="line" id="L575">    <span class="tok-comment">// already captured in the triple?</span>
</span>
<span class="line" id="L576">    <span class="tok-kw">return</span> self.zigTriple(allocator);</span>
<span class="line" id="L577">}</span>
<span class="line" id="L578"></span>
<span class="line" id="L579"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">linuxTriple</span>(self: CrossTarget, allocator: mem.Allocator) ![]<span class="tok-type">u8</span> {</span>
<span class="line" id="L580">    <span class="tok-kw">return</span> Target.linuxTripleSimple(allocator, self.getCpuArch(), self.getOsTag(), self.getAbi());</span>
<span class="line" id="L581">}</span>
<span class="line" id="L582"></span>
<span class="line" id="L583"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">wantSharedLibSymLinks</span>(self: CrossTarget) <span class="tok-type">bool</span> {</span>
<span class="line" id="L584">    <span class="tok-kw">return</span> self.getOsTag() != .windows;</span>
<span class="line" id="L585">}</span>
<span class="line" id="L586"></span>
<span class="line" id="L587"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> VcpkgLinkage = std.builtin.LinkMode;</span>
<span class="line" id="L588"></span>
<span class="line" id="L589"><span class="tok-comment">/// Returned slice must be freed by the caller.</span></span>
<span class="line" id="L590"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">vcpkgTriplet</span>(self: CrossTarget, allocator: mem.Allocator, linkage: VcpkgLinkage) ![]<span class="tok-type">u8</span> {</span>
<span class="line" id="L591">    <span class="tok-kw">const</span> arch = <span class="tok-kw">switch</span> (self.getCpuArch()) {</span>
<span class="line" id="L592">        .<span class="tok-type">i386</span> =&gt; <span class="tok-str">&quot;x86&quot;</span>,</span>
<span class="line" id="L593">        .x86_64 =&gt; <span class="tok-str">&quot;x64&quot;</span>,</span>
<span class="line" id="L594"></span>
<span class="line" id="L595">        .arm,</span>
<span class="line" id="L596">        .armeb,</span>
<span class="line" id="L597">        .thumb,</span>
<span class="line" id="L598">        .thumbeb,</span>
<span class="line" id="L599">        .aarch64_32,</span>
<span class="line" id="L600">        =&gt; <span class="tok-str">&quot;arm&quot;</span>,</span>
<span class="line" id="L601"></span>
<span class="line" id="L602">        .aarch64,</span>
<span class="line" id="L603">        .aarch64_be,</span>
<span class="line" id="L604">        =&gt; <span class="tok-str">&quot;arm64&quot;</span>,</span>
<span class="line" id="L605"></span>
<span class="line" id="L606">        <span class="tok-kw">else</span> =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.UnsupportedVcpkgArchitecture,</span>
<span class="line" id="L607">    };</span>
<span class="line" id="L608"></span>
<span class="line" id="L609">    <span class="tok-kw">const</span> os = <span class="tok-kw">switch</span> (self.getOsTag()) {</span>
<span class="line" id="L610">        .windows =&gt; <span class="tok-str">&quot;windows&quot;</span>,</span>
<span class="line" id="L611">        .linux =&gt; <span class="tok-str">&quot;linux&quot;</span>,</span>
<span class="line" id="L612">        .macos =&gt; <span class="tok-str">&quot;macos&quot;</span>,</span>
<span class="line" id="L613">        <span class="tok-kw">else</span> =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.UnsupportedVcpkgOperatingSystem,</span>
<span class="line" id="L614">    };</span>
<span class="line" id="L615"></span>
<span class="line" id="L616">    <span class="tok-kw">const</span> static_suffix = <span class="tok-kw">switch</span> (linkage) {</span>
<span class="line" id="L617">        .Static =&gt; <span class="tok-str">&quot;-static&quot;</span>,</span>
<span class="line" id="L618">        .Dynamic =&gt; <span class="tok-str">&quot;&quot;</span>,</span>
<span class="line" id="L619">    };</span>
<span class="line" id="L620"></span>
<span class="line" id="L621">    <span class="tok-kw">return</span> std.fmt.allocPrint(allocator, <span class="tok-str">&quot;{s}-{s}{s}&quot;</span>, .{ arch, os, static_suffix });</span>
<span class="line" id="L622">}</span>
<span class="line" id="L623"></span>
<span class="line" id="L624"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">isGnuLibC</span>(self: CrossTarget) <span class="tok-type">bool</span> {</span>
<span class="line" id="L625">    <span class="tok-kw">return</span> Target.isGnuLibC_os_tag_abi(self.getOsTag(), self.getAbi());</span>
<span class="line" id="L626">}</span>
<span class="line" id="L627"></span>
<span class="line" id="L628"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">setGnuLibCVersion</span>(self: *CrossTarget, major: <span class="tok-type">u32</span>, minor: <span class="tok-type">u32</span>, patch: <span class="tok-type">u32</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L629">    assert(self.isGnuLibC());</span>
<span class="line" id="L630">    self.glibc_version = SemVer{ .major = major, .minor = minor, .patch = patch };</span>
<span class="line" id="L631">}</span>
<span class="line" id="L632"></span>
<span class="line" id="L633"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">getObjectFormat</span>(self: CrossTarget) Target.ObjectFormat {</span>
<span class="line" id="L634">    <span class="tok-kw">return</span> self.ofmt <span class="tok-kw">orelse</span> Target.ObjectFormat.default(self.getOsTag(), self.getCpuArch());</span>
<span class="line" id="L635">}</span>
<span class="line" id="L636"></span>
<span class="line" id="L637"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">updateCpuFeatures</span>(self: CrossTarget, set: *Target.Cpu.Feature.Set) <span class="tok-type">void</span> {</span>
<span class="line" id="L638">    set.removeFeatureSet(self.cpu_features_sub);</span>
<span class="line" id="L639">    set.addFeatureSet(self.cpu_features_add);</span>
<span class="line" id="L640">    set.populateDependencies(self.getCpuArch().allFeaturesList());</span>
<span class="line" id="L641">    set.removeFeatureSet(self.cpu_features_sub);</span>
<span class="line" id="L642">}</span>
<span class="line" id="L643"></span>
<span class="line" id="L644"><span class="tok-kw">fn</span> <span class="tok-fn">parseOs</span>(result: *CrossTarget, diags: *ParseOptions.Diagnostics, text: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) !<span class="tok-type">void</span> {</span>
<span class="line" id="L645">    <span class="tok-kw">var</span> it = mem.split(<span class="tok-type">u8</span>, text, <span class="tok-str">&quot;.&quot;</span>);</span>
<span class="line" id="L646">    <span class="tok-kw">const</span> os_name = it.first();</span>
<span class="line" id="L647">    diags.os_name = os_name;</span>
<span class="line" id="L648">    <span class="tok-kw">const</span> os_is_native = mem.eql(<span class="tok-type">u8</span>, os_name, <span class="tok-str">&quot;native&quot;</span>);</span>
<span class="line" id="L649">    <span class="tok-kw">if</span> (!os_is_native) {</span>
<span class="line" id="L650">        result.os_tag = std.meta.stringToEnum(Target.Os.Tag, os_name) <span class="tok-kw">orelse</span></span>
<span class="line" id="L651">            <span class="tok-kw">return</span> <span class="tok-kw">error</span>.UnknownOperatingSystem;</span>
<span class="line" id="L652">    }</span>
<span class="line" id="L653">    <span class="tok-kw">const</span> tag = result.getOsTag();</span>
<span class="line" id="L654">    diags.os_tag = tag;</span>
<span class="line" id="L655"></span>
<span class="line" id="L656">    <span class="tok-kw">const</span> version_text = it.rest();</span>
<span class="line" id="L657">    <span class="tok-kw">if</span> (it.next() == <span class="tok-null">null</span>) <span class="tok-kw">return</span>;</span>
<span class="line" id="L658"></span>
<span class="line" id="L659">    <span class="tok-kw">switch</span> (tag) {</span>
<span class="line" id="L660">        .freestanding,</span>
<span class="line" id="L661">        .ananas,</span>
<span class="line" id="L662">        .cloudabi,</span>
<span class="line" id="L663">        .fuchsia,</span>
<span class="line" id="L664">        .kfreebsd,</span>
<span class="line" id="L665">        .lv2,</span>
<span class="line" id="L666">        .solaris,</span>
<span class="line" id="L667">        .zos,</span>
<span class="line" id="L668">        .haiku,</span>
<span class="line" id="L669">        .minix,</span>
<span class="line" id="L670">        .rtems,</span>
<span class="line" id="L671">        .nacl,</span>
<span class="line" id="L672">        .aix,</span>
<span class="line" id="L673">        .cuda,</span>
<span class="line" id="L674">        .nvcl,</span>
<span class="line" id="L675">        .amdhsa,</span>
<span class="line" id="L676">        .ps4,</span>
<span class="line" id="L677">        .elfiamcu,</span>
<span class="line" id="L678">        .mesa3d,</span>
<span class="line" id="L679">        .contiki,</span>
<span class="line" id="L680">        .amdpal,</span>
<span class="line" id="L681">        .hermit,</span>
<span class="line" id="L682">        .hurd,</span>
<span class="line" id="L683">        .wasi,</span>
<span class="line" id="L684">        .emscripten,</span>
<span class="line" id="L685">        .uefi,</span>
<span class="line" id="L686">        .opencl,</span>
<span class="line" id="L687">        .glsl450,</span>
<span class="line" id="L688">        .vulkan,</span>
<span class="line" id="L689">        .plan9,</span>
<span class="line" id="L690">        .other,</span>
<span class="line" id="L691">        =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InvalidOperatingSystemVersion,</span>
<span class="line" id="L692"></span>
<span class="line" id="L693">        .freebsd,</span>
<span class="line" id="L694">        .macos,</span>
<span class="line" id="L695">        .ios,</span>
<span class="line" id="L696">        .tvos,</span>
<span class="line" id="L697">        .watchos,</span>
<span class="line" id="L698">        .netbsd,</span>
<span class="line" id="L699">        .openbsd,</span>
<span class="line" id="L700">        .linux,</span>
<span class="line" id="L701">        .dragonfly,</span>
<span class="line" id="L702">        =&gt; {</span>
<span class="line" id="L703">            <span class="tok-kw">var</span> range_it = mem.split(<span class="tok-type">u8</span>, version_text, <span class="tok-str">&quot;...&quot;</span>);</span>
<span class="line" id="L704"></span>
<span class="line" id="L705">            <span class="tok-kw">const</span> min_text = range_it.next().?;</span>
<span class="line" id="L706">            <span class="tok-kw">const</span> min_ver = SemVer.parse(min_text) <span class="tok-kw">catch</span> |err| <span class="tok-kw">switch</span> (err) {</span>
<span class="line" id="L707">                <span class="tok-kw">error</span>.Overflow =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InvalidOperatingSystemVersion,</span>
<span class="line" id="L708">                <span class="tok-kw">error</span>.InvalidCharacter =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InvalidOperatingSystemVersion,</span>
<span class="line" id="L709">                <span class="tok-kw">error</span>.InvalidVersion =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InvalidOperatingSystemVersion,</span>
<span class="line" id="L710">            };</span>
<span class="line" id="L711">            result.os_version_min = .{ .semver = min_ver };</span>
<span class="line" id="L712"></span>
<span class="line" id="L713">            <span class="tok-kw">const</span> max_text = range_it.next() <span class="tok-kw">orelse</span> <span class="tok-kw">return</span>;</span>
<span class="line" id="L714">            <span class="tok-kw">const</span> max_ver = SemVer.parse(max_text) <span class="tok-kw">catch</span> |err| <span class="tok-kw">switch</span> (err) {</span>
<span class="line" id="L715">                <span class="tok-kw">error</span>.Overflow =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InvalidOperatingSystemVersion,</span>
<span class="line" id="L716">                <span class="tok-kw">error</span>.InvalidCharacter =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InvalidOperatingSystemVersion,</span>
<span class="line" id="L717">                <span class="tok-kw">error</span>.InvalidVersion =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InvalidOperatingSystemVersion,</span>
<span class="line" id="L718">            };</span>
<span class="line" id="L719">            result.os_version_max = .{ .semver = max_ver };</span>
<span class="line" id="L720">        },</span>
<span class="line" id="L721"></span>
<span class="line" id="L722">        .windows =&gt; {</span>
<span class="line" id="L723">            <span class="tok-kw">var</span> range_it = mem.split(<span class="tok-type">u8</span>, version_text, <span class="tok-str">&quot;...&quot;</span>);</span>
<span class="line" id="L724"></span>
<span class="line" id="L725">            <span class="tok-kw">const</span> min_text = range_it.first();</span>
<span class="line" id="L726">            <span class="tok-kw">const</span> min_ver = std.meta.stringToEnum(Target.Os.WindowsVersion, min_text) <span class="tok-kw">orelse</span></span>
<span class="line" id="L727">                <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InvalidOperatingSystemVersion;</span>
<span class="line" id="L728">            result.os_version_min = .{ .windows = min_ver };</span>
<span class="line" id="L729"></span>
<span class="line" id="L730">            <span class="tok-kw">const</span> max_text = range_it.next() <span class="tok-kw">orelse</span> <span class="tok-kw">return</span>;</span>
<span class="line" id="L731">            <span class="tok-kw">const</span> max_ver = std.meta.stringToEnum(Target.Os.WindowsVersion, max_text) <span class="tok-kw">orelse</span></span>
<span class="line" id="L732">                <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InvalidOperatingSystemVersion;</span>
<span class="line" id="L733">            result.os_version_max = .{ .windows = max_ver };</span>
<span class="line" id="L734">        },</span>
<span class="line" id="L735">    }</span>
<span class="line" id="L736">}</span>
<span class="line" id="L737"></span>
<span class="line" id="L738"><span class="tok-kw">test</span> <span class="tok-str">&quot;CrossTarget.parse&quot;</span> {</span>
<span class="line" id="L739">    <span class="tok-kw">if</span> (builtin.target.isGnuLibC()) {</span>
<span class="line" id="L740">        <span class="tok-kw">var</span> cross_target = <span class="tok-kw">try</span> CrossTarget.parse(.{});</span>
<span class="line" id="L741">        cross_target.setGnuLibCVersion(<span class="tok-number">2</span>, <span class="tok-number">1</span>, <span class="tok-number">1</span>);</span>
<span class="line" id="L742"></span>
<span class="line" id="L743">        <span class="tok-kw">const</span> text = <span class="tok-kw">try</span> cross_target.zigTriple(std.testing.allocator);</span>
<span class="line" id="L744">        <span class="tok-kw">defer</span> std.testing.allocator.free(text);</span>
<span class="line" id="L745"></span>
<span class="line" id="L746">        <span class="tok-kw">var</span> buf: [<span class="tok-number">256</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L747">        <span class="tok-kw">const</span> triple = std.fmt.bufPrint(</span>
<span class="line" id="L748">            buf[<span class="tok-number">0</span>..],</span>
<span class="line" id="L749">            <span class="tok-str">&quot;native-native-{s}.2.1.1&quot;</span>,</span>
<span class="line" id="L750">            .{<span class="tok-builtin">@tagName</span>(builtin.abi)},</span>
<span class="line" id="L751">        ) <span class="tok-kw">catch</span> <span class="tok-kw">unreachable</span>;</span>
<span class="line" id="L752"></span>
<span class="line" id="L753">        <span class="tok-kw">try</span> std.testing.expectEqualSlices(<span class="tok-type">u8</span>, triple, text);</span>
<span class="line" id="L754">    }</span>
<span class="line" id="L755">    {</span>
<span class="line" id="L756">        <span class="tok-kw">const</span> cross_target = <span class="tok-kw">try</span> CrossTarget.parse(.{</span>
<span class="line" id="L757">            .arch_os_abi = <span class="tok-str">&quot;aarch64-linux&quot;</span>,</span>
<span class="line" id="L758">            .cpu_features = <span class="tok-str">&quot;native&quot;</span>,</span>
<span class="line" id="L759">        });</span>
<span class="line" id="L760"></span>
<span class="line" id="L761">        <span class="tok-kw">try</span> std.testing.expect(cross_target.cpu_arch.? == .aarch64);</span>
<span class="line" id="L762">        <span class="tok-kw">try</span> std.testing.expect(cross_target.cpu_model == .native);</span>
<span class="line" id="L763">    }</span>
<span class="line" id="L764">    {</span>
<span class="line" id="L765">        <span class="tok-kw">const</span> cross_target = <span class="tok-kw">try</span> CrossTarget.parse(.{ .arch_os_abi = <span class="tok-str">&quot;native&quot;</span> });</span>
<span class="line" id="L766"></span>
<span class="line" id="L767">        <span class="tok-kw">try</span> std.testing.expect(cross_target.cpu_arch == <span class="tok-null">null</span>);</span>
<span class="line" id="L768">        <span class="tok-kw">try</span> std.testing.expect(cross_target.isNative());</span>
<span class="line" id="L769"></span>
<span class="line" id="L770">        <span class="tok-kw">const</span> text = <span class="tok-kw">try</span> cross_target.zigTriple(std.testing.allocator);</span>
<span class="line" id="L771">        <span class="tok-kw">defer</span> std.testing.allocator.free(text);</span>
<span class="line" id="L772">        <span class="tok-kw">try</span> std.testing.expectEqualSlices(<span class="tok-type">u8</span>, <span class="tok-str">&quot;native&quot;</span>, text);</span>
<span class="line" id="L773">    }</span>
<span class="line" id="L774">    {</span>
<span class="line" id="L775">        <span class="tok-kw">const</span> cross_target = <span class="tok-kw">try</span> CrossTarget.parse(.{</span>
<span class="line" id="L776">            .arch_os_abi = <span class="tok-str">&quot;x86_64-linux-gnu&quot;</span>,</span>
<span class="line" id="L777">            .cpu_features = <span class="tok-str">&quot;x86_64-sse-sse2-avx-cx8&quot;</span>,</span>
<span class="line" id="L778">        });</span>
<span class="line" id="L779">        <span class="tok-kw">const</span> target = cross_target.toTarget();</span>
<span class="line" id="L780"></span>
<span class="line" id="L781">        <span class="tok-kw">try</span> std.testing.expect(target.os.tag == .linux);</span>
<span class="line" id="L782">        <span class="tok-kw">try</span> std.testing.expect(target.abi == .gnu);</span>
<span class="line" id="L783">        <span class="tok-kw">try</span> std.testing.expect(target.cpu.arch == .x86_64);</span>
<span class="line" id="L784">        <span class="tok-kw">try</span> std.testing.expect(!Target.x86.featureSetHas(target.cpu.features, .sse));</span>
<span class="line" id="L785">        <span class="tok-kw">try</span> std.testing.expect(!Target.x86.featureSetHas(target.cpu.features, .avx));</span>
<span class="line" id="L786">        <span class="tok-kw">try</span> std.testing.expect(!Target.x86.featureSetHas(target.cpu.features, .cx8));</span>
<span class="line" id="L787">        <span class="tok-kw">try</span> std.testing.expect(Target.x86.featureSetHas(target.cpu.features, .cmov));</span>
<span class="line" id="L788">        <span class="tok-kw">try</span> std.testing.expect(Target.x86.featureSetHas(target.cpu.features, .fxsr));</span>
<span class="line" id="L789"></span>
<span class="line" id="L790">        <span class="tok-kw">try</span> std.testing.expect(Target.x86.featureSetHasAny(target.cpu.features, .{ .sse, .avx, .cmov }));</span>
<span class="line" id="L791">        <span class="tok-kw">try</span> std.testing.expect(!Target.x86.featureSetHasAny(target.cpu.features, .{ .sse, .avx }));</span>
<span class="line" id="L792">        <span class="tok-kw">try</span> std.testing.expect(Target.x86.featureSetHasAll(target.cpu.features, .{ .mmx, .x87 }));</span>
<span class="line" id="L793">        <span class="tok-kw">try</span> std.testing.expect(!Target.x86.featureSetHasAll(target.cpu.features, .{ .mmx, .x87, .sse }));</span>
<span class="line" id="L794"></span>
<span class="line" id="L795">        <span class="tok-kw">const</span> text = <span class="tok-kw">try</span> cross_target.zigTriple(std.testing.allocator);</span>
<span class="line" id="L796">        <span class="tok-kw">defer</span> std.testing.allocator.free(text);</span>
<span class="line" id="L797">        <span class="tok-kw">try</span> std.testing.expectEqualSlices(<span class="tok-type">u8</span>, <span class="tok-str">&quot;x86_64-linux-gnu&quot;</span>, text);</span>
<span class="line" id="L798">    }</span>
<span class="line" id="L799">    {</span>
<span class="line" id="L800">        <span class="tok-kw">const</span> cross_target = <span class="tok-kw">try</span> CrossTarget.parse(.{</span>
<span class="line" id="L801">            .arch_os_abi = <span class="tok-str">&quot;arm-linux-musleabihf&quot;</span>,</span>
<span class="line" id="L802">            .cpu_features = <span class="tok-str">&quot;generic+v8a&quot;</span>,</span>
<span class="line" id="L803">        });</span>
<span class="line" id="L804">        <span class="tok-kw">const</span> target = cross_target.toTarget();</span>
<span class="line" id="L805"></span>
<span class="line" id="L806">        <span class="tok-kw">try</span> std.testing.expect(target.os.tag == .linux);</span>
<span class="line" id="L807">        <span class="tok-kw">try</span> std.testing.expect(target.abi == .musleabihf);</span>
<span class="line" id="L808">        <span class="tok-kw">try</span> std.testing.expect(target.cpu.arch == .arm);</span>
<span class="line" id="L809">        <span class="tok-kw">try</span> std.testing.expect(target.cpu.model == &amp;Target.arm.cpu.generic);</span>
<span class="line" id="L810">        <span class="tok-kw">try</span> std.testing.expect(Target.arm.featureSetHas(target.cpu.features, .v8a));</span>
<span class="line" id="L811"></span>
<span class="line" id="L812">        <span class="tok-kw">const</span> text = <span class="tok-kw">try</span> cross_target.zigTriple(std.testing.allocator);</span>
<span class="line" id="L813">        <span class="tok-kw">defer</span> std.testing.allocator.free(text);</span>
<span class="line" id="L814">        <span class="tok-kw">try</span> std.testing.expectEqualSlices(<span class="tok-type">u8</span>, <span class="tok-str">&quot;arm-linux-musleabihf&quot;</span>, text);</span>
<span class="line" id="L815">    }</span>
<span class="line" id="L816">    {</span>
<span class="line" id="L817">        <span class="tok-kw">const</span> cross_target = <span class="tok-kw">try</span> CrossTarget.parse(.{</span>
<span class="line" id="L818">            .arch_os_abi = <span class="tok-str">&quot;aarch64-linux.3.10...4.4.1-gnu.2.27&quot;</span>,</span>
<span class="line" id="L819">            .cpu_features = <span class="tok-str">&quot;generic+v8a&quot;</span>,</span>
<span class="line" id="L820">        });</span>
<span class="line" id="L821">        <span class="tok-kw">const</span> target = cross_target.toTarget();</span>
<span class="line" id="L822"></span>
<span class="line" id="L823">        <span class="tok-kw">try</span> std.testing.expect(target.cpu.arch == .aarch64);</span>
<span class="line" id="L824">        <span class="tok-kw">try</span> std.testing.expect(target.os.tag == .linux);</span>
<span class="line" id="L825">        <span class="tok-kw">try</span> std.testing.expect(target.os.version_range.linux.range.min.major == <span class="tok-number">3</span>);</span>
<span class="line" id="L826">        <span class="tok-kw">try</span> std.testing.expect(target.os.version_range.linux.range.min.minor == <span class="tok-number">10</span>);</span>
<span class="line" id="L827">        <span class="tok-kw">try</span> std.testing.expect(target.os.version_range.linux.range.min.patch == <span class="tok-number">0</span>);</span>
<span class="line" id="L828">        <span class="tok-kw">try</span> std.testing.expect(target.os.version_range.linux.range.max.major == <span class="tok-number">4</span>);</span>
<span class="line" id="L829">        <span class="tok-kw">try</span> std.testing.expect(target.os.version_range.linux.range.max.minor == <span class="tok-number">4</span>);</span>
<span class="line" id="L830">        <span class="tok-kw">try</span> std.testing.expect(target.os.version_range.linux.range.max.patch == <span class="tok-number">1</span>);</span>
<span class="line" id="L831">        <span class="tok-kw">try</span> std.testing.expect(target.os.version_range.linux.glibc.major == <span class="tok-number">2</span>);</span>
<span class="line" id="L832">        <span class="tok-kw">try</span> std.testing.expect(target.os.version_range.linux.glibc.minor == <span class="tok-number">27</span>);</span>
<span class="line" id="L833">        <span class="tok-kw">try</span> std.testing.expect(target.os.version_range.linux.glibc.patch == <span class="tok-number">0</span>);</span>
<span class="line" id="L834">        <span class="tok-kw">try</span> std.testing.expect(target.abi == .gnu);</span>
<span class="line" id="L835"></span>
<span class="line" id="L836">        <span class="tok-kw">const</span> text = <span class="tok-kw">try</span> cross_target.zigTriple(std.testing.allocator);</span>
<span class="line" id="L837">        <span class="tok-kw">defer</span> std.testing.allocator.free(text);</span>
<span class="line" id="L838">        <span class="tok-kw">try</span> std.testing.expectEqualSlices(<span class="tok-type">u8</span>, <span class="tok-str">&quot;aarch64-linux.3.10...4.4.1-gnu.2.27&quot;</span>, text);</span>
<span class="line" id="L839">    }</span>
<span class="line" id="L840">}</span>
<span class="line" id="L841"></span>
</code></pre></body>
</html>