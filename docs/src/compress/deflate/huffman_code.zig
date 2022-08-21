<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">    <title>compress/deflate/huffman_code.zig - source view</title>
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
<span class="line" id="L2"><span class="tok-kw">const</span> assert = std.debug.assert;</span>
<span class="line" id="L3"><span class="tok-kw">const</span> math = std.math;</span>
<span class="line" id="L4"><span class="tok-kw">const</span> mem = std.mem;</span>
<span class="line" id="L5"><span class="tok-kw">const</span> sort = std.sort;</span>
<span class="line" id="L6"><span class="tok-kw">const</span> testing = std.testing;</span>
<span class="line" id="L7"></span>
<span class="line" id="L8"><span class="tok-kw">const</span> Allocator = std.mem.Allocator;</span>
<span class="line" id="L9"></span>
<span class="line" id="L10"><span class="tok-kw">const</span> bu = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;bits_utils.zig&quot;</span>);</span>
<span class="line" id="L11"><span class="tok-kw">const</span> deflate_const = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;deflate_const.zig&quot;</span>);</span>
<span class="line" id="L12"></span>
<span class="line" id="L13"><span class="tok-kw">const</span> max_bits_limit = <span class="tok-number">16</span>;</span>
<span class="line" id="L14"></span>
<span class="line" id="L15"><span class="tok-kw">const</span> LiteralNode = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L16">    literal: <span class="tok-type">u16</span>,</span>
<span class="line" id="L17">    freq: <span class="tok-type">u16</span>,</span>
<span class="line" id="L18">};</span>
<span class="line" id="L19"></span>
<span class="line" id="L20"><span class="tok-comment">// Describes the state of the constructed tree for a given depth.</span>
</span>
<span class="line" id="L21"><span class="tok-kw">const</span> LevelInfo = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L22">    <span class="tok-comment">// Our level.  for better printing</span>
</span>
<span class="line" id="L23">    level: <span class="tok-type">u32</span>,</span>
<span class="line" id="L24"></span>
<span class="line" id="L25">    <span class="tok-comment">// The frequency of the last node at this level</span>
</span>
<span class="line" id="L26">    last_freq: <span class="tok-type">u32</span>,</span>
<span class="line" id="L27"></span>
<span class="line" id="L28">    <span class="tok-comment">// The frequency of the next character to add to this level</span>
</span>
<span class="line" id="L29">    next_char_freq: <span class="tok-type">u32</span>,</span>
<span class="line" id="L30"></span>
<span class="line" id="L31">    <span class="tok-comment">// The frequency of the next pair (from level below) to add to this level.</span>
</span>
<span class="line" id="L32">    <span class="tok-comment">// Only valid if the &quot;needed&quot; value of the next lower level is 0.</span>
</span>
<span class="line" id="L33">    next_pair_freq: <span class="tok-type">u32</span>,</span>
<span class="line" id="L34"></span>
<span class="line" id="L35">    <span class="tok-comment">// The number of chains remaining to generate for this level before moving</span>
</span>
<span class="line" id="L36">    <span class="tok-comment">// up to the next level</span>
</span>
<span class="line" id="L37">    needed: <span class="tok-type">u32</span>,</span>
<span class="line" id="L38">};</span>
<span class="line" id="L39"></span>
<span class="line" id="L40"><span class="tok-comment">// hcode is a huffman code with a bit code and bit length.</span>
</span>
<span class="line" id="L41"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> HuffCode = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L42">    code: <span class="tok-type">u16</span> = <span class="tok-number">0</span>,</span>
<span class="line" id="L43">    len: <span class="tok-type">u16</span> = <span class="tok-number">0</span>,</span>
<span class="line" id="L44"></span>
<span class="line" id="L45">    <span class="tok-comment">// set sets the code and length of an hcode.</span>
</span>
<span class="line" id="L46">    <span class="tok-kw">fn</span> <span class="tok-fn">set</span>(self: *HuffCode, code: <span class="tok-type">u16</span>, length: <span class="tok-type">u16</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L47">        self.len = length;</span>
<span class="line" id="L48">        self.code = code;</span>
<span class="line" id="L49">    }</span>
<span class="line" id="L50">};</span>
<span class="line" id="L51"></span>
<span class="line" id="L52"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> HuffmanEncoder = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L53">    codes: []HuffCode,</span>
<span class="line" id="L54">    freq_cache: []LiteralNode = <span class="tok-null">undefined</span>,</span>
<span class="line" id="L55">    bit_count: [<span class="tok-number">17</span>]<span class="tok-type">u32</span> = <span class="tok-null">undefined</span>,</span>
<span class="line" id="L56">    lns: []LiteralNode = <span class="tok-null">undefined</span>, <span class="tok-comment">// sorted by literal, stored to avoid repeated allocation in generate</span>
</span>
<span class="line" id="L57">    lfs: []LiteralNode = <span class="tok-null">undefined</span>, <span class="tok-comment">// sorted by frequency, stored to avoid repeated allocation in generate</span>
</span>
<span class="line" id="L58">    allocator: Allocator,</span>
<span class="line" id="L59"></span>
<span class="line" id="L60">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">deinit</span>(self: *HuffmanEncoder) <span class="tok-type">void</span> {</span>
<span class="line" id="L61">        self.allocator.free(self.codes);</span>
<span class="line" id="L62">        self.allocator.free(self.freq_cache);</span>
<span class="line" id="L63">    }</span>
<span class="line" id="L64"></span>
<span class="line" id="L65">    <span class="tok-comment">// Update this Huffman Code object to be the minimum code for the specified frequency count.</span>
</span>
<span class="line" id="L66">    <span class="tok-comment">//</span>
</span>
<span class="line" id="L67">    <span class="tok-comment">// freq  An array of frequencies, in which frequency[i] gives the frequency of literal i.</span>
</span>
<span class="line" id="L68">    <span class="tok-comment">// max_bits  The maximum number of bits to use for any literal.</span>
</span>
<span class="line" id="L69">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">generate</span>(self: *HuffmanEncoder, freq: []<span class="tok-type">u16</span>, max_bits: <span class="tok-type">u32</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L70">        <span class="tok-kw">var</span> list = self.freq_cache[<span class="tok-number">0</span> .. freq.len + <span class="tok-number">1</span>];</span>
<span class="line" id="L71">        <span class="tok-comment">// Number of non-zero literals</span>
</span>
<span class="line" id="L72">        <span class="tok-kw">var</span> count: <span class="tok-type">u32</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L73">        <span class="tok-comment">// Set list to be the set of all non-zero literals and their frequencies</span>
</span>
<span class="line" id="L74">        <span class="tok-kw">for</span> (freq) |f, i| {</span>
<span class="line" id="L75">            <span class="tok-kw">if</span> (f != <span class="tok-number">0</span>) {</span>
<span class="line" id="L76">                list[count] = LiteralNode{ .literal = <span class="tok-builtin">@intCast</span>(<span class="tok-type">u16</span>, i), .freq = f };</span>
<span class="line" id="L77">                count += <span class="tok-number">1</span>;</span>
<span class="line" id="L78">            } <span class="tok-kw">else</span> {</span>
<span class="line" id="L79">                list[count] = LiteralNode{ .literal = <span class="tok-number">0x00</span>, .freq = <span class="tok-number">0</span> };</span>
<span class="line" id="L80">                self.codes[i].len = <span class="tok-number">0</span>;</span>
<span class="line" id="L81">            }</span>
<span class="line" id="L82">        }</span>
<span class="line" id="L83">        list[freq.len] = LiteralNode{ .literal = <span class="tok-number">0x00</span>, .freq = <span class="tok-number">0</span> };</span>
<span class="line" id="L84"></span>
<span class="line" id="L85">        list = list[<span class="tok-number">0</span>..count];</span>
<span class="line" id="L86">        <span class="tok-kw">if</span> (count &lt;= <span class="tok-number">2</span>) {</span>
<span class="line" id="L87">            <span class="tok-comment">// Handle the small cases here, because they are awkward for the general case code. With</span>
</span>
<span class="line" id="L88">            <span class="tok-comment">// two or fewer literals, everything has bit length 1.</span>
</span>
<span class="line" id="L89">            <span class="tok-kw">for</span> (list) |node, i| {</span>
<span class="line" id="L90">                <span class="tok-comment">// &quot;list&quot; is in order of increasing literal value.</span>
</span>
<span class="line" id="L91">                self.codes[node.literal].set(<span class="tok-builtin">@intCast</span>(<span class="tok-type">u16</span>, i), <span class="tok-number">1</span>);</span>
<span class="line" id="L92">            }</span>
<span class="line" id="L93">            <span class="tok-kw">return</span>;</span>
<span class="line" id="L94">        }</span>
<span class="line" id="L95">        self.lfs = list;</span>
<span class="line" id="L96">        sort.sort(LiteralNode, self.lfs, {}, byFreq);</span>
<span class="line" id="L97"></span>
<span class="line" id="L98">        <span class="tok-comment">// Get the number of literals for each bit count</span>
</span>
<span class="line" id="L99">        <span class="tok-kw">var</span> bit_count = self.bitCounts(list, max_bits);</span>
<span class="line" id="L100">        <span class="tok-comment">// And do the assignment</span>
</span>
<span class="line" id="L101">        self.assignEncodingAndSize(bit_count, list);</span>
<span class="line" id="L102">    }</span>
<span class="line" id="L103"></span>
<span class="line" id="L104">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">bitLength</span>(self: *HuffmanEncoder, freq: []<span class="tok-type">u16</span>) <span class="tok-type">u32</span> {</span>
<span class="line" id="L105">        <span class="tok-kw">var</span> total: <span class="tok-type">u32</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L106">        <span class="tok-kw">for</span> (freq) |f, i| {</span>
<span class="line" id="L107">            <span class="tok-kw">if</span> (f != <span class="tok-number">0</span>) {</span>
<span class="line" id="L108">                total += <span class="tok-builtin">@intCast</span>(<span class="tok-type">u32</span>, f) * <span class="tok-builtin">@intCast</span>(<span class="tok-type">u32</span>, self.codes[i].len);</span>
<span class="line" id="L109">            }</span>
<span class="line" id="L110">        }</span>
<span class="line" id="L111">        <span class="tok-kw">return</span> total;</span>
<span class="line" id="L112">    }</span>
<span class="line" id="L113"></span>
<span class="line" id="L114">    <span class="tok-comment">// Return the number of literals assigned to each bit size in the Huffman encoding</span>
</span>
<span class="line" id="L115">    <span class="tok-comment">//</span>
</span>
<span class="line" id="L116">    <span class="tok-comment">// This method is only called when list.len &gt;= 3</span>
</span>
<span class="line" id="L117">    <span class="tok-comment">// The cases of 0, 1, and 2 literals are handled by special case code.</span>
</span>
<span class="line" id="L118">    <span class="tok-comment">//</span>
</span>
<span class="line" id="L119">    <span class="tok-comment">// list: An array of the literals with non-zero frequencies</span>
</span>
<span class="line" id="L120">    <span class="tok-comment">// and their associated frequencies. The array is in order of increasing</span>
</span>
<span class="line" id="L121">    <span class="tok-comment">// frequency, and has as its last element a special element with frequency</span>
</span>
<span class="line" id="L122">    <span class="tok-comment">// std.math.maxInt(i32)</span>
</span>
<span class="line" id="L123">    <span class="tok-comment">//</span>
</span>
<span class="line" id="L124">    <span class="tok-comment">// max_bits: The maximum number of bits that should be used to encode any literal.</span>
</span>
<span class="line" id="L125">    <span class="tok-comment">// Must be less than 16.</span>
</span>
<span class="line" id="L126">    <span class="tok-comment">//</span>
</span>
<span class="line" id="L127">    <span class="tok-comment">// Returns an integer array in which array[i] indicates the number of literals</span>
</span>
<span class="line" id="L128">    <span class="tok-comment">// that should be encoded in i bits.</span>
</span>
<span class="line" id="L129">    <span class="tok-kw">fn</span> <span class="tok-fn">bitCounts</span>(self: *HuffmanEncoder, list: []LiteralNode, max_bits_to_use: <span class="tok-type">usize</span>) []<span class="tok-type">u32</span> {</span>
<span class="line" id="L130">        <span class="tok-kw">var</span> max_bits = max_bits_to_use;</span>
<span class="line" id="L131">        <span class="tok-kw">var</span> n = list.len;</span>
<span class="line" id="L132"></span>
<span class="line" id="L133">        assert(max_bits &lt; max_bits_limit);</span>
<span class="line" id="L134"></span>
<span class="line" id="L135">        <span class="tok-comment">// The tree can't have greater depth than n - 1, no matter what. This</span>
</span>
<span class="line" id="L136">        <span class="tok-comment">// saves a little bit of work in some small cases</span>
</span>
<span class="line" id="L137">        max_bits = <span class="tok-builtin">@minimum</span>(max_bits, n - <span class="tok-number">1</span>);</span>
<span class="line" id="L138"></span>
<span class="line" id="L139">        <span class="tok-comment">// Create information about each of the levels.</span>
</span>
<span class="line" id="L140">        <span class="tok-comment">// A bogus &quot;Level 0&quot; whose sole purpose is so that</span>
</span>
<span class="line" id="L141">        <span class="tok-comment">// level1.prev.needed == 0.  This makes level1.next_pair_freq</span>
</span>
<span class="line" id="L142">        <span class="tok-comment">// be a legitimate value that never gets chosen.</span>
</span>
<span class="line" id="L143">        <span class="tok-kw">var</span> levels: [max_bits_limit]LevelInfo = mem.zeroes([max_bits_limit]LevelInfo);</span>
<span class="line" id="L144">        <span class="tok-comment">// leaf_counts[i] counts the number of literals at the left</span>
</span>
<span class="line" id="L145">        <span class="tok-comment">// of ancestors of the rightmost node at level i.</span>
</span>
<span class="line" id="L146">        <span class="tok-comment">// leaf_counts[i][j] is the number of literals at the left</span>
</span>
<span class="line" id="L147">        <span class="tok-comment">// of the level j ancestor.</span>
</span>
<span class="line" id="L148">        <span class="tok-kw">var</span> leaf_counts: [max_bits_limit][max_bits_limit]<span class="tok-type">u32</span> = mem.zeroes([max_bits_limit][max_bits_limit]<span class="tok-type">u32</span>);</span>
<span class="line" id="L149"></span>
<span class="line" id="L150">        {</span>
<span class="line" id="L151">            <span class="tok-kw">var</span> level = <span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">1</span>);</span>
<span class="line" id="L152">            <span class="tok-kw">while</span> (level &lt;= max_bits) : (level += <span class="tok-number">1</span>) {</span>
<span class="line" id="L153">                <span class="tok-comment">// For every level, the first two items are the first two characters.</span>
</span>
<span class="line" id="L154">                <span class="tok-comment">// We initialize the levels as if we had already figured this out.</span>
</span>
<span class="line" id="L155">                levels[level] = LevelInfo{</span>
<span class="line" id="L156">                    .level = level,</span>
<span class="line" id="L157">                    .last_freq = list[<span class="tok-number">1</span>].freq,</span>
<span class="line" id="L158">                    .next_char_freq = list[<span class="tok-number">2</span>].freq,</span>
<span class="line" id="L159">                    .next_pair_freq = list[<span class="tok-number">0</span>].freq + list[<span class="tok-number">1</span>].freq,</span>
<span class="line" id="L160">                    .needed = <span class="tok-number">0</span>,</span>
<span class="line" id="L161">                };</span>
<span class="line" id="L162">                leaf_counts[level][level] = <span class="tok-number">2</span>;</span>
<span class="line" id="L163">                <span class="tok-kw">if</span> (level == <span class="tok-number">1</span>) {</span>
<span class="line" id="L164">                    levels[level].next_pair_freq = math.maxInt(<span class="tok-type">i32</span>);</span>
<span class="line" id="L165">                }</span>
<span class="line" id="L166">            }</span>
<span class="line" id="L167">        }</span>
<span class="line" id="L168"></span>
<span class="line" id="L169">        <span class="tok-comment">// We need a total of 2*n - 2 items at top level and have already generated 2.</span>
</span>
<span class="line" id="L170">        levels[max_bits].needed = <span class="tok-number">2</span> * <span class="tok-builtin">@intCast</span>(<span class="tok-type">u32</span>, n) - <span class="tok-number">4</span>;</span>
<span class="line" id="L171"></span>
<span class="line" id="L172">        {</span>
<span class="line" id="L173">            <span class="tok-kw">var</span> level = max_bits;</span>
<span class="line" id="L174">            <span class="tok-kw">while</span> (<span class="tok-null">true</span>) {</span>
<span class="line" id="L175">                <span class="tok-kw">var</span> l = &amp;levels[level];</span>
<span class="line" id="L176">                <span class="tok-kw">if</span> (l.next_pair_freq == math.maxInt(<span class="tok-type">i32</span>) <span class="tok-kw">and</span> l.next_char_freq == math.maxInt(<span class="tok-type">i32</span>)) {</span>
<span class="line" id="L177">                    <span class="tok-comment">// We've run out of both leafs and pairs.</span>
</span>
<span class="line" id="L178">                    <span class="tok-comment">// End all calculations for this level.</span>
</span>
<span class="line" id="L179">                    <span class="tok-comment">// To make sure we never come back to this level or any lower level,</span>
</span>
<span class="line" id="L180">                    <span class="tok-comment">// set next_pair_freq impossibly large.</span>
</span>
<span class="line" id="L181">                    l.needed = <span class="tok-number">0</span>;</span>
<span class="line" id="L182">                    levels[level + <span class="tok-number">1</span>].next_pair_freq = math.maxInt(<span class="tok-type">i32</span>);</span>
<span class="line" id="L183">                    level += <span class="tok-number">1</span>;</span>
<span class="line" id="L184">                    <span class="tok-kw">continue</span>;</span>
<span class="line" id="L185">                }</span>
<span class="line" id="L186"></span>
<span class="line" id="L187">                <span class="tok-kw">var</span> prev_freq = l.last_freq;</span>
<span class="line" id="L188">                <span class="tok-kw">if</span> (l.next_char_freq &lt; l.next_pair_freq) {</span>
<span class="line" id="L189">                    <span class="tok-comment">// The next item on this row is a leaf node.</span>
</span>
<span class="line" id="L190">                    <span class="tok-kw">var</span> next = leaf_counts[level][level] + <span class="tok-number">1</span>;</span>
<span class="line" id="L191">                    l.last_freq = l.next_char_freq;</span>
<span class="line" id="L192">                    <span class="tok-comment">// Lower leaf_counts are the same of the previous node.</span>
</span>
<span class="line" id="L193">                    leaf_counts[level][level] = next;</span>
<span class="line" id="L194">                    <span class="tok-kw">if</span> (next &gt;= list.len) {</span>
<span class="line" id="L195">                        l.next_char_freq = maxNode().freq;</span>
<span class="line" id="L196">                    } <span class="tok-kw">else</span> {</span>
<span class="line" id="L197">                        l.next_char_freq = list[next].freq;</span>
<span class="line" id="L198">                    }</span>
<span class="line" id="L199">                } <span class="tok-kw">else</span> {</span>
<span class="line" id="L200">                    <span class="tok-comment">// The next item on this row is a pair from the previous row.</span>
</span>
<span class="line" id="L201">                    <span class="tok-comment">// next_pair_freq isn't valid until we generate two</span>
</span>
<span class="line" id="L202">                    <span class="tok-comment">// more values in the level below</span>
</span>
<span class="line" id="L203">                    l.last_freq = l.next_pair_freq;</span>
<span class="line" id="L204">                    <span class="tok-comment">// Take leaf counts from the lower level, except counts[level] remains the same.</span>
</span>
<span class="line" id="L205">                    mem.copy(<span class="tok-type">u32</span>, leaf_counts[level][<span class="tok-number">0</span>..level], leaf_counts[level - <span class="tok-number">1</span>][<span class="tok-number">0</span>..level]);</span>
<span class="line" id="L206">                    levels[l.level - <span class="tok-number">1</span>].needed = <span class="tok-number">2</span>;</span>
<span class="line" id="L207">                }</span>
<span class="line" id="L208"></span>
<span class="line" id="L209">                l.needed -= <span class="tok-number">1</span>;</span>
<span class="line" id="L210">                <span class="tok-kw">if</span> (l.needed == <span class="tok-number">0</span>) {</span>
<span class="line" id="L211">                    <span class="tok-comment">// We've done everything we need to do for this level.</span>
</span>
<span class="line" id="L212">                    <span class="tok-comment">// Continue calculating one level up. Fill in next_pair_freq</span>
</span>
<span class="line" id="L213">                    <span class="tok-comment">// of that level with the sum of the two nodes we've just calculated on</span>
</span>
<span class="line" id="L214">                    <span class="tok-comment">// this level.</span>
</span>
<span class="line" id="L215">                    <span class="tok-kw">if</span> (l.level == max_bits) {</span>
<span class="line" id="L216">                        <span class="tok-comment">// All done!</span>
</span>
<span class="line" id="L217">                        <span class="tok-kw">break</span>;</span>
<span class="line" id="L218">                    }</span>
<span class="line" id="L219">                    levels[l.level + <span class="tok-number">1</span>].next_pair_freq = prev_freq + l.last_freq;</span>
<span class="line" id="L220">                    level += <span class="tok-number">1</span>;</span>
<span class="line" id="L221">                } <span class="tok-kw">else</span> {</span>
<span class="line" id="L222">                    <span class="tok-comment">// If we stole from below, move down temporarily to replenish it.</span>
</span>
<span class="line" id="L223">                    <span class="tok-kw">while</span> (levels[level - <span class="tok-number">1</span>].needed &gt; <span class="tok-number">0</span>) {</span>
<span class="line" id="L224">                        level -= <span class="tok-number">1</span>;</span>
<span class="line" id="L225">                        <span class="tok-kw">if</span> (level == <span class="tok-number">0</span>) {</span>
<span class="line" id="L226">                            <span class="tok-kw">break</span>;</span>
<span class="line" id="L227">                        }</span>
<span class="line" id="L228">                    }</span>
<span class="line" id="L229">                }</span>
<span class="line" id="L230">            }</span>
<span class="line" id="L231">        }</span>
<span class="line" id="L232"></span>
<span class="line" id="L233">        <span class="tok-comment">// Somethings is wrong if at the end, the top level is null or hasn't used</span>
</span>
<span class="line" id="L234">        <span class="tok-comment">// all of the leaves.</span>
</span>
<span class="line" id="L235">        assert(leaf_counts[max_bits][max_bits] == n);</span>
<span class="line" id="L236"></span>
<span class="line" id="L237">        <span class="tok-kw">var</span> bit_count = self.bit_count[<span class="tok-number">0</span> .. max_bits + <span class="tok-number">1</span>];</span>
<span class="line" id="L238">        <span class="tok-kw">var</span> bits: <span class="tok-type">u32</span> = <span class="tok-number">1</span>;</span>
<span class="line" id="L239">        <span class="tok-kw">var</span> counts = &amp;leaf_counts[max_bits];</span>
<span class="line" id="L240">        {</span>
<span class="line" id="L241">            <span class="tok-kw">var</span> level = max_bits;</span>
<span class="line" id="L242">            <span class="tok-kw">while</span> (level &gt; <span class="tok-number">0</span>) : (level -= <span class="tok-number">1</span>) {</span>
<span class="line" id="L243">                <span class="tok-comment">// counts[level] gives the number of literals requiring at least &quot;bits&quot;</span>
</span>
<span class="line" id="L244">                <span class="tok-comment">// bits to encode.</span>
</span>
<span class="line" id="L245">                bit_count[bits] = counts[level] - counts[level - <span class="tok-number">1</span>];</span>
<span class="line" id="L246">                bits += <span class="tok-number">1</span>;</span>
<span class="line" id="L247">                <span class="tok-kw">if</span> (level == <span class="tok-number">0</span>) {</span>
<span class="line" id="L248">                    <span class="tok-kw">break</span>;</span>
<span class="line" id="L249">                }</span>
<span class="line" id="L250">            }</span>
<span class="line" id="L251">        }</span>
<span class="line" id="L252">        <span class="tok-kw">return</span> bit_count;</span>
<span class="line" id="L253">    }</span>
<span class="line" id="L254"></span>
<span class="line" id="L255">    <span class="tok-comment">// Look at the leaves and assign them a bit count and an encoding as specified</span>
</span>
<span class="line" id="L256">    <span class="tok-comment">// in RFC 1951 3.2.2</span>
</span>
<span class="line" id="L257">    <span class="tok-kw">fn</span> <span class="tok-fn">assignEncodingAndSize</span>(self: *HuffmanEncoder, bit_count: []<span class="tok-type">u32</span>, list_arg: []LiteralNode) <span class="tok-type">void</span> {</span>
<span class="line" id="L258">        <span class="tok-kw">var</span> code = <span class="tok-builtin">@as</span>(<span class="tok-type">u16</span>, <span class="tok-number">0</span>);</span>
<span class="line" id="L259">        <span class="tok-kw">var</span> list = list_arg;</span>
<span class="line" id="L260"></span>
<span class="line" id="L261">        <span class="tok-kw">for</span> (bit_count) |bits, n| {</span>
<span class="line" id="L262">            code &lt;&lt;= <span class="tok-number">1</span>;</span>
<span class="line" id="L263">            <span class="tok-kw">if</span> (n == <span class="tok-number">0</span> <span class="tok-kw">or</span> bits == <span class="tok-number">0</span>) {</span>
<span class="line" id="L264">                <span class="tok-kw">continue</span>;</span>
<span class="line" id="L265">            }</span>
<span class="line" id="L266">            <span class="tok-comment">// The literals list[list.len-bits] .. list[list.len-bits]</span>
</span>
<span class="line" id="L267">            <span class="tok-comment">// are encoded using &quot;bits&quot; bits, and get the values</span>
</span>
<span class="line" id="L268">            <span class="tok-comment">// code, code + 1, ....  The code values are</span>
</span>
<span class="line" id="L269">            <span class="tok-comment">// assigned in literal order (not frequency order).</span>
</span>
<span class="line" id="L270">            <span class="tok-kw">var</span> chunk = list[list.len - <span class="tok-builtin">@intCast</span>(<span class="tok-type">u32</span>, bits) ..];</span>
<span class="line" id="L271"></span>
<span class="line" id="L272">            self.lns = chunk;</span>
<span class="line" id="L273">            sort.sort(LiteralNode, self.lns, {}, byLiteral);</span>
<span class="line" id="L274"></span>
<span class="line" id="L275">            <span class="tok-kw">for</span> (chunk) |node| {</span>
<span class="line" id="L276">                self.codes[node.literal] = HuffCode{</span>
<span class="line" id="L277">                    .code = bu.bitReverse(<span class="tok-type">u16</span>, code, <span class="tok-builtin">@intCast</span>(<span class="tok-type">u5</span>, n)),</span>
<span class="line" id="L278">                    .len = <span class="tok-builtin">@intCast</span>(<span class="tok-type">u16</span>, n),</span>
<span class="line" id="L279">                };</span>
<span class="line" id="L280">                code += <span class="tok-number">1</span>;</span>
<span class="line" id="L281">            }</span>
<span class="line" id="L282">            list = list[<span class="tok-number">0</span> .. list.len - <span class="tok-builtin">@intCast</span>(<span class="tok-type">u32</span>, bits)];</span>
<span class="line" id="L283">        }</span>
<span class="line" id="L284">    }</span>
<span class="line" id="L285">};</span>
<span class="line" id="L286"></span>
<span class="line" id="L287"><span class="tok-kw">fn</span> <span class="tok-fn">maxNode</span>() LiteralNode {</span>
<span class="line" id="L288">    <span class="tok-kw">return</span> LiteralNode{</span>
<span class="line" id="L289">        .literal = math.maxInt(<span class="tok-type">u16</span>),</span>
<span class="line" id="L290">        .freq = math.maxInt(<span class="tok-type">u16</span>),</span>
<span class="line" id="L291">    };</span>
<span class="line" id="L292">}</span>
<span class="line" id="L293"></span>
<span class="line" id="L294"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">newHuffmanEncoder</span>(allocator: Allocator, size: <span class="tok-type">u32</span>) !HuffmanEncoder {</span>
<span class="line" id="L295">    <span class="tok-kw">return</span> HuffmanEncoder{</span>
<span class="line" id="L296">        .codes = <span class="tok-kw">try</span> allocator.alloc(HuffCode, size),</span>
<span class="line" id="L297">        <span class="tok-comment">// Allocate a reusable buffer with the longest possible frequency table.</span>
</span>
<span class="line" id="L298">        <span class="tok-comment">// (deflate_const.max_num_frequencies).</span>
</span>
<span class="line" id="L299">        .freq_cache = <span class="tok-kw">try</span> allocator.alloc(LiteralNode, deflate_const.max_num_frequencies + <span class="tok-number">1</span>),</span>
<span class="line" id="L300">        .allocator = allocator,</span>
<span class="line" id="L301">    };</span>
<span class="line" id="L302">}</span>
<span class="line" id="L303"></span>
<span class="line" id="L304"><span class="tok-comment">// Generates a HuffmanCode corresponding to the fixed literal table</span>
</span>
<span class="line" id="L305"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">generateFixedLiteralEncoding</span>(allocator: Allocator) !HuffmanEncoder {</span>
<span class="line" id="L306">    <span class="tok-kw">var</span> h = <span class="tok-kw">try</span> newHuffmanEncoder(allocator, deflate_const.max_num_frequencies);</span>
<span class="line" id="L307">    <span class="tok-kw">var</span> codes = h.codes;</span>
<span class="line" id="L308">    <span class="tok-kw">var</span> ch: <span class="tok-type">u16</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L309"></span>
<span class="line" id="L310">    <span class="tok-kw">while</span> (ch &lt; deflate_const.max_num_frequencies) : (ch += <span class="tok-number">1</span>) {</span>
<span class="line" id="L311">        <span class="tok-kw">var</span> bits: <span class="tok-type">u16</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L312">        <span class="tok-kw">var</span> size: <span class="tok-type">u16</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L313">        <span class="tok-kw">switch</span> (ch) {</span>
<span class="line" id="L314">            <span class="tok-number">0</span>...<span class="tok-number">143</span> =&gt; {</span>
<span class="line" id="L315">                <span class="tok-comment">// size 8, 000110000  .. 10111111</span>
</span>
<span class="line" id="L316">                bits = ch + <span class="tok-number">48</span>;</span>
<span class="line" id="L317">                size = <span class="tok-number">8</span>;</span>
<span class="line" id="L318">            },</span>
<span class="line" id="L319">            <span class="tok-number">144</span>...<span class="tok-number">255</span> =&gt; {</span>
<span class="line" id="L320">                <span class="tok-comment">// size 9, 110010000 .. 111111111</span>
</span>
<span class="line" id="L321">                bits = ch + <span class="tok-number">400</span> - <span class="tok-number">144</span>;</span>
<span class="line" id="L322">                size = <span class="tok-number">9</span>;</span>
<span class="line" id="L323">            },</span>
<span class="line" id="L324">            <span class="tok-number">256</span>...<span class="tok-number">279</span> =&gt; {</span>
<span class="line" id="L325">                <span class="tok-comment">// size 7, 0000000 .. 0010111</span>
</span>
<span class="line" id="L326">                bits = ch - <span class="tok-number">256</span>;</span>
<span class="line" id="L327">                size = <span class="tok-number">7</span>;</span>
<span class="line" id="L328">            },</span>
<span class="line" id="L329">            <span class="tok-kw">else</span> =&gt; {</span>
<span class="line" id="L330">                <span class="tok-comment">// size 8, 11000000 .. 11000111</span>
</span>
<span class="line" id="L331">                bits = ch + <span class="tok-number">192</span> - <span class="tok-number">280</span>;</span>
<span class="line" id="L332">                size = <span class="tok-number">8</span>;</span>
<span class="line" id="L333">            },</span>
<span class="line" id="L334">        }</span>
<span class="line" id="L335">        codes[ch] = HuffCode{ .code = bu.bitReverse(<span class="tok-type">u16</span>, bits, <span class="tok-builtin">@intCast</span>(<span class="tok-type">u5</span>, size)), .len = size };</span>
<span class="line" id="L336">    }</span>
<span class="line" id="L337">    <span class="tok-kw">return</span> h;</span>
<span class="line" id="L338">}</span>
<span class="line" id="L339"></span>
<span class="line" id="L340"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">generateFixedOffsetEncoding</span>(allocator: Allocator) !HuffmanEncoder {</span>
<span class="line" id="L341">    <span class="tok-kw">var</span> h = <span class="tok-kw">try</span> newHuffmanEncoder(allocator, <span class="tok-number">30</span>);</span>
<span class="line" id="L342">    <span class="tok-kw">var</span> codes = h.codes;</span>
<span class="line" id="L343">    <span class="tok-kw">for</span> (codes) |_, ch| {</span>
<span class="line" id="L344">        codes[ch] = HuffCode{ .code = bu.bitReverse(<span class="tok-type">u16</span>, <span class="tok-builtin">@intCast</span>(<span class="tok-type">u16</span>, ch), <span class="tok-number">5</span>), .len = <span class="tok-number">5</span> };</span>
<span class="line" id="L345">    }</span>
<span class="line" id="L346">    <span class="tok-kw">return</span> h;</span>
<span class="line" id="L347">}</span>
<span class="line" id="L348"></span>
<span class="line" id="L349"><span class="tok-kw">fn</span> <span class="tok-fn">byLiteral</span>(context: <span class="tok-type">void</span>, a: LiteralNode, b: LiteralNode) <span class="tok-type">bool</span> {</span>
<span class="line" id="L350">    _ = context;</span>
<span class="line" id="L351">    <span class="tok-kw">return</span> a.literal &lt; b.literal;</span>
<span class="line" id="L352">}</span>
<span class="line" id="L353"></span>
<span class="line" id="L354"><span class="tok-kw">fn</span> <span class="tok-fn">byFreq</span>(context: <span class="tok-type">void</span>, a: LiteralNode, b: LiteralNode) <span class="tok-type">bool</span> {</span>
<span class="line" id="L355">    _ = context;</span>
<span class="line" id="L356">    <span class="tok-kw">if</span> (a.freq == b.freq) {</span>
<span class="line" id="L357">        <span class="tok-kw">return</span> a.literal &lt; b.literal;</span>
<span class="line" id="L358">    }</span>
<span class="line" id="L359">    <span class="tok-kw">return</span> a.freq &lt; b.freq;</span>
<span class="line" id="L360">}</span>
<span class="line" id="L361"></span>
<span class="line" id="L362"><span class="tok-kw">test</span> <span class="tok-str">&quot;generate a Huffman code from an array of frequencies&quot;</span> {</span>
<span class="line" id="L363">    <span class="tok-kw">var</span> freqs: [<span class="tok-number">19</span>]<span class="tok-type">u16</span> = [_]<span class="tok-type">u16</span>{</span>
<span class="line" id="L364">        <span class="tok-number">8</span>, <span class="tok-comment">// 0</span>
</span>
<span class="line" id="L365">        <span class="tok-number">1</span>, <span class="tok-comment">// 1</span>
</span>
<span class="line" id="L366">        <span class="tok-number">1</span>, <span class="tok-comment">// 2</span>
</span>
<span class="line" id="L367">        <span class="tok-number">2</span>, <span class="tok-comment">// 3</span>
</span>
<span class="line" id="L368">        <span class="tok-number">5</span>, <span class="tok-comment">// 4</span>
</span>
<span class="line" id="L369">        <span class="tok-number">10</span>, <span class="tok-comment">// 5</span>
</span>
<span class="line" id="L370">        <span class="tok-number">9</span>, <span class="tok-comment">// 6</span>
</span>
<span class="line" id="L371">        <span class="tok-number">1</span>, <span class="tok-comment">// 7</span>
</span>
<span class="line" id="L372">        <span class="tok-number">0</span>, <span class="tok-comment">// 8</span>
</span>
<span class="line" id="L373">        <span class="tok-number">0</span>, <span class="tok-comment">// 9</span>
</span>
<span class="line" id="L374">        <span class="tok-number">0</span>, <span class="tok-comment">// 10</span>
</span>
<span class="line" id="L375">        <span class="tok-number">0</span>, <span class="tok-comment">// 11</span>
</span>
<span class="line" id="L376">        <span class="tok-number">0</span>, <span class="tok-comment">// 12</span>
</span>
<span class="line" id="L377">        <span class="tok-number">0</span>, <span class="tok-comment">// 13</span>
</span>
<span class="line" id="L378">        <span class="tok-number">0</span>, <span class="tok-comment">// 14</span>
</span>
<span class="line" id="L379">        <span class="tok-number">0</span>, <span class="tok-comment">// 15</span>
</span>
<span class="line" id="L380">        <span class="tok-number">1</span>, <span class="tok-comment">// 16</span>
</span>
<span class="line" id="L381">        <span class="tok-number">3</span>, <span class="tok-comment">// 17</span>
</span>
<span class="line" id="L382">        <span class="tok-number">5</span>, <span class="tok-comment">// 18</span>
</span>
<span class="line" id="L383">    };</span>
<span class="line" id="L384"></span>
<span class="line" id="L385">    <span class="tok-kw">var</span> enc = <span class="tok-kw">try</span> newHuffmanEncoder(testing.allocator, freqs.len);</span>
<span class="line" id="L386">    <span class="tok-kw">defer</span> enc.deinit();</span>
<span class="line" id="L387">    enc.generate(freqs[<span class="tok-number">0</span>..], <span class="tok-number">7</span>);</span>
<span class="line" id="L388"></span>
<span class="line" id="L389">    <span class="tok-kw">try</span> testing.expect(enc.bitLength(freqs[<span class="tok-number">0</span>..]) == <span class="tok-number">141</span>);</span>
<span class="line" id="L390"></span>
<span class="line" id="L391">    <span class="tok-kw">try</span> testing.expect(enc.codes[<span class="tok-number">0</span>].len == <span class="tok-number">3</span>);</span>
<span class="line" id="L392">    <span class="tok-kw">try</span> testing.expect(enc.codes[<span class="tok-number">1</span>].len == <span class="tok-number">6</span>);</span>
<span class="line" id="L393">    <span class="tok-kw">try</span> testing.expect(enc.codes[<span class="tok-number">2</span>].len == <span class="tok-number">6</span>);</span>
<span class="line" id="L394">    <span class="tok-kw">try</span> testing.expect(enc.codes[<span class="tok-number">3</span>].len == <span class="tok-number">5</span>);</span>
<span class="line" id="L395">    <span class="tok-kw">try</span> testing.expect(enc.codes[<span class="tok-number">4</span>].len == <span class="tok-number">3</span>);</span>
<span class="line" id="L396">    <span class="tok-kw">try</span> testing.expect(enc.codes[<span class="tok-number">5</span>].len == <span class="tok-number">2</span>);</span>
<span class="line" id="L397">    <span class="tok-kw">try</span> testing.expect(enc.codes[<span class="tok-number">6</span>].len == <span class="tok-number">2</span>);</span>
<span class="line" id="L398">    <span class="tok-kw">try</span> testing.expect(enc.codes[<span class="tok-number">7</span>].len == <span class="tok-number">6</span>);</span>
<span class="line" id="L399">    <span class="tok-kw">try</span> testing.expect(enc.codes[<span class="tok-number">8</span>].len == <span class="tok-number">0</span>);</span>
<span class="line" id="L400">    <span class="tok-kw">try</span> testing.expect(enc.codes[<span class="tok-number">9</span>].len == <span class="tok-number">0</span>);</span>
<span class="line" id="L401">    <span class="tok-kw">try</span> testing.expect(enc.codes[<span class="tok-number">10</span>].len == <span class="tok-number">0</span>);</span>
<span class="line" id="L402">    <span class="tok-kw">try</span> testing.expect(enc.codes[<span class="tok-number">11</span>].len == <span class="tok-number">0</span>);</span>
<span class="line" id="L403">    <span class="tok-kw">try</span> testing.expect(enc.codes[<span class="tok-number">12</span>].len == <span class="tok-number">0</span>);</span>
<span class="line" id="L404">    <span class="tok-kw">try</span> testing.expect(enc.codes[<span class="tok-number">13</span>].len == <span class="tok-number">0</span>);</span>
<span class="line" id="L405">    <span class="tok-kw">try</span> testing.expect(enc.codes[<span class="tok-number">14</span>].len == <span class="tok-number">0</span>);</span>
<span class="line" id="L406">    <span class="tok-kw">try</span> testing.expect(enc.codes[<span class="tok-number">15</span>].len == <span class="tok-number">0</span>);</span>
<span class="line" id="L407">    <span class="tok-kw">try</span> testing.expect(enc.codes[<span class="tok-number">16</span>].len == <span class="tok-number">6</span>);</span>
<span class="line" id="L408">    <span class="tok-kw">try</span> testing.expect(enc.codes[<span class="tok-number">17</span>].len == <span class="tok-number">5</span>);</span>
<span class="line" id="L409">    <span class="tok-kw">try</span> testing.expect(enc.codes[<span class="tok-number">18</span>].len == <span class="tok-number">3</span>);</span>
<span class="line" id="L410"></span>
<span class="line" id="L411">    <span class="tok-kw">try</span> testing.expect(enc.codes[<span class="tok-number">5</span>].code == <span class="tok-number">0x0</span>);</span>
<span class="line" id="L412">    <span class="tok-kw">try</span> testing.expect(enc.codes[<span class="tok-number">6</span>].code == <span class="tok-number">0x2</span>);</span>
<span class="line" id="L413">    <span class="tok-kw">try</span> testing.expect(enc.codes[<span class="tok-number">0</span>].code == <span class="tok-number">0x1</span>);</span>
<span class="line" id="L414">    <span class="tok-kw">try</span> testing.expect(enc.codes[<span class="tok-number">4</span>].code == <span class="tok-number">0x5</span>);</span>
<span class="line" id="L415">    <span class="tok-kw">try</span> testing.expect(enc.codes[<span class="tok-number">18</span>].code == <span class="tok-number">0x3</span>);</span>
<span class="line" id="L416">    <span class="tok-kw">try</span> testing.expect(enc.codes[<span class="tok-number">3</span>].code == <span class="tok-number">0x7</span>);</span>
<span class="line" id="L417">    <span class="tok-kw">try</span> testing.expect(enc.codes[<span class="tok-number">17</span>].code == <span class="tok-number">0x17</span>);</span>
<span class="line" id="L418">    <span class="tok-kw">try</span> testing.expect(enc.codes[<span class="tok-number">1</span>].code == <span class="tok-number">0x0f</span>);</span>
<span class="line" id="L419">    <span class="tok-kw">try</span> testing.expect(enc.codes[<span class="tok-number">2</span>].code == <span class="tok-number">0x2f</span>);</span>
<span class="line" id="L420">    <span class="tok-kw">try</span> testing.expect(enc.codes[<span class="tok-number">7</span>].code == <span class="tok-number">0x1f</span>);</span>
<span class="line" id="L421">    <span class="tok-kw">try</span> testing.expect(enc.codes[<span class="tok-number">16</span>].code == <span class="tok-number">0x3f</span>);</span>
<span class="line" id="L422">}</span>
<span class="line" id="L423"></span>
<span class="line" id="L424"><span class="tok-kw">test</span> <span class="tok-str">&quot;generate a Huffman code for the fixed litteral table specific to Deflate&quot;</span> {</span>
<span class="line" id="L425">    <span class="tok-kw">var</span> enc = <span class="tok-kw">try</span> generateFixedLiteralEncoding(testing.allocator);</span>
<span class="line" id="L426">    <span class="tok-kw">defer</span> enc.deinit();</span>
<span class="line" id="L427">}</span>
<span class="line" id="L428"></span>
<span class="line" id="L429"><span class="tok-kw">test</span> <span class="tok-str">&quot;generate a Huffman code for the 30 possible relative offsets (LZ77 distances) of Deflate&quot;</span> {</span>
<span class="line" id="L430">    <span class="tok-kw">var</span> enc = <span class="tok-kw">try</span> generateFixedOffsetEncoding(testing.allocator);</span>
<span class="line" id="L431">    <span class="tok-kw">defer</span> enc.deinit();</span>
<span class="line" id="L432">}</span>
<span class="line" id="L433"></span>
</code></pre></body>
</html>