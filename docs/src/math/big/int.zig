<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">    <title>math/big/int.zig - source view</title>
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
<span class="line" id="L2"><span class="tok-kw">const</span> builtin = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;builtin&quot;</span>);</span>
<span class="line" id="L3"><span class="tok-kw">const</span> math = std.math;</span>
<span class="line" id="L4"><span class="tok-kw">const</span> Limb = std.math.big.Limb;</span>
<span class="line" id="L5"><span class="tok-kw">const</span> limb_bits = <span class="tok-builtin">@typeInfo</span>(Limb).Int.bits;</span>
<span class="line" id="L6"><span class="tok-kw">const</span> HalfLimb = std.math.big.HalfLimb;</span>
<span class="line" id="L7"><span class="tok-kw">const</span> half_limb_bits = <span class="tok-builtin">@typeInfo</span>(HalfLimb).Int.bits;</span>
<span class="line" id="L8"><span class="tok-kw">const</span> DoubleLimb = std.math.big.DoubleLimb;</span>
<span class="line" id="L9"><span class="tok-kw">const</span> SignedDoubleLimb = std.math.big.SignedDoubleLimb;</span>
<span class="line" id="L10"><span class="tok-kw">const</span> Log2Limb = std.math.big.Log2Limb;</span>
<span class="line" id="L11"><span class="tok-kw">const</span> Allocator = std.mem.Allocator;</span>
<span class="line" id="L12"><span class="tok-kw">const</span> mem = std.mem;</span>
<span class="line" id="L13"><span class="tok-kw">const</span> maxInt = std.math.maxInt;</span>
<span class="line" id="L14"><span class="tok-kw">const</span> minInt = std.math.minInt;</span>
<span class="line" id="L15"><span class="tok-kw">const</span> assert = std.debug.assert;</span>
<span class="line" id="L16"><span class="tok-kw">const</span> Endian = std.builtin.Endian;</span>
<span class="line" id="L17"><span class="tok-kw">const</span> Signedness = std.builtin.Signedness;</span>
<span class="line" id="L18"><span class="tok-kw">const</span> native_endian = builtin.cpu.arch.endian();</span>
<span class="line" id="L19"></span>
<span class="line" id="L20"><span class="tok-kw">const</span> debug_safety = <span class="tok-null">false</span>;</span>
<span class="line" id="L21"></span>
<span class="line" id="L22"><span class="tok-comment">/// Returns the number of limbs needed to store `scalar`, which must be a</span></span>
<span class="line" id="L23"><span class="tok-comment">/// primitive integer value.</span></span>
<span class="line" id="L24"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">calcLimbLen</span>(scalar: <span class="tok-kw">anytype</span>) <span class="tok-type">usize</span> {</span>
<span class="line" id="L25">    <span class="tok-kw">if</span> (scalar == <span class="tok-number">0</span>) {</span>
<span class="line" id="L26">        <span class="tok-kw">return</span> <span class="tok-number">1</span>;</span>
<span class="line" id="L27">    }</span>
<span class="line" id="L28"></span>
<span class="line" id="L29">    <span class="tok-kw">const</span> w_value = std.math.absCast(scalar);</span>
<span class="line" id="L30">    <span class="tok-kw">return</span> <span class="tok-builtin">@divFloor</span>(<span class="tok-builtin">@intCast</span>(Limb, math.log2(w_value)), limb_bits) + <span class="tok-number">1</span>;</span>
<span class="line" id="L31">}</span>
<span class="line" id="L32"></span>
<span class="line" id="L33"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">calcToStringLimbsBufferLen</span>(a_len: <span class="tok-type">usize</span>, base: <span class="tok-type">u8</span>) <span class="tok-type">usize</span> {</span>
<span class="line" id="L34">    <span class="tok-kw">if</span> (math.isPowerOfTwo(base))</span>
<span class="line" id="L35">        <span class="tok-kw">return</span> <span class="tok-number">0</span>;</span>
<span class="line" id="L36">    <span class="tok-kw">return</span> a_len + <span class="tok-number">2</span> + a_len + calcDivLimbsBufferLen(a_len, <span class="tok-number">1</span>);</span>
<span class="line" id="L37">}</span>
<span class="line" id="L38"></span>
<span class="line" id="L39"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">calcDivLimbsBufferLen</span>(a_len: <span class="tok-type">usize</span>, b_len: <span class="tok-type">usize</span>) <span class="tok-type">usize</span> {</span>
<span class="line" id="L40">    <span class="tok-kw">return</span> a_len + b_len + <span class="tok-number">4</span>;</span>
<span class="line" id="L41">}</span>
<span class="line" id="L42"></span>
<span class="line" id="L43"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">calcMulLimbsBufferLen</span>(a_len: <span class="tok-type">usize</span>, b_len: <span class="tok-type">usize</span>, aliases: <span class="tok-type">usize</span>) <span class="tok-type">usize</span> {</span>
<span class="line" id="L44">    <span class="tok-kw">return</span> aliases * math.max(a_len, b_len);</span>
<span class="line" id="L45">}</span>
<span class="line" id="L46"></span>
<span class="line" id="L47"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">calcMulWrapLimbsBufferLen</span>(bit_count: <span class="tok-type">usize</span>, a_len: <span class="tok-type">usize</span>, b_len: <span class="tok-type">usize</span>, aliases: <span class="tok-type">usize</span>) <span class="tok-type">usize</span> {</span>
<span class="line" id="L48">    <span class="tok-kw">const</span> req_limbs = calcTwosCompLimbCount(bit_count);</span>
<span class="line" id="L49">    <span class="tok-kw">return</span> aliases * math.min(req_limbs, math.max(a_len, b_len));</span>
<span class="line" id="L50">}</span>
<span class="line" id="L51"></span>
<span class="line" id="L52"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">calcSetStringLimbsBufferLen</span>(base: <span class="tok-type">u8</span>, string_len: <span class="tok-type">usize</span>) <span class="tok-type">usize</span> {</span>
<span class="line" id="L53">    <span class="tok-kw">const</span> limb_count = calcSetStringLimbCount(base, string_len);</span>
<span class="line" id="L54">    <span class="tok-kw">return</span> calcMulLimbsBufferLen(limb_count, limb_count, <span class="tok-number">2</span>);</span>
<span class="line" id="L55">}</span>
<span class="line" id="L56"></span>
<span class="line" id="L57"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">calcSetStringLimbCount</span>(base: <span class="tok-type">u8</span>, string_len: <span class="tok-type">usize</span>) <span class="tok-type">usize</span> {</span>
<span class="line" id="L58">    <span class="tok-kw">return</span> (string_len + (limb_bits / base - <span class="tok-number">1</span>)) / (limb_bits / base);</span>
<span class="line" id="L59">}</span>
<span class="line" id="L60"></span>
<span class="line" id="L61"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">calcPowLimbsBufferLen</span>(a_bit_count: <span class="tok-type">usize</span>, y: <span class="tok-type">usize</span>) <span class="tok-type">usize</span> {</span>
<span class="line" id="L62">    <span class="tok-comment">// The 2 accounts for the minimum space requirement for llmulacc</span>
</span>
<span class="line" id="L63">    <span class="tok-kw">return</span> <span class="tok-number">2</span> + (a_bit_count * y + (limb_bits - <span class="tok-number">1</span>)) / limb_bits;</span>
<span class="line" id="L64">}</span>
<span class="line" id="L65"></span>
<span class="line" id="L66"><span class="tok-comment">// Compute the number of limbs required to store a 2s-complement number of `bit_count` bits.</span>
</span>
<span class="line" id="L67"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">calcTwosCompLimbCount</span>(bit_count: <span class="tok-type">usize</span>) <span class="tok-type">usize</span> {</span>
<span class="line" id="L68">    <span class="tok-kw">return</span> std.math.divCeil(<span class="tok-type">usize</span>, bit_count, <span class="tok-builtin">@bitSizeOf</span>(Limb)) <span class="tok-kw">catch</span> <span class="tok-kw">unreachable</span>;</span>
<span class="line" id="L69">}</span>
<span class="line" id="L70"></span>
<span class="line" id="L71"><span class="tok-comment">/// a + b * c + *carry, sets carry to the overflow bits</span></span>
<span class="line" id="L72"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">addMulLimbWithCarry</span>(a: Limb, b: Limb, c: Limb, carry: *Limb) Limb {</span>
<span class="line" id="L73">    <span class="tok-builtin">@setRuntimeSafety</span>(debug_safety);</span>
<span class="line" id="L74">    <span class="tok-kw">var</span> r1: Limb = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L75"></span>
<span class="line" id="L76">    <span class="tok-comment">// r1 = a + *carry</span>
</span>
<span class="line" id="L77">    <span class="tok-kw">const</span> c1: Limb = <span class="tok-builtin">@boolToInt</span>(<span class="tok-builtin">@addWithOverflow</span>(Limb, a, carry.*, &amp;r1));</span>
<span class="line" id="L78"></span>
<span class="line" id="L79">    <span class="tok-comment">// r2 = b * c</span>
</span>
<span class="line" id="L80">    <span class="tok-kw">const</span> bc = <span class="tok-builtin">@as</span>(DoubleLimb, math.mulWide(Limb, b, c));</span>
<span class="line" id="L81">    <span class="tok-kw">const</span> r2 = <span class="tok-builtin">@truncate</span>(Limb, bc);</span>
<span class="line" id="L82">    <span class="tok-kw">const</span> c2 = <span class="tok-builtin">@truncate</span>(Limb, bc &gt;&gt; limb_bits);</span>
<span class="line" id="L83"></span>
<span class="line" id="L84">    <span class="tok-comment">// r1 = r1 + r2</span>
</span>
<span class="line" id="L85">    <span class="tok-kw">const</span> c3: Limb = <span class="tok-builtin">@boolToInt</span>(<span class="tok-builtin">@addWithOverflow</span>(Limb, r1, r2, &amp;r1));</span>
<span class="line" id="L86"></span>
<span class="line" id="L87">    <span class="tok-comment">// This never overflows, c1, c3 are either 0 or 1 and if both are 1 then</span>
</span>
<span class="line" id="L88">    <span class="tok-comment">// c2 is at least &lt;= maxInt(Limb) - 2.</span>
</span>
<span class="line" id="L89">    carry.* = c1 + c2 + c3;</span>
<span class="line" id="L90"></span>
<span class="line" id="L91">    <span class="tok-kw">return</span> r1;</span>
<span class="line" id="L92">}</span>
<span class="line" id="L93"></span>
<span class="line" id="L94"><span class="tok-comment">/// a - b * c - *carry, sets carry to the overflow bits</span></span>
<span class="line" id="L95"><span class="tok-kw">fn</span> <span class="tok-fn">subMulLimbWithBorrow</span>(a: Limb, b: Limb, c: Limb, carry: *Limb) Limb {</span>
<span class="line" id="L96">    <span class="tok-comment">// r1 = a - *carry</span>
</span>
<span class="line" id="L97">    <span class="tok-kw">var</span> r1: Limb = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L98">    <span class="tok-kw">const</span> c1: Limb = <span class="tok-builtin">@boolToInt</span>(<span class="tok-builtin">@subWithOverflow</span>(Limb, a, carry.*, &amp;r1));</span>
<span class="line" id="L99"></span>
<span class="line" id="L100">    <span class="tok-comment">// r2 = b * c</span>
</span>
<span class="line" id="L101">    <span class="tok-kw">const</span> bc = <span class="tok-builtin">@as</span>(DoubleLimb, std.math.mulWide(Limb, b, c));</span>
<span class="line" id="L102">    <span class="tok-kw">const</span> r2 = <span class="tok-builtin">@truncate</span>(Limb, bc);</span>
<span class="line" id="L103">    <span class="tok-kw">const</span> c2 = <span class="tok-builtin">@truncate</span>(Limb, bc &gt;&gt; limb_bits);</span>
<span class="line" id="L104"></span>
<span class="line" id="L105">    <span class="tok-comment">// r1 = r1 - r2</span>
</span>
<span class="line" id="L106">    <span class="tok-kw">const</span> c3: Limb = <span class="tok-builtin">@boolToInt</span>(<span class="tok-builtin">@subWithOverflow</span>(Limb, r1, r2, &amp;r1));</span>
<span class="line" id="L107">    carry.* = c1 + c2 + c3;</span>
<span class="line" id="L108"></span>
<span class="line" id="L109">    <span class="tok-kw">return</span> r1;</span>
<span class="line" id="L110">}</span>
<span class="line" id="L111"></span>
<span class="line" id="L112"><span class="tok-comment">/// Used to indicate either limit of a 2s-complement integer.</span></span>
<span class="line" id="L113"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> TwosCompIntLimit = <span class="tok-kw">enum</span> {</span>
<span class="line" id="L114">    <span class="tok-comment">// The low limit, either 0x00 (unsigned) or (-)0x80 (signed) for an 8-bit integer.</span>
</span>
<span class="line" id="L115">    min,</span>
<span class="line" id="L116"></span>
<span class="line" id="L117">    <span class="tok-comment">// The high limit, either 0xFF (unsigned) or 0x7F (signed) for an 8-bit integer.</span>
</span>
<span class="line" id="L118">    max,</span>
<span class="line" id="L119">};</span>
<span class="line" id="L120"></span>
<span class="line" id="L121"><span class="tok-comment">/// A arbitrary-precision big integer, with a fixed set of mutable limbs.</span></span>
<span class="line" id="L122"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> Mutable = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L123">    <span class="tok-comment">/// Raw digits. These are:</span></span>
<span class="line" id="L124">    <span class="tok-comment">///</span></span>
<span class="line" id="L125">    <span class="tok-comment">/// * Little-endian ordered</span></span>
<span class="line" id="L126">    <span class="tok-comment">/// * limbs.len &gt;= 1</span></span>
<span class="line" id="L127">    <span class="tok-comment">/// * Zero is represented as limbs.len == 1 with limbs[0] == 0.</span></span>
<span class="line" id="L128">    <span class="tok-comment">///</span></span>
<span class="line" id="L129">    <span class="tok-comment">/// Accessing limbs directly should be avoided.</span></span>
<span class="line" id="L130">    <span class="tok-comment">/// These are allocated limbs; the `len` field tells the valid range.</span></span>
<span class="line" id="L131">    limbs: []Limb,</span>
<span class="line" id="L132">    len: <span class="tok-type">usize</span>,</span>
<span class="line" id="L133">    positive: <span class="tok-type">bool</span>,</span>
<span class="line" id="L134"></span>
<span class="line" id="L135">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">toConst</span>(self: Mutable) Const {</span>
<span class="line" id="L136">        <span class="tok-kw">return</span> .{</span>
<span class="line" id="L137">            .limbs = self.limbs[<span class="tok-number">0</span>..self.len],</span>
<span class="line" id="L138">            .positive = self.positive,</span>
<span class="line" id="L139">        };</span>
<span class="line" id="L140">    }</span>
<span class="line" id="L141"></span>
<span class="line" id="L142">    <span class="tok-comment">/// Returns true if `a == 0`.</span></span>
<span class="line" id="L143">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">eqZero</span>(self: Mutable) <span class="tok-type">bool</span> {</span>
<span class="line" id="L144">        <span class="tok-kw">return</span> self.toConst().eqZero();</span>
<span class="line" id="L145">    }</span>
<span class="line" id="L146"></span>
<span class="line" id="L147">    <span class="tok-comment">/// Asserts that the allocator owns the limbs memory. If this is not the case,</span></span>
<span class="line" id="L148">    <span class="tok-comment">/// use `toConst().toManaged()`.</span></span>
<span class="line" id="L149">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">toManaged</span>(self: Mutable, allocator: Allocator) Managed {</span>
<span class="line" id="L150">        <span class="tok-kw">return</span> .{</span>
<span class="line" id="L151">            .allocator = allocator,</span>
<span class="line" id="L152">            .limbs = self.limbs,</span>
<span class="line" id="L153">            .metadata = <span class="tok-kw">if</span> (self.positive)</span>
<span class="line" id="L154">                self.len &amp; ~Managed.sign_bit</span>
<span class="line" id="L155">            <span class="tok-kw">else</span></span>
<span class="line" id="L156">                self.len | Managed.sign_bit,</span>
<span class="line" id="L157">        };</span>
<span class="line" id="L158">    }</span>
<span class="line" id="L159"></span>
<span class="line" id="L160">    <span class="tok-comment">/// `value` is a primitive integer type.</span></span>
<span class="line" id="L161">    <span class="tok-comment">/// Asserts the value fits within the provided `limbs_buffer`.</span></span>
<span class="line" id="L162">    <span class="tok-comment">/// Note: `calcLimbLen` can be used to figure out how big an array to allocate for `limbs_buffer`.</span></span>
<span class="line" id="L163">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">init</span>(limbs_buffer: []Limb, value: <span class="tok-kw">anytype</span>) Mutable {</span>
<span class="line" id="L164">        limbs_buffer[<span class="tok-number">0</span>] = <span class="tok-number">0</span>;</span>
<span class="line" id="L165">        <span class="tok-kw">var</span> self: Mutable = .{</span>
<span class="line" id="L166">            .limbs = limbs_buffer,</span>
<span class="line" id="L167">            .len = <span class="tok-number">1</span>,</span>
<span class="line" id="L168">            .positive = <span class="tok-null">true</span>,</span>
<span class="line" id="L169">        };</span>
<span class="line" id="L170">        self.set(value);</span>
<span class="line" id="L171">        <span class="tok-kw">return</span> self;</span>
<span class="line" id="L172">    }</span>
<span class="line" id="L173"></span>
<span class="line" id="L174">    <span class="tok-comment">/// Copies the value of a Const to an existing Mutable so that they both have the same value.</span></span>
<span class="line" id="L175">    <span class="tok-comment">/// Asserts the value fits in the limbs buffer.</span></span>
<span class="line" id="L176">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">copy</span>(self: *Mutable, other: Const) <span class="tok-type">void</span> {</span>
<span class="line" id="L177">        <span class="tok-kw">if</span> (self.limbs.ptr != other.limbs.ptr) {</span>
<span class="line" id="L178">            mem.copy(Limb, self.limbs[<span class="tok-number">0</span>..], other.limbs[<span class="tok-number">0</span>..other.limbs.len]);</span>
<span class="line" id="L179">        }</span>
<span class="line" id="L180">        self.positive = other.positive;</span>
<span class="line" id="L181">        self.len = other.limbs.len;</span>
<span class="line" id="L182">    }</span>
<span class="line" id="L183"></span>
<span class="line" id="L184">    <span class="tok-comment">/// Efficiently swap an Mutable with another. This swaps the limb pointers and a full copy is not</span></span>
<span class="line" id="L185">    <span class="tok-comment">/// performed. The address of the limbs field will not be the same after this function.</span></span>
<span class="line" id="L186">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">swap</span>(self: *Mutable, other: *Mutable) <span class="tok-type">void</span> {</span>
<span class="line" id="L187">        mem.swap(Mutable, self, other);</span>
<span class="line" id="L188">    }</span>
<span class="line" id="L189"></span>
<span class="line" id="L190">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">dump</span>(self: Mutable) <span class="tok-type">void</span> {</span>
<span class="line" id="L191">        <span class="tok-kw">for</span> (self.limbs[<span class="tok-number">0</span>..self.len]) |limb| {</span>
<span class="line" id="L192">            std.debug.print(<span class="tok-str">&quot;{x} &quot;</span>, .{limb});</span>
<span class="line" id="L193">        }</span>
<span class="line" id="L194">        std.debug.print(<span class="tok-str">&quot;capacity={} positive={}\n&quot;</span>, .{ self.limbs.len, self.positive });</span>
<span class="line" id="L195">    }</span>
<span class="line" id="L196"></span>
<span class="line" id="L197">    <span class="tok-comment">/// Clones an Mutable and returns a new Mutable with the same value. The new Mutable is a deep copy and</span></span>
<span class="line" id="L198">    <span class="tok-comment">/// can be modified separately from the original.</span></span>
<span class="line" id="L199">    <span class="tok-comment">/// Asserts that limbs is big enough to store the value.</span></span>
<span class="line" id="L200">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">clone</span>(other: Mutable, limbs: []Limb) Mutable {</span>
<span class="line" id="L201">        mem.copy(Limb, limbs, other.limbs[<span class="tok-number">0</span>..other.len]);</span>
<span class="line" id="L202">        <span class="tok-kw">return</span> .{</span>
<span class="line" id="L203">            .limbs = limbs,</span>
<span class="line" id="L204">            .len = other.len,</span>
<span class="line" id="L205">            .positive = other.positive,</span>
<span class="line" id="L206">        };</span>
<span class="line" id="L207">    }</span>
<span class="line" id="L208"></span>
<span class="line" id="L209">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">negate</span>(self: *Mutable) <span class="tok-type">void</span> {</span>
<span class="line" id="L210">        self.positive = !self.positive;</span>
<span class="line" id="L211">    }</span>
<span class="line" id="L212"></span>
<span class="line" id="L213">    <span class="tok-comment">/// Modify to become the absolute value</span></span>
<span class="line" id="L214">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">abs</span>(self: *Mutable) <span class="tok-type">void</span> {</span>
<span class="line" id="L215">        self.positive = <span class="tok-null">true</span>;</span>
<span class="line" id="L216">    }</span>
<span class="line" id="L217"></span>
<span class="line" id="L218">    <span class="tok-comment">/// Sets the Mutable to value. Value must be an primitive integer type.</span></span>
<span class="line" id="L219">    <span class="tok-comment">/// Asserts the value fits within the limbs buffer.</span></span>
<span class="line" id="L220">    <span class="tok-comment">/// Note: `calcLimbLen` can be used to figure out how big the limbs buffer</span></span>
<span class="line" id="L221">    <span class="tok-comment">/// needs to be to store a specific value.</span></span>
<span class="line" id="L222">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">set</span>(self: *Mutable, value: <span class="tok-kw">anytype</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L223">        <span class="tok-kw">const</span> T = <span class="tok-builtin">@TypeOf</span>(value);</span>
<span class="line" id="L224">        <span class="tok-kw">const</span> needed_limbs = calcLimbLen(value);</span>
<span class="line" id="L225">        assert(needed_limbs &lt;= self.limbs.len); <span class="tok-comment">// value too big</span>
</span>
<span class="line" id="L226"></span>
<span class="line" id="L227">        self.len = needed_limbs;</span>
<span class="line" id="L228">        self.positive = value &gt;= <span class="tok-number">0</span>;</span>
<span class="line" id="L229"></span>
<span class="line" id="L230">        <span class="tok-kw">switch</span> (<span class="tok-builtin">@typeInfo</span>(T)) {</span>
<span class="line" id="L231">            .Int =&gt; |info| {</span>
<span class="line" id="L232">                <span class="tok-kw">var</span> w_value = std.math.absCast(value);</span>
<span class="line" id="L233"></span>
<span class="line" id="L234">                <span class="tok-kw">if</span> (info.bits &lt;= limb_bits) {</span>
<span class="line" id="L235">                    self.limbs[<span class="tok-number">0</span>] = w_value;</span>
<span class="line" id="L236">                } <span class="tok-kw">else</span> {</span>
<span class="line" id="L237">                    <span class="tok-kw">var</span> i: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L238">                    <span class="tok-kw">while</span> (w_value != <span class="tok-number">0</span>) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L239">                        self.limbs[i] = <span class="tok-builtin">@truncate</span>(Limb, w_value);</span>
<span class="line" id="L240"></span>
<span class="line" id="L241">                        <span class="tok-comment">// TODO: shift == 64 at compile-time fails. Fails on u128 limbs.</span>
</span>
<span class="line" id="L242">                        w_value &gt;&gt;= limb_bits / <span class="tok-number">2</span>;</span>
<span class="line" id="L243">                        w_value &gt;&gt;= limb_bits / <span class="tok-number">2</span>;</span>
<span class="line" id="L244">                    }</span>
<span class="line" id="L245">                }</span>
<span class="line" id="L246">            },</span>
<span class="line" id="L247">            .ComptimeInt =&gt; {</span>
<span class="line" id="L248">                <span class="tok-kw">comptime</span> <span class="tok-kw">var</span> w_value = std.math.absCast(value);</span>
<span class="line" id="L249"></span>
<span class="line" id="L250">                <span class="tok-kw">if</span> (w_value &lt;= maxInt(Limb)) {</span>
<span class="line" id="L251">                    self.limbs[<span class="tok-number">0</span>] = w_value;</span>
<span class="line" id="L252">                } <span class="tok-kw">else</span> {</span>
<span class="line" id="L253">                    <span class="tok-kw">const</span> mask = (<span class="tok-number">1</span> &lt;&lt; limb_bits) - <span class="tok-number">1</span>;</span>
<span class="line" id="L254"></span>
<span class="line" id="L255">                    <span class="tok-kw">comptime</span> <span class="tok-kw">var</span> i = <span class="tok-number">0</span>;</span>
<span class="line" id="L256">                    <span class="tok-kw">inline</span> <span class="tok-kw">while</span> (w_value != <span class="tok-number">0</span>) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L257">                        self.limbs[i] = w_value &amp; mask;</span>
<span class="line" id="L258"></span>
<span class="line" id="L259">                        w_value &gt;&gt;= limb_bits / <span class="tok-number">2</span>;</span>
<span class="line" id="L260">                        w_value &gt;&gt;= limb_bits / <span class="tok-number">2</span>;</span>
<span class="line" id="L261">                    }</span>
<span class="line" id="L262">                }</span>
<span class="line" id="L263">            },</span>
<span class="line" id="L264">            <span class="tok-kw">else</span> =&gt; <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;cannot set Mutable using type &quot;</span> ++ <span class="tok-builtin">@typeName</span>(T)),</span>
<span class="line" id="L265">        }</span>
<span class="line" id="L266">    }</span>
<span class="line" id="L267"></span>
<span class="line" id="L268">    <span class="tok-comment">/// Set self from the string representation `value`.</span></span>
<span class="line" id="L269">    <span class="tok-comment">///</span></span>
<span class="line" id="L270">    <span class="tok-comment">/// `value` must contain only digits &lt;= `base` and is case insensitive.  Base prefixes are</span></span>
<span class="line" id="L271">    <span class="tok-comment">/// not allowed (e.g. 0x43 should simply be 43).  Underscores in the input string are</span></span>
<span class="line" id="L272">    <span class="tok-comment">/// ignored and can be used as digit separators.</span></span>
<span class="line" id="L273">    <span class="tok-comment">///</span></span>
<span class="line" id="L274">    <span class="tok-comment">/// Asserts there is enough memory for the value in `self.limbs`. An upper bound on number of limbs can</span></span>
<span class="line" id="L275">    <span class="tok-comment">/// be determined with `calcSetStringLimbCount`.</span></span>
<span class="line" id="L276">    <span class="tok-comment">/// Asserts the base is in the range [2, 16].</span></span>
<span class="line" id="L277">    <span class="tok-comment">///</span></span>
<span class="line" id="L278">    <span class="tok-comment">/// Returns an error if the value has invalid digits for the requested base.</span></span>
<span class="line" id="L279">    <span class="tok-comment">///</span></span>
<span class="line" id="L280">    <span class="tok-comment">/// `limbs_buffer` is used for temporary storage. The size required can be found with</span></span>
<span class="line" id="L281">    <span class="tok-comment">/// `calcSetStringLimbsBufferLen`.</span></span>
<span class="line" id="L282">    <span class="tok-comment">///</span></span>
<span class="line" id="L283">    <span class="tok-comment">/// If `allocator` is provided, it will be used for temporary storage to improve</span></span>
<span class="line" id="L284">    <span class="tok-comment">/// multiplication performance. `error.OutOfMemory` is handled with a fallback algorithm.</span></span>
<span class="line" id="L285">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">setString</span>(</span>
<span class="line" id="L286">        self: *Mutable,</span>
<span class="line" id="L287">        base: <span class="tok-type">u8</span>,</span>
<span class="line" id="L288">        value: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L289">        limbs_buffer: []Limb,</span>
<span class="line" id="L290">        allocator: ?Allocator,</span>
<span class="line" id="L291">    ) <span class="tok-kw">error</span>{InvalidCharacter}!<span class="tok-type">void</span> {</span>
<span class="line" id="L292">        assert(base &gt;= <span class="tok-number">2</span> <span class="tok-kw">and</span> base &lt;= <span class="tok-number">16</span>);</span>
<span class="line" id="L293"></span>
<span class="line" id="L294">        <span class="tok-kw">var</span> i: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L295">        <span class="tok-kw">var</span> positive = <span class="tok-null">true</span>;</span>
<span class="line" id="L296">        <span class="tok-kw">if</span> (value.len &gt; <span class="tok-number">0</span> <span class="tok-kw">and</span> value[<span class="tok-number">0</span>] == <span class="tok-str">'-'</span>) {</span>
<span class="line" id="L297">            positive = <span class="tok-null">false</span>;</span>
<span class="line" id="L298">            i += <span class="tok-number">1</span>;</span>
<span class="line" id="L299">        }</span>
<span class="line" id="L300"></span>
<span class="line" id="L301">        <span class="tok-kw">const</span> ap_base: Const = .{ .limbs = &amp;[_]Limb{base}, .positive = <span class="tok-null">true</span> };</span>
<span class="line" id="L302">        self.set(<span class="tok-number">0</span>);</span>
<span class="line" id="L303"></span>
<span class="line" id="L304">        <span class="tok-kw">for</span> (value[i..]) |ch| {</span>
<span class="line" id="L305">            <span class="tok-kw">if</span> (ch == <span class="tok-str">'_'</span>) {</span>
<span class="line" id="L306">                <span class="tok-kw">continue</span>;</span>
<span class="line" id="L307">            }</span>
<span class="line" id="L308">            <span class="tok-kw">const</span> d = <span class="tok-kw">try</span> std.fmt.charToDigit(ch, base);</span>
<span class="line" id="L309">            <span class="tok-kw">const</span> ap_d: Const = .{ .limbs = &amp;[_]Limb{d}, .positive = <span class="tok-null">true</span> };</span>
<span class="line" id="L310"></span>
<span class="line" id="L311">            self.mul(self.toConst(), ap_base, limbs_buffer, allocator);</span>
<span class="line" id="L312">            self.add(self.toConst(), ap_d);</span>
<span class="line" id="L313">        }</span>
<span class="line" id="L314">        self.positive = positive;</span>
<span class="line" id="L315">    }</span>
<span class="line" id="L316"></span>
<span class="line" id="L317">    <span class="tok-comment">/// Set self to either bound of a 2s-complement integer.</span></span>
<span class="line" id="L318">    <span class="tok-comment">/// Note: The result is still sign-magnitude, not twos complement! In order to convert the</span></span>
<span class="line" id="L319">    <span class="tok-comment">/// result to twos complement, it is sufficient to take the absolute value.</span></span>
<span class="line" id="L320">    <span class="tok-comment">///</span></span>
<span class="line" id="L321">    <span class="tok-comment">/// Asserts the result fits in `r`. An upper bound on the number of limbs needed by</span></span>
<span class="line" id="L322">    <span class="tok-comment">/// r is `calcTwosCompLimbCount(bit_count)`.</span></span>
<span class="line" id="L323">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">setTwosCompIntLimit</span>(</span>
<span class="line" id="L324">        r: *Mutable,</span>
<span class="line" id="L325">        limit: TwosCompIntLimit,</span>
<span class="line" id="L326">        signedness: Signedness,</span>
<span class="line" id="L327">        bit_count: <span class="tok-type">usize</span>,</span>
<span class="line" id="L328">    ) <span class="tok-type">void</span> {</span>
<span class="line" id="L329">        <span class="tok-comment">// Handle zero-bit types.</span>
</span>
<span class="line" id="L330">        <span class="tok-kw">if</span> (bit_count == <span class="tok-number">0</span>) {</span>
<span class="line" id="L331">            r.set(<span class="tok-number">0</span>);</span>
<span class="line" id="L332">            <span class="tok-kw">return</span>;</span>
<span class="line" id="L333">        }</span>
<span class="line" id="L334"></span>
<span class="line" id="L335">        <span class="tok-kw">const</span> req_limbs = calcTwosCompLimbCount(bit_count);</span>
<span class="line" id="L336">        <span class="tok-kw">const</span> bit = <span class="tok-builtin">@truncate</span>(Log2Limb, bit_count - <span class="tok-number">1</span>);</span>
<span class="line" id="L337">        <span class="tok-kw">const</span> signmask = <span class="tok-builtin">@as</span>(Limb, <span class="tok-number">1</span>) &lt;&lt; bit; <span class="tok-comment">// 0b0..010..0 where 1 is the sign bit.</span>
</span>
<span class="line" id="L338">        <span class="tok-kw">const</span> mask = (signmask &lt;&lt; <span class="tok-number">1</span>) -% <span class="tok-number">1</span>; <span class="tok-comment">// 0b0..011..1 where the leftmost 1 is the sign bit.</span>
</span>
<span class="line" id="L339"></span>
<span class="line" id="L340">        r.positive = <span class="tok-null">true</span>;</span>
<span class="line" id="L341"></span>
<span class="line" id="L342">        <span class="tok-kw">switch</span> (signedness) {</span>
<span class="line" id="L343">            .signed =&gt; <span class="tok-kw">switch</span> (limit) {</span>
<span class="line" id="L344">                .min =&gt; {</span>
<span class="line" id="L345">                    <span class="tok-comment">// Negative bound, signed = -0x80.</span>
</span>
<span class="line" id="L346">                    r.len = req_limbs;</span>
<span class="line" id="L347">                    mem.set(Limb, r.limbs[<span class="tok-number">0</span> .. r.len - <span class="tok-number">1</span>], <span class="tok-number">0</span>);</span>
<span class="line" id="L348">                    r.limbs[r.len - <span class="tok-number">1</span>] = signmask;</span>
<span class="line" id="L349">                    r.positive = <span class="tok-null">false</span>;</span>
<span class="line" id="L350">                },</span>
<span class="line" id="L351">                .max =&gt; {</span>
<span class="line" id="L352">                    <span class="tok-comment">// Positive bound, signed = 0x7F</span>
</span>
<span class="line" id="L353">                    <span class="tok-comment">// Note, in this branch we need to normalize because the first bit is</span>
</span>
<span class="line" id="L354">                    <span class="tok-comment">// supposed to be 0.</span>
</span>
<span class="line" id="L355"></span>
<span class="line" id="L356">                    <span class="tok-comment">// Special case for 1-bit integers.</span>
</span>
<span class="line" id="L357">                    <span class="tok-kw">if</span> (bit_count == <span class="tok-number">1</span>) {</span>
<span class="line" id="L358">                        r.set(<span class="tok-number">0</span>);</span>
<span class="line" id="L359">                    } <span class="tok-kw">else</span> {</span>
<span class="line" id="L360">                        <span class="tok-kw">const</span> new_req_limbs = calcTwosCompLimbCount(bit_count - <span class="tok-number">1</span>);</span>
<span class="line" id="L361">                        <span class="tok-kw">const</span> msb = <span class="tok-builtin">@truncate</span>(Log2Limb, bit_count - <span class="tok-number">2</span>);</span>
<span class="line" id="L362">                        <span class="tok-kw">const</span> new_signmask = <span class="tok-builtin">@as</span>(Limb, <span class="tok-number">1</span>) &lt;&lt; msb; <span class="tok-comment">// 0b0..010..0 where 1 is the sign bit.</span>
</span>
<span class="line" id="L363">                        <span class="tok-kw">const</span> new_mask = (new_signmask &lt;&lt; <span class="tok-number">1</span>) -% <span class="tok-number">1</span>; <span class="tok-comment">// 0b0..001..1 where the rightmost 0 is the sign bit.</span>
</span>
<span class="line" id="L364"></span>
<span class="line" id="L365">                        r.len = new_req_limbs;</span>
<span class="line" id="L366">                        std.mem.set(Limb, r.limbs[<span class="tok-number">0</span> .. r.len - <span class="tok-number">1</span>], maxInt(Limb));</span>
<span class="line" id="L367">                        r.limbs[r.len - <span class="tok-number">1</span>] = new_mask;</span>
<span class="line" id="L368">                    }</span>
<span class="line" id="L369">                },</span>
<span class="line" id="L370">            },</span>
<span class="line" id="L371">            .unsigned =&gt; <span class="tok-kw">switch</span> (limit) {</span>
<span class="line" id="L372">                .min =&gt; {</span>
<span class="line" id="L373">                    <span class="tok-comment">// Min bound, unsigned = 0x00</span>
</span>
<span class="line" id="L374">                    r.set(<span class="tok-number">0</span>);</span>
<span class="line" id="L375">                },</span>
<span class="line" id="L376">                .max =&gt; {</span>
<span class="line" id="L377">                    <span class="tok-comment">// Max bound, unsigned = 0xFF</span>
</span>
<span class="line" id="L378">                    r.len = req_limbs;</span>
<span class="line" id="L379">                    std.mem.set(Limb, r.limbs[<span class="tok-number">0</span> .. r.len - <span class="tok-number">1</span>], maxInt(Limb));</span>
<span class="line" id="L380">                    r.limbs[r.len - <span class="tok-number">1</span>] = mask;</span>
<span class="line" id="L381">                },</span>
<span class="line" id="L382">            },</span>
<span class="line" id="L383">        }</span>
<span class="line" id="L384">    }</span>
<span class="line" id="L385"></span>
<span class="line" id="L386">    <span class="tok-comment">/// r = a + scalar</span></span>
<span class="line" id="L387">    <span class="tok-comment">///</span></span>
<span class="line" id="L388">    <span class="tok-comment">/// r and a may be aliases.</span></span>
<span class="line" id="L389">    <span class="tok-comment">/// scalar is a primitive integer type.</span></span>
<span class="line" id="L390">    <span class="tok-comment">///</span></span>
<span class="line" id="L391">    <span class="tok-comment">/// Asserts the result fits in `r`. An upper bound on the number of limbs needed by</span></span>
<span class="line" id="L392">    <span class="tok-comment">/// r is `math.max(a.limbs.len, calcLimbLen(scalar)) + 1`.</span></span>
<span class="line" id="L393">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">addScalar</span>(r: *Mutable, a: Const, scalar: <span class="tok-kw">anytype</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L394">        <span class="tok-kw">var</span> limbs: [calcLimbLen(scalar)]Limb = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L395">        <span class="tok-kw">const</span> operand = init(&amp;limbs, scalar).toConst();</span>
<span class="line" id="L396">        <span class="tok-kw">return</span> add(r, a, operand);</span>
<span class="line" id="L397">    }</span>
<span class="line" id="L398"></span>
<span class="line" id="L399">    <span class="tok-comment">/// Base implementation for addition. Adds `max(a.limbs.len, b.limbs.len)` elements from a and b,</span></span>
<span class="line" id="L400">    <span class="tok-comment">/// and returns whether any overflow occured.</span></span>
<span class="line" id="L401">    <span class="tok-comment">/// r, a and b may be aliases.</span></span>
<span class="line" id="L402">    <span class="tok-comment">///</span></span>
<span class="line" id="L403">    <span class="tok-comment">/// Asserts r has enough elements to hold the result. The upper bound is `max(a.limbs.len, b.limbs.len)`.</span></span>
<span class="line" id="L404">    <span class="tok-kw">fn</span> <span class="tok-fn">addCarry</span>(r: *Mutable, a: Const, b: Const) <span class="tok-type">bool</span> {</span>
<span class="line" id="L405">        <span class="tok-kw">if</span> (a.eqZero()) {</span>
<span class="line" id="L406">            r.copy(b);</span>
<span class="line" id="L407">            <span class="tok-kw">return</span> <span class="tok-null">false</span>;</span>
<span class="line" id="L408">        } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (b.eqZero()) {</span>
<span class="line" id="L409">            r.copy(a);</span>
<span class="line" id="L410">            <span class="tok-kw">return</span> <span class="tok-null">false</span>;</span>
<span class="line" id="L411">        } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (a.positive != b.positive) {</span>
<span class="line" id="L412">            <span class="tok-kw">if</span> (a.positive) {</span>
<span class="line" id="L413">                <span class="tok-comment">// (a) + (-b) =&gt; a - b</span>
</span>
<span class="line" id="L414">                <span class="tok-kw">return</span> r.subCarry(a, b.abs());</span>
<span class="line" id="L415">            } <span class="tok-kw">else</span> {</span>
<span class="line" id="L416">                <span class="tok-comment">// (-a) + (b) =&gt; b - a</span>
</span>
<span class="line" id="L417">                <span class="tok-kw">return</span> r.subCarry(b, a.abs());</span>
<span class="line" id="L418">            }</span>
<span class="line" id="L419">        } <span class="tok-kw">else</span> {</span>
<span class="line" id="L420">            r.positive = a.positive;</span>
<span class="line" id="L421">            <span class="tok-kw">if</span> (a.limbs.len &gt;= b.limbs.len) {</span>
<span class="line" id="L422">                <span class="tok-kw">const</span> c = lladdcarry(r.limbs, a.limbs, b.limbs);</span>
<span class="line" id="L423">                r.normalize(a.limbs.len);</span>
<span class="line" id="L424">                <span class="tok-kw">return</span> c != <span class="tok-number">0</span>;</span>
<span class="line" id="L425">            } <span class="tok-kw">else</span> {</span>
<span class="line" id="L426">                <span class="tok-kw">const</span> c = lladdcarry(r.limbs, b.limbs, a.limbs);</span>
<span class="line" id="L427">                r.normalize(b.limbs.len);</span>
<span class="line" id="L428">                <span class="tok-kw">return</span> c != <span class="tok-number">0</span>;</span>
<span class="line" id="L429">            }</span>
<span class="line" id="L430">        }</span>
<span class="line" id="L431">    }</span>
<span class="line" id="L432"></span>
<span class="line" id="L433">    <span class="tok-comment">/// r = a + b</span></span>
<span class="line" id="L434">    <span class="tok-comment">/// r, a and b may be aliases.</span></span>
<span class="line" id="L435">    <span class="tok-comment">///</span></span>
<span class="line" id="L436">    <span class="tok-comment">/// Asserts the result fits in `r`. An upper bound on the number of limbs needed by</span></span>
<span class="line" id="L437">    <span class="tok-comment">/// r is `math.max(a.limbs.len, b.limbs.len) + 1`.</span></span>
<span class="line" id="L438">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">add</span>(r: *Mutable, a: Const, b: Const) <span class="tok-type">void</span> {</span>
<span class="line" id="L439">        <span class="tok-kw">if</span> (r.addCarry(a, b)) {</span>
<span class="line" id="L440">            <span class="tok-comment">// Fix up the result. Note that addCarry normalizes by a.limbs.len or b.limbs.len,</span>
</span>
<span class="line" id="L441">            <span class="tok-comment">// so we need to set the length here.</span>
</span>
<span class="line" id="L442">            <span class="tok-kw">const</span> msl = math.max(a.limbs.len, b.limbs.len);</span>
<span class="line" id="L443">            <span class="tok-comment">// `[add|sub]Carry` normalizes by `msl`, so we need to fix up the result manually here.</span>
</span>
<span class="line" id="L444">            <span class="tok-comment">// Note, the fact that it normalized means that the intermediary limbs are zero here.</span>
</span>
<span class="line" id="L445">            r.len = msl + <span class="tok-number">1</span>;</span>
<span class="line" id="L446">            r.limbs[msl] = <span class="tok-number">1</span>; <span class="tok-comment">// If this panics, there wasn't enough space in `r`.</span>
</span>
<span class="line" id="L447">        }</span>
<span class="line" id="L448">    }</span>
<span class="line" id="L449"></span>
<span class="line" id="L450">    <span class="tok-comment">/// r = a + b with 2s-complement wrapping semantics. Returns whether overflow occurred.</span></span>
<span class="line" id="L451">    <span class="tok-comment">/// r, a and b may be aliases</span></span>
<span class="line" id="L452">    <span class="tok-comment">///</span></span>
<span class="line" id="L453">    <span class="tok-comment">/// Asserts the result fits in `r`. An upper bound on the number of limbs needed by</span></span>
<span class="line" id="L454">    <span class="tok-comment">/// r is `calcTwosCompLimbCount(bit_count)`.</span></span>
<span class="line" id="L455">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">addWrap</span>(r: *Mutable, a: Const, b: Const, signedness: Signedness, bit_count: <span class="tok-type">usize</span>) <span class="tok-type">bool</span> {</span>
<span class="line" id="L456">        <span class="tok-kw">const</span> req_limbs = calcTwosCompLimbCount(bit_count);</span>
<span class="line" id="L457"></span>
<span class="line" id="L458">        <span class="tok-comment">// Slice of the upper bits if they exist, these will be ignored and allows us to use addCarry to determine</span>
</span>
<span class="line" id="L459">        <span class="tok-comment">// if an overflow occured.</span>
</span>
<span class="line" id="L460">        <span class="tok-kw">const</span> x = Const{</span>
<span class="line" id="L461">            .positive = a.positive,</span>
<span class="line" id="L462">            .limbs = a.limbs[<span class="tok-number">0</span>..math.min(req_limbs, a.limbs.len)],</span>
<span class="line" id="L463">        };</span>
<span class="line" id="L464"></span>
<span class="line" id="L465">        <span class="tok-kw">const</span> y = Const{</span>
<span class="line" id="L466">            .positive = b.positive,</span>
<span class="line" id="L467">            .limbs = b.limbs[<span class="tok-number">0</span>..math.min(req_limbs, b.limbs.len)],</span>
<span class="line" id="L468">        };</span>
<span class="line" id="L469"></span>
<span class="line" id="L470">        <span class="tok-kw">var</span> carry_truncated = <span class="tok-null">false</span>;</span>
<span class="line" id="L471">        <span class="tok-kw">if</span> (r.addCarry(x, y)) {</span>
<span class="line" id="L472">            <span class="tok-comment">// There are two possibilities here:</span>
</span>
<span class="line" id="L473">            <span class="tok-comment">// - We overflowed req_limbs. In this case, the carry is ignored, as it would be removed by</span>
</span>
<span class="line" id="L474">            <span class="tok-comment">//   truncate anyway.</span>
</span>
<span class="line" id="L475">            <span class="tok-comment">// - a and b had less elements than req_limbs, and those were overflowed. This case needs to be handled.</span>
</span>
<span class="line" id="L476">            <span class="tok-comment">//   Note: after this we still might need to wrap.</span>
</span>
<span class="line" id="L477">            <span class="tok-kw">const</span> msl = math.max(a.limbs.len, b.limbs.len);</span>
<span class="line" id="L478">            <span class="tok-kw">if</span> (msl &lt; req_limbs) {</span>
<span class="line" id="L479">                r.limbs[msl] = <span class="tok-number">1</span>;</span>
<span class="line" id="L480">                r.len = req_limbs;</span>
<span class="line" id="L481">            } <span class="tok-kw">else</span> {</span>
<span class="line" id="L482">                carry_truncated = <span class="tok-null">true</span>;</span>
<span class="line" id="L483">            }</span>
<span class="line" id="L484">        }</span>
<span class="line" id="L485"></span>
<span class="line" id="L486">        <span class="tok-kw">if</span> (!r.toConst().fitsInTwosComp(signedness, bit_count)) {</span>
<span class="line" id="L487">            r.truncate(r.toConst(), signedness, bit_count);</span>
<span class="line" id="L488">            <span class="tok-kw">return</span> <span class="tok-null">true</span>;</span>
<span class="line" id="L489">        }</span>
<span class="line" id="L490"></span>
<span class="line" id="L491">        <span class="tok-kw">return</span> carry_truncated;</span>
<span class="line" id="L492">    }</span>
<span class="line" id="L493"></span>
<span class="line" id="L494">    <span class="tok-comment">/// r = a + b with 2s-complement saturating semantics.</span></span>
<span class="line" id="L495">    <span class="tok-comment">/// r, a and b may be aliases.</span></span>
<span class="line" id="L496">    <span class="tok-comment">///</span></span>
<span class="line" id="L497">    <span class="tok-comment">/// Assets the result fits in `r`. Upper bound on the number of limbs needed by</span></span>
<span class="line" id="L498">    <span class="tok-comment">/// r is `calcTwosCompLimbCount(bit_count)`.</span></span>
<span class="line" id="L499">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">addSat</span>(r: *Mutable, a: Const, b: Const, signedness: Signedness, bit_count: <span class="tok-type">usize</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L500">        <span class="tok-kw">const</span> req_limbs = calcTwosCompLimbCount(bit_count);</span>
<span class="line" id="L501"></span>
<span class="line" id="L502">        <span class="tok-comment">// Slice of the upper bits if they exist, these will be ignored and allows us to use addCarry to determine</span>
</span>
<span class="line" id="L503">        <span class="tok-comment">// if an overflow occured.</span>
</span>
<span class="line" id="L504">        <span class="tok-kw">const</span> x = Const{</span>
<span class="line" id="L505">            .positive = a.positive,</span>
<span class="line" id="L506">            .limbs = a.limbs[<span class="tok-number">0</span>..math.min(req_limbs, a.limbs.len)],</span>
<span class="line" id="L507">        };</span>
<span class="line" id="L508"></span>
<span class="line" id="L509">        <span class="tok-kw">const</span> y = Const{</span>
<span class="line" id="L510">            .positive = b.positive,</span>
<span class="line" id="L511">            .limbs = b.limbs[<span class="tok-number">0</span>..math.min(req_limbs, b.limbs.len)],</span>
<span class="line" id="L512">        };</span>
<span class="line" id="L513"></span>
<span class="line" id="L514">        <span class="tok-kw">if</span> (r.addCarry(x, y)) {</span>
<span class="line" id="L515">            <span class="tok-comment">// There are two possibilities here:</span>
</span>
<span class="line" id="L516">            <span class="tok-comment">// - We overflowed req_limbs, in which case we need to saturate.</span>
</span>
<span class="line" id="L517">            <span class="tok-comment">// - a and b had less elements than req_limbs, and those were overflowed.</span>
</span>
<span class="line" id="L518">            <span class="tok-comment">//   Note: In this case, might _also_ need to saturate.</span>
</span>
<span class="line" id="L519">            <span class="tok-kw">const</span> msl = math.max(a.limbs.len, b.limbs.len);</span>
<span class="line" id="L520">            <span class="tok-kw">if</span> (msl &lt; req_limbs) {</span>
<span class="line" id="L521">                r.limbs[msl] = <span class="tok-number">1</span>;</span>
<span class="line" id="L522">                r.len = req_limbs;</span>
<span class="line" id="L523">                <span class="tok-comment">// Note: Saturation may still be required if msl == req_limbs - 1</span>
</span>
<span class="line" id="L524">            } <span class="tok-kw">else</span> {</span>
<span class="line" id="L525">                <span class="tok-comment">// Overflowed req_limbs, definitely saturate.</span>
</span>
<span class="line" id="L526">                r.setTwosCompIntLimit(<span class="tok-kw">if</span> (r.positive) .max <span class="tok-kw">else</span> .min, signedness, bit_count);</span>
<span class="line" id="L527">            }</span>
<span class="line" id="L528">        }</span>
<span class="line" id="L529"></span>
<span class="line" id="L530">        <span class="tok-comment">// Saturate if the result didn't fit.</span>
</span>
<span class="line" id="L531">        r.saturate(r.toConst(), signedness, bit_count);</span>
<span class="line" id="L532">    }</span>
<span class="line" id="L533"></span>
<span class="line" id="L534">    <span class="tok-comment">/// Base implementation for subtraction. Subtracts `max(a.limbs.len, b.limbs.len)` elements from a and b,</span></span>
<span class="line" id="L535">    <span class="tok-comment">/// and returns whether any overflow occured.</span></span>
<span class="line" id="L536">    <span class="tok-comment">/// r, a and b may be aliases.</span></span>
<span class="line" id="L537">    <span class="tok-comment">///</span></span>
<span class="line" id="L538">    <span class="tok-comment">/// Asserts r has enough elements to hold the result. The upper bound is `max(a.limbs.len, b.limbs.len)`.</span></span>
<span class="line" id="L539">    <span class="tok-kw">fn</span> <span class="tok-fn">subCarry</span>(r: *Mutable, a: Const, b: Const) <span class="tok-type">bool</span> {</span>
<span class="line" id="L540">        <span class="tok-kw">if</span> (a.eqZero()) {</span>
<span class="line" id="L541">            r.copy(b);</span>
<span class="line" id="L542">            r.positive = !b.positive;</span>
<span class="line" id="L543">            <span class="tok-kw">return</span> <span class="tok-null">false</span>;</span>
<span class="line" id="L544">        } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (b.eqZero()) {</span>
<span class="line" id="L545">            r.copy(a);</span>
<span class="line" id="L546">            <span class="tok-kw">return</span> <span class="tok-null">false</span>;</span>
<span class="line" id="L547">        } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (a.positive != b.positive) {</span>
<span class="line" id="L548">            <span class="tok-kw">if</span> (a.positive) {</span>
<span class="line" id="L549">                <span class="tok-comment">// (a) - (-b) =&gt; a + b</span>
</span>
<span class="line" id="L550">                <span class="tok-kw">return</span> r.addCarry(a, b.abs());</span>
<span class="line" id="L551">            } <span class="tok-kw">else</span> {</span>
<span class="line" id="L552">                <span class="tok-comment">// (-a) - (b) =&gt; -a + -b</span>
</span>
<span class="line" id="L553">                <span class="tok-kw">return</span> r.addCarry(a, b.negate());</span>
<span class="line" id="L554">            }</span>
<span class="line" id="L555">        } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (a.positive) {</span>
<span class="line" id="L556">            <span class="tok-kw">if</span> (a.order(b) != .lt) {</span>
<span class="line" id="L557">                <span class="tok-comment">// (a) - (b) =&gt; a - b</span>
</span>
<span class="line" id="L558">                <span class="tok-kw">const</span> c = llsubcarry(r.limbs, a.limbs, b.limbs);</span>
<span class="line" id="L559">                r.normalize(a.limbs.len);</span>
<span class="line" id="L560">                r.positive = <span class="tok-null">true</span>;</span>
<span class="line" id="L561">                <span class="tok-kw">return</span> c != <span class="tok-number">0</span>;</span>
<span class="line" id="L562">            } <span class="tok-kw">else</span> {</span>
<span class="line" id="L563">                <span class="tok-comment">// (a) - (b) =&gt; -b + a =&gt; -(b - a)</span>
</span>
<span class="line" id="L564">                <span class="tok-kw">const</span> c = llsubcarry(r.limbs, b.limbs, a.limbs);</span>
<span class="line" id="L565">                r.normalize(b.limbs.len);</span>
<span class="line" id="L566">                r.positive = <span class="tok-null">false</span>;</span>
<span class="line" id="L567">                <span class="tok-kw">return</span> c != <span class="tok-number">0</span>;</span>
<span class="line" id="L568">            }</span>
<span class="line" id="L569">        } <span class="tok-kw">else</span> {</span>
<span class="line" id="L570">            <span class="tok-kw">if</span> (a.order(b) == .lt) {</span>
<span class="line" id="L571">                <span class="tok-comment">// (-a) - (-b) =&gt; -(a - b)</span>
</span>
<span class="line" id="L572">                <span class="tok-kw">const</span> c = llsubcarry(r.limbs, a.limbs, b.limbs);</span>
<span class="line" id="L573">                r.normalize(a.limbs.len);</span>
<span class="line" id="L574">                r.positive = <span class="tok-null">false</span>;</span>
<span class="line" id="L575">                <span class="tok-kw">return</span> c != <span class="tok-number">0</span>;</span>
<span class="line" id="L576">            } <span class="tok-kw">else</span> {</span>
<span class="line" id="L577">                <span class="tok-comment">// (-a) - (-b) =&gt; --b + -a =&gt; b - a</span>
</span>
<span class="line" id="L578">                <span class="tok-kw">const</span> c = llsubcarry(r.limbs, b.limbs, a.limbs);</span>
<span class="line" id="L579">                r.normalize(b.limbs.len);</span>
<span class="line" id="L580">                r.positive = <span class="tok-null">true</span>;</span>
<span class="line" id="L581">                <span class="tok-kw">return</span> c != <span class="tok-number">0</span>;</span>
<span class="line" id="L582">            }</span>
<span class="line" id="L583">        }</span>
<span class="line" id="L584">    }</span>
<span class="line" id="L585"></span>
<span class="line" id="L586">    <span class="tok-comment">/// r = a - b</span></span>
<span class="line" id="L587">    <span class="tok-comment">///</span></span>
<span class="line" id="L588">    <span class="tok-comment">/// r, a and b may be aliases.</span></span>
<span class="line" id="L589">    <span class="tok-comment">///</span></span>
<span class="line" id="L590">    <span class="tok-comment">/// Asserts the result fits in `r`. An upper bound on the number of limbs needed by</span></span>
<span class="line" id="L591">    <span class="tok-comment">/// r is `math.max(a.limbs.len, b.limbs.len) + 1`. The +1 is not needed if both operands are positive.</span></span>
<span class="line" id="L592">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">sub</span>(r: *Mutable, a: Const, b: Const) <span class="tok-type">void</span> {</span>
<span class="line" id="L593">        r.add(a, b.negate());</span>
<span class="line" id="L594">    }</span>
<span class="line" id="L595"></span>
<span class="line" id="L596">    <span class="tok-comment">/// r = a - b with 2s-complement wrapping semantics. Returns whether any overflow occured.</span></span>
<span class="line" id="L597">    <span class="tok-comment">///</span></span>
<span class="line" id="L598">    <span class="tok-comment">/// r, a and b may be aliases</span></span>
<span class="line" id="L599">    <span class="tok-comment">/// Asserts the result fits in `r`. An upper bound on the number of limbs needed by</span></span>
<span class="line" id="L600">    <span class="tok-comment">/// r is `calcTwosCompLimbCount(bit_count)`.</span></span>
<span class="line" id="L601">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">subWrap</span>(r: *Mutable, a: Const, b: Const, signedness: Signedness, bit_count: <span class="tok-type">usize</span>) <span class="tok-type">bool</span> {</span>
<span class="line" id="L602">        <span class="tok-kw">return</span> r.addWrap(a, b.negate(), signedness, bit_count);</span>
<span class="line" id="L603">    }</span>
<span class="line" id="L604"></span>
<span class="line" id="L605">    <span class="tok-comment">/// r = a - b with 2s-complement saturating semantics.</span></span>
<span class="line" id="L606">    <span class="tok-comment">/// r, a and b may be aliases.</span></span>
<span class="line" id="L607">    <span class="tok-comment">///</span></span>
<span class="line" id="L608">    <span class="tok-comment">/// Assets the result fits in `r`. Upper bound on the number of limbs needed by</span></span>
<span class="line" id="L609">    <span class="tok-comment">/// r is `calcTwosCompLimbCount(bit_count)`.</span></span>
<span class="line" id="L610">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">subSat</span>(r: *Mutable, a: Const, b: Const, signedness: Signedness, bit_count: <span class="tok-type">usize</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L611">        r.addSat(a, b.negate(), signedness, bit_count);</span>
<span class="line" id="L612">    }</span>
<span class="line" id="L613"></span>
<span class="line" id="L614">    <span class="tok-comment">/// rma = a * b</span></span>
<span class="line" id="L615">    <span class="tok-comment">///</span></span>
<span class="line" id="L616">    <span class="tok-comment">/// `rma` may alias with `a` or `b`.</span></span>
<span class="line" id="L617">    <span class="tok-comment">/// `a` and `b` may alias with each other.</span></span>
<span class="line" id="L618">    <span class="tok-comment">///</span></span>
<span class="line" id="L619">    <span class="tok-comment">/// Asserts the result fits in `rma`. An upper bound on the number of limbs needed by</span></span>
<span class="line" id="L620">    <span class="tok-comment">/// rma is given by `a.limbs.len + b.limbs.len`.</span></span>
<span class="line" id="L621">    <span class="tok-comment">///</span></span>
<span class="line" id="L622">    <span class="tok-comment">/// `limbs_buffer` is used for temporary storage. The amount required is given by `calcMulLimbsBufferLen`.</span></span>
<span class="line" id="L623">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">mul</span>(rma: *Mutable, a: Const, b: Const, limbs_buffer: []Limb, allocator: ?Allocator) <span class="tok-type">void</span> {</span>
<span class="line" id="L624">        <span class="tok-kw">var</span> buf_index: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L625"></span>
<span class="line" id="L626">        <span class="tok-kw">const</span> a_copy = <span class="tok-kw">if</span> (rma.limbs.ptr == a.limbs.ptr) blk: {</span>
<span class="line" id="L627">            <span class="tok-kw">const</span> start = buf_index;</span>
<span class="line" id="L628">            mem.copy(Limb, limbs_buffer[buf_index..], a.limbs);</span>
<span class="line" id="L629">            buf_index += a.limbs.len;</span>
<span class="line" id="L630">            <span class="tok-kw">break</span> :blk a.toMutable(limbs_buffer[start..buf_index]).toConst();</span>
<span class="line" id="L631">        } <span class="tok-kw">else</span> a;</span>
<span class="line" id="L632"></span>
<span class="line" id="L633">        <span class="tok-kw">const</span> b_copy = <span class="tok-kw">if</span> (rma.limbs.ptr == b.limbs.ptr) blk: {</span>
<span class="line" id="L634">            <span class="tok-kw">const</span> start = buf_index;</span>
<span class="line" id="L635">            mem.copy(Limb, limbs_buffer[buf_index..], b.limbs);</span>
<span class="line" id="L636">            buf_index += b.limbs.len;</span>
<span class="line" id="L637">            <span class="tok-kw">break</span> :blk b.toMutable(limbs_buffer[start..buf_index]).toConst();</span>
<span class="line" id="L638">        } <span class="tok-kw">else</span> b;</span>
<span class="line" id="L639"></span>
<span class="line" id="L640">        <span class="tok-kw">return</span> rma.mulNoAlias(a_copy, b_copy, allocator);</span>
<span class="line" id="L641">    }</span>
<span class="line" id="L642"></span>
<span class="line" id="L643">    <span class="tok-comment">/// rma = a * b</span></span>
<span class="line" id="L644">    <span class="tok-comment">///</span></span>
<span class="line" id="L645">    <span class="tok-comment">/// `rma` may not alias with `a` or `b`.</span></span>
<span class="line" id="L646">    <span class="tok-comment">/// `a` and `b` may alias with each other.</span></span>
<span class="line" id="L647">    <span class="tok-comment">///</span></span>
<span class="line" id="L648">    <span class="tok-comment">/// Asserts the result fits in `rma`. An upper bound on the number of limbs needed by</span></span>
<span class="line" id="L649">    <span class="tok-comment">/// rma is given by `a.limbs.len + b.limbs.len`.</span></span>
<span class="line" id="L650">    <span class="tok-comment">///</span></span>
<span class="line" id="L651">    <span class="tok-comment">/// If `allocator` is provided, it will be used for temporary storage to improve</span></span>
<span class="line" id="L652">    <span class="tok-comment">/// multiplication performance. `error.OutOfMemory` is handled with a fallback algorithm.</span></span>
<span class="line" id="L653">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">mulNoAlias</span>(rma: *Mutable, a: Const, b: Const, allocator: ?Allocator) <span class="tok-type">void</span> {</span>
<span class="line" id="L654">        assert(rma.limbs.ptr != a.limbs.ptr); <span class="tok-comment">// illegal aliasing</span>
</span>
<span class="line" id="L655">        assert(rma.limbs.ptr != b.limbs.ptr); <span class="tok-comment">// illegal aliasing</span>
</span>
<span class="line" id="L656"></span>
<span class="line" id="L657">        <span class="tok-kw">if</span> (a.limbs.len == <span class="tok-number">1</span> <span class="tok-kw">and</span> b.limbs.len == <span class="tok-number">1</span>) {</span>
<span class="line" id="L658">            <span class="tok-kw">if</span> (!<span class="tok-builtin">@mulWithOverflow</span>(Limb, a.limbs[<span class="tok-number">0</span>], b.limbs[<span class="tok-number">0</span>], &amp;rma.limbs[<span class="tok-number">0</span>])) {</span>
<span class="line" id="L659">                rma.len = <span class="tok-number">1</span>;</span>
<span class="line" id="L660">                rma.positive = (a.positive == b.positive);</span>
<span class="line" id="L661">                <span class="tok-kw">return</span>;</span>
<span class="line" id="L662">            }</span>
<span class="line" id="L663">        }</span>
<span class="line" id="L664"></span>
<span class="line" id="L665">        mem.set(Limb, rma.limbs[<span class="tok-number">0</span> .. a.limbs.len + b.limbs.len], <span class="tok-number">0</span>);</span>
<span class="line" id="L666"></span>
<span class="line" id="L667">        llmulacc(.add, allocator, rma.limbs, a.limbs, b.limbs);</span>
<span class="line" id="L668"></span>
<span class="line" id="L669">        rma.normalize(a.limbs.len + b.limbs.len);</span>
<span class="line" id="L670">        rma.positive = (a.positive == b.positive);</span>
<span class="line" id="L671">    }</span>
<span class="line" id="L672"></span>
<span class="line" id="L673">    <span class="tok-comment">/// rma = a * b with 2s-complement wrapping semantics.</span></span>
<span class="line" id="L674">    <span class="tok-comment">///</span></span>
<span class="line" id="L675">    <span class="tok-comment">/// `rma` may alias with `a` or `b`.</span></span>
<span class="line" id="L676">    <span class="tok-comment">/// `a` and `b` may alias with each other.</span></span>
<span class="line" id="L677">    <span class="tok-comment">///</span></span>
<span class="line" id="L678">    <span class="tok-comment">/// Asserts the result fits in `rma`. An upper bound on the number of limbs needed by</span></span>
<span class="line" id="L679">    <span class="tok-comment">/// rma is given by `a.limbs.len + b.limbs.len`.</span></span>
<span class="line" id="L680">    <span class="tok-comment">///</span></span>
<span class="line" id="L681">    <span class="tok-comment">/// `limbs_buffer` is used for temporary storage. The amount required is given by `calcMulWrapLimbsBufferLen`.</span></span>
<span class="line" id="L682">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">mulWrap</span>(</span>
<span class="line" id="L683">        rma: *Mutable,</span>
<span class="line" id="L684">        a: Const,</span>
<span class="line" id="L685">        b: Const,</span>
<span class="line" id="L686">        signedness: Signedness,</span>
<span class="line" id="L687">        bit_count: <span class="tok-type">usize</span>,</span>
<span class="line" id="L688">        limbs_buffer: []Limb,</span>
<span class="line" id="L689">        allocator: ?Allocator,</span>
<span class="line" id="L690">    ) <span class="tok-type">void</span> {</span>
<span class="line" id="L691">        <span class="tok-kw">var</span> buf_index: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L692">        <span class="tok-kw">const</span> req_limbs = calcTwosCompLimbCount(bit_count);</span>
<span class="line" id="L693"></span>
<span class="line" id="L694">        <span class="tok-kw">const</span> a_copy = <span class="tok-kw">if</span> (rma.limbs.ptr == a.limbs.ptr) blk: {</span>
<span class="line" id="L695">            <span class="tok-kw">const</span> start = buf_index;</span>
<span class="line" id="L696">            <span class="tok-kw">const</span> a_len = math.min(req_limbs, a.limbs.len);</span>
<span class="line" id="L697">            mem.copy(Limb, limbs_buffer[buf_index..], a.limbs[<span class="tok-number">0</span>..a_len]);</span>
<span class="line" id="L698">            buf_index += a_len;</span>
<span class="line" id="L699">            <span class="tok-kw">break</span> :blk a.toMutable(limbs_buffer[start..buf_index]).toConst();</span>
<span class="line" id="L700">        } <span class="tok-kw">else</span> a;</span>
<span class="line" id="L701"></span>
<span class="line" id="L702">        <span class="tok-kw">const</span> b_copy = <span class="tok-kw">if</span> (rma.limbs.ptr == b.limbs.ptr) blk: {</span>
<span class="line" id="L703">            <span class="tok-kw">const</span> start = buf_index;</span>
<span class="line" id="L704">            <span class="tok-kw">const</span> b_len = math.min(req_limbs, b.limbs.len);</span>
<span class="line" id="L705">            mem.copy(Limb, limbs_buffer[buf_index..], b.limbs[<span class="tok-number">0</span>..b_len]);</span>
<span class="line" id="L706">            buf_index += b_len;</span>
<span class="line" id="L707">            <span class="tok-kw">break</span> :blk a.toMutable(limbs_buffer[start..buf_index]).toConst();</span>
<span class="line" id="L708">        } <span class="tok-kw">else</span> b;</span>
<span class="line" id="L709"></span>
<span class="line" id="L710">        <span class="tok-kw">return</span> rma.mulWrapNoAlias(a_copy, b_copy, signedness, bit_count, allocator);</span>
<span class="line" id="L711">    }</span>
<span class="line" id="L712"></span>
<span class="line" id="L713">    <span class="tok-comment">/// rma = a * b with 2s-complement wrapping semantics.</span></span>
<span class="line" id="L714">    <span class="tok-comment">///</span></span>
<span class="line" id="L715">    <span class="tok-comment">/// `rma` may not alias with `a` or `b`.</span></span>
<span class="line" id="L716">    <span class="tok-comment">/// `a` and `b` may alias with each other.</span></span>
<span class="line" id="L717">    <span class="tok-comment">///</span></span>
<span class="line" id="L718">    <span class="tok-comment">/// Asserts the result fits in `rma`. An upper bound on the number of limbs needed by</span></span>
<span class="line" id="L719">    <span class="tok-comment">/// rma is given by `a.limbs.len + b.limbs.len`.</span></span>
<span class="line" id="L720">    <span class="tok-comment">///</span></span>
<span class="line" id="L721">    <span class="tok-comment">/// If `allocator` is provided, it will be used for temporary storage to improve</span></span>
<span class="line" id="L722">    <span class="tok-comment">/// multiplication performance. `error.OutOfMemory` is handled with a fallback algorithm.</span></span>
<span class="line" id="L723">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">mulWrapNoAlias</span>(</span>
<span class="line" id="L724">        rma: *Mutable,</span>
<span class="line" id="L725">        a: Const,</span>
<span class="line" id="L726">        b: Const,</span>
<span class="line" id="L727">        signedness: Signedness,</span>
<span class="line" id="L728">        bit_count: <span class="tok-type">usize</span>,</span>
<span class="line" id="L729">        allocator: ?Allocator,</span>
<span class="line" id="L730">    ) <span class="tok-type">void</span> {</span>
<span class="line" id="L731">        assert(rma.limbs.ptr != a.limbs.ptr); <span class="tok-comment">// illegal aliasing</span>
</span>
<span class="line" id="L732">        assert(rma.limbs.ptr != b.limbs.ptr); <span class="tok-comment">// illegal aliasing</span>
</span>
<span class="line" id="L733"></span>
<span class="line" id="L734">        <span class="tok-kw">const</span> req_limbs = calcTwosCompLimbCount(bit_count);</span>
<span class="line" id="L735"></span>
<span class="line" id="L736">        <span class="tok-comment">// We can ignore the upper bits here, those results will be discarded anyway.</span>
</span>
<span class="line" id="L737">        <span class="tok-kw">const</span> a_limbs = a.limbs[<span class="tok-number">0</span>..math.min(req_limbs, a.limbs.len)];</span>
<span class="line" id="L738">        <span class="tok-kw">const</span> b_limbs = b.limbs[<span class="tok-number">0</span>..math.min(req_limbs, b.limbs.len)];</span>
<span class="line" id="L739"></span>
<span class="line" id="L740">        mem.set(Limb, rma.limbs[<span class="tok-number">0</span>..req_limbs], <span class="tok-number">0</span>);</span>
<span class="line" id="L741"></span>
<span class="line" id="L742">        llmulacc(.add, allocator, rma.limbs, a_limbs, b_limbs);</span>
<span class="line" id="L743">        rma.normalize(math.min(req_limbs, a.limbs.len + b.limbs.len));</span>
<span class="line" id="L744">        rma.positive = (a.positive == b.positive);</span>
<span class="line" id="L745">        rma.truncate(rma.toConst(), signedness, bit_count);</span>
<span class="line" id="L746">    }</span>
<span class="line" id="L747"></span>
<span class="line" id="L748">    <span class="tok-comment">/// r = @bitReverse(a) with 2s-complement semantics.</span></span>
<span class="line" id="L749">    <span class="tok-comment">/// r and a may be aliases.</span></span>
<span class="line" id="L750">    <span class="tok-comment">///</span></span>
<span class="line" id="L751">    <span class="tok-comment">/// Asserts the result fits in `r`. Upper bound on the number of limbs needed by</span></span>
<span class="line" id="L752">    <span class="tok-comment">/// r is `calcTwosCompLimbCount(bit_count)`.</span></span>
<span class="line" id="L753">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">bitReverse</span>(r: *Mutable, a: Const, signedness: Signedness, bit_count: <span class="tok-type">usize</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L754">        <span class="tok-kw">if</span> (bit_count == <span class="tok-number">0</span>) <span class="tok-kw">return</span>;</span>
<span class="line" id="L755"></span>
<span class="line" id="L756">        r.copy(a);</span>
<span class="line" id="L757"></span>
<span class="line" id="L758">        <span class="tok-kw">const</span> limbs_required = calcTwosCompLimbCount(bit_count);</span>
<span class="line" id="L759"></span>
<span class="line" id="L760">        <span class="tok-kw">if</span> (!a.positive) {</span>
<span class="line" id="L761">            r.positive = <span class="tok-null">true</span>; <span class="tok-comment">// Negate.</span>
</span>
<span class="line" id="L762">            r.bitNotWrap(r.toConst(), .unsigned, bit_count); <span class="tok-comment">// Bitwise NOT.</span>
</span>
<span class="line" id="L763">            r.addScalar(r.toConst(), <span class="tok-number">1</span>); <span class="tok-comment">// Add one.</span>
</span>
<span class="line" id="L764">        } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (limbs_required &gt; a.limbs.len) {</span>
<span class="line" id="L765">            <span class="tok-comment">// Zero-extend to our output length</span>
</span>
<span class="line" id="L766">            <span class="tok-kw">for</span> (r.limbs[a.limbs.len..limbs_required]) |*limb| {</span>
<span class="line" id="L767">                limb.* = <span class="tok-number">0</span>;</span>
<span class="line" id="L768">            }</span>
<span class="line" id="L769">            r.len = limbs_required;</span>
<span class="line" id="L770">        }</span>
<span class="line" id="L771"></span>
<span class="line" id="L772">        <span class="tok-comment">// 0b0..01..1000 with @log2(@sizeOf(Limb)) consecutive ones</span>
</span>
<span class="line" id="L773">        <span class="tok-kw">const</span> endian_mask: <span class="tok-type">usize</span> = (<span class="tok-builtin">@sizeOf</span>(Limb) - <span class="tok-number">1</span>) &lt;&lt; <span class="tok-number">3</span>;</span>
<span class="line" id="L774"></span>
<span class="line" id="L775">        <span class="tok-kw">var</span> bytes = std.mem.sliceAsBytes(r.limbs);</span>
<span class="line" id="L776">        <span class="tok-kw">var</span> bits = std.packed_int_array.PackedIntSliceEndian(<span class="tok-type">u1</span>, .Little).init(bytes, limbs_required * <span class="tok-builtin">@bitSizeOf</span>(Limb));</span>
<span class="line" id="L777"></span>
<span class="line" id="L778">        <span class="tok-kw">var</span> k: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L779">        <span class="tok-kw">while</span> (k &lt; ((bit_count + <span class="tok-number">1</span>) / <span class="tok-number">2</span>)) : (k += <span class="tok-number">1</span>) {</span>
<span class="line" id="L780">            <span class="tok-kw">var</span> i = k;</span>
<span class="line" id="L781">            <span class="tok-kw">var</span> rev_i = bit_count - i - <span class="tok-number">1</span>;</span>
<span class="line" id="L782"></span>
<span class="line" id="L783">            <span class="tok-comment">// This &quot;endian mask&quot; remaps a low (LE) byte to the corresponding high</span>
</span>
<span class="line" id="L784">            <span class="tok-comment">// (BE) byte in the Limb, without changing which limbs we are indexing</span>
</span>
<span class="line" id="L785">            <span class="tok-kw">if</span> (native_endian == .Big) {</span>
<span class="line" id="L786">                i ^= endian_mask;</span>
<span class="line" id="L787">                rev_i ^= endian_mask;</span>
<span class="line" id="L788">            }</span>
<span class="line" id="L789"></span>
<span class="line" id="L790">            <span class="tok-kw">const</span> bit_i = bits.get(i);</span>
<span class="line" id="L791">            <span class="tok-kw">const</span> bit_rev_i = bits.get(rev_i);</span>
<span class="line" id="L792">            bits.set(i, bit_rev_i);</span>
<span class="line" id="L793">            bits.set(rev_i, bit_i);</span>
<span class="line" id="L794">        }</span>
<span class="line" id="L795"></span>
<span class="line" id="L796">        <span class="tok-comment">// Calculate signed-magnitude representation for output</span>
</span>
<span class="line" id="L797">        <span class="tok-kw">if</span> (signedness == .signed) {</span>
<span class="line" id="L798">            <span class="tok-kw">const</span> last_bit = <span class="tok-kw">switch</span> (native_endian) {</span>
<span class="line" id="L799">                .Little =&gt; bits.get(bit_count - <span class="tok-number">1</span>),</span>
<span class="line" id="L800">                .Big =&gt; bits.get((bit_count - <span class="tok-number">1</span>) ^ endian_mask),</span>
<span class="line" id="L801">            };</span>
<span class="line" id="L802">            <span class="tok-kw">if</span> (last_bit == <span class="tok-number">1</span>) {</span>
<span class="line" id="L803">                r.bitNotWrap(r.toConst(), .unsigned, bit_count); <span class="tok-comment">// Bitwise NOT.</span>
</span>
<span class="line" id="L804">                r.addScalar(r.toConst(), <span class="tok-number">1</span>); <span class="tok-comment">// Add one.</span>
</span>
<span class="line" id="L805">                r.positive = <span class="tok-null">false</span>; <span class="tok-comment">// Negate.</span>
</span>
<span class="line" id="L806">            }</span>
<span class="line" id="L807">        }</span>
<span class="line" id="L808">        r.normalize(r.len);</span>
<span class="line" id="L809">    }</span>
<span class="line" id="L810"></span>
<span class="line" id="L811">    <span class="tok-comment">/// r = @byteSwap(a) with 2s-complement semantics.</span></span>
<span class="line" id="L812">    <span class="tok-comment">/// r and a may be aliases.</span></span>
<span class="line" id="L813">    <span class="tok-comment">///</span></span>
<span class="line" id="L814">    <span class="tok-comment">/// Asserts the result fits in `r`. Upper bound on the number of limbs needed by</span></span>
<span class="line" id="L815">    <span class="tok-comment">/// r is `calcTwosCompLimbCount(8*byte_count)`.</span></span>
<span class="line" id="L816">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">byteSwap</span>(r: *Mutable, a: Const, signedness: Signedness, byte_count: <span class="tok-type">usize</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L817">        <span class="tok-kw">if</span> (byte_count == <span class="tok-number">0</span>) <span class="tok-kw">return</span>;</span>
<span class="line" id="L818"></span>
<span class="line" id="L819">        r.copy(a);</span>
<span class="line" id="L820">        <span class="tok-kw">const</span> limbs_required = calcTwosCompLimbCount(<span class="tok-number">8</span> * byte_count);</span>
<span class="line" id="L821"></span>
<span class="line" id="L822">        <span class="tok-kw">if</span> (!a.positive) {</span>
<span class="line" id="L823">            r.positive = <span class="tok-null">true</span>; <span class="tok-comment">// Negate.</span>
</span>
<span class="line" id="L824">            r.bitNotWrap(r.toConst(), .unsigned, <span class="tok-number">8</span> * byte_count); <span class="tok-comment">// Bitwise NOT.</span>
</span>
<span class="line" id="L825">            r.addScalar(r.toConst(), <span class="tok-number">1</span>); <span class="tok-comment">// Add one.</span>
</span>
<span class="line" id="L826">        } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (limbs_required &gt; a.limbs.len) {</span>
<span class="line" id="L827">            <span class="tok-comment">// Zero-extend to our output length</span>
</span>
<span class="line" id="L828">            <span class="tok-kw">for</span> (r.limbs[a.limbs.len..limbs_required]) |*limb| {</span>
<span class="line" id="L829">                limb.* = <span class="tok-number">0</span>;</span>
<span class="line" id="L830">            }</span>
<span class="line" id="L831">            r.len = limbs_required;</span>
<span class="line" id="L832">        }</span>
<span class="line" id="L833"></span>
<span class="line" id="L834">        <span class="tok-comment">// 0b0..01..1 with @log2(@sizeOf(Limb)) trailing ones</span>
</span>
<span class="line" id="L835">        <span class="tok-kw">const</span> endian_mask: <span class="tok-type">usize</span> = <span class="tok-builtin">@sizeOf</span>(Limb) - <span class="tok-number">1</span>;</span>
<span class="line" id="L836"></span>
<span class="line" id="L837">        <span class="tok-kw">var</span> bytes = std.mem.sliceAsBytes(r.limbs);</span>
<span class="line" id="L838">        assert(bytes.len &gt;= byte_count);</span>
<span class="line" id="L839"></span>
<span class="line" id="L840">        <span class="tok-kw">var</span> k: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L841">        <span class="tok-kw">while</span> (k &lt; (byte_count + <span class="tok-number">1</span>) / <span class="tok-number">2</span>) : (k += <span class="tok-number">1</span>) {</span>
<span class="line" id="L842">            <span class="tok-kw">var</span> i = k;</span>
<span class="line" id="L843">            <span class="tok-kw">var</span> rev_i = byte_count - k - <span class="tok-number">1</span>;</span>
<span class="line" id="L844"></span>
<span class="line" id="L845">            <span class="tok-comment">// This &quot;endian mask&quot; remaps a low (LE) byte to the corresponding high</span>
</span>
<span class="line" id="L846">            <span class="tok-comment">// (BE) byte in the Limb, without changing which limbs we are indexing</span>
</span>
<span class="line" id="L847">            <span class="tok-kw">if</span> (native_endian == .Big) {</span>
<span class="line" id="L848">                i ^= endian_mask;</span>
<span class="line" id="L849">                rev_i ^= endian_mask;</span>
<span class="line" id="L850">            }</span>
<span class="line" id="L851"></span>
<span class="line" id="L852">            <span class="tok-kw">const</span> byte_i = bytes[i];</span>
<span class="line" id="L853">            <span class="tok-kw">const</span> byte_rev_i = bytes[rev_i];</span>
<span class="line" id="L854">            bytes[rev_i] = byte_i;</span>
<span class="line" id="L855">            bytes[i] = byte_rev_i;</span>
<span class="line" id="L856">        }</span>
<span class="line" id="L857"></span>
<span class="line" id="L858">        <span class="tok-comment">// Calculate signed-magnitude representation for output</span>
</span>
<span class="line" id="L859">        <span class="tok-kw">if</span> (signedness == .signed) {</span>
<span class="line" id="L860">            <span class="tok-kw">const</span> last_byte = <span class="tok-kw">switch</span> (native_endian) {</span>
<span class="line" id="L861">                .Little =&gt; bytes[byte_count - <span class="tok-number">1</span>],</span>
<span class="line" id="L862">                .Big =&gt; bytes[(byte_count - <span class="tok-number">1</span>) ^ endian_mask],</span>
<span class="line" id="L863">            };</span>
<span class="line" id="L864"></span>
<span class="line" id="L865">            <span class="tok-kw">if</span> (last_byte &amp; (<span class="tok-number">1</span> &lt;&lt; <span class="tok-number">7</span>) != <span class="tok-number">0</span>) { <span class="tok-comment">// Check sign bit of last byte</span>
</span>
<span class="line" id="L866">                r.bitNotWrap(r.toConst(), .unsigned, <span class="tok-number">8</span> * byte_count); <span class="tok-comment">// Bitwise NOT.</span>
</span>
<span class="line" id="L867">                r.addScalar(r.toConst(), <span class="tok-number">1</span>); <span class="tok-comment">// Add one.</span>
</span>
<span class="line" id="L868">                r.positive = <span class="tok-null">false</span>; <span class="tok-comment">// Negate.</span>
</span>
<span class="line" id="L869">            }</span>
<span class="line" id="L870">        }</span>
<span class="line" id="L871">        r.normalize(r.len);</span>
<span class="line" id="L872">    }</span>
<span class="line" id="L873"></span>
<span class="line" id="L874">    <span class="tok-comment">/// r = @popCount(a) with 2s-complement semantics.</span></span>
<span class="line" id="L875">    <span class="tok-comment">/// r and a may be aliases.</span></span>
<span class="line" id="L876">    <span class="tok-comment">///</span></span>
<span class="line" id="L877">    <span class="tok-comment">/// Assets the result fits in `r`. Upper bound on the number of limbs needed by</span></span>
<span class="line" id="L878">    <span class="tok-comment">/// r is `calcTwosCompLimbCount(bit_count)`.</span></span>
<span class="line" id="L879">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">popCount</span>(r: *Mutable, a: Const, bit_count: <span class="tok-type">usize</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L880">        r.copy(a);</span>
<span class="line" id="L881"></span>
<span class="line" id="L882">        <span class="tok-kw">if</span> (!a.positive) {</span>
<span class="line" id="L883">            r.positive = <span class="tok-null">true</span>; <span class="tok-comment">// Negate.</span>
</span>
<span class="line" id="L884">            r.bitNotWrap(r.toConst(), .unsigned, bit_count); <span class="tok-comment">// Bitwise NOT.</span>
</span>
<span class="line" id="L885">            r.addScalar(r.toConst(), <span class="tok-number">1</span>); <span class="tok-comment">// Add one.</span>
</span>
<span class="line" id="L886">        }</span>
<span class="line" id="L887"></span>
<span class="line" id="L888">        <span class="tok-kw">var</span> sum: Limb = <span class="tok-number">0</span>;</span>
<span class="line" id="L889">        <span class="tok-kw">for</span> (r.limbs[<span class="tok-number">0</span>..r.len]) |limb| {</span>
<span class="line" id="L890">            sum += <span class="tok-builtin">@popCount</span>(Limb, limb);</span>
<span class="line" id="L891">        }</span>
<span class="line" id="L892">        r.set(sum);</span>
<span class="line" id="L893">    }</span>
<span class="line" id="L894"></span>
<span class="line" id="L895">    <span class="tok-comment">/// rma = a * a</span></span>
<span class="line" id="L896">    <span class="tok-comment">///</span></span>
<span class="line" id="L897">    <span class="tok-comment">/// `rma` may not alias with `a`.</span></span>
<span class="line" id="L898">    <span class="tok-comment">///</span></span>
<span class="line" id="L899">    <span class="tok-comment">/// Asserts the result fits in `rma`. An upper bound on the number of limbs needed by</span></span>
<span class="line" id="L900">    <span class="tok-comment">/// rma is given by `2 * a.limbs.len + 1`.</span></span>
<span class="line" id="L901">    <span class="tok-comment">///</span></span>
<span class="line" id="L902">    <span class="tok-comment">/// If `allocator` is provided, it will be used for temporary storage to improve</span></span>
<span class="line" id="L903">    <span class="tok-comment">/// multiplication performance. `error.OutOfMemory` is handled with a fallback algorithm.</span></span>
<span class="line" id="L904">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">sqrNoAlias</span>(rma: *Mutable, a: Const, opt_allocator: ?Allocator) <span class="tok-type">void</span> {</span>
<span class="line" id="L905">        _ = opt_allocator;</span>
<span class="line" id="L906">        assert(rma.limbs.ptr != a.limbs.ptr); <span class="tok-comment">// illegal aliasing</span>
</span>
<span class="line" id="L907"></span>
<span class="line" id="L908">        mem.set(Limb, rma.limbs, <span class="tok-number">0</span>);</span>
<span class="line" id="L909"></span>
<span class="line" id="L910">        llsquareBasecase(rma.limbs, a.limbs);</span>
<span class="line" id="L911"></span>
<span class="line" id="L912">        rma.normalize(<span class="tok-number">2</span> * a.limbs.len + <span class="tok-number">1</span>);</span>
<span class="line" id="L913">        rma.positive = <span class="tok-null">true</span>;</span>
<span class="line" id="L914">    }</span>
<span class="line" id="L915"></span>
<span class="line" id="L916">    <span class="tok-comment">/// q = a / b (rem r)</span></span>
<span class="line" id="L917">    <span class="tok-comment">///</span></span>
<span class="line" id="L918">    <span class="tok-comment">/// a / b are floored (rounded towards 0).</span></span>
<span class="line" id="L919">    <span class="tok-comment">/// q may alias with a or b.</span></span>
<span class="line" id="L920">    <span class="tok-comment">///</span></span>
<span class="line" id="L921">    <span class="tok-comment">/// Asserts there is enough memory to store q and r.</span></span>
<span class="line" id="L922">    <span class="tok-comment">/// The upper bound for r limb count is `b.limbs.len`.</span></span>
<span class="line" id="L923">    <span class="tok-comment">/// The upper bound for q limb count is given by `a.limbs`.</span></span>
<span class="line" id="L924">    <span class="tok-comment">///</span></span>
<span class="line" id="L925">    <span class="tok-comment">/// If `allocator` is provided, it will be used for temporary storage to improve</span></span>
<span class="line" id="L926">    <span class="tok-comment">/// multiplication performance. `error.OutOfMemory` is handled with a fallback algorithm.</span></span>
<span class="line" id="L927">    <span class="tok-comment">///</span></span>
<span class="line" id="L928">    <span class="tok-comment">/// `limbs_buffer` is used for temporary storage. The amount required is given by `calcDivLimbsBufferLen`.</span></span>
<span class="line" id="L929">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">divFloor</span>(</span>
<span class="line" id="L930">        q: *Mutable,</span>
<span class="line" id="L931">        r: *Mutable,</span>
<span class="line" id="L932">        a: Const,</span>
<span class="line" id="L933">        b: Const,</span>
<span class="line" id="L934">        limbs_buffer: []Limb,</span>
<span class="line" id="L935">    ) <span class="tok-type">void</span> {</span>
<span class="line" id="L936">        <span class="tok-kw">const</span> sep = a.limbs.len + <span class="tok-number">2</span>;</span>
<span class="line" id="L937">        <span class="tok-kw">var</span> x = a.toMutable(limbs_buffer[<span class="tok-number">0</span>..sep]);</span>
<span class="line" id="L938">        <span class="tok-kw">var</span> y = b.toMutable(limbs_buffer[sep..]);</span>
<span class="line" id="L939"></span>
<span class="line" id="L940">        div(q, r, &amp;x, &amp;y);</span>
<span class="line" id="L941"></span>
<span class="line" id="L942">        <span class="tok-comment">// Note, `div` performs truncating division, which satisfies</span>
</span>
<span class="line" id="L943">        <span class="tok-comment">// @divTrunc(a, b) * b + @rem(a, b) = a</span>
</span>
<span class="line" id="L944">        <span class="tok-comment">// so r = a - @divTrunc(a, b) * b</span>
</span>
<span class="line" id="L945">        <span class="tok-comment">// Note,  @rem(a, -b) = @rem(-b, a) = -@rem(a, b) = -@rem(-a, -b)</span>
</span>
<span class="line" id="L946">        <span class="tok-comment">// For divTrunc, we want to perform</span>
</span>
<span class="line" id="L947">        <span class="tok-comment">// @divFloor(a, b) * b + @mod(a, b) = a</span>
</span>
<span class="line" id="L948">        <span class="tok-comment">// Note:</span>
</span>
<span class="line" id="L949">        <span class="tok-comment">// @divFloor(-a, b)</span>
</span>
<span class="line" id="L950">        <span class="tok-comment">// = @divFloor(a, -b)</span>
</span>
<span class="line" id="L951">        <span class="tok-comment">// = -@divCeil(a, b)</span>
</span>
<span class="line" id="L952">        <span class="tok-comment">// = -@divFloor(a + b - 1, b)</span>
</span>
<span class="line" id="L953">        <span class="tok-comment">// = -@divTrunc(a + b - 1, b)</span>
</span>
<span class="line" id="L954"></span>
<span class="line" id="L955">        <span class="tok-comment">// Note (1):</span>
</span>
<span class="line" id="L956">        <span class="tok-comment">// @divTrunc(a + b - 1, b) * b + @rem(a + b - 1, b) = a + b - 1</span>
</span>
<span class="line" id="L957">        <span class="tok-comment">// = @divTrunc(a + b - 1, b) * b + @rem(a - 1, b) = a + b - 1</span>
</span>
<span class="line" id="L958">        <span class="tok-comment">// = @divTrunc(a + b - 1, b) * b + @rem(a - 1, b) - b + 1 = a</span>
</span>
<span class="line" id="L959"></span>
<span class="line" id="L960">        <span class="tok-kw">if</span> (a.positive <span class="tok-kw">and</span> b.positive) {</span>
<span class="line" id="L961">            <span class="tok-comment">// Positive-positive case, don't need to do anything.</span>
</span>
<span class="line" id="L962">        } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (a.positive <span class="tok-kw">and</span> !b.positive) {</span>
<span class="line" id="L963">            <span class="tok-comment">// a/-b -&gt; q is negative, and so we need to fix flooring.</span>
</span>
<span class="line" id="L964">            <span class="tok-comment">// Subtract one to make the division flooring.</span>
</span>
<span class="line" id="L965"></span>
<span class="line" id="L966">            <span class="tok-comment">// @divFloor(a, -b) * -b + @mod(a, -b) = a</span>
</span>
<span class="line" id="L967">            <span class="tok-comment">// If b divides a exactly, we have @divFloor(a, -b) * -b = a</span>
</span>
<span class="line" id="L968">            <span class="tok-comment">// Else, we have @divFloor(a, -b) * -b &gt; a, so @mod(a, -b) becomes negative</span>
</span>
<span class="line" id="L969"></span>
<span class="line" id="L970">            <span class="tok-comment">// We have:</span>
</span>
<span class="line" id="L971">            <span class="tok-comment">// @divFloor(a, -b) * -b + @mod(a, -b) = a</span>
</span>
<span class="line" id="L972">            <span class="tok-comment">// = -@divTrunc(a + b - 1, b) * -b + @mod(a, -b) = a</span>
</span>
<span class="line" id="L973">            <span class="tok-comment">// = @divTrunc(a + b - 1, b) * b + @mod(a, -b) = a</span>
</span>
<span class="line" id="L974"></span>
<span class="line" id="L975">            <span class="tok-comment">// Substitute a for (1):</span>
</span>
<span class="line" id="L976">            <span class="tok-comment">// @divTrunc(a + b - 1, b) * b + @rem(a - 1, b) - b + 1 = @divTrunc(a + b - 1, b) * b + @mod(a, -b)</span>
</span>
<span class="line" id="L977">            <span class="tok-comment">// Yields:</span>
</span>
<span class="line" id="L978">            <span class="tok-comment">// @mod(a, -b) = @rem(a - 1, b) - b + 1</span>
</span>
<span class="line" id="L979">            <span class="tok-comment">// Note that `r` holds @rem(a, b) at this point.</span>
</span>
<span class="line" id="L980">            <span class="tok-comment">//</span>
</span>
<span class="line" id="L981">            <span class="tok-comment">// If @rem(a, b) is not 0:</span>
</span>
<span class="line" id="L982">            <span class="tok-comment">//   @rem(a - 1, b) = @rem(a, b) - 1</span>
</span>
<span class="line" id="L983">            <span class="tok-comment">//   =&gt; @mod(a, -b) = @rem(a, b) - 1 - b + 1 = @rem(a, b) - b</span>
</span>
<span class="line" id="L984">            <span class="tok-comment">// Else:</span>
</span>
<span class="line" id="L985">            <span class="tok-comment">//   @rem(a - 1, b) = @rem(a + b - 1, b) = @rem(b - 1, b) = b - 1</span>
</span>
<span class="line" id="L986">            <span class="tok-comment">//   =&gt; @mod(a, -b) = b - 1 - b + 1 = 0</span>
</span>
<span class="line" id="L987">            <span class="tok-kw">if</span> (!r.eqZero()) {</span>
<span class="line" id="L988">                q.addScalar(q.toConst(), -<span class="tok-number">1</span>);</span>
<span class="line" id="L989">                r.positive = <span class="tok-null">true</span>;</span>
<span class="line" id="L990">                r.sub(r.toConst(), y.toConst().abs());</span>
<span class="line" id="L991">            }</span>
<span class="line" id="L992">        } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (!a.positive <span class="tok-kw">and</span> b.positive) {</span>
<span class="line" id="L993">            <span class="tok-comment">// -a/b -&gt; q is negative, and so we need to fix flooring.</span>
</span>
<span class="line" id="L994">            <span class="tok-comment">// Subtract one to make the division flooring.</span>
</span>
<span class="line" id="L995"></span>
<span class="line" id="L996">            <span class="tok-comment">// @divFloor(-a, b) * b + @mod(-a, b) = a</span>
</span>
<span class="line" id="L997">            <span class="tok-comment">// If b divides a exactly, we have @divFloor(-a, b) * b = -a</span>
</span>
<span class="line" id="L998">            <span class="tok-comment">// Else, we have @divFloor(-a, b) * b &lt; -a, so @mod(-a, b) becomes positive</span>
</span>
<span class="line" id="L999"></span>
<span class="line" id="L1000">            <span class="tok-comment">// We have:</span>
</span>
<span class="line" id="L1001">            <span class="tok-comment">// @divFloor(-a, b) * b + @mod(-a, b) = -a</span>
</span>
<span class="line" id="L1002">            <span class="tok-comment">// = -@divTrunc(a + b - 1, b) * b + @mod(-a, b) = -a</span>
</span>
<span class="line" id="L1003">            <span class="tok-comment">// = @divTrunc(a + b - 1, b) * b - @mod(-a, b) = a</span>
</span>
<span class="line" id="L1004"></span>
<span class="line" id="L1005">            <span class="tok-comment">// Substitute a for (1):</span>
</span>
<span class="line" id="L1006">            <span class="tok-comment">// @divTrunc(a + b - 1, b) * b + @rem(a - 1, b) - b + 1 = @divTrunc(a + b - 1, b) * b - @mod(-a, b)</span>
</span>
<span class="line" id="L1007">            <span class="tok-comment">// Yields:</span>
</span>
<span class="line" id="L1008">            <span class="tok-comment">// @rem(a - 1, b) - b + 1 = -@mod(-a, b)</span>
</span>
<span class="line" id="L1009">            <span class="tok-comment">// =&gt; -@mod(-a, b) = @rem(a - 1, b) - b + 1</span>
</span>
<span class="line" id="L1010">            <span class="tok-comment">// =&gt; @mod(-a, b) = -(@rem(a - 1, b) - b + 1) = -@rem(a - 1, b) + b - 1</span>
</span>
<span class="line" id="L1011">            <span class="tok-comment">//</span>
</span>
<span class="line" id="L1012">            <span class="tok-comment">// If @rem(a, b) is not 0:</span>
</span>
<span class="line" id="L1013">            <span class="tok-comment">//   @rem(a - 1, b) = @rem(a, b) - 1</span>
</span>
<span class="line" id="L1014">            <span class="tok-comment">//   =&gt; @mod(-a, b) = -(@rem(a, b) - 1) + b - 1 = -@rem(a, b) + 1 + b - 1 = -@rem(a, b) + b</span>
</span>
<span class="line" id="L1015">            <span class="tok-comment">// Else :</span>
</span>
<span class="line" id="L1016">            <span class="tok-comment">//   @rem(a - 1, b) = b - 1</span>
</span>
<span class="line" id="L1017">            <span class="tok-comment">//   =&gt; @mod(-a, b) = -(b - 1) + b - 1 = 0</span>
</span>
<span class="line" id="L1018">            <span class="tok-kw">if</span> (!r.eqZero()) {</span>
<span class="line" id="L1019">                q.addScalar(q.toConst(), -<span class="tok-number">1</span>);</span>
<span class="line" id="L1020">                r.positive = <span class="tok-null">false</span>;</span>
<span class="line" id="L1021">                r.add(r.toConst(), y.toConst().abs());</span>
<span class="line" id="L1022">            }</span>
<span class="line" id="L1023">        } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (!a.positive <span class="tok-kw">and</span> !b.positive) {</span>
<span class="line" id="L1024">            <span class="tok-comment">// a/b -&gt; q is positive, don't need to do anything to fix flooring.</span>
</span>
<span class="line" id="L1025"></span>
<span class="line" id="L1026">            <span class="tok-comment">// @divFloor(-a, -b) * -b + @mod(-a, -b) = -a</span>
</span>
<span class="line" id="L1027">            <span class="tok-comment">// If b divides a exactly, we have @divFloor(-a, -b) * -b = -a</span>
</span>
<span class="line" id="L1028">            <span class="tok-comment">// Else, we have @divFloor(-a, -b) * -b &gt; -a, so @mod(-a, -b) becomes negative</span>
</span>
<span class="line" id="L1029"></span>
<span class="line" id="L1030">            <span class="tok-comment">// We have:</span>
</span>
<span class="line" id="L1031">            <span class="tok-comment">// @divFloor(-a, -b) * -b + @mod(-a, -b) = -a</span>
</span>
<span class="line" id="L1032">            <span class="tok-comment">// = @divTrunc(a, b) * -b + @mod(-a, -b) = -a</span>
</span>
<span class="line" id="L1033">            <span class="tok-comment">// = @divTrunc(a, b) * b - @mod(-a, -b) = a</span>
</span>
<span class="line" id="L1034"></span>
<span class="line" id="L1035">            <span class="tok-comment">// We also have:</span>
</span>
<span class="line" id="L1036">            <span class="tok-comment">// @divTrunc(a, b) * b + @rem(a, b) = a</span>
</span>
<span class="line" id="L1037"></span>
<span class="line" id="L1038">            <span class="tok-comment">// Substitute a:</span>
</span>
<span class="line" id="L1039">            <span class="tok-comment">// @divTrunc(a, b) * b + @rem(a, b) = @divTrunc(a, b) * b - @mod(-a, -b)</span>
</span>
<span class="line" id="L1040">            <span class="tok-comment">// =&gt; @rem(a, b) = -@mod(-a, -b)</span>
</span>
<span class="line" id="L1041">            <span class="tok-comment">// =&gt; @mod(-a, -b) = -@rem(a, b)</span>
</span>
<span class="line" id="L1042">            r.positive = <span class="tok-null">false</span>;</span>
<span class="line" id="L1043">        }</span>
<span class="line" id="L1044">    }</span>
<span class="line" id="L1045"></span>
<span class="line" id="L1046">    <span class="tok-comment">/// q = a / b (rem r)</span></span>
<span class="line" id="L1047">    <span class="tok-comment">///</span></span>
<span class="line" id="L1048">    <span class="tok-comment">/// a / b are truncated (rounded towards -inf).</span></span>
<span class="line" id="L1049">    <span class="tok-comment">/// q may alias with a or b.</span></span>
<span class="line" id="L1050">    <span class="tok-comment">///</span></span>
<span class="line" id="L1051">    <span class="tok-comment">/// Asserts there is enough memory to store q and r.</span></span>
<span class="line" id="L1052">    <span class="tok-comment">/// The upper bound for r limb count is `b.limbs.len`.</span></span>
<span class="line" id="L1053">    <span class="tok-comment">/// The upper bound for q limb count is given by `a.limbs.len`.</span></span>
<span class="line" id="L1054">    <span class="tok-comment">///</span></span>
<span class="line" id="L1055">    <span class="tok-comment">/// If `allocator` is provided, it will be used for temporary storage to improve</span></span>
<span class="line" id="L1056">    <span class="tok-comment">/// multiplication performance. `error.OutOfMemory` is handled with a fallback algorithm.</span></span>
<span class="line" id="L1057">    <span class="tok-comment">///</span></span>
<span class="line" id="L1058">    <span class="tok-comment">/// `limbs_buffer` is used for temporary storage. The amount required is given by `calcDivLimbsBufferLen`.</span></span>
<span class="line" id="L1059">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">divTrunc</span>(</span>
<span class="line" id="L1060">        q: *Mutable,</span>
<span class="line" id="L1061">        r: *Mutable,</span>
<span class="line" id="L1062">        a: Const,</span>
<span class="line" id="L1063">        b: Const,</span>
<span class="line" id="L1064">        limbs_buffer: []Limb,</span>
<span class="line" id="L1065">    ) <span class="tok-type">void</span> {</span>
<span class="line" id="L1066">        <span class="tok-kw">const</span> sep = a.limbs.len + <span class="tok-number">2</span>;</span>
<span class="line" id="L1067">        <span class="tok-kw">var</span> x = a.toMutable(limbs_buffer[<span class="tok-number">0</span>..sep]);</span>
<span class="line" id="L1068">        <span class="tok-kw">var</span> y = b.toMutable(limbs_buffer[sep..]);</span>
<span class="line" id="L1069"></span>
<span class="line" id="L1070">        div(q, r, &amp;x, &amp;y);</span>
<span class="line" id="L1071">    }</span>
<span class="line" id="L1072"></span>
<span class="line" id="L1073">    <span class="tok-comment">/// r = a &lt;&lt; shift, in other words, r = a * 2^shift</span></span>
<span class="line" id="L1074">    <span class="tok-comment">///</span></span>
<span class="line" id="L1075">    <span class="tok-comment">/// r and a may alias.</span></span>
<span class="line" id="L1076">    <span class="tok-comment">///</span></span>
<span class="line" id="L1077">    <span class="tok-comment">/// Asserts there is enough memory to fit the result. The upper bound Limb count is</span></span>
<span class="line" id="L1078">    <span class="tok-comment">/// `a.limbs.len + (shift / (@sizeOf(Limb) * 8))`.</span></span>
<span class="line" id="L1079">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">shiftLeft</span>(r: *Mutable, a: Const, shift: <span class="tok-type">usize</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L1080">        llshl(r.limbs[<span class="tok-number">0</span>..], a.limbs[<span class="tok-number">0</span>..a.limbs.len], shift);</span>
<span class="line" id="L1081">        r.normalize(a.limbs.len + (shift / limb_bits) + <span class="tok-number">1</span>);</span>
<span class="line" id="L1082">        r.positive = a.positive;</span>
<span class="line" id="L1083">    }</span>
<span class="line" id="L1084"></span>
<span class="line" id="L1085">    <span class="tok-comment">/// r = a &lt;&lt;| shift with 2s-complement saturating semantics.</span></span>
<span class="line" id="L1086">    <span class="tok-comment">///</span></span>
<span class="line" id="L1087">    <span class="tok-comment">/// r and a may alias.</span></span>
<span class="line" id="L1088">    <span class="tok-comment">///</span></span>
<span class="line" id="L1089">    <span class="tok-comment">/// Asserts there is enough memory to fit the result. The upper bound Limb count is</span></span>
<span class="line" id="L1090">    <span class="tok-comment">/// r is `calcTwosCompLimbCount(bit_count)`.</span></span>
<span class="line" id="L1091">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">shiftLeftSat</span>(r: *Mutable, a: Const, shift: <span class="tok-type">usize</span>, signedness: Signedness, bit_count: <span class="tok-type">usize</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L1092">        <span class="tok-comment">// Special case: When the argument is negative, but the result is supposed to be unsigned,</span>
</span>
<span class="line" id="L1093">        <span class="tok-comment">// return 0 in all cases.</span>
</span>
<span class="line" id="L1094">        <span class="tok-kw">if</span> (!a.positive <span class="tok-kw">and</span> signedness == .unsigned) {</span>
<span class="line" id="L1095">            r.set(<span class="tok-number">0</span>);</span>
<span class="line" id="L1096">            <span class="tok-kw">return</span>;</span>
<span class="line" id="L1097">        }</span>
<span class="line" id="L1098"></span>
<span class="line" id="L1099">        <span class="tok-comment">// Check whether the shift is going to overflow. This is the case</span>
</span>
<span class="line" id="L1100">        <span class="tok-comment">// when (in 2s complement) any bit above `bit_count - shift` is set in the unshifted value.</span>
</span>
<span class="line" id="L1101">        <span class="tok-comment">// Note, the sign bit is not counted here.</span>
</span>
<span class="line" id="L1102"></span>
<span class="line" id="L1103">        <span class="tok-comment">// Handle shifts larger than the target type. This also deals with</span>
</span>
<span class="line" id="L1104">        <span class="tok-comment">// 0-bit integers.</span>
</span>
<span class="line" id="L1105">        <span class="tok-kw">if</span> (bit_count &lt;= shift) {</span>
<span class="line" id="L1106">            <span class="tok-comment">// In this case, there is only no overflow if `a` is zero.</span>
</span>
<span class="line" id="L1107">            <span class="tok-kw">if</span> (a.eqZero()) {</span>
<span class="line" id="L1108">                r.set(<span class="tok-number">0</span>);</span>
<span class="line" id="L1109">            } <span class="tok-kw">else</span> {</span>
<span class="line" id="L1110">                r.setTwosCompIntLimit(<span class="tok-kw">if</span> (a.positive) .max <span class="tok-kw">else</span> .min, signedness, bit_count);</span>
<span class="line" id="L1111">            }</span>
<span class="line" id="L1112">            <span class="tok-kw">return</span>;</span>
<span class="line" id="L1113">        }</span>
<span class="line" id="L1114"></span>
<span class="line" id="L1115">        <span class="tok-kw">const</span> checkbit = bit_count - shift - <span class="tok-builtin">@boolToInt</span>(signedness == .signed);</span>
<span class="line" id="L1116">        <span class="tok-comment">// If `checkbit` and more significant bits are zero, no overflow will take place.</span>
</span>
<span class="line" id="L1117"></span>
<span class="line" id="L1118">        <span class="tok-kw">if</span> (checkbit &gt;= a.limbs.len * limb_bits) {</span>
<span class="line" id="L1119">            <span class="tok-comment">// `checkbit` is outside the range of a, so definitely no overflow will take place. We</span>
</span>
<span class="line" id="L1120">            <span class="tok-comment">// can defer to a normal shift.</span>
</span>
<span class="line" id="L1121">            <span class="tok-comment">// Note that if `a` is normalized (which we assume), this checks for set bits in the upper limbs.</span>
</span>
<span class="line" id="L1122"></span>
<span class="line" id="L1123">            <span class="tok-comment">// Note, in this case r should already have enough limbs required to perform the normal shift.</span>
</span>
<span class="line" id="L1124">            <span class="tok-comment">// In this case the shift of the most significant limb may still overflow.</span>
</span>
<span class="line" id="L1125">            r.shiftLeft(a, shift);</span>
<span class="line" id="L1126">            <span class="tok-kw">return</span>;</span>
<span class="line" id="L1127">        } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (checkbit &lt; (a.limbs.len - <span class="tok-number">1</span>) * limb_bits) {</span>
<span class="line" id="L1128">            <span class="tok-comment">// `checkbit` is not in the most significant limb. If `a` is normalized the most significant</span>
</span>
<span class="line" id="L1129">            <span class="tok-comment">// limb will not be zero, so in this case we need to saturate. Note that `a.limbs.len` must be</span>
</span>
<span class="line" id="L1130">            <span class="tok-comment">// at least one according to normalization rules.</span>
</span>
<span class="line" id="L1131"></span>
<span class="line" id="L1132">            r.setTwosCompIntLimit(<span class="tok-kw">if</span> (a.positive) .max <span class="tok-kw">else</span> .min, signedness, bit_count);</span>
<span class="line" id="L1133">            <span class="tok-kw">return</span>;</span>
<span class="line" id="L1134">        }</span>
<span class="line" id="L1135"></span>
<span class="line" id="L1136">        <span class="tok-comment">// Generate a mask with the bits to check in the most signficant limb. We'll need to check</span>
</span>
<span class="line" id="L1137">        <span class="tok-comment">// all bits with equal or more significance than checkbit.</span>
</span>
<span class="line" id="L1138">        <span class="tok-comment">// const msb = @truncate(Log2Limb, checkbit);</span>
</span>
<span class="line" id="L1139">        <span class="tok-comment">// const checkmask = (@as(Limb, 1) &lt;&lt; msb) -% 1;</span>
</span>
<span class="line" id="L1140"></span>
<span class="line" id="L1141">        <span class="tok-kw">if</span> (a.limbs[a.limbs.len - <span class="tok-number">1</span>] &gt;&gt; <span class="tok-builtin">@truncate</span>(Log2Limb, checkbit) != <span class="tok-number">0</span>) {</span>
<span class="line" id="L1142">            <span class="tok-comment">// Need to saturate.</span>
</span>
<span class="line" id="L1143">            r.setTwosCompIntLimit(<span class="tok-kw">if</span> (a.positive) .max <span class="tok-kw">else</span> .min, signedness, bit_count);</span>
<span class="line" id="L1144">            <span class="tok-kw">return</span>;</span>
<span class="line" id="L1145">        }</span>
<span class="line" id="L1146"></span>
<span class="line" id="L1147">        <span class="tok-comment">// This shift should not be able to overflow, so invoke llshl and normalize manually</span>
</span>
<span class="line" id="L1148">        <span class="tok-comment">// to avoid the extra required limb.</span>
</span>
<span class="line" id="L1149">        llshl(r.limbs[<span class="tok-number">0</span>..], a.limbs[<span class="tok-number">0</span>..a.limbs.len], shift);</span>
<span class="line" id="L1150">        r.normalize(a.limbs.len + (shift / limb_bits));</span>
<span class="line" id="L1151">        r.positive = a.positive;</span>
<span class="line" id="L1152">    }</span>
<span class="line" id="L1153"></span>
<span class="line" id="L1154">    <span class="tok-comment">/// r = a &gt;&gt; shift</span></span>
<span class="line" id="L1155">    <span class="tok-comment">/// r and a may alias.</span></span>
<span class="line" id="L1156">    <span class="tok-comment">///</span></span>
<span class="line" id="L1157">    <span class="tok-comment">/// Asserts there is enough memory to fit the result. The upper bound Limb count is</span></span>
<span class="line" id="L1158">    <span class="tok-comment">/// `a.limbs.len - (shift / (@sizeOf(Limb) * 8))`.</span></span>
<span class="line" id="L1159">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">shiftRight</span>(r: *Mutable, a: Const, shift: <span class="tok-type">usize</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L1160">        <span class="tok-kw">if</span> (a.limbs.len &lt;= shift / limb_bits) {</span>
<span class="line" id="L1161">            r.len = <span class="tok-number">1</span>;</span>
<span class="line" id="L1162">            r.positive = <span class="tok-null">true</span>;</span>
<span class="line" id="L1163">            r.limbs[<span class="tok-number">0</span>] = <span class="tok-number">0</span>;</span>
<span class="line" id="L1164">            <span class="tok-kw">return</span>;</span>
<span class="line" id="L1165">        }</span>
<span class="line" id="L1166"></span>
<span class="line" id="L1167">        llshr(r.limbs[<span class="tok-number">0</span>..], a.limbs[<span class="tok-number">0</span>..a.limbs.len], shift);</span>
<span class="line" id="L1168">        r.normalize(a.limbs.len - (shift / limb_bits));</span>
<span class="line" id="L1169">        r.positive = a.positive;</span>
<span class="line" id="L1170">    }</span>
<span class="line" id="L1171"></span>
<span class="line" id="L1172">    <span class="tok-comment">/// r = ~a under 2s complement wrapping semantics.</span></span>
<span class="line" id="L1173">    <span class="tok-comment">/// r may alias with a.</span></span>
<span class="line" id="L1174">    <span class="tok-comment">///</span></span>
<span class="line" id="L1175">    <span class="tok-comment">/// Assets that r has enough limbs to store the result. The upper bound Limb count is</span></span>
<span class="line" id="L1176">    <span class="tok-comment">/// r is `calcTwosCompLimbCount(bit_count)`.</span></span>
<span class="line" id="L1177">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">bitNotWrap</span>(r: *Mutable, a: Const, signedness: Signedness, bit_count: <span class="tok-type">usize</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L1178">        r.copy(a.negate());</span>
<span class="line" id="L1179">        <span class="tok-kw">const</span> negative_one = Const{ .limbs = &amp;.{<span class="tok-number">1</span>}, .positive = <span class="tok-null">false</span> };</span>
<span class="line" id="L1180">        _ = r.addWrap(r.toConst(), negative_one, signedness, bit_count);</span>
<span class="line" id="L1181">    }</span>
<span class="line" id="L1182"></span>
<span class="line" id="L1183">    <span class="tok-comment">/// r = a | b under 2s complement semantics.</span></span>
<span class="line" id="L1184">    <span class="tok-comment">/// r may alias with a or b.</span></span>
<span class="line" id="L1185">    <span class="tok-comment">///</span></span>
<span class="line" id="L1186">    <span class="tok-comment">/// a and b are zero-extended to the longer of a or b.</span></span>
<span class="line" id="L1187">    <span class="tok-comment">///</span></span>
<span class="line" id="L1188">    <span class="tok-comment">/// Asserts that r has enough limbs to store the result. Upper bound is `math.max(a.limbs.len, b.limbs.len)`.</span></span>
<span class="line" id="L1189">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">bitOr</span>(r: *Mutable, a: Const, b: Const) <span class="tok-type">void</span> {</span>
<span class="line" id="L1190">        <span class="tok-comment">// Trivial cases, llsignedor does not support zero.</span>
</span>
<span class="line" id="L1191">        <span class="tok-kw">if</span> (a.eqZero()) {</span>
<span class="line" id="L1192">            r.copy(b);</span>
<span class="line" id="L1193">            <span class="tok-kw">return</span>;</span>
<span class="line" id="L1194">        } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (b.eqZero()) {</span>
<span class="line" id="L1195">            r.copy(a);</span>
<span class="line" id="L1196">            <span class="tok-kw">return</span>;</span>
<span class="line" id="L1197">        }</span>
<span class="line" id="L1198"></span>
<span class="line" id="L1199">        <span class="tok-kw">if</span> (a.limbs.len &gt;= b.limbs.len) {</span>
<span class="line" id="L1200">            r.positive = llsignedor(r.limbs, a.limbs, a.positive, b.limbs, b.positive);</span>
<span class="line" id="L1201">            r.normalize(<span class="tok-kw">if</span> (b.positive) a.limbs.len <span class="tok-kw">else</span> b.limbs.len);</span>
<span class="line" id="L1202">        } <span class="tok-kw">else</span> {</span>
<span class="line" id="L1203">            r.positive = llsignedor(r.limbs, b.limbs, b.positive, a.limbs, a.positive);</span>
<span class="line" id="L1204">            r.normalize(<span class="tok-kw">if</span> (a.positive) b.limbs.len <span class="tok-kw">else</span> a.limbs.len);</span>
<span class="line" id="L1205">        }</span>
<span class="line" id="L1206">    }</span>
<span class="line" id="L1207"></span>
<span class="line" id="L1208">    <span class="tok-comment">/// r = a &amp; b under 2s complement semantics.</span></span>
<span class="line" id="L1209">    <span class="tok-comment">/// r may alias with a or b.</span></span>
<span class="line" id="L1210">    <span class="tok-comment">///</span></span>
<span class="line" id="L1211">    <span class="tok-comment">/// Asserts that r has enough limbs to store the result.</span></span>
<span class="line" id="L1212">    <span class="tok-comment">/// If a or b is positive, the upper bound is `math.min(a.limbs.len, b.limbs.len)`.</span></span>
<span class="line" id="L1213">    <span class="tok-comment">/// If a and b are negative, the upper bound is `math.max(a.limbs.len, b.limbs.len) + 1`.</span></span>
<span class="line" id="L1214">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">bitAnd</span>(r: *Mutable, a: Const, b: Const) <span class="tok-type">void</span> {</span>
<span class="line" id="L1215">        <span class="tok-comment">// Trivial cases, llsignedand does not support zero.</span>
</span>
<span class="line" id="L1216">        <span class="tok-kw">if</span> (a.eqZero()) {</span>
<span class="line" id="L1217">            r.copy(a);</span>
<span class="line" id="L1218">            <span class="tok-kw">return</span>;</span>
<span class="line" id="L1219">        } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (b.eqZero()) {</span>
<span class="line" id="L1220">            r.copy(b);</span>
<span class="line" id="L1221">            <span class="tok-kw">return</span>;</span>
<span class="line" id="L1222">        }</span>
<span class="line" id="L1223"></span>
<span class="line" id="L1224">        <span class="tok-kw">if</span> (a.limbs.len &gt;= b.limbs.len) {</span>
<span class="line" id="L1225">            r.positive = llsignedand(r.limbs, a.limbs, a.positive, b.limbs, b.positive);</span>
<span class="line" id="L1226">            r.normalize(<span class="tok-kw">if</span> (a.positive <span class="tok-kw">or</span> b.positive) b.limbs.len <span class="tok-kw">else</span> a.limbs.len + <span class="tok-number">1</span>);</span>
<span class="line" id="L1227">        } <span class="tok-kw">else</span> {</span>
<span class="line" id="L1228">            r.positive = llsignedand(r.limbs, b.limbs, b.positive, a.limbs, a.positive);</span>
<span class="line" id="L1229">            r.normalize(<span class="tok-kw">if</span> (a.positive <span class="tok-kw">or</span> b.positive) a.limbs.len <span class="tok-kw">else</span> b.limbs.len + <span class="tok-number">1</span>);</span>
<span class="line" id="L1230">        }</span>
<span class="line" id="L1231">    }</span>
<span class="line" id="L1232"></span>
<span class="line" id="L1233">    <span class="tok-comment">/// r = a ^ b under 2s complement semantics.</span></span>
<span class="line" id="L1234">    <span class="tok-comment">/// r may alias with a or b.</span></span>
<span class="line" id="L1235">    <span class="tok-comment">///</span></span>
<span class="line" id="L1236">    <span class="tok-comment">/// Asserts that r has enough limbs to store the result. If a and b share the same signedness, the</span></span>
<span class="line" id="L1237">    <span class="tok-comment">/// upper bound is `math.max(a.limbs.len, b.limbs.len)`. Otherwise, if either a or b is negative</span></span>
<span class="line" id="L1238">    <span class="tok-comment">/// but not both, the upper bound is `math.max(a.limbs.len, b.limbs.len) + 1`.</span></span>
<span class="line" id="L1239">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">bitXor</span>(r: *Mutable, a: Const, b: Const) <span class="tok-type">void</span> {</span>
<span class="line" id="L1240">        <span class="tok-comment">// Trivial cases, because llsignedxor does not support negative zero.</span>
</span>
<span class="line" id="L1241">        <span class="tok-kw">if</span> (a.eqZero()) {</span>
<span class="line" id="L1242">            r.copy(b);</span>
<span class="line" id="L1243">            <span class="tok-kw">return</span>;</span>
<span class="line" id="L1244">        } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (b.eqZero()) {</span>
<span class="line" id="L1245">            r.copy(a);</span>
<span class="line" id="L1246">            <span class="tok-kw">return</span>;</span>
<span class="line" id="L1247">        }</span>
<span class="line" id="L1248"></span>
<span class="line" id="L1249">        <span class="tok-kw">if</span> (a.limbs.len &gt; b.limbs.len) {</span>
<span class="line" id="L1250">            r.positive = llsignedxor(r.limbs, a.limbs, a.positive, b.limbs, b.positive);</span>
<span class="line" id="L1251">            r.normalize(a.limbs.len + <span class="tok-builtin">@boolToInt</span>(a.positive != b.positive));</span>
<span class="line" id="L1252">        } <span class="tok-kw">else</span> {</span>
<span class="line" id="L1253">            r.positive = llsignedxor(r.limbs, b.limbs, b.positive, a.limbs, a.positive);</span>
<span class="line" id="L1254">            r.normalize(b.limbs.len + <span class="tok-builtin">@boolToInt</span>(a.positive != b.positive));</span>
<span class="line" id="L1255">        }</span>
<span class="line" id="L1256">    }</span>
<span class="line" id="L1257"></span>
<span class="line" id="L1258">    <span class="tok-comment">/// rma may alias x or y.</span></span>
<span class="line" id="L1259">    <span class="tok-comment">/// x and y may alias each other.</span></span>
<span class="line" id="L1260">    <span class="tok-comment">/// Asserts that `rma` has enough limbs to store the result. Upper bound is</span></span>
<span class="line" id="L1261">    <span class="tok-comment">/// `math.min(x.limbs.len, y.limbs.len)`.</span></span>
<span class="line" id="L1262">    <span class="tok-comment">///</span></span>
<span class="line" id="L1263">    <span class="tok-comment">/// `limbs_buffer` is used for temporary storage during the operation. When this function returns,</span></span>
<span class="line" id="L1264">    <span class="tok-comment">/// it will have the same length as it had when the function was called.</span></span>
<span class="line" id="L1265">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">gcd</span>(rma: *Mutable, x: Const, y: Const, limbs_buffer: *std.ArrayList(Limb)) !<span class="tok-type">void</span> {</span>
<span class="line" id="L1266">        <span class="tok-kw">const</span> prev_len = limbs_buffer.items.len;</span>
<span class="line" id="L1267">        <span class="tok-kw">defer</span> limbs_buffer.shrinkRetainingCapacity(prev_len);</span>
<span class="line" id="L1268">        <span class="tok-kw">const</span> x_copy = <span class="tok-kw">if</span> (rma.limbs.ptr == x.limbs.ptr) blk: {</span>
<span class="line" id="L1269">            <span class="tok-kw">const</span> start = limbs_buffer.items.len;</span>
<span class="line" id="L1270">            <span class="tok-kw">try</span> limbs_buffer.appendSlice(x.limbs);</span>
<span class="line" id="L1271">            <span class="tok-kw">break</span> :blk x.toMutable(limbs_buffer.items[start..]).toConst();</span>
<span class="line" id="L1272">        } <span class="tok-kw">else</span> x;</span>
<span class="line" id="L1273">        <span class="tok-kw">const</span> y_copy = <span class="tok-kw">if</span> (rma.limbs.ptr == y.limbs.ptr) blk: {</span>
<span class="line" id="L1274">            <span class="tok-kw">const</span> start = limbs_buffer.items.len;</span>
<span class="line" id="L1275">            <span class="tok-kw">try</span> limbs_buffer.appendSlice(y.limbs);</span>
<span class="line" id="L1276">            <span class="tok-kw">break</span> :blk y.toMutable(limbs_buffer.items[start..]).toConst();</span>
<span class="line" id="L1277">        } <span class="tok-kw">else</span> y;</span>
<span class="line" id="L1278"></span>
<span class="line" id="L1279">        <span class="tok-kw">return</span> gcdLehmer(rma, x_copy, y_copy, limbs_buffer);</span>
<span class="line" id="L1280">    }</span>
<span class="line" id="L1281"></span>
<span class="line" id="L1282">    <span class="tok-comment">/// q = a ^ b</span></span>
<span class="line" id="L1283">    <span class="tok-comment">///</span></span>
<span class="line" id="L1284">    <span class="tok-comment">/// r may not alias a.</span></span>
<span class="line" id="L1285">    <span class="tok-comment">///</span></span>
<span class="line" id="L1286">    <span class="tok-comment">/// Asserts that `r` has enough limbs to store the result. Upper bound is</span></span>
<span class="line" id="L1287">    <span class="tok-comment">/// `calcPowLimbsBufferLen(a.bitCountAbs(), b)`.</span></span>
<span class="line" id="L1288">    <span class="tok-comment">///</span></span>
<span class="line" id="L1289">    <span class="tok-comment">/// `limbs_buffer` is used for temporary storage.</span></span>
<span class="line" id="L1290">    <span class="tok-comment">/// The amount required is given by `calcPowLimbsBufferLen`.</span></span>
<span class="line" id="L1291">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">pow</span>(r: *Mutable, a: Const, b: <span class="tok-type">u32</span>, limbs_buffer: []Limb) !<span class="tok-type">void</span> {</span>
<span class="line" id="L1292">        assert(r.limbs.ptr != a.limbs.ptr); <span class="tok-comment">// illegal aliasing</span>
</span>
<span class="line" id="L1293"></span>
<span class="line" id="L1294">        <span class="tok-comment">// Handle all the trivial cases first</span>
</span>
<span class="line" id="L1295">        <span class="tok-kw">switch</span> (b) {</span>
<span class="line" id="L1296">            <span class="tok-number">0</span> =&gt; {</span>
<span class="line" id="L1297">                <span class="tok-comment">// a^0 = 1</span>
</span>
<span class="line" id="L1298">                <span class="tok-kw">return</span> r.set(<span class="tok-number">1</span>);</span>
<span class="line" id="L1299">            },</span>
<span class="line" id="L1300">            <span class="tok-number">1</span> =&gt; {</span>
<span class="line" id="L1301">                <span class="tok-comment">// a^1 = a</span>
</span>
<span class="line" id="L1302">                <span class="tok-kw">return</span> r.copy(a);</span>
<span class="line" id="L1303">            },</span>
<span class="line" id="L1304">            <span class="tok-kw">else</span> =&gt; {},</span>
<span class="line" id="L1305">        }</span>
<span class="line" id="L1306"></span>
<span class="line" id="L1307">        <span class="tok-kw">if</span> (a.eqZero()) {</span>
<span class="line" id="L1308">            <span class="tok-comment">// 0^b = 0</span>
</span>
<span class="line" id="L1309">            <span class="tok-kw">return</span> r.set(<span class="tok-number">0</span>);</span>
<span class="line" id="L1310">        } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (a.limbs.len == <span class="tok-number">1</span> <span class="tok-kw">and</span> a.limbs[<span class="tok-number">0</span>] == <span class="tok-number">1</span>) {</span>
<span class="line" id="L1311">            <span class="tok-comment">// 1^b = 1 and -1^b = ±1</span>
</span>
<span class="line" id="L1312">            r.set(<span class="tok-number">1</span>);</span>
<span class="line" id="L1313">            r.positive = a.positive <span class="tok-kw">or</span> (b &amp; <span class="tok-number">1</span>) == <span class="tok-number">0</span>;</span>
<span class="line" id="L1314">            <span class="tok-kw">return</span>;</span>
<span class="line" id="L1315">        }</span>
<span class="line" id="L1316"></span>
<span class="line" id="L1317">        <span class="tok-comment">// Here a&gt;1 and b&gt;1</span>
</span>
<span class="line" id="L1318">        <span class="tok-kw">const</span> needed_limbs = calcPowLimbsBufferLen(a.bitCountAbs(), b);</span>
<span class="line" id="L1319">        assert(r.limbs.len &gt;= needed_limbs);</span>
<span class="line" id="L1320">        assert(limbs_buffer.len &gt;= needed_limbs);</span>
<span class="line" id="L1321"></span>
<span class="line" id="L1322">        llpow(r.limbs, a.limbs, b, limbs_buffer);</span>
<span class="line" id="L1323"></span>
<span class="line" id="L1324">        r.normalize(needed_limbs);</span>
<span class="line" id="L1325">        r.positive = a.positive <span class="tok-kw">or</span> (b &amp; <span class="tok-number">1</span>) == <span class="tok-number">0</span>;</span>
<span class="line" id="L1326">    }</span>
<span class="line" id="L1327"></span>
<span class="line" id="L1328">    <span class="tok-comment">/// rma may not alias x or y.</span></span>
<span class="line" id="L1329">    <span class="tok-comment">/// x and y may alias each other.</span></span>
<span class="line" id="L1330">    <span class="tok-comment">/// Asserts that `rma` has enough limbs to store the result. Upper bound is given by `calcGcdNoAliasLimbLen`.</span></span>
<span class="line" id="L1331">    <span class="tok-comment">///</span></span>
<span class="line" id="L1332">    <span class="tok-comment">/// `limbs_buffer` is used for temporary storage during the operation.</span></span>
<span class="line" id="L1333">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">gcdNoAlias</span>(rma: *Mutable, x: Const, y: Const, limbs_buffer: *std.ArrayList(Limb)) !<span class="tok-type">void</span> {</span>
<span class="line" id="L1334">        assert(rma.limbs.ptr != x.limbs.ptr); <span class="tok-comment">// illegal aliasing</span>
</span>
<span class="line" id="L1335">        assert(rma.limbs.ptr != y.limbs.ptr); <span class="tok-comment">// illegal aliasing</span>
</span>
<span class="line" id="L1336">        <span class="tok-kw">return</span> gcdLehmer(rma, x, y, limbs_buffer);</span>
<span class="line" id="L1337">    }</span>
<span class="line" id="L1338"></span>
<span class="line" id="L1339">    <span class="tok-kw">fn</span> <span class="tok-fn">gcdLehmer</span>(result: *Mutable, xa: Const, ya: Const, limbs_buffer: *std.ArrayList(Limb)) !<span class="tok-type">void</span> {</span>
<span class="line" id="L1340">        <span class="tok-kw">var</span> x = <span class="tok-kw">try</span> xa.toManaged(limbs_buffer.allocator);</span>
<span class="line" id="L1341">        <span class="tok-kw">defer</span> x.deinit();</span>
<span class="line" id="L1342">        x.abs();</span>
<span class="line" id="L1343"></span>
<span class="line" id="L1344">        <span class="tok-kw">var</span> y = <span class="tok-kw">try</span> ya.toManaged(limbs_buffer.allocator);</span>
<span class="line" id="L1345">        <span class="tok-kw">defer</span> y.deinit();</span>
<span class="line" id="L1346">        y.abs();</span>
<span class="line" id="L1347"></span>
<span class="line" id="L1348">        <span class="tok-kw">if</span> (x.toConst().order(y.toConst()) == .lt) {</span>
<span class="line" id="L1349">            x.swap(&amp;y);</span>
<span class="line" id="L1350">        }</span>
<span class="line" id="L1351"></span>
<span class="line" id="L1352">        <span class="tok-kw">var</span> t_big = <span class="tok-kw">try</span> Managed.init(limbs_buffer.allocator);</span>
<span class="line" id="L1353">        <span class="tok-kw">defer</span> t_big.deinit();</span>
<span class="line" id="L1354"></span>
<span class="line" id="L1355">        <span class="tok-kw">var</span> r = <span class="tok-kw">try</span> Managed.init(limbs_buffer.allocator);</span>
<span class="line" id="L1356">        <span class="tok-kw">defer</span> r.deinit();</span>
<span class="line" id="L1357"></span>
<span class="line" id="L1358">        <span class="tok-kw">var</span> tmp_x = <span class="tok-kw">try</span> Managed.init(limbs_buffer.allocator);</span>
<span class="line" id="L1359">        <span class="tok-kw">defer</span> tmp_x.deinit();</span>
<span class="line" id="L1360"></span>
<span class="line" id="L1361">        <span class="tok-kw">while</span> (y.len() &gt; <span class="tok-number">1</span> <span class="tok-kw">and</span> !y.eqZero()) {</span>
<span class="line" id="L1362">            assert(x.isPositive() <span class="tok-kw">and</span> y.isPositive());</span>
<span class="line" id="L1363">            assert(x.len() &gt;= y.len());</span>
<span class="line" id="L1364"></span>
<span class="line" id="L1365">            <span class="tok-kw">var</span> xh: SignedDoubleLimb = x.limbs[x.len() - <span class="tok-number">1</span>];</span>
<span class="line" id="L1366">            <span class="tok-kw">var</span> yh: SignedDoubleLimb = <span class="tok-kw">if</span> (x.len() &gt; y.len()) <span class="tok-number">0</span> <span class="tok-kw">else</span> y.limbs[x.len() - <span class="tok-number">1</span>];</span>
<span class="line" id="L1367"></span>
<span class="line" id="L1368">            <span class="tok-kw">var</span> A: SignedDoubleLimb = <span class="tok-number">1</span>;</span>
<span class="line" id="L1369">            <span class="tok-kw">var</span> B: SignedDoubleLimb = <span class="tok-number">0</span>;</span>
<span class="line" id="L1370">            <span class="tok-kw">var</span> C: SignedDoubleLimb = <span class="tok-number">0</span>;</span>
<span class="line" id="L1371">            <span class="tok-kw">var</span> D: SignedDoubleLimb = <span class="tok-number">1</span>;</span>
<span class="line" id="L1372"></span>
<span class="line" id="L1373">            <span class="tok-kw">while</span> (yh + C != <span class="tok-number">0</span> <span class="tok-kw">and</span> yh + D != <span class="tok-number">0</span>) {</span>
<span class="line" id="L1374">                <span class="tok-kw">const</span> q = <span class="tok-builtin">@divFloor</span>(xh + A, yh + C);</span>
<span class="line" id="L1375">                <span class="tok-kw">const</span> qp = <span class="tok-builtin">@divFloor</span>(xh + B, yh + D);</span>
<span class="line" id="L1376">                <span class="tok-kw">if</span> (q != qp) {</span>
<span class="line" id="L1377">                    <span class="tok-kw">break</span>;</span>
<span class="line" id="L1378">                }</span>
<span class="line" id="L1379"></span>
<span class="line" id="L1380">                <span class="tok-kw">var</span> t = A - q * C;</span>
<span class="line" id="L1381">                A = C;</span>
<span class="line" id="L1382">                C = t;</span>
<span class="line" id="L1383">                t = B - q * D;</span>
<span class="line" id="L1384">                B = D;</span>
<span class="line" id="L1385">                D = t;</span>
<span class="line" id="L1386"></span>
<span class="line" id="L1387">                t = xh - q * yh;</span>
<span class="line" id="L1388">                xh = yh;</span>
<span class="line" id="L1389">                yh = t;</span>
<span class="line" id="L1390">            }</span>
<span class="line" id="L1391"></span>
<span class="line" id="L1392">            <span class="tok-kw">if</span> (B == <span class="tok-number">0</span>) {</span>
<span class="line" id="L1393">                <span class="tok-comment">// t_big = x % y, r is unused</span>
</span>
<span class="line" id="L1394">                <span class="tok-kw">try</span> r.divTrunc(&amp;t_big, &amp;x, &amp;y);</span>
<span class="line" id="L1395">                assert(t_big.isPositive());</span>
<span class="line" id="L1396"></span>
<span class="line" id="L1397">                x.swap(&amp;y);</span>
<span class="line" id="L1398">                y.swap(&amp;t_big);</span>
<span class="line" id="L1399">            } <span class="tok-kw">else</span> {</span>
<span class="line" id="L1400">                <span class="tok-kw">var</span> storage: [<span class="tok-number">8</span>]Limb = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L1401">                <span class="tok-kw">const</span> Ap = fixedIntFromSignedDoubleLimb(A, storage[<span class="tok-number">0</span>..<span class="tok-number">2</span>]).toManaged(limbs_buffer.allocator);</span>
<span class="line" id="L1402">                <span class="tok-kw">const</span> Bp = fixedIntFromSignedDoubleLimb(B, storage[<span class="tok-number">2</span>..<span class="tok-number">4</span>]).toManaged(limbs_buffer.allocator);</span>
<span class="line" id="L1403">                <span class="tok-kw">const</span> Cp = fixedIntFromSignedDoubleLimb(C, storage[<span class="tok-number">4</span>..<span class="tok-number">6</span>]).toManaged(limbs_buffer.allocator);</span>
<span class="line" id="L1404">                <span class="tok-kw">const</span> Dp = fixedIntFromSignedDoubleLimb(D, storage[<span class="tok-number">6</span>..<span class="tok-number">8</span>]).toManaged(limbs_buffer.allocator);</span>
<span class="line" id="L1405"></span>
<span class="line" id="L1406">                <span class="tok-comment">// t_big = Ax + By</span>
</span>
<span class="line" id="L1407">                <span class="tok-kw">try</span> r.mul(&amp;x, &amp;Ap);</span>
<span class="line" id="L1408">                <span class="tok-kw">try</span> t_big.mul(&amp;y, &amp;Bp);</span>
<span class="line" id="L1409">                <span class="tok-kw">try</span> t_big.add(&amp;r, &amp;t_big);</span>
<span class="line" id="L1410"></span>
<span class="line" id="L1411">                <span class="tok-comment">// u = Cx + Dy, r as u</span>
</span>
<span class="line" id="L1412">                <span class="tok-kw">try</span> tmp_x.copy(x.toConst());</span>
<span class="line" id="L1413">                <span class="tok-kw">try</span> x.mul(&amp;tmp_x, &amp;Cp);</span>
<span class="line" id="L1414">                <span class="tok-kw">try</span> r.mul(&amp;y, &amp;Dp);</span>
<span class="line" id="L1415">                <span class="tok-kw">try</span> r.add(&amp;x, &amp;r);</span>
<span class="line" id="L1416"></span>
<span class="line" id="L1417">                x.swap(&amp;t_big);</span>
<span class="line" id="L1418">                y.swap(&amp;r);</span>
<span class="line" id="L1419">            }</span>
<span class="line" id="L1420">        }</span>
<span class="line" id="L1421"></span>
<span class="line" id="L1422">        <span class="tok-comment">// euclidean algorithm</span>
</span>
<span class="line" id="L1423">        assert(x.toConst().order(y.toConst()) != .lt);</span>
<span class="line" id="L1424"></span>
<span class="line" id="L1425">        <span class="tok-kw">while</span> (!y.toConst().eqZero()) {</span>
<span class="line" id="L1426">            <span class="tok-kw">try</span> t_big.divTrunc(&amp;r, &amp;x, &amp;y);</span>
<span class="line" id="L1427">            x.swap(&amp;y);</span>
<span class="line" id="L1428">            y.swap(&amp;r);</span>
<span class="line" id="L1429">        }</span>
<span class="line" id="L1430"></span>
<span class="line" id="L1431">        result.copy(x.toConst());</span>
<span class="line" id="L1432">    }</span>
<span class="line" id="L1433"></span>
<span class="line" id="L1434">    <span class="tok-comment">// Truncates by default.</span>
</span>
<span class="line" id="L1435">    <span class="tok-kw">fn</span> <span class="tok-fn">div</span>(q: *Mutable, r: *Mutable, x: *Mutable, y: *Mutable) <span class="tok-type">void</span> {</span>
<span class="line" id="L1436">        assert(!y.eqZero()); <span class="tok-comment">// division by zero</span>
</span>
<span class="line" id="L1437">        assert(q != r); <span class="tok-comment">// illegal aliasing</span>
</span>
<span class="line" id="L1438"></span>
<span class="line" id="L1439">        <span class="tok-kw">const</span> q_positive = (x.positive == y.positive);</span>
<span class="line" id="L1440">        <span class="tok-kw">const</span> r_positive = x.positive;</span>
<span class="line" id="L1441"></span>
<span class="line" id="L1442">        <span class="tok-kw">if</span> (x.toConst().orderAbs(y.toConst()) == .lt) {</span>
<span class="line" id="L1443">            <span class="tok-comment">// q may alias x so handle r first.</span>
</span>
<span class="line" id="L1444">            r.copy(x.toConst());</span>
<span class="line" id="L1445">            r.positive = r_positive;</span>
<span class="line" id="L1446"></span>
<span class="line" id="L1447">            q.set(<span class="tok-number">0</span>);</span>
<span class="line" id="L1448">            <span class="tok-kw">return</span>;</span>
<span class="line" id="L1449">        }</span>
<span class="line" id="L1450"></span>
<span class="line" id="L1451">        <span class="tok-comment">// Handle trailing zero-words of divisor/dividend. These are not handled in the following</span>
</span>
<span class="line" id="L1452">        <span class="tok-comment">// algorithms.</span>
</span>
<span class="line" id="L1453">        <span class="tok-comment">// Note, there must be a non-zero limb for either.</span>
</span>
<span class="line" id="L1454">        <span class="tok-comment">// const x_trailing = std.mem.indexOfScalar(Limb, x.limbs[0..x.len], 0).?;</span>
</span>
<span class="line" id="L1455">        <span class="tok-comment">// const y_trailing = std.mem.indexOfScalar(Limb, y.limbs[0..y.len], 0).?;</span>
</span>
<span class="line" id="L1456"></span>
<span class="line" id="L1457">        <span class="tok-kw">const</span> x_trailing = <span class="tok-kw">for</span> (x.limbs[<span class="tok-number">0</span>..x.len]) |xi, i| {</span>
<span class="line" id="L1458">            <span class="tok-kw">if</span> (xi != <span class="tok-number">0</span>) <span class="tok-kw">break</span> i;</span>
<span class="line" id="L1459">        } <span class="tok-kw">else</span> <span class="tok-kw">unreachable</span>;</span>
<span class="line" id="L1460"></span>
<span class="line" id="L1461">        <span class="tok-kw">const</span> y_trailing = <span class="tok-kw">for</span> (y.limbs[<span class="tok-number">0</span>..y.len]) |yi, i| {</span>
<span class="line" id="L1462">            <span class="tok-kw">if</span> (yi != <span class="tok-number">0</span>) <span class="tok-kw">break</span> i;</span>
<span class="line" id="L1463">        } <span class="tok-kw">else</span> <span class="tok-kw">unreachable</span>;</span>
<span class="line" id="L1464"></span>
<span class="line" id="L1465">        <span class="tok-kw">const</span> xy_trailing = math.min(x_trailing, y_trailing);</span>
<span class="line" id="L1466"></span>
<span class="line" id="L1467">        <span class="tok-kw">if</span> (y.len - xy_trailing == <span class="tok-number">1</span>) {</span>
<span class="line" id="L1468">            <span class="tok-kw">const</span> divisor = y.limbs[y.len - <span class="tok-number">1</span>];</span>
<span class="line" id="L1469"></span>
<span class="line" id="L1470">            <span class="tok-comment">// Optimization for small divisor. By using a half limb we can avoid requiring DoubleLimb</span>
</span>
<span class="line" id="L1471">            <span class="tok-comment">// divisions in the hot code path. This may often require compiler_rt software-emulation.</span>
</span>
<span class="line" id="L1472">            <span class="tok-kw">if</span> (divisor &lt; maxInt(HalfLimb)) {</span>
<span class="line" id="L1473">                lldiv0p5(q.limbs, &amp;r.limbs[<span class="tok-number">0</span>], x.limbs[xy_trailing..x.len], <span class="tok-builtin">@intCast</span>(HalfLimb, divisor));</span>
<span class="line" id="L1474">            } <span class="tok-kw">else</span> {</span>
<span class="line" id="L1475">                lldiv1(q.limbs, &amp;r.limbs[<span class="tok-number">0</span>], x.limbs[xy_trailing..x.len], divisor);</span>
<span class="line" id="L1476">            }</span>
<span class="line" id="L1477"></span>
<span class="line" id="L1478">            q.normalize(x.len - xy_trailing);</span>
<span class="line" id="L1479">            q.positive = q_positive;</span>
<span class="line" id="L1480"></span>
<span class="line" id="L1481">            r.len = <span class="tok-number">1</span>;</span>
<span class="line" id="L1482">            r.positive = r_positive;</span>
<span class="line" id="L1483">        } <span class="tok-kw">else</span> {</span>
<span class="line" id="L1484">            <span class="tok-comment">// Shrink x, y such that the trailing zero limbs shared between are removed.</span>
</span>
<span class="line" id="L1485">            <span class="tok-kw">var</span> x0 = Mutable{</span>
<span class="line" id="L1486">                .limbs = x.limbs[xy_trailing..],</span>
<span class="line" id="L1487">                .len = x.len - xy_trailing,</span>
<span class="line" id="L1488">                .positive = <span class="tok-null">true</span>,</span>
<span class="line" id="L1489">            };</span>
<span class="line" id="L1490"></span>
<span class="line" id="L1491">            <span class="tok-kw">var</span> y0 = Mutable{</span>
<span class="line" id="L1492">                .limbs = y.limbs[xy_trailing..],</span>
<span class="line" id="L1493">                .len = y.len - xy_trailing,</span>
<span class="line" id="L1494">                .positive = <span class="tok-null">true</span>,</span>
<span class="line" id="L1495">            };</span>
<span class="line" id="L1496"></span>
<span class="line" id="L1497">            divmod(q, r, &amp;x0, &amp;y0);</span>
<span class="line" id="L1498">            q.positive = q_positive;</span>
<span class="line" id="L1499"></span>
<span class="line" id="L1500">            r.positive = r_positive;</span>
<span class="line" id="L1501">        }</span>
<span class="line" id="L1502"></span>
<span class="line" id="L1503">        <span class="tok-kw">if</span> (xy_trailing != <span class="tok-number">0</span>) {</span>
<span class="line" id="L1504">            <span class="tok-comment">// Manually shift here since we know its limb aligned.</span>
</span>
<span class="line" id="L1505">            mem.copyBackwards(Limb, r.limbs[xy_trailing..], r.limbs[<span class="tok-number">0</span>..r.len]);</span>
<span class="line" id="L1506">            mem.set(Limb, r.limbs[<span class="tok-number">0</span>..xy_trailing], <span class="tok-number">0</span>);</span>
<span class="line" id="L1507">            r.len += xy_trailing;</span>
<span class="line" id="L1508">        }</span>
<span class="line" id="L1509">    }</span>
<span class="line" id="L1510"></span>
<span class="line" id="L1511">    <span class="tok-comment">/// Handbook of Applied Cryptography, 14.20</span></span>
<span class="line" id="L1512">    <span class="tok-comment">///</span></span>
<span class="line" id="L1513">    <span class="tok-comment">/// x = qy + r where 0 &lt;= r &lt; y</span></span>
<span class="line" id="L1514">    <span class="tok-comment">/// y is modified but returned intact.</span></span>
<span class="line" id="L1515">    <span class="tok-kw">fn</span> <span class="tok-fn">divmod</span>(</span>
<span class="line" id="L1516">        q: *Mutable,</span>
<span class="line" id="L1517">        r: *Mutable,</span>
<span class="line" id="L1518">        x: *Mutable,</span>
<span class="line" id="L1519">        y: *Mutable,</span>
<span class="line" id="L1520">    ) <span class="tok-type">void</span> {</span>
<span class="line" id="L1521">        <span class="tok-comment">// 0.</span>
</span>
<span class="line" id="L1522">        <span class="tok-comment">// Normalize so that y[t] &gt; b/2</span>
</span>
<span class="line" id="L1523">        <span class="tok-kw">const</span> lz = <span class="tok-builtin">@clz</span>(Limb, y.limbs[y.len - <span class="tok-number">1</span>]);</span>
<span class="line" id="L1524">        <span class="tok-kw">const</span> norm_shift = <span class="tok-kw">if</span> (lz == <span class="tok-number">0</span> <span class="tok-kw">and</span> y.toConst().isOdd())</span>
<span class="line" id="L1525">            limb_bits <span class="tok-comment">// Force an extra limb so that y is even.</span>
</span>
<span class="line" id="L1526">        <span class="tok-kw">else</span></span>
<span class="line" id="L1527">            lz;</span>
<span class="line" id="L1528"></span>
<span class="line" id="L1529">        x.shiftLeft(x.toConst(), norm_shift);</span>
<span class="line" id="L1530">        y.shiftLeft(y.toConst(), norm_shift);</span>
<span class="line" id="L1531"></span>
<span class="line" id="L1532">        <span class="tok-kw">const</span> n = x.len - <span class="tok-number">1</span>;</span>
<span class="line" id="L1533">        <span class="tok-kw">const</span> t = y.len - <span class="tok-number">1</span>;</span>
<span class="line" id="L1534">        <span class="tok-kw">const</span> shift = n - t;</span>
<span class="line" id="L1535"></span>
<span class="line" id="L1536">        <span class="tok-comment">// 1.</span>
</span>
<span class="line" id="L1537">        <span class="tok-comment">// for 0 &lt;= j &lt;= n - t, set q[j] to 0</span>
</span>
<span class="line" id="L1538">        q.len = shift + <span class="tok-number">1</span>;</span>
<span class="line" id="L1539">        q.positive = <span class="tok-null">true</span>;</span>
<span class="line" id="L1540">        mem.set(Limb, q.limbs[<span class="tok-number">0</span>..q.len], <span class="tok-number">0</span>);</span>
<span class="line" id="L1541"></span>
<span class="line" id="L1542">        <span class="tok-comment">// 2.</span>
</span>
<span class="line" id="L1543">        <span class="tok-comment">// while x &gt;= y * b^(n - t):</span>
</span>
<span class="line" id="L1544">        <span class="tok-comment">//    x -= y * b^(n - t)</span>
</span>
<span class="line" id="L1545">        <span class="tok-comment">//    q[n - t] += 1</span>
</span>
<span class="line" id="L1546">        <span class="tok-comment">// Note, this algorithm is performed only once if y[t] &gt; radix/2 and y is even, which we</span>
</span>
<span class="line" id="L1547">        <span class="tok-comment">// enforced in step 0. This means we can replace the while with an if.</span>
</span>
<span class="line" id="L1548">        <span class="tok-comment">// Note, multiplication by b^(n - t) comes down to shifting to the right by n - t limbs.</span>
</span>
<span class="line" id="L1549">        <span class="tok-comment">// We can also replace x &gt;= y * b^(n - t) by x/b^(n - t) &gt;= y, and use shifts for that.</span>
</span>
<span class="line" id="L1550">        {</span>
<span class="line" id="L1551">            <span class="tok-comment">// x &gt;= y * b^(n - t) can be replaced by x/b^(n - t) &gt;= y.</span>
</span>
<span class="line" id="L1552"></span>
<span class="line" id="L1553">            <span class="tok-comment">// 'divide' x by b^(n - t)</span>
</span>
<span class="line" id="L1554">            <span class="tok-kw">var</span> tmp = Mutable{</span>
<span class="line" id="L1555">                .limbs = x.limbs[shift..],</span>
<span class="line" id="L1556">                .len = x.len - shift,</span>
<span class="line" id="L1557">                .positive = <span class="tok-null">true</span>,</span>
<span class="line" id="L1558">            };</span>
<span class="line" id="L1559"></span>
<span class="line" id="L1560">            <span class="tok-kw">if</span> (tmp.toConst().order(y.toConst()) != .lt) {</span>
<span class="line" id="L1561">                <span class="tok-comment">// Perform x -= y * b^(n - t)</span>
</span>
<span class="line" id="L1562">                <span class="tok-comment">// Note, we can subtract y from x[n - t..] and get the result without shifting.</span>
</span>
<span class="line" id="L1563">                <span class="tok-comment">// We can also re-use tmp which already contains the relevant part of x. Note that</span>
</span>
<span class="line" id="L1564">                <span class="tok-comment">// this also edits x.</span>
</span>
<span class="line" id="L1565">                <span class="tok-comment">// Due to the check above, this cannot underflow.</span>
</span>
<span class="line" id="L1566">                tmp.sub(tmp.toConst(), y.toConst());</span>
<span class="line" id="L1567"></span>
<span class="line" id="L1568">                <span class="tok-comment">// tmp.sub normalized tmp, but we need to normalize x now.</span>
</span>
<span class="line" id="L1569">                x.limbs.len = tmp.limbs.len + shift;</span>
<span class="line" id="L1570"></span>
<span class="line" id="L1571">                q.limbs[shift] += <span class="tok-number">1</span>;</span>
<span class="line" id="L1572">            }</span>
<span class="line" id="L1573">        }</span>
<span class="line" id="L1574"></span>
<span class="line" id="L1575">        <span class="tok-comment">// 3.</span>
</span>
<span class="line" id="L1576">        <span class="tok-comment">// for i from n down to t + 1, do</span>
</span>
<span class="line" id="L1577">        <span class="tok-kw">var</span> i = n;</span>
<span class="line" id="L1578">        <span class="tok-kw">while</span> (i &gt;= t + <span class="tok-number">1</span>) : (i -= <span class="tok-number">1</span>) {</span>
<span class="line" id="L1579">            <span class="tok-kw">const</span> k = i - t - <span class="tok-number">1</span>;</span>
<span class="line" id="L1580">            <span class="tok-comment">// 3.1.</span>
</span>
<span class="line" id="L1581">            <span class="tok-comment">// if x_i == y_t:</span>
</span>
<span class="line" id="L1582">            <span class="tok-comment">//   q[i - t - 1] = b - 1</span>
</span>
<span class="line" id="L1583">            <span class="tok-comment">// else:</span>
</span>
<span class="line" id="L1584">            <span class="tok-comment">//   q[i - t - 1] = (x[i] * b + x[i - 1]) / y[t]</span>
</span>
<span class="line" id="L1585">            <span class="tok-kw">if</span> (x.limbs[i] == y.limbs[t]) {</span>
<span class="line" id="L1586">                q.limbs[k] = maxInt(Limb);</span>
<span class="line" id="L1587">            } <span class="tok-kw">else</span> {</span>
<span class="line" id="L1588">                <span class="tok-kw">const</span> q0 = (<span class="tok-builtin">@as</span>(DoubleLimb, x.limbs[i]) &lt;&lt; limb_bits) | <span class="tok-builtin">@as</span>(DoubleLimb, x.limbs[i - <span class="tok-number">1</span>]);</span>
<span class="line" id="L1589">                <span class="tok-kw">const</span> n0 = <span class="tok-builtin">@as</span>(DoubleLimb, y.limbs[t]);</span>
<span class="line" id="L1590">                q.limbs[k] = <span class="tok-builtin">@intCast</span>(Limb, q0 / n0);</span>
<span class="line" id="L1591">            }</span>
<span class="line" id="L1592"></span>
<span class="line" id="L1593">            <span class="tok-comment">// 3.2</span>
</span>
<span class="line" id="L1594">            <span class="tok-comment">// while q[i - t - 1] * (y[t] * b + y[t - 1] &gt; x[i] * b * b + x[i - 1] + x[i - 2]:</span>
</span>
<span class="line" id="L1595">            <span class="tok-comment">//   q[i - t - 1] -= 1</span>
</span>
<span class="line" id="L1596">            <span class="tok-comment">// Note, if y[t] &gt; b / 2 this part is repeated no more than twice.</span>
</span>
<span class="line" id="L1597"></span>
<span class="line" id="L1598">            <span class="tok-comment">// Extract from y.</span>
</span>
<span class="line" id="L1599">            <span class="tok-kw">const</span> y0 = <span class="tok-kw">if</span> (t &gt; <span class="tok-number">0</span>) y.limbs[t - <span class="tok-number">1</span>] <span class="tok-kw">else</span> <span class="tok-number">0</span>;</span>
<span class="line" id="L1600">            <span class="tok-kw">const</span> y1 = y.limbs[t];</span>
<span class="line" id="L1601"></span>
<span class="line" id="L1602">            <span class="tok-comment">// Extract from x.</span>
</span>
<span class="line" id="L1603">            <span class="tok-comment">// Note, big endian.</span>
</span>
<span class="line" id="L1604">            <span class="tok-kw">const</span> tmp0 = [_]Limb{</span>
<span class="line" id="L1605">                x.limbs[i],</span>
<span class="line" id="L1606">                <span class="tok-kw">if</span> (i &gt;= <span class="tok-number">1</span>) x.limbs[i - <span class="tok-number">1</span>] <span class="tok-kw">else</span> <span class="tok-number">0</span>,</span>
<span class="line" id="L1607">                <span class="tok-kw">if</span> (i &gt;= <span class="tok-number">2</span>) x.limbs[i - <span class="tok-number">2</span>] <span class="tok-kw">else</span> <span class="tok-number">0</span>,</span>
<span class="line" id="L1608">            };</span>
<span class="line" id="L1609"></span>
<span class="line" id="L1610">            <span class="tok-kw">while</span> (<span class="tok-null">true</span>) {</span>
<span class="line" id="L1611">                <span class="tok-comment">// Ad-hoc 2x1 multiplication with q[i - t - 1].</span>
</span>
<span class="line" id="L1612">                <span class="tok-comment">// Note, big endian.</span>
</span>
<span class="line" id="L1613">                <span class="tok-kw">var</span> tmp1 = [_]Limb{ <span class="tok-number">0</span>, <span class="tok-null">undefined</span>, <span class="tok-null">undefined</span> };</span>
<span class="line" id="L1614">                tmp1[<span class="tok-number">2</span>] = addMulLimbWithCarry(<span class="tok-number">0</span>, y0, q.limbs[k], &amp;tmp1[<span class="tok-number">0</span>]);</span>
<span class="line" id="L1615">                tmp1[<span class="tok-number">1</span>] = addMulLimbWithCarry(<span class="tok-number">0</span>, y1, q.limbs[k], &amp;tmp1[<span class="tok-number">0</span>]);</span>
<span class="line" id="L1616"></span>
<span class="line" id="L1617">                <span class="tok-comment">// Big-endian compare</span>
</span>
<span class="line" id="L1618">                <span class="tok-kw">if</span> (mem.order(Limb, &amp;tmp1, &amp;tmp0) != .gt)</span>
<span class="line" id="L1619">                    <span class="tok-kw">break</span>;</span>
<span class="line" id="L1620"></span>
<span class="line" id="L1621">                q.limbs[k] -= <span class="tok-number">1</span>;</span>
<span class="line" id="L1622">            }</span>
<span class="line" id="L1623"></span>
<span class="line" id="L1624">            <span class="tok-comment">// 3.3.</span>
</span>
<span class="line" id="L1625">            <span class="tok-comment">// x -= q[i - t - 1] * y * b^(i - t - 1)</span>
</span>
<span class="line" id="L1626">            <span class="tok-comment">// Note, we multiply by a single limb here.</span>
</span>
<span class="line" id="L1627">            <span class="tok-comment">// The shift doesn't need to be performed if we add the result of the first multiplication</span>
</span>
<span class="line" id="L1628">            <span class="tok-comment">// to x[i - t - 1].</span>
</span>
<span class="line" id="L1629">            <span class="tok-kw">const</span> underflow = llmulLimb(.sub, x.limbs[k..x.len], y.limbs[<span class="tok-number">0</span>..y.len], q.limbs[k]);</span>
<span class="line" id="L1630"></span>
<span class="line" id="L1631">            <span class="tok-comment">// 3.4.</span>
</span>
<span class="line" id="L1632">            <span class="tok-comment">// if x &lt; 0:</span>
</span>
<span class="line" id="L1633">            <span class="tok-comment">//   x += y * b^(i - t - 1)</span>
</span>
<span class="line" id="L1634">            <span class="tok-comment">//   q[i - t - 1] -= 1</span>
</span>
<span class="line" id="L1635">            <span class="tok-comment">// Note, we check for x &lt; 0 using the underflow flag from the previous operation.</span>
</span>
<span class="line" id="L1636">            <span class="tok-kw">if</span> (underflow) {</span>
<span class="line" id="L1637">                <span class="tok-comment">// While we didn't properly set the signedness of x, this operation should 'flow' it back to positive.</span>
</span>
<span class="line" id="L1638">                llaccum(.add, x.limbs[k..x.len], y.limbs[<span class="tok-number">0</span>..y.len]);</span>
<span class="line" id="L1639">                q.limbs[k] -= <span class="tok-number">1</span>;</span>
<span class="line" id="L1640">            }</span>
<span class="line" id="L1641">        }</span>
<span class="line" id="L1642"></span>
<span class="line" id="L1643">        x.normalize(x.len);</span>
<span class="line" id="L1644">        q.normalize(q.len);</span>
<span class="line" id="L1645"></span>
<span class="line" id="L1646">        <span class="tok-comment">// De-normalize r and y.</span>
</span>
<span class="line" id="L1647">        r.shiftRight(x.toConst(), norm_shift);</span>
<span class="line" id="L1648">        y.shiftRight(y.toConst(), norm_shift);</span>
<span class="line" id="L1649">    }</span>
<span class="line" id="L1650"></span>
<span class="line" id="L1651">    <span class="tok-comment">/// Truncate an integer to a number of bits, following 2s-complement semantics.</span></span>
<span class="line" id="L1652">    <span class="tok-comment">/// r may alias a.</span></span>
<span class="line" id="L1653">    <span class="tok-comment">///</span></span>
<span class="line" id="L1654">    <span class="tok-comment">/// Asserts `r` has enough storage to store the result.</span></span>
<span class="line" id="L1655">    <span class="tok-comment">/// The upper bound is `calcTwosCompLimbCount(a.len)`.</span></span>
<span class="line" id="L1656">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">truncate</span>(r: *Mutable, a: Const, signedness: Signedness, bit_count: <span class="tok-type">usize</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L1657">        <span class="tok-kw">const</span> req_limbs = calcTwosCompLimbCount(bit_count);</span>
<span class="line" id="L1658"></span>
<span class="line" id="L1659">        <span class="tok-comment">// Handle 0-bit integers.</span>
</span>
<span class="line" id="L1660">        <span class="tok-kw">if</span> (req_limbs == <span class="tok-number">0</span> <span class="tok-kw">or</span> a.eqZero()) {</span>
<span class="line" id="L1661">            r.set(<span class="tok-number">0</span>);</span>
<span class="line" id="L1662">            <span class="tok-kw">return</span>;</span>
<span class="line" id="L1663">        }</span>
<span class="line" id="L1664"></span>
<span class="line" id="L1665">        <span class="tok-kw">const</span> bit = <span class="tok-builtin">@truncate</span>(Log2Limb, bit_count - <span class="tok-number">1</span>);</span>
<span class="line" id="L1666">        <span class="tok-kw">const</span> signmask = <span class="tok-builtin">@as</span>(Limb, <span class="tok-number">1</span>) &lt;&lt; bit; <span class="tok-comment">// 0b0..010...0 where 1 is the sign bit.</span>
</span>
<span class="line" id="L1667">        <span class="tok-kw">const</span> mask = (signmask &lt;&lt; <span class="tok-number">1</span>) -% <span class="tok-number">1</span>; <span class="tok-comment">// 0b0..01..1 where the leftmost 1 is the sign bit.</span>
</span>
<span class="line" id="L1668"></span>
<span class="line" id="L1669">        <span class="tok-kw">if</span> (!a.positive) {</span>
<span class="line" id="L1670">            <span class="tok-comment">// Convert the integer from sign-magnitude into twos-complement.</span>
</span>
<span class="line" id="L1671">            <span class="tok-comment">// -x = ~(x - 1)</span>
</span>
<span class="line" id="L1672">            <span class="tok-comment">// Note, we simply take req_limbs * @bitSizeOf(Limb) as the</span>
</span>
<span class="line" id="L1673">            <span class="tok-comment">// target bit count.</span>
</span>
<span class="line" id="L1674"></span>
<span class="line" id="L1675">            r.addScalar(a.abs(), -<span class="tok-number">1</span>);</span>
<span class="line" id="L1676"></span>
<span class="line" id="L1677">            <span class="tok-comment">// Zero-extend the result</span>
</span>
<span class="line" id="L1678">            <span class="tok-kw">if</span> (req_limbs &gt; r.len) {</span>
<span class="line" id="L1679">                mem.set(Limb, r.limbs[r.len..req_limbs], <span class="tok-number">0</span>);</span>
<span class="line" id="L1680">            }</span>
<span class="line" id="L1681"></span>
<span class="line" id="L1682">            <span class="tok-comment">// Truncate to required number of limbs.</span>
</span>
<span class="line" id="L1683">            assert(r.limbs.len &gt;= req_limbs);</span>
<span class="line" id="L1684">            r.len = req_limbs;</span>
<span class="line" id="L1685"></span>
<span class="line" id="L1686">            <span class="tok-comment">// Without truncating, we can already peek at the sign bit of the result here.</span>
</span>
<span class="line" id="L1687">            <span class="tok-comment">// Note that it will be 0 if the result is negative, as we did not apply the flip here.</span>
</span>
<span class="line" id="L1688">            <span class="tok-comment">// If the result is negative, we have</span>
</span>
<span class="line" id="L1689">            <span class="tok-comment">// -(-x &amp; mask)</span>
</span>
<span class="line" id="L1690">            <span class="tok-comment">// = ~(~(x - 1) &amp; mask) + 1</span>
</span>
<span class="line" id="L1691">            <span class="tok-comment">// = ~(~((x - 1) | ~mask)) + 1</span>
</span>
<span class="line" id="L1692">            <span class="tok-comment">// = ((x - 1) | ~mask)) + 1</span>
</span>
<span class="line" id="L1693">            <span class="tok-comment">// Note, this is only valid for the target bits and not the upper bits</span>
</span>
<span class="line" id="L1694">            <span class="tok-comment">// of the most significant limb. Those still need to be cleared.</span>
</span>
<span class="line" id="L1695">            <span class="tok-comment">// Also note that `mask` is zero for all other bits, reducing to the identity.</span>
</span>
<span class="line" id="L1696">            <span class="tok-comment">// This means that we still need to use &amp; mask to clear off the upper bits.</span>
</span>
<span class="line" id="L1697"></span>
<span class="line" id="L1698">            <span class="tok-kw">if</span> (signedness == .signed <span class="tok-kw">and</span> r.limbs[r.len - <span class="tok-number">1</span>] &amp; signmask == <span class="tok-number">0</span>) {</span>
<span class="line" id="L1699">                <span class="tok-comment">// Re-add the one and negate to get the result.</span>
</span>
<span class="line" id="L1700">                r.limbs[r.len - <span class="tok-number">1</span>] &amp;= mask;</span>
<span class="line" id="L1701">                <span class="tok-comment">// Note, addition cannot require extra limbs here as we did a subtraction before.</span>
</span>
<span class="line" id="L1702">                r.addScalar(r.toConst(), <span class="tok-number">1</span>);</span>
<span class="line" id="L1703">                r.normalize(r.len);</span>
<span class="line" id="L1704">                r.positive = <span class="tok-null">false</span>;</span>
<span class="line" id="L1705">            } <span class="tok-kw">else</span> {</span>
<span class="line" id="L1706">                llnot(r.limbs[<span class="tok-number">0</span>..r.len]);</span>
<span class="line" id="L1707">                r.limbs[r.len - <span class="tok-number">1</span>] &amp;= mask;</span>
<span class="line" id="L1708">                r.normalize(r.len);</span>
<span class="line" id="L1709">            }</span>
<span class="line" id="L1710">        } <span class="tok-kw">else</span> {</span>
<span class="line" id="L1711">            <span class="tok-kw">if</span> (a.limbs.len &lt; req_limbs) {</span>
<span class="line" id="L1712">                <span class="tok-comment">// Integer fits within target bits, no wrapping required.</span>
</span>
<span class="line" id="L1713">                r.copy(a);</span>
<span class="line" id="L1714">                <span class="tok-kw">return</span>;</span>
<span class="line" id="L1715">            }</span>
<span class="line" id="L1716"></span>
<span class="line" id="L1717">            r.copy(.{</span>
<span class="line" id="L1718">                .positive = a.positive,</span>
<span class="line" id="L1719">                .limbs = a.limbs[<span class="tok-number">0</span>..req_limbs],</span>
<span class="line" id="L1720">            });</span>
<span class="line" id="L1721">            r.limbs[r.len - <span class="tok-number">1</span>] &amp;= mask;</span>
<span class="line" id="L1722">            r.normalize(r.len);</span>
<span class="line" id="L1723"></span>
<span class="line" id="L1724">            <span class="tok-kw">if</span> (signedness == .signed <span class="tok-kw">and</span> r.limbs[r.len - <span class="tok-number">1</span>] &amp; signmask != <span class="tok-number">0</span>) {</span>
<span class="line" id="L1725">                <span class="tok-comment">// Convert 2s-complement back to sign-magnitude.</span>
</span>
<span class="line" id="L1726">                <span class="tok-comment">// Sign-extend the upper bits so that they are inverted correctly.</span>
</span>
<span class="line" id="L1727">                r.limbs[r.len - <span class="tok-number">1</span>] |= ~mask;</span>
<span class="line" id="L1728">                llnot(r.limbs[<span class="tok-number">0</span>..r.len]);</span>
<span class="line" id="L1729"></span>
<span class="line" id="L1730">                <span class="tok-comment">// Note, can only overflow if r holds 0xFFF...F which can only happen if</span>
</span>
<span class="line" id="L1731">                <span class="tok-comment">// a holds 0.</span>
</span>
<span class="line" id="L1732">                r.addScalar(r.toConst(), <span class="tok-number">1</span>);</span>
<span class="line" id="L1733"></span>
<span class="line" id="L1734">                r.positive = <span class="tok-null">false</span>;</span>
<span class="line" id="L1735">            }</span>
<span class="line" id="L1736">        }</span>
<span class="line" id="L1737">    }</span>
<span class="line" id="L1738"></span>
<span class="line" id="L1739">    <span class="tok-comment">/// Saturate an integer to a number of bits, following 2s-complement semantics.</span></span>
<span class="line" id="L1740">    <span class="tok-comment">/// r may alias a.</span></span>
<span class="line" id="L1741">    <span class="tok-comment">///</span></span>
<span class="line" id="L1742">    <span class="tok-comment">/// Asserts `r` has enough storage to store the result.</span></span>
<span class="line" id="L1743">    <span class="tok-comment">/// The upper bound is `calcTwosCompLimbCount(a.len)`.</span></span>
<span class="line" id="L1744">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">saturate</span>(r: *Mutable, a: Const, signedness: Signedness, bit_count: <span class="tok-type">usize</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L1745">        <span class="tok-kw">if</span> (!a.fitsInTwosComp(signedness, bit_count)) {</span>
<span class="line" id="L1746">            r.setTwosCompIntLimit(<span class="tok-kw">if</span> (r.positive) .max <span class="tok-kw">else</span> .min, signedness, bit_count);</span>
<span class="line" id="L1747">        }</span>
<span class="line" id="L1748">    }</span>
<span class="line" id="L1749"></span>
<span class="line" id="L1750">    <span class="tok-comment">/// Read the value of `x` from `buffer`</span></span>
<span class="line" id="L1751">    <span class="tok-comment">/// Asserts that `buffer`, `abi_size`, and `bit_count` are large enough to store the value.</span></span>
<span class="line" id="L1752">    <span class="tok-comment">///</span></span>
<span class="line" id="L1753">    <span class="tok-comment">/// The contents of `buffer` are interpreted as if they were the contents of</span></span>
<span class="line" id="L1754">    <span class="tok-comment">/// @ptrCast(*[abi_size]const u8, &amp;x). Byte ordering is determined by `endian`</span></span>
<span class="line" id="L1755">    <span class="tok-comment">/// and any required padding bits are expected on the MSB end.</span></span>
<span class="line" id="L1756">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">readTwosComplement</span>(</span>
<span class="line" id="L1757">        x: *Mutable,</span>
<span class="line" id="L1758">        buffer: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L1759">        bit_count: <span class="tok-type">usize</span>,</span>
<span class="line" id="L1760">        abi_size: <span class="tok-type">usize</span>,</span>
<span class="line" id="L1761">        endian: Endian,</span>
<span class="line" id="L1762">        signedness: Signedness,</span>
<span class="line" id="L1763">    ) <span class="tok-type">void</span> {</span>
<span class="line" id="L1764">        <span class="tok-kw">if</span> (bit_count == <span class="tok-number">0</span>) {</span>
<span class="line" id="L1765">            x.limbs[<span class="tok-number">0</span>] = <span class="tok-number">0</span>;</span>
<span class="line" id="L1766">            x.len = <span class="tok-number">1</span>;</span>
<span class="line" id="L1767">            x.positive = <span class="tok-null">true</span>;</span>
<span class="line" id="L1768">            <span class="tok-kw">return</span>;</span>
<span class="line" id="L1769">        }</span>
<span class="line" id="L1770"></span>
<span class="line" id="L1771">        <span class="tok-comment">// byte_count is our total read size: it cannot exceed abi_size,</span>
</span>
<span class="line" id="L1772">        <span class="tok-comment">// but may be less as long as it includes the required bits</span>
</span>
<span class="line" id="L1773">        <span class="tok-kw">const</span> limb_count = calcTwosCompLimbCount(bit_count);</span>
<span class="line" id="L1774">        <span class="tok-kw">const</span> byte_count = std.math.min(abi_size, <span class="tok-builtin">@sizeOf</span>(Limb) * limb_count);</span>
<span class="line" id="L1775">        assert(<span class="tok-number">8</span> * byte_count &gt;= bit_count);</span>
<span class="line" id="L1776"></span>
<span class="line" id="L1777">        <span class="tok-comment">// Check whether the input is negative</span>
</span>
<span class="line" id="L1778">        <span class="tok-kw">var</span> positive = <span class="tok-null">true</span>;</span>
<span class="line" id="L1779">        <span class="tok-kw">if</span> (signedness == .signed) {</span>
<span class="line" id="L1780">            <span class="tok-kw">var</span> last_byte = <span class="tok-kw">switch</span> (endian) {</span>
<span class="line" id="L1781">                .Little =&gt; ((bit_count + <span class="tok-number">7</span>) / <span class="tok-number">8</span>) - <span class="tok-number">1</span>,</span>
<span class="line" id="L1782">                .Big =&gt; abi_size - ((bit_count + <span class="tok-number">7</span>) / <span class="tok-number">8</span>),</span>
<span class="line" id="L1783">            };</span>
<span class="line" id="L1784"></span>
<span class="line" id="L1785">            <span class="tok-kw">const</span> sign_bit = <span class="tok-builtin">@as</span>(<span class="tok-type">u8</span>, <span class="tok-number">1</span>) &lt;&lt; <span class="tok-builtin">@intCast</span>(<span class="tok-type">u3</span>, (bit_count - <span class="tok-number">1</span>) % <span class="tok-number">8</span>);</span>
<span class="line" id="L1786">            positive = ((buffer[last_byte] &amp; sign_bit) == <span class="tok-number">0</span>);</span>
<span class="line" id="L1787">        }</span>
<span class="line" id="L1788"></span>
<span class="line" id="L1789">        <span class="tok-comment">// Copy all complete limbs</span>
</span>
<span class="line" id="L1790">        <span class="tok-kw">var</span> carry: <span class="tok-type">u1</span> = <span class="tok-kw">if</span> (positive) <span class="tok-number">0</span> <span class="tok-kw">else</span> <span class="tok-number">1</span>;</span>
<span class="line" id="L1791">        <span class="tok-kw">var</span> limb_index: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L1792">        <span class="tok-kw">while</span> (limb_index &lt; bit_count / <span class="tok-builtin">@bitSizeOf</span>(Limb)) : (limb_index += <span class="tok-number">1</span>) {</span>
<span class="line" id="L1793">            <span class="tok-kw">var</span> buf_index = <span class="tok-kw">switch</span> (endian) {</span>
<span class="line" id="L1794">                .Little =&gt; <span class="tok-builtin">@sizeOf</span>(Limb) * limb_index,</span>
<span class="line" id="L1795">                .Big =&gt; abi_size - (limb_index + <span class="tok-number">1</span>) * <span class="tok-builtin">@sizeOf</span>(Limb),</span>
<span class="line" id="L1796">            };</span>
<span class="line" id="L1797"></span>
<span class="line" id="L1798">            <span class="tok-kw">const</span> limb_buf = <span class="tok-builtin">@ptrCast</span>(*<span class="tok-kw">const</span> [<span class="tok-builtin">@sizeOf</span>(Limb)]<span class="tok-type">u8</span>, buffer[buf_index..]);</span>
<span class="line" id="L1799">            <span class="tok-kw">var</span> limb = mem.readInt(Limb, limb_buf, endian);</span>
<span class="line" id="L1800"></span>
<span class="line" id="L1801">            <span class="tok-comment">// 2's complement (bitwise not, then add carry bit)</span>
</span>
<span class="line" id="L1802">            <span class="tok-kw">if</span> (!positive) carry = <span class="tok-builtin">@boolToInt</span>(<span class="tok-builtin">@addWithOverflow</span>(Limb, ~limb, carry, &amp;limb));</span>
<span class="line" id="L1803">            x.limbs[limb_index] = limb;</span>
<span class="line" id="L1804">        }</span>
<span class="line" id="L1805"></span>
<span class="line" id="L1806">        <span class="tok-comment">// Copy the remaining N bytes (N &lt;= @sizeOf(Limb))</span>
</span>
<span class="line" id="L1807">        <span class="tok-kw">var</span> bytes_read = limb_index * <span class="tok-builtin">@sizeOf</span>(Limb);</span>
<span class="line" id="L1808">        <span class="tok-kw">if</span> (bytes_read != byte_count) {</span>
<span class="line" id="L1809">            <span class="tok-kw">var</span> limb: Limb = <span class="tok-number">0</span>;</span>
<span class="line" id="L1810"></span>
<span class="line" id="L1811">            <span class="tok-kw">while</span> (bytes_read != byte_count) {</span>
<span class="line" id="L1812">                <span class="tok-kw">const</span> read_size = std.math.floorPowerOfTwo(<span class="tok-type">usize</span>, byte_count - bytes_read);</span>
<span class="line" id="L1813">                <span class="tok-kw">var</span> int_buffer = <span class="tok-kw">switch</span> (endian) {</span>
<span class="line" id="L1814">                    .Little =&gt; buffer[bytes_read..],</span>
<span class="line" id="L1815">                    .Big =&gt; buffer[(abi_size - bytes_read - read_size)..],</span>
<span class="line" id="L1816">                };</span>
<span class="line" id="L1817">                limb |= <span class="tok-builtin">@intCast</span>(Limb, <span class="tok-kw">switch</span> (read_size) {</span>
<span class="line" id="L1818">                    <span class="tok-number">1</span> =&gt; mem.readInt(<span class="tok-type">u8</span>, int_buffer[<span class="tok-number">0</span>..<span class="tok-number">1</span>], endian),</span>
<span class="line" id="L1819">                    <span class="tok-number">2</span> =&gt; mem.readInt(<span class="tok-type">u16</span>, int_buffer[<span class="tok-number">0</span>..<span class="tok-number">2</span>], endian),</span>
<span class="line" id="L1820">                    <span class="tok-number">4</span> =&gt; mem.readInt(<span class="tok-type">u32</span>, int_buffer[<span class="tok-number">0</span>..<span class="tok-number">4</span>], endian),</span>
<span class="line" id="L1821">                    <span class="tok-number">8</span> =&gt; mem.readInt(<span class="tok-type">u64</span>, int_buffer[<span class="tok-number">0</span>..<span class="tok-number">8</span>], endian),</span>
<span class="line" id="L1822">                    <span class="tok-number">16</span> =&gt; mem.readInt(<span class="tok-type">u128</span>, int_buffer[<span class="tok-number">0</span>..<span class="tok-number">16</span>], endian),</span>
<span class="line" id="L1823">                    <span class="tok-kw">else</span> =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L1824">                }) &lt;&lt; <span class="tok-builtin">@intCast</span>(Log2Limb, <span class="tok-number">8</span> * (bytes_read % <span class="tok-builtin">@sizeOf</span>(Limb)));</span>
<span class="line" id="L1825">                bytes_read += read_size;</span>
<span class="line" id="L1826">            }</span>
<span class="line" id="L1827"></span>
<span class="line" id="L1828">            <span class="tok-comment">// 2's complement (bitwise not, then add carry bit)</span>
</span>
<span class="line" id="L1829">            <span class="tok-kw">if</span> (!positive) _ = <span class="tok-builtin">@addWithOverflow</span>(Limb, ~limb, carry, &amp;limb);</span>
<span class="line" id="L1830"></span>
<span class="line" id="L1831">            <span class="tok-comment">// Mask off any unused bits</span>
</span>
<span class="line" id="L1832">            <span class="tok-kw">const</span> valid_bits = <span class="tok-builtin">@intCast</span>(Log2Limb, bit_count % <span class="tok-builtin">@bitSizeOf</span>(Limb));</span>
<span class="line" id="L1833">            <span class="tok-kw">const</span> mask = (<span class="tok-builtin">@as</span>(Limb, <span class="tok-number">1</span>) &lt;&lt; valid_bits) -% <span class="tok-number">1</span>; <span class="tok-comment">// 0b0..01..1 with (valid_bits_in_limb) trailing ones</span>
</span>
<span class="line" id="L1834">            limb &amp;= mask;</span>
<span class="line" id="L1835"></span>
<span class="line" id="L1836">            x.limbs[limb_count - <span class="tok-number">1</span>] = limb;</span>
<span class="line" id="L1837">        }</span>
<span class="line" id="L1838">        x.positive = positive;</span>
<span class="line" id="L1839">        x.len = limb_count;</span>
<span class="line" id="L1840">        x.normalize(x.len);</span>
<span class="line" id="L1841">    }</span>
<span class="line" id="L1842"></span>
<span class="line" id="L1843">    <span class="tok-comment">/// Normalize a possible sequence of leading zeros.</span></span>
<span class="line" id="L1844">    <span class="tok-comment">///</span></span>
<span class="line" id="L1845">    <span class="tok-comment">/// [1, 2, 3, 4, 0] -&gt; [1, 2, 3, 4]</span></span>
<span class="line" id="L1846">    <span class="tok-comment">/// [1, 2, 0, 0, 0] -&gt; [1, 2]</span></span>
<span class="line" id="L1847">    <span class="tok-comment">/// [0, 0, 0, 0, 0] -&gt; [0]</span></span>
<span class="line" id="L1848">    <span class="tok-kw">fn</span> <span class="tok-fn">normalize</span>(r: *Mutable, length: <span class="tok-type">usize</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L1849">        r.len = llnormalize(r.limbs[<span class="tok-number">0</span>..length]);</span>
<span class="line" id="L1850">    }</span>
<span class="line" id="L1851">};</span>
<span class="line" id="L1852"></span>
<span class="line" id="L1853"><span class="tok-comment">/// A arbitrary-precision big integer, with a fixed set of immutable limbs.</span></span>
<span class="line" id="L1854"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> Const = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L1855">    <span class="tok-comment">/// Raw digits. These are:</span></span>
<span class="line" id="L1856">    <span class="tok-comment">///</span></span>
<span class="line" id="L1857">    <span class="tok-comment">/// * Little-endian ordered</span></span>
<span class="line" id="L1858">    <span class="tok-comment">/// * limbs.len &gt;= 1</span></span>
<span class="line" id="L1859">    <span class="tok-comment">/// * Zero is represented as limbs.len == 1 with limbs[0] == 0.</span></span>
<span class="line" id="L1860">    <span class="tok-comment">///</span></span>
<span class="line" id="L1861">    <span class="tok-comment">/// Accessing limbs directly should be avoided.</span></span>
<span class="line" id="L1862">    limbs: []<span class="tok-kw">const</span> Limb,</span>
<span class="line" id="L1863">    positive: <span class="tok-type">bool</span>,</span>
<span class="line" id="L1864"></span>
<span class="line" id="L1865">    <span class="tok-comment">/// The result is an independent resource which is managed by the caller.</span></span>
<span class="line" id="L1866">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">toManaged</span>(self: Const, allocator: Allocator) Allocator.Error!Managed {</span>
<span class="line" id="L1867">        <span class="tok-kw">const</span> limbs = <span class="tok-kw">try</span> allocator.alloc(Limb, math.max(Managed.default_capacity, self.limbs.len));</span>
<span class="line" id="L1868">        mem.copy(Limb, limbs, self.limbs);</span>
<span class="line" id="L1869">        <span class="tok-kw">return</span> Managed{</span>
<span class="line" id="L1870">            .allocator = allocator,</span>
<span class="line" id="L1871">            .limbs = limbs,</span>
<span class="line" id="L1872">            .metadata = <span class="tok-kw">if</span> (self.positive)</span>
<span class="line" id="L1873">                self.limbs.len &amp; ~Managed.sign_bit</span>
<span class="line" id="L1874">            <span class="tok-kw">else</span></span>
<span class="line" id="L1875">                self.limbs.len | Managed.sign_bit,</span>
<span class="line" id="L1876">        };</span>
<span class="line" id="L1877">    }</span>
<span class="line" id="L1878"></span>
<span class="line" id="L1879">    <span class="tok-comment">/// Asserts `limbs` is big enough to store the value.</span></span>
<span class="line" id="L1880">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">toMutable</span>(self: Const, limbs: []Limb) Mutable {</span>
<span class="line" id="L1881">        mem.copy(Limb, limbs, self.limbs[<span class="tok-number">0</span>..self.limbs.len]);</span>
<span class="line" id="L1882">        <span class="tok-kw">return</span> .{</span>
<span class="line" id="L1883">            .limbs = limbs,</span>
<span class="line" id="L1884">            .positive = self.positive,</span>
<span class="line" id="L1885">            .len = self.limbs.len,</span>
<span class="line" id="L1886">        };</span>
<span class="line" id="L1887">    }</span>
<span class="line" id="L1888"></span>
<span class="line" id="L1889">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">dump</span>(self: Const) <span class="tok-type">void</span> {</span>
<span class="line" id="L1890">        <span class="tok-kw">for</span> (self.limbs[<span class="tok-number">0</span>..self.limbs.len]) |limb| {</span>
<span class="line" id="L1891">            std.debug.print(<span class="tok-str">&quot;{x} &quot;</span>, .{limb});</span>
<span class="line" id="L1892">        }</span>
<span class="line" id="L1893">        std.debug.print(<span class="tok-str">&quot;positive={}\n&quot;</span>, .{self.positive});</span>
<span class="line" id="L1894">    }</span>
<span class="line" id="L1895"></span>
<span class="line" id="L1896">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">abs</span>(self: Const) Const {</span>
<span class="line" id="L1897">        <span class="tok-kw">return</span> .{</span>
<span class="line" id="L1898">            .limbs = self.limbs,</span>
<span class="line" id="L1899">            .positive = <span class="tok-null">true</span>,</span>
<span class="line" id="L1900">        };</span>
<span class="line" id="L1901">    }</span>
<span class="line" id="L1902"></span>
<span class="line" id="L1903">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">negate</span>(self: Const) Const {</span>
<span class="line" id="L1904">        <span class="tok-kw">return</span> .{</span>
<span class="line" id="L1905">            .limbs = self.limbs,</span>
<span class="line" id="L1906">            .positive = !self.positive,</span>
<span class="line" id="L1907">        };</span>
<span class="line" id="L1908">    }</span>
<span class="line" id="L1909"></span>
<span class="line" id="L1910">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">isOdd</span>(self: Const) <span class="tok-type">bool</span> {</span>
<span class="line" id="L1911">        <span class="tok-kw">return</span> self.limbs[<span class="tok-number">0</span>] &amp; <span class="tok-number">1</span> != <span class="tok-number">0</span>;</span>
<span class="line" id="L1912">    }</span>
<span class="line" id="L1913"></span>
<span class="line" id="L1914">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">isEven</span>(self: Const) <span class="tok-type">bool</span> {</span>
<span class="line" id="L1915">        <span class="tok-kw">return</span> !self.isOdd();</span>
<span class="line" id="L1916">    }</span>
<span class="line" id="L1917"></span>
<span class="line" id="L1918">    <span class="tok-comment">/// Returns the number of bits required to represent the absolute value of an integer.</span></span>
<span class="line" id="L1919">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">bitCountAbs</span>(self: Const) <span class="tok-type">usize</span> {</span>
<span class="line" id="L1920">        <span class="tok-kw">return</span> (self.limbs.len - <span class="tok-number">1</span>) * limb_bits + (limb_bits - <span class="tok-builtin">@clz</span>(Limb, self.limbs[self.limbs.len - <span class="tok-number">1</span>]));</span>
<span class="line" id="L1921">    }</span>
<span class="line" id="L1922"></span>
<span class="line" id="L1923">    <span class="tok-comment">/// Returns the number of bits required to represent the integer in twos-complement form.</span></span>
<span class="line" id="L1924">    <span class="tok-comment">///</span></span>
<span class="line" id="L1925">    <span class="tok-comment">/// If the integer is negative the value returned is the number of bits needed by a signed</span></span>
<span class="line" id="L1926">    <span class="tok-comment">/// integer to represent the value. If positive the value is the number of bits for an</span></span>
<span class="line" id="L1927">    <span class="tok-comment">/// unsigned integer. Any unsigned integer will fit in the signed integer with bitcount</span></span>
<span class="line" id="L1928">    <span class="tok-comment">/// one greater than the returned value.</span></span>
<span class="line" id="L1929">    <span class="tok-comment">///</span></span>
<span class="line" id="L1930">    <span class="tok-comment">/// e.g. -127 returns 8 as it will fit in an i8. 127 returns 7 since it fits in a u7.</span></span>
<span class="line" id="L1931">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">bitCountTwosComp</span>(self: Const) <span class="tok-type">usize</span> {</span>
<span class="line" id="L1932">        <span class="tok-kw">var</span> bits = self.bitCountAbs();</span>
<span class="line" id="L1933"></span>
<span class="line" id="L1934">        <span class="tok-comment">// If the entire value has only one bit set (e.g. 0b100000000) then the negation in twos</span>
</span>
<span class="line" id="L1935">        <span class="tok-comment">// complement requires one less bit.</span>
</span>
<span class="line" id="L1936">        <span class="tok-kw">if</span> (!self.positive) block: {</span>
<span class="line" id="L1937">            bits += <span class="tok-number">1</span>;</span>
<span class="line" id="L1938"></span>
<span class="line" id="L1939">            <span class="tok-kw">if</span> (<span class="tok-builtin">@popCount</span>(Limb, self.limbs[self.limbs.len - <span class="tok-number">1</span>]) == <span class="tok-number">1</span>) {</span>
<span class="line" id="L1940">                <span class="tok-kw">for</span> (self.limbs[<span class="tok-number">0</span> .. self.limbs.len - <span class="tok-number">1</span>]) |limb| {</span>
<span class="line" id="L1941">                    <span class="tok-kw">if</span> (<span class="tok-builtin">@popCount</span>(Limb, limb) != <span class="tok-number">0</span>) {</span>
<span class="line" id="L1942">                        <span class="tok-kw">break</span> :block;</span>
<span class="line" id="L1943">                    }</span>
<span class="line" id="L1944">                }</span>
<span class="line" id="L1945"></span>
<span class="line" id="L1946">                bits -= <span class="tok-number">1</span>;</span>
<span class="line" id="L1947">            }</span>
<span class="line" id="L1948">        }</span>
<span class="line" id="L1949"></span>
<span class="line" id="L1950">        <span class="tok-kw">return</span> bits;</span>
<span class="line" id="L1951">    }</span>
<span class="line" id="L1952"></span>
<span class="line" id="L1953">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">fitsInTwosComp</span>(self: Const, signedness: Signedness, bit_count: <span class="tok-type">usize</span>) <span class="tok-type">bool</span> {</span>
<span class="line" id="L1954">        <span class="tok-kw">if</span> (self.eqZero()) {</span>
<span class="line" id="L1955">            <span class="tok-kw">return</span> <span class="tok-null">true</span>;</span>
<span class="line" id="L1956">        }</span>
<span class="line" id="L1957">        <span class="tok-kw">if</span> (signedness == .unsigned <span class="tok-kw">and</span> !self.positive) {</span>
<span class="line" id="L1958">            <span class="tok-kw">return</span> <span class="tok-null">false</span>;</span>
<span class="line" id="L1959">        }</span>
<span class="line" id="L1960"></span>
<span class="line" id="L1961">        <span class="tok-kw">const</span> req_bits = self.bitCountTwosComp() + <span class="tok-builtin">@boolToInt</span>(self.positive <span class="tok-kw">and</span> signedness == .signed);</span>
<span class="line" id="L1962">        <span class="tok-kw">return</span> bit_count &gt;= req_bits;</span>
<span class="line" id="L1963">    }</span>
<span class="line" id="L1964"></span>
<span class="line" id="L1965">    <span class="tok-comment">/// Returns whether self can fit into an integer of the requested type.</span></span>
<span class="line" id="L1966">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">fits</span>(self: Const, <span class="tok-kw">comptime</span> T: <span class="tok-type">type</span>) <span class="tok-type">bool</span> {</span>
<span class="line" id="L1967">        <span class="tok-kw">const</span> info = <span class="tok-builtin">@typeInfo</span>(T).Int;</span>
<span class="line" id="L1968">        <span class="tok-kw">return</span> self.fitsInTwosComp(info.signedness, info.bits);</span>
<span class="line" id="L1969">    }</span>
<span class="line" id="L1970"></span>
<span class="line" id="L1971">    <span class="tok-comment">/// Returns the approximate size of the integer in the given base. Negative values accommodate for</span></span>
<span class="line" id="L1972">    <span class="tok-comment">/// the minus sign. This is used for determining the number of characters needed to print the</span></span>
<span class="line" id="L1973">    <span class="tok-comment">/// value. It is inexact and may exceed the given value by ~1-2 bytes.</span></span>
<span class="line" id="L1974">    <span class="tok-comment">/// TODO See if we can make this exact.</span></span>
<span class="line" id="L1975">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">sizeInBaseUpperBound</span>(self: Const, base: <span class="tok-type">usize</span>) <span class="tok-type">usize</span> {</span>
<span class="line" id="L1976">        <span class="tok-kw">const</span> bit_count = <span class="tok-builtin">@as</span>(<span class="tok-type">usize</span>, <span class="tok-builtin">@boolToInt</span>(!self.positive)) + self.bitCountAbs();</span>
<span class="line" id="L1977">        <span class="tok-kw">return</span> (bit_count / math.log2(base)) + <span class="tok-number">2</span>;</span>
<span class="line" id="L1978">    }</span>
<span class="line" id="L1979"></span>
<span class="line" id="L1980">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> ConvertError = <span class="tok-kw">error</span>{</span>
<span class="line" id="L1981">        NegativeIntoUnsigned,</span>
<span class="line" id="L1982">        TargetTooSmall,</span>
<span class="line" id="L1983">    };</span>
<span class="line" id="L1984"></span>
<span class="line" id="L1985">    <span class="tok-comment">/// Convert self to type T.</span></span>
<span class="line" id="L1986">    <span class="tok-comment">///</span></span>
<span class="line" id="L1987">    <span class="tok-comment">/// Returns an error if self cannot be narrowed into the requested type without truncation.</span></span>
<span class="line" id="L1988">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">to</span>(self: Const, <span class="tok-kw">comptime</span> T: <span class="tok-type">type</span>) ConvertError!T {</span>
<span class="line" id="L1989">        <span class="tok-kw">switch</span> (<span class="tok-builtin">@typeInfo</span>(T)) {</span>
<span class="line" id="L1990">            .Int =&gt; |info| {</span>
<span class="line" id="L1991">                <span class="tok-kw">const</span> UT = std.meta.Int(.unsigned, info.bits);</span>
<span class="line" id="L1992"></span>
<span class="line" id="L1993">                <span class="tok-kw">if</span> (!self.fitsInTwosComp(info.signedness, info.bits)) {</span>
<span class="line" id="L1994">                    <span class="tok-kw">return</span> <span class="tok-kw">error</span>.TargetTooSmall;</span>
<span class="line" id="L1995">                }</span>
<span class="line" id="L1996"></span>
<span class="line" id="L1997">                <span class="tok-kw">var</span> r: UT = <span class="tok-number">0</span>;</span>
<span class="line" id="L1998"></span>
<span class="line" id="L1999">                <span class="tok-kw">if</span> (<span class="tok-builtin">@sizeOf</span>(UT) &lt;= <span class="tok-builtin">@sizeOf</span>(Limb)) {</span>
<span class="line" id="L2000">                    r = <span class="tok-builtin">@intCast</span>(UT, self.limbs[<span class="tok-number">0</span>]);</span>
<span class="line" id="L2001">                } <span class="tok-kw">else</span> {</span>
<span class="line" id="L2002">                    <span class="tok-kw">for</span> (self.limbs[<span class="tok-number">0</span>..self.limbs.len]) |_, ri| {</span>
<span class="line" id="L2003">                        <span class="tok-kw">const</span> limb = self.limbs[self.limbs.len - ri - <span class="tok-number">1</span>];</span>
<span class="line" id="L2004">                        r &lt;&lt;= limb_bits;</span>
<span class="line" id="L2005">                        r |= limb;</span>
<span class="line" id="L2006">                    }</span>
<span class="line" id="L2007">                }</span>
<span class="line" id="L2008"></span>
<span class="line" id="L2009">                <span class="tok-kw">if</span> (info.signedness == .unsigned) {</span>
<span class="line" id="L2010">                    <span class="tok-kw">return</span> <span class="tok-kw">if</span> (self.positive) <span class="tok-builtin">@intCast</span>(T, r) <span class="tok-kw">else</span> <span class="tok-kw">error</span>.NegativeIntoUnsigned;</span>
<span class="line" id="L2011">                } <span class="tok-kw">else</span> {</span>
<span class="line" id="L2012">                    <span class="tok-kw">if</span> (self.positive) {</span>
<span class="line" id="L2013">                        <span class="tok-kw">return</span> <span class="tok-builtin">@intCast</span>(T, r);</span>
<span class="line" id="L2014">                    } <span class="tok-kw">else</span> {</span>
<span class="line" id="L2015">                        <span class="tok-kw">if</span> (math.cast(T, r)) |ok| {</span>
<span class="line" id="L2016">                            <span class="tok-kw">return</span> -ok;</span>
<span class="line" id="L2017">                        } <span class="tok-kw">else</span> {</span>
<span class="line" id="L2018">                            <span class="tok-kw">return</span> minInt(T);</span>
<span class="line" id="L2019">                        }</span>
<span class="line" id="L2020">                    }</span>
<span class="line" id="L2021">                }</span>
<span class="line" id="L2022">            },</span>
<span class="line" id="L2023">            <span class="tok-kw">else</span> =&gt; <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;cannot convert Const to type &quot;</span> ++ <span class="tok-builtin">@typeName</span>(T)),</span>
<span class="line" id="L2024">        }</span>
<span class="line" id="L2025">    }</span>
<span class="line" id="L2026"></span>
<span class="line" id="L2027">    <span class="tok-comment">/// To allow `std.fmt.format` to work with this type.</span></span>
<span class="line" id="L2028">    <span class="tok-comment">/// If the integer is larger than `pow(2, 64 * @sizeOf(usize) * 8), this function will fail</span></span>
<span class="line" id="L2029">    <span class="tok-comment">/// to print the string, printing &quot;(BigInt)&quot; instead of a number.</span></span>
<span class="line" id="L2030">    <span class="tok-comment">/// This is because the rendering algorithm requires reversing a string, which requires O(N) memory.</span></span>
<span class="line" id="L2031">    <span class="tok-comment">/// See `toString` and `toStringAlloc` for a way to print big integers without failure.</span></span>
<span class="line" id="L2032">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">format</span>(</span>
<span class="line" id="L2033">        self: Const,</span>
<span class="line" id="L2034">        <span class="tok-kw">comptime</span> fmt: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L2035">        options: std.fmt.FormatOptions,</span>
<span class="line" id="L2036">        out_stream: <span class="tok-kw">anytype</span>,</span>
<span class="line" id="L2037">    ) !<span class="tok-type">void</span> {</span>
<span class="line" id="L2038">        _ = options;</span>
<span class="line" id="L2039">        <span class="tok-kw">comptime</span> <span class="tok-kw">var</span> radix = <span class="tok-number">10</span>;</span>
<span class="line" id="L2040">        <span class="tok-kw">comptime</span> <span class="tok-kw">var</span> case: std.fmt.Case = .lower;</span>
<span class="line" id="L2041"></span>
<span class="line" id="L2042">        <span class="tok-kw">if</span> (fmt.len == <span class="tok-number">0</span> <span class="tok-kw">or</span> <span class="tok-kw">comptime</span> mem.eql(<span class="tok-type">u8</span>, fmt, <span class="tok-str">&quot;d&quot;</span>)) {</span>
<span class="line" id="L2043">            radix = <span class="tok-number">10</span>;</span>
<span class="line" id="L2044">            case = .lower;</span>
<span class="line" id="L2045">        } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (<span class="tok-kw">comptime</span> mem.eql(<span class="tok-type">u8</span>, fmt, <span class="tok-str">&quot;b&quot;</span>)) {</span>
<span class="line" id="L2046">            radix = <span class="tok-number">2</span>;</span>
<span class="line" id="L2047">            case = .lower;</span>
<span class="line" id="L2048">        } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (<span class="tok-kw">comptime</span> mem.eql(<span class="tok-type">u8</span>, fmt, <span class="tok-str">&quot;x&quot;</span>)) {</span>
<span class="line" id="L2049">            radix = <span class="tok-number">16</span>;</span>
<span class="line" id="L2050">            case = .lower;</span>
<span class="line" id="L2051">        } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (<span class="tok-kw">comptime</span> mem.eql(<span class="tok-type">u8</span>, fmt, <span class="tok-str">&quot;X&quot;</span>)) {</span>
<span class="line" id="L2052">            radix = <span class="tok-number">16</span>;</span>
<span class="line" id="L2053">            case = .upper;</span>
<span class="line" id="L2054">        } <span class="tok-kw">else</span> {</span>
<span class="line" id="L2055">            <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;Unknown format string: '&quot;</span> ++ fmt ++ <span class="tok-str">&quot;'&quot;</span>);</span>
<span class="line" id="L2056">        }</span>
<span class="line" id="L2057"></span>
<span class="line" id="L2058">        <span class="tok-kw">var</span> limbs: [<span class="tok-number">128</span>]Limb = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L2059">        <span class="tok-kw">const</span> needed_limbs = calcDivLimbsBufferLen(self.limbs.len, <span class="tok-number">1</span>);</span>
<span class="line" id="L2060">        <span class="tok-kw">if</span> (needed_limbs &gt; limbs.len)</span>
<span class="line" id="L2061">            <span class="tok-kw">return</span> out_stream.writeAll(<span class="tok-str">&quot;(BigInt)&quot;</span>);</span>
<span class="line" id="L2062"></span>
<span class="line" id="L2063">        <span class="tok-comment">// This is the inverse of calcDivLimbsBufferLen</span>
</span>
<span class="line" id="L2064">        <span class="tok-kw">const</span> available_len = (limbs.len / <span class="tok-number">3</span>) - <span class="tok-number">2</span>;</span>
<span class="line" id="L2065"></span>
<span class="line" id="L2066">        <span class="tok-kw">const</span> biggest: Const = .{</span>
<span class="line" id="L2067">            .limbs = &amp;([<span class="tok-number">1</span>]Limb{<span class="tok-kw">comptime</span> math.maxInt(Limb)} ** available_len),</span>
<span class="line" id="L2068">            .positive = <span class="tok-null">false</span>,</span>
<span class="line" id="L2069">        };</span>
<span class="line" id="L2070">        <span class="tok-kw">var</span> buf: [biggest.sizeInBaseUpperBound(radix)]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L2071">        <span class="tok-kw">const</span> len = self.toString(&amp;buf, radix, case, &amp;limbs);</span>
<span class="line" id="L2072">        <span class="tok-kw">return</span> out_stream.writeAll(buf[<span class="tok-number">0</span>..len]);</span>
<span class="line" id="L2073">    }</span>
<span class="line" id="L2074"></span>
<span class="line" id="L2075">    <span class="tok-comment">/// Converts self to a string in the requested base.</span></span>
<span class="line" id="L2076">    <span class="tok-comment">/// Caller owns returned memory.</span></span>
<span class="line" id="L2077">    <span class="tok-comment">/// Asserts that `base` is in the range [2, 16].</span></span>
<span class="line" id="L2078">    <span class="tok-comment">/// See also `toString`, a lower level function than this.</span></span>
<span class="line" id="L2079">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">toStringAlloc</span>(self: Const, allocator: Allocator, base: <span class="tok-type">u8</span>, case: std.fmt.Case) Allocator.Error![]<span class="tok-type">u8</span> {</span>
<span class="line" id="L2080">        assert(base &gt;= <span class="tok-number">2</span>);</span>
<span class="line" id="L2081">        assert(base &lt;= <span class="tok-number">16</span>);</span>
<span class="line" id="L2082"></span>
<span class="line" id="L2083">        <span class="tok-kw">if</span> (self.eqZero()) {</span>
<span class="line" id="L2084">            <span class="tok-kw">return</span> allocator.dupe(<span class="tok-type">u8</span>, <span class="tok-str">&quot;0&quot;</span>);</span>
<span class="line" id="L2085">        }</span>
<span class="line" id="L2086">        <span class="tok-kw">const</span> string = <span class="tok-kw">try</span> allocator.alloc(<span class="tok-type">u8</span>, self.sizeInBaseUpperBound(base));</span>
<span class="line" id="L2087">        <span class="tok-kw">errdefer</span> allocator.free(string);</span>
<span class="line" id="L2088"></span>
<span class="line" id="L2089">        <span class="tok-kw">const</span> limbs = <span class="tok-kw">try</span> allocator.alloc(Limb, calcToStringLimbsBufferLen(self.limbs.len, base));</span>
<span class="line" id="L2090">        <span class="tok-kw">defer</span> allocator.free(limbs);</span>
<span class="line" id="L2091"></span>
<span class="line" id="L2092">        <span class="tok-kw">return</span> allocator.shrink(string, self.toString(string, base, case, limbs));</span>
<span class="line" id="L2093">    }</span>
<span class="line" id="L2094"></span>
<span class="line" id="L2095">    <span class="tok-comment">/// Converts self to a string in the requested base.</span></span>
<span class="line" id="L2096">    <span class="tok-comment">/// Asserts that `base` is in the range [2, 16].</span></span>
<span class="line" id="L2097">    <span class="tok-comment">/// `string` is a caller-provided slice of at least `sizeInBaseUpperBound` bytes,</span></span>
<span class="line" id="L2098">    <span class="tok-comment">/// where the result is written to.</span></span>
<span class="line" id="L2099">    <span class="tok-comment">/// Returns the length of the string.</span></span>
<span class="line" id="L2100">    <span class="tok-comment">/// `limbs_buffer` is caller-provided memory for `toString` to use as a working area. It must have</span></span>
<span class="line" id="L2101">    <span class="tok-comment">/// length of at least `calcToStringLimbsBufferLen`.</span></span>
<span class="line" id="L2102">    <span class="tok-comment">/// In the case of power-of-two base, `limbs_buffer` is ignored.</span></span>
<span class="line" id="L2103">    <span class="tok-comment">/// See also `toStringAlloc`, a higher level function than this.</span></span>
<span class="line" id="L2104">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">toString</span>(self: Const, string: []<span class="tok-type">u8</span>, base: <span class="tok-type">u8</span>, case: std.fmt.Case, limbs_buffer: []Limb) <span class="tok-type">usize</span> {</span>
<span class="line" id="L2105">        assert(base &gt;= <span class="tok-number">2</span>);</span>
<span class="line" id="L2106">        assert(base &lt;= <span class="tok-number">16</span>);</span>
<span class="line" id="L2107"></span>
<span class="line" id="L2108">        <span class="tok-kw">if</span> (self.eqZero()) {</span>
<span class="line" id="L2109">            string[<span class="tok-number">0</span>] = <span class="tok-str">'0'</span>;</span>
<span class="line" id="L2110">            <span class="tok-kw">return</span> <span class="tok-number">1</span>;</span>
<span class="line" id="L2111">        }</span>
<span class="line" id="L2112"></span>
<span class="line" id="L2113">        <span class="tok-kw">var</span> digits_len: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L2114"></span>
<span class="line" id="L2115">        <span class="tok-comment">// Power of two: can do a single pass and use masks to extract digits.</span>
</span>
<span class="line" id="L2116">        <span class="tok-kw">if</span> (math.isPowerOfTwo(base)) {</span>
<span class="line" id="L2117">            <span class="tok-kw">const</span> base_shift = math.log2_int(Limb, base);</span>
<span class="line" id="L2118"></span>
<span class="line" id="L2119">            outer: <span class="tok-kw">for</span> (self.limbs[<span class="tok-number">0</span>..self.limbs.len]) |limb| {</span>
<span class="line" id="L2120">                <span class="tok-kw">var</span> shift: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L2121">                <span class="tok-kw">while</span> (shift &lt; limb_bits) : (shift += base_shift) {</span>
<span class="line" id="L2122">                    <span class="tok-kw">const</span> r = <span class="tok-builtin">@intCast</span>(<span class="tok-type">u8</span>, (limb &gt;&gt; <span class="tok-builtin">@intCast</span>(Log2Limb, shift)) &amp; <span class="tok-builtin">@as</span>(Limb, base - <span class="tok-number">1</span>));</span>
<span class="line" id="L2123">                    <span class="tok-kw">const</span> ch = std.fmt.digitToChar(r, case);</span>
<span class="line" id="L2124">                    string[digits_len] = ch;</span>
<span class="line" id="L2125">                    digits_len += <span class="tok-number">1</span>;</span>
<span class="line" id="L2126">                    <span class="tok-comment">// If we hit the end, it must be all zeroes from here.</span>
</span>
<span class="line" id="L2127">                    <span class="tok-kw">if</span> (digits_len == string.len) <span class="tok-kw">break</span> :outer;</span>
<span class="line" id="L2128">                }</span>
<span class="line" id="L2129">            }</span>
<span class="line" id="L2130"></span>
<span class="line" id="L2131">            <span class="tok-comment">// Always will have a non-zero digit somewhere.</span>
</span>
<span class="line" id="L2132">            <span class="tok-kw">while</span> (string[digits_len - <span class="tok-number">1</span>] == <span class="tok-str">'0'</span>) {</span>
<span class="line" id="L2133">                digits_len -= <span class="tok-number">1</span>;</span>
<span class="line" id="L2134">            }</span>
<span class="line" id="L2135">        } <span class="tok-kw">else</span> {</span>
<span class="line" id="L2136">            <span class="tok-comment">// Non power-of-two: batch divisions per word size.</span>
</span>
<span class="line" id="L2137">            <span class="tok-comment">// We use a HalfLimb here so the division uses the faster lldiv0p5 over lldiv1 codepath.</span>
</span>
<span class="line" id="L2138">            <span class="tok-kw">const</span> digits_per_limb = math.log(HalfLimb, base, maxInt(HalfLimb));</span>
<span class="line" id="L2139">            <span class="tok-kw">var</span> limb_base: Limb = <span class="tok-number">1</span>;</span>
<span class="line" id="L2140">            <span class="tok-kw">var</span> j: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L2141">            <span class="tok-kw">while</span> (j &lt; digits_per_limb) : (j += <span class="tok-number">1</span>) {</span>
<span class="line" id="L2142">                limb_base *= base;</span>
<span class="line" id="L2143">            }</span>
<span class="line" id="L2144">            <span class="tok-kw">const</span> b: Const = .{ .limbs = &amp;[_]Limb{limb_base}, .positive = <span class="tok-null">true</span> };</span>
<span class="line" id="L2145"></span>
<span class="line" id="L2146">            <span class="tok-kw">var</span> q: Mutable = .{</span>
<span class="line" id="L2147">                .limbs = limbs_buffer[<span class="tok-number">0</span> .. self.limbs.len + <span class="tok-number">2</span>],</span>
<span class="line" id="L2148">                .positive = <span class="tok-null">true</span>, <span class="tok-comment">// Make absolute by ignoring self.positive.</span>
</span>
<span class="line" id="L2149">                .len = self.limbs.len,</span>
<span class="line" id="L2150">            };</span>
<span class="line" id="L2151">            mem.copy(Limb, q.limbs, self.limbs);</span>
<span class="line" id="L2152"></span>
<span class="line" id="L2153">            <span class="tok-kw">var</span> r: Mutable = .{</span>
<span class="line" id="L2154">                .limbs = limbs_buffer[q.limbs.len..][<span class="tok-number">0</span>..self.limbs.len],</span>
<span class="line" id="L2155">                .positive = <span class="tok-null">true</span>,</span>
<span class="line" id="L2156">                .len = <span class="tok-number">1</span>,</span>
<span class="line" id="L2157">            };</span>
<span class="line" id="L2158">            r.limbs[<span class="tok-number">0</span>] = <span class="tok-number">0</span>;</span>
<span class="line" id="L2159"></span>
<span class="line" id="L2160">            <span class="tok-kw">const</span> rest_of_the_limbs_buf = limbs_buffer[q.limbs.len + r.limbs.len ..];</span>
<span class="line" id="L2161"></span>
<span class="line" id="L2162">            <span class="tok-kw">while</span> (q.len &gt;= <span class="tok-number">2</span>) {</span>
<span class="line" id="L2163">                <span class="tok-comment">// Passing an allocator here would not be helpful since this division is destroying</span>
</span>
<span class="line" id="L2164">                <span class="tok-comment">// information, not creating it. [TODO citation needed]</span>
</span>
<span class="line" id="L2165">                q.divTrunc(&amp;r, q.toConst(), b, rest_of_the_limbs_buf);</span>
<span class="line" id="L2166"></span>
<span class="line" id="L2167">                <span class="tok-kw">var</span> r_word = r.limbs[<span class="tok-number">0</span>];</span>
<span class="line" id="L2168">                <span class="tok-kw">var</span> i: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L2169">                <span class="tok-kw">while</span> (i &lt; digits_per_limb) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L2170">                    <span class="tok-kw">const</span> ch = std.fmt.digitToChar(<span class="tok-builtin">@intCast</span>(<span class="tok-type">u8</span>, r_word % base), case);</span>
<span class="line" id="L2171">                    r_word /= base;</span>
<span class="line" id="L2172">                    string[digits_len] = ch;</span>
<span class="line" id="L2173">                    digits_len += <span class="tok-number">1</span>;</span>
<span class="line" id="L2174">                }</span>
<span class="line" id="L2175">            }</span>
<span class="line" id="L2176"></span>
<span class="line" id="L2177">            {</span>
<span class="line" id="L2178">                assert(q.len == <span class="tok-number">1</span>);</span>
<span class="line" id="L2179"></span>
<span class="line" id="L2180">                <span class="tok-kw">var</span> r_word = q.limbs[<span class="tok-number">0</span>];</span>
<span class="line" id="L2181">                <span class="tok-kw">while</span> (r_word != <span class="tok-number">0</span>) {</span>
<span class="line" id="L2182">                    <span class="tok-kw">const</span> ch = std.fmt.digitToChar(<span class="tok-builtin">@intCast</span>(<span class="tok-type">u8</span>, r_word % base), case);</span>
<span class="line" id="L2183">                    r_word /= base;</span>
<span class="line" id="L2184">                    string[digits_len] = ch;</span>
<span class="line" id="L2185">                    digits_len += <span class="tok-number">1</span>;</span>
<span class="line" id="L2186">                }</span>
<span class="line" id="L2187">            }</span>
<span class="line" id="L2188">        }</span>
<span class="line" id="L2189"></span>
<span class="line" id="L2190">        <span class="tok-kw">if</span> (!self.positive) {</span>
<span class="line" id="L2191">            string[digits_len] = <span class="tok-str">'-'</span>;</span>
<span class="line" id="L2192">            digits_len += <span class="tok-number">1</span>;</span>
<span class="line" id="L2193">        }</span>
<span class="line" id="L2194"></span>
<span class="line" id="L2195">        <span class="tok-kw">const</span> s = string[<span class="tok-number">0</span>..digits_len];</span>
<span class="line" id="L2196">        mem.reverse(<span class="tok-type">u8</span>, s);</span>
<span class="line" id="L2197">        <span class="tok-kw">return</span> s.len;</span>
<span class="line" id="L2198">    }</span>
<span class="line" id="L2199"></span>
<span class="line" id="L2200">    <span class="tok-comment">/// Write the value of `x` into `buffer`</span></span>
<span class="line" id="L2201">    <span class="tok-comment">/// Asserts that `buffer`, `abi_size`, and `bit_count` are large enough to store the value.</span></span>
<span class="line" id="L2202">    <span class="tok-comment">///</span></span>
<span class="line" id="L2203">    <span class="tok-comment">/// `buffer` is filled so that its contents match what would be observed via</span></span>
<span class="line" id="L2204">    <span class="tok-comment">/// @ptrCast(*[abi_size]const u8, &amp;x). Byte ordering is determined by `endian`,</span></span>
<span class="line" id="L2205">    <span class="tok-comment">/// and any required padding bits are added on the MSB end.</span></span>
<span class="line" id="L2206">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">writeTwosComplement</span>(x: Const, buffer: []<span class="tok-type">u8</span>, bit_count: <span class="tok-type">usize</span>, abi_size: <span class="tok-type">usize</span>, endian: Endian) <span class="tok-type">void</span> {</span>
<span class="line" id="L2207"></span>
<span class="line" id="L2208">        <span class="tok-comment">// byte_count is our total write size</span>
</span>
<span class="line" id="L2209">        <span class="tok-kw">const</span> byte_count = abi_size;</span>
<span class="line" id="L2210">        assert(<span class="tok-number">8</span> * byte_count &gt;= bit_count);</span>
<span class="line" id="L2211">        assert(buffer.len &gt;= byte_count);</span>
<span class="line" id="L2212">        assert(x.fitsInTwosComp(<span class="tok-kw">if</span> (x.positive) .unsigned <span class="tok-kw">else</span> .signed, bit_count));</span>
<span class="line" id="L2213"></span>
<span class="line" id="L2214">        <span class="tok-comment">// Copy all complete limbs</span>
</span>
<span class="line" id="L2215">        <span class="tok-kw">var</span> carry: <span class="tok-type">u1</span> = <span class="tok-kw">if</span> (x.positive) <span class="tok-number">0</span> <span class="tok-kw">else</span> <span class="tok-number">1</span>;</span>
<span class="line" id="L2216">        <span class="tok-kw">var</span> limb_index: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L2217">        <span class="tok-kw">while</span> (limb_index &lt; byte_count / <span class="tok-builtin">@sizeOf</span>(Limb)) : (limb_index += <span class="tok-number">1</span>) {</span>
<span class="line" id="L2218">            <span class="tok-kw">var</span> buf_index = <span class="tok-kw">switch</span> (endian) {</span>
<span class="line" id="L2219">                .Little =&gt; <span class="tok-builtin">@sizeOf</span>(Limb) * limb_index,</span>
<span class="line" id="L2220">                .Big =&gt; abi_size - (limb_index + <span class="tok-number">1</span>) * <span class="tok-builtin">@sizeOf</span>(Limb),</span>
<span class="line" id="L2221">            };</span>
<span class="line" id="L2222"></span>
<span class="line" id="L2223">            <span class="tok-kw">var</span> limb: Limb = <span class="tok-kw">if</span> (limb_index &lt; x.limbs.len) x.limbs[limb_index] <span class="tok-kw">else</span> <span class="tok-number">0</span>;</span>
<span class="line" id="L2224">            <span class="tok-comment">// 2's complement (bitwise not, then add carry bit)</span>
</span>
<span class="line" id="L2225">            <span class="tok-kw">if</span> (!x.positive) carry = <span class="tok-builtin">@boolToInt</span>(<span class="tok-builtin">@addWithOverflow</span>(Limb, ~limb, carry, &amp;limb));</span>
<span class="line" id="L2226"></span>
<span class="line" id="L2227">            <span class="tok-kw">var</span> limb_buf = <span class="tok-builtin">@ptrCast</span>(*[<span class="tok-builtin">@sizeOf</span>(Limb)]<span class="tok-type">u8</span>, buffer[buf_index..]);</span>
<span class="line" id="L2228">            mem.writeInt(Limb, limb_buf, limb, endian);</span>
<span class="line" id="L2229">        }</span>
<span class="line" id="L2230"></span>
<span class="line" id="L2231">        <span class="tok-comment">// Copy the remaining N bytes (N &lt; @sizeOf(Limb))</span>
</span>
<span class="line" id="L2232">        <span class="tok-kw">var</span> bytes_written = limb_index * <span class="tok-builtin">@sizeOf</span>(Limb);</span>
<span class="line" id="L2233">        <span class="tok-kw">if</span> (bytes_written != byte_count) {</span>
<span class="line" id="L2234">            <span class="tok-kw">var</span> limb: Limb = <span class="tok-kw">if</span> (limb_index &lt; x.limbs.len) x.limbs[limb_index] <span class="tok-kw">else</span> <span class="tok-number">0</span>;</span>
<span class="line" id="L2235">            <span class="tok-comment">// 2's complement (bitwise not, then add carry bit)</span>
</span>
<span class="line" id="L2236">            <span class="tok-kw">if</span> (!x.positive) _ = <span class="tok-builtin">@addWithOverflow</span>(Limb, ~limb, carry, &amp;limb);</span>
<span class="line" id="L2237"></span>
<span class="line" id="L2238">            <span class="tok-kw">while</span> (bytes_written != byte_count) {</span>
<span class="line" id="L2239">                <span class="tok-kw">const</span> write_size = std.math.floorPowerOfTwo(<span class="tok-type">usize</span>, byte_count - bytes_written);</span>
<span class="line" id="L2240">                <span class="tok-kw">var</span> int_buffer = <span class="tok-kw">switch</span> (endian) {</span>
<span class="line" id="L2241">                    .Little =&gt; buffer[bytes_written..],</span>
<span class="line" id="L2242">                    .Big =&gt; buffer[(abi_size - bytes_written - write_size)..],</span>
<span class="line" id="L2243">                };</span>
<span class="line" id="L2244"></span>
<span class="line" id="L2245">                <span class="tok-kw">if</span> (write_size == <span class="tok-number">1</span>) {</span>
<span class="line" id="L2246">                    mem.writeInt(<span class="tok-type">u8</span>, int_buffer[<span class="tok-number">0</span>..<span class="tok-number">1</span>], <span class="tok-builtin">@truncate</span>(<span class="tok-type">u8</span>, limb), endian);</span>
<span class="line" id="L2247">                } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (<span class="tok-builtin">@sizeOf</span>(Limb) &gt;= <span class="tok-number">2</span> <span class="tok-kw">and</span> write_size == <span class="tok-number">2</span>) {</span>
<span class="line" id="L2248">                    mem.writeInt(<span class="tok-type">u16</span>, int_buffer[<span class="tok-number">0</span>..<span class="tok-number">2</span>], <span class="tok-builtin">@truncate</span>(<span class="tok-type">u16</span>, limb), endian);</span>
<span class="line" id="L2249">                } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (<span class="tok-builtin">@sizeOf</span>(Limb) &gt;= <span class="tok-number">4</span> <span class="tok-kw">and</span> write_size == <span class="tok-number">4</span>) {</span>
<span class="line" id="L2250">                    mem.writeInt(<span class="tok-type">u32</span>, int_buffer[<span class="tok-number">0</span>..<span class="tok-number">4</span>], <span class="tok-builtin">@truncate</span>(<span class="tok-type">u32</span>, limb), endian);</span>
<span class="line" id="L2251">                } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (<span class="tok-builtin">@sizeOf</span>(Limb) &gt;= <span class="tok-number">8</span> <span class="tok-kw">and</span> write_size == <span class="tok-number">8</span>) {</span>
<span class="line" id="L2252">                    mem.writeInt(<span class="tok-type">u64</span>, int_buffer[<span class="tok-number">0</span>..<span class="tok-number">8</span>], <span class="tok-builtin">@truncate</span>(<span class="tok-type">u64</span>, limb), endian);</span>
<span class="line" id="L2253">                } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (<span class="tok-builtin">@sizeOf</span>(Limb) &gt;= <span class="tok-number">16</span> <span class="tok-kw">and</span> write_size == <span class="tok-number">16</span>) {</span>
<span class="line" id="L2254">                    mem.writeInt(<span class="tok-type">u128</span>, int_buffer[<span class="tok-number">0</span>..<span class="tok-number">16</span>], <span class="tok-builtin">@truncate</span>(<span class="tok-type">u128</span>, limb), endian);</span>
<span class="line" id="L2255">                } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (<span class="tok-builtin">@sizeOf</span>(Limb) &gt;= <span class="tok-number">32</span>) {</span>
<span class="line" id="L2256">                    <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;@sizeOf(Limb) exceeded supported range&quot;</span>);</span>
<span class="line" id="L2257">                } <span class="tok-kw">else</span> <span class="tok-kw">unreachable</span>;</span>
<span class="line" id="L2258">                limb &gt;&gt;= <span class="tok-builtin">@intCast</span>(Log2Limb, <span class="tok-number">8</span> * write_size);</span>
<span class="line" id="L2259">                bytes_written += write_size;</span>
<span class="line" id="L2260">            }</span>
<span class="line" id="L2261">        }</span>
<span class="line" id="L2262">    }</span>
<span class="line" id="L2263"></span>
<span class="line" id="L2264">    <span class="tok-comment">/// Returns `math.Order.lt`, `math.Order.eq`, `math.Order.gt` if</span></span>
<span class="line" id="L2265">    <span class="tok-comment">/// `|a| &lt; |b|`, `|a| == |b|`, or `|a| &gt; |b|` respectively.</span></span>
<span class="line" id="L2266">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">orderAbs</span>(a: Const, b: Const) math.Order {</span>
<span class="line" id="L2267">        <span class="tok-kw">if</span> (a.limbs.len &lt; b.limbs.len) {</span>
<span class="line" id="L2268">            <span class="tok-kw">return</span> .lt;</span>
<span class="line" id="L2269">        }</span>
<span class="line" id="L2270">        <span class="tok-kw">if</span> (a.limbs.len &gt; b.limbs.len) {</span>
<span class="line" id="L2271">            <span class="tok-kw">return</span> .gt;</span>
<span class="line" id="L2272">        }</span>
<span class="line" id="L2273"></span>
<span class="line" id="L2274">        <span class="tok-kw">var</span> i: <span class="tok-type">usize</span> = a.limbs.len - <span class="tok-number">1</span>;</span>
<span class="line" id="L2275">        <span class="tok-kw">while</span> (i != <span class="tok-number">0</span>) : (i -= <span class="tok-number">1</span>) {</span>
<span class="line" id="L2276">            <span class="tok-kw">if</span> (a.limbs[i] != b.limbs[i]) {</span>
<span class="line" id="L2277">                <span class="tok-kw">break</span>;</span>
<span class="line" id="L2278">            }</span>
<span class="line" id="L2279">        }</span>
<span class="line" id="L2280"></span>
<span class="line" id="L2281">        <span class="tok-kw">if</span> (a.limbs[i] &lt; b.limbs[i]) {</span>
<span class="line" id="L2282">            <span class="tok-kw">return</span> .lt;</span>
<span class="line" id="L2283">        } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (a.limbs[i] &gt; b.limbs[i]) {</span>
<span class="line" id="L2284">            <span class="tok-kw">return</span> .gt;</span>
<span class="line" id="L2285">        } <span class="tok-kw">else</span> {</span>
<span class="line" id="L2286">            <span class="tok-kw">return</span> .eq;</span>
<span class="line" id="L2287">        }</span>
<span class="line" id="L2288">    }</span>
<span class="line" id="L2289"></span>
<span class="line" id="L2290">    <span class="tok-comment">/// Returns `math.Order.lt`, `math.Order.eq`, `math.Order.gt` if `a &lt; b`, `a == b` or `a &gt; b` respectively.</span></span>
<span class="line" id="L2291">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">order</span>(a: Const, b: Const) math.Order {</span>
<span class="line" id="L2292">        <span class="tok-kw">if</span> (a.positive != b.positive) {</span>
<span class="line" id="L2293">            <span class="tok-kw">return</span> <span class="tok-kw">if</span> (a.positive) .gt <span class="tok-kw">else</span> .lt;</span>
<span class="line" id="L2294">        } <span class="tok-kw">else</span> {</span>
<span class="line" id="L2295">            <span class="tok-kw">const</span> r = orderAbs(a, b);</span>
<span class="line" id="L2296">            <span class="tok-kw">return</span> <span class="tok-kw">if</span> (a.positive) r <span class="tok-kw">else</span> <span class="tok-kw">switch</span> (r) {</span>
<span class="line" id="L2297">                .lt =&gt; math.Order.gt,</span>
<span class="line" id="L2298">                .eq =&gt; math.Order.eq,</span>
<span class="line" id="L2299">                .gt =&gt; math.Order.lt,</span>
<span class="line" id="L2300">            };</span>
<span class="line" id="L2301">        }</span>
<span class="line" id="L2302">    }</span>
<span class="line" id="L2303"></span>
<span class="line" id="L2304">    <span class="tok-comment">/// Same as `order` but the right-hand operand is a primitive integer.</span></span>
<span class="line" id="L2305">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">orderAgainstScalar</span>(lhs: Const, scalar: <span class="tok-kw">anytype</span>) math.Order {</span>
<span class="line" id="L2306">        <span class="tok-kw">var</span> limbs: [calcLimbLen(scalar)]Limb = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L2307">        <span class="tok-kw">const</span> rhs = Mutable.init(&amp;limbs, scalar);</span>
<span class="line" id="L2308">        <span class="tok-kw">return</span> order(lhs, rhs.toConst());</span>
<span class="line" id="L2309">    }</span>
<span class="line" id="L2310"></span>
<span class="line" id="L2311">    <span class="tok-comment">/// Returns true if `a == 0`.</span></span>
<span class="line" id="L2312">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">eqZero</span>(a: Const) <span class="tok-type">bool</span> {</span>
<span class="line" id="L2313">        <span class="tok-kw">var</span> d: Limb = <span class="tok-number">0</span>;</span>
<span class="line" id="L2314">        <span class="tok-kw">for</span> (a.limbs) |limb| d |= limb;</span>
<span class="line" id="L2315">        <span class="tok-kw">return</span> d == <span class="tok-number">0</span>;</span>
<span class="line" id="L2316">    }</span>
<span class="line" id="L2317"></span>
<span class="line" id="L2318">    <span class="tok-comment">/// Returns true if `|a| == |b|`.</span></span>
<span class="line" id="L2319">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">eqAbs</span>(a: Const, b: Const) <span class="tok-type">bool</span> {</span>
<span class="line" id="L2320">        <span class="tok-kw">return</span> orderAbs(a, b) == .eq;</span>
<span class="line" id="L2321">    }</span>
<span class="line" id="L2322"></span>
<span class="line" id="L2323">    <span class="tok-comment">/// Returns true if `a == b`.</span></span>
<span class="line" id="L2324">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">eq</span>(a: Const, b: Const) <span class="tok-type">bool</span> {</span>
<span class="line" id="L2325">        <span class="tok-kw">return</span> order(a, b) == .eq;</span>
<span class="line" id="L2326">    }</span>
<span class="line" id="L2327">};</span>
<span class="line" id="L2328"></span>
<span class="line" id="L2329"><span class="tok-comment">/// An arbitrary-precision big integer along with an allocator which manages the memory.</span></span>
<span class="line" id="L2330"><span class="tok-comment">///</span></span>
<span class="line" id="L2331"><span class="tok-comment">/// Memory is allocated as needed to ensure operations never overflow. The range</span></span>
<span class="line" id="L2332"><span class="tok-comment">/// is bounded only by available memory.</span></span>
<span class="line" id="L2333"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> Managed = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L2334">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> sign_bit: <span class="tok-type">usize</span> = <span class="tok-number">1</span> &lt;&lt; (<span class="tok-builtin">@typeInfo</span>(<span class="tok-type">usize</span>).Int.bits - <span class="tok-number">1</span>);</span>
<span class="line" id="L2335"></span>
<span class="line" id="L2336">    <span class="tok-comment">/// Default number of limbs to allocate on creation of a `Managed`.</span></span>
<span class="line" id="L2337">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> default_capacity = <span class="tok-number">4</span>;</span>
<span class="line" id="L2338"></span>
<span class="line" id="L2339">    <span class="tok-comment">/// Allocator used by the Managed when requesting memory.</span></span>
<span class="line" id="L2340">    allocator: Allocator,</span>
<span class="line" id="L2341"></span>
<span class="line" id="L2342">    <span class="tok-comment">/// Raw digits. These are:</span></span>
<span class="line" id="L2343">    <span class="tok-comment">///</span></span>
<span class="line" id="L2344">    <span class="tok-comment">/// * Little-endian ordered</span></span>
<span class="line" id="L2345">    <span class="tok-comment">/// * limbs.len &gt;= 1</span></span>
<span class="line" id="L2346">    <span class="tok-comment">/// * Zero is represent as Managed.len() == 1 with limbs[0] == 0.</span></span>
<span class="line" id="L2347">    <span class="tok-comment">///</span></span>
<span class="line" id="L2348">    <span class="tok-comment">/// Accessing limbs directly should be avoided.</span></span>
<span class="line" id="L2349">    limbs: []Limb,</span>
<span class="line" id="L2350"></span>
<span class="line" id="L2351">    <span class="tok-comment">/// High bit is the sign bit. If set, Managed is negative, else Managed is positive.</span></span>
<span class="line" id="L2352">    <span class="tok-comment">/// The remaining bits represent the number of limbs used by Managed.</span></span>
<span class="line" id="L2353">    metadata: <span class="tok-type">usize</span>,</span>
<span class="line" id="L2354"></span>
<span class="line" id="L2355">    <span class="tok-comment">/// Creates a new `Managed`. `default_capacity` limbs will be allocated immediately.</span></span>
<span class="line" id="L2356">    <span class="tok-comment">/// The integer value after initializing is `0`.</span></span>
<span class="line" id="L2357">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">init</span>(allocator: Allocator) !Managed {</span>
<span class="line" id="L2358">        <span class="tok-kw">return</span> initCapacity(allocator, default_capacity);</span>
<span class="line" id="L2359">    }</span>
<span class="line" id="L2360"></span>
<span class="line" id="L2361">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">toMutable</span>(self: Managed) Mutable {</span>
<span class="line" id="L2362">        <span class="tok-kw">return</span> .{</span>
<span class="line" id="L2363">            .limbs = self.limbs,</span>
<span class="line" id="L2364">            .positive = self.isPositive(),</span>
<span class="line" id="L2365">            .len = self.len(),</span>
<span class="line" id="L2366">        };</span>
<span class="line" id="L2367">    }</span>
<span class="line" id="L2368"></span>
<span class="line" id="L2369">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">toConst</span>(self: Managed) Const {</span>
<span class="line" id="L2370">        <span class="tok-kw">return</span> .{</span>
<span class="line" id="L2371">            .limbs = self.limbs[<span class="tok-number">0</span>..self.len()],</span>
<span class="line" id="L2372">            .positive = self.isPositive(),</span>
<span class="line" id="L2373">        };</span>
<span class="line" id="L2374">    }</span>
<span class="line" id="L2375"></span>
<span class="line" id="L2376">    <span class="tok-comment">/// Creates a new `Managed` with value `value`.</span></span>
<span class="line" id="L2377">    <span class="tok-comment">///</span></span>
<span class="line" id="L2378">    <span class="tok-comment">/// This is identical to an `init`, followed by a `set`.</span></span>
<span class="line" id="L2379">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">initSet</span>(allocator: Allocator, value: <span class="tok-kw">anytype</span>) !Managed {</span>
<span class="line" id="L2380">        <span class="tok-kw">var</span> s = <span class="tok-kw">try</span> Managed.init(allocator);</span>
<span class="line" id="L2381">        <span class="tok-kw">try</span> s.set(value);</span>
<span class="line" id="L2382">        <span class="tok-kw">return</span> s;</span>
<span class="line" id="L2383">    }</span>
<span class="line" id="L2384"></span>
<span class="line" id="L2385">    <span class="tok-comment">/// Creates a new Managed with a specific capacity. If capacity &lt; default_capacity then the</span></span>
<span class="line" id="L2386">    <span class="tok-comment">/// default capacity will be used instead.</span></span>
<span class="line" id="L2387">    <span class="tok-comment">/// The integer value after initializing is `0`.</span></span>
<span class="line" id="L2388">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">initCapacity</span>(allocator: Allocator, capacity: <span class="tok-type">usize</span>) !Managed {</span>
<span class="line" id="L2389">        <span class="tok-kw">return</span> Managed{</span>
<span class="line" id="L2390">            .allocator = allocator,</span>
<span class="line" id="L2391">            .metadata = <span class="tok-number">1</span>,</span>
<span class="line" id="L2392">            .limbs = block: {</span>
<span class="line" id="L2393">                <span class="tok-kw">const</span> limbs = <span class="tok-kw">try</span> allocator.alloc(Limb, math.max(default_capacity, capacity));</span>
<span class="line" id="L2394">                limbs[<span class="tok-number">0</span>] = <span class="tok-number">0</span>;</span>
<span class="line" id="L2395">                <span class="tok-kw">break</span> :block limbs;</span>
<span class="line" id="L2396">            },</span>
<span class="line" id="L2397">        };</span>
<span class="line" id="L2398">    }</span>
<span class="line" id="L2399"></span>
<span class="line" id="L2400">    <span class="tok-comment">/// Returns the number of limbs currently in use.</span></span>
<span class="line" id="L2401">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">len</span>(self: Managed) <span class="tok-type">usize</span> {</span>
<span class="line" id="L2402">        <span class="tok-kw">return</span> self.metadata &amp; ~sign_bit;</span>
<span class="line" id="L2403">    }</span>
<span class="line" id="L2404"></span>
<span class="line" id="L2405">    <span class="tok-comment">/// Returns whether an Managed is positive.</span></span>
<span class="line" id="L2406">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">isPositive</span>(self: Managed) <span class="tok-type">bool</span> {</span>
<span class="line" id="L2407">        <span class="tok-kw">return</span> self.metadata &amp; sign_bit == <span class="tok-number">0</span>;</span>
<span class="line" id="L2408">    }</span>
<span class="line" id="L2409"></span>
<span class="line" id="L2410">    <span class="tok-comment">/// Sets the sign of an Managed.</span></span>
<span class="line" id="L2411">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">setSign</span>(self: *Managed, positive: <span class="tok-type">bool</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L2412">        <span class="tok-kw">if</span> (positive) {</span>
<span class="line" id="L2413">            self.metadata &amp;= ~sign_bit;</span>
<span class="line" id="L2414">        } <span class="tok-kw">else</span> {</span>
<span class="line" id="L2415">            self.metadata |= sign_bit;</span>
<span class="line" id="L2416">        }</span>
<span class="line" id="L2417">    }</span>
<span class="line" id="L2418"></span>
<span class="line" id="L2419">    <span class="tok-comment">/// Sets the length of an Managed.</span></span>
<span class="line" id="L2420">    <span class="tok-comment">///</span></span>
<span class="line" id="L2421">    <span class="tok-comment">/// If setLen is used, then the Managed must be normalized to suit.</span></span>
<span class="line" id="L2422">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">setLen</span>(self: *Managed, new_len: <span class="tok-type">usize</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L2423">        self.metadata &amp;= sign_bit;</span>
<span class="line" id="L2424">        self.metadata |= new_len;</span>
<span class="line" id="L2425">    }</span>
<span class="line" id="L2426"></span>
<span class="line" id="L2427">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">setMetadata</span>(self: *Managed, positive: <span class="tok-type">bool</span>, length: <span class="tok-type">usize</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L2428">        self.metadata = <span class="tok-kw">if</span> (positive) length &amp; ~sign_bit <span class="tok-kw">else</span> length | sign_bit;</span>
<span class="line" id="L2429">    }</span>
<span class="line" id="L2430"></span>
<span class="line" id="L2431">    <span class="tok-comment">/// Ensures an Managed has enough space allocated for capacity limbs. If the Managed does not have</span></span>
<span class="line" id="L2432">    <span class="tok-comment">/// sufficient capacity, the exact amount will be allocated. This occurs even if the requested</span></span>
<span class="line" id="L2433">    <span class="tok-comment">/// capacity is only greater than the current capacity by one limb.</span></span>
<span class="line" id="L2434">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">ensureCapacity</span>(self: *Managed, capacity: <span class="tok-type">usize</span>) !<span class="tok-type">void</span> {</span>
<span class="line" id="L2435">        <span class="tok-kw">if</span> (capacity &lt;= self.limbs.len) {</span>
<span class="line" id="L2436">            <span class="tok-kw">return</span>;</span>
<span class="line" id="L2437">        }</span>
<span class="line" id="L2438">        self.limbs = <span class="tok-kw">try</span> self.allocator.realloc(self.limbs, capacity);</span>
<span class="line" id="L2439">    }</span>
<span class="line" id="L2440"></span>
<span class="line" id="L2441">    <span class="tok-comment">/// Frees all associated memory.</span></span>
<span class="line" id="L2442">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">deinit</span>(self: *Managed) <span class="tok-type">void</span> {</span>
<span class="line" id="L2443">        self.allocator.free(self.limbs);</span>
<span class="line" id="L2444">        self.* = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L2445">    }</span>
<span class="line" id="L2446"></span>
<span class="line" id="L2447">    <span class="tok-comment">/// Returns a `Managed` with the same value. The returned `Managed` is a deep copy and</span></span>
<span class="line" id="L2448">    <span class="tok-comment">/// can be modified separately from the original, and its resources are managed</span></span>
<span class="line" id="L2449">    <span class="tok-comment">/// separately from the original.</span></span>
<span class="line" id="L2450">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">clone</span>(other: Managed) !Managed {</span>
<span class="line" id="L2451">        <span class="tok-kw">return</span> other.cloneWithDifferentAllocator(other.allocator);</span>
<span class="line" id="L2452">    }</span>
<span class="line" id="L2453"></span>
<span class="line" id="L2454">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">cloneWithDifferentAllocator</span>(other: Managed, allocator: Allocator) !Managed {</span>
<span class="line" id="L2455">        <span class="tok-kw">return</span> Managed{</span>
<span class="line" id="L2456">            .allocator = allocator,</span>
<span class="line" id="L2457">            .metadata = other.metadata,</span>
<span class="line" id="L2458">            .limbs = block: {</span>
<span class="line" id="L2459">                <span class="tok-kw">var</span> limbs = <span class="tok-kw">try</span> allocator.alloc(Limb, other.len());</span>
<span class="line" id="L2460">                mem.copy(Limb, limbs[<span class="tok-number">0</span>..], other.limbs[<span class="tok-number">0</span>..other.len()]);</span>
<span class="line" id="L2461">                <span class="tok-kw">break</span> :block limbs;</span>
<span class="line" id="L2462">            },</span>
<span class="line" id="L2463">        };</span>
<span class="line" id="L2464">    }</span>
<span class="line" id="L2465"></span>
<span class="line" id="L2466">    <span class="tok-comment">/// Copies the value of the integer to an existing `Managed` so that they both have the same value.</span></span>
<span class="line" id="L2467">    <span class="tok-comment">/// Extra memory will be allocated if the receiver does not have enough capacity.</span></span>
<span class="line" id="L2468">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">copy</span>(self: *Managed, other: Const) !<span class="tok-type">void</span> {</span>
<span class="line" id="L2469">        <span class="tok-kw">if</span> (self.limbs.ptr == other.limbs.ptr) <span class="tok-kw">return</span>;</span>
<span class="line" id="L2470"></span>
<span class="line" id="L2471">        <span class="tok-kw">try</span> self.ensureCapacity(other.limbs.len);</span>
<span class="line" id="L2472">        mem.copy(Limb, self.limbs[<span class="tok-number">0</span>..], other.limbs[<span class="tok-number">0</span>..other.limbs.len]);</span>
<span class="line" id="L2473">        self.setMetadata(other.positive, other.limbs.len);</span>
<span class="line" id="L2474">    }</span>
<span class="line" id="L2475"></span>
<span class="line" id="L2476">    <span class="tok-comment">/// Efficiently swap a `Managed` with another. This swaps the limb pointers and a full copy is not</span></span>
<span class="line" id="L2477">    <span class="tok-comment">/// performed. The address of the limbs field will not be the same after this function.</span></span>
<span class="line" id="L2478">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">swap</span>(self: *Managed, other: *Managed) <span class="tok-type">void</span> {</span>
<span class="line" id="L2479">        mem.swap(Managed, self, other);</span>
<span class="line" id="L2480">    }</span>
<span class="line" id="L2481"></span>
<span class="line" id="L2482">    <span class="tok-comment">/// Debugging tool: prints the state to stderr.</span></span>
<span class="line" id="L2483">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">dump</span>(self: Managed) <span class="tok-type">void</span> {</span>
<span class="line" id="L2484">        <span class="tok-kw">for</span> (self.limbs[<span class="tok-number">0</span>..self.len()]) |limb| {</span>
<span class="line" id="L2485">            std.debug.print(<span class="tok-str">&quot;{x} &quot;</span>, .{limb});</span>
<span class="line" id="L2486">        }</span>
<span class="line" id="L2487">        std.debug.print(<span class="tok-str">&quot;capacity={} positive={}\n&quot;</span>, .{ self.limbs.len, self.isPositive() });</span>
<span class="line" id="L2488">    }</span>
<span class="line" id="L2489"></span>
<span class="line" id="L2490">    <span class="tok-comment">/// Negate the sign.</span></span>
<span class="line" id="L2491">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">negate</span>(self: *Managed) <span class="tok-type">void</span> {</span>
<span class="line" id="L2492">        self.metadata ^= sign_bit;</span>
<span class="line" id="L2493">    }</span>
<span class="line" id="L2494"></span>
<span class="line" id="L2495">    <span class="tok-comment">/// Make positive.</span></span>
<span class="line" id="L2496">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">abs</span>(self: *Managed) <span class="tok-type">void</span> {</span>
<span class="line" id="L2497">        self.metadata &amp;= ~sign_bit;</span>
<span class="line" id="L2498">    }</span>
<span class="line" id="L2499"></span>
<span class="line" id="L2500">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">isOdd</span>(self: Managed) <span class="tok-type">bool</span> {</span>
<span class="line" id="L2501">        <span class="tok-kw">return</span> self.limbs[<span class="tok-number">0</span>] &amp; <span class="tok-number">1</span> != <span class="tok-number">0</span>;</span>
<span class="line" id="L2502">    }</span>
<span class="line" id="L2503"></span>
<span class="line" id="L2504">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">isEven</span>(self: Managed) <span class="tok-type">bool</span> {</span>
<span class="line" id="L2505">        <span class="tok-kw">return</span> !self.isOdd();</span>
<span class="line" id="L2506">    }</span>
<span class="line" id="L2507"></span>
<span class="line" id="L2508">    <span class="tok-comment">/// Returns the number of bits required to represent the absolute value of an integer.</span></span>
<span class="line" id="L2509">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">bitCountAbs</span>(self: Managed) <span class="tok-type">usize</span> {</span>
<span class="line" id="L2510">        <span class="tok-kw">return</span> self.toConst().bitCountAbs();</span>
<span class="line" id="L2511">    }</span>
<span class="line" id="L2512"></span>
<span class="line" id="L2513">    <span class="tok-comment">/// Returns the number of bits required to represent the integer in twos-complement form.</span></span>
<span class="line" id="L2514">    <span class="tok-comment">///</span></span>
<span class="line" id="L2515">    <span class="tok-comment">/// If the integer is negative the value returned is the number of bits needed by a signed</span></span>
<span class="line" id="L2516">    <span class="tok-comment">/// integer to represent the value. If positive the value is the number of bits for an</span></span>
<span class="line" id="L2517">    <span class="tok-comment">/// unsigned integer. Any unsigned integer will fit in the signed integer with bitcount</span></span>
<span class="line" id="L2518">    <span class="tok-comment">/// one greater than the returned value.</span></span>
<span class="line" id="L2519">    <span class="tok-comment">///</span></span>
<span class="line" id="L2520">    <span class="tok-comment">/// e.g. -127 returns 8 as it will fit in an i8. 127 returns 7 since it fits in a u7.</span></span>
<span class="line" id="L2521">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">bitCountTwosComp</span>(self: Managed) <span class="tok-type">usize</span> {</span>
<span class="line" id="L2522">        <span class="tok-kw">return</span> self.toConst().bitCountTwosComp();</span>
<span class="line" id="L2523">    }</span>
<span class="line" id="L2524"></span>
<span class="line" id="L2525">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">fitsInTwosComp</span>(self: Managed, signedness: Signedness, bit_count: <span class="tok-type">usize</span>) <span class="tok-type">bool</span> {</span>
<span class="line" id="L2526">        <span class="tok-kw">return</span> self.toConst().fitsInTwosComp(signedness, bit_count);</span>
<span class="line" id="L2527">    }</span>
<span class="line" id="L2528"></span>
<span class="line" id="L2529">    <span class="tok-comment">/// Returns whether self can fit into an integer of the requested type.</span></span>
<span class="line" id="L2530">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">fits</span>(self: Managed, <span class="tok-kw">comptime</span> T: <span class="tok-type">type</span>) <span class="tok-type">bool</span> {</span>
<span class="line" id="L2531">        <span class="tok-kw">return</span> self.toConst().fits(T);</span>
<span class="line" id="L2532">    }</span>
<span class="line" id="L2533"></span>
<span class="line" id="L2534">    <span class="tok-comment">/// Returns the approximate size of the integer in the given base. Negative values accommodate for</span></span>
<span class="line" id="L2535">    <span class="tok-comment">/// the minus sign. This is used for determining the number of characters needed to print the</span></span>
<span class="line" id="L2536">    <span class="tok-comment">/// value. It is inexact and may exceed the given value by ~1-2 bytes.</span></span>
<span class="line" id="L2537">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">sizeInBaseUpperBound</span>(self: Managed, base: <span class="tok-type">usize</span>) <span class="tok-type">usize</span> {</span>
<span class="line" id="L2538">        <span class="tok-kw">return</span> self.toConst().sizeInBaseUpperBound(base);</span>
<span class="line" id="L2539">    }</span>
<span class="line" id="L2540"></span>
<span class="line" id="L2541">    <span class="tok-comment">/// Sets an Managed to value. Value must be an primitive integer type.</span></span>
<span class="line" id="L2542">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">set</span>(self: *Managed, value: <span class="tok-kw">anytype</span>) Allocator.Error!<span class="tok-type">void</span> {</span>
<span class="line" id="L2543">        <span class="tok-kw">try</span> self.ensureCapacity(calcLimbLen(value));</span>
<span class="line" id="L2544">        <span class="tok-kw">var</span> m = self.toMutable();</span>
<span class="line" id="L2545">        m.set(value);</span>
<span class="line" id="L2546">        self.setMetadata(m.positive, m.len);</span>
<span class="line" id="L2547">    }</span>
<span class="line" id="L2548"></span>
<span class="line" id="L2549">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> ConvertError = Const.ConvertError;</span>
<span class="line" id="L2550"></span>
<span class="line" id="L2551">    <span class="tok-comment">/// Convert self to type T.</span></span>
<span class="line" id="L2552">    <span class="tok-comment">///</span></span>
<span class="line" id="L2553">    <span class="tok-comment">/// Returns an error if self cannot be narrowed into the requested type without truncation.</span></span>
<span class="line" id="L2554">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">to</span>(self: Managed, <span class="tok-kw">comptime</span> T: <span class="tok-type">type</span>) ConvertError!T {</span>
<span class="line" id="L2555">        <span class="tok-kw">return</span> self.toConst().to(T);</span>
<span class="line" id="L2556">    }</span>
<span class="line" id="L2557"></span>
<span class="line" id="L2558">    <span class="tok-comment">/// Set self from the string representation `value`.</span></span>
<span class="line" id="L2559">    <span class="tok-comment">///</span></span>
<span class="line" id="L2560">    <span class="tok-comment">/// `value` must contain only digits &lt;= `base` and is case insensitive.  Base prefixes are</span></span>
<span class="line" id="L2561">    <span class="tok-comment">/// not allowed (e.g. 0x43 should simply be 43).  Underscores in the input string are</span></span>
<span class="line" id="L2562">    <span class="tok-comment">/// ignored and can be used as digit separators.</span></span>
<span class="line" id="L2563">    <span class="tok-comment">///</span></span>
<span class="line" id="L2564">    <span class="tok-comment">/// Returns an error if memory could not be allocated or `value` has invalid digits for the</span></span>
<span class="line" id="L2565">    <span class="tok-comment">/// requested base.</span></span>
<span class="line" id="L2566">    <span class="tok-comment">///</span></span>
<span class="line" id="L2567">    <span class="tok-comment">/// self's allocator is used for temporary storage to boost multiplication performance.</span></span>
<span class="line" id="L2568">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">setString</span>(self: *Managed, base: <span class="tok-type">u8</span>, value: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) !<span class="tok-type">void</span> {</span>
<span class="line" id="L2569">        <span class="tok-kw">if</span> (base &lt; <span class="tok-number">2</span> <span class="tok-kw">or</span> base &gt; <span class="tok-number">16</span>) <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InvalidBase;</span>
<span class="line" id="L2570">        <span class="tok-kw">try</span> self.ensureCapacity(calcSetStringLimbCount(base, value.len));</span>
<span class="line" id="L2571">        <span class="tok-kw">const</span> limbs_buffer = <span class="tok-kw">try</span> self.allocator.alloc(Limb, calcSetStringLimbsBufferLen(base, value.len));</span>
<span class="line" id="L2572">        <span class="tok-kw">defer</span> self.allocator.free(limbs_buffer);</span>
<span class="line" id="L2573">        <span class="tok-kw">var</span> m = self.toMutable();</span>
<span class="line" id="L2574">        <span class="tok-kw">try</span> m.setString(base, value, limbs_buffer, self.allocator);</span>
<span class="line" id="L2575">        self.setMetadata(m.positive, m.len);</span>
<span class="line" id="L2576">    }</span>
<span class="line" id="L2577"></span>
<span class="line" id="L2578">    <span class="tok-comment">/// Set self to either bound of a 2s-complement integer.</span></span>
<span class="line" id="L2579">    <span class="tok-comment">/// Note: The result is still sign-magnitude, not twos complement! In order to convert the</span></span>
<span class="line" id="L2580">    <span class="tok-comment">/// result to twos complement, it is sufficient to take the absolute value.</span></span>
<span class="line" id="L2581">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">setTwosCompIntLimit</span>(</span>
<span class="line" id="L2582">        r: *Managed,</span>
<span class="line" id="L2583">        limit: TwosCompIntLimit,</span>
<span class="line" id="L2584">        signedness: Signedness,</span>
<span class="line" id="L2585">        bit_count: <span class="tok-type">usize</span>,</span>
<span class="line" id="L2586">    ) !<span class="tok-type">void</span> {</span>
<span class="line" id="L2587">        <span class="tok-kw">try</span> r.ensureCapacity(calcTwosCompLimbCount(bit_count));</span>
<span class="line" id="L2588">        <span class="tok-kw">var</span> m = r.toMutable();</span>
<span class="line" id="L2589">        m.setTwosCompIntLimit(limit, signedness, bit_count);</span>
<span class="line" id="L2590">        r.setMetadata(m.positive, m.len);</span>
<span class="line" id="L2591">    }</span>
<span class="line" id="L2592"></span>
<span class="line" id="L2593">    <span class="tok-comment">/// Converts self to a string in the requested base. Memory is allocated from the provided</span></span>
<span class="line" id="L2594">    <span class="tok-comment">/// allocator and not the one present in self.</span></span>
<span class="line" id="L2595">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">toString</span>(self: Managed, allocator: Allocator, base: <span class="tok-type">u8</span>, case: std.fmt.Case) ![]<span class="tok-type">u8</span> {</span>
<span class="line" id="L2596">        <span class="tok-kw">if</span> (base &lt; <span class="tok-number">2</span> <span class="tok-kw">or</span> base &gt; <span class="tok-number">16</span>) <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InvalidBase;</span>
<span class="line" id="L2597">        <span class="tok-kw">return</span> self.toConst().toStringAlloc(allocator, base, case);</span>
<span class="line" id="L2598">    }</span>
<span class="line" id="L2599"></span>
<span class="line" id="L2600">    <span class="tok-comment">/// To allow `std.fmt.format` to work with `Managed`.</span></span>
<span class="line" id="L2601">    <span class="tok-comment">/// If the integer is larger than `pow(2, 64 * @sizeOf(usize) * 8), this function will fail</span></span>
<span class="line" id="L2602">    <span class="tok-comment">/// to print the string, printing &quot;(BigInt)&quot; instead of a number.</span></span>
<span class="line" id="L2603">    <span class="tok-comment">/// This is because the rendering algorithm requires reversing a string, which requires O(N) memory.</span></span>
<span class="line" id="L2604">    <span class="tok-comment">/// See `toString` and `toStringAlloc` for a way to print big integers without failure.</span></span>
<span class="line" id="L2605">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">format</span>(</span>
<span class="line" id="L2606">        self: Managed,</span>
<span class="line" id="L2607">        <span class="tok-kw">comptime</span> fmt: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L2608">        options: std.fmt.FormatOptions,</span>
<span class="line" id="L2609">        out_stream: <span class="tok-kw">anytype</span>,</span>
<span class="line" id="L2610">    ) !<span class="tok-type">void</span> {</span>
<span class="line" id="L2611">        <span class="tok-kw">return</span> self.toConst().format(fmt, options, out_stream);</span>
<span class="line" id="L2612">    }</span>
<span class="line" id="L2613"></span>
<span class="line" id="L2614">    <span class="tok-comment">/// Returns math.Order.lt, math.Order.eq, math.Order.gt if |a| &lt; |b|, |a| ==</span></span>
<span class="line" id="L2615">    <span class="tok-comment">/// |b| or |a| &gt; |b| respectively.</span></span>
<span class="line" id="L2616">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">orderAbs</span>(a: Managed, b: Managed) math.Order {</span>
<span class="line" id="L2617">        <span class="tok-kw">return</span> a.toConst().orderAbs(b.toConst());</span>
<span class="line" id="L2618">    }</span>
<span class="line" id="L2619"></span>
<span class="line" id="L2620">    <span class="tok-comment">/// Returns math.Order.lt, math.Order.eq, math.Order.gt if a &lt; b, a == b or a</span></span>
<span class="line" id="L2621">    <span class="tok-comment">/// &gt; b respectively.</span></span>
<span class="line" id="L2622">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">order</span>(a: Managed, b: Managed) math.Order {</span>
<span class="line" id="L2623">        <span class="tok-kw">return</span> a.toConst().order(b.toConst());</span>
<span class="line" id="L2624">    }</span>
<span class="line" id="L2625"></span>
<span class="line" id="L2626">    <span class="tok-comment">/// Returns true if a == 0.</span></span>
<span class="line" id="L2627">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">eqZero</span>(a: Managed) <span class="tok-type">bool</span> {</span>
<span class="line" id="L2628">        <span class="tok-kw">return</span> a.toConst().eqZero();</span>
<span class="line" id="L2629">    }</span>
<span class="line" id="L2630"></span>
<span class="line" id="L2631">    <span class="tok-comment">/// Returns true if |a| == |b|.</span></span>
<span class="line" id="L2632">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">eqAbs</span>(a: Managed, b: Managed) <span class="tok-type">bool</span> {</span>
<span class="line" id="L2633">        <span class="tok-kw">return</span> a.toConst().eqAbs(b.toConst());</span>
<span class="line" id="L2634">    }</span>
<span class="line" id="L2635"></span>
<span class="line" id="L2636">    <span class="tok-comment">/// Returns true if a == b.</span></span>
<span class="line" id="L2637">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">eq</span>(a: Managed, b: Managed) <span class="tok-type">bool</span> {</span>
<span class="line" id="L2638">        <span class="tok-kw">return</span> a.toConst().eq(b.toConst());</span>
<span class="line" id="L2639">    }</span>
<span class="line" id="L2640"></span>
<span class="line" id="L2641">    <span class="tok-comment">/// Normalize a possible sequence of leading zeros.</span></span>
<span class="line" id="L2642">    <span class="tok-comment">///</span></span>
<span class="line" id="L2643">    <span class="tok-comment">/// [1, 2, 3, 4, 0] -&gt; [1, 2, 3, 4]</span></span>
<span class="line" id="L2644">    <span class="tok-comment">/// [1, 2, 0, 0, 0] -&gt; [1, 2]</span></span>
<span class="line" id="L2645">    <span class="tok-comment">/// [0, 0, 0, 0, 0] -&gt; [0]</span></span>
<span class="line" id="L2646">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">normalize</span>(r: *Managed, length: <span class="tok-type">usize</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L2647">        assert(length &gt; <span class="tok-number">0</span>);</span>
<span class="line" id="L2648">        assert(length &lt;= r.limbs.len);</span>
<span class="line" id="L2649"></span>
<span class="line" id="L2650">        <span class="tok-kw">var</span> j = length;</span>
<span class="line" id="L2651">        <span class="tok-kw">while</span> (j &gt; <span class="tok-number">0</span>) : (j -= <span class="tok-number">1</span>) {</span>
<span class="line" id="L2652">            <span class="tok-kw">if</span> (r.limbs[j - <span class="tok-number">1</span>] != <span class="tok-number">0</span>) {</span>
<span class="line" id="L2653">                <span class="tok-kw">break</span>;</span>
<span class="line" id="L2654">            }</span>
<span class="line" id="L2655">        }</span>
<span class="line" id="L2656"></span>
<span class="line" id="L2657">        <span class="tok-comment">// Handle zero</span>
</span>
<span class="line" id="L2658">        r.setLen(<span class="tok-kw">if</span> (j != <span class="tok-number">0</span>) j <span class="tok-kw">else</span> <span class="tok-number">1</span>);</span>
<span class="line" id="L2659">    }</span>
<span class="line" id="L2660"></span>
<span class="line" id="L2661">    <span class="tok-comment">/// r = a + scalar</span></span>
<span class="line" id="L2662">    <span class="tok-comment">///</span></span>
<span class="line" id="L2663">    <span class="tok-comment">/// r and a may be aliases.</span></span>
<span class="line" id="L2664">    <span class="tok-comment">///</span></span>
<span class="line" id="L2665">    <span class="tok-comment">/// Returns an error if memory could not be allocated.</span></span>
<span class="line" id="L2666">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">addScalar</span>(r: *Managed, a: *<span class="tok-kw">const</span> Managed, scalar: <span class="tok-kw">anytype</span>) Allocator.Error!<span class="tok-type">void</span> {</span>
<span class="line" id="L2667">        <span class="tok-kw">try</span> r.ensureAddScalarCapacity(a.toConst(), scalar);</span>
<span class="line" id="L2668">        <span class="tok-kw">var</span> m = r.toMutable();</span>
<span class="line" id="L2669">        m.addScalar(a.toConst(), scalar);</span>
<span class="line" id="L2670">        r.setMetadata(m.positive, m.len);</span>
<span class="line" id="L2671">    }</span>
<span class="line" id="L2672"></span>
<span class="line" id="L2673">    <span class="tok-comment">/// r = a + b</span></span>
<span class="line" id="L2674">    <span class="tok-comment">///</span></span>
<span class="line" id="L2675">    <span class="tok-comment">/// r, a and b may be aliases.</span></span>
<span class="line" id="L2676">    <span class="tok-comment">///</span></span>
<span class="line" id="L2677">    <span class="tok-comment">/// Returns an error if memory could not be allocated.</span></span>
<span class="line" id="L2678">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">add</span>(r: *Managed, a: *<span class="tok-kw">const</span> Managed, b: *<span class="tok-kw">const</span> Managed) Allocator.Error!<span class="tok-type">void</span> {</span>
<span class="line" id="L2679">        <span class="tok-kw">try</span> r.ensureAddCapacity(a.toConst(), b.toConst());</span>
<span class="line" id="L2680">        <span class="tok-kw">var</span> m = r.toMutable();</span>
<span class="line" id="L2681">        m.add(a.toConst(), b.toConst());</span>
<span class="line" id="L2682">        r.setMetadata(m.positive, m.len);</span>
<span class="line" id="L2683">    }</span>
<span class="line" id="L2684"></span>
<span class="line" id="L2685">    <span class="tok-comment">/// r = a + b with 2s-complement wrapping semantics. Returns whether any overflow occured.</span></span>
<span class="line" id="L2686">    <span class="tok-comment">///</span></span>
<span class="line" id="L2687">    <span class="tok-comment">/// r, a and b may be aliases.</span></span>
<span class="line" id="L2688">    <span class="tok-comment">///</span></span>
<span class="line" id="L2689">    <span class="tok-comment">/// Returns an error if memory could not be allocated.</span></span>
<span class="line" id="L2690">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">addWrap</span>(</span>
<span class="line" id="L2691">        r: *Managed,</span>
<span class="line" id="L2692">        a: *<span class="tok-kw">const</span> Managed,</span>
<span class="line" id="L2693">        b: *<span class="tok-kw">const</span> Managed,</span>
<span class="line" id="L2694">        signedness: Signedness,</span>
<span class="line" id="L2695">        bit_count: <span class="tok-type">usize</span>,</span>
<span class="line" id="L2696">    ) Allocator.Error!<span class="tok-type">bool</span> {</span>
<span class="line" id="L2697">        <span class="tok-kw">try</span> r.ensureTwosCompCapacity(bit_count);</span>
<span class="line" id="L2698">        <span class="tok-kw">var</span> m = r.toMutable();</span>
<span class="line" id="L2699">        <span class="tok-kw">const</span> wrapped = m.addWrap(a.toConst(), b.toConst(), signedness, bit_count);</span>
<span class="line" id="L2700">        r.setMetadata(m.positive, m.len);</span>
<span class="line" id="L2701">        <span class="tok-kw">return</span> wrapped;</span>
<span class="line" id="L2702">    }</span>
<span class="line" id="L2703"></span>
<span class="line" id="L2704">    <span class="tok-comment">/// r = a + b with 2s-complement saturating semantics.</span></span>
<span class="line" id="L2705">    <span class="tok-comment">///</span></span>
<span class="line" id="L2706">    <span class="tok-comment">/// r, a and b may be aliases.</span></span>
<span class="line" id="L2707">    <span class="tok-comment">///</span></span>
<span class="line" id="L2708">    <span class="tok-comment">/// Returns an error if memory could not be allocated.</span></span>
<span class="line" id="L2709">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">addSat</span>(r: *Managed, a: *<span class="tok-kw">const</span> Managed, b: *<span class="tok-kw">const</span> Managed, signedness: Signedness, bit_count: <span class="tok-type">usize</span>) Allocator.Error!<span class="tok-type">void</span> {</span>
<span class="line" id="L2710">        <span class="tok-kw">try</span> r.ensureTwosCompCapacity(bit_count);</span>
<span class="line" id="L2711">        <span class="tok-kw">var</span> m = r.toMutable();</span>
<span class="line" id="L2712">        m.addSat(a.toConst(), b.toConst(), signedness, bit_count);</span>
<span class="line" id="L2713">        r.setMetadata(m.positive, m.len);</span>
<span class="line" id="L2714">    }</span>
<span class="line" id="L2715"></span>
<span class="line" id="L2716">    <span class="tok-comment">/// r = a - b</span></span>
<span class="line" id="L2717">    <span class="tok-comment">///</span></span>
<span class="line" id="L2718">    <span class="tok-comment">/// r, a and b may be aliases.</span></span>
<span class="line" id="L2719">    <span class="tok-comment">///</span></span>
<span class="line" id="L2720">    <span class="tok-comment">/// Returns an error if memory could not be allocated.</span></span>
<span class="line" id="L2721">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">sub</span>(r: *Managed, a: *<span class="tok-kw">const</span> Managed, b: *<span class="tok-kw">const</span> Managed) !<span class="tok-type">void</span> {</span>
<span class="line" id="L2722">        <span class="tok-kw">try</span> r.ensureCapacity(math.max(a.len(), b.len()) + <span class="tok-number">1</span>);</span>
<span class="line" id="L2723">        <span class="tok-kw">var</span> m = r.toMutable();</span>
<span class="line" id="L2724">        m.sub(a.toConst(), b.toConst());</span>
<span class="line" id="L2725">        r.setMetadata(m.positive, m.len);</span>
<span class="line" id="L2726">    }</span>
<span class="line" id="L2727"></span>
<span class="line" id="L2728">    <span class="tok-comment">/// r = a - b with 2s-complement wrapping semantics. Returns whether any overflow occured.</span></span>
<span class="line" id="L2729">    <span class="tok-comment">///</span></span>
<span class="line" id="L2730">    <span class="tok-comment">/// r, a and b may be aliases.</span></span>
<span class="line" id="L2731">    <span class="tok-comment">///</span></span>
<span class="line" id="L2732">    <span class="tok-comment">/// Returns an error if memory could not be allocated.</span></span>
<span class="line" id="L2733">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">subWrap</span>(</span>
<span class="line" id="L2734">        r: *Managed,</span>
<span class="line" id="L2735">        a: *<span class="tok-kw">const</span> Managed,</span>
<span class="line" id="L2736">        b: *<span class="tok-kw">const</span> Managed,</span>
<span class="line" id="L2737">        signedness: Signedness,</span>
<span class="line" id="L2738">        bit_count: <span class="tok-type">usize</span>,</span>
<span class="line" id="L2739">    ) Allocator.Error!<span class="tok-type">bool</span> {</span>
<span class="line" id="L2740">        <span class="tok-kw">try</span> r.ensureTwosCompCapacity(bit_count);</span>
<span class="line" id="L2741">        <span class="tok-kw">var</span> m = r.toMutable();</span>
<span class="line" id="L2742">        <span class="tok-kw">const</span> wrapped = m.subWrap(a.toConst(), b.toConst(), signedness, bit_count);</span>
<span class="line" id="L2743">        r.setMetadata(m.positive, m.len);</span>
<span class="line" id="L2744">        <span class="tok-kw">return</span> wrapped;</span>
<span class="line" id="L2745">    }</span>
<span class="line" id="L2746"></span>
<span class="line" id="L2747">    <span class="tok-comment">/// r = a - b with 2s-complement saturating semantics.</span></span>
<span class="line" id="L2748">    <span class="tok-comment">///</span></span>
<span class="line" id="L2749">    <span class="tok-comment">/// r, a and b may be aliases.</span></span>
<span class="line" id="L2750">    <span class="tok-comment">///</span></span>
<span class="line" id="L2751">    <span class="tok-comment">/// Returns an error if memory could not be allocated.</span></span>
<span class="line" id="L2752">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">subSat</span>(</span>
<span class="line" id="L2753">        r: *Managed,</span>
<span class="line" id="L2754">        a: *<span class="tok-kw">const</span> Managed,</span>
<span class="line" id="L2755">        b: *<span class="tok-kw">const</span> Managed,</span>
<span class="line" id="L2756">        signedness: Signedness,</span>
<span class="line" id="L2757">        bit_count: <span class="tok-type">usize</span>,</span>
<span class="line" id="L2758">    ) Allocator.Error!<span class="tok-type">void</span> {</span>
<span class="line" id="L2759">        <span class="tok-kw">try</span> r.ensureTwosCompCapacity(bit_count);</span>
<span class="line" id="L2760">        <span class="tok-kw">var</span> m = r.toMutable();</span>
<span class="line" id="L2761">        m.subSat(a.toConst(), b.toConst(), signedness, bit_count);</span>
<span class="line" id="L2762">        r.setMetadata(m.positive, m.len);</span>
<span class="line" id="L2763">    }</span>
<span class="line" id="L2764"></span>
<span class="line" id="L2765">    <span class="tok-comment">/// rma = a * b</span></span>
<span class="line" id="L2766">    <span class="tok-comment">///</span></span>
<span class="line" id="L2767">    <span class="tok-comment">/// rma, a and b may be aliases. However, it is more efficient if rma does not alias a or b.</span></span>
<span class="line" id="L2768">    <span class="tok-comment">///</span></span>
<span class="line" id="L2769">    <span class="tok-comment">/// Returns an error if memory could not be allocated.</span></span>
<span class="line" id="L2770">    <span class="tok-comment">///</span></span>
<span class="line" id="L2771">    <span class="tok-comment">/// rma's allocator is used for temporary storage to speed up the multiplication.</span></span>
<span class="line" id="L2772">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">mul</span>(rma: *Managed, a: *<span class="tok-kw">const</span> Managed, b: *<span class="tok-kw">const</span> Managed) !<span class="tok-type">void</span> {</span>
<span class="line" id="L2773">        <span class="tok-kw">var</span> alias_count: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L2774">        <span class="tok-kw">if</span> (rma.limbs.ptr == a.limbs.ptr)</span>
<span class="line" id="L2775">            alias_count += <span class="tok-number">1</span>;</span>
<span class="line" id="L2776">        <span class="tok-kw">if</span> (rma.limbs.ptr == b.limbs.ptr)</span>
<span class="line" id="L2777">            alias_count += <span class="tok-number">1</span>;</span>
<span class="line" id="L2778">        <span class="tok-kw">try</span> rma.ensureMulCapacity(a.toConst(), b.toConst());</span>
<span class="line" id="L2779">        <span class="tok-kw">var</span> m = rma.toMutable();</span>
<span class="line" id="L2780">        <span class="tok-kw">if</span> (alias_count == <span class="tok-number">0</span>) {</span>
<span class="line" id="L2781">            m.mulNoAlias(a.toConst(), b.toConst(), rma.allocator);</span>
<span class="line" id="L2782">        } <span class="tok-kw">else</span> {</span>
<span class="line" id="L2783">            <span class="tok-kw">const</span> limb_count = calcMulLimbsBufferLen(a.len(), b.len(), alias_count);</span>
<span class="line" id="L2784">            <span class="tok-kw">const</span> limbs_buffer = <span class="tok-kw">try</span> rma.allocator.alloc(Limb, limb_count);</span>
<span class="line" id="L2785">            <span class="tok-kw">defer</span> rma.allocator.free(limbs_buffer);</span>
<span class="line" id="L2786">            m.mul(a.toConst(), b.toConst(), limbs_buffer, rma.allocator);</span>
<span class="line" id="L2787">        }</span>
<span class="line" id="L2788">        rma.setMetadata(m.positive, m.len);</span>
<span class="line" id="L2789">    }</span>
<span class="line" id="L2790"></span>
<span class="line" id="L2791">    <span class="tok-comment">/// rma = a * b with 2s-complement wrapping semantics.</span></span>
<span class="line" id="L2792">    <span class="tok-comment">///</span></span>
<span class="line" id="L2793">    <span class="tok-comment">/// rma, a and b may be aliases. However, it is more efficient if rma does not alias a or b.</span></span>
<span class="line" id="L2794">    <span class="tok-comment">///</span></span>
<span class="line" id="L2795">    <span class="tok-comment">/// Returns an error if memory could not be allocated.</span></span>
<span class="line" id="L2796">    <span class="tok-comment">///</span></span>
<span class="line" id="L2797">    <span class="tok-comment">/// rma's allocator is used for temporary storage to speed up the multiplication.</span></span>
<span class="line" id="L2798">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">mulWrap</span>(</span>
<span class="line" id="L2799">        rma: *Managed,</span>
<span class="line" id="L2800">        a: *<span class="tok-kw">const</span> Managed,</span>
<span class="line" id="L2801">        b: *<span class="tok-kw">const</span> Managed,</span>
<span class="line" id="L2802">        signedness: Signedness,</span>
<span class="line" id="L2803">        bit_count: <span class="tok-type">usize</span>,</span>
<span class="line" id="L2804">    ) !<span class="tok-type">void</span> {</span>
<span class="line" id="L2805">        <span class="tok-kw">var</span> alias_count: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L2806">        <span class="tok-kw">if</span> (rma.limbs.ptr == a.limbs.ptr)</span>
<span class="line" id="L2807">            alias_count += <span class="tok-number">1</span>;</span>
<span class="line" id="L2808">        <span class="tok-kw">if</span> (rma.limbs.ptr == b.limbs.ptr)</span>
<span class="line" id="L2809">            alias_count += <span class="tok-number">1</span>;</span>
<span class="line" id="L2810"></span>
<span class="line" id="L2811">        <span class="tok-kw">try</span> rma.ensureTwosCompCapacity(bit_count);</span>
<span class="line" id="L2812">        <span class="tok-kw">var</span> m = rma.toMutable();</span>
<span class="line" id="L2813">        <span class="tok-kw">if</span> (alias_count == <span class="tok-number">0</span>) {</span>
<span class="line" id="L2814">            m.mulWrapNoAlias(a.toConst(), b.toConst(), signedness, bit_count, rma.allocator);</span>
<span class="line" id="L2815">        } <span class="tok-kw">else</span> {</span>
<span class="line" id="L2816">            <span class="tok-kw">const</span> limb_count = calcMulWrapLimbsBufferLen(bit_count, a.len(), b.len(), alias_count);</span>
<span class="line" id="L2817">            <span class="tok-kw">const</span> limbs_buffer = <span class="tok-kw">try</span> rma.allocator.alloc(Limb, limb_count);</span>
<span class="line" id="L2818">            <span class="tok-kw">defer</span> rma.allocator.free(limbs_buffer);</span>
<span class="line" id="L2819">            m.mulWrap(a.toConst(), b.toConst(), signedness, bit_count, limbs_buffer, rma.allocator);</span>
<span class="line" id="L2820">        }</span>
<span class="line" id="L2821">        rma.setMetadata(m.positive, m.len);</span>
<span class="line" id="L2822">    }</span>
<span class="line" id="L2823"></span>
<span class="line" id="L2824">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">ensureTwosCompCapacity</span>(r: *Managed, bit_count: <span class="tok-type">usize</span>) !<span class="tok-type">void</span> {</span>
<span class="line" id="L2825">        <span class="tok-kw">try</span> r.ensureCapacity(calcTwosCompLimbCount(bit_count));</span>
<span class="line" id="L2826">    }</span>
<span class="line" id="L2827"></span>
<span class="line" id="L2828">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">ensureAddScalarCapacity</span>(r: *Managed, a: Const, scalar: <span class="tok-kw">anytype</span>) !<span class="tok-type">void</span> {</span>
<span class="line" id="L2829">        <span class="tok-kw">try</span> r.ensureCapacity(math.max(a.limbs.len, calcLimbLen(scalar)) + <span class="tok-number">1</span>);</span>
<span class="line" id="L2830">    }</span>
<span class="line" id="L2831"></span>
<span class="line" id="L2832">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">ensureAddCapacity</span>(r: *Managed, a: Const, b: Const) !<span class="tok-type">void</span> {</span>
<span class="line" id="L2833">        <span class="tok-kw">try</span> r.ensureCapacity(math.max(a.limbs.len, b.limbs.len) + <span class="tok-number">1</span>);</span>
<span class="line" id="L2834">    }</span>
<span class="line" id="L2835"></span>
<span class="line" id="L2836">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">ensureMulCapacity</span>(rma: *Managed, a: Const, b: Const) !<span class="tok-type">void</span> {</span>
<span class="line" id="L2837">        <span class="tok-kw">try</span> rma.ensureCapacity(a.limbs.len + b.limbs.len + <span class="tok-number">1</span>);</span>
<span class="line" id="L2838">    }</span>
<span class="line" id="L2839"></span>
<span class="line" id="L2840">    <span class="tok-comment">/// q = a / b (rem r)</span></span>
<span class="line" id="L2841">    <span class="tok-comment">///</span></span>
<span class="line" id="L2842">    <span class="tok-comment">/// a / b are floored (rounded towards 0).</span></span>
<span class="line" id="L2843">    <span class="tok-comment">///</span></span>
<span class="line" id="L2844">    <span class="tok-comment">/// Returns an error if memory could not be allocated.</span></span>
<span class="line" id="L2845">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">divFloor</span>(q: *Managed, r: *Managed, a: *<span class="tok-kw">const</span> Managed, b: *<span class="tok-kw">const</span> Managed) !<span class="tok-type">void</span> {</span>
<span class="line" id="L2846">        <span class="tok-kw">try</span> q.ensureCapacity(a.len());</span>
<span class="line" id="L2847">        <span class="tok-kw">try</span> r.ensureCapacity(b.len());</span>
<span class="line" id="L2848">        <span class="tok-kw">var</span> mq = q.toMutable();</span>
<span class="line" id="L2849">        <span class="tok-kw">var</span> mr = r.toMutable();</span>
<span class="line" id="L2850">        <span class="tok-kw">const</span> limbs_buffer = <span class="tok-kw">try</span> q.allocator.alloc(Limb, calcDivLimbsBufferLen(a.len(), b.len()));</span>
<span class="line" id="L2851">        <span class="tok-kw">defer</span> q.allocator.free(limbs_buffer);</span>
<span class="line" id="L2852">        mq.divFloor(&amp;mr, a.toConst(), b.toConst(), limbs_buffer);</span>
<span class="line" id="L2853">        q.setMetadata(mq.positive, mq.len);</span>
<span class="line" id="L2854">        r.setMetadata(mr.positive, mr.len);</span>
<span class="line" id="L2855">    }</span>
<span class="line" id="L2856"></span>
<span class="line" id="L2857">    <span class="tok-comment">/// q = a / b (rem r)</span></span>
<span class="line" id="L2858">    <span class="tok-comment">///</span></span>
<span class="line" id="L2859">    <span class="tok-comment">/// a / b are truncated (rounded towards -inf).</span></span>
<span class="line" id="L2860">    <span class="tok-comment">///</span></span>
<span class="line" id="L2861">    <span class="tok-comment">/// Returns an error if memory could not be allocated.</span></span>
<span class="line" id="L2862">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">divTrunc</span>(q: *Managed, r: *Managed, a: *<span class="tok-kw">const</span> Managed, b: *<span class="tok-kw">const</span> Managed) !<span class="tok-type">void</span> {</span>
<span class="line" id="L2863">        <span class="tok-kw">try</span> q.ensureCapacity(a.len());</span>
<span class="line" id="L2864">        <span class="tok-kw">try</span> r.ensureCapacity(b.len());</span>
<span class="line" id="L2865">        <span class="tok-kw">var</span> mq = q.toMutable();</span>
<span class="line" id="L2866">        <span class="tok-kw">var</span> mr = r.toMutable();</span>
<span class="line" id="L2867">        <span class="tok-kw">const</span> limbs_buffer = <span class="tok-kw">try</span> q.allocator.alloc(Limb, calcDivLimbsBufferLen(a.len(), b.len()));</span>
<span class="line" id="L2868">        <span class="tok-kw">defer</span> q.allocator.free(limbs_buffer);</span>
<span class="line" id="L2869">        mq.divTrunc(&amp;mr, a.toConst(), b.toConst(), limbs_buffer);</span>
<span class="line" id="L2870">        q.setMetadata(mq.positive, mq.len);</span>
<span class="line" id="L2871">        r.setMetadata(mr.positive, mr.len);</span>
<span class="line" id="L2872">    }</span>
<span class="line" id="L2873"></span>
<span class="line" id="L2874">    <span class="tok-comment">/// r = a &lt;&lt; shift, in other words, r = a * 2^shift</span></span>
<span class="line" id="L2875">    <span class="tok-comment">/// r and a may alias.</span></span>
<span class="line" id="L2876">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">shiftLeft</span>(r: *Managed, a: *<span class="tok-kw">const</span> Managed, shift: <span class="tok-type">usize</span>) !<span class="tok-type">void</span> {</span>
<span class="line" id="L2877">        <span class="tok-kw">try</span> r.ensureCapacity(a.len() + (shift / limb_bits) + <span class="tok-number">1</span>);</span>
<span class="line" id="L2878">        <span class="tok-kw">var</span> m = r.toMutable();</span>
<span class="line" id="L2879">        m.shiftLeft(a.toConst(), shift);</span>
<span class="line" id="L2880">        r.setMetadata(m.positive, m.len);</span>
<span class="line" id="L2881">    }</span>
<span class="line" id="L2882"></span>
<span class="line" id="L2883">    <span class="tok-comment">/// r = a &lt;&lt;| shift with 2s-complement saturating semantics.</span></span>
<span class="line" id="L2884">    <span class="tok-comment">/// r and a may alias.</span></span>
<span class="line" id="L2885">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">shiftLeftSat</span>(r: *Managed, a: *<span class="tok-kw">const</span> Managed, shift: <span class="tok-type">usize</span>, signedness: Signedness, bit_count: <span class="tok-type">usize</span>) !<span class="tok-type">void</span> {</span>
<span class="line" id="L2886">        <span class="tok-kw">try</span> r.ensureTwosCompCapacity(bit_count);</span>
<span class="line" id="L2887">        <span class="tok-kw">var</span> m = r.toMutable();</span>
<span class="line" id="L2888">        m.shiftLeftSat(a.toConst(), shift, signedness, bit_count);</span>
<span class="line" id="L2889">        r.setMetadata(m.positive, m.len);</span>
<span class="line" id="L2890">    }</span>
<span class="line" id="L2891"></span>
<span class="line" id="L2892">    <span class="tok-comment">/// r = a &gt;&gt; shift</span></span>
<span class="line" id="L2893">    <span class="tok-comment">/// r and a may alias.</span></span>
<span class="line" id="L2894">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">shiftRight</span>(r: *Managed, a: *<span class="tok-kw">const</span> Managed, shift: <span class="tok-type">usize</span>) !<span class="tok-type">void</span> {</span>
<span class="line" id="L2895">        <span class="tok-kw">if</span> (a.len() &lt;= shift / limb_bits) {</span>
<span class="line" id="L2896">            r.metadata = <span class="tok-number">1</span>;</span>
<span class="line" id="L2897">            r.limbs[<span class="tok-number">0</span>] = <span class="tok-number">0</span>;</span>
<span class="line" id="L2898">            <span class="tok-kw">return</span>;</span>
<span class="line" id="L2899">        }</span>
<span class="line" id="L2900"></span>
<span class="line" id="L2901">        <span class="tok-kw">try</span> r.ensureCapacity(a.len() - (shift / limb_bits));</span>
<span class="line" id="L2902">        <span class="tok-kw">var</span> m = r.toMutable();</span>
<span class="line" id="L2903">        m.shiftRight(a.toConst(), shift);</span>
<span class="line" id="L2904">        r.setMetadata(m.positive, m.len);</span>
<span class="line" id="L2905">    }</span>
<span class="line" id="L2906"></span>
<span class="line" id="L2907">    <span class="tok-comment">/// r = ~a under 2s-complement wrapping semantics.</span></span>
<span class="line" id="L2908">    <span class="tok-comment">/// r and a may alias.</span></span>
<span class="line" id="L2909">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">bitNotWrap</span>(r: *Managed, a: *<span class="tok-kw">const</span> Managed, signedness: Signedness, bit_count: <span class="tok-type">usize</span>) !<span class="tok-type">void</span> {</span>
<span class="line" id="L2910">        <span class="tok-kw">try</span> r.ensureTwosCompCapacity(bit_count);</span>
<span class="line" id="L2911">        <span class="tok-kw">var</span> m = r.toMutable();</span>
<span class="line" id="L2912">        m.bitNotWrap(a.toConst(), signedness, bit_count);</span>
<span class="line" id="L2913">        r.setMetadata(m.positive, m.len);</span>
<span class="line" id="L2914">    }</span>
<span class="line" id="L2915"></span>
<span class="line" id="L2916">    <span class="tok-comment">/// r = a | b</span></span>
<span class="line" id="L2917">    <span class="tok-comment">///</span></span>
<span class="line" id="L2918">    <span class="tok-comment">/// a and b are zero-extended to the longer of a or b.</span></span>
<span class="line" id="L2919">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">bitOr</span>(r: *Managed, a: *<span class="tok-kw">const</span> Managed, b: *<span class="tok-kw">const</span> Managed) !<span class="tok-type">void</span> {</span>
<span class="line" id="L2920">        <span class="tok-kw">try</span> r.ensureCapacity(math.max(a.len(), b.len()));</span>
<span class="line" id="L2921">        <span class="tok-kw">var</span> m = r.toMutable();</span>
<span class="line" id="L2922">        m.bitOr(a.toConst(), b.toConst());</span>
<span class="line" id="L2923">        r.setMetadata(m.positive, m.len);</span>
<span class="line" id="L2924">    }</span>
<span class="line" id="L2925"></span>
<span class="line" id="L2926">    <span class="tok-comment">/// r = a &amp; b</span></span>
<span class="line" id="L2927">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">bitAnd</span>(r: *Managed, a: *<span class="tok-kw">const</span> Managed, b: *<span class="tok-kw">const</span> Managed) !<span class="tok-type">void</span> {</span>
<span class="line" id="L2928">        <span class="tok-kw">const</span> cap = <span class="tok-kw">if</span> (a.isPositive() <span class="tok-kw">or</span> b.isPositive())</span>
<span class="line" id="L2929">            math.min(a.len(), b.len())</span>
<span class="line" id="L2930">        <span class="tok-kw">else</span></span>
<span class="line" id="L2931">            math.max(a.len(), b.len()) + <span class="tok-number">1</span>;</span>
<span class="line" id="L2932">        <span class="tok-kw">try</span> r.ensureCapacity(cap);</span>
<span class="line" id="L2933">        <span class="tok-kw">var</span> m = r.toMutable();</span>
<span class="line" id="L2934">        m.bitAnd(a.toConst(), b.toConst());</span>
<span class="line" id="L2935">        r.setMetadata(m.positive, m.len);</span>
<span class="line" id="L2936">    }</span>
<span class="line" id="L2937"></span>
<span class="line" id="L2938">    <span class="tok-comment">/// r = a ^ b</span></span>
<span class="line" id="L2939">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">bitXor</span>(r: *Managed, a: *<span class="tok-kw">const</span> Managed, b: *<span class="tok-kw">const</span> Managed) !<span class="tok-type">void</span> {</span>
<span class="line" id="L2940">        <span class="tok-kw">var</span> cap = math.max(a.len(), b.len()) + <span class="tok-builtin">@boolToInt</span>(a.isPositive() != b.isPositive());</span>
<span class="line" id="L2941">        <span class="tok-kw">try</span> r.ensureCapacity(cap);</span>
<span class="line" id="L2942"></span>
<span class="line" id="L2943">        <span class="tok-kw">var</span> m = r.toMutable();</span>
<span class="line" id="L2944">        m.bitXor(a.toConst(), b.toConst());</span>
<span class="line" id="L2945">        r.setMetadata(m.positive, m.len);</span>
<span class="line" id="L2946">    }</span>
<span class="line" id="L2947"></span>
<span class="line" id="L2948">    <span class="tok-comment">/// rma may alias x or y.</span></span>
<span class="line" id="L2949">    <span class="tok-comment">/// x and y may alias each other.</span></span>
<span class="line" id="L2950">    <span class="tok-comment">///</span></span>
<span class="line" id="L2951">    <span class="tok-comment">/// rma's allocator is used for temporary storage to boost multiplication performance.</span></span>
<span class="line" id="L2952">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">gcd</span>(rma: *Managed, x: *<span class="tok-kw">const</span> Managed, y: *<span class="tok-kw">const</span> Managed) !<span class="tok-type">void</span> {</span>
<span class="line" id="L2953">        <span class="tok-kw">try</span> rma.ensureCapacity(math.min(x.len(), y.len()));</span>
<span class="line" id="L2954">        <span class="tok-kw">var</span> m = rma.toMutable();</span>
<span class="line" id="L2955">        <span class="tok-kw">var</span> limbs_buffer = std.ArrayList(Limb).init(rma.allocator);</span>
<span class="line" id="L2956">        <span class="tok-kw">defer</span> limbs_buffer.deinit();</span>
<span class="line" id="L2957">        <span class="tok-kw">try</span> m.gcd(x.toConst(), y.toConst(), &amp;limbs_buffer);</span>
<span class="line" id="L2958">        rma.setMetadata(m.positive, m.len);</span>
<span class="line" id="L2959">    }</span>
<span class="line" id="L2960"></span>
<span class="line" id="L2961">    <span class="tok-comment">/// r = a * a</span></span>
<span class="line" id="L2962">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">sqr</span>(rma: *Managed, a: *<span class="tok-kw">const</span> Managed) !<span class="tok-type">void</span> {</span>
<span class="line" id="L2963">        <span class="tok-kw">const</span> needed_limbs = <span class="tok-number">2</span> * a.len() + <span class="tok-number">1</span>;</span>
<span class="line" id="L2964"></span>
<span class="line" id="L2965">        <span class="tok-kw">if</span> (rma.limbs.ptr == a.limbs.ptr) {</span>
<span class="line" id="L2966">            <span class="tok-kw">var</span> m = <span class="tok-kw">try</span> Managed.initCapacity(rma.allocator, needed_limbs);</span>
<span class="line" id="L2967">            <span class="tok-kw">errdefer</span> m.deinit();</span>
<span class="line" id="L2968">            <span class="tok-kw">var</span> m_mut = m.toMutable();</span>
<span class="line" id="L2969">            m_mut.sqrNoAlias(a.toConst(), rma.allocator);</span>
<span class="line" id="L2970">            m.setMetadata(m_mut.positive, m_mut.len);</span>
<span class="line" id="L2971"></span>
<span class="line" id="L2972">            rma.deinit();</span>
<span class="line" id="L2973">            rma.swap(&amp;m);</span>
<span class="line" id="L2974">        } <span class="tok-kw">else</span> {</span>
<span class="line" id="L2975">            <span class="tok-kw">try</span> rma.ensureCapacity(needed_limbs);</span>
<span class="line" id="L2976">            <span class="tok-kw">var</span> rma_mut = rma.toMutable();</span>
<span class="line" id="L2977">            rma_mut.sqrNoAlias(a.toConst(), rma.allocator);</span>
<span class="line" id="L2978">            rma.setMetadata(rma_mut.positive, rma_mut.len);</span>
<span class="line" id="L2979">        }</span>
<span class="line" id="L2980">    }</span>
<span class="line" id="L2981"></span>
<span class="line" id="L2982">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">pow</span>(rma: *Managed, a: *<span class="tok-kw">const</span> Managed, b: <span class="tok-type">u32</span>) !<span class="tok-type">void</span> {</span>
<span class="line" id="L2983">        <span class="tok-kw">const</span> needed_limbs = calcPowLimbsBufferLen(a.bitCountAbs(), b);</span>
<span class="line" id="L2984"></span>
<span class="line" id="L2985">        <span class="tok-kw">const</span> limbs_buffer = <span class="tok-kw">try</span> rma.allocator.alloc(Limb, needed_limbs);</span>
<span class="line" id="L2986">        <span class="tok-kw">defer</span> rma.allocator.free(limbs_buffer);</span>
<span class="line" id="L2987"></span>
<span class="line" id="L2988">        <span class="tok-kw">if</span> (rma.limbs.ptr == a.limbs.ptr) {</span>
<span class="line" id="L2989">            <span class="tok-kw">var</span> m = <span class="tok-kw">try</span> Managed.initCapacity(rma.allocator, needed_limbs);</span>
<span class="line" id="L2990">            <span class="tok-kw">errdefer</span> m.deinit();</span>
<span class="line" id="L2991">            <span class="tok-kw">var</span> m_mut = m.toMutable();</span>
<span class="line" id="L2992">            <span class="tok-kw">try</span> m_mut.pow(a.toConst(), b, limbs_buffer);</span>
<span class="line" id="L2993">            m.setMetadata(m_mut.positive, m_mut.len);</span>
<span class="line" id="L2994"></span>
<span class="line" id="L2995">            rma.deinit();</span>
<span class="line" id="L2996">            rma.swap(&amp;m);</span>
<span class="line" id="L2997">        } <span class="tok-kw">else</span> {</span>
<span class="line" id="L2998">            <span class="tok-kw">try</span> rma.ensureCapacity(needed_limbs);</span>
<span class="line" id="L2999">            <span class="tok-kw">var</span> rma_mut = rma.toMutable();</span>
<span class="line" id="L3000">            <span class="tok-kw">try</span> rma_mut.pow(a.toConst(), b, limbs_buffer);</span>
<span class="line" id="L3001">            rma.setMetadata(rma_mut.positive, rma_mut.len);</span>
<span class="line" id="L3002">        }</span>
<span class="line" id="L3003">    }</span>
<span class="line" id="L3004"></span>
<span class="line" id="L3005">    <span class="tok-comment">/// r = truncate(Int(signedness, bit_count), a)</span></span>
<span class="line" id="L3006">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">truncate</span>(r: *Managed, a: *<span class="tok-kw">const</span> Managed, signedness: Signedness, bit_count: <span class="tok-type">usize</span>) !<span class="tok-type">void</span> {</span>
<span class="line" id="L3007">        <span class="tok-kw">try</span> r.ensureCapacity(calcTwosCompLimbCount(bit_count));</span>
<span class="line" id="L3008">        <span class="tok-kw">var</span> m = r.toMutable();</span>
<span class="line" id="L3009">        m.truncate(a.toConst(), signedness, bit_count);</span>
<span class="line" id="L3010">        r.setMetadata(m.positive, m.len);</span>
<span class="line" id="L3011">    }</span>
<span class="line" id="L3012"></span>
<span class="line" id="L3013">    <span class="tok-comment">/// r = saturate(Int(signedness, bit_count), a)</span></span>
<span class="line" id="L3014">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">saturate</span>(r: *Managed, a: *<span class="tok-kw">const</span> Managed, signedness: Signedness, bit_count: <span class="tok-type">usize</span>) !<span class="tok-type">void</span> {</span>
<span class="line" id="L3015">        <span class="tok-kw">try</span> r.ensureCapacity(calcTwosCompLimbCount(bit_count));</span>
<span class="line" id="L3016">        <span class="tok-kw">var</span> m = r.toMutable();</span>
<span class="line" id="L3017">        m.saturate(a.toConst(), signedness, bit_count);</span>
<span class="line" id="L3018">        r.setMetadata(m.positive, m.len);</span>
<span class="line" id="L3019">    }</span>
<span class="line" id="L3020"></span>
<span class="line" id="L3021">    <span class="tok-comment">/// r = @popCount(a) with 2s-complement semantics.</span></span>
<span class="line" id="L3022">    <span class="tok-comment">/// r and a may be aliases.</span></span>
<span class="line" id="L3023">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">popCount</span>(r: *Managed, a: *<span class="tok-kw">const</span> Managed, bit_count: <span class="tok-type">usize</span>) !<span class="tok-type">void</span> {</span>
<span class="line" id="L3024">        <span class="tok-kw">try</span> r.ensureCapacity(calcTwosCompLimbCount(bit_count));</span>
<span class="line" id="L3025">        <span class="tok-kw">var</span> m = r.toMutable();</span>
<span class="line" id="L3026">        m.popCount(a.toConst(), bit_count);</span>
<span class="line" id="L3027">        r.setMetadata(m.positive, m.len);</span>
<span class="line" id="L3028">    }</span>
<span class="line" id="L3029">};</span>
<span class="line" id="L3030"></span>
<span class="line" id="L3031"><span class="tok-comment">/// Different operators which can be used in accumulation style functions</span></span>
<span class="line" id="L3032"><span class="tok-comment">/// (llmulacc, llmulaccKaratsuba, llmulaccLong, llmulLimb). In all these functions,</span></span>
<span class="line" id="L3033"><span class="tok-comment">/// a computed value is accumulated with an existing result.</span></span>
<span class="line" id="L3034"><span class="tok-kw">const</span> AccOp = <span class="tok-kw">enum</span> {</span>
<span class="line" id="L3035">    <span class="tok-comment">/// The computed value is added to the result.</span></span>
<span class="line" id="L3036">    add,</span>
<span class="line" id="L3037"></span>
<span class="line" id="L3038">    <span class="tok-comment">/// The computed value is subtracted from the result.</span></span>
<span class="line" id="L3039">    sub,</span>
<span class="line" id="L3040">};</span>
<span class="line" id="L3041"></span>
<span class="line" id="L3042"><span class="tok-comment">/// Knuth 4.3.1, Algorithm M.</span></span>
<span class="line" id="L3043"><span class="tok-comment">///</span></span>
<span class="line" id="L3044"><span class="tok-comment">/// r = r (op) a * b</span></span>
<span class="line" id="L3045"><span class="tok-comment">/// r MUST NOT alias any of a or b.</span></span>
<span class="line" id="L3046"><span class="tok-comment">///</span></span>
<span class="line" id="L3047"><span class="tok-comment">/// The result is computed modulo `r.len`. When `r.len &gt;= a.len + b.len`, no overflow occurs.</span></span>
<span class="line" id="L3048"><span class="tok-kw">fn</span> <span class="tok-fn">llmulacc</span>(<span class="tok-kw">comptime</span> op: AccOp, opt_allocator: ?Allocator, r: []Limb, a: []<span class="tok-kw">const</span> Limb, b: []<span class="tok-kw">const</span> Limb) <span class="tok-type">void</span> {</span>
<span class="line" id="L3049">    <span class="tok-builtin">@setRuntimeSafety</span>(debug_safety);</span>
<span class="line" id="L3050">    assert(r.len &gt;= a.len);</span>
<span class="line" id="L3051">    assert(r.len &gt;= b.len);</span>
<span class="line" id="L3052"></span>
<span class="line" id="L3053">    <span class="tok-comment">// Order greatest first.</span>
</span>
<span class="line" id="L3054">    <span class="tok-kw">var</span> x = a;</span>
<span class="line" id="L3055">    <span class="tok-kw">var</span> y = b;</span>
<span class="line" id="L3056">    <span class="tok-kw">if</span> (a.len &lt; b.len) {</span>
<span class="line" id="L3057">        x = b;</span>
<span class="line" id="L3058">        y = a;</span>
<span class="line" id="L3059">    }</span>
<span class="line" id="L3060"></span>
<span class="line" id="L3061">    k_mul: {</span>
<span class="line" id="L3062">        <span class="tok-kw">if</span> (y.len &gt; <span class="tok-number">48</span>) {</span>
<span class="line" id="L3063">            <span class="tok-kw">if</span> (opt_allocator) |allocator| {</span>
<span class="line" id="L3064">                llmulaccKaratsuba(op, allocator, r, x, y) <span class="tok-kw">catch</span> |err| <span class="tok-kw">switch</span> (err) {</span>
<span class="line" id="L3065">                    <span class="tok-kw">error</span>.OutOfMemory =&gt; <span class="tok-kw">break</span> :k_mul, <span class="tok-comment">// handled below</span>
</span>
<span class="line" id="L3066">                };</span>
<span class="line" id="L3067">                <span class="tok-kw">return</span>;</span>
<span class="line" id="L3068">            }</span>
<span class="line" id="L3069">        }</span>
<span class="line" id="L3070">    }</span>
<span class="line" id="L3071"></span>
<span class="line" id="L3072">    llmulaccLong(op, r, x, y);</span>
<span class="line" id="L3073">}</span>
<span class="line" id="L3074"></span>
<span class="line" id="L3075"><span class="tok-comment">/// Knuth 4.3.1, Algorithm M.</span></span>
<span class="line" id="L3076"><span class="tok-comment">///</span></span>
<span class="line" id="L3077"><span class="tok-comment">/// r = r (op) a * b</span></span>
<span class="line" id="L3078"><span class="tok-comment">/// r MUST NOT alias any of a or b.</span></span>
<span class="line" id="L3079"><span class="tok-comment">///</span></span>
<span class="line" id="L3080"><span class="tok-comment">/// The result is computed modulo `r.len`. When `r.len &gt;= a.len + b.len`, no overflow occurs.</span></span>
<span class="line" id="L3081"><span class="tok-kw">fn</span> <span class="tok-fn">llmulaccKaratsuba</span>(</span>
<span class="line" id="L3082">    <span class="tok-kw">comptime</span> op: AccOp,</span>
<span class="line" id="L3083">    allocator: Allocator,</span>
<span class="line" id="L3084">    r: []Limb,</span>
<span class="line" id="L3085">    a: []<span class="tok-kw">const</span> Limb,</span>
<span class="line" id="L3086">    b: []<span class="tok-kw">const</span> Limb,</span>
<span class="line" id="L3087">) <span class="tok-kw">error</span>{OutOfMemory}!<span class="tok-type">void</span> {</span>
<span class="line" id="L3088">    <span class="tok-builtin">@setRuntimeSafety</span>(debug_safety);</span>
<span class="line" id="L3089">    assert(r.len &gt;= a.len);</span>
<span class="line" id="L3090">    assert(a.len &gt;= b.len);</span>
<span class="line" id="L3091"></span>
<span class="line" id="L3092">    <span class="tok-comment">// Classical karatsuba algorithm:</span>
</span>
<span class="line" id="L3093">    <span class="tok-comment">// a = a1 * B + a0</span>
</span>
<span class="line" id="L3094">    <span class="tok-comment">// b = b1 * B + b0</span>
</span>
<span class="line" id="L3095">    <span class="tok-comment">// Where a0, b0 &lt; B</span>
</span>
<span class="line" id="L3096">    <span class="tok-comment">//</span>
</span>
<span class="line" id="L3097">    <span class="tok-comment">// We then have:</span>
</span>
<span class="line" id="L3098">    <span class="tok-comment">// ab = a * b</span>
</span>
<span class="line" id="L3099">    <span class="tok-comment">//    = (a1 * B + a0) * (b1 * B + b0)</span>
</span>
<span class="line" id="L3100">    <span class="tok-comment">//    = a1 * b1 * B * B + a1 * B * b0 + a0 * b1 * B + a0 * b0</span>
</span>
<span class="line" id="L3101">    <span class="tok-comment">//    = a1 * b1 * B * B + (a1 * b0 + a0 * b1) * B + a0 * b0</span>
</span>
<span class="line" id="L3102">    <span class="tok-comment">//</span>
</span>
<span class="line" id="L3103">    <span class="tok-comment">// Note that:</span>
</span>
<span class="line" id="L3104">    <span class="tok-comment">// a1 * b0 + a0 * b1</span>
</span>
<span class="line" id="L3105">    <span class="tok-comment">//    = (a1 + a0)(b1 + b0) - a1 * b1 - a0 * b0</span>
</span>
<span class="line" id="L3106">    <span class="tok-comment">//    = (a0 - a1)(b1 - b0) + a1 * b1 + a0 * b0</span>
</span>
<span class="line" id="L3107">    <span class="tok-comment">//</span>
</span>
<span class="line" id="L3108">    <span class="tok-comment">// This yields:</span>
</span>
<span class="line" id="L3109">    <span class="tok-comment">// ab = p2 * B^2 + (p0 + p1 + p2) * B + p0</span>
</span>
<span class="line" id="L3110">    <span class="tok-comment">//</span>
</span>
<span class="line" id="L3111">    <span class="tok-comment">// Where:</span>
</span>
<span class="line" id="L3112">    <span class="tok-comment">// p0 = a0 * b0</span>
</span>
<span class="line" id="L3113">    <span class="tok-comment">// p1 = (a0 - a1)(b1 - b0)</span>
</span>
<span class="line" id="L3114">    <span class="tok-comment">// p2 = a1 * b1</span>
</span>
<span class="line" id="L3115">    <span class="tok-comment">//</span>
</span>
<span class="line" id="L3116">    <span class="tok-comment">// Note, (a0 - a1) and (b1 - b0) produce values -B &lt; x &lt; B, and so we need to mind the sign here.</span>
</span>
<span class="line" id="L3117">    <span class="tok-comment">// We also have:</span>
</span>
<span class="line" id="L3118">    <span class="tok-comment">// 0 &lt;= p0 &lt;= 2B</span>
</span>
<span class="line" id="L3119">    <span class="tok-comment">// -2B &lt;= p1 &lt;= 2B</span>
</span>
<span class="line" id="L3120">    <span class="tok-comment">//</span>
</span>
<span class="line" id="L3121">    <span class="tok-comment">// Note, when B is a multiple of the limb size, multiplies by B amount to shifts or</span>
</span>
<span class="line" id="L3122">    <span class="tok-comment">// slices of a limbs array.</span>
</span>
<span class="line" id="L3123">    <span class="tok-comment">//</span>
</span>
<span class="line" id="L3124">    <span class="tok-comment">// This function computes the result of the multiplication modulo r.len. This means:</span>
</span>
<span class="line" id="L3125">    <span class="tok-comment">// - p2 and p1 only need to be computed modulo r.len - B.</span>
</span>
<span class="line" id="L3126">    <span class="tok-comment">// - In the case of p2, p2 * B^2 needs to be added modulo r.len - 2 * B.</span>
</span>
<span class="line" id="L3127"></span>
<span class="line" id="L3128">    <span class="tok-kw">const</span> split = b.len / <span class="tok-number">2</span>; <span class="tok-comment">// B</span>
</span>
<span class="line" id="L3129"></span>
<span class="line" id="L3130">    <span class="tok-kw">const</span> limbs_after_split = r.len - split; <span class="tok-comment">// Limbs to compute for p1 and p2.</span>
</span>
<span class="line" id="L3131">    <span class="tok-kw">const</span> limbs_after_split2 = r.len - split * <span class="tok-number">2</span>; <span class="tok-comment">// Limbs to add for p2 * B^2.</span>
</span>
<span class="line" id="L3132"></span>
<span class="line" id="L3133">    <span class="tok-comment">// For a0 and b0 we need the full range.</span>
</span>
<span class="line" id="L3134">    <span class="tok-kw">const</span> a0 = a[<span class="tok-number">0</span>..llnormalize(a[<span class="tok-number">0</span>..split])];</span>
<span class="line" id="L3135">    <span class="tok-kw">const</span> b0 = b[<span class="tok-number">0</span>..llnormalize(b[<span class="tok-number">0</span>..split])];</span>
<span class="line" id="L3136"></span>
<span class="line" id="L3137">    <span class="tok-comment">// For a1 and b1 we only need `limbs_after_split` limbs.</span>
</span>
<span class="line" id="L3138">    <span class="tok-kw">const</span> a1 = blk: {</span>
<span class="line" id="L3139">        <span class="tok-kw">var</span> a1 = a[split..];</span>
<span class="line" id="L3140">        a1.len = math.min(llnormalize(a1), limbs_after_split);</span>
<span class="line" id="L3141">        <span class="tok-kw">break</span> :blk a1;</span>
<span class="line" id="L3142">    };</span>
<span class="line" id="L3143"></span>
<span class="line" id="L3144">    <span class="tok-kw">const</span> b1 = blk: {</span>
<span class="line" id="L3145">        <span class="tok-kw">var</span> b1 = b[split..];</span>
<span class="line" id="L3146">        b1.len = math.min(llnormalize(b1), limbs_after_split);</span>
<span class="line" id="L3147">        <span class="tok-kw">break</span> :blk b1;</span>
<span class="line" id="L3148">    };</span>
<span class="line" id="L3149"></span>
<span class="line" id="L3150">    <span class="tok-comment">// Note that the above slices relative to `split` work because we have a.len &gt; b.len.</span>
</span>
<span class="line" id="L3151"></span>
<span class="line" id="L3152">    <span class="tok-comment">// We need some temporary memory to store intermediate results.</span>
</span>
<span class="line" id="L3153">    <span class="tok-comment">// Note, we can reduce the amount of temporaries we need by reordering the computation here:</span>
</span>
<span class="line" id="L3154">    <span class="tok-comment">// ab = p2 * B^2 + (p0 + p1 + p2) * B + p0</span>
</span>
<span class="line" id="L3155">    <span class="tok-comment">//    = p2 * B^2 + (p0 * B + p1 * B + p2 * B) + p0</span>
</span>
<span class="line" id="L3156">    <span class="tok-comment">//    = (p2 * B^2 + p2 * B) + (p0 * B + p0) + p1 * B</span>
</span>
<span class="line" id="L3157"></span>
<span class="line" id="L3158">    <span class="tok-comment">// Allocate at least enough memory to be able to multiply the upper two segments of a and b, assuming</span>
</span>
<span class="line" id="L3159">    <span class="tok-comment">// no overflow.</span>
</span>
<span class="line" id="L3160">    <span class="tok-kw">const</span> tmp = <span class="tok-kw">try</span> allocator.alloc(Limb, a.len - split + b.len - split);</span>
<span class="line" id="L3161">    <span class="tok-kw">defer</span> allocator.free(tmp);</span>
<span class="line" id="L3162"></span>
<span class="line" id="L3163">    <span class="tok-comment">// Compute p2.</span>
</span>
<span class="line" id="L3164">    <span class="tok-comment">// Note, we don't need to compute all of p2, just enough limbs to satisfy r.</span>
</span>
<span class="line" id="L3165">    <span class="tok-kw">const</span> p2_limbs = math.min(limbs_after_split, a1.len + b1.len);</span>
<span class="line" id="L3166"></span>
<span class="line" id="L3167">    mem.set(Limb, tmp[<span class="tok-number">0</span>..p2_limbs], <span class="tok-number">0</span>);</span>
<span class="line" id="L3168">    llmulacc(.add, allocator, tmp[<span class="tok-number">0</span>..p2_limbs], a1[<span class="tok-number">0</span>..math.min(a1.len, p2_limbs)], b1[<span class="tok-number">0</span>..math.min(b1.len, p2_limbs)]);</span>
<span class="line" id="L3169">    <span class="tok-kw">const</span> p2 = tmp[<span class="tok-number">0</span>..llnormalize(tmp[<span class="tok-number">0</span>..p2_limbs])];</span>
<span class="line" id="L3170"></span>
<span class="line" id="L3171">    <span class="tok-comment">// Add p2 * B to the result.</span>
</span>
<span class="line" id="L3172">    llaccum(op, r[split..], p2);</span>
<span class="line" id="L3173"></span>
<span class="line" id="L3174">    <span class="tok-comment">// Add p2 * B^2 to the result if required.</span>
</span>
<span class="line" id="L3175">    <span class="tok-kw">if</span> (limbs_after_split2 &gt; <span class="tok-number">0</span>) {</span>
<span class="line" id="L3176">        llaccum(op, r[split * <span class="tok-number">2</span> ..], p2[<span class="tok-number">0</span>..math.min(p2.len, limbs_after_split2)]);</span>
<span class="line" id="L3177">    }</span>
<span class="line" id="L3178"></span>
<span class="line" id="L3179">    <span class="tok-comment">// Compute p0.</span>
</span>
<span class="line" id="L3180">    <span class="tok-comment">// Since a0.len, b0.len &lt;= split and r.len &gt;= split * 2, the full width of p0 needs to be computed.</span>
</span>
<span class="line" id="L3181">    <span class="tok-kw">const</span> p0_limbs = a0.len + b0.len;</span>
<span class="line" id="L3182">    mem.set(Limb, tmp[<span class="tok-number">0</span>..p0_limbs], <span class="tok-number">0</span>);</span>
<span class="line" id="L3183">    llmulacc(.add, allocator, tmp[<span class="tok-number">0</span>..p0_limbs], a0, b0);</span>
<span class="line" id="L3184">    <span class="tok-kw">const</span> p0 = tmp[<span class="tok-number">0</span>..llnormalize(tmp[<span class="tok-number">0</span>..p0_limbs])];</span>
<span class="line" id="L3185"></span>
<span class="line" id="L3186">    <span class="tok-comment">// Add p0 to the result.</span>
</span>
<span class="line" id="L3187">    llaccum(op, r, p0);</span>
<span class="line" id="L3188"></span>
<span class="line" id="L3189">    <span class="tok-comment">// Add p0 * B to the result. In this case, we may not need all of it.</span>
</span>
<span class="line" id="L3190">    llaccum(op, r[split..], p0[<span class="tok-number">0</span>..math.min(limbs_after_split, p0.len)]);</span>
<span class="line" id="L3191"></span>
<span class="line" id="L3192">    <span class="tok-comment">// Finally, compute and add p1.</span>
</span>
<span class="line" id="L3193">    <span class="tok-comment">// From now on we only need `limbs_after_split` limbs for a0 and b0, since the result of the</span>
</span>
<span class="line" id="L3194">    <span class="tok-comment">// following computation will be added * B.</span>
</span>
<span class="line" id="L3195">    <span class="tok-kw">const</span> a0x = a0[<span class="tok-number">0</span>..std.math.min(a0.len, limbs_after_split)];</span>
<span class="line" id="L3196">    <span class="tok-kw">const</span> b0x = b0[<span class="tok-number">0</span>..std.math.min(b0.len, limbs_after_split)];</span>
<span class="line" id="L3197"></span>
<span class="line" id="L3198">    <span class="tok-kw">const</span> j0_sign = llcmp(a0x, a1);</span>
<span class="line" id="L3199">    <span class="tok-kw">const</span> j1_sign = llcmp(b1, b0x);</span>
<span class="line" id="L3200"></span>
<span class="line" id="L3201">    <span class="tok-kw">if</span> (j0_sign * j1_sign == <span class="tok-number">0</span>) {</span>
<span class="line" id="L3202">        <span class="tok-comment">// p1 is zero, we don't need to do any computation at all.</span>
</span>
<span class="line" id="L3203">        <span class="tok-kw">return</span>;</span>
<span class="line" id="L3204">    }</span>
<span class="line" id="L3205"></span>
<span class="line" id="L3206">    mem.set(Limb, tmp, <span class="tok-number">0</span>);</span>
<span class="line" id="L3207"></span>
<span class="line" id="L3208">    <span class="tok-comment">// p1 is nonzero, so compute the intermediary terms j0 = a0 - a1 and j1 = b1 - b0.</span>
</span>
<span class="line" id="L3209">    <span class="tok-comment">// Note that in this case, we again need some storage for intermediary results</span>
</span>
<span class="line" id="L3210">    <span class="tok-comment">// j0 and j1. Since we have tmp.len &gt;= 2B, we can store both</span>
</span>
<span class="line" id="L3211">    <span class="tok-comment">// intermediaries in the already allocated array.</span>
</span>
<span class="line" id="L3212">    <span class="tok-kw">const</span> j0 = tmp[<span class="tok-number">0</span> .. a.len - split];</span>
<span class="line" id="L3213">    <span class="tok-kw">const</span> j1 = tmp[a.len - split ..];</span>
<span class="line" id="L3214"></span>
<span class="line" id="L3215">    <span class="tok-comment">// Ensure that no subtraction overflows.</span>
</span>
<span class="line" id="L3216">    <span class="tok-kw">if</span> (j0_sign == <span class="tok-number">1</span>) {</span>
<span class="line" id="L3217">        <span class="tok-comment">// a0 &gt; a1.</span>
</span>
<span class="line" id="L3218">        _ = llsubcarry(j0, a0x, a1);</span>
<span class="line" id="L3219">    } <span class="tok-kw">else</span> {</span>
<span class="line" id="L3220">        <span class="tok-comment">// a0 &lt; a1.</span>
</span>
<span class="line" id="L3221">        _ = llsubcarry(j0, a1, a0x);</span>
<span class="line" id="L3222">    }</span>
<span class="line" id="L3223"></span>
<span class="line" id="L3224">    <span class="tok-kw">if</span> (j1_sign == <span class="tok-number">1</span>) {</span>
<span class="line" id="L3225">        <span class="tok-comment">// b1 &gt; b0.</span>
</span>
<span class="line" id="L3226">        _ = llsubcarry(j1, b1, b0x);</span>
<span class="line" id="L3227">    } <span class="tok-kw">else</span> {</span>
<span class="line" id="L3228">        <span class="tok-comment">// b1 &gt; b0.</span>
</span>
<span class="line" id="L3229">        _ = llsubcarry(j1, b0x, b1);</span>
<span class="line" id="L3230">    }</span>
<span class="line" id="L3231"></span>
<span class="line" id="L3232">    <span class="tok-kw">if</span> (j0_sign * j1_sign == <span class="tok-number">1</span>) {</span>
<span class="line" id="L3233">        <span class="tok-comment">// If j0 and j1 are both positive, we now have:</span>
</span>
<span class="line" id="L3234">        <span class="tok-comment">// p1 = j0 * j1</span>
</span>
<span class="line" id="L3235">        <span class="tok-comment">// If j0 and j1 are both negative, we now have:</span>
</span>
<span class="line" id="L3236">        <span class="tok-comment">// p1 = -j0 * -j1 = j0 * j1</span>
</span>
<span class="line" id="L3237">        <span class="tok-comment">// In this case we can add p1 to the result using llmulacc.</span>
</span>
<span class="line" id="L3238">        llmulacc(op, allocator, r[split..], j0[<span class="tok-number">0</span>..llnormalize(j0)], j1[<span class="tok-number">0</span>..llnormalize(j1)]);</span>
<span class="line" id="L3239">    } <span class="tok-kw">else</span> {</span>
<span class="line" id="L3240">        <span class="tok-comment">// In this case either j0 or j1 is negative, an we have:</span>
</span>
<span class="line" id="L3241">        <span class="tok-comment">// p1 = -(j0 * j1)</span>
</span>
<span class="line" id="L3242">        <span class="tok-comment">// Now we need to subtract instead of accumulate.</span>
</span>
<span class="line" id="L3243">        <span class="tok-kw">const</span> inverted_op = <span class="tok-kw">if</span> (op == .add) .sub <span class="tok-kw">else</span> .add;</span>
<span class="line" id="L3244">        llmulacc(inverted_op, allocator, r[split..], j0[<span class="tok-number">0</span>..llnormalize(j0)], j1[<span class="tok-number">0</span>..llnormalize(j1)]);</span>
<span class="line" id="L3245">    }</span>
<span class="line" id="L3246">}</span>
<span class="line" id="L3247"></span>
<span class="line" id="L3248"><span class="tok-comment">/// r = r (op) a.</span></span>
<span class="line" id="L3249"><span class="tok-comment">/// The result is computed modulo `r.len`.</span></span>
<span class="line" id="L3250"><span class="tok-kw">fn</span> <span class="tok-fn">llaccum</span>(<span class="tok-kw">comptime</span> op: AccOp, r: []Limb, a: []<span class="tok-kw">const</span> Limb) <span class="tok-type">void</span> {</span>
<span class="line" id="L3251">    <span class="tok-builtin">@setRuntimeSafety</span>(debug_safety);</span>
<span class="line" id="L3252">    <span class="tok-kw">if</span> (op == .sub) {</span>
<span class="line" id="L3253">        _ = llsubcarry(r, r, a);</span>
<span class="line" id="L3254">        <span class="tok-kw">return</span>;</span>
<span class="line" id="L3255">    }</span>
<span class="line" id="L3256"></span>
<span class="line" id="L3257">    assert(r.len != <span class="tok-number">0</span> <span class="tok-kw">and</span> a.len != <span class="tok-number">0</span>);</span>
<span class="line" id="L3258">    assert(r.len &gt;= a.len);</span>
<span class="line" id="L3259"></span>
<span class="line" id="L3260">    <span class="tok-kw">var</span> i: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L3261">    <span class="tok-kw">var</span> carry: Limb = <span class="tok-number">0</span>;</span>
<span class="line" id="L3262"></span>
<span class="line" id="L3263">    <span class="tok-kw">while</span> (i &lt; a.len) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L3264">        <span class="tok-kw">var</span> c: Limb = <span class="tok-number">0</span>;</span>
<span class="line" id="L3265">        c += <span class="tok-builtin">@boolToInt</span>(<span class="tok-builtin">@addWithOverflow</span>(Limb, r[i], a[i], &amp;r[i]));</span>
<span class="line" id="L3266">        c += <span class="tok-builtin">@boolToInt</span>(<span class="tok-builtin">@addWithOverflow</span>(Limb, r[i], carry, &amp;r[i]));</span>
<span class="line" id="L3267">        carry = c;</span>
<span class="line" id="L3268">    }</span>
<span class="line" id="L3269"></span>
<span class="line" id="L3270">    <span class="tok-kw">while</span> ((carry != <span class="tok-number">0</span>) <span class="tok-kw">and</span> i &lt; r.len) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L3271">        carry = <span class="tok-builtin">@boolToInt</span>(<span class="tok-builtin">@addWithOverflow</span>(Limb, r[i], carry, &amp;r[i]));</span>
<span class="line" id="L3272">    }</span>
<span class="line" id="L3273">}</span>
<span class="line" id="L3274"></span>
<span class="line" id="L3275"><span class="tok-comment">/// Returns -1, 0, 1 if |a| &lt; |b|, |a| == |b| or |a| &gt; |b| respectively for limbs.</span></span>
<span class="line" id="L3276"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">llcmp</span>(a: []<span class="tok-kw">const</span> Limb, b: []<span class="tok-kw">const</span> Limb) <span class="tok-type">i8</span> {</span>
<span class="line" id="L3277">    <span class="tok-builtin">@setRuntimeSafety</span>(debug_safety);</span>
<span class="line" id="L3278">    <span class="tok-kw">const</span> a_len = llnormalize(a);</span>
<span class="line" id="L3279">    <span class="tok-kw">const</span> b_len = llnormalize(b);</span>
<span class="line" id="L3280">    <span class="tok-kw">if</span> (a_len &lt; b_len) {</span>
<span class="line" id="L3281">        <span class="tok-kw">return</span> -<span class="tok-number">1</span>;</span>
<span class="line" id="L3282">    }</span>
<span class="line" id="L3283">    <span class="tok-kw">if</span> (a_len &gt; b_len) {</span>
<span class="line" id="L3284">        <span class="tok-kw">return</span> <span class="tok-number">1</span>;</span>
<span class="line" id="L3285">    }</span>
<span class="line" id="L3286"></span>
<span class="line" id="L3287">    <span class="tok-kw">var</span> i: <span class="tok-type">usize</span> = a_len - <span class="tok-number">1</span>;</span>
<span class="line" id="L3288">    <span class="tok-kw">while</span> (i != <span class="tok-number">0</span>) : (i -= <span class="tok-number">1</span>) {</span>
<span class="line" id="L3289">        <span class="tok-kw">if</span> (a[i] != b[i]) {</span>
<span class="line" id="L3290">            <span class="tok-kw">break</span>;</span>
<span class="line" id="L3291">        }</span>
<span class="line" id="L3292">    }</span>
<span class="line" id="L3293"></span>
<span class="line" id="L3294">    <span class="tok-kw">if</span> (a[i] &lt; b[i]) {</span>
<span class="line" id="L3295">        <span class="tok-kw">return</span> -<span class="tok-number">1</span>;</span>
<span class="line" id="L3296">    } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (a[i] &gt; b[i]) {</span>
<span class="line" id="L3297">        <span class="tok-kw">return</span> <span class="tok-number">1</span>;</span>
<span class="line" id="L3298">    } <span class="tok-kw">else</span> {</span>
<span class="line" id="L3299">        <span class="tok-kw">return</span> <span class="tok-number">0</span>;</span>
<span class="line" id="L3300">    }</span>
<span class="line" id="L3301">}</span>
<span class="line" id="L3302"></span>
<span class="line" id="L3303"><span class="tok-comment">/// r = r (op) y * xi</span></span>
<span class="line" id="L3304"><span class="tok-comment">/// The result is computed modulo `r.len`. When `r.len &gt;= a.len + b.len`, no overflow occurs.</span></span>
<span class="line" id="L3305"><span class="tok-kw">fn</span> <span class="tok-fn">llmulaccLong</span>(<span class="tok-kw">comptime</span> op: AccOp, r: []Limb, a: []<span class="tok-kw">const</span> Limb, b: []<span class="tok-kw">const</span> Limb) <span class="tok-type">void</span> {</span>
<span class="line" id="L3306">    <span class="tok-builtin">@setRuntimeSafety</span>(debug_safety);</span>
<span class="line" id="L3307">    assert(r.len &gt;= a.len);</span>
<span class="line" id="L3308">    assert(a.len &gt;= b.len);</span>
<span class="line" id="L3309"></span>
<span class="line" id="L3310">    <span class="tok-kw">var</span> i: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L3311">    <span class="tok-kw">while</span> (i &lt; b.len) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L3312">        _ = llmulLimb(op, r[i..], a, b[i]);</span>
<span class="line" id="L3313">    }</span>
<span class="line" id="L3314">}</span>
<span class="line" id="L3315"></span>
<span class="line" id="L3316"><span class="tok-comment">/// r = r (op) y * xi</span></span>
<span class="line" id="L3317"><span class="tok-comment">/// The result is computed modulo `r.len`.</span></span>
<span class="line" id="L3318"><span class="tok-comment">/// Returns whether the operation overflowed.</span></span>
<span class="line" id="L3319"><span class="tok-kw">fn</span> <span class="tok-fn">llmulLimb</span>(<span class="tok-kw">comptime</span> op: AccOp, acc: []Limb, y: []<span class="tok-kw">const</span> Limb, xi: Limb) <span class="tok-type">bool</span> {</span>
<span class="line" id="L3320">    <span class="tok-builtin">@setRuntimeSafety</span>(debug_safety);</span>
<span class="line" id="L3321">    <span class="tok-kw">if</span> (xi == <span class="tok-number">0</span>) {</span>
<span class="line" id="L3322">        <span class="tok-kw">return</span> <span class="tok-null">false</span>;</span>
<span class="line" id="L3323">    }</span>
<span class="line" id="L3324"></span>
<span class="line" id="L3325">    <span class="tok-kw">const</span> split = std.math.min(y.len, acc.len);</span>
<span class="line" id="L3326">    <span class="tok-kw">var</span> a_lo = acc[<span class="tok-number">0</span>..split];</span>
<span class="line" id="L3327">    <span class="tok-kw">var</span> a_hi = acc[split..];</span>
<span class="line" id="L3328"></span>
<span class="line" id="L3329">    <span class="tok-kw">switch</span> (op) {</span>
<span class="line" id="L3330">        .add =&gt; {</span>
<span class="line" id="L3331">            <span class="tok-kw">var</span> carry: Limb = <span class="tok-number">0</span>;</span>
<span class="line" id="L3332">            <span class="tok-kw">var</span> j: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L3333">            <span class="tok-kw">while</span> (j &lt; a_lo.len) : (j += <span class="tok-number">1</span>) {</span>
<span class="line" id="L3334">                a_lo[j] = addMulLimbWithCarry(a_lo[j], y[j], xi, &amp;carry);</span>
<span class="line" id="L3335">            }</span>
<span class="line" id="L3336"></span>
<span class="line" id="L3337">            j = <span class="tok-number">0</span>;</span>
<span class="line" id="L3338">            <span class="tok-kw">while</span> ((carry != <span class="tok-number">0</span>) <span class="tok-kw">and</span> (j &lt; a_hi.len)) : (j += <span class="tok-number">1</span>) {</span>
<span class="line" id="L3339">                carry = <span class="tok-builtin">@boolToInt</span>(<span class="tok-builtin">@addWithOverflow</span>(Limb, a_hi[j], carry, &amp;a_hi[j]));</span>
<span class="line" id="L3340">            }</span>
<span class="line" id="L3341"></span>
<span class="line" id="L3342">            <span class="tok-kw">return</span> carry != <span class="tok-number">0</span>;</span>
<span class="line" id="L3343">        },</span>
<span class="line" id="L3344">        .sub =&gt; {</span>
<span class="line" id="L3345">            <span class="tok-kw">var</span> borrow: Limb = <span class="tok-number">0</span>;</span>
<span class="line" id="L3346">            <span class="tok-kw">var</span> j: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L3347">            <span class="tok-kw">while</span> (j &lt; a_lo.len) : (j += <span class="tok-number">1</span>) {</span>
<span class="line" id="L3348">                a_lo[j] = subMulLimbWithBorrow(a_lo[j], y[j], xi, &amp;borrow);</span>
<span class="line" id="L3349">            }</span>
<span class="line" id="L3350"></span>
<span class="line" id="L3351">            j = <span class="tok-number">0</span>;</span>
<span class="line" id="L3352">            <span class="tok-kw">while</span> ((borrow != <span class="tok-number">0</span>) <span class="tok-kw">and</span> (j &lt; a_hi.len)) : (j += <span class="tok-number">1</span>) {</span>
<span class="line" id="L3353">                borrow = <span class="tok-builtin">@boolToInt</span>(<span class="tok-builtin">@subWithOverflow</span>(Limb, a_hi[j], borrow, &amp;a_hi[j]));</span>
<span class="line" id="L3354">            }</span>
<span class="line" id="L3355"></span>
<span class="line" id="L3356">            <span class="tok-kw">return</span> borrow != <span class="tok-number">0</span>;</span>
<span class="line" id="L3357">        },</span>
<span class="line" id="L3358">    }</span>
<span class="line" id="L3359">}</span>
<span class="line" id="L3360"></span>
<span class="line" id="L3361"><span class="tok-comment">/// returns the min length the limb could be.</span></span>
<span class="line" id="L3362"><span class="tok-kw">fn</span> <span class="tok-fn">llnormalize</span>(a: []<span class="tok-kw">const</span> Limb) <span class="tok-type">usize</span> {</span>
<span class="line" id="L3363">    <span class="tok-builtin">@setRuntimeSafety</span>(debug_safety);</span>
<span class="line" id="L3364">    <span class="tok-kw">var</span> j = a.len;</span>
<span class="line" id="L3365">    <span class="tok-kw">while</span> (j &gt; <span class="tok-number">0</span>) : (j -= <span class="tok-number">1</span>) {</span>
<span class="line" id="L3366">        <span class="tok-kw">if</span> (a[j - <span class="tok-number">1</span>] != <span class="tok-number">0</span>) {</span>
<span class="line" id="L3367">            <span class="tok-kw">break</span>;</span>
<span class="line" id="L3368">        }</span>
<span class="line" id="L3369">    }</span>
<span class="line" id="L3370"></span>
<span class="line" id="L3371">    <span class="tok-comment">// Handle zero</span>
</span>
<span class="line" id="L3372">    <span class="tok-kw">return</span> <span class="tok-kw">if</span> (j != <span class="tok-number">0</span>) j <span class="tok-kw">else</span> <span class="tok-number">1</span>;</span>
<span class="line" id="L3373">}</span>
<span class="line" id="L3374"></span>
<span class="line" id="L3375"><span class="tok-comment">/// Knuth 4.3.1, Algorithm S.</span></span>
<span class="line" id="L3376"><span class="tok-kw">fn</span> <span class="tok-fn">llsubcarry</span>(r: []Limb, a: []<span class="tok-kw">const</span> Limb, b: []<span class="tok-kw">const</span> Limb) Limb {</span>
<span class="line" id="L3377">    <span class="tok-builtin">@setRuntimeSafety</span>(debug_safety);</span>
<span class="line" id="L3378">    assert(a.len != <span class="tok-number">0</span> <span class="tok-kw">and</span> b.len != <span class="tok-number">0</span>);</span>
<span class="line" id="L3379">    assert(a.len &gt;= b.len);</span>
<span class="line" id="L3380">    assert(r.len &gt;= a.len);</span>
<span class="line" id="L3381"></span>
<span class="line" id="L3382">    <span class="tok-kw">var</span> i: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L3383">    <span class="tok-kw">var</span> borrow: Limb = <span class="tok-number">0</span>;</span>
<span class="line" id="L3384"></span>
<span class="line" id="L3385">    <span class="tok-kw">while</span> (i &lt; b.len) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L3386">        <span class="tok-kw">var</span> c: Limb = <span class="tok-number">0</span>;</span>
<span class="line" id="L3387">        c += <span class="tok-builtin">@boolToInt</span>(<span class="tok-builtin">@subWithOverflow</span>(Limb, a[i], b[i], &amp;r[i]));</span>
<span class="line" id="L3388">        c += <span class="tok-builtin">@boolToInt</span>(<span class="tok-builtin">@subWithOverflow</span>(Limb, r[i], borrow, &amp;r[i]));</span>
<span class="line" id="L3389">        borrow = c;</span>
<span class="line" id="L3390">    }</span>
<span class="line" id="L3391"></span>
<span class="line" id="L3392">    <span class="tok-kw">while</span> (i &lt; a.len) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L3393">        borrow = <span class="tok-builtin">@boolToInt</span>(<span class="tok-builtin">@subWithOverflow</span>(Limb, a[i], borrow, &amp;r[i]));</span>
<span class="line" id="L3394">    }</span>
<span class="line" id="L3395"></span>
<span class="line" id="L3396">    <span class="tok-kw">return</span> borrow;</span>
<span class="line" id="L3397">}</span>
<span class="line" id="L3398"></span>
<span class="line" id="L3399"><span class="tok-kw">fn</span> <span class="tok-fn">llsub</span>(r: []Limb, a: []<span class="tok-kw">const</span> Limb, b: []<span class="tok-kw">const</span> Limb) <span class="tok-type">void</span> {</span>
<span class="line" id="L3400">    <span class="tok-builtin">@setRuntimeSafety</span>(debug_safety);</span>
<span class="line" id="L3401">    assert(a.len &gt; b.len <span class="tok-kw">or</span> (a.len == b.len <span class="tok-kw">and</span> a[a.len - <span class="tok-number">1</span>] &gt;= b[b.len - <span class="tok-number">1</span>]));</span>
<span class="line" id="L3402">    assert(llsubcarry(r, a, b) == <span class="tok-number">0</span>);</span>
<span class="line" id="L3403">}</span>
<span class="line" id="L3404"></span>
<span class="line" id="L3405"><span class="tok-comment">/// Knuth 4.3.1, Algorithm A.</span></span>
<span class="line" id="L3406"><span class="tok-kw">fn</span> <span class="tok-fn">lladdcarry</span>(r: []Limb, a: []<span class="tok-kw">const</span> Limb, b: []<span class="tok-kw">const</span> Limb) Limb {</span>
<span class="line" id="L3407">    <span class="tok-builtin">@setRuntimeSafety</span>(debug_safety);</span>
<span class="line" id="L3408">    assert(a.len != <span class="tok-number">0</span> <span class="tok-kw">and</span> b.len != <span class="tok-number">0</span>);</span>
<span class="line" id="L3409">    assert(a.len &gt;= b.len);</span>
<span class="line" id="L3410">    assert(r.len &gt;= a.len);</span>
<span class="line" id="L3411"></span>
<span class="line" id="L3412">    <span class="tok-kw">var</span> i: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L3413">    <span class="tok-kw">var</span> carry: Limb = <span class="tok-number">0</span>;</span>
<span class="line" id="L3414"></span>
<span class="line" id="L3415">    <span class="tok-kw">while</span> (i &lt; b.len) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L3416">        <span class="tok-kw">var</span> c: Limb = <span class="tok-number">0</span>;</span>
<span class="line" id="L3417">        c += <span class="tok-builtin">@boolToInt</span>(<span class="tok-builtin">@addWithOverflow</span>(Limb, a[i], b[i], &amp;r[i]));</span>
<span class="line" id="L3418">        c += <span class="tok-builtin">@boolToInt</span>(<span class="tok-builtin">@addWithOverflow</span>(Limb, r[i], carry, &amp;r[i]));</span>
<span class="line" id="L3419">        carry = c;</span>
<span class="line" id="L3420">    }</span>
<span class="line" id="L3421"></span>
<span class="line" id="L3422">    <span class="tok-kw">while</span> (i &lt; a.len) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L3423">        carry = <span class="tok-builtin">@boolToInt</span>(<span class="tok-builtin">@addWithOverflow</span>(Limb, a[i], carry, &amp;r[i]));</span>
<span class="line" id="L3424">    }</span>
<span class="line" id="L3425"></span>
<span class="line" id="L3426">    <span class="tok-kw">return</span> carry;</span>
<span class="line" id="L3427">}</span>
<span class="line" id="L3428"></span>
<span class="line" id="L3429"><span class="tok-kw">fn</span> <span class="tok-fn">lladd</span>(r: []Limb, a: []<span class="tok-kw">const</span> Limb, b: []<span class="tok-kw">const</span> Limb) <span class="tok-type">void</span> {</span>
<span class="line" id="L3430">    <span class="tok-builtin">@setRuntimeSafety</span>(debug_safety);</span>
<span class="line" id="L3431">    assert(r.len &gt;= a.len + <span class="tok-number">1</span>);</span>
<span class="line" id="L3432">    r[a.len] = lladdcarry(r, a, b);</span>
<span class="line" id="L3433">}</span>
<span class="line" id="L3434"></span>
<span class="line" id="L3435"><span class="tok-comment">/// Knuth 4.3.1, Exercise 16.</span></span>
<span class="line" id="L3436"><span class="tok-kw">fn</span> <span class="tok-fn">lldiv1</span>(quo: []Limb, rem: *Limb, a: []<span class="tok-kw">const</span> Limb, b: Limb) <span class="tok-type">void</span> {</span>
<span class="line" id="L3437">    <span class="tok-builtin">@setRuntimeSafety</span>(debug_safety);</span>
<span class="line" id="L3438">    assert(a.len &gt; <span class="tok-number">1</span> <span class="tok-kw">or</span> a[<span class="tok-number">0</span>] &gt;= b);</span>
<span class="line" id="L3439">    assert(quo.len &gt;= a.len);</span>
<span class="line" id="L3440"></span>
<span class="line" id="L3441">    rem.* = <span class="tok-number">0</span>;</span>
<span class="line" id="L3442">    <span class="tok-kw">for</span> (a) |_, ri| {</span>
<span class="line" id="L3443">        <span class="tok-kw">const</span> i = a.len - ri - <span class="tok-number">1</span>;</span>
<span class="line" id="L3444">        <span class="tok-kw">const</span> pdiv = ((<span class="tok-builtin">@as</span>(DoubleLimb, rem.*) &lt;&lt; limb_bits) | a[i]);</span>
<span class="line" id="L3445"></span>
<span class="line" id="L3446">        <span class="tok-kw">if</span> (pdiv == <span class="tok-number">0</span>) {</span>
<span class="line" id="L3447">            quo[i] = <span class="tok-number">0</span>;</span>
<span class="line" id="L3448">            rem.* = <span class="tok-number">0</span>;</span>
<span class="line" id="L3449">        } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (pdiv &lt; b) {</span>
<span class="line" id="L3450">            quo[i] = <span class="tok-number">0</span>;</span>
<span class="line" id="L3451">            rem.* = <span class="tok-builtin">@truncate</span>(Limb, pdiv);</span>
<span class="line" id="L3452">        } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (pdiv == b) {</span>
<span class="line" id="L3453">            quo[i] = <span class="tok-number">1</span>;</span>
<span class="line" id="L3454">            rem.* = <span class="tok-number">0</span>;</span>
<span class="line" id="L3455">        } <span class="tok-kw">else</span> {</span>
<span class="line" id="L3456">            quo[i] = <span class="tok-builtin">@truncate</span>(Limb, <span class="tok-builtin">@divTrunc</span>(pdiv, b));</span>
<span class="line" id="L3457">            rem.* = <span class="tok-builtin">@truncate</span>(Limb, pdiv - (quo[i] *% b));</span>
<span class="line" id="L3458">        }</span>
<span class="line" id="L3459">    }</span>
<span class="line" id="L3460">}</span>
<span class="line" id="L3461"></span>
<span class="line" id="L3462"><span class="tok-kw">fn</span> <span class="tok-fn">lldiv0p5</span>(quo: []Limb, rem: *Limb, a: []<span class="tok-kw">const</span> Limb, b: HalfLimb) <span class="tok-type">void</span> {</span>
<span class="line" id="L3463">    <span class="tok-builtin">@setRuntimeSafety</span>(debug_safety);</span>
<span class="line" id="L3464">    assert(a.len &gt; <span class="tok-number">1</span> <span class="tok-kw">or</span> a[<span class="tok-number">0</span>] &gt;= b);</span>
<span class="line" id="L3465">    assert(quo.len &gt;= a.len);</span>
<span class="line" id="L3466"></span>
<span class="line" id="L3467">    rem.* = <span class="tok-number">0</span>;</span>
<span class="line" id="L3468">    <span class="tok-kw">for</span> (a) |_, ri| {</span>
<span class="line" id="L3469">        <span class="tok-kw">const</span> i = a.len - ri - <span class="tok-number">1</span>;</span>
<span class="line" id="L3470">        <span class="tok-kw">const</span> ai_high = a[i] &gt;&gt; half_limb_bits;</span>
<span class="line" id="L3471">        <span class="tok-kw">const</span> ai_low = a[i] &amp; ((<span class="tok-number">1</span> &lt;&lt; half_limb_bits) - <span class="tok-number">1</span>);</span>
<span class="line" id="L3472"></span>
<span class="line" id="L3473">        <span class="tok-comment">// Split the division into two divisions acting on half a limb each. Carry remainder.</span>
</span>
<span class="line" id="L3474">        <span class="tok-kw">const</span> ai_high_with_carry = (rem.* &lt;&lt; half_limb_bits) | ai_high;</span>
<span class="line" id="L3475">        <span class="tok-kw">const</span> ai_high_quo = ai_high_with_carry / b;</span>
<span class="line" id="L3476">        rem.* = ai_high_with_carry % b;</span>
<span class="line" id="L3477"></span>
<span class="line" id="L3478">        <span class="tok-kw">const</span> ai_low_with_carry = (rem.* &lt;&lt; half_limb_bits) | ai_low;</span>
<span class="line" id="L3479">        <span class="tok-kw">const</span> ai_low_quo = ai_low_with_carry / b;</span>
<span class="line" id="L3480">        rem.* = ai_low_with_carry % b;</span>
<span class="line" id="L3481"></span>
<span class="line" id="L3482">        quo[i] = (ai_high_quo &lt;&lt; half_limb_bits) | ai_low_quo;</span>
<span class="line" id="L3483">    }</span>
<span class="line" id="L3484">}</span>
<span class="line" id="L3485"></span>
<span class="line" id="L3486"><span class="tok-kw">fn</span> <span class="tok-fn">llshl</span>(r: []Limb, a: []<span class="tok-kw">const</span> Limb, shift: <span class="tok-type">usize</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L3487">    <span class="tok-builtin">@setRuntimeSafety</span>(debug_safety);</span>
<span class="line" id="L3488">    assert(a.len &gt;= <span class="tok-number">1</span>);</span>
<span class="line" id="L3489"></span>
<span class="line" id="L3490">    <span class="tok-kw">const</span> interior_limb_shift = <span class="tok-builtin">@truncate</span>(Log2Limb, shift);</span>
<span class="line" id="L3491"></span>
<span class="line" id="L3492">    <span class="tok-comment">// We only need the extra limb if the shift of the last element overflows.</span>
</span>
<span class="line" id="L3493">    <span class="tok-comment">// This is useful for the implementation of `shiftLeftSat`.</span>
</span>
<span class="line" id="L3494">    <span class="tok-kw">if</span> (a[a.len - <span class="tok-number">1</span>] &lt;&lt; interior_limb_shift &gt;&gt; interior_limb_shift != a[a.len - <span class="tok-number">1</span>]) {</span>
<span class="line" id="L3495">        assert(r.len &gt;= a.len + (shift / limb_bits) + <span class="tok-number">1</span>);</span>
<span class="line" id="L3496">    } <span class="tok-kw">else</span> {</span>
<span class="line" id="L3497">        assert(r.len &gt;= a.len + (shift / limb_bits));</span>
<span class="line" id="L3498">    }</span>
<span class="line" id="L3499"></span>
<span class="line" id="L3500">    <span class="tok-kw">const</span> limb_shift = shift / limb_bits + <span class="tok-number">1</span>;</span>
<span class="line" id="L3501"></span>
<span class="line" id="L3502">    <span class="tok-kw">var</span> carry: Limb = <span class="tok-number">0</span>;</span>
<span class="line" id="L3503">    <span class="tok-kw">var</span> i: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L3504">    <span class="tok-kw">while</span> (i &lt; a.len) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L3505">        <span class="tok-kw">const</span> src_i = a.len - i - <span class="tok-number">1</span>;</span>
<span class="line" id="L3506">        <span class="tok-kw">const</span> dst_i = src_i + limb_shift;</span>
<span class="line" id="L3507"></span>
<span class="line" id="L3508">        <span class="tok-kw">const</span> src_digit = a[src_i];</span>
<span class="line" id="L3509">        r[dst_i] = carry | <span class="tok-builtin">@call</span>(.{ .modifier = .always_inline }, math.shr, .{</span>
<span class="line" id="L3510">            Limb,</span>
<span class="line" id="L3511">            src_digit,</span>
<span class="line" id="L3512">            limb_bits - <span class="tok-builtin">@intCast</span>(Limb, interior_limb_shift),</span>
<span class="line" id="L3513">        });</span>
<span class="line" id="L3514">        carry = (src_digit &lt;&lt; interior_limb_shift);</span>
<span class="line" id="L3515">    }</span>
<span class="line" id="L3516"></span>
<span class="line" id="L3517">    r[limb_shift - <span class="tok-number">1</span>] = carry;</span>
<span class="line" id="L3518">    mem.set(Limb, r[<span class="tok-number">0</span> .. limb_shift - <span class="tok-number">1</span>], <span class="tok-number">0</span>);</span>
<span class="line" id="L3519">}</span>
<span class="line" id="L3520"></span>
<span class="line" id="L3521"><span class="tok-kw">fn</span> <span class="tok-fn">llshr</span>(r: []Limb, a: []<span class="tok-kw">const</span> Limb, shift: <span class="tok-type">usize</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L3522">    <span class="tok-builtin">@setRuntimeSafety</span>(debug_safety);</span>
<span class="line" id="L3523">    assert(a.len &gt;= <span class="tok-number">1</span>);</span>
<span class="line" id="L3524">    assert(r.len &gt;= a.len - (shift / limb_bits));</span>
<span class="line" id="L3525"></span>
<span class="line" id="L3526">    <span class="tok-kw">const</span> limb_shift = shift / limb_bits;</span>
<span class="line" id="L3527">    <span class="tok-kw">const</span> interior_limb_shift = <span class="tok-builtin">@truncate</span>(Log2Limb, shift);</span>
<span class="line" id="L3528"></span>
<span class="line" id="L3529">    <span class="tok-kw">var</span> carry: Limb = <span class="tok-number">0</span>;</span>
<span class="line" id="L3530">    <span class="tok-kw">var</span> i: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L3531">    <span class="tok-kw">while</span> (i &lt; a.len - limb_shift) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L3532">        <span class="tok-kw">const</span> src_i = a.len - i - <span class="tok-number">1</span>;</span>
<span class="line" id="L3533">        <span class="tok-kw">const</span> dst_i = src_i - limb_shift;</span>
<span class="line" id="L3534"></span>
<span class="line" id="L3535">        <span class="tok-kw">const</span> src_digit = a[src_i];</span>
<span class="line" id="L3536">        r[dst_i] = carry | (src_digit &gt;&gt; interior_limb_shift);</span>
<span class="line" id="L3537">        carry = <span class="tok-builtin">@call</span>(.{ .modifier = .always_inline }, math.shl, .{</span>
<span class="line" id="L3538">            Limb,</span>
<span class="line" id="L3539">            src_digit,</span>
<span class="line" id="L3540">            limb_bits - <span class="tok-builtin">@intCast</span>(Limb, interior_limb_shift),</span>
<span class="line" id="L3541">        });</span>
<span class="line" id="L3542">    }</span>
<span class="line" id="L3543">}</span>
<span class="line" id="L3544"></span>
<span class="line" id="L3545"><span class="tok-comment">// r = ~r</span>
</span>
<span class="line" id="L3546"><span class="tok-kw">fn</span> <span class="tok-fn">llnot</span>(r: []Limb) <span class="tok-type">void</span> {</span>
<span class="line" id="L3547">    <span class="tok-builtin">@setRuntimeSafety</span>(debug_safety);</span>
<span class="line" id="L3548"></span>
<span class="line" id="L3549">    <span class="tok-kw">for</span> (r) |*elem| {</span>
<span class="line" id="L3550">        elem.* = ~elem.*;</span>
<span class="line" id="L3551">    }</span>
<span class="line" id="L3552">}</span>
<span class="line" id="L3553"></span>
<span class="line" id="L3554"><span class="tok-comment">// r = a | b with 2s complement semantics.</span>
</span>
<span class="line" id="L3555"><span class="tok-comment">// r may alias.</span>
</span>
<span class="line" id="L3556"><span class="tok-comment">// a and b must not be 0.</span>
</span>
<span class="line" id="L3557"><span class="tok-comment">// Returns `true` when the result is positive.</span>
</span>
<span class="line" id="L3558"><span class="tok-comment">// When b is positive, r requires at least `a.len` limbs of storage.</span>
</span>
<span class="line" id="L3559"><span class="tok-comment">// When b is negative, r requires at least `b.len` limbs of storage.</span>
</span>
<span class="line" id="L3560"><span class="tok-kw">fn</span> <span class="tok-fn">llsignedor</span>(r: []Limb, a: []<span class="tok-kw">const</span> Limb, a_positive: <span class="tok-type">bool</span>, b: []<span class="tok-kw">const</span> Limb, b_positive: <span class="tok-type">bool</span>) <span class="tok-type">bool</span> {</span>
<span class="line" id="L3561">    <span class="tok-builtin">@setRuntimeSafety</span>(debug_safety);</span>
<span class="line" id="L3562">    assert(r.len &gt;= a.len);</span>
<span class="line" id="L3563">    assert(a.len &gt;= b.len);</span>
<span class="line" id="L3564"></span>
<span class="line" id="L3565">    <span class="tok-kw">if</span> (a_positive <span class="tok-kw">and</span> b_positive) {</span>
<span class="line" id="L3566">        <span class="tok-comment">// Trivial case, result is positive.</span>
</span>
<span class="line" id="L3567">        <span class="tok-kw">var</span> i: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L3568">        <span class="tok-kw">while</span> (i &lt; b.len) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L3569">            r[i] = a[i] | b[i];</span>
<span class="line" id="L3570">        }</span>
<span class="line" id="L3571">        <span class="tok-kw">while</span> (i &lt; a.len) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L3572">            r[i] = a[i];</span>
<span class="line" id="L3573">        }</span>
<span class="line" id="L3574"></span>
<span class="line" id="L3575">        <span class="tok-kw">return</span> <span class="tok-null">true</span>;</span>
<span class="line" id="L3576">    } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (!a_positive <span class="tok-kw">and</span> b_positive) {</span>
<span class="line" id="L3577">        <span class="tok-comment">// Result is negative.</span>
</span>
<span class="line" id="L3578">        <span class="tok-comment">// r = (--a) | b</span>
</span>
<span class="line" id="L3579">        <span class="tok-comment">//   = ~(-a - 1) | b</span>
</span>
<span class="line" id="L3580">        <span class="tok-comment">//   = ~(-a - 1) | ~~b</span>
</span>
<span class="line" id="L3581">        <span class="tok-comment">//   = ~((-a - 1) &amp; ~b)</span>
</span>
<span class="line" id="L3582">        <span class="tok-comment">//   = -(((-a - 1) &amp; ~b) + 1)</span>
</span>
<span class="line" id="L3583"></span>
<span class="line" id="L3584">        <span class="tok-kw">var</span> i: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L3585">        <span class="tok-kw">var</span> a_borrow: <span class="tok-type">u1</span> = <span class="tok-number">1</span>;</span>
<span class="line" id="L3586">        <span class="tok-kw">var</span> r_carry: <span class="tok-type">u1</span> = <span class="tok-number">1</span>;</span>
<span class="line" id="L3587"></span>
<span class="line" id="L3588">        <span class="tok-kw">while</span> (i &lt; b.len) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L3589">            <span class="tok-kw">var</span> a_limb: Limb = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L3590">            a_borrow = <span class="tok-builtin">@boolToInt</span>(<span class="tok-builtin">@subWithOverflow</span>(Limb, a[i], a_borrow, &amp;a_limb));</span>
<span class="line" id="L3591"></span>
<span class="line" id="L3592">            r[i] = a_limb &amp; ~b[i];</span>
<span class="line" id="L3593">            r_carry = <span class="tok-builtin">@boolToInt</span>(<span class="tok-builtin">@addWithOverflow</span>(Limb, r[i], r_carry, &amp;r[i]));</span>
<span class="line" id="L3594">        }</span>
<span class="line" id="L3595"></span>
<span class="line" id="L3596">        <span class="tok-comment">// In order for r_carry to be nonzero at this point, ~b[i] would need to be</span>
</span>
<span class="line" id="L3597">        <span class="tok-comment">// all ones, which would require b[i] to be zero. This cannot be when</span>
</span>
<span class="line" id="L3598">        <span class="tok-comment">// b is normalized, so there cannot be a carry here.</span>
</span>
<span class="line" id="L3599">        <span class="tok-comment">// Also, x &amp; ~b can only clear bits, so (x &amp; ~b) &lt;= x, meaning (-a - 1) + 1 never overflows.</span>
</span>
<span class="line" id="L3600">        assert(r_carry == <span class="tok-number">0</span>);</span>
<span class="line" id="L3601"></span>
<span class="line" id="L3602">        <span class="tok-comment">// With b = 0, we get (-a - 1) &amp; ~0 = -a - 1.</span>
</span>
<span class="line" id="L3603">        <span class="tok-comment">// Note, if a_borrow is zero we do not need to compute anything for</span>
</span>
<span class="line" id="L3604">        <span class="tok-comment">// the higher limbs so we can early return here.</span>
</span>
<span class="line" id="L3605">        <span class="tok-kw">while</span> (i &lt; a.len <span class="tok-kw">and</span> a_borrow == <span class="tok-number">1</span>) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L3606">            a_borrow = <span class="tok-builtin">@boolToInt</span>(<span class="tok-builtin">@subWithOverflow</span>(Limb, a[i], a_borrow, &amp;r[i]));</span>
<span class="line" id="L3607">        }</span>
<span class="line" id="L3608"></span>
<span class="line" id="L3609">        assert(a_borrow == <span class="tok-number">0</span>); <span class="tok-comment">// a was 0.</span>
</span>
<span class="line" id="L3610"></span>
<span class="line" id="L3611">        <span class="tok-kw">return</span> <span class="tok-null">false</span>;</span>
<span class="line" id="L3612">    } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (a_positive <span class="tok-kw">and</span> !b_positive) {</span>
<span class="line" id="L3613">        <span class="tok-comment">// Result is negative.</span>
</span>
<span class="line" id="L3614">        <span class="tok-comment">// r = a | (--b)</span>
</span>
<span class="line" id="L3615">        <span class="tok-comment">//   = a | ~(-b - 1)</span>
</span>
<span class="line" id="L3616">        <span class="tok-comment">//   = ~~a | ~(-b - 1)</span>
</span>
<span class="line" id="L3617">        <span class="tok-comment">//   = ~(~a &amp; (-b - 1))</span>
</span>
<span class="line" id="L3618">        <span class="tok-comment">//   = -((~a &amp; (-b - 1)) + 1)</span>
</span>
<span class="line" id="L3619"></span>
<span class="line" id="L3620">        <span class="tok-kw">var</span> i: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L3621">        <span class="tok-kw">var</span> b_borrow: <span class="tok-type">u1</span> = <span class="tok-number">1</span>;</span>
<span class="line" id="L3622">        <span class="tok-kw">var</span> r_carry: <span class="tok-type">u1</span> = <span class="tok-number">1</span>;</span>
<span class="line" id="L3623"></span>
<span class="line" id="L3624">        <span class="tok-kw">while</span> (i &lt; b.len) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L3625">            <span class="tok-kw">var</span> b_limb: Limb = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L3626">            b_borrow = <span class="tok-builtin">@boolToInt</span>(<span class="tok-builtin">@subWithOverflow</span>(Limb, b[i], b_borrow, &amp;b_limb));</span>
<span class="line" id="L3627"></span>
<span class="line" id="L3628">            r[i] = ~a[i] &amp; b_limb;</span>
<span class="line" id="L3629">            r_carry = <span class="tok-builtin">@boolToInt</span>(<span class="tok-builtin">@addWithOverflow</span>(Limb, r[i], r_carry, &amp;r[i]));</span>
<span class="line" id="L3630">        }</span>
<span class="line" id="L3631"></span>
<span class="line" id="L3632">        <span class="tok-comment">// b is at least 1, so this should never underflow.</span>
</span>
<span class="line" id="L3633">        assert(b_borrow == <span class="tok-number">0</span>); <span class="tok-comment">// b was 0</span>
</span>
<span class="line" id="L3634"></span>
<span class="line" id="L3635">        <span class="tok-comment">// x &amp; ~a can only clear bits, so (x &amp; ~a) &lt;= x, meaning (-b - 1) + 1 never overflows.</span>
</span>
<span class="line" id="L3636">        assert(r_carry == <span class="tok-number">0</span>);</span>
<span class="line" id="L3637"></span>
<span class="line" id="L3638">        <span class="tok-comment">// With b = 0 and b_borrow = 0, we get ~a &amp; (-0 - 0) = ~a &amp; 0 = 0.</span>
</span>
<span class="line" id="L3639">        <span class="tok-comment">// Omit setting the upper bytes, just deal with those when calling llsignedor.</span>
</span>
<span class="line" id="L3640"></span>
<span class="line" id="L3641">        <span class="tok-kw">return</span> <span class="tok-null">false</span>;</span>
<span class="line" id="L3642">    } <span class="tok-kw">else</span> {</span>
<span class="line" id="L3643">        <span class="tok-comment">// Result is negative.</span>
</span>
<span class="line" id="L3644">        <span class="tok-comment">// r = (--a) | (--b)</span>
</span>
<span class="line" id="L3645">        <span class="tok-comment">//   = ~(-a - 1) | ~(-b - 1)</span>
</span>
<span class="line" id="L3646">        <span class="tok-comment">//   = ~((-a - 1) &amp; (-b - 1))</span>
</span>
<span class="line" id="L3647">        <span class="tok-comment">//   = -(~(~((-a - 1) &amp; (-b - 1))) + 1)</span>
</span>
<span class="line" id="L3648">        <span class="tok-comment">//   = -((-a - 1) &amp; (-b - 1) + 1)</span>
</span>
<span class="line" id="L3649"></span>
<span class="line" id="L3650">        <span class="tok-kw">var</span> i: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L3651">        <span class="tok-kw">var</span> a_borrow: <span class="tok-type">u1</span> = <span class="tok-number">1</span>;</span>
<span class="line" id="L3652">        <span class="tok-kw">var</span> b_borrow: <span class="tok-type">u1</span> = <span class="tok-number">1</span>;</span>
<span class="line" id="L3653">        <span class="tok-kw">var</span> r_carry: <span class="tok-type">u1</span> = <span class="tok-number">1</span>;</span>
<span class="line" id="L3654"></span>
<span class="line" id="L3655">        <span class="tok-kw">while</span> (i &lt; b.len) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L3656">            <span class="tok-kw">var</span> a_limb: Limb = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L3657">            a_borrow = <span class="tok-builtin">@boolToInt</span>(<span class="tok-builtin">@subWithOverflow</span>(Limb, a[i], a_borrow, &amp;a_limb));</span>
<span class="line" id="L3658"></span>
<span class="line" id="L3659">            <span class="tok-kw">var</span> b_limb: Limb = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L3660">            b_borrow = <span class="tok-builtin">@boolToInt</span>(<span class="tok-builtin">@subWithOverflow</span>(Limb, b[i], b_borrow, &amp;b_limb));</span>
<span class="line" id="L3661"></span>
<span class="line" id="L3662">            r[i] = a_limb &amp; b_limb;</span>
<span class="line" id="L3663">            r_carry = <span class="tok-builtin">@boolToInt</span>(<span class="tok-builtin">@addWithOverflow</span>(Limb, r[i], r_carry, &amp;r[i]));</span>
<span class="line" id="L3664">        }</span>
<span class="line" id="L3665"></span>
<span class="line" id="L3666">        <span class="tok-comment">// b is at least 1, so this should never underflow.</span>
</span>
<span class="line" id="L3667">        assert(b_borrow == <span class="tok-number">0</span>); <span class="tok-comment">// b was 0</span>
</span>
<span class="line" id="L3668"></span>
<span class="line" id="L3669">        <span class="tok-comment">// Can never overflow because in order for b_limb to be maxInt(Limb),</span>
</span>
<span class="line" id="L3670">        <span class="tok-comment">// b_borrow would need to equal 1.</span>
</span>
<span class="line" id="L3671"></span>
<span class="line" id="L3672">        <span class="tok-comment">// x &amp; y can only clear bits, meaning x &amp; y &lt;= x and x &amp; y &lt;= y. This implies that</span>
</span>
<span class="line" id="L3673">        <span class="tok-comment">// for x = a - 1 and y = b - 1, the +1 term would never cause an overflow.</span>
</span>
<span class="line" id="L3674">        assert(r_carry == <span class="tok-number">0</span>);</span>
<span class="line" id="L3675"></span>
<span class="line" id="L3676">        <span class="tok-comment">// With b = 0 and b_borrow = 0 we get (-a - 1) &amp; (-0 - 0) = (-a - 1) &amp; 0 = 0.</span>
</span>
<span class="line" id="L3677">        <span class="tok-comment">// Omit setting the upper bytes, just deal with those when calling llsignedor.</span>
</span>
<span class="line" id="L3678">        <span class="tok-kw">return</span> <span class="tok-null">false</span>;</span>
<span class="line" id="L3679">    }</span>
<span class="line" id="L3680">}</span>
<span class="line" id="L3681"></span>
<span class="line" id="L3682"><span class="tok-comment">// r = a &amp; b with 2s complement semantics.</span>
</span>
<span class="line" id="L3683"><span class="tok-comment">// r may alias.</span>
</span>
<span class="line" id="L3684"><span class="tok-comment">// a and b must not be 0.</span>
</span>
<span class="line" id="L3685"><span class="tok-comment">// Returns `true` when the result is positive.</span>
</span>
<span class="line" id="L3686"><span class="tok-comment">// When either or both of a and b are positive, r requires at least `b.len` limbs of storage.</span>
</span>
<span class="line" id="L3687"><span class="tok-comment">// When both a and b are negative, r requires at least `a.limbs.len + 1` limbs of storage.</span>
</span>
<span class="line" id="L3688"><span class="tok-kw">fn</span> <span class="tok-fn">llsignedand</span>(r: []Limb, a: []<span class="tok-kw">const</span> Limb, a_positive: <span class="tok-type">bool</span>, b: []<span class="tok-kw">const</span> Limb, b_positive: <span class="tok-type">bool</span>) <span class="tok-type">bool</span> {</span>
<span class="line" id="L3689">    <span class="tok-builtin">@setRuntimeSafety</span>(debug_safety);</span>
<span class="line" id="L3690">    assert(a.len != <span class="tok-number">0</span> <span class="tok-kw">and</span> b.len != <span class="tok-number">0</span>);</span>
<span class="line" id="L3691">    assert(a.len &gt;= b.len);</span>
<span class="line" id="L3692">    assert(r.len &gt;= <span class="tok-kw">if</span> (!a_positive <span class="tok-kw">and</span> !b_positive) a.len + <span class="tok-number">1</span> <span class="tok-kw">else</span> b.len);</span>
<span class="line" id="L3693"></span>
<span class="line" id="L3694">    <span class="tok-kw">if</span> (a_positive <span class="tok-kw">and</span> b_positive) {</span>
<span class="line" id="L3695">        <span class="tok-comment">// Trivial case, result is positive.</span>
</span>
<span class="line" id="L3696">        <span class="tok-kw">var</span> i: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L3697">        <span class="tok-kw">while</span> (i &lt; b.len) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L3698">            r[i] = a[i] &amp; b[i];</span>
<span class="line" id="L3699">        }</span>
<span class="line" id="L3700"></span>
<span class="line" id="L3701">        <span class="tok-comment">// With b = 0 we have a &amp; 0 = 0, so the upper bytes are zero.</span>
</span>
<span class="line" id="L3702">        <span class="tok-comment">// Omit setting them here and simply discard them whenever</span>
</span>
<span class="line" id="L3703">        <span class="tok-comment">// llsignedand is called.</span>
</span>
<span class="line" id="L3704"></span>
<span class="line" id="L3705">        <span class="tok-kw">return</span> <span class="tok-null">true</span>;</span>
<span class="line" id="L3706">    } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (!a_positive <span class="tok-kw">and</span> b_positive) {</span>
<span class="line" id="L3707">        <span class="tok-comment">// Result is positive.</span>
</span>
<span class="line" id="L3708">        <span class="tok-comment">// r = (--a) &amp; b</span>
</span>
<span class="line" id="L3709">        <span class="tok-comment">//   = ~(-a - 1) &amp; b</span>
</span>
<span class="line" id="L3710"></span>
<span class="line" id="L3711">        <span class="tok-kw">var</span> i: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L3712">        <span class="tok-kw">var</span> a_borrow: <span class="tok-type">u1</span> = <span class="tok-number">1</span>;</span>
<span class="line" id="L3713"></span>
<span class="line" id="L3714">        <span class="tok-kw">while</span> (i &lt; b.len) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L3715">            <span class="tok-kw">var</span> a_limb: Limb = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L3716">            a_borrow = <span class="tok-builtin">@boolToInt</span>(<span class="tok-builtin">@subWithOverflow</span>(Limb, a[i], a_borrow, &amp;a_limb));</span>
<span class="line" id="L3717">            r[i] = ~a_limb &amp; b[i];</span>
<span class="line" id="L3718">        }</span>
<span class="line" id="L3719"></span>
<span class="line" id="L3720">        <span class="tok-comment">// With b = 0 we have ~(a - 1) &amp; 0 = 0, so the upper bytes are zero.</span>
</span>
<span class="line" id="L3721">        <span class="tok-comment">// Omit setting them here and simply discard them whenever</span>
</span>
<span class="line" id="L3722">        <span class="tok-comment">// llsignedand is called.</span>
</span>
<span class="line" id="L3723"></span>
<span class="line" id="L3724">        <span class="tok-kw">return</span> <span class="tok-null">true</span>;</span>
<span class="line" id="L3725">    } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (a_positive <span class="tok-kw">and</span> !b_positive) {</span>
<span class="line" id="L3726">        <span class="tok-comment">// Result is positive.</span>
</span>
<span class="line" id="L3727">        <span class="tok-comment">// r = a &amp; (--b)</span>
</span>
<span class="line" id="L3728">        <span class="tok-comment">//   = a &amp; ~(-b - 1)</span>
</span>
<span class="line" id="L3729"></span>
<span class="line" id="L3730">        <span class="tok-kw">var</span> i: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L3731">        <span class="tok-kw">var</span> b_borrow: <span class="tok-type">u1</span> = <span class="tok-number">1</span>;</span>
<span class="line" id="L3732"></span>
<span class="line" id="L3733">        <span class="tok-kw">while</span> (i &lt; b.len) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L3734">            <span class="tok-kw">var</span> a_limb: Limb = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L3735">            b_borrow = <span class="tok-builtin">@boolToInt</span>(<span class="tok-builtin">@subWithOverflow</span>(Limb, b[i], b_borrow, &amp;a_limb));</span>
<span class="line" id="L3736">            r[i] = a[i] &amp; ~a_limb;</span>
<span class="line" id="L3737">        }</span>
<span class="line" id="L3738"></span>
<span class="line" id="L3739">        assert(b_borrow == <span class="tok-number">0</span>); <span class="tok-comment">// b was 0</span>
</span>
<span class="line" id="L3740"></span>
<span class="line" id="L3741">        <span class="tok-comment">// With b = 0 and b_borrow = 0 we have a &amp; ~(-0 - 0) = a &amp; 0 = 0, so</span>
</span>
<span class="line" id="L3742">        <span class="tok-comment">// the upper bytes are zero.  Omit setting them here and simply discard</span>
</span>
<span class="line" id="L3743">        <span class="tok-comment">// them whenever llsignedand is called.</span>
</span>
<span class="line" id="L3744"></span>
<span class="line" id="L3745">        <span class="tok-kw">return</span> <span class="tok-null">true</span>;</span>
<span class="line" id="L3746">    } <span class="tok-kw">else</span> {</span>
<span class="line" id="L3747">        <span class="tok-comment">// Result is negative.</span>
</span>
<span class="line" id="L3748">        <span class="tok-comment">// r = (--a) &amp; (--b)</span>
</span>
<span class="line" id="L3749">        <span class="tok-comment">//   = ~(-a - 1) &amp; ~(-b - 1)</span>
</span>
<span class="line" id="L3750">        <span class="tok-comment">//   = ~((-a - 1) | (-b - 1))</span>
</span>
<span class="line" id="L3751">        <span class="tok-comment">//   = -(((-a - 1) | (-b - 1)) + 1)</span>
</span>
<span class="line" id="L3752"></span>
<span class="line" id="L3753">        <span class="tok-kw">var</span> i: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L3754">        <span class="tok-kw">var</span> a_borrow: <span class="tok-type">u1</span> = <span class="tok-number">1</span>;</span>
<span class="line" id="L3755">        <span class="tok-kw">var</span> b_borrow: <span class="tok-type">u1</span> = <span class="tok-number">1</span>;</span>
<span class="line" id="L3756">        <span class="tok-kw">var</span> r_carry: <span class="tok-type">u1</span> = <span class="tok-number">1</span>;</span>
<span class="line" id="L3757"></span>
<span class="line" id="L3758">        <span class="tok-kw">while</span> (i &lt; b.len) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L3759">            <span class="tok-kw">var</span> a_limb: Limb = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L3760">            a_borrow = <span class="tok-builtin">@boolToInt</span>(<span class="tok-builtin">@subWithOverflow</span>(Limb, a[i], a_borrow, &amp;a_limb));</span>
<span class="line" id="L3761"></span>
<span class="line" id="L3762">            <span class="tok-kw">var</span> b_limb: Limb = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L3763">            b_borrow = <span class="tok-builtin">@boolToInt</span>(<span class="tok-builtin">@subWithOverflow</span>(Limb, b[i], b_borrow, &amp;b_limb));</span>
<span class="line" id="L3764"></span>
<span class="line" id="L3765">            r[i] = a_limb | b_limb;</span>
<span class="line" id="L3766">            r_carry = <span class="tok-builtin">@boolToInt</span>(<span class="tok-builtin">@addWithOverflow</span>(Limb, r[i], r_carry, &amp;r[i]));</span>
<span class="line" id="L3767">        }</span>
<span class="line" id="L3768"></span>
<span class="line" id="L3769">        <span class="tok-comment">// b is at least 1, so this should never underflow.</span>
</span>
<span class="line" id="L3770">        assert(b_borrow == <span class="tok-number">0</span>); <span class="tok-comment">// b was 0</span>
</span>
<span class="line" id="L3771"></span>
<span class="line" id="L3772">        <span class="tok-comment">// With b = 0 and b_borrow = 0 we get (-a - 1) | (-0 - 0) = (-a - 1) | 0 = -a - 1.</span>
</span>
<span class="line" id="L3773">        <span class="tok-kw">while</span> (i &lt; a.len) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L3774">            a_borrow = <span class="tok-builtin">@boolToInt</span>(<span class="tok-builtin">@subWithOverflow</span>(Limb, a[i], a_borrow, &amp;r[i]));</span>
<span class="line" id="L3775">            r_carry = <span class="tok-builtin">@boolToInt</span>(<span class="tok-builtin">@addWithOverflow</span>(Limb, r[i], r_carry, &amp;r[i]));</span>
<span class="line" id="L3776">        }</span>
<span class="line" id="L3777"></span>
<span class="line" id="L3778">        assert(a_borrow == <span class="tok-number">0</span>); <span class="tok-comment">// a was 0.</span>
</span>
<span class="line" id="L3779"></span>
<span class="line" id="L3780">        <span class="tok-comment">// The final addition can overflow here, so we need to keep that in mind.</span>
</span>
<span class="line" id="L3781">        r[i] = r_carry;</span>
<span class="line" id="L3782"></span>
<span class="line" id="L3783">        <span class="tok-kw">return</span> <span class="tok-null">false</span>;</span>
<span class="line" id="L3784">    }</span>
<span class="line" id="L3785">}</span>
<span class="line" id="L3786"></span>
<span class="line" id="L3787"><span class="tok-comment">// r = a ^ b with 2s complement semantics.</span>
</span>
<span class="line" id="L3788"><span class="tok-comment">// r may alias.</span>
</span>
<span class="line" id="L3789"><span class="tok-comment">// a and b must not be -0.</span>
</span>
<span class="line" id="L3790"><span class="tok-comment">// Returns `true` when the result is positive.</span>
</span>
<span class="line" id="L3791"><span class="tok-comment">// If the sign of a and b is equal, then r requires at least `max(a.len, b.len)` limbs are required.</span>
</span>
<span class="line" id="L3792"><span class="tok-comment">// Otherwise, r requires at least `max(a.len, b.len) + 1` limbs.</span>
</span>
<span class="line" id="L3793"><span class="tok-kw">fn</span> <span class="tok-fn">llsignedxor</span>(r: []Limb, a: []<span class="tok-kw">const</span> Limb, a_positive: <span class="tok-type">bool</span>, b: []<span class="tok-kw">const</span> Limb, b_positive: <span class="tok-type">bool</span>) <span class="tok-type">bool</span> {</span>
<span class="line" id="L3794">    <span class="tok-builtin">@setRuntimeSafety</span>(debug_safety);</span>
<span class="line" id="L3795">    assert(a.len != <span class="tok-number">0</span> <span class="tok-kw">and</span> b.len != <span class="tok-number">0</span>);</span>
<span class="line" id="L3796">    assert(r.len &gt;= a.len);</span>
<span class="line" id="L3797">    assert(a.len &gt;= b.len);</span>
<span class="line" id="L3798"></span>
<span class="line" id="L3799">    <span class="tok-comment">// If a and b are positive, the result is positive and r = a ^ b.</span>
</span>
<span class="line" id="L3800">    <span class="tok-comment">// If a negative, b positive, result is negative and we have</span>
</span>
<span class="line" id="L3801">    <span class="tok-comment">// r = --(--a ^ b)</span>
</span>
<span class="line" id="L3802">    <span class="tok-comment">//   = --(~(-a - 1) ^ b)</span>
</span>
<span class="line" id="L3803">    <span class="tok-comment">//   = -(~(~(-a - 1) ^ b) + 1)</span>
</span>
<span class="line" id="L3804">    <span class="tok-comment">//   = -(((-a - 1) ^ b) + 1)</span>
</span>
<span class="line" id="L3805">    <span class="tok-comment">// Same if a is positive and b is negative, sides switched.</span>
</span>
<span class="line" id="L3806">    <span class="tok-comment">// If both a and b are negative, the result is positive and we have</span>
</span>
<span class="line" id="L3807">    <span class="tok-comment">// r = (--a) ^ (--b)</span>
</span>
<span class="line" id="L3808">    <span class="tok-comment">//   = ~(-a - 1) ^ ~(-b - 1)</span>
</span>
<span class="line" id="L3809">    <span class="tok-comment">//   = (-a - 1) ^ (-b - 1)</span>
</span>
<span class="line" id="L3810">    <span class="tok-comment">// These operations can be made more generic as follows:</span>
</span>
<span class="line" id="L3811">    <span class="tok-comment">// - If a is negative, subtract 1 from |a| before the xor.</span>
</span>
<span class="line" id="L3812">    <span class="tok-comment">// - If b is negative, subtract 1 from |b| before the xor.</span>
</span>
<span class="line" id="L3813">    <span class="tok-comment">// - if the result is supposed to be negative, add 1.</span>
</span>
<span class="line" id="L3814"></span>
<span class="line" id="L3815">    <span class="tok-kw">var</span> i: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L3816">    <span class="tok-kw">var</span> a_borrow = <span class="tok-builtin">@boolToInt</span>(!a_positive);</span>
<span class="line" id="L3817">    <span class="tok-kw">var</span> b_borrow = <span class="tok-builtin">@boolToInt</span>(!b_positive);</span>
<span class="line" id="L3818">    <span class="tok-kw">var</span> r_carry = <span class="tok-builtin">@boolToInt</span>(a_positive != b_positive);</span>
<span class="line" id="L3819"></span>
<span class="line" id="L3820">    <span class="tok-kw">while</span> (i &lt; b.len) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L3821">        <span class="tok-kw">var</span> a_limb: Limb = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L3822">        a_borrow = <span class="tok-builtin">@boolToInt</span>(<span class="tok-builtin">@subWithOverflow</span>(Limb, a[i], a_borrow, &amp;a_limb));</span>
<span class="line" id="L3823"></span>
<span class="line" id="L3824">        <span class="tok-kw">var</span> b_limb: Limb = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L3825">        b_borrow = <span class="tok-builtin">@boolToInt</span>(<span class="tok-builtin">@subWithOverflow</span>(Limb, b[i], b_borrow, &amp;b_limb));</span>
<span class="line" id="L3826"></span>
<span class="line" id="L3827">        r[i] = a_limb ^ b_limb;</span>
<span class="line" id="L3828">        r_carry = <span class="tok-builtin">@boolToInt</span>(<span class="tok-builtin">@addWithOverflow</span>(Limb, r[i], r_carry, &amp;r[i]));</span>
<span class="line" id="L3829">    }</span>
<span class="line" id="L3830"></span>
<span class="line" id="L3831">    <span class="tok-kw">while</span> (i &lt; a.len) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L3832">        a_borrow = <span class="tok-builtin">@boolToInt</span>(<span class="tok-builtin">@subWithOverflow</span>(Limb, a[i], a_borrow, &amp;r[i]));</span>
<span class="line" id="L3833">        r_carry = <span class="tok-builtin">@boolToInt</span>(<span class="tok-builtin">@addWithOverflow</span>(Limb, r[i], r_carry, &amp;r[i]));</span>
<span class="line" id="L3834">    }</span>
<span class="line" id="L3835"></span>
<span class="line" id="L3836">    <span class="tok-comment">// If both inputs don't share the same sign, an extra limb is required.</span>
</span>
<span class="line" id="L3837">    <span class="tok-kw">if</span> (a_positive != b_positive) {</span>
<span class="line" id="L3838">        r[i] = r_carry;</span>
<span class="line" id="L3839">    } <span class="tok-kw">else</span> {</span>
<span class="line" id="L3840">        assert(r_carry == <span class="tok-number">0</span>);</span>
<span class="line" id="L3841">    }</span>
<span class="line" id="L3842"></span>
<span class="line" id="L3843">    assert(a_borrow == <span class="tok-number">0</span>);</span>
<span class="line" id="L3844">    assert(b_borrow == <span class="tok-number">0</span>);</span>
<span class="line" id="L3845"></span>
<span class="line" id="L3846">    <span class="tok-kw">return</span> a_positive == b_positive;</span>
<span class="line" id="L3847">}</span>
<span class="line" id="L3848"></span>
<span class="line" id="L3849"><span class="tok-comment">/// r MUST NOT alias x.</span></span>
<span class="line" id="L3850"><span class="tok-kw">fn</span> <span class="tok-fn">llsquareBasecase</span>(r: []Limb, x: []<span class="tok-kw">const</span> Limb) <span class="tok-type">void</span> {</span>
<span class="line" id="L3851">    <span class="tok-builtin">@setRuntimeSafety</span>(debug_safety);</span>
<span class="line" id="L3852"></span>
<span class="line" id="L3853">    <span class="tok-kw">const</span> x_norm = x;</span>
<span class="line" id="L3854">    assert(r.len &gt;= <span class="tok-number">2</span> * x_norm.len + <span class="tok-number">1</span>);</span>
<span class="line" id="L3855"></span>
<span class="line" id="L3856">    <span class="tok-comment">// Compute the square of a N-limb bigint with only (N^2 + N)/2</span>
</span>
<span class="line" id="L3857">    <span class="tok-comment">// multiplications by exploting the symmetry of the coefficients around the</span>
</span>
<span class="line" id="L3858">    <span class="tok-comment">// diagonal:</span>
</span>
<span class="line" id="L3859">    <span class="tok-comment">//</span>
</span>
<span class="line" id="L3860">    <span class="tok-comment">//           a   b   c *</span>
</span>
<span class="line" id="L3861">    <span class="tok-comment">//           a   b   c =</span>
</span>
<span class="line" id="L3862">    <span class="tok-comment">// -------------------</span>
</span>
<span class="line" id="L3863">    <span class="tok-comment">//          ca  cb  cc +</span>
</span>
<span class="line" id="L3864">    <span class="tok-comment">//      ba  bb  bc     +</span>
</span>
<span class="line" id="L3865">    <span class="tok-comment">//  aa  ab  ac</span>
</span>
<span class="line" id="L3866">    <span class="tok-comment">//</span>
</span>
<span class="line" id="L3867">    <span class="tok-comment">// Note that:</span>
</span>
<span class="line" id="L3868">    <span class="tok-comment">//  - Each mixed-product term appears twice for each column,</span>
</span>
<span class="line" id="L3869">    <span class="tok-comment">//  - Squares are always in the 2k (0 &lt;= k &lt; N) column</span>
</span>
<span class="line" id="L3870"></span>
<span class="line" id="L3871">    <span class="tok-kw">for</span> (x_norm) |v, i| {</span>
<span class="line" id="L3872">        <span class="tok-comment">// Accumulate all the x[i]*x[j] (with x!=j) products</span>
</span>
<span class="line" id="L3873">        <span class="tok-kw">const</span> overflow = llmulLimb(.add, r[<span class="tok-number">2</span> * i + <span class="tok-number">1</span> ..], x_norm[i + <span class="tok-number">1</span> ..], v);</span>
<span class="line" id="L3874">        assert(!overflow);</span>
<span class="line" id="L3875">    }</span>
<span class="line" id="L3876"></span>
<span class="line" id="L3877">    <span class="tok-comment">// Each product appears twice, multiply by 2</span>
</span>
<span class="line" id="L3878">    llshl(r, r[<span class="tok-number">0</span> .. <span class="tok-number">2</span> * x_norm.len], <span class="tok-number">1</span>);</span>
<span class="line" id="L3879"></span>
<span class="line" id="L3880">    <span class="tok-kw">for</span> (x_norm) |v, i| {</span>
<span class="line" id="L3881">        <span class="tok-comment">// Compute and add the squares</span>
</span>
<span class="line" id="L3882">        <span class="tok-kw">const</span> overflow = llmulLimb(.add, r[<span class="tok-number">2</span> * i ..], x[i .. i + <span class="tok-number">1</span>], v);</span>
<span class="line" id="L3883">        assert(!overflow);</span>
<span class="line" id="L3884">    }</span>
<span class="line" id="L3885">}</span>
<span class="line" id="L3886"></span>
<span class="line" id="L3887"><span class="tok-comment">/// Knuth 4.6.3</span></span>
<span class="line" id="L3888"><span class="tok-kw">fn</span> <span class="tok-fn">llpow</span>(r: []Limb, a: []<span class="tok-kw">const</span> Limb, b: <span class="tok-type">u32</span>, tmp_limbs: []Limb) <span class="tok-type">void</span> {</span>
<span class="line" id="L3889">    <span class="tok-kw">var</span> tmp1: []Limb = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L3890">    <span class="tok-kw">var</span> tmp2: []Limb = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L3891"></span>
<span class="line" id="L3892">    <span class="tok-comment">// Multiplication requires no aliasing between the operand and the result</span>
</span>
<span class="line" id="L3893">    <span class="tok-comment">// variable, use the output limbs and another temporary set to overcome this</span>
</span>
<span class="line" id="L3894">    <span class="tok-comment">// limitation.</span>
</span>
<span class="line" id="L3895">    <span class="tok-comment">// The initial assignment makes the result end in `r` so an extra memory</span>
</span>
<span class="line" id="L3896">    <span class="tok-comment">// copy is saved, each 1 flips the index twice so it's only the zeros that</span>
</span>
<span class="line" id="L3897">    <span class="tok-comment">// matter.</span>
</span>
<span class="line" id="L3898">    <span class="tok-kw">const</span> b_leading_zeros = <span class="tok-builtin">@clz</span>(<span class="tok-type">u32</span>, b);</span>
<span class="line" id="L3899">    <span class="tok-kw">const</span> exp_zeros = <span class="tok-builtin">@popCount</span>(<span class="tok-type">u32</span>, ~b) - b_leading_zeros;</span>
<span class="line" id="L3900">    <span class="tok-kw">if</span> (exp_zeros &amp; <span class="tok-number">1</span> != <span class="tok-number">0</span>) {</span>
<span class="line" id="L3901">        tmp1 = tmp_limbs;</span>
<span class="line" id="L3902">        tmp2 = r;</span>
<span class="line" id="L3903">    } <span class="tok-kw">else</span> {</span>
<span class="line" id="L3904">        tmp1 = r;</span>
<span class="line" id="L3905">        tmp2 = tmp_limbs;</span>
<span class="line" id="L3906">    }</span>
<span class="line" id="L3907"></span>
<span class="line" id="L3908">    mem.copy(Limb, tmp1, a);</span>
<span class="line" id="L3909">    mem.set(Limb, tmp1[a.len..], <span class="tok-number">0</span>);</span>
<span class="line" id="L3910"></span>
<span class="line" id="L3911">    <span class="tok-comment">// Scan the exponent as a binary number, from left to right, dropping the</span>
</span>
<span class="line" id="L3912">    <span class="tok-comment">// most significant bit set.</span>
</span>
<span class="line" id="L3913">    <span class="tok-comment">// Square the result if the current bit is zero, square and multiply by a if</span>
</span>
<span class="line" id="L3914">    <span class="tok-comment">// it is one.</span>
</span>
<span class="line" id="L3915">    <span class="tok-kw">var</span> exp_bits = <span class="tok-number">32</span> - <span class="tok-number">1</span> - b_leading_zeros;</span>
<span class="line" id="L3916">    <span class="tok-kw">var</span> exp = b &lt;&lt; <span class="tok-builtin">@intCast</span>(<span class="tok-type">u5</span>, <span class="tok-number">1</span> + b_leading_zeros);</span>
<span class="line" id="L3917"></span>
<span class="line" id="L3918">    <span class="tok-kw">var</span> i: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L3919">    <span class="tok-kw">while</span> (i &lt; exp_bits) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L3920">        <span class="tok-comment">// Square</span>
</span>
<span class="line" id="L3921">        mem.set(Limb, tmp2, <span class="tok-number">0</span>);</span>
<span class="line" id="L3922">        llsquareBasecase(tmp2, tmp1[<span class="tok-number">0</span>..llnormalize(tmp1)]);</span>
<span class="line" id="L3923">        mem.swap([]Limb, &amp;tmp1, &amp;tmp2);</span>
<span class="line" id="L3924">        <span class="tok-comment">// Multiply by a</span>
</span>
<span class="line" id="L3925">        <span class="tok-kw">if</span> (<span class="tok-builtin">@shlWithOverflow</span>(<span class="tok-type">u32</span>, exp, <span class="tok-number">1</span>, &amp;exp)) {</span>
<span class="line" id="L3926">            mem.set(Limb, tmp2, <span class="tok-number">0</span>);</span>
<span class="line" id="L3927">            llmulacc(.add, <span class="tok-null">null</span>, tmp2, tmp1[<span class="tok-number">0</span>..llnormalize(tmp1)], a);</span>
<span class="line" id="L3928">            mem.swap([]Limb, &amp;tmp1, &amp;tmp2);</span>
<span class="line" id="L3929">        }</span>
<span class="line" id="L3930">    }</span>
<span class="line" id="L3931">}</span>
<span class="line" id="L3932"></span>
<span class="line" id="L3933"><span class="tok-comment">// Storage must live for the lifetime of the returned value</span>
</span>
<span class="line" id="L3934"><span class="tok-kw">fn</span> <span class="tok-fn">fixedIntFromSignedDoubleLimb</span>(A: SignedDoubleLimb, storage: []Limb) Mutable {</span>
<span class="line" id="L3935">    assert(storage.len &gt;= <span class="tok-number">2</span>);</span>
<span class="line" id="L3936"></span>
<span class="line" id="L3937">    <span class="tok-kw">const</span> A_is_positive = A &gt;= <span class="tok-number">0</span>;</span>
<span class="line" id="L3938">    <span class="tok-kw">const</span> Au = <span class="tok-builtin">@intCast</span>(DoubleLimb, <span class="tok-kw">if</span> (A &lt; <span class="tok-number">0</span>) -A <span class="tok-kw">else</span> A);</span>
<span class="line" id="L3939">    storage[<span class="tok-number">0</span>] = <span class="tok-builtin">@truncate</span>(Limb, Au);</span>
<span class="line" id="L3940">    storage[<span class="tok-number">1</span>] = <span class="tok-builtin">@truncate</span>(Limb, Au &gt;&gt; limb_bits);</span>
<span class="line" id="L3941">    <span class="tok-kw">return</span> .{</span>
<span class="line" id="L3942">        .limbs = storage[<span class="tok-number">0</span>..<span class="tok-number">2</span>],</span>
<span class="line" id="L3943">        .positive = A_is_positive,</span>
<span class="line" id="L3944">        .len = <span class="tok-number">2</span>,</span>
<span class="line" id="L3945">    };</span>
<span class="line" id="L3946">}</span>
<span class="line" id="L3947"></span>
<span class="line" id="L3948"><span class="tok-kw">test</span> {</span>
<span class="line" id="L3949">    _ = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;int_test.zig&quot;</span>);</span>
<span class="line" id="L3950">}</span>
<span class="line" id="L3951"></span>
</code></pre></body>
</html>