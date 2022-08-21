<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">    <title>compress/deflate/deflate_fast.zig - source view</title>
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
<pre><code><span class="line" id="L1"><span class="tok-comment">// This encoding algorithm, which prioritizes speed over output size, is</span>
</span>
<span class="line" id="L2"><span class="tok-comment">// based on Snappy's LZ77-style encoder: github.com/golang/snappy</span>
</span>
<span class="line" id="L3"></span>
<span class="line" id="L4"><span class="tok-kw">const</span> std = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;std&quot;</span>);</span>
<span class="line" id="L5"><span class="tok-kw">const</span> math = std.math;</span>
<span class="line" id="L6"><span class="tok-kw">const</span> mem = std.mem;</span>
<span class="line" id="L7"></span>
<span class="line" id="L8"><span class="tok-kw">const</span> Allocator = std.mem.Allocator;</span>
<span class="line" id="L9"></span>
<span class="line" id="L10"><span class="tok-kw">const</span> deflate_const = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;deflate_const.zig&quot;</span>);</span>
<span class="line" id="L11"><span class="tok-kw">const</span> deflate = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;compressor.zig&quot;</span>);</span>
<span class="line" id="L12"><span class="tok-kw">const</span> token = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;token.zig&quot;</span>);</span>
<span class="line" id="L13"></span>
<span class="line" id="L14"><span class="tok-kw">const</span> base_match_length = deflate_const.base_match_length;</span>
<span class="line" id="L15"><span class="tok-kw">const</span> base_match_offset = deflate_const.base_match_offset;</span>
<span class="line" id="L16"><span class="tok-kw">const</span> max_match_length = deflate_const.max_match_length;</span>
<span class="line" id="L17"><span class="tok-kw">const</span> max_match_offset = deflate_const.max_match_offset;</span>
<span class="line" id="L18"><span class="tok-kw">const</span> max_store_block_size = deflate_const.max_store_block_size;</span>
<span class="line" id="L19"></span>
<span class="line" id="L20"><span class="tok-kw">const</span> table_bits = <span class="tok-number">14</span>; <span class="tok-comment">// Bits used in the table.</span>
</span>
<span class="line" id="L21"><span class="tok-kw">const</span> table_mask = table_size - <span class="tok-number">1</span>; <span class="tok-comment">// Mask for table indices. Redundant, but can eliminate bounds checks.</span>
</span>
<span class="line" id="L22"><span class="tok-kw">const</span> table_shift = <span class="tok-number">32</span> - table_bits; <span class="tok-comment">// Right-shift to get the table_bits most significant bits of a uint32.</span>
</span>
<span class="line" id="L23"><span class="tok-kw">const</span> table_size = <span class="tok-number">1</span> &lt;&lt; table_bits; <span class="tok-comment">// Size of the table.</span>
</span>
<span class="line" id="L24"></span>
<span class="line" id="L25"><span class="tok-comment">// Reset the buffer offset when reaching this.</span>
</span>
<span class="line" id="L26"><span class="tok-comment">// Offsets are stored between blocks as i32 values.</span>
</span>
<span class="line" id="L27"><span class="tok-comment">// Since the offset we are checking against is at the beginning</span>
</span>
<span class="line" id="L28"><span class="tok-comment">// of the buffer, we need to subtract the current and input</span>
</span>
<span class="line" id="L29"><span class="tok-comment">// buffer to not risk overflowing the i32.</span>
</span>
<span class="line" id="L30"><span class="tok-kw">const</span> buffer_reset = math.maxInt(<span class="tok-type">i32</span>) - max_store_block_size * <span class="tok-number">2</span>;</span>
<span class="line" id="L31"></span>
<span class="line" id="L32"><span class="tok-kw">fn</span> <span class="tok-fn">load32</span>(b: []<span class="tok-type">u8</span>, i: <span class="tok-type">i32</span>) <span class="tok-type">u32</span> {</span>
<span class="line" id="L33">    <span class="tok-kw">var</span> s = b[<span class="tok-builtin">@intCast</span>(<span class="tok-type">usize</span>, i) .. <span class="tok-builtin">@intCast</span>(<span class="tok-type">usize</span>, i) + <span class="tok-number">4</span>];</span>
<span class="line" id="L34">    <span class="tok-kw">return</span> <span class="tok-builtin">@intCast</span>(<span class="tok-type">u32</span>, s[<span class="tok-number">0</span>]) |</span>
<span class="line" id="L35">        <span class="tok-builtin">@intCast</span>(<span class="tok-type">u32</span>, s[<span class="tok-number">1</span>]) &lt;&lt; <span class="tok-number">8</span> |</span>
<span class="line" id="L36">        <span class="tok-builtin">@intCast</span>(<span class="tok-type">u32</span>, s[<span class="tok-number">2</span>]) &lt;&lt; <span class="tok-number">16</span> |</span>
<span class="line" id="L37">        <span class="tok-builtin">@intCast</span>(<span class="tok-type">u32</span>, s[<span class="tok-number">3</span>]) &lt;&lt; <span class="tok-number">24</span>;</span>
<span class="line" id="L38">}</span>
<span class="line" id="L39"></span>
<span class="line" id="L40"><span class="tok-kw">fn</span> <span class="tok-fn">load64</span>(b: []<span class="tok-type">u8</span>, i: <span class="tok-type">i32</span>) <span class="tok-type">u64</span> {</span>
<span class="line" id="L41">    <span class="tok-kw">var</span> s = b[<span class="tok-builtin">@intCast</span>(<span class="tok-type">usize</span>, i)..<span class="tok-builtin">@intCast</span>(<span class="tok-type">usize</span>, i + <span class="tok-number">8</span>)];</span>
<span class="line" id="L42">    <span class="tok-kw">return</span> <span class="tok-builtin">@intCast</span>(<span class="tok-type">u64</span>, s[<span class="tok-number">0</span>]) |</span>
<span class="line" id="L43">        <span class="tok-builtin">@intCast</span>(<span class="tok-type">u64</span>, s[<span class="tok-number">1</span>]) &lt;&lt; <span class="tok-number">8</span> |</span>
<span class="line" id="L44">        <span class="tok-builtin">@intCast</span>(<span class="tok-type">u64</span>, s[<span class="tok-number">2</span>]) &lt;&lt; <span class="tok-number">16</span> |</span>
<span class="line" id="L45">        <span class="tok-builtin">@intCast</span>(<span class="tok-type">u64</span>, s[<span class="tok-number">3</span>]) &lt;&lt; <span class="tok-number">24</span> |</span>
<span class="line" id="L46">        <span class="tok-builtin">@intCast</span>(<span class="tok-type">u64</span>, s[<span class="tok-number">4</span>]) &lt;&lt; <span class="tok-number">32</span> |</span>
<span class="line" id="L47">        <span class="tok-builtin">@intCast</span>(<span class="tok-type">u64</span>, s[<span class="tok-number">5</span>]) &lt;&lt; <span class="tok-number">40</span> |</span>
<span class="line" id="L48">        <span class="tok-builtin">@intCast</span>(<span class="tok-type">u64</span>, s[<span class="tok-number">6</span>]) &lt;&lt; <span class="tok-number">48</span> |</span>
<span class="line" id="L49">        <span class="tok-builtin">@intCast</span>(<span class="tok-type">u64</span>, s[<span class="tok-number">7</span>]) &lt;&lt; <span class="tok-number">56</span>;</span>
<span class="line" id="L50">}</span>
<span class="line" id="L51"></span>
<span class="line" id="L52"><span class="tok-kw">fn</span> <span class="tok-fn">hash</span>(u: <span class="tok-type">u32</span>) <span class="tok-type">u32</span> {</span>
<span class="line" id="L53">    <span class="tok-kw">return</span> (u *% <span class="tok-number">0x1e35a7bd</span>) &gt;&gt; table_shift;</span>
<span class="line" id="L54">}</span>
<span class="line" id="L55"></span>
<span class="line" id="L56"><span class="tok-comment">// These constants are defined by the Snappy implementation so that its</span>
</span>
<span class="line" id="L57"><span class="tok-comment">// assembly implementation can fast-path some 16-bytes-at-a-time copies.</span>
</span>
<span class="line" id="L58"><span class="tok-comment">// They aren't necessary in the pure Go implementation, and may not be</span>
</span>
<span class="line" id="L59"><span class="tok-comment">// necessary in Zig, but using the same thresholds doesn't really hurt.</span>
</span>
<span class="line" id="L60"><span class="tok-kw">const</span> input_margin = <span class="tok-number">16</span> - <span class="tok-number">1</span>;</span>
<span class="line" id="L61"><span class="tok-kw">const</span> min_non_literal_block_size = <span class="tok-number">1</span> + <span class="tok-number">1</span> + input_margin;</span>
<span class="line" id="L62"></span>
<span class="line" id="L63"><span class="tok-kw">const</span> TableEntry = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L64">    val: <span class="tok-type">u32</span>, <span class="tok-comment">// Value at destination</span>
</span>
<span class="line" id="L65">    offset: <span class="tok-type">i32</span>,</span>
<span class="line" id="L66">};</span>
<span class="line" id="L67"></span>
<span class="line" id="L68"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">deflateFast</span>() DeflateFast {</span>
<span class="line" id="L69">    <span class="tok-kw">return</span> DeflateFast{</span>
<span class="line" id="L70">        .table = [_]TableEntry{.{ .val = <span class="tok-number">0</span>, .offset = <span class="tok-number">0</span> }} ** table_size,</span>
<span class="line" id="L71">        .prev = <span class="tok-null">undefined</span>,</span>
<span class="line" id="L72">        .prev_len = <span class="tok-number">0</span>,</span>
<span class="line" id="L73">        .cur = max_store_block_size,</span>
<span class="line" id="L74">        .allocator = <span class="tok-null">undefined</span>,</span>
<span class="line" id="L75">    };</span>
<span class="line" id="L76">}</span>
<span class="line" id="L77"></span>
<span class="line" id="L78"><span class="tok-comment">// DeflateFast maintains the table for matches,</span>
</span>
<span class="line" id="L79"><span class="tok-comment">// and the previous byte block for cross block matching.</span>
</span>
<span class="line" id="L80"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> DeflateFast = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L81">    table: [table_size]TableEntry,</span>
<span class="line" id="L82">    prev: []<span class="tok-type">u8</span>, <span class="tok-comment">// Previous block, zero length if unknown.</span>
</span>
<span class="line" id="L83">    prev_len: <span class="tok-type">u32</span>, <span class="tok-comment">// Previous block length</span>
</span>
<span class="line" id="L84">    cur: <span class="tok-type">i32</span>, <span class="tok-comment">// Current match offset.</span>
</span>
<span class="line" id="L85">    allocator: Allocator,</span>
<span class="line" id="L86"></span>
<span class="line" id="L87">    <span class="tok-kw">const</span> Self = <span class="tok-builtin">@This</span>();</span>
<span class="line" id="L88"></span>
<span class="line" id="L89">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">init</span>(self: *Self, allocator: Allocator) !<span class="tok-type">void</span> {</span>
<span class="line" id="L90">        self.allocator = allocator;</span>
<span class="line" id="L91">        self.prev = <span class="tok-kw">try</span> allocator.alloc(<span class="tok-type">u8</span>, max_store_block_size);</span>
<span class="line" id="L92">        self.prev_len = <span class="tok-number">0</span>;</span>
<span class="line" id="L93">    }</span>
<span class="line" id="L94"></span>
<span class="line" id="L95">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">deinit</span>(self: *Self) <span class="tok-type">void</span> {</span>
<span class="line" id="L96">        self.allocator.free(self.prev);</span>
<span class="line" id="L97">        self.prev_len = <span class="tok-number">0</span>;</span>
<span class="line" id="L98">    }</span>
<span class="line" id="L99"></span>
<span class="line" id="L100">    <span class="tok-comment">// Encodes a block given in `src` and appends tokens to `dst` and returns the result.</span>
</span>
<span class="line" id="L101">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">encode</span>(self: *Self, dst: []token.Token, tokens_count: *<span class="tok-type">u16</span>, src: []<span class="tok-type">u8</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L102"></span>
<span class="line" id="L103">        <span class="tok-comment">// Ensure that self.cur doesn't wrap.</span>
</span>
<span class="line" id="L104">        <span class="tok-kw">if</span> (self.cur &gt;= buffer_reset) {</span>
<span class="line" id="L105">            self.shiftOffsets();</span>
<span class="line" id="L106">        }</span>
<span class="line" id="L107"></span>
<span class="line" id="L108">        <span class="tok-comment">// This check isn't in the Snappy implementation, but there, the caller</span>
</span>
<span class="line" id="L109">        <span class="tok-comment">// instead of the callee handles this case.</span>
</span>
<span class="line" id="L110">        <span class="tok-kw">if</span> (src.len &lt; min_non_literal_block_size) {</span>
<span class="line" id="L111">            self.cur += max_store_block_size;</span>
<span class="line" id="L112">            self.prev_len = <span class="tok-number">0</span>;</span>
<span class="line" id="L113">            emitLiteral(dst, tokens_count, src);</span>
<span class="line" id="L114">            <span class="tok-kw">return</span>;</span>
<span class="line" id="L115">        }</span>
<span class="line" id="L116"></span>
<span class="line" id="L117">        <span class="tok-comment">// s_limit is when to stop looking for offset/length copies. The input_margin</span>
</span>
<span class="line" id="L118">        <span class="tok-comment">// lets us use a fast path for emitLiteral in the main loop, while we are</span>
</span>
<span class="line" id="L119">        <span class="tok-comment">// looking for copies.</span>
</span>
<span class="line" id="L120">        <span class="tok-kw">var</span> s_limit = <span class="tok-builtin">@intCast</span>(<span class="tok-type">i32</span>, src.len - input_margin);</span>
<span class="line" id="L121"></span>
<span class="line" id="L122">        <span class="tok-comment">// next_emit is where in src the next emitLiteral should start from.</span>
</span>
<span class="line" id="L123">        <span class="tok-kw">var</span> next_emit: <span class="tok-type">i32</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L124">        <span class="tok-kw">var</span> s: <span class="tok-type">i32</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L125">        <span class="tok-kw">var</span> cv: <span class="tok-type">u32</span> = load32(src, s);</span>
<span class="line" id="L126">        <span class="tok-kw">var</span> next_hash: <span class="tok-type">u32</span> = hash(cv);</span>
<span class="line" id="L127"></span>
<span class="line" id="L128">        outer: <span class="tok-kw">while</span> (<span class="tok-null">true</span>) {</span>
<span class="line" id="L129">            <span class="tok-comment">// Copied from the C++ snappy implementation:</span>
</span>
<span class="line" id="L130">            <span class="tok-comment">//</span>
</span>
<span class="line" id="L131">            <span class="tok-comment">// Heuristic match skipping: If 32 bytes are scanned with no matches</span>
</span>
<span class="line" id="L132">            <span class="tok-comment">// found, start looking only at every other byte. If 32 more bytes are</span>
</span>
<span class="line" id="L133">            <span class="tok-comment">// scanned (or skipped), look at every third byte, etc.. When a match</span>
</span>
<span class="line" id="L134">            <span class="tok-comment">// is found, immediately go back to looking at every byte. This is a</span>
</span>
<span class="line" id="L135">            <span class="tok-comment">// small loss (~5% performance, ~0.1% density) for compressible data</span>
</span>
<span class="line" id="L136">            <span class="tok-comment">// due to more bookkeeping, but for non-compressible data (such as</span>
</span>
<span class="line" id="L137">            <span class="tok-comment">// JPEG) it's a huge win since the compressor quickly &quot;realizes&quot; the</span>
</span>
<span class="line" id="L138">            <span class="tok-comment">// data is incompressible and doesn't bother looking for matches</span>
</span>
<span class="line" id="L139">            <span class="tok-comment">// everywhere.</span>
</span>
<span class="line" id="L140">            <span class="tok-comment">//</span>
</span>
<span class="line" id="L141">            <span class="tok-comment">// The &quot;skip&quot; variable keeps track of how many bytes there are since</span>
</span>
<span class="line" id="L142">            <span class="tok-comment">// the last match; dividing it by 32 (ie. right-shifting by five) gives</span>
</span>
<span class="line" id="L143">            <span class="tok-comment">// the number of bytes to move ahead for each iteration.</span>
</span>
<span class="line" id="L144">            <span class="tok-kw">var</span> skip: <span class="tok-type">i32</span> = <span class="tok-number">32</span>;</span>
<span class="line" id="L145"></span>
<span class="line" id="L146">            <span class="tok-kw">var</span> next_s: <span class="tok-type">i32</span> = s;</span>
<span class="line" id="L147">            <span class="tok-kw">var</span> candidate: TableEntry = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L148">            <span class="tok-kw">while</span> (<span class="tok-null">true</span>) {</span>
<span class="line" id="L149">                s = next_s;</span>
<span class="line" id="L150">                <span class="tok-kw">var</span> bytes_between_hash_lookups = skip &gt;&gt; <span class="tok-number">5</span>;</span>
<span class="line" id="L151">                next_s = s + bytes_between_hash_lookups;</span>
<span class="line" id="L152">                skip += bytes_between_hash_lookups;</span>
<span class="line" id="L153">                <span class="tok-kw">if</span> (next_s &gt; s_limit) {</span>
<span class="line" id="L154">                    <span class="tok-kw">break</span> :outer;</span>
<span class="line" id="L155">                }</span>
<span class="line" id="L156">                candidate = self.table[next_hash &amp; table_mask];</span>
<span class="line" id="L157">                <span class="tok-kw">var</span> now = load32(src, next_s);</span>
<span class="line" id="L158">                self.table[next_hash &amp; table_mask] = .{ .offset = s + self.cur, .val = cv };</span>
<span class="line" id="L159">                next_hash = hash(now);</span>
<span class="line" id="L160"></span>
<span class="line" id="L161">                <span class="tok-kw">var</span> offset = s - (candidate.offset - self.cur);</span>
<span class="line" id="L162">                <span class="tok-kw">if</span> (offset &gt; max_match_offset <span class="tok-kw">or</span> cv != candidate.val) {</span>
<span class="line" id="L163">                    <span class="tok-comment">// Out of range or not matched.</span>
</span>
<span class="line" id="L164">                    cv = now;</span>
<span class="line" id="L165">                    <span class="tok-kw">continue</span>;</span>
<span class="line" id="L166">                }</span>
<span class="line" id="L167">                <span class="tok-kw">break</span>;</span>
<span class="line" id="L168">            }</span>
<span class="line" id="L169"></span>
<span class="line" id="L170">            <span class="tok-comment">// A 4-byte match has been found. We'll later see if more than 4 bytes</span>
</span>
<span class="line" id="L171">            <span class="tok-comment">// match. But, prior to the match, src[next_emit..s] are unmatched. Emit</span>
</span>
<span class="line" id="L172">            <span class="tok-comment">// them as literal bytes.</span>
</span>
<span class="line" id="L173">            emitLiteral(dst, tokens_count, src[<span class="tok-builtin">@intCast</span>(<span class="tok-type">usize</span>, next_emit)..<span class="tok-builtin">@intCast</span>(<span class="tok-type">usize</span>, s)]);</span>
<span class="line" id="L174"></span>
<span class="line" id="L175">            <span class="tok-comment">// Call emitCopy, and then see if another emitCopy could be our next</span>
</span>
<span class="line" id="L176">            <span class="tok-comment">// move. Repeat until we find no match for the input immediately after</span>
</span>
<span class="line" id="L177">            <span class="tok-comment">// what was consumed by the last emitCopy call.</span>
</span>
<span class="line" id="L178">            <span class="tok-comment">//</span>
</span>
<span class="line" id="L179">            <span class="tok-comment">// If we exit this loop normally then we need to call emitLiteral next,</span>
</span>
<span class="line" id="L180">            <span class="tok-comment">// though we don't yet know how big the literal will be. We handle that</span>
</span>
<span class="line" id="L181">            <span class="tok-comment">// by proceeding to the next iteration of the main loop. We also can</span>
</span>
<span class="line" id="L182">            <span class="tok-comment">// exit this loop via goto if we get close to exhausting the input.</span>
</span>
<span class="line" id="L183">            <span class="tok-kw">while</span> (<span class="tok-null">true</span>) {</span>
<span class="line" id="L184">                <span class="tok-comment">// Invariant: we have a 4-byte match at s, and no need to emit any</span>
</span>
<span class="line" id="L185">                <span class="tok-comment">// literal bytes prior to s.</span>
</span>
<span class="line" id="L186"></span>
<span class="line" id="L187">                <span class="tok-comment">// Extend the 4-byte match as long as possible.</span>
</span>
<span class="line" id="L188">                <span class="tok-comment">//</span>
</span>
<span class="line" id="L189">                s += <span class="tok-number">4</span>;</span>
<span class="line" id="L190">                <span class="tok-kw">var</span> t = candidate.offset - self.cur + <span class="tok-number">4</span>;</span>
<span class="line" id="L191">                <span class="tok-kw">var</span> l = self.matchLen(s, t, src);</span>
<span class="line" id="L192"></span>
<span class="line" id="L193">                <span class="tok-comment">// matchToken is flate's equivalent of Snappy's emitCopy. (length,offset)</span>
</span>
<span class="line" id="L194">                dst[tokens_count.*] = token.matchToken(</span>
<span class="line" id="L195">                    <span class="tok-builtin">@intCast</span>(<span class="tok-type">u32</span>, l + <span class="tok-number">4</span> - base_match_length),</span>
<span class="line" id="L196">                    <span class="tok-builtin">@intCast</span>(<span class="tok-type">u32</span>, s - t - base_match_offset),</span>
<span class="line" id="L197">                );</span>
<span class="line" id="L198">                tokens_count.* += <span class="tok-number">1</span>;</span>
<span class="line" id="L199">                s += l;</span>
<span class="line" id="L200">                next_emit = s;</span>
<span class="line" id="L201">                <span class="tok-kw">if</span> (s &gt;= s_limit) {</span>
<span class="line" id="L202">                    <span class="tok-kw">break</span> :outer;</span>
<span class="line" id="L203">                }</span>
<span class="line" id="L204"></span>
<span class="line" id="L205">                <span class="tok-comment">// We could immediately start working at s now, but to improve</span>
</span>
<span class="line" id="L206">                <span class="tok-comment">// compression we first update the hash table at s-1 and at s. If</span>
</span>
<span class="line" id="L207">                <span class="tok-comment">// another emitCopy is not our next move, also calculate next_hash</span>
</span>
<span class="line" id="L208">                <span class="tok-comment">// at s+1. At least on amd64 architecture, these three hash calculations</span>
</span>
<span class="line" id="L209">                <span class="tok-comment">// are faster as one load64 call (with some shifts) instead of</span>
</span>
<span class="line" id="L210">                <span class="tok-comment">// three load32 calls.</span>
</span>
<span class="line" id="L211">                <span class="tok-kw">var</span> x = load64(src, s - <span class="tok-number">1</span>);</span>
<span class="line" id="L212">                <span class="tok-kw">var</span> prev_hash = hash(<span class="tok-builtin">@truncate</span>(<span class="tok-type">u32</span>, x));</span>
<span class="line" id="L213">                self.table[prev_hash &amp; table_mask] = TableEntry{</span>
<span class="line" id="L214">                    .offset = self.cur + s - <span class="tok-number">1</span>,</span>
<span class="line" id="L215">                    .val = <span class="tok-builtin">@truncate</span>(<span class="tok-type">u32</span>, x),</span>
<span class="line" id="L216">                };</span>
<span class="line" id="L217">                x &gt;&gt;= <span class="tok-number">8</span>;</span>
<span class="line" id="L218">                <span class="tok-kw">var</span> curr_hash = hash(<span class="tok-builtin">@truncate</span>(<span class="tok-type">u32</span>, x));</span>
<span class="line" id="L219">                candidate = self.table[curr_hash &amp; table_mask];</span>
<span class="line" id="L220">                self.table[curr_hash &amp; table_mask] = TableEntry{</span>
<span class="line" id="L221">                    .offset = self.cur + s,</span>
<span class="line" id="L222">                    .val = <span class="tok-builtin">@truncate</span>(<span class="tok-type">u32</span>, x),</span>
<span class="line" id="L223">                };</span>
<span class="line" id="L224"></span>
<span class="line" id="L225">                <span class="tok-kw">var</span> offset = s - (candidate.offset - self.cur);</span>
<span class="line" id="L226">                <span class="tok-kw">if</span> (offset &gt; max_match_offset <span class="tok-kw">or</span> <span class="tok-builtin">@truncate</span>(<span class="tok-type">u32</span>, x) != candidate.val) {</span>
<span class="line" id="L227">                    cv = <span class="tok-builtin">@truncate</span>(<span class="tok-type">u32</span>, x &gt;&gt; <span class="tok-number">8</span>);</span>
<span class="line" id="L228">                    next_hash = hash(cv);</span>
<span class="line" id="L229">                    s += <span class="tok-number">1</span>;</span>
<span class="line" id="L230">                    <span class="tok-kw">break</span>;</span>
<span class="line" id="L231">                }</span>
<span class="line" id="L232">            }</span>
<span class="line" id="L233">        }</span>
<span class="line" id="L234"></span>
<span class="line" id="L235">        <span class="tok-kw">if</span> (<span class="tok-builtin">@intCast</span>(<span class="tok-type">u32</span>, next_emit) &lt; src.len) {</span>
<span class="line" id="L236">            emitLiteral(dst, tokens_count, src[<span class="tok-builtin">@intCast</span>(<span class="tok-type">usize</span>, next_emit)..]);</span>
<span class="line" id="L237">        }</span>
<span class="line" id="L238">        self.cur += <span class="tok-builtin">@intCast</span>(<span class="tok-type">i32</span>, src.len);</span>
<span class="line" id="L239">        self.prev_len = <span class="tok-builtin">@intCast</span>(<span class="tok-type">u32</span>, src.len);</span>
<span class="line" id="L240">        mem.copy(<span class="tok-type">u8</span>, self.prev[<span class="tok-number">0</span>..self.prev_len], src);</span>
<span class="line" id="L241">        <span class="tok-kw">return</span>;</span>
<span class="line" id="L242">    }</span>
<span class="line" id="L243"></span>
<span class="line" id="L244">    <span class="tok-kw">fn</span> <span class="tok-fn">emitLiteral</span>(dst: []token.Token, tokens_count: *<span class="tok-type">u16</span>, lit: []<span class="tok-type">u8</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L245">        <span class="tok-kw">for</span> (lit) |v| {</span>
<span class="line" id="L246">            dst[tokens_count.*] = token.literalToken(<span class="tok-builtin">@intCast</span>(<span class="tok-type">u32</span>, v));</span>
<span class="line" id="L247">            tokens_count.* += <span class="tok-number">1</span>;</span>
<span class="line" id="L248">        }</span>
<span class="line" id="L249">        <span class="tok-kw">return</span>;</span>
<span class="line" id="L250">    }</span>
<span class="line" id="L251"></span>
<span class="line" id="L252">    <span class="tok-comment">// matchLen returns the match length between src[s..] and src[t..].</span>
</span>
<span class="line" id="L253">    <span class="tok-comment">// t can be negative to indicate the match is starting in self.prev.</span>
</span>
<span class="line" id="L254">    <span class="tok-comment">// We assume that src[s-4 .. s] and src[t-4 .. t] already match.</span>
</span>
<span class="line" id="L255">    <span class="tok-kw">fn</span> <span class="tok-fn">matchLen</span>(self: *Self, s: <span class="tok-type">i32</span>, t: <span class="tok-type">i32</span>, src: []<span class="tok-type">u8</span>) <span class="tok-type">i32</span> {</span>
<span class="line" id="L256">        <span class="tok-kw">var</span> s1 = <span class="tok-builtin">@intCast</span>(<span class="tok-type">u32</span>, s) + max_match_length - <span class="tok-number">4</span>;</span>
<span class="line" id="L257">        <span class="tok-kw">if</span> (s1 &gt; src.len) {</span>
<span class="line" id="L258">            s1 = <span class="tok-builtin">@intCast</span>(<span class="tok-type">u32</span>, src.len);</span>
<span class="line" id="L259">        }</span>
<span class="line" id="L260"></span>
<span class="line" id="L261">        <span class="tok-comment">// If we are inside the current block</span>
</span>
<span class="line" id="L262">        <span class="tok-kw">if</span> (t &gt;= <span class="tok-number">0</span>) {</span>
<span class="line" id="L263">            <span class="tok-kw">var</span> b = src[<span class="tok-builtin">@intCast</span>(<span class="tok-type">usize</span>, t)..];</span>
<span class="line" id="L264">            <span class="tok-kw">var</span> a = src[<span class="tok-builtin">@intCast</span>(<span class="tok-type">usize</span>, s)..<span class="tok-builtin">@intCast</span>(<span class="tok-type">usize</span>, s1)];</span>
<span class="line" id="L265">            b = b[<span class="tok-number">0</span>..a.len];</span>
<span class="line" id="L266">            <span class="tok-comment">// Extend the match to be as long as possible.</span>
</span>
<span class="line" id="L267">            <span class="tok-kw">for</span> (a) |_, i| {</span>
<span class="line" id="L268">                <span class="tok-kw">if</span> (a[i] != b[i]) {</span>
<span class="line" id="L269">                    <span class="tok-kw">return</span> <span class="tok-builtin">@intCast</span>(<span class="tok-type">i32</span>, i);</span>
<span class="line" id="L270">                }</span>
<span class="line" id="L271">            }</span>
<span class="line" id="L272">            <span class="tok-kw">return</span> <span class="tok-builtin">@intCast</span>(<span class="tok-type">i32</span>, a.len);</span>
<span class="line" id="L273">        }</span>
<span class="line" id="L274"></span>
<span class="line" id="L275">        <span class="tok-comment">// We found a match in the previous block.</span>
</span>
<span class="line" id="L276">        <span class="tok-kw">var</span> tp = <span class="tok-builtin">@intCast</span>(<span class="tok-type">i32</span>, self.prev_len) + t;</span>
<span class="line" id="L277">        <span class="tok-kw">if</span> (tp &lt; <span class="tok-number">0</span>) {</span>
<span class="line" id="L278">            <span class="tok-kw">return</span> <span class="tok-number">0</span>;</span>
<span class="line" id="L279">        }</span>
<span class="line" id="L280"></span>
<span class="line" id="L281">        <span class="tok-comment">// Extend the match to be as long as possible.</span>
</span>
<span class="line" id="L282">        <span class="tok-kw">var</span> a = src[<span class="tok-builtin">@intCast</span>(<span class="tok-type">usize</span>, s)..<span class="tok-builtin">@intCast</span>(<span class="tok-type">usize</span>, s1)];</span>
<span class="line" id="L283">        <span class="tok-kw">var</span> b = self.prev[<span class="tok-builtin">@intCast</span>(<span class="tok-type">usize</span>, tp)..<span class="tok-builtin">@intCast</span>(<span class="tok-type">usize</span>, self.prev_len)];</span>
<span class="line" id="L284">        <span class="tok-kw">if</span> (b.len &gt; a.len) {</span>
<span class="line" id="L285">            b = b[<span class="tok-number">0</span>..a.len];</span>
<span class="line" id="L286">        }</span>
<span class="line" id="L287">        a = a[<span class="tok-number">0</span>..b.len];</span>
<span class="line" id="L288">        <span class="tok-kw">for</span> (b) |_, i| {</span>
<span class="line" id="L289">            <span class="tok-kw">if</span> (a[i] != b[i]) {</span>
<span class="line" id="L290">                <span class="tok-kw">return</span> <span class="tok-builtin">@intCast</span>(<span class="tok-type">i32</span>, i);</span>
<span class="line" id="L291">            }</span>
<span class="line" id="L292">        }</span>
<span class="line" id="L293"></span>
<span class="line" id="L294">        <span class="tok-comment">// If we reached our limit, we matched everything we are</span>
</span>
<span class="line" id="L295">        <span class="tok-comment">// allowed to in the previous block and we return.</span>
</span>
<span class="line" id="L296">        <span class="tok-kw">var</span> n = <span class="tok-builtin">@intCast</span>(<span class="tok-type">i32</span>, b.len);</span>
<span class="line" id="L297">        <span class="tok-kw">if</span> (<span class="tok-builtin">@intCast</span>(<span class="tok-type">u32</span>, s + n) == s1) {</span>
<span class="line" id="L298">            <span class="tok-kw">return</span> n;</span>
<span class="line" id="L299">        }</span>
<span class="line" id="L300"></span>
<span class="line" id="L301">        <span class="tok-comment">// Continue looking for more matches in the current block.</span>
</span>
<span class="line" id="L302">        a = src[<span class="tok-builtin">@intCast</span>(<span class="tok-type">usize</span>, s + n)..<span class="tok-builtin">@intCast</span>(<span class="tok-type">usize</span>, s1)];</span>
<span class="line" id="L303">        b = src[<span class="tok-number">0</span>..a.len];</span>
<span class="line" id="L304">        <span class="tok-kw">for</span> (a) |_, i| {</span>
<span class="line" id="L305">            <span class="tok-kw">if</span> (a[i] != b[i]) {</span>
<span class="line" id="L306">                <span class="tok-kw">return</span> <span class="tok-builtin">@intCast</span>(<span class="tok-type">i32</span>, i) + n;</span>
<span class="line" id="L307">            }</span>
<span class="line" id="L308">        }</span>
<span class="line" id="L309">        <span class="tok-kw">return</span> <span class="tok-builtin">@intCast</span>(<span class="tok-type">i32</span>, a.len) + n;</span>
<span class="line" id="L310">    }</span>
<span class="line" id="L311"></span>
<span class="line" id="L312">    <span class="tok-comment">// Reset resets the encoding history.</span>
</span>
<span class="line" id="L313">    <span class="tok-comment">// This ensures that no matches are made to the previous block.</span>
</span>
<span class="line" id="L314">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">reset</span>(self: *Self) <span class="tok-type">void</span> {</span>
<span class="line" id="L315">        self.prev_len = <span class="tok-number">0</span>;</span>
<span class="line" id="L316">        <span class="tok-comment">// Bump the offset, so all matches will fail distance check.</span>
</span>
<span class="line" id="L317">        <span class="tok-comment">// Nothing should be &gt;= self.cur in the table.</span>
</span>
<span class="line" id="L318">        self.cur += max_match_offset;</span>
<span class="line" id="L319"></span>
<span class="line" id="L320">        <span class="tok-comment">// Protect against self.cur wraparound.</span>
</span>
<span class="line" id="L321">        <span class="tok-kw">if</span> (self.cur &gt;= buffer_reset) {</span>
<span class="line" id="L322">            self.shiftOffsets();</span>
<span class="line" id="L323">        }</span>
<span class="line" id="L324">    }</span>
<span class="line" id="L325"></span>
<span class="line" id="L326">    <span class="tok-comment">// shiftOffsets will shift down all match offset.</span>
</span>
<span class="line" id="L327">    <span class="tok-comment">// This is only called in rare situations to prevent integer overflow.</span>
</span>
<span class="line" id="L328">    <span class="tok-comment">//</span>
</span>
<span class="line" id="L329">    <span class="tok-comment">// See https://golang.org/issue/18636 and https://golang.org/issues/34121.</span>
</span>
<span class="line" id="L330">    <span class="tok-kw">fn</span> <span class="tok-fn">shiftOffsets</span>(self: *Self) <span class="tok-type">void</span> {</span>
<span class="line" id="L331">        <span class="tok-kw">if</span> (self.prev_len == <span class="tok-number">0</span>) {</span>
<span class="line" id="L332">            <span class="tok-comment">// We have no history; just clear the table.</span>
</span>
<span class="line" id="L333">            <span class="tok-kw">for</span> (self.table) |_, i| {</span>
<span class="line" id="L334">                self.table[i] = TableEntry{ .val = <span class="tok-number">0</span>, .offset = <span class="tok-number">0</span> };</span>
<span class="line" id="L335">            }</span>
<span class="line" id="L336">            self.cur = max_match_offset + <span class="tok-number">1</span>;</span>
<span class="line" id="L337">            <span class="tok-kw">return</span>;</span>
<span class="line" id="L338">        }</span>
<span class="line" id="L339"></span>
<span class="line" id="L340">        <span class="tok-comment">// Shift down everything in the table that isn't already too far away.</span>
</span>
<span class="line" id="L341">        <span class="tok-kw">for</span> (self.table) |_, i| {</span>
<span class="line" id="L342">            <span class="tok-kw">var</span> v = self.table[i].offset - self.cur + max_match_offset + <span class="tok-number">1</span>;</span>
<span class="line" id="L343">            <span class="tok-kw">if</span> (v &lt; <span class="tok-number">0</span>) {</span>
<span class="line" id="L344">                <span class="tok-comment">// We want to reset self.cur to max_match_offset + 1, so we need to shift</span>
</span>
<span class="line" id="L345">                <span class="tok-comment">// all table entries down by (self.cur - (max_match_offset + 1)).</span>
</span>
<span class="line" id="L346">                <span class="tok-comment">// Because we ignore matches &gt; max_match_offset, we can cap</span>
</span>
<span class="line" id="L347">                <span class="tok-comment">// any negative offsets at 0.</span>
</span>
<span class="line" id="L348">                v = <span class="tok-number">0</span>;</span>
<span class="line" id="L349">            }</span>
<span class="line" id="L350">            self.table[i].offset = v;</span>
<span class="line" id="L351">        }</span>
<span class="line" id="L352">        self.cur = max_match_offset + <span class="tok-number">1</span>;</span>
<span class="line" id="L353">    }</span>
<span class="line" id="L354">};</span>
<span class="line" id="L355"></span>
<span class="line" id="L356"><span class="tok-kw">test</span> <span class="tok-str">&quot;best speed match 1/3&quot;</span> {</span>
<span class="line" id="L357">    <span class="tok-kw">const</span> expect = std.testing.expect;</span>
<span class="line" id="L358"></span>
<span class="line" id="L359">    {</span>
<span class="line" id="L360">        <span class="tok-kw">var</span> previous = [_]<span class="tok-type">u8</span>{ <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">1</span>, <span class="tok-number">2</span> };</span>
<span class="line" id="L361">        <span class="tok-kw">var</span> e = DeflateFast{</span>
<span class="line" id="L362">            .prev = &amp;previous,</span>
<span class="line" id="L363">            .prev_len = previous.len,</span>
<span class="line" id="L364">            .table = <span class="tok-null">undefined</span>,</span>
<span class="line" id="L365">            .allocator = <span class="tok-null">undefined</span>,</span>
<span class="line" id="L366">            .cur = <span class="tok-number">0</span>,</span>
<span class="line" id="L367">        };</span>
<span class="line" id="L368">        <span class="tok-kw">var</span> current = [_]<span class="tok-type">u8</span>{ <span class="tok-number">3</span>, <span class="tok-number">4</span>, <span class="tok-number">5</span>, <span class="tok-number">0</span>, <span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">4</span>, <span class="tok-number">5</span> };</span>
<span class="line" id="L369">        <span class="tok-kw">var</span> got: <span class="tok-type">i32</span> = e.matchLen(<span class="tok-number">3</span>, -<span class="tok-number">3</span>, &amp;current);</span>
<span class="line" id="L370">        <span class="tok-kw">try</span> expect(got == <span class="tok-number">6</span>);</span>
<span class="line" id="L371">    }</span>
<span class="line" id="L372">    {</span>
<span class="line" id="L373">        <span class="tok-kw">var</span> previous = [_]<span class="tok-type">u8</span>{ <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">1</span>, <span class="tok-number">2</span> };</span>
<span class="line" id="L374">        <span class="tok-kw">var</span> e = DeflateFast{</span>
<span class="line" id="L375">            .prev = &amp;previous,</span>
<span class="line" id="L376">            .prev_len = previous.len,</span>
<span class="line" id="L377">            .table = <span class="tok-null">undefined</span>,</span>
<span class="line" id="L378">            .allocator = <span class="tok-null">undefined</span>,</span>
<span class="line" id="L379">            .cur = <span class="tok-number">0</span>,</span>
<span class="line" id="L380">        };</span>
<span class="line" id="L381">        <span class="tok-kw">var</span> current = [_]<span class="tok-type">u8</span>{ <span class="tok-number">2</span>, <span class="tok-number">4</span>, <span class="tok-number">5</span>, <span class="tok-number">0</span>, <span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">4</span>, <span class="tok-number">5</span> };</span>
<span class="line" id="L382">        <span class="tok-kw">var</span> got: <span class="tok-type">i32</span> = e.matchLen(<span class="tok-number">3</span>, -<span class="tok-number">3</span>, &amp;current);</span>
<span class="line" id="L383">        <span class="tok-kw">try</span> expect(got == <span class="tok-number">3</span>);</span>
<span class="line" id="L384">    }</span>
<span class="line" id="L385">    {</span>
<span class="line" id="L386">        <span class="tok-kw">var</span> previous = [_]<span class="tok-type">u8</span>{ <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">1</span>, <span class="tok-number">1</span> };</span>
<span class="line" id="L387">        <span class="tok-kw">var</span> e = DeflateFast{</span>
<span class="line" id="L388">            .prev = &amp;previous,</span>
<span class="line" id="L389">            .prev_len = previous.len,</span>
<span class="line" id="L390">            .table = <span class="tok-null">undefined</span>,</span>
<span class="line" id="L391">            .allocator = <span class="tok-null">undefined</span>,</span>
<span class="line" id="L392">            .cur = <span class="tok-number">0</span>,</span>
<span class="line" id="L393">        };</span>
<span class="line" id="L394">        <span class="tok-kw">var</span> current = [_]<span class="tok-type">u8</span>{ <span class="tok-number">3</span>, <span class="tok-number">4</span>, <span class="tok-number">5</span>, <span class="tok-number">0</span>, <span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">4</span>, <span class="tok-number">5</span> };</span>
<span class="line" id="L395">        <span class="tok-kw">var</span> got: <span class="tok-type">i32</span> = e.matchLen(<span class="tok-number">3</span>, -<span class="tok-number">3</span>, &amp;current);</span>
<span class="line" id="L396">        <span class="tok-kw">try</span> expect(got == <span class="tok-number">2</span>);</span>
<span class="line" id="L397">    }</span>
<span class="line" id="L398">    {</span>
<span class="line" id="L399">        <span class="tok-kw">var</span> previous = [_]<span class="tok-type">u8</span>{ <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">1</span>, <span class="tok-number">2</span> };</span>
<span class="line" id="L400">        <span class="tok-kw">var</span> e = DeflateFast{</span>
<span class="line" id="L401">            .prev = &amp;previous,</span>
<span class="line" id="L402">            .prev_len = previous.len,</span>
<span class="line" id="L403">            .table = <span class="tok-null">undefined</span>,</span>
<span class="line" id="L404">            .allocator = <span class="tok-null">undefined</span>,</span>
<span class="line" id="L405">            .cur = <span class="tok-number">0</span>,</span>
<span class="line" id="L406">        };</span>
<span class="line" id="L407">        <span class="tok-kw">var</span> current = [_]<span class="tok-type">u8</span>{ <span class="tok-number">2</span>, <span class="tok-number">2</span>, <span class="tok-number">2</span>, <span class="tok-number">2</span>, <span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">4</span>, <span class="tok-number">5</span> };</span>
<span class="line" id="L408">        <span class="tok-kw">var</span> got: <span class="tok-type">i32</span> = e.matchLen(<span class="tok-number">0</span>, -<span class="tok-number">1</span>, &amp;current);</span>
<span class="line" id="L409">        <span class="tok-kw">try</span> expect(got == <span class="tok-number">4</span>);</span>
<span class="line" id="L410">    }</span>
<span class="line" id="L411">    {</span>
<span class="line" id="L412">        <span class="tok-kw">var</span> previous = [_]<span class="tok-type">u8</span>{ <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">4</span>, <span class="tok-number">5</span>, <span class="tok-number">2</span>, <span class="tok-number">2</span> };</span>
<span class="line" id="L413">        <span class="tok-kw">var</span> e = DeflateFast{</span>
<span class="line" id="L414">            .prev = &amp;previous,</span>
<span class="line" id="L415">            .prev_len = previous.len,</span>
<span class="line" id="L416">            .table = <span class="tok-null">undefined</span>,</span>
<span class="line" id="L417">            .allocator = <span class="tok-null">undefined</span>,</span>
<span class="line" id="L418">            .cur = <span class="tok-number">0</span>,</span>
<span class="line" id="L419">        };</span>
<span class="line" id="L420">        <span class="tok-kw">var</span> current = [_]<span class="tok-type">u8</span>{ <span class="tok-number">2</span>, <span class="tok-number">2</span>, <span class="tok-number">2</span>, <span class="tok-number">2</span>, <span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">4</span>, <span class="tok-number">5</span> };</span>
<span class="line" id="L421">        <span class="tok-kw">var</span> got: <span class="tok-type">i32</span> = e.matchLen(<span class="tok-number">4</span>, -<span class="tok-number">7</span>, &amp;current);</span>
<span class="line" id="L422">        <span class="tok-kw">try</span> expect(got == <span class="tok-number">5</span>);</span>
<span class="line" id="L423">    }</span>
<span class="line" id="L424">    {</span>
<span class="line" id="L425">        <span class="tok-kw">var</span> previous = [_]<span class="tok-type">u8</span>{ <span class="tok-number">9</span>, <span class="tok-number">9</span>, <span class="tok-number">9</span>, <span class="tok-number">9</span>, <span class="tok-number">9</span> };</span>
<span class="line" id="L426">        <span class="tok-kw">var</span> e = DeflateFast{</span>
<span class="line" id="L427">            .prev = &amp;previous,</span>
<span class="line" id="L428">            .prev_len = previous.len,</span>
<span class="line" id="L429">            .table = <span class="tok-null">undefined</span>,</span>
<span class="line" id="L430">            .allocator = <span class="tok-null">undefined</span>,</span>
<span class="line" id="L431">            .cur = <span class="tok-number">0</span>,</span>
<span class="line" id="L432">        };</span>
<span class="line" id="L433">        <span class="tok-kw">var</span> current = [_]<span class="tok-type">u8</span>{ <span class="tok-number">2</span>, <span class="tok-number">2</span>, <span class="tok-number">2</span>, <span class="tok-number">2</span>, <span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">4</span>, <span class="tok-number">5</span> };</span>
<span class="line" id="L434">        <span class="tok-kw">var</span> got: <span class="tok-type">i32</span> = e.matchLen(<span class="tok-number">0</span>, -<span class="tok-number">1</span>, &amp;current);</span>
<span class="line" id="L435">        <span class="tok-kw">try</span> expect(got == <span class="tok-number">0</span>);</span>
<span class="line" id="L436">    }</span>
<span class="line" id="L437">    {</span>
<span class="line" id="L438">        <span class="tok-kw">var</span> previous = [_]<span class="tok-type">u8</span>{ <span class="tok-number">9</span>, <span class="tok-number">9</span>, <span class="tok-number">9</span>, <span class="tok-number">9</span>, <span class="tok-number">9</span> };</span>
<span class="line" id="L439">        <span class="tok-kw">var</span> e = DeflateFast{</span>
<span class="line" id="L440">            .prev = &amp;previous,</span>
<span class="line" id="L441">            .prev_len = previous.len,</span>
<span class="line" id="L442">            .table = <span class="tok-null">undefined</span>,</span>
<span class="line" id="L443">            .allocator = <span class="tok-null">undefined</span>,</span>
<span class="line" id="L444">            .cur = <span class="tok-number">0</span>,</span>
<span class="line" id="L445">        };</span>
<span class="line" id="L446">        <span class="tok-kw">var</span> current = [_]<span class="tok-type">u8</span>{ <span class="tok-number">9</span>, <span class="tok-number">2</span>, <span class="tok-number">2</span>, <span class="tok-number">2</span>, <span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">4</span>, <span class="tok-number">5</span> };</span>
<span class="line" id="L447">        <span class="tok-kw">var</span> got: <span class="tok-type">i32</span> = e.matchLen(<span class="tok-number">1</span>, <span class="tok-number">0</span>, &amp;current);</span>
<span class="line" id="L448">        <span class="tok-kw">try</span> expect(got == <span class="tok-number">0</span>);</span>
<span class="line" id="L449">    }</span>
<span class="line" id="L450">}</span>
<span class="line" id="L451"></span>
<span class="line" id="L452"><span class="tok-kw">test</span> <span class="tok-str">&quot;best speed match 2/3&quot;</span> {</span>
<span class="line" id="L453">    <span class="tok-kw">const</span> expect = std.testing.expect;</span>
<span class="line" id="L454"></span>
<span class="line" id="L455">    {</span>
<span class="line" id="L456">        <span class="tok-kw">var</span> previous = [_]<span class="tok-type">u8</span>{};</span>
<span class="line" id="L457">        <span class="tok-kw">var</span> e = DeflateFast{</span>
<span class="line" id="L458">            .prev = &amp;previous,</span>
<span class="line" id="L459">            .prev_len = previous.len,</span>
<span class="line" id="L460">            .table = <span class="tok-null">undefined</span>,</span>
<span class="line" id="L461">            .allocator = <span class="tok-null">undefined</span>,</span>
<span class="line" id="L462">            .cur = <span class="tok-number">0</span>,</span>
<span class="line" id="L463">        };</span>
<span class="line" id="L464">        <span class="tok-kw">var</span> current = [_]<span class="tok-type">u8</span>{ <span class="tok-number">9</span>, <span class="tok-number">2</span>, <span class="tok-number">2</span>, <span class="tok-number">2</span>, <span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">4</span>, <span class="tok-number">5</span> };</span>
<span class="line" id="L465">        <span class="tok-kw">var</span> got: <span class="tok-type">i32</span> = e.matchLen(<span class="tok-number">1</span>, -<span class="tok-number">5</span>, &amp;current);</span>
<span class="line" id="L466">        <span class="tok-kw">try</span> expect(got == <span class="tok-number">0</span>);</span>
<span class="line" id="L467">    }</span>
<span class="line" id="L468">    {</span>
<span class="line" id="L469">        <span class="tok-kw">var</span> previous = [_]<span class="tok-type">u8</span>{};</span>
<span class="line" id="L470">        <span class="tok-kw">var</span> e = DeflateFast{</span>
<span class="line" id="L471">            .prev = &amp;previous,</span>
<span class="line" id="L472">            .prev_len = previous.len,</span>
<span class="line" id="L473">            .table = <span class="tok-null">undefined</span>,</span>
<span class="line" id="L474">            .allocator = <span class="tok-null">undefined</span>,</span>
<span class="line" id="L475">            .cur = <span class="tok-number">0</span>,</span>
<span class="line" id="L476">        };</span>
<span class="line" id="L477">        <span class="tok-kw">var</span> current = [_]<span class="tok-type">u8</span>{ <span class="tok-number">9</span>, <span class="tok-number">2</span>, <span class="tok-number">2</span>, <span class="tok-number">2</span>, <span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">4</span>, <span class="tok-number">5</span> };</span>
<span class="line" id="L478">        <span class="tok-kw">var</span> got: <span class="tok-type">i32</span> = e.matchLen(<span class="tok-number">1</span>, -<span class="tok-number">1</span>, &amp;current);</span>
<span class="line" id="L479">        <span class="tok-kw">try</span> expect(got == <span class="tok-number">0</span>);</span>
<span class="line" id="L480">    }</span>
<span class="line" id="L481">    {</span>
<span class="line" id="L482">        <span class="tok-kw">var</span> previous = [_]<span class="tok-type">u8</span>{};</span>
<span class="line" id="L483">        <span class="tok-kw">var</span> e = DeflateFast{</span>
<span class="line" id="L484">            .prev = &amp;previous,</span>
<span class="line" id="L485">            .prev_len = previous.len,</span>
<span class="line" id="L486">            .table = <span class="tok-null">undefined</span>,</span>
<span class="line" id="L487">            .allocator = <span class="tok-null">undefined</span>,</span>
<span class="line" id="L488">            .cur = <span class="tok-number">0</span>,</span>
<span class="line" id="L489">        };</span>
<span class="line" id="L490">        <span class="tok-kw">var</span> current = [_]<span class="tok-type">u8</span>{ <span class="tok-number">2</span>, <span class="tok-number">2</span>, <span class="tok-number">2</span>, <span class="tok-number">2</span>, <span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">4</span>, <span class="tok-number">5</span> };</span>
<span class="line" id="L491">        <span class="tok-kw">var</span> got: <span class="tok-type">i32</span> = e.matchLen(<span class="tok-number">1</span>, <span class="tok-number">0</span>, &amp;current);</span>
<span class="line" id="L492">        <span class="tok-kw">try</span> expect(got == <span class="tok-number">3</span>);</span>
<span class="line" id="L493">    }</span>
<span class="line" id="L494">    {</span>
<span class="line" id="L495">        <span class="tok-kw">var</span> previous = [_]<span class="tok-type">u8</span>{ <span class="tok-number">3</span>, <span class="tok-number">4</span>, <span class="tok-number">5</span> };</span>
<span class="line" id="L496">        <span class="tok-kw">var</span> e = DeflateFast{</span>
<span class="line" id="L497">            .prev = &amp;previous,</span>
<span class="line" id="L498">            .prev_len = previous.len,</span>
<span class="line" id="L499">            .table = <span class="tok-null">undefined</span>,</span>
<span class="line" id="L500">            .allocator = <span class="tok-null">undefined</span>,</span>
<span class="line" id="L501">            .cur = <span class="tok-number">0</span>,</span>
<span class="line" id="L502">        };</span>
<span class="line" id="L503">        <span class="tok-kw">var</span> current = [_]<span class="tok-type">u8</span>{ <span class="tok-number">3</span>, <span class="tok-number">4</span>, <span class="tok-number">5</span> };</span>
<span class="line" id="L504">        <span class="tok-kw">var</span> got: <span class="tok-type">i32</span> = e.matchLen(<span class="tok-number">0</span>, -<span class="tok-number">3</span>, &amp;current);</span>
<span class="line" id="L505">        <span class="tok-kw">try</span> expect(got == <span class="tok-number">3</span>);</span>
<span class="line" id="L506">    }</span>
<span class="line" id="L507">}</span>
<span class="line" id="L508"></span>
<span class="line" id="L509"><span class="tok-kw">test</span> <span class="tok-str">&quot;best speed match 2/2&quot;</span> {</span>
<span class="line" id="L510">    <span class="tok-kw">const</span> testing = std.testing;</span>
<span class="line" id="L511">    <span class="tok-kw">const</span> expect = testing.expect;</span>
<span class="line" id="L512"></span>
<span class="line" id="L513">    <span class="tok-kw">const</span> Case = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L514">        previous: <span class="tok-type">u32</span>,</span>
<span class="line" id="L515">        current: <span class="tok-type">u32</span>,</span>
<span class="line" id="L516">        s: <span class="tok-type">i32</span>,</span>
<span class="line" id="L517">        t: <span class="tok-type">i32</span>,</span>
<span class="line" id="L518">        expected: <span class="tok-type">i32</span>,</span>
<span class="line" id="L519">    };</span>
<span class="line" id="L520"></span>
<span class="line" id="L521">    <span class="tok-kw">const</span> cases = [_]Case{</span>
<span class="line" id="L522">        .{</span>
<span class="line" id="L523">            .previous = <span class="tok-number">1000</span>,</span>
<span class="line" id="L524">            .current = <span class="tok-number">1000</span>,</span>
<span class="line" id="L525">            .s = <span class="tok-number">0</span>,</span>
<span class="line" id="L526">            .t = -<span class="tok-number">1000</span>,</span>
<span class="line" id="L527">            .expected = max_match_length - <span class="tok-number">4</span>,</span>
<span class="line" id="L528">        },</span>
<span class="line" id="L529">        .{</span>
<span class="line" id="L530">            .previous = <span class="tok-number">200</span>,</span>
<span class="line" id="L531">            .s = <span class="tok-number">0</span>,</span>
<span class="line" id="L532">            .t = -<span class="tok-number">200</span>,</span>
<span class="line" id="L533">            .current = <span class="tok-number">500</span>,</span>
<span class="line" id="L534">            .expected = max_match_length - <span class="tok-number">4</span>,</span>
<span class="line" id="L535">        },</span>
<span class="line" id="L536">        .{</span>
<span class="line" id="L537">            .previous = <span class="tok-number">200</span>,</span>
<span class="line" id="L538">            .s = <span class="tok-number">1</span>,</span>
<span class="line" id="L539">            .t = <span class="tok-number">0</span>,</span>
<span class="line" id="L540">            .current = <span class="tok-number">500</span>,</span>
<span class="line" id="L541">            .expected = max_match_length - <span class="tok-number">4</span>,</span>
<span class="line" id="L542">        },</span>
<span class="line" id="L543">        .{</span>
<span class="line" id="L544">            .previous = max_match_length - <span class="tok-number">4</span>,</span>
<span class="line" id="L545">            .s = <span class="tok-number">0</span>,</span>
<span class="line" id="L546">            .t = -(max_match_length - <span class="tok-number">4</span>),</span>
<span class="line" id="L547">            .current = <span class="tok-number">500</span>,</span>
<span class="line" id="L548">            .expected = max_match_length - <span class="tok-number">4</span>,</span>
<span class="line" id="L549">        },</span>
<span class="line" id="L550">        .{</span>
<span class="line" id="L551">            .previous = <span class="tok-number">200</span>,</span>
<span class="line" id="L552">            .s = <span class="tok-number">400</span>,</span>
<span class="line" id="L553">            .t = -<span class="tok-number">200</span>,</span>
<span class="line" id="L554">            .current = <span class="tok-number">500</span>,</span>
<span class="line" id="L555">            .expected = <span class="tok-number">100</span>,</span>
<span class="line" id="L556">        },</span>
<span class="line" id="L557">        .{</span>
<span class="line" id="L558">            .previous = <span class="tok-number">10</span>,</span>
<span class="line" id="L559">            .s = <span class="tok-number">400</span>,</span>
<span class="line" id="L560">            .t = <span class="tok-number">200</span>,</span>
<span class="line" id="L561">            .current = <span class="tok-number">500</span>,</span>
<span class="line" id="L562">            .expected = <span class="tok-number">100</span>,</span>
<span class="line" id="L563">        },</span>
<span class="line" id="L564">    };</span>
<span class="line" id="L565"></span>
<span class="line" id="L566">    <span class="tok-kw">for</span> (cases) |c| {</span>
<span class="line" id="L567">        <span class="tok-kw">var</span> previous = <span class="tok-kw">try</span> testing.allocator.alloc(<span class="tok-type">u8</span>, c.previous);</span>
<span class="line" id="L568">        <span class="tok-kw">defer</span> testing.allocator.free(previous);</span>
<span class="line" id="L569">        mem.set(<span class="tok-type">u8</span>, previous, <span class="tok-number">0</span>);</span>
<span class="line" id="L570"></span>
<span class="line" id="L571">        <span class="tok-kw">var</span> current = <span class="tok-kw">try</span> testing.allocator.alloc(<span class="tok-type">u8</span>, c.current);</span>
<span class="line" id="L572">        <span class="tok-kw">defer</span> testing.allocator.free(current);</span>
<span class="line" id="L573">        mem.set(<span class="tok-type">u8</span>, current, <span class="tok-number">0</span>);</span>
<span class="line" id="L574"></span>
<span class="line" id="L575">        <span class="tok-kw">var</span> e = DeflateFast{</span>
<span class="line" id="L576">            .prev = previous,</span>
<span class="line" id="L577">            .prev_len = <span class="tok-builtin">@intCast</span>(<span class="tok-type">u32</span>, previous.len),</span>
<span class="line" id="L578">            .table = <span class="tok-null">undefined</span>,</span>
<span class="line" id="L579">            .allocator = <span class="tok-null">undefined</span>,</span>
<span class="line" id="L580">            .cur = <span class="tok-number">0</span>,</span>
<span class="line" id="L581">        };</span>
<span class="line" id="L582">        <span class="tok-kw">var</span> got: <span class="tok-type">i32</span> = e.matchLen(c.s, c.t, current);</span>
<span class="line" id="L583">        <span class="tok-kw">try</span> expect(got == c.expected);</span>
<span class="line" id="L584">    }</span>
<span class="line" id="L585">}</span>
<span class="line" id="L586"></span>
<span class="line" id="L587"><span class="tok-kw">test</span> <span class="tok-str">&quot;best speed shift offsets&quot;</span> {</span>
<span class="line" id="L588">    <span class="tok-kw">const</span> testing = std.testing;</span>
<span class="line" id="L589">    <span class="tok-kw">const</span> expect = std.testing.expect;</span>
<span class="line" id="L590"></span>
<span class="line" id="L591">    <span class="tok-comment">// Test if shiftoffsets properly preserves matches and resets out-of-range matches</span>
</span>
<span class="line" id="L592">    <span class="tok-comment">// seen in https://github.com/golang/go/issues/4142</span>
</span>
<span class="line" id="L593">    <span class="tok-kw">var</span> enc = deflateFast();</span>
<span class="line" id="L594">    <span class="tok-kw">try</span> enc.init(testing.allocator);</span>
<span class="line" id="L595">    <span class="tok-kw">defer</span> enc.deinit();</span>
<span class="line" id="L596"></span>
<span class="line" id="L597">    <span class="tok-comment">// test_data may not generate internal matches.</span>
</span>
<span class="line" id="L598">    <span class="tok-kw">var</span> test_data = [<span class="tok-number">32</span>]<span class="tok-type">u8</span>{</span>
<span class="line" id="L599">        <span class="tok-number">0xf5</span>, <span class="tok-number">0x25</span>, <span class="tok-number">0xf2</span>, <span class="tok-number">0x55</span>, <span class="tok-number">0xf6</span>, <span class="tok-number">0xc1</span>, <span class="tok-number">0x1f</span>, <span class="tok-number">0x0b</span>, <span class="tok-number">0x10</span>, <span class="tok-number">0xa1</span>,</span>
<span class="line" id="L600">        <span class="tok-number">0xd0</span>, <span class="tok-number">0x77</span>, <span class="tok-number">0x56</span>, <span class="tok-number">0x38</span>, <span class="tok-number">0xf1</span>, <span class="tok-number">0x9c</span>, <span class="tok-number">0x7f</span>, <span class="tok-number">0x85</span>, <span class="tok-number">0xc5</span>, <span class="tok-number">0xbd</span>,</span>
<span class="line" id="L601">        <span class="tok-number">0x16</span>, <span class="tok-number">0x28</span>, <span class="tok-number">0xd4</span>, <span class="tok-number">0xf9</span>, <span class="tok-number">0x03</span>, <span class="tok-number">0xd4</span>, <span class="tok-number">0xc0</span>, <span class="tok-number">0xa1</span>, <span class="tok-number">0x1e</span>, <span class="tok-number">0x58</span>,</span>
<span class="line" id="L602">        <span class="tok-number">0x5b</span>, <span class="tok-number">0xc9</span>,</span>
<span class="line" id="L603">    };</span>
<span class="line" id="L604"></span>
<span class="line" id="L605">    <span class="tok-kw">var</span> tokens = [_]token.Token{<span class="tok-number">0</span>} ** <span class="tok-number">32</span>;</span>
<span class="line" id="L606">    <span class="tok-kw">var</span> tokens_count: <span class="tok-type">u16</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L607"></span>
<span class="line" id="L608">    <span class="tok-comment">// Encode the testdata with clean state.</span>
</span>
<span class="line" id="L609">    <span class="tok-comment">// Second part should pick up matches from the first block.</span>
</span>
<span class="line" id="L610">    tokens_count = <span class="tok-number">0</span>;</span>
<span class="line" id="L611">    enc.encode(&amp;tokens, &amp;tokens_count, &amp;test_data);</span>
<span class="line" id="L612">    <span class="tok-kw">var</span> want_first_tokens = tokens_count;</span>
<span class="line" id="L613">    tokens_count = <span class="tok-number">0</span>;</span>
<span class="line" id="L614">    enc.encode(&amp;tokens, &amp;tokens_count, &amp;test_data);</span>
<span class="line" id="L615">    <span class="tok-kw">var</span> want_second_tokens = tokens_count;</span>
<span class="line" id="L616"></span>
<span class="line" id="L617">    <span class="tok-kw">try</span> expect(want_first_tokens &gt; want_second_tokens);</span>
<span class="line" id="L618"></span>
<span class="line" id="L619">    <span class="tok-comment">// Forward the current indicator to before wraparound.</span>
</span>
<span class="line" id="L620">    enc.cur = buffer_reset - <span class="tok-builtin">@intCast</span>(<span class="tok-type">i32</span>, test_data.len);</span>
<span class="line" id="L621"></span>
<span class="line" id="L622">    <span class="tok-comment">// Part 1 before wrap, should match clean state.</span>
</span>
<span class="line" id="L623">    tokens_count = <span class="tok-number">0</span>;</span>
<span class="line" id="L624">    enc.encode(&amp;tokens, &amp;tokens_count, &amp;test_data);</span>
<span class="line" id="L625">    <span class="tok-kw">var</span> got = tokens_count;</span>
<span class="line" id="L626">    <span class="tok-kw">try</span> expect(want_first_tokens == got);</span>
<span class="line" id="L627"></span>
<span class="line" id="L628">    <span class="tok-comment">// Verify we are about to wrap.</span>
</span>
<span class="line" id="L629">    <span class="tok-kw">try</span> expect(enc.cur == buffer_reset);</span>
<span class="line" id="L630"></span>
<span class="line" id="L631">    <span class="tok-comment">// Part 2 should match clean state as well even if wrapped.</span>
</span>
<span class="line" id="L632">    tokens_count = <span class="tok-number">0</span>;</span>
<span class="line" id="L633">    enc.encode(&amp;tokens, &amp;tokens_count, &amp;test_data);</span>
<span class="line" id="L634">    got = tokens_count;</span>
<span class="line" id="L635">    <span class="tok-kw">try</span> expect(want_second_tokens == got);</span>
<span class="line" id="L636"></span>
<span class="line" id="L637">    <span class="tok-comment">// Verify that we wrapped.</span>
</span>
<span class="line" id="L638">    <span class="tok-kw">try</span> expect(enc.cur &lt; buffer_reset);</span>
<span class="line" id="L639"></span>
<span class="line" id="L640">    <span class="tok-comment">// Forward the current buffer, leaving the matches at the bottom.</span>
</span>
<span class="line" id="L641">    enc.cur = buffer_reset;</span>
<span class="line" id="L642">    enc.shiftOffsets();</span>
<span class="line" id="L643"></span>
<span class="line" id="L644">    <span class="tok-comment">// Ensure that no matches were picked up.</span>
</span>
<span class="line" id="L645">    tokens_count = <span class="tok-number">0</span>;</span>
<span class="line" id="L646">    enc.encode(&amp;tokens, &amp;tokens_count, &amp;test_data);</span>
<span class="line" id="L647">    got = tokens_count;</span>
<span class="line" id="L648">    <span class="tok-kw">try</span> expect(want_first_tokens == got);</span>
<span class="line" id="L649">}</span>
<span class="line" id="L650"></span>
<span class="line" id="L651"><span class="tok-kw">test</span> <span class="tok-str">&quot;best speed reset&quot;</span> {</span>
<span class="line" id="L652">    <span class="tok-comment">// test that encoding is consistent across a warparound of the table offset.</span>
</span>
<span class="line" id="L653">    <span class="tok-comment">// See https://github.com/golang/go/issues/34121</span>
</span>
<span class="line" id="L654">    <span class="tok-kw">const</span> expect = std.testing.expect;</span>
<span class="line" id="L655">    <span class="tok-kw">const</span> fmt = std.fmt;</span>
<span class="line" id="L656">    <span class="tok-kw">const</span> testing = std.testing;</span>
<span class="line" id="L657"></span>
<span class="line" id="L658">    <span class="tok-kw">const</span> ArrayList = std.ArrayList;</span>
<span class="line" id="L659"></span>
<span class="line" id="L660">    <span class="tok-kw">const</span> input_size = <span class="tok-number">65536</span>;</span>
<span class="line" id="L661">    <span class="tok-kw">var</span> input = <span class="tok-kw">try</span> testing.allocator.alloc(<span class="tok-type">u8</span>, input_size);</span>
<span class="line" id="L662">    <span class="tok-kw">defer</span> testing.allocator.free(input);</span>
<span class="line" id="L663"></span>
<span class="line" id="L664">    <span class="tok-kw">var</span> i: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L665">    <span class="tok-kw">while</span> (i &lt; input_size) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L666">        _ = <span class="tok-kw">try</span> fmt.bufPrint(input, <span class="tok-str">&quot;asdfasdfasdfasdf{d}{d}fghfgujyut{d}yutyu\n&quot;</span>, .{ i, i, i });</span>
<span class="line" id="L667">    }</span>
<span class="line" id="L668">    <span class="tok-comment">// This is specific to level 1 (best_speed).</span>
</span>
<span class="line" id="L669">    <span class="tok-kw">const</span> level = .best_speed;</span>
<span class="line" id="L670">    <span class="tok-kw">const</span> offset: <span class="tok-type">usize</span> = <span class="tok-number">1</span>;</span>
<span class="line" id="L671"></span>
<span class="line" id="L672">    <span class="tok-comment">// We do an encode with a clean buffer to compare.</span>
</span>
<span class="line" id="L673">    <span class="tok-kw">var</span> want = ArrayList(<span class="tok-type">u8</span>).init(testing.allocator);</span>
<span class="line" id="L674">    <span class="tok-kw">defer</span> want.deinit();</span>
<span class="line" id="L675">    <span class="tok-kw">var</span> clean_comp = <span class="tok-kw">try</span> deflate.compressor(</span>
<span class="line" id="L676">        testing.allocator,</span>
<span class="line" id="L677">        want.writer(),</span>
<span class="line" id="L678">        .{ .level = level },</span>
<span class="line" id="L679">    );</span>
<span class="line" id="L680">    <span class="tok-kw">defer</span> clean_comp.deinit();</span>
<span class="line" id="L681"></span>
<span class="line" id="L682">    <span class="tok-comment">// Write 3 times, close.</span>
</span>
<span class="line" id="L683">    <span class="tok-kw">try</span> clean_comp.writer().writeAll(input);</span>
<span class="line" id="L684">    <span class="tok-kw">try</span> clean_comp.writer().writeAll(input);</span>
<span class="line" id="L685">    <span class="tok-kw">try</span> clean_comp.writer().writeAll(input);</span>
<span class="line" id="L686">    <span class="tok-kw">try</span> clean_comp.close();</span>
<span class="line" id="L687"></span>
<span class="line" id="L688">    <span class="tok-kw">var</span> o = offset;</span>
<span class="line" id="L689">    <span class="tok-kw">while</span> (o &lt;= <span class="tok-number">256</span>) : (o *= <span class="tok-number">2</span>) {</span>
<span class="line" id="L690">        <span class="tok-kw">var</span> discard = ArrayList(<span class="tok-type">u8</span>).init(testing.allocator);</span>
<span class="line" id="L691">        <span class="tok-kw">defer</span> discard.deinit();</span>
<span class="line" id="L692"></span>
<span class="line" id="L693">        <span class="tok-kw">var</span> comp = <span class="tok-kw">try</span> deflate.compressor(</span>
<span class="line" id="L694">            testing.allocator,</span>
<span class="line" id="L695">            discard.writer(),</span>
<span class="line" id="L696">            .{ .level = level },</span>
<span class="line" id="L697">        );</span>
<span class="line" id="L698">        <span class="tok-kw">defer</span> comp.deinit();</span>
<span class="line" id="L699"></span>
<span class="line" id="L700">        <span class="tok-comment">// Reset until we are right before the wraparound.</span>
</span>
<span class="line" id="L701">        <span class="tok-comment">// Each reset adds max_match_offset to the offset.</span>
</span>
<span class="line" id="L702">        i = <span class="tok-number">0</span>;</span>
<span class="line" id="L703">        <span class="tok-kw">var</span> limit = (buffer_reset - input.len - o - max_match_offset) / max_match_offset;</span>
<span class="line" id="L704">        <span class="tok-kw">while</span> (i &lt; limit) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L705">            <span class="tok-comment">// skip ahead to where we are close to wrap around...</span>
</span>
<span class="line" id="L706">            comp.reset(discard.writer());</span>
<span class="line" id="L707">        }</span>
<span class="line" id="L708">        <span class="tok-kw">var</span> got = ArrayList(<span class="tok-type">u8</span>).init(testing.allocator);</span>
<span class="line" id="L709">        <span class="tok-kw">defer</span> got.deinit();</span>
<span class="line" id="L710">        comp.reset(got.writer());</span>
<span class="line" id="L711"></span>
<span class="line" id="L712">        <span class="tok-comment">// Write 3 times, close.</span>
</span>
<span class="line" id="L713">        <span class="tok-kw">try</span> comp.writer().writeAll(input);</span>
<span class="line" id="L714">        <span class="tok-kw">try</span> comp.writer().writeAll(input);</span>
<span class="line" id="L715">        <span class="tok-kw">try</span> comp.writer().writeAll(input);</span>
<span class="line" id="L716">        <span class="tok-kw">try</span> comp.close();</span>
<span class="line" id="L717"></span>
<span class="line" id="L718">        <span class="tok-comment">// output must match at wraparound</span>
</span>
<span class="line" id="L719">        <span class="tok-kw">try</span> expect(mem.eql(<span class="tok-type">u8</span>, got.items, want.items));</span>
<span class="line" id="L720">    }</span>
<span class="line" id="L721">}</span>
<span class="line" id="L722"></span>
</code></pre></body>
</html>