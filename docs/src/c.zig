<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">    <title>c.zig - source view</title>
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
<span class="line" id="L3"><span class="tok-kw">const</span> c = <span class="tok-builtin">@This</span>();</span>
<span class="line" id="L4"><span class="tok-kw">const</span> page_size = std.mem.page_size;</span>
<span class="line" id="L5"><span class="tok-kw">const</span> iovec = std.os.iovec;</span>
<span class="line" id="L6"><span class="tok-kw">const</span> iovec_const = std.os.iovec_const;</span>
<span class="line" id="L7"></span>
<span class="line" id="L8"><span class="tok-kw">test</span> {</span>
<span class="line" id="L9">    _ = tokenizer;</span>
<span class="line" id="L10">}</span>
<span class="line" id="L11"></span>
<span class="line" id="L12"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> tokenizer = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;c/tokenizer.zig&quot;</span>);</span>
<span class="line" id="L13"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> Token = tokenizer.Token;</span>
<span class="line" id="L14"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> Tokenizer = tokenizer.Tokenizer;</span>
<span class="line" id="L15"></span>
<span class="line" id="L16"><span class="tok-comment">/// The return type is `type` to force comptime function call execution.</span></span>
<span class="line" id="L17"><span class="tok-comment">/// TODO: https://github.com/ziglang/zig/issues/425</span></span>
<span class="line" id="L18"><span class="tok-comment">/// If not linking libc, returns struct{pub const ok = false;}</span></span>
<span class="line" id="L19"><span class="tok-comment">/// If linking musl libc, returns struct{pub const ok = true;}</span></span>
<span class="line" id="L20"><span class="tok-comment">/// If linking gnu libc (glibc), the `ok` value will be true if the target</span></span>
<span class="line" id="L21"><span class="tok-comment">/// version is greater than or equal to `glibc_version`.</span></span>
<span class="line" id="L22"><span class="tok-comment">/// If linking a libc other than these, returns `false`.</span></span>
<span class="line" id="L23"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">versionCheck</span>(glibc_version: std.builtin.Version) <span class="tok-type">type</span> {</span>
<span class="line" id="L24">    <span class="tok-kw">return</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L25">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> ok = blk: {</span>
<span class="line" id="L26">            <span class="tok-kw">if</span> (!builtin.link_libc) <span class="tok-kw">break</span> :blk <span class="tok-null">false</span>;</span>
<span class="line" id="L27">            <span class="tok-kw">if</span> (builtin.abi.isMusl()) <span class="tok-kw">break</span> :blk <span class="tok-null">true</span>;</span>
<span class="line" id="L28">            <span class="tok-kw">if</span> (builtin.target.isGnuLibC()) {</span>
<span class="line" id="L29">                <span class="tok-kw">const</span> ver = builtin.os.version_range.linux.glibc;</span>
<span class="line" id="L30">                <span class="tok-kw">const</span> order = ver.order(glibc_version);</span>
<span class="line" id="L31">                <span class="tok-kw">break</span> :blk <span class="tok-kw">switch</span> (order) {</span>
<span class="line" id="L32">                    .gt, .eq =&gt; <span class="tok-null">true</span>,</span>
<span class="line" id="L33">                    .lt =&gt; <span class="tok-null">false</span>,</span>
<span class="line" id="L34">                };</span>
<span class="line" id="L35">            } <span class="tok-kw">else</span> {</span>
<span class="line" id="L36">                <span class="tok-kw">break</span> :blk <span class="tok-null">false</span>;</span>
<span class="line" id="L37">            }</span>
<span class="line" id="L38">        };</span>
<span class="line" id="L39">    };</span>
<span class="line" id="L40">}</span>
<span class="line" id="L41"></span>
<span class="line" id="L42"><span class="tok-kw">pub</span> <span class="tok-kw">usingnamespace</span> <span class="tok-kw">switch</span> (builtin.os.tag) {</span>
<span class="line" id="L43">    .linux =&gt; <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;c/linux.zig&quot;</span>),</span>
<span class="line" id="L44">    .windows =&gt; <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;c/windows.zig&quot;</span>),</span>
<span class="line" id="L45">    .macos, .ios, .tvos, .watchos =&gt; <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;c/darwin.zig&quot;</span>),</span>
<span class="line" id="L46">    .freebsd, .kfreebsd =&gt; <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;c/freebsd.zig&quot;</span>),</span>
<span class="line" id="L47">    .netbsd =&gt; <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;c/netbsd.zig&quot;</span>),</span>
<span class="line" id="L48">    .dragonfly =&gt; <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;c/dragonfly.zig&quot;</span>),</span>
<span class="line" id="L49">    .openbsd =&gt; <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;c/openbsd.zig&quot;</span>),</span>
<span class="line" id="L50">    .haiku =&gt; <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;c/haiku.zig&quot;</span>),</span>
<span class="line" id="L51">    .hermit =&gt; <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;c/hermit.zig&quot;</span>),</span>
<span class="line" id="L52">    .solaris =&gt; <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;c/solaris.zig&quot;</span>),</span>
<span class="line" id="L53">    .fuchsia =&gt; <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;c/fuchsia.zig&quot;</span>),</span>
<span class="line" id="L54">    .minix =&gt; <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;c/minix.zig&quot;</span>),</span>
<span class="line" id="L55">    .emscripten =&gt; <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;c/emscripten.zig&quot;</span>),</span>
<span class="line" id="L56">    .wasi =&gt; <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;c/wasi.zig&quot;</span>),</span>
<span class="line" id="L57">    <span class="tok-kw">else</span> =&gt; <span class="tok-kw">struct</span> {},</span>
<span class="line" id="L58">};</span>
<span class="line" id="L59"></span>
<span class="line" id="L60"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> whence_t = <span class="tok-kw">if</span> (builtin.os.tag == .wasi) std.os.wasi.whence_t <span class="tok-kw">else</span> <span class="tok-type">c_int</span>;</span>
<span class="line" id="L61"></span>
<span class="line" id="L62"><span class="tok-comment">// Unix-like systems</span>
</span>
<span class="line" id="L63"><span class="tok-kw">pub</span> <span class="tok-kw">usingnamespace</span> <span class="tok-kw">switch</span> (builtin.os.tag) {</span>
<span class="line" id="L64">    .netbsd, .windows =&gt; <span class="tok-kw">struct</span> {},</span>
<span class="line" id="L65">    <span class="tok-kw">else</span> =&gt; <span class="tok-kw">struct</span> {</span>
<span class="line" id="L66">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> DIR = <span class="tok-kw">opaque</span> {};</span>
<span class="line" id="L67">        <span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;c&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">opendir</span>(pathname: [*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span>) ?*DIR;</span>
<span class="line" id="L68">        <span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;c&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">fdopendir</span>(fd: <span class="tok-type">c_int</span>) ?*DIR;</span>
<span class="line" id="L69">        <span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;c&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">rewinddir</span>(dp: *DIR) <span class="tok-type">void</span>;</span>
<span class="line" id="L70">        <span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;c&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">closedir</span>(dp: *DIR) <span class="tok-type">c_int</span>;</span>
<span class="line" id="L71">        <span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;c&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">telldir</span>(dp: *DIR) <span class="tok-type">c_long</span>;</span>
<span class="line" id="L72">        <span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;c&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">seekdir</span>(dp: *DIR, loc: <span class="tok-type">c_long</span>) <span class="tok-type">void</span>;</span>
<span class="line" id="L73"></span>
<span class="line" id="L74">        <span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;c&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">clock_gettime</span>(clk_id: <span class="tok-type">c_int</span>, tp: *c.timespec) <span class="tok-type">c_int</span>;</span>
<span class="line" id="L75">        <span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;c&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">clock_getres</span>(clk_id: <span class="tok-type">c_int</span>, tp: *c.timespec) <span class="tok-type">c_int</span>;</span>
<span class="line" id="L76">        <span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;c&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">gettimeofday</span>(<span class="tok-kw">noalias</span> tv: ?*c.timeval, <span class="tok-kw">noalias</span> tz: ?*c.timezone) <span class="tok-type">c_int</span>;</span>
<span class="line" id="L77">        <span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;c&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">nanosleep</span>(rqtp: *<span class="tok-kw">const</span> c.timespec, rmtp: ?*c.timespec) <span class="tok-type">c_int</span>;</span>
<span class="line" id="L78"></span>
<span class="line" id="L79">        <span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;c&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">getrusage</span>(who: <span class="tok-type">c_int</span>, usage: *c.rusage) <span class="tok-type">c_int</span>;</span>
<span class="line" id="L80"></span>
<span class="line" id="L81">        <span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;c&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">sched_yield</span>() <span class="tok-type">c_int</span>;</span>
<span class="line" id="L82"></span>
<span class="line" id="L83">        <span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;c&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">sigaction</span>(sig: <span class="tok-type">c_int</span>, <span class="tok-kw">noalias</span> act: ?*<span class="tok-kw">const</span> c.Sigaction, <span class="tok-kw">noalias</span> oact: ?*c.Sigaction) <span class="tok-type">c_int</span>;</span>
<span class="line" id="L84">        <span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;c&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">sigprocmask</span>(how: <span class="tok-type">c_int</span>, <span class="tok-kw">noalias</span> set: ?*<span class="tok-kw">const</span> c.sigset_t, <span class="tok-kw">noalias</span> oset: ?*c.sigset_t) <span class="tok-type">c_int</span>;</span>
<span class="line" id="L85">        <span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;c&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">sigfillset</span>(set: ?*c.sigset_t) <span class="tok-type">void</span>;</span>
<span class="line" id="L86">        <span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;c&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">sigwait</span>(set: ?*c.sigset_t, sig: ?*<span class="tok-type">c_int</span>) <span class="tok-type">c_int</span>;</span>
<span class="line" id="L87"></span>
<span class="line" id="L88">        <span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;c&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">socket</span>(domain: <span class="tok-type">c_uint</span>, sock_type: <span class="tok-type">c_uint</span>, protocol: <span class="tok-type">c_uint</span>) <span class="tok-type">c_int</span>;</span>
<span class="line" id="L89"></span>
<span class="line" id="L90">        <span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;c&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">stat</span>(<span class="tok-kw">noalias</span> path: [*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span>, <span class="tok-kw">noalias</span> buf: *c.Stat) <span class="tok-type">c_int</span>;</span>
<span class="line" id="L91"></span>
<span class="line" id="L92">        <span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;c&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">alarm</span>(seconds: <span class="tok-type">c_uint</span>) <span class="tok-type">c_uint</span>;</span>
<span class="line" id="L93">    },</span>
<span class="line" id="L94">};</span>
<span class="line" id="L95"></span>
<span class="line" id="L96"><span class="tok-kw">pub</span> <span class="tok-kw">usingnamespace</span> <span class="tok-kw">switch</span> (builtin.os.tag) {</span>
<span class="line" id="L97">    .netbsd, .macos, .ios, .watchos, .tvos, .windows =&gt; <span class="tok-kw">struct</span> {},</span>
<span class="line" id="L98">    <span class="tok-kw">else</span> =&gt; <span class="tok-kw">struct</span> {</span>
<span class="line" id="L99">        <span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;c&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">fstat</span>(fd: c.fd_t, buf: *c.Stat) <span class="tok-type">c_int</span>;</span>
<span class="line" id="L100">        <span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;c&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">readdir</span>(dp: *c.DIR) ?*c.dirent;</span>
<span class="line" id="L101">    },</span>
<span class="line" id="L102">};</span>
<span class="line" id="L103"></span>
<span class="line" id="L104"><span class="tok-kw">pub</span> <span class="tok-kw">usingnamespace</span> <span class="tok-kw">switch</span> (builtin.os.tag) {</span>
<span class="line" id="L105">    .macos, .ios, .watchos, .tvos =&gt; <span class="tok-kw">struct</span> {},</span>
<span class="line" id="L106">    <span class="tok-kw">else</span> =&gt; <span class="tok-kw">struct</span> {</span>
<span class="line" id="L107">        <span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;c&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">realpath</span>(<span class="tok-kw">noalias</span> file_name: [*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span>, <span class="tok-kw">noalias</span> resolved_name: [*]<span class="tok-type">u8</span>) ?[*:<span class="tok-number">0</span>]<span class="tok-type">u8</span>;</span>
<span class="line" id="L108">        <span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;c&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">fstatat</span>(dirfd: c.fd_t, path: [*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span>, stat_buf: *c.Stat, flags: <span class="tok-type">u32</span>) <span class="tok-type">c_int</span>;</span>
<span class="line" id="L109">    },</span>
<span class="line" id="L110">};</span>
<span class="line" id="L111"></span>
<span class="line" id="L112"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">getErrno</span>(rc: <span class="tok-kw">anytype</span>) c.E {</span>
<span class="line" id="L113">    <span class="tok-kw">if</span> (rc == -<span class="tok-number">1</span>) {</span>
<span class="line" id="L114">        <span class="tok-kw">return</span> <span class="tok-builtin">@intToEnum</span>(c.E, c._errno().*);</span>
<span class="line" id="L115">    } <span class="tok-kw">else</span> {</span>
<span class="line" id="L116">        <span class="tok-kw">return</span> .SUCCESS;</span>
<span class="line" id="L117">    }</span>
<span class="line" id="L118">}</span>
<span class="line" id="L119"></span>
<span class="line" id="L120"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;c&quot;</span> <span class="tok-kw">var</span> environ: [*:<span class="tok-null">null</span>]?[*:<span class="tok-number">0</span>]<span class="tok-type">u8</span>;</span>
<span class="line" id="L121"></span>
<span class="line" id="L122"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;c&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">fopen</span>(<span class="tok-kw">noalias</span> filename: [*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span>, <span class="tok-kw">noalias</span> modes: [*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span>) ?*FILE;</span>
<span class="line" id="L123"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;c&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">fclose</span>(stream: *FILE) <span class="tok-type">c_int</span>;</span>
<span class="line" id="L124"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;c&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">fwrite</span>(<span class="tok-kw">noalias</span> ptr: [*]<span class="tok-kw">const</span> <span class="tok-type">u8</span>, size_of_type: <span class="tok-type">usize</span>, item_count: <span class="tok-type">usize</span>, <span class="tok-kw">noalias</span> stream: *FILE) <span class="tok-type">usize</span>;</span>
<span class="line" id="L125"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;c&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">fread</span>(<span class="tok-kw">noalias</span> ptr: [*]<span class="tok-type">u8</span>, size_of_type: <span class="tok-type">usize</span>, item_count: <span class="tok-type">usize</span>, <span class="tok-kw">noalias</span> stream: *FILE) <span class="tok-type">usize</span>;</span>
<span class="line" id="L126"></span>
<span class="line" id="L127"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;c&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">printf</span>(format: [*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span>, ...) <span class="tok-type">c_int</span>;</span>
<span class="line" id="L128"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;c&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">abort</span>() <span class="tok-type">noreturn</span>;</span>
<span class="line" id="L129"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;c&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">exit</span>(code: <span class="tok-type">c_int</span>) <span class="tok-type">noreturn</span>;</span>
<span class="line" id="L130"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;c&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">_exit</span>(code: <span class="tok-type">c_int</span>) <span class="tok-type">noreturn</span>;</span>
<span class="line" id="L131"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;c&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">isatty</span>(fd: c.fd_t) <span class="tok-type">c_int</span>;</span>
<span class="line" id="L132"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;c&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">close</span>(fd: c.fd_t) <span class="tok-type">c_int</span>;</span>
<span class="line" id="L133"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;c&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">lseek</span>(fd: c.fd_t, offset: c.off_t, whence: whence_t) c.off_t;</span>
<span class="line" id="L134"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;c&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">open</span>(path: [*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span>, oflag: <span class="tok-type">c_uint</span>, ...) <span class="tok-type">c_int</span>;</span>
<span class="line" id="L135"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;c&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">openat</span>(fd: <span class="tok-type">c_int</span>, path: [*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span>, oflag: <span class="tok-type">c_uint</span>, ...) <span class="tok-type">c_int</span>;</span>
<span class="line" id="L136"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;c&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">ftruncate</span>(fd: <span class="tok-type">c_int</span>, length: c.off_t) <span class="tok-type">c_int</span>;</span>
<span class="line" id="L137"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;c&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">raise</span>(sig: <span class="tok-type">c_int</span>) <span class="tok-type">c_int</span>;</span>
<span class="line" id="L138"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;c&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">read</span>(fd: c.fd_t, buf: [*]<span class="tok-type">u8</span>, nbyte: <span class="tok-type">usize</span>) <span class="tok-type">isize</span>;</span>
<span class="line" id="L139"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;c&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">readv</span>(fd: <span class="tok-type">c_int</span>, iov: [*]<span class="tok-kw">const</span> iovec, iovcnt: <span class="tok-type">c_uint</span>) <span class="tok-type">isize</span>;</span>
<span class="line" id="L140"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;c&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">pread</span>(fd: c.fd_t, buf: [*]<span class="tok-type">u8</span>, nbyte: <span class="tok-type">usize</span>, offset: c.off_t) <span class="tok-type">isize</span>;</span>
<span class="line" id="L141"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;c&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">preadv</span>(fd: <span class="tok-type">c_int</span>, iov: [*]<span class="tok-kw">const</span> iovec, iovcnt: <span class="tok-type">c_uint</span>, offset: c.off_t) <span class="tok-type">isize</span>;</span>
<span class="line" id="L142"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;c&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">writev</span>(fd: <span class="tok-type">c_int</span>, iov: [*]<span class="tok-kw">const</span> iovec_const, iovcnt: <span class="tok-type">c_uint</span>) <span class="tok-type">isize</span>;</span>
<span class="line" id="L143"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;c&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">pwritev</span>(fd: <span class="tok-type">c_int</span>, iov: [*]<span class="tok-kw">const</span> iovec_const, iovcnt: <span class="tok-type">c_uint</span>, offset: c.off_t) <span class="tok-type">isize</span>;</span>
<span class="line" id="L144"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;c&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">write</span>(fd: c.fd_t, buf: [*]<span class="tok-kw">const</span> <span class="tok-type">u8</span>, nbyte: <span class="tok-type">usize</span>) <span class="tok-type">isize</span>;</span>
<span class="line" id="L145"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;c&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">pwrite</span>(fd: c.fd_t, buf: [*]<span class="tok-kw">const</span> <span class="tok-type">u8</span>, nbyte: <span class="tok-type">usize</span>, offset: c.off_t) <span class="tok-type">isize</span>;</span>
<span class="line" id="L146"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;c&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">mmap</span>(addr: ?*<span class="tok-kw">align</span>(page_size) <span class="tok-type">anyopaque</span>, len: <span class="tok-type">usize</span>, prot: <span class="tok-type">c_uint</span>, flags: <span class="tok-type">c_uint</span>, fd: c.fd_t, offset: c.off_t) *<span class="tok-type">anyopaque</span>;</span>
<span class="line" id="L147"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;c&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">munmap</span>(addr: *<span class="tok-kw">align</span>(page_size) <span class="tok-kw">const</span> <span class="tok-type">anyopaque</span>, len: <span class="tok-type">usize</span>) <span class="tok-type">c_int</span>;</span>
<span class="line" id="L148"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;c&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">msync</span>(addr: *<span class="tok-kw">align</span>(page_size) <span class="tok-kw">const</span> <span class="tok-type">anyopaque</span>, len: <span class="tok-type">usize</span>, flags: <span class="tok-type">c_int</span>) <span class="tok-type">c_int</span>;</span>
<span class="line" id="L149"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;c&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">mprotect</span>(addr: *<span class="tok-kw">align</span>(page_size) <span class="tok-type">anyopaque</span>, len: <span class="tok-type">usize</span>, prot: <span class="tok-type">c_uint</span>) <span class="tok-type">c_int</span>;</span>
<span class="line" id="L150"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;c&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">link</span>(oldpath: [*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span>, newpath: [*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span>, flags: <span class="tok-type">c_int</span>) <span class="tok-type">c_int</span>;</span>
<span class="line" id="L151"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;c&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">linkat</span>(oldfd: c.fd_t, oldpath: [*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span>, newfd: c.fd_t, newpath: [*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span>, flags: <span class="tok-type">c_int</span>) <span class="tok-type">c_int</span>;</span>
<span class="line" id="L152"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;c&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">unlink</span>(path: [*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span>) <span class="tok-type">c_int</span>;</span>
<span class="line" id="L153"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;c&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">unlinkat</span>(dirfd: c.fd_t, path: [*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span>, flags: <span class="tok-type">c_uint</span>) <span class="tok-type">c_int</span>;</span>
<span class="line" id="L154"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;c&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">getcwd</span>(buf: [*]<span class="tok-type">u8</span>, size: <span class="tok-type">usize</span>) ?[*]<span class="tok-type">u8</span>;</span>
<span class="line" id="L155"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;c&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">waitpid</span>(pid: c.pid_t, stat_loc: ?*<span class="tok-type">c_int</span>, options: <span class="tok-type">c_int</span>) c.pid_t;</span>
<span class="line" id="L156"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;c&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">fork</span>() <span class="tok-type">c_int</span>;</span>
<span class="line" id="L157"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;c&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">access</span>(path: [*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span>, mode: <span class="tok-type">c_uint</span>) <span class="tok-type">c_int</span>;</span>
<span class="line" id="L158"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;c&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">faccessat</span>(dirfd: c.fd_t, path: [*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span>, mode: <span class="tok-type">c_uint</span>, flags: <span class="tok-type">c_uint</span>) <span class="tok-type">c_int</span>;</span>
<span class="line" id="L159"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;c&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">pipe</span>(fds: *[<span class="tok-number">2</span>]c.fd_t) <span class="tok-type">c_int</span>;</span>
<span class="line" id="L160"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;c&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">mkdir</span>(path: [*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span>, mode: <span class="tok-type">c_uint</span>) <span class="tok-type">c_int</span>;</span>
<span class="line" id="L161"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;c&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">mkdirat</span>(dirfd: c.fd_t, path: [*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span>, mode: <span class="tok-type">u32</span>) <span class="tok-type">c_int</span>;</span>
<span class="line" id="L162"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;c&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">symlink</span>(existing: [*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span>, new: [*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span>) <span class="tok-type">c_int</span>;</span>
<span class="line" id="L163"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;c&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">symlinkat</span>(oldpath: [*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span>, newdirfd: c.fd_t, newpath: [*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span>) <span class="tok-type">c_int</span>;</span>
<span class="line" id="L164"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;c&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">rename</span>(old: [*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span>, new: [*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span>) <span class="tok-type">c_int</span>;</span>
<span class="line" id="L165"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;c&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">renameat</span>(olddirfd: c.fd_t, old: [*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span>, newdirfd: c.fd_t, new: [*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span>) <span class="tok-type">c_int</span>;</span>
<span class="line" id="L166"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;c&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">chdir</span>(path: [*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span>) <span class="tok-type">c_int</span>;</span>
<span class="line" id="L167"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;c&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">fchdir</span>(fd: c.fd_t) <span class="tok-type">c_int</span>;</span>
<span class="line" id="L168"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;c&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">execve</span>(path: [*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span>, argv: [*:<span class="tok-null">null</span>]<span class="tok-kw">const</span> ?[*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span>, envp: [*:<span class="tok-null">null</span>]<span class="tok-kw">const</span> ?[*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span>) <span class="tok-type">c_int</span>;</span>
<span class="line" id="L169"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;c&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">dup</span>(fd: c.fd_t) <span class="tok-type">c_int</span>;</span>
<span class="line" id="L170"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;c&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">dup2</span>(old_fd: c.fd_t, new_fd: c.fd_t) <span class="tok-type">c_int</span>;</span>
<span class="line" id="L171"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;c&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">readlink</span>(<span class="tok-kw">noalias</span> path: [*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span>, <span class="tok-kw">noalias</span> buf: [*]<span class="tok-type">u8</span>, bufsize: <span class="tok-type">usize</span>) <span class="tok-type">isize</span>;</span>
<span class="line" id="L172"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;c&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">readlinkat</span>(dirfd: c.fd_t, <span class="tok-kw">noalias</span> path: [*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span>, <span class="tok-kw">noalias</span> buf: [*]<span class="tok-type">u8</span>, bufsize: <span class="tok-type">usize</span>) <span class="tok-type">isize</span>;</span>
<span class="line" id="L173"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;c&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">fchmod</span>(fd: c.fd_t, mode: c.mode_t) <span class="tok-type">c_int</span>;</span>
<span class="line" id="L174"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;c&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">fchown</span>(fd: c.fd_t, owner: c.uid_t, group: c.gid_t) <span class="tok-type">c_int</span>;</span>
<span class="line" id="L175"></span>
<span class="line" id="L176"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;c&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">rmdir</span>(path: [*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span>) <span class="tok-type">c_int</span>;</span>
<span class="line" id="L177"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;c&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">getenv</span>(name: [*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span>) ?[*:<span class="tok-number">0</span>]<span class="tok-type">u8</span>;</span>
<span class="line" id="L178"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;c&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">sysctl</span>(name: [*]<span class="tok-kw">const</span> <span class="tok-type">c_int</span>, namelen: <span class="tok-type">c_uint</span>, oldp: ?*<span class="tok-type">anyopaque</span>, oldlenp: ?*<span class="tok-type">usize</span>, newp: ?*<span class="tok-type">anyopaque</span>, newlen: <span class="tok-type">usize</span>) <span class="tok-type">c_int</span>;</span>
<span class="line" id="L179"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;c&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">sysctlbyname</span>(name: [*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span>, oldp: ?*<span class="tok-type">anyopaque</span>, oldlenp: ?*<span class="tok-type">usize</span>, newp: ?*<span class="tok-type">anyopaque</span>, newlen: <span class="tok-type">usize</span>) <span class="tok-type">c_int</span>;</span>
<span class="line" id="L180"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;c&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">sysctlnametomib</span>(name: [*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span>, mibp: ?*<span class="tok-type">c_int</span>, sizep: ?*<span class="tok-type">usize</span>) <span class="tok-type">c_int</span>;</span>
<span class="line" id="L181"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;c&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">tcgetattr</span>(fd: c.fd_t, termios_p: *c.termios) <span class="tok-type">c_int</span>;</span>
<span class="line" id="L182"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;c&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">tcsetattr</span>(fd: c.fd_t, optional_action: c.TCSA, termios_p: *<span class="tok-kw">const</span> c.termios) <span class="tok-type">c_int</span>;</span>
<span class="line" id="L183"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;c&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">fcntl</span>(fd: c.fd_t, cmd: <span class="tok-type">c_int</span>, ...) <span class="tok-type">c_int</span>;</span>
<span class="line" id="L184"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;c&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">flock</span>(fd: c.fd_t, operation: <span class="tok-type">c_int</span>) <span class="tok-type">c_int</span>;</span>
<span class="line" id="L185"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;c&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">ioctl</span>(fd: c.fd_t, request: <span class="tok-type">c_int</span>, ...) <span class="tok-type">c_int</span>;</span>
<span class="line" id="L186"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;c&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">uname</span>(buf: *c.utsname) <span class="tok-type">c_int</span>;</span>
<span class="line" id="L187"></span>
<span class="line" id="L188"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;c&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">gethostname</span>(name: [*]<span class="tok-type">u8</span>, len: <span class="tok-type">usize</span>) <span class="tok-type">c_int</span>;</span>
<span class="line" id="L189"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;c&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">shutdown</span>(socket: c.fd_t, how: <span class="tok-type">c_int</span>) <span class="tok-type">c_int</span>;</span>
<span class="line" id="L190"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;c&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">bind</span>(socket: c.fd_t, address: ?*<span class="tok-kw">const</span> c.sockaddr, address_len: c.socklen_t) <span class="tok-type">c_int</span>;</span>
<span class="line" id="L191"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;c&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">socketpair</span>(domain: <span class="tok-type">c_uint</span>, sock_type: <span class="tok-type">c_uint</span>, protocol: <span class="tok-type">c_uint</span>, sv: *[<span class="tok-number">2</span>]c.fd_t) <span class="tok-type">c_int</span>;</span>
<span class="line" id="L192"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;c&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">listen</span>(sockfd: c.fd_t, backlog: <span class="tok-type">c_uint</span>) <span class="tok-type">c_int</span>;</span>
<span class="line" id="L193"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;c&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">getsockname</span>(sockfd: c.fd_t, <span class="tok-kw">noalias</span> addr: *c.sockaddr, <span class="tok-kw">noalias</span> addrlen: *c.socklen_t) <span class="tok-type">c_int</span>;</span>
<span class="line" id="L194"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;c&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">getpeername</span>(sockfd: c.fd_t, <span class="tok-kw">noalias</span> addr: *c.sockaddr, <span class="tok-kw">noalias</span> addrlen: *c.socklen_t) <span class="tok-type">c_int</span>;</span>
<span class="line" id="L195"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;c&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">connect</span>(sockfd: c.fd_t, sock_addr: *<span class="tok-kw">const</span> c.sockaddr, addrlen: c.socklen_t) <span class="tok-type">c_int</span>;</span>
<span class="line" id="L196"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;c&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">accept</span>(sockfd: c.fd_t, <span class="tok-kw">noalias</span> addr: ?*c.sockaddr, <span class="tok-kw">noalias</span> addrlen: ?*c.socklen_t) <span class="tok-type">c_int</span>;</span>
<span class="line" id="L197"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;c&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">accept4</span>(sockfd: c.fd_t, <span class="tok-kw">noalias</span> addr: ?*c.sockaddr, <span class="tok-kw">noalias</span> addrlen: ?*c.socklen_t, flags: <span class="tok-type">c_uint</span>) <span class="tok-type">c_int</span>;</span>
<span class="line" id="L198"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;c&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">getsockopt</span>(sockfd: c.fd_t, level: <span class="tok-type">u32</span>, optname: <span class="tok-type">u32</span>, <span class="tok-kw">noalias</span> optval: ?*<span class="tok-type">anyopaque</span>, <span class="tok-kw">noalias</span> optlen: *c.socklen_t) <span class="tok-type">c_int</span>;</span>
<span class="line" id="L199"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;c&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">setsockopt</span>(sockfd: c.fd_t, level: <span class="tok-type">u32</span>, optname: <span class="tok-type">u32</span>, optval: ?*<span class="tok-kw">const</span> <span class="tok-type">anyopaque</span>, optlen: c.socklen_t) <span class="tok-type">c_int</span>;</span>
<span class="line" id="L200"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;c&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">send</span>(sockfd: c.fd_t, buf: *<span class="tok-kw">const</span> <span class="tok-type">anyopaque</span>, len: <span class="tok-type">usize</span>, flags: <span class="tok-type">u32</span>) <span class="tok-type">isize</span>;</span>
<span class="line" id="L201"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;c&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">sendto</span>(</span>
<span class="line" id="L202">    sockfd: c.fd_t,</span>
<span class="line" id="L203">    buf: *<span class="tok-kw">const</span> <span class="tok-type">anyopaque</span>,</span>
<span class="line" id="L204">    len: <span class="tok-type">usize</span>,</span>
<span class="line" id="L205">    flags: <span class="tok-type">u32</span>,</span>
<span class="line" id="L206">    dest_addr: ?*<span class="tok-kw">const</span> c.sockaddr,</span>
<span class="line" id="L207">    addrlen: c.socklen_t,</span>
<span class="line" id="L208">) <span class="tok-type">isize</span>;</span>
<span class="line" id="L209"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;c&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">sendmsg</span>(sockfd: c.fd_t, msg: *<span class="tok-kw">const</span> std.x.os.Socket.Message, flags: <span class="tok-type">c_int</span>) <span class="tok-type">isize</span>;</span>
<span class="line" id="L210"></span>
<span class="line" id="L211"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;c&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">recv</span>(sockfd: c.fd_t, arg1: ?*<span class="tok-type">anyopaque</span>, arg2: <span class="tok-type">usize</span>, arg3: <span class="tok-type">c_int</span>) <span class="tok-type">isize</span>;</span>
<span class="line" id="L212"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;c&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">recvfrom</span>(</span>
<span class="line" id="L213">    sockfd: c.fd_t,</span>
<span class="line" id="L214">    <span class="tok-kw">noalias</span> buf: *<span class="tok-type">anyopaque</span>,</span>
<span class="line" id="L215">    len: <span class="tok-type">usize</span>,</span>
<span class="line" id="L216">    flags: <span class="tok-type">u32</span>,</span>
<span class="line" id="L217">    <span class="tok-kw">noalias</span> src_addr: ?*c.sockaddr,</span>
<span class="line" id="L218">    <span class="tok-kw">noalias</span> addrlen: ?*c.socklen_t,</span>
<span class="line" id="L219">) <span class="tok-type">isize</span>;</span>
<span class="line" id="L220"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;c&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">recvmsg</span>(sockfd: c.fd_t, msg: *std.x.os.Socket.Message, flags: <span class="tok-type">c_int</span>) <span class="tok-type">isize</span>;</span>
<span class="line" id="L221"></span>
<span class="line" id="L222"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;c&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">kill</span>(pid: c.pid_t, sig: <span class="tok-type">c_int</span>) <span class="tok-type">c_int</span>;</span>
<span class="line" id="L223"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;c&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">getdirentries</span>(fd: c.fd_t, buf_ptr: [*]<span class="tok-type">u8</span>, nbytes: <span class="tok-type">usize</span>, basep: *<span class="tok-type">i64</span>) <span class="tok-type">isize</span>;</span>
<span class="line" id="L224"></span>
<span class="line" id="L225"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;c&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">setuid</span>(uid: c.uid_t) <span class="tok-type">c_int</span>;</span>
<span class="line" id="L226"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;c&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">setgid</span>(gid: c.gid_t) <span class="tok-type">c_int</span>;</span>
<span class="line" id="L227"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;c&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">seteuid</span>(euid: c.uid_t) <span class="tok-type">c_int</span>;</span>
<span class="line" id="L228"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;c&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">setegid</span>(egid: c.gid_t) <span class="tok-type">c_int</span>;</span>
<span class="line" id="L229"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;c&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">setreuid</span>(ruid: c.uid_t, euid: c.uid_t) <span class="tok-type">c_int</span>;</span>
<span class="line" id="L230"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;c&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">setregid</span>(rgid: c.gid_t, egid: c.gid_t) <span class="tok-type">c_int</span>;</span>
<span class="line" id="L231"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;c&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">setresuid</span>(ruid: c.uid_t, euid: c.uid_t, suid: c.uid_t) <span class="tok-type">c_int</span>;</span>
<span class="line" id="L232"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;c&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">setresgid</span>(rgid: c.gid_t, egid: c.gid_t, sgid: c.gid_t) <span class="tok-type">c_int</span>;</span>
<span class="line" id="L233"></span>
<span class="line" id="L234"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;c&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">malloc</span>(<span class="tok-type">usize</span>) ?*<span class="tok-type">anyopaque</span>;</span>
<span class="line" id="L235"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;c&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">realloc</span>(?*<span class="tok-type">anyopaque</span>, <span class="tok-type">usize</span>) ?*<span class="tok-type">anyopaque</span>;</span>
<span class="line" id="L236"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;c&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">free</span>(?*<span class="tok-type">anyopaque</span>) <span class="tok-type">void</span>;</span>
<span class="line" id="L237"></span>
<span class="line" id="L238"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;c&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">futimes</span>(fd: c.fd_t, times: *[<span class="tok-number">2</span>]c.timeval) <span class="tok-type">c_int</span>;</span>
<span class="line" id="L239"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;c&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">utimes</span>(path: [*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span>, times: *[<span class="tok-number">2</span>]c.timeval) <span class="tok-type">c_int</span>;</span>
<span class="line" id="L240"></span>
<span class="line" id="L241"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;c&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">utimensat</span>(dirfd: c.fd_t, pathname: [*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span>, times: *[<span class="tok-number">2</span>]c.timespec, flags: <span class="tok-type">u32</span>) <span class="tok-type">c_int</span>;</span>
<span class="line" id="L242"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;c&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">futimens</span>(fd: c.fd_t, times: *<span class="tok-kw">const</span> [<span class="tok-number">2</span>]c.timespec) <span class="tok-type">c_int</span>;</span>
<span class="line" id="L243"></span>
<span class="line" id="L244"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;c&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">pthread_create</span>(<span class="tok-kw">noalias</span> newthread: *pthread_t, <span class="tok-kw">noalias</span> attr: ?*<span class="tok-kw">const</span> c.pthread_attr_t, start_routine: PThreadStartFn, <span class="tok-kw">noalias</span> arg: ?*<span class="tok-type">anyopaque</span>) c.E;</span>
<span class="line" id="L245"><span class="tok-kw">const</span> PThreadStartFn = <span class="tok-kw">if</span> (builtin.zig_backend == .stage1)</span>
<span class="line" id="L246">    <span class="tok-kw">fn</span> (?*<span class="tok-type">anyopaque</span>) <span class="tok-kw">callconv</span>(.C) ?*<span class="tok-type">anyopaque</span></span>
<span class="line" id="L247"><span class="tok-kw">else</span></span>
<span class="line" id="L248">    *<span class="tok-kw">const</span> <span class="tok-kw">fn</span> (?*<span class="tok-type">anyopaque</span>) <span class="tok-kw">callconv</span>(.C) ?*<span class="tok-type">anyopaque</span>;</span>
<span class="line" id="L249"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;c&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">pthread_attr_init</span>(attr: *c.pthread_attr_t) c.E;</span>
<span class="line" id="L250"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;c&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">pthread_attr_setstack</span>(attr: *c.pthread_attr_t, stackaddr: *<span class="tok-type">anyopaque</span>, stacksize: <span class="tok-type">usize</span>) c.E;</span>
<span class="line" id="L251"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;c&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">pthread_attr_setstacksize</span>(attr: *c.pthread_attr_t, stacksize: <span class="tok-type">usize</span>) c.E;</span>
<span class="line" id="L252"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;c&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">pthread_attr_setguardsize</span>(attr: *c.pthread_attr_t, guardsize: <span class="tok-type">usize</span>) c.E;</span>
<span class="line" id="L253"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;c&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">pthread_attr_destroy</span>(attr: *c.pthread_attr_t) c.E;</span>
<span class="line" id="L254"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;c&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">pthread_self</span>() pthread_t;</span>
<span class="line" id="L255"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;c&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">pthread_join</span>(thread: pthread_t, arg_return: ?*?*<span class="tok-type">anyopaque</span>) c.E;</span>
<span class="line" id="L256"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;c&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">pthread_detach</span>(thread: pthread_t) c.E;</span>
<span class="line" id="L257"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;c&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">pthread_atfork</span>(</span>
<span class="line" id="L258">    prepare: ?PThreadForkFn,</span>
<span class="line" id="L259">    parent: ?PThreadForkFn,</span>
<span class="line" id="L260">    child: ?PThreadForkFn,</span>
<span class="line" id="L261">) <span class="tok-type">c_int</span>;</span>
<span class="line" id="L262"><span class="tok-kw">const</span> PThreadForkFn = <span class="tok-kw">if</span> (builtin.zig_backend == .stage1)</span>
<span class="line" id="L263">    <span class="tok-kw">fn</span> () <span class="tok-kw">callconv</span>(.C) <span class="tok-type">void</span></span>
<span class="line" id="L264"><span class="tok-kw">else</span></span>
<span class="line" id="L265">    *<span class="tok-kw">const</span> <span class="tok-kw">fn</span> () <span class="tok-kw">callconv</span>(.C) <span class="tok-type">void</span>;</span>
<span class="line" id="L266"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;c&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">pthread_key_create</span>(key: *c.pthread_key_t, destructor: ?<span class="tok-kw">fn</span> (value: *<span class="tok-type">anyopaque</span>) <span class="tok-kw">callconv</span>(.C) <span class="tok-type">void</span>) c.E;</span>
<span class="line" id="L267"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;c&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">pthread_key_delete</span>(key: c.pthread_key_t) c.E;</span>
<span class="line" id="L268"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;c&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">pthread_getspecific</span>(key: c.pthread_key_t) ?*<span class="tok-type">anyopaque</span>;</span>
<span class="line" id="L269"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;c&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">pthread_setspecific</span>(key: c.pthread_key_t, value: ?*<span class="tok-type">anyopaque</span>) <span class="tok-type">c_int</span>;</span>
<span class="line" id="L270"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;c&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">sem_init</span>(sem: *c.sem_t, pshared: <span class="tok-type">c_int</span>, value: <span class="tok-type">c_uint</span>) <span class="tok-type">c_int</span>;</span>
<span class="line" id="L271"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;c&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">sem_destroy</span>(sem: *c.sem_t) <span class="tok-type">c_int</span>;</span>
<span class="line" id="L272"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;c&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">sem_open</span>(name: [*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span>, flag: <span class="tok-type">c_int</span>, mode: c.mode_t, value: <span class="tok-type">c_uint</span>) *c.sem_t;</span>
<span class="line" id="L273"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;c&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">sem_close</span>(sem: *c.sem_t) <span class="tok-type">c_int</span>;</span>
<span class="line" id="L274"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;c&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">sem_post</span>(sem: *c.sem_t) <span class="tok-type">c_int</span>;</span>
<span class="line" id="L275"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;c&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">sem_wait</span>(sem: *c.sem_t) <span class="tok-type">c_int</span>;</span>
<span class="line" id="L276"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;c&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">sem_trywait</span>(sem: *c.sem_t) <span class="tok-type">c_int</span>;</span>
<span class="line" id="L277"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;c&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">sem_timedwait</span>(sem: *c.sem_t, abs_timeout: *<span class="tok-kw">const</span> c.timespec) <span class="tok-type">c_int</span>;</span>
<span class="line" id="L278"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;c&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">sem_getvalue</span>(sem: *c.sem_t, sval: *<span class="tok-type">c_int</span>) <span class="tok-type">c_int</span>;</span>
<span class="line" id="L279"></span>
<span class="line" id="L280"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;c&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">shm_open</span>(name: [*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span>, flag: <span class="tok-type">c_int</span>, mode: c.mode_t) <span class="tok-type">c_int</span>;</span>
<span class="line" id="L281"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;c&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">shm_unlink</span>(name: [*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span>) <span class="tok-type">c_int</span>;</span>
<span class="line" id="L282"></span>
<span class="line" id="L283"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;c&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">kqueue</span>() <span class="tok-type">c_int</span>;</span>
<span class="line" id="L284"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;c&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">kevent</span>(</span>
<span class="line" id="L285">    kq: <span class="tok-type">c_int</span>,</span>
<span class="line" id="L286">    changelist: [*]<span class="tok-kw">const</span> c.Kevent,</span>
<span class="line" id="L287">    nchanges: <span class="tok-type">c_int</span>,</span>
<span class="line" id="L288">    eventlist: [*]c.Kevent,</span>
<span class="line" id="L289">    nevents: <span class="tok-type">c_int</span>,</span>
<span class="line" id="L290">    timeout: ?*<span class="tok-kw">const</span> c.timespec,</span>
<span class="line" id="L291">) <span class="tok-type">c_int</span>;</span>
<span class="line" id="L292"></span>
<span class="line" id="L293"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;c&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">port_create</span>() c.port_t;</span>
<span class="line" id="L294"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;c&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">port_associate</span>(</span>
<span class="line" id="L295">    port: c.port_t,</span>
<span class="line" id="L296">    source: <span class="tok-type">u32</span>,</span>
<span class="line" id="L297">    object: <span class="tok-type">usize</span>,</span>
<span class="line" id="L298">    events: <span class="tok-type">u32</span>,</span>
<span class="line" id="L299">    user_var: ?*<span class="tok-type">anyopaque</span>,</span>
<span class="line" id="L300">) <span class="tok-type">c_int</span>;</span>
<span class="line" id="L301"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;c&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">port_dissociate</span>(port: c.port_t, source: <span class="tok-type">u32</span>, object: <span class="tok-type">usize</span>) <span class="tok-type">c_int</span>;</span>
<span class="line" id="L302"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;c&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">port_send</span>(port: c.port_t, events: <span class="tok-type">u32</span>, user_var: ?*<span class="tok-type">anyopaque</span>) <span class="tok-type">c_int</span>;</span>
<span class="line" id="L303"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;c&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">port_sendn</span>(</span>
<span class="line" id="L304">    ports: [*]c.port_t,</span>
<span class="line" id="L305">    errors: []<span class="tok-type">u32</span>,</span>
<span class="line" id="L306">    num_ports: <span class="tok-type">u32</span>,</span>
<span class="line" id="L307">    events: <span class="tok-type">u32</span>,</span>
<span class="line" id="L308">    user_var: ?*<span class="tok-type">anyopaque</span>,</span>
<span class="line" id="L309">) <span class="tok-type">c_int</span>;</span>
<span class="line" id="L310"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;c&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">port_get</span>(port: c.port_t, event: *c.port_event, timeout: ?*c.timespec) <span class="tok-type">c_int</span>;</span>
<span class="line" id="L311"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;c&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">port_getn</span>(</span>
<span class="line" id="L312">    port: c.port_t,</span>
<span class="line" id="L313">    event_list: []c.port_event,</span>
<span class="line" id="L314">    max_events: <span class="tok-type">u32</span>,</span>
<span class="line" id="L315">    events_retrieved: *<span class="tok-type">u32</span>,</span>
<span class="line" id="L316">    timeout: ?*c.timespec,</span>
<span class="line" id="L317">) <span class="tok-type">c_int</span>;</span>
<span class="line" id="L318"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;c&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">port_alert</span>(port: c.port_t, flags: <span class="tok-type">u32</span>, events: <span class="tok-type">u32</span>, user_var: ?*<span class="tok-type">anyopaque</span>) <span class="tok-type">c_int</span>;</span>
<span class="line" id="L319"></span>
<span class="line" id="L320"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;c&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">getaddrinfo</span>(</span>
<span class="line" id="L321">    <span class="tok-kw">noalias</span> node: ?[*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L322">    <span class="tok-kw">noalias</span> service: ?[*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L323">    <span class="tok-kw">noalias</span> hints: ?*<span class="tok-kw">const</span> c.addrinfo,</span>
<span class="line" id="L324">    <span class="tok-kw">noalias</span> res: **c.addrinfo,</span>
<span class="line" id="L325">) c.EAI;</span>
<span class="line" id="L326"></span>
<span class="line" id="L327"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;c&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">freeaddrinfo</span>(res: *c.addrinfo) <span class="tok-type">void</span>;</span>
<span class="line" id="L328"></span>
<span class="line" id="L329"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;c&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">getnameinfo</span>(</span>
<span class="line" id="L330">    <span class="tok-kw">noalias</span> addr: *<span class="tok-kw">const</span> c.sockaddr,</span>
<span class="line" id="L331">    addrlen: c.socklen_t,</span>
<span class="line" id="L332">    <span class="tok-kw">noalias</span> host: [*]<span class="tok-type">u8</span>,</span>
<span class="line" id="L333">    hostlen: c.socklen_t,</span>
<span class="line" id="L334">    <span class="tok-kw">noalias</span> serv: [*]<span class="tok-type">u8</span>,</span>
<span class="line" id="L335">    servlen: c.socklen_t,</span>
<span class="line" id="L336">    flags: <span class="tok-type">u32</span>,</span>
<span class="line" id="L337">) c.EAI;</span>
<span class="line" id="L338"></span>
<span class="line" id="L339"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;c&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">gai_strerror</span>(errcode: c.EAI) [*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span>;</span>
<span class="line" id="L340"></span>
<span class="line" id="L341"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;c&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">poll</span>(fds: [*]c.pollfd, nfds: c.nfds_t, timeout: <span class="tok-type">c_int</span>) <span class="tok-type">c_int</span>;</span>
<span class="line" id="L342"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;c&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">ppoll</span>(fds: [*]c.pollfd, nfds: c.nfds_t, timeout: ?*<span class="tok-kw">const</span> c.timespec, sigmask: ?*<span class="tok-kw">const</span> c.sigset_t) <span class="tok-type">c_int</span>;</span>
<span class="line" id="L343"></span>
<span class="line" id="L344"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;c&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">dn_expand</span>(</span>
<span class="line" id="L345">    msg: [*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L346">    eomorig: [*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L347">    comp_dn: [*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L348">    exp_dn: [*:<span class="tok-number">0</span>]<span class="tok-type">u8</span>,</span>
<span class="line" id="L349">    length: <span class="tok-type">c_int</span>,</span>
<span class="line" id="L350">) <span class="tok-type">c_int</span>;</span>
<span class="line" id="L351"></span>
<span class="line" id="L352"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> PTHREAD_MUTEX_INITIALIZER = c.pthread_mutex_t{};</span>
<span class="line" id="L353"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;c&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">pthread_mutex_lock</span>(mutex: *c.pthread_mutex_t) c.E;</span>
<span class="line" id="L354"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;c&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">pthread_mutex_unlock</span>(mutex: *c.pthread_mutex_t) c.E;</span>
<span class="line" id="L355"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;c&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">pthread_mutex_trylock</span>(mutex: *c.pthread_mutex_t) c.E;</span>
<span class="line" id="L356"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;c&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">pthread_mutex_destroy</span>(mutex: *c.pthread_mutex_t) c.E;</span>
<span class="line" id="L357"></span>
<span class="line" id="L358"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> PTHREAD_COND_INITIALIZER = c.pthread_cond_t{};</span>
<span class="line" id="L359"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;c&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">pthread_cond_wait</span>(<span class="tok-kw">noalias</span> cond: *c.pthread_cond_t, <span class="tok-kw">noalias</span> mutex: *c.pthread_mutex_t) c.E;</span>
<span class="line" id="L360"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;c&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">pthread_cond_timedwait</span>(<span class="tok-kw">noalias</span> cond: *c.pthread_cond_t, <span class="tok-kw">noalias</span> mutex: *c.pthread_mutex_t, <span class="tok-kw">noalias</span> abstime: *<span class="tok-kw">const</span> c.timespec) c.E;</span>
<span class="line" id="L361"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;c&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">pthread_cond_signal</span>(cond: *c.pthread_cond_t) c.E;</span>
<span class="line" id="L362"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;c&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">pthread_cond_broadcast</span>(cond: *c.pthread_cond_t) c.E;</span>
<span class="line" id="L363"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;c&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">pthread_cond_destroy</span>(cond: *c.pthread_cond_t) c.E;</span>
<span class="line" id="L364"></span>
<span class="line" id="L365"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;c&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">pthread_rwlock_destroy</span>(rwl: *c.pthread_rwlock_t) <span class="tok-kw">callconv</span>(.C) c.E;</span>
<span class="line" id="L366"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;c&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">pthread_rwlock_rdlock</span>(rwl: *c.pthread_rwlock_t) <span class="tok-kw">callconv</span>(.C) c.E;</span>
<span class="line" id="L367"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;c&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">pthread_rwlock_wrlock</span>(rwl: *c.pthread_rwlock_t) <span class="tok-kw">callconv</span>(.C) c.E;</span>
<span class="line" id="L368"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;c&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">pthread_rwlock_tryrdlock</span>(rwl: *c.pthread_rwlock_t) <span class="tok-kw">callconv</span>(.C) c.E;</span>
<span class="line" id="L369"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;c&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">pthread_rwlock_trywrlock</span>(rwl: *c.pthread_rwlock_t) <span class="tok-kw">callconv</span>(.C) c.E;</span>
<span class="line" id="L370"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;c&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">pthread_rwlock_unlock</span>(rwl: *c.pthread_rwlock_t) <span class="tok-kw">callconv</span>(.C) c.E;</span>
<span class="line" id="L371"></span>
<span class="line" id="L372"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> pthread_t = *<span class="tok-kw">opaque</span> {};</span>
<span class="line" id="L373"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FILE = <span class="tok-kw">opaque</span> {};</span>
<span class="line" id="L374"></span>
<span class="line" id="L375"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;c&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">dlopen</span>(path: [*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span>, mode: <span class="tok-type">c_int</span>) ?*<span class="tok-type">anyopaque</span>;</span>
<span class="line" id="L376"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;c&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">dlclose</span>(handle: *<span class="tok-type">anyopaque</span>) <span class="tok-type">c_int</span>;</span>
<span class="line" id="L377"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;c&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">dlsym</span>(handle: ?*<span class="tok-type">anyopaque</span>, symbol: [*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span>) ?*<span class="tok-type">anyopaque</span>;</span>
<span class="line" id="L378"></span>
<span class="line" id="L379"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;c&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">sync</span>() <span class="tok-type">void</span>;</span>
<span class="line" id="L380"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;c&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">syncfs</span>(fd: <span class="tok-type">c_int</span>) <span class="tok-type">c_int</span>;</span>
<span class="line" id="L381"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;c&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">fsync</span>(fd: <span class="tok-type">c_int</span>) <span class="tok-type">c_int</span>;</span>
<span class="line" id="L382"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;c&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">fdatasync</span>(fd: <span class="tok-type">c_int</span>) <span class="tok-type">c_int</span>;</span>
<span class="line" id="L383"></span>
<span class="line" id="L384"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;c&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">prctl</span>(option: <span class="tok-type">c_int</span>, ...) <span class="tok-type">c_int</span>;</span>
<span class="line" id="L385"></span>
<span class="line" id="L386"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;c&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">getrlimit</span>(resource: c.rlimit_resource, rlim: *c.rlimit) <span class="tok-type">c_int</span>;</span>
<span class="line" id="L387"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;c&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">setrlimit</span>(resource: c.rlimit_resource, rlim: *<span class="tok-kw">const</span> c.rlimit) <span class="tok-type">c_int</span>;</span>
<span class="line" id="L388"></span>
<span class="line" id="L389"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;c&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">fmemopen</span>(<span class="tok-kw">noalias</span> buf: ?*<span class="tok-type">anyopaque</span>, size: <span class="tok-type">usize</span>, <span class="tok-kw">noalias</span> mode: [*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span>) ?*FILE;</span>
<span class="line" id="L390"></span>
<span class="line" id="L391"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;c&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">syslog</span>(priority: <span class="tok-type">c_int</span>, message: [*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span>, ...) <span class="tok-type">void</span>;</span>
<span class="line" id="L392"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;c&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">openlog</span>(ident: [*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span>, logopt: <span class="tok-type">c_int</span>, facility: <span class="tok-type">c_int</span>) <span class="tok-type">void</span>;</span>
<span class="line" id="L393"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;c&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">closelog</span>() <span class="tok-type">void</span>;</span>
<span class="line" id="L394"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;c&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">setlogmask</span>(maskpri: <span class="tok-type">c_int</span>) <span class="tok-type">c_int</span>;</span>
<span class="line" id="L395"></span>
<span class="line" id="L396"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;c&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">if_nametoindex</span>([*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span>) <span class="tok-type">c_int</span>;</span>
<span class="line" id="L397"></span>
<span class="line" id="L398"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> max_align_t = <span class="tok-kw">if</span> (builtin.abi == .msvc)</span>
<span class="line" id="L399">    <span class="tok-type">f64</span></span>
<span class="line" id="L400"><span class="tok-kw">else</span> <span class="tok-kw">if</span> (builtin.target.isDarwin())</span>
<span class="line" id="L401">    <span class="tok-type">c_longdouble</span></span>
<span class="line" id="L402"><span class="tok-kw">else</span></span>
<span class="line" id="L403">    <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L404">        a: <span class="tok-type">c_longlong</span>,</span>
<span class="line" id="L405">        b: <span class="tok-type">c_longdouble</span>,</span>
<span class="line" id="L406">    };</span>
<span class="line" id="L407"></span>
</code></pre></body>
</html>