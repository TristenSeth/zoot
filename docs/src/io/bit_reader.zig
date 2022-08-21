<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">    <title>io/bit_reader.zig - source view</title>
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
<pre><code><span class="line" id="L1"><span class="tok-kw">const</span> std = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;../std.zig&quot;</span>);</span>
<span class="line" id="L2"><span class="tok-kw">const</span> io = std.io;</span>
<span class="line" id="L3"><span class="tok-kw">const</span> assert = std.debug.assert;</span>
<span class="line" id="L4"><span class="tok-kw">const</span> testing = std.testing;</span>
<span class="line" id="L5"><span class="tok-kw">const</span> trait = std.meta.trait;</span>
<span class="line" id="L6"><span class="tok-kw">const</span> meta = std.meta;</span>
<span class="line" id="L7"><span class="tok-kw">const</span> math = std.math;</span>
<span class="line" id="L8"></span>
<span class="line" id="L9"><span class="tok-comment">/// Creates a stream which allows for reading bit fields from another stream</span></span>
<span class="line" id="L10"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">BitReader</span>(endian: std.builtin.Endian, <span class="tok-kw">comptime</span> ReaderType: <span class="tok-type">type</span>) <span class="tok-type">type</span> {</span>
<span class="line" id="L11">    <span class="tok-kw">return</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L12">        forward_reader: ReaderType,</span>
<span class="line" id="L13">        bit_buffer: <span class="tok-type">u7</span>,</span>
<span class="line" id="L14">        bit_count: <span class="tok-type">u3</span>,</span>
<span class="line" id="L15"></span>
<span class="line" id="L16">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> Error = ReaderType.Error;</span>
<span class="line" id="L17">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> Reader = io.Reader(*Self, Error, read);</span>
<span class="line" id="L18"></span>
<span class="line" id="L19">        <span class="tok-kw">const</span> Self = <span class="tok-builtin">@This</span>();</span>
<span class="line" id="L20">        <span class="tok-kw">const</span> u8_bit_count = <span class="tok-builtin">@bitSizeOf</span>(<span class="tok-type">u8</span>);</span>
<span class="line" id="L21">        <span class="tok-kw">const</span> u7_bit_count = <span class="tok-builtin">@bitSizeOf</span>(<span class="tok-type">u7</span>);</span>
<span class="line" id="L22">        <span class="tok-kw">const</span> u4_bit_count = <span class="tok-builtin">@bitSizeOf</span>(<span class="tok-type">u4</span>);</span>
<span class="line" id="L23"></span>
<span class="line" id="L24">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">init</span>(forward_reader: ReaderType) Self {</span>
<span class="line" id="L25">            <span class="tok-kw">return</span> Self{</span>
<span class="line" id="L26">                .forward_reader = forward_reader,</span>
<span class="line" id="L27">                .bit_buffer = <span class="tok-number">0</span>,</span>
<span class="line" id="L28">                .bit_count = <span class="tok-number">0</span>,</span>
<span class="line" id="L29">            };</span>
<span class="line" id="L30">        }</span>
<span class="line" id="L31"></span>
<span class="line" id="L32">        <span class="tok-comment">/// Reads `bits` bits from the stream and returns a specified unsigned int type</span></span>
<span class="line" id="L33">        <span class="tok-comment">///  containing them in the least significant end, returning an error if the</span></span>
<span class="line" id="L34">        <span class="tok-comment">///  specified number of bits could not be read.</span></span>
<span class="line" id="L35">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">readBitsNoEof</span>(self: *Self, <span class="tok-kw">comptime</span> U: <span class="tok-type">type</span>, bits: <span class="tok-type">usize</span>) !U {</span>
<span class="line" id="L36">            <span class="tok-kw">var</span> n: <span class="tok-type">usize</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L37">            <span class="tok-kw">const</span> result = <span class="tok-kw">try</span> self.readBits(U, bits, &amp;n);</span>
<span class="line" id="L38">            <span class="tok-kw">if</span> (n &lt; bits) <span class="tok-kw">return</span> <span class="tok-kw">error</span>.EndOfStream;</span>
<span class="line" id="L39">            <span class="tok-kw">return</span> result;</span>
<span class="line" id="L40">        }</span>
<span class="line" id="L41"></span>
<span class="line" id="L42">        <span class="tok-comment">/// Reads `bits` bits from the stream and returns a specified unsigned int type</span></span>
<span class="line" id="L43">        <span class="tok-comment">///  containing them in the least significant end. The number of bits successfully</span></span>
<span class="line" id="L44">        <span class="tok-comment">///  read is placed in `out_bits`, as reaching the end of the stream is not an error.</span></span>
<span class="line" id="L45">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">readBits</span>(self: *Self, <span class="tok-kw">comptime</span> U: <span class="tok-type">type</span>, bits: <span class="tok-type">usize</span>, out_bits: *<span class="tok-type">usize</span>) Error!U {</span>
<span class="line" id="L46">            <span class="tok-kw">comptime</span> assert(trait.isUnsignedInt(U));</span>
<span class="line" id="L47"></span>
<span class="line" id="L48">            <span class="tok-comment">//by extending the buffer to a minimum of u8 we can cover a number of edge cases</span>
</span>
<span class="line" id="L49">            <span class="tok-comment">// related to shifting and casting.</span>
</span>
<span class="line" id="L50">            <span class="tok-kw">const</span> u_bit_count = <span class="tok-builtin">@bitSizeOf</span>(U);</span>
<span class="line" id="L51">            <span class="tok-kw">const</span> buf_bit_count = bc: {</span>
<span class="line" id="L52">                assert(u_bit_count &gt;= bits);</span>
<span class="line" id="L53">                <span class="tok-kw">break</span> :bc <span class="tok-kw">if</span> (u_bit_count &lt;= u8_bit_count) u8_bit_count <span class="tok-kw">else</span> u_bit_count;</span>
<span class="line" id="L54">            };</span>
<span class="line" id="L55">            <span class="tok-kw">const</span> Buf = std.meta.Int(.unsigned, buf_bit_count);</span>
<span class="line" id="L56">            <span class="tok-kw">const</span> BufShift = math.Log2Int(Buf);</span>
<span class="line" id="L57"></span>
<span class="line" id="L58">            out_bits.* = <span class="tok-builtin">@as</span>(<span class="tok-type">usize</span>, <span class="tok-number">0</span>);</span>
<span class="line" id="L59">            <span class="tok-kw">if</span> (U == <span class="tok-type">u0</span> <span class="tok-kw">or</span> bits == <span class="tok-number">0</span>) <span class="tok-kw">return</span> <span class="tok-number">0</span>;</span>
<span class="line" id="L60">            <span class="tok-kw">var</span> out_buffer = <span class="tok-builtin">@as</span>(Buf, <span class="tok-number">0</span>);</span>
<span class="line" id="L61"></span>
<span class="line" id="L62">            <span class="tok-kw">if</span> (self.bit_count &gt; <span class="tok-number">0</span>) {</span>
<span class="line" id="L63">                <span class="tok-kw">const</span> n = <span class="tok-kw">if</span> (self.bit_count &gt;= bits) <span class="tok-builtin">@intCast</span>(<span class="tok-type">u3</span>, bits) <span class="tok-kw">else</span> self.bit_count;</span>
<span class="line" id="L64">                <span class="tok-kw">const</span> shift = u7_bit_count - n;</span>
<span class="line" id="L65">                <span class="tok-kw">switch</span> (endian) {</span>
<span class="line" id="L66">                    .Big =&gt; {</span>
<span class="line" id="L67">                        out_buffer = <span class="tok-builtin">@as</span>(Buf, self.bit_buffer &gt;&gt; shift);</span>
<span class="line" id="L68">                        <span class="tok-kw">if</span> (n &gt;= u7_bit_count)</span>
<span class="line" id="L69">                            self.bit_buffer = <span class="tok-number">0</span></span>
<span class="line" id="L70">                        <span class="tok-kw">else</span></span>
<span class="line" id="L71">                            self.bit_buffer &lt;&lt;= n;</span>
<span class="line" id="L72">                    },</span>
<span class="line" id="L73">                    .Little =&gt; {</span>
<span class="line" id="L74">                        <span class="tok-kw">const</span> value = (self.bit_buffer &lt;&lt; shift) &gt;&gt; shift;</span>
<span class="line" id="L75">                        out_buffer = <span class="tok-builtin">@as</span>(Buf, value);</span>
<span class="line" id="L76">                        <span class="tok-kw">if</span> (n &gt;= u7_bit_count)</span>
<span class="line" id="L77">                            self.bit_buffer = <span class="tok-number">0</span></span>
<span class="line" id="L78">                        <span class="tok-kw">else</span></span>
<span class="line" id="L79">                            self.bit_buffer &gt;&gt;= n;</span>
<span class="line" id="L80">                    },</span>
<span class="line" id="L81">                }</span>
<span class="line" id="L82">                self.bit_count -= n;</span>
<span class="line" id="L83">                out_bits.* = n;</span>
<span class="line" id="L84">            }</span>
<span class="line" id="L85">            <span class="tok-comment">//at this point we know bit_buffer is empty</span>
</span>
<span class="line" id="L86"></span>
<span class="line" id="L87">            <span class="tok-comment">//copy bytes until we have enough bits, then leave the rest in bit_buffer</span>
</span>
<span class="line" id="L88">            <span class="tok-kw">while</span> (out_bits.* &lt; bits) {</span>
<span class="line" id="L89">                <span class="tok-kw">const</span> n = bits - out_bits.*;</span>
<span class="line" id="L90">                <span class="tok-kw">const</span> next_byte = self.forward_reader.readByte() <span class="tok-kw">catch</span> |err| <span class="tok-kw">switch</span> (err) {</span>
<span class="line" id="L91">                    <span class="tok-kw">error</span>.EndOfStream =&gt; <span class="tok-kw">return</span> <span class="tok-builtin">@intCast</span>(U, out_buffer),</span>
<span class="line" id="L92">                    <span class="tok-kw">else</span> =&gt; |e| <span class="tok-kw">return</span> e,</span>
<span class="line" id="L93">                };</span>
<span class="line" id="L94"></span>
<span class="line" id="L95">                <span class="tok-kw">switch</span> (endian) {</span>
<span class="line" id="L96">                    .Big =&gt; {</span>
<span class="line" id="L97">                        <span class="tok-kw">if</span> (n &gt;= u8_bit_count) {</span>
<span class="line" id="L98">                            out_buffer &lt;&lt;= <span class="tok-builtin">@intCast</span>(<span class="tok-type">u3</span>, u8_bit_count - <span class="tok-number">1</span>);</span>
<span class="line" id="L99">                            out_buffer &lt;&lt;= <span class="tok-number">1</span>;</span>
<span class="line" id="L100">                            out_buffer |= <span class="tok-builtin">@as</span>(Buf, next_byte);</span>
<span class="line" id="L101">                            out_bits.* += u8_bit_count;</span>
<span class="line" id="L102">                            <span class="tok-kw">continue</span>;</span>
<span class="line" id="L103">                        }</span>
<span class="line" id="L104"></span>
<span class="line" id="L105">                        <span class="tok-kw">const</span> shift = <span class="tok-builtin">@intCast</span>(<span class="tok-type">u3</span>, u8_bit_count - n);</span>
<span class="line" id="L106">                        out_buffer &lt;&lt;= <span class="tok-builtin">@intCast</span>(BufShift, n);</span>
<span class="line" id="L107">                        out_buffer |= <span class="tok-builtin">@as</span>(Buf, next_byte &gt;&gt; shift);</span>
<span class="line" id="L108">                        out_bits.* += n;</span>
<span class="line" id="L109">                        self.bit_buffer = <span class="tok-builtin">@truncate</span>(<span class="tok-type">u7</span>, next_byte &lt;&lt; <span class="tok-builtin">@intCast</span>(<span class="tok-type">u3</span>, n - <span class="tok-number">1</span>));</span>
<span class="line" id="L110">                        self.bit_count = shift;</span>
<span class="line" id="L111">                    },</span>
<span class="line" id="L112">                    .Little =&gt; {</span>
<span class="line" id="L113">                        <span class="tok-kw">if</span> (n &gt;= u8_bit_count) {</span>
<span class="line" id="L114">                            out_buffer |= <span class="tok-builtin">@as</span>(Buf, next_byte) &lt;&lt; <span class="tok-builtin">@intCast</span>(BufShift, out_bits.*);</span>
<span class="line" id="L115">                            out_bits.* += u8_bit_count;</span>
<span class="line" id="L116">                            <span class="tok-kw">continue</span>;</span>
<span class="line" id="L117">                        }</span>
<span class="line" id="L118"></span>
<span class="line" id="L119">                        <span class="tok-kw">const</span> shift = <span class="tok-builtin">@intCast</span>(<span class="tok-type">u3</span>, u8_bit_count - n);</span>
<span class="line" id="L120">                        <span class="tok-kw">const</span> value = (next_byte &lt;&lt; shift) &gt;&gt; shift;</span>
<span class="line" id="L121">                        out_buffer |= <span class="tok-builtin">@as</span>(Buf, value) &lt;&lt; <span class="tok-builtin">@intCast</span>(BufShift, out_bits.*);</span>
<span class="line" id="L122">                        out_bits.* += n;</span>
<span class="line" id="L123">                        self.bit_buffer = <span class="tok-builtin">@truncate</span>(<span class="tok-type">u7</span>, next_byte &gt;&gt; <span class="tok-builtin">@intCast</span>(<span class="tok-type">u3</span>, n));</span>
<span class="line" id="L124">                        self.bit_count = shift;</span>
<span class="line" id="L125">                    },</span>
<span class="line" id="L126">                }</span>
<span class="line" id="L127">            }</span>
<span class="line" id="L128"></span>
<span class="line" id="L129">            <span class="tok-kw">return</span> <span class="tok-builtin">@intCast</span>(U, out_buffer);</span>
<span class="line" id="L130">        }</span>
<span class="line" id="L131"></span>
<span class="line" id="L132">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">alignToByte</span>(self: *Self) <span class="tok-type">void</span> {</span>
<span class="line" id="L133">            self.bit_buffer = <span class="tok-number">0</span>;</span>
<span class="line" id="L134">            self.bit_count = <span class="tok-number">0</span>;</span>
<span class="line" id="L135">        }</span>
<span class="line" id="L136"></span>
<span class="line" id="L137">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">read</span>(self: *Self, buffer: []<span class="tok-type">u8</span>) Error!<span class="tok-type">usize</span> {</span>
<span class="line" id="L138">            <span class="tok-kw">var</span> out_bits: <span class="tok-type">usize</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L139">            <span class="tok-kw">var</span> out_bits_total = <span class="tok-builtin">@as</span>(<span class="tok-type">usize</span>, <span class="tok-number">0</span>);</span>
<span class="line" id="L140">            <span class="tok-comment">//@NOTE: I'm not sure this is a good idea, maybe alignToByte should be forced</span>
</span>
<span class="line" id="L141">            <span class="tok-kw">if</span> (self.bit_count &gt; <span class="tok-number">0</span>) {</span>
<span class="line" id="L142">                <span class="tok-kw">for</span> (buffer) |*b| {</span>
<span class="line" id="L143">                    b.* = <span class="tok-kw">try</span> self.readBits(<span class="tok-type">u8</span>, u8_bit_count, &amp;out_bits);</span>
<span class="line" id="L144">                    out_bits_total += out_bits;</span>
<span class="line" id="L145">                }</span>
<span class="line" id="L146">                <span class="tok-kw">const</span> incomplete_byte = <span class="tok-builtin">@boolToInt</span>(out_bits_total % u8_bit_count &gt; <span class="tok-number">0</span>);</span>
<span class="line" id="L147">                <span class="tok-kw">return</span> (out_bits_total / u8_bit_count) + incomplete_byte;</span>
<span class="line" id="L148">            }</span>
<span class="line" id="L149"></span>
<span class="line" id="L150">            <span class="tok-kw">return</span> self.forward_reader.read(buffer);</span>
<span class="line" id="L151">        }</span>
<span class="line" id="L152"></span>
<span class="line" id="L153">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">reader</span>(self: *Self) Reader {</span>
<span class="line" id="L154">            <span class="tok-kw">return</span> .{ .context = self };</span>
<span class="line" id="L155">        }</span>
<span class="line" id="L156">    };</span>
<span class="line" id="L157">}</span>
<span class="line" id="L158"></span>
<span class="line" id="L159"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">bitReader</span>(</span>
<span class="line" id="L160">    <span class="tok-kw">comptime</span> endian: std.builtin.Endian,</span>
<span class="line" id="L161">    underlying_stream: <span class="tok-kw">anytype</span>,</span>
<span class="line" id="L162">) BitReader(endian, <span class="tok-builtin">@TypeOf</span>(underlying_stream)) {</span>
<span class="line" id="L163">    <span class="tok-kw">return</span> BitReader(endian, <span class="tok-builtin">@TypeOf</span>(underlying_stream)).init(underlying_stream);</span>
<span class="line" id="L164">}</span>
<span class="line" id="L165"></span>
<span class="line" id="L166"><span class="tok-kw">test</span> <span class="tok-str">&quot;api coverage&quot;</span> {</span>
<span class="line" id="L167">    <span class="tok-kw">const</span> mem_be = [_]<span class="tok-type">u8</span>{ <span class="tok-number">0b11001101</span>, <span class="tok-number">0b00001011</span> };</span>
<span class="line" id="L168">    <span class="tok-kw">const</span> mem_le = [_]<span class="tok-type">u8</span>{ <span class="tok-number">0b00011101</span>, <span class="tok-number">0b10010101</span> };</span>
<span class="line" id="L169"></span>
<span class="line" id="L170">    <span class="tok-kw">var</span> mem_in_be = io.fixedBufferStream(&amp;mem_be);</span>
<span class="line" id="L171">    <span class="tok-kw">var</span> bit_stream_be = bitReader(.Big, mem_in_be.reader());</span>
<span class="line" id="L172"></span>
<span class="line" id="L173">    <span class="tok-kw">var</span> out_bits: <span class="tok-type">usize</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L174"></span>
<span class="line" id="L175">    <span class="tok-kw">const</span> expect = testing.expect;</span>
<span class="line" id="L176">    <span class="tok-kw">const</span> expectError = testing.expectError;</span>
<span class="line" id="L177"></span>
<span class="line" id="L178">    <span class="tok-kw">try</span> expect(<span class="tok-number">1</span> == <span class="tok-kw">try</span> bit_stream_be.readBits(<span class="tok-type">u2</span>, <span class="tok-number">1</span>, &amp;out_bits));</span>
<span class="line" id="L179">    <span class="tok-kw">try</span> expect(out_bits == <span class="tok-number">1</span>);</span>
<span class="line" id="L180">    <span class="tok-kw">try</span> expect(<span class="tok-number">2</span> == <span class="tok-kw">try</span> bit_stream_be.readBits(<span class="tok-type">u5</span>, <span class="tok-number">2</span>, &amp;out_bits));</span>
<span class="line" id="L181">    <span class="tok-kw">try</span> expect(out_bits == <span class="tok-number">2</span>);</span>
<span class="line" id="L182">    <span class="tok-kw">try</span> expect(<span class="tok-number">3</span> == <span class="tok-kw">try</span> bit_stream_be.readBits(<span class="tok-type">u128</span>, <span class="tok-number">3</span>, &amp;out_bits));</span>
<span class="line" id="L183">    <span class="tok-kw">try</span> expect(out_bits == <span class="tok-number">3</span>);</span>
<span class="line" id="L184">    <span class="tok-kw">try</span> expect(<span class="tok-number">4</span> == <span class="tok-kw">try</span> bit_stream_be.readBits(<span class="tok-type">u8</span>, <span class="tok-number">4</span>, &amp;out_bits));</span>
<span class="line" id="L185">    <span class="tok-kw">try</span> expect(out_bits == <span class="tok-number">4</span>);</span>
<span class="line" id="L186">    <span class="tok-kw">try</span> expect(<span class="tok-number">5</span> == <span class="tok-kw">try</span> bit_stream_be.readBits(<span class="tok-type">u9</span>, <span class="tok-number">5</span>, &amp;out_bits));</span>
<span class="line" id="L187">    <span class="tok-kw">try</span> expect(out_bits == <span class="tok-number">5</span>);</span>
<span class="line" id="L188">    <span class="tok-kw">try</span> expect(<span class="tok-number">1</span> == <span class="tok-kw">try</span> bit_stream_be.readBits(<span class="tok-type">u1</span>, <span class="tok-number">1</span>, &amp;out_bits));</span>
<span class="line" id="L189">    <span class="tok-kw">try</span> expect(out_bits == <span class="tok-number">1</span>);</span>
<span class="line" id="L190"></span>
<span class="line" id="L191">    mem_in_be.pos = <span class="tok-number">0</span>;</span>
<span class="line" id="L192">    bit_stream_be.bit_count = <span class="tok-number">0</span>;</span>
<span class="line" id="L193">    <span class="tok-kw">try</span> expect(<span class="tok-number">0b110011010000101</span> == <span class="tok-kw">try</span> bit_stream_be.readBits(<span class="tok-type">u15</span>, <span class="tok-number">15</span>, &amp;out_bits));</span>
<span class="line" id="L194">    <span class="tok-kw">try</span> expect(out_bits == <span class="tok-number">15</span>);</span>
<span class="line" id="L195"></span>
<span class="line" id="L196">    mem_in_be.pos = <span class="tok-number">0</span>;</span>
<span class="line" id="L197">    bit_stream_be.bit_count = <span class="tok-number">0</span>;</span>
<span class="line" id="L198">    <span class="tok-kw">try</span> expect(<span class="tok-number">0b1100110100001011</span> == <span class="tok-kw">try</span> bit_stream_be.readBits(<span class="tok-type">u16</span>, <span class="tok-number">16</span>, &amp;out_bits));</span>
<span class="line" id="L199">    <span class="tok-kw">try</span> expect(out_bits == <span class="tok-number">16</span>);</span>
<span class="line" id="L200"></span>
<span class="line" id="L201">    _ = <span class="tok-kw">try</span> bit_stream_be.readBits(<span class="tok-type">u0</span>, <span class="tok-number">0</span>, &amp;out_bits);</span>
<span class="line" id="L202"></span>
<span class="line" id="L203">    <span class="tok-kw">try</span> expect(<span class="tok-number">0</span> == <span class="tok-kw">try</span> bit_stream_be.readBits(<span class="tok-type">u1</span>, <span class="tok-number">1</span>, &amp;out_bits));</span>
<span class="line" id="L204">    <span class="tok-kw">try</span> expect(out_bits == <span class="tok-number">0</span>);</span>
<span class="line" id="L205">    <span class="tok-kw">try</span> expectError(<span class="tok-kw">error</span>.EndOfStream, bit_stream_be.readBitsNoEof(<span class="tok-type">u1</span>, <span class="tok-number">1</span>));</span>
<span class="line" id="L206"></span>
<span class="line" id="L207">    <span class="tok-kw">var</span> mem_in_le = io.fixedBufferStream(&amp;mem_le);</span>
<span class="line" id="L208">    <span class="tok-kw">var</span> bit_stream_le = bitReader(.Little, mem_in_le.reader());</span>
<span class="line" id="L209"></span>
<span class="line" id="L210">    <span class="tok-kw">try</span> expect(<span class="tok-number">1</span> == <span class="tok-kw">try</span> bit_stream_le.readBits(<span class="tok-type">u2</span>, <span class="tok-number">1</span>, &amp;out_bits));</span>
<span class="line" id="L211">    <span class="tok-kw">try</span> expect(out_bits == <span class="tok-number">1</span>);</span>
<span class="line" id="L212">    <span class="tok-kw">try</span> expect(<span class="tok-number">2</span> == <span class="tok-kw">try</span> bit_stream_le.readBits(<span class="tok-type">u5</span>, <span class="tok-number">2</span>, &amp;out_bits));</span>
<span class="line" id="L213">    <span class="tok-kw">try</span> expect(out_bits == <span class="tok-number">2</span>);</span>
<span class="line" id="L214">    <span class="tok-kw">try</span> expect(<span class="tok-number">3</span> == <span class="tok-kw">try</span> bit_stream_le.readBits(<span class="tok-type">u128</span>, <span class="tok-number">3</span>, &amp;out_bits));</span>
<span class="line" id="L215">    <span class="tok-kw">try</span> expect(out_bits == <span class="tok-number">3</span>);</span>
<span class="line" id="L216">    <span class="tok-kw">try</span> expect(<span class="tok-number">4</span> == <span class="tok-kw">try</span> bit_stream_le.readBits(<span class="tok-type">u8</span>, <span class="tok-number">4</span>, &amp;out_bits));</span>
<span class="line" id="L217">    <span class="tok-kw">try</span> expect(out_bits == <span class="tok-number">4</span>);</span>
<span class="line" id="L218">    <span class="tok-kw">try</span> expect(<span class="tok-number">5</span> == <span class="tok-kw">try</span> bit_stream_le.readBits(<span class="tok-type">u9</span>, <span class="tok-number">5</span>, &amp;out_bits));</span>
<span class="line" id="L219">    <span class="tok-kw">try</span> expect(out_bits == <span class="tok-number">5</span>);</span>
<span class="line" id="L220">    <span class="tok-kw">try</span> expect(<span class="tok-number">1</span> == <span class="tok-kw">try</span> bit_stream_le.readBits(<span class="tok-type">u1</span>, <span class="tok-number">1</span>, &amp;out_bits));</span>
<span class="line" id="L221">    <span class="tok-kw">try</span> expect(out_bits == <span class="tok-number">1</span>);</span>
<span class="line" id="L222"></span>
<span class="line" id="L223">    mem_in_le.pos = <span class="tok-number">0</span>;</span>
<span class="line" id="L224">    bit_stream_le.bit_count = <span class="tok-number">0</span>;</span>
<span class="line" id="L225">    <span class="tok-kw">try</span> expect(<span class="tok-number">0b001010100011101</span> == <span class="tok-kw">try</span> bit_stream_le.readBits(<span class="tok-type">u15</span>, <span class="tok-number">15</span>, &amp;out_bits));</span>
<span class="line" id="L226">    <span class="tok-kw">try</span> expect(out_bits == <span class="tok-number">15</span>);</span>
<span class="line" id="L227"></span>
<span class="line" id="L228">    mem_in_le.pos = <span class="tok-number">0</span>;</span>
<span class="line" id="L229">    bit_stream_le.bit_count = <span class="tok-number">0</span>;</span>
<span class="line" id="L230">    <span class="tok-kw">try</span> expect(<span class="tok-number">0b1001010100011101</span> == <span class="tok-kw">try</span> bit_stream_le.readBits(<span class="tok-type">u16</span>, <span class="tok-number">16</span>, &amp;out_bits));</span>
<span class="line" id="L231">    <span class="tok-kw">try</span> expect(out_bits == <span class="tok-number">16</span>);</span>
<span class="line" id="L232"></span>
<span class="line" id="L233">    _ = <span class="tok-kw">try</span> bit_stream_le.readBits(<span class="tok-type">u0</span>, <span class="tok-number">0</span>, &amp;out_bits);</span>
<span class="line" id="L234"></span>
<span class="line" id="L235">    <span class="tok-kw">try</span> expect(<span class="tok-number">0</span> == <span class="tok-kw">try</span> bit_stream_le.readBits(<span class="tok-type">u1</span>, <span class="tok-number">1</span>, &amp;out_bits));</span>
<span class="line" id="L236">    <span class="tok-kw">try</span> expect(out_bits == <span class="tok-number">0</span>);</span>
<span class="line" id="L237">    <span class="tok-kw">try</span> expectError(<span class="tok-kw">error</span>.EndOfStream, bit_stream_le.readBitsNoEof(<span class="tok-type">u1</span>, <span class="tok-number">1</span>));</span>
<span class="line" id="L238">}</span>
<span class="line" id="L239"></span>
</code></pre></body>
</html>