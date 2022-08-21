<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">    <title>fmt/parse_float/decimal.zig - source view</title>
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
<span class="line" id="L4"><span class="tok-kw">const</span> FloatStream = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;FloatStream.zig&quot;</span>);</span>
<span class="line" id="L5"><span class="tok-kw">const</span> isEightDigits = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;common.zig&quot;</span>).isEightDigits;</span>
<span class="line" id="L6"><span class="tok-kw">const</span> mantissaType = common.mantissaType;</span>
<span class="line" id="L7"></span>
<span class="line" id="L8"><span class="tok-comment">// Arbitrary-precision decimal class for fallback algorithms.</span>
</span>
<span class="line" id="L9"><span class="tok-comment">//</span>
</span>
<span class="line" id="L10"><span class="tok-comment">// This is only used if the fast-path (native floats) and</span>
</span>
<span class="line" id="L11"><span class="tok-comment">// the Eisel-Lemire algorithm are unable to unambiguously</span>
</span>
<span class="line" id="L12"><span class="tok-comment">// determine the float.</span>
</span>
<span class="line" id="L13"><span class="tok-comment">//</span>
</span>
<span class="line" id="L14"><span class="tok-comment">// The technique used is &quot;Simple Decimal Conversion&quot;, developed</span>
</span>
<span class="line" id="L15"><span class="tok-comment">// by Nigel Tao and Ken Thompson. A detailed description of the</span>
</span>
<span class="line" id="L16"><span class="tok-comment">// algorithm can be found in &quot;ParseNumberF64 by Simple Decimal Conversion&quot;,</span>
</span>
<span class="line" id="L17"><span class="tok-comment">// available online: &lt;https://nigeltao.github.io/blog/2020/parse-number-f64-simple.html&gt;.</span>
</span>
<span class="line" id="L18"><span class="tok-comment">//</span>
</span>
<span class="line" id="L19"><span class="tok-comment">// Big-decimal implementation. We do not use the big.Int routines since we only require a maximum</span>
</span>
<span class="line" id="L20"><span class="tok-comment">// fixed region of memory. Further, we require only a small subset of operations.</span>
</span>
<span class="line" id="L21"><span class="tok-comment">//</span>
</span>
<span class="line" id="L22"><span class="tok-comment">// This accepts a floating point parameter and will generate a Decimal which can correctly parse</span>
</span>
<span class="line" id="L23"><span class="tok-comment">// the input with sufficient accuracy. Internally this means either a u64 mantissa (f16, f32 or f64)</span>
</span>
<span class="line" id="L24"><span class="tok-comment">// or a u128 mantissa (f128).</span>
</span>
<span class="line" id="L25"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">Decimal</span>(<span class="tok-kw">comptime</span> T: <span class="tok-type">type</span>) <span class="tok-type">type</span> {</span>
<span class="line" id="L26">    <span class="tok-kw">const</span> MantissaT = mantissaType(T);</span>
<span class="line" id="L27">    std.debug.assert(MantissaT == <span class="tok-type">u64</span> <span class="tok-kw">or</span> MantissaT == <span class="tok-type">u128</span>);</span>
<span class="line" id="L28"></span>
<span class="line" id="L29">    <span class="tok-kw">return</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L30">        <span class="tok-kw">const</span> Self = <span class="tok-builtin">@This</span>();</span>
<span class="line" id="L31"></span>
<span class="line" id="L32">        <span class="tok-comment">/// The maximum number of digits required to unambiguously round a float.</span></span>
<span class="line" id="L33">        <span class="tok-comment">///</span></span>
<span class="line" id="L34">        <span class="tok-comment">/// For a double-precision IEEE-754 float, this required 767 digits,</span></span>
<span class="line" id="L35">        <span class="tok-comment">/// so we store the max digits + 1.</span></span>
<span class="line" id="L36">        <span class="tok-comment">///</span></span>
<span class="line" id="L37">        <span class="tok-comment">/// We can exactly represent a float in radix `b` from radix 2 if</span></span>
<span class="line" id="L38">        <span class="tok-comment">/// `b` is divisible by 2. This function calculates the exact number of</span></span>
<span class="line" id="L39">        <span class="tok-comment">/// digits required to exactly represent that float.</span></span>
<span class="line" id="L40">        <span class="tok-comment">///</span></span>
<span class="line" id="L41">        <span class="tok-comment">/// According to the &quot;Handbook of Floating Point Arithmetic&quot;,</span></span>
<span class="line" id="L42">        <span class="tok-comment">/// for IEEE754, with emin being the min exponent, p2 being the</span></span>
<span class="line" id="L43">        <span class="tok-comment">/// precision, and b being the radix, the number of digits follows as:</span></span>
<span class="line" id="L44">        <span class="tok-comment">///</span></span>
<span class="line" id="L45">        <span class="tok-comment">/// `−emin + p2 + ⌊(emin + 1) log(2, b) − log(1 − 2^(−p2), b)⌋`</span></span>
<span class="line" id="L46">        <span class="tok-comment">///</span></span>
<span class="line" id="L47">        <span class="tok-comment">/// For f32, this follows as:</span></span>
<span class="line" id="L48">        <span class="tok-comment">///     emin = -126</span></span>
<span class="line" id="L49">        <span class="tok-comment">///     p2 = 24</span></span>
<span class="line" id="L50">        <span class="tok-comment">///</span></span>
<span class="line" id="L51">        <span class="tok-comment">/// For f64, this follows as:</span></span>
<span class="line" id="L52">        <span class="tok-comment">///     emin = -1022</span></span>
<span class="line" id="L53">        <span class="tok-comment">///     p2 = 53</span></span>
<span class="line" id="L54">        <span class="tok-comment">///</span></span>
<span class="line" id="L55">        <span class="tok-comment">/// For f128, this follows as:</span></span>
<span class="line" id="L56">        <span class="tok-comment">///     emin = -16383</span></span>
<span class="line" id="L57">        <span class="tok-comment">///     p2 = 112</span></span>
<span class="line" id="L58">        <span class="tok-comment">///</span></span>
<span class="line" id="L59">        <span class="tok-comment">/// In Python:</span></span>
<span class="line" id="L60">        <span class="tok-comment">///     `-emin + p2 + math.floor((emin+ 1)*math.log(2, b)-math.log(1-2**(-p2), b))`</span></span>
<span class="line" id="L61">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> max_digits = <span class="tok-kw">if</span> (MantissaT == <span class="tok-type">u64</span>) <span class="tok-number">768</span> <span class="tok-kw">else</span> <span class="tok-number">11564</span>;</span>
<span class="line" id="L62">        <span class="tok-comment">/// The max digits that can be exactly represented in a 64-bit integer.</span></span>
<span class="line" id="L63">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> max_digits_without_overflow = <span class="tok-kw">if</span> (MantissaT == <span class="tok-type">u64</span>) <span class="tok-number">19</span> <span class="tok-kw">else</span> <span class="tok-number">38</span>;</span>
<span class="line" id="L64">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> decimal_point_range = <span class="tok-kw">if</span> (MantissaT == <span class="tok-type">u64</span>) <span class="tok-number">2047</span> <span class="tok-kw">else</span> <span class="tok-number">32767</span>;</span>
<span class="line" id="L65">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> min_exponent = <span class="tok-kw">if</span> (MantissaT == <span class="tok-type">u64</span>) -<span class="tok-number">324</span> <span class="tok-kw">else</span> -<span class="tok-number">4966</span>;</span>
<span class="line" id="L66">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> max_exponent = <span class="tok-kw">if</span> (MantissaT == <span class="tok-type">u64</span>) <span class="tok-number">310</span> <span class="tok-kw">else</span> <span class="tok-number">4933</span>;</span>
<span class="line" id="L67">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> max_decimal_digits = <span class="tok-kw">if</span> (MantissaT == <span class="tok-type">u64</span>) <span class="tok-number">18</span> <span class="tok-kw">else</span> <span class="tok-number">37</span>;</span>
<span class="line" id="L68"></span>
<span class="line" id="L69">        <span class="tok-comment">/// The number of significant digits in the decimal.</span></span>
<span class="line" id="L70">        num_digits: <span class="tok-type">usize</span>,</span>
<span class="line" id="L71">        <span class="tok-comment">/// The offset of the decimal point in the significant digits.</span></span>
<span class="line" id="L72">        decimal_point: <span class="tok-type">i32</span>,</span>
<span class="line" id="L73">        <span class="tok-comment">/// If the number of significant digits stored in the decimal is truncated.</span></span>
<span class="line" id="L74">        truncated: <span class="tok-type">bool</span>,</span>
<span class="line" id="L75">        <span class="tok-comment">/// buffer of the raw digits, in the range [0, 9].</span></span>
<span class="line" id="L76">        digits: [max_digits]<span class="tok-type">u8</span>,</span>
<span class="line" id="L77"></span>
<span class="line" id="L78">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">new</span>() Self {</span>
<span class="line" id="L79">            <span class="tok-kw">return</span> .{</span>
<span class="line" id="L80">                .num_digits = <span class="tok-number">0</span>,</span>
<span class="line" id="L81">                .decimal_point = <span class="tok-number">0</span>,</span>
<span class="line" id="L82">                .truncated = <span class="tok-null">false</span>,</span>
<span class="line" id="L83">                .digits = [_]<span class="tok-type">u8</span>{<span class="tok-number">0</span>} ** max_digits,</span>
<span class="line" id="L84">            };</span>
<span class="line" id="L85">        }</span>
<span class="line" id="L86"></span>
<span class="line" id="L87">        <span class="tok-comment">/// Append a digit to the buffer</span></span>
<span class="line" id="L88">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">tryAddDigit</span>(self: *Self, digit: <span class="tok-type">u8</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L89">            <span class="tok-kw">if</span> (self.num_digits &lt; max_digits) {</span>
<span class="line" id="L90">                self.digits[self.num_digits] = digit;</span>
<span class="line" id="L91">            }</span>
<span class="line" id="L92">            self.num_digits += <span class="tok-number">1</span>;</span>
<span class="line" id="L93">        }</span>
<span class="line" id="L94"></span>
<span class="line" id="L95">        <span class="tok-comment">/// Trim trailing zeroes from the buffer</span></span>
<span class="line" id="L96">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">trim</span>(self: *Self) <span class="tok-type">void</span> {</span>
<span class="line" id="L97">            <span class="tok-comment">// All of the following calls to `Self::trim` can't panic because:</span>
</span>
<span class="line" id="L98">            <span class="tok-comment">//</span>
</span>
<span class="line" id="L99">            <span class="tok-comment">//  1. `parse_decimal` sets `num_digits` to a max of `max_digits`.</span>
</span>
<span class="line" id="L100">            <span class="tok-comment">//  2. `right_shift` sets `num_digits` to `write_index`, which is bounded by `num_digits`.</span>
</span>
<span class="line" id="L101">            <span class="tok-comment">//  3. `left_shift` `num_digits` to a max of `max_digits`.</span>
</span>
<span class="line" id="L102">            <span class="tok-comment">//</span>
</span>
<span class="line" id="L103">            <span class="tok-comment">// Trim is only called in `right_shift` and `left_shift`.</span>
</span>
<span class="line" id="L104">            std.debug.assert(self.num_digits &lt;= max_digits);</span>
<span class="line" id="L105">            <span class="tok-kw">while</span> (self.num_digits != <span class="tok-number">0</span> <span class="tok-kw">and</span> self.digits[self.num_digits - <span class="tok-number">1</span>] == <span class="tok-number">0</span>) {</span>
<span class="line" id="L106">                self.num_digits -= <span class="tok-number">1</span>;</span>
<span class="line" id="L107">            }</span>
<span class="line" id="L108">        }</span>
<span class="line" id="L109"></span>
<span class="line" id="L110">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">round</span>(self: *Self) MantissaT {</span>
<span class="line" id="L111">            <span class="tok-kw">if</span> (self.num_digits == <span class="tok-number">0</span> <span class="tok-kw">or</span> self.decimal_point &lt; <span class="tok-number">0</span>) {</span>
<span class="line" id="L112">                <span class="tok-kw">return</span> <span class="tok-number">0</span>;</span>
<span class="line" id="L113">            } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (self.decimal_point &gt; max_decimal_digits) {</span>
<span class="line" id="L114">                <span class="tok-kw">return</span> math.maxInt(MantissaT);</span>
<span class="line" id="L115">            }</span>
<span class="line" id="L116"></span>
<span class="line" id="L117">            <span class="tok-kw">const</span> dp = <span class="tok-builtin">@intCast</span>(<span class="tok-type">usize</span>, self.decimal_point);</span>
<span class="line" id="L118">            <span class="tok-kw">var</span> n: MantissaT = <span class="tok-number">0</span>;</span>
<span class="line" id="L119"></span>
<span class="line" id="L120">            <span class="tok-kw">var</span> i: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L121">            <span class="tok-kw">while</span> (i &lt; dp) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L122">                n *= <span class="tok-number">10</span>;</span>
<span class="line" id="L123">                <span class="tok-kw">if</span> (i &lt; self.num_digits) {</span>
<span class="line" id="L124">                    n += <span class="tok-builtin">@as</span>(MantissaT, self.digits[i]);</span>
<span class="line" id="L125">                }</span>
<span class="line" id="L126">            }</span>
<span class="line" id="L127"></span>
<span class="line" id="L128">            <span class="tok-kw">var</span> round_up = <span class="tok-null">false</span>;</span>
<span class="line" id="L129">            <span class="tok-kw">if</span> (dp &lt; self.num_digits) {</span>
<span class="line" id="L130">                round_up = self.digits[dp] &gt;= <span class="tok-number">5</span>;</span>
<span class="line" id="L131">                <span class="tok-kw">if</span> (self.digits[dp] == <span class="tok-number">5</span> <span class="tok-kw">and</span> dp + <span class="tok-number">1</span> == self.num_digits) {</span>
<span class="line" id="L132">                    round_up = self.truncated <span class="tok-kw">or</span> ((dp != <span class="tok-number">0</span>) <span class="tok-kw">and</span> (<span class="tok-number">1</span> &amp; self.digits[dp - <span class="tok-number">1</span>] != <span class="tok-number">0</span>));</span>
<span class="line" id="L133">                }</span>
<span class="line" id="L134">            }</span>
<span class="line" id="L135">            <span class="tok-kw">if</span> (round_up) {</span>
<span class="line" id="L136">                n += <span class="tok-number">1</span>;</span>
<span class="line" id="L137">            }</span>
<span class="line" id="L138">            <span class="tok-kw">return</span> n;</span>
<span class="line" id="L139">        }</span>
<span class="line" id="L140"></span>
<span class="line" id="L141">        <span class="tok-comment">/// Computes decimal * 2^shift.</span></span>
<span class="line" id="L142">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">leftShift</span>(self: *Self, shift: <span class="tok-type">usize</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L143">            <span class="tok-kw">if</span> (self.num_digits == <span class="tok-number">0</span>) {</span>
<span class="line" id="L144">                <span class="tok-kw">return</span>;</span>
<span class="line" id="L145">            }</span>
<span class="line" id="L146">            <span class="tok-kw">const</span> num_new_digits = self.numberOfDigitsLeftShift(shift);</span>
<span class="line" id="L147">            <span class="tok-kw">var</span> read_index = self.num_digits;</span>
<span class="line" id="L148">            <span class="tok-kw">var</span> write_index = self.num_digits + num_new_digits;</span>
<span class="line" id="L149">            <span class="tok-kw">var</span> n: MantissaT = <span class="tok-number">0</span>;</span>
<span class="line" id="L150">            <span class="tok-kw">while</span> (read_index != <span class="tok-number">0</span>) {</span>
<span class="line" id="L151">                read_index -= <span class="tok-number">1</span>;</span>
<span class="line" id="L152">                write_index -= <span class="tok-number">1</span>;</span>
<span class="line" id="L153">                n += math.shl(MantissaT, self.digits[read_index], shift);</span>
<span class="line" id="L154"></span>
<span class="line" id="L155">                <span class="tok-kw">const</span> quotient = n / <span class="tok-number">10</span>;</span>
<span class="line" id="L156">                <span class="tok-kw">const</span> remainder = n - (<span class="tok-number">10</span> * quotient);</span>
<span class="line" id="L157">                <span class="tok-kw">if</span> (write_index &lt; max_digits) {</span>
<span class="line" id="L158">                    self.digits[write_index] = <span class="tok-builtin">@intCast</span>(<span class="tok-type">u8</span>, remainder);</span>
<span class="line" id="L159">                } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (remainder &gt; <span class="tok-number">0</span>) {</span>
<span class="line" id="L160">                    self.truncated = <span class="tok-null">true</span>;</span>
<span class="line" id="L161">                }</span>
<span class="line" id="L162">                n = quotient;</span>
<span class="line" id="L163">            }</span>
<span class="line" id="L164">            <span class="tok-kw">while</span> (n &gt; <span class="tok-number">0</span>) {</span>
<span class="line" id="L165">                write_index -= <span class="tok-number">1</span>;</span>
<span class="line" id="L166"></span>
<span class="line" id="L167">                <span class="tok-kw">const</span> quotient = n / <span class="tok-number">10</span>;</span>
<span class="line" id="L168">                <span class="tok-kw">const</span> remainder = n - (<span class="tok-number">10</span> * quotient);</span>
<span class="line" id="L169">                <span class="tok-kw">if</span> (write_index &lt; max_digits) {</span>
<span class="line" id="L170">                    self.digits[write_index] = <span class="tok-builtin">@intCast</span>(<span class="tok-type">u8</span>, remainder);</span>
<span class="line" id="L171">                } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (remainder &gt; <span class="tok-number">0</span>) {</span>
<span class="line" id="L172">                    self.truncated = <span class="tok-null">true</span>;</span>
<span class="line" id="L173">                }</span>
<span class="line" id="L174">                n = quotient;</span>
<span class="line" id="L175">            }</span>
<span class="line" id="L176"></span>
<span class="line" id="L177">            self.num_digits += num_new_digits;</span>
<span class="line" id="L178">            <span class="tok-kw">if</span> (self.num_digits &gt; max_digits) {</span>
<span class="line" id="L179">                self.num_digits = max_digits;</span>
<span class="line" id="L180">            }</span>
<span class="line" id="L181">            self.decimal_point += <span class="tok-builtin">@intCast</span>(<span class="tok-type">i32</span>, num_new_digits);</span>
<span class="line" id="L182">            self.trim();</span>
<span class="line" id="L183">        }</span>
<span class="line" id="L184"></span>
<span class="line" id="L185">        <span class="tok-comment">/// Computes decimal * 2^-shift.</span></span>
<span class="line" id="L186">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">rightShift</span>(self: *Self, shift: <span class="tok-type">usize</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L187">            <span class="tok-kw">var</span> read_index: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L188">            <span class="tok-kw">var</span> write_index: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L189">            <span class="tok-kw">var</span> n: MantissaT = <span class="tok-number">0</span>;</span>
<span class="line" id="L190">            <span class="tok-kw">while</span> (math.shr(MantissaT, n, shift) == <span class="tok-number">0</span>) {</span>
<span class="line" id="L191">                <span class="tok-kw">if</span> (read_index &lt; self.num_digits) {</span>
<span class="line" id="L192">                    n = (<span class="tok-number">10</span> * n) + self.digits[read_index];</span>
<span class="line" id="L193">                    read_index += <span class="tok-number">1</span>;</span>
<span class="line" id="L194">                } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (n == <span class="tok-number">0</span>) {</span>
<span class="line" id="L195">                    <span class="tok-kw">return</span>;</span>
<span class="line" id="L196">                } <span class="tok-kw">else</span> {</span>
<span class="line" id="L197">                    <span class="tok-kw">while</span> (math.shr(MantissaT, n, shift) == <span class="tok-number">0</span>) {</span>
<span class="line" id="L198">                        n *= <span class="tok-number">10</span>;</span>
<span class="line" id="L199">                        read_index += <span class="tok-number">1</span>;</span>
<span class="line" id="L200">                    }</span>
<span class="line" id="L201">                    <span class="tok-kw">break</span>;</span>
<span class="line" id="L202">                }</span>
<span class="line" id="L203">            }</span>
<span class="line" id="L204"></span>
<span class="line" id="L205">            self.decimal_point -= <span class="tok-builtin">@intCast</span>(<span class="tok-type">i32</span>, read_index) - <span class="tok-number">1</span>;</span>
<span class="line" id="L206">            <span class="tok-kw">if</span> (self.decimal_point &lt; -decimal_point_range) {</span>
<span class="line" id="L207">                self.num_digits = <span class="tok-number">0</span>;</span>
<span class="line" id="L208">                self.decimal_point = <span class="tok-number">0</span>;</span>
<span class="line" id="L209">                self.truncated = <span class="tok-null">false</span>;</span>
<span class="line" id="L210">                <span class="tok-kw">return</span>;</span>
<span class="line" id="L211">            }</span>
<span class="line" id="L212"></span>
<span class="line" id="L213">            <span class="tok-kw">const</span> mask = math.shl(MantissaT, <span class="tok-number">1</span>, shift) - <span class="tok-number">1</span>;</span>
<span class="line" id="L214">            <span class="tok-kw">while</span> (read_index &lt; self.num_digits) {</span>
<span class="line" id="L215">                <span class="tok-kw">const</span> new_digit = <span class="tok-builtin">@intCast</span>(<span class="tok-type">u8</span>, math.shr(MantissaT, n, shift));</span>
<span class="line" id="L216">                n = (<span class="tok-number">10</span> * (n &amp; mask)) + self.digits[read_index];</span>
<span class="line" id="L217">                read_index += <span class="tok-number">1</span>;</span>
<span class="line" id="L218">                self.digits[write_index] = new_digit;</span>
<span class="line" id="L219">                write_index += <span class="tok-number">1</span>;</span>
<span class="line" id="L220">            }</span>
<span class="line" id="L221">            <span class="tok-kw">while</span> (n &gt; <span class="tok-number">0</span>) {</span>
<span class="line" id="L222">                <span class="tok-kw">const</span> new_digit = <span class="tok-builtin">@intCast</span>(<span class="tok-type">u8</span>, math.shr(MantissaT, n, shift));</span>
<span class="line" id="L223">                n = <span class="tok-number">10</span> * (n &amp; mask);</span>
<span class="line" id="L224">                <span class="tok-kw">if</span> (write_index &lt; max_digits) {</span>
<span class="line" id="L225">                    self.digits[write_index] = new_digit;</span>
<span class="line" id="L226">                    write_index += <span class="tok-number">1</span>;</span>
<span class="line" id="L227">                } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (new_digit &gt; <span class="tok-number">0</span>) {</span>
<span class="line" id="L228">                    self.truncated = <span class="tok-null">true</span>;</span>
<span class="line" id="L229">                }</span>
<span class="line" id="L230">            }</span>
<span class="line" id="L231">            self.num_digits = write_index;</span>
<span class="line" id="L232">            self.trim();</span>
<span class="line" id="L233">        }</span>
<span class="line" id="L234"></span>
<span class="line" id="L235">        <span class="tok-comment">/// Parse a bit integer representation of the float as a decimal.</span></span>
<span class="line" id="L236">        <span class="tok-comment">// We do not verify underscores in this path since these will have been verified</span>
</span>
<span class="line" id="L237">        <span class="tok-comment">// via parse.parseNumber so can assume the number is well-formed.</span>
</span>
<span class="line" id="L238">        <span class="tok-comment">// This code-path does not have to handle hex-floats since these will always be handled via another</span>
</span>
<span class="line" id="L239">        <span class="tok-comment">// function prior to this.</span>
</span>
<span class="line" id="L240">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">parse</span>(s: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) Self {</span>
<span class="line" id="L241">            <span class="tok-kw">var</span> d = Self.new();</span>
<span class="line" id="L242">            <span class="tok-kw">var</span> stream = FloatStream.init(s);</span>
<span class="line" id="L243"></span>
<span class="line" id="L244">            stream.skipChars2(<span class="tok-str">'0'</span>, <span class="tok-str">'_'</span>);</span>
<span class="line" id="L245">            <span class="tok-kw">while</span> (stream.scanDigit(<span class="tok-number">10</span>)) |digit| {</span>
<span class="line" id="L246">                d.tryAddDigit(digit);</span>
<span class="line" id="L247">            }</span>
<span class="line" id="L248"></span>
<span class="line" id="L249">            <span class="tok-kw">if</span> (stream.firstIs(<span class="tok-str">'.'</span>)) {</span>
<span class="line" id="L250">                stream.advance(<span class="tok-number">1</span>);</span>
<span class="line" id="L251">                <span class="tok-kw">const</span> marker = stream.offsetTrue();</span>
<span class="line" id="L252"></span>
<span class="line" id="L253">                <span class="tok-comment">// Skip leading zeroes</span>
</span>
<span class="line" id="L254">                <span class="tok-kw">if</span> (d.num_digits == <span class="tok-number">0</span>) {</span>
<span class="line" id="L255">                    stream.skipChars(<span class="tok-str">'0'</span>);</span>
<span class="line" id="L256">                }</span>
<span class="line" id="L257"></span>
<span class="line" id="L258">                <span class="tok-kw">while</span> (stream.hasLen(<span class="tok-number">8</span>) <span class="tok-kw">and</span> d.num_digits + <span class="tok-number">8</span> &lt; max_digits) {</span>
<span class="line" id="L259">                    <span class="tok-kw">const</span> v = stream.readU64Unchecked();</span>
<span class="line" id="L260">                    <span class="tok-kw">if</span> (!isEightDigits(v)) {</span>
<span class="line" id="L261">                        <span class="tok-kw">break</span>;</span>
<span class="line" id="L262">                    }</span>
<span class="line" id="L263">                    std.mem.writeIntSliceLittle(<span class="tok-type">u64</span>, d.digits[d.num_digits..], v - <span class="tok-number">0x3030_3030_3030_3030</span>);</span>
<span class="line" id="L264">                    d.num_digits += <span class="tok-number">8</span>;</span>
<span class="line" id="L265">                    stream.advance(<span class="tok-number">8</span>);</span>
<span class="line" id="L266">                }</span>
<span class="line" id="L267"></span>
<span class="line" id="L268">                <span class="tok-kw">while</span> (stream.scanDigit(<span class="tok-number">10</span>)) |digit| {</span>
<span class="line" id="L269">                    d.tryAddDigit(digit);</span>
<span class="line" id="L270">                }</span>
<span class="line" id="L271">                d.decimal_point = <span class="tok-builtin">@intCast</span>(<span class="tok-type">i32</span>, marker) - <span class="tok-builtin">@intCast</span>(<span class="tok-type">i32</span>, stream.offsetTrue());</span>
<span class="line" id="L272">            }</span>
<span class="line" id="L273">            <span class="tok-kw">if</span> (d.num_digits != <span class="tok-number">0</span>) {</span>
<span class="line" id="L274">                <span class="tok-comment">// Ignore trailing zeros if any</span>
</span>
<span class="line" id="L275">                <span class="tok-kw">var</span> n_trailing_zeros: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L276">                <span class="tok-kw">var</span> i = stream.offsetTrue() - <span class="tok-number">1</span>;</span>
<span class="line" id="L277">                <span class="tok-kw">while</span> (<span class="tok-null">true</span>) {</span>
<span class="line" id="L278">                    <span class="tok-kw">if</span> (s[i] == <span class="tok-str">'0'</span>) {</span>
<span class="line" id="L279">                        n_trailing_zeros += <span class="tok-number">1</span>;</span>
<span class="line" id="L280">                    } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (s[i] != <span class="tok-str">'.'</span>) {</span>
<span class="line" id="L281">                        <span class="tok-kw">break</span>;</span>
<span class="line" id="L282">                    }</span>
<span class="line" id="L283"></span>
<span class="line" id="L284">                    i -= <span class="tok-number">1</span>;</span>
<span class="line" id="L285">                    <span class="tok-kw">if</span> (i == <span class="tok-number">0</span>) <span class="tok-kw">break</span>;</span>
<span class="line" id="L286">                }</span>
<span class="line" id="L287">                d.decimal_point += <span class="tok-builtin">@intCast</span>(<span class="tok-type">i32</span>, n_trailing_zeros);</span>
<span class="line" id="L288">                d.num_digits -= n_trailing_zeros;</span>
<span class="line" id="L289">                d.decimal_point += <span class="tok-builtin">@intCast</span>(<span class="tok-type">i32</span>, d.num_digits);</span>
<span class="line" id="L290">                <span class="tok-kw">if</span> (d.num_digits &gt; max_digits) {</span>
<span class="line" id="L291">                    d.truncated = <span class="tok-null">true</span>;</span>
<span class="line" id="L292">                    d.num_digits = max_digits;</span>
<span class="line" id="L293">                }</span>
<span class="line" id="L294">            }</span>
<span class="line" id="L295">            <span class="tok-kw">if</span> (stream.firstIsLower(<span class="tok-str">'e'</span>)) {</span>
<span class="line" id="L296">                stream.advance(<span class="tok-number">1</span>);</span>
<span class="line" id="L297">                <span class="tok-kw">var</span> neg_exp = <span class="tok-null">false</span>;</span>
<span class="line" id="L298">                <span class="tok-kw">if</span> (stream.firstIs(<span class="tok-str">'-'</span>)) {</span>
<span class="line" id="L299">                    neg_exp = <span class="tok-null">true</span>;</span>
<span class="line" id="L300">                    stream.advance(<span class="tok-number">1</span>);</span>
<span class="line" id="L301">                } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (stream.firstIs(<span class="tok-str">'+'</span>)) {</span>
<span class="line" id="L302">                    stream.advance(<span class="tok-number">1</span>);</span>
<span class="line" id="L303">                }</span>
<span class="line" id="L304">                <span class="tok-kw">var</span> exp_num: <span class="tok-type">i32</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L305">                <span class="tok-kw">while</span> (stream.scanDigit(<span class="tok-number">10</span>)) |digit| {</span>
<span class="line" id="L306">                    <span class="tok-kw">if</span> (exp_num &lt; <span class="tok-number">0x10000</span>) {</span>
<span class="line" id="L307">                        exp_num = <span class="tok-number">10</span> * exp_num + digit;</span>
<span class="line" id="L308">                    }</span>
<span class="line" id="L309">                }</span>
<span class="line" id="L310">                d.decimal_point += <span class="tok-kw">if</span> (neg_exp) -exp_num <span class="tok-kw">else</span> exp_num;</span>
<span class="line" id="L311">            }</span>
<span class="line" id="L312"></span>
<span class="line" id="L313">            <span class="tok-kw">var</span> i = d.num_digits;</span>
<span class="line" id="L314">            <span class="tok-kw">while</span> (i &lt; max_digits_without_overflow) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L315">                d.digits[i] = <span class="tok-number">0</span>;</span>
<span class="line" id="L316">            }</span>
<span class="line" id="L317"></span>
<span class="line" id="L318">            <span class="tok-kw">return</span> d;</span>
<span class="line" id="L319">        }</span>
<span class="line" id="L320"></span>
<span class="line" id="L321">        <span class="tok-comment">// Compute the number decimal digits introduced by a base-2 shift. This is performed</span>
</span>
<span class="line" id="L322">        <span class="tok-comment">// by storing the leading digits of 1/2^i = 5^i and using these along with the cut-off</span>
</span>
<span class="line" id="L323">        <span class="tok-comment">// value to quickly determine the decimal shift from binary.</span>
</span>
<span class="line" id="L324">        <span class="tok-comment">//</span>
</span>
<span class="line" id="L325">        <span class="tok-comment">// See also https://github.com/golang/go/blob/go1.15.3/src/strconv/decimal.go#L163 for</span>
</span>
<span class="line" id="L326">        <span class="tok-comment">// another description of the method.</span>
</span>
<span class="line" id="L327">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">numberOfDigitsLeftShift</span>(self: *Self, shift: <span class="tok-type">usize</span>) <span class="tok-type">usize</span> {</span>
<span class="line" id="L328">            <span class="tok-kw">const</span> ShiftCutoff = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L329">                delta: <span class="tok-type">u8</span>,</span>
<span class="line" id="L330">                cutoff: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L331">            };</span>
<span class="line" id="L332"></span>
<span class="line" id="L333">            <span class="tok-comment">// Leading digits of 1/2^i = 5^i.</span>
</span>
<span class="line" id="L334">            <span class="tok-comment">//</span>
</span>
<span class="line" id="L335">            <span class="tok-comment">// ```</span>
</span>
<span class="line" id="L336">            <span class="tok-comment">// import math</span>
</span>
<span class="line" id="L337">            <span class="tok-comment">//</span>
</span>
<span class="line" id="L338">            <span class="tok-comment">// bits = 128</span>
</span>
<span class="line" id="L339">            <span class="tok-comment">// for i in range(bits):</span>
</span>
<span class="line" id="L340">            <span class="tok-comment">//     log2 = math.log(2)/math.log(10)</span>
</span>
<span class="line" id="L341">            <span class="tok-comment">//     print(f'.{{ .delta = {int(log2*i+1)}, .cutoff = &quot;{5**i}&quot; }}, // {2**i}')</span>
</span>
<span class="line" id="L342">            <span class="tok-comment">// ```</span>
</span>
<span class="line" id="L343">            <span class="tok-kw">const</span> pow2_to_pow5_table = [_]ShiftCutoff{</span>
<span class="line" id="L344">                .{ .delta = <span class="tok-number">0</span>, .cutoff = <span class="tok-str">&quot;&quot;</span> },</span>
<span class="line" id="L345">                .{ .delta = <span class="tok-number">1</span>, .cutoff = <span class="tok-str">&quot;5&quot;</span> }, <span class="tok-comment">// 2</span>
</span>
<span class="line" id="L346">                .{ .delta = <span class="tok-number">1</span>, .cutoff = <span class="tok-str">&quot;25&quot;</span> }, <span class="tok-comment">// 4</span>
</span>
<span class="line" id="L347">                .{ .delta = <span class="tok-number">1</span>, .cutoff = <span class="tok-str">&quot;125&quot;</span> }, <span class="tok-comment">// 8</span>
</span>
<span class="line" id="L348">                .{ .delta = <span class="tok-number">2</span>, .cutoff = <span class="tok-str">&quot;625&quot;</span> }, <span class="tok-comment">// 16</span>
</span>
<span class="line" id="L349">                .{ .delta = <span class="tok-number">2</span>, .cutoff = <span class="tok-str">&quot;3125&quot;</span> }, <span class="tok-comment">// 32</span>
</span>
<span class="line" id="L350">                .{ .delta = <span class="tok-number">2</span>, .cutoff = <span class="tok-str">&quot;15625&quot;</span> }, <span class="tok-comment">// 64</span>
</span>
<span class="line" id="L351">                .{ .delta = <span class="tok-number">3</span>, .cutoff = <span class="tok-str">&quot;78125&quot;</span> }, <span class="tok-comment">// 128</span>
</span>
<span class="line" id="L352">                .{ .delta = <span class="tok-number">3</span>, .cutoff = <span class="tok-str">&quot;390625&quot;</span> }, <span class="tok-comment">// 256</span>
</span>
<span class="line" id="L353">                .{ .delta = <span class="tok-number">3</span>, .cutoff = <span class="tok-str">&quot;1953125&quot;</span> }, <span class="tok-comment">// 512</span>
</span>
<span class="line" id="L354">                .{ .delta = <span class="tok-number">4</span>, .cutoff = <span class="tok-str">&quot;9765625&quot;</span> }, <span class="tok-comment">// 1024</span>
</span>
<span class="line" id="L355">                .{ .delta = <span class="tok-number">4</span>, .cutoff = <span class="tok-str">&quot;48828125&quot;</span> }, <span class="tok-comment">// 2048</span>
</span>
<span class="line" id="L356">                .{ .delta = <span class="tok-number">4</span>, .cutoff = <span class="tok-str">&quot;244140625&quot;</span> }, <span class="tok-comment">// 4096</span>
</span>
<span class="line" id="L357">                .{ .delta = <span class="tok-number">4</span>, .cutoff = <span class="tok-str">&quot;1220703125&quot;</span> }, <span class="tok-comment">// 8192</span>
</span>
<span class="line" id="L358">                .{ .delta = <span class="tok-number">5</span>, .cutoff = <span class="tok-str">&quot;6103515625&quot;</span> }, <span class="tok-comment">// 16384</span>
</span>
<span class="line" id="L359">                .{ .delta = <span class="tok-number">5</span>, .cutoff = <span class="tok-str">&quot;30517578125&quot;</span> }, <span class="tok-comment">// 32768</span>
</span>
<span class="line" id="L360">                .{ .delta = <span class="tok-number">5</span>, .cutoff = <span class="tok-str">&quot;152587890625&quot;</span> }, <span class="tok-comment">// 65536</span>
</span>
<span class="line" id="L361">                .{ .delta = <span class="tok-number">6</span>, .cutoff = <span class="tok-str">&quot;762939453125&quot;</span> }, <span class="tok-comment">// 131072</span>
</span>
<span class="line" id="L362">                .{ .delta = <span class="tok-number">6</span>, .cutoff = <span class="tok-str">&quot;3814697265625&quot;</span> }, <span class="tok-comment">// 262144</span>
</span>
<span class="line" id="L363">                .{ .delta = <span class="tok-number">6</span>, .cutoff = <span class="tok-str">&quot;19073486328125&quot;</span> }, <span class="tok-comment">// 524288</span>
</span>
<span class="line" id="L364">                .{ .delta = <span class="tok-number">7</span>, .cutoff = <span class="tok-str">&quot;95367431640625&quot;</span> }, <span class="tok-comment">// 1048576</span>
</span>
<span class="line" id="L365">                .{ .delta = <span class="tok-number">7</span>, .cutoff = <span class="tok-str">&quot;476837158203125&quot;</span> }, <span class="tok-comment">// 2097152</span>
</span>
<span class="line" id="L366">                .{ .delta = <span class="tok-number">7</span>, .cutoff = <span class="tok-str">&quot;2384185791015625&quot;</span> }, <span class="tok-comment">// 4194304</span>
</span>
<span class="line" id="L367">                .{ .delta = <span class="tok-number">7</span>, .cutoff = <span class="tok-str">&quot;11920928955078125&quot;</span> }, <span class="tok-comment">// 8388608</span>
</span>
<span class="line" id="L368">                .{ .delta = <span class="tok-number">8</span>, .cutoff = <span class="tok-str">&quot;59604644775390625&quot;</span> }, <span class="tok-comment">// 16777216</span>
</span>
<span class="line" id="L369">                .{ .delta = <span class="tok-number">8</span>, .cutoff = <span class="tok-str">&quot;298023223876953125&quot;</span> }, <span class="tok-comment">// 33554432</span>
</span>
<span class="line" id="L370">                .{ .delta = <span class="tok-number">8</span>, .cutoff = <span class="tok-str">&quot;1490116119384765625&quot;</span> }, <span class="tok-comment">// 67108864</span>
</span>
<span class="line" id="L371">                .{ .delta = <span class="tok-number">9</span>, .cutoff = <span class="tok-str">&quot;7450580596923828125&quot;</span> }, <span class="tok-comment">// 134217728</span>
</span>
<span class="line" id="L372">                .{ .delta = <span class="tok-number">9</span>, .cutoff = <span class="tok-str">&quot;37252902984619140625&quot;</span> }, <span class="tok-comment">// 268435456</span>
</span>
<span class="line" id="L373">                .{ .delta = <span class="tok-number">9</span>, .cutoff = <span class="tok-str">&quot;186264514923095703125&quot;</span> }, <span class="tok-comment">// 536870912</span>
</span>
<span class="line" id="L374">                .{ .delta = <span class="tok-number">10</span>, .cutoff = <span class="tok-str">&quot;931322574615478515625&quot;</span> }, <span class="tok-comment">// 1073741824</span>
</span>
<span class="line" id="L375">                .{ .delta = <span class="tok-number">10</span>, .cutoff = <span class="tok-str">&quot;4656612873077392578125&quot;</span> }, <span class="tok-comment">// 2147483648</span>
</span>
<span class="line" id="L376">                .{ .delta = <span class="tok-number">10</span>, .cutoff = <span class="tok-str">&quot;23283064365386962890625&quot;</span> }, <span class="tok-comment">// 4294967296</span>
</span>
<span class="line" id="L377">                .{ .delta = <span class="tok-number">10</span>, .cutoff = <span class="tok-str">&quot;116415321826934814453125&quot;</span> }, <span class="tok-comment">// 8589934592</span>
</span>
<span class="line" id="L378">                .{ .delta = <span class="tok-number">11</span>, .cutoff = <span class="tok-str">&quot;582076609134674072265625&quot;</span> }, <span class="tok-comment">// 17179869184</span>
</span>
<span class="line" id="L379">                .{ .delta = <span class="tok-number">11</span>, .cutoff = <span class="tok-str">&quot;2910383045673370361328125&quot;</span> }, <span class="tok-comment">// 34359738368</span>
</span>
<span class="line" id="L380">                .{ .delta = <span class="tok-number">11</span>, .cutoff = <span class="tok-str">&quot;14551915228366851806640625&quot;</span> }, <span class="tok-comment">// 68719476736</span>
</span>
<span class="line" id="L381">                .{ .delta = <span class="tok-number">12</span>, .cutoff = <span class="tok-str">&quot;72759576141834259033203125&quot;</span> }, <span class="tok-comment">// 137438953472</span>
</span>
<span class="line" id="L382">                .{ .delta = <span class="tok-number">12</span>, .cutoff = <span class="tok-str">&quot;363797880709171295166015625&quot;</span> }, <span class="tok-comment">// 274877906944</span>
</span>
<span class="line" id="L383">                .{ .delta = <span class="tok-number">12</span>, .cutoff = <span class="tok-str">&quot;1818989403545856475830078125&quot;</span> }, <span class="tok-comment">// 549755813888</span>
</span>
<span class="line" id="L384">                .{ .delta = <span class="tok-number">13</span>, .cutoff = <span class="tok-str">&quot;9094947017729282379150390625&quot;</span> }, <span class="tok-comment">// 1099511627776</span>
</span>
<span class="line" id="L385">                .{ .delta = <span class="tok-number">13</span>, .cutoff = <span class="tok-str">&quot;45474735088646411895751953125&quot;</span> }, <span class="tok-comment">// 2199023255552</span>
</span>
<span class="line" id="L386">                .{ .delta = <span class="tok-number">13</span>, .cutoff = <span class="tok-str">&quot;227373675443232059478759765625&quot;</span> }, <span class="tok-comment">// 4398046511104</span>
</span>
<span class="line" id="L387">                .{ .delta = <span class="tok-number">13</span>, .cutoff = <span class="tok-str">&quot;1136868377216160297393798828125&quot;</span> }, <span class="tok-comment">// 8796093022208</span>
</span>
<span class="line" id="L388">                .{ .delta = <span class="tok-number">14</span>, .cutoff = <span class="tok-str">&quot;5684341886080801486968994140625&quot;</span> }, <span class="tok-comment">// 17592186044416</span>
</span>
<span class="line" id="L389">                .{ .delta = <span class="tok-number">14</span>, .cutoff = <span class="tok-str">&quot;28421709430404007434844970703125&quot;</span> }, <span class="tok-comment">// 35184372088832</span>
</span>
<span class="line" id="L390">                .{ .delta = <span class="tok-number">14</span>, .cutoff = <span class="tok-str">&quot;142108547152020037174224853515625&quot;</span> }, <span class="tok-comment">// 70368744177664</span>
</span>
<span class="line" id="L391">                .{ .delta = <span class="tok-number">15</span>, .cutoff = <span class="tok-str">&quot;710542735760100185871124267578125&quot;</span> }, <span class="tok-comment">// 140737488355328</span>
</span>
<span class="line" id="L392">                .{ .delta = <span class="tok-number">15</span>, .cutoff = <span class="tok-str">&quot;3552713678800500929355621337890625&quot;</span> }, <span class="tok-comment">// 281474976710656</span>
</span>
<span class="line" id="L393">                .{ .delta = <span class="tok-number">15</span>, .cutoff = <span class="tok-str">&quot;17763568394002504646778106689453125&quot;</span> }, <span class="tok-comment">// 562949953421312</span>
</span>
<span class="line" id="L394">                .{ .delta = <span class="tok-number">16</span>, .cutoff = <span class="tok-str">&quot;88817841970012523233890533447265625&quot;</span> }, <span class="tok-comment">// 1125899906842624</span>
</span>
<span class="line" id="L395">                .{ .delta = <span class="tok-number">16</span>, .cutoff = <span class="tok-str">&quot;444089209850062616169452667236328125&quot;</span> }, <span class="tok-comment">// 2251799813685248</span>
</span>
<span class="line" id="L396">                .{ .delta = <span class="tok-number">16</span>, .cutoff = <span class="tok-str">&quot;2220446049250313080847263336181640625&quot;</span> }, <span class="tok-comment">// 4503599627370496</span>
</span>
<span class="line" id="L397">                .{ .delta = <span class="tok-number">16</span>, .cutoff = <span class="tok-str">&quot;11102230246251565404236316680908203125&quot;</span> }, <span class="tok-comment">// 9007199254740992</span>
</span>
<span class="line" id="L398">                .{ .delta = <span class="tok-number">17</span>, .cutoff = <span class="tok-str">&quot;55511151231257827021181583404541015625&quot;</span> }, <span class="tok-comment">// 18014398509481984</span>
</span>
<span class="line" id="L399">                .{ .delta = <span class="tok-number">17</span>, .cutoff = <span class="tok-str">&quot;277555756156289135105907917022705078125&quot;</span> }, <span class="tok-comment">// 36028797018963968</span>
</span>
<span class="line" id="L400">                .{ .delta = <span class="tok-number">17</span>, .cutoff = <span class="tok-str">&quot;1387778780781445675529539585113525390625&quot;</span> }, <span class="tok-comment">// 72057594037927936</span>
</span>
<span class="line" id="L401">                .{ .delta = <span class="tok-number">18</span>, .cutoff = <span class="tok-str">&quot;6938893903907228377647697925567626953125&quot;</span> }, <span class="tok-comment">// 144115188075855872</span>
</span>
<span class="line" id="L402">                .{ .delta = <span class="tok-number">18</span>, .cutoff = <span class="tok-str">&quot;34694469519536141888238489627838134765625&quot;</span> }, <span class="tok-comment">// 288230376151711744</span>
</span>
<span class="line" id="L403">                .{ .delta = <span class="tok-number">18</span>, .cutoff = <span class="tok-str">&quot;173472347597680709441192448139190673828125&quot;</span> }, <span class="tok-comment">// 576460752303423488</span>
</span>
<span class="line" id="L404">                .{ .delta = <span class="tok-number">19</span>, .cutoff = <span class="tok-str">&quot;867361737988403547205962240695953369140625&quot;</span> }, <span class="tok-comment">// 1152921504606846976</span>
</span>
<span class="line" id="L405">                .{ .delta = <span class="tok-number">19</span>, .cutoff = <span class="tok-str">&quot;4336808689942017736029811203479766845703125&quot;</span> }, <span class="tok-comment">// 2305843009213693952</span>
</span>
<span class="line" id="L406">                .{ .delta = <span class="tok-number">19</span>, .cutoff = <span class="tok-str">&quot;21684043449710088680149056017398834228515625&quot;</span> }, <span class="tok-comment">// 4611686018427387904</span>
</span>
<span class="line" id="L407">                .{ .delta = <span class="tok-number">19</span>, .cutoff = <span class="tok-str">&quot;108420217248550443400745280086994171142578125&quot;</span> }, <span class="tok-comment">// 9223372036854775808</span>
</span>
<span class="line" id="L408">                .{ .delta = <span class="tok-number">20</span>, .cutoff = <span class="tok-str">&quot;542101086242752217003726400434970855712890625&quot;</span> }, <span class="tok-comment">// 18446744073709551616</span>
</span>
<span class="line" id="L409">                .{ .delta = <span class="tok-number">20</span>, .cutoff = <span class="tok-str">&quot;2710505431213761085018632002174854278564453125&quot;</span> }, <span class="tok-comment">// 36893488147419103232</span>
</span>
<span class="line" id="L410">                .{ .delta = <span class="tok-number">20</span>, .cutoff = <span class="tok-str">&quot;13552527156068805425093160010874271392822265625&quot;</span> }, <span class="tok-comment">// 73786976294838206464</span>
</span>
<span class="line" id="L411">                .{ .delta = <span class="tok-number">21</span>, .cutoff = <span class="tok-str">&quot;67762635780344027125465800054371356964111328125&quot;</span> }, <span class="tok-comment">// 147573952589676412928</span>
</span>
<span class="line" id="L412">                .{ .delta = <span class="tok-number">21</span>, .cutoff = <span class="tok-str">&quot;338813178901720135627329000271856784820556640625&quot;</span> }, <span class="tok-comment">// 295147905179352825856</span>
</span>
<span class="line" id="L413">                .{ .delta = <span class="tok-number">21</span>, .cutoff = <span class="tok-str">&quot;1694065894508600678136645001359283924102783203125&quot;</span> }, <span class="tok-comment">// 590295810358705651712</span>
</span>
<span class="line" id="L414">                .{ .delta = <span class="tok-number">22</span>, .cutoff = <span class="tok-str">&quot;8470329472543003390683225006796419620513916015625&quot;</span> }, <span class="tok-comment">// 1180591620717411303424</span>
</span>
<span class="line" id="L415">                .{ .delta = <span class="tok-number">22</span>, .cutoff = <span class="tok-str">&quot;42351647362715016953416125033982098102569580078125&quot;</span> }, <span class="tok-comment">// 2361183241434822606848</span>
</span>
<span class="line" id="L416">                .{ .delta = <span class="tok-number">22</span>, .cutoff = <span class="tok-str">&quot;211758236813575084767080625169910490512847900390625&quot;</span> }, <span class="tok-comment">// 4722366482869645213696</span>
</span>
<span class="line" id="L417">                .{ .delta = <span class="tok-number">22</span>, .cutoff = <span class="tok-str">&quot;1058791184067875423835403125849552452564239501953125&quot;</span> }, <span class="tok-comment">// 9444732965739290427392</span>
</span>
<span class="line" id="L418">                .{ .delta = <span class="tok-number">23</span>, .cutoff = <span class="tok-str">&quot;5293955920339377119177015629247762262821197509765625&quot;</span> }, <span class="tok-comment">// 18889465931478580854784</span>
</span>
<span class="line" id="L419">                .{ .delta = <span class="tok-number">23</span>, .cutoff = <span class="tok-str">&quot;26469779601696885595885078146238811314105987548828125&quot;</span> }, <span class="tok-comment">// 37778931862957161709568</span>
</span>
<span class="line" id="L420">                .{ .delta = <span class="tok-number">23</span>, .cutoff = <span class="tok-str">&quot;132348898008484427979425390731194056570529937744140625&quot;</span> }, <span class="tok-comment">// 75557863725914323419136</span>
</span>
<span class="line" id="L421">                .{ .delta = <span class="tok-number">24</span>, .cutoff = <span class="tok-str">&quot;661744490042422139897126953655970282852649688720703125&quot;</span> }, <span class="tok-comment">// 151115727451828646838272</span>
</span>
<span class="line" id="L422">                .{ .delta = <span class="tok-number">24</span>, .cutoff = <span class="tok-str">&quot;3308722450212110699485634768279851414263248443603515625&quot;</span> }, <span class="tok-comment">// 302231454903657293676544</span>
</span>
<span class="line" id="L423">                .{ .delta = <span class="tok-number">24</span>, .cutoff = <span class="tok-str">&quot;16543612251060553497428173841399257071316242218017578125&quot;</span> }, <span class="tok-comment">// 604462909807314587353088</span>
</span>
<span class="line" id="L424">                .{ .delta = <span class="tok-number">25</span>, .cutoff = <span class="tok-str">&quot;82718061255302767487140869206996285356581211090087890625&quot;</span> }, <span class="tok-comment">// 1208925819614629174706176</span>
</span>
<span class="line" id="L425">                .{ .delta = <span class="tok-number">25</span>, .cutoff = <span class="tok-str">&quot;413590306276513837435704346034981426782906055450439453125&quot;</span> }, <span class="tok-comment">// 2417851639229258349412352</span>
</span>
<span class="line" id="L426">                .{ .delta = <span class="tok-number">25</span>, .cutoff = <span class="tok-str">&quot;2067951531382569187178521730174907133914530277252197265625&quot;</span> }, <span class="tok-comment">// 4835703278458516698824704</span>
</span>
<span class="line" id="L427">                .{ .delta = <span class="tok-number">25</span>, .cutoff = <span class="tok-str">&quot;10339757656912845935892608650874535669572651386260986328125&quot;</span> }, <span class="tok-comment">// 9671406556917033397649408</span>
</span>
<span class="line" id="L428">                .{ .delta = <span class="tok-number">26</span>, .cutoff = <span class="tok-str">&quot;51698788284564229679463043254372678347863256931304931640625&quot;</span> }, <span class="tok-comment">// 19342813113834066795298816</span>
</span>
<span class="line" id="L429">                .{ .delta = <span class="tok-number">26</span>, .cutoff = <span class="tok-str">&quot;258493941422821148397315216271863391739316284656524658203125&quot;</span> }, <span class="tok-comment">// 38685626227668133590597632</span>
</span>
<span class="line" id="L430">                .{ .delta = <span class="tok-number">26</span>, .cutoff = <span class="tok-str">&quot;1292469707114105741986576081359316958696581423282623291015625&quot;</span> }, <span class="tok-comment">// 77371252455336267181195264</span>
</span>
<span class="line" id="L431">                .{ .delta = <span class="tok-number">27</span>, .cutoff = <span class="tok-str">&quot;6462348535570528709932880406796584793482907116413116455078125&quot;</span> }, <span class="tok-comment">// 154742504910672534362390528</span>
</span>
<span class="line" id="L432">                .{ .delta = <span class="tok-number">27</span>, .cutoff = <span class="tok-str">&quot;32311742677852643549664402033982923967414535582065582275390625&quot;</span> }, <span class="tok-comment">// 309485009821345068724781056</span>
</span>
<span class="line" id="L433">                .{ .delta = <span class="tok-number">27</span>, .cutoff = <span class="tok-str">&quot;161558713389263217748322010169914619837072677910327911376953125&quot;</span> }, <span class="tok-comment">// 618970019642690137449562112</span>
</span>
<span class="line" id="L434">                .{ .delta = <span class="tok-number">28</span>, .cutoff = <span class="tok-str">&quot;807793566946316088741610050849573099185363389551639556884765625&quot;</span> }, <span class="tok-comment">// 1237940039285380274899124224</span>
</span>
<span class="line" id="L435">                .{ .delta = <span class="tok-number">28</span>, .cutoff = <span class="tok-str">&quot;4038967834731580443708050254247865495926816947758197784423828125&quot;</span> }, <span class="tok-comment">// 2475880078570760549798248448</span>
</span>
<span class="line" id="L436">                .{ .delta = <span class="tok-number">28</span>, .cutoff = <span class="tok-str">&quot;20194839173657902218540251271239327479634084738790988922119140625&quot;</span> }, <span class="tok-comment">// 4951760157141521099596496896</span>
</span>
<span class="line" id="L437">                .{ .delta = <span class="tok-number">28</span>, .cutoff = <span class="tok-str">&quot;100974195868289511092701256356196637398170423693954944610595703125&quot;</span> }, <span class="tok-comment">// 9903520314283042199192993792</span>
</span>
<span class="line" id="L438">                .{ .delta = <span class="tok-number">29</span>, .cutoff = <span class="tok-str">&quot;504870979341447555463506281780983186990852118469774723052978515625&quot;</span> }, <span class="tok-comment">// 19807040628566084398385987584</span>
</span>
<span class="line" id="L439">                .{ .delta = <span class="tok-number">29</span>, .cutoff = <span class="tok-str">&quot;2524354896707237777317531408904915934954260592348873615264892578125&quot;</span> }, <span class="tok-comment">// 39614081257132168796771975168</span>
</span>
<span class="line" id="L440">                .{ .delta = <span class="tok-number">29</span>, .cutoff = <span class="tok-str">&quot;12621774483536188886587657044524579674771302961744368076324462890625&quot;</span> }, <span class="tok-comment">// 79228162514264337593543950336</span>
</span>
<span class="line" id="L441">                .{ .delta = <span class="tok-number">30</span>, .cutoff = <span class="tok-str">&quot;63108872417680944432938285222622898373856514808721840381622314453125&quot;</span> }, <span class="tok-comment">// 158456325028528675187087900672</span>
</span>
<span class="line" id="L442">                .{ .delta = <span class="tok-number">30</span>, .cutoff = <span class="tok-str">&quot;315544362088404722164691426113114491869282574043609201908111572265625&quot;</span> }, <span class="tok-comment">// 316912650057057350374175801344</span>
</span>
<span class="line" id="L443">                .{ .delta = <span class="tok-number">30</span>, .cutoff = <span class="tok-str">&quot;1577721810442023610823457130565572459346412870218046009540557861328125&quot;</span> }, <span class="tok-comment">// 633825300114114700748351602688</span>
</span>
<span class="line" id="L444">                .{ .delta = <span class="tok-number">31</span>, .cutoff = <span class="tok-str">&quot;7888609052210118054117285652827862296732064351090230047702789306640625&quot;</span> }, <span class="tok-comment">// 1267650600228229401496703205376</span>
</span>
<span class="line" id="L445">                .{ .delta = <span class="tok-number">31</span>, .cutoff = <span class="tok-str">&quot;39443045261050590270586428264139311483660321755451150238513946533203125&quot;</span> }, <span class="tok-comment">// 2535301200456458802993406410752</span>
</span>
<span class="line" id="L446">                .{ .delta = <span class="tok-number">31</span>, .cutoff = <span class="tok-str">&quot;197215226305252951352932141320696557418301608777255751192569732666015625&quot;</span> }, <span class="tok-comment">// 5070602400912917605986812821504</span>
</span>
<span class="line" id="L447">                .{ .delta = <span class="tok-number">32</span>, .cutoff = <span class="tok-str">&quot;986076131526264756764660706603482787091508043886278755962848663330078125&quot;</span> }, <span class="tok-comment">// 10141204801825835211973625643008</span>
</span>
<span class="line" id="L448">                .{ .delta = <span class="tok-number">32</span>, .cutoff = <span class="tok-str">&quot;4930380657631323783823303533017413935457540219431393779814243316650390625&quot;</span> }, <span class="tok-comment">// 20282409603651670423947251286016</span>
</span>
<span class="line" id="L449">                .{ .delta = <span class="tok-number">32</span>, .cutoff = <span class="tok-str">&quot;24651903288156618919116517665087069677287701097156968899071216583251953125&quot;</span> }, <span class="tok-comment">// 40564819207303340847894502572032</span>
</span>
<span class="line" id="L450">                .{ .delta = <span class="tok-number">32</span>, .cutoff = <span class="tok-str">&quot;123259516440783094595582588325435348386438505485784844495356082916259765625&quot;</span> }, <span class="tok-comment">// 81129638414606681695789005144064</span>
</span>
<span class="line" id="L451">                .{ .delta = <span class="tok-number">33</span>, .cutoff = <span class="tok-str">&quot;616297582203915472977912941627176741932192527428924222476780414581298828125&quot;</span> }, <span class="tok-comment">// 162259276829213363391578010288128</span>
</span>
<span class="line" id="L452">                .{ .delta = <span class="tok-number">33</span>, .cutoff = <span class="tok-str">&quot;3081487911019577364889564708135883709660962637144621112383902072906494140625&quot;</span> }, <span class="tok-comment">// 324518553658426726783156020576256</span>
</span>
<span class="line" id="L453">                .{ .delta = <span class="tok-number">33</span>, .cutoff = <span class="tok-str">&quot;15407439555097886824447823540679418548304813185723105561919510364532470703125&quot;</span> }, <span class="tok-comment">// 649037107316853453566312041152512</span>
</span>
<span class="line" id="L454">                .{ .delta = <span class="tok-number">34</span>, .cutoff = <span class="tok-str">&quot;77037197775489434122239117703397092741524065928615527809597551822662353515625&quot;</span> }, <span class="tok-comment">// 1298074214633706907132624082305024</span>
</span>
<span class="line" id="L455">                .{ .delta = <span class="tok-number">34</span>, .cutoff = <span class="tok-str">&quot;385185988877447170611195588516985463707620329643077639047987759113311767578125&quot;</span> }, <span class="tok-comment">// 2596148429267413814265248164610048</span>
</span>
<span class="line" id="L456">                .{ .delta = <span class="tok-number">34</span>, .cutoff = <span class="tok-str">&quot;1925929944387235853055977942584927318538101648215388195239938795566558837890625&quot;</span> }, <span class="tok-comment">// 5192296858534827628530496329220096</span>
</span>
<span class="line" id="L457">                .{ .delta = <span class="tok-number">35</span>, .cutoff = <span class="tok-str">&quot;9629649721936179265279889712924636592690508241076940976199693977832794189453125&quot;</span> }, <span class="tok-comment">// 10384593717069655257060992658440192</span>
</span>
<span class="line" id="L458">                .{ .delta = <span class="tok-number">35</span>, .cutoff = <span class="tok-str">&quot;48148248609680896326399448564623182963452541205384704880998469889163970947265625&quot;</span> }, <span class="tok-comment">// 20769187434139310514121985316880384</span>
</span>
<span class="line" id="L459">                .{ .delta = <span class="tok-number">35</span>, .cutoff = <span class="tok-str">&quot;240741243048404481631997242823115914817262706026923524404992349445819854736328125&quot;</span> }, <span class="tok-comment">// 41538374868278621028243970633760768</span>
</span>
<span class="line" id="L460">                .{ .delta = <span class="tok-number">35</span>, .cutoff = <span class="tok-str">&quot;1203706215242022408159986214115579574086313530134617622024961747229099273681640625&quot;</span> }, <span class="tok-comment">// 83076749736557242056487941267521536</span>
</span>
<span class="line" id="L461">                .{ .delta = <span class="tok-number">36</span>, .cutoff = <span class="tok-str">&quot;6018531076210112040799931070577897870431567650673088110124808736145496368408203125&quot;</span> }, <span class="tok-comment">// 166153499473114484112975882535043072</span>
</span>
<span class="line" id="L462">                .{ .delta = <span class="tok-number">36</span>, .cutoff = <span class="tok-str">&quot;30092655381050560203999655352889489352157838253365440550624043680727481842041015625&quot;</span> }, <span class="tok-comment">// 332306998946228968225951765070086144</span>
</span>
<span class="line" id="L463">                .{ .delta = <span class="tok-number">36</span>, .cutoff = <span class="tok-str">&quot;150463276905252801019998276764447446760789191266827202753120218403637409210205078125&quot;</span> }, <span class="tok-comment">// 664613997892457936451903530140172288</span>
</span>
<span class="line" id="L464">                .{ .delta = <span class="tok-number">37</span>, .cutoff = <span class="tok-str">&quot;752316384526264005099991383822237233803945956334136013765601092018187046051025390625&quot;</span> }, <span class="tok-comment">// 1329227995784915872903807060280344576</span>
</span>
<span class="line" id="L465">                .{ .delta = <span class="tok-number">37</span>, .cutoff = <span class="tok-str">&quot;3761581922631320025499956919111186169019729781670680068828005460090935230255126953125&quot;</span> }, <span class="tok-comment">// 2658455991569831745807614120560689152</span>
</span>
<span class="line" id="L466">                .{ .delta = <span class="tok-number">37</span>, .cutoff = <span class="tok-str">&quot;18807909613156600127499784595555930845098648908353400344140027300454676151275634765625&quot;</span> }, <span class="tok-comment">// 5316911983139663491615228241121378304</span>
</span>
<span class="line" id="L467">                .{ .delta = <span class="tok-number">38</span>, .cutoff = <span class="tok-str">&quot;94039548065783000637498922977779654225493244541767001720700136502273380756378173828125&quot;</span> }, <span class="tok-comment">// 10633823966279326983230456482242756608</span>
</span>
<span class="line" id="L468">                .{ .delta = <span class="tok-number">38</span>, .cutoff = <span class="tok-str">&quot;470197740328915003187494614888898271127466222708835008603500682511366903781890869140625&quot;</span> }, <span class="tok-comment">// 21267647932558653966460912964485513216</span>
</span>
<span class="line" id="L469">                .{ .delta = <span class="tok-number">38</span>, .cutoff = <span class="tok-str">&quot;2350988701644575015937473074444491355637331113544175043017503412556834518909454345703125&quot;</span> }, <span class="tok-comment">// 42535295865117307932921825928971026432</span>
</span>
<span class="line" id="L470">                .{ .delta = <span class="tok-number">38</span>, .cutoff = <span class="tok-str">&quot;11754943508222875079687365372222456778186655567720875215087517062784172594547271728515625&quot;</span> }, <span class="tok-comment">// 85070591730234615865843651857942052864</span>
</span>
<span class="line" id="L471">                .{ .delta = <span class="tok-number">39</span>, .cutoff = <span class="tok-str">&quot;58774717541114375398436826861112283890933277838604376075437585313920862972736358642578125&quot;</span> }, <span class="tok-comment">// 170141183460469231731687303715884105728</span>
</span>
<span class="line" id="L472">            };</span>
<span class="line" id="L473"></span>
<span class="line" id="L474">            std.debug.assert(shift &lt; pow2_to_pow5_table.len);</span>
<span class="line" id="L475">            <span class="tok-kw">const</span> x = pow2_to_pow5_table[shift];</span>
<span class="line" id="L476"></span>
<span class="line" id="L477">            <span class="tok-comment">// Compare leading digits of current to check if lexicographically less than cutoff.</span>
</span>
<span class="line" id="L478">            <span class="tok-kw">for</span> (x.cutoff) |p5, i| {</span>
<span class="line" id="L479">                <span class="tok-kw">if</span> (i &gt;= self.num_digits) {</span>
<span class="line" id="L480">                    <span class="tok-kw">return</span> x.delta - <span class="tok-number">1</span>;</span>
<span class="line" id="L481">                } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (self.digits[i] == p5 - <span class="tok-str">'0'</span>) { <span class="tok-comment">// digits are stored as integers</span>
</span>
<span class="line" id="L482">                    <span class="tok-kw">continue</span>;</span>
<span class="line" id="L483">                } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (self.digits[i] &lt; p5 - <span class="tok-str">'0'</span>) {</span>
<span class="line" id="L484">                    <span class="tok-kw">return</span> x.delta - <span class="tok-number">1</span>;</span>
<span class="line" id="L485">                } <span class="tok-kw">else</span> {</span>
<span class="line" id="L486">                    <span class="tok-kw">return</span> x.delta;</span>
<span class="line" id="L487">                }</span>
<span class="line" id="L488">                <span class="tok-kw">return</span> x.delta;</span>
<span class="line" id="L489">            }</span>
<span class="line" id="L490">            <span class="tok-kw">return</span> x.delta;</span>
<span class="line" id="L491">        }</span>
<span class="line" id="L492">    };</span>
<span class="line" id="L493">}</span>
<span class="line" id="L494"></span>
</code></pre></body>
</html>