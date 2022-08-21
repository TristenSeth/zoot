<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">    <title>crypto/pcurves/p384.zig - source view</title>
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
<span class="line" id="L4"><span class="tok-kw">const</span> meta = std.meta;</span>
<span class="line" id="L5"></span>
<span class="line" id="L6"><span class="tok-kw">const</span> EncodingError = crypto.errors.EncodingError;</span>
<span class="line" id="L7"><span class="tok-kw">const</span> IdentityElementError = crypto.errors.IdentityElementError;</span>
<span class="line" id="L8"><span class="tok-kw">const</span> NonCanonicalError = crypto.errors.NonCanonicalError;</span>
<span class="line" id="L9"><span class="tok-kw">const</span> NotSquareError = crypto.errors.NotSquareError;</span>
<span class="line" id="L10"></span>
<span class="line" id="L11"><span class="tok-comment">/// Group operations over P384.</span></span>
<span class="line" id="L12"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> P384 = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L13">    <span class="tok-comment">/// The underlying prime field.</span></span>
<span class="line" id="L14">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> Fe = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;p384/field.zig&quot;</span>).Fe;</span>
<span class="line" id="L15">    <span class="tok-comment">/// Field arithmetic mod the order of the main subgroup.</span></span>
<span class="line" id="L16">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> scalar = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;p384/scalar.zig&quot;</span>);</span>
<span class="line" id="L17"></span>
<span class="line" id="L18">    x: Fe,</span>
<span class="line" id="L19">    y: Fe,</span>
<span class="line" id="L20">    z: Fe = Fe.one,</span>
<span class="line" id="L21"></span>
<span class="line" id="L22">    is_base: <span class="tok-type">bool</span> = <span class="tok-null">false</span>,</span>
<span class="line" id="L23"></span>
<span class="line" id="L24">    <span class="tok-comment">/// The P384 base point.</span></span>
<span class="line" id="L25">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> basePoint = P384{</span>
<span class="line" id="L26">        .x = Fe.fromInt(<span class="tok-number">26247035095799689268623156744566981891852923491109213387815615900925518854738050089022388053975719786650872476732087</span>) <span class="tok-kw">catch</span> <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L27">        .y = Fe.fromInt(<span class="tok-number">8325710961489029985546751289520108179287853048861315594709205902480503199884419224438643760392947333078086511627871</span>) <span class="tok-kw">catch</span> <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L28">        .z = Fe.one,</span>
<span class="line" id="L29">        .is_base = <span class="tok-null">true</span>,</span>
<span class="line" id="L30">    };</span>
<span class="line" id="L31"></span>
<span class="line" id="L32">    <span class="tok-comment">/// The P384 neutral element.</span></span>
<span class="line" id="L33">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> identityElement = P384{ .x = Fe.zero, .y = Fe.one, .z = Fe.zero };</span>
<span class="line" id="L34"></span>
<span class="line" id="L35">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> B = Fe.fromInt(<span class="tok-number">27580193559959705877849011840389048093056905856361568521428707301988689241309860865136260764883745107765439761230575</span>) <span class="tok-kw">catch</span> <span class="tok-kw">unreachable</span>;</span>
<span class="line" id="L36"></span>
<span class="line" id="L37">    <span class="tok-comment">/// Reject the neutral element.</span></span>
<span class="line" id="L38">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">rejectIdentity</span>(p: P384) IdentityElementError!<span class="tok-type">void</span> {</span>
<span class="line" id="L39">        <span class="tok-kw">if</span> (p.x.isZero()) {</span>
<span class="line" id="L40">            <span class="tok-kw">return</span> <span class="tok-kw">error</span>.IdentityElement;</span>
<span class="line" id="L41">        }</span>
<span class="line" id="L42">    }</span>
<span class="line" id="L43"></span>
<span class="line" id="L44">    <span class="tok-comment">/// Create a point from affine coordinates after checking that they match the curve equation.</span></span>
<span class="line" id="L45">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">fromAffineCoordinates</span>(p: AffineCoordinates) EncodingError!P384 {</span>
<span class="line" id="L46">        <span class="tok-kw">const</span> x = p.x;</span>
<span class="line" id="L47">        <span class="tok-kw">const</span> y = p.y;</span>
<span class="line" id="L48">        <span class="tok-kw">const</span> x3AxB = x.sq().mul(x).sub(x).sub(x).sub(x).add(B);</span>
<span class="line" id="L49">        <span class="tok-kw">const</span> yy = y.sq();</span>
<span class="line" id="L50">        <span class="tok-kw">const</span> on_curve = <span class="tok-builtin">@boolToInt</span>(x3AxB.equivalent(yy));</span>
<span class="line" id="L51">        <span class="tok-kw">const</span> is_identity = <span class="tok-builtin">@boolToInt</span>(x.equivalent(AffineCoordinates.identityElement.x)) &amp; <span class="tok-builtin">@boolToInt</span>(y.equivalent(AffineCoordinates.identityElement.y));</span>
<span class="line" id="L52">        <span class="tok-kw">if</span> ((on_curve | is_identity) == <span class="tok-number">0</span>) {</span>
<span class="line" id="L53">            <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InvalidEncoding;</span>
<span class="line" id="L54">        }</span>
<span class="line" id="L55">        <span class="tok-kw">var</span> ret = P384{ .x = x, .y = y, .z = Fe.one };</span>
<span class="line" id="L56">        ret.z.cMov(P384.identityElement.z, is_identity);</span>
<span class="line" id="L57">        <span class="tok-kw">return</span> ret;</span>
<span class="line" id="L58">    }</span>
<span class="line" id="L59"></span>
<span class="line" id="L60">    <span class="tok-comment">/// Create a point from serialized affine coordinates.</span></span>
<span class="line" id="L61">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">fromSerializedAffineCoordinates</span>(xs: [<span class="tok-number">48</span>]<span class="tok-type">u8</span>, ys: [<span class="tok-number">48</span>]<span class="tok-type">u8</span>, endian: std.builtin.Endian) (NonCanonicalError || EncodingError)!P384 {</span>
<span class="line" id="L62">        <span class="tok-kw">const</span> x = <span class="tok-kw">try</span> Fe.fromBytes(xs, endian);</span>
<span class="line" id="L63">        <span class="tok-kw">const</span> y = <span class="tok-kw">try</span> Fe.fromBytes(ys, endian);</span>
<span class="line" id="L64">        <span class="tok-kw">return</span> fromAffineCoordinates(.{ .x = x, .y = y });</span>
<span class="line" id="L65">    }</span>
<span class="line" id="L66"></span>
<span class="line" id="L67">    <span class="tok-comment">/// Recover the Y coordinate from the X coordinate.</span></span>
<span class="line" id="L68">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">recoverY</span>(x: Fe, is_odd: <span class="tok-type">bool</span>) NotSquareError!Fe {</span>
<span class="line" id="L69">        <span class="tok-kw">const</span> x3AxB = x.sq().mul(x).sub(x).sub(x).sub(x).add(B);</span>
<span class="line" id="L70">        <span class="tok-kw">var</span> y = <span class="tok-kw">try</span> x3AxB.sqrt();</span>
<span class="line" id="L71">        <span class="tok-kw">const</span> yn = y.neg();</span>
<span class="line" id="L72">        y.cMov(yn, <span class="tok-builtin">@boolToInt</span>(is_odd) ^ <span class="tok-builtin">@boolToInt</span>(y.isOdd()));</span>
<span class="line" id="L73">        <span class="tok-kw">return</span> y;</span>
<span class="line" id="L74">    }</span>
<span class="line" id="L75"></span>
<span class="line" id="L76">    <span class="tok-comment">/// Deserialize a SEC1-encoded point.</span></span>
<span class="line" id="L77">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">fromSec1</span>(s: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) (EncodingError || NotSquareError || NonCanonicalError)!P384 {</span>
<span class="line" id="L78">        <span class="tok-kw">if</span> (s.len &lt; <span class="tok-number">1</span>) <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InvalidEncoding;</span>
<span class="line" id="L79">        <span class="tok-kw">const</span> encoding_type = s[<span class="tok-number">0</span>];</span>
<span class="line" id="L80">        <span class="tok-kw">const</span> encoded = s[<span class="tok-number">1</span>..];</span>
<span class="line" id="L81">        <span class="tok-kw">switch</span> (encoding_type) {</span>
<span class="line" id="L82">            <span class="tok-number">0</span> =&gt; {</span>
<span class="line" id="L83">                <span class="tok-kw">if</span> (encoded.len != <span class="tok-number">0</span>) <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InvalidEncoding;</span>
<span class="line" id="L84">                <span class="tok-kw">return</span> P384.identityElement;</span>
<span class="line" id="L85">            },</span>
<span class="line" id="L86">            <span class="tok-number">2</span>, <span class="tok-number">3</span> =&gt; {</span>
<span class="line" id="L87">                <span class="tok-kw">if</span> (encoded.len != <span class="tok-number">48</span>) <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InvalidEncoding;</span>
<span class="line" id="L88">                <span class="tok-kw">const</span> x = <span class="tok-kw">try</span> Fe.fromBytes(encoded[<span class="tok-number">0</span>..<span class="tok-number">48</span>].*, .Big);</span>
<span class="line" id="L89">                <span class="tok-kw">const</span> y_is_odd = (encoding_type == <span class="tok-number">3</span>);</span>
<span class="line" id="L90">                <span class="tok-kw">const</span> y = <span class="tok-kw">try</span> recoverY(x, y_is_odd);</span>
<span class="line" id="L91">                <span class="tok-kw">return</span> P384{ .x = x, .y = y };</span>
<span class="line" id="L92">            },</span>
<span class="line" id="L93">            <span class="tok-number">4</span> =&gt; {</span>
<span class="line" id="L94">                <span class="tok-kw">if</span> (encoded.len != <span class="tok-number">96</span>) <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InvalidEncoding;</span>
<span class="line" id="L95">                <span class="tok-kw">const</span> x = <span class="tok-kw">try</span> Fe.fromBytes(encoded[<span class="tok-number">0</span>..<span class="tok-number">48</span>].*, .Big);</span>
<span class="line" id="L96">                <span class="tok-kw">const</span> y = <span class="tok-kw">try</span> Fe.fromBytes(encoded[<span class="tok-number">48</span>..<span class="tok-number">96</span>].*, .Big);</span>
<span class="line" id="L97">                <span class="tok-kw">return</span> P384.fromAffineCoordinates(.{ .x = x, .y = y });</span>
<span class="line" id="L98">            },</span>
<span class="line" id="L99">            <span class="tok-kw">else</span> =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InvalidEncoding,</span>
<span class="line" id="L100">        }</span>
<span class="line" id="L101">    }</span>
<span class="line" id="L102"></span>
<span class="line" id="L103">    <span class="tok-comment">/// Serialize a point using the compressed SEC-1 format.</span></span>
<span class="line" id="L104">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">toCompressedSec1</span>(p: P384) [<span class="tok-number">49</span>]<span class="tok-type">u8</span> {</span>
<span class="line" id="L105">        <span class="tok-kw">var</span> out: [<span class="tok-number">49</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L106">        <span class="tok-kw">const</span> xy = p.affineCoordinates();</span>
<span class="line" id="L107">        out[<span class="tok-number">0</span>] = <span class="tok-kw">if</span> (xy.y.isOdd()) <span class="tok-number">3</span> <span class="tok-kw">else</span> <span class="tok-number">2</span>;</span>
<span class="line" id="L108">        mem.copy(<span class="tok-type">u8</span>, out[<span class="tok-number">1</span>..], &amp;xy.x.toBytes(.Big));</span>
<span class="line" id="L109">        <span class="tok-kw">return</span> out;</span>
<span class="line" id="L110">    }</span>
<span class="line" id="L111"></span>
<span class="line" id="L112">    <span class="tok-comment">/// Serialize a point using the uncompressed SEC-1 format.</span></span>
<span class="line" id="L113">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">toUncompressedSec1</span>(p: P384) [<span class="tok-number">97</span>]<span class="tok-type">u8</span> {</span>
<span class="line" id="L114">        <span class="tok-kw">var</span> out: [<span class="tok-number">97</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L115">        out[<span class="tok-number">0</span>] = <span class="tok-number">4</span>;</span>
<span class="line" id="L116">        <span class="tok-kw">const</span> xy = p.affineCoordinates();</span>
<span class="line" id="L117">        mem.copy(<span class="tok-type">u8</span>, out[<span class="tok-number">1</span>..<span class="tok-number">49</span>], &amp;xy.x.toBytes(.Big));</span>
<span class="line" id="L118">        mem.copy(<span class="tok-type">u8</span>, out[<span class="tok-number">49</span>..<span class="tok-number">97</span>], &amp;xy.y.toBytes(.Big));</span>
<span class="line" id="L119">        <span class="tok-kw">return</span> out;</span>
<span class="line" id="L120">    }</span>
<span class="line" id="L121"></span>
<span class="line" id="L122">    <span class="tok-comment">/// Return a random point.</span></span>
<span class="line" id="L123">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">random</span>() P384 {</span>
<span class="line" id="L124">        <span class="tok-kw">const</span> n = scalar.random(.Little);</span>
<span class="line" id="L125">        <span class="tok-kw">return</span> basePoint.mul(n, .Little) <span class="tok-kw">catch</span> <span class="tok-kw">unreachable</span>;</span>
<span class="line" id="L126">    }</span>
<span class="line" id="L127"></span>
<span class="line" id="L128">    <span class="tok-comment">/// Flip the sign of the X coordinate.</span></span>
<span class="line" id="L129">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">neg</span>(p: P384) P384 {</span>
<span class="line" id="L130">        <span class="tok-kw">return</span> .{ .x = p.x, .y = p.y.neg(), .z = p.z };</span>
<span class="line" id="L131">    }</span>
<span class="line" id="L132"></span>
<span class="line" id="L133">    <span class="tok-comment">/// Double a P384 point.</span></span>
<span class="line" id="L134">    <span class="tok-comment">// Algorithm 6 from https://eprint.iacr.org/2015/1060.pdf</span>
</span>
<span class="line" id="L135">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">dbl</span>(p: P384) P384 {</span>
<span class="line" id="L136">        <span class="tok-kw">var</span> t0 = p.x.sq();</span>
<span class="line" id="L137">        <span class="tok-kw">var</span> t1 = p.y.sq();</span>
<span class="line" id="L138">        <span class="tok-kw">var</span> t2 = p.z.sq();</span>
<span class="line" id="L139">        <span class="tok-kw">var</span> t3 = p.x.mul(p.y);</span>
<span class="line" id="L140">        t3 = t3.dbl();</span>
<span class="line" id="L141">        <span class="tok-kw">var</span> Z3 = p.x.mul(p.z);</span>
<span class="line" id="L142">        Z3 = Z3.add(Z3);</span>
<span class="line" id="L143">        <span class="tok-kw">var</span> Y3 = B.mul(t2);</span>
<span class="line" id="L144">        Y3 = Y3.sub(Z3);</span>
<span class="line" id="L145">        <span class="tok-kw">var</span> X3 = Y3.dbl();</span>
<span class="line" id="L146">        Y3 = X3.add(Y3);</span>
<span class="line" id="L147">        X3 = t1.sub(Y3);</span>
<span class="line" id="L148">        Y3 = t1.add(Y3);</span>
<span class="line" id="L149">        Y3 = X3.mul(Y3);</span>
<span class="line" id="L150">        X3 = X3.mul(t3);</span>
<span class="line" id="L151">        t3 = t2.dbl();</span>
<span class="line" id="L152">        t2 = t2.add(t3);</span>
<span class="line" id="L153">        Z3 = B.mul(Z3);</span>
<span class="line" id="L154">        Z3 = Z3.sub(t2);</span>
<span class="line" id="L155">        Z3 = Z3.sub(t0);</span>
<span class="line" id="L156">        t3 = Z3.dbl();</span>
<span class="line" id="L157">        Z3 = Z3.add(t3);</span>
<span class="line" id="L158">        t3 = t0.dbl();</span>
<span class="line" id="L159">        t0 = t3.add(t0);</span>
<span class="line" id="L160">        t0 = t0.sub(t2);</span>
<span class="line" id="L161">        t0 = t0.mul(Z3);</span>
<span class="line" id="L162">        Y3 = Y3.add(t0);</span>
<span class="line" id="L163">        t0 = p.y.mul(p.z);</span>
<span class="line" id="L164">        t0 = t0.dbl();</span>
<span class="line" id="L165">        Z3 = t0.mul(Z3);</span>
<span class="line" id="L166">        X3 = X3.sub(Z3);</span>
<span class="line" id="L167">        Z3 = t0.mul(t1);</span>
<span class="line" id="L168">        Z3 = Z3.dbl().dbl();</span>
<span class="line" id="L169">        <span class="tok-kw">return</span> .{</span>
<span class="line" id="L170">            .x = X3,</span>
<span class="line" id="L171">            .y = Y3,</span>
<span class="line" id="L172">            .z = Z3,</span>
<span class="line" id="L173">        };</span>
<span class="line" id="L174">    }</span>
<span class="line" id="L175"></span>
<span class="line" id="L176">    <span class="tok-comment">/// Add P384 points, the second being specified using affine coordinates.</span></span>
<span class="line" id="L177">    <span class="tok-comment">// Algorithm 5 from https://eprint.iacr.org/2015/1060.pdf</span>
</span>
<span class="line" id="L178">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">addMixed</span>(p: P384, q: AffineCoordinates) P384 {</span>
<span class="line" id="L179">        <span class="tok-kw">var</span> t0 = p.x.mul(q.x);</span>
<span class="line" id="L180">        <span class="tok-kw">var</span> t1 = p.y.mul(q.y);</span>
<span class="line" id="L181">        <span class="tok-kw">var</span> t3 = q.x.add(q.y);</span>
<span class="line" id="L182">        <span class="tok-kw">var</span> t4 = p.x.add(p.y);</span>
<span class="line" id="L183">        t3 = t3.mul(t4);</span>
<span class="line" id="L184">        t4 = t0.add(t1);</span>
<span class="line" id="L185">        t3 = t3.sub(t4);</span>
<span class="line" id="L186">        t4 = q.y.mul(p.z);</span>
<span class="line" id="L187">        t4 = t4.add(p.y);</span>
<span class="line" id="L188">        <span class="tok-kw">var</span> Y3 = q.x.mul(p.z);</span>
<span class="line" id="L189">        Y3 = Y3.add(p.x);</span>
<span class="line" id="L190">        <span class="tok-kw">var</span> Z3 = B.mul(p.z);</span>
<span class="line" id="L191">        <span class="tok-kw">var</span> X3 = Y3.sub(Z3);</span>
<span class="line" id="L192">        Z3 = X3.dbl();</span>
<span class="line" id="L193">        X3 = X3.add(Z3);</span>
<span class="line" id="L194">        Z3 = t1.sub(X3);</span>
<span class="line" id="L195">        X3 = t1.add(X3);</span>
<span class="line" id="L196">        Y3 = B.mul(Y3);</span>
<span class="line" id="L197">        t1 = p.z.dbl();</span>
<span class="line" id="L198">        <span class="tok-kw">var</span> t2 = t1.add(p.z);</span>
<span class="line" id="L199">        Y3 = Y3.sub(t2);</span>
<span class="line" id="L200">        Y3 = Y3.sub(t0);</span>
<span class="line" id="L201">        t1 = Y3.dbl();</span>
<span class="line" id="L202">        Y3 = t1.add(Y3);</span>
<span class="line" id="L203">        t1 = t0.dbl();</span>
<span class="line" id="L204">        t0 = t1.add(t0);</span>
<span class="line" id="L205">        t0 = t0.sub(t2);</span>
<span class="line" id="L206">        t1 = t4.mul(Y3);</span>
<span class="line" id="L207">        t2 = t0.mul(Y3);</span>
<span class="line" id="L208">        Y3 = X3.mul(Z3);</span>
<span class="line" id="L209">        Y3 = Y3.add(t2);</span>
<span class="line" id="L210">        X3 = t3.mul(X3);</span>
<span class="line" id="L211">        X3 = X3.sub(t1);</span>
<span class="line" id="L212">        Z3 = t4.mul(Z3);</span>
<span class="line" id="L213">        t1 = t3.mul(t0);</span>
<span class="line" id="L214">        Z3 = Z3.add(t1);</span>
<span class="line" id="L215">        <span class="tok-kw">var</span> ret = P384{</span>
<span class="line" id="L216">            .x = X3,</span>
<span class="line" id="L217">            .y = Y3,</span>
<span class="line" id="L218">            .z = Z3,</span>
<span class="line" id="L219">        };</span>
<span class="line" id="L220">        ret.cMov(p, <span class="tok-builtin">@boolToInt</span>(q.x.isZero()));</span>
<span class="line" id="L221">        <span class="tok-kw">return</span> ret;</span>
<span class="line" id="L222">    }</span>
<span class="line" id="L223"></span>
<span class="line" id="L224">    <span class="tok-comment">/// Add P384 points.</span></span>
<span class="line" id="L225">    <span class="tok-comment">// Algorithm 4 from https://eprint.iacr.org/2015/1060.pdf</span>
</span>
<span class="line" id="L226">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">add</span>(p: P384, q: P384) P384 {</span>
<span class="line" id="L227">        <span class="tok-kw">var</span> t0 = p.x.mul(q.x);</span>
<span class="line" id="L228">        <span class="tok-kw">var</span> t1 = p.y.mul(q.y);</span>
<span class="line" id="L229">        <span class="tok-kw">var</span> t2 = p.z.mul(q.z);</span>
<span class="line" id="L230">        <span class="tok-kw">var</span> t3 = p.x.add(p.y);</span>
<span class="line" id="L231">        <span class="tok-kw">var</span> t4 = q.x.add(q.y);</span>
<span class="line" id="L232">        t3 = t3.mul(t4);</span>
<span class="line" id="L233">        t4 = t0.add(t1);</span>
<span class="line" id="L234">        t3 = t3.sub(t4);</span>
<span class="line" id="L235">        t4 = p.y.add(p.z);</span>
<span class="line" id="L236">        <span class="tok-kw">var</span> X3 = q.y.add(q.z);</span>
<span class="line" id="L237">        t4 = t4.mul(X3);</span>
<span class="line" id="L238">        X3 = t1.add(t2);</span>
<span class="line" id="L239">        t4 = t4.sub(X3);</span>
<span class="line" id="L240">        X3 = p.x.add(p.z);</span>
<span class="line" id="L241">        <span class="tok-kw">var</span> Y3 = q.x.add(q.z);</span>
<span class="line" id="L242">        X3 = X3.mul(Y3);</span>
<span class="line" id="L243">        Y3 = t0.add(t2);</span>
<span class="line" id="L244">        Y3 = X3.sub(Y3);</span>
<span class="line" id="L245">        <span class="tok-kw">var</span> Z3 = B.mul(t2);</span>
<span class="line" id="L246">        X3 = Y3.sub(Z3);</span>
<span class="line" id="L247">        Z3 = X3.dbl();</span>
<span class="line" id="L248">        X3 = X3.add(Z3);</span>
<span class="line" id="L249">        Z3 = t1.sub(X3);</span>
<span class="line" id="L250">        X3 = t1.add(X3);</span>
<span class="line" id="L251">        Y3 = B.mul(Y3);</span>
<span class="line" id="L252">        t1 = t2.dbl();</span>
<span class="line" id="L253">        t2 = t1.add(t2);</span>
<span class="line" id="L254">        Y3 = Y3.sub(t2);</span>
<span class="line" id="L255">        Y3 = Y3.sub(t0);</span>
<span class="line" id="L256">        t1 = Y3.dbl();</span>
<span class="line" id="L257">        Y3 = t1.add(Y3);</span>
<span class="line" id="L258">        t1 = t0.dbl();</span>
<span class="line" id="L259">        t0 = t1.add(t0);</span>
<span class="line" id="L260">        t0 = t0.sub(t2);</span>
<span class="line" id="L261">        t1 = t4.mul(Y3);</span>
<span class="line" id="L262">        t2 = t0.mul(Y3);</span>
<span class="line" id="L263">        Y3 = X3.mul(Z3);</span>
<span class="line" id="L264">        Y3 = Y3.add(t2);</span>
<span class="line" id="L265">        X3 = t3.mul(X3);</span>
<span class="line" id="L266">        X3 = X3.sub(t1);</span>
<span class="line" id="L267">        Z3 = t4.mul(Z3);</span>
<span class="line" id="L268">        t1 = t3.mul(t0);</span>
<span class="line" id="L269">        Z3 = Z3.add(t1);</span>
<span class="line" id="L270">        <span class="tok-kw">return</span> .{</span>
<span class="line" id="L271">            .x = X3,</span>
<span class="line" id="L272">            .y = Y3,</span>
<span class="line" id="L273">            .z = Z3,</span>
<span class="line" id="L274">        };</span>
<span class="line" id="L275">    }</span>
<span class="line" id="L276"></span>
<span class="line" id="L277">    <span class="tok-comment">/// Subtract P384 points.</span></span>
<span class="line" id="L278">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">sub</span>(p: P384, q: P384) P384 {</span>
<span class="line" id="L279">        <span class="tok-kw">return</span> p.add(q.neg());</span>
<span class="line" id="L280">    }</span>
<span class="line" id="L281"></span>
<span class="line" id="L282">    <span class="tok-comment">/// Subtract P384 points, the second being specified using affine coordinates.</span></span>
<span class="line" id="L283">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">subMixed</span>(p: P384, q: AffineCoordinates) P384 {</span>
<span class="line" id="L284">        <span class="tok-kw">return</span> p.addMixed(q.neg());</span>
<span class="line" id="L285">    }</span>
<span class="line" id="L286"></span>
<span class="line" id="L287">    <span class="tok-comment">/// Return affine coordinates.</span></span>
<span class="line" id="L288">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">affineCoordinates</span>(p: P384) AffineCoordinates {</span>
<span class="line" id="L289">        <span class="tok-kw">const</span> zinv = p.z.invert();</span>
<span class="line" id="L290">        <span class="tok-kw">var</span> ret = AffineCoordinates{</span>
<span class="line" id="L291">            .x = p.x.mul(zinv),</span>
<span class="line" id="L292">            .y = p.y.mul(zinv),</span>
<span class="line" id="L293">        };</span>
<span class="line" id="L294">        ret.cMov(AffineCoordinates.identityElement, <span class="tok-builtin">@boolToInt</span>(p.x.isZero()));</span>
<span class="line" id="L295">        <span class="tok-kw">return</span> ret;</span>
<span class="line" id="L296">    }</span>
<span class="line" id="L297"></span>
<span class="line" id="L298">    <span class="tok-comment">/// Return true if both coordinate sets represent the same point.</span></span>
<span class="line" id="L299">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">equivalent</span>(a: P384, b: P384) <span class="tok-type">bool</span> {</span>
<span class="line" id="L300">        <span class="tok-kw">if</span> (a.sub(b).rejectIdentity()) {</span>
<span class="line" id="L301">            <span class="tok-kw">return</span> <span class="tok-null">false</span>;</span>
<span class="line" id="L302">        } <span class="tok-kw">else</span> |_| {</span>
<span class="line" id="L303">            <span class="tok-kw">return</span> <span class="tok-null">true</span>;</span>
<span class="line" id="L304">        }</span>
<span class="line" id="L305">    }</span>
<span class="line" id="L306"></span>
<span class="line" id="L307">    <span class="tok-kw">fn</span> <span class="tok-fn">cMov</span>(p: *P384, a: P384, c: <span class="tok-type">u1</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L308">        p.x.cMov(a.x, c);</span>
<span class="line" id="L309">        p.y.cMov(a.y, c);</span>
<span class="line" id="L310">        p.z.cMov(a.z, c);</span>
<span class="line" id="L311">    }</span>
<span class="line" id="L312"></span>
<span class="line" id="L313">    <span class="tok-kw">fn</span> <span class="tok-fn">pcSelect</span>(<span class="tok-kw">comptime</span> n: <span class="tok-type">usize</span>, pc: *<span class="tok-kw">const</span> [n]P384, b: <span class="tok-type">u8</span>) P384 {</span>
<span class="line" id="L314">        <span class="tok-kw">var</span> t = P384.identityElement;</span>
<span class="line" id="L315">        <span class="tok-kw">comptime</span> <span class="tok-kw">var</span> i: <span class="tok-type">u8</span> = <span class="tok-number">1</span>;</span>
<span class="line" id="L316">        <span class="tok-kw">inline</span> <span class="tok-kw">while</span> (i &lt; pc.len) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L317">            t.cMov(pc[i], <span class="tok-builtin">@truncate</span>(<span class="tok-type">u1</span>, (<span class="tok-builtin">@as</span>(<span class="tok-type">usize</span>, b ^ i) -% <span class="tok-number">1</span>) &gt;&gt; <span class="tok-number">8</span>));</span>
<span class="line" id="L318">        }</span>
<span class="line" id="L319">        <span class="tok-kw">return</span> t;</span>
<span class="line" id="L320">    }</span>
<span class="line" id="L321"></span>
<span class="line" id="L322">    <span class="tok-kw">fn</span> <span class="tok-fn">slide</span>(s: [<span class="tok-number">48</span>]<span class="tok-type">u8</span>) [<span class="tok-number">2</span> * <span class="tok-number">48</span> + <span class="tok-number">1</span>]<span class="tok-type">i8</span> {</span>
<span class="line" id="L323">        <span class="tok-kw">var</span> e: [<span class="tok-number">2</span> * <span class="tok-number">48</span> + <span class="tok-number">1</span>]<span class="tok-type">i8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L324">        <span class="tok-kw">for</span> (s) |x, i| {</span>
<span class="line" id="L325">            e[i * <span class="tok-number">2</span> + <span class="tok-number">0</span>] = <span class="tok-builtin">@as</span>(<span class="tok-type">i8</span>, <span class="tok-builtin">@truncate</span>(<span class="tok-type">u4</span>, x));</span>
<span class="line" id="L326">            e[i * <span class="tok-number">2</span> + <span class="tok-number">1</span>] = <span class="tok-builtin">@as</span>(<span class="tok-type">i8</span>, <span class="tok-builtin">@truncate</span>(<span class="tok-type">u4</span>, x &gt;&gt; <span class="tok-number">4</span>));</span>
<span class="line" id="L327">        }</span>
<span class="line" id="L328">        <span class="tok-comment">// Now, e[0..63] is between 0 and 15, e[63] is between 0 and 7</span>
</span>
<span class="line" id="L329">        <span class="tok-kw">var</span> carry: <span class="tok-type">i8</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L330">        <span class="tok-kw">for</span> (e[<span class="tok-number">0</span>..<span class="tok-number">96</span>]) |*x| {</span>
<span class="line" id="L331">            x.* += carry;</span>
<span class="line" id="L332">            carry = (x.* + <span class="tok-number">8</span>) &gt;&gt; <span class="tok-number">4</span>;</span>
<span class="line" id="L333">            x.* -= carry * <span class="tok-number">16</span>;</span>
<span class="line" id="L334">            std.debug.assert(x.* &gt;= -<span class="tok-number">8</span> <span class="tok-kw">and</span> x.* &lt;= <span class="tok-number">8</span>);</span>
<span class="line" id="L335">        }</span>
<span class="line" id="L336">        e[<span class="tok-number">96</span>] = carry;</span>
<span class="line" id="L337">        <span class="tok-comment">// Now, e[*] is between -8 and 8, including e[64]</span>
</span>
<span class="line" id="L338">        std.debug.assert(carry &gt;= -<span class="tok-number">8</span> <span class="tok-kw">and</span> carry &lt;= <span class="tok-number">8</span>);</span>
<span class="line" id="L339">        <span class="tok-kw">return</span> e;</span>
<span class="line" id="L340">    }</span>
<span class="line" id="L341"></span>
<span class="line" id="L342">    <span class="tok-kw">fn</span> <span class="tok-fn">pcMul</span>(pc: *<span class="tok-kw">const</span> [<span class="tok-number">9</span>]P384, s: [<span class="tok-number">48</span>]<span class="tok-type">u8</span>, <span class="tok-kw">comptime</span> vartime: <span class="tok-type">bool</span>) IdentityElementError!P384 {</span>
<span class="line" id="L343">        std.debug.assert(vartime);</span>
<span class="line" id="L344">        <span class="tok-kw">const</span> e = slide(s);</span>
<span class="line" id="L345">        <span class="tok-kw">var</span> q = P384.identityElement;</span>
<span class="line" id="L346">        <span class="tok-kw">var</span> pos = e.len - <span class="tok-number">1</span>;</span>
<span class="line" id="L347">        <span class="tok-kw">while</span> (<span class="tok-null">true</span>) : (pos -= <span class="tok-number">1</span>) {</span>
<span class="line" id="L348">            <span class="tok-kw">const</span> slot = e[pos];</span>
<span class="line" id="L349">            <span class="tok-kw">if</span> (slot &gt; <span class="tok-number">0</span>) {</span>
<span class="line" id="L350">                q = q.add(pc[<span class="tok-builtin">@intCast</span>(<span class="tok-type">usize</span>, slot)]);</span>
<span class="line" id="L351">            } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (slot &lt; <span class="tok-number">0</span>) {</span>
<span class="line" id="L352">                q = q.sub(pc[<span class="tok-builtin">@intCast</span>(<span class="tok-type">usize</span>, -slot)]);</span>
<span class="line" id="L353">            }</span>
<span class="line" id="L354">            <span class="tok-kw">if</span> (pos == <span class="tok-number">0</span>) <span class="tok-kw">break</span>;</span>
<span class="line" id="L355">            q = q.dbl().dbl().dbl().dbl();</span>
<span class="line" id="L356">        }</span>
<span class="line" id="L357">        <span class="tok-kw">try</span> q.rejectIdentity();</span>
<span class="line" id="L358">        <span class="tok-kw">return</span> q;</span>
<span class="line" id="L359">    }</span>
<span class="line" id="L360"></span>
<span class="line" id="L361">    <span class="tok-kw">fn</span> <span class="tok-fn">pcMul16</span>(pc: *<span class="tok-kw">const</span> [<span class="tok-number">16</span>]P384, s: [<span class="tok-number">48</span>]<span class="tok-type">u8</span>, <span class="tok-kw">comptime</span> vartime: <span class="tok-type">bool</span>) IdentityElementError!P384 {</span>
<span class="line" id="L362">        <span class="tok-kw">var</span> q = P384.identityElement;</span>
<span class="line" id="L363">        <span class="tok-kw">var</span> pos: <span class="tok-type">usize</span> = <span class="tok-number">380</span>;</span>
<span class="line" id="L364">        <span class="tok-kw">while</span> (<span class="tok-null">true</span>) : (pos -= <span class="tok-number">4</span>) {</span>
<span class="line" id="L365">            <span class="tok-kw">const</span> slot = <span class="tok-builtin">@truncate</span>(<span class="tok-type">u4</span>, (s[pos &gt;&gt; <span class="tok-number">3</span>] &gt;&gt; <span class="tok-builtin">@truncate</span>(<span class="tok-type">u3</span>, pos)));</span>
<span class="line" id="L366">            <span class="tok-kw">if</span> (vartime) {</span>
<span class="line" id="L367">                <span class="tok-kw">if</span> (slot != <span class="tok-number">0</span>) {</span>
<span class="line" id="L368">                    q = q.add(pc[slot]);</span>
<span class="line" id="L369">                }</span>
<span class="line" id="L370">            } <span class="tok-kw">else</span> {</span>
<span class="line" id="L371">                q = q.add(pcSelect(<span class="tok-number">16</span>, pc, slot));</span>
<span class="line" id="L372">            }</span>
<span class="line" id="L373">            <span class="tok-kw">if</span> (pos == <span class="tok-number">0</span>) <span class="tok-kw">break</span>;</span>
<span class="line" id="L374">            q = q.dbl().dbl().dbl().dbl();</span>
<span class="line" id="L375">        }</span>
<span class="line" id="L376">        <span class="tok-kw">try</span> q.rejectIdentity();</span>
<span class="line" id="L377">        <span class="tok-kw">return</span> q;</span>
<span class="line" id="L378">    }</span>
<span class="line" id="L379"></span>
<span class="line" id="L380">    <span class="tok-kw">fn</span> <span class="tok-fn">precompute</span>(p: P384, <span class="tok-kw">comptime</span> count: <span class="tok-type">usize</span>) [<span class="tok-number">1</span> + count]P384 {</span>
<span class="line" id="L381">        <span class="tok-kw">var</span> pc: [<span class="tok-number">1</span> + count]P384 = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L382">        pc[<span class="tok-number">0</span>] = P384.identityElement;</span>
<span class="line" id="L383">        pc[<span class="tok-number">1</span>] = p;</span>
<span class="line" id="L384">        <span class="tok-kw">var</span> i: <span class="tok-type">usize</span> = <span class="tok-number">2</span>;</span>
<span class="line" id="L385">        <span class="tok-kw">while</span> (i &lt;= count) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L386">            pc[i] = <span class="tok-kw">if</span> (i % <span class="tok-number">2</span> == <span class="tok-number">0</span>) pc[i / <span class="tok-number">2</span>].dbl() <span class="tok-kw">else</span> pc[i - <span class="tok-number">1</span>].add(p);</span>
<span class="line" id="L387">        }</span>
<span class="line" id="L388">        <span class="tok-kw">return</span> pc;</span>
<span class="line" id="L389">    }</span>
<span class="line" id="L390"></span>
<span class="line" id="L391">    <span class="tok-kw">const</span> basePointPc = pc: {</span>
<span class="line" id="L392">        <span class="tok-builtin">@setEvalBranchQuota</span>(<span class="tok-number">50000</span>);</span>
<span class="line" id="L393">        <span class="tok-kw">break</span> :pc precompute(P384.basePoint, <span class="tok-number">15</span>);</span>
<span class="line" id="L394">    };</span>
<span class="line" id="L395"></span>
<span class="line" id="L396">    <span class="tok-comment">/// Multiply an elliptic curve point by a scalar.</span></span>
<span class="line" id="L397">    <span class="tok-comment">/// Return error.IdentityElement if the result is the identity element.</span></span>
<span class="line" id="L398">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">mul</span>(p: P384, s_: [<span class="tok-number">48</span>]<span class="tok-type">u8</span>, endian: std.builtin.Endian) IdentityElementError!P384 {</span>
<span class="line" id="L399">        <span class="tok-kw">const</span> s = <span class="tok-kw">if</span> (endian == .Little) s_ <span class="tok-kw">else</span> Fe.orderSwap(s_);</span>
<span class="line" id="L400">        <span class="tok-kw">if</span> (p.is_base) {</span>
<span class="line" id="L401">            <span class="tok-kw">return</span> pcMul16(&amp;basePointPc, s, <span class="tok-null">false</span>);</span>
<span class="line" id="L402">        }</span>
<span class="line" id="L403">        <span class="tok-kw">try</span> p.rejectIdentity();</span>
<span class="line" id="L404">        <span class="tok-kw">const</span> pc = precompute(p, <span class="tok-number">15</span>);</span>
<span class="line" id="L405">        <span class="tok-kw">return</span> pcMul16(&amp;pc, s, <span class="tok-null">false</span>);</span>
<span class="line" id="L406">    }</span>
<span class="line" id="L407"></span>
<span class="line" id="L408">    <span class="tok-comment">/// Multiply an elliptic curve point by a *PUBLIC* scalar *IN VARIABLE TIME*</span></span>
<span class="line" id="L409">    <span class="tok-comment">/// This can be used for signature verification.</span></span>
<span class="line" id="L410">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">mulPublic</span>(p: P384, s_: [<span class="tok-number">48</span>]<span class="tok-type">u8</span>, endian: std.builtin.Endian) IdentityElementError!P384 {</span>
<span class="line" id="L411">        <span class="tok-kw">const</span> s = <span class="tok-kw">if</span> (endian == .Little) s_ <span class="tok-kw">else</span> Fe.orderSwap(s_);</span>
<span class="line" id="L412">        <span class="tok-kw">if</span> (p.is_base) {</span>
<span class="line" id="L413">            <span class="tok-kw">return</span> pcMul16(&amp;basePointPc, s, <span class="tok-null">true</span>);</span>
<span class="line" id="L414">        }</span>
<span class="line" id="L415">        <span class="tok-kw">try</span> p.rejectIdentity();</span>
<span class="line" id="L416">        <span class="tok-kw">const</span> pc = precompute(p, <span class="tok-number">8</span>);</span>
<span class="line" id="L417">        <span class="tok-kw">return</span> pcMul(&amp;pc, s, <span class="tok-null">true</span>);</span>
<span class="line" id="L418">    }</span>
<span class="line" id="L419"></span>
<span class="line" id="L420">    <span class="tok-comment">/// Double-base multiplication of public parameters - Compute (p1*s1)+(p2*s2) *IN VARIABLE TIME*</span></span>
<span class="line" id="L421">    <span class="tok-comment">/// This can be used for signature verification.</span></span>
<span class="line" id="L422">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">mulDoubleBasePublic</span>(p1: P384, s1_: [<span class="tok-number">48</span>]<span class="tok-type">u8</span>, p2: P384, s2_: [<span class="tok-number">48</span>]<span class="tok-type">u8</span>, endian: std.builtin.Endian) IdentityElementError!P384 {</span>
<span class="line" id="L423">        <span class="tok-kw">const</span> s1 = <span class="tok-kw">if</span> (endian == .Little) s1_ <span class="tok-kw">else</span> Fe.orderSwap(s1_);</span>
<span class="line" id="L424">        <span class="tok-kw">const</span> s2 = <span class="tok-kw">if</span> (endian == .Little) s2_ <span class="tok-kw">else</span> Fe.orderSwap(s2_);</span>
<span class="line" id="L425">        <span class="tok-kw">try</span> p1.rejectIdentity();</span>
<span class="line" id="L426">        <span class="tok-kw">var</span> pc1_array: [<span class="tok-number">9</span>]P384 = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L427">        <span class="tok-kw">const</span> pc1 = <span class="tok-kw">if</span> (p1.is_base) basePointPc[<span class="tok-number">0</span>..<span class="tok-number">9</span>] <span class="tok-kw">else</span> pc: {</span>
<span class="line" id="L428">            pc1_array = precompute(p1, <span class="tok-number">8</span>);</span>
<span class="line" id="L429">            <span class="tok-kw">break</span> :pc &amp;pc1_array;</span>
<span class="line" id="L430">        };</span>
<span class="line" id="L431">        <span class="tok-kw">try</span> p2.rejectIdentity();</span>
<span class="line" id="L432">        <span class="tok-kw">var</span> pc2_array: [<span class="tok-number">9</span>]P384 = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L433">        <span class="tok-kw">const</span> pc2 = <span class="tok-kw">if</span> (p2.is_base) basePointPc[<span class="tok-number">0</span>..<span class="tok-number">9</span>] <span class="tok-kw">else</span> pc: {</span>
<span class="line" id="L434">            pc2_array = precompute(p2, <span class="tok-number">8</span>);</span>
<span class="line" id="L435">            <span class="tok-kw">break</span> :pc &amp;pc2_array;</span>
<span class="line" id="L436">        };</span>
<span class="line" id="L437">        <span class="tok-kw">const</span> e1 = slide(s1);</span>
<span class="line" id="L438">        <span class="tok-kw">const</span> e2 = slide(s2);</span>
<span class="line" id="L439">        <span class="tok-kw">var</span> q = P384.identityElement;</span>
<span class="line" id="L440">        <span class="tok-kw">var</span> pos: <span class="tok-type">usize</span> = <span class="tok-number">2</span> * <span class="tok-number">48</span>;</span>
<span class="line" id="L441">        <span class="tok-kw">while</span> (<span class="tok-null">true</span>) : (pos -= <span class="tok-number">1</span>) {</span>
<span class="line" id="L442">            <span class="tok-kw">const</span> slot1 = e1[pos];</span>
<span class="line" id="L443">            <span class="tok-kw">if</span> (slot1 &gt; <span class="tok-number">0</span>) {</span>
<span class="line" id="L444">                q = q.add(pc1[<span class="tok-builtin">@intCast</span>(<span class="tok-type">usize</span>, slot1)]);</span>
<span class="line" id="L445">            } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (slot1 &lt; <span class="tok-number">0</span>) {</span>
<span class="line" id="L446">                q = q.sub(pc1[<span class="tok-builtin">@intCast</span>(<span class="tok-type">usize</span>, -slot1)]);</span>
<span class="line" id="L447">            }</span>
<span class="line" id="L448">            <span class="tok-kw">const</span> slot2 = e2[pos];</span>
<span class="line" id="L449">            <span class="tok-kw">if</span> (slot2 &gt; <span class="tok-number">0</span>) {</span>
<span class="line" id="L450">                q = q.add(pc2[<span class="tok-builtin">@intCast</span>(<span class="tok-type">usize</span>, slot2)]);</span>
<span class="line" id="L451">            } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (slot2 &lt; <span class="tok-number">0</span>) {</span>
<span class="line" id="L452">                q = q.sub(pc2[<span class="tok-builtin">@intCast</span>(<span class="tok-type">usize</span>, -slot2)]);</span>
<span class="line" id="L453">            }</span>
<span class="line" id="L454">            <span class="tok-kw">if</span> (pos == <span class="tok-number">0</span>) <span class="tok-kw">break</span>;</span>
<span class="line" id="L455">            q = q.dbl().dbl().dbl().dbl();</span>
<span class="line" id="L456">        }</span>
<span class="line" id="L457">        <span class="tok-kw">try</span> q.rejectIdentity();</span>
<span class="line" id="L458">        <span class="tok-kw">return</span> q;</span>
<span class="line" id="L459">    }</span>
<span class="line" id="L460">};</span>
<span class="line" id="L461"></span>
<span class="line" id="L462"><span class="tok-comment">/// A point in affine coordinates.</span></span>
<span class="line" id="L463"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> AffineCoordinates = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L464">    x: P384.Fe,</span>
<span class="line" id="L465">    y: P384.Fe,</span>
<span class="line" id="L466"></span>
<span class="line" id="L467">    <span class="tok-comment">/// Identity element in affine coordinates.</span></span>
<span class="line" id="L468">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> identityElement = AffineCoordinates{ .x = P384.identityElement.x, .y = P384.identityElement.y };</span>
<span class="line" id="L469"></span>
<span class="line" id="L470">    <span class="tok-kw">fn</span> <span class="tok-fn">cMov</span>(p: *AffineCoordinates, a: AffineCoordinates, c: <span class="tok-type">u1</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L471">        p.x.cMov(a.x, c);</span>
<span class="line" id="L472">        p.y.cMov(a.y, c);</span>
<span class="line" id="L473">    }</span>
<span class="line" id="L474">};</span>
<span class="line" id="L475"></span>
<span class="line" id="L476"><span class="tok-kw">test</span> <span class="tok-str">&quot;p384&quot;</span> {</span>
<span class="line" id="L477">    _ = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;tests/p384.zig&quot;</span>);</span>
<span class="line" id="L478">}</span>
<span class="line" id="L479"></span>
</code></pre></body>
</html>