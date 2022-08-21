<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">    <title>fmt/parse_float/convert_eisel_lemire.zig - source view</title>
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
<span class="line" id="L2"><span class="tok-kw">const</span> math = std.math;</span>
<span class="line" id="L3"><span class="tok-kw">const</span> common = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;common.zig&quot;</span>);</span>
<span class="line" id="L4"><span class="tok-kw">const</span> FloatInfo = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;FloatInfo.zig&quot;</span>);</span>
<span class="line" id="L5"><span class="tok-kw">const</span> BiasedFp = common.BiasedFp;</span>
<span class="line" id="L6"><span class="tok-kw">const</span> Number = common.Number;</span>
<span class="line" id="L7"></span>
<span class="line" id="L8"><span class="tok-comment">/// Compute a float using an extended-precision representation.</span></span>
<span class="line" id="L9"><span class="tok-comment">///</span></span>
<span class="line" id="L10"><span class="tok-comment">/// Fast conversion of a the significant digits and decimal exponent</span></span>
<span class="line" id="L11"><span class="tok-comment">/// a float to an extended representation with a binary float. This</span></span>
<span class="line" id="L12"><span class="tok-comment">/// algorithm will accurately parse the vast majority of cases,</span></span>
<span class="line" id="L13"><span class="tok-comment">/// and uses a 128-bit representation (with a fallback 192-bit</span></span>
<span class="line" id="L14"><span class="tok-comment">/// representation).</span></span>
<span class="line" id="L15"><span class="tok-comment">///</span></span>
<span class="line" id="L16"><span class="tok-comment">/// This algorithm scales the exponent by the decimal exponent</span></span>
<span class="line" id="L17"><span class="tok-comment">/// using pre-computed powers-of-5, and calculates if the</span></span>
<span class="line" id="L18"><span class="tok-comment">/// representation can be unambiguously rounded to the nearest</span></span>
<span class="line" id="L19"><span class="tok-comment">/// machine float. Near-halfway cases are not handled here,</span></span>
<span class="line" id="L20"><span class="tok-comment">/// and are represented by a negative, biased binary exponent.</span></span>
<span class="line" id="L21"><span class="tok-comment">///</span></span>
<span class="line" id="L22"><span class="tok-comment">/// The algorithm is described in detail in &quot;Daniel Lemire, Number Parsing</span></span>
<span class="line" id="L23"><span class="tok-comment">/// at a Gigabyte per Second&quot; in section 5, &quot;Fast Algorithm&quot;, and</span></span>
<span class="line" id="L24"><span class="tok-comment">/// section 6, &quot;Exact Numbers And Ties&quot;, available online:</span></span>
<span class="line" id="L25"><span class="tok-comment">/// &lt;https://arxiv.org/abs/2101.11408.pdf&gt;.</span></span>
<span class="line" id="L26"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">convertEiselLemire</span>(<span class="tok-kw">comptime</span> T: <span class="tok-type">type</span>, q: <span class="tok-type">i64</span>, w_: <span class="tok-type">u64</span>) ?BiasedFp(<span class="tok-type">f64</span>) {</span>
<span class="line" id="L27">    std.debug.assert(T == <span class="tok-type">f16</span> <span class="tok-kw">or</span> T == <span class="tok-type">f32</span> <span class="tok-kw">or</span> T == <span class="tok-type">f64</span>);</span>
<span class="line" id="L28">    <span class="tok-kw">var</span> w = w_;</span>
<span class="line" id="L29">    <span class="tok-kw">const</span> float_info = FloatInfo.from(T);</span>
<span class="line" id="L30"></span>
<span class="line" id="L31">    <span class="tok-comment">// Short-circuit if the value can only be a literal 0 or infinity.</span>
</span>
<span class="line" id="L32">    <span class="tok-kw">if</span> (w == <span class="tok-number">0</span> <span class="tok-kw">or</span> q &lt; float_info.smallest_power_of_ten) {</span>
<span class="line" id="L33">        <span class="tok-kw">return</span> BiasedFp(<span class="tok-type">f64</span>).zero();</span>
<span class="line" id="L34">    } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (q &gt; float_info.largest_power_of_ten) {</span>
<span class="line" id="L35">        <span class="tok-kw">return</span> BiasedFp(<span class="tok-type">f64</span>).inf(T);</span>
<span class="line" id="L36">    }</span>
<span class="line" id="L37"></span>
<span class="line" id="L38">    <span class="tok-comment">// Normalize our significant digits, so the most-significant bit is set.</span>
</span>
<span class="line" id="L39">    <span class="tok-kw">const</span> lz = <span class="tok-builtin">@clz</span>(<span class="tok-type">u64</span>, <span class="tok-builtin">@bitCast</span>(<span class="tok-type">u64</span>, w));</span>
<span class="line" id="L40">    w = math.shl(<span class="tok-type">u64</span>, w, lz);</span>
<span class="line" id="L41"></span>
<span class="line" id="L42">    <span class="tok-kw">const</span> r = computeProductApprox(q, w, float_info.mantissa_explicit_bits + <span class="tok-number">3</span>);</span>
<span class="line" id="L43">    <span class="tok-kw">if</span> (r.lo == <span class="tok-number">0xffff_ffff_ffff_ffff</span>) {</span>
<span class="line" id="L44">        <span class="tok-comment">// If we have failed to approximate w x 5^-q with our 128-bit value.</span>
</span>
<span class="line" id="L45">        <span class="tok-comment">// Since the addition of 1 could lead to an overflow which could then</span>
</span>
<span class="line" id="L46">        <span class="tok-comment">// round up over the half-way point, this can lead to improper rounding</span>
</span>
<span class="line" id="L47">        <span class="tok-comment">// of a float.</span>
</span>
<span class="line" id="L48">        <span class="tok-comment">//</span>
</span>
<span class="line" id="L49">        <span class="tok-comment">// However, this can only occur if q ∈ [-27, 55]. The upper bound of q</span>
</span>
<span class="line" id="L50">        <span class="tok-comment">// is 55 because 5^55 &lt; 2^128, however, this can only happen if 5^q &gt; 2^64,</span>
</span>
<span class="line" id="L51">        <span class="tok-comment">// since otherwise the product can be represented in 64-bits, producing</span>
</span>
<span class="line" id="L52">        <span class="tok-comment">// an exact result. For negative exponents, rounding-to-even can</span>
</span>
<span class="line" id="L53">        <span class="tok-comment">// only occur if 5^-q &lt; 2^64.</span>
</span>
<span class="line" id="L54">        <span class="tok-comment">//</span>
</span>
<span class="line" id="L55">        <span class="tok-comment">// For detailed explanations of rounding for negative exponents, see</span>
</span>
<span class="line" id="L56">        <span class="tok-comment">// &lt;https://arxiv.org/pdf/2101.11408.pdf#section.9.1&gt;. For detailed</span>
</span>
<span class="line" id="L57">        <span class="tok-comment">// explanations of rounding for positive exponents, see</span>
</span>
<span class="line" id="L58">        <span class="tok-comment">// &lt;https://arxiv.org/pdf/2101.11408.pdf#section.8&gt;.</span>
</span>
<span class="line" id="L59">        <span class="tok-kw">const</span> inside_safe_exponent = q &gt;= -<span class="tok-number">27</span> <span class="tok-kw">and</span> q &lt;= <span class="tok-number">55</span>;</span>
<span class="line" id="L60">        <span class="tok-kw">if</span> (!inside_safe_exponent) {</span>
<span class="line" id="L61">            <span class="tok-kw">return</span> <span class="tok-null">null</span>;</span>
<span class="line" id="L62">        }</span>
<span class="line" id="L63">    }</span>
<span class="line" id="L64"></span>
<span class="line" id="L65">    <span class="tok-kw">const</span> upper_bit = <span class="tok-builtin">@intCast</span>(<span class="tok-type">i32</span>, r.hi &gt;&gt; <span class="tok-number">63</span>);</span>
<span class="line" id="L66">    <span class="tok-kw">var</span> mantissa = math.shr(<span class="tok-type">u64</span>, r.hi, upper_bit + <span class="tok-number">64</span> - <span class="tok-builtin">@intCast</span>(<span class="tok-type">i32</span>, float_info.mantissa_explicit_bits) - <span class="tok-number">3</span>);</span>
<span class="line" id="L67">    <span class="tok-kw">var</span> power2 = power(<span class="tok-builtin">@intCast</span>(<span class="tok-type">i32</span>, q)) + upper_bit - <span class="tok-builtin">@intCast</span>(<span class="tok-type">i32</span>, lz) - float_info.minimum_exponent;</span>
<span class="line" id="L68">    <span class="tok-kw">if</span> (power2 &lt;= <span class="tok-number">0</span>) {</span>
<span class="line" id="L69">        <span class="tok-kw">if</span> (-power2 + <span class="tok-number">1</span> &gt;= <span class="tok-number">64</span>) {</span>
<span class="line" id="L70">            <span class="tok-comment">// Have more than 64 bits below the minimum exponent, must be 0.</span>
</span>
<span class="line" id="L71">            <span class="tok-kw">return</span> BiasedFp(<span class="tok-type">f64</span>).zero();</span>
<span class="line" id="L72">        }</span>
<span class="line" id="L73">        <span class="tok-comment">// Have a subnormal value.</span>
</span>
<span class="line" id="L74">        mantissa = math.shr(<span class="tok-type">u64</span>, mantissa, -power2 + <span class="tok-number">1</span>);</span>
<span class="line" id="L75">        mantissa += mantissa &amp; <span class="tok-number">1</span>;</span>
<span class="line" id="L76">        mantissa &gt;&gt;= <span class="tok-number">1</span>;</span>
<span class="line" id="L77">        power2 = <span class="tok-builtin">@boolToInt</span>(mantissa &gt;= (<span class="tok-number">1</span> &lt;&lt; float_info.mantissa_explicit_bits));</span>
<span class="line" id="L78">        <span class="tok-kw">return</span> BiasedFp(<span class="tok-type">f64</span>){ .f = mantissa, .e = power2 };</span>
<span class="line" id="L79">    }</span>
<span class="line" id="L80"></span>
<span class="line" id="L81">    <span class="tok-comment">// Need to handle rounding ties. Normally, we need to round up,</span>
</span>
<span class="line" id="L82">    <span class="tok-comment">// but if we fall right in between and and we have an even basis, we</span>
</span>
<span class="line" id="L83">    <span class="tok-comment">// need to round down.</span>
</span>
<span class="line" id="L84">    <span class="tok-comment">//</span>
</span>
<span class="line" id="L85">    <span class="tok-comment">// This will only occur if:</span>
</span>
<span class="line" id="L86">    <span class="tok-comment">//  1. The lower 64 bits of the 128-bit representation is 0.</span>
</span>
<span class="line" id="L87">    <span class="tok-comment">//      IE, 5^q fits in single 64-bit word.</span>
</span>
<span class="line" id="L88">    <span class="tok-comment">//  2. The least-significant bit prior to truncated mantissa is odd.</span>
</span>
<span class="line" id="L89">    <span class="tok-comment">//  3. All the bits truncated when shifting to mantissa bits + 1 are 0.</span>
</span>
<span class="line" id="L90">    <span class="tok-comment">//</span>
</span>
<span class="line" id="L91">    <span class="tok-comment">// Or, we may fall between two floats: we are exactly halfway.</span>
</span>
<span class="line" id="L92">    <span class="tok-kw">if</span> (r.lo &lt;= <span class="tok-number">1</span> <span class="tok-kw">and</span></span>
<span class="line" id="L93">        q &gt;= float_info.min_exponent_round_to_even <span class="tok-kw">and</span></span>
<span class="line" id="L94">        q &lt;= float_info.max_exponent_round_to_even <span class="tok-kw">and</span></span>
<span class="line" id="L95">        mantissa &amp; <span class="tok-number">3</span> == <span class="tok-number">1</span> <span class="tok-kw">and</span></span>
<span class="line" id="L96">        math.shl(<span class="tok-type">u64</span>, mantissa, (upper_bit + <span class="tok-number">64</span> - <span class="tok-builtin">@intCast</span>(<span class="tok-type">i32</span>, float_info.mantissa_explicit_bits) - <span class="tok-number">3</span>)) == r.hi)</span>
<span class="line" id="L97">    {</span>
<span class="line" id="L98">        <span class="tok-comment">// Zero the lowest bit, so we don't round up.</span>
</span>
<span class="line" id="L99">        mantissa &amp;= ~<span class="tok-builtin">@as</span>(<span class="tok-type">u64</span>, <span class="tok-number">1</span>);</span>
<span class="line" id="L100">    }</span>
<span class="line" id="L101"></span>
<span class="line" id="L102">    <span class="tok-comment">// Round-to-even, then shift the significant digits into place.</span>
</span>
<span class="line" id="L103">    mantissa += mantissa &amp; <span class="tok-number">1</span>;</span>
<span class="line" id="L104">    mantissa &gt;&gt;= <span class="tok-number">1</span>;</span>
<span class="line" id="L105">    <span class="tok-kw">if</span> (mantissa &gt;= <span class="tok-number">2</span> &lt;&lt; float_info.mantissa_explicit_bits) {</span>
<span class="line" id="L106">        <span class="tok-comment">// Rounding up overflowed, so the carry bit is set. Set the</span>
</span>
<span class="line" id="L107">        <span class="tok-comment">// mantissa to 1 (only the implicit, hidden bit is set) and</span>
</span>
<span class="line" id="L108">        <span class="tok-comment">// increase the exponent.</span>
</span>
<span class="line" id="L109">        mantissa = <span class="tok-number">1</span> &lt;&lt; float_info.mantissa_explicit_bits;</span>
<span class="line" id="L110">        power2 += <span class="tok-number">1</span>;</span>
<span class="line" id="L111">    }</span>
<span class="line" id="L112"></span>
<span class="line" id="L113">    <span class="tok-comment">// Zero out the hidden bit</span>
</span>
<span class="line" id="L114">    mantissa &amp;= ~(<span class="tok-builtin">@as</span>(<span class="tok-type">u64</span>, <span class="tok-number">1</span>) &lt;&lt; float_info.mantissa_explicit_bits);</span>
<span class="line" id="L115">    <span class="tok-kw">if</span> (power2 &gt;= float_info.infinite_power) {</span>
<span class="line" id="L116">        <span class="tok-comment">// Exponent is above largest normal value, must be infinite</span>
</span>
<span class="line" id="L117">        <span class="tok-kw">return</span> BiasedFp(<span class="tok-type">f64</span>).inf(T);</span>
<span class="line" id="L118">    }</span>
<span class="line" id="L119"></span>
<span class="line" id="L120">    <span class="tok-kw">return</span> BiasedFp(<span class="tok-type">f64</span>){ .f = mantissa, .e = power2 };</span>
<span class="line" id="L121">}</span>
<span class="line" id="L122"></span>
<span class="line" id="L123"><span class="tok-comment">/// Calculate a base 2 exponent from a decimal exponent.</span></span>
<span class="line" id="L124"><span class="tok-comment">/// This uses a pre-computed integer approximation for</span></span>
<span class="line" id="L125"><span class="tok-comment">/// log2(10), where 217706 / 2^16 is accurate for the</span></span>
<span class="line" id="L126"><span class="tok-comment">/// entire range of non-finite decimal exponents.</span></span>
<span class="line" id="L127"><span class="tok-kw">fn</span> <span class="tok-fn">power</span>(q: <span class="tok-type">i32</span>) <span class="tok-type">i32</span> {</span>
<span class="line" id="L128">    <span class="tok-kw">return</span> ((q *% (<span class="tok-number">152170</span> + <span class="tok-number">65536</span>)) &gt;&gt; <span class="tok-number">16</span>) + <span class="tok-number">63</span>;</span>
<span class="line" id="L129">}</span>
<span class="line" id="L130"></span>
<span class="line" id="L131"><span class="tok-kw">const</span> U128 = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L132">    lo: <span class="tok-type">u64</span>,</span>
<span class="line" id="L133">    hi: <span class="tok-type">u64</span>,</span>
<span class="line" id="L134"></span>
<span class="line" id="L135">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">new</span>(lo: <span class="tok-type">u64</span>, hi: <span class="tok-type">u64</span>) U128 {</span>
<span class="line" id="L136">        <span class="tok-kw">return</span> .{ .lo = lo, .hi = hi };</span>
<span class="line" id="L137">    }</span>
<span class="line" id="L138"></span>
<span class="line" id="L139">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">mul</span>(a: <span class="tok-type">u64</span>, b: <span class="tok-type">u64</span>) U128 {</span>
<span class="line" id="L140">        <span class="tok-kw">const</span> x = <span class="tok-builtin">@as</span>(<span class="tok-type">u128</span>, a) * b;</span>
<span class="line" id="L141">        <span class="tok-kw">return</span> .{</span>
<span class="line" id="L142">            .hi = <span class="tok-builtin">@truncate</span>(<span class="tok-type">u64</span>, x &gt;&gt; <span class="tok-number">64</span>),</span>
<span class="line" id="L143">            .lo = <span class="tok-builtin">@truncate</span>(<span class="tok-type">u64</span>, x),</span>
<span class="line" id="L144">        };</span>
<span class="line" id="L145">    }</span>
<span class="line" id="L146">};</span>
<span class="line" id="L147"></span>
<span class="line" id="L148"><span class="tok-comment">// This will compute or rather approximate w * 5**q and return a pair of 64-bit words</span>
</span>
<span class="line" id="L149"><span class="tok-comment">// approximating the result, with the &quot;high&quot; part corresponding to the most significant</span>
</span>
<span class="line" id="L150"><span class="tok-comment">// bits and the low part corresponding to the least significant bits.</span>
</span>
<span class="line" id="L151"><span class="tok-kw">fn</span> <span class="tok-fn">computeProductApprox</span>(q: <span class="tok-type">i64</span>, w: <span class="tok-type">u64</span>, <span class="tok-kw">comptime</span> precision: <span class="tok-type">usize</span>) U128 {</span>
<span class="line" id="L152">    std.debug.assert(q &gt;= eisel_lemire_smallest_power_of_five);</span>
<span class="line" id="L153">    std.debug.assert(q &lt;= eisel_lemire_largest_power_of_five);</span>
<span class="line" id="L154">    std.debug.assert(precision &lt;= <span class="tok-number">64</span>);</span>
<span class="line" id="L155"></span>
<span class="line" id="L156">    <span class="tok-kw">const</span> mask = <span class="tok-kw">if</span> (precision &lt; <span class="tok-number">64</span>)</span>
<span class="line" id="L157">        <span class="tok-number">0xffff_ffff_ffff_ffff</span> &gt;&gt; precision</span>
<span class="line" id="L158">    <span class="tok-kw">else</span></span>
<span class="line" id="L159">        <span class="tok-number">0xffff_ffff_ffff_ffff</span>;</span>
<span class="line" id="L160"></span>
<span class="line" id="L161">    <span class="tok-comment">// 5^q &lt; 2^64, then the multiplication always provides an exact value.</span>
</span>
<span class="line" id="L162">    <span class="tok-comment">// That means whenever we need to round ties to even, we always have</span>
</span>
<span class="line" id="L163">    <span class="tok-comment">// an exact value.</span>
</span>
<span class="line" id="L164">    <span class="tok-kw">const</span> index = <span class="tok-builtin">@intCast</span>(<span class="tok-type">usize</span>, q - <span class="tok-builtin">@intCast</span>(<span class="tok-type">i64</span>, eisel_lemire_smallest_power_of_five));</span>
<span class="line" id="L165">    <span class="tok-kw">const</span> pow5 = eisel_lemire_table_powers_of_five_128[index];</span>
<span class="line" id="L166"></span>
<span class="line" id="L167">    <span class="tok-comment">// Only need one multiplication as long as there is 1 zero but</span>
</span>
<span class="line" id="L168">    <span class="tok-comment">// in the explicit mantissa bits, +1 for the hidden bit, +1 to</span>
</span>
<span class="line" id="L169">    <span class="tok-comment">// determine the rounding direction, +1 for if the computed</span>
</span>
<span class="line" id="L170">    <span class="tok-comment">// product has a leading zero.</span>
</span>
<span class="line" id="L171">    <span class="tok-kw">var</span> first = U128.mul(w, pow5.lo);</span>
<span class="line" id="L172">    <span class="tok-kw">if</span> (first.hi &amp; mask == mask) {</span>
<span class="line" id="L173">        <span class="tok-comment">// Need to do a second multiplication to get better precision</span>
</span>
<span class="line" id="L174">        <span class="tok-comment">// for the lower product. This will always be exact</span>
</span>
<span class="line" id="L175">        <span class="tok-comment">// where q is &lt; 55, since 5^55 &lt; 2^128. If this wraps,</span>
</span>
<span class="line" id="L176">        <span class="tok-comment">// then we need to need to round up the hi product.</span>
</span>
<span class="line" id="L177">        <span class="tok-kw">const</span> second = U128.mul(w, pow5.hi);</span>
<span class="line" id="L178"></span>
<span class="line" id="L179">        first.lo +%= second.hi;</span>
<span class="line" id="L180">        <span class="tok-kw">if</span> (second.hi &gt; first.lo) {</span>
<span class="line" id="L181">            first.hi += <span class="tok-number">1</span>;</span>
<span class="line" id="L182">        }</span>
<span class="line" id="L183">    }</span>
<span class="line" id="L184"></span>
<span class="line" id="L185">    <span class="tok-kw">return</span> .{ .lo = first.lo, .hi = first.hi };</span>
<span class="line" id="L186">}</span>
<span class="line" id="L187"></span>
<span class="line" id="L188"><span class="tok-comment">// Eisel-Lemire tables ~10Kb</span>
</span>
<span class="line" id="L189"><span class="tok-kw">const</span> eisel_lemire_smallest_power_of_five = -<span class="tok-number">342</span>;</span>
<span class="line" id="L190"><span class="tok-kw">const</span> eisel_lemire_largest_power_of_five = <span class="tok-number">308</span>;</span>
<span class="line" id="L191"><span class="tok-kw">const</span> eisel_lemire_table_powers_of_five_128 = [_]U128{</span>
<span class="line" id="L192">    U128.new(<span class="tok-number">0xeef453d6923bd65a</span>, <span class="tok-number">0x113faa2906a13b3f</span>), <span class="tok-comment">// 5^-342</span>
</span>
<span class="line" id="L193">    U128.new(<span class="tok-number">0x9558b4661b6565f8</span>, <span class="tok-number">0x4ac7ca59a424c507</span>), <span class="tok-comment">// 5^-341</span>
</span>
<span class="line" id="L194">    U128.new(<span class="tok-number">0xbaaee17fa23ebf76</span>, <span class="tok-number">0x5d79bcf00d2df649</span>), <span class="tok-comment">// 5^-340</span>
</span>
<span class="line" id="L195">    U128.new(<span class="tok-number">0xe95a99df8ace6f53</span>, <span class="tok-number">0xf4d82c2c107973dc</span>), <span class="tok-comment">// 5^-339</span>
</span>
<span class="line" id="L196">    U128.new(<span class="tok-number">0x91d8a02bb6c10594</span>, <span class="tok-number">0x79071b9b8a4be869</span>), <span class="tok-comment">// 5^-338</span>
</span>
<span class="line" id="L197">    U128.new(<span class="tok-number">0xb64ec836a47146f9</span>, <span class="tok-number">0x9748e2826cdee284</span>), <span class="tok-comment">// 5^-337</span>
</span>
<span class="line" id="L198">    U128.new(<span class="tok-number">0xe3e27a444d8d98b7</span>, <span class="tok-number">0xfd1b1b2308169b25</span>), <span class="tok-comment">// 5^-336</span>
</span>
<span class="line" id="L199">    U128.new(<span class="tok-number">0x8e6d8c6ab0787f72</span>, <span class="tok-number">0xfe30f0f5e50e20f7</span>), <span class="tok-comment">// 5^-335</span>
</span>
<span class="line" id="L200">    U128.new(<span class="tok-number">0xb208ef855c969f4f</span>, <span class="tok-number">0xbdbd2d335e51a935</span>), <span class="tok-comment">// 5^-334</span>
</span>
<span class="line" id="L201">    U128.new(<span class="tok-number">0xde8b2b66b3bc4723</span>, <span class="tok-number">0xad2c788035e61382</span>), <span class="tok-comment">// 5^-333</span>
</span>
<span class="line" id="L202">    U128.new(<span class="tok-number">0x8b16fb203055ac76</span>, <span class="tok-number">0x4c3bcb5021afcc31</span>), <span class="tok-comment">// 5^-332</span>
</span>
<span class="line" id="L203">    U128.new(<span class="tok-number">0xaddcb9e83c6b1793</span>, <span class="tok-number">0xdf4abe242a1bbf3d</span>), <span class="tok-comment">// 5^-331</span>
</span>
<span class="line" id="L204">    U128.new(<span class="tok-number">0xd953e8624b85dd78</span>, <span class="tok-number">0xd71d6dad34a2af0d</span>), <span class="tok-comment">// 5^-330</span>
</span>
<span class="line" id="L205">    U128.new(<span class="tok-number">0x87d4713d6f33aa6b</span>, <span class="tok-number">0x8672648c40e5ad68</span>), <span class="tok-comment">// 5^-329</span>
</span>
<span class="line" id="L206">    U128.new(<span class="tok-number">0xa9c98d8ccb009506</span>, <span class="tok-number">0x680efdaf511f18c2</span>), <span class="tok-comment">// 5^-328</span>
</span>
<span class="line" id="L207">    U128.new(<span class="tok-number">0xd43bf0effdc0ba48</span>, <span class="tok-number">0x212bd1b2566def2</span>), <span class="tok-comment">// 5^-327</span>
</span>
<span class="line" id="L208">    U128.new(<span class="tok-number">0x84a57695fe98746d</span>, <span class="tok-number">0x14bb630f7604b57</span>), <span class="tok-comment">// 5^-326</span>
</span>
<span class="line" id="L209">    U128.new(<span class="tok-number">0xa5ced43b7e3e9188</span>, <span class="tok-number">0x419ea3bd35385e2d</span>), <span class="tok-comment">// 5^-325</span>
</span>
<span class="line" id="L210">    U128.new(<span class="tok-number">0xcf42894a5dce35ea</span>, <span class="tok-number">0x52064cac828675b9</span>), <span class="tok-comment">// 5^-324</span>
</span>
<span class="line" id="L211">    U128.new(<span class="tok-number">0x818995ce7aa0e1b2</span>, <span class="tok-number">0x7343efebd1940993</span>), <span class="tok-comment">// 5^-323</span>
</span>
<span class="line" id="L212">    U128.new(<span class="tok-number">0xa1ebfb4219491a1f</span>, <span class="tok-number">0x1014ebe6c5f90bf8</span>), <span class="tok-comment">// 5^-322</span>
</span>
<span class="line" id="L213">    U128.new(<span class="tok-number">0xca66fa129f9b60a6</span>, <span class="tok-number">0xd41a26e077774ef6</span>), <span class="tok-comment">// 5^-321</span>
</span>
<span class="line" id="L214">    U128.new(<span class="tok-number">0xfd00b897478238d0</span>, <span class="tok-number">0x8920b098955522b4</span>), <span class="tok-comment">// 5^-320</span>
</span>
<span class="line" id="L215">    U128.new(<span class="tok-number">0x9e20735e8cb16382</span>, <span class="tok-number">0x55b46e5f5d5535b0</span>), <span class="tok-comment">// 5^-319</span>
</span>
<span class="line" id="L216">    U128.new(<span class="tok-number">0xc5a890362fddbc62</span>, <span class="tok-number">0xeb2189f734aa831d</span>), <span class="tok-comment">// 5^-318</span>
</span>
<span class="line" id="L217">    U128.new(<span class="tok-number">0xf712b443bbd52b7b</span>, <span class="tok-number">0xa5e9ec7501d523e4</span>), <span class="tok-comment">// 5^-317</span>
</span>
<span class="line" id="L218">    U128.new(<span class="tok-number">0x9a6bb0aa55653b2d</span>, <span class="tok-number">0x47b233c92125366e</span>), <span class="tok-comment">// 5^-316</span>
</span>
<span class="line" id="L219">    U128.new(<span class="tok-number">0xc1069cd4eabe89f8</span>, <span class="tok-number">0x999ec0bb696e840a</span>), <span class="tok-comment">// 5^-315</span>
</span>
<span class="line" id="L220">    U128.new(<span class="tok-number">0xf148440a256e2c76</span>, <span class="tok-number">0xc00670ea43ca250d</span>), <span class="tok-comment">// 5^-314</span>
</span>
<span class="line" id="L221">    U128.new(<span class="tok-number">0x96cd2a865764dbca</span>, <span class="tok-number">0x380406926a5e5728</span>), <span class="tok-comment">// 5^-313</span>
</span>
<span class="line" id="L222">    U128.new(<span class="tok-number">0xbc807527ed3e12bc</span>, <span class="tok-number">0xc605083704f5ecf2</span>), <span class="tok-comment">// 5^-312</span>
</span>
<span class="line" id="L223">    U128.new(<span class="tok-number">0xeba09271e88d976b</span>, <span class="tok-number">0xf7864a44c633682e</span>), <span class="tok-comment">// 5^-311</span>
</span>
<span class="line" id="L224">    U128.new(<span class="tok-number">0x93445b8731587ea3</span>, <span class="tok-number">0x7ab3ee6afbe0211d</span>), <span class="tok-comment">// 5^-310</span>
</span>
<span class="line" id="L225">    U128.new(<span class="tok-number">0xb8157268fdae9e4c</span>, <span class="tok-number">0x5960ea05bad82964</span>), <span class="tok-comment">// 5^-309</span>
</span>
<span class="line" id="L226">    U128.new(<span class="tok-number">0xe61acf033d1a45df</span>, <span class="tok-number">0x6fb92487298e33bd</span>), <span class="tok-comment">// 5^-308</span>
</span>
<span class="line" id="L227">    U128.new(<span class="tok-number">0x8fd0c16206306bab</span>, <span class="tok-number">0xa5d3b6d479f8e056</span>), <span class="tok-comment">// 5^-307</span>
</span>
<span class="line" id="L228">    U128.new(<span class="tok-number">0xb3c4f1ba87bc8696</span>, <span class="tok-number">0x8f48a4899877186c</span>), <span class="tok-comment">// 5^-306</span>
</span>
<span class="line" id="L229">    U128.new(<span class="tok-number">0xe0b62e2929aba83c</span>, <span class="tok-number">0x331acdabfe94de87</span>), <span class="tok-comment">// 5^-305</span>
</span>
<span class="line" id="L230">    U128.new(<span class="tok-number">0x8c71dcd9ba0b4925</span>, <span class="tok-number">0x9ff0c08b7f1d0b14</span>), <span class="tok-comment">// 5^-304</span>
</span>
<span class="line" id="L231">    U128.new(<span class="tok-number">0xaf8e5410288e1b6f</span>, <span class="tok-number">0x7ecf0ae5ee44dd9</span>), <span class="tok-comment">// 5^-303</span>
</span>
<span class="line" id="L232">    U128.new(<span class="tok-number">0xdb71e91432b1a24a</span>, <span class="tok-number">0xc9e82cd9f69d6150</span>), <span class="tok-comment">// 5^-302</span>
</span>
<span class="line" id="L233">    U128.new(<span class="tok-number">0x892731ac9faf056e</span>, <span class="tok-number">0xbe311c083a225cd2</span>), <span class="tok-comment">// 5^-301</span>
</span>
<span class="line" id="L234">    U128.new(<span class="tok-number">0xab70fe17c79ac6ca</span>, <span class="tok-number">0x6dbd630a48aaf406</span>), <span class="tok-comment">// 5^-300</span>
</span>
<span class="line" id="L235">    U128.new(<span class="tok-number">0xd64d3d9db981787d</span>, <span class="tok-number">0x92cbbccdad5b108</span>), <span class="tok-comment">// 5^-299</span>
</span>
<span class="line" id="L236">    U128.new(<span class="tok-number">0x85f0468293f0eb4e</span>, <span class="tok-number">0x25bbf56008c58ea5</span>), <span class="tok-comment">// 5^-298</span>
</span>
<span class="line" id="L237">    U128.new(<span class="tok-number">0xa76c582338ed2621</span>, <span class="tok-number">0xaf2af2b80af6f24e</span>), <span class="tok-comment">// 5^-297</span>
</span>
<span class="line" id="L238">    U128.new(<span class="tok-number">0xd1476e2c07286faa</span>, <span class="tok-number">0x1af5af660db4aee1</span>), <span class="tok-comment">// 5^-296</span>
</span>
<span class="line" id="L239">    U128.new(<span class="tok-number">0x82cca4db847945ca</span>, <span class="tok-number">0x50d98d9fc890ed4d</span>), <span class="tok-comment">// 5^-295</span>
</span>
<span class="line" id="L240">    U128.new(<span class="tok-number">0xa37fce126597973c</span>, <span class="tok-number">0xe50ff107bab528a0</span>), <span class="tok-comment">// 5^-294</span>
</span>
<span class="line" id="L241">    U128.new(<span class="tok-number">0xcc5fc196fefd7d0c</span>, <span class="tok-number">0x1e53ed49a96272c8</span>), <span class="tok-comment">// 5^-293</span>
</span>
<span class="line" id="L242">    U128.new(<span class="tok-number">0xff77b1fcbebcdc4f</span>, <span class="tok-number">0x25e8e89c13bb0f7a</span>), <span class="tok-comment">// 5^-292</span>
</span>
<span class="line" id="L243">    U128.new(<span class="tok-number">0x9faacf3df73609b1</span>, <span class="tok-number">0x77b191618c54e9ac</span>), <span class="tok-comment">// 5^-291</span>
</span>
<span class="line" id="L244">    U128.new(<span class="tok-number">0xc795830d75038c1d</span>, <span class="tok-number">0xd59df5b9ef6a2417</span>), <span class="tok-comment">// 5^-290</span>
</span>
<span class="line" id="L245">    U128.new(<span class="tok-number">0xf97ae3d0d2446f25</span>, <span class="tok-number">0x4b0573286b44ad1d</span>), <span class="tok-comment">// 5^-289</span>
</span>
<span class="line" id="L246">    U128.new(<span class="tok-number">0x9becce62836ac577</span>, <span class="tok-number">0x4ee367f9430aec32</span>), <span class="tok-comment">// 5^-288</span>
</span>
<span class="line" id="L247">    U128.new(<span class="tok-number">0xc2e801fb244576d5</span>, <span class="tok-number">0x229c41f793cda73f</span>), <span class="tok-comment">// 5^-287</span>
</span>
<span class="line" id="L248">    U128.new(<span class="tok-number">0xf3a20279ed56d48a</span>, <span class="tok-number">0x6b43527578c1110f</span>), <span class="tok-comment">// 5^-286</span>
</span>
<span class="line" id="L249">    U128.new(<span class="tok-number">0x9845418c345644d6</span>, <span class="tok-number">0x830a13896b78aaa9</span>), <span class="tok-comment">// 5^-285</span>
</span>
<span class="line" id="L250">    U128.new(<span class="tok-number">0xbe5691ef416bd60c</span>, <span class="tok-number">0x23cc986bc656d553</span>), <span class="tok-comment">// 5^-284</span>
</span>
<span class="line" id="L251">    U128.new(<span class="tok-number">0xedec366b11c6cb8f</span>, <span class="tok-number">0x2cbfbe86b7ec8aa8</span>), <span class="tok-comment">// 5^-283</span>
</span>
<span class="line" id="L252">    U128.new(<span class="tok-number">0x94b3a202eb1c3f39</span>, <span class="tok-number">0x7bf7d71432f3d6a9</span>), <span class="tok-comment">// 5^-282</span>
</span>
<span class="line" id="L253">    U128.new(<span class="tok-number">0xb9e08a83a5e34f07</span>, <span class="tok-number">0xdaf5ccd93fb0cc53</span>), <span class="tok-comment">// 5^-281</span>
</span>
<span class="line" id="L254">    U128.new(<span class="tok-number">0xe858ad248f5c22c9</span>, <span class="tok-number">0xd1b3400f8f9cff68</span>), <span class="tok-comment">// 5^-280</span>
</span>
<span class="line" id="L255">    U128.new(<span class="tok-number">0x91376c36d99995be</span>, <span class="tok-number">0x23100809b9c21fa1</span>), <span class="tok-comment">// 5^-279</span>
</span>
<span class="line" id="L256">    U128.new(<span class="tok-number">0xb58547448ffffb2d</span>, <span class="tok-number">0xabd40a0c2832a78a</span>), <span class="tok-comment">// 5^-278</span>
</span>
<span class="line" id="L257">    U128.new(<span class="tok-number">0xe2e69915b3fff9f9</span>, <span class="tok-number">0x16c90c8f323f516c</span>), <span class="tok-comment">// 5^-277</span>
</span>
<span class="line" id="L258">    U128.new(<span class="tok-number">0x8dd01fad907ffc3b</span>, <span class="tok-number">0xae3da7d97f6792e3</span>), <span class="tok-comment">// 5^-276</span>
</span>
<span class="line" id="L259">    U128.new(<span class="tok-number">0xb1442798f49ffb4a</span>, <span class="tok-number">0x99cd11cfdf41779c</span>), <span class="tok-comment">// 5^-275</span>
</span>
<span class="line" id="L260">    U128.new(<span class="tok-number">0xdd95317f31c7fa1d</span>, <span class="tok-number">0x40405643d711d583</span>), <span class="tok-comment">// 5^-274</span>
</span>
<span class="line" id="L261">    U128.new(<span class="tok-number">0x8a7d3eef7f1cfc52</span>, <span class="tok-number">0x482835ea666b2572</span>), <span class="tok-comment">// 5^-273</span>
</span>
<span class="line" id="L262">    U128.new(<span class="tok-number">0xad1c8eab5ee43b66</span>, <span class="tok-number">0xda3243650005eecf</span>), <span class="tok-comment">// 5^-272</span>
</span>
<span class="line" id="L263">    U128.new(<span class="tok-number">0xd863b256369d4a40</span>, <span class="tok-number">0x90bed43e40076a82</span>), <span class="tok-comment">// 5^-271</span>
</span>
<span class="line" id="L264">    U128.new(<span class="tok-number">0x873e4f75e2224e68</span>, <span class="tok-number">0x5a7744a6e804a291</span>), <span class="tok-comment">// 5^-270</span>
</span>
<span class="line" id="L265">    U128.new(<span class="tok-number">0xa90de3535aaae202</span>, <span class="tok-number">0x711515d0a205cb36</span>), <span class="tok-comment">// 5^-269</span>
</span>
<span class="line" id="L266">    U128.new(<span class="tok-number">0xd3515c2831559a83</span>, <span class="tok-number">0xd5a5b44ca873e03</span>), <span class="tok-comment">// 5^-268</span>
</span>
<span class="line" id="L267">    U128.new(<span class="tok-number">0x8412d9991ed58091</span>, <span class="tok-number">0xe858790afe9486c2</span>), <span class="tok-comment">// 5^-267</span>
</span>
<span class="line" id="L268">    U128.new(<span class="tok-number">0xa5178fff668ae0b6</span>, <span class="tok-number">0x626e974dbe39a872</span>), <span class="tok-comment">// 5^-266</span>
</span>
<span class="line" id="L269">    U128.new(<span class="tok-number">0xce5d73ff402d98e3</span>, <span class="tok-number">0xfb0a3d212dc8128f</span>), <span class="tok-comment">// 5^-265</span>
</span>
<span class="line" id="L270">    U128.new(<span class="tok-number">0x80fa687f881c7f8e</span>, <span class="tok-number">0x7ce66634bc9d0b99</span>), <span class="tok-comment">// 5^-264</span>
</span>
<span class="line" id="L271">    U128.new(<span class="tok-number">0xa139029f6a239f72</span>, <span class="tok-number">0x1c1fffc1ebc44e80</span>), <span class="tok-comment">// 5^-263</span>
</span>
<span class="line" id="L272">    U128.new(<span class="tok-number">0xc987434744ac874e</span>, <span class="tok-number">0xa327ffb266b56220</span>), <span class="tok-comment">// 5^-262</span>
</span>
<span class="line" id="L273">    U128.new(<span class="tok-number">0xfbe9141915d7a922</span>, <span class="tok-number">0x4bf1ff9f0062baa8</span>), <span class="tok-comment">// 5^-261</span>
</span>
<span class="line" id="L274">    U128.new(<span class="tok-number">0x9d71ac8fada6c9b5</span>, <span class="tok-number">0x6f773fc3603db4a9</span>), <span class="tok-comment">// 5^-260</span>
</span>
<span class="line" id="L275">    U128.new(<span class="tok-number">0xc4ce17b399107c22</span>, <span class="tok-number">0xcb550fb4384d21d3</span>), <span class="tok-comment">// 5^-259</span>
</span>
<span class="line" id="L276">    U128.new(<span class="tok-number">0xf6019da07f549b2b</span>, <span class="tok-number">0x7e2a53a146606a48</span>), <span class="tok-comment">// 5^-258</span>
</span>
<span class="line" id="L277">    U128.new(<span class="tok-number">0x99c102844f94e0fb</span>, <span class="tok-number">0x2eda7444cbfc426d</span>), <span class="tok-comment">// 5^-257</span>
</span>
<span class="line" id="L278">    U128.new(<span class="tok-number">0xc0314325637a1939</span>, <span class="tok-number">0xfa911155fefb5308</span>), <span class="tok-comment">// 5^-256</span>
</span>
<span class="line" id="L279">    U128.new(<span class="tok-number">0xf03d93eebc589f88</span>, <span class="tok-number">0x793555ab7eba27ca</span>), <span class="tok-comment">// 5^-255</span>
</span>
<span class="line" id="L280">    U128.new(<span class="tok-number">0x96267c7535b763b5</span>, <span class="tok-number">0x4bc1558b2f3458de</span>), <span class="tok-comment">// 5^-254</span>
</span>
<span class="line" id="L281">    U128.new(<span class="tok-number">0xbbb01b9283253ca2</span>, <span class="tok-number">0x9eb1aaedfb016f16</span>), <span class="tok-comment">// 5^-253</span>
</span>
<span class="line" id="L282">    U128.new(<span class="tok-number">0xea9c227723ee8bcb</span>, <span class="tok-number">0x465e15a979c1cadc</span>), <span class="tok-comment">// 5^-252</span>
</span>
<span class="line" id="L283">    U128.new(<span class="tok-number">0x92a1958a7675175f</span>, <span class="tok-number">0xbfacd89ec191ec9</span>), <span class="tok-comment">// 5^-251</span>
</span>
<span class="line" id="L284">    U128.new(<span class="tok-number">0xb749faed14125d36</span>, <span class="tok-number">0xcef980ec671f667b</span>), <span class="tok-comment">// 5^-250</span>
</span>
<span class="line" id="L285">    U128.new(<span class="tok-number">0xe51c79a85916f484</span>, <span class="tok-number">0x82b7e12780e7401a</span>), <span class="tok-comment">// 5^-249</span>
</span>
<span class="line" id="L286">    U128.new(<span class="tok-number">0x8f31cc0937ae58d2</span>, <span class="tok-number">0xd1b2ecb8b0908810</span>), <span class="tok-comment">// 5^-248</span>
</span>
<span class="line" id="L287">    U128.new(<span class="tok-number">0xb2fe3f0b8599ef07</span>, <span class="tok-number">0x861fa7e6dcb4aa15</span>), <span class="tok-comment">// 5^-247</span>
</span>
<span class="line" id="L288">    U128.new(<span class="tok-number">0xdfbdcece67006ac9</span>, <span class="tok-number">0x67a791e093e1d49a</span>), <span class="tok-comment">// 5^-246</span>
</span>
<span class="line" id="L289">    U128.new(<span class="tok-number">0x8bd6a141006042bd</span>, <span class="tok-number">0xe0c8bb2c5c6d24e0</span>), <span class="tok-comment">// 5^-245</span>
</span>
<span class="line" id="L290">    U128.new(<span class="tok-number">0xaecc49914078536d</span>, <span class="tok-number">0x58fae9f773886e18</span>), <span class="tok-comment">// 5^-244</span>
</span>
<span class="line" id="L291">    U128.new(<span class="tok-number">0xda7f5bf590966848</span>, <span class="tok-number">0xaf39a475506a899e</span>), <span class="tok-comment">// 5^-243</span>
</span>
<span class="line" id="L292">    U128.new(<span class="tok-number">0x888f99797a5e012d</span>, <span class="tok-number">0x6d8406c952429603</span>), <span class="tok-comment">// 5^-242</span>
</span>
<span class="line" id="L293">    U128.new(<span class="tok-number">0xaab37fd7d8f58178</span>, <span class="tok-number">0xc8e5087ba6d33b83</span>), <span class="tok-comment">// 5^-241</span>
</span>
<span class="line" id="L294">    U128.new(<span class="tok-number">0xd5605fcdcf32e1d6</span>, <span class="tok-number">0xfb1e4a9a90880a64</span>), <span class="tok-comment">// 5^-240</span>
</span>
<span class="line" id="L295">    U128.new(<span class="tok-number">0x855c3be0a17fcd26</span>, <span class="tok-number">0x5cf2eea09a55067f</span>), <span class="tok-comment">// 5^-239</span>
</span>
<span class="line" id="L296">    U128.new(<span class="tok-number">0xa6b34ad8c9dfc06f</span>, <span class="tok-number">0xf42faa48c0ea481e</span>), <span class="tok-comment">// 5^-238</span>
</span>
<span class="line" id="L297">    U128.new(<span class="tok-number">0xd0601d8efc57b08b</span>, <span class="tok-number">0xf13b94daf124da26</span>), <span class="tok-comment">// 5^-237</span>
</span>
<span class="line" id="L298">    U128.new(<span class="tok-number">0x823c12795db6ce57</span>, <span class="tok-number">0x76c53d08d6b70858</span>), <span class="tok-comment">// 5^-236</span>
</span>
<span class="line" id="L299">    U128.new(<span class="tok-number">0xa2cb1717b52481ed</span>, <span class="tok-number">0x54768c4b0c64ca6e</span>), <span class="tok-comment">// 5^-235</span>
</span>
<span class="line" id="L300">    U128.new(<span class="tok-number">0xcb7ddcdda26da268</span>, <span class="tok-number">0xa9942f5dcf7dfd09</span>), <span class="tok-comment">// 5^-234</span>
</span>
<span class="line" id="L301">    U128.new(<span class="tok-number">0xfe5d54150b090b02</span>, <span class="tok-number">0xd3f93b35435d7c4c</span>), <span class="tok-comment">// 5^-233</span>
</span>
<span class="line" id="L302">    U128.new(<span class="tok-number">0x9efa548d26e5a6e1</span>, <span class="tok-number">0xc47bc5014a1a6daf</span>), <span class="tok-comment">// 5^-232</span>
</span>
<span class="line" id="L303">    U128.new(<span class="tok-number">0xc6b8e9b0709f109a</span>, <span class="tok-number">0x359ab6419ca1091b</span>), <span class="tok-comment">// 5^-231</span>
</span>
<span class="line" id="L304">    U128.new(<span class="tok-number">0xf867241c8cc6d4c0</span>, <span class="tok-number">0xc30163d203c94b62</span>), <span class="tok-comment">// 5^-230</span>
</span>
<span class="line" id="L305">    U128.new(<span class="tok-number">0x9b407691d7fc44f8</span>, <span class="tok-number">0x79e0de63425dcf1d</span>), <span class="tok-comment">// 5^-229</span>
</span>
<span class="line" id="L306">    U128.new(<span class="tok-number">0xc21094364dfb5636</span>, <span class="tok-number">0x985915fc12f542e4</span>), <span class="tok-comment">// 5^-228</span>
</span>
<span class="line" id="L307">    U128.new(<span class="tok-number">0xf294b943e17a2bc4</span>, <span class="tok-number">0x3e6f5b7b17b2939d</span>), <span class="tok-comment">// 5^-227</span>
</span>
<span class="line" id="L308">    U128.new(<span class="tok-number">0x979cf3ca6cec5b5a</span>, <span class="tok-number">0xa705992ceecf9c42</span>), <span class="tok-comment">// 5^-226</span>
</span>
<span class="line" id="L309">    U128.new(<span class="tok-number">0xbd8430bd08277231</span>, <span class="tok-number">0x50c6ff782a838353</span>), <span class="tok-comment">// 5^-225</span>
</span>
<span class="line" id="L310">    U128.new(<span class="tok-number">0xece53cec4a314ebd</span>, <span class="tok-number">0xa4f8bf5635246428</span>), <span class="tok-comment">// 5^-224</span>
</span>
<span class="line" id="L311">    U128.new(<span class="tok-number">0x940f4613ae5ed136</span>, <span class="tok-number">0x871b7795e136be99</span>), <span class="tok-comment">// 5^-223</span>
</span>
<span class="line" id="L312">    U128.new(<span class="tok-number">0xb913179899f68584</span>, <span class="tok-number">0x28e2557b59846e3f</span>), <span class="tok-comment">// 5^-222</span>
</span>
<span class="line" id="L313">    U128.new(<span class="tok-number">0xe757dd7ec07426e5</span>, <span class="tok-number">0x331aeada2fe589cf</span>), <span class="tok-comment">// 5^-221</span>
</span>
<span class="line" id="L314">    U128.new(<span class="tok-number">0x9096ea6f3848984f</span>, <span class="tok-number">0x3ff0d2c85def7621</span>), <span class="tok-comment">// 5^-220</span>
</span>
<span class="line" id="L315">    U128.new(<span class="tok-number">0xb4bca50b065abe63</span>, <span class="tok-number">0xfed077a756b53a9</span>), <span class="tok-comment">// 5^-219</span>
</span>
<span class="line" id="L316">    U128.new(<span class="tok-number">0xe1ebce4dc7f16dfb</span>, <span class="tok-number">0xd3e8495912c62894</span>), <span class="tok-comment">// 5^-218</span>
</span>
<span class="line" id="L317">    U128.new(<span class="tok-number">0x8d3360f09cf6e4bd</span>, <span class="tok-number">0x64712dd7abbbd95c</span>), <span class="tok-comment">// 5^-217</span>
</span>
<span class="line" id="L318">    U128.new(<span class="tok-number">0xb080392cc4349dec</span>, <span class="tok-number">0xbd8d794d96aacfb3</span>), <span class="tok-comment">// 5^-216</span>
</span>
<span class="line" id="L319">    U128.new(<span class="tok-number">0xdca04777f541c567</span>, <span class="tok-number">0xecf0d7a0fc5583a0</span>), <span class="tok-comment">// 5^-215</span>
</span>
<span class="line" id="L320">    U128.new(<span class="tok-number">0x89e42caaf9491b60</span>, <span class="tok-number">0xf41686c49db57244</span>), <span class="tok-comment">// 5^-214</span>
</span>
<span class="line" id="L321">    U128.new(<span class="tok-number">0xac5d37d5b79b6239</span>, <span class="tok-number">0x311c2875c522ced5</span>), <span class="tok-comment">// 5^-213</span>
</span>
<span class="line" id="L322">    U128.new(<span class="tok-number">0xd77485cb25823ac7</span>, <span class="tok-number">0x7d633293366b828b</span>), <span class="tok-comment">// 5^-212</span>
</span>
<span class="line" id="L323">    U128.new(<span class="tok-number">0x86a8d39ef77164bc</span>, <span class="tok-number">0xae5dff9c02033197</span>), <span class="tok-comment">// 5^-211</span>
</span>
<span class="line" id="L324">    U128.new(<span class="tok-number">0xa8530886b54dbdeb</span>, <span class="tok-number">0xd9f57f830283fdfc</span>), <span class="tok-comment">// 5^-210</span>
</span>
<span class="line" id="L325">    U128.new(<span class="tok-number">0xd267caa862a12d66</span>, <span class="tok-number">0xd072df63c324fd7b</span>), <span class="tok-comment">// 5^-209</span>
</span>
<span class="line" id="L326">    U128.new(<span class="tok-number">0x8380dea93da4bc60</span>, <span class="tok-number">0x4247cb9e59f71e6d</span>), <span class="tok-comment">// 5^-208</span>
</span>
<span class="line" id="L327">    U128.new(<span class="tok-number">0xa46116538d0deb78</span>, <span class="tok-number">0x52d9be85f074e608</span>), <span class="tok-comment">// 5^-207</span>
</span>
<span class="line" id="L328">    U128.new(<span class="tok-number">0xcd795be870516656</span>, <span class="tok-number">0x67902e276c921f8b</span>), <span class="tok-comment">// 5^-206</span>
</span>
<span class="line" id="L329">    U128.new(<span class="tok-number">0x806bd9714632dff6</span>, <span class="tok-number">0xba1cd8a3db53b6</span>), <span class="tok-comment">// 5^-205</span>
</span>
<span class="line" id="L330">    U128.new(<span class="tok-number">0xa086cfcd97bf97f3</span>, <span class="tok-number">0x80e8a40eccd228a4</span>), <span class="tok-comment">// 5^-204</span>
</span>
<span class="line" id="L331">    U128.new(<span class="tok-number">0xc8a883c0fdaf7df0</span>, <span class="tok-number">0x6122cd128006b2cd</span>), <span class="tok-comment">// 5^-203</span>
</span>
<span class="line" id="L332">    U128.new(<span class="tok-number">0xfad2a4b13d1b5d6c</span>, <span class="tok-number">0x796b805720085f81</span>), <span class="tok-comment">// 5^-202</span>
</span>
<span class="line" id="L333">    U128.new(<span class="tok-number">0x9cc3a6eec6311a63</span>, <span class="tok-number">0xcbe3303674053bb0</span>), <span class="tok-comment">// 5^-201</span>
</span>
<span class="line" id="L334">    U128.new(<span class="tok-number">0xc3f490aa77bd60fc</span>, <span class="tok-number">0xbedbfc4411068a9c</span>), <span class="tok-comment">// 5^-200</span>
</span>
<span class="line" id="L335">    U128.new(<span class="tok-number">0xf4f1b4d515acb93b</span>, <span class="tok-number">0xee92fb5515482d44</span>), <span class="tok-comment">// 5^-199</span>
</span>
<span class="line" id="L336">    U128.new(<span class="tok-number">0x991711052d8bf3c5</span>, <span class="tok-number">0x751bdd152d4d1c4a</span>), <span class="tok-comment">// 5^-198</span>
</span>
<span class="line" id="L337">    U128.new(<span class="tok-number">0xbf5cd54678eef0b6</span>, <span class="tok-number">0xd262d45a78a0635d</span>), <span class="tok-comment">// 5^-197</span>
</span>
<span class="line" id="L338">    U128.new(<span class="tok-number">0xef340a98172aace4</span>, <span class="tok-number">0x86fb897116c87c34</span>), <span class="tok-comment">// 5^-196</span>
</span>
<span class="line" id="L339">    U128.new(<span class="tok-number">0x9580869f0e7aac0e</span>, <span class="tok-number">0xd45d35e6ae3d4da0</span>), <span class="tok-comment">// 5^-195</span>
</span>
<span class="line" id="L340">    U128.new(<span class="tok-number">0xbae0a846d2195712</span>, <span class="tok-number">0x8974836059cca109</span>), <span class="tok-comment">// 5^-194</span>
</span>
<span class="line" id="L341">    U128.new(<span class="tok-number">0xe998d258869facd7</span>, <span class="tok-number">0x2bd1a438703fc94b</span>), <span class="tok-comment">// 5^-193</span>
</span>
<span class="line" id="L342">    U128.new(<span class="tok-number">0x91ff83775423cc06</span>, <span class="tok-number">0x7b6306a34627ddcf</span>), <span class="tok-comment">// 5^-192</span>
</span>
<span class="line" id="L343">    U128.new(<span class="tok-number">0xb67f6455292cbf08</span>, <span class="tok-number">0x1a3bc84c17b1d542</span>), <span class="tok-comment">// 5^-191</span>
</span>
<span class="line" id="L344">    U128.new(<span class="tok-number">0xe41f3d6a7377eeca</span>, <span class="tok-number">0x20caba5f1d9e4a93</span>), <span class="tok-comment">// 5^-190</span>
</span>
<span class="line" id="L345">    U128.new(<span class="tok-number">0x8e938662882af53e</span>, <span class="tok-number">0x547eb47b7282ee9c</span>), <span class="tok-comment">// 5^-189</span>
</span>
<span class="line" id="L346">    U128.new(<span class="tok-number">0xb23867fb2a35b28d</span>, <span class="tok-number">0xe99e619a4f23aa43</span>), <span class="tok-comment">// 5^-188</span>
</span>
<span class="line" id="L347">    U128.new(<span class="tok-number">0xdec681f9f4c31f31</span>, <span class="tok-number">0x6405fa00e2ec94d4</span>), <span class="tok-comment">// 5^-187</span>
</span>
<span class="line" id="L348">    U128.new(<span class="tok-number">0x8b3c113c38f9f37e</span>, <span class="tok-number">0xde83bc408dd3dd04</span>), <span class="tok-comment">// 5^-186</span>
</span>
<span class="line" id="L349">    U128.new(<span class="tok-number">0xae0b158b4738705e</span>, <span class="tok-number">0x9624ab50b148d445</span>), <span class="tok-comment">// 5^-185</span>
</span>
<span class="line" id="L350">    U128.new(<span class="tok-number">0xd98ddaee19068c76</span>, <span class="tok-number">0x3badd624dd9b0957</span>), <span class="tok-comment">// 5^-184</span>
</span>
<span class="line" id="L351">    U128.new(<span class="tok-number">0x87f8a8d4cfa417c9</span>, <span class="tok-number">0xe54ca5d70a80e5d6</span>), <span class="tok-comment">// 5^-183</span>
</span>
<span class="line" id="L352">    U128.new(<span class="tok-number">0xa9f6d30a038d1dbc</span>, <span class="tok-number">0x5e9fcf4ccd211f4c</span>), <span class="tok-comment">// 5^-182</span>
</span>
<span class="line" id="L353">    U128.new(<span class="tok-number">0xd47487cc8470652b</span>, <span class="tok-number">0x7647c3200069671f</span>), <span class="tok-comment">// 5^-181</span>
</span>
<span class="line" id="L354">    U128.new(<span class="tok-number">0x84c8d4dfd2c63f3b</span>, <span class="tok-number">0x29ecd9f40041e073</span>), <span class="tok-comment">// 5^-180</span>
</span>
<span class="line" id="L355">    U128.new(<span class="tok-number">0xa5fb0a17c777cf09</span>, <span class="tok-number">0xf468107100525890</span>), <span class="tok-comment">// 5^-179</span>
</span>
<span class="line" id="L356">    U128.new(<span class="tok-number">0xcf79cc9db955c2cc</span>, <span class="tok-number">0x7182148d4066eeb4</span>), <span class="tok-comment">// 5^-178</span>
</span>
<span class="line" id="L357">    U128.new(<span class="tok-number">0x81ac1fe293d599bf</span>, <span class="tok-number">0xc6f14cd848405530</span>), <span class="tok-comment">// 5^-177</span>
</span>
<span class="line" id="L358">    U128.new(<span class="tok-number">0xa21727db38cb002f</span>, <span class="tok-number">0xb8ada00e5a506a7c</span>), <span class="tok-comment">// 5^-176</span>
</span>
<span class="line" id="L359">    U128.new(<span class="tok-number">0xca9cf1d206fdc03b</span>, <span class="tok-number">0xa6d90811f0e4851c</span>), <span class="tok-comment">// 5^-175</span>
</span>
<span class="line" id="L360">    U128.new(<span class="tok-number">0xfd442e4688bd304a</span>, <span class="tok-number">0x908f4a166d1da663</span>), <span class="tok-comment">// 5^-174</span>
</span>
<span class="line" id="L361">    U128.new(<span class="tok-number">0x9e4a9cec15763e2e</span>, <span class="tok-number">0x9a598e4e043287fe</span>), <span class="tok-comment">// 5^-173</span>
</span>
<span class="line" id="L362">    U128.new(<span class="tok-number">0xc5dd44271ad3cdba</span>, <span class="tok-number">0x40eff1e1853f29fd</span>), <span class="tok-comment">// 5^-172</span>
</span>
<span class="line" id="L363">    U128.new(<span class="tok-number">0xf7549530e188c128</span>, <span class="tok-number">0xd12bee59e68ef47c</span>), <span class="tok-comment">// 5^-171</span>
</span>
<span class="line" id="L364">    U128.new(<span class="tok-number">0x9a94dd3e8cf578b9</span>, <span class="tok-number">0x82bb74f8301958ce</span>), <span class="tok-comment">// 5^-170</span>
</span>
<span class="line" id="L365">    U128.new(<span class="tok-number">0xc13a148e3032d6e7</span>, <span class="tok-number">0xe36a52363c1faf01</span>), <span class="tok-comment">// 5^-169</span>
</span>
<span class="line" id="L366">    U128.new(<span class="tok-number">0xf18899b1bc3f8ca1</span>, <span class="tok-number">0xdc44e6c3cb279ac1</span>), <span class="tok-comment">// 5^-168</span>
</span>
<span class="line" id="L367">    U128.new(<span class="tok-number">0x96f5600f15a7b7e5</span>, <span class="tok-number">0x29ab103a5ef8c0b9</span>), <span class="tok-comment">// 5^-167</span>
</span>
<span class="line" id="L368">    U128.new(<span class="tok-number">0xbcb2b812db11a5de</span>, <span class="tok-number">0x7415d448f6b6f0e7</span>), <span class="tok-comment">// 5^-166</span>
</span>
<span class="line" id="L369">    U128.new(<span class="tok-number">0xebdf661791d60f56</span>, <span class="tok-number">0x111b495b3464ad21</span>), <span class="tok-comment">// 5^-165</span>
</span>
<span class="line" id="L370">    U128.new(<span class="tok-number">0x936b9fcebb25c995</span>, <span class="tok-number">0xcab10dd900beec34</span>), <span class="tok-comment">// 5^-164</span>
</span>
<span class="line" id="L371">    U128.new(<span class="tok-number">0xb84687c269ef3bfb</span>, <span class="tok-number">0x3d5d514f40eea742</span>), <span class="tok-comment">// 5^-163</span>
</span>
<span class="line" id="L372">    U128.new(<span class="tok-number">0xe65829b3046b0afa</span>, <span class="tok-number">0xcb4a5a3112a5112</span>), <span class="tok-comment">// 5^-162</span>
</span>
<span class="line" id="L373">    U128.new(<span class="tok-number">0x8ff71a0fe2c2e6dc</span>, <span class="tok-number">0x47f0e785eaba72ab</span>), <span class="tok-comment">// 5^-161</span>
</span>
<span class="line" id="L374">    U128.new(<span class="tok-number">0xb3f4e093db73a093</span>, <span class="tok-number">0x59ed216765690f56</span>), <span class="tok-comment">// 5^-160</span>
</span>
<span class="line" id="L375">    U128.new(<span class="tok-number">0xe0f218b8d25088b8</span>, <span class="tok-number">0x306869c13ec3532c</span>), <span class="tok-comment">// 5^-159</span>
</span>
<span class="line" id="L376">    U128.new(<span class="tok-number">0x8c974f7383725573</span>, <span class="tok-number">0x1e414218c73a13fb</span>), <span class="tok-comment">// 5^-158</span>
</span>
<span class="line" id="L377">    U128.new(<span class="tok-number">0xafbd2350644eeacf</span>, <span class="tok-number">0xe5d1929ef90898fa</span>), <span class="tok-comment">// 5^-157</span>
</span>
<span class="line" id="L378">    U128.new(<span class="tok-number">0xdbac6c247d62a583</span>, <span class="tok-number">0xdf45f746b74abf39</span>), <span class="tok-comment">// 5^-156</span>
</span>
<span class="line" id="L379">    U128.new(<span class="tok-number">0x894bc396ce5da772</span>, <span class="tok-number">0x6b8bba8c328eb783</span>), <span class="tok-comment">// 5^-155</span>
</span>
<span class="line" id="L380">    U128.new(<span class="tok-number">0xab9eb47c81f5114f</span>, <span class="tok-number">0x66ea92f3f326564</span>), <span class="tok-comment">// 5^-154</span>
</span>
<span class="line" id="L381">    U128.new(<span class="tok-number">0xd686619ba27255a2</span>, <span class="tok-number">0xc80a537b0efefebd</span>), <span class="tok-comment">// 5^-153</span>
</span>
<span class="line" id="L382">    U128.new(<span class="tok-number">0x8613fd0145877585</span>, <span class="tok-number">0xbd06742ce95f5f36</span>), <span class="tok-comment">// 5^-152</span>
</span>
<span class="line" id="L383">    U128.new(<span class="tok-number">0xa798fc4196e952e7</span>, <span class="tok-number">0x2c48113823b73704</span>), <span class="tok-comment">// 5^-151</span>
</span>
<span class="line" id="L384">    U128.new(<span class="tok-number">0xd17f3b51fca3a7a0</span>, <span class="tok-number">0xf75a15862ca504c5</span>), <span class="tok-comment">// 5^-150</span>
</span>
<span class="line" id="L385">    U128.new(<span class="tok-number">0x82ef85133de648c4</span>, <span class="tok-number">0x9a984d73dbe722fb</span>), <span class="tok-comment">// 5^-149</span>
</span>
<span class="line" id="L386">    U128.new(<span class="tok-number">0xa3ab66580d5fdaf5</span>, <span class="tok-number">0xc13e60d0d2e0ebba</span>), <span class="tok-comment">// 5^-148</span>
</span>
<span class="line" id="L387">    U128.new(<span class="tok-number">0xcc963fee10b7d1b3</span>, <span class="tok-number">0x318df905079926a8</span>), <span class="tok-comment">// 5^-147</span>
</span>
<span class="line" id="L388">    U128.new(<span class="tok-number">0xffbbcfe994e5c61f</span>, <span class="tok-number">0xfdf17746497f7052</span>), <span class="tok-comment">// 5^-146</span>
</span>
<span class="line" id="L389">    U128.new(<span class="tok-number">0x9fd561f1fd0f9bd3</span>, <span class="tok-number">0xfeb6ea8bedefa633</span>), <span class="tok-comment">// 5^-145</span>
</span>
<span class="line" id="L390">    U128.new(<span class="tok-number">0xc7caba6e7c5382c8</span>, <span class="tok-number">0xfe64a52ee96b8fc0</span>), <span class="tok-comment">// 5^-144</span>
</span>
<span class="line" id="L391">    U128.new(<span class="tok-number">0xf9bd690a1b68637b</span>, <span class="tok-number">0x3dfdce7aa3c673b0</span>), <span class="tok-comment">// 5^-143</span>
</span>
<span class="line" id="L392">    U128.new(<span class="tok-number">0x9c1661a651213e2d</span>, <span class="tok-number">0x6bea10ca65c084e</span>), <span class="tok-comment">// 5^-142</span>
</span>
<span class="line" id="L393">    U128.new(<span class="tok-number">0xc31bfa0fe5698db8</span>, <span class="tok-number">0x486e494fcff30a62</span>), <span class="tok-comment">// 5^-141</span>
</span>
<span class="line" id="L394">    U128.new(<span class="tok-number">0xf3e2f893dec3f126</span>, <span class="tok-number">0x5a89dba3c3efccfa</span>), <span class="tok-comment">// 5^-140</span>
</span>
<span class="line" id="L395">    U128.new(<span class="tok-number">0x986ddb5c6b3a76b7</span>, <span class="tok-number">0xf89629465a75e01c</span>), <span class="tok-comment">// 5^-139</span>
</span>
<span class="line" id="L396">    U128.new(<span class="tok-number">0xbe89523386091465</span>, <span class="tok-number">0xf6bbb397f1135823</span>), <span class="tok-comment">// 5^-138</span>
</span>
<span class="line" id="L397">    U128.new(<span class="tok-number">0xee2ba6c0678b597f</span>, <span class="tok-number">0x746aa07ded582e2c</span>), <span class="tok-comment">// 5^-137</span>
</span>
<span class="line" id="L398">    U128.new(<span class="tok-number">0x94db483840b717ef</span>, <span class="tok-number">0xa8c2a44eb4571cdc</span>), <span class="tok-comment">// 5^-136</span>
</span>
<span class="line" id="L399">    U128.new(<span class="tok-number">0xba121a4650e4ddeb</span>, <span class="tok-number">0x92f34d62616ce413</span>), <span class="tok-comment">// 5^-135</span>
</span>
<span class="line" id="L400">    U128.new(<span class="tok-number">0xe896a0d7e51e1566</span>, <span class="tok-number">0x77b020baf9c81d17</span>), <span class="tok-comment">// 5^-134</span>
</span>
<span class="line" id="L401">    U128.new(<span class="tok-number">0x915e2486ef32cd60</span>, <span class="tok-number">0xace1474dc1d122e</span>), <span class="tok-comment">// 5^-133</span>
</span>
<span class="line" id="L402">    U128.new(<span class="tok-number">0xb5b5ada8aaff80b8</span>, <span class="tok-number">0xd819992132456ba</span>), <span class="tok-comment">// 5^-132</span>
</span>
<span class="line" id="L403">    U128.new(<span class="tok-number">0xe3231912d5bf60e6</span>, <span class="tok-number">0x10e1fff697ed6c69</span>), <span class="tok-comment">// 5^-131</span>
</span>
<span class="line" id="L404">    U128.new(<span class="tok-number">0x8df5efabc5979c8f</span>, <span class="tok-number">0xca8d3ffa1ef463c1</span>), <span class="tok-comment">// 5^-130</span>
</span>
<span class="line" id="L405">    U128.new(<span class="tok-number">0xb1736b96b6fd83b3</span>, <span class="tok-number">0xbd308ff8a6b17cb2</span>), <span class="tok-comment">// 5^-129</span>
</span>
<span class="line" id="L406">    U128.new(<span class="tok-number">0xddd0467c64bce4a0</span>, <span class="tok-number">0xac7cb3f6d05ddbde</span>), <span class="tok-comment">// 5^-128</span>
</span>
<span class="line" id="L407">    U128.new(<span class="tok-number">0x8aa22c0dbef60ee4</span>, <span class="tok-number">0x6bcdf07a423aa96b</span>), <span class="tok-comment">// 5^-127</span>
</span>
<span class="line" id="L408">    U128.new(<span class="tok-number">0xad4ab7112eb3929d</span>, <span class="tok-number">0x86c16c98d2c953c6</span>), <span class="tok-comment">// 5^-126</span>
</span>
<span class="line" id="L409">    U128.new(<span class="tok-number">0xd89d64d57a607744</span>, <span class="tok-number">0xe871c7bf077ba8b7</span>), <span class="tok-comment">// 5^-125</span>
</span>
<span class="line" id="L410">    U128.new(<span class="tok-number">0x87625f056c7c4a8b</span>, <span class="tok-number">0x11471cd764ad4972</span>), <span class="tok-comment">// 5^-124</span>
</span>
<span class="line" id="L411">    U128.new(<span class="tok-number">0xa93af6c6c79b5d2d</span>, <span class="tok-number">0xd598e40d3dd89bcf</span>), <span class="tok-comment">// 5^-123</span>
</span>
<span class="line" id="L412">    U128.new(<span class="tok-number">0xd389b47879823479</span>, <span class="tok-number">0x4aff1d108d4ec2c3</span>), <span class="tok-comment">// 5^-122</span>
</span>
<span class="line" id="L413">    U128.new(<span class="tok-number">0x843610cb4bf160cb</span>, <span class="tok-number">0xcedf722a585139ba</span>), <span class="tok-comment">// 5^-121</span>
</span>
<span class="line" id="L414">    U128.new(<span class="tok-number">0xa54394fe1eedb8fe</span>, <span class="tok-number">0xc2974eb4ee658828</span>), <span class="tok-comment">// 5^-120</span>
</span>
<span class="line" id="L415">    U128.new(<span class="tok-number">0xce947a3da6a9273e</span>, <span class="tok-number">0x733d226229feea32</span>), <span class="tok-comment">// 5^-119</span>
</span>
<span class="line" id="L416">    U128.new(<span class="tok-number">0x811ccc668829b887</span>, <span class="tok-number">0x806357d5a3f525f</span>), <span class="tok-comment">// 5^-118</span>
</span>
<span class="line" id="L417">    U128.new(<span class="tok-number">0xa163ff802a3426a8</span>, <span class="tok-number">0xca07c2dcb0cf26f7</span>), <span class="tok-comment">// 5^-117</span>
</span>
<span class="line" id="L418">    U128.new(<span class="tok-number">0xc9bcff6034c13052</span>, <span class="tok-number">0xfc89b393dd02f0b5</span>), <span class="tok-comment">// 5^-116</span>
</span>
<span class="line" id="L419">    U128.new(<span class="tok-number">0xfc2c3f3841f17c67</span>, <span class="tok-number">0xbbac2078d443ace2</span>), <span class="tok-comment">// 5^-115</span>
</span>
<span class="line" id="L420">    U128.new(<span class="tok-number">0x9d9ba7832936edc0</span>, <span class="tok-number">0xd54b944b84aa4c0d</span>), <span class="tok-comment">// 5^-114</span>
</span>
<span class="line" id="L421">    U128.new(<span class="tok-number">0xc5029163f384a931</span>, <span class="tok-number">0xa9e795e65d4df11</span>), <span class="tok-comment">// 5^-113</span>
</span>
<span class="line" id="L422">    U128.new(<span class="tok-number">0xf64335bcf065d37d</span>, <span class="tok-number">0x4d4617b5ff4a16d5</span>), <span class="tok-comment">// 5^-112</span>
</span>
<span class="line" id="L423">    U128.new(<span class="tok-number">0x99ea0196163fa42e</span>, <span class="tok-number">0x504bced1bf8e4e45</span>), <span class="tok-comment">// 5^-111</span>
</span>
<span class="line" id="L424">    U128.new(<span class="tok-number">0xc06481fb9bcf8d39</span>, <span class="tok-number">0xe45ec2862f71e1d6</span>), <span class="tok-comment">// 5^-110</span>
</span>
<span class="line" id="L425">    U128.new(<span class="tok-number">0xf07da27a82c37088</span>, <span class="tok-number">0x5d767327bb4e5a4c</span>), <span class="tok-comment">// 5^-109</span>
</span>
<span class="line" id="L426">    U128.new(<span class="tok-number">0x964e858c91ba2655</span>, <span class="tok-number">0x3a6a07f8d510f86f</span>), <span class="tok-comment">// 5^-108</span>
</span>
<span class="line" id="L427">    U128.new(<span class="tok-number">0xbbe226efb628afea</span>, <span class="tok-number">0x890489f70a55368b</span>), <span class="tok-comment">// 5^-107</span>
</span>
<span class="line" id="L428">    U128.new(<span class="tok-number">0xeadab0aba3b2dbe5</span>, <span class="tok-number">0x2b45ac74ccea842e</span>), <span class="tok-comment">// 5^-106</span>
</span>
<span class="line" id="L429">    U128.new(<span class="tok-number">0x92c8ae6b464fc96f</span>, <span class="tok-number">0x3b0b8bc90012929d</span>), <span class="tok-comment">// 5^-105</span>
</span>
<span class="line" id="L430">    U128.new(<span class="tok-number">0xb77ada0617e3bbcb</span>, <span class="tok-number">0x9ce6ebb40173744</span>), <span class="tok-comment">// 5^-104</span>
</span>
<span class="line" id="L431">    U128.new(<span class="tok-number">0xe55990879ddcaabd</span>, <span class="tok-number">0xcc420a6a101d0515</span>), <span class="tok-comment">// 5^-103</span>
</span>
<span class="line" id="L432">    U128.new(<span class="tok-number">0x8f57fa54c2a9eab6</span>, <span class="tok-number">0x9fa946824a12232d</span>), <span class="tok-comment">// 5^-102</span>
</span>
<span class="line" id="L433">    U128.new(<span class="tok-number">0xb32df8e9f3546564</span>, <span class="tok-number">0x47939822dc96abf9</span>), <span class="tok-comment">// 5^-101</span>
</span>
<span class="line" id="L434">    U128.new(<span class="tok-number">0xdff9772470297ebd</span>, <span class="tok-number">0x59787e2b93bc56f7</span>), <span class="tok-comment">// 5^-100</span>
</span>
<span class="line" id="L435">    U128.new(<span class="tok-number">0x8bfbea76c619ef36</span>, <span class="tok-number">0x57eb4edb3c55b65a</span>), <span class="tok-comment">// 5^-99</span>
</span>
<span class="line" id="L436">    U128.new(<span class="tok-number">0xaefae51477a06b03</span>, <span class="tok-number">0xede622920b6b23f1</span>), <span class="tok-comment">// 5^-98</span>
</span>
<span class="line" id="L437">    U128.new(<span class="tok-number">0xdab99e59958885c4</span>, <span class="tok-number">0xe95fab368e45eced</span>), <span class="tok-comment">// 5^-97</span>
</span>
<span class="line" id="L438">    U128.new(<span class="tok-number">0x88b402f7fd75539b</span>, <span class="tok-number">0x11dbcb0218ebb414</span>), <span class="tok-comment">// 5^-96</span>
</span>
<span class="line" id="L439">    U128.new(<span class="tok-number">0xaae103b5fcd2a881</span>, <span class="tok-number">0xd652bdc29f26a119</span>), <span class="tok-comment">// 5^-95</span>
</span>
<span class="line" id="L440">    U128.new(<span class="tok-number">0xd59944a37c0752a2</span>, <span class="tok-number">0x4be76d3346f0495f</span>), <span class="tok-comment">// 5^-94</span>
</span>
<span class="line" id="L441">    U128.new(<span class="tok-number">0x857fcae62d8493a5</span>, <span class="tok-number">0x6f70a4400c562ddb</span>), <span class="tok-comment">// 5^-93</span>
</span>
<span class="line" id="L442">    U128.new(<span class="tok-number">0xa6dfbd9fb8e5b88e</span>, <span class="tok-number">0xcb4ccd500f6bb952</span>), <span class="tok-comment">// 5^-92</span>
</span>
<span class="line" id="L443">    U128.new(<span class="tok-number">0xd097ad07a71f26b2</span>, <span class="tok-number">0x7e2000a41346a7a7</span>), <span class="tok-comment">// 5^-91</span>
</span>
<span class="line" id="L444">    U128.new(<span class="tok-number">0x825ecc24c873782f</span>, <span class="tok-number">0x8ed400668c0c28c8</span>), <span class="tok-comment">// 5^-90</span>
</span>
<span class="line" id="L445">    U128.new(<span class="tok-number">0xa2f67f2dfa90563b</span>, <span class="tok-number">0x728900802f0f32fa</span>), <span class="tok-comment">// 5^-89</span>
</span>
<span class="line" id="L446">    U128.new(<span class="tok-number">0xcbb41ef979346bca</span>, <span class="tok-number">0x4f2b40a03ad2ffb9</span>), <span class="tok-comment">// 5^-88</span>
</span>
<span class="line" id="L447">    U128.new(<span class="tok-number">0xfea126b7d78186bc</span>, <span class="tok-number">0xe2f610c84987bfa8</span>), <span class="tok-comment">// 5^-87</span>
</span>
<span class="line" id="L448">    U128.new(<span class="tok-number">0x9f24b832e6b0f436</span>, <span class="tok-number">0xdd9ca7d2df4d7c9</span>), <span class="tok-comment">// 5^-86</span>
</span>
<span class="line" id="L449">    U128.new(<span class="tok-number">0xc6ede63fa05d3143</span>, <span class="tok-number">0x91503d1c79720dbb</span>), <span class="tok-comment">// 5^-85</span>
</span>
<span class="line" id="L450">    U128.new(<span class="tok-number">0xf8a95fcf88747d94</span>, <span class="tok-number">0x75a44c6397ce912a</span>), <span class="tok-comment">// 5^-84</span>
</span>
<span class="line" id="L451">    U128.new(<span class="tok-number">0x9b69dbe1b548ce7c</span>, <span class="tok-number">0xc986afbe3ee11aba</span>), <span class="tok-comment">// 5^-83</span>
</span>
<span class="line" id="L452">    U128.new(<span class="tok-number">0xc24452da229b021b</span>, <span class="tok-number">0xfbe85badce996168</span>), <span class="tok-comment">// 5^-82</span>
</span>
<span class="line" id="L453">    U128.new(<span class="tok-number">0xf2d56790ab41c2a2</span>, <span class="tok-number">0xfae27299423fb9c3</span>), <span class="tok-comment">// 5^-81</span>
</span>
<span class="line" id="L454">    U128.new(<span class="tok-number">0x97c560ba6b0919a5</span>, <span class="tok-number">0xdccd879fc967d41a</span>), <span class="tok-comment">// 5^-80</span>
</span>
<span class="line" id="L455">    U128.new(<span class="tok-number">0xbdb6b8e905cb600f</span>, <span class="tok-number">0x5400e987bbc1c920</span>), <span class="tok-comment">// 5^-79</span>
</span>
<span class="line" id="L456">    U128.new(<span class="tok-number">0xed246723473e3813</span>, <span class="tok-number">0x290123e9aab23b68</span>), <span class="tok-comment">// 5^-78</span>
</span>
<span class="line" id="L457">    U128.new(<span class="tok-number">0x9436c0760c86e30b</span>, <span class="tok-number">0xf9a0b6720aaf6521</span>), <span class="tok-comment">// 5^-77</span>
</span>
<span class="line" id="L458">    U128.new(<span class="tok-number">0xb94470938fa89bce</span>, <span class="tok-number">0xf808e40e8d5b3e69</span>), <span class="tok-comment">// 5^-76</span>
</span>
<span class="line" id="L459">    U128.new(<span class="tok-number">0xe7958cb87392c2c2</span>, <span class="tok-number">0xb60b1d1230b20e04</span>), <span class="tok-comment">// 5^-75</span>
</span>
<span class="line" id="L460">    U128.new(<span class="tok-number">0x90bd77f3483bb9b9</span>, <span class="tok-number">0xb1c6f22b5e6f48c2</span>), <span class="tok-comment">// 5^-74</span>
</span>
<span class="line" id="L461">    U128.new(<span class="tok-number">0xb4ecd5f01a4aa828</span>, <span class="tok-number">0x1e38aeb6360b1af3</span>), <span class="tok-comment">// 5^-73</span>
</span>
<span class="line" id="L462">    U128.new(<span class="tok-number">0xe2280b6c20dd5232</span>, <span class="tok-number">0x25c6da63c38de1b0</span>), <span class="tok-comment">// 5^-72</span>
</span>
<span class="line" id="L463">    U128.new(<span class="tok-number">0x8d590723948a535f</span>, <span class="tok-number">0x579c487e5a38ad0e</span>), <span class="tok-comment">// 5^-71</span>
</span>
<span class="line" id="L464">    U128.new(<span class="tok-number">0xb0af48ec79ace837</span>, <span class="tok-number">0x2d835a9df0c6d851</span>), <span class="tok-comment">// 5^-70</span>
</span>
<span class="line" id="L465">    U128.new(<span class="tok-number">0xdcdb1b2798182244</span>, <span class="tok-number">0xf8e431456cf88e65</span>), <span class="tok-comment">// 5^-69</span>
</span>
<span class="line" id="L466">    U128.new(<span class="tok-number">0x8a08f0f8bf0f156b</span>, <span class="tok-number">0x1b8e9ecb641b58ff</span>), <span class="tok-comment">// 5^-68</span>
</span>
<span class="line" id="L467">    U128.new(<span class="tok-number">0xac8b2d36eed2dac5</span>, <span class="tok-number">0xe272467e3d222f3f</span>), <span class="tok-comment">// 5^-67</span>
</span>
<span class="line" id="L468">    U128.new(<span class="tok-number">0xd7adf884aa879177</span>, <span class="tok-number">0x5b0ed81dcc6abb0f</span>), <span class="tok-comment">// 5^-66</span>
</span>
<span class="line" id="L469">    U128.new(<span class="tok-number">0x86ccbb52ea94baea</span>, <span class="tok-number">0x98e947129fc2b4e9</span>), <span class="tok-comment">// 5^-65</span>
</span>
<span class="line" id="L470">    U128.new(<span class="tok-number">0xa87fea27a539e9a5</span>, <span class="tok-number">0x3f2398d747b36224</span>), <span class="tok-comment">// 5^-64</span>
</span>
<span class="line" id="L471">    U128.new(<span class="tok-number">0xd29fe4b18e88640e</span>, <span class="tok-number">0x8eec7f0d19a03aad</span>), <span class="tok-comment">// 5^-63</span>
</span>
<span class="line" id="L472">    U128.new(<span class="tok-number">0x83a3eeeef9153e89</span>, <span class="tok-number">0x1953cf68300424ac</span>), <span class="tok-comment">// 5^-62</span>
</span>
<span class="line" id="L473">    U128.new(<span class="tok-number">0xa48ceaaab75a8e2b</span>, <span class="tok-number">0x5fa8c3423c052dd7</span>), <span class="tok-comment">// 5^-61</span>
</span>
<span class="line" id="L474">    U128.new(<span class="tok-number">0xcdb02555653131b6</span>, <span class="tok-number">0x3792f412cb06794d</span>), <span class="tok-comment">// 5^-60</span>
</span>
<span class="line" id="L475">    U128.new(<span class="tok-number">0x808e17555f3ebf11</span>, <span class="tok-number">0xe2bbd88bbee40bd0</span>), <span class="tok-comment">// 5^-59</span>
</span>
<span class="line" id="L476">    U128.new(<span class="tok-number">0xa0b19d2ab70e6ed6</span>, <span class="tok-number">0x5b6aceaeae9d0ec4</span>), <span class="tok-comment">// 5^-58</span>
</span>
<span class="line" id="L477">    U128.new(<span class="tok-number">0xc8de047564d20a8b</span>, <span class="tok-number">0xf245825a5a445275</span>), <span class="tok-comment">// 5^-57</span>
</span>
<span class="line" id="L478">    U128.new(<span class="tok-number">0xfb158592be068d2e</span>, <span class="tok-number">0xeed6e2f0f0d56712</span>), <span class="tok-comment">// 5^-56</span>
</span>
<span class="line" id="L479">    U128.new(<span class="tok-number">0x9ced737bb6c4183d</span>, <span class="tok-number">0x55464dd69685606b</span>), <span class="tok-comment">// 5^-55</span>
</span>
<span class="line" id="L480">    U128.new(<span class="tok-number">0xc428d05aa4751e4c</span>, <span class="tok-number">0xaa97e14c3c26b886</span>), <span class="tok-comment">// 5^-54</span>
</span>
<span class="line" id="L481">    U128.new(<span class="tok-number">0xf53304714d9265df</span>, <span class="tok-number">0xd53dd99f4b3066a8</span>), <span class="tok-comment">// 5^-53</span>
</span>
<span class="line" id="L482">    U128.new(<span class="tok-number">0x993fe2c6d07b7fab</span>, <span class="tok-number">0xe546a8038efe4029</span>), <span class="tok-comment">// 5^-52</span>
</span>
<span class="line" id="L483">    U128.new(<span class="tok-number">0xbf8fdb78849a5f96</span>, <span class="tok-number">0xde98520472bdd033</span>), <span class="tok-comment">// 5^-51</span>
</span>
<span class="line" id="L484">    U128.new(<span class="tok-number">0xef73d256a5c0f77c</span>, <span class="tok-number">0x963e66858f6d4440</span>), <span class="tok-comment">// 5^-50</span>
</span>
<span class="line" id="L485">    U128.new(<span class="tok-number">0x95a8637627989aad</span>, <span class="tok-number">0xdde7001379a44aa8</span>), <span class="tok-comment">// 5^-49</span>
</span>
<span class="line" id="L486">    U128.new(<span class="tok-number">0xbb127c53b17ec159</span>, <span class="tok-number">0x5560c018580d5d52</span>), <span class="tok-comment">// 5^-48</span>
</span>
<span class="line" id="L487">    U128.new(<span class="tok-number">0xe9d71b689dde71af</span>, <span class="tok-number">0xaab8f01e6e10b4a6</span>), <span class="tok-comment">// 5^-47</span>
</span>
<span class="line" id="L488">    U128.new(<span class="tok-number">0x9226712162ab070d</span>, <span class="tok-number">0xcab3961304ca70e8</span>), <span class="tok-comment">// 5^-46</span>
</span>
<span class="line" id="L489">    U128.new(<span class="tok-number">0xb6b00d69bb55c8d1</span>, <span class="tok-number">0x3d607b97c5fd0d22</span>), <span class="tok-comment">// 5^-45</span>
</span>
<span class="line" id="L490">    U128.new(<span class="tok-number">0xe45c10c42a2b3b05</span>, <span class="tok-number">0x8cb89a7db77c506a</span>), <span class="tok-comment">// 5^-44</span>
</span>
<span class="line" id="L491">    U128.new(<span class="tok-number">0x8eb98a7a9a5b04e3</span>, <span class="tok-number">0x77f3608e92adb242</span>), <span class="tok-comment">// 5^-43</span>
</span>
<span class="line" id="L492">    U128.new(<span class="tok-number">0xb267ed1940f1c61c</span>, <span class="tok-number">0x55f038b237591ed3</span>), <span class="tok-comment">// 5^-42</span>
</span>
<span class="line" id="L493">    U128.new(<span class="tok-number">0xdf01e85f912e37a3</span>, <span class="tok-number">0x6b6c46dec52f6688</span>), <span class="tok-comment">// 5^-41</span>
</span>
<span class="line" id="L494">    U128.new(<span class="tok-number">0x8b61313bbabce2c6</span>, <span class="tok-number">0x2323ac4b3b3da015</span>), <span class="tok-comment">// 5^-40</span>
</span>
<span class="line" id="L495">    U128.new(<span class="tok-number">0xae397d8aa96c1b77</span>, <span class="tok-number">0xabec975e0a0d081a</span>), <span class="tok-comment">// 5^-39</span>
</span>
<span class="line" id="L496">    U128.new(<span class="tok-number">0xd9c7dced53c72255</span>, <span class="tok-number">0x96e7bd358c904a21</span>), <span class="tok-comment">// 5^-38</span>
</span>
<span class="line" id="L497">    U128.new(<span class="tok-number">0x881cea14545c7575</span>, <span class="tok-number">0x7e50d64177da2e54</span>), <span class="tok-comment">// 5^-37</span>
</span>
<span class="line" id="L498">    U128.new(<span class="tok-number">0xaa242499697392d2</span>, <span class="tok-number">0xdde50bd1d5d0b9e9</span>), <span class="tok-comment">// 5^-36</span>
</span>
<span class="line" id="L499">    U128.new(<span class="tok-number">0xd4ad2dbfc3d07787</span>, <span class="tok-number">0x955e4ec64b44e864</span>), <span class="tok-comment">// 5^-35</span>
</span>
<span class="line" id="L500">    U128.new(<span class="tok-number">0x84ec3c97da624ab4</span>, <span class="tok-number">0xbd5af13bef0b113e</span>), <span class="tok-comment">// 5^-34</span>
</span>
<span class="line" id="L501">    U128.new(<span class="tok-number">0xa6274bbdd0fadd61</span>, <span class="tok-number">0xecb1ad8aeacdd58e</span>), <span class="tok-comment">// 5^-33</span>
</span>
<span class="line" id="L502">    U128.new(<span class="tok-number">0xcfb11ead453994ba</span>, <span class="tok-number">0x67de18eda5814af2</span>), <span class="tok-comment">// 5^-32</span>
</span>
<span class="line" id="L503">    U128.new(<span class="tok-number">0x81ceb32c4b43fcf4</span>, <span class="tok-number">0x80eacf948770ced7</span>), <span class="tok-comment">// 5^-31</span>
</span>
<span class="line" id="L504">    U128.new(<span class="tok-number">0xa2425ff75e14fc31</span>, <span class="tok-number">0xa1258379a94d028d</span>), <span class="tok-comment">// 5^-30</span>
</span>
<span class="line" id="L505">    U128.new(<span class="tok-number">0xcad2f7f5359a3b3e</span>, <span class="tok-number">0x96ee45813a04330</span>), <span class="tok-comment">// 5^-29</span>
</span>
<span class="line" id="L506">    U128.new(<span class="tok-number">0xfd87b5f28300ca0d</span>, <span class="tok-number">0x8bca9d6e188853fc</span>), <span class="tok-comment">// 5^-28</span>
</span>
<span class="line" id="L507">    U128.new(<span class="tok-number">0x9e74d1b791e07e48</span>, <span class="tok-number">0x775ea264cf55347e</span>), <span class="tok-comment">// 5^-27</span>
</span>
<span class="line" id="L508">    U128.new(<span class="tok-number">0xc612062576589dda</span>, <span class="tok-number">0x95364afe032a819e</span>), <span class="tok-comment">// 5^-26</span>
</span>
<span class="line" id="L509">    U128.new(<span class="tok-number">0xf79687aed3eec551</span>, <span class="tok-number">0x3a83ddbd83f52205</span>), <span class="tok-comment">// 5^-25</span>
</span>
<span class="line" id="L510">    U128.new(<span class="tok-number">0x9abe14cd44753b52</span>, <span class="tok-number">0xc4926a9672793543</span>), <span class="tok-comment">// 5^-24</span>
</span>
<span class="line" id="L511">    U128.new(<span class="tok-number">0xc16d9a0095928a27</span>, <span class="tok-number">0x75b7053c0f178294</span>), <span class="tok-comment">// 5^-23</span>
</span>
<span class="line" id="L512">    U128.new(<span class="tok-number">0xf1c90080baf72cb1</span>, <span class="tok-number">0x5324c68b12dd6339</span>), <span class="tok-comment">// 5^-22</span>
</span>
<span class="line" id="L513">    U128.new(<span class="tok-number">0x971da05074da7bee</span>, <span class="tok-number">0xd3f6fc16ebca5e04</span>), <span class="tok-comment">// 5^-21</span>
</span>
<span class="line" id="L514">    U128.new(<span class="tok-number">0xbce5086492111aea</span>, <span class="tok-number">0x88f4bb1ca6bcf585</span>), <span class="tok-comment">// 5^-20</span>
</span>
<span class="line" id="L515">    U128.new(<span class="tok-number">0xec1e4a7db69561a5</span>, <span class="tok-number">0x2b31e9e3d06c32e6</span>), <span class="tok-comment">// 5^-19</span>
</span>
<span class="line" id="L516">    U128.new(<span class="tok-number">0x9392ee8e921d5d07</span>, <span class="tok-number">0x3aff322e62439fd0</span>), <span class="tok-comment">// 5^-18</span>
</span>
<span class="line" id="L517">    U128.new(<span class="tok-number">0xb877aa3236a4b449</span>, <span class="tok-number">0x9befeb9fad487c3</span>), <span class="tok-comment">// 5^-17</span>
</span>
<span class="line" id="L518">    U128.new(<span class="tok-number">0xe69594bec44de15b</span>, <span class="tok-number">0x4c2ebe687989a9b4</span>), <span class="tok-comment">// 5^-16</span>
</span>
<span class="line" id="L519">    U128.new(<span class="tok-number">0x901d7cf73ab0acd9</span>, <span class="tok-number">0xf9d37014bf60a11</span>), <span class="tok-comment">// 5^-15</span>
</span>
<span class="line" id="L520">    U128.new(<span class="tok-number">0xb424dc35095cd80f</span>, <span class="tok-number">0x538484c19ef38c95</span>), <span class="tok-comment">// 5^-14</span>
</span>
<span class="line" id="L521">    U128.new(<span class="tok-number">0xe12e13424bb40e13</span>, <span class="tok-number">0x2865a5f206b06fba</span>), <span class="tok-comment">// 5^-13</span>
</span>
<span class="line" id="L522">    U128.new(<span class="tok-number">0x8cbccc096f5088cb</span>, <span class="tok-number">0xf93f87b7442e45d4</span>), <span class="tok-comment">// 5^-12</span>
</span>
<span class="line" id="L523">    U128.new(<span class="tok-number">0xafebff0bcb24aafe</span>, <span class="tok-number">0xf78f69a51539d749</span>), <span class="tok-comment">// 5^-11</span>
</span>
<span class="line" id="L524">    U128.new(<span class="tok-number">0xdbe6fecebdedd5be</span>, <span class="tok-number">0xb573440e5a884d1c</span>), <span class="tok-comment">// 5^-10</span>
</span>
<span class="line" id="L525">    U128.new(<span class="tok-number">0x89705f4136b4a597</span>, <span class="tok-number">0x31680a88f8953031</span>), <span class="tok-comment">// 5^-9</span>
</span>
<span class="line" id="L526">    U128.new(<span class="tok-number">0xabcc77118461cefc</span>, <span class="tok-number">0xfdc20d2b36ba7c3e</span>), <span class="tok-comment">// 5^-8</span>
</span>
<span class="line" id="L527">    U128.new(<span class="tok-number">0xd6bf94d5e57a42bc</span>, <span class="tok-number">0x3d32907604691b4d</span>), <span class="tok-comment">// 5^-7</span>
</span>
<span class="line" id="L528">    U128.new(<span class="tok-number">0x8637bd05af6c69b5</span>, <span class="tok-number">0xa63f9a49c2c1b110</span>), <span class="tok-comment">// 5^-6</span>
</span>
<span class="line" id="L529">    U128.new(<span class="tok-number">0xa7c5ac471b478423</span>, <span class="tok-number">0xfcf80dc33721d54</span>), <span class="tok-comment">// 5^-5</span>
</span>
<span class="line" id="L530">    U128.new(<span class="tok-number">0xd1b71758e219652b</span>, <span class="tok-number">0xd3c36113404ea4a9</span>), <span class="tok-comment">// 5^-4</span>
</span>
<span class="line" id="L531">    U128.new(<span class="tok-number">0x83126e978d4fdf3b</span>, <span class="tok-number">0x645a1cac083126ea</span>), <span class="tok-comment">// 5^-3</span>
</span>
<span class="line" id="L532">    U128.new(<span class="tok-number">0xa3d70a3d70a3d70a</span>, <span class="tok-number">0x3d70a3d70a3d70a4</span>), <span class="tok-comment">// 5^-2</span>
</span>
<span class="line" id="L533">    U128.new(<span class="tok-number">0xcccccccccccccccc</span>, <span class="tok-number">0xcccccccccccccccd</span>), <span class="tok-comment">// 5^-1</span>
</span>
<span class="line" id="L534">    U128.new(<span class="tok-number">0x8000000000000000</span>, <span class="tok-number">0x0</span>), <span class="tok-comment">// 5^0</span>
</span>
<span class="line" id="L535">    U128.new(<span class="tok-number">0xa000000000000000</span>, <span class="tok-number">0x0</span>), <span class="tok-comment">// 5^1</span>
</span>
<span class="line" id="L536">    U128.new(<span class="tok-number">0xc800000000000000</span>, <span class="tok-number">0x0</span>), <span class="tok-comment">// 5^2</span>
</span>
<span class="line" id="L537">    U128.new(<span class="tok-number">0xfa00000000000000</span>, <span class="tok-number">0x0</span>), <span class="tok-comment">// 5^3</span>
</span>
<span class="line" id="L538">    U128.new(<span class="tok-number">0x9c40000000000000</span>, <span class="tok-number">0x0</span>), <span class="tok-comment">// 5^4</span>
</span>
<span class="line" id="L539">    U128.new(<span class="tok-number">0xc350000000000000</span>, <span class="tok-number">0x0</span>), <span class="tok-comment">// 5^5</span>
</span>
<span class="line" id="L540">    U128.new(<span class="tok-number">0xf424000000000000</span>, <span class="tok-number">0x0</span>), <span class="tok-comment">// 5^6</span>
</span>
<span class="line" id="L541">    U128.new(<span class="tok-number">0x9896800000000000</span>, <span class="tok-number">0x0</span>), <span class="tok-comment">// 5^7</span>
</span>
<span class="line" id="L542">    U128.new(<span class="tok-number">0xbebc200000000000</span>, <span class="tok-number">0x0</span>), <span class="tok-comment">// 5^8</span>
</span>
<span class="line" id="L543">    U128.new(<span class="tok-number">0xee6b280000000000</span>, <span class="tok-number">0x0</span>), <span class="tok-comment">// 5^9</span>
</span>
<span class="line" id="L544">    U128.new(<span class="tok-number">0x9502f90000000000</span>, <span class="tok-number">0x0</span>), <span class="tok-comment">// 5^10</span>
</span>
<span class="line" id="L545">    U128.new(<span class="tok-number">0xba43b74000000000</span>, <span class="tok-number">0x0</span>), <span class="tok-comment">// 5^11</span>
</span>
<span class="line" id="L546">    U128.new(<span class="tok-number">0xe8d4a51000000000</span>, <span class="tok-number">0x0</span>), <span class="tok-comment">// 5^12</span>
</span>
<span class="line" id="L547">    U128.new(<span class="tok-number">0x9184e72a00000000</span>, <span class="tok-number">0x0</span>), <span class="tok-comment">// 5^13</span>
</span>
<span class="line" id="L548">    U128.new(<span class="tok-number">0xb5e620f480000000</span>, <span class="tok-number">0x0</span>), <span class="tok-comment">// 5^14</span>
</span>
<span class="line" id="L549">    U128.new(<span class="tok-number">0xe35fa931a0000000</span>, <span class="tok-number">0x0</span>), <span class="tok-comment">// 5^15</span>
</span>
<span class="line" id="L550">    U128.new(<span class="tok-number">0x8e1bc9bf04000000</span>, <span class="tok-number">0x0</span>), <span class="tok-comment">// 5^16</span>
</span>
<span class="line" id="L551">    U128.new(<span class="tok-number">0xb1a2bc2ec5000000</span>, <span class="tok-number">0x0</span>), <span class="tok-comment">// 5^17</span>
</span>
<span class="line" id="L552">    U128.new(<span class="tok-number">0xde0b6b3a76400000</span>, <span class="tok-number">0x0</span>), <span class="tok-comment">// 5^18</span>
</span>
<span class="line" id="L553">    U128.new(<span class="tok-number">0x8ac7230489e80000</span>, <span class="tok-number">0x0</span>), <span class="tok-comment">// 5^19</span>
</span>
<span class="line" id="L554">    U128.new(<span class="tok-number">0xad78ebc5ac620000</span>, <span class="tok-number">0x0</span>), <span class="tok-comment">// 5^20</span>
</span>
<span class="line" id="L555">    U128.new(<span class="tok-number">0xd8d726b7177a8000</span>, <span class="tok-number">0x0</span>), <span class="tok-comment">// 5^21</span>
</span>
<span class="line" id="L556">    U128.new(<span class="tok-number">0x878678326eac9000</span>, <span class="tok-number">0x0</span>), <span class="tok-comment">// 5^22</span>
</span>
<span class="line" id="L557">    U128.new(<span class="tok-number">0xa968163f0a57b400</span>, <span class="tok-number">0x0</span>), <span class="tok-comment">// 5^23</span>
</span>
<span class="line" id="L558">    U128.new(<span class="tok-number">0xd3c21bcecceda100</span>, <span class="tok-number">0x0</span>), <span class="tok-comment">// 5^24</span>
</span>
<span class="line" id="L559">    U128.new(<span class="tok-number">0x84595161401484a0</span>, <span class="tok-number">0x0</span>), <span class="tok-comment">// 5^25</span>
</span>
<span class="line" id="L560">    U128.new(<span class="tok-number">0xa56fa5b99019a5c8</span>, <span class="tok-number">0x0</span>), <span class="tok-comment">// 5^26</span>
</span>
<span class="line" id="L561">    U128.new(<span class="tok-number">0xcecb8f27f4200f3a</span>, <span class="tok-number">0x0</span>), <span class="tok-comment">// 5^27</span>
</span>
<span class="line" id="L562">    U128.new(<span class="tok-number">0x813f3978f8940984</span>, <span class="tok-number">0x4000000000000000</span>), <span class="tok-comment">// 5^28</span>
</span>
<span class="line" id="L563">    U128.new(<span class="tok-number">0xa18f07d736b90be5</span>, <span class="tok-number">0x5000000000000000</span>), <span class="tok-comment">// 5^29</span>
</span>
<span class="line" id="L564">    U128.new(<span class="tok-number">0xc9f2c9cd04674ede</span>, <span class="tok-number">0xa400000000000000</span>), <span class="tok-comment">// 5^30</span>
</span>
<span class="line" id="L565">    U128.new(<span class="tok-number">0xfc6f7c4045812296</span>, <span class="tok-number">0x4d00000000000000</span>), <span class="tok-comment">// 5^31</span>
</span>
<span class="line" id="L566">    U128.new(<span class="tok-number">0x9dc5ada82b70b59d</span>, <span class="tok-number">0xf020000000000000</span>), <span class="tok-comment">// 5^32</span>
</span>
<span class="line" id="L567">    U128.new(<span class="tok-number">0xc5371912364ce305</span>, <span class="tok-number">0x6c28000000000000</span>), <span class="tok-comment">// 5^33</span>
</span>
<span class="line" id="L568">    U128.new(<span class="tok-number">0xf684df56c3e01bc6</span>, <span class="tok-number">0xc732000000000000</span>), <span class="tok-comment">// 5^34</span>
</span>
<span class="line" id="L569">    U128.new(<span class="tok-number">0x9a130b963a6c115c</span>, <span class="tok-number">0x3c7f400000000000</span>), <span class="tok-comment">// 5^35</span>
</span>
<span class="line" id="L570">    U128.new(<span class="tok-number">0xc097ce7bc90715b3</span>, <span class="tok-number">0x4b9f100000000000</span>), <span class="tok-comment">// 5^36</span>
</span>
<span class="line" id="L571">    U128.new(<span class="tok-number">0xf0bdc21abb48db20</span>, <span class="tok-number">0x1e86d40000000000</span>), <span class="tok-comment">// 5^37</span>
</span>
<span class="line" id="L572">    U128.new(<span class="tok-number">0x96769950b50d88f4</span>, <span class="tok-number">0x1314448000000000</span>), <span class="tok-comment">// 5^38</span>
</span>
<span class="line" id="L573">    U128.new(<span class="tok-number">0xbc143fa4e250eb31</span>, <span class="tok-number">0x17d955a000000000</span>), <span class="tok-comment">// 5^39</span>
</span>
<span class="line" id="L574">    U128.new(<span class="tok-number">0xeb194f8e1ae525fd</span>, <span class="tok-number">0x5dcfab0800000000</span>), <span class="tok-comment">// 5^40</span>
</span>
<span class="line" id="L575">    U128.new(<span class="tok-number">0x92efd1b8d0cf37be</span>, <span class="tok-number">0x5aa1cae500000000</span>), <span class="tok-comment">// 5^41</span>
</span>
<span class="line" id="L576">    U128.new(<span class="tok-number">0xb7abc627050305ad</span>, <span class="tok-number">0xf14a3d9e40000000</span>), <span class="tok-comment">// 5^42</span>
</span>
<span class="line" id="L577">    U128.new(<span class="tok-number">0xe596b7b0c643c719</span>, <span class="tok-number">0x6d9ccd05d0000000</span>), <span class="tok-comment">// 5^43</span>
</span>
<span class="line" id="L578">    U128.new(<span class="tok-number">0x8f7e32ce7bea5c6f</span>, <span class="tok-number">0xe4820023a2000000</span>), <span class="tok-comment">// 5^44</span>
</span>
<span class="line" id="L579">    U128.new(<span class="tok-number">0xb35dbf821ae4f38b</span>, <span class="tok-number">0xdda2802c8a800000</span>), <span class="tok-comment">// 5^45</span>
</span>
<span class="line" id="L580">    U128.new(<span class="tok-number">0xe0352f62a19e306e</span>, <span class="tok-number">0xd50b2037ad200000</span>), <span class="tok-comment">// 5^46</span>
</span>
<span class="line" id="L581">    U128.new(<span class="tok-number">0x8c213d9da502de45</span>, <span class="tok-number">0x4526f422cc340000</span>), <span class="tok-comment">// 5^47</span>
</span>
<span class="line" id="L582">    U128.new(<span class="tok-number">0xaf298d050e4395d6</span>, <span class="tok-number">0x9670b12b7f410000</span>), <span class="tok-comment">// 5^48</span>
</span>
<span class="line" id="L583">    U128.new(<span class="tok-number">0xdaf3f04651d47b4c</span>, <span class="tok-number">0x3c0cdd765f114000</span>), <span class="tok-comment">// 5^49</span>
</span>
<span class="line" id="L584">    U128.new(<span class="tok-number">0x88d8762bf324cd0f</span>, <span class="tok-number">0xa5880a69fb6ac800</span>), <span class="tok-comment">// 5^50</span>
</span>
<span class="line" id="L585">    U128.new(<span class="tok-number">0xab0e93b6efee0053</span>, <span class="tok-number">0x8eea0d047a457a00</span>), <span class="tok-comment">// 5^51</span>
</span>
<span class="line" id="L586">    U128.new(<span class="tok-number">0xd5d238a4abe98068</span>, <span class="tok-number">0x72a4904598d6d880</span>), <span class="tok-comment">// 5^52</span>
</span>
<span class="line" id="L587">    U128.new(<span class="tok-number">0x85a36366eb71f041</span>, <span class="tok-number">0x47a6da2b7f864750</span>), <span class="tok-comment">// 5^53</span>
</span>
<span class="line" id="L588">    U128.new(<span class="tok-number">0xa70c3c40a64e6c51</span>, <span class="tok-number">0x999090b65f67d924</span>), <span class="tok-comment">// 5^54</span>
</span>
<span class="line" id="L589">    U128.new(<span class="tok-number">0xd0cf4b50cfe20765</span>, <span class="tok-number">0xfff4b4e3f741cf6d</span>), <span class="tok-comment">// 5^55</span>
</span>
<span class="line" id="L590">    U128.new(<span class="tok-number">0x82818f1281ed449f</span>, <span class="tok-number">0xbff8f10e7a8921a4</span>), <span class="tok-comment">// 5^56</span>
</span>
<span class="line" id="L591">    U128.new(<span class="tok-number">0xa321f2d7226895c7</span>, <span class="tok-number">0xaff72d52192b6a0d</span>), <span class="tok-comment">// 5^57</span>
</span>
<span class="line" id="L592">    U128.new(<span class="tok-number">0xcbea6f8ceb02bb39</span>, <span class="tok-number">0x9bf4f8a69f764490</span>), <span class="tok-comment">// 5^58</span>
</span>
<span class="line" id="L593">    U128.new(<span class="tok-number">0xfee50b7025c36a08</span>, <span class="tok-number">0x2f236d04753d5b4</span>), <span class="tok-comment">// 5^59</span>
</span>
<span class="line" id="L594">    U128.new(<span class="tok-number">0x9f4f2726179a2245</span>, <span class="tok-number">0x1d762422c946590</span>), <span class="tok-comment">// 5^60</span>
</span>
<span class="line" id="L595">    U128.new(<span class="tok-number">0xc722f0ef9d80aad6</span>, <span class="tok-number">0x424d3ad2b7b97ef5</span>), <span class="tok-comment">// 5^61</span>
</span>
<span class="line" id="L596">    U128.new(<span class="tok-number">0xf8ebad2b84e0d58b</span>, <span class="tok-number">0xd2e0898765a7deb2</span>), <span class="tok-comment">// 5^62</span>
</span>
<span class="line" id="L597">    U128.new(<span class="tok-number">0x9b934c3b330c8577</span>, <span class="tok-number">0x63cc55f49f88eb2f</span>), <span class="tok-comment">// 5^63</span>
</span>
<span class="line" id="L598">    U128.new(<span class="tok-number">0xc2781f49ffcfa6d5</span>, <span class="tok-number">0x3cbf6b71c76b25fb</span>), <span class="tok-comment">// 5^64</span>
</span>
<span class="line" id="L599">    U128.new(<span class="tok-number">0xf316271c7fc3908a</span>, <span class="tok-number">0x8bef464e3945ef7a</span>), <span class="tok-comment">// 5^65</span>
</span>
<span class="line" id="L600">    U128.new(<span class="tok-number">0x97edd871cfda3a56</span>, <span class="tok-number">0x97758bf0e3cbb5ac</span>), <span class="tok-comment">// 5^66</span>
</span>
<span class="line" id="L601">    U128.new(<span class="tok-number">0xbde94e8e43d0c8ec</span>, <span class="tok-number">0x3d52eeed1cbea317</span>), <span class="tok-comment">// 5^67</span>
</span>
<span class="line" id="L602">    U128.new(<span class="tok-number">0xed63a231d4c4fb27</span>, <span class="tok-number">0x4ca7aaa863ee4bdd</span>), <span class="tok-comment">// 5^68</span>
</span>
<span class="line" id="L603">    U128.new(<span class="tok-number">0x945e455f24fb1cf8</span>, <span class="tok-number">0x8fe8caa93e74ef6a</span>), <span class="tok-comment">// 5^69</span>
</span>
<span class="line" id="L604">    U128.new(<span class="tok-number">0xb975d6b6ee39e436</span>, <span class="tok-number">0xb3e2fd538e122b44</span>), <span class="tok-comment">// 5^70</span>
</span>
<span class="line" id="L605">    U128.new(<span class="tok-number">0xe7d34c64a9c85d44</span>, <span class="tok-number">0x60dbbca87196b616</span>), <span class="tok-comment">// 5^71</span>
</span>
<span class="line" id="L606">    U128.new(<span class="tok-number">0x90e40fbeea1d3a4a</span>, <span class="tok-number">0xbc8955e946fe31cd</span>), <span class="tok-comment">// 5^72</span>
</span>
<span class="line" id="L607">    U128.new(<span class="tok-number">0xb51d13aea4a488dd</span>, <span class="tok-number">0x6babab6398bdbe41</span>), <span class="tok-comment">// 5^73</span>
</span>
<span class="line" id="L608">    U128.new(<span class="tok-number">0xe264589a4dcdab14</span>, <span class="tok-number">0xc696963c7eed2dd1</span>), <span class="tok-comment">// 5^74</span>
</span>
<span class="line" id="L609">    U128.new(<span class="tok-number">0x8d7eb76070a08aec</span>, <span class="tok-number">0xfc1e1de5cf543ca2</span>), <span class="tok-comment">// 5^75</span>
</span>
<span class="line" id="L610">    U128.new(<span class="tok-number">0xb0de65388cc8ada8</span>, <span class="tok-number">0x3b25a55f43294bcb</span>), <span class="tok-comment">// 5^76</span>
</span>
<span class="line" id="L611">    U128.new(<span class="tok-number">0xdd15fe86affad912</span>, <span class="tok-number">0x49ef0eb713f39ebe</span>), <span class="tok-comment">// 5^77</span>
</span>
<span class="line" id="L612">    U128.new(<span class="tok-number">0x8a2dbf142dfcc7ab</span>, <span class="tok-number">0x6e3569326c784337</span>), <span class="tok-comment">// 5^78</span>
</span>
<span class="line" id="L613">    U128.new(<span class="tok-number">0xacb92ed9397bf996</span>, <span class="tok-number">0x49c2c37f07965404</span>), <span class="tok-comment">// 5^79</span>
</span>
<span class="line" id="L614">    U128.new(<span class="tok-number">0xd7e77a8f87daf7fb</span>, <span class="tok-number">0xdc33745ec97be906</span>), <span class="tok-comment">// 5^80</span>
</span>
<span class="line" id="L615">    U128.new(<span class="tok-number">0x86f0ac99b4e8dafd</span>, <span class="tok-number">0x69a028bb3ded71a3</span>), <span class="tok-comment">// 5^81</span>
</span>
<span class="line" id="L616">    U128.new(<span class="tok-number">0xa8acd7c0222311bc</span>, <span class="tok-number">0xc40832ea0d68ce0c</span>), <span class="tok-comment">// 5^82</span>
</span>
<span class="line" id="L617">    U128.new(<span class="tok-number">0xd2d80db02aabd62b</span>, <span class="tok-number">0xf50a3fa490c30190</span>), <span class="tok-comment">// 5^83</span>
</span>
<span class="line" id="L618">    U128.new(<span class="tok-number">0x83c7088e1aab65db</span>, <span class="tok-number">0x792667c6da79e0fa</span>), <span class="tok-comment">// 5^84</span>
</span>
<span class="line" id="L619">    U128.new(<span class="tok-number">0xa4b8cab1a1563f52</span>, <span class="tok-number">0x577001b891185938</span>), <span class="tok-comment">// 5^85</span>
</span>
<span class="line" id="L620">    U128.new(<span class="tok-number">0xcde6fd5e09abcf26</span>, <span class="tok-number">0xed4c0226b55e6f86</span>), <span class="tok-comment">// 5^86</span>
</span>
<span class="line" id="L621">    U128.new(<span class="tok-number">0x80b05e5ac60b6178</span>, <span class="tok-number">0x544f8158315b05b4</span>), <span class="tok-comment">// 5^87</span>
</span>
<span class="line" id="L622">    U128.new(<span class="tok-number">0xa0dc75f1778e39d6</span>, <span class="tok-number">0x696361ae3db1c721</span>), <span class="tok-comment">// 5^88</span>
</span>
<span class="line" id="L623">    U128.new(<span class="tok-number">0xc913936dd571c84c</span>, <span class="tok-number">0x3bc3a19cd1e38e9</span>), <span class="tok-comment">// 5^89</span>
</span>
<span class="line" id="L624">    U128.new(<span class="tok-number">0xfb5878494ace3a5f</span>, <span class="tok-number">0x4ab48a04065c723</span>), <span class="tok-comment">// 5^90</span>
</span>
<span class="line" id="L625">    U128.new(<span class="tok-number">0x9d174b2dcec0e47b</span>, <span class="tok-number">0x62eb0d64283f9c76</span>), <span class="tok-comment">// 5^91</span>
</span>
<span class="line" id="L626">    U128.new(<span class="tok-number">0xc45d1df942711d9a</span>, <span class="tok-number">0x3ba5d0bd324f8394</span>), <span class="tok-comment">// 5^92</span>
</span>
<span class="line" id="L627">    U128.new(<span class="tok-number">0xf5746577930d6500</span>, <span class="tok-number">0xca8f44ec7ee36479</span>), <span class="tok-comment">// 5^93</span>
</span>
<span class="line" id="L628">    U128.new(<span class="tok-number">0x9968bf6abbe85f20</span>, <span class="tok-number">0x7e998b13cf4e1ecb</span>), <span class="tok-comment">// 5^94</span>
</span>
<span class="line" id="L629">    U128.new(<span class="tok-number">0xbfc2ef456ae276e8</span>, <span class="tok-number">0x9e3fedd8c321a67e</span>), <span class="tok-comment">// 5^95</span>
</span>
<span class="line" id="L630">    U128.new(<span class="tok-number">0xefb3ab16c59b14a2</span>, <span class="tok-number">0xc5cfe94ef3ea101e</span>), <span class="tok-comment">// 5^96</span>
</span>
<span class="line" id="L631">    U128.new(<span class="tok-number">0x95d04aee3b80ece5</span>, <span class="tok-number">0xbba1f1d158724a12</span>), <span class="tok-comment">// 5^97</span>
</span>
<span class="line" id="L632">    U128.new(<span class="tok-number">0xbb445da9ca61281f</span>, <span class="tok-number">0x2a8a6e45ae8edc97</span>), <span class="tok-comment">// 5^98</span>
</span>
<span class="line" id="L633">    U128.new(<span class="tok-number">0xea1575143cf97226</span>, <span class="tok-number">0xf52d09d71a3293bd</span>), <span class="tok-comment">// 5^99</span>
</span>
<span class="line" id="L634">    U128.new(<span class="tok-number">0x924d692ca61be758</span>, <span class="tok-number">0x593c2626705f9c56</span>), <span class="tok-comment">// 5^100</span>
</span>
<span class="line" id="L635">    U128.new(<span class="tok-number">0xb6e0c377cfa2e12e</span>, <span class="tok-number">0x6f8b2fb00c77836c</span>), <span class="tok-comment">// 5^101</span>
</span>
<span class="line" id="L636">    U128.new(<span class="tok-number">0xe498f455c38b997a</span>, <span class="tok-number">0xb6dfb9c0f956447</span>), <span class="tok-comment">// 5^102</span>
</span>
<span class="line" id="L637">    U128.new(<span class="tok-number">0x8edf98b59a373fec</span>, <span class="tok-number">0x4724bd4189bd5eac</span>), <span class="tok-comment">// 5^103</span>
</span>
<span class="line" id="L638">    U128.new(<span class="tok-number">0xb2977ee300c50fe7</span>, <span class="tok-number">0x58edec91ec2cb657</span>), <span class="tok-comment">// 5^104</span>
</span>
<span class="line" id="L639">    U128.new(<span class="tok-number">0xdf3d5e9bc0f653e1</span>, <span class="tok-number">0x2f2967b66737e3ed</span>), <span class="tok-comment">// 5^105</span>
</span>
<span class="line" id="L640">    U128.new(<span class="tok-number">0x8b865b215899f46c</span>, <span class="tok-number">0xbd79e0d20082ee74</span>), <span class="tok-comment">// 5^106</span>
</span>
<span class="line" id="L641">    U128.new(<span class="tok-number">0xae67f1e9aec07187</span>, <span class="tok-number">0xecd8590680a3aa11</span>), <span class="tok-comment">// 5^107</span>
</span>
<span class="line" id="L642">    U128.new(<span class="tok-number">0xda01ee641a708de9</span>, <span class="tok-number">0xe80e6f4820cc9495</span>), <span class="tok-comment">// 5^108</span>
</span>
<span class="line" id="L643">    U128.new(<span class="tok-number">0x884134fe908658b2</span>, <span class="tok-number">0x3109058d147fdcdd</span>), <span class="tok-comment">// 5^109</span>
</span>
<span class="line" id="L644">    U128.new(<span class="tok-number">0xaa51823e34a7eede</span>, <span class="tok-number">0xbd4b46f0599fd415</span>), <span class="tok-comment">// 5^110</span>
</span>
<span class="line" id="L645">    U128.new(<span class="tok-number">0xd4e5e2cdc1d1ea96</span>, <span class="tok-number">0x6c9e18ac7007c91a</span>), <span class="tok-comment">// 5^111</span>
</span>
<span class="line" id="L646">    U128.new(<span class="tok-number">0x850fadc09923329e</span>, <span class="tok-number">0x3e2cf6bc604ddb0</span>), <span class="tok-comment">// 5^112</span>
</span>
<span class="line" id="L647">    U128.new(<span class="tok-number">0xa6539930bf6bff45</span>, <span class="tok-number">0x84db8346b786151c</span>), <span class="tok-comment">// 5^113</span>
</span>
<span class="line" id="L648">    U128.new(<span class="tok-number">0xcfe87f7cef46ff16</span>, <span class="tok-number">0xe612641865679a63</span>), <span class="tok-comment">// 5^114</span>
</span>
<span class="line" id="L649">    U128.new(<span class="tok-number">0x81f14fae158c5f6e</span>, <span class="tok-number">0x4fcb7e8f3f60c07e</span>), <span class="tok-comment">// 5^115</span>
</span>
<span class="line" id="L650">    U128.new(<span class="tok-number">0xa26da3999aef7749</span>, <span class="tok-number">0xe3be5e330f38f09d</span>), <span class="tok-comment">// 5^116</span>
</span>
<span class="line" id="L651">    U128.new(<span class="tok-number">0xcb090c8001ab551c</span>, <span class="tok-number">0x5cadf5bfd3072cc5</span>), <span class="tok-comment">// 5^117</span>
</span>
<span class="line" id="L652">    U128.new(<span class="tok-number">0xfdcb4fa002162a63</span>, <span class="tok-number">0x73d9732fc7c8f7f6</span>), <span class="tok-comment">// 5^118</span>
</span>
<span class="line" id="L653">    U128.new(<span class="tok-number">0x9e9f11c4014dda7e</span>, <span class="tok-number">0x2867e7fddcdd9afa</span>), <span class="tok-comment">// 5^119</span>
</span>
<span class="line" id="L654">    U128.new(<span class="tok-number">0xc646d63501a1511d</span>, <span class="tok-number">0xb281e1fd541501b8</span>), <span class="tok-comment">// 5^120</span>
</span>
<span class="line" id="L655">    U128.new(<span class="tok-number">0xf7d88bc24209a565</span>, <span class="tok-number">0x1f225a7ca91a4226</span>), <span class="tok-comment">// 5^121</span>
</span>
<span class="line" id="L656">    U128.new(<span class="tok-number">0x9ae757596946075f</span>, <span class="tok-number">0x3375788de9b06958</span>), <span class="tok-comment">// 5^122</span>
</span>
<span class="line" id="L657">    U128.new(<span class="tok-number">0xc1a12d2fc3978937</span>, <span class="tok-number">0x52d6b1641c83ae</span>), <span class="tok-comment">// 5^123</span>
</span>
<span class="line" id="L658">    U128.new(<span class="tok-number">0xf209787bb47d6b84</span>, <span class="tok-number">0xc0678c5dbd23a49a</span>), <span class="tok-comment">// 5^124</span>
</span>
<span class="line" id="L659">    U128.new(<span class="tok-number">0x9745eb4d50ce6332</span>, <span class="tok-number">0xf840b7ba963646e0</span>), <span class="tok-comment">// 5^125</span>
</span>
<span class="line" id="L660">    U128.new(<span class="tok-number">0xbd176620a501fbff</span>, <span class="tok-number">0xb650e5a93bc3d898</span>), <span class="tok-comment">// 5^126</span>
</span>
<span class="line" id="L661">    U128.new(<span class="tok-number">0xec5d3fa8ce427aff</span>, <span class="tok-number">0xa3e51f138ab4cebe</span>), <span class="tok-comment">// 5^127</span>
</span>
<span class="line" id="L662">    U128.new(<span class="tok-number">0x93ba47c980e98cdf</span>, <span class="tok-number">0xc66f336c36b10137</span>), <span class="tok-comment">// 5^128</span>
</span>
<span class="line" id="L663">    U128.new(<span class="tok-number">0xb8a8d9bbe123f017</span>, <span class="tok-number">0xb80b0047445d4184</span>), <span class="tok-comment">// 5^129</span>
</span>
<span class="line" id="L664">    U128.new(<span class="tok-number">0xe6d3102ad96cec1d</span>, <span class="tok-number">0xa60dc059157491e5</span>), <span class="tok-comment">// 5^130</span>
</span>
<span class="line" id="L665">    U128.new(<span class="tok-number">0x9043ea1ac7e41392</span>, <span class="tok-number">0x87c89837ad68db2f</span>), <span class="tok-comment">// 5^131</span>
</span>
<span class="line" id="L666">    U128.new(<span class="tok-number">0xb454e4a179dd1877</span>, <span class="tok-number">0x29babe4598c311fb</span>), <span class="tok-comment">// 5^132</span>
</span>
<span class="line" id="L667">    U128.new(<span class="tok-number">0xe16a1dc9d8545e94</span>, <span class="tok-number">0xf4296dd6fef3d67a</span>), <span class="tok-comment">// 5^133</span>
</span>
<span class="line" id="L668">    U128.new(<span class="tok-number">0x8ce2529e2734bb1d</span>, <span class="tok-number">0x1899e4a65f58660c</span>), <span class="tok-comment">// 5^134</span>
</span>
<span class="line" id="L669">    U128.new(<span class="tok-number">0xb01ae745b101e9e4</span>, <span class="tok-number">0x5ec05dcff72e7f8f</span>), <span class="tok-comment">// 5^135</span>
</span>
<span class="line" id="L670">    U128.new(<span class="tok-number">0xdc21a1171d42645d</span>, <span class="tok-number">0x76707543f4fa1f73</span>), <span class="tok-comment">// 5^136</span>
</span>
<span class="line" id="L671">    U128.new(<span class="tok-number">0x899504ae72497eba</span>, <span class="tok-number">0x6a06494a791c53a8</span>), <span class="tok-comment">// 5^137</span>
</span>
<span class="line" id="L672">    U128.new(<span class="tok-number">0xabfa45da0edbde69</span>, <span class="tok-number">0x487db9d17636892</span>), <span class="tok-comment">// 5^138</span>
</span>
<span class="line" id="L673">    U128.new(<span class="tok-number">0xd6f8d7509292d603</span>, <span class="tok-number">0x45a9d2845d3c42b6</span>), <span class="tok-comment">// 5^139</span>
</span>
<span class="line" id="L674">    U128.new(<span class="tok-number">0x865b86925b9bc5c2</span>, <span class="tok-number">0xb8a2392ba45a9b2</span>), <span class="tok-comment">// 5^140</span>
</span>
<span class="line" id="L675">    U128.new(<span class="tok-number">0xa7f26836f282b732</span>, <span class="tok-number">0x8e6cac7768d7141e</span>), <span class="tok-comment">// 5^141</span>
</span>
<span class="line" id="L676">    U128.new(<span class="tok-number">0xd1ef0244af2364ff</span>, <span class="tok-number">0x3207d795430cd926</span>), <span class="tok-comment">// 5^142</span>
</span>
<span class="line" id="L677">    U128.new(<span class="tok-number">0x8335616aed761f1f</span>, <span class="tok-number">0x7f44e6bd49e807b8</span>), <span class="tok-comment">// 5^143</span>
</span>
<span class="line" id="L678">    U128.new(<span class="tok-number">0xa402b9c5a8d3a6e7</span>, <span class="tok-number">0x5f16206c9c6209a6</span>), <span class="tok-comment">// 5^144</span>
</span>
<span class="line" id="L679">    U128.new(<span class="tok-number">0xcd036837130890a1</span>, <span class="tok-number">0x36dba887c37a8c0f</span>), <span class="tok-comment">// 5^145</span>
</span>
<span class="line" id="L680">    U128.new(<span class="tok-number">0x802221226be55a64</span>, <span class="tok-number">0xc2494954da2c9789</span>), <span class="tok-comment">// 5^146</span>
</span>
<span class="line" id="L681">    U128.new(<span class="tok-number">0xa02aa96b06deb0fd</span>, <span class="tok-number">0xf2db9baa10b7bd6c</span>), <span class="tok-comment">// 5^147</span>
</span>
<span class="line" id="L682">    U128.new(<span class="tok-number">0xc83553c5c8965d3d</span>, <span class="tok-number">0x6f92829494e5acc7</span>), <span class="tok-comment">// 5^148</span>
</span>
<span class="line" id="L683">    U128.new(<span class="tok-number">0xfa42a8b73abbf48c</span>, <span class="tok-number">0xcb772339ba1f17f9</span>), <span class="tok-comment">// 5^149</span>
</span>
<span class="line" id="L684">    U128.new(<span class="tok-number">0x9c69a97284b578d7</span>, <span class="tok-number">0xff2a760414536efb</span>), <span class="tok-comment">// 5^150</span>
</span>
<span class="line" id="L685">    U128.new(<span class="tok-number">0xc38413cf25e2d70d</span>, <span class="tok-number">0xfef5138519684aba</span>), <span class="tok-comment">// 5^151</span>
</span>
<span class="line" id="L686">    U128.new(<span class="tok-number">0xf46518c2ef5b8cd1</span>, <span class="tok-number">0x7eb258665fc25d69</span>), <span class="tok-comment">// 5^152</span>
</span>
<span class="line" id="L687">    U128.new(<span class="tok-number">0x98bf2f79d5993802</span>, <span class="tok-number">0xef2f773ffbd97a61</span>), <span class="tok-comment">// 5^153</span>
</span>
<span class="line" id="L688">    U128.new(<span class="tok-number">0xbeeefb584aff8603</span>, <span class="tok-number">0xaafb550ffacfd8fa</span>), <span class="tok-comment">// 5^154</span>
</span>
<span class="line" id="L689">    U128.new(<span class="tok-number">0xeeaaba2e5dbf6784</span>, <span class="tok-number">0x95ba2a53f983cf38</span>), <span class="tok-comment">// 5^155</span>
</span>
<span class="line" id="L690">    U128.new(<span class="tok-number">0x952ab45cfa97a0b2</span>, <span class="tok-number">0xdd945a747bf26183</span>), <span class="tok-comment">// 5^156</span>
</span>
<span class="line" id="L691">    U128.new(<span class="tok-number">0xba756174393d88df</span>, <span class="tok-number">0x94f971119aeef9e4</span>), <span class="tok-comment">// 5^157</span>
</span>
<span class="line" id="L692">    U128.new(<span class="tok-number">0xe912b9d1478ceb17</span>, <span class="tok-number">0x7a37cd5601aab85d</span>), <span class="tok-comment">// 5^158</span>
</span>
<span class="line" id="L693">    U128.new(<span class="tok-number">0x91abb422ccb812ee</span>, <span class="tok-number">0xac62e055c10ab33a</span>), <span class="tok-comment">// 5^159</span>
</span>
<span class="line" id="L694">    U128.new(<span class="tok-number">0xb616a12b7fe617aa</span>, <span class="tok-number">0x577b986b314d6009</span>), <span class="tok-comment">// 5^160</span>
</span>
<span class="line" id="L695">    U128.new(<span class="tok-number">0xe39c49765fdf9d94</span>, <span class="tok-number">0xed5a7e85fda0b80b</span>), <span class="tok-comment">// 5^161</span>
</span>
<span class="line" id="L696">    U128.new(<span class="tok-number">0x8e41ade9fbebc27d</span>, <span class="tok-number">0x14588f13be847307</span>), <span class="tok-comment">// 5^162</span>
</span>
<span class="line" id="L697">    U128.new(<span class="tok-number">0xb1d219647ae6b31c</span>, <span class="tok-number">0x596eb2d8ae258fc8</span>), <span class="tok-comment">// 5^163</span>
</span>
<span class="line" id="L698">    U128.new(<span class="tok-number">0xde469fbd99a05fe3</span>, <span class="tok-number">0x6fca5f8ed9aef3bb</span>), <span class="tok-comment">// 5^164</span>
</span>
<span class="line" id="L699">    U128.new(<span class="tok-number">0x8aec23d680043bee</span>, <span class="tok-number">0x25de7bb9480d5854</span>), <span class="tok-comment">// 5^165</span>
</span>
<span class="line" id="L700">    U128.new(<span class="tok-number">0xada72ccc20054ae9</span>, <span class="tok-number">0xaf561aa79a10ae6a</span>), <span class="tok-comment">// 5^166</span>
</span>
<span class="line" id="L701">    U128.new(<span class="tok-number">0xd910f7ff28069da4</span>, <span class="tok-number">0x1b2ba1518094da04</span>), <span class="tok-comment">// 5^167</span>
</span>
<span class="line" id="L702">    U128.new(<span class="tok-number">0x87aa9aff79042286</span>, <span class="tok-number">0x90fb44d2f05d0842</span>), <span class="tok-comment">// 5^168</span>
</span>
<span class="line" id="L703">    U128.new(<span class="tok-number">0xa99541bf57452b28</span>, <span class="tok-number">0x353a1607ac744a53</span>), <span class="tok-comment">// 5^169</span>
</span>
<span class="line" id="L704">    U128.new(<span class="tok-number">0xd3fa922f2d1675f2</span>, <span class="tok-number">0x42889b8997915ce8</span>), <span class="tok-comment">// 5^170</span>
</span>
<span class="line" id="L705">    U128.new(<span class="tok-number">0x847c9b5d7c2e09b7</span>, <span class="tok-number">0x69956135febada11</span>), <span class="tok-comment">// 5^171</span>
</span>
<span class="line" id="L706">    U128.new(<span class="tok-number">0xa59bc234db398c25</span>, <span class="tok-number">0x43fab9837e699095</span>), <span class="tok-comment">// 5^172</span>
</span>
<span class="line" id="L707">    U128.new(<span class="tok-number">0xcf02b2c21207ef2e</span>, <span class="tok-number">0x94f967e45e03f4bb</span>), <span class="tok-comment">// 5^173</span>
</span>
<span class="line" id="L708">    U128.new(<span class="tok-number">0x8161afb94b44f57d</span>, <span class="tok-number">0x1d1be0eebac278f5</span>), <span class="tok-comment">// 5^174</span>
</span>
<span class="line" id="L709">    U128.new(<span class="tok-number">0xa1ba1ba79e1632dc</span>, <span class="tok-number">0x6462d92a69731732</span>), <span class="tok-comment">// 5^175</span>
</span>
<span class="line" id="L710">    U128.new(<span class="tok-number">0xca28a291859bbf93</span>, <span class="tok-number">0x7d7b8f7503cfdcfe</span>), <span class="tok-comment">// 5^176</span>
</span>
<span class="line" id="L711">    U128.new(<span class="tok-number">0xfcb2cb35e702af78</span>, <span class="tok-number">0x5cda735244c3d43e</span>), <span class="tok-comment">// 5^177</span>
</span>
<span class="line" id="L712">    U128.new(<span class="tok-number">0x9defbf01b061adab</span>, <span class="tok-number">0x3a0888136afa64a7</span>), <span class="tok-comment">// 5^178</span>
</span>
<span class="line" id="L713">    U128.new(<span class="tok-number">0xc56baec21c7a1916</span>, <span class="tok-number">0x88aaa1845b8fdd0</span>), <span class="tok-comment">// 5^179</span>
</span>
<span class="line" id="L714">    U128.new(<span class="tok-number">0xf6c69a72a3989f5b</span>, <span class="tok-number">0x8aad549e57273d45</span>), <span class="tok-comment">// 5^180</span>
</span>
<span class="line" id="L715">    U128.new(<span class="tok-number">0x9a3c2087a63f6399</span>, <span class="tok-number">0x36ac54e2f678864b</span>), <span class="tok-comment">// 5^181</span>
</span>
<span class="line" id="L716">    U128.new(<span class="tok-number">0xc0cb28a98fcf3c7f</span>, <span class="tok-number">0x84576a1bb416a7dd</span>), <span class="tok-comment">// 5^182</span>
</span>
<span class="line" id="L717">    U128.new(<span class="tok-number">0xf0fdf2d3f3c30b9f</span>, <span class="tok-number">0x656d44a2a11c51d5</span>), <span class="tok-comment">// 5^183</span>
</span>
<span class="line" id="L718">    U128.new(<span class="tok-number">0x969eb7c47859e743</span>, <span class="tok-number">0x9f644ae5a4b1b325</span>), <span class="tok-comment">// 5^184</span>
</span>
<span class="line" id="L719">    U128.new(<span class="tok-number">0xbc4665b596706114</span>, <span class="tok-number">0x873d5d9f0dde1fee</span>), <span class="tok-comment">// 5^185</span>
</span>
<span class="line" id="L720">    U128.new(<span class="tok-number">0xeb57ff22fc0c7959</span>, <span class="tok-number">0xa90cb506d155a7ea</span>), <span class="tok-comment">// 5^186</span>
</span>
<span class="line" id="L721">    U128.new(<span class="tok-number">0x9316ff75dd87cbd8</span>, <span class="tok-number">0x9a7f12442d588f2</span>), <span class="tok-comment">// 5^187</span>
</span>
<span class="line" id="L722">    U128.new(<span class="tok-number">0xb7dcbf5354e9bece</span>, <span class="tok-number">0xc11ed6d538aeb2f</span>), <span class="tok-comment">// 5^188</span>
</span>
<span class="line" id="L723">    U128.new(<span class="tok-number">0xe5d3ef282a242e81</span>, <span class="tok-number">0x8f1668c8a86da5fa</span>), <span class="tok-comment">// 5^189</span>
</span>
<span class="line" id="L724">    U128.new(<span class="tok-number">0x8fa475791a569d10</span>, <span class="tok-number">0xf96e017d694487bc</span>), <span class="tok-comment">// 5^190</span>
</span>
<span class="line" id="L725">    U128.new(<span class="tok-number">0xb38d92d760ec4455</span>, <span class="tok-number">0x37c981dcc395a9ac</span>), <span class="tok-comment">// 5^191</span>
</span>
<span class="line" id="L726">    U128.new(<span class="tok-number">0xe070f78d3927556a</span>, <span class="tok-number">0x85bbe253f47b1417</span>), <span class="tok-comment">// 5^192</span>
</span>
<span class="line" id="L727">    U128.new(<span class="tok-number">0x8c469ab843b89562</span>, <span class="tok-number">0x93956d7478ccec8e</span>), <span class="tok-comment">// 5^193</span>
</span>
<span class="line" id="L728">    U128.new(<span class="tok-number">0xaf58416654a6babb</span>, <span class="tok-number">0x387ac8d1970027b2</span>), <span class="tok-comment">// 5^194</span>
</span>
<span class="line" id="L729">    U128.new(<span class="tok-number">0xdb2e51bfe9d0696a</span>, <span class="tok-number">0x6997b05fcc0319e</span>), <span class="tok-comment">// 5^195</span>
</span>
<span class="line" id="L730">    U128.new(<span class="tok-number">0x88fcf317f22241e2</span>, <span class="tok-number">0x441fece3bdf81f03</span>), <span class="tok-comment">// 5^196</span>
</span>
<span class="line" id="L731">    U128.new(<span class="tok-number">0xab3c2fddeeaad25a</span>, <span class="tok-number">0xd527e81cad7626c3</span>), <span class="tok-comment">// 5^197</span>
</span>
<span class="line" id="L732">    U128.new(<span class="tok-number">0xd60b3bd56a5586f1</span>, <span class="tok-number">0x8a71e223d8d3b074</span>), <span class="tok-comment">// 5^198</span>
</span>
<span class="line" id="L733">    U128.new(<span class="tok-number">0x85c7056562757456</span>, <span class="tok-number">0xf6872d5667844e49</span>), <span class="tok-comment">// 5^199</span>
</span>
<span class="line" id="L734">    U128.new(<span class="tok-number">0xa738c6bebb12d16c</span>, <span class="tok-number">0xb428f8ac016561db</span>), <span class="tok-comment">// 5^200</span>
</span>
<span class="line" id="L735">    U128.new(<span class="tok-number">0xd106f86e69d785c7</span>, <span class="tok-number">0xe13336d701beba52</span>), <span class="tok-comment">// 5^201</span>
</span>
<span class="line" id="L736">    U128.new(<span class="tok-number">0x82a45b450226b39c</span>, <span class="tok-number">0xecc0024661173473</span>), <span class="tok-comment">// 5^202</span>
</span>
<span class="line" id="L737">    U128.new(<span class="tok-number">0xa34d721642b06084</span>, <span class="tok-number">0x27f002d7f95d0190</span>), <span class="tok-comment">// 5^203</span>
</span>
<span class="line" id="L738">    U128.new(<span class="tok-number">0xcc20ce9bd35c78a5</span>, <span class="tok-number">0x31ec038df7b441f4</span>), <span class="tok-comment">// 5^204</span>
</span>
<span class="line" id="L739">    U128.new(<span class="tok-number">0xff290242c83396ce</span>, <span class="tok-number">0x7e67047175a15271</span>), <span class="tok-comment">// 5^205</span>
</span>
<span class="line" id="L740">    U128.new(<span class="tok-number">0x9f79a169bd203e41</span>, <span class="tok-number">0xf0062c6e984d386</span>), <span class="tok-comment">// 5^206</span>
</span>
<span class="line" id="L741">    U128.new(<span class="tok-number">0xc75809c42c684dd1</span>, <span class="tok-number">0x52c07b78a3e60868</span>), <span class="tok-comment">// 5^207</span>
</span>
<span class="line" id="L742">    U128.new(<span class="tok-number">0xf92e0c3537826145</span>, <span class="tok-number">0xa7709a56ccdf8a82</span>), <span class="tok-comment">// 5^208</span>
</span>
<span class="line" id="L743">    U128.new(<span class="tok-number">0x9bbcc7a142b17ccb</span>, <span class="tok-number">0x88a66076400bb691</span>), <span class="tok-comment">// 5^209</span>
</span>
<span class="line" id="L744">    U128.new(<span class="tok-number">0xc2abf989935ddbfe</span>, <span class="tok-number">0x6acff893d00ea435</span>), <span class="tok-comment">// 5^210</span>
</span>
<span class="line" id="L745">    U128.new(<span class="tok-number">0xf356f7ebf83552fe</span>, <span class="tok-number">0x583f6b8c4124d43</span>), <span class="tok-comment">// 5^211</span>
</span>
<span class="line" id="L746">    U128.new(<span class="tok-number">0x98165af37b2153de</span>, <span class="tok-number">0xc3727a337a8b704a</span>), <span class="tok-comment">// 5^212</span>
</span>
<span class="line" id="L747">    U128.new(<span class="tok-number">0xbe1bf1b059e9a8d6</span>, <span class="tok-number">0x744f18c0592e4c5c</span>), <span class="tok-comment">// 5^213</span>
</span>
<span class="line" id="L748">    U128.new(<span class="tok-number">0xeda2ee1c7064130c</span>, <span class="tok-number">0x1162def06f79df73</span>), <span class="tok-comment">// 5^214</span>
</span>
<span class="line" id="L749">    U128.new(<span class="tok-number">0x9485d4d1c63e8be7</span>, <span class="tok-number">0x8addcb5645ac2ba8</span>), <span class="tok-comment">// 5^215</span>
</span>
<span class="line" id="L750">    U128.new(<span class="tok-number">0xb9a74a0637ce2ee1</span>, <span class="tok-number">0x6d953e2bd7173692</span>), <span class="tok-comment">// 5^216</span>
</span>
<span class="line" id="L751">    U128.new(<span class="tok-number">0xe8111c87c5c1ba99</span>, <span class="tok-number">0xc8fa8db6ccdd0437</span>), <span class="tok-comment">// 5^217</span>
</span>
<span class="line" id="L752">    U128.new(<span class="tok-number">0x910ab1d4db9914a0</span>, <span class="tok-number">0x1d9c9892400a22a2</span>), <span class="tok-comment">// 5^218</span>
</span>
<span class="line" id="L753">    U128.new(<span class="tok-number">0xb54d5e4a127f59c8</span>, <span class="tok-number">0x2503beb6d00cab4b</span>), <span class="tok-comment">// 5^219</span>
</span>
<span class="line" id="L754">    U128.new(<span class="tok-number">0xe2a0b5dc971f303a</span>, <span class="tok-number">0x2e44ae64840fd61d</span>), <span class="tok-comment">// 5^220</span>
</span>
<span class="line" id="L755">    U128.new(<span class="tok-number">0x8da471a9de737e24</span>, <span class="tok-number">0x5ceaecfed289e5d2</span>), <span class="tok-comment">// 5^221</span>
</span>
<span class="line" id="L756">    U128.new(<span class="tok-number">0xb10d8e1456105dad</span>, <span class="tok-number">0x7425a83e872c5f47</span>), <span class="tok-comment">// 5^222</span>
</span>
<span class="line" id="L757">    U128.new(<span class="tok-number">0xdd50f1996b947518</span>, <span class="tok-number">0xd12f124e28f77719</span>), <span class="tok-comment">// 5^223</span>
</span>
<span class="line" id="L758">    U128.new(<span class="tok-number">0x8a5296ffe33cc92f</span>, <span class="tok-number">0x82bd6b70d99aaa6f</span>), <span class="tok-comment">// 5^224</span>
</span>
<span class="line" id="L759">    U128.new(<span class="tok-number">0xace73cbfdc0bfb7b</span>, <span class="tok-number">0x636cc64d1001550b</span>), <span class="tok-comment">// 5^225</span>
</span>
<span class="line" id="L760">    U128.new(<span class="tok-number">0xd8210befd30efa5a</span>, <span class="tok-number">0x3c47f7e05401aa4e</span>), <span class="tok-comment">// 5^226</span>
</span>
<span class="line" id="L761">    U128.new(<span class="tok-number">0x8714a775e3e95c78</span>, <span class="tok-number">0x65acfaec34810a71</span>), <span class="tok-comment">// 5^227</span>
</span>
<span class="line" id="L762">    U128.new(<span class="tok-number">0xa8d9d1535ce3b396</span>, <span class="tok-number">0x7f1839a741a14d0d</span>), <span class="tok-comment">// 5^228</span>
</span>
<span class="line" id="L763">    U128.new(<span class="tok-number">0xd31045a8341ca07c</span>, <span class="tok-number">0x1ede48111209a050</span>), <span class="tok-comment">// 5^229</span>
</span>
<span class="line" id="L764">    U128.new(<span class="tok-number">0x83ea2b892091e44d</span>, <span class="tok-number">0x934aed0aab460432</span>), <span class="tok-comment">// 5^230</span>
</span>
<span class="line" id="L765">    U128.new(<span class="tok-number">0xa4e4b66b68b65d60</span>, <span class="tok-number">0xf81da84d5617853f</span>), <span class="tok-comment">// 5^231</span>
</span>
<span class="line" id="L766">    U128.new(<span class="tok-number">0xce1de40642e3f4b9</span>, <span class="tok-number">0x36251260ab9d668e</span>), <span class="tok-comment">// 5^232</span>
</span>
<span class="line" id="L767">    U128.new(<span class="tok-number">0x80d2ae83e9ce78f3</span>, <span class="tok-number">0xc1d72b7c6b426019</span>), <span class="tok-comment">// 5^233</span>
</span>
<span class="line" id="L768">    U128.new(<span class="tok-number">0xa1075a24e4421730</span>, <span class="tok-number">0xb24cf65b8612f81f</span>), <span class="tok-comment">// 5^234</span>
</span>
<span class="line" id="L769">    U128.new(<span class="tok-number">0xc94930ae1d529cfc</span>, <span class="tok-number">0xdee033f26797b627</span>), <span class="tok-comment">// 5^235</span>
</span>
<span class="line" id="L770">    U128.new(<span class="tok-number">0xfb9b7cd9a4a7443c</span>, <span class="tok-number">0x169840ef017da3b1</span>), <span class="tok-comment">// 5^236</span>
</span>
<span class="line" id="L771">    U128.new(<span class="tok-number">0x9d412e0806e88aa5</span>, <span class="tok-number">0x8e1f289560ee864e</span>), <span class="tok-comment">// 5^237</span>
</span>
<span class="line" id="L772">    U128.new(<span class="tok-number">0xc491798a08a2ad4e</span>, <span class="tok-number">0xf1a6f2bab92a27e2</span>), <span class="tok-comment">// 5^238</span>
</span>
<span class="line" id="L773">    U128.new(<span class="tok-number">0xf5b5d7ec8acb58a2</span>, <span class="tok-number">0xae10af696774b1db</span>), <span class="tok-comment">// 5^239</span>
</span>
<span class="line" id="L774">    U128.new(<span class="tok-number">0x9991a6f3d6bf1765</span>, <span class="tok-number">0xacca6da1e0a8ef29</span>), <span class="tok-comment">// 5^240</span>
</span>
<span class="line" id="L775">    U128.new(<span class="tok-number">0xbff610b0cc6edd3f</span>, <span class="tok-number">0x17fd090a58d32af3</span>), <span class="tok-comment">// 5^241</span>
</span>
<span class="line" id="L776">    U128.new(<span class="tok-number">0xeff394dcff8a948e</span>, <span class="tok-number">0xddfc4b4cef07f5b0</span>), <span class="tok-comment">// 5^242</span>
</span>
<span class="line" id="L777">    U128.new(<span class="tok-number">0x95f83d0a1fb69cd9</span>, <span class="tok-number">0x4abdaf101564f98e</span>), <span class="tok-comment">// 5^243</span>
</span>
<span class="line" id="L778">    U128.new(<span class="tok-number">0xbb764c4ca7a4440f</span>, <span class="tok-number">0x9d6d1ad41abe37f1</span>), <span class="tok-comment">// 5^244</span>
</span>
<span class="line" id="L779">    U128.new(<span class="tok-number">0xea53df5fd18d5513</span>, <span class="tok-number">0x84c86189216dc5ed</span>), <span class="tok-comment">// 5^245</span>
</span>
<span class="line" id="L780">    U128.new(<span class="tok-number">0x92746b9be2f8552c</span>, <span class="tok-number">0x32fd3cf5b4e49bb4</span>), <span class="tok-comment">// 5^246</span>
</span>
<span class="line" id="L781">    U128.new(<span class="tok-number">0xb7118682dbb66a77</span>, <span class="tok-number">0x3fbc8c33221dc2a1</span>), <span class="tok-comment">// 5^247</span>
</span>
<span class="line" id="L782">    U128.new(<span class="tok-number">0xe4d5e82392a40515</span>, <span class="tok-number">0xfabaf3feaa5334a</span>), <span class="tok-comment">// 5^248</span>
</span>
<span class="line" id="L783">    U128.new(<span class="tok-number">0x8f05b1163ba6832d</span>, <span class="tok-number">0x29cb4d87f2a7400e</span>), <span class="tok-comment">// 5^249</span>
</span>
<span class="line" id="L784">    U128.new(<span class="tok-number">0xb2c71d5bca9023f8</span>, <span class="tok-number">0x743e20e9ef511012</span>), <span class="tok-comment">// 5^250</span>
</span>
<span class="line" id="L785">    U128.new(<span class="tok-number">0xdf78e4b2bd342cf6</span>, <span class="tok-number">0x914da9246b255416</span>), <span class="tok-comment">// 5^251</span>
</span>
<span class="line" id="L786">    U128.new(<span class="tok-number">0x8bab8eefb6409c1a</span>, <span class="tok-number">0x1ad089b6c2f7548e</span>), <span class="tok-comment">// 5^252</span>
</span>
<span class="line" id="L787">    U128.new(<span class="tok-number">0xae9672aba3d0c320</span>, <span class="tok-number">0xa184ac2473b529b1</span>), <span class="tok-comment">// 5^253</span>
</span>
<span class="line" id="L788">    U128.new(<span class="tok-number">0xda3c0f568cc4f3e8</span>, <span class="tok-number">0xc9e5d72d90a2741e</span>), <span class="tok-comment">// 5^254</span>
</span>
<span class="line" id="L789">    U128.new(<span class="tok-number">0x8865899617fb1871</span>, <span class="tok-number">0x7e2fa67c7a658892</span>), <span class="tok-comment">// 5^255</span>
</span>
<span class="line" id="L790">    U128.new(<span class="tok-number">0xaa7eebfb9df9de8d</span>, <span class="tok-number">0xddbb901b98feeab7</span>), <span class="tok-comment">// 5^256</span>
</span>
<span class="line" id="L791">    U128.new(<span class="tok-number">0xd51ea6fa85785631</span>, <span class="tok-number">0x552a74227f3ea565</span>), <span class="tok-comment">// 5^257</span>
</span>
<span class="line" id="L792">    U128.new(<span class="tok-number">0x8533285c936b35de</span>, <span class="tok-number">0xd53a88958f87275f</span>), <span class="tok-comment">// 5^258</span>
</span>
<span class="line" id="L793">    U128.new(<span class="tok-number">0xa67ff273b8460356</span>, <span class="tok-number">0x8a892abaf368f137</span>), <span class="tok-comment">// 5^259</span>
</span>
<span class="line" id="L794">    U128.new(<span class="tok-number">0xd01fef10a657842c</span>, <span class="tok-number">0x2d2b7569b0432d85</span>), <span class="tok-comment">// 5^260</span>
</span>
<span class="line" id="L795">    U128.new(<span class="tok-number">0x8213f56a67f6b29b</span>, <span class="tok-number">0x9c3b29620e29fc73</span>), <span class="tok-comment">// 5^261</span>
</span>
<span class="line" id="L796">    U128.new(<span class="tok-number">0xa298f2c501f45f42</span>, <span class="tok-number">0x8349f3ba91b47b8f</span>), <span class="tok-comment">// 5^262</span>
</span>
<span class="line" id="L797">    U128.new(<span class="tok-number">0xcb3f2f7642717713</span>, <span class="tok-number">0x241c70a936219a73</span>), <span class="tok-comment">// 5^263</span>
</span>
<span class="line" id="L798">    U128.new(<span class="tok-number">0xfe0efb53d30dd4d7</span>, <span class="tok-number">0xed238cd383aa0110</span>), <span class="tok-comment">// 5^264</span>
</span>
<span class="line" id="L799">    U128.new(<span class="tok-number">0x9ec95d1463e8a506</span>, <span class="tok-number">0xf4363804324a40aa</span>), <span class="tok-comment">// 5^265</span>
</span>
<span class="line" id="L800">    U128.new(<span class="tok-number">0xc67bb4597ce2ce48</span>, <span class="tok-number">0xb143c6053edcd0d5</span>), <span class="tok-comment">// 5^266</span>
</span>
<span class="line" id="L801">    U128.new(<span class="tok-number">0xf81aa16fdc1b81da</span>, <span class="tok-number">0xdd94b7868e94050a</span>), <span class="tok-comment">// 5^267</span>
</span>
<span class="line" id="L802">    U128.new(<span class="tok-number">0x9b10a4e5e9913128</span>, <span class="tok-number">0xca7cf2b4191c8326</span>), <span class="tok-comment">// 5^268</span>
</span>
<span class="line" id="L803">    U128.new(<span class="tok-number">0xc1d4ce1f63f57d72</span>, <span class="tok-number">0xfd1c2f611f63a3f0</span>), <span class="tok-comment">// 5^269</span>
</span>
<span class="line" id="L804">    U128.new(<span class="tok-number">0xf24a01a73cf2dccf</span>, <span class="tok-number">0xbc633b39673c8cec</span>), <span class="tok-comment">// 5^270</span>
</span>
<span class="line" id="L805">    U128.new(<span class="tok-number">0x976e41088617ca01</span>, <span class="tok-number">0xd5be0503e085d813</span>), <span class="tok-comment">// 5^271</span>
</span>
<span class="line" id="L806">    U128.new(<span class="tok-number">0xbd49d14aa79dbc82</span>, <span class="tok-number">0x4b2d8644d8a74e18</span>), <span class="tok-comment">// 5^272</span>
</span>
<span class="line" id="L807">    U128.new(<span class="tok-number">0xec9c459d51852ba2</span>, <span class="tok-number">0xddf8e7d60ed1219e</span>), <span class="tok-comment">// 5^273</span>
</span>
<span class="line" id="L808">    U128.new(<span class="tok-number">0x93e1ab8252f33b45</span>, <span class="tok-number">0xcabb90e5c942b503</span>), <span class="tok-comment">// 5^274</span>
</span>
<span class="line" id="L809">    U128.new(<span class="tok-number">0xb8da1662e7b00a17</span>, <span class="tok-number">0x3d6a751f3b936243</span>), <span class="tok-comment">// 5^275</span>
</span>
<span class="line" id="L810">    U128.new(<span class="tok-number">0xe7109bfba19c0c9d</span>, <span class="tok-number">0xcc512670a783ad4</span>), <span class="tok-comment">// 5^276</span>
</span>
<span class="line" id="L811">    U128.new(<span class="tok-number">0x906a617d450187e2</span>, <span class="tok-number">0x27fb2b80668b24c5</span>), <span class="tok-comment">// 5^277</span>
</span>
<span class="line" id="L812">    U128.new(<span class="tok-number">0xb484f9dc9641e9da</span>, <span class="tok-number">0xb1f9f660802dedf6</span>), <span class="tok-comment">// 5^278</span>
</span>
<span class="line" id="L813">    U128.new(<span class="tok-number">0xe1a63853bbd26451</span>, <span class="tok-number">0x5e7873f8a0396973</span>), <span class="tok-comment">// 5^279</span>
</span>
<span class="line" id="L814">    U128.new(<span class="tok-number">0x8d07e33455637eb2</span>, <span class="tok-number">0xdb0b487b6423e1e8</span>), <span class="tok-comment">// 5^280</span>
</span>
<span class="line" id="L815">    U128.new(<span class="tok-number">0xb049dc016abc5e5f</span>, <span class="tok-number">0x91ce1a9a3d2cda62</span>), <span class="tok-comment">// 5^281</span>
</span>
<span class="line" id="L816">    U128.new(<span class="tok-number">0xdc5c5301c56b75f7</span>, <span class="tok-number">0x7641a140cc7810fb</span>), <span class="tok-comment">// 5^282</span>
</span>
<span class="line" id="L817">    U128.new(<span class="tok-number">0x89b9b3e11b6329ba</span>, <span class="tok-number">0xa9e904c87fcb0a9d</span>), <span class="tok-comment">// 5^283</span>
</span>
<span class="line" id="L818">    U128.new(<span class="tok-number">0xac2820d9623bf429</span>, <span class="tok-number">0x546345fa9fbdcd44</span>), <span class="tok-comment">// 5^284</span>
</span>
<span class="line" id="L819">    U128.new(<span class="tok-number">0xd732290fbacaf133</span>, <span class="tok-number">0xa97c177947ad4095</span>), <span class="tok-comment">// 5^285</span>
</span>
<span class="line" id="L820">    U128.new(<span class="tok-number">0x867f59a9d4bed6c0</span>, <span class="tok-number">0x49ed8eabcccc485d</span>), <span class="tok-comment">// 5^286</span>
</span>
<span class="line" id="L821">    U128.new(<span class="tok-number">0xa81f301449ee8c70</span>, <span class="tok-number">0x5c68f256bfff5a74</span>), <span class="tok-comment">// 5^287</span>
</span>
<span class="line" id="L822">    U128.new(<span class="tok-number">0xd226fc195c6a2f8c</span>, <span class="tok-number">0x73832eec6fff3111</span>), <span class="tok-comment">// 5^288</span>
</span>
<span class="line" id="L823">    U128.new(<span class="tok-number">0x83585d8fd9c25db7</span>, <span class="tok-number">0xc831fd53c5ff7eab</span>), <span class="tok-comment">// 5^289</span>
</span>
<span class="line" id="L824">    U128.new(<span class="tok-number">0xa42e74f3d032f525</span>, <span class="tok-number">0xba3e7ca8b77f5e55</span>), <span class="tok-comment">// 5^290</span>
</span>
<span class="line" id="L825">    U128.new(<span class="tok-number">0xcd3a1230c43fb26f</span>, <span class="tok-number">0x28ce1bd2e55f35eb</span>), <span class="tok-comment">// 5^291</span>
</span>
<span class="line" id="L826">    U128.new(<span class="tok-number">0x80444b5e7aa7cf85</span>, <span class="tok-number">0x7980d163cf5b81b3</span>), <span class="tok-comment">// 5^292</span>
</span>
<span class="line" id="L827">    U128.new(<span class="tok-number">0xa0555e361951c366</span>, <span class="tok-number">0xd7e105bcc332621f</span>), <span class="tok-comment">// 5^293</span>
</span>
<span class="line" id="L828">    U128.new(<span class="tok-number">0xc86ab5c39fa63440</span>, <span class="tok-number">0x8dd9472bf3fefaa7</span>), <span class="tok-comment">// 5^294</span>
</span>
<span class="line" id="L829">    U128.new(<span class="tok-number">0xfa856334878fc150</span>, <span class="tok-number">0xb14f98f6f0feb951</span>), <span class="tok-comment">// 5^295</span>
</span>
<span class="line" id="L830">    U128.new(<span class="tok-number">0x9c935e00d4b9d8d2</span>, <span class="tok-number">0x6ed1bf9a569f33d3</span>), <span class="tok-comment">// 5^296</span>
</span>
<span class="line" id="L831">    U128.new(<span class="tok-number">0xc3b8358109e84f07</span>, <span class="tok-number">0xa862f80ec4700c8</span>), <span class="tok-comment">// 5^297</span>
</span>
<span class="line" id="L832">    U128.new(<span class="tok-number">0xf4a642e14c6262c8</span>, <span class="tok-number">0xcd27bb612758c0fa</span>), <span class="tok-comment">// 5^298</span>
</span>
<span class="line" id="L833">    U128.new(<span class="tok-number">0x98e7e9cccfbd7dbd</span>, <span class="tok-number">0x8038d51cb897789c</span>), <span class="tok-comment">// 5^299</span>
</span>
<span class="line" id="L834">    U128.new(<span class="tok-number">0xbf21e44003acdd2c</span>, <span class="tok-number">0xe0470a63e6bd56c3</span>), <span class="tok-comment">// 5^300</span>
</span>
<span class="line" id="L835">    U128.new(<span class="tok-number">0xeeea5d5004981478</span>, <span class="tok-number">0x1858ccfce06cac74</span>), <span class="tok-comment">// 5^301</span>
</span>
<span class="line" id="L836">    U128.new(<span class="tok-number">0x95527a5202df0ccb</span>, <span class="tok-number">0xf37801e0c43ebc8</span>), <span class="tok-comment">// 5^302</span>
</span>
<span class="line" id="L837">    U128.new(<span class="tok-number">0xbaa718e68396cffd</span>, <span class="tok-number">0xd30560258f54e6ba</span>), <span class="tok-comment">// 5^303</span>
</span>
<span class="line" id="L838">    U128.new(<span class="tok-number">0xe950df20247c83fd</span>, <span class="tok-number">0x47c6b82ef32a2069</span>), <span class="tok-comment">// 5^304</span>
</span>
<span class="line" id="L839">    U128.new(<span class="tok-number">0x91d28b7416cdd27e</span>, <span class="tok-number">0x4cdc331d57fa5441</span>), <span class="tok-comment">// 5^305</span>
</span>
<span class="line" id="L840">    U128.new(<span class="tok-number">0xb6472e511c81471d</span>, <span class="tok-number">0xe0133fe4adf8e952</span>), <span class="tok-comment">// 5^306</span>
</span>
<span class="line" id="L841">    U128.new(<span class="tok-number">0xe3d8f9e563a198e5</span>, <span class="tok-number">0x58180fddd97723a6</span>), <span class="tok-comment">// 5^307</span>
</span>
<span class="line" id="L842">    U128.new(<span class="tok-number">0x8e679c2f5e44ff8f</span>, <span class="tok-number">0x570f09eaa7ea7648</span>), <span class="tok-comment">// 5^308</span>
</span>
<span class="line" id="L843">};</span>
<span class="line" id="L844"></span>
</code></pre></body>
</html>