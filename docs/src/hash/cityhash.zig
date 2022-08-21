<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">    <title>hash/cityhash.zig - source view</title>
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
<span class="line" id="L2"></span>
<span class="line" id="L3"><span class="tok-kw">inline</span> <span class="tok-kw">fn</span> <span class="tok-fn">offsetPtr</span>(ptr: [*]<span class="tok-kw">const</span> <span class="tok-type">u8</span>, offset: <span class="tok-type">usize</span>) [*]<span class="tok-kw">const</span> <span class="tok-type">u8</span> {</span>
<span class="line" id="L4">    <span class="tok-comment">// ptr + offset doesn't work at comptime so we need this instead.</span>
</span>
<span class="line" id="L5">    <span class="tok-kw">return</span> <span class="tok-builtin">@ptrCast</span>([*]<span class="tok-kw">const</span> <span class="tok-type">u8</span>, &amp;ptr[offset]);</span>
<span class="line" id="L6">}</span>
<span class="line" id="L7"></span>
<span class="line" id="L8"><span class="tok-kw">fn</span> <span class="tok-fn">fetch32</span>(ptr: [*]<span class="tok-kw">const</span> <span class="tok-type">u8</span>, offset: <span class="tok-type">usize</span>) <span class="tok-type">u32</span> {</span>
<span class="line" id="L9">    <span class="tok-kw">return</span> std.mem.readIntLittle(<span class="tok-type">u32</span>, offsetPtr(ptr, offset)[<span class="tok-number">0</span>..<span class="tok-number">4</span>]);</span>
<span class="line" id="L10">}</span>
<span class="line" id="L11"></span>
<span class="line" id="L12"><span class="tok-kw">fn</span> <span class="tok-fn">fetch64</span>(ptr: [*]<span class="tok-kw">const</span> <span class="tok-type">u8</span>, offset: <span class="tok-type">usize</span>) <span class="tok-type">u64</span> {</span>
<span class="line" id="L13">    <span class="tok-kw">return</span> std.mem.readIntLittle(<span class="tok-type">u64</span>, offsetPtr(ptr, offset)[<span class="tok-number">0</span>..<span class="tok-number">8</span>]);</span>
<span class="line" id="L14">}</span>
<span class="line" id="L15"></span>
<span class="line" id="L16"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> CityHash32 = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L17">    <span class="tok-kw">const</span> Self = <span class="tok-builtin">@This</span>();</span>
<span class="line" id="L18"></span>
<span class="line" id="L19">    <span class="tok-comment">// Magic numbers for 32-bit hashing.  Copied from Murmur3.</span>
</span>
<span class="line" id="L20">    <span class="tok-kw">const</span> c1: <span class="tok-type">u32</span> = <span class="tok-number">0xcc9e2d51</span>;</span>
<span class="line" id="L21">    <span class="tok-kw">const</span> c2: <span class="tok-type">u32</span> = <span class="tok-number">0x1b873593</span>;</span>
<span class="line" id="L22"></span>
<span class="line" id="L23">    <span class="tok-comment">// A 32-bit to 32-bit integer hash copied from Murmur3.</span>
</span>
<span class="line" id="L24">    <span class="tok-kw">fn</span> <span class="tok-fn">fmix</span>(h: <span class="tok-type">u32</span>) <span class="tok-type">u32</span> {</span>
<span class="line" id="L25">        <span class="tok-kw">var</span> h1: <span class="tok-type">u32</span> = h;</span>
<span class="line" id="L26">        h1 ^= h1 &gt;&gt; <span class="tok-number">16</span>;</span>
<span class="line" id="L27">        h1 *%= <span class="tok-number">0x85ebca6b</span>;</span>
<span class="line" id="L28">        h1 ^= h1 &gt;&gt; <span class="tok-number">13</span>;</span>
<span class="line" id="L29">        h1 *%= <span class="tok-number">0xc2b2ae35</span>;</span>
<span class="line" id="L30">        h1 ^= h1 &gt;&gt; <span class="tok-number">16</span>;</span>
<span class="line" id="L31">        <span class="tok-kw">return</span> h1;</span>
<span class="line" id="L32">    }</span>
<span class="line" id="L33"></span>
<span class="line" id="L34">    <span class="tok-comment">// Rotate right helper</span>
</span>
<span class="line" id="L35">    <span class="tok-kw">fn</span> <span class="tok-fn">rotr32</span>(x: <span class="tok-type">u32</span>, <span class="tok-kw">comptime</span> r: <span class="tok-type">u32</span>) <span class="tok-type">u32</span> {</span>
<span class="line" id="L36">        <span class="tok-kw">return</span> (x &gt;&gt; r) | (x &lt;&lt; (<span class="tok-number">32</span> - r));</span>
<span class="line" id="L37">    }</span>
<span class="line" id="L38"></span>
<span class="line" id="L39">    <span class="tok-comment">// Helper from Murmur3 for combining two 32-bit values.</span>
</span>
<span class="line" id="L40">    <span class="tok-kw">fn</span> <span class="tok-fn">mur</span>(a: <span class="tok-type">u32</span>, h: <span class="tok-type">u32</span>) <span class="tok-type">u32</span> {</span>
<span class="line" id="L41">        <span class="tok-kw">var</span> a1: <span class="tok-type">u32</span> = a;</span>
<span class="line" id="L42">        <span class="tok-kw">var</span> h1: <span class="tok-type">u32</span> = h;</span>
<span class="line" id="L43">        a1 *%= c1;</span>
<span class="line" id="L44">        a1 = rotr32(a1, <span class="tok-number">17</span>);</span>
<span class="line" id="L45">        a1 *%= c2;</span>
<span class="line" id="L46">        h1 ^= a1;</span>
<span class="line" id="L47">        h1 = rotr32(h1, <span class="tok-number">19</span>);</span>
<span class="line" id="L48">        <span class="tok-kw">return</span> h1 *% <span class="tok-number">5</span> +% <span class="tok-number">0xe6546b64</span>;</span>
<span class="line" id="L49">    }</span>
<span class="line" id="L50"></span>
<span class="line" id="L51">    <span class="tok-kw">fn</span> <span class="tok-fn">hash32Len0To4</span>(str: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) <span class="tok-type">u32</span> {</span>
<span class="line" id="L52">        <span class="tok-kw">const</span> len: <span class="tok-type">u32</span> = <span class="tok-builtin">@truncate</span>(<span class="tok-type">u32</span>, str.len);</span>
<span class="line" id="L53">        <span class="tok-kw">var</span> b: <span class="tok-type">u32</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L54">        <span class="tok-kw">var</span> c: <span class="tok-type">u32</span> = <span class="tok-number">9</span>;</span>
<span class="line" id="L55">        <span class="tok-kw">for</span> (str) |v| {</span>
<span class="line" id="L56">            b = b *% c1 +% <span class="tok-builtin">@bitCast</span>(<span class="tok-type">u32</span>, <span class="tok-builtin">@intCast</span>(<span class="tok-type">i32</span>, <span class="tok-builtin">@bitCast</span>(<span class="tok-type">i8</span>, v)));</span>
<span class="line" id="L57">            c ^= b;</span>
<span class="line" id="L58">        }</span>
<span class="line" id="L59">        <span class="tok-kw">return</span> fmix(mur(b, mur(len, c)));</span>
<span class="line" id="L60">    }</span>
<span class="line" id="L61"></span>
<span class="line" id="L62">    <span class="tok-kw">fn</span> <span class="tok-fn">hash32Len5To12</span>(str: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) <span class="tok-type">u32</span> {</span>
<span class="line" id="L63">        <span class="tok-kw">var</span> a: <span class="tok-type">u32</span> = <span class="tok-builtin">@truncate</span>(<span class="tok-type">u32</span>, str.len);</span>
<span class="line" id="L64">        <span class="tok-kw">var</span> b: <span class="tok-type">u32</span> = a *% <span class="tok-number">5</span>;</span>
<span class="line" id="L65">        <span class="tok-kw">var</span> c: <span class="tok-type">u32</span> = <span class="tok-number">9</span>;</span>
<span class="line" id="L66">        <span class="tok-kw">const</span> d: <span class="tok-type">u32</span> = b;</span>
<span class="line" id="L67"></span>
<span class="line" id="L68">        a +%= fetch32(str.ptr, <span class="tok-number">0</span>);</span>
<span class="line" id="L69">        b +%= fetch32(str.ptr, str.len - <span class="tok-number">4</span>);</span>
<span class="line" id="L70">        c +%= fetch32(str.ptr, (str.len &gt;&gt; <span class="tok-number">1</span>) &amp; <span class="tok-number">4</span>);</span>
<span class="line" id="L71"></span>
<span class="line" id="L72">        <span class="tok-kw">return</span> fmix(mur(c, mur(b, mur(a, d))));</span>
<span class="line" id="L73">    }</span>
<span class="line" id="L74"></span>
<span class="line" id="L75">    <span class="tok-kw">fn</span> <span class="tok-fn">hash32Len13To24</span>(str: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) <span class="tok-type">u32</span> {</span>
<span class="line" id="L76">        <span class="tok-kw">const</span> len: <span class="tok-type">u32</span> = <span class="tok-builtin">@truncate</span>(<span class="tok-type">u32</span>, str.len);</span>
<span class="line" id="L77">        <span class="tok-kw">const</span> a: <span class="tok-type">u32</span> = fetch32(str.ptr, (str.len &gt;&gt; <span class="tok-number">1</span>) - <span class="tok-number">4</span>);</span>
<span class="line" id="L78">        <span class="tok-kw">const</span> b: <span class="tok-type">u32</span> = fetch32(str.ptr, <span class="tok-number">4</span>);</span>
<span class="line" id="L79">        <span class="tok-kw">const</span> c: <span class="tok-type">u32</span> = fetch32(str.ptr, str.len - <span class="tok-number">8</span>);</span>
<span class="line" id="L80">        <span class="tok-kw">const</span> d: <span class="tok-type">u32</span> = fetch32(str.ptr, str.len &gt;&gt; <span class="tok-number">1</span>);</span>
<span class="line" id="L81">        <span class="tok-kw">const</span> e: <span class="tok-type">u32</span> = fetch32(str.ptr, <span class="tok-number">0</span>);</span>
<span class="line" id="L82">        <span class="tok-kw">const</span> f: <span class="tok-type">u32</span> = fetch32(str.ptr, str.len - <span class="tok-number">4</span>);</span>
<span class="line" id="L83"></span>
<span class="line" id="L84">        <span class="tok-kw">return</span> fmix(mur(f, mur(e, mur(d, mur(c, mur(b, mur(a, len)))))));</span>
<span class="line" id="L85">    }</span>
<span class="line" id="L86"></span>
<span class="line" id="L87">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">hash</span>(str: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) <span class="tok-type">u32</span> {</span>
<span class="line" id="L88">        <span class="tok-kw">if</span> (str.len &lt;= <span class="tok-number">24</span>) {</span>
<span class="line" id="L89">            <span class="tok-kw">if</span> (str.len &lt;= <span class="tok-number">4</span>) {</span>
<span class="line" id="L90">                <span class="tok-kw">return</span> hash32Len0To4(str);</span>
<span class="line" id="L91">            } <span class="tok-kw">else</span> {</span>
<span class="line" id="L92">                <span class="tok-kw">if</span> (str.len &lt;= <span class="tok-number">12</span>)</span>
<span class="line" id="L93">                    <span class="tok-kw">return</span> hash32Len5To12(str);</span>
<span class="line" id="L94">                <span class="tok-kw">return</span> hash32Len13To24(str);</span>
<span class="line" id="L95">            }</span>
<span class="line" id="L96">        }</span>
<span class="line" id="L97"></span>
<span class="line" id="L98">        <span class="tok-kw">const</span> len: <span class="tok-type">u32</span> = <span class="tok-builtin">@truncate</span>(<span class="tok-type">u32</span>, str.len);</span>
<span class="line" id="L99">        <span class="tok-kw">var</span> h: <span class="tok-type">u32</span> = len;</span>
<span class="line" id="L100">        <span class="tok-kw">var</span> g: <span class="tok-type">u32</span> = c1 *% len;</span>
<span class="line" id="L101">        <span class="tok-kw">var</span> f: <span class="tok-type">u32</span> = g;</span>
<span class="line" id="L102"></span>
<span class="line" id="L103">        <span class="tok-kw">const</span> a0: <span class="tok-type">u32</span> = rotr32(fetch32(str.ptr, str.len - <span class="tok-number">4</span>) *% c1, <span class="tok-number">17</span>) *% c2;</span>
<span class="line" id="L104">        <span class="tok-kw">const</span> a1: <span class="tok-type">u32</span> = rotr32(fetch32(str.ptr, str.len - <span class="tok-number">8</span>) *% c1, <span class="tok-number">17</span>) *% c2;</span>
<span class="line" id="L105">        <span class="tok-kw">const</span> a2: <span class="tok-type">u32</span> = rotr32(fetch32(str.ptr, str.len - <span class="tok-number">16</span>) *% c1, <span class="tok-number">17</span>) *% c2;</span>
<span class="line" id="L106">        <span class="tok-kw">const</span> a3: <span class="tok-type">u32</span> = rotr32(fetch32(str.ptr, str.len - <span class="tok-number">12</span>) *% c1, <span class="tok-number">17</span>) *% c2;</span>
<span class="line" id="L107">        <span class="tok-kw">const</span> a4: <span class="tok-type">u32</span> = rotr32(fetch32(str.ptr, str.len - <span class="tok-number">20</span>) *% c1, <span class="tok-number">17</span>) *% c2;</span>
<span class="line" id="L108"></span>
<span class="line" id="L109">        h ^= a0;</span>
<span class="line" id="L110">        h = rotr32(h, <span class="tok-number">19</span>);</span>
<span class="line" id="L111">        h = h *% <span class="tok-number">5</span> +% <span class="tok-number">0xe6546b64</span>;</span>
<span class="line" id="L112">        h ^= a2;</span>
<span class="line" id="L113">        h = rotr32(h, <span class="tok-number">19</span>);</span>
<span class="line" id="L114">        h = h *% <span class="tok-number">5</span> +% <span class="tok-number">0xe6546b64</span>;</span>
<span class="line" id="L115">        g ^= a1;</span>
<span class="line" id="L116">        g = rotr32(g, <span class="tok-number">19</span>);</span>
<span class="line" id="L117">        g = g *% <span class="tok-number">5</span> +% <span class="tok-number">0xe6546b64</span>;</span>
<span class="line" id="L118">        g ^= a3;</span>
<span class="line" id="L119">        g = rotr32(g, <span class="tok-number">19</span>);</span>
<span class="line" id="L120">        g = g *% <span class="tok-number">5</span> +% <span class="tok-number">0xe6546b64</span>;</span>
<span class="line" id="L121">        f +%= a4;</span>
<span class="line" id="L122">        f = rotr32(f, <span class="tok-number">19</span>);</span>
<span class="line" id="L123">        f = f *% <span class="tok-number">5</span> +% <span class="tok-number">0xe6546b64</span>;</span>
<span class="line" id="L124">        <span class="tok-kw">var</span> iters = (str.len - <span class="tok-number">1</span>) / <span class="tok-number">20</span>;</span>
<span class="line" id="L125">        <span class="tok-kw">var</span> ptr = str.ptr;</span>
<span class="line" id="L126">        <span class="tok-kw">while</span> (iters != <span class="tok-number">0</span>) : (iters -= <span class="tok-number">1</span>) {</span>
<span class="line" id="L127">            <span class="tok-kw">const</span> b0: <span class="tok-type">u32</span> = rotr32(fetch32(ptr, <span class="tok-number">0</span>) *% c1, <span class="tok-number">17</span>) *% c2;</span>
<span class="line" id="L128">            <span class="tok-kw">const</span> b1: <span class="tok-type">u32</span> = fetch32(ptr, <span class="tok-number">4</span>);</span>
<span class="line" id="L129">            <span class="tok-kw">const</span> b2: <span class="tok-type">u32</span> = rotr32(fetch32(ptr, <span class="tok-number">8</span>) *% c1, <span class="tok-number">17</span>) *% c2;</span>
<span class="line" id="L130">            <span class="tok-kw">const</span> b3: <span class="tok-type">u32</span> = rotr32(fetch32(ptr, <span class="tok-number">12</span>) *% c1, <span class="tok-number">17</span>) *% c2;</span>
<span class="line" id="L131">            <span class="tok-kw">const</span> b4: <span class="tok-type">u32</span> = fetch32(ptr, <span class="tok-number">16</span>);</span>
<span class="line" id="L132"></span>
<span class="line" id="L133">            h ^= b0;</span>
<span class="line" id="L134">            h = rotr32(h, <span class="tok-number">18</span>);</span>
<span class="line" id="L135">            h = h *% <span class="tok-number">5</span> +% <span class="tok-number">0xe6546b64</span>;</span>
<span class="line" id="L136">            f +%= b1;</span>
<span class="line" id="L137">            f = rotr32(f, <span class="tok-number">19</span>);</span>
<span class="line" id="L138">            f = f *% c1;</span>
<span class="line" id="L139">            g +%= b2;</span>
<span class="line" id="L140">            g = rotr32(g, <span class="tok-number">18</span>);</span>
<span class="line" id="L141">            g = g *% <span class="tok-number">5</span> +% <span class="tok-number">0xe6546b64</span>;</span>
<span class="line" id="L142">            h ^= b3 +% b1;</span>
<span class="line" id="L143">            h = rotr32(h, <span class="tok-number">19</span>);</span>
<span class="line" id="L144">            h = h *% <span class="tok-number">5</span> +% <span class="tok-number">0xe6546b64</span>;</span>
<span class="line" id="L145">            g ^= b4;</span>
<span class="line" id="L146">            g = <span class="tok-builtin">@byteSwap</span>(<span class="tok-type">u32</span>, g) *% <span class="tok-number">5</span>;</span>
<span class="line" id="L147">            h +%= b4 *% <span class="tok-number">5</span>;</span>
<span class="line" id="L148">            h = <span class="tok-builtin">@byteSwap</span>(<span class="tok-type">u32</span>, h);</span>
<span class="line" id="L149">            f +%= b0;</span>
<span class="line" id="L150">            <span class="tok-kw">const</span> t: <span class="tok-type">u32</span> = h;</span>
<span class="line" id="L151">            h = f;</span>
<span class="line" id="L152">            f = g;</span>
<span class="line" id="L153">            g = t;</span>
<span class="line" id="L154">            ptr = offsetPtr(ptr, <span class="tok-number">20</span>);</span>
<span class="line" id="L155">        }</span>
<span class="line" id="L156">        g = rotr32(g, <span class="tok-number">11</span>) *% c1;</span>
<span class="line" id="L157">        g = rotr32(g, <span class="tok-number">17</span>) *% c1;</span>
<span class="line" id="L158">        f = rotr32(f, <span class="tok-number">11</span>) *% c1;</span>
<span class="line" id="L159">        f = rotr32(f, <span class="tok-number">17</span>) *% c1;</span>
<span class="line" id="L160">        h = rotr32(h +% g, <span class="tok-number">19</span>);</span>
<span class="line" id="L161">        h = h *% <span class="tok-number">5</span> +% <span class="tok-number">0xe6546b64</span>;</span>
<span class="line" id="L162">        h = rotr32(h, <span class="tok-number">17</span>) *% c1;</span>
<span class="line" id="L163">        h = rotr32(h +% f, <span class="tok-number">19</span>);</span>
<span class="line" id="L164">        h = h *% <span class="tok-number">5</span> +% <span class="tok-number">0xe6546b64</span>;</span>
<span class="line" id="L165">        h = rotr32(h, <span class="tok-number">17</span>) *% c1;</span>
<span class="line" id="L166">        <span class="tok-kw">return</span> h;</span>
<span class="line" id="L167">    }</span>
<span class="line" id="L168">};</span>
<span class="line" id="L169"></span>
<span class="line" id="L170"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> CityHash64 = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L171">    <span class="tok-kw">const</span> Self = <span class="tok-builtin">@This</span>();</span>
<span class="line" id="L172"></span>
<span class="line" id="L173">    <span class="tok-comment">// Some primes between 2^63 and 2^64 for various uses.</span>
</span>
<span class="line" id="L174">    <span class="tok-kw">const</span> k0: <span class="tok-type">u64</span> = <span class="tok-number">0xc3a5c85c97cb3127</span>;</span>
<span class="line" id="L175">    <span class="tok-kw">const</span> k1: <span class="tok-type">u64</span> = <span class="tok-number">0xb492b66fbe98f273</span>;</span>
<span class="line" id="L176">    <span class="tok-kw">const</span> k2: <span class="tok-type">u64</span> = <span class="tok-number">0x9ae16a3b2f90404f</span>;</span>
<span class="line" id="L177"></span>
<span class="line" id="L178">    <span class="tok-comment">// Rotate right helper</span>
</span>
<span class="line" id="L179">    <span class="tok-kw">fn</span> <span class="tok-fn">rotr64</span>(x: <span class="tok-type">u64</span>, <span class="tok-kw">comptime</span> r: <span class="tok-type">u64</span>) <span class="tok-type">u64</span> {</span>
<span class="line" id="L180">        <span class="tok-kw">return</span> (x &gt;&gt; r) | (x &lt;&lt; (<span class="tok-number">64</span> - r));</span>
<span class="line" id="L181">    }</span>
<span class="line" id="L182"></span>
<span class="line" id="L183">    <span class="tok-kw">fn</span> <span class="tok-fn">shiftmix</span>(v: <span class="tok-type">u64</span>) <span class="tok-type">u64</span> {</span>
<span class="line" id="L184">        <span class="tok-kw">return</span> v ^ (v &gt;&gt; <span class="tok-number">47</span>);</span>
<span class="line" id="L185">    }</span>
<span class="line" id="L186"></span>
<span class="line" id="L187">    <span class="tok-kw">fn</span> <span class="tok-fn">hashLen16</span>(u: <span class="tok-type">u64</span>, v: <span class="tok-type">u64</span>) <span class="tok-type">u64</span> {</span>
<span class="line" id="L188">        <span class="tok-kw">return</span> <span class="tok-builtin">@call</span>(.{ .modifier = .always_inline }, hash128To64, .{ u, v });</span>
<span class="line" id="L189">    }</span>
<span class="line" id="L190"></span>
<span class="line" id="L191">    <span class="tok-kw">fn</span> <span class="tok-fn">hashLen16Mul</span>(low: <span class="tok-type">u64</span>, high: <span class="tok-type">u64</span>, mul: <span class="tok-type">u64</span>) <span class="tok-type">u64</span> {</span>
<span class="line" id="L192">        <span class="tok-kw">var</span> a: <span class="tok-type">u64</span> = (low ^ high) *% mul;</span>
<span class="line" id="L193">        a ^= (a &gt;&gt; <span class="tok-number">47</span>);</span>
<span class="line" id="L194">        <span class="tok-kw">var</span> b: <span class="tok-type">u64</span> = (high ^ a) *% mul;</span>
<span class="line" id="L195">        b ^= (b &gt;&gt; <span class="tok-number">47</span>);</span>
<span class="line" id="L196">        b *%= mul;</span>
<span class="line" id="L197">        <span class="tok-kw">return</span> b;</span>
<span class="line" id="L198">    }</span>
<span class="line" id="L199"></span>
<span class="line" id="L200">    <span class="tok-kw">fn</span> <span class="tok-fn">hash128To64</span>(low: <span class="tok-type">u64</span>, high: <span class="tok-type">u64</span>) <span class="tok-type">u64</span> {</span>
<span class="line" id="L201">        <span class="tok-kw">return</span> <span class="tok-builtin">@call</span>(.{ .modifier = .always_inline }, hashLen16Mul, .{ low, high, <span class="tok-number">0x9ddfea08eb382d69</span> });</span>
<span class="line" id="L202">    }</span>
<span class="line" id="L203"></span>
<span class="line" id="L204">    <span class="tok-kw">fn</span> <span class="tok-fn">hashLen0To16</span>(str: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) <span class="tok-type">u64</span> {</span>
<span class="line" id="L205">        <span class="tok-kw">const</span> len: <span class="tok-type">u64</span> = <span class="tok-builtin">@as</span>(<span class="tok-type">u64</span>, str.len);</span>
<span class="line" id="L206">        <span class="tok-kw">if</span> (len &gt;= <span class="tok-number">8</span>) {</span>
<span class="line" id="L207">            <span class="tok-kw">const</span> mul: <span class="tok-type">u64</span> = k2 +% len *% <span class="tok-number">2</span>;</span>
<span class="line" id="L208">            <span class="tok-kw">const</span> a: <span class="tok-type">u64</span> = fetch64(str.ptr, <span class="tok-number">0</span>) +% k2;</span>
<span class="line" id="L209">            <span class="tok-kw">const</span> b: <span class="tok-type">u64</span> = fetch64(str.ptr, str.len - <span class="tok-number">8</span>);</span>
<span class="line" id="L210">            <span class="tok-kw">const</span> c: <span class="tok-type">u64</span> = rotr64(b, <span class="tok-number">37</span>) *% mul +% a;</span>
<span class="line" id="L211">            <span class="tok-kw">const</span> d: <span class="tok-type">u64</span> = (rotr64(a, <span class="tok-number">25</span>) +% b) *% mul;</span>
<span class="line" id="L212">            <span class="tok-kw">return</span> hashLen16Mul(c, d, mul);</span>
<span class="line" id="L213">        }</span>
<span class="line" id="L214">        <span class="tok-kw">if</span> (len &gt;= <span class="tok-number">4</span>) {</span>
<span class="line" id="L215">            <span class="tok-kw">const</span> mul: <span class="tok-type">u64</span> = k2 +% len *% <span class="tok-number">2</span>;</span>
<span class="line" id="L216">            <span class="tok-kw">const</span> a: <span class="tok-type">u64</span> = fetch32(str.ptr, <span class="tok-number">0</span>);</span>
<span class="line" id="L217">            <span class="tok-kw">return</span> hashLen16Mul(len +% (a &lt;&lt; <span class="tok-number">3</span>), fetch32(str.ptr, str.len - <span class="tok-number">4</span>), mul);</span>
<span class="line" id="L218">        }</span>
<span class="line" id="L219">        <span class="tok-kw">if</span> (len &gt; <span class="tok-number">0</span>) {</span>
<span class="line" id="L220">            <span class="tok-kw">const</span> a: <span class="tok-type">u8</span> = str[<span class="tok-number">0</span>];</span>
<span class="line" id="L221">            <span class="tok-kw">const</span> b: <span class="tok-type">u8</span> = str[str.len &gt;&gt; <span class="tok-number">1</span>];</span>
<span class="line" id="L222">            <span class="tok-kw">const</span> c: <span class="tok-type">u8</span> = str[str.len - <span class="tok-number">1</span>];</span>
<span class="line" id="L223">            <span class="tok-kw">const</span> y: <span class="tok-type">u32</span> = <span class="tok-builtin">@intCast</span>(<span class="tok-type">u32</span>, a) +% (<span class="tok-builtin">@intCast</span>(<span class="tok-type">u32</span>, b) &lt;&lt; <span class="tok-number">8</span>);</span>
<span class="line" id="L224">            <span class="tok-kw">const</span> z: <span class="tok-type">u32</span> = <span class="tok-builtin">@truncate</span>(<span class="tok-type">u32</span>, str.len) +% (<span class="tok-builtin">@intCast</span>(<span class="tok-type">u32</span>, c) &lt;&lt; <span class="tok-number">2</span>);</span>
<span class="line" id="L225">            <span class="tok-kw">return</span> shiftmix(<span class="tok-builtin">@intCast</span>(<span class="tok-type">u64</span>, y) *% k2 ^ <span class="tok-builtin">@intCast</span>(<span class="tok-type">u64</span>, z) *% k0) *% k2;</span>
<span class="line" id="L226">        }</span>
<span class="line" id="L227">        <span class="tok-kw">return</span> k2;</span>
<span class="line" id="L228">    }</span>
<span class="line" id="L229"></span>
<span class="line" id="L230">    <span class="tok-kw">fn</span> <span class="tok-fn">hashLen17To32</span>(str: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) <span class="tok-type">u64</span> {</span>
<span class="line" id="L231">        <span class="tok-kw">const</span> len: <span class="tok-type">u64</span> = <span class="tok-builtin">@as</span>(<span class="tok-type">u64</span>, str.len);</span>
<span class="line" id="L232">        <span class="tok-kw">const</span> mul: <span class="tok-type">u64</span> = k2 +% len *% <span class="tok-number">2</span>;</span>
<span class="line" id="L233">        <span class="tok-kw">const</span> a: <span class="tok-type">u64</span> = fetch64(str.ptr, <span class="tok-number">0</span>) *% k1;</span>
<span class="line" id="L234">        <span class="tok-kw">const</span> b: <span class="tok-type">u64</span> = fetch64(str.ptr, <span class="tok-number">8</span>);</span>
<span class="line" id="L235">        <span class="tok-kw">const</span> c: <span class="tok-type">u64</span> = fetch64(str.ptr, str.len - <span class="tok-number">8</span>) *% mul;</span>
<span class="line" id="L236">        <span class="tok-kw">const</span> d: <span class="tok-type">u64</span> = fetch64(str.ptr, str.len - <span class="tok-number">16</span>) *% k2;</span>
<span class="line" id="L237"></span>
<span class="line" id="L238">        <span class="tok-kw">return</span> hashLen16Mul(rotr64(a +% b, <span class="tok-number">43</span>) +% rotr64(c, <span class="tok-number">30</span>) +% d, a +% rotr64(b +% k2, <span class="tok-number">18</span>) +% c, mul);</span>
<span class="line" id="L239">    }</span>
<span class="line" id="L240"></span>
<span class="line" id="L241">    <span class="tok-kw">fn</span> <span class="tok-fn">hashLen33To64</span>(str: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) <span class="tok-type">u64</span> {</span>
<span class="line" id="L242">        <span class="tok-kw">const</span> len: <span class="tok-type">u64</span> = <span class="tok-builtin">@as</span>(<span class="tok-type">u64</span>, str.len);</span>
<span class="line" id="L243">        <span class="tok-kw">const</span> mul: <span class="tok-type">u64</span> = k2 +% len *% <span class="tok-number">2</span>;</span>
<span class="line" id="L244">        <span class="tok-kw">const</span> a: <span class="tok-type">u64</span> = fetch64(str.ptr, <span class="tok-number">0</span>) *% k2;</span>
<span class="line" id="L245">        <span class="tok-kw">const</span> b: <span class="tok-type">u64</span> = fetch64(str.ptr, <span class="tok-number">8</span>);</span>
<span class="line" id="L246">        <span class="tok-kw">const</span> c: <span class="tok-type">u64</span> = fetch64(str.ptr, str.len - <span class="tok-number">24</span>);</span>
<span class="line" id="L247">        <span class="tok-kw">const</span> d: <span class="tok-type">u64</span> = fetch64(str.ptr, str.len - <span class="tok-number">32</span>);</span>
<span class="line" id="L248">        <span class="tok-kw">const</span> e: <span class="tok-type">u64</span> = fetch64(str.ptr, <span class="tok-number">16</span>) *% k2;</span>
<span class="line" id="L249">        <span class="tok-kw">const</span> f: <span class="tok-type">u64</span> = fetch64(str.ptr, <span class="tok-number">24</span>) *% <span class="tok-number">9</span>;</span>
<span class="line" id="L250">        <span class="tok-kw">const</span> g: <span class="tok-type">u64</span> = fetch64(str.ptr, str.len - <span class="tok-number">8</span>);</span>
<span class="line" id="L251">        <span class="tok-kw">const</span> h: <span class="tok-type">u64</span> = fetch64(str.ptr, str.len - <span class="tok-number">16</span>) *% mul;</span>
<span class="line" id="L252"></span>
<span class="line" id="L253">        <span class="tok-kw">const</span> u: <span class="tok-type">u64</span> = rotr64(a +% g, <span class="tok-number">43</span>) +% (rotr64(b, <span class="tok-number">30</span>) +% c) *% <span class="tok-number">9</span>;</span>
<span class="line" id="L254">        <span class="tok-kw">const</span> v: <span class="tok-type">u64</span> = ((a +% g) ^ d) +% f +% <span class="tok-number">1</span>;</span>
<span class="line" id="L255">        <span class="tok-kw">const</span> w: <span class="tok-type">u64</span> = <span class="tok-builtin">@byteSwap</span>(<span class="tok-type">u64</span>, (u +% v) *% mul) +% h;</span>
<span class="line" id="L256">        <span class="tok-kw">const</span> x: <span class="tok-type">u64</span> = rotr64(e +% f, <span class="tok-number">42</span>) +% c;</span>
<span class="line" id="L257">        <span class="tok-kw">const</span> y: <span class="tok-type">u64</span> = (<span class="tok-builtin">@byteSwap</span>(<span class="tok-type">u64</span>, (v +% w) *% mul) +% g) *% mul;</span>
<span class="line" id="L258">        <span class="tok-kw">const</span> z: <span class="tok-type">u64</span> = e +% f +% c;</span>
<span class="line" id="L259">        <span class="tok-kw">const</span> a1: <span class="tok-type">u64</span> = <span class="tok-builtin">@byteSwap</span>(<span class="tok-type">u64</span>, (x +% z) *% mul +% y) +% b;</span>
<span class="line" id="L260">        <span class="tok-kw">const</span> b1: <span class="tok-type">u64</span> = shiftmix((z +% a1) *% mul +% d +% h) *% mul;</span>
<span class="line" id="L261">        <span class="tok-kw">return</span> b1 +% x;</span>
<span class="line" id="L262">    }</span>
<span class="line" id="L263"></span>
<span class="line" id="L264">    <span class="tok-kw">const</span> WeakPair = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L265">        first: <span class="tok-type">u64</span>,</span>
<span class="line" id="L266">        second: <span class="tok-type">u64</span>,</span>
<span class="line" id="L267">    };</span>
<span class="line" id="L268"></span>
<span class="line" id="L269">    <span class="tok-kw">fn</span> <span class="tok-fn">weakHashLen32WithSeedsHelper</span>(w: <span class="tok-type">u64</span>, x: <span class="tok-type">u64</span>, y: <span class="tok-type">u64</span>, z: <span class="tok-type">u64</span>, a: <span class="tok-type">u64</span>, b: <span class="tok-type">u64</span>) WeakPair {</span>
<span class="line" id="L270">        <span class="tok-kw">var</span> a1: <span class="tok-type">u64</span> = a;</span>
<span class="line" id="L271">        <span class="tok-kw">var</span> b1: <span class="tok-type">u64</span> = b;</span>
<span class="line" id="L272">        a1 +%= w;</span>
<span class="line" id="L273">        b1 = rotr64(b1 +% a1 +% z, <span class="tok-number">21</span>);</span>
<span class="line" id="L274">        <span class="tok-kw">var</span> c: <span class="tok-type">u64</span> = a1;</span>
<span class="line" id="L275">        a1 +%= x;</span>
<span class="line" id="L276">        a1 +%= y;</span>
<span class="line" id="L277">        b1 +%= rotr64(a1, <span class="tok-number">44</span>);</span>
<span class="line" id="L278">        <span class="tok-kw">return</span> WeakPair{ .first = a1 +% z, .second = b1 +% c };</span>
<span class="line" id="L279">    }</span>
<span class="line" id="L280"></span>
<span class="line" id="L281">    <span class="tok-kw">fn</span> <span class="tok-fn">weakHashLen32WithSeeds</span>(ptr: [*]<span class="tok-kw">const</span> <span class="tok-type">u8</span>, a: <span class="tok-type">u64</span>, b: <span class="tok-type">u64</span>) WeakPair {</span>
<span class="line" id="L282">        <span class="tok-kw">return</span> <span class="tok-builtin">@call</span>(.{ .modifier = .always_inline }, weakHashLen32WithSeedsHelper, .{</span>
<span class="line" id="L283">            fetch64(ptr, <span class="tok-number">0</span>),</span>
<span class="line" id="L284">            fetch64(ptr, <span class="tok-number">8</span>),</span>
<span class="line" id="L285">            fetch64(ptr, <span class="tok-number">16</span>),</span>
<span class="line" id="L286">            fetch64(ptr, <span class="tok-number">24</span>),</span>
<span class="line" id="L287">            a,</span>
<span class="line" id="L288">            b,</span>
<span class="line" id="L289">        });</span>
<span class="line" id="L290">    }</span>
<span class="line" id="L291"></span>
<span class="line" id="L292">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">hash</span>(str: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) <span class="tok-type">u64</span> {</span>
<span class="line" id="L293">        <span class="tok-kw">if</span> (str.len &lt;= <span class="tok-number">32</span>) {</span>
<span class="line" id="L294">            <span class="tok-kw">if</span> (str.len &lt;= <span class="tok-number">16</span>) {</span>
<span class="line" id="L295">                <span class="tok-kw">return</span> hashLen0To16(str);</span>
<span class="line" id="L296">            } <span class="tok-kw">else</span> {</span>
<span class="line" id="L297">                <span class="tok-kw">return</span> hashLen17To32(str);</span>
<span class="line" id="L298">            }</span>
<span class="line" id="L299">        } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (str.len &lt;= <span class="tok-number">64</span>) {</span>
<span class="line" id="L300">            <span class="tok-kw">return</span> hashLen33To64(str);</span>
<span class="line" id="L301">        }</span>
<span class="line" id="L302"></span>
<span class="line" id="L303">        <span class="tok-kw">var</span> len: <span class="tok-type">u64</span> = <span class="tok-builtin">@as</span>(<span class="tok-type">u64</span>, str.len);</span>
<span class="line" id="L304"></span>
<span class="line" id="L305">        <span class="tok-kw">var</span> x: <span class="tok-type">u64</span> = fetch64(str.ptr, str.len - <span class="tok-number">40</span>);</span>
<span class="line" id="L306">        <span class="tok-kw">var</span> y: <span class="tok-type">u64</span> = fetch64(str.ptr, str.len - <span class="tok-number">16</span>) +% fetch64(str.ptr, str.len - <span class="tok-number">56</span>);</span>
<span class="line" id="L307">        <span class="tok-kw">var</span> z: <span class="tok-type">u64</span> = hashLen16(fetch64(str.ptr, str.len - <span class="tok-number">48</span>) +% len, fetch64(str.ptr, str.len - <span class="tok-number">24</span>));</span>
<span class="line" id="L308">        <span class="tok-kw">var</span> v: WeakPair = weakHashLen32WithSeeds(offsetPtr(str.ptr, str.len - <span class="tok-number">64</span>), len, z);</span>
<span class="line" id="L309">        <span class="tok-kw">var</span> w: WeakPair = weakHashLen32WithSeeds(offsetPtr(str.ptr, str.len - <span class="tok-number">32</span>), y +% k1, x);</span>
<span class="line" id="L310"></span>
<span class="line" id="L311">        x = x *% k1 +% fetch64(str.ptr, <span class="tok-number">0</span>);</span>
<span class="line" id="L312">        len = (len - <span class="tok-number">1</span>) &amp; ~<span class="tok-builtin">@intCast</span>(<span class="tok-type">u64</span>, <span class="tok-number">63</span>);</span>
<span class="line" id="L313"></span>
<span class="line" id="L314">        <span class="tok-kw">var</span> ptr: [*]<span class="tok-kw">const</span> <span class="tok-type">u8</span> = str.ptr;</span>
<span class="line" id="L315">        <span class="tok-kw">while</span> (<span class="tok-null">true</span>) {</span>
<span class="line" id="L316">            x = rotr64(x +% y +% v.first +% fetch64(ptr, <span class="tok-number">8</span>), <span class="tok-number">37</span>) *% k1;</span>
<span class="line" id="L317">            y = rotr64(y +% v.second +% fetch64(ptr, <span class="tok-number">48</span>), <span class="tok-number">42</span>) *% k1;</span>
<span class="line" id="L318">            x ^= w.second;</span>
<span class="line" id="L319">            y +%= v.first +% fetch64(ptr, <span class="tok-number">40</span>);</span>
<span class="line" id="L320">            z = rotr64(z +% w.first, <span class="tok-number">33</span>) *% k1;</span>
<span class="line" id="L321">            v = weakHashLen32WithSeeds(ptr, v.second *% k1, x +% w.first);</span>
<span class="line" id="L322">            w = weakHashLen32WithSeeds(offsetPtr(ptr, <span class="tok-number">32</span>), z +% w.second, y +% fetch64(ptr, <span class="tok-number">16</span>));</span>
<span class="line" id="L323">            <span class="tok-kw">const</span> t: <span class="tok-type">u64</span> = z;</span>
<span class="line" id="L324">            z = x;</span>
<span class="line" id="L325">            x = t;</span>
<span class="line" id="L326"></span>
<span class="line" id="L327">            ptr = offsetPtr(ptr, <span class="tok-number">64</span>);</span>
<span class="line" id="L328">            len -= <span class="tok-number">64</span>;</span>
<span class="line" id="L329">            <span class="tok-kw">if</span> (len == <span class="tok-number">0</span>)</span>
<span class="line" id="L330">                <span class="tok-kw">break</span>;</span>
<span class="line" id="L331">        }</span>
<span class="line" id="L332"></span>
<span class="line" id="L333">        <span class="tok-kw">return</span> hashLen16(hashLen16(v.first, w.first) +% shiftmix(y) *% k1 +% z, hashLen16(v.second, w.second) +% x);</span>
<span class="line" id="L334">    }</span>
<span class="line" id="L335"></span>
<span class="line" id="L336">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">hashWithSeed</span>(str: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, seed: <span class="tok-type">u64</span>) <span class="tok-type">u64</span> {</span>
<span class="line" id="L337">        <span class="tok-kw">return</span> <span class="tok-builtin">@call</span>(.{ .modifier = .always_inline }, Self.hashWithSeeds, .{ str, k2, seed });</span>
<span class="line" id="L338">    }</span>
<span class="line" id="L339"></span>
<span class="line" id="L340">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">hashWithSeeds</span>(str: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, seed0: <span class="tok-type">u64</span>, seed1: <span class="tok-type">u64</span>) <span class="tok-type">u64</span> {</span>
<span class="line" id="L341">        <span class="tok-kw">return</span> hashLen16(hash(str) -% seed0, seed1);</span>
<span class="line" id="L342">    }</span>
<span class="line" id="L343">};</span>
<span class="line" id="L344"></span>
<span class="line" id="L345"><span class="tok-kw">fn</span> <span class="tok-fn">SMHasherTest</span>(<span class="tok-kw">comptime</span> hash_fn: <span class="tok-kw">anytype</span>) <span class="tok-type">u32</span> {</span>
<span class="line" id="L346">    <span class="tok-kw">const</span> HashResult = <span class="tok-builtin">@typeInfo</span>(<span class="tok-builtin">@TypeOf</span>(hash_fn)).Fn.return_type.?;</span>
<span class="line" id="L347"></span>
<span class="line" id="L348">    <span class="tok-kw">var</span> key: [<span class="tok-number">256</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L349">    <span class="tok-kw">var</span> hashes_bytes: [<span class="tok-number">256</span> * <span class="tok-builtin">@sizeOf</span>(HashResult)]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L350"></span>
<span class="line" id="L351">    std.mem.set(<span class="tok-type">u8</span>, &amp;key, <span class="tok-number">0</span>);</span>
<span class="line" id="L352">    std.mem.set(<span class="tok-type">u8</span>, &amp;hashes_bytes, <span class="tok-number">0</span>);</span>
<span class="line" id="L353"></span>
<span class="line" id="L354">    <span class="tok-kw">var</span> i: <span class="tok-type">u32</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L355">    <span class="tok-kw">while</span> (i &lt; <span class="tok-number">256</span>) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L356">        key[i] = <span class="tok-builtin">@intCast</span>(<span class="tok-type">u8</span>, i);</span>
<span class="line" id="L357"></span>
<span class="line" id="L358">        <span class="tok-kw">var</span> h: HashResult = hash_fn(key[<span class="tok-number">0</span>..i], <span class="tok-number">256</span> - i);</span>
<span class="line" id="L359"></span>
<span class="line" id="L360">        <span class="tok-comment">// comptime can't really do reinterpret casting yet,</span>
</span>
<span class="line" id="L361">        <span class="tok-comment">// so we need to write the bytes manually.</span>
</span>
<span class="line" id="L362">        <span class="tok-kw">for</span> (hashes_bytes[i * <span class="tok-builtin">@sizeOf</span>(HashResult) ..][<span class="tok-number">0</span>..<span class="tok-builtin">@sizeOf</span>(HashResult)]) |*byte| {</span>
<span class="line" id="L363">            byte.* = <span class="tok-builtin">@truncate</span>(<span class="tok-type">u8</span>, h);</span>
<span class="line" id="L364">            h = h &gt;&gt; <span class="tok-number">8</span>;</span>
<span class="line" id="L365">        }</span>
<span class="line" id="L366">    }</span>
<span class="line" id="L367"></span>
<span class="line" id="L368">    <span class="tok-kw">return</span> <span class="tok-builtin">@truncate</span>(<span class="tok-type">u32</span>, hash_fn(&amp;hashes_bytes, <span class="tok-number">0</span>));</span>
<span class="line" id="L369">}</span>
<span class="line" id="L370"></span>
<span class="line" id="L371"><span class="tok-kw">fn</span> <span class="tok-fn">CityHash32hashIgnoreSeed</span>(str: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, seed: <span class="tok-type">u32</span>) <span class="tok-type">u32</span> {</span>
<span class="line" id="L372">    _ = seed;</span>
<span class="line" id="L373">    <span class="tok-kw">return</span> CityHash32.hash(str);</span>
<span class="line" id="L374">}</span>
<span class="line" id="L375"></span>
<span class="line" id="L376"><span class="tok-kw">test</span> <span class="tok-str">&quot;cityhash32&quot;</span> {</span>
<span class="line" id="L377">    <span class="tok-kw">const</span> Test = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L378">        <span class="tok-kw">fn</span> <span class="tok-fn">doTest</span>() !<span class="tok-type">void</span> {</span>
<span class="line" id="L379">            <span class="tok-comment">// Note: SMHasher doesn't provide a 32bit version of the algorithm.</span>
</span>
<span class="line" id="L380">            <span class="tok-comment">// Note: The implementation was verified against the Google Abseil version.</span>
</span>
<span class="line" id="L381">            <span class="tok-kw">try</span> std.testing.expectEqual(SMHasherTest(CityHash32hashIgnoreSeed), <span class="tok-number">0x68254F81</span>);</span>
<span class="line" id="L382">            <span class="tok-kw">try</span> std.testing.expectEqual(SMHasherTest(CityHash32hashIgnoreSeed), <span class="tok-number">0x68254F81</span>);</span>
<span class="line" id="L383">        }</span>
<span class="line" id="L384">    };</span>
<span class="line" id="L385">    <span class="tok-kw">try</span> Test.doTest();</span>
<span class="line" id="L386">    <span class="tok-comment">// TODO This is uncommented to prevent OOM on the CI server. Re-enable this test</span>
</span>
<span class="line" id="L387">    <span class="tok-comment">// case once we ship stage2.</span>
</span>
<span class="line" id="L388">    <span class="tok-comment">//@setEvalBranchQuota(50000);</span>
</span>
<span class="line" id="L389">    <span class="tok-comment">//comptime Test.doTest();</span>
</span>
<span class="line" id="L390">}</span>
<span class="line" id="L391"></span>
<span class="line" id="L392"><span class="tok-kw">test</span> <span class="tok-str">&quot;cityhash64&quot;</span> {</span>
<span class="line" id="L393">    <span class="tok-kw">const</span> Test = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L394">        <span class="tok-kw">fn</span> <span class="tok-fn">doTest</span>() !<span class="tok-type">void</span> {</span>
<span class="line" id="L395">            <span class="tok-comment">// Note: This is not compliant with the SMHasher implementation of CityHash64!</span>
</span>
<span class="line" id="L396">            <span class="tok-comment">// Note: The implementation was verified against the Google Abseil version.</span>
</span>
<span class="line" id="L397">            <span class="tok-kw">try</span> std.testing.expectEqual(SMHasherTest(CityHash64.hashWithSeed), <span class="tok-number">0x5FABC5C5</span>);</span>
<span class="line" id="L398">        }</span>
<span class="line" id="L399">    };</span>
<span class="line" id="L400">    <span class="tok-kw">try</span> Test.doTest();</span>
<span class="line" id="L401">    <span class="tok-comment">// TODO This is uncommented to prevent OOM on the CI server. Re-enable this test</span>
</span>
<span class="line" id="L402">    <span class="tok-comment">// case once we ship stage2.</span>
</span>
<span class="line" id="L403">    <span class="tok-comment">//@setEvalBranchQuota(50000);</span>
</span>
<span class="line" id="L404">    <span class="tok-comment">//comptime Test.doTest();</span>
</span>
<span class="line" id="L405">}</span>
<span class="line" id="L406"></span>
</code></pre></body>
</html>