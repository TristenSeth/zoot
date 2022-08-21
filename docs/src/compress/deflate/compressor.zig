<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">    <title>compress/deflate/compressor.zig - source view</title>
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
<span class="line" id="L3"><span class="tok-kw">const</span> fmt = std.fmt;</span>
<span class="line" id="L4"><span class="tok-kw">const</span> io = std.io;</span>
<span class="line" id="L5"><span class="tok-kw">const</span> math = std.math;</span>
<span class="line" id="L6"><span class="tok-kw">const</span> mem = std.mem;</span>
<span class="line" id="L7"></span>
<span class="line" id="L8"><span class="tok-kw">const</span> Allocator = std.mem.Allocator;</span>
<span class="line" id="L9"></span>
<span class="line" id="L10"><span class="tok-kw">const</span> deflate_const = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;deflate_const.zig&quot;</span>);</span>
<span class="line" id="L11"><span class="tok-kw">const</span> fast = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;deflate_fast.zig&quot;</span>);</span>
<span class="line" id="L12"><span class="tok-kw">const</span> hm_bw = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;huffman_bit_writer.zig&quot;</span>);</span>
<span class="line" id="L13"><span class="tok-kw">const</span> mu = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;mem_utils.zig&quot;</span>);</span>
<span class="line" id="L14"><span class="tok-kw">const</span> token = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;token.zig&quot;</span>);</span>
<span class="line" id="L15"></span>
<span class="line" id="L16"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> Compression = <span class="tok-kw">enum</span>(<span class="tok-type">i5</span>) {</span>
<span class="line" id="L17">    <span class="tok-comment">/// huffman_only disables Lempel-Ziv match searching and only performs Huffman</span></span>
<span class="line" id="L18">    <span class="tok-comment">/// entropy encoding. This mode is useful in compressing data that has</span></span>
<span class="line" id="L19">    <span class="tok-comment">/// already been compressed with an LZ style algorithm (e.g. Snappy or LZ4)</span></span>
<span class="line" id="L20">    <span class="tok-comment">/// that lacks an entropy encoder. Compression gains are achieved when</span></span>
<span class="line" id="L21">    <span class="tok-comment">/// certain bytes in the input stream occur more frequently than others.</span></span>
<span class="line" id="L22">    <span class="tok-comment">///</span></span>
<span class="line" id="L23">    <span class="tok-comment">/// Note that huffman_only produces a compressed output that is</span></span>
<span class="line" id="L24">    <span class="tok-comment">/// RFC 1951 compliant. That is, any valid DEFLATE decompressor will</span></span>
<span class="line" id="L25">    <span class="tok-comment">/// continue to be able to decompress this output.</span></span>
<span class="line" id="L26">    huffman_only = -<span class="tok-number">2</span>,</span>
<span class="line" id="L27">    <span class="tok-comment">/// Same as level_6</span></span>
<span class="line" id="L28">    default_compression = -<span class="tok-number">1</span>,</span>
<span class="line" id="L29">    <span class="tok-comment">/// Does not attempt any compression; only adds the necessary DEFLATE framing.</span></span>
<span class="line" id="L30">    no_compression = <span class="tok-number">0</span>,</span>
<span class="line" id="L31">    <span class="tok-comment">/// Prioritizes speed over output size, based on Snappy's LZ77-style encoder</span></span>
<span class="line" id="L32">    best_speed = <span class="tok-number">1</span>,</span>
<span class="line" id="L33">    level_2 = <span class="tok-number">2</span>,</span>
<span class="line" id="L34">    level_3 = <span class="tok-number">3</span>,</span>
<span class="line" id="L35">    level_4 = <span class="tok-number">4</span>,</span>
<span class="line" id="L36">    level_5 = <span class="tok-number">5</span>,</span>
<span class="line" id="L37">    level_6 = <span class="tok-number">6</span>,</span>
<span class="line" id="L38">    level_7 = <span class="tok-number">7</span>,</span>
<span class="line" id="L39">    level_8 = <span class="tok-number">8</span>,</span>
<span class="line" id="L40">    <span class="tok-comment">/// Prioritizes smaller output size over speed</span></span>
<span class="line" id="L41">    best_compression = <span class="tok-number">9</span>,</span>
<span class="line" id="L42">};</span>
<span class="line" id="L43"></span>
<span class="line" id="L44"><span class="tok-kw">const</span> log_window_size = <span class="tok-number">15</span>;</span>
<span class="line" id="L45"><span class="tok-kw">const</span> window_size = <span class="tok-number">1</span> &lt;&lt; log_window_size;</span>
<span class="line" id="L46"><span class="tok-kw">const</span> window_mask = window_size - <span class="tok-number">1</span>;</span>
<span class="line" id="L47"></span>
<span class="line" id="L48"><span class="tok-comment">// The LZ77 step produces a sequence of literal tokens and &lt;length, offset&gt;</span>
</span>
<span class="line" id="L49"><span class="tok-comment">// pair tokens. The offset is also known as distance. The underlying wire</span>
</span>
<span class="line" id="L50"><span class="tok-comment">// format limits the range of lengths and offsets. For example, there are</span>
</span>
<span class="line" id="L51"><span class="tok-comment">// 256 legitimate lengths: those in the range [3, 258]. This package's</span>
</span>
<span class="line" id="L52"><span class="tok-comment">// compressor uses a higher minimum match length, enabling optimizations</span>
</span>
<span class="line" id="L53"><span class="tok-comment">// such as finding matches via 32-bit loads and compares.</span>
</span>
<span class="line" id="L54"><span class="tok-kw">const</span> base_match_length = deflate_const.base_match_length; <span class="tok-comment">// The smallest match length per the RFC section 3.2.5</span>
</span>
<span class="line" id="L55"><span class="tok-kw">const</span> min_match_length = <span class="tok-number">4</span>; <span class="tok-comment">// The smallest match length that the compressor actually emits</span>
</span>
<span class="line" id="L56"><span class="tok-kw">const</span> max_match_length = deflate_const.max_match_length;</span>
<span class="line" id="L57"><span class="tok-kw">const</span> base_match_offset = deflate_const.base_match_offset; <span class="tok-comment">// The smallest match offset</span>
</span>
<span class="line" id="L58"><span class="tok-kw">const</span> max_match_offset = deflate_const.max_match_offset; <span class="tok-comment">// The largest match offset</span>
</span>
<span class="line" id="L59"></span>
<span class="line" id="L60"><span class="tok-comment">// The maximum number of tokens we put into a single flate block, just to</span>
</span>
<span class="line" id="L61"><span class="tok-comment">// stop things from getting too large.</span>
</span>
<span class="line" id="L62"><span class="tok-kw">const</span> max_flate_block_tokens = <span class="tok-number">1</span> &lt;&lt; <span class="tok-number">14</span>;</span>
<span class="line" id="L63"><span class="tok-kw">const</span> max_store_block_size = deflate_const.max_store_block_size;</span>
<span class="line" id="L64"><span class="tok-kw">const</span> hash_bits = <span class="tok-number">17</span>; <span class="tok-comment">// After 17 performance degrades</span>
</span>
<span class="line" id="L65"><span class="tok-kw">const</span> hash_size = <span class="tok-number">1</span> &lt;&lt; hash_bits;</span>
<span class="line" id="L66"><span class="tok-kw">const</span> hash_mask = (<span class="tok-number">1</span> &lt;&lt; hash_bits) - <span class="tok-number">1</span>;</span>
<span class="line" id="L67"><span class="tok-kw">const</span> max_hash_offset = <span class="tok-number">1</span> &lt;&lt; <span class="tok-number">24</span>;</span>
<span class="line" id="L68"></span>
<span class="line" id="L69"><span class="tok-kw">const</span> skip_never = math.maxInt(<span class="tok-type">u32</span>);</span>
<span class="line" id="L70"></span>
<span class="line" id="L71"><span class="tok-kw">const</span> CompressionLevel = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L72">    good: <span class="tok-type">u16</span>,</span>
<span class="line" id="L73">    lazy: <span class="tok-type">u16</span>,</span>
<span class="line" id="L74">    nice: <span class="tok-type">u16</span>,</span>
<span class="line" id="L75">    chain: <span class="tok-type">u16</span>,</span>
<span class="line" id="L76">    fast_skip_hashshing: <span class="tok-type">u32</span>,</span>
<span class="line" id="L77">};</span>
<span class="line" id="L78"></span>
<span class="line" id="L79"><span class="tok-kw">fn</span> <span class="tok-fn">levels</span>(compression: Compression) CompressionLevel {</span>
<span class="line" id="L80">    <span class="tok-kw">switch</span> (compression) {</span>
<span class="line" id="L81">        .no_compression,</span>
<span class="line" id="L82">        .best_speed, <span class="tok-comment">// best_speed uses a custom algorithm; see deflate_fast.zig</span>
</span>
<span class="line" id="L83">        .huffman_only,</span>
<span class="line" id="L84">        =&gt; <span class="tok-kw">return</span> .{</span>
<span class="line" id="L85">            .good = <span class="tok-number">0</span>,</span>
<span class="line" id="L86">            .lazy = <span class="tok-number">0</span>,</span>
<span class="line" id="L87">            .nice = <span class="tok-number">0</span>,</span>
<span class="line" id="L88">            .chain = <span class="tok-number">0</span>,</span>
<span class="line" id="L89">            .fast_skip_hashshing = <span class="tok-number">0</span>,</span>
<span class="line" id="L90">        },</span>
<span class="line" id="L91">        <span class="tok-comment">// For levels 2-3 we don't bother trying with lazy matches.</span>
</span>
<span class="line" id="L92">        .level_2 =&gt; <span class="tok-kw">return</span> .{</span>
<span class="line" id="L93">            .good = <span class="tok-number">4</span>,</span>
<span class="line" id="L94">            .lazy = <span class="tok-number">0</span>,</span>
<span class="line" id="L95">            .nice = <span class="tok-number">16</span>,</span>
<span class="line" id="L96">            .chain = <span class="tok-number">8</span>,</span>
<span class="line" id="L97">            .fast_skip_hashshing = <span class="tok-number">5</span>,</span>
<span class="line" id="L98">        },</span>
<span class="line" id="L99">        .level_3 =&gt; <span class="tok-kw">return</span> .{</span>
<span class="line" id="L100">            .good = <span class="tok-number">4</span>,</span>
<span class="line" id="L101">            .lazy = <span class="tok-number">0</span>,</span>
<span class="line" id="L102">            .nice = <span class="tok-number">32</span>,</span>
<span class="line" id="L103">            .chain = <span class="tok-number">32</span>,</span>
<span class="line" id="L104">            .fast_skip_hashshing = <span class="tok-number">6</span>,</span>
<span class="line" id="L105">        },</span>
<span class="line" id="L106"></span>
<span class="line" id="L107">        <span class="tok-comment">// Levels 4-9 use increasingly more lazy matching and increasingly stringent conditions for</span>
</span>
<span class="line" id="L108">        <span class="tok-comment">// &quot;good enough&quot;.</span>
</span>
<span class="line" id="L109">        .level_4 =&gt; <span class="tok-kw">return</span> .{</span>
<span class="line" id="L110">            .good = <span class="tok-number">4</span>,</span>
<span class="line" id="L111">            .lazy = <span class="tok-number">4</span>,</span>
<span class="line" id="L112">            .nice = <span class="tok-number">16</span>,</span>
<span class="line" id="L113">            .chain = <span class="tok-number">16</span>,</span>
<span class="line" id="L114">            .fast_skip_hashshing = skip_never,</span>
<span class="line" id="L115">        },</span>
<span class="line" id="L116">        .level_5 =&gt; <span class="tok-kw">return</span> .{</span>
<span class="line" id="L117">            .good = <span class="tok-number">8</span>,</span>
<span class="line" id="L118">            .lazy = <span class="tok-number">16</span>,</span>
<span class="line" id="L119">            .nice = <span class="tok-number">32</span>,</span>
<span class="line" id="L120">            .chain = <span class="tok-number">32</span>,</span>
<span class="line" id="L121">            .fast_skip_hashshing = skip_never,</span>
<span class="line" id="L122">        },</span>
<span class="line" id="L123">        .default_compression,</span>
<span class="line" id="L124">        .level_6,</span>
<span class="line" id="L125">        =&gt; <span class="tok-kw">return</span> .{</span>
<span class="line" id="L126">            .good = <span class="tok-number">8</span>,</span>
<span class="line" id="L127">            .lazy = <span class="tok-number">16</span>,</span>
<span class="line" id="L128">            .nice = <span class="tok-number">128</span>,</span>
<span class="line" id="L129">            .chain = <span class="tok-number">128</span>,</span>
<span class="line" id="L130">            .fast_skip_hashshing = skip_never,</span>
<span class="line" id="L131">        },</span>
<span class="line" id="L132">        .level_7 =&gt; <span class="tok-kw">return</span> .{</span>
<span class="line" id="L133">            .good = <span class="tok-number">8</span>,</span>
<span class="line" id="L134">            .lazy = <span class="tok-number">32</span>,</span>
<span class="line" id="L135">            .nice = <span class="tok-number">128</span>,</span>
<span class="line" id="L136">            .chain = <span class="tok-number">256</span>,</span>
<span class="line" id="L137">            .fast_skip_hashshing = skip_never,</span>
<span class="line" id="L138">        },</span>
<span class="line" id="L139">        .level_8 =&gt; <span class="tok-kw">return</span> .{</span>
<span class="line" id="L140">            .good = <span class="tok-number">32</span>,</span>
<span class="line" id="L141">            .lazy = <span class="tok-number">128</span>,</span>
<span class="line" id="L142">            .nice = <span class="tok-number">258</span>,</span>
<span class="line" id="L143">            .chain = <span class="tok-number">1024</span>,</span>
<span class="line" id="L144">            .fast_skip_hashshing = skip_never,</span>
<span class="line" id="L145">        },</span>
<span class="line" id="L146">        .best_compression =&gt; <span class="tok-kw">return</span> .{</span>
<span class="line" id="L147">            .good = <span class="tok-number">32</span>,</span>
<span class="line" id="L148">            .lazy = <span class="tok-number">258</span>,</span>
<span class="line" id="L149">            .nice = <span class="tok-number">258</span>,</span>
<span class="line" id="L150">            .chain = <span class="tok-number">4096</span>,</span>
<span class="line" id="L151">            .fast_skip_hashshing = skip_never,</span>
<span class="line" id="L152">        },</span>
<span class="line" id="L153">    }</span>
<span class="line" id="L154">}</span>
<span class="line" id="L155"></span>
<span class="line" id="L156"><span class="tok-comment">// matchLen returns the number of matching bytes in a and b</span>
</span>
<span class="line" id="L157"><span class="tok-comment">// up to length 'max'. Both slices must be at least 'max'</span>
</span>
<span class="line" id="L158"><span class="tok-comment">// bytes in size.</span>
</span>
<span class="line" id="L159"><span class="tok-kw">fn</span> <span class="tok-fn">matchLen</span>(a: []<span class="tok-type">u8</span>, b: []<span class="tok-type">u8</span>, max: <span class="tok-type">u32</span>) <span class="tok-type">u32</span> {</span>
<span class="line" id="L160">    <span class="tok-kw">var</span> bounded_a = a[<span class="tok-number">0</span>..max];</span>
<span class="line" id="L161">    <span class="tok-kw">var</span> bounded_b = b[<span class="tok-number">0</span>..max];</span>
<span class="line" id="L162">    <span class="tok-kw">for</span> (bounded_a) |av, i| {</span>
<span class="line" id="L163">        <span class="tok-kw">if</span> (bounded_b[i] != av) {</span>
<span class="line" id="L164">            <span class="tok-kw">return</span> <span class="tok-builtin">@intCast</span>(<span class="tok-type">u32</span>, i);</span>
<span class="line" id="L165">        }</span>
<span class="line" id="L166">    }</span>
<span class="line" id="L167">    <span class="tok-kw">return</span> max;</span>
<span class="line" id="L168">}</span>
<span class="line" id="L169"></span>
<span class="line" id="L170"><span class="tok-kw">const</span> hash_mul = <span class="tok-number">0x1e35a7bd</span>;</span>
<span class="line" id="L171"></span>
<span class="line" id="L172"><span class="tok-comment">// hash4 returns a hash representation of the first 4 bytes</span>
</span>
<span class="line" id="L173"><span class="tok-comment">// of the supplied slice.</span>
</span>
<span class="line" id="L174"><span class="tok-comment">// The caller must ensure that b.len &gt;= 4.</span>
</span>
<span class="line" id="L175"><span class="tok-kw">fn</span> <span class="tok-fn">hash4</span>(b: []<span class="tok-type">u8</span>) <span class="tok-type">u32</span> {</span>
<span class="line" id="L176">    <span class="tok-kw">return</span> ((<span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, b[<span class="tok-number">3</span>]) |</span>
<span class="line" id="L177">        <span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, b[<span class="tok-number">2</span>]) &lt;&lt; <span class="tok-number">8</span> |</span>
<span class="line" id="L178">        <span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, b[<span class="tok-number">1</span>]) &lt;&lt; <span class="tok-number">16</span> |</span>
<span class="line" id="L179">        <span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, b[<span class="tok-number">0</span>]) &lt;&lt; <span class="tok-number">24</span>) *% hash_mul) &gt;&gt; (<span class="tok-number">32</span> - hash_bits);</span>
<span class="line" id="L180">}</span>
<span class="line" id="L181"></span>
<span class="line" id="L182"><span class="tok-comment">// bulkHash4 will compute hashes using the same</span>
</span>
<span class="line" id="L183"><span class="tok-comment">// algorithm as hash4</span>
</span>
<span class="line" id="L184"><span class="tok-kw">fn</span> <span class="tok-fn">bulkHash4</span>(b: []<span class="tok-type">u8</span>, dst: []<span class="tok-type">u32</span>) <span class="tok-type">u32</span> {</span>
<span class="line" id="L185">    <span class="tok-kw">if</span> (b.len &lt; min_match_length) {</span>
<span class="line" id="L186">        <span class="tok-kw">return</span> <span class="tok-number">0</span>;</span>
<span class="line" id="L187">    }</span>
<span class="line" id="L188">    <span class="tok-kw">var</span> hb =</span>
<span class="line" id="L189">        <span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, b[<span class="tok-number">3</span>]) |</span>
<span class="line" id="L190">        <span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, b[<span class="tok-number">2</span>]) &lt;&lt; <span class="tok-number">8</span> |</span>
<span class="line" id="L191">        <span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, b[<span class="tok-number">1</span>]) &lt;&lt; <span class="tok-number">16</span> |</span>
<span class="line" id="L192">        <span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, b[<span class="tok-number">0</span>]) &lt;&lt; <span class="tok-number">24</span>;</span>
<span class="line" id="L193"></span>
<span class="line" id="L194">    dst[<span class="tok-number">0</span>] = (hb *% hash_mul) &gt;&gt; (<span class="tok-number">32</span> - hash_bits);</span>
<span class="line" id="L195">    <span class="tok-kw">var</span> end = b.len - min_match_length + <span class="tok-number">1</span>;</span>
<span class="line" id="L196">    <span class="tok-kw">var</span> i: <span class="tok-type">u32</span> = <span class="tok-number">1</span>;</span>
<span class="line" id="L197">    <span class="tok-kw">while</span> (i &lt; end) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L198">        hb = (hb &lt;&lt; <span class="tok-number">8</span>) | <span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, b[i + <span class="tok-number">3</span>]);</span>
<span class="line" id="L199">        dst[i] = (hb *% hash_mul) &gt;&gt; (<span class="tok-number">32</span> - hash_bits);</span>
<span class="line" id="L200">    }</span>
<span class="line" id="L201"></span>
<span class="line" id="L202">    <span class="tok-kw">return</span> hb;</span>
<span class="line" id="L203">}</span>
<span class="line" id="L204"></span>
<span class="line" id="L205"><span class="tok-kw">const</span> CompressorOptions = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L206">    level: Compression = .default_compression,</span>
<span class="line" id="L207">    dictionary: ?[]<span class="tok-kw">const</span> <span class="tok-type">u8</span> = <span class="tok-null">null</span>,</span>
<span class="line" id="L208">};</span>
<span class="line" id="L209"></span>
<span class="line" id="L210"><span class="tok-comment">/// Returns a new Compressor compressing data at the given level.</span></span>
<span class="line" id="L211"><span class="tok-comment">/// Following zlib, levels range from 1 (best_speed) to 9 (best_compression);</span></span>
<span class="line" id="L212"><span class="tok-comment">/// higher levels typically run slower but compress more. Level 0</span></span>
<span class="line" id="L213"><span class="tok-comment">/// (no_compression) does not attempt any compression; it only adds the</span></span>
<span class="line" id="L214"><span class="tok-comment">/// necessary DEFLATE framing.</span></span>
<span class="line" id="L215"><span class="tok-comment">/// Level -1 (default_compression) uses the default compression level.</span></span>
<span class="line" id="L216"><span class="tok-comment">/// Level -2 (huffman_only) will use Huffman compression only, giving</span></span>
<span class="line" id="L217"><span class="tok-comment">/// a very fast compression for all types of input, but sacrificing considerable</span></span>
<span class="line" id="L218"><span class="tok-comment">/// compression efficiency.</span></span>
<span class="line" id="L219"><span class="tok-comment">///</span></span>
<span class="line" id="L220"><span class="tok-comment">/// `dictionary` is optional and initializes the new `Compressor` with a preset dictionary.</span></span>
<span class="line" id="L221"><span class="tok-comment">/// The returned Compressor behaves as if the dictionary had been written to it without producing</span></span>
<span class="line" id="L222"><span class="tok-comment">/// any compressed output. The compressed data written to hm_bw can only be decompressed by a</span></span>
<span class="line" id="L223"><span class="tok-comment">/// Decompressor initialized with the same dictionary.</span></span>
<span class="line" id="L224"><span class="tok-comment">///</span></span>
<span class="line" id="L225"><span class="tok-comment">/// The compressed data will be passed to the provided `writer`, see `writer()` and `write()`.</span></span>
<span class="line" id="L226"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">compressor</span>(</span>
<span class="line" id="L227">    allocator: Allocator,</span>
<span class="line" id="L228">    writer: <span class="tok-kw">anytype</span>,</span>
<span class="line" id="L229">    options: CompressorOptions,</span>
<span class="line" id="L230">) !Compressor(<span class="tok-builtin">@TypeOf</span>(writer)) {</span>
<span class="line" id="L231">    <span class="tok-kw">return</span> Compressor(<span class="tok-builtin">@TypeOf</span>(writer)).init(allocator, writer, options);</span>
<span class="line" id="L232">}</span>
<span class="line" id="L233"></span>
<span class="line" id="L234"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">Compressor</span>(<span class="tok-kw">comptime</span> WriterType: <span class="tok-kw">anytype</span>) <span class="tok-type">type</span> {</span>
<span class="line" id="L235">    <span class="tok-kw">return</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L236">        <span class="tok-kw">const</span> Self = <span class="tok-builtin">@This</span>();</span>
<span class="line" id="L237"></span>
<span class="line" id="L238">        <span class="tok-comment">/// A Writer takes data written to it and writes the compressed</span></span>
<span class="line" id="L239">        <span class="tok-comment">/// form of that data to an underlying writer.</span></span>
<span class="line" id="L240">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> Writer = io.Writer(*Self, Error, write);</span>
<span class="line" id="L241"></span>
<span class="line" id="L242">        <span class="tok-comment">/// Returns a Writer that takes data written to it and writes the compressed</span></span>
<span class="line" id="L243">        <span class="tok-comment">/// form of that data to an underlying writer.</span></span>
<span class="line" id="L244">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">writer</span>(self: *Self) Writer {</span>
<span class="line" id="L245">            <span class="tok-kw">return</span> .{ .context = self };</span>
<span class="line" id="L246">        }</span>
<span class="line" id="L247"></span>
<span class="line" id="L248">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> Error = WriterType.Error;</span>
<span class="line" id="L249"></span>
<span class="line" id="L250">        allocator: Allocator,</span>
<span class="line" id="L251"></span>
<span class="line" id="L252">        compression: Compression,</span>
<span class="line" id="L253">        compression_level: CompressionLevel,</span>
<span class="line" id="L254"></span>
<span class="line" id="L255">        <span class="tok-comment">// Inner writer wrapped in a HuffmanBitWriter</span>
</span>
<span class="line" id="L256">        hm_bw: hm_bw.HuffmanBitWriter(WriterType) = <span class="tok-null">undefined</span>,</span>
<span class="line" id="L257">        bulk_hasher: <span class="tok-kw">if</span> (<span class="tok-builtin">@import</span>(<span class="tok-str">&quot;builtin&quot;</span>).zig_backend == .stage1)</span>
<span class="line" id="L258">            <span class="tok-kw">fn</span> ([]<span class="tok-type">u8</span>, []<span class="tok-type">u32</span>) <span class="tok-type">u32</span></span>
<span class="line" id="L259">        <span class="tok-kw">else</span></span>
<span class="line" id="L260">            *<span class="tok-kw">const</span> <span class="tok-kw">fn</span> ([]<span class="tok-type">u8</span>, []<span class="tok-type">u32</span>) <span class="tok-type">u32</span>,</span>
<span class="line" id="L261"></span>
<span class="line" id="L262">        sync: <span class="tok-type">bool</span>, <span class="tok-comment">// requesting flush</span>
</span>
<span class="line" id="L263">        best_speed_enc: *fast.DeflateFast, <span class="tok-comment">// Encoder for best_speed</span>
</span>
<span class="line" id="L264"></span>
<span class="line" id="L265">        <span class="tok-comment">// Input hash chains</span>
</span>
<span class="line" id="L266">        <span class="tok-comment">// hash_head[hashValue] contains the largest inputIndex with the specified hash value</span>
</span>
<span class="line" id="L267">        <span class="tok-comment">// If hash_head[hashValue] is within the current window, then</span>
</span>
<span class="line" id="L268">        <span class="tok-comment">// hash_prev[hash_head[hashValue] &amp; window_mask] contains the previous index</span>
</span>
<span class="line" id="L269">        <span class="tok-comment">// with the same hash value.</span>
</span>
<span class="line" id="L270">        chain_head: <span class="tok-type">u32</span>,</span>
<span class="line" id="L271">        hash_head: []<span class="tok-type">u32</span>, <span class="tok-comment">// [hash_size]u32,</span>
</span>
<span class="line" id="L272">        hash_prev: []<span class="tok-type">u32</span>, <span class="tok-comment">// [window_size]u32,</span>
</span>
<span class="line" id="L273">        hash_offset: <span class="tok-type">u32</span>,</span>
<span class="line" id="L274"></span>
<span class="line" id="L275">        <span class="tok-comment">// input window: unprocessed data is window[index..window_end]</span>
</span>
<span class="line" id="L276">        index: <span class="tok-type">u32</span>,</span>
<span class="line" id="L277">        window: []<span class="tok-type">u8</span>,</span>
<span class="line" id="L278">        window_end: <span class="tok-type">usize</span>,</span>
<span class="line" id="L279">        block_start: <span class="tok-type">usize</span>, <span class="tok-comment">// window index where current tokens start</span>
</span>
<span class="line" id="L280">        byte_available: <span class="tok-type">bool</span>, <span class="tok-comment">// if true, still need to process window[index-1].</span>
</span>
<span class="line" id="L281"></span>
<span class="line" id="L282">        <span class="tok-comment">// queued output tokens</span>
</span>
<span class="line" id="L283">        tokens: []token.Token,</span>
<span class="line" id="L284">        tokens_count: <span class="tok-type">u16</span>,</span>
<span class="line" id="L285"></span>
<span class="line" id="L286">        <span class="tok-comment">// deflate state</span>
</span>
<span class="line" id="L287">        length: <span class="tok-type">u32</span>,</span>
<span class="line" id="L288">        offset: <span class="tok-type">u32</span>,</span>
<span class="line" id="L289">        hash: <span class="tok-type">u32</span>,</span>
<span class="line" id="L290">        max_insert_index: <span class="tok-type">usize</span>,</span>
<span class="line" id="L291">        err: <span class="tok-type">bool</span>,</span>
<span class="line" id="L292"></span>
<span class="line" id="L293">        <span class="tok-comment">// hash_match must be able to contain hashes for the maximum match length.</span>
</span>
<span class="line" id="L294">        hash_match: []<span class="tok-type">u32</span>, <span class="tok-comment">// [max_match_length - 1]u32,</span>
</span>
<span class="line" id="L295"></span>
<span class="line" id="L296">        <span class="tok-comment">// dictionary</span>
</span>
<span class="line" id="L297">        dictionary: ?[]<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L298"></span>
<span class="line" id="L299">        <span class="tok-kw">fn</span> <span class="tok-fn">fillDeflate</span>(self: *Self, b: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) <span class="tok-type">u32</span> {</span>
<span class="line" id="L300">            <span class="tok-kw">if</span> (self.index &gt;= <span class="tok-number">2</span> * window_size - (min_match_length + max_match_length)) {</span>
<span class="line" id="L301">                <span class="tok-comment">// shift the window by window_size</span>
</span>
<span class="line" id="L302">                mem.copy(<span class="tok-type">u8</span>, self.window, self.window[window_size .. <span class="tok-number">2</span> * window_size]);</span>
<span class="line" id="L303">                self.index -= window_size;</span>
<span class="line" id="L304">                self.window_end -= window_size;</span>
<span class="line" id="L305">                <span class="tok-kw">if</span> (self.block_start &gt;= window_size) {</span>
<span class="line" id="L306">                    self.block_start -= window_size;</span>
<span class="line" id="L307">                } <span class="tok-kw">else</span> {</span>
<span class="line" id="L308">                    self.block_start = math.maxInt(<span class="tok-type">u32</span>);</span>
<span class="line" id="L309">                }</span>
<span class="line" id="L310">                self.hash_offset += window_size;</span>
<span class="line" id="L311">                <span class="tok-kw">if</span> (self.hash_offset &gt; max_hash_offset) {</span>
<span class="line" id="L312">                    <span class="tok-kw">var</span> delta = self.hash_offset - <span class="tok-number">1</span>;</span>
<span class="line" id="L313">                    self.hash_offset -= delta;</span>
<span class="line" id="L314">                    self.chain_head -|= delta;</span>
<span class="line" id="L315"></span>
<span class="line" id="L316">                    <span class="tok-comment">// Iterate over slices instead of arrays to avoid copying</span>
</span>
<span class="line" id="L317">                    <span class="tok-comment">// the entire table onto the stack (https://golang.org/issue/18625).</span>
</span>
<span class="line" id="L318">                    <span class="tok-kw">for</span> (self.hash_prev) |v, i| {</span>
<span class="line" id="L319">                        <span class="tok-kw">if</span> (v &gt; delta) {</span>
<span class="line" id="L320">                            self.hash_prev[i] = <span class="tok-builtin">@intCast</span>(<span class="tok-type">u32</span>, v - delta);</span>
<span class="line" id="L321">                        } <span class="tok-kw">else</span> {</span>
<span class="line" id="L322">                            self.hash_prev[i] = <span class="tok-number">0</span>;</span>
<span class="line" id="L323">                        }</span>
<span class="line" id="L324">                    }</span>
<span class="line" id="L325">                    <span class="tok-kw">for</span> (self.hash_head) |v, i| {</span>
<span class="line" id="L326">                        <span class="tok-kw">if</span> (v &gt; delta) {</span>
<span class="line" id="L327">                            self.hash_head[i] = <span class="tok-builtin">@intCast</span>(<span class="tok-type">u32</span>, v - delta);</span>
<span class="line" id="L328">                        } <span class="tok-kw">else</span> {</span>
<span class="line" id="L329">                            self.hash_head[i] = <span class="tok-number">0</span>;</span>
<span class="line" id="L330">                        }</span>
<span class="line" id="L331">                    }</span>
<span class="line" id="L332">                }</span>
<span class="line" id="L333">            }</span>
<span class="line" id="L334">            <span class="tok-kw">var</span> n = mu.copy(self.window[self.window_end..], b);</span>
<span class="line" id="L335">            self.window_end += n;</span>
<span class="line" id="L336">            <span class="tok-kw">return</span> <span class="tok-builtin">@intCast</span>(<span class="tok-type">u32</span>, n);</span>
<span class="line" id="L337">        }</span>
<span class="line" id="L338"></span>
<span class="line" id="L339">        <span class="tok-kw">fn</span> <span class="tok-fn">writeBlock</span>(self: *Self, tokens: []token.Token, index: <span class="tok-type">usize</span>) !<span class="tok-type">void</span> {</span>
<span class="line" id="L340">            <span class="tok-kw">if</span> (index &gt; <span class="tok-number">0</span>) {</span>
<span class="line" id="L341">                <span class="tok-kw">var</span> window: ?[]<span class="tok-type">u8</span> = <span class="tok-null">null</span>;</span>
<span class="line" id="L342">                <span class="tok-kw">if</span> (self.block_start &lt;= index) {</span>
<span class="line" id="L343">                    window = self.window[self.block_start..index];</span>
<span class="line" id="L344">                }</span>
<span class="line" id="L345">                self.block_start = index;</span>
<span class="line" id="L346">                <span class="tok-kw">try</span> self.hm_bw.writeBlock(tokens, <span class="tok-null">false</span>, window);</span>
<span class="line" id="L347">                <span class="tok-kw">return</span>;</span>
<span class="line" id="L348">            }</span>
<span class="line" id="L349">            <span class="tok-kw">return</span>;</span>
<span class="line" id="L350">        }</span>
<span class="line" id="L351"></span>
<span class="line" id="L352">        <span class="tok-comment">// fillWindow will fill the current window with the supplied</span>
</span>
<span class="line" id="L353">        <span class="tok-comment">// dictionary and calculate all hashes.</span>
</span>
<span class="line" id="L354">        <span class="tok-comment">// This is much faster than doing a full encode.</span>
</span>
<span class="line" id="L355">        <span class="tok-comment">// Should only be used after a reset.</span>
</span>
<span class="line" id="L356">        <span class="tok-kw">fn</span> <span class="tok-fn">fillWindow</span>(self: *Self, in_b: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L357">            <span class="tok-kw">var</span> b = in_b;</span>
<span class="line" id="L358">            <span class="tok-comment">// Do not fill window if we are in store-only mode (look at the fill() function to see</span>
</span>
<span class="line" id="L359">            <span class="tok-comment">// Compressions which use fillStore() instead of fillDeflate()).</span>
</span>
<span class="line" id="L360">            <span class="tok-kw">if</span> (self.compression == .no_compression <span class="tok-kw">or</span></span>
<span class="line" id="L361">                self.compression == .huffman_only <span class="tok-kw">or</span></span>
<span class="line" id="L362">                self.compression == .best_speed)</span>
<span class="line" id="L363">            {</span>
<span class="line" id="L364">                <span class="tok-kw">return</span>;</span>
<span class="line" id="L365">            }</span>
<span class="line" id="L366"></span>
<span class="line" id="L367">            <span class="tok-comment">// fillWindow() must not be called with stale data</span>
</span>
<span class="line" id="L368">            assert(self.index == <span class="tok-number">0</span> <span class="tok-kw">and</span> self.window_end == <span class="tok-number">0</span>);</span>
<span class="line" id="L369"></span>
<span class="line" id="L370">            <span class="tok-comment">// If we are given too much, cut it.</span>
</span>
<span class="line" id="L371">            <span class="tok-kw">if</span> (b.len &gt; window_size) {</span>
<span class="line" id="L372">                b = b[b.len - window_size ..];</span>
<span class="line" id="L373">            }</span>
<span class="line" id="L374">            <span class="tok-comment">// Add all to window.</span>
</span>
<span class="line" id="L375">            mem.copy(<span class="tok-type">u8</span>, self.window, b);</span>
<span class="line" id="L376">            <span class="tok-kw">var</span> n = b.len;</span>
<span class="line" id="L377"></span>
<span class="line" id="L378">            <span class="tok-comment">// Calculate 256 hashes at the time (more L1 cache hits)</span>
</span>
<span class="line" id="L379">            <span class="tok-kw">var</span> loops = (n + <span class="tok-number">256</span> - min_match_length) / <span class="tok-number">256</span>;</span>
<span class="line" id="L380">            <span class="tok-kw">var</span> j: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L381">            <span class="tok-kw">while</span> (j &lt; loops) : (j += <span class="tok-number">1</span>) {</span>
<span class="line" id="L382">                <span class="tok-kw">var</span> index = j * <span class="tok-number">256</span>;</span>
<span class="line" id="L383">                <span class="tok-kw">var</span> end = index + <span class="tok-number">256</span> + min_match_length - <span class="tok-number">1</span>;</span>
<span class="line" id="L384">                <span class="tok-kw">if</span> (end &gt; n) {</span>
<span class="line" id="L385">                    end = n;</span>
<span class="line" id="L386">                }</span>
<span class="line" id="L387">                <span class="tok-kw">var</span> to_check = self.window[index..end];</span>
<span class="line" id="L388">                <span class="tok-kw">var</span> dst_size = to_check.len - min_match_length + <span class="tok-number">1</span>;</span>
<span class="line" id="L389"></span>
<span class="line" id="L390">                <span class="tok-kw">if</span> (dst_size &lt;= <span class="tok-number">0</span>) {</span>
<span class="line" id="L391">                    <span class="tok-kw">continue</span>;</span>
<span class="line" id="L392">                }</span>
<span class="line" id="L393"></span>
<span class="line" id="L394">                <span class="tok-kw">var</span> dst = self.hash_match[<span class="tok-number">0</span>..dst_size];</span>
<span class="line" id="L395">                _ = self.bulk_hasher(to_check, dst);</span>
<span class="line" id="L396">                <span class="tok-kw">var</span> new_h: <span class="tok-type">u32</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L397">                <span class="tok-kw">for</span> (dst) |val, i| {</span>
<span class="line" id="L398">                    <span class="tok-kw">var</span> di = i + index;</span>
<span class="line" id="L399">                    new_h = val;</span>
<span class="line" id="L400">                    <span class="tok-kw">var</span> hh = &amp;self.hash_head[new_h &amp; hash_mask];</span>
<span class="line" id="L401">                    <span class="tok-comment">// Get previous value with the same hash.</span>
</span>
<span class="line" id="L402">                    <span class="tok-comment">// Our chain should point to the previous value.</span>
</span>
<span class="line" id="L403">                    self.hash_prev[di &amp; window_mask] = hh.*;</span>
<span class="line" id="L404">                    <span class="tok-comment">// Set the head of the hash chain to us.</span>
</span>
<span class="line" id="L405">                    hh.* = <span class="tok-builtin">@intCast</span>(<span class="tok-type">u32</span>, di + self.hash_offset);</span>
<span class="line" id="L406">                }</span>
<span class="line" id="L407">                self.hash = new_h;</span>
<span class="line" id="L408">            }</span>
<span class="line" id="L409">            <span class="tok-comment">// Update window information.</span>
</span>
<span class="line" id="L410">            self.window_end = n;</span>
<span class="line" id="L411">            self.index = <span class="tok-builtin">@intCast</span>(<span class="tok-type">u32</span>, n);</span>
<span class="line" id="L412">        }</span>
<span class="line" id="L413"></span>
<span class="line" id="L414">        <span class="tok-kw">const</span> Match = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L415">            length: <span class="tok-type">u32</span>,</span>
<span class="line" id="L416">            offset: <span class="tok-type">u32</span>,</span>
<span class="line" id="L417">            ok: <span class="tok-type">bool</span>,</span>
<span class="line" id="L418">        };</span>
<span class="line" id="L419"></span>
<span class="line" id="L420">        <span class="tok-comment">// Try to find a match starting at pos whose length is greater than prev_length.</span>
</span>
<span class="line" id="L421">        <span class="tok-comment">// We only look at self.compression_level.chain possibilities before giving up.</span>
</span>
<span class="line" id="L422">        <span class="tok-kw">fn</span> <span class="tok-fn">findMatch</span>(</span>
<span class="line" id="L423">            self: *Self,</span>
<span class="line" id="L424">            pos: <span class="tok-type">u32</span>,</span>
<span class="line" id="L425">            prev_head: <span class="tok-type">u32</span>,</span>
<span class="line" id="L426">            prev_length: <span class="tok-type">u32</span>,</span>
<span class="line" id="L427">            lookahead: <span class="tok-type">u32</span>,</span>
<span class="line" id="L428">        ) Match {</span>
<span class="line" id="L429">            <span class="tok-kw">var</span> length: <span class="tok-type">u32</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L430">            <span class="tok-kw">var</span> offset: <span class="tok-type">u32</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L431">            <span class="tok-kw">var</span> ok: <span class="tok-type">bool</span> = <span class="tok-null">false</span>;</span>
<span class="line" id="L432"></span>
<span class="line" id="L433">            <span class="tok-kw">var</span> min_match_look: <span class="tok-type">u32</span> = max_match_length;</span>
<span class="line" id="L434">            <span class="tok-kw">if</span> (lookahead &lt; min_match_look) {</span>
<span class="line" id="L435">                min_match_look = lookahead;</span>
<span class="line" id="L436">            }</span>
<span class="line" id="L437"></span>
<span class="line" id="L438">            <span class="tok-kw">var</span> win = self.window[<span class="tok-number">0</span> .. pos + min_match_look];</span>
<span class="line" id="L439"></span>
<span class="line" id="L440">            <span class="tok-comment">// We quit when we get a match that's at least nice long</span>
</span>
<span class="line" id="L441">            <span class="tok-kw">var</span> nice = win.len - pos;</span>
<span class="line" id="L442">            <span class="tok-kw">if</span> (self.compression_level.nice &lt; nice) {</span>
<span class="line" id="L443">                nice = self.compression_level.nice;</span>
<span class="line" id="L444">            }</span>
<span class="line" id="L445"></span>
<span class="line" id="L446">            <span class="tok-comment">// If we've got a match that's good enough, only look in 1/4 the chain.</span>
</span>
<span class="line" id="L447">            <span class="tok-kw">var</span> tries = self.compression_level.chain;</span>
<span class="line" id="L448">            length = prev_length;</span>
<span class="line" id="L449">            <span class="tok-kw">if</span> (length &gt;= self.compression_level.good) {</span>
<span class="line" id="L450">                tries &gt;&gt;= <span class="tok-number">2</span>;</span>
<span class="line" id="L451">            }</span>
<span class="line" id="L452"></span>
<span class="line" id="L453">            <span class="tok-kw">var</span> w_end = win[pos + length];</span>
<span class="line" id="L454">            <span class="tok-kw">var</span> w_pos = win[pos..];</span>
<span class="line" id="L455">            <span class="tok-kw">var</span> min_index = pos -| window_size;</span>
<span class="line" id="L456"></span>
<span class="line" id="L457">            <span class="tok-kw">var</span> i = prev_head;</span>
<span class="line" id="L458">            <span class="tok-kw">while</span> (tries &gt; <span class="tok-number">0</span>) : (tries -= <span class="tok-number">1</span>) {</span>
<span class="line" id="L459">                <span class="tok-kw">if</span> (w_end == win[i + length]) {</span>
<span class="line" id="L460">                    <span class="tok-kw">var</span> n = matchLen(win[i..], w_pos, min_match_look);</span>
<span class="line" id="L461"></span>
<span class="line" id="L462">                    <span class="tok-kw">if</span> (n &gt; length <span class="tok-kw">and</span> (n &gt; min_match_length <span class="tok-kw">or</span> pos - i &lt;= <span class="tok-number">4096</span>)) {</span>
<span class="line" id="L463">                        length = n;</span>
<span class="line" id="L464">                        offset = pos - i;</span>
<span class="line" id="L465">                        ok = <span class="tok-null">true</span>;</span>
<span class="line" id="L466">                        <span class="tok-kw">if</span> (n &gt;= nice) {</span>
<span class="line" id="L467">                            <span class="tok-comment">// The match is good enough that we don't try to find a better one.</span>
</span>
<span class="line" id="L468">                            <span class="tok-kw">break</span>;</span>
<span class="line" id="L469">                        }</span>
<span class="line" id="L470">                        w_end = win[pos + n];</span>
<span class="line" id="L471">                    }</span>
<span class="line" id="L472">                }</span>
<span class="line" id="L473">                <span class="tok-kw">if</span> (i == min_index) {</span>
<span class="line" id="L474">                    <span class="tok-comment">// hash_prev[i &amp; window_mask] has already been overwritten, so stop now.</span>
</span>
<span class="line" id="L475">                    <span class="tok-kw">break</span>;</span>
<span class="line" id="L476">                }</span>
<span class="line" id="L477"></span>
<span class="line" id="L478">                <span class="tok-kw">if</span> (<span class="tok-builtin">@intCast</span>(<span class="tok-type">u32</span>, self.hash_prev[i &amp; window_mask]) &lt; self.hash_offset) {</span>
<span class="line" id="L479">                    <span class="tok-kw">break</span>;</span>
<span class="line" id="L480">                }</span>
<span class="line" id="L481"></span>
<span class="line" id="L482">                i = <span class="tok-builtin">@intCast</span>(<span class="tok-type">u32</span>, self.hash_prev[i &amp; window_mask]) - self.hash_offset;</span>
<span class="line" id="L483">                <span class="tok-kw">if</span> (i &lt; min_index) {</span>
<span class="line" id="L484">                    <span class="tok-kw">break</span>;</span>
<span class="line" id="L485">                }</span>
<span class="line" id="L486">            }</span>
<span class="line" id="L487"></span>
<span class="line" id="L488">            <span class="tok-kw">return</span> Match{ .length = length, .offset = offset, .ok = ok };</span>
<span class="line" id="L489">        }</span>
<span class="line" id="L490"></span>
<span class="line" id="L491">        <span class="tok-kw">fn</span> <span class="tok-fn">writeStoredBlock</span>(self: *Self, buf: []<span class="tok-type">u8</span>) !<span class="tok-type">void</span> {</span>
<span class="line" id="L492">            <span class="tok-kw">try</span> self.hm_bw.writeStoredHeader(buf.len, <span class="tok-null">false</span>);</span>
<span class="line" id="L493">            <span class="tok-kw">try</span> self.hm_bw.writeBytes(buf);</span>
<span class="line" id="L494">        }</span>
<span class="line" id="L495"></span>
<span class="line" id="L496">        <span class="tok-comment">// encSpeed will compress and store the currently added data,</span>
</span>
<span class="line" id="L497">        <span class="tok-comment">// if enough has been accumulated or we at the end of the stream.</span>
</span>
<span class="line" id="L498">        <span class="tok-kw">fn</span> <span class="tok-fn">encSpeed</span>(self: *Self) !<span class="tok-type">void</span> {</span>
<span class="line" id="L499">            <span class="tok-comment">// We only compress if we have max_store_block_size.</span>
</span>
<span class="line" id="L500">            <span class="tok-kw">if</span> (self.window_end &lt; max_store_block_size) {</span>
<span class="line" id="L501">                <span class="tok-kw">if</span> (!self.sync) {</span>
<span class="line" id="L502">                    <span class="tok-kw">return</span>;</span>
<span class="line" id="L503">                }</span>
<span class="line" id="L504"></span>
<span class="line" id="L505">                <span class="tok-comment">// Handle small sizes.</span>
</span>
<span class="line" id="L506">                <span class="tok-kw">if</span> (self.window_end &lt; <span class="tok-number">128</span>) {</span>
<span class="line" id="L507">                    <span class="tok-kw">switch</span> (self.window_end) {</span>
<span class="line" id="L508">                        <span class="tok-number">0</span> =&gt; <span class="tok-kw">return</span>,</span>
<span class="line" id="L509">                        <span class="tok-number">1</span>...<span class="tok-number">16</span> =&gt; {</span>
<span class="line" id="L510">                            <span class="tok-kw">try</span> self.writeStoredBlock(self.window[<span class="tok-number">0</span>..self.window_end]);</span>
<span class="line" id="L511">                        },</span>
<span class="line" id="L512">                        <span class="tok-kw">else</span> =&gt; {</span>
<span class="line" id="L513">                            <span class="tok-kw">try</span> self.hm_bw.writeBlockHuff(<span class="tok-null">false</span>, self.window[<span class="tok-number">0</span>..self.window_end]);</span>
<span class="line" id="L514">                            self.err = self.hm_bw.err;</span>
<span class="line" id="L515">                        },</span>
<span class="line" id="L516">                    }</span>
<span class="line" id="L517">                    self.window_end = <span class="tok-number">0</span>;</span>
<span class="line" id="L518">                    self.best_speed_enc.reset();</span>
<span class="line" id="L519">                    <span class="tok-kw">return</span>;</span>
<span class="line" id="L520">                }</span>
<span class="line" id="L521">            }</span>
<span class="line" id="L522">            <span class="tok-comment">// Encode the block.</span>
</span>
<span class="line" id="L523">            self.tokens_count = <span class="tok-number">0</span>;</span>
<span class="line" id="L524">            self.best_speed_enc.encode(</span>
<span class="line" id="L525">                self.tokens,</span>
<span class="line" id="L526">                &amp;self.tokens_count,</span>
<span class="line" id="L527">                self.window[<span class="tok-number">0</span>..self.window_end],</span>
<span class="line" id="L528">            );</span>
<span class="line" id="L529"></span>
<span class="line" id="L530">            <span class="tok-comment">// If we removed less than 1/16th, Huffman compress the block.</span>
</span>
<span class="line" id="L531">            <span class="tok-kw">if</span> (self.tokens_count &gt; self.window_end - (self.window_end &gt;&gt; <span class="tok-number">4</span>)) {</span>
<span class="line" id="L532">                <span class="tok-kw">try</span> self.hm_bw.writeBlockHuff(<span class="tok-null">false</span>, self.window[<span class="tok-number">0</span>..self.window_end]);</span>
<span class="line" id="L533">            } <span class="tok-kw">else</span> {</span>
<span class="line" id="L534">                <span class="tok-kw">try</span> self.hm_bw.writeBlockDynamic(</span>
<span class="line" id="L535">                    self.tokens[<span class="tok-number">0</span>..self.tokens_count],</span>
<span class="line" id="L536">                    <span class="tok-null">false</span>,</span>
<span class="line" id="L537">                    self.window[<span class="tok-number">0</span>..self.window_end],</span>
<span class="line" id="L538">                );</span>
<span class="line" id="L539">            }</span>
<span class="line" id="L540">            self.err = self.hm_bw.err;</span>
<span class="line" id="L541">            self.window_end = <span class="tok-number">0</span>;</span>
<span class="line" id="L542">        }</span>
<span class="line" id="L543"></span>
<span class="line" id="L544">        <span class="tok-kw">fn</span> <span class="tok-fn">initDeflate</span>(self: *Self) !<span class="tok-type">void</span> {</span>
<span class="line" id="L545">            self.window = <span class="tok-kw">try</span> self.allocator.alloc(<span class="tok-type">u8</span>, <span class="tok-number">2</span> * window_size);</span>
<span class="line" id="L546">            self.hash_offset = <span class="tok-number">1</span>;</span>
<span class="line" id="L547">            self.tokens = <span class="tok-kw">try</span> self.allocator.alloc(token.Token, max_flate_block_tokens);</span>
<span class="line" id="L548">            self.tokens_count = <span class="tok-number">0</span>;</span>
<span class="line" id="L549">            mem.set(token.Token, self.tokens, <span class="tok-number">0</span>);</span>
<span class="line" id="L550">            self.length = min_match_length - <span class="tok-number">1</span>;</span>
<span class="line" id="L551">            self.offset = <span class="tok-number">0</span>;</span>
<span class="line" id="L552">            self.byte_available = <span class="tok-null">false</span>;</span>
<span class="line" id="L553">            self.index = <span class="tok-number">0</span>;</span>
<span class="line" id="L554">            self.hash = <span class="tok-number">0</span>;</span>
<span class="line" id="L555">            self.chain_head = <span class="tok-number">0</span>;</span>
<span class="line" id="L556">            self.bulk_hasher = bulkHash4;</span>
<span class="line" id="L557">        }</span>
<span class="line" id="L558"></span>
<span class="line" id="L559">        <span class="tok-kw">fn</span> <span class="tok-fn">deflate</span>(self: *Self) !<span class="tok-type">void</span> {</span>
<span class="line" id="L560">            <span class="tok-kw">if</span> (self.window_end - self.index &lt; min_match_length + max_match_length <span class="tok-kw">and</span> !self.sync) {</span>
<span class="line" id="L561">                <span class="tok-kw">return</span>;</span>
<span class="line" id="L562">            }</span>
<span class="line" id="L563"></span>
<span class="line" id="L564">            self.max_insert_index = self.window_end -| (min_match_length - <span class="tok-number">1</span>);</span>
<span class="line" id="L565">            <span class="tok-kw">if</span> (self.index &lt; self.max_insert_index) {</span>
<span class="line" id="L566">                self.hash = hash4(self.window[self.index .. self.index + min_match_length]);</span>
<span class="line" id="L567">            }</span>
<span class="line" id="L568"></span>
<span class="line" id="L569">            <span class="tok-kw">while</span> (<span class="tok-null">true</span>) {</span>
<span class="line" id="L570">                assert(self.index &lt;= self.window_end);</span>
<span class="line" id="L571"></span>
<span class="line" id="L572">                <span class="tok-kw">var</span> lookahead = self.window_end -| self.index;</span>
<span class="line" id="L573">                <span class="tok-kw">if</span> (lookahead &lt; min_match_length + max_match_length) {</span>
<span class="line" id="L574">                    <span class="tok-kw">if</span> (!self.sync) {</span>
<span class="line" id="L575">                        <span class="tok-kw">break</span>;</span>
<span class="line" id="L576">                    }</span>
<span class="line" id="L577">                    assert(self.index &lt;= self.window_end);</span>
<span class="line" id="L578"></span>
<span class="line" id="L579">                    <span class="tok-kw">if</span> (lookahead == <span class="tok-number">0</span>) {</span>
<span class="line" id="L580">                        <span class="tok-comment">// Flush current output block if any.</span>
</span>
<span class="line" id="L581">                        <span class="tok-kw">if</span> (self.byte_available) {</span>
<span class="line" id="L582">                            <span class="tok-comment">// There is still one pending token that needs to be flushed</span>
</span>
<span class="line" id="L583">                            self.tokens[self.tokens_count] = token.literalToken(<span class="tok-builtin">@intCast</span>(<span class="tok-type">u32</span>, self.window[self.index - <span class="tok-number">1</span>]));</span>
<span class="line" id="L584">                            self.tokens_count += <span class="tok-number">1</span>;</span>
<span class="line" id="L585">                            self.byte_available = <span class="tok-null">false</span>;</span>
<span class="line" id="L586">                        }</span>
<span class="line" id="L587">                        <span class="tok-kw">if</span> (self.tokens.len &gt; <span class="tok-number">0</span>) {</span>
<span class="line" id="L588">                            <span class="tok-kw">try</span> self.writeBlock(self.tokens[<span class="tok-number">0</span>..self.tokens_count], self.index);</span>
<span class="line" id="L589">                            self.tokens_count = <span class="tok-number">0</span>;</span>
<span class="line" id="L590">                        }</span>
<span class="line" id="L591">                        <span class="tok-kw">break</span>;</span>
<span class="line" id="L592">                    }</span>
<span class="line" id="L593">                }</span>
<span class="line" id="L594">                <span class="tok-kw">if</span> (self.index &lt; self.max_insert_index) {</span>
<span class="line" id="L595">                    <span class="tok-comment">// Update the hash</span>
</span>
<span class="line" id="L596">                    self.hash = hash4(self.window[self.index .. self.index + min_match_length]);</span>
<span class="line" id="L597">                    <span class="tok-kw">var</span> hh = &amp;self.hash_head[self.hash &amp; hash_mask];</span>
<span class="line" id="L598">                    self.chain_head = <span class="tok-builtin">@intCast</span>(<span class="tok-type">u32</span>, hh.*);</span>
<span class="line" id="L599">                    self.hash_prev[self.index &amp; window_mask] = <span class="tok-builtin">@intCast</span>(<span class="tok-type">u32</span>, self.chain_head);</span>
<span class="line" id="L600">                    hh.* = <span class="tok-builtin">@intCast</span>(<span class="tok-type">u32</span>, self.index + self.hash_offset);</span>
<span class="line" id="L601">                }</span>
<span class="line" id="L602">                <span class="tok-kw">var</span> prev_length = self.length;</span>
<span class="line" id="L603">                <span class="tok-kw">var</span> prev_offset = self.offset;</span>
<span class="line" id="L604">                self.length = min_match_length - <span class="tok-number">1</span>;</span>
<span class="line" id="L605">                self.offset = <span class="tok-number">0</span>;</span>
<span class="line" id="L606">                <span class="tok-kw">var</span> min_index = self.index -| window_size;</span>
<span class="line" id="L607"></span>
<span class="line" id="L608">                <span class="tok-kw">if</span> (self.hash_offset &lt;= self.chain_head <span class="tok-kw">and</span></span>
<span class="line" id="L609">                    self.chain_head - self.hash_offset &gt;= min_index <span class="tok-kw">and</span></span>
<span class="line" id="L610">                    (self.compression_level.fast_skip_hashshing != skip_never <span class="tok-kw">and</span></span>
<span class="line" id="L611">                    lookahead &gt; min_match_length - <span class="tok-number">1</span> <span class="tok-kw">or</span></span>
<span class="line" id="L612">                    self.compression_level.fast_skip_hashshing == skip_never <span class="tok-kw">and</span></span>
<span class="line" id="L613">                    lookahead &gt; prev_length <span class="tok-kw">and</span></span>
<span class="line" id="L614">                    prev_length &lt; self.compression_level.lazy))</span>
<span class="line" id="L615">                {</span>
<span class="line" id="L616">                    {</span>
<span class="line" id="L617">                        <span class="tok-kw">var</span> fmatch = self.findMatch(</span>
<span class="line" id="L618">                            self.index,</span>
<span class="line" id="L619">                            self.chain_head -| self.hash_offset,</span>
<span class="line" id="L620">                            min_match_length - <span class="tok-number">1</span>,</span>
<span class="line" id="L621">                            <span class="tok-builtin">@intCast</span>(<span class="tok-type">u32</span>, lookahead),</span>
<span class="line" id="L622">                        );</span>
<span class="line" id="L623">                        <span class="tok-kw">if</span> (fmatch.ok) {</span>
<span class="line" id="L624">                            self.length = fmatch.length;</span>
<span class="line" id="L625">                            self.offset = fmatch.offset;</span>
<span class="line" id="L626">                        }</span>
<span class="line" id="L627">                    }</span>
<span class="line" id="L628">                }</span>
<span class="line" id="L629">                <span class="tok-kw">if</span> (self.compression_level.fast_skip_hashshing != skip_never <span class="tok-kw">and</span></span>
<span class="line" id="L630">                    self.length &gt;= min_match_length <span class="tok-kw">or</span></span>
<span class="line" id="L631">                    self.compression_level.fast_skip_hashshing == skip_never <span class="tok-kw">and</span></span>
<span class="line" id="L632">                    prev_length &gt;= min_match_length <span class="tok-kw">and</span></span>
<span class="line" id="L633">                    self.length &lt;= prev_length)</span>
<span class="line" id="L634">                {</span>
<span class="line" id="L635">                    <span class="tok-comment">// There was a match at the previous step, and the current match is</span>
</span>
<span class="line" id="L636">                    <span class="tok-comment">// not better. Output the previous match.</span>
</span>
<span class="line" id="L637">                    <span class="tok-kw">if</span> (self.compression_level.fast_skip_hashshing != skip_never) {</span>
<span class="line" id="L638">                        self.tokens[self.tokens_count] = token.matchToken(<span class="tok-builtin">@intCast</span>(<span class="tok-type">u32</span>, self.length - base_match_length), <span class="tok-builtin">@intCast</span>(<span class="tok-type">u32</span>, self.offset - base_match_offset));</span>
<span class="line" id="L639">                        self.tokens_count += <span class="tok-number">1</span>;</span>
<span class="line" id="L640">                    } <span class="tok-kw">else</span> {</span>
<span class="line" id="L641">                        self.tokens[self.tokens_count] = token.matchToken(</span>
<span class="line" id="L642">                            <span class="tok-builtin">@intCast</span>(<span class="tok-type">u32</span>, prev_length - base_match_length),</span>
<span class="line" id="L643">                            <span class="tok-builtin">@intCast</span>(<span class="tok-type">u32</span>, prev_offset -| base_match_offset),</span>
<span class="line" id="L644">                        );</span>
<span class="line" id="L645">                        self.tokens_count += <span class="tok-number">1</span>;</span>
<span class="line" id="L646">                    }</span>
<span class="line" id="L647">                    <span class="tok-comment">// Insert in the hash table all strings up to the end of the match.</span>
</span>
<span class="line" id="L648">                    <span class="tok-comment">// index and index-1 are already inserted. If there is not enough</span>
</span>
<span class="line" id="L649">                    <span class="tok-comment">// lookahead, the last two strings are not inserted into the hash</span>
</span>
<span class="line" id="L650">                    <span class="tok-comment">// table.</span>
</span>
<span class="line" id="L651">                    <span class="tok-kw">if</span> (self.length &lt;= self.compression_level.fast_skip_hashshing) {</span>
<span class="line" id="L652">                        <span class="tok-kw">var</span> newIndex: <span class="tok-type">u32</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L653">                        <span class="tok-kw">if</span> (self.compression_level.fast_skip_hashshing != skip_never) {</span>
<span class="line" id="L654">                            newIndex = self.index + self.length;</span>
<span class="line" id="L655">                        } <span class="tok-kw">else</span> {</span>
<span class="line" id="L656">                            newIndex = self.index + prev_length - <span class="tok-number">1</span>;</span>
<span class="line" id="L657">                        }</span>
<span class="line" id="L658">                        <span class="tok-kw">var</span> index = self.index;</span>
<span class="line" id="L659">                        index += <span class="tok-number">1</span>;</span>
<span class="line" id="L660">                        <span class="tok-kw">while</span> (index &lt; newIndex) : (index += <span class="tok-number">1</span>) {</span>
<span class="line" id="L661">                            <span class="tok-kw">if</span> (index &lt; self.max_insert_index) {</span>
<span class="line" id="L662">                                self.hash = hash4(self.window[index .. index + min_match_length]);</span>
<span class="line" id="L663">                                <span class="tok-comment">// Get previous value with the same hash.</span>
</span>
<span class="line" id="L664">                                <span class="tok-comment">// Our chain should point to the previous value.</span>
</span>
<span class="line" id="L665">                                <span class="tok-kw">var</span> hh = &amp;self.hash_head[self.hash &amp; hash_mask];</span>
<span class="line" id="L666">                                self.hash_prev[index &amp; window_mask] = hh.*;</span>
<span class="line" id="L667">                                <span class="tok-comment">// Set the head of the hash chain to us.</span>
</span>
<span class="line" id="L668">                                hh.* = <span class="tok-builtin">@intCast</span>(<span class="tok-type">u32</span>, index + self.hash_offset);</span>
<span class="line" id="L669">                            }</span>
<span class="line" id="L670">                        }</span>
<span class="line" id="L671">                        self.index = index;</span>
<span class="line" id="L672"></span>
<span class="line" id="L673">                        <span class="tok-kw">if</span> (self.compression_level.fast_skip_hashshing == skip_never) {</span>
<span class="line" id="L674">                            self.byte_available = <span class="tok-null">false</span>;</span>
<span class="line" id="L675">                            self.length = min_match_length - <span class="tok-number">1</span>;</span>
<span class="line" id="L676">                        }</span>
<span class="line" id="L677">                    } <span class="tok-kw">else</span> {</span>
<span class="line" id="L678">                        <span class="tok-comment">// For matches this long, we don't bother inserting each individual</span>
</span>
<span class="line" id="L679">                        <span class="tok-comment">// item into the table.</span>
</span>
<span class="line" id="L680">                        self.index += self.length;</span>
<span class="line" id="L681">                        <span class="tok-kw">if</span> (self.index &lt; self.max_insert_index) {</span>
<span class="line" id="L682">                            self.hash = hash4(self.window[self.index .. self.index + min_match_length]);</span>
<span class="line" id="L683">                        }</span>
<span class="line" id="L684">                    }</span>
<span class="line" id="L685">                    <span class="tok-kw">if</span> (self.tokens_count == max_flate_block_tokens) {</span>
<span class="line" id="L686">                        <span class="tok-comment">// The block includes the current character</span>
</span>
<span class="line" id="L687">                        <span class="tok-kw">try</span> self.writeBlock(self.tokens[<span class="tok-number">0</span>..self.tokens_count], self.index);</span>
<span class="line" id="L688">                        self.tokens_count = <span class="tok-number">0</span>;</span>
<span class="line" id="L689">                    }</span>
<span class="line" id="L690">                } <span class="tok-kw">else</span> {</span>
<span class="line" id="L691">                    <span class="tok-kw">if</span> (self.compression_level.fast_skip_hashshing != skip_never <span class="tok-kw">or</span> self.byte_available) {</span>
<span class="line" id="L692">                        <span class="tok-kw">var</span> i = self.index -| <span class="tok-number">1</span>;</span>
<span class="line" id="L693">                        <span class="tok-kw">if</span> (self.compression_level.fast_skip_hashshing != skip_never) {</span>
<span class="line" id="L694">                            i = self.index;</span>
<span class="line" id="L695">                        }</span>
<span class="line" id="L696">                        self.tokens[self.tokens_count] = token.literalToken(<span class="tok-builtin">@intCast</span>(<span class="tok-type">u32</span>, self.window[i]));</span>
<span class="line" id="L697">                        self.tokens_count += <span class="tok-number">1</span>;</span>
<span class="line" id="L698">                        <span class="tok-kw">if</span> (self.tokens_count == max_flate_block_tokens) {</span>
<span class="line" id="L699">                            <span class="tok-kw">try</span> self.writeBlock(self.tokens[<span class="tok-number">0</span>..self.tokens_count], i + <span class="tok-number">1</span>);</span>
<span class="line" id="L700">                            self.tokens_count = <span class="tok-number">0</span>;</span>
<span class="line" id="L701">                        }</span>
<span class="line" id="L702">                    }</span>
<span class="line" id="L703">                    self.index += <span class="tok-number">1</span>;</span>
<span class="line" id="L704">                    <span class="tok-kw">if</span> (self.compression_level.fast_skip_hashshing == skip_never) {</span>
<span class="line" id="L705">                        self.byte_available = <span class="tok-null">true</span>;</span>
<span class="line" id="L706">                    }</span>
<span class="line" id="L707">                }</span>
<span class="line" id="L708">            }</span>
<span class="line" id="L709">        }</span>
<span class="line" id="L710"></span>
<span class="line" id="L711">        <span class="tok-kw">fn</span> <span class="tok-fn">fillStore</span>(self: *Self, b: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) <span class="tok-type">u32</span> {</span>
<span class="line" id="L712">            <span class="tok-kw">var</span> n = mu.copy(self.window[self.window_end..], b);</span>
<span class="line" id="L713">            self.window_end += n;</span>
<span class="line" id="L714">            <span class="tok-kw">return</span> <span class="tok-builtin">@intCast</span>(<span class="tok-type">u32</span>, n);</span>
<span class="line" id="L715">        }</span>
<span class="line" id="L716"></span>
<span class="line" id="L717">        <span class="tok-kw">fn</span> <span class="tok-fn">store</span>(self: *Self) !<span class="tok-type">void</span> {</span>
<span class="line" id="L718">            <span class="tok-kw">if</span> (self.window_end &gt; <span class="tok-number">0</span> <span class="tok-kw">and</span> (self.window_end == max_store_block_size <span class="tok-kw">or</span> self.sync)) {</span>
<span class="line" id="L719">                <span class="tok-kw">try</span> self.writeStoredBlock(self.window[<span class="tok-number">0</span>..self.window_end]);</span>
<span class="line" id="L720">                self.window_end = <span class="tok-number">0</span>;</span>
<span class="line" id="L721">            }</span>
<span class="line" id="L722">        }</span>
<span class="line" id="L723"></span>
<span class="line" id="L724">        <span class="tok-comment">// storeHuff compresses and stores the currently added data</span>
</span>
<span class="line" id="L725">        <span class="tok-comment">// when the self.window is full or we are at the end of the stream.</span>
</span>
<span class="line" id="L726">        <span class="tok-kw">fn</span> <span class="tok-fn">storeHuff</span>(self: *Self) !<span class="tok-type">void</span> {</span>
<span class="line" id="L727">            <span class="tok-kw">if</span> (self.window_end &lt; self.window.len <span class="tok-kw">and</span> !self.sync <span class="tok-kw">or</span> self.window_end == <span class="tok-number">0</span>) {</span>
<span class="line" id="L728">                <span class="tok-kw">return</span>;</span>
<span class="line" id="L729">            }</span>
<span class="line" id="L730">            <span class="tok-kw">try</span> self.hm_bw.writeBlockHuff(<span class="tok-null">false</span>, self.window[<span class="tok-number">0</span>..self.window_end]);</span>
<span class="line" id="L731">            self.err = self.hm_bw.err;</span>
<span class="line" id="L732">            self.window_end = <span class="tok-number">0</span>;</span>
<span class="line" id="L733">        }</span>
<span class="line" id="L734"></span>
<span class="line" id="L735">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">bytesWritten</span>(self: *Self) <span class="tok-type">usize</span> {</span>
<span class="line" id="L736">            <span class="tok-kw">return</span> self.hm_bw.bytes_written;</span>
<span class="line" id="L737">        }</span>
<span class="line" id="L738"></span>
<span class="line" id="L739">        <span class="tok-comment">/// Writes the compressed form of `input` to the underlying writer.</span></span>
<span class="line" id="L740">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">write</span>(self: *Self, input: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) !<span class="tok-type">usize</span> {</span>
<span class="line" id="L741">            <span class="tok-kw">var</span> buf = input;</span>
<span class="line" id="L742"></span>
<span class="line" id="L743">            <span class="tok-comment">// writes data to hm_bw, which will eventually write the</span>
</span>
<span class="line" id="L744">            <span class="tok-comment">// compressed form of data to its underlying writer.</span>
</span>
<span class="line" id="L745">            <span class="tok-kw">while</span> (buf.len &gt; <span class="tok-number">0</span>) {</span>
<span class="line" id="L746">                <span class="tok-kw">try</span> self.step();</span>
<span class="line" id="L747">                <span class="tok-kw">var</span> filled = self.fill(buf);</span>
<span class="line" id="L748">                buf = buf[filled..];</span>
<span class="line" id="L749">            }</span>
<span class="line" id="L750"></span>
<span class="line" id="L751">            <span class="tok-kw">return</span> input.len;</span>
<span class="line" id="L752">        }</span>
<span class="line" id="L753"></span>
<span class="line" id="L754">        <span class="tok-comment">/// Flushes any pending data to the underlying writer.</span></span>
<span class="line" id="L755">        <span class="tok-comment">/// It is useful mainly in compressed network protocols, to ensure that</span></span>
<span class="line" id="L756">        <span class="tok-comment">/// a remote reader has enough data to reconstruct a packet.</span></span>
<span class="line" id="L757">        <span class="tok-comment">/// Flush does not return until the data has been written.</span></span>
<span class="line" id="L758">        <span class="tok-comment">/// Calling `flush()` when there is no pending data still causes the Writer</span></span>
<span class="line" id="L759">        <span class="tok-comment">/// to emit a sync marker of at least 4 bytes.</span></span>
<span class="line" id="L760">        <span class="tok-comment">/// If the underlying writer returns an error, `flush()` returns that error.</span></span>
<span class="line" id="L761">        <span class="tok-comment">///</span></span>
<span class="line" id="L762">        <span class="tok-comment">/// In the terminology of the zlib library, Flush is equivalent to Z_SYNC_FLUSH.</span></span>
<span class="line" id="L763">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">flush</span>(self: *Self) !<span class="tok-type">void</span> {</span>
<span class="line" id="L764">            self.sync = <span class="tok-null">true</span>;</span>
<span class="line" id="L765">            <span class="tok-kw">try</span> self.step();</span>
<span class="line" id="L766">            <span class="tok-kw">try</span> self.hm_bw.writeStoredHeader(<span class="tok-number">0</span>, <span class="tok-null">false</span>);</span>
<span class="line" id="L767">            <span class="tok-kw">try</span> self.hm_bw.flush();</span>
<span class="line" id="L768">            self.sync = <span class="tok-null">false</span>;</span>
<span class="line" id="L769">            <span class="tok-kw">return</span>;</span>
<span class="line" id="L770">        }</span>
<span class="line" id="L771"></span>
<span class="line" id="L772">        <span class="tok-kw">fn</span> <span class="tok-fn">step</span>(self: *Self) !<span class="tok-type">void</span> {</span>
<span class="line" id="L773">            <span class="tok-kw">switch</span> (self.compression) {</span>
<span class="line" id="L774">                .no_compression =&gt; <span class="tok-kw">return</span> self.store(),</span>
<span class="line" id="L775">                .huffman_only =&gt; <span class="tok-kw">return</span> self.storeHuff(),</span>
<span class="line" id="L776">                .best_speed =&gt; <span class="tok-kw">return</span> self.encSpeed(),</span>
<span class="line" id="L777">                .default_compression,</span>
<span class="line" id="L778">                .level_2,</span>
<span class="line" id="L779">                .level_3,</span>
<span class="line" id="L780">                .level_4,</span>
<span class="line" id="L781">                .level_5,</span>
<span class="line" id="L782">                .level_6,</span>
<span class="line" id="L783">                .level_7,</span>
<span class="line" id="L784">                .level_8,</span>
<span class="line" id="L785">                .best_compression,</span>
<span class="line" id="L786">                =&gt; <span class="tok-kw">return</span> self.deflate(),</span>
<span class="line" id="L787">            }</span>
<span class="line" id="L788">        }</span>
<span class="line" id="L789"></span>
<span class="line" id="L790">        <span class="tok-kw">fn</span> <span class="tok-fn">fill</span>(self: *Self, b: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) <span class="tok-type">u32</span> {</span>
<span class="line" id="L791">            <span class="tok-kw">switch</span> (self.compression) {</span>
<span class="line" id="L792">                .no_compression =&gt; <span class="tok-kw">return</span> self.fillStore(b),</span>
<span class="line" id="L793">                .huffman_only =&gt; <span class="tok-kw">return</span> self.fillStore(b),</span>
<span class="line" id="L794">                .best_speed =&gt; <span class="tok-kw">return</span> self.fillStore(b),</span>
<span class="line" id="L795">                .default_compression,</span>
<span class="line" id="L796">                .level_2,</span>
<span class="line" id="L797">                .level_3,</span>
<span class="line" id="L798">                .level_4,</span>
<span class="line" id="L799">                .level_5,</span>
<span class="line" id="L800">                .level_6,</span>
<span class="line" id="L801">                .level_7,</span>
<span class="line" id="L802">                .level_8,</span>
<span class="line" id="L803">                .best_compression,</span>
<span class="line" id="L804">                =&gt; <span class="tok-kw">return</span> self.fillDeflate(b),</span>
<span class="line" id="L805">            }</span>
<span class="line" id="L806">        }</span>
<span class="line" id="L807"></span>
<span class="line" id="L808">        <span class="tok-kw">fn</span> <span class="tok-fn">init</span>(</span>
<span class="line" id="L809">            allocator: Allocator,</span>
<span class="line" id="L810">            in_writer: WriterType,</span>
<span class="line" id="L811">            options: CompressorOptions,</span>
<span class="line" id="L812">        ) !Self {</span>
<span class="line" id="L813">            <span class="tok-kw">var</span> s = Self{</span>
<span class="line" id="L814">                .allocator = <span class="tok-null">undefined</span>,</span>
<span class="line" id="L815">                .compression = <span class="tok-null">undefined</span>,</span>
<span class="line" id="L816">                .compression_level = <span class="tok-null">undefined</span>,</span>
<span class="line" id="L817">                .hm_bw = <span class="tok-null">undefined</span>, <span class="tok-comment">// HuffmanBitWriter</span>
</span>
<span class="line" id="L818">                .bulk_hasher = <span class="tok-null">undefined</span>,</span>
<span class="line" id="L819">                .sync = <span class="tok-null">false</span>,</span>
<span class="line" id="L820">                .best_speed_enc = <span class="tok-null">undefined</span>, <span class="tok-comment">// Best speed encoder</span>
</span>
<span class="line" id="L821">                .chain_head = <span class="tok-number">0</span>,</span>
<span class="line" id="L822">                .hash_head = <span class="tok-null">undefined</span>,</span>
<span class="line" id="L823">                .hash_prev = <span class="tok-null">undefined</span>, <span class="tok-comment">// previous hash</span>
</span>
<span class="line" id="L824">                .hash_offset = <span class="tok-number">0</span>,</span>
<span class="line" id="L825">                .index = <span class="tok-number">0</span>,</span>
<span class="line" id="L826">                .window = <span class="tok-null">undefined</span>,</span>
<span class="line" id="L827">                .window_end = <span class="tok-number">0</span>,</span>
<span class="line" id="L828">                .block_start = <span class="tok-number">0</span>,</span>
<span class="line" id="L829">                .byte_available = <span class="tok-null">false</span>,</span>
<span class="line" id="L830">                .tokens = <span class="tok-null">undefined</span>,</span>
<span class="line" id="L831">                .tokens_count = <span class="tok-number">0</span>,</span>
<span class="line" id="L832">                .length = <span class="tok-number">0</span>,</span>
<span class="line" id="L833">                .offset = <span class="tok-number">0</span>,</span>
<span class="line" id="L834">                .hash = <span class="tok-number">0</span>,</span>
<span class="line" id="L835">                .max_insert_index = <span class="tok-number">0</span>,</span>
<span class="line" id="L836">                .err = <span class="tok-null">false</span>, <span class="tok-comment">// Error</span>
</span>
<span class="line" id="L837">                .hash_match = <span class="tok-null">undefined</span>,</span>
<span class="line" id="L838">                .dictionary = options.dictionary,</span>
<span class="line" id="L839">            };</span>
<span class="line" id="L840"></span>
<span class="line" id="L841">            s.hm_bw = <span class="tok-kw">try</span> hm_bw.huffmanBitWriter(allocator, in_writer);</span>
<span class="line" id="L842">            s.allocator = allocator;</span>
<span class="line" id="L843"></span>
<span class="line" id="L844">            s.hash_head = <span class="tok-kw">try</span> allocator.alloc(<span class="tok-type">u32</span>, hash_size);</span>
<span class="line" id="L845">            s.hash_prev = <span class="tok-kw">try</span> allocator.alloc(<span class="tok-type">u32</span>, window_size);</span>
<span class="line" id="L846">            s.hash_match = <span class="tok-kw">try</span> allocator.alloc(<span class="tok-type">u32</span>, max_match_length - <span class="tok-number">1</span>);</span>
<span class="line" id="L847">            mem.set(<span class="tok-type">u32</span>, s.hash_head, <span class="tok-number">0</span>);</span>
<span class="line" id="L848">            mem.set(<span class="tok-type">u32</span>, s.hash_prev, <span class="tok-number">0</span>);</span>
<span class="line" id="L849">            mem.set(<span class="tok-type">u32</span>, s.hash_match, <span class="tok-number">0</span>);</span>
<span class="line" id="L850"></span>
<span class="line" id="L851">            <span class="tok-kw">switch</span> (options.level) {</span>
<span class="line" id="L852">                .no_compression =&gt; {</span>
<span class="line" id="L853">                    s.compression = options.level;</span>
<span class="line" id="L854">                    s.compression_level = levels(options.level);</span>
<span class="line" id="L855">                    s.window = <span class="tok-kw">try</span> allocator.alloc(<span class="tok-type">u8</span>, max_store_block_size);</span>
<span class="line" id="L856">                    s.tokens = <span class="tok-kw">try</span> allocator.alloc(token.Token, <span class="tok-number">0</span>);</span>
<span class="line" id="L857">                },</span>
<span class="line" id="L858">                .huffman_only =&gt; {</span>
<span class="line" id="L859">                    s.compression = options.level;</span>
<span class="line" id="L860">                    s.compression_level = levels(options.level);</span>
<span class="line" id="L861">                    s.window = <span class="tok-kw">try</span> allocator.alloc(<span class="tok-type">u8</span>, max_store_block_size);</span>
<span class="line" id="L862">                    s.tokens = <span class="tok-kw">try</span> allocator.alloc(token.Token, <span class="tok-number">0</span>);</span>
<span class="line" id="L863">                },</span>
<span class="line" id="L864">                .best_speed =&gt; {</span>
<span class="line" id="L865">                    s.compression = options.level;</span>
<span class="line" id="L866">                    s.compression_level = levels(options.level);</span>
<span class="line" id="L867">                    s.window = <span class="tok-kw">try</span> allocator.alloc(<span class="tok-type">u8</span>, max_store_block_size);</span>
<span class="line" id="L868">                    s.tokens = <span class="tok-kw">try</span> allocator.alloc(token.Token, max_store_block_size);</span>
<span class="line" id="L869">                    s.best_speed_enc = <span class="tok-kw">try</span> allocator.create(fast.DeflateFast);</span>
<span class="line" id="L870">                    s.best_speed_enc.* = fast.deflateFast();</span>
<span class="line" id="L871">                    <span class="tok-kw">try</span> s.best_speed_enc.init(allocator);</span>
<span class="line" id="L872">                },</span>
<span class="line" id="L873">                .default_compression =&gt; {</span>
<span class="line" id="L874">                    s.compression = .level_6;</span>
<span class="line" id="L875">                    s.compression_level = levels(.level_6);</span>
<span class="line" id="L876">                    <span class="tok-kw">try</span> s.initDeflate();</span>
<span class="line" id="L877">                    <span class="tok-kw">if</span> (options.dictionary != <span class="tok-null">null</span>) {</span>
<span class="line" id="L878">                        s.fillWindow(options.dictionary.?);</span>
<span class="line" id="L879">                    }</span>
<span class="line" id="L880">                },</span>
<span class="line" id="L881">                .level_2,</span>
<span class="line" id="L882">                .level_3,</span>
<span class="line" id="L883">                .level_4,</span>
<span class="line" id="L884">                .level_5,</span>
<span class="line" id="L885">                .level_6,</span>
<span class="line" id="L886">                .level_7,</span>
<span class="line" id="L887">                .level_8,</span>
<span class="line" id="L888">                .best_compression,</span>
<span class="line" id="L889">                =&gt; {</span>
<span class="line" id="L890">                    s.compression = options.level;</span>
<span class="line" id="L891">                    s.compression_level = levels(options.level);</span>
<span class="line" id="L892">                    <span class="tok-kw">try</span> s.initDeflate();</span>
<span class="line" id="L893">                    <span class="tok-kw">if</span> (options.dictionary != <span class="tok-null">null</span>) {</span>
<span class="line" id="L894">                        s.fillWindow(options.dictionary.?);</span>
<span class="line" id="L895">                    }</span>
<span class="line" id="L896">                },</span>
<span class="line" id="L897">            }</span>
<span class="line" id="L898">            <span class="tok-kw">return</span> s;</span>
<span class="line" id="L899">        }</span>
<span class="line" id="L900"></span>
<span class="line" id="L901">        <span class="tok-comment">/// Release all allocated memory.</span></span>
<span class="line" id="L902">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">deinit</span>(self: *Self) <span class="tok-type">void</span> {</span>
<span class="line" id="L903">            self.hm_bw.deinit();</span>
<span class="line" id="L904">            self.allocator.free(self.window);</span>
<span class="line" id="L905">            self.allocator.free(self.tokens);</span>
<span class="line" id="L906">            self.allocator.free(self.hash_head);</span>
<span class="line" id="L907">            self.allocator.free(self.hash_prev);</span>
<span class="line" id="L908">            self.allocator.free(self.hash_match);</span>
<span class="line" id="L909">            <span class="tok-kw">if</span> (self.compression == .best_speed) {</span>
<span class="line" id="L910">                self.best_speed_enc.deinit();</span>
<span class="line" id="L911">                self.allocator.destroy(self.best_speed_enc);</span>
<span class="line" id="L912">            }</span>
<span class="line" id="L913">        }</span>
<span class="line" id="L914"></span>
<span class="line" id="L915">        <span class="tok-comment">/// Reset discards the inner writer's state and replace the inner writer with new_writer.</span></span>
<span class="line" id="L916">        <span class="tok-comment">/// new_writer must be of the same type as the previous writer.</span></span>
<span class="line" id="L917">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">reset</span>(self: *Self, new_writer: WriterType) <span class="tok-type">void</span> {</span>
<span class="line" id="L918">            self.hm_bw.reset(new_writer);</span>
<span class="line" id="L919">            self.sync = <span class="tok-null">false</span>;</span>
<span class="line" id="L920">            <span class="tok-kw">switch</span> (self.compression) {</span>
<span class="line" id="L921">                <span class="tok-comment">// Reset window</span>
</span>
<span class="line" id="L922">                .no_compression =&gt; self.window_end = <span class="tok-number">0</span>,</span>
<span class="line" id="L923">                <span class="tok-comment">// Reset window, tokens, and encoder</span>
</span>
<span class="line" id="L924">                .best_speed =&gt; {</span>
<span class="line" id="L925">                    self.window_end = <span class="tok-number">0</span>;</span>
<span class="line" id="L926">                    self.tokens_count = <span class="tok-number">0</span>;</span>
<span class="line" id="L927">                    self.best_speed_enc.reset();</span>
<span class="line" id="L928">                },</span>
<span class="line" id="L929">                <span class="tok-comment">// Reset everything and reinclude the dictionary if there is one</span>
</span>
<span class="line" id="L930">                .huffman_only,</span>
<span class="line" id="L931">                .default_compression,</span>
<span class="line" id="L932">                .level_2,</span>
<span class="line" id="L933">                .level_3,</span>
<span class="line" id="L934">                .level_4,</span>
<span class="line" id="L935">                .level_5,</span>
<span class="line" id="L936">                .level_6,</span>
<span class="line" id="L937">                .level_7,</span>
<span class="line" id="L938">                .level_8,</span>
<span class="line" id="L939">                .best_compression,</span>
<span class="line" id="L940">                =&gt; {</span>
<span class="line" id="L941">                    self.chain_head = <span class="tok-number">0</span>;</span>
<span class="line" id="L942">                    mem.set(<span class="tok-type">u32</span>, self.hash_head, <span class="tok-number">0</span>);</span>
<span class="line" id="L943">                    mem.set(<span class="tok-type">u32</span>, self.hash_prev, <span class="tok-number">0</span>);</span>
<span class="line" id="L944">                    self.hash_offset = <span class="tok-number">1</span>;</span>
<span class="line" id="L945">                    self.index = <span class="tok-number">0</span>;</span>
<span class="line" id="L946">                    self.window_end = <span class="tok-number">0</span>;</span>
<span class="line" id="L947">                    self.block_start = <span class="tok-number">0</span>;</span>
<span class="line" id="L948">                    self.byte_available = <span class="tok-null">false</span>;</span>
<span class="line" id="L949">                    self.tokens_count = <span class="tok-number">0</span>;</span>
<span class="line" id="L950">                    self.length = min_match_length - <span class="tok-number">1</span>;</span>
<span class="line" id="L951">                    self.offset = <span class="tok-number">0</span>;</span>
<span class="line" id="L952">                    self.hash = <span class="tok-number">0</span>;</span>
<span class="line" id="L953">                    self.max_insert_index = <span class="tok-number">0</span>;</span>
<span class="line" id="L954"></span>
<span class="line" id="L955">                    <span class="tok-kw">if</span> (self.dictionary != <span class="tok-null">null</span>) {</span>
<span class="line" id="L956">                        self.fillWindow(self.dictionary.?);</span>
<span class="line" id="L957">                    }</span>
<span class="line" id="L958">                },</span>
<span class="line" id="L959">            }</span>
<span class="line" id="L960">        }</span>
<span class="line" id="L961"></span>
<span class="line" id="L962">        <span class="tok-comment">/// Writes any pending data to the underlying writer.</span></span>
<span class="line" id="L963">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">close</span>(self: *Self) !<span class="tok-type">void</span> {</span>
<span class="line" id="L964">            self.sync = <span class="tok-null">true</span>;</span>
<span class="line" id="L965">            <span class="tok-kw">try</span> self.step();</span>
<span class="line" id="L966">            <span class="tok-kw">try</span> self.hm_bw.writeStoredHeader(<span class="tok-number">0</span>, <span class="tok-null">true</span>);</span>
<span class="line" id="L967">            <span class="tok-kw">try</span> self.hm_bw.flush();</span>
<span class="line" id="L968">            <span class="tok-kw">return</span>;</span>
<span class="line" id="L969">        }</span>
<span class="line" id="L970">    };</span>
<span class="line" id="L971">}</span>
<span class="line" id="L972"></span>
<span class="line" id="L973"><span class="tok-comment">// tests</span>
</span>
<span class="line" id="L974"></span>
<span class="line" id="L975"><span class="tok-kw">const</span> expect = std.testing.expect;</span>
<span class="line" id="L976"><span class="tok-kw">const</span> testing = std.testing;</span>
<span class="line" id="L977"></span>
<span class="line" id="L978"><span class="tok-kw">const</span> ArrayList = std.ArrayList;</span>
<span class="line" id="L979"></span>
<span class="line" id="L980"><span class="tok-kw">const</span> DeflateTest = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L981">    in: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L982">    level: Compression,</span>
<span class="line" id="L983">    out: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L984">};</span>
<span class="line" id="L985"></span>
<span class="line" id="L986"><span class="tok-kw">var</span> deflate_tests = [_]DeflateTest{</span>
<span class="line" id="L987">    <span class="tok-comment">// Level 0</span>
</span>
<span class="line" id="L988">    .{</span>
<span class="line" id="L989">        .in = &amp;[_]<span class="tok-type">u8</span>{},</span>
<span class="line" id="L990">        .level = .no_compression,</span>
<span class="line" id="L991">        .out = &amp;[_]<span class="tok-type">u8</span>{ <span class="tok-number">1</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">255</span>, <span class="tok-number">255</span> },</span>
<span class="line" id="L992">    },</span>
<span class="line" id="L993"></span>
<span class="line" id="L994">    <span class="tok-comment">// Level -1</span>
</span>
<span class="line" id="L995">    .{</span>
<span class="line" id="L996">        .in = &amp;[_]<span class="tok-type">u8</span>{<span class="tok-number">0x11</span>},</span>
<span class="line" id="L997">        .level = .default_compression,</span>
<span class="line" id="L998">        .out = &amp;[_]<span class="tok-type">u8</span>{ <span class="tok-number">18</span>, <span class="tok-number">4</span>, <span class="tok-number">4</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">255</span>, <span class="tok-number">255</span> },</span>
<span class="line" id="L999">    },</span>
<span class="line" id="L1000">    .{</span>
<span class="line" id="L1001">        .in = &amp;[_]<span class="tok-type">u8</span>{<span class="tok-number">0x11</span>},</span>
<span class="line" id="L1002">        .level = .level_6,</span>
<span class="line" id="L1003">        .out = &amp;[_]<span class="tok-type">u8</span>{ <span class="tok-number">18</span>, <span class="tok-number">4</span>, <span class="tok-number">4</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">255</span>, <span class="tok-number">255</span> },</span>
<span class="line" id="L1004">    },</span>
<span class="line" id="L1005"></span>
<span class="line" id="L1006">    <span class="tok-comment">// Level 4</span>
</span>
<span class="line" id="L1007">    .{</span>
<span class="line" id="L1008">        .in = &amp;[_]<span class="tok-type">u8</span>{<span class="tok-number">0x11</span>},</span>
<span class="line" id="L1009">        .level = .level_4,</span>
<span class="line" id="L1010">        .out = &amp;[_]<span class="tok-type">u8</span>{ <span class="tok-number">18</span>, <span class="tok-number">4</span>, <span class="tok-number">4</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">255</span>, <span class="tok-number">255</span> },</span>
<span class="line" id="L1011">    },</span>
<span class="line" id="L1012"></span>
<span class="line" id="L1013">    <span class="tok-comment">// Level 0</span>
</span>
<span class="line" id="L1014">    .{</span>
<span class="line" id="L1015">        .in = &amp;[_]<span class="tok-type">u8</span>{<span class="tok-number">0x11</span>},</span>
<span class="line" id="L1016">        .level = .no_compression,</span>
<span class="line" id="L1017">        .out = &amp;[_]<span class="tok-type">u8</span>{ <span class="tok-number">0</span>, <span class="tok-number">1</span>, <span class="tok-number">0</span>, <span class="tok-number">254</span>, <span class="tok-number">255</span>, <span class="tok-number">17</span>, <span class="tok-number">1</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">255</span>, <span class="tok-number">255</span> },</span>
<span class="line" id="L1018">    },</span>
<span class="line" id="L1019">    .{</span>
<span class="line" id="L1020">        .in = &amp;[_]<span class="tok-type">u8</span>{ <span class="tok-number">0x11</span>, <span class="tok-number">0x12</span> },</span>
<span class="line" id="L1021">        .level = .no_compression,</span>
<span class="line" id="L1022">        .out = &amp;[_]<span class="tok-type">u8</span>{ <span class="tok-number">0</span>, <span class="tok-number">2</span>, <span class="tok-number">0</span>, <span class="tok-number">253</span>, <span class="tok-number">255</span>, <span class="tok-number">17</span>, <span class="tok-number">18</span>, <span class="tok-number">1</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">255</span>, <span class="tok-number">255</span> },</span>
<span class="line" id="L1023">    },</span>
<span class="line" id="L1024">    .{</span>
<span class="line" id="L1025">        .in = &amp;[_]<span class="tok-type">u8</span>{ <span class="tok-number">0x11</span>, <span class="tok-number">0x11</span>, <span class="tok-number">0x11</span>, <span class="tok-number">0x11</span>, <span class="tok-number">0x11</span>, <span class="tok-number">0x11</span>, <span class="tok-number">0x11</span>, <span class="tok-number">0x11</span> },</span>
<span class="line" id="L1026">        .level = .no_compression,</span>
<span class="line" id="L1027">        .out = &amp;[_]<span class="tok-type">u8</span>{ <span class="tok-number">0</span>, <span class="tok-number">8</span>, <span class="tok-number">0</span>, <span class="tok-number">247</span>, <span class="tok-number">255</span>, <span class="tok-number">17</span>, <span class="tok-number">17</span>, <span class="tok-number">17</span>, <span class="tok-number">17</span>, <span class="tok-number">17</span>, <span class="tok-number">17</span>, <span class="tok-number">17</span>, <span class="tok-number">17</span>, <span class="tok-number">1</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">255</span>, <span class="tok-number">255</span> },</span>
<span class="line" id="L1028">    },</span>
<span class="line" id="L1029"></span>
<span class="line" id="L1030">    <span class="tok-comment">// Level 2</span>
</span>
<span class="line" id="L1031">    .{</span>
<span class="line" id="L1032">        .in = &amp;[_]<span class="tok-type">u8</span>{},</span>
<span class="line" id="L1033">        .level = .level_2,</span>
<span class="line" id="L1034">        .out = &amp;[_]<span class="tok-type">u8</span>{ <span class="tok-number">1</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">255</span>, <span class="tok-number">255</span> },</span>
<span class="line" id="L1035">    },</span>
<span class="line" id="L1036">    .{</span>
<span class="line" id="L1037">        .in = &amp;[_]<span class="tok-type">u8</span>{<span class="tok-number">0x11</span>},</span>
<span class="line" id="L1038">        .level = .level_2,</span>
<span class="line" id="L1039">        .out = &amp;[_]<span class="tok-type">u8</span>{ <span class="tok-number">18</span>, <span class="tok-number">4</span>, <span class="tok-number">4</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">255</span>, <span class="tok-number">255</span> },</span>
<span class="line" id="L1040">    },</span>
<span class="line" id="L1041">    .{</span>
<span class="line" id="L1042">        .in = &amp;[_]<span class="tok-type">u8</span>{ <span class="tok-number">0x11</span>, <span class="tok-number">0x12</span> },</span>
<span class="line" id="L1043">        .level = .level_2,</span>
<span class="line" id="L1044">        .out = &amp;[_]<span class="tok-type">u8</span>{ <span class="tok-number">18</span>, <span class="tok-number">20</span>, <span class="tok-number">2</span>, <span class="tok-number">4</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">255</span>, <span class="tok-number">255</span> },</span>
<span class="line" id="L1045">    },</span>
<span class="line" id="L1046">    .{</span>
<span class="line" id="L1047">        .in = &amp;[_]<span class="tok-type">u8</span>{ <span class="tok-number">0x11</span>, <span class="tok-number">0x11</span>, <span class="tok-number">0x11</span>, <span class="tok-number">0x11</span>, <span class="tok-number">0x11</span>, <span class="tok-number">0x11</span>, <span class="tok-number">0x11</span>, <span class="tok-number">0x11</span> },</span>
<span class="line" id="L1048">        .level = .level_2,</span>
<span class="line" id="L1049">        .out = &amp;[_]<span class="tok-type">u8</span>{ <span class="tok-number">18</span>, <span class="tok-number">132</span>, <span class="tok-number">2</span>, <span class="tok-number">64</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">255</span>, <span class="tok-number">255</span> },</span>
<span class="line" id="L1050">    },</span>
<span class="line" id="L1051"></span>
<span class="line" id="L1052">    <span class="tok-comment">// Level 9</span>
</span>
<span class="line" id="L1053">    .{</span>
<span class="line" id="L1054">        .in = &amp;[_]<span class="tok-type">u8</span>{},</span>
<span class="line" id="L1055">        .level = .best_compression,</span>
<span class="line" id="L1056">        .out = &amp;[_]<span class="tok-type">u8</span>{ <span class="tok-number">1</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">255</span>, <span class="tok-number">255</span> },</span>
<span class="line" id="L1057">    },</span>
<span class="line" id="L1058">    .{</span>
<span class="line" id="L1059">        .in = &amp;[_]<span class="tok-type">u8</span>{<span class="tok-number">0x11</span>},</span>
<span class="line" id="L1060">        .level = .best_compression,</span>
<span class="line" id="L1061">        .out = &amp;[_]<span class="tok-type">u8</span>{ <span class="tok-number">18</span>, <span class="tok-number">4</span>, <span class="tok-number">4</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">255</span>, <span class="tok-number">255</span> },</span>
<span class="line" id="L1062">    },</span>
<span class="line" id="L1063">    .{</span>
<span class="line" id="L1064">        .in = &amp;[_]<span class="tok-type">u8</span>{ <span class="tok-number">0x11</span>, <span class="tok-number">0x12</span> },</span>
<span class="line" id="L1065">        .level = .best_compression,</span>
<span class="line" id="L1066">        .out = &amp;[_]<span class="tok-type">u8</span>{ <span class="tok-number">18</span>, <span class="tok-number">20</span>, <span class="tok-number">2</span>, <span class="tok-number">4</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">255</span>, <span class="tok-number">255</span> },</span>
<span class="line" id="L1067">    },</span>
<span class="line" id="L1068">    .{</span>
<span class="line" id="L1069">        .in = &amp;[_]<span class="tok-type">u8</span>{ <span class="tok-number">0x11</span>, <span class="tok-number">0x11</span>, <span class="tok-number">0x11</span>, <span class="tok-number">0x11</span>, <span class="tok-number">0x11</span>, <span class="tok-number">0x11</span>, <span class="tok-number">0x11</span>, <span class="tok-number">0x11</span> },</span>
<span class="line" id="L1070">        .level = .best_compression,</span>
<span class="line" id="L1071">        .out = &amp;[_]<span class="tok-type">u8</span>{ <span class="tok-number">18</span>, <span class="tok-number">132</span>, <span class="tok-number">2</span>, <span class="tok-number">64</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">255</span>, <span class="tok-number">255</span> },</span>
<span class="line" id="L1072">    },</span>
<span class="line" id="L1073">};</span>
<span class="line" id="L1074"></span>
<span class="line" id="L1075"><span class="tok-kw">test</span> <span class="tok-str">&quot;deflate&quot;</span> {</span>
<span class="line" id="L1076">    <span class="tok-kw">for</span> (deflate_tests) |dt| {</span>
<span class="line" id="L1077">        <span class="tok-kw">var</span> output = ArrayList(<span class="tok-type">u8</span>).init(testing.allocator);</span>
<span class="line" id="L1078">        <span class="tok-kw">defer</span> output.deinit();</span>
<span class="line" id="L1079"></span>
<span class="line" id="L1080">        <span class="tok-kw">var</span> comp = <span class="tok-kw">try</span> compressor(testing.allocator, output.writer(), .{ .level = dt.level });</span>
<span class="line" id="L1081">        _ = <span class="tok-kw">try</span> comp.write(dt.in);</span>
<span class="line" id="L1082">        <span class="tok-kw">try</span> comp.close();</span>
<span class="line" id="L1083">        comp.deinit();</span>
<span class="line" id="L1084"></span>
<span class="line" id="L1085">        <span class="tok-kw">try</span> expect(mem.eql(<span class="tok-type">u8</span>, output.items, dt.out));</span>
<span class="line" id="L1086">    }</span>
<span class="line" id="L1087">}</span>
<span class="line" id="L1088"></span>
<span class="line" id="L1089"><span class="tok-kw">test</span> <span class="tok-str">&quot;bulkHash4&quot;</span> {</span>
<span class="line" id="L1090">    <span class="tok-kw">for</span> (deflate_tests) |x| {</span>
<span class="line" id="L1091">        <span class="tok-kw">if</span> (x.out.len &lt; min_match_length) {</span>
<span class="line" id="L1092">            <span class="tok-kw">continue</span>;</span>
<span class="line" id="L1093">        }</span>
<span class="line" id="L1094">        <span class="tok-comment">// double the test data</span>
</span>
<span class="line" id="L1095">        <span class="tok-kw">var</span> out = <span class="tok-kw">try</span> testing.allocator.alloc(<span class="tok-type">u8</span>, x.out.len * <span class="tok-number">2</span>);</span>
<span class="line" id="L1096">        <span class="tok-kw">defer</span> testing.allocator.free(out);</span>
<span class="line" id="L1097">        mem.copy(<span class="tok-type">u8</span>, out[<span class="tok-number">0</span>..x.out.len], x.out);</span>
<span class="line" id="L1098">        mem.copy(<span class="tok-type">u8</span>, out[x.out.len..], x.out);</span>
<span class="line" id="L1099"></span>
<span class="line" id="L1100">        <span class="tok-kw">var</span> j: <span class="tok-type">usize</span> = <span class="tok-number">4</span>;</span>
<span class="line" id="L1101">        <span class="tok-kw">while</span> (j &lt; out.len) : (j += <span class="tok-number">1</span>) {</span>
<span class="line" id="L1102">            <span class="tok-kw">var</span> y = out[<span class="tok-number">0</span>..j];</span>
<span class="line" id="L1103"></span>
<span class="line" id="L1104">            <span class="tok-kw">var</span> dst = <span class="tok-kw">try</span> testing.allocator.alloc(<span class="tok-type">u32</span>, y.len - min_match_length + <span class="tok-number">1</span>);</span>
<span class="line" id="L1105">            <span class="tok-kw">defer</span> testing.allocator.free(dst);</span>
<span class="line" id="L1106"></span>
<span class="line" id="L1107">            _ = bulkHash4(y, dst);</span>
<span class="line" id="L1108">            <span class="tok-kw">for</span> (dst) |got, i| {</span>
<span class="line" id="L1109">                <span class="tok-kw">var</span> want = hash4(y[i..]);</span>
<span class="line" id="L1110">                <span class="tok-kw">try</span> expect(got == want);</span>
<span class="line" id="L1111">            }</span>
<span class="line" id="L1112">        }</span>
<span class="line" id="L1113">    }</span>
<span class="line" id="L1114">}</span>
<span class="line" id="L1115"></span>
</code></pre></body>
</html>