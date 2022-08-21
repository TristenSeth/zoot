<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">    <title>compress/deflate/dict_decoder.zig - source view</title>
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
<span class="line" id="L3"><span class="tok-kw">const</span> mem = std.mem;</span>
<span class="line" id="L4"></span>
<span class="line" id="L5"><span class="tok-kw">const</span> Allocator = std.mem.Allocator;</span>
<span class="line" id="L6"></span>
<span class="line" id="L7"><span class="tok-comment">// Implements the LZ77 sliding dictionary as used in decompression.</span>
</span>
<span class="line" id="L8"><span class="tok-comment">// LZ77 decompresses data through sequences of two forms of commands:</span>
</span>
<span class="line" id="L9"><span class="tok-comment">//</span>
</span>
<span class="line" id="L10"><span class="tok-comment">//  * Literal insertions: Runs of one or more symbols are inserted into the data</span>
</span>
<span class="line" id="L11"><span class="tok-comment">//  stream as is. This is accomplished through the writeByte method for a</span>
</span>
<span class="line" id="L12"><span class="tok-comment">//  single symbol, or combinations of writeSlice/writeMark for multiple symbols.</span>
</span>
<span class="line" id="L13"><span class="tok-comment">//  Any valid stream must start with a literal insertion if no preset dictionary</span>
</span>
<span class="line" id="L14"><span class="tok-comment">//  is used.</span>
</span>
<span class="line" id="L15"><span class="tok-comment">//</span>
</span>
<span class="line" id="L16"><span class="tok-comment">//  * Backward copies: Runs of one or more symbols are copied from previously</span>
</span>
<span class="line" id="L17"><span class="tok-comment">//  emitted data. Backward copies come as the tuple (dist, length) where dist</span>
</span>
<span class="line" id="L18"><span class="tok-comment">//  determines how far back in the stream to copy from and length determines how</span>
</span>
<span class="line" id="L19"><span class="tok-comment">//  many bytes to copy. Note that it is valid for the length to be greater than</span>
</span>
<span class="line" id="L20"><span class="tok-comment">//  the distance. Since LZ77 uses forward copies, that situation is used to</span>
</span>
<span class="line" id="L21"><span class="tok-comment">//  perform a form of run-length encoding on repeated runs of symbols.</span>
</span>
<span class="line" id="L22"><span class="tok-comment">//  The writeCopy and tryWriteCopy are used to implement this command.</span>
</span>
<span class="line" id="L23"><span class="tok-comment">//</span>
</span>
<span class="line" id="L24"><span class="tok-comment">// For performance reasons, this implementation performs little to no sanity</span>
</span>
<span class="line" id="L25"><span class="tok-comment">// checks about the arguments. As such, the invariants documented for each</span>
</span>
<span class="line" id="L26"><span class="tok-comment">// method call must be respected.</span>
</span>
<span class="line" id="L27"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> DictDecoder = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L28">    <span class="tok-kw">const</span> Self = <span class="tok-builtin">@This</span>();</span>
<span class="line" id="L29"></span>
<span class="line" id="L30">    allocator: Allocator = <span class="tok-null">undefined</span>,</span>
<span class="line" id="L31"></span>
<span class="line" id="L32">    hist: []<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>, <span class="tok-comment">// Sliding window history</span>
</span>
<span class="line" id="L33"></span>
<span class="line" id="L34">    <span class="tok-comment">// Invariant: 0 &lt;= rd_pos &lt;= wr_pos &lt;= hist.len</span>
</span>
<span class="line" id="L35">    wr_pos: <span class="tok-type">u32</span> = <span class="tok-number">0</span>, <span class="tok-comment">// Current output position in buffer</span>
</span>
<span class="line" id="L36">    rd_pos: <span class="tok-type">u32</span> = <span class="tok-number">0</span>, <span class="tok-comment">// Have emitted hist[0..rd_pos] already</span>
</span>
<span class="line" id="L37">    full: <span class="tok-type">bool</span> = <span class="tok-null">false</span>, <span class="tok-comment">// Has a full window length been written yet?</span>
</span>
<span class="line" id="L38"></span>
<span class="line" id="L39">    <span class="tok-comment">// init initializes DictDecoder to have a sliding window dictionary of the given</span>
</span>
<span class="line" id="L40">    <span class="tok-comment">// size. If a preset dict is provided, it will initialize the dictionary with</span>
</span>
<span class="line" id="L41">    <span class="tok-comment">// the contents of dict.</span>
</span>
<span class="line" id="L42">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">init</span>(self: *Self, allocator: Allocator, size: <span class="tok-type">u32</span>, dict: ?[]<span class="tok-kw">const</span> <span class="tok-type">u8</span>) !<span class="tok-type">void</span> {</span>
<span class="line" id="L43">        self.allocator = allocator;</span>
<span class="line" id="L44"></span>
<span class="line" id="L45">        self.hist = <span class="tok-kw">try</span> allocator.alloc(<span class="tok-type">u8</span>, size);</span>
<span class="line" id="L46"></span>
<span class="line" id="L47">        self.wr_pos = <span class="tok-number">0</span>;</span>
<span class="line" id="L48"></span>
<span class="line" id="L49">        <span class="tok-kw">if</span> (dict != <span class="tok-null">null</span>) {</span>
<span class="line" id="L50">            mem.copy(<span class="tok-type">u8</span>, self.hist, dict.?[dict.?.len -| self.hist.len..]);</span>
<span class="line" id="L51">            self.wr_pos = <span class="tok-builtin">@intCast</span>(<span class="tok-type">u32</span>, dict.?.len);</span>
<span class="line" id="L52">        }</span>
<span class="line" id="L53"></span>
<span class="line" id="L54">        <span class="tok-kw">if</span> (self.wr_pos == self.hist.len) {</span>
<span class="line" id="L55">            self.wr_pos = <span class="tok-number">0</span>;</span>
<span class="line" id="L56">            self.full = <span class="tok-null">true</span>;</span>
<span class="line" id="L57">        }</span>
<span class="line" id="L58">        self.rd_pos = self.wr_pos;</span>
<span class="line" id="L59">    }</span>
<span class="line" id="L60"></span>
<span class="line" id="L61">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">deinit</span>(self: *Self) <span class="tok-type">void</span> {</span>
<span class="line" id="L62">        self.allocator.free(self.hist);</span>
<span class="line" id="L63">    }</span>
<span class="line" id="L64"></span>
<span class="line" id="L65">    <span class="tok-comment">// Reports the total amount of historical data in the dictionary.</span>
</span>
<span class="line" id="L66">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">histSize</span>(self: *Self) <span class="tok-type">u32</span> {</span>
<span class="line" id="L67">        <span class="tok-kw">if</span> (self.full) {</span>
<span class="line" id="L68">            <span class="tok-kw">return</span> <span class="tok-builtin">@intCast</span>(<span class="tok-type">u32</span>, self.hist.len);</span>
<span class="line" id="L69">        }</span>
<span class="line" id="L70">        <span class="tok-kw">return</span> self.wr_pos;</span>
<span class="line" id="L71">    }</span>
<span class="line" id="L72"></span>
<span class="line" id="L73">    <span class="tok-comment">// Reports the number of bytes that can be flushed by readFlush.</span>
</span>
<span class="line" id="L74">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">availRead</span>(self: *Self) <span class="tok-type">u32</span> {</span>
<span class="line" id="L75">        <span class="tok-kw">return</span> self.wr_pos - self.rd_pos;</span>
<span class="line" id="L76">    }</span>
<span class="line" id="L77"></span>
<span class="line" id="L78">    <span class="tok-comment">// Reports the available amount of output buffer space.</span>
</span>
<span class="line" id="L79">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">availWrite</span>(self: *Self) <span class="tok-type">u32</span> {</span>
<span class="line" id="L80">        <span class="tok-kw">return</span> <span class="tok-builtin">@intCast</span>(<span class="tok-type">u32</span>, self.hist.len - self.wr_pos);</span>
<span class="line" id="L81">    }</span>
<span class="line" id="L82"></span>
<span class="line" id="L83">    <span class="tok-comment">// Returns a slice of the available buffer to write data to.</span>
</span>
<span class="line" id="L84">    <span class="tok-comment">//</span>
</span>
<span class="line" id="L85">    <span class="tok-comment">// This invariant will be kept: s.len &lt;= availWrite()</span>
</span>
<span class="line" id="L86">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">writeSlice</span>(self: *Self) []<span class="tok-type">u8</span> {</span>
<span class="line" id="L87">        <span class="tok-kw">return</span> self.hist[self.wr_pos..];</span>
<span class="line" id="L88">    }</span>
<span class="line" id="L89"></span>
<span class="line" id="L90">    <span class="tok-comment">// Advances the writer pointer by `count`.</span>
</span>
<span class="line" id="L91">    <span class="tok-comment">//</span>
</span>
<span class="line" id="L92">    <span class="tok-comment">// This invariant must be kept: 0 &lt;= count &lt;= availWrite()</span>
</span>
<span class="line" id="L93">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">writeMark</span>(self: *Self, count: <span class="tok-type">u32</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L94">        assert(<span class="tok-number">0</span> &lt;= count <span class="tok-kw">and</span> count &lt;= self.availWrite());</span>
<span class="line" id="L95">        self.wr_pos += count;</span>
<span class="line" id="L96">    }</span>
<span class="line" id="L97"></span>
<span class="line" id="L98">    <span class="tok-comment">// Writes a single byte to the dictionary.</span>
</span>
<span class="line" id="L99">    <span class="tok-comment">//</span>
</span>
<span class="line" id="L100">    <span class="tok-comment">// This invariant must be kept: 0 &lt; availWrite()</span>
</span>
<span class="line" id="L101">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">writeByte</span>(self: *Self, byte: <span class="tok-type">u8</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L102">        self.hist[self.wr_pos] = byte;</span>
<span class="line" id="L103">        self.wr_pos += <span class="tok-number">1</span>;</span>
<span class="line" id="L104">    }</span>
<span class="line" id="L105"></span>
<span class="line" id="L106">    <span class="tok-kw">fn</span> <span class="tok-fn">copy</span>(dst: []<span class="tok-type">u8</span>, src: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) <span class="tok-type">u32</span> {</span>
<span class="line" id="L107">        <span class="tok-kw">if</span> (src.len &gt; dst.len) {</span>
<span class="line" id="L108">            mem.copy(<span class="tok-type">u8</span>, dst, src[<span class="tok-number">0</span>..dst.len]);</span>
<span class="line" id="L109">            <span class="tok-kw">return</span> <span class="tok-builtin">@intCast</span>(<span class="tok-type">u32</span>, dst.len);</span>
<span class="line" id="L110">        }</span>
<span class="line" id="L111">        mem.copy(<span class="tok-type">u8</span>, dst, src);</span>
<span class="line" id="L112">        <span class="tok-kw">return</span> <span class="tok-builtin">@intCast</span>(<span class="tok-type">u32</span>, src.len);</span>
<span class="line" id="L113">    }</span>
<span class="line" id="L114"></span>
<span class="line" id="L115">    <span class="tok-comment">// Copies a string at a given (dist, length) to the output.</span>
</span>
<span class="line" id="L116">    <span class="tok-comment">// This returns the number of bytes copied and may be less than the requested</span>
</span>
<span class="line" id="L117">    <span class="tok-comment">// length if the available space in the output buffer is too small.</span>
</span>
<span class="line" id="L118">    <span class="tok-comment">//</span>
</span>
<span class="line" id="L119">    <span class="tok-comment">// This invariant must be kept: 0 &lt; dist &lt;= histSize()</span>
</span>
<span class="line" id="L120">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">writeCopy</span>(self: *Self, dist: <span class="tok-type">u32</span>, length: <span class="tok-type">u32</span>) <span class="tok-type">u32</span> {</span>
<span class="line" id="L121">        assert(<span class="tok-number">0</span> &lt; dist <span class="tok-kw">and</span> dist &lt;= self.histSize());</span>
<span class="line" id="L122">        <span class="tok-kw">var</span> dst_base = self.wr_pos;</span>
<span class="line" id="L123">        <span class="tok-kw">var</span> dst_pos = dst_base;</span>
<span class="line" id="L124">        <span class="tok-kw">var</span> src_pos: <span class="tok-type">i32</span> = <span class="tok-builtin">@intCast</span>(<span class="tok-type">i32</span>, dst_pos) - <span class="tok-builtin">@intCast</span>(<span class="tok-type">i32</span>, dist);</span>
<span class="line" id="L125">        <span class="tok-kw">var</span> end_pos = dst_pos + length;</span>
<span class="line" id="L126">        <span class="tok-kw">if</span> (end_pos &gt; self.hist.len) {</span>
<span class="line" id="L127">            end_pos = <span class="tok-builtin">@intCast</span>(<span class="tok-type">u32</span>, self.hist.len);</span>
<span class="line" id="L128">        }</span>
<span class="line" id="L129"></span>
<span class="line" id="L130">        <span class="tok-comment">// Copy non-overlapping section after destination position.</span>
</span>
<span class="line" id="L131">        <span class="tok-comment">//</span>
</span>
<span class="line" id="L132">        <span class="tok-comment">// This section is non-overlapping in that the copy length for this section</span>
</span>
<span class="line" id="L133">        <span class="tok-comment">// is always less than or equal to the backwards distance. This can occur</span>
</span>
<span class="line" id="L134">        <span class="tok-comment">// if a distance refers to data that wraps-around in the buffer.</span>
</span>
<span class="line" id="L135">        <span class="tok-comment">// Thus, a backwards copy is performed here; that is, the exact bytes in</span>
</span>
<span class="line" id="L136">        <span class="tok-comment">// the source prior to the copy is placed in the destination.</span>
</span>
<span class="line" id="L137">        <span class="tok-kw">if</span> (src_pos &lt; <span class="tok-number">0</span>) {</span>
<span class="line" id="L138">            src_pos += <span class="tok-builtin">@intCast</span>(<span class="tok-type">i32</span>, self.hist.len);</span>
<span class="line" id="L139">            dst_pos += copy(self.hist[dst_pos..end_pos], self.hist[<span class="tok-builtin">@intCast</span>(<span class="tok-type">usize</span>, src_pos)..]);</span>
<span class="line" id="L140">            src_pos = <span class="tok-number">0</span>;</span>
<span class="line" id="L141">        }</span>
<span class="line" id="L142"></span>
<span class="line" id="L143">        <span class="tok-comment">// Copy possibly overlapping section before destination position.</span>
</span>
<span class="line" id="L144">        <span class="tok-comment">//</span>
</span>
<span class="line" id="L145">        <span class="tok-comment">// This section can overlap if the copy length for this section is larger</span>
</span>
<span class="line" id="L146">        <span class="tok-comment">// than the backwards distance. This is allowed by LZ77 so that repeated</span>
</span>
<span class="line" id="L147">        <span class="tok-comment">// strings can be succinctly represented using (dist, length) pairs.</span>
</span>
<span class="line" id="L148">        <span class="tok-comment">// Thus, a forwards copy is performed here; that is, the bytes copied is</span>
</span>
<span class="line" id="L149">        <span class="tok-comment">// possibly dependent on the resulting bytes in the destination as the copy</span>
</span>
<span class="line" id="L150">        <span class="tok-comment">// progresses along. This is functionally equivalent to the following:</span>
</span>
<span class="line" id="L151">        <span class="tok-comment">//</span>
</span>
<span class="line" id="L152">        <span class="tok-comment">//    var i = 0;</span>
</span>
<span class="line" id="L153">        <span class="tok-comment">//    while(i &lt; end_pos - dst_pos) : (i+=1) {</span>
</span>
<span class="line" id="L154">        <span class="tok-comment">//        self.hist[dst_pos+i] = self.hist[src_pos+i];</span>
</span>
<span class="line" id="L155">        <span class="tok-comment">//    }</span>
</span>
<span class="line" id="L156">        <span class="tok-comment">//    dst_pos = end_pos;</span>
</span>
<span class="line" id="L157">        <span class="tok-comment">//</span>
</span>
<span class="line" id="L158">        <span class="tok-kw">while</span> (dst_pos &lt; end_pos) {</span>
<span class="line" id="L159">            dst_pos += copy(self.hist[dst_pos..end_pos], self.hist[<span class="tok-builtin">@intCast</span>(<span class="tok-type">usize</span>, src_pos)..dst_pos]);</span>
<span class="line" id="L160">        }</span>
<span class="line" id="L161"></span>
<span class="line" id="L162">        self.wr_pos = dst_pos;</span>
<span class="line" id="L163">        <span class="tok-kw">return</span> dst_pos - dst_base;</span>
<span class="line" id="L164">    }</span>
<span class="line" id="L165"></span>
<span class="line" id="L166">    <span class="tok-comment">// Tries to copy a string at a given (distance, length) to the</span>
</span>
<span class="line" id="L167">    <span class="tok-comment">// output. This specialized version is optimized for short distances.</span>
</span>
<span class="line" id="L168">    <span class="tok-comment">//</span>
</span>
<span class="line" id="L169">    <span class="tok-comment">// This method is designed to be inlined for performance reasons.</span>
</span>
<span class="line" id="L170">    <span class="tok-comment">//</span>
</span>
<span class="line" id="L171">    <span class="tok-comment">// This invariant must be kept: 0 &lt; dist &lt;= histSize()</span>
</span>
<span class="line" id="L172">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">tryWriteCopy</span>(self: *Self, dist: <span class="tok-type">u32</span>, length: <span class="tok-type">u32</span>) <span class="tok-type">u32</span> {</span>
<span class="line" id="L173">        <span class="tok-kw">var</span> dst_pos = self.wr_pos;</span>
<span class="line" id="L174">        <span class="tok-kw">var</span> end_pos = dst_pos + length;</span>
<span class="line" id="L175">        <span class="tok-kw">if</span> (dst_pos &lt; dist <span class="tok-kw">or</span> end_pos &gt; self.hist.len) {</span>
<span class="line" id="L176">            <span class="tok-kw">return</span> <span class="tok-number">0</span>;</span>
<span class="line" id="L177">        }</span>
<span class="line" id="L178">        <span class="tok-kw">var</span> dst_base = dst_pos;</span>
<span class="line" id="L179">        <span class="tok-kw">var</span> src_pos = dst_pos - dist;</span>
<span class="line" id="L180"></span>
<span class="line" id="L181">        <span class="tok-comment">// Copy possibly overlapping section before destination position.</span>
</span>
<span class="line" id="L182">        <span class="tok-kw">while</span> (dst_pos &lt; end_pos) {</span>
<span class="line" id="L183">            dst_pos += copy(self.hist[dst_pos..end_pos], self.hist[src_pos..dst_pos]);</span>
<span class="line" id="L184">        }</span>
<span class="line" id="L185"></span>
<span class="line" id="L186">        self.wr_pos = dst_pos;</span>
<span class="line" id="L187">        <span class="tok-kw">return</span> dst_pos - dst_base;</span>
<span class="line" id="L188">    }</span>
<span class="line" id="L189"></span>
<span class="line" id="L190">    <span class="tok-comment">// Returns a slice of the historical buffer that is ready to be</span>
</span>
<span class="line" id="L191">    <span class="tok-comment">// emitted to the user. The data returned by readFlush must be fully consumed</span>
</span>
<span class="line" id="L192">    <span class="tok-comment">// before calling any other DictDecoder methods.</span>
</span>
<span class="line" id="L193">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">readFlush</span>(self: *Self) []<span class="tok-type">u8</span> {</span>
<span class="line" id="L194">        <span class="tok-kw">var</span> to_read = self.hist[self.rd_pos..self.wr_pos];</span>
<span class="line" id="L195">        self.rd_pos = self.wr_pos;</span>
<span class="line" id="L196">        <span class="tok-kw">if</span> (self.wr_pos == self.hist.len) {</span>
<span class="line" id="L197">            self.wr_pos = <span class="tok-number">0</span>;</span>
<span class="line" id="L198">            self.rd_pos = <span class="tok-number">0</span>;</span>
<span class="line" id="L199">            self.full = <span class="tok-null">true</span>;</span>
<span class="line" id="L200">        }</span>
<span class="line" id="L201">        <span class="tok-kw">return</span> to_read;</span>
<span class="line" id="L202">    }</span>
<span class="line" id="L203">};</span>
<span class="line" id="L204"></span>
<span class="line" id="L205"><span class="tok-comment">// tests</span>
</span>
<span class="line" id="L206"></span>
<span class="line" id="L207"><span class="tok-kw">test</span> <span class="tok-str">&quot;dictionary decoder&quot;</span> {</span>
<span class="line" id="L208">    <span class="tok-kw">const</span> ArrayList = std.ArrayList;</span>
<span class="line" id="L209">    <span class="tok-kw">const</span> expect = std.testing.expect;</span>
<span class="line" id="L210">    <span class="tok-kw">const</span> testing = std.testing;</span>
<span class="line" id="L211"></span>
<span class="line" id="L212">    <span class="tok-kw">const</span> abc = <span class="tok-str">&quot;ABC\n&quot;</span>;</span>
<span class="line" id="L213">    <span class="tok-kw">const</span> fox = <span class="tok-str">&quot;The quick brown fox jumped over the lazy dog!\n&quot;</span>;</span>
<span class="line" id="L214">    <span class="tok-kw">const</span> poem: []<span class="tok-kw">const</span> <span class="tok-type">u8</span> =</span>
<span class="line" id="L215">        <span class="tok-str">\\The Road Not Taken</span></span>

<span class="line" id="L216">        <span class="tok-str">\\Robert Frost</span></span>

<span class="line" id="L217">        <span class="tok-str">\\</span></span>

<span class="line" id="L218">        <span class="tok-str">\\Two roads diverged in a yellow wood,</span></span>

<span class="line" id="L219">        <span class="tok-str">\\And sorry I could not travel both</span></span>

<span class="line" id="L220">        <span class="tok-str">\\And be one traveler, long I stood</span></span>

<span class="line" id="L221">        <span class="tok-str">\\And looked down one as far as I could</span></span>

<span class="line" id="L222">        <span class="tok-str">\\To where it bent in the undergrowth;</span></span>

<span class="line" id="L223">        <span class="tok-str">\\</span></span>

<span class="line" id="L224">        <span class="tok-str">\\Then took the other, as just as fair,</span></span>

<span class="line" id="L225">        <span class="tok-str">\\And having perhaps the better claim,</span></span>

<span class="line" id="L226">        <span class="tok-str">\\Because it was grassy and wanted wear;</span></span>

<span class="line" id="L227">        <span class="tok-str">\\Though as for that the passing there</span></span>

<span class="line" id="L228">        <span class="tok-str">\\Had worn them really about the same,</span></span>

<span class="line" id="L229">        <span class="tok-str">\\</span></span>

<span class="line" id="L230">        <span class="tok-str">\\And both that morning equally lay</span></span>

<span class="line" id="L231">        <span class="tok-str">\\In leaves no step had trodden black.</span></span>

<span class="line" id="L232">        <span class="tok-str">\\Oh, I kept the first for another day!</span></span>

<span class="line" id="L233">        <span class="tok-str">\\Yet knowing how way leads on to way,</span></span>

<span class="line" id="L234">        <span class="tok-str">\\I doubted if I should ever come back.</span></span>

<span class="line" id="L235">        <span class="tok-str">\\</span></span>

<span class="line" id="L236">        <span class="tok-str">\\I shall be telling this with a sigh</span></span>

<span class="line" id="L237">        <span class="tok-str">\\Somewhere ages and ages hence:</span></span>

<span class="line" id="L238">        <span class="tok-str">\\Two roads diverged in a wood, and I-</span></span>

<span class="line" id="L239">        <span class="tok-str">\\I took the one less traveled by,</span></span>

<span class="line" id="L240">        <span class="tok-str">\\And that has made all the difference.</span></span>

<span class="line" id="L241">        <span class="tok-str">\\</span></span>

<span class="line" id="L242">    ;</span>
<span class="line" id="L243"></span>
<span class="line" id="L244">    <span class="tok-kw">const</span> uppercase: []<span class="tok-kw">const</span> <span class="tok-type">u8</span> =</span>
<span class="line" id="L245">        <span class="tok-str">\\THE ROAD NOT TAKEN</span></span>

<span class="line" id="L246">        <span class="tok-str">\\ROBERT FROST</span></span>

<span class="line" id="L247">        <span class="tok-str">\\</span></span>

<span class="line" id="L248">        <span class="tok-str">\\TWO ROADS DIVERGED IN A YELLOW WOOD,</span></span>

<span class="line" id="L249">        <span class="tok-str">\\AND SORRY I COULD NOT TRAVEL BOTH</span></span>

<span class="line" id="L250">        <span class="tok-str">\\AND BE ONE TRAVELER, LONG I STOOD</span></span>

<span class="line" id="L251">        <span class="tok-str">\\AND LOOKED DOWN ONE AS FAR AS I COULD</span></span>

<span class="line" id="L252">        <span class="tok-str">\\TO WHERE IT BENT IN THE UNDERGROWTH;</span></span>

<span class="line" id="L253">        <span class="tok-str">\\</span></span>

<span class="line" id="L254">        <span class="tok-str">\\THEN TOOK THE OTHER, AS JUST AS FAIR,</span></span>

<span class="line" id="L255">        <span class="tok-str">\\AND HAVING PERHAPS THE BETTER CLAIM,</span></span>

<span class="line" id="L256">        <span class="tok-str">\\BECAUSE IT WAS GRASSY AND WANTED WEAR;</span></span>

<span class="line" id="L257">        <span class="tok-str">\\THOUGH AS FOR THAT THE PASSING THERE</span></span>

<span class="line" id="L258">        <span class="tok-str">\\HAD WORN THEM REALLY ABOUT THE SAME,</span></span>

<span class="line" id="L259">        <span class="tok-str">\\</span></span>

<span class="line" id="L260">        <span class="tok-str">\\AND BOTH THAT MORNING EQUALLY LAY</span></span>

<span class="line" id="L261">        <span class="tok-str">\\IN LEAVES NO STEP HAD TRODDEN BLACK.</span></span>

<span class="line" id="L262">        <span class="tok-str">\\OH, I KEPT THE FIRST FOR ANOTHER DAY!</span></span>

<span class="line" id="L263">        <span class="tok-str">\\YET KNOWING HOW WAY LEADS ON TO WAY,</span></span>

<span class="line" id="L264">        <span class="tok-str">\\I DOUBTED IF I SHOULD EVER COME BACK.</span></span>

<span class="line" id="L265">        <span class="tok-str">\\</span></span>

<span class="line" id="L266">        <span class="tok-str">\\I SHALL BE TELLING THIS WITH A SIGH</span></span>

<span class="line" id="L267">        <span class="tok-str">\\SOMEWHERE AGES AND AGES HENCE:</span></span>

<span class="line" id="L268">        <span class="tok-str">\\TWO ROADS DIVERGED IN A WOOD, AND I-</span></span>

<span class="line" id="L269">        <span class="tok-str">\\I TOOK THE ONE LESS TRAVELED BY,</span></span>

<span class="line" id="L270">        <span class="tok-str">\\AND THAT HAS MADE ALL THE DIFFERENCE.</span></span>

<span class="line" id="L271">        <span class="tok-str">\\</span></span>

<span class="line" id="L272">    ;</span>
<span class="line" id="L273"></span>
<span class="line" id="L274">    <span class="tok-kw">const</span> PoemRefs = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L275">        dist: <span class="tok-type">u32</span>, <span class="tok-comment">// Backward distance (0 if this is an insertion)</span>
</span>
<span class="line" id="L276">        length: <span class="tok-type">u32</span>, <span class="tok-comment">// Length of copy or insertion</span>
</span>
<span class="line" id="L277">    };</span>
<span class="line" id="L278"></span>
<span class="line" id="L279">    <span class="tok-kw">var</span> poem_refs = [_]PoemRefs{</span>
<span class="line" id="L280">        .{ .dist = <span class="tok-number">0</span>, .length = <span class="tok-number">38</span> },  .{ .dist = <span class="tok-number">33</span>, .length = <span class="tok-number">3</span> },   .{ .dist = <span class="tok-number">0</span>, .length = <span class="tok-number">48</span> },</span>
<span class="line" id="L281">        .{ .dist = <span class="tok-number">79</span>, .length = <span class="tok-number">3</span> },  .{ .dist = <span class="tok-number">0</span>, .length = <span class="tok-number">11</span> },   .{ .dist = <span class="tok-number">34</span>, .length = <span class="tok-number">5</span> },</span>
<span class="line" id="L282">        .{ .dist = <span class="tok-number">0</span>, .length = <span class="tok-number">6</span> },   .{ .dist = <span class="tok-number">23</span>, .length = <span class="tok-number">7</span> },   .{ .dist = <span class="tok-number">0</span>, .length = <span class="tok-number">8</span> },</span>
<span class="line" id="L283">        .{ .dist = <span class="tok-number">50</span>, .length = <span class="tok-number">3</span> },  .{ .dist = <span class="tok-number">0</span>, .length = <span class="tok-number">2</span> },    .{ .dist = <span class="tok-number">69</span>, .length = <span class="tok-number">3</span> },</span>
<span class="line" id="L284">        .{ .dist = <span class="tok-number">34</span>, .length = <span class="tok-number">5</span> },  .{ .dist = <span class="tok-number">0</span>, .length = <span class="tok-number">4</span> },    .{ .dist = <span class="tok-number">97</span>, .length = <span class="tok-number">3</span> },</span>
<span class="line" id="L285">        .{ .dist = <span class="tok-number">0</span>, .length = <span class="tok-number">4</span> },   .{ .dist = <span class="tok-number">43</span>, .length = <span class="tok-number">5</span> },   .{ .dist = <span class="tok-number">0</span>, .length = <span class="tok-number">6</span> },</span>
<span class="line" id="L286">        .{ .dist = <span class="tok-number">7</span>, .length = <span class="tok-number">4</span> },   .{ .dist = <span class="tok-number">88</span>, .length = <span class="tok-number">7</span> },   .{ .dist = <span class="tok-number">0</span>, .length = <span class="tok-number">12</span> },</span>
<span class="line" id="L287">        .{ .dist = <span class="tok-number">80</span>, .length = <span class="tok-number">3</span> },  .{ .dist = <span class="tok-number">0</span>, .length = <span class="tok-number">2</span> },    .{ .dist = <span class="tok-number">141</span>, .length = <span class="tok-number">4</span> },</span>
<span class="line" id="L288">        .{ .dist = <span class="tok-number">0</span>, .length = <span class="tok-number">1</span> },   .{ .dist = <span class="tok-number">196</span>, .length = <span class="tok-number">3</span> },  .{ .dist = <span class="tok-number">0</span>, .length = <span class="tok-number">3</span> },</span>
<span class="line" id="L289">        .{ .dist = <span class="tok-number">157</span>, .length = <span class="tok-number">3</span> }, .{ .dist = <span class="tok-number">0</span>, .length = <span class="tok-number">6</span> },    .{ .dist = <span class="tok-number">181</span>, .length = <span class="tok-number">3</span> },</span>
<span class="line" id="L290">        .{ .dist = <span class="tok-number">0</span>, .length = <span class="tok-number">2</span> },   .{ .dist = <span class="tok-number">23</span>, .length = <span class="tok-number">3</span> },   .{ .dist = <span class="tok-number">77</span>, .length = <span class="tok-number">3</span> },</span>
<span class="line" id="L291">        .{ .dist = <span class="tok-number">28</span>, .length = <span class="tok-number">5</span> },  .{ .dist = <span class="tok-number">128</span>, .length = <span class="tok-number">3</span> },  .{ .dist = <span class="tok-number">110</span>, .length = <span class="tok-number">4</span> },</span>
<span class="line" id="L292">        .{ .dist = <span class="tok-number">70</span>, .length = <span class="tok-number">3</span> },  .{ .dist = <span class="tok-number">0</span>, .length = <span class="tok-number">4</span> },    .{ .dist = <span class="tok-number">85</span>, .length = <span class="tok-number">6</span> },</span>
<span class="line" id="L293">        .{ .dist = <span class="tok-number">0</span>, .length = <span class="tok-number">2</span> },   .{ .dist = <span class="tok-number">182</span>, .length = <span class="tok-number">6</span> },  .{ .dist = <span class="tok-number">0</span>, .length = <span class="tok-number">4</span> },</span>
<span class="line" id="L294">        .{ .dist = <span class="tok-number">133</span>, .length = <span class="tok-number">3</span> }, .{ .dist = <span class="tok-number">0</span>, .length = <span class="tok-number">7</span> },    .{ .dist = <span class="tok-number">47</span>, .length = <span class="tok-number">5</span> },</span>
<span class="line" id="L295">        .{ .dist = <span class="tok-number">0</span>, .length = <span class="tok-number">20</span> },  .{ .dist = <span class="tok-number">112</span>, .length = <span class="tok-number">5</span> },  .{ .dist = <span class="tok-number">0</span>, .length = <span class="tok-number">1</span> },</span>
<span class="line" id="L296">        .{ .dist = <span class="tok-number">58</span>, .length = <span class="tok-number">3</span> },  .{ .dist = <span class="tok-number">0</span>, .length = <span class="tok-number">8</span> },    .{ .dist = <span class="tok-number">59</span>, .length = <span class="tok-number">3</span> },</span>
<span class="line" id="L297">        .{ .dist = <span class="tok-number">0</span>, .length = <span class="tok-number">4</span> },   .{ .dist = <span class="tok-number">173</span>, .length = <span class="tok-number">3</span> },  .{ .dist = <span class="tok-number">0</span>, .length = <span class="tok-number">5</span> },</span>
<span class="line" id="L298">        .{ .dist = <span class="tok-number">114</span>, .length = <span class="tok-number">3</span> }, .{ .dist = <span class="tok-number">0</span>, .length = <span class="tok-number">4</span> },    .{ .dist = <span class="tok-number">92</span>, .length = <span class="tok-number">5</span> },</span>
<span class="line" id="L299">        .{ .dist = <span class="tok-number">0</span>, .length = <span class="tok-number">2</span> },   .{ .dist = <span class="tok-number">71</span>, .length = <span class="tok-number">3</span> },   .{ .dist = <span class="tok-number">0</span>, .length = <span class="tok-number">2</span> },</span>
<span class="line" id="L300">        .{ .dist = <span class="tok-number">76</span>, .length = <span class="tok-number">5</span> },  .{ .dist = <span class="tok-number">0</span>, .length = <span class="tok-number">1</span> },    .{ .dist = <span class="tok-number">46</span>, .length = <span class="tok-number">3</span> },</span>
<span class="line" id="L301">        .{ .dist = <span class="tok-number">96</span>, .length = <span class="tok-number">4</span> },  .{ .dist = <span class="tok-number">130</span>, .length = <span class="tok-number">4</span> },  .{ .dist = <span class="tok-number">0</span>, .length = <span class="tok-number">3</span> },</span>
<span class="line" id="L302">        .{ .dist = <span class="tok-number">360</span>, .length = <span class="tok-number">3</span> }, .{ .dist = <span class="tok-number">0</span>, .length = <span class="tok-number">3</span> },    .{ .dist = <span class="tok-number">178</span>, .length = <span class="tok-number">5</span> },</span>
<span class="line" id="L303">        .{ .dist = <span class="tok-number">0</span>, .length = <span class="tok-number">7</span> },   .{ .dist = <span class="tok-number">75</span>, .length = <span class="tok-number">3</span> },   .{ .dist = <span class="tok-number">0</span>, .length = <span class="tok-number">3</span> },</span>
<span class="line" id="L304">        .{ .dist = <span class="tok-number">45</span>, .length = <span class="tok-number">6</span> },  .{ .dist = <span class="tok-number">0</span>, .length = <span class="tok-number">6</span> },    .{ .dist = <span class="tok-number">299</span>, .length = <span class="tok-number">6</span> },</span>
<span class="line" id="L305">        .{ .dist = <span class="tok-number">180</span>, .length = <span class="tok-number">3</span> }, .{ .dist = <span class="tok-number">70</span>, .length = <span class="tok-number">6</span> },   .{ .dist = <span class="tok-number">0</span>, .length = <span class="tok-number">1</span> },</span>
<span class="line" id="L306">        .{ .dist = <span class="tok-number">48</span>, .length = <span class="tok-number">3</span> },  .{ .dist = <span class="tok-number">66</span>, .length = <span class="tok-number">4</span> },   .{ .dist = <span class="tok-number">0</span>, .length = <span class="tok-number">3</span> },</span>
<span class="line" id="L307">        .{ .dist = <span class="tok-number">47</span>, .length = <span class="tok-number">5</span> },  .{ .dist = <span class="tok-number">0</span>, .length = <span class="tok-number">9</span> },    .{ .dist = <span class="tok-number">325</span>, .length = <span class="tok-number">3</span> },</span>
<span class="line" id="L308">        .{ .dist = <span class="tok-number">0</span>, .length = <span class="tok-number">1</span> },   .{ .dist = <span class="tok-number">359</span>, .length = <span class="tok-number">3</span> },  .{ .dist = <span class="tok-number">318</span>, .length = <span class="tok-number">3</span> },</span>
<span class="line" id="L309">        .{ .dist = <span class="tok-number">0</span>, .length = <span class="tok-number">2</span> },   .{ .dist = <span class="tok-number">199</span>, .length = <span class="tok-number">3</span> },  .{ .dist = <span class="tok-number">0</span>, .length = <span class="tok-number">1</span> },</span>
<span class="line" id="L310">        .{ .dist = <span class="tok-number">344</span>, .length = <span class="tok-number">3</span> }, .{ .dist = <span class="tok-number">0</span>, .length = <span class="tok-number">3</span> },    .{ .dist = <span class="tok-number">248</span>, .length = <span class="tok-number">3</span> },</span>
<span class="line" id="L311">        .{ .dist = <span class="tok-number">0</span>, .length = <span class="tok-number">10</span> },  .{ .dist = <span class="tok-number">310</span>, .length = <span class="tok-number">3</span> },  .{ .dist = <span class="tok-number">0</span>, .length = <span class="tok-number">3</span> },</span>
<span class="line" id="L312">        .{ .dist = <span class="tok-number">93</span>, .length = <span class="tok-number">6</span> },  .{ .dist = <span class="tok-number">0</span>, .length = <span class="tok-number">3</span> },    .{ .dist = <span class="tok-number">252</span>, .length = <span class="tok-number">3</span> },</span>
<span class="line" id="L313">        .{ .dist = <span class="tok-number">157</span>, .length = <span class="tok-number">4</span> }, .{ .dist = <span class="tok-number">0</span>, .length = <span class="tok-number">2</span> },    .{ .dist = <span class="tok-number">273</span>, .length = <span class="tok-number">5</span> },</span>
<span class="line" id="L314">        .{ .dist = <span class="tok-number">0</span>, .length = <span class="tok-number">14</span> },  .{ .dist = <span class="tok-number">99</span>, .length = <span class="tok-number">4</span> },   .{ .dist = <span class="tok-number">0</span>, .length = <span class="tok-number">1</span> },</span>
<span class="line" id="L315">        .{ .dist = <span class="tok-number">464</span>, .length = <span class="tok-number">4</span> }, .{ .dist = <span class="tok-number">0</span>, .length = <span class="tok-number">2</span> },    .{ .dist = <span class="tok-number">92</span>, .length = <span class="tok-number">4</span> },</span>
<span class="line" id="L316">        .{ .dist = <span class="tok-number">495</span>, .length = <span class="tok-number">3</span> }, .{ .dist = <span class="tok-number">0</span>, .length = <span class="tok-number">1</span> },    .{ .dist = <span class="tok-number">322</span>, .length = <span class="tok-number">4</span> },</span>
<span class="line" id="L317">        .{ .dist = <span class="tok-number">16</span>, .length = <span class="tok-number">4</span> },  .{ .dist = <span class="tok-number">0</span>, .length = <span class="tok-number">3</span> },    .{ .dist = <span class="tok-number">402</span>, .length = <span class="tok-number">3</span> },</span>
<span class="line" id="L318">        .{ .dist = <span class="tok-number">0</span>, .length = <span class="tok-number">2</span> },   .{ .dist = <span class="tok-number">237</span>, .length = <span class="tok-number">4</span> },  .{ .dist = <span class="tok-number">0</span>, .length = <span class="tok-number">2</span> },</span>
<span class="line" id="L319">        .{ .dist = <span class="tok-number">432</span>, .length = <span class="tok-number">4</span> }, .{ .dist = <span class="tok-number">0</span>, .length = <span class="tok-number">1</span> },    .{ .dist = <span class="tok-number">483</span>, .length = <span class="tok-number">5</span> },</span>
<span class="line" id="L320">        .{ .dist = <span class="tok-number">0</span>, .length = <span class="tok-number">2</span> },   .{ .dist = <span class="tok-number">294</span>, .length = <span class="tok-number">4</span> },  .{ .dist = <span class="tok-number">0</span>, .length = <span class="tok-number">2</span> },</span>
<span class="line" id="L321">        .{ .dist = <span class="tok-number">306</span>, .length = <span class="tok-number">3</span> }, .{ .dist = <span class="tok-number">113</span>, .length = <span class="tok-number">5</span> },  .{ .dist = <span class="tok-number">0</span>, .length = <span class="tok-number">1</span> },</span>
<span class="line" id="L322">        .{ .dist = <span class="tok-number">26</span>, .length = <span class="tok-number">4</span> },  .{ .dist = <span class="tok-number">164</span>, .length = <span class="tok-number">3</span> },  .{ .dist = <span class="tok-number">488</span>, .length = <span class="tok-number">4</span> },</span>
<span class="line" id="L323">        .{ .dist = <span class="tok-number">0</span>, .length = <span class="tok-number">1</span> },   .{ .dist = <span class="tok-number">542</span>, .length = <span class="tok-number">3</span> },  .{ .dist = <span class="tok-number">248</span>, .length = <span class="tok-number">6</span> },</span>
<span class="line" id="L324">        .{ .dist = <span class="tok-number">0</span>, .length = <span class="tok-number">5</span> },   .{ .dist = <span class="tok-number">205</span>, .length = <span class="tok-number">3</span> },  .{ .dist = <span class="tok-number">0</span>, .length = <span class="tok-number">8</span> },</span>
<span class="line" id="L325">        .{ .dist = <span class="tok-number">48</span>, .length = <span class="tok-number">3</span> },  .{ .dist = <span class="tok-number">449</span>, .length = <span class="tok-number">6</span> },  .{ .dist = <span class="tok-number">0</span>, .length = <span class="tok-number">2</span> },</span>
<span class="line" id="L326">        .{ .dist = <span class="tok-number">192</span>, .length = <span class="tok-number">3</span> }, .{ .dist = <span class="tok-number">328</span>, .length = <span class="tok-number">4</span> },  .{ .dist = <span class="tok-number">9</span>, .length = <span class="tok-number">5</span> },</span>
<span class="line" id="L327">        .{ .dist = <span class="tok-number">433</span>, .length = <span class="tok-number">3</span> }, .{ .dist = <span class="tok-number">0</span>, .length = <span class="tok-number">3</span> },    .{ .dist = <span class="tok-number">622</span>, .length = <span class="tok-number">25</span> },</span>
<span class="line" id="L328">        .{ .dist = <span class="tok-number">615</span>, .length = <span class="tok-number">5</span> }, .{ .dist = <span class="tok-number">46</span>, .length = <span class="tok-number">5</span> },   .{ .dist = <span class="tok-number">0</span>, .length = <span class="tok-number">2</span> },</span>
<span class="line" id="L329">        .{ .dist = <span class="tok-number">104</span>, .length = <span class="tok-number">3</span> }, .{ .dist = <span class="tok-number">475</span>, .length = <span class="tok-number">10</span> }, .{ .dist = <span class="tok-number">549</span>, .length = <span class="tok-number">3</span> },</span>
<span class="line" id="L330">        .{ .dist = <span class="tok-number">0</span>, .length = <span class="tok-number">4</span> },   .{ .dist = <span class="tok-number">597</span>, .length = <span class="tok-number">8</span> },  .{ .dist = <span class="tok-number">314</span>, .length = <span class="tok-number">3</span> },</span>
<span class="line" id="L331">        .{ .dist = <span class="tok-number">0</span>, .length = <span class="tok-number">1</span> },   .{ .dist = <span class="tok-number">473</span>, .length = <span class="tok-number">6</span> },  .{ .dist = <span class="tok-number">317</span>, .length = <span class="tok-number">5</span> },</span>
<span class="line" id="L332">        .{ .dist = <span class="tok-number">0</span>, .length = <span class="tok-number">1</span> },   .{ .dist = <span class="tok-number">400</span>, .length = <span class="tok-number">3</span> },  .{ .dist = <span class="tok-number">0</span>, .length = <span class="tok-number">3</span> },</span>
<span class="line" id="L333">        .{ .dist = <span class="tok-number">109</span>, .length = <span class="tok-number">3</span> }, .{ .dist = <span class="tok-number">151</span>, .length = <span class="tok-number">3</span> },  .{ .dist = <span class="tok-number">48</span>, .length = <span class="tok-number">4</span> },</span>
<span class="line" id="L334">        .{ .dist = <span class="tok-number">0</span>, .length = <span class="tok-number">4</span> },   .{ .dist = <span class="tok-number">125</span>, .length = <span class="tok-number">3</span> },  .{ .dist = <span class="tok-number">108</span>, .length = <span class="tok-number">3</span> },</span>
<span class="line" id="L335">        .{ .dist = <span class="tok-number">0</span>, .length = <span class="tok-number">2</span> },</span>
<span class="line" id="L336">    };</span>
<span class="line" id="L337"></span>
<span class="line" id="L338">    <span class="tok-kw">var</span> got_list = ArrayList(<span class="tok-type">u8</span>).init(testing.allocator);</span>
<span class="line" id="L339">    <span class="tok-kw">defer</span> got_list.deinit();</span>
<span class="line" id="L340">    <span class="tok-kw">var</span> got = got_list.writer();</span>
<span class="line" id="L341"></span>
<span class="line" id="L342">    <span class="tok-kw">var</span> want_list = ArrayList(<span class="tok-type">u8</span>).init(testing.allocator);</span>
<span class="line" id="L343">    <span class="tok-kw">defer</span> want_list.deinit();</span>
<span class="line" id="L344">    <span class="tok-kw">var</span> want = want_list.writer();</span>
<span class="line" id="L345"></span>
<span class="line" id="L346">    <span class="tok-kw">var</span> dd = DictDecoder{};</span>
<span class="line" id="L347">    <span class="tok-kw">try</span> dd.init(testing.allocator, <span class="tok-number">1</span> &lt;&lt; <span class="tok-number">11</span>, <span class="tok-null">null</span>);</span>
<span class="line" id="L348">    <span class="tok-kw">defer</span> dd.deinit();</span>
<span class="line" id="L349"></span>
<span class="line" id="L350">    <span class="tok-kw">const</span> util = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L351">        <span class="tok-kw">fn</span> <span class="tok-fn">writeCopy</span>(dst_dd: *DictDecoder, dst: <span class="tok-kw">anytype</span>, dist: <span class="tok-type">u32</span>, length: <span class="tok-type">u32</span>) !<span class="tok-type">void</span> {</span>
<span class="line" id="L352">            <span class="tok-kw">var</span> len = length;</span>
<span class="line" id="L353">            <span class="tok-kw">while</span> (len &gt; <span class="tok-number">0</span>) {</span>
<span class="line" id="L354">                <span class="tok-kw">var</span> n = dst_dd.tryWriteCopy(dist, len);</span>
<span class="line" id="L355">                <span class="tok-kw">if</span> (n == <span class="tok-number">0</span>) {</span>
<span class="line" id="L356">                    n = dst_dd.writeCopy(dist, len);</span>
<span class="line" id="L357">                }</span>
<span class="line" id="L358"></span>
<span class="line" id="L359">                len -= n;</span>
<span class="line" id="L360">                <span class="tok-kw">if</span> (dst_dd.availWrite() == <span class="tok-number">0</span>) {</span>
<span class="line" id="L361">                    _ = <span class="tok-kw">try</span> dst.write(dst_dd.readFlush());</span>
<span class="line" id="L362">                }</span>
<span class="line" id="L363">            }</span>
<span class="line" id="L364">        }</span>
<span class="line" id="L365">        <span class="tok-kw">fn</span> <span class="tok-fn">writeString</span>(dst_dd: *DictDecoder, dst: <span class="tok-kw">anytype</span>, str: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) !<span class="tok-type">void</span> {</span>
<span class="line" id="L366">            <span class="tok-kw">var</span> string = str;</span>
<span class="line" id="L367">            <span class="tok-kw">while</span> (string.len &gt; <span class="tok-number">0</span>) {</span>
<span class="line" id="L368">                <span class="tok-kw">var</span> cnt = DictDecoder.copy(dst_dd.writeSlice(), string);</span>
<span class="line" id="L369">                dst_dd.writeMark(cnt);</span>
<span class="line" id="L370">                string = string[cnt..];</span>
<span class="line" id="L371">                <span class="tok-kw">if</span> (dst_dd.availWrite() == <span class="tok-number">0</span>) {</span>
<span class="line" id="L372">                    _ = <span class="tok-kw">try</span> dst.write(dst_dd.readFlush());</span>
<span class="line" id="L373">                }</span>
<span class="line" id="L374">            }</span>
<span class="line" id="L375">        }</span>
<span class="line" id="L376">    };</span>
<span class="line" id="L377"></span>
<span class="line" id="L378">    <span class="tok-kw">try</span> util.writeString(&amp;dd, got, <span class="tok-str">&quot;.&quot;</span>);</span>
<span class="line" id="L379">    _ = <span class="tok-kw">try</span> want.write(<span class="tok-str">&quot;.&quot;</span>);</span>
<span class="line" id="L380"></span>
<span class="line" id="L381">    <span class="tok-kw">var</span> str = poem;</span>
<span class="line" id="L382">    <span class="tok-kw">for</span> (poem_refs) |ref, i| {</span>
<span class="line" id="L383">        _ = i;</span>
<span class="line" id="L384">        <span class="tok-kw">if</span> (ref.dist == <span class="tok-number">0</span>) {</span>
<span class="line" id="L385">            <span class="tok-kw">try</span> util.writeString(&amp;dd, got, str[<span class="tok-number">0</span>..ref.length]);</span>
<span class="line" id="L386">        } <span class="tok-kw">else</span> {</span>
<span class="line" id="L387">            <span class="tok-kw">try</span> util.writeCopy(&amp;dd, got, ref.dist, ref.length);</span>
<span class="line" id="L388">        }</span>
<span class="line" id="L389">        str = str[ref.length..];</span>
<span class="line" id="L390">    }</span>
<span class="line" id="L391">    _ = <span class="tok-kw">try</span> want.write(poem);</span>
<span class="line" id="L392"></span>
<span class="line" id="L393">    <span class="tok-kw">try</span> util.writeCopy(&amp;dd, got, dd.histSize(), <span class="tok-number">33</span>);</span>
<span class="line" id="L394">    _ = <span class="tok-kw">try</span> want.write(want_list.items[<span class="tok-number">0</span>..<span class="tok-number">33</span>]);</span>
<span class="line" id="L395"></span>
<span class="line" id="L396">    <span class="tok-kw">try</span> util.writeString(&amp;dd, got, abc);</span>
<span class="line" id="L397">    <span class="tok-kw">try</span> util.writeCopy(&amp;dd, got, abc.len, <span class="tok-number">59</span> * abc.len);</span>
<span class="line" id="L398">    _ = <span class="tok-kw">try</span> want.write(abc ** <span class="tok-number">60</span>);</span>
<span class="line" id="L399"></span>
<span class="line" id="L400">    <span class="tok-kw">try</span> util.writeString(&amp;dd, got, fox);</span>
<span class="line" id="L401">    <span class="tok-kw">try</span> util.writeCopy(&amp;dd, got, fox.len, <span class="tok-number">9</span> * fox.len);</span>
<span class="line" id="L402">    _ = <span class="tok-kw">try</span> want.write(fox ** <span class="tok-number">10</span>);</span>
<span class="line" id="L403"></span>
<span class="line" id="L404">    <span class="tok-kw">try</span> util.writeString(&amp;dd, got, <span class="tok-str">&quot;.&quot;</span>);</span>
<span class="line" id="L405">    <span class="tok-kw">try</span> util.writeCopy(&amp;dd, got, <span class="tok-number">1</span>, <span class="tok-number">9</span>);</span>
<span class="line" id="L406">    _ = <span class="tok-kw">try</span> want.write(<span class="tok-str">&quot;.&quot;</span> ** <span class="tok-number">10</span>);</span>
<span class="line" id="L407"></span>
<span class="line" id="L408">    <span class="tok-kw">try</span> util.writeString(&amp;dd, got, uppercase);</span>
<span class="line" id="L409">    <span class="tok-kw">try</span> util.writeCopy(&amp;dd, got, uppercase.len, <span class="tok-number">7</span> * uppercase.len);</span>
<span class="line" id="L410">    <span class="tok-kw">var</span> i: <span class="tok-type">u8</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L411">    <span class="tok-kw">while</span> (i &lt; <span class="tok-number">8</span>) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L412">        _ = <span class="tok-kw">try</span> want.write(uppercase);</span>
<span class="line" id="L413">    }</span>
<span class="line" id="L414"></span>
<span class="line" id="L415">    <span class="tok-kw">try</span> util.writeCopy(&amp;dd, got, dd.histSize(), <span class="tok-number">10</span>);</span>
<span class="line" id="L416">    _ = <span class="tok-kw">try</span> want.write(want_list.items[want_list.items.len - dd.histSize() ..][<span class="tok-number">0</span>..<span class="tok-number">10</span>]);</span>
<span class="line" id="L417"></span>
<span class="line" id="L418">    _ = <span class="tok-kw">try</span> got.write(dd.readFlush());</span>
<span class="line" id="L419">    <span class="tok-kw">try</span> expect(mem.eql(<span class="tok-type">u8</span>, got_list.items, want_list.items));</span>
<span class="line" id="L420">}</span>
<span class="line" id="L421"></span>
</code></pre></body>
</html>