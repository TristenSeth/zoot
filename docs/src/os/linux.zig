<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">    <title>os/linux.zig - source view</title>
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
<pre><code><span class="line" id="L1"><span class="tok-comment">//! This file provides the system interface functions for Linux matching those</span></span>
<span class="line" id="L2"><span class="tok-comment">//! that are provided by libc, whether or not libc is linked. The following</span></span>
<span class="line" id="L3"><span class="tok-comment">//! abstractions are made:</span></span>
<span class="line" id="L4"><span class="tok-comment">//! * Work around kernel bugs and limitations. For example, see sendmmsg.</span></span>
<span class="line" id="L5"><span class="tok-comment">//! * Implement all the syscalls in the same way that libc functions will</span></span>
<span class="line" id="L6"><span class="tok-comment">//!   provide `rename` when only the `renameat` syscall exists.</span></span>
<span class="line" id="L7"><span class="tok-comment">//! * Does not support POSIX thread cancellation.</span></span>
<span class="line" id="L8"><span class="tok-kw">const</span> std = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;../std.zig&quot;</span>);</span>
<span class="line" id="L9"><span class="tok-kw">const</span> builtin = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;builtin&quot;</span>);</span>
<span class="line" id="L10"><span class="tok-kw">const</span> assert = std.debug.assert;</span>
<span class="line" id="L11"><span class="tok-kw">const</span> maxInt = std.math.maxInt;</span>
<span class="line" id="L12"><span class="tok-kw">const</span> elf = std.elf;</span>
<span class="line" id="L13"><span class="tok-kw">const</span> vdso = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;linux/vdso.zig&quot;</span>);</span>
<span class="line" id="L14"><span class="tok-kw">const</span> dl = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;../dynamic_library.zig&quot;</span>);</span>
<span class="line" id="L15"><span class="tok-kw">const</span> native_arch = builtin.cpu.arch;</span>
<span class="line" id="L16"><span class="tok-kw">const</span> native_endian = native_arch.endian();</span>
<span class="line" id="L17"><span class="tok-kw">const</span> is_mips = native_arch.isMIPS();</span>
<span class="line" id="L18"><span class="tok-kw">const</span> is_ppc = native_arch.isPPC();</span>
<span class="line" id="L19"><span class="tok-kw">const</span> is_ppc64 = native_arch.isPPC64();</span>
<span class="line" id="L20"><span class="tok-kw">const</span> is_sparc = native_arch.isSPARC();</span>
<span class="line" id="L21"><span class="tok-kw">const</span> iovec = std.os.iovec;</span>
<span class="line" id="L22"><span class="tok-kw">const</span> iovec_const = std.os.iovec_const;</span>
<span class="line" id="L23"></span>
<span class="line" id="L24"><span class="tok-kw">test</span> {</span>
<span class="line" id="L25">    <span class="tok-kw">if</span> (builtin.os.tag == .linux) {</span>
<span class="line" id="L26">        _ = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;linux/test.zig&quot;</span>);</span>
<span class="line" id="L27">    }</span>
<span class="line" id="L28">}</span>
<span class="line" id="L29"></span>
<span class="line" id="L30"><span class="tok-kw">const</span> syscall_bits = <span class="tok-kw">switch</span> (native_arch) {</span>
<span class="line" id="L31">    .thumb =&gt; <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;linux/thumb.zig&quot;</span>),</span>
<span class="line" id="L32">    <span class="tok-kw">else</span> =&gt; arch_bits,</span>
<span class="line" id="L33">};</span>
<span class="line" id="L34"></span>
<span class="line" id="L35"><span class="tok-kw">const</span> arch_bits = <span class="tok-kw">switch</span> (native_arch) {</span>
<span class="line" id="L36">    .<span class="tok-type">i386</span> =&gt; <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;linux/i386.zig&quot;</span>),</span>
<span class="line" id="L37">    .x86_64 =&gt; <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;linux/x86_64.zig&quot;</span>),</span>
<span class="line" id="L38">    .aarch64 =&gt; <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;linux/arm64.zig&quot;</span>),</span>
<span class="line" id="L39">    .arm, .thumb =&gt; <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;linux/arm-eabi.zig&quot;</span>),</span>
<span class="line" id="L40">    .riscv64 =&gt; <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;linux/riscv64.zig&quot;</span>),</span>
<span class="line" id="L41">    .sparc64 =&gt; <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;linux/sparc64.zig&quot;</span>),</span>
<span class="line" id="L42">    .mips, .mipsel =&gt; <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;linux/mips.zig&quot;</span>),</span>
<span class="line" id="L43">    .powerpc =&gt; <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;linux/powerpc.zig&quot;</span>),</span>
<span class="line" id="L44">    .powerpc64, .powerpc64le =&gt; <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;linux/powerpc64.zig&quot;</span>),</span>
<span class="line" id="L45">    <span class="tok-kw">else</span> =&gt; <span class="tok-kw">struct</span> {},</span>
<span class="line" id="L46">};</span>
<span class="line" id="L47"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> syscall0 = syscall_bits.syscall0;</span>
<span class="line" id="L48"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> syscall1 = syscall_bits.syscall1;</span>
<span class="line" id="L49"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> syscall2 = syscall_bits.syscall2;</span>
<span class="line" id="L50"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> syscall3 = syscall_bits.syscall3;</span>
<span class="line" id="L51"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> syscall4 = syscall_bits.syscall4;</span>
<span class="line" id="L52"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> syscall5 = syscall_bits.syscall5;</span>
<span class="line" id="L53"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> syscall6 = syscall_bits.syscall6;</span>
<span class="line" id="L54"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> syscall7 = syscall_bits.syscall7;</span>
<span class="line" id="L55"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> restore = syscall_bits.restore;</span>
<span class="line" id="L56"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> restore_rt = syscall_bits.restore_rt;</span>
<span class="line" id="L57"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> socketcall = syscall_bits.socketcall;</span>
<span class="line" id="L58"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> syscall_pipe = syscall_bits.syscall_pipe;</span>
<span class="line" id="L59"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> syscall_fork = syscall_bits.syscall_fork;</span>
<span class="line" id="L60"></span>
<span class="line" id="L61"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> ARCH = arch_bits.ARCH;</span>
<span class="line" id="L62"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> Elf_Symndx = arch_bits.Elf_Symndx;</span>
<span class="line" id="L63"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> F = arch_bits.F;</span>
<span class="line" id="L64"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> Flock = arch_bits.Flock;</span>
<span class="line" id="L65"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> HWCAP = arch_bits.HWCAP;</span>
<span class="line" id="L66"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> LOCK = arch_bits.LOCK;</span>
<span class="line" id="L67"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> MMAP2_UNIT = arch_bits.MMAP2_UNIT;</span>
<span class="line" id="L68"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> REG = arch_bits.REG;</span>
<span class="line" id="L69"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SC = arch_bits.SC;</span>
<span class="line" id="L70"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> Stat = arch_bits.Stat;</span>
<span class="line" id="L71"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> VDSO = arch_bits.VDSO;</span>
<span class="line" id="L72"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> blkcnt_t = arch_bits.blkcnt_t;</span>
<span class="line" id="L73"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> blksize_t = arch_bits.blksize_t;</span>
<span class="line" id="L74"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> clone = arch_bits.clone;</span>
<span class="line" id="L75"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> dev_t = arch_bits.dev_t;</span>
<span class="line" id="L76"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> ino_t = arch_bits.ino_t;</span>
<span class="line" id="L77"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> mcontext_t = arch_bits.mcontext_t;</span>
<span class="line" id="L78"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> mode_t = arch_bits.mode_t;</span>
<span class="line" id="L79"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> msghdr = arch_bits.msghdr;</span>
<span class="line" id="L80"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> msghdr_const = arch_bits.msghdr_const;</span>
<span class="line" id="L81"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> nlink_t = arch_bits.nlink_t;</span>
<span class="line" id="L82"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> off_t = arch_bits.off_t;</span>
<span class="line" id="L83"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> time_t = arch_bits.time_t;</span>
<span class="line" id="L84"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> timeval = arch_bits.timeval;</span>
<span class="line" id="L85"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> timezone = arch_bits.timezone;</span>
<span class="line" id="L86"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> ucontext_t = arch_bits.ucontext_t;</span>
<span class="line" id="L87"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> user_desc = arch_bits.user_desc;</span>
<span class="line" id="L88"></span>
<span class="line" id="L89"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> tls = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;linux/tls.zig&quot;</span>);</span>
<span class="line" id="L90"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> pie = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;linux/start_pie.zig&quot;</span>);</span>
<span class="line" id="L91"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> BPF = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;linux/bpf.zig&quot;</span>);</span>
<span class="line" id="L92"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IOCTL = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;linux/ioctl.zig&quot;</span>);</span>
<span class="line" id="L93"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SECCOMP = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;linux/seccomp.zig&quot;</span>);</span>
<span class="line" id="L94"></span>
<span class="line" id="L95"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> syscalls = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;linux/syscalls.zig&quot;</span>);</span>
<span class="line" id="L96"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SYS = <span class="tok-kw">switch</span> (<span class="tok-builtin">@import</span>(<span class="tok-str">&quot;builtin&quot;</span>).cpu.arch) {</span>
<span class="line" id="L97">    .<span class="tok-type">i386</span> =&gt; syscalls.X86,</span>
<span class="line" id="L98">    .x86_64 =&gt; syscalls.X64,</span>
<span class="line" id="L99">    .aarch64 =&gt; syscalls.Arm64,</span>
<span class="line" id="L100">    .arm, .thumb =&gt; syscalls.Arm,</span>
<span class="line" id="L101">    .riscv64 =&gt; syscalls.RiscV64,</span>
<span class="line" id="L102">    .sparc64 =&gt; syscalls.Sparc64,</span>
<span class="line" id="L103">    .mips, .mipsel =&gt; syscalls.Mips,</span>
<span class="line" id="L104">    .powerpc =&gt; syscalls.PowerPC,</span>
<span class="line" id="L105">    .powerpc64, .powerpc64le =&gt; syscalls.PowerPC64,</span>
<span class="line" id="L106">    <span class="tok-kw">else</span> =&gt; <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;The Zig Standard Library is missing syscall definitions for the target CPU architecture&quot;</span>),</span>
<span class="line" id="L107">};</span>
<span class="line" id="L108"></span>
<span class="line" id="L109"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> MAP = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L110">    <span class="tok-kw">pub</span> <span class="tok-kw">usingnamespace</span> arch_bits.MAP;</span>
<span class="line" id="L111"></span>
<span class="line" id="L112">    <span class="tok-comment">/// Share changes</span></span>
<span class="line" id="L113">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> SHARED = <span class="tok-number">0x01</span>;</span>
<span class="line" id="L114">    <span class="tok-comment">/// Changes are private</span></span>
<span class="line" id="L115">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> PRIVATE = <span class="tok-number">0x02</span>;</span>
<span class="line" id="L116">    <span class="tok-comment">/// share + validate extension flags</span></span>
<span class="line" id="L117">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> SHARED_VALIDATE = <span class="tok-number">0x03</span>;</span>
<span class="line" id="L118">    <span class="tok-comment">/// Mask for type of mapping</span></span>
<span class="line" id="L119">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> TYPE = <span class="tok-number">0x0f</span>;</span>
<span class="line" id="L120">    <span class="tok-comment">/// Interpret addr exactly</span></span>
<span class="line" id="L121">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> FIXED = <span class="tok-number">0x10</span>;</span>
<span class="line" id="L122">    <span class="tok-comment">/// don't use a file</span></span>
<span class="line" id="L123">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> ANONYMOUS = <span class="tok-kw">if</span> (is_mips) <span class="tok-number">0x800</span> <span class="tok-kw">else</span> <span class="tok-number">0x20</span>;</span>
<span class="line" id="L124">    <span class="tok-comment">// MAP_ 0x0100 - 0x4000 flags are per architecture</span>
</span>
<span class="line" id="L125">    <span class="tok-comment">/// populate (prefault) pagetables</span></span>
<span class="line" id="L126">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> POPULATE = <span class="tok-kw">if</span> (is_mips) <span class="tok-number">0x10000</span> <span class="tok-kw">else</span> <span class="tok-number">0x8000</span>;</span>
<span class="line" id="L127">    <span class="tok-comment">/// do not block on IO</span></span>
<span class="line" id="L128">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> NONBLOCK = <span class="tok-kw">if</span> (is_mips) <span class="tok-number">0x20000</span> <span class="tok-kw">else</span> <span class="tok-number">0x10000</span>;</span>
<span class="line" id="L129">    <span class="tok-comment">/// give out an address that is best suited for process/thread stacks</span></span>
<span class="line" id="L130">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> STACK = <span class="tok-kw">if</span> (is_mips) <span class="tok-number">0x40000</span> <span class="tok-kw">else</span> <span class="tok-number">0x20000</span>;</span>
<span class="line" id="L131">    <span class="tok-comment">/// create a huge page mapping</span></span>
<span class="line" id="L132">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> HUGETLB = <span class="tok-kw">if</span> (is_mips) <span class="tok-number">0x80000</span> <span class="tok-kw">else</span> <span class="tok-number">0x40000</span>;</span>
<span class="line" id="L133">    <span class="tok-comment">/// perform synchronous page faults for the mapping</span></span>
<span class="line" id="L134">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> SYNC = <span class="tok-number">0x80000</span>;</span>
<span class="line" id="L135">    <span class="tok-comment">/// MAP_FIXED which doesn't unmap underlying mapping</span></span>
<span class="line" id="L136">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> FIXED_NOREPLACE = <span class="tok-number">0x100000</span>;</span>
<span class="line" id="L137">    <span class="tok-comment">/// For anonymous mmap, memory could be uninitialized</span></span>
<span class="line" id="L138">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> UNINITIALIZED = <span class="tok-number">0x4000000</span>;</span>
<span class="line" id="L139">};</span>
<span class="line" id="L140"></span>
<span class="line" id="L141"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> O = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L142">    <span class="tok-kw">pub</span> <span class="tok-kw">usingnamespace</span> arch_bits.O;</span>
<span class="line" id="L143"></span>
<span class="line" id="L144">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> RDONLY = <span class="tok-number">0o0</span>;</span>
<span class="line" id="L145">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> WRONLY = <span class="tok-number">0o1</span>;</span>
<span class="line" id="L146">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> RDWR = <span class="tok-number">0o2</span>;</span>
<span class="line" id="L147">};</span>
<span class="line" id="L148"></span>
<span class="line" id="L149"><span class="tok-kw">pub</span> <span class="tok-kw">usingnamespace</span> <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;linux/io_uring.zig&quot;</span>);</span>
<span class="line" id="L150"></span>
<span class="line" id="L151"><span class="tok-comment">/// Set by startup code, used by `getauxval`.</span></span>
<span class="line" id="L152"><span class="tok-kw">pub</span> <span class="tok-kw">var</span> elf_aux_maybe: ?[*]std.elf.Auxv = <span class="tok-null">null</span>;</span>
<span class="line" id="L153"></span>
<span class="line" id="L154"><span class="tok-comment">/// See `std.elf` for the constants.</span></span>
<span class="line" id="L155"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">getauxval</span>(index: <span class="tok-type">usize</span>) <span class="tok-type">usize</span> {</span>
<span class="line" id="L156">    <span class="tok-kw">const</span> auxv = elf_aux_maybe <span class="tok-kw">orelse</span> <span class="tok-kw">return</span> <span class="tok-number">0</span>;</span>
<span class="line" id="L157">    <span class="tok-kw">var</span> i: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L158">    <span class="tok-kw">while</span> (auxv[i].a_type != std.elf.AT_NULL) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L159">        <span class="tok-kw">if</span> (auxv[i].a_type == index)</span>
<span class="line" id="L160">            <span class="tok-kw">return</span> auxv[i].a_un.a_val;</span>
<span class="line" id="L161">    }</span>
<span class="line" id="L162">    <span class="tok-kw">return</span> <span class="tok-number">0</span>;</span>
<span class="line" id="L163">}</span>
<span class="line" id="L164"></span>
<span class="line" id="L165"><span class="tok-comment">// Some architectures (and some syscalls) require 64bit parameters to be passed</span>
</span>
<span class="line" id="L166"><span class="tok-comment">// in a even-aligned register pair.</span>
</span>
<span class="line" id="L167"><span class="tok-kw">const</span> require_aligned_register_pair =</span>
<span class="line" id="L168">    builtin.cpu.arch.isPPC() <span class="tok-kw">or</span></span>
<span class="line" id="L169">    builtin.cpu.arch.isMIPS() <span class="tok-kw">or</span></span>
<span class="line" id="L170">    builtin.cpu.arch.isARM() <span class="tok-kw">or</span></span>
<span class="line" id="L171">    builtin.cpu.arch.isThumb();</span>
<span class="line" id="L172"></span>
<span class="line" id="L173"><span class="tok-comment">// Split a 64bit value into a {LSB,MSB} pair.</span>
</span>
<span class="line" id="L174"><span class="tok-comment">// The LE/BE variants specify the endianness to assume.</span>
</span>
<span class="line" id="L175"><span class="tok-kw">fn</span> <span class="tok-fn">splitValueLE64</span>(val: <span class="tok-type">i64</span>) [<span class="tok-number">2</span>]<span class="tok-type">u32</span> {</span>
<span class="line" id="L176">    <span class="tok-kw">const</span> u = <span class="tok-builtin">@bitCast</span>(<span class="tok-type">u64</span>, val);</span>
<span class="line" id="L177">    <span class="tok-kw">return</span> [<span class="tok-number">2</span>]<span class="tok-type">u32</span>{</span>
<span class="line" id="L178">        <span class="tok-builtin">@truncate</span>(<span class="tok-type">u32</span>, u),</span>
<span class="line" id="L179">        <span class="tok-builtin">@truncate</span>(<span class="tok-type">u32</span>, u &gt;&gt; <span class="tok-number">32</span>),</span>
<span class="line" id="L180">    };</span>
<span class="line" id="L181">}</span>
<span class="line" id="L182"><span class="tok-kw">fn</span> <span class="tok-fn">splitValueBE64</span>(val: <span class="tok-type">i64</span>) [<span class="tok-number">2</span>]<span class="tok-type">u32</span> {</span>
<span class="line" id="L183">    <span class="tok-kw">const</span> u = <span class="tok-builtin">@bitCast</span>(<span class="tok-type">u64</span>, val);</span>
<span class="line" id="L184">    <span class="tok-kw">return</span> [<span class="tok-number">2</span>]<span class="tok-type">u32</span>{</span>
<span class="line" id="L185">        <span class="tok-builtin">@truncate</span>(<span class="tok-type">u32</span>, u &gt;&gt; <span class="tok-number">32</span>),</span>
<span class="line" id="L186">        <span class="tok-builtin">@truncate</span>(<span class="tok-type">u32</span>, u),</span>
<span class="line" id="L187">    };</span>
<span class="line" id="L188">}</span>
<span class="line" id="L189"><span class="tok-kw">fn</span> <span class="tok-fn">splitValue64</span>(val: <span class="tok-type">i64</span>) [<span class="tok-number">2</span>]<span class="tok-type">u32</span> {</span>
<span class="line" id="L190">    <span class="tok-kw">const</span> u = <span class="tok-builtin">@bitCast</span>(<span class="tok-type">u64</span>, val);</span>
<span class="line" id="L191">    <span class="tok-kw">switch</span> (native_endian) {</span>
<span class="line" id="L192">        .Little =&gt; <span class="tok-kw">return</span> [<span class="tok-number">2</span>]<span class="tok-type">u32</span>{</span>
<span class="line" id="L193">            <span class="tok-builtin">@truncate</span>(<span class="tok-type">u32</span>, u),</span>
<span class="line" id="L194">            <span class="tok-builtin">@truncate</span>(<span class="tok-type">u32</span>, u &gt;&gt; <span class="tok-number">32</span>),</span>
<span class="line" id="L195">        },</span>
<span class="line" id="L196">        .Big =&gt; <span class="tok-kw">return</span> [<span class="tok-number">2</span>]<span class="tok-type">u32</span>{</span>
<span class="line" id="L197">            <span class="tok-builtin">@truncate</span>(<span class="tok-type">u32</span>, u &gt;&gt; <span class="tok-number">32</span>),</span>
<span class="line" id="L198">            <span class="tok-builtin">@truncate</span>(<span class="tok-type">u32</span>, u),</span>
<span class="line" id="L199">        },</span>
<span class="line" id="L200">    }</span>
<span class="line" id="L201">}</span>
<span class="line" id="L202"></span>
<span class="line" id="L203"><span class="tok-comment">/// Get the errno from a syscall return value, or 0 for no error.</span></span>
<span class="line" id="L204"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">getErrno</span>(r: <span class="tok-type">usize</span>) E {</span>
<span class="line" id="L205">    <span class="tok-kw">const</span> signed_r = <span class="tok-builtin">@bitCast</span>(<span class="tok-type">isize</span>, r);</span>
<span class="line" id="L206">    <span class="tok-kw">const</span> int = <span class="tok-kw">if</span> (signed_r &gt; -<span class="tok-number">4096</span> <span class="tok-kw">and</span> signed_r &lt; <span class="tok-number">0</span>) -signed_r <span class="tok-kw">else</span> <span class="tok-number">0</span>;</span>
<span class="line" id="L207">    <span class="tok-kw">return</span> <span class="tok-builtin">@intToEnum</span>(E, int);</span>
<span class="line" id="L208">}</span>
<span class="line" id="L209"></span>
<span class="line" id="L210"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">dup</span>(old: <span class="tok-type">i32</span>) <span class="tok-type">usize</span> {</span>
<span class="line" id="L211">    <span class="tok-kw">return</span> syscall1(.dup, <span class="tok-builtin">@bitCast</span>(<span class="tok-type">usize</span>, <span class="tok-builtin">@as</span>(<span class="tok-type">isize</span>, old)));</span>
<span class="line" id="L212">}</span>
<span class="line" id="L213"></span>
<span class="line" id="L214"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">dup2</span>(old: <span class="tok-type">i32</span>, new: <span class="tok-type">i32</span>) <span class="tok-type">usize</span> {</span>
<span class="line" id="L215">    <span class="tok-kw">if</span> (<span class="tok-builtin">@hasField</span>(SYS, <span class="tok-str">&quot;dup2&quot;</span>)) {</span>
<span class="line" id="L216">        <span class="tok-kw">return</span> syscall2(.dup2, <span class="tok-builtin">@bitCast</span>(<span class="tok-type">usize</span>, <span class="tok-builtin">@as</span>(<span class="tok-type">isize</span>, old)), <span class="tok-builtin">@bitCast</span>(<span class="tok-type">usize</span>, <span class="tok-builtin">@as</span>(<span class="tok-type">isize</span>, new)));</span>
<span class="line" id="L217">    } <span class="tok-kw">else</span> {</span>
<span class="line" id="L218">        <span class="tok-kw">if</span> (old == new) {</span>
<span class="line" id="L219">            <span class="tok-kw">if</span> (std.debug.runtime_safety) {</span>
<span class="line" id="L220">                <span class="tok-kw">const</span> rc = syscall2(.fcntl, <span class="tok-builtin">@bitCast</span>(<span class="tok-type">usize</span>, <span class="tok-builtin">@as</span>(<span class="tok-type">isize</span>, old)), F.GETFD);</span>
<span class="line" id="L221">                <span class="tok-kw">if</span> (<span class="tok-builtin">@bitCast</span>(<span class="tok-type">isize</span>, rc) &lt; <span class="tok-number">0</span>) <span class="tok-kw">return</span> rc;</span>
<span class="line" id="L222">            }</span>
<span class="line" id="L223">            <span class="tok-kw">return</span> <span class="tok-builtin">@intCast</span>(<span class="tok-type">usize</span>, old);</span>
<span class="line" id="L224">        } <span class="tok-kw">else</span> {</span>
<span class="line" id="L225">            <span class="tok-kw">return</span> syscall3(.dup3, <span class="tok-builtin">@bitCast</span>(<span class="tok-type">usize</span>, <span class="tok-builtin">@as</span>(<span class="tok-type">isize</span>, old)), <span class="tok-builtin">@bitCast</span>(<span class="tok-type">usize</span>, <span class="tok-builtin">@as</span>(<span class="tok-type">isize</span>, new)), <span class="tok-number">0</span>);</span>
<span class="line" id="L226">        }</span>
<span class="line" id="L227">    }</span>
<span class="line" id="L228">}</span>
<span class="line" id="L229"></span>
<span class="line" id="L230"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">dup3</span>(old: <span class="tok-type">i32</span>, new: <span class="tok-type">i32</span>, flags: <span class="tok-type">u32</span>) <span class="tok-type">usize</span> {</span>
<span class="line" id="L231">    <span class="tok-kw">return</span> syscall3(.dup3, <span class="tok-builtin">@bitCast</span>(<span class="tok-type">usize</span>, <span class="tok-builtin">@as</span>(<span class="tok-type">isize</span>, old)), <span class="tok-builtin">@bitCast</span>(<span class="tok-type">usize</span>, <span class="tok-builtin">@as</span>(<span class="tok-type">isize</span>, new)), flags);</span>
<span class="line" id="L232">}</span>
<span class="line" id="L233"></span>
<span class="line" id="L234"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">chdir</span>(path: [*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span>) <span class="tok-type">usize</span> {</span>
<span class="line" id="L235">    <span class="tok-kw">return</span> syscall1(.chdir, <span class="tok-builtin">@ptrToInt</span>(path));</span>
<span class="line" id="L236">}</span>
<span class="line" id="L237"></span>
<span class="line" id="L238"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">fchdir</span>(fd: fd_t) <span class="tok-type">usize</span> {</span>
<span class="line" id="L239">    <span class="tok-kw">return</span> syscall1(.fchdir, <span class="tok-builtin">@bitCast</span>(<span class="tok-type">usize</span>, <span class="tok-builtin">@as</span>(<span class="tok-type">isize</span>, fd)));</span>
<span class="line" id="L240">}</span>
<span class="line" id="L241"></span>
<span class="line" id="L242"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">chroot</span>(path: [*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span>) <span class="tok-type">usize</span> {</span>
<span class="line" id="L243">    <span class="tok-kw">return</span> syscall1(.chroot, <span class="tok-builtin">@ptrToInt</span>(path));</span>
<span class="line" id="L244">}</span>
<span class="line" id="L245"></span>
<span class="line" id="L246"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">execve</span>(path: [*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span>, argv: [*:<span class="tok-null">null</span>]<span class="tok-kw">const</span> ?[*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span>, envp: [*:<span class="tok-null">null</span>]<span class="tok-kw">const</span> ?[*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span>) <span class="tok-type">usize</span> {</span>
<span class="line" id="L247">    <span class="tok-kw">return</span> syscall3(.execve, <span class="tok-builtin">@ptrToInt</span>(path), <span class="tok-builtin">@ptrToInt</span>(argv), <span class="tok-builtin">@ptrToInt</span>(envp));</span>
<span class="line" id="L248">}</span>
<span class="line" id="L249"></span>
<span class="line" id="L250"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">fork</span>() <span class="tok-type">usize</span> {</span>
<span class="line" id="L251">    <span class="tok-kw">if</span> (<span class="tok-kw">comptime</span> native_arch.isSPARC()) {</span>
<span class="line" id="L252">        <span class="tok-kw">return</span> syscall_fork();</span>
<span class="line" id="L253">    } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (<span class="tok-builtin">@hasField</span>(SYS, <span class="tok-str">&quot;fork&quot;</span>)) {</span>
<span class="line" id="L254">        <span class="tok-kw">return</span> syscall0(.fork);</span>
<span class="line" id="L255">    } <span class="tok-kw">else</span> {</span>
<span class="line" id="L256">        <span class="tok-kw">return</span> syscall2(.clone, SIG.CHLD, <span class="tok-number">0</span>);</span>
<span class="line" id="L257">    }</span>
<span class="line" id="L258">}</span>
<span class="line" id="L259"></span>
<span class="line" id="L260"><span class="tok-comment">/// This must be inline, and inline call the syscall function, because if the</span></span>
<span class="line" id="L261"><span class="tok-comment">/// child does a return it will clobber the parent's stack.</span></span>
<span class="line" id="L262"><span class="tok-comment">/// It is advised to avoid this function and use clone instead, because</span></span>
<span class="line" id="L263"><span class="tok-comment">/// the compiler is not aware of how vfork affects control flow and you may</span></span>
<span class="line" id="L264"><span class="tok-comment">/// see different results in optimized builds.</span></span>
<span class="line" id="L265"><span class="tok-kw">pub</span> <span class="tok-kw">inline</span> <span class="tok-kw">fn</span> <span class="tok-fn">vfork</span>() <span class="tok-type">usize</span> {</span>
<span class="line" id="L266">    <span class="tok-kw">return</span> <span class="tok-builtin">@call</span>(.{ .modifier = .always_inline }, syscall0, .{.vfork});</span>
<span class="line" id="L267">}</span>
<span class="line" id="L268"></span>
<span class="line" id="L269"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">futimens</span>(fd: <span class="tok-type">i32</span>, times: *<span class="tok-kw">const</span> [<span class="tok-number">2</span>]timespec) <span class="tok-type">usize</span> {</span>
<span class="line" id="L270">    <span class="tok-kw">return</span> utimensat(fd, <span class="tok-null">null</span>, times, <span class="tok-number">0</span>);</span>
<span class="line" id="L271">}</span>
<span class="line" id="L272"></span>
<span class="line" id="L273"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">utimensat</span>(dirfd: <span class="tok-type">i32</span>, path: ?[*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span>, times: *<span class="tok-kw">const</span> [<span class="tok-number">2</span>]timespec, flags: <span class="tok-type">u32</span>) <span class="tok-type">usize</span> {</span>
<span class="line" id="L274">    <span class="tok-kw">return</span> syscall4(.utimensat, <span class="tok-builtin">@bitCast</span>(<span class="tok-type">usize</span>, <span class="tok-builtin">@as</span>(<span class="tok-type">isize</span>, dirfd)), <span class="tok-builtin">@ptrToInt</span>(path), <span class="tok-builtin">@ptrToInt</span>(times), flags);</span>
<span class="line" id="L275">}</span>
<span class="line" id="L276"></span>
<span class="line" id="L277"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">fallocate</span>(fd: <span class="tok-type">i32</span>, mode: <span class="tok-type">i32</span>, offset: <span class="tok-type">i64</span>, length: <span class="tok-type">i64</span>) <span class="tok-type">usize</span> {</span>
<span class="line" id="L278">    <span class="tok-kw">if</span> (usize_bits &lt; <span class="tok-number">64</span>) {</span>
<span class="line" id="L279">        <span class="tok-kw">const</span> offset_halves = splitValue64(offset);</span>
<span class="line" id="L280">        <span class="tok-kw">const</span> length_halves = splitValue64(length);</span>
<span class="line" id="L281">        <span class="tok-kw">return</span> syscall6(</span>
<span class="line" id="L282">            .fallocate,</span>
<span class="line" id="L283">            <span class="tok-builtin">@bitCast</span>(<span class="tok-type">usize</span>, <span class="tok-builtin">@as</span>(<span class="tok-type">isize</span>, fd)),</span>
<span class="line" id="L284">            <span class="tok-builtin">@bitCast</span>(<span class="tok-type">usize</span>, <span class="tok-builtin">@as</span>(<span class="tok-type">isize</span>, mode)),</span>
<span class="line" id="L285">            offset_halves[<span class="tok-number">0</span>],</span>
<span class="line" id="L286">            offset_halves[<span class="tok-number">1</span>],</span>
<span class="line" id="L287">            length_halves[<span class="tok-number">0</span>],</span>
<span class="line" id="L288">            length_halves[<span class="tok-number">1</span>],</span>
<span class="line" id="L289">        );</span>
<span class="line" id="L290">    } <span class="tok-kw">else</span> {</span>
<span class="line" id="L291">        <span class="tok-kw">return</span> syscall4(</span>
<span class="line" id="L292">            .fallocate,</span>
<span class="line" id="L293">            <span class="tok-builtin">@bitCast</span>(<span class="tok-type">usize</span>, <span class="tok-builtin">@as</span>(<span class="tok-type">isize</span>, fd)),</span>
<span class="line" id="L294">            <span class="tok-builtin">@bitCast</span>(<span class="tok-type">usize</span>, <span class="tok-builtin">@as</span>(<span class="tok-type">isize</span>, mode)),</span>
<span class="line" id="L295">            <span class="tok-builtin">@bitCast</span>(<span class="tok-type">u64</span>, offset),</span>
<span class="line" id="L296">            <span class="tok-builtin">@bitCast</span>(<span class="tok-type">u64</span>, length),</span>
<span class="line" id="L297">        );</span>
<span class="line" id="L298">    }</span>
<span class="line" id="L299">}</span>
<span class="line" id="L300"></span>
<span class="line" id="L301"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">futex_wait</span>(uaddr: *<span class="tok-kw">const</span> <span class="tok-type">i32</span>, futex_op: <span class="tok-type">u32</span>, val: <span class="tok-type">i32</span>, timeout: ?*<span class="tok-kw">const</span> timespec) <span class="tok-type">usize</span> {</span>
<span class="line" id="L302">    <span class="tok-kw">return</span> syscall4(.futex, <span class="tok-builtin">@ptrToInt</span>(uaddr), futex_op, <span class="tok-builtin">@bitCast</span>(<span class="tok-type">u32</span>, val), <span class="tok-builtin">@ptrToInt</span>(timeout));</span>
<span class="line" id="L303">}</span>
<span class="line" id="L304"></span>
<span class="line" id="L305"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">futex_wake</span>(uaddr: *<span class="tok-kw">const</span> <span class="tok-type">i32</span>, futex_op: <span class="tok-type">u32</span>, val: <span class="tok-type">i32</span>) <span class="tok-type">usize</span> {</span>
<span class="line" id="L306">    <span class="tok-kw">return</span> syscall3(.futex, <span class="tok-builtin">@ptrToInt</span>(uaddr), futex_op, <span class="tok-builtin">@bitCast</span>(<span class="tok-type">u32</span>, val));</span>
<span class="line" id="L307">}</span>
<span class="line" id="L308"></span>
<span class="line" id="L309"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">getcwd</span>(buf: [*]<span class="tok-type">u8</span>, size: <span class="tok-type">usize</span>) <span class="tok-type">usize</span> {</span>
<span class="line" id="L310">    <span class="tok-kw">return</span> syscall2(.getcwd, <span class="tok-builtin">@ptrToInt</span>(buf), size);</span>
<span class="line" id="L311">}</span>
<span class="line" id="L312"></span>
<span class="line" id="L313"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">getdents</span>(fd: <span class="tok-type">i32</span>, dirp: [*]<span class="tok-type">u8</span>, len: <span class="tok-type">usize</span>) <span class="tok-type">usize</span> {</span>
<span class="line" id="L314">    <span class="tok-kw">return</span> syscall3(</span>
<span class="line" id="L315">        .getdents,</span>
<span class="line" id="L316">        <span class="tok-builtin">@bitCast</span>(<span class="tok-type">usize</span>, <span class="tok-builtin">@as</span>(<span class="tok-type">isize</span>, fd)),</span>
<span class="line" id="L317">        <span class="tok-builtin">@ptrToInt</span>(dirp),</span>
<span class="line" id="L318">        std.math.min(len, maxInt(<span class="tok-type">c_int</span>)),</span>
<span class="line" id="L319">    );</span>
<span class="line" id="L320">}</span>
<span class="line" id="L321"></span>
<span class="line" id="L322"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">getdents64</span>(fd: <span class="tok-type">i32</span>, dirp: [*]<span class="tok-type">u8</span>, len: <span class="tok-type">usize</span>) <span class="tok-type">usize</span> {</span>
<span class="line" id="L323">    <span class="tok-kw">return</span> syscall3(</span>
<span class="line" id="L324">        .getdents64,</span>
<span class="line" id="L325">        <span class="tok-builtin">@bitCast</span>(<span class="tok-type">usize</span>, <span class="tok-builtin">@as</span>(<span class="tok-type">isize</span>, fd)),</span>
<span class="line" id="L326">        <span class="tok-builtin">@ptrToInt</span>(dirp),</span>
<span class="line" id="L327">        std.math.min(len, maxInt(<span class="tok-type">c_int</span>)),</span>
<span class="line" id="L328">    );</span>
<span class="line" id="L329">}</span>
<span class="line" id="L330"></span>
<span class="line" id="L331"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">inotify_init1</span>(flags: <span class="tok-type">u32</span>) <span class="tok-type">usize</span> {</span>
<span class="line" id="L332">    <span class="tok-kw">return</span> syscall1(.inotify_init1, flags);</span>
<span class="line" id="L333">}</span>
<span class="line" id="L334"></span>
<span class="line" id="L335"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">inotify_add_watch</span>(fd: <span class="tok-type">i32</span>, pathname: [*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span>, mask: <span class="tok-type">u32</span>) <span class="tok-type">usize</span> {</span>
<span class="line" id="L336">    <span class="tok-kw">return</span> syscall3(.inotify_add_watch, <span class="tok-builtin">@bitCast</span>(<span class="tok-type">usize</span>, <span class="tok-builtin">@as</span>(<span class="tok-type">isize</span>, fd)), <span class="tok-builtin">@ptrToInt</span>(pathname), mask);</span>
<span class="line" id="L337">}</span>
<span class="line" id="L338"></span>
<span class="line" id="L339"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">inotify_rm_watch</span>(fd: <span class="tok-type">i32</span>, wd: <span class="tok-type">i32</span>) <span class="tok-type">usize</span> {</span>
<span class="line" id="L340">    <span class="tok-kw">return</span> syscall2(.inotify_rm_watch, <span class="tok-builtin">@bitCast</span>(<span class="tok-type">usize</span>, <span class="tok-builtin">@as</span>(<span class="tok-type">isize</span>, fd)), <span class="tok-builtin">@bitCast</span>(<span class="tok-type">usize</span>, <span class="tok-builtin">@as</span>(<span class="tok-type">isize</span>, wd)));</span>
<span class="line" id="L341">}</span>
<span class="line" id="L342"></span>
<span class="line" id="L343"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">readlink</span>(<span class="tok-kw">noalias</span> path: [*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span>, <span class="tok-kw">noalias</span> buf_ptr: [*]<span class="tok-type">u8</span>, buf_len: <span class="tok-type">usize</span>) <span class="tok-type">usize</span> {</span>
<span class="line" id="L344">    <span class="tok-kw">if</span> (<span class="tok-builtin">@hasField</span>(SYS, <span class="tok-str">&quot;readlink&quot;</span>)) {</span>
<span class="line" id="L345">        <span class="tok-kw">return</span> syscall3(.readlink, <span class="tok-builtin">@ptrToInt</span>(path), <span class="tok-builtin">@ptrToInt</span>(buf_ptr), buf_len);</span>
<span class="line" id="L346">    } <span class="tok-kw">else</span> {</span>
<span class="line" id="L347">        <span class="tok-kw">return</span> syscall4(.readlinkat, <span class="tok-builtin">@bitCast</span>(<span class="tok-type">usize</span>, <span class="tok-builtin">@as</span>(<span class="tok-type">isize</span>, AT.FDCWD)), <span class="tok-builtin">@ptrToInt</span>(path), <span class="tok-builtin">@ptrToInt</span>(buf_ptr), buf_len);</span>
<span class="line" id="L348">    }</span>
<span class="line" id="L349">}</span>
<span class="line" id="L350"></span>
<span class="line" id="L351"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">readlinkat</span>(dirfd: <span class="tok-type">i32</span>, <span class="tok-kw">noalias</span> path: [*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span>, <span class="tok-kw">noalias</span> buf_ptr: [*]<span class="tok-type">u8</span>, buf_len: <span class="tok-type">usize</span>) <span class="tok-type">usize</span> {</span>
<span class="line" id="L352">    <span class="tok-kw">return</span> syscall4(.readlinkat, <span class="tok-builtin">@bitCast</span>(<span class="tok-type">usize</span>, <span class="tok-builtin">@as</span>(<span class="tok-type">isize</span>, dirfd)), <span class="tok-builtin">@ptrToInt</span>(path), <span class="tok-builtin">@ptrToInt</span>(buf_ptr), buf_len);</span>
<span class="line" id="L353">}</span>
<span class="line" id="L354"></span>
<span class="line" id="L355"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">mkdir</span>(path: [*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span>, mode: <span class="tok-type">u32</span>) <span class="tok-type">usize</span> {</span>
<span class="line" id="L356">    <span class="tok-kw">if</span> (<span class="tok-builtin">@hasField</span>(SYS, <span class="tok-str">&quot;mkdir&quot;</span>)) {</span>
<span class="line" id="L357">        <span class="tok-kw">return</span> syscall2(.mkdir, <span class="tok-builtin">@ptrToInt</span>(path), mode);</span>
<span class="line" id="L358">    } <span class="tok-kw">else</span> {</span>
<span class="line" id="L359">        <span class="tok-kw">return</span> syscall3(.mkdirat, <span class="tok-builtin">@bitCast</span>(<span class="tok-type">usize</span>, <span class="tok-builtin">@as</span>(<span class="tok-type">isize</span>, AT.FDCWD)), <span class="tok-builtin">@ptrToInt</span>(path), mode);</span>
<span class="line" id="L360">    }</span>
<span class="line" id="L361">}</span>
<span class="line" id="L362"></span>
<span class="line" id="L363"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">mkdirat</span>(dirfd: <span class="tok-type">i32</span>, path: [*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span>, mode: <span class="tok-type">u32</span>) <span class="tok-type">usize</span> {</span>
<span class="line" id="L364">    <span class="tok-kw">return</span> syscall3(.mkdirat, <span class="tok-builtin">@bitCast</span>(<span class="tok-type">usize</span>, <span class="tok-builtin">@as</span>(<span class="tok-type">isize</span>, dirfd)), <span class="tok-builtin">@ptrToInt</span>(path), mode);</span>
<span class="line" id="L365">}</span>
<span class="line" id="L366"></span>
<span class="line" id="L367"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">mknod</span>(path: [*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span>, mode: <span class="tok-type">u32</span>, dev: <span class="tok-type">u32</span>) <span class="tok-type">usize</span> {</span>
<span class="line" id="L368">    <span class="tok-kw">if</span> (<span class="tok-builtin">@hasField</span>(SYS, <span class="tok-str">&quot;mknod&quot;</span>)) {</span>
<span class="line" id="L369">        <span class="tok-kw">return</span> syscall3(.mknod, <span class="tok-builtin">@ptrToInt</span>(path), mode, dev);</span>
<span class="line" id="L370">    } <span class="tok-kw">else</span> {</span>
<span class="line" id="L371">        <span class="tok-kw">return</span> mknodat(AT.FDCWD, path, mode, dev);</span>
<span class="line" id="L372">    }</span>
<span class="line" id="L373">}</span>
<span class="line" id="L374"></span>
<span class="line" id="L375"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">mknodat</span>(dirfd: <span class="tok-type">i32</span>, path: [*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span>, mode: <span class="tok-type">u32</span>, dev: <span class="tok-type">u32</span>) <span class="tok-type">usize</span> {</span>
<span class="line" id="L376">    <span class="tok-kw">return</span> syscall4(.mknodat, <span class="tok-builtin">@bitCast</span>(<span class="tok-type">usize</span>, <span class="tok-builtin">@as</span>(<span class="tok-type">isize</span>, dirfd)), <span class="tok-builtin">@ptrToInt</span>(path), mode, dev);</span>
<span class="line" id="L377">}</span>
<span class="line" id="L378"></span>
<span class="line" id="L379"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">mount</span>(special: [*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span>, dir: [*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span>, fstype: ?[*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span>, flags: <span class="tok-type">u32</span>, data: <span class="tok-type">usize</span>) <span class="tok-type">usize</span> {</span>
<span class="line" id="L380">    <span class="tok-kw">return</span> syscall5(.mount, <span class="tok-builtin">@ptrToInt</span>(special), <span class="tok-builtin">@ptrToInt</span>(dir), <span class="tok-builtin">@ptrToInt</span>(fstype), flags, data);</span>
<span class="line" id="L381">}</span>
<span class="line" id="L382"></span>
<span class="line" id="L383"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">umount</span>(special: [*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span>) <span class="tok-type">usize</span> {</span>
<span class="line" id="L384">    <span class="tok-kw">return</span> syscall2(.umount2, <span class="tok-builtin">@ptrToInt</span>(special), <span class="tok-number">0</span>);</span>
<span class="line" id="L385">}</span>
<span class="line" id="L386"></span>
<span class="line" id="L387"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">umount2</span>(special: [*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span>, flags: <span class="tok-type">u32</span>) <span class="tok-type">usize</span> {</span>
<span class="line" id="L388">    <span class="tok-kw">return</span> syscall2(.umount2, <span class="tok-builtin">@ptrToInt</span>(special), flags);</span>
<span class="line" id="L389">}</span>
<span class="line" id="L390"></span>
<span class="line" id="L391"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">mmap</span>(address: ?[*]<span class="tok-type">u8</span>, length: <span class="tok-type">usize</span>, prot: <span class="tok-type">usize</span>, flags: <span class="tok-type">u32</span>, fd: <span class="tok-type">i32</span>, offset: <span class="tok-type">i64</span>) <span class="tok-type">usize</span> {</span>
<span class="line" id="L392">    <span class="tok-kw">if</span> (<span class="tok-builtin">@hasField</span>(SYS, <span class="tok-str">&quot;mmap2&quot;</span>)) {</span>
<span class="line" id="L393">        <span class="tok-comment">// Make sure the offset is also specified in multiples of page size</span>
</span>
<span class="line" id="L394">        <span class="tok-kw">if</span> ((offset &amp; (MMAP2_UNIT - <span class="tok-number">1</span>)) != <span class="tok-number">0</span>)</span>
<span class="line" id="L395">            <span class="tok-kw">return</span> <span class="tok-builtin">@bitCast</span>(<span class="tok-type">usize</span>, -<span class="tok-builtin">@as</span>(<span class="tok-type">isize</span>, <span class="tok-builtin">@enumToInt</span>(E.INVAL)));</span>
<span class="line" id="L396"></span>
<span class="line" id="L397">        <span class="tok-kw">return</span> syscall6(</span>
<span class="line" id="L398">            .mmap2,</span>
<span class="line" id="L399">            <span class="tok-builtin">@ptrToInt</span>(address),</span>
<span class="line" id="L400">            length,</span>
<span class="line" id="L401">            prot,</span>
<span class="line" id="L402">            flags,</span>
<span class="line" id="L403">            <span class="tok-builtin">@bitCast</span>(<span class="tok-type">usize</span>, <span class="tok-builtin">@as</span>(<span class="tok-type">isize</span>, fd)),</span>
<span class="line" id="L404">            <span class="tok-builtin">@truncate</span>(<span class="tok-type">usize</span>, <span class="tok-builtin">@bitCast</span>(<span class="tok-type">u64</span>, offset) / MMAP2_UNIT),</span>
<span class="line" id="L405">        );</span>
<span class="line" id="L406">    } <span class="tok-kw">else</span> {</span>
<span class="line" id="L407">        <span class="tok-kw">return</span> syscall6(</span>
<span class="line" id="L408">            .mmap,</span>
<span class="line" id="L409">            <span class="tok-builtin">@ptrToInt</span>(address),</span>
<span class="line" id="L410">            length,</span>
<span class="line" id="L411">            prot,</span>
<span class="line" id="L412">            flags,</span>
<span class="line" id="L413">            <span class="tok-builtin">@bitCast</span>(<span class="tok-type">usize</span>, <span class="tok-builtin">@as</span>(<span class="tok-type">isize</span>, fd)),</span>
<span class="line" id="L414">            <span class="tok-builtin">@bitCast</span>(<span class="tok-type">u64</span>, offset),</span>
<span class="line" id="L415">        );</span>
<span class="line" id="L416">    }</span>
<span class="line" id="L417">}</span>
<span class="line" id="L418"></span>
<span class="line" id="L419"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">mprotect</span>(address: [*]<span class="tok-kw">const</span> <span class="tok-type">u8</span>, length: <span class="tok-type">usize</span>, protection: <span class="tok-type">usize</span>) <span class="tok-type">usize</span> {</span>
<span class="line" id="L420">    <span class="tok-kw">return</span> syscall3(.mprotect, <span class="tok-builtin">@ptrToInt</span>(address), length, protection);</span>
<span class="line" id="L421">}</span>
<span class="line" id="L422"></span>
<span class="line" id="L423"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> MSF = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L424">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> ASYNC = <span class="tok-number">1</span>;</span>
<span class="line" id="L425">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> INVALIDATE = <span class="tok-number">2</span>;</span>
<span class="line" id="L426">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> SYNC = <span class="tok-number">4</span>;</span>
<span class="line" id="L427">};</span>
<span class="line" id="L428"></span>
<span class="line" id="L429"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">msync</span>(address: [*]<span class="tok-kw">const</span> <span class="tok-type">u8</span>, length: <span class="tok-type">usize</span>, flags: <span class="tok-type">i32</span>) <span class="tok-type">usize</span> {</span>
<span class="line" id="L430">    <span class="tok-kw">return</span> syscall3(.msync, <span class="tok-builtin">@ptrToInt</span>(address), length, <span class="tok-builtin">@bitCast</span>(<span class="tok-type">u32</span>, flags));</span>
<span class="line" id="L431">}</span>
<span class="line" id="L432"></span>
<span class="line" id="L433"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">munmap</span>(address: [*]<span class="tok-kw">const</span> <span class="tok-type">u8</span>, length: <span class="tok-type">usize</span>) <span class="tok-type">usize</span> {</span>
<span class="line" id="L434">    <span class="tok-kw">return</span> syscall2(.munmap, <span class="tok-builtin">@ptrToInt</span>(address), length);</span>
<span class="line" id="L435">}</span>
<span class="line" id="L436"></span>
<span class="line" id="L437"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">poll</span>(fds: [*]pollfd, n: nfds_t, timeout: <span class="tok-type">i32</span>) <span class="tok-type">usize</span> {</span>
<span class="line" id="L438">    <span class="tok-kw">if</span> (<span class="tok-builtin">@hasField</span>(SYS, <span class="tok-str">&quot;poll&quot;</span>)) {</span>
<span class="line" id="L439">        <span class="tok-kw">return</span> syscall3(.poll, <span class="tok-builtin">@ptrToInt</span>(fds), n, <span class="tok-builtin">@bitCast</span>(<span class="tok-type">u32</span>, timeout));</span>
<span class="line" id="L440">    } <span class="tok-kw">else</span> {</span>
<span class="line" id="L441">        <span class="tok-kw">return</span> syscall5(</span>
<span class="line" id="L442">            .ppoll,</span>
<span class="line" id="L443">            <span class="tok-builtin">@ptrToInt</span>(fds),</span>
<span class="line" id="L444">            n,</span>
<span class="line" id="L445">            <span class="tok-builtin">@ptrToInt</span>(<span class="tok-kw">if</span> (timeout &gt;= <span class="tok-number">0</span>)</span>
<span class="line" id="L446">                &amp;timespec{</span>
<span class="line" id="L447">                    .tv_sec = <span class="tok-builtin">@divTrunc</span>(timeout, <span class="tok-number">1000</span>),</span>
<span class="line" id="L448">                    .tv_nsec = <span class="tok-builtin">@rem</span>(timeout, <span class="tok-number">1000</span>) * <span class="tok-number">1000000</span>,</span>
<span class="line" id="L449">                }</span>
<span class="line" id="L450">            <span class="tok-kw">else</span></span>
<span class="line" id="L451">                <span class="tok-null">null</span>),</span>
<span class="line" id="L452">            <span class="tok-number">0</span>,</span>
<span class="line" id="L453">            NSIG / <span class="tok-number">8</span>,</span>
<span class="line" id="L454">        );</span>
<span class="line" id="L455">    }</span>
<span class="line" id="L456">}</span>
<span class="line" id="L457"></span>
<span class="line" id="L458"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">ppoll</span>(fds: [*]pollfd, n: nfds_t, timeout: ?*timespec, sigmask: ?*<span class="tok-kw">const</span> sigset_t) <span class="tok-type">usize</span> {</span>
<span class="line" id="L459">    <span class="tok-kw">return</span> syscall5(.ppoll, <span class="tok-builtin">@ptrToInt</span>(fds), n, <span class="tok-builtin">@ptrToInt</span>(timeout), <span class="tok-builtin">@ptrToInt</span>(sigmask), NSIG / <span class="tok-number">8</span>);</span>
<span class="line" id="L460">}</span>
<span class="line" id="L461"></span>
<span class="line" id="L462"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">read</span>(fd: <span class="tok-type">i32</span>, buf: [*]<span class="tok-type">u8</span>, count: <span class="tok-type">usize</span>) <span class="tok-type">usize</span> {</span>
<span class="line" id="L463">    <span class="tok-kw">return</span> syscall3(.read, <span class="tok-builtin">@bitCast</span>(<span class="tok-type">usize</span>, <span class="tok-builtin">@as</span>(<span class="tok-type">isize</span>, fd)), <span class="tok-builtin">@ptrToInt</span>(buf), count);</span>
<span class="line" id="L464">}</span>
<span class="line" id="L465"></span>
<span class="line" id="L466"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">preadv</span>(fd: <span class="tok-type">i32</span>, iov: [*]<span class="tok-kw">const</span> iovec, count: <span class="tok-type">usize</span>, offset: <span class="tok-type">i64</span>) <span class="tok-type">usize</span> {</span>
<span class="line" id="L467">    <span class="tok-kw">const</span> offset_u = <span class="tok-builtin">@bitCast</span>(<span class="tok-type">u64</span>, offset);</span>
<span class="line" id="L468">    <span class="tok-kw">return</span> syscall5(</span>
<span class="line" id="L469">        .preadv,</span>
<span class="line" id="L470">        <span class="tok-builtin">@bitCast</span>(<span class="tok-type">usize</span>, <span class="tok-builtin">@as</span>(<span class="tok-type">isize</span>, fd)),</span>
<span class="line" id="L471">        <span class="tok-builtin">@ptrToInt</span>(iov),</span>
<span class="line" id="L472">        count,</span>
<span class="line" id="L473">        <span class="tok-comment">// Kernel expects the offset is splitted into largest natural word-size.</span>
</span>
<span class="line" id="L474">        <span class="tok-comment">// See following link for detail:</span>
</span>
<span class="line" id="L475">        <span class="tok-comment">// https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=601cc11d054ae4b5e9b5babec3d8e4667a2cb9b5</span>
</span>
<span class="line" id="L476">        <span class="tok-builtin">@truncate</span>(<span class="tok-type">usize</span>, offset_u),</span>
<span class="line" id="L477">        <span class="tok-kw">if</span> (usize_bits &lt; <span class="tok-number">64</span>) <span class="tok-builtin">@truncate</span>(<span class="tok-type">usize</span>, offset_u &gt;&gt; <span class="tok-number">32</span>) <span class="tok-kw">else</span> <span class="tok-number">0</span>,</span>
<span class="line" id="L478">    );</span>
<span class="line" id="L479">}</span>
<span class="line" id="L480"></span>
<span class="line" id="L481"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">preadv2</span>(fd: <span class="tok-type">i32</span>, iov: [*]<span class="tok-kw">const</span> iovec, count: <span class="tok-type">usize</span>, offset: <span class="tok-type">i64</span>, flags: kernel_rwf) <span class="tok-type">usize</span> {</span>
<span class="line" id="L482">    <span class="tok-kw">const</span> offset_u = <span class="tok-builtin">@bitCast</span>(<span class="tok-type">u64</span>, offset);</span>
<span class="line" id="L483">    <span class="tok-kw">return</span> syscall6(</span>
<span class="line" id="L484">        .preadv2,</span>
<span class="line" id="L485">        <span class="tok-builtin">@bitCast</span>(<span class="tok-type">usize</span>, <span class="tok-builtin">@as</span>(<span class="tok-type">isize</span>, fd)),</span>
<span class="line" id="L486">        <span class="tok-builtin">@ptrToInt</span>(iov),</span>
<span class="line" id="L487">        count,</span>
<span class="line" id="L488">        <span class="tok-comment">// See comments in preadv</span>
</span>
<span class="line" id="L489">        <span class="tok-builtin">@truncate</span>(<span class="tok-type">usize</span>, offset_u),</span>
<span class="line" id="L490">        <span class="tok-kw">if</span> (usize_bits &lt; <span class="tok-number">64</span>) <span class="tok-builtin">@truncate</span>(<span class="tok-type">usize</span>, offset_u &gt;&gt; <span class="tok-number">32</span>) <span class="tok-kw">else</span> <span class="tok-number">0</span>,</span>
<span class="line" id="L491">        flags,</span>
<span class="line" id="L492">    );</span>
<span class="line" id="L493">}</span>
<span class="line" id="L494"></span>
<span class="line" id="L495"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">readv</span>(fd: <span class="tok-type">i32</span>, iov: [*]<span class="tok-kw">const</span> iovec, count: <span class="tok-type">usize</span>) <span class="tok-type">usize</span> {</span>
<span class="line" id="L496">    <span class="tok-kw">return</span> syscall3(.readv, <span class="tok-builtin">@bitCast</span>(<span class="tok-type">usize</span>, <span class="tok-builtin">@as</span>(<span class="tok-type">isize</span>, fd)), <span class="tok-builtin">@ptrToInt</span>(iov), count);</span>
<span class="line" id="L497">}</span>
<span class="line" id="L498"></span>
<span class="line" id="L499"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">writev</span>(fd: <span class="tok-type">i32</span>, iov: [*]<span class="tok-kw">const</span> iovec_const, count: <span class="tok-type">usize</span>) <span class="tok-type">usize</span> {</span>
<span class="line" id="L500">    <span class="tok-kw">return</span> syscall3(.writev, <span class="tok-builtin">@bitCast</span>(<span class="tok-type">usize</span>, <span class="tok-builtin">@as</span>(<span class="tok-type">isize</span>, fd)), <span class="tok-builtin">@ptrToInt</span>(iov), count);</span>
<span class="line" id="L501">}</span>
<span class="line" id="L502"></span>
<span class="line" id="L503"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">pwritev</span>(fd: <span class="tok-type">i32</span>, iov: [*]<span class="tok-kw">const</span> iovec_const, count: <span class="tok-type">usize</span>, offset: <span class="tok-type">i64</span>) <span class="tok-type">usize</span> {</span>
<span class="line" id="L504">    <span class="tok-kw">const</span> offset_u = <span class="tok-builtin">@bitCast</span>(<span class="tok-type">u64</span>, offset);</span>
<span class="line" id="L505">    <span class="tok-kw">return</span> syscall5(</span>
<span class="line" id="L506">        .pwritev,</span>
<span class="line" id="L507">        <span class="tok-builtin">@bitCast</span>(<span class="tok-type">usize</span>, <span class="tok-builtin">@as</span>(<span class="tok-type">isize</span>, fd)),</span>
<span class="line" id="L508">        <span class="tok-builtin">@ptrToInt</span>(iov),</span>
<span class="line" id="L509">        count,</span>
<span class="line" id="L510">        <span class="tok-comment">// See comments in preadv</span>
</span>
<span class="line" id="L511">        <span class="tok-builtin">@truncate</span>(<span class="tok-type">usize</span>, offset_u),</span>
<span class="line" id="L512">        <span class="tok-kw">if</span> (usize_bits &lt; <span class="tok-number">64</span>) <span class="tok-builtin">@truncate</span>(<span class="tok-type">usize</span>, offset_u &gt;&gt; <span class="tok-number">32</span>) <span class="tok-kw">else</span> <span class="tok-number">0</span>,</span>
<span class="line" id="L513">    );</span>
<span class="line" id="L514">}</span>
<span class="line" id="L515"></span>
<span class="line" id="L516"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">pwritev2</span>(fd: <span class="tok-type">i32</span>, iov: [*]<span class="tok-kw">const</span> iovec_const, count: <span class="tok-type">usize</span>, offset: <span class="tok-type">i64</span>, flags: kernel_rwf) <span class="tok-type">usize</span> {</span>
<span class="line" id="L517">    <span class="tok-kw">const</span> offset_u = <span class="tok-builtin">@bitCast</span>(<span class="tok-type">u64</span>, offset);</span>
<span class="line" id="L518">    <span class="tok-kw">return</span> syscall6(</span>
<span class="line" id="L519">        .pwritev2,</span>
<span class="line" id="L520">        <span class="tok-builtin">@bitCast</span>(<span class="tok-type">usize</span>, <span class="tok-builtin">@as</span>(<span class="tok-type">isize</span>, fd)),</span>
<span class="line" id="L521">        <span class="tok-builtin">@ptrToInt</span>(iov),</span>
<span class="line" id="L522">        count,</span>
<span class="line" id="L523">        <span class="tok-comment">// See comments in preadv</span>
</span>
<span class="line" id="L524">        <span class="tok-builtin">@truncate</span>(<span class="tok-type">usize</span>, offset_u),</span>
<span class="line" id="L525">        <span class="tok-kw">if</span> (usize_bits &lt; <span class="tok-number">64</span>) <span class="tok-builtin">@truncate</span>(<span class="tok-type">usize</span>, offset_u &gt;&gt; <span class="tok-number">32</span>) <span class="tok-kw">else</span> <span class="tok-number">0</span>,</span>
<span class="line" id="L526">        flags,</span>
<span class="line" id="L527">    );</span>
<span class="line" id="L528">}</span>
<span class="line" id="L529"></span>
<span class="line" id="L530"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">rmdir</span>(path: [*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span>) <span class="tok-type">usize</span> {</span>
<span class="line" id="L531">    <span class="tok-kw">if</span> (<span class="tok-builtin">@hasField</span>(SYS, <span class="tok-str">&quot;rmdir&quot;</span>)) {</span>
<span class="line" id="L532">        <span class="tok-kw">return</span> syscall1(.rmdir, <span class="tok-builtin">@ptrToInt</span>(path));</span>
<span class="line" id="L533">    } <span class="tok-kw">else</span> {</span>
<span class="line" id="L534">        <span class="tok-kw">return</span> syscall3(.unlinkat, <span class="tok-builtin">@bitCast</span>(<span class="tok-type">usize</span>, <span class="tok-builtin">@as</span>(<span class="tok-type">isize</span>, AT.FDCWD)), <span class="tok-builtin">@ptrToInt</span>(path), AT.REMOVEDIR);</span>
<span class="line" id="L535">    }</span>
<span class="line" id="L536">}</span>
<span class="line" id="L537"></span>
<span class="line" id="L538"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">symlink</span>(existing: [*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span>, new: [*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span>) <span class="tok-type">usize</span> {</span>
<span class="line" id="L539">    <span class="tok-kw">if</span> (<span class="tok-builtin">@hasField</span>(SYS, <span class="tok-str">&quot;symlink&quot;</span>)) {</span>
<span class="line" id="L540">        <span class="tok-kw">return</span> syscall2(.symlink, <span class="tok-builtin">@ptrToInt</span>(existing), <span class="tok-builtin">@ptrToInt</span>(new));</span>
<span class="line" id="L541">    } <span class="tok-kw">else</span> {</span>
<span class="line" id="L542">        <span class="tok-kw">return</span> syscall3(.symlinkat, <span class="tok-builtin">@ptrToInt</span>(existing), <span class="tok-builtin">@bitCast</span>(<span class="tok-type">usize</span>, <span class="tok-builtin">@as</span>(<span class="tok-type">isize</span>, AT.FDCWD)), <span class="tok-builtin">@ptrToInt</span>(new));</span>
<span class="line" id="L543">    }</span>
<span class="line" id="L544">}</span>
<span class="line" id="L545"></span>
<span class="line" id="L546"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">symlinkat</span>(existing: [*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span>, newfd: <span class="tok-type">i32</span>, newpath: [*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span>) <span class="tok-type">usize</span> {</span>
<span class="line" id="L547">    <span class="tok-kw">return</span> syscall3(.symlinkat, <span class="tok-builtin">@ptrToInt</span>(existing), <span class="tok-builtin">@bitCast</span>(<span class="tok-type">usize</span>, <span class="tok-builtin">@as</span>(<span class="tok-type">isize</span>, newfd)), <span class="tok-builtin">@ptrToInt</span>(newpath));</span>
<span class="line" id="L548">}</span>
<span class="line" id="L549"></span>
<span class="line" id="L550"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">pread</span>(fd: <span class="tok-type">i32</span>, buf: [*]<span class="tok-type">u8</span>, count: <span class="tok-type">usize</span>, offset: <span class="tok-type">i64</span>) <span class="tok-type">usize</span> {</span>
<span class="line" id="L551">    <span class="tok-kw">if</span> (<span class="tok-builtin">@hasField</span>(SYS, <span class="tok-str">&quot;pread64&quot;</span>) <span class="tok-kw">and</span> usize_bits &lt; <span class="tok-number">64</span>) {</span>
<span class="line" id="L552">        <span class="tok-kw">const</span> offset_halves = splitValue64(offset);</span>
<span class="line" id="L553">        <span class="tok-kw">if</span> (require_aligned_register_pair) {</span>
<span class="line" id="L554">            <span class="tok-kw">return</span> syscall6(</span>
<span class="line" id="L555">                .pread64,</span>
<span class="line" id="L556">                <span class="tok-builtin">@bitCast</span>(<span class="tok-type">usize</span>, <span class="tok-builtin">@as</span>(<span class="tok-type">isize</span>, fd)),</span>
<span class="line" id="L557">                <span class="tok-builtin">@ptrToInt</span>(buf),</span>
<span class="line" id="L558">                count,</span>
<span class="line" id="L559">                <span class="tok-number">0</span>,</span>
<span class="line" id="L560">                offset_halves[<span class="tok-number">0</span>],</span>
<span class="line" id="L561">                offset_halves[<span class="tok-number">1</span>],</span>
<span class="line" id="L562">            );</span>
<span class="line" id="L563">        } <span class="tok-kw">else</span> {</span>
<span class="line" id="L564">            <span class="tok-kw">return</span> syscall5(</span>
<span class="line" id="L565">                .pread64,</span>
<span class="line" id="L566">                <span class="tok-builtin">@bitCast</span>(<span class="tok-type">usize</span>, <span class="tok-builtin">@as</span>(<span class="tok-type">isize</span>, fd)),</span>
<span class="line" id="L567">                <span class="tok-builtin">@ptrToInt</span>(buf),</span>
<span class="line" id="L568">                count,</span>
<span class="line" id="L569">                offset_halves[<span class="tok-number">0</span>],</span>
<span class="line" id="L570">                offset_halves[<span class="tok-number">1</span>],</span>
<span class="line" id="L571">            );</span>
<span class="line" id="L572">        }</span>
<span class="line" id="L573">    } <span class="tok-kw">else</span> {</span>
<span class="line" id="L574">        <span class="tok-comment">// Some architectures (eg. 64bit SPARC) pread is called pread64.</span>
</span>
<span class="line" id="L575">        <span class="tok-kw">const</span> syscall_number = <span class="tok-kw">if</span> (!<span class="tok-builtin">@hasField</span>(SYS, <span class="tok-str">&quot;pread&quot;</span>) <span class="tok-kw">and</span> <span class="tok-builtin">@hasField</span>(SYS, <span class="tok-str">&quot;pread64&quot;</span>))</span>
<span class="line" id="L576">            .pread64</span>
<span class="line" id="L577">        <span class="tok-kw">else</span></span>
<span class="line" id="L578">            .pread;</span>
<span class="line" id="L579">        <span class="tok-kw">return</span> syscall4(</span>
<span class="line" id="L580">            syscall_number,</span>
<span class="line" id="L581">            <span class="tok-builtin">@bitCast</span>(<span class="tok-type">usize</span>, <span class="tok-builtin">@as</span>(<span class="tok-type">isize</span>, fd)),</span>
<span class="line" id="L582">            <span class="tok-builtin">@ptrToInt</span>(buf),</span>
<span class="line" id="L583">            count,</span>
<span class="line" id="L584">            <span class="tok-builtin">@bitCast</span>(<span class="tok-type">u64</span>, offset),</span>
<span class="line" id="L585">        );</span>
<span class="line" id="L586">    }</span>
<span class="line" id="L587">}</span>
<span class="line" id="L588"></span>
<span class="line" id="L589"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">access</span>(path: [*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span>, mode: <span class="tok-type">u32</span>) <span class="tok-type">usize</span> {</span>
<span class="line" id="L590">    <span class="tok-kw">if</span> (<span class="tok-builtin">@hasField</span>(SYS, <span class="tok-str">&quot;access&quot;</span>)) {</span>
<span class="line" id="L591">        <span class="tok-kw">return</span> syscall2(.access, <span class="tok-builtin">@ptrToInt</span>(path), mode);</span>
<span class="line" id="L592">    } <span class="tok-kw">else</span> {</span>
<span class="line" id="L593">        <span class="tok-kw">return</span> syscall4(.faccessat, <span class="tok-builtin">@bitCast</span>(<span class="tok-type">usize</span>, <span class="tok-builtin">@as</span>(<span class="tok-type">isize</span>, AT.FDCWD)), <span class="tok-builtin">@ptrToInt</span>(path), mode, <span class="tok-number">0</span>);</span>
<span class="line" id="L594">    }</span>
<span class="line" id="L595">}</span>
<span class="line" id="L596"></span>
<span class="line" id="L597"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">faccessat</span>(dirfd: <span class="tok-type">i32</span>, path: [*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span>, mode: <span class="tok-type">u32</span>, flags: <span class="tok-type">u32</span>) <span class="tok-type">usize</span> {</span>
<span class="line" id="L598">    <span class="tok-kw">return</span> syscall4(.faccessat, <span class="tok-builtin">@bitCast</span>(<span class="tok-type">usize</span>, <span class="tok-builtin">@as</span>(<span class="tok-type">isize</span>, dirfd)), <span class="tok-builtin">@ptrToInt</span>(path), mode, flags);</span>
<span class="line" id="L599">}</span>
<span class="line" id="L600"></span>
<span class="line" id="L601"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">pipe</span>(fd: *[<span class="tok-number">2</span>]<span class="tok-type">i32</span>) <span class="tok-type">usize</span> {</span>
<span class="line" id="L602">    <span class="tok-kw">if</span> (<span class="tok-kw">comptime</span> (native_arch.isMIPS() <span class="tok-kw">or</span> native_arch.isSPARC())) {</span>
<span class="line" id="L603">        <span class="tok-kw">return</span> syscall_pipe(fd);</span>
<span class="line" id="L604">    } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (<span class="tok-builtin">@hasField</span>(SYS, <span class="tok-str">&quot;pipe&quot;</span>)) {</span>
<span class="line" id="L605">        <span class="tok-kw">return</span> syscall1(.pipe, <span class="tok-builtin">@ptrToInt</span>(fd));</span>
<span class="line" id="L606">    } <span class="tok-kw">else</span> {</span>
<span class="line" id="L607">        <span class="tok-kw">return</span> syscall2(.pipe2, <span class="tok-builtin">@ptrToInt</span>(fd), <span class="tok-number">0</span>);</span>
<span class="line" id="L608">    }</span>
<span class="line" id="L609">}</span>
<span class="line" id="L610"></span>
<span class="line" id="L611"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">pipe2</span>(fd: *[<span class="tok-number">2</span>]<span class="tok-type">i32</span>, flags: <span class="tok-type">u32</span>) <span class="tok-type">usize</span> {</span>
<span class="line" id="L612">    <span class="tok-kw">return</span> syscall2(.pipe2, <span class="tok-builtin">@ptrToInt</span>(fd), flags);</span>
<span class="line" id="L613">}</span>
<span class="line" id="L614"></span>
<span class="line" id="L615"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">write</span>(fd: <span class="tok-type">i32</span>, buf: [*]<span class="tok-kw">const</span> <span class="tok-type">u8</span>, count: <span class="tok-type">usize</span>) <span class="tok-type">usize</span> {</span>
<span class="line" id="L616">    <span class="tok-kw">return</span> syscall3(.write, <span class="tok-builtin">@bitCast</span>(<span class="tok-type">usize</span>, <span class="tok-builtin">@as</span>(<span class="tok-type">isize</span>, fd)), <span class="tok-builtin">@ptrToInt</span>(buf), count);</span>
<span class="line" id="L617">}</span>
<span class="line" id="L618"></span>
<span class="line" id="L619"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">ftruncate</span>(fd: <span class="tok-type">i32</span>, length: <span class="tok-type">i64</span>) <span class="tok-type">usize</span> {</span>
<span class="line" id="L620">    <span class="tok-kw">if</span> (<span class="tok-builtin">@hasField</span>(SYS, <span class="tok-str">&quot;ftruncate64&quot;</span>) <span class="tok-kw">and</span> usize_bits &lt; <span class="tok-number">64</span>) {</span>
<span class="line" id="L621">        <span class="tok-kw">const</span> length_halves = splitValue64(length);</span>
<span class="line" id="L622">        <span class="tok-kw">if</span> (require_aligned_register_pair) {</span>
<span class="line" id="L623">            <span class="tok-kw">return</span> syscall4(</span>
<span class="line" id="L624">                .ftruncate64,</span>
<span class="line" id="L625">                <span class="tok-builtin">@bitCast</span>(<span class="tok-type">usize</span>, <span class="tok-builtin">@as</span>(<span class="tok-type">isize</span>, fd)),</span>
<span class="line" id="L626">                <span class="tok-number">0</span>,</span>
<span class="line" id="L627">                length_halves[<span class="tok-number">0</span>],</span>
<span class="line" id="L628">                length_halves[<span class="tok-number">1</span>],</span>
<span class="line" id="L629">            );</span>
<span class="line" id="L630">        } <span class="tok-kw">else</span> {</span>
<span class="line" id="L631">            <span class="tok-kw">return</span> syscall3(</span>
<span class="line" id="L632">                .ftruncate64,</span>
<span class="line" id="L633">                <span class="tok-builtin">@bitCast</span>(<span class="tok-type">usize</span>, <span class="tok-builtin">@as</span>(<span class="tok-type">isize</span>, fd)),</span>
<span class="line" id="L634">                length_halves[<span class="tok-number">0</span>],</span>
<span class="line" id="L635">                length_halves[<span class="tok-number">1</span>],</span>
<span class="line" id="L636">            );</span>
<span class="line" id="L637">        }</span>
<span class="line" id="L638">    } <span class="tok-kw">else</span> {</span>
<span class="line" id="L639">        <span class="tok-kw">return</span> syscall2(</span>
<span class="line" id="L640">            .ftruncate,</span>
<span class="line" id="L641">            <span class="tok-builtin">@bitCast</span>(<span class="tok-type">usize</span>, <span class="tok-builtin">@as</span>(<span class="tok-type">isize</span>, fd)),</span>
<span class="line" id="L642">            <span class="tok-builtin">@bitCast</span>(<span class="tok-type">usize</span>, length),</span>
<span class="line" id="L643">        );</span>
<span class="line" id="L644">    }</span>
<span class="line" id="L645">}</span>
<span class="line" id="L646"></span>
<span class="line" id="L647"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">pwrite</span>(fd: <span class="tok-type">i32</span>, buf: [*]<span class="tok-kw">const</span> <span class="tok-type">u8</span>, count: <span class="tok-type">usize</span>, offset: <span class="tok-type">i64</span>) <span class="tok-type">usize</span> {</span>
<span class="line" id="L648">    <span class="tok-kw">if</span> (<span class="tok-builtin">@hasField</span>(SYS, <span class="tok-str">&quot;pwrite64&quot;</span>) <span class="tok-kw">and</span> usize_bits &lt; <span class="tok-number">64</span>) {</span>
<span class="line" id="L649">        <span class="tok-kw">const</span> offset_halves = splitValue64(offset);</span>
<span class="line" id="L650"></span>
<span class="line" id="L651">        <span class="tok-kw">if</span> (require_aligned_register_pair) {</span>
<span class="line" id="L652">            <span class="tok-kw">return</span> syscall6(</span>
<span class="line" id="L653">                .pwrite64,</span>
<span class="line" id="L654">                <span class="tok-builtin">@bitCast</span>(<span class="tok-type">usize</span>, <span class="tok-builtin">@as</span>(<span class="tok-type">isize</span>, fd)),</span>
<span class="line" id="L655">                <span class="tok-builtin">@ptrToInt</span>(buf),</span>
<span class="line" id="L656">                count,</span>
<span class="line" id="L657">                <span class="tok-number">0</span>,</span>
<span class="line" id="L658">                offset_halves[<span class="tok-number">0</span>],</span>
<span class="line" id="L659">                offset_halves[<span class="tok-number">1</span>],</span>
<span class="line" id="L660">            );</span>
<span class="line" id="L661">        } <span class="tok-kw">else</span> {</span>
<span class="line" id="L662">            <span class="tok-kw">return</span> syscall5(</span>
<span class="line" id="L663">                .pwrite64,</span>
<span class="line" id="L664">                <span class="tok-builtin">@bitCast</span>(<span class="tok-type">usize</span>, <span class="tok-builtin">@as</span>(<span class="tok-type">isize</span>, fd)),</span>
<span class="line" id="L665">                <span class="tok-builtin">@ptrToInt</span>(buf),</span>
<span class="line" id="L666">                count,</span>
<span class="line" id="L667">                offset_halves[<span class="tok-number">0</span>],</span>
<span class="line" id="L668">                offset_halves[<span class="tok-number">1</span>],</span>
<span class="line" id="L669">            );</span>
<span class="line" id="L670">        }</span>
<span class="line" id="L671">    } <span class="tok-kw">else</span> {</span>
<span class="line" id="L672">        <span class="tok-comment">// Some architectures (eg. 64bit SPARC) pwrite is called pwrite64.</span>
</span>
<span class="line" id="L673">        <span class="tok-kw">const</span> syscall_number = <span class="tok-kw">if</span> (!<span class="tok-builtin">@hasField</span>(SYS, <span class="tok-str">&quot;pwrite&quot;</span>) <span class="tok-kw">and</span> <span class="tok-builtin">@hasField</span>(SYS, <span class="tok-str">&quot;pwrite64&quot;</span>))</span>
<span class="line" id="L674">            .pwrite64</span>
<span class="line" id="L675">        <span class="tok-kw">else</span></span>
<span class="line" id="L676">            .pwrite;</span>
<span class="line" id="L677">        <span class="tok-kw">return</span> syscall4(</span>
<span class="line" id="L678">            syscall_number,</span>
<span class="line" id="L679">            <span class="tok-builtin">@bitCast</span>(<span class="tok-type">usize</span>, <span class="tok-builtin">@as</span>(<span class="tok-type">isize</span>, fd)),</span>
<span class="line" id="L680">            <span class="tok-builtin">@ptrToInt</span>(buf),</span>
<span class="line" id="L681">            count,</span>
<span class="line" id="L682">            <span class="tok-builtin">@bitCast</span>(<span class="tok-type">u64</span>, offset),</span>
<span class="line" id="L683">        );</span>
<span class="line" id="L684">    }</span>
<span class="line" id="L685">}</span>
<span class="line" id="L686"></span>
<span class="line" id="L687"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">rename</span>(old: [*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span>, new: [*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span>) <span class="tok-type">usize</span> {</span>
<span class="line" id="L688">    <span class="tok-kw">if</span> (<span class="tok-builtin">@hasField</span>(SYS, <span class="tok-str">&quot;rename&quot;</span>)) {</span>
<span class="line" id="L689">        <span class="tok-kw">return</span> syscall2(.rename, <span class="tok-builtin">@ptrToInt</span>(old), <span class="tok-builtin">@ptrToInt</span>(new));</span>
<span class="line" id="L690">    } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (<span class="tok-builtin">@hasField</span>(SYS, <span class="tok-str">&quot;renameat&quot;</span>)) {</span>
<span class="line" id="L691">        <span class="tok-kw">return</span> syscall4(.renameat, <span class="tok-builtin">@bitCast</span>(<span class="tok-type">usize</span>, <span class="tok-builtin">@as</span>(<span class="tok-type">isize</span>, AT.FDCWD)), <span class="tok-builtin">@ptrToInt</span>(old), <span class="tok-builtin">@bitCast</span>(<span class="tok-type">usize</span>, <span class="tok-builtin">@as</span>(<span class="tok-type">isize</span>, AT.FDCWD)), <span class="tok-builtin">@ptrToInt</span>(new));</span>
<span class="line" id="L692">    } <span class="tok-kw">else</span> {</span>
<span class="line" id="L693">        <span class="tok-kw">return</span> syscall5(.renameat2, <span class="tok-builtin">@bitCast</span>(<span class="tok-type">usize</span>, <span class="tok-builtin">@as</span>(<span class="tok-type">isize</span>, AT.FDCWD)), <span class="tok-builtin">@ptrToInt</span>(old), <span class="tok-builtin">@bitCast</span>(<span class="tok-type">usize</span>, <span class="tok-builtin">@as</span>(<span class="tok-type">isize</span>, AT.FDCWD)), <span class="tok-builtin">@ptrToInt</span>(new), <span class="tok-number">0</span>);</span>
<span class="line" id="L694">    }</span>
<span class="line" id="L695">}</span>
<span class="line" id="L696"></span>
<span class="line" id="L697"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">renameat</span>(oldfd: <span class="tok-type">i32</span>, oldpath: [*]<span class="tok-kw">const</span> <span class="tok-type">u8</span>, newfd: <span class="tok-type">i32</span>, newpath: [*]<span class="tok-kw">const</span> <span class="tok-type">u8</span>) <span class="tok-type">usize</span> {</span>
<span class="line" id="L698">    <span class="tok-kw">if</span> (<span class="tok-builtin">@hasField</span>(SYS, <span class="tok-str">&quot;renameat&quot;</span>)) {</span>
<span class="line" id="L699">        <span class="tok-kw">return</span> syscall4(</span>
<span class="line" id="L700">            .renameat,</span>
<span class="line" id="L701">            <span class="tok-builtin">@bitCast</span>(<span class="tok-type">usize</span>, <span class="tok-builtin">@as</span>(<span class="tok-type">isize</span>, oldfd)),</span>
<span class="line" id="L702">            <span class="tok-builtin">@ptrToInt</span>(oldpath),</span>
<span class="line" id="L703">            <span class="tok-builtin">@bitCast</span>(<span class="tok-type">usize</span>, <span class="tok-builtin">@as</span>(<span class="tok-type">isize</span>, newfd)),</span>
<span class="line" id="L704">            <span class="tok-builtin">@ptrToInt</span>(newpath),</span>
<span class="line" id="L705">        );</span>
<span class="line" id="L706">    } <span class="tok-kw">else</span> {</span>
<span class="line" id="L707">        <span class="tok-kw">return</span> syscall5(</span>
<span class="line" id="L708">            .renameat2,</span>
<span class="line" id="L709">            <span class="tok-builtin">@bitCast</span>(<span class="tok-type">usize</span>, <span class="tok-builtin">@as</span>(<span class="tok-type">isize</span>, oldfd)),</span>
<span class="line" id="L710">            <span class="tok-builtin">@ptrToInt</span>(oldpath),</span>
<span class="line" id="L711">            <span class="tok-builtin">@bitCast</span>(<span class="tok-type">usize</span>, <span class="tok-builtin">@as</span>(<span class="tok-type">isize</span>, newfd)),</span>
<span class="line" id="L712">            <span class="tok-builtin">@ptrToInt</span>(newpath),</span>
<span class="line" id="L713">            <span class="tok-number">0</span>,</span>
<span class="line" id="L714">        );</span>
<span class="line" id="L715">    }</span>
<span class="line" id="L716">}</span>
<span class="line" id="L717"></span>
<span class="line" id="L718"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">renameat2</span>(oldfd: <span class="tok-type">i32</span>, oldpath: [*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span>, newfd: <span class="tok-type">i32</span>, newpath: [*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span>, flags: <span class="tok-type">u32</span>) <span class="tok-type">usize</span> {</span>
<span class="line" id="L719">    <span class="tok-kw">return</span> syscall5(</span>
<span class="line" id="L720">        .renameat2,</span>
<span class="line" id="L721">        <span class="tok-builtin">@bitCast</span>(<span class="tok-type">usize</span>, <span class="tok-builtin">@as</span>(<span class="tok-type">isize</span>, oldfd)),</span>
<span class="line" id="L722">        <span class="tok-builtin">@ptrToInt</span>(oldpath),</span>
<span class="line" id="L723">        <span class="tok-builtin">@bitCast</span>(<span class="tok-type">usize</span>, <span class="tok-builtin">@as</span>(<span class="tok-type">isize</span>, newfd)),</span>
<span class="line" id="L724">        <span class="tok-builtin">@ptrToInt</span>(newpath),</span>
<span class="line" id="L725">        flags,</span>
<span class="line" id="L726">    );</span>
<span class="line" id="L727">}</span>
<span class="line" id="L728"></span>
<span class="line" id="L729"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">open</span>(path: [*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span>, flags: <span class="tok-type">u32</span>, perm: mode_t) <span class="tok-type">usize</span> {</span>
<span class="line" id="L730">    <span class="tok-kw">if</span> (<span class="tok-builtin">@hasField</span>(SYS, <span class="tok-str">&quot;open&quot;</span>)) {</span>
<span class="line" id="L731">        <span class="tok-kw">return</span> syscall3(.open, <span class="tok-builtin">@ptrToInt</span>(path), flags, perm);</span>
<span class="line" id="L732">    } <span class="tok-kw">else</span> {</span>
<span class="line" id="L733">        <span class="tok-kw">return</span> syscall4(</span>
<span class="line" id="L734">            .openat,</span>
<span class="line" id="L735">            <span class="tok-builtin">@bitCast</span>(<span class="tok-type">usize</span>, <span class="tok-builtin">@as</span>(<span class="tok-type">isize</span>, AT.FDCWD)),</span>
<span class="line" id="L736">            <span class="tok-builtin">@ptrToInt</span>(path),</span>
<span class="line" id="L737">            flags,</span>
<span class="line" id="L738">            perm,</span>
<span class="line" id="L739">        );</span>
<span class="line" id="L740">    }</span>
<span class="line" id="L741">}</span>
<span class="line" id="L742"></span>
<span class="line" id="L743"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">create</span>(path: [*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span>, perm: mode_t) <span class="tok-type">usize</span> {</span>
<span class="line" id="L744">    <span class="tok-kw">return</span> syscall2(.creat, <span class="tok-builtin">@ptrToInt</span>(path), perm);</span>
<span class="line" id="L745">}</span>
<span class="line" id="L746"></span>
<span class="line" id="L747"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">openat</span>(dirfd: <span class="tok-type">i32</span>, path: [*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span>, flags: <span class="tok-type">u32</span>, mode: mode_t) <span class="tok-type">usize</span> {</span>
<span class="line" id="L748">    <span class="tok-comment">// dirfd could be negative, for example AT.FDCWD is -100</span>
</span>
<span class="line" id="L749">    <span class="tok-kw">return</span> syscall4(.openat, <span class="tok-builtin">@bitCast</span>(<span class="tok-type">usize</span>, <span class="tok-builtin">@as</span>(<span class="tok-type">isize</span>, dirfd)), <span class="tok-builtin">@ptrToInt</span>(path), flags, mode);</span>
<span class="line" id="L750">}</span>
<span class="line" id="L751"></span>
<span class="line" id="L752"><span class="tok-comment">/// See also `clone` (from the arch-specific include)</span></span>
<span class="line" id="L753"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">clone5</span>(flags: <span class="tok-type">usize</span>, child_stack_ptr: <span class="tok-type">usize</span>, parent_tid: *<span class="tok-type">i32</span>, child_tid: *<span class="tok-type">i32</span>, newtls: <span class="tok-type">usize</span>) <span class="tok-type">usize</span> {</span>
<span class="line" id="L754">    <span class="tok-kw">return</span> syscall5(.clone, flags, child_stack_ptr, <span class="tok-builtin">@ptrToInt</span>(parent_tid), <span class="tok-builtin">@ptrToInt</span>(child_tid), newtls);</span>
<span class="line" id="L755">}</span>
<span class="line" id="L756"></span>
<span class="line" id="L757"><span class="tok-comment">/// See also `clone` (from the arch-specific include)</span></span>
<span class="line" id="L758"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">clone2</span>(flags: <span class="tok-type">u32</span>, child_stack_ptr: <span class="tok-type">usize</span>) <span class="tok-type">usize</span> {</span>
<span class="line" id="L759">    <span class="tok-kw">return</span> syscall2(.clone, flags, child_stack_ptr);</span>
<span class="line" id="L760">}</span>
<span class="line" id="L761"></span>
<span class="line" id="L762"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">close</span>(fd: <span class="tok-type">i32</span>) <span class="tok-type">usize</span> {</span>
<span class="line" id="L763">    <span class="tok-kw">return</span> syscall1(.close, <span class="tok-builtin">@bitCast</span>(<span class="tok-type">usize</span>, <span class="tok-builtin">@as</span>(<span class="tok-type">isize</span>, fd)));</span>
<span class="line" id="L764">}</span>
<span class="line" id="L765"></span>
<span class="line" id="L766"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">fchmod</span>(fd: <span class="tok-type">i32</span>, mode: mode_t) <span class="tok-type">usize</span> {</span>
<span class="line" id="L767">    <span class="tok-kw">return</span> syscall2(.fchmod, <span class="tok-builtin">@bitCast</span>(<span class="tok-type">usize</span>, <span class="tok-builtin">@as</span>(<span class="tok-type">isize</span>, fd)), mode);</span>
<span class="line" id="L768">}</span>
<span class="line" id="L769"></span>
<span class="line" id="L770"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">fchown</span>(fd: <span class="tok-type">i32</span>, owner: uid_t, group: gid_t) <span class="tok-type">usize</span> {</span>
<span class="line" id="L771">    <span class="tok-kw">if</span> (<span class="tok-builtin">@hasField</span>(SYS, <span class="tok-str">&quot;fchown32&quot;</span>)) {</span>
<span class="line" id="L772">        <span class="tok-kw">return</span> syscall3(.fchown32, <span class="tok-builtin">@bitCast</span>(<span class="tok-type">usize</span>, <span class="tok-builtin">@as</span>(<span class="tok-type">isize</span>, fd)), owner, group);</span>
<span class="line" id="L773">    } <span class="tok-kw">else</span> {</span>
<span class="line" id="L774">        <span class="tok-kw">return</span> syscall3(.fchown, <span class="tok-builtin">@bitCast</span>(<span class="tok-type">usize</span>, <span class="tok-builtin">@as</span>(<span class="tok-type">isize</span>, fd)), owner, group);</span>
<span class="line" id="L775">    }</span>
<span class="line" id="L776">}</span>
<span class="line" id="L777"></span>
<span class="line" id="L778"><span class="tok-comment">/// Can only be called on 32 bit systems. For 64 bit see `lseek`.</span></span>
<span class="line" id="L779"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">llseek</span>(fd: <span class="tok-type">i32</span>, offset: <span class="tok-type">u64</span>, result: ?*<span class="tok-type">u64</span>, whence: <span class="tok-type">usize</span>) <span class="tok-type">usize</span> {</span>
<span class="line" id="L780">    <span class="tok-comment">// NOTE: The offset parameter splitting is independent from the target</span>
</span>
<span class="line" id="L781">    <span class="tok-comment">// endianness.</span>
</span>
<span class="line" id="L782">    <span class="tok-kw">return</span> syscall5(</span>
<span class="line" id="L783">        ._llseek,</span>
<span class="line" id="L784">        <span class="tok-builtin">@bitCast</span>(<span class="tok-type">usize</span>, <span class="tok-builtin">@as</span>(<span class="tok-type">isize</span>, fd)),</span>
<span class="line" id="L785">        <span class="tok-builtin">@truncate</span>(<span class="tok-type">usize</span>, offset &gt;&gt; <span class="tok-number">32</span>),</span>
<span class="line" id="L786">        <span class="tok-builtin">@truncate</span>(<span class="tok-type">usize</span>, offset),</span>
<span class="line" id="L787">        <span class="tok-builtin">@ptrToInt</span>(result),</span>
<span class="line" id="L788">        whence,</span>
<span class="line" id="L789">    );</span>
<span class="line" id="L790">}</span>
<span class="line" id="L791"></span>
<span class="line" id="L792"><span class="tok-comment">/// Can only be called on 64 bit systems. For 32 bit see `llseek`.</span></span>
<span class="line" id="L793"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">lseek</span>(fd: <span class="tok-type">i32</span>, offset: <span class="tok-type">i64</span>, whence: <span class="tok-type">usize</span>) <span class="tok-type">usize</span> {</span>
<span class="line" id="L794">    <span class="tok-kw">return</span> syscall3(.lseek, <span class="tok-builtin">@bitCast</span>(<span class="tok-type">usize</span>, <span class="tok-builtin">@as</span>(<span class="tok-type">isize</span>, fd)), <span class="tok-builtin">@bitCast</span>(<span class="tok-type">usize</span>, offset), whence);</span>
<span class="line" id="L795">}</span>
<span class="line" id="L796"></span>
<span class="line" id="L797"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">exit</span>(status: <span class="tok-type">i32</span>) <span class="tok-type">noreturn</span> {</span>
<span class="line" id="L798">    _ = syscall1(.exit, <span class="tok-builtin">@bitCast</span>(<span class="tok-type">usize</span>, <span class="tok-builtin">@as</span>(<span class="tok-type">isize</span>, status)));</span>
<span class="line" id="L799">    <span class="tok-kw">unreachable</span>;</span>
<span class="line" id="L800">}</span>
<span class="line" id="L801"></span>
<span class="line" id="L802"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">exit_group</span>(status: <span class="tok-type">i32</span>) <span class="tok-type">noreturn</span> {</span>
<span class="line" id="L803">    _ = syscall1(.exit_group, <span class="tok-builtin">@bitCast</span>(<span class="tok-type">usize</span>, <span class="tok-builtin">@as</span>(<span class="tok-type">isize</span>, status)));</span>
<span class="line" id="L804">    <span class="tok-kw">unreachable</span>;</span>
<span class="line" id="L805">}</span>
<span class="line" id="L806"></span>
<span class="line" id="L807"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">getrandom</span>(buf: [*]<span class="tok-type">u8</span>, count: <span class="tok-type">usize</span>, flags: <span class="tok-type">u32</span>) <span class="tok-type">usize</span> {</span>
<span class="line" id="L808">    <span class="tok-kw">return</span> syscall3(.getrandom, <span class="tok-builtin">@ptrToInt</span>(buf), count, flags);</span>
<span class="line" id="L809">}</span>
<span class="line" id="L810"></span>
<span class="line" id="L811"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">kill</span>(pid: pid_t, sig: <span class="tok-type">i32</span>) <span class="tok-type">usize</span> {</span>
<span class="line" id="L812">    <span class="tok-kw">return</span> syscall2(.kill, <span class="tok-builtin">@bitCast</span>(<span class="tok-type">usize</span>, <span class="tok-builtin">@as</span>(<span class="tok-type">isize</span>, pid)), <span class="tok-builtin">@bitCast</span>(<span class="tok-type">usize</span>, <span class="tok-builtin">@as</span>(<span class="tok-type">isize</span>, sig)));</span>
<span class="line" id="L813">}</span>
<span class="line" id="L814"></span>
<span class="line" id="L815"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">tkill</span>(tid: pid_t, sig: <span class="tok-type">i32</span>) <span class="tok-type">usize</span> {</span>
<span class="line" id="L816">    <span class="tok-kw">return</span> syscall2(.tkill, <span class="tok-builtin">@bitCast</span>(<span class="tok-type">usize</span>, <span class="tok-builtin">@as</span>(<span class="tok-type">isize</span>, tid)), <span class="tok-builtin">@bitCast</span>(<span class="tok-type">usize</span>, <span class="tok-builtin">@as</span>(<span class="tok-type">isize</span>, sig)));</span>
<span class="line" id="L817">}</span>
<span class="line" id="L818"></span>
<span class="line" id="L819"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">tgkill</span>(tgid: pid_t, tid: pid_t, sig: <span class="tok-type">i32</span>) <span class="tok-type">usize</span> {</span>
<span class="line" id="L820">    <span class="tok-kw">return</span> syscall3(.tgkill, <span class="tok-builtin">@bitCast</span>(<span class="tok-type">usize</span>, <span class="tok-builtin">@as</span>(<span class="tok-type">isize</span>, tgid)), <span class="tok-builtin">@bitCast</span>(<span class="tok-type">usize</span>, <span class="tok-builtin">@as</span>(<span class="tok-type">isize</span>, tid)), <span class="tok-builtin">@bitCast</span>(<span class="tok-type">usize</span>, <span class="tok-builtin">@as</span>(<span class="tok-type">isize</span>, sig)));</span>
<span class="line" id="L821">}</span>
<span class="line" id="L822"></span>
<span class="line" id="L823"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">link</span>(oldpath: [*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span>, newpath: [*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span>, flags: <span class="tok-type">i32</span>) <span class="tok-type">usize</span> {</span>
<span class="line" id="L824">    <span class="tok-kw">if</span> (<span class="tok-builtin">@hasField</span>(SYS, <span class="tok-str">&quot;link&quot;</span>)) {</span>
<span class="line" id="L825">        <span class="tok-kw">return</span> syscall3(</span>
<span class="line" id="L826">            .link,</span>
<span class="line" id="L827">            <span class="tok-builtin">@ptrToInt</span>(oldpath),</span>
<span class="line" id="L828">            <span class="tok-builtin">@ptrToInt</span>(newpath),</span>
<span class="line" id="L829">            <span class="tok-builtin">@bitCast</span>(<span class="tok-type">usize</span>, <span class="tok-builtin">@as</span>(<span class="tok-type">isize</span>, flags)),</span>
<span class="line" id="L830">        );</span>
<span class="line" id="L831">    } <span class="tok-kw">else</span> {</span>
<span class="line" id="L832">        <span class="tok-kw">return</span> syscall5(</span>
<span class="line" id="L833">            .linkat,</span>
<span class="line" id="L834">            <span class="tok-builtin">@bitCast</span>(<span class="tok-type">usize</span>, <span class="tok-builtin">@as</span>(<span class="tok-type">isize</span>, AT.FDCWD)),</span>
<span class="line" id="L835">            <span class="tok-builtin">@ptrToInt</span>(oldpath),</span>
<span class="line" id="L836">            <span class="tok-builtin">@bitCast</span>(<span class="tok-type">usize</span>, <span class="tok-builtin">@as</span>(<span class="tok-type">isize</span>, AT.FDCWD)),</span>
<span class="line" id="L837">            <span class="tok-builtin">@ptrToInt</span>(newpath),</span>
<span class="line" id="L838">            <span class="tok-builtin">@bitCast</span>(<span class="tok-type">usize</span>, <span class="tok-builtin">@as</span>(<span class="tok-type">isize</span>, flags)),</span>
<span class="line" id="L839">        );</span>
<span class="line" id="L840">    }</span>
<span class="line" id="L841">}</span>
<span class="line" id="L842"></span>
<span class="line" id="L843"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">linkat</span>(oldfd: fd_t, oldpath: [*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span>, newfd: fd_t, newpath: [*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span>, flags: <span class="tok-type">i32</span>) <span class="tok-type">usize</span> {</span>
<span class="line" id="L844">    <span class="tok-kw">return</span> syscall5(</span>
<span class="line" id="L845">        .linkat,</span>
<span class="line" id="L846">        <span class="tok-builtin">@bitCast</span>(<span class="tok-type">usize</span>, <span class="tok-builtin">@as</span>(<span class="tok-type">isize</span>, oldfd)),</span>
<span class="line" id="L847">        <span class="tok-builtin">@ptrToInt</span>(oldpath),</span>
<span class="line" id="L848">        <span class="tok-builtin">@bitCast</span>(<span class="tok-type">usize</span>, <span class="tok-builtin">@as</span>(<span class="tok-type">isize</span>, newfd)),</span>
<span class="line" id="L849">        <span class="tok-builtin">@ptrToInt</span>(newpath),</span>
<span class="line" id="L850">        <span class="tok-builtin">@bitCast</span>(<span class="tok-type">usize</span>, <span class="tok-builtin">@as</span>(<span class="tok-type">isize</span>, flags)),</span>
<span class="line" id="L851">    );</span>
<span class="line" id="L852">}</span>
<span class="line" id="L853"></span>
<span class="line" id="L854"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">unlink</span>(path: [*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span>) <span class="tok-type">usize</span> {</span>
<span class="line" id="L855">    <span class="tok-kw">if</span> (<span class="tok-builtin">@hasField</span>(SYS, <span class="tok-str">&quot;unlink&quot;</span>)) {</span>
<span class="line" id="L856">        <span class="tok-kw">return</span> syscall1(.unlink, <span class="tok-builtin">@ptrToInt</span>(path));</span>
<span class="line" id="L857">    } <span class="tok-kw">else</span> {</span>
<span class="line" id="L858">        <span class="tok-kw">return</span> syscall3(.unlinkat, <span class="tok-builtin">@bitCast</span>(<span class="tok-type">usize</span>, <span class="tok-builtin">@as</span>(<span class="tok-type">isize</span>, AT.FDCWD)), <span class="tok-builtin">@ptrToInt</span>(path), <span class="tok-number">0</span>);</span>
<span class="line" id="L859">    }</span>
<span class="line" id="L860">}</span>
<span class="line" id="L861"></span>
<span class="line" id="L862"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">unlinkat</span>(dirfd: <span class="tok-type">i32</span>, path: [*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span>, flags: <span class="tok-type">u32</span>) <span class="tok-type">usize</span> {</span>
<span class="line" id="L863">    <span class="tok-kw">return</span> syscall3(.unlinkat, <span class="tok-builtin">@bitCast</span>(<span class="tok-type">usize</span>, <span class="tok-builtin">@as</span>(<span class="tok-type">isize</span>, dirfd)), <span class="tok-builtin">@ptrToInt</span>(path), flags);</span>
<span class="line" id="L864">}</span>
<span class="line" id="L865"></span>
<span class="line" id="L866"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">waitpid</span>(pid: pid_t, status: *<span class="tok-type">u32</span>, flags: <span class="tok-type">u32</span>) <span class="tok-type">usize</span> {</span>
<span class="line" id="L867">    <span class="tok-kw">return</span> syscall4(.wait4, <span class="tok-builtin">@bitCast</span>(<span class="tok-type">usize</span>, <span class="tok-builtin">@as</span>(<span class="tok-type">isize</span>, pid)), <span class="tok-builtin">@ptrToInt</span>(status), flags, <span class="tok-number">0</span>);</span>
<span class="line" id="L868">}</span>
<span class="line" id="L869"></span>
<span class="line" id="L870"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">waitid</span>(id_type: P, id: <span class="tok-type">i32</span>, infop: *siginfo_t, flags: <span class="tok-type">u32</span>) <span class="tok-type">usize</span> {</span>
<span class="line" id="L871">    <span class="tok-kw">return</span> syscall5(.waitid, <span class="tok-builtin">@enumToInt</span>(id_type), <span class="tok-builtin">@bitCast</span>(<span class="tok-type">usize</span>, <span class="tok-builtin">@as</span>(<span class="tok-type">isize</span>, id)), <span class="tok-builtin">@ptrToInt</span>(infop), flags, <span class="tok-number">0</span>);</span>
<span class="line" id="L872">}</span>
<span class="line" id="L873"></span>
<span class="line" id="L874"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">fcntl</span>(fd: fd_t, cmd: <span class="tok-type">i32</span>, arg: <span class="tok-type">usize</span>) <span class="tok-type">usize</span> {</span>
<span class="line" id="L875">    <span class="tok-kw">return</span> syscall3(.fcntl, <span class="tok-builtin">@bitCast</span>(<span class="tok-type">usize</span>, <span class="tok-builtin">@as</span>(<span class="tok-type">isize</span>, fd)), <span class="tok-builtin">@bitCast</span>(<span class="tok-type">usize</span>, <span class="tok-builtin">@as</span>(<span class="tok-type">isize</span>, cmd)), arg);</span>
<span class="line" id="L876">}</span>
<span class="line" id="L877"></span>
<span class="line" id="L878"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">flock</span>(fd: fd_t, operation: <span class="tok-type">i32</span>) <span class="tok-type">usize</span> {</span>
<span class="line" id="L879">    <span class="tok-kw">return</span> syscall2(.flock, <span class="tok-builtin">@bitCast</span>(<span class="tok-type">usize</span>, <span class="tok-builtin">@as</span>(<span class="tok-type">isize</span>, fd)), <span class="tok-builtin">@bitCast</span>(<span class="tok-type">usize</span>, <span class="tok-builtin">@as</span>(<span class="tok-type">isize</span>, operation)));</span>
<span class="line" id="L880">}</span>
<span class="line" id="L881"></span>
<span class="line" id="L882"><span class="tok-kw">var</span> vdso_clock_gettime = <span class="tok-kw">if</span> (builtin.zig_backend == .stage1)</span>
<span class="line" id="L883">    <span class="tok-builtin">@ptrCast</span>(?*<span class="tok-kw">const</span> <span class="tok-type">anyopaque</span>, init_vdso_clock_gettime)</span>
<span class="line" id="L884"><span class="tok-kw">else</span></span>
<span class="line" id="L885">    <span class="tok-builtin">@ptrCast</span>(?*<span class="tok-kw">const</span> <span class="tok-type">anyopaque</span>, &amp;init_vdso_clock_gettime);</span>
<span class="line" id="L886"></span>
<span class="line" id="L887"><span class="tok-comment">// We must follow the C calling convention when we call into the VDSO</span>
</span>
<span class="line" id="L888"><span class="tok-kw">const</span> vdso_clock_gettime_ty = <span class="tok-kw">if</span> (builtin.zig_backend == .stage1)</span>
<span class="line" id="L889">    <span class="tok-kw">fn</span> (<span class="tok-type">i32</span>, *timespec) <span class="tok-kw">callconv</span>(.C) <span class="tok-type">usize</span></span>
<span class="line" id="L890"><span class="tok-kw">else</span></span>
<span class="line" id="L891">    *<span class="tok-kw">const</span> <span class="tok-kw">fn</span> (<span class="tok-type">i32</span>, *timespec) <span class="tok-kw">callconv</span>(.C) <span class="tok-type">usize</span>;</span>
<span class="line" id="L892"></span>
<span class="line" id="L893"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">clock_gettime</span>(clk_id: <span class="tok-type">i32</span>, tp: *timespec) <span class="tok-type">usize</span> {</span>
<span class="line" id="L894">    <span class="tok-kw">if</span> (<span class="tok-builtin">@hasDecl</span>(VDSO, <span class="tok-str">&quot;CGT_SYM&quot;</span>)) {</span>
<span class="line" id="L895">        <span class="tok-kw">const</span> ptr = <span class="tok-builtin">@atomicLoad</span>(?*<span class="tok-kw">const</span> <span class="tok-type">anyopaque</span>, &amp;vdso_clock_gettime, .Unordered);</span>
<span class="line" id="L896">        <span class="tok-kw">if</span> (ptr) |fn_ptr| {</span>
<span class="line" id="L897">            <span class="tok-kw">const</span> f = <span class="tok-builtin">@ptrCast</span>(vdso_clock_gettime_ty, fn_ptr);</span>
<span class="line" id="L898">            <span class="tok-kw">const</span> rc = f(clk_id, tp);</span>
<span class="line" id="L899">            <span class="tok-kw">switch</span> (rc) {</span>
<span class="line" id="L900">                <span class="tok-number">0</span>, <span class="tok-builtin">@bitCast</span>(<span class="tok-type">usize</span>, -<span class="tok-builtin">@as</span>(<span class="tok-type">isize</span>, <span class="tok-builtin">@enumToInt</span>(E.INVAL))) =&gt; <span class="tok-kw">return</span> rc,</span>
<span class="line" id="L901">                <span class="tok-kw">else</span> =&gt; {},</span>
<span class="line" id="L902">            }</span>
<span class="line" id="L903">        }</span>
<span class="line" id="L904">    }</span>
<span class="line" id="L905">    <span class="tok-kw">return</span> syscall2(.clock_gettime, <span class="tok-builtin">@bitCast</span>(<span class="tok-type">usize</span>, <span class="tok-builtin">@as</span>(<span class="tok-type">isize</span>, clk_id)), <span class="tok-builtin">@ptrToInt</span>(tp));</span>
<span class="line" id="L906">}</span>
<span class="line" id="L907"></span>
<span class="line" id="L908"><span class="tok-kw">fn</span> <span class="tok-fn">init_vdso_clock_gettime</span>(clk: <span class="tok-type">i32</span>, ts: *timespec) <span class="tok-kw">callconv</span>(.C) <span class="tok-type">usize</span> {</span>
<span class="line" id="L909">    <span class="tok-kw">const</span> ptr = <span class="tok-builtin">@intToPtr</span>(?*<span class="tok-kw">const</span> <span class="tok-type">anyopaque</span>, vdso.lookup(VDSO.CGT_VER, VDSO.CGT_SYM));</span>
<span class="line" id="L910">    <span class="tok-comment">// Note that we may not have a VDSO at all, update the stub address anyway</span>
</span>
<span class="line" id="L911">    <span class="tok-comment">// so that clock_gettime will fall back on the good old (and slow) syscall</span>
</span>
<span class="line" id="L912">    <span class="tok-builtin">@atomicStore</span>(?*<span class="tok-kw">const</span> <span class="tok-type">anyopaque</span>, &amp;vdso_clock_gettime, ptr, .Monotonic);</span>
<span class="line" id="L913">    <span class="tok-comment">// Call into the VDSO if available</span>
</span>
<span class="line" id="L914">    <span class="tok-kw">if</span> (ptr) |fn_ptr| {</span>
<span class="line" id="L915">        <span class="tok-kw">const</span> f = <span class="tok-builtin">@ptrCast</span>(vdso_clock_gettime_ty, fn_ptr);</span>
<span class="line" id="L916">        <span class="tok-kw">return</span> f(clk, ts);</span>
<span class="line" id="L917">    }</span>
<span class="line" id="L918">    <span class="tok-kw">return</span> <span class="tok-builtin">@bitCast</span>(<span class="tok-type">usize</span>, -<span class="tok-builtin">@as</span>(<span class="tok-type">isize</span>, <span class="tok-builtin">@enumToInt</span>(E.NOSYS)));</span>
<span class="line" id="L919">}</span>
<span class="line" id="L920"></span>
<span class="line" id="L921"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">clock_getres</span>(clk_id: <span class="tok-type">i32</span>, tp: *timespec) <span class="tok-type">usize</span> {</span>
<span class="line" id="L922">    <span class="tok-kw">return</span> syscall2(.clock_getres, <span class="tok-builtin">@bitCast</span>(<span class="tok-type">usize</span>, <span class="tok-builtin">@as</span>(<span class="tok-type">isize</span>, clk_id)), <span class="tok-builtin">@ptrToInt</span>(tp));</span>
<span class="line" id="L923">}</span>
<span class="line" id="L924"></span>
<span class="line" id="L925"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">clock_settime</span>(clk_id: <span class="tok-type">i32</span>, tp: *<span class="tok-kw">const</span> timespec) <span class="tok-type">usize</span> {</span>
<span class="line" id="L926">    <span class="tok-kw">return</span> syscall2(.clock_settime, <span class="tok-builtin">@bitCast</span>(<span class="tok-type">usize</span>, <span class="tok-builtin">@as</span>(<span class="tok-type">isize</span>, clk_id)), <span class="tok-builtin">@ptrToInt</span>(tp));</span>
<span class="line" id="L927">}</span>
<span class="line" id="L928"></span>
<span class="line" id="L929"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">gettimeofday</span>(tv: *timeval, tz: *timezone) <span class="tok-type">usize</span> {</span>
<span class="line" id="L930">    <span class="tok-kw">return</span> syscall2(.gettimeofday, <span class="tok-builtin">@ptrToInt</span>(tv), <span class="tok-builtin">@ptrToInt</span>(tz));</span>
<span class="line" id="L931">}</span>
<span class="line" id="L932"></span>
<span class="line" id="L933"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">settimeofday</span>(tv: *<span class="tok-kw">const</span> timeval, tz: *<span class="tok-kw">const</span> timezone) <span class="tok-type">usize</span> {</span>
<span class="line" id="L934">    <span class="tok-kw">return</span> syscall2(.settimeofday, <span class="tok-builtin">@ptrToInt</span>(tv), <span class="tok-builtin">@ptrToInt</span>(tz));</span>
<span class="line" id="L935">}</span>
<span class="line" id="L936"></span>
<span class="line" id="L937"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">nanosleep</span>(req: *<span class="tok-kw">const</span> timespec, rem: ?*timespec) <span class="tok-type">usize</span> {</span>
<span class="line" id="L938">    <span class="tok-kw">return</span> syscall2(.nanosleep, <span class="tok-builtin">@ptrToInt</span>(req), <span class="tok-builtin">@ptrToInt</span>(rem));</span>
<span class="line" id="L939">}</span>
<span class="line" id="L940"></span>
<span class="line" id="L941"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">setuid</span>(uid: uid_t) <span class="tok-type">usize</span> {</span>
<span class="line" id="L942">    <span class="tok-kw">if</span> (<span class="tok-builtin">@hasField</span>(SYS, <span class="tok-str">&quot;setuid32&quot;</span>)) {</span>
<span class="line" id="L943">        <span class="tok-kw">return</span> syscall1(.setuid32, uid);</span>
<span class="line" id="L944">    } <span class="tok-kw">else</span> {</span>
<span class="line" id="L945">        <span class="tok-kw">return</span> syscall1(.setuid, uid);</span>
<span class="line" id="L946">    }</span>
<span class="line" id="L947">}</span>
<span class="line" id="L948"></span>
<span class="line" id="L949"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">setgid</span>(gid: gid_t) <span class="tok-type">usize</span> {</span>
<span class="line" id="L950">    <span class="tok-kw">if</span> (<span class="tok-builtin">@hasField</span>(SYS, <span class="tok-str">&quot;setgid32&quot;</span>)) {</span>
<span class="line" id="L951">        <span class="tok-kw">return</span> syscall1(.setgid32, gid);</span>
<span class="line" id="L952">    } <span class="tok-kw">else</span> {</span>
<span class="line" id="L953">        <span class="tok-kw">return</span> syscall1(.setgid, gid);</span>
<span class="line" id="L954">    }</span>
<span class="line" id="L955">}</span>
<span class="line" id="L956"></span>
<span class="line" id="L957"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">setreuid</span>(ruid: uid_t, euid: uid_t) <span class="tok-type">usize</span> {</span>
<span class="line" id="L958">    <span class="tok-kw">if</span> (<span class="tok-builtin">@hasField</span>(SYS, <span class="tok-str">&quot;setreuid32&quot;</span>)) {</span>
<span class="line" id="L959">        <span class="tok-kw">return</span> syscall2(.setreuid32, ruid, euid);</span>
<span class="line" id="L960">    } <span class="tok-kw">else</span> {</span>
<span class="line" id="L961">        <span class="tok-kw">return</span> syscall2(.setreuid, ruid, euid);</span>
<span class="line" id="L962">    }</span>
<span class="line" id="L963">}</span>
<span class="line" id="L964"></span>
<span class="line" id="L965"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">setregid</span>(rgid: gid_t, egid: gid_t) <span class="tok-type">usize</span> {</span>
<span class="line" id="L966">    <span class="tok-kw">if</span> (<span class="tok-builtin">@hasField</span>(SYS, <span class="tok-str">&quot;setregid32&quot;</span>)) {</span>
<span class="line" id="L967">        <span class="tok-kw">return</span> syscall2(.setregid32, rgid, egid);</span>
<span class="line" id="L968">    } <span class="tok-kw">else</span> {</span>
<span class="line" id="L969">        <span class="tok-kw">return</span> syscall2(.setregid, rgid, egid);</span>
<span class="line" id="L970">    }</span>
<span class="line" id="L971">}</span>
<span class="line" id="L972"></span>
<span class="line" id="L973"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">getuid</span>() uid_t {</span>
<span class="line" id="L974">    <span class="tok-kw">if</span> (<span class="tok-builtin">@hasField</span>(SYS, <span class="tok-str">&quot;getuid32&quot;</span>)) {</span>
<span class="line" id="L975">        <span class="tok-kw">return</span> <span class="tok-builtin">@intCast</span>(uid_t, syscall0(.getuid32));</span>
<span class="line" id="L976">    } <span class="tok-kw">else</span> {</span>
<span class="line" id="L977">        <span class="tok-kw">return</span> <span class="tok-builtin">@intCast</span>(uid_t, syscall0(.getuid));</span>
<span class="line" id="L978">    }</span>
<span class="line" id="L979">}</span>
<span class="line" id="L980"></span>
<span class="line" id="L981"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">getgid</span>() gid_t {</span>
<span class="line" id="L982">    <span class="tok-kw">if</span> (<span class="tok-builtin">@hasField</span>(SYS, <span class="tok-str">&quot;getgid32&quot;</span>)) {</span>
<span class="line" id="L983">        <span class="tok-kw">return</span> <span class="tok-builtin">@intCast</span>(gid_t, syscall0(.getgid32));</span>
<span class="line" id="L984">    } <span class="tok-kw">else</span> {</span>
<span class="line" id="L985">        <span class="tok-kw">return</span> <span class="tok-builtin">@intCast</span>(gid_t, syscall0(.getgid));</span>
<span class="line" id="L986">    }</span>
<span class="line" id="L987">}</span>
<span class="line" id="L988"></span>
<span class="line" id="L989"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">geteuid</span>() uid_t {</span>
<span class="line" id="L990">    <span class="tok-kw">if</span> (<span class="tok-builtin">@hasField</span>(SYS, <span class="tok-str">&quot;geteuid32&quot;</span>)) {</span>
<span class="line" id="L991">        <span class="tok-kw">return</span> <span class="tok-builtin">@intCast</span>(uid_t, syscall0(.geteuid32));</span>
<span class="line" id="L992">    } <span class="tok-kw">else</span> {</span>
<span class="line" id="L993">        <span class="tok-kw">return</span> <span class="tok-builtin">@intCast</span>(uid_t, syscall0(.geteuid));</span>
<span class="line" id="L994">    }</span>
<span class="line" id="L995">}</span>
<span class="line" id="L996"></span>
<span class="line" id="L997"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">getegid</span>() gid_t {</span>
<span class="line" id="L998">    <span class="tok-kw">if</span> (<span class="tok-builtin">@hasField</span>(SYS, <span class="tok-str">&quot;getegid32&quot;</span>)) {</span>
<span class="line" id="L999">        <span class="tok-kw">return</span> <span class="tok-builtin">@intCast</span>(gid_t, syscall0(.getegid32));</span>
<span class="line" id="L1000">    } <span class="tok-kw">else</span> {</span>
<span class="line" id="L1001">        <span class="tok-kw">return</span> <span class="tok-builtin">@intCast</span>(gid_t, syscall0(.getegid));</span>
<span class="line" id="L1002">    }</span>
<span class="line" id="L1003">}</span>
<span class="line" id="L1004"></span>
<span class="line" id="L1005"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">seteuid</span>(euid: uid_t) <span class="tok-type">usize</span> {</span>
<span class="line" id="L1006">    <span class="tok-comment">// We use setresuid here instead of setreuid to ensure that the saved uid</span>
</span>
<span class="line" id="L1007">    <span class="tok-comment">// is not changed. This is what musl and recent glibc versions do as well.</span>
</span>
<span class="line" id="L1008">    <span class="tok-comment">//</span>
</span>
<span class="line" id="L1009">    <span class="tok-comment">// The setresuid(2) man page says that if -1 is passed the corresponding</span>
</span>
<span class="line" id="L1010">    <span class="tok-comment">// id will not be changed. Since uid_t is unsigned, this wraps around to the</span>
</span>
<span class="line" id="L1011">    <span class="tok-comment">// max value in C.</span>
</span>
<span class="line" id="L1012">    <span class="tok-kw">comptime</span> assert(<span class="tok-builtin">@typeInfo</span>(uid_t) == .Int <span class="tok-kw">and</span> <span class="tok-builtin">@typeInfo</span>(uid_t).Int.signedness == .unsigned);</span>
<span class="line" id="L1013">    <span class="tok-kw">return</span> setresuid(std.math.maxInt(uid_t), euid, std.math.maxInt(uid_t));</span>
<span class="line" id="L1014">}</span>
<span class="line" id="L1015"></span>
<span class="line" id="L1016"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">setegid</span>(egid: gid_t) <span class="tok-type">usize</span> {</span>
<span class="line" id="L1017">    <span class="tok-comment">// We use setresgid here instead of setregid to ensure that the saved uid</span>
</span>
<span class="line" id="L1018">    <span class="tok-comment">// is not changed. This is what musl and recent glibc versions do as well.</span>
</span>
<span class="line" id="L1019">    <span class="tok-comment">//</span>
</span>
<span class="line" id="L1020">    <span class="tok-comment">// The setresgid(2) man page says that if -1 is passed the corresponding</span>
</span>
<span class="line" id="L1021">    <span class="tok-comment">// id will not be changed. Since gid_t is unsigned, this wraps around to the</span>
</span>
<span class="line" id="L1022">    <span class="tok-comment">// max value in C.</span>
</span>
<span class="line" id="L1023">    <span class="tok-kw">comptime</span> assert(<span class="tok-builtin">@typeInfo</span>(uid_t) == .Int <span class="tok-kw">and</span> <span class="tok-builtin">@typeInfo</span>(uid_t).Int.signedness == .unsigned);</span>
<span class="line" id="L1024">    <span class="tok-kw">return</span> setresgid(std.math.maxInt(gid_t), egid, std.math.maxInt(gid_t));</span>
<span class="line" id="L1025">}</span>
<span class="line" id="L1026"></span>
<span class="line" id="L1027"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">getresuid</span>(ruid: *uid_t, euid: *uid_t, suid: *uid_t) <span class="tok-type">usize</span> {</span>
<span class="line" id="L1028">    <span class="tok-kw">if</span> (<span class="tok-builtin">@hasField</span>(SYS, <span class="tok-str">&quot;getresuid32&quot;</span>)) {</span>
<span class="line" id="L1029">        <span class="tok-kw">return</span> syscall3(.getresuid32, <span class="tok-builtin">@ptrToInt</span>(ruid), <span class="tok-builtin">@ptrToInt</span>(euid), <span class="tok-builtin">@ptrToInt</span>(suid));</span>
<span class="line" id="L1030">    } <span class="tok-kw">else</span> {</span>
<span class="line" id="L1031">        <span class="tok-kw">return</span> syscall3(.getresuid, <span class="tok-builtin">@ptrToInt</span>(ruid), <span class="tok-builtin">@ptrToInt</span>(euid), <span class="tok-builtin">@ptrToInt</span>(suid));</span>
<span class="line" id="L1032">    }</span>
<span class="line" id="L1033">}</span>
<span class="line" id="L1034"></span>
<span class="line" id="L1035"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">getresgid</span>(rgid: *gid_t, egid: *gid_t, sgid: *gid_t) <span class="tok-type">usize</span> {</span>
<span class="line" id="L1036">    <span class="tok-kw">if</span> (<span class="tok-builtin">@hasField</span>(SYS, <span class="tok-str">&quot;getresgid32&quot;</span>)) {</span>
<span class="line" id="L1037">        <span class="tok-kw">return</span> syscall3(.getresgid32, <span class="tok-builtin">@ptrToInt</span>(rgid), <span class="tok-builtin">@ptrToInt</span>(egid), <span class="tok-builtin">@ptrToInt</span>(sgid));</span>
<span class="line" id="L1038">    } <span class="tok-kw">else</span> {</span>
<span class="line" id="L1039">        <span class="tok-kw">return</span> syscall3(.getresgid, <span class="tok-builtin">@ptrToInt</span>(rgid), <span class="tok-builtin">@ptrToInt</span>(egid), <span class="tok-builtin">@ptrToInt</span>(sgid));</span>
<span class="line" id="L1040">    }</span>
<span class="line" id="L1041">}</span>
<span class="line" id="L1042"></span>
<span class="line" id="L1043"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">setresuid</span>(ruid: uid_t, euid: uid_t, suid: uid_t) <span class="tok-type">usize</span> {</span>
<span class="line" id="L1044">    <span class="tok-kw">if</span> (<span class="tok-builtin">@hasField</span>(SYS, <span class="tok-str">&quot;setresuid32&quot;</span>)) {</span>
<span class="line" id="L1045">        <span class="tok-kw">return</span> syscall3(.setresuid32, ruid, euid, suid);</span>
<span class="line" id="L1046">    } <span class="tok-kw">else</span> {</span>
<span class="line" id="L1047">        <span class="tok-kw">return</span> syscall3(.setresuid, ruid, euid, suid);</span>
<span class="line" id="L1048">    }</span>
<span class="line" id="L1049">}</span>
<span class="line" id="L1050"></span>
<span class="line" id="L1051"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">setresgid</span>(rgid: gid_t, egid: gid_t, sgid: gid_t) <span class="tok-type">usize</span> {</span>
<span class="line" id="L1052">    <span class="tok-kw">if</span> (<span class="tok-builtin">@hasField</span>(SYS, <span class="tok-str">&quot;setresgid32&quot;</span>)) {</span>
<span class="line" id="L1053">        <span class="tok-kw">return</span> syscall3(.setresgid32, rgid, egid, sgid);</span>
<span class="line" id="L1054">    } <span class="tok-kw">else</span> {</span>
<span class="line" id="L1055">        <span class="tok-kw">return</span> syscall3(.setresgid, rgid, egid, sgid);</span>
<span class="line" id="L1056">    }</span>
<span class="line" id="L1057">}</span>
<span class="line" id="L1058"></span>
<span class="line" id="L1059"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">getgroups</span>(size: <span class="tok-type">usize</span>, list: *gid_t) <span class="tok-type">usize</span> {</span>
<span class="line" id="L1060">    <span class="tok-kw">if</span> (<span class="tok-builtin">@hasField</span>(SYS, <span class="tok-str">&quot;getgroups32&quot;</span>)) {</span>
<span class="line" id="L1061">        <span class="tok-kw">return</span> syscall2(.getgroups32, size, <span class="tok-builtin">@ptrToInt</span>(list));</span>
<span class="line" id="L1062">    } <span class="tok-kw">else</span> {</span>
<span class="line" id="L1063">        <span class="tok-kw">return</span> syscall2(.getgroups, size, <span class="tok-builtin">@ptrToInt</span>(list));</span>
<span class="line" id="L1064">    }</span>
<span class="line" id="L1065">}</span>
<span class="line" id="L1066"></span>
<span class="line" id="L1067"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">setgroups</span>(size: <span class="tok-type">usize</span>, list: [*]<span class="tok-kw">const</span> gid_t) <span class="tok-type">usize</span> {</span>
<span class="line" id="L1068">    <span class="tok-kw">if</span> (<span class="tok-builtin">@hasField</span>(SYS, <span class="tok-str">&quot;setgroups32&quot;</span>)) {</span>
<span class="line" id="L1069">        <span class="tok-kw">return</span> syscall2(.setgroups32, size, <span class="tok-builtin">@ptrToInt</span>(list));</span>
<span class="line" id="L1070">    } <span class="tok-kw">else</span> {</span>
<span class="line" id="L1071">        <span class="tok-kw">return</span> syscall2(.setgroups, size, <span class="tok-builtin">@ptrToInt</span>(list));</span>
<span class="line" id="L1072">    }</span>
<span class="line" id="L1073">}</span>
<span class="line" id="L1074"></span>
<span class="line" id="L1075"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">getpid</span>() pid_t {</span>
<span class="line" id="L1076">    <span class="tok-kw">return</span> <span class="tok-builtin">@bitCast</span>(pid_t, <span class="tok-builtin">@truncate</span>(<span class="tok-type">u32</span>, syscall0(.getpid)));</span>
<span class="line" id="L1077">}</span>
<span class="line" id="L1078"></span>
<span class="line" id="L1079"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">gettid</span>() pid_t {</span>
<span class="line" id="L1080">    <span class="tok-kw">return</span> <span class="tok-builtin">@bitCast</span>(pid_t, <span class="tok-builtin">@truncate</span>(<span class="tok-type">u32</span>, syscall0(.gettid)));</span>
<span class="line" id="L1081">}</span>
<span class="line" id="L1082"></span>
<span class="line" id="L1083"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">sigprocmask</span>(flags: <span class="tok-type">u32</span>, <span class="tok-kw">noalias</span> set: ?*<span class="tok-kw">const</span> sigset_t, <span class="tok-kw">noalias</span> oldset: ?*sigset_t) <span class="tok-type">usize</span> {</span>
<span class="line" id="L1084">    <span class="tok-kw">return</span> syscall4(.rt_sigprocmask, flags, <span class="tok-builtin">@ptrToInt</span>(set), <span class="tok-builtin">@ptrToInt</span>(oldset), NSIG / <span class="tok-number">8</span>);</span>
<span class="line" id="L1085">}</span>
<span class="line" id="L1086"></span>
<span class="line" id="L1087"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">sigaction</span>(sig: <span class="tok-type">u6</span>, <span class="tok-kw">noalias</span> act: ?*<span class="tok-kw">const</span> Sigaction, <span class="tok-kw">noalias</span> oact: ?*Sigaction) <span class="tok-type">usize</span> {</span>
<span class="line" id="L1088">    assert(sig &gt;= <span class="tok-number">1</span>);</span>
<span class="line" id="L1089">    assert(sig != SIG.KILL);</span>
<span class="line" id="L1090">    assert(sig != SIG.STOP);</span>
<span class="line" id="L1091"></span>
<span class="line" id="L1092">    <span class="tok-kw">var</span> ksa: k_sigaction = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L1093">    <span class="tok-kw">var</span> oldksa: k_sigaction = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L1094">    <span class="tok-kw">const</span> mask_size = <span class="tok-builtin">@sizeOf</span>(<span class="tok-builtin">@TypeOf</span>(ksa.mask));</span>
<span class="line" id="L1095"></span>
<span class="line" id="L1096">    <span class="tok-kw">if</span> (act) |new| {</span>
<span class="line" id="L1097">        <span class="tok-kw">const</span> restore_rt_ptr = <span class="tok-kw">if</span> (builtin.zig_backend == .stage1) restore_rt <span class="tok-kw">else</span> &amp;restore_rt;</span>
<span class="line" id="L1098">        <span class="tok-kw">const</span> restore_ptr = <span class="tok-kw">if</span> (builtin.zig_backend == .stage1) restore <span class="tok-kw">else</span> &amp;restore;</span>
<span class="line" id="L1099">        <span class="tok-kw">const</span> restorer_fn = <span class="tok-kw">if</span> ((new.flags &amp; SA.SIGINFO) != <span class="tok-number">0</span>) restore_rt_ptr <span class="tok-kw">else</span> restore_ptr;</span>
<span class="line" id="L1100">        ksa = k_sigaction{</span>
<span class="line" id="L1101">            .handler = new.handler.handler,</span>
<span class="line" id="L1102">            .flags = new.flags | SA.RESTORER,</span>
<span class="line" id="L1103">            .mask = <span class="tok-null">undefined</span>,</span>
<span class="line" id="L1104">            .restorer = <span class="tok-builtin">@ptrCast</span>(k_sigaction_funcs.restorer, restorer_fn),</span>
<span class="line" id="L1105">        };</span>
<span class="line" id="L1106">        <span class="tok-builtin">@memcpy</span>(<span class="tok-builtin">@ptrCast</span>([*]<span class="tok-type">u8</span>, &amp;ksa.mask), <span class="tok-builtin">@ptrCast</span>([*]<span class="tok-kw">const</span> <span class="tok-type">u8</span>, &amp;new.mask), mask_size);</span>
<span class="line" id="L1107">    }</span>
<span class="line" id="L1108"></span>
<span class="line" id="L1109">    <span class="tok-kw">const</span> ksa_arg = <span class="tok-kw">if</span> (act != <span class="tok-null">null</span>) <span class="tok-builtin">@ptrToInt</span>(&amp;ksa) <span class="tok-kw">else</span> <span class="tok-number">0</span>;</span>
<span class="line" id="L1110">    <span class="tok-kw">const</span> oldksa_arg = <span class="tok-kw">if</span> (oact != <span class="tok-null">null</span>) <span class="tok-builtin">@ptrToInt</span>(&amp;oldksa) <span class="tok-kw">else</span> <span class="tok-number">0</span>;</span>
<span class="line" id="L1111"></span>
<span class="line" id="L1112">    <span class="tok-kw">const</span> result = <span class="tok-kw">switch</span> (native_arch) {</span>
<span class="line" id="L1113">        <span class="tok-comment">// The sparc version of rt_sigaction needs the restorer function to be passed as an argument too.</span>
</span>
<span class="line" id="L1114">        .sparc, .sparc64 =&gt; syscall5(.rt_sigaction, sig, ksa_arg, oldksa_arg, <span class="tok-builtin">@ptrToInt</span>(ksa.restorer), mask_size),</span>
<span class="line" id="L1115">        <span class="tok-kw">else</span> =&gt; syscall4(.rt_sigaction, sig, ksa_arg, oldksa_arg, mask_size),</span>
<span class="line" id="L1116">    };</span>
<span class="line" id="L1117">    <span class="tok-kw">if</span> (getErrno(result) != .SUCCESS) <span class="tok-kw">return</span> result;</span>
<span class="line" id="L1118"></span>
<span class="line" id="L1119">    <span class="tok-kw">if</span> (oact) |old| {</span>
<span class="line" id="L1120">        old.handler.handler = oldksa.handler;</span>
<span class="line" id="L1121">        old.flags = <span class="tok-builtin">@truncate</span>(<span class="tok-type">c_uint</span>, oldksa.flags);</span>
<span class="line" id="L1122">        <span class="tok-builtin">@memcpy</span>(<span class="tok-builtin">@ptrCast</span>([*]<span class="tok-type">u8</span>, &amp;old.mask), <span class="tok-builtin">@ptrCast</span>([*]<span class="tok-kw">const</span> <span class="tok-type">u8</span>, &amp;oldksa.mask), mask_size);</span>
<span class="line" id="L1123">    }</span>
<span class="line" id="L1124"></span>
<span class="line" id="L1125">    <span class="tok-kw">return</span> <span class="tok-number">0</span>;</span>
<span class="line" id="L1126">}</span>
<span class="line" id="L1127"></span>
<span class="line" id="L1128"><span class="tok-kw">const</span> usize_bits = <span class="tok-builtin">@typeInfo</span>(<span class="tok-type">usize</span>).Int.bits;</span>
<span class="line" id="L1129"></span>
<span class="line" id="L1130"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">sigaddset</span>(set: *sigset_t, sig: <span class="tok-type">u6</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L1131">    <span class="tok-kw">const</span> s = sig - <span class="tok-number">1</span>;</span>
<span class="line" id="L1132">    <span class="tok-comment">// shift in musl: s&amp;8*sizeof *set-&gt;__bits-1</span>
</span>
<span class="line" id="L1133">    <span class="tok-kw">const</span> shift = <span class="tok-builtin">@intCast</span>(<span class="tok-type">u5</span>, s &amp; (usize_bits - <span class="tok-number">1</span>));</span>
<span class="line" id="L1134">    <span class="tok-kw">const</span> val = <span class="tok-builtin">@intCast</span>(<span class="tok-type">u32</span>, <span class="tok-number">1</span>) &lt;&lt; shift;</span>
<span class="line" id="L1135">    (set.*)[<span class="tok-builtin">@intCast</span>(<span class="tok-type">usize</span>, s) / usize_bits] |= val;</span>
<span class="line" id="L1136">}</span>
<span class="line" id="L1137"></span>
<span class="line" id="L1138"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">sigismember</span>(set: *<span class="tok-kw">const</span> sigset_t, sig: <span class="tok-type">u6</span>) <span class="tok-type">bool</span> {</span>
<span class="line" id="L1139">    <span class="tok-kw">const</span> s = sig - <span class="tok-number">1</span>;</span>
<span class="line" id="L1140">    <span class="tok-kw">return</span> ((set.*)[<span class="tok-builtin">@intCast</span>(<span class="tok-type">usize</span>, s) / usize_bits] &amp; (<span class="tok-builtin">@intCast</span>(<span class="tok-type">usize</span>, <span class="tok-number">1</span>) &lt;&lt; (s &amp; (usize_bits - <span class="tok-number">1</span>)))) != <span class="tok-number">0</span>;</span>
<span class="line" id="L1141">}</span>
<span class="line" id="L1142"></span>
<span class="line" id="L1143"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">getsockname</span>(fd: <span class="tok-type">i32</span>, <span class="tok-kw">noalias</span> addr: *sockaddr, <span class="tok-kw">noalias</span> len: *socklen_t) <span class="tok-type">usize</span> {</span>
<span class="line" id="L1144">    <span class="tok-kw">if</span> (native_arch == .<span class="tok-type">i386</span>) {</span>
<span class="line" id="L1145">        <span class="tok-kw">return</span> socketcall(SC.getsockname, &amp;[<span class="tok-number">3</span>]<span class="tok-type">usize</span>{ <span class="tok-builtin">@bitCast</span>(<span class="tok-type">usize</span>, <span class="tok-builtin">@as</span>(<span class="tok-type">isize</span>, fd)), <span class="tok-builtin">@ptrToInt</span>(addr), <span class="tok-builtin">@ptrToInt</span>(len) });</span>
<span class="line" id="L1146">    }</span>
<span class="line" id="L1147">    <span class="tok-kw">return</span> syscall3(.getsockname, <span class="tok-builtin">@bitCast</span>(<span class="tok-type">usize</span>, <span class="tok-builtin">@as</span>(<span class="tok-type">isize</span>, fd)), <span class="tok-builtin">@ptrToInt</span>(addr), <span class="tok-builtin">@ptrToInt</span>(len));</span>
<span class="line" id="L1148">}</span>
<span class="line" id="L1149"></span>
<span class="line" id="L1150"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">getpeername</span>(fd: <span class="tok-type">i32</span>, <span class="tok-kw">noalias</span> addr: *sockaddr, <span class="tok-kw">noalias</span> len: *socklen_t) <span class="tok-type">usize</span> {</span>
<span class="line" id="L1151">    <span class="tok-kw">if</span> (native_arch == .<span class="tok-type">i386</span>) {</span>
<span class="line" id="L1152">        <span class="tok-kw">return</span> socketcall(SC.getpeername, &amp;[<span class="tok-number">3</span>]<span class="tok-type">usize</span>{ <span class="tok-builtin">@bitCast</span>(<span class="tok-type">usize</span>, <span class="tok-builtin">@as</span>(<span class="tok-type">isize</span>, fd)), <span class="tok-builtin">@ptrToInt</span>(addr), <span class="tok-builtin">@ptrToInt</span>(len) });</span>
<span class="line" id="L1153">    }</span>
<span class="line" id="L1154">    <span class="tok-kw">return</span> syscall3(.getpeername, <span class="tok-builtin">@bitCast</span>(<span class="tok-type">usize</span>, <span class="tok-builtin">@as</span>(<span class="tok-type">isize</span>, fd)), <span class="tok-builtin">@ptrToInt</span>(addr), <span class="tok-builtin">@ptrToInt</span>(len));</span>
<span class="line" id="L1155">}</span>
<span class="line" id="L1156"></span>
<span class="line" id="L1157"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">socket</span>(domain: <span class="tok-type">u32</span>, socket_type: <span class="tok-type">u32</span>, protocol: <span class="tok-type">u32</span>) <span class="tok-type">usize</span> {</span>
<span class="line" id="L1158">    <span class="tok-kw">if</span> (native_arch == .<span class="tok-type">i386</span>) {</span>
<span class="line" id="L1159">        <span class="tok-kw">return</span> socketcall(SC.socket, &amp;[<span class="tok-number">3</span>]<span class="tok-type">usize</span>{ domain, socket_type, protocol });</span>
<span class="line" id="L1160">    }</span>
<span class="line" id="L1161">    <span class="tok-kw">return</span> syscall3(.socket, domain, socket_type, protocol);</span>
<span class="line" id="L1162">}</span>
<span class="line" id="L1163"></span>
<span class="line" id="L1164"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">setsockopt</span>(fd: <span class="tok-type">i32</span>, level: <span class="tok-type">u32</span>, optname: <span class="tok-type">u32</span>, optval: [*]<span class="tok-kw">const</span> <span class="tok-type">u8</span>, optlen: socklen_t) <span class="tok-type">usize</span> {</span>
<span class="line" id="L1165">    <span class="tok-kw">if</span> (native_arch == .<span class="tok-type">i386</span>) {</span>
<span class="line" id="L1166">        <span class="tok-kw">return</span> socketcall(SC.setsockopt, &amp;[<span class="tok-number">5</span>]<span class="tok-type">usize</span>{ <span class="tok-builtin">@bitCast</span>(<span class="tok-type">usize</span>, <span class="tok-builtin">@as</span>(<span class="tok-type">isize</span>, fd)), level, optname, <span class="tok-builtin">@ptrToInt</span>(optval), <span class="tok-builtin">@intCast</span>(<span class="tok-type">usize</span>, optlen) });</span>
<span class="line" id="L1167">    }</span>
<span class="line" id="L1168">    <span class="tok-kw">return</span> syscall5(.setsockopt, <span class="tok-builtin">@bitCast</span>(<span class="tok-type">usize</span>, <span class="tok-builtin">@as</span>(<span class="tok-type">isize</span>, fd)), level, optname, <span class="tok-builtin">@ptrToInt</span>(optval), <span class="tok-builtin">@intCast</span>(<span class="tok-type">usize</span>, optlen));</span>
<span class="line" id="L1169">}</span>
<span class="line" id="L1170"></span>
<span class="line" id="L1171"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">getsockopt</span>(fd: <span class="tok-type">i32</span>, level: <span class="tok-type">u32</span>, optname: <span class="tok-type">u32</span>, <span class="tok-kw">noalias</span> optval: [*]<span class="tok-type">u8</span>, <span class="tok-kw">noalias</span> optlen: *socklen_t) <span class="tok-type">usize</span> {</span>
<span class="line" id="L1172">    <span class="tok-kw">if</span> (native_arch == .<span class="tok-type">i386</span>) {</span>
<span class="line" id="L1173">        <span class="tok-kw">return</span> socketcall(SC.getsockopt, &amp;[<span class="tok-number">5</span>]<span class="tok-type">usize</span>{ <span class="tok-builtin">@bitCast</span>(<span class="tok-type">usize</span>, <span class="tok-builtin">@as</span>(<span class="tok-type">isize</span>, fd)), level, optname, <span class="tok-builtin">@ptrToInt</span>(optval), <span class="tok-builtin">@ptrToInt</span>(optlen) });</span>
<span class="line" id="L1174">    }</span>
<span class="line" id="L1175">    <span class="tok-kw">return</span> syscall5(.getsockopt, <span class="tok-builtin">@bitCast</span>(<span class="tok-type">usize</span>, <span class="tok-builtin">@as</span>(<span class="tok-type">isize</span>, fd)), level, optname, <span class="tok-builtin">@ptrToInt</span>(optval), <span class="tok-builtin">@ptrToInt</span>(optlen));</span>
<span class="line" id="L1176">}</span>
<span class="line" id="L1177"></span>
<span class="line" id="L1178"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">sendmsg</span>(fd: <span class="tok-type">i32</span>, msg: *<span class="tok-kw">const</span> std.x.os.Socket.Message, flags: <span class="tok-type">c_int</span>) <span class="tok-type">usize</span> {</span>
<span class="line" id="L1179">    <span class="tok-kw">if</span> (native_arch == .<span class="tok-type">i386</span>) {</span>
<span class="line" id="L1180">        <span class="tok-kw">return</span> socketcall(SC.sendmsg, &amp;[<span class="tok-number">3</span>]<span class="tok-type">usize</span>{ <span class="tok-builtin">@bitCast</span>(<span class="tok-type">usize</span>, <span class="tok-builtin">@as</span>(<span class="tok-type">isize</span>, fd)), <span class="tok-builtin">@ptrToInt</span>(msg), <span class="tok-builtin">@bitCast</span>(<span class="tok-type">usize</span>, <span class="tok-builtin">@as</span>(<span class="tok-type">isize</span>, flags)) });</span>
<span class="line" id="L1181">    }</span>
<span class="line" id="L1182">    <span class="tok-kw">return</span> syscall3(.sendmsg, <span class="tok-builtin">@bitCast</span>(<span class="tok-type">usize</span>, <span class="tok-builtin">@as</span>(<span class="tok-type">isize</span>, fd)), <span class="tok-builtin">@ptrToInt</span>(msg), <span class="tok-builtin">@bitCast</span>(<span class="tok-type">usize</span>, <span class="tok-builtin">@as</span>(<span class="tok-type">isize</span>, flags)));</span>
<span class="line" id="L1183">}</span>
<span class="line" id="L1184"></span>
<span class="line" id="L1185"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">sendmmsg</span>(fd: <span class="tok-type">i32</span>, msgvec: [*]mmsghdr_const, vlen: <span class="tok-type">u32</span>, flags: <span class="tok-type">u32</span>) <span class="tok-type">usize</span> {</span>
<span class="line" id="L1186">    <span class="tok-kw">if</span> (<span class="tok-builtin">@typeInfo</span>(<span class="tok-type">usize</span>).Int.bits &gt; <span class="tok-builtin">@typeInfo</span>(<span class="tok-builtin">@TypeOf</span>(mmsghdr(<span class="tok-null">undefined</span>).msg_len)).Int.bits) {</span>
<span class="line" id="L1187">        <span class="tok-comment">// workaround kernel brokenness:</span>
</span>
<span class="line" id="L1188">        <span class="tok-comment">// if adding up all iov_len overflows a i32 then split into multiple calls</span>
</span>
<span class="line" id="L1189">        <span class="tok-comment">// see https://www.openwall.com/lists/musl/2014/06/07/5</span>
</span>
<span class="line" id="L1190">        <span class="tok-kw">const</span> kvlen = <span class="tok-kw">if</span> (vlen &gt; IOV_MAX) IOV_MAX <span class="tok-kw">else</span> vlen; <span class="tok-comment">// matches kernel</span>
</span>
<span class="line" id="L1191">        <span class="tok-kw">var</span> next_unsent: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L1192">        <span class="tok-kw">for</span> (msgvec[<span class="tok-number">0</span>..kvlen]) |*msg, i| {</span>
<span class="line" id="L1193">            <span class="tok-kw">var</span> size: <span class="tok-type">i32</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L1194">            <span class="tok-kw">const</span> msg_iovlen = <span class="tok-builtin">@intCast</span>(<span class="tok-type">usize</span>, msg.msg_hdr.msg_iovlen); <span class="tok-comment">// kernel side this is treated as unsigned</span>
</span>
<span class="line" id="L1195">            <span class="tok-kw">for</span> (msg.msg_hdr.msg_iov[<span class="tok-number">0</span>..msg_iovlen]) |iov| {</span>
<span class="line" id="L1196">                <span class="tok-kw">if</span> (iov.iov_len &gt; std.math.maxInt(<span class="tok-type">i32</span>) <span class="tok-kw">or</span> <span class="tok-builtin">@addWithOverflow</span>(<span class="tok-type">i32</span>, size, <span class="tok-builtin">@intCast</span>(<span class="tok-type">i32</span>, iov.iov_len), &amp;size)) {</span>
<span class="line" id="L1197">                    <span class="tok-comment">// batch-send all messages up to the current message</span>
</span>
<span class="line" id="L1198">                    <span class="tok-kw">if</span> (next_unsent &lt; i) {</span>
<span class="line" id="L1199">                        <span class="tok-kw">const</span> batch_size = i - next_unsent;</span>
<span class="line" id="L1200">                        <span class="tok-kw">const</span> r = syscall4(.sendmmsg, <span class="tok-builtin">@bitCast</span>(<span class="tok-type">usize</span>, <span class="tok-builtin">@as</span>(<span class="tok-type">isize</span>, fd)), <span class="tok-builtin">@ptrToInt</span>(&amp;msgvec[next_unsent]), batch_size, flags);</span>
<span class="line" id="L1201">                        <span class="tok-kw">if</span> (getErrno(r) != <span class="tok-number">0</span>) <span class="tok-kw">return</span> next_unsent;</span>
<span class="line" id="L1202">                        <span class="tok-kw">if</span> (r &lt; batch_size) <span class="tok-kw">return</span> next_unsent + r;</span>
<span class="line" id="L1203">                    }</span>
<span class="line" id="L1204">                    <span class="tok-comment">// send current message as own packet</span>
</span>
<span class="line" id="L1205">                    <span class="tok-kw">const</span> r = sendmsg(fd, &amp;msg.msg_hdr, flags);</span>
<span class="line" id="L1206">                    <span class="tok-kw">if</span> (getErrno(r) != <span class="tok-number">0</span>) <span class="tok-kw">return</span> r;</span>
<span class="line" id="L1207">                    <span class="tok-comment">// Linux limits the total bytes sent by sendmsg to INT_MAX, so this cast is safe.</span>
</span>
<span class="line" id="L1208">                    msg.msg_len = <span class="tok-builtin">@intCast</span>(<span class="tok-type">u32</span>, r);</span>
<span class="line" id="L1209">                    next_unsent = i + <span class="tok-number">1</span>;</span>
<span class="line" id="L1210">                    <span class="tok-kw">break</span>;</span>
<span class="line" id="L1211">                }</span>
<span class="line" id="L1212">            }</span>
<span class="line" id="L1213">        }</span>
<span class="line" id="L1214">        <span class="tok-kw">if</span> (next_unsent &lt; kvlen <span class="tok-kw">or</span> next_unsent == <span class="tok-number">0</span>) { <span class="tok-comment">// want to make sure at least one syscall occurs (e.g. to trigger MSG.EOR)</span>
</span>
<span class="line" id="L1215">            <span class="tok-kw">const</span> batch_size = kvlen - next_unsent;</span>
<span class="line" id="L1216">            <span class="tok-kw">const</span> r = syscall4(.sendmmsg, <span class="tok-builtin">@bitCast</span>(<span class="tok-type">usize</span>, <span class="tok-builtin">@as</span>(<span class="tok-type">isize</span>, fd)), <span class="tok-builtin">@ptrToInt</span>(&amp;msgvec[next_unsent]), batch_size, flags);</span>
<span class="line" id="L1217">            <span class="tok-kw">if</span> (getErrno(r) != <span class="tok-number">0</span>) <span class="tok-kw">return</span> r;</span>
<span class="line" id="L1218">            <span class="tok-kw">return</span> next_unsent + r;</span>
<span class="line" id="L1219">        }</span>
<span class="line" id="L1220">        <span class="tok-kw">return</span> kvlen;</span>
<span class="line" id="L1221">    }</span>
<span class="line" id="L1222">    <span class="tok-kw">return</span> syscall4(.sendmmsg, <span class="tok-builtin">@bitCast</span>(<span class="tok-type">usize</span>, <span class="tok-builtin">@as</span>(<span class="tok-type">isize</span>, fd)), <span class="tok-builtin">@ptrToInt</span>(msgvec), vlen, flags);</span>
<span class="line" id="L1223">}</span>
<span class="line" id="L1224"></span>
<span class="line" id="L1225"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">connect</span>(fd: <span class="tok-type">i32</span>, addr: *<span class="tok-kw">const</span> <span class="tok-type">anyopaque</span>, len: socklen_t) <span class="tok-type">usize</span> {</span>
<span class="line" id="L1226">    <span class="tok-kw">if</span> (native_arch == .<span class="tok-type">i386</span>) {</span>
<span class="line" id="L1227">        <span class="tok-kw">return</span> socketcall(SC.connect, &amp;[<span class="tok-number">3</span>]<span class="tok-type">usize</span>{ <span class="tok-builtin">@bitCast</span>(<span class="tok-type">usize</span>, <span class="tok-builtin">@as</span>(<span class="tok-type">isize</span>, fd)), <span class="tok-builtin">@ptrToInt</span>(addr), len });</span>
<span class="line" id="L1228">    }</span>
<span class="line" id="L1229">    <span class="tok-kw">return</span> syscall3(.connect, <span class="tok-builtin">@bitCast</span>(<span class="tok-type">usize</span>, <span class="tok-builtin">@as</span>(<span class="tok-type">isize</span>, fd)), <span class="tok-builtin">@ptrToInt</span>(addr), len);</span>
<span class="line" id="L1230">}</span>
<span class="line" id="L1231"></span>
<span class="line" id="L1232"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">recvmsg</span>(fd: <span class="tok-type">i32</span>, msg: *std.x.os.Socket.Message, flags: <span class="tok-type">c_int</span>) <span class="tok-type">usize</span> {</span>
<span class="line" id="L1233">    <span class="tok-kw">if</span> (native_arch == .<span class="tok-type">i386</span>) {</span>
<span class="line" id="L1234">        <span class="tok-kw">return</span> socketcall(SC.recvmsg, &amp;[<span class="tok-number">3</span>]<span class="tok-type">usize</span>{ <span class="tok-builtin">@bitCast</span>(<span class="tok-type">usize</span>, <span class="tok-builtin">@as</span>(<span class="tok-type">isize</span>, fd)), <span class="tok-builtin">@ptrToInt</span>(msg), <span class="tok-builtin">@bitCast</span>(<span class="tok-type">usize</span>, <span class="tok-builtin">@as</span>(<span class="tok-type">isize</span>, flags)) });</span>
<span class="line" id="L1235">    }</span>
<span class="line" id="L1236">    <span class="tok-kw">return</span> syscall3(.recvmsg, <span class="tok-builtin">@bitCast</span>(<span class="tok-type">usize</span>, <span class="tok-builtin">@as</span>(<span class="tok-type">isize</span>, fd)), <span class="tok-builtin">@ptrToInt</span>(msg), <span class="tok-builtin">@bitCast</span>(<span class="tok-type">usize</span>, <span class="tok-builtin">@as</span>(<span class="tok-type">isize</span>, flags)));</span>
<span class="line" id="L1237">}</span>
<span class="line" id="L1238"></span>
<span class="line" id="L1239"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">recvfrom</span>(fd: <span class="tok-type">i32</span>, <span class="tok-kw">noalias</span> buf: [*]<span class="tok-type">u8</span>, len: <span class="tok-type">usize</span>, flags: <span class="tok-type">u32</span>, <span class="tok-kw">noalias</span> addr: ?*sockaddr, <span class="tok-kw">noalias</span> alen: ?*socklen_t) <span class="tok-type">usize</span> {</span>
<span class="line" id="L1240">    <span class="tok-kw">if</span> (native_arch == .<span class="tok-type">i386</span>) {</span>
<span class="line" id="L1241">        <span class="tok-kw">return</span> socketcall(SC.recvfrom, &amp;[<span class="tok-number">6</span>]<span class="tok-type">usize</span>{ <span class="tok-builtin">@bitCast</span>(<span class="tok-type">usize</span>, <span class="tok-builtin">@as</span>(<span class="tok-type">isize</span>, fd)), <span class="tok-builtin">@ptrToInt</span>(buf), len, flags, <span class="tok-builtin">@ptrToInt</span>(addr), <span class="tok-builtin">@ptrToInt</span>(alen) });</span>
<span class="line" id="L1242">    }</span>
<span class="line" id="L1243">    <span class="tok-kw">return</span> syscall6(.recvfrom, <span class="tok-builtin">@bitCast</span>(<span class="tok-type">usize</span>, <span class="tok-builtin">@as</span>(<span class="tok-type">isize</span>, fd)), <span class="tok-builtin">@ptrToInt</span>(buf), len, flags, <span class="tok-builtin">@ptrToInt</span>(addr), <span class="tok-builtin">@ptrToInt</span>(alen));</span>
<span class="line" id="L1244">}</span>
<span class="line" id="L1245"></span>
<span class="line" id="L1246"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">shutdown</span>(fd: <span class="tok-type">i32</span>, how: <span class="tok-type">i32</span>) <span class="tok-type">usize</span> {</span>
<span class="line" id="L1247">    <span class="tok-kw">if</span> (native_arch == .<span class="tok-type">i386</span>) {</span>
<span class="line" id="L1248">        <span class="tok-kw">return</span> socketcall(SC.shutdown, &amp;[<span class="tok-number">2</span>]<span class="tok-type">usize</span>{ <span class="tok-builtin">@bitCast</span>(<span class="tok-type">usize</span>, <span class="tok-builtin">@as</span>(<span class="tok-type">isize</span>, fd)), <span class="tok-builtin">@bitCast</span>(<span class="tok-type">usize</span>, <span class="tok-builtin">@as</span>(<span class="tok-type">isize</span>, how)) });</span>
<span class="line" id="L1249">    }</span>
<span class="line" id="L1250">    <span class="tok-kw">return</span> syscall2(.shutdown, <span class="tok-builtin">@bitCast</span>(<span class="tok-type">usize</span>, <span class="tok-builtin">@as</span>(<span class="tok-type">isize</span>, fd)), <span class="tok-builtin">@bitCast</span>(<span class="tok-type">usize</span>, <span class="tok-builtin">@as</span>(<span class="tok-type">isize</span>, how)));</span>
<span class="line" id="L1251">}</span>
<span class="line" id="L1252"></span>
<span class="line" id="L1253"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">bind</span>(fd: <span class="tok-type">i32</span>, addr: *<span class="tok-kw">const</span> sockaddr, len: socklen_t) <span class="tok-type">usize</span> {</span>
<span class="line" id="L1254">    <span class="tok-kw">if</span> (native_arch == .<span class="tok-type">i386</span>) {</span>
<span class="line" id="L1255">        <span class="tok-kw">return</span> socketcall(SC.bind, &amp;[<span class="tok-number">3</span>]<span class="tok-type">usize</span>{ <span class="tok-builtin">@bitCast</span>(<span class="tok-type">usize</span>, <span class="tok-builtin">@as</span>(<span class="tok-type">isize</span>, fd)), <span class="tok-builtin">@ptrToInt</span>(addr), <span class="tok-builtin">@intCast</span>(<span class="tok-type">usize</span>, len) });</span>
<span class="line" id="L1256">    }</span>
<span class="line" id="L1257">    <span class="tok-kw">return</span> syscall3(.bind, <span class="tok-builtin">@bitCast</span>(<span class="tok-type">usize</span>, <span class="tok-builtin">@as</span>(<span class="tok-type">isize</span>, fd)), <span class="tok-builtin">@ptrToInt</span>(addr), <span class="tok-builtin">@intCast</span>(<span class="tok-type">usize</span>, len));</span>
<span class="line" id="L1258">}</span>
<span class="line" id="L1259"></span>
<span class="line" id="L1260"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">listen</span>(fd: <span class="tok-type">i32</span>, backlog: <span class="tok-type">u32</span>) <span class="tok-type">usize</span> {</span>
<span class="line" id="L1261">    <span class="tok-kw">if</span> (native_arch == .<span class="tok-type">i386</span>) {</span>
<span class="line" id="L1262">        <span class="tok-kw">return</span> socketcall(SC.listen, &amp;[<span class="tok-number">2</span>]<span class="tok-type">usize</span>{ <span class="tok-builtin">@bitCast</span>(<span class="tok-type">usize</span>, <span class="tok-builtin">@as</span>(<span class="tok-type">isize</span>, fd)), backlog });</span>
<span class="line" id="L1263">    }</span>
<span class="line" id="L1264">    <span class="tok-kw">return</span> syscall2(.listen, <span class="tok-builtin">@bitCast</span>(<span class="tok-type">usize</span>, <span class="tok-builtin">@as</span>(<span class="tok-type">isize</span>, fd)), backlog);</span>
<span class="line" id="L1265">}</span>
<span class="line" id="L1266"></span>
<span class="line" id="L1267"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">sendto</span>(fd: <span class="tok-type">i32</span>, buf: [*]<span class="tok-kw">const</span> <span class="tok-type">u8</span>, len: <span class="tok-type">usize</span>, flags: <span class="tok-type">u32</span>, addr: ?*<span class="tok-kw">const</span> sockaddr, alen: socklen_t) <span class="tok-type">usize</span> {</span>
<span class="line" id="L1268">    <span class="tok-kw">if</span> (native_arch == .<span class="tok-type">i386</span>) {</span>
<span class="line" id="L1269">        <span class="tok-kw">return</span> socketcall(SC.sendto, &amp;[<span class="tok-number">6</span>]<span class="tok-type">usize</span>{ <span class="tok-builtin">@bitCast</span>(<span class="tok-type">usize</span>, <span class="tok-builtin">@as</span>(<span class="tok-type">isize</span>, fd)), <span class="tok-builtin">@ptrToInt</span>(buf), len, flags, <span class="tok-builtin">@ptrToInt</span>(addr), <span class="tok-builtin">@intCast</span>(<span class="tok-type">usize</span>, alen) });</span>
<span class="line" id="L1270">    }</span>
<span class="line" id="L1271">    <span class="tok-kw">return</span> syscall6(.sendto, <span class="tok-builtin">@bitCast</span>(<span class="tok-type">usize</span>, <span class="tok-builtin">@as</span>(<span class="tok-type">isize</span>, fd)), <span class="tok-builtin">@ptrToInt</span>(buf), len, flags, <span class="tok-builtin">@ptrToInt</span>(addr), <span class="tok-builtin">@intCast</span>(<span class="tok-type">usize</span>, alen));</span>
<span class="line" id="L1272">}</span>
<span class="line" id="L1273"></span>
<span class="line" id="L1274"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">sendfile</span>(outfd: <span class="tok-type">i32</span>, infd: <span class="tok-type">i32</span>, offset: ?*<span class="tok-type">i64</span>, count: <span class="tok-type">usize</span>) <span class="tok-type">usize</span> {</span>
<span class="line" id="L1275">    <span class="tok-kw">if</span> (<span class="tok-builtin">@hasField</span>(SYS, <span class="tok-str">&quot;sendfile64&quot;</span>)) {</span>
<span class="line" id="L1276">        <span class="tok-kw">return</span> syscall4(</span>
<span class="line" id="L1277">            .sendfile64,</span>
<span class="line" id="L1278">            <span class="tok-builtin">@bitCast</span>(<span class="tok-type">usize</span>, <span class="tok-builtin">@as</span>(<span class="tok-type">isize</span>, outfd)),</span>
<span class="line" id="L1279">            <span class="tok-builtin">@bitCast</span>(<span class="tok-type">usize</span>, <span class="tok-builtin">@as</span>(<span class="tok-type">isize</span>, infd)),</span>
<span class="line" id="L1280">            <span class="tok-builtin">@ptrToInt</span>(offset),</span>
<span class="line" id="L1281">            count,</span>
<span class="line" id="L1282">        );</span>
<span class="line" id="L1283">    } <span class="tok-kw">else</span> {</span>
<span class="line" id="L1284">        <span class="tok-kw">return</span> syscall4(</span>
<span class="line" id="L1285">            .sendfile,</span>
<span class="line" id="L1286">            <span class="tok-builtin">@bitCast</span>(<span class="tok-type">usize</span>, <span class="tok-builtin">@as</span>(<span class="tok-type">isize</span>, outfd)),</span>
<span class="line" id="L1287">            <span class="tok-builtin">@bitCast</span>(<span class="tok-type">usize</span>, <span class="tok-builtin">@as</span>(<span class="tok-type">isize</span>, infd)),</span>
<span class="line" id="L1288">            <span class="tok-builtin">@ptrToInt</span>(offset),</span>
<span class="line" id="L1289">            count,</span>
<span class="line" id="L1290">        );</span>
<span class="line" id="L1291">    }</span>
<span class="line" id="L1292">}</span>
<span class="line" id="L1293"></span>
<span class="line" id="L1294"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">socketpair</span>(domain: <span class="tok-type">i32</span>, socket_type: <span class="tok-type">i32</span>, protocol: <span class="tok-type">i32</span>, fd: *[<span class="tok-number">2</span>]<span class="tok-type">i32</span>) <span class="tok-type">usize</span> {</span>
<span class="line" id="L1295">    <span class="tok-kw">if</span> (native_arch == .<span class="tok-type">i386</span>) {</span>
<span class="line" id="L1296">        <span class="tok-kw">return</span> socketcall(SC.socketpair, &amp;[<span class="tok-number">4</span>]<span class="tok-type">usize</span>{ <span class="tok-builtin">@intCast</span>(<span class="tok-type">usize</span>, domain), <span class="tok-builtin">@intCast</span>(<span class="tok-type">usize</span>, socket_type), <span class="tok-builtin">@intCast</span>(<span class="tok-type">usize</span>, protocol), <span class="tok-builtin">@ptrToInt</span>(fd) });</span>
<span class="line" id="L1297">    }</span>
<span class="line" id="L1298">    <span class="tok-kw">return</span> syscall4(.socketpair, <span class="tok-builtin">@intCast</span>(<span class="tok-type">usize</span>, domain), <span class="tok-builtin">@intCast</span>(<span class="tok-type">usize</span>, socket_type), <span class="tok-builtin">@intCast</span>(<span class="tok-type">usize</span>, protocol), <span class="tok-builtin">@ptrToInt</span>(fd));</span>
<span class="line" id="L1299">}</span>
<span class="line" id="L1300"></span>
<span class="line" id="L1301"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">accept</span>(fd: <span class="tok-type">i32</span>, <span class="tok-kw">noalias</span> addr: ?*sockaddr, <span class="tok-kw">noalias</span> len: ?*socklen_t) <span class="tok-type">usize</span> {</span>
<span class="line" id="L1302">    <span class="tok-kw">if</span> (native_arch == .<span class="tok-type">i386</span>) {</span>
<span class="line" id="L1303">        <span class="tok-kw">return</span> socketcall(SC.accept, &amp;[<span class="tok-number">4</span>]<span class="tok-type">usize</span>{ fd, addr, len, <span class="tok-number">0</span> });</span>
<span class="line" id="L1304">    }</span>
<span class="line" id="L1305">    <span class="tok-kw">return</span> accept4(fd, addr, len, <span class="tok-number">0</span>);</span>
<span class="line" id="L1306">}</span>
<span class="line" id="L1307"></span>
<span class="line" id="L1308"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">accept4</span>(fd: <span class="tok-type">i32</span>, <span class="tok-kw">noalias</span> addr: ?*sockaddr, <span class="tok-kw">noalias</span> len: ?*socklen_t, flags: <span class="tok-type">u32</span>) <span class="tok-type">usize</span> {</span>
<span class="line" id="L1309">    <span class="tok-kw">if</span> (native_arch == .<span class="tok-type">i386</span>) {</span>
<span class="line" id="L1310">        <span class="tok-kw">return</span> socketcall(SC.accept4, &amp;[<span class="tok-number">4</span>]<span class="tok-type">usize</span>{ <span class="tok-builtin">@bitCast</span>(<span class="tok-type">usize</span>, <span class="tok-builtin">@as</span>(<span class="tok-type">isize</span>, fd)), <span class="tok-builtin">@ptrToInt</span>(addr), <span class="tok-builtin">@ptrToInt</span>(len), flags });</span>
<span class="line" id="L1311">    }</span>
<span class="line" id="L1312">    <span class="tok-kw">return</span> syscall4(.accept4, <span class="tok-builtin">@bitCast</span>(<span class="tok-type">usize</span>, <span class="tok-builtin">@as</span>(<span class="tok-type">isize</span>, fd)), <span class="tok-builtin">@ptrToInt</span>(addr), <span class="tok-builtin">@ptrToInt</span>(len), flags);</span>
<span class="line" id="L1313">}</span>
<span class="line" id="L1314"></span>
<span class="line" id="L1315"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">fstat</span>(fd: <span class="tok-type">i32</span>, stat_buf: *Stat) <span class="tok-type">usize</span> {</span>
<span class="line" id="L1316">    <span class="tok-kw">if</span> (<span class="tok-builtin">@hasField</span>(SYS, <span class="tok-str">&quot;fstat64&quot;</span>)) {</span>
<span class="line" id="L1317">        <span class="tok-kw">return</span> syscall2(.fstat64, <span class="tok-builtin">@bitCast</span>(<span class="tok-type">usize</span>, <span class="tok-builtin">@as</span>(<span class="tok-type">isize</span>, fd)), <span class="tok-builtin">@ptrToInt</span>(stat_buf));</span>
<span class="line" id="L1318">    } <span class="tok-kw">else</span> {</span>
<span class="line" id="L1319">        <span class="tok-kw">return</span> syscall2(.fstat, <span class="tok-builtin">@bitCast</span>(<span class="tok-type">usize</span>, <span class="tok-builtin">@as</span>(<span class="tok-type">isize</span>, fd)), <span class="tok-builtin">@ptrToInt</span>(stat_buf));</span>
<span class="line" id="L1320">    }</span>
<span class="line" id="L1321">}</span>
<span class="line" id="L1322"></span>
<span class="line" id="L1323"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">stat</span>(pathname: [*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span>, statbuf: *Stat) <span class="tok-type">usize</span> {</span>
<span class="line" id="L1324">    <span class="tok-kw">if</span> (<span class="tok-builtin">@hasField</span>(SYS, <span class="tok-str">&quot;stat64&quot;</span>)) {</span>
<span class="line" id="L1325">        <span class="tok-kw">return</span> syscall2(.stat64, <span class="tok-builtin">@ptrToInt</span>(pathname), <span class="tok-builtin">@ptrToInt</span>(statbuf));</span>
<span class="line" id="L1326">    } <span class="tok-kw">else</span> {</span>
<span class="line" id="L1327">        <span class="tok-kw">return</span> syscall2(.stat, <span class="tok-builtin">@ptrToInt</span>(pathname), <span class="tok-builtin">@ptrToInt</span>(statbuf));</span>
<span class="line" id="L1328">    }</span>
<span class="line" id="L1329">}</span>
<span class="line" id="L1330"></span>
<span class="line" id="L1331"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">lstat</span>(pathname: [*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span>, statbuf: *Stat) <span class="tok-type">usize</span> {</span>
<span class="line" id="L1332">    <span class="tok-kw">if</span> (<span class="tok-builtin">@hasField</span>(SYS, <span class="tok-str">&quot;lstat64&quot;</span>)) {</span>
<span class="line" id="L1333">        <span class="tok-kw">return</span> syscall2(.lstat64, <span class="tok-builtin">@ptrToInt</span>(pathname), <span class="tok-builtin">@ptrToInt</span>(statbuf));</span>
<span class="line" id="L1334">    } <span class="tok-kw">else</span> {</span>
<span class="line" id="L1335">        <span class="tok-kw">return</span> syscall2(.lstat, <span class="tok-builtin">@ptrToInt</span>(pathname), <span class="tok-builtin">@ptrToInt</span>(statbuf));</span>
<span class="line" id="L1336">    }</span>
<span class="line" id="L1337">}</span>
<span class="line" id="L1338"></span>
<span class="line" id="L1339"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">fstatat</span>(dirfd: <span class="tok-type">i32</span>, path: [*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span>, stat_buf: *Stat, flags: <span class="tok-type">u32</span>) <span class="tok-type">usize</span> {</span>
<span class="line" id="L1340">    <span class="tok-kw">if</span> (<span class="tok-builtin">@hasField</span>(SYS, <span class="tok-str">&quot;fstatat64&quot;</span>)) {</span>
<span class="line" id="L1341">        <span class="tok-kw">return</span> syscall4(.fstatat64, <span class="tok-builtin">@bitCast</span>(<span class="tok-type">usize</span>, <span class="tok-builtin">@as</span>(<span class="tok-type">isize</span>, dirfd)), <span class="tok-builtin">@ptrToInt</span>(path), <span class="tok-builtin">@ptrToInt</span>(stat_buf), flags);</span>
<span class="line" id="L1342">    } <span class="tok-kw">else</span> {</span>
<span class="line" id="L1343">        <span class="tok-kw">return</span> syscall4(.fstatat, <span class="tok-builtin">@bitCast</span>(<span class="tok-type">usize</span>, <span class="tok-builtin">@as</span>(<span class="tok-type">isize</span>, dirfd)), <span class="tok-builtin">@ptrToInt</span>(path), <span class="tok-builtin">@ptrToInt</span>(stat_buf), flags);</span>
<span class="line" id="L1344">    }</span>
<span class="line" id="L1345">}</span>
<span class="line" id="L1346"></span>
<span class="line" id="L1347"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">statx</span>(dirfd: <span class="tok-type">i32</span>, path: [*]<span class="tok-kw">const</span> <span class="tok-type">u8</span>, flags: <span class="tok-type">u32</span>, mask: <span class="tok-type">u32</span>, statx_buf: *Statx) <span class="tok-type">usize</span> {</span>
<span class="line" id="L1348">    <span class="tok-kw">if</span> (<span class="tok-builtin">@hasField</span>(SYS, <span class="tok-str">&quot;statx&quot;</span>)) {</span>
<span class="line" id="L1349">        <span class="tok-kw">return</span> syscall5(</span>
<span class="line" id="L1350">            .statx,</span>
<span class="line" id="L1351">            <span class="tok-builtin">@bitCast</span>(<span class="tok-type">usize</span>, <span class="tok-builtin">@as</span>(<span class="tok-type">isize</span>, dirfd)),</span>
<span class="line" id="L1352">            <span class="tok-builtin">@ptrToInt</span>(path),</span>
<span class="line" id="L1353">            flags,</span>
<span class="line" id="L1354">            mask,</span>
<span class="line" id="L1355">            <span class="tok-builtin">@ptrToInt</span>(statx_buf),</span>
<span class="line" id="L1356">        );</span>
<span class="line" id="L1357">    }</span>
<span class="line" id="L1358">    <span class="tok-kw">return</span> <span class="tok-builtin">@bitCast</span>(<span class="tok-type">usize</span>, -<span class="tok-builtin">@as</span>(<span class="tok-type">isize</span>, <span class="tok-builtin">@enumToInt</span>(E.NOSYS)));</span>
<span class="line" id="L1359">}</span>
<span class="line" id="L1360"></span>
<span class="line" id="L1361"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">listxattr</span>(path: [*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span>, list: [*]<span class="tok-type">u8</span>, size: <span class="tok-type">usize</span>) <span class="tok-type">usize</span> {</span>
<span class="line" id="L1362">    <span class="tok-kw">return</span> syscall3(.listxattr, <span class="tok-builtin">@ptrToInt</span>(path), <span class="tok-builtin">@ptrToInt</span>(list), size);</span>
<span class="line" id="L1363">}</span>
<span class="line" id="L1364"></span>
<span class="line" id="L1365"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">llistxattr</span>(path: [*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span>, list: [*]<span class="tok-type">u8</span>, size: <span class="tok-type">usize</span>) <span class="tok-type">usize</span> {</span>
<span class="line" id="L1366">    <span class="tok-kw">return</span> syscall3(.llistxattr, <span class="tok-builtin">@ptrToInt</span>(path), <span class="tok-builtin">@ptrToInt</span>(list), size);</span>
<span class="line" id="L1367">}</span>
<span class="line" id="L1368"></span>
<span class="line" id="L1369"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">flistxattr</span>(fd: <span class="tok-type">usize</span>, list: [*]<span class="tok-type">u8</span>, size: <span class="tok-type">usize</span>) <span class="tok-type">usize</span> {</span>
<span class="line" id="L1370">    <span class="tok-kw">return</span> syscall3(.flistxattr, fd, <span class="tok-builtin">@ptrToInt</span>(list), size);</span>
<span class="line" id="L1371">}</span>
<span class="line" id="L1372"></span>
<span class="line" id="L1373"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">getxattr</span>(path: [*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span>, name: [*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span>, value: [*]<span class="tok-type">u8</span>, size: <span class="tok-type">usize</span>) <span class="tok-type">usize</span> {</span>
<span class="line" id="L1374">    <span class="tok-kw">return</span> syscall4(.getxattr, <span class="tok-builtin">@ptrToInt</span>(path), <span class="tok-builtin">@ptrToInt</span>(name), <span class="tok-builtin">@ptrToInt</span>(value), size);</span>
<span class="line" id="L1375">}</span>
<span class="line" id="L1376"></span>
<span class="line" id="L1377"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">lgetxattr</span>(path: [*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span>, name: [*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span>, value: [*]<span class="tok-type">u8</span>, size: <span class="tok-type">usize</span>) <span class="tok-type">usize</span> {</span>
<span class="line" id="L1378">    <span class="tok-kw">return</span> syscall4(.lgetxattr, <span class="tok-builtin">@ptrToInt</span>(path), <span class="tok-builtin">@ptrToInt</span>(name), <span class="tok-builtin">@ptrToInt</span>(value), size);</span>
<span class="line" id="L1379">}</span>
<span class="line" id="L1380"></span>
<span class="line" id="L1381"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">fgetxattr</span>(fd: <span class="tok-type">usize</span>, name: [*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span>, value: [*]<span class="tok-type">u8</span>, size: <span class="tok-type">usize</span>) <span class="tok-type">usize</span> {</span>
<span class="line" id="L1382">    <span class="tok-kw">return</span> syscall4(.lgetxattr, fd, <span class="tok-builtin">@ptrToInt</span>(name), <span class="tok-builtin">@ptrToInt</span>(value), size);</span>
<span class="line" id="L1383">}</span>
<span class="line" id="L1384"></span>
<span class="line" id="L1385"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">setxattr</span>(path: [*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span>, name: [*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span>, value: *<span class="tok-kw">const</span> <span class="tok-type">void</span>, size: <span class="tok-type">usize</span>, flags: <span class="tok-type">usize</span>) <span class="tok-type">usize</span> {</span>
<span class="line" id="L1386">    <span class="tok-kw">return</span> syscall5(.setxattr, <span class="tok-builtin">@ptrToInt</span>(path), <span class="tok-builtin">@ptrToInt</span>(name), <span class="tok-builtin">@ptrToInt</span>(value), size, flags);</span>
<span class="line" id="L1387">}</span>
<span class="line" id="L1388"></span>
<span class="line" id="L1389"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">lsetxattr</span>(path: [*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span>, name: [*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span>, value: *<span class="tok-kw">const</span> <span class="tok-type">void</span>, size: <span class="tok-type">usize</span>, flags: <span class="tok-type">usize</span>) <span class="tok-type">usize</span> {</span>
<span class="line" id="L1390">    <span class="tok-kw">return</span> syscall5(.lsetxattr, <span class="tok-builtin">@ptrToInt</span>(path), <span class="tok-builtin">@ptrToInt</span>(name), <span class="tok-builtin">@ptrToInt</span>(value), size, flags);</span>
<span class="line" id="L1391">}</span>
<span class="line" id="L1392"></span>
<span class="line" id="L1393"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">fsetxattr</span>(fd: <span class="tok-type">usize</span>, name: [*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span>, value: *<span class="tok-kw">const</span> <span class="tok-type">void</span>, size: <span class="tok-type">usize</span>, flags: <span class="tok-type">usize</span>) <span class="tok-type">usize</span> {</span>
<span class="line" id="L1394">    <span class="tok-kw">return</span> syscall5(.fsetxattr, fd, <span class="tok-builtin">@ptrToInt</span>(name), <span class="tok-builtin">@ptrToInt</span>(value), size, flags);</span>
<span class="line" id="L1395">}</span>
<span class="line" id="L1396"></span>
<span class="line" id="L1397"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">removexattr</span>(path: [*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span>, name: [*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span>) <span class="tok-type">usize</span> {</span>
<span class="line" id="L1398">    <span class="tok-kw">return</span> syscall2(.removexattr, <span class="tok-builtin">@ptrToInt</span>(path), <span class="tok-builtin">@ptrToInt</span>(name));</span>
<span class="line" id="L1399">}</span>
<span class="line" id="L1400"></span>
<span class="line" id="L1401"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">lremovexattr</span>(path: [*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span>, name: [*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span>) <span class="tok-type">usize</span> {</span>
<span class="line" id="L1402">    <span class="tok-kw">return</span> syscall2(.lremovexattr, <span class="tok-builtin">@ptrToInt</span>(path), <span class="tok-builtin">@ptrToInt</span>(name));</span>
<span class="line" id="L1403">}</span>
<span class="line" id="L1404"></span>
<span class="line" id="L1405"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">fremovexattr</span>(fd: <span class="tok-type">usize</span>, name: [*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span>) <span class="tok-type">usize</span> {</span>
<span class="line" id="L1406">    <span class="tok-kw">return</span> syscall2(.fremovexattr, fd, <span class="tok-builtin">@ptrToInt</span>(name));</span>
<span class="line" id="L1407">}</span>
<span class="line" id="L1408"></span>
<span class="line" id="L1409"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">sched_yield</span>() <span class="tok-type">usize</span> {</span>
<span class="line" id="L1410">    <span class="tok-kw">return</span> syscall0(.sched_yield);</span>
<span class="line" id="L1411">}</span>
<span class="line" id="L1412"></span>
<span class="line" id="L1413"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">sched_getaffinity</span>(pid: pid_t, size: <span class="tok-type">usize</span>, set: *cpu_set_t) <span class="tok-type">usize</span> {</span>
<span class="line" id="L1414">    <span class="tok-kw">const</span> rc = syscall3(.sched_getaffinity, <span class="tok-builtin">@bitCast</span>(<span class="tok-type">usize</span>, <span class="tok-builtin">@as</span>(<span class="tok-type">isize</span>, pid)), size, <span class="tok-builtin">@ptrToInt</span>(set));</span>
<span class="line" id="L1415">    <span class="tok-kw">if</span> (<span class="tok-builtin">@bitCast</span>(<span class="tok-type">isize</span>, rc) &lt; <span class="tok-number">0</span>) <span class="tok-kw">return</span> rc;</span>
<span class="line" id="L1416">    <span class="tok-kw">if</span> (rc &lt; size) <span class="tok-builtin">@memset</span>(<span class="tok-builtin">@ptrCast</span>([*]<span class="tok-type">u8</span>, set) + rc, <span class="tok-number">0</span>, size - rc);</span>
<span class="line" id="L1417">    <span class="tok-kw">return</span> <span class="tok-number">0</span>;</span>
<span class="line" id="L1418">}</span>
<span class="line" id="L1419"></span>
<span class="line" id="L1420"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">epoll_create</span>() <span class="tok-type">usize</span> {</span>
<span class="line" id="L1421">    <span class="tok-kw">return</span> epoll_create1(<span class="tok-number">0</span>);</span>
<span class="line" id="L1422">}</span>
<span class="line" id="L1423"></span>
<span class="line" id="L1424"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">epoll_create1</span>(flags: <span class="tok-type">usize</span>) <span class="tok-type">usize</span> {</span>
<span class="line" id="L1425">    <span class="tok-kw">return</span> syscall1(.epoll_create1, flags);</span>
<span class="line" id="L1426">}</span>
<span class="line" id="L1427"></span>
<span class="line" id="L1428"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">epoll_ctl</span>(epoll_fd: <span class="tok-type">i32</span>, op: <span class="tok-type">u32</span>, fd: <span class="tok-type">i32</span>, ev: ?*epoll_event) <span class="tok-type">usize</span> {</span>
<span class="line" id="L1429">    <span class="tok-kw">return</span> syscall4(.epoll_ctl, <span class="tok-builtin">@bitCast</span>(<span class="tok-type">usize</span>, <span class="tok-builtin">@as</span>(<span class="tok-type">isize</span>, epoll_fd)), <span class="tok-builtin">@intCast</span>(<span class="tok-type">usize</span>, op), <span class="tok-builtin">@bitCast</span>(<span class="tok-type">usize</span>, <span class="tok-builtin">@as</span>(<span class="tok-type">isize</span>, fd)), <span class="tok-builtin">@ptrToInt</span>(ev));</span>
<span class="line" id="L1430">}</span>
<span class="line" id="L1431"></span>
<span class="line" id="L1432"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">epoll_wait</span>(epoll_fd: <span class="tok-type">i32</span>, events: [*]epoll_event, maxevents: <span class="tok-type">u32</span>, timeout: <span class="tok-type">i32</span>) <span class="tok-type">usize</span> {</span>
<span class="line" id="L1433">    <span class="tok-kw">return</span> epoll_pwait(epoll_fd, events, maxevents, timeout, <span class="tok-null">null</span>);</span>
<span class="line" id="L1434">}</span>
<span class="line" id="L1435"></span>
<span class="line" id="L1436"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">epoll_pwait</span>(epoll_fd: <span class="tok-type">i32</span>, events: [*]epoll_event, maxevents: <span class="tok-type">u32</span>, timeout: <span class="tok-type">i32</span>, sigmask: ?*<span class="tok-kw">const</span> sigset_t) <span class="tok-type">usize</span> {</span>
<span class="line" id="L1437">    <span class="tok-kw">return</span> syscall6(</span>
<span class="line" id="L1438">        .epoll_pwait,</span>
<span class="line" id="L1439">        <span class="tok-builtin">@bitCast</span>(<span class="tok-type">usize</span>, <span class="tok-builtin">@as</span>(<span class="tok-type">isize</span>, epoll_fd)),</span>
<span class="line" id="L1440">        <span class="tok-builtin">@ptrToInt</span>(events),</span>
<span class="line" id="L1441">        <span class="tok-builtin">@intCast</span>(<span class="tok-type">usize</span>, maxevents),</span>
<span class="line" id="L1442">        <span class="tok-builtin">@bitCast</span>(<span class="tok-type">usize</span>, <span class="tok-builtin">@as</span>(<span class="tok-type">isize</span>, timeout)),</span>
<span class="line" id="L1443">        <span class="tok-builtin">@ptrToInt</span>(sigmask),</span>
<span class="line" id="L1444">        <span class="tok-builtin">@sizeOf</span>(sigset_t),</span>
<span class="line" id="L1445">    );</span>
<span class="line" id="L1446">}</span>
<span class="line" id="L1447"></span>
<span class="line" id="L1448"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">eventfd</span>(count: <span class="tok-type">u32</span>, flags: <span class="tok-type">u32</span>) <span class="tok-type">usize</span> {</span>
<span class="line" id="L1449">    <span class="tok-kw">return</span> syscall2(.eventfd2, count, flags);</span>
<span class="line" id="L1450">}</span>
<span class="line" id="L1451"></span>
<span class="line" id="L1452"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">timerfd_create</span>(clockid: <span class="tok-type">i32</span>, flags: <span class="tok-type">u32</span>) <span class="tok-type">usize</span> {</span>
<span class="line" id="L1453">    <span class="tok-kw">return</span> syscall2(.timerfd_create, <span class="tok-builtin">@bitCast</span>(<span class="tok-type">usize</span>, <span class="tok-builtin">@as</span>(<span class="tok-type">isize</span>, clockid)), flags);</span>
<span class="line" id="L1454">}</span>
<span class="line" id="L1455"></span>
<span class="line" id="L1456"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> itimerspec = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L1457">    it_interval: timespec,</span>
<span class="line" id="L1458">    it_value: timespec,</span>
<span class="line" id="L1459">};</span>
<span class="line" id="L1460"></span>
<span class="line" id="L1461"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">timerfd_gettime</span>(fd: <span class="tok-type">i32</span>, curr_value: *itimerspec) <span class="tok-type">usize</span> {</span>
<span class="line" id="L1462">    <span class="tok-kw">return</span> syscall2(.timerfd_gettime, <span class="tok-builtin">@bitCast</span>(<span class="tok-type">usize</span>, <span class="tok-builtin">@as</span>(<span class="tok-type">isize</span>, fd)), <span class="tok-builtin">@ptrToInt</span>(curr_value));</span>
<span class="line" id="L1463">}</span>
<span class="line" id="L1464"></span>
<span class="line" id="L1465"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">timerfd_settime</span>(fd: <span class="tok-type">i32</span>, flags: <span class="tok-type">u32</span>, new_value: *<span class="tok-kw">const</span> itimerspec, old_value: ?*itimerspec) <span class="tok-type">usize</span> {</span>
<span class="line" id="L1466">    <span class="tok-kw">return</span> syscall4(.timerfd_settime, <span class="tok-builtin">@bitCast</span>(<span class="tok-type">usize</span>, <span class="tok-builtin">@as</span>(<span class="tok-type">isize</span>, fd)), flags, <span class="tok-builtin">@ptrToInt</span>(new_value), <span class="tok-builtin">@ptrToInt</span>(old_value));</span>
<span class="line" id="L1467">}</span>
<span class="line" id="L1468"></span>
<span class="line" id="L1469"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">unshare</span>(flags: <span class="tok-type">usize</span>) <span class="tok-type">usize</span> {</span>
<span class="line" id="L1470">    <span class="tok-kw">return</span> syscall1(.unshare, flags);</span>
<span class="line" id="L1471">}</span>
<span class="line" id="L1472"></span>
<span class="line" id="L1473"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">capget</span>(hdrp: *cap_user_header_t, datap: *cap_user_data_t) <span class="tok-type">usize</span> {</span>
<span class="line" id="L1474">    <span class="tok-kw">return</span> syscall2(.capget, <span class="tok-builtin">@ptrToInt</span>(hdrp), <span class="tok-builtin">@ptrToInt</span>(datap));</span>
<span class="line" id="L1475">}</span>
<span class="line" id="L1476"></span>
<span class="line" id="L1477"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">capset</span>(hdrp: *cap_user_header_t, datap: *<span class="tok-kw">const</span> cap_user_data_t) <span class="tok-type">usize</span> {</span>
<span class="line" id="L1478">    <span class="tok-kw">return</span> syscall2(.capset, <span class="tok-builtin">@ptrToInt</span>(hdrp), <span class="tok-builtin">@ptrToInt</span>(datap));</span>
<span class="line" id="L1479">}</span>
<span class="line" id="L1480"></span>
<span class="line" id="L1481"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">sigaltstack</span>(ss: ?*stack_t, old_ss: ?*stack_t) <span class="tok-type">usize</span> {</span>
<span class="line" id="L1482">    <span class="tok-kw">return</span> syscall2(.sigaltstack, <span class="tok-builtin">@ptrToInt</span>(ss), <span class="tok-builtin">@ptrToInt</span>(old_ss));</span>
<span class="line" id="L1483">}</span>
<span class="line" id="L1484"></span>
<span class="line" id="L1485"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">uname</span>(uts: *utsname) <span class="tok-type">usize</span> {</span>
<span class="line" id="L1486">    <span class="tok-kw">return</span> syscall1(.uname, <span class="tok-builtin">@ptrToInt</span>(uts));</span>
<span class="line" id="L1487">}</span>
<span class="line" id="L1488"></span>
<span class="line" id="L1489"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">io_uring_setup</span>(entries: <span class="tok-type">u32</span>, p: *io_uring_params) <span class="tok-type">usize</span> {</span>
<span class="line" id="L1490">    <span class="tok-kw">return</span> syscall2(.io_uring_setup, entries, <span class="tok-builtin">@ptrToInt</span>(p));</span>
<span class="line" id="L1491">}</span>
<span class="line" id="L1492"></span>
<span class="line" id="L1493"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">io_uring_enter</span>(fd: <span class="tok-type">i32</span>, to_submit: <span class="tok-type">u32</span>, min_complete: <span class="tok-type">u32</span>, flags: <span class="tok-type">u32</span>, sig: ?*sigset_t) <span class="tok-type">usize</span> {</span>
<span class="line" id="L1494">    <span class="tok-kw">return</span> syscall6(.io_uring_enter, <span class="tok-builtin">@bitCast</span>(<span class="tok-type">usize</span>, <span class="tok-builtin">@as</span>(<span class="tok-type">isize</span>, fd)), to_submit, min_complete, flags, <span class="tok-builtin">@ptrToInt</span>(sig), NSIG / <span class="tok-number">8</span>);</span>
<span class="line" id="L1495">}</span>
<span class="line" id="L1496"></span>
<span class="line" id="L1497"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">io_uring_register</span>(fd: <span class="tok-type">i32</span>, opcode: IORING_REGISTER, arg: ?*<span class="tok-kw">const</span> <span class="tok-type">anyopaque</span>, nr_args: <span class="tok-type">u32</span>) <span class="tok-type">usize</span> {</span>
<span class="line" id="L1498">    <span class="tok-kw">return</span> syscall4(.io_uring_register, <span class="tok-builtin">@bitCast</span>(<span class="tok-type">usize</span>, <span class="tok-builtin">@as</span>(<span class="tok-type">isize</span>, fd)), <span class="tok-builtin">@enumToInt</span>(opcode), <span class="tok-builtin">@ptrToInt</span>(arg), nr_args);</span>
<span class="line" id="L1499">}</span>
<span class="line" id="L1500"></span>
<span class="line" id="L1501"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">memfd_create</span>(name: [*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span>, flags: <span class="tok-type">u32</span>) <span class="tok-type">usize</span> {</span>
<span class="line" id="L1502">    <span class="tok-kw">return</span> syscall2(.memfd_create, <span class="tok-builtin">@ptrToInt</span>(name), flags);</span>
<span class="line" id="L1503">}</span>
<span class="line" id="L1504"></span>
<span class="line" id="L1505"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">getrusage</span>(who: <span class="tok-type">i32</span>, usage: *rusage) <span class="tok-type">usize</span> {</span>
<span class="line" id="L1506">    <span class="tok-kw">return</span> syscall2(.getrusage, <span class="tok-builtin">@bitCast</span>(<span class="tok-type">usize</span>, <span class="tok-builtin">@as</span>(<span class="tok-type">isize</span>, who)), <span class="tok-builtin">@ptrToInt</span>(usage));</span>
<span class="line" id="L1507">}</span>
<span class="line" id="L1508"></span>
<span class="line" id="L1509"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">tcgetattr</span>(fd: fd_t, termios_p: *termios) <span class="tok-type">usize</span> {</span>
<span class="line" id="L1510">    <span class="tok-kw">return</span> syscall3(.ioctl, <span class="tok-builtin">@bitCast</span>(<span class="tok-type">usize</span>, <span class="tok-builtin">@as</span>(<span class="tok-type">isize</span>, fd)), T.CGETS, <span class="tok-builtin">@ptrToInt</span>(termios_p));</span>
<span class="line" id="L1511">}</span>
<span class="line" id="L1512"></span>
<span class="line" id="L1513"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">tcsetattr</span>(fd: fd_t, optional_action: TCSA, termios_p: *<span class="tok-kw">const</span> termios) <span class="tok-type">usize</span> {</span>
<span class="line" id="L1514">    <span class="tok-kw">return</span> syscall3(.ioctl, <span class="tok-builtin">@bitCast</span>(<span class="tok-type">usize</span>, <span class="tok-builtin">@as</span>(<span class="tok-type">isize</span>, fd)), T.CSETS + <span class="tok-builtin">@enumToInt</span>(optional_action), <span class="tok-builtin">@ptrToInt</span>(termios_p));</span>
<span class="line" id="L1515">}</span>
<span class="line" id="L1516"></span>
<span class="line" id="L1517"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">ioctl</span>(fd: fd_t, request: <span class="tok-type">u32</span>, arg: <span class="tok-type">usize</span>) <span class="tok-type">usize</span> {</span>
<span class="line" id="L1518">    <span class="tok-kw">return</span> syscall3(.ioctl, <span class="tok-builtin">@bitCast</span>(<span class="tok-type">usize</span>, <span class="tok-builtin">@as</span>(<span class="tok-type">isize</span>, fd)), request, arg);</span>
<span class="line" id="L1519">}</span>
<span class="line" id="L1520"></span>
<span class="line" id="L1521"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">signalfd</span>(fd: fd_t, mask: *<span class="tok-kw">const</span> sigset_t, flags: <span class="tok-type">u32</span>) <span class="tok-type">usize</span> {</span>
<span class="line" id="L1522">    <span class="tok-kw">return</span> syscall4(.signalfd4, <span class="tok-builtin">@bitCast</span>(<span class="tok-type">usize</span>, <span class="tok-builtin">@as</span>(<span class="tok-type">isize</span>, fd)), <span class="tok-builtin">@ptrToInt</span>(mask), NSIG / <span class="tok-number">8</span>, flags);</span>
<span class="line" id="L1523">}</span>
<span class="line" id="L1524"></span>
<span class="line" id="L1525"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">copy_file_range</span>(fd_in: fd_t, off_in: ?*<span class="tok-type">i64</span>, fd_out: fd_t, off_out: ?*<span class="tok-type">i64</span>, len: <span class="tok-type">usize</span>, flags: <span class="tok-type">u32</span>) <span class="tok-type">usize</span> {</span>
<span class="line" id="L1526">    <span class="tok-kw">return</span> syscall6(</span>
<span class="line" id="L1527">        .copy_file_range,</span>
<span class="line" id="L1528">        <span class="tok-builtin">@bitCast</span>(<span class="tok-type">usize</span>, <span class="tok-builtin">@as</span>(<span class="tok-type">isize</span>, fd_in)),</span>
<span class="line" id="L1529">        <span class="tok-builtin">@ptrToInt</span>(off_in),</span>
<span class="line" id="L1530">        <span class="tok-builtin">@bitCast</span>(<span class="tok-type">usize</span>, <span class="tok-builtin">@as</span>(<span class="tok-type">isize</span>, fd_out)),</span>
<span class="line" id="L1531">        <span class="tok-builtin">@ptrToInt</span>(off_out),</span>
<span class="line" id="L1532">        len,</span>
<span class="line" id="L1533">        flags,</span>
<span class="line" id="L1534">    );</span>
<span class="line" id="L1535">}</span>
<span class="line" id="L1536"></span>
<span class="line" id="L1537"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">bpf</span>(cmd: BPF.Cmd, attr: *BPF.Attr, size: <span class="tok-type">u32</span>) <span class="tok-type">usize</span> {</span>
<span class="line" id="L1538">    <span class="tok-kw">return</span> syscall3(.bpf, <span class="tok-builtin">@enumToInt</span>(cmd), <span class="tok-builtin">@ptrToInt</span>(attr), size);</span>
<span class="line" id="L1539">}</span>
<span class="line" id="L1540"></span>
<span class="line" id="L1541"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">sync</span>() <span class="tok-type">void</span> {</span>
<span class="line" id="L1542">    _ = syscall0(.sync);</span>
<span class="line" id="L1543">}</span>
<span class="line" id="L1544"></span>
<span class="line" id="L1545"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">syncfs</span>(fd: fd_t) <span class="tok-type">usize</span> {</span>
<span class="line" id="L1546">    <span class="tok-kw">return</span> syscall1(.syncfs, <span class="tok-builtin">@bitCast</span>(<span class="tok-type">usize</span>, <span class="tok-builtin">@as</span>(<span class="tok-type">isize</span>, fd)));</span>
<span class="line" id="L1547">}</span>
<span class="line" id="L1548"></span>
<span class="line" id="L1549"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">fsync</span>(fd: fd_t) <span class="tok-type">usize</span> {</span>
<span class="line" id="L1550">    <span class="tok-kw">return</span> syscall1(.fsync, <span class="tok-builtin">@bitCast</span>(<span class="tok-type">usize</span>, <span class="tok-builtin">@as</span>(<span class="tok-type">isize</span>, fd)));</span>
<span class="line" id="L1551">}</span>
<span class="line" id="L1552"></span>
<span class="line" id="L1553"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">fdatasync</span>(fd: fd_t) <span class="tok-type">usize</span> {</span>
<span class="line" id="L1554">    <span class="tok-kw">return</span> syscall1(.fdatasync, <span class="tok-builtin">@bitCast</span>(<span class="tok-type">usize</span>, <span class="tok-builtin">@as</span>(<span class="tok-type">isize</span>, fd)));</span>
<span class="line" id="L1555">}</span>
<span class="line" id="L1556"></span>
<span class="line" id="L1557"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">prctl</span>(option: <span class="tok-type">i32</span>, arg2: <span class="tok-type">usize</span>, arg3: <span class="tok-type">usize</span>, arg4: <span class="tok-type">usize</span>, arg5: <span class="tok-type">usize</span>) <span class="tok-type">usize</span> {</span>
<span class="line" id="L1558">    <span class="tok-kw">return</span> syscall5(.prctl, <span class="tok-builtin">@bitCast</span>(<span class="tok-type">usize</span>, <span class="tok-builtin">@as</span>(<span class="tok-type">isize</span>, option)), arg2, arg3, arg4, arg5);</span>
<span class="line" id="L1559">}</span>
<span class="line" id="L1560"></span>
<span class="line" id="L1561"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">getrlimit</span>(resource: rlimit_resource, rlim: *rlimit) <span class="tok-type">usize</span> {</span>
<span class="line" id="L1562">    <span class="tok-comment">// use prlimit64 to have 64 bit limits on 32 bit platforms</span>
</span>
<span class="line" id="L1563">    <span class="tok-kw">return</span> prlimit(<span class="tok-number">0</span>, resource, <span class="tok-null">null</span>, rlim);</span>
<span class="line" id="L1564">}</span>
<span class="line" id="L1565"></span>
<span class="line" id="L1566"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">setrlimit</span>(resource: rlimit_resource, rlim: *<span class="tok-kw">const</span> rlimit) <span class="tok-type">usize</span> {</span>
<span class="line" id="L1567">    <span class="tok-comment">// use prlimit64 to have 64 bit limits on 32 bit platforms</span>
</span>
<span class="line" id="L1568">    <span class="tok-kw">return</span> prlimit(<span class="tok-number">0</span>, resource, rlim, <span class="tok-null">null</span>);</span>
<span class="line" id="L1569">}</span>
<span class="line" id="L1570"></span>
<span class="line" id="L1571"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">prlimit</span>(pid: pid_t, resource: rlimit_resource, new_limit: ?*<span class="tok-kw">const</span> rlimit, old_limit: ?*rlimit) <span class="tok-type">usize</span> {</span>
<span class="line" id="L1572">    <span class="tok-kw">return</span> syscall4(</span>
<span class="line" id="L1573">        .prlimit64,</span>
<span class="line" id="L1574">        <span class="tok-builtin">@bitCast</span>(<span class="tok-type">usize</span>, <span class="tok-builtin">@as</span>(<span class="tok-type">isize</span>, pid)),</span>
<span class="line" id="L1575">        <span class="tok-builtin">@bitCast</span>(<span class="tok-type">usize</span>, <span class="tok-builtin">@as</span>(<span class="tok-type">isize</span>, <span class="tok-builtin">@enumToInt</span>(resource))),</span>
<span class="line" id="L1576">        <span class="tok-builtin">@ptrToInt</span>(new_limit),</span>
<span class="line" id="L1577">        <span class="tok-builtin">@ptrToInt</span>(old_limit),</span>
<span class="line" id="L1578">    );</span>
<span class="line" id="L1579">}</span>
<span class="line" id="L1580"></span>
<span class="line" id="L1581"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">madvise</span>(address: [*]<span class="tok-type">u8</span>, len: <span class="tok-type">usize</span>, advice: <span class="tok-type">u32</span>) <span class="tok-type">usize</span> {</span>
<span class="line" id="L1582">    <span class="tok-kw">return</span> syscall3(.madvise, <span class="tok-builtin">@ptrToInt</span>(address), len, advice);</span>
<span class="line" id="L1583">}</span>
<span class="line" id="L1584"></span>
<span class="line" id="L1585"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">pidfd_open</span>(pid: pid_t, flags: <span class="tok-type">u32</span>) <span class="tok-type">usize</span> {</span>
<span class="line" id="L1586">    <span class="tok-kw">return</span> syscall2(.pidfd_open, <span class="tok-builtin">@bitCast</span>(<span class="tok-type">usize</span>, <span class="tok-builtin">@as</span>(<span class="tok-type">isize</span>, pid)), flags);</span>
<span class="line" id="L1587">}</span>
<span class="line" id="L1588"></span>
<span class="line" id="L1589"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">pidfd_getfd</span>(pidfd: fd_t, targetfd: fd_t, flags: <span class="tok-type">u32</span>) <span class="tok-type">usize</span> {</span>
<span class="line" id="L1590">    <span class="tok-kw">return</span> syscall3(</span>
<span class="line" id="L1591">        .pidfd_getfd,</span>
<span class="line" id="L1592">        <span class="tok-builtin">@bitCast</span>(<span class="tok-type">usize</span>, <span class="tok-builtin">@as</span>(<span class="tok-type">isize</span>, pidfd)),</span>
<span class="line" id="L1593">        <span class="tok-builtin">@bitCast</span>(<span class="tok-type">usize</span>, <span class="tok-builtin">@as</span>(<span class="tok-type">isize</span>, targetfd)),</span>
<span class="line" id="L1594">        flags,</span>
<span class="line" id="L1595">    );</span>
<span class="line" id="L1596">}</span>
<span class="line" id="L1597"></span>
<span class="line" id="L1598"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">pidfd_send_signal</span>(pidfd: fd_t, sig: <span class="tok-type">i32</span>, info: ?*siginfo_t, flags: <span class="tok-type">u32</span>) <span class="tok-type">usize</span> {</span>
<span class="line" id="L1599">    <span class="tok-kw">return</span> syscall4(</span>
<span class="line" id="L1600">        .pidfd_send_signal,</span>
<span class="line" id="L1601">        <span class="tok-builtin">@bitCast</span>(<span class="tok-type">usize</span>, <span class="tok-builtin">@as</span>(<span class="tok-type">isize</span>, pidfd)),</span>
<span class="line" id="L1602">        <span class="tok-builtin">@bitCast</span>(<span class="tok-type">usize</span>, <span class="tok-builtin">@as</span>(<span class="tok-type">isize</span>, sig)),</span>
<span class="line" id="L1603">        <span class="tok-builtin">@ptrToInt</span>(info),</span>
<span class="line" id="L1604">        flags,</span>
<span class="line" id="L1605">    );</span>
<span class="line" id="L1606">}</span>
<span class="line" id="L1607"></span>
<span class="line" id="L1608"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">process_vm_readv</span>(pid: pid_t, local: [*]<span class="tok-kw">const</span> iovec, local_count: <span class="tok-type">usize</span>, remote: [*]<span class="tok-kw">const</span> iovec, remote_count: <span class="tok-type">usize</span>, flags: <span class="tok-type">usize</span>) <span class="tok-type">usize</span> {</span>
<span class="line" id="L1609">    <span class="tok-kw">return</span> syscall6(</span>
<span class="line" id="L1610">        .process_vm_readv,</span>
<span class="line" id="L1611">        <span class="tok-builtin">@bitCast</span>(<span class="tok-type">usize</span>, <span class="tok-builtin">@as</span>(<span class="tok-type">isize</span>, pid)),</span>
<span class="line" id="L1612">        <span class="tok-builtin">@ptrToInt</span>(local),</span>
<span class="line" id="L1613">        local_count,</span>
<span class="line" id="L1614">        <span class="tok-builtin">@ptrToInt</span>(remote),</span>
<span class="line" id="L1615">        remote_count,</span>
<span class="line" id="L1616">        flags,</span>
<span class="line" id="L1617">    );</span>
<span class="line" id="L1618">}</span>
<span class="line" id="L1619"></span>
<span class="line" id="L1620"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">process_vm_writev</span>(pid: pid_t, local: [*]<span class="tok-kw">const</span> iovec, local_count: <span class="tok-type">usize</span>, remote: [*]<span class="tok-kw">const</span> iovec, remote_count: <span class="tok-type">usize</span>, flags: <span class="tok-type">usize</span>) <span class="tok-type">usize</span> {</span>
<span class="line" id="L1621">    <span class="tok-kw">return</span> syscall6(</span>
<span class="line" id="L1622">        .process_vm_writev,</span>
<span class="line" id="L1623">        <span class="tok-builtin">@bitCast</span>(<span class="tok-type">usize</span>, <span class="tok-builtin">@as</span>(<span class="tok-type">isize</span>, pid)),</span>
<span class="line" id="L1624">        <span class="tok-builtin">@ptrToInt</span>(local),</span>
<span class="line" id="L1625">        local_count,</span>
<span class="line" id="L1626">        <span class="tok-builtin">@ptrToInt</span>(remote),</span>
<span class="line" id="L1627">        remote_count,</span>
<span class="line" id="L1628">        flags,</span>
<span class="line" id="L1629">    );</span>
<span class="line" id="L1630">}</span>
<span class="line" id="L1631"></span>
<span class="line" id="L1632"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">fadvise</span>(fd: fd_t, offset: <span class="tok-type">i64</span>, len: <span class="tok-type">i64</span>, advice: <span class="tok-type">usize</span>) <span class="tok-type">usize</span> {</span>
<span class="line" id="L1633">    <span class="tok-kw">if</span> (<span class="tok-kw">comptime</span> builtin.cpu.arch.isMIPS()) {</span>
<span class="line" id="L1634">        <span class="tok-comment">// MIPS requires a 7 argument syscall</span>
</span>
<span class="line" id="L1635"></span>
<span class="line" id="L1636">        <span class="tok-kw">const</span> offset_halves = splitValue64(offset);</span>
<span class="line" id="L1637">        <span class="tok-kw">const</span> length_halves = splitValue64(len);</span>
<span class="line" id="L1638"></span>
<span class="line" id="L1639">        <span class="tok-kw">return</span> syscall7(</span>
<span class="line" id="L1640">            .fadvise64,</span>
<span class="line" id="L1641">            <span class="tok-builtin">@bitCast</span>(<span class="tok-type">usize</span>, <span class="tok-builtin">@as</span>(<span class="tok-type">isize</span>, fd)),</span>
<span class="line" id="L1642">            <span class="tok-number">0</span>,</span>
<span class="line" id="L1643">            offset_halves[<span class="tok-number">0</span>],</span>
<span class="line" id="L1644">            offset_halves[<span class="tok-number">1</span>],</span>
<span class="line" id="L1645">            length_halves[<span class="tok-number">0</span>],</span>
<span class="line" id="L1646">            length_halves[<span class="tok-number">1</span>],</span>
<span class="line" id="L1647">            advice,</span>
<span class="line" id="L1648">        );</span>
<span class="line" id="L1649">    } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (<span class="tok-kw">comptime</span> builtin.cpu.arch.isARM()) {</span>
<span class="line" id="L1650">        <span class="tok-comment">// ARM reorders the arguments</span>
</span>
<span class="line" id="L1651"></span>
<span class="line" id="L1652">        <span class="tok-kw">const</span> offset_halves = splitValue64(offset);</span>
<span class="line" id="L1653">        <span class="tok-kw">const</span> length_halves = splitValue64(len);</span>
<span class="line" id="L1654"></span>
<span class="line" id="L1655">        <span class="tok-kw">return</span> syscall6(</span>
<span class="line" id="L1656">            .fadvise64_64,</span>
<span class="line" id="L1657">            <span class="tok-builtin">@bitCast</span>(<span class="tok-type">usize</span>, <span class="tok-builtin">@as</span>(<span class="tok-type">isize</span>, fd)),</span>
<span class="line" id="L1658">            advice,</span>
<span class="line" id="L1659">            offset_halves[<span class="tok-number">0</span>],</span>
<span class="line" id="L1660">            offset_halves[<span class="tok-number">1</span>],</span>
<span class="line" id="L1661">            length_halves[<span class="tok-number">0</span>],</span>
<span class="line" id="L1662">            length_halves[<span class="tok-number">1</span>],</span>
<span class="line" id="L1663">        );</span>
<span class="line" id="L1664">    } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (<span class="tok-builtin">@hasField</span>(SYS, <span class="tok-str">&quot;fadvise64_64&quot;</span>) <span class="tok-kw">and</span> usize_bits != <span class="tok-number">64</span>) {</span>
<span class="line" id="L1665">        <span class="tok-comment">// The extra usize check is needed to avoid SPARC64 because it provides both</span>
</span>
<span class="line" id="L1666">        <span class="tok-comment">// fadvise64 and fadvise64_64 but the latter behaves differently than other platforms.</span>
</span>
<span class="line" id="L1667"></span>
<span class="line" id="L1668">        <span class="tok-kw">const</span> offset_halves = splitValue64(offset);</span>
<span class="line" id="L1669">        <span class="tok-kw">const</span> length_halves = splitValue64(len);</span>
<span class="line" id="L1670"></span>
<span class="line" id="L1671">        <span class="tok-kw">return</span> syscall6(</span>
<span class="line" id="L1672">            .fadvise64_64,</span>
<span class="line" id="L1673">            <span class="tok-builtin">@bitCast</span>(<span class="tok-type">usize</span>, <span class="tok-builtin">@as</span>(<span class="tok-type">isize</span>, fd)),</span>
<span class="line" id="L1674">            offset_halves[<span class="tok-number">0</span>],</span>
<span class="line" id="L1675">            offset_halves[<span class="tok-number">1</span>],</span>
<span class="line" id="L1676">            length_halves[<span class="tok-number">0</span>],</span>
<span class="line" id="L1677">            length_halves[<span class="tok-number">1</span>],</span>
<span class="line" id="L1678">            advice,</span>
<span class="line" id="L1679">        );</span>
<span class="line" id="L1680">    } <span class="tok-kw">else</span> {</span>
<span class="line" id="L1681">        <span class="tok-kw">return</span> syscall4(</span>
<span class="line" id="L1682">            .fadvise64,</span>
<span class="line" id="L1683">            <span class="tok-builtin">@bitCast</span>(<span class="tok-type">usize</span>, <span class="tok-builtin">@as</span>(<span class="tok-type">isize</span>, fd)),</span>
<span class="line" id="L1684">            <span class="tok-builtin">@bitCast</span>(<span class="tok-type">usize</span>, offset),</span>
<span class="line" id="L1685">            <span class="tok-builtin">@bitCast</span>(<span class="tok-type">usize</span>, len),</span>
<span class="line" id="L1686">            advice,</span>
<span class="line" id="L1687">        );</span>
<span class="line" id="L1688">    }</span>
<span class="line" id="L1689">}</span>
<span class="line" id="L1690"></span>
<span class="line" id="L1691"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">perf_event_open</span>(</span>
<span class="line" id="L1692">    attr: *perf_event_attr,</span>
<span class="line" id="L1693">    pid: pid_t,</span>
<span class="line" id="L1694">    cpu: <span class="tok-type">i32</span>,</span>
<span class="line" id="L1695">    group_fd: fd_t,</span>
<span class="line" id="L1696">    flags: <span class="tok-type">usize</span>,</span>
<span class="line" id="L1697">) <span class="tok-type">usize</span> {</span>
<span class="line" id="L1698">    <span class="tok-kw">return</span> syscall5(</span>
<span class="line" id="L1699">        .perf_event_open,</span>
<span class="line" id="L1700">        <span class="tok-builtin">@ptrToInt</span>(attr),</span>
<span class="line" id="L1701">        <span class="tok-builtin">@bitCast</span>(<span class="tok-type">usize</span>, <span class="tok-builtin">@as</span>(<span class="tok-type">isize</span>, pid)),</span>
<span class="line" id="L1702">        <span class="tok-builtin">@bitCast</span>(<span class="tok-type">usize</span>, <span class="tok-builtin">@as</span>(<span class="tok-type">isize</span>, cpu)),</span>
<span class="line" id="L1703">        <span class="tok-builtin">@bitCast</span>(<span class="tok-type">usize</span>, <span class="tok-builtin">@as</span>(<span class="tok-type">isize</span>, group_fd)),</span>
<span class="line" id="L1704">        flags,</span>
<span class="line" id="L1705">    );</span>
<span class="line" id="L1706">}</span>
<span class="line" id="L1707"></span>
<span class="line" id="L1708"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">seccomp</span>(operation: <span class="tok-type">u32</span>, flags: <span class="tok-type">u32</span>, args: ?*<span class="tok-kw">const</span> <span class="tok-type">anyopaque</span>) <span class="tok-type">usize</span> {</span>
<span class="line" id="L1709">    <span class="tok-kw">return</span> syscall3(.seccomp, operation, flags, <span class="tok-builtin">@ptrToInt</span>(args));</span>
<span class="line" id="L1710">}</span>
<span class="line" id="L1711"></span>
<span class="line" id="L1712"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> E = <span class="tok-kw">switch</span> (native_arch) {</span>
<span class="line" id="L1713">    .mips, .mipsel =&gt; <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;linux/errno/mips.zig&quot;</span>).E,</span>
<span class="line" id="L1714">    .sparc, .sparcel, .sparc64 =&gt; <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;linux/errno/sparc.zig&quot;</span>).E,</span>
<span class="line" id="L1715">    <span class="tok-kw">else</span> =&gt; <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;linux/errno/generic.zig&quot;</span>).E,</span>
<span class="line" id="L1716">};</span>
<span class="line" id="L1717"></span>
<span class="line" id="L1718"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> pid_t = <span class="tok-type">i32</span>;</span>
<span class="line" id="L1719"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> fd_t = <span class="tok-type">i32</span>;</span>
<span class="line" id="L1720"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> uid_t = <span class="tok-type">u32</span>;</span>
<span class="line" id="L1721"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> gid_t = <span class="tok-type">u32</span>;</span>
<span class="line" id="L1722"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> clock_t = <span class="tok-type">isize</span>;</span>
<span class="line" id="L1723"></span>
<span class="line" id="L1724"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> NAME_MAX = <span class="tok-number">255</span>;</span>
<span class="line" id="L1725"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> PATH_MAX = <span class="tok-number">4096</span>;</span>
<span class="line" id="L1726"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IOV_MAX = <span class="tok-number">1024</span>;</span>
<span class="line" id="L1727"></span>
<span class="line" id="L1728"><span class="tok-comment">/// Largest hardware address length</span></span>
<span class="line" id="L1729"><span class="tok-comment">/// e.g. a mac address is a type of hardware address</span></span>
<span class="line" id="L1730"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> MAX_ADDR_LEN = <span class="tok-number">32</span>;</span>
<span class="line" id="L1731"></span>
<span class="line" id="L1732"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> STDIN_FILENO = <span class="tok-number">0</span>;</span>
<span class="line" id="L1733"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> STDOUT_FILENO = <span class="tok-number">1</span>;</span>
<span class="line" id="L1734"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> STDERR_FILENO = <span class="tok-number">2</span>;</span>
<span class="line" id="L1735"></span>
<span class="line" id="L1736"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> AT = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L1737">    <span class="tok-comment">/// Special value used to indicate openat should use the current working directory</span></span>
<span class="line" id="L1738">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> FDCWD = -<span class="tok-number">100</span>;</span>
<span class="line" id="L1739"></span>
<span class="line" id="L1740">    <span class="tok-comment">/// Do not follow symbolic links</span></span>
<span class="line" id="L1741">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> SYMLINK_NOFOLLOW = <span class="tok-number">0x100</span>;</span>
<span class="line" id="L1742"></span>
<span class="line" id="L1743">    <span class="tok-comment">/// Remove directory instead of unlinking file</span></span>
<span class="line" id="L1744">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> REMOVEDIR = <span class="tok-number">0x200</span>;</span>
<span class="line" id="L1745"></span>
<span class="line" id="L1746">    <span class="tok-comment">/// Follow symbolic links.</span></span>
<span class="line" id="L1747">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> SYMLINK_FOLLOW = <span class="tok-number">0x400</span>;</span>
<span class="line" id="L1748"></span>
<span class="line" id="L1749">    <span class="tok-comment">/// Suppress terminal automount traversal</span></span>
<span class="line" id="L1750">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> NO_AUTOMOUNT = <span class="tok-number">0x800</span>;</span>
<span class="line" id="L1751"></span>
<span class="line" id="L1752">    <span class="tok-comment">/// Allow empty relative pathname</span></span>
<span class="line" id="L1753">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> EMPTY_PATH = <span class="tok-number">0x1000</span>;</span>
<span class="line" id="L1754"></span>
<span class="line" id="L1755">    <span class="tok-comment">/// Type of synchronisation required from statx()</span></span>
<span class="line" id="L1756">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> STATX_SYNC_TYPE = <span class="tok-number">0x6000</span>;</span>
<span class="line" id="L1757"></span>
<span class="line" id="L1758">    <span class="tok-comment">/// - Do whatever stat() does</span></span>
<span class="line" id="L1759">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> STATX_SYNC_AS_STAT = <span class="tok-number">0x0000</span>;</span>
<span class="line" id="L1760"></span>
<span class="line" id="L1761">    <span class="tok-comment">/// - Force the attributes to be sync'd with the server</span></span>
<span class="line" id="L1762">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> STATX_FORCE_SYNC = <span class="tok-number">0x2000</span>;</span>
<span class="line" id="L1763"></span>
<span class="line" id="L1764">    <span class="tok-comment">/// - Don't sync attributes with the server</span></span>
<span class="line" id="L1765">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> STATX_DONT_SYNC = <span class="tok-number">0x4000</span>;</span>
<span class="line" id="L1766"></span>
<span class="line" id="L1767">    <span class="tok-comment">/// Apply to the entire subtree</span></span>
<span class="line" id="L1768">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> RECURSIVE = <span class="tok-number">0x8000</span>;</span>
<span class="line" id="L1769">};</span>
<span class="line" id="L1770"></span>
<span class="line" id="L1771"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FALLOC = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L1772">    <span class="tok-comment">/// Default is extend size</span></span>
<span class="line" id="L1773">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> FL_KEEP_SIZE = <span class="tok-number">0x01</span>;</span>
<span class="line" id="L1774"></span>
<span class="line" id="L1775">    <span class="tok-comment">/// De-allocates range</span></span>
<span class="line" id="L1776">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> FL_PUNCH_HOLE = <span class="tok-number">0x02</span>;</span>
<span class="line" id="L1777"></span>
<span class="line" id="L1778">    <span class="tok-comment">/// Reserved codepoint</span></span>
<span class="line" id="L1779">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> FL_NO_HIDE_STALE = <span class="tok-number">0x04</span>;</span>
<span class="line" id="L1780"></span>
<span class="line" id="L1781">    <span class="tok-comment">/// Removes a range of a file without leaving a hole in the file</span></span>
<span class="line" id="L1782">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> FL_COLLAPSE_RANGE = <span class="tok-number">0x08</span>;</span>
<span class="line" id="L1783"></span>
<span class="line" id="L1784">    <span class="tok-comment">/// Converts a range of file to zeros preferably without issuing data IO</span></span>
<span class="line" id="L1785">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> FL_ZERO_RANGE = <span class="tok-number">0x10</span>;</span>
<span class="line" id="L1786"></span>
<span class="line" id="L1787">    <span class="tok-comment">/// Inserts space within the file size without overwriting any existing data</span></span>
<span class="line" id="L1788">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> FL_INSERT_RANGE = <span class="tok-number">0x20</span>;</span>
<span class="line" id="L1789"></span>
<span class="line" id="L1790">    <span class="tok-comment">/// Unshares shared blocks within the file size without overwriting any existing data</span></span>
<span class="line" id="L1791">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> FL_UNSHARE_RANGE = <span class="tok-number">0x40</span>;</span>
<span class="line" id="L1792">};</span>
<span class="line" id="L1793"></span>
<span class="line" id="L1794"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FUTEX = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L1795">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> WAIT = <span class="tok-number">0</span>;</span>
<span class="line" id="L1796">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> WAKE = <span class="tok-number">1</span>;</span>
<span class="line" id="L1797">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> FD = <span class="tok-number">2</span>;</span>
<span class="line" id="L1798">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> REQUEUE = <span class="tok-number">3</span>;</span>
<span class="line" id="L1799">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> CMP_REQUEUE = <span class="tok-number">4</span>;</span>
<span class="line" id="L1800">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> WAKE_OP = <span class="tok-number">5</span>;</span>
<span class="line" id="L1801">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> LOCK_PI = <span class="tok-number">6</span>;</span>
<span class="line" id="L1802">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> UNLOCK_PI = <span class="tok-number">7</span>;</span>
<span class="line" id="L1803">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> TRYLOCK_PI = <span class="tok-number">8</span>;</span>
<span class="line" id="L1804">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> WAIT_BITSET = <span class="tok-number">9</span>;</span>
<span class="line" id="L1805">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> WAKE_BITSET = <span class="tok-number">10</span>;</span>
<span class="line" id="L1806">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> WAIT_REQUEUE_PI = <span class="tok-number">11</span>;</span>
<span class="line" id="L1807">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> CMP_REQUEUE_PI = <span class="tok-number">12</span>;</span>
<span class="line" id="L1808"></span>
<span class="line" id="L1809">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> PRIVATE_FLAG = <span class="tok-number">128</span>;</span>
<span class="line" id="L1810"></span>
<span class="line" id="L1811">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> CLOCK_REALTIME = <span class="tok-number">256</span>;</span>
<span class="line" id="L1812">};</span>
<span class="line" id="L1813"></span>
<span class="line" id="L1814"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> PROT = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L1815">    <span class="tok-comment">/// page can not be accessed</span></span>
<span class="line" id="L1816">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> NONE = <span class="tok-number">0x0</span>;</span>
<span class="line" id="L1817">    <span class="tok-comment">/// page can be read</span></span>
<span class="line" id="L1818">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> READ = <span class="tok-number">0x1</span>;</span>
<span class="line" id="L1819">    <span class="tok-comment">/// page can be written</span></span>
<span class="line" id="L1820">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> WRITE = <span class="tok-number">0x2</span>;</span>
<span class="line" id="L1821">    <span class="tok-comment">/// page can be executed</span></span>
<span class="line" id="L1822">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> EXEC = <span class="tok-number">0x4</span>;</span>
<span class="line" id="L1823">    <span class="tok-comment">/// page may be used for atomic ops</span></span>
<span class="line" id="L1824">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> SEM = <span class="tok-kw">switch</span> (native_arch) {</span>
<span class="line" id="L1825">        <span class="tok-comment">// TODO: also xtensa</span>
</span>
<span class="line" id="L1826">        .mips, .mipsel, .mips64, .mips64el =&gt; <span class="tok-number">0x10</span>,</span>
<span class="line" id="L1827">        <span class="tok-kw">else</span> =&gt; <span class="tok-number">0x8</span>,</span>
<span class="line" id="L1828">    };</span>
<span class="line" id="L1829">    <span class="tok-comment">/// mprotect flag: extend change to start of growsdown vma</span></span>
<span class="line" id="L1830">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> GROWSDOWN = <span class="tok-number">0x01000000</span>;</span>
<span class="line" id="L1831">    <span class="tok-comment">/// mprotect flag: extend change to end of growsup vma</span></span>
<span class="line" id="L1832">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> GROWSUP = <span class="tok-number">0x02000000</span>;</span>
<span class="line" id="L1833">};</span>
<span class="line" id="L1834"></span>
<span class="line" id="L1835"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FD_CLOEXEC = <span class="tok-number">1</span>;</span>
<span class="line" id="L1836"></span>
<span class="line" id="L1837"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> F_OK = <span class="tok-number">0</span>;</span>
<span class="line" id="L1838"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> X_OK = <span class="tok-number">1</span>;</span>
<span class="line" id="L1839"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> W_OK = <span class="tok-number">2</span>;</span>
<span class="line" id="L1840"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> R_OK = <span class="tok-number">4</span>;</span>
<span class="line" id="L1841"></span>
<span class="line" id="L1842"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> W = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L1843">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> NOHANG = <span class="tok-number">1</span>;</span>
<span class="line" id="L1844">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> UNTRACED = <span class="tok-number">2</span>;</span>
<span class="line" id="L1845">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> STOPPED = <span class="tok-number">2</span>;</span>
<span class="line" id="L1846">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> EXITED = <span class="tok-number">4</span>;</span>
<span class="line" id="L1847">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> CONTINUED = <span class="tok-number">8</span>;</span>
<span class="line" id="L1848">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> NOWAIT = <span class="tok-number">0x1000000</span>;</span>
<span class="line" id="L1849"></span>
<span class="line" id="L1850">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">EXITSTATUS</span>(s: <span class="tok-type">u32</span>) <span class="tok-type">u8</span> {</span>
<span class="line" id="L1851">        <span class="tok-kw">return</span> <span class="tok-builtin">@intCast</span>(<span class="tok-type">u8</span>, (s &amp; <span class="tok-number">0xff00</span>) &gt;&gt; <span class="tok-number">8</span>);</span>
<span class="line" id="L1852">    }</span>
<span class="line" id="L1853">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">TERMSIG</span>(s: <span class="tok-type">u32</span>) <span class="tok-type">u32</span> {</span>
<span class="line" id="L1854">        <span class="tok-kw">return</span> s &amp; <span class="tok-number">0x7f</span>;</span>
<span class="line" id="L1855">    }</span>
<span class="line" id="L1856">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">STOPSIG</span>(s: <span class="tok-type">u32</span>) <span class="tok-type">u32</span> {</span>
<span class="line" id="L1857">        <span class="tok-kw">return</span> EXITSTATUS(s);</span>
<span class="line" id="L1858">    }</span>
<span class="line" id="L1859">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">IFEXITED</span>(s: <span class="tok-type">u32</span>) <span class="tok-type">bool</span> {</span>
<span class="line" id="L1860">        <span class="tok-kw">return</span> TERMSIG(s) == <span class="tok-number">0</span>;</span>
<span class="line" id="L1861">    }</span>
<span class="line" id="L1862">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">IFSTOPPED</span>(s: <span class="tok-type">u32</span>) <span class="tok-type">bool</span> {</span>
<span class="line" id="L1863">        <span class="tok-kw">return</span> <span class="tok-builtin">@truncate</span>(<span class="tok-type">u16</span>, ((s &amp; <span class="tok-number">0xffff</span>) *% <span class="tok-number">0x10001</span>) &gt;&gt; <span class="tok-number">8</span>) &gt; <span class="tok-number">0x7f00</span>;</span>
<span class="line" id="L1864">    }</span>
<span class="line" id="L1865">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">IFSIGNALED</span>(s: <span class="tok-type">u32</span>) <span class="tok-type">bool</span> {</span>
<span class="line" id="L1866">        <span class="tok-kw">return</span> (s &amp; <span class="tok-number">0xffff</span>) -% <span class="tok-number">1</span> &lt; <span class="tok-number">0xff</span>;</span>
<span class="line" id="L1867">    }</span>
<span class="line" id="L1868">};</span>
<span class="line" id="L1869"></span>
<span class="line" id="L1870"><span class="tok-comment">// waitid id types</span>
</span>
<span class="line" id="L1871"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> P = <span class="tok-kw">enum</span>(<span class="tok-type">c_uint</span>) {</span>
<span class="line" id="L1872">    ALL = <span class="tok-number">0</span>,</span>
<span class="line" id="L1873">    PID = <span class="tok-number">1</span>,</span>
<span class="line" id="L1874">    PGID = <span class="tok-number">2</span>,</span>
<span class="line" id="L1875">    PIDFD = <span class="tok-number">3</span>,</span>
<span class="line" id="L1876">    _,</span>
<span class="line" id="L1877">};</span>
<span class="line" id="L1878"></span>
<span class="line" id="L1879"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SA = <span class="tok-kw">if</span> (is_mips) <span class="tok-kw">struct</span> {</span>
<span class="line" id="L1880">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> NOCLDSTOP = <span class="tok-number">1</span>;</span>
<span class="line" id="L1881">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> NOCLDWAIT = <span class="tok-number">0x10000</span>;</span>
<span class="line" id="L1882">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> SIGINFO = <span class="tok-number">8</span>;</span>
<span class="line" id="L1883">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> RESTART = <span class="tok-number">0x10000000</span>;</span>
<span class="line" id="L1884">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> RESETHAND = <span class="tok-number">0x80000000</span>;</span>
<span class="line" id="L1885">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> ONSTACK = <span class="tok-number">0x08000000</span>;</span>
<span class="line" id="L1886">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> NODEFER = <span class="tok-number">0x40000000</span>;</span>
<span class="line" id="L1887">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> RESTORER = <span class="tok-number">0x04000000</span>;</span>
<span class="line" id="L1888">} <span class="tok-kw">else</span> <span class="tok-kw">if</span> (is_sparc) <span class="tok-kw">struct</span> {</span>
<span class="line" id="L1889">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> NOCLDSTOP = <span class="tok-number">0x8</span>;</span>
<span class="line" id="L1890">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> NOCLDWAIT = <span class="tok-number">0x100</span>;</span>
<span class="line" id="L1891">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> SIGINFO = <span class="tok-number">0x200</span>;</span>
<span class="line" id="L1892">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> RESTART = <span class="tok-number">0x2</span>;</span>
<span class="line" id="L1893">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> RESETHAND = <span class="tok-number">0x4</span>;</span>
<span class="line" id="L1894">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> ONSTACK = <span class="tok-number">0x1</span>;</span>
<span class="line" id="L1895">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> NODEFER = <span class="tok-number">0x20</span>;</span>
<span class="line" id="L1896">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> RESTORER = <span class="tok-number">0x04000000</span>;</span>
<span class="line" id="L1897">} <span class="tok-kw">else</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L1898">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> NOCLDSTOP = <span class="tok-number">1</span>;</span>
<span class="line" id="L1899">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> NOCLDWAIT = <span class="tok-number">2</span>;</span>
<span class="line" id="L1900">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> SIGINFO = <span class="tok-number">4</span>;</span>
<span class="line" id="L1901">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> RESTART = <span class="tok-number">0x10000000</span>;</span>
<span class="line" id="L1902">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> RESETHAND = <span class="tok-number">0x80000000</span>;</span>
<span class="line" id="L1903">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> ONSTACK = <span class="tok-number">0x08000000</span>;</span>
<span class="line" id="L1904">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> NODEFER = <span class="tok-number">0x40000000</span>;</span>
<span class="line" id="L1905">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> RESTORER = <span class="tok-number">0x04000000</span>;</span>
<span class="line" id="L1906">};</span>
<span class="line" id="L1907"></span>
<span class="line" id="L1908"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SIG = <span class="tok-kw">if</span> (is_mips) <span class="tok-kw">struct</span> {</span>
<span class="line" id="L1909">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> BLOCK = <span class="tok-number">1</span>;</span>
<span class="line" id="L1910">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> UNBLOCK = <span class="tok-number">2</span>;</span>
<span class="line" id="L1911">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> SETMASK = <span class="tok-number">3</span>;</span>
<span class="line" id="L1912"></span>
<span class="line" id="L1913">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> HUP = <span class="tok-number">1</span>;</span>
<span class="line" id="L1914">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> INT = <span class="tok-number">2</span>;</span>
<span class="line" id="L1915">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> QUIT = <span class="tok-number">3</span>;</span>
<span class="line" id="L1916">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> ILL = <span class="tok-number">4</span>;</span>
<span class="line" id="L1917">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> TRAP = <span class="tok-number">5</span>;</span>
<span class="line" id="L1918">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> ABRT = <span class="tok-number">6</span>;</span>
<span class="line" id="L1919">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> IOT = ABRT;</span>
<span class="line" id="L1920">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> BUS = <span class="tok-number">7</span>;</span>
<span class="line" id="L1921">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> FPE = <span class="tok-number">8</span>;</span>
<span class="line" id="L1922">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> KILL = <span class="tok-number">9</span>;</span>
<span class="line" id="L1923">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> USR1 = <span class="tok-number">10</span>;</span>
<span class="line" id="L1924">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> SEGV = <span class="tok-number">11</span>;</span>
<span class="line" id="L1925">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> USR2 = <span class="tok-number">12</span>;</span>
<span class="line" id="L1926">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> PIPE = <span class="tok-number">13</span>;</span>
<span class="line" id="L1927">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> ALRM = <span class="tok-number">14</span>;</span>
<span class="line" id="L1928">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> TERM = <span class="tok-number">15</span>;</span>
<span class="line" id="L1929">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> STKFLT = <span class="tok-number">16</span>;</span>
<span class="line" id="L1930">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> CHLD = <span class="tok-number">17</span>;</span>
<span class="line" id="L1931">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> CONT = <span class="tok-number">18</span>;</span>
<span class="line" id="L1932">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> STOP = <span class="tok-number">19</span>;</span>
<span class="line" id="L1933">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> TSTP = <span class="tok-number">20</span>;</span>
<span class="line" id="L1934">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> TTIN = <span class="tok-number">21</span>;</span>
<span class="line" id="L1935">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> TTOU = <span class="tok-number">22</span>;</span>
<span class="line" id="L1936">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> URG = <span class="tok-number">23</span>;</span>
<span class="line" id="L1937">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> XCPU = <span class="tok-number">24</span>;</span>
<span class="line" id="L1938">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> XFSZ = <span class="tok-number">25</span>;</span>
<span class="line" id="L1939">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> VTALRM = <span class="tok-number">26</span>;</span>
<span class="line" id="L1940">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> PROF = <span class="tok-number">27</span>;</span>
<span class="line" id="L1941">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> WINCH = <span class="tok-number">28</span>;</span>
<span class="line" id="L1942">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> IO = <span class="tok-number">29</span>;</span>
<span class="line" id="L1943">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> POLL = <span class="tok-number">29</span>;</span>
<span class="line" id="L1944">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> PWR = <span class="tok-number">30</span>;</span>
<span class="line" id="L1945">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> SYS = <span class="tok-number">31</span>;</span>
<span class="line" id="L1946">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> UNUSED = SIG.SYS;</span>
<span class="line" id="L1947"></span>
<span class="line" id="L1948">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> ERR = <span class="tok-builtin">@intToPtr</span>(?Sigaction.handler_fn, maxInt(<span class="tok-type">usize</span>));</span>
<span class="line" id="L1949">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> DFL = <span class="tok-builtin">@intToPtr</span>(?Sigaction.handler_fn, <span class="tok-number">0</span>);</span>
<span class="line" id="L1950">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> IGN = <span class="tok-builtin">@intToPtr</span>(?Sigaction.handler_fn, <span class="tok-number">1</span>);</span>
<span class="line" id="L1951">} <span class="tok-kw">else</span> <span class="tok-kw">if</span> (is_sparc) <span class="tok-kw">struct</span> {</span>
<span class="line" id="L1952">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> BLOCK = <span class="tok-number">1</span>;</span>
<span class="line" id="L1953">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> UNBLOCK = <span class="tok-number">2</span>;</span>
<span class="line" id="L1954">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> SETMASK = <span class="tok-number">4</span>;</span>
<span class="line" id="L1955"></span>
<span class="line" id="L1956">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> HUP = <span class="tok-number">1</span>;</span>
<span class="line" id="L1957">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> INT = <span class="tok-number">2</span>;</span>
<span class="line" id="L1958">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> QUIT = <span class="tok-number">3</span>;</span>
<span class="line" id="L1959">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> ILL = <span class="tok-number">4</span>;</span>
<span class="line" id="L1960">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> TRAP = <span class="tok-number">5</span>;</span>
<span class="line" id="L1961">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> ABRT = <span class="tok-number">6</span>;</span>
<span class="line" id="L1962">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> EMT = <span class="tok-number">7</span>;</span>
<span class="line" id="L1963">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> FPE = <span class="tok-number">8</span>;</span>
<span class="line" id="L1964">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> KILL = <span class="tok-number">9</span>;</span>
<span class="line" id="L1965">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> BUS = <span class="tok-number">10</span>;</span>
<span class="line" id="L1966">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> SEGV = <span class="tok-number">11</span>;</span>
<span class="line" id="L1967">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> SYS = <span class="tok-number">12</span>;</span>
<span class="line" id="L1968">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> PIPE = <span class="tok-number">13</span>;</span>
<span class="line" id="L1969">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> ALRM = <span class="tok-number">14</span>;</span>
<span class="line" id="L1970">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> TERM = <span class="tok-number">15</span>;</span>
<span class="line" id="L1971">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> URG = <span class="tok-number">16</span>;</span>
<span class="line" id="L1972">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> STOP = <span class="tok-number">17</span>;</span>
<span class="line" id="L1973">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> TSTP = <span class="tok-number">18</span>;</span>
<span class="line" id="L1974">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> CONT = <span class="tok-number">19</span>;</span>
<span class="line" id="L1975">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> CHLD = <span class="tok-number">20</span>;</span>
<span class="line" id="L1976">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> TTIN = <span class="tok-number">21</span>;</span>
<span class="line" id="L1977">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> TTOU = <span class="tok-number">22</span>;</span>
<span class="line" id="L1978">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> POLL = <span class="tok-number">23</span>;</span>
<span class="line" id="L1979">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> XCPU = <span class="tok-number">24</span>;</span>
<span class="line" id="L1980">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> XFSZ = <span class="tok-number">25</span>;</span>
<span class="line" id="L1981">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> VTALRM = <span class="tok-number">26</span>;</span>
<span class="line" id="L1982">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> PROF = <span class="tok-number">27</span>;</span>
<span class="line" id="L1983">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> WINCH = <span class="tok-number">28</span>;</span>
<span class="line" id="L1984">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> LOST = <span class="tok-number">29</span>;</span>
<span class="line" id="L1985">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> USR1 = <span class="tok-number">30</span>;</span>
<span class="line" id="L1986">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> USR2 = <span class="tok-number">31</span>;</span>
<span class="line" id="L1987">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> IOT = ABRT;</span>
<span class="line" id="L1988">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> CLD = CHLD;</span>
<span class="line" id="L1989">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> PWR = LOST;</span>
<span class="line" id="L1990">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> IO = SIG.POLL;</span>
<span class="line" id="L1991"></span>
<span class="line" id="L1992">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> ERR = <span class="tok-builtin">@intToPtr</span>(?Sigaction.handler_fn, maxInt(<span class="tok-type">usize</span>));</span>
<span class="line" id="L1993">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> DFL = <span class="tok-builtin">@intToPtr</span>(?Sigaction.handler_fn, <span class="tok-number">0</span>);</span>
<span class="line" id="L1994">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> IGN = <span class="tok-builtin">@intToPtr</span>(?Sigaction.handler_fn, <span class="tok-number">1</span>);</span>
<span class="line" id="L1995">} <span class="tok-kw">else</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L1996">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> BLOCK = <span class="tok-number">0</span>;</span>
<span class="line" id="L1997">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> UNBLOCK = <span class="tok-number">1</span>;</span>
<span class="line" id="L1998">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> SETMASK = <span class="tok-number">2</span>;</span>
<span class="line" id="L1999"></span>
<span class="line" id="L2000">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> HUP = <span class="tok-number">1</span>;</span>
<span class="line" id="L2001">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> INT = <span class="tok-number">2</span>;</span>
<span class="line" id="L2002">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> QUIT = <span class="tok-number">3</span>;</span>
<span class="line" id="L2003">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> ILL = <span class="tok-number">4</span>;</span>
<span class="line" id="L2004">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> TRAP = <span class="tok-number">5</span>;</span>
<span class="line" id="L2005">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> ABRT = <span class="tok-number">6</span>;</span>
<span class="line" id="L2006">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> IOT = ABRT;</span>
<span class="line" id="L2007">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> BUS = <span class="tok-number">7</span>;</span>
<span class="line" id="L2008">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> FPE = <span class="tok-number">8</span>;</span>
<span class="line" id="L2009">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> KILL = <span class="tok-number">9</span>;</span>
<span class="line" id="L2010">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> USR1 = <span class="tok-number">10</span>;</span>
<span class="line" id="L2011">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> SEGV = <span class="tok-number">11</span>;</span>
<span class="line" id="L2012">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> USR2 = <span class="tok-number">12</span>;</span>
<span class="line" id="L2013">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> PIPE = <span class="tok-number">13</span>;</span>
<span class="line" id="L2014">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> ALRM = <span class="tok-number">14</span>;</span>
<span class="line" id="L2015">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> TERM = <span class="tok-number">15</span>;</span>
<span class="line" id="L2016">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> STKFLT = <span class="tok-number">16</span>;</span>
<span class="line" id="L2017">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> CHLD = <span class="tok-number">17</span>;</span>
<span class="line" id="L2018">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> CONT = <span class="tok-number">18</span>;</span>
<span class="line" id="L2019">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> STOP = <span class="tok-number">19</span>;</span>
<span class="line" id="L2020">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> TSTP = <span class="tok-number">20</span>;</span>
<span class="line" id="L2021">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> TTIN = <span class="tok-number">21</span>;</span>
<span class="line" id="L2022">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> TTOU = <span class="tok-number">22</span>;</span>
<span class="line" id="L2023">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> URG = <span class="tok-number">23</span>;</span>
<span class="line" id="L2024">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> XCPU = <span class="tok-number">24</span>;</span>
<span class="line" id="L2025">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> XFSZ = <span class="tok-number">25</span>;</span>
<span class="line" id="L2026">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> VTALRM = <span class="tok-number">26</span>;</span>
<span class="line" id="L2027">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> PROF = <span class="tok-number">27</span>;</span>
<span class="line" id="L2028">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> WINCH = <span class="tok-number">28</span>;</span>
<span class="line" id="L2029">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> IO = <span class="tok-number">29</span>;</span>
<span class="line" id="L2030">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> POLL = <span class="tok-number">29</span>;</span>
<span class="line" id="L2031">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> PWR = <span class="tok-number">30</span>;</span>
<span class="line" id="L2032">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> SYS = <span class="tok-number">31</span>;</span>
<span class="line" id="L2033">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> UNUSED = SIG.SYS;</span>
<span class="line" id="L2034"></span>
<span class="line" id="L2035">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> ERR = <span class="tok-builtin">@intToPtr</span>(?Sigaction.handler_fn, maxInt(<span class="tok-type">usize</span>));</span>
<span class="line" id="L2036">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> DFL = <span class="tok-builtin">@intToPtr</span>(?Sigaction.handler_fn, <span class="tok-number">0</span>);</span>
<span class="line" id="L2037">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> IGN = <span class="tok-builtin">@intToPtr</span>(?Sigaction.handler_fn, <span class="tok-number">1</span>);</span>
<span class="line" id="L2038">};</span>
<span class="line" id="L2039"></span>
<span class="line" id="L2040"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> kernel_rwf = <span class="tok-type">u32</span>;</span>
<span class="line" id="L2041"></span>
<span class="line" id="L2042"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> RWF = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L2043">    <span class="tok-comment">/// high priority request, poll if possible</span></span>
<span class="line" id="L2044">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> HIPRI: kernel_rwf = <span class="tok-number">0x00000001</span>;</span>
<span class="line" id="L2045"></span>
<span class="line" id="L2046">    <span class="tok-comment">/// per-IO O.DSYNC</span></span>
<span class="line" id="L2047">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> DSYNC: kernel_rwf = <span class="tok-number">0x00000002</span>;</span>
<span class="line" id="L2048"></span>
<span class="line" id="L2049">    <span class="tok-comment">/// per-IO O.SYNC</span></span>
<span class="line" id="L2050">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> SYNC: kernel_rwf = <span class="tok-number">0x00000004</span>;</span>
<span class="line" id="L2051"></span>
<span class="line" id="L2052">    <span class="tok-comment">/// per-IO, return -EAGAIN if operation would block</span></span>
<span class="line" id="L2053">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> NOWAIT: kernel_rwf = <span class="tok-number">0x00000008</span>;</span>
<span class="line" id="L2054"></span>
<span class="line" id="L2055">    <span class="tok-comment">/// per-IO O.APPEND</span></span>
<span class="line" id="L2056">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> APPEND: kernel_rwf = <span class="tok-number">0x00000010</span>;</span>
<span class="line" id="L2057">};</span>
<span class="line" id="L2058"></span>
<span class="line" id="L2059"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SEEK = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L2060">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> SET = <span class="tok-number">0</span>;</span>
<span class="line" id="L2061">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> CUR = <span class="tok-number">1</span>;</span>
<span class="line" id="L2062">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> END = <span class="tok-number">2</span>;</span>
<span class="line" id="L2063">};</span>
<span class="line" id="L2064"></span>
<span class="line" id="L2065"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SHUT = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L2066">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> RD = <span class="tok-number">0</span>;</span>
<span class="line" id="L2067">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> WR = <span class="tok-number">1</span>;</span>
<span class="line" id="L2068">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> RDWR = <span class="tok-number">2</span>;</span>
<span class="line" id="L2069">};</span>
<span class="line" id="L2070"></span>
<span class="line" id="L2071"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SOCK = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L2072">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> STREAM = <span class="tok-kw">if</span> (is_mips) <span class="tok-number">2</span> <span class="tok-kw">else</span> <span class="tok-number">1</span>;</span>
<span class="line" id="L2073">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> DGRAM = <span class="tok-kw">if</span> (is_mips) <span class="tok-number">1</span> <span class="tok-kw">else</span> <span class="tok-number">2</span>;</span>
<span class="line" id="L2074">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> RAW = <span class="tok-number">3</span>;</span>
<span class="line" id="L2075">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> RDM = <span class="tok-number">4</span>;</span>
<span class="line" id="L2076">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> SEQPACKET = <span class="tok-number">5</span>;</span>
<span class="line" id="L2077">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> DCCP = <span class="tok-number">6</span>;</span>
<span class="line" id="L2078">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> PACKET = <span class="tok-number">10</span>;</span>
<span class="line" id="L2079">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> CLOEXEC = <span class="tok-kw">if</span> (is_sparc) <span class="tok-number">0o20000000</span> <span class="tok-kw">else</span> <span class="tok-number">0o2000000</span>;</span>
<span class="line" id="L2080">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> NONBLOCK = <span class="tok-kw">if</span> (is_mips) <span class="tok-number">0o200</span> <span class="tok-kw">else</span> <span class="tok-kw">if</span> (is_sparc) <span class="tok-number">0o40000</span> <span class="tok-kw">else</span> <span class="tok-number">0o4000</span>;</span>
<span class="line" id="L2081">};</span>
<span class="line" id="L2082"></span>
<span class="line" id="L2083"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> TCP = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L2084">    <span class="tok-comment">/// Turn off Nagle's algorithm</span></span>
<span class="line" id="L2085">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> NODELAY = <span class="tok-number">1</span>;</span>
<span class="line" id="L2086">    <span class="tok-comment">/// Limit MSS</span></span>
<span class="line" id="L2087">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> MAXSEG = <span class="tok-number">2</span>;</span>
<span class="line" id="L2088">    <span class="tok-comment">/// Never send partially complete segments.</span></span>
<span class="line" id="L2089">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> CORK = <span class="tok-number">3</span>;</span>
<span class="line" id="L2090">    <span class="tok-comment">/// Start keeplives after this period, in seconds</span></span>
<span class="line" id="L2091">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> KEEPIDLE = <span class="tok-number">4</span>;</span>
<span class="line" id="L2092">    <span class="tok-comment">/// Interval between keepalives</span></span>
<span class="line" id="L2093">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> KEEPINTVL = <span class="tok-number">5</span>;</span>
<span class="line" id="L2094">    <span class="tok-comment">/// Number of keepalives before death</span></span>
<span class="line" id="L2095">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> KEEPCNT = <span class="tok-number">6</span>;</span>
<span class="line" id="L2096">    <span class="tok-comment">/// Number of SYN retransmits</span></span>
<span class="line" id="L2097">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> SYNCNT = <span class="tok-number">7</span>;</span>
<span class="line" id="L2098">    <span class="tok-comment">/// Life time of orphaned FIN-WAIT-2 state</span></span>
<span class="line" id="L2099">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> LINGER2 = <span class="tok-number">8</span>;</span>
<span class="line" id="L2100">    <span class="tok-comment">/// Wake up listener only when data arrive</span></span>
<span class="line" id="L2101">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> DEFER_ACCEPT = <span class="tok-number">9</span>;</span>
<span class="line" id="L2102">    <span class="tok-comment">/// Bound advertised window</span></span>
<span class="line" id="L2103">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> WINDOW_CLAMP = <span class="tok-number">10</span>;</span>
<span class="line" id="L2104">    <span class="tok-comment">/// Information about this connection.</span></span>
<span class="line" id="L2105">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> INFO = <span class="tok-number">11</span>;</span>
<span class="line" id="L2106">    <span class="tok-comment">/// Block/reenable quick acks</span></span>
<span class="line" id="L2107">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> QUICKACK = <span class="tok-number">12</span>;</span>
<span class="line" id="L2108">    <span class="tok-comment">/// Congestion control algorithm</span></span>
<span class="line" id="L2109">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> CONGESTION = <span class="tok-number">13</span>;</span>
<span class="line" id="L2110">    <span class="tok-comment">/// TCP MD5 Signature (RFC2385)</span></span>
<span class="line" id="L2111">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> MD5SIG = <span class="tok-number">14</span>;</span>
<span class="line" id="L2112">    <span class="tok-comment">/// Use linear timeouts for thin streams</span></span>
<span class="line" id="L2113">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> THIN_LINEAR_TIMEOUTS = <span class="tok-number">16</span>;</span>
<span class="line" id="L2114">    <span class="tok-comment">/// Fast retrans. after 1 dupack</span></span>
<span class="line" id="L2115">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> THIN_DUPACK = <span class="tok-number">17</span>;</span>
<span class="line" id="L2116">    <span class="tok-comment">/// How long for loss retry before timeout</span></span>
<span class="line" id="L2117">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> USER_TIMEOUT = <span class="tok-number">18</span>;</span>
<span class="line" id="L2118">    <span class="tok-comment">/// TCP sock is under repair right now</span></span>
<span class="line" id="L2119">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> REPAIR = <span class="tok-number">19</span>;</span>
<span class="line" id="L2120">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> REPAIR_QUEUE = <span class="tok-number">20</span>;</span>
<span class="line" id="L2121">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> QUEUE_SEQ = <span class="tok-number">21</span>;</span>
<span class="line" id="L2122">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> REPAIR_OPTIONS = <span class="tok-number">22</span>;</span>
<span class="line" id="L2123">    <span class="tok-comment">/// Enable FastOpen on listeners</span></span>
<span class="line" id="L2124">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> FASTOPEN = <span class="tok-number">23</span>;</span>
<span class="line" id="L2125">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> TIMESTAMP = <span class="tok-number">24</span>;</span>
<span class="line" id="L2126">    <span class="tok-comment">/// limit number of unsent bytes in write queue</span></span>
<span class="line" id="L2127">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> NOTSENT_LOWAT = <span class="tok-number">25</span>;</span>
<span class="line" id="L2128">    <span class="tok-comment">/// Get Congestion Control (optional) info</span></span>
<span class="line" id="L2129">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> CC_INFO = <span class="tok-number">26</span>;</span>
<span class="line" id="L2130">    <span class="tok-comment">/// Record SYN headers for new connections</span></span>
<span class="line" id="L2131">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> SAVE_SYN = <span class="tok-number">27</span>;</span>
<span class="line" id="L2132">    <span class="tok-comment">/// Get SYN headers recorded for connection</span></span>
<span class="line" id="L2133">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> SAVED_SYN = <span class="tok-number">28</span>;</span>
<span class="line" id="L2134">    <span class="tok-comment">/// Get/set window parameters</span></span>
<span class="line" id="L2135">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> REPAIR_WINDOW = <span class="tok-number">29</span>;</span>
<span class="line" id="L2136">    <span class="tok-comment">/// Attempt FastOpen with connect</span></span>
<span class="line" id="L2137">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> FASTOPEN_CONNECT = <span class="tok-number">30</span>;</span>
<span class="line" id="L2138">    <span class="tok-comment">/// Attach a ULP to a TCP connection</span></span>
<span class="line" id="L2139">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> ULP = <span class="tok-number">31</span>;</span>
<span class="line" id="L2140">    <span class="tok-comment">/// TCP MD5 Signature with extensions</span></span>
<span class="line" id="L2141">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> MD5SIG_EXT = <span class="tok-number">32</span>;</span>
<span class="line" id="L2142">    <span class="tok-comment">/// Set the key for Fast Open (cookie)</span></span>
<span class="line" id="L2143">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> FASTOPEN_KEY = <span class="tok-number">33</span>;</span>
<span class="line" id="L2144">    <span class="tok-comment">/// Enable TFO without a TFO cookie</span></span>
<span class="line" id="L2145">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> FASTOPEN_NO_COOKIE = <span class="tok-number">34</span>;</span>
<span class="line" id="L2146">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> ZEROCOPY_RECEIVE = <span class="tok-number">35</span>;</span>
<span class="line" id="L2147">    <span class="tok-comment">/// Notify bytes available to read as a cmsg on read</span></span>
<span class="line" id="L2148">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> INQ = <span class="tok-number">36</span>;</span>
<span class="line" id="L2149">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> CM_INQ = INQ;</span>
<span class="line" id="L2150">    <span class="tok-comment">/// delay outgoing packets by XX usec</span></span>
<span class="line" id="L2151">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> TX_DELAY = <span class="tok-number">37</span>;</span>
<span class="line" id="L2152"></span>
<span class="line" id="L2153">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> REPAIR_ON = <span class="tok-number">1</span>;</span>
<span class="line" id="L2154">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> REPAIR_OFF = <span class="tok-number">0</span>;</span>
<span class="line" id="L2155">    <span class="tok-comment">/// Turn off without window probes</span></span>
<span class="line" id="L2156">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> REPAIR_OFF_NO_WP = -<span class="tok-number">1</span>;</span>
<span class="line" id="L2157">};</span>
<span class="line" id="L2158"></span>
<span class="line" id="L2159"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> PF = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L2160">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> UNSPEC = <span class="tok-number">0</span>;</span>
<span class="line" id="L2161">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> LOCAL = <span class="tok-number">1</span>;</span>
<span class="line" id="L2162">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> UNIX = LOCAL;</span>
<span class="line" id="L2163">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> FILE = LOCAL;</span>
<span class="line" id="L2164">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> INET = <span class="tok-number">2</span>;</span>
<span class="line" id="L2165">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> AX25 = <span class="tok-number">3</span>;</span>
<span class="line" id="L2166">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> IPX = <span class="tok-number">4</span>;</span>
<span class="line" id="L2167">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> APPLETALK = <span class="tok-number">5</span>;</span>
<span class="line" id="L2168">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> NETROM = <span class="tok-number">6</span>;</span>
<span class="line" id="L2169">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> BRIDGE = <span class="tok-number">7</span>;</span>
<span class="line" id="L2170">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> ATMPVC = <span class="tok-number">8</span>;</span>
<span class="line" id="L2171">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> X25 = <span class="tok-number">9</span>;</span>
<span class="line" id="L2172">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> INET6 = <span class="tok-number">10</span>;</span>
<span class="line" id="L2173">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> ROSE = <span class="tok-number">11</span>;</span>
<span class="line" id="L2174">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> DECnet = <span class="tok-number">12</span>;</span>
<span class="line" id="L2175">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> NETBEUI = <span class="tok-number">13</span>;</span>
<span class="line" id="L2176">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> SECURITY = <span class="tok-number">14</span>;</span>
<span class="line" id="L2177">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> KEY = <span class="tok-number">15</span>;</span>
<span class="line" id="L2178">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> NETLINK = <span class="tok-number">16</span>;</span>
<span class="line" id="L2179">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> ROUTE = PF.NETLINK;</span>
<span class="line" id="L2180">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> PACKET = <span class="tok-number">17</span>;</span>
<span class="line" id="L2181">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> ASH = <span class="tok-number">18</span>;</span>
<span class="line" id="L2182">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> ECONET = <span class="tok-number">19</span>;</span>
<span class="line" id="L2183">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> ATMSVC = <span class="tok-number">20</span>;</span>
<span class="line" id="L2184">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> RDS = <span class="tok-number">21</span>;</span>
<span class="line" id="L2185">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> SNA = <span class="tok-number">22</span>;</span>
<span class="line" id="L2186">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> IRDA = <span class="tok-number">23</span>;</span>
<span class="line" id="L2187">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> PPPOX = <span class="tok-number">24</span>;</span>
<span class="line" id="L2188">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> WANPIPE = <span class="tok-number">25</span>;</span>
<span class="line" id="L2189">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> LLC = <span class="tok-number">26</span>;</span>
<span class="line" id="L2190">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> IB = <span class="tok-number">27</span>;</span>
<span class="line" id="L2191">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> MPLS = <span class="tok-number">28</span>;</span>
<span class="line" id="L2192">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> CAN = <span class="tok-number">29</span>;</span>
<span class="line" id="L2193">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> TIPC = <span class="tok-number">30</span>;</span>
<span class="line" id="L2194">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> BLUETOOTH = <span class="tok-number">31</span>;</span>
<span class="line" id="L2195">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> IUCV = <span class="tok-number">32</span>;</span>
<span class="line" id="L2196">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> RXRPC = <span class="tok-number">33</span>;</span>
<span class="line" id="L2197">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> ISDN = <span class="tok-number">34</span>;</span>
<span class="line" id="L2198">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> PHONET = <span class="tok-number">35</span>;</span>
<span class="line" id="L2199">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> IEEE802154 = <span class="tok-number">36</span>;</span>
<span class="line" id="L2200">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> CAIF = <span class="tok-number">37</span>;</span>
<span class="line" id="L2201">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> ALG = <span class="tok-number">38</span>;</span>
<span class="line" id="L2202">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> NFC = <span class="tok-number">39</span>;</span>
<span class="line" id="L2203">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> VSOCK = <span class="tok-number">40</span>;</span>
<span class="line" id="L2204">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> KCM = <span class="tok-number">41</span>;</span>
<span class="line" id="L2205">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> QIPCRTR = <span class="tok-number">42</span>;</span>
<span class="line" id="L2206">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> SMC = <span class="tok-number">43</span>;</span>
<span class="line" id="L2207">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> XDP = <span class="tok-number">44</span>;</span>
<span class="line" id="L2208">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> MAX = <span class="tok-number">45</span>;</span>
<span class="line" id="L2209">};</span>
<span class="line" id="L2210"></span>
<span class="line" id="L2211"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> AF = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L2212">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> UNSPEC = PF.UNSPEC;</span>
<span class="line" id="L2213">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> LOCAL = PF.LOCAL;</span>
<span class="line" id="L2214">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> UNIX = AF.LOCAL;</span>
<span class="line" id="L2215">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> FILE = AF.LOCAL;</span>
<span class="line" id="L2216">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> INET = PF.INET;</span>
<span class="line" id="L2217">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> AX25 = PF.AX25;</span>
<span class="line" id="L2218">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> IPX = PF.IPX;</span>
<span class="line" id="L2219">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> APPLETALK = PF.APPLETALK;</span>
<span class="line" id="L2220">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> NETROM = PF.NETROM;</span>
<span class="line" id="L2221">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> BRIDGE = PF.BRIDGE;</span>
<span class="line" id="L2222">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> ATMPVC = PF.ATMPVC;</span>
<span class="line" id="L2223">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> X25 = PF.X25;</span>
<span class="line" id="L2224">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> INET6 = PF.INET6;</span>
<span class="line" id="L2225">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> ROSE = PF.ROSE;</span>
<span class="line" id="L2226">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> DECnet = PF.DECnet;</span>
<span class="line" id="L2227">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> NETBEUI = PF.NETBEUI;</span>
<span class="line" id="L2228">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> SECURITY = PF.SECURITY;</span>
<span class="line" id="L2229">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> KEY = PF.KEY;</span>
<span class="line" id="L2230">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> NETLINK = PF.NETLINK;</span>
<span class="line" id="L2231">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> ROUTE = PF.ROUTE;</span>
<span class="line" id="L2232">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> PACKET = PF.PACKET;</span>
<span class="line" id="L2233">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> ASH = PF.ASH;</span>
<span class="line" id="L2234">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> ECONET = PF.ECONET;</span>
<span class="line" id="L2235">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> ATMSVC = PF.ATMSVC;</span>
<span class="line" id="L2236">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> RDS = PF.RDS;</span>
<span class="line" id="L2237">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> SNA = PF.SNA;</span>
<span class="line" id="L2238">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> IRDA = PF.IRDA;</span>
<span class="line" id="L2239">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> PPPOX = PF.PPPOX;</span>
<span class="line" id="L2240">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> WANPIPE = PF.WANPIPE;</span>
<span class="line" id="L2241">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> LLC = PF.LLC;</span>
<span class="line" id="L2242">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> IB = PF.IB;</span>
<span class="line" id="L2243">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> MPLS = PF.MPLS;</span>
<span class="line" id="L2244">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> CAN = PF.CAN;</span>
<span class="line" id="L2245">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> TIPC = PF.TIPC;</span>
<span class="line" id="L2246">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> BLUETOOTH = PF.BLUETOOTH;</span>
<span class="line" id="L2247">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> IUCV = PF.IUCV;</span>
<span class="line" id="L2248">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> RXRPC = PF.RXRPC;</span>
<span class="line" id="L2249">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> ISDN = PF.ISDN;</span>
<span class="line" id="L2250">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> PHONET = PF.PHONET;</span>
<span class="line" id="L2251">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> IEEE802154 = PF.IEEE802154;</span>
<span class="line" id="L2252">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> CAIF = PF.CAIF;</span>
<span class="line" id="L2253">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> ALG = PF.ALG;</span>
<span class="line" id="L2254">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> NFC = PF.NFC;</span>
<span class="line" id="L2255">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> VSOCK = PF.VSOCK;</span>
<span class="line" id="L2256">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> KCM = PF.KCM;</span>
<span class="line" id="L2257">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> QIPCRTR = PF.QIPCRTR;</span>
<span class="line" id="L2258">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> SMC = PF.SMC;</span>
<span class="line" id="L2259">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> XDP = PF.XDP;</span>
<span class="line" id="L2260">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> MAX = PF.MAX;</span>
<span class="line" id="L2261">};</span>
<span class="line" id="L2262"></span>
<span class="line" id="L2263"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SO = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L2264">    <span class="tok-kw">pub</span> <span class="tok-kw">usingnamespace</span> <span class="tok-kw">if</span> (is_mips) <span class="tok-kw">struct</span> {</span>
<span class="line" id="L2265">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> DEBUG = <span class="tok-number">1</span>;</span>
<span class="line" id="L2266">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> REUSEADDR = <span class="tok-number">0x0004</span>;</span>
<span class="line" id="L2267">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> KEEPALIVE = <span class="tok-number">0x0008</span>;</span>
<span class="line" id="L2268">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> DONTROUTE = <span class="tok-number">0x0010</span>;</span>
<span class="line" id="L2269">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> BROADCAST = <span class="tok-number">0x0020</span>;</span>
<span class="line" id="L2270">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> LINGER = <span class="tok-number">0x0080</span>;</span>
<span class="line" id="L2271">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> OOBINLINE = <span class="tok-number">0x0100</span>;</span>
<span class="line" id="L2272">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> REUSEPORT = <span class="tok-number">0x0200</span>;</span>
<span class="line" id="L2273">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> SNDBUF = <span class="tok-number">0x1001</span>;</span>
<span class="line" id="L2274">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> RCVBUF = <span class="tok-number">0x1002</span>;</span>
<span class="line" id="L2275">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> SNDLOWAT = <span class="tok-number">0x1003</span>;</span>
<span class="line" id="L2276">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> RCVLOWAT = <span class="tok-number">0x1004</span>;</span>
<span class="line" id="L2277">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> RCVTIMEO = <span class="tok-number">0x1006</span>;</span>
<span class="line" id="L2278">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> SNDTIMEO = <span class="tok-number">0x1005</span>;</span>
<span class="line" id="L2279">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> ERROR = <span class="tok-number">0x1007</span>;</span>
<span class="line" id="L2280">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> TYPE = <span class="tok-number">0x1008</span>;</span>
<span class="line" id="L2281">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> ACCEPTCONN = <span class="tok-number">0x1009</span>;</span>
<span class="line" id="L2282">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> PROTOCOL = <span class="tok-number">0x1028</span>;</span>
<span class="line" id="L2283">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> DOMAIN = <span class="tok-number">0x1029</span>;</span>
<span class="line" id="L2284">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> NO_CHECK = <span class="tok-number">11</span>;</span>
<span class="line" id="L2285">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> PRIORITY = <span class="tok-number">12</span>;</span>
<span class="line" id="L2286">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> BSDCOMPAT = <span class="tok-number">14</span>;</span>
<span class="line" id="L2287">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> PASSCRED = <span class="tok-number">17</span>;</span>
<span class="line" id="L2288">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> PEERCRED = <span class="tok-number">18</span>;</span>
<span class="line" id="L2289">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> PEERSEC = <span class="tok-number">30</span>;</span>
<span class="line" id="L2290">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> SNDBUFFORCE = <span class="tok-number">31</span>;</span>
<span class="line" id="L2291">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> RCVBUFFORCE = <span class="tok-number">33</span>;</span>
<span class="line" id="L2292">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> SECURITY_AUTHENTICATION = <span class="tok-number">22</span>;</span>
<span class="line" id="L2293">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> SECURITY_ENCRYPTION_TRANSPORT = <span class="tok-number">23</span>;</span>
<span class="line" id="L2294">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> SECURITY_ENCRYPTION_NETWORK = <span class="tok-number">24</span>;</span>
<span class="line" id="L2295">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> BINDTODEVICE = <span class="tok-number">25</span>;</span>
<span class="line" id="L2296">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> ATTACH_FILTER = <span class="tok-number">26</span>;</span>
<span class="line" id="L2297">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> DETACH_FILTER = <span class="tok-number">27</span>;</span>
<span class="line" id="L2298">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> GET_FILTER = ATTACH_FILTER;</span>
<span class="line" id="L2299">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> PEERNAME = <span class="tok-number">28</span>;</span>
<span class="line" id="L2300">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> TIMESTAMP_OLD = <span class="tok-number">29</span>;</span>
<span class="line" id="L2301">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> PASSSEC = <span class="tok-number">34</span>;</span>
<span class="line" id="L2302">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> TIMESTAMPNS_OLD = <span class="tok-number">35</span>;</span>
<span class="line" id="L2303">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> MARK = <span class="tok-number">36</span>;</span>
<span class="line" id="L2304">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> TIMESTAMPING_OLD = <span class="tok-number">37</span>;</span>
<span class="line" id="L2305">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> RXQ_OVFL = <span class="tok-number">40</span>;</span>
<span class="line" id="L2306">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> WIFI_STATUS = <span class="tok-number">41</span>;</span>
<span class="line" id="L2307">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> PEEK_OFF = <span class="tok-number">42</span>;</span>
<span class="line" id="L2308">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> NOFCS = <span class="tok-number">43</span>;</span>
<span class="line" id="L2309">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> LOCK_FILTER = <span class="tok-number">44</span>;</span>
<span class="line" id="L2310">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> SELECT_ERR_QUEUE = <span class="tok-number">45</span>;</span>
<span class="line" id="L2311">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> BUSY_POLL = <span class="tok-number">46</span>;</span>
<span class="line" id="L2312">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> MAX_PACING_RATE = <span class="tok-number">47</span>;</span>
<span class="line" id="L2313">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> BPF_EXTENSIONS = <span class="tok-number">48</span>;</span>
<span class="line" id="L2314">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> INCOMING_CPU = <span class="tok-number">49</span>;</span>
<span class="line" id="L2315">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> ATTACH_BPF = <span class="tok-number">50</span>;</span>
<span class="line" id="L2316">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> DETACH_BPF = DETACH_FILTER;</span>
<span class="line" id="L2317">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> ATTACH_REUSEPORT_CBPF = <span class="tok-number">51</span>;</span>
<span class="line" id="L2318">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> ATTACH_REUSEPORT_EBPF = <span class="tok-number">52</span>;</span>
<span class="line" id="L2319">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> CNX_ADVICE = <span class="tok-number">53</span>;</span>
<span class="line" id="L2320">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> MEMINFO = <span class="tok-number">55</span>;</span>
<span class="line" id="L2321">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> INCOMING_NAPI_ID = <span class="tok-number">56</span>;</span>
<span class="line" id="L2322">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> COOKIE = <span class="tok-number">57</span>;</span>
<span class="line" id="L2323">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> PEERGROUPS = <span class="tok-number">59</span>;</span>
<span class="line" id="L2324">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> ZEROCOPY = <span class="tok-number">60</span>;</span>
<span class="line" id="L2325">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> TXTIME = <span class="tok-number">61</span>;</span>
<span class="line" id="L2326">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> BINDTOIFINDEX = <span class="tok-number">62</span>;</span>
<span class="line" id="L2327">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> TIMESTAMP_NEW = <span class="tok-number">63</span>;</span>
<span class="line" id="L2328">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> TIMESTAMPNS_NEW = <span class="tok-number">64</span>;</span>
<span class="line" id="L2329">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> TIMESTAMPING_NEW = <span class="tok-number">65</span>;</span>
<span class="line" id="L2330">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> RCVTIMEO_NEW = <span class="tok-number">66</span>;</span>
<span class="line" id="L2331">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> SNDTIMEO_NEW = <span class="tok-number">67</span>;</span>
<span class="line" id="L2332">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> DETACH_REUSEPORT_BPF = <span class="tok-number">68</span>;</span>
<span class="line" id="L2333">    } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (is_ppc <span class="tok-kw">or</span> is_ppc64) <span class="tok-kw">struct</span> {</span>
<span class="line" id="L2334">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> DEBUG = <span class="tok-number">1</span>;</span>
<span class="line" id="L2335">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> REUSEADDR = <span class="tok-number">2</span>;</span>
<span class="line" id="L2336">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> TYPE = <span class="tok-number">3</span>;</span>
<span class="line" id="L2337">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> ERROR = <span class="tok-number">4</span>;</span>
<span class="line" id="L2338">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> DONTROUTE = <span class="tok-number">5</span>;</span>
<span class="line" id="L2339">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> BROADCAST = <span class="tok-number">6</span>;</span>
<span class="line" id="L2340">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> SNDBUF = <span class="tok-number">7</span>;</span>
<span class="line" id="L2341">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> RCVBUF = <span class="tok-number">8</span>;</span>
<span class="line" id="L2342">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> KEEPALIVE = <span class="tok-number">9</span>;</span>
<span class="line" id="L2343">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> OOBINLINE = <span class="tok-number">10</span>;</span>
<span class="line" id="L2344">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> NO_CHECK = <span class="tok-number">11</span>;</span>
<span class="line" id="L2345">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> PRIORITY = <span class="tok-number">12</span>;</span>
<span class="line" id="L2346">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> LINGER = <span class="tok-number">13</span>;</span>
<span class="line" id="L2347">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> BSDCOMPAT = <span class="tok-number">14</span>;</span>
<span class="line" id="L2348">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> REUSEPORT = <span class="tok-number">15</span>;</span>
<span class="line" id="L2349">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> RCVLOWAT = <span class="tok-number">16</span>;</span>
<span class="line" id="L2350">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> SNDLOWAT = <span class="tok-number">17</span>;</span>
<span class="line" id="L2351">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> RCVTIMEO = <span class="tok-number">18</span>;</span>
<span class="line" id="L2352">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> SNDTIMEO = <span class="tok-number">19</span>;</span>
<span class="line" id="L2353">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> PASSCRED = <span class="tok-number">20</span>;</span>
<span class="line" id="L2354">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> PEERCRED = <span class="tok-number">21</span>;</span>
<span class="line" id="L2355">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> ACCEPTCONN = <span class="tok-number">30</span>;</span>
<span class="line" id="L2356">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> PEERSEC = <span class="tok-number">31</span>;</span>
<span class="line" id="L2357">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> SNDBUFFORCE = <span class="tok-number">32</span>;</span>
<span class="line" id="L2358">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> RCVBUFFORCE = <span class="tok-number">33</span>;</span>
<span class="line" id="L2359">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> PROTOCOL = <span class="tok-number">38</span>;</span>
<span class="line" id="L2360">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> DOMAIN = <span class="tok-number">39</span>;</span>
<span class="line" id="L2361">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> SECURITY_AUTHENTICATION = <span class="tok-number">22</span>;</span>
<span class="line" id="L2362">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> SECURITY_ENCRYPTION_TRANSPORT = <span class="tok-number">23</span>;</span>
<span class="line" id="L2363">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> SECURITY_ENCRYPTION_NETWORK = <span class="tok-number">24</span>;</span>
<span class="line" id="L2364">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> BINDTODEVICE = <span class="tok-number">25</span>;</span>
<span class="line" id="L2365">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> ATTACH_FILTER = <span class="tok-number">26</span>;</span>
<span class="line" id="L2366">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> DETACH_FILTER = <span class="tok-number">27</span>;</span>
<span class="line" id="L2367">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> GET_FILTER = ATTACH_FILTER;</span>
<span class="line" id="L2368">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> PEERNAME = <span class="tok-number">28</span>;</span>
<span class="line" id="L2369">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> TIMESTAMP_OLD = <span class="tok-number">29</span>;</span>
<span class="line" id="L2370">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> PASSSEC = <span class="tok-number">34</span>;</span>
<span class="line" id="L2371">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> TIMESTAMPNS_OLD = <span class="tok-number">35</span>;</span>
<span class="line" id="L2372">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> MARK = <span class="tok-number">36</span>;</span>
<span class="line" id="L2373">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> TIMESTAMPING_OLD = <span class="tok-number">37</span>;</span>
<span class="line" id="L2374">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> RXQ_OVFL = <span class="tok-number">40</span>;</span>
<span class="line" id="L2375">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> WIFI_STATUS = <span class="tok-number">41</span>;</span>
<span class="line" id="L2376">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> PEEK_OFF = <span class="tok-number">42</span>;</span>
<span class="line" id="L2377">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> NOFCS = <span class="tok-number">43</span>;</span>
<span class="line" id="L2378">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> LOCK_FILTER = <span class="tok-number">44</span>;</span>
<span class="line" id="L2379">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> SELECT_ERR_QUEUE = <span class="tok-number">45</span>;</span>
<span class="line" id="L2380">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> BUSY_POLL = <span class="tok-number">46</span>;</span>
<span class="line" id="L2381">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> MAX_PACING_RATE = <span class="tok-number">47</span>;</span>
<span class="line" id="L2382">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> BPF_EXTENSIONS = <span class="tok-number">48</span>;</span>
<span class="line" id="L2383">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> INCOMING_CPU = <span class="tok-number">49</span>;</span>
<span class="line" id="L2384">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> ATTACH_BPF = <span class="tok-number">50</span>;</span>
<span class="line" id="L2385">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> DETACH_BPF = DETACH_FILTER;</span>
<span class="line" id="L2386">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> ATTACH_REUSEPORT_CBPF = <span class="tok-number">51</span>;</span>
<span class="line" id="L2387">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> ATTACH_REUSEPORT_EBPF = <span class="tok-number">52</span>;</span>
<span class="line" id="L2388">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> CNX_ADVICE = <span class="tok-number">53</span>;</span>
<span class="line" id="L2389">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> MEMINFO = <span class="tok-number">55</span>;</span>
<span class="line" id="L2390">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> INCOMING_NAPI_ID = <span class="tok-number">56</span>;</span>
<span class="line" id="L2391">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> COOKIE = <span class="tok-number">57</span>;</span>
<span class="line" id="L2392">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> PEERGROUPS = <span class="tok-number">59</span>;</span>
<span class="line" id="L2393">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> ZEROCOPY = <span class="tok-number">60</span>;</span>
<span class="line" id="L2394">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> TXTIME = <span class="tok-number">61</span>;</span>
<span class="line" id="L2395">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> BINDTOIFINDEX = <span class="tok-number">62</span>;</span>
<span class="line" id="L2396">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> TIMESTAMP_NEW = <span class="tok-number">63</span>;</span>
<span class="line" id="L2397">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> TIMESTAMPNS_NEW = <span class="tok-number">64</span>;</span>
<span class="line" id="L2398">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> TIMESTAMPING_NEW = <span class="tok-number">65</span>;</span>
<span class="line" id="L2399">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> RCVTIMEO_NEW = <span class="tok-number">66</span>;</span>
<span class="line" id="L2400">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> SNDTIMEO_NEW = <span class="tok-number">67</span>;</span>
<span class="line" id="L2401">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> DETACH_REUSEPORT_BPF = <span class="tok-number">68</span>;</span>
<span class="line" id="L2402">    } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (is_sparc) <span class="tok-kw">struct</span> {</span>
<span class="line" id="L2403">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> DEBUG = <span class="tok-number">1</span>;</span>
<span class="line" id="L2404">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> REUSEADDR = <span class="tok-number">4</span>;</span>
<span class="line" id="L2405">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> TYPE = <span class="tok-number">4104</span>;</span>
<span class="line" id="L2406">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> ERROR = <span class="tok-number">4103</span>;</span>
<span class="line" id="L2407">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> DONTROUTE = <span class="tok-number">16</span>;</span>
<span class="line" id="L2408">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> BROADCAST = <span class="tok-number">32</span>;</span>
<span class="line" id="L2409">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> SNDBUF = <span class="tok-number">4097</span>;</span>
<span class="line" id="L2410">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> RCVBUF = <span class="tok-number">4098</span>;</span>
<span class="line" id="L2411">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> KEEPALIVE = <span class="tok-number">8</span>;</span>
<span class="line" id="L2412">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> OOBINLINE = <span class="tok-number">256</span>;</span>
<span class="line" id="L2413">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> NO_CHECK = <span class="tok-number">11</span>;</span>
<span class="line" id="L2414">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> PRIORITY = <span class="tok-number">12</span>;</span>
<span class="line" id="L2415">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> LINGER = <span class="tok-number">128</span>;</span>
<span class="line" id="L2416">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> BSDCOMPAT = <span class="tok-number">1024</span>;</span>
<span class="line" id="L2417">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> REUSEPORT = <span class="tok-number">512</span>;</span>
<span class="line" id="L2418">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> PASSCRED = <span class="tok-number">2</span>;</span>
<span class="line" id="L2419">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> PEERCRED = <span class="tok-number">64</span>;</span>
<span class="line" id="L2420">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> RCVLOWAT = <span class="tok-number">2048</span>;</span>
<span class="line" id="L2421">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> SNDLOWAT = <span class="tok-number">4096</span>;</span>
<span class="line" id="L2422">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> RCVTIMEO = <span class="tok-number">8192</span>;</span>
<span class="line" id="L2423">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> SNDTIMEO = <span class="tok-number">16384</span>;</span>
<span class="line" id="L2424">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> ACCEPTCONN = <span class="tok-number">32768</span>;</span>
<span class="line" id="L2425">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> PEERSEC = <span class="tok-number">30</span>;</span>
<span class="line" id="L2426">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> SNDBUFFORCE = <span class="tok-number">4106</span>;</span>
<span class="line" id="L2427">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> RCVBUFFORCE = <span class="tok-number">4107</span>;</span>
<span class="line" id="L2428">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> PROTOCOL = <span class="tok-number">4136</span>;</span>
<span class="line" id="L2429">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> DOMAIN = <span class="tok-number">4137</span>;</span>
<span class="line" id="L2430">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> SECURITY_AUTHENTICATION = <span class="tok-number">20481</span>;</span>
<span class="line" id="L2431">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> SECURITY_ENCRYPTION_TRANSPORT = <span class="tok-number">20482</span>;</span>
<span class="line" id="L2432">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> SECURITY_ENCRYPTION_NETWORK = <span class="tok-number">20484</span>;</span>
<span class="line" id="L2433">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> BINDTODEVICE = <span class="tok-number">13</span>;</span>
<span class="line" id="L2434">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> ATTACH_FILTER = <span class="tok-number">26</span>;</span>
<span class="line" id="L2435">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> DETACH_FILTER = <span class="tok-number">27</span>;</span>
<span class="line" id="L2436">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> GET_FILTER = <span class="tok-number">26</span>;</span>
<span class="line" id="L2437">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> PEERNAME = <span class="tok-number">28</span>;</span>
<span class="line" id="L2438">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> TIMESTAMP_OLD = <span class="tok-number">29</span>;</span>
<span class="line" id="L2439">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> PASSSEC = <span class="tok-number">31</span>;</span>
<span class="line" id="L2440">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> TIMESTAMPNS_OLD = <span class="tok-number">33</span>;</span>
<span class="line" id="L2441">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> MARK = <span class="tok-number">34</span>;</span>
<span class="line" id="L2442">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> TIMESTAMPING_OLD = <span class="tok-number">35</span>;</span>
<span class="line" id="L2443">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> RXQ_OVFL = <span class="tok-number">36</span>;</span>
<span class="line" id="L2444">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> WIFI_STATUS = <span class="tok-number">37</span>;</span>
<span class="line" id="L2445">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> PEEK_OFF = <span class="tok-number">38</span>;</span>
<span class="line" id="L2446">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> NOFCS = <span class="tok-number">39</span>;</span>
<span class="line" id="L2447">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> LOCK_FILTER = <span class="tok-number">40</span>;</span>
<span class="line" id="L2448">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> SELECT_ERR_QUEUE = <span class="tok-number">41</span>;</span>
<span class="line" id="L2449">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> BUSY_POLL = <span class="tok-number">48</span>;</span>
<span class="line" id="L2450">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> MAX_PACING_RATE = <span class="tok-number">49</span>;</span>
<span class="line" id="L2451">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> BPF_EXTENSIONS = <span class="tok-number">50</span>;</span>
<span class="line" id="L2452">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> INCOMING_CPU = <span class="tok-number">51</span>;</span>
<span class="line" id="L2453">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> ATTACH_BPF = <span class="tok-number">52</span>;</span>
<span class="line" id="L2454">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> DETACH_BPF = <span class="tok-number">27</span>;</span>
<span class="line" id="L2455">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> ATTACH_REUSEPORT_CBPF = <span class="tok-number">53</span>;</span>
<span class="line" id="L2456">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> ATTACH_REUSEPORT_EBPF = <span class="tok-number">54</span>;</span>
<span class="line" id="L2457">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> CNX_ADVICE = <span class="tok-number">55</span>;</span>
<span class="line" id="L2458">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> MEMINFO = <span class="tok-number">57</span>;</span>
<span class="line" id="L2459">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> INCOMING_NAPI_ID = <span class="tok-number">58</span>;</span>
<span class="line" id="L2460">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> COOKIE = <span class="tok-number">59</span>;</span>
<span class="line" id="L2461">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> PEERGROUPS = <span class="tok-number">61</span>;</span>
<span class="line" id="L2462">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> ZEROCOPY = <span class="tok-number">62</span>;</span>
<span class="line" id="L2463">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> TXTIME = <span class="tok-number">63</span>;</span>
<span class="line" id="L2464">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> BINDTOIFINDEX = <span class="tok-number">65</span>;</span>
<span class="line" id="L2465">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> TIMESTAMP_NEW = <span class="tok-number">70</span>;</span>
<span class="line" id="L2466">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> TIMESTAMPNS_NEW = <span class="tok-number">66</span>;</span>
<span class="line" id="L2467">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> TIMESTAMPING_NEW = <span class="tok-number">67</span>;</span>
<span class="line" id="L2468">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> RCVTIMEO_NEW = <span class="tok-number">68</span>;</span>
<span class="line" id="L2469">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> SNDTIMEO_NEW = <span class="tok-number">69</span>;</span>
<span class="line" id="L2470">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> DETACH_REUSEPORT_BPF = <span class="tok-number">71</span>;</span>
<span class="line" id="L2471">    } <span class="tok-kw">else</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L2472">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> DEBUG = <span class="tok-number">1</span>;</span>
<span class="line" id="L2473">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> REUSEADDR = <span class="tok-number">2</span>;</span>
<span class="line" id="L2474">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> TYPE = <span class="tok-number">3</span>;</span>
<span class="line" id="L2475">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> ERROR = <span class="tok-number">4</span>;</span>
<span class="line" id="L2476">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> DONTROUTE = <span class="tok-number">5</span>;</span>
<span class="line" id="L2477">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> BROADCAST = <span class="tok-number">6</span>;</span>
<span class="line" id="L2478">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> SNDBUF = <span class="tok-number">7</span>;</span>
<span class="line" id="L2479">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> RCVBUF = <span class="tok-number">8</span>;</span>
<span class="line" id="L2480">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> KEEPALIVE = <span class="tok-number">9</span>;</span>
<span class="line" id="L2481">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> OOBINLINE = <span class="tok-number">10</span>;</span>
<span class="line" id="L2482">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> NO_CHECK = <span class="tok-number">11</span>;</span>
<span class="line" id="L2483">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> PRIORITY = <span class="tok-number">12</span>;</span>
<span class="line" id="L2484">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> LINGER = <span class="tok-number">13</span>;</span>
<span class="line" id="L2485">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> BSDCOMPAT = <span class="tok-number">14</span>;</span>
<span class="line" id="L2486">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> REUSEPORT = <span class="tok-number">15</span>;</span>
<span class="line" id="L2487">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> PASSCRED = <span class="tok-number">16</span>;</span>
<span class="line" id="L2488">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> PEERCRED = <span class="tok-number">17</span>;</span>
<span class="line" id="L2489">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> RCVLOWAT = <span class="tok-number">18</span>;</span>
<span class="line" id="L2490">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> SNDLOWAT = <span class="tok-number">19</span>;</span>
<span class="line" id="L2491">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> RCVTIMEO = <span class="tok-number">20</span>;</span>
<span class="line" id="L2492">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> SNDTIMEO = <span class="tok-number">21</span>;</span>
<span class="line" id="L2493">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> ACCEPTCONN = <span class="tok-number">30</span>;</span>
<span class="line" id="L2494">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> PEERSEC = <span class="tok-number">31</span>;</span>
<span class="line" id="L2495">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> SNDBUFFORCE = <span class="tok-number">32</span>;</span>
<span class="line" id="L2496">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> RCVBUFFORCE = <span class="tok-number">33</span>;</span>
<span class="line" id="L2497">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> PROTOCOL = <span class="tok-number">38</span>;</span>
<span class="line" id="L2498">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> DOMAIN = <span class="tok-number">39</span>;</span>
<span class="line" id="L2499">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> SECURITY_AUTHENTICATION = <span class="tok-number">22</span>;</span>
<span class="line" id="L2500">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> SECURITY_ENCRYPTION_TRANSPORT = <span class="tok-number">23</span>;</span>
<span class="line" id="L2501">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> SECURITY_ENCRYPTION_NETWORK = <span class="tok-number">24</span>;</span>
<span class="line" id="L2502">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> BINDTODEVICE = <span class="tok-number">25</span>;</span>
<span class="line" id="L2503">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> ATTACH_FILTER = <span class="tok-number">26</span>;</span>
<span class="line" id="L2504">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> DETACH_FILTER = <span class="tok-number">27</span>;</span>
<span class="line" id="L2505">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> GET_FILTER = ATTACH_FILTER;</span>
<span class="line" id="L2506">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> PEERNAME = <span class="tok-number">28</span>;</span>
<span class="line" id="L2507">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> TIMESTAMP_OLD = <span class="tok-number">29</span>;</span>
<span class="line" id="L2508">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> PASSSEC = <span class="tok-number">34</span>;</span>
<span class="line" id="L2509">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> TIMESTAMPNS_OLD = <span class="tok-number">35</span>;</span>
<span class="line" id="L2510">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> MARK = <span class="tok-number">36</span>;</span>
<span class="line" id="L2511">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> TIMESTAMPING_OLD = <span class="tok-number">37</span>;</span>
<span class="line" id="L2512">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> RXQ_OVFL = <span class="tok-number">40</span>;</span>
<span class="line" id="L2513">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> WIFI_STATUS = <span class="tok-number">41</span>;</span>
<span class="line" id="L2514">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> PEEK_OFF = <span class="tok-number">42</span>;</span>
<span class="line" id="L2515">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> NOFCS = <span class="tok-number">43</span>;</span>
<span class="line" id="L2516">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> LOCK_FILTER = <span class="tok-number">44</span>;</span>
<span class="line" id="L2517">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> SELECT_ERR_QUEUE = <span class="tok-number">45</span>;</span>
<span class="line" id="L2518">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> BUSY_POLL = <span class="tok-number">46</span>;</span>
<span class="line" id="L2519">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> MAX_PACING_RATE = <span class="tok-number">47</span>;</span>
<span class="line" id="L2520">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> BPF_EXTENSIONS = <span class="tok-number">48</span>;</span>
<span class="line" id="L2521">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> INCOMING_CPU = <span class="tok-number">49</span>;</span>
<span class="line" id="L2522">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> ATTACH_BPF = <span class="tok-number">50</span>;</span>
<span class="line" id="L2523">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> DETACH_BPF = DETACH_FILTER;</span>
<span class="line" id="L2524">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> ATTACH_REUSEPORT_CBPF = <span class="tok-number">51</span>;</span>
<span class="line" id="L2525">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> ATTACH_REUSEPORT_EBPF = <span class="tok-number">52</span>;</span>
<span class="line" id="L2526">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> CNX_ADVICE = <span class="tok-number">53</span>;</span>
<span class="line" id="L2527">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> MEMINFO = <span class="tok-number">55</span>;</span>
<span class="line" id="L2528">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> INCOMING_NAPI_ID = <span class="tok-number">56</span>;</span>
<span class="line" id="L2529">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> COOKIE = <span class="tok-number">57</span>;</span>
<span class="line" id="L2530">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> PEERGROUPS = <span class="tok-number">59</span>;</span>
<span class="line" id="L2531">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> ZEROCOPY = <span class="tok-number">60</span>;</span>
<span class="line" id="L2532">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> TXTIME = <span class="tok-number">61</span>;</span>
<span class="line" id="L2533">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> BINDTOIFINDEX = <span class="tok-number">62</span>;</span>
<span class="line" id="L2534">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> TIMESTAMP_NEW = <span class="tok-number">63</span>;</span>
<span class="line" id="L2535">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> TIMESTAMPNS_NEW = <span class="tok-number">64</span>;</span>
<span class="line" id="L2536">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> TIMESTAMPING_NEW = <span class="tok-number">65</span>;</span>
<span class="line" id="L2537">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> RCVTIMEO_NEW = <span class="tok-number">66</span>;</span>
<span class="line" id="L2538">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> SNDTIMEO_NEW = <span class="tok-number">67</span>;</span>
<span class="line" id="L2539">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> DETACH_REUSEPORT_BPF = <span class="tok-number">68</span>;</span>
<span class="line" id="L2540">    };</span>
<span class="line" id="L2541">};</span>
<span class="line" id="L2542"></span>
<span class="line" id="L2543"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SCM = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L2544">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> WIFI_STATUS = SO.WIFI_STATUS;</span>
<span class="line" id="L2545">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> TIMESTAMPING_OPT_STATS = <span class="tok-number">54</span>;</span>
<span class="line" id="L2546">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> TIMESTAMPING_PKTINFO = <span class="tok-number">58</span>;</span>
<span class="line" id="L2547">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> TXTIME = SO.TXTIME;</span>
<span class="line" id="L2548">};</span>
<span class="line" id="L2549"></span>
<span class="line" id="L2550"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SOL = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L2551">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> SOCKET = <span class="tok-kw">if</span> (is_mips <span class="tok-kw">or</span> is_sparc) <span class="tok-number">65535</span> <span class="tok-kw">else</span> <span class="tok-number">1</span>;</span>
<span class="line" id="L2552"></span>
<span class="line" id="L2553">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> IP = <span class="tok-number">0</span>;</span>
<span class="line" id="L2554">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> IPV6 = <span class="tok-number">41</span>;</span>
<span class="line" id="L2555">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> ICMPV6 = <span class="tok-number">58</span>;</span>
<span class="line" id="L2556"></span>
<span class="line" id="L2557">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> RAW = <span class="tok-number">255</span>;</span>
<span class="line" id="L2558">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> DECNET = <span class="tok-number">261</span>;</span>
<span class="line" id="L2559">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> X25 = <span class="tok-number">262</span>;</span>
<span class="line" id="L2560">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> PACKET = <span class="tok-number">263</span>;</span>
<span class="line" id="L2561">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> ATM = <span class="tok-number">264</span>;</span>
<span class="line" id="L2562">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> AAL = <span class="tok-number">265</span>;</span>
<span class="line" id="L2563">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> IRDA = <span class="tok-number">266</span>;</span>
<span class="line" id="L2564">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> NETBEUI = <span class="tok-number">267</span>;</span>
<span class="line" id="L2565">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> LLC = <span class="tok-number">268</span>;</span>
<span class="line" id="L2566">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> DCCP = <span class="tok-number">269</span>;</span>
<span class="line" id="L2567">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> NETLINK = <span class="tok-number">270</span>;</span>
<span class="line" id="L2568">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> TIPC = <span class="tok-number">271</span>;</span>
<span class="line" id="L2569">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> RXRPC = <span class="tok-number">272</span>;</span>
<span class="line" id="L2570">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> PPPOL2TP = <span class="tok-number">273</span>;</span>
<span class="line" id="L2571">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> BLUETOOTH = <span class="tok-number">274</span>;</span>
<span class="line" id="L2572">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> PNPIPE = <span class="tok-number">275</span>;</span>
<span class="line" id="L2573">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> RDS = <span class="tok-number">276</span>;</span>
<span class="line" id="L2574">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> IUCV = <span class="tok-number">277</span>;</span>
<span class="line" id="L2575">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> CAIF = <span class="tok-number">278</span>;</span>
<span class="line" id="L2576">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> ALG = <span class="tok-number">279</span>;</span>
<span class="line" id="L2577">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> NFC = <span class="tok-number">280</span>;</span>
<span class="line" id="L2578">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> KCM = <span class="tok-number">281</span>;</span>
<span class="line" id="L2579">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> TLS = <span class="tok-number">282</span>;</span>
<span class="line" id="L2580">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> XDP = <span class="tok-number">283</span>;</span>
<span class="line" id="L2581">};</span>
<span class="line" id="L2582"></span>
<span class="line" id="L2583"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SOMAXCONN = <span class="tok-number">128</span>;</span>
<span class="line" id="L2584"></span>
<span class="line" id="L2585"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IP = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L2586">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> TOS = <span class="tok-number">1</span>;</span>
<span class="line" id="L2587">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> TTL = <span class="tok-number">2</span>;</span>
<span class="line" id="L2588">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> HDRINCL = <span class="tok-number">3</span>;</span>
<span class="line" id="L2589">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> OPTIONS = <span class="tok-number">4</span>;</span>
<span class="line" id="L2590">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> ROUTER_ALERT = <span class="tok-number">5</span>;</span>
<span class="line" id="L2591">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> RECVOPTS = <span class="tok-number">6</span>;</span>
<span class="line" id="L2592">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> RETOPTS = <span class="tok-number">7</span>;</span>
<span class="line" id="L2593">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> PKTINFO = <span class="tok-number">8</span>;</span>
<span class="line" id="L2594">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> PKTOPTIONS = <span class="tok-number">9</span>;</span>
<span class="line" id="L2595">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> PMTUDISC = <span class="tok-number">10</span>;</span>
<span class="line" id="L2596">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> MTU_DISCOVER = <span class="tok-number">10</span>;</span>
<span class="line" id="L2597">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> RECVERR = <span class="tok-number">11</span>;</span>
<span class="line" id="L2598">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> RECVTTL = <span class="tok-number">12</span>;</span>
<span class="line" id="L2599">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> RECVTOS = <span class="tok-number">13</span>;</span>
<span class="line" id="L2600">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> MTU = <span class="tok-number">14</span>;</span>
<span class="line" id="L2601">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> FREEBIND = <span class="tok-number">15</span>;</span>
<span class="line" id="L2602">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> IPSEC_POLICY = <span class="tok-number">16</span>;</span>
<span class="line" id="L2603">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> XFRM_POLICY = <span class="tok-number">17</span>;</span>
<span class="line" id="L2604">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> PASSSEC = <span class="tok-number">18</span>;</span>
<span class="line" id="L2605">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> TRANSPARENT = <span class="tok-number">19</span>;</span>
<span class="line" id="L2606">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> ORIGDSTADDR = <span class="tok-number">20</span>;</span>
<span class="line" id="L2607">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> RECVORIGDSTADDR = IP.ORIGDSTADDR;</span>
<span class="line" id="L2608">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> MINTTL = <span class="tok-number">21</span>;</span>
<span class="line" id="L2609">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> NODEFRAG = <span class="tok-number">22</span>;</span>
<span class="line" id="L2610">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> CHECKSUM = <span class="tok-number">23</span>;</span>
<span class="line" id="L2611">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> BIND_ADDRESS_NO_PORT = <span class="tok-number">24</span>;</span>
<span class="line" id="L2612">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> RECVFRAGSIZE = <span class="tok-number">25</span>;</span>
<span class="line" id="L2613">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> MULTICAST_IF = <span class="tok-number">32</span>;</span>
<span class="line" id="L2614">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> MULTICAST_TTL = <span class="tok-number">33</span>;</span>
<span class="line" id="L2615">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> MULTICAST_LOOP = <span class="tok-number">34</span>;</span>
<span class="line" id="L2616">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> ADD_MEMBERSHIP = <span class="tok-number">35</span>;</span>
<span class="line" id="L2617">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> DROP_MEMBERSHIP = <span class="tok-number">36</span>;</span>
<span class="line" id="L2618">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> UNBLOCK_SOURCE = <span class="tok-number">37</span>;</span>
<span class="line" id="L2619">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> BLOCK_SOURCE = <span class="tok-number">38</span>;</span>
<span class="line" id="L2620">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> ADD_SOURCE_MEMBERSHIP = <span class="tok-number">39</span>;</span>
<span class="line" id="L2621">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> DROP_SOURCE_MEMBERSHIP = <span class="tok-number">40</span>;</span>
<span class="line" id="L2622">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> MSFILTER = <span class="tok-number">41</span>;</span>
<span class="line" id="L2623">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> MULTICAST_ALL = <span class="tok-number">49</span>;</span>
<span class="line" id="L2624">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> UNICAST_IF = <span class="tok-number">50</span>;</span>
<span class="line" id="L2625"></span>
<span class="line" id="L2626">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> RECVRETOPTS = IP.RETOPTS;</span>
<span class="line" id="L2627"></span>
<span class="line" id="L2628">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> PMTUDISC_DONT = <span class="tok-number">0</span>;</span>
<span class="line" id="L2629">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> PMTUDISC_WANT = <span class="tok-number">1</span>;</span>
<span class="line" id="L2630">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> PMTUDISC_DO = <span class="tok-number">2</span>;</span>
<span class="line" id="L2631">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> PMTUDISC_PROBE = <span class="tok-number">3</span>;</span>
<span class="line" id="L2632">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> PMTUDISC_INTERFACE = <span class="tok-number">4</span>;</span>
<span class="line" id="L2633">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> PMTUDISC_OMIT = <span class="tok-number">5</span>;</span>
<span class="line" id="L2634"></span>
<span class="line" id="L2635">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> DEFAULT_MULTICAST_TTL = <span class="tok-number">1</span>;</span>
<span class="line" id="L2636">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> DEFAULT_MULTICAST_LOOP = <span class="tok-number">1</span>;</span>
<span class="line" id="L2637">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> MAX_MEMBERSHIPS = <span class="tok-number">20</span>;</span>
<span class="line" id="L2638">};</span>
<span class="line" id="L2639"></span>
<span class="line" id="L2640"><span class="tok-comment">/// IPv6 socket options</span></span>
<span class="line" id="L2641"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IPV6 = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L2642">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> ADDRFORM = <span class="tok-number">1</span>;</span>
<span class="line" id="L2643">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> @&quot;2292PKTINFO&quot; = <span class="tok-number">2</span>;</span>
<span class="line" id="L2644">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> @&quot;2292HOPOPTS&quot; = <span class="tok-number">3</span>;</span>
<span class="line" id="L2645">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> @&quot;2292DSTOPTS&quot; = <span class="tok-number">4</span>;</span>
<span class="line" id="L2646">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> @&quot;2292RTHDR&quot; = <span class="tok-number">5</span>;</span>
<span class="line" id="L2647">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> @&quot;2292PKTOPTIONS&quot; = <span class="tok-number">6</span>;</span>
<span class="line" id="L2648">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> CHECKSUM = <span class="tok-number">7</span>;</span>
<span class="line" id="L2649">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> @&quot;2292HOPLIMIT&quot; = <span class="tok-number">8</span>;</span>
<span class="line" id="L2650">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> NEXTHOP = <span class="tok-number">9</span>;</span>
<span class="line" id="L2651">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> AUTHHDR = <span class="tok-number">10</span>;</span>
<span class="line" id="L2652">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> FLOWINFO = <span class="tok-number">11</span>;</span>
<span class="line" id="L2653"></span>
<span class="line" id="L2654">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> UNICAST_HOPS = <span class="tok-number">16</span>;</span>
<span class="line" id="L2655">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> MULTICAST_IF = <span class="tok-number">17</span>;</span>
<span class="line" id="L2656">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> MULTICAST_HOPS = <span class="tok-number">18</span>;</span>
<span class="line" id="L2657">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> MULTICAST_LOOP = <span class="tok-number">19</span>;</span>
<span class="line" id="L2658">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> ADD_MEMBERSHIP = <span class="tok-number">20</span>;</span>
<span class="line" id="L2659">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> DROP_MEMBERSHIP = <span class="tok-number">21</span>;</span>
<span class="line" id="L2660">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> ROUTER_ALERT = <span class="tok-number">22</span>;</span>
<span class="line" id="L2661">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> MTU_DISCOVER = <span class="tok-number">23</span>;</span>
<span class="line" id="L2662">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> MTU = <span class="tok-number">24</span>;</span>
<span class="line" id="L2663">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> RECVERR = <span class="tok-number">25</span>;</span>
<span class="line" id="L2664">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> V6ONLY = <span class="tok-number">26</span>;</span>
<span class="line" id="L2665">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> JOIN_ANYCAST = <span class="tok-number">27</span>;</span>
<span class="line" id="L2666">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> LEAVE_ANYCAST = <span class="tok-number">28</span>;</span>
<span class="line" id="L2667"></span>
<span class="line" id="L2668">    <span class="tok-comment">// IPV6.MTU_DISCOVER values</span>
</span>
<span class="line" id="L2669">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> PMTUDISC_DONT = <span class="tok-number">0</span>;</span>
<span class="line" id="L2670">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> PMTUDISC_WANT = <span class="tok-number">1</span>;</span>
<span class="line" id="L2671">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> PMTUDISC_DO = <span class="tok-number">2</span>;</span>
<span class="line" id="L2672">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> PMTUDISC_PROBE = <span class="tok-number">3</span>;</span>
<span class="line" id="L2673">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> PMTUDISC_INTERFACE = <span class="tok-number">4</span>;</span>
<span class="line" id="L2674">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> PMTUDISC_OMIT = <span class="tok-number">5</span>;</span>
<span class="line" id="L2675"></span>
<span class="line" id="L2676">    <span class="tok-comment">// Flowlabel</span>
</span>
<span class="line" id="L2677">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> FLOWLABEL_MGR = <span class="tok-number">32</span>;</span>
<span class="line" id="L2678">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> FLOWINFO_SEND = <span class="tok-number">33</span>;</span>
<span class="line" id="L2679">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> IPSEC_POLICY = <span class="tok-number">34</span>;</span>
<span class="line" id="L2680">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> XFRM_POLICY = <span class="tok-number">35</span>;</span>
<span class="line" id="L2681">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> HDRINCL = <span class="tok-number">36</span>;</span>
<span class="line" id="L2682"></span>
<span class="line" id="L2683">    <span class="tok-comment">// Advanced API (RFC3542) (1)</span>
</span>
<span class="line" id="L2684">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> RECVPKTINFO = <span class="tok-number">49</span>;</span>
<span class="line" id="L2685">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> PKTINFO = <span class="tok-number">50</span>;</span>
<span class="line" id="L2686">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> RECVHOPLIMIT = <span class="tok-number">51</span>;</span>
<span class="line" id="L2687">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> HOPLIMIT = <span class="tok-number">52</span>;</span>
<span class="line" id="L2688">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> RECVHOPOPTS = <span class="tok-number">53</span>;</span>
<span class="line" id="L2689">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> HOPOPTS = <span class="tok-number">54</span>;</span>
<span class="line" id="L2690">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> RTHDRDSTOPTS = <span class="tok-number">55</span>;</span>
<span class="line" id="L2691">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> RECVRTHDR = <span class="tok-number">56</span>;</span>
<span class="line" id="L2692">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> RTHDR = <span class="tok-number">57</span>;</span>
<span class="line" id="L2693">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> RECVDSTOPTS = <span class="tok-number">58</span>;</span>
<span class="line" id="L2694">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> DSTOPTS = <span class="tok-number">59</span>;</span>
<span class="line" id="L2695">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> RECVPATHMTU = <span class="tok-number">60</span>;</span>
<span class="line" id="L2696">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> PATHMTU = <span class="tok-number">61</span>;</span>
<span class="line" id="L2697">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> DONTFRAG = <span class="tok-number">62</span>;</span>
<span class="line" id="L2698"></span>
<span class="line" id="L2699">    <span class="tok-comment">// Advanced API (RFC3542) (2)</span>
</span>
<span class="line" id="L2700">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> RECVTCLASS = <span class="tok-number">66</span>;</span>
<span class="line" id="L2701">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> TCLASS = <span class="tok-number">67</span>;</span>
<span class="line" id="L2702"></span>
<span class="line" id="L2703">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> AUTOFLOWLABEL = <span class="tok-number">70</span>;</span>
<span class="line" id="L2704"></span>
<span class="line" id="L2705">    <span class="tok-comment">// RFC5014: Source address selection</span>
</span>
<span class="line" id="L2706">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> ADDR_PREFERENCES = <span class="tok-number">72</span>;</span>
<span class="line" id="L2707"></span>
<span class="line" id="L2708">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> PREFER_SRC_TMP = <span class="tok-number">0x0001</span>;</span>
<span class="line" id="L2709">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> PREFER_SRC_PUBLIC = <span class="tok-number">0x0002</span>;</span>
<span class="line" id="L2710">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> PREFER_SRC_PUBTMP_DEFAULT = <span class="tok-number">0x0100</span>;</span>
<span class="line" id="L2711">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> PREFER_SRC_COA = <span class="tok-number">0x0004</span>;</span>
<span class="line" id="L2712">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> PREFER_SRC_HOME = <span class="tok-number">0x0400</span>;</span>
<span class="line" id="L2713">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> PREFER_SRC_CGA = <span class="tok-number">0x0008</span>;</span>
<span class="line" id="L2714">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> PREFER_SRC_NONCGA = <span class="tok-number">0x0800</span>;</span>
<span class="line" id="L2715"></span>
<span class="line" id="L2716">    <span class="tok-comment">// RFC5082: Generalized Ttl Security Mechanism</span>
</span>
<span class="line" id="L2717">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> MINHOPCOUNT = <span class="tok-number">73</span>;</span>
<span class="line" id="L2718"></span>
<span class="line" id="L2719">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> ORIGDSTADDR = <span class="tok-number">74</span>;</span>
<span class="line" id="L2720">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> RECVORIGDSTADDR = IPV6.ORIGDSTADDR;</span>
<span class="line" id="L2721">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> TRANSPARENT = <span class="tok-number">75</span>;</span>
<span class="line" id="L2722">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> UNICAST_IF = <span class="tok-number">76</span>;</span>
<span class="line" id="L2723">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> RECVFRAGSIZE = <span class="tok-number">77</span>;</span>
<span class="line" id="L2724">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> FREEBIND = <span class="tok-number">78</span>;</span>
<span class="line" id="L2725">};</span>
<span class="line" id="L2726"></span>
<span class="line" id="L2727"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> MSG = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L2728">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> OOB = <span class="tok-number">0x0001</span>;</span>
<span class="line" id="L2729">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> PEEK = <span class="tok-number">0x0002</span>;</span>
<span class="line" id="L2730">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> DONTROUTE = <span class="tok-number">0x0004</span>;</span>
<span class="line" id="L2731">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> CTRUNC = <span class="tok-number">0x0008</span>;</span>
<span class="line" id="L2732">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> PROXY = <span class="tok-number">0x0010</span>;</span>
<span class="line" id="L2733">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> TRUNC = <span class="tok-number">0x0020</span>;</span>
<span class="line" id="L2734">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> DONTWAIT = <span class="tok-number">0x0040</span>;</span>
<span class="line" id="L2735">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> EOR = <span class="tok-number">0x0080</span>;</span>
<span class="line" id="L2736">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> WAITALL = <span class="tok-number">0x0100</span>;</span>
<span class="line" id="L2737">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> FIN = <span class="tok-number">0x0200</span>;</span>
<span class="line" id="L2738">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> SYN = <span class="tok-number">0x0400</span>;</span>
<span class="line" id="L2739">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> CONFIRM = <span class="tok-number">0x0800</span>;</span>
<span class="line" id="L2740">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> RST = <span class="tok-number">0x1000</span>;</span>
<span class="line" id="L2741">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> ERRQUEUE = <span class="tok-number">0x2000</span>;</span>
<span class="line" id="L2742">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> NOSIGNAL = <span class="tok-number">0x4000</span>;</span>
<span class="line" id="L2743">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> MORE = <span class="tok-number">0x8000</span>;</span>
<span class="line" id="L2744">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> WAITFORONE = <span class="tok-number">0x10000</span>;</span>
<span class="line" id="L2745">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> BATCH = <span class="tok-number">0x40000</span>;</span>
<span class="line" id="L2746">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> ZEROCOPY = <span class="tok-number">0x4000000</span>;</span>
<span class="line" id="L2747">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> FASTOPEN = <span class="tok-number">0x20000000</span>;</span>
<span class="line" id="L2748">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> CMSG_CLOEXEC = <span class="tok-number">0x40000000</span>;</span>
<span class="line" id="L2749">};</span>
<span class="line" id="L2750"></span>
<span class="line" id="L2751"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> DT = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L2752">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> UNKNOWN = <span class="tok-number">0</span>;</span>
<span class="line" id="L2753">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> FIFO = <span class="tok-number">1</span>;</span>
<span class="line" id="L2754">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> CHR = <span class="tok-number">2</span>;</span>
<span class="line" id="L2755">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> DIR = <span class="tok-number">4</span>;</span>
<span class="line" id="L2756">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> BLK = <span class="tok-number">6</span>;</span>
<span class="line" id="L2757">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> REG = <span class="tok-number">8</span>;</span>
<span class="line" id="L2758">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> LNK = <span class="tok-number">10</span>;</span>
<span class="line" id="L2759">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> SOCK = <span class="tok-number">12</span>;</span>
<span class="line" id="L2760">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> WHT = <span class="tok-number">14</span>;</span>
<span class="line" id="L2761">};</span>
<span class="line" id="L2762"></span>
<span class="line" id="L2763"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> T = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L2764">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> CGETS = <span class="tok-kw">if</span> (is_mips) <span class="tok-number">0x540D</span> <span class="tok-kw">else</span> <span class="tok-number">0x5401</span>;</span>
<span class="line" id="L2765">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> CSETS = <span class="tok-number">0x5402</span>;</span>
<span class="line" id="L2766">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> CSETSW = <span class="tok-number">0x5403</span>;</span>
<span class="line" id="L2767">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> CSETSF = <span class="tok-number">0x5404</span>;</span>
<span class="line" id="L2768">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> CGETA = <span class="tok-number">0x5405</span>;</span>
<span class="line" id="L2769">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> CSETA = <span class="tok-number">0x5406</span>;</span>
<span class="line" id="L2770">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> CSETAW = <span class="tok-number">0x5407</span>;</span>
<span class="line" id="L2771">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> CSETAF = <span class="tok-number">0x5408</span>;</span>
<span class="line" id="L2772">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> CSBRK = <span class="tok-number">0x5409</span>;</span>
<span class="line" id="L2773">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> CXONC = <span class="tok-number">0x540A</span>;</span>
<span class="line" id="L2774">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> CFLSH = <span class="tok-number">0x540B</span>;</span>
<span class="line" id="L2775">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> IOCEXCL = <span class="tok-number">0x540C</span>;</span>
<span class="line" id="L2776">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> IOCNXCL = <span class="tok-number">0x540D</span>;</span>
<span class="line" id="L2777">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> IOCSCTTY = <span class="tok-number">0x540E</span>;</span>
<span class="line" id="L2778">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> IOCGPGRP = <span class="tok-number">0x540F</span>;</span>
<span class="line" id="L2779">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> IOCSPGRP = <span class="tok-number">0x5410</span>;</span>
<span class="line" id="L2780">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> IOCOUTQ = <span class="tok-kw">if</span> (is_mips) <span class="tok-number">0x7472</span> <span class="tok-kw">else</span> <span class="tok-number">0x5411</span>;</span>
<span class="line" id="L2781">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> IOCSTI = <span class="tok-number">0x5412</span>;</span>
<span class="line" id="L2782">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> IOCGWINSZ = <span class="tok-kw">if</span> (is_mips <span class="tok-kw">or</span> is_ppc64) <span class="tok-number">0x40087468</span> <span class="tok-kw">else</span> <span class="tok-number">0x5413</span>;</span>
<span class="line" id="L2783">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> IOCSWINSZ = <span class="tok-kw">if</span> (is_mips <span class="tok-kw">or</span> is_ppc64) <span class="tok-number">0x80087467</span> <span class="tok-kw">else</span> <span class="tok-number">0x5414</span>;</span>
<span class="line" id="L2784">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> IOCMGET = <span class="tok-number">0x5415</span>;</span>
<span class="line" id="L2785">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> IOCMBIS = <span class="tok-number">0x5416</span>;</span>
<span class="line" id="L2786">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> IOCMBIC = <span class="tok-number">0x5417</span>;</span>
<span class="line" id="L2787">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> IOCMSET = <span class="tok-number">0x5418</span>;</span>
<span class="line" id="L2788">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> IOCGSOFTCAR = <span class="tok-number">0x5419</span>;</span>
<span class="line" id="L2789">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> IOCSSOFTCAR = <span class="tok-number">0x541A</span>;</span>
<span class="line" id="L2790">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> FIONREAD = <span class="tok-kw">if</span> (is_mips) <span class="tok-number">0x467F</span> <span class="tok-kw">else</span> <span class="tok-number">0x541B</span>;</span>
<span class="line" id="L2791">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> IOCINQ = FIONREAD;</span>
<span class="line" id="L2792">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> IOCLINUX = <span class="tok-number">0x541C</span>;</span>
<span class="line" id="L2793">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> IOCCONS = <span class="tok-number">0x541D</span>;</span>
<span class="line" id="L2794">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> IOCGSERIAL = <span class="tok-number">0x541E</span>;</span>
<span class="line" id="L2795">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> IOCSSERIAL = <span class="tok-number">0x541F</span>;</span>
<span class="line" id="L2796">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> IOCPKT = <span class="tok-number">0x5420</span>;</span>
<span class="line" id="L2797">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> FIONBIO = <span class="tok-number">0x5421</span>;</span>
<span class="line" id="L2798">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> IOCNOTTY = <span class="tok-number">0x5422</span>;</span>
<span class="line" id="L2799">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> IOCSETD = <span class="tok-number">0x5423</span>;</span>
<span class="line" id="L2800">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> IOCGETD = <span class="tok-number">0x5424</span>;</span>
<span class="line" id="L2801">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> CSBRKP = <span class="tok-number">0x5425</span>;</span>
<span class="line" id="L2802">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> IOCSBRK = <span class="tok-number">0x5427</span>;</span>
<span class="line" id="L2803">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> IOCCBRK = <span class="tok-number">0x5428</span>;</span>
<span class="line" id="L2804">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> IOCGSID = <span class="tok-number">0x5429</span>;</span>
<span class="line" id="L2805">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> IOCGRS485 = <span class="tok-number">0x542E</span>;</span>
<span class="line" id="L2806">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> IOCSRS485 = <span class="tok-number">0x542F</span>;</span>
<span class="line" id="L2807">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> IOCGPTN = IOCTL.IOR(<span class="tok-str">'T'</span>, <span class="tok-number">0x30</span>, <span class="tok-type">c_uint</span>);</span>
<span class="line" id="L2808">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> IOCSPTLCK = IOCTL.IOW(<span class="tok-str">'T'</span>, <span class="tok-number">0x31</span>, <span class="tok-type">c_int</span>);</span>
<span class="line" id="L2809">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> IOCGDEV = IOCTL.IOR(<span class="tok-str">'T'</span>, <span class="tok-number">0x32</span>, <span class="tok-type">c_uint</span>);</span>
<span class="line" id="L2810">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> CGETX = <span class="tok-number">0x5432</span>;</span>
<span class="line" id="L2811">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> CSETX = <span class="tok-number">0x5433</span>;</span>
<span class="line" id="L2812">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> CSETXF = <span class="tok-number">0x5434</span>;</span>
<span class="line" id="L2813">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> CSETXW = <span class="tok-number">0x5435</span>;</span>
<span class="line" id="L2814">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> IOCSIG = IOCTL.IOW(<span class="tok-str">'T'</span>, <span class="tok-number">0x36</span>, <span class="tok-type">c_int</span>);</span>
<span class="line" id="L2815">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> IOCVHANGUP = <span class="tok-number">0x5437</span>;</span>
<span class="line" id="L2816">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> IOCGPKT = IOCTL.IOR(<span class="tok-str">'T'</span>, <span class="tok-number">0x38</span>, <span class="tok-type">c_int</span>);</span>
<span class="line" id="L2817">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> IOCGPTLCK = IOCTL.IOR(<span class="tok-str">'T'</span>, <span class="tok-number">0x39</span>, <span class="tok-type">c_int</span>);</span>
<span class="line" id="L2818">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> IOCGEXCL = IOCTL.IOR(<span class="tok-str">'T'</span>, <span class="tok-number">0x40</span>, <span class="tok-type">c_int</span>);</span>
<span class="line" id="L2819">};</span>
<span class="line" id="L2820"></span>
<span class="line" id="L2821"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> EPOLL = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L2822">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> CLOEXEC = O.CLOEXEC;</span>
<span class="line" id="L2823"></span>
<span class="line" id="L2824">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> CTL_ADD = <span class="tok-number">1</span>;</span>
<span class="line" id="L2825">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> CTL_DEL = <span class="tok-number">2</span>;</span>
<span class="line" id="L2826">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> CTL_MOD = <span class="tok-number">3</span>;</span>
<span class="line" id="L2827"></span>
<span class="line" id="L2828">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> IN = <span class="tok-number">0x001</span>;</span>
<span class="line" id="L2829">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> PRI = <span class="tok-number">0x002</span>;</span>
<span class="line" id="L2830">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> OUT = <span class="tok-number">0x004</span>;</span>
<span class="line" id="L2831">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> RDNORM = <span class="tok-number">0x040</span>;</span>
<span class="line" id="L2832">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> RDBAND = <span class="tok-number">0x080</span>;</span>
<span class="line" id="L2833">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> WRNORM = <span class="tok-kw">if</span> (is_mips) <span class="tok-number">0x004</span> <span class="tok-kw">else</span> <span class="tok-number">0x100</span>;</span>
<span class="line" id="L2834">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> WRBAND = <span class="tok-kw">if</span> (is_mips) <span class="tok-number">0x100</span> <span class="tok-kw">else</span> <span class="tok-number">0x200</span>;</span>
<span class="line" id="L2835">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> MSG = <span class="tok-number">0x400</span>;</span>
<span class="line" id="L2836">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> ERR = <span class="tok-number">0x008</span>;</span>
<span class="line" id="L2837">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> HUP = <span class="tok-number">0x010</span>;</span>
<span class="line" id="L2838">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> RDHUP = <span class="tok-number">0x2000</span>;</span>
<span class="line" id="L2839">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> EXCLUSIVE = (<span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">1</span>) &lt;&lt; <span class="tok-number">28</span>);</span>
<span class="line" id="L2840">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> WAKEUP = (<span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">1</span>) &lt;&lt; <span class="tok-number">29</span>);</span>
<span class="line" id="L2841">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> ONESHOT = (<span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">1</span>) &lt;&lt; <span class="tok-number">30</span>);</span>
<span class="line" id="L2842">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> ET = (<span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">1</span>) &lt;&lt; <span class="tok-number">31</span>);</span>
<span class="line" id="L2843">};</span>
<span class="line" id="L2844"></span>
<span class="line" id="L2845"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> CLOCK = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L2846">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> REALTIME = <span class="tok-number">0</span>;</span>
<span class="line" id="L2847">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> MONOTONIC = <span class="tok-number">1</span>;</span>
<span class="line" id="L2848">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> PROCESS_CPUTIME_ID = <span class="tok-number">2</span>;</span>
<span class="line" id="L2849">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> THREAD_CPUTIME_ID = <span class="tok-number">3</span>;</span>
<span class="line" id="L2850">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> MONOTONIC_RAW = <span class="tok-number">4</span>;</span>
<span class="line" id="L2851">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> REALTIME_COARSE = <span class="tok-number">5</span>;</span>
<span class="line" id="L2852">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> MONOTONIC_COARSE = <span class="tok-number">6</span>;</span>
<span class="line" id="L2853">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> BOOTTIME = <span class="tok-number">7</span>;</span>
<span class="line" id="L2854">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> REALTIME_ALARM = <span class="tok-number">8</span>;</span>
<span class="line" id="L2855">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> BOOTTIME_ALARM = <span class="tok-number">9</span>;</span>
<span class="line" id="L2856">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> SGI_CYCLE = <span class="tok-number">10</span>;</span>
<span class="line" id="L2857">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> TAI = <span class="tok-number">11</span>;</span>
<span class="line" id="L2858">};</span>
<span class="line" id="L2859"></span>
<span class="line" id="L2860"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> CSIGNAL = <span class="tok-number">0x000000ff</span>;</span>
<span class="line" id="L2861"></span>
<span class="line" id="L2862"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> CLONE = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L2863">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> VM = <span class="tok-number">0x00000100</span>;</span>
<span class="line" id="L2864">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> FS = <span class="tok-number">0x00000200</span>;</span>
<span class="line" id="L2865">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> FILES = <span class="tok-number">0x00000400</span>;</span>
<span class="line" id="L2866">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> SIGHAND = <span class="tok-number">0x00000800</span>;</span>
<span class="line" id="L2867">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> PIDFD = <span class="tok-number">0x00001000</span>;</span>
<span class="line" id="L2868">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> PTRACE = <span class="tok-number">0x00002000</span>;</span>
<span class="line" id="L2869">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> VFORK = <span class="tok-number">0x00004000</span>;</span>
<span class="line" id="L2870">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> PARENT = <span class="tok-number">0x00008000</span>;</span>
<span class="line" id="L2871">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> THREAD = <span class="tok-number">0x00010000</span>;</span>
<span class="line" id="L2872">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> NEWNS = <span class="tok-number">0x00020000</span>;</span>
<span class="line" id="L2873">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> SYSVSEM = <span class="tok-number">0x00040000</span>;</span>
<span class="line" id="L2874">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> SETTLS = <span class="tok-number">0x00080000</span>;</span>
<span class="line" id="L2875">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> PARENT_SETTID = <span class="tok-number">0x00100000</span>;</span>
<span class="line" id="L2876">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> CHILD_CLEARTID = <span class="tok-number">0x00200000</span>;</span>
<span class="line" id="L2877">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> DETACHED = <span class="tok-number">0x00400000</span>;</span>
<span class="line" id="L2878">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> UNTRACED = <span class="tok-number">0x00800000</span>;</span>
<span class="line" id="L2879">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> CHILD_SETTID = <span class="tok-number">0x01000000</span>;</span>
<span class="line" id="L2880">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> NEWCGROUP = <span class="tok-number">0x02000000</span>;</span>
<span class="line" id="L2881">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> NEWUTS = <span class="tok-number">0x04000000</span>;</span>
<span class="line" id="L2882">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> NEWIPC = <span class="tok-number">0x08000000</span>;</span>
<span class="line" id="L2883">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> NEWUSER = <span class="tok-number">0x10000000</span>;</span>
<span class="line" id="L2884">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> NEWPID = <span class="tok-number">0x20000000</span>;</span>
<span class="line" id="L2885">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> NEWNET = <span class="tok-number">0x40000000</span>;</span>
<span class="line" id="L2886">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> IO = <span class="tok-number">0x80000000</span>;</span>
<span class="line" id="L2887"></span>
<span class="line" id="L2888">    <span class="tok-comment">// Flags for the clone3() syscall.</span>
</span>
<span class="line" id="L2889"></span>
<span class="line" id="L2890">    <span class="tok-comment">/// Clear any signal handler and reset to SIG_DFL.</span></span>
<span class="line" id="L2891">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> CLEAR_SIGHAND = <span class="tok-number">0x100000000</span>;</span>
<span class="line" id="L2892">    <span class="tok-comment">/// Clone into a specific cgroup given the right permissions.</span></span>
<span class="line" id="L2893">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> INTO_CGROUP = <span class="tok-number">0x200000000</span>;</span>
<span class="line" id="L2894"></span>
<span class="line" id="L2895">    <span class="tok-comment">// cloning flags intersect with CSIGNAL so can be used with unshare and clone3 syscalls only.</span>
</span>
<span class="line" id="L2896"></span>
<span class="line" id="L2897">    <span class="tok-comment">/// New time namespace</span></span>
<span class="line" id="L2898">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> NEWTIME = <span class="tok-number">0x00000080</span>;</span>
<span class="line" id="L2899">};</span>
<span class="line" id="L2900"></span>
<span class="line" id="L2901"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> EFD = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L2902">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> SEMAPHORE = <span class="tok-number">1</span>;</span>
<span class="line" id="L2903">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> CLOEXEC = O.CLOEXEC;</span>
<span class="line" id="L2904">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> NONBLOCK = O.NONBLOCK;</span>
<span class="line" id="L2905">};</span>
<span class="line" id="L2906"></span>
<span class="line" id="L2907"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> MS = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L2908">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> RDONLY = <span class="tok-number">1</span>;</span>
<span class="line" id="L2909">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> NOSUID = <span class="tok-number">2</span>;</span>
<span class="line" id="L2910">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> NODEV = <span class="tok-number">4</span>;</span>
<span class="line" id="L2911">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> NOEXEC = <span class="tok-number">8</span>;</span>
<span class="line" id="L2912">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> SYNCHRONOUS = <span class="tok-number">16</span>;</span>
<span class="line" id="L2913">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> REMOUNT = <span class="tok-number">32</span>;</span>
<span class="line" id="L2914">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> MANDLOCK = <span class="tok-number">64</span>;</span>
<span class="line" id="L2915">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> DIRSYNC = <span class="tok-number">128</span>;</span>
<span class="line" id="L2916">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> NOATIME = <span class="tok-number">1024</span>;</span>
<span class="line" id="L2917">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> NODIRATIME = <span class="tok-number">2048</span>;</span>
<span class="line" id="L2918">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> BIND = <span class="tok-number">4096</span>;</span>
<span class="line" id="L2919">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> MOVE = <span class="tok-number">8192</span>;</span>
<span class="line" id="L2920">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> REC = <span class="tok-number">16384</span>;</span>
<span class="line" id="L2921">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> SILENT = <span class="tok-number">32768</span>;</span>
<span class="line" id="L2922">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> POSIXACL = (<span class="tok-number">1</span> &lt;&lt; <span class="tok-number">16</span>);</span>
<span class="line" id="L2923">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> UNBINDABLE = (<span class="tok-number">1</span> &lt;&lt; <span class="tok-number">17</span>);</span>
<span class="line" id="L2924">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> PRIVATE = (<span class="tok-number">1</span> &lt;&lt; <span class="tok-number">18</span>);</span>
<span class="line" id="L2925">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> SLAVE = (<span class="tok-number">1</span> &lt;&lt; <span class="tok-number">19</span>);</span>
<span class="line" id="L2926">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> SHARED = (<span class="tok-number">1</span> &lt;&lt; <span class="tok-number">20</span>);</span>
<span class="line" id="L2927">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> RELATIME = (<span class="tok-number">1</span> &lt;&lt; <span class="tok-number">21</span>);</span>
<span class="line" id="L2928">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> KERNMOUNT = (<span class="tok-number">1</span> &lt;&lt; <span class="tok-number">22</span>);</span>
<span class="line" id="L2929">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> I_VERSION = (<span class="tok-number">1</span> &lt;&lt; <span class="tok-number">23</span>);</span>
<span class="line" id="L2930">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> STRICTATIME = (<span class="tok-number">1</span> &lt;&lt; <span class="tok-number">24</span>);</span>
<span class="line" id="L2931">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> LAZYTIME = (<span class="tok-number">1</span> &lt;&lt; <span class="tok-number">25</span>);</span>
<span class="line" id="L2932">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> NOREMOTELOCK = (<span class="tok-number">1</span> &lt;&lt; <span class="tok-number">27</span>);</span>
<span class="line" id="L2933">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> NOSEC = (<span class="tok-number">1</span> &lt;&lt; <span class="tok-number">28</span>);</span>
<span class="line" id="L2934">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> BORN = (<span class="tok-number">1</span> &lt;&lt; <span class="tok-number">29</span>);</span>
<span class="line" id="L2935">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> ACTIVE = (<span class="tok-number">1</span> &lt;&lt; <span class="tok-number">30</span>);</span>
<span class="line" id="L2936">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> NOUSER = (<span class="tok-number">1</span> &lt;&lt; <span class="tok-number">31</span>);</span>
<span class="line" id="L2937"></span>
<span class="line" id="L2938">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> RMT_MASK = (RDONLY | SYNCHRONOUS | MANDLOCK | I_VERSION | LAZYTIME);</span>
<span class="line" id="L2939"></span>
<span class="line" id="L2940">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> MGC_VAL = <span class="tok-number">0xc0ed0000</span>;</span>
<span class="line" id="L2941">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> MGC_MSK = <span class="tok-number">0xffff0000</span>;</span>
<span class="line" id="L2942">};</span>
<span class="line" id="L2943"></span>
<span class="line" id="L2944"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> MNT = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L2945">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> FORCE = <span class="tok-number">1</span>;</span>
<span class="line" id="L2946">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> DETACH = <span class="tok-number">2</span>;</span>
<span class="line" id="L2947">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> EXPIRE = <span class="tok-number">4</span>;</span>
<span class="line" id="L2948">};</span>
<span class="line" id="L2949"></span>
<span class="line" id="L2950"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> UMOUNT_NOFOLLOW = <span class="tok-number">8</span>;</span>
<span class="line" id="L2951"></span>
<span class="line" id="L2952"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IN = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L2953">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> CLOEXEC = O.CLOEXEC;</span>
<span class="line" id="L2954">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> NONBLOCK = O.NONBLOCK;</span>
<span class="line" id="L2955"></span>
<span class="line" id="L2956">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> ACCESS = <span class="tok-number">0x00000001</span>;</span>
<span class="line" id="L2957">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> MODIFY = <span class="tok-number">0x00000002</span>;</span>
<span class="line" id="L2958">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> ATTRIB = <span class="tok-number">0x00000004</span>;</span>
<span class="line" id="L2959">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> CLOSE_WRITE = <span class="tok-number">0x00000008</span>;</span>
<span class="line" id="L2960">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> CLOSE_NOWRITE = <span class="tok-number">0x00000010</span>;</span>
<span class="line" id="L2961">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> CLOSE = CLOSE_WRITE | CLOSE_NOWRITE;</span>
<span class="line" id="L2962">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> OPEN = <span class="tok-number">0x00000020</span>;</span>
<span class="line" id="L2963">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> MOVED_FROM = <span class="tok-number">0x00000040</span>;</span>
<span class="line" id="L2964">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> MOVED_TO = <span class="tok-number">0x00000080</span>;</span>
<span class="line" id="L2965">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> MOVE = MOVED_FROM | MOVED_TO;</span>
<span class="line" id="L2966">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> CREATE = <span class="tok-number">0x00000100</span>;</span>
<span class="line" id="L2967">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> DELETE = <span class="tok-number">0x00000200</span>;</span>
<span class="line" id="L2968">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> DELETE_SELF = <span class="tok-number">0x00000400</span>;</span>
<span class="line" id="L2969">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> MOVE_SELF = <span class="tok-number">0x00000800</span>;</span>
<span class="line" id="L2970">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> ALL_EVENTS = <span class="tok-number">0x00000fff</span>;</span>
<span class="line" id="L2971"></span>
<span class="line" id="L2972">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> UNMOUNT = <span class="tok-number">0x00002000</span>;</span>
<span class="line" id="L2973">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> Q_OVERFLOW = <span class="tok-number">0x00004000</span>;</span>
<span class="line" id="L2974">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> IGNORED = <span class="tok-number">0x00008000</span>;</span>
<span class="line" id="L2975"></span>
<span class="line" id="L2976">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> ONLYDIR = <span class="tok-number">0x01000000</span>;</span>
<span class="line" id="L2977">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> DONT_FOLLOW = <span class="tok-number">0x02000000</span>;</span>
<span class="line" id="L2978">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> EXCL_UNLINK = <span class="tok-number">0x04000000</span>;</span>
<span class="line" id="L2979">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> MASK_CREATE = <span class="tok-number">0x10000000</span>;</span>
<span class="line" id="L2980">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> MASK_ADD = <span class="tok-number">0x20000000</span>;</span>
<span class="line" id="L2981"></span>
<span class="line" id="L2982">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> ISDIR = <span class="tok-number">0x40000000</span>;</span>
<span class="line" id="L2983">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> ONESHOT = <span class="tok-number">0x80000000</span>;</span>
<span class="line" id="L2984">};</span>
<span class="line" id="L2985"></span>
<span class="line" id="L2986"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> S = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L2987">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> IFMT = <span class="tok-number">0o170000</span>;</span>
<span class="line" id="L2988"></span>
<span class="line" id="L2989">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> IFDIR = <span class="tok-number">0o040000</span>;</span>
<span class="line" id="L2990">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> IFCHR = <span class="tok-number">0o020000</span>;</span>
<span class="line" id="L2991">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> IFBLK = <span class="tok-number">0o060000</span>;</span>
<span class="line" id="L2992">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> IFREG = <span class="tok-number">0o100000</span>;</span>
<span class="line" id="L2993">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> IFIFO = <span class="tok-number">0o010000</span>;</span>
<span class="line" id="L2994">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> IFLNK = <span class="tok-number">0o120000</span>;</span>
<span class="line" id="L2995">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> IFSOCK = <span class="tok-number">0o140000</span>;</span>
<span class="line" id="L2996"></span>
<span class="line" id="L2997">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> ISUID = <span class="tok-number">0o4000</span>;</span>
<span class="line" id="L2998">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> ISGID = <span class="tok-number">0o2000</span>;</span>
<span class="line" id="L2999">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> ISVTX = <span class="tok-number">0o1000</span>;</span>
<span class="line" id="L3000">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> IRUSR = <span class="tok-number">0o400</span>;</span>
<span class="line" id="L3001">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> IWUSR = <span class="tok-number">0o200</span>;</span>
<span class="line" id="L3002">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> IXUSR = <span class="tok-number">0o100</span>;</span>
<span class="line" id="L3003">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> IRWXU = <span class="tok-number">0o700</span>;</span>
<span class="line" id="L3004">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> IRGRP = <span class="tok-number">0o040</span>;</span>
<span class="line" id="L3005">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> IWGRP = <span class="tok-number">0o020</span>;</span>
<span class="line" id="L3006">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> IXGRP = <span class="tok-number">0o010</span>;</span>
<span class="line" id="L3007">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> IRWXG = <span class="tok-number">0o070</span>;</span>
<span class="line" id="L3008">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> IROTH = <span class="tok-number">0o004</span>;</span>
<span class="line" id="L3009">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> IWOTH = <span class="tok-number">0o002</span>;</span>
<span class="line" id="L3010">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> IXOTH = <span class="tok-number">0o001</span>;</span>
<span class="line" id="L3011">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> IRWXO = <span class="tok-number">0o007</span>;</span>
<span class="line" id="L3012"></span>
<span class="line" id="L3013">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">ISREG</span>(m: <span class="tok-type">u32</span>) <span class="tok-type">bool</span> {</span>
<span class="line" id="L3014">        <span class="tok-kw">return</span> m &amp; IFMT == IFREG;</span>
<span class="line" id="L3015">    }</span>
<span class="line" id="L3016"></span>
<span class="line" id="L3017">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">ISDIR</span>(m: <span class="tok-type">u32</span>) <span class="tok-type">bool</span> {</span>
<span class="line" id="L3018">        <span class="tok-kw">return</span> m &amp; IFMT == IFDIR;</span>
<span class="line" id="L3019">    }</span>
<span class="line" id="L3020"></span>
<span class="line" id="L3021">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">ISCHR</span>(m: <span class="tok-type">u32</span>) <span class="tok-type">bool</span> {</span>
<span class="line" id="L3022">        <span class="tok-kw">return</span> m &amp; IFMT == IFCHR;</span>
<span class="line" id="L3023">    }</span>
<span class="line" id="L3024"></span>
<span class="line" id="L3025">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">ISBLK</span>(m: <span class="tok-type">u32</span>) <span class="tok-type">bool</span> {</span>
<span class="line" id="L3026">        <span class="tok-kw">return</span> m &amp; IFMT == IFBLK;</span>
<span class="line" id="L3027">    }</span>
<span class="line" id="L3028"></span>
<span class="line" id="L3029">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">ISFIFO</span>(m: <span class="tok-type">u32</span>) <span class="tok-type">bool</span> {</span>
<span class="line" id="L3030">        <span class="tok-kw">return</span> m &amp; IFMT == IFIFO;</span>
<span class="line" id="L3031">    }</span>
<span class="line" id="L3032"></span>
<span class="line" id="L3033">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">ISLNK</span>(m: <span class="tok-type">u32</span>) <span class="tok-type">bool</span> {</span>
<span class="line" id="L3034">        <span class="tok-kw">return</span> m &amp; IFMT == IFLNK;</span>
<span class="line" id="L3035">    }</span>
<span class="line" id="L3036"></span>
<span class="line" id="L3037">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">ISSOCK</span>(m: <span class="tok-type">u32</span>) <span class="tok-type">bool</span> {</span>
<span class="line" id="L3038">        <span class="tok-kw">return</span> m &amp; IFMT == IFSOCK;</span>
<span class="line" id="L3039">    }</span>
<span class="line" id="L3040">};</span>
<span class="line" id="L3041"></span>
<span class="line" id="L3042"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> UTIME = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L3043">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> NOW = <span class="tok-number">0x3fffffff</span>;</span>
<span class="line" id="L3044">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> OMIT = <span class="tok-number">0x3ffffffe</span>;</span>
<span class="line" id="L3045">};</span>
<span class="line" id="L3046"></span>
<span class="line" id="L3047"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> TFD = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L3048">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> NONBLOCK = O.NONBLOCK;</span>
<span class="line" id="L3049">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> CLOEXEC = O.CLOEXEC;</span>
<span class="line" id="L3050"></span>
<span class="line" id="L3051">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> TIMER_ABSTIME = <span class="tok-number">1</span>;</span>
<span class="line" id="L3052">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> TIMER_CANCEL_ON_SET = (<span class="tok-number">1</span> &lt;&lt; <span class="tok-number">1</span>);</span>
<span class="line" id="L3053">};</span>
<span class="line" id="L3054"></span>
<span class="line" id="L3055"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> winsize = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L3056">    ws_row: <span class="tok-type">u16</span>,</span>
<span class="line" id="L3057">    ws_col: <span class="tok-type">u16</span>,</span>
<span class="line" id="L3058">    ws_xpixel: <span class="tok-type">u16</span>,</span>
<span class="line" id="L3059">    ws_ypixel: <span class="tok-type">u16</span>,</span>
<span class="line" id="L3060">};</span>
<span class="line" id="L3061"></span>
<span class="line" id="L3062"><span class="tok-comment">/// NSIG is the total number of signals defined.</span></span>
<span class="line" id="L3063"><span class="tok-comment">/// As signal numbers are sequential, NSIG is one greater than the largest defined signal number.</span></span>
<span class="line" id="L3064"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> NSIG = <span class="tok-kw">if</span> (is_mips) <span class="tok-number">128</span> <span class="tok-kw">else</span> <span class="tok-number">65</span>;</span>
<span class="line" id="L3065"></span>
<span class="line" id="L3066"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> sigset_t = [<span class="tok-number">1024</span> / <span class="tok-number">32</span>]<span class="tok-type">u32</span>;</span>
<span class="line" id="L3067"></span>
<span class="line" id="L3068"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> all_mask: sigset_t = [_]<span class="tok-type">u32</span>{<span class="tok-number">0xffffffff</span>} ** <span class="tok-builtin">@typeInfo</span>(sigset_t).Array.len;</span>
<span class="line" id="L3069"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> app_mask: sigset_t = [<span class="tok-number">2</span>]<span class="tok-type">u32</span>{ <span class="tok-number">0xfffffffc</span>, <span class="tok-number">0x7fffffff</span> } ++ [_]<span class="tok-type">u32</span>{<span class="tok-number">0xffffffff</span>} ** <span class="tok-number">30</span>;</span>
<span class="line" id="L3070"></span>
<span class="line" id="L3071"><span class="tok-kw">const</span> k_sigaction_funcs = <span class="tok-kw">if</span> (builtin.zig_backend == .stage1) <span class="tok-kw">struct</span> {</span>
<span class="line" id="L3072">    <span class="tok-kw">const</span> handler = ?<span class="tok-kw">fn</span> (<span class="tok-type">c_int</span>) <span class="tok-kw">callconv</span>(.C) <span class="tok-type">void</span>;</span>
<span class="line" id="L3073">    <span class="tok-kw">const</span> restorer = <span class="tok-kw">fn</span> () <span class="tok-kw">callconv</span>(.C) <span class="tok-type">void</span>;</span>
<span class="line" id="L3074">} <span class="tok-kw">else</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L3075">    <span class="tok-kw">const</span> handler = ?*<span class="tok-kw">const</span> <span class="tok-kw">fn</span> (<span class="tok-type">c_int</span>) <span class="tok-kw">callconv</span>(.C) <span class="tok-type">void</span>;</span>
<span class="line" id="L3076">    <span class="tok-kw">const</span> restorer = *<span class="tok-kw">const</span> <span class="tok-kw">fn</span> () <span class="tok-kw">callconv</span>(.C) <span class="tok-type">void</span>;</span>
<span class="line" id="L3077">};</span>
<span class="line" id="L3078"></span>
<span class="line" id="L3079"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> k_sigaction = <span class="tok-kw">switch</span> (native_arch) {</span>
<span class="line" id="L3080">    .mips, .mipsel =&gt; <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L3081">        flags: <span class="tok-type">c_uint</span>,</span>
<span class="line" id="L3082">        handler: k_sigaction_funcs.handler,</span>
<span class="line" id="L3083">        mask: [<span class="tok-number">4</span>]<span class="tok-type">c_ulong</span>,</span>
<span class="line" id="L3084">        restorer: k_sigaction_funcs.restorer,</span>
<span class="line" id="L3085">    },</span>
<span class="line" id="L3086">    .mips64, .mips64el =&gt; <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L3087">        flags: <span class="tok-type">c_uint</span>,</span>
<span class="line" id="L3088">        handler: k_sigaction_funcs.handler,</span>
<span class="line" id="L3089">        mask: [<span class="tok-number">2</span>]<span class="tok-type">c_ulong</span>,</span>
<span class="line" id="L3090">        restorer: k_sigaction_funcs.restorer,</span>
<span class="line" id="L3091">    },</span>
<span class="line" id="L3092">    <span class="tok-kw">else</span> =&gt; <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L3093">        handler: k_sigaction_funcs.handler,</span>
<span class="line" id="L3094">        flags: <span class="tok-type">c_ulong</span>,</span>
<span class="line" id="L3095">        restorer: k_sigaction_funcs.restorer,</span>
<span class="line" id="L3096">        mask: [<span class="tok-number">2</span>]<span class="tok-type">c_uint</span>,</span>
<span class="line" id="L3097">    },</span>
<span class="line" id="L3098">};</span>
<span class="line" id="L3099"></span>
<span class="line" id="L3100"><span class="tok-comment">/// Renamed from `sigaction` to `Sigaction` to avoid conflict with the syscall.</span></span>
<span class="line" id="L3101"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> Sigaction = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L3102">    <span class="tok-kw">pub</span> <span class="tok-kw">usingnamespace</span> <span class="tok-kw">if</span> (builtin.zig_backend == .stage1) <span class="tok-kw">struct</span> {</span>
<span class="line" id="L3103">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> handler_fn = <span class="tok-kw">fn</span> (<span class="tok-type">c_int</span>) <span class="tok-kw">callconv</span>(.C) <span class="tok-type">void</span>;</span>
<span class="line" id="L3104">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> sigaction_fn = <span class="tok-kw">fn</span> (<span class="tok-type">c_int</span>, *<span class="tok-kw">const</span> siginfo_t, ?*<span class="tok-kw">const</span> <span class="tok-type">anyopaque</span>) <span class="tok-kw">callconv</span>(.C) <span class="tok-type">void</span>;</span>
<span class="line" id="L3105">    } <span class="tok-kw">else</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L3106">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> handler_fn = *<span class="tok-kw">const</span> <span class="tok-kw">fn</span> (<span class="tok-type">c_int</span>) <span class="tok-kw">callconv</span>(.C) <span class="tok-type">void</span>;</span>
<span class="line" id="L3107">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> sigaction_fn = *<span class="tok-kw">const</span> <span class="tok-kw">fn</span> (<span class="tok-type">c_int</span>, *<span class="tok-kw">const</span> siginfo_t, ?*<span class="tok-kw">const</span> <span class="tok-type">anyopaque</span>) <span class="tok-kw">callconv</span>(.C) <span class="tok-type">void</span>;</span>
<span class="line" id="L3108">    };</span>
<span class="line" id="L3109"></span>
<span class="line" id="L3110">    handler: <span class="tok-kw">extern</span> <span class="tok-kw">union</span> {</span>
<span class="line" id="L3111">        handler: ?Sigaction.handler_fn,</span>
<span class="line" id="L3112">        sigaction: ?Sigaction.sigaction_fn,</span>
<span class="line" id="L3113">    },</span>
<span class="line" id="L3114">    mask: sigset_t,</span>
<span class="line" id="L3115">    flags: <span class="tok-type">c_uint</span>,</span>
<span class="line" id="L3116">    restorer: ?<span class="tok-kw">if</span> (builtin.zig_backend == .stage1)</span>
<span class="line" id="L3117">        <span class="tok-kw">fn</span> () <span class="tok-kw">callconv</span>(.C) <span class="tok-type">void</span></span>
<span class="line" id="L3118">    <span class="tok-kw">else</span></span>
<span class="line" id="L3119">        *<span class="tok-kw">const</span> <span class="tok-kw">fn</span> () <span class="tok-kw">callconv</span>(.C) <span class="tok-type">void</span> = <span class="tok-null">null</span>,</span>
<span class="line" id="L3120">};</span>
<span class="line" id="L3121"></span>
<span class="line" id="L3122"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> empty_sigset = [_]<span class="tok-type">u32</span>{<span class="tok-number">0</span>} ** <span class="tok-builtin">@typeInfo</span>(sigset_t).Array.len;</span>
<span class="line" id="L3123"></span>
<span class="line" id="L3124"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SFD = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L3125">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> CLOEXEC = O.CLOEXEC;</span>
<span class="line" id="L3126">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> NONBLOCK = O.NONBLOCK;</span>
<span class="line" id="L3127">};</span>
<span class="line" id="L3128"></span>
<span class="line" id="L3129"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> signalfd_siginfo = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L3130">    signo: <span class="tok-type">u32</span>,</span>
<span class="line" id="L3131">    errno: <span class="tok-type">i32</span>,</span>
<span class="line" id="L3132">    code: <span class="tok-type">i32</span>,</span>
<span class="line" id="L3133">    pid: <span class="tok-type">u32</span>,</span>
<span class="line" id="L3134">    uid: uid_t,</span>
<span class="line" id="L3135">    fd: <span class="tok-type">i32</span>,</span>
<span class="line" id="L3136">    tid: <span class="tok-type">u32</span>,</span>
<span class="line" id="L3137">    band: <span class="tok-type">u32</span>,</span>
<span class="line" id="L3138">    overrun: <span class="tok-type">u32</span>,</span>
<span class="line" id="L3139">    trapno: <span class="tok-type">u32</span>,</span>
<span class="line" id="L3140">    status: <span class="tok-type">i32</span>,</span>
<span class="line" id="L3141">    int: <span class="tok-type">i32</span>,</span>
<span class="line" id="L3142">    ptr: <span class="tok-type">u64</span>,</span>
<span class="line" id="L3143">    utime: <span class="tok-type">u64</span>,</span>
<span class="line" id="L3144">    stime: <span class="tok-type">u64</span>,</span>
<span class="line" id="L3145">    addr: <span class="tok-type">u64</span>,</span>
<span class="line" id="L3146">    addr_lsb: <span class="tok-type">u16</span>,</span>
<span class="line" id="L3147">    __pad2: <span class="tok-type">u16</span>,</span>
<span class="line" id="L3148">    syscall: <span class="tok-type">i32</span>,</span>
<span class="line" id="L3149">    call_addr: <span class="tok-type">u64</span>,</span>
<span class="line" id="L3150">    native_arch: <span class="tok-type">u32</span>,</span>
<span class="line" id="L3151">    __pad: [<span class="tok-number">28</span>]<span class="tok-type">u8</span>,</span>
<span class="line" id="L3152">};</span>
<span class="line" id="L3153"></span>
<span class="line" id="L3154"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> in_port_t = <span class="tok-type">u16</span>;</span>
<span class="line" id="L3155"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> sa_family_t = <span class="tok-type">u16</span>;</span>
<span class="line" id="L3156"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> socklen_t = <span class="tok-type">u32</span>;</span>
<span class="line" id="L3157"></span>
<span class="line" id="L3158"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> sockaddr = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L3159">    family: sa_family_t,</span>
<span class="line" id="L3160">    data: [<span class="tok-number">14</span>]<span class="tok-type">u8</span>,</span>
<span class="line" id="L3161"></span>
<span class="line" id="L3162">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> SS_MAXSIZE = <span class="tok-number">128</span>;</span>
<span class="line" id="L3163">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> storage = std.x.os.Socket.Address.Native.Storage;</span>
<span class="line" id="L3164"></span>
<span class="line" id="L3165">    <span class="tok-comment">/// IPv4 socket address</span></span>
<span class="line" id="L3166">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> in = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L3167">        family: sa_family_t = AF.INET,</span>
<span class="line" id="L3168">        port: in_port_t,</span>
<span class="line" id="L3169">        addr: <span class="tok-type">u32</span>,</span>
<span class="line" id="L3170">        zero: [<span class="tok-number">8</span>]<span class="tok-type">u8</span> = [<span class="tok-number">8</span>]<span class="tok-type">u8</span>{ <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span> },</span>
<span class="line" id="L3171">    };</span>
<span class="line" id="L3172"></span>
<span class="line" id="L3173">    <span class="tok-comment">/// IPv6 socket address</span></span>
<span class="line" id="L3174">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> in6 = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L3175">        family: sa_family_t = AF.INET6,</span>
<span class="line" id="L3176">        port: in_port_t,</span>
<span class="line" id="L3177">        flowinfo: <span class="tok-type">u32</span>,</span>
<span class="line" id="L3178">        addr: [<span class="tok-number">16</span>]<span class="tok-type">u8</span>,</span>
<span class="line" id="L3179">        scope_id: <span class="tok-type">u32</span>,</span>
<span class="line" id="L3180">    };</span>
<span class="line" id="L3181"></span>
<span class="line" id="L3182">    <span class="tok-comment">/// UNIX domain socket address</span></span>
<span class="line" id="L3183">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> un = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L3184">        family: sa_family_t = AF.UNIX,</span>
<span class="line" id="L3185">        path: [<span class="tok-number">108</span>]<span class="tok-type">u8</span>,</span>
<span class="line" id="L3186">    };</span>
<span class="line" id="L3187"></span>
<span class="line" id="L3188">    <span class="tok-comment">/// Netlink socket address</span></span>
<span class="line" id="L3189">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> nl = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L3190">        family: sa_family_t = AF.NETLINK,</span>
<span class="line" id="L3191">        __pad1: <span class="tok-type">c_ushort</span> = <span class="tok-number">0</span>,</span>
<span class="line" id="L3192"></span>
<span class="line" id="L3193">        <span class="tok-comment">/// port ID</span></span>
<span class="line" id="L3194">        pid: <span class="tok-type">u32</span>,</span>
<span class="line" id="L3195"></span>
<span class="line" id="L3196">        <span class="tok-comment">/// multicast groups mask</span></span>
<span class="line" id="L3197">        groups: <span class="tok-type">u32</span>,</span>
<span class="line" id="L3198">    };</span>
<span class="line" id="L3199"></span>
<span class="line" id="L3200">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> xdp = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L3201">        family: <span class="tok-type">u16</span> = AF.XDP,</span>
<span class="line" id="L3202">        flags: <span class="tok-type">u16</span>,</span>
<span class="line" id="L3203">        ifindex: <span class="tok-type">u32</span>,</span>
<span class="line" id="L3204">        queue_id: <span class="tok-type">u32</span>,</span>
<span class="line" id="L3205">        shared_umem_fd: <span class="tok-type">u32</span>,</span>
<span class="line" id="L3206">    };</span>
<span class="line" id="L3207">};</span>
<span class="line" id="L3208"></span>
<span class="line" id="L3209"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> mmsghdr = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L3210">    msg_hdr: msghdr,</span>
<span class="line" id="L3211">    msg_len: <span class="tok-type">u32</span>,</span>
<span class="line" id="L3212">};</span>
<span class="line" id="L3213"></span>
<span class="line" id="L3214"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> mmsghdr_const = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L3215">    msg_hdr: msghdr_const,</span>
<span class="line" id="L3216">    msg_len: <span class="tok-type">u32</span>,</span>
<span class="line" id="L3217">};</span>
<span class="line" id="L3218"></span>
<span class="line" id="L3219"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> epoll_data = <span class="tok-kw">extern</span> <span class="tok-kw">union</span> {</span>
<span class="line" id="L3220">    ptr: <span class="tok-type">usize</span>,</span>
<span class="line" id="L3221">    fd: <span class="tok-type">i32</span>,</span>
<span class="line" id="L3222">    @&quot;u32&quot;: <span class="tok-type">u32</span>,</span>
<span class="line" id="L3223">    @&quot;u64&quot;: <span class="tok-type">u64</span>,</span>
<span class="line" id="L3224">};</span>
<span class="line" id="L3225"></span>
<span class="line" id="L3226"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> epoll_event = <span class="tok-kw">switch</span> (builtin.zig_backend) {</span>
<span class="line" id="L3227">    <span class="tok-comment">// stage1 crashes with the align(4) field so we have this workaround</span>
</span>
<span class="line" id="L3228">    .stage1 =&gt; <span class="tok-kw">switch</span> (native_arch) {</span>
<span class="line" id="L3229">        .x86_64 =&gt; <span class="tok-kw">packed</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L3230">            events: <span class="tok-type">u32</span>,</span>
<span class="line" id="L3231">            data: epoll_data,</span>
<span class="line" id="L3232">        },</span>
<span class="line" id="L3233">        <span class="tok-kw">else</span> =&gt; <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L3234">            events: <span class="tok-type">u32</span>,</span>
<span class="line" id="L3235">            data: epoll_data,</span>
<span class="line" id="L3236">        },</span>
<span class="line" id="L3237">    },</span>
<span class="line" id="L3238">    <span class="tok-kw">else</span> =&gt; <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L3239">        events: <span class="tok-type">u32</span>,</span>
<span class="line" id="L3240">        data: epoll_data <span class="tok-kw">align</span>(<span class="tok-kw">switch</span> (native_arch) {</span>
<span class="line" id="L3241">            .x86_64 =&gt; <span class="tok-number">4</span>,</span>
<span class="line" id="L3242">            <span class="tok-kw">else</span> =&gt; <span class="tok-builtin">@alignOf</span>(epoll_data),</span>
<span class="line" id="L3243">        }),</span>
<span class="line" id="L3244">    },</span>
<span class="line" id="L3245">};</span>
<span class="line" id="L3246"></span>
<span class="line" id="L3247"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> VFS_CAP_REVISION_MASK = <span class="tok-number">0xFF000000</span>;</span>
<span class="line" id="L3248"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> VFS_CAP_REVISION_SHIFT = <span class="tok-number">24</span>;</span>
<span class="line" id="L3249"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> VFS_CAP_FLAGS_MASK = ~VFS_CAP_REVISION_MASK;</span>
<span class="line" id="L3250"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> VFS_CAP_FLAGS_EFFECTIVE = <span class="tok-number">0x000001</span>;</span>
<span class="line" id="L3251"></span>
<span class="line" id="L3252"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> VFS_CAP_REVISION_1 = <span class="tok-number">0x01000000</span>;</span>
<span class="line" id="L3253"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> VFS_CAP_U32_1 = <span class="tok-number">1</span>;</span>
<span class="line" id="L3254"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> XATTR_CAPS_SZ_1 = <span class="tok-builtin">@sizeOf</span>(<span class="tok-type">u32</span>) * (<span class="tok-number">1</span> + <span class="tok-number">2</span> * VFS_CAP_U32_1);</span>
<span class="line" id="L3255"></span>
<span class="line" id="L3256"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> VFS_CAP_REVISION_2 = <span class="tok-number">0x02000000</span>;</span>
<span class="line" id="L3257"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> VFS_CAP_U32_2 = <span class="tok-number">2</span>;</span>
<span class="line" id="L3258"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> XATTR_CAPS_SZ_2 = <span class="tok-builtin">@sizeOf</span>(<span class="tok-type">u32</span>) * (<span class="tok-number">1</span> + <span class="tok-number">2</span> * VFS_CAP_U32_2);</span>
<span class="line" id="L3259"></span>
<span class="line" id="L3260"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> XATTR_CAPS_SZ = XATTR_CAPS_SZ_2;</span>
<span class="line" id="L3261"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> VFS_CAP_U32 = VFS_CAP_U32_2;</span>
<span class="line" id="L3262"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> VFS_CAP_REVISION = VFS_CAP_REVISION_2;</span>
<span class="line" id="L3263"></span>
<span class="line" id="L3264"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> vfs_cap_data = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L3265">    <span class="tok-comment">//all of these are mandated as little endian</span>
</span>
<span class="line" id="L3266">    <span class="tok-comment">//when on disk.</span>
</span>
<span class="line" id="L3267">    <span class="tok-kw">const</span> Data = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L3268">        permitted: <span class="tok-type">u32</span>,</span>
<span class="line" id="L3269">        inheritable: <span class="tok-type">u32</span>,</span>
<span class="line" id="L3270">    };</span>
<span class="line" id="L3271"></span>
<span class="line" id="L3272">    magic_etc: <span class="tok-type">u32</span>,</span>
<span class="line" id="L3273">    data: [VFS_CAP_U32]Data,</span>
<span class="line" id="L3274">};</span>
<span class="line" id="L3275"></span>
<span class="line" id="L3276"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> CAP = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L3277">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> CHOWN = <span class="tok-number">0</span>;</span>
<span class="line" id="L3278">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> DAC_OVERRIDE = <span class="tok-number">1</span>;</span>
<span class="line" id="L3279">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> DAC_READ_SEARCH = <span class="tok-number">2</span>;</span>
<span class="line" id="L3280">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> FOWNER = <span class="tok-number">3</span>;</span>
<span class="line" id="L3281">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> FSETID = <span class="tok-number">4</span>;</span>
<span class="line" id="L3282">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> KILL = <span class="tok-number">5</span>;</span>
<span class="line" id="L3283">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> SETGID = <span class="tok-number">6</span>;</span>
<span class="line" id="L3284">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> SETUID = <span class="tok-number">7</span>;</span>
<span class="line" id="L3285">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> SETPCAP = <span class="tok-number">8</span>;</span>
<span class="line" id="L3286">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> LINUX_IMMUTABLE = <span class="tok-number">9</span>;</span>
<span class="line" id="L3287">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> NET_BIND_SERVICE = <span class="tok-number">10</span>;</span>
<span class="line" id="L3288">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> NET_BROADCAST = <span class="tok-number">11</span>;</span>
<span class="line" id="L3289">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> NET_ADMIN = <span class="tok-number">12</span>;</span>
<span class="line" id="L3290">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> NET_RAW = <span class="tok-number">13</span>;</span>
<span class="line" id="L3291">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> IPC_LOCK = <span class="tok-number">14</span>;</span>
<span class="line" id="L3292">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> IPC_OWNER = <span class="tok-number">15</span>;</span>
<span class="line" id="L3293">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> SYS_MODULE = <span class="tok-number">16</span>;</span>
<span class="line" id="L3294">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> SYS_RAWIO = <span class="tok-number">17</span>;</span>
<span class="line" id="L3295">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> SYS_CHROOT = <span class="tok-number">18</span>;</span>
<span class="line" id="L3296">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> SYS_PTRACE = <span class="tok-number">19</span>;</span>
<span class="line" id="L3297">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> SYS_PACCT = <span class="tok-number">20</span>;</span>
<span class="line" id="L3298">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> SYS_ADMIN = <span class="tok-number">21</span>;</span>
<span class="line" id="L3299">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> SYS_BOOT = <span class="tok-number">22</span>;</span>
<span class="line" id="L3300">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> SYS_NICE = <span class="tok-number">23</span>;</span>
<span class="line" id="L3301">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> SYS_RESOURCE = <span class="tok-number">24</span>;</span>
<span class="line" id="L3302">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> SYS_TIME = <span class="tok-number">25</span>;</span>
<span class="line" id="L3303">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> SYS_TTY_CONFIG = <span class="tok-number">26</span>;</span>
<span class="line" id="L3304">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> MKNOD = <span class="tok-number">27</span>;</span>
<span class="line" id="L3305">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> LEASE = <span class="tok-number">28</span>;</span>
<span class="line" id="L3306">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> AUDIT_WRITE = <span class="tok-number">29</span>;</span>
<span class="line" id="L3307">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> AUDIT_CONTROL = <span class="tok-number">30</span>;</span>
<span class="line" id="L3308">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> SETFCAP = <span class="tok-number">31</span>;</span>
<span class="line" id="L3309">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> MAC_OVERRIDE = <span class="tok-number">32</span>;</span>
<span class="line" id="L3310">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> MAC_ADMIN = <span class="tok-number">33</span>;</span>
<span class="line" id="L3311">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> SYSLOG = <span class="tok-number">34</span>;</span>
<span class="line" id="L3312">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> WAKE_ALARM = <span class="tok-number">35</span>;</span>
<span class="line" id="L3313">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> BLOCK_SUSPEND = <span class="tok-number">36</span>;</span>
<span class="line" id="L3314">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> AUDIT_READ = <span class="tok-number">37</span>;</span>
<span class="line" id="L3315">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> LAST_CAP = AUDIT_READ;</span>
<span class="line" id="L3316"></span>
<span class="line" id="L3317">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">valid</span>(x: <span class="tok-type">u8</span>) <span class="tok-type">bool</span> {</span>
<span class="line" id="L3318">        <span class="tok-kw">return</span> x &gt;= <span class="tok-number">0</span> <span class="tok-kw">and</span> x &lt;= LAST_CAP;</span>
<span class="line" id="L3319">    }</span>
<span class="line" id="L3320"></span>
<span class="line" id="L3321">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">TO_MASK</span>(cap: <span class="tok-type">u8</span>) <span class="tok-type">u32</span> {</span>
<span class="line" id="L3322">        <span class="tok-kw">return</span> <span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">1</span>) &lt;&lt; <span class="tok-builtin">@intCast</span>(<span class="tok-type">u5</span>, cap &amp; <span class="tok-number">31</span>);</span>
<span class="line" id="L3323">    }</span>
<span class="line" id="L3324"></span>
<span class="line" id="L3325">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">TO_INDEX</span>(cap: <span class="tok-type">u8</span>) <span class="tok-type">u8</span> {</span>
<span class="line" id="L3326">        <span class="tok-kw">return</span> cap &gt;&gt; <span class="tok-number">5</span>;</span>
<span class="line" id="L3327">    }</span>
<span class="line" id="L3328">};</span>
<span class="line" id="L3329"></span>
<span class="line" id="L3330"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> cap_t = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L3331">    hdrp: *cap_user_header_t,</span>
<span class="line" id="L3332">    datap: *cap_user_data_t,</span>
<span class="line" id="L3333">};</span>
<span class="line" id="L3334"></span>
<span class="line" id="L3335"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> cap_user_header_t = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L3336">    version: <span class="tok-type">u32</span>,</span>
<span class="line" id="L3337">    pid: <span class="tok-type">usize</span>,</span>
<span class="line" id="L3338">};</span>
<span class="line" id="L3339"></span>
<span class="line" id="L3340"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> cap_user_data_t = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L3341">    effective: <span class="tok-type">u32</span>,</span>
<span class="line" id="L3342">    permitted: <span class="tok-type">u32</span>,</span>
<span class="line" id="L3343">    inheritable: <span class="tok-type">u32</span>,</span>
<span class="line" id="L3344">};</span>
<span class="line" id="L3345"></span>
<span class="line" id="L3346"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> inotify_event = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L3347">    wd: <span class="tok-type">i32</span>,</span>
<span class="line" id="L3348">    mask: <span class="tok-type">u32</span>,</span>
<span class="line" id="L3349">    cookie: <span class="tok-type">u32</span>,</span>
<span class="line" id="L3350">    len: <span class="tok-type">u32</span>,</span>
<span class="line" id="L3351">    <span class="tok-comment">//name: [?]u8,</span>
</span>
<span class="line" id="L3352">};</span>
<span class="line" id="L3353"></span>
<span class="line" id="L3354"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> dirent64 = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L3355">    d_ino: <span class="tok-type">u64</span>,</span>
<span class="line" id="L3356">    d_off: <span class="tok-type">u64</span>,</span>
<span class="line" id="L3357">    d_reclen: <span class="tok-type">u16</span>,</span>
<span class="line" id="L3358">    d_type: <span class="tok-type">u8</span>,</span>
<span class="line" id="L3359">    d_name: <span class="tok-type">u8</span>, <span class="tok-comment">// field address is the address of first byte of name https://github.com/ziglang/zig/issues/173</span>
</span>
<span class="line" id="L3360"></span>
<span class="line" id="L3361">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">reclen</span>(self: dirent64) <span class="tok-type">u16</span> {</span>
<span class="line" id="L3362">        <span class="tok-kw">return</span> self.d_reclen;</span>
<span class="line" id="L3363">    }</span>
<span class="line" id="L3364">};</span>
<span class="line" id="L3365"></span>
<span class="line" id="L3366"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> dl_phdr_info = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L3367">    dlpi_addr: <span class="tok-type">usize</span>,</span>
<span class="line" id="L3368">    dlpi_name: ?[*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L3369">    dlpi_phdr: [*]std.elf.Phdr,</span>
<span class="line" id="L3370">    dlpi_phnum: <span class="tok-type">u16</span>,</span>
<span class="line" id="L3371">};</span>
<span class="line" id="L3372"></span>
<span class="line" id="L3373"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> CPU_SETSIZE = <span class="tok-number">128</span>;</span>
<span class="line" id="L3374"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> cpu_set_t = [CPU_SETSIZE / <span class="tok-builtin">@sizeOf</span>(<span class="tok-type">usize</span>)]<span class="tok-type">usize</span>;</span>
<span class="line" id="L3375"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> cpu_count_t = std.meta.Int(.unsigned, std.math.log2(CPU_SETSIZE * <span class="tok-number">8</span>));</span>
<span class="line" id="L3376"></span>
<span class="line" id="L3377"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">CPU_COUNT</span>(set: cpu_set_t) cpu_count_t {</span>
<span class="line" id="L3378">    <span class="tok-kw">var</span> sum: cpu_count_t = <span class="tok-number">0</span>;</span>
<span class="line" id="L3379">    <span class="tok-kw">for</span> (set) |x| {</span>
<span class="line" id="L3380">        sum += <span class="tok-builtin">@popCount</span>(<span class="tok-type">usize</span>, x);</span>
<span class="line" id="L3381">    }</span>
<span class="line" id="L3382">    <span class="tok-kw">return</span> sum;</span>
<span class="line" id="L3383">}</span>
<span class="line" id="L3384"></span>
<span class="line" id="L3385"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> MINSIGSTKSZ = <span class="tok-kw">switch</span> (native_arch) {</span>
<span class="line" id="L3386">    .<span class="tok-type">i386</span>, .x86_64, .arm, .mipsel =&gt; <span class="tok-number">2048</span>,</span>
<span class="line" id="L3387">    .aarch64 =&gt; <span class="tok-number">5120</span>,</span>
<span class="line" id="L3388">    <span class="tok-kw">else</span> =&gt; <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;MINSIGSTKSZ not defined for this architecture&quot;</span>),</span>
<span class="line" id="L3389">};</span>
<span class="line" id="L3390"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SIGSTKSZ = <span class="tok-kw">switch</span> (native_arch) {</span>
<span class="line" id="L3391">    .<span class="tok-type">i386</span>, .x86_64, .arm, .mipsel =&gt; <span class="tok-number">8192</span>,</span>
<span class="line" id="L3392">    .aarch64 =&gt; <span class="tok-number">16384</span>,</span>
<span class="line" id="L3393">    <span class="tok-kw">else</span> =&gt; <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;SIGSTKSZ not defined for this architecture&quot;</span>),</span>
<span class="line" id="L3394">};</span>
<span class="line" id="L3395"></span>
<span class="line" id="L3396"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SS_ONSTACK = <span class="tok-number">1</span>;</span>
<span class="line" id="L3397"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SS_DISABLE = <span class="tok-number">2</span>;</span>
<span class="line" id="L3398"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SS_AUTODISARM = <span class="tok-number">1</span> &lt;&lt; <span class="tok-number">31</span>;</span>
<span class="line" id="L3399"></span>
<span class="line" id="L3400"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> stack_t = <span class="tok-kw">if</span> (is_mips)</span>
<span class="line" id="L3401">    <span class="tok-comment">// IRIX compatible stack_t</span>
</span>
<span class="line" id="L3402">    <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L3403">        sp: [*]<span class="tok-type">u8</span>,</span>
<span class="line" id="L3404">        size: <span class="tok-type">usize</span>,</span>
<span class="line" id="L3405">        flags: <span class="tok-type">i32</span>,</span>
<span class="line" id="L3406">    }</span>
<span class="line" id="L3407"><span class="tok-kw">else</span></span>
<span class="line" id="L3408">    <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L3409">        sp: [*]<span class="tok-type">u8</span>,</span>
<span class="line" id="L3410">        flags: <span class="tok-type">i32</span>,</span>
<span class="line" id="L3411">        size: <span class="tok-type">usize</span>,</span>
<span class="line" id="L3412">    };</span>
<span class="line" id="L3413"></span>
<span class="line" id="L3414"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> sigval = <span class="tok-kw">extern</span> <span class="tok-kw">union</span> {</span>
<span class="line" id="L3415">    int: <span class="tok-type">i32</span>,</span>
<span class="line" id="L3416">    ptr: *<span class="tok-type">anyopaque</span>,</span>
<span class="line" id="L3417">};</span>
<span class="line" id="L3418"></span>
<span class="line" id="L3419"><span class="tok-kw">const</span> siginfo_fields_union = <span class="tok-kw">extern</span> <span class="tok-kw">union</span> {</span>
<span class="line" id="L3420">    pad: [<span class="tok-number">128</span> - <span class="tok-number">2</span> * <span class="tok-builtin">@sizeOf</span>(<span class="tok-type">c_int</span>) - <span class="tok-builtin">@sizeOf</span>(<span class="tok-type">c_long</span>)]<span class="tok-type">u8</span>,</span>
<span class="line" id="L3421">    common: <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L3422">        first: <span class="tok-kw">extern</span> <span class="tok-kw">union</span> {</span>
<span class="line" id="L3423">            piduid: <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L3424">                pid: pid_t,</span>
<span class="line" id="L3425">                uid: uid_t,</span>
<span class="line" id="L3426">            },</span>
<span class="line" id="L3427">            timer: <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L3428">                timerid: <span class="tok-type">i32</span>,</span>
<span class="line" id="L3429">                overrun: <span class="tok-type">i32</span>,</span>
<span class="line" id="L3430">            },</span>
<span class="line" id="L3431">        },</span>
<span class="line" id="L3432">        second: <span class="tok-kw">extern</span> <span class="tok-kw">union</span> {</span>
<span class="line" id="L3433">            value: sigval,</span>
<span class="line" id="L3434">            sigchld: <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L3435">                status: <span class="tok-type">i32</span>,</span>
<span class="line" id="L3436">                utime: clock_t,</span>
<span class="line" id="L3437">                stime: clock_t,</span>
<span class="line" id="L3438">            },</span>
<span class="line" id="L3439">        },</span>
<span class="line" id="L3440">    },</span>
<span class="line" id="L3441">    sigfault: <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L3442">        addr: *<span class="tok-type">anyopaque</span>,</span>
<span class="line" id="L3443">        addr_lsb: <span class="tok-type">i16</span>,</span>
<span class="line" id="L3444">        first: <span class="tok-kw">extern</span> <span class="tok-kw">union</span> {</span>
<span class="line" id="L3445">            addr_bnd: <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L3446">                lower: *<span class="tok-type">anyopaque</span>,</span>
<span class="line" id="L3447">                upper: *<span class="tok-type">anyopaque</span>,</span>
<span class="line" id="L3448">            },</span>
<span class="line" id="L3449">            pkey: <span class="tok-type">u32</span>,</span>
<span class="line" id="L3450">        },</span>
<span class="line" id="L3451">    },</span>
<span class="line" id="L3452">    sigpoll: <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L3453">        band: <span class="tok-type">isize</span>,</span>
<span class="line" id="L3454">        fd: <span class="tok-type">i32</span>,</span>
<span class="line" id="L3455">    },</span>
<span class="line" id="L3456">    sigsys: <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L3457">        call_addr: *<span class="tok-type">anyopaque</span>,</span>
<span class="line" id="L3458">        syscall: <span class="tok-type">i32</span>,</span>
<span class="line" id="L3459">        native_arch: <span class="tok-type">u32</span>,</span>
<span class="line" id="L3460">    },</span>
<span class="line" id="L3461">};</span>
<span class="line" id="L3462"></span>
<span class="line" id="L3463"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> siginfo_t = <span class="tok-kw">if</span> (is_mips)</span>
<span class="line" id="L3464">    <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L3465">        signo: <span class="tok-type">i32</span>,</span>
<span class="line" id="L3466">        code: <span class="tok-type">i32</span>,</span>
<span class="line" id="L3467">        errno: <span class="tok-type">i32</span>,</span>
<span class="line" id="L3468">        fields: siginfo_fields_union,</span>
<span class="line" id="L3469">    }</span>
<span class="line" id="L3470"><span class="tok-kw">else</span></span>
<span class="line" id="L3471">    <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L3472">        signo: <span class="tok-type">i32</span>,</span>
<span class="line" id="L3473">        errno: <span class="tok-type">i32</span>,</span>
<span class="line" id="L3474">        code: <span class="tok-type">i32</span>,</span>
<span class="line" id="L3475">        fields: siginfo_fields_union,</span>
<span class="line" id="L3476">    };</span>
<span class="line" id="L3477"></span>
<span class="line" id="L3478"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> io_uring_params = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L3479">    sq_entries: <span class="tok-type">u32</span>,</span>
<span class="line" id="L3480">    cq_entries: <span class="tok-type">u32</span>,</span>
<span class="line" id="L3481">    flags: <span class="tok-type">u32</span>,</span>
<span class="line" id="L3482">    sq_thread_cpu: <span class="tok-type">u32</span>,</span>
<span class="line" id="L3483">    sq_thread_idle: <span class="tok-type">u32</span>,</span>
<span class="line" id="L3484">    features: <span class="tok-type">u32</span>,</span>
<span class="line" id="L3485">    wq_fd: <span class="tok-type">u32</span>,</span>
<span class="line" id="L3486">    resv: [<span class="tok-number">3</span>]<span class="tok-type">u32</span>,</span>
<span class="line" id="L3487">    sq_off: io_sqring_offsets,</span>
<span class="line" id="L3488">    cq_off: io_cqring_offsets,</span>
<span class="line" id="L3489">};</span>
<span class="line" id="L3490"></span>
<span class="line" id="L3491"><span class="tok-comment">// io_uring_params.features flags</span>
</span>
<span class="line" id="L3492"></span>
<span class="line" id="L3493"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IORING_FEAT_SINGLE_MMAP = <span class="tok-number">1</span> &lt;&lt; <span class="tok-number">0</span>;</span>
<span class="line" id="L3494"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IORING_FEAT_NODROP = <span class="tok-number">1</span> &lt;&lt; <span class="tok-number">1</span>;</span>
<span class="line" id="L3495"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IORING_FEAT_SUBMIT_STABLE = <span class="tok-number">1</span> &lt;&lt; <span class="tok-number">2</span>;</span>
<span class="line" id="L3496"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IORING_FEAT_RW_CUR_POS = <span class="tok-number">1</span> &lt;&lt; <span class="tok-number">3</span>;</span>
<span class="line" id="L3497"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IORING_FEAT_CUR_PERSONALITY = <span class="tok-number">1</span> &lt;&lt; <span class="tok-number">4</span>;</span>
<span class="line" id="L3498"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IORING_FEAT_FAST_POLL = <span class="tok-number">1</span> &lt;&lt; <span class="tok-number">5</span>;</span>
<span class="line" id="L3499"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IORING_FEAT_POLL_32BITS = <span class="tok-number">1</span> &lt;&lt; <span class="tok-number">6</span>;</span>
<span class="line" id="L3500"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IORING_FEAT_SQPOLL_NONFIXED = <span class="tok-number">1</span> &lt;&lt; <span class="tok-number">7</span>;</span>
<span class="line" id="L3501"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IORING_FEAT_EXT_ARG = <span class="tok-number">1</span> &lt;&lt; <span class="tok-number">8</span>;</span>
<span class="line" id="L3502"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IORING_FEAT_NATIVE_WORKERS = <span class="tok-number">1</span> &lt;&lt; <span class="tok-number">9</span>;</span>
<span class="line" id="L3503"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IORING_FEAT_RSRC_TAGS = <span class="tok-number">1</span> &lt;&lt; <span class="tok-number">10</span>;</span>
<span class="line" id="L3504"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IORING_FEAT_CQE_SKIP = <span class="tok-number">1</span> &lt;&lt; <span class="tok-number">11</span>;</span>
<span class="line" id="L3505"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IORING_FEAT_LINKED_FILE = <span class="tok-number">1</span> &lt;&lt; <span class="tok-number">12</span>;</span>
<span class="line" id="L3506"></span>
<span class="line" id="L3507"><span class="tok-comment">// io_uring_params.flags</span>
</span>
<span class="line" id="L3508"></span>
<span class="line" id="L3509"><span class="tok-comment">/// io_context is polled</span></span>
<span class="line" id="L3510"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IORING_SETUP_IOPOLL = <span class="tok-number">1</span> &lt;&lt; <span class="tok-number">0</span>;</span>
<span class="line" id="L3511"></span>
<span class="line" id="L3512"><span class="tok-comment">/// SQ poll thread</span></span>
<span class="line" id="L3513"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IORING_SETUP_SQPOLL = <span class="tok-number">1</span> &lt;&lt; <span class="tok-number">1</span>;</span>
<span class="line" id="L3514"></span>
<span class="line" id="L3515"><span class="tok-comment">/// sq_thread_cpu is valid</span></span>
<span class="line" id="L3516"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IORING_SETUP_SQ_AFF = <span class="tok-number">1</span> &lt;&lt; <span class="tok-number">2</span>;</span>
<span class="line" id="L3517"></span>
<span class="line" id="L3518"><span class="tok-comment">/// app defines CQ size</span></span>
<span class="line" id="L3519"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IORING_SETUP_CQSIZE = <span class="tok-number">1</span> &lt;&lt; <span class="tok-number">3</span>;</span>
<span class="line" id="L3520"></span>
<span class="line" id="L3521"><span class="tok-comment">/// clamp SQ/CQ ring sizes</span></span>
<span class="line" id="L3522"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IORING_SETUP_CLAMP = <span class="tok-number">1</span> &lt;&lt; <span class="tok-number">4</span>;</span>
<span class="line" id="L3523"></span>
<span class="line" id="L3524"><span class="tok-comment">/// attach to existing wq</span></span>
<span class="line" id="L3525"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IORING_SETUP_ATTACH_WQ = <span class="tok-number">1</span> &lt;&lt; <span class="tok-number">5</span>;</span>
<span class="line" id="L3526"></span>
<span class="line" id="L3527"><span class="tok-comment">/// start with ring disabled</span></span>
<span class="line" id="L3528"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IORING_SETUP_R_DISABLED = <span class="tok-number">1</span> &lt;&lt; <span class="tok-number">6</span>;</span>
<span class="line" id="L3529"></span>
<span class="line" id="L3530"><span class="tok-comment">/// continue submit on error</span></span>
<span class="line" id="L3531"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IORING_SETUP_SUBMIT_ALL = <span class="tok-number">1</span> &lt;&lt; <span class="tok-number">7</span>;</span>
<span class="line" id="L3532"></span>
<span class="line" id="L3533"><span class="tok-comment">/// Cooperative task running. When requests complete, they often require</span></span>
<span class="line" id="L3534"><span class="tok-comment">/// forcing the submitter to transition to the kernel to complete. If this</span></span>
<span class="line" id="L3535"><span class="tok-comment">/// flag is set, work will be done when the task transitions anyway, rather</span></span>
<span class="line" id="L3536"><span class="tok-comment">/// than force an inter-processor interrupt reschedule. This avoids interrupting</span></span>
<span class="line" id="L3537"><span class="tok-comment">/// a task running in userspace, and saves an IPI.</span></span>
<span class="line" id="L3538"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IORING_SETUP_COOP_TASKRUN = <span class="tok-number">1</span> &lt;&lt; <span class="tok-number">8</span>;</span>
<span class="line" id="L3539"></span>
<span class="line" id="L3540"><span class="tok-comment">/// If COOP_TASKRUN is set, get notified if task work is available for</span></span>
<span class="line" id="L3541"><span class="tok-comment">/// running and a kernel transition would be needed to run it. This sets</span></span>
<span class="line" id="L3542"><span class="tok-comment">/// IORING_SQ_TASKRUN in the sq ring flags. Not valid with COOP_TASKRUN.</span></span>
<span class="line" id="L3543"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IORING_SETUP_TASKRUN_FLAG = <span class="tok-number">1</span> &lt;&lt; <span class="tok-number">9</span>;</span>
<span class="line" id="L3544"></span>
<span class="line" id="L3545"><span class="tok-comment">/// SQEs are 128 byte</span></span>
<span class="line" id="L3546"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IORING_SETUP_SQE128 = <span class="tok-number">1</span> &lt;&lt; <span class="tok-number">10</span>;</span>
<span class="line" id="L3547"><span class="tok-comment">/// CQEs are 32 byte</span></span>
<span class="line" id="L3548"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IORING_SETUP_CQE32 = <span class="tok-number">1</span> &lt;&lt; <span class="tok-number">11</span>;</span>
<span class="line" id="L3549"></span>
<span class="line" id="L3550"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> io_sqring_offsets = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L3551">    <span class="tok-comment">/// offset of ring head</span></span>
<span class="line" id="L3552">    head: <span class="tok-type">u32</span>,</span>
<span class="line" id="L3553"></span>
<span class="line" id="L3554">    <span class="tok-comment">/// offset of ring tail</span></span>
<span class="line" id="L3555">    tail: <span class="tok-type">u32</span>,</span>
<span class="line" id="L3556"></span>
<span class="line" id="L3557">    <span class="tok-comment">/// ring mask value</span></span>
<span class="line" id="L3558">    ring_mask: <span class="tok-type">u32</span>,</span>
<span class="line" id="L3559"></span>
<span class="line" id="L3560">    <span class="tok-comment">/// entries in ring</span></span>
<span class="line" id="L3561">    ring_entries: <span class="tok-type">u32</span>,</span>
<span class="line" id="L3562"></span>
<span class="line" id="L3563">    <span class="tok-comment">/// ring flags</span></span>
<span class="line" id="L3564">    flags: <span class="tok-type">u32</span>,</span>
<span class="line" id="L3565"></span>
<span class="line" id="L3566">    <span class="tok-comment">/// number of sqes not submitted</span></span>
<span class="line" id="L3567">    dropped: <span class="tok-type">u32</span>,</span>
<span class="line" id="L3568"></span>
<span class="line" id="L3569">    <span class="tok-comment">/// sqe index array</span></span>
<span class="line" id="L3570">    array: <span class="tok-type">u32</span>,</span>
<span class="line" id="L3571"></span>
<span class="line" id="L3572">    resv1: <span class="tok-type">u32</span>,</span>
<span class="line" id="L3573">    resv2: <span class="tok-type">u64</span>,</span>
<span class="line" id="L3574">};</span>
<span class="line" id="L3575"></span>
<span class="line" id="L3576"><span class="tok-comment">// io_sqring_offsets.flags</span>
</span>
<span class="line" id="L3577"></span>
<span class="line" id="L3578"><span class="tok-comment">/// needs io_uring_enter wakeup</span></span>
<span class="line" id="L3579"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IORING_SQ_NEED_WAKEUP = <span class="tok-number">1</span> &lt;&lt; <span class="tok-number">0</span>;</span>
<span class="line" id="L3580"><span class="tok-comment">/// kernel has cqes waiting beyond the cq ring</span></span>
<span class="line" id="L3581"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IORING_SQ_CQ_OVERFLOW = <span class="tok-number">1</span> &lt;&lt; <span class="tok-number">1</span>;</span>
<span class="line" id="L3582"><span class="tok-comment">/// task should enter the kernel</span></span>
<span class="line" id="L3583"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IORING_SQ_TASKRUN = <span class="tok-number">1</span> &lt;&lt; <span class="tok-number">2</span>;</span>
<span class="line" id="L3584"></span>
<span class="line" id="L3585"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> io_cqring_offsets = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L3586">    head: <span class="tok-type">u32</span>,</span>
<span class="line" id="L3587">    tail: <span class="tok-type">u32</span>,</span>
<span class="line" id="L3588">    ring_mask: <span class="tok-type">u32</span>,</span>
<span class="line" id="L3589">    ring_entries: <span class="tok-type">u32</span>,</span>
<span class="line" id="L3590">    overflow: <span class="tok-type">u32</span>,</span>
<span class="line" id="L3591">    cqes: <span class="tok-type">u32</span>,</span>
<span class="line" id="L3592">    resv: [<span class="tok-number">2</span>]<span class="tok-type">u64</span>,</span>
<span class="line" id="L3593">};</span>
<span class="line" id="L3594"></span>
<span class="line" id="L3595"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> io_uring_sqe = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L3596">    opcode: IORING_OP,</span>
<span class="line" id="L3597">    flags: <span class="tok-type">u8</span>,</span>
<span class="line" id="L3598">    ioprio: <span class="tok-type">u16</span>,</span>
<span class="line" id="L3599">    fd: <span class="tok-type">i32</span>,</span>
<span class="line" id="L3600">    off: <span class="tok-type">u64</span>,</span>
<span class="line" id="L3601">    addr: <span class="tok-type">u64</span>,</span>
<span class="line" id="L3602">    len: <span class="tok-type">u32</span>,</span>
<span class="line" id="L3603">    rw_flags: <span class="tok-type">u32</span>,</span>
<span class="line" id="L3604">    user_data: <span class="tok-type">u64</span>,</span>
<span class="line" id="L3605">    buf_index: <span class="tok-type">u16</span>,</span>
<span class="line" id="L3606">    personality: <span class="tok-type">u16</span>,</span>
<span class="line" id="L3607">    splice_fd_in: <span class="tok-type">i32</span>,</span>
<span class="line" id="L3608">    __pad2: [<span class="tok-number">2</span>]<span class="tok-type">u64</span>,</span>
<span class="line" id="L3609">};</span>
<span class="line" id="L3610"></span>
<span class="line" id="L3611"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IOSQE_BIT = <span class="tok-kw">enum</span>(<span class="tok-type">u8</span>) {</span>
<span class="line" id="L3612">    FIXED_FILE,</span>
<span class="line" id="L3613">    IO_DRAIN,</span>
<span class="line" id="L3614">    IO_LINK,</span>
<span class="line" id="L3615">    IO_HARDLINK,</span>
<span class="line" id="L3616">    ASYNC,</span>
<span class="line" id="L3617">    BUFFER_SELECT,</span>
<span class="line" id="L3618">    CQE_SKIP_SUCCESS,</span>
<span class="line" id="L3619"></span>
<span class="line" id="L3620">    _,</span>
<span class="line" id="L3621">};</span>
<span class="line" id="L3622"></span>
<span class="line" id="L3623"><span class="tok-comment">// io_uring_sqe.flags</span>
</span>
<span class="line" id="L3624"></span>
<span class="line" id="L3625"><span class="tok-comment">/// use fixed fileset</span></span>
<span class="line" id="L3626"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IOSQE_FIXED_FILE = <span class="tok-number">1</span> &lt;&lt; <span class="tok-builtin">@enumToInt</span>(IOSQE_BIT.FIXED_FILE);</span>
<span class="line" id="L3627"></span>
<span class="line" id="L3628"><span class="tok-comment">/// issue after inflight IO</span></span>
<span class="line" id="L3629"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IOSQE_IO_DRAIN = <span class="tok-number">1</span> &lt;&lt; <span class="tok-builtin">@enumToInt</span>(IOSQE_BIT.IO_DRAIN);</span>
<span class="line" id="L3630"></span>
<span class="line" id="L3631"><span class="tok-comment">/// links next sqe</span></span>
<span class="line" id="L3632"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IOSQE_IO_LINK = <span class="tok-number">1</span> &lt;&lt; <span class="tok-builtin">@enumToInt</span>(IOSQE_BIT.IO_LINK);</span>
<span class="line" id="L3633"></span>
<span class="line" id="L3634"><span class="tok-comment">/// like LINK, but stronger</span></span>
<span class="line" id="L3635"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IOSQE_IO_HARDLINK = <span class="tok-number">1</span> &lt;&lt; <span class="tok-builtin">@enumToInt</span>(IOSQE_BIT.IO_HARDLINK);</span>
<span class="line" id="L3636"></span>
<span class="line" id="L3637"><span class="tok-comment">/// always go async</span></span>
<span class="line" id="L3638"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IOSQE_ASYNC = <span class="tok-number">1</span> &lt;&lt; <span class="tok-builtin">@enumToInt</span>(IOSQE_BIT.ASYNC);</span>
<span class="line" id="L3639"></span>
<span class="line" id="L3640"><span class="tok-comment">/// select buffer from buf_group</span></span>
<span class="line" id="L3641"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IOSQE_BUFFER_SELECT = <span class="tok-number">1</span> &lt;&lt; <span class="tok-builtin">@enumToInt</span>(IOSQE_BIT.BUFFER_SELECT);</span>
<span class="line" id="L3642"></span>
<span class="line" id="L3643"><span class="tok-comment">/// don't post CQE if request succeeded</span></span>
<span class="line" id="L3644"><span class="tok-comment">/// Available since Linux 5.17</span></span>
<span class="line" id="L3645"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IOSQE_CQE_SKIP_SUCCESS = <span class="tok-number">1</span> &lt;&lt; <span class="tok-builtin">@enumToInt</span>(IOSQE_BIT.CQE_SKIP_SUCCESS);</span>
<span class="line" id="L3646"></span>
<span class="line" id="L3647"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IORING_OP = <span class="tok-kw">enum</span>(<span class="tok-type">u8</span>) {</span>
<span class="line" id="L3648">    NOP,</span>
<span class="line" id="L3649">    READV,</span>
<span class="line" id="L3650">    WRITEV,</span>
<span class="line" id="L3651">    FSYNC,</span>
<span class="line" id="L3652">    READ_FIXED,</span>
<span class="line" id="L3653">    WRITE_FIXED,</span>
<span class="line" id="L3654">    POLL_ADD,</span>
<span class="line" id="L3655">    POLL_REMOVE,</span>
<span class="line" id="L3656">    SYNC_FILE_RANGE,</span>
<span class="line" id="L3657">    SENDMSG,</span>
<span class="line" id="L3658">    RECVMSG,</span>
<span class="line" id="L3659">    TIMEOUT,</span>
<span class="line" id="L3660">    TIMEOUT_REMOVE,</span>
<span class="line" id="L3661">    ACCEPT,</span>
<span class="line" id="L3662">    ASYNC_CANCEL,</span>
<span class="line" id="L3663">    LINK_TIMEOUT,</span>
<span class="line" id="L3664">    CONNECT,</span>
<span class="line" id="L3665">    FALLOCATE,</span>
<span class="line" id="L3666">    OPENAT,</span>
<span class="line" id="L3667">    CLOSE,</span>
<span class="line" id="L3668">    FILES_UPDATE,</span>
<span class="line" id="L3669">    STATX,</span>
<span class="line" id="L3670">    READ,</span>
<span class="line" id="L3671">    WRITE,</span>
<span class="line" id="L3672">    FADVISE,</span>
<span class="line" id="L3673">    MADVISE,</span>
<span class="line" id="L3674">    SEND,</span>
<span class="line" id="L3675">    RECV,</span>
<span class="line" id="L3676">    OPENAT2,</span>
<span class="line" id="L3677">    EPOLL_CTL,</span>
<span class="line" id="L3678">    SPLICE,</span>
<span class="line" id="L3679">    PROVIDE_BUFFERS,</span>
<span class="line" id="L3680">    REMOVE_BUFFERS,</span>
<span class="line" id="L3681">    TEE,</span>
<span class="line" id="L3682">    SHUTDOWN,</span>
<span class="line" id="L3683">    RENAMEAT,</span>
<span class="line" id="L3684">    UNLINKAT,</span>
<span class="line" id="L3685">    MKDIRAT,</span>
<span class="line" id="L3686">    SYMLINKAT,</span>
<span class="line" id="L3687">    LINKAT,</span>
<span class="line" id="L3688"></span>
<span class="line" id="L3689">    _,</span>
<span class="line" id="L3690">};</span>
<span class="line" id="L3691"></span>
<span class="line" id="L3692"><span class="tok-comment">// io_uring_sqe.fsync_flags (rw_flags in the Zig struct)</span>
</span>
<span class="line" id="L3693"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IORING_FSYNC_DATASYNC = <span class="tok-number">1</span> &lt;&lt; <span class="tok-number">0</span>;</span>
<span class="line" id="L3694"></span>
<span class="line" id="L3695"><span class="tok-comment">// io_uring_sqe.timeout_flags (rw_flags in the Zig struct)</span>
</span>
<span class="line" id="L3696"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IORING_TIMEOUT_ABS = <span class="tok-number">1</span> &lt;&lt; <span class="tok-number">0</span>;</span>
<span class="line" id="L3697"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IORING_TIMEOUT_UPDATE = <span class="tok-number">1</span> &lt;&lt; <span class="tok-number">1</span>; <span class="tok-comment">// Available since Linux 5.11</span>
</span>
<span class="line" id="L3698"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IORING_TIMEOUT_BOOTTIME = <span class="tok-number">1</span> &lt;&lt; <span class="tok-number">2</span>; <span class="tok-comment">// Available since Linux 5.15</span>
</span>
<span class="line" id="L3699"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IORING_TIMEOUT_REALTIME = <span class="tok-number">1</span> &lt;&lt; <span class="tok-number">3</span>; <span class="tok-comment">// Available since Linux 5.15</span>
</span>
<span class="line" id="L3700"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IORING_LINK_TIMEOUT_UPDATE = <span class="tok-number">1</span> &lt;&lt; <span class="tok-number">4</span>; <span class="tok-comment">// Available since Linux 5.15</span>
</span>
<span class="line" id="L3701"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IORING_TIMEOUT_ETIME_SUCCESS = <span class="tok-number">1</span> &lt;&lt; <span class="tok-number">5</span>; <span class="tok-comment">// Available since Linux 5.16</span>
</span>
<span class="line" id="L3702"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IORING_TIMEOUT_CLOCK_MASK = IORING_TIMEOUT_BOOTTIME | IORING_TIMEOUT_REALTIME;</span>
<span class="line" id="L3703"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IORING_TIMEOUT_UPDATE_MASK = IORING_TIMEOUT_UPDATE | IORING_LINK_TIMEOUT_UPDATE;</span>
<span class="line" id="L3704"></span>
<span class="line" id="L3705"><span class="tok-comment">// io_uring_sqe.splice_flags (rw_flags in the Zig struct)</span>
</span>
<span class="line" id="L3706"><span class="tok-comment">// extends splice(2) flags</span>
</span>
<span class="line" id="L3707"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IORING_SPLICE_F_FD_IN_FIXED = <span class="tok-number">1</span> &lt;&lt; <span class="tok-number">31</span>;</span>
<span class="line" id="L3708"></span>
<span class="line" id="L3709"><span class="tok-comment">// POLL_ADD flags.</span>
</span>
<span class="line" id="L3710"><span class="tok-comment">// Note that since sqe-&gt;poll_events (rw_flags in the Zig struct) is the flag space, the command flags for POLL_ADD are stored in sqe-&gt;len.</span>
</span>
<span class="line" id="L3711"></span>
<span class="line" id="L3712"><span class="tok-comment">/// Multishot poll. Sets IORING_CQE_F_MORE if the poll handler will continue to report CQEs on behalf of the same SQE.</span></span>
<span class="line" id="L3713"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IORING_POLL_ADD_MULTI = <span class="tok-number">1</span> &lt;&lt; <span class="tok-number">0</span>;</span>
<span class="line" id="L3714"><span class="tok-comment">/// Update existing poll request, matching sqe-&gt;addr as the old user_data field.</span></span>
<span class="line" id="L3715"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IORING_POLL_UPDATE_EVENTS = <span class="tok-number">1</span> &lt;&lt; <span class="tok-number">1</span>;</span>
<span class="line" id="L3716"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IORING_POLL_UPDATE_USER_DATA = <span class="tok-number">1</span> &lt;&lt; <span class="tok-number">2</span>;</span>
<span class="line" id="L3717"></span>
<span class="line" id="L3718"><span class="tok-comment">// ASYNC_CANCEL flags.</span>
</span>
<span class="line" id="L3719"></span>
<span class="line" id="L3720"><span class="tok-comment">/// Cancel all requests that match the given key</span></span>
<span class="line" id="L3721"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IORING_ASYNC_CANCEL_ALL = <span class="tok-number">1</span> &lt;&lt; <span class="tok-number">0</span>;</span>
<span class="line" id="L3722"><span class="tok-comment">/// Key off 'fd' for cancelation rather than the request 'user_data'.</span></span>
<span class="line" id="L3723"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IORING_ASYNC_CANCEL_FD = <span class="tok-number">1</span> &lt;&lt; <span class="tok-number">1</span>;</span>
<span class="line" id="L3724"><span class="tok-comment">/// Match any request</span></span>
<span class="line" id="L3725"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IORING_ASYNC_CANCEL_ANY = <span class="tok-number">1</span> &lt;&lt; <span class="tok-number">2</span>;</span>
<span class="line" id="L3726"></span>
<span class="line" id="L3727"><span class="tok-comment">// send/sendmsg and recv/recvmsg flags (sqe-&gt;ioprio)</span>
</span>
<span class="line" id="L3728"></span>
<span class="line" id="L3729"><span class="tok-comment">/// If set, instead of first attempting to send or receive and arm poll if that yields an -EAGAIN result,</span></span>
<span class="line" id="L3730"><span class="tok-comment">/// arm poll upfront and skip the initial transfer attempt.</span></span>
<span class="line" id="L3731"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IORING_RECVSEND_POLL_FIRST = <span class="tok-number">1</span> &lt;&lt; <span class="tok-number">0</span>;</span>
<span class="line" id="L3732"><span class="tok-comment">/// Multishot recv. Sets IORING_CQE_F_MORE if the handler will continue to report CQEs on behalf of the same SQE.</span></span>
<span class="line" id="L3733"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IORING_RECV_MULTISHOT = <span class="tok-number">1</span> &lt;&lt; <span class="tok-number">1</span>;</span>
<span class="line" id="L3734"></span>
<span class="line" id="L3735"><span class="tok-comment">/// accept flags stored in sqe-&gt;ioprio</span></span>
<span class="line" id="L3736"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IORING_ACCEPT_MULTISHOT = <span class="tok-number">1</span> &lt;&lt; <span class="tok-number">0</span>;</span>
<span class="line" id="L3737"></span>
<span class="line" id="L3738"><span class="tok-comment">// IO completion data structure (Completion Queue Entry)</span>
</span>
<span class="line" id="L3739"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> io_uring_cqe = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L3740">    <span class="tok-comment">/// io_uring_sqe.data submission passed back</span></span>
<span class="line" id="L3741">    user_data: <span class="tok-type">u64</span>,</span>
<span class="line" id="L3742"></span>
<span class="line" id="L3743">    <span class="tok-comment">/// result code for this event</span></span>
<span class="line" id="L3744">    res: <span class="tok-type">i32</span>,</span>
<span class="line" id="L3745">    flags: <span class="tok-type">u32</span>,</span>
<span class="line" id="L3746"></span>
<span class="line" id="L3747">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">err</span>(self: io_uring_cqe) E {</span>
<span class="line" id="L3748">        <span class="tok-kw">if</span> (self.res &gt; -<span class="tok-number">4096</span> <span class="tok-kw">and</span> self.res &lt; <span class="tok-number">0</span>) {</span>
<span class="line" id="L3749">            <span class="tok-kw">return</span> <span class="tok-builtin">@intToEnum</span>(E, -self.res);</span>
<span class="line" id="L3750">        }</span>
<span class="line" id="L3751">        <span class="tok-kw">return</span> .SUCCESS;</span>
<span class="line" id="L3752">    }</span>
<span class="line" id="L3753">};</span>
<span class="line" id="L3754"></span>
<span class="line" id="L3755"><span class="tok-comment">// io_uring_cqe.flags</span>
</span>
<span class="line" id="L3756"></span>
<span class="line" id="L3757"><span class="tok-comment">/// If set, the upper 16 bits are the buffer ID</span></span>
<span class="line" id="L3758"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IORING_CQE_F_BUFFER = <span class="tok-number">1</span> &lt;&lt; <span class="tok-number">0</span>;</span>
<span class="line" id="L3759"><span class="tok-comment">/// If set, parent SQE will generate more CQE entries.</span></span>
<span class="line" id="L3760"><span class="tok-comment">/// Avaiable since Linux 5.13.</span></span>
<span class="line" id="L3761"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IORING_CQE_F_MORE = <span class="tok-number">1</span> &lt;&lt; <span class="tok-number">1</span>;</span>
<span class="line" id="L3762"><span class="tok-comment">/// If set, more data to read after socket recv</span></span>
<span class="line" id="L3763"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IORING_CQE_F_SOCK_NONEMPTY = <span class="tok-number">1</span> &lt;&lt; <span class="tok-number">2</span>;</span>
<span class="line" id="L3764"></span>
<span class="line" id="L3765"><span class="tok-comment">/// Magic offsets for the application to mmap the data it needs</span></span>
<span class="line" id="L3766"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IORING_OFF_SQ_RING = <span class="tok-number">0</span>;</span>
<span class="line" id="L3767"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IORING_OFF_CQ_RING = <span class="tok-number">0x8000000</span>;</span>
<span class="line" id="L3768"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IORING_OFF_SQES = <span class="tok-number">0x10000000</span>;</span>
<span class="line" id="L3769"></span>
<span class="line" id="L3770"><span class="tok-comment">// io_uring_enter flags</span>
</span>
<span class="line" id="L3771"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IORING_ENTER_GETEVENTS = <span class="tok-number">1</span> &lt;&lt; <span class="tok-number">0</span>;</span>
<span class="line" id="L3772"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IORING_ENTER_SQ_WAKEUP = <span class="tok-number">1</span> &lt;&lt; <span class="tok-number">1</span>;</span>
<span class="line" id="L3773"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IORING_ENTER_SQ_WAIT = <span class="tok-number">1</span> &lt;&lt; <span class="tok-number">2</span>;</span>
<span class="line" id="L3774"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IORING_ENTER_EXT_ARG = <span class="tok-number">1</span> &lt;&lt; <span class="tok-number">3</span>;</span>
<span class="line" id="L3775"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IORING_ENTER_REGISTERED_RING = <span class="tok-number">1</span> &lt;&lt; <span class="tok-number">4</span>;</span>
<span class="line" id="L3776"></span>
<span class="line" id="L3777"><span class="tok-comment">// io_uring_register opcodes and arguments</span>
</span>
<span class="line" id="L3778"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IORING_REGISTER = <span class="tok-kw">enum</span>(<span class="tok-type">u8</span>) {</span>
<span class="line" id="L3779">    REGISTER_BUFFERS,</span>
<span class="line" id="L3780">    UNREGISTER_BUFFERS,</span>
<span class="line" id="L3781">    REGISTER_FILES,</span>
<span class="line" id="L3782">    UNREGISTER_FILES,</span>
<span class="line" id="L3783">    REGISTER_EVENTFD,</span>
<span class="line" id="L3784">    UNREGISTER_EVENTFD,</span>
<span class="line" id="L3785">    REGISTER_FILES_UPDATE,</span>
<span class="line" id="L3786">    REGISTER_EVENTFD_ASYNC,</span>
<span class="line" id="L3787">    REGISTER_PROBE,</span>
<span class="line" id="L3788">    REGISTER_PERSONALITY,</span>
<span class="line" id="L3789">    UNREGISTER_PERSONALITY,</span>
<span class="line" id="L3790">    REGISTER_RESTRICTIONS,</span>
<span class="line" id="L3791">    REGISTER_ENABLE_RINGS,</span>
<span class="line" id="L3792"></span>
<span class="line" id="L3793">    <span class="tok-comment">// extended with tagging</span>
</span>
<span class="line" id="L3794">    IORING_REGISTER_FILES2,</span>
<span class="line" id="L3795">    IORING_REGISTER_FILES_UPDATE2,</span>
<span class="line" id="L3796">    IORING_REGISTER_BUFFERS2,</span>
<span class="line" id="L3797">    IORING_REGISTER_BUFFERS_UPDATE,</span>
<span class="line" id="L3798"></span>
<span class="line" id="L3799">    <span class="tok-comment">// set/clear io-wq thread affinities</span>
</span>
<span class="line" id="L3800">    IORING_REGISTER_IOWQ_AFF,</span>
<span class="line" id="L3801">    IORING_UNREGISTER_IOWQ_AFF,</span>
<span class="line" id="L3802"></span>
<span class="line" id="L3803">    <span class="tok-comment">// set/get max number of io-wq workers</span>
</span>
<span class="line" id="L3804">    IORING_REGISTER_IOWQ_MAX_WORKERS,</span>
<span class="line" id="L3805"></span>
<span class="line" id="L3806">    <span class="tok-comment">// register/unregister io_uring fd with the ring</span>
</span>
<span class="line" id="L3807">    IORING_REGISTER_RING_FDS,</span>
<span class="line" id="L3808">    IORING_UNREGISTER_RING_FDS,</span>
<span class="line" id="L3809"></span>
<span class="line" id="L3810">    <span class="tok-comment">// register ring based provide buffer group</span>
</span>
<span class="line" id="L3811">    IORING_REGISTER_PBUF_RING,</span>
<span class="line" id="L3812">    IORING_UNREGISTER_PBUF_RING,</span>
<span class="line" id="L3813"></span>
<span class="line" id="L3814">    <span class="tok-comment">// sync cancelation API</span>
</span>
<span class="line" id="L3815">    IORING_REGISTER_SYNC_CANCEL,</span>
<span class="line" id="L3816"></span>
<span class="line" id="L3817">    <span class="tok-comment">// register a range of fixed file slots for automatic slot allocation</span>
</span>
<span class="line" id="L3818">    IORING_REGISTER_FILE_ALLOC_RANGE,</span>
<span class="line" id="L3819"></span>
<span class="line" id="L3820">    _,</span>
<span class="line" id="L3821">};</span>
<span class="line" id="L3822"></span>
<span class="line" id="L3823"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> io_uring_files_update = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L3824">    offset: <span class="tok-type">u32</span>,</span>
<span class="line" id="L3825">    resv: <span class="tok-type">u32</span>,</span>
<span class="line" id="L3826">    fds: <span class="tok-type">u64</span>,</span>
<span class="line" id="L3827">};</span>
<span class="line" id="L3828"></span>
<span class="line" id="L3829"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IO_URING_OP_SUPPORTED = <span class="tok-number">1</span> &lt;&lt; <span class="tok-number">0</span>;</span>
<span class="line" id="L3830"></span>
<span class="line" id="L3831"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> io_uring_probe_op = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L3832">    op: IORING_OP,</span>
<span class="line" id="L3833"></span>
<span class="line" id="L3834">    resv: <span class="tok-type">u8</span>,</span>
<span class="line" id="L3835"></span>
<span class="line" id="L3836">    <span class="tok-comment">/// IO_URING_OP_* flags</span></span>
<span class="line" id="L3837">    flags: <span class="tok-type">u16</span>,</span>
<span class="line" id="L3838"></span>
<span class="line" id="L3839">    resv2: <span class="tok-type">u32</span>,</span>
<span class="line" id="L3840">};</span>
<span class="line" id="L3841"></span>
<span class="line" id="L3842"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> io_uring_probe = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L3843">    <span class="tok-comment">/// last opcode supported</span></span>
<span class="line" id="L3844">    last_op: IORING_OP,</span>
<span class="line" id="L3845"></span>
<span class="line" id="L3846">    <span class="tok-comment">/// Number of io_uring_probe_op following</span></span>
<span class="line" id="L3847">    ops_len: <span class="tok-type">u8</span>,</span>
<span class="line" id="L3848"></span>
<span class="line" id="L3849">    resv: <span class="tok-type">u16</span>,</span>
<span class="line" id="L3850">    resv2: <span class="tok-type">u32</span>[<span class="tok-number">3</span>],</span>
<span class="line" id="L3851"></span>
<span class="line" id="L3852">    <span class="tok-comment">// Followed by up to `ops_len` io_uring_probe_op structures</span>
</span>
<span class="line" id="L3853">};</span>
<span class="line" id="L3854"></span>
<span class="line" id="L3855"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> io_uring_restriction = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L3856">    opcode: <span class="tok-type">u16</span>,</span>
<span class="line" id="L3857">    arg: <span class="tok-kw">extern</span> <span class="tok-kw">union</span> {</span>
<span class="line" id="L3858">        <span class="tok-comment">/// IORING_RESTRICTION_REGISTER_OP</span></span>
<span class="line" id="L3859">        register_op: IORING_REGISTER,</span>
<span class="line" id="L3860"></span>
<span class="line" id="L3861">        <span class="tok-comment">/// IORING_RESTRICTION_SQE_OP</span></span>
<span class="line" id="L3862">        sqe_op: IORING_OP,</span>
<span class="line" id="L3863"></span>
<span class="line" id="L3864">        <span class="tok-comment">/// IORING_RESTRICTION_SQE_FLAGS_*</span></span>
<span class="line" id="L3865">        sqe_flags: <span class="tok-type">u8</span>,</span>
<span class="line" id="L3866">    },</span>
<span class="line" id="L3867">    resv: <span class="tok-type">u8</span>,</span>
<span class="line" id="L3868">    resv2: <span class="tok-type">u32</span>[<span class="tok-number">3</span>],</span>
<span class="line" id="L3869">};</span>
<span class="line" id="L3870"></span>
<span class="line" id="L3871"><span class="tok-comment">/// io_uring_restriction-&gt;opcode values</span></span>
<span class="line" id="L3872"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IORING_RESTRICTION = <span class="tok-kw">enum</span>(<span class="tok-type">u8</span>) {</span>
<span class="line" id="L3873">    <span class="tok-comment">/// Allow an io_uring_register(2) opcode</span></span>
<span class="line" id="L3874">    REGISTER_OP = <span class="tok-number">0</span>,</span>
<span class="line" id="L3875"></span>
<span class="line" id="L3876">    <span class="tok-comment">/// Allow an sqe opcode</span></span>
<span class="line" id="L3877">    SQE_OP = <span class="tok-number">1</span>,</span>
<span class="line" id="L3878"></span>
<span class="line" id="L3879">    <span class="tok-comment">/// Allow sqe flags</span></span>
<span class="line" id="L3880">    SQE_FLAGS_ALLOWED = <span class="tok-number">2</span>,</span>
<span class="line" id="L3881"></span>
<span class="line" id="L3882">    <span class="tok-comment">/// Require sqe flags (these flags must be set on each submission)</span></span>
<span class="line" id="L3883">    SQE_FLAGS_REQUIRED = <span class="tok-number">3</span>,</span>
<span class="line" id="L3884"></span>
<span class="line" id="L3885">    _,</span>
<span class="line" id="L3886">};</span>
<span class="line" id="L3887"></span>
<span class="line" id="L3888"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> utsname = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L3889">    sysname: [<span class="tok-number">64</span>:<span class="tok-number">0</span>]<span class="tok-type">u8</span>,</span>
<span class="line" id="L3890">    nodename: [<span class="tok-number">64</span>:<span class="tok-number">0</span>]<span class="tok-type">u8</span>,</span>
<span class="line" id="L3891">    release: [<span class="tok-number">64</span>:<span class="tok-number">0</span>]<span class="tok-type">u8</span>,</span>
<span class="line" id="L3892">    version: [<span class="tok-number">64</span>:<span class="tok-number">0</span>]<span class="tok-type">u8</span>,</span>
<span class="line" id="L3893">    machine: [<span class="tok-number">64</span>:<span class="tok-number">0</span>]<span class="tok-type">u8</span>,</span>
<span class="line" id="L3894">    domainname: [<span class="tok-number">64</span>:<span class="tok-number">0</span>]<span class="tok-type">u8</span>,</span>
<span class="line" id="L3895">};</span>
<span class="line" id="L3896"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> HOST_NAME_MAX = <span class="tok-number">64</span>;</span>
<span class="line" id="L3897"></span>
<span class="line" id="L3898"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> STATX_TYPE = <span class="tok-number">0x0001</span>;</span>
<span class="line" id="L3899"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> STATX_MODE = <span class="tok-number">0x0002</span>;</span>
<span class="line" id="L3900"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> STATX_NLINK = <span class="tok-number">0x0004</span>;</span>
<span class="line" id="L3901"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> STATX_UID = <span class="tok-number">0x0008</span>;</span>
<span class="line" id="L3902"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> STATX_GID = <span class="tok-number">0x0010</span>;</span>
<span class="line" id="L3903"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> STATX_ATIME = <span class="tok-number">0x0020</span>;</span>
<span class="line" id="L3904"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> STATX_MTIME = <span class="tok-number">0x0040</span>;</span>
<span class="line" id="L3905"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> STATX_CTIME = <span class="tok-number">0x0080</span>;</span>
<span class="line" id="L3906"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> STATX_INO = <span class="tok-number">0x0100</span>;</span>
<span class="line" id="L3907"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> STATX_SIZE = <span class="tok-number">0x0200</span>;</span>
<span class="line" id="L3908"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> STATX_BLOCKS = <span class="tok-number">0x0400</span>;</span>
<span class="line" id="L3909"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> STATX_BASIC_STATS = <span class="tok-number">0x07ff</span>;</span>
<span class="line" id="L3910"></span>
<span class="line" id="L3911"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> STATX_BTIME = <span class="tok-number">0x0800</span>;</span>
<span class="line" id="L3912"></span>
<span class="line" id="L3913"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> STATX_ATTR_COMPRESSED = <span class="tok-number">0x0004</span>;</span>
<span class="line" id="L3914"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> STATX_ATTR_IMMUTABLE = <span class="tok-number">0x0010</span>;</span>
<span class="line" id="L3915"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> STATX_ATTR_APPEND = <span class="tok-number">0x0020</span>;</span>
<span class="line" id="L3916"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> STATX_ATTR_NODUMP = <span class="tok-number">0x0040</span>;</span>
<span class="line" id="L3917"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> STATX_ATTR_ENCRYPTED = <span class="tok-number">0x0800</span>;</span>
<span class="line" id="L3918"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> STATX_ATTR_AUTOMOUNT = <span class="tok-number">0x1000</span>;</span>
<span class="line" id="L3919"></span>
<span class="line" id="L3920"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> statx_timestamp = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L3921">    tv_sec: <span class="tok-type">i64</span>,</span>
<span class="line" id="L3922">    tv_nsec: <span class="tok-type">u32</span>,</span>
<span class="line" id="L3923">    __pad1: <span class="tok-type">u32</span>,</span>
<span class="line" id="L3924">};</span>
<span class="line" id="L3925"></span>
<span class="line" id="L3926"><span class="tok-comment">/// Renamed to `Statx` to not conflict with the `statx` function.</span></span>
<span class="line" id="L3927"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> Statx = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L3928">    <span class="tok-comment">/// Mask of bits indicating filled fields</span></span>
<span class="line" id="L3929">    mask: <span class="tok-type">u32</span>,</span>
<span class="line" id="L3930"></span>
<span class="line" id="L3931">    <span class="tok-comment">/// Block size for filesystem I/O</span></span>
<span class="line" id="L3932">    blksize: <span class="tok-type">u32</span>,</span>
<span class="line" id="L3933"></span>
<span class="line" id="L3934">    <span class="tok-comment">/// Extra file attribute indicators</span></span>
<span class="line" id="L3935">    attributes: <span class="tok-type">u64</span>,</span>
<span class="line" id="L3936"></span>
<span class="line" id="L3937">    <span class="tok-comment">/// Number of hard links</span></span>
<span class="line" id="L3938">    nlink: <span class="tok-type">u32</span>,</span>
<span class="line" id="L3939"></span>
<span class="line" id="L3940">    <span class="tok-comment">/// User ID of owner</span></span>
<span class="line" id="L3941">    uid: uid_t,</span>
<span class="line" id="L3942"></span>
<span class="line" id="L3943">    <span class="tok-comment">/// Group ID of owner</span></span>
<span class="line" id="L3944">    gid: gid_t,</span>
<span class="line" id="L3945"></span>
<span class="line" id="L3946">    <span class="tok-comment">/// File type and mode</span></span>
<span class="line" id="L3947">    mode: <span class="tok-type">u16</span>,</span>
<span class="line" id="L3948">    __pad1: <span class="tok-type">u16</span>,</span>
<span class="line" id="L3949"></span>
<span class="line" id="L3950">    <span class="tok-comment">/// Inode number</span></span>
<span class="line" id="L3951">    ino: <span class="tok-type">u64</span>,</span>
<span class="line" id="L3952"></span>
<span class="line" id="L3953">    <span class="tok-comment">/// Total size in bytes</span></span>
<span class="line" id="L3954">    size: <span class="tok-type">u64</span>,</span>
<span class="line" id="L3955"></span>
<span class="line" id="L3956">    <span class="tok-comment">/// Number of 512B blocks allocated</span></span>
<span class="line" id="L3957">    blocks: <span class="tok-type">u64</span>,</span>
<span class="line" id="L3958"></span>
<span class="line" id="L3959">    <span class="tok-comment">/// Mask to show what's supported in `attributes`.</span></span>
<span class="line" id="L3960">    attributes_mask: <span class="tok-type">u64</span>,</span>
<span class="line" id="L3961"></span>
<span class="line" id="L3962">    <span class="tok-comment">/// Last access file timestamp</span></span>
<span class="line" id="L3963">    atime: statx_timestamp,</span>
<span class="line" id="L3964"></span>
<span class="line" id="L3965">    <span class="tok-comment">/// Creation file timestamp</span></span>
<span class="line" id="L3966">    btime: statx_timestamp,</span>
<span class="line" id="L3967"></span>
<span class="line" id="L3968">    <span class="tok-comment">/// Last status change file timestamp</span></span>
<span class="line" id="L3969">    ctime: statx_timestamp,</span>
<span class="line" id="L3970"></span>
<span class="line" id="L3971">    <span class="tok-comment">/// Last modification file timestamp</span></span>
<span class="line" id="L3972">    mtime: statx_timestamp,</span>
<span class="line" id="L3973"></span>
<span class="line" id="L3974">    <span class="tok-comment">/// Major ID, if this file represents a device.</span></span>
<span class="line" id="L3975">    rdev_major: <span class="tok-type">u32</span>,</span>
<span class="line" id="L3976"></span>
<span class="line" id="L3977">    <span class="tok-comment">/// Minor ID, if this file represents a device.</span></span>
<span class="line" id="L3978">    rdev_minor: <span class="tok-type">u32</span>,</span>
<span class="line" id="L3979"></span>
<span class="line" id="L3980">    <span class="tok-comment">/// Major ID of the device containing the filesystem where this file resides.</span></span>
<span class="line" id="L3981">    dev_major: <span class="tok-type">u32</span>,</span>
<span class="line" id="L3982"></span>
<span class="line" id="L3983">    <span class="tok-comment">/// Minor ID of the device containing the filesystem where this file resides.</span></span>
<span class="line" id="L3984">    dev_minor: <span class="tok-type">u32</span>,</span>
<span class="line" id="L3985"></span>
<span class="line" id="L3986">    __pad2: [<span class="tok-number">14</span>]<span class="tok-type">u64</span>,</span>
<span class="line" id="L3987">};</span>
<span class="line" id="L3988"></span>
<span class="line" id="L3989"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> addrinfo = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L3990">    flags: <span class="tok-type">i32</span>,</span>
<span class="line" id="L3991">    family: <span class="tok-type">i32</span>,</span>
<span class="line" id="L3992">    socktype: <span class="tok-type">i32</span>,</span>
<span class="line" id="L3993">    protocol: <span class="tok-type">i32</span>,</span>
<span class="line" id="L3994">    addrlen: socklen_t,</span>
<span class="line" id="L3995">    addr: ?*sockaddr,</span>
<span class="line" id="L3996">    canonname: ?[*:<span class="tok-number">0</span>]<span class="tok-type">u8</span>,</span>
<span class="line" id="L3997">    next: ?*addrinfo,</span>
<span class="line" id="L3998">};</span>
<span class="line" id="L3999"></span>
<span class="line" id="L4000"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IPPORT_RESERVED = <span class="tok-number">1024</span>;</span>
<span class="line" id="L4001"></span>
<span class="line" id="L4002"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IPPROTO = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L4003">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> IP = <span class="tok-number">0</span>;</span>
<span class="line" id="L4004">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> HOPOPTS = <span class="tok-number">0</span>;</span>
<span class="line" id="L4005">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> ICMP = <span class="tok-number">1</span>;</span>
<span class="line" id="L4006">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> IGMP = <span class="tok-number">2</span>;</span>
<span class="line" id="L4007">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> IPIP = <span class="tok-number">4</span>;</span>
<span class="line" id="L4008">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> TCP = <span class="tok-number">6</span>;</span>
<span class="line" id="L4009">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> EGP = <span class="tok-number">8</span>;</span>
<span class="line" id="L4010">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> PUP = <span class="tok-number">12</span>;</span>
<span class="line" id="L4011">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> UDP = <span class="tok-number">17</span>;</span>
<span class="line" id="L4012">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> IDP = <span class="tok-number">22</span>;</span>
<span class="line" id="L4013">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> TP = <span class="tok-number">29</span>;</span>
<span class="line" id="L4014">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> DCCP = <span class="tok-number">33</span>;</span>
<span class="line" id="L4015">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> IPV6 = <span class="tok-number">41</span>;</span>
<span class="line" id="L4016">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> ROUTING = <span class="tok-number">43</span>;</span>
<span class="line" id="L4017">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> FRAGMENT = <span class="tok-number">44</span>;</span>
<span class="line" id="L4018">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> RSVP = <span class="tok-number">46</span>;</span>
<span class="line" id="L4019">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> GRE = <span class="tok-number">47</span>;</span>
<span class="line" id="L4020">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> ESP = <span class="tok-number">50</span>;</span>
<span class="line" id="L4021">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> AH = <span class="tok-number">51</span>;</span>
<span class="line" id="L4022">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> ICMPV6 = <span class="tok-number">58</span>;</span>
<span class="line" id="L4023">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> NONE = <span class="tok-number">59</span>;</span>
<span class="line" id="L4024">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> DSTOPTS = <span class="tok-number">60</span>;</span>
<span class="line" id="L4025">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> MTP = <span class="tok-number">92</span>;</span>
<span class="line" id="L4026">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> BEETPH = <span class="tok-number">94</span>;</span>
<span class="line" id="L4027">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> ENCAP = <span class="tok-number">98</span>;</span>
<span class="line" id="L4028">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> PIM = <span class="tok-number">103</span>;</span>
<span class="line" id="L4029">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> COMP = <span class="tok-number">108</span>;</span>
<span class="line" id="L4030">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> SCTP = <span class="tok-number">132</span>;</span>
<span class="line" id="L4031">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> MH = <span class="tok-number">135</span>;</span>
<span class="line" id="L4032">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> UDPLITE = <span class="tok-number">136</span>;</span>
<span class="line" id="L4033">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> MPLS = <span class="tok-number">137</span>;</span>
<span class="line" id="L4034">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> RAW = <span class="tok-number">255</span>;</span>
<span class="line" id="L4035">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> MAX = <span class="tok-number">256</span>;</span>
<span class="line" id="L4036">};</span>
<span class="line" id="L4037"></span>
<span class="line" id="L4038"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> RR = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L4039">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> A = <span class="tok-number">1</span>;</span>
<span class="line" id="L4040">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> CNAME = <span class="tok-number">5</span>;</span>
<span class="line" id="L4041">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> AAAA = <span class="tok-number">28</span>;</span>
<span class="line" id="L4042">};</span>
<span class="line" id="L4043"></span>
<span class="line" id="L4044"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> tcp_repair_opt = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L4045">    opt_code: <span class="tok-type">u32</span>,</span>
<span class="line" id="L4046">    opt_val: <span class="tok-type">u32</span>,</span>
<span class="line" id="L4047">};</span>
<span class="line" id="L4048"></span>
<span class="line" id="L4049"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> tcp_repair_window = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L4050">    snd_wl1: <span class="tok-type">u32</span>,</span>
<span class="line" id="L4051">    snd_wnd: <span class="tok-type">u32</span>,</span>
<span class="line" id="L4052">    max_window: <span class="tok-type">u32</span>,</span>
<span class="line" id="L4053">    rcv_wnd: <span class="tok-type">u32</span>,</span>
<span class="line" id="L4054">    rcv_wup: <span class="tok-type">u32</span>,</span>
<span class="line" id="L4055">};</span>
<span class="line" id="L4056"></span>
<span class="line" id="L4057"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> TcpRepairOption = <span class="tok-kw">enum</span> {</span>
<span class="line" id="L4058">    TCP_NO_QUEUE,</span>
<span class="line" id="L4059">    TCP_RECV_QUEUE,</span>
<span class="line" id="L4060">    TCP_SEND_QUEUE,</span>
<span class="line" id="L4061">    TCP_QUEUES_NR,</span>
<span class="line" id="L4062">};</span>
<span class="line" id="L4063"></span>
<span class="line" id="L4064"><span class="tok-comment">/// why fastopen failed from client perspective</span></span>
<span class="line" id="L4065"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> tcp_fastopen_client_fail = <span class="tok-kw">enum</span> {</span>
<span class="line" id="L4066">    <span class="tok-comment">/// catch-all</span></span>
<span class="line" id="L4067">    TFO_STATUS_UNSPEC,</span>
<span class="line" id="L4068">    <span class="tok-comment">/// if not in TFO_CLIENT_NO_COOKIE mode</span></span>
<span class="line" id="L4069">    TFO_COOKIE_UNAVAILABLE,</span>
<span class="line" id="L4070">    <span class="tok-comment">/// SYN-ACK did not ack SYN data</span></span>
<span class="line" id="L4071">    TFO_DATA_NOT_ACKED,</span>
<span class="line" id="L4072">    <span class="tok-comment">/// SYN-ACK did not ack SYN data after timeout</span></span>
<span class="line" id="L4073">    TFO_SYN_RETRANSMITTED,</span>
<span class="line" id="L4074">};</span>
<span class="line" id="L4075"></span>
<span class="line" id="L4076"><span class="tok-comment">/// for TCP_INFO socket option</span></span>
<span class="line" id="L4077"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> TCPI_OPT_TIMESTAMPS = <span class="tok-number">1</span>;</span>
<span class="line" id="L4078"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> TCPI_OPT_SACK = <span class="tok-number">2</span>;</span>
<span class="line" id="L4079"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> TCPI_OPT_WSCALE = <span class="tok-number">4</span>;</span>
<span class="line" id="L4080"><span class="tok-comment">/// ECN was negociated at TCP session init</span></span>
<span class="line" id="L4081"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> TCPI_OPT_ECN = <span class="tok-number">8</span>;</span>
<span class="line" id="L4082"><span class="tok-comment">/// we received at least one packet with ECT</span></span>
<span class="line" id="L4083"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> TCPI_OPT_ECN_SEEN = <span class="tok-number">16</span>;</span>
<span class="line" id="L4084"><span class="tok-comment">/// SYN-ACK acked data in SYN sent or rcvd</span></span>
<span class="line" id="L4085"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> TCPI_OPT_SYN_DATA = <span class="tok-number">32</span>;</span>
<span class="line" id="L4086"></span>
<span class="line" id="L4087"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> nfds_t = <span class="tok-type">usize</span>;</span>
<span class="line" id="L4088"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> pollfd = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L4089">    fd: fd_t,</span>
<span class="line" id="L4090">    events: <span class="tok-type">i16</span>,</span>
<span class="line" id="L4091">    revents: <span class="tok-type">i16</span>,</span>
<span class="line" id="L4092">};</span>
<span class="line" id="L4093"></span>
<span class="line" id="L4094"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> POLL = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L4095">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> IN = <span class="tok-number">0x001</span>;</span>
<span class="line" id="L4096">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> PRI = <span class="tok-number">0x002</span>;</span>
<span class="line" id="L4097">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> OUT = <span class="tok-number">0x004</span>;</span>
<span class="line" id="L4098">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> ERR = <span class="tok-number">0x008</span>;</span>
<span class="line" id="L4099">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> HUP = <span class="tok-number">0x010</span>;</span>
<span class="line" id="L4100">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> NVAL = <span class="tok-number">0x020</span>;</span>
<span class="line" id="L4101">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> RDNORM = <span class="tok-number">0x040</span>;</span>
<span class="line" id="L4102">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> RDBAND = <span class="tok-number">0x080</span>;</span>
<span class="line" id="L4103">};</span>
<span class="line" id="L4104"></span>
<span class="line" id="L4105"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> HUGETLB_FLAG_ENCODE_SHIFT = <span class="tok-number">26</span>;</span>
<span class="line" id="L4106"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> HUGETLB_FLAG_ENCODE_MASK = <span class="tok-number">0x3f</span>;</span>
<span class="line" id="L4107"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> HUGETLB_FLAG_ENCODE_64KB = <span class="tok-number">16</span> &lt;&lt; HUGETLB_FLAG_ENCODE_SHIFT;</span>
<span class="line" id="L4108"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> HUGETLB_FLAG_ENCODE_512KB = <span class="tok-number">19</span> &lt;&lt; HUGETLB_FLAG_ENCODE_SHIFT;</span>
<span class="line" id="L4109"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> HUGETLB_FLAG_ENCODE_1MB = <span class="tok-number">20</span> &lt;&lt; HUGETLB_FLAG_ENCODE_SHIFT;</span>
<span class="line" id="L4110"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> HUGETLB_FLAG_ENCODE_2MB = <span class="tok-number">21</span> &lt;&lt; HUGETLB_FLAG_ENCODE_SHIFT;</span>
<span class="line" id="L4111"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> HUGETLB_FLAG_ENCODE_8MB = <span class="tok-number">23</span> &lt;&lt; HUGETLB_FLAG_ENCODE_SHIFT;</span>
<span class="line" id="L4112"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> HUGETLB_FLAG_ENCODE_16MB = <span class="tok-number">24</span> &lt;&lt; HUGETLB_FLAG_ENCODE_SHIFT;</span>
<span class="line" id="L4113"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> HUGETLB_FLAG_ENCODE_32MB = <span class="tok-number">25</span> &lt;&lt; HUGETLB_FLAG_ENCODE_SHIFT;</span>
<span class="line" id="L4114"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> HUGETLB_FLAG_ENCODE_256MB = <span class="tok-number">28</span> &lt;&lt; HUGETLB_FLAG_ENCODE_SHIFT;</span>
<span class="line" id="L4115"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> HUGETLB_FLAG_ENCODE_512MB = <span class="tok-number">29</span> &lt;&lt; HUGETLB_FLAG_ENCODE_SHIFT;</span>
<span class="line" id="L4116"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> HUGETLB_FLAG_ENCODE_1GB = <span class="tok-number">30</span> &lt;&lt; HUGETLB_FLAG_ENCODE_SHIFT;</span>
<span class="line" id="L4117"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> HUGETLB_FLAG_ENCODE_2GB = <span class="tok-number">31</span> &lt;&lt; HUGETLB_FLAG_ENCODE_SHIFT;</span>
<span class="line" id="L4118"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> HUGETLB_FLAG_ENCODE_16GB = <span class="tok-number">34</span> &lt;&lt; HUGETLB_FLAG_ENCODE_SHIFT;</span>
<span class="line" id="L4119"></span>
<span class="line" id="L4120"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> MFD = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L4121">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> CLOEXEC = <span class="tok-number">0x0001</span>;</span>
<span class="line" id="L4122">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> ALLOW_SEALING = <span class="tok-number">0x0002</span>;</span>
<span class="line" id="L4123">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> HUGETLB = <span class="tok-number">0x0004</span>;</span>
<span class="line" id="L4124">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> ALL_FLAGS = CLOEXEC | ALLOW_SEALING | HUGETLB;</span>
<span class="line" id="L4125"></span>
<span class="line" id="L4126">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> HUGE_SHIFT = HUGETLB_FLAG_ENCODE_SHIFT;</span>
<span class="line" id="L4127">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> HUGE_MASK = HUGETLB_FLAG_ENCODE_MASK;</span>
<span class="line" id="L4128">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> HUGE_64KB = HUGETLB_FLAG_ENCODE_64KB;</span>
<span class="line" id="L4129">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> HUGE_512KB = HUGETLB_FLAG_ENCODE_512KB;</span>
<span class="line" id="L4130">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> HUGE_1MB = HUGETLB_FLAG_ENCODE_1MB;</span>
<span class="line" id="L4131">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> HUGE_2MB = HUGETLB_FLAG_ENCODE_2MB;</span>
<span class="line" id="L4132">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> HUGE_8MB = HUGETLB_FLAG_ENCODE_8MB;</span>
<span class="line" id="L4133">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> HUGE_16MB = HUGETLB_FLAG_ENCODE_16MB;</span>
<span class="line" id="L4134">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> HUGE_32MB = HUGETLB_FLAG_ENCODE_32MB;</span>
<span class="line" id="L4135">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> HUGE_256MB = HUGETLB_FLAG_ENCODE_256MB;</span>
<span class="line" id="L4136">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> HUGE_512MB = HUGETLB_FLAG_ENCODE_512MB;</span>
<span class="line" id="L4137">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> HUGE_1GB = HUGETLB_FLAG_ENCODE_1GB;</span>
<span class="line" id="L4138">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> HUGE_2GB = HUGETLB_FLAG_ENCODE_2GB;</span>
<span class="line" id="L4139">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> HUGE_16GB = HUGETLB_FLAG_ENCODE_16GB;</span>
<span class="line" id="L4140">};</span>
<span class="line" id="L4141"></span>
<span class="line" id="L4142"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> rusage = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L4143">    utime: timeval,</span>
<span class="line" id="L4144">    stime: timeval,</span>
<span class="line" id="L4145">    maxrss: <span class="tok-type">isize</span>,</span>
<span class="line" id="L4146">    ixrss: <span class="tok-type">isize</span>,</span>
<span class="line" id="L4147">    idrss: <span class="tok-type">isize</span>,</span>
<span class="line" id="L4148">    isrss: <span class="tok-type">isize</span>,</span>
<span class="line" id="L4149">    minflt: <span class="tok-type">isize</span>,</span>
<span class="line" id="L4150">    majflt: <span class="tok-type">isize</span>,</span>
<span class="line" id="L4151">    nswap: <span class="tok-type">isize</span>,</span>
<span class="line" id="L4152">    inblock: <span class="tok-type">isize</span>,</span>
<span class="line" id="L4153">    oublock: <span class="tok-type">isize</span>,</span>
<span class="line" id="L4154">    msgsnd: <span class="tok-type">isize</span>,</span>
<span class="line" id="L4155">    msgrcv: <span class="tok-type">isize</span>,</span>
<span class="line" id="L4156">    nsignals: <span class="tok-type">isize</span>,</span>
<span class="line" id="L4157">    nvcsw: <span class="tok-type">isize</span>,</span>
<span class="line" id="L4158">    nivcsw: <span class="tok-type">isize</span>,</span>
<span class="line" id="L4159">    __reserved: [<span class="tok-number">16</span>]<span class="tok-type">isize</span> = [<span class="tok-number">1</span>]<span class="tok-type">isize</span>{<span class="tok-number">0</span>} ** <span class="tok-number">16</span>,</span>
<span class="line" id="L4160"></span>
<span class="line" id="L4161">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> SELF = <span class="tok-number">0</span>;</span>
<span class="line" id="L4162">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> CHILDREN = -<span class="tok-number">1</span>;</span>
<span class="line" id="L4163">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> THREAD = <span class="tok-number">1</span>;</span>
<span class="line" id="L4164">};</span>
<span class="line" id="L4165"></span>
<span class="line" id="L4166"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> cc_t = <span class="tok-type">u8</span>;</span>
<span class="line" id="L4167"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> speed_t = <span class="tok-type">u32</span>;</span>
<span class="line" id="L4168"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> tcflag_t = <span class="tok-type">u32</span>;</span>
<span class="line" id="L4169"></span>
<span class="line" id="L4170"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> NCCS = <span class="tok-number">32</span>;</span>
<span class="line" id="L4171"></span>
<span class="line" id="L4172"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> B0 = <span class="tok-number">0o0000000</span>;</span>
<span class="line" id="L4173"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> B50 = <span class="tok-number">0o0000001</span>;</span>
<span class="line" id="L4174"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> B75 = <span class="tok-number">0o0000002</span>;</span>
<span class="line" id="L4175"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> B110 = <span class="tok-number">0o0000003</span>;</span>
<span class="line" id="L4176"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> B134 = <span class="tok-number">0o0000004</span>;</span>
<span class="line" id="L4177"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> B150 = <span class="tok-number">0o0000005</span>;</span>
<span class="line" id="L4178"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> B200 = <span class="tok-number">0o0000006</span>;</span>
<span class="line" id="L4179"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> B300 = <span class="tok-number">0o0000007</span>;</span>
<span class="line" id="L4180"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> B600 = <span class="tok-number">0o0000010</span>;</span>
<span class="line" id="L4181"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> B1200 = <span class="tok-number">0o0000011</span>;</span>
<span class="line" id="L4182"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> B1800 = <span class="tok-number">0o0000012</span>;</span>
<span class="line" id="L4183"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> B2400 = <span class="tok-number">0o0000013</span>;</span>
<span class="line" id="L4184"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> B4800 = <span class="tok-number">0o0000014</span>;</span>
<span class="line" id="L4185"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> B9600 = <span class="tok-number">0o0000015</span>;</span>
<span class="line" id="L4186"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> B19200 = <span class="tok-number">0o0000016</span>;</span>
<span class="line" id="L4187"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> B38400 = <span class="tok-number">0o0000017</span>;</span>
<span class="line" id="L4188"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> BOTHER = <span class="tok-number">0o0010000</span>;</span>
<span class="line" id="L4189"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> B57600 = <span class="tok-number">0o0010001</span>;</span>
<span class="line" id="L4190"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> B115200 = <span class="tok-number">0o0010002</span>;</span>
<span class="line" id="L4191"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> B230400 = <span class="tok-number">0o0010003</span>;</span>
<span class="line" id="L4192"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> B460800 = <span class="tok-number">0o0010004</span>;</span>
<span class="line" id="L4193"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> B500000 = <span class="tok-number">0o0010005</span>;</span>
<span class="line" id="L4194"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> B576000 = <span class="tok-number">0o0010006</span>;</span>
<span class="line" id="L4195"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> B921600 = <span class="tok-number">0o0010007</span>;</span>
<span class="line" id="L4196"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> B1000000 = <span class="tok-number">0o0010010</span>;</span>
<span class="line" id="L4197"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> B1152000 = <span class="tok-number">0o0010011</span>;</span>
<span class="line" id="L4198"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> B1500000 = <span class="tok-number">0o0010012</span>;</span>
<span class="line" id="L4199"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> B2000000 = <span class="tok-number">0o0010013</span>;</span>
<span class="line" id="L4200"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> B2500000 = <span class="tok-number">0o0010014</span>;</span>
<span class="line" id="L4201"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> B3000000 = <span class="tok-number">0o0010015</span>;</span>
<span class="line" id="L4202"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> B3500000 = <span class="tok-number">0o0010016</span>;</span>
<span class="line" id="L4203"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> B4000000 = <span class="tok-number">0o0010017</span>;</span>
<span class="line" id="L4204"></span>
<span class="line" id="L4205"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> V = <span class="tok-kw">switch</span> (native_arch) {</span>
<span class="line" id="L4206">    .powerpc, .powerpc64, .powerpc64le =&gt; <span class="tok-kw">struct</span> {</span>
<span class="line" id="L4207">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> INTR = <span class="tok-number">0</span>;</span>
<span class="line" id="L4208">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> QUIT = <span class="tok-number">1</span>;</span>
<span class="line" id="L4209">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> ERASE = <span class="tok-number">2</span>;</span>
<span class="line" id="L4210">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> KILL = <span class="tok-number">3</span>;</span>
<span class="line" id="L4211">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> EOF = <span class="tok-number">4</span>;</span>
<span class="line" id="L4212">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> MIN = <span class="tok-number">5</span>;</span>
<span class="line" id="L4213">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> EOL = <span class="tok-number">6</span>;</span>
<span class="line" id="L4214">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> TIME = <span class="tok-number">7</span>;</span>
<span class="line" id="L4215">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> EOL2 = <span class="tok-number">8</span>;</span>
<span class="line" id="L4216">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> SWTC = <span class="tok-number">9</span>;</span>
<span class="line" id="L4217">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> WERASE = <span class="tok-number">10</span>;</span>
<span class="line" id="L4218">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> REPRINT = <span class="tok-number">11</span>;</span>
<span class="line" id="L4219">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> SUSP = <span class="tok-number">12</span>;</span>
<span class="line" id="L4220">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> START = <span class="tok-number">13</span>;</span>
<span class="line" id="L4221">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> STOP = <span class="tok-number">14</span>;</span>
<span class="line" id="L4222">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> LNEXT = <span class="tok-number">15</span>;</span>
<span class="line" id="L4223">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> DISCARD = <span class="tok-number">16</span>;</span>
<span class="line" id="L4224">    },</span>
<span class="line" id="L4225">    .sparc, .sparc64 =&gt; <span class="tok-kw">struct</span> {</span>
<span class="line" id="L4226">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> INTR = <span class="tok-number">0</span>;</span>
<span class="line" id="L4227">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> QUIT = <span class="tok-number">1</span>;</span>
<span class="line" id="L4228">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> ERASE = <span class="tok-number">2</span>;</span>
<span class="line" id="L4229">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> KILL = <span class="tok-number">3</span>;</span>
<span class="line" id="L4230">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> EOF = <span class="tok-number">4</span>;</span>
<span class="line" id="L4231">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> EOL = <span class="tok-number">5</span>;</span>
<span class="line" id="L4232">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> EOL2 = <span class="tok-number">6</span>;</span>
<span class="line" id="L4233">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> SWTC = <span class="tok-number">7</span>;</span>
<span class="line" id="L4234">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> START = <span class="tok-number">8</span>;</span>
<span class="line" id="L4235">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> STOP = <span class="tok-number">9</span>;</span>
<span class="line" id="L4236">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> SUSP = <span class="tok-number">10</span>;</span>
<span class="line" id="L4237">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> DSUSP = <span class="tok-number">11</span>;</span>
<span class="line" id="L4238">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> REPRINT = <span class="tok-number">12</span>;</span>
<span class="line" id="L4239">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> DISCARD = <span class="tok-number">13</span>;</span>
<span class="line" id="L4240">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> WERASE = <span class="tok-number">14</span>;</span>
<span class="line" id="L4241">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> LNEXT = <span class="tok-number">15</span>;</span>
<span class="line" id="L4242">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> MIN = EOF;</span>
<span class="line" id="L4243">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> TIME = EOL;</span>
<span class="line" id="L4244">    },</span>
<span class="line" id="L4245">    .mips, .mipsel, .mips64, .mips64el =&gt; <span class="tok-kw">struct</span> {</span>
<span class="line" id="L4246">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> INTR = <span class="tok-number">0</span>;</span>
<span class="line" id="L4247">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> QUIT = <span class="tok-number">1</span>;</span>
<span class="line" id="L4248">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> ERASE = <span class="tok-number">2</span>;</span>
<span class="line" id="L4249">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> KILL = <span class="tok-number">3</span>;</span>
<span class="line" id="L4250">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> MIN = <span class="tok-number">4</span>;</span>
<span class="line" id="L4251">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> TIME = <span class="tok-number">5</span>;</span>
<span class="line" id="L4252">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> EOL2 = <span class="tok-number">6</span>;</span>
<span class="line" id="L4253">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> SWTC = <span class="tok-number">7</span>;</span>
<span class="line" id="L4254">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> SWTCH = <span class="tok-number">7</span>;</span>
<span class="line" id="L4255">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> START = <span class="tok-number">8</span>;</span>
<span class="line" id="L4256">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> STOP = <span class="tok-number">9</span>;</span>
<span class="line" id="L4257">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> SUSP = <span class="tok-number">10</span>;</span>
<span class="line" id="L4258">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> REPRINT = <span class="tok-number">12</span>;</span>
<span class="line" id="L4259">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> DISCARD = <span class="tok-number">13</span>;</span>
<span class="line" id="L4260">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> WERASE = <span class="tok-number">14</span>;</span>
<span class="line" id="L4261">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> LNEXT = <span class="tok-number">15</span>;</span>
<span class="line" id="L4262">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> EOF = <span class="tok-number">16</span>;</span>
<span class="line" id="L4263">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> EOL = <span class="tok-number">17</span>;</span>
<span class="line" id="L4264">    },</span>
<span class="line" id="L4265">    <span class="tok-kw">else</span> =&gt; <span class="tok-kw">struct</span> {</span>
<span class="line" id="L4266">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> INTR = <span class="tok-number">0</span>;</span>
<span class="line" id="L4267">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> QUIT = <span class="tok-number">1</span>;</span>
<span class="line" id="L4268">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> ERASE = <span class="tok-number">2</span>;</span>
<span class="line" id="L4269">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> KILL = <span class="tok-number">3</span>;</span>
<span class="line" id="L4270">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> EOF = <span class="tok-number">4</span>;</span>
<span class="line" id="L4271">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> TIME = <span class="tok-number">5</span>;</span>
<span class="line" id="L4272">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> MIN = <span class="tok-number">6</span>;</span>
<span class="line" id="L4273">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> SWTC = <span class="tok-number">7</span>;</span>
<span class="line" id="L4274">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> START = <span class="tok-number">8</span>;</span>
<span class="line" id="L4275">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> STOP = <span class="tok-number">9</span>;</span>
<span class="line" id="L4276">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> SUSP = <span class="tok-number">10</span>;</span>
<span class="line" id="L4277">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> EOL = <span class="tok-number">11</span>;</span>
<span class="line" id="L4278">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> REPRINT = <span class="tok-number">12</span>;</span>
<span class="line" id="L4279">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> DISCARD = <span class="tok-number">13</span>;</span>
<span class="line" id="L4280">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> WERASE = <span class="tok-number">14</span>;</span>
<span class="line" id="L4281">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> LNEXT = <span class="tok-number">15</span>;</span>
<span class="line" id="L4282">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> EOL2 = <span class="tok-number">16</span>;</span>
<span class="line" id="L4283">    },</span>
<span class="line" id="L4284">};</span>
<span class="line" id="L4285"></span>
<span class="line" id="L4286"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IGNBRK: tcflag_t = <span class="tok-number">1</span>;</span>
<span class="line" id="L4287"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> BRKINT: tcflag_t = <span class="tok-number">2</span>;</span>
<span class="line" id="L4288"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IGNPAR: tcflag_t = <span class="tok-number">4</span>;</span>
<span class="line" id="L4289"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> PARMRK: tcflag_t = <span class="tok-number">8</span>;</span>
<span class="line" id="L4290"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> INPCK: tcflag_t = <span class="tok-number">16</span>;</span>
<span class="line" id="L4291"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> ISTRIP: tcflag_t = <span class="tok-number">32</span>;</span>
<span class="line" id="L4292"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> INLCR: tcflag_t = <span class="tok-number">64</span>;</span>
<span class="line" id="L4293"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IGNCR: tcflag_t = <span class="tok-number">128</span>;</span>
<span class="line" id="L4294"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> ICRNL: tcflag_t = <span class="tok-number">256</span>;</span>
<span class="line" id="L4295"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IUCLC: tcflag_t = <span class="tok-number">512</span>;</span>
<span class="line" id="L4296"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IXON: tcflag_t = <span class="tok-number">1024</span>;</span>
<span class="line" id="L4297"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IXANY: tcflag_t = <span class="tok-number">2048</span>;</span>
<span class="line" id="L4298"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IXOFF: tcflag_t = <span class="tok-number">4096</span>;</span>
<span class="line" id="L4299"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IMAXBEL: tcflag_t = <span class="tok-number">8192</span>;</span>
<span class="line" id="L4300"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IUTF8: tcflag_t = <span class="tok-number">16384</span>;</span>
<span class="line" id="L4301"></span>
<span class="line" id="L4302"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> OPOST: tcflag_t = <span class="tok-number">1</span>;</span>
<span class="line" id="L4303"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> OLCUC: tcflag_t = <span class="tok-number">2</span>;</span>
<span class="line" id="L4304"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> ONLCR: tcflag_t = <span class="tok-number">4</span>;</span>
<span class="line" id="L4305"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> OCRNL: tcflag_t = <span class="tok-number">8</span>;</span>
<span class="line" id="L4306"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> ONOCR: tcflag_t = <span class="tok-number">16</span>;</span>
<span class="line" id="L4307"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> ONLRET: tcflag_t = <span class="tok-number">32</span>;</span>
<span class="line" id="L4308"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> OFILL: tcflag_t = <span class="tok-number">64</span>;</span>
<span class="line" id="L4309"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> OFDEL: tcflag_t = <span class="tok-number">128</span>;</span>
<span class="line" id="L4310"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> VTDLY: tcflag_t = <span class="tok-number">16384</span>;</span>
<span class="line" id="L4311"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> VT0: tcflag_t = <span class="tok-number">0</span>;</span>
<span class="line" id="L4312"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> VT1: tcflag_t = <span class="tok-number">16384</span>;</span>
<span class="line" id="L4313"></span>
<span class="line" id="L4314"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> CSIZE: tcflag_t = <span class="tok-number">48</span>;</span>
<span class="line" id="L4315"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> CS5: tcflag_t = <span class="tok-number">0</span>;</span>
<span class="line" id="L4316"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> CS6: tcflag_t = <span class="tok-number">16</span>;</span>
<span class="line" id="L4317"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> CS7: tcflag_t = <span class="tok-number">32</span>;</span>
<span class="line" id="L4318"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> CS8: tcflag_t = <span class="tok-number">48</span>;</span>
<span class="line" id="L4319"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> CSTOPB: tcflag_t = <span class="tok-number">64</span>;</span>
<span class="line" id="L4320"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> CREAD: tcflag_t = <span class="tok-number">128</span>;</span>
<span class="line" id="L4321"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> PARENB: tcflag_t = <span class="tok-number">256</span>;</span>
<span class="line" id="L4322"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> PARODD: tcflag_t = <span class="tok-number">512</span>;</span>
<span class="line" id="L4323"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> HUPCL: tcflag_t = <span class="tok-number">1024</span>;</span>
<span class="line" id="L4324"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> CLOCAL: tcflag_t = <span class="tok-number">2048</span>;</span>
<span class="line" id="L4325"></span>
<span class="line" id="L4326"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> ISIG: tcflag_t = <span class="tok-number">1</span>;</span>
<span class="line" id="L4327"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> ICANON: tcflag_t = <span class="tok-number">2</span>;</span>
<span class="line" id="L4328"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> ECHO: tcflag_t = <span class="tok-number">8</span>;</span>
<span class="line" id="L4329"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> ECHOE: tcflag_t = <span class="tok-number">16</span>;</span>
<span class="line" id="L4330"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> ECHOK: tcflag_t = <span class="tok-number">32</span>;</span>
<span class="line" id="L4331"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> ECHONL: tcflag_t = <span class="tok-number">64</span>;</span>
<span class="line" id="L4332"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> NOFLSH: tcflag_t = <span class="tok-number">128</span>;</span>
<span class="line" id="L4333"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> TOSTOP: tcflag_t = <span class="tok-number">256</span>;</span>
<span class="line" id="L4334"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IEXTEN: tcflag_t = <span class="tok-number">32768</span>;</span>
<span class="line" id="L4335"></span>
<span class="line" id="L4336"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> TCSA = <span class="tok-kw">enum</span>(<span class="tok-type">c_uint</span>) {</span>
<span class="line" id="L4337">    NOW,</span>
<span class="line" id="L4338">    DRAIN,</span>
<span class="line" id="L4339">    FLUSH,</span>
<span class="line" id="L4340">    _,</span>
<span class="line" id="L4341">};</span>
<span class="line" id="L4342"></span>
<span class="line" id="L4343"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> termios = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L4344">    iflag: tcflag_t,</span>
<span class="line" id="L4345">    oflag: tcflag_t,</span>
<span class="line" id="L4346">    cflag: tcflag_t,</span>
<span class="line" id="L4347">    lflag: tcflag_t,</span>
<span class="line" id="L4348">    line: cc_t,</span>
<span class="line" id="L4349">    cc: [NCCS]cc_t,</span>
<span class="line" id="L4350">    ispeed: speed_t,</span>
<span class="line" id="L4351">    ospeed: speed_t,</span>
<span class="line" id="L4352">};</span>
<span class="line" id="L4353"></span>
<span class="line" id="L4354"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SIOCGIFINDEX = <span class="tok-number">0x8933</span>;</span>
<span class="line" id="L4355"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IFNAMESIZE = <span class="tok-number">16</span>;</span>
<span class="line" id="L4356"></span>
<span class="line" id="L4357"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> ifmap = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L4358">    mem_start: <span class="tok-type">u32</span>,</span>
<span class="line" id="L4359">    mem_end: <span class="tok-type">u32</span>,</span>
<span class="line" id="L4360">    base_addr: <span class="tok-type">u16</span>,</span>
<span class="line" id="L4361">    irq: <span class="tok-type">u8</span>,</span>
<span class="line" id="L4362">    dma: <span class="tok-type">u8</span>,</span>
<span class="line" id="L4363">    port: <span class="tok-type">u8</span>,</span>
<span class="line" id="L4364">};</span>
<span class="line" id="L4365"></span>
<span class="line" id="L4366"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> ifreq = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L4367">    ifrn: <span class="tok-kw">extern</span> <span class="tok-kw">union</span> {</span>
<span class="line" id="L4368">        name: [IFNAMESIZE]<span class="tok-type">u8</span>,</span>
<span class="line" id="L4369">    },</span>
<span class="line" id="L4370">    ifru: <span class="tok-kw">extern</span> <span class="tok-kw">union</span> {</span>
<span class="line" id="L4371">        addr: sockaddr,</span>
<span class="line" id="L4372">        dstaddr: sockaddr,</span>
<span class="line" id="L4373">        broadaddr: sockaddr,</span>
<span class="line" id="L4374">        netmask: sockaddr,</span>
<span class="line" id="L4375">        hwaddr: sockaddr,</span>
<span class="line" id="L4376">        flags: <span class="tok-type">i16</span>,</span>
<span class="line" id="L4377">        ivalue: <span class="tok-type">i32</span>,</span>
<span class="line" id="L4378">        mtu: <span class="tok-type">i32</span>,</span>
<span class="line" id="L4379">        map: ifmap,</span>
<span class="line" id="L4380">        slave: [IFNAMESIZE - <span class="tok-number">1</span>:<span class="tok-number">0</span>]<span class="tok-type">u8</span>,</span>
<span class="line" id="L4381">        newname: [IFNAMESIZE - <span class="tok-number">1</span>:<span class="tok-number">0</span>]<span class="tok-type">u8</span>,</span>
<span class="line" id="L4382">        data: ?[*]<span class="tok-type">u8</span>,</span>
<span class="line" id="L4383">    },</span>
<span class="line" id="L4384">};</span>
<span class="line" id="L4385"></span>
<span class="line" id="L4386"><span class="tok-comment">// doc comments copied from musl</span>
</span>
<span class="line" id="L4387"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> rlimit_resource = <span class="tok-kw">if</span> (native_arch.isMIPS() <span class="tok-kw">or</span> native_arch.isSPARC())</span>
<span class="line" id="L4388">    arch_bits.rlimit_resource</span>
<span class="line" id="L4389"><span class="tok-kw">else</span></span>
<span class="line" id="L4390">    <span class="tok-kw">enum</span>(<span class="tok-type">c_int</span>) {</span>
<span class="line" id="L4391">        <span class="tok-comment">/// Per-process CPU limit, in seconds.</span></span>
<span class="line" id="L4392">        CPU,</span>
<span class="line" id="L4393"></span>
<span class="line" id="L4394">        <span class="tok-comment">/// Largest file that can be created, in bytes.</span></span>
<span class="line" id="L4395">        FSIZE,</span>
<span class="line" id="L4396"></span>
<span class="line" id="L4397">        <span class="tok-comment">/// Maximum size of data segment, in bytes.</span></span>
<span class="line" id="L4398">        DATA,</span>
<span class="line" id="L4399"></span>
<span class="line" id="L4400">        <span class="tok-comment">/// Maximum size of stack segment, in bytes.</span></span>
<span class="line" id="L4401">        STACK,</span>
<span class="line" id="L4402"></span>
<span class="line" id="L4403">        <span class="tok-comment">/// Largest core file that can be created, in bytes.</span></span>
<span class="line" id="L4404">        CORE,</span>
<span class="line" id="L4405"></span>
<span class="line" id="L4406">        <span class="tok-comment">/// Largest resident set size, in bytes.</span></span>
<span class="line" id="L4407">        <span class="tok-comment">/// This affects swapping; processes that are exceeding their</span></span>
<span class="line" id="L4408">        <span class="tok-comment">/// resident set size will be more likely to have physical memory</span></span>
<span class="line" id="L4409">        <span class="tok-comment">/// taken from them.</span></span>
<span class="line" id="L4410">        RSS,</span>
<span class="line" id="L4411"></span>
<span class="line" id="L4412">        <span class="tok-comment">/// Number of processes.</span></span>
<span class="line" id="L4413">        NPROC,</span>
<span class="line" id="L4414"></span>
<span class="line" id="L4415">        <span class="tok-comment">/// Number of open files.</span></span>
<span class="line" id="L4416">        NOFILE,</span>
<span class="line" id="L4417"></span>
<span class="line" id="L4418">        <span class="tok-comment">/// Locked-in-memory address space.</span></span>
<span class="line" id="L4419">        MEMLOCK,</span>
<span class="line" id="L4420"></span>
<span class="line" id="L4421">        <span class="tok-comment">/// Address space limit.</span></span>
<span class="line" id="L4422">        AS,</span>
<span class="line" id="L4423"></span>
<span class="line" id="L4424">        <span class="tok-comment">/// Maximum number of file locks.</span></span>
<span class="line" id="L4425">        LOCKS,</span>
<span class="line" id="L4426"></span>
<span class="line" id="L4427">        <span class="tok-comment">/// Maximum number of pending signals.</span></span>
<span class="line" id="L4428">        SIGPENDING,</span>
<span class="line" id="L4429"></span>
<span class="line" id="L4430">        <span class="tok-comment">/// Maximum bytes in POSIX message queues.</span></span>
<span class="line" id="L4431">        MSGQUEUE,</span>
<span class="line" id="L4432"></span>
<span class="line" id="L4433">        <span class="tok-comment">/// Maximum nice priority allowed to raise to.</span></span>
<span class="line" id="L4434">        <span class="tok-comment">/// Nice levels 19 .. -20 correspond to 0 .. 39</span></span>
<span class="line" id="L4435">        <span class="tok-comment">/// values of this resource limit.</span></span>
<span class="line" id="L4436">        NICE,</span>
<span class="line" id="L4437"></span>
<span class="line" id="L4438">        <span class="tok-comment">/// Maximum realtime priority allowed for non-priviledged</span></span>
<span class="line" id="L4439">        <span class="tok-comment">/// processes.</span></span>
<span class="line" id="L4440">        RTPRIO,</span>
<span class="line" id="L4441"></span>
<span class="line" id="L4442">        <span class="tok-comment">/// Maximum CPU time in µs that a process scheduled under a real-time</span></span>
<span class="line" id="L4443">        <span class="tok-comment">/// scheduling policy may consume without making a blocking system</span></span>
<span class="line" id="L4444">        <span class="tok-comment">/// call before being forcibly descheduled.</span></span>
<span class="line" id="L4445">        RTTIME,</span>
<span class="line" id="L4446"></span>
<span class="line" id="L4447">        _,</span>
<span class="line" id="L4448">    };</span>
<span class="line" id="L4449"></span>
<span class="line" id="L4450"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> rlim_t = <span class="tok-type">u64</span>;</span>
<span class="line" id="L4451"></span>
<span class="line" id="L4452"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> RLIM = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L4453">    <span class="tok-comment">/// No limit</span></span>
<span class="line" id="L4454">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> INFINITY = ~<span class="tok-builtin">@as</span>(rlim_t, <span class="tok-number">0</span>);</span>
<span class="line" id="L4455"></span>
<span class="line" id="L4456">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> SAVED_MAX = INFINITY;</span>
<span class="line" id="L4457">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> SAVED_CUR = INFINITY;</span>
<span class="line" id="L4458">};</span>
<span class="line" id="L4459"></span>
<span class="line" id="L4460"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> rlimit = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L4461">    <span class="tok-comment">/// Soft limit</span></span>
<span class="line" id="L4462">    cur: rlim_t,</span>
<span class="line" id="L4463">    <span class="tok-comment">/// Hard limit</span></span>
<span class="line" id="L4464">    max: rlim_t,</span>
<span class="line" id="L4465">};</span>
<span class="line" id="L4466"></span>
<span class="line" id="L4467"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> MADV = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L4468">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> NORMAL = <span class="tok-number">0</span>;</span>
<span class="line" id="L4469">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> RANDOM = <span class="tok-number">1</span>;</span>
<span class="line" id="L4470">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> SEQUENTIAL = <span class="tok-number">2</span>;</span>
<span class="line" id="L4471">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> WILLNEED = <span class="tok-number">3</span>;</span>
<span class="line" id="L4472">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> DONTNEED = <span class="tok-number">4</span>;</span>
<span class="line" id="L4473">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> FREE = <span class="tok-number">8</span>;</span>
<span class="line" id="L4474">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> REMOVE = <span class="tok-number">9</span>;</span>
<span class="line" id="L4475">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> DONTFORK = <span class="tok-number">10</span>;</span>
<span class="line" id="L4476">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> DOFORK = <span class="tok-number">11</span>;</span>
<span class="line" id="L4477">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> MERGEABLE = <span class="tok-number">12</span>;</span>
<span class="line" id="L4478">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> UNMERGEABLE = <span class="tok-number">13</span>;</span>
<span class="line" id="L4479">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> HUGEPAGE = <span class="tok-number">14</span>;</span>
<span class="line" id="L4480">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> NOHUGEPAGE = <span class="tok-number">15</span>;</span>
<span class="line" id="L4481">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> DONTDUMP = <span class="tok-number">16</span>;</span>
<span class="line" id="L4482">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> DODUMP = <span class="tok-number">17</span>;</span>
<span class="line" id="L4483">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> WIPEONFORK = <span class="tok-number">18</span>;</span>
<span class="line" id="L4484">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> KEEPONFORK = <span class="tok-number">19</span>;</span>
<span class="line" id="L4485">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> COLD = <span class="tok-number">20</span>;</span>
<span class="line" id="L4486">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> PAGEOUT = <span class="tok-number">21</span>;</span>
<span class="line" id="L4487">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> HWPOISON = <span class="tok-number">100</span>;</span>
<span class="line" id="L4488">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> SOFT_OFFLINE = <span class="tok-number">101</span>;</span>
<span class="line" id="L4489">};</span>
<span class="line" id="L4490"></span>
<span class="line" id="L4491"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> POSIX_FADV = <span class="tok-kw">switch</span> (native_arch) {</span>
<span class="line" id="L4492">    .s390x =&gt; <span class="tok-kw">if</span> (<span class="tok-builtin">@typeInfo</span>(<span class="tok-type">usize</span>).Int.bits == <span class="tok-number">64</span>) <span class="tok-kw">struct</span> {</span>
<span class="line" id="L4493">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> NORMAL = <span class="tok-number">0</span>;</span>
<span class="line" id="L4494">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> RANDOM = <span class="tok-number">1</span>;</span>
<span class="line" id="L4495">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> SEQUENTIAL = <span class="tok-number">2</span>;</span>
<span class="line" id="L4496">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> WILLNEED = <span class="tok-number">3</span>;</span>
<span class="line" id="L4497">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> DONTNEED = <span class="tok-number">6</span>;</span>
<span class="line" id="L4498">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> NOREUSE = <span class="tok-number">7</span>;</span>
<span class="line" id="L4499">    } <span class="tok-kw">else</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L4500">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> NORMAL = <span class="tok-number">0</span>;</span>
<span class="line" id="L4501">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> RANDOM = <span class="tok-number">1</span>;</span>
<span class="line" id="L4502">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> SEQUENTIAL = <span class="tok-number">2</span>;</span>
<span class="line" id="L4503">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> WILLNEED = <span class="tok-number">3</span>;</span>
<span class="line" id="L4504">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> DONTNEED = <span class="tok-number">4</span>;</span>
<span class="line" id="L4505">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> NOREUSE = <span class="tok-number">5</span>;</span>
<span class="line" id="L4506">    },</span>
<span class="line" id="L4507">    <span class="tok-kw">else</span> =&gt; <span class="tok-kw">struct</span> {</span>
<span class="line" id="L4508">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> NORMAL = <span class="tok-number">0</span>;</span>
<span class="line" id="L4509">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> RANDOM = <span class="tok-number">1</span>;</span>
<span class="line" id="L4510">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> SEQUENTIAL = <span class="tok-number">2</span>;</span>
<span class="line" id="L4511">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> WILLNEED = <span class="tok-number">3</span>;</span>
<span class="line" id="L4512">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> DONTNEED = <span class="tok-number">4</span>;</span>
<span class="line" id="L4513">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> NOREUSE = <span class="tok-number">5</span>;</span>
<span class="line" id="L4514">    },</span>
<span class="line" id="L4515">};</span>
<span class="line" id="L4516"></span>
<span class="line" id="L4517"><span class="tok-comment">/// The timespec struct used by the kernel.</span></span>
<span class="line" id="L4518"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> kernel_timespec = <span class="tok-kw">if</span> (<span class="tok-builtin">@sizeOf</span>(<span class="tok-type">usize</span>) &gt;= <span class="tok-number">8</span>) timespec <span class="tok-kw">else</span> <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L4519">    tv_sec: <span class="tok-type">i64</span>,</span>
<span class="line" id="L4520">    tv_nsec: <span class="tok-type">i64</span>,</span>
<span class="line" id="L4521">};</span>
<span class="line" id="L4522"></span>
<span class="line" id="L4523"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> timespec = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L4524">    tv_sec: <span class="tok-type">isize</span>,</span>
<span class="line" id="L4525">    tv_nsec: <span class="tok-type">isize</span>,</span>
<span class="line" id="L4526">};</span>
<span class="line" id="L4527"></span>
<span class="line" id="L4528"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> XDP = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L4529">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> SHARED_UMEM = (<span class="tok-number">1</span> &lt;&lt; <span class="tok-number">0</span>);</span>
<span class="line" id="L4530">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> COPY = (<span class="tok-number">1</span> &lt;&lt; <span class="tok-number">1</span>);</span>
<span class="line" id="L4531">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> ZEROCOPY = (<span class="tok-number">1</span> &lt;&lt; <span class="tok-number">2</span>);</span>
<span class="line" id="L4532">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> UMEM_UNALIGNED_CHUNK_FLAG = (<span class="tok-number">1</span> &lt;&lt; <span class="tok-number">0</span>);</span>
<span class="line" id="L4533">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> USE_NEED_WAKEUP = (<span class="tok-number">1</span> &lt;&lt; <span class="tok-number">3</span>);</span>
<span class="line" id="L4534"></span>
<span class="line" id="L4535">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> MMAP_OFFSETS = <span class="tok-number">1</span>;</span>
<span class="line" id="L4536">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> RX_RING = <span class="tok-number">2</span>;</span>
<span class="line" id="L4537">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> TX_RING = <span class="tok-number">3</span>;</span>
<span class="line" id="L4538">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> UMEM_REG = <span class="tok-number">4</span>;</span>
<span class="line" id="L4539">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> UMEM_FILL_RING = <span class="tok-number">5</span>;</span>
<span class="line" id="L4540">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> UMEM_COMPLETION_RING = <span class="tok-number">6</span>;</span>
<span class="line" id="L4541">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> STATISTICS = <span class="tok-number">7</span>;</span>
<span class="line" id="L4542">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> OPTIONS = <span class="tok-number">8</span>;</span>
<span class="line" id="L4543"></span>
<span class="line" id="L4544">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> OPTIONS_ZEROCOPY = (<span class="tok-number">1</span> &lt;&lt; <span class="tok-number">0</span>);</span>
<span class="line" id="L4545"></span>
<span class="line" id="L4546">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> PGOFF_RX_RING = <span class="tok-number">0</span>;</span>
<span class="line" id="L4547">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> PGOFF_TX_RING = <span class="tok-number">0x80000000</span>;</span>
<span class="line" id="L4548">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> UMEM_PGOFF_FILL_RING = <span class="tok-number">0x100000000</span>;</span>
<span class="line" id="L4549">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> UMEM_PGOFF_COMPLETION_RING = <span class="tok-number">0x180000000</span>;</span>
<span class="line" id="L4550">};</span>
<span class="line" id="L4551"></span>
<span class="line" id="L4552"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> xdp_ring_offset = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L4553">    producer: <span class="tok-type">u64</span>,</span>
<span class="line" id="L4554">    consumer: <span class="tok-type">u64</span>,</span>
<span class="line" id="L4555">    desc: <span class="tok-type">u64</span>,</span>
<span class="line" id="L4556">    flags: <span class="tok-type">u64</span>,</span>
<span class="line" id="L4557">};</span>
<span class="line" id="L4558"></span>
<span class="line" id="L4559"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> xdp_mmap_offsets = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L4560">    rx: xdp_ring_offset,</span>
<span class="line" id="L4561">    tx: xdp_ring_offset,</span>
<span class="line" id="L4562">    fr: xdp_ring_offset,</span>
<span class="line" id="L4563">    cr: xdp_ring_offset,</span>
<span class="line" id="L4564">};</span>
<span class="line" id="L4565"></span>
<span class="line" id="L4566"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> xdp_umem_reg = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L4567">    addr: <span class="tok-type">u64</span>,</span>
<span class="line" id="L4568">    len: <span class="tok-type">u64</span>,</span>
<span class="line" id="L4569">    chunk_size: <span class="tok-type">u32</span>,</span>
<span class="line" id="L4570">    headroom: <span class="tok-type">u32</span>,</span>
<span class="line" id="L4571">    flags: <span class="tok-type">u32</span>,</span>
<span class="line" id="L4572">};</span>
<span class="line" id="L4573"></span>
<span class="line" id="L4574"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> xdp_statistics = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L4575">    rx_dropped: <span class="tok-type">u64</span>,</span>
<span class="line" id="L4576">    rx_invalid_descs: <span class="tok-type">u64</span>,</span>
<span class="line" id="L4577">    tx_invalid_descs: <span class="tok-type">u64</span>,</span>
<span class="line" id="L4578">    rx_ring_full: <span class="tok-type">u64</span>,</span>
<span class="line" id="L4579">    rx_fill_ring_empty_descs: <span class="tok-type">u64</span>,</span>
<span class="line" id="L4580">    tx_ring_empty_descs: <span class="tok-type">u64</span>,</span>
<span class="line" id="L4581">};</span>
<span class="line" id="L4582"></span>
<span class="line" id="L4583"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> xdp_options = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L4584">    flags: <span class="tok-type">u32</span>,</span>
<span class="line" id="L4585">};</span>
<span class="line" id="L4586"></span>
<span class="line" id="L4587"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> XSK_UNALIGNED_BUF_OFFSET_SHIFT = <span class="tok-number">48</span>;</span>
<span class="line" id="L4588"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> XSK_UNALIGNED_BUF_ADDR_MASK = (<span class="tok-number">1</span> &lt;&lt; XSK_UNALIGNED_BUF_OFFSET_SHIFT) - <span class="tok-number">1</span>;</span>
<span class="line" id="L4589"></span>
<span class="line" id="L4590"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> xdp_desc = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L4591">    addr: <span class="tok-type">u64</span>,</span>
<span class="line" id="L4592">    len: <span class="tok-type">u32</span>,</span>
<span class="line" id="L4593">    options: <span class="tok-type">u32</span>,</span>
<span class="line" id="L4594">};</span>
<span class="line" id="L4595"></span>
<span class="line" id="L4596"><span class="tok-kw">fn</span> <span class="tok-fn">issecure_mask</span>(<span class="tok-kw">comptime</span> x: <span class="tok-type">comptime_int</span>) <span class="tok-type">comptime_int</span> {</span>
<span class="line" id="L4597">    <span class="tok-kw">return</span> <span class="tok-number">1</span> &lt;&lt; x;</span>
<span class="line" id="L4598">}</span>
<span class="line" id="L4599"></span>
<span class="line" id="L4600"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SECUREBITS_DEFAULT = <span class="tok-number">0x00000000</span>;</span>
<span class="line" id="L4601"></span>
<span class="line" id="L4602"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SECURE_NOROOT = <span class="tok-number">0</span>;</span>
<span class="line" id="L4603"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SECURE_NOROOT_LOCKED = <span class="tok-number">1</span>;</span>
<span class="line" id="L4604"></span>
<span class="line" id="L4605"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SECBIT_NOROOT = issecure_mask(SECURE_NOROOT);</span>
<span class="line" id="L4606"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SECBIT_NOROOT_LOCKED = issecure_mask(SECURE_NOROOT_LOCKED);</span>
<span class="line" id="L4607"></span>
<span class="line" id="L4608"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SECURE_NO_SETUID_FIXUP = <span class="tok-number">2</span>;</span>
<span class="line" id="L4609"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SECURE_NO_SETUID_FIXUP_LOCKED = <span class="tok-number">3</span>;</span>
<span class="line" id="L4610"></span>
<span class="line" id="L4611"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SECBIT_NO_SETUID_FIXUP = issecure_mask(SECURE_NO_SETUID_FIXUP);</span>
<span class="line" id="L4612"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SECBIT_NO_SETUID_FIXUP_LOCKED = issecure_mask(SECURE_NO_SETUID_FIXUP_LOCKED);</span>
<span class="line" id="L4613"></span>
<span class="line" id="L4614"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SECURE_KEEP_CAPS = <span class="tok-number">4</span>;</span>
<span class="line" id="L4615"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SECURE_KEEP_CAPS_LOCKED = <span class="tok-number">5</span>;</span>
<span class="line" id="L4616"></span>
<span class="line" id="L4617"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SECBIT_KEEP_CAPS = issecure_mask(SECURE_KEEP_CAPS);</span>
<span class="line" id="L4618"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SECBIT_KEEP_CAPS_LOCKED = issecure_mask(SECURE_KEEP_CAPS_LOCKED);</span>
<span class="line" id="L4619"></span>
<span class="line" id="L4620"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SECURE_NO_CAP_AMBIENT_RAISE = <span class="tok-number">6</span>;</span>
<span class="line" id="L4621"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SECURE_NO_CAP_AMBIENT_RAISE_LOCKED = <span class="tok-number">7</span>;</span>
<span class="line" id="L4622"></span>
<span class="line" id="L4623"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SECBIT_NO_CAP_AMBIENT_RAISE = issecure_mask(SECURE_NO_CAP_AMBIENT_RAISE);</span>
<span class="line" id="L4624"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SECBIT_NO_CAP_AMBIENT_RAISE_LOCKED = issecure_mask(SECURE_NO_CAP_AMBIENT_RAISE_LOCKED);</span>
<span class="line" id="L4625"></span>
<span class="line" id="L4626"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SECURE_ALL_BITS = issecure_mask(SECURE_NOROOT) |</span>
<span class="line" id="L4627">    issecure_mask(SECURE_NO_SETUID_FIXUP) |</span>
<span class="line" id="L4628">    issecure_mask(SECURE_KEEP_CAPS) |</span>
<span class="line" id="L4629">    issecure_mask(SECURE_NO_CAP_AMBIENT_RAISE);</span>
<span class="line" id="L4630"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SECURE_ALL_LOCKS = SECURE_ALL_BITS &lt;&lt; <span class="tok-number">1</span>;</span>
<span class="line" id="L4631"></span>
<span class="line" id="L4632"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> PR = <span class="tok-kw">enum</span>(<span class="tok-type">i32</span>) {</span>
<span class="line" id="L4633">    SET_PDEATHSIG = <span class="tok-number">1</span>,</span>
<span class="line" id="L4634">    GET_PDEATHSIG = <span class="tok-number">2</span>,</span>
<span class="line" id="L4635"></span>
<span class="line" id="L4636">    GET_DUMPABLE = <span class="tok-number">3</span>,</span>
<span class="line" id="L4637">    SET_DUMPABLE = <span class="tok-number">4</span>,</span>
<span class="line" id="L4638"></span>
<span class="line" id="L4639">    GET_UNALIGN = <span class="tok-number">5</span>,</span>
<span class="line" id="L4640">    SET_UNALIGN = <span class="tok-number">6</span>,</span>
<span class="line" id="L4641"></span>
<span class="line" id="L4642">    GET_KEEPCAPS = <span class="tok-number">7</span>,</span>
<span class="line" id="L4643">    SET_KEEPCAPS = <span class="tok-number">8</span>,</span>
<span class="line" id="L4644"></span>
<span class="line" id="L4645">    GET_FPEMU = <span class="tok-number">9</span>,</span>
<span class="line" id="L4646">    SET_FPEMU = <span class="tok-number">10</span>,</span>
<span class="line" id="L4647"></span>
<span class="line" id="L4648">    GET_FPEXC = <span class="tok-number">11</span>,</span>
<span class="line" id="L4649">    SET_FPEXC = <span class="tok-number">12</span>,</span>
<span class="line" id="L4650"></span>
<span class="line" id="L4651">    GET_TIMING = <span class="tok-number">13</span>,</span>
<span class="line" id="L4652">    SET_TIMING = <span class="tok-number">14</span>,</span>
<span class="line" id="L4653"></span>
<span class="line" id="L4654">    SET_NAME = <span class="tok-number">15</span>,</span>
<span class="line" id="L4655">    GET_NAME = <span class="tok-number">16</span>,</span>
<span class="line" id="L4656"></span>
<span class="line" id="L4657">    GET_ENDIAN = <span class="tok-number">19</span>,</span>
<span class="line" id="L4658">    SET_ENDIAN = <span class="tok-number">20</span>,</span>
<span class="line" id="L4659"></span>
<span class="line" id="L4660">    GET_SECCOMP = <span class="tok-number">21</span>,</span>
<span class="line" id="L4661">    SET_SECCOMP = <span class="tok-number">22</span>,</span>
<span class="line" id="L4662"></span>
<span class="line" id="L4663">    CAPBSET_READ = <span class="tok-number">23</span>,</span>
<span class="line" id="L4664">    CAPBSET_DROP = <span class="tok-number">24</span>,</span>
<span class="line" id="L4665"></span>
<span class="line" id="L4666">    GET_TSC = <span class="tok-number">25</span>,</span>
<span class="line" id="L4667">    SET_TSC = <span class="tok-number">26</span>,</span>
<span class="line" id="L4668"></span>
<span class="line" id="L4669">    GET_SECUREBITS = <span class="tok-number">27</span>,</span>
<span class="line" id="L4670">    SET_SECUREBITS = <span class="tok-number">28</span>,</span>
<span class="line" id="L4671"></span>
<span class="line" id="L4672">    SET_TIMERSLACK = <span class="tok-number">29</span>,</span>
<span class="line" id="L4673">    GET_TIMERSLACK = <span class="tok-number">30</span>,</span>
<span class="line" id="L4674"></span>
<span class="line" id="L4675">    TASK_PERF_EVENTS_DISABLE = <span class="tok-number">31</span>,</span>
<span class="line" id="L4676">    TASK_PERF_EVENTS_ENABLE = <span class="tok-number">32</span>,</span>
<span class="line" id="L4677"></span>
<span class="line" id="L4678">    MCE_KILL = <span class="tok-number">33</span>,</span>
<span class="line" id="L4679"></span>
<span class="line" id="L4680">    MCE_KILL_GET = <span class="tok-number">34</span>,</span>
<span class="line" id="L4681"></span>
<span class="line" id="L4682">    SET_MM = <span class="tok-number">35</span>,</span>
<span class="line" id="L4683"></span>
<span class="line" id="L4684">    SET_PTRACER = <span class="tok-number">0x59616d61</span>,</span>
<span class="line" id="L4685"></span>
<span class="line" id="L4686">    SET_CHILD_SUBREAPER = <span class="tok-number">36</span>,</span>
<span class="line" id="L4687">    GET_CHILD_SUBREAPER = <span class="tok-number">37</span>,</span>
<span class="line" id="L4688"></span>
<span class="line" id="L4689">    SET_NO_NEW_PRIVS = <span class="tok-number">38</span>,</span>
<span class="line" id="L4690">    GET_NO_NEW_PRIVS = <span class="tok-number">39</span>,</span>
<span class="line" id="L4691"></span>
<span class="line" id="L4692">    GET_TID_ADDRESS = <span class="tok-number">40</span>,</span>
<span class="line" id="L4693"></span>
<span class="line" id="L4694">    SET_THP_DISABLE = <span class="tok-number">41</span>,</span>
<span class="line" id="L4695">    GET_THP_DISABLE = <span class="tok-number">42</span>,</span>
<span class="line" id="L4696"></span>
<span class="line" id="L4697">    MPX_ENABLE_MANAGEMENT = <span class="tok-number">43</span>,</span>
<span class="line" id="L4698">    MPX_DISABLE_MANAGEMENT = <span class="tok-number">44</span>,</span>
<span class="line" id="L4699"></span>
<span class="line" id="L4700">    SET_FP_MODE = <span class="tok-number">45</span>,</span>
<span class="line" id="L4701">    GET_FP_MODE = <span class="tok-number">46</span>,</span>
<span class="line" id="L4702"></span>
<span class="line" id="L4703">    CAP_AMBIENT = <span class="tok-number">47</span>,</span>
<span class="line" id="L4704"></span>
<span class="line" id="L4705">    SVE_SET_VL = <span class="tok-number">50</span>,</span>
<span class="line" id="L4706">    SVE_GET_VL = <span class="tok-number">51</span>,</span>
<span class="line" id="L4707"></span>
<span class="line" id="L4708">    GET_SPECULATION_CTRL = <span class="tok-number">52</span>,</span>
<span class="line" id="L4709">    SET_SPECULATION_CTRL = <span class="tok-number">53</span>,</span>
<span class="line" id="L4710"></span>
<span class="line" id="L4711">    _,</span>
<span class="line" id="L4712"></span>
<span class="line" id="L4713">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> UNALIGN_NOPRINT = <span class="tok-number">1</span>;</span>
<span class="line" id="L4714">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> UNALIGN_SIGBUS = <span class="tok-number">2</span>;</span>
<span class="line" id="L4715"></span>
<span class="line" id="L4716">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> FPEMU_NOPRINT = <span class="tok-number">1</span>;</span>
<span class="line" id="L4717">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> FPEMU_SIGFPE = <span class="tok-number">2</span>;</span>
<span class="line" id="L4718"></span>
<span class="line" id="L4719">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> FP_EXC_SW_ENABLE = <span class="tok-number">0x80</span>;</span>
<span class="line" id="L4720">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> FP_EXC_DIV = <span class="tok-number">0x010000</span>;</span>
<span class="line" id="L4721">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> FP_EXC_OVF = <span class="tok-number">0x020000</span>;</span>
<span class="line" id="L4722">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> FP_EXC_UND = <span class="tok-number">0x040000</span>;</span>
<span class="line" id="L4723">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> FP_EXC_RES = <span class="tok-number">0x080000</span>;</span>
<span class="line" id="L4724">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> FP_EXC_INV = <span class="tok-number">0x100000</span>;</span>
<span class="line" id="L4725">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> FP_EXC_DISABLED = <span class="tok-number">0</span>;</span>
<span class="line" id="L4726">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> FP_EXC_NONRECOV = <span class="tok-number">1</span>;</span>
<span class="line" id="L4727">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> FP_EXC_ASYNC = <span class="tok-number">2</span>;</span>
<span class="line" id="L4728">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> FP_EXC_PRECISE = <span class="tok-number">3</span>;</span>
<span class="line" id="L4729"></span>
<span class="line" id="L4730">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> TIMING_STATISTICAL = <span class="tok-number">0</span>;</span>
<span class="line" id="L4731">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> TIMING_TIMESTAMP = <span class="tok-number">1</span>;</span>
<span class="line" id="L4732"></span>
<span class="line" id="L4733">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> ENDIAN_BIG = <span class="tok-number">0</span>;</span>
<span class="line" id="L4734">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> ENDIAN_LITTLE = <span class="tok-number">1</span>;</span>
<span class="line" id="L4735">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> ENDIAN_PPC_LITTLE = <span class="tok-number">2</span>;</span>
<span class="line" id="L4736"></span>
<span class="line" id="L4737">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> TSC_ENABLE = <span class="tok-number">1</span>;</span>
<span class="line" id="L4738">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> TSC_SIGSEGV = <span class="tok-number">2</span>;</span>
<span class="line" id="L4739"></span>
<span class="line" id="L4740">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> MCE_KILL_CLEAR = <span class="tok-number">0</span>;</span>
<span class="line" id="L4741">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> MCE_KILL_SET = <span class="tok-number">1</span>;</span>
<span class="line" id="L4742"></span>
<span class="line" id="L4743">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> MCE_KILL_LATE = <span class="tok-number">0</span>;</span>
<span class="line" id="L4744">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> MCE_KILL_EARLY = <span class="tok-number">1</span>;</span>
<span class="line" id="L4745">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> MCE_KILL_DEFAULT = <span class="tok-number">2</span>;</span>
<span class="line" id="L4746"></span>
<span class="line" id="L4747">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> SET_MM_START_CODE = <span class="tok-number">1</span>;</span>
<span class="line" id="L4748">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> SET_MM_END_CODE = <span class="tok-number">2</span>;</span>
<span class="line" id="L4749">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> SET_MM_START_DATA = <span class="tok-number">3</span>;</span>
<span class="line" id="L4750">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> SET_MM_END_DATA = <span class="tok-number">4</span>;</span>
<span class="line" id="L4751">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> SET_MM_START_STACK = <span class="tok-number">5</span>;</span>
<span class="line" id="L4752">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> SET_MM_START_BRK = <span class="tok-number">6</span>;</span>
<span class="line" id="L4753">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> SET_MM_BRK = <span class="tok-number">7</span>;</span>
<span class="line" id="L4754">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> SET_MM_ARG_START = <span class="tok-number">8</span>;</span>
<span class="line" id="L4755">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> SET_MM_ARG_END = <span class="tok-number">9</span>;</span>
<span class="line" id="L4756">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> SET_MM_ENV_START = <span class="tok-number">10</span>;</span>
<span class="line" id="L4757">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> SET_MM_ENV_END = <span class="tok-number">11</span>;</span>
<span class="line" id="L4758">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> SET_MM_AUXV = <span class="tok-number">12</span>;</span>
<span class="line" id="L4759">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> SET_MM_EXE_FILE = <span class="tok-number">13</span>;</span>
<span class="line" id="L4760">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> SET_MM_MAP = <span class="tok-number">14</span>;</span>
<span class="line" id="L4761">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> SET_MM_MAP_SIZE = <span class="tok-number">15</span>;</span>
<span class="line" id="L4762"></span>
<span class="line" id="L4763">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> SET_PTRACER_ANY = std.math.maxInt(<span class="tok-type">c_ulong</span>);</span>
<span class="line" id="L4764"></span>
<span class="line" id="L4765">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> FP_MODE_FR = <span class="tok-number">1</span> &lt;&lt; <span class="tok-number">0</span>;</span>
<span class="line" id="L4766">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> FP_MODE_FRE = <span class="tok-number">1</span> &lt;&lt; <span class="tok-number">1</span>;</span>
<span class="line" id="L4767"></span>
<span class="line" id="L4768">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> CAP_AMBIENT_IS_SET = <span class="tok-number">1</span>;</span>
<span class="line" id="L4769">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> CAP_AMBIENT_RAISE = <span class="tok-number">2</span>;</span>
<span class="line" id="L4770">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> CAP_AMBIENT_LOWER = <span class="tok-number">3</span>;</span>
<span class="line" id="L4771">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> CAP_AMBIENT_CLEAR_ALL = <span class="tok-number">4</span>;</span>
<span class="line" id="L4772"></span>
<span class="line" id="L4773">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> SVE_SET_VL_ONEXEC = <span class="tok-number">1</span> &lt;&lt; <span class="tok-number">18</span>;</span>
<span class="line" id="L4774">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> SVE_VL_LEN_MASK = <span class="tok-number">0xffff</span>;</span>
<span class="line" id="L4775">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> SVE_VL_INHERIT = <span class="tok-number">1</span> &lt;&lt; <span class="tok-number">17</span>;</span>
<span class="line" id="L4776"></span>
<span class="line" id="L4777">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> SPEC_STORE_BYPASS = <span class="tok-number">0</span>;</span>
<span class="line" id="L4778">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> SPEC_NOT_AFFECTED = <span class="tok-number">0</span>;</span>
<span class="line" id="L4779">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> SPEC_PRCTL = <span class="tok-number">1</span> &lt;&lt; <span class="tok-number">0</span>;</span>
<span class="line" id="L4780">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> SPEC_ENABLE = <span class="tok-number">1</span> &lt;&lt; <span class="tok-number">1</span>;</span>
<span class="line" id="L4781">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> SPEC_DISABLE = <span class="tok-number">1</span> &lt;&lt; <span class="tok-number">2</span>;</span>
<span class="line" id="L4782">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> SPEC_FORCE_DISABLE = <span class="tok-number">1</span> &lt;&lt; <span class="tok-number">3</span>;</span>
<span class="line" id="L4783">};</span>
<span class="line" id="L4784"></span>
<span class="line" id="L4785"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> prctl_mm_map = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L4786">    start_code: <span class="tok-type">u64</span>,</span>
<span class="line" id="L4787">    end_code: <span class="tok-type">u64</span>,</span>
<span class="line" id="L4788">    start_data: <span class="tok-type">u64</span>,</span>
<span class="line" id="L4789">    end_data: <span class="tok-type">u64</span>,</span>
<span class="line" id="L4790">    start_brk: <span class="tok-type">u64</span>,</span>
<span class="line" id="L4791">    brk: <span class="tok-type">u64</span>,</span>
<span class="line" id="L4792">    start_stack: <span class="tok-type">u64</span>,</span>
<span class="line" id="L4793">    arg_start: <span class="tok-type">u64</span>,</span>
<span class="line" id="L4794">    arg_end: <span class="tok-type">u64</span>,</span>
<span class="line" id="L4795">    env_start: <span class="tok-type">u64</span>,</span>
<span class="line" id="L4796">    env_end: <span class="tok-type">u64</span>,</span>
<span class="line" id="L4797">    auxv: *<span class="tok-type">u64</span>,</span>
<span class="line" id="L4798">    auxv_size: <span class="tok-type">u32</span>,</span>
<span class="line" id="L4799">    exe_fd: <span class="tok-type">u32</span>,</span>
<span class="line" id="L4800">};</span>
<span class="line" id="L4801"></span>
<span class="line" id="L4802"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> NETLINK = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L4803">    <span class="tok-comment">/// Routing/device hook</span></span>
<span class="line" id="L4804">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> ROUTE = <span class="tok-number">0</span>;</span>
<span class="line" id="L4805"></span>
<span class="line" id="L4806">    <span class="tok-comment">/// Unused number</span></span>
<span class="line" id="L4807">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> UNUSED = <span class="tok-number">1</span>;</span>
<span class="line" id="L4808"></span>
<span class="line" id="L4809">    <span class="tok-comment">/// Reserved for user mode socket protocols</span></span>
<span class="line" id="L4810">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> USERSOCK = <span class="tok-number">2</span>;</span>
<span class="line" id="L4811"></span>
<span class="line" id="L4812">    <span class="tok-comment">/// Unused number, formerly ip_queue</span></span>
<span class="line" id="L4813">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> FIREWALL = <span class="tok-number">3</span>;</span>
<span class="line" id="L4814"></span>
<span class="line" id="L4815">    <span class="tok-comment">/// socket monitoring</span></span>
<span class="line" id="L4816">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> SOCK_DIAG = <span class="tok-number">4</span>;</span>
<span class="line" id="L4817"></span>
<span class="line" id="L4818">    <span class="tok-comment">/// netfilter/iptables ULOG</span></span>
<span class="line" id="L4819">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> NFLOG = <span class="tok-number">5</span>;</span>
<span class="line" id="L4820"></span>
<span class="line" id="L4821">    <span class="tok-comment">/// ipsec</span></span>
<span class="line" id="L4822">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> XFRM = <span class="tok-number">6</span>;</span>
<span class="line" id="L4823"></span>
<span class="line" id="L4824">    <span class="tok-comment">/// SELinux event notifications</span></span>
<span class="line" id="L4825">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> SELINUX = <span class="tok-number">7</span>;</span>
<span class="line" id="L4826"></span>
<span class="line" id="L4827">    <span class="tok-comment">/// Open-iSCSI</span></span>
<span class="line" id="L4828">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> ISCSI = <span class="tok-number">8</span>;</span>
<span class="line" id="L4829"></span>
<span class="line" id="L4830">    <span class="tok-comment">/// auditing</span></span>
<span class="line" id="L4831">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> AUDIT = <span class="tok-number">9</span>;</span>
<span class="line" id="L4832"></span>
<span class="line" id="L4833">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> FIB_LOOKUP = <span class="tok-number">10</span>;</span>
<span class="line" id="L4834"></span>
<span class="line" id="L4835">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> CONNECTOR = <span class="tok-number">11</span>;</span>
<span class="line" id="L4836"></span>
<span class="line" id="L4837">    <span class="tok-comment">/// netfilter subsystem</span></span>
<span class="line" id="L4838">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> NETFILTER = <span class="tok-number">12</span>;</span>
<span class="line" id="L4839"></span>
<span class="line" id="L4840">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> IP6_FW = <span class="tok-number">13</span>;</span>
<span class="line" id="L4841"></span>
<span class="line" id="L4842">    <span class="tok-comment">/// DECnet routing messages</span></span>
<span class="line" id="L4843">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> DNRTMSG = <span class="tok-number">14</span>;</span>
<span class="line" id="L4844"></span>
<span class="line" id="L4845">    <span class="tok-comment">/// Kernel messages to userspace</span></span>
<span class="line" id="L4846">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> KOBJECT_UEVENT = <span class="tok-number">15</span>;</span>
<span class="line" id="L4847"></span>
<span class="line" id="L4848">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> GENERIC = <span class="tok-number">16</span>;</span>
<span class="line" id="L4849"></span>
<span class="line" id="L4850">    <span class="tok-comment">// leave room for NETLINK_DM (DM Events)</span>
</span>
<span class="line" id="L4851"></span>
<span class="line" id="L4852">    <span class="tok-comment">/// SCSI Transports</span></span>
<span class="line" id="L4853">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> SCSITRANSPORT = <span class="tok-number">18</span>;</span>
<span class="line" id="L4854"></span>
<span class="line" id="L4855">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> ECRYPTFS = <span class="tok-number">19</span>;</span>
<span class="line" id="L4856"></span>
<span class="line" id="L4857">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> RDMA = <span class="tok-number">20</span>;</span>
<span class="line" id="L4858"></span>
<span class="line" id="L4859">    <span class="tok-comment">/// Crypto layer</span></span>
<span class="line" id="L4860">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> CRYPTO = <span class="tok-number">21</span>;</span>
<span class="line" id="L4861"></span>
<span class="line" id="L4862">    <span class="tok-comment">/// SMC monitoring</span></span>
<span class="line" id="L4863">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> SMC = <span class="tok-number">22</span>;</span>
<span class="line" id="L4864">};</span>
<span class="line" id="L4865"></span>
<span class="line" id="L4866"><span class="tok-comment">// Flags values</span>
</span>
<span class="line" id="L4867"></span>
<span class="line" id="L4868"><span class="tok-comment">/// It is request message.</span></span>
<span class="line" id="L4869"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> NLM_F_REQUEST = <span class="tok-number">0x01</span>;</span>
<span class="line" id="L4870"></span>
<span class="line" id="L4871"><span class="tok-comment">/// Multipart message, terminated by NLMSG_DONE</span></span>
<span class="line" id="L4872"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> NLM_F_MULTI = <span class="tok-number">0x02</span>;</span>
<span class="line" id="L4873"></span>
<span class="line" id="L4874"><span class="tok-comment">/// Reply with ack, with zero or error code</span></span>
<span class="line" id="L4875"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> NLM_F_ACK = <span class="tok-number">0x04</span>;</span>
<span class="line" id="L4876"></span>
<span class="line" id="L4877"><span class="tok-comment">/// Echo this request</span></span>
<span class="line" id="L4878"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> NLM_F_ECHO = <span class="tok-number">0x08</span>;</span>
<span class="line" id="L4879"></span>
<span class="line" id="L4880"><span class="tok-comment">/// Dump was inconsistent due to sequence change</span></span>
<span class="line" id="L4881"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> NLM_F_DUMP_INTR = <span class="tok-number">0x10</span>;</span>
<span class="line" id="L4882"></span>
<span class="line" id="L4883"><span class="tok-comment">/// Dump was filtered as requested</span></span>
<span class="line" id="L4884"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> NLM_F_DUMP_FILTERED = <span class="tok-number">0x20</span>;</span>
<span class="line" id="L4885"></span>
<span class="line" id="L4886"><span class="tok-comment">// Modifiers to GET request</span>
</span>
<span class="line" id="L4887"></span>
<span class="line" id="L4888"><span class="tok-comment">/// specify tree root</span></span>
<span class="line" id="L4889"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> NLM_F_ROOT = <span class="tok-number">0x100</span>;</span>
<span class="line" id="L4890"></span>
<span class="line" id="L4891"><span class="tok-comment">/// return all matching</span></span>
<span class="line" id="L4892"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> NLM_F_MATCH = <span class="tok-number">0x200</span>;</span>
<span class="line" id="L4893"></span>
<span class="line" id="L4894"><span class="tok-comment">/// atomic GET</span></span>
<span class="line" id="L4895"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> NLM_F_ATOMIC = <span class="tok-number">0x400</span>;</span>
<span class="line" id="L4896"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> NLM_F_DUMP = NLM_F_ROOT | NLM_F_MATCH;</span>
<span class="line" id="L4897"></span>
<span class="line" id="L4898"><span class="tok-comment">// Modifiers to NEW request</span>
</span>
<span class="line" id="L4899"></span>
<span class="line" id="L4900"><span class="tok-comment">/// Override existing</span></span>
<span class="line" id="L4901"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> NLM_F_REPLACE = <span class="tok-number">0x100</span>;</span>
<span class="line" id="L4902"></span>
<span class="line" id="L4903"><span class="tok-comment">/// Do not touch, if it exists</span></span>
<span class="line" id="L4904"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> NLM_F_EXCL = <span class="tok-number">0x200</span>;</span>
<span class="line" id="L4905"></span>
<span class="line" id="L4906"><span class="tok-comment">/// Create, if it does not exist</span></span>
<span class="line" id="L4907"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> NLM_F_CREATE = <span class="tok-number">0x400</span>;</span>
<span class="line" id="L4908"></span>
<span class="line" id="L4909"><span class="tok-comment">/// Add to end of list</span></span>
<span class="line" id="L4910"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> NLM_F_APPEND = <span class="tok-number">0x800</span>;</span>
<span class="line" id="L4911"></span>
<span class="line" id="L4912"><span class="tok-comment">// Modifiers to DELETE request</span>
</span>
<span class="line" id="L4913"></span>
<span class="line" id="L4914"><span class="tok-comment">/// Do not delete recursively</span></span>
<span class="line" id="L4915"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> NLM_F_NONREC = <span class="tok-number">0x100</span>;</span>
<span class="line" id="L4916"></span>
<span class="line" id="L4917"><span class="tok-comment">// Flags for ACK message</span>
</span>
<span class="line" id="L4918"></span>
<span class="line" id="L4919"><span class="tok-comment">/// request was capped</span></span>
<span class="line" id="L4920"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> NLM_F_CAPPED = <span class="tok-number">0x100</span>;</span>
<span class="line" id="L4921"></span>
<span class="line" id="L4922"><span class="tok-comment">/// extended ACK TVLs were included</span></span>
<span class="line" id="L4923"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> NLM_F_ACK_TLVS = <span class="tok-number">0x200</span>;</span>
<span class="line" id="L4924"></span>
<span class="line" id="L4925"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> NetlinkMessageType = <span class="tok-kw">enum</span>(<span class="tok-type">u16</span>) {</span>
<span class="line" id="L4926">    <span class="tok-comment">/// &lt; 0x10: reserved control messages</span></span>
<span class="line" id="L4927">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> MIN_TYPE = <span class="tok-number">0x10</span>;</span>
<span class="line" id="L4928"></span>
<span class="line" id="L4929">    <span class="tok-comment">/// Nothing.</span></span>
<span class="line" id="L4930">    NOOP = <span class="tok-number">0x1</span>,</span>
<span class="line" id="L4931"></span>
<span class="line" id="L4932">    <span class="tok-comment">/// Error</span></span>
<span class="line" id="L4933">    ERROR = <span class="tok-number">0x2</span>,</span>
<span class="line" id="L4934"></span>
<span class="line" id="L4935">    <span class="tok-comment">/// End of a dump</span></span>
<span class="line" id="L4936">    DONE = <span class="tok-number">0x3</span>,</span>
<span class="line" id="L4937"></span>
<span class="line" id="L4938">    <span class="tok-comment">/// Data lost</span></span>
<span class="line" id="L4939">    OVERRUN = <span class="tok-number">0x4</span>,</span>
<span class="line" id="L4940"></span>
<span class="line" id="L4941">    <span class="tok-comment">// rtlink types</span>
</span>
<span class="line" id="L4942"></span>
<span class="line" id="L4943">    RTM_NEWLINK = <span class="tok-number">16</span>,</span>
<span class="line" id="L4944">    RTM_DELLINK,</span>
<span class="line" id="L4945">    RTM_GETLINK,</span>
<span class="line" id="L4946">    RTM_SETLINK,</span>
<span class="line" id="L4947"></span>
<span class="line" id="L4948">    RTM_NEWADDR = <span class="tok-number">20</span>,</span>
<span class="line" id="L4949">    RTM_DELADDR,</span>
<span class="line" id="L4950">    RTM_GETADDR,</span>
<span class="line" id="L4951"></span>
<span class="line" id="L4952">    RTM_NEWROUTE = <span class="tok-number">24</span>,</span>
<span class="line" id="L4953">    RTM_DELROUTE,</span>
<span class="line" id="L4954">    RTM_GETROUTE,</span>
<span class="line" id="L4955"></span>
<span class="line" id="L4956">    RTM_NEWNEIGH = <span class="tok-number">28</span>,</span>
<span class="line" id="L4957">    RTM_DELNEIGH,</span>
<span class="line" id="L4958">    RTM_GETNEIGH,</span>
<span class="line" id="L4959"></span>
<span class="line" id="L4960">    RTM_NEWRULE = <span class="tok-number">32</span>,</span>
<span class="line" id="L4961">    RTM_DELRULE,</span>
<span class="line" id="L4962">    RTM_GETRULE,</span>
<span class="line" id="L4963"></span>
<span class="line" id="L4964">    RTM_NEWQDISC = <span class="tok-number">36</span>,</span>
<span class="line" id="L4965">    RTM_DELQDISC,</span>
<span class="line" id="L4966">    RTM_GETQDISC,</span>
<span class="line" id="L4967"></span>
<span class="line" id="L4968">    RTM_NEWTCLASS = <span class="tok-number">40</span>,</span>
<span class="line" id="L4969">    RTM_DELTCLASS,</span>
<span class="line" id="L4970">    RTM_GETTCLASS,</span>
<span class="line" id="L4971"></span>
<span class="line" id="L4972">    RTM_NEWTFILTER = <span class="tok-number">44</span>,</span>
<span class="line" id="L4973">    RTM_DELTFILTER,</span>
<span class="line" id="L4974">    RTM_GETTFILTER,</span>
<span class="line" id="L4975"></span>
<span class="line" id="L4976">    RTM_NEWACTION = <span class="tok-number">48</span>,</span>
<span class="line" id="L4977">    RTM_DELACTION,</span>
<span class="line" id="L4978">    RTM_GETACTION,</span>
<span class="line" id="L4979"></span>
<span class="line" id="L4980">    RTM_NEWPREFIX = <span class="tok-number">52</span>,</span>
<span class="line" id="L4981"></span>
<span class="line" id="L4982">    RTM_GETMULTICAST = <span class="tok-number">58</span>,</span>
<span class="line" id="L4983"></span>
<span class="line" id="L4984">    RTM_GETANYCAST = <span class="tok-number">62</span>,</span>
<span class="line" id="L4985"></span>
<span class="line" id="L4986">    RTM_NEWNEIGHTBL = <span class="tok-number">64</span>,</span>
<span class="line" id="L4987">    RTM_GETNEIGHTBL = <span class="tok-number">66</span>,</span>
<span class="line" id="L4988">    RTM_SETNEIGHTBL,</span>
<span class="line" id="L4989"></span>
<span class="line" id="L4990">    RTM_NEWNDUSEROPT = <span class="tok-number">68</span>,</span>
<span class="line" id="L4991"></span>
<span class="line" id="L4992">    RTM_NEWADDRLABEL = <span class="tok-number">72</span>,</span>
<span class="line" id="L4993">    RTM_DELADDRLABEL,</span>
<span class="line" id="L4994">    RTM_GETADDRLABEL,</span>
<span class="line" id="L4995"></span>
<span class="line" id="L4996">    RTM_GETDCB = <span class="tok-number">78</span>,</span>
<span class="line" id="L4997">    RTM_SETDCB,</span>
<span class="line" id="L4998"></span>
<span class="line" id="L4999">    RTM_NEWNETCONF = <span class="tok-number">80</span>,</span>
<span class="line" id="L5000">    RTM_DELNETCONF,</span>
<span class="line" id="L5001">    RTM_GETNETCONF = <span class="tok-number">82</span>,</span>
<span class="line" id="L5002"></span>
<span class="line" id="L5003">    RTM_NEWMDB = <span class="tok-number">84</span>,</span>
<span class="line" id="L5004">    RTM_DELMDB = <span class="tok-number">85</span>,</span>
<span class="line" id="L5005">    RTM_GETMDB = <span class="tok-number">86</span>,</span>
<span class="line" id="L5006"></span>
<span class="line" id="L5007">    RTM_NEWNSID = <span class="tok-number">88</span>,</span>
<span class="line" id="L5008">    RTM_DELNSID = <span class="tok-number">89</span>,</span>
<span class="line" id="L5009">    RTM_GETNSID = <span class="tok-number">90</span>,</span>
<span class="line" id="L5010"></span>
<span class="line" id="L5011">    RTM_NEWSTATS = <span class="tok-number">92</span>,</span>
<span class="line" id="L5012">    RTM_GETSTATS = <span class="tok-number">94</span>,</span>
<span class="line" id="L5013"></span>
<span class="line" id="L5014">    RTM_NEWCACHEREPORT = <span class="tok-number">96</span>,</span>
<span class="line" id="L5015"></span>
<span class="line" id="L5016">    RTM_NEWCHAIN = <span class="tok-number">100</span>,</span>
<span class="line" id="L5017">    RTM_DELCHAIN,</span>
<span class="line" id="L5018">    RTM_GETCHAIN,</span>
<span class="line" id="L5019"></span>
<span class="line" id="L5020">    RTM_NEWNEXTHOP = <span class="tok-number">104</span>,</span>
<span class="line" id="L5021">    RTM_DELNEXTHOP,</span>
<span class="line" id="L5022">    RTM_GETNEXTHOP,</span>
<span class="line" id="L5023"></span>
<span class="line" id="L5024">    _,</span>
<span class="line" id="L5025">};</span>
<span class="line" id="L5026"></span>
<span class="line" id="L5027"><span class="tok-comment">/// Netlink message header</span></span>
<span class="line" id="L5028"><span class="tok-comment">/// Specified in RFC 3549 Section 2.3.2</span></span>
<span class="line" id="L5029"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> nlmsghdr = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L5030">    <span class="tok-comment">/// Length of message including header</span></span>
<span class="line" id="L5031">    len: <span class="tok-type">u32</span>,</span>
<span class="line" id="L5032"></span>
<span class="line" id="L5033">    <span class="tok-comment">/// Message content</span></span>
<span class="line" id="L5034">    @&quot;type&quot;: NetlinkMessageType,</span>
<span class="line" id="L5035"></span>
<span class="line" id="L5036">    <span class="tok-comment">/// Additional flags</span></span>
<span class="line" id="L5037">    flags: <span class="tok-type">u16</span>,</span>
<span class="line" id="L5038"></span>
<span class="line" id="L5039">    <span class="tok-comment">/// Sequence number</span></span>
<span class="line" id="L5040">    seq: <span class="tok-type">u32</span>,</span>
<span class="line" id="L5041"></span>
<span class="line" id="L5042">    <span class="tok-comment">/// Sending process port ID</span></span>
<span class="line" id="L5043">    pid: <span class="tok-type">u32</span>,</span>
<span class="line" id="L5044">};</span>
<span class="line" id="L5045"></span>
<span class="line" id="L5046"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> ifinfomsg = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L5047">    family: <span class="tok-type">u8</span>,</span>
<span class="line" id="L5048">    __pad1: <span class="tok-type">u8</span> = <span class="tok-number">0</span>,</span>
<span class="line" id="L5049"></span>
<span class="line" id="L5050">    <span class="tok-comment">/// ARPHRD_*</span></span>
<span class="line" id="L5051">    @&quot;type&quot;: <span class="tok-type">c_ushort</span>,</span>
<span class="line" id="L5052"></span>
<span class="line" id="L5053">    <span class="tok-comment">/// Link index</span></span>
<span class="line" id="L5054">    index: <span class="tok-type">c_int</span>,</span>
<span class="line" id="L5055"></span>
<span class="line" id="L5056">    <span class="tok-comment">/// IFF_* flags</span></span>
<span class="line" id="L5057">    flags: <span class="tok-type">c_uint</span>,</span>
<span class="line" id="L5058"></span>
<span class="line" id="L5059">    <span class="tok-comment">/// IFF_* change mask</span></span>
<span class="line" id="L5060">    change: <span class="tok-type">c_uint</span>,</span>
<span class="line" id="L5061">};</span>
<span class="line" id="L5062"></span>
<span class="line" id="L5063"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> rtattr = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L5064">    <span class="tok-comment">/// Length of option</span></span>
<span class="line" id="L5065">    len: <span class="tok-type">c_ushort</span>,</span>
<span class="line" id="L5066"></span>
<span class="line" id="L5067">    <span class="tok-comment">/// Type of option</span></span>
<span class="line" id="L5068">    @&quot;type&quot;: IFLA,</span>
<span class="line" id="L5069"></span>
<span class="line" id="L5070">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> ALIGNTO = <span class="tok-number">4</span>;</span>
<span class="line" id="L5071">};</span>
<span class="line" id="L5072"></span>
<span class="line" id="L5073"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IFLA = <span class="tok-kw">enum</span>(<span class="tok-type">c_ushort</span>) {</span>
<span class="line" id="L5074">    UNSPEC,</span>
<span class="line" id="L5075">    ADDRESS,</span>
<span class="line" id="L5076">    BROADCAST,</span>
<span class="line" id="L5077">    IFNAME,</span>
<span class="line" id="L5078">    MTU,</span>
<span class="line" id="L5079">    LINK,</span>
<span class="line" id="L5080">    QDISC,</span>
<span class="line" id="L5081">    STATS,</span>
<span class="line" id="L5082">    COST,</span>
<span class="line" id="L5083">    PRIORITY,</span>
<span class="line" id="L5084">    MASTER,</span>
<span class="line" id="L5085"></span>
<span class="line" id="L5086">    <span class="tok-comment">/// Wireless Extension event</span></span>
<span class="line" id="L5087">    WIRELESS,</span>
<span class="line" id="L5088"></span>
<span class="line" id="L5089">    <span class="tok-comment">/// Protocol specific information for a link</span></span>
<span class="line" id="L5090">    PROTINFO,</span>
<span class="line" id="L5091"></span>
<span class="line" id="L5092">    TXQLEN,</span>
<span class="line" id="L5093">    MAP,</span>
<span class="line" id="L5094">    WEIGHT,</span>
<span class="line" id="L5095">    OPERSTATE,</span>
<span class="line" id="L5096">    LINKMODE,</span>
<span class="line" id="L5097">    LINKINFO,</span>
<span class="line" id="L5098">    NET_NS_PID,</span>
<span class="line" id="L5099">    IFALIAS,</span>
<span class="line" id="L5100"></span>
<span class="line" id="L5101">    <span class="tok-comment">/// Number of VFs if device is SR-IOV PF</span></span>
<span class="line" id="L5102">    NUM_VF,</span>
<span class="line" id="L5103"></span>
<span class="line" id="L5104">    VFINFO_LIST,</span>
<span class="line" id="L5105">    STATS64,</span>
<span class="line" id="L5106">    VF_PORTS,</span>
<span class="line" id="L5107">    PORT_SELF,</span>
<span class="line" id="L5108">    AF_SPEC,</span>
<span class="line" id="L5109"></span>
<span class="line" id="L5110">    <span class="tok-comment">/// Group the device belongs to</span></span>
<span class="line" id="L5111">    GROUP,</span>
<span class="line" id="L5112"></span>
<span class="line" id="L5113">    NET_NS_FD,</span>
<span class="line" id="L5114"></span>
<span class="line" id="L5115">    <span class="tok-comment">/// Extended info mask, VFs, etc</span></span>
<span class="line" id="L5116">    EXT_MASK,</span>
<span class="line" id="L5117"></span>
<span class="line" id="L5118">    <span class="tok-comment">/// Promiscuity count: &gt; 0 means acts PROMISC</span></span>
<span class="line" id="L5119">    PROMISCUITY,</span>
<span class="line" id="L5120"></span>
<span class="line" id="L5121">    NUM_TX_QUEUES,</span>
<span class="line" id="L5122">    NUM_RX_QUEUES,</span>
<span class="line" id="L5123">    CARRIER,</span>
<span class="line" id="L5124">    PHYS_PORT_ID,</span>
<span class="line" id="L5125">    CARRIER_CHANGES,</span>
<span class="line" id="L5126">    PHYS_SWITCH_ID,</span>
<span class="line" id="L5127">    LINK_NETNSID,</span>
<span class="line" id="L5128">    PHYS_PORT_NAME,</span>
<span class="line" id="L5129">    PROTO_DOWN,</span>
<span class="line" id="L5130">    GSO_MAX_SEGS,</span>
<span class="line" id="L5131">    GSO_MAX_SIZE,</span>
<span class="line" id="L5132">    PAD,</span>
<span class="line" id="L5133">    XDP,</span>
<span class="line" id="L5134">    EVENT,</span>
<span class="line" id="L5135"></span>
<span class="line" id="L5136">    NEW_NETNSID,</span>
<span class="line" id="L5137">    IF_NETNSID,</span>
<span class="line" id="L5138"></span>
<span class="line" id="L5139">    CARRIER_UP_COUNT,</span>
<span class="line" id="L5140">    CARRIER_DOWN_COUNT,</span>
<span class="line" id="L5141">    NEW_IFINDEX,</span>
<span class="line" id="L5142">    MIN_MTU,</span>
<span class="line" id="L5143">    MAX_MTU,</span>
<span class="line" id="L5144"></span>
<span class="line" id="L5145">    _,</span>
<span class="line" id="L5146"></span>
<span class="line" id="L5147">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> TARGET_NETNSID: IFLA = .IF_NETNSID;</span>
<span class="line" id="L5148">};</span>
<span class="line" id="L5149"></span>
<span class="line" id="L5150"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> rtnl_link_ifmap = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L5151">    mem_start: <span class="tok-type">u64</span>,</span>
<span class="line" id="L5152">    mem_end: <span class="tok-type">u64</span>,</span>
<span class="line" id="L5153">    base_addr: <span class="tok-type">u64</span>,</span>
<span class="line" id="L5154">    irq: <span class="tok-type">u16</span>,</span>
<span class="line" id="L5155">    dma: <span class="tok-type">u8</span>,</span>
<span class="line" id="L5156">    port: <span class="tok-type">u8</span>,</span>
<span class="line" id="L5157">};</span>
<span class="line" id="L5158"></span>
<span class="line" id="L5159"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> rtnl_link_stats = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L5160">    <span class="tok-comment">/// total packets received</span></span>
<span class="line" id="L5161">    rx_packets: <span class="tok-type">u32</span>,</span>
<span class="line" id="L5162"></span>
<span class="line" id="L5163">    <span class="tok-comment">/// total packets transmitted</span></span>
<span class="line" id="L5164">    tx_packets: <span class="tok-type">u32</span>,</span>
<span class="line" id="L5165"></span>
<span class="line" id="L5166">    <span class="tok-comment">/// total bytes received</span></span>
<span class="line" id="L5167">    rx_bytes: <span class="tok-type">u32</span>,</span>
<span class="line" id="L5168"></span>
<span class="line" id="L5169">    <span class="tok-comment">/// total bytes transmitted</span></span>
<span class="line" id="L5170">    tx_bytes: <span class="tok-type">u32</span>,</span>
<span class="line" id="L5171"></span>
<span class="line" id="L5172">    <span class="tok-comment">/// bad packets received</span></span>
<span class="line" id="L5173">    rx_errors: <span class="tok-type">u32</span>,</span>
<span class="line" id="L5174"></span>
<span class="line" id="L5175">    <span class="tok-comment">/// packet transmit problems</span></span>
<span class="line" id="L5176">    tx_errors: <span class="tok-type">u32</span>,</span>
<span class="line" id="L5177"></span>
<span class="line" id="L5178">    <span class="tok-comment">/// no space in linux buffers</span></span>
<span class="line" id="L5179">    rx_dropped: <span class="tok-type">u32</span>,</span>
<span class="line" id="L5180"></span>
<span class="line" id="L5181">    <span class="tok-comment">/// no space available in linux</span></span>
<span class="line" id="L5182">    tx_dropped: <span class="tok-type">u32</span>,</span>
<span class="line" id="L5183"></span>
<span class="line" id="L5184">    <span class="tok-comment">/// multicast packets received</span></span>
<span class="line" id="L5185">    multicast: <span class="tok-type">u32</span>,</span>
<span class="line" id="L5186"></span>
<span class="line" id="L5187">    collisions: <span class="tok-type">u32</span>,</span>
<span class="line" id="L5188"></span>
<span class="line" id="L5189">    <span class="tok-comment">// detailed rx_errors</span>
</span>
<span class="line" id="L5190"></span>
<span class="line" id="L5191">    rx_length_errors: <span class="tok-type">u32</span>,</span>
<span class="line" id="L5192"></span>
<span class="line" id="L5193">    <span class="tok-comment">/// receiver ring buff overflow</span></span>
<span class="line" id="L5194">    rx_over_errors: <span class="tok-type">u32</span>,</span>
<span class="line" id="L5195"></span>
<span class="line" id="L5196">    <span class="tok-comment">/// recved pkt with crc error</span></span>
<span class="line" id="L5197">    rx_crc_errors: <span class="tok-type">u32</span>,</span>
<span class="line" id="L5198"></span>
<span class="line" id="L5199">    <span class="tok-comment">/// recv'd frame alignment error</span></span>
<span class="line" id="L5200">    rx_frame_errors: <span class="tok-type">u32</span>,</span>
<span class="line" id="L5201"></span>
<span class="line" id="L5202">    <span class="tok-comment">/// recv'r fifo overrun</span></span>
<span class="line" id="L5203">    rx_fifo_errors: <span class="tok-type">u32</span>,</span>
<span class="line" id="L5204"></span>
<span class="line" id="L5205">    <span class="tok-comment">/// receiver missed packet</span></span>
<span class="line" id="L5206">    rx_missed_errors: <span class="tok-type">u32</span>,</span>
<span class="line" id="L5207"></span>
<span class="line" id="L5208">    <span class="tok-comment">// detailed tx_errors</span>
</span>
<span class="line" id="L5209">    tx_aborted_errors: <span class="tok-type">u32</span>,</span>
<span class="line" id="L5210">    tx_carrier_errors: <span class="tok-type">u32</span>,</span>
<span class="line" id="L5211">    tx_fifo_errors: <span class="tok-type">u32</span>,</span>
<span class="line" id="L5212">    tx_heartbeat_errors: <span class="tok-type">u32</span>,</span>
<span class="line" id="L5213">    tx_window_errors: <span class="tok-type">u32</span>,</span>
<span class="line" id="L5214"></span>
<span class="line" id="L5215">    <span class="tok-comment">// for cslip etc</span>
</span>
<span class="line" id="L5216"></span>
<span class="line" id="L5217">    rx_compressed: <span class="tok-type">u32</span>,</span>
<span class="line" id="L5218">    tx_compressed: <span class="tok-type">u32</span>,</span>
<span class="line" id="L5219"></span>
<span class="line" id="L5220">    <span class="tok-comment">/// dropped, no handler found</span></span>
<span class="line" id="L5221">    rx_nohandler: <span class="tok-type">u32</span>,</span>
<span class="line" id="L5222">};</span>
<span class="line" id="L5223"></span>
<span class="line" id="L5224"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> rtnl_link_stats64 = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L5225">    <span class="tok-comment">/// total packets received</span></span>
<span class="line" id="L5226">    rx_packets: <span class="tok-type">u64</span>,</span>
<span class="line" id="L5227"></span>
<span class="line" id="L5228">    <span class="tok-comment">/// total packets transmitted</span></span>
<span class="line" id="L5229">    tx_packets: <span class="tok-type">u64</span>,</span>
<span class="line" id="L5230"></span>
<span class="line" id="L5231">    <span class="tok-comment">/// total bytes received</span></span>
<span class="line" id="L5232">    rx_bytes: <span class="tok-type">u64</span>,</span>
<span class="line" id="L5233"></span>
<span class="line" id="L5234">    <span class="tok-comment">/// total bytes transmitted</span></span>
<span class="line" id="L5235">    tx_bytes: <span class="tok-type">u64</span>,</span>
<span class="line" id="L5236"></span>
<span class="line" id="L5237">    <span class="tok-comment">/// bad packets received</span></span>
<span class="line" id="L5238">    rx_errors: <span class="tok-type">u64</span>,</span>
<span class="line" id="L5239"></span>
<span class="line" id="L5240">    <span class="tok-comment">/// packet transmit problems</span></span>
<span class="line" id="L5241">    tx_errors: <span class="tok-type">u64</span>,</span>
<span class="line" id="L5242"></span>
<span class="line" id="L5243">    <span class="tok-comment">/// no space in linux buffers</span></span>
<span class="line" id="L5244">    rx_dropped: <span class="tok-type">u64</span>,</span>
<span class="line" id="L5245"></span>
<span class="line" id="L5246">    <span class="tok-comment">/// no space available in linux</span></span>
<span class="line" id="L5247">    tx_dropped: <span class="tok-type">u64</span>,</span>
<span class="line" id="L5248"></span>
<span class="line" id="L5249">    <span class="tok-comment">/// multicast packets received</span></span>
<span class="line" id="L5250">    multicast: <span class="tok-type">u64</span>,</span>
<span class="line" id="L5251"></span>
<span class="line" id="L5252">    collisions: <span class="tok-type">u64</span>,</span>
<span class="line" id="L5253"></span>
<span class="line" id="L5254">    <span class="tok-comment">// detailed rx_errors</span>
</span>
<span class="line" id="L5255"></span>
<span class="line" id="L5256">    rx_length_errors: <span class="tok-type">u64</span>,</span>
<span class="line" id="L5257"></span>
<span class="line" id="L5258">    <span class="tok-comment">/// receiver ring buff overflow</span></span>
<span class="line" id="L5259">    rx_over_errors: <span class="tok-type">u64</span>,</span>
<span class="line" id="L5260"></span>
<span class="line" id="L5261">    <span class="tok-comment">/// recved pkt with crc error</span></span>
<span class="line" id="L5262">    rx_crc_errors: <span class="tok-type">u64</span>,</span>
<span class="line" id="L5263"></span>
<span class="line" id="L5264">    <span class="tok-comment">/// recv'd frame alignment error</span></span>
<span class="line" id="L5265">    rx_frame_errors: <span class="tok-type">u64</span>,</span>
<span class="line" id="L5266"></span>
<span class="line" id="L5267">    <span class="tok-comment">/// recv'r fifo overrun</span></span>
<span class="line" id="L5268">    rx_fifo_errors: <span class="tok-type">u64</span>,</span>
<span class="line" id="L5269"></span>
<span class="line" id="L5270">    <span class="tok-comment">/// receiver missed packet</span></span>
<span class="line" id="L5271">    rx_missed_errors: <span class="tok-type">u64</span>,</span>
<span class="line" id="L5272"></span>
<span class="line" id="L5273">    <span class="tok-comment">// detailed tx_errors</span>
</span>
<span class="line" id="L5274">    tx_aborted_errors: <span class="tok-type">u64</span>,</span>
<span class="line" id="L5275">    tx_carrier_errors: <span class="tok-type">u64</span>,</span>
<span class="line" id="L5276">    tx_fifo_errors: <span class="tok-type">u64</span>,</span>
<span class="line" id="L5277">    tx_heartbeat_errors: <span class="tok-type">u64</span>,</span>
<span class="line" id="L5278">    tx_window_errors: <span class="tok-type">u64</span>,</span>
<span class="line" id="L5279"></span>
<span class="line" id="L5280">    <span class="tok-comment">// for cslip etc</span>
</span>
<span class="line" id="L5281"></span>
<span class="line" id="L5282">    rx_compressed: <span class="tok-type">u64</span>,</span>
<span class="line" id="L5283">    tx_compressed: <span class="tok-type">u64</span>,</span>
<span class="line" id="L5284"></span>
<span class="line" id="L5285">    <span class="tok-comment">/// dropped, no handler found</span></span>
<span class="line" id="L5286">    rx_nohandler: <span class="tok-type">u64</span>,</span>
<span class="line" id="L5287">};</span>
<span class="line" id="L5288"></span>
<span class="line" id="L5289"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> perf_event_attr = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L5290">    <span class="tok-comment">/// Major type: hardware/software/tracepoint/etc.</span></span>
<span class="line" id="L5291">    <span class="tok-type">type</span>: PERF.TYPE = <span class="tok-null">undefined</span>,</span>
<span class="line" id="L5292">    <span class="tok-comment">/// Size of the attr structure, for fwd/bwd compat.</span></span>
<span class="line" id="L5293">    size: <span class="tok-type">u32</span> = <span class="tok-builtin">@sizeOf</span>(perf_event_attr),</span>
<span class="line" id="L5294">    <span class="tok-comment">/// Type specific configuration information.</span></span>
<span class="line" id="L5295">    config: <span class="tok-type">u64</span> = <span class="tok-number">0</span>,</span>
<span class="line" id="L5296"></span>
<span class="line" id="L5297">    sample_period_or_freq: <span class="tok-type">u64</span> = <span class="tok-number">0</span>,</span>
<span class="line" id="L5298">    sample_type: <span class="tok-type">u64</span> = <span class="tok-number">0</span>,</span>
<span class="line" id="L5299">    read_format: <span class="tok-type">u64</span> = <span class="tok-number">0</span>,</span>
<span class="line" id="L5300"></span>
<span class="line" id="L5301">    flags: <span class="tok-kw">packed</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L5302">        <span class="tok-comment">/// off by default</span></span>
<span class="line" id="L5303">        disabled: <span class="tok-type">bool</span> = <span class="tok-null">false</span>,</span>
<span class="line" id="L5304">        <span class="tok-comment">/// children inherit it</span></span>
<span class="line" id="L5305">        inherit: <span class="tok-type">bool</span> = <span class="tok-null">false</span>,</span>
<span class="line" id="L5306">        <span class="tok-comment">/// must always be on PMU</span></span>
<span class="line" id="L5307">        pinned: <span class="tok-type">bool</span> = <span class="tok-null">false</span>,</span>
<span class="line" id="L5308">        <span class="tok-comment">/// only group on PMU</span></span>
<span class="line" id="L5309">        exclusive: <span class="tok-type">bool</span> = <span class="tok-null">false</span>,</span>
<span class="line" id="L5310">        <span class="tok-comment">/// don't count user</span></span>
<span class="line" id="L5311">        exclude_user: <span class="tok-type">bool</span> = <span class="tok-null">false</span>,</span>
<span class="line" id="L5312">        <span class="tok-comment">/// ditto kernel</span></span>
<span class="line" id="L5313">        exclude_kernel: <span class="tok-type">bool</span> = <span class="tok-null">false</span>,</span>
<span class="line" id="L5314">        <span class="tok-comment">/// ditto hypervisor</span></span>
<span class="line" id="L5315">        exclude_hv: <span class="tok-type">bool</span> = <span class="tok-null">false</span>,</span>
<span class="line" id="L5316">        <span class="tok-comment">/// don't count when idle</span></span>
<span class="line" id="L5317">        exclude_idle: <span class="tok-type">bool</span> = <span class="tok-null">false</span>,</span>
<span class="line" id="L5318">        <span class="tok-comment">/// include mmap data</span></span>
<span class="line" id="L5319">        mmap: <span class="tok-type">bool</span> = <span class="tok-null">false</span>,</span>
<span class="line" id="L5320">        <span class="tok-comment">/// include comm data</span></span>
<span class="line" id="L5321">        comm: <span class="tok-type">bool</span> = <span class="tok-null">false</span>,</span>
<span class="line" id="L5322">        <span class="tok-comment">/// use freq, not period</span></span>
<span class="line" id="L5323">        freq: <span class="tok-type">bool</span> = <span class="tok-null">false</span>,</span>
<span class="line" id="L5324">        <span class="tok-comment">/// per task counts</span></span>
<span class="line" id="L5325">        inherit_stat: <span class="tok-type">bool</span> = <span class="tok-null">false</span>,</span>
<span class="line" id="L5326">        <span class="tok-comment">/// next exec enables</span></span>
<span class="line" id="L5327">        enable_on_exec: <span class="tok-type">bool</span> = <span class="tok-null">false</span>,</span>
<span class="line" id="L5328">        <span class="tok-comment">/// trace fork/exit</span></span>
<span class="line" id="L5329">        task: <span class="tok-type">bool</span> = <span class="tok-null">false</span>,</span>
<span class="line" id="L5330">        <span class="tok-comment">/// wakeup_watermark</span></span>
<span class="line" id="L5331">        watermark: <span class="tok-type">bool</span> = <span class="tok-null">false</span>,</span>
<span class="line" id="L5332">        <span class="tok-comment">/// precise_ip:</span></span>
<span class="line" id="L5333">        <span class="tok-comment">///</span></span>
<span class="line" id="L5334">        <span class="tok-comment">///  0 - SAMPLE_IP can have arbitrary skid</span></span>
<span class="line" id="L5335">        <span class="tok-comment">///  1 - SAMPLE_IP must have constant skid</span></span>
<span class="line" id="L5336">        <span class="tok-comment">///  2 - SAMPLE_IP requested to have 0 skid</span></span>
<span class="line" id="L5337">        <span class="tok-comment">///  3 - SAMPLE_IP must have 0 skid</span></span>
<span class="line" id="L5338">        <span class="tok-comment">///</span></span>
<span class="line" id="L5339">        <span class="tok-comment">///  See also PERF_RECORD_MISC_EXACT_IP</span></span>
<span class="line" id="L5340">        <span class="tok-comment">/// skid constraint</span></span>
<span class="line" id="L5341">        precise_ip: <span class="tok-type">u2</span> = <span class="tok-number">0</span>,</span>
<span class="line" id="L5342">        <span class="tok-comment">/// non-exec mmap data</span></span>
<span class="line" id="L5343">        mmap_data: <span class="tok-type">bool</span> = <span class="tok-null">false</span>,</span>
<span class="line" id="L5344">        <span class="tok-comment">/// sample_type all events</span></span>
<span class="line" id="L5345">        sample_id_all: <span class="tok-type">bool</span> = <span class="tok-null">false</span>,</span>
<span class="line" id="L5346"></span>
<span class="line" id="L5347">        <span class="tok-comment">/// don't count in host</span></span>
<span class="line" id="L5348">        exclude_host: <span class="tok-type">bool</span> = <span class="tok-null">false</span>,</span>
<span class="line" id="L5349">        <span class="tok-comment">/// don't count in guest</span></span>
<span class="line" id="L5350">        exclude_guest: <span class="tok-type">bool</span> = <span class="tok-null">false</span>,</span>
<span class="line" id="L5351"></span>
<span class="line" id="L5352">        <span class="tok-comment">/// exclude kernel callchains</span></span>
<span class="line" id="L5353">        exclude_callchain_kernel: <span class="tok-type">bool</span> = <span class="tok-null">false</span>,</span>
<span class="line" id="L5354">        <span class="tok-comment">/// exclude user callchains</span></span>
<span class="line" id="L5355">        exclude_callchain_user: <span class="tok-type">bool</span> = <span class="tok-null">false</span>,</span>
<span class="line" id="L5356">        <span class="tok-comment">/// include mmap with inode data</span></span>
<span class="line" id="L5357">        mmap2: <span class="tok-type">bool</span> = <span class="tok-null">false</span>,</span>
<span class="line" id="L5358">        <span class="tok-comment">/// flag comm events that are due to an exec</span></span>
<span class="line" id="L5359">        comm_exec: <span class="tok-type">bool</span> = <span class="tok-null">false</span>,</span>
<span class="line" id="L5360">        <span class="tok-comment">/// use @clockid for time fields</span></span>
<span class="line" id="L5361">        use_clockid: <span class="tok-type">bool</span> = <span class="tok-null">false</span>,</span>
<span class="line" id="L5362">        <span class="tok-comment">/// context switch data</span></span>
<span class="line" id="L5363">        context_switch: <span class="tok-type">bool</span> = <span class="tok-null">false</span>,</span>
<span class="line" id="L5364">        <span class="tok-comment">/// Write ring buffer from end to beginning</span></span>
<span class="line" id="L5365">        write_backward: <span class="tok-type">bool</span> = <span class="tok-null">false</span>,</span>
<span class="line" id="L5366">        <span class="tok-comment">/// include namespaces data</span></span>
<span class="line" id="L5367">        namespaces: <span class="tok-type">bool</span> = <span class="tok-null">false</span>,</span>
<span class="line" id="L5368"></span>
<span class="line" id="L5369">        __reserved_1: <span class="tok-type">u35</span> = <span class="tok-number">0</span>,</span>
<span class="line" id="L5370">    } = .{},</span>
<span class="line" id="L5371">    <span class="tok-comment">/// wakeup every n events, or</span></span>
<span class="line" id="L5372">    <span class="tok-comment">/// bytes before wakeup</span></span>
<span class="line" id="L5373">    wakeup_events_or_watermark: <span class="tok-type">u32</span> = <span class="tok-number">0</span>,</span>
<span class="line" id="L5374"></span>
<span class="line" id="L5375">    bp_type: <span class="tok-type">u32</span> = <span class="tok-number">0</span>,</span>
<span class="line" id="L5376"></span>
<span class="line" id="L5377">    <span class="tok-comment">/// This field is also used for:</span></span>
<span class="line" id="L5378">    <span class="tok-comment">/// bp_addr</span></span>
<span class="line" id="L5379">    <span class="tok-comment">/// kprobe_func for perf_kprobe</span></span>
<span class="line" id="L5380">    <span class="tok-comment">/// uprobe_path for perf_uprobe</span></span>
<span class="line" id="L5381">    config1: <span class="tok-type">u64</span> = <span class="tok-number">0</span>,</span>
<span class="line" id="L5382">    <span class="tok-comment">/// This field is also used for:</span></span>
<span class="line" id="L5383">    <span class="tok-comment">/// bp_len</span></span>
<span class="line" id="L5384">    <span class="tok-comment">/// kprobe_addr when kprobe_func == null</span></span>
<span class="line" id="L5385">    <span class="tok-comment">/// probe_offset for perf_[k,u]probe</span></span>
<span class="line" id="L5386">    config2: <span class="tok-type">u64</span> = <span class="tok-number">0</span>,</span>
<span class="line" id="L5387"></span>
<span class="line" id="L5388">    <span class="tok-comment">/// enum perf_branch_sample_type</span></span>
<span class="line" id="L5389">    branch_sample_type: <span class="tok-type">u64</span> = <span class="tok-number">0</span>,</span>
<span class="line" id="L5390"></span>
<span class="line" id="L5391">    <span class="tok-comment">/// Defines set of user regs to dump on samples.</span></span>
<span class="line" id="L5392">    <span class="tok-comment">/// See asm/perf_regs.h for details.</span></span>
<span class="line" id="L5393">    sample_regs_user: <span class="tok-type">u64</span> = <span class="tok-number">0</span>,</span>
<span class="line" id="L5394"></span>
<span class="line" id="L5395">    <span class="tok-comment">/// Defines size of the user stack to dump on samples.</span></span>
<span class="line" id="L5396">    sample_stack_user: <span class="tok-type">u32</span> = <span class="tok-number">0</span>,</span>
<span class="line" id="L5397"></span>
<span class="line" id="L5398">    clockid: <span class="tok-type">i32</span> = <span class="tok-number">0</span>,</span>
<span class="line" id="L5399">    <span class="tok-comment">/// Defines set of regs to dump for each sample</span></span>
<span class="line" id="L5400">    <span class="tok-comment">/// state captured on:</span></span>
<span class="line" id="L5401">    <span class="tok-comment">///  - precise = 0: PMU interrupt</span></span>
<span class="line" id="L5402">    <span class="tok-comment">///  - precise &gt; 0: sampled instruction</span></span>
<span class="line" id="L5403">    <span class="tok-comment">///</span></span>
<span class="line" id="L5404">    <span class="tok-comment">/// See asm/perf_regs.h for details.</span></span>
<span class="line" id="L5405">    sample_regs_intr: <span class="tok-type">u64</span> = <span class="tok-number">0</span>,</span>
<span class="line" id="L5406"></span>
<span class="line" id="L5407">    <span class="tok-comment">/// Wakeup watermark for AUX area</span></span>
<span class="line" id="L5408">    aux_watermark: <span class="tok-type">u32</span> = <span class="tok-number">0</span>,</span>
<span class="line" id="L5409">    sample_max_stack: <span class="tok-type">u16</span> = <span class="tok-number">0</span>,</span>
<span class="line" id="L5410">    <span class="tok-comment">/// Align to u64</span></span>
<span class="line" id="L5411">    __reserved_2: <span class="tok-type">u16</span> = <span class="tok-number">0</span>,</span>
<span class="line" id="L5412">};</span>
<span class="line" id="L5413"></span>
<span class="line" id="L5414"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> PERF = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L5415">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> TYPE = <span class="tok-kw">enum</span>(<span class="tok-type">u32</span>) {</span>
<span class="line" id="L5416">        HARDWARE,</span>
<span class="line" id="L5417">        SOFTWARE,</span>
<span class="line" id="L5418">        TRACEPOINT,</span>
<span class="line" id="L5419">        HW_CACHE,</span>
<span class="line" id="L5420">        RAW,</span>
<span class="line" id="L5421">        BREAKPOINT,</span>
<span class="line" id="L5422">        MAX,</span>
<span class="line" id="L5423">    };</span>
<span class="line" id="L5424"></span>
<span class="line" id="L5425">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> COUNT = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L5426">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> HW = <span class="tok-kw">enum</span>(<span class="tok-type">u32</span>) {</span>
<span class="line" id="L5427">            CPU_CYCLES,</span>
<span class="line" id="L5428">            INSTRUCTIONS,</span>
<span class="line" id="L5429">            CACHE_REFERENCES,</span>
<span class="line" id="L5430">            CACHE_MISSES,</span>
<span class="line" id="L5431">            BRANCH_INSTRUCTIONS,</span>
<span class="line" id="L5432">            BRANCH_MISSES,</span>
<span class="line" id="L5433">            BUS_CYCLES,</span>
<span class="line" id="L5434">            STALLED_CYCLES_FRONTEND,</span>
<span class="line" id="L5435">            STALLED_CYCLES_BACKEND,</span>
<span class="line" id="L5436">            REF_CPU_CYCLES,</span>
<span class="line" id="L5437">            MAX,</span>
<span class="line" id="L5438"></span>
<span class="line" id="L5439">            <span class="tok-kw">pub</span> <span class="tok-kw">const</span> CACHE = <span class="tok-kw">enum</span>(<span class="tok-type">u32</span>) {</span>
<span class="line" id="L5440">                L1D,</span>
<span class="line" id="L5441">                L1I,</span>
<span class="line" id="L5442">                LL,</span>
<span class="line" id="L5443">                DTLB,</span>
<span class="line" id="L5444">                ITLB,</span>
<span class="line" id="L5445">                BPU,</span>
<span class="line" id="L5446">                NODE,</span>
<span class="line" id="L5447">                MAX,</span>
<span class="line" id="L5448"></span>
<span class="line" id="L5449">                <span class="tok-kw">pub</span> <span class="tok-kw">const</span> OP = <span class="tok-kw">enum</span>(<span class="tok-type">u32</span>) {</span>
<span class="line" id="L5450">                    READ,</span>
<span class="line" id="L5451">                    WRITE,</span>
<span class="line" id="L5452">                    PREFETCH,</span>
<span class="line" id="L5453">                    MAX,</span>
<span class="line" id="L5454">                };</span>
<span class="line" id="L5455"></span>
<span class="line" id="L5456">                <span class="tok-kw">pub</span> <span class="tok-kw">const</span> RESULT = <span class="tok-kw">enum</span>(<span class="tok-type">u32</span>) {</span>
<span class="line" id="L5457">                    ACCESS,</span>
<span class="line" id="L5458">                    MISS,</span>
<span class="line" id="L5459">                    MAX,</span>
<span class="line" id="L5460">                };</span>
<span class="line" id="L5461">            };</span>
<span class="line" id="L5462">        };</span>
<span class="line" id="L5463"></span>
<span class="line" id="L5464">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> SW = <span class="tok-kw">enum</span>(<span class="tok-type">u32</span>) {</span>
<span class="line" id="L5465">            CPU_CLOCK,</span>
<span class="line" id="L5466">            TASK_CLOCK,</span>
<span class="line" id="L5467">            PAGE_FAULTS,</span>
<span class="line" id="L5468">            CONTEXT_SWITCHES,</span>
<span class="line" id="L5469">            CPU_MIGRATIONS,</span>
<span class="line" id="L5470">            PAGE_FAULTS_MIN,</span>
<span class="line" id="L5471">            PAGE_FAULTS_MAJ,</span>
<span class="line" id="L5472">            ALIGNMENT_FAULTS,</span>
<span class="line" id="L5473">            EMULATION_FAULTS,</span>
<span class="line" id="L5474">            DUMMY,</span>
<span class="line" id="L5475">            BPF_OUTPUT,</span>
<span class="line" id="L5476">            MAX,</span>
<span class="line" id="L5477">        };</span>
<span class="line" id="L5478">    };</span>
<span class="line" id="L5479"></span>
<span class="line" id="L5480">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> SAMPLE = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L5481">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> IP = <span class="tok-number">1</span>;</span>
<span class="line" id="L5482">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> TID = <span class="tok-number">2</span>;</span>
<span class="line" id="L5483">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> TIME = <span class="tok-number">4</span>;</span>
<span class="line" id="L5484">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> ADDR = <span class="tok-number">8</span>;</span>
<span class="line" id="L5485">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> READ = <span class="tok-number">16</span>;</span>
<span class="line" id="L5486">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> CALLCHAIN = <span class="tok-number">32</span>;</span>
<span class="line" id="L5487">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> ID = <span class="tok-number">64</span>;</span>
<span class="line" id="L5488">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> CPU = <span class="tok-number">128</span>;</span>
<span class="line" id="L5489">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> PERIOD = <span class="tok-number">256</span>;</span>
<span class="line" id="L5490">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> STREAM_ID = <span class="tok-number">512</span>;</span>
<span class="line" id="L5491">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> RAW = <span class="tok-number">1024</span>;</span>
<span class="line" id="L5492">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> BRANCH_STACK = <span class="tok-number">2048</span>;</span>
<span class="line" id="L5493">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> REGS_USER = <span class="tok-number">4096</span>;</span>
<span class="line" id="L5494">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> STACK_USER = <span class="tok-number">8192</span>;</span>
<span class="line" id="L5495">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> WEIGHT = <span class="tok-number">16384</span>;</span>
<span class="line" id="L5496">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> DATA_SRC = <span class="tok-number">32768</span>;</span>
<span class="line" id="L5497">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> IDENTIFIER = <span class="tok-number">65536</span>;</span>
<span class="line" id="L5498">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> TRANSACTION = <span class="tok-number">131072</span>;</span>
<span class="line" id="L5499">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> REGS_INTR = <span class="tok-number">262144</span>;</span>
<span class="line" id="L5500">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> PHYS_ADDR = <span class="tok-number">524288</span>;</span>
<span class="line" id="L5501">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> MAX = <span class="tok-number">1048576</span>;</span>
<span class="line" id="L5502"></span>
<span class="line" id="L5503">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> BRANCH = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L5504">            <span class="tok-kw">pub</span> <span class="tok-kw">const</span> USER = <span class="tok-number">1</span> &lt;&lt; <span class="tok-number">0</span>;</span>
<span class="line" id="L5505">            <span class="tok-kw">pub</span> <span class="tok-kw">const</span> KERNEL = <span class="tok-number">1</span> &lt;&lt; <span class="tok-number">1</span>;</span>
<span class="line" id="L5506">            <span class="tok-kw">pub</span> <span class="tok-kw">const</span> HV = <span class="tok-number">1</span> &lt;&lt; <span class="tok-number">2</span>;</span>
<span class="line" id="L5507">            <span class="tok-kw">pub</span> <span class="tok-kw">const</span> ANY = <span class="tok-number">1</span> &lt;&lt; <span class="tok-number">3</span>;</span>
<span class="line" id="L5508">            <span class="tok-kw">pub</span> <span class="tok-kw">const</span> ANY_CALL = <span class="tok-number">1</span> &lt;&lt; <span class="tok-number">4</span>;</span>
<span class="line" id="L5509">            <span class="tok-kw">pub</span> <span class="tok-kw">const</span> ANY_RETURN = <span class="tok-number">1</span> &lt;&lt; <span class="tok-number">5</span>;</span>
<span class="line" id="L5510">            <span class="tok-kw">pub</span> <span class="tok-kw">const</span> IND_CALL = <span class="tok-number">1</span> &lt;&lt; <span class="tok-number">6</span>;</span>
<span class="line" id="L5511">            <span class="tok-kw">pub</span> <span class="tok-kw">const</span> ABORT_TX = <span class="tok-number">1</span> &lt;&lt; <span class="tok-number">7</span>;</span>
<span class="line" id="L5512">            <span class="tok-kw">pub</span> <span class="tok-kw">const</span> IN_TX = <span class="tok-number">1</span> &lt;&lt; <span class="tok-number">8</span>;</span>
<span class="line" id="L5513">            <span class="tok-kw">pub</span> <span class="tok-kw">const</span> NO_TX = <span class="tok-number">1</span> &lt;&lt; <span class="tok-number">9</span>;</span>
<span class="line" id="L5514">            <span class="tok-kw">pub</span> <span class="tok-kw">const</span> COND = <span class="tok-number">1</span> &lt;&lt; <span class="tok-number">10</span>;</span>
<span class="line" id="L5515">            <span class="tok-kw">pub</span> <span class="tok-kw">const</span> CALL_STACK = <span class="tok-number">1</span> &lt;&lt; <span class="tok-number">11</span>;</span>
<span class="line" id="L5516">            <span class="tok-kw">pub</span> <span class="tok-kw">const</span> IND_JUMP = <span class="tok-number">1</span> &lt;&lt; <span class="tok-number">12</span>;</span>
<span class="line" id="L5517">            <span class="tok-kw">pub</span> <span class="tok-kw">const</span> CALL = <span class="tok-number">1</span> &lt;&lt; <span class="tok-number">13</span>;</span>
<span class="line" id="L5518">            <span class="tok-kw">pub</span> <span class="tok-kw">const</span> NO_FLAGS = <span class="tok-number">1</span> &lt;&lt; <span class="tok-number">14</span>;</span>
<span class="line" id="L5519">            <span class="tok-kw">pub</span> <span class="tok-kw">const</span> NO_CYCLES = <span class="tok-number">1</span> &lt;&lt; <span class="tok-number">15</span>;</span>
<span class="line" id="L5520">            <span class="tok-kw">pub</span> <span class="tok-kw">const</span> TYPE_SAVE = <span class="tok-number">1</span> &lt;&lt; <span class="tok-number">16</span>;</span>
<span class="line" id="L5521">            <span class="tok-kw">pub</span> <span class="tok-kw">const</span> MAX = <span class="tok-number">1</span> &lt;&lt; <span class="tok-number">17</span>;</span>
<span class="line" id="L5522">        };</span>
<span class="line" id="L5523">    };</span>
<span class="line" id="L5524"></span>
<span class="line" id="L5525">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> FLAG = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L5526">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> FD_NO_GROUP = <span class="tok-number">1</span> &lt;&lt; <span class="tok-number">0</span>;</span>
<span class="line" id="L5527">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> FD_OUTPUT = <span class="tok-number">1</span> &lt;&lt; <span class="tok-number">1</span>;</span>
<span class="line" id="L5528">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> PID_CGROUP = <span class="tok-number">1</span> &lt;&lt; <span class="tok-number">2</span>;</span>
<span class="line" id="L5529">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> FD_CLOEXEC = <span class="tok-number">1</span> &lt;&lt; <span class="tok-number">3</span>;</span>
<span class="line" id="L5530">    };</span>
<span class="line" id="L5531"></span>
<span class="line" id="L5532">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> EVENT_IOC = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L5533">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> ENABLE = <span class="tok-number">9216</span>;</span>
<span class="line" id="L5534">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> DISABLE = <span class="tok-number">9217</span>;</span>
<span class="line" id="L5535">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> REFRESH = <span class="tok-number">9218</span>;</span>
<span class="line" id="L5536">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> RESET = <span class="tok-number">9219</span>;</span>
<span class="line" id="L5537">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> PERIOD = <span class="tok-number">1074275332</span>;</span>
<span class="line" id="L5538">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> SET_OUTPUT = <span class="tok-number">9221</span>;</span>
<span class="line" id="L5539">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> SET_FILTER = <span class="tok-number">1074275334</span>;</span>
<span class="line" id="L5540">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> SET_BPF = <span class="tok-number">1074013192</span>;</span>
<span class="line" id="L5541">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> PAUSE_OUTPUT = <span class="tok-number">1074013193</span>;</span>
<span class="line" id="L5542">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> QUERY_BPF = <span class="tok-number">3221758986</span>;</span>
<span class="line" id="L5543">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> MODIFY_ATTRIBUTES = <span class="tok-number">1074275339</span>;</span>
<span class="line" id="L5544">    };</span>
<span class="line" id="L5545"></span>
<span class="line" id="L5546">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> IOC_FLAG_GROUP = <span class="tok-number">1</span>;</span>
<span class="line" id="L5547">};</span>
<span class="line" id="L5548"></span>
<span class="line" id="L5549"><span class="tok-comment">// TODO: Add the rest of the AUDIT defines?</span>
</span>
<span class="line" id="L5550"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> AUDIT = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L5551">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> ARCH = <span class="tok-kw">enum</span>(<span class="tok-type">u32</span>) {</span>
<span class="line" id="L5552">        <span class="tok-kw">const</span> @&quot;64BIT&quot; = <span class="tok-number">0x80000000</span>;</span>
<span class="line" id="L5553">        <span class="tok-kw">const</span> LE = <span class="tok-number">0x40000000</span>;</span>
<span class="line" id="L5554"></span>
<span class="line" id="L5555">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> current: AUDIT.ARCH = <span class="tok-kw">switch</span> (native_arch) {</span>
<span class="line" id="L5556">            .<span class="tok-type">i386</span> =&gt; .I386,</span>
<span class="line" id="L5557">            .x86_64 =&gt; .X86_64,</span>
<span class="line" id="L5558">            .aarch64 =&gt; .AARCH64,</span>
<span class="line" id="L5559">            .arm, .thumb =&gt; .ARM,</span>
<span class="line" id="L5560">            .riscv64 =&gt; .RISCV64,</span>
<span class="line" id="L5561">            .sparc64 =&gt; .SPARC64,</span>
<span class="line" id="L5562">            .mips =&gt; .MIPS,</span>
<span class="line" id="L5563">            .mipsel =&gt; .MIPSEL,</span>
<span class="line" id="L5564">            .powerpc =&gt; .PPC,</span>
<span class="line" id="L5565">            .powerpc64 =&gt; .PPC64,</span>
<span class="line" id="L5566">            .powerpc64le =&gt; .PPC64LE,</span>
<span class="line" id="L5567">            <span class="tok-kw">else</span> =&gt; <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;unsupported architecture&quot;</span>),</span>
<span class="line" id="L5568">        };</span>
<span class="line" id="L5569"></span>
<span class="line" id="L5570">        AARCH64 = toAudit(.aarch64),</span>
<span class="line" id="L5571">        ARM = toAudit(.arm),</span>
<span class="line" id="L5572">        ARMEB = toAudit(.armeb),</span>
<span class="line" id="L5573">        CSKY = toAudit(.csky),</span>
<span class="line" id="L5574">        HEXAGON = <span class="tok-builtin">@enumToInt</span>(std.elf.EM.HEXAGON),</span>
<span class="line" id="L5575">        I386 = toAudit(.<span class="tok-type">i386</span>),</span>
<span class="line" id="L5576">        M68K = toAudit(.m68k),</span>
<span class="line" id="L5577">        MIPS = toAudit(.mips),</span>
<span class="line" id="L5578">        MIPSEL = toAudit(.mips) | LE,</span>
<span class="line" id="L5579">        MIPS64 = toAudit(.mips64),</span>
<span class="line" id="L5580">        MIPSEL64 = toAudit(.mips64) | LE,</span>
<span class="line" id="L5581">        PPC = toAudit(.powerpc),</span>
<span class="line" id="L5582">        PPC64 = toAudit(.powerpc64),</span>
<span class="line" id="L5583">        PPC64LE = toAudit(.powerpc64le),</span>
<span class="line" id="L5584">        RISCV32 = toAudit(.riscv32),</span>
<span class="line" id="L5585">        RISCV64 = toAudit(.riscv64),</span>
<span class="line" id="L5586">        S390X = toAudit(.s390x),</span>
<span class="line" id="L5587">        SPARC = toAudit(.sparc),</span>
<span class="line" id="L5588">        SPARC64 = toAudit(.sparc64),</span>
<span class="line" id="L5589">        X86_64 = toAudit(.x86_64),</span>
<span class="line" id="L5590"></span>
<span class="line" id="L5591">        <span class="tok-kw">fn</span> <span class="tok-fn">toAudit</span>(arch: std.Target.Cpu.Arch) <span class="tok-type">u32</span> {</span>
<span class="line" id="L5592">            <span class="tok-kw">var</span> res: <span class="tok-type">u32</span> = <span class="tok-builtin">@enumToInt</span>(arch.toElfMachine());</span>
<span class="line" id="L5593">            <span class="tok-kw">if</span> (arch.endian() == .Little) res |= LE;</span>
<span class="line" id="L5594">            <span class="tok-kw">if</span> (arch.ptrBitWidth() == <span class="tok-number">64</span>) res |= @&quot;64BIT&quot;;</span>
<span class="line" id="L5595"></span>
<span class="line" id="L5596">            <span class="tok-kw">return</span> res;</span>
<span class="line" id="L5597">        }</span>
<span class="line" id="L5598">    };</span>
<span class="line" id="L5599">};</span>
<span class="line" id="L5600"></span>
</code></pre></body>
</html>