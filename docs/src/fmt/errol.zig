<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">    <title>fmt/errol.zig - source view</title>
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
<pre><code><span class="line" id="L1"><span class="tok-kw">const</span> std = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;../std.zig&quot;</span>);</span>
<span class="line" id="L2"><span class="tok-kw">const</span> enum3 = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;errol/enum3.zig&quot;</span>).enum3;</span>
<span class="line" id="L3"><span class="tok-kw">const</span> enum3_data = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;errol/enum3.zig&quot;</span>).enum3_data;</span>
<span class="line" id="L4"><span class="tok-kw">const</span> lookup_table = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;errol/lookup.zig&quot;</span>).lookup_table;</span>
<span class="line" id="L5"><span class="tok-kw">const</span> HP = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;errol/lookup.zig&quot;</span>).HP;</span>
<span class="line" id="L6"><span class="tok-kw">const</span> math = std.math;</span>
<span class="line" id="L7"><span class="tok-kw">const</span> mem = std.mem;</span>
<span class="line" id="L8"><span class="tok-kw">const</span> assert = std.debug.assert;</span>
<span class="line" id="L9"></span>
<span class="line" id="L10"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FloatDecimal = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L11">    digits: []<span class="tok-type">u8</span>,</span>
<span class="line" id="L12">    exp: <span class="tok-type">i32</span>,</span>
<span class="line" id="L13">};</span>
<span class="line" id="L14"></span>
<span class="line" id="L15"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> RoundMode = <span class="tok-kw">enum</span> {</span>
<span class="line" id="L16">    <span class="tok-comment">// Round only the fractional portion (e.g. 1234.23 has precision 2)</span>
</span>
<span class="line" id="L17">    Decimal,</span>
<span class="line" id="L18">    <span class="tok-comment">// Round the entire whole/fractional portion (e.g. 1.23423e3 has precision 5)</span>
</span>
<span class="line" id="L19">    Scientific,</span>
<span class="line" id="L20">};</span>
<span class="line" id="L21"></span>
<span class="line" id="L22"><span class="tok-comment">/// Round a FloatDecimal as returned by errol3 to the specified fractional precision.</span></span>
<span class="line" id="L23"><span class="tok-comment">/// All digits after the specified precision should be considered invalid.</span></span>
<span class="line" id="L24"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">roundToPrecision</span>(float_decimal: *FloatDecimal, precision: <span class="tok-type">usize</span>, mode: RoundMode) <span class="tok-type">void</span> {</span>
<span class="line" id="L25">    <span class="tok-comment">// The round digit refers to the index which we should look at to determine</span>
</span>
<span class="line" id="L26">    <span class="tok-comment">// whether we need to round to match the specified precision.</span>
</span>
<span class="line" id="L27">    <span class="tok-kw">var</span> round_digit: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L28"></span>
<span class="line" id="L29">    <span class="tok-kw">switch</span> (mode) {</span>
<span class="line" id="L30">        RoundMode.Decimal =&gt; {</span>
<span class="line" id="L31">            <span class="tok-kw">if</span> (float_decimal.exp &gt;= <span class="tok-number">0</span>) {</span>
<span class="line" id="L32">                round_digit = precision + <span class="tok-builtin">@intCast</span>(<span class="tok-type">usize</span>, float_decimal.exp);</span>
<span class="line" id="L33">            } <span class="tok-kw">else</span> {</span>
<span class="line" id="L34">                <span class="tok-comment">// if a small negative exp, then adjust we need to offset by the number</span>
</span>
<span class="line" id="L35">                <span class="tok-comment">// of leading zeros that will occur.</span>
</span>
<span class="line" id="L36">                <span class="tok-kw">const</span> min_exp_required = <span class="tok-builtin">@intCast</span>(<span class="tok-type">usize</span>, -float_decimal.exp);</span>
<span class="line" id="L37">                <span class="tok-kw">if</span> (precision &gt; min_exp_required) {</span>
<span class="line" id="L38">                    round_digit = precision - min_exp_required;</span>
<span class="line" id="L39">                }</span>
<span class="line" id="L40">            }</span>
<span class="line" id="L41">        },</span>
<span class="line" id="L42">        RoundMode.Scientific =&gt; {</span>
<span class="line" id="L43">            round_digit = <span class="tok-number">1</span> + precision;</span>
<span class="line" id="L44">        },</span>
<span class="line" id="L45">    }</span>
<span class="line" id="L46"></span>
<span class="line" id="L47">    <span class="tok-comment">// It suffices to look at just this digit. We don't round and propagate say 0.04999 to 0.05</span>
</span>
<span class="line" id="L48">    <span class="tok-comment">// first, and then to 0.1 in the case of a {.1} single precision.</span>
</span>
<span class="line" id="L49"></span>
<span class="line" id="L50">    <span class="tok-comment">// Find the digit which will signify the round point and start rounding backwards.</span>
</span>
<span class="line" id="L51">    <span class="tok-kw">if</span> (round_digit &lt; float_decimal.digits.len <span class="tok-kw">and</span> float_decimal.digits[round_digit] - <span class="tok-str">'0'</span> &gt;= <span class="tok-number">5</span>) {</span>
<span class="line" id="L52">        assert(round_digit &gt;= <span class="tok-number">0</span>);</span>
<span class="line" id="L53"></span>
<span class="line" id="L54">        <span class="tok-kw">var</span> i = round_digit;</span>
<span class="line" id="L55">        <span class="tok-kw">while</span> (<span class="tok-null">true</span>) {</span>
<span class="line" id="L56">            <span class="tok-kw">if</span> (i == <span class="tok-number">0</span>) {</span>
<span class="line" id="L57">                <span class="tok-comment">// Rounded all the way past the start. This was of the form 9.999...</span>
</span>
<span class="line" id="L58">                <span class="tok-comment">// Slot the new digit in place and increase the exponent.</span>
</span>
<span class="line" id="L59">                float_decimal.exp += <span class="tok-number">1</span>;</span>
<span class="line" id="L60"></span>
<span class="line" id="L61">                <span class="tok-comment">// Re-size the buffer to use the reserved leading byte.</span>
</span>
<span class="line" id="L62">                <span class="tok-kw">const</span> one_before = <span class="tok-builtin">@intToPtr</span>([*]<span class="tok-type">u8</span>, <span class="tok-builtin">@ptrToInt</span>(&amp;float_decimal.digits[<span class="tok-number">0</span>]) - <span class="tok-number">1</span>);</span>
<span class="line" id="L63">                float_decimal.digits = one_before[<span class="tok-number">0</span> .. float_decimal.digits.len + <span class="tok-number">1</span>];</span>
<span class="line" id="L64">                float_decimal.digits[<span class="tok-number">0</span>] = <span class="tok-str">'1'</span>;</span>
<span class="line" id="L65">                <span class="tok-kw">return</span>;</span>
<span class="line" id="L66">            }</span>
<span class="line" id="L67"></span>
<span class="line" id="L68">            i -= <span class="tok-number">1</span>;</span>
<span class="line" id="L69"></span>
<span class="line" id="L70">            <span class="tok-kw">const</span> new_value = (float_decimal.digits[i] - <span class="tok-str">'0'</span> + <span class="tok-number">1</span>) % <span class="tok-number">10</span>;</span>
<span class="line" id="L71">            float_decimal.digits[i] = new_value + <span class="tok-str">'0'</span>;</span>
<span class="line" id="L72"></span>
<span class="line" id="L73">            <span class="tok-comment">// must continue rounding until non-9</span>
</span>
<span class="line" id="L74">            <span class="tok-kw">if</span> (new_value != <span class="tok-number">0</span>) {</span>
<span class="line" id="L75">                <span class="tok-kw">return</span>;</span>
<span class="line" id="L76">            }</span>
<span class="line" id="L77">        }</span>
<span class="line" id="L78">    }</span>
<span class="line" id="L79">}</span>
<span class="line" id="L80"></span>
<span class="line" id="L81"><span class="tok-comment">/// Corrected Errol3 double to ASCII conversion.</span></span>
<span class="line" id="L82"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">errol3</span>(value: <span class="tok-type">f64</span>, buffer: []<span class="tok-type">u8</span>) FloatDecimal {</span>
<span class="line" id="L83">    <span class="tok-kw">const</span> bits = <span class="tok-builtin">@bitCast</span>(<span class="tok-type">u64</span>, value);</span>
<span class="line" id="L84">    <span class="tok-kw">const</span> i = tableLowerBound(bits);</span>
<span class="line" id="L85">    <span class="tok-kw">if</span> (i &lt; enum3.len <span class="tok-kw">and</span> enum3[i] == bits) {</span>
<span class="line" id="L86">        <span class="tok-kw">const</span> data = enum3_data[i];</span>
<span class="line" id="L87">        <span class="tok-kw">const</span> digits = buffer[<span class="tok-number">1</span> .. data.str.len + <span class="tok-number">1</span>];</span>
<span class="line" id="L88">        mem.copy(<span class="tok-type">u8</span>, digits, data.str);</span>
<span class="line" id="L89">        <span class="tok-kw">return</span> FloatDecimal{</span>
<span class="line" id="L90">            .digits = digits,</span>
<span class="line" id="L91">            .exp = data.exp,</span>
<span class="line" id="L92">        };</span>
<span class="line" id="L93">    }</span>
<span class="line" id="L94"></span>
<span class="line" id="L95">    <span class="tok-comment">// We generate digits starting at index 1. If rounding a buffer later then it may be</span>
</span>
<span class="line" id="L96">    <span class="tok-comment">// required to generate a preceding digit in some cases (9.999) in which case we use</span>
</span>
<span class="line" id="L97">    <span class="tok-comment">// the 0-index for this extra digit.</span>
</span>
<span class="line" id="L98">    <span class="tok-kw">return</span> errol3u(value, buffer[<span class="tok-number">1</span>..]);</span>
<span class="line" id="L99">}</span>
<span class="line" id="L100"></span>
<span class="line" id="L101"><span class="tok-comment">/// Uncorrected Errol3 double to ASCII conversion.</span></span>
<span class="line" id="L102"><span class="tok-kw">fn</span> <span class="tok-fn">errol3u</span>(val: <span class="tok-type">f64</span>, buffer: []<span class="tok-type">u8</span>) FloatDecimal {</span>
<span class="line" id="L103">    <span class="tok-comment">// check if in integer or fixed range</span>
</span>
<span class="line" id="L104">    <span class="tok-kw">if</span> (val &gt; <span class="tok-number">9.007199254740992e15</span> <span class="tok-kw">and</span> val &lt; <span class="tok-number">3.40282366920938e+38</span>) {</span>
<span class="line" id="L105">        <span class="tok-kw">return</span> errolInt(val, buffer);</span>
<span class="line" id="L106">    } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (val &gt;= <span class="tok-number">16.0</span> <span class="tok-kw">and</span> val &lt; <span class="tok-number">9.007199254740992e15</span>) {</span>
<span class="line" id="L107">        <span class="tok-kw">return</span> errolFixed(val, buffer);</span>
<span class="line" id="L108">    }</span>
<span class="line" id="L109">    <span class="tok-kw">return</span> errolSlow(val, buffer);</span>
<span class="line" id="L110">}</span>
<span class="line" id="L111"></span>
<span class="line" id="L112"><span class="tok-kw">fn</span> <span class="tok-fn">errolSlow</span>(val: <span class="tok-type">f64</span>, buffer: []<span class="tok-type">u8</span>) FloatDecimal {</span>
<span class="line" id="L113">    <span class="tok-comment">// normalize the midpoint</span>
</span>
<span class="line" id="L114"></span>
<span class="line" id="L115">    <span class="tok-kw">const</span> e = math.frexp(val).exponent;</span>
<span class="line" id="L116">    <span class="tok-kw">var</span> exp = <span class="tok-builtin">@floatToInt</span>(<span class="tok-type">i16</span>, <span class="tok-builtin">@floor</span>(<span class="tok-number">307</span> + <span class="tok-builtin">@intToFloat</span>(<span class="tok-type">f64</span>, e) * <span class="tok-number">0.30103</span>));</span>
<span class="line" id="L117">    <span class="tok-kw">if</span> (exp &lt; <span class="tok-number">20</span>) {</span>
<span class="line" id="L118">        exp = <span class="tok-number">20</span>;</span>
<span class="line" id="L119">    } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (<span class="tok-builtin">@intCast</span>(<span class="tok-type">usize</span>, exp) &gt;= lookup_table.len) {</span>
<span class="line" id="L120">        exp = <span class="tok-builtin">@intCast</span>(<span class="tok-type">i16</span>, lookup_table.len - <span class="tok-number">1</span>);</span>
<span class="line" id="L121">    }</span>
<span class="line" id="L122"></span>
<span class="line" id="L123">    <span class="tok-kw">var</span> mid = lookup_table[<span class="tok-builtin">@intCast</span>(<span class="tok-type">usize</span>, exp)];</span>
<span class="line" id="L124">    mid = hpProd(mid, val);</span>
<span class="line" id="L125">    <span class="tok-kw">const</span> lten = lookup_table[<span class="tok-builtin">@intCast</span>(<span class="tok-type">usize</span>, exp)].val;</span>
<span class="line" id="L126"></span>
<span class="line" id="L127">    exp -= <span class="tok-number">307</span>;</span>
<span class="line" id="L128"></span>
<span class="line" id="L129">    <span class="tok-kw">var</span> ten: <span class="tok-type">f64</span> = <span class="tok-number">1.0</span>;</span>
<span class="line" id="L130"></span>
<span class="line" id="L131">    <span class="tok-kw">while</span> (mid.val &gt; <span class="tok-number">10.0</span> <span class="tok-kw">or</span> (mid.val == <span class="tok-number">10.0</span> <span class="tok-kw">and</span> mid.off &gt;= <span class="tok-number">0.0</span>)) {</span>
<span class="line" id="L132">        exp += <span class="tok-number">1</span>;</span>
<span class="line" id="L133">        hpDiv10(&amp;mid);</span>
<span class="line" id="L134">        ten /= <span class="tok-number">10.0</span>;</span>
<span class="line" id="L135">    }</span>
<span class="line" id="L136"></span>
<span class="line" id="L137">    <span class="tok-kw">while</span> (mid.val &lt; <span class="tok-number">1.0</span> <span class="tok-kw">or</span> (mid.val == <span class="tok-number">1.0</span> <span class="tok-kw">and</span> mid.off &lt; <span class="tok-number">0.0</span>)) {</span>
<span class="line" id="L138">        exp -= <span class="tok-number">1</span>;</span>
<span class="line" id="L139">        hpMul10(&amp;mid);</span>
<span class="line" id="L140">        ten *= <span class="tok-number">10.0</span>;</span>
<span class="line" id="L141">    }</span>
<span class="line" id="L142"></span>
<span class="line" id="L143">    <span class="tok-comment">// compute boundaries</span>
</span>
<span class="line" id="L144">    <span class="tok-kw">var</span> high = HP{</span>
<span class="line" id="L145">        .val = mid.val,</span>
<span class="line" id="L146">        .off = mid.off + (fpnext(val) - val) * lten * ten / <span class="tok-number">2.0</span>,</span>
<span class="line" id="L147">    };</span>
<span class="line" id="L148">    <span class="tok-kw">var</span> low = HP{</span>
<span class="line" id="L149">        .val = mid.val,</span>
<span class="line" id="L150">        .off = mid.off + (fpprev(val) - val) * lten * ten / <span class="tok-number">2.0</span>,</span>
<span class="line" id="L151">    };</span>
<span class="line" id="L152"></span>
<span class="line" id="L153">    hpNormalize(&amp;high);</span>
<span class="line" id="L154">    hpNormalize(&amp;low);</span>
<span class="line" id="L155"></span>
<span class="line" id="L156">    <span class="tok-comment">// normalized boundaries</span>
</span>
<span class="line" id="L157"></span>
<span class="line" id="L158">    <span class="tok-kw">while</span> (high.val &gt; <span class="tok-number">10.0</span> <span class="tok-kw">or</span> (high.val == <span class="tok-number">10.0</span> <span class="tok-kw">and</span> high.off &gt;= <span class="tok-number">0.0</span>)) {</span>
<span class="line" id="L159">        exp += <span class="tok-number">1</span>;</span>
<span class="line" id="L160">        hpDiv10(&amp;high);</span>
<span class="line" id="L161">        hpDiv10(&amp;low);</span>
<span class="line" id="L162">    }</span>
<span class="line" id="L163"></span>
<span class="line" id="L164">    <span class="tok-kw">while</span> (high.val &lt; <span class="tok-number">1.0</span> <span class="tok-kw">or</span> (high.val == <span class="tok-number">1.0</span> <span class="tok-kw">and</span> high.off &lt; <span class="tok-number">0.0</span>)) {</span>
<span class="line" id="L165">        exp -= <span class="tok-number">1</span>;</span>
<span class="line" id="L166">        hpMul10(&amp;high);</span>
<span class="line" id="L167">        hpMul10(&amp;low);</span>
<span class="line" id="L168">    }</span>
<span class="line" id="L169"></span>
<span class="line" id="L170">    <span class="tok-comment">// digit generation</span>
</span>
<span class="line" id="L171">    <span class="tok-kw">var</span> buf_index: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L172">    <span class="tok-kw">while</span> (<span class="tok-null">true</span>) {</span>
<span class="line" id="L173">        <span class="tok-kw">var</span> hdig = <span class="tok-builtin">@floatToInt</span>(<span class="tok-type">u8</span>, <span class="tok-builtin">@floor</span>(high.val));</span>
<span class="line" id="L174">        <span class="tok-kw">if</span> ((high.val == <span class="tok-builtin">@intToFloat</span>(<span class="tok-type">f64</span>, hdig)) <span class="tok-kw">and</span> (high.off &lt; <span class="tok-number">0</span>)) hdig -= <span class="tok-number">1</span>;</span>
<span class="line" id="L175"></span>
<span class="line" id="L176">        <span class="tok-kw">var</span> ldig = <span class="tok-builtin">@floatToInt</span>(<span class="tok-type">u8</span>, <span class="tok-builtin">@floor</span>(low.val));</span>
<span class="line" id="L177">        <span class="tok-kw">if</span> ((low.val == <span class="tok-builtin">@intToFloat</span>(<span class="tok-type">f64</span>, ldig)) <span class="tok-kw">and</span> (low.off &lt; <span class="tok-number">0</span>)) ldig -= <span class="tok-number">1</span>;</span>
<span class="line" id="L178"></span>
<span class="line" id="L179">        <span class="tok-kw">if</span> (ldig != hdig) <span class="tok-kw">break</span>;</span>
<span class="line" id="L180"></span>
<span class="line" id="L181">        buffer[buf_index] = hdig + <span class="tok-str">'0'</span>;</span>
<span class="line" id="L182">        buf_index += <span class="tok-number">1</span>;</span>
<span class="line" id="L183">        high.val -= <span class="tok-builtin">@intToFloat</span>(<span class="tok-type">f64</span>, hdig);</span>
<span class="line" id="L184">        low.val -= <span class="tok-builtin">@intToFloat</span>(<span class="tok-type">f64</span>, ldig);</span>
<span class="line" id="L185">        hpMul10(&amp;high);</span>
<span class="line" id="L186">        hpMul10(&amp;low);</span>
<span class="line" id="L187">    }</span>
<span class="line" id="L188"></span>
<span class="line" id="L189">    <span class="tok-kw">const</span> tmp = (high.val + low.val) / <span class="tok-number">2.0</span>;</span>
<span class="line" id="L190">    <span class="tok-kw">var</span> mdig = <span class="tok-builtin">@floatToInt</span>(<span class="tok-type">u8</span>, <span class="tok-builtin">@floor</span>(tmp + <span class="tok-number">0.5</span>));</span>
<span class="line" id="L191">    <span class="tok-kw">if</span> ((<span class="tok-builtin">@intToFloat</span>(<span class="tok-type">f64</span>, mdig) - tmp) == <span class="tok-number">0.5</span> <span class="tok-kw">and</span> (mdig &amp; <span class="tok-number">0x1</span>) != <span class="tok-number">0</span>) mdig -= <span class="tok-number">1</span>;</span>
<span class="line" id="L192"></span>
<span class="line" id="L193">    buffer[buf_index] = mdig + <span class="tok-str">'0'</span>;</span>
<span class="line" id="L194">    buf_index += <span class="tok-number">1</span>;</span>
<span class="line" id="L195"></span>
<span class="line" id="L196">    <span class="tok-kw">return</span> FloatDecimal{</span>
<span class="line" id="L197">        .digits = buffer[<span class="tok-number">0</span>..buf_index],</span>
<span class="line" id="L198">        .exp = exp,</span>
<span class="line" id="L199">    };</span>
<span class="line" id="L200">}</span>
<span class="line" id="L201"></span>
<span class="line" id="L202"><span class="tok-kw">fn</span> <span class="tok-fn">tableLowerBound</span>(k: <span class="tok-type">u64</span>) <span class="tok-type">usize</span> {</span>
<span class="line" id="L203">    <span class="tok-kw">var</span> i = enum3.len;</span>
<span class="line" id="L204">    <span class="tok-kw">var</span> j: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L205"></span>
<span class="line" id="L206">    <span class="tok-kw">while</span> (j &lt; enum3.len) {</span>
<span class="line" id="L207">        <span class="tok-kw">if</span> (enum3[j] &lt; k) {</span>
<span class="line" id="L208">            j = <span class="tok-number">2</span> * j + <span class="tok-number">2</span>;</span>
<span class="line" id="L209">        } <span class="tok-kw">else</span> {</span>
<span class="line" id="L210">            i = j;</span>
<span class="line" id="L211">            j = <span class="tok-number">2</span> * j + <span class="tok-number">1</span>;</span>
<span class="line" id="L212">        }</span>
<span class="line" id="L213">    }</span>
<span class="line" id="L214"></span>
<span class="line" id="L215">    <span class="tok-kw">return</span> i;</span>
<span class="line" id="L216">}</span>
<span class="line" id="L217"></span>
<span class="line" id="L218"><span class="tok-comment">/// Compute the product of an HP number and a double.</span></span>
<span class="line" id="L219"><span class="tok-comment">///   @in: The HP number.</span></span>
<span class="line" id="L220"><span class="tok-comment">///   @val: The double.</span></span>
<span class="line" id="L221"><span class="tok-comment">///   &amp;returns: The HP number.</span></span>
<span class="line" id="L222"><span class="tok-kw">fn</span> <span class="tok-fn">hpProd</span>(in: HP, val: <span class="tok-type">f64</span>) HP {</span>
<span class="line" id="L223">    <span class="tok-kw">var</span> hi: <span class="tok-type">f64</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L224">    <span class="tok-kw">var</span> lo: <span class="tok-type">f64</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L225">    split(in.val, &amp;hi, &amp;lo);</span>
<span class="line" id="L226"></span>
<span class="line" id="L227">    <span class="tok-kw">var</span> hi2: <span class="tok-type">f64</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L228">    <span class="tok-kw">var</span> lo2: <span class="tok-type">f64</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L229">    split(val, &amp;hi2, &amp;lo2);</span>
<span class="line" id="L230"></span>
<span class="line" id="L231">    <span class="tok-kw">const</span> p = in.val * val;</span>
<span class="line" id="L232">    <span class="tok-kw">const</span> e = ((hi * hi2 - p) + lo * hi2 + hi * lo2) + lo * lo2;</span>
<span class="line" id="L233"></span>
<span class="line" id="L234">    <span class="tok-kw">return</span> HP{</span>
<span class="line" id="L235">        .val = p,</span>
<span class="line" id="L236">        .off = in.off * val + e,</span>
<span class="line" id="L237">    };</span>
<span class="line" id="L238">}</span>
<span class="line" id="L239"></span>
<span class="line" id="L240"><span class="tok-comment">/// Split a double into two halves.</span></span>
<span class="line" id="L241"><span class="tok-comment">///   @val: The double.</span></span>
<span class="line" id="L242"><span class="tok-comment">///   @hi: The high bits.</span></span>
<span class="line" id="L243"><span class="tok-comment">///   @lo: The low bits.</span></span>
<span class="line" id="L244"><span class="tok-kw">fn</span> <span class="tok-fn">split</span>(val: <span class="tok-type">f64</span>, hi: *<span class="tok-type">f64</span>, lo: *<span class="tok-type">f64</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L245">    hi.* = gethi(val);</span>
<span class="line" id="L246">    lo.* = val - hi.*;</span>
<span class="line" id="L247">}</span>
<span class="line" id="L248"></span>
<span class="line" id="L249"><span class="tok-kw">fn</span> <span class="tok-fn">gethi</span>(in: <span class="tok-type">f64</span>) <span class="tok-type">f64</span> {</span>
<span class="line" id="L250">    <span class="tok-kw">const</span> bits = <span class="tok-builtin">@bitCast</span>(<span class="tok-type">u64</span>, in);</span>
<span class="line" id="L251">    <span class="tok-kw">const</span> new_bits = bits &amp; <span class="tok-number">0xFFFFFFFFF8000000</span>;</span>
<span class="line" id="L252">    <span class="tok-kw">return</span> <span class="tok-builtin">@bitCast</span>(<span class="tok-type">f64</span>, new_bits);</span>
<span class="line" id="L253">}</span>
<span class="line" id="L254"></span>
<span class="line" id="L255"><span class="tok-comment">/// Normalize the number by factoring in the error.</span></span>
<span class="line" id="L256"><span class="tok-comment">///   @hp: The float pair.</span></span>
<span class="line" id="L257"><span class="tok-kw">fn</span> <span class="tok-fn">hpNormalize</span>(hp: *HP) <span class="tok-type">void</span> {</span>
<span class="line" id="L258">    <span class="tok-kw">const</span> val = hp.val;</span>
<span class="line" id="L259">    hp.val += hp.off;</span>
<span class="line" id="L260">    hp.off += val - hp.val;</span>
<span class="line" id="L261">}</span>
<span class="line" id="L262"></span>
<span class="line" id="L263"><span class="tok-comment">/// Divide the high-precision number by ten.</span></span>
<span class="line" id="L264"><span class="tok-comment">///   @hp: The high-precision number</span></span>
<span class="line" id="L265"><span class="tok-kw">fn</span> <span class="tok-fn">hpDiv10</span>(hp: *HP) <span class="tok-type">void</span> {</span>
<span class="line" id="L266">    <span class="tok-kw">var</span> val = hp.val;</span>
<span class="line" id="L267"></span>
<span class="line" id="L268">    hp.val /= <span class="tok-number">10.0</span>;</span>
<span class="line" id="L269">    hp.off /= <span class="tok-number">10.0</span>;</span>
<span class="line" id="L270"></span>
<span class="line" id="L271">    val -= hp.val * <span class="tok-number">8.0</span>;</span>
<span class="line" id="L272">    val -= hp.val * <span class="tok-number">2.0</span>;</span>
<span class="line" id="L273"></span>
<span class="line" id="L274">    hp.off += val / <span class="tok-number">10.0</span>;</span>
<span class="line" id="L275"></span>
<span class="line" id="L276">    hpNormalize(hp);</span>
<span class="line" id="L277">}</span>
<span class="line" id="L278"></span>
<span class="line" id="L279"><span class="tok-comment">/// Multiply the high-precision number by ten.</span></span>
<span class="line" id="L280"><span class="tok-comment">///   @hp: The high-precision number</span></span>
<span class="line" id="L281"><span class="tok-kw">fn</span> <span class="tok-fn">hpMul10</span>(hp: *HP) <span class="tok-type">void</span> {</span>
<span class="line" id="L282">    <span class="tok-kw">const</span> val = hp.val;</span>
<span class="line" id="L283"></span>
<span class="line" id="L284">    hp.val *= <span class="tok-number">10.0</span>;</span>
<span class="line" id="L285">    hp.off *= <span class="tok-number">10.0</span>;</span>
<span class="line" id="L286"></span>
<span class="line" id="L287">    <span class="tok-kw">var</span> off = hp.val;</span>
<span class="line" id="L288">    off -= val * <span class="tok-number">8.0</span>;</span>
<span class="line" id="L289">    off -= val * <span class="tok-number">2.0</span>;</span>
<span class="line" id="L290"></span>
<span class="line" id="L291">    hp.off -= off;</span>
<span class="line" id="L292"></span>
<span class="line" id="L293">    hpNormalize(hp);</span>
<span class="line" id="L294">}</span>
<span class="line" id="L295"></span>
<span class="line" id="L296"><span class="tok-comment">/// Integer conversion algorithm, guaranteed correct, optimal, and best.</span></span>
<span class="line" id="L297"><span class="tok-comment">///  @val: The val.</span></span>
<span class="line" id="L298"><span class="tok-comment">///  @buf: The output buffer.</span></span>
<span class="line" id="L299"><span class="tok-comment">///  &amp;return: The exponent.</span></span>
<span class="line" id="L300"><span class="tok-kw">fn</span> <span class="tok-fn">errolInt</span>(val: <span class="tok-type">f64</span>, buffer: []<span class="tok-type">u8</span>) FloatDecimal {</span>
<span class="line" id="L301">    <span class="tok-kw">const</span> pow19 = <span class="tok-builtin">@as</span>(<span class="tok-type">u128</span>, <span class="tok-number">1e19</span>);</span>
<span class="line" id="L302"></span>
<span class="line" id="L303">    assert((val &gt; <span class="tok-number">9.007199254740992e15</span>) <span class="tok-kw">and</span> val &lt; (<span class="tok-number">3.40282366920938e38</span>));</span>
<span class="line" id="L304"></span>
<span class="line" id="L305">    <span class="tok-kw">var</span> mid = <span class="tok-builtin">@floatToInt</span>(<span class="tok-type">u128</span>, val);</span>
<span class="line" id="L306">    <span class="tok-kw">var</span> low: <span class="tok-type">u128</span> = mid - fpeint((fpnext(val) - val) / <span class="tok-number">2.0</span>);</span>
<span class="line" id="L307">    <span class="tok-kw">var</span> high: <span class="tok-type">u128</span> = mid + fpeint((val - fpprev(val)) / <span class="tok-number">2.0</span>);</span>
<span class="line" id="L308"></span>
<span class="line" id="L309">    <span class="tok-kw">if</span> (<span class="tok-builtin">@bitCast</span>(<span class="tok-type">u64</span>, val) &amp; <span class="tok-number">0x1</span> != <span class="tok-number">0</span>) {</span>
<span class="line" id="L310">        high -= <span class="tok-number">1</span>;</span>
<span class="line" id="L311">    } <span class="tok-kw">else</span> {</span>
<span class="line" id="L312">        low -= <span class="tok-number">1</span>;</span>
<span class="line" id="L313">    }</span>
<span class="line" id="L314"></span>
<span class="line" id="L315">    <span class="tok-kw">var</span> l64 = <span class="tok-builtin">@intCast</span>(<span class="tok-type">u64</span>, low % pow19);</span>
<span class="line" id="L316">    <span class="tok-kw">const</span> lf = <span class="tok-builtin">@intCast</span>(<span class="tok-type">u64</span>, (low / pow19) % pow19);</span>
<span class="line" id="L317"></span>
<span class="line" id="L318">    <span class="tok-kw">var</span> h64 = <span class="tok-builtin">@intCast</span>(<span class="tok-type">u64</span>, high % pow19);</span>
<span class="line" id="L319">    <span class="tok-kw">const</span> hf = <span class="tok-builtin">@intCast</span>(<span class="tok-type">u64</span>, (high / pow19) % pow19);</span>
<span class="line" id="L320"></span>
<span class="line" id="L321">    <span class="tok-kw">if</span> (lf != hf) {</span>
<span class="line" id="L322">        l64 = lf;</span>
<span class="line" id="L323">        h64 = hf;</span>
<span class="line" id="L324">        mid = mid / (pow19 / <span class="tok-number">10</span>);</span>
<span class="line" id="L325">    }</span>
<span class="line" id="L326"></span>
<span class="line" id="L327">    <span class="tok-kw">var</span> mi: <span class="tok-type">i32</span> = mismatch10(l64, h64);</span>
<span class="line" id="L328">    <span class="tok-kw">var</span> x: <span class="tok-type">u64</span> = <span class="tok-number">1</span>;</span>
<span class="line" id="L329">    {</span>
<span class="line" id="L330">        <span class="tok-kw">var</span> i: <span class="tok-type">i32</span> = <span class="tok-builtin">@boolToInt</span>(lf == hf);</span>
<span class="line" id="L331">        <span class="tok-kw">while</span> (i &lt; mi) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L332">            x *= <span class="tok-number">10</span>;</span>
<span class="line" id="L333">        }</span>
<span class="line" id="L334">    }</span>
<span class="line" id="L335">    <span class="tok-kw">const</span> m64 = <span class="tok-builtin">@truncate</span>(<span class="tok-type">u64</span>, <span class="tok-builtin">@divTrunc</span>(mid, x));</span>
<span class="line" id="L336"></span>
<span class="line" id="L337">    <span class="tok-kw">if</span> (lf != hf) mi += <span class="tok-number">19</span>;</span>
<span class="line" id="L338"></span>
<span class="line" id="L339">    <span class="tok-kw">var</span> buf_index = u64toa(m64, buffer) - <span class="tok-number">1</span>;</span>
<span class="line" id="L340"></span>
<span class="line" id="L341">    <span class="tok-kw">if</span> (mi != <span class="tok-number">0</span>) {</span>
<span class="line" id="L342">        <span class="tok-kw">const</span> round_up = buffer[buf_index] &gt;= <span class="tok-str">'5'</span>;</span>
<span class="line" id="L343">        <span class="tok-kw">if</span> (buf_index == <span class="tok-number">0</span> <span class="tok-kw">or</span> (round_up <span class="tok-kw">and</span> buffer[buf_index - <span class="tok-number">1</span>] == <span class="tok-str">'9'</span>)) <span class="tok-kw">return</span> errolSlow(val, buffer);</span>
<span class="line" id="L344">        buffer[buf_index - <span class="tok-number">1</span>] += <span class="tok-builtin">@boolToInt</span>(round_up);</span>
<span class="line" id="L345">    } <span class="tok-kw">else</span> {</span>
<span class="line" id="L346">        buf_index += <span class="tok-number">1</span>;</span>
<span class="line" id="L347">    }</span>
<span class="line" id="L348"></span>
<span class="line" id="L349">    <span class="tok-kw">return</span> FloatDecimal{</span>
<span class="line" id="L350">        .digits = buffer[<span class="tok-number">0</span>..buf_index],</span>
<span class="line" id="L351">        .exp = <span class="tok-builtin">@intCast</span>(<span class="tok-type">i32</span>, buf_index) + mi,</span>
<span class="line" id="L352">    };</span>
<span class="line" id="L353">}</span>
<span class="line" id="L354"></span>
<span class="line" id="L355"><span class="tok-comment">/// Fixed point conversion algorithm, guaranteed correct, optimal, and best.</span></span>
<span class="line" id="L356"><span class="tok-comment">///  @val: The val.</span></span>
<span class="line" id="L357"><span class="tok-comment">///  @buf: The output buffer.</span></span>
<span class="line" id="L358"><span class="tok-comment">///  &amp;return: The exponent.</span></span>
<span class="line" id="L359"><span class="tok-kw">fn</span> <span class="tok-fn">errolFixed</span>(val: <span class="tok-type">f64</span>, buffer: []<span class="tok-type">u8</span>) FloatDecimal {</span>
<span class="line" id="L360">    assert((val &gt;= <span class="tok-number">16.0</span>) <span class="tok-kw">and</span> (val &lt; <span class="tok-number">9.007199254740992e15</span>));</span>
<span class="line" id="L361"></span>
<span class="line" id="L362">    <span class="tok-kw">const</span> u = <span class="tok-builtin">@floatToInt</span>(<span class="tok-type">u64</span>, val);</span>
<span class="line" id="L363">    <span class="tok-kw">const</span> n = <span class="tok-builtin">@intToFloat</span>(<span class="tok-type">f64</span>, u);</span>
<span class="line" id="L364"></span>
<span class="line" id="L365">    <span class="tok-kw">var</span> mid = val - n;</span>
<span class="line" id="L366">    <span class="tok-kw">var</span> lo = ((fpprev(val) - n) + mid) / <span class="tok-number">2.0</span>;</span>
<span class="line" id="L367">    <span class="tok-kw">var</span> hi = ((fpnext(val) - n) + mid) / <span class="tok-number">2.0</span>;</span>
<span class="line" id="L368"></span>
<span class="line" id="L369">    <span class="tok-kw">var</span> buf_index = u64toa(u, buffer);</span>
<span class="line" id="L370">    <span class="tok-kw">var</span> exp = <span class="tok-builtin">@intCast</span>(<span class="tok-type">i32</span>, buf_index);</span>
<span class="line" id="L371">    <span class="tok-kw">var</span> j = buf_index;</span>
<span class="line" id="L372">    buffer[j] = <span class="tok-number">0</span>;</span>
<span class="line" id="L373"></span>
<span class="line" id="L374">    <span class="tok-kw">if</span> (mid != <span class="tok-number">0.0</span>) {</span>
<span class="line" id="L375">        <span class="tok-kw">while</span> (mid != <span class="tok-number">0.0</span>) {</span>
<span class="line" id="L376">            lo *= <span class="tok-number">10.0</span>;</span>
<span class="line" id="L377">            <span class="tok-kw">const</span> ldig = <span class="tok-builtin">@floatToInt</span>(<span class="tok-type">i32</span>, lo);</span>
<span class="line" id="L378">            lo -= <span class="tok-builtin">@intToFloat</span>(<span class="tok-type">f64</span>, ldig);</span>
<span class="line" id="L379"></span>
<span class="line" id="L380">            mid *= <span class="tok-number">10.0</span>;</span>
<span class="line" id="L381">            <span class="tok-kw">const</span> mdig = <span class="tok-builtin">@floatToInt</span>(<span class="tok-type">i32</span>, mid);</span>
<span class="line" id="L382">            mid -= <span class="tok-builtin">@intToFloat</span>(<span class="tok-type">f64</span>, mdig);</span>
<span class="line" id="L383"></span>
<span class="line" id="L384">            hi *= <span class="tok-number">10.0</span>;</span>
<span class="line" id="L385">            <span class="tok-kw">const</span> hdig = <span class="tok-builtin">@floatToInt</span>(<span class="tok-type">i32</span>, hi);</span>
<span class="line" id="L386">            hi -= <span class="tok-builtin">@intToFloat</span>(<span class="tok-type">f64</span>, hdig);</span>
<span class="line" id="L387"></span>
<span class="line" id="L388">            buffer[j] = <span class="tok-builtin">@intCast</span>(<span class="tok-type">u8</span>, mdig + <span class="tok-str">'0'</span>);</span>
<span class="line" id="L389">            j += <span class="tok-number">1</span>;</span>
<span class="line" id="L390"></span>
<span class="line" id="L391">            <span class="tok-kw">if</span> (hdig != ldig <span class="tok-kw">or</span> j &gt; <span class="tok-number">50</span>) <span class="tok-kw">break</span>;</span>
<span class="line" id="L392">        }</span>
<span class="line" id="L393"></span>
<span class="line" id="L394">        <span class="tok-kw">if</span> (mid &gt; <span class="tok-number">0.5</span>) {</span>
<span class="line" id="L395">            buffer[j - <span class="tok-number">1</span>] += <span class="tok-number">1</span>;</span>
<span class="line" id="L396">        } <span class="tok-kw">else</span> <span class="tok-kw">if</span> ((mid == <span class="tok-number">0.5</span>) <span class="tok-kw">and</span> (buffer[j - <span class="tok-number">1</span>] &amp; <span class="tok-number">0x1</span>) != <span class="tok-number">0</span>) {</span>
<span class="line" id="L397">            buffer[j - <span class="tok-number">1</span>] += <span class="tok-number">1</span>;</span>
<span class="line" id="L398">        }</span>
<span class="line" id="L399">    } <span class="tok-kw">else</span> {</span>
<span class="line" id="L400">        <span class="tok-kw">while</span> (buffer[j - <span class="tok-number">1</span>] == <span class="tok-str">'0'</span>) {</span>
<span class="line" id="L401">            buffer[j - <span class="tok-number">1</span>] = <span class="tok-number">0</span>;</span>
<span class="line" id="L402">            j -= <span class="tok-number">1</span>;</span>
<span class="line" id="L403">        }</span>
<span class="line" id="L404">    }</span>
<span class="line" id="L405"></span>
<span class="line" id="L406">    buffer[j] = <span class="tok-number">0</span>;</span>
<span class="line" id="L407"></span>
<span class="line" id="L408">    <span class="tok-kw">return</span> FloatDecimal{</span>
<span class="line" id="L409">        .digits = buffer[<span class="tok-number">0</span>..j],</span>
<span class="line" id="L410">        .exp = exp,</span>
<span class="line" id="L411">    };</span>
<span class="line" id="L412">}</span>
<span class="line" id="L413"></span>
<span class="line" id="L414"><span class="tok-kw">fn</span> <span class="tok-fn">fpnext</span>(val: <span class="tok-type">f64</span>) <span class="tok-type">f64</span> {</span>
<span class="line" id="L415">    <span class="tok-kw">return</span> <span class="tok-builtin">@bitCast</span>(<span class="tok-type">f64</span>, <span class="tok-builtin">@bitCast</span>(<span class="tok-type">u64</span>, val) +% <span class="tok-number">1</span>);</span>
<span class="line" id="L416">}</span>
<span class="line" id="L417"></span>
<span class="line" id="L418"><span class="tok-kw">fn</span> <span class="tok-fn">fpprev</span>(val: <span class="tok-type">f64</span>) <span class="tok-type">f64</span> {</span>
<span class="line" id="L419">    <span class="tok-kw">return</span> <span class="tok-builtin">@bitCast</span>(<span class="tok-type">f64</span>, <span class="tok-builtin">@bitCast</span>(<span class="tok-type">u64</span>, val) -% <span class="tok-number">1</span>);</span>
<span class="line" id="L420">}</span>
<span class="line" id="L421"></span>
<span class="line" id="L422"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> c_digits_lut = [_]<span class="tok-type">u8</span>{</span>
<span class="line" id="L423">    <span class="tok-str">'0'</span>, <span class="tok-str">'0'</span>, <span class="tok-str">'0'</span>, <span class="tok-str">'1'</span>, <span class="tok-str">'0'</span>, <span class="tok-str">'2'</span>, <span class="tok-str">'0'</span>, <span class="tok-str">'3'</span>, <span class="tok-str">'0'</span>, <span class="tok-str">'4'</span>, <span class="tok-str">'0'</span>, <span class="tok-str">'5'</span>, <span class="tok-str">'0'</span>, <span class="tok-str">'6'</span>,</span>
<span class="line" id="L424">    <span class="tok-str">'0'</span>, <span class="tok-str">'7'</span>, <span class="tok-str">'0'</span>, <span class="tok-str">'8'</span>, <span class="tok-str">'0'</span>, <span class="tok-str">'9'</span>, <span class="tok-str">'1'</span>, <span class="tok-str">'0'</span>, <span class="tok-str">'1'</span>, <span class="tok-str">'1'</span>, <span class="tok-str">'1'</span>, <span class="tok-str">'2'</span>, <span class="tok-str">'1'</span>, <span class="tok-str">'3'</span>,</span>
<span class="line" id="L425">    <span class="tok-str">'1'</span>, <span class="tok-str">'4'</span>, <span class="tok-str">'1'</span>, <span class="tok-str">'5'</span>, <span class="tok-str">'1'</span>, <span class="tok-str">'6'</span>, <span class="tok-str">'1'</span>, <span class="tok-str">'7'</span>, <span class="tok-str">'1'</span>, <span class="tok-str">'8'</span>, <span class="tok-str">'1'</span>, <span class="tok-str">'9'</span>, <span class="tok-str">'2'</span>, <span class="tok-str">'0'</span>,</span>
<span class="line" id="L426">    <span class="tok-str">'2'</span>, <span class="tok-str">'1'</span>, <span class="tok-str">'2'</span>, <span class="tok-str">'2'</span>, <span class="tok-str">'2'</span>, <span class="tok-str">'3'</span>, <span class="tok-str">'2'</span>, <span class="tok-str">'4'</span>, <span class="tok-str">'2'</span>, <span class="tok-str">'5'</span>, <span class="tok-str">'2'</span>, <span class="tok-str">'6'</span>, <span class="tok-str">'2'</span>, <span class="tok-str">'7'</span>,</span>
<span class="line" id="L427">    <span class="tok-str">'2'</span>, <span class="tok-str">'8'</span>, <span class="tok-str">'2'</span>, <span class="tok-str">'9'</span>, <span class="tok-str">'3'</span>, <span class="tok-str">'0'</span>, <span class="tok-str">'3'</span>, <span class="tok-str">'1'</span>, <span class="tok-str">'3'</span>, <span class="tok-str">'2'</span>, <span class="tok-str">'3'</span>, <span class="tok-str">'3'</span>, <span class="tok-str">'3'</span>, <span class="tok-str">'4'</span>,</span>
<span class="line" id="L428">    <span class="tok-str">'3'</span>, <span class="tok-str">'5'</span>, <span class="tok-str">'3'</span>, <span class="tok-str">'6'</span>, <span class="tok-str">'3'</span>, <span class="tok-str">'7'</span>, <span class="tok-str">'3'</span>, <span class="tok-str">'8'</span>, <span class="tok-str">'3'</span>, <span class="tok-str">'9'</span>, <span class="tok-str">'4'</span>, <span class="tok-str">'0'</span>, <span class="tok-str">'4'</span>, <span class="tok-str">'1'</span>,</span>
<span class="line" id="L429">    <span class="tok-str">'4'</span>, <span class="tok-str">'2'</span>, <span class="tok-str">'4'</span>, <span class="tok-str">'3'</span>, <span class="tok-str">'4'</span>, <span class="tok-str">'4'</span>, <span class="tok-str">'4'</span>, <span class="tok-str">'5'</span>, <span class="tok-str">'4'</span>, <span class="tok-str">'6'</span>, <span class="tok-str">'4'</span>, <span class="tok-str">'7'</span>, <span class="tok-str">'4'</span>, <span class="tok-str">'8'</span>,</span>
<span class="line" id="L430">    <span class="tok-str">'4'</span>, <span class="tok-str">'9'</span>, <span class="tok-str">'5'</span>, <span class="tok-str">'0'</span>, <span class="tok-str">'5'</span>, <span class="tok-str">'1'</span>, <span class="tok-str">'5'</span>, <span class="tok-str">'2'</span>, <span class="tok-str">'5'</span>, <span class="tok-str">'3'</span>, <span class="tok-str">'5'</span>, <span class="tok-str">'4'</span>, <span class="tok-str">'5'</span>, <span class="tok-str">'5'</span>,</span>
<span class="line" id="L431">    <span class="tok-str">'5'</span>, <span class="tok-str">'6'</span>, <span class="tok-str">'5'</span>, <span class="tok-str">'7'</span>, <span class="tok-str">'5'</span>, <span class="tok-str">'8'</span>, <span class="tok-str">'5'</span>, <span class="tok-str">'9'</span>, <span class="tok-str">'6'</span>, <span class="tok-str">'0'</span>, <span class="tok-str">'6'</span>, <span class="tok-str">'1'</span>, <span class="tok-str">'6'</span>, <span class="tok-str">'2'</span>,</span>
<span class="line" id="L432">    <span class="tok-str">'6'</span>, <span class="tok-str">'3'</span>, <span class="tok-str">'6'</span>, <span class="tok-str">'4'</span>, <span class="tok-str">'6'</span>, <span class="tok-str">'5'</span>, <span class="tok-str">'6'</span>, <span class="tok-str">'6'</span>, <span class="tok-str">'6'</span>, <span class="tok-str">'7'</span>, <span class="tok-str">'6'</span>, <span class="tok-str">'8'</span>, <span class="tok-str">'6'</span>, <span class="tok-str">'9'</span>,</span>
<span class="line" id="L433">    <span class="tok-str">'7'</span>, <span class="tok-str">'0'</span>, <span class="tok-str">'7'</span>, <span class="tok-str">'1'</span>, <span class="tok-str">'7'</span>, <span class="tok-str">'2'</span>, <span class="tok-str">'7'</span>, <span class="tok-str">'3'</span>, <span class="tok-str">'7'</span>, <span class="tok-str">'4'</span>, <span class="tok-str">'7'</span>, <span class="tok-str">'5'</span>, <span class="tok-str">'7'</span>, <span class="tok-str">'6'</span>,</span>
<span class="line" id="L434">    <span class="tok-str">'7'</span>, <span class="tok-str">'7'</span>, <span class="tok-str">'7'</span>, <span class="tok-str">'8'</span>, <span class="tok-str">'7'</span>, <span class="tok-str">'9'</span>, <span class="tok-str">'8'</span>, <span class="tok-str">'0'</span>, <span class="tok-str">'8'</span>, <span class="tok-str">'1'</span>, <span class="tok-str">'8'</span>, <span class="tok-str">'2'</span>, <span class="tok-str">'8'</span>, <span class="tok-str">'3'</span>,</span>
<span class="line" id="L435">    <span class="tok-str">'8'</span>, <span class="tok-str">'4'</span>, <span class="tok-str">'8'</span>, <span class="tok-str">'5'</span>, <span class="tok-str">'8'</span>, <span class="tok-str">'6'</span>, <span class="tok-str">'8'</span>, <span class="tok-str">'7'</span>, <span class="tok-str">'8'</span>, <span class="tok-str">'8'</span>, <span class="tok-str">'8'</span>, <span class="tok-str">'9'</span>, <span class="tok-str">'9'</span>, <span class="tok-str">'0'</span>,</span>
<span class="line" id="L436">    <span class="tok-str">'9'</span>, <span class="tok-str">'1'</span>, <span class="tok-str">'9'</span>, <span class="tok-str">'2'</span>, <span class="tok-str">'9'</span>, <span class="tok-str">'3'</span>, <span class="tok-str">'9'</span>, <span class="tok-str">'4'</span>, <span class="tok-str">'9'</span>, <span class="tok-str">'5'</span>, <span class="tok-str">'9'</span>, <span class="tok-str">'6'</span>, <span class="tok-str">'9'</span>, <span class="tok-str">'7'</span>,</span>
<span class="line" id="L437">    <span class="tok-str">'9'</span>, <span class="tok-str">'8'</span>, <span class="tok-str">'9'</span>, <span class="tok-str">'9'</span>,</span>
<span class="line" id="L438">};</span>
<span class="line" id="L439"></span>
<span class="line" id="L440"><span class="tok-kw">fn</span> <span class="tok-fn">u64toa</span>(value_param: <span class="tok-type">u64</span>, buffer: []<span class="tok-type">u8</span>) <span class="tok-type">usize</span> {</span>
<span class="line" id="L441">    <span class="tok-kw">var</span> value = value_param;</span>
<span class="line" id="L442">    <span class="tok-kw">const</span> kTen8: <span class="tok-type">u64</span> = <span class="tok-number">100000000</span>;</span>
<span class="line" id="L443">    <span class="tok-kw">const</span> kTen9: <span class="tok-type">u64</span> = kTen8 * <span class="tok-number">10</span>;</span>
<span class="line" id="L444">    <span class="tok-kw">const</span> kTen10: <span class="tok-type">u64</span> = kTen8 * <span class="tok-number">100</span>;</span>
<span class="line" id="L445">    <span class="tok-kw">const</span> kTen11: <span class="tok-type">u64</span> = kTen8 * <span class="tok-number">1000</span>;</span>
<span class="line" id="L446">    <span class="tok-kw">const</span> kTen12: <span class="tok-type">u64</span> = kTen8 * <span class="tok-number">10000</span>;</span>
<span class="line" id="L447">    <span class="tok-kw">const</span> kTen13: <span class="tok-type">u64</span> = kTen8 * <span class="tok-number">100000</span>;</span>
<span class="line" id="L448">    <span class="tok-kw">const</span> kTen14: <span class="tok-type">u64</span> = kTen8 * <span class="tok-number">1000000</span>;</span>
<span class="line" id="L449">    <span class="tok-kw">const</span> kTen15: <span class="tok-type">u64</span> = kTen8 * <span class="tok-number">10000000</span>;</span>
<span class="line" id="L450">    <span class="tok-kw">const</span> kTen16: <span class="tok-type">u64</span> = kTen8 * kTen8;</span>
<span class="line" id="L451"></span>
<span class="line" id="L452">    <span class="tok-kw">var</span> buf_index: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L453"></span>
<span class="line" id="L454">    <span class="tok-kw">if</span> (value &lt; kTen8) {</span>
<span class="line" id="L455">        <span class="tok-kw">const</span> v = <span class="tok-builtin">@intCast</span>(<span class="tok-type">u32</span>, value);</span>
<span class="line" id="L456">        <span class="tok-kw">if</span> (v &lt; <span class="tok-number">10000</span>) {</span>
<span class="line" id="L457">            <span class="tok-kw">const</span> d1: <span class="tok-type">u32</span> = (v / <span class="tok-number">100</span>) &lt;&lt; <span class="tok-number">1</span>;</span>
<span class="line" id="L458">            <span class="tok-kw">const</span> d2: <span class="tok-type">u32</span> = (v % <span class="tok-number">100</span>) &lt;&lt; <span class="tok-number">1</span>;</span>
<span class="line" id="L459"></span>
<span class="line" id="L460">            <span class="tok-kw">if</span> (v &gt;= <span class="tok-number">1000</span>) {</span>
<span class="line" id="L461">                buffer[buf_index] = c_digits_lut[d1];</span>
<span class="line" id="L462">                buf_index += <span class="tok-number">1</span>;</span>
<span class="line" id="L463">            }</span>
<span class="line" id="L464">            <span class="tok-kw">if</span> (v &gt;= <span class="tok-number">100</span>) {</span>
<span class="line" id="L465">                buffer[buf_index] = c_digits_lut[d1 + <span class="tok-number">1</span>];</span>
<span class="line" id="L466">                buf_index += <span class="tok-number">1</span>;</span>
<span class="line" id="L467">            }</span>
<span class="line" id="L468">            <span class="tok-kw">if</span> (v &gt;= <span class="tok-number">10</span>) {</span>
<span class="line" id="L469">                buffer[buf_index] = c_digits_lut[d2];</span>
<span class="line" id="L470">                buf_index += <span class="tok-number">1</span>;</span>
<span class="line" id="L471">            }</span>
<span class="line" id="L472">            buffer[buf_index] = c_digits_lut[d2 + <span class="tok-number">1</span>];</span>
<span class="line" id="L473">            buf_index += <span class="tok-number">1</span>;</span>
<span class="line" id="L474">        } <span class="tok-kw">else</span> {</span>
<span class="line" id="L475">            <span class="tok-comment">// value = bbbbcccc</span>
</span>
<span class="line" id="L476">            <span class="tok-kw">const</span> b: <span class="tok-type">u32</span> = v / <span class="tok-number">10000</span>;</span>
<span class="line" id="L477">            <span class="tok-kw">const</span> c: <span class="tok-type">u32</span> = v % <span class="tok-number">10000</span>;</span>
<span class="line" id="L478"></span>
<span class="line" id="L479">            <span class="tok-kw">const</span> d1: <span class="tok-type">u32</span> = (b / <span class="tok-number">100</span>) &lt;&lt; <span class="tok-number">1</span>;</span>
<span class="line" id="L480">            <span class="tok-kw">const</span> d2: <span class="tok-type">u32</span> = (b % <span class="tok-number">100</span>) &lt;&lt; <span class="tok-number">1</span>;</span>
<span class="line" id="L481"></span>
<span class="line" id="L482">            <span class="tok-kw">const</span> d3: <span class="tok-type">u32</span> = (c / <span class="tok-number">100</span>) &lt;&lt; <span class="tok-number">1</span>;</span>
<span class="line" id="L483">            <span class="tok-kw">const</span> d4: <span class="tok-type">u32</span> = (c % <span class="tok-number">100</span>) &lt;&lt; <span class="tok-number">1</span>;</span>
<span class="line" id="L484"></span>
<span class="line" id="L485">            <span class="tok-kw">if</span> (value &gt;= <span class="tok-number">10000000</span>) {</span>
<span class="line" id="L486">                buffer[buf_index] = c_digits_lut[d1];</span>
<span class="line" id="L487">                buf_index += <span class="tok-number">1</span>;</span>
<span class="line" id="L488">            }</span>
<span class="line" id="L489">            <span class="tok-kw">if</span> (value &gt;= <span class="tok-number">1000000</span>) {</span>
<span class="line" id="L490">                buffer[buf_index] = c_digits_lut[d1 + <span class="tok-number">1</span>];</span>
<span class="line" id="L491">                buf_index += <span class="tok-number">1</span>;</span>
<span class="line" id="L492">            }</span>
<span class="line" id="L493">            <span class="tok-kw">if</span> (value &gt;= <span class="tok-number">100000</span>) {</span>
<span class="line" id="L494">                buffer[buf_index] = c_digits_lut[d2];</span>
<span class="line" id="L495">                buf_index += <span class="tok-number">1</span>;</span>
<span class="line" id="L496">            }</span>
<span class="line" id="L497">            buffer[buf_index] = c_digits_lut[d2 + <span class="tok-number">1</span>];</span>
<span class="line" id="L498">            buf_index += <span class="tok-number">1</span>;</span>
<span class="line" id="L499"></span>
<span class="line" id="L500">            buffer[buf_index] = c_digits_lut[d3];</span>
<span class="line" id="L501">            buf_index += <span class="tok-number">1</span>;</span>
<span class="line" id="L502">            buffer[buf_index] = c_digits_lut[d3 + <span class="tok-number">1</span>];</span>
<span class="line" id="L503">            buf_index += <span class="tok-number">1</span>;</span>
<span class="line" id="L504">            buffer[buf_index] = c_digits_lut[d4];</span>
<span class="line" id="L505">            buf_index += <span class="tok-number">1</span>;</span>
<span class="line" id="L506">            buffer[buf_index] = c_digits_lut[d4 + <span class="tok-number">1</span>];</span>
<span class="line" id="L507">            buf_index += <span class="tok-number">1</span>;</span>
<span class="line" id="L508">        }</span>
<span class="line" id="L509">    } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (value &lt; kTen16) {</span>
<span class="line" id="L510">        <span class="tok-kw">const</span> v0: <span class="tok-type">u32</span> = <span class="tok-builtin">@intCast</span>(<span class="tok-type">u32</span>, value / kTen8);</span>
<span class="line" id="L511">        <span class="tok-kw">const</span> v1: <span class="tok-type">u32</span> = <span class="tok-builtin">@intCast</span>(<span class="tok-type">u32</span>, value % kTen8);</span>
<span class="line" id="L512"></span>
<span class="line" id="L513">        <span class="tok-kw">const</span> b0: <span class="tok-type">u32</span> = v0 / <span class="tok-number">10000</span>;</span>
<span class="line" id="L514">        <span class="tok-kw">const</span> c0: <span class="tok-type">u32</span> = v0 % <span class="tok-number">10000</span>;</span>
<span class="line" id="L515"></span>
<span class="line" id="L516">        <span class="tok-kw">const</span> d1: <span class="tok-type">u32</span> = (b0 / <span class="tok-number">100</span>) &lt;&lt; <span class="tok-number">1</span>;</span>
<span class="line" id="L517">        <span class="tok-kw">const</span> d2: <span class="tok-type">u32</span> = (b0 % <span class="tok-number">100</span>) &lt;&lt; <span class="tok-number">1</span>;</span>
<span class="line" id="L518"></span>
<span class="line" id="L519">        <span class="tok-kw">const</span> d3: <span class="tok-type">u32</span> = (c0 / <span class="tok-number">100</span>) &lt;&lt; <span class="tok-number">1</span>;</span>
<span class="line" id="L520">        <span class="tok-kw">const</span> d4: <span class="tok-type">u32</span> = (c0 % <span class="tok-number">100</span>) &lt;&lt; <span class="tok-number">1</span>;</span>
<span class="line" id="L521"></span>
<span class="line" id="L522">        <span class="tok-kw">const</span> b1: <span class="tok-type">u32</span> = v1 / <span class="tok-number">10000</span>;</span>
<span class="line" id="L523">        <span class="tok-kw">const</span> c1: <span class="tok-type">u32</span> = v1 % <span class="tok-number">10000</span>;</span>
<span class="line" id="L524"></span>
<span class="line" id="L525">        <span class="tok-kw">const</span> d5: <span class="tok-type">u32</span> = (b1 / <span class="tok-number">100</span>) &lt;&lt; <span class="tok-number">1</span>;</span>
<span class="line" id="L526">        <span class="tok-kw">const</span> d6: <span class="tok-type">u32</span> = (b1 % <span class="tok-number">100</span>) &lt;&lt; <span class="tok-number">1</span>;</span>
<span class="line" id="L527"></span>
<span class="line" id="L528">        <span class="tok-kw">const</span> d7: <span class="tok-type">u32</span> = (c1 / <span class="tok-number">100</span>) &lt;&lt; <span class="tok-number">1</span>;</span>
<span class="line" id="L529">        <span class="tok-kw">const</span> d8: <span class="tok-type">u32</span> = (c1 % <span class="tok-number">100</span>) &lt;&lt; <span class="tok-number">1</span>;</span>
<span class="line" id="L530"></span>
<span class="line" id="L531">        <span class="tok-kw">if</span> (value &gt;= kTen15) {</span>
<span class="line" id="L532">            buffer[buf_index] = c_digits_lut[d1];</span>
<span class="line" id="L533">            buf_index += <span class="tok-number">1</span>;</span>
<span class="line" id="L534">        }</span>
<span class="line" id="L535">        <span class="tok-kw">if</span> (value &gt;= kTen14) {</span>
<span class="line" id="L536">            buffer[buf_index] = c_digits_lut[d1 + <span class="tok-number">1</span>];</span>
<span class="line" id="L537">            buf_index += <span class="tok-number">1</span>;</span>
<span class="line" id="L538">        }</span>
<span class="line" id="L539">        <span class="tok-kw">if</span> (value &gt;= kTen13) {</span>
<span class="line" id="L540">            buffer[buf_index] = c_digits_lut[d2];</span>
<span class="line" id="L541">            buf_index += <span class="tok-number">1</span>;</span>
<span class="line" id="L542">        }</span>
<span class="line" id="L543">        <span class="tok-kw">if</span> (value &gt;= kTen12) {</span>
<span class="line" id="L544">            buffer[buf_index] = c_digits_lut[d2 + <span class="tok-number">1</span>];</span>
<span class="line" id="L545">            buf_index += <span class="tok-number">1</span>;</span>
<span class="line" id="L546">        }</span>
<span class="line" id="L547">        <span class="tok-kw">if</span> (value &gt;= kTen11) {</span>
<span class="line" id="L548">            buffer[buf_index] = c_digits_lut[d3];</span>
<span class="line" id="L549">            buf_index += <span class="tok-number">1</span>;</span>
<span class="line" id="L550">        }</span>
<span class="line" id="L551">        <span class="tok-kw">if</span> (value &gt;= kTen10) {</span>
<span class="line" id="L552">            buffer[buf_index] = c_digits_lut[d3 + <span class="tok-number">1</span>];</span>
<span class="line" id="L553">            buf_index += <span class="tok-number">1</span>;</span>
<span class="line" id="L554">        }</span>
<span class="line" id="L555">        <span class="tok-kw">if</span> (value &gt;= kTen9) {</span>
<span class="line" id="L556">            buffer[buf_index] = c_digits_lut[d4];</span>
<span class="line" id="L557">            buf_index += <span class="tok-number">1</span>;</span>
<span class="line" id="L558">        }</span>
<span class="line" id="L559">        <span class="tok-kw">if</span> (value &gt;= kTen8) {</span>
<span class="line" id="L560">            buffer[buf_index] = c_digits_lut[d4 + <span class="tok-number">1</span>];</span>
<span class="line" id="L561">            buf_index += <span class="tok-number">1</span>;</span>
<span class="line" id="L562">        }</span>
<span class="line" id="L563"></span>
<span class="line" id="L564">        buffer[buf_index] = c_digits_lut[d5];</span>
<span class="line" id="L565">        buf_index += <span class="tok-number">1</span>;</span>
<span class="line" id="L566">        buffer[buf_index] = c_digits_lut[d5 + <span class="tok-number">1</span>];</span>
<span class="line" id="L567">        buf_index += <span class="tok-number">1</span>;</span>
<span class="line" id="L568">        buffer[buf_index] = c_digits_lut[d6];</span>
<span class="line" id="L569">        buf_index += <span class="tok-number">1</span>;</span>
<span class="line" id="L570">        buffer[buf_index] = c_digits_lut[d6 + <span class="tok-number">1</span>];</span>
<span class="line" id="L571">        buf_index += <span class="tok-number">1</span>;</span>
<span class="line" id="L572">        buffer[buf_index] = c_digits_lut[d7];</span>
<span class="line" id="L573">        buf_index += <span class="tok-number">1</span>;</span>
<span class="line" id="L574">        buffer[buf_index] = c_digits_lut[d7 + <span class="tok-number">1</span>];</span>
<span class="line" id="L575">        buf_index += <span class="tok-number">1</span>;</span>
<span class="line" id="L576">        buffer[buf_index] = c_digits_lut[d8];</span>
<span class="line" id="L577">        buf_index += <span class="tok-number">1</span>;</span>
<span class="line" id="L578">        buffer[buf_index] = c_digits_lut[d8 + <span class="tok-number">1</span>];</span>
<span class="line" id="L579">        buf_index += <span class="tok-number">1</span>;</span>
<span class="line" id="L580">    } <span class="tok-kw">else</span> {</span>
<span class="line" id="L581">        <span class="tok-kw">const</span> a = <span class="tok-builtin">@intCast</span>(<span class="tok-type">u32</span>, value / kTen16); <span class="tok-comment">// 1 to 1844</span>
</span>
<span class="line" id="L582">        value %= kTen16;</span>
<span class="line" id="L583"></span>
<span class="line" id="L584">        <span class="tok-kw">if</span> (a &lt; <span class="tok-number">10</span>) {</span>
<span class="line" id="L585">            buffer[buf_index] = <span class="tok-str">'0'</span> + <span class="tok-builtin">@intCast</span>(<span class="tok-type">u8</span>, a);</span>
<span class="line" id="L586">            buf_index += <span class="tok-number">1</span>;</span>
<span class="line" id="L587">        } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (a &lt; <span class="tok-number">100</span>) {</span>
<span class="line" id="L588">            <span class="tok-kw">const</span> i: <span class="tok-type">u32</span> = a &lt;&lt; <span class="tok-number">1</span>;</span>
<span class="line" id="L589">            buffer[buf_index] = c_digits_lut[i];</span>
<span class="line" id="L590">            buf_index += <span class="tok-number">1</span>;</span>
<span class="line" id="L591">            buffer[buf_index] = c_digits_lut[i + <span class="tok-number">1</span>];</span>
<span class="line" id="L592">            buf_index += <span class="tok-number">1</span>;</span>
<span class="line" id="L593">        } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (a &lt; <span class="tok-number">1000</span>) {</span>
<span class="line" id="L594">            buffer[buf_index] = <span class="tok-str">'0'</span> + <span class="tok-builtin">@intCast</span>(<span class="tok-type">u8</span>, a / <span class="tok-number">100</span>);</span>
<span class="line" id="L595">            buf_index += <span class="tok-number">1</span>;</span>
<span class="line" id="L596"></span>
<span class="line" id="L597">            <span class="tok-kw">const</span> i: <span class="tok-type">u32</span> = (a % <span class="tok-number">100</span>) &lt;&lt; <span class="tok-number">1</span>;</span>
<span class="line" id="L598">            buffer[buf_index] = c_digits_lut[i];</span>
<span class="line" id="L599">            buf_index += <span class="tok-number">1</span>;</span>
<span class="line" id="L600">            buffer[buf_index] = c_digits_lut[i + <span class="tok-number">1</span>];</span>
<span class="line" id="L601">            buf_index += <span class="tok-number">1</span>;</span>
<span class="line" id="L602">        } <span class="tok-kw">else</span> {</span>
<span class="line" id="L603">            <span class="tok-kw">const</span> i: <span class="tok-type">u32</span> = (a / <span class="tok-number">100</span>) &lt;&lt; <span class="tok-number">1</span>;</span>
<span class="line" id="L604">            <span class="tok-kw">const</span> j: <span class="tok-type">u32</span> = (a % <span class="tok-number">100</span>) &lt;&lt; <span class="tok-number">1</span>;</span>
<span class="line" id="L605">            buffer[buf_index] = c_digits_lut[i];</span>
<span class="line" id="L606">            buf_index += <span class="tok-number">1</span>;</span>
<span class="line" id="L607">            buffer[buf_index] = c_digits_lut[i + <span class="tok-number">1</span>];</span>
<span class="line" id="L608">            buf_index += <span class="tok-number">1</span>;</span>
<span class="line" id="L609">            buffer[buf_index] = c_digits_lut[j];</span>
<span class="line" id="L610">            buf_index += <span class="tok-number">1</span>;</span>
<span class="line" id="L611">            buffer[buf_index] = c_digits_lut[j + <span class="tok-number">1</span>];</span>
<span class="line" id="L612">            buf_index += <span class="tok-number">1</span>;</span>
<span class="line" id="L613">        }</span>
<span class="line" id="L614"></span>
<span class="line" id="L615">        <span class="tok-kw">const</span> v0 = <span class="tok-builtin">@intCast</span>(<span class="tok-type">u32</span>, value / kTen8);</span>
<span class="line" id="L616">        <span class="tok-kw">const</span> v1 = <span class="tok-builtin">@intCast</span>(<span class="tok-type">u32</span>, value % kTen8);</span>
<span class="line" id="L617"></span>
<span class="line" id="L618">        <span class="tok-kw">const</span> b0: <span class="tok-type">u32</span> = v0 / <span class="tok-number">10000</span>;</span>
<span class="line" id="L619">        <span class="tok-kw">const</span> c0: <span class="tok-type">u32</span> = v0 % <span class="tok-number">10000</span>;</span>
<span class="line" id="L620"></span>
<span class="line" id="L621">        <span class="tok-kw">const</span> d1: <span class="tok-type">u32</span> = (b0 / <span class="tok-number">100</span>) &lt;&lt; <span class="tok-number">1</span>;</span>
<span class="line" id="L622">        <span class="tok-kw">const</span> d2: <span class="tok-type">u32</span> = (b0 % <span class="tok-number">100</span>) &lt;&lt; <span class="tok-number">1</span>;</span>
<span class="line" id="L623"></span>
<span class="line" id="L624">        <span class="tok-kw">const</span> d3: <span class="tok-type">u32</span> = (c0 / <span class="tok-number">100</span>) &lt;&lt; <span class="tok-number">1</span>;</span>
<span class="line" id="L625">        <span class="tok-kw">const</span> d4: <span class="tok-type">u32</span> = (c0 % <span class="tok-number">100</span>) &lt;&lt; <span class="tok-number">1</span>;</span>
<span class="line" id="L626"></span>
<span class="line" id="L627">        <span class="tok-kw">const</span> b1: <span class="tok-type">u32</span> = v1 / <span class="tok-number">10000</span>;</span>
<span class="line" id="L628">        <span class="tok-kw">const</span> c1: <span class="tok-type">u32</span> = v1 % <span class="tok-number">10000</span>;</span>
<span class="line" id="L629"></span>
<span class="line" id="L630">        <span class="tok-kw">const</span> d5: <span class="tok-type">u32</span> = (b1 / <span class="tok-number">100</span>) &lt;&lt; <span class="tok-number">1</span>;</span>
<span class="line" id="L631">        <span class="tok-kw">const</span> d6: <span class="tok-type">u32</span> = (b1 % <span class="tok-number">100</span>) &lt;&lt; <span class="tok-number">1</span>;</span>
<span class="line" id="L632"></span>
<span class="line" id="L633">        <span class="tok-kw">const</span> d7: <span class="tok-type">u32</span> = (c1 / <span class="tok-number">100</span>) &lt;&lt; <span class="tok-number">1</span>;</span>
<span class="line" id="L634">        <span class="tok-kw">const</span> d8: <span class="tok-type">u32</span> = (c1 % <span class="tok-number">100</span>) &lt;&lt; <span class="tok-number">1</span>;</span>
<span class="line" id="L635"></span>
<span class="line" id="L636">        buffer[buf_index] = c_digits_lut[d1];</span>
<span class="line" id="L637">        buf_index += <span class="tok-number">1</span>;</span>
<span class="line" id="L638">        buffer[buf_index] = c_digits_lut[d1 + <span class="tok-number">1</span>];</span>
<span class="line" id="L639">        buf_index += <span class="tok-number">1</span>;</span>
<span class="line" id="L640">        buffer[buf_index] = c_digits_lut[d2];</span>
<span class="line" id="L641">        buf_index += <span class="tok-number">1</span>;</span>
<span class="line" id="L642">        buffer[buf_index] = c_digits_lut[d2 + <span class="tok-number">1</span>];</span>
<span class="line" id="L643">        buf_index += <span class="tok-number">1</span>;</span>
<span class="line" id="L644">        buffer[buf_index] = c_digits_lut[d3];</span>
<span class="line" id="L645">        buf_index += <span class="tok-number">1</span>;</span>
<span class="line" id="L646">        buffer[buf_index] = c_digits_lut[d3 + <span class="tok-number">1</span>];</span>
<span class="line" id="L647">        buf_index += <span class="tok-number">1</span>;</span>
<span class="line" id="L648">        buffer[buf_index] = c_digits_lut[d4];</span>
<span class="line" id="L649">        buf_index += <span class="tok-number">1</span>;</span>
<span class="line" id="L650">        buffer[buf_index] = c_digits_lut[d4 + <span class="tok-number">1</span>];</span>
<span class="line" id="L651">        buf_index += <span class="tok-number">1</span>;</span>
<span class="line" id="L652">        buffer[buf_index] = c_digits_lut[d5];</span>
<span class="line" id="L653">        buf_index += <span class="tok-number">1</span>;</span>
<span class="line" id="L654">        buffer[buf_index] = c_digits_lut[d5 + <span class="tok-number">1</span>];</span>
<span class="line" id="L655">        buf_index += <span class="tok-number">1</span>;</span>
<span class="line" id="L656">        buffer[buf_index] = c_digits_lut[d6];</span>
<span class="line" id="L657">        buf_index += <span class="tok-number">1</span>;</span>
<span class="line" id="L658">        buffer[buf_index] = c_digits_lut[d6 + <span class="tok-number">1</span>];</span>
<span class="line" id="L659">        buf_index += <span class="tok-number">1</span>;</span>
<span class="line" id="L660">        buffer[buf_index] = c_digits_lut[d7];</span>
<span class="line" id="L661">        buf_index += <span class="tok-number">1</span>;</span>
<span class="line" id="L662">        buffer[buf_index] = c_digits_lut[d7 + <span class="tok-number">1</span>];</span>
<span class="line" id="L663">        buf_index += <span class="tok-number">1</span>;</span>
<span class="line" id="L664">        buffer[buf_index] = c_digits_lut[d8];</span>
<span class="line" id="L665">        buf_index += <span class="tok-number">1</span>;</span>
<span class="line" id="L666">        buffer[buf_index] = c_digits_lut[d8 + <span class="tok-number">1</span>];</span>
<span class="line" id="L667">        buf_index += <span class="tok-number">1</span>;</span>
<span class="line" id="L668">    }</span>
<span class="line" id="L669"></span>
<span class="line" id="L670">    <span class="tok-kw">return</span> buf_index;</span>
<span class="line" id="L671">}</span>
<span class="line" id="L672"></span>
<span class="line" id="L673"><span class="tok-kw">fn</span> <span class="tok-fn">fpeint</span>(from: <span class="tok-type">f64</span>) <span class="tok-type">u128</span> {</span>
<span class="line" id="L674">    <span class="tok-kw">const</span> bits = <span class="tok-builtin">@bitCast</span>(<span class="tok-type">u64</span>, from);</span>
<span class="line" id="L675">    assert((bits &amp; ((<span class="tok-number">1</span> &lt;&lt; <span class="tok-number">52</span>) - <span class="tok-number">1</span>)) == <span class="tok-number">0</span>);</span>
<span class="line" id="L676"></span>
<span class="line" id="L677">    <span class="tok-kw">return</span> <span class="tok-builtin">@as</span>(<span class="tok-type">u128</span>, <span class="tok-number">1</span>) &lt;&lt; <span class="tok-builtin">@truncate</span>(<span class="tok-type">u7</span>, (bits &gt;&gt; <span class="tok-number">52</span>) -% <span class="tok-number">1023</span>);</span>
<span class="line" id="L678">}</span>
<span class="line" id="L679"></span>
<span class="line" id="L680"><span class="tok-comment">/// Given two different integers with the same length in terms of the number</span></span>
<span class="line" id="L681"><span class="tok-comment">/// of decimal digits, index the digits from the right-most position starting</span></span>
<span class="line" id="L682"><span class="tok-comment">/// from zero, find the first index where the digits in the two integers</span></span>
<span class="line" id="L683"><span class="tok-comment">/// divergent starting from the highest index.</span></span>
<span class="line" id="L684"><span class="tok-comment">///   @a: Integer a.</span></span>
<span class="line" id="L685"><span class="tok-comment">///   @b: Integer b.</span></span>
<span class="line" id="L686"><span class="tok-comment">///   &amp;returns: An index within [0, 19).</span></span>
<span class="line" id="L687"><span class="tok-kw">fn</span> <span class="tok-fn">mismatch10</span>(a: <span class="tok-type">u64</span>, b: <span class="tok-type">u64</span>) <span class="tok-type">i32</span> {</span>
<span class="line" id="L688">    <span class="tok-kw">const</span> pow10 = <span class="tok-number">10000000000</span>;</span>
<span class="line" id="L689">    <span class="tok-kw">const</span> af = a / pow10;</span>
<span class="line" id="L690">    <span class="tok-kw">const</span> bf = b / pow10;</span>
<span class="line" id="L691"></span>
<span class="line" id="L692">    <span class="tok-kw">var</span> i: <span class="tok-type">i32</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L693">    <span class="tok-kw">var</span> a_copy = a;</span>
<span class="line" id="L694">    <span class="tok-kw">var</span> b_copy = b;</span>
<span class="line" id="L695"></span>
<span class="line" id="L696">    <span class="tok-kw">if</span> (af != bf) {</span>
<span class="line" id="L697">        i = <span class="tok-number">10</span>;</span>
<span class="line" id="L698">        a_copy = af;</span>
<span class="line" id="L699">        b_copy = bf;</span>
<span class="line" id="L700">    }</span>
<span class="line" id="L701"></span>
<span class="line" id="L702">    <span class="tok-kw">while</span> (<span class="tok-null">true</span>) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L703">        a_copy /= <span class="tok-number">10</span>;</span>
<span class="line" id="L704">        b_copy /= <span class="tok-number">10</span>;</span>
<span class="line" id="L705"></span>
<span class="line" id="L706">        <span class="tok-kw">if</span> (a_copy == b_copy) <span class="tok-kw">return</span> i;</span>
<span class="line" id="L707">    }</span>
<span class="line" id="L708">}</span>
<span class="line" id="L709"></span>
</code></pre></body>
</html>