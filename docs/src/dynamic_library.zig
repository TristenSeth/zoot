<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">    <title>dynamic_library.zig - source view</title>
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
<span class="line" id="L3"><span class="tok-kw">const</span> mem = std.mem;</span>
<span class="line" id="L4"><span class="tok-kw">const</span> os = std.os;</span>
<span class="line" id="L5"><span class="tok-kw">const</span> assert = std.debug.assert;</span>
<span class="line" id="L6"><span class="tok-kw">const</span> testing = std.testing;</span>
<span class="line" id="L7"><span class="tok-kw">const</span> elf = std.elf;</span>
<span class="line" id="L8"><span class="tok-kw">const</span> windows = std.os.windows;</span>
<span class="line" id="L9"><span class="tok-kw">const</span> system = std.os.system;</span>
<span class="line" id="L10"><span class="tok-kw">const</span> maxInt = std.math.maxInt;</span>
<span class="line" id="L11"><span class="tok-kw">const</span> max = std.math.max;</span>
<span class="line" id="L12"></span>
<span class="line" id="L13"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> DynLib = <span class="tok-kw">switch</span> (builtin.os.tag) {</span>
<span class="line" id="L14">    .linux =&gt; <span class="tok-kw">if</span> (builtin.link_libc) DlDynlib <span class="tok-kw">else</span> ElfDynLib,</span>
<span class="line" id="L15">    .windows =&gt; WindowsDynLib,</span>
<span class="line" id="L16">    .macos, .tvos, .watchos, .ios, .freebsd, .netbsd, .openbsd, .dragonfly, .solaris =&gt; DlDynlib,</span>
<span class="line" id="L17">    <span class="tok-kw">else</span> =&gt; <span class="tok-type">void</span>,</span>
<span class="line" id="L18">};</span>
<span class="line" id="L19"></span>
<span class="line" id="L20"><span class="tok-comment">// The link_map structure is not completely specified beside the fields</span>
</span>
<span class="line" id="L21"><span class="tok-comment">// reported below, any libc is free to store additional data in the remaining</span>
</span>
<span class="line" id="L22"><span class="tok-comment">// space.</span>
</span>
<span class="line" id="L23"><span class="tok-comment">// An iterator is provided in order to traverse the linked list in a idiomatic</span>
</span>
<span class="line" id="L24"><span class="tok-comment">// fashion.</span>
</span>
<span class="line" id="L25"><span class="tok-kw">const</span> LinkMap = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L26">    l_addr: <span class="tok-type">usize</span>,</span>
<span class="line" id="L27">    l_name: [*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L28">    l_ld: ?*elf.Dyn,</span>
<span class="line" id="L29">    l_next: ?*LinkMap,</span>
<span class="line" id="L30">    l_prev: ?*LinkMap,</span>
<span class="line" id="L31"></span>
<span class="line" id="L32">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> Iterator = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L33">        current: ?*LinkMap,</span>
<span class="line" id="L34"></span>
<span class="line" id="L35">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">end</span>(self: *Iterator) <span class="tok-type">bool</span> {</span>
<span class="line" id="L36">            <span class="tok-kw">return</span> self.current == <span class="tok-null">null</span>;</span>
<span class="line" id="L37">        }</span>
<span class="line" id="L38"></span>
<span class="line" id="L39">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">next</span>(self: *Iterator) ?*LinkMap {</span>
<span class="line" id="L40">            <span class="tok-kw">if</span> (self.current) |it| {</span>
<span class="line" id="L41">                self.current = it.l_next;</span>
<span class="line" id="L42">                <span class="tok-kw">return</span> it;</span>
<span class="line" id="L43">            }</span>
<span class="line" id="L44">            <span class="tok-kw">return</span> <span class="tok-null">null</span>;</span>
<span class="line" id="L45">        }</span>
<span class="line" id="L46">    };</span>
<span class="line" id="L47">};</span>
<span class="line" id="L48"></span>
<span class="line" id="L49"><span class="tok-kw">const</span> RDebug = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L50">    r_version: <span class="tok-type">i32</span>,</span>
<span class="line" id="L51">    r_map: ?*LinkMap,</span>
<span class="line" id="L52">    r_brk: <span class="tok-type">usize</span>,</span>
<span class="line" id="L53">    r_ldbase: <span class="tok-type">usize</span>,</span>
<span class="line" id="L54">};</span>
<span class="line" id="L55"></span>
<span class="line" id="L56"><span class="tok-comment">/// TODO make it possible to reference this same external symbol 2x so we don't need this</span></span>
<span class="line" id="L57"><span class="tok-comment">/// helper function.</span></span>
<span class="line" id="L58"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">get_DYNAMIC</span>() ?[*]elf.Dyn {</span>
<span class="line" id="L59">    <span class="tok-kw">return</span> <span class="tok-builtin">@extern</span>([*]elf.Dyn, .{ .name = <span class="tok-str">&quot;_DYNAMIC&quot;</span>, .linkage = .Weak });</span>
<span class="line" id="L60">}</span>
<span class="line" id="L61"></span>
<span class="line" id="L62"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">linkmap_iterator</span>(phdrs: []elf.Phdr) !LinkMap.Iterator {</span>
<span class="line" id="L63">    _ = phdrs;</span>
<span class="line" id="L64">    <span class="tok-kw">const</span> _DYNAMIC = get_DYNAMIC() <span class="tok-kw">orelse</span> {</span>
<span class="line" id="L65">        <span class="tok-comment">// No PT_DYNAMIC means this is either a statically-linked program or a</span>
</span>
<span class="line" id="L66">        <span class="tok-comment">// badly corrupted dynamically-linked one.</span>
</span>
<span class="line" id="L67">        <span class="tok-kw">return</span> LinkMap.Iterator{ .current = <span class="tok-null">null</span> };</span>
<span class="line" id="L68">    };</span>
<span class="line" id="L69"></span>
<span class="line" id="L70">    <span class="tok-kw">const</span> link_map_ptr = init: {</span>
<span class="line" id="L71">        <span class="tok-kw">var</span> i: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L72">        <span class="tok-kw">while</span> (_DYNAMIC[i].d_tag != elf.DT_NULL) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L73">            <span class="tok-kw">switch</span> (_DYNAMIC[i].d_tag) {</span>
<span class="line" id="L74">                elf.DT_DEBUG =&gt; {</span>
<span class="line" id="L75">                    <span class="tok-kw">const</span> ptr = <span class="tok-builtin">@intToPtr</span>(?*RDebug, _DYNAMIC[i].d_val);</span>
<span class="line" id="L76">                    <span class="tok-kw">if</span> (ptr) |r_debug| {</span>
<span class="line" id="L77">                        <span class="tok-kw">if</span> (r_debug.r_version != <span class="tok-number">1</span>) <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InvalidExe;</span>
<span class="line" id="L78">                        <span class="tok-kw">break</span> :init r_debug.r_map;</span>
<span class="line" id="L79">                    }</span>
<span class="line" id="L80">                },</span>
<span class="line" id="L81">                elf.DT_PLTGOT =&gt; {</span>
<span class="line" id="L82">                    <span class="tok-kw">const</span> ptr = <span class="tok-builtin">@intToPtr</span>(?[*]<span class="tok-type">usize</span>, _DYNAMIC[i].d_val);</span>
<span class="line" id="L83">                    <span class="tok-kw">if</span> (ptr) |got_table| {</span>
<span class="line" id="L84">                        <span class="tok-comment">// The address to the link_map structure is stored in</span>
</span>
<span class="line" id="L85">                        <span class="tok-comment">// the second slot</span>
</span>
<span class="line" id="L86">                        <span class="tok-kw">break</span> :init <span class="tok-builtin">@intToPtr</span>(?*LinkMap, got_table[<span class="tok-number">1</span>]);</span>
<span class="line" id="L87">                    }</span>
<span class="line" id="L88">                },</span>
<span class="line" id="L89">                <span class="tok-kw">else</span> =&gt; {},</span>
<span class="line" id="L90">            }</span>
<span class="line" id="L91">        }</span>
<span class="line" id="L92">        <span class="tok-kw">return</span> LinkMap.Iterator{ .current = <span class="tok-null">null</span> };</span>
<span class="line" id="L93">    };</span>
<span class="line" id="L94"></span>
<span class="line" id="L95">    <span class="tok-kw">return</span> LinkMap.Iterator{ .current = link_map_ptr };</span>
<span class="line" id="L96">}</span>
<span class="line" id="L97"></span>
<span class="line" id="L98"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> ElfDynLib = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L99">    strings: [*:<span class="tok-number">0</span>]<span class="tok-type">u8</span>,</span>
<span class="line" id="L100">    syms: [*]elf.Sym,</span>
<span class="line" id="L101">    hashtab: [*]os.Elf_Symndx,</span>
<span class="line" id="L102">    versym: ?[*]<span class="tok-type">u16</span>,</span>
<span class="line" id="L103">    verdef: ?*elf.Verdef,</span>
<span class="line" id="L104">    memory: []<span class="tok-kw">align</span>(mem.page_size) <span class="tok-type">u8</span>,</span>
<span class="line" id="L105"></span>
<span class="line" id="L106">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> Error = <span class="tok-kw">error</span>{</span>
<span class="line" id="L107">        FileTooBig,</span>
<span class="line" id="L108">        NotElfFile,</span>
<span class="line" id="L109">        NotDynamicLibrary,</span>
<span class="line" id="L110">        MissingDynamicLinkingInformation,</span>
<span class="line" id="L111">        ElfStringSectionNotFound,</span>
<span class="line" id="L112">        ElfSymSectionNotFound,</span>
<span class="line" id="L113">        ElfHashTableNotFound,</span>
<span class="line" id="L114">    };</span>
<span class="line" id="L115"></span>
<span class="line" id="L116">    <span class="tok-comment">/// Trusts the file. Malicious file will be able to execute arbitrary code.</span></span>
<span class="line" id="L117">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">open</span>(path: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) !ElfDynLib {</span>
<span class="line" id="L118">        <span class="tok-kw">const</span> fd = <span class="tok-kw">try</span> os.open(path, <span class="tok-number">0</span>, os.O.RDONLY | os.O.CLOEXEC);</span>
<span class="line" id="L119">        <span class="tok-kw">defer</span> os.close(fd);</span>
<span class="line" id="L120"></span>
<span class="line" id="L121">        <span class="tok-kw">const</span> stat = <span class="tok-kw">try</span> os.fstat(fd);</span>
<span class="line" id="L122">        <span class="tok-kw">const</span> size = std.math.cast(<span class="tok-type">usize</span>, stat.size) <span class="tok-kw">orelse</span> <span class="tok-kw">return</span> <span class="tok-kw">error</span>.FileTooBig;</span>
<span class="line" id="L123"></span>
<span class="line" id="L124">        <span class="tok-comment">// This one is to read the ELF info. We do more mmapping later</span>
</span>
<span class="line" id="L125">        <span class="tok-comment">// corresponding to the actual LOAD sections.</span>
</span>
<span class="line" id="L126">        <span class="tok-kw">const</span> file_bytes = <span class="tok-kw">try</span> os.mmap(</span>
<span class="line" id="L127">            <span class="tok-null">null</span>,</span>
<span class="line" id="L128">            mem.alignForward(size, mem.page_size),</span>
<span class="line" id="L129">            os.PROT.READ,</span>
<span class="line" id="L130">            os.MAP.PRIVATE,</span>
<span class="line" id="L131">            fd,</span>
<span class="line" id="L132">            <span class="tok-number">0</span>,</span>
<span class="line" id="L133">        );</span>
<span class="line" id="L134">        <span class="tok-kw">defer</span> os.munmap(file_bytes);</span>
<span class="line" id="L135"></span>
<span class="line" id="L136">        <span class="tok-kw">const</span> eh = <span class="tok-builtin">@ptrCast</span>(*elf.Ehdr, file_bytes.ptr);</span>
<span class="line" id="L137">        <span class="tok-kw">if</span> (!mem.eql(<span class="tok-type">u8</span>, eh.e_ident[<span class="tok-number">0</span>..<span class="tok-number">4</span>], elf.MAGIC)) <span class="tok-kw">return</span> <span class="tok-kw">error</span>.NotElfFile;</span>
<span class="line" id="L138">        <span class="tok-kw">if</span> (eh.e_type != elf.ET.DYN) <span class="tok-kw">return</span> <span class="tok-kw">error</span>.NotDynamicLibrary;</span>
<span class="line" id="L139"></span>
<span class="line" id="L140">        <span class="tok-kw">const</span> elf_addr = <span class="tok-builtin">@ptrToInt</span>(file_bytes.ptr);</span>
<span class="line" id="L141"></span>
<span class="line" id="L142">        <span class="tok-comment">// Iterate over the program header entries to find out the</span>
</span>
<span class="line" id="L143">        <span class="tok-comment">// dynamic vector as well as the total size of the virtual memory.</span>
</span>
<span class="line" id="L144">        <span class="tok-kw">var</span> maybe_dynv: ?[*]<span class="tok-type">usize</span> = <span class="tok-null">null</span>;</span>
<span class="line" id="L145">        <span class="tok-kw">var</span> virt_addr_end: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L146">        {</span>
<span class="line" id="L147">            <span class="tok-kw">var</span> i: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L148">            <span class="tok-kw">var</span> ph_addr: <span class="tok-type">usize</span> = elf_addr + eh.e_phoff;</span>
<span class="line" id="L149">            <span class="tok-kw">while</span> (i &lt; eh.e_phnum) : ({</span>
<span class="line" id="L150">                i += <span class="tok-number">1</span>;</span>
<span class="line" id="L151">                ph_addr += eh.e_phentsize;</span>
<span class="line" id="L152">            }) {</span>
<span class="line" id="L153">                <span class="tok-kw">const</span> ph = <span class="tok-builtin">@intToPtr</span>(*elf.Phdr, ph_addr);</span>
<span class="line" id="L154">                <span class="tok-kw">switch</span> (ph.p_type) {</span>
<span class="line" id="L155">                    elf.PT_LOAD =&gt; virt_addr_end = max(virt_addr_end, ph.p_vaddr + ph.p_memsz),</span>
<span class="line" id="L156">                    elf.PT_DYNAMIC =&gt; maybe_dynv = <span class="tok-builtin">@intToPtr</span>([*]<span class="tok-type">usize</span>, elf_addr + ph.p_offset),</span>
<span class="line" id="L157">                    <span class="tok-kw">else</span> =&gt; {},</span>
<span class="line" id="L158">                }</span>
<span class="line" id="L159">            }</span>
<span class="line" id="L160">        }</span>
<span class="line" id="L161">        <span class="tok-kw">const</span> dynv = maybe_dynv <span class="tok-kw">orelse</span> <span class="tok-kw">return</span> <span class="tok-kw">error</span>.MissingDynamicLinkingInformation;</span>
<span class="line" id="L162"></span>
<span class="line" id="L163">        <span class="tok-comment">// Reserve the entire range (with no permissions) so that we can do MAP.FIXED below.</span>
</span>
<span class="line" id="L164">        <span class="tok-kw">const</span> all_loaded_mem = <span class="tok-kw">try</span> os.mmap(</span>
<span class="line" id="L165">            <span class="tok-null">null</span>,</span>
<span class="line" id="L166">            virt_addr_end,</span>
<span class="line" id="L167">            os.PROT.NONE,</span>
<span class="line" id="L168">            os.MAP.PRIVATE | os.MAP.ANONYMOUS,</span>
<span class="line" id="L169">            -<span class="tok-number">1</span>,</span>
<span class="line" id="L170">            <span class="tok-number">0</span>,</span>
<span class="line" id="L171">        );</span>
<span class="line" id="L172">        <span class="tok-kw">errdefer</span> os.munmap(all_loaded_mem);</span>
<span class="line" id="L173"></span>
<span class="line" id="L174">        <span class="tok-kw">const</span> base = <span class="tok-builtin">@ptrToInt</span>(all_loaded_mem.ptr);</span>
<span class="line" id="L175"></span>
<span class="line" id="L176">        <span class="tok-comment">// Now iterate again and actually load all the program sections.</span>
</span>
<span class="line" id="L177">        {</span>
<span class="line" id="L178">            <span class="tok-kw">var</span> i: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L179">            <span class="tok-kw">var</span> ph_addr: <span class="tok-type">usize</span> = elf_addr + eh.e_phoff;</span>
<span class="line" id="L180">            <span class="tok-kw">while</span> (i &lt; eh.e_phnum) : ({</span>
<span class="line" id="L181">                i += <span class="tok-number">1</span>;</span>
<span class="line" id="L182">                ph_addr += eh.e_phentsize;</span>
<span class="line" id="L183">            }) {</span>
<span class="line" id="L184">                <span class="tok-kw">const</span> ph = <span class="tok-builtin">@intToPtr</span>(*elf.Phdr, ph_addr);</span>
<span class="line" id="L185">                <span class="tok-kw">switch</span> (ph.p_type) {</span>
<span class="line" id="L186">                    elf.PT_LOAD =&gt; {</span>
<span class="line" id="L187">                        <span class="tok-comment">// The VirtAddr may not be page-aligned; in such case there will be</span>
</span>
<span class="line" id="L188">                        <span class="tok-comment">// extra nonsense mapped before/after the VirtAddr,MemSiz</span>
</span>
<span class="line" id="L189">                        <span class="tok-kw">const</span> aligned_addr = (base + ph.p_vaddr) &amp; ~(<span class="tok-builtin">@as</span>(<span class="tok-type">usize</span>, mem.page_size) - <span class="tok-number">1</span>);</span>
<span class="line" id="L190">                        <span class="tok-kw">const</span> extra_bytes = (base + ph.p_vaddr) - aligned_addr;</span>
<span class="line" id="L191">                        <span class="tok-kw">const</span> extended_memsz = mem.alignForward(ph.p_memsz + extra_bytes, mem.page_size);</span>
<span class="line" id="L192">                        <span class="tok-kw">const</span> ptr = <span class="tok-builtin">@intToPtr</span>([*]<span class="tok-kw">align</span>(mem.page_size) <span class="tok-type">u8</span>, aligned_addr);</span>
<span class="line" id="L193">                        <span class="tok-kw">const</span> prot = elfToMmapProt(ph.p_flags);</span>
<span class="line" id="L194">                        <span class="tok-kw">if</span> ((ph.p_flags &amp; elf.PF_W) == <span class="tok-number">0</span>) {</span>
<span class="line" id="L195">                            <span class="tok-comment">// If it does not need write access, it can be mapped from the fd.</span>
</span>
<span class="line" id="L196">                            _ = <span class="tok-kw">try</span> os.mmap(</span>
<span class="line" id="L197">                                ptr,</span>
<span class="line" id="L198">                                extended_memsz,</span>
<span class="line" id="L199">                                prot,</span>
<span class="line" id="L200">                                os.MAP.PRIVATE | os.MAP.FIXED,</span>
<span class="line" id="L201">                                fd,</span>
<span class="line" id="L202">                                ph.p_offset - extra_bytes,</span>
<span class="line" id="L203">                            );</span>
<span class="line" id="L204">                        } <span class="tok-kw">else</span> {</span>
<span class="line" id="L205">                            <span class="tok-kw">const</span> sect_mem = <span class="tok-kw">try</span> os.mmap(</span>
<span class="line" id="L206">                                ptr,</span>
<span class="line" id="L207">                                extended_memsz,</span>
<span class="line" id="L208">                                prot,</span>
<span class="line" id="L209">                                os.MAP.PRIVATE | os.MAP.FIXED | os.MAP.ANONYMOUS,</span>
<span class="line" id="L210">                                -<span class="tok-number">1</span>,</span>
<span class="line" id="L211">                                <span class="tok-number">0</span>,</span>
<span class="line" id="L212">                            );</span>
<span class="line" id="L213">                            mem.copy(<span class="tok-type">u8</span>, sect_mem, file_bytes[<span class="tok-number">0</span>..ph.p_filesz]);</span>
<span class="line" id="L214">                        }</span>
<span class="line" id="L215">                    },</span>
<span class="line" id="L216">                    <span class="tok-kw">else</span> =&gt; {},</span>
<span class="line" id="L217">                }</span>
<span class="line" id="L218">            }</span>
<span class="line" id="L219">        }</span>
<span class="line" id="L220"></span>
<span class="line" id="L221">        <span class="tok-kw">var</span> maybe_strings: ?[*:<span class="tok-number">0</span>]<span class="tok-type">u8</span> = <span class="tok-null">null</span>;</span>
<span class="line" id="L222">        <span class="tok-kw">var</span> maybe_syms: ?[*]elf.Sym = <span class="tok-null">null</span>;</span>
<span class="line" id="L223">        <span class="tok-kw">var</span> maybe_hashtab: ?[*]os.Elf_Symndx = <span class="tok-null">null</span>;</span>
<span class="line" id="L224">        <span class="tok-kw">var</span> maybe_versym: ?[*]<span class="tok-type">u16</span> = <span class="tok-null">null</span>;</span>
<span class="line" id="L225">        <span class="tok-kw">var</span> maybe_verdef: ?*elf.Verdef = <span class="tok-null">null</span>;</span>
<span class="line" id="L226"></span>
<span class="line" id="L227">        {</span>
<span class="line" id="L228">            <span class="tok-kw">var</span> i: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L229">            <span class="tok-kw">while</span> (dynv[i] != <span class="tok-number">0</span>) : (i += <span class="tok-number">2</span>) {</span>
<span class="line" id="L230">                <span class="tok-kw">const</span> p = base + dynv[i + <span class="tok-number">1</span>];</span>
<span class="line" id="L231">                <span class="tok-kw">switch</span> (dynv[i]) {</span>
<span class="line" id="L232">                    elf.DT_STRTAB =&gt; maybe_strings = <span class="tok-builtin">@intToPtr</span>([*:<span class="tok-number">0</span>]<span class="tok-type">u8</span>, p),</span>
<span class="line" id="L233">                    elf.DT_SYMTAB =&gt; maybe_syms = <span class="tok-builtin">@intToPtr</span>([*]elf.Sym, p),</span>
<span class="line" id="L234">                    elf.DT_HASH =&gt; maybe_hashtab = <span class="tok-builtin">@intToPtr</span>([*]os.Elf_Symndx, p),</span>
<span class="line" id="L235">                    elf.DT_VERSYM =&gt; maybe_versym = <span class="tok-builtin">@intToPtr</span>([*]<span class="tok-type">u16</span>, p),</span>
<span class="line" id="L236">                    elf.DT_VERDEF =&gt; maybe_verdef = <span class="tok-builtin">@intToPtr</span>(*elf.Verdef, p),</span>
<span class="line" id="L237">                    <span class="tok-kw">else</span> =&gt; {},</span>
<span class="line" id="L238">                }</span>
<span class="line" id="L239">            }</span>
<span class="line" id="L240">        }</span>
<span class="line" id="L241"></span>
<span class="line" id="L242">        <span class="tok-kw">return</span> ElfDynLib{</span>
<span class="line" id="L243">            .memory = all_loaded_mem,</span>
<span class="line" id="L244">            .strings = maybe_strings <span class="tok-kw">orelse</span> <span class="tok-kw">return</span> <span class="tok-kw">error</span>.ElfStringSectionNotFound,</span>
<span class="line" id="L245">            .syms = maybe_syms <span class="tok-kw">orelse</span> <span class="tok-kw">return</span> <span class="tok-kw">error</span>.ElfSymSectionNotFound,</span>
<span class="line" id="L246">            .hashtab = maybe_hashtab <span class="tok-kw">orelse</span> <span class="tok-kw">return</span> <span class="tok-kw">error</span>.ElfHashTableNotFound,</span>
<span class="line" id="L247">            .versym = maybe_versym,</span>
<span class="line" id="L248">            .verdef = maybe_verdef,</span>
<span class="line" id="L249">        };</span>
<span class="line" id="L250">    }</span>
<span class="line" id="L251"></span>
<span class="line" id="L252">    <span class="tok-comment">/// Trusts the file. Malicious file will be able to execute arbitrary code.</span></span>
<span class="line" id="L253">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">openZ</span>(path_c: [*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span>) !ElfDynLib {</span>
<span class="line" id="L254">        <span class="tok-kw">return</span> open(mem.sliceTo(path_c, <span class="tok-number">0</span>));</span>
<span class="line" id="L255">    }</span>
<span class="line" id="L256"></span>
<span class="line" id="L257">    <span class="tok-comment">/// Trusts the file</span></span>
<span class="line" id="L258">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">close</span>(self: *ElfDynLib) <span class="tok-type">void</span> {</span>
<span class="line" id="L259">        os.munmap(self.memory);</span>
<span class="line" id="L260">        self.* = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L261">    }</span>
<span class="line" id="L262"></span>
<span class="line" id="L263">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">lookup</span>(self: *ElfDynLib, <span class="tok-kw">comptime</span> T: <span class="tok-type">type</span>, name: [:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span>) ?T {</span>
<span class="line" id="L264">        <span class="tok-kw">if</span> (self.lookupAddress(<span class="tok-str">&quot;&quot;</span>, name)) |symbol| {</span>
<span class="line" id="L265">            <span class="tok-kw">return</span> <span class="tok-builtin">@intToPtr</span>(T, symbol);</span>
<span class="line" id="L266">        } <span class="tok-kw">else</span> {</span>
<span class="line" id="L267">            <span class="tok-kw">return</span> <span class="tok-null">null</span>;</span>
<span class="line" id="L268">        }</span>
<span class="line" id="L269">    }</span>
<span class="line" id="L270"></span>
<span class="line" id="L271">    <span class="tok-comment">/// Returns the address of the symbol</span></span>
<span class="line" id="L272">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">lookupAddress</span>(self: *<span class="tok-kw">const</span> ElfDynLib, vername: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, name: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) ?<span class="tok-type">usize</span> {</span>
<span class="line" id="L273">        <span class="tok-kw">const</span> maybe_versym = <span class="tok-kw">if</span> (self.verdef == <span class="tok-null">null</span>) <span class="tok-null">null</span> <span class="tok-kw">else</span> self.versym;</span>
<span class="line" id="L274"></span>
<span class="line" id="L275">        <span class="tok-kw">const</span> OK_TYPES = (<span class="tok-number">1</span> &lt;&lt; elf.STT_NOTYPE | <span class="tok-number">1</span> &lt;&lt; elf.STT_OBJECT | <span class="tok-number">1</span> &lt;&lt; elf.STT_FUNC | <span class="tok-number">1</span> &lt;&lt; elf.STT_COMMON);</span>
<span class="line" id="L276">        <span class="tok-kw">const</span> OK_BINDS = (<span class="tok-number">1</span> &lt;&lt; elf.STB_GLOBAL | <span class="tok-number">1</span> &lt;&lt; elf.STB_WEAK | <span class="tok-number">1</span> &lt;&lt; elf.STB_GNU_UNIQUE);</span>
<span class="line" id="L277"></span>
<span class="line" id="L278">        <span class="tok-kw">var</span> i: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L279">        <span class="tok-kw">while</span> (i &lt; self.hashtab[<span class="tok-number">1</span>]) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L280">            <span class="tok-kw">if</span> (<span class="tok-number">0</span> == (<span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">1</span>) &lt;&lt; <span class="tok-builtin">@intCast</span>(<span class="tok-type">u5</span>, self.syms[i].st_info &amp; <span class="tok-number">0xf</span>) &amp; OK_TYPES)) <span class="tok-kw">continue</span>;</span>
<span class="line" id="L281">            <span class="tok-kw">if</span> (<span class="tok-number">0</span> == (<span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">1</span>) &lt;&lt; <span class="tok-builtin">@intCast</span>(<span class="tok-type">u5</span>, self.syms[i].st_info &gt;&gt; <span class="tok-number">4</span>) &amp; OK_BINDS)) <span class="tok-kw">continue</span>;</span>
<span class="line" id="L282">            <span class="tok-kw">if</span> (<span class="tok-number">0</span> == self.syms[i].st_shndx) <span class="tok-kw">continue</span>;</span>
<span class="line" id="L283">            <span class="tok-kw">if</span> (!mem.eql(<span class="tok-type">u8</span>, name, mem.sliceTo(self.strings + self.syms[i].st_name, <span class="tok-number">0</span>))) <span class="tok-kw">continue</span>;</span>
<span class="line" id="L284">            <span class="tok-kw">if</span> (maybe_versym) |versym| {</span>
<span class="line" id="L285">                <span class="tok-kw">if</span> (!checkver(self.verdef.?, versym[i], vername, self.strings))</span>
<span class="line" id="L286">                    <span class="tok-kw">continue</span>;</span>
<span class="line" id="L287">            }</span>
<span class="line" id="L288">            <span class="tok-kw">return</span> <span class="tok-builtin">@ptrToInt</span>(self.memory.ptr) + self.syms[i].st_value;</span>
<span class="line" id="L289">        }</span>
<span class="line" id="L290"></span>
<span class="line" id="L291">        <span class="tok-kw">return</span> <span class="tok-null">null</span>;</span>
<span class="line" id="L292">    }</span>
<span class="line" id="L293"></span>
<span class="line" id="L294">    <span class="tok-kw">fn</span> <span class="tok-fn">elfToMmapProt</span>(elf_prot: <span class="tok-type">u64</span>) <span class="tok-type">u32</span> {</span>
<span class="line" id="L295">        <span class="tok-kw">var</span> result: <span class="tok-type">u32</span> = os.PROT.NONE;</span>
<span class="line" id="L296">        <span class="tok-kw">if</span> ((elf_prot &amp; elf.PF_R) != <span class="tok-number">0</span>) result |= os.PROT.READ;</span>
<span class="line" id="L297">        <span class="tok-kw">if</span> ((elf_prot &amp; elf.PF_W) != <span class="tok-number">0</span>) result |= os.PROT.WRITE;</span>
<span class="line" id="L298">        <span class="tok-kw">if</span> ((elf_prot &amp; elf.PF_X) != <span class="tok-number">0</span>) result |= os.PROT.EXEC;</span>
<span class="line" id="L299">        <span class="tok-kw">return</span> result;</span>
<span class="line" id="L300">    }</span>
<span class="line" id="L301">};</span>
<span class="line" id="L302"></span>
<span class="line" id="L303"><span class="tok-kw">fn</span> <span class="tok-fn">checkver</span>(def_arg: *elf.Verdef, vsym_arg: <span class="tok-type">i32</span>, vername: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, strings: [*:<span class="tok-number">0</span>]<span class="tok-type">u8</span>) <span class="tok-type">bool</span> {</span>
<span class="line" id="L304">    <span class="tok-kw">var</span> def = def_arg;</span>
<span class="line" id="L305">    <span class="tok-kw">const</span> vsym = <span class="tok-builtin">@bitCast</span>(<span class="tok-type">u32</span>, vsym_arg) &amp; <span class="tok-number">0x7fff</span>;</span>
<span class="line" id="L306">    <span class="tok-kw">while</span> (<span class="tok-null">true</span>) {</span>
<span class="line" id="L307">        <span class="tok-kw">if</span> (<span class="tok-number">0</span> == (def.vd_flags &amp; elf.VER_FLG_BASE) <span class="tok-kw">and</span> (def.vd_ndx &amp; <span class="tok-number">0x7fff</span>) == vsym)</span>
<span class="line" id="L308">            <span class="tok-kw">break</span>;</span>
<span class="line" id="L309">        <span class="tok-kw">if</span> (def.vd_next == <span class="tok-number">0</span>)</span>
<span class="line" id="L310">            <span class="tok-kw">return</span> <span class="tok-null">false</span>;</span>
<span class="line" id="L311">        def = <span class="tok-builtin">@intToPtr</span>(*elf.Verdef, <span class="tok-builtin">@ptrToInt</span>(def) + def.vd_next);</span>
<span class="line" id="L312">    }</span>
<span class="line" id="L313">    <span class="tok-kw">const</span> aux = <span class="tok-builtin">@intToPtr</span>(*elf.Verdaux, <span class="tok-builtin">@ptrToInt</span>(def) + def.vd_aux);</span>
<span class="line" id="L314">    <span class="tok-kw">return</span> mem.eql(<span class="tok-type">u8</span>, vername, mem.sliceTo(strings + aux.vda_name, <span class="tok-number">0</span>));</span>
<span class="line" id="L315">}</span>
<span class="line" id="L316"></span>
<span class="line" id="L317"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WindowsDynLib = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L318">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> Error = <span class="tok-kw">error</span>{FileNotFound};</span>
<span class="line" id="L319"></span>
<span class="line" id="L320">    dll: windows.HMODULE,</span>
<span class="line" id="L321"></span>
<span class="line" id="L322">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">open</span>(path: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) !WindowsDynLib {</span>
<span class="line" id="L323">        <span class="tok-kw">const</span> path_w = <span class="tok-kw">try</span> windows.sliceToPrefixedFileW(path);</span>
<span class="line" id="L324">        <span class="tok-kw">return</span> openW(path_w.span().ptr);</span>
<span class="line" id="L325">    }</span>
<span class="line" id="L326"></span>
<span class="line" id="L327">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">openZ</span>(path_c: [*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span>) !WindowsDynLib {</span>
<span class="line" id="L328">        <span class="tok-kw">const</span> path_w = <span class="tok-kw">try</span> windows.cStrToPrefixedFileW(path_c);</span>
<span class="line" id="L329">        <span class="tok-kw">return</span> openW(path_w.span().ptr);</span>
<span class="line" id="L330">    }</span>
<span class="line" id="L331"></span>
<span class="line" id="L332">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">openW</span>(path_w: [*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u16</span>) !WindowsDynLib {</span>
<span class="line" id="L333">        <span class="tok-kw">var</span> offset: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L334">        <span class="tok-kw">if</span> (path_w[<span class="tok-number">0</span>] == <span class="tok-str">'\\'</span> <span class="tok-kw">and</span> path_w[<span class="tok-number">1</span>] == <span class="tok-str">'?'</span> <span class="tok-kw">and</span> path_w[<span class="tok-number">2</span>] == <span class="tok-str">'?'</span> <span class="tok-kw">and</span> path_w[<span class="tok-number">3</span>] == <span class="tok-str">'\\'</span>) {</span>
<span class="line" id="L335">            <span class="tok-comment">// + 4 to skip over the \??\</span>
</span>
<span class="line" id="L336">            offset = <span class="tok-number">4</span>;</span>
<span class="line" id="L337">        }</span>
<span class="line" id="L338"></span>
<span class="line" id="L339">        <span class="tok-kw">return</span> WindowsDynLib{</span>
<span class="line" id="L340">            .dll = <span class="tok-kw">try</span> windows.LoadLibraryW(path_w + offset),</span>
<span class="line" id="L341">        };</span>
<span class="line" id="L342">    }</span>
<span class="line" id="L343"></span>
<span class="line" id="L344">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">close</span>(self: *WindowsDynLib) <span class="tok-type">void</span> {</span>
<span class="line" id="L345">        windows.FreeLibrary(self.dll);</span>
<span class="line" id="L346">        self.* = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L347">    }</span>
<span class="line" id="L348"></span>
<span class="line" id="L349">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">lookup</span>(self: *WindowsDynLib, <span class="tok-kw">comptime</span> T: <span class="tok-type">type</span>, name: [:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span>) ?T {</span>
<span class="line" id="L350">        <span class="tok-kw">if</span> (windows.kernel32.GetProcAddress(self.dll, name.ptr)) |addr| {</span>
<span class="line" id="L351">            <span class="tok-kw">return</span> <span class="tok-builtin">@ptrCast</span>(T, addr);</span>
<span class="line" id="L352">        } <span class="tok-kw">else</span> {</span>
<span class="line" id="L353">            <span class="tok-kw">return</span> <span class="tok-null">null</span>;</span>
<span class="line" id="L354">        }</span>
<span class="line" id="L355">    }</span>
<span class="line" id="L356">};</span>
<span class="line" id="L357"></span>
<span class="line" id="L358"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> DlDynlib = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L359">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> Error = <span class="tok-kw">error</span>{FileNotFound};</span>
<span class="line" id="L360"></span>
<span class="line" id="L361">    handle: *<span class="tok-type">anyopaque</span>,</span>
<span class="line" id="L362"></span>
<span class="line" id="L363">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">open</span>(path: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) !DlDynlib {</span>
<span class="line" id="L364">        <span class="tok-kw">const</span> path_c = <span class="tok-kw">try</span> os.toPosixPath(path);</span>
<span class="line" id="L365">        <span class="tok-kw">return</span> openZ(&amp;path_c);</span>
<span class="line" id="L366">    }</span>
<span class="line" id="L367"></span>
<span class="line" id="L368">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">openZ</span>(path_c: [*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span>) !DlDynlib {</span>
<span class="line" id="L369">        <span class="tok-kw">return</span> DlDynlib{</span>
<span class="line" id="L370">            .handle = system.dlopen(path_c, system.RTLD.LAZY) <span class="tok-kw">orelse</span> {</span>
<span class="line" id="L371">                <span class="tok-kw">return</span> <span class="tok-kw">error</span>.FileNotFound;</span>
<span class="line" id="L372">            },</span>
<span class="line" id="L373">        };</span>
<span class="line" id="L374">    }</span>
<span class="line" id="L375"></span>
<span class="line" id="L376">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">close</span>(self: *DlDynlib) <span class="tok-type">void</span> {</span>
<span class="line" id="L377">        _ = system.dlclose(self.handle);</span>
<span class="line" id="L378">        self.* = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L379">    }</span>
<span class="line" id="L380"></span>
<span class="line" id="L381">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">lookup</span>(self: *DlDynlib, <span class="tok-kw">comptime</span> T: <span class="tok-type">type</span>, name: [:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span>) ?T {</span>
<span class="line" id="L382">        <span class="tok-comment">// dlsym (and other dl-functions) secretly take shadow parameter - return address on stack</span>
</span>
<span class="line" id="L383">        <span class="tok-comment">// https://gcc.gnu.org/bugzilla/show_bug.cgi?id=66826</span>
</span>
<span class="line" id="L384">        <span class="tok-kw">if</span> (<span class="tok-builtin">@call</span>(.{ .modifier = .never_tail }, system.dlsym, .{ self.handle, name.ptr })) |symbol| {</span>
<span class="line" id="L385">            <span class="tok-kw">return</span> <span class="tok-builtin">@ptrCast</span>(T, symbol);</span>
<span class="line" id="L386">        } <span class="tok-kw">else</span> {</span>
<span class="line" id="L387">            <span class="tok-kw">return</span> <span class="tok-null">null</span>;</span>
<span class="line" id="L388">        }</span>
<span class="line" id="L389">    }</span>
<span class="line" id="L390">};</span>
<span class="line" id="L391"></span>
<span class="line" id="L392"><span class="tok-kw">test</span> <span class="tok-str">&quot;dynamic_library&quot;</span> {</span>
<span class="line" id="L393">    <span class="tok-kw">const</span> libname = <span class="tok-kw">switch</span> (builtin.os.tag) {</span>
<span class="line" id="L394">        .linux, .freebsd, .openbsd =&gt; <span class="tok-str">&quot;invalid_so.so&quot;</span>,</span>
<span class="line" id="L395">        .windows =&gt; <span class="tok-str">&quot;invalid_dll.dll&quot;</span>,</span>
<span class="line" id="L396">        .macos, .tvos, .watchos, .ios =&gt; <span class="tok-str">&quot;invalid_dylib.dylib&quot;</span>,</span>
<span class="line" id="L397">        <span class="tok-kw">else</span> =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SkipZigTest,</span>
<span class="line" id="L398">    };</span>
<span class="line" id="L399"></span>
<span class="line" id="L400">    _ = DynLib.open(libname) <span class="tok-kw">catch</span> |err| {</span>
<span class="line" id="L401">        <span class="tok-kw">try</span> testing.expect(err == <span class="tok-kw">error</span>.FileNotFound);</span>
<span class="line" id="L402">        <span class="tok-kw">return</span>;</span>
<span class="line" id="L403">    };</span>
<span class="line" id="L404">}</span>
<span class="line" id="L405"></span>
</code></pre></body>
</html>