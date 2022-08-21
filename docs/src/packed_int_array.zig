<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">    <title>packed_int_array.zig - source view</title>
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
<pre><code><span class="line" id="L1"><span class="tok-comment">//! An set of array and slice types that bit-pack integer elements. A normal [12]u3</span></span>
<span class="line" id="L2"><span class="tok-comment">//! takes up 12 bytes of memory since u3's alignment is 1. PackedArray(u3, 12) only</span></span>
<span class="line" id="L3"><span class="tok-comment">//! takes up 4 bytes of memory.</span></span>
<span class="line" id="L4"></span>
<span class="line" id="L5"><span class="tok-kw">const</span> std = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;std&quot;</span>);</span>
<span class="line" id="L6"><span class="tok-kw">const</span> builtin = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;builtin&quot;</span>);</span>
<span class="line" id="L7"><span class="tok-kw">const</span> debug = std.debug;</span>
<span class="line" id="L8"><span class="tok-kw">const</span> testing = std.testing;</span>
<span class="line" id="L9"><span class="tok-kw">const</span> native_endian = builtin.target.cpu.arch.endian();</span>
<span class="line" id="L10"><span class="tok-kw">const</span> Endian = std.builtin.Endian;</span>
<span class="line" id="L11"></span>
<span class="line" id="L12"><span class="tok-comment">/// Provides a set of functions for reading and writing packed integers from a</span></span>
<span class="line" id="L13"><span class="tok-comment">/// slice of bytes.</span></span>
<span class="line" id="L14"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">PackedIntIo</span>(<span class="tok-kw">comptime</span> Int: <span class="tok-type">type</span>, <span class="tok-kw">comptime</span> endian: Endian) <span class="tok-type">type</span> {</span>
<span class="line" id="L15">    <span class="tok-comment">// The general technique employed here is to cast bytes in the array to a container</span>
</span>
<span class="line" id="L16">    <span class="tok-comment">// integer (having bits % 8 == 0) large enough to contain the number of bits we want,</span>
</span>
<span class="line" id="L17">    <span class="tok-comment">// then we can retrieve or store the new value with a relative minimum of masking</span>
</span>
<span class="line" id="L18">    <span class="tok-comment">// and shifting. In this worst case, this means that we'll need an integer that's</span>
</span>
<span class="line" id="L19">    <span class="tok-comment">// actually 1 byte larger than the minimum required to store the bits, because it</span>
</span>
<span class="line" id="L20">    <span class="tok-comment">// is possible that the bits start at the end of the first byte, continue through</span>
</span>
<span class="line" id="L21">    <span class="tok-comment">// zero or more, then end in the beginning of the last. But, if we try to access</span>
</span>
<span class="line" id="L22">    <span class="tok-comment">// a value in the very last byte of memory with that integer size, that extra byte</span>
</span>
<span class="line" id="L23">    <span class="tok-comment">// will be out of bounds. Depending on the circumstances of the memory, that might</span>
</span>
<span class="line" id="L24">    <span class="tok-comment">// mean the OS fatally kills the program. Thus, we use a larger container (MaxIo)</span>
</span>
<span class="line" id="L25">    <span class="tok-comment">// most of the time, but a smaller container (MinIo) when touching the last byte</span>
</span>
<span class="line" id="L26">    <span class="tok-comment">// of the memory.</span>
</span>
<span class="line" id="L27">    <span class="tok-kw">const</span> int_bits = <span class="tok-builtin">@bitSizeOf</span>(Int);</span>
<span class="line" id="L28"></span>
<span class="line" id="L29">    <span class="tok-comment">// In the best case, this is the number of bytes we need to touch</span>
</span>
<span class="line" id="L30">    <span class="tok-comment">// to read or write a value, as bits.</span>
</span>
<span class="line" id="L31">    <span class="tok-kw">const</span> min_io_bits = ((int_bits + <span class="tok-number">7</span>) / <span class="tok-number">8</span>) * <span class="tok-number">8</span>;</span>
<span class="line" id="L32"></span>
<span class="line" id="L33">    <span class="tok-comment">// In the worst case, this is the number of bytes we need to touch</span>
</span>
<span class="line" id="L34">    <span class="tok-comment">// to read or write a value, as bits. To calculate for int_bits &gt; 1,</span>
</span>
<span class="line" id="L35">    <span class="tok-comment">// set aside 2 bits to touch the first and last bytes, then divide</span>
</span>
<span class="line" id="L36">    <span class="tok-comment">// by 8 to see how many bytes can be filled up inbetween.</span>
</span>
<span class="line" id="L37">    <span class="tok-kw">const</span> max_io_bits = <span class="tok-kw">switch</span> (int_bits) {</span>
<span class="line" id="L38">        <span class="tok-number">0</span> =&gt; <span class="tok-number">0</span>,</span>
<span class="line" id="L39">        <span class="tok-number">1</span> =&gt; <span class="tok-number">8</span>,</span>
<span class="line" id="L40">        <span class="tok-kw">else</span> =&gt; ((int_bits - <span class="tok-number">2</span>) / <span class="tok-number">8</span> + <span class="tok-number">2</span>) * <span class="tok-number">8</span>,</span>
<span class="line" id="L41">    };</span>
<span class="line" id="L42"></span>
<span class="line" id="L43">    <span class="tok-comment">// We bitcast the desired Int type to an unsigned version of itself</span>
</span>
<span class="line" id="L44">    <span class="tok-comment">// to avoid issues with shifting signed ints.</span>
</span>
<span class="line" id="L45">    <span class="tok-kw">const</span> UnInt = std.meta.Int(.unsigned, int_bits);</span>
<span class="line" id="L46"></span>
<span class="line" id="L47">    <span class="tok-comment">// The maximum container int type</span>
</span>
<span class="line" id="L48">    <span class="tok-kw">const</span> MinIo = std.meta.Int(.unsigned, min_io_bits);</span>
<span class="line" id="L49"></span>
<span class="line" id="L50">    <span class="tok-comment">// The minimum container int type</span>
</span>
<span class="line" id="L51">    <span class="tok-kw">const</span> MaxIo = std.meta.Int(.unsigned, max_io_bits);</span>
<span class="line" id="L52"></span>
<span class="line" id="L53">    <span class="tok-kw">return</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L54">        <span class="tok-comment">/// Retrieves the integer at `index` from the packed data beginning at `bit_offset`</span></span>
<span class="line" id="L55">        <span class="tok-comment">/// within `bytes`.</span></span>
<span class="line" id="L56">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">get</span>(bytes: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, index: <span class="tok-type">usize</span>, bit_offset: <span class="tok-type">u7</span>) Int {</span>
<span class="line" id="L57">            <span class="tok-kw">if</span> (int_bits == <span class="tok-number">0</span>) <span class="tok-kw">return</span> <span class="tok-number">0</span>;</span>
<span class="line" id="L58"></span>
<span class="line" id="L59">            <span class="tok-kw">const</span> bit_index = (index * int_bits) + bit_offset;</span>
<span class="line" id="L60">            <span class="tok-kw">const</span> max_end_byte = (bit_index + max_io_bits) / <span class="tok-number">8</span>;</span>
<span class="line" id="L61"></span>
<span class="line" id="L62">            <span class="tok-comment">//using the larger container size will potentially read out of bounds</span>
</span>
<span class="line" id="L63">            <span class="tok-kw">if</span> (max_end_byte &gt; bytes.len) <span class="tok-kw">return</span> getBits(bytes, MinIo, bit_index);</span>
<span class="line" id="L64">            <span class="tok-kw">return</span> getBits(bytes, MaxIo, bit_index);</span>
<span class="line" id="L65">        }</span>
<span class="line" id="L66"></span>
<span class="line" id="L67">        <span class="tok-kw">fn</span> <span class="tok-fn">getBits</span>(bytes: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, <span class="tok-kw">comptime</span> Container: <span class="tok-type">type</span>, bit_index: <span class="tok-type">usize</span>) Int {</span>
<span class="line" id="L68">            <span class="tok-kw">const</span> container_bits = <span class="tok-builtin">@bitSizeOf</span>(Container);</span>
<span class="line" id="L69">            <span class="tok-kw">const</span> Shift = std.math.Log2Int(Container);</span>
<span class="line" id="L70"></span>
<span class="line" id="L71">            <span class="tok-kw">const</span> start_byte = bit_index / <span class="tok-number">8</span>;</span>
<span class="line" id="L72">            <span class="tok-kw">const</span> head_keep_bits = bit_index - (start_byte * <span class="tok-number">8</span>);</span>
<span class="line" id="L73">            <span class="tok-kw">const</span> tail_keep_bits = container_bits - (int_bits + head_keep_bits);</span>
<span class="line" id="L74"></span>
<span class="line" id="L75">            <span class="tok-comment">//read bytes as container</span>
</span>
<span class="line" id="L76">            <span class="tok-kw">const</span> value_ptr = <span class="tok-builtin">@ptrCast</span>(*<span class="tok-kw">align</span>(<span class="tok-number">1</span>) <span class="tok-kw">const</span> Container, &amp;bytes[start_byte]);</span>
<span class="line" id="L77">            <span class="tok-kw">var</span> value = value_ptr.*;</span>
<span class="line" id="L78"></span>
<span class="line" id="L79">            <span class="tok-kw">if</span> (endian != native_endian) value = <span class="tok-builtin">@byteSwap</span>(Container, value);</span>
<span class="line" id="L80"></span>
<span class="line" id="L81">            <span class="tok-kw">switch</span> (endian) {</span>
<span class="line" id="L82">                .Big =&gt; {</span>
<span class="line" id="L83">                    value &lt;&lt;= <span class="tok-builtin">@intCast</span>(Shift, head_keep_bits);</span>
<span class="line" id="L84">                    value &gt;&gt;= <span class="tok-builtin">@intCast</span>(Shift, head_keep_bits);</span>
<span class="line" id="L85">                    value &gt;&gt;= <span class="tok-builtin">@intCast</span>(Shift, tail_keep_bits);</span>
<span class="line" id="L86">                },</span>
<span class="line" id="L87">                .Little =&gt; {</span>
<span class="line" id="L88">                    value &lt;&lt;= <span class="tok-builtin">@intCast</span>(Shift, tail_keep_bits);</span>
<span class="line" id="L89">                    value &gt;&gt;= <span class="tok-builtin">@intCast</span>(Shift, tail_keep_bits);</span>
<span class="line" id="L90">                    value &gt;&gt;= <span class="tok-builtin">@intCast</span>(Shift, head_keep_bits);</span>
<span class="line" id="L91">                },</span>
<span class="line" id="L92">            }</span>
<span class="line" id="L93"></span>
<span class="line" id="L94">            <span class="tok-kw">return</span> <span class="tok-builtin">@bitCast</span>(Int, <span class="tok-builtin">@truncate</span>(UnInt, value));</span>
<span class="line" id="L95">        }</span>
<span class="line" id="L96"></span>
<span class="line" id="L97">        <span class="tok-comment">/// Sets the integer at `index` to `val` within the packed data beginning</span></span>
<span class="line" id="L98">        <span class="tok-comment">/// at `bit_offset` into `bytes`.</span></span>
<span class="line" id="L99">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">set</span>(bytes: []<span class="tok-type">u8</span>, index: <span class="tok-type">usize</span>, bit_offset: <span class="tok-type">u3</span>, int: Int) <span class="tok-type">void</span> {</span>
<span class="line" id="L100">            <span class="tok-kw">if</span> (int_bits == <span class="tok-number">0</span>) <span class="tok-kw">return</span>;</span>
<span class="line" id="L101"></span>
<span class="line" id="L102">            <span class="tok-kw">const</span> bit_index = (index * int_bits) + bit_offset;</span>
<span class="line" id="L103">            <span class="tok-kw">const</span> max_end_byte = (bit_index + max_io_bits) / <span class="tok-number">8</span>;</span>
<span class="line" id="L104"></span>
<span class="line" id="L105">            <span class="tok-comment">//using the larger container size will potentially write out of bounds</span>
</span>
<span class="line" id="L106">            <span class="tok-kw">if</span> (max_end_byte &gt; bytes.len) <span class="tok-kw">return</span> setBits(bytes, MinIo, bit_index, int);</span>
<span class="line" id="L107">            setBits(bytes, MaxIo, bit_index, int);</span>
<span class="line" id="L108">        }</span>
<span class="line" id="L109"></span>
<span class="line" id="L110">        <span class="tok-kw">fn</span> <span class="tok-fn">setBits</span>(bytes: []<span class="tok-type">u8</span>, <span class="tok-kw">comptime</span> Container: <span class="tok-type">type</span>, bit_index: <span class="tok-type">usize</span>, int: Int) <span class="tok-type">void</span> {</span>
<span class="line" id="L111">            <span class="tok-kw">const</span> container_bits = <span class="tok-builtin">@bitSizeOf</span>(Container);</span>
<span class="line" id="L112">            <span class="tok-kw">const</span> Shift = std.math.Log2Int(Container);</span>
<span class="line" id="L113"></span>
<span class="line" id="L114">            <span class="tok-kw">const</span> start_byte = bit_index / <span class="tok-number">8</span>;</span>
<span class="line" id="L115">            <span class="tok-kw">const</span> head_keep_bits = bit_index - (start_byte * <span class="tok-number">8</span>);</span>
<span class="line" id="L116">            <span class="tok-kw">const</span> tail_keep_bits = container_bits - (int_bits + head_keep_bits);</span>
<span class="line" id="L117">            <span class="tok-kw">const</span> keep_shift = <span class="tok-kw">switch</span> (endian) {</span>
<span class="line" id="L118">                .Big =&gt; <span class="tok-builtin">@intCast</span>(Shift, tail_keep_bits),</span>
<span class="line" id="L119">                .Little =&gt; <span class="tok-builtin">@intCast</span>(Shift, head_keep_bits),</span>
<span class="line" id="L120">            };</span>
<span class="line" id="L121"></span>
<span class="line" id="L122">            <span class="tok-comment">//position the bits where they need to be in the container</span>
</span>
<span class="line" id="L123">            <span class="tok-kw">const</span> value = <span class="tok-builtin">@intCast</span>(Container, <span class="tok-builtin">@bitCast</span>(UnInt, int)) &lt;&lt; keep_shift;</span>
<span class="line" id="L124"></span>
<span class="line" id="L125">            <span class="tok-comment">//read existing bytes</span>
</span>
<span class="line" id="L126">            <span class="tok-kw">const</span> target_ptr = <span class="tok-builtin">@ptrCast</span>(*<span class="tok-kw">align</span>(<span class="tok-number">1</span>) Container, &amp;bytes[start_byte]);</span>
<span class="line" id="L127">            <span class="tok-kw">var</span> target = target_ptr.*;</span>
<span class="line" id="L128"></span>
<span class="line" id="L129">            <span class="tok-kw">if</span> (endian != native_endian) target = <span class="tok-builtin">@byteSwap</span>(Container, target);</span>
<span class="line" id="L130"></span>
<span class="line" id="L131">            <span class="tok-comment">//zero the bits we want to replace in the existing bytes</span>
</span>
<span class="line" id="L132">            <span class="tok-kw">const</span> inv_mask = <span class="tok-builtin">@intCast</span>(Container, std.math.maxInt(UnInt)) &lt;&lt; keep_shift;</span>
<span class="line" id="L133">            <span class="tok-kw">const</span> mask = ~inv_mask;</span>
<span class="line" id="L134">            target &amp;= mask;</span>
<span class="line" id="L135"></span>
<span class="line" id="L136">            <span class="tok-comment">//merge the new value</span>
</span>
<span class="line" id="L137">            target |= value;</span>
<span class="line" id="L138"></span>
<span class="line" id="L139">            <span class="tok-kw">if</span> (endian != native_endian) target = <span class="tok-builtin">@byteSwap</span>(Container, target);</span>
<span class="line" id="L140"></span>
<span class="line" id="L141">            <span class="tok-comment">//save it back</span>
</span>
<span class="line" id="L142">            target_ptr.* = target;</span>
<span class="line" id="L143">        }</span>
<span class="line" id="L144"></span>
<span class="line" id="L145">        <span class="tok-comment">/// Provides a PackedIntSlice of the packed integers in `bytes` (which begins at `bit_offset`)</span></span>
<span class="line" id="L146">        <span class="tok-comment">/// from the element specified by `start` to the element specified by `end`.</span></span>
<span class="line" id="L147">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">slice</span>(bytes: []<span class="tok-type">u8</span>, bit_offset: <span class="tok-type">u3</span>, start: <span class="tok-type">usize</span>, end: <span class="tok-type">usize</span>) PackedIntSliceEndian(Int, endian) {</span>
<span class="line" id="L148">            debug.assert(end &gt;= start);</span>
<span class="line" id="L149"></span>
<span class="line" id="L150">            <span class="tok-kw">const</span> length = end - start;</span>
<span class="line" id="L151">            <span class="tok-kw">const</span> bit_index = (start * int_bits) + bit_offset;</span>
<span class="line" id="L152">            <span class="tok-kw">const</span> start_byte = bit_index / <span class="tok-number">8</span>;</span>
<span class="line" id="L153">            <span class="tok-kw">const</span> end_byte = (bit_index + (length * int_bits) + <span class="tok-number">7</span>) / <span class="tok-number">8</span>;</span>
<span class="line" id="L154">            <span class="tok-kw">const</span> new_bytes = bytes[start_byte..end_byte];</span>
<span class="line" id="L155"></span>
<span class="line" id="L156">            <span class="tok-kw">if</span> (length == <span class="tok-number">0</span>) <span class="tok-kw">return</span> PackedIntSliceEndian(Int, endian).init(new_bytes[<span class="tok-number">0</span>..<span class="tok-number">0</span>], <span class="tok-number">0</span>);</span>
<span class="line" id="L157"></span>
<span class="line" id="L158">            <span class="tok-kw">var</span> new_slice = PackedIntSliceEndian(Int, endian).init(new_bytes, length);</span>
<span class="line" id="L159">            new_slice.bit_offset = <span class="tok-builtin">@intCast</span>(<span class="tok-type">u3</span>, (bit_index - (start_byte * <span class="tok-number">8</span>)));</span>
<span class="line" id="L160">            <span class="tok-kw">return</span> new_slice;</span>
<span class="line" id="L161">        }</span>
<span class="line" id="L162"></span>
<span class="line" id="L163">        <span class="tok-comment">/// Recasts a packed slice to a version with elements of type `NewInt` and endianness `new_endian`.</span></span>
<span class="line" id="L164">        <span class="tok-comment">/// Slice will begin at `bit_offset` within `bytes` and the new length will be automatically</span></span>
<span class="line" id="L165">        <span class="tok-comment">/// calculated from `old_len` using the sizes of the current integer type and `NewInt`.</span></span>
<span class="line" id="L166">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">sliceCast</span>(bytes: []<span class="tok-type">u8</span>, <span class="tok-kw">comptime</span> NewInt: <span class="tok-type">type</span>, <span class="tok-kw">comptime</span> new_endian: Endian, bit_offset: <span class="tok-type">u3</span>, old_len: <span class="tok-type">usize</span>) PackedIntSliceEndian(NewInt, new_endian) {</span>
<span class="line" id="L167">            <span class="tok-kw">const</span> new_int_bits = <span class="tok-builtin">@bitSizeOf</span>(NewInt);</span>
<span class="line" id="L168">            <span class="tok-kw">const</span> New = PackedIntSliceEndian(NewInt, new_endian);</span>
<span class="line" id="L169"></span>
<span class="line" id="L170">            <span class="tok-kw">const</span> total_bits = (old_len * int_bits);</span>
<span class="line" id="L171">            <span class="tok-kw">const</span> new_int_count = total_bits / new_int_bits;</span>
<span class="line" id="L172"></span>
<span class="line" id="L173">            debug.assert(total_bits == new_int_count * new_int_bits);</span>
<span class="line" id="L174"></span>
<span class="line" id="L175">            <span class="tok-kw">var</span> new = New.init(bytes, new_int_count);</span>
<span class="line" id="L176">            new.bit_offset = bit_offset;</span>
<span class="line" id="L177"></span>
<span class="line" id="L178">            <span class="tok-kw">return</span> new;</span>
<span class="line" id="L179">        }</span>
<span class="line" id="L180">    };</span>
<span class="line" id="L181">}</span>
<span class="line" id="L182"></span>
<span class="line" id="L183"><span class="tok-comment">/// Creates a bit-packed array of `Int`. Non-byte-multiple integers</span></span>
<span class="line" id="L184"><span class="tok-comment">/// will take up less memory in PackedIntArray than in a normal array.</span></span>
<span class="line" id="L185"><span class="tok-comment">/// Elements are packed using native endianess and without storing any</span></span>
<span class="line" id="L186"><span class="tok-comment">/// meta data. PackedArray(i3, 8) will occupy exactly 3 bytes</span></span>
<span class="line" id="L187"><span class="tok-comment">/// of memory.</span></span>
<span class="line" id="L188"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">PackedIntArray</span>(<span class="tok-kw">comptime</span> Int: <span class="tok-type">type</span>, <span class="tok-kw">comptime</span> int_count: <span class="tok-type">usize</span>) <span class="tok-type">type</span> {</span>
<span class="line" id="L189">    <span class="tok-kw">return</span> PackedIntArrayEndian(Int, native_endian, int_count);</span>
<span class="line" id="L190">}</span>
<span class="line" id="L191"></span>
<span class="line" id="L192"><span class="tok-comment">/// Creates a bit-packed array of `Int` with bit order specified by `endian`.</span></span>
<span class="line" id="L193"><span class="tok-comment">/// Non-byte-multiple integers will take up less memory in PackedIntArrayEndian</span></span>
<span class="line" id="L194"><span class="tok-comment">/// than in a normal array. Elements are packed without storing any meta data.</span></span>
<span class="line" id="L195"><span class="tok-comment">/// PackedIntArrayEndian(i3, 8) will occupy exactly 3 bytes of memory.</span></span>
<span class="line" id="L196"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">PackedIntArrayEndian</span>(<span class="tok-kw">comptime</span> Int: <span class="tok-type">type</span>, <span class="tok-kw">comptime</span> endian: Endian, <span class="tok-kw">comptime</span> int_count: <span class="tok-type">usize</span>) <span class="tok-type">type</span> {</span>
<span class="line" id="L197">    <span class="tok-kw">const</span> int_bits = <span class="tok-builtin">@bitSizeOf</span>(Int);</span>
<span class="line" id="L198">    <span class="tok-kw">const</span> total_bits = int_bits * int_count;</span>
<span class="line" id="L199">    <span class="tok-kw">const</span> total_bytes = (total_bits + <span class="tok-number">7</span>) / <span class="tok-number">8</span>;</span>
<span class="line" id="L200"></span>
<span class="line" id="L201">    <span class="tok-kw">const</span> Io = PackedIntIo(Int, endian);</span>
<span class="line" id="L202"></span>
<span class="line" id="L203">    <span class="tok-kw">return</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L204">        <span class="tok-kw">const</span> Self = <span class="tok-builtin">@This</span>();</span>
<span class="line" id="L205"></span>
<span class="line" id="L206">        <span class="tok-comment">/// The byte buffer containing the packed data.</span></span>
<span class="line" id="L207">        bytes: [total_bytes]<span class="tok-type">u8</span>,</span>
<span class="line" id="L208">        <span class="tok-comment">/// The number of elements in the packed array.</span></span>
<span class="line" id="L209">        <span class="tok-kw">comptime</span> len: <span class="tok-type">usize</span> = int_count,</span>
<span class="line" id="L210"></span>
<span class="line" id="L211">        <span class="tok-comment">/// Initialize a packed array using an unpacked array</span></span>
<span class="line" id="L212">        <span class="tok-comment">/// or, more likely, an array literal.</span></span>
<span class="line" id="L213">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">init</span>(ints: [int_count]Int) Self {</span>
<span class="line" id="L214">            <span class="tok-kw">var</span> self = <span class="tok-builtin">@as</span>(Self, <span class="tok-null">undefined</span>);</span>
<span class="line" id="L215">            <span class="tok-kw">for</span> (ints) |int, i| self.set(i, int);</span>
<span class="line" id="L216">            <span class="tok-kw">return</span> self;</span>
<span class="line" id="L217">        }</span>
<span class="line" id="L218"></span>
<span class="line" id="L219">        <span class="tok-comment">/// Initialize all entries of a packed array to the same value.</span></span>
<span class="line" id="L220">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">initAllTo</span>(int: Int) Self {</span>
<span class="line" id="L221">            <span class="tok-comment">// TODO: use `var self = @as(Self, undefined);` https://github.com/ziglang/zig/issues/7635</span>
</span>
<span class="line" id="L222">            <span class="tok-kw">var</span> self = Self{ .bytes = [_]<span class="tok-type">u8</span>{<span class="tok-number">0</span>} ** total_bytes, .len = int_count };</span>
<span class="line" id="L223">            self.setAll(int);</span>
<span class="line" id="L224">            <span class="tok-kw">return</span> self;</span>
<span class="line" id="L225">        }</span>
<span class="line" id="L226"></span>
<span class="line" id="L227">        <span class="tok-comment">/// Return the integer stored at `index`.</span></span>
<span class="line" id="L228">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">get</span>(self: Self, index: <span class="tok-type">usize</span>) Int {</span>
<span class="line" id="L229">            debug.assert(index &lt; int_count);</span>
<span class="line" id="L230">            <span class="tok-kw">return</span> Io.get(&amp;self.bytes, index, <span class="tok-number">0</span>);</span>
<span class="line" id="L231">        }</span>
<span class="line" id="L232"></span>
<span class="line" id="L233">        <span class="tok-comment">///Copy the value of `int` into the array at `index`.</span></span>
<span class="line" id="L234">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">set</span>(self: *Self, index: <span class="tok-type">usize</span>, int: Int) <span class="tok-type">void</span> {</span>
<span class="line" id="L235">            debug.assert(index &lt; int_count);</span>
<span class="line" id="L236">            <span class="tok-kw">return</span> Io.set(&amp;self.bytes, index, <span class="tok-number">0</span>, int);</span>
<span class="line" id="L237">        }</span>
<span class="line" id="L238"></span>
<span class="line" id="L239">        <span class="tok-comment">/// Set all entries of a packed array to the value of `int`.</span></span>
<span class="line" id="L240">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">setAll</span>(self: *Self, int: Int) <span class="tok-type">void</span> {</span>
<span class="line" id="L241">            <span class="tok-kw">var</span> i: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L242">            <span class="tok-kw">while</span> (i &lt; int_count) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L243">                self.set(i, int);</span>
<span class="line" id="L244">            }</span>
<span class="line" id="L245">        }</span>
<span class="line" id="L246"></span>
<span class="line" id="L247">        <span class="tok-comment">/// Create a PackedIntSlice of the array from `start` to `end`.</span></span>
<span class="line" id="L248">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">slice</span>(self: *Self, start: <span class="tok-type">usize</span>, end: <span class="tok-type">usize</span>) PackedIntSliceEndian(Int, endian) {</span>
<span class="line" id="L249">            debug.assert(start &lt; int_count);</span>
<span class="line" id="L250">            debug.assert(end &lt;= int_count);</span>
<span class="line" id="L251">            <span class="tok-kw">return</span> Io.slice(&amp;self.bytes, <span class="tok-number">0</span>, start, end);</span>
<span class="line" id="L252">        }</span>
<span class="line" id="L253"></span>
<span class="line" id="L254">        <span class="tok-comment">/// Create a PackedIntSlice of the array using `NewInt` as the integer type.</span></span>
<span class="line" id="L255">        <span class="tok-comment">/// `NewInt`'s bit width must fit evenly within the array's `Int`'s total bits.</span></span>
<span class="line" id="L256">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">sliceCast</span>(self: *Self, <span class="tok-kw">comptime</span> NewInt: <span class="tok-type">type</span>) PackedIntSlice(NewInt) {</span>
<span class="line" id="L257">            <span class="tok-kw">return</span> self.sliceCastEndian(NewInt, endian);</span>
<span class="line" id="L258">        }</span>
<span class="line" id="L259"></span>
<span class="line" id="L260">        <span class="tok-comment">/// Create a PackedIntSliceEndian of the array using `NewInt` as the integer type</span></span>
<span class="line" id="L261">        <span class="tok-comment">/// and `new_endian` as the new endianess. `NewInt`'s bit width must fit evenly</span></span>
<span class="line" id="L262">        <span class="tok-comment">/// within the array's `Int`'s total bits.</span></span>
<span class="line" id="L263">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">sliceCastEndian</span>(self: *Self, <span class="tok-kw">comptime</span> NewInt: <span class="tok-type">type</span>, <span class="tok-kw">comptime</span> new_endian: Endian) PackedIntSliceEndian(NewInt, new_endian) {</span>
<span class="line" id="L264">            <span class="tok-kw">return</span> Io.sliceCast(&amp;self.bytes, NewInt, new_endian, <span class="tok-number">0</span>, int_count);</span>
<span class="line" id="L265">        }</span>
<span class="line" id="L266">    };</span>
<span class="line" id="L267">}</span>
<span class="line" id="L268"></span>
<span class="line" id="L269"><span class="tok-comment">/// A type representing a sub range of a PackedIntArray.</span></span>
<span class="line" id="L270"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">PackedIntSlice</span>(<span class="tok-kw">comptime</span> Int: <span class="tok-type">type</span>) <span class="tok-type">type</span> {</span>
<span class="line" id="L271">    <span class="tok-kw">return</span> PackedIntSliceEndian(Int, native_endian);</span>
<span class="line" id="L272">}</span>
<span class="line" id="L273"></span>
<span class="line" id="L274"><span class="tok-comment">/// A type representing a sub range of a PackedIntArrayEndian.</span></span>
<span class="line" id="L275"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">PackedIntSliceEndian</span>(<span class="tok-kw">comptime</span> Int: <span class="tok-type">type</span>, <span class="tok-kw">comptime</span> endian: Endian) <span class="tok-type">type</span> {</span>
<span class="line" id="L276">    <span class="tok-kw">const</span> int_bits = <span class="tok-builtin">@bitSizeOf</span>(Int);</span>
<span class="line" id="L277">    <span class="tok-kw">const</span> Io = PackedIntIo(Int, endian);</span>
<span class="line" id="L278"></span>
<span class="line" id="L279">    <span class="tok-kw">return</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L280">        <span class="tok-kw">const</span> Self = <span class="tok-builtin">@This</span>();</span>
<span class="line" id="L281"></span>
<span class="line" id="L282">        bytes: []<span class="tok-type">u8</span>,</span>
<span class="line" id="L283">        bit_offset: <span class="tok-type">u3</span>,</span>
<span class="line" id="L284">        len: <span class="tok-type">usize</span>,</span>
<span class="line" id="L285"></span>
<span class="line" id="L286">        <span class="tok-comment">/// Calculates the number of bytes required to store a desired count</span></span>
<span class="line" id="L287">        <span class="tok-comment">/// of `Int`s.</span></span>
<span class="line" id="L288">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">bytesRequired</span>(int_count: <span class="tok-type">usize</span>) <span class="tok-type">usize</span> {</span>
<span class="line" id="L289">            <span class="tok-kw">const</span> total_bits = int_bits * int_count;</span>
<span class="line" id="L290">            <span class="tok-kw">const</span> total_bytes = (total_bits + <span class="tok-number">7</span>) / <span class="tok-number">8</span>;</span>
<span class="line" id="L291">            <span class="tok-kw">return</span> total_bytes;</span>
<span class="line" id="L292">        }</span>
<span class="line" id="L293"></span>
<span class="line" id="L294">        <span class="tok-comment">/// Initialize a packed slice using the memory at `bytes`, with `int_count`</span></span>
<span class="line" id="L295">        <span class="tok-comment">/// elements. `bytes` must be large enough to accomodate the requested</span></span>
<span class="line" id="L296">        <span class="tok-comment">/// count.</span></span>
<span class="line" id="L297">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">init</span>(bytes: []<span class="tok-type">u8</span>, int_count: <span class="tok-type">usize</span>) Self {</span>
<span class="line" id="L298">            debug.assert(bytes.len &gt;= bytesRequired(int_count));</span>
<span class="line" id="L299"></span>
<span class="line" id="L300">            <span class="tok-kw">return</span> Self{</span>
<span class="line" id="L301">                .bytes = bytes,</span>
<span class="line" id="L302">                .len = int_count,</span>
<span class="line" id="L303">                .bit_offset = <span class="tok-number">0</span>,</span>
<span class="line" id="L304">            };</span>
<span class="line" id="L305">        }</span>
<span class="line" id="L306"></span>
<span class="line" id="L307">        <span class="tok-comment">/// Return the integer stored at `index`.</span></span>
<span class="line" id="L308">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">get</span>(self: Self, index: <span class="tok-type">usize</span>) Int {</span>
<span class="line" id="L309">            debug.assert(index &lt; self.len);</span>
<span class="line" id="L310">            <span class="tok-kw">return</span> Io.get(self.bytes, index, self.bit_offset);</span>
<span class="line" id="L311">        }</span>
<span class="line" id="L312"></span>
<span class="line" id="L313">        <span class="tok-comment">/// Copy `int` into the slice at `index`.</span></span>
<span class="line" id="L314">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">set</span>(self: *Self, index: <span class="tok-type">usize</span>, int: Int) <span class="tok-type">void</span> {</span>
<span class="line" id="L315">            debug.assert(index &lt; self.len);</span>
<span class="line" id="L316">            <span class="tok-kw">return</span> Io.set(self.bytes, index, self.bit_offset, int);</span>
<span class="line" id="L317">        }</span>
<span class="line" id="L318"></span>
<span class="line" id="L319">        <span class="tok-comment">/// Create a PackedIntSlice of this slice from `start` to `end`.</span></span>
<span class="line" id="L320">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">slice</span>(self: Self, start: <span class="tok-type">usize</span>, end: <span class="tok-type">usize</span>) PackedIntSliceEndian(Int, endian) {</span>
<span class="line" id="L321">            debug.assert(start &lt; self.len);</span>
<span class="line" id="L322">            debug.assert(end &lt;= self.len);</span>
<span class="line" id="L323">            <span class="tok-kw">return</span> Io.slice(self.bytes, self.bit_offset, start, end);</span>
<span class="line" id="L324">        }</span>
<span class="line" id="L325"></span>
<span class="line" id="L326">        <span class="tok-comment">/// Create a PackedIntSlice of the sclice using `NewInt` as the integer type.</span></span>
<span class="line" id="L327">        <span class="tok-comment">/// `NewInt`'s bit width must fit evenly within the slice's `Int`'s total bits.</span></span>
<span class="line" id="L328">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">sliceCast</span>(self: Self, <span class="tok-kw">comptime</span> NewInt: <span class="tok-type">type</span>) PackedIntSliceEndian(NewInt, endian) {</span>
<span class="line" id="L329">            <span class="tok-kw">return</span> self.sliceCastEndian(NewInt, endian);</span>
<span class="line" id="L330">        }</span>
<span class="line" id="L331"></span>
<span class="line" id="L332">        <span class="tok-comment">/// Create a PackedIntSliceEndian of the slice using `NewInt` as the integer type</span></span>
<span class="line" id="L333">        <span class="tok-comment">/// and `new_endian` as the new endianess. `NewInt`'s bit width must fit evenly</span></span>
<span class="line" id="L334">        <span class="tok-comment">/// within the slice's `Int`'s total bits.</span></span>
<span class="line" id="L335">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">sliceCastEndian</span>(self: Self, <span class="tok-kw">comptime</span> NewInt: <span class="tok-type">type</span>, <span class="tok-kw">comptime</span> new_endian: Endian) PackedIntSliceEndian(NewInt, new_endian) {</span>
<span class="line" id="L336">            <span class="tok-kw">return</span> Io.sliceCast(self.bytes, NewInt, new_endian, self.bit_offset, self.len);</span>
<span class="line" id="L337">        }</span>
<span class="line" id="L338">    };</span>
<span class="line" id="L339">}</span>
<span class="line" id="L340"></span>
<span class="line" id="L341"><span class="tok-kw">const</span> we_are_testing_this_with_stage1_which_leaks_comptime_memory = <span class="tok-null">true</span>;</span>
<span class="line" id="L342"></span>
<span class="line" id="L343"><span class="tok-kw">test</span> <span class="tok-str">&quot;PackedIntArray&quot;</span> {</span>
<span class="line" id="L344">    <span class="tok-comment">// TODO @setEvalBranchQuota generates panics in wasm32. Investigate.</span>
</span>
<span class="line" id="L345">    <span class="tok-kw">if</span> (builtin.target.cpu.arch == .wasm32) <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SkipZigTest;</span>
<span class="line" id="L346">    <span class="tok-kw">if</span> (we_are_testing_this_with_stage1_which_leaks_comptime_memory) <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SkipZigTest;</span>
<span class="line" id="L347"></span>
<span class="line" id="L348">    <span class="tok-builtin">@setEvalBranchQuota</span>(<span class="tok-number">10000</span>);</span>
<span class="line" id="L349">    <span class="tok-kw">const</span> max_bits = <span class="tok-number">256</span>;</span>
<span class="line" id="L350">    <span class="tok-kw">const</span> int_count = <span class="tok-number">19</span>;</span>
<span class="line" id="L351"></span>
<span class="line" id="L352">    <span class="tok-kw">comptime</span> <span class="tok-kw">var</span> bits = <span class="tok-number">0</span>;</span>
<span class="line" id="L353">    <span class="tok-kw">inline</span> <span class="tok-kw">while</span> (bits &lt;= max_bits) : (bits += <span class="tok-number">1</span>) {</span>
<span class="line" id="L354">        <span class="tok-comment">//alternate unsigned and signed</span>
</span>
<span class="line" id="L355">        <span class="tok-kw">const</span> sign: std.builtin.Signedness = <span class="tok-kw">if</span> (bits % <span class="tok-number">2</span> == <span class="tok-number">0</span>) .signed <span class="tok-kw">else</span> .unsigned;</span>
<span class="line" id="L356">        <span class="tok-kw">const</span> I = std.meta.Int(sign, bits);</span>
<span class="line" id="L357"></span>
<span class="line" id="L358">        <span class="tok-kw">const</span> PackedArray = PackedIntArray(I, int_count);</span>
<span class="line" id="L359">        <span class="tok-kw">const</span> expected_bytes = ((bits * int_count) + <span class="tok-number">7</span>) / <span class="tok-number">8</span>;</span>
<span class="line" id="L360">        <span class="tok-kw">try</span> testing.expect(<span class="tok-builtin">@sizeOf</span>(PackedArray) == expected_bytes);</span>
<span class="line" id="L361"></span>
<span class="line" id="L362">        <span class="tok-kw">var</span> data = <span class="tok-builtin">@as</span>(PackedArray, <span class="tok-null">undefined</span>);</span>
<span class="line" id="L363"></span>
<span class="line" id="L364">        <span class="tok-comment">//write values, counting up</span>
</span>
<span class="line" id="L365">        <span class="tok-kw">var</span> i = <span class="tok-builtin">@as</span>(<span class="tok-type">usize</span>, <span class="tok-number">0</span>);</span>
<span class="line" id="L366">        <span class="tok-kw">var</span> count = <span class="tok-builtin">@as</span>(I, <span class="tok-number">0</span>);</span>
<span class="line" id="L367">        <span class="tok-kw">while</span> (i &lt; data.len) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L368">            data.set(i, count);</span>
<span class="line" id="L369">            <span class="tok-kw">if</span> (bits &gt; <span class="tok-number">0</span>) count +%= <span class="tok-number">1</span>;</span>
<span class="line" id="L370">        }</span>
<span class="line" id="L371"></span>
<span class="line" id="L372">        <span class="tok-comment">//read and verify values</span>
</span>
<span class="line" id="L373">        i = <span class="tok-number">0</span>;</span>
<span class="line" id="L374">        count = <span class="tok-number">0</span>;</span>
<span class="line" id="L375">        <span class="tok-kw">while</span> (i &lt; data.len) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L376">            <span class="tok-kw">const</span> val = data.get(i);</span>
<span class="line" id="L377">            <span class="tok-kw">try</span> testing.expect(val == count);</span>
<span class="line" id="L378">            <span class="tok-kw">if</span> (bits &gt; <span class="tok-number">0</span>) count +%= <span class="tok-number">1</span>;</span>
<span class="line" id="L379">        }</span>
<span class="line" id="L380">    }</span>
<span class="line" id="L381">}</span>
<span class="line" id="L382"></span>
<span class="line" id="L383"><span class="tok-kw">test</span> <span class="tok-str">&quot;PackedIntIo&quot;</span> {</span>
<span class="line" id="L384">    <span class="tok-kw">const</span> bytes = [_]<span class="tok-type">u8</span>{ <span class="tok-number">0b01101_000</span>, <span class="tok-number">0b01011_110</span>, <span class="tok-number">0b00011_101</span> };</span>
<span class="line" id="L385">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">u15</span>, <span class="tok-number">0x2bcd</span>), PackedIntIo(<span class="tok-type">u15</span>, .Little).get(&amp;bytes, <span class="tok-number">0</span>, <span class="tok-number">3</span>));</span>
<span class="line" id="L386">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">u16</span>, <span class="tok-number">0xabcd</span>), PackedIntIo(<span class="tok-type">u16</span>, .Little).get(&amp;bytes, <span class="tok-number">0</span>, <span class="tok-number">3</span>));</span>
<span class="line" id="L387">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">u17</span>, <span class="tok-number">0x1abcd</span>), PackedIntIo(<span class="tok-type">u17</span>, .Little).get(&amp;bytes, <span class="tok-number">0</span>, <span class="tok-number">3</span>));</span>
<span class="line" id="L388">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">u18</span>, <span class="tok-number">0x3abcd</span>), PackedIntIo(<span class="tok-type">u18</span>, .Little).get(&amp;bytes, <span class="tok-number">0</span>, <span class="tok-number">3</span>));</span>
<span class="line" id="L389">}</span>
<span class="line" id="L390"></span>
<span class="line" id="L391"><span class="tok-kw">test</span> <span class="tok-str">&quot;PackedIntArray init&quot;</span> {</span>
<span class="line" id="L392">    <span class="tok-kw">const</span> PackedArray = PackedIntArray(<span class="tok-type">u3</span>, <span class="tok-number">8</span>);</span>
<span class="line" id="L393">    <span class="tok-kw">var</span> packed_array = PackedArray.init([_]<span class="tok-type">u3</span>{ <span class="tok-number">0</span>, <span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">4</span>, <span class="tok-number">5</span>, <span class="tok-number">6</span>, <span class="tok-number">7</span> });</span>
<span class="line" id="L394">    <span class="tok-kw">var</span> i = <span class="tok-builtin">@as</span>(<span class="tok-type">usize</span>, <span class="tok-number">0</span>);</span>
<span class="line" id="L395">    <span class="tok-kw">while</span> (i &lt; packed_array.len) : (i += <span class="tok-number">1</span>) <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@intCast</span>(<span class="tok-type">u3</span>, i), packed_array.get(i));</span>
<span class="line" id="L396">}</span>
<span class="line" id="L397"></span>
<span class="line" id="L398"><span class="tok-kw">test</span> <span class="tok-str">&quot;PackedIntArray initAllTo&quot;</span> {</span>
<span class="line" id="L399">    <span class="tok-kw">const</span> PackedArray = PackedIntArray(<span class="tok-type">u3</span>, <span class="tok-number">8</span>);</span>
<span class="line" id="L400">    <span class="tok-kw">var</span> packed_array = PackedArray.initAllTo(<span class="tok-number">5</span>);</span>
<span class="line" id="L401">    <span class="tok-kw">var</span> i = <span class="tok-builtin">@as</span>(<span class="tok-type">usize</span>, <span class="tok-number">0</span>);</span>
<span class="line" id="L402">    <span class="tok-kw">while</span> (i &lt; packed_array.len) : (i += <span class="tok-number">1</span>) <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">u3</span>, <span class="tok-number">5</span>), packed_array.get(i));</span>
<span class="line" id="L403">}</span>
<span class="line" id="L404"></span>
<span class="line" id="L405"><span class="tok-kw">test</span> <span class="tok-str">&quot;PackedIntSlice&quot;</span> {</span>
<span class="line" id="L406">    <span class="tok-comment">// TODO @setEvalBranchQuota generates panics in wasm32. Investigate.</span>
</span>
<span class="line" id="L407">    <span class="tok-kw">if</span> (builtin.target.cpu.arch == .wasm32) <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SkipZigTest;</span>
<span class="line" id="L408">    <span class="tok-kw">if</span> (we_are_testing_this_with_stage1_which_leaks_comptime_memory) <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SkipZigTest;</span>
<span class="line" id="L409"></span>
<span class="line" id="L410">    <span class="tok-builtin">@setEvalBranchQuota</span>(<span class="tok-number">10000</span>);</span>
<span class="line" id="L411">    <span class="tok-kw">const</span> max_bits = <span class="tok-number">256</span>;</span>
<span class="line" id="L412">    <span class="tok-kw">const</span> int_count = <span class="tok-number">19</span>;</span>
<span class="line" id="L413">    <span class="tok-kw">const</span> total_bits = max_bits * int_count;</span>
<span class="line" id="L414">    <span class="tok-kw">const</span> total_bytes = (total_bits + <span class="tok-number">7</span>) / <span class="tok-number">8</span>;</span>
<span class="line" id="L415"></span>
<span class="line" id="L416">    <span class="tok-kw">var</span> buffer: [total_bytes]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L417"></span>
<span class="line" id="L418">    <span class="tok-kw">comptime</span> <span class="tok-kw">var</span> bits = <span class="tok-number">0</span>;</span>
<span class="line" id="L419">    <span class="tok-kw">inline</span> <span class="tok-kw">while</span> (bits &lt;= max_bits) : (bits += <span class="tok-number">1</span>) {</span>
<span class="line" id="L420">        <span class="tok-comment">//alternate unsigned and signed</span>
</span>
<span class="line" id="L421">        <span class="tok-kw">const</span> sign: std.builtin.Signedness = <span class="tok-kw">if</span> (bits % <span class="tok-number">2</span> == <span class="tok-number">0</span>) .signed <span class="tok-kw">else</span> .unsigned;</span>
<span class="line" id="L422">        <span class="tok-kw">const</span> I = std.meta.Int(sign, bits);</span>
<span class="line" id="L423">        <span class="tok-kw">const</span> P = PackedIntSlice(I);</span>
<span class="line" id="L424"></span>
<span class="line" id="L425">        <span class="tok-kw">var</span> data = P.init(&amp;buffer, int_count);</span>
<span class="line" id="L426"></span>
<span class="line" id="L427">        <span class="tok-comment">//write values, counting up</span>
</span>
<span class="line" id="L428">        <span class="tok-kw">var</span> i = <span class="tok-builtin">@as</span>(<span class="tok-type">usize</span>, <span class="tok-number">0</span>);</span>
<span class="line" id="L429">        <span class="tok-kw">var</span> count = <span class="tok-builtin">@as</span>(I, <span class="tok-number">0</span>);</span>
<span class="line" id="L430">        <span class="tok-kw">while</span> (i &lt; data.len) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L431">            data.set(i, count);</span>
<span class="line" id="L432">            <span class="tok-kw">if</span> (bits &gt; <span class="tok-number">0</span>) count +%= <span class="tok-number">1</span>;</span>
<span class="line" id="L433">        }</span>
<span class="line" id="L434"></span>
<span class="line" id="L435">        <span class="tok-comment">//read and verify values</span>
</span>
<span class="line" id="L436">        i = <span class="tok-number">0</span>;</span>
<span class="line" id="L437">        count = <span class="tok-number">0</span>;</span>
<span class="line" id="L438">        <span class="tok-kw">while</span> (i &lt; data.len) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L439">            <span class="tok-kw">const</span> val = data.get(i);</span>
<span class="line" id="L440">            <span class="tok-kw">try</span> testing.expect(val == count);</span>
<span class="line" id="L441">            <span class="tok-kw">if</span> (bits &gt; <span class="tok-number">0</span>) count +%= <span class="tok-number">1</span>;</span>
<span class="line" id="L442">        }</span>
<span class="line" id="L443">    }</span>
<span class="line" id="L444">}</span>
<span class="line" id="L445"></span>
<span class="line" id="L446"><span class="tok-kw">test</span> <span class="tok-str">&quot;PackedIntSlice of PackedInt(Array/Slice)&quot;</span> {</span>
<span class="line" id="L447">    <span class="tok-kw">if</span> (we_are_testing_this_with_stage1_which_leaks_comptime_memory) <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SkipZigTest;</span>
<span class="line" id="L448">    <span class="tok-kw">const</span> max_bits = <span class="tok-number">16</span>;</span>
<span class="line" id="L449">    <span class="tok-kw">const</span> int_count = <span class="tok-number">19</span>;</span>
<span class="line" id="L450"></span>
<span class="line" id="L451">    <span class="tok-kw">comptime</span> <span class="tok-kw">var</span> bits = <span class="tok-number">0</span>;</span>
<span class="line" id="L452">    <span class="tok-kw">inline</span> <span class="tok-kw">while</span> (bits &lt;= max_bits) : (bits += <span class="tok-number">1</span>) {</span>
<span class="line" id="L453">        <span class="tok-kw">const</span> Int = std.meta.Int(.unsigned, bits);</span>
<span class="line" id="L454"></span>
<span class="line" id="L455">        <span class="tok-kw">const</span> PackedArray = PackedIntArray(Int, int_count);</span>
<span class="line" id="L456">        <span class="tok-kw">var</span> packed_array = <span class="tok-builtin">@as</span>(PackedArray, <span class="tok-null">undefined</span>);</span>
<span class="line" id="L457"></span>
<span class="line" id="L458">        <span class="tok-kw">const</span> limit = (<span class="tok-number">1</span> &lt;&lt; bits);</span>
<span class="line" id="L459"></span>
<span class="line" id="L460">        <span class="tok-kw">var</span> i = <span class="tok-builtin">@as</span>(<span class="tok-type">usize</span>, <span class="tok-number">0</span>);</span>
<span class="line" id="L461">        <span class="tok-kw">while</span> (i &lt; packed_array.len) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L462">            packed_array.set(i, <span class="tok-builtin">@intCast</span>(Int, i % limit));</span>
<span class="line" id="L463">        }</span>
<span class="line" id="L464"></span>
<span class="line" id="L465">        <span class="tok-comment">//slice of array</span>
</span>
<span class="line" id="L466">        <span class="tok-kw">var</span> packed_slice = packed_array.slice(<span class="tok-number">2</span>, <span class="tok-number">5</span>);</span>
<span class="line" id="L467">        <span class="tok-kw">try</span> testing.expect(packed_slice.len == <span class="tok-number">3</span>);</span>
<span class="line" id="L468">        <span class="tok-kw">const</span> ps_bit_count = (bits * packed_slice.len) + packed_slice.bit_offset;</span>
<span class="line" id="L469">        <span class="tok-kw">const</span> ps_expected_bytes = (ps_bit_count + <span class="tok-number">7</span>) / <span class="tok-number">8</span>;</span>
<span class="line" id="L470">        <span class="tok-kw">try</span> testing.expect(packed_slice.bytes.len == ps_expected_bytes);</span>
<span class="line" id="L471">        <span class="tok-kw">try</span> testing.expect(packed_slice.get(<span class="tok-number">0</span>) == <span class="tok-number">2</span> % limit);</span>
<span class="line" id="L472">        <span class="tok-kw">try</span> testing.expect(packed_slice.get(<span class="tok-number">1</span>) == <span class="tok-number">3</span> % limit);</span>
<span class="line" id="L473">        <span class="tok-kw">try</span> testing.expect(packed_slice.get(<span class="tok-number">2</span>) == <span class="tok-number">4</span> % limit);</span>
<span class="line" id="L474">        packed_slice.set(<span class="tok-number">1</span>, <span class="tok-number">7</span> % limit);</span>
<span class="line" id="L475">        <span class="tok-kw">try</span> testing.expect(packed_slice.get(<span class="tok-number">1</span>) == <span class="tok-number">7</span> % limit);</span>
<span class="line" id="L476"></span>
<span class="line" id="L477">        <span class="tok-comment">//write through slice</span>
</span>
<span class="line" id="L478">        <span class="tok-kw">try</span> testing.expect(packed_array.get(<span class="tok-number">3</span>) == <span class="tok-number">7</span> % limit);</span>
<span class="line" id="L479"></span>
<span class="line" id="L480">        <span class="tok-comment">//slice of a slice</span>
</span>
<span class="line" id="L481">        <span class="tok-kw">const</span> packed_slice_two = packed_slice.slice(<span class="tok-number">0</span>, <span class="tok-number">3</span>);</span>
<span class="line" id="L482">        <span class="tok-kw">try</span> testing.expect(packed_slice_two.len == <span class="tok-number">3</span>);</span>
<span class="line" id="L483">        <span class="tok-kw">const</span> ps2_bit_count = (bits * packed_slice_two.len) + packed_slice_two.bit_offset;</span>
<span class="line" id="L484">        <span class="tok-kw">const</span> ps2_expected_bytes = (ps2_bit_count + <span class="tok-number">7</span>) / <span class="tok-number">8</span>;</span>
<span class="line" id="L485">        <span class="tok-kw">try</span> testing.expect(packed_slice_two.bytes.len == ps2_expected_bytes);</span>
<span class="line" id="L486">        <span class="tok-kw">try</span> testing.expect(packed_slice_two.get(<span class="tok-number">1</span>) == <span class="tok-number">7</span> % limit);</span>
<span class="line" id="L487">        <span class="tok-kw">try</span> testing.expect(packed_slice_two.get(<span class="tok-number">2</span>) == <span class="tok-number">4</span> % limit);</span>
<span class="line" id="L488"></span>
<span class="line" id="L489">        <span class="tok-comment">//size one case</span>
</span>
<span class="line" id="L490">        <span class="tok-kw">const</span> packed_slice_three = packed_slice_two.slice(<span class="tok-number">1</span>, <span class="tok-number">2</span>);</span>
<span class="line" id="L491">        <span class="tok-kw">try</span> testing.expect(packed_slice_three.len == <span class="tok-number">1</span>);</span>
<span class="line" id="L492">        <span class="tok-kw">const</span> ps3_bit_count = (bits * packed_slice_three.len) + packed_slice_three.bit_offset;</span>
<span class="line" id="L493">        <span class="tok-kw">const</span> ps3_expected_bytes = (ps3_bit_count + <span class="tok-number">7</span>) / <span class="tok-number">8</span>;</span>
<span class="line" id="L494">        <span class="tok-kw">try</span> testing.expect(packed_slice_three.bytes.len == ps3_expected_bytes);</span>
<span class="line" id="L495">        <span class="tok-kw">try</span> testing.expect(packed_slice_three.get(<span class="tok-number">0</span>) == <span class="tok-number">7</span> % limit);</span>
<span class="line" id="L496"></span>
<span class="line" id="L497">        <span class="tok-comment">//empty slice case</span>
</span>
<span class="line" id="L498">        <span class="tok-kw">const</span> packed_slice_empty = packed_slice.slice(<span class="tok-number">0</span>, <span class="tok-number">0</span>);</span>
<span class="line" id="L499">        <span class="tok-kw">try</span> testing.expect(packed_slice_empty.len == <span class="tok-number">0</span>);</span>
<span class="line" id="L500">        <span class="tok-kw">try</span> testing.expect(packed_slice_empty.bytes.len == <span class="tok-number">0</span>);</span>
<span class="line" id="L501"></span>
<span class="line" id="L502">        <span class="tok-comment">//slicing at byte boundaries</span>
</span>
<span class="line" id="L503">        <span class="tok-kw">const</span> packed_slice_edge = packed_array.slice(<span class="tok-number">8</span>, <span class="tok-number">16</span>);</span>
<span class="line" id="L504">        <span class="tok-kw">try</span> testing.expect(packed_slice_edge.len == <span class="tok-number">8</span>);</span>
<span class="line" id="L505">        <span class="tok-kw">const</span> pse_bit_count = (bits * packed_slice_edge.len) + packed_slice_edge.bit_offset;</span>
<span class="line" id="L506">        <span class="tok-kw">const</span> pse_expected_bytes = (pse_bit_count + <span class="tok-number">7</span>) / <span class="tok-number">8</span>;</span>
<span class="line" id="L507">        <span class="tok-kw">try</span> testing.expect(packed_slice_edge.bytes.len == pse_expected_bytes);</span>
<span class="line" id="L508">        <span class="tok-kw">try</span> testing.expect(packed_slice_edge.bit_offset == <span class="tok-number">0</span>);</span>
<span class="line" id="L509">    }</span>
<span class="line" id="L510">}</span>
<span class="line" id="L511"></span>
<span class="line" id="L512"><span class="tok-kw">test</span> <span class="tok-str">&quot;PackedIntSlice accumulating bit offsets&quot;</span> {</span>
<span class="line" id="L513">    <span class="tok-comment">//bit_offset is u3, so standard debugging asserts should catch</span>
</span>
<span class="line" id="L514">    <span class="tok-comment">// anything</span>
</span>
<span class="line" id="L515">    {</span>
<span class="line" id="L516">        <span class="tok-kw">const</span> PackedArray = PackedIntArray(<span class="tok-type">u3</span>, <span class="tok-number">16</span>);</span>
<span class="line" id="L517">        <span class="tok-kw">var</span> packed_array = <span class="tok-builtin">@as</span>(PackedArray, <span class="tok-null">undefined</span>);</span>
<span class="line" id="L518"></span>
<span class="line" id="L519">        <span class="tok-kw">var</span> packed_slice = packed_array.slice(<span class="tok-number">0</span>, packed_array.len);</span>
<span class="line" id="L520">        <span class="tok-kw">var</span> i = <span class="tok-builtin">@as</span>(<span class="tok-type">usize</span>, <span class="tok-number">0</span>);</span>
<span class="line" id="L521">        <span class="tok-kw">while</span> (i &lt; packed_array.len - <span class="tok-number">1</span>) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L522">            packed_slice = packed_slice.slice(<span class="tok-number">1</span>, packed_slice.len);</span>
<span class="line" id="L523">        }</span>
<span class="line" id="L524">    }</span>
<span class="line" id="L525">    {</span>
<span class="line" id="L526">        <span class="tok-kw">const</span> PackedArray = PackedIntArray(<span class="tok-type">u11</span>, <span class="tok-number">88</span>);</span>
<span class="line" id="L527">        <span class="tok-kw">var</span> packed_array = <span class="tok-builtin">@as</span>(PackedArray, <span class="tok-null">undefined</span>);</span>
<span class="line" id="L528"></span>
<span class="line" id="L529">        <span class="tok-kw">var</span> packed_slice = packed_array.slice(<span class="tok-number">0</span>, packed_array.len);</span>
<span class="line" id="L530">        <span class="tok-kw">var</span> i = <span class="tok-builtin">@as</span>(<span class="tok-type">usize</span>, <span class="tok-number">0</span>);</span>
<span class="line" id="L531">        <span class="tok-kw">while</span> (i &lt; packed_array.len - <span class="tok-number">1</span>) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L532">            packed_slice = packed_slice.slice(<span class="tok-number">1</span>, packed_slice.len);</span>
<span class="line" id="L533">        }</span>
<span class="line" id="L534">    }</span>
<span class="line" id="L535">}</span>
<span class="line" id="L536"></span>
<span class="line" id="L537"><span class="tok-kw">test</span> <span class="tok-str">&quot;PackedInt(Array/Slice) sliceCast&quot;</span> {</span>
<span class="line" id="L538">    <span class="tok-kw">const</span> PackedArray = PackedIntArray(<span class="tok-type">u1</span>, <span class="tok-number">16</span>);</span>
<span class="line" id="L539">    <span class="tok-kw">var</span> packed_array = PackedArray.init([_]<span class="tok-type">u1</span>{ <span class="tok-number">0</span>, <span class="tok-number">1</span>, <span class="tok-number">0</span>, <span class="tok-number">1</span>, <span class="tok-number">0</span>, <span class="tok-number">1</span>, <span class="tok-number">0</span>, <span class="tok-number">1</span>, <span class="tok-number">0</span>, <span class="tok-number">1</span>, <span class="tok-number">0</span>, <span class="tok-number">1</span>, <span class="tok-number">0</span>, <span class="tok-number">1</span>, <span class="tok-number">0</span>, <span class="tok-number">1</span> });</span>
<span class="line" id="L540">    <span class="tok-kw">const</span> packed_slice_cast_2 = packed_array.sliceCast(<span class="tok-type">u2</span>);</span>
<span class="line" id="L541">    <span class="tok-kw">const</span> packed_slice_cast_4 = packed_slice_cast_2.sliceCast(<span class="tok-type">u4</span>);</span>
<span class="line" id="L542">    <span class="tok-kw">var</span> packed_slice_cast_9 = packed_array.slice(<span class="tok-number">0</span>, (packed_array.len / <span class="tok-number">9</span>) * <span class="tok-number">9</span>).sliceCast(<span class="tok-type">u9</span>);</span>
<span class="line" id="L543">    <span class="tok-kw">const</span> packed_slice_cast_3 = packed_slice_cast_9.sliceCast(<span class="tok-type">u3</span>);</span>
<span class="line" id="L544"></span>
<span class="line" id="L545">    <span class="tok-kw">var</span> i = <span class="tok-builtin">@as</span>(<span class="tok-type">usize</span>, <span class="tok-number">0</span>);</span>
<span class="line" id="L546">    <span class="tok-kw">while</span> (i &lt; packed_slice_cast_2.len) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L547">        <span class="tok-kw">const</span> val = <span class="tok-kw">switch</span> (native_endian) {</span>
<span class="line" id="L548">            .Big =&gt; <span class="tok-number">0b01</span>,</span>
<span class="line" id="L549">            .Little =&gt; <span class="tok-number">0b10</span>,</span>
<span class="line" id="L550">        };</span>
<span class="line" id="L551">        <span class="tok-kw">try</span> testing.expect(packed_slice_cast_2.get(i) == val);</span>
<span class="line" id="L552">    }</span>
<span class="line" id="L553">    i = <span class="tok-number">0</span>;</span>
<span class="line" id="L554">    <span class="tok-kw">while</span> (i &lt; packed_slice_cast_4.len) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L555">        <span class="tok-kw">const</span> val = <span class="tok-kw">switch</span> (native_endian) {</span>
<span class="line" id="L556">            .Big =&gt; <span class="tok-number">0b0101</span>,</span>
<span class="line" id="L557">            .Little =&gt; <span class="tok-number">0b1010</span>,</span>
<span class="line" id="L558">        };</span>
<span class="line" id="L559">        <span class="tok-kw">try</span> testing.expect(packed_slice_cast_4.get(i) == val);</span>
<span class="line" id="L560">    }</span>
<span class="line" id="L561">    i = <span class="tok-number">0</span>;</span>
<span class="line" id="L562">    <span class="tok-kw">while</span> (i &lt; packed_slice_cast_9.len) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L563">        <span class="tok-kw">const</span> val = <span class="tok-number">0b010101010</span>;</span>
<span class="line" id="L564">        <span class="tok-kw">try</span> testing.expect(packed_slice_cast_9.get(i) == val);</span>
<span class="line" id="L565">        packed_slice_cast_9.set(i, <span class="tok-number">0b111000111</span>);</span>
<span class="line" id="L566">    }</span>
<span class="line" id="L567">    i = <span class="tok-number">0</span>;</span>
<span class="line" id="L568">    <span class="tok-kw">while</span> (i &lt; packed_slice_cast_3.len) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L569">        <span class="tok-kw">const</span> val = <span class="tok-kw">switch</span> (native_endian) {</span>
<span class="line" id="L570">            .Big =&gt; <span class="tok-kw">if</span> (i % <span class="tok-number">2</span> == <span class="tok-number">0</span>) <span class="tok-builtin">@as</span>(<span class="tok-type">u3</span>, <span class="tok-number">0b111</span>) <span class="tok-kw">else</span> <span class="tok-builtin">@as</span>(<span class="tok-type">u3</span>, <span class="tok-number">0b000</span>),</span>
<span class="line" id="L571">            .Little =&gt; <span class="tok-kw">if</span> (i % <span class="tok-number">2</span> == <span class="tok-number">0</span>) <span class="tok-builtin">@as</span>(<span class="tok-type">u3</span>, <span class="tok-number">0b111</span>) <span class="tok-kw">else</span> <span class="tok-builtin">@as</span>(<span class="tok-type">u3</span>, <span class="tok-number">0b000</span>),</span>
<span class="line" id="L572">        };</span>
<span class="line" id="L573">        <span class="tok-kw">try</span> testing.expect(packed_slice_cast_3.get(i) == val);</span>
<span class="line" id="L574">    }</span>
<span class="line" id="L575">}</span>
<span class="line" id="L576"></span>
<span class="line" id="L577"><span class="tok-kw">test</span> <span class="tok-str">&quot;PackedInt(Array/Slice)Endian&quot;</span> {</span>
<span class="line" id="L578">    {</span>
<span class="line" id="L579">        <span class="tok-kw">const</span> PackedArrayBe = PackedIntArrayEndian(<span class="tok-type">u4</span>, .Big, <span class="tok-number">8</span>);</span>
<span class="line" id="L580">        <span class="tok-kw">var</span> packed_array_be = PackedArrayBe.init([_]<span class="tok-type">u4</span>{ <span class="tok-number">0</span>, <span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">4</span>, <span class="tok-number">5</span>, <span class="tok-number">6</span>, <span class="tok-number">7</span> });</span>
<span class="line" id="L581">        <span class="tok-kw">try</span> testing.expect(packed_array_be.bytes[<span class="tok-number">0</span>] == <span class="tok-number">0b00000001</span>);</span>
<span class="line" id="L582">        <span class="tok-kw">try</span> testing.expect(packed_array_be.bytes[<span class="tok-number">1</span>] == <span class="tok-number">0b00100011</span>);</span>
<span class="line" id="L583"></span>
<span class="line" id="L584">        <span class="tok-kw">var</span> i = <span class="tok-builtin">@as</span>(<span class="tok-type">usize</span>, <span class="tok-number">0</span>);</span>
<span class="line" id="L585">        <span class="tok-kw">while</span> (i &lt; packed_array_be.len) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L586">            <span class="tok-kw">try</span> testing.expect(packed_array_be.get(i) == i);</span>
<span class="line" id="L587">        }</span>
<span class="line" id="L588"></span>
<span class="line" id="L589">        <span class="tok-kw">var</span> packed_slice_le = packed_array_be.sliceCastEndian(<span class="tok-type">u4</span>, .Little);</span>
<span class="line" id="L590">        i = <span class="tok-number">0</span>;</span>
<span class="line" id="L591">        <span class="tok-kw">while</span> (i &lt; packed_slice_le.len) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L592">            <span class="tok-kw">const</span> val = <span class="tok-kw">if</span> (i % <span class="tok-number">2</span> == <span class="tok-number">0</span>) i + <span class="tok-number">1</span> <span class="tok-kw">else</span> i - <span class="tok-number">1</span>;</span>
<span class="line" id="L593">            <span class="tok-kw">try</span> testing.expect(packed_slice_le.get(i) == val);</span>
<span class="line" id="L594">        }</span>
<span class="line" id="L595"></span>
<span class="line" id="L596">        <span class="tok-kw">var</span> packed_slice_le_shift = packed_array_be.slice(<span class="tok-number">1</span>, <span class="tok-number">5</span>).sliceCastEndian(<span class="tok-type">u4</span>, .Little);</span>
<span class="line" id="L597">        i = <span class="tok-number">0</span>;</span>
<span class="line" id="L598">        <span class="tok-kw">while</span> (i &lt; packed_slice_le_shift.len) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L599">            <span class="tok-kw">const</span> val = <span class="tok-kw">if</span> (i % <span class="tok-number">2</span> == <span class="tok-number">0</span>) i <span class="tok-kw">else</span> i + <span class="tok-number">2</span>;</span>
<span class="line" id="L600">            <span class="tok-kw">try</span> testing.expect(packed_slice_le_shift.get(i) == val);</span>
<span class="line" id="L601">        }</span>
<span class="line" id="L602">    }</span>
<span class="line" id="L603"></span>
<span class="line" id="L604">    {</span>
<span class="line" id="L605">        <span class="tok-kw">const</span> PackedArrayBe = PackedIntArrayEndian(<span class="tok-type">u11</span>, .Big, <span class="tok-number">8</span>);</span>
<span class="line" id="L606">        <span class="tok-kw">var</span> packed_array_be = PackedArrayBe.init([_]<span class="tok-type">u11</span>{ <span class="tok-number">0</span>, <span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">4</span>, <span class="tok-number">5</span>, <span class="tok-number">6</span>, <span class="tok-number">7</span> });</span>
<span class="line" id="L607">        <span class="tok-kw">try</span> testing.expect(packed_array_be.bytes[<span class="tok-number">0</span>] == <span class="tok-number">0b00000000</span>);</span>
<span class="line" id="L608">        <span class="tok-kw">try</span> testing.expect(packed_array_be.bytes[<span class="tok-number">1</span>] == <span class="tok-number">0b00000000</span>);</span>
<span class="line" id="L609">        <span class="tok-kw">try</span> testing.expect(packed_array_be.bytes[<span class="tok-number">2</span>] == <span class="tok-number">0b00000100</span>);</span>
<span class="line" id="L610">        <span class="tok-kw">try</span> testing.expect(packed_array_be.bytes[<span class="tok-number">3</span>] == <span class="tok-number">0b00000001</span>);</span>
<span class="line" id="L611">        <span class="tok-kw">try</span> testing.expect(packed_array_be.bytes[<span class="tok-number">4</span>] == <span class="tok-number">0b00000000</span>);</span>
<span class="line" id="L612"></span>
<span class="line" id="L613">        <span class="tok-kw">var</span> i = <span class="tok-builtin">@as</span>(<span class="tok-type">usize</span>, <span class="tok-number">0</span>);</span>
<span class="line" id="L614">        <span class="tok-kw">while</span> (i &lt; packed_array_be.len) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L615">            <span class="tok-kw">try</span> testing.expect(packed_array_be.get(i) == i);</span>
<span class="line" id="L616">        }</span>
<span class="line" id="L617"></span>
<span class="line" id="L618">        <span class="tok-kw">var</span> packed_slice_le = packed_array_be.sliceCastEndian(<span class="tok-type">u11</span>, .Little);</span>
<span class="line" id="L619">        <span class="tok-kw">try</span> testing.expect(packed_slice_le.get(<span class="tok-number">0</span>) == <span class="tok-number">0b00000000000</span>);</span>
<span class="line" id="L620">        <span class="tok-kw">try</span> testing.expect(packed_slice_le.get(<span class="tok-number">1</span>) == <span class="tok-number">0b00010000000</span>);</span>
<span class="line" id="L621">        <span class="tok-kw">try</span> testing.expect(packed_slice_le.get(<span class="tok-number">2</span>) == <span class="tok-number">0b00000000100</span>);</span>
<span class="line" id="L622">        <span class="tok-kw">try</span> testing.expect(packed_slice_le.get(<span class="tok-number">3</span>) == <span class="tok-number">0b00000000000</span>);</span>
<span class="line" id="L623">        <span class="tok-kw">try</span> testing.expect(packed_slice_le.get(<span class="tok-number">4</span>) == <span class="tok-number">0b00010000011</span>);</span>
<span class="line" id="L624">        <span class="tok-kw">try</span> testing.expect(packed_slice_le.get(<span class="tok-number">5</span>) == <span class="tok-number">0b00000000010</span>);</span>
<span class="line" id="L625">        <span class="tok-kw">try</span> testing.expect(packed_slice_le.get(<span class="tok-number">6</span>) == <span class="tok-number">0b10000010000</span>);</span>
<span class="line" id="L626">        <span class="tok-kw">try</span> testing.expect(packed_slice_le.get(<span class="tok-number">7</span>) == <span class="tok-number">0b00000111001</span>);</span>
<span class="line" id="L627"></span>
<span class="line" id="L628">        <span class="tok-kw">var</span> packed_slice_le_shift = packed_array_be.slice(<span class="tok-number">1</span>, <span class="tok-number">5</span>).sliceCastEndian(<span class="tok-type">u11</span>, .Little);</span>
<span class="line" id="L629">        <span class="tok-kw">try</span> testing.expect(packed_slice_le_shift.get(<span class="tok-number">0</span>) == <span class="tok-number">0b00010000000</span>);</span>
<span class="line" id="L630">        <span class="tok-kw">try</span> testing.expect(packed_slice_le_shift.get(<span class="tok-number">1</span>) == <span class="tok-number">0b00000000100</span>);</span>
<span class="line" id="L631">        <span class="tok-kw">try</span> testing.expect(packed_slice_le_shift.get(<span class="tok-number">2</span>) == <span class="tok-number">0b00000000000</span>);</span>
<span class="line" id="L632">        <span class="tok-kw">try</span> testing.expect(packed_slice_le_shift.get(<span class="tok-number">3</span>) == <span class="tok-number">0b00010000011</span>);</span>
<span class="line" id="L633">    }</span>
<span class="line" id="L634">}</span>
<span class="line" id="L635"></span>
<span class="line" id="L636"><span class="tok-comment">//@NOTE: Need to manually update this list as more posix os's get</span>
</span>
<span class="line" id="L637"><span class="tok-comment">// added to DirectAllocator.</span>
</span>
<span class="line" id="L638"></span>
<span class="line" id="L639"><span class="tok-comment">// These tests prove we aren't accidentally accessing memory past</span>
</span>
<span class="line" id="L640"><span class="tok-comment">// the end of the array/slice by placing it at the end of a page</span>
</span>
<span class="line" id="L641"><span class="tok-comment">// and reading the last element. The assumption is that the page</span>
</span>
<span class="line" id="L642"><span class="tok-comment">// after this one is not mapped and will cause a segfault if we</span>
</span>
<span class="line" id="L643"><span class="tok-comment">// don't account for the bounds.</span>
</span>
<span class="line" id="L644"><span class="tok-kw">test</span> <span class="tok-str">&quot;PackedIntArray at end of available memory&quot;</span> {</span>
<span class="line" id="L645">    <span class="tok-kw">switch</span> (builtin.target.os.tag) {</span>
<span class="line" id="L646">        .linux, .macos, .ios, .freebsd, .netbsd, .openbsd, .windows =&gt; {},</span>
<span class="line" id="L647">        <span class="tok-kw">else</span> =&gt; <span class="tok-kw">return</span>,</span>
<span class="line" id="L648">    }</span>
<span class="line" id="L649">    <span class="tok-kw">const</span> PackedArray = PackedIntArray(<span class="tok-type">u3</span>, <span class="tok-number">8</span>);</span>
<span class="line" id="L650"></span>
<span class="line" id="L651">    <span class="tok-kw">const</span> Padded = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L652">        _: [std.mem.page_size - <span class="tok-builtin">@sizeOf</span>(PackedArray)]<span class="tok-type">u8</span>,</span>
<span class="line" id="L653">        p: PackedArray,</span>
<span class="line" id="L654">    };</span>
<span class="line" id="L655"></span>
<span class="line" id="L656">    <span class="tok-kw">const</span> allocator = std.testing.allocator;</span>
<span class="line" id="L657"></span>
<span class="line" id="L658">    <span class="tok-kw">var</span> pad = <span class="tok-kw">try</span> allocator.create(Padded);</span>
<span class="line" id="L659">    <span class="tok-kw">defer</span> allocator.destroy(pad);</span>
<span class="line" id="L660">    pad.p.set(<span class="tok-number">7</span>, std.math.maxInt(<span class="tok-type">u3</span>));</span>
<span class="line" id="L661">}</span>
<span class="line" id="L662"></span>
<span class="line" id="L663"><span class="tok-kw">test</span> <span class="tok-str">&quot;PackedIntSlice at end of available memory&quot;</span> {</span>
<span class="line" id="L664">    <span class="tok-kw">switch</span> (builtin.target.os.tag) {</span>
<span class="line" id="L665">        .linux, .macos, .ios, .freebsd, .netbsd, .openbsd, .windows =&gt; {},</span>
<span class="line" id="L666">        <span class="tok-kw">else</span> =&gt; <span class="tok-kw">return</span>,</span>
<span class="line" id="L667">    }</span>
<span class="line" id="L668">    <span class="tok-kw">const</span> PackedSlice = PackedIntSlice(<span class="tok-type">u11</span>);</span>
<span class="line" id="L669"></span>
<span class="line" id="L670">    <span class="tok-kw">const</span> allocator = std.testing.allocator;</span>
<span class="line" id="L671"></span>
<span class="line" id="L672">    <span class="tok-kw">var</span> page = <span class="tok-kw">try</span> allocator.alloc(<span class="tok-type">u8</span>, std.mem.page_size);</span>
<span class="line" id="L673">    <span class="tok-kw">defer</span> allocator.free(page);</span>
<span class="line" id="L674"></span>
<span class="line" id="L675">    <span class="tok-kw">var</span> p = PackedSlice.init(page[std.mem.page_size - <span class="tok-number">2</span> ..], <span class="tok-number">1</span>);</span>
<span class="line" id="L676">    p.set(<span class="tok-number">0</span>, std.math.maxInt(<span class="tok-type">u11</span>));</span>
<span class="line" id="L677">}</span>
<span class="line" id="L678"></span>
</code></pre></body>
</html>