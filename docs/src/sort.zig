<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">    <title>sort.zig - source view</title>
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
<pre><code><span class="line" id="L1"><span class="tok-kw">const</span> std = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;std.zig&quot;</span>);</span>
<span class="line" id="L2"><span class="tok-kw">const</span> assert = std.debug.assert;</span>
<span class="line" id="L3"><span class="tok-kw">const</span> testing = std.testing;</span>
<span class="line" id="L4"><span class="tok-kw">const</span> mem = std.mem;</span>
<span class="line" id="L5"><span class="tok-kw">const</span> math = std.math;</span>
<span class="line" id="L6"></span>
<span class="line" id="L7"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">binarySearch</span>(</span>
<span class="line" id="L8">    <span class="tok-kw">comptime</span> T: <span class="tok-type">type</span>,</span>
<span class="line" id="L9">    key: T,</span>
<span class="line" id="L10">    items: []<span class="tok-kw">const</span> T,</span>
<span class="line" id="L11">    context: <span class="tok-kw">anytype</span>,</span>
<span class="line" id="L12">    <span class="tok-kw">comptime</span> compareFn: <span class="tok-kw">fn</span> (context: <span class="tok-builtin">@TypeOf</span>(context), lhs: T, rhs: T) math.Order,</span>
<span class="line" id="L13">) ?<span class="tok-type">usize</span> {</span>
<span class="line" id="L14">    <span class="tok-kw">var</span> left: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L15">    <span class="tok-kw">var</span> right: <span class="tok-type">usize</span> = items.len;</span>
<span class="line" id="L16"></span>
<span class="line" id="L17">    <span class="tok-kw">while</span> (left &lt; right) {</span>
<span class="line" id="L18">        <span class="tok-comment">// Avoid overflowing in the midpoint calculation</span>
</span>
<span class="line" id="L19">        <span class="tok-kw">const</span> mid = left + (right - left) / <span class="tok-number">2</span>;</span>
<span class="line" id="L20">        <span class="tok-comment">// Compare the key with the midpoint element</span>
</span>
<span class="line" id="L21">        <span class="tok-kw">switch</span> (compareFn(context, key, items[mid])) {</span>
<span class="line" id="L22">            .eq =&gt; <span class="tok-kw">return</span> mid,</span>
<span class="line" id="L23">            .gt =&gt; left = mid + <span class="tok-number">1</span>,</span>
<span class="line" id="L24">            .lt =&gt; right = mid,</span>
<span class="line" id="L25">        }</span>
<span class="line" id="L26">    }</span>
<span class="line" id="L27"></span>
<span class="line" id="L28">    <span class="tok-kw">return</span> <span class="tok-null">null</span>;</span>
<span class="line" id="L29">}</span>
<span class="line" id="L30"></span>
<span class="line" id="L31"><span class="tok-kw">test</span> <span class="tok-str">&quot;binarySearch&quot;</span> {</span>
<span class="line" id="L32">    <span class="tok-kw">const</span> S = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L33">        <span class="tok-kw">fn</span> <span class="tok-fn">order_u32</span>(context: <span class="tok-type">void</span>, lhs: <span class="tok-type">u32</span>, rhs: <span class="tok-type">u32</span>) math.Order {</span>
<span class="line" id="L34">            _ = context;</span>
<span class="line" id="L35">            <span class="tok-kw">return</span> math.order(lhs, rhs);</span>
<span class="line" id="L36">        }</span>
<span class="line" id="L37">        <span class="tok-kw">fn</span> <span class="tok-fn">order_i32</span>(context: <span class="tok-type">void</span>, lhs: <span class="tok-type">i32</span>, rhs: <span class="tok-type">i32</span>) math.Order {</span>
<span class="line" id="L38">            _ = context;</span>
<span class="line" id="L39">            <span class="tok-kw">return</span> math.order(lhs, rhs);</span>
<span class="line" id="L40">        }</span>
<span class="line" id="L41">    };</span>
<span class="line" id="L42">    <span class="tok-kw">try</span> testing.expectEqual(</span>
<span class="line" id="L43">        <span class="tok-builtin">@as</span>(?<span class="tok-type">usize</span>, <span class="tok-null">null</span>),</span>
<span class="line" id="L44">        binarySearch(<span class="tok-type">u32</span>, <span class="tok-number">1</span>, &amp;[_]<span class="tok-type">u32</span>{}, {}, S.order_u32),</span>
<span class="line" id="L45">    );</span>
<span class="line" id="L46">    <span class="tok-kw">try</span> testing.expectEqual(</span>
<span class="line" id="L47">        <span class="tok-builtin">@as</span>(?<span class="tok-type">usize</span>, <span class="tok-number">0</span>),</span>
<span class="line" id="L48">        binarySearch(<span class="tok-type">u32</span>, <span class="tok-number">1</span>, &amp;[_]<span class="tok-type">u32</span>{<span class="tok-number">1</span>}, {}, S.order_u32),</span>
<span class="line" id="L49">    );</span>
<span class="line" id="L50">    <span class="tok-kw">try</span> testing.expectEqual(</span>
<span class="line" id="L51">        <span class="tok-builtin">@as</span>(?<span class="tok-type">usize</span>, <span class="tok-null">null</span>),</span>
<span class="line" id="L52">        binarySearch(<span class="tok-type">u32</span>, <span class="tok-number">1</span>, &amp;[_]<span class="tok-type">u32</span>{<span class="tok-number">0</span>}, {}, S.order_u32),</span>
<span class="line" id="L53">    );</span>
<span class="line" id="L54">    <span class="tok-kw">try</span> testing.expectEqual(</span>
<span class="line" id="L55">        <span class="tok-builtin">@as</span>(?<span class="tok-type">usize</span>, <span class="tok-null">null</span>),</span>
<span class="line" id="L56">        binarySearch(<span class="tok-type">u32</span>, <span class="tok-number">0</span>, &amp;[_]<span class="tok-type">u32</span>{<span class="tok-number">1</span>}, {}, S.order_u32),</span>
<span class="line" id="L57">    );</span>
<span class="line" id="L58">    <span class="tok-kw">try</span> testing.expectEqual(</span>
<span class="line" id="L59">        <span class="tok-builtin">@as</span>(?<span class="tok-type">usize</span>, <span class="tok-number">4</span>),</span>
<span class="line" id="L60">        binarySearch(<span class="tok-type">u32</span>, <span class="tok-number">5</span>, &amp;[_]<span class="tok-type">u32</span>{ <span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">4</span>, <span class="tok-number">5</span> }, {}, S.order_u32),</span>
<span class="line" id="L61">    );</span>
<span class="line" id="L62">    <span class="tok-kw">try</span> testing.expectEqual(</span>
<span class="line" id="L63">        <span class="tok-builtin">@as</span>(?<span class="tok-type">usize</span>, <span class="tok-number">0</span>),</span>
<span class="line" id="L64">        binarySearch(<span class="tok-type">u32</span>, <span class="tok-number">2</span>, &amp;[_]<span class="tok-type">u32</span>{ <span class="tok-number">2</span>, <span class="tok-number">4</span>, <span class="tok-number">8</span>, <span class="tok-number">16</span>, <span class="tok-number">32</span>, <span class="tok-number">64</span> }, {}, S.order_u32),</span>
<span class="line" id="L65">    );</span>
<span class="line" id="L66">    <span class="tok-kw">try</span> testing.expectEqual(</span>
<span class="line" id="L67">        <span class="tok-builtin">@as</span>(?<span class="tok-type">usize</span>, <span class="tok-number">1</span>),</span>
<span class="line" id="L68">        binarySearch(<span class="tok-type">i32</span>, -<span class="tok-number">4</span>, &amp;[_]<span class="tok-type">i32</span>{ -<span class="tok-number">7</span>, -<span class="tok-number">4</span>, <span class="tok-number">0</span>, <span class="tok-number">9</span>, <span class="tok-number">10</span> }, {}, S.order_i32),</span>
<span class="line" id="L69">    );</span>
<span class="line" id="L70">    <span class="tok-kw">try</span> testing.expectEqual(</span>
<span class="line" id="L71">        <span class="tok-builtin">@as</span>(?<span class="tok-type">usize</span>, <span class="tok-number">3</span>),</span>
<span class="line" id="L72">        binarySearch(<span class="tok-type">i32</span>, <span class="tok-number">98</span>, &amp;[_]<span class="tok-type">i32</span>{ -<span class="tok-number">100</span>, -<span class="tok-number">25</span>, <span class="tok-number">2</span>, <span class="tok-number">98</span>, <span class="tok-number">99</span>, <span class="tok-number">100</span> }, {}, S.order_i32),</span>
<span class="line" id="L73">    );</span>
<span class="line" id="L74">}</span>
<span class="line" id="L75"></span>
<span class="line" id="L76"><span class="tok-comment">/// Stable in-place sort. O(n) best case, O(pow(n, 2)) worst case.</span></span>
<span class="line" id="L77"><span class="tok-comment">/// O(1) memory (no allocator required).</span></span>
<span class="line" id="L78"><span class="tok-comment">/// This can be expressed in terms of `insertionSortContext` but the glue</span></span>
<span class="line" id="L79"><span class="tok-comment">/// code is slightly longer than the direct implementation.</span></span>
<span class="line" id="L80"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">insertionSort</span>(</span>
<span class="line" id="L81">    <span class="tok-kw">comptime</span> T: <span class="tok-type">type</span>,</span>
<span class="line" id="L82">    items: []T,</span>
<span class="line" id="L83">    context: <span class="tok-kw">anytype</span>,</span>
<span class="line" id="L84">    <span class="tok-kw">comptime</span> lessThan: <span class="tok-kw">fn</span> (context: <span class="tok-builtin">@TypeOf</span>(context), lhs: T, rhs: T) <span class="tok-type">bool</span>,</span>
<span class="line" id="L85">) <span class="tok-type">void</span> {</span>
<span class="line" id="L86">    <span class="tok-kw">var</span> i: <span class="tok-type">usize</span> = <span class="tok-number">1</span>;</span>
<span class="line" id="L87">    <span class="tok-kw">while</span> (i &lt; items.len) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L88">        <span class="tok-kw">const</span> x = items[i];</span>
<span class="line" id="L89">        <span class="tok-kw">var</span> j: <span class="tok-type">usize</span> = i;</span>
<span class="line" id="L90">        <span class="tok-kw">while</span> (j &gt; <span class="tok-number">0</span> <span class="tok-kw">and</span> lessThan(context, x, items[j - <span class="tok-number">1</span>])) : (j -= <span class="tok-number">1</span>) {</span>
<span class="line" id="L91">            items[j] = items[j - <span class="tok-number">1</span>];</span>
<span class="line" id="L92">        }</span>
<span class="line" id="L93">        items[j] = x;</span>
<span class="line" id="L94">    }</span>
<span class="line" id="L95">}</span>
<span class="line" id="L96"></span>
<span class="line" id="L97"><span class="tok-comment">/// Stable in-place sort. O(n) best case, O(pow(n, 2)) worst case.</span></span>
<span class="line" id="L98"><span class="tok-comment">/// O(1) memory (no allocator required).</span></span>
<span class="line" id="L99"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">insertionSortContext</span>(len: <span class="tok-type">usize</span>, context: <span class="tok-kw">anytype</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L100">    <span class="tok-kw">var</span> i: <span class="tok-type">usize</span> = <span class="tok-number">1</span>;</span>
<span class="line" id="L101">    <span class="tok-kw">while</span> (i &lt; len) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L102">        <span class="tok-kw">var</span> j: <span class="tok-type">usize</span> = i;</span>
<span class="line" id="L103">        <span class="tok-kw">while</span> (j &gt; <span class="tok-number">0</span> <span class="tok-kw">and</span> context.lessThan(j, j - <span class="tok-number">1</span>)) : (j -= <span class="tok-number">1</span>) {</span>
<span class="line" id="L104">            context.swap(j, j - <span class="tok-number">1</span>);</span>
<span class="line" id="L105">        }</span>
<span class="line" id="L106">    }</span>
<span class="line" id="L107">}</span>
<span class="line" id="L108"></span>
<span class="line" id="L109"><span class="tok-kw">const</span> Range = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L110">    start: <span class="tok-type">usize</span>,</span>
<span class="line" id="L111">    end: <span class="tok-type">usize</span>,</span>
<span class="line" id="L112"></span>
<span class="line" id="L113">    <span class="tok-kw">fn</span> <span class="tok-fn">init</span>(start: <span class="tok-type">usize</span>, end: <span class="tok-type">usize</span>) Range {</span>
<span class="line" id="L114">        <span class="tok-kw">return</span> Range{</span>
<span class="line" id="L115">            .start = start,</span>
<span class="line" id="L116">            .end = end,</span>
<span class="line" id="L117">        };</span>
<span class="line" id="L118">    }</span>
<span class="line" id="L119"></span>
<span class="line" id="L120">    <span class="tok-kw">fn</span> <span class="tok-fn">length</span>(self: Range) <span class="tok-type">usize</span> {</span>
<span class="line" id="L121">        <span class="tok-kw">return</span> self.end - self.start;</span>
<span class="line" id="L122">    }</span>
<span class="line" id="L123">};</span>
<span class="line" id="L124"></span>
<span class="line" id="L125"><span class="tok-kw">const</span> Iterator = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L126">    size: <span class="tok-type">usize</span>,</span>
<span class="line" id="L127">    power_of_two: <span class="tok-type">usize</span>,</span>
<span class="line" id="L128">    numerator: <span class="tok-type">usize</span>,</span>
<span class="line" id="L129">    decimal: <span class="tok-type">usize</span>,</span>
<span class="line" id="L130">    denominator: <span class="tok-type">usize</span>,</span>
<span class="line" id="L131">    decimal_step: <span class="tok-type">usize</span>,</span>
<span class="line" id="L132">    numerator_step: <span class="tok-type">usize</span>,</span>
<span class="line" id="L133"></span>
<span class="line" id="L134">    <span class="tok-kw">fn</span> <span class="tok-fn">init</span>(size2: <span class="tok-type">usize</span>, min_level: <span class="tok-type">usize</span>) Iterator {</span>
<span class="line" id="L135">        <span class="tok-kw">const</span> power_of_two = math.floorPowerOfTwo(<span class="tok-type">usize</span>, size2);</span>
<span class="line" id="L136">        <span class="tok-kw">const</span> denominator = power_of_two / min_level;</span>
<span class="line" id="L137">        <span class="tok-kw">return</span> Iterator{</span>
<span class="line" id="L138">            .numerator = <span class="tok-number">0</span>,</span>
<span class="line" id="L139">            .decimal = <span class="tok-number">0</span>,</span>
<span class="line" id="L140">            .size = size2,</span>
<span class="line" id="L141">            .power_of_two = power_of_two,</span>
<span class="line" id="L142">            .denominator = denominator,</span>
<span class="line" id="L143">            .decimal_step = size2 / denominator,</span>
<span class="line" id="L144">            .numerator_step = size2 % denominator,</span>
<span class="line" id="L145">        };</span>
<span class="line" id="L146">    }</span>
<span class="line" id="L147"></span>
<span class="line" id="L148">    <span class="tok-kw">fn</span> <span class="tok-fn">begin</span>(self: *Iterator) <span class="tok-type">void</span> {</span>
<span class="line" id="L149">        self.numerator = <span class="tok-number">0</span>;</span>
<span class="line" id="L150">        self.decimal = <span class="tok-number">0</span>;</span>
<span class="line" id="L151">    }</span>
<span class="line" id="L152"></span>
<span class="line" id="L153">    <span class="tok-kw">fn</span> <span class="tok-fn">nextRange</span>(self: *Iterator) Range {</span>
<span class="line" id="L154">        <span class="tok-kw">const</span> start = self.decimal;</span>
<span class="line" id="L155"></span>
<span class="line" id="L156">        self.decimal += self.decimal_step;</span>
<span class="line" id="L157">        self.numerator += self.numerator_step;</span>
<span class="line" id="L158">        <span class="tok-kw">if</span> (self.numerator &gt;= self.denominator) {</span>
<span class="line" id="L159">            self.numerator -= self.denominator;</span>
<span class="line" id="L160">            self.decimal += <span class="tok-number">1</span>;</span>
<span class="line" id="L161">        }</span>
<span class="line" id="L162"></span>
<span class="line" id="L163">        <span class="tok-kw">return</span> Range{</span>
<span class="line" id="L164">            .start = start,</span>
<span class="line" id="L165">            .end = self.decimal,</span>
<span class="line" id="L166">        };</span>
<span class="line" id="L167">    }</span>
<span class="line" id="L168"></span>
<span class="line" id="L169">    <span class="tok-kw">fn</span> <span class="tok-fn">finished</span>(self: *Iterator) <span class="tok-type">bool</span> {</span>
<span class="line" id="L170">        <span class="tok-kw">return</span> self.decimal &gt;= self.size;</span>
<span class="line" id="L171">    }</span>
<span class="line" id="L172"></span>
<span class="line" id="L173">    <span class="tok-kw">fn</span> <span class="tok-fn">nextLevel</span>(self: *Iterator) <span class="tok-type">bool</span> {</span>
<span class="line" id="L174">        self.decimal_step += self.decimal_step;</span>
<span class="line" id="L175">        self.numerator_step += self.numerator_step;</span>
<span class="line" id="L176">        <span class="tok-kw">if</span> (self.numerator_step &gt;= self.denominator) {</span>
<span class="line" id="L177">            self.numerator_step -= self.denominator;</span>
<span class="line" id="L178">            self.decimal_step += <span class="tok-number">1</span>;</span>
<span class="line" id="L179">        }</span>
<span class="line" id="L180"></span>
<span class="line" id="L181">        <span class="tok-kw">return</span> (self.decimal_step &lt; self.size);</span>
<span class="line" id="L182">    }</span>
<span class="line" id="L183"></span>
<span class="line" id="L184">    <span class="tok-kw">fn</span> <span class="tok-fn">length</span>(self: *Iterator) <span class="tok-type">usize</span> {</span>
<span class="line" id="L185">        <span class="tok-kw">return</span> self.decimal_step;</span>
<span class="line" id="L186">    }</span>
<span class="line" id="L187">};</span>
<span class="line" id="L188"></span>
<span class="line" id="L189"><span class="tok-kw">const</span> Pull = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L190">    from: <span class="tok-type">usize</span>,</span>
<span class="line" id="L191">    to: <span class="tok-type">usize</span>,</span>
<span class="line" id="L192">    count: <span class="tok-type">usize</span>,</span>
<span class="line" id="L193">    range: Range,</span>
<span class="line" id="L194">};</span>
<span class="line" id="L195"></span>
<span class="line" id="L196"><span class="tok-comment">/// Stable in-place sort. O(n) best case, O(n*log(n)) worst case and average case.</span></span>
<span class="line" id="L197"><span class="tok-comment">/// O(1) memory (no allocator required).</span></span>
<span class="line" id="L198"><span class="tok-comment">/// Currently implemented as block sort.</span></span>
<span class="line" id="L199"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">sort</span>(</span>
<span class="line" id="L200">    <span class="tok-kw">comptime</span> T: <span class="tok-type">type</span>,</span>
<span class="line" id="L201">    items: []T,</span>
<span class="line" id="L202">    context: <span class="tok-kw">anytype</span>,</span>
<span class="line" id="L203">    <span class="tok-kw">comptime</span> lessThan: <span class="tok-kw">fn</span> (context: <span class="tok-builtin">@TypeOf</span>(context), lhs: T, rhs: T) <span class="tok-type">bool</span>,</span>
<span class="line" id="L204">) <span class="tok-type">void</span> {</span>
<span class="line" id="L205"></span>
<span class="line" id="L206">    <span class="tok-comment">// Implementation ported from https://github.com/BonzaiThePenguin/WikiSort/blob/master/WikiSort.c</span>
</span>
<span class="line" id="L207">    <span class="tok-kw">var</span> cache: [<span class="tok-number">512</span>]T = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L208"></span>
<span class="line" id="L209">    <span class="tok-kw">if</span> (items.len &lt; <span class="tok-number">4</span>) {</span>
<span class="line" id="L210">        <span class="tok-kw">if</span> (items.len == <span class="tok-number">3</span>) {</span>
<span class="line" id="L211">            <span class="tok-comment">// hard coded insertion sort</span>
</span>
<span class="line" id="L212">            <span class="tok-kw">if</span> (lessThan(context, items[<span class="tok-number">1</span>], items[<span class="tok-number">0</span>])) mem.swap(T, &amp;items[<span class="tok-number">0</span>], &amp;items[<span class="tok-number">1</span>]);</span>
<span class="line" id="L213">            <span class="tok-kw">if</span> (lessThan(context, items[<span class="tok-number">2</span>], items[<span class="tok-number">1</span>])) {</span>
<span class="line" id="L214">                mem.swap(T, &amp;items[<span class="tok-number">1</span>], &amp;items[<span class="tok-number">2</span>]);</span>
<span class="line" id="L215">                <span class="tok-kw">if</span> (lessThan(context, items[<span class="tok-number">1</span>], items[<span class="tok-number">0</span>])) mem.swap(T, &amp;items[<span class="tok-number">0</span>], &amp;items[<span class="tok-number">1</span>]);</span>
<span class="line" id="L216">            }</span>
<span class="line" id="L217">        } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (items.len == <span class="tok-number">2</span>) {</span>
<span class="line" id="L218">            <span class="tok-kw">if</span> (lessThan(context, items[<span class="tok-number">1</span>], items[<span class="tok-number">0</span>])) mem.swap(T, &amp;items[<span class="tok-number">0</span>], &amp;items[<span class="tok-number">1</span>]);</span>
<span class="line" id="L219">        }</span>
<span class="line" id="L220">        <span class="tok-kw">return</span>;</span>
<span class="line" id="L221">    }</span>
<span class="line" id="L222"></span>
<span class="line" id="L223">    <span class="tok-comment">// sort groups of 4-8 items at a time using an unstable sorting network,</span>
</span>
<span class="line" id="L224">    <span class="tok-comment">// but keep track of the original item orders to force it to be stable</span>
</span>
<span class="line" id="L225">    <span class="tok-comment">// http://pages.ripco.net/~jgamble/nw.html</span>
</span>
<span class="line" id="L226">    <span class="tok-kw">var</span> iterator = Iterator.init(items.len, <span class="tok-number">4</span>);</span>
<span class="line" id="L227">    <span class="tok-kw">while</span> (!iterator.finished()) {</span>
<span class="line" id="L228">        <span class="tok-kw">var</span> order = [_]<span class="tok-type">u8</span>{ <span class="tok-number">0</span>, <span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">4</span>, <span class="tok-number">5</span>, <span class="tok-number">6</span>, <span class="tok-number">7</span> };</span>
<span class="line" id="L229">        <span class="tok-kw">const</span> range = iterator.nextRange();</span>
<span class="line" id="L230"></span>
<span class="line" id="L231">        <span class="tok-kw">const</span> sliced_items = items[range.start..];</span>
<span class="line" id="L232">        <span class="tok-kw">switch</span> (range.length()) {</span>
<span class="line" id="L233">            <span class="tok-number">8</span> =&gt; {</span>
<span class="line" id="L234">                swap(T, sliced_items, context, lessThan, &amp;order, <span class="tok-number">0</span>, <span class="tok-number">1</span>);</span>
<span class="line" id="L235">                swap(T, sliced_items, context, lessThan, &amp;order, <span class="tok-number">2</span>, <span class="tok-number">3</span>);</span>
<span class="line" id="L236">                swap(T, sliced_items, context, lessThan, &amp;order, <span class="tok-number">4</span>, <span class="tok-number">5</span>);</span>
<span class="line" id="L237">                swap(T, sliced_items, context, lessThan, &amp;order, <span class="tok-number">6</span>, <span class="tok-number">7</span>);</span>
<span class="line" id="L238">                swap(T, sliced_items, context, lessThan, &amp;order, <span class="tok-number">0</span>, <span class="tok-number">2</span>);</span>
<span class="line" id="L239">                swap(T, sliced_items, context, lessThan, &amp;order, <span class="tok-number">1</span>, <span class="tok-number">3</span>);</span>
<span class="line" id="L240">                swap(T, sliced_items, context, lessThan, &amp;order, <span class="tok-number">4</span>, <span class="tok-number">6</span>);</span>
<span class="line" id="L241">                swap(T, sliced_items, context, lessThan, &amp;order, <span class="tok-number">5</span>, <span class="tok-number">7</span>);</span>
<span class="line" id="L242">                swap(T, sliced_items, context, lessThan, &amp;order, <span class="tok-number">1</span>, <span class="tok-number">2</span>);</span>
<span class="line" id="L243">                swap(T, sliced_items, context, lessThan, &amp;order, <span class="tok-number">5</span>, <span class="tok-number">6</span>);</span>
<span class="line" id="L244">                swap(T, sliced_items, context, lessThan, &amp;order, <span class="tok-number">0</span>, <span class="tok-number">4</span>);</span>
<span class="line" id="L245">                swap(T, sliced_items, context, lessThan, &amp;order, <span class="tok-number">3</span>, <span class="tok-number">7</span>);</span>
<span class="line" id="L246">                swap(T, sliced_items, context, lessThan, &amp;order, <span class="tok-number">1</span>, <span class="tok-number">5</span>);</span>
<span class="line" id="L247">                swap(T, sliced_items, context, lessThan, &amp;order, <span class="tok-number">2</span>, <span class="tok-number">6</span>);</span>
<span class="line" id="L248">                swap(T, sliced_items, context, lessThan, &amp;order, <span class="tok-number">1</span>, <span class="tok-number">4</span>);</span>
<span class="line" id="L249">                swap(T, sliced_items, context, lessThan, &amp;order, <span class="tok-number">3</span>, <span class="tok-number">6</span>);</span>
<span class="line" id="L250">                swap(T, sliced_items, context, lessThan, &amp;order, <span class="tok-number">2</span>, <span class="tok-number">4</span>);</span>
<span class="line" id="L251">                swap(T, sliced_items, context, lessThan, &amp;order, <span class="tok-number">3</span>, <span class="tok-number">5</span>);</span>
<span class="line" id="L252">                swap(T, sliced_items, context, lessThan, &amp;order, <span class="tok-number">3</span>, <span class="tok-number">4</span>);</span>
<span class="line" id="L253">            },</span>
<span class="line" id="L254">            <span class="tok-number">7</span> =&gt; {</span>
<span class="line" id="L255">                swap(T, sliced_items, context, lessThan, &amp;order, <span class="tok-number">1</span>, <span class="tok-number">2</span>);</span>
<span class="line" id="L256">                swap(T, sliced_items, context, lessThan, &amp;order, <span class="tok-number">3</span>, <span class="tok-number">4</span>);</span>
<span class="line" id="L257">                swap(T, sliced_items, context, lessThan, &amp;order, <span class="tok-number">5</span>, <span class="tok-number">6</span>);</span>
<span class="line" id="L258">                swap(T, sliced_items, context, lessThan, &amp;order, <span class="tok-number">0</span>, <span class="tok-number">2</span>);</span>
<span class="line" id="L259">                swap(T, sliced_items, context, lessThan, &amp;order, <span class="tok-number">3</span>, <span class="tok-number">5</span>);</span>
<span class="line" id="L260">                swap(T, sliced_items, context, lessThan, &amp;order, <span class="tok-number">4</span>, <span class="tok-number">6</span>);</span>
<span class="line" id="L261">                swap(T, sliced_items, context, lessThan, &amp;order, <span class="tok-number">0</span>, <span class="tok-number">1</span>);</span>
<span class="line" id="L262">                swap(T, sliced_items, context, lessThan, &amp;order, <span class="tok-number">4</span>, <span class="tok-number">5</span>);</span>
<span class="line" id="L263">                swap(T, sliced_items, context, lessThan, &amp;order, <span class="tok-number">2</span>, <span class="tok-number">6</span>);</span>
<span class="line" id="L264">                swap(T, sliced_items, context, lessThan, &amp;order, <span class="tok-number">0</span>, <span class="tok-number">4</span>);</span>
<span class="line" id="L265">                swap(T, sliced_items, context, lessThan, &amp;order, <span class="tok-number">1</span>, <span class="tok-number">5</span>);</span>
<span class="line" id="L266">                swap(T, sliced_items, context, lessThan, &amp;order, <span class="tok-number">0</span>, <span class="tok-number">3</span>);</span>
<span class="line" id="L267">                swap(T, sliced_items, context, lessThan, &amp;order, <span class="tok-number">2</span>, <span class="tok-number">5</span>);</span>
<span class="line" id="L268">                swap(T, sliced_items, context, lessThan, &amp;order, <span class="tok-number">1</span>, <span class="tok-number">3</span>);</span>
<span class="line" id="L269">                swap(T, sliced_items, context, lessThan, &amp;order, <span class="tok-number">2</span>, <span class="tok-number">4</span>);</span>
<span class="line" id="L270">                swap(T, sliced_items, context, lessThan, &amp;order, <span class="tok-number">2</span>, <span class="tok-number">3</span>);</span>
<span class="line" id="L271">            },</span>
<span class="line" id="L272">            <span class="tok-number">6</span> =&gt; {</span>
<span class="line" id="L273">                swap(T, sliced_items, context, lessThan, &amp;order, <span class="tok-number">1</span>, <span class="tok-number">2</span>);</span>
<span class="line" id="L274">                swap(T, sliced_items, context, lessThan, &amp;order, <span class="tok-number">4</span>, <span class="tok-number">5</span>);</span>
<span class="line" id="L275">                swap(T, sliced_items, context, lessThan, &amp;order, <span class="tok-number">0</span>, <span class="tok-number">2</span>);</span>
<span class="line" id="L276">                swap(T, sliced_items, context, lessThan, &amp;order, <span class="tok-number">3</span>, <span class="tok-number">5</span>);</span>
<span class="line" id="L277">                swap(T, sliced_items, context, lessThan, &amp;order, <span class="tok-number">0</span>, <span class="tok-number">1</span>);</span>
<span class="line" id="L278">                swap(T, sliced_items, context, lessThan, &amp;order, <span class="tok-number">3</span>, <span class="tok-number">4</span>);</span>
<span class="line" id="L279">                swap(T, sliced_items, context, lessThan, &amp;order, <span class="tok-number">2</span>, <span class="tok-number">5</span>);</span>
<span class="line" id="L280">                swap(T, sliced_items, context, lessThan, &amp;order, <span class="tok-number">0</span>, <span class="tok-number">3</span>);</span>
<span class="line" id="L281">                swap(T, sliced_items, context, lessThan, &amp;order, <span class="tok-number">1</span>, <span class="tok-number">4</span>);</span>
<span class="line" id="L282">                swap(T, sliced_items, context, lessThan, &amp;order, <span class="tok-number">2</span>, <span class="tok-number">4</span>);</span>
<span class="line" id="L283">                swap(T, sliced_items, context, lessThan, &amp;order, <span class="tok-number">1</span>, <span class="tok-number">3</span>);</span>
<span class="line" id="L284">                swap(T, sliced_items, context, lessThan, &amp;order, <span class="tok-number">2</span>, <span class="tok-number">3</span>);</span>
<span class="line" id="L285">            },</span>
<span class="line" id="L286">            <span class="tok-number">5</span> =&gt; {</span>
<span class="line" id="L287">                swap(T, sliced_items, context, lessThan, &amp;order, <span class="tok-number">0</span>, <span class="tok-number">1</span>);</span>
<span class="line" id="L288">                swap(T, sliced_items, context, lessThan, &amp;order, <span class="tok-number">3</span>, <span class="tok-number">4</span>);</span>
<span class="line" id="L289">                swap(T, sliced_items, context, lessThan, &amp;order, <span class="tok-number">2</span>, <span class="tok-number">4</span>);</span>
<span class="line" id="L290">                swap(T, sliced_items, context, lessThan, &amp;order, <span class="tok-number">2</span>, <span class="tok-number">3</span>);</span>
<span class="line" id="L291">                swap(T, sliced_items, context, lessThan, &amp;order, <span class="tok-number">1</span>, <span class="tok-number">4</span>);</span>
<span class="line" id="L292">                swap(T, sliced_items, context, lessThan, &amp;order, <span class="tok-number">0</span>, <span class="tok-number">3</span>);</span>
<span class="line" id="L293">                swap(T, sliced_items, context, lessThan, &amp;order, <span class="tok-number">0</span>, <span class="tok-number">2</span>);</span>
<span class="line" id="L294">                swap(T, sliced_items, context, lessThan, &amp;order, <span class="tok-number">1</span>, <span class="tok-number">3</span>);</span>
<span class="line" id="L295">                swap(T, sliced_items, context, lessThan, &amp;order, <span class="tok-number">1</span>, <span class="tok-number">2</span>);</span>
<span class="line" id="L296">            },</span>
<span class="line" id="L297">            <span class="tok-number">4</span> =&gt; {</span>
<span class="line" id="L298">                swap(T, sliced_items, context, lessThan, &amp;order, <span class="tok-number">0</span>, <span class="tok-number">1</span>);</span>
<span class="line" id="L299">                swap(T, sliced_items, context, lessThan, &amp;order, <span class="tok-number">2</span>, <span class="tok-number">3</span>);</span>
<span class="line" id="L300">                swap(T, sliced_items, context, lessThan, &amp;order, <span class="tok-number">0</span>, <span class="tok-number">2</span>);</span>
<span class="line" id="L301">                swap(T, sliced_items, context, lessThan, &amp;order, <span class="tok-number">1</span>, <span class="tok-number">3</span>);</span>
<span class="line" id="L302">                swap(T, sliced_items, context, lessThan, &amp;order, <span class="tok-number">1</span>, <span class="tok-number">2</span>);</span>
<span class="line" id="L303">            },</span>
<span class="line" id="L304">            <span class="tok-kw">else</span> =&gt; {},</span>
<span class="line" id="L305">        }</span>
<span class="line" id="L306">    }</span>
<span class="line" id="L307">    <span class="tok-kw">if</span> (items.len &lt; <span class="tok-number">8</span>) <span class="tok-kw">return</span>;</span>
<span class="line" id="L308"></span>
<span class="line" id="L309">    <span class="tok-comment">// then merge sort the higher levels, which can be 8-15, 16-31, 32-63, 64-127, etc.</span>
</span>
<span class="line" id="L310">    <span class="tok-kw">while</span> (<span class="tok-null">true</span>) {</span>
<span class="line" id="L311">        <span class="tok-comment">// if every A and B block will fit into the cache, use a special branch</span>
</span>
<span class="line" id="L312">        <span class="tok-comment">// specifically for merging with the cache</span>
</span>
<span class="line" id="L313">        <span class="tok-comment">// (we use &lt; rather than &lt;= since the block size might be one more than</span>
</span>
<span class="line" id="L314">        <span class="tok-comment">// iterator.length())</span>
</span>
<span class="line" id="L315">        <span class="tok-kw">if</span> (iterator.length() &lt; cache.len) {</span>
<span class="line" id="L316">            <span class="tok-comment">// if four subarrays fit into the cache, it's faster to merge both</span>
</span>
<span class="line" id="L317">            <span class="tok-comment">// pairs of subarrays into the cache,</span>
</span>
<span class="line" id="L318">            <span class="tok-comment">// then merge the two merged subarrays from the cache back into the original array</span>
</span>
<span class="line" id="L319">            <span class="tok-kw">if</span> ((iterator.length() + <span class="tok-number">1</span>) * <span class="tok-number">4</span> &lt;= cache.len <span class="tok-kw">and</span> iterator.length() * <span class="tok-number">4</span> &lt;= items.len) {</span>
<span class="line" id="L320">                iterator.begin();</span>
<span class="line" id="L321">                <span class="tok-kw">while</span> (!iterator.finished()) {</span>
<span class="line" id="L322">                    <span class="tok-comment">// merge A1 and B1 into the cache</span>
</span>
<span class="line" id="L323">                    <span class="tok-kw">var</span> A1 = iterator.nextRange();</span>
<span class="line" id="L324">                    <span class="tok-kw">var</span> B1 = iterator.nextRange();</span>
<span class="line" id="L325">                    <span class="tok-kw">var</span> A2 = iterator.nextRange();</span>
<span class="line" id="L326">                    <span class="tok-kw">var</span> B2 = iterator.nextRange();</span>
<span class="line" id="L327"></span>
<span class="line" id="L328">                    <span class="tok-kw">if</span> (lessThan(context, items[B1.end - <span class="tok-number">1</span>], items[A1.start])) {</span>
<span class="line" id="L329">                        <span class="tok-comment">// the two ranges are in reverse order, so copy them in reverse order into the cache</span>
</span>
<span class="line" id="L330">                        mem.copy(T, cache[B1.length()..], items[A1.start..A1.end]);</span>
<span class="line" id="L331">                        mem.copy(T, cache[<span class="tok-number">0</span>..], items[B1.start..B1.end]);</span>
<span class="line" id="L332">                    } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (lessThan(context, items[B1.start], items[A1.end - <span class="tok-number">1</span>])) {</span>
<span class="line" id="L333">                        <span class="tok-comment">// these two ranges weren't already in order, so merge them into the cache</span>
</span>
<span class="line" id="L334">                        mergeInto(T, items, A1, B1, context, lessThan, cache[<span class="tok-number">0</span>..]);</span>
<span class="line" id="L335">                    } <span class="tok-kw">else</span> {</span>
<span class="line" id="L336">                        <span class="tok-comment">// if A1, B1, A2, and B2 are all in order, skip doing anything else</span>
</span>
<span class="line" id="L337">                        <span class="tok-kw">if</span> (!lessThan(context, items[B2.start], items[A2.end - <span class="tok-number">1</span>]) <span class="tok-kw">and</span> !lessThan(context, items[A2.start], items[B1.end - <span class="tok-number">1</span>])) <span class="tok-kw">continue</span>;</span>
<span class="line" id="L338"></span>
<span class="line" id="L339">                        <span class="tok-comment">// copy A1 and B1 into the cache in the same order</span>
</span>
<span class="line" id="L340">                        mem.copy(T, cache[<span class="tok-number">0</span>..], items[A1.start..A1.end]);</span>
<span class="line" id="L341">                        mem.copy(T, cache[A1.length()..], items[B1.start..B1.end]);</span>
<span class="line" id="L342">                    }</span>
<span class="line" id="L343">                    A1 = Range.init(A1.start, B1.end);</span>
<span class="line" id="L344"></span>
<span class="line" id="L345">                    <span class="tok-comment">// merge A2 and B2 into the cache</span>
</span>
<span class="line" id="L346">                    <span class="tok-kw">if</span> (lessThan(context, items[B2.end - <span class="tok-number">1</span>], items[A2.start])) {</span>
<span class="line" id="L347">                        <span class="tok-comment">// the two ranges are in reverse order, so copy them in reverse order into the cache</span>
</span>
<span class="line" id="L348">                        mem.copy(T, cache[A1.length() + B2.length() ..], items[A2.start..A2.end]);</span>
<span class="line" id="L349">                        mem.copy(T, cache[A1.length()..], items[B2.start..B2.end]);</span>
<span class="line" id="L350">                    } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (lessThan(context, items[B2.start], items[A2.end - <span class="tok-number">1</span>])) {</span>
<span class="line" id="L351">                        <span class="tok-comment">// these two ranges weren't already in order, so merge them into the cache</span>
</span>
<span class="line" id="L352">                        mergeInto(T, items, A2, B2, context, lessThan, cache[A1.length()..]);</span>
<span class="line" id="L353">                    } <span class="tok-kw">else</span> {</span>
<span class="line" id="L354">                        <span class="tok-comment">// copy A2 and B2 into the cache in the same order</span>
</span>
<span class="line" id="L355">                        mem.copy(T, cache[A1.length()..], items[A2.start..A2.end]);</span>
<span class="line" id="L356">                        mem.copy(T, cache[A1.length() + A2.length() ..], items[B2.start..B2.end]);</span>
<span class="line" id="L357">                    }</span>
<span class="line" id="L358">                    A2 = Range.init(A2.start, B2.end);</span>
<span class="line" id="L359"></span>
<span class="line" id="L360">                    <span class="tok-comment">// merge A1 and A2 from the cache into the items</span>
</span>
<span class="line" id="L361">                    <span class="tok-kw">const</span> A3 = Range.init(<span class="tok-number">0</span>, A1.length());</span>
<span class="line" id="L362">                    <span class="tok-kw">const</span> B3 = Range.init(A1.length(), A1.length() + A2.length());</span>
<span class="line" id="L363"></span>
<span class="line" id="L364">                    <span class="tok-kw">if</span> (lessThan(context, cache[B3.end - <span class="tok-number">1</span>], cache[A3.start])) {</span>
<span class="line" id="L365">                        <span class="tok-comment">// the two ranges are in reverse order, so copy them in reverse order into the items</span>
</span>
<span class="line" id="L366">                        mem.copy(T, items[A1.start + A2.length() ..], cache[A3.start..A3.end]);</span>
<span class="line" id="L367">                        mem.copy(T, items[A1.start..], cache[B3.start..B3.end]);</span>
<span class="line" id="L368">                    } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (lessThan(context, cache[B3.start], cache[A3.end - <span class="tok-number">1</span>])) {</span>
<span class="line" id="L369">                        <span class="tok-comment">// these two ranges weren't already in order, so merge them back into the items</span>
</span>
<span class="line" id="L370">                        mergeInto(T, cache[<span class="tok-number">0</span>..], A3, B3, context, lessThan, items[A1.start..]);</span>
<span class="line" id="L371">                    } <span class="tok-kw">else</span> {</span>
<span class="line" id="L372">                        <span class="tok-comment">// copy A3 and B3 into the items in the same order</span>
</span>
<span class="line" id="L373">                        mem.copy(T, items[A1.start..], cache[A3.start..A3.end]);</span>
<span class="line" id="L374">                        mem.copy(T, items[A1.start + A1.length() ..], cache[B3.start..B3.end]);</span>
<span class="line" id="L375">                    }</span>
<span class="line" id="L376">                }</span>
<span class="line" id="L377"></span>
<span class="line" id="L378">                <span class="tok-comment">// we merged two levels at the same time, so we're done with this level already</span>
</span>
<span class="line" id="L379">                <span class="tok-comment">// (iterator.nextLevel() is called again at the bottom of this outer merge loop)</span>
</span>
<span class="line" id="L380">                _ = iterator.nextLevel();</span>
<span class="line" id="L381">            } <span class="tok-kw">else</span> {</span>
<span class="line" id="L382">                iterator.begin();</span>
<span class="line" id="L383">                <span class="tok-kw">while</span> (!iterator.finished()) {</span>
<span class="line" id="L384">                    <span class="tok-kw">var</span> A = iterator.nextRange();</span>
<span class="line" id="L385">                    <span class="tok-kw">var</span> B = iterator.nextRange();</span>
<span class="line" id="L386"></span>
<span class="line" id="L387">                    <span class="tok-kw">if</span> (lessThan(context, items[B.end - <span class="tok-number">1</span>], items[A.start])) {</span>
<span class="line" id="L388">                        <span class="tok-comment">// the two ranges are in reverse order, so a simple rotation should fix it</span>
</span>
<span class="line" id="L389">                        mem.rotate(T, items[A.start..B.end], A.length());</span>
<span class="line" id="L390">                    } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (lessThan(context, items[B.start], items[A.end - <span class="tok-number">1</span>])) {</span>
<span class="line" id="L391">                        <span class="tok-comment">// these two ranges weren't already in order, so we'll need to merge them!</span>
</span>
<span class="line" id="L392">                        mem.copy(T, cache[<span class="tok-number">0</span>..], items[A.start..A.end]);</span>
<span class="line" id="L393">                        mergeExternal(T, items, A, B, context, lessThan, cache[<span class="tok-number">0</span>..]);</span>
<span class="line" id="L394">                    }</span>
<span class="line" id="L395">                }</span>
<span class="line" id="L396">            }</span>
<span class="line" id="L397">        } <span class="tok-kw">else</span> {</span>
<span class="line" id="L398">            <span class="tok-comment">// this is where the in-place merge logic starts!</span>
</span>
<span class="line" id="L399">            <span class="tok-comment">// 1. pull out two internal buffers each containing √A unique values</span>
</span>
<span class="line" id="L400">            <span class="tok-comment">//    1a. adjust block_size and buffer_size if we couldn't find enough unique values</span>
</span>
<span class="line" id="L401">            <span class="tok-comment">// 2. loop over the A and B subarrays within this level of the merge sort</span>
</span>
<span class="line" id="L402">            <span class="tok-comment">// 3. break A and B into blocks of size 'block_size'</span>
</span>
<span class="line" id="L403">            <span class="tok-comment">// 4. &quot;tag&quot; each of the A blocks with values from the first internal buffer</span>
</span>
<span class="line" id="L404">            <span class="tok-comment">// 5. roll the A blocks through the B blocks and drop/rotate them where they belong</span>
</span>
<span class="line" id="L405">            <span class="tok-comment">// 6. merge each A block with any B values that follow, using the cache or the second internal buffer</span>
</span>
<span class="line" id="L406">            <span class="tok-comment">// 7. sort the second internal buffer if it exists</span>
</span>
<span class="line" id="L407">            <span class="tok-comment">// 8. redistribute the two internal buffers back into the items</span>
</span>
<span class="line" id="L408">            <span class="tok-kw">var</span> block_size: <span class="tok-type">usize</span> = math.sqrt(iterator.length());</span>
<span class="line" id="L409">            <span class="tok-kw">var</span> buffer_size = iterator.length() / block_size + <span class="tok-number">1</span>;</span>
<span class="line" id="L410"></span>
<span class="line" id="L411">            <span class="tok-comment">// as an optimization, we really only need to pull out the internal buffers once for each level of merges</span>
</span>
<span class="line" id="L412">            <span class="tok-comment">// after that we can reuse the same buffers over and over, then redistribute it when we're finished with this level</span>
</span>
<span class="line" id="L413">            <span class="tok-kw">var</span> A: Range = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L414">            <span class="tok-kw">var</span> B: Range = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L415">            <span class="tok-kw">var</span> index: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L416">            <span class="tok-kw">var</span> last: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L417">            <span class="tok-kw">var</span> count: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L418">            <span class="tok-kw">var</span> find: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L419">            <span class="tok-kw">var</span> start: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L420">            <span class="tok-kw">var</span> pull_index: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L421">            <span class="tok-kw">var</span> pull = [_]Pull{</span>
<span class="line" id="L422">                Pull{</span>
<span class="line" id="L423">                    .from = <span class="tok-number">0</span>,</span>
<span class="line" id="L424">                    .to = <span class="tok-number">0</span>,</span>
<span class="line" id="L425">                    .count = <span class="tok-number">0</span>,</span>
<span class="line" id="L426">                    .range = Range.init(<span class="tok-number">0</span>, <span class="tok-number">0</span>),</span>
<span class="line" id="L427">                },</span>
<span class="line" id="L428">                Pull{</span>
<span class="line" id="L429">                    .from = <span class="tok-number">0</span>,</span>
<span class="line" id="L430">                    .to = <span class="tok-number">0</span>,</span>
<span class="line" id="L431">                    .count = <span class="tok-number">0</span>,</span>
<span class="line" id="L432">                    .range = Range.init(<span class="tok-number">0</span>, <span class="tok-number">0</span>),</span>
<span class="line" id="L433">                },</span>
<span class="line" id="L434">            };</span>
<span class="line" id="L435"></span>
<span class="line" id="L436">            <span class="tok-kw">var</span> buffer1 = Range.init(<span class="tok-number">0</span>, <span class="tok-number">0</span>);</span>
<span class="line" id="L437">            <span class="tok-kw">var</span> buffer2 = Range.init(<span class="tok-number">0</span>, <span class="tok-number">0</span>);</span>
<span class="line" id="L438"></span>
<span class="line" id="L439">            <span class="tok-comment">// find two internal buffers of size 'buffer_size' each</span>
</span>
<span class="line" id="L440">            find = buffer_size + buffer_size;</span>
<span class="line" id="L441">            <span class="tok-kw">var</span> find_separately = <span class="tok-null">false</span>;</span>
<span class="line" id="L442"></span>
<span class="line" id="L443">            <span class="tok-kw">if</span> (block_size &lt;= cache.len) {</span>
<span class="line" id="L444">                <span class="tok-comment">// if every A block fits into the cache then we won't need the second internal buffer,</span>
</span>
<span class="line" id="L445">                <span class="tok-comment">// so we really only need to find 'buffer_size' unique values</span>
</span>
<span class="line" id="L446">                find = buffer_size;</span>
<span class="line" id="L447">            } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (find &gt; iterator.length()) {</span>
<span class="line" id="L448">                <span class="tok-comment">// we can't fit both buffers into the same A or B subarray, so find two buffers separately</span>
</span>
<span class="line" id="L449">                find = buffer_size;</span>
<span class="line" id="L450">                find_separately = <span class="tok-null">true</span>;</span>
<span class="line" id="L451">            }</span>
<span class="line" id="L452"></span>
<span class="line" id="L453">            <span class="tok-comment">// we need to find either a single contiguous space containing 2√A unique values (which will be split up into two buffers of size √A each),</span>
</span>
<span class="line" id="L454">            <span class="tok-comment">// or we need to find one buffer of &lt; 2√A unique values, and a second buffer of √A unique values,</span>
</span>
<span class="line" id="L455">            <span class="tok-comment">// OR if we couldn't find that many unique values, we need the largest possible buffer we can get</span>
</span>
<span class="line" id="L456"></span>
<span class="line" id="L457">            <span class="tok-comment">// in the case where it couldn't find a single buffer of at least √A unique values,</span>
</span>
<span class="line" id="L458">            <span class="tok-comment">// all of the Merge steps must be replaced by a different merge algorithm (MergeInPlace)</span>
</span>
<span class="line" id="L459">            iterator.begin();</span>
<span class="line" id="L460">            <span class="tok-kw">while</span> (!iterator.finished()) {</span>
<span class="line" id="L461">                A = iterator.nextRange();</span>
<span class="line" id="L462">                B = iterator.nextRange();</span>
<span class="line" id="L463"></span>
<span class="line" id="L464">                <span class="tok-comment">// just store information about where the values will be pulled from and to,</span>
</span>
<span class="line" id="L465">                <span class="tok-comment">// as well as how many values there are, to create the two internal buffers</span>
</span>
<span class="line" id="L466"></span>
<span class="line" id="L467">                <span class="tok-comment">// check A for the number of unique values we need to fill an internal buffer</span>
</span>
<span class="line" id="L468">                <span class="tok-comment">// these values will be pulled out to the start of A</span>
</span>
<span class="line" id="L469">                last = A.start;</span>
<span class="line" id="L470">                count = <span class="tok-number">1</span>;</span>
<span class="line" id="L471">                <span class="tok-kw">while</span> (count &lt; find) : ({</span>
<span class="line" id="L472">                    last = index;</span>
<span class="line" id="L473">                    count += <span class="tok-number">1</span>;</span>
<span class="line" id="L474">                }) {</span>
<span class="line" id="L475">                    index = findLastForward(T, items, items[last], Range.init(last + <span class="tok-number">1</span>, A.end), context, lessThan, find - count);</span>
<span class="line" id="L476">                    <span class="tok-kw">if</span> (index == A.end) <span class="tok-kw">break</span>;</span>
<span class="line" id="L477">                }</span>
<span class="line" id="L478">                index = last;</span>
<span class="line" id="L479"></span>
<span class="line" id="L480">                <span class="tok-kw">if</span> (count &gt;= buffer_size) {</span>
<span class="line" id="L481">                    <span class="tok-comment">// keep track of the range within the items where we'll need to &quot;pull out&quot; these values to create the internal buffer</span>
</span>
<span class="line" id="L482">                    pull[pull_index] = Pull{</span>
<span class="line" id="L483">                        .range = Range.init(A.start, B.end),</span>
<span class="line" id="L484">                        .count = count,</span>
<span class="line" id="L485">                        .from = index,</span>
<span class="line" id="L486">                        .to = A.start,</span>
<span class="line" id="L487">                    };</span>
<span class="line" id="L488">                    pull_index = <span class="tok-number">1</span>;</span>
<span class="line" id="L489"></span>
<span class="line" id="L490">                    <span class="tok-kw">if</span> (count == buffer_size + buffer_size) {</span>
<span class="line" id="L491">                        <span class="tok-comment">// we were able to find a single contiguous section containing 2√A unique values,</span>
</span>
<span class="line" id="L492">                        <span class="tok-comment">// so this section can be used to contain both of the internal buffers we'll need</span>
</span>
<span class="line" id="L493">                        buffer1 = Range.init(A.start, A.start + buffer_size);</span>
<span class="line" id="L494">                        buffer2 = Range.init(A.start + buffer_size, A.start + count);</span>
<span class="line" id="L495">                        <span class="tok-kw">break</span>;</span>
<span class="line" id="L496">                    } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (find == buffer_size + buffer_size) {</span>
<span class="line" id="L497">                        <span class="tok-comment">// we found a buffer that contains at least √A unique values, but did not contain the full 2√A unique values,</span>
</span>
<span class="line" id="L498">                        <span class="tok-comment">// so we still need to find a second separate buffer of at least √A unique values</span>
</span>
<span class="line" id="L499">                        buffer1 = Range.init(A.start, A.start + count);</span>
<span class="line" id="L500">                        find = buffer_size;</span>
<span class="line" id="L501">                    } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (block_size &lt;= cache.len) {</span>
<span class="line" id="L502">                        <span class="tok-comment">// we found the first and only internal buffer that we need, so we're done!</span>
</span>
<span class="line" id="L503">                        buffer1 = Range.init(A.start, A.start + count);</span>
<span class="line" id="L504">                        <span class="tok-kw">break</span>;</span>
<span class="line" id="L505">                    } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (find_separately) {</span>
<span class="line" id="L506">                        <span class="tok-comment">// found one buffer, but now find the other one</span>
</span>
<span class="line" id="L507">                        buffer1 = Range.init(A.start, A.start + count);</span>
<span class="line" id="L508">                        find_separately = <span class="tok-null">false</span>;</span>
<span class="line" id="L509">                    } <span class="tok-kw">else</span> {</span>
<span class="line" id="L510">                        <span class="tok-comment">// we found a second buffer in an 'A' subarray containing √A unique values, so we're done!</span>
</span>
<span class="line" id="L511">                        buffer2 = Range.init(A.start, A.start + count);</span>
<span class="line" id="L512">                        <span class="tok-kw">break</span>;</span>
<span class="line" id="L513">                    }</span>
<span class="line" id="L514">                } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (pull_index == <span class="tok-number">0</span> <span class="tok-kw">and</span> count &gt; buffer1.length()) {</span>
<span class="line" id="L515">                    <span class="tok-comment">// keep track of the largest buffer we were able to find</span>
</span>
<span class="line" id="L516">                    buffer1 = Range.init(A.start, A.start + count);</span>
<span class="line" id="L517">                    pull[pull_index] = Pull{</span>
<span class="line" id="L518">                        .range = Range.init(A.start, B.end),</span>
<span class="line" id="L519">                        .count = count,</span>
<span class="line" id="L520">                        .from = index,</span>
<span class="line" id="L521">                        .to = A.start,</span>
<span class="line" id="L522">                    };</span>
<span class="line" id="L523">                }</span>
<span class="line" id="L524"></span>
<span class="line" id="L525">                <span class="tok-comment">// check B for the number of unique values we need to fill an internal buffer</span>
</span>
<span class="line" id="L526">                <span class="tok-comment">// these values will be pulled out to the end of B</span>
</span>
<span class="line" id="L527">                last = B.end - <span class="tok-number">1</span>;</span>
<span class="line" id="L528">                count = <span class="tok-number">1</span>;</span>
<span class="line" id="L529">                <span class="tok-kw">while</span> (count &lt; find) : ({</span>
<span class="line" id="L530">                    last = index - <span class="tok-number">1</span>;</span>
<span class="line" id="L531">                    count += <span class="tok-number">1</span>;</span>
<span class="line" id="L532">                }) {</span>
<span class="line" id="L533">                    index = findFirstBackward(T, items, items[last], Range.init(B.start, last), context, lessThan, find - count);</span>
<span class="line" id="L534">                    <span class="tok-kw">if</span> (index == B.start) <span class="tok-kw">break</span>;</span>
<span class="line" id="L535">                }</span>
<span class="line" id="L536">                index = last;</span>
<span class="line" id="L537"></span>
<span class="line" id="L538">                <span class="tok-kw">if</span> (count &gt;= buffer_size) {</span>
<span class="line" id="L539">                    <span class="tok-comment">// keep track of the range within the items where we'll need to &quot;pull out&quot; these values to create the internal buffe</span>
</span>
<span class="line" id="L540">                    pull[pull_index] = Pull{</span>
<span class="line" id="L541">                        .range = Range.init(A.start, B.end),</span>
<span class="line" id="L542">                        .count = count,</span>
<span class="line" id="L543">                        .from = index,</span>
<span class="line" id="L544">                        .to = B.end,</span>
<span class="line" id="L545">                    };</span>
<span class="line" id="L546">                    pull_index = <span class="tok-number">1</span>;</span>
<span class="line" id="L547"></span>
<span class="line" id="L548">                    <span class="tok-kw">if</span> (count == buffer_size + buffer_size) {</span>
<span class="line" id="L549">                        <span class="tok-comment">// we were able to find a single contiguous section containing 2√A unique values,</span>
</span>
<span class="line" id="L550">                        <span class="tok-comment">// so this section can be used to contain both of the internal buffers we'll need</span>
</span>
<span class="line" id="L551">                        buffer1 = Range.init(B.end - count, B.end - buffer_size);</span>
<span class="line" id="L552">                        buffer2 = Range.init(B.end - buffer_size, B.end);</span>
<span class="line" id="L553">                        <span class="tok-kw">break</span>;</span>
<span class="line" id="L554">                    } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (find == buffer_size + buffer_size) {</span>
<span class="line" id="L555">                        <span class="tok-comment">// we found a buffer that contains at least √A unique values, but did not contain the full 2√A unique values,</span>
</span>
<span class="line" id="L556">                        <span class="tok-comment">// so we still need to find a second separate buffer of at least √A unique values</span>
</span>
<span class="line" id="L557">                        buffer1 = Range.init(B.end - count, B.end);</span>
<span class="line" id="L558">                        find = buffer_size;</span>
<span class="line" id="L559">                    } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (block_size &lt;= cache.len) {</span>
<span class="line" id="L560">                        <span class="tok-comment">// we found the first and only internal buffer that we need, so we're done!</span>
</span>
<span class="line" id="L561">                        buffer1 = Range.init(B.end - count, B.end);</span>
<span class="line" id="L562">                        <span class="tok-kw">break</span>;</span>
<span class="line" id="L563">                    } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (find_separately) {</span>
<span class="line" id="L564">                        <span class="tok-comment">// found one buffer, but now find the other one</span>
</span>
<span class="line" id="L565">                        buffer1 = Range.init(B.end - count, B.end);</span>
<span class="line" id="L566">                        find_separately = <span class="tok-null">false</span>;</span>
<span class="line" id="L567">                    } <span class="tok-kw">else</span> {</span>
<span class="line" id="L568">                        <span class="tok-comment">// buffer2 will be pulled out from a 'B' subarray, so if the first buffer was pulled out from the corresponding 'A' subarray,</span>
</span>
<span class="line" id="L569">                        <span class="tok-comment">// we need to adjust the end point for that A subarray so it knows to stop redistributing its values before reaching buffer2</span>
</span>
<span class="line" id="L570">                        <span class="tok-kw">if</span> (pull[<span class="tok-number">0</span>].range.start == A.start) pull[<span class="tok-number">0</span>].range.end -= pull[<span class="tok-number">1</span>].count;</span>
<span class="line" id="L571"></span>
<span class="line" id="L572">                        <span class="tok-comment">// we found a second buffer in an 'B' subarray containing √A unique values, so we're done!</span>
</span>
<span class="line" id="L573">                        buffer2 = Range.init(B.end - count, B.end);</span>
<span class="line" id="L574">                        <span class="tok-kw">break</span>;</span>
<span class="line" id="L575">                    }</span>
<span class="line" id="L576">                } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (pull_index == <span class="tok-number">0</span> <span class="tok-kw">and</span> count &gt; buffer1.length()) {</span>
<span class="line" id="L577">                    <span class="tok-comment">// keep track of the largest buffer we were able to find</span>
</span>
<span class="line" id="L578">                    buffer1 = Range.init(B.end - count, B.end);</span>
<span class="line" id="L579">                    pull[pull_index] = Pull{</span>
<span class="line" id="L580">                        .range = Range.init(A.start, B.end),</span>
<span class="line" id="L581">                        .count = count,</span>
<span class="line" id="L582">                        .from = index,</span>
<span class="line" id="L583">                        .to = B.end,</span>
<span class="line" id="L584">                    };</span>
<span class="line" id="L585">                }</span>
<span class="line" id="L586">            }</span>
<span class="line" id="L587"></span>
<span class="line" id="L588">            <span class="tok-comment">// pull out the two ranges so we can use them as internal buffers</span>
</span>
<span class="line" id="L589">            pull_index = <span class="tok-number">0</span>;</span>
<span class="line" id="L590">            <span class="tok-kw">while</span> (pull_index &lt; <span class="tok-number">2</span>) : (pull_index += <span class="tok-number">1</span>) {</span>
<span class="line" id="L591">                <span class="tok-kw">const</span> length = pull[pull_index].count;</span>
<span class="line" id="L592"></span>
<span class="line" id="L593">                <span class="tok-kw">if</span> (pull[pull_index].to &lt; pull[pull_index].from) {</span>
<span class="line" id="L594">                    <span class="tok-comment">// we're pulling the values out to the left, which means the start of an A subarray</span>
</span>
<span class="line" id="L595">                    index = pull[pull_index].from;</span>
<span class="line" id="L596">                    count = <span class="tok-number">1</span>;</span>
<span class="line" id="L597">                    <span class="tok-kw">while</span> (count &lt; length) : (count += <span class="tok-number">1</span>) {</span>
<span class="line" id="L598">                        index = findFirstBackward(T, items, items[index - <span class="tok-number">1</span>], Range.init(pull[pull_index].to, pull[pull_index].from - (count - <span class="tok-number">1</span>)), context, lessThan, length - count);</span>
<span class="line" id="L599">                        <span class="tok-kw">const</span> range = Range.init(index + <span class="tok-number">1</span>, pull[pull_index].from + <span class="tok-number">1</span>);</span>
<span class="line" id="L600">                        mem.rotate(T, items[range.start..range.end], range.length() - count);</span>
<span class="line" id="L601">                        pull[pull_index].from = index + count;</span>
<span class="line" id="L602">                    }</span>
<span class="line" id="L603">                } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (pull[pull_index].to &gt; pull[pull_index].from) {</span>
<span class="line" id="L604">                    <span class="tok-comment">// we're pulling values out to the right, which means the end of a B subarray</span>
</span>
<span class="line" id="L605">                    index = pull[pull_index].from + <span class="tok-number">1</span>;</span>
<span class="line" id="L606">                    count = <span class="tok-number">1</span>;</span>
<span class="line" id="L607">                    <span class="tok-kw">while</span> (count &lt; length) : (count += <span class="tok-number">1</span>) {</span>
<span class="line" id="L608">                        index = findLastForward(T, items, items[index], Range.init(index, pull[pull_index].to), context, lessThan, length - count);</span>
<span class="line" id="L609">                        <span class="tok-kw">const</span> range = Range.init(pull[pull_index].from, index - <span class="tok-number">1</span>);</span>
<span class="line" id="L610">                        mem.rotate(T, items[range.start..range.end], count);</span>
<span class="line" id="L611">                        pull[pull_index].from = index - <span class="tok-number">1</span> - count;</span>
<span class="line" id="L612">                    }</span>
<span class="line" id="L613">                }</span>
<span class="line" id="L614">            }</span>
<span class="line" id="L615"></span>
<span class="line" id="L616">            <span class="tok-comment">// adjust block_size and buffer_size based on the values we were able to pull out</span>
</span>
<span class="line" id="L617">            buffer_size = buffer1.length();</span>
<span class="line" id="L618">            block_size = iterator.length() / buffer_size + <span class="tok-number">1</span>;</span>
<span class="line" id="L619"></span>
<span class="line" id="L620">            <span class="tok-comment">// the first buffer NEEDS to be large enough to tag each of the evenly sized A blocks,</span>
</span>
<span class="line" id="L621">            <span class="tok-comment">// so this was originally here to test the math for adjusting block_size above</span>
</span>
<span class="line" id="L622">            <span class="tok-comment">// assert((iterator.length() + 1)/block_size &lt;= buffer_size);</span>
</span>
<span class="line" id="L623"></span>
<span class="line" id="L624">            <span class="tok-comment">// now that the two internal buffers have been created, it's time to merge each A+B combination at this level of the merge sort!</span>
</span>
<span class="line" id="L625">            iterator.begin();</span>
<span class="line" id="L626">            <span class="tok-kw">while</span> (!iterator.finished()) {</span>
<span class="line" id="L627">                A = iterator.nextRange();</span>
<span class="line" id="L628">                B = iterator.nextRange();</span>
<span class="line" id="L629"></span>
<span class="line" id="L630">                <span class="tok-comment">// remove any parts of A or B that are being used by the internal buffers</span>
</span>
<span class="line" id="L631">                start = A.start;</span>
<span class="line" id="L632">                <span class="tok-kw">if</span> (start == pull[<span class="tok-number">0</span>].range.start) {</span>
<span class="line" id="L633">                    <span class="tok-kw">if</span> (pull[<span class="tok-number">0</span>].from &gt; pull[<span class="tok-number">0</span>].to) {</span>
<span class="line" id="L634">                        A.start += pull[<span class="tok-number">0</span>].count;</span>
<span class="line" id="L635"></span>
<span class="line" id="L636">                        <span class="tok-comment">// if the internal buffer takes up the entire A or B subarray, then there's nothing to merge</span>
</span>
<span class="line" id="L637">                        <span class="tok-comment">// this only happens for very small subarrays, like √4 = 2, 2 * (2 internal buffers) = 4,</span>
</span>
<span class="line" id="L638">                        <span class="tok-comment">// which also only happens when cache.len is small or 0 since it'd otherwise use MergeExternal</span>
</span>
<span class="line" id="L639">                        <span class="tok-kw">if</span> (A.length() == <span class="tok-number">0</span>) <span class="tok-kw">continue</span>;</span>
<span class="line" id="L640">                    } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (pull[<span class="tok-number">0</span>].from &lt; pull[<span class="tok-number">0</span>].to) {</span>
<span class="line" id="L641">                        B.end -= pull[<span class="tok-number">0</span>].count;</span>
<span class="line" id="L642">                        <span class="tok-kw">if</span> (B.length() == <span class="tok-number">0</span>) <span class="tok-kw">continue</span>;</span>
<span class="line" id="L643">                    }</span>
<span class="line" id="L644">                }</span>
<span class="line" id="L645">                <span class="tok-kw">if</span> (start == pull[<span class="tok-number">1</span>].range.start) {</span>
<span class="line" id="L646">                    <span class="tok-kw">if</span> (pull[<span class="tok-number">1</span>].from &gt; pull[<span class="tok-number">1</span>].to) {</span>
<span class="line" id="L647">                        A.start += pull[<span class="tok-number">1</span>].count;</span>
<span class="line" id="L648">                        <span class="tok-kw">if</span> (A.length() == <span class="tok-number">0</span>) <span class="tok-kw">continue</span>;</span>
<span class="line" id="L649">                    } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (pull[<span class="tok-number">1</span>].from &lt; pull[<span class="tok-number">1</span>].to) {</span>
<span class="line" id="L650">                        B.end -= pull[<span class="tok-number">1</span>].count;</span>
<span class="line" id="L651">                        <span class="tok-kw">if</span> (B.length() == <span class="tok-number">0</span>) <span class="tok-kw">continue</span>;</span>
<span class="line" id="L652">                    }</span>
<span class="line" id="L653">                }</span>
<span class="line" id="L654"></span>
<span class="line" id="L655">                <span class="tok-kw">if</span> (lessThan(context, items[B.end - <span class="tok-number">1</span>], items[A.start])) {</span>
<span class="line" id="L656">                    <span class="tok-comment">// the two ranges are in reverse order, so a simple rotation should fix it</span>
</span>
<span class="line" id="L657">                    mem.rotate(T, items[A.start..B.end], A.length());</span>
<span class="line" id="L658">                } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (lessThan(context, items[A.end], items[A.end - <span class="tok-number">1</span>])) {</span>
<span class="line" id="L659">                    <span class="tok-comment">// these two ranges weren't already in order, so we'll need to merge them!</span>
</span>
<span class="line" id="L660">                    <span class="tok-kw">var</span> findA: <span class="tok-type">usize</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L661"></span>
<span class="line" id="L662">                    <span class="tok-comment">// break the remainder of A into blocks. firstA is the uneven-sized first A block</span>
</span>
<span class="line" id="L663">                    <span class="tok-kw">var</span> blockA = Range.init(A.start, A.end);</span>
<span class="line" id="L664">                    <span class="tok-kw">var</span> firstA = Range.init(A.start, A.start + blockA.length() % block_size);</span>
<span class="line" id="L665"></span>
<span class="line" id="L666">                    <span class="tok-comment">// swap the first value of each A block with the value in buffer1</span>
</span>
<span class="line" id="L667">                    <span class="tok-kw">var</span> indexA = buffer1.start;</span>
<span class="line" id="L668">                    index = firstA.end;</span>
<span class="line" id="L669">                    <span class="tok-kw">while</span> (index &lt; blockA.end) : ({</span>
<span class="line" id="L670">                        indexA += <span class="tok-number">1</span>;</span>
<span class="line" id="L671">                        index += block_size;</span>
<span class="line" id="L672">                    }) {</span>
<span class="line" id="L673">                        mem.swap(T, &amp;items[indexA], &amp;items[index]);</span>
<span class="line" id="L674">                    }</span>
<span class="line" id="L675"></span>
<span class="line" id="L676">                    <span class="tok-comment">// start rolling the A blocks through the B blocks!</span>
</span>
<span class="line" id="L677">                    <span class="tok-comment">// whenever we leave an A block behind, we'll need to merge the previous A block with any B blocks that follow it, so track that information as well</span>
</span>
<span class="line" id="L678">                    <span class="tok-kw">var</span> lastA = firstA;</span>
<span class="line" id="L679">                    <span class="tok-kw">var</span> lastB = Range.init(<span class="tok-number">0</span>, <span class="tok-number">0</span>);</span>
<span class="line" id="L680">                    <span class="tok-kw">var</span> blockB = Range.init(B.start, B.start + math.min(block_size, B.length()));</span>
<span class="line" id="L681">                    blockA.start += firstA.length();</span>
<span class="line" id="L682">                    indexA = buffer1.start;</span>
<span class="line" id="L683"></span>
<span class="line" id="L684">                    <span class="tok-comment">// if the first unevenly sized A block fits into the cache, copy it there for when we go to Merge it</span>
</span>
<span class="line" id="L685">                    <span class="tok-comment">// otherwise, if the second buffer is available, block swap the contents into that</span>
</span>
<span class="line" id="L686">                    <span class="tok-kw">if</span> (lastA.length() &lt;= cache.len) {</span>
<span class="line" id="L687">                        mem.copy(T, cache[<span class="tok-number">0</span>..], items[lastA.start..lastA.end]);</span>
<span class="line" id="L688">                    } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (buffer2.length() &gt; <span class="tok-number">0</span>) {</span>
<span class="line" id="L689">                        blockSwap(T, items, lastA.start, buffer2.start, lastA.length());</span>
<span class="line" id="L690">                    }</span>
<span class="line" id="L691"></span>
<span class="line" id="L692">                    <span class="tok-kw">if</span> (blockA.length() &gt; <span class="tok-number">0</span>) {</span>
<span class="line" id="L693">                        <span class="tok-kw">while</span> (<span class="tok-null">true</span>) {</span>
<span class="line" id="L694">                            <span class="tok-comment">// if there's a previous B block and the first value of the minimum A block is &lt;= the last value of the previous B block,</span>
</span>
<span class="line" id="L695">                            <span class="tok-comment">// then drop that minimum A block behind. or if there are no B blocks left then keep dropping the remaining A blocks.</span>
</span>
<span class="line" id="L696">                            <span class="tok-kw">if</span> ((lastB.length() &gt; <span class="tok-number">0</span> <span class="tok-kw">and</span> !lessThan(context, items[lastB.end - <span class="tok-number">1</span>], items[indexA])) <span class="tok-kw">or</span> blockB.length() == <span class="tok-number">0</span>) {</span>
<span class="line" id="L697">                                <span class="tok-comment">// figure out where to split the previous B block, and rotate it at the split</span>
</span>
<span class="line" id="L698">                                <span class="tok-kw">const</span> B_split = binaryFirst(T, items, items[indexA], lastB, context, lessThan);</span>
<span class="line" id="L699">                                <span class="tok-kw">const</span> B_remaining = lastB.end - B_split;</span>
<span class="line" id="L700"></span>
<span class="line" id="L701">                                <span class="tok-comment">// swap the minimum A block to the beginning of the rolling A blocks</span>
</span>
<span class="line" id="L702">                                <span class="tok-kw">var</span> minA = blockA.start;</span>
<span class="line" id="L703">                                findA = minA + block_size;</span>
<span class="line" id="L704">                                <span class="tok-kw">while</span> (findA &lt; blockA.end) : (findA += block_size) {</span>
<span class="line" id="L705">                                    <span class="tok-kw">if</span> (lessThan(context, items[findA], items[minA])) {</span>
<span class="line" id="L706">                                        minA = findA;</span>
<span class="line" id="L707">                                    }</span>
<span class="line" id="L708">                                }</span>
<span class="line" id="L709">                                blockSwap(T, items, blockA.start, minA, block_size);</span>
<span class="line" id="L710"></span>
<span class="line" id="L711">                                <span class="tok-comment">// swap the first item of the previous A block back with its original value, which is stored in buffer1</span>
</span>
<span class="line" id="L712">                                mem.swap(T, &amp;items[blockA.start], &amp;items[indexA]);</span>
<span class="line" id="L713">                                indexA += <span class="tok-number">1</span>;</span>
<span class="line" id="L714"></span>
<span class="line" id="L715">                                <span class="tok-comment">// locally merge the previous A block with the B values that follow it</span>
</span>
<span class="line" id="L716">                                <span class="tok-comment">// if lastA fits into the external cache we'll use that (with MergeExternal),</span>
</span>
<span class="line" id="L717">                                <span class="tok-comment">// or if the second internal buffer exists we'll use that (with MergeInternal),</span>
</span>
<span class="line" id="L718">                                <span class="tok-comment">// or failing that we'll use a strictly in-place merge algorithm (MergeInPlace)</span>
</span>
<span class="line" id="L719"></span>
<span class="line" id="L720">                                <span class="tok-kw">if</span> (lastA.length() &lt;= cache.len) {</span>
<span class="line" id="L721">                                    mergeExternal(T, items, lastA, Range.init(lastA.end, B_split), context, lessThan, cache[<span class="tok-number">0</span>..]);</span>
<span class="line" id="L722">                                } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (buffer2.length() &gt; <span class="tok-number">0</span>) {</span>
<span class="line" id="L723">                                    mergeInternal(T, items, lastA, Range.init(lastA.end, B_split), context, lessThan, buffer2);</span>
<span class="line" id="L724">                                } <span class="tok-kw">else</span> {</span>
<span class="line" id="L725">                                    mergeInPlace(T, items, lastA, Range.init(lastA.end, B_split), context, lessThan);</span>
<span class="line" id="L726">                                }</span>
<span class="line" id="L727"></span>
<span class="line" id="L728">                                <span class="tok-kw">if</span> (buffer2.length() &gt; <span class="tok-number">0</span> <span class="tok-kw">or</span> block_size &lt;= cache.len) {</span>
<span class="line" id="L729">                                    <span class="tok-comment">// copy the previous A block into the cache or buffer2, since that's where we need it to be when we go to merge it anyway</span>
</span>
<span class="line" id="L730">                                    <span class="tok-kw">if</span> (block_size &lt;= cache.len) {</span>
<span class="line" id="L731">                                        mem.copy(T, cache[<span class="tok-number">0</span>..], items[blockA.start .. blockA.start + block_size]);</span>
<span class="line" id="L732">                                    } <span class="tok-kw">else</span> {</span>
<span class="line" id="L733">                                        blockSwap(T, items, blockA.start, buffer2.start, block_size);</span>
<span class="line" id="L734">                                    }</span>
<span class="line" id="L735"></span>
<span class="line" id="L736">                                    <span class="tok-comment">// this is equivalent to rotating, but faster</span>
</span>
<span class="line" id="L737">                                    <span class="tok-comment">// the area normally taken up by the A block is either the contents of buffer2, or data we don't need anymore since we memcopied it</span>
</span>
<span class="line" id="L738">                                    <span class="tok-comment">// either way, we don't need to retain the order of those items, so instead of rotating we can just block swap B to where it belongs</span>
</span>
<span class="line" id="L739">                                    blockSwap(T, items, B_split, blockA.start + block_size - B_remaining, B_remaining);</span>
<span class="line" id="L740">                                } <span class="tok-kw">else</span> {</span>
<span class="line" id="L741">                                    <span class="tok-comment">// we are unable to use the 'buffer2' trick to speed up the rotation operation since buffer2 doesn't exist, so perform a normal rotation</span>
</span>
<span class="line" id="L742">                                    mem.rotate(T, items[B_split .. blockA.start + block_size], blockA.start - B_split);</span>
<span class="line" id="L743">                                }</span>
<span class="line" id="L744"></span>
<span class="line" id="L745">                                <span class="tok-comment">// update the range for the remaining A blocks, and the range remaining from the B block after it was split</span>
</span>
<span class="line" id="L746">                                lastA = Range.init(blockA.start - B_remaining, blockA.start - B_remaining + block_size);</span>
<span class="line" id="L747">                                lastB = Range.init(lastA.end, lastA.end + B_remaining);</span>
<span class="line" id="L748"></span>
<span class="line" id="L749">                                <span class="tok-comment">// if there are no more A blocks remaining, this step is finished!</span>
</span>
<span class="line" id="L750">                                blockA.start += block_size;</span>
<span class="line" id="L751">                                <span class="tok-kw">if</span> (blockA.length() == <span class="tok-number">0</span>) <span class="tok-kw">break</span>;</span>
<span class="line" id="L752">                            } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (blockB.length() &lt; block_size) {</span>
<span class="line" id="L753">                                <span class="tok-comment">// move the last B block, which is unevenly sized, to before the remaining A blocks, by using a rotation</span>
</span>
<span class="line" id="L754">                                <span class="tok-comment">// the cache is disabled here since it might contain the contents of the previous A block</span>
</span>
<span class="line" id="L755">                                mem.rotate(T, items[blockA.start..blockB.end], blockB.start - blockA.start);</span>
<span class="line" id="L756"></span>
<span class="line" id="L757">                                lastB = Range.init(blockA.start, blockA.start + blockB.length());</span>
<span class="line" id="L758">                                blockA.start += blockB.length();</span>
<span class="line" id="L759">                                blockA.end += blockB.length();</span>
<span class="line" id="L760">                                blockB.end = blockB.start;</span>
<span class="line" id="L761">                            } <span class="tok-kw">else</span> {</span>
<span class="line" id="L762">                                <span class="tok-comment">// roll the leftmost A block to the end by swapping it with the next B block</span>
</span>
<span class="line" id="L763">                                blockSwap(T, items, blockA.start, blockB.start, block_size);</span>
<span class="line" id="L764">                                lastB = Range.init(blockA.start, blockA.start + block_size);</span>
<span class="line" id="L765"></span>
<span class="line" id="L766">                                blockA.start += block_size;</span>
<span class="line" id="L767">                                blockA.end += block_size;</span>
<span class="line" id="L768">                                blockB.start += block_size;</span>
<span class="line" id="L769"></span>
<span class="line" id="L770">                                <span class="tok-kw">if</span> (blockB.end &gt; B.end - block_size) {</span>
<span class="line" id="L771">                                    blockB.end = B.end;</span>
<span class="line" id="L772">                                } <span class="tok-kw">else</span> {</span>
<span class="line" id="L773">                                    blockB.end += block_size;</span>
<span class="line" id="L774">                                }</span>
<span class="line" id="L775">                            }</span>
<span class="line" id="L776">                        }</span>
<span class="line" id="L777">                    }</span>
<span class="line" id="L778"></span>
<span class="line" id="L779">                    <span class="tok-comment">// merge the last A block with the remaining B values</span>
</span>
<span class="line" id="L780">                    <span class="tok-kw">if</span> (lastA.length() &lt;= cache.len) {</span>
<span class="line" id="L781">                        mergeExternal(T, items, lastA, Range.init(lastA.end, B.end), context, lessThan, cache[<span class="tok-number">0</span>..]);</span>
<span class="line" id="L782">                    } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (buffer2.length() &gt; <span class="tok-number">0</span>) {</span>
<span class="line" id="L783">                        mergeInternal(T, items, lastA, Range.init(lastA.end, B.end), context, lessThan, buffer2);</span>
<span class="line" id="L784">                    } <span class="tok-kw">else</span> {</span>
<span class="line" id="L785">                        mergeInPlace(T, items, lastA, Range.init(lastA.end, B.end), context, lessThan);</span>
<span class="line" id="L786">                    }</span>
<span class="line" id="L787">                }</span>
<span class="line" id="L788">            }</span>
<span class="line" id="L789"></span>
<span class="line" id="L790">            <span class="tok-comment">// when we're finished with this merge step we should have the one</span>
</span>
<span class="line" id="L791">            <span class="tok-comment">// or two internal buffers left over, where the second buffer is all jumbled up</span>
</span>
<span class="line" id="L792">            <span class="tok-comment">// insertion sort the second buffer, then redistribute the buffers</span>
</span>
<span class="line" id="L793">            <span class="tok-comment">// back into the items using the opposite process used for creating the buffer</span>
</span>
<span class="line" id="L794"></span>
<span class="line" id="L795">            <span class="tok-comment">// while an unstable sort like quicksort could be applied here, in benchmarks</span>
</span>
<span class="line" id="L796">            <span class="tok-comment">// it was consistently slightly slower than a simple insertion sort,</span>
</span>
<span class="line" id="L797">            <span class="tok-comment">// even for tens of millions of items. this may be because insertion</span>
</span>
<span class="line" id="L798">            <span class="tok-comment">// sort is quite fast when the data is already somewhat sorted, like it is here</span>
</span>
<span class="line" id="L799">            insertionSort(T, items[buffer2.start..buffer2.end], context, lessThan);</span>
<span class="line" id="L800"></span>
<span class="line" id="L801">            pull_index = <span class="tok-number">0</span>;</span>
<span class="line" id="L802">            <span class="tok-kw">while</span> (pull_index &lt; <span class="tok-number">2</span>) : (pull_index += <span class="tok-number">1</span>) {</span>
<span class="line" id="L803">                <span class="tok-kw">var</span> unique = pull[pull_index].count * <span class="tok-number">2</span>;</span>
<span class="line" id="L804">                <span class="tok-kw">if</span> (pull[pull_index].from &gt; pull[pull_index].to) {</span>
<span class="line" id="L805">                    <span class="tok-comment">// the values were pulled out to the left, so redistribute them back to the right</span>
</span>
<span class="line" id="L806">                    <span class="tok-kw">var</span> buffer = Range.init(pull[pull_index].range.start, pull[pull_index].range.start + pull[pull_index].count);</span>
<span class="line" id="L807">                    <span class="tok-kw">while</span> (buffer.length() &gt; <span class="tok-number">0</span>) {</span>
<span class="line" id="L808">                        index = findFirstForward(T, items, items[buffer.start], Range.init(buffer.end, pull[pull_index].range.end), context, lessThan, unique);</span>
<span class="line" id="L809">                        <span class="tok-kw">const</span> amount = index - buffer.end;</span>
<span class="line" id="L810">                        mem.rotate(T, items[buffer.start..index], buffer.length());</span>
<span class="line" id="L811">                        buffer.start += (amount + <span class="tok-number">1</span>);</span>
<span class="line" id="L812">                        buffer.end += amount;</span>
<span class="line" id="L813">                        unique -= <span class="tok-number">2</span>;</span>
<span class="line" id="L814">                    }</span>
<span class="line" id="L815">                } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (pull[pull_index].from &lt; pull[pull_index].to) {</span>
<span class="line" id="L816">                    <span class="tok-comment">// the values were pulled out to the right, so redistribute them back to the left</span>
</span>
<span class="line" id="L817">                    <span class="tok-kw">var</span> buffer = Range.init(pull[pull_index].range.end - pull[pull_index].count, pull[pull_index].range.end);</span>
<span class="line" id="L818">                    <span class="tok-kw">while</span> (buffer.length() &gt; <span class="tok-number">0</span>) {</span>
<span class="line" id="L819">                        index = findLastBackward(T, items, items[buffer.end - <span class="tok-number">1</span>], Range.init(pull[pull_index].range.start, buffer.start), context, lessThan, unique);</span>
<span class="line" id="L820">                        <span class="tok-kw">const</span> amount = buffer.start - index;</span>
<span class="line" id="L821">                        mem.rotate(T, items[index..buffer.end], amount);</span>
<span class="line" id="L822">                        buffer.start -= amount;</span>
<span class="line" id="L823">                        buffer.end -= (amount + <span class="tok-number">1</span>);</span>
<span class="line" id="L824">                        unique -= <span class="tok-number">2</span>;</span>
<span class="line" id="L825">                    }</span>
<span class="line" id="L826">                }</span>
<span class="line" id="L827">            }</span>
<span class="line" id="L828">        }</span>
<span class="line" id="L829"></span>
<span class="line" id="L830">        <span class="tok-comment">// double the size of each A and B subarray that will be merged in the next level</span>
</span>
<span class="line" id="L831">        <span class="tok-kw">if</span> (!iterator.nextLevel()) <span class="tok-kw">break</span>;</span>
<span class="line" id="L832">    }</span>
<span class="line" id="L833">}</span>
<span class="line" id="L834"></span>
<span class="line" id="L835"><span class="tok-comment">/// TODO currently this just calls `insertionSortContext`. The block sort implementation</span></span>
<span class="line" id="L836"><span class="tok-comment">/// in this file needs to be adapted to use the sort context.</span></span>
<span class="line" id="L837"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">sortContext</span>(len: <span class="tok-type">usize</span>, context: <span class="tok-kw">anytype</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L838">    <span class="tok-kw">return</span> insertionSortContext(len, context);</span>
<span class="line" id="L839">}</span>
<span class="line" id="L840"></span>
<span class="line" id="L841"><span class="tok-comment">// merge operation without a buffer</span>
</span>
<span class="line" id="L842"><span class="tok-kw">fn</span> <span class="tok-fn">mergeInPlace</span>(</span>
<span class="line" id="L843">    <span class="tok-kw">comptime</span> T: <span class="tok-type">type</span>,</span>
<span class="line" id="L844">    items: []T,</span>
<span class="line" id="L845">    A_arg: Range,</span>
<span class="line" id="L846">    B_arg: Range,</span>
<span class="line" id="L847">    context: <span class="tok-kw">anytype</span>,</span>
<span class="line" id="L848">    <span class="tok-kw">comptime</span> lessThan: <span class="tok-kw">fn</span> (<span class="tok-builtin">@TypeOf</span>(context), T, T) <span class="tok-type">bool</span>,</span>
<span class="line" id="L849">) <span class="tok-type">void</span> {</span>
<span class="line" id="L850">    <span class="tok-kw">if</span> (A_arg.length() == <span class="tok-number">0</span> <span class="tok-kw">or</span> B_arg.length() == <span class="tok-number">0</span>) <span class="tok-kw">return</span>;</span>
<span class="line" id="L851"></span>
<span class="line" id="L852">    <span class="tok-comment">// this just repeatedly binary searches into B and rotates A into position.</span>
</span>
<span class="line" id="L853">    <span class="tok-comment">// the paper suggests using the 'rotation-based Hwang and Lin algorithm' here,</span>
</span>
<span class="line" id="L854">    <span class="tok-comment">// but I decided to stick with this because it had better situational performance</span>
</span>
<span class="line" id="L855">    <span class="tok-comment">//</span>
</span>
<span class="line" id="L856">    <span class="tok-comment">// (Hwang and Lin is designed for merging subarrays of very different sizes,</span>
</span>
<span class="line" id="L857">    <span class="tok-comment">// but WikiSort almost always uses subarrays that are roughly the same size)</span>
</span>
<span class="line" id="L858">    <span class="tok-comment">//</span>
</span>
<span class="line" id="L859">    <span class="tok-comment">// normally this is incredibly suboptimal, but this function is only called</span>
</span>
<span class="line" id="L860">    <span class="tok-comment">// when none of the A or B blocks in any subarray contained 2√A unique values,</span>
</span>
<span class="line" id="L861">    <span class="tok-comment">// which places a hard limit on the number of times this will ACTUALLY need</span>
</span>
<span class="line" id="L862">    <span class="tok-comment">// to binary search and rotate.</span>
</span>
<span class="line" id="L863">    <span class="tok-comment">//</span>
</span>
<span class="line" id="L864">    <span class="tok-comment">// according to my analysis the worst case is √A rotations performed on √A items</span>
</span>
<span class="line" id="L865">    <span class="tok-comment">// once the constant factors are removed, which ends up being O(n)</span>
</span>
<span class="line" id="L866">    <span class="tok-comment">//</span>
</span>
<span class="line" id="L867">    <span class="tok-comment">// again, this is NOT a general-purpose solution – it only works well in this case!</span>
</span>
<span class="line" id="L868">    <span class="tok-comment">// kind of like how the O(n^2) insertion sort is used in some places</span>
</span>
<span class="line" id="L869"></span>
<span class="line" id="L870">    <span class="tok-kw">var</span> A = A_arg;</span>
<span class="line" id="L871">    <span class="tok-kw">var</span> B = B_arg;</span>
<span class="line" id="L872"></span>
<span class="line" id="L873">    <span class="tok-kw">while</span> (<span class="tok-null">true</span>) {</span>
<span class="line" id="L874">        <span class="tok-comment">// find the first place in B where the first item in A needs to be inserted</span>
</span>
<span class="line" id="L875">        <span class="tok-kw">const</span> mid = binaryFirst(T, items, items[A.start], B, context, lessThan);</span>
<span class="line" id="L876"></span>
<span class="line" id="L877">        <span class="tok-comment">// rotate A into place</span>
</span>
<span class="line" id="L878">        <span class="tok-kw">const</span> amount = mid - A.end;</span>
<span class="line" id="L879">        mem.rotate(T, items[A.start..mid], A.length());</span>
<span class="line" id="L880">        <span class="tok-kw">if</span> (B.end == mid) <span class="tok-kw">break</span>;</span>
<span class="line" id="L881"></span>
<span class="line" id="L882">        <span class="tok-comment">// calculate the new A and B ranges</span>
</span>
<span class="line" id="L883">        B.start = mid;</span>
<span class="line" id="L884">        A = Range.init(A.start + amount, B.start);</span>
<span class="line" id="L885">        A.start = binaryLast(T, items, items[A.start], A, context, lessThan);</span>
<span class="line" id="L886">        <span class="tok-kw">if</span> (A.length() == <span class="tok-number">0</span>) <span class="tok-kw">break</span>;</span>
<span class="line" id="L887">    }</span>
<span class="line" id="L888">}</span>
<span class="line" id="L889"></span>
<span class="line" id="L890"><span class="tok-comment">// merge operation using an internal buffer</span>
</span>
<span class="line" id="L891"><span class="tok-kw">fn</span> <span class="tok-fn">mergeInternal</span>(</span>
<span class="line" id="L892">    <span class="tok-kw">comptime</span> T: <span class="tok-type">type</span>,</span>
<span class="line" id="L893">    items: []T,</span>
<span class="line" id="L894">    A: Range,</span>
<span class="line" id="L895">    B: Range,</span>
<span class="line" id="L896">    context: <span class="tok-kw">anytype</span>,</span>
<span class="line" id="L897">    <span class="tok-kw">comptime</span> lessThan: <span class="tok-kw">fn</span> (<span class="tok-builtin">@TypeOf</span>(context), T, T) <span class="tok-type">bool</span>,</span>
<span class="line" id="L898">    buffer: Range,</span>
<span class="line" id="L899">) <span class="tok-type">void</span> {</span>
<span class="line" id="L900">    <span class="tok-comment">// whenever we find a value to add to the final array, swap it with the value that's already in that spot</span>
</span>
<span class="line" id="L901">    <span class="tok-comment">// when this algorithm is finished, 'buffer' will contain its original contents, but in a different order</span>
</span>
<span class="line" id="L902">    <span class="tok-kw">var</span> A_count: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L903">    <span class="tok-kw">var</span> B_count: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L904">    <span class="tok-kw">var</span> insert: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L905"></span>
<span class="line" id="L906">    <span class="tok-kw">if</span> (B.length() &gt; <span class="tok-number">0</span> <span class="tok-kw">and</span> A.length() &gt; <span class="tok-number">0</span>) {</span>
<span class="line" id="L907">        <span class="tok-kw">while</span> (<span class="tok-null">true</span>) {</span>
<span class="line" id="L908">            <span class="tok-kw">if</span> (!lessThan(context, items[B.start + B_count], items[buffer.start + A_count])) {</span>
<span class="line" id="L909">                mem.swap(T, &amp;items[A.start + insert], &amp;items[buffer.start + A_count]);</span>
<span class="line" id="L910">                A_count += <span class="tok-number">1</span>;</span>
<span class="line" id="L911">                insert += <span class="tok-number">1</span>;</span>
<span class="line" id="L912">                <span class="tok-kw">if</span> (A_count &gt;= A.length()) <span class="tok-kw">break</span>;</span>
<span class="line" id="L913">            } <span class="tok-kw">else</span> {</span>
<span class="line" id="L914">                mem.swap(T, &amp;items[A.start + insert], &amp;items[B.start + B_count]);</span>
<span class="line" id="L915">                B_count += <span class="tok-number">1</span>;</span>
<span class="line" id="L916">                insert += <span class="tok-number">1</span>;</span>
<span class="line" id="L917">                <span class="tok-kw">if</span> (B_count &gt;= B.length()) <span class="tok-kw">break</span>;</span>
<span class="line" id="L918">            }</span>
<span class="line" id="L919">        }</span>
<span class="line" id="L920">    }</span>
<span class="line" id="L921"></span>
<span class="line" id="L922">    <span class="tok-comment">// swap the remainder of A into the final array</span>
</span>
<span class="line" id="L923">    blockSwap(T, items, buffer.start + A_count, A.start + insert, A.length() - A_count);</span>
<span class="line" id="L924">}</span>
<span class="line" id="L925"></span>
<span class="line" id="L926"><span class="tok-kw">fn</span> <span class="tok-fn">blockSwap</span>(<span class="tok-kw">comptime</span> T: <span class="tok-type">type</span>, items: []T, start1: <span class="tok-type">usize</span>, start2: <span class="tok-type">usize</span>, block_size: <span class="tok-type">usize</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L927">    <span class="tok-kw">var</span> index: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L928">    <span class="tok-kw">while</span> (index &lt; block_size) : (index += <span class="tok-number">1</span>) {</span>
<span class="line" id="L929">        mem.swap(T, &amp;items[start1 + index], &amp;items[start2 + index]);</span>
<span class="line" id="L930">    }</span>
<span class="line" id="L931">}</span>
<span class="line" id="L932"></span>
<span class="line" id="L933"><span class="tok-comment">// combine a linear search with a binary search to reduce the number of comparisons in situations</span>
</span>
<span class="line" id="L934"><span class="tok-comment">// where have some idea as to how many unique values there are and where the next value might be</span>
</span>
<span class="line" id="L935"><span class="tok-kw">fn</span> <span class="tok-fn">findFirstForward</span>(</span>
<span class="line" id="L936">    <span class="tok-kw">comptime</span> T: <span class="tok-type">type</span>,</span>
<span class="line" id="L937">    items: []T,</span>
<span class="line" id="L938">    value: T,</span>
<span class="line" id="L939">    range: Range,</span>
<span class="line" id="L940">    context: <span class="tok-kw">anytype</span>,</span>
<span class="line" id="L941">    <span class="tok-kw">comptime</span> lessThan: <span class="tok-kw">fn</span> (<span class="tok-builtin">@TypeOf</span>(context), T, T) <span class="tok-type">bool</span>,</span>
<span class="line" id="L942">    unique: <span class="tok-type">usize</span>,</span>
<span class="line" id="L943">) <span class="tok-type">usize</span> {</span>
<span class="line" id="L944">    <span class="tok-kw">if</span> (range.length() == <span class="tok-number">0</span>) <span class="tok-kw">return</span> range.start;</span>
<span class="line" id="L945">    <span class="tok-kw">const</span> skip = math.max(range.length() / unique, <span class="tok-builtin">@as</span>(<span class="tok-type">usize</span>, <span class="tok-number">1</span>));</span>
<span class="line" id="L946"></span>
<span class="line" id="L947">    <span class="tok-kw">var</span> index = range.start + skip;</span>
<span class="line" id="L948">    <span class="tok-kw">while</span> (lessThan(context, items[index - <span class="tok-number">1</span>], value)) : (index += skip) {</span>
<span class="line" id="L949">        <span class="tok-kw">if</span> (index &gt;= range.end - skip) {</span>
<span class="line" id="L950">            <span class="tok-kw">return</span> binaryFirst(T, items, value, Range.init(index, range.end), context, lessThan);</span>
<span class="line" id="L951">        }</span>
<span class="line" id="L952">    }</span>
<span class="line" id="L953"></span>
<span class="line" id="L954">    <span class="tok-kw">return</span> binaryFirst(T, items, value, Range.init(index - skip, index), context, lessThan);</span>
<span class="line" id="L955">}</span>
<span class="line" id="L956"></span>
<span class="line" id="L957"><span class="tok-kw">fn</span> <span class="tok-fn">findFirstBackward</span>(</span>
<span class="line" id="L958">    <span class="tok-kw">comptime</span> T: <span class="tok-type">type</span>,</span>
<span class="line" id="L959">    items: []T,</span>
<span class="line" id="L960">    value: T,</span>
<span class="line" id="L961">    range: Range,</span>
<span class="line" id="L962">    context: <span class="tok-kw">anytype</span>,</span>
<span class="line" id="L963">    <span class="tok-kw">comptime</span> lessThan: <span class="tok-kw">fn</span> (<span class="tok-builtin">@TypeOf</span>(context), T, T) <span class="tok-type">bool</span>,</span>
<span class="line" id="L964">    unique: <span class="tok-type">usize</span>,</span>
<span class="line" id="L965">) <span class="tok-type">usize</span> {</span>
<span class="line" id="L966">    <span class="tok-kw">if</span> (range.length() == <span class="tok-number">0</span>) <span class="tok-kw">return</span> range.start;</span>
<span class="line" id="L967">    <span class="tok-kw">const</span> skip = math.max(range.length() / unique, <span class="tok-builtin">@as</span>(<span class="tok-type">usize</span>, <span class="tok-number">1</span>));</span>
<span class="line" id="L968"></span>
<span class="line" id="L969">    <span class="tok-kw">var</span> index = range.end - skip;</span>
<span class="line" id="L970">    <span class="tok-kw">while</span> (index &gt; range.start <span class="tok-kw">and</span> !lessThan(context, items[index - <span class="tok-number">1</span>], value)) : (index -= skip) {</span>
<span class="line" id="L971">        <span class="tok-kw">if</span> (index &lt; range.start + skip) {</span>
<span class="line" id="L972">            <span class="tok-kw">return</span> binaryFirst(T, items, value, Range.init(range.start, index), context, lessThan);</span>
<span class="line" id="L973">        }</span>
<span class="line" id="L974">    }</span>
<span class="line" id="L975"></span>
<span class="line" id="L976">    <span class="tok-kw">return</span> binaryFirst(T, items, value, Range.init(index, index + skip), context, lessThan);</span>
<span class="line" id="L977">}</span>
<span class="line" id="L978"></span>
<span class="line" id="L979"><span class="tok-kw">fn</span> <span class="tok-fn">findLastForward</span>(</span>
<span class="line" id="L980">    <span class="tok-kw">comptime</span> T: <span class="tok-type">type</span>,</span>
<span class="line" id="L981">    items: []T,</span>
<span class="line" id="L982">    value: T,</span>
<span class="line" id="L983">    range: Range,</span>
<span class="line" id="L984">    context: <span class="tok-kw">anytype</span>,</span>
<span class="line" id="L985">    <span class="tok-kw">comptime</span> lessThan: <span class="tok-kw">fn</span> (<span class="tok-builtin">@TypeOf</span>(context), T, T) <span class="tok-type">bool</span>,</span>
<span class="line" id="L986">    unique: <span class="tok-type">usize</span>,</span>
<span class="line" id="L987">) <span class="tok-type">usize</span> {</span>
<span class="line" id="L988">    <span class="tok-kw">if</span> (range.length() == <span class="tok-number">0</span>) <span class="tok-kw">return</span> range.start;</span>
<span class="line" id="L989">    <span class="tok-kw">const</span> skip = math.max(range.length() / unique, <span class="tok-builtin">@as</span>(<span class="tok-type">usize</span>, <span class="tok-number">1</span>));</span>
<span class="line" id="L990"></span>
<span class="line" id="L991">    <span class="tok-kw">var</span> index = range.start + skip;</span>
<span class="line" id="L992">    <span class="tok-kw">while</span> (!lessThan(context, value, items[index - <span class="tok-number">1</span>])) : (index += skip) {</span>
<span class="line" id="L993">        <span class="tok-kw">if</span> (index &gt;= range.end - skip) {</span>
<span class="line" id="L994">            <span class="tok-kw">return</span> binaryLast(T, items, value, Range.init(index, range.end), context, lessThan);</span>
<span class="line" id="L995">        }</span>
<span class="line" id="L996">    }</span>
<span class="line" id="L997"></span>
<span class="line" id="L998">    <span class="tok-kw">return</span> binaryLast(T, items, value, Range.init(index - skip, index), context, lessThan);</span>
<span class="line" id="L999">}</span>
<span class="line" id="L1000"></span>
<span class="line" id="L1001"><span class="tok-kw">fn</span> <span class="tok-fn">findLastBackward</span>(</span>
<span class="line" id="L1002">    <span class="tok-kw">comptime</span> T: <span class="tok-type">type</span>,</span>
<span class="line" id="L1003">    items: []T,</span>
<span class="line" id="L1004">    value: T,</span>
<span class="line" id="L1005">    range: Range,</span>
<span class="line" id="L1006">    context: <span class="tok-kw">anytype</span>,</span>
<span class="line" id="L1007">    <span class="tok-kw">comptime</span> lessThan: <span class="tok-kw">fn</span> (<span class="tok-builtin">@TypeOf</span>(context), T, T) <span class="tok-type">bool</span>,</span>
<span class="line" id="L1008">    unique: <span class="tok-type">usize</span>,</span>
<span class="line" id="L1009">) <span class="tok-type">usize</span> {</span>
<span class="line" id="L1010">    <span class="tok-kw">if</span> (range.length() == <span class="tok-number">0</span>) <span class="tok-kw">return</span> range.start;</span>
<span class="line" id="L1011">    <span class="tok-kw">const</span> skip = math.max(range.length() / unique, <span class="tok-builtin">@as</span>(<span class="tok-type">usize</span>, <span class="tok-number">1</span>));</span>
<span class="line" id="L1012"></span>
<span class="line" id="L1013">    <span class="tok-kw">var</span> index = range.end - skip;</span>
<span class="line" id="L1014">    <span class="tok-kw">while</span> (index &gt; range.start <span class="tok-kw">and</span> lessThan(context, value, items[index - <span class="tok-number">1</span>])) : (index -= skip) {</span>
<span class="line" id="L1015">        <span class="tok-kw">if</span> (index &lt; range.start + skip) {</span>
<span class="line" id="L1016">            <span class="tok-kw">return</span> binaryLast(T, items, value, Range.init(range.start, index), context, lessThan);</span>
<span class="line" id="L1017">        }</span>
<span class="line" id="L1018">    }</span>
<span class="line" id="L1019"></span>
<span class="line" id="L1020">    <span class="tok-kw">return</span> binaryLast(T, items, value, Range.init(index, index + skip), context, lessThan);</span>
<span class="line" id="L1021">}</span>
<span class="line" id="L1022"></span>
<span class="line" id="L1023"><span class="tok-kw">fn</span> <span class="tok-fn">binaryFirst</span>(</span>
<span class="line" id="L1024">    <span class="tok-kw">comptime</span> T: <span class="tok-type">type</span>,</span>
<span class="line" id="L1025">    items: []T,</span>
<span class="line" id="L1026">    value: T,</span>
<span class="line" id="L1027">    range: Range,</span>
<span class="line" id="L1028">    context: <span class="tok-kw">anytype</span>,</span>
<span class="line" id="L1029">    <span class="tok-kw">comptime</span> lessThan: <span class="tok-kw">fn</span> (<span class="tok-builtin">@TypeOf</span>(context), T, T) <span class="tok-type">bool</span>,</span>
<span class="line" id="L1030">) <span class="tok-type">usize</span> {</span>
<span class="line" id="L1031">    <span class="tok-kw">var</span> curr = range.start;</span>
<span class="line" id="L1032">    <span class="tok-kw">var</span> size = range.length();</span>
<span class="line" id="L1033">    <span class="tok-kw">if</span> (range.start &gt;= range.end) <span class="tok-kw">return</span> range.end;</span>
<span class="line" id="L1034">    <span class="tok-kw">while</span> (size &gt; <span class="tok-number">0</span>) {</span>
<span class="line" id="L1035">        <span class="tok-kw">const</span> offset = size % <span class="tok-number">2</span>;</span>
<span class="line" id="L1036"></span>
<span class="line" id="L1037">        size /= <span class="tok-number">2</span>;</span>
<span class="line" id="L1038">        <span class="tok-kw">const</span> mid = items[curr + size];</span>
<span class="line" id="L1039">        <span class="tok-kw">if</span> (lessThan(context, mid, value)) {</span>
<span class="line" id="L1040">            curr += size + offset;</span>
<span class="line" id="L1041">        }</span>
<span class="line" id="L1042">    }</span>
<span class="line" id="L1043">    <span class="tok-kw">return</span> curr;</span>
<span class="line" id="L1044">}</span>
<span class="line" id="L1045"></span>
<span class="line" id="L1046"><span class="tok-kw">fn</span> <span class="tok-fn">binaryLast</span>(</span>
<span class="line" id="L1047">    <span class="tok-kw">comptime</span> T: <span class="tok-type">type</span>,</span>
<span class="line" id="L1048">    items: []T,</span>
<span class="line" id="L1049">    value: T,</span>
<span class="line" id="L1050">    range: Range,</span>
<span class="line" id="L1051">    context: <span class="tok-kw">anytype</span>,</span>
<span class="line" id="L1052">    <span class="tok-kw">comptime</span> lessThan: <span class="tok-kw">fn</span> (<span class="tok-builtin">@TypeOf</span>(context), T, T) <span class="tok-type">bool</span>,</span>
<span class="line" id="L1053">) <span class="tok-type">usize</span> {</span>
<span class="line" id="L1054">    <span class="tok-kw">var</span> curr = range.start;</span>
<span class="line" id="L1055">    <span class="tok-kw">var</span> size = range.length();</span>
<span class="line" id="L1056">    <span class="tok-kw">if</span> (range.start &gt;= range.end) <span class="tok-kw">return</span> range.end;</span>
<span class="line" id="L1057">    <span class="tok-kw">while</span> (size &gt; <span class="tok-number">0</span>) {</span>
<span class="line" id="L1058">        <span class="tok-kw">const</span> offset = size % <span class="tok-number">2</span>;</span>
<span class="line" id="L1059"></span>
<span class="line" id="L1060">        size /= <span class="tok-number">2</span>;</span>
<span class="line" id="L1061">        <span class="tok-kw">const</span> mid = items[curr + size];</span>
<span class="line" id="L1062">        <span class="tok-kw">if</span> (!lessThan(context, value, mid)) {</span>
<span class="line" id="L1063">            curr += size + offset;</span>
<span class="line" id="L1064">        }</span>
<span class="line" id="L1065">    }</span>
<span class="line" id="L1066">    <span class="tok-kw">return</span> curr;</span>
<span class="line" id="L1067">}</span>
<span class="line" id="L1068"></span>
<span class="line" id="L1069"><span class="tok-kw">fn</span> <span class="tok-fn">mergeInto</span>(</span>
<span class="line" id="L1070">    <span class="tok-kw">comptime</span> T: <span class="tok-type">type</span>,</span>
<span class="line" id="L1071">    from: []T,</span>
<span class="line" id="L1072">    A: Range,</span>
<span class="line" id="L1073">    B: Range,</span>
<span class="line" id="L1074">    context: <span class="tok-kw">anytype</span>,</span>
<span class="line" id="L1075">    <span class="tok-kw">comptime</span> lessThan: <span class="tok-kw">fn</span> (<span class="tok-builtin">@TypeOf</span>(context), T, T) <span class="tok-type">bool</span>,</span>
<span class="line" id="L1076">    into: []T,</span>
<span class="line" id="L1077">) <span class="tok-type">void</span> {</span>
<span class="line" id="L1078">    <span class="tok-kw">var</span> A_index: <span class="tok-type">usize</span> = A.start;</span>
<span class="line" id="L1079">    <span class="tok-kw">var</span> B_index: <span class="tok-type">usize</span> = B.start;</span>
<span class="line" id="L1080">    <span class="tok-kw">const</span> A_last = A.end;</span>
<span class="line" id="L1081">    <span class="tok-kw">const</span> B_last = B.end;</span>
<span class="line" id="L1082">    <span class="tok-kw">var</span> insert_index: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L1083"></span>
<span class="line" id="L1084">    <span class="tok-kw">while</span> (<span class="tok-null">true</span>) {</span>
<span class="line" id="L1085">        <span class="tok-kw">if</span> (!lessThan(context, from[B_index], from[A_index])) {</span>
<span class="line" id="L1086">            into[insert_index] = from[A_index];</span>
<span class="line" id="L1087">            A_index += <span class="tok-number">1</span>;</span>
<span class="line" id="L1088">            insert_index += <span class="tok-number">1</span>;</span>
<span class="line" id="L1089">            <span class="tok-kw">if</span> (A_index == A_last) {</span>
<span class="line" id="L1090">                <span class="tok-comment">// copy the remainder of B into the final array</span>
</span>
<span class="line" id="L1091">                mem.copy(T, into[insert_index..], from[B_index..B_last]);</span>
<span class="line" id="L1092">                <span class="tok-kw">break</span>;</span>
<span class="line" id="L1093">            }</span>
<span class="line" id="L1094">        } <span class="tok-kw">else</span> {</span>
<span class="line" id="L1095">            into[insert_index] = from[B_index];</span>
<span class="line" id="L1096">            B_index += <span class="tok-number">1</span>;</span>
<span class="line" id="L1097">            insert_index += <span class="tok-number">1</span>;</span>
<span class="line" id="L1098">            <span class="tok-kw">if</span> (B_index == B_last) {</span>
<span class="line" id="L1099">                <span class="tok-comment">// copy the remainder of A into the final array</span>
</span>
<span class="line" id="L1100">                mem.copy(T, into[insert_index..], from[A_index..A_last]);</span>
<span class="line" id="L1101">                <span class="tok-kw">break</span>;</span>
<span class="line" id="L1102">            }</span>
<span class="line" id="L1103">        }</span>
<span class="line" id="L1104">    }</span>
<span class="line" id="L1105">}</span>
<span class="line" id="L1106"></span>
<span class="line" id="L1107"><span class="tok-kw">fn</span> <span class="tok-fn">mergeExternal</span>(</span>
<span class="line" id="L1108">    <span class="tok-kw">comptime</span> T: <span class="tok-type">type</span>,</span>
<span class="line" id="L1109">    items: []T,</span>
<span class="line" id="L1110">    A: Range,</span>
<span class="line" id="L1111">    B: Range,</span>
<span class="line" id="L1112">    context: <span class="tok-kw">anytype</span>,</span>
<span class="line" id="L1113">    <span class="tok-kw">comptime</span> lessThan: <span class="tok-kw">fn</span> (<span class="tok-builtin">@TypeOf</span>(context), T, T) <span class="tok-type">bool</span>,</span>
<span class="line" id="L1114">    cache: []T,</span>
<span class="line" id="L1115">) <span class="tok-type">void</span> {</span>
<span class="line" id="L1116">    <span class="tok-comment">// A fits into the cache, so use that instead of the internal buffer</span>
</span>
<span class="line" id="L1117">    <span class="tok-kw">var</span> A_index: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L1118">    <span class="tok-kw">var</span> B_index: <span class="tok-type">usize</span> = B.start;</span>
<span class="line" id="L1119">    <span class="tok-kw">var</span> insert_index: <span class="tok-type">usize</span> = A.start;</span>
<span class="line" id="L1120">    <span class="tok-kw">const</span> A_last = A.length();</span>
<span class="line" id="L1121">    <span class="tok-kw">const</span> B_last = B.end;</span>
<span class="line" id="L1122"></span>
<span class="line" id="L1123">    <span class="tok-kw">if</span> (B.length() &gt; <span class="tok-number">0</span> <span class="tok-kw">and</span> A.length() &gt; <span class="tok-number">0</span>) {</span>
<span class="line" id="L1124">        <span class="tok-kw">while</span> (<span class="tok-null">true</span>) {</span>
<span class="line" id="L1125">            <span class="tok-kw">if</span> (!lessThan(context, items[B_index], cache[A_index])) {</span>
<span class="line" id="L1126">                items[insert_index] = cache[A_index];</span>
<span class="line" id="L1127">                A_index += <span class="tok-number">1</span>;</span>
<span class="line" id="L1128">                insert_index += <span class="tok-number">1</span>;</span>
<span class="line" id="L1129">                <span class="tok-kw">if</span> (A_index == A_last) <span class="tok-kw">break</span>;</span>
<span class="line" id="L1130">            } <span class="tok-kw">else</span> {</span>
<span class="line" id="L1131">                items[insert_index] = items[B_index];</span>
<span class="line" id="L1132">                B_index += <span class="tok-number">1</span>;</span>
<span class="line" id="L1133">                insert_index += <span class="tok-number">1</span>;</span>
<span class="line" id="L1134">                <span class="tok-kw">if</span> (B_index == B_last) <span class="tok-kw">break</span>;</span>
<span class="line" id="L1135">            }</span>
<span class="line" id="L1136">        }</span>
<span class="line" id="L1137">    }</span>
<span class="line" id="L1138"></span>
<span class="line" id="L1139">    <span class="tok-comment">// copy the remainder of A into the final array</span>
</span>
<span class="line" id="L1140">    mem.copy(T, items[insert_index..], cache[A_index..A_last]);</span>
<span class="line" id="L1141">}</span>
<span class="line" id="L1142"></span>
<span class="line" id="L1143"><span class="tok-kw">fn</span> <span class="tok-fn">swap</span>(</span>
<span class="line" id="L1144">    <span class="tok-kw">comptime</span> T: <span class="tok-type">type</span>,</span>
<span class="line" id="L1145">    items: []T,</span>
<span class="line" id="L1146">    context: <span class="tok-kw">anytype</span>,</span>
<span class="line" id="L1147">    <span class="tok-kw">comptime</span> lessThan: <span class="tok-kw">fn</span> (<span class="tok-builtin">@TypeOf</span>(context), lhs: T, rhs: T) <span class="tok-type">bool</span>,</span>
<span class="line" id="L1148">    order: *[<span class="tok-number">8</span>]<span class="tok-type">u8</span>,</span>
<span class="line" id="L1149">    x: <span class="tok-type">usize</span>,</span>
<span class="line" id="L1150">    y: <span class="tok-type">usize</span>,</span>
<span class="line" id="L1151">) <span class="tok-type">void</span> {</span>
<span class="line" id="L1152">    <span class="tok-kw">if</span> (lessThan(context, items[y], items[x]) <span class="tok-kw">or</span> ((order.*)[x] &gt; (order.*)[y] <span class="tok-kw">and</span> !lessThan(context, items[x], items[y]))) {</span>
<span class="line" id="L1153">        mem.swap(T, &amp;items[x], &amp;items[y]);</span>
<span class="line" id="L1154">        mem.swap(<span class="tok-type">u8</span>, &amp;(order.*)[x], &amp;(order.*)[y]);</span>
<span class="line" id="L1155">    }</span>
<span class="line" id="L1156">}</span>
<span class="line" id="L1157"></span>
<span class="line" id="L1158"><span class="tok-comment">/// Use to generate a comparator function for a given type. e.g. `sort(u8, slice, {}, comptime asc(u8))`.</span></span>
<span class="line" id="L1159"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">asc</span>(<span class="tok-kw">comptime</span> T: <span class="tok-type">type</span>) <span class="tok-kw">fn</span> (<span class="tok-type">void</span>, T, T) <span class="tok-type">bool</span> {</span>
<span class="line" id="L1160">    <span class="tok-kw">const</span> impl = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L1161">        <span class="tok-kw">fn</span> <span class="tok-fn">inner</span>(context: <span class="tok-type">void</span>, a: T, b: T) <span class="tok-type">bool</span> {</span>
<span class="line" id="L1162">            _ = context;</span>
<span class="line" id="L1163">            <span class="tok-kw">return</span> a &lt; b;</span>
<span class="line" id="L1164">        }</span>
<span class="line" id="L1165">    };</span>
<span class="line" id="L1166"></span>
<span class="line" id="L1167">    <span class="tok-kw">return</span> impl.inner;</span>
<span class="line" id="L1168">}</span>
<span class="line" id="L1169"></span>
<span class="line" id="L1170"><span class="tok-comment">/// Use to generate a comparator function for a given type. e.g. `sort(u8, slice, {}, comptime desc(u8))`.</span></span>
<span class="line" id="L1171"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">desc</span>(<span class="tok-kw">comptime</span> T: <span class="tok-type">type</span>) <span class="tok-kw">fn</span> (<span class="tok-type">void</span>, T, T) <span class="tok-type">bool</span> {</span>
<span class="line" id="L1172">    <span class="tok-kw">const</span> impl = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L1173">        <span class="tok-kw">fn</span> <span class="tok-fn">inner</span>(context: <span class="tok-type">void</span>, a: T, b: T) <span class="tok-type">bool</span> {</span>
<span class="line" id="L1174">            _ = context;</span>
<span class="line" id="L1175">            <span class="tok-kw">return</span> a &gt; b;</span>
<span class="line" id="L1176">        }</span>
<span class="line" id="L1177">    };</span>
<span class="line" id="L1178"></span>
<span class="line" id="L1179">    <span class="tok-kw">return</span> impl.inner;</span>
<span class="line" id="L1180">}</span>
<span class="line" id="L1181"></span>
<span class="line" id="L1182"><span class="tok-kw">test</span> <span class="tok-str">&quot;stable sort&quot;</span> {</span>
<span class="line" id="L1183">    <span class="tok-kw">try</span> testStableSort();</span>
<span class="line" id="L1184">    <span class="tok-kw">comptime</span> <span class="tok-kw">try</span> testStableSort();</span>
<span class="line" id="L1185">}</span>
<span class="line" id="L1186"><span class="tok-kw">fn</span> <span class="tok-fn">testStableSort</span>() !<span class="tok-type">void</span> {</span>
<span class="line" id="L1187">    <span class="tok-kw">var</span> expected = [_]IdAndValue{</span>
<span class="line" id="L1188">        IdAndValue{ .id = <span class="tok-number">0</span>, .value = <span class="tok-number">0</span> },</span>
<span class="line" id="L1189">        IdAndValue{ .id = <span class="tok-number">1</span>, .value = <span class="tok-number">0</span> },</span>
<span class="line" id="L1190">        IdAndValue{ .id = <span class="tok-number">2</span>, .value = <span class="tok-number">0</span> },</span>
<span class="line" id="L1191">        IdAndValue{ .id = <span class="tok-number">0</span>, .value = <span class="tok-number">1</span> },</span>
<span class="line" id="L1192">        IdAndValue{ .id = <span class="tok-number">1</span>, .value = <span class="tok-number">1</span> },</span>
<span class="line" id="L1193">        IdAndValue{ .id = <span class="tok-number">2</span>, .value = <span class="tok-number">1</span> },</span>
<span class="line" id="L1194">        IdAndValue{ .id = <span class="tok-number">0</span>, .value = <span class="tok-number">2</span> },</span>
<span class="line" id="L1195">        IdAndValue{ .id = <span class="tok-number">1</span>, .value = <span class="tok-number">2</span> },</span>
<span class="line" id="L1196">        IdAndValue{ .id = <span class="tok-number">2</span>, .value = <span class="tok-number">2</span> },</span>
<span class="line" id="L1197">    };</span>
<span class="line" id="L1198">    <span class="tok-kw">var</span> cases = [_][<span class="tok-number">9</span>]IdAndValue{</span>
<span class="line" id="L1199">        [_]IdAndValue{</span>
<span class="line" id="L1200">            IdAndValue{ .id = <span class="tok-number">0</span>, .value = <span class="tok-number">0</span> },</span>
<span class="line" id="L1201">            IdAndValue{ .id = <span class="tok-number">0</span>, .value = <span class="tok-number">1</span> },</span>
<span class="line" id="L1202">            IdAndValue{ .id = <span class="tok-number">0</span>, .value = <span class="tok-number">2</span> },</span>
<span class="line" id="L1203">            IdAndValue{ .id = <span class="tok-number">1</span>, .value = <span class="tok-number">0</span> },</span>
<span class="line" id="L1204">            IdAndValue{ .id = <span class="tok-number">1</span>, .value = <span class="tok-number">1</span> },</span>
<span class="line" id="L1205">            IdAndValue{ .id = <span class="tok-number">1</span>, .value = <span class="tok-number">2</span> },</span>
<span class="line" id="L1206">            IdAndValue{ .id = <span class="tok-number">2</span>, .value = <span class="tok-number">0</span> },</span>
<span class="line" id="L1207">            IdAndValue{ .id = <span class="tok-number">2</span>, .value = <span class="tok-number">1</span> },</span>
<span class="line" id="L1208">            IdAndValue{ .id = <span class="tok-number">2</span>, .value = <span class="tok-number">2</span> },</span>
<span class="line" id="L1209">        },</span>
<span class="line" id="L1210">        [_]IdAndValue{</span>
<span class="line" id="L1211">            IdAndValue{ .id = <span class="tok-number">0</span>, .value = <span class="tok-number">2</span> },</span>
<span class="line" id="L1212">            IdAndValue{ .id = <span class="tok-number">0</span>, .value = <span class="tok-number">1</span> },</span>
<span class="line" id="L1213">            IdAndValue{ .id = <span class="tok-number">0</span>, .value = <span class="tok-number">0</span> },</span>
<span class="line" id="L1214">            IdAndValue{ .id = <span class="tok-number">1</span>, .value = <span class="tok-number">2</span> },</span>
<span class="line" id="L1215">            IdAndValue{ .id = <span class="tok-number">1</span>, .value = <span class="tok-number">1</span> },</span>
<span class="line" id="L1216">            IdAndValue{ .id = <span class="tok-number">1</span>, .value = <span class="tok-number">0</span> },</span>
<span class="line" id="L1217">            IdAndValue{ .id = <span class="tok-number">2</span>, .value = <span class="tok-number">2</span> },</span>
<span class="line" id="L1218">            IdAndValue{ .id = <span class="tok-number">2</span>, .value = <span class="tok-number">1</span> },</span>
<span class="line" id="L1219">            IdAndValue{ .id = <span class="tok-number">2</span>, .value = <span class="tok-number">0</span> },</span>
<span class="line" id="L1220">        },</span>
<span class="line" id="L1221">    };</span>
<span class="line" id="L1222">    <span class="tok-kw">for</span> (cases) |*case| {</span>
<span class="line" id="L1223">        insertionSort(IdAndValue, (case.*)[<span class="tok-number">0</span>..], {}, cmpByValue);</span>
<span class="line" id="L1224">        <span class="tok-kw">for</span> (case.*) |item, i| {</span>
<span class="line" id="L1225">            <span class="tok-kw">try</span> testing.expect(item.id == expected[i].id);</span>
<span class="line" id="L1226">            <span class="tok-kw">try</span> testing.expect(item.value == expected[i].value);</span>
<span class="line" id="L1227">        }</span>
<span class="line" id="L1228">    }</span>
<span class="line" id="L1229">}</span>
<span class="line" id="L1230"><span class="tok-kw">const</span> IdAndValue = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L1231">    id: <span class="tok-type">usize</span>,</span>
<span class="line" id="L1232">    value: <span class="tok-type">i32</span>,</span>
<span class="line" id="L1233">};</span>
<span class="line" id="L1234"><span class="tok-kw">fn</span> <span class="tok-fn">cmpByValue</span>(context: <span class="tok-type">void</span>, a: IdAndValue, b: IdAndValue) <span class="tok-type">bool</span> {</span>
<span class="line" id="L1235">    <span class="tok-kw">return</span> asc_i32(context, a.value, b.value);</span>
<span class="line" id="L1236">}</span>
<span class="line" id="L1237"></span>
<span class="line" id="L1238"><span class="tok-kw">const</span> asc_u8 = asc(<span class="tok-type">u8</span>);</span>
<span class="line" id="L1239"><span class="tok-kw">const</span> asc_i32 = asc(<span class="tok-type">i32</span>);</span>
<span class="line" id="L1240"><span class="tok-kw">const</span> desc_u8 = desc(<span class="tok-type">u8</span>);</span>
<span class="line" id="L1241"><span class="tok-kw">const</span> desc_i32 = desc(<span class="tok-type">i32</span>);</span>
<span class="line" id="L1242"></span>
<span class="line" id="L1243"><span class="tok-kw">test</span> <span class="tok-str">&quot;sort&quot;</span> {</span>
<span class="line" id="L1244">    <span class="tok-kw">const</span> u8cases = [_][]<span class="tok-kw">const</span> []<span class="tok-kw">const</span> <span class="tok-type">u8</span>{</span>
<span class="line" id="L1245">        &amp;[_][]<span class="tok-kw">const</span> <span class="tok-type">u8</span>{</span>
<span class="line" id="L1246">            <span class="tok-str">&quot;&quot;</span>,</span>
<span class="line" id="L1247">            <span class="tok-str">&quot;&quot;</span>,</span>
<span class="line" id="L1248">        },</span>
<span class="line" id="L1249">        &amp;[_][]<span class="tok-kw">const</span> <span class="tok-type">u8</span>{</span>
<span class="line" id="L1250">            <span class="tok-str">&quot;a&quot;</span>,</span>
<span class="line" id="L1251">            <span class="tok-str">&quot;a&quot;</span>,</span>
<span class="line" id="L1252">        },</span>
<span class="line" id="L1253">        &amp;[_][]<span class="tok-kw">const</span> <span class="tok-type">u8</span>{</span>
<span class="line" id="L1254">            <span class="tok-str">&quot;az&quot;</span>,</span>
<span class="line" id="L1255">            <span class="tok-str">&quot;az&quot;</span>,</span>
<span class="line" id="L1256">        },</span>
<span class="line" id="L1257">        &amp;[_][]<span class="tok-kw">const</span> <span class="tok-type">u8</span>{</span>
<span class="line" id="L1258">            <span class="tok-str">&quot;za&quot;</span>,</span>
<span class="line" id="L1259">            <span class="tok-str">&quot;az&quot;</span>,</span>
<span class="line" id="L1260">        },</span>
<span class="line" id="L1261">        &amp;[_][]<span class="tok-kw">const</span> <span class="tok-type">u8</span>{</span>
<span class="line" id="L1262">            <span class="tok-str">&quot;asdf&quot;</span>,</span>
<span class="line" id="L1263">            <span class="tok-str">&quot;adfs&quot;</span>,</span>
<span class="line" id="L1264">        },</span>
<span class="line" id="L1265">        &amp;[_][]<span class="tok-kw">const</span> <span class="tok-type">u8</span>{</span>
<span class="line" id="L1266">            <span class="tok-str">&quot;one&quot;</span>,</span>
<span class="line" id="L1267">            <span class="tok-str">&quot;eno&quot;</span>,</span>
<span class="line" id="L1268">        },</span>
<span class="line" id="L1269">    };</span>
<span class="line" id="L1270"></span>
<span class="line" id="L1271">    <span class="tok-kw">for</span> (u8cases) |case| {</span>
<span class="line" id="L1272">        <span class="tok-kw">var</span> buf: [<span class="tok-number">8</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L1273">        <span class="tok-kw">const</span> slice = buf[<span class="tok-number">0</span>..case[<span class="tok-number">0</span>].len];</span>
<span class="line" id="L1274">        mem.copy(<span class="tok-type">u8</span>, slice, case[<span class="tok-number">0</span>]);</span>
<span class="line" id="L1275">        sort(<span class="tok-type">u8</span>, slice, {}, asc_u8);</span>
<span class="line" id="L1276">        <span class="tok-kw">try</span> testing.expect(mem.eql(<span class="tok-type">u8</span>, slice, case[<span class="tok-number">1</span>]));</span>
<span class="line" id="L1277">    }</span>
<span class="line" id="L1278"></span>
<span class="line" id="L1279">    <span class="tok-kw">const</span> i32cases = [_][]<span class="tok-kw">const</span> []<span class="tok-kw">const</span> <span class="tok-type">i32</span>{</span>
<span class="line" id="L1280">        &amp;[_][]<span class="tok-kw">const</span> <span class="tok-type">i32</span>{</span>
<span class="line" id="L1281">            &amp;[_]<span class="tok-type">i32</span>{},</span>
<span class="line" id="L1282">            &amp;[_]<span class="tok-type">i32</span>{},</span>
<span class="line" id="L1283">        },</span>
<span class="line" id="L1284">        &amp;[_][]<span class="tok-kw">const</span> <span class="tok-type">i32</span>{</span>
<span class="line" id="L1285">            &amp;[_]<span class="tok-type">i32</span>{<span class="tok-number">1</span>},</span>
<span class="line" id="L1286">            &amp;[_]<span class="tok-type">i32</span>{<span class="tok-number">1</span>},</span>
<span class="line" id="L1287">        },</span>
<span class="line" id="L1288">        &amp;[_][]<span class="tok-kw">const</span> <span class="tok-type">i32</span>{</span>
<span class="line" id="L1289">            &amp;[_]<span class="tok-type">i32</span>{ <span class="tok-number">0</span>, <span class="tok-number">1</span> },</span>
<span class="line" id="L1290">            &amp;[_]<span class="tok-type">i32</span>{ <span class="tok-number">0</span>, <span class="tok-number">1</span> },</span>
<span class="line" id="L1291">        },</span>
<span class="line" id="L1292">        &amp;[_][]<span class="tok-kw">const</span> <span class="tok-type">i32</span>{</span>
<span class="line" id="L1293">            &amp;[_]<span class="tok-type">i32</span>{ <span class="tok-number">1</span>, <span class="tok-number">0</span> },</span>
<span class="line" id="L1294">            &amp;[_]<span class="tok-type">i32</span>{ <span class="tok-number">0</span>, <span class="tok-number">1</span> },</span>
<span class="line" id="L1295">        },</span>
<span class="line" id="L1296">        &amp;[_][]<span class="tok-kw">const</span> <span class="tok-type">i32</span>{</span>
<span class="line" id="L1297">            &amp;[_]<span class="tok-type">i32</span>{ <span class="tok-number">1</span>, -<span class="tok-number">1</span>, <span class="tok-number">0</span> },</span>
<span class="line" id="L1298">            &amp;[_]<span class="tok-type">i32</span>{ -<span class="tok-number">1</span>, <span class="tok-number">0</span>, <span class="tok-number">1</span> },</span>
<span class="line" id="L1299">        },</span>
<span class="line" id="L1300">        &amp;[_][]<span class="tok-kw">const</span> <span class="tok-type">i32</span>{</span>
<span class="line" id="L1301">            &amp;[_]<span class="tok-type">i32</span>{ <span class="tok-number">2</span>, <span class="tok-number">1</span>, <span class="tok-number">3</span> },</span>
<span class="line" id="L1302">            &amp;[_]<span class="tok-type">i32</span>{ <span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">3</span> },</span>
<span class="line" id="L1303">        },</span>
<span class="line" id="L1304">    };</span>
<span class="line" id="L1305"></span>
<span class="line" id="L1306">    <span class="tok-kw">for</span> (i32cases) |case| {</span>
<span class="line" id="L1307">        <span class="tok-kw">var</span> buf: [<span class="tok-number">8</span>]<span class="tok-type">i32</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L1308">        <span class="tok-kw">const</span> slice = buf[<span class="tok-number">0</span>..case[<span class="tok-number">0</span>].len];</span>
<span class="line" id="L1309">        mem.copy(<span class="tok-type">i32</span>, slice, case[<span class="tok-number">0</span>]);</span>
<span class="line" id="L1310">        sort(<span class="tok-type">i32</span>, slice, {}, asc_i32);</span>
<span class="line" id="L1311">        <span class="tok-kw">try</span> testing.expect(mem.eql(<span class="tok-type">i32</span>, slice, case[<span class="tok-number">1</span>]));</span>
<span class="line" id="L1312">    }</span>
<span class="line" id="L1313">}</span>
<span class="line" id="L1314"></span>
<span class="line" id="L1315"><span class="tok-kw">test</span> <span class="tok-str">&quot;sort descending&quot;</span> {</span>
<span class="line" id="L1316">    <span class="tok-kw">const</span> rev_cases = [_][]<span class="tok-kw">const</span> []<span class="tok-kw">const</span> <span class="tok-type">i32</span>{</span>
<span class="line" id="L1317">        &amp;[_][]<span class="tok-kw">const</span> <span class="tok-type">i32</span>{</span>
<span class="line" id="L1318">            &amp;[_]<span class="tok-type">i32</span>{},</span>
<span class="line" id="L1319">            &amp;[_]<span class="tok-type">i32</span>{},</span>
<span class="line" id="L1320">        },</span>
<span class="line" id="L1321">        &amp;[_][]<span class="tok-kw">const</span> <span class="tok-type">i32</span>{</span>
<span class="line" id="L1322">            &amp;[_]<span class="tok-type">i32</span>{<span class="tok-number">1</span>},</span>
<span class="line" id="L1323">            &amp;[_]<span class="tok-type">i32</span>{<span class="tok-number">1</span>},</span>
<span class="line" id="L1324">        },</span>
<span class="line" id="L1325">        &amp;[_][]<span class="tok-kw">const</span> <span class="tok-type">i32</span>{</span>
<span class="line" id="L1326">            &amp;[_]<span class="tok-type">i32</span>{ <span class="tok-number">0</span>, <span class="tok-number">1</span> },</span>
<span class="line" id="L1327">            &amp;[_]<span class="tok-type">i32</span>{ <span class="tok-number">1</span>, <span class="tok-number">0</span> },</span>
<span class="line" id="L1328">        },</span>
<span class="line" id="L1329">        &amp;[_][]<span class="tok-kw">const</span> <span class="tok-type">i32</span>{</span>
<span class="line" id="L1330">            &amp;[_]<span class="tok-type">i32</span>{ <span class="tok-number">1</span>, <span class="tok-number">0</span> },</span>
<span class="line" id="L1331">            &amp;[_]<span class="tok-type">i32</span>{ <span class="tok-number">1</span>, <span class="tok-number">0</span> },</span>
<span class="line" id="L1332">        },</span>
<span class="line" id="L1333">        &amp;[_][]<span class="tok-kw">const</span> <span class="tok-type">i32</span>{</span>
<span class="line" id="L1334">            &amp;[_]<span class="tok-type">i32</span>{ <span class="tok-number">1</span>, -<span class="tok-number">1</span>, <span class="tok-number">0</span> },</span>
<span class="line" id="L1335">            &amp;[_]<span class="tok-type">i32</span>{ <span class="tok-number">1</span>, <span class="tok-number">0</span>, -<span class="tok-number">1</span> },</span>
<span class="line" id="L1336">        },</span>
<span class="line" id="L1337">        &amp;[_][]<span class="tok-kw">const</span> <span class="tok-type">i32</span>{</span>
<span class="line" id="L1338">            &amp;[_]<span class="tok-type">i32</span>{ <span class="tok-number">2</span>, <span class="tok-number">1</span>, <span class="tok-number">3</span> },</span>
<span class="line" id="L1339">            &amp;[_]<span class="tok-type">i32</span>{ <span class="tok-number">3</span>, <span class="tok-number">2</span>, <span class="tok-number">1</span> },</span>
<span class="line" id="L1340">        },</span>
<span class="line" id="L1341">    };</span>
<span class="line" id="L1342"></span>
<span class="line" id="L1343">    <span class="tok-kw">for</span> (rev_cases) |case| {</span>
<span class="line" id="L1344">        <span class="tok-kw">var</span> buf: [<span class="tok-number">8</span>]<span class="tok-type">i32</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L1345">        <span class="tok-kw">const</span> slice = buf[<span class="tok-number">0</span>..case[<span class="tok-number">0</span>].len];</span>
<span class="line" id="L1346">        mem.copy(<span class="tok-type">i32</span>, slice, case[<span class="tok-number">0</span>]);</span>
<span class="line" id="L1347">        sort(<span class="tok-type">i32</span>, slice, {}, desc_i32);</span>
<span class="line" id="L1348">        <span class="tok-kw">try</span> testing.expect(mem.eql(<span class="tok-type">i32</span>, slice, case[<span class="tok-number">1</span>]));</span>
<span class="line" id="L1349">    }</span>
<span class="line" id="L1350">}</span>
<span class="line" id="L1351"></span>
<span class="line" id="L1352"><span class="tok-kw">test</span> <span class="tok-str">&quot;another sort case&quot;</span> {</span>
<span class="line" id="L1353">    <span class="tok-kw">var</span> arr = [_]<span class="tok-type">i32</span>{ <span class="tok-number">5</span>, <span class="tok-number">3</span>, <span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">4</span> };</span>
<span class="line" id="L1354">    sort(<span class="tok-type">i32</span>, arr[<span class="tok-number">0</span>..], {}, asc_i32);</span>
<span class="line" id="L1355"></span>
<span class="line" id="L1356">    <span class="tok-kw">try</span> testing.expect(mem.eql(<span class="tok-type">i32</span>, &amp;arr, &amp;[_]<span class="tok-type">i32</span>{ <span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">4</span>, <span class="tok-number">5</span> }));</span>
<span class="line" id="L1357">}</span>
<span class="line" id="L1358"></span>
<span class="line" id="L1359"><span class="tok-kw">test</span> <span class="tok-str">&quot;sort fuzz testing&quot;</span> {</span>
<span class="line" id="L1360">    <span class="tok-kw">var</span> prng = std.rand.DefaultPrng.init(<span class="tok-number">0x12345678</span>);</span>
<span class="line" id="L1361">    <span class="tok-kw">const</span> random = prng.random();</span>
<span class="line" id="L1362">    <span class="tok-kw">const</span> test_case_count = <span class="tok-number">10</span>;</span>
<span class="line" id="L1363">    <span class="tok-kw">var</span> i: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L1364">    <span class="tok-kw">while</span> (i &lt; test_case_count) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L1365">        <span class="tok-kw">try</span> fuzzTest(random);</span>
<span class="line" id="L1366">    }</span>
<span class="line" id="L1367">}</span>
<span class="line" id="L1368"></span>
<span class="line" id="L1369"><span class="tok-kw">var</span> fixed_buffer_mem: [<span class="tok-number">100</span> * <span class="tok-number">1024</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L1370"></span>
<span class="line" id="L1371"><span class="tok-kw">fn</span> <span class="tok-fn">fuzzTest</span>(rng: std.rand.Random) !<span class="tok-type">void</span> {</span>
<span class="line" id="L1372">    <span class="tok-kw">const</span> array_size = rng.intRangeLessThan(<span class="tok-type">usize</span>, <span class="tok-number">0</span>, <span class="tok-number">1000</span>);</span>
<span class="line" id="L1373">    <span class="tok-kw">var</span> array = <span class="tok-kw">try</span> testing.allocator.alloc(IdAndValue, array_size);</span>
<span class="line" id="L1374">    <span class="tok-kw">defer</span> testing.allocator.free(array);</span>
<span class="line" id="L1375">    <span class="tok-comment">// populate with random data</span>
</span>
<span class="line" id="L1376">    <span class="tok-kw">for</span> (array) |*item, index| {</span>
<span class="line" id="L1377">        item.id = index;</span>
<span class="line" id="L1378">        item.value = rng.intRangeLessThan(<span class="tok-type">i32</span>, <span class="tok-number">0</span>, <span class="tok-number">100</span>);</span>
<span class="line" id="L1379">    }</span>
<span class="line" id="L1380">    sort(IdAndValue, array, {}, cmpByValue);</span>
<span class="line" id="L1381"></span>
<span class="line" id="L1382">    <span class="tok-kw">var</span> index: <span class="tok-type">usize</span> = <span class="tok-number">1</span>;</span>
<span class="line" id="L1383">    <span class="tok-kw">while</span> (index &lt; array.len) : (index += <span class="tok-number">1</span>) {</span>
<span class="line" id="L1384">        <span class="tok-kw">if</span> (array[index].value == array[index - <span class="tok-number">1</span>].value) {</span>
<span class="line" id="L1385">            <span class="tok-kw">try</span> testing.expect(array[index].id &gt; array[index - <span class="tok-number">1</span>].id);</span>
<span class="line" id="L1386">        } <span class="tok-kw">else</span> {</span>
<span class="line" id="L1387">            <span class="tok-kw">try</span> testing.expect(array[index].value &gt; array[index - <span class="tok-number">1</span>].value);</span>
<span class="line" id="L1388">        }</span>
<span class="line" id="L1389">    }</span>
<span class="line" id="L1390">}</span>
<span class="line" id="L1391"></span>
<span class="line" id="L1392"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">argMin</span>(</span>
<span class="line" id="L1393">    <span class="tok-kw">comptime</span> T: <span class="tok-type">type</span>,</span>
<span class="line" id="L1394">    items: []<span class="tok-kw">const</span> T,</span>
<span class="line" id="L1395">    context: <span class="tok-kw">anytype</span>,</span>
<span class="line" id="L1396">    <span class="tok-kw">comptime</span> lessThan: <span class="tok-kw">fn</span> (<span class="tok-builtin">@TypeOf</span>(context), lhs: T, rhs: T) <span class="tok-type">bool</span>,</span>
<span class="line" id="L1397">) ?<span class="tok-type">usize</span> {</span>
<span class="line" id="L1398">    <span class="tok-kw">if</span> (items.len == <span class="tok-number">0</span>) {</span>
<span class="line" id="L1399">        <span class="tok-kw">return</span> <span class="tok-null">null</span>;</span>
<span class="line" id="L1400">    }</span>
<span class="line" id="L1401"></span>
<span class="line" id="L1402">    <span class="tok-kw">var</span> smallest = items[<span class="tok-number">0</span>];</span>
<span class="line" id="L1403">    <span class="tok-kw">var</span> smallest_index: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L1404">    <span class="tok-kw">for</span> (items[<span class="tok-number">1</span>..]) |item, i| {</span>
<span class="line" id="L1405">        <span class="tok-kw">if</span> (lessThan(context, item, smallest)) {</span>
<span class="line" id="L1406">            smallest = item;</span>
<span class="line" id="L1407">            smallest_index = i + <span class="tok-number">1</span>;</span>
<span class="line" id="L1408">        }</span>
<span class="line" id="L1409">    }</span>
<span class="line" id="L1410"></span>
<span class="line" id="L1411">    <span class="tok-kw">return</span> smallest_index;</span>
<span class="line" id="L1412">}</span>
<span class="line" id="L1413"></span>
<span class="line" id="L1414"><span class="tok-kw">test</span> <span class="tok-str">&quot;argMin&quot;</span> {</span>
<span class="line" id="L1415">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(?<span class="tok-type">usize</span>, <span class="tok-null">null</span>), argMin(<span class="tok-type">i32</span>, &amp;[_]<span class="tok-type">i32</span>{}, {}, asc_i32));</span>
<span class="line" id="L1416">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(?<span class="tok-type">usize</span>, <span class="tok-number">0</span>), argMin(<span class="tok-type">i32</span>, &amp;[_]<span class="tok-type">i32</span>{<span class="tok-number">1</span>}, {}, asc_i32));</span>
<span class="line" id="L1417">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(?<span class="tok-type">usize</span>, <span class="tok-number">0</span>), argMin(<span class="tok-type">i32</span>, &amp;[_]<span class="tok-type">i32</span>{ <span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">4</span>, <span class="tok-number">5</span> }, {}, asc_i32));</span>
<span class="line" id="L1418">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(?<span class="tok-type">usize</span>, <span class="tok-number">3</span>), argMin(<span class="tok-type">i32</span>, &amp;[_]<span class="tok-type">i32</span>{ <span class="tok-number">9</span>, <span class="tok-number">3</span>, <span class="tok-number">8</span>, <span class="tok-number">2</span>, <span class="tok-number">5</span> }, {}, asc_i32));</span>
<span class="line" id="L1419">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(?<span class="tok-type">usize</span>, <span class="tok-number">0</span>), argMin(<span class="tok-type">i32</span>, &amp;[_]<span class="tok-type">i32</span>{ <span class="tok-number">1</span>, <span class="tok-number">1</span>, <span class="tok-number">1</span>, <span class="tok-number">1</span>, <span class="tok-number">1</span> }, {}, asc_i32));</span>
<span class="line" id="L1420">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(?<span class="tok-type">usize</span>, <span class="tok-number">0</span>), argMin(<span class="tok-type">i32</span>, &amp;[_]<span class="tok-type">i32</span>{ -<span class="tok-number">10</span>, <span class="tok-number">1</span>, <span class="tok-number">10</span> }, {}, asc_i32));</span>
<span class="line" id="L1421">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(?<span class="tok-type">usize</span>, <span class="tok-number">3</span>), argMin(<span class="tok-type">i32</span>, &amp;[_]<span class="tok-type">i32</span>{ <span class="tok-number">6</span>, <span class="tok-number">3</span>, <span class="tok-number">5</span>, <span class="tok-number">7</span>, <span class="tok-number">6</span> }, {}, desc_i32));</span>
<span class="line" id="L1422">}</span>
<span class="line" id="L1423"></span>
<span class="line" id="L1424"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">min</span>(</span>
<span class="line" id="L1425">    <span class="tok-kw">comptime</span> T: <span class="tok-type">type</span>,</span>
<span class="line" id="L1426">    items: []<span class="tok-kw">const</span> T,</span>
<span class="line" id="L1427">    context: <span class="tok-kw">anytype</span>,</span>
<span class="line" id="L1428">    <span class="tok-kw">comptime</span> lessThan: <span class="tok-kw">fn</span> (context: <span class="tok-builtin">@TypeOf</span>(context), lhs: T, rhs: T) <span class="tok-type">bool</span>,</span>
<span class="line" id="L1429">) ?T {</span>
<span class="line" id="L1430">    <span class="tok-kw">const</span> i = argMin(T, items, context, lessThan) <span class="tok-kw">orelse</span> <span class="tok-kw">return</span> <span class="tok-null">null</span>;</span>
<span class="line" id="L1431">    <span class="tok-kw">return</span> items[i];</span>
<span class="line" id="L1432">}</span>
<span class="line" id="L1433"></span>
<span class="line" id="L1434"><span class="tok-kw">test</span> <span class="tok-str">&quot;min&quot;</span> {</span>
<span class="line" id="L1435">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(?<span class="tok-type">i32</span>, <span class="tok-null">null</span>), min(<span class="tok-type">i32</span>, &amp;[_]<span class="tok-type">i32</span>{}, {}, asc_i32));</span>
<span class="line" id="L1436">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(?<span class="tok-type">i32</span>, <span class="tok-number">1</span>), min(<span class="tok-type">i32</span>, &amp;[_]<span class="tok-type">i32</span>{<span class="tok-number">1</span>}, {}, asc_i32));</span>
<span class="line" id="L1437">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(?<span class="tok-type">i32</span>, <span class="tok-number">1</span>), min(<span class="tok-type">i32</span>, &amp;[_]<span class="tok-type">i32</span>{ <span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">4</span>, <span class="tok-number">5</span> }, {}, asc_i32));</span>
<span class="line" id="L1438">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(?<span class="tok-type">i32</span>, <span class="tok-number">2</span>), min(<span class="tok-type">i32</span>, &amp;[_]<span class="tok-type">i32</span>{ <span class="tok-number">9</span>, <span class="tok-number">3</span>, <span class="tok-number">8</span>, <span class="tok-number">2</span>, <span class="tok-number">5</span> }, {}, asc_i32));</span>
<span class="line" id="L1439">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(?<span class="tok-type">i32</span>, <span class="tok-number">1</span>), min(<span class="tok-type">i32</span>, &amp;[_]<span class="tok-type">i32</span>{ <span class="tok-number">1</span>, <span class="tok-number">1</span>, <span class="tok-number">1</span>, <span class="tok-number">1</span>, <span class="tok-number">1</span> }, {}, asc_i32));</span>
<span class="line" id="L1440">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(?<span class="tok-type">i32</span>, -<span class="tok-number">10</span>), min(<span class="tok-type">i32</span>, &amp;[_]<span class="tok-type">i32</span>{ -<span class="tok-number">10</span>, <span class="tok-number">1</span>, <span class="tok-number">10</span> }, {}, asc_i32));</span>
<span class="line" id="L1441">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(?<span class="tok-type">i32</span>, <span class="tok-number">7</span>), min(<span class="tok-type">i32</span>, &amp;[_]<span class="tok-type">i32</span>{ <span class="tok-number">6</span>, <span class="tok-number">3</span>, <span class="tok-number">5</span>, <span class="tok-number">7</span>, <span class="tok-number">6</span> }, {}, desc_i32));</span>
<span class="line" id="L1442">}</span>
<span class="line" id="L1443"></span>
<span class="line" id="L1444"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">argMax</span>(</span>
<span class="line" id="L1445">    <span class="tok-kw">comptime</span> T: <span class="tok-type">type</span>,</span>
<span class="line" id="L1446">    items: []<span class="tok-kw">const</span> T,</span>
<span class="line" id="L1447">    context: <span class="tok-kw">anytype</span>,</span>
<span class="line" id="L1448">    <span class="tok-kw">comptime</span> lessThan: <span class="tok-kw">fn</span> (context: <span class="tok-builtin">@TypeOf</span>(context), lhs: T, rhs: T) <span class="tok-type">bool</span>,</span>
<span class="line" id="L1449">) ?<span class="tok-type">usize</span> {</span>
<span class="line" id="L1450">    <span class="tok-kw">if</span> (items.len == <span class="tok-number">0</span>) {</span>
<span class="line" id="L1451">        <span class="tok-kw">return</span> <span class="tok-null">null</span>;</span>
<span class="line" id="L1452">    }</span>
<span class="line" id="L1453"></span>
<span class="line" id="L1454">    <span class="tok-kw">var</span> biggest = items[<span class="tok-number">0</span>];</span>
<span class="line" id="L1455">    <span class="tok-kw">var</span> biggest_index: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L1456">    <span class="tok-kw">for</span> (items[<span class="tok-number">1</span>..]) |item, i| {</span>
<span class="line" id="L1457">        <span class="tok-kw">if</span> (lessThan(context, biggest, item)) {</span>
<span class="line" id="L1458">            biggest = item;</span>
<span class="line" id="L1459">            biggest_index = i + <span class="tok-number">1</span>;</span>
<span class="line" id="L1460">        }</span>
<span class="line" id="L1461">    }</span>
<span class="line" id="L1462"></span>
<span class="line" id="L1463">    <span class="tok-kw">return</span> biggest_index;</span>
<span class="line" id="L1464">}</span>
<span class="line" id="L1465"></span>
<span class="line" id="L1466"><span class="tok-kw">test</span> <span class="tok-str">&quot;argMax&quot;</span> {</span>
<span class="line" id="L1467">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(?<span class="tok-type">usize</span>, <span class="tok-null">null</span>), argMax(<span class="tok-type">i32</span>, &amp;[_]<span class="tok-type">i32</span>{}, {}, asc_i32));</span>
<span class="line" id="L1468">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(?<span class="tok-type">usize</span>, <span class="tok-number">0</span>), argMax(<span class="tok-type">i32</span>, &amp;[_]<span class="tok-type">i32</span>{<span class="tok-number">1</span>}, {}, asc_i32));</span>
<span class="line" id="L1469">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(?<span class="tok-type">usize</span>, <span class="tok-number">4</span>), argMax(<span class="tok-type">i32</span>, &amp;[_]<span class="tok-type">i32</span>{ <span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">4</span>, <span class="tok-number">5</span> }, {}, asc_i32));</span>
<span class="line" id="L1470">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(?<span class="tok-type">usize</span>, <span class="tok-number">0</span>), argMax(<span class="tok-type">i32</span>, &amp;[_]<span class="tok-type">i32</span>{ <span class="tok-number">9</span>, <span class="tok-number">3</span>, <span class="tok-number">8</span>, <span class="tok-number">2</span>, <span class="tok-number">5</span> }, {}, asc_i32));</span>
<span class="line" id="L1471">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(?<span class="tok-type">usize</span>, <span class="tok-number">0</span>), argMax(<span class="tok-type">i32</span>, &amp;[_]<span class="tok-type">i32</span>{ <span class="tok-number">1</span>, <span class="tok-number">1</span>, <span class="tok-number">1</span>, <span class="tok-number">1</span>, <span class="tok-number">1</span> }, {}, asc_i32));</span>
<span class="line" id="L1472">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(?<span class="tok-type">usize</span>, <span class="tok-number">2</span>), argMax(<span class="tok-type">i32</span>, &amp;[_]<span class="tok-type">i32</span>{ -<span class="tok-number">10</span>, <span class="tok-number">1</span>, <span class="tok-number">10</span> }, {}, asc_i32));</span>
<span class="line" id="L1473">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(?<span class="tok-type">usize</span>, <span class="tok-number">1</span>), argMax(<span class="tok-type">i32</span>, &amp;[_]<span class="tok-type">i32</span>{ <span class="tok-number">6</span>, <span class="tok-number">3</span>, <span class="tok-number">5</span>, <span class="tok-number">7</span>, <span class="tok-number">6</span> }, {}, desc_i32));</span>
<span class="line" id="L1474">}</span>
<span class="line" id="L1475"></span>
<span class="line" id="L1476"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">max</span>(</span>
<span class="line" id="L1477">    <span class="tok-kw">comptime</span> T: <span class="tok-type">type</span>,</span>
<span class="line" id="L1478">    items: []<span class="tok-kw">const</span> T,</span>
<span class="line" id="L1479">    context: <span class="tok-kw">anytype</span>,</span>
<span class="line" id="L1480">    <span class="tok-kw">comptime</span> lessThan: <span class="tok-kw">fn</span> (context: <span class="tok-builtin">@TypeOf</span>(context), lhs: T, rhs: T) <span class="tok-type">bool</span>,</span>
<span class="line" id="L1481">) ?T {</span>
<span class="line" id="L1482">    <span class="tok-kw">const</span> i = argMax(T, items, context, lessThan) <span class="tok-kw">orelse</span> <span class="tok-kw">return</span> <span class="tok-null">null</span>;</span>
<span class="line" id="L1483">    <span class="tok-kw">return</span> items[i];</span>
<span class="line" id="L1484">}</span>
<span class="line" id="L1485"></span>
<span class="line" id="L1486"><span class="tok-kw">test</span> <span class="tok-str">&quot;max&quot;</span> {</span>
<span class="line" id="L1487">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(?<span class="tok-type">i32</span>, <span class="tok-null">null</span>), max(<span class="tok-type">i32</span>, &amp;[_]<span class="tok-type">i32</span>{}, {}, asc_i32));</span>
<span class="line" id="L1488">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(?<span class="tok-type">i32</span>, <span class="tok-number">1</span>), max(<span class="tok-type">i32</span>, &amp;[_]<span class="tok-type">i32</span>{<span class="tok-number">1</span>}, {}, asc_i32));</span>
<span class="line" id="L1489">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(?<span class="tok-type">i32</span>, <span class="tok-number">5</span>), max(<span class="tok-type">i32</span>, &amp;[_]<span class="tok-type">i32</span>{ <span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">4</span>, <span class="tok-number">5</span> }, {}, asc_i32));</span>
<span class="line" id="L1490">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(?<span class="tok-type">i32</span>, <span class="tok-number">9</span>), max(<span class="tok-type">i32</span>, &amp;[_]<span class="tok-type">i32</span>{ <span class="tok-number">9</span>, <span class="tok-number">3</span>, <span class="tok-number">8</span>, <span class="tok-number">2</span>, <span class="tok-number">5</span> }, {}, asc_i32));</span>
<span class="line" id="L1491">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(?<span class="tok-type">i32</span>, <span class="tok-number">1</span>), max(<span class="tok-type">i32</span>, &amp;[_]<span class="tok-type">i32</span>{ <span class="tok-number">1</span>, <span class="tok-number">1</span>, <span class="tok-number">1</span>, <span class="tok-number">1</span>, <span class="tok-number">1</span> }, {}, asc_i32));</span>
<span class="line" id="L1492">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(?<span class="tok-type">i32</span>, <span class="tok-number">10</span>), max(<span class="tok-type">i32</span>, &amp;[_]<span class="tok-type">i32</span>{ -<span class="tok-number">10</span>, <span class="tok-number">1</span>, <span class="tok-number">10</span> }, {}, asc_i32));</span>
<span class="line" id="L1493">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(?<span class="tok-type">i32</span>, <span class="tok-number">3</span>), max(<span class="tok-type">i32</span>, &amp;[_]<span class="tok-type">i32</span>{ <span class="tok-number">6</span>, <span class="tok-number">3</span>, <span class="tok-number">5</span>, <span class="tok-number">7</span>, <span class="tok-number">6</span> }, {}, desc_i32));</span>
<span class="line" id="L1494">}</span>
<span class="line" id="L1495"></span>
<span class="line" id="L1496"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">isSorted</span>(</span>
<span class="line" id="L1497">    <span class="tok-kw">comptime</span> T: <span class="tok-type">type</span>,</span>
<span class="line" id="L1498">    items: []<span class="tok-kw">const</span> T,</span>
<span class="line" id="L1499">    context: <span class="tok-kw">anytype</span>,</span>
<span class="line" id="L1500">    <span class="tok-kw">comptime</span> lessThan: <span class="tok-kw">fn</span> (context: <span class="tok-builtin">@TypeOf</span>(context), lhs: T, rhs: T) <span class="tok-type">bool</span>,</span>
<span class="line" id="L1501">) <span class="tok-type">bool</span> {</span>
<span class="line" id="L1502">    <span class="tok-kw">var</span> i: <span class="tok-type">usize</span> = <span class="tok-number">1</span>;</span>
<span class="line" id="L1503">    <span class="tok-kw">while</span> (i &lt; items.len) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L1504">        <span class="tok-kw">if</span> (lessThan(context, items[i], items[i - <span class="tok-number">1</span>])) {</span>
<span class="line" id="L1505">            <span class="tok-kw">return</span> <span class="tok-null">false</span>;</span>
<span class="line" id="L1506">        }</span>
<span class="line" id="L1507">    }</span>
<span class="line" id="L1508"></span>
<span class="line" id="L1509">    <span class="tok-kw">return</span> <span class="tok-null">true</span>;</span>
<span class="line" id="L1510">}</span>
<span class="line" id="L1511"></span>
<span class="line" id="L1512"><span class="tok-kw">test</span> <span class="tok-str">&quot;isSorted&quot;</span> {</span>
<span class="line" id="L1513">    <span class="tok-kw">try</span> testing.expect(isSorted(<span class="tok-type">i32</span>, &amp;[_]<span class="tok-type">i32</span>{}, {}, asc_i32));</span>
<span class="line" id="L1514">    <span class="tok-kw">try</span> testing.expect(isSorted(<span class="tok-type">i32</span>, &amp;[_]<span class="tok-type">i32</span>{<span class="tok-number">10</span>}, {}, asc_i32));</span>
<span class="line" id="L1515">    <span class="tok-kw">try</span> testing.expect(isSorted(<span class="tok-type">i32</span>, &amp;[_]<span class="tok-type">i32</span>{ <span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">4</span>, <span class="tok-number">5</span> }, {}, asc_i32));</span>
<span class="line" id="L1516">    <span class="tok-kw">try</span> testing.expect(isSorted(<span class="tok-type">i32</span>, &amp;[_]<span class="tok-type">i32</span>{ -<span class="tok-number">10</span>, <span class="tok-number">1</span>, <span class="tok-number">1</span>, <span class="tok-number">1</span>, <span class="tok-number">10</span> }, {}, asc_i32));</span>
<span class="line" id="L1517"></span>
<span class="line" id="L1518">    <span class="tok-kw">try</span> testing.expect(isSorted(<span class="tok-type">i32</span>, &amp;[_]<span class="tok-type">i32</span>{}, {}, desc_i32));</span>
<span class="line" id="L1519">    <span class="tok-kw">try</span> testing.expect(isSorted(<span class="tok-type">i32</span>, &amp;[_]<span class="tok-type">i32</span>{-<span class="tok-number">20</span>}, {}, desc_i32));</span>
<span class="line" id="L1520">    <span class="tok-kw">try</span> testing.expect(isSorted(<span class="tok-type">i32</span>, &amp;[_]<span class="tok-type">i32</span>{ <span class="tok-number">3</span>, <span class="tok-number">2</span>, <span class="tok-number">1</span>, <span class="tok-number">0</span>, -<span class="tok-number">1</span> }, {}, desc_i32));</span>
<span class="line" id="L1521">    <span class="tok-kw">try</span> testing.expect(isSorted(<span class="tok-type">i32</span>, &amp;[_]<span class="tok-type">i32</span>{ <span class="tok-number">10</span>, -<span class="tok-number">10</span> }, {}, desc_i32));</span>
<span class="line" id="L1522"></span>
<span class="line" id="L1523">    <span class="tok-kw">try</span> testing.expect(isSorted(<span class="tok-type">i32</span>, &amp;[_]<span class="tok-type">i32</span>{ <span class="tok-number">1</span>, <span class="tok-number">1</span>, <span class="tok-number">1</span>, <span class="tok-number">1</span>, <span class="tok-number">1</span> }, {}, asc_i32));</span>
<span class="line" id="L1524">    <span class="tok-kw">try</span> testing.expect(isSorted(<span class="tok-type">i32</span>, &amp;[_]<span class="tok-type">i32</span>{ <span class="tok-number">1</span>, <span class="tok-number">1</span>, <span class="tok-number">1</span>, <span class="tok-number">1</span>, <span class="tok-number">1</span> }, {}, desc_i32));</span>
<span class="line" id="L1525"></span>
<span class="line" id="L1526">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-null">false</span>, isSorted(<span class="tok-type">i32</span>, &amp;[_]<span class="tok-type">i32</span>{ <span class="tok-number">5</span>, <span class="tok-number">4</span>, <span class="tok-number">3</span>, <span class="tok-number">2</span>, <span class="tok-number">1</span> }, {}, asc_i32));</span>
<span class="line" id="L1527">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-null">false</span>, isSorted(<span class="tok-type">i32</span>, &amp;[_]<span class="tok-type">i32</span>{ <span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">4</span>, <span class="tok-number">5</span> }, {}, desc_i32));</span>
<span class="line" id="L1528"></span>
<span class="line" id="L1529">    <span class="tok-kw">try</span> testing.expect(isSorted(<span class="tok-type">u8</span>, <span class="tok-str">&quot;abcd&quot;</span>, {}, asc_u8));</span>
<span class="line" id="L1530">    <span class="tok-kw">try</span> testing.expect(isSorted(<span class="tok-type">u8</span>, <span class="tok-str">&quot;zyxw&quot;</span>, {}, desc_u8));</span>
<span class="line" id="L1531"></span>
<span class="line" id="L1532">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-null">false</span>, isSorted(<span class="tok-type">u8</span>, <span class="tok-str">&quot;abcd&quot;</span>, {}, desc_u8));</span>
<span class="line" id="L1533">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-null">false</span>, isSorted(<span class="tok-type">u8</span>, <span class="tok-str">&quot;zyxw&quot;</span>, {}, asc_u8));</span>
<span class="line" id="L1534"></span>
<span class="line" id="L1535">    <span class="tok-kw">try</span> testing.expect(isSorted(<span class="tok-type">u8</span>, <span class="tok-str">&quot;ffff&quot;</span>, {}, asc_u8));</span>
<span class="line" id="L1536">    <span class="tok-kw">try</span> testing.expect(isSorted(<span class="tok-type">u8</span>, <span class="tok-str">&quot;ffff&quot;</span>, {}, desc_u8));</span>
<span class="line" id="L1537">}</span>
<span class="line" id="L1538"></span>
</code></pre></body>
</html>