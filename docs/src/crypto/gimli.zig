<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">    <title>crypto/gimli.zig - source view</title>
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
<pre><code><span class="line" id="L1"><span class="tok-comment">//! Gimli is a 384-bit permutation designed to achieve high security with high</span></span>
<span class="line" id="L2"><span class="tok-comment">//! performance across a broad range of platforms, including 64-bit Intel/AMD</span></span>
<span class="line" id="L3"><span class="tok-comment">//! server CPUs, 64-bit and 32-bit ARM smartphone CPUs, 32-bit ARM</span></span>
<span class="line" id="L4"><span class="tok-comment">//! microcontrollers, 8-bit AVR microcontrollers, FPGAs, ASICs without</span></span>
<span class="line" id="L5"><span class="tok-comment">//! side-channel protection, and ASICs with side-channel protection.</span></span>
<span class="line" id="L6"><span class="tok-comment">//!</span></span>
<span class="line" id="L7"><span class="tok-comment">//! https://gimli.cr.yp.to/</span></span>
<span class="line" id="L8"><span class="tok-comment">//! https://csrc.nist.gov/CSRC/media/Projects/Lightweight-Cryptography/documents/round-1/spec-doc/gimli-spec.pdf</span></span>
<span class="line" id="L9"></span>
<span class="line" id="L10"><span class="tok-kw">const</span> std = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;../std.zig&quot;</span>);</span>
<span class="line" id="L11"><span class="tok-kw">const</span> builtin = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;builtin&quot;</span>);</span>
<span class="line" id="L12"><span class="tok-kw">const</span> mem = std.mem;</span>
<span class="line" id="L13"><span class="tok-kw">const</span> math = std.math;</span>
<span class="line" id="L14"><span class="tok-kw">const</span> debug = std.debug;</span>
<span class="line" id="L15"><span class="tok-kw">const</span> assert = std.debug.assert;</span>
<span class="line" id="L16"><span class="tok-kw">const</span> testing = std.testing;</span>
<span class="line" id="L17"><span class="tok-kw">const</span> htest = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;test.zig&quot;</span>);</span>
<span class="line" id="L18"><span class="tok-kw">const</span> AuthenticationError = std.crypto.errors.AuthenticationError;</span>
<span class="line" id="L19"></span>
<span class="line" id="L20"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> State = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L21">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> BLOCKBYTES = <span class="tok-number">48</span>;</span>
<span class="line" id="L22">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> RATE = <span class="tok-number">16</span>;</span>
<span class="line" id="L23"></span>
<span class="line" id="L24">    data: [BLOCKBYTES / <span class="tok-number">4</span>]<span class="tok-type">u32</span> <span class="tok-kw">align</span>(<span class="tok-number">16</span>),</span>
<span class="line" id="L25"></span>
<span class="line" id="L26">    <span class="tok-kw">const</span> Self = <span class="tok-builtin">@This</span>();</span>
<span class="line" id="L27"></span>
<span class="line" id="L28">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">init</span>(initial_state: [State.BLOCKBYTES]<span class="tok-type">u8</span>) Self {</span>
<span class="line" id="L29">        <span class="tok-kw">var</span> data: [BLOCKBYTES / <span class="tok-number">4</span>]<span class="tok-type">u32</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L30">        <span class="tok-kw">var</span> i: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L31">        <span class="tok-kw">while</span> (i &lt; State.BLOCKBYTES) : (i += <span class="tok-number">4</span>) {</span>
<span class="line" id="L32">            data[i / <span class="tok-number">4</span>] = mem.readIntNative(<span class="tok-type">u32</span>, initial_state[i..][<span class="tok-number">0</span>..<span class="tok-number">4</span>]);</span>
<span class="line" id="L33">        }</span>
<span class="line" id="L34">        <span class="tok-kw">return</span> Self{ .data = data };</span>
<span class="line" id="L35">    }</span>
<span class="line" id="L36"></span>
<span class="line" id="L37">    <span class="tok-comment">/// TODO follow the span() convention instead of having this and `toSliceConst`</span></span>
<span class="line" id="L38">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">toSlice</span>(self: *Self) *[BLOCKBYTES]<span class="tok-type">u8</span> {</span>
<span class="line" id="L39">        <span class="tok-kw">return</span> mem.asBytes(&amp;self.data);</span>
<span class="line" id="L40">    }</span>
<span class="line" id="L41"></span>
<span class="line" id="L42">    <span class="tok-comment">/// TODO follow the span() convention instead of having this and `toSlice`</span></span>
<span class="line" id="L43">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">toSliceConst</span>(self: *<span class="tok-kw">const</span> Self) *<span class="tok-kw">const</span> [BLOCKBYTES]<span class="tok-type">u8</span> {</span>
<span class="line" id="L44">        <span class="tok-kw">return</span> mem.asBytes(&amp;self.data);</span>
<span class="line" id="L45">    }</span>
<span class="line" id="L46"></span>
<span class="line" id="L47">    <span class="tok-kw">inline</span> <span class="tok-kw">fn</span> <span class="tok-fn">endianSwap</span>(self: *Self) <span class="tok-type">void</span> {</span>
<span class="line" id="L48">        <span class="tok-kw">for</span> (self.data) |*w| {</span>
<span class="line" id="L49">            w.* = mem.littleToNative(<span class="tok-type">u32</span>, w.*);</span>
<span class="line" id="L50">        }</span>
<span class="line" id="L51">    }</span>
<span class="line" id="L52"></span>
<span class="line" id="L53">    <span class="tok-kw">fn</span> <span class="tok-fn">permute_unrolled</span>(self: *Self) <span class="tok-type">void</span> {</span>
<span class="line" id="L54">        self.endianSwap();</span>
<span class="line" id="L55">        <span class="tok-kw">const</span> state = &amp;self.data;</span>
<span class="line" id="L56">        <span class="tok-kw">comptime</span> <span class="tok-kw">var</span> round = <span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">24</span>);</span>
<span class="line" id="L57">        <span class="tok-kw">inline</span> <span class="tok-kw">while</span> (round &gt; <span class="tok-number">0</span>) : (round -= <span class="tok-number">1</span>) {</span>
<span class="line" id="L58">            <span class="tok-kw">var</span> column = <span class="tok-builtin">@as</span>(<span class="tok-type">usize</span>, <span class="tok-number">0</span>);</span>
<span class="line" id="L59">            <span class="tok-kw">while</span> (column &lt; <span class="tok-number">4</span>) : (column += <span class="tok-number">1</span>) {</span>
<span class="line" id="L60">                <span class="tok-kw">const</span> x = math.rotl(<span class="tok-type">u32</span>, state[column], <span class="tok-number">24</span>);</span>
<span class="line" id="L61">                <span class="tok-kw">const</span> y = math.rotl(<span class="tok-type">u32</span>, state[<span class="tok-number">4</span> + column], <span class="tok-number">9</span>);</span>
<span class="line" id="L62">                <span class="tok-kw">const</span> z = state[<span class="tok-number">8</span> + column];</span>
<span class="line" id="L63">                state[<span class="tok-number">8</span> + column] = ((x ^ (z &lt;&lt; <span class="tok-number">1</span>)) ^ ((y &amp; z) &lt;&lt; <span class="tok-number">2</span>));</span>
<span class="line" id="L64">                state[<span class="tok-number">4</span> + column] = ((y ^ x) ^ ((x | z) &lt;&lt; <span class="tok-number">1</span>));</span>
<span class="line" id="L65">                state[column] = ((z ^ y) ^ ((x &amp; y) &lt;&lt; <span class="tok-number">3</span>));</span>
<span class="line" id="L66">            }</span>
<span class="line" id="L67">            <span class="tok-kw">switch</span> (round &amp; <span class="tok-number">3</span>) {</span>
<span class="line" id="L68">                <span class="tok-number">0</span> =&gt; {</span>
<span class="line" id="L69">                    mem.swap(<span class="tok-type">u32</span>, &amp;state[<span class="tok-number">0</span>], &amp;state[<span class="tok-number">1</span>]);</span>
<span class="line" id="L70">                    mem.swap(<span class="tok-type">u32</span>, &amp;state[<span class="tok-number">2</span>], &amp;state[<span class="tok-number">3</span>]);</span>
<span class="line" id="L71">                    state[<span class="tok-number">0</span>] ^= round | <span class="tok-number">0x9e377900</span>;</span>
<span class="line" id="L72">                },</span>
<span class="line" id="L73">                <span class="tok-number">2</span> =&gt; {</span>
<span class="line" id="L74">                    mem.swap(<span class="tok-type">u32</span>, &amp;state[<span class="tok-number">0</span>], &amp;state[<span class="tok-number">2</span>]);</span>
<span class="line" id="L75">                    mem.swap(<span class="tok-type">u32</span>, &amp;state[<span class="tok-number">1</span>], &amp;state[<span class="tok-number">3</span>]);</span>
<span class="line" id="L76">                },</span>
<span class="line" id="L77">                <span class="tok-kw">else</span> =&gt; {},</span>
<span class="line" id="L78">            }</span>
<span class="line" id="L79">        }</span>
<span class="line" id="L80">        self.endianSwap();</span>
<span class="line" id="L81">    }</span>
<span class="line" id="L82"></span>
<span class="line" id="L83">    <span class="tok-kw">fn</span> <span class="tok-fn">permute_small</span>(self: *Self) <span class="tok-type">void</span> {</span>
<span class="line" id="L84">        self.endianSwap();</span>
<span class="line" id="L85">        <span class="tok-kw">const</span> state = &amp;self.data;</span>
<span class="line" id="L86">        <span class="tok-kw">var</span> round = <span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">24</span>);</span>
<span class="line" id="L87">        <span class="tok-kw">while</span> (round &gt; <span class="tok-number">0</span>) : (round -= <span class="tok-number">1</span>) {</span>
<span class="line" id="L88">            <span class="tok-kw">var</span> column = <span class="tok-builtin">@as</span>(<span class="tok-type">usize</span>, <span class="tok-number">0</span>);</span>
<span class="line" id="L89">            <span class="tok-kw">while</span> (column &lt; <span class="tok-number">4</span>) : (column += <span class="tok-number">1</span>) {</span>
<span class="line" id="L90">                <span class="tok-kw">const</span> x = math.rotl(<span class="tok-type">u32</span>, state[column], <span class="tok-number">24</span>);</span>
<span class="line" id="L91">                <span class="tok-kw">const</span> y = math.rotl(<span class="tok-type">u32</span>, state[<span class="tok-number">4</span> + column], <span class="tok-number">9</span>);</span>
<span class="line" id="L92">                <span class="tok-kw">const</span> z = state[<span class="tok-number">8</span> + column];</span>
<span class="line" id="L93">                state[<span class="tok-number">8</span> + column] = ((x ^ (z &lt;&lt; <span class="tok-number">1</span>)) ^ ((y &amp; z) &lt;&lt; <span class="tok-number">2</span>));</span>
<span class="line" id="L94">                state[<span class="tok-number">4</span> + column] = ((y ^ x) ^ ((x | z) &lt;&lt; <span class="tok-number">1</span>));</span>
<span class="line" id="L95">                state[column] = ((z ^ y) ^ ((x &amp; y) &lt;&lt; <span class="tok-number">3</span>));</span>
<span class="line" id="L96">            }</span>
<span class="line" id="L97">            <span class="tok-kw">switch</span> (round &amp; <span class="tok-number">3</span>) {</span>
<span class="line" id="L98">                <span class="tok-number">0</span> =&gt; {</span>
<span class="line" id="L99">                    mem.swap(<span class="tok-type">u32</span>, &amp;state[<span class="tok-number">0</span>], &amp;state[<span class="tok-number">1</span>]);</span>
<span class="line" id="L100">                    mem.swap(<span class="tok-type">u32</span>, &amp;state[<span class="tok-number">2</span>], &amp;state[<span class="tok-number">3</span>]);</span>
<span class="line" id="L101">                    state[<span class="tok-number">0</span>] ^= round | <span class="tok-number">0x9e377900</span>;</span>
<span class="line" id="L102">                },</span>
<span class="line" id="L103">                <span class="tok-number">2</span> =&gt; {</span>
<span class="line" id="L104">                    mem.swap(<span class="tok-type">u32</span>, &amp;state[<span class="tok-number">0</span>], &amp;state[<span class="tok-number">2</span>]);</span>
<span class="line" id="L105">                    mem.swap(<span class="tok-type">u32</span>, &amp;state[<span class="tok-number">1</span>], &amp;state[<span class="tok-number">3</span>]);</span>
<span class="line" id="L106">                },</span>
<span class="line" id="L107">                <span class="tok-kw">else</span> =&gt; {},</span>
<span class="line" id="L108">            }</span>
<span class="line" id="L109">        }</span>
<span class="line" id="L110">        self.endianSwap();</span>
<span class="line" id="L111">    }</span>
<span class="line" id="L112"></span>
<span class="line" id="L113">    <span class="tok-kw">const</span> Lane = <span class="tok-builtin">@Vector</span>(<span class="tok-number">4</span>, <span class="tok-type">u32</span>);</span>
<span class="line" id="L114"></span>
<span class="line" id="L115">    <span class="tok-kw">inline</span> <span class="tok-kw">fn</span> <span class="tok-fn">shift</span>(x: Lane, <span class="tok-kw">comptime</span> n: <span class="tok-type">comptime_int</span>) Lane {</span>
<span class="line" id="L116">        <span class="tok-kw">return</span> x &lt;&lt; <span class="tok-builtin">@splat</span>(<span class="tok-number">4</span>, <span class="tok-builtin">@as</span>(<span class="tok-type">u5</span>, n));</span>
<span class="line" id="L117">    }</span>
<span class="line" id="L118"></span>
<span class="line" id="L119">    <span class="tok-kw">fn</span> <span class="tok-fn">permute_vectorized</span>(self: *Self) <span class="tok-type">void</span> {</span>
<span class="line" id="L120">        self.endianSwap();</span>
<span class="line" id="L121">        <span class="tok-kw">const</span> state = &amp;self.data;</span>
<span class="line" id="L122">        <span class="tok-kw">var</span> x = Lane{ state[<span class="tok-number">0</span>], state[<span class="tok-number">1</span>], state[<span class="tok-number">2</span>], state[<span class="tok-number">3</span>] };</span>
<span class="line" id="L123">        <span class="tok-kw">var</span> y = Lane{ state[<span class="tok-number">4</span>], state[<span class="tok-number">5</span>], state[<span class="tok-number">6</span>], state[<span class="tok-number">7</span>] };</span>
<span class="line" id="L124">        <span class="tok-kw">var</span> z = Lane{ state[<span class="tok-number">8</span>], state[<span class="tok-number">9</span>], state[<span class="tok-number">10</span>], state[<span class="tok-number">11</span>] };</span>
<span class="line" id="L125">        <span class="tok-kw">var</span> round = <span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">24</span>);</span>
<span class="line" id="L126">        <span class="tok-kw">while</span> (round &gt; <span class="tok-number">0</span>) : (round -= <span class="tok-number">1</span>) {</span>
<span class="line" id="L127">            x = math.rotl(Lane, x, <span class="tok-number">24</span>);</span>
<span class="line" id="L128">            y = math.rotl(Lane, y, <span class="tok-number">9</span>);</span>
<span class="line" id="L129">            <span class="tok-kw">const</span> newz = x ^ shift(z, <span class="tok-number">1</span>) ^ shift(y &amp; z, <span class="tok-number">2</span>);</span>
<span class="line" id="L130">            <span class="tok-kw">const</span> newy = y ^ x ^ shift(x | z, <span class="tok-number">1</span>);</span>
<span class="line" id="L131">            <span class="tok-kw">const</span> newx = z ^ y ^ shift(x &amp; y, <span class="tok-number">3</span>);</span>
<span class="line" id="L132">            x = newx;</span>
<span class="line" id="L133">            y = newy;</span>
<span class="line" id="L134">            z = newz;</span>
<span class="line" id="L135">            <span class="tok-kw">switch</span> (round &amp; <span class="tok-number">3</span>) {</span>
<span class="line" id="L136">                <span class="tok-number">0</span> =&gt; {</span>
<span class="line" id="L137">                    x = <span class="tok-builtin">@shuffle</span>(<span class="tok-type">u32</span>, x, <span class="tok-null">undefined</span>, [_]<span class="tok-type">i32</span>{ <span class="tok-number">1</span>, <span class="tok-number">0</span>, <span class="tok-number">3</span>, <span class="tok-number">2</span> });</span>
<span class="line" id="L138">                    x[<span class="tok-number">0</span>] ^= round | <span class="tok-number">0x9e377900</span>;</span>
<span class="line" id="L139">                },</span>
<span class="line" id="L140">                <span class="tok-number">2</span> =&gt; {</span>
<span class="line" id="L141">                    x = <span class="tok-builtin">@shuffle</span>(<span class="tok-type">u32</span>, x, <span class="tok-null">undefined</span>, [_]<span class="tok-type">i32</span>{ <span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">0</span>, <span class="tok-number">1</span> });</span>
<span class="line" id="L142">                },</span>
<span class="line" id="L143">                <span class="tok-kw">else</span> =&gt; {},</span>
<span class="line" id="L144">            }</span>
<span class="line" id="L145">        }</span>
<span class="line" id="L146">        <span class="tok-kw">comptime</span> <span class="tok-kw">var</span> i: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L147">        <span class="tok-kw">inline</span> <span class="tok-kw">while</span> (i &lt; <span class="tok-number">4</span>) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L148">            state[<span class="tok-number">0</span> + i] = x[i];</span>
<span class="line" id="L149">            state[<span class="tok-number">4</span> + i] = y[i];</span>
<span class="line" id="L150">            state[<span class="tok-number">8</span> + i] = z[i];</span>
<span class="line" id="L151">        }</span>
<span class="line" id="L152">        self.endianSwap();</span>
<span class="line" id="L153">    }</span>
<span class="line" id="L154"></span>
<span class="line" id="L155">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> permute = <span class="tok-kw">if</span> (builtin.cpu.arch == .x86_64) impl: {</span>
<span class="line" id="L156">        <span class="tok-kw">break</span> :impl permute_vectorized;</span>
<span class="line" id="L157">    } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (builtin.mode == .ReleaseSmall) impl: {</span>
<span class="line" id="L158">        <span class="tok-kw">break</span> :impl permute_small;</span>
<span class="line" id="L159">    } <span class="tok-kw">else</span> impl: {</span>
<span class="line" id="L160">        <span class="tok-kw">break</span> :impl permute_unrolled;</span>
<span class="line" id="L161">    };</span>
<span class="line" id="L162"></span>
<span class="line" id="L163">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">squeeze</span>(self: *Self, out: []<span class="tok-type">u8</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L164">        <span class="tok-kw">var</span> i = <span class="tok-builtin">@as</span>(<span class="tok-type">usize</span>, <span class="tok-number">0</span>);</span>
<span class="line" id="L165">        <span class="tok-kw">while</span> (i + RATE &lt;= out.len) : (i += RATE) {</span>
<span class="line" id="L166">            self.permute();</span>
<span class="line" id="L167">            mem.copy(<span class="tok-type">u8</span>, out[i..], self.toSliceConst()[<span class="tok-number">0</span>..RATE]);</span>
<span class="line" id="L168">        }</span>
<span class="line" id="L169">        <span class="tok-kw">const</span> leftover = out.len - i;</span>
<span class="line" id="L170">        <span class="tok-kw">if</span> (leftover != <span class="tok-number">0</span>) {</span>
<span class="line" id="L171">            self.permute();</span>
<span class="line" id="L172">            mem.copy(<span class="tok-type">u8</span>, out[i..], self.toSliceConst()[<span class="tok-number">0</span>..leftover]);</span>
<span class="line" id="L173">        }</span>
<span class="line" id="L174">    }</span>
<span class="line" id="L175">};</span>
<span class="line" id="L176"></span>
<span class="line" id="L177"><span class="tok-kw">test</span> <span class="tok-str">&quot;permute&quot;</span> {</span>
<span class="line" id="L178">    <span class="tok-comment">// test vector from gimli-20170627</span>
</span>
<span class="line" id="L179">    <span class="tok-kw">const</span> tv_input = [<span class="tok-number">3</span>][<span class="tok-number">4</span>]<span class="tok-type">u32</span>{</span>
<span class="line" id="L180">        [<span class="tok-number">4</span>]<span class="tok-type">u32</span>{ <span class="tok-number">0x00000000</span>, <span class="tok-number">0x9e3779ba</span>, <span class="tok-number">0x3c6ef37a</span>, <span class="tok-number">0xdaa66d46</span> },</span>
<span class="line" id="L181">        [<span class="tok-number">4</span>]<span class="tok-type">u32</span>{ <span class="tok-number">0x78dde724</span>, <span class="tok-number">0x1715611a</span>, <span class="tok-number">0xb54cdb2e</span>, <span class="tok-number">0x53845566</span> },</span>
<span class="line" id="L182">        [<span class="tok-number">4</span>]<span class="tok-type">u32</span>{ <span class="tok-number">0xf1bbcfc8</span>, <span class="tok-number">0x8ff34a5a</span>, <span class="tok-number">0x2e2ac522</span>, <span class="tok-number">0xcc624026</span> },</span>
<span class="line" id="L183">    };</span>
<span class="line" id="L184">    <span class="tok-kw">var</span> input: [<span class="tok-number">48</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L185">    <span class="tok-kw">var</span> i: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L186">    <span class="tok-kw">while</span> (i &lt; <span class="tok-number">12</span>) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L187">        mem.writeIntLittle(<span class="tok-type">u32</span>, input[i * <span class="tok-number">4</span> ..][<span class="tok-number">0</span>..<span class="tok-number">4</span>], tv_input[i / <span class="tok-number">4</span>][i % <span class="tok-number">4</span>]);</span>
<span class="line" id="L188">    }</span>
<span class="line" id="L189"></span>
<span class="line" id="L190">    <span class="tok-kw">var</span> state = State.init(input);</span>
<span class="line" id="L191">    state.permute();</span>
<span class="line" id="L192"></span>
<span class="line" id="L193">    <span class="tok-kw">const</span> tv_output = [<span class="tok-number">3</span>][<span class="tok-number">4</span>]<span class="tok-type">u32</span>{</span>
<span class="line" id="L194">        [<span class="tok-number">4</span>]<span class="tok-type">u32</span>{ <span class="tok-number">0xba11c85a</span>, <span class="tok-number">0x91bad119</span>, <span class="tok-number">0x380ce880</span>, <span class="tok-number">0xd24c2c68</span> },</span>
<span class="line" id="L195">        [<span class="tok-number">4</span>]<span class="tok-type">u32</span>{ <span class="tok-number">0x3eceffea</span>, <span class="tok-number">0x277a921c</span>, <span class="tok-number">0x4f73a0bd</span>, <span class="tok-number">0xda5a9cd8</span> },</span>
<span class="line" id="L196">        [<span class="tok-number">4</span>]<span class="tok-type">u32</span>{ <span class="tok-number">0x84b673f0</span>, <span class="tok-number">0x34e52ff7</span>, <span class="tok-number">0x9e2bef49</span>, <span class="tok-number">0xf41bb8d6</span> },</span>
<span class="line" id="L197">    };</span>
<span class="line" id="L198">    <span class="tok-kw">var</span> expected_output: [<span class="tok-number">48</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L199">    i = <span class="tok-number">0</span>;</span>
<span class="line" id="L200">    <span class="tok-kw">while</span> (i &lt; <span class="tok-number">12</span>) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L201">        mem.writeIntLittle(<span class="tok-type">u32</span>, expected_output[i * <span class="tok-number">4</span> ..][<span class="tok-number">0</span>..<span class="tok-number">4</span>], tv_output[i / <span class="tok-number">4</span>][i % <span class="tok-number">4</span>]);</span>
<span class="line" id="L202">    }</span>
<span class="line" id="L203">    <span class="tok-kw">try</span> testing.expectEqualSlices(<span class="tok-type">u8</span>, state.toSliceConst(), expected_output[<span class="tok-number">0</span>..]);</span>
<span class="line" id="L204">}</span>
<span class="line" id="L205"></span>
<span class="line" id="L206"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> Hash = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L207">    state: State,</span>
<span class="line" id="L208">    buf_off: <span class="tok-type">usize</span>,</span>
<span class="line" id="L209"></span>
<span class="line" id="L210">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> block_length = State.RATE;</span>
<span class="line" id="L211">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> digest_length = <span class="tok-number">32</span>;</span>
<span class="line" id="L212">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> Options = <span class="tok-kw">struct</span> {};</span>
<span class="line" id="L213"></span>
<span class="line" id="L214">    <span class="tok-kw">const</span> Self = <span class="tok-builtin">@This</span>();</span>
<span class="line" id="L215"></span>
<span class="line" id="L216">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">init</span>(options: Options) Self {</span>
<span class="line" id="L217">        _ = options;</span>
<span class="line" id="L218">        <span class="tok-kw">return</span> Self{</span>
<span class="line" id="L219">            .state = State{ .data = [_]<span class="tok-type">u32</span>{<span class="tok-number">0</span>} ** (State.BLOCKBYTES / <span class="tok-number">4</span>) },</span>
<span class="line" id="L220">            .buf_off = <span class="tok-number">0</span>,</span>
<span class="line" id="L221">        };</span>
<span class="line" id="L222">    }</span>
<span class="line" id="L223"></span>
<span class="line" id="L224">    <span class="tok-comment">/// Also known as 'absorb'</span></span>
<span class="line" id="L225">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">update</span>(self: *Self, data: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L226">        <span class="tok-kw">const</span> buf = self.state.toSlice();</span>
<span class="line" id="L227">        <span class="tok-kw">var</span> in = data;</span>
<span class="line" id="L228">        <span class="tok-kw">while</span> (in.len &gt; <span class="tok-number">0</span>) {</span>
<span class="line" id="L229">            <span class="tok-kw">const</span> left = State.RATE - self.buf_off;</span>
<span class="line" id="L230">            <span class="tok-kw">const</span> ps = math.min(in.len, left);</span>
<span class="line" id="L231">            <span class="tok-kw">for</span> (buf[self.buf_off .. self.buf_off + ps]) |*p, i| {</span>
<span class="line" id="L232">                p.* ^= in[i];</span>
<span class="line" id="L233">            }</span>
<span class="line" id="L234">            self.buf_off += ps;</span>
<span class="line" id="L235">            in = in[ps..];</span>
<span class="line" id="L236">            <span class="tok-kw">if</span> (self.buf_off == State.RATE) {</span>
<span class="line" id="L237">                self.state.permute();</span>
<span class="line" id="L238">                self.buf_off = <span class="tok-number">0</span>;</span>
<span class="line" id="L239">            }</span>
<span class="line" id="L240">        }</span>
<span class="line" id="L241">    }</span>
<span class="line" id="L242"></span>
<span class="line" id="L243">    <span class="tok-comment">/// Finish the current hashing operation, writing the hash to `out`</span></span>
<span class="line" id="L244">    <span class="tok-comment">///</span></span>
<span class="line" id="L245">    <span class="tok-comment">/// From 4.9 &quot;Application to hashing&quot;</span></span>
<span class="line" id="L246">    <span class="tok-comment">/// By default, Gimli-Hash provides a fixed-length output of 32 bytes</span></span>
<span class="line" id="L247">    <span class="tok-comment">/// (the concatenation of two 16-byte blocks).  However, Gimli-Hash can</span></span>
<span class="line" id="L248">    <span class="tok-comment">/// be used as an “extendable one-way function” (XOF).</span></span>
<span class="line" id="L249">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">final</span>(self: *Self, out: []<span class="tok-type">u8</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L250">        <span class="tok-kw">const</span> buf = self.state.toSlice();</span>
<span class="line" id="L251"></span>
<span class="line" id="L252">        <span class="tok-comment">// XOR 1 into the next byte of the state</span>
</span>
<span class="line" id="L253">        buf[self.buf_off] ^= <span class="tok-number">1</span>;</span>
<span class="line" id="L254">        <span class="tok-comment">// XOR 1 into the last byte of the state, position 47.</span>
</span>
<span class="line" id="L255">        buf[buf.len - <span class="tok-number">1</span>] ^= <span class="tok-number">1</span>;</span>
<span class="line" id="L256"></span>
<span class="line" id="L257">        self.state.squeeze(out);</span>
<span class="line" id="L258">    }</span>
<span class="line" id="L259"></span>
<span class="line" id="L260">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> Error = <span class="tok-kw">error</span>{};</span>
<span class="line" id="L261">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> Writer = std.io.Writer(*Self, Error, write);</span>
<span class="line" id="L262"></span>
<span class="line" id="L263">    <span class="tok-kw">fn</span> <span class="tok-fn">write</span>(self: *Self, bytes: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) Error!<span class="tok-type">usize</span> {</span>
<span class="line" id="L264">        self.update(bytes);</span>
<span class="line" id="L265">        <span class="tok-kw">return</span> bytes.len;</span>
<span class="line" id="L266">    }</span>
<span class="line" id="L267"></span>
<span class="line" id="L268">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">writer</span>(self: *Self) Writer {</span>
<span class="line" id="L269">        <span class="tok-kw">return</span> .{ .context = self };</span>
<span class="line" id="L270">    }</span>
<span class="line" id="L271">};</span>
<span class="line" id="L272"></span>
<span class="line" id="L273"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">hash</span>(out: []<span class="tok-type">u8</span>, in: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, options: Hash.Options) <span class="tok-type">void</span> {</span>
<span class="line" id="L274">    <span class="tok-kw">var</span> st = Hash.init(options);</span>
<span class="line" id="L275">    st.update(in);</span>
<span class="line" id="L276">    st.final(out);</span>
<span class="line" id="L277">}</span>
<span class="line" id="L278"></span>
<span class="line" id="L279"><span class="tok-kw">test</span> <span class="tok-str">&quot;hash&quot;</span> {</span>
<span class="line" id="L280">    <span class="tok-comment">// a test vector (30) from NIST KAT submission.</span>
</span>
<span class="line" id="L281">    <span class="tok-kw">var</span> msg: [<span class="tok-number">58</span> / <span class="tok-number">2</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L282">    _ = <span class="tok-kw">try</span> std.fmt.hexToBytes(&amp;msg, <span class="tok-str">&quot;000102030405060708090A0B0C0D0E0F101112131415161718191A1B1C&quot;</span>);</span>
<span class="line" id="L283">    <span class="tok-kw">var</span> md: [<span class="tok-number">32</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L284">    hash(&amp;md, &amp;msg, .{});</span>
<span class="line" id="L285">    <span class="tok-kw">try</span> htest.assertEqual(<span class="tok-str">&quot;1C9A03DC6A5DDC5444CFC6F4B154CFF5CF081633B2CEA4D7D0AE7CCFED5AAA44&quot;</span>, &amp;md);</span>
<span class="line" id="L286">}</span>
<span class="line" id="L287"></span>
<span class="line" id="L288"><span class="tok-kw">test</span> <span class="tok-str">&quot;hash test vector 17&quot;</span> {</span>
<span class="line" id="L289">    <span class="tok-kw">var</span> msg: [<span class="tok-number">32</span> / <span class="tok-number">2</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L290">    _ = <span class="tok-kw">try</span> std.fmt.hexToBytes(&amp;msg, <span class="tok-str">&quot;000102030405060708090A0B0C0D0E0F&quot;</span>);</span>
<span class="line" id="L291">    <span class="tok-kw">var</span> md: [<span class="tok-number">32</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L292">    hash(&amp;md, &amp;msg, .{});</span>
<span class="line" id="L293">    <span class="tok-kw">try</span> htest.assertEqual(<span class="tok-str">&quot;404C130AF1B9023A7908200919F690FFBB756D5176E056FFDE320016A37C7282&quot;</span>, &amp;md);</span>
<span class="line" id="L294">}</span>
<span class="line" id="L295"></span>
<span class="line" id="L296"><span class="tok-kw">test</span> <span class="tok-str">&quot;hash test vector 33&quot;</span> {</span>
<span class="line" id="L297">    <span class="tok-kw">var</span> msg: [<span class="tok-number">32</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L298">    _ = <span class="tok-kw">try</span> std.fmt.hexToBytes(&amp;msg, <span class="tok-str">&quot;000102030405060708090A0B0C0D0E0F101112131415161718191A1B1C1D1E1F&quot;</span>);</span>
<span class="line" id="L299">    <span class="tok-kw">var</span> md: [<span class="tok-number">32</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L300">    hash(&amp;md, &amp;msg, .{});</span>
<span class="line" id="L301">    <span class="tok-kw">try</span> htest.assertEqual(<span class="tok-str">&quot;A8F4FA28708BDA7EFB4C1914CA4AFA9E475B82D588D36504F87DBB0ED9AB3C4B&quot;</span>, &amp;md);</span>
<span class="line" id="L302">}</span>
<span class="line" id="L303"></span>
<span class="line" id="L304"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> Aead = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L305">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> tag_length = State.RATE;</span>
<span class="line" id="L306">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> nonce_length = <span class="tok-number">16</span>;</span>
<span class="line" id="L307">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> key_length = <span class="tok-number">32</span>;</span>
<span class="line" id="L308"></span>
<span class="line" id="L309">    <span class="tok-comment">/// ad: Associated Data</span></span>
<span class="line" id="L310">    <span class="tok-comment">/// npub: public nonce</span></span>
<span class="line" id="L311">    <span class="tok-comment">/// k: private key</span></span>
<span class="line" id="L312">    <span class="tok-kw">fn</span> <span class="tok-fn">init</span>(ad: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, npub: [nonce_length]<span class="tok-type">u8</span>, k: [key_length]<span class="tok-type">u8</span>) State {</span>
<span class="line" id="L313">        <span class="tok-kw">var</span> state = State{</span>
<span class="line" id="L314">            .data = <span class="tok-null">undefined</span>,</span>
<span class="line" id="L315">        };</span>
<span class="line" id="L316">        <span class="tok-kw">const</span> buf = state.toSlice();</span>
<span class="line" id="L317"></span>
<span class="line" id="L318">        <span class="tok-comment">// Gimli-Cipher initializes a 48-byte Gimli state to a 16-byte nonce</span>
</span>
<span class="line" id="L319">        <span class="tok-comment">// followed by a 32-byte key.</span>
</span>
<span class="line" id="L320">        assert(npub.len + k.len == State.BLOCKBYTES);</span>
<span class="line" id="L321">        std.mem.copy(<span class="tok-type">u8</span>, buf[<span class="tok-number">0</span>..npub.len], &amp;npub);</span>
<span class="line" id="L322">        std.mem.copy(<span class="tok-type">u8</span>, buf[npub.len .. npub.len + k.len], &amp;k);</span>
<span class="line" id="L323"></span>
<span class="line" id="L324">        <span class="tok-comment">// It then applies the Gimli permutation.</span>
</span>
<span class="line" id="L325">        state.permute();</span>
<span class="line" id="L326"></span>
<span class="line" id="L327">        {</span>
<span class="line" id="L328">            <span class="tok-comment">// Gimli-Cipher then handles each block of associated data, including</span>
</span>
<span class="line" id="L329">            <span class="tok-comment">// exactly one final non-full block, in the same way as Gimli-Hash.</span>
</span>
<span class="line" id="L330">            <span class="tok-kw">var</span> data = ad;</span>
<span class="line" id="L331">            <span class="tok-kw">while</span> (data.len &gt;= State.RATE) : (data = data[State.RATE..]) {</span>
<span class="line" id="L332">                <span class="tok-kw">for</span> (buf[<span class="tok-number">0</span>..State.RATE]) |*p, i| {</span>
<span class="line" id="L333">                    p.* ^= data[i];</span>
<span class="line" id="L334">                }</span>
<span class="line" id="L335">                state.permute();</span>
<span class="line" id="L336">            }</span>
<span class="line" id="L337">            <span class="tok-kw">for</span> (buf[<span class="tok-number">0</span>..data.len]) |*p, i| {</span>
<span class="line" id="L338">                p.* ^= data[i];</span>
<span class="line" id="L339">            }</span>
<span class="line" id="L340"></span>
<span class="line" id="L341">            <span class="tok-comment">// XOR 1 into the next byte of the state</span>
</span>
<span class="line" id="L342">            buf[data.len] ^= <span class="tok-number">1</span>;</span>
<span class="line" id="L343">            <span class="tok-comment">// XOR 1 into the last byte of the state, position 47.</span>
</span>
<span class="line" id="L344">            buf[buf.len - <span class="tok-number">1</span>] ^= <span class="tok-number">1</span>;</span>
<span class="line" id="L345"></span>
<span class="line" id="L346">            state.permute();</span>
<span class="line" id="L347">        }</span>
<span class="line" id="L348"></span>
<span class="line" id="L349">        <span class="tok-kw">return</span> state;</span>
<span class="line" id="L350">    }</span>
<span class="line" id="L351"></span>
<span class="line" id="L352">    <span class="tok-comment">/// c: ciphertext: output buffer should be of size m.len</span></span>
<span class="line" id="L353">    <span class="tok-comment">/// tag: authentication tag: output MAC</span></span>
<span class="line" id="L354">    <span class="tok-comment">/// m: message</span></span>
<span class="line" id="L355">    <span class="tok-comment">/// ad: Associated Data</span></span>
<span class="line" id="L356">    <span class="tok-comment">/// npub: public nonce</span></span>
<span class="line" id="L357">    <span class="tok-comment">/// k: private key</span></span>
<span class="line" id="L358">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">encrypt</span>(c: []<span class="tok-type">u8</span>, tag: *[tag_length]<span class="tok-type">u8</span>, m: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, ad: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, npub: [nonce_length]<span class="tok-type">u8</span>, k: [key_length]<span class="tok-type">u8</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L359">        assert(c.len == m.len);</span>
<span class="line" id="L360"></span>
<span class="line" id="L361">        <span class="tok-kw">var</span> state = Aead.init(ad, npub, k);</span>
<span class="line" id="L362">        <span class="tok-kw">const</span> buf = state.toSlice();</span>
<span class="line" id="L363"></span>
<span class="line" id="L364">        <span class="tok-comment">// Gimli-Cipher then handles each block of plaintext, including</span>
</span>
<span class="line" id="L365">        <span class="tok-comment">// exactly one final non-full block, in the same way as Gimli-Hash.</span>
</span>
<span class="line" id="L366">        <span class="tok-comment">// Whenever a plaintext byte is XORed into a state byte, the new state</span>
</span>
<span class="line" id="L367">        <span class="tok-comment">// byte is output as ciphertext.</span>
</span>
<span class="line" id="L368">        <span class="tok-kw">var</span> in = m;</span>
<span class="line" id="L369">        <span class="tok-kw">var</span> out = c;</span>
<span class="line" id="L370">        <span class="tok-kw">while</span> (in.len &gt;= State.RATE) : ({</span>
<span class="line" id="L371">            in = in[State.RATE..];</span>
<span class="line" id="L372">            out = out[State.RATE..];</span>
<span class="line" id="L373">        }) {</span>
<span class="line" id="L374">            <span class="tok-kw">for</span> (in[<span class="tok-number">0</span>..State.RATE]) |v, i| {</span>
<span class="line" id="L375">                buf[i] ^= v;</span>
<span class="line" id="L376">            }</span>
<span class="line" id="L377">            mem.copy(<span class="tok-type">u8</span>, out[<span class="tok-number">0</span>..State.RATE], buf[<span class="tok-number">0</span>..State.RATE]);</span>
<span class="line" id="L378">            state.permute();</span>
<span class="line" id="L379">        }</span>
<span class="line" id="L380">        <span class="tok-kw">for</span> (in[<span class="tok-number">0</span>..]) |v, i| {</span>
<span class="line" id="L381">            buf[i] ^= v;</span>
<span class="line" id="L382">            out[i] = buf[i];</span>
<span class="line" id="L383">        }</span>
<span class="line" id="L384"></span>
<span class="line" id="L385">        <span class="tok-comment">// XOR 1 into the next byte of the state</span>
</span>
<span class="line" id="L386">        buf[in.len] ^= <span class="tok-number">1</span>;</span>
<span class="line" id="L387">        <span class="tok-comment">// XOR 1 into the last byte of the state, position 47.</span>
</span>
<span class="line" id="L388">        buf[buf.len - <span class="tok-number">1</span>] ^= <span class="tok-number">1</span>;</span>
<span class="line" id="L389"></span>
<span class="line" id="L390">        state.permute();</span>
<span class="line" id="L391"></span>
<span class="line" id="L392">        <span class="tok-comment">// After the final non-full block of plaintext, the first 16 bytes</span>
</span>
<span class="line" id="L393">        <span class="tok-comment">// of the state are output as an authentication tag.</span>
</span>
<span class="line" id="L394">        std.mem.copy(<span class="tok-type">u8</span>, tag, buf[<span class="tok-number">0</span>..State.RATE]);</span>
<span class="line" id="L395">    }</span>
<span class="line" id="L396"></span>
<span class="line" id="L397">    <span class="tok-comment">/// m: message: output buffer should be of size c.len</span></span>
<span class="line" id="L398">    <span class="tok-comment">/// c: ciphertext</span></span>
<span class="line" id="L399">    <span class="tok-comment">/// tag: authentication tag</span></span>
<span class="line" id="L400">    <span class="tok-comment">/// ad: Associated Data</span></span>
<span class="line" id="L401">    <span class="tok-comment">/// npub: public nonce</span></span>
<span class="line" id="L402">    <span class="tok-comment">/// k: private key</span></span>
<span class="line" id="L403">    <span class="tok-comment">/// NOTE: the check of the authentication tag is currently not done in constant time</span></span>
<span class="line" id="L404">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">decrypt</span>(m: []<span class="tok-type">u8</span>, c: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, tag: [tag_length]<span class="tok-type">u8</span>, ad: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, npub: [nonce_length]<span class="tok-type">u8</span>, k: [key_length]<span class="tok-type">u8</span>) AuthenticationError!<span class="tok-type">void</span> {</span>
<span class="line" id="L405">        assert(c.len == m.len);</span>
<span class="line" id="L406"></span>
<span class="line" id="L407">        <span class="tok-kw">var</span> state = Aead.init(ad, npub, k);</span>
<span class="line" id="L408">        <span class="tok-kw">const</span> buf = state.toSlice();</span>
<span class="line" id="L409"></span>
<span class="line" id="L410">        <span class="tok-kw">var</span> in = c;</span>
<span class="line" id="L411">        <span class="tok-kw">var</span> out = m;</span>
<span class="line" id="L412">        <span class="tok-kw">while</span> (in.len &gt;= State.RATE) : ({</span>
<span class="line" id="L413">            in = in[State.RATE..];</span>
<span class="line" id="L414">            out = out[State.RATE..];</span>
<span class="line" id="L415">        }) {</span>
<span class="line" id="L416">            <span class="tok-kw">const</span> d = in[<span class="tok-number">0</span>..State.RATE].*;</span>
<span class="line" id="L417">            <span class="tok-kw">for</span> (d) |v, i| {</span>
<span class="line" id="L418">                out[i] = buf[i] ^ v;</span>
<span class="line" id="L419">            }</span>
<span class="line" id="L420">            mem.copy(<span class="tok-type">u8</span>, buf[<span class="tok-number">0</span>..State.RATE], d[<span class="tok-number">0</span>..State.RATE]);</span>
<span class="line" id="L421">            state.permute();</span>
<span class="line" id="L422">        }</span>
<span class="line" id="L423">        <span class="tok-kw">for</span> (buf[<span class="tok-number">0</span>..in.len]) |*p, i| {</span>
<span class="line" id="L424">            <span class="tok-kw">const</span> d = in[i];</span>
<span class="line" id="L425">            out[i] = p.* ^ d;</span>
<span class="line" id="L426">            p.* = d;</span>
<span class="line" id="L427">        }</span>
<span class="line" id="L428"></span>
<span class="line" id="L429">        <span class="tok-comment">// XOR 1 into the next byte of the state</span>
</span>
<span class="line" id="L430">        buf[in.len] ^= <span class="tok-number">1</span>;</span>
<span class="line" id="L431">        <span class="tok-comment">// XOR 1 into the last byte of the state, position 47.</span>
</span>
<span class="line" id="L432">        buf[buf.len - <span class="tok-number">1</span>] ^= <span class="tok-number">1</span>;</span>
<span class="line" id="L433"></span>
<span class="line" id="L434">        state.permute();</span>
<span class="line" id="L435"></span>
<span class="line" id="L436">        <span class="tok-comment">// After the final non-full block of plaintext, the first 16 bytes</span>
</span>
<span class="line" id="L437">        <span class="tok-comment">// of the state are the authentication tag.</span>
</span>
<span class="line" id="L438">        <span class="tok-comment">// TODO: use a constant-time equality check here, see https://github.com/ziglang/zig/issues/1776</span>
</span>
<span class="line" id="L439">        <span class="tok-kw">if</span> (!mem.eql(<span class="tok-type">u8</span>, buf[<span class="tok-number">0</span>..State.RATE], &amp;tag)) {</span>
<span class="line" id="L440">            <span class="tok-builtin">@memset</span>(m.ptr, <span class="tok-null">undefined</span>, m.len);</span>
<span class="line" id="L441">            <span class="tok-kw">return</span> <span class="tok-kw">error</span>.AuthenticationFailed;</span>
<span class="line" id="L442">        }</span>
<span class="line" id="L443">    }</span>
<span class="line" id="L444">};</span>
<span class="line" id="L445"></span>
<span class="line" id="L446"><span class="tok-kw">test</span> <span class="tok-str">&quot;cipher&quot;</span> {</span>
<span class="line" id="L447">    <span class="tok-kw">var</span> key: [<span class="tok-number">32</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L448">    _ = <span class="tok-kw">try</span> std.fmt.hexToBytes(&amp;key, <span class="tok-str">&quot;000102030405060708090A0B0C0D0E0F101112131415161718191A1B1C1D1E1F&quot;</span>);</span>
<span class="line" id="L449">    <span class="tok-kw">var</span> nonce: [<span class="tok-number">16</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L450">    _ = <span class="tok-kw">try</span> std.fmt.hexToBytes(&amp;nonce, <span class="tok-str">&quot;000102030405060708090A0B0C0D0E0F&quot;</span>);</span>
<span class="line" id="L451">    { <span class="tok-comment">// test vector (1) from NIST KAT submission.</span>
</span>
<span class="line" id="L452">        <span class="tok-kw">const</span> ad: [<span class="tok-number">0</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L453">        <span class="tok-kw">const</span> pt: [<span class="tok-number">0</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L454"></span>
<span class="line" id="L455">        <span class="tok-kw">var</span> ct: [pt.len]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L456">        <span class="tok-kw">var</span> tag: [<span class="tok-number">16</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L457">        Aead.encrypt(&amp;ct, &amp;tag, &amp;pt, &amp;ad, nonce, key);</span>
<span class="line" id="L458">        <span class="tok-kw">try</span> htest.assertEqual(<span class="tok-str">&quot;&quot;</span>, &amp;ct);</span>
<span class="line" id="L459">        <span class="tok-kw">try</span> htest.assertEqual(<span class="tok-str">&quot;14DA9BB7120BF58B985A8E00FDEBA15B&quot;</span>, &amp;tag);</span>
<span class="line" id="L460"></span>
<span class="line" id="L461">        <span class="tok-kw">var</span> pt2: [pt.len]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L462">        <span class="tok-kw">try</span> Aead.decrypt(&amp;pt2, &amp;ct, tag, &amp;ad, nonce, key);</span>
<span class="line" id="L463">        <span class="tok-kw">try</span> testing.expectEqualSlices(<span class="tok-type">u8</span>, &amp;pt, &amp;pt2);</span>
<span class="line" id="L464">    }</span>
<span class="line" id="L465">    { <span class="tok-comment">// test vector (34) from NIST KAT submission.</span>
</span>
<span class="line" id="L466">        <span class="tok-kw">const</span> ad: [<span class="tok-number">0</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L467">        <span class="tok-kw">var</span> pt: [<span class="tok-number">2</span> / <span class="tok-number">2</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L468">        _ = <span class="tok-kw">try</span> std.fmt.hexToBytes(&amp;pt, <span class="tok-str">&quot;00&quot;</span>);</span>
<span class="line" id="L469"></span>
<span class="line" id="L470">        <span class="tok-kw">var</span> ct: [pt.len]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L471">        <span class="tok-kw">var</span> tag: [<span class="tok-number">16</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L472">        Aead.encrypt(&amp;ct, &amp;tag, &amp;pt, &amp;ad, nonce, key);</span>
<span class="line" id="L473">        <span class="tok-kw">try</span> htest.assertEqual(<span class="tok-str">&quot;7F&quot;</span>, &amp;ct);</span>
<span class="line" id="L474">        <span class="tok-kw">try</span> htest.assertEqual(<span class="tok-str">&quot;80492C317B1CD58A1EDC3A0D3E9876FC&quot;</span>, &amp;tag);</span>
<span class="line" id="L475"></span>
<span class="line" id="L476">        <span class="tok-kw">var</span> pt2: [pt.len]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L477">        <span class="tok-kw">try</span> Aead.decrypt(&amp;pt2, &amp;ct, tag, &amp;ad, nonce, key);</span>
<span class="line" id="L478">        <span class="tok-kw">try</span> testing.expectEqualSlices(<span class="tok-type">u8</span>, &amp;pt, &amp;pt2);</span>
<span class="line" id="L479">    }</span>
<span class="line" id="L480">    { <span class="tok-comment">// test vector (106) from NIST KAT submission.</span>
</span>
<span class="line" id="L481">        <span class="tok-kw">var</span> ad: [<span class="tok-number">12</span> / <span class="tok-number">2</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L482">        _ = <span class="tok-kw">try</span> std.fmt.hexToBytes(&amp;ad, <span class="tok-str">&quot;000102030405&quot;</span>);</span>
<span class="line" id="L483">        <span class="tok-kw">var</span> pt: [<span class="tok-number">6</span> / <span class="tok-number">2</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L484">        _ = <span class="tok-kw">try</span> std.fmt.hexToBytes(&amp;pt, <span class="tok-str">&quot;000102&quot;</span>);</span>
<span class="line" id="L485"></span>
<span class="line" id="L486">        <span class="tok-kw">var</span> ct: [pt.len]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L487">        <span class="tok-kw">var</span> tag: [<span class="tok-number">16</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L488">        Aead.encrypt(&amp;ct, &amp;tag, &amp;pt, &amp;ad, nonce, key);</span>
<span class="line" id="L489">        <span class="tok-kw">try</span> htest.assertEqual(<span class="tok-str">&quot;484D35&quot;</span>, &amp;ct);</span>
<span class="line" id="L490">        <span class="tok-kw">try</span> htest.assertEqual(<span class="tok-str">&quot;030BBEA23B61C00CED60A923BDCF9147&quot;</span>, &amp;tag);</span>
<span class="line" id="L491"></span>
<span class="line" id="L492">        <span class="tok-kw">var</span> pt2: [pt.len]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L493">        <span class="tok-kw">try</span> Aead.decrypt(&amp;pt2, &amp;ct, tag, &amp;ad, nonce, key);</span>
<span class="line" id="L494">        <span class="tok-kw">try</span> testing.expectEqualSlices(<span class="tok-type">u8</span>, &amp;pt, &amp;pt2);</span>
<span class="line" id="L495">    }</span>
<span class="line" id="L496">    { <span class="tok-comment">// test vector (790) from NIST KAT submission.</span>
</span>
<span class="line" id="L497">        <span class="tok-kw">var</span> ad: [<span class="tok-number">60</span> / <span class="tok-number">2</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L498">        _ = <span class="tok-kw">try</span> std.fmt.hexToBytes(&amp;ad, <span class="tok-str">&quot;000102030405060708090A0B0C0D0E0F101112131415161718191A1B1C1D&quot;</span>);</span>
<span class="line" id="L499">        <span class="tok-kw">var</span> pt: [<span class="tok-number">46</span> / <span class="tok-number">2</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L500">        _ = <span class="tok-kw">try</span> std.fmt.hexToBytes(&amp;pt, <span class="tok-str">&quot;000102030405060708090A0B0C0D0E0F10111213141516&quot;</span>);</span>
<span class="line" id="L501"></span>
<span class="line" id="L502">        <span class="tok-kw">var</span> ct: [pt.len]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L503">        <span class="tok-kw">var</span> tag: [<span class="tok-number">16</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L504">        Aead.encrypt(&amp;ct, &amp;tag, &amp;pt, &amp;ad, nonce, key);</span>
<span class="line" id="L505">        <span class="tok-kw">try</span> htest.assertEqual(<span class="tok-str">&quot;6815B4A0ECDAD01596EAD87D9E690697475D234C6A13D1&quot;</span>, &amp;ct);</span>
<span class="line" id="L506">        <span class="tok-kw">try</span> htest.assertEqual(<span class="tok-str">&quot;DFE23F1642508290D68245279558B2FB&quot;</span>, &amp;tag);</span>
<span class="line" id="L507"></span>
<span class="line" id="L508">        <span class="tok-kw">var</span> pt2: [pt.len]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L509">        <span class="tok-kw">try</span> Aead.decrypt(&amp;pt2, &amp;ct, tag, &amp;ad, nonce, key);</span>
<span class="line" id="L510">        <span class="tok-kw">try</span> testing.expectEqualSlices(<span class="tok-type">u8</span>, &amp;pt, &amp;pt2);</span>
<span class="line" id="L511">    }</span>
<span class="line" id="L512">    { <span class="tok-comment">// test vector (1057) from NIST KAT submission.</span>
</span>
<span class="line" id="L513">        <span class="tok-kw">const</span> ad: [<span class="tok-number">0</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L514">        <span class="tok-kw">var</span> pt: [<span class="tok-number">64</span> / <span class="tok-number">2</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L515">        _ = <span class="tok-kw">try</span> std.fmt.hexToBytes(&amp;pt, <span class="tok-str">&quot;000102030405060708090A0B0C0D0E0F101112131415161718191A1B1C1D1E1F&quot;</span>);</span>
<span class="line" id="L516"></span>
<span class="line" id="L517">        <span class="tok-kw">var</span> ct: [pt.len]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L518">        <span class="tok-kw">var</span> tag: [<span class="tok-number">16</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L519">        Aead.encrypt(&amp;ct, &amp;tag, &amp;pt, &amp;ad, nonce, key);</span>
<span class="line" id="L520">        <span class="tok-kw">try</span> htest.assertEqual(<span class="tok-str">&quot;7F8A2CF4F52AA4D6B2E74105C30A2777B9D0C8AEFDD555DE35861BD3011F652F&quot;</span>, &amp;ct);</span>
<span class="line" id="L521">        <span class="tok-kw">try</span> htest.assertEqual(<span class="tok-str">&quot;7256456FA935AC34BBF55AE135F33257&quot;</span>, &amp;tag);</span>
<span class="line" id="L522"></span>
<span class="line" id="L523">        <span class="tok-kw">var</span> pt2: [pt.len]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L524">        <span class="tok-kw">try</span> Aead.decrypt(&amp;pt2, &amp;ct, tag, &amp;ad, nonce, key);</span>
<span class="line" id="L525">        <span class="tok-kw">try</span> testing.expectEqualSlices(<span class="tok-type">u8</span>, &amp;pt, &amp;pt2);</span>
<span class="line" id="L526">    }</span>
<span class="line" id="L527">}</span>
<span class="line" id="L528"></span>
</code></pre></body>
</html>