<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">    <title>os/darwin.zig - source view</title>
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
<span class="line" id="L3"><span class="tok-kw">const</span> log = std.log;</span>
<span class="line" id="L4"><span class="tok-kw">const</span> mem = std.mem;</span>
<span class="line" id="L5"></span>
<span class="line" id="L6"><span class="tok-kw">pub</span> <span class="tok-kw">usingnamespace</span> std.c;</span>
<span class="line" id="L7"><span class="tok-kw">pub</span> <span class="tok-kw">usingnamespace</span> mach_task;</span>
<span class="line" id="L8"></span>
<span class="line" id="L9"><span class="tok-kw">const</span> mach_task = <span class="tok-kw">if</span> (builtin.target.isDarwin()) <span class="tok-kw">struct</span> {</span>
<span class="line" id="L10">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> MachError = <span class="tok-kw">error</span>{</span>
<span class="line" id="L11">        <span class="tok-comment">/// Not enough permissions held to perform the requested kernel</span></span>
<span class="line" id="L12">        <span class="tok-comment">/// call.</span></span>
<span class="line" id="L13">        PermissionDenied,</span>
<span class="line" id="L14">        <span class="tok-comment">/// Kernel returned an unhandled and unexpected error code.</span></span>
<span class="line" id="L15">        <span class="tok-comment">/// This is a catch-all for any yet unobserved kernel response</span></span>
<span class="line" id="L16">        <span class="tok-comment">/// to some Mach message.</span></span>
<span class="line" id="L17">        Unexpected,</span>
<span class="line" id="L18">    };</span>
<span class="line" id="L19"></span>
<span class="line" id="L20">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> MachTask = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L21">        port: std.c.mach_port_name_t,</span>
<span class="line" id="L22"></span>
<span class="line" id="L23">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">isValid</span>(self: MachTask) <span class="tok-type">bool</span> {</span>
<span class="line" id="L24">            <span class="tok-kw">return</span> self.port != <span class="tok-number">0</span>;</span>
<span class="line" id="L25">        }</span>
<span class="line" id="L26"></span>
<span class="line" id="L27">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> RegionInfo = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L28">            <span class="tok-kw">pub</span> <span class="tok-kw">const</span> Tag = <span class="tok-kw">enum</span> {</span>
<span class="line" id="L29">                basic,</span>
<span class="line" id="L30">                extended,</span>
<span class="line" id="L31">                top,</span>
<span class="line" id="L32">            };</span>
<span class="line" id="L33"></span>
<span class="line" id="L34">            base_addr: <span class="tok-type">u64</span>,</span>
<span class="line" id="L35">            tag: Tag,</span>
<span class="line" id="L36">            info: <span class="tok-kw">union</span> {</span>
<span class="line" id="L37">                basic: std.c.vm_region_basic_info_64,</span>
<span class="line" id="L38">                extended: std.c.vm_region_extended_info,</span>
<span class="line" id="L39">                top: std.c.vm_region_top_info,</span>
<span class="line" id="L40">            },</span>
<span class="line" id="L41">        };</span>
<span class="line" id="L42"></span>
<span class="line" id="L43">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">getRegionInfo</span>(</span>
<span class="line" id="L44">            task: MachTask,</span>
<span class="line" id="L45">            address: <span class="tok-type">u64</span>,</span>
<span class="line" id="L46">            len: <span class="tok-type">usize</span>,</span>
<span class="line" id="L47">            tag: RegionInfo.Tag,</span>
<span class="line" id="L48">        ) MachError!RegionInfo {</span>
<span class="line" id="L49">            <span class="tok-kw">var</span> info: RegionInfo = .{</span>
<span class="line" id="L50">                .base_addr = address,</span>
<span class="line" id="L51">                .tag = tag,</span>
<span class="line" id="L52">                .info = <span class="tok-null">undefined</span>,</span>
<span class="line" id="L53">            };</span>
<span class="line" id="L54">            <span class="tok-kw">switch</span> (tag) {</span>
<span class="line" id="L55">                .basic =&gt; info.info = .{ .basic = <span class="tok-null">undefined</span> },</span>
<span class="line" id="L56">                .extended =&gt; info.info = .{ .extended = <span class="tok-null">undefined</span> },</span>
<span class="line" id="L57">                .top =&gt; info.info = .{ .top = <span class="tok-null">undefined</span> },</span>
<span class="line" id="L58">            }</span>
<span class="line" id="L59">            <span class="tok-kw">var</span> base_len: std.c.mach_vm_size_t = <span class="tok-kw">if</span> (len == <span class="tok-number">1</span>) <span class="tok-number">2</span> <span class="tok-kw">else</span> len;</span>
<span class="line" id="L60">            <span class="tok-kw">var</span> objname: std.c.mach_port_t = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L61">            <span class="tok-kw">var</span> count: std.c.mach_msg_type_number_t = <span class="tok-kw">switch</span> (tag) {</span>
<span class="line" id="L62">                .basic =&gt; std.c.VM_REGION_BASIC_INFO_COUNT,</span>
<span class="line" id="L63">                .extended =&gt; std.c.VM_REGION_EXTENDED_INFO_COUNT,</span>
<span class="line" id="L64">                .top =&gt; std.c.VM_REGION_TOP_INFO_COUNT,</span>
<span class="line" id="L65">            };</span>
<span class="line" id="L66">            <span class="tok-kw">switch</span> (std.c.getKernError(std.c.mach_vm_region(</span>
<span class="line" id="L67">                task.port,</span>
<span class="line" id="L68">                &amp;info.base_addr,</span>
<span class="line" id="L69">                &amp;base_len,</span>
<span class="line" id="L70">                <span class="tok-kw">switch</span> (tag) {</span>
<span class="line" id="L71">                    .basic =&gt; std.c.VM_REGION_BASIC_INFO_64,</span>
<span class="line" id="L72">                    .extended =&gt; std.c.VM_REGION_EXTENDED_INFO,</span>
<span class="line" id="L73">                    .top =&gt; std.c.VM_REGION_TOP_INFO,</span>
<span class="line" id="L74">                },</span>
<span class="line" id="L75">                <span class="tok-kw">switch</span> (tag) {</span>
<span class="line" id="L76">                    .basic =&gt; <span class="tok-builtin">@ptrCast</span>(std.c.vm_region_info_t, &amp;info.info.basic),</span>
<span class="line" id="L77">                    .extended =&gt; <span class="tok-builtin">@ptrCast</span>(std.c.vm_region_info_t, &amp;info.info.extended),</span>
<span class="line" id="L78">                    .top =&gt; <span class="tok-builtin">@ptrCast</span>(std.c.vm_region_info_t, &amp;info.info.top),</span>
<span class="line" id="L79">                },</span>
<span class="line" id="L80">                &amp;count,</span>
<span class="line" id="L81">                &amp;objname,</span>
<span class="line" id="L82">            ))) {</span>
<span class="line" id="L83">                .SUCCESS =&gt; <span class="tok-kw">return</span> info,</span>
<span class="line" id="L84">                .FAILURE =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.PermissionDenied,</span>
<span class="line" id="L85">                <span class="tok-kw">else</span> =&gt; |err| {</span>
<span class="line" id="L86">                    log.err(<span class="tok-str">&quot;mach_vm_region kernel call failed with error code: {s}&quot;</span>, .{<span class="tok-builtin">@tagName</span>(err)});</span>
<span class="line" id="L87">                    <span class="tok-kw">return</span> <span class="tok-kw">error</span>.Unexpected;</span>
<span class="line" id="L88">                },</span>
<span class="line" id="L89">            }</span>
<span class="line" id="L90">        }</span>
<span class="line" id="L91"></span>
<span class="line" id="L92">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> RegionSubmapInfo = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L93">            <span class="tok-kw">pub</span> <span class="tok-kw">const</span> Tag = <span class="tok-kw">enum</span> {</span>
<span class="line" id="L94">                short,</span>
<span class="line" id="L95">                full,</span>
<span class="line" id="L96">            };</span>
<span class="line" id="L97"></span>
<span class="line" id="L98">            tag: Tag,</span>
<span class="line" id="L99">            base_addr: <span class="tok-type">u64</span>,</span>
<span class="line" id="L100">            info: <span class="tok-kw">union</span> {</span>
<span class="line" id="L101">                short: std.c.vm_region_submap_short_info_64,</span>
<span class="line" id="L102">                full: std.c.vm_region_submap_info_64,</span>
<span class="line" id="L103">            },</span>
<span class="line" id="L104">        };</span>
<span class="line" id="L105"></span>
<span class="line" id="L106">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">getRegionSubmapInfo</span>(</span>
<span class="line" id="L107">            task: MachTask,</span>
<span class="line" id="L108">            address: <span class="tok-type">u64</span>,</span>
<span class="line" id="L109">            len: <span class="tok-type">usize</span>,</span>
<span class="line" id="L110">            nesting_depth: <span class="tok-type">u32</span>,</span>
<span class="line" id="L111">            tag: RegionSubmapInfo.Tag,</span>
<span class="line" id="L112">        ) MachError!RegionSubmapInfo {</span>
<span class="line" id="L113">            <span class="tok-kw">var</span> info: RegionSubmapInfo = .{</span>
<span class="line" id="L114">                .base_addr = address,</span>
<span class="line" id="L115">                .tag = tag,</span>
<span class="line" id="L116">                .info = <span class="tok-null">undefined</span>,</span>
<span class="line" id="L117">            };</span>
<span class="line" id="L118">            <span class="tok-kw">switch</span> (tag) {</span>
<span class="line" id="L119">                .short =&gt; info.info = .{ .short = <span class="tok-null">undefined</span> },</span>
<span class="line" id="L120">                .full =&gt; info.info = .{ .full = <span class="tok-null">undefined</span> },</span>
<span class="line" id="L121">            }</span>
<span class="line" id="L122">            <span class="tok-kw">var</span> nesting = nesting_depth;</span>
<span class="line" id="L123">            <span class="tok-kw">var</span> base_len: std.c.mach_vm_size_t = <span class="tok-kw">if</span> (len == <span class="tok-number">1</span>) <span class="tok-number">2</span> <span class="tok-kw">else</span> len;</span>
<span class="line" id="L124">            <span class="tok-kw">var</span> count: std.c.mach_msg_type_number_t = <span class="tok-kw">switch</span> (tag) {</span>
<span class="line" id="L125">                .short =&gt; std.c.VM_REGION_SUBMAP_SHORT_INFO_COUNT_64,</span>
<span class="line" id="L126">                .full =&gt; std.c.VM_REGION_SUBMAP_INFO_COUNT_64,</span>
<span class="line" id="L127">            };</span>
<span class="line" id="L128">            <span class="tok-kw">switch</span> (std.c.getKernError(std.c.mach_vm_region_recurse(</span>
<span class="line" id="L129">                task.port,</span>
<span class="line" id="L130">                &amp;info.base_addr,</span>
<span class="line" id="L131">                &amp;base_len,</span>
<span class="line" id="L132">                &amp;nesting,</span>
<span class="line" id="L133">                <span class="tok-kw">switch</span> (tag) {</span>
<span class="line" id="L134">                    .short =&gt; <span class="tok-builtin">@ptrCast</span>(std.c.vm_region_recurse_info_t, &amp;info.info.short),</span>
<span class="line" id="L135">                    .full =&gt; <span class="tok-builtin">@ptrCast</span>(std.c.vm_region_recurse_info_t, &amp;info.info.full),</span>
<span class="line" id="L136">                },</span>
<span class="line" id="L137">                &amp;count,</span>
<span class="line" id="L138">            ))) {</span>
<span class="line" id="L139">                .SUCCESS =&gt; <span class="tok-kw">return</span> info,</span>
<span class="line" id="L140">                .FAILURE =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.PermissionDenied,</span>
<span class="line" id="L141">                <span class="tok-kw">else</span> =&gt; |err| {</span>
<span class="line" id="L142">                    log.err(<span class="tok-str">&quot;mach_vm_region kernel call failed with error code: {s}&quot;</span>, .{<span class="tok-builtin">@tagName</span>(err)});</span>
<span class="line" id="L143">                    <span class="tok-kw">return</span> <span class="tok-kw">error</span>.Unexpected;</span>
<span class="line" id="L144">                },</span>
<span class="line" id="L145">            }</span>
<span class="line" id="L146">        }</span>
<span class="line" id="L147"></span>
<span class="line" id="L148">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">getCurrProtection</span>(task: MachTask, address: <span class="tok-type">u64</span>, len: <span class="tok-type">usize</span>) MachError!std.c.vm_prot_t {</span>
<span class="line" id="L149">            <span class="tok-kw">const</span> info = <span class="tok-kw">try</span> task.getRegionSubmapInfo(address, len, <span class="tok-number">0</span>, .short);</span>
<span class="line" id="L150">            <span class="tok-kw">return</span> info.info.short.protection;</span>
<span class="line" id="L151">        }</span>
<span class="line" id="L152"></span>
<span class="line" id="L153">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">setMaxProtection</span>(task: MachTask, address: <span class="tok-type">u64</span>, len: <span class="tok-type">usize</span>, prot: std.c.vm_prot_t) MachError!<span class="tok-type">void</span> {</span>
<span class="line" id="L154">            <span class="tok-kw">return</span> task.setProtectionImpl(address, len, <span class="tok-null">true</span>, prot);</span>
<span class="line" id="L155">        }</span>
<span class="line" id="L156"></span>
<span class="line" id="L157">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">setCurrProtection</span>(task: MachTask, address: <span class="tok-type">u64</span>, len: <span class="tok-type">usize</span>, prot: std.c.vm_prot_t) MachError!<span class="tok-type">void</span> {</span>
<span class="line" id="L158">            <span class="tok-kw">return</span> task.setProtectionImpl(address, len, <span class="tok-null">false</span>, prot);</span>
<span class="line" id="L159">        }</span>
<span class="line" id="L160"></span>
<span class="line" id="L161">        <span class="tok-kw">fn</span> <span class="tok-fn">setProtectionImpl</span>(task: MachTask, address: <span class="tok-type">u64</span>, len: <span class="tok-type">usize</span>, set_max: <span class="tok-type">bool</span>, prot: std.c.vm_prot_t) MachError!<span class="tok-type">void</span> {</span>
<span class="line" id="L162">            <span class="tok-kw">switch</span> (std.c.getKernError(std.c.mach_vm_protect(task.port, address, len, <span class="tok-builtin">@boolToInt</span>(set_max), prot))) {</span>
<span class="line" id="L163">                .SUCCESS =&gt; <span class="tok-kw">return</span>,</span>
<span class="line" id="L164">                .FAILURE =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.PermissionDenied,</span>
<span class="line" id="L165">                <span class="tok-kw">else</span> =&gt; |err| {</span>
<span class="line" id="L166">                    log.err(<span class="tok-str">&quot;mach_vm_protect kernel call failed with error code: {s}&quot;</span>, .{<span class="tok-builtin">@tagName</span>(err)});</span>
<span class="line" id="L167">                    <span class="tok-kw">return</span> <span class="tok-kw">error</span>.Unexpected;</span>
<span class="line" id="L168">                },</span>
<span class="line" id="L169">            }</span>
<span class="line" id="L170">        }</span>
<span class="line" id="L171"></span>
<span class="line" id="L172">        <span class="tok-comment">/// Will write to VM even if current protection attributes specifically prohibit</span></span>
<span class="line" id="L173">        <span class="tok-comment">/// us from doing so, by temporarily setting protection level to a level with VM_PROT_COPY</span></span>
<span class="line" id="L174">        <span class="tok-comment">/// variant, and resetting after a successful or unsuccessful write.</span></span>
<span class="line" id="L175">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">writeMemProtected</span>(task: MachTask, address: <span class="tok-type">u64</span>, buf: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, arch: std.Target.Cpu.Arch) MachError!<span class="tok-type">usize</span> {</span>
<span class="line" id="L176">            <span class="tok-kw">const</span> curr_prot = <span class="tok-kw">try</span> task.getCurrProtection(address, buf.len);</span>
<span class="line" id="L177">            <span class="tok-kw">try</span> task.setCurrProtection(</span>
<span class="line" id="L178">                address,</span>
<span class="line" id="L179">                buf.len,</span>
<span class="line" id="L180">                std.c.PROT.READ | std.c.PROT.WRITE | std.c.PROT.COPY,</span>
<span class="line" id="L181">            );</span>
<span class="line" id="L182">            <span class="tok-kw">defer</span> {</span>
<span class="line" id="L183">                task.setCurrProtection(address, buf.len, curr_prot) <span class="tok-kw">catch</span> {};</span>
<span class="line" id="L184">            }</span>
<span class="line" id="L185">            <span class="tok-kw">return</span> task.writeMem(address, buf, arch);</span>
<span class="line" id="L186">        }</span>
<span class="line" id="L187"></span>
<span class="line" id="L188">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">writeMem</span>(task: MachTask, address: <span class="tok-type">u64</span>, buf: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, arch: std.Target.Cpu.Arch) MachError!<span class="tok-type">usize</span> {</span>
<span class="line" id="L189">            <span class="tok-kw">const</span> count = buf.len;</span>
<span class="line" id="L190">            <span class="tok-kw">var</span> total_written: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L191">            <span class="tok-kw">var</span> curr_addr = address;</span>
<span class="line" id="L192">            <span class="tok-kw">const</span> page_size = <span class="tok-kw">try</span> getPageSize(task); <span class="tok-comment">// TODO we probably can assume value here</span>
</span>
<span class="line" id="L193">            <span class="tok-kw">var</span> out_buf = buf[<span class="tok-number">0</span>..];</span>
<span class="line" id="L194"></span>
<span class="line" id="L195">            <span class="tok-kw">while</span> (total_written &lt; count) {</span>
<span class="line" id="L196">                <span class="tok-kw">const</span> curr_size = maxBytesLeftInPage(page_size, curr_addr, count - total_written);</span>
<span class="line" id="L197">                <span class="tok-kw">switch</span> (std.c.getKernError(std.c.mach_vm_write(</span>
<span class="line" id="L198">                    task.port,</span>
<span class="line" id="L199">                    curr_addr,</span>
<span class="line" id="L200">                    <span class="tok-builtin">@ptrToInt</span>(out_buf.ptr),</span>
<span class="line" id="L201">                    <span class="tok-builtin">@intCast</span>(std.c.mach_msg_type_number_t, curr_size),</span>
<span class="line" id="L202">                ))) {</span>
<span class="line" id="L203">                    .SUCCESS =&gt; {},</span>
<span class="line" id="L204">                    .FAILURE =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.PermissionDenied,</span>
<span class="line" id="L205">                    <span class="tok-kw">else</span> =&gt; |err| {</span>
<span class="line" id="L206">                        log.err(<span class="tok-str">&quot;mach_vm_write kernel call failed with error code: {s}&quot;</span>, .{<span class="tok-builtin">@tagName</span>(err)});</span>
<span class="line" id="L207">                        <span class="tok-kw">return</span> <span class="tok-kw">error</span>.Unexpected;</span>
<span class="line" id="L208">                    },</span>
<span class="line" id="L209">                }</span>
<span class="line" id="L210"></span>
<span class="line" id="L211">                <span class="tok-kw">switch</span> (arch) {</span>
<span class="line" id="L212">                    .aarch64 =&gt; {</span>
<span class="line" id="L213">                        <span class="tok-kw">var</span> mattr_value: std.c.vm_machine_attribute_val_t = std.c.MATTR_VAL_CACHE_FLUSH;</span>
<span class="line" id="L214">                        <span class="tok-kw">switch</span> (std.c.getKernError(std.c.vm_machine_attribute(</span>
<span class="line" id="L215">                            task.port,</span>
<span class="line" id="L216">                            curr_addr,</span>
<span class="line" id="L217">                            curr_size,</span>
<span class="line" id="L218">                            std.c.MATTR_CACHE,</span>
<span class="line" id="L219">                            &amp;mattr_value,</span>
<span class="line" id="L220">                        ))) {</span>
<span class="line" id="L221">                            .SUCCESS =&gt; {},</span>
<span class="line" id="L222">                            .FAILURE =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.PermissionDenied,</span>
<span class="line" id="L223">                            <span class="tok-kw">else</span> =&gt; |err| {</span>
<span class="line" id="L224">                                log.err(<span class="tok-str">&quot;vm_machine_attribute kernel call failed with error code: {s}&quot;</span>, .{<span class="tok-builtin">@tagName</span>(err)});</span>
<span class="line" id="L225">                                <span class="tok-kw">return</span> <span class="tok-kw">error</span>.Unexpected;</span>
<span class="line" id="L226">                            },</span>
<span class="line" id="L227">                        }</span>
<span class="line" id="L228">                    },</span>
<span class="line" id="L229">                    .x86_64 =&gt; {},</span>
<span class="line" id="L230">                    <span class="tok-kw">else</span> =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L231">                }</span>
<span class="line" id="L232"></span>
<span class="line" id="L233">                out_buf = out_buf[curr_size..];</span>
<span class="line" id="L234">                total_written += curr_size;</span>
<span class="line" id="L235">                curr_addr += curr_size;</span>
<span class="line" id="L236">            }</span>
<span class="line" id="L237"></span>
<span class="line" id="L238">            <span class="tok-kw">return</span> total_written;</span>
<span class="line" id="L239">        }</span>
<span class="line" id="L240"></span>
<span class="line" id="L241">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">readMem</span>(task: MachTask, address: <span class="tok-type">u64</span>, buf: []<span class="tok-type">u8</span>) MachError!<span class="tok-type">usize</span> {</span>
<span class="line" id="L242">            <span class="tok-kw">const</span> count = buf.len;</span>
<span class="line" id="L243">            <span class="tok-kw">var</span> total_read: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L244">            <span class="tok-kw">var</span> curr_addr = address;</span>
<span class="line" id="L245">            <span class="tok-kw">const</span> page_size = <span class="tok-kw">try</span> getPageSize(task); <span class="tok-comment">// TODO we probably can assume value here</span>
</span>
<span class="line" id="L246">            <span class="tok-kw">var</span> out_buf = buf[<span class="tok-number">0</span>..];</span>
<span class="line" id="L247"></span>
<span class="line" id="L248">            <span class="tok-kw">while</span> (total_read &lt; count) {</span>
<span class="line" id="L249">                <span class="tok-kw">const</span> curr_size = maxBytesLeftInPage(page_size, curr_addr, count - total_read);</span>
<span class="line" id="L250">                <span class="tok-kw">var</span> curr_bytes_read: std.c.mach_msg_type_number_t = <span class="tok-number">0</span>;</span>
<span class="line" id="L251">                <span class="tok-kw">var</span> vm_memory: std.c.vm_offset_t = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L252">                <span class="tok-kw">switch</span> (std.c.getKernError(std.c.mach_vm_read(task.port, curr_addr, curr_size, &amp;vm_memory, &amp;curr_bytes_read))) {</span>
<span class="line" id="L253">                    .SUCCESS =&gt; {},</span>
<span class="line" id="L254">                    .FAILURE =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.PermissionDenied,</span>
<span class="line" id="L255">                    <span class="tok-kw">else</span> =&gt; |err| {</span>
<span class="line" id="L256">                        log.err(<span class="tok-str">&quot;mach_vm_read kernel call failed with error code: {s}&quot;</span>, .{<span class="tok-builtin">@tagName</span>(err)});</span>
<span class="line" id="L257">                        <span class="tok-kw">return</span> <span class="tok-kw">error</span>.Unexpected;</span>
<span class="line" id="L258">                    },</span>
<span class="line" id="L259">                }</span>
<span class="line" id="L260"></span>
<span class="line" id="L261">                <span class="tok-builtin">@memcpy</span>(out_buf[<span class="tok-number">0</span>..].ptr, <span class="tok-builtin">@intToPtr</span>([*]<span class="tok-kw">const</span> <span class="tok-type">u8</span>, vm_memory), curr_bytes_read);</span>
<span class="line" id="L262">                _ = std.c.vm_deallocate(std.c.mach_task_self(), vm_memory, curr_bytes_read);</span>
<span class="line" id="L263"></span>
<span class="line" id="L264">                out_buf = out_buf[curr_bytes_read..];</span>
<span class="line" id="L265">                curr_addr += curr_bytes_read;</span>
<span class="line" id="L266">                total_read += curr_bytes_read;</span>
<span class="line" id="L267">            }</span>
<span class="line" id="L268"></span>
<span class="line" id="L269">            <span class="tok-kw">return</span> total_read;</span>
<span class="line" id="L270">        }</span>
<span class="line" id="L271"></span>
<span class="line" id="L272">        <span class="tok-kw">fn</span> <span class="tok-fn">maxBytesLeftInPage</span>(page_size: <span class="tok-type">usize</span>, address: <span class="tok-type">u64</span>, count: <span class="tok-type">usize</span>) <span class="tok-type">usize</span> {</span>
<span class="line" id="L273">            <span class="tok-kw">var</span> left = count;</span>
<span class="line" id="L274">            <span class="tok-kw">if</span> (page_size &gt; <span class="tok-number">0</span>) {</span>
<span class="line" id="L275">                <span class="tok-kw">const</span> page_offset = address % page_size;</span>
<span class="line" id="L276">                <span class="tok-kw">const</span> bytes_left_in_page = page_size - page_offset;</span>
<span class="line" id="L277">                <span class="tok-kw">if</span> (count &gt; bytes_left_in_page) {</span>
<span class="line" id="L278">                    left = bytes_left_in_page;</span>
<span class="line" id="L279">                }</span>
<span class="line" id="L280">            }</span>
<span class="line" id="L281">            <span class="tok-kw">return</span> left;</span>
<span class="line" id="L282">        }</span>
<span class="line" id="L283"></span>
<span class="line" id="L284">        <span class="tok-kw">fn</span> <span class="tok-fn">getPageSize</span>(task: MachTask) MachError!<span class="tok-type">usize</span> {</span>
<span class="line" id="L285">            <span class="tok-kw">if</span> (task.isValid()) {</span>
<span class="line" id="L286">                <span class="tok-kw">var</span> info_count = std.c.TASK_VM_INFO_COUNT;</span>
<span class="line" id="L287">                <span class="tok-kw">var</span> vm_info: std.c.task_vm_info_data_t = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L288">                <span class="tok-kw">switch</span> (std.c.getKernError(std.c.task_info(</span>
<span class="line" id="L289">                    task.port,</span>
<span class="line" id="L290">                    std.c.TASK_VM_INFO,</span>
<span class="line" id="L291">                    <span class="tok-builtin">@ptrCast</span>(std.c.task_info_t, &amp;vm_info),</span>
<span class="line" id="L292">                    &amp;info_count,</span>
<span class="line" id="L293">                ))) {</span>
<span class="line" id="L294">                    .SUCCESS =&gt; <span class="tok-kw">return</span> <span class="tok-builtin">@intCast</span>(<span class="tok-type">usize</span>, vm_info.page_size),</span>
<span class="line" id="L295">                    <span class="tok-kw">else</span> =&gt; {},</span>
<span class="line" id="L296">                }</span>
<span class="line" id="L297">            }</span>
<span class="line" id="L298">            <span class="tok-kw">var</span> page_size: std.c.vm_size_t = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L299">            <span class="tok-kw">switch</span> (std.c.getKernError(std.c._host_page_size(std.c.mach_host_self(), &amp;page_size))) {</span>
<span class="line" id="L300">                .SUCCESS =&gt; <span class="tok-kw">return</span> page_size,</span>
<span class="line" id="L301">                <span class="tok-kw">else</span> =&gt; |err| {</span>
<span class="line" id="L302">                    log.err(<span class="tok-str">&quot;_host_page_size kernel call failed with error code: {s}&quot;</span>, .{<span class="tok-builtin">@tagName</span>(err)});</span>
<span class="line" id="L303">                    <span class="tok-kw">return</span> <span class="tok-kw">error</span>.Unexpected;</span>
<span class="line" id="L304">                },</span>
<span class="line" id="L305">            }</span>
<span class="line" id="L306">        }</span>
<span class="line" id="L307">    };</span>
<span class="line" id="L308"></span>
<span class="line" id="L309">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">machTaskForPid</span>(pid: std.os.pid_t) MachError!MachTask {</span>
<span class="line" id="L310">        <span class="tok-kw">var</span> port: std.c.mach_port_name_t = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L311">        <span class="tok-kw">switch</span> (std.c.getKernError(std.c.task_for_pid(std.c.mach_task_self(), pid, &amp;port))) {</span>
<span class="line" id="L312">            .SUCCESS =&gt; {},</span>
<span class="line" id="L313">            .FAILURE =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.PermissionDenied,</span>
<span class="line" id="L314">            <span class="tok-kw">else</span> =&gt; |err| {</span>
<span class="line" id="L315">                log.err(<span class="tok-str">&quot;task_for_pid kernel call failed with error code: {s}&quot;</span>, .{<span class="tok-builtin">@tagName</span>(err)});</span>
<span class="line" id="L316">                <span class="tok-kw">return</span> <span class="tok-kw">error</span>.Unexpected;</span>
<span class="line" id="L317">            },</span>
<span class="line" id="L318">        }</span>
<span class="line" id="L319">        <span class="tok-kw">return</span> MachTask{ .port = port };</span>
<span class="line" id="L320">    }</span>
<span class="line" id="L321"></span>
<span class="line" id="L322">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">machTaskForSelf</span>() MachTask {</span>
<span class="line" id="L323">        <span class="tok-kw">return</span> .{ .port = std.c.mach_task_self() };</span>
<span class="line" id="L324">    }</span>
<span class="line" id="L325">} <span class="tok-kw">else</span> <span class="tok-kw">struct</span> {};</span>
<span class="line" id="L326"></span>
</code></pre></body>
</html>