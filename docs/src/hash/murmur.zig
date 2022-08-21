<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">    <title>hash/murmur.zig - source view</title>
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
<span class="line" id="L3"><span class="tok-kw">const</span> testing = std.testing;</span>
<span class="line" id="L4"><span class="tok-kw">const</span> native_endian = builtin.target.cpu.arch.endian();</span>
<span class="line" id="L5"></span>
<span class="line" id="L6"><span class="tok-kw">const</span> default_seed: <span class="tok-type">u32</span> = <span class="tok-number">0xc70f6907</span>;</span>
<span class="line" id="L7"></span>
<span class="line" id="L8"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> Murmur2_32 = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L9">    <span class="tok-kw">const</span> Self = <span class="tok-builtin">@This</span>();</span>
<span class="line" id="L10"></span>
<span class="line" id="L11">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">hash</span>(str: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) <span class="tok-type">u32</span> {</span>
<span class="line" id="L12">        <span class="tok-kw">return</span> <span class="tok-builtin">@call</span>(.{ .modifier = .always_inline }, Self.hashWithSeed, .{ str, default_seed });</span>
<span class="line" id="L13">    }</span>
<span class="line" id="L14"></span>
<span class="line" id="L15">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">hashWithSeed</span>(str: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, seed: <span class="tok-type">u32</span>) <span class="tok-type">u32</span> {</span>
<span class="line" id="L16">        <span class="tok-kw">const</span> m: <span class="tok-type">u32</span> = <span class="tok-number">0x5bd1e995</span>;</span>
<span class="line" id="L17">        <span class="tok-kw">const</span> len = <span class="tok-builtin">@truncate</span>(<span class="tok-type">u32</span>, str.len);</span>
<span class="line" id="L18">        <span class="tok-kw">var</span> h1: <span class="tok-type">u32</span> = seed ^ len;</span>
<span class="line" id="L19">        <span class="tok-kw">for</span> (<span class="tok-builtin">@ptrCast</span>([*]<span class="tok-kw">align</span>(<span class="tok-number">1</span>) <span class="tok-kw">const</span> <span class="tok-type">u32</span>, str.ptr)[<span class="tok-number">0</span>..(len &gt;&gt; <span class="tok-number">2</span>)]) |v| {</span>
<span class="line" id="L20">            <span class="tok-kw">var</span> k1: <span class="tok-type">u32</span> = v;</span>
<span class="line" id="L21">            <span class="tok-kw">if</span> (native_endian == .Big)</span>
<span class="line" id="L22">                k1 = <span class="tok-builtin">@byteSwap</span>(<span class="tok-type">u32</span>, k1);</span>
<span class="line" id="L23">            k1 *%= m;</span>
<span class="line" id="L24">            k1 ^= k1 &gt;&gt; <span class="tok-number">24</span>;</span>
<span class="line" id="L25">            k1 *%= m;</span>
<span class="line" id="L26">            h1 *%= m;</span>
<span class="line" id="L27">            h1 ^= k1;</span>
<span class="line" id="L28">        }</span>
<span class="line" id="L29">        <span class="tok-kw">const</span> offset = len &amp; <span class="tok-number">0xfffffffc</span>;</span>
<span class="line" id="L30">        <span class="tok-kw">const</span> rest = len &amp; <span class="tok-number">3</span>;</span>
<span class="line" id="L31">        <span class="tok-kw">if</span> (rest &gt;= <span class="tok-number">3</span>) {</span>
<span class="line" id="L32">            h1 ^= <span class="tok-builtin">@intCast</span>(<span class="tok-type">u32</span>, str[offset + <span class="tok-number">2</span>]) &lt;&lt; <span class="tok-number">16</span>;</span>
<span class="line" id="L33">        }</span>
<span class="line" id="L34">        <span class="tok-kw">if</span> (rest &gt;= <span class="tok-number">2</span>) {</span>
<span class="line" id="L35">            h1 ^= <span class="tok-builtin">@intCast</span>(<span class="tok-type">u32</span>, str[offset + <span class="tok-number">1</span>]) &lt;&lt; <span class="tok-number">8</span>;</span>
<span class="line" id="L36">        }</span>
<span class="line" id="L37">        <span class="tok-kw">if</span> (rest &gt;= <span class="tok-number">1</span>) {</span>
<span class="line" id="L38">            h1 ^= <span class="tok-builtin">@intCast</span>(<span class="tok-type">u32</span>, str[offset + <span class="tok-number">0</span>]);</span>
<span class="line" id="L39">            h1 *%= m;</span>
<span class="line" id="L40">        }</span>
<span class="line" id="L41">        h1 ^= h1 &gt;&gt; <span class="tok-number">13</span>;</span>
<span class="line" id="L42">        h1 *%= m;</span>
<span class="line" id="L43">        h1 ^= h1 &gt;&gt; <span class="tok-number">15</span>;</span>
<span class="line" id="L44">        <span class="tok-kw">return</span> h1;</span>
<span class="line" id="L45">    }</span>
<span class="line" id="L46"></span>
<span class="line" id="L47">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">hashUint32</span>(v: <span class="tok-type">u32</span>) <span class="tok-type">u32</span> {</span>
<span class="line" id="L48">        <span class="tok-kw">return</span> <span class="tok-builtin">@call</span>(.{ .modifier = .always_inline }, Self.hashUint32WithSeed, .{ v, default_seed });</span>
<span class="line" id="L49">    }</span>
<span class="line" id="L50"></span>
<span class="line" id="L51">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">hashUint32WithSeed</span>(v: <span class="tok-type">u32</span>, seed: <span class="tok-type">u32</span>) <span class="tok-type">u32</span> {</span>
<span class="line" id="L52">        <span class="tok-kw">const</span> m: <span class="tok-type">u32</span> = <span class="tok-number">0x5bd1e995</span>;</span>
<span class="line" id="L53">        <span class="tok-kw">const</span> len: <span class="tok-type">u32</span> = <span class="tok-number">4</span>;</span>
<span class="line" id="L54">        <span class="tok-kw">var</span> h1: <span class="tok-type">u32</span> = seed ^ len;</span>
<span class="line" id="L55">        <span class="tok-kw">var</span> k1: <span class="tok-type">u32</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L56">        k1 = v *% m;</span>
<span class="line" id="L57">        k1 ^= k1 &gt;&gt; <span class="tok-number">24</span>;</span>
<span class="line" id="L58">        k1 *%= m;</span>
<span class="line" id="L59">        h1 *%= m;</span>
<span class="line" id="L60">        h1 ^= k1;</span>
<span class="line" id="L61">        h1 ^= h1 &gt;&gt; <span class="tok-number">13</span>;</span>
<span class="line" id="L62">        h1 *%= m;</span>
<span class="line" id="L63">        h1 ^= h1 &gt;&gt; <span class="tok-number">15</span>;</span>
<span class="line" id="L64">        <span class="tok-kw">return</span> h1;</span>
<span class="line" id="L65">    }</span>
<span class="line" id="L66"></span>
<span class="line" id="L67">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">hashUint64</span>(v: <span class="tok-type">u64</span>) <span class="tok-type">u32</span> {</span>
<span class="line" id="L68">        <span class="tok-kw">return</span> <span class="tok-builtin">@call</span>(.{ .modifier = .always_inline }, Self.hashUint64WithSeed, .{ v, default_seed });</span>
<span class="line" id="L69">    }</span>
<span class="line" id="L70"></span>
<span class="line" id="L71">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">hashUint64WithSeed</span>(v: <span class="tok-type">u64</span>, seed: <span class="tok-type">u32</span>) <span class="tok-type">u32</span> {</span>
<span class="line" id="L72">        <span class="tok-kw">const</span> m: <span class="tok-type">u32</span> = <span class="tok-number">0x5bd1e995</span>;</span>
<span class="line" id="L73">        <span class="tok-kw">const</span> len: <span class="tok-type">u32</span> = <span class="tok-number">8</span>;</span>
<span class="line" id="L74">        <span class="tok-kw">var</span> h1: <span class="tok-type">u32</span> = seed ^ len;</span>
<span class="line" id="L75">        <span class="tok-kw">var</span> k1: <span class="tok-type">u32</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L76">        k1 = <span class="tok-builtin">@truncate</span>(<span class="tok-type">u32</span>, v) *% m;</span>
<span class="line" id="L77">        k1 ^= k1 &gt;&gt; <span class="tok-number">24</span>;</span>
<span class="line" id="L78">        k1 *%= m;</span>
<span class="line" id="L79">        h1 *%= m;</span>
<span class="line" id="L80">        h1 ^= k1;</span>
<span class="line" id="L81">        k1 = <span class="tok-builtin">@truncate</span>(<span class="tok-type">u32</span>, v &gt;&gt; <span class="tok-number">32</span>) *% m;</span>
<span class="line" id="L82">        k1 ^= k1 &gt;&gt; <span class="tok-number">24</span>;</span>
<span class="line" id="L83">        k1 *%= m;</span>
<span class="line" id="L84">        h1 *%= m;</span>
<span class="line" id="L85">        h1 ^= k1;</span>
<span class="line" id="L86">        h1 ^= h1 &gt;&gt; <span class="tok-number">13</span>;</span>
<span class="line" id="L87">        h1 *%= m;</span>
<span class="line" id="L88">        h1 ^= h1 &gt;&gt; <span class="tok-number">15</span>;</span>
<span class="line" id="L89">        <span class="tok-kw">return</span> h1;</span>
<span class="line" id="L90">    }</span>
<span class="line" id="L91">};</span>
<span class="line" id="L92"></span>
<span class="line" id="L93"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> Murmur2_64 = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L94">    <span class="tok-kw">const</span> Self = <span class="tok-builtin">@This</span>();</span>
<span class="line" id="L95"></span>
<span class="line" id="L96">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">hash</span>(str: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) <span class="tok-type">u64</span> {</span>
<span class="line" id="L97">        <span class="tok-kw">return</span> <span class="tok-builtin">@call</span>(.{ .modifier = .always_inline }, Self.hashWithSeed, .{ str, default_seed });</span>
<span class="line" id="L98">    }</span>
<span class="line" id="L99"></span>
<span class="line" id="L100">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">hashWithSeed</span>(str: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, seed: <span class="tok-type">u64</span>) <span class="tok-type">u64</span> {</span>
<span class="line" id="L101">        <span class="tok-kw">const</span> m: <span class="tok-type">u64</span> = <span class="tok-number">0xc6a4a7935bd1e995</span>;</span>
<span class="line" id="L102">        <span class="tok-kw">const</span> len = <span class="tok-builtin">@as</span>(<span class="tok-type">u64</span>, str.len);</span>
<span class="line" id="L103">        <span class="tok-kw">var</span> h1: <span class="tok-type">u64</span> = seed ^ (len *% m);</span>
<span class="line" id="L104">        <span class="tok-kw">for</span> (<span class="tok-builtin">@ptrCast</span>([*]<span class="tok-kw">align</span>(<span class="tok-number">1</span>) <span class="tok-kw">const</span> <span class="tok-type">u64</span>, str.ptr)[<span class="tok-number">0</span>..<span class="tok-builtin">@intCast</span>(<span class="tok-type">usize</span>, len &gt;&gt; <span class="tok-number">3</span>)]) |v| {</span>
<span class="line" id="L105">            <span class="tok-kw">var</span> k1: <span class="tok-type">u64</span> = v;</span>
<span class="line" id="L106">            <span class="tok-kw">if</span> (native_endian == .Big)</span>
<span class="line" id="L107">                k1 = <span class="tok-builtin">@byteSwap</span>(<span class="tok-type">u64</span>, k1);</span>
<span class="line" id="L108">            k1 *%= m;</span>
<span class="line" id="L109">            k1 ^= k1 &gt;&gt; <span class="tok-number">47</span>;</span>
<span class="line" id="L110">            k1 *%= m;</span>
<span class="line" id="L111">            h1 ^= k1;</span>
<span class="line" id="L112">            h1 *%= m;</span>
<span class="line" id="L113">        }</span>
<span class="line" id="L114">        <span class="tok-kw">const</span> rest = len &amp; <span class="tok-number">7</span>;</span>
<span class="line" id="L115">        <span class="tok-kw">const</span> offset = len - rest;</span>
<span class="line" id="L116">        <span class="tok-kw">if</span> (rest &gt; <span class="tok-number">0</span>) {</span>
<span class="line" id="L117">            <span class="tok-kw">var</span> k1: <span class="tok-type">u64</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L118">            <span class="tok-builtin">@memcpy</span>(<span class="tok-builtin">@ptrCast</span>([*]<span class="tok-type">u8</span>, &amp;k1), <span class="tok-builtin">@ptrCast</span>([*]<span class="tok-kw">const</span> <span class="tok-type">u8</span>, &amp;str[<span class="tok-builtin">@intCast</span>(<span class="tok-type">usize</span>, offset)]), <span class="tok-builtin">@intCast</span>(<span class="tok-type">usize</span>, rest));</span>
<span class="line" id="L119">            <span class="tok-kw">if</span> (native_endian == .Big)</span>
<span class="line" id="L120">                k1 = <span class="tok-builtin">@byteSwap</span>(<span class="tok-type">u64</span>, k1);</span>
<span class="line" id="L121">            h1 ^= k1;</span>
<span class="line" id="L122">            h1 *%= m;</span>
<span class="line" id="L123">        }</span>
<span class="line" id="L124">        h1 ^= h1 &gt;&gt; <span class="tok-number">47</span>;</span>
<span class="line" id="L125">        h1 *%= m;</span>
<span class="line" id="L126">        h1 ^= h1 &gt;&gt; <span class="tok-number">47</span>;</span>
<span class="line" id="L127">        <span class="tok-kw">return</span> h1;</span>
<span class="line" id="L128">    }</span>
<span class="line" id="L129"></span>
<span class="line" id="L130">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">hashUint32</span>(v: <span class="tok-type">u32</span>) <span class="tok-type">u64</span> {</span>
<span class="line" id="L131">        <span class="tok-kw">return</span> <span class="tok-builtin">@call</span>(.{ .modifier = .always_inline }, Self.hashUint32WithSeed, .{ v, default_seed });</span>
<span class="line" id="L132">    }</span>
<span class="line" id="L133"></span>
<span class="line" id="L134">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">hashUint32WithSeed</span>(v: <span class="tok-type">u32</span>, seed: <span class="tok-type">u64</span>) <span class="tok-type">u64</span> {</span>
<span class="line" id="L135">        <span class="tok-kw">const</span> m: <span class="tok-type">u64</span> = <span class="tok-number">0xc6a4a7935bd1e995</span>;</span>
<span class="line" id="L136">        <span class="tok-kw">const</span> len: <span class="tok-type">u64</span> = <span class="tok-number">4</span>;</span>
<span class="line" id="L137">        <span class="tok-kw">var</span> h1: <span class="tok-type">u64</span> = seed ^ (len *% m);</span>
<span class="line" id="L138">        <span class="tok-kw">var</span> k1: <span class="tok-type">u64</span> = v;</span>
<span class="line" id="L139">        h1 ^= k1;</span>
<span class="line" id="L140">        h1 *%= m;</span>
<span class="line" id="L141">        h1 ^= h1 &gt;&gt; <span class="tok-number">47</span>;</span>
<span class="line" id="L142">        h1 *%= m;</span>
<span class="line" id="L143">        h1 ^= h1 &gt;&gt; <span class="tok-number">47</span>;</span>
<span class="line" id="L144">        <span class="tok-kw">return</span> h1;</span>
<span class="line" id="L145">    }</span>
<span class="line" id="L146"></span>
<span class="line" id="L147">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">hashUint64</span>(v: <span class="tok-type">u64</span>) <span class="tok-type">u64</span> {</span>
<span class="line" id="L148">        <span class="tok-kw">return</span> <span class="tok-builtin">@call</span>(.{ .modifier = .always_inline }, Self.hashUint64WithSeed, .{ v, default_seed });</span>
<span class="line" id="L149">    }</span>
<span class="line" id="L150"></span>
<span class="line" id="L151">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">hashUint64WithSeed</span>(v: <span class="tok-type">u64</span>, seed: <span class="tok-type">u64</span>) <span class="tok-type">u64</span> {</span>
<span class="line" id="L152">        <span class="tok-kw">const</span> m: <span class="tok-type">u64</span> = <span class="tok-number">0xc6a4a7935bd1e995</span>;</span>
<span class="line" id="L153">        <span class="tok-kw">const</span> len: <span class="tok-type">u64</span> = <span class="tok-number">8</span>;</span>
<span class="line" id="L154">        <span class="tok-kw">var</span> h1: <span class="tok-type">u64</span> = seed ^ (len *% m);</span>
<span class="line" id="L155">        <span class="tok-kw">var</span> k1: <span class="tok-type">u64</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L156">        k1 = v *% m;</span>
<span class="line" id="L157">        k1 ^= k1 &gt;&gt; <span class="tok-number">47</span>;</span>
<span class="line" id="L158">        k1 *%= m;</span>
<span class="line" id="L159">        h1 ^= k1;</span>
<span class="line" id="L160">        h1 *%= m;</span>
<span class="line" id="L161">        h1 ^= h1 &gt;&gt; <span class="tok-number">47</span>;</span>
<span class="line" id="L162">        h1 *%= m;</span>
<span class="line" id="L163">        h1 ^= h1 &gt;&gt; <span class="tok-number">47</span>;</span>
<span class="line" id="L164">        <span class="tok-kw">return</span> h1;</span>
<span class="line" id="L165">    }</span>
<span class="line" id="L166">};</span>
<span class="line" id="L167"></span>
<span class="line" id="L168"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> Murmur3_32 = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L169">    <span class="tok-kw">const</span> Self = <span class="tok-builtin">@This</span>();</span>
<span class="line" id="L170"></span>
<span class="line" id="L171">    <span class="tok-kw">fn</span> <span class="tok-fn">rotl32</span>(x: <span class="tok-type">u32</span>, <span class="tok-kw">comptime</span> r: <span class="tok-type">u32</span>) <span class="tok-type">u32</span> {</span>
<span class="line" id="L172">        <span class="tok-kw">return</span> (x &lt;&lt; r) | (x &gt;&gt; (<span class="tok-number">32</span> - r));</span>
<span class="line" id="L173">    }</span>
<span class="line" id="L174"></span>
<span class="line" id="L175">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">hash</span>(str: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) <span class="tok-type">u32</span> {</span>
<span class="line" id="L176">        <span class="tok-kw">return</span> <span class="tok-builtin">@call</span>(.{ .modifier = .always_inline }, Self.hashWithSeed, .{ str, default_seed });</span>
<span class="line" id="L177">    }</span>
<span class="line" id="L178"></span>
<span class="line" id="L179">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">hashWithSeed</span>(str: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, seed: <span class="tok-type">u32</span>) <span class="tok-type">u32</span> {</span>
<span class="line" id="L180">        <span class="tok-kw">const</span> c1: <span class="tok-type">u32</span> = <span class="tok-number">0xcc9e2d51</span>;</span>
<span class="line" id="L181">        <span class="tok-kw">const</span> c2: <span class="tok-type">u32</span> = <span class="tok-number">0x1b873593</span>;</span>
<span class="line" id="L182">        <span class="tok-kw">const</span> len = <span class="tok-builtin">@truncate</span>(<span class="tok-type">u32</span>, str.len);</span>
<span class="line" id="L183">        <span class="tok-kw">var</span> h1: <span class="tok-type">u32</span> = seed;</span>
<span class="line" id="L184">        <span class="tok-kw">for</span> (<span class="tok-builtin">@ptrCast</span>([*]<span class="tok-kw">align</span>(<span class="tok-number">1</span>) <span class="tok-kw">const</span> <span class="tok-type">u32</span>, str.ptr)[<span class="tok-number">0</span>..(len &gt;&gt; <span class="tok-number">2</span>)]) |v| {</span>
<span class="line" id="L185">            <span class="tok-kw">var</span> k1: <span class="tok-type">u32</span> = v;</span>
<span class="line" id="L186">            <span class="tok-kw">if</span> (native_endian == .Big)</span>
<span class="line" id="L187">                k1 = <span class="tok-builtin">@byteSwap</span>(<span class="tok-type">u32</span>, k1);</span>
<span class="line" id="L188">            k1 *%= c1;</span>
<span class="line" id="L189">            k1 = rotl32(k1, <span class="tok-number">15</span>);</span>
<span class="line" id="L190">            k1 *%= c2;</span>
<span class="line" id="L191">            h1 ^= k1;</span>
<span class="line" id="L192">            h1 = rotl32(h1, <span class="tok-number">13</span>);</span>
<span class="line" id="L193">            h1 *%= <span class="tok-number">5</span>;</span>
<span class="line" id="L194">            h1 +%= <span class="tok-number">0xe6546b64</span>;</span>
<span class="line" id="L195">        }</span>
<span class="line" id="L196">        {</span>
<span class="line" id="L197">            <span class="tok-kw">var</span> k1: <span class="tok-type">u32</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L198">            <span class="tok-kw">const</span> offset = len &amp; <span class="tok-number">0xfffffffc</span>;</span>
<span class="line" id="L199">            <span class="tok-kw">const</span> rest = len &amp; <span class="tok-number">3</span>;</span>
<span class="line" id="L200">            <span class="tok-kw">if</span> (rest == <span class="tok-number">3</span>) {</span>
<span class="line" id="L201">                k1 ^= <span class="tok-builtin">@intCast</span>(<span class="tok-type">u32</span>, str[offset + <span class="tok-number">2</span>]) &lt;&lt; <span class="tok-number">16</span>;</span>
<span class="line" id="L202">            }</span>
<span class="line" id="L203">            <span class="tok-kw">if</span> (rest &gt;= <span class="tok-number">2</span>) {</span>
<span class="line" id="L204">                k1 ^= <span class="tok-builtin">@intCast</span>(<span class="tok-type">u32</span>, str[offset + <span class="tok-number">1</span>]) &lt;&lt; <span class="tok-number">8</span>;</span>
<span class="line" id="L205">            }</span>
<span class="line" id="L206">            <span class="tok-kw">if</span> (rest &gt;= <span class="tok-number">1</span>) {</span>
<span class="line" id="L207">                k1 ^= <span class="tok-builtin">@intCast</span>(<span class="tok-type">u32</span>, str[offset + <span class="tok-number">0</span>]);</span>
<span class="line" id="L208">                k1 *%= c1;</span>
<span class="line" id="L209">                k1 = rotl32(k1, <span class="tok-number">15</span>);</span>
<span class="line" id="L210">                k1 *%= c2;</span>
<span class="line" id="L211">                h1 ^= k1;</span>
<span class="line" id="L212">            }</span>
<span class="line" id="L213">        }</span>
<span class="line" id="L214">        h1 ^= len;</span>
<span class="line" id="L215">        h1 ^= h1 &gt;&gt; <span class="tok-number">16</span>;</span>
<span class="line" id="L216">        h1 *%= <span class="tok-number">0x85ebca6b</span>;</span>
<span class="line" id="L217">        h1 ^= h1 &gt;&gt; <span class="tok-number">13</span>;</span>
<span class="line" id="L218">        h1 *%= <span class="tok-number">0xc2b2ae35</span>;</span>
<span class="line" id="L219">        h1 ^= h1 &gt;&gt; <span class="tok-number">16</span>;</span>
<span class="line" id="L220">        <span class="tok-kw">return</span> h1;</span>
<span class="line" id="L221">    }</span>
<span class="line" id="L222"></span>
<span class="line" id="L223">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">hashUint32</span>(v: <span class="tok-type">u32</span>) <span class="tok-type">u32</span> {</span>
<span class="line" id="L224">        <span class="tok-kw">return</span> <span class="tok-builtin">@call</span>(.{ .modifier = .always_inline }, Self.hashUint32WithSeed, .{ v, default_seed });</span>
<span class="line" id="L225">    }</span>
<span class="line" id="L226"></span>
<span class="line" id="L227">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">hashUint32WithSeed</span>(v: <span class="tok-type">u32</span>, seed: <span class="tok-type">u32</span>) <span class="tok-type">u32</span> {</span>
<span class="line" id="L228">        <span class="tok-kw">const</span> c1: <span class="tok-type">u32</span> = <span class="tok-number">0xcc9e2d51</span>;</span>
<span class="line" id="L229">        <span class="tok-kw">const</span> c2: <span class="tok-type">u32</span> = <span class="tok-number">0x1b873593</span>;</span>
<span class="line" id="L230">        <span class="tok-kw">const</span> len: <span class="tok-type">u32</span> = <span class="tok-number">4</span>;</span>
<span class="line" id="L231">        <span class="tok-kw">var</span> h1: <span class="tok-type">u32</span> = seed;</span>
<span class="line" id="L232">        <span class="tok-kw">var</span> k1: <span class="tok-type">u32</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L233">        k1 = v *% c1;</span>
<span class="line" id="L234">        k1 = rotl32(k1, <span class="tok-number">15</span>);</span>
<span class="line" id="L235">        k1 *%= c2;</span>
<span class="line" id="L236">        h1 ^= k1;</span>
<span class="line" id="L237">        h1 = rotl32(h1, <span class="tok-number">13</span>);</span>
<span class="line" id="L238">        h1 *%= <span class="tok-number">5</span>;</span>
<span class="line" id="L239">        h1 +%= <span class="tok-number">0xe6546b64</span>;</span>
<span class="line" id="L240">        h1 ^= len;</span>
<span class="line" id="L241">        h1 ^= h1 &gt;&gt; <span class="tok-number">16</span>;</span>
<span class="line" id="L242">        h1 *%= <span class="tok-number">0x85ebca6b</span>;</span>
<span class="line" id="L243">        h1 ^= h1 &gt;&gt; <span class="tok-number">13</span>;</span>
<span class="line" id="L244">        h1 *%= <span class="tok-number">0xc2b2ae35</span>;</span>
<span class="line" id="L245">        h1 ^= h1 &gt;&gt; <span class="tok-number">16</span>;</span>
<span class="line" id="L246">        <span class="tok-kw">return</span> h1;</span>
<span class="line" id="L247">    }</span>
<span class="line" id="L248"></span>
<span class="line" id="L249">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">hashUint64</span>(v: <span class="tok-type">u64</span>) <span class="tok-type">u32</span> {</span>
<span class="line" id="L250">        <span class="tok-kw">return</span> <span class="tok-builtin">@call</span>(.{ .modifier = .always_inline }, Self.hashUint64WithSeed, .{ v, default_seed });</span>
<span class="line" id="L251">    }</span>
<span class="line" id="L252"></span>
<span class="line" id="L253">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">hashUint64WithSeed</span>(v: <span class="tok-type">u64</span>, seed: <span class="tok-type">u32</span>) <span class="tok-type">u32</span> {</span>
<span class="line" id="L254">        <span class="tok-kw">const</span> c1: <span class="tok-type">u32</span> = <span class="tok-number">0xcc9e2d51</span>;</span>
<span class="line" id="L255">        <span class="tok-kw">const</span> c2: <span class="tok-type">u32</span> = <span class="tok-number">0x1b873593</span>;</span>
<span class="line" id="L256">        <span class="tok-kw">const</span> len: <span class="tok-type">u32</span> = <span class="tok-number">8</span>;</span>
<span class="line" id="L257">        <span class="tok-kw">var</span> h1: <span class="tok-type">u32</span> = seed;</span>
<span class="line" id="L258">        <span class="tok-kw">var</span> k1: <span class="tok-type">u32</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L259">        k1 = <span class="tok-builtin">@truncate</span>(<span class="tok-type">u32</span>, v) *% c1;</span>
<span class="line" id="L260">        k1 = rotl32(k1, <span class="tok-number">15</span>);</span>
<span class="line" id="L261">        k1 *%= c2;</span>
<span class="line" id="L262">        h1 ^= k1;</span>
<span class="line" id="L263">        h1 = rotl32(h1, <span class="tok-number">13</span>);</span>
<span class="line" id="L264">        h1 *%= <span class="tok-number">5</span>;</span>
<span class="line" id="L265">        h1 +%= <span class="tok-number">0xe6546b64</span>;</span>
<span class="line" id="L266">        k1 = <span class="tok-builtin">@truncate</span>(<span class="tok-type">u32</span>, v &gt;&gt; <span class="tok-number">32</span>) *% c1;</span>
<span class="line" id="L267">        k1 = rotl32(k1, <span class="tok-number">15</span>);</span>
<span class="line" id="L268">        k1 *%= c2;</span>
<span class="line" id="L269">        h1 ^= k1;</span>
<span class="line" id="L270">        h1 = rotl32(h1, <span class="tok-number">13</span>);</span>
<span class="line" id="L271">        h1 *%= <span class="tok-number">5</span>;</span>
<span class="line" id="L272">        h1 +%= <span class="tok-number">0xe6546b64</span>;</span>
<span class="line" id="L273">        h1 ^= len;</span>
<span class="line" id="L274">        h1 ^= h1 &gt;&gt; <span class="tok-number">16</span>;</span>
<span class="line" id="L275">        h1 *%= <span class="tok-number">0x85ebca6b</span>;</span>
<span class="line" id="L276">        h1 ^= h1 &gt;&gt; <span class="tok-number">13</span>;</span>
<span class="line" id="L277">        h1 *%= <span class="tok-number">0xc2b2ae35</span>;</span>
<span class="line" id="L278">        h1 ^= h1 &gt;&gt; <span class="tok-number">16</span>;</span>
<span class="line" id="L279">        <span class="tok-kw">return</span> h1;</span>
<span class="line" id="L280">    }</span>
<span class="line" id="L281">};</span>
<span class="line" id="L282"></span>
<span class="line" id="L283"><span class="tok-kw">fn</span> <span class="tok-fn">SMHasherTest</span>(<span class="tok-kw">comptime</span> hash_fn: <span class="tok-kw">anytype</span>, <span class="tok-kw">comptime</span> hashbits: <span class="tok-type">u32</span>) <span class="tok-type">u32</span> {</span>
<span class="line" id="L284">    <span class="tok-kw">const</span> hashbytes = hashbits / <span class="tok-number">8</span>;</span>
<span class="line" id="L285">    <span class="tok-kw">var</span> key: [<span class="tok-number">256</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L286">    <span class="tok-kw">var</span> hashes: [hashbytes * <span class="tok-number">256</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L287">    <span class="tok-kw">var</span> final: [hashbytes]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L288"></span>
<span class="line" id="L289">    <span class="tok-builtin">@memset</span>(<span class="tok-builtin">@ptrCast</span>([*]<span class="tok-type">u8</span>, &amp;key[<span class="tok-number">0</span>]), <span class="tok-number">0</span>, <span class="tok-builtin">@sizeOf</span>(<span class="tok-builtin">@TypeOf</span>(key)));</span>
<span class="line" id="L290">    <span class="tok-builtin">@memset</span>(<span class="tok-builtin">@ptrCast</span>([*]<span class="tok-type">u8</span>, &amp;hashes[<span class="tok-number">0</span>]), <span class="tok-number">0</span>, <span class="tok-builtin">@sizeOf</span>(<span class="tok-builtin">@TypeOf</span>(hashes)));</span>
<span class="line" id="L291">    <span class="tok-builtin">@memset</span>(<span class="tok-builtin">@ptrCast</span>([*]<span class="tok-type">u8</span>, &amp;final[<span class="tok-number">0</span>]), <span class="tok-number">0</span>, <span class="tok-builtin">@sizeOf</span>(<span class="tok-builtin">@TypeOf</span>(final)));</span>
<span class="line" id="L292"></span>
<span class="line" id="L293">    <span class="tok-kw">var</span> i: <span class="tok-type">u32</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L294">    <span class="tok-kw">while</span> (i &lt; <span class="tok-number">256</span>) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L295">        key[i] = <span class="tok-builtin">@truncate</span>(<span class="tok-type">u8</span>, i);</span>
<span class="line" id="L296"></span>
<span class="line" id="L297">        <span class="tok-kw">var</span> h = hash_fn(key[<span class="tok-number">0</span>..i], <span class="tok-number">256</span> - i);</span>
<span class="line" id="L298">        <span class="tok-kw">if</span> (native_endian == .Big)</span>
<span class="line" id="L299">            h = <span class="tok-builtin">@byteSwap</span>(<span class="tok-builtin">@TypeOf</span>(h), h);</span>
<span class="line" id="L300">        <span class="tok-builtin">@memcpy</span>(<span class="tok-builtin">@ptrCast</span>([*]<span class="tok-type">u8</span>, &amp;hashes[i * hashbytes]), <span class="tok-builtin">@ptrCast</span>([*]<span class="tok-type">u8</span>, &amp;h), hashbytes);</span>
<span class="line" id="L301">    }</span>
<span class="line" id="L302"></span>
<span class="line" id="L303">    <span class="tok-kw">return</span> <span class="tok-builtin">@truncate</span>(<span class="tok-type">u32</span>, hash_fn(&amp;hashes, <span class="tok-number">0</span>));</span>
<span class="line" id="L304">}</span>
<span class="line" id="L305"></span>
<span class="line" id="L306"><span class="tok-kw">test</span> <span class="tok-str">&quot;murmur2_32&quot;</span> {</span>
<span class="line" id="L307">    <span class="tok-kw">try</span> testing.expectEqual(SMHasherTest(Murmur2_32.hashWithSeed, <span class="tok-number">32</span>), <span class="tok-number">0x27864C1E</span>);</span>
<span class="line" id="L308">    <span class="tok-kw">var</span> v0: <span class="tok-type">u32</span> = <span class="tok-number">0x12345678</span>;</span>
<span class="line" id="L309">    <span class="tok-kw">var</span> v1: <span class="tok-type">u64</span> = <span class="tok-number">0x1234567812345678</span>;</span>
<span class="line" id="L310">    <span class="tok-kw">var</span> v0le: <span class="tok-type">u32</span> = v0;</span>
<span class="line" id="L311">    <span class="tok-kw">var</span> v1le: <span class="tok-type">u64</span> = v1;</span>
<span class="line" id="L312">    <span class="tok-kw">if</span> (native_endian == .Big) {</span>
<span class="line" id="L313">        v0le = <span class="tok-builtin">@byteSwap</span>(<span class="tok-type">u32</span>, v0le);</span>
<span class="line" id="L314">        v1le = <span class="tok-builtin">@byteSwap</span>(<span class="tok-type">u64</span>, v1le);</span>
<span class="line" id="L315">    }</span>
<span class="line" id="L316">    <span class="tok-kw">try</span> testing.expectEqual(Murmur2_32.hash(<span class="tok-builtin">@ptrCast</span>([*]<span class="tok-type">u8</span>, &amp;v0le)[<span class="tok-number">0</span>..<span class="tok-number">4</span>]), Murmur2_32.hashUint32(v0));</span>
<span class="line" id="L317">    <span class="tok-kw">try</span> testing.expectEqual(Murmur2_32.hash(<span class="tok-builtin">@ptrCast</span>([*]<span class="tok-type">u8</span>, &amp;v1le)[<span class="tok-number">0</span>..<span class="tok-number">8</span>]), Murmur2_32.hashUint64(v1));</span>
<span class="line" id="L318">}</span>
<span class="line" id="L319"></span>
<span class="line" id="L320"><span class="tok-kw">test</span> <span class="tok-str">&quot;murmur2_64&quot;</span> {</span>
<span class="line" id="L321">    <span class="tok-kw">try</span> std.testing.expectEqual(SMHasherTest(Murmur2_64.hashWithSeed, <span class="tok-number">64</span>), <span class="tok-number">0x1F0D3804</span>);</span>
<span class="line" id="L322">    <span class="tok-kw">var</span> v0: <span class="tok-type">u32</span> = <span class="tok-number">0x12345678</span>;</span>
<span class="line" id="L323">    <span class="tok-kw">var</span> v1: <span class="tok-type">u64</span> = <span class="tok-number">0x1234567812345678</span>;</span>
<span class="line" id="L324">    <span class="tok-kw">var</span> v0le: <span class="tok-type">u32</span> = v0;</span>
<span class="line" id="L325">    <span class="tok-kw">var</span> v1le: <span class="tok-type">u64</span> = v1;</span>
<span class="line" id="L326">    <span class="tok-kw">if</span> (native_endian == .Big) {</span>
<span class="line" id="L327">        v0le = <span class="tok-builtin">@byteSwap</span>(<span class="tok-type">u32</span>, v0le);</span>
<span class="line" id="L328">        v1le = <span class="tok-builtin">@byteSwap</span>(<span class="tok-type">u64</span>, v1le);</span>
<span class="line" id="L329">    }</span>
<span class="line" id="L330">    <span class="tok-kw">try</span> testing.expectEqual(Murmur2_64.hash(<span class="tok-builtin">@ptrCast</span>([*]<span class="tok-type">u8</span>, &amp;v0le)[<span class="tok-number">0</span>..<span class="tok-number">4</span>]), Murmur2_64.hashUint32(v0));</span>
<span class="line" id="L331">    <span class="tok-kw">try</span> testing.expectEqual(Murmur2_64.hash(<span class="tok-builtin">@ptrCast</span>([*]<span class="tok-type">u8</span>, &amp;v1le)[<span class="tok-number">0</span>..<span class="tok-number">8</span>]), Murmur2_64.hashUint64(v1));</span>
<span class="line" id="L332">}</span>
<span class="line" id="L333"></span>
<span class="line" id="L334"><span class="tok-kw">test</span> <span class="tok-str">&quot;murmur3_32&quot;</span> {</span>
<span class="line" id="L335">    <span class="tok-kw">try</span> std.testing.expectEqual(SMHasherTest(Murmur3_32.hashWithSeed, <span class="tok-number">32</span>), <span class="tok-number">0xB0F57EE3</span>);</span>
<span class="line" id="L336">    <span class="tok-kw">var</span> v0: <span class="tok-type">u32</span> = <span class="tok-number">0x12345678</span>;</span>
<span class="line" id="L337">    <span class="tok-kw">var</span> v1: <span class="tok-type">u64</span> = <span class="tok-number">0x1234567812345678</span>;</span>
<span class="line" id="L338">    <span class="tok-kw">var</span> v0le: <span class="tok-type">u32</span> = v0;</span>
<span class="line" id="L339">    <span class="tok-kw">var</span> v1le: <span class="tok-type">u64</span> = v1;</span>
<span class="line" id="L340">    <span class="tok-kw">if</span> (native_endian == .Big) {</span>
<span class="line" id="L341">        v0le = <span class="tok-builtin">@byteSwap</span>(<span class="tok-type">u32</span>, v0le);</span>
<span class="line" id="L342">        v1le = <span class="tok-builtin">@byteSwap</span>(<span class="tok-type">u64</span>, v1le);</span>
<span class="line" id="L343">    }</span>
<span class="line" id="L344">    <span class="tok-kw">try</span> testing.expectEqual(Murmur3_32.hash(<span class="tok-builtin">@ptrCast</span>([*]<span class="tok-type">u8</span>, &amp;v0le)[<span class="tok-number">0</span>..<span class="tok-number">4</span>]), Murmur3_32.hashUint32(v0));</span>
<span class="line" id="L345">    <span class="tok-kw">try</span> testing.expectEqual(Murmur3_32.hash(<span class="tok-builtin">@ptrCast</span>([*]<span class="tok-type">u8</span>, &amp;v1le)[<span class="tok-number">0</span>..<span class="tok-number">8</span>]), Murmur3_32.hashUint64(v1));</span>
<span class="line" id="L346">}</span>
<span class="line" id="L347"></span>
</code></pre></body>
</html>