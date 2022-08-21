<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">    <title>crypto/25519/field.zig - source view</title>
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
<span class="line" id="L3"><span class="tok-kw">const</span> readIntLittle = std.mem.readIntLittle;</span>
<span class="line" id="L4"><span class="tok-kw">const</span> writeIntLittle = std.mem.writeIntLittle;</span>
<span class="line" id="L5"></span>
<span class="line" id="L6"><span class="tok-kw">const</span> NonCanonicalError = crypto.errors.NonCanonicalError;</span>
<span class="line" id="L7"><span class="tok-kw">const</span> NotSquareError = crypto.errors.NotSquareError;</span>
<span class="line" id="L8"></span>
<span class="line" id="L9"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> Fe = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L10">    limbs: [<span class="tok-number">5</span>]<span class="tok-type">u64</span>,</span>
<span class="line" id="L11"></span>
<span class="line" id="L12">    <span class="tok-kw">const</span> MASK51: <span class="tok-type">u64</span> = <span class="tok-number">0x7ffffffffffff</span>;</span>
<span class="line" id="L13"></span>
<span class="line" id="L14">    <span class="tok-comment">/// 0</span></span>
<span class="line" id="L15">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> zero = Fe{ .limbs = .{ <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span> } };</span>
<span class="line" id="L16"></span>
<span class="line" id="L17">    <span class="tok-comment">/// 1</span></span>
<span class="line" id="L18">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> one = Fe{ .limbs = .{ <span class="tok-number">1</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span> } };</span>
<span class="line" id="L19"></span>
<span class="line" id="L20">    <span class="tok-comment">/// sqrt(-1)</span></span>
<span class="line" id="L21">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> sqrtm1 = Fe{ .limbs = .{ <span class="tok-number">1718705420411056</span>, <span class="tok-number">234908883556509</span>, <span class="tok-number">2233514472574048</span>, <span class="tok-number">2117202627021982</span>, <span class="tok-number">765476049583133</span> } };</span>
<span class="line" id="L22"></span>
<span class="line" id="L23">    <span class="tok-comment">/// The Curve25519 base point</span></span>
<span class="line" id="L24">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> curve25519BasePoint = Fe{ .limbs = .{ <span class="tok-number">9</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span> } };</span>
<span class="line" id="L25"></span>
<span class="line" id="L26">    <span class="tok-comment">/// Edwards25519 d = 37095705934669439343138083508754565189542113879843219016388785533085940283555</span></span>
<span class="line" id="L27">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> edwards25519d = Fe{ .limbs = .{ <span class="tok-number">929955233495203</span>, <span class="tok-number">466365720129213</span>, <span class="tok-number">1662059464998953</span>, <span class="tok-number">2033849074728123</span>, <span class="tok-number">1442794654840575</span> } };</span>
<span class="line" id="L28"></span>
<span class="line" id="L29">    <span class="tok-comment">/// Edwards25519 2d</span></span>
<span class="line" id="L30">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> edwards25519d2 = Fe{ .limbs = .{ <span class="tok-number">1859910466990425</span>, <span class="tok-number">932731440258426</span>, <span class="tok-number">1072319116312658</span>, <span class="tok-number">1815898335770999</span>, <span class="tok-number">633789495995903</span> } };</span>
<span class="line" id="L31"></span>
<span class="line" id="L32">    <span class="tok-comment">/// Edwards25519 1/sqrt(a-d)</span></span>
<span class="line" id="L33">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> edwards25519sqrtamd = Fe{ .limbs = .{ <span class="tok-number">278908739862762</span>, <span class="tok-number">821645201101625</span>, <span class="tok-number">8113234426968</span>, <span class="tok-number">1777959178193151</span>, <span class="tok-number">2118520810568447</span> } };</span>
<span class="line" id="L34"></span>
<span class="line" id="L35">    <span class="tok-comment">/// Edwards25519 1-d^2</span></span>
<span class="line" id="L36">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> edwards25519eonemsqd = Fe{ .limbs = .{ <span class="tok-number">1136626929484150</span>, <span class="tok-number">1998550399581263</span>, <span class="tok-number">496427632559748</span>, <span class="tok-number">118527312129759</span>, <span class="tok-number">45110755273534</span> } };</span>
<span class="line" id="L37"></span>
<span class="line" id="L38">    <span class="tok-comment">/// Edwards25519 (d-1)^2</span></span>
<span class="line" id="L39">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> edwards25519sqdmone = Fe{ .limbs = .{ <span class="tok-number">1507062230895904</span>, <span class="tok-number">1572317787530805</span>, <span class="tok-number">683053064812840</span>, <span class="tok-number">317374165784489</span>, <span class="tok-number">1572899562415810</span> } };</span>
<span class="line" id="L40"></span>
<span class="line" id="L41">    <span class="tok-comment">/// Edwards25519 sqrt(ad-1) with a = -1 (mod p)</span></span>
<span class="line" id="L42">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> edwards25519sqrtadm1 = Fe{ .limbs = .{ <span class="tok-number">2241493124984347</span>, <span class="tok-number">425987919032274</span>, <span class="tok-number">2207028919301688</span>, <span class="tok-number">1220490630685848</span>, <span class="tok-number">974799131293748</span> } };</span>
<span class="line" id="L43"></span>
<span class="line" id="L44">    <span class="tok-comment">/// Edwards25519 A, as a single limb</span></span>
<span class="line" id="L45">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> edwards25519a_32: <span class="tok-type">u32</span> = <span class="tok-number">486662</span>;</span>
<span class="line" id="L46"></span>
<span class="line" id="L47">    <span class="tok-comment">/// Edwards25519 A</span></span>
<span class="line" id="L48">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> edwards25519a = Fe{ .limbs = .{ <span class="tok-builtin">@as</span>(<span class="tok-type">u64</span>, edwards25519a_32), <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span> } };</span>
<span class="line" id="L49"></span>
<span class="line" id="L50">    <span class="tok-comment">/// Edwards25519 sqrt(A-2)</span></span>
<span class="line" id="L51">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> edwards25519sqrtam2 = Fe{ .limbs = .{ <span class="tok-number">1693982333959686</span>, <span class="tok-number">608509411481997</span>, <span class="tok-number">2235573344831311</span>, <span class="tok-number">947681270984193</span>, <span class="tok-number">266558006233600</span> } };</span>
<span class="line" id="L52"></span>
<span class="line" id="L53">    <span class="tok-comment">/// Return true if the field element is zero</span></span>
<span class="line" id="L54">    <span class="tok-kw">pub</span> <span class="tok-kw">inline</span> <span class="tok-kw">fn</span> <span class="tok-fn">isZero</span>(fe: Fe) <span class="tok-type">bool</span> {</span>
<span class="line" id="L55">        <span class="tok-kw">var</span> reduced = fe;</span>
<span class="line" id="L56">        reduced.reduce();</span>
<span class="line" id="L57">        <span class="tok-kw">const</span> limbs = reduced.limbs;</span>
<span class="line" id="L58">        <span class="tok-kw">return</span> (limbs[<span class="tok-number">0</span>] | limbs[<span class="tok-number">1</span>] | limbs[<span class="tok-number">2</span>] | limbs[<span class="tok-number">3</span>] | limbs[<span class="tok-number">4</span>]) == <span class="tok-number">0</span>;</span>
<span class="line" id="L59">    }</span>
<span class="line" id="L60"></span>
<span class="line" id="L61">    <span class="tok-comment">/// Return true if both field elements are equivalent</span></span>
<span class="line" id="L62">    <span class="tok-kw">pub</span> <span class="tok-kw">inline</span> <span class="tok-kw">fn</span> <span class="tok-fn">equivalent</span>(a: Fe, b: Fe) <span class="tok-type">bool</span> {</span>
<span class="line" id="L63">        <span class="tok-kw">return</span> a.sub(b).isZero();</span>
<span class="line" id="L64">    }</span>
<span class="line" id="L65"></span>
<span class="line" id="L66">    <span class="tok-comment">/// Unpack a field element</span></span>
<span class="line" id="L67">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">fromBytes</span>(s: [<span class="tok-number">32</span>]<span class="tok-type">u8</span>) Fe {</span>
<span class="line" id="L68">        <span class="tok-kw">var</span> fe: Fe = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L69">        fe.limbs[<span class="tok-number">0</span>] = readIntLittle(<span class="tok-type">u64</span>, s[<span class="tok-number">0</span>..<span class="tok-number">8</span>]) &amp; MASK51;</span>
<span class="line" id="L70">        fe.limbs[<span class="tok-number">1</span>] = (readIntLittle(<span class="tok-type">u64</span>, s[<span class="tok-number">6</span>..<span class="tok-number">14</span>]) &gt;&gt; <span class="tok-number">3</span>) &amp; MASK51;</span>
<span class="line" id="L71">        fe.limbs[<span class="tok-number">2</span>] = (readIntLittle(<span class="tok-type">u64</span>, s[<span class="tok-number">12</span>..<span class="tok-number">20</span>]) &gt;&gt; <span class="tok-number">6</span>) &amp; MASK51;</span>
<span class="line" id="L72">        fe.limbs[<span class="tok-number">3</span>] = (readIntLittle(<span class="tok-type">u64</span>, s[<span class="tok-number">19</span>..<span class="tok-number">27</span>]) &gt;&gt; <span class="tok-number">1</span>) &amp; MASK51;</span>
<span class="line" id="L73">        fe.limbs[<span class="tok-number">4</span>] = (readIntLittle(<span class="tok-type">u64</span>, s[<span class="tok-number">24</span>..<span class="tok-number">32</span>]) &gt;&gt; <span class="tok-number">12</span>) &amp; MASK51;</span>
<span class="line" id="L74"></span>
<span class="line" id="L75">        <span class="tok-kw">return</span> fe;</span>
<span class="line" id="L76">    }</span>
<span class="line" id="L77"></span>
<span class="line" id="L78">    <span class="tok-comment">/// Pack a field element</span></span>
<span class="line" id="L79">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">toBytes</span>(fe: Fe) [<span class="tok-number">32</span>]<span class="tok-type">u8</span> {</span>
<span class="line" id="L80">        <span class="tok-kw">var</span> reduced = fe;</span>
<span class="line" id="L81">        reduced.reduce();</span>
<span class="line" id="L82">        <span class="tok-kw">var</span> s: [<span class="tok-number">32</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L83">        writeIntLittle(<span class="tok-type">u64</span>, s[<span class="tok-number">0</span>..<span class="tok-number">8</span>], reduced.limbs[<span class="tok-number">0</span>] | (reduced.limbs[<span class="tok-number">1</span>] &lt;&lt; <span class="tok-number">51</span>));</span>
<span class="line" id="L84">        writeIntLittle(<span class="tok-type">u64</span>, s[<span class="tok-number">8</span>..<span class="tok-number">16</span>], (reduced.limbs[<span class="tok-number">1</span>] &gt;&gt; <span class="tok-number">13</span>) | (reduced.limbs[<span class="tok-number">2</span>] &lt;&lt; <span class="tok-number">38</span>));</span>
<span class="line" id="L85">        writeIntLittle(<span class="tok-type">u64</span>, s[<span class="tok-number">16</span>..<span class="tok-number">24</span>], (reduced.limbs[<span class="tok-number">2</span>] &gt;&gt; <span class="tok-number">26</span>) | (reduced.limbs[<span class="tok-number">3</span>] &lt;&lt; <span class="tok-number">25</span>));</span>
<span class="line" id="L86">        writeIntLittle(<span class="tok-type">u64</span>, s[<span class="tok-number">24</span>..<span class="tok-number">32</span>], (reduced.limbs[<span class="tok-number">3</span>] &gt;&gt; <span class="tok-number">39</span>) | (reduced.limbs[<span class="tok-number">4</span>] &lt;&lt; <span class="tok-number">12</span>));</span>
<span class="line" id="L87"></span>
<span class="line" id="L88">        <span class="tok-kw">return</span> s;</span>
<span class="line" id="L89">    }</span>
<span class="line" id="L90"></span>
<span class="line" id="L91">    <span class="tok-comment">/// Map a 64 bytes big endian string into a field element</span></span>
<span class="line" id="L92">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">fromBytes64</span>(s: [<span class="tok-number">64</span>]<span class="tok-type">u8</span>) Fe {</span>
<span class="line" id="L93">        <span class="tok-kw">var</span> fl: [<span class="tok-number">32</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L94">        <span class="tok-kw">var</span> gl: [<span class="tok-number">32</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L95">        <span class="tok-kw">var</span> i: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L96">        <span class="tok-kw">while</span> (i &lt; <span class="tok-number">32</span>) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L97">            fl[i] = s[<span class="tok-number">63</span> - i];</span>
<span class="line" id="L98">            gl[i] = s[<span class="tok-number">31</span> - i];</span>
<span class="line" id="L99">        }</span>
<span class="line" id="L100">        fl[<span class="tok-number">31</span>] &amp;= <span class="tok-number">0x7f</span>;</span>
<span class="line" id="L101">        gl[<span class="tok-number">31</span>] &amp;= <span class="tok-number">0x7f</span>;</span>
<span class="line" id="L102">        <span class="tok-kw">var</span> fe_f = fromBytes(fl);</span>
<span class="line" id="L103">        <span class="tok-kw">const</span> fe_g = fromBytes(gl);</span>
<span class="line" id="L104">        fe_f.limbs[<span class="tok-number">0</span>] += (s[<span class="tok-number">32</span>] &gt;&gt; <span class="tok-number">7</span>) * <span class="tok-number">19</span> + <span class="tok-builtin">@as</span>(<span class="tok-type">u10</span>, s[<span class="tok-number">0</span>] &gt;&gt; <span class="tok-number">7</span>) * <span class="tok-number">722</span>;</span>
<span class="line" id="L105">        i = <span class="tok-number">0</span>;</span>
<span class="line" id="L106">        <span class="tok-kw">while</span> (i &lt; <span class="tok-number">5</span>) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L107">            fe_f.limbs[i] += <span class="tok-number">38</span> * fe_g.limbs[i];</span>
<span class="line" id="L108">        }</span>
<span class="line" id="L109">        fe_f.reduce();</span>
<span class="line" id="L110">        <span class="tok-kw">return</span> fe_f;</span>
<span class="line" id="L111">    }</span>
<span class="line" id="L112"></span>
<span class="line" id="L113">    <span class="tok-comment">/// Reject non-canonical encodings of an element, possibly ignoring the top bit</span></span>
<span class="line" id="L114">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">rejectNonCanonical</span>(s: [<span class="tok-number">32</span>]<span class="tok-type">u8</span>, <span class="tok-kw">comptime</span> ignore_extra_bit: <span class="tok-type">bool</span>) NonCanonicalError!<span class="tok-type">void</span> {</span>
<span class="line" id="L115">        <span class="tok-kw">var</span> c: <span class="tok-type">u16</span> = (s[<span class="tok-number">31</span>] &amp; <span class="tok-number">0x7f</span>) ^ <span class="tok-number">0x7f</span>;</span>
<span class="line" id="L116">        <span class="tok-kw">comptime</span> <span class="tok-kw">var</span> i = <span class="tok-number">30</span>;</span>
<span class="line" id="L117">        <span class="tok-kw">inline</span> <span class="tok-kw">while</span> (i &gt; <span class="tok-number">0</span>) : (i -= <span class="tok-number">1</span>) {</span>
<span class="line" id="L118">            c |= s[i] ^ <span class="tok-number">0xff</span>;</span>
<span class="line" id="L119">        }</span>
<span class="line" id="L120">        c = (c -% <span class="tok-number">1</span>) &gt;&gt; <span class="tok-number">8</span>;</span>
<span class="line" id="L121">        <span class="tok-kw">const</span> d = (<span class="tok-builtin">@as</span>(<span class="tok-type">u16</span>, <span class="tok-number">0xed</span> - <span class="tok-number">1</span>) -% <span class="tok-builtin">@as</span>(<span class="tok-type">u16</span>, s[<span class="tok-number">0</span>])) &gt;&gt; <span class="tok-number">8</span>;</span>
<span class="line" id="L122">        <span class="tok-kw">const</span> x = <span class="tok-kw">if</span> (ignore_extra_bit) <span class="tok-number">0</span> <span class="tok-kw">else</span> s[<span class="tok-number">31</span>] &gt;&gt; <span class="tok-number">7</span>;</span>
<span class="line" id="L123">        <span class="tok-kw">if</span> ((((c &amp; d) | x) &amp; <span class="tok-number">1</span>) != <span class="tok-number">0</span>) {</span>
<span class="line" id="L124">            <span class="tok-kw">return</span> <span class="tok-kw">error</span>.NonCanonical;</span>
<span class="line" id="L125">        }</span>
<span class="line" id="L126">    }</span>
<span class="line" id="L127"></span>
<span class="line" id="L128">    <span class="tok-comment">/// Reduce a field element mod 2^255-19</span></span>
<span class="line" id="L129">    <span class="tok-kw">fn</span> <span class="tok-fn">reduce</span>(fe: *Fe) <span class="tok-type">void</span> {</span>
<span class="line" id="L130">        <span class="tok-kw">comptime</span> <span class="tok-kw">var</span> i = <span class="tok-number">0</span>;</span>
<span class="line" id="L131">        <span class="tok-kw">comptime</span> <span class="tok-kw">var</span> j = <span class="tok-number">0</span>;</span>
<span class="line" id="L132">        <span class="tok-kw">const</span> limbs = &amp;fe.limbs;</span>
<span class="line" id="L133">        <span class="tok-kw">inline</span> <span class="tok-kw">while</span> (j &lt; <span class="tok-number">2</span>) : (j += <span class="tok-number">1</span>) {</span>
<span class="line" id="L134">            i = <span class="tok-number">0</span>;</span>
<span class="line" id="L135">            <span class="tok-kw">inline</span> <span class="tok-kw">while</span> (i &lt; <span class="tok-number">4</span>) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L136">                limbs[i + <span class="tok-number">1</span>] += limbs[i] &gt;&gt; <span class="tok-number">51</span>;</span>
<span class="line" id="L137">                limbs[i] &amp;= MASK51;</span>
<span class="line" id="L138">            }</span>
<span class="line" id="L139">            limbs[<span class="tok-number">0</span>] += <span class="tok-number">19</span> * (limbs[<span class="tok-number">4</span>] &gt;&gt; <span class="tok-number">51</span>);</span>
<span class="line" id="L140">            limbs[<span class="tok-number">4</span>] &amp;= MASK51;</span>
<span class="line" id="L141">        }</span>
<span class="line" id="L142">        limbs[<span class="tok-number">0</span>] += <span class="tok-number">19</span>;</span>
<span class="line" id="L143">        i = <span class="tok-number">0</span>;</span>
<span class="line" id="L144">        <span class="tok-kw">inline</span> <span class="tok-kw">while</span> (i &lt; <span class="tok-number">4</span>) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L145">            limbs[i + <span class="tok-number">1</span>] += limbs[i] &gt;&gt; <span class="tok-number">51</span>;</span>
<span class="line" id="L146">            limbs[i] &amp;= MASK51;</span>
<span class="line" id="L147">        }</span>
<span class="line" id="L148">        limbs[<span class="tok-number">0</span>] += <span class="tok-number">19</span> * (limbs[<span class="tok-number">4</span>] &gt;&gt; <span class="tok-number">51</span>);</span>
<span class="line" id="L149">        limbs[<span class="tok-number">4</span>] &amp;= MASK51;</span>
<span class="line" id="L150"></span>
<span class="line" id="L151">        limbs[<span class="tok-number">0</span>] += <span class="tok-number">0x8000000000000</span> - <span class="tok-number">19</span>;</span>
<span class="line" id="L152">        limbs[<span class="tok-number">1</span>] += <span class="tok-number">0x8000000000000</span> - <span class="tok-number">1</span>;</span>
<span class="line" id="L153">        limbs[<span class="tok-number">2</span>] += <span class="tok-number">0x8000000000000</span> - <span class="tok-number">1</span>;</span>
<span class="line" id="L154">        limbs[<span class="tok-number">3</span>] += <span class="tok-number">0x8000000000000</span> - <span class="tok-number">1</span>;</span>
<span class="line" id="L155">        limbs[<span class="tok-number">4</span>] += <span class="tok-number">0x8000000000000</span> - <span class="tok-number">1</span>;</span>
<span class="line" id="L156"></span>
<span class="line" id="L157">        i = <span class="tok-number">0</span>;</span>
<span class="line" id="L158">        <span class="tok-kw">inline</span> <span class="tok-kw">while</span> (i &lt; <span class="tok-number">4</span>) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L159">            limbs[i + <span class="tok-number">1</span>] += limbs[i] &gt;&gt; <span class="tok-number">51</span>;</span>
<span class="line" id="L160">            limbs[i] &amp;= MASK51;</span>
<span class="line" id="L161">        }</span>
<span class="line" id="L162">        limbs[<span class="tok-number">4</span>] &amp;= MASK51;</span>
<span class="line" id="L163">    }</span>
<span class="line" id="L164"></span>
<span class="line" id="L165">    <span class="tok-comment">/// Add a field element</span></span>
<span class="line" id="L166">    <span class="tok-kw">pub</span> <span class="tok-kw">inline</span> <span class="tok-kw">fn</span> <span class="tok-fn">add</span>(a: Fe, b: Fe) Fe {</span>
<span class="line" id="L167">        <span class="tok-kw">var</span> fe: Fe = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L168">        <span class="tok-kw">comptime</span> <span class="tok-kw">var</span> i = <span class="tok-number">0</span>;</span>
<span class="line" id="L169">        <span class="tok-kw">inline</span> <span class="tok-kw">while</span> (i &lt; <span class="tok-number">5</span>) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L170">            fe.limbs[i] = a.limbs[i] + b.limbs[i];</span>
<span class="line" id="L171">        }</span>
<span class="line" id="L172">        <span class="tok-kw">return</span> fe;</span>
<span class="line" id="L173">    }</span>
<span class="line" id="L174"></span>
<span class="line" id="L175">    <span class="tok-comment">/// Substract a field element</span></span>
<span class="line" id="L176">    <span class="tok-kw">pub</span> <span class="tok-kw">inline</span> <span class="tok-kw">fn</span> <span class="tok-fn">sub</span>(a: Fe, b: Fe) Fe {</span>
<span class="line" id="L177">        <span class="tok-kw">var</span> fe = b;</span>
<span class="line" id="L178">        <span class="tok-kw">comptime</span> <span class="tok-kw">var</span> i = <span class="tok-number">0</span>;</span>
<span class="line" id="L179">        <span class="tok-kw">inline</span> <span class="tok-kw">while</span> (i &lt; <span class="tok-number">4</span>) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L180">            fe.limbs[i + <span class="tok-number">1</span>] += fe.limbs[i] &gt;&gt; <span class="tok-number">51</span>;</span>
<span class="line" id="L181">            fe.limbs[i] &amp;= MASK51;</span>
<span class="line" id="L182">        }</span>
<span class="line" id="L183">        fe.limbs[<span class="tok-number">0</span>] += <span class="tok-number">19</span> * (fe.limbs[<span class="tok-number">4</span>] &gt;&gt; <span class="tok-number">51</span>);</span>
<span class="line" id="L184">        fe.limbs[<span class="tok-number">4</span>] &amp;= MASK51;</span>
<span class="line" id="L185">        fe.limbs[<span class="tok-number">0</span>] = (a.limbs[<span class="tok-number">0</span>] + <span class="tok-number">0xfffffffffffda</span>) - fe.limbs[<span class="tok-number">0</span>];</span>
<span class="line" id="L186">        fe.limbs[<span class="tok-number">1</span>] = (a.limbs[<span class="tok-number">1</span>] + <span class="tok-number">0xffffffffffffe</span>) - fe.limbs[<span class="tok-number">1</span>];</span>
<span class="line" id="L187">        fe.limbs[<span class="tok-number">2</span>] = (a.limbs[<span class="tok-number">2</span>] + <span class="tok-number">0xffffffffffffe</span>) - fe.limbs[<span class="tok-number">2</span>];</span>
<span class="line" id="L188">        fe.limbs[<span class="tok-number">3</span>] = (a.limbs[<span class="tok-number">3</span>] + <span class="tok-number">0xffffffffffffe</span>) - fe.limbs[<span class="tok-number">3</span>];</span>
<span class="line" id="L189">        fe.limbs[<span class="tok-number">4</span>] = (a.limbs[<span class="tok-number">4</span>] + <span class="tok-number">0xffffffffffffe</span>) - fe.limbs[<span class="tok-number">4</span>];</span>
<span class="line" id="L190"></span>
<span class="line" id="L191">        <span class="tok-kw">return</span> fe;</span>
<span class="line" id="L192">    }</span>
<span class="line" id="L193"></span>
<span class="line" id="L194">    <span class="tok-comment">/// Negate a field element</span></span>
<span class="line" id="L195">    <span class="tok-kw">pub</span> <span class="tok-kw">inline</span> <span class="tok-kw">fn</span> <span class="tok-fn">neg</span>(a: Fe) Fe {</span>
<span class="line" id="L196">        <span class="tok-kw">return</span> zero.sub(a);</span>
<span class="line" id="L197">    }</span>
<span class="line" id="L198"></span>
<span class="line" id="L199">    <span class="tok-comment">/// Return true if a field element is negative</span></span>
<span class="line" id="L200">    <span class="tok-kw">pub</span> <span class="tok-kw">inline</span> <span class="tok-kw">fn</span> <span class="tok-fn">isNegative</span>(a: Fe) <span class="tok-type">bool</span> {</span>
<span class="line" id="L201">        <span class="tok-kw">return</span> (a.toBytes()[<span class="tok-number">0</span>] &amp; <span class="tok-number">1</span>) != <span class="tok-number">0</span>;</span>
<span class="line" id="L202">    }</span>
<span class="line" id="L203"></span>
<span class="line" id="L204">    <span class="tok-comment">/// Conditonally replace a field element with `a` if `c` is positive</span></span>
<span class="line" id="L205">    <span class="tok-kw">pub</span> <span class="tok-kw">inline</span> <span class="tok-kw">fn</span> <span class="tok-fn">cMov</span>(fe: *Fe, a: Fe, c: <span class="tok-type">u64</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L206">        <span class="tok-kw">const</span> mask: <span class="tok-type">u64</span> = <span class="tok-number">0</span> -% c;</span>
<span class="line" id="L207">        <span class="tok-kw">var</span> x = fe.*;</span>
<span class="line" id="L208">        <span class="tok-kw">comptime</span> <span class="tok-kw">var</span> i = <span class="tok-number">0</span>;</span>
<span class="line" id="L209">        <span class="tok-kw">inline</span> <span class="tok-kw">while</span> (i &lt; <span class="tok-number">5</span>) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L210">            x.limbs[i] ^= a.limbs[i];</span>
<span class="line" id="L211">        }</span>
<span class="line" id="L212">        i = <span class="tok-number">0</span>;</span>
<span class="line" id="L213">        <span class="tok-kw">inline</span> <span class="tok-kw">while</span> (i &lt; <span class="tok-number">5</span>) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L214">            x.limbs[i] &amp;= mask;</span>
<span class="line" id="L215">        }</span>
<span class="line" id="L216">        i = <span class="tok-number">0</span>;</span>
<span class="line" id="L217">        <span class="tok-kw">inline</span> <span class="tok-kw">while</span> (i &lt; <span class="tok-number">5</span>) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L218">            fe.limbs[i] ^= x.limbs[i];</span>
<span class="line" id="L219">        }</span>
<span class="line" id="L220">    }</span>
<span class="line" id="L221"></span>
<span class="line" id="L222">    <span class="tok-comment">/// Conditionally swap two pairs of field elements if `c` is positive</span></span>
<span class="line" id="L223">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">cSwap2</span>(a0: *Fe, b0: *Fe, a1: *Fe, b1: *Fe, c: <span class="tok-type">u64</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L224">        <span class="tok-kw">const</span> mask: <span class="tok-type">u64</span> = <span class="tok-number">0</span> -% c;</span>
<span class="line" id="L225">        <span class="tok-kw">var</span> x0 = a0.*;</span>
<span class="line" id="L226">        <span class="tok-kw">var</span> x1 = a1.*;</span>
<span class="line" id="L227">        <span class="tok-kw">comptime</span> <span class="tok-kw">var</span> i = <span class="tok-number">0</span>;</span>
<span class="line" id="L228">        <span class="tok-kw">inline</span> <span class="tok-kw">while</span> (i &lt; <span class="tok-number">5</span>) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L229">            x0.limbs[i] ^= b0.limbs[i];</span>
<span class="line" id="L230">            x1.limbs[i] ^= b1.limbs[i];</span>
<span class="line" id="L231">        }</span>
<span class="line" id="L232">        i = <span class="tok-number">0</span>;</span>
<span class="line" id="L233">        <span class="tok-kw">inline</span> <span class="tok-kw">while</span> (i &lt; <span class="tok-number">5</span>) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L234">            x0.limbs[i] &amp;= mask;</span>
<span class="line" id="L235">            x1.limbs[i] &amp;= mask;</span>
<span class="line" id="L236">        }</span>
<span class="line" id="L237">        i = <span class="tok-number">0</span>;</span>
<span class="line" id="L238">        <span class="tok-kw">inline</span> <span class="tok-kw">while</span> (i &lt; <span class="tok-number">5</span>) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L239">            a0.limbs[i] ^= x0.limbs[i];</span>
<span class="line" id="L240">            b0.limbs[i] ^= x0.limbs[i];</span>
<span class="line" id="L241">            a1.limbs[i] ^= x1.limbs[i];</span>
<span class="line" id="L242">            b1.limbs[i] ^= x1.limbs[i];</span>
<span class="line" id="L243">        }</span>
<span class="line" id="L244">    }</span>
<span class="line" id="L245"></span>
<span class="line" id="L246">    <span class="tok-kw">inline</span> <span class="tok-kw">fn</span> <span class="tok-fn">_carry128</span>(r: *[<span class="tok-number">5</span>]<span class="tok-type">u128</span>) Fe {</span>
<span class="line" id="L247">        <span class="tok-kw">var</span> rs: [<span class="tok-number">5</span>]<span class="tok-type">u64</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L248">        <span class="tok-kw">comptime</span> <span class="tok-kw">var</span> i = <span class="tok-number">0</span>;</span>
<span class="line" id="L249">        <span class="tok-kw">inline</span> <span class="tok-kw">while</span> (i &lt; <span class="tok-number">4</span>) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L250">            rs[i] = <span class="tok-builtin">@truncate</span>(<span class="tok-type">u64</span>, r[i]) &amp; MASK51;</span>
<span class="line" id="L251">            r[i + <span class="tok-number">1</span>] += <span class="tok-builtin">@intCast</span>(<span class="tok-type">u64</span>, r[i] &gt;&gt; <span class="tok-number">51</span>);</span>
<span class="line" id="L252">        }</span>
<span class="line" id="L253">        rs[<span class="tok-number">4</span>] = <span class="tok-builtin">@truncate</span>(<span class="tok-type">u64</span>, r[<span class="tok-number">4</span>]) &amp; MASK51;</span>
<span class="line" id="L254">        <span class="tok-kw">var</span> carry = <span class="tok-builtin">@intCast</span>(<span class="tok-type">u64</span>, r[<span class="tok-number">4</span>] &gt;&gt; <span class="tok-number">51</span>);</span>
<span class="line" id="L255">        rs[<span class="tok-number">0</span>] += <span class="tok-number">19</span> * carry;</span>
<span class="line" id="L256">        carry = rs[<span class="tok-number">0</span>] &gt;&gt; <span class="tok-number">51</span>;</span>
<span class="line" id="L257">        rs[<span class="tok-number">0</span>] &amp;= MASK51;</span>
<span class="line" id="L258">        rs[<span class="tok-number">1</span>] += carry;</span>
<span class="line" id="L259">        carry = rs[<span class="tok-number">1</span>] &gt;&gt; <span class="tok-number">51</span>;</span>
<span class="line" id="L260">        rs[<span class="tok-number">1</span>] &amp;= MASK51;</span>
<span class="line" id="L261">        rs[<span class="tok-number">2</span>] += carry;</span>
<span class="line" id="L262"></span>
<span class="line" id="L263">        <span class="tok-kw">return</span> .{ .limbs = rs };</span>
<span class="line" id="L264">    }</span>
<span class="line" id="L265"></span>
<span class="line" id="L266">    <span class="tok-comment">/// Multiply two field elements</span></span>
<span class="line" id="L267">    <span class="tok-kw">pub</span> <span class="tok-kw">inline</span> <span class="tok-kw">fn</span> <span class="tok-fn">mul</span>(a: Fe, b: Fe) Fe {</span>
<span class="line" id="L268">        <span class="tok-kw">var</span> ax: [<span class="tok-number">5</span>]<span class="tok-type">u128</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L269">        <span class="tok-kw">var</span> bx: [<span class="tok-number">5</span>]<span class="tok-type">u128</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L270">        <span class="tok-kw">var</span> a19: [<span class="tok-number">5</span>]<span class="tok-type">u128</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L271">        <span class="tok-kw">var</span> r: [<span class="tok-number">5</span>]<span class="tok-type">u128</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L272">        <span class="tok-kw">comptime</span> <span class="tok-kw">var</span> i = <span class="tok-number">0</span>;</span>
<span class="line" id="L273">        <span class="tok-kw">inline</span> <span class="tok-kw">while</span> (i &lt; <span class="tok-number">5</span>) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L274">            ax[i] = <span class="tok-builtin">@intCast</span>(<span class="tok-type">u128</span>, a.limbs[i]);</span>
<span class="line" id="L275">            bx[i] = <span class="tok-builtin">@intCast</span>(<span class="tok-type">u128</span>, b.limbs[i]);</span>
<span class="line" id="L276">        }</span>
<span class="line" id="L277">        i = <span class="tok-number">1</span>;</span>
<span class="line" id="L278">        <span class="tok-kw">inline</span> <span class="tok-kw">while</span> (i &lt; <span class="tok-number">5</span>) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L279">            a19[i] = <span class="tok-number">19</span> * ax[i];</span>
<span class="line" id="L280">        }</span>
<span class="line" id="L281">        r[<span class="tok-number">0</span>] = ax[<span class="tok-number">0</span>] * bx[<span class="tok-number">0</span>] + a19[<span class="tok-number">1</span>] * bx[<span class="tok-number">4</span>] + a19[<span class="tok-number">2</span>] * bx[<span class="tok-number">3</span>] + a19[<span class="tok-number">3</span>] * bx[<span class="tok-number">2</span>] + a19[<span class="tok-number">4</span>] * bx[<span class="tok-number">1</span>];</span>
<span class="line" id="L282">        r[<span class="tok-number">1</span>] = ax[<span class="tok-number">0</span>] * bx[<span class="tok-number">1</span>] + ax[<span class="tok-number">1</span>] * bx[<span class="tok-number">0</span>] + a19[<span class="tok-number">2</span>] * bx[<span class="tok-number">4</span>] + a19[<span class="tok-number">3</span>] * bx[<span class="tok-number">3</span>] + a19[<span class="tok-number">4</span>] * bx[<span class="tok-number">2</span>];</span>
<span class="line" id="L283">        r[<span class="tok-number">2</span>] = ax[<span class="tok-number">0</span>] * bx[<span class="tok-number">2</span>] + ax[<span class="tok-number">1</span>] * bx[<span class="tok-number">1</span>] + ax[<span class="tok-number">2</span>] * bx[<span class="tok-number">0</span>] + a19[<span class="tok-number">3</span>] * bx[<span class="tok-number">4</span>] + a19[<span class="tok-number">4</span>] * bx[<span class="tok-number">3</span>];</span>
<span class="line" id="L284">        r[<span class="tok-number">3</span>] = ax[<span class="tok-number">0</span>] * bx[<span class="tok-number">3</span>] + ax[<span class="tok-number">1</span>] * bx[<span class="tok-number">2</span>] + ax[<span class="tok-number">2</span>] * bx[<span class="tok-number">1</span>] + ax[<span class="tok-number">3</span>] * bx[<span class="tok-number">0</span>] + a19[<span class="tok-number">4</span>] * bx[<span class="tok-number">4</span>];</span>
<span class="line" id="L285">        r[<span class="tok-number">4</span>] = ax[<span class="tok-number">0</span>] * bx[<span class="tok-number">4</span>] + ax[<span class="tok-number">1</span>] * bx[<span class="tok-number">3</span>] + ax[<span class="tok-number">2</span>] * bx[<span class="tok-number">2</span>] + ax[<span class="tok-number">3</span>] * bx[<span class="tok-number">1</span>] + ax[<span class="tok-number">4</span>] * bx[<span class="tok-number">0</span>];</span>
<span class="line" id="L286"></span>
<span class="line" id="L287">        <span class="tok-kw">return</span> _carry128(&amp;r);</span>
<span class="line" id="L288">    }</span>
<span class="line" id="L289"></span>
<span class="line" id="L290">    <span class="tok-kw">inline</span> <span class="tok-kw">fn</span> <span class="tok-fn">_sq</span>(a: Fe, <span class="tok-kw">comptime</span> double: <span class="tok-type">bool</span>) Fe {</span>
<span class="line" id="L291">        <span class="tok-kw">var</span> ax: [<span class="tok-number">5</span>]<span class="tok-type">u128</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L292">        <span class="tok-kw">var</span> r: [<span class="tok-number">5</span>]<span class="tok-type">u128</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L293">        <span class="tok-kw">comptime</span> <span class="tok-kw">var</span> i = <span class="tok-number">0</span>;</span>
<span class="line" id="L294">        <span class="tok-kw">inline</span> <span class="tok-kw">while</span> (i &lt; <span class="tok-number">5</span>) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L295">            ax[i] = <span class="tok-builtin">@intCast</span>(<span class="tok-type">u128</span>, a.limbs[i]);</span>
<span class="line" id="L296">        }</span>
<span class="line" id="L297">        <span class="tok-kw">const</span> a0_2 = <span class="tok-number">2</span> * ax[<span class="tok-number">0</span>];</span>
<span class="line" id="L298">        <span class="tok-kw">const</span> a1_2 = <span class="tok-number">2</span> * ax[<span class="tok-number">1</span>];</span>
<span class="line" id="L299">        <span class="tok-kw">const</span> a1_38 = <span class="tok-number">38</span> * ax[<span class="tok-number">1</span>];</span>
<span class="line" id="L300">        <span class="tok-kw">const</span> a2_38 = <span class="tok-number">38</span> * ax[<span class="tok-number">2</span>];</span>
<span class="line" id="L301">        <span class="tok-kw">const</span> a3_38 = <span class="tok-number">38</span> * ax[<span class="tok-number">3</span>];</span>
<span class="line" id="L302">        <span class="tok-kw">const</span> a3_19 = <span class="tok-number">19</span> * ax[<span class="tok-number">3</span>];</span>
<span class="line" id="L303">        <span class="tok-kw">const</span> a4_19 = <span class="tok-number">19</span> * ax[<span class="tok-number">4</span>];</span>
<span class="line" id="L304">        r[<span class="tok-number">0</span>] = ax[<span class="tok-number">0</span>] * ax[<span class="tok-number">0</span>] + a1_38 * ax[<span class="tok-number">4</span>] + a2_38 * ax[<span class="tok-number">3</span>];</span>
<span class="line" id="L305">        r[<span class="tok-number">1</span>] = a0_2 * ax[<span class="tok-number">1</span>] + a2_38 * ax[<span class="tok-number">4</span>] + a3_19 * ax[<span class="tok-number">3</span>];</span>
<span class="line" id="L306">        r[<span class="tok-number">2</span>] = a0_2 * ax[<span class="tok-number">2</span>] + ax[<span class="tok-number">1</span>] * ax[<span class="tok-number">1</span>] + a3_38 * ax[<span class="tok-number">4</span>];</span>
<span class="line" id="L307">        r[<span class="tok-number">3</span>] = a0_2 * ax[<span class="tok-number">3</span>] + a1_2 * ax[<span class="tok-number">2</span>] + a4_19 * ax[<span class="tok-number">4</span>];</span>
<span class="line" id="L308">        r[<span class="tok-number">4</span>] = a0_2 * ax[<span class="tok-number">4</span>] + a1_2 * ax[<span class="tok-number">3</span>] + ax[<span class="tok-number">2</span>] * ax[<span class="tok-number">2</span>];</span>
<span class="line" id="L309">        <span class="tok-kw">if</span> (double) {</span>
<span class="line" id="L310">            i = <span class="tok-number">0</span>;</span>
<span class="line" id="L311">            <span class="tok-kw">inline</span> <span class="tok-kw">while</span> (i &lt; <span class="tok-number">5</span>) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L312">                r[i] *= <span class="tok-number">2</span>;</span>
<span class="line" id="L313">            }</span>
<span class="line" id="L314">        }</span>
<span class="line" id="L315">        <span class="tok-kw">return</span> _carry128(&amp;r);</span>
<span class="line" id="L316">    }</span>
<span class="line" id="L317"></span>
<span class="line" id="L318">    <span class="tok-comment">/// Square a field element</span></span>
<span class="line" id="L319">    <span class="tok-kw">pub</span> <span class="tok-kw">inline</span> <span class="tok-kw">fn</span> <span class="tok-fn">sq</span>(a: Fe) Fe {</span>
<span class="line" id="L320">        <span class="tok-kw">return</span> _sq(a, <span class="tok-null">false</span>);</span>
<span class="line" id="L321">    }</span>
<span class="line" id="L322"></span>
<span class="line" id="L323">    <span class="tok-comment">/// Square and double a field element</span></span>
<span class="line" id="L324">    <span class="tok-kw">pub</span> <span class="tok-kw">inline</span> <span class="tok-kw">fn</span> <span class="tok-fn">sq2</span>(a: Fe) Fe {</span>
<span class="line" id="L325">        <span class="tok-kw">return</span> _sq(a, <span class="tok-null">true</span>);</span>
<span class="line" id="L326">    }</span>
<span class="line" id="L327"></span>
<span class="line" id="L328">    <span class="tok-comment">/// Multiply a field element with a small (32-bit) integer</span></span>
<span class="line" id="L329">    <span class="tok-kw">pub</span> <span class="tok-kw">inline</span> <span class="tok-kw">fn</span> <span class="tok-fn">mul32</span>(a: Fe, <span class="tok-kw">comptime</span> n: <span class="tok-type">u32</span>) Fe {</span>
<span class="line" id="L330">        <span class="tok-kw">const</span> sn = <span class="tok-builtin">@intCast</span>(<span class="tok-type">u128</span>, n);</span>
<span class="line" id="L331">        <span class="tok-kw">var</span> fe: Fe = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L332">        <span class="tok-kw">var</span> x: <span class="tok-type">u128</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L333">        <span class="tok-kw">comptime</span> <span class="tok-kw">var</span> i = <span class="tok-number">0</span>;</span>
<span class="line" id="L334">        <span class="tok-kw">inline</span> <span class="tok-kw">while</span> (i &lt; <span class="tok-number">5</span>) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L335">            x = a.limbs[i] * sn + (x &gt;&gt; <span class="tok-number">51</span>);</span>
<span class="line" id="L336">            fe.limbs[i] = <span class="tok-builtin">@truncate</span>(<span class="tok-type">u64</span>, x) &amp; MASK51;</span>
<span class="line" id="L337">        }</span>
<span class="line" id="L338">        fe.limbs[<span class="tok-number">0</span>] += <span class="tok-builtin">@intCast</span>(<span class="tok-type">u64</span>, x &gt;&gt; <span class="tok-number">51</span>) * <span class="tok-number">19</span>;</span>
<span class="line" id="L339"></span>
<span class="line" id="L340">        <span class="tok-kw">return</span> fe;</span>
<span class="line" id="L341">    }</span>
<span class="line" id="L342"></span>
<span class="line" id="L343">    <span class="tok-comment">/// Square a field element `n` times</span></span>
<span class="line" id="L344">    <span class="tok-kw">fn</span> <span class="tok-fn">sqn</span>(a: Fe, n: <span class="tok-type">usize</span>) Fe {</span>
<span class="line" id="L345">        <span class="tok-kw">var</span> i: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L346">        <span class="tok-kw">var</span> fe = a;</span>
<span class="line" id="L347">        <span class="tok-kw">while</span> (i &lt; n) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L348">            fe = fe.sq();</span>
<span class="line" id="L349">        }</span>
<span class="line" id="L350">        <span class="tok-kw">return</span> fe;</span>
<span class="line" id="L351">    }</span>
<span class="line" id="L352"></span>
<span class="line" id="L353">    <span class="tok-comment">/// Return the inverse of a field element, or 0 if a=0.</span></span>
<span class="line" id="L354">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">invert</span>(a: Fe) Fe {</span>
<span class="line" id="L355">        <span class="tok-kw">var</span> t0 = a.sq();</span>
<span class="line" id="L356">        <span class="tok-kw">var</span> t1 = t0.sqn(<span class="tok-number">2</span>).mul(a);</span>
<span class="line" id="L357">        t0 = t0.mul(t1);</span>
<span class="line" id="L358">        t1 = t1.mul(t0.sq());</span>
<span class="line" id="L359">        t1 = t1.mul(t1.sqn(<span class="tok-number">5</span>));</span>
<span class="line" id="L360">        <span class="tok-kw">var</span> t2 = t1.sqn(<span class="tok-number">10</span>).mul(t1);</span>
<span class="line" id="L361">        t2 = t2.mul(t2.sqn(<span class="tok-number">20</span>)).sqn(<span class="tok-number">10</span>);</span>
<span class="line" id="L362">        t1 = t1.mul(t2);</span>
<span class="line" id="L363">        t2 = t1.sqn(<span class="tok-number">50</span>).mul(t1);</span>
<span class="line" id="L364">        <span class="tok-kw">return</span> t1.mul(t2.mul(t2.sqn(<span class="tok-number">100</span>)).sqn(<span class="tok-number">50</span>)).sqn(<span class="tok-number">5</span>).mul(t0);</span>
<span class="line" id="L365">    }</span>
<span class="line" id="L366"></span>
<span class="line" id="L367">    <span class="tok-comment">/// Return a^((p-5)/8) = a^(2^252-3)</span></span>
<span class="line" id="L368">    <span class="tok-comment">/// Used to compute square roots since we have p=5 (mod 8); see Cohen and Frey.</span></span>
<span class="line" id="L369">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">pow2523</span>(a: Fe) Fe {</span>
<span class="line" id="L370">        <span class="tok-kw">var</span> t0 = a.mul(a.sq());</span>
<span class="line" id="L371">        <span class="tok-kw">var</span> t1 = t0.mul(t0.sqn(<span class="tok-number">2</span>)).sq().mul(a);</span>
<span class="line" id="L372">        t0 = t1.sqn(<span class="tok-number">5</span>).mul(t1);</span>
<span class="line" id="L373">        <span class="tok-kw">var</span> t2 = t0.sqn(<span class="tok-number">5</span>).mul(t1);</span>
<span class="line" id="L374">        t1 = t2.sqn(<span class="tok-number">15</span>).mul(t2);</span>
<span class="line" id="L375">        t2 = t1.sqn(<span class="tok-number">30</span>).mul(t1);</span>
<span class="line" id="L376">        t1 = t2.sqn(<span class="tok-number">60</span>).mul(t2);</span>
<span class="line" id="L377">        <span class="tok-kw">return</span> t1.sqn(<span class="tok-number">120</span>).mul(t1).sqn(<span class="tok-number">10</span>).mul(t0).sqn(<span class="tok-number">2</span>).mul(a);</span>
<span class="line" id="L378">    }</span>
<span class="line" id="L379"></span>
<span class="line" id="L380">    <span class="tok-comment">/// Return the absolute value of a field element</span></span>
<span class="line" id="L381">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">abs</span>(a: Fe) Fe {</span>
<span class="line" id="L382">        <span class="tok-kw">var</span> r = a;</span>
<span class="line" id="L383">        r.cMov(a.neg(), <span class="tok-builtin">@boolToInt</span>(a.isNegative()));</span>
<span class="line" id="L384">        <span class="tok-kw">return</span> r;</span>
<span class="line" id="L385">    }</span>
<span class="line" id="L386"></span>
<span class="line" id="L387">    <span class="tok-comment">/// Return true if the field element is a square</span></span>
<span class="line" id="L388">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">isSquare</span>(a: Fe) <span class="tok-type">bool</span> {</span>
<span class="line" id="L389">        <span class="tok-comment">// Compute the Jacobi symbol x^((p-1)/2)</span>
</span>
<span class="line" id="L390">        <span class="tok-kw">const</span> _11 = a.mul(a.sq());</span>
<span class="line" id="L391">        <span class="tok-kw">const</span> _1111 = _11.mul(_11.sq().sq());</span>
<span class="line" id="L392">        <span class="tok-kw">const</span> _11111111 = _1111.mul(_1111.sq().sq().sq().sq());</span>
<span class="line" id="L393">        <span class="tok-kw">const</span> u = _11111111.sqn(<span class="tok-number">2</span>).mul(_11);</span>
<span class="line" id="L394">        <span class="tok-kw">const</span> t = u.sqn(<span class="tok-number">10</span>).mul(u).sqn(<span class="tok-number">10</span>).mul(u);</span>
<span class="line" id="L395">        <span class="tok-kw">const</span> t2 = t.sqn(<span class="tok-number">30</span>).mul(t);</span>
<span class="line" id="L396">        <span class="tok-kw">const</span> t3 = t2.sqn(<span class="tok-number">60</span>).mul(t2);</span>
<span class="line" id="L397">        <span class="tok-kw">const</span> t4 = t3.sqn(<span class="tok-number">120</span>).mul(t3).sqn(<span class="tok-number">10</span>).mul(u).sqn(<span class="tok-number">3</span>).mul(_11).sq();</span>
<span class="line" id="L398">        <span class="tok-kw">return</span> <span class="tok-builtin">@bitCast</span>(<span class="tok-type">bool</span>, <span class="tok-builtin">@truncate</span>(<span class="tok-type">u1</span>, ~(t4.toBytes()[<span class="tok-number">1</span>] &amp; <span class="tok-number">1</span>)));</span>
<span class="line" id="L399">    }</span>
<span class="line" id="L400"></span>
<span class="line" id="L401">    <span class="tok-kw">fn</span> <span class="tok-fn">uncheckedSqrt</span>(x2: Fe) Fe {</span>
<span class="line" id="L402">        <span class="tok-kw">var</span> e = x2.pow2523();</span>
<span class="line" id="L403">        <span class="tok-kw">const</span> p_root = e.mul(x2); <span class="tok-comment">// positive root</span>
</span>
<span class="line" id="L404">        <span class="tok-kw">const</span> m_root = p_root.mul(Fe.sqrtm1); <span class="tok-comment">// negative root</span>
</span>
<span class="line" id="L405">        <span class="tok-kw">const</span> m_root2 = m_root.sq();</span>
<span class="line" id="L406">        e = x2.sub(m_root2);</span>
<span class="line" id="L407">        <span class="tok-kw">var</span> x = p_root;</span>
<span class="line" id="L408">        x.cMov(m_root, <span class="tok-builtin">@boolToInt</span>(e.isZero()));</span>
<span class="line" id="L409">        <span class="tok-kw">return</span> x;</span>
<span class="line" id="L410">    }</span>
<span class="line" id="L411"></span>
<span class="line" id="L412">    <span class="tok-comment">/// Compute the square root of `x2`, returning `error.NotSquare` if `x2` was not a square</span></span>
<span class="line" id="L413">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">sqrt</span>(x2: Fe) NotSquareError!Fe {</span>
<span class="line" id="L414">        <span class="tok-kw">var</span> x2_copy = x2;</span>
<span class="line" id="L415">        <span class="tok-kw">const</span> x = x2.uncheckedSqrt();</span>
<span class="line" id="L416">        <span class="tok-kw">const</span> check = x.sq().sub(x2_copy);</span>
<span class="line" id="L417">        <span class="tok-kw">if</span> (check.isZero()) {</span>
<span class="line" id="L418">            <span class="tok-kw">return</span> x;</span>
<span class="line" id="L419">        }</span>
<span class="line" id="L420">        <span class="tok-kw">return</span> <span class="tok-kw">error</span>.NotSquare;</span>
<span class="line" id="L421">    }</span>
<span class="line" id="L422">};</span>
<span class="line" id="L423"></span>
</code></pre></body>
</html>