<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">    <title>rand/ziggurat.zig - source view</title>
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
<pre><code><span class="line" id="L1"><span class="tok-comment">//! Implements ZIGNOR [1].</span></span>
<span class="line" id="L2"><span class="tok-comment">//!</span></span>
<span class="line" id="L3"><span class="tok-comment">//! [1]: Jurgen A. Doornik (2005). [*An Improved Ziggurat Method to Generate Normal Random Samples*]</span></span>
<span class="line" id="L4"><span class="tok-comment">//! (https://www.doornik.com/research/ziggurat.pdf). Nuffield College, Oxford.</span></span>
<span class="line" id="L5"><span class="tok-comment">//!</span></span>
<span class="line" id="L6"><span class="tok-comment">//! rust/rand used as a reference;</span></span>
<span class="line" id="L7"><span class="tok-comment">//!</span></span>
<span class="line" id="L8"><span class="tok-comment">//! NOTE: This seems interesting but reference code is a bit hard to grok:</span></span>
<span class="line" id="L9"><span class="tok-comment">//! https://sbarral.github.io/etf.</span></span>
<span class="line" id="L10"></span>
<span class="line" id="L11"><span class="tok-kw">const</span> std = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;../std.zig&quot;</span>);</span>
<span class="line" id="L12"><span class="tok-kw">const</span> builtin = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;builtin&quot;</span>);</span>
<span class="line" id="L13"><span class="tok-kw">const</span> math = std.math;</span>
<span class="line" id="L14"><span class="tok-kw">const</span> Random = std.rand.Random;</span>
<span class="line" id="L15"></span>
<span class="line" id="L16"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">next_f64</span>(random: Random, <span class="tok-kw">comptime</span> tables: ZigTable) <span class="tok-type">f64</span> {</span>
<span class="line" id="L17">    <span class="tok-kw">while</span> (<span class="tok-null">true</span>) {</span>
<span class="line" id="L18">        <span class="tok-comment">// We manually construct a float from parts as we can avoid an extra random lookup here by</span>
</span>
<span class="line" id="L19">        <span class="tok-comment">// using the unused exponent for the lookup table entry.</span>
</span>
<span class="line" id="L20">        <span class="tok-kw">const</span> bits = random.int(<span class="tok-type">u64</span>);</span>
<span class="line" id="L21">        <span class="tok-kw">const</span> i = <span class="tok-builtin">@as</span>(<span class="tok-type">usize</span>, <span class="tok-builtin">@truncate</span>(<span class="tok-type">u8</span>, bits));</span>
<span class="line" id="L22"></span>
<span class="line" id="L23">        <span class="tok-kw">const</span> u = blk: {</span>
<span class="line" id="L24">            <span class="tok-kw">if</span> (tables.is_symmetric) {</span>
<span class="line" id="L25">                <span class="tok-comment">// Generate a value in the range [2, 4) and scale into [-1, 1)</span>
</span>
<span class="line" id="L26">                <span class="tok-kw">const</span> repr = ((<span class="tok-number">0x3ff</span> + <span class="tok-number">1</span>) &lt;&lt; <span class="tok-number">52</span>) | (bits &gt;&gt; <span class="tok-number">12</span>);</span>
<span class="line" id="L27">                <span class="tok-kw">break</span> :blk <span class="tok-builtin">@bitCast</span>(<span class="tok-type">f64</span>, repr) - <span class="tok-number">3.0</span>;</span>
<span class="line" id="L28">            } <span class="tok-kw">else</span> {</span>
<span class="line" id="L29">                <span class="tok-comment">// Generate a value in the range [1, 2) and scale into (0, 1)</span>
</span>
<span class="line" id="L30">                <span class="tok-kw">const</span> repr = (<span class="tok-number">0x3ff</span> &lt;&lt; <span class="tok-number">52</span>) | (bits &gt;&gt; <span class="tok-number">12</span>);</span>
<span class="line" id="L31">                <span class="tok-kw">break</span> :blk <span class="tok-builtin">@bitCast</span>(<span class="tok-type">f64</span>, repr) - (<span class="tok-number">1.0</span> - math.floatEps(<span class="tok-type">f64</span>) / <span class="tok-number">2.0</span>);</span>
<span class="line" id="L32">            }</span>
<span class="line" id="L33">        };</span>
<span class="line" id="L34"></span>
<span class="line" id="L35">        <span class="tok-kw">const</span> x = u * tables.x[i];</span>
<span class="line" id="L36">        <span class="tok-kw">const</span> test_x = <span class="tok-kw">if</span> (tables.is_symmetric) <span class="tok-builtin">@fabs</span>(x) <span class="tok-kw">else</span> x;</span>
<span class="line" id="L37"></span>
<span class="line" id="L38">        <span class="tok-comment">// equivalent to |u| &lt; tables.x[i+1] / tables.x[i] (or u &lt; tables.x[i+1] / tables.x[i])</span>
</span>
<span class="line" id="L39">        <span class="tok-kw">if</span> (test_x &lt; tables.x[i + <span class="tok-number">1</span>]) {</span>
<span class="line" id="L40">            <span class="tok-kw">return</span> x;</span>
<span class="line" id="L41">        }</span>
<span class="line" id="L42"></span>
<span class="line" id="L43">        <span class="tok-kw">if</span> (i == <span class="tok-number">0</span>) {</span>
<span class="line" id="L44">            <span class="tok-kw">return</span> tables.zero_case(random, u);</span>
<span class="line" id="L45">        }</span>
<span class="line" id="L46"></span>
<span class="line" id="L47">        <span class="tok-comment">// equivalent to f1 + DRanU() * (f0 - f1) &lt; 1</span>
</span>
<span class="line" id="L48">        <span class="tok-kw">if</span> (tables.f[i + <span class="tok-number">1</span>] + (tables.f[i] - tables.f[i + <span class="tok-number">1</span>]) * random.float(<span class="tok-type">f64</span>) &lt; tables.pdf(x)) {</span>
<span class="line" id="L49">            <span class="tok-kw">return</span> x;</span>
<span class="line" id="L50">        }</span>
<span class="line" id="L51">    }</span>
<span class="line" id="L52">}</span>
<span class="line" id="L53"></span>
<span class="line" id="L54"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> ZigTable = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L55">    r: <span class="tok-type">f64</span>,</span>
<span class="line" id="L56">    x: [<span class="tok-number">257</span>]<span class="tok-type">f64</span>,</span>
<span class="line" id="L57">    f: [<span class="tok-number">257</span>]<span class="tok-type">f64</span>,</span>
<span class="line" id="L58"></span>
<span class="line" id="L59">    <span class="tok-comment">// probability density function used as a fallback</span>
</span>
<span class="line" id="L60">    pdf: <span class="tok-kw">fn</span> (<span class="tok-type">f64</span>) <span class="tok-type">f64</span>,</span>
<span class="line" id="L61">    <span class="tok-comment">// whether the distribution is symmetric</span>
</span>
<span class="line" id="L62">    is_symmetric: <span class="tok-type">bool</span>,</span>
<span class="line" id="L63">    <span class="tok-comment">// fallback calculation in the case we are in the 0 block</span>
</span>
<span class="line" id="L64">    zero_case: <span class="tok-kw">fn</span> (Random, <span class="tok-type">f64</span>) <span class="tok-type">f64</span>,</span>
<span class="line" id="L65">};</span>
<span class="line" id="L66"></span>
<span class="line" id="L67"><span class="tok-comment">// zigNorInit</span>
</span>
<span class="line" id="L68"><span class="tok-kw">fn</span> <span class="tok-fn">ZigTableGen</span>(</span>
<span class="line" id="L69">    <span class="tok-kw">comptime</span> is_symmetric: <span class="tok-type">bool</span>,</span>
<span class="line" id="L70">    <span class="tok-kw">comptime</span> r: <span class="tok-type">f64</span>,</span>
<span class="line" id="L71">    <span class="tok-kw">comptime</span> v: <span class="tok-type">f64</span>,</span>
<span class="line" id="L72">    <span class="tok-kw">comptime</span> f: <span class="tok-kw">fn</span> (<span class="tok-type">f64</span>) <span class="tok-type">f64</span>,</span>
<span class="line" id="L73">    <span class="tok-kw">comptime</span> f_inv: <span class="tok-kw">fn</span> (<span class="tok-type">f64</span>) <span class="tok-type">f64</span>,</span>
<span class="line" id="L74">    <span class="tok-kw">comptime</span> zero_case: <span class="tok-kw">fn</span> (Random, <span class="tok-type">f64</span>) <span class="tok-type">f64</span>,</span>
<span class="line" id="L75">) ZigTable {</span>
<span class="line" id="L76">    <span class="tok-kw">var</span> tables: ZigTable = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L77"></span>
<span class="line" id="L78">    tables.is_symmetric = is_symmetric;</span>
<span class="line" id="L79">    tables.r = r;</span>
<span class="line" id="L80">    tables.pdf = f;</span>
<span class="line" id="L81">    tables.zero_case = zero_case;</span>
<span class="line" id="L82"></span>
<span class="line" id="L83">    tables.x[<span class="tok-number">0</span>] = v / f(r);</span>
<span class="line" id="L84">    tables.x[<span class="tok-number">1</span>] = r;</span>
<span class="line" id="L85"></span>
<span class="line" id="L86">    <span class="tok-kw">for</span> (tables.x[<span class="tok-number">2</span>..<span class="tok-number">256</span>]) |*entry, i| {</span>
<span class="line" id="L87">        <span class="tok-kw">const</span> last = tables.x[<span class="tok-number">2</span> + i - <span class="tok-number">1</span>];</span>
<span class="line" id="L88">        entry.* = f_inv(v / last + f(last));</span>
<span class="line" id="L89">    }</span>
<span class="line" id="L90">    tables.x[<span class="tok-number">256</span>] = <span class="tok-number">0</span>;</span>
<span class="line" id="L91"></span>
<span class="line" id="L92">    <span class="tok-kw">for</span> (tables.f[<span class="tok-number">0</span>..]) |*entry, i| {</span>
<span class="line" id="L93">        entry.* = f(tables.x[i]);</span>
<span class="line" id="L94">    }</span>
<span class="line" id="L95"></span>
<span class="line" id="L96">    <span class="tok-kw">return</span> tables;</span>
<span class="line" id="L97">}</span>
<span class="line" id="L98"></span>
<span class="line" id="L99"><span class="tok-comment">// N(0, 1)</span>
</span>
<span class="line" id="L100"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> NormDist = blk: {</span>
<span class="line" id="L101">    <span class="tok-builtin">@setEvalBranchQuota</span>(<span class="tok-number">30000</span>);</span>
<span class="line" id="L102">    <span class="tok-kw">break</span> :blk ZigTableGen(<span class="tok-null">true</span>, norm_r, norm_v, norm_f, norm_f_inv, norm_zero_case);</span>
<span class="line" id="L103">};</span>
<span class="line" id="L104"></span>
<span class="line" id="L105"><span class="tok-kw">const</span> norm_r = <span class="tok-number">3.6541528853610088</span>;</span>
<span class="line" id="L106"><span class="tok-kw">const</span> norm_v = <span class="tok-number">0.00492867323399</span>;</span>
<span class="line" id="L107"></span>
<span class="line" id="L108"><span class="tok-kw">fn</span> <span class="tok-fn">norm_f</span>(x: <span class="tok-type">f64</span>) <span class="tok-type">f64</span> {</span>
<span class="line" id="L109">    <span class="tok-kw">return</span> <span class="tok-builtin">@exp</span>(-x * x / <span class="tok-number">2.0</span>);</span>
<span class="line" id="L110">}</span>
<span class="line" id="L111"><span class="tok-kw">fn</span> <span class="tok-fn">norm_f_inv</span>(y: <span class="tok-type">f64</span>) <span class="tok-type">f64</span> {</span>
<span class="line" id="L112">    <span class="tok-kw">return</span> <span class="tok-builtin">@sqrt</span>(-<span class="tok-number">2.0</span> * <span class="tok-builtin">@log</span>(y));</span>
<span class="line" id="L113">}</span>
<span class="line" id="L114"><span class="tok-kw">fn</span> <span class="tok-fn">norm_zero_case</span>(random: Random, u: <span class="tok-type">f64</span>) <span class="tok-type">f64</span> {</span>
<span class="line" id="L115">    <span class="tok-kw">var</span> x: <span class="tok-type">f64</span> = <span class="tok-number">1</span>;</span>
<span class="line" id="L116">    <span class="tok-kw">var</span> y: <span class="tok-type">f64</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L117"></span>
<span class="line" id="L118">    <span class="tok-kw">while</span> (-<span class="tok-number">2.0</span> * y &lt; x * x) {</span>
<span class="line" id="L119">        x = <span class="tok-builtin">@log</span>(random.float(<span class="tok-type">f64</span>)) / norm_r;</span>
<span class="line" id="L120">        y = <span class="tok-builtin">@log</span>(random.float(<span class="tok-type">f64</span>));</span>
<span class="line" id="L121">    }</span>
<span class="line" id="L122"></span>
<span class="line" id="L123">    <span class="tok-kw">if</span> (u &lt; <span class="tok-number">0</span>) {</span>
<span class="line" id="L124">        <span class="tok-kw">return</span> x - norm_r;</span>
<span class="line" id="L125">    } <span class="tok-kw">else</span> {</span>
<span class="line" id="L126">        <span class="tok-kw">return</span> norm_r - x;</span>
<span class="line" id="L127">    }</span>
<span class="line" id="L128">}</span>
<span class="line" id="L129"></span>
<span class="line" id="L130"><span class="tok-kw">const</span> please_windows_dont_oom = builtin.os.tag == .windows;</span>
<span class="line" id="L131"></span>
<span class="line" id="L132"><span class="tok-kw">test</span> <span class="tok-str">&quot;normal dist sanity&quot;</span> {</span>
<span class="line" id="L133">    <span class="tok-kw">if</span> (please_windows_dont_oom) <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SkipZigTest;</span>
<span class="line" id="L134"></span>
<span class="line" id="L135">    <span class="tok-kw">var</span> prng = std.rand.DefaultPrng.init(<span class="tok-number">0</span>);</span>
<span class="line" id="L136">    <span class="tok-kw">const</span> random = prng.random();</span>
<span class="line" id="L137"></span>
<span class="line" id="L138">    <span class="tok-kw">var</span> i: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L139">    <span class="tok-kw">while</span> (i &lt; <span class="tok-number">1000</span>) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L140">        _ = random.floatNorm(<span class="tok-type">f64</span>);</span>
<span class="line" id="L141">    }</span>
<span class="line" id="L142">}</span>
<span class="line" id="L143"></span>
<span class="line" id="L144"><span class="tok-comment">// Exp(1)</span>
</span>
<span class="line" id="L145"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> ExpDist = blk: {</span>
<span class="line" id="L146">    <span class="tok-builtin">@setEvalBranchQuota</span>(<span class="tok-number">30000</span>);</span>
<span class="line" id="L147">    <span class="tok-kw">break</span> :blk ZigTableGen(<span class="tok-null">false</span>, exp_r, exp_v, exp_f, exp_f_inv, exp_zero_case);</span>
<span class="line" id="L148">};</span>
<span class="line" id="L149"></span>
<span class="line" id="L150"><span class="tok-kw">const</span> exp_r = <span class="tok-number">7.69711747013104972</span>;</span>
<span class="line" id="L151"><span class="tok-kw">const</span> exp_v = <span class="tok-number">0.0039496598225815571993</span>;</span>
<span class="line" id="L152"></span>
<span class="line" id="L153"><span class="tok-kw">fn</span> <span class="tok-fn">exp_f</span>(x: <span class="tok-type">f64</span>) <span class="tok-type">f64</span> {</span>
<span class="line" id="L154">    <span class="tok-kw">return</span> <span class="tok-builtin">@exp</span>(-x);</span>
<span class="line" id="L155">}</span>
<span class="line" id="L156"><span class="tok-kw">fn</span> <span class="tok-fn">exp_f_inv</span>(y: <span class="tok-type">f64</span>) <span class="tok-type">f64</span> {</span>
<span class="line" id="L157">    <span class="tok-kw">return</span> -<span class="tok-builtin">@log</span>(y);</span>
<span class="line" id="L158">}</span>
<span class="line" id="L159"><span class="tok-kw">fn</span> <span class="tok-fn">exp_zero_case</span>(random: Random, _: <span class="tok-type">f64</span>) <span class="tok-type">f64</span> {</span>
<span class="line" id="L160">    <span class="tok-kw">return</span> exp_r - <span class="tok-builtin">@log</span>(random.float(<span class="tok-type">f64</span>));</span>
<span class="line" id="L161">}</span>
<span class="line" id="L162"></span>
<span class="line" id="L163"><span class="tok-kw">test</span> <span class="tok-str">&quot;exp dist sanity&quot;</span> {</span>
<span class="line" id="L164">    <span class="tok-kw">if</span> (please_windows_dont_oom) <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SkipZigTest;</span>
<span class="line" id="L165"></span>
<span class="line" id="L166">    <span class="tok-kw">var</span> prng = std.rand.DefaultPrng.init(<span class="tok-number">0</span>);</span>
<span class="line" id="L167">    <span class="tok-kw">const</span> random = prng.random();</span>
<span class="line" id="L168"></span>
<span class="line" id="L169">    <span class="tok-kw">var</span> i: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L170">    <span class="tok-kw">while</span> (i &lt; <span class="tok-number">1000</span>) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L171">        _ = random.floatExp(<span class="tok-type">f64</span>);</span>
<span class="line" id="L172">    }</span>
<span class="line" id="L173">}</span>
<span class="line" id="L174"></span>
<span class="line" id="L175"><span class="tok-kw">test</span> <span class="tok-str">&quot;table gen&quot;</span> {</span>
<span class="line" id="L176">    <span class="tok-kw">if</span> (please_windows_dont_oom) <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SkipZigTest;</span>
<span class="line" id="L177"></span>
<span class="line" id="L178">    _ = NormDist;</span>
<span class="line" id="L179">}</span>
<span class="line" id="L180"></span>
</code></pre></body>
</html>