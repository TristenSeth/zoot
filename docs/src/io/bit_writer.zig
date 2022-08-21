<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">    <title>io/bit_writer.zig - source view</title>
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
<span class="line" id="L3"><span class="tok-kw">const</span> testing = std.testing;</span>
<span class="line" id="L4"><span class="tok-kw">const</span> assert = std.debug.assert;</span>
<span class="line" id="L5"><span class="tok-kw">const</span> trait = std.meta.trait;</span>
<span class="line" id="L6"><span class="tok-kw">const</span> meta = std.meta;</span>
<span class="line" id="L7"><span class="tok-kw">const</span> math = std.math;</span>
<span class="line" id="L8"></span>
<span class="line" id="L9"><span class="tok-comment">/// Creates a stream which allows for writing bit fields to another stream</span></span>
<span class="line" id="L10"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">BitWriter</span>(endian: std.builtin.Endian, <span class="tok-kw">comptime</span> WriterType: <span class="tok-type">type</span>) <span class="tok-type">type</span> {</span>
<span class="line" id="L11">    <span class="tok-kw">return</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L12">        forward_writer: WriterType,</span>
<span class="line" id="L13">        bit_buffer: <span class="tok-type">u8</span>,</span>
<span class="line" id="L14">        bit_count: <span class="tok-type">u4</span>,</span>
<span class="line" id="L15"></span>
<span class="line" id="L16">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> Error = WriterType.Error;</span>
<span class="line" id="L17">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> Writer = io.Writer(*Self, Error, write);</span>
<span class="line" id="L18"></span>
<span class="line" id="L19">        <span class="tok-kw">const</span> Self = <span class="tok-builtin">@This</span>();</span>
<span class="line" id="L20">        <span class="tok-kw">const</span> u8_bit_count = <span class="tok-builtin">@bitSizeOf</span>(<span class="tok-type">u8</span>);</span>
<span class="line" id="L21">        <span class="tok-kw">const</span> u4_bit_count = <span class="tok-builtin">@bitSizeOf</span>(<span class="tok-type">u4</span>);</span>
<span class="line" id="L22"></span>
<span class="line" id="L23">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">init</span>(forward_writer: WriterType) Self {</span>
<span class="line" id="L24">            <span class="tok-kw">return</span> Self{</span>
<span class="line" id="L25">                .forward_writer = forward_writer,</span>
<span class="line" id="L26">                .bit_buffer = <span class="tok-number">0</span>,</span>
<span class="line" id="L27">                .bit_count = <span class="tok-number">0</span>,</span>
<span class="line" id="L28">            };</span>
<span class="line" id="L29">        }</span>
<span class="line" id="L30"></span>
<span class="line" id="L31">        <span class="tok-comment">/// Write the specified number of bits to the stream from the least significant bits of</span></span>
<span class="line" id="L32">        <span class="tok-comment">///  the specified unsigned int value. Bits will only be written to the stream when there</span></span>
<span class="line" id="L33">        <span class="tok-comment">///  are enough to fill a byte.</span></span>
<span class="line" id="L34">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">writeBits</span>(self: *Self, value: <span class="tok-kw">anytype</span>, bits: <span class="tok-type">usize</span>) Error!<span class="tok-type">void</span> {</span>
<span class="line" id="L35">            <span class="tok-kw">if</span> (bits == <span class="tok-number">0</span>) <span class="tok-kw">return</span>;</span>
<span class="line" id="L36"></span>
<span class="line" id="L37">            <span class="tok-kw">const</span> U = <span class="tok-builtin">@TypeOf</span>(value);</span>
<span class="line" id="L38">            <span class="tok-kw">comptime</span> assert(trait.isUnsignedInt(U));</span>
<span class="line" id="L39"></span>
<span class="line" id="L40">            <span class="tok-comment">//by extending the buffer to a minimum of u8 we can cover a number of edge cases</span>
</span>
<span class="line" id="L41">            <span class="tok-comment">// related to shifting and casting.</span>
</span>
<span class="line" id="L42">            <span class="tok-kw">const</span> u_bit_count = <span class="tok-builtin">@bitSizeOf</span>(U);</span>
<span class="line" id="L43">            <span class="tok-kw">const</span> buf_bit_count = bc: {</span>
<span class="line" id="L44">                assert(u_bit_count &gt;= bits);</span>
<span class="line" id="L45">                <span class="tok-kw">break</span> :bc <span class="tok-kw">if</span> (u_bit_count &lt;= u8_bit_count) u8_bit_count <span class="tok-kw">else</span> u_bit_count;</span>
<span class="line" id="L46">            };</span>
<span class="line" id="L47">            <span class="tok-kw">const</span> Buf = std.meta.Int(.unsigned, buf_bit_count);</span>
<span class="line" id="L48">            <span class="tok-kw">const</span> BufShift = math.Log2Int(Buf);</span>
<span class="line" id="L49"></span>
<span class="line" id="L50">            <span class="tok-kw">const</span> buf_value = <span class="tok-builtin">@intCast</span>(Buf, value);</span>
<span class="line" id="L51"></span>
<span class="line" id="L52">            <span class="tok-kw">const</span> high_byte_shift = <span class="tok-builtin">@intCast</span>(BufShift, buf_bit_count - u8_bit_count);</span>
<span class="line" id="L53">            <span class="tok-kw">var</span> in_buffer = <span class="tok-kw">switch</span> (endian) {</span>
<span class="line" id="L54">                .Big =&gt; buf_value &lt;&lt; <span class="tok-builtin">@intCast</span>(BufShift, buf_bit_count - bits),</span>
<span class="line" id="L55">                .Little =&gt; buf_value,</span>
<span class="line" id="L56">            };</span>
<span class="line" id="L57">            <span class="tok-kw">var</span> in_bits = bits;</span>
<span class="line" id="L58"></span>
<span class="line" id="L59">            <span class="tok-kw">if</span> (self.bit_count &gt; <span class="tok-number">0</span>) {</span>
<span class="line" id="L60">                <span class="tok-kw">const</span> bits_remaining = u8_bit_count - self.bit_count;</span>
<span class="line" id="L61">                <span class="tok-kw">const</span> n = <span class="tok-builtin">@intCast</span>(<span class="tok-type">u3</span>, <span class="tok-kw">if</span> (bits_remaining &gt; bits) bits <span class="tok-kw">else</span> bits_remaining);</span>
<span class="line" id="L62">                <span class="tok-kw">switch</span> (endian) {</span>
<span class="line" id="L63">                    .Big =&gt; {</span>
<span class="line" id="L64">                        <span class="tok-kw">const</span> shift = <span class="tok-builtin">@intCast</span>(BufShift, high_byte_shift + self.bit_count);</span>
<span class="line" id="L65">                        <span class="tok-kw">const</span> v = <span class="tok-builtin">@intCast</span>(<span class="tok-type">u8</span>, in_buffer &gt;&gt; shift);</span>
<span class="line" id="L66">                        self.bit_buffer |= v;</span>
<span class="line" id="L67">                        in_buffer &lt;&lt;= n;</span>
<span class="line" id="L68">                    },</span>
<span class="line" id="L69">                    .Little =&gt; {</span>
<span class="line" id="L70">                        <span class="tok-kw">const</span> v = <span class="tok-builtin">@truncate</span>(<span class="tok-type">u8</span>, in_buffer) &lt;&lt; <span class="tok-builtin">@intCast</span>(<span class="tok-type">u3</span>, self.bit_count);</span>
<span class="line" id="L71">                        self.bit_buffer |= v;</span>
<span class="line" id="L72">                        in_buffer &gt;&gt;= n;</span>
<span class="line" id="L73">                    },</span>
<span class="line" id="L74">                }</span>
<span class="line" id="L75">                self.bit_count += n;</span>
<span class="line" id="L76">                in_bits -= n;</span>
<span class="line" id="L77"></span>
<span class="line" id="L78">                <span class="tok-comment">//if we didn't fill the buffer, it's because bits &lt; bits_remaining;</span>
</span>
<span class="line" id="L79">                <span class="tok-kw">if</span> (self.bit_count != u8_bit_count) <span class="tok-kw">return</span>;</span>
<span class="line" id="L80">                <span class="tok-kw">try</span> self.forward_writer.writeByte(self.bit_buffer);</span>
<span class="line" id="L81">                self.bit_buffer = <span class="tok-number">0</span>;</span>
<span class="line" id="L82">                self.bit_count = <span class="tok-number">0</span>;</span>
<span class="line" id="L83">            }</span>
<span class="line" id="L84">            <span class="tok-comment">//at this point we know bit_buffer is empty</span>
</span>
<span class="line" id="L85"></span>
<span class="line" id="L86">            <span class="tok-comment">//copy bytes until we can't fill one anymore, then leave the rest in bit_buffer</span>
</span>
<span class="line" id="L87">            <span class="tok-kw">while</span> (in_bits &gt;= u8_bit_count) {</span>
<span class="line" id="L88">                <span class="tok-kw">switch</span> (endian) {</span>
<span class="line" id="L89">                    .Big =&gt; {</span>
<span class="line" id="L90">                        <span class="tok-kw">const</span> v = <span class="tok-builtin">@intCast</span>(<span class="tok-type">u8</span>, in_buffer &gt;&gt; high_byte_shift);</span>
<span class="line" id="L91">                        <span class="tok-kw">try</span> self.forward_writer.writeByte(v);</span>
<span class="line" id="L92">                        in_buffer &lt;&lt;= <span class="tok-builtin">@intCast</span>(<span class="tok-type">u3</span>, u8_bit_count - <span class="tok-number">1</span>);</span>
<span class="line" id="L93">                        in_buffer &lt;&lt;= <span class="tok-number">1</span>;</span>
<span class="line" id="L94">                    },</span>
<span class="line" id="L95">                    .Little =&gt; {</span>
<span class="line" id="L96">                        <span class="tok-kw">const</span> v = <span class="tok-builtin">@truncate</span>(<span class="tok-type">u8</span>, in_buffer);</span>
<span class="line" id="L97">                        <span class="tok-kw">try</span> self.forward_writer.writeByte(v);</span>
<span class="line" id="L98">                        in_buffer &gt;&gt;= <span class="tok-builtin">@intCast</span>(<span class="tok-type">u3</span>, u8_bit_count - <span class="tok-number">1</span>);</span>
<span class="line" id="L99">                        in_buffer &gt;&gt;= <span class="tok-number">1</span>;</span>
<span class="line" id="L100">                    },</span>
<span class="line" id="L101">                }</span>
<span class="line" id="L102">                in_bits -= u8_bit_count;</span>
<span class="line" id="L103">            }</span>
<span class="line" id="L104"></span>
<span class="line" id="L105">            <span class="tok-kw">if</span> (in_bits &gt; <span class="tok-number">0</span>) {</span>
<span class="line" id="L106">                self.bit_count = <span class="tok-builtin">@intCast</span>(<span class="tok-type">u4</span>, in_bits);</span>
<span class="line" id="L107">                self.bit_buffer = <span class="tok-kw">switch</span> (endian) {</span>
<span class="line" id="L108">                    .Big =&gt; <span class="tok-builtin">@truncate</span>(<span class="tok-type">u8</span>, in_buffer &gt;&gt; high_byte_shift),</span>
<span class="line" id="L109">                    .Little =&gt; <span class="tok-builtin">@truncate</span>(<span class="tok-type">u8</span>, in_buffer),</span>
<span class="line" id="L110">                };</span>
<span class="line" id="L111">            }</span>
<span class="line" id="L112">        }</span>
<span class="line" id="L113"></span>
<span class="line" id="L114">        <span class="tok-comment">/// Flush any remaining bits to the stream.</span></span>
<span class="line" id="L115">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">flushBits</span>(self: *Self) Error!<span class="tok-type">void</span> {</span>
<span class="line" id="L116">            <span class="tok-kw">if</span> (self.bit_count == <span class="tok-number">0</span>) <span class="tok-kw">return</span>;</span>
<span class="line" id="L117">            <span class="tok-kw">try</span> self.forward_writer.writeByte(self.bit_buffer);</span>
<span class="line" id="L118">            self.bit_buffer = <span class="tok-number">0</span>;</span>
<span class="line" id="L119">            self.bit_count = <span class="tok-number">0</span>;</span>
<span class="line" id="L120">        }</span>
<span class="line" id="L121"></span>
<span class="line" id="L122">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">write</span>(self: *Self, buffer: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) Error!<span class="tok-type">usize</span> {</span>
<span class="line" id="L123">            <span class="tok-comment">// TODO: I'm not sure this is a good idea, maybe flushBits should be forced</span>
</span>
<span class="line" id="L124">            <span class="tok-kw">if</span> (self.bit_count &gt; <span class="tok-number">0</span>) {</span>
<span class="line" id="L125">                <span class="tok-kw">for</span> (buffer) |b|</span>
<span class="line" id="L126">                    <span class="tok-kw">try</span> self.writeBits(b, u8_bit_count);</span>
<span class="line" id="L127">                <span class="tok-kw">return</span> buffer.len;</span>
<span class="line" id="L128">            }</span>
<span class="line" id="L129"></span>
<span class="line" id="L130">            <span class="tok-kw">return</span> self.forward_writer.write(buffer);</span>
<span class="line" id="L131">        }</span>
<span class="line" id="L132"></span>
<span class="line" id="L133">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">writer</span>(self: *Self) Writer {</span>
<span class="line" id="L134">            <span class="tok-kw">return</span> .{ .context = self };</span>
<span class="line" id="L135">        }</span>
<span class="line" id="L136">    };</span>
<span class="line" id="L137">}</span>
<span class="line" id="L138"></span>
<span class="line" id="L139"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">bitWriter</span>(</span>
<span class="line" id="L140">    <span class="tok-kw">comptime</span> endian: std.builtin.Endian,</span>
<span class="line" id="L141">    underlying_stream: <span class="tok-kw">anytype</span>,</span>
<span class="line" id="L142">) BitWriter(endian, <span class="tok-builtin">@TypeOf</span>(underlying_stream)) {</span>
<span class="line" id="L143">    <span class="tok-kw">return</span> BitWriter(endian, <span class="tok-builtin">@TypeOf</span>(underlying_stream)).init(underlying_stream);</span>
<span class="line" id="L144">}</span>
<span class="line" id="L145"></span>
<span class="line" id="L146"><span class="tok-kw">test</span> <span class="tok-str">&quot;api coverage&quot;</span> {</span>
<span class="line" id="L147">    <span class="tok-kw">var</span> mem_be = [_]<span class="tok-type">u8</span>{<span class="tok-number">0</span>} ** <span class="tok-number">2</span>;</span>
<span class="line" id="L148">    <span class="tok-kw">var</span> mem_le = [_]<span class="tok-type">u8</span>{<span class="tok-number">0</span>} ** <span class="tok-number">2</span>;</span>
<span class="line" id="L149"></span>
<span class="line" id="L150">    <span class="tok-kw">var</span> mem_out_be = io.fixedBufferStream(&amp;mem_be);</span>
<span class="line" id="L151">    <span class="tok-kw">var</span> bit_stream_be = bitWriter(.Big, mem_out_be.writer());</span>
<span class="line" id="L152"></span>
<span class="line" id="L153">    <span class="tok-kw">try</span> bit_stream_be.writeBits(<span class="tok-builtin">@as</span>(<span class="tok-type">u2</span>, <span class="tok-number">1</span>), <span class="tok-number">1</span>);</span>
<span class="line" id="L154">    <span class="tok-kw">try</span> bit_stream_be.writeBits(<span class="tok-builtin">@as</span>(<span class="tok-type">u5</span>, <span class="tok-number">2</span>), <span class="tok-number">2</span>);</span>
<span class="line" id="L155">    <span class="tok-kw">try</span> bit_stream_be.writeBits(<span class="tok-builtin">@as</span>(<span class="tok-type">u128</span>, <span class="tok-number">3</span>), <span class="tok-number">3</span>);</span>
<span class="line" id="L156">    <span class="tok-kw">try</span> bit_stream_be.writeBits(<span class="tok-builtin">@as</span>(<span class="tok-type">u8</span>, <span class="tok-number">4</span>), <span class="tok-number">4</span>);</span>
<span class="line" id="L157">    <span class="tok-kw">try</span> bit_stream_be.writeBits(<span class="tok-builtin">@as</span>(<span class="tok-type">u9</span>, <span class="tok-number">5</span>), <span class="tok-number">5</span>);</span>
<span class="line" id="L158">    <span class="tok-kw">try</span> bit_stream_be.writeBits(<span class="tok-builtin">@as</span>(<span class="tok-type">u1</span>, <span class="tok-number">1</span>), <span class="tok-number">1</span>);</span>
<span class="line" id="L159"></span>
<span class="line" id="L160">    <span class="tok-kw">try</span> testing.expect(mem_be[<span class="tok-number">0</span>] == <span class="tok-number">0b11001101</span> <span class="tok-kw">and</span> mem_be[<span class="tok-number">1</span>] == <span class="tok-number">0b00001011</span>);</span>
<span class="line" id="L161"></span>
<span class="line" id="L162">    mem_out_be.pos = <span class="tok-number">0</span>;</span>
<span class="line" id="L163"></span>
<span class="line" id="L164">    <span class="tok-kw">try</span> bit_stream_be.writeBits(<span class="tok-builtin">@as</span>(<span class="tok-type">u15</span>, <span class="tok-number">0b110011010000101</span>), <span class="tok-number">15</span>);</span>
<span class="line" id="L165">    <span class="tok-kw">try</span> bit_stream_be.flushBits();</span>
<span class="line" id="L166">    <span class="tok-kw">try</span> testing.expect(mem_be[<span class="tok-number">0</span>] == <span class="tok-number">0b11001101</span> <span class="tok-kw">and</span> mem_be[<span class="tok-number">1</span>] == <span class="tok-number">0b00001010</span>);</span>
<span class="line" id="L167"></span>
<span class="line" id="L168">    mem_out_be.pos = <span class="tok-number">0</span>;</span>
<span class="line" id="L169">    <span class="tok-kw">try</span> bit_stream_be.writeBits(<span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">0b110011010000101</span>), <span class="tok-number">16</span>);</span>
<span class="line" id="L170">    <span class="tok-kw">try</span> testing.expect(mem_be[<span class="tok-number">0</span>] == <span class="tok-number">0b01100110</span> <span class="tok-kw">and</span> mem_be[<span class="tok-number">1</span>] == <span class="tok-number">0b10000101</span>);</span>
<span class="line" id="L171"></span>
<span class="line" id="L172">    <span class="tok-kw">try</span> bit_stream_be.writeBits(<span class="tok-builtin">@as</span>(<span class="tok-type">u0</span>, <span class="tok-number">0</span>), <span class="tok-number">0</span>);</span>
<span class="line" id="L173"></span>
<span class="line" id="L174">    <span class="tok-kw">var</span> mem_out_le = io.fixedBufferStream(&amp;mem_le);</span>
<span class="line" id="L175">    <span class="tok-kw">var</span> bit_stream_le = bitWriter(.Little, mem_out_le.writer());</span>
<span class="line" id="L176"></span>
<span class="line" id="L177">    <span class="tok-kw">try</span> bit_stream_le.writeBits(<span class="tok-builtin">@as</span>(<span class="tok-type">u2</span>, <span class="tok-number">1</span>), <span class="tok-number">1</span>);</span>
<span class="line" id="L178">    <span class="tok-kw">try</span> bit_stream_le.writeBits(<span class="tok-builtin">@as</span>(<span class="tok-type">u5</span>, <span class="tok-number">2</span>), <span class="tok-number">2</span>);</span>
<span class="line" id="L179">    <span class="tok-kw">try</span> bit_stream_le.writeBits(<span class="tok-builtin">@as</span>(<span class="tok-type">u128</span>, <span class="tok-number">3</span>), <span class="tok-number">3</span>);</span>
<span class="line" id="L180">    <span class="tok-kw">try</span> bit_stream_le.writeBits(<span class="tok-builtin">@as</span>(<span class="tok-type">u8</span>, <span class="tok-number">4</span>), <span class="tok-number">4</span>);</span>
<span class="line" id="L181">    <span class="tok-kw">try</span> bit_stream_le.writeBits(<span class="tok-builtin">@as</span>(<span class="tok-type">u9</span>, <span class="tok-number">5</span>), <span class="tok-number">5</span>);</span>
<span class="line" id="L182">    <span class="tok-kw">try</span> bit_stream_le.writeBits(<span class="tok-builtin">@as</span>(<span class="tok-type">u1</span>, <span class="tok-number">1</span>), <span class="tok-number">1</span>);</span>
<span class="line" id="L183"></span>
<span class="line" id="L184">    <span class="tok-kw">try</span> testing.expect(mem_le[<span class="tok-number">0</span>] == <span class="tok-number">0b00011101</span> <span class="tok-kw">and</span> mem_le[<span class="tok-number">1</span>] == <span class="tok-number">0b10010101</span>);</span>
<span class="line" id="L185"></span>
<span class="line" id="L186">    mem_out_le.pos = <span class="tok-number">0</span>;</span>
<span class="line" id="L187">    <span class="tok-kw">try</span> bit_stream_le.writeBits(<span class="tok-builtin">@as</span>(<span class="tok-type">u15</span>, <span class="tok-number">0b110011010000101</span>), <span class="tok-number">15</span>);</span>
<span class="line" id="L188">    <span class="tok-kw">try</span> bit_stream_le.flushBits();</span>
<span class="line" id="L189">    <span class="tok-kw">try</span> testing.expect(mem_le[<span class="tok-number">0</span>] == <span class="tok-number">0b10000101</span> <span class="tok-kw">and</span> mem_le[<span class="tok-number">1</span>] == <span class="tok-number">0b01100110</span>);</span>
<span class="line" id="L190"></span>
<span class="line" id="L191">    mem_out_le.pos = <span class="tok-number">0</span>;</span>
<span class="line" id="L192">    <span class="tok-kw">try</span> bit_stream_le.writeBits(<span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">0b1100110100001011</span>), <span class="tok-number">16</span>);</span>
<span class="line" id="L193">    <span class="tok-kw">try</span> testing.expect(mem_le[<span class="tok-number">0</span>] == <span class="tok-number">0b00001011</span> <span class="tok-kw">and</span> mem_le[<span class="tok-number">1</span>] == <span class="tok-number">0b11001101</span>);</span>
<span class="line" id="L194"></span>
<span class="line" id="L195">    <span class="tok-kw">try</span> bit_stream_le.writeBits(<span class="tok-builtin">@as</span>(<span class="tok-type">u0</span>, <span class="tok-number">0</span>), <span class="tok-number">0</span>);</span>
<span class="line" id="L196">}</span>
<span class="line" id="L197"></span>
</code></pre></body>
</html>