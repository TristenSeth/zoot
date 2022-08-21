<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">    <title>compress/deflate/decompressor.zig - source view</title>
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
<span class="line" id="L5"></span>
<span class="line" id="L6"><span class="tok-kw">const</span> Allocator = std.mem.Allocator;</span>
<span class="line" id="L7"><span class="tok-kw">const</span> ArrayList = std.ArrayList;</span>
<span class="line" id="L8"></span>
<span class="line" id="L9"><span class="tok-kw">const</span> bu = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;bits_utils.zig&quot;</span>);</span>
<span class="line" id="L10"><span class="tok-kw">const</span> ddec = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;dict_decoder.zig&quot;</span>);</span>
<span class="line" id="L11"><span class="tok-kw">const</span> deflate_const = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;deflate_const.zig&quot;</span>);</span>
<span class="line" id="L12"><span class="tok-kw">const</span> mu = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;mem_utils.zig&quot;</span>);</span>
<span class="line" id="L13"></span>
<span class="line" id="L14"><span class="tok-kw">const</span> max_match_offset = deflate_const.max_match_offset;</span>
<span class="line" id="L15"><span class="tok-kw">const</span> end_block_marker = deflate_const.end_block_marker;</span>
<span class="line" id="L16"></span>
<span class="line" id="L17"><span class="tok-kw">const</span> max_code_len = <span class="tok-number">16</span>; <span class="tok-comment">// max length of Huffman code</span>
</span>
<span class="line" id="L18"><span class="tok-comment">// The next three numbers come from the RFC section 3.2.7, with the</span>
</span>
<span class="line" id="L19"><span class="tok-comment">// additional proviso in section 3.2.5 which implies that distance codes</span>
</span>
<span class="line" id="L20"><span class="tok-comment">// 30 and 31 should never occur in compressed data.</span>
</span>
<span class="line" id="L21"><span class="tok-kw">const</span> max_num_lit = <span class="tok-number">286</span>;</span>
<span class="line" id="L22"><span class="tok-kw">const</span> max_num_dist = <span class="tok-number">30</span>;</span>
<span class="line" id="L23"><span class="tok-kw">const</span> num_codes = <span class="tok-number">19</span>; <span class="tok-comment">// number of codes in Huffman meta-code</span>
</span>
<span class="line" id="L24"></span>
<span class="line" id="L25"><span class="tok-kw">var</span> corrupt_input_error_offset: <span class="tok-type">u64</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L26"></span>
<span class="line" id="L27"><span class="tok-kw">const</span> InflateError = <span class="tok-kw">error</span>{</span>
<span class="line" id="L28">    CorruptInput, <span class="tok-comment">// A CorruptInput error reports the presence of corrupt input at a given offset.</span>
</span>
<span class="line" id="L29">    BadInternalState, <span class="tok-comment">// An BadInternalState reports an error in the flate code itself.</span>
</span>
<span class="line" id="L30">    BadReaderState, <span class="tok-comment">// An error was encountered while accessing the inner reader</span>
</span>
<span class="line" id="L31">    UnexpectedEndOfStream,</span>
<span class="line" id="L32">    EndOfStreamWithNoError,</span>
<span class="line" id="L33">};</span>
<span class="line" id="L34"></span>
<span class="line" id="L35"><span class="tok-comment">// The data structure for decoding Huffman tables is based on that of</span>
</span>
<span class="line" id="L36"><span class="tok-comment">// zlib. There is a lookup table of a fixed bit width (huffman_chunk_bits),</span>
</span>
<span class="line" id="L37"><span class="tok-comment">// For codes smaller than the table width, there are multiple entries</span>
</span>
<span class="line" id="L38"><span class="tok-comment">// (each combination of trailing bits has the same value). For codes</span>
</span>
<span class="line" id="L39"><span class="tok-comment">// larger than the table width, the table contains a link to an overflow</span>
</span>
<span class="line" id="L40"><span class="tok-comment">// table. The width of each entry in the link table is the maximum code</span>
</span>
<span class="line" id="L41"><span class="tok-comment">// size minus the chunk width.</span>
</span>
<span class="line" id="L42"><span class="tok-comment">//</span>
</span>
<span class="line" id="L43"><span class="tok-comment">// Note that you can do a lookup in the table even without all bits</span>
</span>
<span class="line" id="L44"><span class="tok-comment">// filled. Since the extra bits are zero, and the DEFLATE Huffman codes</span>
</span>
<span class="line" id="L45"><span class="tok-comment">// have the property that shorter codes come before longer ones, the</span>
</span>
<span class="line" id="L46"><span class="tok-comment">// bit length estimate in the result is a lower bound on the actual</span>
</span>
<span class="line" id="L47"><span class="tok-comment">// number of bits.</span>
</span>
<span class="line" id="L48"><span class="tok-comment">//</span>
</span>
<span class="line" id="L49"><span class="tok-comment">// See the following:</span>
</span>
<span class="line" id="L50"><span class="tok-comment">//	https://github.com/madler/zlib/raw/master/doc/algorithm.txt</span>
</span>
<span class="line" id="L51"></span>
<span class="line" id="L52"><span class="tok-comment">// chunk &amp; 15 is number of bits</span>
</span>
<span class="line" id="L53"><span class="tok-comment">// chunk &gt;&gt; 4 is value, including table link</span>
</span>
<span class="line" id="L54"></span>
<span class="line" id="L55"><span class="tok-kw">const</span> huffman_chunk_bits = <span class="tok-number">9</span>;</span>
<span class="line" id="L56"><span class="tok-kw">const</span> huffman_num_chunks = <span class="tok-number">1</span> &lt;&lt; huffman_chunk_bits; <span class="tok-comment">// 512</span>
</span>
<span class="line" id="L57"><span class="tok-kw">const</span> huffman_count_mask = <span class="tok-number">15</span>; <span class="tok-comment">// 0b1111</span>
</span>
<span class="line" id="L58"><span class="tok-kw">const</span> huffman_value_shift = <span class="tok-number">4</span>;</span>
<span class="line" id="L59"></span>
<span class="line" id="L60"><span class="tok-kw">const</span> HuffmanDecoder = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L61">    <span class="tok-kw">const</span> Self = <span class="tok-builtin">@This</span>();</span>
<span class="line" id="L62"></span>
<span class="line" id="L63">    allocator: Allocator = <span class="tok-null">undefined</span>,</span>
<span class="line" id="L64"></span>
<span class="line" id="L65">    min: <span class="tok-type">u32</span> = <span class="tok-number">0</span>, <span class="tok-comment">// the minimum code length</span>
</span>
<span class="line" id="L66">    chunks: [huffman_num_chunks]<span class="tok-type">u16</span> = [<span class="tok-number">1</span>]<span class="tok-type">u16</span>{<span class="tok-number">0</span>} ** huffman_num_chunks, <span class="tok-comment">// chunks as described above</span>
</span>
<span class="line" id="L67">    links: [][]<span class="tok-type">u16</span> = <span class="tok-null">undefined</span>, <span class="tok-comment">// overflow links</span>
</span>
<span class="line" id="L68">    link_mask: <span class="tok-type">u32</span> = <span class="tok-number">0</span>, <span class="tok-comment">// mask the width of the link table</span>
</span>
<span class="line" id="L69">    initialized: <span class="tok-type">bool</span> = <span class="tok-null">false</span>,</span>
<span class="line" id="L70">    sub_chunks: ArrayList(<span class="tok-type">u32</span>) = <span class="tok-null">undefined</span>,</span>
<span class="line" id="L71"></span>
<span class="line" id="L72">    <span class="tok-comment">// Initialize Huffman decoding tables from array of code lengths.</span>
</span>
<span class="line" id="L73">    <span class="tok-comment">// Following this function, self is guaranteed to be initialized into a complete</span>
</span>
<span class="line" id="L74">    <span class="tok-comment">// tree (i.e., neither over-subscribed nor under-subscribed). The exception is a</span>
</span>
<span class="line" id="L75">    <span class="tok-comment">// degenerate case where the tree has only a single symbol with length 1. Empty</span>
</span>
<span class="line" id="L76">    <span class="tok-comment">// trees are permitted.</span>
</span>
<span class="line" id="L77">    <span class="tok-kw">fn</span> <span class="tok-fn">init</span>(self: *Self, allocator: Allocator, lengths: []<span class="tok-type">u32</span>) !<span class="tok-type">bool</span> {</span>
<span class="line" id="L78"></span>
<span class="line" id="L79">        <span class="tok-comment">// Sanity enables additional runtime tests during Huffman</span>
</span>
<span class="line" id="L80">        <span class="tok-comment">// table construction. It's intended to be used during</span>
</span>
<span class="line" id="L81">        <span class="tok-comment">// development and debugging</span>
</span>
<span class="line" id="L82">        <span class="tok-kw">const</span> sanity = <span class="tok-null">false</span>;</span>
<span class="line" id="L83"></span>
<span class="line" id="L84">        <span class="tok-kw">if</span> (self.min != <span class="tok-number">0</span>) {</span>
<span class="line" id="L85">            self.* = HuffmanDecoder{};</span>
<span class="line" id="L86">        }</span>
<span class="line" id="L87"></span>
<span class="line" id="L88">        self.allocator = allocator;</span>
<span class="line" id="L89"></span>
<span class="line" id="L90">        <span class="tok-comment">// Count number of codes of each length,</span>
</span>
<span class="line" id="L91">        <span class="tok-comment">// compute min and max length.</span>
</span>
<span class="line" id="L92">        <span class="tok-kw">var</span> count: [max_code_len]<span class="tok-type">u32</span> = [<span class="tok-number">1</span>]<span class="tok-type">u32</span>{<span class="tok-number">0</span>} ** max_code_len;</span>
<span class="line" id="L93">        <span class="tok-kw">var</span> min: <span class="tok-type">u32</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L94">        <span class="tok-kw">var</span> max: <span class="tok-type">u32</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L95">        <span class="tok-kw">for</span> (lengths) |n| {</span>
<span class="line" id="L96">            <span class="tok-kw">if</span> (n == <span class="tok-number">0</span>) {</span>
<span class="line" id="L97">                <span class="tok-kw">continue</span>;</span>
<span class="line" id="L98">            }</span>
<span class="line" id="L99">            <span class="tok-kw">if</span> (min == <span class="tok-number">0</span>) {</span>
<span class="line" id="L100">                min = n;</span>
<span class="line" id="L101">            }</span>
<span class="line" id="L102">            min = <span class="tok-builtin">@minimum</span>(n, min);</span>
<span class="line" id="L103">            max = <span class="tok-builtin">@maximum</span>(n, max);</span>
<span class="line" id="L104">            count[n] += <span class="tok-number">1</span>;</span>
<span class="line" id="L105">        }</span>
<span class="line" id="L106"></span>
<span class="line" id="L107">        <span class="tok-comment">// Empty tree. The decompressor.huffSym function will fail later if the tree</span>
</span>
<span class="line" id="L108">        <span class="tok-comment">// is used. Technically, an empty tree is only valid for the HDIST tree and</span>
</span>
<span class="line" id="L109">        <span class="tok-comment">// not the HCLEN and HLIT tree. However, a stream with an empty HCLEN tree</span>
</span>
<span class="line" id="L110">        <span class="tok-comment">// is guaranteed to fail since it will attempt to use the tree to decode the</span>
</span>
<span class="line" id="L111">        <span class="tok-comment">// codes for the HLIT and HDIST trees. Similarly, an empty HLIT tree is</span>
</span>
<span class="line" id="L112">        <span class="tok-comment">// guaranteed to fail later since the compressed data section must be</span>
</span>
<span class="line" id="L113">        <span class="tok-comment">// composed of at least one symbol (the end-of-block marker).</span>
</span>
<span class="line" id="L114">        <span class="tok-kw">if</span> (max == <span class="tok-number">0</span>) {</span>
<span class="line" id="L115">            <span class="tok-kw">return</span> <span class="tok-null">true</span>;</span>
<span class="line" id="L116">        }</span>
<span class="line" id="L117"></span>
<span class="line" id="L118">        <span class="tok-kw">var</span> next_code: [max_code_len]<span class="tok-type">u32</span> = [<span class="tok-number">1</span>]<span class="tok-type">u32</span>{<span class="tok-number">0</span>} ** max_code_len;</span>
<span class="line" id="L119">        <span class="tok-kw">var</span> code: <span class="tok-type">u32</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L120">        {</span>
<span class="line" id="L121">            <span class="tok-kw">var</span> i = min;</span>
<span class="line" id="L122">            <span class="tok-kw">while</span> (i &lt;= max) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L123">                code &lt;&lt;= <span class="tok-number">1</span>;</span>
<span class="line" id="L124">                next_code[i] = code;</span>
<span class="line" id="L125">                code += count[i];</span>
<span class="line" id="L126">            }</span>
<span class="line" id="L127">        }</span>
<span class="line" id="L128"></span>
<span class="line" id="L129">        <span class="tok-comment">// Check that the coding is complete (i.e., that we've</span>
</span>
<span class="line" id="L130">        <span class="tok-comment">// assigned all 2-to-the-max possible bit sequences).</span>
</span>
<span class="line" id="L131">        <span class="tok-comment">// Exception: To be compatible with zlib, we also need to</span>
</span>
<span class="line" id="L132">        <span class="tok-comment">// accept degenerate single-code codings. See also</span>
</span>
<span class="line" id="L133">        <span class="tok-comment">// TestDegenerateHuffmanCoding.</span>
</span>
<span class="line" id="L134">        <span class="tok-kw">if</span> (code != <span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">1</span>) &lt;&lt; <span class="tok-builtin">@intCast</span>(<span class="tok-type">u5</span>, max) <span class="tok-kw">and</span> !(code == <span class="tok-number">1</span> <span class="tok-kw">and</span> max == <span class="tok-number">1</span>)) {</span>
<span class="line" id="L135">            <span class="tok-kw">return</span> <span class="tok-null">false</span>;</span>
<span class="line" id="L136">        }</span>
<span class="line" id="L137"></span>
<span class="line" id="L138">        self.min = min;</span>
<span class="line" id="L139">        <span class="tok-kw">if</span> (max &gt; huffman_chunk_bits) {</span>
<span class="line" id="L140">            <span class="tok-kw">var</span> num_links = <span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">1</span>) &lt;&lt; <span class="tok-builtin">@intCast</span>(<span class="tok-type">u5</span>, max - huffman_chunk_bits);</span>
<span class="line" id="L141">            self.link_mask = <span class="tok-builtin">@intCast</span>(<span class="tok-type">u32</span>, num_links - <span class="tok-number">1</span>);</span>
<span class="line" id="L142"></span>
<span class="line" id="L143">            <span class="tok-comment">// create link tables</span>
</span>
<span class="line" id="L144">            <span class="tok-kw">var</span> link = next_code[huffman_chunk_bits + <span class="tok-number">1</span>] &gt;&gt; <span class="tok-number">1</span>;</span>
<span class="line" id="L145">            self.links = <span class="tok-kw">try</span> self.allocator.alloc([]<span class="tok-type">u16</span>, huffman_num_chunks - link);</span>
<span class="line" id="L146">            self.sub_chunks = ArrayList(<span class="tok-type">u32</span>).init(self.allocator);</span>
<span class="line" id="L147">            self.initialized = <span class="tok-null">true</span>;</span>
<span class="line" id="L148">            <span class="tok-kw">var</span> j = <span class="tok-builtin">@intCast</span>(<span class="tok-type">u32</span>, link);</span>
<span class="line" id="L149">            <span class="tok-kw">while</span> (j &lt; huffman_num_chunks) : (j += <span class="tok-number">1</span>) {</span>
<span class="line" id="L150">                <span class="tok-kw">var</span> reverse = <span class="tok-builtin">@intCast</span>(<span class="tok-type">u32</span>, bu.bitReverse(<span class="tok-type">u16</span>, <span class="tok-builtin">@intCast</span>(<span class="tok-type">u16</span>, j), <span class="tok-number">16</span>));</span>
<span class="line" id="L151">                reverse &gt;&gt;= <span class="tok-builtin">@intCast</span>(<span class="tok-type">u32</span>, <span class="tok-number">16</span> - huffman_chunk_bits);</span>
<span class="line" id="L152">                <span class="tok-kw">var</span> off = j - <span class="tok-builtin">@intCast</span>(<span class="tok-type">u32</span>, link);</span>
<span class="line" id="L153">                <span class="tok-kw">if</span> (sanity) {</span>
<span class="line" id="L154">                    <span class="tok-comment">// check we are not overwriting an existing chunk</span>
</span>
<span class="line" id="L155">                    assert(self.chunks[reverse] == <span class="tok-number">0</span>);</span>
<span class="line" id="L156">                }</span>
<span class="line" id="L157">                self.chunks[reverse] = <span class="tok-builtin">@intCast</span>(<span class="tok-type">u16</span>, off &lt;&lt; huffman_value_shift | (huffman_chunk_bits + <span class="tok-number">1</span>));</span>
<span class="line" id="L158">                self.links[off] = <span class="tok-kw">try</span> self.allocator.alloc(<span class="tok-type">u16</span>, num_links);</span>
<span class="line" id="L159">                <span class="tok-kw">if</span> (sanity) {</span>
<span class="line" id="L160">                    <span class="tok-comment">// initialize to a known invalid chunk code (0) to see if we overwrite</span>
</span>
<span class="line" id="L161">                    <span class="tok-comment">// this value later on</span>
</span>
<span class="line" id="L162">                    mem.set(<span class="tok-type">u16</span>, self.links[off], <span class="tok-number">0</span>);</span>
<span class="line" id="L163">                }</span>
<span class="line" id="L164">                <span class="tok-kw">try</span> self.sub_chunks.append(off);</span>
<span class="line" id="L165">            }</span>
<span class="line" id="L166">        }</span>
<span class="line" id="L167"></span>
<span class="line" id="L168">        <span class="tok-kw">for</span> (lengths) |n, li| {</span>
<span class="line" id="L169">            <span class="tok-kw">if</span> (n == <span class="tok-number">0</span>) {</span>
<span class="line" id="L170">                <span class="tok-kw">continue</span>;</span>
<span class="line" id="L171">            }</span>
<span class="line" id="L172">            <span class="tok-kw">var</span> ncode = next_code[n];</span>
<span class="line" id="L173">            next_code[n] += <span class="tok-number">1</span>;</span>
<span class="line" id="L174">            <span class="tok-kw">var</span> chunk = <span class="tok-builtin">@intCast</span>(<span class="tok-type">u16</span>, (li &lt;&lt; huffman_value_shift) | n);</span>
<span class="line" id="L175">            <span class="tok-kw">var</span> reverse = <span class="tok-builtin">@intCast</span>(<span class="tok-type">u16</span>, bu.bitReverse(<span class="tok-type">u16</span>, <span class="tok-builtin">@intCast</span>(<span class="tok-type">u16</span>, ncode), <span class="tok-number">16</span>));</span>
<span class="line" id="L176">            reverse &gt;&gt;= <span class="tok-builtin">@intCast</span>(<span class="tok-type">u4</span>, <span class="tok-number">16</span> - n);</span>
<span class="line" id="L177">            <span class="tok-kw">if</span> (n &lt;= huffman_chunk_bits) {</span>
<span class="line" id="L178">                <span class="tok-kw">var</span> off = reverse;</span>
<span class="line" id="L179">                <span class="tok-kw">while</span> (off &lt; self.chunks.len) : (off += <span class="tok-builtin">@as</span>(<span class="tok-type">u16</span>, <span class="tok-number">1</span>) &lt;&lt; <span class="tok-builtin">@intCast</span>(<span class="tok-type">u4</span>, n)) {</span>
<span class="line" id="L180">                    <span class="tok-comment">// We should never need to overwrite</span>
</span>
<span class="line" id="L181">                    <span class="tok-comment">// an existing chunk. Also, 0 is</span>
</span>
<span class="line" id="L182">                    <span class="tok-comment">// never a valid chunk, because the</span>
</span>
<span class="line" id="L183">                    <span class="tok-comment">// lower 4 &quot;count&quot; bits should be</span>
</span>
<span class="line" id="L184">                    <span class="tok-comment">// between 1 and 15.</span>
</span>
<span class="line" id="L185">                    <span class="tok-kw">if</span> (sanity) {</span>
<span class="line" id="L186">                        assert(self.chunks[off] == <span class="tok-number">0</span>);</span>
<span class="line" id="L187">                    }</span>
<span class="line" id="L188">                    self.chunks[off] = chunk;</span>
<span class="line" id="L189">                }</span>
<span class="line" id="L190">            } <span class="tok-kw">else</span> {</span>
<span class="line" id="L191">                <span class="tok-kw">var</span> j = reverse &amp; (huffman_num_chunks - <span class="tok-number">1</span>);</span>
<span class="line" id="L192">                <span class="tok-kw">if</span> (sanity) {</span>
<span class="line" id="L193">                    <span class="tok-comment">// Expect an indirect chunk</span>
</span>
<span class="line" id="L194">                    assert(self.chunks[j] &amp; huffman_count_mask == huffman_chunk_bits + <span class="tok-number">1</span>);</span>
<span class="line" id="L195">                    <span class="tok-comment">// Longer codes should have been</span>
</span>
<span class="line" id="L196">                    <span class="tok-comment">// associated with a link table above.</span>
</span>
<span class="line" id="L197">                }</span>
<span class="line" id="L198">                <span class="tok-kw">var</span> value = self.chunks[j] &gt;&gt; huffman_value_shift;</span>
<span class="line" id="L199">                <span class="tok-kw">var</span> link_tab = self.links[value];</span>
<span class="line" id="L200">                reverse &gt;&gt;= huffman_chunk_bits;</span>
<span class="line" id="L201">                <span class="tok-kw">var</span> off = reverse;</span>
<span class="line" id="L202">                <span class="tok-kw">while</span> (off &lt; link_tab.len) : (off += <span class="tok-builtin">@as</span>(<span class="tok-type">u16</span>, <span class="tok-number">1</span>) &lt;&lt; <span class="tok-builtin">@intCast</span>(<span class="tok-type">u4</span>, n - huffman_chunk_bits)) {</span>
<span class="line" id="L203">                    <span class="tok-kw">if</span> (sanity) {</span>
<span class="line" id="L204">                        <span class="tok-comment">// check we are not overwriting an existing chunk</span>
</span>
<span class="line" id="L205">                        assert(link_tab[off] == <span class="tok-number">0</span>);</span>
<span class="line" id="L206">                    }</span>
<span class="line" id="L207">                    link_tab[off] = <span class="tok-builtin">@intCast</span>(<span class="tok-type">u16</span>, chunk);</span>
<span class="line" id="L208">                }</span>
<span class="line" id="L209">            }</span>
<span class="line" id="L210">        }</span>
<span class="line" id="L211"></span>
<span class="line" id="L212">        <span class="tok-kw">if</span> (sanity) {</span>
<span class="line" id="L213">            <span class="tok-comment">// Above we've sanity checked that we never overwrote</span>
</span>
<span class="line" id="L214">            <span class="tok-comment">// an existing entry. Here we additionally check that</span>
</span>
<span class="line" id="L215">            <span class="tok-comment">// we filled the tables completely.</span>
</span>
<span class="line" id="L216">            <span class="tok-kw">for</span> (self.chunks) |chunk, i| {</span>
<span class="line" id="L217">                <span class="tok-comment">// As an exception, in the degenerate</span>
</span>
<span class="line" id="L218">                <span class="tok-comment">// single-code case, we allow odd</span>
</span>
<span class="line" id="L219">                <span class="tok-comment">// chunks to be missing.</span>
</span>
<span class="line" id="L220">                <span class="tok-kw">if</span> (code == <span class="tok-number">1</span> <span class="tok-kw">and</span> i % <span class="tok-number">2</span> == <span class="tok-number">1</span>) {</span>
<span class="line" id="L221">                    <span class="tok-kw">continue</span>;</span>
<span class="line" id="L222">                }</span>
<span class="line" id="L223"></span>
<span class="line" id="L224">                <span class="tok-comment">// Assert we are not missing a chunk.</span>
</span>
<span class="line" id="L225">                <span class="tok-comment">// All chunks should have been written once</span>
</span>
<span class="line" id="L226">                <span class="tok-comment">// thus losing their initial value of 0</span>
</span>
<span class="line" id="L227">                assert(chunk != <span class="tok-number">0</span>);</span>
<span class="line" id="L228">            }</span>
<span class="line" id="L229"></span>
<span class="line" id="L230">            <span class="tok-kw">if</span> (self.initialized) {</span>
<span class="line" id="L231">                <span class="tok-kw">for</span> (self.links) |link_tab| {</span>
<span class="line" id="L232">                    <span class="tok-kw">for</span> (link_tab) |chunk| {</span>
<span class="line" id="L233">                        <span class="tok-comment">// Assert we are not missing a chunk.</span>
</span>
<span class="line" id="L234">                        assert(chunk != <span class="tok-number">0</span>);</span>
<span class="line" id="L235">                    }</span>
<span class="line" id="L236">                }</span>
<span class="line" id="L237">            }</span>
<span class="line" id="L238">        }</span>
<span class="line" id="L239"></span>
<span class="line" id="L240">        <span class="tok-kw">return</span> <span class="tok-null">true</span>;</span>
<span class="line" id="L241">    }</span>
<span class="line" id="L242"></span>
<span class="line" id="L243">    <span class="tok-comment">/// Release all allocated memory.</span></span>
<span class="line" id="L244">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">deinit</span>(self: *Self) <span class="tok-type">void</span> {</span>
<span class="line" id="L245">        <span class="tok-kw">if</span> (self.initialized <span class="tok-kw">and</span> self.links.len &gt; <span class="tok-number">0</span>) {</span>
<span class="line" id="L246">            <span class="tok-kw">for</span> (self.sub_chunks.items) |off| {</span>
<span class="line" id="L247">                self.allocator.free(self.links[off]);</span>
<span class="line" id="L248">            }</span>
<span class="line" id="L249">            self.allocator.free(self.links);</span>
<span class="line" id="L250">            self.sub_chunks.deinit();</span>
<span class="line" id="L251">            self.initialized = <span class="tok-null">false</span>;</span>
<span class="line" id="L252">        }</span>
<span class="line" id="L253">    }</span>
<span class="line" id="L254">};</span>
<span class="line" id="L255"></span>
<span class="line" id="L256"><span class="tok-kw">var</span> fixed_huffman_decoder: ?HuffmanDecoder = <span class="tok-null">null</span>;</span>
<span class="line" id="L257"></span>
<span class="line" id="L258"><span class="tok-kw">fn</span> <span class="tok-fn">fixedHuffmanDecoderInit</span>(allocator: Allocator) !HuffmanDecoder {</span>
<span class="line" id="L259">    <span class="tok-kw">if</span> (fixed_huffman_decoder != <span class="tok-null">null</span>) {</span>
<span class="line" id="L260">        <span class="tok-kw">return</span> fixed_huffman_decoder.?;</span>
<span class="line" id="L261">    }</span>
<span class="line" id="L262"></span>
<span class="line" id="L263">    <span class="tok-comment">// These come from the RFC section 3.2.6.</span>
</span>
<span class="line" id="L264">    <span class="tok-kw">var</span> bits: [<span class="tok-number">288</span>]<span class="tok-type">u32</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L265">    <span class="tok-kw">var</span> i: <span class="tok-type">u32</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L266">    <span class="tok-kw">while</span> (i &lt; <span class="tok-number">144</span>) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L267">        bits[i] = <span class="tok-number">8</span>;</span>
<span class="line" id="L268">    }</span>
<span class="line" id="L269">    <span class="tok-kw">while</span> (i &lt; <span class="tok-number">256</span>) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L270">        bits[i] = <span class="tok-number">9</span>;</span>
<span class="line" id="L271">    }</span>
<span class="line" id="L272">    <span class="tok-kw">while</span> (i &lt; <span class="tok-number">280</span>) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L273">        bits[i] = <span class="tok-number">7</span>;</span>
<span class="line" id="L274">    }</span>
<span class="line" id="L275">    <span class="tok-kw">while</span> (i &lt; <span class="tok-number">288</span>) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L276">        bits[i] = <span class="tok-number">8</span>;</span>
<span class="line" id="L277">    }</span>
<span class="line" id="L278"></span>
<span class="line" id="L279">    fixed_huffman_decoder = HuffmanDecoder{};</span>
<span class="line" id="L280">    _ = <span class="tok-kw">try</span> fixed_huffman_decoder.?.init(allocator, &amp;bits);</span>
<span class="line" id="L281">    <span class="tok-kw">return</span> fixed_huffman_decoder.?;</span>
<span class="line" id="L282">}</span>
<span class="line" id="L283"></span>
<span class="line" id="L284"><span class="tok-kw">const</span> DecompressorState = <span class="tok-kw">enum</span> {</span>
<span class="line" id="L285">    init,</span>
<span class="line" id="L286">    dict,</span>
<span class="line" id="L287">};</span>
<span class="line" id="L288"></span>
<span class="line" id="L289"><span class="tok-comment">/// Returns a new Decompressor that can be used to read the uncompressed version of `reader`.</span></span>
<span class="line" id="L290"><span class="tok-comment">/// `dictionary` is optional and initializes the Decompressor with a preset dictionary.</span></span>
<span class="line" id="L291"><span class="tok-comment">/// The returned Decompressor behaves as if the uncompressed data stream started with the given</span></span>
<span class="line" id="L292"><span class="tok-comment">/// dictionary, which has already been read. Use the same `dictionary` as the compressor used to</span></span>
<span class="line" id="L293"><span class="tok-comment">/// compress the data.</span></span>
<span class="line" id="L294"><span class="tok-comment">/// This decompressor may use at most 300 KiB of heap memory from the provided allocator.</span></span>
<span class="line" id="L295"><span class="tok-comment">/// The uncompressed data will be written into the provided buffer, see `reader()` and `read()`.</span></span>
<span class="line" id="L296"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">decompressor</span>(allocator: Allocator, reader: <span class="tok-kw">anytype</span>, dictionary: ?[]<span class="tok-kw">const</span> <span class="tok-type">u8</span>) !Decompressor(<span class="tok-builtin">@TypeOf</span>(reader)) {</span>
<span class="line" id="L297">    <span class="tok-kw">return</span> Decompressor(<span class="tok-builtin">@TypeOf</span>(reader)).init(allocator, reader, dictionary);</span>
<span class="line" id="L298">}</span>
<span class="line" id="L299"></span>
<span class="line" id="L300"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">Decompressor</span>(<span class="tok-kw">comptime</span> ReaderType: <span class="tok-type">type</span>) <span class="tok-type">type</span> {</span>
<span class="line" id="L301">    <span class="tok-kw">return</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L302">        <span class="tok-kw">const</span> Self = <span class="tok-builtin">@This</span>();</span>
<span class="line" id="L303"></span>
<span class="line" id="L304">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> Error =</span>
<span class="line" id="L305">            ReaderType.Error ||</span>
<span class="line" id="L306">            <span class="tok-kw">error</span>{EndOfStream} ||</span>
<span class="line" id="L307">            InflateError ||</span>
<span class="line" id="L308">            Allocator.Error;</span>
<span class="line" id="L309">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> Reader = io.Reader(*Self, Error, read);</span>
<span class="line" id="L310"></span>
<span class="line" id="L311">        allocator: Allocator,</span>
<span class="line" id="L312"></span>
<span class="line" id="L313">        <span class="tok-comment">// Input source.</span>
</span>
<span class="line" id="L314">        inner_reader: ReaderType,</span>
<span class="line" id="L315">        roffset: <span class="tok-type">u64</span>,</span>
<span class="line" id="L316"></span>
<span class="line" id="L317">        <span class="tok-comment">// Input bits, in top of b.</span>
</span>
<span class="line" id="L318">        b: <span class="tok-type">u32</span>,</span>
<span class="line" id="L319">        nb: <span class="tok-type">u32</span>,</span>
<span class="line" id="L320"></span>
<span class="line" id="L321">        <span class="tok-comment">// Huffman decoders for literal/length, distance.</span>
</span>
<span class="line" id="L322">        hd1: HuffmanDecoder,</span>
<span class="line" id="L323">        hd2: HuffmanDecoder,</span>
<span class="line" id="L324"></span>
<span class="line" id="L325">        <span class="tok-comment">// Length arrays used to define Huffman codes.</span>
</span>
<span class="line" id="L326">        bits: *[max_num_lit + max_num_dist]<span class="tok-type">u32</span>,</span>
<span class="line" id="L327">        codebits: *[num_codes]<span class="tok-type">u32</span>,</span>
<span class="line" id="L328"></span>
<span class="line" id="L329">        <span class="tok-comment">// Output history, buffer.</span>
</span>
<span class="line" id="L330">        dict: ddec.DictDecoder,</span>
<span class="line" id="L331"></span>
<span class="line" id="L332">        <span class="tok-comment">// Temporary buffer (avoids repeated allocation).</span>
</span>
<span class="line" id="L333">        buf: [<span class="tok-number">4</span>]<span class="tok-type">u8</span>,</span>
<span class="line" id="L334"></span>
<span class="line" id="L335">        <span class="tok-comment">// Next step in the decompression,</span>
</span>
<span class="line" id="L336">        <span class="tok-comment">// and decompression state.</span>
</span>
<span class="line" id="L337">        step: <span class="tok-kw">if</span> (<span class="tok-builtin">@import</span>(<span class="tok-str">&quot;builtin&quot;</span>).zig_backend == .stage1)</span>
<span class="line" id="L338">            <span class="tok-kw">fn</span> (*Self) Error!<span class="tok-type">void</span></span>
<span class="line" id="L339">        <span class="tok-kw">else</span></span>
<span class="line" id="L340">            *<span class="tok-kw">const</span> <span class="tok-kw">fn</span> (*Self) Error!<span class="tok-type">void</span>,</span>
<span class="line" id="L341">        step_state: DecompressorState,</span>
<span class="line" id="L342">        final: <span class="tok-type">bool</span>,</span>
<span class="line" id="L343">        err: ?Error,</span>
<span class="line" id="L344">        to_read: []<span class="tok-type">u8</span>,</span>
<span class="line" id="L345">        <span class="tok-comment">// Huffman states for the lit/length values</span>
</span>
<span class="line" id="L346">        hl: ?*HuffmanDecoder,</span>
<span class="line" id="L347">        <span class="tok-comment">// Huffman states for the distance values.</span>
</span>
<span class="line" id="L348">        hd: ?*HuffmanDecoder,</span>
<span class="line" id="L349">        copy_len: <span class="tok-type">u32</span>,</span>
<span class="line" id="L350">        copy_dist: <span class="tok-type">u32</span>,</span>
<span class="line" id="L351"></span>
<span class="line" id="L352">        <span class="tok-comment">/// Returns a Reader that reads compressed data from an underlying reader and outputs</span></span>
<span class="line" id="L353">        <span class="tok-comment">/// uncompressed data.</span></span>
<span class="line" id="L354">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">reader</span>(self: *Self) Reader {</span>
<span class="line" id="L355">            <span class="tok-kw">return</span> .{ .context = self };</span>
<span class="line" id="L356">        }</span>
<span class="line" id="L357"></span>
<span class="line" id="L358">        <span class="tok-kw">fn</span> <span class="tok-fn">init</span>(allocator: Allocator, in_reader: ReaderType, dict: ?[]<span class="tok-kw">const</span> <span class="tok-type">u8</span>) !Self {</span>
<span class="line" id="L359">            fixed_huffman_decoder = <span class="tok-kw">try</span> fixedHuffmanDecoderInit(allocator);</span>
<span class="line" id="L360"></span>
<span class="line" id="L361">            <span class="tok-kw">var</span> bits = <span class="tok-kw">try</span> allocator.create([max_num_lit + max_num_dist]<span class="tok-type">u32</span>);</span>
<span class="line" id="L362">            <span class="tok-kw">var</span> codebits = <span class="tok-kw">try</span> allocator.create([num_codes]<span class="tok-type">u32</span>);</span>
<span class="line" id="L363"></span>
<span class="line" id="L364">            <span class="tok-kw">var</span> dd = ddec.DictDecoder{};</span>
<span class="line" id="L365">            <span class="tok-kw">try</span> dd.init(allocator, max_match_offset, dict);</span>
<span class="line" id="L366"></span>
<span class="line" id="L367">            <span class="tok-kw">return</span> Self{</span>
<span class="line" id="L368">                .allocator = allocator,</span>
<span class="line" id="L369"></span>
<span class="line" id="L370">                <span class="tok-comment">// Input source.</span>
</span>
<span class="line" id="L371">                .inner_reader = in_reader,</span>
<span class="line" id="L372">                .roffset = <span class="tok-number">0</span>,</span>
<span class="line" id="L373"></span>
<span class="line" id="L374">                <span class="tok-comment">// Input bits, in top of b.</span>
</span>
<span class="line" id="L375">                .b = <span class="tok-number">0</span>,</span>
<span class="line" id="L376">                .nb = <span class="tok-number">0</span>,</span>
<span class="line" id="L377"></span>
<span class="line" id="L378">                <span class="tok-comment">// Huffman decoders for literal/length, distance.</span>
</span>
<span class="line" id="L379">                .hd1 = HuffmanDecoder{},</span>
<span class="line" id="L380">                .hd2 = HuffmanDecoder{},</span>
<span class="line" id="L381"></span>
<span class="line" id="L382">                <span class="tok-comment">// Length arrays used to define Huffman codes.</span>
</span>
<span class="line" id="L383">                .bits = bits,</span>
<span class="line" id="L384">                .codebits = codebits,</span>
<span class="line" id="L385"></span>
<span class="line" id="L386">                <span class="tok-comment">// Output history, buffer.</span>
</span>
<span class="line" id="L387">                .dict = dd,</span>
<span class="line" id="L388"></span>
<span class="line" id="L389">                <span class="tok-comment">// Temporary buffer (avoids repeated allocation).</span>
</span>
<span class="line" id="L390">                .buf = [_]<span class="tok-type">u8</span>{<span class="tok-number">0</span>} ** <span class="tok-number">4</span>,</span>
<span class="line" id="L391"></span>
<span class="line" id="L392">                <span class="tok-comment">// Next step in the decompression and decompression state.</span>
</span>
<span class="line" id="L393">                .step = nextBlock,</span>
<span class="line" id="L394">                .step_state = .init,</span>
<span class="line" id="L395">                .final = <span class="tok-null">false</span>,</span>
<span class="line" id="L396">                .err = <span class="tok-null">null</span>,</span>
<span class="line" id="L397">                .to_read = &amp;[<span class="tok-number">0</span>]<span class="tok-type">u8</span>{},</span>
<span class="line" id="L398">                .hl = <span class="tok-null">null</span>,</span>
<span class="line" id="L399">                .hd = <span class="tok-null">null</span>,</span>
<span class="line" id="L400">                .copy_len = <span class="tok-number">0</span>,</span>
<span class="line" id="L401">                .copy_dist = <span class="tok-number">0</span>,</span>
<span class="line" id="L402">            };</span>
<span class="line" id="L403">        }</span>
<span class="line" id="L404"></span>
<span class="line" id="L405">        <span class="tok-comment">/// Release all allocated memory.</span></span>
<span class="line" id="L406">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">deinit</span>(self: *Self) <span class="tok-type">void</span> {</span>
<span class="line" id="L407">            self.hd2.deinit();</span>
<span class="line" id="L408">            self.hd1.deinit();</span>
<span class="line" id="L409">            self.dict.deinit();</span>
<span class="line" id="L410">            self.allocator.destroy(self.codebits);</span>
<span class="line" id="L411">            self.allocator.destroy(self.bits);</span>
<span class="line" id="L412">        }</span>
<span class="line" id="L413"></span>
<span class="line" id="L414">        <span class="tok-kw">fn</span> <span class="tok-fn">nextBlock</span>(self: *Self) Error!<span class="tok-type">void</span> {</span>
<span class="line" id="L415">            <span class="tok-kw">while</span> (self.nb &lt; <span class="tok-number">1</span> + <span class="tok-number">2</span>) {</span>
<span class="line" id="L416">                self.moreBits() <span class="tok-kw">catch</span> |e| {</span>
<span class="line" id="L417">                    self.err = e;</span>
<span class="line" id="L418">                    <span class="tok-kw">return</span> e;</span>
<span class="line" id="L419">                };</span>
<span class="line" id="L420">            }</span>
<span class="line" id="L421">            self.final = self.b &amp; <span class="tok-number">1</span> == <span class="tok-number">1</span>;</span>
<span class="line" id="L422">            self.b &gt;&gt;= <span class="tok-number">1</span>;</span>
<span class="line" id="L423">            <span class="tok-kw">var</span> typ = self.b &amp; <span class="tok-number">3</span>;</span>
<span class="line" id="L424">            self.b &gt;&gt;= <span class="tok-number">2</span>;</span>
<span class="line" id="L425">            self.nb -= <span class="tok-number">1</span> + <span class="tok-number">2</span>;</span>
<span class="line" id="L426">            <span class="tok-kw">switch</span> (typ) {</span>
<span class="line" id="L427">                <span class="tok-number">0</span> =&gt; <span class="tok-kw">try</span> self.dataBlock(),</span>
<span class="line" id="L428">                <span class="tok-number">1</span> =&gt; {</span>
<span class="line" id="L429">                    <span class="tok-comment">// compressed, fixed Huffman tables</span>
</span>
<span class="line" id="L430">                    self.hl = &amp;fixed_huffman_decoder.?;</span>
<span class="line" id="L431">                    self.hd = <span class="tok-null">null</span>;</span>
<span class="line" id="L432">                    <span class="tok-kw">try</span> self.huffmanBlock();</span>
<span class="line" id="L433">                },</span>
<span class="line" id="L434">                <span class="tok-number">2</span> =&gt; {</span>
<span class="line" id="L435">                    <span class="tok-comment">// compressed, dynamic Huffman tables</span>
</span>
<span class="line" id="L436">                    self.hd2.deinit();</span>
<span class="line" id="L437">                    self.hd1.deinit();</span>
<span class="line" id="L438">                    <span class="tok-kw">try</span> self.readHuffman();</span>
<span class="line" id="L439">                    self.hl = &amp;self.hd1;</span>
<span class="line" id="L440">                    self.hd = &amp;self.hd2;</span>
<span class="line" id="L441">                    <span class="tok-kw">try</span> self.huffmanBlock();</span>
<span class="line" id="L442">                },</span>
<span class="line" id="L443">                <span class="tok-kw">else</span> =&gt; {</span>
<span class="line" id="L444">                    <span class="tok-comment">// 3 is reserved.</span>
</span>
<span class="line" id="L445">                    corrupt_input_error_offset = self.roffset;</span>
<span class="line" id="L446">                    self.err = InflateError.CorruptInput;</span>
<span class="line" id="L447">                    <span class="tok-kw">return</span> InflateError.CorruptInput;</span>
<span class="line" id="L448">                },</span>
<span class="line" id="L449">            }</span>
<span class="line" id="L450">        }</span>
<span class="line" id="L451"></span>
<span class="line" id="L452">        <span class="tok-comment">/// Reads compressed data from the underlying reader and outputs uncompressed data into</span></span>
<span class="line" id="L453">        <span class="tok-comment">/// `output`.</span></span>
<span class="line" id="L454">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">read</span>(self: *Self, output: []<span class="tok-type">u8</span>) Error!<span class="tok-type">usize</span> {</span>
<span class="line" id="L455">            <span class="tok-kw">while</span> (<span class="tok-null">true</span>) {</span>
<span class="line" id="L456">                <span class="tok-kw">if</span> (self.to_read.len &gt; <span class="tok-number">0</span>) {</span>
<span class="line" id="L457">                    <span class="tok-kw">var</span> n = mu.copy(output, self.to_read);</span>
<span class="line" id="L458">                    self.to_read = self.to_read[n..];</span>
<span class="line" id="L459">                    <span class="tok-kw">if</span> (self.to_read.len == <span class="tok-number">0</span> <span class="tok-kw">and</span></span>
<span class="line" id="L460">                        self.err != <span class="tok-null">null</span>)</span>
<span class="line" id="L461">                    {</span>
<span class="line" id="L462">                        <span class="tok-kw">if</span> (self.err.? == InflateError.EndOfStreamWithNoError) {</span>
<span class="line" id="L463">                            <span class="tok-kw">return</span> n;</span>
<span class="line" id="L464">                        }</span>
<span class="line" id="L465">                        <span class="tok-kw">return</span> self.err.?;</span>
<span class="line" id="L466">                    }</span>
<span class="line" id="L467">                    <span class="tok-kw">return</span> n;</span>
<span class="line" id="L468">                }</span>
<span class="line" id="L469">                <span class="tok-kw">if</span> (self.err != <span class="tok-null">null</span>) {</span>
<span class="line" id="L470">                    <span class="tok-kw">if</span> (self.err.? == InflateError.EndOfStreamWithNoError) {</span>
<span class="line" id="L471">                        <span class="tok-kw">return</span> <span class="tok-number">0</span>;</span>
<span class="line" id="L472">                    }</span>
<span class="line" id="L473">                    <span class="tok-kw">return</span> self.err.?;</span>
<span class="line" id="L474">                }</span>
<span class="line" id="L475">                self.step(self) <span class="tok-kw">catch</span> |e| {</span>
<span class="line" id="L476">                    self.err = e;</span>
<span class="line" id="L477">                    <span class="tok-kw">if</span> (self.to_read.len == <span class="tok-number">0</span>) {</span>
<span class="line" id="L478">                        self.to_read = self.dict.readFlush(); <span class="tok-comment">// Flush what's left in case of error</span>
</span>
<span class="line" id="L479">                    }</span>
<span class="line" id="L480">                };</span>
<span class="line" id="L481">            }</span>
<span class="line" id="L482">        }</span>
<span class="line" id="L483"></span>
<span class="line" id="L484">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">close</span>(self: *Self) ?Error {</span>
<span class="line" id="L485">            <span class="tok-kw">if</span> (<span class="tok-builtin">@import</span>(<span class="tok-str">&quot;builtin&quot;</span>).zig_backend == .stage1) {</span>
<span class="line" id="L486">                <span class="tok-kw">if</span> (self.err == Error.EndOfStreamWithNoError) {</span>
<span class="line" id="L487">                    <span class="tok-kw">return</span> <span class="tok-null">null</span>;</span>
<span class="line" id="L488">                }</span>
<span class="line" id="L489">                <span class="tok-kw">return</span> self.err;</span>
<span class="line" id="L490">            }</span>
<span class="line" id="L491">            <span class="tok-kw">if</span> (self.err == <span class="tok-builtin">@as</span>(?Error, <span class="tok-kw">error</span>.EndOfStreamWithNoError)) {</span>
<span class="line" id="L492">                <span class="tok-kw">return</span> <span class="tok-null">null</span>;</span>
<span class="line" id="L493">            }</span>
<span class="line" id="L494">            <span class="tok-kw">return</span> self.err;</span>
<span class="line" id="L495">        }</span>
<span class="line" id="L496"></span>
<span class="line" id="L497">        <span class="tok-comment">// RFC 1951 section 3.2.7.</span>
</span>
<span class="line" id="L498">        <span class="tok-comment">// Compression with dynamic Huffman codes</span>
</span>
<span class="line" id="L499"></span>
<span class="line" id="L500">        <span class="tok-kw">const</span> code_order = [_]<span class="tok-type">u32</span>{ <span class="tok-number">16</span>, <span class="tok-number">17</span>, <span class="tok-number">18</span>, <span class="tok-number">0</span>, <span class="tok-number">8</span>, <span class="tok-number">7</span>, <span class="tok-number">9</span>, <span class="tok-number">6</span>, <span class="tok-number">10</span>, <span class="tok-number">5</span>, <span class="tok-number">11</span>, <span class="tok-number">4</span>, <span class="tok-number">12</span>, <span class="tok-number">3</span>, <span class="tok-number">13</span>, <span class="tok-number">2</span>, <span class="tok-number">14</span>, <span class="tok-number">1</span>, <span class="tok-number">15</span> };</span>
<span class="line" id="L501"></span>
<span class="line" id="L502">        <span class="tok-kw">fn</span> <span class="tok-fn">readHuffman</span>(self: *Self) Error!<span class="tok-type">void</span> {</span>
<span class="line" id="L503">            <span class="tok-comment">// HLIT[5], HDIST[5], HCLEN[4].</span>
</span>
<span class="line" id="L504">            <span class="tok-kw">while</span> (self.nb &lt; <span class="tok-number">5</span> + <span class="tok-number">5</span> + <span class="tok-number">4</span>) {</span>
<span class="line" id="L505">                <span class="tok-kw">try</span> self.moreBits();</span>
<span class="line" id="L506">            }</span>
<span class="line" id="L507">            <span class="tok-kw">var</span> nlit = <span class="tok-builtin">@intCast</span>(<span class="tok-type">u32</span>, self.b &amp; <span class="tok-number">0x1F</span>) + <span class="tok-number">257</span>;</span>
<span class="line" id="L508">            <span class="tok-kw">if</span> (nlit &gt; max_num_lit) {</span>
<span class="line" id="L509">                corrupt_input_error_offset = self.roffset;</span>
<span class="line" id="L510">                self.err = InflateError.CorruptInput;</span>
<span class="line" id="L511">                <span class="tok-kw">return</span> InflateError.CorruptInput;</span>
<span class="line" id="L512">            }</span>
<span class="line" id="L513">            self.b &gt;&gt;= <span class="tok-number">5</span>;</span>
<span class="line" id="L514">            <span class="tok-kw">var</span> ndist = <span class="tok-builtin">@intCast</span>(<span class="tok-type">u32</span>, self.b &amp; <span class="tok-number">0x1F</span>) + <span class="tok-number">1</span>;</span>
<span class="line" id="L515">            <span class="tok-kw">if</span> (ndist &gt; max_num_dist) {</span>
<span class="line" id="L516">                corrupt_input_error_offset = self.roffset;</span>
<span class="line" id="L517">                self.err = InflateError.CorruptInput;</span>
<span class="line" id="L518">                <span class="tok-kw">return</span> InflateError.CorruptInput;</span>
<span class="line" id="L519">            }</span>
<span class="line" id="L520">            self.b &gt;&gt;= <span class="tok-number">5</span>;</span>
<span class="line" id="L521">            <span class="tok-kw">var</span> nclen = <span class="tok-builtin">@intCast</span>(<span class="tok-type">u32</span>, self.b &amp; <span class="tok-number">0xF</span>) + <span class="tok-number">4</span>;</span>
<span class="line" id="L522">            <span class="tok-comment">// num_codes is 19, so nclen is always valid.</span>
</span>
<span class="line" id="L523">            self.b &gt;&gt;= <span class="tok-number">4</span>;</span>
<span class="line" id="L524">            self.nb -= <span class="tok-number">5</span> + <span class="tok-number">5</span> + <span class="tok-number">4</span>;</span>
<span class="line" id="L525"></span>
<span class="line" id="L526">            <span class="tok-comment">// (HCLEN+4)*3 bits: code lengths in the magic code_order order.</span>
</span>
<span class="line" id="L527">            <span class="tok-kw">var</span> i: <span class="tok-type">u32</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L528">            <span class="tok-kw">while</span> (i &lt; nclen) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L529">                <span class="tok-kw">while</span> (self.nb &lt; <span class="tok-number">3</span>) {</span>
<span class="line" id="L530">                    <span class="tok-kw">try</span> self.moreBits();</span>
<span class="line" id="L531">                }</span>
<span class="line" id="L532">                self.codebits[code_order[i]] = <span class="tok-builtin">@intCast</span>(<span class="tok-type">u32</span>, self.b &amp; <span class="tok-number">0x7</span>);</span>
<span class="line" id="L533">                self.b &gt;&gt;= <span class="tok-number">3</span>;</span>
<span class="line" id="L534">                self.nb -= <span class="tok-number">3</span>;</span>
<span class="line" id="L535">            }</span>
<span class="line" id="L536">            i = nclen;</span>
<span class="line" id="L537">            <span class="tok-kw">while</span> (i &lt; code_order.len) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L538">                self.codebits[code_order[i]] = <span class="tok-number">0</span>;</span>
<span class="line" id="L539">            }</span>
<span class="line" id="L540">            <span class="tok-kw">if</span> (!<span class="tok-kw">try</span> self.hd1.init(self.allocator, self.codebits[<span class="tok-number">0</span>..])) {</span>
<span class="line" id="L541">                corrupt_input_error_offset = self.roffset;</span>
<span class="line" id="L542">                self.err = InflateError.CorruptInput;</span>
<span class="line" id="L543">                <span class="tok-kw">return</span> InflateError.CorruptInput;</span>
<span class="line" id="L544">            }</span>
<span class="line" id="L545"></span>
<span class="line" id="L546">            <span class="tok-comment">// HLIT + 257 code lengths, HDIST + 1 code lengths,</span>
</span>
<span class="line" id="L547">            <span class="tok-comment">// using the code length Huffman code.</span>
</span>
<span class="line" id="L548">            i = <span class="tok-number">0</span>;</span>
<span class="line" id="L549">            <span class="tok-kw">var</span> n = nlit + ndist;</span>
<span class="line" id="L550">            <span class="tok-kw">while</span> (i &lt; n) {</span>
<span class="line" id="L551">                <span class="tok-kw">var</span> x = <span class="tok-kw">try</span> self.huffSym(&amp;self.hd1);</span>
<span class="line" id="L552">                <span class="tok-kw">if</span> (x &lt; <span class="tok-number">16</span>) {</span>
<span class="line" id="L553">                    <span class="tok-comment">// Actual length.</span>
</span>
<span class="line" id="L554">                    self.bits[i] = x;</span>
<span class="line" id="L555">                    i += <span class="tok-number">1</span>;</span>
<span class="line" id="L556">                    <span class="tok-kw">continue</span>;</span>
<span class="line" id="L557">                }</span>
<span class="line" id="L558">                <span class="tok-comment">// Repeat previous length or zero.</span>
</span>
<span class="line" id="L559">                <span class="tok-kw">var</span> rep: <span class="tok-type">u32</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L560">                <span class="tok-kw">var</span> nb: <span class="tok-type">u32</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L561">                <span class="tok-kw">var</span> b: <span class="tok-type">u32</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L562">                <span class="tok-kw">switch</span> (x) {</span>
<span class="line" id="L563">                    <span class="tok-number">16</span> =&gt; {</span>
<span class="line" id="L564">                        rep = <span class="tok-number">3</span>;</span>
<span class="line" id="L565">                        nb = <span class="tok-number">2</span>;</span>
<span class="line" id="L566">                        <span class="tok-kw">if</span> (i == <span class="tok-number">0</span>) {</span>
<span class="line" id="L567">                            corrupt_input_error_offset = self.roffset;</span>
<span class="line" id="L568">                            self.err = InflateError.CorruptInput;</span>
<span class="line" id="L569">                            <span class="tok-kw">return</span> InflateError.CorruptInput;</span>
<span class="line" id="L570">                        }</span>
<span class="line" id="L571">                        b = self.bits[i - <span class="tok-number">1</span>];</span>
<span class="line" id="L572">                    },</span>
<span class="line" id="L573">                    <span class="tok-number">17</span> =&gt; {</span>
<span class="line" id="L574">                        rep = <span class="tok-number">3</span>;</span>
<span class="line" id="L575">                        nb = <span class="tok-number">3</span>;</span>
<span class="line" id="L576">                        b = <span class="tok-number">0</span>;</span>
<span class="line" id="L577">                    },</span>
<span class="line" id="L578">                    <span class="tok-number">18</span> =&gt; {</span>
<span class="line" id="L579">                        rep = <span class="tok-number">11</span>;</span>
<span class="line" id="L580">                        nb = <span class="tok-number">7</span>;</span>
<span class="line" id="L581">                        b = <span class="tok-number">0</span>;</span>
<span class="line" id="L582">                    },</span>
<span class="line" id="L583">                    <span class="tok-kw">else</span> =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.BadInternalState, <span class="tok-comment">// unexpected length code</span>
</span>
<span class="line" id="L584">                }</span>
<span class="line" id="L585">                <span class="tok-kw">while</span> (self.nb &lt; nb) {</span>
<span class="line" id="L586">                    <span class="tok-kw">try</span> self.moreBits();</span>
<span class="line" id="L587">                }</span>
<span class="line" id="L588">                rep += <span class="tok-builtin">@intCast</span>(<span class="tok-type">u32</span>, self.b &amp; (<span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">1</span>) &lt;&lt; <span class="tok-builtin">@intCast</span>(<span class="tok-type">u5</span>, nb)) - <span class="tok-number">1</span>);</span>
<span class="line" id="L589">                self.b &gt;&gt;= <span class="tok-builtin">@intCast</span>(<span class="tok-type">u5</span>, nb);</span>
<span class="line" id="L590">                self.nb -= nb;</span>
<span class="line" id="L591">                <span class="tok-kw">if</span> (i + rep &gt; n) {</span>
<span class="line" id="L592">                    corrupt_input_error_offset = self.roffset;</span>
<span class="line" id="L593">                    self.err = InflateError.CorruptInput;</span>
<span class="line" id="L594">                    <span class="tok-kw">return</span> InflateError.CorruptInput;</span>
<span class="line" id="L595">                }</span>
<span class="line" id="L596">                <span class="tok-kw">var</span> j: <span class="tok-type">u32</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L597">                <span class="tok-kw">while</span> (j &lt; rep) : (j += <span class="tok-number">1</span>) {</span>
<span class="line" id="L598">                    self.bits[i] = b;</span>
<span class="line" id="L599">                    i += <span class="tok-number">1</span>;</span>
<span class="line" id="L600">                }</span>
<span class="line" id="L601">            }</span>
<span class="line" id="L602"></span>
<span class="line" id="L603">            <span class="tok-kw">if</span> (!<span class="tok-kw">try</span> self.hd1.init(self.allocator, self.bits[<span class="tok-number">0</span>..nlit]) <span class="tok-kw">or</span></span>
<span class="line" id="L604">                !<span class="tok-kw">try</span> self.hd2.init(self.allocator, self.bits[nlit .. nlit + ndist]))</span>
<span class="line" id="L605">            {</span>
<span class="line" id="L606">                corrupt_input_error_offset = self.roffset;</span>
<span class="line" id="L607">                self.err = InflateError.CorruptInput;</span>
<span class="line" id="L608">                <span class="tok-kw">return</span> InflateError.CorruptInput;</span>
<span class="line" id="L609">            }</span>
<span class="line" id="L610"></span>
<span class="line" id="L611">            <span class="tok-comment">// As an optimization, we can initialize the min bits to read at a time</span>
</span>
<span class="line" id="L612">            <span class="tok-comment">// for the HLIT tree to the length of the EOB marker since we know that</span>
</span>
<span class="line" id="L613">            <span class="tok-comment">// every block must terminate with one. This preserves the property that</span>
</span>
<span class="line" id="L614">            <span class="tok-comment">// we never read any extra bytes after the end of the DEFLATE stream.</span>
</span>
<span class="line" id="L615">            <span class="tok-kw">if</span> (self.hd1.min &lt; self.bits[end_block_marker]) {</span>
<span class="line" id="L616">                self.hd1.min = self.bits[end_block_marker];</span>
<span class="line" id="L617">            }</span>
<span class="line" id="L618"></span>
<span class="line" id="L619">            <span class="tok-kw">return</span>;</span>
<span class="line" id="L620">        }</span>
<span class="line" id="L621"></span>
<span class="line" id="L622">        <span class="tok-comment">// Decode a single Huffman block.</span>
</span>
<span class="line" id="L623">        <span class="tok-comment">// hl and hd are the Huffman states for the lit/length values</span>
</span>
<span class="line" id="L624">        <span class="tok-comment">// and the distance values, respectively. If hd == null, using the</span>
</span>
<span class="line" id="L625">        <span class="tok-comment">// fixed distance encoding associated with fixed Huffman blocks.</span>
</span>
<span class="line" id="L626">        <span class="tok-kw">fn</span> <span class="tok-fn">huffmanBlock</span>(self: *Self) Error!<span class="tok-type">void</span> {</span>
<span class="line" id="L627">            <span class="tok-kw">while</span> (<span class="tok-null">true</span>) {</span>
<span class="line" id="L628">                <span class="tok-kw">switch</span> (self.step_state) {</span>
<span class="line" id="L629">                    .init =&gt; {</span>
<span class="line" id="L630">                        <span class="tok-comment">// Read literal and/or (length, distance) according to RFC section 3.2.3.</span>
</span>
<span class="line" id="L631">                        <span class="tok-kw">var</span> v = <span class="tok-kw">try</span> self.huffSym(self.hl.?);</span>
<span class="line" id="L632">                        <span class="tok-kw">var</span> n: <span class="tok-type">u32</span> = <span class="tok-number">0</span>; <span class="tok-comment">// number of bits extra</span>
</span>
<span class="line" id="L633">                        <span class="tok-kw">var</span> length: <span class="tok-type">u32</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L634">                        <span class="tok-kw">switch</span> (v) {</span>
<span class="line" id="L635">                            <span class="tok-number">0</span>...<span class="tok-number">255</span> =&gt; {</span>
<span class="line" id="L636">                                self.dict.writeByte(<span class="tok-builtin">@intCast</span>(<span class="tok-type">u8</span>, v));</span>
<span class="line" id="L637">                                <span class="tok-kw">if</span> (self.dict.availWrite() == <span class="tok-number">0</span>) {</span>
<span class="line" id="L638">                                    self.to_read = self.dict.readFlush();</span>
<span class="line" id="L639">                                    self.step = huffmanBlock;</span>
<span class="line" id="L640">                                    self.step_state = .init;</span>
<span class="line" id="L641">                                    <span class="tok-kw">return</span>;</span>
<span class="line" id="L642">                                }</span>
<span class="line" id="L643">                                self.step_state = .init;</span>
<span class="line" id="L644">                                <span class="tok-kw">continue</span>;</span>
<span class="line" id="L645">                            },</span>
<span class="line" id="L646">                            <span class="tok-number">256</span> =&gt; {</span>
<span class="line" id="L647">                                self.finishBlock();</span>
<span class="line" id="L648">                                <span class="tok-kw">return</span>;</span>
<span class="line" id="L649">                            },</span>
<span class="line" id="L650">                            <span class="tok-comment">// otherwise, reference to older data</span>
</span>
<span class="line" id="L651">                            <span class="tok-number">257</span>...<span class="tok-number">264</span> =&gt; {</span>
<span class="line" id="L652">                                length = v - (<span class="tok-number">257</span> - <span class="tok-number">3</span>);</span>
<span class="line" id="L653">                                n = <span class="tok-number">0</span>;</span>
<span class="line" id="L654">                            },</span>
<span class="line" id="L655">                            <span class="tok-number">265</span>...<span class="tok-number">268</span> =&gt; {</span>
<span class="line" id="L656">                                length = v * <span class="tok-number">2</span> - (<span class="tok-number">265</span> * <span class="tok-number">2</span> - <span class="tok-number">11</span>);</span>
<span class="line" id="L657">                                n = <span class="tok-number">1</span>;</span>
<span class="line" id="L658">                            },</span>
<span class="line" id="L659">                            <span class="tok-number">269</span>...<span class="tok-number">272</span> =&gt; {</span>
<span class="line" id="L660">                                length = v * <span class="tok-number">4</span> - (<span class="tok-number">269</span> * <span class="tok-number">4</span> - <span class="tok-number">19</span>);</span>
<span class="line" id="L661">                                n = <span class="tok-number">2</span>;</span>
<span class="line" id="L662">                            },</span>
<span class="line" id="L663">                            <span class="tok-number">273</span>...<span class="tok-number">276</span> =&gt; {</span>
<span class="line" id="L664">                                length = v * <span class="tok-number">8</span> - (<span class="tok-number">273</span> * <span class="tok-number">8</span> - <span class="tok-number">35</span>);</span>
<span class="line" id="L665">                                n = <span class="tok-number">3</span>;</span>
<span class="line" id="L666">                            },</span>
<span class="line" id="L667">                            <span class="tok-number">277</span>...<span class="tok-number">280</span> =&gt; {</span>
<span class="line" id="L668">                                length = v * <span class="tok-number">16</span> - (<span class="tok-number">277</span> * <span class="tok-number">16</span> - <span class="tok-number">67</span>);</span>
<span class="line" id="L669">                                n = <span class="tok-number">4</span>;</span>
<span class="line" id="L670">                            },</span>
<span class="line" id="L671">                            <span class="tok-number">281</span>...<span class="tok-number">284</span> =&gt; {</span>
<span class="line" id="L672">                                length = v * <span class="tok-number">32</span> - (<span class="tok-number">281</span> * <span class="tok-number">32</span> - <span class="tok-number">131</span>);</span>
<span class="line" id="L673">                                n = <span class="tok-number">5</span>;</span>
<span class="line" id="L674">                            },</span>
<span class="line" id="L675">                            max_num_lit - <span class="tok-number">1</span> =&gt; { <span class="tok-comment">// 285</span>
</span>
<span class="line" id="L676">                                length = <span class="tok-number">258</span>;</span>
<span class="line" id="L677">                                n = <span class="tok-number">0</span>;</span>
<span class="line" id="L678">                            },</span>
<span class="line" id="L679">                            <span class="tok-kw">else</span> =&gt; {</span>
<span class="line" id="L680">                                corrupt_input_error_offset = self.roffset;</span>
<span class="line" id="L681">                                self.err = InflateError.CorruptInput;</span>
<span class="line" id="L682">                                <span class="tok-kw">return</span> InflateError.CorruptInput;</span>
<span class="line" id="L683">                            },</span>
<span class="line" id="L684">                        }</span>
<span class="line" id="L685">                        <span class="tok-kw">if</span> (n &gt; <span class="tok-number">0</span>) {</span>
<span class="line" id="L686">                            <span class="tok-kw">while</span> (self.nb &lt; n) {</span>
<span class="line" id="L687">                                <span class="tok-kw">try</span> self.moreBits();</span>
<span class="line" id="L688">                            }</span>
<span class="line" id="L689">                            length += <span class="tok-builtin">@intCast</span>(<span class="tok-type">u32</span>, self.b) &amp; ((<span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">1</span>) &lt;&lt; <span class="tok-builtin">@intCast</span>(<span class="tok-type">u5</span>, n)) - <span class="tok-number">1</span>);</span>
<span class="line" id="L690">                            self.b &gt;&gt;= <span class="tok-builtin">@intCast</span>(<span class="tok-type">u5</span>, n);</span>
<span class="line" id="L691">                            self.nb -= n;</span>
<span class="line" id="L692">                        }</span>
<span class="line" id="L693"></span>
<span class="line" id="L694">                        <span class="tok-kw">var</span> dist: <span class="tok-type">u32</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L695">                        <span class="tok-kw">if</span> (self.hd == <span class="tok-null">null</span>) {</span>
<span class="line" id="L696">                            <span class="tok-kw">while</span> (self.nb &lt; <span class="tok-number">5</span>) {</span>
<span class="line" id="L697">                                <span class="tok-kw">try</span> self.moreBits();</span>
<span class="line" id="L698">                            }</span>
<span class="line" id="L699">                            dist = <span class="tok-builtin">@intCast</span>(</span>
<span class="line" id="L700">                                <span class="tok-type">u32</span>,</span>
<span class="line" id="L701">                                bu.bitReverse(<span class="tok-type">u8</span>, <span class="tok-builtin">@intCast</span>(<span class="tok-type">u8</span>, (self.b &amp; <span class="tok-number">0x1F</span>) &lt;&lt; <span class="tok-number">3</span>), <span class="tok-number">8</span>),</span>
<span class="line" id="L702">                            );</span>
<span class="line" id="L703">                            self.b &gt;&gt;= <span class="tok-number">5</span>;</span>
<span class="line" id="L704">                            self.nb -= <span class="tok-number">5</span>;</span>
<span class="line" id="L705">                        } <span class="tok-kw">else</span> {</span>
<span class="line" id="L706">                            dist = <span class="tok-kw">try</span> self.huffSym(self.hd.?);</span>
<span class="line" id="L707">                        }</span>
<span class="line" id="L708"></span>
<span class="line" id="L709">                        <span class="tok-kw">switch</span> (dist) {</span>
<span class="line" id="L710">                            <span class="tok-number">0</span>...<span class="tok-number">3</span> =&gt; dist += <span class="tok-number">1</span>,</span>
<span class="line" id="L711">                            <span class="tok-number">4</span>...max_num_dist - <span class="tok-number">1</span> =&gt; { <span class="tok-comment">// 4...29</span>
</span>
<span class="line" id="L712">                                <span class="tok-kw">var</span> nb = <span class="tok-builtin">@intCast</span>(<span class="tok-type">u32</span>, dist - <span class="tok-number">2</span>) &gt;&gt; <span class="tok-number">1</span>;</span>
<span class="line" id="L713">                                <span class="tok-comment">// have 1 bit in bottom of dist, need nb more.</span>
</span>
<span class="line" id="L714">                                <span class="tok-kw">var</span> extra = (dist &amp; <span class="tok-number">1</span>) &lt;&lt; <span class="tok-builtin">@intCast</span>(<span class="tok-type">u5</span>, nb);</span>
<span class="line" id="L715">                                <span class="tok-kw">while</span> (self.nb &lt; nb) {</span>
<span class="line" id="L716">                                    <span class="tok-kw">try</span> self.moreBits();</span>
<span class="line" id="L717">                                }</span>
<span class="line" id="L718">                                extra |= <span class="tok-builtin">@intCast</span>(<span class="tok-type">u32</span>, self.b &amp; (<span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">1</span>) &lt;&lt; <span class="tok-builtin">@intCast</span>(<span class="tok-type">u5</span>, nb)) - <span class="tok-number">1</span>);</span>
<span class="line" id="L719">                                self.b &gt;&gt;= <span class="tok-builtin">@intCast</span>(<span class="tok-type">u5</span>, nb);</span>
<span class="line" id="L720">                                self.nb -= nb;</span>
<span class="line" id="L721">                                dist = (<span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">1</span>) &lt;&lt; <span class="tok-builtin">@intCast</span>(<span class="tok-type">u5</span>, nb + <span class="tok-number">1</span>)) + <span class="tok-number">1</span> + extra;</span>
<span class="line" id="L722">                            },</span>
<span class="line" id="L723">                            <span class="tok-kw">else</span> =&gt; {</span>
<span class="line" id="L724">                                corrupt_input_error_offset = self.roffset;</span>
<span class="line" id="L725">                                self.err = InflateError.CorruptInput;</span>
<span class="line" id="L726">                                <span class="tok-kw">return</span> InflateError.CorruptInput;</span>
<span class="line" id="L727">                            },</span>
<span class="line" id="L728">                        }</span>
<span class="line" id="L729"></span>
<span class="line" id="L730">                        <span class="tok-comment">// No check on length; encoding can be prescient.</span>
</span>
<span class="line" id="L731">                        <span class="tok-kw">if</span> (dist &gt; self.dict.histSize()) {</span>
<span class="line" id="L732">                            corrupt_input_error_offset = self.roffset;</span>
<span class="line" id="L733">                            self.err = InflateError.CorruptInput;</span>
<span class="line" id="L734">                            <span class="tok-kw">return</span> InflateError.CorruptInput;</span>
<span class="line" id="L735">                        }</span>
<span class="line" id="L736"></span>
<span class="line" id="L737">                        self.copy_len = length;</span>
<span class="line" id="L738">                        self.copy_dist = dist;</span>
<span class="line" id="L739">                        self.step_state = .dict;</span>
<span class="line" id="L740">                    },</span>
<span class="line" id="L741"></span>
<span class="line" id="L742">                    .dict =&gt; {</span>
<span class="line" id="L743">                        <span class="tok-comment">// Perform a backwards copy according to RFC section 3.2.3.</span>
</span>
<span class="line" id="L744">                        <span class="tok-kw">var</span> cnt = self.dict.tryWriteCopy(self.copy_dist, self.copy_len);</span>
<span class="line" id="L745">                        <span class="tok-kw">if</span> (cnt == <span class="tok-number">0</span>) {</span>
<span class="line" id="L746">                            cnt = self.dict.writeCopy(self.copy_dist, self.copy_len);</span>
<span class="line" id="L747">                        }</span>
<span class="line" id="L748">                        self.copy_len -= cnt;</span>
<span class="line" id="L749"></span>
<span class="line" id="L750">                        <span class="tok-kw">if</span> (self.dict.availWrite() == <span class="tok-number">0</span> <span class="tok-kw">or</span> self.copy_len &gt; <span class="tok-number">0</span>) {</span>
<span class="line" id="L751">                            self.to_read = self.dict.readFlush();</span>
<span class="line" id="L752">                            self.step = huffmanBlock; <span class="tok-comment">// We need to continue this work</span>
</span>
<span class="line" id="L753">                            self.step_state = .dict;</span>
<span class="line" id="L754">                            <span class="tok-kw">return</span>;</span>
<span class="line" id="L755">                        }</span>
<span class="line" id="L756">                        self.step_state = .init;</span>
<span class="line" id="L757">                    },</span>
<span class="line" id="L758">                }</span>
<span class="line" id="L759">            }</span>
<span class="line" id="L760">        }</span>
<span class="line" id="L761"></span>
<span class="line" id="L762">        <span class="tok-comment">// Copy a single uncompressed data block from input to output.</span>
</span>
<span class="line" id="L763">        <span class="tok-kw">fn</span> <span class="tok-fn">dataBlock</span>(self: *Self) Error!<span class="tok-type">void</span> {</span>
<span class="line" id="L764">            <span class="tok-comment">// Uncompressed.</span>
</span>
<span class="line" id="L765">            <span class="tok-comment">// Discard current half-byte.</span>
</span>
<span class="line" id="L766">            self.nb = <span class="tok-number">0</span>;</span>
<span class="line" id="L767">            self.b = <span class="tok-number">0</span>;</span>
<span class="line" id="L768"></span>
<span class="line" id="L769">            <span class="tok-comment">// Length then ones-complement of length.</span>
</span>
<span class="line" id="L770">            <span class="tok-kw">var</span> nr: <span class="tok-type">u32</span> = <span class="tok-number">4</span>;</span>
<span class="line" id="L771">            self.inner_reader.readNoEof(self.buf[<span class="tok-number">0</span>..nr]) <span class="tok-kw">catch</span> {</span>
<span class="line" id="L772">                self.err = InflateError.UnexpectedEndOfStream;</span>
<span class="line" id="L773">                <span class="tok-kw">return</span> InflateError.UnexpectedEndOfStream;</span>
<span class="line" id="L774">            };</span>
<span class="line" id="L775">            self.roffset += <span class="tok-builtin">@intCast</span>(<span class="tok-type">u64</span>, nr);</span>
<span class="line" id="L776">            <span class="tok-kw">var</span> n = <span class="tok-builtin">@intCast</span>(<span class="tok-type">u32</span>, self.buf[<span class="tok-number">0</span>]) | <span class="tok-builtin">@intCast</span>(<span class="tok-type">u32</span>, self.buf[<span class="tok-number">1</span>]) &lt;&lt; <span class="tok-number">8</span>;</span>
<span class="line" id="L777">            <span class="tok-kw">var</span> nn = <span class="tok-builtin">@intCast</span>(<span class="tok-type">u32</span>, self.buf[<span class="tok-number">2</span>]) | <span class="tok-builtin">@intCast</span>(<span class="tok-type">u32</span>, self.buf[<span class="tok-number">3</span>]) &lt;&lt; <span class="tok-number">8</span>;</span>
<span class="line" id="L778">            <span class="tok-kw">if</span> (<span class="tok-builtin">@intCast</span>(<span class="tok-type">u16</span>, nn) != <span class="tok-builtin">@truncate</span>(<span class="tok-type">u16</span>, ~n)) {</span>
<span class="line" id="L779">                corrupt_input_error_offset = self.roffset;</span>
<span class="line" id="L780">                self.err = InflateError.CorruptInput;</span>
<span class="line" id="L781">                <span class="tok-kw">return</span> InflateError.CorruptInput;</span>
<span class="line" id="L782">            }</span>
<span class="line" id="L783"></span>
<span class="line" id="L784">            <span class="tok-kw">if</span> (n == <span class="tok-number">0</span>) {</span>
<span class="line" id="L785">                self.to_read = self.dict.readFlush();</span>
<span class="line" id="L786">                self.finishBlock();</span>
<span class="line" id="L787">                <span class="tok-kw">return</span>;</span>
<span class="line" id="L788">            }</span>
<span class="line" id="L789"></span>
<span class="line" id="L790">            self.copy_len = n;</span>
<span class="line" id="L791">            <span class="tok-kw">try</span> self.copyData();</span>
<span class="line" id="L792">        }</span>
<span class="line" id="L793"></span>
<span class="line" id="L794">        <span class="tok-comment">// copyData copies self.copy_len bytes from the underlying reader into self.hist.</span>
</span>
<span class="line" id="L795">        <span class="tok-comment">// It pauses for reads when self.hist is full.</span>
</span>
<span class="line" id="L796">        <span class="tok-kw">fn</span> <span class="tok-fn">copyData</span>(self: *Self) Error!<span class="tok-type">void</span> {</span>
<span class="line" id="L797">            <span class="tok-kw">var</span> buf = self.dict.writeSlice();</span>
<span class="line" id="L798">            <span class="tok-kw">if</span> (buf.len &gt; self.copy_len) {</span>
<span class="line" id="L799">                buf = buf[<span class="tok-number">0</span>..self.copy_len];</span>
<span class="line" id="L800">            }</span>
<span class="line" id="L801"></span>
<span class="line" id="L802">            <span class="tok-kw">var</span> cnt = <span class="tok-kw">try</span> self.inner_reader.read(buf);</span>
<span class="line" id="L803">            <span class="tok-kw">if</span> (cnt &lt; buf.len) {</span>
<span class="line" id="L804">                self.err = InflateError.UnexpectedEndOfStream;</span>
<span class="line" id="L805">            }</span>
<span class="line" id="L806">            self.roffset += <span class="tok-builtin">@intCast</span>(<span class="tok-type">u64</span>, cnt);</span>
<span class="line" id="L807">            self.copy_len -= <span class="tok-builtin">@intCast</span>(<span class="tok-type">u32</span>, cnt);</span>
<span class="line" id="L808">            self.dict.writeMark(<span class="tok-builtin">@intCast</span>(<span class="tok-type">u32</span>, cnt));</span>
<span class="line" id="L809">            <span class="tok-kw">if</span> (self.err != <span class="tok-null">null</span>) {</span>
<span class="line" id="L810">                <span class="tok-kw">return</span> InflateError.UnexpectedEndOfStream;</span>
<span class="line" id="L811">            }</span>
<span class="line" id="L812"></span>
<span class="line" id="L813">            <span class="tok-kw">if</span> (self.dict.availWrite() == <span class="tok-number">0</span> <span class="tok-kw">or</span> self.copy_len &gt; <span class="tok-number">0</span>) {</span>
<span class="line" id="L814">                self.to_read = self.dict.readFlush();</span>
<span class="line" id="L815">                self.step = copyData;</span>
<span class="line" id="L816">                <span class="tok-kw">return</span>;</span>
<span class="line" id="L817">            }</span>
<span class="line" id="L818">            self.finishBlock();</span>
<span class="line" id="L819">        }</span>
<span class="line" id="L820"></span>
<span class="line" id="L821">        <span class="tok-kw">fn</span> <span class="tok-fn">finishBlock</span>(self: *Self) <span class="tok-type">void</span> {</span>
<span class="line" id="L822">            <span class="tok-kw">if</span> (self.final) {</span>
<span class="line" id="L823">                <span class="tok-kw">if</span> (self.dict.availRead() &gt; <span class="tok-number">0</span>) {</span>
<span class="line" id="L824">                    self.to_read = self.dict.readFlush();</span>
<span class="line" id="L825">                }</span>
<span class="line" id="L826">                self.err = InflateError.EndOfStreamWithNoError;</span>
<span class="line" id="L827">            }</span>
<span class="line" id="L828">            self.step = nextBlock;</span>
<span class="line" id="L829">        }</span>
<span class="line" id="L830"></span>
<span class="line" id="L831">        <span class="tok-kw">fn</span> <span class="tok-fn">moreBits</span>(self: *Self) InflateError!<span class="tok-type">void</span> {</span>
<span class="line" id="L832">            <span class="tok-kw">var</span> c = self.inner_reader.readByte() <span class="tok-kw">catch</span> |e| {</span>
<span class="line" id="L833">                <span class="tok-kw">if</span> (e == <span class="tok-kw">error</span>.EndOfStream) {</span>
<span class="line" id="L834">                    <span class="tok-kw">return</span> InflateError.UnexpectedEndOfStream;</span>
<span class="line" id="L835">                }</span>
<span class="line" id="L836">                <span class="tok-kw">return</span> InflateError.BadReaderState;</span>
<span class="line" id="L837">            };</span>
<span class="line" id="L838">            self.roffset += <span class="tok-number">1</span>;</span>
<span class="line" id="L839">            self.b |= <span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, c) &lt;&lt; <span class="tok-builtin">@intCast</span>(<span class="tok-type">u5</span>, self.nb);</span>
<span class="line" id="L840">            self.nb += <span class="tok-number">8</span>;</span>
<span class="line" id="L841">            <span class="tok-kw">return</span>;</span>
<span class="line" id="L842">        }</span>
<span class="line" id="L843"></span>
<span class="line" id="L844">        <span class="tok-comment">// Read the next Huffman-encoded symbol according to h.</span>
</span>
<span class="line" id="L845">        <span class="tok-kw">fn</span> <span class="tok-fn">huffSym</span>(self: *Self, h: *HuffmanDecoder) InflateError!<span class="tok-type">u32</span> {</span>
<span class="line" id="L846">            <span class="tok-comment">// Since a HuffmanDecoder can be empty or be composed of a degenerate tree</span>
</span>
<span class="line" id="L847">            <span class="tok-comment">// with single element, huffSym must error on these two edge cases. In both</span>
</span>
<span class="line" id="L848">            <span class="tok-comment">// cases, the chunks slice will be 0 for the invalid sequence, leading it</span>
</span>
<span class="line" id="L849">            <span class="tok-comment">// satisfy the n == 0 check below.</span>
</span>
<span class="line" id="L850">            <span class="tok-kw">var</span> n: <span class="tok-type">u32</span> = h.min;</span>
<span class="line" id="L851">            <span class="tok-comment">// Optimization. Go compiler isn't smart enough to keep self.b, self.nb in registers,</span>
</span>
<span class="line" id="L852">            <span class="tok-comment">// but is smart enough to keep local variables in registers, so use nb and b,</span>
</span>
<span class="line" id="L853">            <span class="tok-comment">// inline call to moreBits and reassign b, nb back to self on return.</span>
</span>
<span class="line" id="L854">            <span class="tok-kw">var</span> nb = self.nb;</span>
<span class="line" id="L855">            <span class="tok-kw">var</span> b = self.b;</span>
<span class="line" id="L856">            <span class="tok-kw">while</span> (<span class="tok-null">true</span>) {</span>
<span class="line" id="L857">                <span class="tok-kw">while</span> (nb &lt; n) {</span>
<span class="line" id="L858">                    <span class="tok-kw">var</span> c = self.inner_reader.readByte() <span class="tok-kw">catch</span> |e| {</span>
<span class="line" id="L859">                        self.b = b;</span>
<span class="line" id="L860">                        self.nb = nb;</span>
<span class="line" id="L861">                        <span class="tok-kw">if</span> (e == <span class="tok-kw">error</span>.EndOfStream) {</span>
<span class="line" id="L862">                            <span class="tok-kw">return</span> <span class="tok-kw">error</span>.UnexpectedEndOfStream;</span>
<span class="line" id="L863">                        }</span>
<span class="line" id="L864">                        <span class="tok-kw">return</span> InflateError.BadReaderState;</span>
<span class="line" id="L865">                    };</span>
<span class="line" id="L866">                    self.roffset += <span class="tok-number">1</span>;</span>
<span class="line" id="L867">                    b |= <span class="tok-builtin">@intCast</span>(<span class="tok-type">u32</span>, c) &lt;&lt; <span class="tok-builtin">@intCast</span>(<span class="tok-type">u5</span>, nb &amp; <span class="tok-number">31</span>);</span>
<span class="line" id="L868">                    nb += <span class="tok-number">8</span>;</span>
<span class="line" id="L869">                }</span>
<span class="line" id="L870">                <span class="tok-kw">var</span> chunk = h.chunks[b &amp; (huffman_num_chunks - <span class="tok-number">1</span>)];</span>
<span class="line" id="L871">                n = <span class="tok-builtin">@intCast</span>(<span class="tok-type">u32</span>, chunk &amp; huffman_count_mask);</span>
<span class="line" id="L872">                <span class="tok-kw">if</span> (n &gt; huffman_chunk_bits) {</span>
<span class="line" id="L873">                    chunk = h.links[chunk &gt;&gt; huffman_value_shift][(b &gt;&gt; huffman_chunk_bits) &amp; h.link_mask];</span>
<span class="line" id="L874">                    n = <span class="tok-builtin">@intCast</span>(<span class="tok-type">u32</span>, chunk &amp; huffman_count_mask);</span>
<span class="line" id="L875">                }</span>
<span class="line" id="L876">                <span class="tok-kw">if</span> (n &lt;= nb) {</span>
<span class="line" id="L877">                    <span class="tok-kw">if</span> (n == <span class="tok-number">0</span>) {</span>
<span class="line" id="L878">                        self.b = b;</span>
<span class="line" id="L879">                        self.nb = nb;</span>
<span class="line" id="L880">                        corrupt_input_error_offset = self.roffset;</span>
<span class="line" id="L881">                        self.err = InflateError.CorruptInput;</span>
<span class="line" id="L882">                        <span class="tok-kw">return</span> InflateError.CorruptInput;</span>
<span class="line" id="L883">                    }</span>
<span class="line" id="L884">                    self.b = b &gt;&gt; <span class="tok-builtin">@intCast</span>(<span class="tok-type">u5</span>, n &amp; <span class="tok-number">31</span>);</span>
<span class="line" id="L885">                    self.nb = nb - n;</span>
<span class="line" id="L886">                    <span class="tok-kw">return</span> <span class="tok-builtin">@intCast</span>(<span class="tok-type">u32</span>, chunk &gt;&gt; huffman_value_shift);</span>
<span class="line" id="L887">                }</span>
<span class="line" id="L888">            }</span>
<span class="line" id="L889">        }</span>
<span class="line" id="L890"></span>
<span class="line" id="L891">        <span class="tok-comment">/// Replaces the inner reader and dictionary with new_reader and new_dict.</span></span>
<span class="line" id="L892">        <span class="tok-comment">/// new_reader must be of the same type as the reader being replaced.</span></span>
<span class="line" id="L893">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">reset</span>(s: *Self, new_reader: ReaderType, new_dict: ?[]<span class="tok-kw">const</span> <span class="tok-type">u8</span>) !<span class="tok-type">void</span> {</span>
<span class="line" id="L894">            s.inner_reader = new_reader;</span>
<span class="line" id="L895">            s.step = nextBlock;</span>
<span class="line" id="L896">            s.err = <span class="tok-null">null</span>;</span>
<span class="line" id="L897"></span>
<span class="line" id="L898">            s.dict.deinit();</span>
<span class="line" id="L899">            <span class="tok-kw">try</span> s.dict.init(s.allocator, max_match_offset, new_dict);</span>
<span class="line" id="L900"></span>
<span class="line" id="L901">            <span class="tok-kw">return</span>;</span>
<span class="line" id="L902">        }</span>
<span class="line" id="L903">    };</span>
<span class="line" id="L904">}</span>
<span class="line" id="L905"></span>
<span class="line" id="L906"><span class="tok-comment">// tests</span>
</span>
<span class="line" id="L907"><span class="tok-kw">const</span> expect = std.testing.expect;</span>
<span class="line" id="L908"><span class="tok-kw">const</span> expectError = std.testing.expectError;</span>
<span class="line" id="L909"><span class="tok-kw">const</span> io = std.io;</span>
<span class="line" id="L910"><span class="tok-kw">const</span> testing = std.testing;</span>
<span class="line" id="L911"></span>
<span class="line" id="L912"><span class="tok-kw">test</span> <span class="tok-str">&quot;truncated input&quot;</span> {</span>
<span class="line" id="L913">    <span class="tok-kw">const</span> TruncatedTest = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L914">        input: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L915">        output: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L916">    };</span>
<span class="line" id="L917"></span>
<span class="line" id="L918">    <span class="tok-kw">const</span> tests = [_]TruncatedTest{</span>
<span class="line" id="L919">        .{ .input = <span class="tok-str">&quot;\x00&quot;</span>, .output = <span class="tok-str">&quot;&quot;</span> },</span>
<span class="line" id="L920">        .{ .input = <span class="tok-str">&quot;\x00\x0c&quot;</span>, .output = <span class="tok-str">&quot;&quot;</span> },</span>
<span class="line" id="L921">        .{ .input = <span class="tok-str">&quot;\x00\x0c\x00&quot;</span>, .output = <span class="tok-str">&quot;&quot;</span> },</span>
<span class="line" id="L922">        .{ .input = <span class="tok-str">&quot;\x00\x0c\x00\xf3\xff&quot;</span>, .output = <span class="tok-str">&quot;&quot;</span> },</span>
<span class="line" id="L923">        .{ .input = <span class="tok-str">&quot;\x00\x0c\x00\xf3\xffhello&quot;</span>, .output = <span class="tok-str">&quot;hello&quot;</span> },</span>
<span class="line" id="L924">        .{ .input = <span class="tok-str">&quot;\x00\x0c\x00\xf3\xffhello, world&quot;</span>, .output = <span class="tok-str">&quot;hello, world&quot;</span> },</span>
<span class="line" id="L925">        .{ .input = <span class="tok-str">&quot;\x02&quot;</span>, .output = <span class="tok-str">&quot;&quot;</span> },</span>
<span class="line" id="L926">        .{ .input = <span class="tok-str">&quot;\xf2H\xcd&quot;</span>, .output = <span class="tok-str">&quot;He&quot;</span> },</span>
<span class="line" id="L927">        .{ .input = <span class="tok-str">&quot;\xf2H͙0a\u{0084}\t&quot;</span>, .output = <span class="tok-str">&quot;Hel\x90\x90\x90\x90\x90&quot;</span> },</span>
<span class="line" id="L928">        .{ .input = <span class="tok-str">&quot;\xf2H͙0a\u{0084}\t\x00&quot;</span>, .output = <span class="tok-str">&quot;Hel\x90\x90\x90\x90\x90&quot;</span> },</span>
<span class="line" id="L929">    };</span>
<span class="line" id="L930"></span>
<span class="line" id="L931">    <span class="tok-kw">for</span> (tests) |t| {</span>
<span class="line" id="L932">        <span class="tok-kw">var</span> fib = io.fixedBufferStream(t.input);</span>
<span class="line" id="L933">        <span class="tok-kw">const</span> r = fib.reader();</span>
<span class="line" id="L934">        <span class="tok-kw">var</span> z = <span class="tok-kw">try</span> decompressor(testing.allocator, r, <span class="tok-null">null</span>);</span>
<span class="line" id="L935">        <span class="tok-kw">defer</span> z.deinit();</span>
<span class="line" id="L936">        <span class="tok-kw">var</span> zr = z.reader();</span>
<span class="line" id="L937"></span>
<span class="line" id="L938">        <span class="tok-kw">var</span> output = [<span class="tok-number">1</span>]<span class="tok-type">u8</span>{<span class="tok-number">0</span>} ** <span class="tok-number">12</span>;</span>
<span class="line" id="L939">        <span class="tok-kw">try</span> expectError(<span class="tok-kw">error</span>.UnexpectedEndOfStream, zr.readAll(&amp;output));</span>
<span class="line" id="L940">        <span class="tok-kw">try</span> expect(mem.eql(<span class="tok-type">u8</span>, output[<span class="tok-number">0</span>..t.output.len], t.output));</span>
<span class="line" id="L941">    }</span>
<span class="line" id="L942">}</span>
<span class="line" id="L943"></span>
<span class="line" id="L944"><span class="tok-kw">test</span> <span class="tok-str">&quot;Go non-regression test for 9842&quot;</span> {</span>
<span class="line" id="L945">    <span class="tok-comment">// See https://golang.org/issue/9842</span>
</span>
<span class="line" id="L946"></span>
<span class="line" id="L947">    <span class="tok-kw">const</span> Test = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L948">        err: ?<span class="tok-type">anyerror</span>,</span>
<span class="line" id="L949">        input: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L950">    };</span>
<span class="line" id="L951"></span>
<span class="line" id="L952">    <span class="tok-kw">const</span> tests = [_]Test{</span>
<span class="line" id="L953">        .{ .err = <span class="tok-kw">error</span>.UnexpectedEndOfStream, .input = (<span class="tok-str">&quot;\x95\x90=o\xc20\x10\x86\xf30&quot;</span>) },</span>
<span class="line" id="L954">        .{ .err = <span class="tok-kw">error</span>.CorruptInput, .input = (<span class="tok-str">&quot;\x950\x00\x0000000&quot;</span>) },</span>
<span class="line" id="L955"></span>
<span class="line" id="L956">        <span class="tok-comment">// Huffman.construct errors</span>
</span>
<span class="line" id="L957"></span>
<span class="line" id="L958">        <span class="tok-comment">// lencode</span>
</span>
<span class="line" id="L959">        .{ .err = <span class="tok-kw">error</span>.CorruptInput, .input = (<span class="tok-str">&quot;\x950000&quot;</span>) },</span>
<span class="line" id="L960">        .{ .err = <span class="tok-kw">error</span>.CorruptInput, .input = (<span class="tok-str">&quot;\x05000&quot;</span>) },</span>
<span class="line" id="L961">        <span class="tok-comment">// hlen</span>
</span>
<span class="line" id="L962">        .{ .err = <span class="tok-kw">error</span>.CorruptInput, .input = (<span class="tok-str">&quot;\x05\xea\x01\t\x00\x00\x00\x01\x00\\\xbf.\t\x00&quot;</span>) },</span>
<span class="line" id="L963">        <span class="tok-comment">// hdist</span>
</span>
<span class="line" id="L964">        .{ .err = <span class="tok-kw">error</span>.CorruptInput, .input = (<span class="tok-str">&quot;\x05\xe0\x01A\x00\x00\x00\x00\x10\\\xbf.&quot;</span>) },</span>
<span class="line" id="L965"></span>
<span class="line" id="L966">        <span class="tok-comment">// like the &quot;empty distance alphabet&quot; test but for ndist instead of nlen</span>
</span>
<span class="line" id="L967">        .{ .err = <span class="tok-kw">error</span>.CorruptInput, .input = (<span class="tok-str">&quot;\x05\xe0\x01\t\x00\x00\x00\x00\x10\\\xbf\xce&quot;</span>) },</span>
<span class="line" id="L968">        .{ .err = <span class="tok-null">null</span>, .input = <span class="tok-str">&quot;\x15\xe0\x01\t\x00\x00\x00\x00\x10\\\xbf.0&quot;</span> },</span>
<span class="line" id="L969">    };</span>
<span class="line" id="L970"></span>
<span class="line" id="L971">    <span class="tok-kw">for</span> (tests) |t| {</span>
<span class="line" id="L972">        <span class="tok-kw">var</span> fib = std.io.fixedBufferStream(t.input);</span>
<span class="line" id="L973">        <span class="tok-kw">const</span> reader = fib.reader();</span>
<span class="line" id="L974">        <span class="tok-kw">var</span> decomp = <span class="tok-kw">try</span> decompressor(testing.allocator, reader, <span class="tok-null">null</span>);</span>
<span class="line" id="L975">        <span class="tok-kw">defer</span> decomp.deinit();</span>
<span class="line" id="L976"></span>
<span class="line" id="L977">        <span class="tok-kw">var</span> output: [<span class="tok-number">10</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L978">        <span class="tok-kw">if</span> (t.err != <span class="tok-null">null</span>) {</span>
<span class="line" id="L979">            <span class="tok-kw">try</span> expectError(t.err.?, decomp.reader().read(&amp;output));</span>
<span class="line" id="L980">        } <span class="tok-kw">else</span> {</span>
<span class="line" id="L981">            _ = <span class="tok-kw">try</span> decomp.reader().read(&amp;output);</span>
<span class="line" id="L982">        }</span>
<span class="line" id="L983">    }</span>
<span class="line" id="L984">}</span>
<span class="line" id="L985"></span>
<span class="line" id="L986"><span class="tok-kw">test</span> <span class="tok-str">&quot;inflate A Tale of Two Cities (1859) intro&quot;</span> {</span>
<span class="line" id="L987">    <span class="tok-kw">const</span> compressed = [_]<span class="tok-type">u8</span>{</span>
<span class="line" id="L988">        <span class="tok-number">0x74</span>, <span class="tok-number">0xeb</span>, <span class="tok-number">0xcd</span>, <span class="tok-number">0x0d</span>, <span class="tok-number">0x80</span>, <span class="tok-number">0x20</span>, <span class="tok-number">0x0c</span>, <span class="tok-number">0x47</span>, <span class="tok-number">0x71</span>, <span class="tok-number">0xdc</span>, <span class="tok-number">0x9d</span>, <span class="tok-number">0xa2</span>, <span class="tok-number">0x03</span>, <span class="tok-number">0xb8</span>, <span class="tok-number">0x88</span>,</span>
<span class="line" id="L989">        <span class="tok-number">0x63</span>, <span class="tok-number">0xf0</span>, <span class="tok-number">0xf1</span>, <span class="tok-number">0x47</span>, <span class="tok-number">0x9a</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x35</span>, <span class="tok-number">0xb4</span>, <span class="tok-number">0x86</span>, <span class="tok-number">0xf5</span>, <span class="tok-number">0x0d</span>, <span class="tok-number">0x27</span>, <span class="tok-number">0x63</span>, <span class="tok-number">0x82</span>, <span class="tok-number">0xe7</span>,</span>
<span class="line" id="L990">        <span class="tok-number">0xdf</span>, <span class="tok-number">0x7b</span>, <span class="tok-number">0x87</span>, <span class="tok-number">0xd1</span>, <span class="tok-number">0x70</span>, <span class="tok-number">0x4a</span>, <span class="tok-number">0x96</span>, <span class="tok-number">0x41</span>, <span class="tok-number">0x1e</span>, <span class="tok-number">0x6a</span>, <span class="tok-number">0x24</span>, <span class="tok-number">0x89</span>, <span class="tok-number">0x8c</span>, <span class="tok-number">0x2b</span>, <span class="tok-number">0x74</span>,</span>
<span class="line" id="L991">        <span class="tok-number">0xdf</span>, <span class="tok-number">0xf8</span>, <span class="tok-number">0x95</span>, <span class="tok-number">0x21</span>, <span class="tok-number">0xfd</span>, <span class="tok-number">0x8f</span>, <span class="tok-number">0xdc</span>, <span class="tok-number">0x89</span>, <span class="tok-number">0x09</span>, <span class="tok-number">0x83</span>, <span class="tok-number">0x35</span>, <span class="tok-number">0x4a</span>, <span class="tok-number">0x5d</span>, <span class="tok-number">0x49</span>, <span class="tok-number">0x12</span>,</span>
<span class="line" id="L992">        <span class="tok-number">0x29</span>, <span class="tok-number">0xac</span>, <span class="tok-number">0xb9</span>, <span class="tok-number">0x41</span>, <span class="tok-number">0xbf</span>, <span class="tok-number">0x23</span>, <span class="tok-number">0x2e</span>, <span class="tok-number">0x09</span>, <span class="tok-number">0x79</span>, <span class="tok-number">0x06</span>, <span class="tok-number">0x1e</span>, <span class="tok-number">0x85</span>, <span class="tok-number">0x91</span>, <span class="tok-number">0xd6</span>, <span class="tok-number">0xc6</span>,</span>
<span class="line" id="L993">        <span class="tok-number">0x2d</span>, <span class="tok-number">0x74</span>, <span class="tok-number">0xc4</span>, <span class="tok-number">0xfb</span>, <span class="tok-number">0xa1</span>, <span class="tok-number">0x7b</span>, <span class="tok-number">0x0f</span>, <span class="tok-number">0x52</span>, <span class="tok-number">0x20</span>, <span class="tok-number">0x84</span>, <span class="tok-number">0x61</span>, <span class="tok-number">0x28</span>, <span class="tok-number">0x0c</span>, <span class="tok-number">0x63</span>, <span class="tok-number">0xdf</span>,</span>
<span class="line" id="L994">        <span class="tok-number">0x53</span>, <span class="tok-number">0xf4</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x1e</span>, <span class="tok-number">0xc3</span>, <span class="tok-number">0xa5</span>, <span class="tok-number">0x97</span>, <span class="tok-number">0x88</span>, <span class="tok-number">0xf4</span>, <span class="tok-number">0xd9</span>, <span class="tok-number">0x04</span>, <span class="tok-number">0xa5</span>, <span class="tok-number">0x2d</span>, <span class="tok-number">0x49</span>, <span class="tok-number">0x54</span>,</span>
<span class="line" id="L995">        <span class="tok-number">0xbc</span>, <span class="tok-number">0xfd</span>, <span class="tok-number">0x90</span>, <span class="tok-number">0xa5</span>, <span class="tok-number">0x0c</span>, <span class="tok-number">0xae</span>, <span class="tok-number">0xbf</span>, <span class="tok-number">0x3f</span>, <span class="tok-number">0x84</span>, <span class="tok-number">0x77</span>, <span class="tok-number">0x88</span>, <span class="tok-number">0x3f</span>, <span class="tok-number">0xaf</span>, <span class="tok-number">0xc0</span>, <span class="tok-number">0x40</span>,</span>
<span class="line" id="L996">        <span class="tok-number">0xd6</span>, <span class="tok-number">0x5b</span>, <span class="tok-number">0x14</span>, <span class="tok-number">0x8b</span>, <span class="tok-number">0x54</span>, <span class="tok-number">0xf6</span>, <span class="tok-number">0x0f</span>, <span class="tok-number">0x9b</span>, <span class="tok-number">0x49</span>, <span class="tok-number">0xf7</span>, <span class="tok-number">0xbf</span>, <span class="tok-number">0xbf</span>, <span class="tok-number">0x36</span>, <span class="tok-number">0x54</span>, <span class="tok-number">0x5a</span>,</span>
<span class="line" id="L997">        <span class="tok-number">0x0d</span>, <span class="tok-number">0xe6</span>, <span class="tok-number">0x3e</span>, <span class="tok-number">0xf0</span>, <span class="tok-number">0x9e</span>, <span class="tok-number">0x29</span>, <span class="tok-number">0xcd</span>, <span class="tok-number">0xa1</span>, <span class="tok-number">0x41</span>, <span class="tok-number">0x05</span>, <span class="tok-number">0x36</span>, <span class="tok-number">0x48</span>, <span class="tok-number">0x74</span>, <span class="tok-number">0x4a</span>, <span class="tok-number">0xe9</span>,</span>
<span class="line" id="L998">        <span class="tok-number">0x46</span>, <span class="tok-number">0x66</span>, <span class="tok-number">0x2a</span>, <span class="tok-number">0x19</span>, <span class="tok-number">0x17</span>, <span class="tok-number">0xf4</span>, <span class="tok-number">0x71</span>, <span class="tok-number">0x8e</span>, <span class="tok-number">0xcb</span>, <span class="tok-number">0x15</span>, <span class="tok-number">0x5b</span>, <span class="tok-number">0x57</span>, <span class="tok-number">0xe4</span>, <span class="tok-number">0xf3</span>, <span class="tok-number">0xc7</span>,</span>
<span class="line" id="L999">        <span class="tok-number">0xe7</span>, <span class="tok-number">0x1e</span>, <span class="tok-number">0x9d</span>, <span class="tok-number">0x50</span>, <span class="tok-number">0x08</span>, <span class="tok-number">0xc3</span>, <span class="tok-number">0x50</span>, <span class="tok-number">0x18</span>, <span class="tok-number">0xc6</span>, <span class="tok-number">0x2a</span>, <span class="tok-number">0x19</span>, <span class="tok-number">0xa0</span>, <span class="tok-number">0xdd</span>, <span class="tok-number">0xc3</span>, <span class="tok-number">0x35</span>,</span>
<span class="line" id="L1000">        <span class="tok-number">0x82</span>, <span class="tok-number">0x3d</span>, <span class="tok-number">0x6a</span>, <span class="tok-number">0xb0</span>, <span class="tok-number">0x34</span>, <span class="tok-number">0x92</span>, <span class="tok-number">0x16</span>, <span class="tok-number">0x8b</span>, <span class="tok-number">0xdb</span>, <span class="tok-number">0x1b</span>, <span class="tok-number">0xeb</span>, <span class="tok-number">0x7d</span>, <span class="tok-number">0xbc</span>, <span class="tok-number">0xf8</span>, <span class="tok-number">0x16</span>,</span>
<span class="line" id="L1001">        <span class="tok-number">0xf8</span>, <span class="tok-number">0xc2</span>, <span class="tok-number">0xe1</span>, <span class="tok-number">0xaf</span>, <span class="tok-number">0x81</span>, <span class="tok-number">0x7e</span>, <span class="tok-number">0x58</span>, <span class="tok-number">0xf4</span>, <span class="tok-number">0x9f</span>, <span class="tok-number">0x74</span>, <span class="tok-number">0xf8</span>, <span class="tok-number">0xcd</span>, <span class="tok-number">0x39</span>, <span class="tok-number">0xd3</span>, <span class="tok-number">0xaa</span>,</span>
<span class="line" id="L1002">        <span class="tok-number">0x0f</span>, <span class="tok-number">0x26</span>, <span class="tok-number">0x31</span>, <span class="tok-number">0xcc</span>, <span class="tok-number">0x8d</span>, <span class="tok-number">0x9a</span>, <span class="tok-number">0xd2</span>, <span class="tok-number">0x04</span>, <span class="tok-number">0x3e</span>, <span class="tok-number">0x51</span>, <span class="tok-number">0xbe</span>, <span class="tok-number">0x7e</span>, <span class="tok-number">0xbc</span>, <span class="tok-number">0xc5</span>, <span class="tok-number">0x27</span>,</span>
<span class="line" id="L1003">        <span class="tok-number">0x3d</span>, <span class="tok-number">0xa5</span>, <span class="tok-number">0xf3</span>, <span class="tok-number">0x15</span>, <span class="tok-number">0x63</span>, <span class="tok-number">0x94</span>, <span class="tok-number">0x42</span>, <span class="tok-number">0x75</span>, <span class="tok-number">0x53</span>, <span class="tok-number">0x6b</span>, <span class="tok-number">0x61</span>, <span class="tok-number">0xc8</span>, <span class="tok-number">0x01</span>, <span class="tok-number">0x13</span>, <span class="tok-number">0x4d</span>,</span>
<span class="line" id="L1004">        <span class="tok-number">0x23</span>, <span class="tok-number">0xba</span>, <span class="tok-number">0x2a</span>, <span class="tok-number">0x2d</span>, <span class="tok-number">0x6c</span>, <span class="tok-number">0x94</span>, <span class="tok-number">0x65</span>, <span class="tok-number">0xc7</span>, <span class="tok-number">0x4b</span>, <span class="tok-number">0x86</span>, <span class="tok-number">0x9b</span>, <span class="tok-number">0x25</span>, <span class="tok-number">0x3e</span>, <span class="tok-number">0xba</span>, <span class="tok-number">0x01</span>,</span>
<span class="line" id="L1005">        <span class="tok-number">0x10</span>, <span class="tok-number">0x84</span>, <span class="tok-number">0x81</span>, <span class="tok-number">0x28</span>, <span class="tok-number">0x80</span>, <span class="tok-number">0x55</span>, <span class="tok-number">0x1c</span>, <span class="tok-number">0xc0</span>, <span class="tok-number">0xa5</span>, <span class="tok-number">0xaa</span>, <span class="tok-number">0x36</span>, <span class="tok-number">0xa6</span>, <span class="tok-number">0x09</span>, <span class="tok-number">0xa8</span>, <span class="tok-number">0xa1</span>,</span>
<span class="line" id="L1006">        <span class="tok-number">0x85</span>, <span class="tok-number">0xf9</span>, <span class="tok-number">0x7d</span>, <span class="tok-number">0x45</span>, <span class="tok-number">0xbf</span>, <span class="tok-number">0x80</span>, <span class="tok-number">0xe4</span>, <span class="tok-number">0xd1</span>, <span class="tok-number">0xbb</span>, <span class="tok-number">0xde</span>, <span class="tok-number">0xb9</span>, <span class="tok-number">0x5e</span>, <span class="tok-number">0xf1</span>, <span class="tok-number">0x23</span>, <span class="tok-number">0x89</span>,</span>
<span class="line" id="L1007">        <span class="tok-number">0x4b</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0xd5</span>, <span class="tok-number">0x59</span>, <span class="tok-number">0x84</span>, <span class="tok-number">0x85</span>, <span class="tok-number">0xe3</span>, <span class="tok-number">0xd4</span>, <span class="tok-number">0xdc</span>, <span class="tok-number">0xb2</span>, <span class="tok-number">0x66</span>, <span class="tok-number">0xe9</span>, <span class="tok-number">0xc1</span>, <span class="tok-number">0x44</span>, <span class="tok-number">0x0b</span>,</span>
<span class="line" id="L1008">        <span class="tok-number">0x1e</span>, <span class="tok-number">0x84</span>, <span class="tok-number">0xec</span>, <span class="tok-number">0xe6</span>, <span class="tok-number">0xa1</span>, <span class="tok-number">0xc7</span>, <span class="tok-number">0x42</span>, <span class="tok-number">0x6a</span>, <span class="tok-number">0x09</span>, <span class="tok-number">0x6d</span>, <span class="tok-number">0x9a</span>, <span class="tok-number">0x5e</span>, <span class="tok-number">0x70</span>, <span class="tok-number">0xa2</span>, <span class="tok-number">0x36</span>,</span>
<span class="line" id="L1009">        <span class="tok-number">0x94</span>, <span class="tok-number">0x29</span>, <span class="tok-number">0x2c</span>, <span class="tok-number">0x85</span>, <span class="tok-number">0x3f</span>, <span class="tok-number">0x24</span>, <span class="tok-number">0x39</span>, <span class="tok-number">0xf3</span>, <span class="tok-number">0xae</span>, <span class="tok-number">0xc3</span>, <span class="tok-number">0xca</span>, <span class="tok-number">0xca</span>, <span class="tok-number">0xaf</span>, <span class="tok-number">0x2f</span>, <span class="tok-number">0xce</span>,</span>
<span class="line" id="L1010">        <span class="tok-number">0x8e</span>, <span class="tok-number">0x58</span>, <span class="tok-number">0x91</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x25</span>, <span class="tok-number">0xb5</span>, <span class="tok-number">0xb3</span>, <span class="tok-number">0xe9</span>, <span class="tok-number">0xd4</span>, <span class="tok-number">0xda</span>, <span class="tok-number">0xef</span>, <span class="tok-number">0xfa</span>, <span class="tok-number">0x48</span>, <span class="tok-number">0x7b</span>, <span class="tok-number">0x3b</span>,</span>
<span class="line" id="L1011">        <span class="tok-number">0xe2</span>, <span class="tok-number">0x63</span>, <span class="tok-number">0x12</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x20</span>, <span class="tok-number">0x04</span>, <span class="tok-number">0x80</span>, <span class="tok-number">0x70</span>, <span class="tok-number">0x36</span>, <span class="tok-number">0x8c</span>, <span class="tok-number">0xbd</span>, <span class="tok-number">0x04</span>, <span class="tok-number">0x71</span>, <span class="tok-number">0xff</span>,</span>
<span class="line" id="L1012">        <span class="tok-number">0xf6</span>, <span class="tok-number">0x0f</span>, <span class="tok-number">0x66</span>, <span class="tok-number">0x38</span>, <span class="tok-number">0xcf</span>, <span class="tok-number">0xa1</span>, <span class="tok-number">0x39</span>, <span class="tok-number">0x11</span>, <span class="tok-number">0x0f</span>,</span>
<span class="line" id="L1013">    };</span>
<span class="line" id="L1014"></span>
<span class="line" id="L1015">    <span class="tok-kw">const</span> expected =</span>
<span class="line" id="L1016">        <span class="tok-str">\\It was the best of times,</span></span>

<span class="line" id="L1017">        <span class="tok-str">\\it was the worst of times,</span></span>

<span class="line" id="L1018">        <span class="tok-str">\\it was the age of wisdom,</span></span>

<span class="line" id="L1019">        <span class="tok-str">\\it was the age of foolishness,</span></span>

<span class="line" id="L1020">        <span class="tok-str">\\it was the epoch of belief,</span></span>

<span class="line" id="L1021">        <span class="tok-str">\\it was the epoch of incredulity,</span></span>

<span class="line" id="L1022">        <span class="tok-str">\\it was the season of Light,</span></span>

<span class="line" id="L1023">        <span class="tok-str">\\it was the season of Darkness,</span></span>

<span class="line" id="L1024">        <span class="tok-str">\\it was the spring of hope,</span></span>

<span class="line" id="L1025">        <span class="tok-str">\\it was the winter of despair,</span></span>

<span class="line" id="L1026">        <span class="tok-str">\\</span></span>

<span class="line" id="L1027">        <span class="tok-str">\\we had everything before us, we had nothing before us, we were all going direct to Heaven, we were all going direct the other way---in short, the period was so far like the present period, that some of its noisiest authorities insisted on its being received, for good or for evil, in the superlative degree of comparison only.</span></span>

<span class="line" id="L1028">        <span class="tok-str">\\</span></span>

<span class="line" id="L1029">    ;</span>
<span class="line" id="L1030"></span>
<span class="line" id="L1031">    <span class="tok-kw">var</span> fib = std.io.fixedBufferStream(&amp;compressed);</span>
<span class="line" id="L1032">    <span class="tok-kw">const</span> reader = fib.reader();</span>
<span class="line" id="L1033">    <span class="tok-kw">var</span> decomp = <span class="tok-kw">try</span> decompressor(testing.allocator, reader, <span class="tok-null">null</span>);</span>
<span class="line" id="L1034">    <span class="tok-kw">defer</span> decomp.deinit();</span>
<span class="line" id="L1035"></span>
<span class="line" id="L1036">    <span class="tok-kw">var</span> got: [<span class="tok-number">700</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L1037">    <span class="tok-kw">var</span> got_len = <span class="tok-kw">try</span> decomp.reader().read(&amp;got);</span>
<span class="line" id="L1038">    <span class="tok-kw">try</span> expect(got_len == <span class="tok-number">616</span>);</span>
<span class="line" id="L1039">    <span class="tok-kw">try</span> expect(mem.eql(<span class="tok-type">u8</span>, got[<span class="tok-number">0</span>..expected.len], expected));</span>
<span class="line" id="L1040">}</span>
<span class="line" id="L1041"></span>
<span class="line" id="L1042"><span class="tok-kw">test</span> <span class="tok-str">&quot;lengths overflow&quot;</span> {</span>
<span class="line" id="L1043">    <span class="tok-comment">// malformed final dynamic block, tries to write 321 code lengths (MAXCODES is 316)</span>
</span>
<span class="line" id="L1044">    <span class="tok-comment">// f dy  hlit hdist hclen 16  17  18   0 (18)    x138 (18)    x138 (18)     x39 (16) x6</span>
</span>
<span class="line" id="L1045">    <span class="tok-comment">// 1 10 11101 11101 0000 010 010 010 010 (11) 1111111 (11) 1111111 (11) 0011100 (01) 11</span>
</span>
<span class="line" id="L1046">    <span class="tok-kw">const</span> stream = [_]<span class="tok-type">u8</span>{</span>
<span class="line" id="L1047">        <span class="tok-number">0b11101101</span>, <span class="tok-number">0b00011101</span>, <span class="tok-number">0b00100100</span>, <span class="tok-number">0b11101001</span>, <span class="tok-number">0b11111111</span>, <span class="tok-number">0b11111111</span>, <span class="tok-number">0b00111001</span>,</span>
<span class="line" id="L1048">        <span class="tok-number">0b00001110</span>,</span>
<span class="line" id="L1049">    };</span>
<span class="line" id="L1050">    <span class="tok-kw">try</span> expectError(<span class="tok-kw">error</span>.CorruptInput, decompress(stream[<span class="tok-number">0</span>..]));</span>
<span class="line" id="L1051">}</span>
<span class="line" id="L1052"></span>
<span class="line" id="L1053"><span class="tok-kw">test</span> <span class="tok-str">&quot;empty distance alphabet&quot;</span> {</span>
<span class="line" id="L1054">    <span class="tok-comment">// dynamic block with empty distance alphabet is valid if only literals and end of data symbol are used</span>
</span>
<span class="line" id="L1055">    <span class="tok-comment">// f dy  hlit hdist hclen 16  17  18   0   8   7   9   6  10   5  11   4  12   3  13   2  14   1  15 (18)    x128 (18)    x128 (1)  ( 0) (256)</span>
</span>
<span class="line" id="L1056">    <span class="tok-comment">// 1 10 00000 00000 1111 000 000 010 010 000 000 000 000 000 000 000 000 000 000 000 000 000 001 000 (11) 1110101 (11) 1110101 (0)  (10)  (0)</span>
</span>
<span class="line" id="L1057">    <span class="tok-kw">const</span> stream = [_]<span class="tok-type">u8</span>{</span>
<span class="line" id="L1058">        <span class="tok-number">0b00000101</span>, <span class="tok-number">0b11100000</span>, <span class="tok-number">0b00000001</span>, <span class="tok-number">0b00001001</span>, <span class="tok-number">0b00000000</span>, <span class="tok-number">0b00000000</span>,</span>
<span class="line" id="L1059">        <span class="tok-number">0b00000000</span>, <span class="tok-number">0b00000000</span>, <span class="tok-number">0b00010000</span>, <span class="tok-number">0b01011100</span>, <span class="tok-number">0b10111111</span>, <span class="tok-number">0b00101110</span>,</span>
<span class="line" id="L1060">    };</span>
<span class="line" id="L1061">    <span class="tok-kw">try</span> decompress(stream[<span class="tok-number">0</span>..]);</span>
<span class="line" id="L1062">}</span>
<span class="line" id="L1063"></span>
<span class="line" id="L1064"><span class="tok-kw">test</span> <span class="tok-str">&quot;distance past beginning of output stream&quot;</span> {</span>
<span class="line" id="L1065">    <span class="tok-comment">// f fx ('A')      ('B')      ('C')      &lt;len=4,   dist=4&gt; (end)</span>
</span>
<span class="line" id="L1066">    <span class="tok-comment">// 1 01 (01110001) (01110010) (01110011) (0000010) (00011) (0000000)</span>
</span>
<span class="line" id="L1067">    <span class="tok-kw">const</span> stream = [_]<span class="tok-type">u8</span>{ <span class="tok-number">0b01110011</span>, <span class="tok-number">0b01110100</span>, <span class="tok-number">0b01110010</span>, <span class="tok-number">0b00000110</span>, <span class="tok-number">0b01100001</span>, <span class="tok-number">0b00000000</span> };</span>
<span class="line" id="L1068">    <span class="tok-kw">try</span> std.testing.expectError(<span class="tok-kw">error</span>.CorruptInput, decompress(stream[<span class="tok-number">0</span>..]));</span>
<span class="line" id="L1069">}</span>
<span class="line" id="L1070"></span>
<span class="line" id="L1071"><span class="tok-kw">test</span> <span class="tok-str">&quot;fuzzing&quot;</span> {</span>
<span class="line" id="L1072">    <span class="tok-kw">const</span> compressed = [_]<span class="tok-type">u8</span>{</span>
<span class="line" id="L1073">        <span class="tok-number">0x0a</span>, <span class="tok-number">0x08</span>, <span class="tok-number">0x50</span>, <span class="tok-number">0xeb</span>, <span class="tok-number">0x25</span>, <span class="tok-number">0x05</span>, <span class="tok-number">0xfc</span>, <span class="tok-number">0x30</span>, <span class="tok-number">0x0b</span>, <span class="tok-number">0x0a</span>, <span class="tok-number">0x08</span>, <span class="tok-number">0x50</span>, <span class="tok-number">0xeb</span>, <span class="tok-number">0x25</span>, <span class="tok-number">0x05</span>,</span>
<span class="line" id="L1074">    } ++ [_]<span class="tok-type">u8</span>{<span class="tok-number">0xe1</span>} ** <span class="tok-number">15</span> ++ [_]<span class="tok-type">u8</span>{<span class="tok-number">0x30</span>} ++ [_]<span class="tok-type">u8</span>{<span class="tok-number">0xe1</span>} ** <span class="tok-number">1481</span>;</span>
<span class="line" id="L1075">    <span class="tok-kw">try</span> expectError(<span class="tok-kw">error</span>.UnexpectedEndOfStream, decompress(&amp;compressed));</span>
<span class="line" id="L1076"></span>
<span class="line" id="L1077">    <span class="tok-comment">// see https://github.com/ziglang/zig/issues/9842</span>
</span>
<span class="line" id="L1078">    <span class="tok-kw">try</span> expectError(<span class="tok-kw">error</span>.UnexpectedEndOfStream, decompress(<span class="tok-str">&quot;\x95\x90=o\xc20\x10\x86\xf30&quot;</span>));</span>
<span class="line" id="L1079">    <span class="tok-kw">try</span> expectError(<span class="tok-kw">error</span>.CorruptInput, decompress(<span class="tok-str">&quot;\x950\x00\x0000000&quot;</span>));</span>
<span class="line" id="L1080"></span>
<span class="line" id="L1081">    <span class="tok-comment">// Huffman errors</span>
</span>
<span class="line" id="L1082">    <span class="tok-comment">// lencode</span>
</span>
<span class="line" id="L1083">    <span class="tok-kw">try</span> expectError(<span class="tok-kw">error</span>.CorruptInput, decompress(<span class="tok-str">&quot;\x950000&quot;</span>));</span>
<span class="line" id="L1084">    <span class="tok-kw">try</span> expectError(<span class="tok-kw">error</span>.CorruptInput, decompress(<span class="tok-str">&quot;\x05000&quot;</span>));</span>
<span class="line" id="L1085">    <span class="tok-comment">// hlen</span>
</span>
<span class="line" id="L1086">    <span class="tok-kw">try</span> expectError(<span class="tok-kw">error</span>.CorruptInput, decompress(<span class="tok-str">&quot;\x05\xea\x01\t\x00\x00\x00\x01\x00\\\xbf.\t\x00&quot;</span>));</span>
<span class="line" id="L1087">    <span class="tok-comment">// hdist</span>
</span>
<span class="line" id="L1088">    <span class="tok-kw">try</span> expectError(<span class="tok-kw">error</span>.CorruptInput, decompress(<span class="tok-str">&quot;\x05\xe0\x01A\x00\x00\x00\x00\x10\\\xbf.&quot;</span>));</span>
<span class="line" id="L1089"></span>
<span class="line" id="L1090">    <span class="tok-comment">// like the &quot;empty distance alphabet&quot; test but for ndist instead of nlen</span>
</span>
<span class="line" id="L1091">    <span class="tok-kw">try</span> expectError(<span class="tok-kw">error</span>.CorruptInput, decompress(<span class="tok-str">&quot;\x05\xe0\x01\t\x00\x00\x00\x00\x10\\\xbf\xce&quot;</span>));</span>
<span class="line" id="L1092">    <span class="tok-kw">try</span> decompress(<span class="tok-str">&quot;\x15\xe0\x01\t\x00\x00\x00\x00\x10\\\xbf.0&quot;</span>);</span>
<span class="line" id="L1093">}</span>
<span class="line" id="L1094"></span>
<span class="line" id="L1095"><span class="tok-kw">fn</span> <span class="tok-fn">decompress</span>(input: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) !<span class="tok-type">void</span> {</span>
<span class="line" id="L1096">    <span class="tok-kw">const</span> allocator = testing.allocator;</span>
<span class="line" id="L1097">    <span class="tok-kw">var</span> fib = std.io.fixedBufferStream(input);</span>
<span class="line" id="L1098">    <span class="tok-kw">const</span> reader = fib.reader();</span>
<span class="line" id="L1099">    <span class="tok-kw">var</span> decomp = <span class="tok-kw">try</span> decompressor(allocator, reader, <span class="tok-null">null</span>);</span>
<span class="line" id="L1100">    <span class="tok-kw">defer</span> decomp.deinit();</span>
<span class="line" id="L1101">    <span class="tok-kw">var</span> output = <span class="tok-kw">try</span> decomp.reader().readAllAlloc(allocator, math.maxInt(<span class="tok-type">usize</span>));</span>
<span class="line" id="L1102">    <span class="tok-kw">defer</span> std.testing.allocator.free(output);</span>
<span class="line" id="L1103">}</span>
<span class="line" id="L1104"></span>
</code></pre></body>
</html>