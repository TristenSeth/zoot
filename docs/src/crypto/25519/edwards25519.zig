<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">    <title>crypto/25519/edwards25519.zig - source view</title>
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
<span class="line" id="L2"><span class="tok-kw">const</span> crypto = std.crypto;</span>
<span class="line" id="L3"><span class="tok-kw">const</span> debug = std.debug;</span>
<span class="line" id="L4"><span class="tok-kw">const</span> fmt = std.fmt;</span>
<span class="line" id="L5"><span class="tok-kw">const</span> mem = std.mem;</span>
<span class="line" id="L6"></span>
<span class="line" id="L7"><span class="tok-kw">const</span> EncodingError = crypto.errors.EncodingError;</span>
<span class="line" id="L8"><span class="tok-kw">const</span> IdentityElementError = crypto.errors.IdentityElementError;</span>
<span class="line" id="L9"><span class="tok-kw">const</span> NonCanonicalError = crypto.errors.NonCanonicalError;</span>
<span class="line" id="L10"><span class="tok-kw">const</span> NotSquareError = crypto.errors.NotSquareError;</span>
<span class="line" id="L11"><span class="tok-kw">const</span> WeakPublicKeyError = crypto.errors.WeakPublicKeyError;</span>
<span class="line" id="L12"></span>
<span class="line" id="L13"><span class="tok-comment">/// Group operations over Edwards25519.</span></span>
<span class="line" id="L14"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> Edwards25519 = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L15">    <span class="tok-comment">/// The underlying prime field.</span></span>
<span class="line" id="L16">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> Fe = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;field.zig&quot;</span>).Fe;</span>
<span class="line" id="L17">    <span class="tok-comment">/// Field arithmetic mod the order of the main subgroup.</span></span>
<span class="line" id="L18">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> scalar = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;scalar.zig&quot;</span>);</span>
<span class="line" id="L19">    <span class="tok-comment">/// Length in bytes of a compressed representation of a point.</span></span>
<span class="line" id="L20">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> encoded_length: <span class="tok-type">usize</span> = <span class="tok-number">32</span>;</span>
<span class="line" id="L21"></span>
<span class="line" id="L22">    x: Fe,</span>
<span class="line" id="L23">    y: Fe,</span>
<span class="line" id="L24">    z: Fe,</span>
<span class="line" id="L25">    t: Fe,</span>
<span class="line" id="L26"></span>
<span class="line" id="L27">    is_base: <span class="tok-type">bool</span> = <span class="tok-null">false</span>,</span>
<span class="line" id="L28"></span>
<span class="line" id="L29">    <span class="tok-comment">/// Decode an Edwards25519 point from its compressed (Y+sign) coordinates.</span></span>
<span class="line" id="L30">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">fromBytes</span>(s: [encoded_length]<span class="tok-type">u8</span>) EncodingError!Edwards25519 {</span>
<span class="line" id="L31">        <span class="tok-kw">const</span> z = Fe.one;</span>
<span class="line" id="L32">        <span class="tok-kw">const</span> y = Fe.fromBytes(s);</span>
<span class="line" id="L33">        <span class="tok-kw">var</span> u = y.sq();</span>
<span class="line" id="L34">        <span class="tok-kw">var</span> v = u.mul(Fe.edwards25519d);</span>
<span class="line" id="L35">        u = u.sub(z);</span>
<span class="line" id="L36">        v = v.add(z);</span>
<span class="line" id="L37">        <span class="tok-kw">var</span> x = u.mul(v).pow2523().mul(u);</span>
<span class="line" id="L38">        <span class="tok-kw">const</span> vxx = x.sq().mul(v);</span>
<span class="line" id="L39">        <span class="tok-kw">const</span> has_m_root = vxx.sub(u).isZero();</span>
<span class="line" id="L40">        <span class="tok-kw">const</span> has_p_root = vxx.add(u).isZero();</span>
<span class="line" id="L41">        <span class="tok-kw">if</span> ((<span class="tok-builtin">@boolToInt</span>(has_m_root) | <span class="tok-builtin">@boolToInt</span>(has_p_root)) == <span class="tok-number">0</span>) { <span class="tok-comment">// best-effort to avoid two conditional branches</span>
</span>
<span class="line" id="L42">            <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InvalidEncoding;</span>
<span class="line" id="L43">        }</span>
<span class="line" id="L44">        x.cMov(x.mul(Fe.sqrtm1), <span class="tok-number">1</span> - <span class="tok-builtin">@boolToInt</span>(has_m_root));</span>
<span class="line" id="L45">        x.cMov(x.neg(), <span class="tok-builtin">@boolToInt</span>(x.isNegative()) ^ (s[<span class="tok-number">31</span>] &gt;&gt; <span class="tok-number">7</span>));</span>
<span class="line" id="L46">        <span class="tok-kw">const</span> t = x.mul(y);</span>
<span class="line" id="L47">        <span class="tok-kw">return</span> Edwards25519{ .x = x, .y = y, .z = z, .t = t };</span>
<span class="line" id="L48">    }</span>
<span class="line" id="L49"></span>
<span class="line" id="L50">    <span class="tok-comment">/// Encode an Edwards25519 point.</span></span>
<span class="line" id="L51">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">toBytes</span>(p: Edwards25519) [encoded_length]<span class="tok-type">u8</span> {</span>
<span class="line" id="L52">        <span class="tok-kw">const</span> zi = p.z.invert();</span>
<span class="line" id="L53">        <span class="tok-kw">var</span> s = p.y.mul(zi).toBytes();</span>
<span class="line" id="L54">        s[<span class="tok-number">31</span>] ^= <span class="tok-builtin">@as</span>(<span class="tok-type">u8</span>, <span class="tok-builtin">@boolToInt</span>(p.x.mul(zi).isNegative())) &lt;&lt; <span class="tok-number">7</span>;</span>
<span class="line" id="L55">        <span class="tok-kw">return</span> s;</span>
<span class="line" id="L56">    }</span>
<span class="line" id="L57"></span>
<span class="line" id="L58">    <span class="tok-comment">/// Check that the encoding of a point is canonical.</span></span>
<span class="line" id="L59">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">rejectNonCanonical</span>(s: [<span class="tok-number">32</span>]<span class="tok-type">u8</span>) NonCanonicalError!<span class="tok-type">void</span> {</span>
<span class="line" id="L60">        <span class="tok-kw">return</span> Fe.rejectNonCanonical(s, <span class="tok-null">true</span>);</span>
<span class="line" id="L61">    }</span>
<span class="line" id="L62"></span>
<span class="line" id="L63">    <span class="tok-comment">/// The edwards25519 base point.</span></span>
<span class="line" id="L64">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> basePoint = Edwards25519{</span>
<span class="line" id="L65">        .x = Fe{ .limbs = .{ <span class="tok-number">1738742601995546</span>, <span class="tok-number">1146398526822698</span>, <span class="tok-number">2070867633025821</span>, <span class="tok-number">562264141797630</span>, <span class="tok-number">587772402128613</span> } },</span>
<span class="line" id="L66">        .y = Fe{ .limbs = .{ <span class="tok-number">1801439850948184</span>, <span class="tok-number">1351079888211148</span>, <span class="tok-number">450359962737049</span>, <span class="tok-number">900719925474099</span>, <span class="tok-number">1801439850948198</span> } },</span>
<span class="line" id="L67">        .z = Fe.one,</span>
<span class="line" id="L68">        .t = Fe{ .limbs = .{ <span class="tok-number">1841354044333475</span>, <span class="tok-number">16398895984059</span>, <span class="tok-number">755974180946558</span>, <span class="tok-number">900171276175154</span>, <span class="tok-number">1821297809914039</span> } },</span>
<span class="line" id="L69">        .is_base = <span class="tok-null">true</span>,</span>
<span class="line" id="L70">    };</span>
<span class="line" id="L71"></span>
<span class="line" id="L72">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> neutralElement = <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;deprecated: use identityElement instead&quot;</span>);</span>
<span class="line" id="L73">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> identityElement = Edwards25519{ .x = Fe.zero, .y = Fe.one, .z = Fe.one, .t = Fe.zero };</span>
<span class="line" id="L74"></span>
<span class="line" id="L75">    <span class="tok-comment">/// Reject the neutral element.</span></span>
<span class="line" id="L76">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">rejectIdentity</span>(p: Edwards25519) IdentityElementError!<span class="tok-type">void</span> {</span>
<span class="line" id="L77">        <span class="tok-kw">if</span> (p.x.isZero()) {</span>
<span class="line" id="L78">            <span class="tok-kw">return</span> <span class="tok-kw">error</span>.IdentityElement;</span>
<span class="line" id="L79">        }</span>
<span class="line" id="L80">    }</span>
<span class="line" id="L81"></span>
<span class="line" id="L82">    <span class="tok-comment">/// Multiply a point by the cofactor</span></span>
<span class="line" id="L83">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">clearCofactor</span>(p: Edwards25519) Edwards25519 {</span>
<span class="line" id="L84">        <span class="tok-kw">return</span> p.dbl().dbl().dbl();</span>
<span class="line" id="L85">    }</span>
<span class="line" id="L86"></span>
<span class="line" id="L87">    <span class="tok-comment">/// Flip the sign of the X coordinate.</span></span>
<span class="line" id="L88">    <span class="tok-kw">pub</span> <span class="tok-kw">inline</span> <span class="tok-kw">fn</span> <span class="tok-fn">neg</span>(p: Edwards25519) Edwards25519 {</span>
<span class="line" id="L89">        <span class="tok-kw">return</span> .{ .x = p.x.neg(), .y = p.y, .z = p.z, .t = p.t.neg() };</span>
<span class="line" id="L90">    }</span>
<span class="line" id="L91"></span>
<span class="line" id="L92">    <span class="tok-comment">/// Double an Edwards25519 point.</span></span>
<span class="line" id="L93">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">dbl</span>(p: Edwards25519) Edwards25519 {</span>
<span class="line" id="L94">        <span class="tok-kw">const</span> t0 = p.x.add(p.y).sq();</span>
<span class="line" id="L95">        <span class="tok-kw">var</span> x = p.x.sq();</span>
<span class="line" id="L96">        <span class="tok-kw">var</span> z = p.y.sq();</span>
<span class="line" id="L97">        <span class="tok-kw">const</span> y = z.add(x);</span>
<span class="line" id="L98">        z = z.sub(x);</span>
<span class="line" id="L99">        x = t0.sub(y);</span>
<span class="line" id="L100">        <span class="tok-kw">const</span> t = p.z.sq2().sub(z);</span>
<span class="line" id="L101">        <span class="tok-kw">return</span> .{</span>
<span class="line" id="L102">            .x = x.mul(t),</span>
<span class="line" id="L103">            .y = y.mul(z),</span>
<span class="line" id="L104">            .z = z.mul(t),</span>
<span class="line" id="L105">            .t = x.mul(y),</span>
<span class="line" id="L106">        };</span>
<span class="line" id="L107">    }</span>
<span class="line" id="L108"></span>
<span class="line" id="L109">    <span class="tok-comment">/// Add two Edwards25519 points.</span></span>
<span class="line" id="L110">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">add</span>(p: Edwards25519, q: Edwards25519) Edwards25519 {</span>
<span class="line" id="L111">        <span class="tok-kw">const</span> a = p.y.sub(p.x).mul(q.y.sub(q.x));</span>
<span class="line" id="L112">        <span class="tok-kw">const</span> b = p.x.add(p.y).mul(q.x.add(q.y));</span>
<span class="line" id="L113">        <span class="tok-kw">const</span> c = p.t.mul(q.t).mul(Fe.edwards25519d2);</span>
<span class="line" id="L114">        <span class="tok-kw">var</span> d = p.z.mul(q.z);</span>
<span class="line" id="L115">        d = d.add(d);</span>
<span class="line" id="L116">        <span class="tok-kw">const</span> x = b.sub(a);</span>
<span class="line" id="L117">        <span class="tok-kw">const</span> y = b.add(a);</span>
<span class="line" id="L118">        <span class="tok-kw">const</span> z = d.add(c);</span>
<span class="line" id="L119">        <span class="tok-kw">const</span> t = d.sub(c);</span>
<span class="line" id="L120">        <span class="tok-kw">return</span> .{</span>
<span class="line" id="L121">            .x = x.mul(t),</span>
<span class="line" id="L122">            .y = y.mul(z),</span>
<span class="line" id="L123">            .z = z.mul(t),</span>
<span class="line" id="L124">            .t = x.mul(y),</span>
<span class="line" id="L125">        };</span>
<span class="line" id="L126">    }</span>
<span class="line" id="L127"></span>
<span class="line" id="L128">    <span class="tok-comment">/// Substract two Edwards25519 points.</span></span>
<span class="line" id="L129">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">sub</span>(p: Edwards25519, q: Edwards25519) Edwards25519 {</span>
<span class="line" id="L130">        <span class="tok-kw">return</span> p.add(q.neg());</span>
<span class="line" id="L131">    }</span>
<span class="line" id="L132"></span>
<span class="line" id="L133">    <span class="tok-kw">inline</span> <span class="tok-kw">fn</span> <span class="tok-fn">cMov</span>(p: *Edwards25519, a: Edwards25519, c: <span class="tok-type">u64</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L134">        p.x.cMov(a.x, c);</span>
<span class="line" id="L135">        p.y.cMov(a.y, c);</span>
<span class="line" id="L136">        p.z.cMov(a.z, c);</span>
<span class="line" id="L137">        p.t.cMov(a.t, c);</span>
<span class="line" id="L138">    }</span>
<span class="line" id="L139"></span>
<span class="line" id="L140">    <span class="tok-kw">inline</span> <span class="tok-kw">fn</span> <span class="tok-fn">pcSelect</span>(<span class="tok-kw">comptime</span> n: <span class="tok-type">usize</span>, pc: *<span class="tok-kw">const</span> [n]Edwards25519, b: <span class="tok-type">u8</span>) Edwards25519 {</span>
<span class="line" id="L141">        <span class="tok-kw">var</span> t = Edwards25519.identityElement;</span>
<span class="line" id="L142">        <span class="tok-kw">comptime</span> <span class="tok-kw">var</span> i: <span class="tok-type">u8</span> = <span class="tok-number">1</span>;</span>
<span class="line" id="L143">        <span class="tok-kw">inline</span> <span class="tok-kw">while</span> (i &lt; pc.len) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L144">            t.cMov(pc[i], ((<span class="tok-builtin">@as</span>(<span class="tok-type">usize</span>, b ^ i) -% <span class="tok-number">1</span>) &gt;&gt; <span class="tok-number">8</span>) &amp; <span class="tok-number">1</span>);</span>
<span class="line" id="L145">        }</span>
<span class="line" id="L146">        <span class="tok-kw">return</span> t;</span>
<span class="line" id="L147">    }</span>
<span class="line" id="L148"></span>
<span class="line" id="L149">    <span class="tok-kw">fn</span> <span class="tok-fn">slide</span>(s: [<span class="tok-number">32</span>]<span class="tok-type">u8</span>) [<span class="tok-number">2</span> * <span class="tok-number">32</span>]<span class="tok-type">i8</span> {</span>
<span class="line" id="L150">        <span class="tok-kw">const</span> reduced = <span class="tok-kw">if</span> ((s[s.len - <span class="tok-number">1</span>] &amp; <span class="tok-number">0x80</span>) == <span class="tok-number">0</span>) s <span class="tok-kw">else</span> scalar.reduce(s);</span>
<span class="line" id="L151">        <span class="tok-kw">var</span> e: [<span class="tok-number">2</span> * <span class="tok-number">32</span>]<span class="tok-type">i8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L152">        <span class="tok-kw">for</span> (reduced) |x, i| {</span>
<span class="line" id="L153">            e[i * <span class="tok-number">2</span> + <span class="tok-number">0</span>] = <span class="tok-builtin">@as</span>(<span class="tok-type">i8</span>, <span class="tok-builtin">@truncate</span>(<span class="tok-type">u4</span>, x));</span>
<span class="line" id="L154">            e[i * <span class="tok-number">2</span> + <span class="tok-number">1</span>] = <span class="tok-builtin">@as</span>(<span class="tok-type">i8</span>, <span class="tok-builtin">@truncate</span>(<span class="tok-type">u4</span>, x &gt;&gt; <span class="tok-number">4</span>));</span>
<span class="line" id="L155">        }</span>
<span class="line" id="L156">        <span class="tok-comment">// Now, e[0..63] is between 0 and 15, e[63] is between 0 and 7</span>
</span>
<span class="line" id="L157">        <span class="tok-kw">var</span> carry: <span class="tok-type">i8</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L158">        <span class="tok-kw">for</span> (e[<span class="tok-number">0</span>..<span class="tok-number">63</span>]) |*x| {</span>
<span class="line" id="L159">            x.* += carry;</span>
<span class="line" id="L160">            carry = (x.* + <span class="tok-number">8</span>) &gt;&gt; <span class="tok-number">4</span>;</span>
<span class="line" id="L161">            x.* -= carry * <span class="tok-number">16</span>;</span>
<span class="line" id="L162">        }</span>
<span class="line" id="L163">        e[<span class="tok-number">63</span>] += carry;</span>
<span class="line" id="L164">        <span class="tok-comment">// Now, e[*] is between -8 and 8, including e[63]</span>
</span>
<span class="line" id="L165">        <span class="tok-kw">return</span> e;</span>
<span class="line" id="L166">    }</span>
<span class="line" id="L167"></span>
<span class="line" id="L168">    <span class="tok-comment">// Scalar multiplication with a 4-bit window and the first 8 multiples.</span>
</span>
<span class="line" id="L169">    <span class="tok-comment">// This requires the scalar to be converted to non-adjacent form.</span>
</span>
<span class="line" id="L170">    <span class="tok-comment">// Based on real-world benchmarks, we only use this for multi-scalar multiplication.</span>
</span>
<span class="line" id="L171">    <span class="tok-comment">// NAF could be useful to half the size of precomputation tables, but we intentionally</span>
</span>
<span class="line" id="L172">    <span class="tok-comment">// avoid these to keep the standard library lightweight.</span>
</span>
<span class="line" id="L173">    <span class="tok-kw">fn</span> <span class="tok-fn">pcMul</span>(pc: *<span class="tok-kw">const</span> [<span class="tok-number">9</span>]Edwards25519, s: [<span class="tok-number">32</span>]<span class="tok-type">u8</span>, <span class="tok-kw">comptime</span> vartime: <span class="tok-type">bool</span>) IdentityElementError!Edwards25519 {</span>
<span class="line" id="L174">        std.debug.assert(vartime);</span>
<span class="line" id="L175">        <span class="tok-kw">const</span> e = slide(s);</span>
<span class="line" id="L176">        <span class="tok-kw">var</span> q = Edwards25519.identityElement;</span>
<span class="line" id="L177">        <span class="tok-kw">var</span> pos: <span class="tok-type">usize</span> = <span class="tok-number">2</span> * <span class="tok-number">32</span> - <span class="tok-number">1</span>;</span>
<span class="line" id="L178">        <span class="tok-kw">while</span> (<span class="tok-null">true</span>) : (pos -= <span class="tok-number">1</span>) {</span>
<span class="line" id="L179">            <span class="tok-kw">const</span> slot = e[pos];</span>
<span class="line" id="L180">            <span class="tok-kw">if</span> (slot &gt; <span class="tok-number">0</span>) {</span>
<span class="line" id="L181">                q = q.add(pc[<span class="tok-builtin">@intCast</span>(<span class="tok-type">usize</span>, slot)]);</span>
<span class="line" id="L182">            } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (slot &lt; <span class="tok-number">0</span>) {</span>
<span class="line" id="L183">                q = q.sub(pc[<span class="tok-builtin">@intCast</span>(<span class="tok-type">usize</span>, -slot)]);</span>
<span class="line" id="L184">            }</span>
<span class="line" id="L185">            <span class="tok-kw">if</span> (pos == <span class="tok-number">0</span>) <span class="tok-kw">break</span>;</span>
<span class="line" id="L186">            q = q.dbl().dbl().dbl().dbl();</span>
<span class="line" id="L187">        }</span>
<span class="line" id="L188">        <span class="tok-kw">try</span> q.rejectIdentity();</span>
<span class="line" id="L189">        <span class="tok-kw">return</span> q;</span>
<span class="line" id="L190">    }</span>
<span class="line" id="L191"></span>
<span class="line" id="L192">    <span class="tok-comment">// Scalar multiplication with a 4-bit window and the first 15 multiples.</span>
</span>
<span class="line" id="L193">    <span class="tok-kw">fn</span> <span class="tok-fn">pcMul16</span>(pc: *<span class="tok-kw">const</span> [<span class="tok-number">16</span>]Edwards25519, s: [<span class="tok-number">32</span>]<span class="tok-type">u8</span>, <span class="tok-kw">comptime</span> vartime: <span class="tok-type">bool</span>) IdentityElementError!Edwards25519 {</span>
<span class="line" id="L194">        <span class="tok-kw">var</span> q = Edwards25519.identityElement;</span>
<span class="line" id="L195">        <span class="tok-kw">var</span> pos: <span class="tok-type">usize</span> = <span class="tok-number">252</span>;</span>
<span class="line" id="L196">        <span class="tok-kw">while</span> (<span class="tok-null">true</span>) : (pos -= <span class="tok-number">4</span>) {</span>
<span class="line" id="L197">            <span class="tok-kw">const</span> slot = <span class="tok-builtin">@truncate</span>(<span class="tok-type">u4</span>, (s[pos &gt;&gt; <span class="tok-number">3</span>] &gt;&gt; <span class="tok-builtin">@truncate</span>(<span class="tok-type">u3</span>, pos)));</span>
<span class="line" id="L198">            <span class="tok-kw">if</span> (vartime) {</span>
<span class="line" id="L199">                <span class="tok-kw">if</span> (slot != <span class="tok-number">0</span>) {</span>
<span class="line" id="L200">                    q = q.add(pc[slot]);</span>
<span class="line" id="L201">                }</span>
<span class="line" id="L202">            } <span class="tok-kw">else</span> {</span>
<span class="line" id="L203">                q = q.add(pcSelect(<span class="tok-number">16</span>, pc, slot));</span>
<span class="line" id="L204">            }</span>
<span class="line" id="L205">            <span class="tok-kw">if</span> (pos == <span class="tok-number">0</span>) <span class="tok-kw">break</span>;</span>
<span class="line" id="L206">            q = q.dbl().dbl().dbl().dbl();</span>
<span class="line" id="L207">        }</span>
<span class="line" id="L208">        <span class="tok-kw">try</span> q.rejectIdentity();</span>
<span class="line" id="L209">        <span class="tok-kw">return</span> q;</span>
<span class="line" id="L210">    }</span>
<span class="line" id="L211"></span>
<span class="line" id="L212">    <span class="tok-kw">fn</span> <span class="tok-fn">precompute</span>(p: Edwards25519, <span class="tok-kw">comptime</span> count: <span class="tok-type">usize</span>) [<span class="tok-number">1</span> + count]Edwards25519 {</span>
<span class="line" id="L213">        <span class="tok-kw">var</span> pc: [<span class="tok-number">1</span> + count]Edwards25519 = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L214">        pc[<span class="tok-number">0</span>] = Edwards25519.identityElement;</span>
<span class="line" id="L215">        pc[<span class="tok-number">1</span>] = p;</span>
<span class="line" id="L216">        <span class="tok-kw">var</span> i: <span class="tok-type">usize</span> = <span class="tok-number">2</span>;</span>
<span class="line" id="L217">        <span class="tok-kw">while</span> (i &lt;= count) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L218">            pc[i] = <span class="tok-kw">if</span> (i % <span class="tok-number">2</span> == <span class="tok-number">0</span>) pc[i / <span class="tok-number">2</span>].dbl() <span class="tok-kw">else</span> pc[i - <span class="tok-number">1</span>].add(p);</span>
<span class="line" id="L219">        }</span>
<span class="line" id="L220">        <span class="tok-kw">return</span> pc;</span>
<span class="line" id="L221">    }</span>
<span class="line" id="L222"></span>
<span class="line" id="L223">    <span class="tok-kw">const</span> basePointPc = pc: {</span>
<span class="line" id="L224">        <span class="tok-builtin">@setEvalBranchQuota</span>(<span class="tok-number">10000</span>);</span>
<span class="line" id="L225">        <span class="tok-kw">break</span> :pc precompute(Edwards25519.basePoint, <span class="tok-number">15</span>);</span>
<span class="line" id="L226">    };</span>
<span class="line" id="L227"></span>
<span class="line" id="L228">    <span class="tok-comment">/// Multiply an Edwards25519 point by a scalar without clamping it.</span></span>
<span class="line" id="L229">    <span class="tok-comment">/// Return error.WeakPublicKey if the base generates a small-order group,</span></span>
<span class="line" id="L230">    <span class="tok-comment">/// and error.IdentityElement if the result is the identity element.</span></span>
<span class="line" id="L231">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">mul</span>(p: Edwards25519, s: [<span class="tok-number">32</span>]<span class="tok-type">u8</span>) (IdentityElementError || WeakPublicKeyError)!Edwards25519 {</span>
<span class="line" id="L232">        <span class="tok-kw">const</span> pc = <span class="tok-kw">if</span> (p.is_base) basePointPc <span class="tok-kw">else</span> pc: {</span>
<span class="line" id="L233">            <span class="tok-kw">const</span> xpc = precompute(p, <span class="tok-number">15</span>);</span>
<span class="line" id="L234">            xpc[<span class="tok-number">4</span>].rejectIdentity() <span class="tok-kw">catch</span> <span class="tok-kw">return</span> <span class="tok-kw">error</span>.WeakPublicKey;</span>
<span class="line" id="L235">            <span class="tok-kw">break</span> :pc xpc;</span>
<span class="line" id="L236">        };</span>
<span class="line" id="L237">        <span class="tok-kw">return</span> pcMul16(&amp;pc, s, <span class="tok-null">false</span>);</span>
<span class="line" id="L238">    }</span>
<span class="line" id="L239"></span>
<span class="line" id="L240">    <span class="tok-comment">/// Multiply an Edwards25519 point by a *PUBLIC* scalar *IN VARIABLE TIME*</span></span>
<span class="line" id="L241">    <span class="tok-comment">/// This can be used for signature verification.</span></span>
<span class="line" id="L242">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">mulPublic</span>(p: Edwards25519, s: [<span class="tok-number">32</span>]<span class="tok-type">u8</span>) (IdentityElementError || WeakPublicKeyError)!Edwards25519 {</span>
<span class="line" id="L243">        <span class="tok-kw">if</span> (p.is_base) {</span>
<span class="line" id="L244">            <span class="tok-kw">return</span> pcMul16(&amp;basePointPc, s, <span class="tok-null">true</span>);</span>
<span class="line" id="L245">        } <span class="tok-kw">else</span> {</span>
<span class="line" id="L246">            <span class="tok-kw">const</span> pc = precompute(p, <span class="tok-number">8</span>);</span>
<span class="line" id="L247">            pc[<span class="tok-number">4</span>].rejectIdentity() <span class="tok-kw">catch</span> <span class="tok-kw">return</span> <span class="tok-kw">error</span>.WeakPublicKey;</span>
<span class="line" id="L248">            <span class="tok-kw">return</span> pcMul(&amp;pc, s, <span class="tok-null">true</span>);</span>
<span class="line" id="L249">        }</span>
<span class="line" id="L250">    }</span>
<span class="line" id="L251"></span>
<span class="line" id="L252">    <span class="tok-comment">/// Double-base multiplication of public parameters - Compute (p1*s1)+(p2*s2) *IN VARIABLE TIME*</span></span>
<span class="line" id="L253">    <span class="tok-comment">/// This can be used for signature verification.</span></span>
<span class="line" id="L254">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">mulDoubleBasePublic</span>(p1: Edwards25519, s1: [<span class="tok-number">32</span>]<span class="tok-type">u8</span>, p2: Edwards25519, s2: [<span class="tok-number">32</span>]<span class="tok-type">u8</span>) (IdentityElementError || WeakPublicKeyError)!Edwards25519 {</span>
<span class="line" id="L255">        <span class="tok-kw">var</span> pc1_array: [<span class="tok-number">9</span>]Edwards25519 = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L256">        <span class="tok-kw">const</span> pc1 = <span class="tok-kw">if</span> (p1.is_base) basePointPc[<span class="tok-number">0</span>..<span class="tok-number">9</span>] <span class="tok-kw">else</span> pc: {</span>
<span class="line" id="L257">            pc1_array = precompute(p1, <span class="tok-number">8</span>);</span>
<span class="line" id="L258">            pc1_array[<span class="tok-number">4</span>].rejectIdentity() <span class="tok-kw">catch</span> <span class="tok-kw">return</span> <span class="tok-kw">error</span>.WeakPublicKey;</span>
<span class="line" id="L259">            <span class="tok-kw">break</span> :pc &amp;pc1_array;</span>
<span class="line" id="L260">        };</span>
<span class="line" id="L261">        <span class="tok-kw">var</span> pc2_array: [<span class="tok-number">9</span>]Edwards25519 = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L262">        <span class="tok-kw">const</span> pc2 = <span class="tok-kw">if</span> (p2.is_base) basePointPc[<span class="tok-number">0</span>..<span class="tok-number">9</span>] <span class="tok-kw">else</span> pc: {</span>
<span class="line" id="L263">            pc2_array = precompute(p2, <span class="tok-number">8</span>);</span>
<span class="line" id="L264">            pc2_array[<span class="tok-number">4</span>].rejectIdentity() <span class="tok-kw">catch</span> <span class="tok-kw">return</span> <span class="tok-kw">error</span>.WeakPublicKey;</span>
<span class="line" id="L265">            <span class="tok-kw">break</span> :pc &amp;pc2_array;</span>
<span class="line" id="L266">        };</span>
<span class="line" id="L267">        <span class="tok-kw">const</span> e1 = slide(s1);</span>
<span class="line" id="L268">        <span class="tok-kw">const</span> e2 = slide(s2);</span>
<span class="line" id="L269">        <span class="tok-kw">var</span> q = Edwards25519.identityElement;</span>
<span class="line" id="L270">        <span class="tok-kw">var</span> pos: <span class="tok-type">usize</span> = <span class="tok-number">2</span> * <span class="tok-number">32</span> - <span class="tok-number">1</span>;</span>
<span class="line" id="L271">        <span class="tok-kw">while</span> (<span class="tok-null">true</span>) : (pos -= <span class="tok-number">1</span>) {</span>
<span class="line" id="L272">            <span class="tok-kw">const</span> slot1 = e1[pos];</span>
<span class="line" id="L273">            <span class="tok-kw">if</span> (slot1 &gt; <span class="tok-number">0</span>) {</span>
<span class="line" id="L274">                q = q.add(pc1[<span class="tok-builtin">@intCast</span>(<span class="tok-type">usize</span>, slot1)]);</span>
<span class="line" id="L275">            } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (slot1 &lt; <span class="tok-number">0</span>) {</span>
<span class="line" id="L276">                q = q.sub(pc1[<span class="tok-builtin">@intCast</span>(<span class="tok-type">usize</span>, -slot1)]);</span>
<span class="line" id="L277">            }</span>
<span class="line" id="L278">            <span class="tok-kw">const</span> slot2 = e2[pos];</span>
<span class="line" id="L279">            <span class="tok-kw">if</span> (slot2 &gt; <span class="tok-number">0</span>) {</span>
<span class="line" id="L280">                q = q.add(pc2[<span class="tok-builtin">@intCast</span>(<span class="tok-type">usize</span>, slot2)]);</span>
<span class="line" id="L281">            } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (slot2 &lt; <span class="tok-number">0</span>) {</span>
<span class="line" id="L282">                q = q.sub(pc2[<span class="tok-builtin">@intCast</span>(<span class="tok-type">usize</span>, -slot2)]);</span>
<span class="line" id="L283">            }</span>
<span class="line" id="L284">            <span class="tok-kw">if</span> (pos == <span class="tok-number">0</span>) <span class="tok-kw">break</span>;</span>
<span class="line" id="L285">            q = q.dbl().dbl().dbl().dbl();</span>
<span class="line" id="L286">        }</span>
<span class="line" id="L287">        <span class="tok-kw">try</span> q.rejectIdentity();</span>
<span class="line" id="L288">        <span class="tok-kw">return</span> q;</span>
<span class="line" id="L289">    }</span>
<span class="line" id="L290"></span>
<span class="line" id="L291">    <span class="tok-comment">/// Multiscalar multiplication *IN VARIABLE TIME* for public data</span></span>
<span class="line" id="L292">    <span class="tok-comment">/// Computes ps0*ss0 + ps1*ss1 + ps2*ss2... faster than doing many of these operations individually</span></span>
<span class="line" id="L293">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">mulMulti</span>(<span class="tok-kw">comptime</span> count: <span class="tok-type">usize</span>, ps: [count]Edwards25519, ss: [count][<span class="tok-number">32</span>]<span class="tok-type">u8</span>) (IdentityElementError || WeakPublicKeyError)!Edwards25519 {</span>
<span class="line" id="L294">        <span class="tok-kw">var</span> pcs: [count][<span class="tok-number">9</span>]Edwards25519 = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L295"></span>
<span class="line" id="L296">        <span class="tok-kw">var</span> bpc: [<span class="tok-number">9</span>]Edwards25519 = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L297">        mem.copy(Edwards25519, bpc[<span class="tok-number">0</span>..], basePointPc[<span class="tok-number">0</span>..bpc.len]);</span>
<span class="line" id="L298"></span>
<span class="line" id="L299">        <span class="tok-kw">for</span> (ps) |p, i| {</span>
<span class="line" id="L300">            <span class="tok-kw">if</span> (p.is_base) {</span>
<span class="line" id="L301">                pcs[i] = bpc;</span>
<span class="line" id="L302">            } <span class="tok-kw">else</span> {</span>
<span class="line" id="L303">                pcs[i] = precompute(p, <span class="tok-number">8</span>);</span>
<span class="line" id="L304">                pcs[i][<span class="tok-number">4</span>].rejectIdentity() <span class="tok-kw">catch</span> <span class="tok-kw">return</span> <span class="tok-kw">error</span>.WeakPublicKey;</span>
<span class="line" id="L305">            }</span>
<span class="line" id="L306">        }</span>
<span class="line" id="L307">        <span class="tok-kw">var</span> es: [count][<span class="tok-number">2</span> * <span class="tok-number">32</span>]<span class="tok-type">i8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L308">        <span class="tok-kw">for</span> (ss) |s, i| {</span>
<span class="line" id="L309">            es[i] = slide(s);</span>
<span class="line" id="L310">        }</span>
<span class="line" id="L311">        <span class="tok-kw">var</span> q = Edwards25519.identityElement;</span>
<span class="line" id="L312">        <span class="tok-kw">var</span> pos: <span class="tok-type">usize</span> = <span class="tok-number">2</span> * <span class="tok-number">32</span> - <span class="tok-number">1</span>;</span>
<span class="line" id="L313">        <span class="tok-kw">while</span> (<span class="tok-null">true</span>) : (pos -= <span class="tok-number">1</span>) {</span>
<span class="line" id="L314">            <span class="tok-kw">for</span> (es) |e, i| {</span>
<span class="line" id="L315">                <span class="tok-kw">const</span> slot = e[pos];</span>
<span class="line" id="L316">                <span class="tok-kw">if</span> (slot &gt; <span class="tok-number">0</span>) {</span>
<span class="line" id="L317">                    q = q.add(pcs[i][<span class="tok-builtin">@intCast</span>(<span class="tok-type">usize</span>, slot)]);</span>
<span class="line" id="L318">                } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (slot &lt; <span class="tok-number">0</span>) {</span>
<span class="line" id="L319">                    q = q.sub(pcs[i][<span class="tok-builtin">@intCast</span>(<span class="tok-type">usize</span>, -slot)]);</span>
<span class="line" id="L320">                }</span>
<span class="line" id="L321">            }</span>
<span class="line" id="L322">            <span class="tok-kw">if</span> (pos == <span class="tok-number">0</span>) <span class="tok-kw">break</span>;</span>
<span class="line" id="L323">            q = q.dbl().dbl().dbl().dbl();</span>
<span class="line" id="L324">        }</span>
<span class="line" id="L325">        <span class="tok-kw">try</span> q.rejectIdentity();</span>
<span class="line" id="L326">        <span class="tok-kw">return</span> q;</span>
<span class="line" id="L327">    }</span>
<span class="line" id="L328"></span>
<span class="line" id="L329">    <span class="tok-comment">/// Multiply an Edwards25519 point by a scalar after &quot;clamping&quot; it.</span></span>
<span class="line" id="L330">    <span class="tok-comment">/// Clamping forces the scalar to be a multiple of the cofactor in</span></span>
<span class="line" id="L331">    <span class="tok-comment">/// order to prevent small subgroups attacks.</span></span>
<span class="line" id="L332">    <span class="tok-comment">/// This is strongly recommended for DH operations.</span></span>
<span class="line" id="L333">    <span class="tok-comment">/// Return error.WeakPublicKey if the resulting point is</span></span>
<span class="line" id="L334">    <span class="tok-comment">/// the identity element.</span></span>
<span class="line" id="L335">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">clampedMul</span>(p: Edwards25519, s: [<span class="tok-number">32</span>]<span class="tok-type">u8</span>) (IdentityElementError || WeakPublicKeyError)!Edwards25519 {</span>
<span class="line" id="L336">        <span class="tok-kw">var</span> t: [<span class="tok-number">32</span>]<span class="tok-type">u8</span> = s;</span>
<span class="line" id="L337">        scalar.clamp(&amp;t);</span>
<span class="line" id="L338">        <span class="tok-kw">return</span> mul(p, t);</span>
<span class="line" id="L339">    }</span>
<span class="line" id="L340"></span>
<span class="line" id="L341">    <span class="tok-comment">// montgomery -- recover y = sqrt(x^3 + A*x^2 + x)</span>
</span>
<span class="line" id="L342">    <span class="tok-kw">fn</span> <span class="tok-fn">xmontToYmont</span>(x: Fe) NotSquareError!Fe {</span>
<span class="line" id="L343">        <span class="tok-kw">var</span> x2 = x.sq();</span>
<span class="line" id="L344">        <span class="tok-kw">const</span> x3 = x.mul(x2);</span>
<span class="line" id="L345">        x2 = x2.mul32(Fe.edwards25519a_32);</span>
<span class="line" id="L346">        <span class="tok-kw">return</span> x.add(x2).add(x3).sqrt();</span>
<span class="line" id="L347">    }</span>
<span class="line" id="L348"></span>
<span class="line" id="L349">    <span class="tok-comment">// montgomery affine coordinates to edwards extended coordinates</span>
</span>
<span class="line" id="L350">    <span class="tok-kw">fn</span> <span class="tok-fn">montToEd</span>(x: Fe, y: Fe) Edwards25519 {</span>
<span class="line" id="L351">        <span class="tok-kw">const</span> x_plus_one = x.add(Fe.one);</span>
<span class="line" id="L352">        <span class="tok-kw">const</span> x_minus_one = x.sub(Fe.one);</span>
<span class="line" id="L353">        <span class="tok-kw">const</span> x_plus_one_y_inv = x_plus_one.mul(y).invert(); <span class="tok-comment">// 1/((x+1)*y)</span>
</span>
<span class="line" id="L354"></span>
<span class="line" id="L355">        <span class="tok-comment">// xed = sqrt(-A-2)*x/y</span>
</span>
<span class="line" id="L356">        <span class="tok-kw">const</span> xed = x.mul(Fe.edwards25519sqrtam2).mul(x_plus_one_y_inv).mul(x_plus_one);</span>
<span class="line" id="L357"></span>
<span class="line" id="L358">        <span class="tok-comment">// yed = (x-1)/(x+1) or 1 if the denominator is 0</span>
</span>
<span class="line" id="L359">        <span class="tok-kw">var</span> yed = x_plus_one_y_inv.mul(y).mul(x_minus_one);</span>
<span class="line" id="L360">        yed.cMov(Fe.one, <span class="tok-builtin">@boolToInt</span>(x_plus_one_y_inv.isZero()));</span>
<span class="line" id="L361"></span>
<span class="line" id="L362">        <span class="tok-kw">return</span> Edwards25519{</span>
<span class="line" id="L363">            .x = xed,</span>
<span class="line" id="L364">            .y = yed,</span>
<span class="line" id="L365">            .z = Fe.one,</span>
<span class="line" id="L366">            .t = xed.mul(yed),</span>
<span class="line" id="L367">        };</span>
<span class="line" id="L368">    }</span>
<span class="line" id="L369"></span>
<span class="line" id="L370">    <span class="tok-comment">/// Elligator2 map - Returns Montgomery affine coordinates</span></span>
<span class="line" id="L371">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">elligator2</span>(r: Fe) <span class="tok-kw">struct</span> { x: Fe, y: Fe, not_square: <span class="tok-type">bool</span> } {</span>
<span class="line" id="L372">        <span class="tok-kw">const</span> rr2 = r.sq2().add(Fe.one).invert();</span>
<span class="line" id="L373">        <span class="tok-kw">var</span> x = rr2.mul32(Fe.edwards25519a_32).neg(); <span class="tok-comment">// x=x1</span>
</span>
<span class="line" id="L374">        <span class="tok-kw">var</span> x2 = x.sq();</span>
<span class="line" id="L375">        <span class="tok-kw">const</span> x3 = x2.mul(x);</span>
<span class="line" id="L376">        x2 = x2.mul32(Fe.edwards25519a_32); <span class="tok-comment">// x2 = A*x1^2</span>
</span>
<span class="line" id="L377">        <span class="tok-kw">const</span> gx1 = x3.add(x).add(x2); <span class="tok-comment">// gx1 = x1^3 + A*x1^2 + x1</span>
</span>
<span class="line" id="L378">        <span class="tok-kw">const</span> not_square = !gx1.isSquare();</span>
<span class="line" id="L379"></span>
<span class="line" id="L380">        <span class="tok-comment">// gx1 not a square =&gt; x = -x1-A</span>
</span>
<span class="line" id="L381">        x.cMov(x.neg(), <span class="tok-builtin">@boolToInt</span>(not_square));</span>
<span class="line" id="L382">        x2 = Fe.zero;</span>
<span class="line" id="L383">        x2.cMov(Fe.edwards25519a, <span class="tok-builtin">@boolToInt</span>(not_square));</span>
<span class="line" id="L384">        x = x.sub(x2);</span>
<span class="line" id="L385"></span>
<span class="line" id="L386">        <span class="tok-comment">// We have y = sqrt(gx1) or sqrt(gx2) with gx2 = gx1*(A+x1)/(-x1)</span>
</span>
<span class="line" id="L387">        <span class="tok-comment">// but it is about as fast to just recompute y from the curve equation.</span>
</span>
<span class="line" id="L388">        <span class="tok-kw">const</span> y = xmontToYmont(x) <span class="tok-kw">catch</span> <span class="tok-kw">unreachable</span>;</span>
<span class="line" id="L389">        <span class="tok-kw">return</span> .{ .x = x, .y = y, .not_square = not_square };</span>
<span class="line" id="L390">    }</span>
<span class="line" id="L391"></span>
<span class="line" id="L392">    <span class="tok-comment">/// Map a 64-bit hash into an Edwards25519 point</span></span>
<span class="line" id="L393">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">fromHash</span>(h: [<span class="tok-number">64</span>]<span class="tok-type">u8</span>) Edwards25519 {</span>
<span class="line" id="L394">        <span class="tok-kw">const</span> fe_f = Fe.fromBytes64(h);</span>
<span class="line" id="L395">        <span class="tok-kw">var</span> elr = elligator2(fe_f);</span>
<span class="line" id="L396"></span>
<span class="line" id="L397">        <span class="tok-kw">const</span> y_sign = !elr.not_square;</span>
<span class="line" id="L398">        <span class="tok-kw">const</span> y_neg = elr.y.neg();</span>
<span class="line" id="L399">        elr.y.cMov(y_neg, <span class="tok-builtin">@boolToInt</span>(elr.y.isNegative()) ^ <span class="tok-builtin">@boolToInt</span>(y_sign));</span>
<span class="line" id="L400">        <span class="tok-kw">return</span> montToEd(elr.x, elr.y).clearCofactor();</span>
<span class="line" id="L401">    }</span>
<span class="line" id="L402"></span>
<span class="line" id="L403">    <span class="tok-kw">fn</span> <span class="tok-fn">stringToPoints</span>(<span class="tok-kw">comptime</span> n: <span class="tok-type">usize</span>, ctx: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, s: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) [n]Edwards25519 {</span>
<span class="line" id="L404">        debug.assert(n &lt;= <span class="tok-number">2</span>);</span>
<span class="line" id="L405">        <span class="tok-kw">const</span> H = crypto.hash.sha2.Sha512;</span>
<span class="line" id="L406">        <span class="tok-kw">const</span> h_l: <span class="tok-type">usize</span> = <span class="tok-number">48</span>;</span>
<span class="line" id="L407">        <span class="tok-kw">var</span> xctx = ctx;</span>
<span class="line" id="L408">        <span class="tok-kw">var</span> hctx: [H.digest_length]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L409">        <span class="tok-kw">if</span> (ctx.len &gt; <span class="tok-number">0xff</span>) {</span>
<span class="line" id="L410">            <span class="tok-kw">var</span> st = H.init(.{});</span>
<span class="line" id="L411">            st.update(<span class="tok-str">&quot;H2C-OVERSIZE-DST-&quot;</span>);</span>
<span class="line" id="L412">            st.update(ctx);</span>
<span class="line" id="L413">            st.final(&amp;hctx);</span>
<span class="line" id="L414">            xctx = hctx[<span class="tok-number">0</span>..];</span>
<span class="line" id="L415">        }</span>
<span class="line" id="L416">        <span class="tok-kw">const</span> empty_block = [_]<span class="tok-type">u8</span>{<span class="tok-number">0</span>} ** H.block_length;</span>
<span class="line" id="L417">        <span class="tok-kw">var</span> t = [<span class="tok-number">3</span>]<span class="tok-type">u8</span>{ <span class="tok-number">0</span>, n * h_l, <span class="tok-number">0</span> };</span>
<span class="line" id="L418">        <span class="tok-kw">var</span> xctx_len_u8 = [<span class="tok-number">1</span>]<span class="tok-type">u8</span>{<span class="tok-builtin">@intCast</span>(<span class="tok-type">u8</span>, xctx.len)};</span>
<span class="line" id="L419">        <span class="tok-kw">var</span> st = H.init(.{});</span>
<span class="line" id="L420">        st.update(empty_block[<span class="tok-number">0</span>..]);</span>
<span class="line" id="L421">        st.update(s);</span>
<span class="line" id="L422">        st.update(t[<span class="tok-number">0</span>..]);</span>
<span class="line" id="L423">        st.update(xctx);</span>
<span class="line" id="L424">        st.update(xctx_len_u8[<span class="tok-number">0</span>..]);</span>
<span class="line" id="L425">        <span class="tok-kw">var</span> u_0: [H.digest_length]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L426">        st.final(&amp;u_0);</span>
<span class="line" id="L427">        <span class="tok-kw">var</span> u: [n * H.digest_length]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L428">        <span class="tok-kw">var</span> i: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L429">        <span class="tok-kw">while</span> (i &lt; n * H.digest_length) : (i += H.digest_length) {</span>
<span class="line" id="L430">            mem.copy(<span class="tok-type">u8</span>, u[i..][<span class="tok-number">0</span>..H.digest_length], u_0[<span class="tok-number">0</span>..]);</span>
<span class="line" id="L431">            <span class="tok-kw">var</span> j: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L432">            <span class="tok-kw">while</span> (i &gt; <span class="tok-number">0</span> <span class="tok-kw">and</span> j &lt; H.digest_length) : (j += <span class="tok-number">1</span>) {</span>
<span class="line" id="L433">                u[i + j] ^= u[i + j - H.digest_length];</span>
<span class="line" id="L434">            }</span>
<span class="line" id="L435">            t[<span class="tok-number">2</span>] += <span class="tok-number">1</span>;</span>
<span class="line" id="L436">            st = H.init(.{});</span>
<span class="line" id="L437">            st.update(u[i..][<span class="tok-number">0</span>..H.digest_length]);</span>
<span class="line" id="L438">            st.update(t[<span class="tok-number">2</span>..<span class="tok-number">3</span>]);</span>
<span class="line" id="L439">            st.update(xctx);</span>
<span class="line" id="L440">            st.update(xctx_len_u8[<span class="tok-number">0</span>..]);</span>
<span class="line" id="L441">            st.final(u[i..][<span class="tok-number">0</span>..H.digest_length]);</span>
<span class="line" id="L442">        }</span>
<span class="line" id="L443">        <span class="tok-kw">var</span> px: [n]Edwards25519 = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L444">        i = <span class="tok-number">0</span>;</span>
<span class="line" id="L445">        <span class="tok-kw">while</span> (i &lt; n) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L446">            mem.set(<span class="tok-type">u8</span>, u_0[<span class="tok-number">0</span> .. H.digest_length - h_l], <span class="tok-number">0</span>);</span>
<span class="line" id="L447">            mem.copy(<span class="tok-type">u8</span>, u_0[H.digest_length - h_l ..][<span class="tok-number">0</span>..h_l], u[i * h_l ..][<span class="tok-number">0</span>..h_l]);</span>
<span class="line" id="L448">            px[i] = fromHash(u_0);</span>
<span class="line" id="L449">        }</span>
<span class="line" id="L450">        <span class="tok-kw">return</span> px;</span>
<span class="line" id="L451">    }</span>
<span class="line" id="L452"></span>
<span class="line" id="L453">    <span class="tok-comment">/// Hash a context `ctx` and a string `s` into an Edwards25519 point</span></span>
<span class="line" id="L454">    <span class="tok-comment">///</span></span>
<span class="line" id="L455">    <span class="tok-comment">/// This function implements the edwards25519_XMD:SHA-512_ELL2_RO_ and edwards25519_XMD:SHA-512_ELL2_NU_</span></span>
<span class="line" id="L456">    <span class="tok-comment">/// methods from the &quot;Hashing to Elliptic Curves&quot; standard document.</span></span>
<span class="line" id="L457">    <span class="tok-comment">///</span></span>
<span class="line" id="L458">    <span class="tok-comment">/// Although not strictly required by the standard, it is recommended to avoid NUL characters in</span></span>
<span class="line" id="L459">    <span class="tok-comment">/// the context in order to be compatible with other implementations.</span></span>
<span class="line" id="L460">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">fromString</span>(<span class="tok-kw">comptime</span> random_oracle: <span class="tok-type">bool</span>, ctx: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, s: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) Edwards25519 {</span>
<span class="line" id="L461">        <span class="tok-kw">if</span> (random_oracle) {</span>
<span class="line" id="L462">            <span class="tok-kw">const</span> px = stringToPoints(<span class="tok-number">2</span>, ctx, s);</span>
<span class="line" id="L463">            <span class="tok-kw">return</span> px[<span class="tok-number">0</span>].add(px[<span class="tok-number">1</span>]);</span>
<span class="line" id="L464">        } <span class="tok-kw">else</span> {</span>
<span class="line" id="L465">            <span class="tok-kw">return</span> stringToPoints(<span class="tok-number">1</span>, ctx, s)[<span class="tok-number">0</span>];</span>
<span class="line" id="L466">        }</span>
<span class="line" id="L467">    }</span>
<span class="line" id="L468"></span>
<span class="line" id="L469">    <span class="tok-comment">/// Map a 32 bit uniform bit string into an edwards25519 point</span></span>
<span class="line" id="L470">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">fromUniform</span>(r: [<span class="tok-number">32</span>]<span class="tok-type">u8</span>) Edwards25519 {</span>
<span class="line" id="L471">        <span class="tok-kw">var</span> s = r;</span>
<span class="line" id="L472">        <span class="tok-kw">const</span> x_sign = s[<span class="tok-number">31</span>] &gt;&gt; <span class="tok-number">7</span>;</span>
<span class="line" id="L473">        s[<span class="tok-number">31</span>] &amp;= <span class="tok-number">0x7f</span>;</span>
<span class="line" id="L474">        <span class="tok-kw">const</span> elr = elligator2(Fe.fromBytes(s));</span>
<span class="line" id="L475">        <span class="tok-kw">var</span> p = montToEd(elr.x, elr.y);</span>
<span class="line" id="L476">        <span class="tok-kw">const</span> p_neg = p.neg();</span>
<span class="line" id="L477">        p.cMov(p_neg, <span class="tok-builtin">@boolToInt</span>(p.x.isNegative()) ^ x_sign);</span>
<span class="line" id="L478">        <span class="tok-kw">return</span> p.clearCofactor();</span>
<span class="line" id="L479">    }</span>
<span class="line" id="L480">};</span>
<span class="line" id="L481"></span>
<span class="line" id="L482"><span class="tok-kw">const</span> htest = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;../test.zig&quot;</span>);</span>
<span class="line" id="L483"></span>
<span class="line" id="L484"><span class="tok-kw">test</span> <span class="tok-str">&quot;edwards25519 packing/unpacking&quot;</span> {</span>
<span class="line" id="L485">    <span class="tok-kw">const</span> s = [_]<span class="tok-type">u8</span>{<span class="tok-number">170</span>} ++ [_]<span class="tok-type">u8</span>{<span class="tok-number">0</span>} ** <span class="tok-number">31</span>;</span>
<span class="line" id="L486">    <span class="tok-kw">var</span> b = Edwards25519.basePoint;</span>
<span class="line" id="L487">    <span class="tok-kw">const</span> pk = <span class="tok-kw">try</span> b.mul(s);</span>
<span class="line" id="L488">    <span class="tok-kw">var</span> buf: [<span class="tok-number">128</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L489">    <span class="tok-kw">try</span> std.testing.expectEqualStrings(<span class="tok-kw">try</span> std.fmt.bufPrint(&amp;buf, <span class="tok-str">&quot;{s}&quot;</span>, .{std.fmt.fmtSliceHexUpper(&amp;pk.toBytes())}), <span class="tok-str">&quot;074BC7E0FCBD587FDBC0969444245FADC562809C8F6E97E949AF62484B5B81A6&quot;</span>);</span>
<span class="line" id="L490"></span>
<span class="line" id="L491">    <span class="tok-kw">const</span> small_order_ss: [<span class="tok-number">7</span>][<span class="tok-number">32</span>]<span class="tok-type">u8</span> = .{</span>
<span class="line" id="L492">        .{</span>
<span class="line" id="L493">            <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-comment">// 0 (order 4)</span>
</span>
<span class="line" id="L494">        },</span>
<span class="line" id="L495">        .{</span>
<span class="line" id="L496">            <span class="tok-number">0x01</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-comment">// 1 (order 1)</span>
</span>
<span class="line" id="L497">        },</span>
<span class="line" id="L498">        .{</span>
<span class="line" id="L499">            <span class="tok-number">0x26</span>, <span class="tok-number">0xe8</span>, <span class="tok-number">0x95</span>, <span class="tok-number">0x8f</span>, <span class="tok-number">0xc2</span>, <span class="tok-number">0xb2</span>, <span class="tok-number">0x27</span>, <span class="tok-number">0xb0</span>, <span class="tok-number">0x45</span>, <span class="tok-number">0xc3</span>, <span class="tok-number">0xf4</span>, <span class="tok-number">0x89</span>, <span class="tok-number">0xf2</span>, <span class="tok-number">0xef</span>, <span class="tok-number">0x98</span>, <span class="tok-number">0xf0</span>, <span class="tok-number">0xd5</span>, <span class="tok-number">0xdf</span>, <span class="tok-number">0xac</span>, <span class="tok-number">0x05</span>, <span class="tok-number">0xd3</span>, <span class="tok-number">0xc6</span>, <span class="tok-number">0x33</span>, <span class="tok-number">0x39</span>, <span class="tok-number">0xb1</span>, <span class="tok-number">0x38</span>, <span class="tok-number">0x02</span>, <span class="tok-number">0x88</span>, <span class="tok-number">0x6d</span>, <span class="tok-number">0x53</span>, <span class="tok-number">0xfc</span>, <span class="tok-number">0x05</span>, <span class="tok-comment">// 270738550114484064931822528722565878893680426757531351946374360975030340202(order 8)</span>
</span>
<span class="line" id="L500">        },</span>
<span class="line" id="L501">        .{</span>
<span class="line" id="L502">            <span class="tok-number">0xc7</span>, <span class="tok-number">0x17</span>, <span class="tok-number">0x6a</span>, <span class="tok-number">0x70</span>, <span class="tok-number">0x3d</span>, <span class="tok-number">0x4d</span>, <span class="tok-number">0xd8</span>, <span class="tok-number">0x4f</span>, <span class="tok-number">0xba</span>, <span class="tok-number">0x3c</span>, <span class="tok-number">0x0b</span>, <span class="tok-number">0x76</span>, <span class="tok-number">0x0d</span>, <span class="tok-number">0x10</span>, <span class="tok-number">0x67</span>, <span class="tok-number">0x0f</span>, <span class="tok-number">0x2a</span>, <span class="tok-number">0x20</span>, <span class="tok-number">0x53</span>, <span class="tok-number">0xfa</span>, <span class="tok-number">0x2c</span>, <span class="tok-number">0x39</span>, <span class="tok-number">0xcc</span>, <span class="tok-number">0xc6</span>, <span class="tok-number">0x4e</span>, <span class="tok-number">0xc7</span>, <span class="tok-number">0xfd</span>, <span class="tok-number">0x77</span>, <span class="tok-number">0x92</span>, <span class="tok-number">0xac</span>, <span class="tok-number">0x03</span>, <span class="tok-number">0x7a</span>, <span class="tok-comment">// 55188659117513257062467267217118295137698188065244968500265048394206261417927 (order 8)</span>
</span>
<span class="line" id="L503">        },</span>
<span class="line" id="L504">        .{</span>
<span class="line" id="L505">            <span class="tok-number">0xec</span>, <span class="tok-number">0xff</span>, <span class="tok-number">0xff</span>, <span class="tok-number">0xff</span>, <span class="tok-number">0xff</span>, <span class="tok-number">0xff</span>, <span class="tok-number">0xff</span>, <span class="tok-number">0xff</span>, <span class="tok-number">0xff</span>, <span class="tok-number">0xff</span>, <span class="tok-number">0xff</span>, <span class="tok-number">0xff</span>, <span class="tok-number">0xff</span>, <span class="tok-number">0xff</span>, <span class="tok-number">0xff</span>, <span class="tok-number">0xff</span>, <span class="tok-number">0xff</span>, <span class="tok-number">0xff</span>, <span class="tok-number">0xff</span>, <span class="tok-number">0xff</span>, <span class="tok-number">0xff</span>, <span class="tok-number">0xff</span>, <span class="tok-number">0xff</span>, <span class="tok-number">0xff</span>, <span class="tok-number">0xff</span>, <span class="tok-number">0xff</span>, <span class="tok-number">0xff</span>, <span class="tok-number">0xff</span>, <span class="tok-number">0xff</span>, <span class="tok-number">0xff</span>, <span class="tok-number">0xff</span>, <span class="tok-number">0x7f</span>, <span class="tok-comment">// p-1 (order 2)</span>
</span>
<span class="line" id="L506">        },</span>
<span class="line" id="L507">        .{</span>
<span class="line" id="L508">            <span class="tok-number">0xed</span>, <span class="tok-number">0xff</span>, <span class="tok-number">0xff</span>, <span class="tok-number">0xff</span>, <span class="tok-number">0xff</span>, <span class="tok-number">0xff</span>, <span class="tok-number">0xff</span>, <span class="tok-number">0xff</span>, <span class="tok-number">0xff</span>, <span class="tok-number">0xff</span>, <span class="tok-number">0xff</span>, <span class="tok-number">0xff</span>, <span class="tok-number">0xff</span>, <span class="tok-number">0xff</span>, <span class="tok-number">0xff</span>, <span class="tok-number">0xff</span>, <span class="tok-number">0xff</span>, <span class="tok-number">0xff</span>, <span class="tok-number">0xff</span>, <span class="tok-number">0xff</span>, <span class="tok-number">0xff</span>, <span class="tok-number">0xff</span>, <span class="tok-number">0xff</span>, <span class="tok-number">0xff</span>, <span class="tok-number">0xff</span>, <span class="tok-number">0xff</span>, <span class="tok-number">0xff</span>, <span class="tok-number">0xff</span>, <span class="tok-number">0xff</span>, <span class="tok-number">0xff</span>, <span class="tok-number">0xff</span>, <span class="tok-number">0x7f</span>, <span class="tok-comment">// p (=0, order 4)</span>
</span>
<span class="line" id="L509">        },</span>
<span class="line" id="L510">        .{</span>
<span class="line" id="L511">            <span class="tok-number">0xee</span>, <span class="tok-number">0xff</span>, <span class="tok-number">0xff</span>, <span class="tok-number">0xff</span>, <span class="tok-number">0xff</span>, <span class="tok-number">0xff</span>, <span class="tok-number">0xff</span>, <span class="tok-number">0xff</span>, <span class="tok-number">0xff</span>, <span class="tok-number">0xff</span>, <span class="tok-number">0xff</span>, <span class="tok-number">0xff</span>, <span class="tok-number">0xff</span>, <span class="tok-number">0xff</span>, <span class="tok-number">0xff</span>, <span class="tok-number">0xff</span>, <span class="tok-number">0xff</span>, <span class="tok-number">0xff</span>, <span class="tok-number">0xff</span>, <span class="tok-number">0xff</span>, <span class="tok-number">0xff</span>, <span class="tok-number">0xff</span>, <span class="tok-number">0xff</span>, <span class="tok-number">0xff</span>, <span class="tok-number">0xff</span>, <span class="tok-number">0xff</span>, <span class="tok-number">0xff</span>, <span class="tok-number">0xff</span>, <span class="tok-number">0xff</span>, <span class="tok-number">0xff</span>, <span class="tok-number">0xff</span>, <span class="tok-number">0x7f</span>, <span class="tok-comment">// p+1 (=1, order 1)</span>
</span>
<span class="line" id="L512">        },</span>
<span class="line" id="L513">    };</span>
<span class="line" id="L514">    <span class="tok-kw">for</span> (small_order_ss) |small_order_s| {</span>
<span class="line" id="L515">        <span class="tok-kw">const</span> small_p = <span class="tok-kw">try</span> Edwards25519.fromBytes(small_order_s);</span>
<span class="line" id="L516">        <span class="tok-kw">try</span> std.testing.expectError(<span class="tok-kw">error</span>.WeakPublicKey, small_p.mul(s));</span>
<span class="line" id="L517">    }</span>
<span class="line" id="L518">}</span>
<span class="line" id="L519"></span>
<span class="line" id="L520"><span class="tok-kw">test</span> <span class="tok-str">&quot;edwards25519 point addition/substraction&quot;</span> {</span>
<span class="line" id="L521">    <span class="tok-kw">var</span> s1: [<span class="tok-number">32</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L522">    <span class="tok-kw">var</span> s2: [<span class="tok-number">32</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L523">    crypto.random.bytes(&amp;s1);</span>
<span class="line" id="L524">    crypto.random.bytes(&amp;s2);</span>
<span class="line" id="L525">    <span class="tok-kw">const</span> p = <span class="tok-kw">try</span> Edwards25519.basePoint.clampedMul(s1);</span>
<span class="line" id="L526">    <span class="tok-kw">const</span> q = <span class="tok-kw">try</span> Edwards25519.basePoint.clampedMul(s2);</span>
<span class="line" id="L527">    <span class="tok-kw">const</span> r = p.add(q).add(q).sub(q).sub(q);</span>
<span class="line" id="L528">    <span class="tok-kw">try</span> r.rejectIdentity();</span>
<span class="line" id="L529">    <span class="tok-kw">try</span> std.testing.expectError(<span class="tok-kw">error</span>.IdentityElement, r.sub(p).rejectIdentity());</span>
<span class="line" id="L530">    <span class="tok-kw">try</span> std.testing.expectError(<span class="tok-kw">error</span>.IdentityElement, p.sub(p).rejectIdentity());</span>
<span class="line" id="L531">    <span class="tok-kw">try</span> std.testing.expectError(<span class="tok-kw">error</span>.IdentityElement, p.sub(q).add(q).sub(p).rejectIdentity());</span>
<span class="line" id="L532">}</span>
<span class="line" id="L533"></span>
<span class="line" id="L534"><span class="tok-kw">test</span> <span class="tok-str">&quot;edwards25519 uniform-to-point&quot;</span> {</span>
<span class="line" id="L535">    <span class="tok-kw">var</span> r = [<span class="tok-number">32</span>]<span class="tok-type">u8</span>{ <span class="tok-number">0</span>, <span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">4</span>, <span class="tok-number">5</span>, <span class="tok-number">6</span>, <span class="tok-number">7</span>, <span class="tok-number">8</span>, <span class="tok-number">9</span>, <span class="tok-number">10</span>, <span class="tok-number">11</span>, <span class="tok-number">12</span>, <span class="tok-number">13</span>, <span class="tok-number">14</span>, <span class="tok-number">15</span>, <span class="tok-number">16</span>, <span class="tok-number">17</span>, <span class="tok-number">18</span>, <span class="tok-number">19</span>, <span class="tok-number">20</span>, <span class="tok-number">21</span>, <span class="tok-number">22</span>, <span class="tok-number">23</span>, <span class="tok-number">24</span>, <span class="tok-number">25</span>, <span class="tok-number">26</span>, <span class="tok-number">27</span>, <span class="tok-number">28</span>, <span class="tok-number">29</span>, <span class="tok-number">30</span>, <span class="tok-number">31</span> };</span>
<span class="line" id="L536">    <span class="tok-kw">var</span> p = Edwards25519.fromUniform(r);</span>
<span class="line" id="L537">    <span class="tok-kw">try</span> htest.assertEqual(<span class="tok-str">&quot;0691eee3cf70a0056df6bfa03120635636581b5c4ea571dfc680f78c7e0b4137&quot;</span>, p.toBytes()[<span class="tok-number">0</span>..]);</span>
<span class="line" id="L538"></span>
<span class="line" id="L539">    r[<span class="tok-number">31</span>] = <span class="tok-number">0xff</span>;</span>
<span class="line" id="L540">    p = Edwards25519.fromUniform(r);</span>
<span class="line" id="L541">    <span class="tok-kw">try</span> htest.assertEqual(<span class="tok-str">&quot;f70718e68ef42d90ca1d936bb2d7e159be6c01d8095d39bd70487c82fe5c973a&quot;</span>, p.toBytes()[<span class="tok-number">0</span>..]);</span>
<span class="line" id="L542">}</span>
<span class="line" id="L543"></span>
<span class="line" id="L544"><span class="tok-comment">// Test vectors from draft-irtf-cfrg-hash-to-curve-12</span>
</span>
<span class="line" id="L545"><span class="tok-kw">test</span> <span class="tok-str">&quot;edwards25519 hash-to-curve operation&quot;</span> {</span>
<span class="line" id="L546">    <span class="tok-kw">var</span> p = Edwards25519.fromString(<span class="tok-null">true</span>, <span class="tok-str">&quot;QUUX-V01-CS02-with-edwards25519_XMD:SHA-512_ELL2_RO_&quot;</span>, <span class="tok-str">&quot;abc&quot;</span>);</span>
<span class="line" id="L547">    <span class="tok-kw">try</span> htest.assertEqual(<span class="tok-str">&quot;31558a26887f23fb8218f143e69d5f0af2e7831130bd5b432ef23883b895839a&quot;</span>, p.toBytes()[<span class="tok-number">0</span>..]);</span>
<span class="line" id="L548"></span>
<span class="line" id="L549">    p = Edwards25519.fromString(<span class="tok-null">false</span>, <span class="tok-str">&quot;QUUX-V01-CS02-with-edwards25519_XMD:SHA-512_ELL2_NU_&quot;</span>, <span class="tok-str">&quot;abc&quot;</span>);</span>
<span class="line" id="L550">    <span class="tok-kw">try</span> htest.assertEqual(<span class="tok-str">&quot;42fa27c8f5a1ae0aa38bb59d5938e5145622ba5dedd11d11736fa2f9502d7367&quot;</span>, p.toBytes()[<span class="tok-number">0</span>..]);</span>
<span class="line" id="L551">}</span>
<span class="line" id="L552"></span>
<span class="line" id="L553"><span class="tok-kw">test</span> <span class="tok-str">&quot;edwards25519 implicit reduction of invalid scalars&quot;</span> {</span>
<span class="line" id="L554">    <span class="tok-kw">const</span> s = [_]<span class="tok-type">u8</span>{<span class="tok-number">0</span>} ** <span class="tok-number">31</span> ++ [_]<span class="tok-type">u8</span>{<span class="tok-number">255</span>};</span>
<span class="line" id="L555">    <span class="tok-kw">const</span> p1 = <span class="tok-kw">try</span> Edwards25519.basePoint.mulPublic(s);</span>
<span class="line" id="L556">    <span class="tok-kw">const</span> p2 = <span class="tok-kw">try</span> Edwards25519.basePoint.mul(s);</span>
<span class="line" id="L557">    <span class="tok-kw">const</span> p3 = <span class="tok-kw">try</span> p1.mulPublic(s);</span>
<span class="line" id="L558">    <span class="tok-kw">const</span> p4 = <span class="tok-kw">try</span> p1.mul(s);</span>
<span class="line" id="L559"></span>
<span class="line" id="L560">    <span class="tok-kw">try</span> std.testing.expectEqualSlices(<span class="tok-type">u8</span>, p1.toBytes()[<span class="tok-number">0</span>..], p2.toBytes()[<span class="tok-number">0</span>..]);</span>
<span class="line" id="L561">    <span class="tok-kw">try</span> std.testing.expectEqualSlices(<span class="tok-type">u8</span>, p3.toBytes()[<span class="tok-number">0</span>..], p4.toBytes()[<span class="tok-number">0</span>..]);</span>
<span class="line" id="L562"></span>
<span class="line" id="L563">    <span class="tok-kw">try</span> htest.assertEqual(<span class="tok-str">&quot;339f189ecc5fbebe9895345c72dc07bda6e615f8a40e768441b6f529cd6c671a&quot;</span>, p1.toBytes()[<span class="tok-number">0</span>..]);</span>
<span class="line" id="L564">    <span class="tok-kw">try</span> htest.assertEqual(<span class="tok-str">&quot;a501e4c595a3686d8bee7058c7e6af7fd237f945c47546910e37e0e79b1bafb0&quot;</span>, p3.toBytes()[<span class="tok-number">0</span>..]);</span>
<span class="line" id="L565">}</span>
<span class="line" id="L566"></span>
</code></pre></body>
</html>