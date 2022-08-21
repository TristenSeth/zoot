<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">    <title>math/big/rational.zig - source view</title>
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
<pre><code><span class="line" id="L1"><span class="tok-kw">const</span> std = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;../../std.zig&quot;</span>);</span>
<span class="line" id="L2"><span class="tok-kw">const</span> debug = std.debug;</span>
<span class="line" id="L3"><span class="tok-kw">const</span> math = std.math;</span>
<span class="line" id="L4"><span class="tok-kw">const</span> mem = std.mem;</span>
<span class="line" id="L5"><span class="tok-kw">const</span> testing = std.testing;</span>
<span class="line" id="L6"><span class="tok-kw">const</span> Allocator = mem.Allocator;</span>
<span class="line" id="L7"></span>
<span class="line" id="L8"><span class="tok-kw">const</span> Limb = std.math.big.Limb;</span>
<span class="line" id="L9"><span class="tok-kw">const</span> DoubleLimb = std.math.big.DoubleLimb;</span>
<span class="line" id="L10"><span class="tok-kw">const</span> Int = std.math.big.int.Managed;</span>
<span class="line" id="L11"><span class="tok-kw">const</span> IntConst = std.math.big.int.Const;</span>
<span class="line" id="L12"></span>
<span class="line" id="L13"><span class="tok-comment">/// An arbitrary-precision rational number.</span></span>
<span class="line" id="L14"><span class="tok-comment">///</span></span>
<span class="line" id="L15"><span class="tok-comment">/// Memory is allocated as needed for operations to ensure full precision is kept. The precision</span></span>
<span class="line" id="L16"><span class="tok-comment">/// of a Rational is only bounded by memory.</span></span>
<span class="line" id="L17"><span class="tok-comment">///</span></span>
<span class="line" id="L18"><span class="tok-comment">/// Rational's are always normalized. That is, for a Rational r = p/q where p and q are integers,</span></span>
<span class="line" id="L19"><span class="tok-comment">/// gcd(p, q) = 1 always.</span></span>
<span class="line" id="L20"><span class="tok-comment">///</span></span>
<span class="line" id="L21"><span class="tok-comment">/// TODO rework this to store its own allocator and use a non-managed big int, to avoid double</span></span>
<span class="line" id="L22"><span class="tok-comment">/// allocator storage.</span></span>
<span class="line" id="L23"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> Rational = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L24">    <span class="tok-comment">/// Numerator. Determines the sign of the Rational.</span></span>
<span class="line" id="L25">    p: Int,</span>
<span class="line" id="L26"></span>
<span class="line" id="L27">    <span class="tok-comment">/// Denominator. Sign is ignored.</span></span>
<span class="line" id="L28">    q: Int,</span>
<span class="line" id="L29"></span>
<span class="line" id="L30">    <span class="tok-comment">/// Create a new Rational. A small amount of memory will be allocated on initialization.</span></span>
<span class="line" id="L31">    <span class="tok-comment">/// This will be 2 * Int.default_capacity.</span></span>
<span class="line" id="L32">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">init</span>(a: Allocator) !Rational {</span>
<span class="line" id="L33">        <span class="tok-kw">return</span> Rational{</span>
<span class="line" id="L34">            .p = <span class="tok-kw">try</span> Int.init(a),</span>
<span class="line" id="L35">            .q = <span class="tok-kw">try</span> Int.initSet(a, <span class="tok-number">1</span>),</span>
<span class="line" id="L36">        };</span>
<span class="line" id="L37">    }</span>
<span class="line" id="L38"></span>
<span class="line" id="L39">    <span class="tok-comment">/// Frees all memory associated with a Rational.</span></span>
<span class="line" id="L40">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">deinit</span>(self: *Rational) <span class="tok-type">void</span> {</span>
<span class="line" id="L41">        self.p.deinit();</span>
<span class="line" id="L42">        self.q.deinit();</span>
<span class="line" id="L43">    }</span>
<span class="line" id="L44"></span>
<span class="line" id="L45">    <span class="tok-comment">/// Set a Rational from a primitive integer type.</span></span>
<span class="line" id="L46">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">setInt</span>(self: *Rational, a: <span class="tok-kw">anytype</span>) !<span class="tok-type">void</span> {</span>
<span class="line" id="L47">        <span class="tok-kw">try</span> self.p.set(a);</span>
<span class="line" id="L48">        <span class="tok-kw">try</span> self.q.set(<span class="tok-number">1</span>);</span>
<span class="line" id="L49">    }</span>
<span class="line" id="L50"></span>
<span class="line" id="L51">    <span class="tok-comment">/// Set a Rational from a string of the form `A/B` where A and B are base-10 integers.</span></span>
<span class="line" id="L52">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">setFloatString</span>(self: *Rational, str: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) !<span class="tok-type">void</span> {</span>
<span class="line" id="L53">        <span class="tok-comment">// TODO: Accept a/b fractions and exponent form</span>
</span>
<span class="line" id="L54">        <span class="tok-kw">if</span> (str.len == <span class="tok-number">0</span>) {</span>
<span class="line" id="L55">            <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InvalidFloatString;</span>
<span class="line" id="L56">        }</span>
<span class="line" id="L57"></span>
<span class="line" id="L58">        <span class="tok-kw">const</span> State = <span class="tok-kw">enum</span> {</span>
<span class="line" id="L59">            Integer,</span>
<span class="line" id="L60">            Fractional,</span>
<span class="line" id="L61">        };</span>
<span class="line" id="L62"></span>
<span class="line" id="L63">        <span class="tok-kw">var</span> state = State.Integer;</span>
<span class="line" id="L64">        <span class="tok-kw">var</span> point: ?<span class="tok-type">usize</span> = <span class="tok-null">null</span>;</span>
<span class="line" id="L65"></span>
<span class="line" id="L66">        <span class="tok-kw">var</span> start: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L67">        <span class="tok-kw">if</span> (str[<span class="tok-number">0</span>] == <span class="tok-str">'-'</span>) {</span>
<span class="line" id="L68">            start += <span class="tok-number">1</span>;</span>
<span class="line" id="L69">        }</span>
<span class="line" id="L70"></span>
<span class="line" id="L71">        <span class="tok-kw">for</span> (str) |c, i| {</span>
<span class="line" id="L72">            <span class="tok-kw">switch</span> (state) {</span>
<span class="line" id="L73">                State.Integer =&gt; {</span>
<span class="line" id="L74">                    <span class="tok-kw">switch</span> (c) {</span>
<span class="line" id="L75">                        <span class="tok-str">'.'</span> =&gt; {</span>
<span class="line" id="L76">                            state = State.Fractional;</span>
<span class="line" id="L77">                            point = i;</span>
<span class="line" id="L78">                        },</span>
<span class="line" id="L79">                        <span class="tok-str">'0'</span>...<span class="tok-str">'9'</span> =&gt; {</span>
<span class="line" id="L80">                            <span class="tok-comment">// okay</span>
</span>
<span class="line" id="L81">                        },</span>
<span class="line" id="L82">                        <span class="tok-kw">else</span> =&gt; {</span>
<span class="line" id="L83">                            <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InvalidFloatString;</span>
<span class="line" id="L84">                        },</span>
<span class="line" id="L85">                    }</span>
<span class="line" id="L86">                },</span>
<span class="line" id="L87">                State.Fractional =&gt; {</span>
<span class="line" id="L88">                    <span class="tok-kw">switch</span> (c) {</span>
<span class="line" id="L89">                        <span class="tok-str">'0'</span>...<span class="tok-str">'9'</span> =&gt; {</span>
<span class="line" id="L90">                            <span class="tok-comment">// okay</span>
</span>
<span class="line" id="L91">                        },</span>
<span class="line" id="L92">                        <span class="tok-kw">else</span> =&gt; {</span>
<span class="line" id="L93">                            <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InvalidFloatString;</span>
<span class="line" id="L94">                        },</span>
<span class="line" id="L95">                    }</span>
<span class="line" id="L96">                },</span>
<span class="line" id="L97">            }</span>
<span class="line" id="L98">        }</span>
<span class="line" id="L99"></span>
<span class="line" id="L100">        <span class="tok-comment">// TODO: batch the multiplies by 10</span>
</span>
<span class="line" id="L101">        <span class="tok-kw">if</span> (point) |i| {</span>
<span class="line" id="L102">            <span class="tok-kw">try</span> self.p.setString(<span class="tok-number">10</span>, str[<span class="tok-number">0</span>..i]);</span>
<span class="line" id="L103"></span>
<span class="line" id="L104">            <span class="tok-kw">const</span> base = IntConst{ .limbs = &amp;[_]Limb{<span class="tok-number">10</span>}, .positive = <span class="tok-null">true</span> };</span>
<span class="line" id="L105">            <span class="tok-kw">var</span> local_buf: [<span class="tok-builtin">@sizeOf</span>(Limb) * Int.default_capacity]<span class="tok-type">u8</span> <span class="tok-kw">align</span>(<span class="tok-builtin">@alignOf</span>(Limb)) = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L106">            <span class="tok-kw">var</span> fba = std.heap.FixedBufferAllocator.init(&amp;local_buf);</span>
<span class="line" id="L107">            <span class="tok-kw">const</span> base_managed = <span class="tok-kw">try</span> base.toManaged(fba.allocator());</span>
<span class="line" id="L108"></span>
<span class="line" id="L109">            <span class="tok-kw">var</span> j: <span class="tok-type">usize</span> = start;</span>
<span class="line" id="L110">            <span class="tok-kw">while</span> (j &lt; str.len - i - <span class="tok-number">1</span>) : (j += <span class="tok-number">1</span>) {</span>
<span class="line" id="L111">                <span class="tok-kw">try</span> self.p.ensureMulCapacity(self.p.toConst(), base);</span>
<span class="line" id="L112">                <span class="tok-kw">try</span> self.p.mul(&amp;self.p, &amp;base_managed);</span>
<span class="line" id="L113">            }</span>
<span class="line" id="L114"></span>
<span class="line" id="L115">            <span class="tok-kw">try</span> self.q.setString(<span class="tok-number">10</span>, str[i + <span class="tok-number">1</span> ..]);</span>
<span class="line" id="L116">            <span class="tok-kw">try</span> self.p.add(&amp;self.p, &amp;self.q);</span>
<span class="line" id="L117"></span>
<span class="line" id="L118">            <span class="tok-kw">try</span> self.q.set(<span class="tok-number">1</span>);</span>
<span class="line" id="L119">            <span class="tok-kw">var</span> k: <span class="tok-type">usize</span> = i + <span class="tok-number">1</span>;</span>
<span class="line" id="L120">            <span class="tok-kw">while</span> (k &lt; str.len) : (k += <span class="tok-number">1</span>) {</span>
<span class="line" id="L121">                <span class="tok-kw">try</span> self.q.mul(&amp;self.q, &amp;base_managed);</span>
<span class="line" id="L122">            }</span>
<span class="line" id="L123"></span>
<span class="line" id="L124">            <span class="tok-kw">try</span> self.reduce();</span>
<span class="line" id="L125">        } <span class="tok-kw">else</span> {</span>
<span class="line" id="L126">            <span class="tok-kw">try</span> self.p.setString(<span class="tok-number">10</span>, str[<span class="tok-number">0</span>..]);</span>
<span class="line" id="L127">            <span class="tok-kw">try</span> self.q.set(<span class="tok-number">1</span>);</span>
<span class="line" id="L128">        }</span>
<span class="line" id="L129">    }</span>
<span class="line" id="L130"></span>
<span class="line" id="L131">    <span class="tok-comment">/// Set a Rational from a floating-point value. The rational will have enough precision to</span></span>
<span class="line" id="L132">    <span class="tok-comment">/// completely represent the provided float.</span></span>
<span class="line" id="L133">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">setFloat</span>(self: *Rational, <span class="tok-kw">comptime</span> T: <span class="tok-type">type</span>, f: T) !<span class="tok-type">void</span> {</span>
<span class="line" id="L134">        <span class="tok-comment">// Translated from golang.go/src/math/big/rat.go.</span>
</span>
<span class="line" id="L135">        debug.assert(<span class="tok-builtin">@typeInfo</span>(T) == .Float);</span>
<span class="line" id="L136"></span>
<span class="line" id="L137">        <span class="tok-kw">const</span> UnsignedInt = std.meta.Int(.unsigned, <span class="tok-builtin">@typeInfo</span>(T).Float.bits);</span>
<span class="line" id="L138">        <span class="tok-kw">const</span> f_bits = <span class="tok-builtin">@bitCast</span>(UnsignedInt, f);</span>
<span class="line" id="L139"></span>
<span class="line" id="L140">        <span class="tok-kw">const</span> exponent_bits = math.floatExponentBits(T);</span>
<span class="line" id="L141">        <span class="tok-kw">const</span> exponent_bias = (<span class="tok-number">1</span> &lt;&lt; (exponent_bits - <span class="tok-number">1</span>)) - <span class="tok-number">1</span>;</span>
<span class="line" id="L142">        <span class="tok-kw">const</span> mantissa_bits = math.floatMantissaBits(T);</span>
<span class="line" id="L143"></span>
<span class="line" id="L144">        <span class="tok-kw">const</span> exponent_mask = (<span class="tok-number">1</span> &lt;&lt; exponent_bits) - <span class="tok-number">1</span>;</span>
<span class="line" id="L145">        <span class="tok-kw">const</span> mantissa_mask = (<span class="tok-number">1</span> &lt;&lt; mantissa_bits) - <span class="tok-number">1</span>;</span>
<span class="line" id="L146"></span>
<span class="line" id="L147">        <span class="tok-kw">var</span> exponent = <span class="tok-builtin">@intCast</span>(<span class="tok-type">i16</span>, (f_bits &gt;&gt; mantissa_bits) &amp; exponent_mask);</span>
<span class="line" id="L148">        <span class="tok-kw">var</span> mantissa = f_bits &amp; mantissa_mask;</span>
<span class="line" id="L149"></span>
<span class="line" id="L150">        <span class="tok-kw">switch</span> (exponent) {</span>
<span class="line" id="L151">            exponent_mask =&gt; {</span>
<span class="line" id="L152">                <span class="tok-kw">return</span> <span class="tok-kw">error</span>.NonFiniteFloat;</span>
<span class="line" id="L153">            },</span>
<span class="line" id="L154">            <span class="tok-number">0</span> =&gt; {</span>
<span class="line" id="L155">                <span class="tok-comment">// denormal</span>
</span>
<span class="line" id="L156">                exponent -= exponent_bias - <span class="tok-number">1</span>;</span>
<span class="line" id="L157">            },</span>
<span class="line" id="L158">            <span class="tok-kw">else</span> =&gt; {</span>
<span class="line" id="L159">                <span class="tok-comment">// normal</span>
</span>
<span class="line" id="L160">                mantissa |= <span class="tok-number">1</span> &lt;&lt; mantissa_bits;</span>
<span class="line" id="L161">                exponent -= exponent_bias;</span>
<span class="line" id="L162">            },</span>
<span class="line" id="L163">        }</span>
<span class="line" id="L164"></span>
<span class="line" id="L165">        <span class="tok-kw">var</span> shift: <span class="tok-type">i16</span> = mantissa_bits - exponent;</span>
<span class="line" id="L166"></span>
<span class="line" id="L167">        <span class="tok-comment">// factor out powers of two early from rational</span>
</span>
<span class="line" id="L168">        <span class="tok-kw">while</span> (mantissa &amp; <span class="tok-number">1</span> == <span class="tok-number">0</span> <span class="tok-kw">and</span> shift &gt; <span class="tok-number">0</span>) {</span>
<span class="line" id="L169">            mantissa &gt;&gt;= <span class="tok-number">1</span>;</span>
<span class="line" id="L170">            shift -= <span class="tok-number">1</span>;</span>
<span class="line" id="L171">        }</span>
<span class="line" id="L172"></span>
<span class="line" id="L173">        <span class="tok-kw">try</span> self.p.set(mantissa);</span>
<span class="line" id="L174">        self.p.setSign(f &gt;= <span class="tok-number">0</span>);</span>
<span class="line" id="L175"></span>
<span class="line" id="L176">        <span class="tok-kw">try</span> self.q.set(<span class="tok-number">1</span>);</span>
<span class="line" id="L177">        <span class="tok-kw">if</span> (shift &gt;= <span class="tok-number">0</span>) {</span>
<span class="line" id="L178">            <span class="tok-kw">try</span> self.q.shiftLeft(&amp;self.q, <span class="tok-builtin">@intCast</span>(<span class="tok-type">usize</span>, shift));</span>
<span class="line" id="L179">        } <span class="tok-kw">else</span> {</span>
<span class="line" id="L180">            <span class="tok-kw">try</span> self.p.shiftLeft(&amp;self.p, <span class="tok-builtin">@intCast</span>(<span class="tok-type">usize</span>, -shift));</span>
<span class="line" id="L181">        }</span>
<span class="line" id="L182"></span>
<span class="line" id="L183">        <span class="tok-kw">try</span> self.reduce();</span>
<span class="line" id="L184">    }</span>
<span class="line" id="L185"></span>
<span class="line" id="L186">    <span class="tok-comment">/// Return a floating-point value that is the closest value to a Rational.</span></span>
<span class="line" id="L187">    <span class="tok-comment">///</span></span>
<span class="line" id="L188">    <span class="tok-comment">/// The result may not be exact if the Rational is too precise or too large for the</span></span>
<span class="line" id="L189">    <span class="tok-comment">/// target type.</span></span>
<span class="line" id="L190">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">toFloat</span>(self: Rational, <span class="tok-kw">comptime</span> T: <span class="tok-type">type</span>) !T {</span>
<span class="line" id="L191">        <span class="tok-comment">// Translated from golang.go/src/math/big/rat.go.</span>
</span>
<span class="line" id="L192">        <span class="tok-comment">// TODO: Indicate whether the result is not exact.</span>
</span>
<span class="line" id="L193">        debug.assert(<span class="tok-builtin">@typeInfo</span>(T) == .Float);</span>
<span class="line" id="L194"></span>
<span class="line" id="L195">        <span class="tok-kw">const</span> fsize = <span class="tok-builtin">@typeInfo</span>(T).Float.bits;</span>
<span class="line" id="L196">        <span class="tok-kw">const</span> BitReprType = std.meta.Int(.unsigned, fsize);</span>
<span class="line" id="L197"></span>
<span class="line" id="L198">        <span class="tok-kw">const</span> msize = math.floatMantissaBits(T);</span>
<span class="line" id="L199">        <span class="tok-kw">const</span> msize1 = msize + <span class="tok-number">1</span>;</span>
<span class="line" id="L200">        <span class="tok-kw">const</span> msize2 = msize1 + <span class="tok-number">1</span>;</span>
<span class="line" id="L201"></span>
<span class="line" id="L202">        <span class="tok-kw">const</span> esize = math.floatExponentBits(T);</span>
<span class="line" id="L203">        <span class="tok-kw">const</span> ebias = (<span class="tok-number">1</span> &lt;&lt; (esize - <span class="tok-number">1</span>)) - <span class="tok-number">1</span>;</span>
<span class="line" id="L204">        <span class="tok-kw">const</span> emin = <span class="tok-number">1</span> - ebias;</span>
<span class="line" id="L205"></span>
<span class="line" id="L206">        <span class="tok-kw">if</span> (self.p.eqZero()) {</span>
<span class="line" id="L207">            <span class="tok-kw">return</span> <span class="tok-number">0</span>;</span>
<span class="line" id="L208">        }</span>
<span class="line" id="L209"></span>
<span class="line" id="L210">        <span class="tok-comment">// 1. left-shift a or sub so that a/b is in [1 &lt;&lt; msize1, 1 &lt;&lt; (msize2 + 1)]</span>
</span>
<span class="line" id="L211">        <span class="tok-kw">var</span> exp = <span class="tok-builtin">@intCast</span>(<span class="tok-type">isize</span>, self.p.bitCountTwosComp()) - <span class="tok-builtin">@intCast</span>(<span class="tok-type">isize</span>, self.q.bitCountTwosComp());</span>
<span class="line" id="L212"></span>
<span class="line" id="L213">        <span class="tok-kw">var</span> a2 = <span class="tok-kw">try</span> self.p.clone();</span>
<span class="line" id="L214">        <span class="tok-kw">defer</span> a2.deinit();</span>
<span class="line" id="L215"></span>
<span class="line" id="L216">        <span class="tok-kw">var</span> b2 = <span class="tok-kw">try</span> self.q.clone();</span>
<span class="line" id="L217">        <span class="tok-kw">defer</span> b2.deinit();</span>
<span class="line" id="L218"></span>
<span class="line" id="L219">        <span class="tok-kw">const</span> shift = msize2 - exp;</span>
<span class="line" id="L220">        <span class="tok-kw">if</span> (shift &gt;= <span class="tok-number">0</span>) {</span>
<span class="line" id="L221">            <span class="tok-kw">try</span> a2.shiftLeft(&amp;a2, <span class="tok-builtin">@intCast</span>(<span class="tok-type">usize</span>, shift));</span>
<span class="line" id="L222">        } <span class="tok-kw">else</span> {</span>
<span class="line" id="L223">            <span class="tok-kw">try</span> b2.shiftLeft(&amp;b2, <span class="tok-builtin">@intCast</span>(<span class="tok-type">usize</span>, -shift));</span>
<span class="line" id="L224">        }</span>
<span class="line" id="L225"></span>
<span class="line" id="L226">        <span class="tok-comment">// 2. compute quotient and remainder</span>
</span>
<span class="line" id="L227">        <span class="tok-kw">var</span> q = <span class="tok-kw">try</span> Int.init(self.p.allocator);</span>
<span class="line" id="L228">        <span class="tok-kw">defer</span> q.deinit();</span>
<span class="line" id="L229"></span>
<span class="line" id="L230">        <span class="tok-comment">// unused</span>
</span>
<span class="line" id="L231">        <span class="tok-kw">var</span> r = <span class="tok-kw">try</span> Int.init(self.p.allocator);</span>
<span class="line" id="L232">        <span class="tok-kw">defer</span> r.deinit();</span>
<span class="line" id="L233"></span>
<span class="line" id="L234">        <span class="tok-kw">try</span> Int.divTrunc(&amp;q, &amp;r, &amp;a2, &amp;b2);</span>
<span class="line" id="L235"></span>
<span class="line" id="L236">        <span class="tok-kw">var</span> mantissa = extractLowBits(q, BitReprType);</span>
<span class="line" id="L237">        <span class="tok-kw">var</span> have_rem = r.len() &gt; <span class="tok-number">0</span>;</span>
<span class="line" id="L238"></span>
<span class="line" id="L239">        <span class="tok-comment">// 3. q didn't fit in msize2 bits, redo division b2 &lt;&lt; 1</span>
</span>
<span class="line" id="L240">        <span class="tok-kw">if</span> (mantissa &gt;&gt; msize2 == <span class="tok-number">1</span>) {</span>
<span class="line" id="L241">            <span class="tok-kw">if</span> (mantissa &amp; <span class="tok-number">1</span> == <span class="tok-number">1</span>) {</span>
<span class="line" id="L242">                have_rem = <span class="tok-null">true</span>;</span>
<span class="line" id="L243">            }</span>
<span class="line" id="L244">            mantissa &gt;&gt;= <span class="tok-number">1</span>;</span>
<span class="line" id="L245">            exp += <span class="tok-number">1</span>;</span>
<span class="line" id="L246">        }</span>
<span class="line" id="L247">        <span class="tok-kw">if</span> (mantissa &gt;&gt; msize1 != <span class="tok-number">1</span>) {</span>
<span class="line" id="L248">            <span class="tok-comment">// NOTE: This can be hit if the limb size is small (u8/16).</span>
</span>
<span class="line" id="L249">            <span class="tok-builtin">@panic</span>(<span class="tok-str">&quot;unexpected bits in result&quot;</span>);</span>
<span class="line" id="L250">        }</span>
<span class="line" id="L251"></span>
<span class="line" id="L252">        <span class="tok-comment">// 4. Rounding</span>
</span>
<span class="line" id="L253">        <span class="tok-kw">if</span> (emin - msize &lt;= exp <span class="tok-kw">and</span> exp &lt;= emin) {</span>
<span class="line" id="L254">            <span class="tok-comment">// denormal</span>
</span>
<span class="line" id="L255">            <span class="tok-kw">const</span> shift1 = <span class="tok-builtin">@intCast</span>(math.Log2Int(BitReprType), emin - (exp - <span class="tok-number">1</span>));</span>
<span class="line" id="L256">            <span class="tok-kw">const</span> lost_bits = mantissa &amp; ((<span class="tok-builtin">@intCast</span>(BitReprType, <span class="tok-number">1</span>) &lt;&lt; shift1) - <span class="tok-number">1</span>);</span>
<span class="line" id="L257">            have_rem = have_rem <span class="tok-kw">or</span> lost_bits != <span class="tok-number">0</span>;</span>
<span class="line" id="L258">            mantissa &gt;&gt;= shift1;</span>
<span class="line" id="L259">            exp = <span class="tok-number">2</span> - ebias;</span>
<span class="line" id="L260">        }</span>
<span class="line" id="L261"></span>
<span class="line" id="L262">        <span class="tok-comment">// round q using round-half-to-even</span>
</span>
<span class="line" id="L263">        <span class="tok-kw">var</span> exact = !have_rem;</span>
<span class="line" id="L264">        <span class="tok-kw">if</span> (mantissa &amp; <span class="tok-number">1</span> != <span class="tok-number">0</span>) {</span>
<span class="line" id="L265">            exact = <span class="tok-null">false</span>;</span>
<span class="line" id="L266">            <span class="tok-kw">if</span> (have_rem <span class="tok-kw">or</span> (mantissa &amp; <span class="tok-number">2</span> != <span class="tok-number">0</span>)) {</span>
<span class="line" id="L267">                mantissa += <span class="tok-number">1</span>;</span>
<span class="line" id="L268">                <span class="tok-kw">if</span> (mantissa &gt;= <span class="tok-number">1</span> &lt;&lt; msize2) {</span>
<span class="line" id="L269">                    <span class="tok-comment">// 11...1 =&gt; 100...0</span>
</span>
<span class="line" id="L270">                    mantissa &gt;&gt;= <span class="tok-number">1</span>;</span>
<span class="line" id="L271">                    exp += <span class="tok-number">1</span>;</span>
<span class="line" id="L272">                }</span>
<span class="line" id="L273">            }</span>
<span class="line" id="L274">        }</span>
<span class="line" id="L275">        mantissa &gt;&gt;= <span class="tok-number">1</span>;</span>
<span class="line" id="L276"></span>
<span class="line" id="L277">        <span class="tok-kw">const</span> f = math.scalbn(<span class="tok-builtin">@intToFloat</span>(T, mantissa), <span class="tok-builtin">@intCast</span>(<span class="tok-type">i32</span>, exp - msize1));</span>
<span class="line" id="L278">        <span class="tok-kw">if</span> (math.isInf(f)) {</span>
<span class="line" id="L279">            exact = <span class="tok-null">false</span>;</span>
<span class="line" id="L280">        }</span>
<span class="line" id="L281"></span>
<span class="line" id="L282">        <span class="tok-kw">return</span> <span class="tok-kw">if</span> (self.p.isPositive()) f <span class="tok-kw">else</span> -f;</span>
<span class="line" id="L283">    }</span>
<span class="line" id="L284"></span>
<span class="line" id="L285">    <span class="tok-comment">/// Set a rational from an integer ratio.</span></span>
<span class="line" id="L286">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">setRatio</span>(self: *Rational, p: <span class="tok-kw">anytype</span>, q: <span class="tok-kw">anytype</span>) !<span class="tok-type">void</span> {</span>
<span class="line" id="L287">        <span class="tok-kw">try</span> self.p.set(p);</span>
<span class="line" id="L288">        <span class="tok-kw">try</span> self.q.set(q);</span>
<span class="line" id="L289"></span>
<span class="line" id="L290">        self.p.setSign(<span class="tok-builtin">@boolToInt</span>(self.p.isPositive()) ^ <span class="tok-builtin">@boolToInt</span>(self.q.isPositive()) == <span class="tok-number">0</span>);</span>
<span class="line" id="L291">        self.q.setSign(<span class="tok-null">true</span>);</span>
<span class="line" id="L292"></span>
<span class="line" id="L293">        <span class="tok-kw">try</span> self.reduce();</span>
<span class="line" id="L294"></span>
<span class="line" id="L295">        <span class="tok-kw">if</span> (self.q.eqZero()) {</span>
<span class="line" id="L296">            <span class="tok-builtin">@panic</span>(<span class="tok-str">&quot;cannot set rational with denominator = 0&quot;</span>);</span>
<span class="line" id="L297">        }</span>
<span class="line" id="L298">    }</span>
<span class="line" id="L299"></span>
<span class="line" id="L300">    <span class="tok-comment">/// Set a Rational directly from an Int.</span></span>
<span class="line" id="L301">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">copyInt</span>(self: *Rational, a: Int) !<span class="tok-type">void</span> {</span>
<span class="line" id="L302">        <span class="tok-kw">try</span> self.p.copy(a.toConst());</span>
<span class="line" id="L303">        <span class="tok-kw">try</span> self.q.set(<span class="tok-number">1</span>);</span>
<span class="line" id="L304">    }</span>
<span class="line" id="L305"></span>
<span class="line" id="L306">    <span class="tok-comment">/// Set a Rational directly from a ratio of two Int's.</span></span>
<span class="line" id="L307">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">copyRatio</span>(self: *Rational, a: Int, b: Int) !<span class="tok-type">void</span> {</span>
<span class="line" id="L308">        <span class="tok-kw">try</span> self.p.copy(a.toConst());</span>
<span class="line" id="L309">        <span class="tok-kw">try</span> self.q.copy(b.toConst());</span>
<span class="line" id="L310"></span>
<span class="line" id="L311">        self.p.setSign(<span class="tok-builtin">@boolToInt</span>(self.p.isPositive()) ^ <span class="tok-builtin">@boolToInt</span>(self.q.isPositive()) == <span class="tok-number">0</span>);</span>
<span class="line" id="L312">        self.q.setSign(<span class="tok-null">true</span>);</span>
<span class="line" id="L313"></span>
<span class="line" id="L314">        <span class="tok-kw">try</span> self.reduce();</span>
<span class="line" id="L315">    }</span>
<span class="line" id="L316"></span>
<span class="line" id="L317">    <span class="tok-comment">/// Make a Rational positive.</span></span>
<span class="line" id="L318">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">abs</span>(r: *Rational) <span class="tok-type">void</span> {</span>
<span class="line" id="L319">        r.p.abs();</span>
<span class="line" id="L320">    }</span>
<span class="line" id="L321"></span>
<span class="line" id="L322">    <span class="tok-comment">/// Negate the sign of a Rational.</span></span>
<span class="line" id="L323">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">negate</span>(r: *Rational) <span class="tok-type">void</span> {</span>
<span class="line" id="L324">        r.p.negate();</span>
<span class="line" id="L325">    }</span>
<span class="line" id="L326"></span>
<span class="line" id="L327">    <span class="tok-comment">/// Efficiently swap a Rational with another. This swaps the limb pointers and a full copy is not</span></span>
<span class="line" id="L328">    <span class="tok-comment">/// performed. The address of the limbs field will not be the same after this function.</span></span>
<span class="line" id="L329">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">swap</span>(r: *Rational, other: *Rational) <span class="tok-type">void</span> {</span>
<span class="line" id="L330">        r.p.swap(&amp;other.p);</span>
<span class="line" id="L331">        r.q.swap(&amp;other.q);</span>
<span class="line" id="L332">    }</span>
<span class="line" id="L333"></span>
<span class="line" id="L334">    <span class="tok-comment">/// Returns math.Order.lt, math.Order.eq, math.Order.gt if a &lt; b, a == b or a</span></span>
<span class="line" id="L335">    <span class="tok-comment">/// &gt; b respectively.</span></span>
<span class="line" id="L336">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">order</span>(a: Rational, b: Rational) !math.Order {</span>
<span class="line" id="L337">        <span class="tok-kw">return</span> cmpInternal(a, b, <span class="tok-null">true</span>);</span>
<span class="line" id="L338">    }</span>
<span class="line" id="L339"></span>
<span class="line" id="L340">    <span class="tok-comment">/// Returns math.Order.lt, math.Order.eq, math.Order.gt if |a| &lt; |b|, |a| ==</span></span>
<span class="line" id="L341">    <span class="tok-comment">/// |b| or |a| &gt; |b| respectively.</span></span>
<span class="line" id="L342">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">orderAbs</span>(a: Rational, b: Rational) !math.Order {</span>
<span class="line" id="L343">        <span class="tok-kw">return</span> cmpInternal(a, b, <span class="tok-null">false</span>);</span>
<span class="line" id="L344">    }</span>
<span class="line" id="L345"></span>
<span class="line" id="L346">    <span class="tok-comment">// p/q &gt; x/y iff p*y &gt; x*q</span>
</span>
<span class="line" id="L347">    <span class="tok-kw">fn</span> <span class="tok-fn">cmpInternal</span>(a: Rational, b: Rational, is_abs: <span class="tok-type">bool</span>) !math.Order {</span>
<span class="line" id="L348">        <span class="tok-comment">// TODO: Would a div compare algorithm of sorts be viable and quicker? Can we avoid</span>
</span>
<span class="line" id="L349">        <span class="tok-comment">// the memory allocations here?</span>
</span>
<span class="line" id="L350">        <span class="tok-kw">var</span> q = <span class="tok-kw">try</span> Int.init(a.p.allocator);</span>
<span class="line" id="L351">        <span class="tok-kw">defer</span> q.deinit();</span>
<span class="line" id="L352"></span>
<span class="line" id="L353">        <span class="tok-kw">var</span> p = <span class="tok-kw">try</span> Int.init(b.p.allocator);</span>
<span class="line" id="L354">        <span class="tok-kw">defer</span> p.deinit();</span>
<span class="line" id="L355"></span>
<span class="line" id="L356">        <span class="tok-kw">try</span> q.mul(&amp;a.p, &amp;b.q);</span>
<span class="line" id="L357">        <span class="tok-kw">try</span> p.mul(&amp;b.p, &amp;a.q);</span>
<span class="line" id="L358"></span>
<span class="line" id="L359">        <span class="tok-kw">return</span> <span class="tok-kw">if</span> (is_abs) q.orderAbs(p) <span class="tok-kw">else</span> q.order(p);</span>
<span class="line" id="L360">    }</span>
<span class="line" id="L361"></span>
<span class="line" id="L362">    <span class="tok-comment">/// rma = a + b.</span></span>
<span class="line" id="L363">    <span class="tok-comment">///</span></span>
<span class="line" id="L364">    <span class="tok-comment">/// rma, a and b may be aliases. However, it is more efficient if rma does not alias a or b.</span></span>
<span class="line" id="L365">    <span class="tok-comment">///</span></span>
<span class="line" id="L366">    <span class="tok-comment">/// Returns an error if memory could not be allocated.</span></span>
<span class="line" id="L367">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">add</span>(rma: *Rational, a: Rational, b: Rational) !<span class="tok-type">void</span> {</span>
<span class="line" id="L368">        <span class="tok-kw">var</span> r = rma;</span>
<span class="line" id="L369">        <span class="tok-kw">var</span> aliased = rma.p.limbs.ptr == a.p.limbs.ptr <span class="tok-kw">or</span> rma.p.limbs.ptr == b.p.limbs.ptr;</span>
<span class="line" id="L370"></span>
<span class="line" id="L371">        <span class="tok-kw">var</span> sr: Rational = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L372">        <span class="tok-kw">if</span> (aliased) {</span>
<span class="line" id="L373">            sr = <span class="tok-kw">try</span> Rational.init(rma.p.allocator);</span>
<span class="line" id="L374">            r = &amp;sr;</span>
<span class="line" id="L375">            aliased = <span class="tok-null">true</span>;</span>
<span class="line" id="L376">        }</span>
<span class="line" id="L377">        <span class="tok-kw">defer</span> <span class="tok-kw">if</span> (aliased) {</span>
<span class="line" id="L378">            rma.swap(r);</span>
<span class="line" id="L379">            r.deinit();</span>
<span class="line" id="L380">        };</span>
<span class="line" id="L381"></span>
<span class="line" id="L382">        <span class="tok-kw">try</span> r.p.mul(&amp;a.p, &amp;b.q);</span>
<span class="line" id="L383">        <span class="tok-kw">try</span> r.q.mul(&amp;b.p, &amp;a.q);</span>
<span class="line" id="L384">        <span class="tok-kw">try</span> r.p.add(&amp;r.p, &amp;r.q);</span>
<span class="line" id="L385"></span>
<span class="line" id="L386">        <span class="tok-kw">try</span> r.q.mul(&amp;a.q, &amp;b.q);</span>
<span class="line" id="L387">        <span class="tok-kw">try</span> r.reduce();</span>
<span class="line" id="L388">    }</span>
<span class="line" id="L389"></span>
<span class="line" id="L390">    <span class="tok-comment">/// rma = a - b.</span></span>
<span class="line" id="L391">    <span class="tok-comment">///</span></span>
<span class="line" id="L392">    <span class="tok-comment">/// rma, a and b may be aliases. However, it is more efficient if rma does not alias a or b.</span></span>
<span class="line" id="L393">    <span class="tok-comment">///</span></span>
<span class="line" id="L394">    <span class="tok-comment">/// Returns an error if memory could not be allocated.</span></span>
<span class="line" id="L395">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">sub</span>(rma: *Rational, a: Rational, b: Rational) !<span class="tok-type">void</span> {</span>
<span class="line" id="L396">        <span class="tok-kw">var</span> r = rma;</span>
<span class="line" id="L397">        <span class="tok-kw">var</span> aliased = rma.p.limbs.ptr == a.p.limbs.ptr <span class="tok-kw">or</span> rma.p.limbs.ptr == b.p.limbs.ptr;</span>
<span class="line" id="L398"></span>
<span class="line" id="L399">        <span class="tok-kw">var</span> sr: Rational = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L400">        <span class="tok-kw">if</span> (aliased) {</span>
<span class="line" id="L401">            sr = <span class="tok-kw">try</span> Rational.init(rma.p.allocator);</span>
<span class="line" id="L402">            r = &amp;sr;</span>
<span class="line" id="L403">            aliased = <span class="tok-null">true</span>;</span>
<span class="line" id="L404">        }</span>
<span class="line" id="L405">        <span class="tok-kw">defer</span> <span class="tok-kw">if</span> (aliased) {</span>
<span class="line" id="L406">            rma.swap(r);</span>
<span class="line" id="L407">            r.deinit();</span>
<span class="line" id="L408">        };</span>
<span class="line" id="L409"></span>
<span class="line" id="L410">        <span class="tok-kw">try</span> r.p.mul(&amp;a.p, &amp;b.q);</span>
<span class="line" id="L411">        <span class="tok-kw">try</span> r.q.mul(&amp;b.p, &amp;a.q);</span>
<span class="line" id="L412">        <span class="tok-kw">try</span> r.p.sub(&amp;r.p, &amp;r.q);</span>
<span class="line" id="L413"></span>
<span class="line" id="L414">        <span class="tok-kw">try</span> r.q.mul(&amp;a.q, &amp;b.q);</span>
<span class="line" id="L415">        <span class="tok-kw">try</span> r.reduce();</span>
<span class="line" id="L416">    }</span>
<span class="line" id="L417"></span>
<span class="line" id="L418">    <span class="tok-comment">/// rma = a * b.</span></span>
<span class="line" id="L419">    <span class="tok-comment">///</span></span>
<span class="line" id="L420">    <span class="tok-comment">/// rma, a and b may be aliases. However, it is more efficient if rma does not alias a or b.</span></span>
<span class="line" id="L421">    <span class="tok-comment">///</span></span>
<span class="line" id="L422">    <span class="tok-comment">/// Returns an error if memory could not be allocated.</span></span>
<span class="line" id="L423">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">mul</span>(r: *Rational, a: Rational, b: Rational) !<span class="tok-type">void</span> {</span>
<span class="line" id="L424">        <span class="tok-kw">try</span> r.p.mul(&amp;a.p, &amp;b.p);</span>
<span class="line" id="L425">        <span class="tok-kw">try</span> r.q.mul(&amp;a.q, &amp;b.q);</span>
<span class="line" id="L426">        <span class="tok-kw">try</span> r.reduce();</span>
<span class="line" id="L427">    }</span>
<span class="line" id="L428"></span>
<span class="line" id="L429">    <span class="tok-comment">/// rma = a / b.</span></span>
<span class="line" id="L430">    <span class="tok-comment">///</span></span>
<span class="line" id="L431">    <span class="tok-comment">/// rma, a and b may be aliases. However, it is more efficient if rma does not alias a or b.</span></span>
<span class="line" id="L432">    <span class="tok-comment">///</span></span>
<span class="line" id="L433">    <span class="tok-comment">/// Returns an error if memory could not be allocated.</span></span>
<span class="line" id="L434">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">div</span>(r: *Rational, a: Rational, b: Rational) !<span class="tok-type">void</span> {</span>
<span class="line" id="L435">        <span class="tok-kw">if</span> (b.p.eqZero()) {</span>
<span class="line" id="L436">            <span class="tok-builtin">@panic</span>(<span class="tok-str">&quot;division by zero&quot;</span>);</span>
<span class="line" id="L437">        }</span>
<span class="line" id="L438"></span>
<span class="line" id="L439">        <span class="tok-kw">try</span> r.p.mul(&amp;a.p, &amp;b.q);</span>
<span class="line" id="L440">        <span class="tok-kw">try</span> r.q.mul(&amp;b.p, &amp;a.q);</span>
<span class="line" id="L441">        <span class="tok-kw">try</span> r.reduce();</span>
<span class="line" id="L442">    }</span>
<span class="line" id="L443"></span>
<span class="line" id="L444">    <span class="tok-comment">/// Invert the numerator and denominator fields of a Rational. p/q =&gt; q/p.</span></span>
<span class="line" id="L445">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">invert</span>(r: *Rational) <span class="tok-type">void</span> {</span>
<span class="line" id="L446">        Int.swap(&amp;r.p, &amp;r.q);</span>
<span class="line" id="L447">    }</span>
<span class="line" id="L448"></span>
<span class="line" id="L449">    <span class="tok-comment">// reduce r/q such that gcd(r, q) = 1</span>
</span>
<span class="line" id="L450">    <span class="tok-kw">fn</span> <span class="tok-fn">reduce</span>(r: *Rational) !<span class="tok-type">void</span> {</span>
<span class="line" id="L451">        <span class="tok-kw">var</span> a = <span class="tok-kw">try</span> Int.init(r.p.allocator);</span>
<span class="line" id="L452">        <span class="tok-kw">defer</span> a.deinit();</span>
<span class="line" id="L453"></span>
<span class="line" id="L454">        <span class="tok-kw">const</span> sign = r.p.isPositive();</span>
<span class="line" id="L455">        r.p.abs();</span>
<span class="line" id="L456">        <span class="tok-kw">try</span> a.gcd(&amp;r.p, &amp;r.q);</span>
<span class="line" id="L457">        r.p.setSign(sign);</span>
<span class="line" id="L458"></span>
<span class="line" id="L459">        <span class="tok-kw">const</span> one = IntConst{ .limbs = &amp;[_]Limb{<span class="tok-number">1</span>}, .positive = <span class="tok-null">true</span> };</span>
<span class="line" id="L460">        <span class="tok-kw">if</span> (a.toConst().order(one) != .eq) {</span>
<span class="line" id="L461">            <span class="tok-kw">var</span> unused = <span class="tok-kw">try</span> Int.init(r.p.allocator);</span>
<span class="line" id="L462">            <span class="tok-kw">defer</span> unused.deinit();</span>
<span class="line" id="L463"></span>
<span class="line" id="L464">            <span class="tok-comment">// TODO: divexact would be useful here</span>
</span>
<span class="line" id="L465">            <span class="tok-comment">// TODO: don't copy r.q for div</span>
</span>
<span class="line" id="L466">            <span class="tok-kw">try</span> Int.divTrunc(&amp;r.p, &amp;unused, &amp;r.p, &amp;a);</span>
<span class="line" id="L467">            <span class="tok-kw">try</span> Int.divTrunc(&amp;r.q, &amp;unused, &amp;r.q, &amp;a);</span>
<span class="line" id="L468">        }</span>
<span class="line" id="L469">    }</span>
<span class="line" id="L470">};</span>
<span class="line" id="L471"></span>
<span class="line" id="L472"><span class="tok-kw">fn</span> <span class="tok-fn">extractLowBits</span>(a: Int, <span class="tok-kw">comptime</span> T: <span class="tok-type">type</span>) T {</span>
<span class="line" id="L473">    debug.assert(<span class="tok-builtin">@typeInfo</span>(T) == .Int);</span>
<span class="line" id="L474"></span>
<span class="line" id="L475">    <span class="tok-kw">const</span> t_bits = <span class="tok-builtin">@typeInfo</span>(T).Int.bits;</span>
<span class="line" id="L476">    <span class="tok-kw">const</span> limb_bits = <span class="tok-builtin">@typeInfo</span>(Limb).Int.bits;</span>
<span class="line" id="L477">    <span class="tok-kw">if</span> (t_bits &lt;= limb_bits) {</span>
<span class="line" id="L478">        <span class="tok-kw">return</span> <span class="tok-builtin">@truncate</span>(T, a.limbs[<span class="tok-number">0</span>]);</span>
<span class="line" id="L479">    } <span class="tok-kw">else</span> {</span>
<span class="line" id="L480">        <span class="tok-kw">var</span> r: T = <span class="tok-number">0</span>;</span>
<span class="line" id="L481">        <span class="tok-kw">comptime</span> <span class="tok-kw">var</span> i: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L482"></span>
<span class="line" id="L483">        <span class="tok-comment">// Remainder is always 0 since if t_bits &gt;= limb_bits -&gt; Limb | T and both</span>
</span>
<span class="line" id="L484">        <span class="tok-comment">// are powers of two.</span>
</span>
<span class="line" id="L485">        <span class="tok-kw">inline</span> <span class="tok-kw">while</span> (i &lt; t_bits / limb_bits) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L486">            r |= math.shl(T, a.limbs[i], i * limb_bits);</span>
<span class="line" id="L487">        }</span>
<span class="line" id="L488"></span>
<span class="line" id="L489">        <span class="tok-kw">return</span> r;</span>
<span class="line" id="L490">    }</span>
<span class="line" id="L491">}</span>
<span class="line" id="L492"></span>
<span class="line" id="L493"><span class="tok-kw">test</span> <span class="tok-str">&quot;big.rational extractLowBits&quot;</span> {</span>
<span class="line" id="L494">    <span class="tok-kw">var</span> a = <span class="tok-kw">try</span> Int.initSet(testing.allocator, <span class="tok-number">0x11112222333344441234567887654321</span>);</span>
<span class="line" id="L495">    <span class="tok-kw">defer</span> a.deinit();</span>
<span class="line" id="L496"></span>
<span class="line" id="L497">    <span class="tok-kw">const</span> a1 = extractLowBits(a, <span class="tok-type">u8</span>);</span>
<span class="line" id="L498">    <span class="tok-kw">try</span> testing.expect(a1 == <span class="tok-number">0x21</span>);</span>
<span class="line" id="L499"></span>
<span class="line" id="L500">    <span class="tok-kw">const</span> a2 = extractLowBits(a, <span class="tok-type">u16</span>);</span>
<span class="line" id="L501">    <span class="tok-kw">try</span> testing.expect(a2 == <span class="tok-number">0x4321</span>);</span>
<span class="line" id="L502"></span>
<span class="line" id="L503">    <span class="tok-kw">const</span> a3 = extractLowBits(a, <span class="tok-type">u32</span>);</span>
<span class="line" id="L504">    <span class="tok-kw">try</span> testing.expect(a3 == <span class="tok-number">0x87654321</span>);</span>
<span class="line" id="L505"></span>
<span class="line" id="L506">    <span class="tok-kw">const</span> a4 = extractLowBits(a, <span class="tok-type">u64</span>);</span>
<span class="line" id="L507">    <span class="tok-kw">try</span> testing.expect(a4 == <span class="tok-number">0x1234567887654321</span>);</span>
<span class="line" id="L508"></span>
<span class="line" id="L509">    <span class="tok-kw">const</span> a5 = extractLowBits(a, <span class="tok-type">u128</span>);</span>
<span class="line" id="L510">    <span class="tok-kw">try</span> testing.expect(a5 == <span class="tok-number">0x11112222333344441234567887654321</span>);</span>
<span class="line" id="L511">}</span>
<span class="line" id="L512"></span>
<span class="line" id="L513"><span class="tok-kw">test</span> <span class="tok-str">&quot;big.rational set&quot;</span> {</span>
<span class="line" id="L514">    <span class="tok-kw">var</span> a = <span class="tok-kw">try</span> Rational.init(testing.allocator);</span>
<span class="line" id="L515">    <span class="tok-kw">defer</span> a.deinit();</span>
<span class="line" id="L516"></span>
<span class="line" id="L517">    <span class="tok-kw">try</span> a.setInt(<span class="tok-number">5</span>);</span>
<span class="line" id="L518">    <span class="tok-kw">try</span> testing.expect((<span class="tok-kw">try</span> a.p.to(<span class="tok-type">u32</span>)) == <span class="tok-number">5</span>);</span>
<span class="line" id="L519">    <span class="tok-kw">try</span> testing.expect((<span class="tok-kw">try</span> a.q.to(<span class="tok-type">u32</span>)) == <span class="tok-number">1</span>);</span>
<span class="line" id="L520"></span>
<span class="line" id="L521">    <span class="tok-kw">try</span> a.setRatio(<span class="tok-number">7</span>, <span class="tok-number">3</span>);</span>
<span class="line" id="L522">    <span class="tok-kw">try</span> testing.expect((<span class="tok-kw">try</span> a.p.to(<span class="tok-type">u32</span>)) == <span class="tok-number">7</span>);</span>
<span class="line" id="L523">    <span class="tok-kw">try</span> testing.expect((<span class="tok-kw">try</span> a.q.to(<span class="tok-type">u32</span>)) == <span class="tok-number">3</span>);</span>
<span class="line" id="L524"></span>
<span class="line" id="L525">    <span class="tok-kw">try</span> a.setRatio(<span class="tok-number">9</span>, <span class="tok-number">3</span>);</span>
<span class="line" id="L526">    <span class="tok-kw">try</span> testing.expect((<span class="tok-kw">try</span> a.p.to(<span class="tok-type">i32</span>)) == <span class="tok-number">3</span>);</span>
<span class="line" id="L527">    <span class="tok-kw">try</span> testing.expect((<span class="tok-kw">try</span> a.q.to(<span class="tok-type">i32</span>)) == <span class="tok-number">1</span>);</span>
<span class="line" id="L528"></span>
<span class="line" id="L529">    <span class="tok-kw">try</span> a.setRatio(-<span class="tok-number">9</span>, <span class="tok-number">3</span>);</span>
<span class="line" id="L530">    <span class="tok-kw">try</span> testing.expect((<span class="tok-kw">try</span> a.p.to(<span class="tok-type">i32</span>)) == -<span class="tok-number">3</span>);</span>
<span class="line" id="L531">    <span class="tok-kw">try</span> testing.expect((<span class="tok-kw">try</span> a.q.to(<span class="tok-type">i32</span>)) == <span class="tok-number">1</span>);</span>
<span class="line" id="L532"></span>
<span class="line" id="L533">    <span class="tok-kw">try</span> a.setRatio(<span class="tok-number">9</span>, -<span class="tok-number">3</span>);</span>
<span class="line" id="L534">    <span class="tok-kw">try</span> testing.expect((<span class="tok-kw">try</span> a.p.to(<span class="tok-type">i32</span>)) == -<span class="tok-number">3</span>);</span>
<span class="line" id="L535">    <span class="tok-kw">try</span> testing.expect((<span class="tok-kw">try</span> a.q.to(<span class="tok-type">i32</span>)) == <span class="tok-number">1</span>);</span>
<span class="line" id="L536"></span>
<span class="line" id="L537">    <span class="tok-kw">try</span> a.setRatio(-<span class="tok-number">9</span>, -<span class="tok-number">3</span>);</span>
<span class="line" id="L538">    <span class="tok-kw">try</span> testing.expect((<span class="tok-kw">try</span> a.p.to(<span class="tok-type">i32</span>)) == <span class="tok-number">3</span>);</span>
<span class="line" id="L539">    <span class="tok-kw">try</span> testing.expect((<span class="tok-kw">try</span> a.q.to(<span class="tok-type">i32</span>)) == <span class="tok-number">1</span>);</span>
<span class="line" id="L540">}</span>
<span class="line" id="L541"></span>
<span class="line" id="L542"><span class="tok-kw">test</span> <span class="tok-str">&quot;big.rational setFloat&quot;</span> {</span>
<span class="line" id="L543">    <span class="tok-kw">var</span> a = <span class="tok-kw">try</span> Rational.init(testing.allocator);</span>
<span class="line" id="L544">    <span class="tok-kw">defer</span> a.deinit();</span>
<span class="line" id="L545"></span>
<span class="line" id="L546">    <span class="tok-kw">try</span> a.setFloat(<span class="tok-type">f64</span>, <span class="tok-number">2.5</span>);</span>
<span class="line" id="L547">    <span class="tok-kw">try</span> testing.expect((<span class="tok-kw">try</span> a.p.to(<span class="tok-type">i32</span>)) == <span class="tok-number">5</span>);</span>
<span class="line" id="L548">    <span class="tok-kw">try</span> testing.expect((<span class="tok-kw">try</span> a.q.to(<span class="tok-type">i32</span>)) == <span class="tok-number">2</span>);</span>
<span class="line" id="L549"></span>
<span class="line" id="L550">    <span class="tok-kw">try</span> a.setFloat(<span class="tok-type">f32</span>, -<span class="tok-number">2.5</span>);</span>
<span class="line" id="L551">    <span class="tok-kw">try</span> testing.expect((<span class="tok-kw">try</span> a.p.to(<span class="tok-type">i32</span>)) == -<span class="tok-number">5</span>);</span>
<span class="line" id="L552">    <span class="tok-kw">try</span> testing.expect((<span class="tok-kw">try</span> a.q.to(<span class="tok-type">i32</span>)) == <span class="tok-number">2</span>);</span>
<span class="line" id="L553"></span>
<span class="line" id="L554">    <span class="tok-kw">try</span> a.setFloat(<span class="tok-type">f32</span>, <span class="tok-number">3.141593</span>);</span>
<span class="line" id="L555"></span>
<span class="line" id="L556">    <span class="tok-comment">//                = 3.14159297943115234375</span>
</span>
<span class="line" id="L557">    <span class="tok-kw">try</span> testing.expect((<span class="tok-kw">try</span> a.p.to(<span class="tok-type">u32</span>)) == <span class="tok-number">3294199</span>);</span>
<span class="line" id="L558">    <span class="tok-kw">try</span> testing.expect((<span class="tok-kw">try</span> a.q.to(<span class="tok-type">u32</span>)) == <span class="tok-number">1048576</span>);</span>
<span class="line" id="L559"></span>
<span class="line" id="L560">    <span class="tok-kw">try</span> a.setFloat(<span class="tok-type">f64</span>, <span class="tok-number">72.141593120712409172417410926841290461290467124</span>);</span>
<span class="line" id="L561"></span>
<span class="line" id="L562">    <span class="tok-comment">//                = 72.1415931207124145885245525278151035308837890625</span>
</span>
<span class="line" id="L563">    <span class="tok-kw">try</span> testing.expect((<span class="tok-kw">try</span> a.p.to(<span class="tok-type">u128</span>)) == <span class="tok-number">5076513310880537</span>);</span>
<span class="line" id="L564">    <span class="tok-kw">try</span> testing.expect((<span class="tok-kw">try</span> a.q.to(<span class="tok-type">u128</span>)) == <span class="tok-number">70368744177664</span>);</span>
<span class="line" id="L565">}</span>
<span class="line" id="L566"></span>
<span class="line" id="L567"><span class="tok-kw">test</span> <span class="tok-str">&quot;big.rational setFloatString&quot;</span> {</span>
<span class="line" id="L568">    <span class="tok-kw">var</span> a = <span class="tok-kw">try</span> Rational.init(testing.allocator);</span>
<span class="line" id="L569">    <span class="tok-kw">defer</span> a.deinit();</span>
<span class="line" id="L570"></span>
<span class="line" id="L571">    <span class="tok-kw">try</span> a.setFloatString(<span class="tok-str">&quot;72.14159312071241458852455252781510353&quot;</span>);</span>
<span class="line" id="L572"></span>
<span class="line" id="L573">    <span class="tok-comment">//                  = 72.1415931207124145885245525278151035308837890625</span>
</span>
<span class="line" id="L574">    <span class="tok-kw">try</span> testing.expect((<span class="tok-kw">try</span> a.p.to(<span class="tok-type">u128</span>)) == <span class="tok-number">7214159312071241458852455252781510353</span>);</span>
<span class="line" id="L575">    <span class="tok-kw">try</span> testing.expect((<span class="tok-kw">try</span> a.q.to(<span class="tok-type">u128</span>)) == <span class="tok-number">100000000000000000000000000000000000</span>);</span>
<span class="line" id="L576">}</span>
<span class="line" id="L577"></span>
<span class="line" id="L578"><span class="tok-kw">test</span> <span class="tok-str">&quot;big.rational toFloat&quot;</span> {</span>
<span class="line" id="L579">    <span class="tok-kw">var</span> a = <span class="tok-kw">try</span> Rational.init(testing.allocator);</span>
<span class="line" id="L580">    <span class="tok-kw">defer</span> a.deinit();</span>
<span class="line" id="L581"></span>
<span class="line" id="L582">    <span class="tok-comment">// = 3.14159297943115234375</span>
</span>
<span class="line" id="L583">    <span class="tok-kw">try</span> a.setRatio(<span class="tok-number">3294199</span>, <span class="tok-number">1048576</span>);</span>
<span class="line" id="L584">    <span class="tok-kw">try</span> testing.expect((<span class="tok-kw">try</span> a.toFloat(<span class="tok-type">f64</span>)) == <span class="tok-number">3.14159297943115234375</span>);</span>
<span class="line" id="L585"></span>
<span class="line" id="L586">    <span class="tok-comment">// = 72.1415931207124145885245525278151035308837890625</span>
</span>
<span class="line" id="L587">    <span class="tok-kw">try</span> a.setRatio(<span class="tok-number">5076513310880537</span>, <span class="tok-number">70368744177664</span>);</span>
<span class="line" id="L588">    <span class="tok-kw">try</span> testing.expect((<span class="tok-kw">try</span> a.toFloat(<span class="tok-type">f64</span>)) == <span class="tok-number">72.141593120712409172417410926841290461290467124</span>);</span>
<span class="line" id="L589">}</span>
<span class="line" id="L590"></span>
<span class="line" id="L591"><span class="tok-kw">test</span> <span class="tok-str">&quot;big.rational set/to Float round-trip&quot;</span> {</span>
<span class="line" id="L592">    <span class="tok-kw">var</span> a = <span class="tok-kw">try</span> Rational.init(testing.allocator);</span>
<span class="line" id="L593">    <span class="tok-kw">defer</span> a.deinit();</span>
<span class="line" id="L594">    <span class="tok-kw">var</span> prng = std.rand.DefaultPrng.init(<span class="tok-number">0x5EED</span>);</span>
<span class="line" id="L595">    <span class="tok-kw">const</span> random = prng.random();</span>
<span class="line" id="L596">    <span class="tok-kw">var</span> i: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L597">    <span class="tok-kw">while</span> (i &lt; <span class="tok-number">512</span>) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L598">        <span class="tok-kw">const</span> r = random.float(<span class="tok-type">f64</span>);</span>
<span class="line" id="L599">        <span class="tok-kw">try</span> a.setFloat(<span class="tok-type">f64</span>, r);</span>
<span class="line" id="L600">        <span class="tok-kw">try</span> testing.expect((<span class="tok-kw">try</span> a.toFloat(<span class="tok-type">f64</span>)) == r);</span>
<span class="line" id="L601">    }</span>
<span class="line" id="L602">}</span>
<span class="line" id="L603"></span>
<span class="line" id="L604"><span class="tok-kw">test</span> <span class="tok-str">&quot;big.rational copy&quot;</span> {</span>
<span class="line" id="L605">    <span class="tok-kw">var</span> a = <span class="tok-kw">try</span> Rational.init(testing.allocator);</span>
<span class="line" id="L606">    <span class="tok-kw">defer</span> a.deinit();</span>
<span class="line" id="L607"></span>
<span class="line" id="L608">    <span class="tok-kw">var</span> b = <span class="tok-kw">try</span> Int.initSet(testing.allocator, <span class="tok-number">5</span>);</span>
<span class="line" id="L609">    <span class="tok-kw">defer</span> b.deinit();</span>
<span class="line" id="L610"></span>
<span class="line" id="L611">    <span class="tok-kw">try</span> a.copyInt(b);</span>
<span class="line" id="L612">    <span class="tok-kw">try</span> testing.expect((<span class="tok-kw">try</span> a.p.to(<span class="tok-type">u32</span>)) == <span class="tok-number">5</span>);</span>
<span class="line" id="L613">    <span class="tok-kw">try</span> testing.expect((<span class="tok-kw">try</span> a.q.to(<span class="tok-type">u32</span>)) == <span class="tok-number">1</span>);</span>
<span class="line" id="L614"></span>
<span class="line" id="L615">    <span class="tok-kw">var</span> c = <span class="tok-kw">try</span> Int.initSet(testing.allocator, <span class="tok-number">7</span>);</span>
<span class="line" id="L616">    <span class="tok-kw">defer</span> c.deinit();</span>
<span class="line" id="L617">    <span class="tok-kw">var</span> d = <span class="tok-kw">try</span> Int.initSet(testing.allocator, <span class="tok-number">3</span>);</span>
<span class="line" id="L618">    <span class="tok-kw">defer</span> d.deinit();</span>
<span class="line" id="L619"></span>
<span class="line" id="L620">    <span class="tok-kw">try</span> a.copyRatio(c, d);</span>
<span class="line" id="L621">    <span class="tok-kw">try</span> testing.expect((<span class="tok-kw">try</span> a.p.to(<span class="tok-type">u32</span>)) == <span class="tok-number">7</span>);</span>
<span class="line" id="L622">    <span class="tok-kw">try</span> testing.expect((<span class="tok-kw">try</span> a.q.to(<span class="tok-type">u32</span>)) == <span class="tok-number">3</span>);</span>
<span class="line" id="L623"></span>
<span class="line" id="L624">    <span class="tok-kw">var</span> e = <span class="tok-kw">try</span> Int.initSet(testing.allocator, <span class="tok-number">9</span>);</span>
<span class="line" id="L625">    <span class="tok-kw">defer</span> e.deinit();</span>
<span class="line" id="L626">    <span class="tok-kw">var</span> f = <span class="tok-kw">try</span> Int.initSet(testing.allocator, <span class="tok-number">3</span>);</span>
<span class="line" id="L627">    <span class="tok-kw">defer</span> f.deinit();</span>
<span class="line" id="L628"></span>
<span class="line" id="L629">    <span class="tok-kw">try</span> a.copyRatio(e, f);</span>
<span class="line" id="L630">    <span class="tok-kw">try</span> testing.expect((<span class="tok-kw">try</span> a.p.to(<span class="tok-type">u32</span>)) == <span class="tok-number">3</span>);</span>
<span class="line" id="L631">    <span class="tok-kw">try</span> testing.expect((<span class="tok-kw">try</span> a.q.to(<span class="tok-type">u32</span>)) == <span class="tok-number">1</span>);</span>
<span class="line" id="L632">}</span>
<span class="line" id="L633"></span>
<span class="line" id="L634"><span class="tok-kw">test</span> <span class="tok-str">&quot;big.rational negate&quot;</span> {</span>
<span class="line" id="L635">    <span class="tok-kw">var</span> a = <span class="tok-kw">try</span> Rational.init(testing.allocator);</span>
<span class="line" id="L636">    <span class="tok-kw">defer</span> a.deinit();</span>
<span class="line" id="L637"></span>
<span class="line" id="L638">    <span class="tok-kw">try</span> a.setInt(-<span class="tok-number">50</span>);</span>
<span class="line" id="L639">    <span class="tok-kw">try</span> testing.expect((<span class="tok-kw">try</span> a.p.to(<span class="tok-type">i32</span>)) == -<span class="tok-number">50</span>);</span>
<span class="line" id="L640">    <span class="tok-kw">try</span> testing.expect((<span class="tok-kw">try</span> a.q.to(<span class="tok-type">i32</span>)) == <span class="tok-number">1</span>);</span>
<span class="line" id="L641"></span>
<span class="line" id="L642">    a.negate();</span>
<span class="line" id="L643">    <span class="tok-kw">try</span> testing.expect((<span class="tok-kw">try</span> a.p.to(<span class="tok-type">i32</span>)) == <span class="tok-number">50</span>);</span>
<span class="line" id="L644">    <span class="tok-kw">try</span> testing.expect((<span class="tok-kw">try</span> a.q.to(<span class="tok-type">i32</span>)) == <span class="tok-number">1</span>);</span>
<span class="line" id="L645"></span>
<span class="line" id="L646">    a.negate();</span>
<span class="line" id="L647">    <span class="tok-kw">try</span> testing.expect((<span class="tok-kw">try</span> a.p.to(<span class="tok-type">i32</span>)) == -<span class="tok-number">50</span>);</span>
<span class="line" id="L648">    <span class="tok-kw">try</span> testing.expect((<span class="tok-kw">try</span> a.q.to(<span class="tok-type">i32</span>)) == <span class="tok-number">1</span>);</span>
<span class="line" id="L649">}</span>
<span class="line" id="L650"></span>
<span class="line" id="L651"><span class="tok-kw">test</span> <span class="tok-str">&quot;big.rational abs&quot;</span> {</span>
<span class="line" id="L652">    <span class="tok-kw">var</span> a = <span class="tok-kw">try</span> Rational.init(testing.allocator);</span>
<span class="line" id="L653">    <span class="tok-kw">defer</span> a.deinit();</span>
<span class="line" id="L654"></span>
<span class="line" id="L655">    <span class="tok-kw">try</span> a.setInt(-<span class="tok-number">50</span>);</span>
<span class="line" id="L656">    <span class="tok-kw">try</span> testing.expect((<span class="tok-kw">try</span> a.p.to(<span class="tok-type">i32</span>)) == -<span class="tok-number">50</span>);</span>
<span class="line" id="L657">    <span class="tok-kw">try</span> testing.expect((<span class="tok-kw">try</span> a.q.to(<span class="tok-type">i32</span>)) == <span class="tok-number">1</span>);</span>
<span class="line" id="L658"></span>
<span class="line" id="L659">    a.abs();</span>
<span class="line" id="L660">    <span class="tok-kw">try</span> testing.expect((<span class="tok-kw">try</span> a.p.to(<span class="tok-type">i32</span>)) == <span class="tok-number">50</span>);</span>
<span class="line" id="L661">    <span class="tok-kw">try</span> testing.expect((<span class="tok-kw">try</span> a.q.to(<span class="tok-type">i32</span>)) == <span class="tok-number">1</span>);</span>
<span class="line" id="L662"></span>
<span class="line" id="L663">    a.abs();</span>
<span class="line" id="L664">    <span class="tok-kw">try</span> testing.expect((<span class="tok-kw">try</span> a.p.to(<span class="tok-type">i32</span>)) == <span class="tok-number">50</span>);</span>
<span class="line" id="L665">    <span class="tok-kw">try</span> testing.expect((<span class="tok-kw">try</span> a.q.to(<span class="tok-type">i32</span>)) == <span class="tok-number">1</span>);</span>
<span class="line" id="L666">}</span>
<span class="line" id="L667"></span>
<span class="line" id="L668"><span class="tok-kw">test</span> <span class="tok-str">&quot;big.rational swap&quot;</span> {</span>
<span class="line" id="L669">    <span class="tok-kw">var</span> a = <span class="tok-kw">try</span> Rational.init(testing.allocator);</span>
<span class="line" id="L670">    <span class="tok-kw">defer</span> a.deinit();</span>
<span class="line" id="L671">    <span class="tok-kw">var</span> b = <span class="tok-kw">try</span> Rational.init(testing.allocator);</span>
<span class="line" id="L672">    <span class="tok-kw">defer</span> b.deinit();</span>
<span class="line" id="L673"></span>
<span class="line" id="L674">    <span class="tok-kw">try</span> a.setRatio(<span class="tok-number">50</span>, <span class="tok-number">23</span>);</span>
<span class="line" id="L675">    <span class="tok-kw">try</span> b.setRatio(<span class="tok-number">17</span>, <span class="tok-number">3</span>);</span>
<span class="line" id="L676"></span>
<span class="line" id="L677">    <span class="tok-kw">try</span> testing.expect((<span class="tok-kw">try</span> a.p.to(<span class="tok-type">u32</span>)) == <span class="tok-number">50</span>);</span>
<span class="line" id="L678">    <span class="tok-kw">try</span> testing.expect((<span class="tok-kw">try</span> a.q.to(<span class="tok-type">u32</span>)) == <span class="tok-number">23</span>);</span>
<span class="line" id="L679"></span>
<span class="line" id="L680">    <span class="tok-kw">try</span> testing.expect((<span class="tok-kw">try</span> b.p.to(<span class="tok-type">u32</span>)) == <span class="tok-number">17</span>);</span>
<span class="line" id="L681">    <span class="tok-kw">try</span> testing.expect((<span class="tok-kw">try</span> b.q.to(<span class="tok-type">u32</span>)) == <span class="tok-number">3</span>);</span>
<span class="line" id="L682"></span>
<span class="line" id="L683">    a.swap(&amp;b);</span>
<span class="line" id="L684"></span>
<span class="line" id="L685">    <span class="tok-kw">try</span> testing.expect((<span class="tok-kw">try</span> a.p.to(<span class="tok-type">u32</span>)) == <span class="tok-number">17</span>);</span>
<span class="line" id="L686">    <span class="tok-kw">try</span> testing.expect((<span class="tok-kw">try</span> a.q.to(<span class="tok-type">u32</span>)) == <span class="tok-number">3</span>);</span>
<span class="line" id="L687"></span>
<span class="line" id="L688">    <span class="tok-kw">try</span> testing.expect((<span class="tok-kw">try</span> b.p.to(<span class="tok-type">u32</span>)) == <span class="tok-number">50</span>);</span>
<span class="line" id="L689">    <span class="tok-kw">try</span> testing.expect((<span class="tok-kw">try</span> b.q.to(<span class="tok-type">u32</span>)) == <span class="tok-number">23</span>);</span>
<span class="line" id="L690">}</span>
<span class="line" id="L691"></span>
<span class="line" id="L692"><span class="tok-kw">test</span> <span class="tok-str">&quot;big.rational order&quot;</span> {</span>
<span class="line" id="L693">    <span class="tok-kw">var</span> a = <span class="tok-kw">try</span> Rational.init(testing.allocator);</span>
<span class="line" id="L694">    <span class="tok-kw">defer</span> a.deinit();</span>
<span class="line" id="L695">    <span class="tok-kw">var</span> b = <span class="tok-kw">try</span> Rational.init(testing.allocator);</span>
<span class="line" id="L696">    <span class="tok-kw">defer</span> b.deinit();</span>
<span class="line" id="L697"></span>
<span class="line" id="L698">    <span class="tok-kw">try</span> a.setRatio(<span class="tok-number">500</span>, <span class="tok-number">231</span>);</span>
<span class="line" id="L699">    <span class="tok-kw">try</span> b.setRatio(<span class="tok-number">18903</span>, <span class="tok-number">8584</span>);</span>
<span class="line" id="L700">    <span class="tok-kw">try</span> testing.expect((<span class="tok-kw">try</span> a.order(b)) == .lt);</span>
<span class="line" id="L701"></span>
<span class="line" id="L702">    <span class="tok-kw">try</span> a.setRatio(<span class="tok-number">890</span>, <span class="tok-number">10</span>);</span>
<span class="line" id="L703">    <span class="tok-kw">try</span> b.setRatio(<span class="tok-number">89</span>, <span class="tok-number">1</span>);</span>
<span class="line" id="L704">    <span class="tok-kw">try</span> testing.expect((<span class="tok-kw">try</span> a.order(b)) == .eq);</span>
<span class="line" id="L705">}</span>
<span class="line" id="L706"></span>
<span class="line" id="L707"><span class="tok-kw">test</span> <span class="tok-str">&quot;big.rational add single-limb&quot;</span> {</span>
<span class="line" id="L708">    <span class="tok-kw">var</span> a = <span class="tok-kw">try</span> Rational.init(testing.allocator);</span>
<span class="line" id="L709">    <span class="tok-kw">defer</span> a.deinit();</span>
<span class="line" id="L710">    <span class="tok-kw">var</span> b = <span class="tok-kw">try</span> Rational.init(testing.allocator);</span>
<span class="line" id="L711">    <span class="tok-kw">defer</span> b.deinit();</span>
<span class="line" id="L712"></span>
<span class="line" id="L713">    <span class="tok-kw">try</span> a.setRatio(<span class="tok-number">500</span>, <span class="tok-number">231</span>);</span>
<span class="line" id="L714">    <span class="tok-kw">try</span> b.setRatio(<span class="tok-number">18903</span>, <span class="tok-number">8584</span>);</span>
<span class="line" id="L715">    <span class="tok-kw">try</span> testing.expect((<span class="tok-kw">try</span> a.order(b)) == .lt);</span>
<span class="line" id="L716"></span>
<span class="line" id="L717">    <span class="tok-kw">try</span> a.setRatio(<span class="tok-number">890</span>, <span class="tok-number">10</span>);</span>
<span class="line" id="L718">    <span class="tok-kw">try</span> b.setRatio(<span class="tok-number">89</span>, <span class="tok-number">1</span>);</span>
<span class="line" id="L719">    <span class="tok-kw">try</span> testing.expect((<span class="tok-kw">try</span> a.order(b)) == .eq);</span>
<span class="line" id="L720">}</span>
<span class="line" id="L721"></span>
<span class="line" id="L722"><span class="tok-kw">test</span> <span class="tok-str">&quot;big.rational add&quot;</span> {</span>
<span class="line" id="L723">    <span class="tok-kw">var</span> a = <span class="tok-kw">try</span> Rational.init(testing.allocator);</span>
<span class="line" id="L724">    <span class="tok-kw">defer</span> a.deinit();</span>
<span class="line" id="L725">    <span class="tok-kw">var</span> b = <span class="tok-kw">try</span> Rational.init(testing.allocator);</span>
<span class="line" id="L726">    <span class="tok-kw">defer</span> b.deinit();</span>
<span class="line" id="L727">    <span class="tok-kw">var</span> r = <span class="tok-kw">try</span> Rational.init(testing.allocator);</span>
<span class="line" id="L728">    <span class="tok-kw">defer</span> r.deinit();</span>
<span class="line" id="L729"></span>
<span class="line" id="L730">    <span class="tok-kw">try</span> a.setRatio(<span class="tok-number">78923</span>, <span class="tok-number">23341</span>);</span>
<span class="line" id="L731">    <span class="tok-kw">try</span> b.setRatio(<span class="tok-number">123097</span>, <span class="tok-number">12441414</span>);</span>
<span class="line" id="L732">    <span class="tok-kw">try</span> a.add(a, b);</span>
<span class="line" id="L733"></span>
<span class="line" id="L734">    <span class="tok-kw">try</span> r.setRatio(<span class="tok-number">984786924199</span>, <span class="tok-number">290395044174</span>);</span>
<span class="line" id="L735">    <span class="tok-kw">try</span> testing.expect((<span class="tok-kw">try</span> a.order(r)) == .eq);</span>
<span class="line" id="L736">}</span>
<span class="line" id="L737"></span>
<span class="line" id="L738"><span class="tok-kw">test</span> <span class="tok-str">&quot;big.rational sub&quot;</span> {</span>
<span class="line" id="L739">    <span class="tok-kw">var</span> a = <span class="tok-kw">try</span> Rational.init(testing.allocator);</span>
<span class="line" id="L740">    <span class="tok-kw">defer</span> a.deinit();</span>
<span class="line" id="L741">    <span class="tok-kw">var</span> b = <span class="tok-kw">try</span> Rational.init(testing.allocator);</span>
<span class="line" id="L742">    <span class="tok-kw">defer</span> b.deinit();</span>
<span class="line" id="L743">    <span class="tok-kw">var</span> r = <span class="tok-kw">try</span> Rational.init(testing.allocator);</span>
<span class="line" id="L744">    <span class="tok-kw">defer</span> r.deinit();</span>
<span class="line" id="L745"></span>
<span class="line" id="L746">    <span class="tok-kw">try</span> a.setRatio(<span class="tok-number">78923</span>, <span class="tok-number">23341</span>);</span>
<span class="line" id="L747">    <span class="tok-kw">try</span> b.setRatio(<span class="tok-number">123097</span>, <span class="tok-number">12441414</span>);</span>
<span class="line" id="L748">    <span class="tok-kw">try</span> a.sub(a, b);</span>
<span class="line" id="L749"></span>
<span class="line" id="L750">    <span class="tok-kw">try</span> r.setRatio(<span class="tok-number">979040510045</span>, <span class="tok-number">290395044174</span>);</span>
<span class="line" id="L751">    <span class="tok-kw">try</span> testing.expect((<span class="tok-kw">try</span> a.order(r)) == .eq);</span>
<span class="line" id="L752">}</span>
<span class="line" id="L753"></span>
<span class="line" id="L754"><span class="tok-kw">test</span> <span class="tok-str">&quot;big.rational mul&quot;</span> {</span>
<span class="line" id="L755">    <span class="tok-kw">var</span> a = <span class="tok-kw">try</span> Rational.init(testing.allocator);</span>
<span class="line" id="L756">    <span class="tok-kw">defer</span> a.deinit();</span>
<span class="line" id="L757">    <span class="tok-kw">var</span> b = <span class="tok-kw">try</span> Rational.init(testing.allocator);</span>
<span class="line" id="L758">    <span class="tok-kw">defer</span> b.deinit();</span>
<span class="line" id="L759">    <span class="tok-kw">var</span> r = <span class="tok-kw">try</span> Rational.init(testing.allocator);</span>
<span class="line" id="L760">    <span class="tok-kw">defer</span> r.deinit();</span>
<span class="line" id="L761"></span>
<span class="line" id="L762">    <span class="tok-kw">try</span> a.setRatio(<span class="tok-number">78923</span>, <span class="tok-number">23341</span>);</span>
<span class="line" id="L763">    <span class="tok-kw">try</span> b.setRatio(<span class="tok-number">123097</span>, <span class="tok-number">12441414</span>);</span>
<span class="line" id="L764">    <span class="tok-kw">try</span> a.mul(a, b);</span>
<span class="line" id="L765"></span>
<span class="line" id="L766">    <span class="tok-kw">try</span> r.setRatio(<span class="tok-number">571481443</span>, <span class="tok-number">17082061422</span>);</span>
<span class="line" id="L767">    <span class="tok-kw">try</span> testing.expect((<span class="tok-kw">try</span> a.order(r)) == .eq);</span>
<span class="line" id="L768">}</span>
<span class="line" id="L769"></span>
<span class="line" id="L770"><span class="tok-kw">test</span> <span class="tok-str">&quot;big.rational div&quot;</span> {</span>
<span class="line" id="L771">    <span class="tok-kw">var</span> a = <span class="tok-kw">try</span> Rational.init(testing.allocator);</span>
<span class="line" id="L772">    <span class="tok-kw">defer</span> a.deinit();</span>
<span class="line" id="L773">    <span class="tok-kw">var</span> b = <span class="tok-kw">try</span> Rational.init(testing.allocator);</span>
<span class="line" id="L774">    <span class="tok-kw">defer</span> b.deinit();</span>
<span class="line" id="L775">    <span class="tok-kw">var</span> r = <span class="tok-kw">try</span> Rational.init(testing.allocator);</span>
<span class="line" id="L776">    <span class="tok-kw">defer</span> r.deinit();</span>
<span class="line" id="L777"></span>
<span class="line" id="L778">    <span class="tok-kw">try</span> a.setRatio(<span class="tok-number">78923</span>, <span class="tok-number">23341</span>);</span>
<span class="line" id="L779">    <span class="tok-kw">try</span> b.setRatio(<span class="tok-number">123097</span>, <span class="tok-number">12441414</span>);</span>
<span class="line" id="L780">    <span class="tok-kw">try</span> a.div(a, b);</span>
<span class="line" id="L781"></span>
<span class="line" id="L782">    <span class="tok-kw">try</span> r.setRatio(<span class="tok-number">75531824394</span>, <span class="tok-number">221015929</span>);</span>
<span class="line" id="L783">    <span class="tok-kw">try</span> testing.expect((<span class="tok-kw">try</span> a.order(r)) == .eq);</span>
<span class="line" id="L784">}</span>
<span class="line" id="L785"></span>
<span class="line" id="L786"><span class="tok-kw">test</span> <span class="tok-str">&quot;big.rational div&quot;</span> {</span>
<span class="line" id="L787">    <span class="tok-kw">var</span> a = <span class="tok-kw">try</span> Rational.init(testing.allocator);</span>
<span class="line" id="L788">    <span class="tok-kw">defer</span> a.deinit();</span>
<span class="line" id="L789">    <span class="tok-kw">var</span> r = <span class="tok-kw">try</span> Rational.init(testing.allocator);</span>
<span class="line" id="L790">    <span class="tok-kw">defer</span> r.deinit();</span>
<span class="line" id="L791"></span>
<span class="line" id="L792">    <span class="tok-kw">try</span> a.setRatio(<span class="tok-number">78923</span>, <span class="tok-number">23341</span>);</span>
<span class="line" id="L793">    a.invert();</span>
<span class="line" id="L794"></span>
<span class="line" id="L795">    <span class="tok-kw">try</span> r.setRatio(<span class="tok-number">23341</span>, <span class="tok-number">78923</span>);</span>
<span class="line" id="L796">    <span class="tok-kw">try</span> testing.expect((<span class="tok-kw">try</span> a.order(r)) == .eq);</span>
<span class="line" id="L797"></span>
<span class="line" id="L798">    <span class="tok-kw">try</span> a.setRatio(-<span class="tok-number">78923</span>, <span class="tok-number">23341</span>);</span>
<span class="line" id="L799">    a.invert();</span>
<span class="line" id="L800"></span>
<span class="line" id="L801">    <span class="tok-kw">try</span> r.setRatio(-<span class="tok-number">23341</span>, <span class="tok-number">78923</span>);</span>
<span class="line" id="L802">    <span class="tok-kw">try</span> testing.expect((<span class="tok-kw">try</span> a.order(r)) == .eq);</span>
<span class="line" id="L803">}</span>
<span class="line" id="L804"></span>
</code></pre></body>
</html>