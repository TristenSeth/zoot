<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">    <title>crypto/pcurves/secp256k1.zig - source view</title>
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
<span class="line" id="L3"><span class="tok-kw">const</span> math = std.math;</span>
<span class="line" id="L4"><span class="tok-kw">const</span> mem = std.mem;</span>
<span class="line" id="L5"><span class="tok-kw">const</span> meta = std.meta;</span>
<span class="line" id="L6"></span>
<span class="line" id="L7"><span class="tok-kw">const</span> EncodingError = crypto.errors.EncodingError;</span>
<span class="line" id="L8"><span class="tok-kw">const</span> IdentityElementError = crypto.errors.IdentityElementError;</span>
<span class="line" id="L9"><span class="tok-kw">const</span> NonCanonicalError = crypto.errors.NonCanonicalError;</span>
<span class="line" id="L10"><span class="tok-kw">const</span> NotSquareError = crypto.errors.NotSquareError;</span>
<span class="line" id="L11"></span>
<span class="line" id="L12"><span class="tok-comment">/// Group operations over secp256k1.</span></span>
<span class="line" id="L13"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> Secp256k1 = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L14">    <span class="tok-comment">/// The underlying prime field.</span></span>
<span class="line" id="L15">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> Fe = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;secp256k1/field.zig&quot;</span>).Fe;</span>
<span class="line" id="L16">    <span class="tok-comment">/// Field arithmetic mod the order of the main subgroup.</span></span>
<span class="line" id="L17">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> scalar = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;secp256k1/scalar.zig&quot;</span>);</span>
<span class="line" id="L18"></span>
<span class="line" id="L19">    x: Fe,</span>
<span class="line" id="L20">    y: Fe,</span>
<span class="line" id="L21">    z: Fe = Fe.one,</span>
<span class="line" id="L22"></span>
<span class="line" id="L23">    is_base: <span class="tok-type">bool</span> = <span class="tok-null">false</span>,</span>
<span class="line" id="L24"></span>
<span class="line" id="L25">    <span class="tok-comment">/// The secp256k1 base point.</span></span>
<span class="line" id="L26">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> basePoint = Secp256k1{</span>
<span class="line" id="L27">        .x = Fe.fromInt(<span class="tok-number">55066263022277343669578718895168534326250603453777594175500187360389116729240</span>) <span class="tok-kw">catch</span> <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L28">        .y = Fe.fromInt(<span class="tok-number">32670510020758816978083085130507043184471273380659243275938904335757337482424</span>) <span class="tok-kw">catch</span> <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L29">        .z = Fe.one,</span>
<span class="line" id="L30">        .is_base = <span class="tok-null">true</span>,</span>
<span class="line" id="L31">    };</span>
<span class="line" id="L32"></span>
<span class="line" id="L33">    <span class="tok-comment">/// The secp256k1 neutral element.</span></span>
<span class="line" id="L34">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> identityElement = Secp256k1{ .x = Fe.zero, .y = Fe.one, .z = Fe.zero };</span>
<span class="line" id="L35"></span>
<span class="line" id="L36">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> B = Fe.fromInt(<span class="tok-number">7</span>) <span class="tok-kw">catch</span> <span class="tok-kw">unreachable</span>;</span>
<span class="line" id="L37"></span>
<span class="line" id="L38">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> Endormorphism = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L39">        <span class="tok-kw">const</span> lambda: <span class="tok-type">u256</span> = <span class="tok-number">37718080363155996902926221483475020450927657555482586988616620542887997980018</span>;</span>
<span class="line" id="L40">        <span class="tok-kw">const</span> beta: <span class="tok-type">u256</span> = <span class="tok-number">55594575648329892869085402983802832744385952214688224221778511981742606582254</span>;</span>
<span class="line" id="L41"></span>
<span class="line" id="L42">        <span class="tok-kw">const</span> lambda_s = s: {</span>
<span class="line" id="L43">            <span class="tok-kw">var</span> buf: [<span class="tok-number">32</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L44">            mem.writeIntLittle(<span class="tok-type">u256</span>, &amp;buf, Endormorphism.lambda);</span>
<span class="line" id="L45">            <span class="tok-kw">break</span> :s buf;</span>
<span class="line" id="L46">        };</span>
<span class="line" id="L47"></span>
<span class="line" id="L48">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> SplitScalar = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L49">            r1: [<span class="tok-number">32</span>]<span class="tok-type">u8</span>,</span>
<span class="line" id="L50">            r2: [<span class="tok-number">32</span>]<span class="tok-type">u8</span>,</span>
<span class="line" id="L51">        };</span>
<span class="line" id="L52"></span>
<span class="line" id="L53">        <span class="tok-comment">/// Compute r1 and r2 so that k = r1 + r2*lambda (mod L).</span></span>
<span class="line" id="L54">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">splitScalar</span>(s: [<span class="tok-number">32</span>]<span class="tok-type">u8</span>, endian: std.builtin.Endian) SplitScalar {</span>
<span class="line" id="L55">            <span class="tok-kw">const</span> b1_neg_s = <span class="tok-kw">comptime</span> s: {</span>
<span class="line" id="L56">                <span class="tok-kw">var</span> buf: [<span class="tok-number">32</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L57">                mem.writeIntLittle(<span class="tok-type">u256</span>, &amp;buf, <span class="tok-number">303414439467246543595250775667605759171</span>);</span>
<span class="line" id="L58">                <span class="tok-kw">break</span> :s buf;</span>
<span class="line" id="L59">            };</span>
<span class="line" id="L60">            <span class="tok-kw">const</span> b2_neg_s = <span class="tok-kw">comptime</span> s: {</span>
<span class="line" id="L61">                <span class="tok-kw">var</span> buf: [<span class="tok-number">32</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L62">                mem.writeIntLittle(<span class="tok-type">u256</span>, &amp;buf, scalar.field_order - <span class="tok-number">64502973549206556628585045361533709077</span>);</span>
<span class="line" id="L63">                <span class="tok-kw">break</span> :s buf;</span>
<span class="line" id="L64">            };</span>
<span class="line" id="L65">            <span class="tok-kw">const</span> k = mem.readInt(<span class="tok-type">u256</span>, &amp;s, endian);</span>
<span class="line" id="L66"></span>
<span class="line" id="L67">            <span class="tok-kw">const</span> t1 = math.mulWide(<span class="tok-type">u256</span>, k, <span class="tok-number">21949224512762693861512883645436906316123769664773102907882521278123970637873</span>);</span>
<span class="line" id="L68">            <span class="tok-kw">const</span> t2 = math.mulWide(<span class="tok-type">u256</span>, k, <span class="tok-number">103246583619904461035481197785446227098457807945486720222659797044629401272177</span>);</span>
<span class="line" id="L69"></span>
<span class="line" id="L70">            <span class="tok-kw">const</span> c1 = <span class="tok-builtin">@truncate</span>(<span class="tok-type">u128</span>, t1 &gt;&gt; <span class="tok-number">384</span>) + <span class="tok-builtin">@truncate</span>(<span class="tok-type">u1</span>, t1 &gt;&gt; <span class="tok-number">383</span>);</span>
<span class="line" id="L71">            <span class="tok-kw">const</span> c2 = <span class="tok-builtin">@truncate</span>(<span class="tok-type">u128</span>, t2 &gt;&gt; <span class="tok-number">384</span>) + <span class="tok-builtin">@truncate</span>(<span class="tok-type">u1</span>, t2 &gt;&gt; <span class="tok-number">383</span>);</span>
<span class="line" id="L72"></span>
<span class="line" id="L73">            <span class="tok-kw">var</span> buf: [<span class="tok-number">32</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L74"></span>
<span class="line" id="L75">            mem.writeIntLittle(<span class="tok-type">u256</span>, &amp;buf, c1);</span>
<span class="line" id="L76">            <span class="tok-kw">const</span> c1x = scalar.mul(buf, b1_neg_s, .Little) <span class="tok-kw">catch</span> <span class="tok-kw">unreachable</span>;</span>
<span class="line" id="L77"></span>
<span class="line" id="L78">            mem.writeIntLittle(<span class="tok-type">u256</span>, &amp;buf, c2);</span>
<span class="line" id="L79">            <span class="tok-kw">const</span> c2x = scalar.mul(buf, b2_neg_s, .Little) <span class="tok-kw">catch</span> <span class="tok-kw">unreachable</span>;</span>
<span class="line" id="L80"></span>
<span class="line" id="L81">            <span class="tok-kw">const</span> r2 = scalar.add(c1x, c2x, .Little) <span class="tok-kw">catch</span> <span class="tok-kw">unreachable</span>;</span>
<span class="line" id="L82"></span>
<span class="line" id="L83">            <span class="tok-kw">var</span> r1 = scalar.mul(r2, lambda_s, .Little) <span class="tok-kw">catch</span> <span class="tok-kw">unreachable</span>;</span>
<span class="line" id="L84">            r1 = scalar.sub(s, r1, .Little) <span class="tok-kw">catch</span> <span class="tok-kw">unreachable</span>;</span>
<span class="line" id="L85"></span>
<span class="line" id="L86">            <span class="tok-kw">return</span> SplitScalar{ .r1 = r1, .r2 = r2 };</span>
<span class="line" id="L87">        }</span>
<span class="line" id="L88">    };</span>
<span class="line" id="L89"></span>
<span class="line" id="L90">    <span class="tok-comment">/// Reject the neutral element.</span></span>
<span class="line" id="L91">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">rejectIdentity</span>(p: Secp256k1) IdentityElementError!<span class="tok-type">void</span> {</span>
<span class="line" id="L92">        <span class="tok-kw">if</span> (p.x.isZero()) {</span>
<span class="line" id="L93">            <span class="tok-kw">return</span> <span class="tok-kw">error</span>.IdentityElement;</span>
<span class="line" id="L94">        }</span>
<span class="line" id="L95">    }</span>
<span class="line" id="L96"></span>
<span class="line" id="L97">    <span class="tok-comment">/// Create a point from affine coordinates after checking that they match the curve equation.</span></span>
<span class="line" id="L98">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">fromAffineCoordinates</span>(p: AffineCoordinates) EncodingError!Secp256k1 {</span>
<span class="line" id="L99">        <span class="tok-kw">const</span> x = p.x;</span>
<span class="line" id="L100">        <span class="tok-kw">const</span> y = p.y;</span>
<span class="line" id="L101">        <span class="tok-kw">const</span> x3B = x.sq().mul(x).add(B);</span>
<span class="line" id="L102">        <span class="tok-kw">const</span> yy = y.sq();</span>
<span class="line" id="L103">        <span class="tok-kw">const</span> on_curve = <span class="tok-builtin">@boolToInt</span>(x3B.equivalent(yy));</span>
<span class="line" id="L104">        <span class="tok-kw">const</span> is_identity = <span class="tok-builtin">@boolToInt</span>(x.equivalent(AffineCoordinates.identityElement.x)) &amp; <span class="tok-builtin">@boolToInt</span>(y.equivalent(AffineCoordinates.identityElement.y));</span>
<span class="line" id="L105">        <span class="tok-kw">if</span> ((on_curve | is_identity) == <span class="tok-number">0</span>) {</span>
<span class="line" id="L106">            <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InvalidEncoding;</span>
<span class="line" id="L107">        }</span>
<span class="line" id="L108">        <span class="tok-kw">var</span> ret = Secp256k1{ .x = x, .y = y, .z = Fe.one };</span>
<span class="line" id="L109">        ret.z.cMov(Secp256k1.identityElement.z, is_identity);</span>
<span class="line" id="L110">        <span class="tok-kw">return</span> ret;</span>
<span class="line" id="L111">    }</span>
<span class="line" id="L112"></span>
<span class="line" id="L113">    <span class="tok-comment">/// Create a point from serialized affine coordinates.</span></span>
<span class="line" id="L114">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">fromSerializedAffineCoordinates</span>(xs: [<span class="tok-number">32</span>]<span class="tok-type">u8</span>, ys: [<span class="tok-number">32</span>]<span class="tok-type">u8</span>, endian: std.builtin.Endian) (NonCanonicalError || EncodingError)!Secp256k1 {</span>
<span class="line" id="L115">        <span class="tok-kw">const</span> x = <span class="tok-kw">try</span> Fe.fromBytes(xs, endian);</span>
<span class="line" id="L116">        <span class="tok-kw">const</span> y = <span class="tok-kw">try</span> Fe.fromBytes(ys, endian);</span>
<span class="line" id="L117">        <span class="tok-kw">return</span> fromAffineCoordinates(.{ .x = x, .y = y });</span>
<span class="line" id="L118">    }</span>
<span class="line" id="L119"></span>
<span class="line" id="L120">    <span class="tok-comment">/// Recover the Y coordinate from the X coordinate.</span></span>
<span class="line" id="L121">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">recoverY</span>(x: Fe, is_odd: <span class="tok-type">bool</span>) NotSquareError!Fe {</span>
<span class="line" id="L122">        <span class="tok-kw">const</span> x3B = x.sq().mul(x).add(B);</span>
<span class="line" id="L123">        <span class="tok-kw">var</span> y = <span class="tok-kw">try</span> x3B.sqrt();</span>
<span class="line" id="L124">        <span class="tok-kw">const</span> yn = y.neg();</span>
<span class="line" id="L125">        y.cMov(yn, <span class="tok-builtin">@boolToInt</span>(is_odd) ^ <span class="tok-builtin">@boolToInt</span>(y.isOdd()));</span>
<span class="line" id="L126">        <span class="tok-kw">return</span> y;</span>
<span class="line" id="L127">    }</span>
<span class="line" id="L128"></span>
<span class="line" id="L129">    <span class="tok-comment">/// Deserialize a SEC1-encoded point.</span></span>
<span class="line" id="L130">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">fromSec1</span>(s: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) (EncodingError || NotSquareError || NonCanonicalError)!Secp256k1 {</span>
<span class="line" id="L131">        <span class="tok-kw">if</span> (s.len &lt; <span class="tok-number">1</span>) <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InvalidEncoding;</span>
<span class="line" id="L132">        <span class="tok-kw">const</span> encoding_type = s[<span class="tok-number">0</span>];</span>
<span class="line" id="L133">        <span class="tok-kw">const</span> encoded = s[<span class="tok-number">1</span>..];</span>
<span class="line" id="L134">        <span class="tok-kw">switch</span> (encoding_type) {</span>
<span class="line" id="L135">            <span class="tok-number">0</span> =&gt; {</span>
<span class="line" id="L136">                <span class="tok-kw">if</span> (encoded.len != <span class="tok-number">0</span>) <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InvalidEncoding;</span>
<span class="line" id="L137">                <span class="tok-kw">return</span> Secp256k1.identityElement;</span>
<span class="line" id="L138">            },</span>
<span class="line" id="L139">            <span class="tok-number">2</span>, <span class="tok-number">3</span> =&gt; {</span>
<span class="line" id="L140">                <span class="tok-kw">if</span> (encoded.len != <span class="tok-number">32</span>) <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InvalidEncoding;</span>
<span class="line" id="L141">                <span class="tok-kw">const</span> x = <span class="tok-kw">try</span> Fe.fromBytes(encoded[<span class="tok-number">0</span>..<span class="tok-number">32</span>].*, .Big);</span>
<span class="line" id="L142">                <span class="tok-kw">const</span> y_is_odd = (encoding_type == <span class="tok-number">3</span>);</span>
<span class="line" id="L143">                <span class="tok-kw">const</span> y = <span class="tok-kw">try</span> recoverY(x, y_is_odd);</span>
<span class="line" id="L144">                <span class="tok-kw">return</span> Secp256k1{ .x = x, .y = y };</span>
<span class="line" id="L145">            },</span>
<span class="line" id="L146">            <span class="tok-number">4</span> =&gt; {</span>
<span class="line" id="L147">                <span class="tok-kw">if</span> (encoded.len != <span class="tok-number">64</span>) <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InvalidEncoding;</span>
<span class="line" id="L148">                <span class="tok-kw">const</span> x = <span class="tok-kw">try</span> Fe.fromBytes(encoded[<span class="tok-number">0</span>..<span class="tok-number">32</span>].*, .Big);</span>
<span class="line" id="L149">                <span class="tok-kw">const</span> y = <span class="tok-kw">try</span> Fe.fromBytes(encoded[<span class="tok-number">32</span>..<span class="tok-number">64</span>].*, .Big);</span>
<span class="line" id="L150">                <span class="tok-kw">return</span> Secp256k1.fromAffineCoordinates(.{ .x = x, .y = y });</span>
<span class="line" id="L151">            },</span>
<span class="line" id="L152">            <span class="tok-kw">else</span> =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InvalidEncoding,</span>
<span class="line" id="L153">        }</span>
<span class="line" id="L154">    }</span>
<span class="line" id="L155"></span>
<span class="line" id="L156">    <span class="tok-comment">/// Serialize a point using the compressed SEC-1 format.</span></span>
<span class="line" id="L157">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">toCompressedSec1</span>(p: Secp256k1) [<span class="tok-number">33</span>]<span class="tok-type">u8</span> {</span>
<span class="line" id="L158">        <span class="tok-kw">var</span> out: [<span class="tok-number">33</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L159">        <span class="tok-kw">const</span> xy = p.affineCoordinates();</span>
<span class="line" id="L160">        out[<span class="tok-number">0</span>] = <span class="tok-kw">if</span> (xy.y.isOdd()) <span class="tok-number">3</span> <span class="tok-kw">else</span> <span class="tok-number">2</span>;</span>
<span class="line" id="L161">        mem.copy(<span class="tok-type">u8</span>, out[<span class="tok-number">1</span>..], &amp;xy.x.toBytes(.Big));</span>
<span class="line" id="L162">        <span class="tok-kw">return</span> out;</span>
<span class="line" id="L163">    }</span>
<span class="line" id="L164"></span>
<span class="line" id="L165">    <span class="tok-comment">/// Serialize a point using the uncompressed SEC-1 format.</span></span>
<span class="line" id="L166">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">toUncompressedSec1</span>(p: Secp256k1) [<span class="tok-number">65</span>]<span class="tok-type">u8</span> {</span>
<span class="line" id="L167">        <span class="tok-kw">var</span> out: [<span class="tok-number">65</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L168">        out[<span class="tok-number">0</span>] = <span class="tok-number">4</span>;</span>
<span class="line" id="L169">        <span class="tok-kw">const</span> xy = p.affineCoordinates();</span>
<span class="line" id="L170">        mem.copy(<span class="tok-type">u8</span>, out[<span class="tok-number">1</span>..<span class="tok-number">33</span>], &amp;xy.x.toBytes(.Big));</span>
<span class="line" id="L171">        mem.copy(<span class="tok-type">u8</span>, out[<span class="tok-number">33</span>..<span class="tok-number">65</span>], &amp;xy.y.toBytes(.Big));</span>
<span class="line" id="L172">        <span class="tok-kw">return</span> out;</span>
<span class="line" id="L173">    }</span>
<span class="line" id="L174"></span>
<span class="line" id="L175">    <span class="tok-comment">/// Return a random point.</span></span>
<span class="line" id="L176">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">random</span>() Secp256k1 {</span>
<span class="line" id="L177">        <span class="tok-kw">const</span> n = scalar.random(.Little);</span>
<span class="line" id="L178">        <span class="tok-kw">return</span> basePoint.mul(n, .Little) <span class="tok-kw">catch</span> <span class="tok-kw">unreachable</span>;</span>
<span class="line" id="L179">    }</span>
<span class="line" id="L180"></span>
<span class="line" id="L181">    <span class="tok-comment">/// Flip the sign of the X coordinate.</span></span>
<span class="line" id="L182">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">neg</span>(p: Secp256k1) Secp256k1 {</span>
<span class="line" id="L183">        <span class="tok-kw">return</span> .{ .x = p.x, .y = p.y.neg(), .z = p.z };</span>
<span class="line" id="L184">    }</span>
<span class="line" id="L185"></span>
<span class="line" id="L186">    <span class="tok-comment">/// Double a secp256k1 point.</span></span>
<span class="line" id="L187">    <span class="tok-comment">// Algorithm 9 from https://eprint.iacr.org/2015/1060.pdf</span>
</span>
<span class="line" id="L188">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">dbl</span>(p: Secp256k1) Secp256k1 {</span>
<span class="line" id="L189">        <span class="tok-kw">var</span> t0 = p.y.sq();</span>
<span class="line" id="L190">        <span class="tok-kw">var</span> Z3 = t0.dbl();</span>
<span class="line" id="L191">        Z3 = Z3.dbl();</span>
<span class="line" id="L192">        Z3 = Z3.dbl();</span>
<span class="line" id="L193">        <span class="tok-kw">var</span> t1 = p.y.mul(p.z);</span>
<span class="line" id="L194">        <span class="tok-kw">var</span> t2 = p.z.sq();</span>
<span class="line" id="L195">        <span class="tok-comment">// b3 = (2^2)^2 + 2^2 + 1</span>
</span>
<span class="line" id="L196">        <span class="tok-kw">const</span> t2_4 = t2.dbl().dbl();</span>
<span class="line" id="L197">        t2 = t2_4.dbl().dbl().add(t2_4).add(t2);</span>
<span class="line" id="L198">        <span class="tok-kw">var</span> X3 = t2.mul(Z3);</span>
<span class="line" id="L199">        <span class="tok-kw">var</span> Y3 = t0.add(t2);</span>
<span class="line" id="L200">        Z3 = t1.mul(Z3);</span>
<span class="line" id="L201">        t1 = t2.dbl();</span>
<span class="line" id="L202">        t2 = t1.add(t2);</span>
<span class="line" id="L203">        t0 = t0.sub(t2);</span>
<span class="line" id="L204">        Y3 = t0.mul(Y3);</span>
<span class="line" id="L205">        Y3 = X3.add(Y3);</span>
<span class="line" id="L206">        t1 = p.x.mul(p.y);</span>
<span class="line" id="L207">        X3 = t0.mul(t1);</span>
<span class="line" id="L208">        X3 = X3.dbl();</span>
<span class="line" id="L209">        <span class="tok-kw">return</span> .{</span>
<span class="line" id="L210">            .x = X3,</span>
<span class="line" id="L211">            .y = Y3,</span>
<span class="line" id="L212">            .z = Z3,</span>
<span class="line" id="L213">        };</span>
<span class="line" id="L214">    }</span>
<span class="line" id="L215"></span>
<span class="line" id="L216">    <span class="tok-comment">/// Add secp256k1 points, the second being specified using affine coordinates.</span></span>
<span class="line" id="L217">    <span class="tok-comment">// Algorithm 8 from https://eprint.iacr.org/2015/1060.pdf</span>
</span>
<span class="line" id="L218">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">addMixed</span>(p: Secp256k1, q: AffineCoordinates) Secp256k1 {</span>
<span class="line" id="L219">        <span class="tok-kw">var</span> t0 = p.x.mul(q.x);</span>
<span class="line" id="L220">        <span class="tok-kw">var</span> t1 = p.y.mul(q.y);</span>
<span class="line" id="L221">        <span class="tok-kw">var</span> t3 = q.x.add(q.y);</span>
<span class="line" id="L222">        <span class="tok-kw">var</span> t4 = p.x.add(p.y1);</span>
<span class="line" id="L223">        t3 = t3.mul(t4);</span>
<span class="line" id="L224">        t4 = t0.add(t1);</span>
<span class="line" id="L225">        t3 = t3.sub(t4);</span>
<span class="line" id="L226">        t4 = q.y.mul(p.z);</span>
<span class="line" id="L227">        t4 = t4.add(p.y);</span>
<span class="line" id="L228">        <span class="tok-kw">var</span> Y3 = q.x.mul(p.z);</span>
<span class="line" id="L229">        Y3 = Y3.add(p.x);</span>
<span class="line" id="L230">        <span class="tok-kw">var</span> X3 = t0.dbl();</span>
<span class="line" id="L231">        t0 = X3.add(t0);</span>
<span class="line" id="L232">        <span class="tok-comment">// b3 = (2^2)^2 + 2^2 + 1</span>
</span>
<span class="line" id="L233">        <span class="tok-kw">const</span> t2_4 = p.z.dbl().dbl();</span>
<span class="line" id="L234">        <span class="tok-kw">var</span> t2 = t2_4.dbl().dbl().add(t2_4).add(p.z);</span>
<span class="line" id="L235">        <span class="tok-kw">var</span> Z3 = t1.add(t2);</span>
<span class="line" id="L236">        t1 = t1.sub(t2);</span>
<span class="line" id="L237">        <span class="tok-kw">const</span> Y3_4 = Y3.dbl().dbl();</span>
<span class="line" id="L238">        Y3 = Y3_4.dbl().dbl().add(Y3_4).add(Y3);</span>
<span class="line" id="L239">        X3 = t4.mul(Y3);</span>
<span class="line" id="L240">        t2 = t3.mul(t1);</span>
<span class="line" id="L241">        X3 = t2.sub(X3);</span>
<span class="line" id="L242">        Y3 = Y3.mul(t0);</span>
<span class="line" id="L243">        t1 = t1.mul(Z3);</span>
<span class="line" id="L244">        Y3 = t1.add(Y3);</span>
<span class="line" id="L245">        t0 = t0.mul(t3);</span>
<span class="line" id="L246">        Z3 = Z3.mul(t4);</span>
<span class="line" id="L247">        Z3 = Z3.add(t0);</span>
<span class="line" id="L248"></span>
<span class="line" id="L249">        <span class="tok-kw">var</span> ret = Secp256k1{</span>
<span class="line" id="L250">            .x = X3,</span>
<span class="line" id="L251">            .y = Y3,</span>
<span class="line" id="L252">            .z = Z3,</span>
<span class="line" id="L253">        };</span>
<span class="line" id="L254">        ret.cMov(p, <span class="tok-builtin">@boolToInt</span>(q.x.isZero()));</span>
<span class="line" id="L255">        <span class="tok-kw">return</span> ret;</span>
<span class="line" id="L256">    }</span>
<span class="line" id="L257"></span>
<span class="line" id="L258">    <span class="tok-comment">/// Add secp256k1 points.</span></span>
<span class="line" id="L259">    <span class="tok-comment">// Algorithm 7 from https://eprint.iacr.org/2015/1060.pdf</span>
</span>
<span class="line" id="L260">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">add</span>(p: Secp256k1, q: Secp256k1) Secp256k1 {</span>
<span class="line" id="L261">        <span class="tok-kw">var</span> t0 = p.x.mul(q.x);</span>
<span class="line" id="L262">        <span class="tok-kw">var</span> t1 = p.y.mul(q.y);</span>
<span class="line" id="L263">        <span class="tok-kw">var</span> t2 = p.z.mul(q.z);</span>
<span class="line" id="L264">        <span class="tok-kw">var</span> t3 = p.x.add(p.y);</span>
<span class="line" id="L265">        <span class="tok-kw">var</span> t4 = q.x.add(q.y);</span>
<span class="line" id="L266">        t3 = t3.mul(t4);</span>
<span class="line" id="L267">        t4 = t0.add(t1);</span>
<span class="line" id="L268">        t3 = t3.sub(t4);</span>
<span class="line" id="L269">        t4 = p.y.add(p.z);</span>
<span class="line" id="L270">        <span class="tok-kw">var</span> X3 = q.y.add(q.z);</span>
<span class="line" id="L271">        t4 = t4.mul(X3);</span>
<span class="line" id="L272">        X3 = t1.add(t2);</span>
<span class="line" id="L273">        t4 = t4.sub(X3);</span>
<span class="line" id="L274">        X3 = p.x.add(p.z);</span>
<span class="line" id="L275">        <span class="tok-kw">var</span> Y3 = q.x.add(q.z);</span>
<span class="line" id="L276">        X3 = X3.mul(Y3);</span>
<span class="line" id="L277">        Y3 = t0.add(t2);</span>
<span class="line" id="L278">        Y3 = X3.sub(Y3);</span>
<span class="line" id="L279">        X3 = t0.dbl();</span>
<span class="line" id="L280">        t0 = X3.add(t0);</span>
<span class="line" id="L281">        <span class="tok-comment">// b3 = (2^2)^2 + 2^2 + 1</span>
</span>
<span class="line" id="L282">        <span class="tok-kw">const</span> t2_4 = t2.dbl().dbl();</span>
<span class="line" id="L283">        t2 = t2_4.dbl().dbl().add(t2_4).add(t2);</span>
<span class="line" id="L284">        <span class="tok-kw">var</span> Z3 = t1.add(t2);</span>
<span class="line" id="L285">        t1 = t1.sub(t2);</span>
<span class="line" id="L286">        <span class="tok-kw">const</span> Y3_4 = Y3.dbl().dbl();</span>
<span class="line" id="L287">        Y3 = Y3_4.dbl().dbl().add(Y3_4).add(Y3);</span>
<span class="line" id="L288">        X3 = t4.mul(Y3);</span>
<span class="line" id="L289">        t2 = t3.mul(t1);</span>
<span class="line" id="L290">        X3 = t2.sub(X3);</span>
<span class="line" id="L291">        Y3 = Y3.mul(t0);</span>
<span class="line" id="L292">        t1 = t1.mul(Z3);</span>
<span class="line" id="L293">        Y3 = t1.add(Y3);</span>
<span class="line" id="L294">        t0 = t0.mul(t3);</span>
<span class="line" id="L295">        Z3 = Z3.mul(t4);</span>
<span class="line" id="L296">        Z3 = Z3.add(t0);</span>
<span class="line" id="L297"></span>
<span class="line" id="L298">        <span class="tok-kw">return</span> .{</span>
<span class="line" id="L299">            .x = X3,</span>
<span class="line" id="L300">            .y = Y3,</span>
<span class="line" id="L301">            .z = Z3,</span>
<span class="line" id="L302">        };</span>
<span class="line" id="L303">    }</span>
<span class="line" id="L304"></span>
<span class="line" id="L305">    <span class="tok-comment">/// Subtract secp256k1 points.</span></span>
<span class="line" id="L306">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">sub</span>(p: Secp256k1, q: Secp256k1) Secp256k1 {</span>
<span class="line" id="L307">        <span class="tok-kw">return</span> p.add(q.neg());</span>
<span class="line" id="L308">    }</span>
<span class="line" id="L309"></span>
<span class="line" id="L310">    <span class="tok-comment">/// Subtract secp256k1 points, the second being specified using affine coordinates.</span></span>
<span class="line" id="L311">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">subMixed</span>(p: Secp256k1, q: AffineCoordinates) Secp256k1 {</span>
<span class="line" id="L312">        <span class="tok-kw">return</span> p.addMixed(q.neg());</span>
<span class="line" id="L313">    }</span>
<span class="line" id="L314"></span>
<span class="line" id="L315">    <span class="tok-comment">/// Return affine coordinates.</span></span>
<span class="line" id="L316">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">affineCoordinates</span>(p: Secp256k1) AffineCoordinates {</span>
<span class="line" id="L317">        <span class="tok-kw">const</span> zinv = p.z.invert();</span>
<span class="line" id="L318">        <span class="tok-kw">var</span> ret = AffineCoordinates{</span>
<span class="line" id="L319">            .x = p.x.mul(zinv),</span>
<span class="line" id="L320">            .y = p.y.mul(zinv),</span>
<span class="line" id="L321">        };</span>
<span class="line" id="L322">        ret.cMov(AffineCoordinates.identityElement, <span class="tok-builtin">@boolToInt</span>(p.x.isZero()));</span>
<span class="line" id="L323">        <span class="tok-kw">return</span> ret;</span>
<span class="line" id="L324">    }</span>
<span class="line" id="L325"></span>
<span class="line" id="L326">    <span class="tok-comment">/// Return true if both coordinate sets represent the same point.</span></span>
<span class="line" id="L327">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">equivalent</span>(a: Secp256k1, b: Secp256k1) <span class="tok-type">bool</span> {</span>
<span class="line" id="L328">        <span class="tok-kw">if</span> (a.sub(b).rejectIdentity()) {</span>
<span class="line" id="L329">            <span class="tok-kw">return</span> <span class="tok-null">false</span>;</span>
<span class="line" id="L330">        } <span class="tok-kw">else</span> |_| {</span>
<span class="line" id="L331">            <span class="tok-kw">return</span> <span class="tok-null">true</span>;</span>
<span class="line" id="L332">        }</span>
<span class="line" id="L333">    }</span>
<span class="line" id="L334"></span>
<span class="line" id="L335">    <span class="tok-kw">fn</span> <span class="tok-fn">cMov</span>(p: *Secp256k1, a: Secp256k1, c: <span class="tok-type">u1</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L336">        p.x.cMov(a.x, c);</span>
<span class="line" id="L337">        p.y.cMov(a.y, c);</span>
<span class="line" id="L338">        p.z.cMov(a.z, c);</span>
<span class="line" id="L339">    }</span>
<span class="line" id="L340"></span>
<span class="line" id="L341">    <span class="tok-kw">fn</span> <span class="tok-fn">pcSelect</span>(<span class="tok-kw">comptime</span> n: <span class="tok-type">usize</span>, pc: *<span class="tok-kw">const</span> [n]Secp256k1, b: <span class="tok-type">u8</span>) Secp256k1 {</span>
<span class="line" id="L342">        <span class="tok-kw">var</span> t = Secp256k1.identityElement;</span>
<span class="line" id="L343">        <span class="tok-kw">comptime</span> <span class="tok-kw">var</span> i: <span class="tok-type">u8</span> = <span class="tok-number">1</span>;</span>
<span class="line" id="L344">        <span class="tok-kw">inline</span> <span class="tok-kw">while</span> (i &lt; pc.len) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L345">            t.cMov(pc[i], <span class="tok-builtin">@truncate</span>(<span class="tok-type">u1</span>, (<span class="tok-builtin">@as</span>(<span class="tok-type">usize</span>, b ^ i) -% <span class="tok-number">1</span>) &gt;&gt; <span class="tok-number">8</span>));</span>
<span class="line" id="L346">        }</span>
<span class="line" id="L347">        <span class="tok-kw">return</span> t;</span>
<span class="line" id="L348">    }</span>
<span class="line" id="L349"></span>
<span class="line" id="L350">    <span class="tok-kw">fn</span> <span class="tok-fn">slide</span>(s: [<span class="tok-number">32</span>]<span class="tok-type">u8</span>) [<span class="tok-number">2</span> * <span class="tok-number">32</span> + <span class="tok-number">1</span>]<span class="tok-type">i8</span> {</span>
<span class="line" id="L351">        <span class="tok-kw">var</span> e: [<span class="tok-number">2</span> * <span class="tok-number">32</span> + <span class="tok-number">1</span>]<span class="tok-type">i8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L352">        <span class="tok-kw">for</span> (s) |x, i| {</span>
<span class="line" id="L353">            e[i * <span class="tok-number">2</span> + <span class="tok-number">0</span>] = <span class="tok-builtin">@as</span>(<span class="tok-type">i8</span>, <span class="tok-builtin">@truncate</span>(<span class="tok-type">u4</span>, x));</span>
<span class="line" id="L354">            e[i * <span class="tok-number">2</span> + <span class="tok-number">1</span>] = <span class="tok-builtin">@as</span>(<span class="tok-type">i8</span>, <span class="tok-builtin">@truncate</span>(<span class="tok-type">u4</span>, x &gt;&gt; <span class="tok-number">4</span>));</span>
<span class="line" id="L355">        }</span>
<span class="line" id="L356">        <span class="tok-comment">// Now, e[0..63] is between 0 and 15, e[63] is between 0 and 7</span>
</span>
<span class="line" id="L357">        <span class="tok-kw">var</span> carry: <span class="tok-type">i8</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L358">        <span class="tok-kw">for</span> (e[<span class="tok-number">0</span>..<span class="tok-number">64</span>]) |*x| {</span>
<span class="line" id="L359">            x.* += carry;</span>
<span class="line" id="L360">            carry = (x.* + <span class="tok-number">8</span>) &gt;&gt; <span class="tok-number">4</span>;</span>
<span class="line" id="L361">            x.* -= carry * <span class="tok-number">16</span>;</span>
<span class="line" id="L362">            std.debug.assert(x.* &gt;= -<span class="tok-number">8</span> <span class="tok-kw">and</span> x.* &lt;= <span class="tok-number">8</span>);</span>
<span class="line" id="L363">        }</span>
<span class="line" id="L364">        e[<span class="tok-number">64</span>] = carry;</span>
<span class="line" id="L365">        <span class="tok-comment">// Now, e[*] is between -8 and 8, including e[64]</span>
</span>
<span class="line" id="L366">        std.debug.assert(carry &gt;= -<span class="tok-number">8</span> <span class="tok-kw">and</span> carry &lt;= <span class="tok-number">8</span>);</span>
<span class="line" id="L367">        <span class="tok-kw">return</span> e;</span>
<span class="line" id="L368">    }</span>
<span class="line" id="L369"></span>
<span class="line" id="L370">    <span class="tok-kw">fn</span> <span class="tok-fn">pcMul</span>(pc: *<span class="tok-kw">const</span> [<span class="tok-number">9</span>]Secp256k1, s: [<span class="tok-number">32</span>]<span class="tok-type">u8</span>, <span class="tok-kw">comptime</span> vartime: <span class="tok-type">bool</span>) IdentityElementError!Secp256k1 {</span>
<span class="line" id="L371">        std.debug.assert(vartime);</span>
<span class="line" id="L372">        <span class="tok-kw">const</span> e = slide(s);</span>
<span class="line" id="L373">        <span class="tok-kw">var</span> q = Secp256k1.identityElement;</span>
<span class="line" id="L374">        <span class="tok-kw">var</span> pos = e.len - <span class="tok-number">1</span>;</span>
<span class="line" id="L375">        <span class="tok-kw">while</span> (<span class="tok-null">true</span>) : (pos -= <span class="tok-number">1</span>) {</span>
<span class="line" id="L376">            <span class="tok-kw">const</span> slot = e[pos];</span>
<span class="line" id="L377">            <span class="tok-kw">if</span> (slot &gt; <span class="tok-number">0</span>) {</span>
<span class="line" id="L378">                q = q.add(pc[<span class="tok-builtin">@intCast</span>(<span class="tok-type">usize</span>, slot)]);</span>
<span class="line" id="L379">            } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (slot &lt; <span class="tok-number">0</span>) {</span>
<span class="line" id="L380">                q = q.sub(pc[<span class="tok-builtin">@intCast</span>(<span class="tok-type">usize</span>, -slot)]);</span>
<span class="line" id="L381">            }</span>
<span class="line" id="L382">            <span class="tok-kw">if</span> (pos == <span class="tok-number">0</span>) <span class="tok-kw">break</span>;</span>
<span class="line" id="L383">            q = q.dbl().dbl().dbl().dbl();</span>
<span class="line" id="L384">        }</span>
<span class="line" id="L385">        <span class="tok-kw">try</span> q.rejectIdentity();</span>
<span class="line" id="L386">        <span class="tok-kw">return</span> q;</span>
<span class="line" id="L387">    }</span>
<span class="line" id="L388"></span>
<span class="line" id="L389">    <span class="tok-kw">fn</span> <span class="tok-fn">pcMul16</span>(pc: *<span class="tok-kw">const</span> [<span class="tok-number">16</span>]Secp256k1, s: [<span class="tok-number">32</span>]<span class="tok-type">u8</span>, <span class="tok-kw">comptime</span> vartime: <span class="tok-type">bool</span>) IdentityElementError!Secp256k1 {</span>
<span class="line" id="L390">        <span class="tok-kw">var</span> q = Secp256k1.identityElement;</span>
<span class="line" id="L391">        <span class="tok-kw">var</span> pos: <span class="tok-type">usize</span> = <span class="tok-number">252</span>;</span>
<span class="line" id="L392">        <span class="tok-kw">while</span> (<span class="tok-null">true</span>) : (pos -= <span class="tok-number">4</span>) {</span>
<span class="line" id="L393">            <span class="tok-kw">const</span> slot = <span class="tok-builtin">@truncate</span>(<span class="tok-type">u4</span>, (s[pos &gt;&gt; <span class="tok-number">3</span>] &gt;&gt; <span class="tok-builtin">@truncate</span>(<span class="tok-type">u3</span>, pos)));</span>
<span class="line" id="L394">            <span class="tok-kw">if</span> (vartime) {</span>
<span class="line" id="L395">                <span class="tok-kw">if</span> (slot != <span class="tok-number">0</span>) {</span>
<span class="line" id="L396">                    q = q.add(pc[slot]);</span>
<span class="line" id="L397">                }</span>
<span class="line" id="L398">            } <span class="tok-kw">else</span> {</span>
<span class="line" id="L399">                q = q.add(pcSelect(<span class="tok-number">16</span>, pc, slot));</span>
<span class="line" id="L400">            }</span>
<span class="line" id="L401">            <span class="tok-kw">if</span> (pos == <span class="tok-number">0</span>) <span class="tok-kw">break</span>;</span>
<span class="line" id="L402">            q = q.dbl().dbl().dbl().dbl();</span>
<span class="line" id="L403">        }</span>
<span class="line" id="L404">        <span class="tok-kw">try</span> q.rejectIdentity();</span>
<span class="line" id="L405">        <span class="tok-kw">return</span> q;</span>
<span class="line" id="L406">    }</span>
<span class="line" id="L407"></span>
<span class="line" id="L408">    <span class="tok-kw">fn</span> <span class="tok-fn">precompute</span>(p: Secp256k1, <span class="tok-kw">comptime</span> count: <span class="tok-type">usize</span>) [<span class="tok-number">1</span> + count]Secp256k1 {</span>
<span class="line" id="L409">        <span class="tok-kw">var</span> pc: [<span class="tok-number">1</span> + count]Secp256k1 = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L410">        pc[<span class="tok-number">0</span>] = Secp256k1.identityElement;</span>
<span class="line" id="L411">        pc[<span class="tok-number">1</span>] = p;</span>
<span class="line" id="L412">        <span class="tok-kw">var</span> i: <span class="tok-type">usize</span> = <span class="tok-number">2</span>;</span>
<span class="line" id="L413">        <span class="tok-kw">while</span> (i &lt;= count) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L414">            pc[i] = <span class="tok-kw">if</span> (i % <span class="tok-number">2</span> == <span class="tok-number">0</span>) pc[i / <span class="tok-number">2</span>].dbl() <span class="tok-kw">else</span> pc[i - <span class="tok-number">1</span>].add(p);</span>
<span class="line" id="L415">        }</span>
<span class="line" id="L416">        <span class="tok-kw">return</span> pc;</span>
<span class="line" id="L417">    }</span>
<span class="line" id="L418"></span>
<span class="line" id="L419">    <span class="tok-kw">const</span> basePointPc = pc: {</span>
<span class="line" id="L420">        <span class="tok-builtin">@setEvalBranchQuota</span>(<span class="tok-number">50000</span>);</span>
<span class="line" id="L421">        <span class="tok-kw">break</span> :pc precompute(Secp256k1.basePoint, <span class="tok-number">15</span>);</span>
<span class="line" id="L422">    };</span>
<span class="line" id="L423"></span>
<span class="line" id="L424">    <span class="tok-comment">/// Multiply an elliptic curve point by a scalar.</span></span>
<span class="line" id="L425">    <span class="tok-comment">/// Return error.IdentityElement if the result is the identity element.</span></span>
<span class="line" id="L426">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">mul</span>(p: Secp256k1, s_: [<span class="tok-number">32</span>]<span class="tok-type">u8</span>, endian: std.builtin.Endian) IdentityElementError!Secp256k1 {</span>
<span class="line" id="L427">        <span class="tok-kw">const</span> s = <span class="tok-kw">if</span> (endian == .Little) s_ <span class="tok-kw">else</span> Fe.orderSwap(s_);</span>
<span class="line" id="L428">        <span class="tok-kw">if</span> (p.is_base) {</span>
<span class="line" id="L429">            <span class="tok-kw">return</span> pcMul16(&amp;basePointPc, s, <span class="tok-null">false</span>);</span>
<span class="line" id="L430">        }</span>
<span class="line" id="L431">        <span class="tok-kw">try</span> p.rejectIdentity();</span>
<span class="line" id="L432">        <span class="tok-kw">const</span> pc = precompute(p, <span class="tok-number">15</span>);</span>
<span class="line" id="L433">        <span class="tok-kw">return</span> pcMul16(&amp;pc, s, <span class="tok-null">false</span>);</span>
<span class="line" id="L434">    }</span>
<span class="line" id="L435"></span>
<span class="line" id="L436">    <span class="tok-comment">/// Multiply an elliptic curve point by a *PUBLIC* scalar *IN VARIABLE TIME*</span></span>
<span class="line" id="L437">    <span class="tok-comment">/// This can be used for signature verification.</span></span>
<span class="line" id="L438">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">mulPublic</span>(p: Secp256k1, s_: [<span class="tok-number">32</span>]<span class="tok-type">u8</span>, endian: std.builtin.Endian) IdentityElementError!Secp256k1 {</span>
<span class="line" id="L439">        <span class="tok-kw">const</span> s = <span class="tok-kw">if</span> (endian == .Little) s_ <span class="tok-kw">else</span> Fe.orderSwap(s_);</span>
<span class="line" id="L440">        <span class="tok-kw">const</span> zero = <span class="tok-kw">comptime</span> scalar.Scalar.zero.toBytes(.Little);</span>
<span class="line" id="L441">        <span class="tok-kw">if</span> (mem.eql(<span class="tok-type">u8</span>, &amp;zero, &amp;s)) {</span>
<span class="line" id="L442">            <span class="tok-kw">return</span> <span class="tok-kw">error</span>.IdentityElement;</span>
<span class="line" id="L443">        }</span>
<span class="line" id="L444">        <span class="tok-kw">const</span> pc = precompute(p, <span class="tok-number">8</span>);</span>
<span class="line" id="L445">        <span class="tok-kw">var</span> lambda_p = <span class="tok-kw">try</span> pcMul(&amp;pc, Endormorphism.lambda_s, <span class="tok-null">true</span>);</span>
<span class="line" id="L446">        <span class="tok-kw">var</span> split_scalar = Endormorphism.splitScalar(s, .Little);</span>
<span class="line" id="L447">        <span class="tok-kw">var</span> px = p;</span>
<span class="line" id="L448"></span>
<span class="line" id="L449">        <span class="tok-comment">// If a key is negative, flip the sign to keep it half-sized,</span>
</span>
<span class="line" id="L450">        <span class="tok-comment">// and flip the sign of the Y point coordinate to compensate.</span>
</span>
<span class="line" id="L451">        <span class="tok-kw">if</span> (split_scalar.r1[split_scalar.r1.len / <span class="tok-number">2</span>] != <span class="tok-number">0</span>) {</span>
<span class="line" id="L452">            split_scalar.r1 = scalar.neg(split_scalar.r1, .Little) <span class="tok-kw">catch</span> zero;</span>
<span class="line" id="L453">            px = px.neg();</span>
<span class="line" id="L454">        }</span>
<span class="line" id="L455">        <span class="tok-kw">if</span> (split_scalar.r2[split_scalar.r2.len / <span class="tok-number">2</span>] != <span class="tok-number">0</span>) {</span>
<span class="line" id="L456">            split_scalar.r2 = scalar.neg(split_scalar.r2, .Little) <span class="tok-kw">catch</span> zero;</span>
<span class="line" id="L457">            lambda_p = lambda_p.neg();</span>
<span class="line" id="L458">        }</span>
<span class="line" id="L459">        <span class="tok-kw">return</span> mulDoubleBasePublicEndo(px, split_scalar.r1, lambda_p, split_scalar.r2);</span>
<span class="line" id="L460">    }</span>
<span class="line" id="L461"></span>
<span class="line" id="L462">    <span class="tok-comment">// Half-size double-base public multiplication when using the curve endomorphism.</span>
</span>
<span class="line" id="L463">    <span class="tok-comment">// Scalars must be in little-endian.</span>
</span>
<span class="line" id="L464">    <span class="tok-comment">// The second point is unlikely to be the generator, so don't even try to use the comptime table for it.</span>
</span>
<span class="line" id="L465">    <span class="tok-kw">fn</span> <span class="tok-fn">mulDoubleBasePublicEndo</span>(p1: Secp256k1, s1: [<span class="tok-number">32</span>]<span class="tok-type">u8</span>, p2: Secp256k1, s2: [<span class="tok-number">32</span>]<span class="tok-type">u8</span>) IdentityElementError!Secp256k1 {</span>
<span class="line" id="L466">        <span class="tok-kw">var</span> pc1_array: [<span class="tok-number">9</span>]Secp256k1 = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L467">        <span class="tok-kw">const</span> pc1 = <span class="tok-kw">if</span> (p1.is_base) basePointPc[<span class="tok-number">0</span>..<span class="tok-number">9</span>] <span class="tok-kw">else</span> pc: {</span>
<span class="line" id="L468">            pc1_array = precompute(p1, <span class="tok-number">8</span>);</span>
<span class="line" id="L469">            <span class="tok-kw">break</span> :pc &amp;pc1_array;</span>
<span class="line" id="L470">        };</span>
<span class="line" id="L471">        <span class="tok-kw">const</span> pc2 = precompute(p2, <span class="tok-number">8</span>);</span>
<span class="line" id="L472">        std.debug.assert(s1[s1.len / <span class="tok-number">2</span>] == <span class="tok-number">0</span>);</span>
<span class="line" id="L473">        std.debug.assert(s2[s2.len / <span class="tok-number">2</span>] == <span class="tok-number">0</span>);</span>
<span class="line" id="L474">        <span class="tok-kw">const</span> e1 = slide(s1);</span>
<span class="line" id="L475">        <span class="tok-kw">const</span> e2 = slide(s2);</span>
<span class="line" id="L476">        <span class="tok-kw">var</span> q = Secp256k1.identityElement;</span>
<span class="line" id="L477">        <span class="tok-kw">var</span> pos: <span class="tok-type">usize</span> = <span class="tok-number">2</span> * <span class="tok-number">32</span> / <span class="tok-number">2</span>; <span class="tok-comment">// second half is all zero</span>
</span>
<span class="line" id="L478">        <span class="tok-kw">while</span> (<span class="tok-null">true</span>) : (pos -= <span class="tok-number">1</span>) {</span>
<span class="line" id="L479">            <span class="tok-kw">const</span> slot1 = e1[pos];</span>
<span class="line" id="L480">            <span class="tok-kw">if</span> (slot1 &gt; <span class="tok-number">0</span>) {</span>
<span class="line" id="L481">                q = q.add(pc1[<span class="tok-builtin">@intCast</span>(<span class="tok-type">usize</span>, slot1)]);</span>
<span class="line" id="L482">            } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (slot1 &lt; <span class="tok-number">0</span>) {</span>
<span class="line" id="L483">                q = q.sub(pc1[<span class="tok-builtin">@intCast</span>(<span class="tok-type">usize</span>, -slot1)]);</span>
<span class="line" id="L484">            }</span>
<span class="line" id="L485">            <span class="tok-kw">const</span> slot2 = e2[pos];</span>
<span class="line" id="L486">            <span class="tok-kw">if</span> (slot2 &gt; <span class="tok-number">0</span>) {</span>
<span class="line" id="L487">                q = q.add(pc2[<span class="tok-builtin">@intCast</span>(<span class="tok-type">usize</span>, slot2)]);</span>
<span class="line" id="L488">            } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (slot2 &lt; <span class="tok-number">0</span>) {</span>
<span class="line" id="L489">                q = q.sub(pc2[<span class="tok-builtin">@intCast</span>(<span class="tok-type">usize</span>, -slot2)]);</span>
<span class="line" id="L490">            }</span>
<span class="line" id="L491">            <span class="tok-kw">if</span> (pos == <span class="tok-number">0</span>) <span class="tok-kw">break</span>;</span>
<span class="line" id="L492">            q = q.dbl().dbl().dbl().dbl();</span>
<span class="line" id="L493">        }</span>
<span class="line" id="L494">        <span class="tok-kw">try</span> q.rejectIdentity();</span>
<span class="line" id="L495">        <span class="tok-kw">return</span> q;</span>
<span class="line" id="L496">    }</span>
<span class="line" id="L497"></span>
<span class="line" id="L498">    <span class="tok-comment">/// Double-base multiplication of public parameters - Compute (p1*s1)+(p2*s2) *IN VARIABLE TIME*</span></span>
<span class="line" id="L499">    <span class="tok-comment">/// This can be used for signature verification.</span></span>
<span class="line" id="L500">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">mulDoubleBasePublic</span>(p1: Secp256k1, s1_: [<span class="tok-number">32</span>]<span class="tok-type">u8</span>, p2: Secp256k1, s2_: [<span class="tok-number">32</span>]<span class="tok-type">u8</span>, endian: std.builtin.Endian) IdentityElementError!Secp256k1 {</span>
<span class="line" id="L501">        <span class="tok-kw">const</span> s1 = <span class="tok-kw">if</span> (endian == .Little) s1_ <span class="tok-kw">else</span> Fe.orderSwap(s1_);</span>
<span class="line" id="L502">        <span class="tok-kw">const</span> s2 = <span class="tok-kw">if</span> (endian == .Little) s2_ <span class="tok-kw">else</span> Fe.orderSwap(s2_);</span>
<span class="line" id="L503">        <span class="tok-kw">try</span> p1.rejectIdentity();</span>
<span class="line" id="L504">        <span class="tok-kw">var</span> pc1_array: [<span class="tok-number">9</span>]Secp256k1 = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L505">        <span class="tok-kw">const</span> pc1 = <span class="tok-kw">if</span> (p1.is_base) basePointPc[<span class="tok-number">0</span>..<span class="tok-number">9</span>] <span class="tok-kw">else</span> pc: {</span>
<span class="line" id="L506">            pc1_array = precompute(p1, <span class="tok-number">8</span>);</span>
<span class="line" id="L507">            <span class="tok-kw">break</span> :pc &amp;pc1_array;</span>
<span class="line" id="L508">        };</span>
<span class="line" id="L509">        <span class="tok-kw">try</span> p2.rejectIdentity();</span>
<span class="line" id="L510">        <span class="tok-kw">var</span> pc2_array: [<span class="tok-number">9</span>]Secp256k1 = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L511">        <span class="tok-kw">const</span> pc2 = <span class="tok-kw">if</span> (p2.is_base) basePointPc[<span class="tok-number">0</span>..<span class="tok-number">9</span>] <span class="tok-kw">else</span> pc: {</span>
<span class="line" id="L512">            pc2_array = precompute(p2, <span class="tok-number">8</span>);</span>
<span class="line" id="L513">            <span class="tok-kw">break</span> :pc &amp;pc2_array;</span>
<span class="line" id="L514">        };</span>
<span class="line" id="L515">        <span class="tok-kw">const</span> e1 = slide(s1);</span>
<span class="line" id="L516">        <span class="tok-kw">const</span> e2 = slide(s2);</span>
<span class="line" id="L517">        <span class="tok-kw">var</span> q = Secp256k1.identityElement;</span>
<span class="line" id="L518">        <span class="tok-kw">var</span> pos: <span class="tok-type">usize</span> = <span class="tok-number">2</span> * <span class="tok-number">32</span>;</span>
<span class="line" id="L519">        <span class="tok-kw">while</span> (<span class="tok-null">true</span>) : (pos -= <span class="tok-number">1</span>) {</span>
<span class="line" id="L520">            <span class="tok-kw">const</span> slot1 = e1[pos];</span>
<span class="line" id="L521">            <span class="tok-kw">if</span> (slot1 &gt; <span class="tok-number">0</span>) {</span>
<span class="line" id="L522">                q = q.add(pc1[<span class="tok-builtin">@intCast</span>(<span class="tok-type">usize</span>, slot1)]);</span>
<span class="line" id="L523">            } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (slot1 &lt; <span class="tok-number">0</span>) {</span>
<span class="line" id="L524">                q = q.sub(pc1[<span class="tok-builtin">@intCast</span>(<span class="tok-type">usize</span>, -slot1)]);</span>
<span class="line" id="L525">            }</span>
<span class="line" id="L526">            <span class="tok-kw">const</span> slot2 = e2[pos];</span>
<span class="line" id="L527">            <span class="tok-kw">if</span> (slot2 &gt; <span class="tok-number">0</span>) {</span>
<span class="line" id="L528">                q = q.add(pc2[<span class="tok-builtin">@intCast</span>(<span class="tok-type">usize</span>, slot2)]);</span>
<span class="line" id="L529">            } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (slot2 &lt; <span class="tok-number">0</span>) {</span>
<span class="line" id="L530">                q = q.sub(pc2[<span class="tok-builtin">@intCast</span>(<span class="tok-type">usize</span>, -slot2)]);</span>
<span class="line" id="L531">            }</span>
<span class="line" id="L532">            <span class="tok-kw">if</span> (pos == <span class="tok-number">0</span>) <span class="tok-kw">break</span>;</span>
<span class="line" id="L533">            q = q.dbl().dbl().dbl().dbl();</span>
<span class="line" id="L534">        }</span>
<span class="line" id="L535">        <span class="tok-kw">try</span> q.rejectIdentity();</span>
<span class="line" id="L536">        <span class="tok-kw">return</span> q;</span>
<span class="line" id="L537">    }</span>
<span class="line" id="L538">};</span>
<span class="line" id="L539"></span>
<span class="line" id="L540"><span class="tok-comment">/// A point in affine coordinates.</span></span>
<span class="line" id="L541"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> AffineCoordinates = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L542">    x: Secp256k1.Fe,</span>
<span class="line" id="L543">    y: Secp256k1.Fe,</span>
<span class="line" id="L544"></span>
<span class="line" id="L545">    <span class="tok-comment">/// Identity element in affine coordinates.</span></span>
<span class="line" id="L546">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> identityElement = AffineCoordinates{ .x = Secp256k1.identityElement.x, .y = Secp256k1.identityElement.y };</span>
<span class="line" id="L547"></span>
<span class="line" id="L548">    <span class="tok-kw">fn</span> <span class="tok-fn">cMov</span>(p: *AffineCoordinates, a: AffineCoordinates, c: <span class="tok-type">u1</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L549">        p.x.cMov(a.x, c);</span>
<span class="line" id="L550">        p.y.cMov(a.y, c);</span>
<span class="line" id="L551">    }</span>
<span class="line" id="L552">};</span>
<span class="line" id="L553"></span>
<span class="line" id="L554"><span class="tok-kw">test</span> <span class="tok-str">&quot;secp256k1&quot;</span> {</span>
<span class="line" id="L555">    _ = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;tests/secp256k1.zig&quot;</span>);</span>
<span class="line" id="L556">}</span>
<span class="line" id="L557"></span>
</code></pre></body>
</html>