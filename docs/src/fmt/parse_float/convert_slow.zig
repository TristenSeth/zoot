<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">    <title>fmt/parse_float/convert_slow.zig - source view</title>
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
<span class="line" id="L4"><span class="tok-kw">const</span> BiasedFp = common.BiasedFp;</span>
<span class="line" id="L5"><span class="tok-kw">const</span> Decimal = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;decimal.zig&quot;</span>).Decimal;</span>
<span class="line" id="L6"><span class="tok-kw">const</span> mantissaType = common.mantissaType;</span>
<span class="line" id="L7"></span>
<span class="line" id="L8"><span class="tok-kw">const</span> max_shift = <span class="tok-number">60</span>;</span>
<span class="line" id="L9"><span class="tok-kw">const</span> num_powers = <span class="tok-number">19</span>;</span>
<span class="line" id="L10"><span class="tok-kw">const</span> powers = [_]<span class="tok-type">u8</span>{ <span class="tok-number">0</span>, <span class="tok-number">3</span>, <span class="tok-number">6</span>, <span class="tok-number">9</span>, <span class="tok-number">13</span>, <span class="tok-number">16</span>, <span class="tok-number">19</span>, <span class="tok-number">23</span>, <span class="tok-number">26</span>, <span class="tok-number">29</span>, <span class="tok-number">33</span>, <span class="tok-number">36</span>, <span class="tok-number">39</span>, <span class="tok-number">43</span>, <span class="tok-number">46</span>, <span class="tok-number">49</span>, <span class="tok-number">53</span>, <span class="tok-number">56</span>, <span class="tok-number">59</span> };</span>
<span class="line" id="L11"></span>
<span class="line" id="L12"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">getShift</span>(n: <span class="tok-type">usize</span>) <span class="tok-type">usize</span> {</span>
<span class="line" id="L13">    <span class="tok-kw">return</span> <span class="tok-kw">if</span> (n &lt; num_powers) powers[n] <span class="tok-kw">else</span> max_shift;</span>
<span class="line" id="L14">}</span>
<span class="line" id="L15"></span>
<span class="line" id="L16"><span class="tok-comment">/// Parse the significant digits and biased, binary exponent of a float.</span></span>
<span class="line" id="L17"><span class="tok-comment">///</span></span>
<span class="line" id="L18"><span class="tok-comment">/// This is a fallback algorithm that uses a big-integer representation</span></span>
<span class="line" id="L19"><span class="tok-comment">/// of the float, and therefore is considerably slower than faster</span></span>
<span class="line" id="L20"><span class="tok-comment">/// approximations. However, it will always determine how to round</span></span>
<span class="line" id="L21"><span class="tok-comment">/// the significant digits to the nearest machine float, allowing</span></span>
<span class="line" id="L22"><span class="tok-comment">/// use to handle near half-way cases.</span></span>
<span class="line" id="L23"><span class="tok-comment">///</span></span>
<span class="line" id="L24"><span class="tok-comment">/// Near half-way cases are halfway between two consecutive machine floats.</span></span>
<span class="line" id="L25"><span class="tok-comment">/// For example, the float `16777217.0` has a bitwise representation of</span></span>
<span class="line" id="L26"><span class="tok-comment">/// `100000000000000000000000 1`. Rounding to a single-precision float,</span></span>
<span class="line" id="L27"><span class="tok-comment">/// the trailing `1` is truncated. Using round-nearest, tie-even, any</span></span>
<span class="line" id="L28"><span class="tok-comment">/// value above `16777217.0` must be rounded up to `16777218.0`, while</span></span>
<span class="line" id="L29"><span class="tok-comment">/// any value before or equal to `16777217.0` must be rounded down</span></span>
<span class="line" id="L30"><span class="tok-comment">/// to `16777216.0`. These near-halfway conversions therefore may require</span></span>
<span class="line" id="L31"><span class="tok-comment">/// a large number of digits to unambiguously determine how to round.</span></span>
<span class="line" id="L32"><span class="tok-comment">///</span></span>
<span class="line" id="L33"><span class="tok-comment">/// The algorithms described here are based on &quot;Processing Long Numbers Quickly&quot;,</span></span>
<span class="line" id="L34"><span class="tok-comment">/// available here: &lt;https://arxiv.org/pdf/2101.11408.pdf#section.11&gt;.</span></span>
<span class="line" id="L35"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">convertSlow</span>(<span class="tok-kw">comptime</span> T: <span class="tok-type">type</span>, s: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) BiasedFp(T) {</span>
<span class="line" id="L36">    <span class="tok-kw">const</span> MantissaT = mantissaType(T);</span>
<span class="line" id="L37">    <span class="tok-kw">const</span> min_exponent = -(<span class="tok-number">1</span> &lt;&lt; (math.floatExponentBits(T) - <span class="tok-number">1</span>)) + <span class="tok-number">1</span>;</span>
<span class="line" id="L38">    <span class="tok-kw">const</span> infinite_power = (<span class="tok-number">1</span> &lt;&lt; math.floatExponentBits(T)) - <span class="tok-number">1</span>;</span>
<span class="line" id="L39">    <span class="tok-kw">const</span> mantissa_explicit_bits = math.floatMantissaBits(T);</span>
<span class="line" id="L40"></span>
<span class="line" id="L41">    <span class="tok-kw">var</span> d = Decimal(T).parse(s); <span class="tok-comment">// no need to recheck underscores</span>
</span>
<span class="line" id="L42">    <span class="tok-kw">if</span> (d.num_digits == <span class="tok-number">0</span> <span class="tok-kw">or</span> d.decimal_point &lt; Decimal(T).min_exponent) {</span>
<span class="line" id="L43">        <span class="tok-kw">return</span> BiasedFp(T).zero();</span>
<span class="line" id="L44">    } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (d.decimal_point &gt;= Decimal(T).max_exponent) {</span>
<span class="line" id="L45">        <span class="tok-kw">return</span> BiasedFp(T).inf(T);</span>
<span class="line" id="L46">    }</span>
<span class="line" id="L47"></span>
<span class="line" id="L48">    <span class="tok-kw">var</span> exp2: <span class="tok-type">i32</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L49">    <span class="tok-comment">// Shift right toward (1/2 .. 1]</span>
</span>
<span class="line" id="L50">    <span class="tok-kw">while</span> (d.decimal_point &gt; <span class="tok-number">0</span>) {</span>
<span class="line" id="L51">        <span class="tok-kw">const</span> n = <span class="tok-builtin">@intCast</span>(<span class="tok-type">usize</span>, d.decimal_point);</span>
<span class="line" id="L52">        <span class="tok-kw">const</span> shift = getShift(n);</span>
<span class="line" id="L53">        d.rightShift(shift);</span>
<span class="line" id="L54">        <span class="tok-kw">if</span> (d.decimal_point &lt; -Decimal(T).decimal_point_range) {</span>
<span class="line" id="L55">            <span class="tok-kw">return</span> BiasedFp(T).zero();</span>
<span class="line" id="L56">        }</span>
<span class="line" id="L57">        exp2 += <span class="tok-builtin">@intCast</span>(<span class="tok-type">i32</span>, shift);</span>
<span class="line" id="L58">    }</span>
<span class="line" id="L59">    <span class="tok-comment">//  Shift left toward (1/2 .. 1]</span>
</span>
<span class="line" id="L60">    <span class="tok-kw">while</span> (d.decimal_point &lt;= <span class="tok-number">0</span>) {</span>
<span class="line" id="L61">        <span class="tok-kw">const</span> shift = blk: {</span>
<span class="line" id="L62">            <span class="tok-kw">if</span> (d.decimal_point == <span class="tok-number">0</span>) {</span>
<span class="line" id="L63">                <span class="tok-kw">break</span> :blk <span class="tok-kw">switch</span> (d.digits[<span class="tok-number">0</span>]) {</span>
<span class="line" id="L64">                    <span class="tok-number">5</span>...<span class="tok-number">9</span> =&gt; <span class="tok-kw">break</span>,</span>
<span class="line" id="L65">                    <span class="tok-number">0</span>, <span class="tok-number">1</span> =&gt; <span class="tok-builtin">@as</span>(<span class="tok-type">usize</span>, <span class="tok-number">2</span>),</span>
<span class="line" id="L66">                    <span class="tok-kw">else</span> =&gt; <span class="tok-number">1</span>,</span>
<span class="line" id="L67">                };</span>
<span class="line" id="L68">            } <span class="tok-kw">else</span> {</span>
<span class="line" id="L69">                <span class="tok-kw">const</span> n = <span class="tok-builtin">@intCast</span>(<span class="tok-type">usize</span>, -d.decimal_point);</span>
<span class="line" id="L70">                <span class="tok-kw">break</span> :blk getShift(n);</span>
<span class="line" id="L71">            }</span>
<span class="line" id="L72">        };</span>
<span class="line" id="L73">        d.leftShift(shift);</span>
<span class="line" id="L74">        <span class="tok-kw">if</span> (d.decimal_point &gt; Decimal(T).decimal_point_range) {</span>
<span class="line" id="L75">            <span class="tok-kw">return</span> BiasedFp(T).inf(T);</span>
<span class="line" id="L76">        }</span>
<span class="line" id="L77">        exp2 -= <span class="tok-builtin">@intCast</span>(<span class="tok-type">i32</span>, shift);</span>
<span class="line" id="L78">    }</span>
<span class="line" id="L79">    <span class="tok-comment">// We are now in the range [1/2 .. 1] but the binary format uses [1 .. 2]</span>
</span>
<span class="line" id="L80">    exp2 -= <span class="tok-number">1</span>;</span>
<span class="line" id="L81">    <span class="tok-kw">while</span> (min_exponent + <span class="tok-number">1</span> &gt; exp2) {</span>
<span class="line" id="L82">        <span class="tok-kw">var</span> n = <span class="tok-builtin">@intCast</span>(<span class="tok-type">usize</span>, (min_exponent + <span class="tok-number">1</span>) - exp2);</span>
<span class="line" id="L83">        <span class="tok-kw">if</span> (n &gt; max_shift) {</span>
<span class="line" id="L84">            n = max_shift;</span>
<span class="line" id="L85">        }</span>
<span class="line" id="L86">        d.rightShift(n);</span>
<span class="line" id="L87">        exp2 += <span class="tok-builtin">@intCast</span>(<span class="tok-type">i32</span>, n);</span>
<span class="line" id="L88">    }</span>
<span class="line" id="L89">    <span class="tok-kw">if</span> (exp2 - min_exponent &gt;= infinite_power) {</span>
<span class="line" id="L90">        <span class="tok-kw">return</span> BiasedFp(T).inf(T);</span>
<span class="line" id="L91">    }</span>
<span class="line" id="L92"></span>
<span class="line" id="L93">    <span class="tok-comment">// Shift the decimal to the hidden bit, and then round the value</span>
</span>
<span class="line" id="L94">    <span class="tok-comment">// to get the high mantissa+1 bits.</span>
</span>
<span class="line" id="L95">    d.leftShift(mantissa_explicit_bits + <span class="tok-number">1</span>);</span>
<span class="line" id="L96">    <span class="tok-kw">var</span> mantissa = d.round();</span>
<span class="line" id="L97">    <span class="tok-kw">if</span> (mantissa &gt;= (<span class="tok-builtin">@as</span>(MantissaT, <span class="tok-number">1</span>) &lt;&lt; (mantissa_explicit_bits + <span class="tok-number">1</span>))) {</span>
<span class="line" id="L98">        <span class="tok-comment">// Rounding up overflowed to the carry bit, need to</span>
</span>
<span class="line" id="L99">        <span class="tok-comment">// shift back to the hidden bit.</span>
</span>
<span class="line" id="L100">        d.rightShift(<span class="tok-number">1</span>);</span>
<span class="line" id="L101">        exp2 += <span class="tok-number">1</span>;</span>
<span class="line" id="L102">        mantissa = d.round();</span>
<span class="line" id="L103">        <span class="tok-kw">if</span> ((exp2 - min_exponent) &gt;= infinite_power) {</span>
<span class="line" id="L104">            <span class="tok-kw">return</span> BiasedFp(T).inf(T);</span>
<span class="line" id="L105">        }</span>
<span class="line" id="L106">    }</span>
<span class="line" id="L107">    <span class="tok-kw">var</span> power2 = exp2 - min_exponent;</span>
<span class="line" id="L108">    <span class="tok-kw">if</span> (mantissa &lt; (<span class="tok-builtin">@as</span>(MantissaT, <span class="tok-number">1</span>) &lt;&lt; mantissa_explicit_bits)) {</span>
<span class="line" id="L109">        power2 -= <span class="tok-number">1</span>;</span>
<span class="line" id="L110">    }</span>
<span class="line" id="L111">    <span class="tok-comment">// Zero out all the bits above the explicit mantissa bits.</span>
</span>
<span class="line" id="L112">    mantissa &amp;= (<span class="tok-builtin">@as</span>(MantissaT, <span class="tok-number">1</span>) &lt;&lt; mantissa_explicit_bits) - <span class="tok-number">1</span>;</span>
<span class="line" id="L113">    <span class="tok-kw">return</span> .{ .f = mantissa, .e = power2 };</span>
<span class="line" id="L114">}</span>
<span class="line" id="L115"></span>
</code></pre></body>
</html>