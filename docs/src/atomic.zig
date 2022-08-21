<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">    <title>atomic.zig - source view</title>
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
<span class="line" id="L3"></span>
<span class="line" id="L4"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> Ordering = std.builtin.AtomicOrder;</span>
<span class="line" id="L5"></span>
<span class="line" id="L6"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> Stack = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;atomic/stack.zig&quot;</span>).Stack;</span>
<span class="line" id="L7"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> Queue = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;atomic/queue.zig&quot;</span>).Queue;</span>
<span class="line" id="L8"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> Atomic = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;atomic/Atomic.zig&quot;</span>).Atomic;</span>
<span class="line" id="L9"></span>
<span class="line" id="L10"><span class="tok-kw">test</span> <span class="tok-str">&quot;std.atomic&quot;</span> {</span>
<span class="line" id="L11">    _ = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;atomic/stack.zig&quot;</span>);</span>
<span class="line" id="L12">    _ = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;atomic/queue.zig&quot;</span>);</span>
<span class="line" id="L13">    _ = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;atomic/Atomic.zig&quot;</span>);</span>
<span class="line" id="L14">}</span>
<span class="line" id="L15"></span>
<span class="line" id="L16"><span class="tok-kw">pub</span> <span class="tok-kw">inline</span> <span class="tok-kw">fn</span> <span class="tok-fn">fence</span>(<span class="tok-kw">comptime</span> ordering: Ordering) <span class="tok-type">void</span> {</span>
<span class="line" id="L17">    <span class="tok-kw">switch</span> (ordering) {</span>
<span class="line" id="L18">        .Acquire, .Release, .AcqRel, .SeqCst =&gt; {</span>
<span class="line" id="L19">            <span class="tok-builtin">@fence</span>(ordering);</span>
<span class="line" id="L20">        },</span>
<span class="line" id="L21">        <span class="tok-kw">else</span> =&gt; {</span>
<span class="line" id="L22">            <span class="tok-builtin">@compileLog</span>(ordering, <span class="tok-str">&quot; only applies to a given memory location&quot;</span>);</span>
<span class="line" id="L23">        },</span>
<span class="line" id="L24">    }</span>
<span class="line" id="L25">}</span>
<span class="line" id="L26"></span>
<span class="line" id="L27"><span class="tok-kw">pub</span> <span class="tok-kw">inline</span> <span class="tok-kw">fn</span> <span class="tok-fn">compilerFence</span>(<span class="tok-kw">comptime</span> ordering: Ordering) <span class="tok-type">void</span> {</span>
<span class="line" id="L28">    <span class="tok-kw">switch</span> (ordering) {</span>
<span class="line" id="L29">        .Acquire, .Release, .AcqRel, .SeqCst =&gt; <span class="tok-kw">asm</span> <span class="tok-kw">volatile</span> (<span class="tok-str">&quot;&quot;</span> ::: <span class="tok-str">&quot;memory&quot;</span>),</span>
<span class="line" id="L30">        <span class="tok-kw">else</span> =&gt; <span class="tok-builtin">@compileLog</span>(ordering, <span class="tok-str">&quot; only applies to a given memory location&quot;</span>),</span>
<span class="line" id="L31">    }</span>
<span class="line" id="L32">}</span>
<span class="line" id="L33"></span>
<span class="line" id="L34"><span class="tok-kw">test</span> <span class="tok-str">&quot;fence/compilerFence&quot;</span> {</span>
<span class="line" id="L35">    <span class="tok-kw">inline</span> <span class="tok-kw">for</span> (.{ .Acquire, .Release, .AcqRel, .SeqCst }) |ordering| {</span>
<span class="line" id="L36">        compilerFence(ordering);</span>
<span class="line" id="L37">        fence(ordering);</span>
<span class="line" id="L38">    }</span>
<span class="line" id="L39">}</span>
<span class="line" id="L40"></span>
<span class="line" id="L41"><span class="tok-comment">/// Signals to the processor that the caller is inside a busy-wait spin-loop.</span></span>
<span class="line" id="L42"><span class="tok-kw">pub</span> <span class="tok-kw">inline</span> <span class="tok-kw">fn</span> <span class="tok-fn">spinLoopHint</span>() <span class="tok-type">void</span> {</span>
<span class="line" id="L43">    <span class="tok-kw">switch</span> (builtin.target.cpu.arch) {</span>
<span class="line" id="L44">        <span class="tok-comment">// No-op instruction that can hint to save (or share with a hardware-thread)</span>
</span>
<span class="line" id="L45">        <span class="tok-comment">// pipelining/power resources</span>
</span>
<span class="line" id="L46">        <span class="tok-comment">// https://software.intel.com/content/www/us/en/develop/articles/benefitting-power-and-performance-sleep-loops.html</span>
</span>
<span class="line" id="L47">        .<span class="tok-type">i386</span>, .x86_64 =&gt; <span class="tok-kw">asm</span> <span class="tok-kw">volatile</span> (<span class="tok-str">&quot;pause&quot;</span> ::: <span class="tok-str">&quot;memory&quot;</span>),</span>
<span class="line" id="L48"></span>
<span class="line" id="L49">        <span class="tok-comment">// No-op instruction that serves as a hardware-thread resource yield hint.</span>
</span>
<span class="line" id="L50">        <span class="tok-comment">// https://stackoverflow.com/a/7588941</span>
</span>
<span class="line" id="L51">        .powerpc64, .powerpc64le =&gt; <span class="tok-kw">asm</span> <span class="tok-kw">volatile</span> (<span class="tok-str">&quot;or 27, 27, 27&quot;</span> ::: <span class="tok-str">&quot;memory&quot;</span>),</span>
<span class="line" id="L52"></span>
<span class="line" id="L53">        <span class="tok-comment">// `isb` appears more reliable for releasing execution resources than `yield`</span>
</span>
<span class="line" id="L54">        <span class="tok-comment">// on common aarch64 CPUs.</span>
</span>
<span class="line" id="L55">        <span class="tok-comment">// https://bugs.java.com/bugdatabase/view_bug.do?bug_id=8258604</span>
</span>
<span class="line" id="L56">        <span class="tok-comment">// https://bugs.mysql.com/bug.php?id=100664</span>
</span>
<span class="line" id="L57">        .aarch64, .aarch64_be, .aarch64_32 =&gt; <span class="tok-kw">asm</span> <span class="tok-kw">volatile</span> (<span class="tok-str">&quot;isb&quot;</span> ::: <span class="tok-str">&quot;memory&quot;</span>),</span>
<span class="line" id="L58"></span>
<span class="line" id="L59">        <span class="tok-comment">// `yield` was introduced in v6k but is also available on v6m.</span>
</span>
<span class="line" id="L60">        <span class="tok-comment">// https://www.keil.com/support/man/docs/armasm/armasm_dom1361289926796.htm</span>
</span>
<span class="line" id="L61">        .arm, .armeb, .thumb, .thumbeb =&gt; {</span>
<span class="line" id="L62">            <span class="tok-kw">const</span> can_yield = <span class="tok-kw">comptime</span> std.Target.arm.featureSetHasAny(builtin.target.cpu.features, .{</span>
<span class="line" id="L63">                .has_v6k, .has_v6m,</span>
<span class="line" id="L64">            });</span>
<span class="line" id="L65">            <span class="tok-kw">if</span> (can_yield) {</span>
<span class="line" id="L66">                <span class="tok-kw">asm</span> <span class="tok-kw">volatile</span> (<span class="tok-str">&quot;yield&quot;</span> ::: <span class="tok-str">&quot;memory&quot;</span>);</span>
<span class="line" id="L67">            } <span class="tok-kw">else</span> {</span>
<span class="line" id="L68">                <span class="tok-kw">asm</span> <span class="tok-kw">volatile</span> (<span class="tok-str">&quot;&quot;</span> ::: <span class="tok-str">&quot;memory&quot;</span>);</span>
<span class="line" id="L69">            }</span>
<span class="line" id="L70">        },</span>
<span class="line" id="L71">        <span class="tok-comment">// Memory barrier to prevent the compiler from optimizing away the spin-loop</span>
</span>
<span class="line" id="L72">        <span class="tok-comment">// even if no hint_instruction was provided.</span>
</span>
<span class="line" id="L73">        <span class="tok-kw">else</span> =&gt; <span class="tok-kw">asm</span> <span class="tok-kw">volatile</span> (<span class="tok-str">&quot;&quot;</span> ::: <span class="tok-str">&quot;memory&quot;</span>),</span>
<span class="line" id="L74">    }</span>
<span class="line" id="L75">}</span>
<span class="line" id="L76"></span>
<span class="line" id="L77"><span class="tok-kw">test</span> <span class="tok-str">&quot;spinLoopHint&quot;</span> {</span>
<span class="line" id="L78">    <span class="tok-kw">var</span> i: <span class="tok-type">usize</span> = <span class="tok-number">10</span>;</span>
<span class="line" id="L79">    <span class="tok-kw">while</span> (i &gt; <span class="tok-number">0</span>) : (i -= <span class="tok-number">1</span>) {</span>
<span class="line" id="L80">        spinLoopHint();</span>
<span class="line" id="L81">    }</span>
<span class="line" id="L82">}</span>
<span class="line" id="L83"></span>
<span class="line" id="L84"><span class="tok-comment">/// The estimated size of the CPU's cache line when atomically updating memory.</span></span>
<span class="line" id="L85"><span class="tok-comment">/// Add this much padding or align to this boundary to avoid atomically-updated</span></span>
<span class="line" id="L86"><span class="tok-comment">/// memory from forcing cache invalidations on near, but non-atomic, memory.</span></span>
<span class="line" id="L87"><span class="tok-comment">///</span></span>
<span class="line" id="L88"><span class="tok-comment">// https://en.wikipedia.org/wiki/False_sharing</span>
</span>
<span class="line" id="L89"><span class="tok-comment">// https://github.com/golang/go/search?q=CacheLinePadSize</span>
</span>
<span class="line" id="L90"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> cache_line = <span class="tok-kw">switch</span> (builtin.cpu.arch) {</span>
<span class="line" id="L91">    <span class="tok-comment">// x86_64: Starting from Intel's Sandy Bridge, the spatial prefetcher pulls in pairs of 64-byte cache lines at a time.</span>
</span>
<span class="line" id="L92">    <span class="tok-comment">// - https://www.intel.com/content/dam/www/public/us/en/documents/manuals/64-ia-32-architectures-optimization-manual.pdf</span>
</span>
<span class="line" id="L93">    <span class="tok-comment">// - https://github.com/facebook/folly/blob/1b5288e6eea6df074758f877c849b6e73bbb9fbb/folly/lang/Align.h#L107</span>
</span>
<span class="line" id="L94">    <span class="tok-comment">//</span>
</span>
<span class="line" id="L95">    <span class="tok-comment">// aarch64: Some big.LITTLE ARM archs have &quot;big&quot; cores with 128-byte cache lines:</span>
</span>
<span class="line" id="L96">    <span class="tok-comment">// - https://www.mono-project.com/news/2016/09/12/arm64-icache/</span>
</span>
<span class="line" id="L97">    <span class="tok-comment">// - https://cpufun.substack.com/p/more-m1-fun-hardware-information</span>
</span>
<span class="line" id="L98">    <span class="tok-comment">//</span>
</span>
<span class="line" id="L99">    <span class="tok-comment">// powerpc64: PPC has 128-byte cache lines</span>
</span>
<span class="line" id="L100">    <span class="tok-comment">// - https://github.com/golang/go/blob/3dd58676054223962cd915bb0934d1f9f489d4d2/src/internal/cpu/cpu_ppc64x.go#L9</span>
</span>
<span class="line" id="L101">    .x86_64, .aarch64, .powerpc64 =&gt; <span class="tok-number">128</span>,</span>
<span class="line" id="L102"></span>
<span class="line" id="L103">    <span class="tok-comment">// These platforms reportedly have 32-byte cache lines</span>
</span>
<span class="line" id="L104">    <span class="tok-comment">// - https://github.com/golang/go/blob/3dd58676054223962cd915bb0934d1f9f489d4d2/src/internal/cpu/cpu_arm.go#L7</span>
</span>
<span class="line" id="L105">    <span class="tok-comment">// - https://github.com/golang/go/blob/3dd58676054223962cd915bb0934d1f9f489d4d2/src/internal/cpu/cpu_mips.go#L7</span>
</span>
<span class="line" id="L106">    <span class="tok-comment">// - https://github.com/golang/go/blob/3dd58676054223962cd915bb0934d1f9f489d4d2/src/internal/cpu/cpu_mipsle.go#L7</span>
</span>
<span class="line" id="L107">    <span class="tok-comment">// - https://github.com/golang/go/blob/3dd58676054223962cd915bb0934d1f9f489d4d2/src/internal/cpu/cpu_mips64x.go#L9</span>
</span>
<span class="line" id="L108">    <span class="tok-comment">// - https://github.com/golang/go/blob/3dd58676054223962cd915bb0934d1f9f489d4d2/src/internal/cpu/cpu_riscv64.go#L7</span>
</span>
<span class="line" id="L109">    .arm, .mips, .mips64, .riscv64 =&gt; <span class="tok-number">32</span>,</span>
<span class="line" id="L110"></span>
<span class="line" id="L111">    <span class="tok-comment">// This platform reportedly has 256-byte cache lines</span>
</span>
<span class="line" id="L112">    <span class="tok-comment">// - https://github.com/golang/go/blob/3dd58676054223962cd915bb0934d1f9f489d4d2/src/internal/cpu/cpu_s390x.go#L7</span>
</span>
<span class="line" id="L113">    .s390x =&gt; <span class="tok-number">256</span>,</span>
<span class="line" id="L114"></span>
<span class="line" id="L115">    <span class="tok-comment">// Other x86 and WASM platforms have 64-byte cache lines.</span>
</span>
<span class="line" id="L116">    <span class="tok-comment">// The rest of the architectures are assumed to be similar.</span>
</span>
<span class="line" id="L117">    <span class="tok-comment">// - https://github.com/golang/go/blob/dda2991c2ea0c5914714469c4defc2562a907230/src/internal/cpu/cpu_x86.go#L9</span>
</span>
<span class="line" id="L118">    <span class="tok-comment">// - https://github.com/golang/go/blob/3dd58676054223962cd915bb0934d1f9f489d4d2/src/internal/cpu/cpu_wasm.go#L7</span>
</span>
<span class="line" id="L119">    <span class="tok-kw">else</span> =&gt; <span class="tok-number">64</span>,</span>
<span class="line" id="L120">};</span>
<span class="line" id="L121"></span>
</code></pre></body>
</html>