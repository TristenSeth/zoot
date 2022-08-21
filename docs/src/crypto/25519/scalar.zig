<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">    <title>crypto/25519/scalar.zig - source view</title>
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
<span class="line" id="L3"><span class="tok-kw">const</span> mem = std.mem;</span>
<span class="line" id="L4"></span>
<span class="line" id="L5"><span class="tok-kw">const</span> NonCanonicalError = std.crypto.errors.NonCanonicalError;</span>
<span class="line" id="L6"></span>
<span class="line" id="L7"><span class="tok-comment">/// The scalar field order.</span></span>
<span class="line" id="L8"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> field_order: <span class="tok-type">u256</span> = <span class="tok-number">7237005577332262213973186563042994240857116359379907606001950938285454250989</span>;</span>
<span class="line" id="L9"></span>
<span class="line" id="L10"><span class="tok-comment">/// A compressed scalar</span></span>
<span class="line" id="L11"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> CompressedScalar = [<span class="tok-number">32</span>]<span class="tok-type">u8</span>;</span>
<span class="line" id="L12"></span>
<span class="line" id="L13"><span class="tok-comment">/// Zero</span></span>
<span class="line" id="L14"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> zero = [_]<span class="tok-type">u8</span>{<span class="tok-number">0</span>} ** <span class="tok-number">32</span>;</span>
<span class="line" id="L15"></span>
<span class="line" id="L16"><span class="tok-kw">const</span> field_order_s = s: {</span>
<span class="line" id="L17">    <span class="tok-kw">var</span> s: [<span class="tok-number">32</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L18">    mem.writeIntLittle(<span class="tok-type">u256</span>, &amp;s, field_order);</span>
<span class="line" id="L19">    <span class="tok-kw">break</span> :s s;</span>
<span class="line" id="L20">};</span>
<span class="line" id="L21"></span>
<span class="line" id="L22"><span class="tok-comment">/// Reject a scalar whose encoding is not canonical.</span></span>
<span class="line" id="L23"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">rejectNonCanonical</span>(s: CompressedScalar) NonCanonicalError!<span class="tok-type">void</span> {</span>
<span class="line" id="L24">    <span class="tok-kw">var</span> c: <span class="tok-type">u8</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L25">    <span class="tok-kw">var</span> n: <span class="tok-type">u8</span> = <span class="tok-number">1</span>;</span>
<span class="line" id="L26">    <span class="tok-kw">var</span> i: <span class="tok-type">usize</span> = <span class="tok-number">31</span>;</span>
<span class="line" id="L27">    <span class="tok-kw">while</span> (<span class="tok-null">true</span>) : (i -= <span class="tok-number">1</span>) {</span>
<span class="line" id="L28">        <span class="tok-kw">const</span> xs = <span class="tok-builtin">@as</span>(<span class="tok-type">u16</span>, s[i]);</span>
<span class="line" id="L29">        <span class="tok-kw">const</span> xfield_order_s = <span class="tok-builtin">@as</span>(<span class="tok-type">u16</span>, field_order_s[i]);</span>
<span class="line" id="L30">        c |= <span class="tok-builtin">@intCast</span>(<span class="tok-type">u8</span>, ((xs -% xfield_order_s) &gt;&gt; <span class="tok-number">8</span>) &amp; n);</span>
<span class="line" id="L31">        n &amp;= <span class="tok-builtin">@intCast</span>(<span class="tok-type">u8</span>, ((xs ^ xfield_order_s) -% <span class="tok-number">1</span>) &gt;&gt; <span class="tok-number">8</span>);</span>
<span class="line" id="L32">        <span class="tok-kw">if</span> (i == <span class="tok-number">0</span>) <span class="tok-kw">break</span>;</span>
<span class="line" id="L33">    }</span>
<span class="line" id="L34">    <span class="tok-kw">if</span> (c == <span class="tok-number">0</span>) {</span>
<span class="line" id="L35">        <span class="tok-kw">return</span> <span class="tok-kw">error</span>.NonCanonical;</span>
<span class="line" id="L36">    }</span>
<span class="line" id="L37">}</span>
<span class="line" id="L38"></span>
<span class="line" id="L39"><span class="tok-comment">/// Reduce a scalar to the field size.</span></span>
<span class="line" id="L40"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">reduce</span>(s: CompressedScalar) CompressedScalar {</span>
<span class="line" id="L41">    <span class="tok-kw">var</span> scalar = Scalar.fromBytes(s);</span>
<span class="line" id="L42">    <span class="tok-kw">return</span> scalar.toBytes();</span>
<span class="line" id="L43">}</span>
<span class="line" id="L44"></span>
<span class="line" id="L45"><span class="tok-comment">/// Reduce a 64-bytes scalar to the field size.</span></span>
<span class="line" id="L46"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">reduce64</span>(s: [<span class="tok-number">64</span>]<span class="tok-type">u8</span>) CompressedScalar {</span>
<span class="line" id="L47">    <span class="tok-kw">var</span> scalar = ScalarDouble.fromBytes64(s);</span>
<span class="line" id="L48">    <span class="tok-kw">return</span> scalar.toBytes();</span>
<span class="line" id="L49">}</span>
<span class="line" id="L50"></span>
<span class="line" id="L51"><span class="tok-comment">/// Perform the X25519 &quot;clamping&quot; operation.</span></span>
<span class="line" id="L52"><span class="tok-comment">/// The scalar is then guaranteed to be a multiple of the cofactor.</span></span>
<span class="line" id="L53"><span class="tok-kw">pub</span> <span class="tok-kw">inline</span> <span class="tok-kw">fn</span> <span class="tok-fn">clamp</span>(s: *CompressedScalar) <span class="tok-type">void</span> {</span>
<span class="line" id="L54">    s[<span class="tok-number">0</span>] &amp;= <span class="tok-number">248</span>;</span>
<span class="line" id="L55">    s[<span class="tok-number">31</span>] = (s[<span class="tok-number">31</span>] &amp; <span class="tok-number">127</span>) | <span class="tok-number">64</span>;</span>
<span class="line" id="L56">}</span>
<span class="line" id="L57"></span>
<span class="line" id="L58"><span class="tok-comment">/// Return a*b (mod L)</span></span>
<span class="line" id="L59"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">mul</span>(a: CompressedScalar, b: CompressedScalar) CompressedScalar {</span>
<span class="line" id="L60">    <span class="tok-kw">return</span> Scalar.fromBytes(a).mul(Scalar.fromBytes(b)).toBytes();</span>
<span class="line" id="L61">}</span>
<span class="line" id="L62"></span>
<span class="line" id="L63"><span class="tok-comment">/// Return a*b+c (mod L)</span></span>
<span class="line" id="L64"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">mulAdd</span>(a: CompressedScalar, b: CompressedScalar, c: CompressedScalar) CompressedScalar {</span>
<span class="line" id="L65">    <span class="tok-kw">return</span> Scalar.fromBytes(a).mul(Scalar.fromBytes(b)).add(Scalar.fromBytes(c)).toBytes();</span>
<span class="line" id="L66">}</span>
<span class="line" id="L67"></span>
<span class="line" id="L68"><span class="tok-comment">/// Return a*8 (mod L)</span></span>
<span class="line" id="L69"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">mul8</span>(s: CompressedScalar) CompressedScalar {</span>
<span class="line" id="L70">    <span class="tok-kw">var</span> x = Scalar.fromBytes(s);</span>
<span class="line" id="L71">    x = x.add(x);</span>
<span class="line" id="L72">    x = x.add(x);</span>
<span class="line" id="L73">    x = x.add(x);</span>
<span class="line" id="L74">    <span class="tok-kw">return</span> x.toBytes();</span>
<span class="line" id="L75">}</span>
<span class="line" id="L76"></span>
<span class="line" id="L77"><span class="tok-comment">/// Return a+b (mod L)</span></span>
<span class="line" id="L78"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">add</span>(a: CompressedScalar, b: CompressedScalar) CompressedScalar {</span>
<span class="line" id="L79">    <span class="tok-kw">return</span> Scalar.fromBytes(a).add(Scalar.fromBytes(b)).toBytes();</span>
<span class="line" id="L80">}</span>
<span class="line" id="L81"></span>
<span class="line" id="L82"><span class="tok-comment">/// Return -s (mod L)</span></span>
<span class="line" id="L83"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">neg</span>(s: CompressedScalar) CompressedScalar {</span>
<span class="line" id="L84">    <span class="tok-kw">const</span> fs: [<span class="tok-number">64</span>]<span class="tok-type">u8</span> = field_order_s ++ [_]<span class="tok-type">u8</span>{<span class="tok-number">0</span>} ** <span class="tok-number">32</span>;</span>
<span class="line" id="L85">    <span class="tok-kw">var</span> sx: [<span class="tok-number">64</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L86">    mem.copy(<span class="tok-type">u8</span>, sx[<span class="tok-number">0</span>..<span class="tok-number">32</span>], s[<span class="tok-number">0</span>..]);</span>
<span class="line" id="L87">    mem.set(<span class="tok-type">u8</span>, sx[<span class="tok-number">32</span>..], <span class="tok-number">0</span>);</span>
<span class="line" id="L88">    <span class="tok-kw">var</span> carry: <span class="tok-type">u32</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L89">    <span class="tok-kw">var</span> i: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L90">    <span class="tok-kw">while</span> (i &lt; <span class="tok-number">64</span>) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L91">        carry = <span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, fs[i]) -% sx[i] -% <span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, carry);</span>
<span class="line" id="L92">        sx[i] = <span class="tok-builtin">@truncate</span>(<span class="tok-type">u8</span>, carry);</span>
<span class="line" id="L93">        carry = (carry &gt;&gt; <span class="tok-number">8</span>) &amp; <span class="tok-number">1</span>;</span>
<span class="line" id="L94">    }</span>
<span class="line" id="L95">    <span class="tok-kw">return</span> reduce64(sx);</span>
<span class="line" id="L96">}</span>
<span class="line" id="L97"></span>
<span class="line" id="L98"><span class="tok-comment">/// Return (a-b) (mod L)</span></span>
<span class="line" id="L99"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">sub</span>(a: CompressedScalar, b: CompressedScalar) CompressedScalar {</span>
<span class="line" id="L100">    <span class="tok-kw">return</span> add(a, neg(b));</span>
<span class="line" id="L101">}</span>
<span class="line" id="L102"></span>
<span class="line" id="L103"><span class="tok-comment">/// Return a random scalar &lt; L</span></span>
<span class="line" id="L104"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">random</span>() CompressedScalar {</span>
<span class="line" id="L105">    <span class="tok-kw">return</span> Scalar.random().toBytes();</span>
<span class="line" id="L106">}</span>
<span class="line" id="L107"></span>
<span class="line" id="L108"><span class="tok-comment">/// A scalar in unpacked representation</span></span>
<span class="line" id="L109"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> Scalar = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L110">    <span class="tok-kw">const</span> Limbs = [<span class="tok-number">5</span>]<span class="tok-type">u64</span>;</span>
<span class="line" id="L111">    limbs: Limbs = <span class="tok-null">undefined</span>,</span>
<span class="line" id="L112"></span>
<span class="line" id="L113">    <span class="tok-comment">/// Unpack a 32-byte representation of a scalar</span></span>
<span class="line" id="L114">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">fromBytes</span>(bytes: CompressedScalar) Scalar {</span>
<span class="line" id="L115">        <span class="tok-kw">var</span> scalar = ScalarDouble.fromBytes32(bytes);</span>
<span class="line" id="L116">        <span class="tok-kw">return</span> scalar.reduce(<span class="tok-number">5</span>);</span>
<span class="line" id="L117">    }</span>
<span class="line" id="L118"></span>
<span class="line" id="L119">    <span class="tok-comment">/// Unpack a 64-byte representation of a scalar</span></span>
<span class="line" id="L120">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">fromBytes64</span>(bytes: [<span class="tok-number">64</span>]<span class="tok-type">u8</span>) Scalar {</span>
<span class="line" id="L121">        <span class="tok-kw">var</span> scalar = ScalarDouble.fromBytes64(bytes);</span>
<span class="line" id="L122">        <span class="tok-kw">return</span> scalar.reduce(<span class="tok-number">5</span>);</span>
<span class="line" id="L123">    }</span>
<span class="line" id="L124"></span>
<span class="line" id="L125">    <span class="tok-comment">/// Pack a scalar into bytes</span></span>
<span class="line" id="L126">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">toBytes</span>(expanded: *<span class="tok-kw">const</span> Scalar) CompressedScalar {</span>
<span class="line" id="L127">        <span class="tok-kw">var</span> bytes: CompressedScalar = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L128">        <span class="tok-kw">var</span> i: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L129">        <span class="tok-kw">while</span> (i &lt; <span class="tok-number">4</span>) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L130">            mem.writeIntLittle(<span class="tok-type">u64</span>, bytes[i * <span class="tok-number">7</span> ..][<span class="tok-number">0</span>..<span class="tok-number">8</span>], expanded.limbs[i]);</span>
<span class="line" id="L131">        }</span>
<span class="line" id="L132">        mem.writeIntLittle(<span class="tok-type">u32</span>, bytes[i * <span class="tok-number">7</span> ..][<span class="tok-number">0</span>..<span class="tok-number">4</span>], <span class="tok-builtin">@intCast</span>(<span class="tok-type">u32</span>, expanded.limbs[i]));</span>
<span class="line" id="L133">        <span class="tok-kw">return</span> bytes;</span>
<span class="line" id="L134">    }</span>
<span class="line" id="L135"></span>
<span class="line" id="L136">    <span class="tok-comment">/// Return true if the scalar is zero</span></span>
<span class="line" id="L137">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">isZero</span>(n: Scalar) <span class="tok-type">bool</span> {</span>
<span class="line" id="L138">        <span class="tok-kw">const</span> limbs = n.limbs;</span>
<span class="line" id="L139">        <span class="tok-kw">return</span> (limbs[<span class="tok-number">0</span>] | limbs[<span class="tok-number">1</span>] | limbs[<span class="tok-number">2</span>] | limbs[<span class="tok-number">3</span>] | limbs[<span class="tok-number">4</span>]) == <span class="tok-number">0</span>;</span>
<span class="line" id="L140">    }</span>
<span class="line" id="L141"></span>
<span class="line" id="L142">    <span class="tok-comment">/// Return x+y (mod L)</span></span>
<span class="line" id="L143">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">add</span>(x: Scalar, y: Scalar) Scalar {</span>
<span class="line" id="L144">        <span class="tok-kw">const</span> carry0 = (x.limbs[<span class="tok-number">0</span>] + y.limbs[<span class="tok-number">0</span>]) &gt;&gt; <span class="tok-number">56</span>;</span>
<span class="line" id="L145">        <span class="tok-kw">const</span> t0 = (x.limbs[<span class="tok-number">0</span>] + y.limbs[<span class="tok-number">0</span>]) &amp; <span class="tok-number">0xffffffffffffff</span>;</span>
<span class="line" id="L146">        <span class="tok-kw">const</span> t00 = t0;</span>
<span class="line" id="L147">        <span class="tok-kw">const</span> c0 = carry0;</span>
<span class="line" id="L148">        <span class="tok-kw">const</span> carry1 = (x.limbs[<span class="tok-number">1</span>] + y.limbs[<span class="tok-number">1</span>] + c0) &gt;&gt; <span class="tok-number">56</span>;</span>
<span class="line" id="L149">        <span class="tok-kw">const</span> t1 = (x.limbs[<span class="tok-number">1</span>] + y.limbs[<span class="tok-number">1</span>] + c0) &amp; <span class="tok-number">0xffffffffffffff</span>;</span>
<span class="line" id="L150">        <span class="tok-kw">const</span> t10 = t1;</span>
<span class="line" id="L151">        <span class="tok-kw">const</span> c1 = carry1;</span>
<span class="line" id="L152">        <span class="tok-kw">const</span> carry2 = (x.limbs[<span class="tok-number">2</span>] + y.limbs[<span class="tok-number">2</span>] + c1) &gt;&gt; <span class="tok-number">56</span>;</span>
<span class="line" id="L153">        <span class="tok-kw">const</span> t2 = (x.limbs[<span class="tok-number">2</span>] + y.limbs[<span class="tok-number">2</span>] + c1) &amp; <span class="tok-number">0xffffffffffffff</span>;</span>
<span class="line" id="L154">        <span class="tok-kw">const</span> t20 = t2;</span>
<span class="line" id="L155">        <span class="tok-kw">const</span> c2 = carry2;</span>
<span class="line" id="L156">        <span class="tok-kw">const</span> carry = (x.limbs[<span class="tok-number">3</span>] + y.limbs[<span class="tok-number">3</span>] + c2) &gt;&gt; <span class="tok-number">56</span>;</span>
<span class="line" id="L157">        <span class="tok-kw">const</span> t3 = (x.limbs[<span class="tok-number">3</span>] + y.limbs[<span class="tok-number">3</span>] + c2) &amp; <span class="tok-number">0xffffffffffffff</span>;</span>
<span class="line" id="L158">        <span class="tok-kw">const</span> t30 = t3;</span>
<span class="line" id="L159">        <span class="tok-kw">const</span> c3 = carry;</span>
<span class="line" id="L160">        <span class="tok-kw">const</span> t4 = x.limbs[<span class="tok-number">4</span>] + y.limbs[<span class="tok-number">4</span>] + c3;</span>
<span class="line" id="L161"></span>
<span class="line" id="L162">        <span class="tok-kw">const</span> y01: <span class="tok-type">u64</span> = <span class="tok-number">5175514460705773</span>;</span>
<span class="line" id="L163">        <span class="tok-kw">const</span> y11: <span class="tok-type">u64</span> = <span class="tok-number">70332060721272408</span>;</span>
<span class="line" id="L164">        <span class="tok-kw">const</span> y21: <span class="tok-type">u64</span> = <span class="tok-number">5342</span>;</span>
<span class="line" id="L165">        <span class="tok-kw">const</span> y31: <span class="tok-type">u64</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L166">        <span class="tok-kw">const</span> y41: <span class="tok-type">u64</span> = <span class="tok-number">268435456</span>;</span>
<span class="line" id="L167"></span>
<span class="line" id="L168">        <span class="tok-kw">const</span> b5 = (t00 -% y01) &gt;&gt; <span class="tok-number">63</span>;</span>
<span class="line" id="L169">        <span class="tok-kw">const</span> t5 = ((b5 &lt;&lt; <span class="tok-number">56</span>) + t00) -% y01;</span>
<span class="line" id="L170">        <span class="tok-kw">const</span> b0 = b5;</span>
<span class="line" id="L171">        <span class="tok-kw">const</span> t01 = t5;</span>
<span class="line" id="L172">        <span class="tok-kw">const</span> b6 = (t10 -% (y11 + b0)) &gt;&gt; <span class="tok-number">63</span>;</span>
<span class="line" id="L173">        <span class="tok-kw">const</span> t6 = ((b6 &lt;&lt; <span class="tok-number">56</span>) + t10) -% (y11 + b0);</span>
<span class="line" id="L174">        <span class="tok-kw">const</span> b1 = b6;</span>
<span class="line" id="L175">        <span class="tok-kw">const</span> t11 = t6;</span>
<span class="line" id="L176">        <span class="tok-kw">const</span> b7 = (t20 -% (y21 + b1)) &gt;&gt; <span class="tok-number">63</span>;</span>
<span class="line" id="L177">        <span class="tok-kw">const</span> t7 = ((b7 &lt;&lt; <span class="tok-number">56</span>) + t20) -% (y21 + b1);</span>
<span class="line" id="L178">        <span class="tok-kw">const</span> b2 = b7;</span>
<span class="line" id="L179">        <span class="tok-kw">const</span> t21 = t7;</span>
<span class="line" id="L180">        <span class="tok-kw">const</span> b8 = (t30 -% (y31 + b2)) &gt;&gt; <span class="tok-number">63</span>;</span>
<span class="line" id="L181">        <span class="tok-kw">const</span> t8 = ((b8 &lt;&lt; <span class="tok-number">56</span>) + t30) -% (y31 + b2);</span>
<span class="line" id="L182">        <span class="tok-kw">const</span> b3 = b8;</span>
<span class="line" id="L183">        <span class="tok-kw">const</span> t31 = t8;</span>
<span class="line" id="L184">        <span class="tok-kw">const</span> b = (t4 -% (y41 + b3)) &gt;&gt; <span class="tok-number">63</span>;</span>
<span class="line" id="L185">        <span class="tok-kw">const</span> t = ((b &lt;&lt; <span class="tok-number">56</span>) + t4) -% (y41 + b3);</span>
<span class="line" id="L186">        <span class="tok-kw">const</span> b4 = b;</span>
<span class="line" id="L187">        <span class="tok-kw">const</span> t41 = t;</span>
<span class="line" id="L188"></span>
<span class="line" id="L189">        <span class="tok-kw">const</span> mask = (b4 -% <span class="tok-number">1</span>);</span>
<span class="line" id="L190">        <span class="tok-kw">const</span> z00 = t00 ^ (mask &amp; (t00 ^ t01));</span>
<span class="line" id="L191">        <span class="tok-kw">const</span> z10 = t10 ^ (mask &amp; (t10 ^ t11));</span>
<span class="line" id="L192">        <span class="tok-kw">const</span> z20 = t20 ^ (mask &amp; (t20 ^ t21));</span>
<span class="line" id="L193">        <span class="tok-kw">const</span> z30 = t30 ^ (mask &amp; (t30 ^ t31));</span>
<span class="line" id="L194">        <span class="tok-kw">const</span> z40 = t4 ^ (mask &amp; (t4 ^ t41));</span>
<span class="line" id="L195"></span>
<span class="line" id="L196">        <span class="tok-kw">return</span> Scalar{ .limbs = .{ z00, z10, z20, z30, z40 } };</span>
<span class="line" id="L197">    }</span>
<span class="line" id="L198"></span>
<span class="line" id="L199">    <span class="tok-comment">/// Return x*r (mod L)</span></span>
<span class="line" id="L200">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">mul</span>(x: Scalar, y: Scalar) Scalar {</span>
<span class="line" id="L201">        <span class="tok-kw">const</span> xy000 = <span class="tok-builtin">@as</span>(<span class="tok-type">u128</span>, x.limbs[<span class="tok-number">0</span>]) * <span class="tok-builtin">@as</span>(<span class="tok-type">u128</span>, y.limbs[<span class="tok-number">0</span>]);</span>
<span class="line" id="L202">        <span class="tok-kw">const</span> xy010 = <span class="tok-builtin">@as</span>(<span class="tok-type">u128</span>, x.limbs[<span class="tok-number">0</span>]) * <span class="tok-builtin">@as</span>(<span class="tok-type">u128</span>, y.limbs[<span class="tok-number">1</span>]);</span>
<span class="line" id="L203">        <span class="tok-kw">const</span> xy020 = <span class="tok-builtin">@as</span>(<span class="tok-type">u128</span>, x.limbs[<span class="tok-number">0</span>]) * <span class="tok-builtin">@as</span>(<span class="tok-type">u128</span>, y.limbs[<span class="tok-number">2</span>]);</span>
<span class="line" id="L204">        <span class="tok-kw">const</span> xy030 = <span class="tok-builtin">@as</span>(<span class="tok-type">u128</span>, x.limbs[<span class="tok-number">0</span>]) * <span class="tok-builtin">@as</span>(<span class="tok-type">u128</span>, y.limbs[<span class="tok-number">3</span>]);</span>
<span class="line" id="L205">        <span class="tok-kw">const</span> xy040 = <span class="tok-builtin">@as</span>(<span class="tok-type">u128</span>, x.limbs[<span class="tok-number">0</span>]) * <span class="tok-builtin">@as</span>(<span class="tok-type">u128</span>, y.limbs[<span class="tok-number">4</span>]);</span>
<span class="line" id="L206">        <span class="tok-kw">const</span> xy100 = <span class="tok-builtin">@as</span>(<span class="tok-type">u128</span>, x.limbs[<span class="tok-number">1</span>]) * <span class="tok-builtin">@as</span>(<span class="tok-type">u128</span>, y.limbs[<span class="tok-number">0</span>]);</span>
<span class="line" id="L207">        <span class="tok-kw">const</span> xy110 = <span class="tok-builtin">@as</span>(<span class="tok-type">u128</span>, x.limbs[<span class="tok-number">1</span>]) * <span class="tok-builtin">@as</span>(<span class="tok-type">u128</span>, y.limbs[<span class="tok-number">1</span>]);</span>
<span class="line" id="L208">        <span class="tok-kw">const</span> xy120 = <span class="tok-builtin">@as</span>(<span class="tok-type">u128</span>, x.limbs[<span class="tok-number">1</span>]) * <span class="tok-builtin">@as</span>(<span class="tok-type">u128</span>, y.limbs[<span class="tok-number">2</span>]);</span>
<span class="line" id="L209">        <span class="tok-kw">const</span> xy130 = <span class="tok-builtin">@as</span>(<span class="tok-type">u128</span>, x.limbs[<span class="tok-number">1</span>]) * <span class="tok-builtin">@as</span>(<span class="tok-type">u128</span>, y.limbs[<span class="tok-number">3</span>]);</span>
<span class="line" id="L210">        <span class="tok-kw">const</span> xy140 = <span class="tok-builtin">@as</span>(<span class="tok-type">u128</span>, x.limbs[<span class="tok-number">1</span>]) * <span class="tok-builtin">@as</span>(<span class="tok-type">u128</span>, y.limbs[<span class="tok-number">4</span>]);</span>
<span class="line" id="L211">        <span class="tok-kw">const</span> xy200 = <span class="tok-builtin">@as</span>(<span class="tok-type">u128</span>, x.limbs[<span class="tok-number">2</span>]) * <span class="tok-builtin">@as</span>(<span class="tok-type">u128</span>, y.limbs[<span class="tok-number">0</span>]);</span>
<span class="line" id="L212">        <span class="tok-kw">const</span> xy210 = <span class="tok-builtin">@as</span>(<span class="tok-type">u128</span>, x.limbs[<span class="tok-number">2</span>]) * <span class="tok-builtin">@as</span>(<span class="tok-type">u128</span>, y.limbs[<span class="tok-number">1</span>]);</span>
<span class="line" id="L213">        <span class="tok-kw">const</span> xy220 = <span class="tok-builtin">@as</span>(<span class="tok-type">u128</span>, x.limbs[<span class="tok-number">2</span>]) * <span class="tok-builtin">@as</span>(<span class="tok-type">u128</span>, y.limbs[<span class="tok-number">2</span>]);</span>
<span class="line" id="L214">        <span class="tok-kw">const</span> xy230 = <span class="tok-builtin">@as</span>(<span class="tok-type">u128</span>, x.limbs[<span class="tok-number">2</span>]) * <span class="tok-builtin">@as</span>(<span class="tok-type">u128</span>, y.limbs[<span class="tok-number">3</span>]);</span>
<span class="line" id="L215">        <span class="tok-kw">const</span> xy240 = <span class="tok-builtin">@as</span>(<span class="tok-type">u128</span>, x.limbs[<span class="tok-number">2</span>]) * <span class="tok-builtin">@as</span>(<span class="tok-type">u128</span>, y.limbs[<span class="tok-number">4</span>]);</span>
<span class="line" id="L216">        <span class="tok-kw">const</span> xy300 = <span class="tok-builtin">@as</span>(<span class="tok-type">u128</span>, x.limbs[<span class="tok-number">3</span>]) * <span class="tok-builtin">@as</span>(<span class="tok-type">u128</span>, y.limbs[<span class="tok-number">0</span>]);</span>
<span class="line" id="L217">        <span class="tok-kw">const</span> xy310 = <span class="tok-builtin">@as</span>(<span class="tok-type">u128</span>, x.limbs[<span class="tok-number">3</span>]) * <span class="tok-builtin">@as</span>(<span class="tok-type">u128</span>, y.limbs[<span class="tok-number">1</span>]);</span>
<span class="line" id="L218">        <span class="tok-kw">const</span> xy320 = <span class="tok-builtin">@as</span>(<span class="tok-type">u128</span>, x.limbs[<span class="tok-number">3</span>]) * <span class="tok-builtin">@as</span>(<span class="tok-type">u128</span>, y.limbs[<span class="tok-number">2</span>]);</span>
<span class="line" id="L219">        <span class="tok-kw">const</span> xy330 = <span class="tok-builtin">@as</span>(<span class="tok-type">u128</span>, x.limbs[<span class="tok-number">3</span>]) * <span class="tok-builtin">@as</span>(<span class="tok-type">u128</span>, y.limbs[<span class="tok-number">3</span>]);</span>
<span class="line" id="L220">        <span class="tok-kw">const</span> xy340 = <span class="tok-builtin">@as</span>(<span class="tok-type">u128</span>, x.limbs[<span class="tok-number">3</span>]) * <span class="tok-builtin">@as</span>(<span class="tok-type">u128</span>, y.limbs[<span class="tok-number">4</span>]);</span>
<span class="line" id="L221">        <span class="tok-kw">const</span> xy400 = <span class="tok-builtin">@as</span>(<span class="tok-type">u128</span>, x.limbs[<span class="tok-number">4</span>]) * <span class="tok-builtin">@as</span>(<span class="tok-type">u128</span>, y.limbs[<span class="tok-number">0</span>]);</span>
<span class="line" id="L222">        <span class="tok-kw">const</span> xy410 = <span class="tok-builtin">@as</span>(<span class="tok-type">u128</span>, x.limbs[<span class="tok-number">4</span>]) * <span class="tok-builtin">@as</span>(<span class="tok-type">u128</span>, y.limbs[<span class="tok-number">1</span>]);</span>
<span class="line" id="L223">        <span class="tok-kw">const</span> xy420 = <span class="tok-builtin">@as</span>(<span class="tok-type">u128</span>, x.limbs[<span class="tok-number">4</span>]) * <span class="tok-builtin">@as</span>(<span class="tok-type">u128</span>, y.limbs[<span class="tok-number">2</span>]);</span>
<span class="line" id="L224">        <span class="tok-kw">const</span> xy430 = <span class="tok-builtin">@as</span>(<span class="tok-type">u128</span>, x.limbs[<span class="tok-number">4</span>]) * <span class="tok-builtin">@as</span>(<span class="tok-type">u128</span>, y.limbs[<span class="tok-number">3</span>]);</span>
<span class="line" id="L225">        <span class="tok-kw">const</span> xy440 = <span class="tok-builtin">@as</span>(<span class="tok-type">u128</span>, x.limbs[<span class="tok-number">4</span>]) * <span class="tok-builtin">@as</span>(<span class="tok-type">u128</span>, y.limbs[<span class="tok-number">4</span>]);</span>
<span class="line" id="L226">        <span class="tok-kw">const</span> z00 = xy000;</span>
<span class="line" id="L227">        <span class="tok-kw">const</span> z10 = xy010 + xy100;</span>
<span class="line" id="L228">        <span class="tok-kw">const</span> z20 = xy020 + xy110 + xy200;</span>
<span class="line" id="L229">        <span class="tok-kw">const</span> z30 = xy030 + xy120 + xy210 + xy300;</span>
<span class="line" id="L230">        <span class="tok-kw">const</span> z40 = xy040 + xy130 + xy220 + xy310 + xy400;</span>
<span class="line" id="L231">        <span class="tok-kw">const</span> z50 = xy140 + xy230 + xy320 + xy410;</span>
<span class="line" id="L232">        <span class="tok-kw">const</span> z60 = xy240 + xy330 + xy420;</span>
<span class="line" id="L233">        <span class="tok-kw">const</span> z70 = xy340 + xy430;</span>
<span class="line" id="L234">        <span class="tok-kw">const</span> z80 = xy440;</span>
<span class="line" id="L235"></span>
<span class="line" id="L236">        <span class="tok-kw">const</span> carry0 = z00 &gt;&gt; <span class="tok-number">56</span>;</span>
<span class="line" id="L237">        <span class="tok-kw">const</span> t10 = <span class="tok-builtin">@truncate</span>(<span class="tok-type">u64</span>, z00) &amp; <span class="tok-number">0xffffffffffffff</span>;</span>
<span class="line" id="L238">        <span class="tok-kw">const</span> c00 = carry0;</span>
<span class="line" id="L239">        <span class="tok-kw">const</span> t00 = t10;</span>
<span class="line" id="L240">        <span class="tok-kw">const</span> carry1 = (z10 + c00) &gt;&gt; <span class="tok-number">56</span>;</span>
<span class="line" id="L241">        <span class="tok-kw">const</span> t11 = <span class="tok-builtin">@truncate</span>(<span class="tok-type">u64</span>, (z10 + c00)) &amp; <span class="tok-number">0xffffffffffffff</span>;</span>
<span class="line" id="L242">        <span class="tok-kw">const</span> c10 = carry1;</span>
<span class="line" id="L243">        <span class="tok-kw">const</span> t12 = t11;</span>
<span class="line" id="L244">        <span class="tok-kw">const</span> carry2 = (z20 + c10) &gt;&gt; <span class="tok-number">56</span>;</span>
<span class="line" id="L245">        <span class="tok-kw">const</span> t13 = <span class="tok-builtin">@truncate</span>(<span class="tok-type">u64</span>, (z20 + c10)) &amp; <span class="tok-number">0xffffffffffffff</span>;</span>
<span class="line" id="L246">        <span class="tok-kw">const</span> c20 = carry2;</span>
<span class="line" id="L247">        <span class="tok-kw">const</span> t20 = t13;</span>
<span class="line" id="L248">        <span class="tok-kw">const</span> carry3 = (z30 + c20) &gt;&gt; <span class="tok-number">56</span>;</span>
<span class="line" id="L249">        <span class="tok-kw">const</span> t14 = <span class="tok-builtin">@truncate</span>(<span class="tok-type">u64</span>, (z30 + c20)) &amp; <span class="tok-number">0xffffffffffffff</span>;</span>
<span class="line" id="L250">        <span class="tok-kw">const</span> c30 = carry3;</span>
<span class="line" id="L251">        <span class="tok-kw">const</span> t30 = t14;</span>
<span class="line" id="L252">        <span class="tok-kw">const</span> carry4 = (z40 + c30) &gt;&gt; <span class="tok-number">56</span>;</span>
<span class="line" id="L253">        <span class="tok-kw">const</span> t15 = <span class="tok-builtin">@truncate</span>(<span class="tok-type">u64</span>, (z40 + c30)) &amp; <span class="tok-number">0xffffffffffffff</span>;</span>
<span class="line" id="L254">        <span class="tok-kw">const</span> c40 = carry4;</span>
<span class="line" id="L255">        <span class="tok-kw">const</span> t40 = t15;</span>
<span class="line" id="L256">        <span class="tok-kw">const</span> carry5 = (z50 + c40) &gt;&gt; <span class="tok-number">56</span>;</span>
<span class="line" id="L257">        <span class="tok-kw">const</span> t16 = <span class="tok-builtin">@truncate</span>(<span class="tok-type">u64</span>, (z50 + c40)) &amp; <span class="tok-number">0xffffffffffffff</span>;</span>
<span class="line" id="L258">        <span class="tok-kw">const</span> c50 = carry5;</span>
<span class="line" id="L259">        <span class="tok-kw">const</span> t50 = t16;</span>
<span class="line" id="L260">        <span class="tok-kw">const</span> carry6 = (z60 + c50) &gt;&gt; <span class="tok-number">56</span>;</span>
<span class="line" id="L261">        <span class="tok-kw">const</span> t17 = <span class="tok-builtin">@truncate</span>(<span class="tok-type">u64</span>, (z60 + c50)) &amp; <span class="tok-number">0xffffffffffffff</span>;</span>
<span class="line" id="L262">        <span class="tok-kw">const</span> c60 = carry6;</span>
<span class="line" id="L263">        <span class="tok-kw">const</span> t60 = t17;</span>
<span class="line" id="L264">        <span class="tok-kw">const</span> carry7 = (z70 + c60) &gt;&gt; <span class="tok-number">56</span>;</span>
<span class="line" id="L265">        <span class="tok-kw">const</span> t18 = <span class="tok-builtin">@truncate</span>(<span class="tok-type">u64</span>, (z70 + c60)) &amp; <span class="tok-number">0xffffffffffffff</span>;</span>
<span class="line" id="L266">        <span class="tok-kw">const</span> c70 = carry7;</span>
<span class="line" id="L267">        <span class="tok-kw">const</span> t70 = t18;</span>
<span class="line" id="L268">        <span class="tok-kw">const</span> carry8 = (z80 + c70) &gt;&gt; <span class="tok-number">56</span>;</span>
<span class="line" id="L269">        <span class="tok-kw">const</span> t19 = <span class="tok-builtin">@truncate</span>(<span class="tok-type">u64</span>, (z80 + c70)) &amp; <span class="tok-number">0xffffffffffffff</span>;</span>
<span class="line" id="L270">        <span class="tok-kw">const</span> c80 = carry8;</span>
<span class="line" id="L271">        <span class="tok-kw">const</span> t80 = t19;</span>
<span class="line" id="L272">        <span class="tok-kw">const</span> t90 = (<span class="tok-builtin">@truncate</span>(<span class="tok-type">u64</span>, c80));</span>
<span class="line" id="L273">        <span class="tok-kw">const</span> r0 = t00;</span>
<span class="line" id="L274">        <span class="tok-kw">const</span> r1 = t12;</span>
<span class="line" id="L275">        <span class="tok-kw">const</span> r2 = t20;</span>
<span class="line" id="L276">        <span class="tok-kw">const</span> r3 = t30;</span>
<span class="line" id="L277">        <span class="tok-kw">const</span> r4 = t40;</span>
<span class="line" id="L278">        <span class="tok-kw">const</span> r5 = t50;</span>
<span class="line" id="L279">        <span class="tok-kw">const</span> r6 = t60;</span>
<span class="line" id="L280">        <span class="tok-kw">const</span> r7 = t70;</span>
<span class="line" id="L281">        <span class="tok-kw">const</span> r8 = t80;</span>
<span class="line" id="L282">        <span class="tok-kw">const</span> r9 = t90;</span>
<span class="line" id="L283"></span>
<span class="line" id="L284">        <span class="tok-kw">const</span> m0: <span class="tok-type">u64</span> = <span class="tok-number">5175514460705773</span>;</span>
<span class="line" id="L285">        <span class="tok-kw">const</span> m1: <span class="tok-type">u64</span> = <span class="tok-number">70332060721272408</span>;</span>
<span class="line" id="L286">        <span class="tok-kw">const</span> m2: <span class="tok-type">u64</span> = <span class="tok-number">5342</span>;</span>
<span class="line" id="L287">        <span class="tok-kw">const</span> m3: <span class="tok-type">u64</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L288">        <span class="tok-kw">const</span> m4: <span class="tok-type">u64</span> = <span class="tok-number">268435456</span>;</span>
<span class="line" id="L289">        <span class="tok-kw">const</span> mu0: <span class="tok-type">u64</span> = <span class="tok-number">44162584779952923</span>;</span>
<span class="line" id="L290">        <span class="tok-kw">const</span> mu1: <span class="tok-type">u64</span> = <span class="tok-number">9390964836247533</span>;</span>
<span class="line" id="L291">        <span class="tok-kw">const</span> mu2: <span class="tok-type">u64</span> = <span class="tok-number">72057594036560134</span>;</span>
<span class="line" id="L292">        <span class="tok-kw">const</span> mu3: <span class="tok-type">u64</span> = <span class="tok-number">72057594037927935</span>;</span>
<span class="line" id="L293">        <span class="tok-kw">const</span> mu4: <span class="tok-type">u64</span> = <span class="tok-number">68719476735</span>;</span>
<span class="line" id="L294"></span>
<span class="line" id="L295">        <span class="tok-kw">const</span> y_ = (r5 &amp; <span class="tok-number">0xffffff</span>) &lt;&lt; <span class="tok-number">32</span>;</span>
<span class="line" id="L296">        <span class="tok-kw">const</span> x_ = r4 &gt;&gt; <span class="tok-number">24</span>;</span>
<span class="line" id="L297">        <span class="tok-kw">const</span> z01 = (x_ | y_);</span>
<span class="line" id="L298">        <span class="tok-kw">const</span> y_0 = (r6 &amp; <span class="tok-number">0xffffff</span>) &lt;&lt; <span class="tok-number">32</span>;</span>
<span class="line" id="L299">        <span class="tok-kw">const</span> x_0 = r5 &gt;&gt; <span class="tok-number">24</span>;</span>
<span class="line" id="L300">        <span class="tok-kw">const</span> z11 = (x_0 | y_0);</span>
<span class="line" id="L301">        <span class="tok-kw">const</span> y_1 = (r7 &amp; <span class="tok-number">0xffffff</span>) &lt;&lt; <span class="tok-number">32</span>;</span>
<span class="line" id="L302">        <span class="tok-kw">const</span> x_1 = r6 &gt;&gt; <span class="tok-number">24</span>;</span>
<span class="line" id="L303">        <span class="tok-kw">const</span> z21 = (x_1 | y_1);</span>
<span class="line" id="L304">        <span class="tok-kw">const</span> y_2 = (r8 &amp; <span class="tok-number">0xffffff</span>) &lt;&lt; <span class="tok-number">32</span>;</span>
<span class="line" id="L305">        <span class="tok-kw">const</span> x_2 = r7 &gt;&gt; <span class="tok-number">24</span>;</span>
<span class="line" id="L306">        <span class="tok-kw">const</span> z31 = (x_2 | y_2);</span>
<span class="line" id="L307">        <span class="tok-kw">const</span> y_3 = (r9 &amp; <span class="tok-number">0xffffff</span>) &lt;&lt; <span class="tok-number">32</span>;</span>
<span class="line" id="L308">        <span class="tok-kw">const</span> x_3 = r8 &gt;&gt; <span class="tok-number">24</span>;</span>
<span class="line" id="L309">        <span class="tok-kw">const</span> z41 = (x_3 | y_3);</span>
<span class="line" id="L310">        <span class="tok-kw">const</span> q0 = z01;</span>
<span class="line" id="L311">        <span class="tok-kw">const</span> q1 = z11;</span>
<span class="line" id="L312">        <span class="tok-kw">const</span> q2 = z21;</span>
<span class="line" id="L313">        <span class="tok-kw">const</span> q3 = z31;</span>
<span class="line" id="L314">        <span class="tok-kw">const</span> q4 = z41;</span>
<span class="line" id="L315">        <span class="tok-kw">const</span> xy001 = <span class="tok-builtin">@as</span>(<span class="tok-type">u128</span>, q0) * <span class="tok-builtin">@as</span>(<span class="tok-type">u128</span>, mu0);</span>
<span class="line" id="L316">        <span class="tok-kw">const</span> xy011 = <span class="tok-builtin">@as</span>(<span class="tok-type">u128</span>, q0) * <span class="tok-builtin">@as</span>(<span class="tok-type">u128</span>, mu1);</span>
<span class="line" id="L317">        <span class="tok-kw">const</span> xy021 = <span class="tok-builtin">@as</span>(<span class="tok-type">u128</span>, q0) * <span class="tok-builtin">@as</span>(<span class="tok-type">u128</span>, mu2);</span>
<span class="line" id="L318">        <span class="tok-kw">const</span> xy031 = <span class="tok-builtin">@as</span>(<span class="tok-type">u128</span>, q0) * <span class="tok-builtin">@as</span>(<span class="tok-type">u128</span>, mu3);</span>
<span class="line" id="L319">        <span class="tok-kw">const</span> xy041 = <span class="tok-builtin">@as</span>(<span class="tok-type">u128</span>, q0) * <span class="tok-builtin">@as</span>(<span class="tok-type">u128</span>, mu4);</span>
<span class="line" id="L320">        <span class="tok-kw">const</span> xy101 = <span class="tok-builtin">@as</span>(<span class="tok-type">u128</span>, q1) * <span class="tok-builtin">@as</span>(<span class="tok-type">u128</span>, mu0);</span>
<span class="line" id="L321">        <span class="tok-kw">const</span> xy111 = <span class="tok-builtin">@as</span>(<span class="tok-type">u128</span>, q1) * <span class="tok-builtin">@as</span>(<span class="tok-type">u128</span>, mu1);</span>
<span class="line" id="L322">        <span class="tok-kw">const</span> xy121 = <span class="tok-builtin">@as</span>(<span class="tok-type">u128</span>, q1) * <span class="tok-builtin">@as</span>(<span class="tok-type">u128</span>, mu2);</span>
<span class="line" id="L323">        <span class="tok-kw">const</span> xy131 = <span class="tok-builtin">@as</span>(<span class="tok-type">u128</span>, q1) * <span class="tok-builtin">@as</span>(<span class="tok-type">u128</span>, mu3);</span>
<span class="line" id="L324">        <span class="tok-kw">const</span> xy14 = <span class="tok-builtin">@as</span>(<span class="tok-type">u128</span>, q1) * <span class="tok-builtin">@as</span>(<span class="tok-type">u128</span>, mu4);</span>
<span class="line" id="L325">        <span class="tok-kw">const</span> xy201 = <span class="tok-builtin">@as</span>(<span class="tok-type">u128</span>, q2) * <span class="tok-builtin">@as</span>(<span class="tok-type">u128</span>, mu0);</span>
<span class="line" id="L326">        <span class="tok-kw">const</span> xy211 = <span class="tok-builtin">@as</span>(<span class="tok-type">u128</span>, q2) * <span class="tok-builtin">@as</span>(<span class="tok-type">u128</span>, mu1);</span>
<span class="line" id="L327">        <span class="tok-kw">const</span> xy221 = <span class="tok-builtin">@as</span>(<span class="tok-type">u128</span>, q2) * <span class="tok-builtin">@as</span>(<span class="tok-type">u128</span>, mu2);</span>
<span class="line" id="L328">        <span class="tok-kw">const</span> xy23 = <span class="tok-builtin">@as</span>(<span class="tok-type">u128</span>, q2) * <span class="tok-builtin">@as</span>(<span class="tok-type">u128</span>, mu3);</span>
<span class="line" id="L329">        <span class="tok-kw">const</span> xy24 = <span class="tok-builtin">@as</span>(<span class="tok-type">u128</span>, q2) * <span class="tok-builtin">@as</span>(<span class="tok-type">u128</span>, mu4);</span>
<span class="line" id="L330">        <span class="tok-kw">const</span> xy301 = <span class="tok-builtin">@as</span>(<span class="tok-type">u128</span>, q3) * <span class="tok-builtin">@as</span>(<span class="tok-type">u128</span>, mu0);</span>
<span class="line" id="L331">        <span class="tok-kw">const</span> xy311 = <span class="tok-builtin">@as</span>(<span class="tok-type">u128</span>, q3) * <span class="tok-builtin">@as</span>(<span class="tok-type">u128</span>, mu1);</span>
<span class="line" id="L332">        <span class="tok-kw">const</span> xy32 = <span class="tok-builtin">@as</span>(<span class="tok-type">u128</span>, q3) * <span class="tok-builtin">@as</span>(<span class="tok-type">u128</span>, mu2);</span>
<span class="line" id="L333">        <span class="tok-kw">const</span> xy33 = <span class="tok-builtin">@as</span>(<span class="tok-type">u128</span>, q3) * <span class="tok-builtin">@as</span>(<span class="tok-type">u128</span>, mu3);</span>
<span class="line" id="L334">        <span class="tok-kw">const</span> xy34 = <span class="tok-builtin">@as</span>(<span class="tok-type">u128</span>, q3) * <span class="tok-builtin">@as</span>(<span class="tok-type">u128</span>, mu4);</span>
<span class="line" id="L335">        <span class="tok-kw">const</span> xy401 = <span class="tok-builtin">@as</span>(<span class="tok-type">u128</span>, q4) * <span class="tok-builtin">@as</span>(<span class="tok-type">u128</span>, mu0);</span>
<span class="line" id="L336">        <span class="tok-kw">const</span> xy41 = <span class="tok-builtin">@as</span>(<span class="tok-type">u128</span>, q4) * <span class="tok-builtin">@as</span>(<span class="tok-type">u128</span>, mu1);</span>
<span class="line" id="L337">        <span class="tok-kw">const</span> xy42 = <span class="tok-builtin">@as</span>(<span class="tok-type">u128</span>, q4) * <span class="tok-builtin">@as</span>(<span class="tok-type">u128</span>, mu2);</span>
<span class="line" id="L338">        <span class="tok-kw">const</span> xy43 = <span class="tok-builtin">@as</span>(<span class="tok-type">u128</span>, q4) * <span class="tok-builtin">@as</span>(<span class="tok-type">u128</span>, mu3);</span>
<span class="line" id="L339">        <span class="tok-kw">const</span> xy44 = <span class="tok-builtin">@as</span>(<span class="tok-type">u128</span>, q4) * <span class="tok-builtin">@as</span>(<span class="tok-type">u128</span>, mu4);</span>
<span class="line" id="L340">        <span class="tok-kw">const</span> z02 = xy001;</span>
<span class="line" id="L341">        <span class="tok-kw">const</span> z12 = xy011 + xy101;</span>
<span class="line" id="L342">        <span class="tok-kw">const</span> z22 = xy021 + xy111 + xy201;</span>
<span class="line" id="L343">        <span class="tok-kw">const</span> z32 = xy031 + xy121 + xy211 + xy301;</span>
<span class="line" id="L344">        <span class="tok-kw">const</span> z42 = xy041 + xy131 + xy221 + xy311 + xy401;</span>
<span class="line" id="L345">        <span class="tok-kw">const</span> z5 = xy14 + xy23 + xy32 + xy41;</span>
<span class="line" id="L346">        <span class="tok-kw">const</span> z6 = xy24 + xy33 + xy42;</span>
<span class="line" id="L347">        <span class="tok-kw">const</span> z7 = xy34 + xy43;</span>
<span class="line" id="L348">        <span class="tok-kw">const</span> z8 = xy44;</span>
<span class="line" id="L349"></span>
<span class="line" id="L350">        <span class="tok-kw">const</span> carry9 = z02 &gt;&gt; <span class="tok-number">56</span>;</span>
<span class="line" id="L351">        <span class="tok-kw">const</span> c01 = carry9;</span>
<span class="line" id="L352">        <span class="tok-kw">const</span> carry10 = (z12 + c01) &gt;&gt; <span class="tok-number">56</span>;</span>
<span class="line" id="L353">        <span class="tok-kw">const</span> c11 = carry10;</span>
<span class="line" id="L354">        <span class="tok-kw">const</span> carry11 = (z22 + c11) &gt;&gt; <span class="tok-number">56</span>;</span>
<span class="line" id="L355">        <span class="tok-kw">const</span> c21 = carry11;</span>
<span class="line" id="L356">        <span class="tok-kw">const</span> carry12 = (z32 + c21) &gt;&gt; <span class="tok-number">56</span>;</span>
<span class="line" id="L357">        <span class="tok-kw">const</span> c31 = carry12;</span>
<span class="line" id="L358">        <span class="tok-kw">const</span> carry13 = (z42 + c31) &gt;&gt; <span class="tok-number">56</span>;</span>
<span class="line" id="L359">        <span class="tok-kw">const</span> t24 = <span class="tok-builtin">@truncate</span>(<span class="tok-type">u64</span>, z42 + c31) &amp; <span class="tok-number">0xffffffffffffff</span>;</span>
<span class="line" id="L360">        <span class="tok-kw">const</span> c41 = carry13;</span>
<span class="line" id="L361">        <span class="tok-kw">const</span> t41 = t24;</span>
<span class="line" id="L362">        <span class="tok-kw">const</span> carry14 = (z5 + c41) &gt;&gt; <span class="tok-number">56</span>;</span>
<span class="line" id="L363">        <span class="tok-kw">const</span> t25 = <span class="tok-builtin">@truncate</span>(<span class="tok-type">u64</span>, z5 + c41) &amp; <span class="tok-number">0xffffffffffffff</span>;</span>
<span class="line" id="L364">        <span class="tok-kw">const</span> c5 = carry14;</span>
<span class="line" id="L365">        <span class="tok-kw">const</span> t5 = t25;</span>
<span class="line" id="L366">        <span class="tok-kw">const</span> carry15 = (z6 + c5) &gt;&gt; <span class="tok-number">56</span>;</span>
<span class="line" id="L367">        <span class="tok-kw">const</span> t26 = <span class="tok-builtin">@truncate</span>(<span class="tok-type">u64</span>, z6 + c5) &amp; <span class="tok-number">0xffffffffffffff</span>;</span>
<span class="line" id="L368">        <span class="tok-kw">const</span> c6 = carry15;</span>
<span class="line" id="L369">        <span class="tok-kw">const</span> t6 = t26;</span>
<span class="line" id="L370">        <span class="tok-kw">const</span> carry16 = (z7 + c6) &gt;&gt; <span class="tok-number">56</span>;</span>
<span class="line" id="L371">        <span class="tok-kw">const</span> t27 = <span class="tok-builtin">@truncate</span>(<span class="tok-type">u64</span>, z7 + c6) &amp; <span class="tok-number">0xffffffffffffff</span>;</span>
<span class="line" id="L372">        <span class="tok-kw">const</span> c7 = carry16;</span>
<span class="line" id="L373">        <span class="tok-kw">const</span> t7 = t27;</span>
<span class="line" id="L374">        <span class="tok-kw">const</span> carry17 = (z8 + c7) &gt;&gt; <span class="tok-number">56</span>;</span>
<span class="line" id="L375">        <span class="tok-kw">const</span> t28 = <span class="tok-builtin">@truncate</span>(<span class="tok-type">u64</span>, z8 + c7) &amp; <span class="tok-number">0xffffffffffffff</span>;</span>
<span class="line" id="L376">        <span class="tok-kw">const</span> c8 = carry17;</span>
<span class="line" id="L377">        <span class="tok-kw">const</span> t8 = t28;</span>
<span class="line" id="L378">        <span class="tok-kw">const</span> t9 = <span class="tok-builtin">@truncate</span>(<span class="tok-type">u64</span>, c8);</span>
<span class="line" id="L379"></span>
<span class="line" id="L380">        <span class="tok-kw">const</span> qmu4_ = t41;</span>
<span class="line" id="L381">        <span class="tok-kw">const</span> qmu5_ = t5;</span>
<span class="line" id="L382">        <span class="tok-kw">const</span> qmu6_ = t6;</span>
<span class="line" id="L383">        <span class="tok-kw">const</span> qmu7_ = t7;</span>
<span class="line" id="L384">        <span class="tok-kw">const</span> qmu8_ = t8;</span>
<span class="line" id="L385">        <span class="tok-kw">const</span> qmu9_ = t9;</span>
<span class="line" id="L386">        <span class="tok-kw">const</span> y_4 = (qmu5_ &amp; <span class="tok-number">0xffffffffff</span>) &lt;&lt; <span class="tok-number">16</span>;</span>
<span class="line" id="L387">        <span class="tok-kw">const</span> x_4 = qmu4_ &gt;&gt; <span class="tok-number">40</span>;</span>
<span class="line" id="L388">        <span class="tok-kw">const</span> z03 = (x_4 | y_4);</span>
<span class="line" id="L389">        <span class="tok-kw">const</span> y_5 = (qmu6_ &amp; <span class="tok-number">0xffffffffff</span>) &lt;&lt; <span class="tok-number">16</span>;</span>
<span class="line" id="L390">        <span class="tok-kw">const</span> x_5 = qmu5_ &gt;&gt; <span class="tok-number">40</span>;</span>
<span class="line" id="L391">        <span class="tok-kw">const</span> z13 = (x_5 | y_5);</span>
<span class="line" id="L392">        <span class="tok-kw">const</span> y_6 = (qmu7_ &amp; <span class="tok-number">0xffffffffff</span>) &lt;&lt; <span class="tok-number">16</span>;</span>
<span class="line" id="L393">        <span class="tok-kw">const</span> x_6 = qmu6_ &gt;&gt; <span class="tok-number">40</span>;</span>
<span class="line" id="L394">        <span class="tok-kw">const</span> z23 = (x_6 | y_6);</span>
<span class="line" id="L395">        <span class="tok-kw">const</span> y_7 = (qmu8_ &amp; <span class="tok-number">0xffffffffff</span>) &lt;&lt; <span class="tok-number">16</span>;</span>
<span class="line" id="L396">        <span class="tok-kw">const</span> x_7 = qmu7_ &gt;&gt; <span class="tok-number">40</span>;</span>
<span class="line" id="L397">        <span class="tok-kw">const</span> z33 = (x_7 | y_7);</span>
<span class="line" id="L398">        <span class="tok-kw">const</span> y_8 = (qmu9_ &amp; <span class="tok-number">0xffffffffff</span>) &lt;&lt; <span class="tok-number">16</span>;</span>
<span class="line" id="L399">        <span class="tok-kw">const</span> x_8 = qmu8_ &gt;&gt; <span class="tok-number">40</span>;</span>
<span class="line" id="L400">        <span class="tok-kw">const</span> z43 = (x_8 | y_8);</span>
<span class="line" id="L401">        <span class="tok-kw">const</span> qdiv0 = z03;</span>
<span class="line" id="L402">        <span class="tok-kw">const</span> qdiv1 = z13;</span>
<span class="line" id="L403">        <span class="tok-kw">const</span> qdiv2 = z23;</span>
<span class="line" id="L404">        <span class="tok-kw">const</span> qdiv3 = z33;</span>
<span class="line" id="L405">        <span class="tok-kw">const</span> qdiv4 = z43;</span>
<span class="line" id="L406">        <span class="tok-kw">const</span> r01 = r0;</span>
<span class="line" id="L407">        <span class="tok-kw">const</span> r11 = r1;</span>
<span class="line" id="L408">        <span class="tok-kw">const</span> r21 = r2;</span>
<span class="line" id="L409">        <span class="tok-kw">const</span> r31 = r3;</span>
<span class="line" id="L410">        <span class="tok-kw">const</span> r41 = (r4 &amp; <span class="tok-number">0xffffffffff</span>);</span>
<span class="line" id="L411"></span>
<span class="line" id="L412">        <span class="tok-kw">const</span> xy00 = <span class="tok-builtin">@as</span>(<span class="tok-type">u128</span>, qdiv0) * <span class="tok-builtin">@as</span>(<span class="tok-type">u128</span>, m0);</span>
<span class="line" id="L413">        <span class="tok-kw">const</span> xy01 = <span class="tok-builtin">@as</span>(<span class="tok-type">u128</span>, qdiv0) * <span class="tok-builtin">@as</span>(<span class="tok-type">u128</span>, m1);</span>
<span class="line" id="L414">        <span class="tok-kw">const</span> xy02 = <span class="tok-builtin">@as</span>(<span class="tok-type">u128</span>, qdiv0) * <span class="tok-builtin">@as</span>(<span class="tok-type">u128</span>, m2);</span>
<span class="line" id="L415">        <span class="tok-kw">const</span> xy03 = <span class="tok-builtin">@as</span>(<span class="tok-type">u128</span>, qdiv0) * <span class="tok-builtin">@as</span>(<span class="tok-type">u128</span>, m3);</span>
<span class="line" id="L416">        <span class="tok-kw">const</span> xy04 = <span class="tok-builtin">@as</span>(<span class="tok-type">u128</span>, qdiv0) * <span class="tok-builtin">@as</span>(<span class="tok-type">u128</span>, m4);</span>
<span class="line" id="L417">        <span class="tok-kw">const</span> xy10 = <span class="tok-builtin">@as</span>(<span class="tok-type">u128</span>, qdiv1) * <span class="tok-builtin">@as</span>(<span class="tok-type">u128</span>, m0);</span>
<span class="line" id="L418">        <span class="tok-kw">const</span> xy11 = <span class="tok-builtin">@as</span>(<span class="tok-type">u128</span>, qdiv1) * <span class="tok-builtin">@as</span>(<span class="tok-type">u128</span>, m1);</span>
<span class="line" id="L419">        <span class="tok-kw">const</span> xy12 = <span class="tok-builtin">@as</span>(<span class="tok-type">u128</span>, qdiv1) * <span class="tok-builtin">@as</span>(<span class="tok-type">u128</span>, m2);</span>
<span class="line" id="L420">        <span class="tok-kw">const</span> xy13 = <span class="tok-builtin">@as</span>(<span class="tok-type">u128</span>, qdiv1) * <span class="tok-builtin">@as</span>(<span class="tok-type">u128</span>, m3);</span>
<span class="line" id="L421">        <span class="tok-kw">const</span> xy20 = <span class="tok-builtin">@as</span>(<span class="tok-type">u128</span>, qdiv2) * <span class="tok-builtin">@as</span>(<span class="tok-type">u128</span>, m0);</span>
<span class="line" id="L422">        <span class="tok-kw">const</span> xy21 = <span class="tok-builtin">@as</span>(<span class="tok-type">u128</span>, qdiv2) * <span class="tok-builtin">@as</span>(<span class="tok-type">u128</span>, m1);</span>
<span class="line" id="L423">        <span class="tok-kw">const</span> xy22 = <span class="tok-builtin">@as</span>(<span class="tok-type">u128</span>, qdiv2) * <span class="tok-builtin">@as</span>(<span class="tok-type">u128</span>, m2);</span>
<span class="line" id="L424">        <span class="tok-kw">const</span> xy30 = <span class="tok-builtin">@as</span>(<span class="tok-type">u128</span>, qdiv3) * <span class="tok-builtin">@as</span>(<span class="tok-type">u128</span>, m0);</span>
<span class="line" id="L425">        <span class="tok-kw">const</span> xy31 = <span class="tok-builtin">@as</span>(<span class="tok-type">u128</span>, qdiv3) * <span class="tok-builtin">@as</span>(<span class="tok-type">u128</span>, m1);</span>
<span class="line" id="L426">        <span class="tok-kw">const</span> xy40 = <span class="tok-builtin">@as</span>(<span class="tok-type">u128</span>, qdiv4) * <span class="tok-builtin">@as</span>(<span class="tok-type">u128</span>, m0);</span>
<span class="line" id="L427">        <span class="tok-kw">const</span> carry18 = xy00 &gt;&gt; <span class="tok-number">56</span>;</span>
<span class="line" id="L428">        <span class="tok-kw">const</span> t29 = <span class="tok-builtin">@truncate</span>(<span class="tok-type">u64</span>, xy00) &amp; <span class="tok-number">0xffffffffffffff</span>;</span>
<span class="line" id="L429">        <span class="tok-kw">const</span> c0 = carry18;</span>
<span class="line" id="L430">        <span class="tok-kw">const</span> t01 = t29;</span>
<span class="line" id="L431">        <span class="tok-kw">const</span> carry19 = (xy01 + xy10 + c0) &gt;&gt; <span class="tok-number">56</span>;</span>
<span class="line" id="L432">        <span class="tok-kw">const</span> t31 = <span class="tok-builtin">@truncate</span>(<span class="tok-type">u64</span>, xy01 + xy10 + c0) &amp; <span class="tok-number">0xffffffffffffff</span>;</span>
<span class="line" id="L433">        <span class="tok-kw">const</span> c12 = carry19;</span>
<span class="line" id="L434">        <span class="tok-kw">const</span> t110 = t31;</span>
<span class="line" id="L435">        <span class="tok-kw">const</span> carry20 = (xy02 + xy11 + xy20 + c12) &gt;&gt; <span class="tok-number">56</span>;</span>
<span class="line" id="L436">        <span class="tok-kw">const</span> t32 = <span class="tok-builtin">@truncate</span>(<span class="tok-type">u64</span>, xy02 + xy11 + xy20 + c12) &amp; <span class="tok-number">0xffffffffffffff</span>;</span>
<span class="line" id="L437">        <span class="tok-kw">const</span> c22 = carry20;</span>
<span class="line" id="L438">        <span class="tok-kw">const</span> t210 = t32;</span>
<span class="line" id="L439">        <span class="tok-kw">const</span> carry = (xy03 + xy12 + xy21 + xy30 + c22) &gt;&gt; <span class="tok-number">56</span>;</span>
<span class="line" id="L440">        <span class="tok-kw">const</span> t33 = <span class="tok-builtin">@truncate</span>(<span class="tok-type">u64</span>, xy03 + xy12 + xy21 + xy30 + c22) &amp; <span class="tok-number">0xffffffffffffff</span>;</span>
<span class="line" id="L441">        <span class="tok-kw">const</span> c32 = carry;</span>
<span class="line" id="L442">        <span class="tok-kw">const</span> t34 = t33;</span>
<span class="line" id="L443">        <span class="tok-kw">const</span> t42 = <span class="tok-builtin">@truncate</span>(<span class="tok-type">u64</span>, xy04 + xy13 + xy22 + xy31 + xy40 + c32) &amp; <span class="tok-number">0xffffffffff</span>;</span>
<span class="line" id="L444"></span>
<span class="line" id="L445">        <span class="tok-kw">const</span> qmul0 = t01;</span>
<span class="line" id="L446">        <span class="tok-kw">const</span> qmul1 = t110;</span>
<span class="line" id="L447">        <span class="tok-kw">const</span> qmul2 = t210;</span>
<span class="line" id="L448">        <span class="tok-kw">const</span> qmul3 = t34;</span>
<span class="line" id="L449">        <span class="tok-kw">const</span> qmul4 = t42;</span>
<span class="line" id="L450">        <span class="tok-kw">const</span> b5 = (r01 -% qmul0) &gt;&gt; <span class="tok-number">63</span>;</span>
<span class="line" id="L451">        <span class="tok-kw">const</span> t35 = ((b5 &lt;&lt; <span class="tok-number">56</span>) + r01) -% qmul0;</span>
<span class="line" id="L452">        <span class="tok-kw">const</span> c1 = b5;</span>
<span class="line" id="L453">        <span class="tok-kw">const</span> t02 = t35;</span>
<span class="line" id="L454">        <span class="tok-kw">const</span> b6 = (r11 -% (qmul1 + c1)) &gt;&gt; <span class="tok-number">63</span>;</span>
<span class="line" id="L455">        <span class="tok-kw">const</span> t36 = ((b6 &lt;&lt; <span class="tok-number">56</span>) + r11) -% (qmul1 + c1);</span>
<span class="line" id="L456">        <span class="tok-kw">const</span> c2 = b6;</span>
<span class="line" id="L457">        <span class="tok-kw">const</span> t111 = t36;</span>
<span class="line" id="L458">        <span class="tok-kw">const</span> b7 = (r21 -% (qmul2 + c2)) &gt;&gt; <span class="tok-number">63</span>;</span>
<span class="line" id="L459">        <span class="tok-kw">const</span> t37 = ((b7 &lt;&lt; <span class="tok-number">56</span>) + r21) -% (qmul2 + c2);</span>
<span class="line" id="L460">        <span class="tok-kw">const</span> c3 = b7;</span>
<span class="line" id="L461">        <span class="tok-kw">const</span> t211 = t37;</span>
<span class="line" id="L462">        <span class="tok-kw">const</span> b8 = (r31 -% (qmul3 + c3)) &gt;&gt; <span class="tok-number">63</span>;</span>
<span class="line" id="L463">        <span class="tok-kw">const</span> t38 = ((b8 &lt;&lt; <span class="tok-number">56</span>) + r31) -% (qmul3 + c3);</span>
<span class="line" id="L464">        <span class="tok-kw">const</span> c4 = b8;</span>
<span class="line" id="L465">        <span class="tok-kw">const</span> t39 = t38;</span>
<span class="line" id="L466">        <span class="tok-kw">const</span> b9 = (r41 -% (qmul4 + c4)) &gt;&gt; <span class="tok-number">63</span>;</span>
<span class="line" id="L467">        <span class="tok-kw">const</span> t43 = ((b9 &lt;&lt; <span class="tok-number">40</span>) + r41) -% (qmul4 + c4);</span>
<span class="line" id="L468">        <span class="tok-kw">const</span> t44 = t43;</span>
<span class="line" id="L469">        <span class="tok-kw">const</span> s0 = t02;</span>
<span class="line" id="L470">        <span class="tok-kw">const</span> s1 = t111;</span>
<span class="line" id="L471">        <span class="tok-kw">const</span> s2 = t211;</span>
<span class="line" id="L472">        <span class="tok-kw">const</span> s3 = t39;</span>
<span class="line" id="L473">        <span class="tok-kw">const</span> s4 = t44;</span>
<span class="line" id="L474"></span>
<span class="line" id="L475">        <span class="tok-kw">const</span> y01: <span class="tok-type">u64</span> = <span class="tok-number">5175514460705773</span>;</span>
<span class="line" id="L476">        <span class="tok-kw">const</span> y11: <span class="tok-type">u64</span> = <span class="tok-number">70332060721272408</span>;</span>
<span class="line" id="L477">        <span class="tok-kw">const</span> y21: <span class="tok-type">u64</span> = <span class="tok-number">5342</span>;</span>
<span class="line" id="L478">        <span class="tok-kw">const</span> y31: <span class="tok-type">u64</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L479">        <span class="tok-kw">const</span> y41: <span class="tok-type">u64</span> = <span class="tok-number">268435456</span>;</span>
<span class="line" id="L480"></span>
<span class="line" id="L481">        <span class="tok-kw">const</span> b10 = (s0 -% y01) &gt;&gt; <span class="tok-number">63</span>;</span>
<span class="line" id="L482">        <span class="tok-kw">const</span> t45 = ((b10 &lt;&lt; <span class="tok-number">56</span>) + s0) -% y01;</span>
<span class="line" id="L483">        <span class="tok-kw">const</span> b0 = b10;</span>
<span class="line" id="L484">        <span class="tok-kw">const</span> t0 = t45;</span>
<span class="line" id="L485">        <span class="tok-kw">const</span> b11 = (s1 -% (y11 + b0)) &gt;&gt; <span class="tok-number">63</span>;</span>
<span class="line" id="L486">        <span class="tok-kw">const</span> t46 = ((b11 &lt;&lt; <span class="tok-number">56</span>) + s1) -% (y11 + b0);</span>
<span class="line" id="L487">        <span class="tok-kw">const</span> b1 = b11;</span>
<span class="line" id="L488">        <span class="tok-kw">const</span> t1 = t46;</span>
<span class="line" id="L489">        <span class="tok-kw">const</span> b12 = (s2 -% (y21 + b1)) &gt;&gt; <span class="tok-number">63</span>;</span>
<span class="line" id="L490">        <span class="tok-kw">const</span> t47 = ((b12 &lt;&lt; <span class="tok-number">56</span>) + s2) -% (y21 + b1);</span>
<span class="line" id="L491">        <span class="tok-kw">const</span> b2 = b12;</span>
<span class="line" id="L492">        <span class="tok-kw">const</span> t2 = t47;</span>
<span class="line" id="L493">        <span class="tok-kw">const</span> b13 = (s3 -% (y31 + b2)) &gt;&gt; <span class="tok-number">63</span>;</span>
<span class="line" id="L494">        <span class="tok-kw">const</span> t48 = ((b13 &lt;&lt; <span class="tok-number">56</span>) + s3) -% (y31 + b2);</span>
<span class="line" id="L495">        <span class="tok-kw">const</span> b3 = b13;</span>
<span class="line" id="L496">        <span class="tok-kw">const</span> t3 = t48;</span>
<span class="line" id="L497">        <span class="tok-kw">const</span> b = (s4 -% (y41 + b3)) &gt;&gt; <span class="tok-number">63</span>;</span>
<span class="line" id="L498">        <span class="tok-kw">const</span> t = ((b &lt;&lt; <span class="tok-number">56</span>) + s4) -% (y41 + b3);</span>
<span class="line" id="L499">        <span class="tok-kw">const</span> b4 = b;</span>
<span class="line" id="L500">        <span class="tok-kw">const</span> t4 = t;</span>
<span class="line" id="L501">        <span class="tok-kw">const</span> mask = (b4 -% <span class="tok-builtin">@intCast</span>(<span class="tok-type">u64</span>, ((<span class="tok-number">1</span>))));</span>
<span class="line" id="L502">        <span class="tok-kw">const</span> z04 = s0 ^ (mask &amp; (s0 ^ t0));</span>
<span class="line" id="L503">        <span class="tok-kw">const</span> z14 = s1 ^ (mask &amp; (s1 ^ t1));</span>
<span class="line" id="L504">        <span class="tok-kw">const</span> z24 = s2 ^ (mask &amp; (s2 ^ t2));</span>
<span class="line" id="L505">        <span class="tok-kw">const</span> z34 = s3 ^ (mask &amp; (s3 ^ t3));</span>
<span class="line" id="L506">        <span class="tok-kw">const</span> z44 = s4 ^ (mask &amp; (s4 ^ t4));</span>
<span class="line" id="L507"></span>
<span class="line" id="L508">        <span class="tok-kw">return</span> Scalar{ .limbs = .{ z04, z14, z24, z34, z44 } };</span>
<span class="line" id="L509">    }</span>
<span class="line" id="L510"></span>
<span class="line" id="L511">    <span class="tok-comment">/// Return x^2 (mod L)</span></span>
<span class="line" id="L512">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">sq</span>(x: Scalar) Scalar {</span>
<span class="line" id="L513">        <span class="tok-kw">return</span> x.mul(x);</span>
<span class="line" id="L514">    }</span>
<span class="line" id="L515"></span>
<span class="line" id="L516">    <span class="tok-comment">/// Square a scalar `n` times</span></span>
<span class="line" id="L517">    <span class="tok-kw">inline</span> <span class="tok-kw">fn</span> <span class="tok-fn">sqn</span>(x: Scalar, <span class="tok-kw">comptime</span> n: <span class="tok-type">comptime_int</span>) Scalar {</span>
<span class="line" id="L518">        <span class="tok-kw">var</span> i: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L519">        <span class="tok-kw">var</span> t = x;</span>
<span class="line" id="L520">        <span class="tok-kw">while</span> (i &lt; n) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L521">            t = t.sq();</span>
<span class="line" id="L522">        }</span>
<span class="line" id="L523">        <span class="tok-kw">return</span> t;</span>
<span class="line" id="L524">    }</span>
<span class="line" id="L525"></span>
<span class="line" id="L526">    <span class="tok-comment">/// Square and multiply</span></span>
<span class="line" id="L527">    <span class="tok-kw">fn</span> <span class="tok-fn">sqn_mul</span>(x: Scalar, <span class="tok-kw">comptime</span> n: <span class="tok-type">comptime_int</span>, y: Scalar) Scalar {</span>
<span class="line" id="L528">        <span class="tok-kw">return</span> x.sqn(n).mul(y);</span>
<span class="line" id="L529">    }</span>
<span class="line" id="L530"></span>
<span class="line" id="L531">    <span class="tok-comment">/// Return the inverse of a scalar (mod L), or 0 if x=0.</span></span>
<span class="line" id="L532">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">invert</span>(x: Scalar) Scalar {</span>
<span class="line" id="L533">        <span class="tok-kw">const</span> _10 = x.sq();</span>
<span class="line" id="L534">        <span class="tok-kw">const</span> _11 = x.mul(_10);</span>
<span class="line" id="L535">        <span class="tok-kw">const</span> _100 = x.mul(_11);</span>
<span class="line" id="L536">        <span class="tok-kw">const</span> _1000 = _100.sq();</span>
<span class="line" id="L537">        <span class="tok-kw">const</span> _1010 = _10.mul(_1000);</span>
<span class="line" id="L538">        <span class="tok-kw">const</span> _1011 = x.mul(_1010);</span>
<span class="line" id="L539">        <span class="tok-kw">const</span> _10000 = _1000.sq();</span>
<span class="line" id="L540">        <span class="tok-kw">const</span> _10110 = _1011.sq();</span>
<span class="line" id="L541">        <span class="tok-kw">const</span> _100000 = _1010.mul(_10110);</span>
<span class="line" id="L542">        <span class="tok-kw">const</span> _100110 = _10000.mul(_10110);</span>
<span class="line" id="L543">        <span class="tok-kw">const</span> _1000000 = _100000.sq();</span>
<span class="line" id="L544">        <span class="tok-kw">const</span> _1010000 = _10000.mul(_1000000);</span>
<span class="line" id="L545">        <span class="tok-kw">const</span> _1010011 = _11.mul(_1010000);</span>
<span class="line" id="L546">        <span class="tok-kw">const</span> _1100011 = _10000.mul(_1010011);</span>
<span class="line" id="L547">        <span class="tok-kw">const</span> _1100111 = _100.mul(_1100011);</span>
<span class="line" id="L548">        <span class="tok-kw">const</span> _1101011 = _100.mul(_1100111);</span>
<span class="line" id="L549">        <span class="tok-kw">const</span> _10010011 = _1000000.mul(_1010011);</span>
<span class="line" id="L550">        <span class="tok-kw">const</span> _10010111 = _100.mul(_10010011);</span>
<span class="line" id="L551">        <span class="tok-kw">const</span> _10111101 = _100110.mul(_10010111);</span>
<span class="line" id="L552">        <span class="tok-kw">const</span> _11010011 = _10110.mul(_10111101);</span>
<span class="line" id="L553">        <span class="tok-kw">const</span> _11100111 = _1010000.mul(_10010111);</span>
<span class="line" id="L554">        <span class="tok-kw">const</span> _11101011 = _100.mul(_11100111);</span>
<span class="line" id="L555">        <span class="tok-kw">const</span> _11110101 = _1010.mul(_11101011);</span>
<span class="line" id="L556">        <span class="tok-kw">return</span> _1011.mul(_11110101).sqn_mul(<span class="tok-number">126</span>, _1010011).sqn_mul(<span class="tok-number">9</span>, _10).mul(_11110101)</span>
<span class="line" id="L557">            .sqn_mul(<span class="tok-number">7</span>, _1100111).sqn_mul(<span class="tok-number">9</span>, _11110101).sqn_mul(<span class="tok-number">11</span>, _10111101).sqn_mul(<span class="tok-number">8</span>, _11100111)</span>
<span class="line" id="L558">            .sqn_mul(<span class="tok-number">9</span>, _1101011).sqn_mul(<span class="tok-number">6</span>, _1011).sqn_mul(<span class="tok-number">14</span>, _10010011).sqn_mul(<span class="tok-number">10</span>, _1100011)</span>
<span class="line" id="L559">            .sqn_mul(<span class="tok-number">9</span>, _10010111).sqn_mul(<span class="tok-number">10</span>, _11110101).sqn_mul(<span class="tok-number">8</span>, _11010011).sqn_mul(<span class="tok-number">8</span>, _11101011);</span>
<span class="line" id="L560">    }</span>
<span class="line" id="L561"></span>
<span class="line" id="L562">    <span class="tok-comment">/// Return a random scalar &lt; L.</span></span>
<span class="line" id="L563">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">random</span>() Scalar {</span>
<span class="line" id="L564">        <span class="tok-kw">var</span> s: [<span class="tok-number">64</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L565">        <span class="tok-kw">while</span> (<span class="tok-null">true</span>) {</span>
<span class="line" id="L566">            crypto.random.bytes(&amp;s);</span>
<span class="line" id="L567">            <span class="tok-kw">const</span> n = Scalar.fromBytes64(s);</span>
<span class="line" id="L568">            <span class="tok-kw">if</span> (!n.isZero()) {</span>
<span class="line" id="L569">                <span class="tok-kw">return</span> n;</span>
<span class="line" id="L570">            }</span>
<span class="line" id="L571">        }</span>
<span class="line" id="L572">    }</span>
<span class="line" id="L573">};</span>
<span class="line" id="L574"></span>
<span class="line" id="L575"><span class="tok-kw">const</span> ScalarDouble = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L576">    <span class="tok-kw">const</span> Limbs = [<span class="tok-number">10</span>]<span class="tok-type">u64</span>;</span>
<span class="line" id="L577">    limbs: Limbs = <span class="tok-null">undefined</span>,</span>
<span class="line" id="L578"></span>
<span class="line" id="L579">    <span class="tok-kw">fn</span> <span class="tok-fn">fromBytes64</span>(bytes: [<span class="tok-number">64</span>]<span class="tok-type">u8</span>) ScalarDouble {</span>
<span class="line" id="L580">        <span class="tok-kw">var</span> limbs: Limbs = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L581">        <span class="tok-kw">var</span> i: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L582">        <span class="tok-kw">while</span> (i &lt; <span class="tok-number">9</span>) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L583">            limbs[i] = mem.readIntLittle(<span class="tok-type">u64</span>, bytes[i * <span class="tok-number">7</span> ..][<span class="tok-number">0</span>..<span class="tok-number">8</span>]) &amp; <span class="tok-number">0xffffffffffffff</span>;</span>
<span class="line" id="L584">        }</span>
<span class="line" id="L585">        limbs[i] = <span class="tok-builtin">@as</span>(<span class="tok-type">u64</span>, bytes[i * <span class="tok-number">7</span>]);</span>
<span class="line" id="L586">        <span class="tok-kw">return</span> ScalarDouble{ .limbs = limbs };</span>
<span class="line" id="L587">    }</span>
<span class="line" id="L588"></span>
<span class="line" id="L589">    <span class="tok-kw">fn</span> <span class="tok-fn">fromBytes32</span>(bytes: CompressedScalar) ScalarDouble {</span>
<span class="line" id="L590">        <span class="tok-kw">var</span> limbs: Limbs = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L591">        <span class="tok-kw">var</span> i: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L592">        <span class="tok-kw">while</span> (i &lt; <span class="tok-number">4</span>) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L593">            limbs[i] = mem.readIntLittle(<span class="tok-type">u64</span>, bytes[i * <span class="tok-number">7</span> ..][<span class="tok-number">0</span>..<span class="tok-number">8</span>]) &amp; <span class="tok-number">0xffffffffffffff</span>;</span>
<span class="line" id="L594">        }</span>
<span class="line" id="L595">        limbs[i] = <span class="tok-builtin">@as</span>(<span class="tok-type">u64</span>, mem.readIntLittle(<span class="tok-type">u32</span>, bytes[i * <span class="tok-number">7</span> ..][<span class="tok-number">0</span>..<span class="tok-number">4</span>]));</span>
<span class="line" id="L596">        mem.set(<span class="tok-type">u64</span>, limbs[<span class="tok-number">5</span>..], <span class="tok-number">0</span>);</span>
<span class="line" id="L597">        <span class="tok-kw">return</span> ScalarDouble{ .limbs = limbs };</span>
<span class="line" id="L598">    }</span>
<span class="line" id="L599"></span>
<span class="line" id="L600">    <span class="tok-kw">fn</span> <span class="tok-fn">toBytes</span>(expanded_double: *ScalarDouble) CompressedScalar {</span>
<span class="line" id="L601">        <span class="tok-kw">return</span> expanded_double.reduce(<span class="tok-number">10</span>).toBytes();</span>
<span class="line" id="L602">    }</span>
<span class="line" id="L603"></span>
<span class="line" id="L604">    <span class="tok-comment">/// Barrett reduction</span></span>
<span class="line" id="L605">    <span class="tok-kw">fn</span> <span class="tok-fn">reduce</span>(expanded: *ScalarDouble, <span class="tok-kw">comptime</span> limbs_count: <span class="tok-type">usize</span>) Scalar {</span>
<span class="line" id="L606">        <span class="tok-kw">const</span> t = expanded.limbs;</span>
<span class="line" id="L607">        <span class="tok-kw">const</span> t0 = <span class="tok-kw">if</span> (limbs_count &lt;= <span class="tok-number">0</span>) <span class="tok-number">0</span> <span class="tok-kw">else</span> t[<span class="tok-number">0</span>];</span>
<span class="line" id="L608">        <span class="tok-kw">const</span> t1 = <span class="tok-kw">if</span> (limbs_count &lt;= <span class="tok-number">1</span>) <span class="tok-number">0</span> <span class="tok-kw">else</span> t[<span class="tok-number">1</span>];</span>
<span class="line" id="L609">        <span class="tok-kw">const</span> t2 = <span class="tok-kw">if</span> (limbs_count &lt;= <span class="tok-number">2</span>) <span class="tok-number">0</span> <span class="tok-kw">else</span> t[<span class="tok-number">2</span>];</span>
<span class="line" id="L610">        <span class="tok-kw">const</span> t3 = <span class="tok-kw">if</span> (limbs_count &lt;= <span class="tok-number">3</span>) <span class="tok-number">0</span> <span class="tok-kw">else</span> t[<span class="tok-number">3</span>];</span>
<span class="line" id="L611">        <span class="tok-kw">const</span> t4 = <span class="tok-kw">if</span> (limbs_count &lt;= <span class="tok-number">4</span>) <span class="tok-number">0</span> <span class="tok-kw">else</span> t[<span class="tok-number">4</span>];</span>
<span class="line" id="L612">        <span class="tok-kw">const</span> t5 = <span class="tok-kw">if</span> (limbs_count &lt;= <span class="tok-number">5</span>) <span class="tok-number">0</span> <span class="tok-kw">else</span> t[<span class="tok-number">5</span>];</span>
<span class="line" id="L613">        <span class="tok-kw">const</span> t6 = <span class="tok-kw">if</span> (limbs_count &lt;= <span class="tok-number">6</span>) <span class="tok-number">0</span> <span class="tok-kw">else</span> t[<span class="tok-number">6</span>];</span>
<span class="line" id="L614">        <span class="tok-kw">const</span> t7 = <span class="tok-kw">if</span> (limbs_count &lt;= <span class="tok-number">7</span>) <span class="tok-number">0</span> <span class="tok-kw">else</span> t[<span class="tok-number">7</span>];</span>
<span class="line" id="L615">        <span class="tok-kw">const</span> t8 = <span class="tok-kw">if</span> (limbs_count &lt;= <span class="tok-number">8</span>) <span class="tok-number">0</span> <span class="tok-kw">else</span> t[<span class="tok-number">8</span>];</span>
<span class="line" id="L616">        <span class="tok-kw">const</span> t9 = <span class="tok-kw">if</span> (limbs_count &lt;= <span class="tok-number">9</span>) <span class="tok-number">0</span> <span class="tok-kw">else</span> t[<span class="tok-number">9</span>];</span>
<span class="line" id="L617"></span>
<span class="line" id="L618">        <span class="tok-kw">const</span> m0: <span class="tok-type">u64</span> = <span class="tok-number">5175514460705773</span>;</span>
<span class="line" id="L619">        <span class="tok-kw">const</span> m1: <span class="tok-type">u64</span> = <span class="tok-number">70332060721272408</span>;</span>
<span class="line" id="L620">        <span class="tok-kw">const</span> m2: <span class="tok-type">u64</span> = <span class="tok-number">5342</span>;</span>
<span class="line" id="L621">        <span class="tok-kw">const</span> m3: <span class="tok-type">u64</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L622">        <span class="tok-kw">const</span> m4: <span class="tok-type">u64</span> = <span class="tok-number">268435456</span>;</span>
<span class="line" id="L623">        <span class="tok-kw">const</span> mu0: <span class="tok-type">u64</span> = <span class="tok-number">44162584779952923</span>;</span>
<span class="line" id="L624">        <span class="tok-kw">const</span> mu1: <span class="tok-type">u64</span> = <span class="tok-number">9390964836247533</span>;</span>
<span class="line" id="L625">        <span class="tok-kw">const</span> mu2: <span class="tok-type">u64</span> = <span class="tok-number">72057594036560134</span>;</span>
<span class="line" id="L626">        <span class="tok-kw">const</span> mu3: <span class="tok-type">u64</span> = <span class="tok-number">0xffffffffffffff</span>;</span>
<span class="line" id="L627">        <span class="tok-kw">const</span> mu4: <span class="tok-type">u64</span> = <span class="tok-number">68719476735</span>;</span>
<span class="line" id="L628"></span>
<span class="line" id="L629">        <span class="tok-kw">const</span> y_ = (t5 &amp; <span class="tok-number">0xffffff</span>) &lt;&lt; <span class="tok-number">32</span>;</span>
<span class="line" id="L630">        <span class="tok-kw">const</span> x_ = t4 &gt;&gt; <span class="tok-number">24</span>;</span>
<span class="line" id="L631">        <span class="tok-kw">const</span> z00 = x_ | y_;</span>
<span class="line" id="L632">        <span class="tok-kw">const</span> y_0 = (t6 &amp; <span class="tok-number">0xffffff</span>) &lt;&lt; <span class="tok-number">32</span>;</span>
<span class="line" id="L633">        <span class="tok-kw">const</span> x_0 = t5 &gt;&gt; <span class="tok-number">24</span>;</span>
<span class="line" id="L634">        <span class="tok-kw">const</span> z10 = x_0 | y_0;</span>
<span class="line" id="L635">        <span class="tok-kw">const</span> y_1 = (t7 &amp; <span class="tok-number">0xffffff</span>) &lt;&lt; <span class="tok-number">32</span>;</span>
<span class="line" id="L636">        <span class="tok-kw">const</span> x_1 = t6 &gt;&gt; <span class="tok-number">24</span>;</span>
<span class="line" id="L637">        <span class="tok-kw">const</span> z20 = x_1 | y_1;</span>
<span class="line" id="L638">        <span class="tok-kw">const</span> y_2 = (t8 &amp; <span class="tok-number">0xffffff</span>) &lt;&lt; <span class="tok-number">32</span>;</span>
<span class="line" id="L639">        <span class="tok-kw">const</span> x_2 = t7 &gt;&gt; <span class="tok-number">24</span>;</span>
<span class="line" id="L640">        <span class="tok-kw">const</span> z30 = x_2 | y_2;</span>
<span class="line" id="L641">        <span class="tok-kw">const</span> y_3 = (t9 &amp; <span class="tok-number">0xffffff</span>) &lt;&lt; <span class="tok-number">32</span>;</span>
<span class="line" id="L642">        <span class="tok-kw">const</span> x_3 = t8 &gt;&gt; <span class="tok-number">24</span>;</span>
<span class="line" id="L643">        <span class="tok-kw">const</span> z40 = x_3 | y_3;</span>
<span class="line" id="L644">        <span class="tok-kw">const</span> q0 = z00;</span>
<span class="line" id="L645">        <span class="tok-kw">const</span> q1 = z10;</span>
<span class="line" id="L646">        <span class="tok-kw">const</span> q2 = z20;</span>
<span class="line" id="L647">        <span class="tok-kw">const</span> q3 = z30;</span>
<span class="line" id="L648">        <span class="tok-kw">const</span> q4 = z40;</span>
<span class="line" id="L649"></span>
<span class="line" id="L650">        <span class="tok-kw">const</span> xy000 = <span class="tok-builtin">@as</span>(<span class="tok-type">u128</span>, q0) * <span class="tok-builtin">@as</span>(<span class="tok-type">u128</span>, mu0);</span>
<span class="line" id="L651">        <span class="tok-kw">const</span> xy010 = <span class="tok-builtin">@as</span>(<span class="tok-type">u128</span>, q0) * <span class="tok-builtin">@as</span>(<span class="tok-type">u128</span>, mu1);</span>
<span class="line" id="L652">        <span class="tok-kw">const</span> xy020 = <span class="tok-builtin">@as</span>(<span class="tok-type">u128</span>, q0) * <span class="tok-builtin">@as</span>(<span class="tok-type">u128</span>, mu2);</span>
<span class="line" id="L653">        <span class="tok-kw">const</span> xy030 = <span class="tok-builtin">@as</span>(<span class="tok-type">u128</span>, q0) * <span class="tok-builtin">@as</span>(<span class="tok-type">u128</span>, mu3);</span>
<span class="line" id="L654">        <span class="tok-kw">const</span> xy040 = <span class="tok-builtin">@as</span>(<span class="tok-type">u128</span>, q0) * <span class="tok-builtin">@as</span>(<span class="tok-type">u128</span>, mu4);</span>
<span class="line" id="L655">        <span class="tok-kw">const</span> xy100 = <span class="tok-builtin">@as</span>(<span class="tok-type">u128</span>, q1) * <span class="tok-builtin">@as</span>(<span class="tok-type">u128</span>, mu0);</span>
<span class="line" id="L656">        <span class="tok-kw">const</span> xy110 = <span class="tok-builtin">@as</span>(<span class="tok-type">u128</span>, q1) * <span class="tok-builtin">@as</span>(<span class="tok-type">u128</span>, mu1);</span>
<span class="line" id="L657">        <span class="tok-kw">const</span> xy120 = <span class="tok-builtin">@as</span>(<span class="tok-type">u128</span>, q1) * <span class="tok-builtin">@as</span>(<span class="tok-type">u128</span>, mu2);</span>
<span class="line" id="L658">        <span class="tok-kw">const</span> xy130 = <span class="tok-builtin">@as</span>(<span class="tok-type">u128</span>, q1) * <span class="tok-builtin">@as</span>(<span class="tok-type">u128</span>, mu3);</span>
<span class="line" id="L659">        <span class="tok-kw">const</span> xy14 = <span class="tok-builtin">@as</span>(<span class="tok-type">u128</span>, q1) * <span class="tok-builtin">@as</span>(<span class="tok-type">u128</span>, mu4);</span>
<span class="line" id="L660">        <span class="tok-kw">const</span> xy200 = <span class="tok-builtin">@as</span>(<span class="tok-type">u128</span>, q2) * <span class="tok-builtin">@as</span>(<span class="tok-type">u128</span>, mu0);</span>
<span class="line" id="L661">        <span class="tok-kw">const</span> xy210 = <span class="tok-builtin">@as</span>(<span class="tok-type">u128</span>, q2) * <span class="tok-builtin">@as</span>(<span class="tok-type">u128</span>, mu1);</span>
<span class="line" id="L662">        <span class="tok-kw">const</span> xy220 = <span class="tok-builtin">@as</span>(<span class="tok-type">u128</span>, q2) * <span class="tok-builtin">@as</span>(<span class="tok-type">u128</span>, mu2);</span>
<span class="line" id="L663">        <span class="tok-kw">const</span> xy23 = <span class="tok-builtin">@as</span>(<span class="tok-type">u128</span>, q2) * <span class="tok-builtin">@as</span>(<span class="tok-type">u128</span>, mu3);</span>
<span class="line" id="L664">        <span class="tok-kw">const</span> xy24 = <span class="tok-builtin">@as</span>(<span class="tok-type">u128</span>, q2) * <span class="tok-builtin">@as</span>(<span class="tok-type">u128</span>, mu4);</span>
<span class="line" id="L665">        <span class="tok-kw">const</span> xy300 = <span class="tok-builtin">@as</span>(<span class="tok-type">u128</span>, q3) * <span class="tok-builtin">@as</span>(<span class="tok-type">u128</span>, mu0);</span>
<span class="line" id="L666">        <span class="tok-kw">const</span> xy310 = <span class="tok-builtin">@as</span>(<span class="tok-type">u128</span>, q3) * <span class="tok-builtin">@as</span>(<span class="tok-type">u128</span>, mu1);</span>
<span class="line" id="L667">        <span class="tok-kw">const</span> xy32 = <span class="tok-builtin">@as</span>(<span class="tok-type">u128</span>, q3) * <span class="tok-builtin">@as</span>(<span class="tok-type">u128</span>, mu2);</span>
<span class="line" id="L668">        <span class="tok-kw">const</span> xy33 = <span class="tok-builtin">@as</span>(<span class="tok-type">u128</span>, q3) * <span class="tok-builtin">@as</span>(<span class="tok-type">u128</span>, mu3);</span>
<span class="line" id="L669">        <span class="tok-kw">const</span> xy34 = <span class="tok-builtin">@as</span>(<span class="tok-type">u128</span>, q3) * <span class="tok-builtin">@as</span>(<span class="tok-type">u128</span>, mu4);</span>
<span class="line" id="L670">        <span class="tok-kw">const</span> xy400 = <span class="tok-builtin">@as</span>(<span class="tok-type">u128</span>, q4) * <span class="tok-builtin">@as</span>(<span class="tok-type">u128</span>, mu0);</span>
<span class="line" id="L671">        <span class="tok-kw">const</span> xy41 = <span class="tok-builtin">@as</span>(<span class="tok-type">u128</span>, q4) * <span class="tok-builtin">@as</span>(<span class="tok-type">u128</span>, mu1);</span>
<span class="line" id="L672">        <span class="tok-kw">const</span> xy42 = <span class="tok-builtin">@as</span>(<span class="tok-type">u128</span>, q4) * <span class="tok-builtin">@as</span>(<span class="tok-type">u128</span>, mu2);</span>
<span class="line" id="L673">        <span class="tok-kw">const</span> xy43 = <span class="tok-builtin">@as</span>(<span class="tok-type">u128</span>, q4) * <span class="tok-builtin">@as</span>(<span class="tok-type">u128</span>, mu3);</span>
<span class="line" id="L674">        <span class="tok-kw">const</span> xy44 = <span class="tok-builtin">@as</span>(<span class="tok-type">u128</span>, q4) * <span class="tok-builtin">@as</span>(<span class="tok-type">u128</span>, mu4);</span>
<span class="line" id="L675">        <span class="tok-kw">const</span> z01 = xy000;</span>
<span class="line" id="L676">        <span class="tok-kw">const</span> z11 = xy010 + xy100;</span>
<span class="line" id="L677">        <span class="tok-kw">const</span> z21 = xy020 + xy110 + xy200;</span>
<span class="line" id="L678">        <span class="tok-kw">const</span> z31 = xy030 + xy120 + xy210 + xy300;</span>
<span class="line" id="L679">        <span class="tok-kw">const</span> z41 = xy040 + xy130 + xy220 + xy310 + xy400;</span>
<span class="line" id="L680">        <span class="tok-kw">const</span> z5 = xy14 + xy23 + xy32 + xy41;</span>
<span class="line" id="L681">        <span class="tok-kw">const</span> z6 = xy24 + xy33 + xy42;</span>
<span class="line" id="L682">        <span class="tok-kw">const</span> z7 = xy34 + xy43;</span>
<span class="line" id="L683">        <span class="tok-kw">const</span> z8 = xy44;</span>
<span class="line" id="L684"></span>
<span class="line" id="L685">        <span class="tok-kw">const</span> carry0 = z01 &gt;&gt; <span class="tok-number">56</span>;</span>
<span class="line" id="L686">        <span class="tok-kw">const</span> c00 = carry0;</span>
<span class="line" id="L687">        <span class="tok-kw">const</span> carry1 = (z11 + c00) &gt;&gt; <span class="tok-number">56</span>;</span>
<span class="line" id="L688">        <span class="tok-kw">const</span> c10 = carry1;</span>
<span class="line" id="L689">        <span class="tok-kw">const</span> carry2 = (z21 + c10) &gt;&gt; <span class="tok-number">56</span>;</span>
<span class="line" id="L690">        <span class="tok-kw">const</span> c20 = carry2;</span>
<span class="line" id="L691">        <span class="tok-kw">const</span> carry3 = (z31 + c20) &gt;&gt; <span class="tok-number">56</span>;</span>
<span class="line" id="L692">        <span class="tok-kw">const</span> c30 = carry3;</span>
<span class="line" id="L693">        <span class="tok-kw">const</span> carry4 = (z41 + c30) &gt;&gt; <span class="tok-number">56</span>;</span>
<span class="line" id="L694">        <span class="tok-kw">const</span> t103 = <span class="tok-builtin">@as</span>(<span class="tok-type">u64</span>, <span class="tok-builtin">@truncate</span>(<span class="tok-type">u64</span>, z41 + c30)) &amp; <span class="tok-number">0xffffffffffffff</span>;</span>
<span class="line" id="L695">        <span class="tok-kw">const</span> c40 = carry4;</span>
<span class="line" id="L696">        <span class="tok-kw">const</span> t410 = t103;</span>
<span class="line" id="L697">        <span class="tok-kw">const</span> carry5 = (z5 + c40) &gt;&gt; <span class="tok-number">56</span>;</span>
<span class="line" id="L698">        <span class="tok-kw">const</span> t104 = <span class="tok-builtin">@as</span>(<span class="tok-type">u64</span>, <span class="tok-builtin">@truncate</span>(<span class="tok-type">u64</span>, z5 + c40)) &amp; <span class="tok-number">0xffffffffffffff</span>;</span>
<span class="line" id="L699">        <span class="tok-kw">const</span> c5 = carry5;</span>
<span class="line" id="L700">        <span class="tok-kw">const</span> t51 = t104;</span>
<span class="line" id="L701">        <span class="tok-kw">const</span> carry6 = (z6 + c5) &gt;&gt; <span class="tok-number">56</span>;</span>
<span class="line" id="L702">        <span class="tok-kw">const</span> t105 = <span class="tok-builtin">@as</span>(<span class="tok-type">u64</span>, <span class="tok-builtin">@truncate</span>(<span class="tok-type">u64</span>, z6 + c5)) &amp; <span class="tok-number">0xffffffffffffff</span>;</span>
<span class="line" id="L703">        <span class="tok-kw">const</span> c6 = carry6;</span>
<span class="line" id="L704">        <span class="tok-kw">const</span> t61 = t105;</span>
<span class="line" id="L705">        <span class="tok-kw">const</span> carry7 = (z7 + c6) &gt;&gt; <span class="tok-number">56</span>;</span>
<span class="line" id="L706">        <span class="tok-kw">const</span> t106 = <span class="tok-builtin">@as</span>(<span class="tok-type">u64</span>, <span class="tok-builtin">@truncate</span>(<span class="tok-type">u64</span>, z7 + c6)) &amp; <span class="tok-number">0xffffffffffffff</span>;</span>
<span class="line" id="L707">        <span class="tok-kw">const</span> c7 = carry7;</span>
<span class="line" id="L708">        <span class="tok-kw">const</span> t71 = t106;</span>
<span class="line" id="L709">        <span class="tok-kw">const</span> carry8 = (z8 + c7) &gt;&gt; <span class="tok-number">56</span>;</span>
<span class="line" id="L710">        <span class="tok-kw">const</span> t107 = <span class="tok-builtin">@as</span>(<span class="tok-type">u64</span>, <span class="tok-builtin">@truncate</span>(<span class="tok-type">u64</span>, z8 + c7)) &amp; <span class="tok-number">0xffffffffffffff</span>;</span>
<span class="line" id="L711">        <span class="tok-kw">const</span> c8 = carry8;</span>
<span class="line" id="L712">        <span class="tok-kw">const</span> t81 = t107;</span>
<span class="line" id="L713">        <span class="tok-kw">const</span> t91 = <span class="tok-builtin">@as</span>(<span class="tok-type">u64</span>, <span class="tok-builtin">@truncate</span>(<span class="tok-type">u64</span>, c8));</span>
<span class="line" id="L714"></span>
<span class="line" id="L715">        <span class="tok-kw">const</span> qmu4_ = t410;</span>
<span class="line" id="L716">        <span class="tok-kw">const</span> qmu5_ = t51;</span>
<span class="line" id="L717">        <span class="tok-kw">const</span> qmu6_ = t61;</span>
<span class="line" id="L718">        <span class="tok-kw">const</span> qmu7_ = t71;</span>
<span class="line" id="L719">        <span class="tok-kw">const</span> qmu8_ = t81;</span>
<span class="line" id="L720">        <span class="tok-kw">const</span> qmu9_ = t91;</span>
<span class="line" id="L721">        <span class="tok-kw">const</span> y_4 = (qmu5_ &amp; <span class="tok-number">0xffffffffff</span>) &lt;&lt; <span class="tok-number">16</span>;</span>
<span class="line" id="L722">        <span class="tok-kw">const</span> x_4 = qmu4_ &gt;&gt; <span class="tok-number">40</span>;</span>
<span class="line" id="L723">        <span class="tok-kw">const</span> z02 = x_4 | y_4;</span>
<span class="line" id="L724">        <span class="tok-kw">const</span> y_5 = (qmu6_ &amp; <span class="tok-number">0xffffffffff</span>) &lt;&lt; <span class="tok-number">16</span>;</span>
<span class="line" id="L725">        <span class="tok-kw">const</span> x_5 = qmu5_ &gt;&gt; <span class="tok-number">40</span>;</span>
<span class="line" id="L726">        <span class="tok-kw">const</span> z12 = x_5 | y_5;</span>
<span class="line" id="L727">        <span class="tok-kw">const</span> y_6 = (qmu7_ &amp; <span class="tok-number">0xffffffffff</span>) &lt;&lt; <span class="tok-number">16</span>;</span>
<span class="line" id="L728">        <span class="tok-kw">const</span> x_6 = qmu6_ &gt;&gt; <span class="tok-number">40</span>;</span>
<span class="line" id="L729">        <span class="tok-kw">const</span> z22 = x_6 | y_6;</span>
<span class="line" id="L730">        <span class="tok-kw">const</span> y_7 = (qmu8_ &amp; <span class="tok-number">0xffffffffff</span>) &lt;&lt; <span class="tok-number">16</span>;</span>
<span class="line" id="L731">        <span class="tok-kw">const</span> x_7 = qmu7_ &gt;&gt; <span class="tok-number">40</span>;</span>
<span class="line" id="L732">        <span class="tok-kw">const</span> z32 = x_7 | y_7;</span>
<span class="line" id="L733">        <span class="tok-kw">const</span> y_8 = (qmu9_ &amp; <span class="tok-number">0xffffffffff</span>) &lt;&lt; <span class="tok-number">16</span>;</span>
<span class="line" id="L734">        <span class="tok-kw">const</span> x_8 = qmu8_ &gt;&gt; <span class="tok-number">40</span>;</span>
<span class="line" id="L735">        <span class="tok-kw">const</span> z42 = x_8 | y_8;</span>
<span class="line" id="L736">        <span class="tok-kw">const</span> qdiv0 = z02;</span>
<span class="line" id="L737">        <span class="tok-kw">const</span> qdiv1 = z12;</span>
<span class="line" id="L738">        <span class="tok-kw">const</span> qdiv2 = z22;</span>
<span class="line" id="L739">        <span class="tok-kw">const</span> qdiv3 = z32;</span>
<span class="line" id="L740">        <span class="tok-kw">const</span> qdiv4 = z42;</span>
<span class="line" id="L741">        <span class="tok-kw">const</span> r0 = t0;</span>
<span class="line" id="L742">        <span class="tok-kw">const</span> r1 = t1;</span>
<span class="line" id="L743">        <span class="tok-kw">const</span> r2 = t2;</span>
<span class="line" id="L744">        <span class="tok-kw">const</span> r3 = t3;</span>
<span class="line" id="L745">        <span class="tok-kw">const</span> r4 = t4 &amp; <span class="tok-number">0xffffffffff</span>;</span>
<span class="line" id="L746"></span>
<span class="line" id="L747">        <span class="tok-kw">const</span> xy00 = <span class="tok-builtin">@as</span>(<span class="tok-type">u128</span>, qdiv0) * <span class="tok-builtin">@as</span>(<span class="tok-type">u128</span>, m0);</span>
<span class="line" id="L748">        <span class="tok-kw">const</span> xy01 = <span class="tok-builtin">@as</span>(<span class="tok-type">u128</span>, qdiv0) * <span class="tok-builtin">@as</span>(<span class="tok-type">u128</span>, m1);</span>
<span class="line" id="L749">        <span class="tok-kw">const</span> xy02 = <span class="tok-builtin">@as</span>(<span class="tok-type">u128</span>, qdiv0) * <span class="tok-builtin">@as</span>(<span class="tok-type">u128</span>, m2);</span>
<span class="line" id="L750">        <span class="tok-kw">const</span> xy03 = <span class="tok-builtin">@as</span>(<span class="tok-type">u128</span>, qdiv0) * <span class="tok-builtin">@as</span>(<span class="tok-type">u128</span>, m3);</span>
<span class="line" id="L751">        <span class="tok-kw">const</span> xy04 = <span class="tok-builtin">@as</span>(<span class="tok-type">u128</span>, qdiv0) * <span class="tok-builtin">@as</span>(<span class="tok-type">u128</span>, m4);</span>
<span class="line" id="L752">        <span class="tok-kw">const</span> xy10 = <span class="tok-builtin">@as</span>(<span class="tok-type">u128</span>, qdiv1) * <span class="tok-builtin">@as</span>(<span class="tok-type">u128</span>, m0);</span>
<span class="line" id="L753">        <span class="tok-kw">const</span> xy11 = <span class="tok-builtin">@as</span>(<span class="tok-type">u128</span>, qdiv1) * <span class="tok-builtin">@as</span>(<span class="tok-type">u128</span>, m1);</span>
<span class="line" id="L754">        <span class="tok-kw">const</span> xy12 = <span class="tok-builtin">@as</span>(<span class="tok-type">u128</span>, qdiv1) * <span class="tok-builtin">@as</span>(<span class="tok-type">u128</span>, m2);</span>
<span class="line" id="L755">        <span class="tok-kw">const</span> xy13 = <span class="tok-builtin">@as</span>(<span class="tok-type">u128</span>, qdiv1) * <span class="tok-builtin">@as</span>(<span class="tok-type">u128</span>, m3);</span>
<span class="line" id="L756">        <span class="tok-kw">const</span> xy20 = <span class="tok-builtin">@as</span>(<span class="tok-type">u128</span>, qdiv2) * <span class="tok-builtin">@as</span>(<span class="tok-type">u128</span>, m0);</span>
<span class="line" id="L757">        <span class="tok-kw">const</span> xy21 = <span class="tok-builtin">@as</span>(<span class="tok-type">u128</span>, qdiv2) * <span class="tok-builtin">@as</span>(<span class="tok-type">u128</span>, m1);</span>
<span class="line" id="L758">        <span class="tok-kw">const</span> xy22 = <span class="tok-builtin">@as</span>(<span class="tok-type">u128</span>, qdiv2) * <span class="tok-builtin">@as</span>(<span class="tok-type">u128</span>, m2);</span>
<span class="line" id="L759">        <span class="tok-kw">const</span> xy30 = <span class="tok-builtin">@as</span>(<span class="tok-type">u128</span>, qdiv3) * <span class="tok-builtin">@as</span>(<span class="tok-type">u128</span>, m0);</span>
<span class="line" id="L760">        <span class="tok-kw">const</span> xy31 = <span class="tok-builtin">@as</span>(<span class="tok-type">u128</span>, qdiv3) * <span class="tok-builtin">@as</span>(<span class="tok-type">u128</span>, m1);</span>
<span class="line" id="L761">        <span class="tok-kw">const</span> xy40 = <span class="tok-builtin">@as</span>(<span class="tok-type">u128</span>, qdiv4) * <span class="tok-builtin">@as</span>(<span class="tok-type">u128</span>, m0);</span>
<span class="line" id="L762">        <span class="tok-kw">const</span> carry9 = xy00 &gt;&gt; <span class="tok-number">56</span>;</span>
<span class="line" id="L763">        <span class="tok-kw">const</span> t108 = <span class="tok-builtin">@truncate</span>(<span class="tok-type">u64</span>, xy00) &amp; <span class="tok-number">0xffffffffffffff</span>;</span>
<span class="line" id="L764">        <span class="tok-kw">const</span> c0 = carry9;</span>
<span class="line" id="L765">        <span class="tok-kw">const</span> t010 = t108;</span>
<span class="line" id="L766">        <span class="tok-kw">const</span> carry10 = (xy01 + xy10 + c0) &gt;&gt; <span class="tok-number">56</span>;</span>
<span class="line" id="L767">        <span class="tok-kw">const</span> t109 = <span class="tok-builtin">@truncate</span>(<span class="tok-type">u64</span>, xy01 + xy10 + c0) &amp; <span class="tok-number">0xffffffffffffff</span>;</span>
<span class="line" id="L768">        <span class="tok-kw">const</span> c11 = carry10;</span>
<span class="line" id="L769">        <span class="tok-kw">const</span> t110 = t109;</span>
<span class="line" id="L770">        <span class="tok-kw">const</span> carry11 = (xy02 + xy11 + xy20 + c11) &gt;&gt; <span class="tok-number">56</span>;</span>
<span class="line" id="L771">        <span class="tok-kw">const</span> t1010 = <span class="tok-builtin">@truncate</span>(<span class="tok-type">u64</span>, xy02 + xy11 + xy20 + c11) &amp; <span class="tok-number">0xffffffffffffff</span>;</span>
<span class="line" id="L772">        <span class="tok-kw">const</span> c21 = carry11;</span>
<span class="line" id="L773">        <span class="tok-kw">const</span> t210 = t1010;</span>
<span class="line" id="L774">        <span class="tok-kw">const</span> carry = (xy03 + xy12 + xy21 + xy30 + c21) &gt;&gt; <span class="tok-number">56</span>;</span>
<span class="line" id="L775">        <span class="tok-kw">const</span> t1011 = <span class="tok-builtin">@truncate</span>(<span class="tok-type">u64</span>, xy03 + xy12 + xy21 + xy30 + c21) &amp; <span class="tok-number">0xffffffffffffff</span>;</span>
<span class="line" id="L776">        <span class="tok-kw">const</span> c31 = carry;</span>
<span class="line" id="L777">        <span class="tok-kw">const</span> t310 = t1011;</span>
<span class="line" id="L778">        <span class="tok-kw">const</span> t411 = <span class="tok-builtin">@truncate</span>(<span class="tok-type">u64</span>, xy04 + xy13 + xy22 + xy31 + xy40 + c31) &amp; <span class="tok-number">0xffffffffff</span>;</span>
<span class="line" id="L779"></span>
<span class="line" id="L780">        <span class="tok-kw">const</span> qmul0 = t010;</span>
<span class="line" id="L781">        <span class="tok-kw">const</span> qmul1 = t110;</span>
<span class="line" id="L782">        <span class="tok-kw">const</span> qmul2 = t210;</span>
<span class="line" id="L783">        <span class="tok-kw">const</span> qmul3 = t310;</span>
<span class="line" id="L784">        <span class="tok-kw">const</span> qmul4 = t411;</span>
<span class="line" id="L785">        <span class="tok-kw">const</span> b5 = (r0 -% qmul0) &gt;&gt; <span class="tok-number">63</span>;</span>
<span class="line" id="L786">        <span class="tok-kw">const</span> t1012 = ((b5 &lt;&lt; <span class="tok-number">56</span>) + r0) -% qmul0;</span>
<span class="line" id="L787">        <span class="tok-kw">const</span> c1 = b5;</span>
<span class="line" id="L788">        <span class="tok-kw">const</span> t011 = t1012;</span>
<span class="line" id="L789">        <span class="tok-kw">const</span> b6 = (r1 -% (qmul1 + c1)) &gt;&gt; <span class="tok-number">63</span>;</span>
<span class="line" id="L790">        <span class="tok-kw">const</span> t1013 = ((b6 &lt;&lt; <span class="tok-number">56</span>) + r1) -% (qmul1 + c1);</span>
<span class="line" id="L791">        <span class="tok-kw">const</span> c2 = b6;</span>
<span class="line" id="L792">        <span class="tok-kw">const</span> t111 = t1013;</span>
<span class="line" id="L793">        <span class="tok-kw">const</span> b7 = (r2 -% (qmul2 + c2)) &gt;&gt; <span class="tok-number">63</span>;</span>
<span class="line" id="L794">        <span class="tok-kw">const</span> t1014 = ((b7 &lt;&lt; <span class="tok-number">56</span>) + r2) -% (qmul2 + c2);</span>
<span class="line" id="L795">        <span class="tok-kw">const</span> c3 = b7;</span>
<span class="line" id="L796">        <span class="tok-kw">const</span> t211 = t1014;</span>
<span class="line" id="L797">        <span class="tok-kw">const</span> b8 = (r3 -% (qmul3 + c3)) &gt;&gt; <span class="tok-number">63</span>;</span>
<span class="line" id="L798">        <span class="tok-kw">const</span> t1015 = ((b8 &lt;&lt; <span class="tok-number">56</span>) + r3) -% (qmul3 + c3);</span>
<span class="line" id="L799">        <span class="tok-kw">const</span> c4 = b8;</span>
<span class="line" id="L800">        <span class="tok-kw">const</span> t311 = t1015;</span>
<span class="line" id="L801">        <span class="tok-kw">const</span> b9 = (r4 -% (qmul4 + c4)) &gt;&gt; <span class="tok-number">63</span>;</span>
<span class="line" id="L802">        <span class="tok-kw">const</span> t1016 = ((b9 &lt;&lt; <span class="tok-number">40</span>) + r4) -% (qmul4 + c4);</span>
<span class="line" id="L803">        <span class="tok-kw">const</span> t412 = t1016;</span>
<span class="line" id="L804">        <span class="tok-kw">const</span> s0 = t011;</span>
<span class="line" id="L805">        <span class="tok-kw">const</span> s1 = t111;</span>
<span class="line" id="L806">        <span class="tok-kw">const</span> s2 = t211;</span>
<span class="line" id="L807">        <span class="tok-kw">const</span> s3 = t311;</span>
<span class="line" id="L808">        <span class="tok-kw">const</span> s4 = t412;</span>
<span class="line" id="L809"></span>
<span class="line" id="L810">        <span class="tok-kw">const</span> y0: <span class="tok-type">u64</span> = <span class="tok-number">5175514460705773</span>;</span>
<span class="line" id="L811">        <span class="tok-kw">const</span> y1: <span class="tok-type">u64</span> = <span class="tok-number">70332060721272408</span>;</span>
<span class="line" id="L812">        <span class="tok-kw">const</span> y2: <span class="tok-type">u64</span> = <span class="tok-number">5342</span>;</span>
<span class="line" id="L813">        <span class="tok-kw">const</span> y3: <span class="tok-type">u64</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L814">        <span class="tok-kw">const</span> y4: <span class="tok-type">u64</span> = <span class="tok-number">268435456</span>;</span>
<span class="line" id="L815"></span>
<span class="line" id="L816">        <span class="tok-kw">const</span> b10 = (s0 -% y0) &gt;&gt; <span class="tok-number">63</span>;</span>
<span class="line" id="L817">        <span class="tok-kw">const</span> t1017 = ((b10 &lt;&lt; <span class="tok-number">56</span>) + s0) -% y0;</span>
<span class="line" id="L818">        <span class="tok-kw">const</span> b0 = b10;</span>
<span class="line" id="L819">        <span class="tok-kw">const</span> t01 = t1017;</span>
<span class="line" id="L820">        <span class="tok-kw">const</span> b11 = (s1 -% (y1 + b0)) &gt;&gt; <span class="tok-number">63</span>;</span>
<span class="line" id="L821">        <span class="tok-kw">const</span> t1018 = ((b11 &lt;&lt; <span class="tok-number">56</span>) + s1) -% (y1 + b0);</span>
<span class="line" id="L822">        <span class="tok-kw">const</span> b1 = b11;</span>
<span class="line" id="L823">        <span class="tok-kw">const</span> t11 = t1018;</span>
<span class="line" id="L824">        <span class="tok-kw">const</span> b12 = (s2 -% (y2 + b1)) &gt;&gt; <span class="tok-number">63</span>;</span>
<span class="line" id="L825">        <span class="tok-kw">const</span> t1019 = ((b12 &lt;&lt; <span class="tok-number">56</span>) + s2) -% (y2 + b1);</span>
<span class="line" id="L826">        <span class="tok-kw">const</span> b2 = b12;</span>
<span class="line" id="L827">        <span class="tok-kw">const</span> t21 = t1019;</span>
<span class="line" id="L828">        <span class="tok-kw">const</span> b13 = (s3 -% (y3 + b2)) &gt;&gt; <span class="tok-number">63</span>;</span>
<span class="line" id="L829">        <span class="tok-kw">const</span> t1020 = ((b13 &lt;&lt; <span class="tok-number">56</span>) + s3) -% (y3 + b2);</span>
<span class="line" id="L830">        <span class="tok-kw">const</span> b3 = b13;</span>
<span class="line" id="L831">        <span class="tok-kw">const</span> t31 = t1020;</span>
<span class="line" id="L832">        <span class="tok-kw">const</span> b = (s4 -% (y4 + b3)) &gt;&gt; <span class="tok-number">63</span>;</span>
<span class="line" id="L833">        <span class="tok-kw">const</span> t10 = ((b &lt;&lt; <span class="tok-number">56</span>) + s4) -% (y4 + b3);</span>
<span class="line" id="L834">        <span class="tok-kw">const</span> b4 = b;</span>
<span class="line" id="L835">        <span class="tok-kw">const</span> t41 = t10;</span>
<span class="line" id="L836">        <span class="tok-kw">const</span> mask = b4 -% <span class="tok-builtin">@as</span>(<span class="tok-type">u64</span>, <span class="tok-builtin">@as</span>(<span class="tok-type">u64</span>, <span class="tok-number">1</span>));</span>
<span class="line" id="L837">        <span class="tok-kw">const</span> z03 = s0 ^ (mask &amp; (s0 ^ t01));</span>
<span class="line" id="L838">        <span class="tok-kw">const</span> z13 = s1 ^ (mask &amp; (s1 ^ t11));</span>
<span class="line" id="L839">        <span class="tok-kw">const</span> z23 = s2 ^ (mask &amp; (s2 ^ t21));</span>
<span class="line" id="L840">        <span class="tok-kw">const</span> z33 = s3 ^ (mask &amp; (s3 ^ t31));</span>
<span class="line" id="L841">        <span class="tok-kw">const</span> z43 = s4 ^ (mask &amp; (s4 ^ t41));</span>
<span class="line" id="L842"></span>
<span class="line" id="L843">        <span class="tok-kw">return</span> Scalar{ .limbs = .{ z03, z13, z23, z33, z43 } };</span>
<span class="line" id="L844">    }</span>
<span class="line" id="L845">};</span>
<span class="line" id="L846"></span>
<span class="line" id="L847"><span class="tok-kw">test</span> <span class="tok-str">&quot;scalar25519&quot;</span> {</span>
<span class="line" id="L848">    <span class="tok-kw">const</span> bytes: [<span class="tok-number">32</span>]<span class="tok-type">u8</span> = .{ <span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">4</span>, <span class="tok-number">5</span>, <span class="tok-number">6</span>, <span class="tok-number">7</span>, <span class="tok-number">8</span>, <span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">4</span>, <span class="tok-number">5</span>, <span class="tok-number">6</span>, <span class="tok-number">7</span>, <span class="tok-number">8</span>, <span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">4</span>, <span class="tok-number">5</span>, <span class="tok-number">6</span>, <span class="tok-number">7</span>, <span class="tok-number">8</span>, <span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">4</span>, <span class="tok-number">5</span>, <span class="tok-number">6</span>, <span class="tok-number">7</span>, <span class="tok-number">255</span> };</span>
<span class="line" id="L849">    <span class="tok-kw">var</span> x = Scalar.fromBytes(bytes);</span>
<span class="line" id="L850">    <span class="tok-kw">var</span> y = x.toBytes();</span>
<span class="line" id="L851">    <span class="tok-kw">try</span> rejectNonCanonical(y);</span>
<span class="line" id="L852">    <span class="tok-kw">var</span> buf: [<span class="tok-number">128</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L853">    <span class="tok-kw">try</span> std.testing.expectEqualStrings(<span class="tok-kw">try</span> std.fmt.bufPrint(&amp;buf, <span class="tok-str">&quot;{s}&quot;</span>, .{std.fmt.fmtSliceHexUpper(&amp;y)}), <span class="tok-str">&quot;1E979B917937F3DE71D18077F961F6CEFF01030405060708010203040506070F&quot;</span>);</span>
<span class="line" id="L854"></span>
<span class="line" id="L855">    <span class="tok-kw">const</span> reduced = reduce(field_order_s);</span>
<span class="line" id="L856">    <span class="tok-kw">try</span> std.testing.expectEqualStrings(<span class="tok-kw">try</span> std.fmt.bufPrint(&amp;buf, <span class="tok-str">&quot;{s}&quot;</span>, .{std.fmt.fmtSliceHexUpper(&amp;reduced)}), <span class="tok-str">&quot;0000000000000000000000000000000000000000000000000000000000000000&quot;</span>);</span>
<span class="line" id="L857">}</span>
<span class="line" id="L858"></span>
<span class="line" id="L859"><span class="tok-kw">test</span> <span class="tok-str">&quot;non-canonical scalar25519&quot;</span> {</span>
<span class="line" id="L860">    <span class="tok-kw">const</span> too_targe: [<span class="tok-number">32</span>]<span class="tok-type">u8</span> = .{ <span class="tok-number">0xed</span>, <span class="tok-number">0xd3</span>, <span class="tok-number">0xf5</span>, <span class="tok-number">0x5c</span>, <span class="tok-number">0x1a</span>, <span class="tok-number">0x63</span>, <span class="tok-number">0x12</span>, <span class="tok-number">0x58</span>, <span class="tok-number">0xd6</span>, <span class="tok-number">0x9c</span>, <span class="tok-number">0xf7</span>, <span class="tok-number">0xa2</span>, <span class="tok-number">0xde</span>, <span class="tok-number">0xf9</span>, <span class="tok-number">0xde</span>, <span class="tok-number">0x14</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x10</span> };</span>
<span class="line" id="L861">    <span class="tok-kw">try</span> std.testing.expectError(<span class="tok-kw">error</span>.NonCanonical, rejectNonCanonical(too_targe));</span>
<span class="line" id="L862">}</span>
<span class="line" id="L863"></span>
<span class="line" id="L864"><span class="tok-kw">test</span> <span class="tok-str">&quot;mulAdd overflow check&quot;</span> {</span>
<span class="line" id="L865">    <span class="tok-kw">const</span> a: [<span class="tok-number">32</span>]<span class="tok-type">u8</span> = [_]<span class="tok-type">u8</span>{<span class="tok-number">0xff</span>} ** <span class="tok-number">32</span>;</span>
<span class="line" id="L866">    <span class="tok-kw">const</span> b: [<span class="tok-number">32</span>]<span class="tok-type">u8</span> = [_]<span class="tok-type">u8</span>{<span class="tok-number">0xff</span>} ** <span class="tok-number">32</span>;</span>
<span class="line" id="L867">    <span class="tok-kw">const</span> c: [<span class="tok-number">32</span>]<span class="tok-type">u8</span> = [_]<span class="tok-type">u8</span>{<span class="tok-number">0xff</span>} ** <span class="tok-number">32</span>;</span>
<span class="line" id="L868">    <span class="tok-kw">const</span> x = mulAdd(a, b, c);</span>
<span class="line" id="L869">    <span class="tok-kw">var</span> buf: [<span class="tok-number">128</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L870">    <span class="tok-kw">try</span> std.testing.expectEqualStrings(<span class="tok-kw">try</span> std.fmt.bufPrint(&amp;buf, <span class="tok-str">&quot;{s}&quot;</span>, .{std.fmt.fmtSliceHexUpper(&amp;x)}), <span class="tok-str">&quot;D14DF91389432C25AD60FF9791B9FD1D67BEF517D273ECCE3D9A307C1B419903&quot;</span>);</span>
<span class="line" id="L871">}</span>
<span class="line" id="L872"></span>
<span class="line" id="L873"><span class="tok-kw">test</span> <span class="tok-str">&quot;scalar field inversion&quot;</span> {</span>
<span class="line" id="L874">    <span class="tok-kw">const</span> bytes: [<span class="tok-number">32</span>]<span class="tok-type">u8</span> = .{ <span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">4</span>, <span class="tok-number">5</span>, <span class="tok-number">6</span>, <span class="tok-number">7</span>, <span class="tok-number">8</span>, <span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">4</span>, <span class="tok-number">5</span>, <span class="tok-number">6</span>, <span class="tok-number">7</span>, <span class="tok-number">8</span>, <span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">4</span>, <span class="tok-number">5</span>, <span class="tok-number">6</span>, <span class="tok-number">7</span>, <span class="tok-number">8</span>, <span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">4</span>, <span class="tok-number">5</span>, <span class="tok-number">6</span>, <span class="tok-number">7</span>, <span class="tok-number">8</span> };</span>
<span class="line" id="L875">    <span class="tok-kw">const</span> x = Scalar.fromBytes(bytes);</span>
<span class="line" id="L876">    <span class="tok-kw">const</span> inv = x.invert();</span>
<span class="line" id="L877">    <span class="tok-kw">const</span> recovered_x = inv.invert();</span>
<span class="line" id="L878">    <span class="tok-kw">try</span> std.testing.expectEqualSlices(<span class="tok-type">u8</span>, &amp;bytes, &amp;recovered_x.toBytes());</span>
<span class="line" id="L879">}</span>
<span class="line" id="L880"></span>
<span class="line" id="L881"><span class="tok-kw">test</span> <span class="tok-str">&quot;random scalar&quot;</span> {</span>
<span class="line" id="L882">    <span class="tok-kw">const</span> s1 = random();</span>
<span class="line" id="L883">    <span class="tok-kw">const</span> s2 = random();</span>
<span class="line" id="L884">    <span class="tok-kw">try</span> std.testing.expect(!mem.eql(<span class="tok-type">u8</span>, &amp;s1, &amp;s2));</span>
<span class="line" id="L885">}</span>
<span class="line" id="L886"></span>
<span class="line" id="L887"><span class="tok-kw">test</span> <span class="tok-str">&quot;64-bit reduction&quot;</span> {</span>
<span class="line" id="L888">    <span class="tok-kw">const</span> bytes = field_order_s ++ [_]<span class="tok-type">u8</span>{<span class="tok-number">0</span>} ** <span class="tok-number">32</span>;</span>
<span class="line" id="L889">    <span class="tok-kw">const</span> x = Scalar.fromBytes64(bytes);</span>
<span class="line" id="L890">    <span class="tok-kw">try</span> std.testing.expect(x.isZero());</span>
<span class="line" id="L891">}</span>
<span class="line" id="L892"></span>
</code></pre></body>
</html>