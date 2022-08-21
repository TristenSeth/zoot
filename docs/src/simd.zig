<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">    <title>simd.zig - source view</title>
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
<pre><code><span class="line" id="L1"><span class="tok-comment">//! This module provides functions for working conveniently with SIMD (Single Instruction; Multiple Data),</span></span>
<span class="line" id="L2"><span class="tok-comment">//! which may offer a potential boost in performance on some targets by performing the same operations on</span></span>
<span class="line" id="L3"><span class="tok-comment">//! multiple elements at once.</span></span>
<span class="line" id="L4"><span class="tok-comment">//! Please be aware that some functions are known to not work on MIPS.</span></span>
<span class="line" id="L5"></span>
<span class="line" id="L6"><span class="tok-kw">const</span> std = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;std&quot;</span>);</span>
<span class="line" id="L7"><span class="tok-kw">const</span> builtin = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;builtin&quot;</span>);</span>
<span class="line" id="L8"></span>
<span class="line" id="L9"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">suggestVectorSizeForCpu</span>(<span class="tok-kw">comptime</span> T: <span class="tok-type">type</span>, <span class="tok-kw">comptime</span> cpu: std.Target.Cpu) ?<span class="tok-type">usize</span> {</span>
<span class="line" id="L10">    <span class="tok-comment">// This is guesswork, if you have better suggestions can add it or edit the current here</span>
</span>
<span class="line" id="L11">    <span class="tok-comment">// This can run in comptime only, but stage 1 fails at it, stage 2 can understand it</span>
</span>
<span class="line" id="L12">    <span class="tok-kw">const</span> element_bit_size = <span class="tok-builtin">@maximum</span>(<span class="tok-number">8</span>, std.math.ceilPowerOfTwo(T, <span class="tok-builtin">@bitSizeOf</span>(T)) <span class="tok-kw">catch</span> <span class="tok-kw">unreachable</span>);</span>
<span class="line" id="L13">    <span class="tok-kw">const</span> vector_bit_size: <span class="tok-type">u16</span> = blk: {</span>
<span class="line" id="L14">        <span class="tok-kw">if</span> (cpu.arch.isX86()) {</span>
<span class="line" id="L15">            <span class="tok-kw">if</span> (T == <span class="tok-type">bool</span> <span class="tok-kw">and</span> std.Target.x86.featureSetHas(.prefer_mask_registers)) <span class="tok-kw">return</span> <span class="tok-number">64</span>;</span>
<span class="line" id="L16">            <span class="tok-kw">if</span> (std.Target.x86.featureSetHas(cpu.features, .avx512f) <span class="tok-kw">and</span> !std.Target.x86.featureSetHasAny(cpu.features, .{ .prefer_256_bit, .prefer_128_bit })) <span class="tok-kw">break</span> :blk <span class="tok-number">512</span>;</span>
<span class="line" id="L17">            <span class="tok-kw">if</span> (std.Target.x86.featureSetHasAny(cpu.features, .{ .prefer_256_bit, .avx2 }) <span class="tok-kw">and</span> !std.Target.x86.featureSetHas(cpu.features, .prefer_128_bit)) <span class="tok-kw">break</span> :blk <span class="tok-number">256</span>;</span>
<span class="line" id="L18">            <span class="tok-kw">if</span> (std.Target.x86.featureSetHas(cpu.features, .sse)) <span class="tok-kw">break</span> :blk <span class="tok-number">128</span>;</span>
<span class="line" id="L19">            <span class="tok-kw">if</span> (std.Target.x86.featureSetHasAny(cpu.features, .{ .mmx, .@&quot;3dnow&quot; })) <span class="tok-kw">break</span> :blk <span class="tok-number">64</span>;</span>
<span class="line" id="L20">        } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (cpu.arch.isARM()) {</span>
<span class="line" id="L21">            <span class="tok-kw">if</span> (std.Target.arm.featureSetHas(cpu.features, .neon)) <span class="tok-kw">break</span> :blk <span class="tok-number">128</span>;</span>
<span class="line" id="L22">        } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (cpu.arch.isAARCH64()) {</span>
<span class="line" id="L23">            <span class="tok-comment">// SVE allows up to 2048 bits in the specification, as of 2022 the most powerful machine has implemented 512-bit</span>
</span>
<span class="line" id="L24">            <span class="tok-comment">// I think is safer to just be on 128 until is more common</span>
</span>
<span class="line" id="L25">            <span class="tok-comment">// TODO: Check on this return when bigger values are more common</span>
</span>
<span class="line" id="L26">            <span class="tok-kw">if</span> (std.Target.aarch64.featureSetHas(cpu.features, .sve)) <span class="tok-kw">break</span> :blk <span class="tok-number">128</span>;</span>
<span class="line" id="L27">            <span class="tok-kw">if</span> (std.Target.aarch64.featureSetHas(cpu.features, .neon)) <span class="tok-kw">break</span> :blk <span class="tok-number">128</span>;</span>
<span class="line" id="L28">        } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (cpu.arch.isPPC() <span class="tok-kw">or</span> cpu.arch.isPPC64()) {</span>
<span class="line" id="L29">            <span class="tok-kw">if</span> (std.Target.powerpc.featureSetHas(cpu.features, .altivec)) <span class="tok-kw">break</span> :blk <span class="tok-number">128</span>;</span>
<span class="line" id="L30">        } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (cpu.arch.isMIPS()) {</span>
<span class="line" id="L31">            <span class="tok-kw">if</span> (std.Target.mips.featureSetHas(cpu.features, .msa)) <span class="tok-kw">break</span> :blk <span class="tok-number">128</span>;</span>
<span class="line" id="L32">            <span class="tok-comment">// TODO: Test MIPS capability to handle bigger vectors</span>
</span>
<span class="line" id="L33">            <span class="tok-comment">//       In theory MDMX and by extension mips3d have 32 registers of 64 bits which can use in parallel</span>
</span>
<span class="line" id="L34">            <span class="tok-comment">//       for multiple processing, but I don't know what's optimal here, if using</span>
</span>
<span class="line" id="L35">            <span class="tok-comment">//       the 2048 bits or using just 64 per vector or something in between</span>
</span>
<span class="line" id="L36">            <span class="tok-kw">if</span> (std.Target.mips.featureSetHas(cpu.features, std.Target.mips.Feature.mips3d)) <span class="tok-kw">break</span> :blk <span class="tok-number">64</span>;</span>
<span class="line" id="L37">        } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (cpu.arch.isRISCV()) {</span>
<span class="line" id="L38">            <span class="tok-comment">// in risc-v the Vector Extension allows configurable vector sizes, but a standard size of 128 is a safe estimate</span>
</span>
<span class="line" id="L39">            <span class="tok-kw">if</span> (std.Target.riscv.featureSetHas(cpu.features, .v)) <span class="tok-kw">break</span> :blk <span class="tok-number">128</span>;</span>
<span class="line" id="L40">        } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (cpu.arch.isSPARC()) {</span>
<span class="line" id="L41">            <span class="tok-comment">// TODO: Test Sparc capability to handle bigger vectors</span>
</span>
<span class="line" id="L42">            <span class="tok-comment">//       In theory Sparc have 32 registers of 64 bits which can use in parallel</span>
</span>
<span class="line" id="L43">            <span class="tok-comment">//       for multiple processing, but I don't know what's optimal here, if using</span>
</span>
<span class="line" id="L44">            <span class="tok-comment">//       the 2048 bits or using just 64 per vector or something in between</span>
</span>
<span class="line" id="L45">            <span class="tok-kw">if</span> (std.Target.sparc.featureSetHasAny(cpu.features, .{ .vis, .vis2, .vis3 })) <span class="tok-kw">break</span> :blk <span class="tok-number">64</span>;</span>
<span class="line" id="L46">        }</span>
<span class="line" id="L47">        <span class="tok-kw">return</span> <span class="tok-null">null</span>;</span>
<span class="line" id="L48">    };</span>
<span class="line" id="L49">    <span class="tok-kw">if</span> (vector_bit_size &lt;= element_bit_size) <span class="tok-kw">return</span> <span class="tok-null">null</span>;</span>
<span class="line" id="L50"></span>
<span class="line" id="L51">    <span class="tok-kw">return</span> <span class="tok-builtin">@divExact</span>(vector_bit_size, element_bit_size);</span>
<span class="line" id="L52">}</span>
<span class="line" id="L53"></span>
<span class="line" id="L54"><span class="tok-comment">/// Suggests a target-dependant vector size for a given type, or null if scalars are recommended.</span></span>
<span class="line" id="L55"><span class="tok-comment">/// Not yet implemented for every CPU architecture.</span></span>
<span class="line" id="L56"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">suggestVectorSize</span>(<span class="tok-kw">comptime</span> T: <span class="tok-type">type</span>) ?<span class="tok-type">usize</span> {</span>
<span class="line" id="L57">    <span class="tok-kw">return</span> suggestVectorSizeForCpu(T, builtin.cpu);</span>
<span class="line" id="L58">}</span>
<span class="line" id="L59"></span>
<span class="line" id="L60"><span class="tok-kw">fn</span> <span class="tok-fn">vectorLength</span>(<span class="tok-kw">comptime</span> VectorType: <span class="tok-type">type</span>) <span class="tok-type">comptime_int</span> {</span>
<span class="line" id="L61">    <span class="tok-kw">return</span> <span class="tok-kw">switch</span> (<span class="tok-builtin">@typeInfo</span>(VectorType)) {</span>
<span class="line" id="L62">        .Vector =&gt; |info| info.len,</span>
<span class="line" id="L63">        .Array =&gt; |info| info.len,</span>
<span class="line" id="L64">        <span class="tok-kw">else</span> =&gt; <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;Invalid type &quot;</span> ++ <span class="tok-builtin">@typeName</span>(VectorType)),</span>
<span class="line" id="L65">    };</span>
<span class="line" id="L66">}</span>
<span class="line" id="L67"></span>
<span class="line" id="L68"><span class="tok-comment">/// Returns the smallest type of unsigned ints capable of indexing any element within the given vector type.</span></span>
<span class="line" id="L69"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">VectorIndex</span>(<span class="tok-kw">comptime</span> VectorType: <span class="tok-type">type</span>) <span class="tok-type">type</span> {</span>
<span class="line" id="L70">    <span class="tok-kw">return</span> std.math.IntFittingRange(<span class="tok-number">0</span>, vectorLength(VectorType) - <span class="tok-number">1</span>);</span>
<span class="line" id="L71">}</span>
<span class="line" id="L72"></span>
<span class="line" id="L73"><span class="tok-comment">/// Returns the smallest type of unsigned ints capable of holding the length of the given vector type.</span></span>
<span class="line" id="L74"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">VectorCount</span>(<span class="tok-kw">comptime</span> VectorType: <span class="tok-type">type</span>) <span class="tok-type">type</span> {</span>
<span class="line" id="L75">    <span class="tok-kw">return</span> std.math.IntFittingRange(<span class="tok-number">0</span>, vectorLength(VectorType));</span>
<span class="line" id="L76">}</span>
<span class="line" id="L77"></span>
<span class="line" id="L78"><span class="tok-comment">/// Returns a vector containing the first `len` integers in order from 0 to `len`-1.</span></span>
<span class="line" id="L79"><span class="tok-comment">/// For example, `iota(i32, 8)` will return a vector containing `.{0, 1, 2, 3, 4, 5, 6, 7}`.</span></span>
<span class="line" id="L80"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">iota</span>(<span class="tok-kw">comptime</span> T: <span class="tok-type">type</span>, <span class="tok-kw">comptime</span> len: <span class="tok-type">usize</span>) <span class="tok-builtin">@Vector</span>(len, T) {</span>
<span class="line" id="L81">    <span class="tok-kw">var</span> out: [len]T = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L82">    <span class="tok-kw">for</span> (out) |*element, i| {</span>
<span class="line" id="L83">        element.* = <span class="tok-kw">switch</span> (<span class="tok-builtin">@typeInfo</span>(T)) {</span>
<span class="line" id="L84">            .Int =&gt; <span class="tok-builtin">@intCast</span>(T, i),</span>
<span class="line" id="L85">            .Float =&gt; <span class="tok-builtin">@intToFloat</span>(T, i),</span>
<span class="line" id="L86">            <span class="tok-kw">else</span> =&gt; <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;Can't use type &quot;</span> ++ <span class="tok-builtin">@typeName</span>(T) ++ <span class="tok-str">&quot; in iota.&quot;</span>),</span>
<span class="line" id="L87">        };</span>
<span class="line" id="L88">    }</span>
<span class="line" id="L89">    <span class="tok-kw">return</span> <span class="tok-builtin">@as</span>(<span class="tok-builtin">@Vector</span>(len, T), out);</span>
<span class="line" id="L90">}</span>
<span class="line" id="L91"></span>
<span class="line" id="L92"><span class="tok-comment">/// Returns a vector containing the same elements as the input, but repeated until the desired length is reached.</span></span>
<span class="line" id="L93"><span class="tok-comment">/// For example, `repeat(8, [_]u32{1, 2, 3})` will return a vector containing `.{1, 2, 3, 1, 2, 3, 1, 2}`.</span></span>
<span class="line" id="L94"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">repeat</span>(<span class="tok-kw">comptime</span> len: <span class="tok-type">usize</span>, vec: <span class="tok-kw">anytype</span>) <span class="tok-builtin">@Vector</span>(len, std.meta.Child(<span class="tok-builtin">@TypeOf</span>(vec))) {</span>
<span class="line" id="L95">    <span class="tok-kw">const</span> Child = std.meta.Child(<span class="tok-builtin">@TypeOf</span>(vec));</span>
<span class="line" id="L96"></span>
<span class="line" id="L97">    <span class="tok-kw">return</span> <span class="tok-builtin">@shuffle</span>(Child, vec, <span class="tok-null">undefined</span>, iota(<span class="tok-type">i32</span>, len) % <span class="tok-builtin">@splat</span>(len, <span class="tok-builtin">@intCast</span>(<span class="tok-type">i32</span>, vectorLength(<span class="tok-builtin">@TypeOf</span>(vec)))));</span>
<span class="line" id="L98">}</span>
<span class="line" id="L99"></span>
<span class="line" id="L100"><span class="tok-comment">/// Returns a vector containing all elements of the first vector at the lower indices followed by all elements of the second vector</span></span>
<span class="line" id="L101"><span class="tok-comment">/// at the higher indices.</span></span>
<span class="line" id="L102"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">join</span>(a: <span class="tok-kw">anytype</span>, b: <span class="tok-kw">anytype</span>) <span class="tok-builtin">@Vector</span>(vectorLength(<span class="tok-builtin">@TypeOf</span>(a)) + vectorLength(<span class="tok-builtin">@TypeOf</span>(b)), std.meta.Child(<span class="tok-builtin">@TypeOf</span>(a))) {</span>
<span class="line" id="L103">    <span class="tok-kw">const</span> Child = std.meta.Child(<span class="tok-builtin">@TypeOf</span>(a));</span>
<span class="line" id="L104">    <span class="tok-kw">const</span> a_len = vectorLength(<span class="tok-builtin">@TypeOf</span>(a));</span>
<span class="line" id="L105">    <span class="tok-kw">const</span> b_len = vectorLength(<span class="tok-builtin">@TypeOf</span>(b));</span>
<span class="line" id="L106"></span>
<span class="line" id="L107">    <span class="tok-kw">return</span> <span class="tok-builtin">@shuffle</span>(Child, a, b, <span class="tok-builtin">@as</span>([a_len]<span class="tok-type">i32</span>, iota(<span class="tok-type">i32</span>, a_len)) ++ <span class="tok-builtin">@as</span>([b_len]<span class="tok-type">i32</span>, ~iota(<span class="tok-type">i32</span>, b_len)));</span>
<span class="line" id="L108">}</span>
<span class="line" id="L109"></span>
<span class="line" id="L110"><span class="tok-comment">/// Returns a vector whose elements alternates between those of each input vector.</span></span>
<span class="line" id="L111"><span class="tok-comment">/// For example, `interlace(.{[4]u32{11, 12, 13, 14}, [4]u32{21, 22, 23, 24}})` returns a vector containing `.{11, 21, 12, 22, 13, 23, 14, 24}`.</span></span>
<span class="line" id="L112"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">interlace</span>(vecs: <span class="tok-kw">anytype</span>) <span class="tok-builtin">@Vector</span>(vectorLength(<span class="tok-builtin">@TypeOf</span>(vecs[<span class="tok-number">0</span>])) * vecs.len, std.meta.Child(<span class="tok-builtin">@TypeOf</span>(vecs[<span class="tok-number">0</span>]))) {</span>
<span class="line" id="L113">    <span class="tok-comment">// interlace doesn't work on MIPS, for some reason.</span>
</span>
<span class="line" id="L114">    <span class="tok-comment">// Notes from earlier debug attempt:</span>
</span>
<span class="line" id="L115">    <span class="tok-comment">//  The indices are correct. The problem seems to be with the @shuffle builtin.</span>
</span>
<span class="line" id="L116">    <span class="tok-comment">//  On MIPS, the test that interlaces small_base gives { 0, 2, 0, 0, 64, 255, 248, 200, 0, 0 }.</span>
</span>
<span class="line" id="L117">    <span class="tok-comment">//  Calling this with two inputs seems to work fine, but I'll let the compile error trigger for all inputs, just to be safe.</span>
</span>
<span class="line" id="L118">    <span class="tok-kw">comptime</span> <span class="tok-kw">if</span> (builtin.cpu.arch.isMIPS()) <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;TODO: Find out why interlace() doesn't work on MIPS&quot;</span>);</span>
<span class="line" id="L119"></span>
<span class="line" id="L120">    <span class="tok-kw">const</span> VecType = <span class="tok-builtin">@TypeOf</span>(vecs[<span class="tok-number">0</span>]);</span>
<span class="line" id="L121">    <span class="tok-kw">const</span> vecs_arr = <span class="tok-builtin">@as</span>([vecs.len]VecType, vecs);</span>
<span class="line" id="L122">    <span class="tok-kw">const</span> Child = std.meta.Child(<span class="tok-builtin">@TypeOf</span>(vecs_arr[<span class="tok-number">0</span>]));</span>
<span class="line" id="L123"></span>
<span class="line" id="L124">    <span class="tok-kw">if</span> (vecs_arr.len == <span class="tok-number">1</span>) <span class="tok-kw">return</span> vecs_arr[<span class="tok-number">0</span>];</span>
<span class="line" id="L125"></span>
<span class="line" id="L126">    <span class="tok-kw">const</span> a_vec_count = (<span class="tok-number">1</span> + vecs_arr.len) &gt;&gt; <span class="tok-number">1</span>;</span>
<span class="line" id="L127">    <span class="tok-kw">const</span> b_vec_count = vecs_arr.len &gt;&gt; <span class="tok-number">1</span>;</span>
<span class="line" id="L128"></span>
<span class="line" id="L129">    <span class="tok-kw">const</span> a = interlace(<span class="tok-builtin">@ptrCast</span>(*<span class="tok-kw">const</span> [a_vec_count]VecType, vecs_arr[<span class="tok-number">0</span>..a_vec_count]).*);</span>
<span class="line" id="L130">    <span class="tok-kw">const</span> b = interlace(<span class="tok-builtin">@ptrCast</span>(*<span class="tok-kw">const</span> [b_vec_count]VecType, vecs_arr[a_vec_count..]).*);</span>
<span class="line" id="L131"></span>
<span class="line" id="L132">    <span class="tok-kw">const</span> a_len = vectorLength(<span class="tok-builtin">@TypeOf</span>(a));</span>
<span class="line" id="L133">    <span class="tok-kw">const</span> b_len = vectorLength(<span class="tok-builtin">@TypeOf</span>(b));</span>
<span class="line" id="L134">    <span class="tok-kw">const</span> len = a_len + b_len;</span>
<span class="line" id="L135"></span>
<span class="line" id="L136">    <span class="tok-kw">const</span> indices = <span class="tok-kw">comptime</span> blk: {</span>
<span class="line" id="L137">        <span class="tok-kw">const</span> count_up = iota(<span class="tok-type">i32</span>, len);</span>
<span class="line" id="L138">        <span class="tok-kw">const</span> cycle = <span class="tok-builtin">@divFloor</span>(count_up, <span class="tok-builtin">@splat</span>(len, <span class="tok-builtin">@intCast</span>(<span class="tok-type">i32</span>, vecs_arr.len)));</span>
<span class="line" id="L139">        <span class="tok-kw">const</span> select_mask = repeat(len, join(<span class="tok-builtin">@splat</span>(a_vec_count, <span class="tok-null">true</span>), <span class="tok-builtin">@splat</span>(b_vec_count, <span class="tok-null">false</span>)));</span>
<span class="line" id="L140">        <span class="tok-kw">const</span> a_indices = count_up - cycle * <span class="tok-builtin">@splat</span>(len, <span class="tok-builtin">@intCast</span>(<span class="tok-type">i32</span>, b_vec_count));</span>
<span class="line" id="L141">        <span class="tok-kw">const</span> b_indices = shiftElementsRight(count_up - cycle * <span class="tok-builtin">@splat</span>(len, <span class="tok-builtin">@intCast</span>(<span class="tok-type">i32</span>, a_vec_count)), a_vec_count, <span class="tok-number">0</span>);</span>
<span class="line" id="L142">        <span class="tok-kw">break</span> :blk <span class="tok-builtin">@select</span>(<span class="tok-type">i32</span>, select_mask, a_indices, ~b_indices);</span>
<span class="line" id="L143">    };</span>
<span class="line" id="L144"></span>
<span class="line" id="L145">    <span class="tok-kw">return</span> <span class="tok-builtin">@shuffle</span>(Child, a, b, indices);</span>
<span class="line" id="L146">}</span>
<span class="line" id="L147"></span>
<span class="line" id="L148"><span class="tok-comment">/// The contents of `interlaced` is evenly split between vec_count vectors that are returned as an array. They &quot;take turns&quot;,</span></span>
<span class="line" id="L149"><span class="tok-comment">/// recieving one element from `interlaced` at a time.</span></span>
<span class="line" id="L150"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">deinterlace</span>(</span>
<span class="line" id="L151">    <span class="tok-kw">comptime</span> vec_count: <span class="tok-type">usize</span>,</span>
<span class="line" id="L152">    interlaced: <span class="tok-kw">anytype</span>,</span>
<span class="line" id="L153">) [vec_count]<span class="tok-builtin">@Vector</span>(</span>
<span class="line" id="L154">    vectorLength(<span class="tok-builtin">@TypeOf</span>(interlaced)) / vec_count,</span>
<span class="line" id="L155">    std.meta.Child(<span class="tok-builtin">@TypeOf</span>(interlaced)),</span>
<span class="line" id="L156">) {</span>
<span class="line" id="L157">    <span class="tok-kw">const</span> vec_len = vectorLength(<span class="tok-builtin">@TypeOf</span>(interlaced)) / vec_count;</span>
<span class="line" id="L158">    <span class="tok-kw">const</span> Child = std.meta.Child(<span class="tok-builtin">@TypeOf</span>(interlaced));</span>
<span class="line" id="L159"></span>
<span class="line" id="L160">    <span class="tok-kw">var</span> out: [vec_count]<span class="tok-builtin">@Vector</span>(vec_len, Child) = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L161"></span>
<span class="line" id="L162">    <span class="tok-kw">comptime</span> <span class="tok-kw">var</span> i: <span class="tok-type">usize</span> = <span class="tok-number">0</span>; <span class="tok-comment">// for-loops don't work for this, apparently.</span>
</span>
<span class="line" id="L163">    <span class="tok-kw">inline</span> <span class="tok-kw">while</span> (i &lt; out.len) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L164">        <span class="tok-kw">const</span> indices = <span class="tok-kw">comptime</span> iota(<span class="tok-type">i32</span>, vec_len) * <span class="tok-builtin">@splat</span>(vec_len, <span class="tok-builtin">@intCast</span>(<span class="tok-type">i32</span>, vec_count)) + <span class="tok-builtin">@splat</span>(vec_len, <span class="tok-builtin">@intCast</span>(<span class="tok-type">i32</span>, i));</span>
<span class="line" id="L165">        out[i] = <span class="tok-builtin">@shuffle</span>(Child, interlaced, <span class="tok-null">undefined</span>, indices);</span>
<span class="line" id="L166">    }</span>
<span class="line" id="L167"></span>
<span class="line" id="L168">    <span class="tok-kw">return</span> out;</span>
<span class="line" id="L169">}</span>
<span class="line" id="L170"></span>
<span class="line" id="L171"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">extract</span>(</span>
<span class="line" id="L172">    vec: <span class="tok-kw">anytype</span>,</span>
<span class="line" id="L173">    <span class="tok-kw">comptime</span> first: VectorIndex(<span class="tok-builtin">@TypeOf</span>(vec)),</span>
<span class="line" id="L174">    <span class="tok-kw">comptime</span> count: VectorCount(<span class="tok-builtin">@TypeOf</span>(vec)),</span>
<span class="line" id="L175">) <span class="tok-builtin">@Vector</span>(count, std.meta.Child(<span class="tok-builtin">@TypeOf</span>(vec))) {</span>
<span class="line" id="L176">    <span class="tok-kw">const</span> Child = std.meta.Child(<span class="tok-builtin">@TypeOf</span>(vec));</span>
<span class="line" id="L177">    <span class="tok-kw">const</span> len = vectorLength(<span class="tok-builtin">@TypeOf</span>(vec));</span>
<span class="line" id="L178"></span>
<span class="line" id="L179">    std.debug.assert(<span class="tok-builtin">@intCast</span>(<span class="tok-type">comptime_int</span>, first) + <span class="tok-builtin">@intCast</span>(<span class="tok-type">comptime_int</span>, count) &lt;= len);</span>
<span class="line" id="L180"></span>
<span class="line" id="L181">    <span class="tok-kw">return</span> <span class="tok-builtin">@shuffle</span>(Child, vec, <span class="tok-null">undefined</span>, iota(<span class="tok-type">i32</span>, count) + <span class="tok-builtin">@splat</span>(count, <span class="tok-builtin">@intCast</span>(<span class="tok-type">i32</span>, first)));</span>
<span class="line" id="L182">}</span>
<span class="line" id="L183"></span>
<span class="line" id="L184"><span class="tok-kw">test</span> <span class="tok-str">&quot;vector patterns&quot;</span> {</span>
<span class="line" id="L185">    <span class="tok-kw">if</span> ((builtin.zig_backend == .stage1 <span class="tok-kw">or</span> builtin.zig_backend == .stage2_llvm) <span class="tok-kw">and</span></span>
<span class="line" id="L186">        builtin.cpu.arch == .aarch64)</span>
<span class="line" id="L187">    {</span>
<span class="line" id="L188">        <span class="tok-comment">// https://github.com/ziglang/zig/issues/12012</span>
</span>
<span class="line" id="L189">        <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SkipZigTest;</span>
<span class="line" id="L190">    }</span>
<span class="line" id="L191">    <span class="tok-kw">const</span> base = <span class="tok-builtin">@Vector</span>(<span class="tok-number">4</span>, <span class="tok-type">u32</span>){ <span class="tok-number">10</span>, <span class="tok-number">20</span>, <span class="tok-number">30</span>, <span class="tok-number">40</span> };</span>
<span class="line" id="L192">    <span class="tok-kw">const</span> other_base = <span class="tok-builtin">@Vector</span>(<span class="tok-number">4</span>, <span class="tok-type">u32</span>){ <span class="tok-number">55</span>, <span class="tok-number">66</span>, <span class="tok-number">77</span>, <span class="tok-number">88</span> };</span>
<span class="line" id="L193"></span>
<span class="line" id="L194">    <span class="tok-kw">const</span> small_bases = [<span class="tok-number">5</span>]<span class="tok-builtin">@Vector</span>(<span class="tok-number">2</span>, <span class="tok-type">u8</span>){</span>
<span class="line" id="L195">        <span class="tok-builtin">@Vector</span>(<span class="tok-number">2</span>, <span class="tok-type">u8</span>){ <span class="tok-number">0</span>, <span class="tok-number">1</span> },</span>
<span class="line" id="L196">        <span class="tok-builtin">@Vector</span>(<span class="tok-number">2</span>, <span class="tok-type">u8</span>){ <span class="tok-number">2</span>, <span class="tok-number">3</span> },</span>
<span class="line" id="L197">        <span class="tok-builtin">@Vector</span>(<span class="tok-number">2</span>, <span class="tok-type">u8</span>){ <span class="tok-number">4</span>, <span class="tok-number">5</span> },</span>
<span class="line" id="L198">        <span class="tok-builtin">@Vector</span>(<span class="tok-number">2</span>, <span class="tok-type">u8</span>){ <span class="tok-number">6</span>, <span class="tok-number">7</span> },</span>
<span class="line" id="L199">        <span class="tok-builtin">@Vector</span>(<span class="tok-number">2</span>, <span class="tok-type">u8</span>){ <span class="tok-number">8</span>, <span class="tok-number">9</span> },</span>
<span class="line" id="L200">    };</span>
<span class="line" id="L201"></span>
<span class="line" id="L202">    <span class="tok-kw">try</span> std.testing.expectEqual([<span class="tok-number">6</span>]<span class="tok-type">u32</span>{ <span class="tok-number">10</span>, <span class="tok-number">20</span>, <span class="tok-number">30</span>, <span class="tok-number">40</span>, <span class="tok-number">10</span>, <span class="tok-number">20</span> }, repeat(<span class="tok-number">6</span>, base));</span>
<span class="line" id="L203">    <span class="tok-kw">try</span> std.testing.expectEqual([<span class="tok-number">8</span>]<span class="tok-type">u32</span>{ <span class="tok-number">10</span>, <span class="tok-number">20</span>, <span class="tok-number">30</span>, <span class="tok-number">40</span>, <span class="tok-number">55</span>, <span class="tok-number">66</span>, <span class="tok-number">77</span>, <span class="tok-number">88</span> }, join(base, other_base));</span>
<span class="line" id="L204">    <span class="tok-kw">try</span> std.testing.expectEqual([<span class="tok-number">2</span>]<span class="tok-type">u32</span>{ <span class="tok-number">20</span>, <span class="tok-number">30</span> }, extract(base, <span class="tok-number">1</span>, <span class="tok-number">2</span>));</span>
<span class="line" id="L205"></span>
<span class="line" id="L206">    <span class="tok-kw">if</span> (<span class="tok-kw">comptime</span> !builtin.cpu.arch.isMIPS()) {</span>
<span class="line" id="L207">        <span class="tok-kw">try</span> std.testing.expectEqual([<span class="tok-number">8</span>]<span class="tok-type">u32</span>{ <span class="tok-number">10</span>, <span class="tok-number">55</span>, <span class="tok-number">20</span>, <span class="tok-number">66</span>, <span class="tok-number">30</span>, <span class="tok-number">77</span>, <span class="tok-number">40</span>, <span class="tok-number">88</span> }, interlace(.{ base, other_base }));</span>
<span class="line" id="L208"></span>
<span class="line" id="L209">        <span class="tok-kw">const</span> small_braid = interlace(small_bases);</span>
<span class="line" id="L210">        <span class="tok-kw">try</span> std.testing.expectEqual([<span class="tok-number">10</span>]<span class="tok-type">u8</span>{ <span class="tok-number">0</span>, <span class="tok-number">2</span>, <span class="tok-number">4</span>, <span class="tok-number">6</span>, <span class="tok-number">8</span>, <span class="tok-number">1</span>, <span class="tok-number">3</span>, <span class="tok-number">5</span>, <span class="tok-number">7</span>, <span class="tok-number">9</span> }, small_braid);</span>
<span class="line" id="L211">        <span class="tok-kw">try</span> std.testing.expectEqual(small_bases, deinterlace(small_bases.len, small_braid));</span>
<span class="line" id="L212">    }</span>
<span class="line" id="L213">}</span>
<span class="line" id="L214"></span>
<span class="line" id="L215"><span class="tok-comment">/// Joins two vectors, shifts them leftwards (towards lower indices) and extracts the leftmost elements into a vector the size of a and b.</span></span>
<span class="line" id="L216"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">mergeShift</span>(a: <span class="tok-kw">anytype</span>, b: <span class="tok-kw">anytype</span>, <span class="tok-kw">comptime</span> shift: VectorCount(<span class="tok-builtin">@TypeOf</span>(a, b))) <span class="tok-builtin">@TypeOf</span>(a, b) {</span>
<span class="line" id="L217">    <span class="tok-kw">const</span> len = vectorLength(<span class="tok-builtin">@TypeOf</span>(a, b));</span>
<span class="line" id="L218"></span>
<span class="line" id="L219">    <span class="tok-kw">return</span> extract(join(a, b), shift, len);</span>
<span class="line" id="L220">}</span>
<span class="line" id="L221"></span>
<span class="line" id="L222"><span class="tok-comment">/// Elements are shifted rightwards (towards higher indices). New elements are added to the left, and the rightmost elements are cut off</span></span>
<span class="line" id="L223"><span class="tok-comment">/// so that the size of the vector stays the same.</span></span>
<span class="line" id="L224"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">shiftElementsRight</span>(vec: <span class="tok-kw">anytype</span>, <span class="tok-kw">comptime</span> amount: VectorCount(<span class="tok-builtin">@TypeOf</span>(vec)), shift_in: std.meta.Child(<span class="tok-builtin">@TypeOf</span>(vec))) <span class="tok-builtin">@TypeOf</span>(vec) {</span>
<span class="line" id="L225">    <span class="tok-comment">// It may be possible to implement shifts and rotates with a runtime-friendly slice of two joined vectors, as the length of the</span>
</span>
<span class="line" id="L226">    <span class="tok-comment">// slice would be comptime-known. This would permit vector shifts and rotates by a non-comptime-known amount.</span>
</span>
<span class="line" id="L227">    <span class="tok-comment">// However, I am unsure whether compiler optimizations would handle that well enough on all platforms.</span>
</span>
<span class="line" id="L228">    <span class="tok-kw">const</span> len = vectorLength(<span class="tok-builtin">@TypeOf</span>(vec));</span>
<span class="line" id="L229"></span>
<span class="line" id="L230">    <span class="tok-kw">return</span> mergeShift(<span class="tok-builtin">@splat</span>(len, shift_in), vec, len - amount);</span>
<span class="line" id="L231">}</span>
<span class="line" id="L232"></span>
<span class="line" id="L233"><span class="tok-comment">/// Elements are shifted leftwards (towards lower indices). New elements are added to the right, and the leftmost elements are cut off</span></span>
<span class="line" id="L234"><span class="tok-comment">/// so that no elements with indices below 0 remain.</span></span>
<span class="line" id="L235"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">shiftElementsLeft</span>(vec: <span class="tok-kw">anytype</span>, <span class="tok-kw">comptime</span> amount: VectorCount(<span class="tok-builtin">@TypeOf</span>(vec)), shift_in: std.meta.Child(<span class="tok-builtin">@TypeOf</span>(vec))) <span class="tok-builtin">@TypeOf</span>(vec) {</span>
<span class="line" id="L236">    <span class="tok-kw">const</span> len = vectorLength(<span class="tok-builtin">@TypeOf</span>(vec));</span>
<span class="line" id="L237"></span>
<span class="line" id="L238">    <span class="tok-kw">return</span> mergeShift(vec, <span class="tok-builtin">@splat</span>(len, shift_in), amount);</span>
<span class="line" id="L239">}</span>
<span class="line" id="L240"></span>
<span class="line" id="L241"><span class="tok-comment">/// Elements are shifted leftwards (towards lower indices). Elements that leave to the left will reappear to the right in the same order.</span></span>
<span class="line" id="L242"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">rotateElementsLeft</span>(vec: <span class="tok-kw">anytype</span>, <span class="tok-kw">comptime</span> amount: VectorCount(<span class="tok-builtin">@TypeOf</span>(vec))) <span class="tok-builtin">@TypeOf</span>(vec) {</span>
<span class="line" id="L243">    <span class="tok-kw">return</span> mergeShift(vec, vec, amount);</span>
<span class="line" id="L244">}</span>
<span class="line" id="L245"></span>
<span class="line" id="L246"><span class="tok-comment">/// Elements are shifted rightwards (towards higher indices). Elements that leave to the right will reappear to the left in the same order.</span></span>
<span class="line" id="L247"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">rotateElementsRight</span>(vec: <span class="tok-kw">anytype</span>, <span class="tok-kw">comptime</span> amount: VectorCount(<span class="tok-builtin">@TypeOf</span>(vec))) <span class="tok-builtin">@TypeOf</span>(vec) {</span>
<span class="line" id="L248">    <span class="tok-kw">return</span> rotateElementsLeft(vec, vectorLength(<span class="tok-builtin">@TypeOf</span>(vec)) - amount);</span>
<span class="line" id="L249">}</span>
<span class="line" id="L250"></span>
<span class="line" id="L251"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">reverseOrder</span>(vec: <span class="tok-kw">anytype</span>) <span class="tok-builtin">@TypeOf</span>(vec) {</span>
<span class="line" id="L252">    <span class="tok-kw">const</span> Child = std.meta.Child(<span class="tok-builtin">@TypeOf</span>(vec));</span>
<span class="line" id="L253">    <span class="tok-kw">const</span> len = vectorLength(<span class="tok-builtin">@TypeOf</span>(vec));</span>
<span class="line" id="L254"></span>
<span class="line" id="L255">    <span class="tok-kw">return</span> <span class="tok-builtin">@shuffle</span>(Child, vec, <span class="tok-null">undefined</span>, <span class="tok-builtin">@splat</span>(len, <span class="tok-builtin">@intCast</span>(<span class="tok-type">i32</span>, len) - <span class="tok-number">1</span>) - iota(<span class="tok-type">i32</span>, len));</span>
<span class="line" id="L256">}</span>
<span class="line" id="L257"></span>
<span class="line" id="L258"><span class="tok-kw">test</span> <span class="tok-str">&quot;vector shifting&quot;</span> {</span>
<span class="line" id="L259">    <span class="tok-kw">const</span> base = <span class="tok-builtin">@Vector</span>(<span class="tok-number">4</span>, <span class="tok-type">u32</span>){ <span class="tok-number">10</span>, <span class="tok-number">20</span>, <span class="tok-number">30</span>, <span class="tok-number">40</span> };</span>
<span class="line" id="L260"></span>
<span class="line" id="L261">    <span class="tok-kw">try</span> std.testing.expectEqual([<span class="tok-number">4</span>]<span class="tok-type">u32</span>{ <span class="tok-number">30</span>, <span class="tok-number">40</span>, <span class="tok-number">999</span>, <span class="tok-number">999</span> }, shiftElementsLeft(base, <span class="tok-number">2</span>, <span class="tok-number">999</span>));</span>
<span class="line" id="L262">    <span class="tok-kw">try</span> std.testing.expectEqual([<span class="tok-number">4</span>]<span class="tok-type">u32</span>{ <span class="tok-number">999</span>, <span class="tok-number">999</span>, <span class="tok-number">10</span>, <span class="tok-number">20</span> }, shiftElementsRight(base, <span class="tok-number">2</span>, <span class="tok-number">999</span>));</span>
<span class="line" id="L263">    <span class="tok-kw">try</span> std.testing.expectEqual([<span class="tok-number">4</span>]<span class="tok-type">u32</span>{ <span class="tok-number">20</span>, <span class="tok-number">30</span>, <span class="tok-number">40</span>, <span class="tok-number">10</span> }, rotateElementsLeft(base, <span class="tok-number">1</span>));</span>
<span class="line" id="L264">    <span class="tok-kw">try</span> std.testing.expectEqual([<span class="tok-number">4</span>]<span class="tok-type">u32</span>{ <span class="tok-number">40</span>, <span class="tok-number">10</span>, <span class="tok-number">20</span>, <span class="tok-number">30</span> }, rotateElementsRight(base, <span class="tok-number">1</span>));</span>
<span class="line" id="L265">    <span class="tok-kw">try</span> std.testing.expectEqual([<span class="tok-number">4</span>]<span class="tok-type">u32</span>{ <span class="tok-number">40</span>, <span class="tok-number">30</span>, <span class="tok-number">20</span>, <span class="tok-number">10</span> }, reverseOrder(base));</span>
<span class="line" id="L266">}</span>
<span class="line" id="L267"></span>
<span class="line" id="L268"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">firstTrue</span>(vec: <span class="tok-kw">anytype</span>) ?VectorIndex(<span class="tok-builtin">@TypeOf</span>(vec)) {</span>
<span class="line" id="L269">    <span class="tok-kw">const</span> len = vectorLength(<span class="tok-builtin">@TypeOf</span>(vec));</span>
<span class="line" id="L270">    <span class="tok-kw">const</span> IndexInt = VectorIndex(<span class="tok-builtin">@TypeOf</span>(vec));</span>
<span class="line" id="L271"></span>
<span class="line" id="L272">    <span class="tok-kw">if</span> (!<span class="tok-builtin">@reduce</span>(.Or, vec)) {</span>
<span class="line" id="L273">        <span class="tok-kw">return</span> <span class="tok-null">null</span>;</span>
<span class="line" id="L274">    }</span>
<span class="line" id="L275">    <span class="tok-kw">const</span> indices = <span class="tok-builtin">@select</span>(IndexInt, vec, iota(IndexInt, len), <span class="tok-builtin">@splat</span>(len, ~<span class="tok-builtin">@as</span>(IndexInt, <span class="tok-number">0</span>)));</span>
<span class="line" id="L276">    <span class="tok-kw">return</span> <span class="tok-builtin">@reduce</span>(.Min, indices);</span>
<span class="line" id="L277">}</span>
<span class="line" id="L278"></span>
<span class="line" id="L279"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">lastTrue</span>(vec: <span class="tok-kw">anytype</span>) ?VectorIndex(<span class="tok-builtin">@TypeOf</span>(vec)) {</span>
<span class="line" id="L280">    <span class="tok-kw">const</span> len = vectorLength(<span class="tok-builtin">@TypeOf</span>(vec));</span>
<span class="line" id="L281">    <span class="tok-kw">const</span> IndexInt = VectorIndex(<span class="tok-builtin">@TypeOf</span>(vec));</span>
<span class="line" id="L282"></span>
<span class="line" id="L283">    <span class="tok-kw">if</span> (!<span class="tok-builtin">@reduce</span>(.Or, vec)) {</span>
<span class="line" id="L284">        <span class="tok-kw">return</span> <span class="tok-null">null</span>;</span>
<span class="line" id="L285">    }</span>
<span class="line" id="L286">    <span class="tok-kw">const</span> indices = <span class="tok-builtin">@select</span>(IndexInt, vec, iota(IndexInt, len), <span class="tok-builtin">@splat</span>(len, <span class="tok-builtin">@as</span>(IndexInt, <span class="tok-number">0</span>)));</span>
<span class="line" id="L287">    <span class="tok-kw">return</span> <span class="tok-builtin">@reduce</span>(.Max, indices);</span>
<span class="line" id="L288">}</span>
<span class="line" id="L289"></span>
<span class="line" id="L290"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">countTrues</span>(vec: <span class="tok-kw">anytype</span>) VectorCount(<span class="tok-builtin">@TypeOf</span>(vec)) {</span>
<span class="line" id="L291">    <span class="tok-kw">const</span> len = vectorLength(<span class="tok-builtin">@TypeOf</span>(vec));</span>
<span class="line" id="L292">    <span class="tok-kw">const</span> CountIntType = VectorCount(<span class="tok-builtin">@TypeOf</span>(vec));</span>
<span class="line" id="L293"></span>
<span class="line" id="L294">    <span class="tok-kw">const</span> one_if_true = <span class="tok-builtin">@select</span>(CountIntType, vec, <span class="tok-builtin">@splat</span>(len, <span class="tok-builtin">@as</span>(CountIntType, <span class="tok-number">1</span>)), <span class="tok-builtin">@splat</span>(len, <span class="tok-builtin">@as</span>(CountIntType, <span class="tok-number">0</span>)));</span>
<span class="line" id="L295">    <span class="tok-kw">return</span> <span class="tok-builtin">@reduce</span>(.Add, one_if_true);</span>
<span class="line" id="L296">}</span>
<span class="line" id="L297"></span>
<span class="line" id="L298"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">firstIndexOfValue</span>(vec: <span class="tok-kw">anytype</span>, value: std.meta.Child(<span class="tok-builtin">@TypeOf</span>(vec))) ?VectorIndex(<span class="tok-builtin">@TypeOf</span>(vec)) {</span>
<span class="line" id="L299">    <span class="tok-kw">const</span> len = vectorLength(<span class="tok-builtin">@TypeOf</span>(vec));</span>
<span class="line" id="L300"></span>
<span class="line" id="L301">    <span class="tok-kw">return</span> firstTrue(vec == <span class="tok-builtin">@splat</span>(len, value));</span>
<span class="line" id="L302">}</span>
<span class="line" id="L303"></span>
<span class="line" id="L304"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">lastIndexOfValue</span>(vec: <span class="tok-kw">anytype</span>, value: std.meta.Child(<span class="tok-builtin">@TypeOf</span>(vec))) ?VectorIndex(<span class="tok-builtin">@TypeOf</span>(vec)) {</span>
<span class="line" id="L305">    <span class="tok-kw">const</span> len = vectorLength(<span class="tok-builtin">@TypeOf</span>(vec));</span>
<span class="line" id="L306"></span>
<span class="line" id="L307">    <span class="tok-kw">return</span> lastTrue(vec == <span class="tok-builtin">@splat</span>(len, value));</span>
<span class="line" id="L308">}</span>
<span class="line" id="L309"></span>
<span class="line" id="L310"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">countElementsWithValue</span>(vec: <span class="tok-kw">anytype</span>, value: std.meta.Child(<span class="tok-builtin">@TypeOf</span>(vec))) VectorCount(<span class="tok-builtin">@TypeOf</span>(vec)) {</span>
<span class="line" id="L311">    <span class="tok-kw">const</span> len = vectorLength(<span class="tok-builtin">@TypeOf</span>(vec));</span>
<span class="line" id="L312"></span>
<span class="line" id="L313">    <span class="tok-kw">return</span> countTrues(vec == <span class="tok-builtin">@splat</span>(len, value));</span>
<span class="line" id="L314">}</span>
<span class="line" id="L315"></span>
<span class="line" id="L316"><span class="tok-kw">test</span> <span class="tok-str">&quot;vector searching&quot;</span> {</span>
<span class="line" id="L317">    <span class="tok-kw">const</span> base = <span class="tok-builtin">@Vector</span>(<span class="tok-number">8</span>, <span class="tok-type">u32</span>){ <span class="tok-number">6</span>, <span class="tok-number">4</span>, <span class="tok-number">7</span>, <span class="tok-number">4</span>, <span class="tok-number">4</span>, <span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">7</span> };</span>
<span class="line" id="L318"></span>
<span class="line" id="L319">    <span class="tok-kw">try</span> std.testing.expectEqual(<span class="tok-builtin">@as</span>(?<span class="tok-type">u3</span>, <span class="tok-number">1</span>), firstIndexOfValue(base, <span class="tok-number">4</span>));</span>
<span class="line" id="L320">    <span class="tok-kw">try</span> std.testing.expectEqual(<span class="tok-builtin">@as</span>(?<span class="tok-type">u3</span>, <span class="tok-number">4</span>), lastIndexOfValue(base, <span class="tok-number">4</span>));</span>
<span class="line" id="L321">    <span class="tok-kw">try</span> std.testing.expectEqual(<span class="tok-builtin">@as</span>(?<span class="tok-type">u3</span>, <span class="tok-null">null</span>), lastIndexOfValue(base, <span class="tok-number">99</span>));</span>
<span class="line" id="L322">    <span class="tok-kw">try</span> std.testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">u4</span>, <span class="tok-number">3</span>), countElementsWithValue(base, <span class="tok-number">4</span>));</span>
<span class="line" id="L323">}</span>
<span class="line" id="L324"></span>
<span class="line" id="L325"><span class="tok-comment">/// Same as prefixScan, but with a user-provided, mathematically associative function.</span></span>
<span class="line" id="L326"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">prefixScanWithFunc</span>(</span>
<span class="line" id="L327">    <span class="tok-kw">comptime</span> hop: <span class="tok-type">isize</span>,</span>
<span class="line" id="L328">    vec: <span class="tok-kw">anytype</span>,</span>
<span class="line" id="L329">    <span class="tok-comment">/// The error type that `func` might return. Set this to `void` if `func` doesn't return an error union.</span></span>
<span class="line" id="L330">    <span class="tok-kw">comptime</span> ErrorType: <span class="tok-type">type</span>,</span>
<span class="line" id="L331">    <span class="tok-kw">comptime</span> func: <span class="tok-kw">fn</span> (<span class="tok-builtin">@TypeOf</span>(vec), <span class="tok-builtin">@TypeOf</span>(vec)) <span class="tok-kw">if</span> (ErrorType == <span class="tok-type">void</span>) <span class="tok-builtin">@TypeOf</span>(vec) <span class="tok-kw">else</span> ErrorType!<span class="tok-builtin">@TypeOf</span>(vec),</span>
<span class="line" id="L332">    <span class="tok-comment">/// When one operand of the operation performed by `func` is this value, the result must equal the other operand.</span></span>
<span class="line" id="L333">    <span class="tok-comment">/// For example, this should be 0 for addition or 1 for multiplication.</span></span>
<span class="line" id="L334">    <span class="tok-kw">comptime</span> identity: std.meta.Child(<span class="tok-builtin">@TypeOf</span>(vec)),</span>
<span class="line" id="L335">) <span class="tok-kw">if</span> (ErrorType == <span class="tok-type">void</span>) <span class="tok-builtin">@TypeOf</span>(vec) <span class="tok-kw">else</span> ErrorType!<span class="tok-builtin">@TypeOf</span>(vec) {</span>
<span class="line" id="L336">    <span class="tok-comment">// I haven't debugged this, but it might be a cousin of sorts to what's going on with interlace.</span>
</span>
<span class="line" id="L337">    <span class="tok-kw">comptime</span> <span class="tok-kw">if</span> (builtin.cpu.arch.isMIPS()) <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;TODO: Find out why prefixScan doesn't work on MIPS&quot;</span>);</span>
<span class="line" id="L338"></span>
<span class="line" id="L339">    <span class="tok-kw">const</span> len = vectorLength(<span class="tok-builtin">@TypeOf</span>(vec));</span>
<span class="line" id="L340"></span>
<span class="line" id="L341">    <span class="tok-kw">if</span> (hop == <span class="tok-number">0</span>) <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;hop can not be 0; you'd be going nowhere forever!&quot;</span>);</span>
<span class="line" id="L342">    <span class="tok-kw">const</span> abs_hop = <span class="tok-kw">if</span> (hop &lt; <span class="tok-number">0</span>) -hop <span class="tok-kw">else</span> hop;</span>
<span class="line" id="L343"></span>
<span class="line" id="L344">    <span class="tok-kw">var</span> acc = vec;</span>
<span class="line" id="L345">    <span class="tok-kw">comptime</span> <span class="tok-kw">var</span> i = <span class="tok-number">0</span>;</span>
<span class="line" id="L346">    <span class="tok-kw">inline</span> <span class="tok-kw">while</span> ((abs_hop &lt;&lt; i) &lt; len) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L347">        <span class="tok-kw">const</span> shifted = <span class="tok-kw">if</span> (hop &lt; <span class="tok-number">0</span>) shiftElementsLeft(acc, abs_hop &lt;&lt; i, identity) <span class="tok-kw">else</span> shiftElementsRight(acc, abs_hop &lt;&lt; i, identity);</span>
<span class="line" id="L348"></span>
<span class="line" id="L349">        acc = <span class="tok-kw">if</span> (ErrorType == <span class="tok-type">void</span>) func(acc, shifted) <span class="tok-kw">else</span> <span class="tok-kw">try</span> func(acc, shifted);</span>
<span class="line" id="L350">    }</span>
<span class="line" id="L351">    <span class="tok-kw">return</span> acc;</span>
<span class="line" id="L352">}</span>
<span class="line" id="L353"></span>
<span class="line" id="L354"><span class="tok-comment">/// Returns a vector whose elements are the result of performing the specified operation on the corresponding</span></span>
<span class="line" id="L355"><span class="tok-comment">/// element of the input vector and every hop'th element that came before it (or after, if hop is negative).</span></span>
<span class="line" id="L356"><span class="tok-comment">/// Supports the same operations as the @reduce() builtin. Takes O(logN) to compute.</span></span>
<span class="line" id="L357"><span class="tok-comment">/// The scan is not linear, which may affect floating point errors. This may affect the determinism of</span></span>
<span class="line" id="L358"><span class="tok-comment">/// algorithms that use this function.</span></span>
<span class="line" id="L359"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">prefixScan</span>(<span class="tok-kw">comptime</span> op: std.builtin.ReduceOp, <span class="tok-kw">comptime</span> hop: <span class="tok-type">isize</span>, vec: <span class="tok-kw">anytype</span>) <span class="tok-builtin">@TypeOf</span>(vec) {</span>
<span class="line" id="L360">    <span class="tok-kw">const</span> VecType = <span class="tok-builtin">@TypeOf</span>(vec);</span>
<span class="line" id="L361">    <span class="tok-kw">const</span> Child = std.meta.Child(VecType);</span>
<span class="line" id="L362">    <span class="tok-kw">const</span> len = vectorLength(VecType);</span>
<span class="line" id="L363"></span>
<span class="line" id="L364">    <span class="tok-kw">const</span> identity = <span class="tok-kw">comptime</span> <span class="tok-kw">switch</span> (<span class="tok-builtin">@typeInfo</span>(Child)) {</span>
<span class="line" id="L365">        .Bool =&gt; <span class="tok-kw">switch</span> (op) {</span>
<span class="line" id="L366">            .Or, .Xor =&gt; <span class="tok-null">false</span>,</span>
<span class="line" id="L367">            .And =&gt; <span class="tok-null">true</span>,</span>
<span class="line" id="L368">            <span class="tok-kw">else</span> =&gt; <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;Invalid prefixScan operation &quot;</span> ++ <span class="tok-builtin">@tagName</span>(op) ++ <span class="tok-str">&quot; for vector of booleans.&quot;</span>),</span>
<span class="line" id="L369">        },</span>
<span class="line" id="L370">        .Int =&gt; <span class="tok-kw">switch</span> (op) {</span>
<span class="line" id="L371">            .Max =&gt; std.math.minInt(Child),</span>
<span class="line" id="L372">            .Add, .Or, .Xor =&gt; <span class="tok-number">0</span>,</span>
<span class="line" id="L373">            .Mul =&gt; <span class="tok-number">1</span>,</span>
<span class="line" id="L374">            .And, .Min =&gt; std.math.maxInt(Child),</span>
<span class="line" id="L375">        },</span>
<span class="line" id="L376">        .Float =&gt; <span class="tok-kw">switch</span> (op) {</span>
<span class="line" id="L377">            .Max =&gt; -std.math.inf(Child),</span>
<span class="line" id="L378">            .Add =&gt; <span class="tok-number">0</span>,</span>
<span class="line" id="L379">            .Mul =&gt; <span class="tok-number">1</span>,</span>
<span class="line" id="L380">            .Min =&gt; std.math.inf(Child),</span>
<span class="line" id="L381">            <span class="tok-kw">else</span> =&gt; <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;Invalid prefixScan operation &quot;</span> ++ <span class="tok-builtin">@tagName</span>(op) ++ <span class="tok-str">&quot; for vector of floats.&quot;</span>),</span>
<span class="line" id="L382">        },</span>
<span class="line" id="L383">        <span class="tok-kw">else</span> =&gt; <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;Invalid type &quot;</span> ++ <span class="tok-builtin">@typeName</span>(VecType) ++ <span class="tok-str">&quot; for prefixScan.&quot;</span>),</span>
<span class="line" id="L384">    };</span>
<span class="line" id="L385"></span>
<span class="line" id="L386">    <span class="tok-kw">const</span> fn_container = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L387">        <span class="tok-kw">fn</span> <span class="tok-fn">opFn</span>(a: VecType, b: VecType) VecType {</span>
<span class="line" id="L388">            <span class="tok-kw">return</span> <span class="tok-kw">if</span> (Child == <span class="tok-type">bool</span>) <span class="tok-kw">switch</span> (op) {</span>
<span class="line" id="L389">                .And =&gt; <span class="tok-builtin">@select</span>(<span class="tok-type">bool</span>, a, b, <span class="tok-builtin">@splat</span>(len, <span class="tok-null">false</span>)),</span>
<span class="line" id="L390">                .Or =&gt; <span class="tok-builtin">@select</span>(<span class="tok-type">bool</span>, a, <span class="tok-builtin">@splat</span>(len, <span class="tok-null">true</span>), b),</span>
<span class="line" id="L391">                .Xor =&gt; a != b,</span>
<span class="line" id="L392">                <span class="tok-kw">else</span> =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L393">            } <span class="tok-kw">else</span> <span class="tok-kw">switch</span> (op) {</span>
<span class="line" id="L394">                .And =&gt; a &amp; b,</span>
<span class="line" id="L395">                .Or =&gt; a | b,</span>
<span class="line" id="L396">                .Xor =&gt; a ^ b,</span>
<span class="line" id="L397">                .Add =&gt; a + b,</span>
<span class="line" id="L398">                .Mul =&gt; a * b,</span>
<span class="line" id="L399">                .Min =&gt; <span class="tok-builtin">@minimum</span>(a, b),</span>
<span class="line" id="L400">                .Max =&gt; <span class="tok-builtin">@maximum</span>(a, b),</span>
<span class="line" id="L401">            };</span>
<span class="line" id="L402">        }</span>
<span class="line" id="L403">    };</span>
<span class="line" id="L404"></span>
<span class="line" id="L405">    <span class="tok-kw">return</span> prefixScanWithFunc(hop, vec, <span class="tok-type">void</span>, fn_container.opFn, identity);</span>
<span class="line" id="L406">}</span>
<span class="line" id="L407"></span>
<span class="line" id="L408"><span class="tok-kw">test</span> <span class="tok-str">&quot;vector prefix scan&quot;</span> {</span>
<span class="line" id="L409">    <span class="tok-kw">if</span> (<span class="tok-kw">comptime</span> builtin.cpu.arch.isMIPS()) {</span>
<span class="line" id="L410">        <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SkipZigTest;</span>
<span class="line" id="L411">    }</span>
<span class="line" id="L412"></span>
<span class="line" id="L413">    <span class="tok-kw">if</span> (builtin.zig_backend == .stage1 <span class="tok-kw">or</span> builtin.zig_backend == .stage2_llvm) {</span>
<span class="line" id="L414">        <span class="tok-comment">// Regressed in LLVM 14:</span>
</span>
<span class="line" id="L415">        <span class="tok-comment">// https://github.com/llvm/llvm-project/issues/55522</span>
</span>
<span class="line" id="L416">        <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SkipZigTest;</span>
<span class="line" id="L417">    }</span>
<span class="line" id="L418"></span>
<span class="line" id="L419">    <span class="tok-kw">const</span> int_base = <span class="tok-builtin">@Vector</span>(<span class="tok-number">4</span>, <span class="tok-type">i32</span>){ <span class="tok-number">11</span>, <span class="tok-number">23</span>, <span class="tok-number">9</span>, -<span class="tok-number">21</span> };</span>
<span class="line" id="L420">    <span class="tok-kw">const</span> float_base = <span class="tok-builtin">@Vector</span>(<span class="tok-number">4</span>, <span class="tok-type">f32</span>){ <span class="tok-number">2</span>, <span class="tok-number">0.5</span>, -<span class="tok-number">10</span>, <span class="tok-number">6.54321</span> };</span>
<span class="line" id="L421">    <span class="tok-kw">const</span> bool_base = <span class="tok-builtin">@Vector</span>(<span class="tok-number">4</span>, <span class="tok-type">bool</span>){ <span class="tok-null">true</span>, <span class="tok-null">false</span>, <span class="tok-null">true</span>, <span class="tok-null">false</span> };</span>
<span class="line" id="L422"></span>
<span class="line" id="L423">    <span class="tok-kw">try</span> std.testing.expectEqual(iota(<span class="tok-type">u8</span>, <span class="tok-number">32</span>) + <span class="tok-builtin">@splat</span>(<span class="tok-number">32</span>, <span class="tok-builtin">@as</span>(<span class="tok-type">u8</span>, <span class="tok-number">1</span>)), prefixScan(.Add, <span class="tok-number">1</span>, <span class="tok-builtin">@splat</span>(<span class="tok-number">32</span>, <span class="tok-builtin">@as</span>(<span class="tok-type">u8</span>, <span class="tok-number">1</span>))));</span>
<span class="line" id="L424">    <span class="tok-kw">try</span> std.testing.expectEqual(<span class="tok-builtin">@Vector</span>(<span class="tok-number">4</span>, <span class="tok-type">i32</span>){ <span class="tok-number">11</span>, <span class="tok-number">3</span>, <span class="tok-number">1</span>, <span class="tok-number">1</span> }, prefixScan(.And, <span class="tok-number">1</span>, int_base));</span>
<span class="line" id="L425">    <span class="tok-kw">try</span> std.testing.expectEqual(<span class="tok-builtin">@Vector</span>(<span class="tok-number">4</span>, <span class="tok-type">i32</span>){ <span class="tok-number">11</span>, <span class="tok-number">31</span>, <span class="tok-number">31</span>, -<span class="tok-number">1</span> }, prefixScan(.Or, <span class="tok-number">1</span>, int_base));</span>
<span class="line" id="L426">    <span class="tok-kw">try</span> std.testing.expectEqual(<span class="tok-builtin">@Vector</span>(<span class="tok-number">4</span>, <span class="tok-type">i32</span>){ <span class="tok-number">11</span>, <span class="tok-number">28</span>, <span class="tok-number">21</span>, -<span class="tok-number">2</span> }, prefixScan(.Xor, <span class="tok-number">1</span>, int_base));</span>
<span class="line" id="L427">    <span class="tok-kw">try</span> std.testing.expectEqual(<span class="tok-builtin">@Vector</span>(<span class="tok-number">4</span>, <span class="tok-type">i32</span>){ <span class="tok-number">11</span>, <span class="tok-number">34</span>, <span class="tok-number">43</span>, <span class="tok-number">22</span> }, prefixScan(.Add, <span class="tok-number">1</span>, int_base));</span>
<span class="line" id="L428">    <span class="tok-kw">try</span> std.testing.expectEqual(<span class="tok-builtin">@Vector</span>(<span class="tok-number">4</span>, <span class="tok-type">i32</span>){ <span class="tok-number">11</span>, <span class="tok-number">253</span>, <span class="tok-number">2277</span>, -<span class="tok-number">47817</span> }, prefixScan(.Mul, <span class="tok-number">1</span>, int_base));</span>
<span class="line" id="L429">    <span class="tok-kw">try</span> std.testing.expectEqual(<span class="tok-builtin">@Vector</span>(<span class="tok-number">4</span>, <span class="tok-type">i32</span>){ <span class="tok-number">11</span>, <span class="tok-number">11</span>, <span class="tok-number">9</span>, -<span class="tok-number">21</span> }, prefixScan(.Min, <span class="tok-number">1</span>, int_base));</span>
<span class="line" id="L430">    <span class="tok-kw">try</span> std.testing.expectEqual(<span class="tok-builtin">@Vector</span>(<span class="tok-number">4</span>, <span class="tok-type">i32</span>){ <span class="tok-number">11</span>, <span class="tok-number">23</span>, <span class="tok-number">23</span>, <span class="tok-number">23</span> }, prefixScan(.Max, <span class="tok-number">1</span>, int_base));</span>
<span class="line" id="L431"></span>
<span class="line" id="L432">    <span class="tok-comment">// Trying to predict all inaccuracies when adding and multiplying floats with prefixScans would be a mess, so we don't test those.</span>
</span>
<span class="line" id="L433">    <span class="tok-kw">try</span> std.testing.expectEqual(<span class="tok-builtin">@Vector</span>(<span class="tok-number">4</span>, <span class="tok-type">f32</span>){ <span class="tok-number">2</span>, <span class="tok-number">0.5</span>, -<span class="tok-number">10</span>, -<span class="tok-number">10</span> }, prefixScan(.Min, <span class="tok-number">1</span>, float_base));</span>
<span class="line" id="L434">    <span class="tok-kw">try</span> std.testing.expectEqual(<span class="tok-builtin">@Vector</span>(<span class="tok-number">4</span>, <span class="tok-type">f32</span>){ <span class="tok-number">2</span>, <span class="tok-number">2</span>, <span class="tok-number">2</span>, <span class="tok-number">6.54321</span> }, prefixScan(.Max, <span class="tok-number">1</span>, float_base));</span>
<span class="line" id="L435"></span>
<span class="line" id="L436">    <span class="tok-kw">try</span> std.testing.expectEqual(<span class="tok-builtin">@Vector</span>(<span class="tok-number">4</span>, <span class="tok-type">bool</span>){ <span class="tok-null">true</span>, <span class="tok-null">true</span>, <span class="tok-null">false</span>, <span class="tok-null">false</span> }, prefixScan(.Xor, <span class="tok-number">1</span>, bool_base));</span>
<span class="line" id="L437">    <span class="tok-kw">try</span> std.testing.expectEqual(<span class="tok-builtin">@Vector</span>(<span class="tok-number">4</span>, <span class="tok-type">bool</span>){ <span class="tok-null">true</span>, <span class="tok-null">true</span>, <span class="tok-null">true</span>, <span class="tok-null">true</span> }, prefixScan(.Or, <span class="tok-number">1</span>, bool_base));</span>
<span class="line" id="L438">    <span class="tok-kw">try</span> std.testing.expectEqual(<span class="tok-builtin">@Vector</span>(<span class="tok-number">4</span>, <span class="tok-type">bool</span>){ <span class="tok-null">true</span>, <span class="tok-null">false</span>, <span class="tok-null">false</span>, <span class="tok-null">false</span> }, prefixScan(.And, <span class="tok-number">1</span>, bool_base));</span>
<span class="line" id="L439"></span>
<span class="line" id="L440">    <span class="tok-kw">try</span> std.testing.expectEqual(<span class="tok-builtin">@Vector</span>(<span class="tok-number">4</span>, <span class="tok-type">i32</span>){ <span class="tok-number">11</span>, <span class="tok-number">23</span>, <span class="tok-number">20</span>, <span class="tok-number">2</span> }, prefixScan(.Add, <span class="tok-number">2</span>, int_base));</span>
<span class="line" id="L441">    <span class="tok-kw">try</span> std.testing.expectEqual(<span class="tok-builtin">@Vector</span>(<span class="tok-number">4</span>, <span class="tok-type">i32</span>){ <span class="tok-number">22</span>, <span class="tok-number">11</span>, -<span class="tok-number">12</span>, -<span class="tok-number">21</span> }, prefixScan(.Add, -<span class="tok-number">1</span>, int_base));</span>
<span class="line" id="L442">    <span class="tok-kw">try</span> std.testing.expectEqual(<span class="tok-builtin">@Vector</span>(<span class="tok-number">4</span>, <span class="tok-type">i32</span>){ <span class="tok-number">11</span>, <span class="tok-number">23</span>, <span class="tok-number">9</span>, -<span class="tok-number">10</span> }, prefixScan(.Add, <span class="tok-number">3</span>, int_base));</span>
<span class="line" id="L443">}</span>
<span class="line" id="L444"></span>
</code></pre></body>
</html>