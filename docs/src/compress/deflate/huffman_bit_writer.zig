<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">    <title>compress/deflate/huffman_bit_writer.zig - source view</title>
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
<span class="line" id="L2"><span class="tok-kw">const</span> builtin = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;builtin&quot;</span>);</span>
<span class="line" id="L3"><span class="tok-kw">const</span> io = std.io;</span>
<span class="line" id="L4"></span>
<span class="line" id="L5"><span class="tok-kw">const</span> Allocator = std.mem.Allocator;</span>
<span class="line" id="L6"></span>
<span class="line" id="L7"><span class="tok-kw">const</span> deflate_const = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;deflate_const.zig&quot;</span>);</span>
<span class="line" id="L8"><span class="tok-kw">const</span> hm_code = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;huffman_code.zig&quot;</span>);</span>
<span class="line" id="L9"><span class="tok-kw">const</span> token = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;token.zig&quot;</span>);</span>
<span class="line" id="L10"></span>
<span class="line" id="L11"><span class="tok-comment">// The first length code.</span>
</span>
<span class="line" id="L12"><span class="tok-kw">const</span> length_codes_start = <span class="tok-number">257</span>;</span>
<span class="line" id="L13"></span>
<span class="line" id="L14"><span class="tok-comment">// The number of codegen codes.</span>
</span>
<span class="line" id="L15"><span class="tok-kw">const</span> codegen_code_count = <span class="tok-number">19</span>;</span>
<span class="line" id="L16"><span class="tok-kw">const</span> bad_code = <span class="tok-number">255</span>;</span>
<span class="line" id="L17"></span>
<span class="line" id="L18"><span class="tok-comment">// buffer_flush_size indicates the buffer size</span>
</span>
<span class="line" id="L19"><span class="tok-comment">// after which bytes are flushed to the writer.</span>
</span>
<span class="line" id="L20"><span class="tok-comment">// Should preferably be a multiple of 6, since</span>
</span>
<span class="line" id="L21"><span class="tok-comment">// we accumulate 6 bytes between writes to the buffer.</span>
</span>
<span class="line" id="L22"><span class="tok-kw">const</span> buffer_flush_size = <span class="tok-number">240</span>;</span>
<span class="line" id="L23"></span>
<span class="line" id="L24"><span class="tok-comment">// buffer_size is the actual output byte buffer size.</span>
</span>
<span class="line" id="L25"><span class="tok-comment">// It must have additional headroom for a flush</span>
</span>
<span class="line" id="L26"><span class="tok-comment">// which can contain up to 8 bytes.</span>
</span>
<span class="line" id="L27"><span class="tok-kw">const</span> buffer_size = buffer_flush_size + <span class="tok-number">8</span>;</span>
<span class="line" id="L28"></span>
<span class="line" id="L29"><span class="tok-comment">// The number of extra bits needed by length code X - LENGTH_CODES_START.</span>
</span>
<span class="line" id="L30"><span class="tok-kw">var</span> length_extra_bits = [_]<span class="tok-type">u8</span>{</span>
<span class="line" id="L31">    <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-comment">// 257</span>
</span>
<span class="line" id="L32">    <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">1</span>, <span class="tok-number">1</span>, <span class="tok-number">1</span>, <span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-comment">// 260</span>
</span>
<span class="line" id="L33">    <span class="tok-number">2</span>, <span class="tok-number">2</span>, <span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">3</span>, <span class="tok-number">3</span>, <span class="tok-number">3</span>, <span class="tok-number">4</span>, <span class="tok-number">4</span>, <span class="tok-number">4</span>, <span class="tok-comment">// 270</span>
</span>
<span class="line" id="L34">    <span class="tok-number">4</span>, <span class="tok-number">5</span>, <span class="tok-number">5</span>, <span class="tok-number">5</span>, <span class="tok-number">5</span>, <span class="tok-number">0</span>, <span class="tok-comment">// 280</span>
</span>
<span class="line" id="L35">};</span>
<span class="line" id="L36"></span>
<span class="line" id="L37"><span class="tok-comment">// The length indicated by length code X - LENGTH_CODES_START.</span>
</span>
<span class="line" id="L38"><span class="tok-kw">var</span> length_base = [_]<span class="tok-type">u32</span>{</span>
<span class="line" id="L39">    <span class="tok-number">0</span>,  <span class="tok-number">1</span>,  <span class="tok-number">2</span>,  <span class="tok-number">3</span>,   <span class="tok-number">4</span>,   <span class="tok-number">5</span>,   <span class="tok-number">6</span>,   <span class="tok-number">7</span>,   <span class="tok-number">8</span>,   <span class="tok-number">10</span>,</span>
<span class="line" id="L40">    <span class="tok-number">12</span>, <span class="tok-number">14</span>, <span class="tok-number">16</span>, <span class="tok-number">20</span>,  <span class="tok-number">24</span>,  <span class="tok-number">28</span>,  <span class="tok-number">32</span>,  <span class="tok-number">40</span>,  <span class="tok-number">48</span>,  <span class="tok-number">56</span>,</span>
<span class="line" id="L41">    <span class="tok-number">64</span>, <span class="tok-number">80</span>, <span class="tok-number">96</span>, <span class="tok-number">112</span>, <span class="tok-number">128</span>, <span class="tok-number">160</span>, <span class="tok-number">192</span>, <span class="tok-number">224</span>, <span class="tok-number">255</span>,</span>
<span class="line" id="L42">};</span>
<span class="line" id="L43"></span>
<span class="line" id="L44"><span class="tok-comment">// offset code word extra bits.</span>
</span>
<span class="line" id="L45"><span class="tok-kw">var</span> offset_extra_bits = [_]<span class="tok-type">i8</span>{</span>
<span class="line" id="L46">    <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>,  <span class="tok-number">0</span>,  <span class="tok-number">1</span>,  <span class="tok-number">1</span>,  <span class="tok-number">2</span>,  <span class="tok-number">2</span>,  <span class="tok-number">3</span>,  <span class="tok-number">3</span>,</span>
<span class="line" id="L47">    <span class="tok-number">4</span>, <span class="tok-number">4</span>, <span class="tok-number">5</span>,  <span class="tok-number">5</span>,  <span class="tok-number">6</span>,  <span class="tok-number">6</span>,  <span class="tok-number">7</span>,  <span class="tok-number">7</span>,  <span class="tok-number">8</span>,  <span class="tok-number">8</span>,</span>
<span class="line" id="L48">    <span class="tok-number">9</span>, <span class="tok-number">9</span>, <span class="tok-number">10</span>, <span class="tok-number">10</span>, <span class="tok-number">11</span>, <span class="tok-number">11</span>, <span class="tok-number">12</span>, <span class="tok-number">12</span>, <span class="tok-number">13</span>, <span class="tok-number">13</span>,</span>
<span class="line" id="L49">};</span>
<span class="line" id="L50"></span>
<span class="line" id="L51"><span class="tok-kw">var</span> offset_base = [_]<span class="tok-type">u32</span>{</span>
<span class="line" id="L52">    <span class="tok-number">0x000000</span>, <span class="tok-number">0x000001</span>, <span class="tok-number">0x000002</span>, <span class="tok-number">0x000003</span>, <span class="tok-number">0x000004</span>,</span>
<span class="line" id="L53">    <span class="tok-number">0x000006</span>, <span class="tok-number">0x000008</span>, <span class="tok-number">0x00000c</span>, <span class="tok-number">0x000010</span>, <span class="tok-number">0x000018</span>,</span>
<span class="line" id="L54">    <span class="tok-number">0x000020</span>, <span class="tok-number">0x000030</span>, <span class="tok-number">0x000040</span>, <span class="tok-number">0x000060</span>, <span class="tok-number">0x000080</span>,</span>
<span class="line" id="L55">    <span class="tok-number">0x0000c0</span>, <span class="tok-number">0x000100</span>, <span class="tok-number">0x000180</span>, <span class="tok-number">0x000200</span>, <span class="tok-number">0x000300</span>,</span>
<span class="line" id="L56">    <span class="tok-number">0x000400</span>, <span class="tok-number">0x000600</span>, <span class="tok-number">0x000800</span>, <span class="tok-number">0x000c00</span>, <span class="tok-number">0x001000</span>,</span>
<span class="line" id="L57">    <span class="tok-number">0x001800</span>, <span class="tok-number">0x002000</span>, <span class="tok-number">0x003000</span>, <span class="tok-number">0x004000</span>, <span class="tok-number">0x006000</span>,</span>
<span class="line" id="L58">};</span>
<span class="line" id="L59"></span>
<span class="line" id="L60"><span class="tok-comment">// The odd order in which the codegen code sizes are written.</span>
</span>
<span class="line" id="L61"><span class="tok-kw">var</span> codegen_order = [_]<span class="tok-type">u32</span>{ <span class="tok-number">16</span>, <span class="tok-number">17</span>, <span class="tok-number">18</span>, <span class="tok-number">0</span>, <span class="tok-number">8</span>, <span class="tok-number">7</span>, <span class="tok-number">9</span>, <span class="tok-number">6</span>, <span class="tok-number">10</span>, <span class="tok-number">5</span>, <span class="tok-number">11</span>, <span class="tok-number">4</span>, <span class="tok-number">12</span>, <span class="tok-number">3</span>, <span class="tok-number">13</span>, <span class="tok-number">2</span>, <span class="tok-number">14</span>, <span class="tok-number">1</span>, <span class="tok-number">15</span> };</span>
<span class="line" id="L62"></span>
<span class="line" id="L63"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">HuffmanBitWriter</span>(<span class="tok-kw">comptime</span> WriterType: <span class="tok-type">type</span>) <span class="tok-type">type</span> {</span>
<span class="line" id="L64">    <span class="tok-kw">return</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L65">        <span class="tok-kw">const</span> Self = <span class="tok-builtin">@This</span>();</span>
<span class="line" id="L66">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> Error = WriterType.Error;</span>
<span class="line" id="L67"></span>
<span class="line" id="L68">        <span class="tok-comment">// writer is the underlying writer.</span>
</span>
<span class="line" id="L69">        <span class="tok-comment">// Do not use it directly; use the write method, which ensures</span>
</span>
<span class="line" id="L70">        <span class="tok-comment">// that Write errors are sticky.</span>
</span>
<span class="line" id="L71">        inner_writer: WriterType,</span>
<span class="line" id="L72">        bytes_written: <span class="tok-type">usize</span>,</span>
<span class="line" id="L73"></span>
<span class="line" id="L74">        <span class="tok-comment">// Data waiting to be written is bytes[0 .. nbytes]</span>
</span>
<span class="line" id="L75">        <span class="tok-comment">// and then the low nbits of bits.  Data is always written</span>
</span>
<span class="line" id="L76">        <span class="tok-comment">// sequentially into the bytes array.</span>
</span>
<span class="line" id="L77">        bits: <span class="tok-type">u64</span>,</span>
<span class="line" id="L78">        nbits: <span class="tok-type">u32</span>, <span class="tok-comment">// number of bits</span>
</span>
<span class="line" id="L79">        bytes: [buffer_size]<span class="tok-type">u8</span>,</span>
<span class="line" id="L80">        codegen_freq: [codegen_code_count]<span class="tok-type">u16</span>,</span>
<span class="line" id="L81">        nbytes: <span class="tok-type">u32</span>, <span class="tok-comment">// number of bytes</span>
</span>
<span class="line" id="L82">        literal_freq: []<span class="tok-type">u16</span>,</span>
<span class="line" id="L83">        offset_freq: []<span class="tok-type">u16</span>,</span>
<span class="line" id="L84">        codegen: []<span class="tok-type">u8</span>,</span>
<span class="line" id="L85">        literal_encoding: hm_code.HuffmanEncoder,</span>
<span class="line" id="L86">        offset_encoding: hm_code.HuffmanEncoder,</span>
<span class="line" id="L87">        codegen_encoding: hm_code.HuffmanEncoder,</span>
<span class="line" id="L88">        err: <span class="tok-type">bool</span> = <span class="tok-null">false</span>,</span>
<span class="line" id="L89">        fixed_literal_encoding: hm_code.HuffmanEncoder,</span>
<span class="line" id="L90">        fixed_offset_encoding: hm_code.HuffmanEncoder,</span>
<span class="line" id="L91">        allocator: Allocator,</span>
<span class="line" id="L92">        huff_offset: hm_code.HuffmanEncoder,</span>
<span class="line" id="L93"></span>
<span class="line" id="L94">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">reset</span>(self: *Self, new_writer: WriterType) <span class="tok-type">void</span> {</span>
<span class="line" id="L95">            self.inner_writer = new_writer;</span>
<span class="line" id="L96">            self.bytes_written = <span class="tok-number">0</span>;</span>
<span class="line" id="L97">            self.bits = <span class="tok-number">0</span>;</span>
<span class="line" id="L98">            self.nbits = <span class="tok-number">0</span>;</span>
<span class="line" id="L99">            self.nbytes = <span class="tok-number">0</span>;</span>
<span class="line" id="L100">            self.err = <span class="tok-null">false</span>;</span>
<span class="line" id="L101">        }</span>
<span class="line" id="L102"></span>
<span class="line" id="L103">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">flush</span>(self: *Self) Error!<span class="tok-type">void</span> {</span>
<span class="line" id="L104">            <span class="tok-kw">if</span> (self.err) {</span>
<span class="line" id="L105">                self.nbits = <span class="tok-number">0</span>;</span>
<span class="line" id="L106">                <span class="tok-kw">return</span>;</span>
<span class="line" id="L107">            }</span>
<span class="line" id="L108">            <span class="tok-kw">var</span> n = self.nbytes;</span>
<span class="line" id="L109">            <span class="tok-kw">while</span> (self.nbits != <span class="tok-number">0</span>) {</span>
<span class="line" id="L110">                self.bytes[n] = <span class="tok-builtin">@truncate</span>(<span class="tok-type">u8</span>, self.bits);</span>
<span class="line" id="L111">                self.bits &gt;&gt;= <span class="tok-number">8</span>;</span>
<span class="line" id="L112">                <span class="tok-kw">if</span> (self.nbits &gt; <span class="tok-number">8</span>) { <span class="tok-comment">// Avoid underflow</span>
</span>
<span class="line" id="L113">                    self.nbits -= <span class="tok-number">8</span>;</span>
<span class="line" id="L114">                } <span class="tok-kw">else</span> {</span>
<span class="line" id="L115">                    self.nbits = <span class="tok-number">0</span>;</span>
<span class="line" id="L116">                }</span>
<span class="line" id="L117">                n += <span class="tok-number">1</span>;</span>
<span class="line" id="L118">            }</span>
<span class="line" id="L119">            self.bits = <span class="tok-number">0</span>;</span>
<span class="line" id="L120">            <span class="tok-kw">try</span> self.write(self.bytes[<span class="tok-number">0</span>..n]);</span>
<span class="line" id="L121">            self.nbytes = <span class="tok-number">0</span>;</span>
<span class="line" id="L122">        }</span>
<span class="line" id="L123"></span>
<span class="line" id="L124">        <span class="tok-kw">fn</span> <span class="tok-fn">write</span>(self: *Self, b: []<span class="tok-type">u8</span>) Error!<span class="tok-type">void</span> {</span>
<span class="line" id="L125">            <span class="tok-kw">if</span> (self.err) {</span>
<span class="line" id="L126">                <span class="tok-kw">return</span>;</span>
<span class="line" id="L127">            }</span>
<span class="line" id="L128">            self.bytes_written += <span class="tok-kw">try</span> self.inner_writer.write(b);</span>
<span class="line" id="L129">        }</span>
<span class="line" id="L130"></span>
<span class="line" id="L131">        <span class="tok-kw">fn</span> <span class="tok-fn">writeBits</span>(self: *Self, b: <span class="tok-type">u32</span>, nb: <span class="tok-type">u32</span>) Error!<span class="tok-type">void</span> {</span>
<span class="line" id="L132">            <span class="tok-kw">if</span> (self.err) {</span>
<span class="line" id="L133">                <span class="tok-kw">return</span>;</span>
<span class="line" id="L134">            }</span>
<span class="line" id="L135">            self.bits |= <span class="tok-builtin">@intCast</span>(<span class="tok-type">u64</span>, b) &lt;&lt; <span class="tok-builtin">@intCast</span>(<span class="tok-type">u6</span>, self.nbits);</span>
<span class="line" id="L136">            self.nbits += nb;</span>
<span class="line" id="L137">            <span class="tok-kw">if</span> (self.nbits &gt;= <span class="tok-number">48</span>) {</span>
<span class="line" id="L138">                <span class="tok-kw">var</span> bits = self.bits;</span>
<span class="line" id="L139">                self.bits &gt;&gt;= <span class="tok-number">48</span>;</span>
<span class="line" id="L140">                self.nbits -= <span class="tok-number">48</span>;</span>
<span class="line" id="L141">                <span class="tok-kw">var</span> n = self.nbytes;</span>
<span class="line" id="L142">                <span class="tok-kw">var</span> bytes = self.bytes[n .. n + <span class="tok-number">6</span>];</span>
<span class="line" id="L143">                bytes[<span class="tok-number">0</span>] = <span class="tok-builtin">@truncate</span>(<span class="tok-type">u8</span>, bits);</span>
<span class="line" id="L144">                bytes[<span class="tok-number">1</span>] = <span class="tok-builtin">@truncate</span>(<span class="tok-type">u8</span>, bits &gt;&gt; <span class="tok-number">8</span>);</span>
<span class="line" id="L145">                bytes[<span class="tok-number">2</span>] = <span class="tok-builtin">@truncate</span>(<span class="tok-type">u8</span>, bits &gt;&gt; <span class="tok-number">16</span>);</span>
<span class="line" id="L146">                bytes[<span class="tok-number">3</span>] = <span class="tok-builtin">@truncate</span>(<span class="tok-type">u8</span>, bits &gt;&gt; <span class="tok-number">24</span>);</span>
<span class="line" id="L147">                bytes[<span class="tok-number">4</span>] = <span class="tok-builtin">@truncate</span>(<span class="tok-type">u8</span>, bits &gt;&gt; <span class="tok-number">32</span>);</span>
<span class="line" id="L148">                bytes[<span class="tok-number">5</span>] = <span class="tok-builtin">@truncate</span>(<span class="tok-type">u8</span>, bits &gt;&gt; <span class="tok-number">40</span>);</span>
<span class="line" id="L149">                n += <span class="tok-number">6</span>;</span>
<span class="line" id="L150">                <span class="tok-kw">if</span> (n &gt;= buffer_flush_size) {</span>
<span class="line" id="L151">                    <span class="tok-kw">try</span> self.write(self.bytes[<span class="tok-number">0</span>..n]);</span>
<span class="line" id="L152">                    n = <span class="tok-number">0</span>;</span>
<span class="line" id="L153">                }</span>
<span class="line" id="L154">                self.nbytes = n;</span>
<span class="line" id="L155">            }</span>
<span class="line" id="L156">        }</span>
<span class="line" id="L157"></span>
<span class="line" id="L158">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">writeBytes</span>(self: *Self, bytes: []<span class="tok-type">u8</span>) Error!<span class="tok-type">void</span> {</span>
<span class="line" id="L159">            <span class="tok-kw">if</span> (self.err) {</span>
<span class="line" id="L160">                <span class="tok-kw">return</span>;</span>
<span class="line" id="L161">            }</span>
<span class="line" id="L162">            <span class="tok-kw">var</span> n = self.nbytes;</span>
<span class="line" id="L163">            <span class="tok-kw">if</span> (self.nbits &amp; <span class="tok-number">7</span> != <span class="tok-number">0</span>) {</span>
<span class="line" id="L164">                self.err = <span class="tok-null">true</span>; <span class="tok-comment">// unfinished bits</span>
</span>
<span class="line" id="L165">                <span class="tok-kw">return</span>;</span>
<span class="line" id="L166">            }</span>
<span class="line" id="L167">            <span class="tok-kw">while</span> (self.nbits != <span class="tok-number">0</span>) {</span>
<span class="line" id="L168">                self.bytes[n] = <span class="tok-builtin">@truncate</span>(<span class="tok-type">u8</span>, self.bits);</span>
<span class="line" id="L169">                self.bits &gt;&gt;= <span class="tok-number">8</span>;</span>
<span class="line" id="L170">                self.nbits -= <span class="tok-number">8</span>;</span>
<span class="line" id="L171">                n += <span class="tok-number">1</span>;</span>
<span class="line" id="L172">            }</span>
<span class="line" id="L173">            <span class="tok-kw">if</span> (n != <span class="tok-number">0</span>) {</span>
<span class="line" id="L174">                <span class="tok-kw">try</span> self.write(self.bytes[<span class="tok-number">0</span>..n]);</span>
<span class="line" id="L175">            }</span>
<span class="line" id="L176">            self.nbytes = <span class="tok-number">0</span>;</span>
<span class="line" id="L177">            <span class="tok-kw">try</span> self.write(bytes);</span>
<span class="line" id="L178">        }</span>
<span class="line" id="L179"></span>
<span class="line" id="L180">        <span class="tok-comment">// RFC 1951 3.2.7 specifies a special run-length encoding for specifying</span>
</span>
<span class="line" id="L181">        <span class="tok-comment">// the literal and offset lengths arrays (which are concatenated into a single</span>
</span>
<span class="line" id="L182">        <span class="tok-comment">// array).  This method generates that run-length encoding.</span>
</span>
<span class="line" id="L183">        <span class="tok-comment">//</span>
</span>
<span class="line" id="L184">        <span class="tok-comment">// The result is written into the codegen array, and the frequencies</span>
</span>
<span class="line" id="L185">        <span class="tok-comment">// of each code is written into the codegen_freq array.</span>
</span>
<span class="line" id="L186">        <span class="tok-comment">// Codes 0-15 are single byte codes. Codes 16-18 are followed by additional</span>
</span>
<span class="line" id="L187">        <span class="tok-comment">// information. Code bad_code is an end marker</span>
</span>
<span class="line" id="L188">        <span class="tok-comment">//</span>
</span>
<span class="line" id="L189">        <span class="tok-comment">// num_literals: The number of literals in literal_encoding</span>
</span>
<span class="line" id="L190">        <span class="tok-comment">// num_offsets: The number of offsets in offset_encoding</span>
</span>
<span class="line" id="L191">        <span class="tok-comment">// lit_enc: The literal encoder to use</span>
</span>
<span class="line" id="L192">        <span class="tok-comment">// off_enc: The offset encoder to use</span>
</span>
<span class="line" id="L193">        <span class="tok-kw">fn</span> <span class="tok-fn">generateCodegen</span>(</span>
<span class="line" id="L194">            self: *Self,</span>
<span class="line" id="L195">            num_literals: <span class="tok-type">u32</span>,</span>
<span class="line" id="L196">            num_offsets: <span class="tok-type">u32</span>,</span>
<span class="line" id="L197">            lit_enc: *hm_code.HuffmanEncoder,</span>
<span class="line" id="L198">            off_enc: *hm_code.HuffmanEncoder,</span>
<span class="line" id="L199">        ) <span class="tok-type">void</span> {</span>
<span class="line" id="L200">            <span class="tok-kw">for</span> (self.codegen_freq) |_, i| {</span>
<span class="line" id="L201">                self.codegen_freq[i] = <span class="tok-number">0</span>;</span>
<span class="line" id="L202">            }</span>
<span class="line" id="L203"></span>
<span class="line" id="L204">            <span class="tok-comment">// Note that we are using codegen both as a temporary variable for holding</span>
</span>
<span class="line" id="L205">            <span class="tok-comment">// a copy of the frequencies, and as the place where we put the result.</span>
</span>
<span class="line" id="L206">            <span class="tok-comment">// This is fine because the output is always shorter than the input used</span>
</span>
<span class="line" id="L207">            <span class="tok-comment">// so far.</span>
</span>
<span class="line" id="L208">            <span class="tok-kw">var</span> codegen = self.codegen; <span class="tok-comment">// cache</span>
</span>
<span class="line" id="L209">            <span class="tok-comment">// Copy the concatenated code sizes to codegen. Put a marker at the end.</span>
</span>
<span class="line" id="L210">            <span class="tok-kw">var</span> cgnl = codegen[<span class="tok-number">0</span>..num_literals];</span>
<span class="line" id="L211">            <span class="tok-kw">for</span> (cgnl) |_, i| {</span>
<span class="line" id="L212">                cgnl[i] = <span class="tok-builtin">@intCast</span>(<span class="tok-type">u8</span>, lit_enc.codes[i].len);</span>
<span class="line" id="L213">            }</span>
<span class="line" id="L214"></span>
<span class="line" id="L215">            cgnl = codegen[num_literals .. num_literals + num_offsets];</span>
<span class="line" id="L216">            <span class="tok-kw">for</span> (cgnl) |_, i| {</span>
<span class="line" id="L217">                cgnl[i] = <span class="tok-builtin">@intCast</span>(<span class="tok-type">u8</span>, off_enc.codes[i].len);</span>
<span class="line" id="L218">            }</span>
<span class="line" id="L219">            codegen[num_literals + num_offsets] = bad_code;</span>
<span class="line" id="L220"></span>
<span class="line" id="L221">            <span class="tok-kw">var</span> size = codegen[<span class="tok-number">0</span>];</span>
<span class="line" id="L222">            <span class="tok-kw">var</span> count: <span class="tok-type">i32</span> = <span class="tok-number">1</span>;</span>
<span class="line" id="L223">            <span class="tok-kw">var</span> out_index: <span class="tok-type">u32</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L224">            <span class="tok-kw">var</span> in_index: <span class="tok-type">u32</span> = <span class="tok-number">1</span>;</span>
<span class="line" id="L225">            <span class="tok-kw">while</span> (size != bad_code) : (in_index += <span class="tok-number">1</span>) {</span>
<span class="line" id="L226">                <span class="tok-comment">// INVARIANT: We have seen &quot;count&quot; copies of size that have not yet</span>
</span>
<span class="line" id="L227">                <span class="tok-comment">// had output generated for them.</span>
</span>
<span class="line" id="L228">                <span class="tok-kw">var</span> next_size = codegen[in_index];</span>
<span class="line" id="L229">                <span class="tok-kw">if</span> (next_size == size) {</span>
<span class="line" id="L230">                    count += <span class="tok-number">1</span>;</span>
<span class="line" id="L231">                    <span class="tok-kw">continue</span>;</span>
<span class="line" id="L232">                }</span>
<span class="line" id="L233">                <span class="tok-comment">// We need to generate codegen indicating &quot;count&quot; of size.</span>
</span>
<span class="line" id="L234">                <span class="tok-kw">if</span> (size != <span class="tok-number">0</span>) {</span>
<span class="line" id="L235">                    codegen[out_index] = size;</span>
<span class="line" id="L236">                    out_index += <span class="tok-number">1</span>;</span>
<span class="line" id="L237">                    self.codegen_freq[size] += <span class="tok-number">1</span>;</span>
<span class="line" id="L238">                    count -= <span class="tok-number">1</span>;</span>
<span class="line" id="L239">                    <span class="tok-kw">while</span> (count &gt;= <span class="tok-number">3</span>) {</span>
<span class="line" id="L240">                        <span class="tok-kw">var</span> n: <span class="tok-type">i32</span> = <span class="tok-number">6</span>;</span>
<span class="line" id="L241">                        <span class="tok-kw">if</span> (n &gt; count) {</span>
<span class="line" id="L242">                            n = count;</span>
<span class="line" id="L243">                        }</span>
<span class="line" id="L244">                        codegen[out_index] = <span class="tok-number">16</span>;</span>
<span class="line" id="L245">                        out_index += <span class="tok-number">1</span>;</span>
<span class="line" id="L246">                        codegen[out_index] = <span class="tok-builtin">@intCast</span>(<span class="tok-type">u8</span>, n - <span class="tok-number">3</span>);</span>
<span class="line" id="L247">                        out_index += <span class="tok-number">1</span>;</span>
<span class="line" id="L248">                        self.codegen_freq[<span class="tok-number">16</span>] += <span class="tok-number">1</span>;</span>
<span class="line" id="L249">                        count -= n;</span>
<span class="line" id="L250">                    }</span>
<span class="line" id="L251">                } <span class="tok-kw">else</span> {</span>
<span class="line" id="L252">                    <span class="tok-kw">while</span> (count &gt;= <span class="tok-number">11</span>) {</span>
<span class="line" id="L253">                        <span class="tok-kw">var</span> n: <span class="tok-type">i32</span> = <span class="tok-number">138</span>;</span>
<span class="line" id="L254">                        <span class="tok-kw">if</span> (n &gt; count) {</span>
<span class="line" id="L255">                            n = count;</span>
<span class="line" id="L256">                        }</span>
<span class="line" id="L257">                        codegen[out_index] = <span class="tok-number">18</span>;</span>
<span class="line" id="L258">                        out_index += <span class="tok-number">1</span>;</span>
<span class="line" id="L259">                        codegen[out_index] = <span class="tok-builtin">@intCast</span>(<span class="tok-type">u8</span>, n - <span class="tok-number">11</span>);</span>
<span class="line" id="L260">                        out_index += <span class="tok-number">1</span>;</span>
<span class="line" id="L261">                        self.codegen_freq[<span class="tok-number">18</span>] += <span class="tok-number">1</span>;</span>
<span class="line" id="L262">                        count -= n;</span>
<span class="line" id="L263">                    }</span>
<span class="line" id="L264">                    <span class="tok-kw">if</span> (count &gt;= <span class="tok-number">3</span>) {</span>
<span class="line" id="L265">                        <span class="tok-comment">// 3 &lt;= count &lt;= 10</span>
</span>
<span class="line" id="L266">                        codegen[out_index] = <span class="tok-number">17</span>;</span>
<span class="line" id="L267">                        out_index += <span class="tok-number">1</span>;</span>
<span class="line" id="L268">                        codegen[out_index] = <span class="tok-builtin">@intCast</span>(<span class="tok-type">u8</span>, count - <span class="tok-number">3</span>);</span>
<span class="line" id="L269">                        out_index += <span class="tok-number">1</span>;</span>
<span class="line" id="L270">                        self.codegen_freq[<span class="tok-number">17</span>] += <span class="tok-number">1</span>;</span>
<span class="line" id="L271">                        count = <span class="tok-number">0</span>;</span>
<span class="line" id="L272">                    }</span>
<span class="line" id="L273">                }</span>
<span class="line" id="L274">                count -= <span class="tok-number">1</span>;</span>
<span class="line" id="L275">                <span class="tok-kw">while</span> (count &gt;= <span class="tok-number">0</span>) : (count -= <span class="tok-number">1</span>) {</span>
<span class="line" id="L276">                    codegen[out_index] = size;</span>
<span class="line" id="L277">                    out_index += <span class="tok-number">1</span>;</span>
<span class="line" id="L278">                    self.codegen_freq[size] += <span class="tok-number">1</span>;</span>
<span class="line" id="L279">                }</span>
<span class="line" id="L280">                <span class="tok-comment">// Set up invariant for next time through the loop.</span>
</span>
<span class="line" id="L281">                size = next_size;</span>
<span class="line" id="L282">                count = <span class="tok-number">1</span>;</span>
<span class="line" id="L283">            }</span>
<span class="line" id="L284">            <span class="tok-comment">// Marker indicating the end of the codegen.</span>
</span>
<span class="line" id="L285">            codegen[out_index] = bad_code;</span>
<span class="line" id="L286">        }</span>
<span class="line" id="L287"></span>
<span class="line" id="L288">        <span class="tok-comment">// dynamicSize returns the size of dynamically encoded data in bits.</span>
</span>
<span class="line" id="L289">        <span class="tok-kw">fn</span> <span class="tok-fn">dynamicSize</span>(</span>
<span class="line" id="L290">            self: *Self,</span>
<span class="line" id="L291">            lit_enc: *hm_code.HuffmanEncoder, <span class="tok-comment">// literal encoder</span>
</span>
<span class="line" id="L292">            off_enc: *hm_code.HuffmanEncoder, <span class="tok-comment">// offset encoder</span>
</span>
<span class="line" id="L293">            extra_bits: <span class="tok-type">u32</span>,</span>
<span class="line" id="L294">        ) DynamicSize {</span>
<span class="line" id="L295">            <span class="tok-kw">var</span> num_codegens = self.codegen_freq.len;</span>
<span class="line" id="L296">            <span class="tok-kw">while</span> (num_codegens &gt; <span class="tok-number">4</span> <span class="tok-kw">and</span> self.codegen_freq[codegen_order[num_codegens - <span class="tok-number">1</span>]] == <span class="tok-number">0</span>) {</span>
<span class="line" id="L297">                num_codegens -= <span class="tok-number">1</span>;</span>
<span class="line" id="L298">            }</span>
<span class="line" id="L299">            <span class="tok-kw">var</span> header = <span class="tok-number">3</span> + <span class="tok-number">5</span> + <span class="tok-number">5</span> + <span class="tok-number">4</span> + (<span class="tok-number">3</span> * num_codegens) +</span>
<span class="line" id="L300">                self.codegen_encoding.bitLength(self.codegen_freq[<span class="tok-number">0</span>..]) +</span>
<span class="line" id="L301">                self.codegen_freq[<span class="tok-number">16</span>] * <span class="tok-number">2</span> +</span>
<span class="line" id="L302">                self.codegen_freq[<span class="tok-number">17</span>] * <span class="tok-number">3</span> +</span>
<span class="line" id="L303">                self.codegen_freq[<span class="tok-number">18</span>] * <span class="tok-number">7</span>;</span>
<span class="line" id="L304">            <span class="tok-kw">var</span> size = header +</span>
<span class="line" id="L305">                lit_enc.bitLength(self.literal_freq) +</span>
<span class="line" id="L306">                off_enc.bitLength(self.offset_freq) +</span>
<span class="line" id="L307">                extra_bits;</span>
<span class="line" id="L308"></span>
<span class="line" id="L309">            <span class="tok-kw">return</span> DynamicSize{</span>
<span class="line" id="L310">                .size = <span class="tok-builtin">@intCast</span>(<span class="tok-type">u32</span>, size),</span>
<span class="line" id="L311">                .num_codegens = <span class="tok-builtin">@intCast</span>(<span class="tok-type">u32</span>, num_codegens),</span>
<span class="line" id="L312">            };</span>
<span class="line" id="L313">        }</span>
<span class="line" id="L314"></span>
<span class="line" id="L315">        <span class="tok-comment">// fixedSize returns the size of dynamically encoded data in bits.</span>
</span>
<span class="line" id="L316">        <span class="tok-kw">fn</span> <span class="tok-fn">fixedSize</span>(self: *Self, extra_bits: <span class="tok-type">u32</span>) <span class="tok-type">u32</span> {</span>
<span class="line" id="L317">            <span class="tok-kw">return</span> <span class="tok-number">3</span> +</span>
<span class="line" id="L318">                self.fixed_literal_encoding.bitLength(self.literal_freq) +</span>
<span class="line" id="L319">                self.fixed_offset_encoding.bitLength(self.offset_freq) +</span>
<span class="line" id="L320">                extra_bits;</span>
<span class="line" id="L321">        }</span>
<span class="line" id="L322"></span>
<span class="line" id="L323">        <span class="tok-comment">// storedSizeFits calculates the stored size, including header.</span>
</span>
<span class="line" id="L324">        <span class="tok-comment">// The function returns the size in bits and whether the block</span>
</span>
<span class="line" id="L325">        <span class="tok-comment">// fits inside a single block.</span>
</span>
<span class="line" id="L326">        <span class="tok-kw">fn</span> <span class="tok-fn">storedSizeFits</span>(in: ?[]<span class="tok-type">u8</span>) StoredSize {</span>
<span class="line" id="L327">            <span class="tok-kw">if</span> (in == <span class="tok-null">null</span>) {</span>
<span class="line" id="L328">                <span class="tok-kw">return</span> .{ .size = <span class="tok-number">0</span>, .storable = <span class="tok-null">false</span> };</span>
<span class="line" id="L329">            }</span>
<span class="line" id="L330">            <span class="tok-kw">if</span> (in.?.len &lt;= deflate_const.max_store_block_size) {</span>
<span class="line" id="L331">                <span class="tok-kw">return</span> .{ .size = <span class="tok-builtin">@intCast</span>(<span class="tok-type">u32</span>, (in.?.len + <span class="tok-number">5</span>) * <span class="tok-number">8</span>), .storable = <span class="tok-null">true</span> };</span>
<span class="line" id="L332">            }</span>
<span class="line" id="L333">            <span class="tok-kw">return</span> .{ .size = <span class="tok-number">0</span>, .storable = <span class="tok-null">false</span> };</span>
<span class="line" id="L334">        }</span>
<span class="line" id="L335"></span>
<span class="line" id="L336">        <span class="tok-kw">fn</span> <span class="tok-fn">writeCode</span>(self: *Self, c: hm_code.HuffCode) Error!<span class="tok-type">void</span> {</span>
<span class="line" id="L337">            <span class="tok-kw">if</span> (self.err) {</span>
<span class="line" id="L338">                <span class="tok-kw">return</span>;</span>
<span class="line" id="L339">            }</span>
<span class="line" id="L340">            self.bits |= <span class="tok-builtin">@intCast</span>(<span class="tok-type">u64</span>, c.code) &lt;&lt; <span class="tok-builtin">@intCast</span>(<span class="tok-type">u6</span>, self.nbits);</span>
<span class="line" id="L341">            self.nbits += <span class="tok-builtin">@intCast</span>(<span class="tok-type">u32</span>, c.len);</span>
<span class="line" id="L342">            <span class="tok-kw">if</span> (self.nbits &gt;= <span class="tok-number">48</span>) {</span>
<span class="line" id="L343">                <span class="tok-kw">var</span> bits = self.bits;</span>
<span class="line" id="L344">                self.bits &gt;&gt;= <span class="tok-number">48</span>;</span>
<span class="line" id="L345">                self.nbits -= <span class="tok-number">48</span>;</span>
<span class="line" id="L346">                <span class="tok-kw">var</span> n = self.nbytes;</span>
<span class="line" id="L347">                <span class="tok-kw">var</span> bytes = self.bytes[n .. n + <span class="tok-number">6</span>];</span>
<span class="line" id="L348">                bytes[<span class="tok-number">0</span>] = <span class="tok-builtin">@truncate</span>(<span class="tok-type">u8</span>, bits);</span>
<span class="line" id="L349">                bytes[<span class="tok-number">1</span>] = <span class="tok-builtin">@truncate</span>(<span class="tok-type">u8</span>, bits &gt;&gt; <span class="tok-number">8</span>);</span>
<span class="line" id="L350">                bytes[<span class="tok-number">2</span>] = <span class="tok-builtin">@truncate</span>(<span class="tok-type">u8</span>, bits &gt;&gt; <span class="tok-number">16</span>);</span>
<span class="line" id="L351">                bytes[<span class="tok-number">3</span>] = <span class="tok-builtin">@truncate</span>(<span class="tok-type">u8</span>, bits &gt;&gt; <span class="tok-number">24</span>);</span>
<span class="line" id="L352">                bytes[<span class="tok-number">4</span>] = <span class="tok-builtin">@truncate</span>(<span class="tok-type">u8</span>, bits &gt;&gt; <span class="tok-number">32</span>);</span>
<span class="line" id="L353">                bytes[<span class="tok-number">5</span>] = <span class="tok-builtin">@truncate</span>(<span class="tok-type">u8</span>, bits &gt;&gt; <span class="tok-number">40</span>);</span>
<span class="line" id="L354">                n += <span class="tok-number">6</span>;</span>
<span class="line" id="L355">                <span class="tok-kw">if</span> (n &gt;= buffer_flush_size) {</span>
<span class="line" id="L356">                    <span class="tok-kw">try</span> self.write(self.bytes[<span class="tok-number">0</span>..n]);</span>
<span class="line" id="L357">                    n = <span class="tok-number">0</span>;</span>
<span class="line" id="L358">                }</span>
<span class="line" id="L359">                self.nbytes = n;</span>
<span class="line" id="L360">            }</span>
<span class="line" id="L361">        }</span>
<span class="line" id="L362"></span>
<span class="line" id="L363">        <span class="tok-comment">// Write the header of a dynamic Huffman block to the output stream.</span>
</span>
<span class="line" id="L364">        <span class="tok-comment">//</span>
</span>
<span class="line" id="L365">        <span class="tok-comment">//  num_literals: The number of literals specified in codegen</span>
</span>
<span class="line" id="L366">        <span class="tok-comment">//  num_offsets: The number of offsets specified in codegen</span>
</span>
<span class="line" id="L367">        <span class="tok-comment">//  num_codegens: The number of codegens used in codegen</span>
</span>
<span class="line" id="L368">        <span class="tok-comment">//  is_eof: Is it the end-of-file? (end of stream)</span>
</span>
<span class="line" id="L369">        <span class="tok-kw">fn</span> <span class="tok-fn">writeDynamicHeader</span>(</span>
<span class="line" id="L370">            self: *Self,</span>
<span class="line" id="L371">            num_literals: <span class="tok-type">u32</span>,</span>
<span class="line" id="L372">            num_offsets: <span class="tok-type">u32</span>,</span>
<span class="line" id="L373">            num_codegens: <span class="tok-type">u32</span>,</span>
<span class="line" id="L374">            is_eof: <span class="tok-type">bool</span>,</span>
<span class="line" id="L375">        ) Error!<span class="tok-type">void</span> {</span>
<span class="line" id="L376">            <span class="tok-kw">if</span> (self.err) {</span>
<span class="line" id="L377">                <span class="tok-kw">return</span>;</span>
<span class="line" id="L378">            }</span>
<span class="line" id="L379">            <span class="tok-kw">var</span> first_bits: <span class="tok-type">u32</span> = <span class="tok-number">4</span>;</span>
<span class="line" id="L380">            <span class="tok-kw">if</span> (is_eof) {</span>
<span class="line" id="L381">                first_bits = <span class="tok-number">5</span>;</span>
<span class="line" id="L382">            }</span>
<span class="line" id="L383">            <span class="tok-kw">try</span> self.writeBits(first_bits, <span class="tok-number">3</span>);</span>
<span class="line" id="L384">            <span class="tok-kw">try</span> self.writeBits(<span class="tok-builtin">@intCast</span>(<span class="tok-type">u32</span>, num_literals - <span class="tok-number">257</span>), <span class="tok-number">5</span>);</span>
<span class="line" id="L385">            <span class="tok-kw">try</span> self.writeBits(<span class="tok-builtin">@intCast</span>(<span class="tok-type">u32</span>, num_offsets - <span class="tok-number">1</span>), <span class="tok-number">5</span>);</span>
<span class="line" id="L386">            <span class="tok-kw">try</span> self.writeBits(<span class="tok-builtin">@intCast</span>(<span class="tok-type">u32</span>, num_codegens - <span class="tok-number">4</span>), <span class="tok-number">4</span>);</span>
<span class="line" id="L387"></span>
<span class="line" id="L388">            <span class="tok-kw">var</span> i: <span class="tok-type">u32</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L389">            <span class="tok-kw">while</span> (i &lt; num_codegens) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L390">                <span class="tok-kw">var</span> value = <span class="tok-builtin">@intCast</span>(<span class="tok-type">u32</span>, self.codegen_encoding.codes[codegen_order[i]].len);</span>
<span class="line" id="L391">                <span class="tok-kw">try</span> self.writeBits(<span class="tok-builtin">@intCast</span>(<span class="tok-type">u32</span>, value), <span class="tok-number">3</span>);</span>
<span class="line" id="L392">            }</span>
<span class="line" id="L393"></span>
<span class="line" id="L394">            i = <span class="tok-number">0</span>;</span>
<span class="line" id="L395">            <span class="tok-kw">while</span> (<span class="tok-null">true</span>) {</span>
<span class="line" id="L396">                <span class="tok-kw">var</span> code_word: <span class="tok-type">u32</span> = <span class="tok-builtin">@intCast</span>(<span class="tok-type">u32</span>, self.codegen[i]);</span>
<span class="line" id="L397">                i += <span class="tok-number">1</span>;</span>
<span class="line" id="L398">                <span class="tok-kw">if</span> (code_word == bad_code) {</span>
<span class="line" id="L399">                    <span class="tok-kw">break</span>;</span>
<span class="line" id="L400">                }</span>
<span class="line" id="L401">                <span class="tok-kw">try</span> self.writeCode(self.codegen_encoding.codes[<span class="tok-builtin">@intCast</span>(<span class="tok-type">u32</span>, code_word)]);</span>
<span class="line" id="L402"></span>
<span class="line" id="L403">                <span class="tok-kw">switch</span> (code_word) {</span>
<span class="line" id="L404">                    <span class="tok-number">16</span> =&gt; {</span>
<span class="line" id="L405">                        <span class="tok-kw">try</span> self.writeBits(<span class="tok-builtin">@intCast</span>(<span class="tok-type">u32</span>, self.codegen[i]), <span class="tok-number">2</span>);</span>
<span class="line" id="L406">                        i += <span class="tok-number">1</span>;</span>
<span class="line" id="L407">                    },</span>
<span class="line" id="L408">                    <span class="tok-number">17</span> =&gt; {</span>
<span class="line" id="L409">                        <span class="tok-kw">try</span> self.writeBits(<span class="tok-builtin">@intCast</span>(<span class="tok-type">u32</span>, self.codegen[i]), <span class="tok-number">3</span>);</span>
<span class="line" id="L410">                        i += <span class="tok-number">1</span>;</span>
<span class="line" id="L411">                    },</span>
<span class="line" id="L412">                    <span class="tok-number">18</span> =&gt; {</span>
<span class="line" id="L413">                        <span class="tok-kw">try</span> self.writeBits(<span class="tok-builtin">@intCast</span>(<span class="tok-type">u32</span>, self.codegen[i]), <span class="tok-number">7</span>);</span>
<span class="line" id="L414">                        i += <span class="tok-number">1</span>;</span>
<span class="line" id="L415">                    },</span>
<span class="line" id="L416">                    <span class="tok-kw">else</span> =&gt; {},</span>
<span class="line" id="L417">                }</span>
<span class="line" id="L418">            }</span>
<span class="line" id="L419">        }</span>
<span class="line" id="L420"></span>
<span class="line" id="L421">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">writeStoredHeader</span>(self: *Self, length: <span class="tok-type">usize</span>, is_eof: <span class="tok-type">bool</span>) Error!<span class="tok-type">void</span> {</span>
<span class="line" id="L422">            <span class="tok-kw">if</span> (self.err) {</span>
<span class="line" id="L423">                <span class="tok-kw">return</span>;</span>
<span class="line" id="L424">            }</span>
<span class="line" id="L425">            <span class="tok-kw">var</span> flag: <span class="tok-type">u32</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L426">            <span class="tok-kw">if</span> (is_eof) {</span>
<span class="line" id="L427">                flag = <span class="tok-number">1</span>;</span>
<span class="line" id="L428">            }</span>
<span class="line" id="L429">            <span class="tok-kw">try</span> self.writeBits(flag, <span class="tok-number">3</span>);</span>
<span class="line" id="L430">            <span class="tok-kw">try</span> self.flush();</span>
<span class="line" id="L431">            <span class="tok-kw">try</span> self.writeBits(<span class="tok-builtin">@intCast</span>(<span class="tok-type">u32</span>, length), <span class="tok-number">16</span>);</span>
<span class="line" id="L432">            <span class="tok-kw">try</span> self.writeBits(<span class="tok-builtin">@intCast</span>(<span class="tok-type">u32</span>, ~<span class="tok-builtin">@intCast</span>(<span class="tok-type">u16</span>, length)), <span class="tok-number">16</span>);</span>
<span class="line" id="L433">        }</span>
<span class="line" id="L434"></span>
<span class="line" id="L435">        <span class="tok-kw">fn</span> <span class="tok-fn">writeFixedHeader</span>(self: *Self, is_eof: <span class="tok-type">bool</span>) Error!<span class="tok-type">void</span> {</span>
<span class="line" id="L436">            <span class="tok-kw">if</span> (self.err) {</span>
<span class="line" id="L437">                <span class="tok-kw">return</span>;</span>
<span class="line" id="L438">            }</span>
<span class="line" id="L439">            <span class="tok-comment">// Indicate that we are a fixed Huffman block</span>
</span>
<span class="line" id="L440">            <span class="tok-kw">var</span> value: <span class="tok-type">u32</span> = <span class="tok-number">2</span>;</span>
<span class="line" id="L441">            <span class="tok-kw">if</span> (is_eof) {</span>
<span class="line" id="L442">                value = <span class="tok-number">3</span>;</span>
<span class="line" id="L443">            }</span>
<span class="line" id="L444">            <span class="tok-kw">try</span> self.writeBits(value, <span class="tok-number">3</span>);</span>
<span class="line" id="L445">        }</span>
<span class="line" id="L446"></span>
<span class="line" id="L447">        <span class="tok-comment">// Write a block of tokens with the smallest encoding.</span>
</span>
<span class="line" id="L448">        <span class="tok-comment">// The original input can be supplied, and if the huffman encoded data</span>
</span>
<span class="line" id="L449">        <span class="tok-comment">// is larger than the original bytes, the data will be written as a</span>
</span>
<span class="line" id="L450">        <span class="tok-comment">// stored block.</span>
</span>
<span class="line" id="L451">        <span class="tok-comment">// If the input is null, the tokens will always be Huffman encoded.</span>
</span>
<span class="line" id="L452">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">writeBlock</span>(</span>
<span class="line" id="L453">            self: *Self,</span>
<span class="line" id="L454">            tokens: []<span class="tok-kw">const</span> token.Token,</span>
<span class="line" id="L455">            eof: <span class="tok-type">bool</span>,</span>
<span class="line" id="L456">            input: ?[]<span class="tok-type">u8</span>,</span>
<span class="line" id="L457">        ) Error!<span class="tok-type">void</span> {</span>
<span class="line" id="L458">            <span class="tok-kw">if</span> (self.err) {</span>
<span class="line" id="L459">                <span class="tok-kw">return</span>;</span>
<span class="line" id="L460">            }</span>
<span class="line" id="L461"></span>
<span class="line" id="L462">            <span class="tok-kw">var</span> lit_and_off = self.indexTokens(tokens);</span>
<span class="line" id="L463">            <span class="tok-kw">var</span> num_literals = lit_and_off.num_literals;</span>
<span class="line" id="L464">            <span class="tok-kw">var</span> num_offsets = lit_and_off.num_offsets;</span>
<span class="line" id="L465"></span>
<span class="line" id="L466">            <span class="tok-kw">var</span> extra_bits: <span class="tok-type">u32</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L467">            <span class="tok-kw">var</span> ret = storedSizeFits(input);</span>
<span class="line" id="L468">            <span class="tok-kw">var</span> stored_size = ret.size;</span>
<span class="line" id="L469">            <span class="tok-kw">var</span> storable = ret.storable;</span>
<span class="line" id="L470"></span>
<span class="line" id="L471">            <span class="tok-kw">if</span> (storable) {</span>
<span class="line" id="L472">                <span class="tok-comment">// We only bother calculating the costs of the extra bits required by</span>
</span>
<span class="line" id="L473">                <span class="tok-comment">// the length of offset fields (which will be the same for both fixed</span>
</span>
<span class="line" id="L474">                <span class="tok-comment">// and dynamic encoding), if we need to compare those two encodings</span>
</span>
<span class="line" id="L475">                <span class="tok-comment">// against stored encoding.</span>
</span>
<span class="line" id="L476">                <span class="tok-kw">var</span> length_code: <span class="tok-type">u32</span> = length_codes_start + <span class="tok-number">8</span>;</span>
<span class="line" id="L477">                <span class="tok-kw">while</span> (length_code &lt; num_literals) : (length_code += <span class="tok-number">1</span>) {</span>
<span class="line" id="L478">                    <span class="tok-comment">// First eight length codes have extra size = 0.</span>
</span>
<span class="line" id="L479">                    extra_bits += <span class="tok-builtin">@intCast</span>(<span class="tok-type">u32</span>, self.literal_freq[length_code]) *</span>
<span class="line" id="L480">                        <span class="tok-builtin">@intCast</span>(<span class="tok-type">u32</span>, length_extra_bits[length_code - length_codes_start]);</span>
<span class="line" id="L481">                }</span>
<span class="line" id="L482">                <span class="tok-kw">var</span> offset_code: <span class="tok-type">u32</span> = <span class="tok-number">4</span>;</span>
<span class="line" id="L483">                <span class="tok-kw">while</span> (offset_code &lt; num_offsets) : (offset_code += <span class="tok-number">1</span>) {</span>
<span class="line" id="L484">                    <span class="tok-comment">// First four offset codes have extra size = 0.</span>
</span>
<span class="line" id="L485">                    extra_bits += <span class="tok-builtin">@intCast</span>(<span class="tok-type">u32</span>, self.offset_freq[offset_code]) *</span>
<span class="line" id="L486">                        <span class="tok-builtin">@intCast</span>(<span class="tok-type">u32</span>, offset_extra_bits[offset_code]);</span>
<span class="line" id="L487">                }</span>
<span class="line" id="L488">            }</span>
<span class="line" id="L489"></span>
<span class="line" id="L490">            <span class="tok-comment">// Figure out smallest code.</span>
</span>
<span class="line" id="L491">            <span class="tok-comment">// Fixed Huffman baseline.</span>
</span>
<span class="line" id="L492">            <span class="tok-kw">var</span> literal_encoding = &amp;self.fixed_literal_encoding;</span>
<span class="line" id="L493">            <span class="tok-kw">var</span> offset_encoding = &amp;self.fixed_offset_encoding;</span>
<span class="line" id="L494">            <span class="tok-kw">var</span> size = self.fixedSize(extra_bits);</span>
<span class="line" id="L495"></span>
<span class="line" id="L496">            <span class="tok-comment">// Dynamic Huffman?</span>
</span>
<span class="line" id="L497">            <span class="tok-kw">var</span> num_codegens: <span class="tok-type">u32</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L498"></span>
<span class="line" id="L499">            <span class="tok-comment">// Generate codegen and codegenFrequencies, which indicates how to encode</span>
</span>
<span class="line" id="L500">            <span class="tok-comment">// the literal_encoding and the offset_encoding.</span>
</span>
<span class="line" id="L501">            self.generateCodegen(</span>
<span class="line" id="L502">                num_literals,</span>
<span class="line" id="L503">                num_offsets,</span>
<span class="line" id="L504">                &amp;self.literal_encoding,</span>
<span class="line" id="L505">                &amp;self.offset_encoding,</span>
<span class="line" id="L506">            );</span>
<span class="line" id="L507">            self.codegen_encoding.generate(self.codegen_freq[<span class="tok-number">0</span>..], <span class="tok-number">7</span>);</span>
<span class="line" id="L508">            <span class="tok-kw">var</span> dynamic_size = self.dynamicSize(</span>
<span class="line" id="L509">                &amp;self.literal_encoding,</span>
<span class="line" id="L510">                &amp;self.offset_encoding,</span>
<span class="line" id="L511">                extra_bits,</span>
<span class="line" id="L512">            );</span>
<span class="line" id="L513">            <span class="tok-kw">var</span> dyn_size = dynamic_size.size;</span>
<span class="line" id="L514">            num_codegens = dynamic_size.num_codegens;</span>
<span class="line" id="L515"></span>
<span class="line" id="L516">            <span class="tok-kw">if</span> (dyn_size &lt; size) {</span>
<span class="line" id="L517">                size = dyn_size;</span>
<span class="line" id="L518">                literal_encoding = &amp;self.literal_encoding;</span>
<span class="line" id="L519">                offset_encoding = &amp;self.offset_encoding;</span>
<span class="line" id="L520">            }</span>
<span class="line" id="L521"></span>
<span class="line" id="L522">            <span class="tok-comment">// Stored bytes?</span>
</span>
<span class="line" id="L523">            <span class="tok-kw">if</span> (storable <span class="tok-kw">and</span> stored_size &lt; size) {</span>
<span class="line" id="L524">                <span class="tok-kw">try</span> self.writeStoredHeader(input.?.len, eof);</span>
<span class="line" id="L525">                <span class="tok-kw">try</span> self.writeBytes(input.?);</span>
<span class="line" id="L526">                <span class="tok-kw">return</span>;</span>
<span class="line" id="L527">            }</span>
<span class="line" id="L528"></span>
<span class="line" id="L529">            <span class="tok-comment">// Huffman.</span>
</span>
<span class="line" id="L530">            <span class="tok-kw">if</span> (<span class="tok-builtin">@ptrToInt</span>(literal_encoding) == <span class="tok-builtin">@ptrToInt</span>(&amp;self.fixed_literal_encoding)) {</span>
<span class="line" id="L531">                <span class="tok-kw">try</span> self.writeFixedHeader(eof);</span>
<span class="line" id="L532">            } <span class="tok-kw">else</span> {</span>
<span class="line" id="L533">                <span class="tok-kw">try</span> self.writeDynamicHeader(num_literals, num_offsets, num_codegens, eof);</span>
<span class="line" id="L534">            }</span>
<span class="line" id="L535"></span>
<span class="line" id="L536">            <span class="tok-comment">// Write the tokens.</span>
</span>
<span class="line" id="L537">            <span class="tok-kw">try</span> self.writeTokens(tokens, literal_encoding.codes, offset_encoding.codes);</span>
<span class="line" id="L538">        }</span>
<span class="line" id="L539"></span>
<span class="line" id="L540">        <span class="tok-comment">// writeBlockDynamic encodes a block using a dynamic Huffman table.</span>
</span>
<span class="line" id="L541">        <span class="tok-comment">// This should be used if the symbols used have a disproportionate</span>
</span>
<span class="line" id="L542">        <span class="tok-comment">// histogram distribution.</span>
</span>
<span class="line" id="L543">        <span class="tok-comment">// If input is supplied and the compression savings are below 1/16th of the</span>
</span>
<span class="line" id="L544">        <span class="tok-comment">// input size the block is stored.</span>
</span>
<span class="line" id="L545">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">writeBlockDynamic</span>(</span>
<span class="line" id="L546">            self: *Self,</span>
<span class="line" id="L547">            tokens: []<span class="tok-kw">const</span> token.Token,</span>
<span class="line" id="L548">            eof: <span class="tok-type">bool</span>,</span>
<span class="line" id="L549">            input: ?[]<span class="tok-type">u8</span>,</span>
<span class="line" id="L550">        ) Error!<span class="tok-type">void</span> {</span>
<span class="line" id="L551">            <span class="tok-kw">if</span> (self.err) {</span>
<span class="line" id="L552">                <span class="tok-kw">return</span>;</span>
<span class="line" id="L553">            }</span>
<span class="line" id="L554"></span>
<span class="line" id="L555">            <span class="tok-kw">var</span> total_tokens = self.indexTokens(tokens);</span>
<span class="line" id="L556">            <span class="tok-kw">var</span> num_literals = total_tokens.num_literals;</span>
<span class="line" id="L557">            <span class="tok-kw">var</span> num_offsets = total_tokens.num_offsets;</span>
<span class="line" id="L558"></span>
<span class="line" id="L559">            <span class="tok-comment">// Generate codegen and codegenFrequencies, which indicates how to encode</span>
</span>
<span class="line" id="L560">            <span class="tok-comment">// the literal_encoding and the offset_encoding.</span>
</span>
<span class="line" id="L561">            self.generateCodegen(</span>
<span class="line" id="L562">                num_literals,</span>
<span class="line" id="L563">                num_offsets,</span>
<span class="line" id="L564">                &amp;self.literal_encoding,</span>
<span class="line" id="L565">                &amp;self.offset_encoding,</span>
<span class="line" id="L566">            );</span>
<span class="line" id="L567">            self.codegen_encoding.generate(self.codegen_freq[<span class="tok-number">0</span>..], <span class="tok-number">7</span>);</span>
<span class="line" id="L568">            <span class="tok-kw">var</span> dynamic_size = self.dynamicSize(&amp;self.literal_encoding, &amp;self.offset_encoding, <span class="tok-number">0</span>);</span>
<span class="line" id="L569">            <span class="tok-kw">var</span> size = dynamic_size.size;</span>
<span class="line" id="L570">            <span class="tok-kw">var</span> num_codegens = dynamic_size.num_codegens;</span>
<span class="line" id="L571"></span>
<span class="line" id="L572">            <span class="tok-comment">// Store bytes, if we don't get a reasonable improvement.</span>
</span>
<span class="line" id="L573"></span>
<span class="line" id="L574">            <span class="tok-kw">var</span> stored_size = storedSizeFits(input);</span>
<span class="line" id="L575">            <span class="tok-kw">var</span> ssize = stored_size.size;</span>
<span class="line" id="L576">            <span class="tok-kw">var</span> storable = stored_size.storable;</span>
<span class="line" id="L577">            <span class="tok-kw">if</span> (storable <span class="tok-kw">and</span> ssize &lt; (size + (size &gt;&gt; <span class="tok-number">4</span>))) {</span>
<span class="line" id="L578">                <span class="tok-kw">try</span> self.writeStoredHeader(input.?.len, eof);</span>
<span class="line" id="L579">                <span class="tok-kw">try</span> self.writeBytes(input.?);</span>
<span class="line" id="L580">                <span class="tok-kw">return</span>;</span>
<span class="line" id="L581">            }</span>
<span class="line" id="L582"></span>
<span class="line" id="L583">            <span class="tok-comment">// Write Huffman table.</span>
</span>
<span class="line" id="L584">            <span class="tok-kw">try</span> self.writeDynamicHeader(num_literals, num_offsets, num_codegens, eof);</span>
<span class="line" id="L585"></span>
<span class="line" id="L586">            <span class="tok-comment">// Write the tokens.</span>
</span>
<span class="line" id="L587">            <span class="tok-kw">try</span> self.writeTokens(tokens, self.literal_encoding.codes, self.offset_encoding.codes);</span>
<span class="line" id="L588">        }</span>
<span class="line" id="L589"></span>
<span class="line" id="L590">        <span class="tok-kw">const</span> TotalIndexedTokens = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L591">            num_literals: <span class="tok-type">u32</span>,</span>
<span class="line" id="L592">            num_offsets: <span class="tok-type">u32</span>,</span>
<span class="line" id="L593">        };</span>
<span class="line" id="L594"></span>
<span class="line" id="L595">        <span class="tok-comment">// Indexes a slice of tokens followed by an end_block_marker, and updates</span>
</span>
<span class="line" id="L596">        <span class="tok-comment">// literal_freq and offset_freq, and generates literal_encoding</span>
</span>
<span class="line" id="L597">        <span class="tok-comment">// and offset_encoding.</span>
</span>
<span class="line" id="L598">        <span class="tok-comment">// The number of literal and offset tokens is returned.</span>
</span>
<span class="line" id="L599">        <span class="tok-kw">fn</span> <span class="tok-fn">indexTokens</span>(self: *Self, tokens: []<span class="tok-kw">const</span> token.Token) TotalIndexedTokens {</span>
<span class="line" id="L600">            <span class="tok-kw">var</span> num_literals: <span class="tok-type">u32</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L601">            <span class="tok-kw">var</span> num_offsets: <span class="tok-type">u32</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L602"></span>
<span class="line" id="L603">            <span class="tok-kw">for</span> (self.literal_freq) |_, i| {</span>
<span class="line" id="L604">                self.literal_freq[i] = <span class="tok-number">0</span>;</span>
<span class="line" id="L605">            }</span>
<span class="line" id="L606">            <span class="tok-kw">for</span> (self.offset_freq) |_, i| {</span>
<span class="line" id="L607">                self.offset_freq[i] = <span class="tok-number">0</span>;</span>
<span class="line" id="L608">            }</span>
<span class="line" id="L609"></span>
<span class="line" id="L610">            <span class="tok-kw">for</span> (tokens) |t| {</span>
<span class="line" id="L611">                <span class="tok-kw">if</span> (t &lt; token.match_type) {</span>
<span class="line" id="L612">                    self.literal_freq[token.literal(t)] += <span class="tok-number">1</span>;</span>
<span class="line" id="L613">                    <span class="tok-kw">continue</span>;</span>
<span class="line" id="L614">                }</span>
<span class="line" id="L615">                <span class="tok-kw">var</span> length = token.length(t);</span>
<span class="line" id="L616">                <span class="tok-kw">var</span> offset = token.offset(t);</span>
<span class="line" id="L617">                self.literal_freq[length_codes_start + token.lengthCode(length)] += <span class="tok-number">1</span>;</span>
<span class="line" id="L618">                self.offset_freq[token.offsetCode(offset)] += <span class="tok-number">1</span>;</span>
<span class="line" id="L619">            }</span>
<span class="line" id="L620">            <span class="tok-comment">// add end_block_marker token at the end</span>
</span>
<span class="line" id="L621">            self.literal_freq[token.literal(deflate_const.end_block_marker)] += <span class="tok-number">1</span>;</span>
<span class="line" id="L622"></span>
<span class="line" id="L623">            <span class="tok-comment">// get the number of literals</span>
</span>
<span class="line" id="L624">            num_literals = <span class="tok-builtin">@intCast</span>(<span class="tok-type">u32</span>, self.literal_freq.len);</span>
<span class="line" id="L625">            <span class="tok-kw">while</span> (self.literal_freq[num_literals - <span class="tok-number">1</span>] == <span class="tok-number">0</span>) {</span>
<span class="line" id="L626">                num_literals -= <span class="tok-number">1</span>;</span>
<span class="line" id="L627">            }</span>
<span class="line" id="L628">            <span class="tok-comment">// get the number of offsets</span>
</span>
<span class="line" id="L629">            num_offsets = <span class="tok-builtin">@intCast</span>(<span class="tok-type">u32</span>, self.offset_freq.len);</span>
<span class="line" id="L630">            <span class="tok-kw">while</span> (num_offsets &gt; <span class="tok-number">0</span> <span class="tok-kw">and</span> self.offset_freq[num_offsets - <span class="tok-number">1</span>] == <span class="tok-number">0</span>) {</span>
<span class="line" id="L631">                num_offsets -= <span class="tok-number">1</span>;</span>
<span class="line" id="L632">            }</span>
<span class="line" id="L633">            <span class="tok-kw">if</span> (num_offsets == <span class="tok-number">0</span>) {</span>
<span class="line" id="L634">                <span class="tok-comment">// We haven't found a single match. If we want to go with the dynamic encoding,</span>
</span>
<span class="line" id="L635">                <span class="tok-comment">// we should count at least one offset to be sure that the offset huffman tree could be encoded.</span>
</span>
<span class="line" id="L636">                self.offset_freq[<span class="tok-number">0</span>] = <span class="tok-number">1</span>;</span>
<span class="line" id="L637">                num_offsets = <span class="tok-number">1</span>;</span>
<span class="line" id="L638">            }</span>
<span class="line" id="L639">            self.literal_encoding.generate(self.literal_freq, <span class="tok-number">15</span>);</span>
<span class="line" id="L640">            self.offset_encoding.generate(self.offset_freq, <span class="tok-number">15</span>);</span>
<span class="line" id="L641">            <span class="tok-kw">return</span> TotalIndexedTokens{</span>
<span class="line" id="L642">                .num_literals = num_literals,</span>
<span class="line" id="L643">                .num_offsets = num_offsets,</span>
<span class="line" id="L644">            };</span>
<span class="line" id="L645">        }</span>
<span class="line" id="L646"></span>
<span class="line" id="L647">        <span class="tok-comment">// Writes a slice of tokens to the output followed by and end_block_marker.</span>
</span>
<span class="line" id="L648">        <span class="tok-comment">// codes for literal and offset encoding must be supplied.</span>
</span>
<span class="line" id="L649">        <span class="tok-kw">fn</span> <span class="tok-fn">writeTokens</span>(</span>
<span class="line" id="L650">            self: *Self,</span>
<span class="line" id="L651">            tokens: []<span class="tok-kw">const</span> token.Token,</span>
<span class="line" id="L652">            le_codes: []hm_code.HuffCode,</span>
<span class="line" id="L653">            oe_codes: []hm_code.HuffCode,</span>
<span class="line" id="L654">        ) Error!<span class="tok-type">void</span> {</span>
<span class="line" id="L655">            <span class="tok-kw">if</span> (self.err) {</span>
<span class="line" id="L656">                <span class="tok-kw">return</span>;</span>
<span class="line" id="L657">            }</span>
<span class="line" id="L658">            <span class="tok-kw">for</span> (tokens) |t| {</span>
<span class="line" id="L659">                <span class="tok-kw">if</span> (t &lt; token.match_type) {</span>
<span class="line" id="L660">                    <span class="tok-kw">try</span> self.writeCode(le_codes[token.literal(t)]);</span>
<span class="line" id="L661">                    <span class="tok-kw">continue</span>;</span>
<span class="line" id="L662">                }</span>
<span class="line" id="L663">                <span class="tok-comment">// Write the length</span>
</span>
<span class="line" id="L664">                <span class="tok-kw">var</span> length = token.length(t);</span>
<span class="line" id="L665">                <span class="tok-kw">var</span> length_code = token.lengthCode(length);</span>
<span class="line" id="L666">                <span class="tok-kw">try</span> self.writeCode(le_codes[length_code + length_codes_start]);</span>
<span class="line" id="L667">                <span class="tok-kw">var</span> extra_length_bits = <span class="tok-builtin">@intCast</span>(<span class="tok-type">u32</span>, length_extra_bits[length_code]);</span>
<span class="line" id="L668">                <span class="tok-kw">if</span> (extra_length_bits &gt; <span class="tok-number">0</span>) {</span>
<span class="line" id="L669">                    <span class="tok-kw">var</span> extra_length = <span class="tok-builtin">@intCast</span>(<span class="tok-type">u32</span>, length - length_base[length_code]);</span>
<span class="line" id="L670">                    <span class="tok-kw">try</span> self.writeBits(extra_length, extra_length_bits);</span>
<span class="line" id="L671">                }</span>
<span class="line" id="L672">                <span class="tok-comment">// Write the offset</span>
</span>
<span class="line" id="L673">                <span class="tok-kw">var</span> offset = token.offset(t);</span>
<span class="line" id="L674">                <span class="tok-kw">var</span> offset_code = token.offsetCode(offset);</span>
<span class="line" id="L675">                <span class="tok-kw">try</span> self.writeCode(oe_codes[offset_code]);</span>
<span class="line" id="L676">                <span class="tok-kw">var</span> extra_offset_bits = <span class="tok-builtin">@intCast</span>(<span class="tok-type">u32</span>, offset_extra_bits[offset_code]);</span>
<span class="line" id="L677">                <span class="tok-kw">if</span> (extra_offset_bits &gt; <span class="tok-number">0</span>) {</span>
<span class="line" id="L678">                    <span class="tok-kw">var</span> extra_offset = <span class="tok-builtin">@intCast</span>(<span class="tok-type">u32</span>, offset - offset_base[offset_code]);</span>
<span class="line" id="L679">                    <span class="tok-kw">try</span> self.writeBits(extra_offset, extra_offset_bits);</span>
<span class="line" id="L680">                }</span>
<span class="line" id="L681">            }</span>
<span class="line" id="L682">            <span class="tok-comment">// add end_block_marker at the end</span>
</span>
<span class="line" id="L683">            <span class="tok-kw">try</span> self.writeCode(le_codes[token.literal(deflate_const.end_block_marker)]);</span>
<span class="line" id="L684">        }</span>
<span class="line" id="L685"></span>
<span class="line" id="L686">        <span class="tok-comment">// Encodes a block of bytes as either Huffman encoded literals or uncompressed bytes</span>
</span>
<span class="line" id="L687">        <span class="tok-comment">// if the results only gains very little from compression.</span>
</span>
<span class="line" id="L688">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">writeBlockHuff</span>(self: *Self, eof: <span class="tok-type">bool</span>, input: []<span class="tok-type">u8</span>) Error!<span class="tok-type">void</span> {</span>
<span class="line" id="L689">            <span class="tok-kw">if</span> (self.err) {</span>
<span class="line" id="L690">                <span class="tok-kw">return</span>;</span>
<span class="line" id="L691">            }</span>
<span class="line" id="L692"></span>
<span class="line" id="L693">            <span class="tok-comment">// Clear histogram</span>
</span>
<span class="line" id="L694">            <span class="tok-kw">for</span> (self.literal_freq) |_, i| {</span>
<span class="line" id="L695">                self.literal_freq[i] = <span class="tok-number">0</span>;</span>
<span class="line" id="L696">            }</span>
<span class="line" id="L697"></span>
<span class="line" id="L698">            <span class="tok-comment">// Add everything as literals</span>
</span>
<span class="line" id="L699">            histogram(input, &amp;self.literal_freq);</span>
<span class="line" id="L700"></span>
<span class="line" id="L701">            self.literal_freq[deflate_const.end_block_marker] = <span class="tok-number">1</span>;</span>
<span class="line" id="L702"></span>
<span class="line" id="L703">            <span class="tok-kw">const</span> num_literals = deflate_const.end_block_marker + <span class="tok-number">1</span>;</span>
<span class="line" id="L704">            self.offset_freq[<span class="tok-number">0</span>] = <span class="tok-number">1</span>;</span>
<span class="line" id="L705">            <span class="tok-kw">const</span> num_offsets = <span class="tok-number">1</span>;</span>
<span class="line" id="L706"></span>
<span class="line" id="L707">            self.literal_encoding.generate(self.literal_freq, <span class="tok-number">15</span>);</span>
<span class="line" id="L708"></span>
<span class="line" id="L709">            <span class="tok-comment">// Figure out smallest code.</span>
</span>
<span class="line" id="L710">            <span class="tok-comment">// Always use dynamic Huffman or Store</span>
</span>
<span class="line" id="L711">            <span class="tok-kw">var</span> num_codegens: <span class="tok-type">u32</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L712"></span>
<span class="line" id="L713">            <span class="tok-comment">// Generate codegen and codegenFrequencies, which indicates how to encode</span>
</span>
<span class="line" id="L714">            <span class="tok-comment">// the literal_encoding and the offset_encoding.</span>
</span>
<span class="line" id="L715">            self.generateCodegen(</span>
<span class="line" id="L716">                num_literals,</span>
<span class="line" id="L717">                num_offsets,</span>
<span class="line" id="L718">                &amp;self.literal_encoding,</span>
<span class="line" id="L719">                &amp;self.huff_offset,</span>
<span class="line" id="L720">            );</span>
<span class="line" id="L721">            self.codegen_encoding.generate(self.codegen_freq[<span class="tok-number">0</span>..], <span class="tok-number">7</span>);</span>
<span class="line" id="L722">            <span class="tok-kw">var</span> dynamic_size = self.dynamicSize(&amp;self.literal_encoding, &amp;self.huff_offset, <span class="tok-number">0</span>);</span>
<span class="line" id="L723">            <span class="tok-kw">var</span> size = dynamic_size.size;</span>
<span class="line" id="L724">            num_codegens = dynamic_size.num_codegens;</span>
<span class="line" id="L725"></span>
<span class="line" id="L726">            <span class="tok-comment">// Store bytes, if we don't get a reasonable improvement.</span>
</span>
<span class="line" id="L727"></span>
<span class="line" id="L728">            <span class="tok-kw">var</span> stored_size_ret = storedSizeFits(input);</span>
<span class="line" id="L729">            <span class="tok-kw">var</span> ssize = stored_size_ret.size;</span>
<span class="line" id="L730">            <span class="tok-kw">var</span> storable = stored_size_ret.storable;</span>
<span class="line" id="L731"></span>
<span class="line" id="L732">            <span class="tok-kw">if</span> (storable <span class="tok-kw">and</span> ssize &lt; (size + (size &gt;&gt; <span class="tok-number">4</span>))) {</span>
<span class="line" id="L733">                <span class="tok-kw">try</span> self.writeStoredHeader(input.len, eof);</span>
<span class="line" id="L734">                <span class="tok-kw">try</span> self.writeBytes(input);</span>
<span class="line" id="L735">                <span class="tok-kw">return</span>;</span>
<span class="line" id="L736">            }</span>
<span class="line" id="L737"></span>
<span class="line" id="L738">            <span class="tok-comment">// Huffman.</span>
</span>
<span class="line" id="L739">            <span class="tok-kw">try</span> self.writeDynamicHeader(num_literals, num_offsets, num_codegens, eof);</span>
<span class="line" id="L740">            <span class="tok-kw">var</span> encoding = self.literal_encoding.codes[<span class="tok-number">0</span>..<span class="tok-number">257</span>];</span>
<span class="line" id="L741">            <span class="tok-kw">var</span> n = self.nbytes;</span>
<span class="line" id="L742">            <span class="tok-kw">for</span> (input) |t| {</span>
<span class="line" id="L743">                <span class="tok-comment">// Bitwriting inlined, ~30% speedup</span>
</span>
<span class="line" id="L744">                <span class="tok-kw">var</span> c = encoding[t];</span>
<span class="line" id="L745">                self.bits |= <span class="tok-builtin">@intCast</span>(<span class="tok-type">u64</span>, c.code) &lt;&lt; <span class="tok-builtin">@intCast</span>(<span class="tok-type">u6</span>, self.nbits);</span>
<span class="line" id="L746">                self.nbits += <span class="tok-builtin">@intCast</span>(<span class="tok-type">u32</span>, c.len);</span>
<span class="line" id="L747">                <span class="tok-kw">if</span> (self.nbits &lt; <span class="tok-number">48</span>) {</span>
<span class="line" id="L748">                    <span class="tok-kw">continue</span>;</span>
<span class="line" id="L749">                }</span>
<span class="line" id="L750">                <span class="tok-comment">// Store 6 bytes</span>
</span>
<span class="line" id="L751">                <span class="tok-kw">var</span> bits = self.bits;</span>
<span class="line" id="L752">                self.bits &gt;&gt;= <span class="tok-number">48</span>;</span>
<span class="line" id="L753">                self.nbits -= <span class="tok-number">48</span>;</span>
<span class="line" id="L754">                <span class="tok-kw">var</span> bytes = self.bytes[n .. n + <span class="tok-number">6</span>];</span>
<span class="line" id="L755">                bytes[<span class="tok-number">0</span>] = <span class="tok-builtin">@truncate</span>(<span class="tok-type">u8</span>, bits);</span>
<span class="line" id="L756">                bytes[<span class="tok-number">1</span>] = <span class="tok-builtin">@truncate</span>(<span class="tok-type">u8</span>, bits &gt;&gt; <span class="tok-number">8</span>);</span>
<span class="line" id="L757">                bytes[<span class="tok-number">2</span>] = <span class="tok-builtin">@truncate</span>(<span class="tok-type">u8</span>, bits &gt;&gt; <span class="tok-number">16</span>);</span>
<span class="line" id="L758">                bytes[<span class="tok-number">3</span>] = <span class="tok-builtin">@truncate</span>(<span class="tok-type">u8</span>, bits &gt;&gt; <span class="tok-number">24</span>);</span>
<span class="line" id="L759">                bytes[<span class="tok-number">4</span>] = <span class="tok-builtin">@truncate</span>(<span class="tok-type">u8</span>, bits &gt;&gt; <span class="tok-number">32</span>);</span>
<span class="line" id="L760">                bytes[<span class="tok-number">5</span>] = <span class="tok-builtin">@truncate</span>(<span class="tok-type">u8</span>, bits &gt;&gt; <span class="tok-number">40</span>);</span>
<span class="line" id="L761">                n += <span class="tok-number">6</span>;</span>
<span class="line" id="L762">                <span class="tok-kw">if</span> (n &lt; buffer_flush_size) {</span>
<span class="line" id="L763">                    <span class="tok-kw">continue</span>;</span>
<span class="line" id="L764">                }</span>
<span class="line" id="L765">                <span class="tok-kw">try</span> self.write(self.bytes[<span class="tok-number">0</span>..n]);</span>
<span class="line" id="L766">                <span class="tok-kw">if</span> (self.err) {</span>
<span class="line" id="L767">                    <span class="tok-kw">return</span>; <span class="tok-comment">// Return early in the event of write failures</span>
</span>
<span class="line" id="L768">                }</span>
<span class="line" id="L769">                n = <span class="tok-number">0</span>;</span>
<span class="line" id="L770">            }</span>
<span class="line" id="L771">            self.nbytes = n;</span>
<span class="line" id="L772">            <span class="tok-kw">try</span> self.writeCode(encoding[deflate_const.end_block_marker]);</span>
<span class="line" id="L773">        }</span>
<span class="line" id="L774"></span>
<span class="line" id="L775">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">deinit</span>(self: *Self) <span class="tok-type">void</span> {</span>
<span class="line" id="L776">            self.allocator.free(self.literal_freq);</span>
<span class="line" id="L777">            self.allocator.free(self.offset_freq);</span>
<span class="line" id="L778">            self.allocator.free(self.codegen);</span>
<span class="line" id="L779">            self.literal_encoding.deinit();</span>
<span class="line" id="L780">            self.codegen_encoding.deinit();</span>
<span class="line" id="L781">            self.offset_encoding.deinit();</span>
<span class="line" id="L782">            self.fixed_literal_encoding.deinit();</span>
<span class="line" id="L783">            self.fixed_offset_encoding.deinit();</span>
<span class="line" id="L784">            self.huff_offset.deinit();</span>
<span class="line" id="L785">        }</span>
<span class="line" id="L786">    };</span>
<span class="line" id="L787">}</span>
<span class="line" id="L788"></span>
<span class="line" id="L789"><span class="tok-kw">const</span> DynamicSize = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L790">    size: <span class="tok-type">u32</span>,</span>
<span class="line" id="L791">    num_codegens: <span class="tok-type">u32</span>,</span>
<span class="line" id="L792">};</span>
<span class="line" id="L793"></span>
<span class="line" id="L794"><span class="tok-kw">const</span> StoredSize = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L795">    size: <span class="tok-type">u32</span>,</span>
<span class="line" id="L796">    storable: <span class="tok-type">bool</span>,</span>
<span class="line" id="L797">};</span>
<span class="line" id="L798"></span>
<span class="line" id="L799"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">huffmanBitWriter</span>(allocator: Allocator, writer: <span class="tok-kw">anytype</span>) !HuffmanBitWriter(<span class="tok-builtin">@TypeOf</span>(writer)) {</span>
<span class="line" id="L800">    <span class="tok-kw">var</span> offset_freq = [<span class="tok-number">1</span>]<span class="tok-type">u16</span>{<span class="tok-number">0</span>} ** deflate_const.offset_code_count;</span>
<span class="line" id="L801">    offset_freq[<span class="tok-number">0</span>] = <span class="tok-number">1</span>;</span>
<span class="line" id="L802">    <span class="tok-comment">// huff_offset is a static offset encoder used for huffman only encoding.</span>
</span>
<span class="line" id="L803">    <span class="tok-comment">// It can be reused since we will not be encoding offset values.</span>
</span>
<span class="line" id="L804">    <span class="tok-kw">var</span> huff_offset = <span class="tok-kw">try</span> hm_code.newHuffmanEncoder(allocator, deflate_const.offset_code_count);</span>
<span class="line" id="L805">    huff_offset.generate(offset_freq[<span class="tok-number">0</span>..], <span class="tok-number">15</span>);</span>
<span class="line" id="L806"></span>
<span class="line" id="L807">    <span class="tok-kw">return</span> HuffmanBitWriter(<span class="tok-builtin">@TypeOf</span>(writer)){</span>
<span class="line" id="L808">        .inner_writer = writer,</span>
<span class="line" id="L809">        .bytes_written = <span class="tok-number">0</span>,</span>
<span class="line" id="L810">        .bits = <span class="tok-number">0</span>,</span>
<span class="line" id="L811">        .nbits = <span class="tok-number">0</span>,</span>
<span class="line" id="L812">        .nbytes = <span class="tok-number">0</span>,</span>
<span class="line" id="L813">        .bytes = [<span class="tok-number">1</span>]<span class="tok-type">u8</span>{<span class="tok-number">0</span>} ** buffer_size,</span>
<span class="line" id="L814">        .codegen_freq = [<span class="tok-number">1</span>]<span class="tok-type">u16</span>{<span class="tok-number">0</span>} ** codegen_code_count,</span>
<span class="line" id="L815">        .literal_freq = <span class="tok-kw">try</span> allocator.alloc(<span class="tok-type">u16</span>, deflate_const.max_num_lit),</span>
<span class="line" id="L816">        .offset_freq = <span class="tok-kw">try</span> allocator.alloc(<span class="tok-type">u16</span>, deflate_const.offset_code_count),</span>
<span class="line" id="L817">        .codegen = <span class="tok-kw">try</span> allocator.alloc(<span class="tok-type">u8</span>, deflate_const.max_num_lit + deflate_const.offset_code_count + <span class="tok-number">1</span>),</span>
<span class="line" id="L818">        .literal_encoding = <span class="tok-kw">try</span> hm_code.newHuffmanEncoder(allocator, deflate_const.max_num_lit),</span>
<span class="line" id="L819">        .codegen_encoding = <span class="tok-kw">try</span> hm_code.newHuffmanEncoder(allocator, codegen_code_count),</span>
<span class="line" id="L820">        .offset_encoding = <span class="tok-kw">try</span> hm_code.newHuffmanEncoder(allocator, deflate_const.offset_code_count),</span>
<span class="line" id="L821">        .allocator = allocator,</span>
<span class="line" id="L822">        .fixed_literal_encoding = <span class="tok-kw">try</span> hm_code.generateFixedLiteralEncoding(allocator),</span>
<span class="line" id="L823">        .fixed_offset_encoding = <span class="tok-kw">try</span> hm_code.generateFixedOffsetEncoding(allocator),</span>
<span class="line" id="L824">        .huff_offset = huff_offset,</span>
<span class="line" id="L825">    };</span>
<span class="line" id="L826">}</span>
<span class="line" id="L827"></span>
<span class="line" id="L828"><span class="tok-comment">// histogram accumulates a histogram of b in h.</span>
</span>
<span class="line" id="L829"><span class="tok-comment">//</span>
</span>
<span class="line" id="L830"><span class="tok-comment">// h.len must be &gt;= 256, and h's elements must be all zeroes.</span>
</span>
<span class="line" id="L831"><span class="tok-kw">fn</span> <span class="tok-fn">histogram</span>(b: []<span class="tok-type">u8</span>, h: *[]<span class="tok-type">u16</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L832">    <span class="tok-kw">var</span> lh = h.*[<span class="tok-number">0</span>..<span class="tok-number">256</span>];</span>
<span class="line" id="L833">    <span class="tok-kw">for</span> (b) |t| {</span>
<span class="line" id="L834">        lh[t] += <span class="tok-number">1</span>;</span>
<span class="line" id="L835">    }</span>
<span class="line" id="L836">}</span>
<span class="line" id="L837"></span>
<span class="line" id="L838"><span class="tok-comment">// tests</span>
</span>
<span class="line" id="L839"><span class="tok-kw">const</span> expect = std.testing.expect;</span>
<span class="line" id="L840"><span class="tok-kw">const</span> fmt = std.fmt;</span>
<span class="line" id="L841"><span class="tok-kw">const</span> math = std.math;</span>
<span class="line" id="L842"><span class="tok-kw">const</span> mem = std.mem;</span>
<span class="line" id="L843"><span class="tok-kw">const</span> testing = std.testing;</span>
<span class="line" id="L844"></span>
<span class="line" id="L845"><span class="tok-kw">const</span> ArrayList = std.ArrayList;</span>
<span class="line" id="L846"></span>
<span class="line" id="L847"><span class="tok-kw">test</span> <span class="tok-str">&quot;writeBlockHuff&quot;</span> {</span>
<span class="line" id="L848">    <span class="tok-comment">// Tests huffman encoding against reference files to detect possible regressions.</span>
</span>
<span class="line" id="L849">    <span class="tok-comment">// If encoding/bit allocation changes you can regenerate these files</span>
</span>
<span class="line" id="L850"></span>
<span class="line" id="L851">    <span class="tok-kw">try</span> testBlockHuff(</span>
<span class="line" id="L852">        <span class="tok-str">&quot;huffman-null-max.input&quot;</span>,</span>
<span class="line" id="L853">        <span class="tok-str">&quot;huffman-null-max.golden&quot;</span>,</span>
<span class="line" id="L854">    );</span>
<span class="line" id="L855">    <span class="tok-kw">try</span> testBlockHuff(</span>
<span class="line" id="L856">        <span class="tok-str">&quot;huffman-pi.input&quot;</span>,</span>
<span class="line" id="L857">        <span class="tok-str">&quot;huffman-pi.golden&quot;</span>,</span>
<span class="line" id="L858">    );</span>
<span class="line" id="L859">    <span class="tok-kw">try</span> testBlockHuff(</span>
<span class="line" id="L860">        <span class="tok-str">&quot;huffman-rand-1k.input&quot;</span>,</span>
<span class="line" id="L861">        <span class="tok-str">&quot;huffman-rand-1k.golden&quot;</span>,</span>
<span class="line" id="L862">    );</span>
<span class="line" id="L863">    <span class="tok-kw">try</span> testBlockHuff(</span>
<span class="line" id="L864">        <span class="tok-str">&quot;huffman-rand-limit.input&quot;</span>,</span>
<span class="line" id="L865">        <span class="tok-str">&quot;huffman-rand-limit.golden&quot;</span>,</span>
<span class="line" id="L866">    );</span>
<span class="line" id="L867">    <span class="tok-kw">try</span> testBlockHuff(</span>
<span class="line" id="L868">        <span class="tok-str">&quot;huffman-rand-max.input&quot;</span>,</span>
<span class="line" id="L869">        <span class="tok-str">&quot;huffman-rand-max.golden&quot;</span>,</span>
<span class="line" id="L870">    );</span>
<span class="line" id="L871">    <span class="tok-kw">try</span> testBlockHuff(</span>
<span class="line" id="L872">        <span class="tok-str">&quot;huffman-shifts.input&quot;</span>,</span>
<span class="line" id="L873">        <span class="tok-str">&quot;huffman-shifts.golden&quot;</span>,</span>
<span class="line" id="L874">    );</span>
<span class="line" id="L875">    <span class="tok-kw">try</span> testBlockHuff(</span>
<span class="line" id="L876">        <span class="tok-str">&quot;huffman-text.input&quot;</span>,</span>
<span class="line" id="L877">        <span class="tok-str">&quot;huffman-text.golden&quot;</span>,</span>
<span class="line" id="L878">    );</span>
<span class="line" id="L879">    <span class="tok-kw">try</span> testBlockHuff(</span>
<span class="line" id="L880">        <span class="tok-str">&quot;huffman-text-shift.input&quot;</span>,</span>
<span class="line" id="L881">        <span class="tok-str">&quot;huffman-text-shift.golden&quot;</span>,</span>
<span class="line" id="L882">    );</span>
<span class="line" id="L883">    <span class="tok-kw">try</span> testBlockHuff(</span>
<span class="line" id="L884">        <span class="tok-str">&quot;huffman-zero.input&quot;</span>,</span>
<span class="line" id="L885">        <span class="tok-str">&quot;huffman-zero.golden&quot;</span>,</span>
<span class="line" id="L886">    );</span>
<span class="line" id="L887">}</span>
<span class="line" id="L888"></span>
<span class="line" id="L889"><span class="tok-kw">fn</span> <span class="tok-fn">testBlockHuff</span>(in_name: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, want_name: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) !<span class="tok-type">void</span> {</span>
<span class="line" id="L890">    <span class="tok-comment">// Skip wasi because it does not support std.fs.openDirAbsolute()</span>
</span>
<span class="line" id="L891">    <span class="tok-kw">if</span> (builtin.os.tag == .wasi) <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SkipZigTest;</span>
<span class="line" id="L892"></span>
<span class="line" id="L893">    <span class="tok-kw">const</span> current_dir = <span class="tok-kw">try</span> std.fs.openDirAbsolute(std.fs.path.dirname(<span class="tok-builtin">@src</span>().file).?, .{});</span>
<span class="line" id="L894">    <span class="tok-kw">const</span> testdata_dir = <span class="tok-kw">try</span> current_dir.openDir(<span class="tok-str">&quot;testdata&quot;</span>, .{});</span>
<span class="line" id="L895">    <span class="tok-kw">const</span> in_file = <span class="tok-kw">try</span> testdata_dir.openFile(in_name, .{});</span>
<span class="line" id="L896">    <span class="tok-kw">defer</span> in_file.close();</span>
<span class="line" id="L897">    <span class="tok-kw">const</span> want_file = <span class="tok-kw">try</span> testdata_dir.openFile(want_name, .{});</span>
<span class="line" id="L898">    <span class="tok-kw">defer</span> want_file.close();</span>
<span class="line" id="L899"></span>
<span class="line" id="L900">    <span class="tok-kw">var</span> in = <span class="tok-kw">try</span> in_file.reader().readAllAlloc(testing.allocator, math.maxInt(<span class="tok-type">usize</span>));</span>
<span class="line" id="L901">    <span class="tok-kw">defer</span> testing.allocator.free(in);</span>
<span class="line" id="L902">    <span class="tok-kw">var</span> want = <span class="tok-kw">try</span> want_file.reader().readAllAlloc(testing.allocator, math.maxInt(<span class="tok-type">usize</span>));</span>
<span class="line" id="L903">    <span class="tok-kw">defer</span> testing.allocator.free(want);</span>
<span class="line" id="L904"></span>
<span class="line" id="L905">    <span class="tok-kw">var</span> buf = ArrayList(<span class="tok-type">u8</span>).init(testing.allocator);</span>
<span class="line" id="L906">    <span class="tok-kw">defer</span> buf.deinit();</span>
<span class="line" id="L907">    <span class="tok-kw">var</span> bw = <span class="tok-kw">try</span> huffmanBitWriter(testing.allocator, buf.writer());</span>
<span class="line" id="L908">    <span class="tok-kw">defer</span> bw.deinit();</span>
<span class="line" id="L909">    <span class="tok-kw">try</span> bw.writeBlockHuff(<span class="tok-null">false</span>, in);</span>
<span class="line" id="L910">    <span class="tok-kw">try</span> bw.flush();</span>
<span class="line" id="L911"></span>
<span class="line" id="L912">    <span class="tok-kw">try</span> expect(mem.eql(<span class="tok-type">u8</span>, buf.items, want));</span>
<span class="line" id="L913"></span>
<span class="line" id="L914">    <span class="tok-comment">// Test if the writer produces the same output after reset.</span>
</span>
<span class="line" id="L915">    <span class="tok-kw">var</span> buf_after_reset = ArrayList(<span class="tok-type">u8</span>).init(testing.allocator);</span>
<span class="line" id="L916">    <span class="tok-kw">defer</span> buf_after_reset.deinit();</span>
<span class="line" id="L917"></span>
<span class="line" id="L918">    bw.reset(buf_after_reset.writer());</span>
<span class="line" id="L919"></span>
<span class="line" id="L920">    <span class="tok-kw">try</span> bw.writeBlockHuff(<span class="tok-null">false</span>, in);</span>
<span class="line" id="L921">    <span class="tok-kw">try</span> bw.flush();</span>
<span class="line" id="L922"></span>
<span class="line" id="L923">    <span class="tok-kw">try</span> expect(mem.eql(<span class="tok-type">u8</span>, buf_after_reset.items, buf.items));</span>
<span class="line" id="L924">    <span class="tok-kw">try</span> expect(mem.eql(<span class="tok-type">u8</span>, buf_after_reset.items, want));</span>
<span class="line" id="L925"></span>
<span class="line" id="L926">    <span class="tok-kw">try</span> testWriterEOF(.write_huffman_block, &amp;[<span class="tok-number">0</span>]token.Token{}, in);</span>
<span class="line" id="L927">}</span>
<span class="line" id="L928"></span>
<span class="line" id="L929"><span class="tok-kw">const</span> HuffTest = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L930">    tokens: []<span class="tok-kw">const</span> token.Token,</span>
<span class="line" id="L931">    input: []<span class="tok-kw">const</span> <span class="tok-type">u8</span> = <span class="tok-str">&quot;&quot;</span>, <span class="tok-comment">// File name of input data matching the tokens.</span>
</span>
<span class="line" id="L932">    want: []<span class="tok-kw">const</span> <span class="tok-type">u8</span> = <span class="tok-str">&quot;&quot;</span>, <span class="tok-comment">// File name of data with the expected output with input available.</span>
</span>
<span class="line" id="L933">    want_no_input: []<span class="tok-kw">const</span> <span class="tok-type">u8</span> = <span class="tok-str">&quot;&quot;</span>, <span class="tok-comment">// File name of the expected output when no input is available.</span>
</span>
<span class="line" id="L934">};</span>
<span class="line" id="L935"></span>
<span class="line" id="L936"><span class="tok-kw">const</span> ml = <span class="tok-number">0x7fc00000</span>; <span class="tok-comment">// Maximum length token. Used to reduce the size of writeBlockTests</span>
</span>
<span class="line" id="L937"></span>
<span class="line" id="L938"><span class="tok-kw">const</span> writeBlockTests = &amp;[_]HuffTest{</span>
<span class="line" id="L939">    HuffTest{</span>
<span class="line" id="L940">        .input = <span class="tok-str">&quot;huffman-null-max.input&quot;</span>,</span>
<span class="line" id="L941">        .want = <span class="tok-str">&quot;huffman-null-max.{s}.expect&quot;</span>,</span>
<span class="line" id="L942">        .want_no_input = <span class="tok-str">&quot;huffman-null-max.{s}.expect-noinput&quot;</span>,</span>
<span class="line" id="L943">        .tokens = &amp;[_]token.Token{</span>
<span class="line" id="L944">            <span class="tok-number">0x0</span>, ml, ml, ml, ml, ml, ml, ml, ml, ml, ml, ml, ml, ml, ml, ml,  ml,  ml, ml, ml,</span>
<span class="line" id="L945">            ml,  ml, ml, ml, ml, ml, ml, ml, ml, ml, ml, ml, ml, ml, ml, ml,  ml,  ml, ml, ml,</span>
<span class="line" id="L946">            ml,  ml, ml, ml, ml, ml, ml, ml, ml, ml, ml, ml, ml, ml, ml, ml,  ml,  ml, ml, ml,</span>
<span class="line" id="L947">            ml,  ml, ml, ml, ml, ml, ml, ml, ml, ml, ml, ml, ml, ml, ml, ml,  ml,  ml, ml, ml,</span>
<span class="line" id="L948">            ml,  ml, ml, ml, ml, ml, ml, ml, ml, ml, ml, ml, ml, ml, ml, ml,  ml,  ml, ml, ml,</span>
<span class="line" id="L949">            ml,  ml, ml, ml, ml, ml, ml, ml, ml, ml, ml, ml, ml, ml, ml, ml,  ml,  ml, ml, ml,</span>
<span class="line" id="L950">            ml,  ml, ml, ml, ml, ml, ml, ml, ml, ml, ml, ml, ml, ml, ml, ml,  ml,  ml, ml, ml,</span>
<span class="line" id="L951">            ml,  ml, ml, ml, ml, ml, ml, ml, ml, ml, ml, ml, ml, ml, ml, ml,  ml,  ml, ml, ml,</span>
<span class="line" id="L952">            ml,  ml, ml, ml, ml, ml, ml, ml, ml, ml, ml, ml, ml, ml, ml, ml,  ml,  ml, ml, ml,</span>
<span class="line" id="L953">            ml,  ml, ml, ml, ml, ml, ml, ml, ml, ml, ml, ml, ml, ml, ml, ml,  ml,  ml, ml, ml,</span>
<span class="line" id="L954">            ml,  ml, ml, ml, ml, ml, ml, ml, ml, ml, ml, ml, ml, ml, ml, ml,  ml,  ml, ml, ml,</span>
<span class="line" id="L955">            ml,  ml, ml, ml, ml, ml, ml, ml, ml, ml, ml, ml, ml, ml, ml, ml,  ml,  ml, ml, ml,</span>
<span class="line" id="L956">            ml,  ml, ml, ml, ml, ml, ml, ml, ml, ml, ml, ml, ml, ml, ml, <span class="tok-number">0x0</span>, <span class="tok-number">0x0</span>,</span>
<span class="line" id="L957">        },</span>
<span class="line" id="L958">    },</span>
<span class="line" id="L959">    HuffTest{</span>
<span class="line" id="L960">        .input = <span class="tok-str">&quot;huffman-pi.input&quot;</span>,</span>
<span class="line" id="L961">        .want = <span class="tok-str">&quot;huffman-pi.{s}.expect&quot;</span>,</span>
<span class="line" id="L962">        .want_no_input = <span class="tok-str">&quot;huffman-pi.{s}.expect-noinput&quot;</span>,</span>
<span class="line" id="L963">        .tokens = &amp;[_]token.Token{</span>
<span class="line" id="L964">            <span class="tok-number">0x33</span>,       <span class="tok-number">0x2e</span>,       <span class="tok-number">0x31</span>,       <span class="tok-number">0x34</span>,       <span class="tok-number">0x31</span>,       <span class="tok-number">0x35</span>,       <span class="tok-number">0x39</span>,</span>
<span class="line" id="L965">            <span class="tok-number">0x32</span>,       <span class="tok-number">0x36</span>,       <span class="tok-number">0x35</span>,       <span class="tok-number">0x33</span>,       <span class="tok-number">0x35</span>,       <span class="tok-number">0x38</span>,       <span class="tok-number">0x39</span>,</span>
<span class="line" id="L966">            <span class="tok-number">0x37</span>,       <span class="tok-number">0x39</span>,       <span class="tok-number">0x33</span>,       <span class="tok-number">0x32</span>,       <span class="tok-number">0x33</span>,       <span class="tok-number">0x38</span>,       <span class="tok-number">0x34</span>,</span>
<span class="line" id="L967">            <span class="tok-number">0x36</span>,       <span class="tok-number">0x32</span>,       <span class="tok-number">0x36</span>,       <span class="tok-number">0x34</span>,       <span class="tok-number">0x33</span>,       <span class="tok-number">0x33</span>,       <span class="tok-number">0x38</span>,</span>
<span class="line" id="L968">            <span class="tok-number">0x33</span>,       <span class="tok-number">0x32</span>,       <span class="tok-number">0x37</span>,       <span class="tok-number">0x39</span>,       <span class="tok-number">0x35</span>,       <span class="tok-number">0x30</span>,       <span class="tok-number">0x32</span>,</span>
<span class="line" id="L969">            <span class="tok-number">0x38</span>,       <span class="tok-number">0x38</span>,       <span class="tok-number">0x34</span>,       <span class="tok-number">0x31</span>,       <span class="tok-number">0x39</span>,       <span class="tok-number">0x37</span>,       <span class="tok-number">0x31</span>,</span>
<span class="line" id="L970">            <span class="tok-number">0x36</span>,       <span class="tok-number">0x39</span>,       <span class="tok-number">0x33</span>,       <span class="tok-number">0x39</span>,       <span class="tok-number">0x39</span>,       <span class="tok-number">0x33</span>,       <span class="tok-number">0x37</span>,</span>
<span class="line" id="L971">            <span class="tok-number">0x35</span>,       <span class="tok-number">0x31</span>,       <span class="tok-number">0x30</span>,       <span class="tok-number">0x35</span>,       <span class="tok-number">0x38</span>,       <span class="tok-number">0x32</span>,       <span class="tok-number">0x30</span>,</span>
<span class="line" id="L972">            <span class="tok-number">0x39</span>,       <span class="tok-number">0x37</span>,       <span class="tok-number">0x34</span>,       <span class="tok-number">0x39</span>,       <span class="tok-number">0x34</span>,       <span class="tok-number">0x34</span>,       <span class="tok-number">0x35</span>,</span>
<span class="line" id="L973">            <span class="tok-number">0x39</span>,       <span class="tok-number">0x32</span>,       <span class="tok-number">0x33</span>,       <span class="tok-number">0x30</span>,       <span class="tok-number">0x37</span>,       <span class="tok-number">0x38</span>,       <span class="tok-number">0x31</span>,</span>
<span class="line" id="L974">            <span class="tok-number">0x36</span>,       <span class="tok-number">0x34</span>,       <span class="tok-number">0x30</span>,       <span class="tok-number">0x36</span>,       <span class="tok-number">0x32</span>,       <span class="tok-number">0x38</span>,       <span class="tok-number">0x36</span>,</span>
<span class="line" id="L975">            <span class="tok-number">0x32</span>,       <span class="tok-number">0x30</span>,       <span class="tok-number">0x38</span>,       <span class="tok-number">0x39</span>,       <span class="tok-number">0x39</span>,       <span class="tok-number">0x38</span>,       <span class="tok-number">0x36</span>,</span>
<span class="line" id="L976">            <span class="tok-number">0x32</span>,       <span class="tok-number">0x38</span>,       <span class="tok-number">0x30</span>,       <span class="tok-number">0x33</span>,       <span class="tok-number">0x34</span>,       <span class="tok-number">0x38</span>,       <span class="tok-number">0x32</span>,</span>
<span class="line" id="L977">            <span class="tok-number">0x35</span>,       <span class="tok-number">0x33</span>,       <span class="tok-number">0x34</span>,       <span class="tok-number">0x32</span>,       <span class="tok-number">0x31</span>,       <span class="tok-number">0x31</span>,       <span class="tok-number">0x37</span>,</span>
<span class="line" id="L978">            <span class="tok-number">0x30</span>,       <span class="tok-number">0x36</span>,       <span class="tok-number">0x37</span>,       <span class="tok-number">0x39</span>,       <span class="tok-number">0x38</span>,       <span class="tok-number">0x32</span>,       <span class="tok-number">0x31</span>,</span>
<span class="line" id="L979">            <span class="tok-number">0x34</span>,       <span class="tok-number">0x38</span>,       <span class="tok-number">0x30</span>,       <span class="tok-number">0x38</span>,       <span class="tok-number">0x36</span>,       <span class="tok-number">0x35</span>,       <span class="tok-number">0x31</span>,</span>
<span class="line" id="L980">            <span class="tok-number">0x33</span>,       <span class="tok-number">0x32</span>,       <span class="tok-number">0x38</span>,       <span class="tok-number">0x32</span>,       <span class="tok-number">0x33</span>,       <span class="tok-number">0x30</span>,       <span class="tok-number">0x36</span>,</span>
<span class="line" id="L981">            <span class="tok-number">0x36</span>,       <span class="tok-number">0x34</span>,       <span class="tok-number">0x37</span>,       <span class="tok-number">0x30</span>,       <span class="tok-number">0x39</span>,       <span class="tok-number">0x33</span>,       <span class="tok-number">0x38</span>,</span>
<span class="line" id="L982">            <span class="tok-number">0x34</span>,       <span class="tok-number">0x34</span>,       <span class="tok-number">0x36</span>,       <span class="tok-number">0x30</span>,       <span class="tok-number">0x39</span>,       <span class="tok-number">0x35</span>,       <span class="tok-number">0x35</span>,</span>
<span class="line" id="L983">            <span class="tok-number">0x30</span>,       <span class="tok-number">0x35</span>,       <span class="tok-number">0x38</span>,       <span class="tok-number">0x32</span>,       <span class="tok-number">0x32</span>,       <span class="tok-number">0x33</span>,       <span class="tok-number">0x31</span>,</span>
<span class="line" id="L984">            <span class="tok-number">0x37</span>,       <span class="tok-number">0x32</span>,       <span class="tok-number">0x35</span>,       <span class="tok-number">0x33</span>,       <span class="tok-number">0x35</span>,       <span class="tok-number">0x39</span>,       <span class="tok-number">0x34</span>,</span>
<span class="line" id="L985">            <span class="tok-number">0x30</span>,       <span class="tok-number">0x38</span>,       <span class="tok-number">0x31</span>,       <span class="tok-number">0x32</span>,       <span class="tok-number">0x38</span>,       <span class="tok-number">0x34</span>,       <span class="tok-number">0x38</span>,</span>
<span class="line" id="L986">            <span class="tok-number">0x31</span>,       <span class="tok-number">0x31</span>,       <span class="tok-number">0x31</span>,       <span class="tok-number">0x37</span>,       <span class="tok-number">0x34</span>,       <span class="tok-number">0x4040007e</span>, <span class="tok-number">0x34</span>,</span>
<span class="line" id="L987">            <span class="tok-number">0x31</span>,       <span class="tok-number">0x30</span>,       <span class="tok-number">0x32</span>,       <span class="tok-number">0x37</span>,       <span class="tok-number">0x30</span>,       <span class="tok-number">0x31</span>,       <span class="tok-number">0x39</span>,</span>
<span class="line" id="L988">            <span class="tok-number">0x33</span>,       <span class="tok-number">0x38</span>,       <span class="tok-number">0x35</span>,       <span class="tok-number">0x32</span>,       <span class="tok-number">0x31</span>,       <span class="tok-number">0x31</span>,       <span class="tok-number">0x30</span>,</span>
<span class="line" id="L989">            <span class="tok-number">0x35</span>,       <span class="tok-number">0x35</span>,       <span class="tok-number">0x35</span>,       <span class="tok-number">0x39</span>,       <span class="tok-number">0x36</span>,       <span class="tok-number">0x34</span>,       <span class="tok-number">0x34</span>,</span>
<span class="line" id="L990">            <span class="tok-number">0x36</span>,       <span class="tok-number">0x32</span>,       <span class="tok-number">0x32</span>,       <span class="tok-number">0x39</span>,       <span class="tok-number">0x34</span>,       <span class="tok-number">0x38</span>,       <span class="tok-number">0x39</span>,</span>
<span class="line" id="L991">            <span class="tok-number">0x35</span>,       <span class="tok-number">0x34</span>,       <span class="tok-number">0x39</span>,       <span class="tok-number">0x33</span>,       <span class="tok-number">0x30</span>,       <span class="tok-number">0x33</span>,       <span class="tok-number">0x38</span>,</span>
<span class="line" id="L992">            <span class="tok-number">0x31</span>,       <span class="tok-number">0x40400012</span>, <span class="tok-number">0x32</span>,       <span class="tok-number">0x38</span>,       <span class="tok-number">0x38</span>,       <span class="tok-number">0x31</span>,       <span class="tok-number">0x30</span>,</span>
<span class="line" id="L993">            <span class="tok-number">0x39</span>,       <span class="tok-number">0x37</span>,       <span class="tok-number">0x35</span>,       <span class="tok-number">0x36</span>,       <span class="tok-number">0x36</span>,       <span class="tok-number">0x35</span>,       <span class="tok-number">0x39</span>,</span>
<span class="line" id="L994">            <span class="tok-number">0x33</span>,       <span class="tok-number">0x33</span>,       <span class="tok-number">0x34</span>,       <span class="tok-number">0x34</span>,       <span class="tok-number">0x36</span>,       <span class="tok-number">0x40400047</span>, <span class="tok-number">0x37</span>,</span>
<span class="line" id="L995">            <span class="tok-number">0x35</span>,       <span class="tok-number">0x36</span>,       <span class="tok-number">0x34</span>,       <span class="tok-number">0x38</span>,       <span class="tok-number">0x32</span>,       <span class="tok-number">0x33</span>,       <span class="tok-number">0x33</span>,</span>
<span class="line" id="L996">            <span class="tok-number">0x37</span>,       <span class="tok-number">0x38</span>,       <span class="tok-number">0x36</span>,       <span class="tok-number">0x37</span>,       <span class="tok-number">0x38</span>,       <span class="tok-number">0x33</span>,       <span class="tok-number">0x31</span>,</span>
<span class="line" id="L997">            <span class="tok-number">0x36</span>,       <span class="tok-number">0x35</span>,       <span class="tok-number">0x32</span>,       <span class="tok-number">0x37</span>,       <span class="tok-number">0x31</span>,       <span class="tok-number">0x32</span>,       <span class="tok-number">0x30</span>,</span>
<span class="line" id="L998">            <span class="tok-number">0x31</span>,       <span class="tok-number">0x39</span>,       <span class="tok-number">0x30</span>,       <span class="tok-number">0x39</span>,       <span class="tok-number">0x31</span>,       <span class="tok-number">0x34</span>,       <span class="tok-number">0x4040001a</span>,</span>
<span class="line" id="L999">            <span class="tok-number">0x35</span>,       <span class="tok-number">0x36</span>,       <span class="tok-number">0x36</span>,       <span class="tok-number">0x39</span>,       <span class="tok-number">0x32</span>,       <span class="tok-number">0x33</span>,       <span class="tok-number">0x34</span>,</span>
<span class="line" id="L1000">            <span class="tok-number">0x36</span>,       <span class="tok-number">0x404000b2</span>, <span class="tok-number">0x36</span>,       <span class="tok-number">0x31</span>,       <span class="tok-number">0x30</span>,       <span class="tok-number">0x34</span>,       <span class="tok-number">0x35</span>,</span>
<span class="line" id="L1001">            <span class="tok-number">0x34</span>,       <span class="tok-number">0x33</span>,       <span class="tok-number">0x32</span>,       <span class="tok-number">0x36</span>,       <span class="tok-number">0x40400032</span>, <span class="tok-number">0x31</span>,       <span class="tok-number">0x33</span>,</span>
<span class="line" id="L1002">            <span class="tok-number">0x33</span>,       <span class="tok-number">0x39</span>,       <span class="tok-number">0x33</span>,       <span class="tok-number">0x36</span>,       <span class="tok-number">0x30</span>,       <span class="tok-number">0x37</span>,       <span class="tok-number">0x32</span>,</span>
<span class="line" id="L1003">            <span class="tok-number">0x36</span>,       <span class="tok-number">0x30</span>,       <span class="tok-number">0x32</span>,       <span class="tok-number">0x34</span>,       <span class="tok-number">0x39</span>,       <span class="tok-number">0x31</span>,       <span class="tok-number">0x34</span>,</span>
<span class="line" id="L1004">            <span class="tok-number">0x31</span>,       <span class="tok-number">0x32</span>,       <span class="tok-number">0x37</span>,       <span class="tok-number">0x33</span>,       <span class="tok-number">0x37</span>,       <span class="tok-number">0x32</span>,       <span class="tok-number">0x34</span>,</span>
<span class="line" id="L1005">            <span class="tok-number">0x35</span>,       <span class="tok-number">0x38</span>,       <span class="tok-number">0x37</span>,       <span class="tok-number">0x30</span>,       <span class="tok-number">0x30</span>,       <span class="tok-number">0x36</span>,       <span class="tok-number">0x36</span>,</span>
<span class="line" id="L1006">            <span class="tok-number">0x30</span>,       <span class="tok-number">0x36</span>,       <span class="tok-number">0x33</span>,       <span class="tok-number">0x31</span>,       <span class="tok-number">0x35</span>,       <span class="tok-number">0x35</span>,       <span class="tok-number">0x38</span>,</span>
<span class="line" id="L1007">            <span class="tok-number">0x38</span>,       <span class="tok-number">0x31</span>,       <span class="tok-number">0x37</span>,       <span class="tok-number">0x34</span>,       <span class="tok-number">0x38</span>,       <span class="tok-number">0x38</span>,       <span class="tok-number">0x31</span>,</span>
<span class="line" id="L1008">            <span class="tok-number">0x35</span>,       <span class="tok-number">0x32</span>,       <span class="tok-number">0x30</span>,       <span class="tok-number">0x39</span>,       <span class="tok-number">0x32</span>,       <span class="tok-number">0x30</span>,       <span class="tok-number">0x39</span>,</span>
<span class="line" id="L1009">            <span class="tok-number">0x36</span>,       <span class="tok-number">0x32</span>,       <span class="tok-number">0x38</span>,       <span class="tok-number">0x32</span>,       <span class="tok-number">0x39</span>,       <span class="tok-number">0x32</span>,       <span class="tok-number">0x35</span>,</span>
<span class="line" id="L1010">            <span class="tok-number">0x34</span>,       <span class="tok-number">0x30</span>,       <span class="tok-number">0x39</span>,       <span class="tok-number">0x31</span>,       <span class="tok-number">0x37</span>,       <span class="tok-number">0x31</span>,       <span class="tok-number">0x35</span>,</span>
<span class="line" id="L1011">            <span class="tok-number">0x33</span>,       <span class="tok-number">0x36</span>,       <span class="tok-number">0x34</span>,       <span class="tok-number">0x33</span>,       <span class="tok-number">0x36</span>,       <span class="tok-number">0x37</span>,       <span class="tok-number">0x38</span>,</span>
<span class="line" id="L1012">            <span class="tok-number">0x39</span>,       <span class="tok-number">0x32</span>,       <span class="tok-number">0x35</span>,       <span class="tok-number">0x39</span>,       <span class="tok-number">0x30</span>,       <span class="tok-number">0x33</span>,       <span class="tok-number">0x36</span>,</span>
<span class="line" id="L1013">            <span class="tok-number">0x30</span>,       <span class="tok-number">0x30</span>,       <span class="tok-number">0x31</span>,       <span class="tok-number">0x31</span>,       <span class="tok-number">0x33</span>,       <span class="tok-number">0x33</span>,       <span class="tok-number">0x30</span>,</span>
<span class="line" id="L1014">            <span class="tok-number">0x35</span>,       <span class="tok-number">0x33</span>,       <span class="tok-number">0x30</span>,       <span class="tok-number">0x35</span>,       <span class="tok-number">0x34</span>,       <span class="tok-number">0x38</span>,       <span class="tok-number">0x38</span>,</span>
<span class="line" id="L1015">            <span class="tok-number">0x32</span>,       <span class="tok-number">0x30</span>,       <span class="tok-number">0x34</span>,       <span class="tok-number">0x36</span>,       <span class="tok-number">0x36</span>,       <span class="tok-number">0x35</span>,       <span class="tok-number">0x32</span>,</span>
<span class="line" id="L1016">            <span class="tok-number">0x31</span>,       <span class="tok-number">0x33</span>,       <span class="tok-number">0x38</span>,       <span class="tok-number">0x34</span>,       <span class="tok-number">0x31</span>,       <span class="tok-number">0x34</span>,       <span class="tok-number">0x36</span>,</span>
<span class="line" id="L1017">            <span class="tok-number">0x39</span>,       <span class="tok-number">0x35</span>,       <span class="tok-number">0x31</span>,       <span class="tok-number">0x39</span>,       <span class="tok-number">0x34</span>,       <span class="tok-number">0x31</span>,       <span class="tok-number">0x35</span>,</span>
<span class="line" id="L1018">            <span class="tok-number">0x31</span>,       <span class="tok-number">0x31</span>,       <span class="tok-number">0x36</span>,       <span class="tok-number">0x30</span>,       <span class="tok-number">0x39</span>,       <span class="tok-number">0x34</span>,       <span class="tok-number">0x33</span>,</span>
<span class="line" id="L1019">            <span class="tok-number">0x33</span>,       <span class="tok-number">0x30</span>,       <span class="tok-number">0x35</span>,       <span class="tok-number">0x37</span>,       <span class="tok-number">0x32</span>,       <span class="tok-number">0x37</span>,       <span class="tok-number">0x30</span>,</span>
<span class="line" id="L1020">            <span class="tok-number">0x33</span>,       <span class="tok-number">0x36</span>,       <span class="tok-number">0x35</span>,       <span class="tok-number">0x37</span>,       <span class="tok-number">0x35</span>,       <span class="tok-number">0x39</span>,       <span class="tok-number">0x35</span>,</span>
<span class="line" id="L1021">            <span class="tok-number">0x39</span>,       <span class="tok-number">0x31</span>,       <span class="tok-number">0x39</span>,       <span class="tok-number">0x35</span>,       <span class="tok-number">0x33</span>,       <span class="tok-number">0x30</span>,       <span class="tok-number">0x39</span>,</span>
<span class="line" id="L1022">            <span class="tok-number">0x32</span>,       <span class="tok-number">0x31</span>,       <span class="tok-number">0x38</span>,       <span class="tok-number">0x36</span>,       <span class="tok-number">0x31</span>,       <span class="tok-number">0x31</span>,       <span class="tok-number">0x37</span>,</span>
<span class="line" id="L1023">            <span class="tok-number">0x404000e9</span>, <span class="tok-number">0x33</span>,       <span class="tok-number">0x32</span>,       <span class="tok-number">0x40400009</span>, <span class="tok-number">0x39</span>,       <span class="tok-number">0x33</span>,       <span class="tok-number">0x31</span>,</span>
<span class="line" id="L1024">            <span class="tok-number">0x30</span>,       <span class="tok-number">0x35</span>,       <span class="tok-number">0x31</span>,       <span class="tok-number">0x31</span>,       <span class="tok-number">0x38</span>,       <span class="tok-number">0x35</span>,       <span class="tok-number">0x34</span>,</span>
<span class="line" id="L1025">            <span class="tok-number">0x38</span>,       <span class="tok-number">0x30</span>,       <span class="tok-number">0x37</span>,       <span class="tok-number">0x4040010e</span>, <span class="tok-number">0x33</span>,       <span class="tok-number">0x37</span>,       <span class="tok-number">0x39</span>,</span>
<span class="line" id="L1026">            <span class="tok-number">0x39</span>,       <span class="tok-number">0x36</span>,       <span class="tok-number">0x32</span>,       <span class="tok-number">0x37</span>,       <span class="tok-number">0x34</span>,       <span class="tok-number">0x39</span>,       <span class="tok-number">0x35</span>,</span>
<span class="line" id="L1027">            <span class="tok-number">0x36</span>,       <span class="tok-number">0x37</span>,       <span class="tok-number">0x33</span>,       <span class="tok-number">0x35</span>,       <span class="tok-number">0x31</span>,       <span class="tok-number">0x38</span>,       <span class="tok-number">0x38</span>,</span>
<span class="line" id="L1028">            <span class="tok-number">0x35</span>,       <span class="tok-number">0x37</span>,       <span class="tok-number">0x35</span>,       <span class="tok-number">0x32</span>,       <span class="tok-number">0x37</span>,       <span class="tok-number">0x32</span>,       <span class="tok-number">0x34</span>,</span>
<span class="line" id="L1029">            <span class="tok-number">0x38</span>,       <span class="tok-number">0x39</span>,       <span class="tok-number">0x31</span>,       <span class="tok-number">0x32</span>,       <span class="tok-number">0x32</span>,       <span class="tok-number">0x37</span>,       <span class="tok-number">0x39</span>,</span>
<span class="line" id="L1030">            <span class="tok-number">0x33</span>,       <span class="tok-number">0x38</span>,       <span class="tok-number">0x31</span>,       <span class="tok-number">0x38</span>,       <span class="tok-number">0x33</span>,       <span class="tok-number">0x30</span>,       <span class="tok-number">0x31</span>,</span>
<span class="line" id="L1031">            <span class="tok-number">0x31</span>,       <span class="tok-number">0x39</span>,       <span class="tok-number">0x34</span>,       <span class="tok-number">0x39</span>,       <span class="tok-number">0x31</span>,       <span class="tok-number">0x32</span>,       <span class="tok-number">0x39</span>,</span>
<span class="line" id="L1032">            <span class="tok-number">0x38</span>,       <span class="tok-number">0x33</span>,       <span class="tok-number">0x33</span>,       <span class="tok-number">0x36</span>,       <span class="tok-number">0x37</span>,       <span class="tok-number">0x33</span>,       <span class="tok-number">0x33</span>,</span>
<span class="line" id="L1033">            <span class="tok-number">0x36</span>,       <span class="tok-number">0x32</span>,       <span class="tok-number">0x34</span>,       <span class="tok-number">0x34</span>,       <span class="tok-number">0x30</span>,       <span class="tok-number">0x36</span>,       <span class="tok-number">0x35</span>,</span>
<span class="line" id="L1034">            <span class="tok-number">0x36</span>,       <span class="tok-number">0x36</span>,       <span class="tok-number">0x34</span>,       <span class="tok-number">0x33</span>,       <span class="tok-number">0x30</span>,       <span class="tok-number">0x38</span>,       <span class="tok-number">0x36</span>,</span>
<span class="line" id="L1035">            <span class="tok-number">0x30</span>,       <span class="tok-number">0x32</span>,       <span class="tok-number">0x31</span>,       <span class="tok-number">0x33</span>,       <span class="tok-number">0x39</span>,       <span class="tok-number">0x34</span>,       <span class="tok-number">0x39</span>,</span>
<span class="line" id="L1036">            <span class="tok-number">0x34</span>,       <span class="tok-number">0x36</span>,       <span class="tok-number">0x33</span>,       <span class="tok-number">0x39</span>,       <span class="tok-number">0x35</span>,       <span class="tok-number">0x32</span>,       <span class="tok-number">0x32</span>,</span>
<span class="line" id="L1037">            <span class="tok-number">0x34</span>,       <span class="tok-number">0x37</span>,       <span class="tok-number">0x33</span>,       <span class="tok-number">0x37</span>,       <span class="tok-number">0x31</span>,       <span class="tok-number">0x39</span>,       <span class="tok-number">0x30</span>,</span>
<span class="line" id="L1038">            <span class="tok-number">0x37</span>,       <span class="tok-number">0x30</span>,       <span class="tok-number">0x32</span>,       <span class="tok-number">0x31</span>,       <span class="tok-number">0x37</span>,       <span class="tok-number">0x39</span>,       <span class="tok-number">0x38</span>,</span>
<span class="line" id="L1039">            <span class="tok-number">0x40800099</span>, <span class="tok-number">0x37</span>,       <span class="tok-number">0x30</span>,       <span class="tok-number">0x32</span>,       <span class="tok-number">0x37</span>,       <span class="tok-number">0x37</span>,       <span class="tok-number">0x30</span>,</span>
<span class="line" id="L1040">            <span class="tok-number">0x35</span>,       <span class="tok-number">0x33</span>,       <span class="tok-number">0x39</span>,       <span class="tok-number">0x32</span>,       <span class="tok-number">0x31</span>,       <span class="tok-number">0x37</span>,       <span class="tok-number">0x31</span>,</span>
<span class="line" id="L1041">            <span class="tok-number">0x37</span>,       <span class="tok-number">0x36</span>,       <span class="tok-number">0x32</span>,       <span class="tok-number">0x39</span>,       <span class="tok-number">0x33</span>,       <span class="tok-number">0x31</span>,       <span class="tok-number">0x37</span>,</span>
<span class="line" id="L1042">            <span class="tok-number">0x36</span>,       <span class="tok-number">0x37</span>,       <span class="tok-number">0x35</span>,       <span class="tok-number">0x40800232</span>, <span class="tok-number">0x37</span>,       <span class="tok-number">0x34</span>,       <span class="tok-number">0x38</span>,</span>
<span class="line" id="L1043">            <span class="tok-number">0x31</span>,       <span class="tok-number">0x40400006</span>, <span class="tok-number">0x36</span>,       <span class="tok-number">0x36</span>,       <span class="tok-number">0x39</span>,       <span class="tok-number">0x34</span>,       <span class="tok-number">0x30</span>,</span>
<span class="line" id="L1044">            <span class="tok-number">0x404001e7</span>, <span class="tok-number">0x30</span>,       <span class="tok-number">0x30</span>,       <span class="tok-number">0x30</span>,       <span class="tok-number">0x35</span>,       <span class="tok-number">0x36</span>,       <span class="tok-number">0x38</span>,</span>
<span class="line" id="L1045">            <span class="tok-number">0x31</span>,       <span class="tok-number">0x32</span>,       <span class="tok-number">0x37</span>,       <span class="tok-number">0x31</span>,       <span class="tok-number">0x34</span>,       <span class="tok-number">0x35</span>,       <span class="tok-number">0x32</span>,</span>
<span class="line" id="L1046">            <span class="tok-number">0x36</span>,       <span class="tok-number">0x33</span>,       <span class="tok-number">0x35</span>,       <span class="tok-number">0x36</span>,       <span class="tok-number">0x30</span>,       <span class="tok-number">0x38</span>,       <span class="tok-number">0x32</span>,</span>
<span class="line" id="L1047">            <span class="tok-number">0x37</span>,       <span class="tok-number">0x37</span>,       <span class="tok-number">0x38</span>,       <span class="tok-number">0x35</span>,       <span class="tok-number">0x37</span>,       <span class="tok-number">0x37</span>,       <span class="tok-number">0x31</span>,</span>
<span class="line" id="L1048">            <span class="tok-number">0x33</span>,       <span class="tok-number">0x34</span>,       <span class="tok-number">0x32</span>,       <span class="tok-number">0x37</span>,       <span class="tok-number">0x35</span>,       <span class="tok-number">0x37</span>,       <span class="tok-number">0x37</span>,</span>
<span class="line" id="L1049">            <span class="tok-number">0x38</span>,       <span class="tok-number">0x39</span>,       <span class="tok-number">0x36</span>,       <span class="tok-number">0x40400129</span>, <span class="tok-number">0x33</span>,       <span class="tok-number">0x36</span>,       <span class="tok-number">0x33</span>,</span>
<span class="line" id="L1050">            <span class="tok-number">0x37</span>,       <span class="tok-number">0x31</span>,       <span class="tok-number">0x37</span>,       <span class="tok-number">0x38</span>,       <span class="tok-number">0x37</span>,       <span class="tok-number">0x32</span>,       <span class="tok-number">0x31</span>,</span>
<span class="line" id="L1051">            <span class="tok-number">0x34</span>,       <span class="tok-number">0x36</span>,       <span class="tok-number">0x38</span>,       <span class="tok-number">0x34</span>,       <span class="tok-number">0x34</span>,       <span class="tok-number">0x30</span>,       <span class="tok-number">0x39</span>,</span>
<span class="line" id="L1052">            <span class="tok-number">0x30</span>,       <span class="tok-number">0x31</span>,       <span class="tok-number">0x32</span>,       <span class="tok-number">0x32</span>,       <span class="tok-number">0x34</span>,       <span class="tok-number">0x39</span>,       <span class="tok-number">0x35</span>,</span>
<span class="line" id="L1053">            <span class="tok-number">0x33</span>,       <span class="tok-number">0x34</span>,       <span class="tok-number">0x33</span>,       <span class="tok-number">0x30</span>,       <span class="tok-number">0x31</span>,       <span class="tok-number">0x34</span>,       <span class="tok-number">0x36</span>,</span>
<span class="line" id="L1054">            <span class="tok-number">0x35</span>,       <span class="tok-number">0x34</span>,       <span class="tok-number">0x39</span>,       <span class="tok-number">0x35</span>,       <span class="tok-number">0x38</span>,       <span class="tok-number">0x35</span>,       <span class="tok-number">0x33</span>,</span>
<span class="line" id="L1055">            <span class="tok-number">0x37</span>,       <span class="tok-number">0x31</span>,       <span class="tok-number">0x30</span>,       <span class="tok-number">0x35</span>,       <span class="tok-number">0x30</span>,       <span class="tok-number">0x37</span>,       <span class="tok-number">0x39</span>,</span>
<span class="line" id="L1056">            <span class="tok-number">0x404000ca</span>, <span class="tok-number">0x36</span>,       <span class="tok-number">0x40400153</span>, <span class="tok-number">0x38</span>,       <span class="tok-number">0x39</span>,       <span class="tok-number">0x32</span>,       <span class="tok-number">0x33</span>,</span>
<span class="line" id="L1057">            <span class="tok-number">0x35</span>,       <span class="tok-number">0x34</span>,       <span class="tok-number">0x404001c9</span>, <span class="tok-number">0x39</span>,       <span class="tok-number">0x35</span>,       <span class="tok-number">0x36</span>,       <span class="tok-number">0x31</span>,</span>
<span class="line" id="L1058">            <span class="tok-number">0x31</span>,       <span class="tok-number">0x32</span>,       <span class="tok-number">0x31</span>,       <span class="tok-number">0x32</span>,       <span class="tok-number">0x39</span>,       <span class="tok-number">0x30</span>,       <span class="tok-number">0x32</span>,</span>
<span class="line" id="L1059">            <span class="tok-number">0x31</span>,       <span class="tok-number">0x39</span>,       <span class="tok-number">0x36</span>,       <span class="tok-number">0x30</span>,       <span class="tok-number">0x38</span>,       <span class="tok-number">0x36</span>,       <span class="tok-number">0x34</span>,</span>
<span class="line" id="L1060">            <span class="tok-number">0x30</span>,       <span class="tok-number">0x33</span>,       <span class="tok-number">0x34</span>,       <span class="tok-number">0x34</span>,       <span class="tok-number">0x31</span>,       <span class="tok-number">0x38</span>,       <span class="tok-number">0x31</span>,</span>
<span class="line" id="L1061">            <span class="tok-number">0x35</span>,       <span class="tok-number">0x39</span>,       <span class="tok-number">0x38</span>,       <span class="tok-number">0x31</span>,       <span class="tok-number">0x33</span>,       <span class="tok-number">0x36</span>,       <span class="tok-number">0x32</span>,</span>
<span class="line" id="L1062">            <span class="tok-number">0x39</span>,       <span class="tok-number">0x37</span>,       <span class="tok-number">0x37</span>,       <span class="tok-number">0x34</span>,       <span class="tok-number">0x40400074</span>, <span class="tok-number">0x30</span>,       <span class="tok-number">0x39</span>,</span>
<span class="line" id="L1063">            <span class="tok-number">0x39</span>,       <span class="tok-number">0x36</span>,       <span class="tok-number">0x30</span>,       <span class="tok-number">0x35</span>,       <span class="tok-number">0x31</span>,       <span class="tok-number">0x38</span>,       <span class="tok-number">0x37</span>,</span>
<span class="line" id="L1064">            <span class="tok-number">0x30</span>,       <span class="tok-number">0x37</span>,       <span class="tok-number">0x32</span>,       <span class="tok-number">0x31</span>,       <span class="tok-number">0x31</span>,       <span class="tok-number">0x33</span>,       <span class="tok-number">0x34</span>,</span>
<span class="line" id="L1065">            <span class="tok-number">0x39</span>,       <span class="tok-number">0x40800000</span>, <span class="tok-number">0x38</span>,       <span class="tok-number">0x33</span>,       <span class="tok-number">0x37</span>,       <span class="tok-number">0x32</span>,       <span class="tok-number">0x39</span>,</span>
<span class="line" id="L1066">            <span class="tok-number">0x37</span>,       <span class="tok-number">0x38</span>,       <span class="tok-number">0x30</span>,       <span class="tok-number">0x34</span>,       <span class="tok-number">0x39</span>,       <span class="tok-number">0x39</span>,       <span class="tok-number">0x404002da</span>,</span>
<span class="line" id="L1067">            <span class="tok-number">0x39</span>,       <span class="tok-number">0x37</span>,       <span class="tok-number">0x33</span>,       <span class="tok-number">0x31</span>,       <span class="tok-number">0x37</span>,       <span class="tok-number">0x33</span>,       <span class="tok-number">0x32</span>,</span>
<span class="line" id="L1068">            <span class="tok-number">0x38</span>,       <span class="tok-number">0x4040018a</span>, <span class="tok-number">0x36</span>,       <span class="tok-number">0x33</span>,       <span class="tok-number">0x31</span>,       <span class="tok-number">0x38</span>,       <span class="tok-number">0x35</span>,</span>
<span class="line" id="L1069">            <span class="tok-number">0x40400301</span>, <span class="tok-number">0x404002e8</span>, <span class="tok-number">0x34</span>,       <span class="tok-number">0x35</span>,       <span class="tok-number">0x35</span>,       <span class="tok-number">0x33</span>,       <span class="tok-number">0x34</span>,</span>
<span class="line" id="L1070">            <span class="tok-number">0x36</span>,       <span class="tok-number">0x39</span>,       <span class="tok-number">0x30</span>,       <span class="tok-number">0x38</span>,       <span class="tok-number">0x33</span>,       <span class="tok-number">0x30</span>,       <span class="tok-number">0x32</span>,</span>
<span class="line" id="L1071">            <span class="tok-number">0x36</span>,       <span class="tok-number">0x34</span>,       <span class="tok-number">0x32</span>,       <span class="tok-number">0x35</span>,       <span class="tok-number">0x32</span>,       <span class="tok-number">0x32</span>,       <span class="tok-number">0x33</span>,</span>
<span class="line" id="L1072">            <span class="tok-number">0x30</span>,       <span class="tok-number">0x404002e3</span>, <span class="tok-number">0x40400267</span>, <span class="tok-number">0x38</span>,       <span class="tok-number">0x35</span>,       <span class="tok-number">0x30</span>,       <span class="tok-number">0x33</span>,</span>
<span class="line" id="L1073">            <span class="tok-number">0x35</span>,       <span class="tok-number">0x32</span>,       <span class="tok-number">0x36</span>,       <span class="tok-number">0x31</span>,       <span class="tok-number">0x39</span>,       <span class="tok-number">0x33</span>,       <span class="tok-number">0x31</span>,</span>
<span class="line" id="L1074">            <span class="tok-number">0x31</span>,       <span class="tok-number">0x40400212</span>, <span class="tok-number">0x31</span>,       <span class="tok-number">0x30</span>,       <span class="tok-number">0x31</span>,       <span class="tok-number">0x30</span>,       <span class="tok-number">0x30</span>,</span>
<span class="line" id="L1075">            <span class="tok-number">0x30</span>,       <span class="tok-number">0x33</span>,       <span class="tok-number">0x31</span>,       <span class="tok-number">0x33</span>,       <span class="tok-number">0x37</span>,       <span class="tok-number">0x38</span>,       <span class="tok-number">0x33</span>,</span>
<span class="line" id="L1076">            <span class="tok-number">0x38</span>,       <span class="tok-number">0x37</span>,       <span class="tok-number">0x35</span>,       <span class="tok-number">0x32</span>,       <span class="tok-number">0x38</span>,       <span class="tok-number">0x38</span>,       <span class="tok-number">0x36</span>,</span>
<span class="line" id="L1077">            <span class="tok-number">0x35</span>,       <span class="tok-number">0x38</span>,       <span class="tok-number">0x37</span>,       <span class="tok-number">0x35</span>,       <span class="tok-number">0x33</span>,       <span class="tok-number">0x33</span>,       <span class="tok-number">0x32</span>,</span>
<span class="line" id="L1078">            <span class="tok-number">0x30</span>,       <span class="tok-number">0x38</span>,       <span class="tok-number">0x33</span>,       <span class="tok-number">0x38</span>,       <span class="tok-number">0x31</span>,       <span class="tok-number">0x34</span>,       <span class="tok-number">0x32</span>,</span>
<span class="line" id="L1079">            <span class="tok-number">0x30</span>,       <span class="tok-number">0x36</span>,       <span class="tok-number">0x40400140</span>, <span class="tok-number">0x4040012b</span>, <span class="tok-number">0x31</span>,       <span class="tok-number">0x34</span>,       <span class="tok-number">0x37</span>,</span>
<span class="line" id="L1080">            <span class="tok-number">0x33</span>,       <span class="tok-number">0x30</span>,       <span class="tok-number">0x33</span>,       <span class="tok-number">0x35</span>,       <span class="tok-number">0x39</span>,       <span class="tok-number">0x4080032e</span>, <span class="tok-number">0x39</span>,</span>
<span class="line" id="L1081">            <span class="tok-number">0x30</span>,       <span class="tok-number">0x34</span>,       <span class="tok-number">0x32</span>,       <span class="tok-number">0x38</span>,       <span class="tok-number">0x37</span>,       <span class="tok-number">0x35</span>,       <span class="tok-number">0x35</span>,</span>
<span class="line" id="L1082">            <span class="tok-number">0x34</span>,       <span class="tok-number">0x36</span>,       <span class="tok-number">0x38</span>,       <span class="tok-number">0x37</span>,       <span class="tok-number">0x33</span>,       <span class="tok-number">0x31</span>,       <span class="tok-number">0x31</span>,</span>
<span class="line" id="L1083">            <span class="tok-number">0x35</span>,       <span class="tok-number">0x39</span>,       <span class="tok-number">0x35</span>,       <span class="tok-number">0x40400355</span>, <span class="tok-number">0x33</span>,       <span class="tok-number">0x38</span>,       <span class="tok-number">0x38</span>,</span>
<span class="line" id="L1084">            <span class="tok-number">0x32</span>,       <span class="tok-number">0x33</span>,       <span class="tok-number">0x35</span>,       <span class="tok-number">0x33</span>,       <span class="tok-number">0x37</span>,       <span class="tok-number">0x38</span>,       <span class="tok-number">0x37</span>,</span>
<span class="line" id="L1085">            <span class="tok-number">0x35</span>,       <span class="tok-number">0x4080037f</span>, <span class="tok-number">0x39</span>,       <span class="tok-number">0x4040013a</span>, <span class="tok-number">0x31</span>,       <span class="tok-number">0x40400148</span>, <span class="tok-number">0x38</span>,</span>
<span class="line" id="L1086">            <span class="tok-number">0x30</span>,       <span class="tok-number">0x35</span>,       <span class="tok-number">0x33</span>,       <span class="tok-number">0x4040018a</span>, <span class="tok-number">0x32</span>,       <span class="tok-number">0x32</span>,       <span class="tok-number">0x36</span>,</span>
<span class="line" id="L1087">            <span class="tok-number">0x38</span>,       <span class="tok-number">0x30</span>,       <span class="tok-number">0x36</span>,       <span class="tok-number">0x36</span>,       <span class="tok-number">0x31</span>,       <span class="tok-number">0x33</span>,       <span class="tok-number">0x30</span>,</span>
<span class="line" id="L1088">            <span class="tok-number">0x30</span>,       <span class="tok-number">0x31</span>,       <span class="tok-number">0x39</span>,       <span class="tok-number">0x32</span>,       <span class="tok-number">0x37</span>,       <span class="tok-number">0x38</span>,       <span class="tok-number">0x37</span>,</span>
<span class="line" id="L1089">            <span class="tok-number">0x36</span>,       <span class="tok-number">0x36</span>,       <span class="tok-number">0x31</span>,       <span class="tok-number">0x31</span>,       <span class="tok-number">0x31</span>,       <span class="tok-number">0x39</span>,       <span class="tok-number">0x35</span>,</span>
<span class="line" id="L1090">            <span class="tok-number">0x39</span>,       <span class="tok-number">0x40400237</span>, <span class="tok-number">0x36</span>,       <span class="tok-number">0x40800124</span>, <span class="tok-number">0x38</span>,       <span class="tok-number">0x39</span>,       <span class="tok-number">0x33</span>,</span>
<span class="line" id="L1091">            <span class="tok-number">0x38</span>,       <span class="tok-number">0x30</span>,       <span class="tok-number">0x39</span>,       <span class="tok-number">0x35</span>,       <span class="tok-number">0x32</span>,       <span class="tok-number">0x35</span>,       <span class="tok-number">0x37</span>,</span>
<span class="line" id="L1092">            <span class="tok-number">0x32</span>,       <span class="tok-number">0x30</span>,       <span class="tok-number">0x31</span>,       <span class="tok-number">0x30</span>,       <span class="tok-number">0x36</span>,       <span class="tok-number">0x35</span>,       <span class="tok-number">0x34</span>,</span>
<span class="line" id="L1093">            <span class="tok-number">0x38</span>,       <span class="tok-number">0x35</span>,       <span class="tok-number">0x38</span>,       <span class="tok-number">0x36</span>,       <span class="tok-number">0x33</span>,       <span class="tok-number">0x32</span>,       <span class="tok-number">0x37</span>,</span>
<span class="line" id="L1094">            <span class="tok-number">0x4040009a</span>, <span class="tok-number">0x39</span>,       <span class="tok-number">0x33</span>,       <span class="tok-number">0x36</span>,       <span class="tok-number">0x31</span>,       <span class="tok-number">0x35</span>,       <span class="tok-number">0x33</span>,</span>
<span class="line" id="L1095">            <span class="tok-number">0x40400220</span>, <span class="tok-number">0x4080015c</span>, <span class="tok-number">0x32</span>,       <span class="tok-number">0x33</span>,       <span class="tok-number">0x30</span>,       <span class="tok-number">0x33</span>,       <span class="tok-number">0x30</span>,</span>
<span class="line" id="L1096">            <span class="tok-number">0x31</span>,       <span class="tok-number">0x39</span>,       <span class="tok-number">0x35</span>,       <span class="tok-number">0x32</span>,       <span class="tok-number">0x30</span>,       <span class="tok-number">0x33</span>,       <span class="tok-number">0x35</span>,</span>
<span class="line" id="L1097">            <span class="tok-number">0x33</span>,       <span class="tok-number">0x30</span>,       <span class="tok-number">0x31</span>,       <span class="tok-number">0x38</span>,       <span class="tok-number">0x35</span>,       <span class="tok-number">0x32</span>,       <span class="tok-number">0x40400171</span>,</span>
<span class="line" id="L1098">            <span class="tok-number">0x40400075</span>, <span class="tok-number">0x33</span>,       <span class="tok-number">0x36</span>,       <span class="tok-number">0x32</span>,       <span class="tok-number">0x32</span>,       <span class="tok-number">0x35</span>,       <span class="tok-number">0x39</span>,</span>
<span class="line" id="L1099">            <span class="tok-number">0x39</span>,       <span class="tok-number">0x34</span>,       <span class="tok-number">0x31</span>,       <span class="tok-number">0x33</span>,       <span class="tok-number">0x40400254</span>, <span class="tok-number">0x34</span>,       <span class="tok-number">0x39</span>,</span>
<span class="line" id="L1100">            <span class="tok-number">0x37</span>,       <span class="tok-number">0x32</span>,       <span class="tok-number">0x31</span>,       <span class="tok-number">0x37</span>,       <span class="tok-number">0x404000de</span>, <span class="tok-number">0x33</span>,       <span class="tok-number">0x34</span>,</span>
<span class="line" id="L1101">            <span class="tok-number">0x37</span>,       <span class="tok-number">0x39</span>,       <span class="tok-number">0x31</span>,       <span class="tok-number">0x33</span>,       <span class="tok-number">0x31</span>,       <span class="tok-number">0x35</span>,       <span class="tok-number">0x31</span>,</span>
<span class="line" id="L1102">            <span class="tok-number">0x35</span>,       <span class="tok-number">0x35</span>,       <span class="tok-number">0x37</span>,       <span class="tok-number">0x34</span>,       <span class="tok-number">0x38</span>,       <span class="tok-number">0x35</span>,       <span class="tok-number">0x37</span>,</span>
<span class="line" id="L1103">            <span class="tok-number">0x32</span>,       <span class="tok-number">0x34</span>,       <span class="tok-number">0x32</span>,       <span class="tok-number">0x34</span>,       <span class="tok-number">0x35</span>,       <span class="tok-number">0x34</span>,       <span class="tok-number">0x31</span>,</span>
<span class="line" id="L1104">            <span class="tok-number">0x35</span>,       <span class="tok-number">0x30</span>,       <span class="tok-number">0x36</span>,       <span class="tok-number">0x39</span>,       <span class="tok-number">0x4040013f</span>, <span class="tok-number">0x38</span>,       <span class="tok-number">0x32</span>,</span>
<span class="line" id="L1105">            <span class="tok-number">0x39</span>,       <span class="tok-number">0x35</span>,       <span class="tok-number">0x33</span>,       <span class="tok-number">0x33</span>,       <span class="tok-number">0x31</span>,       <span class="tok-number">0x31</span>,       <span class="tok-number">0x36</span>,</span>
<span class="line" id="L1106">            <span class="tok-number">0x38</span>,       <span class="tok-number">0x36</span>,       <span class="tok-number">0x31</span>,       <span class="tok-number">0x37</span>,       <span class="tok-number">0x32</span>,       <span class="tok-number">0x37</span>,       <span class="tok-number">0x38</span>,</span>
<span class="line" id="L1107">            <span class="tok-number">0x40400337</span>, <span class="tok-number">0x39</span>,       <span class="tok-number">0x30</span>,       <span class="tok-number">0x37</span>,       <span class="tok-number">0x35</span>,       <span class="tok-number">0x30</span>,       <span class="tok-number">0x39</span>,</span>
<span class="line" id="L1108">            <span class="tok-number">0x4040010d</span>, <span class="tok-number">0x37</span>,       <span class="tok-number">0x35</span>,       <span class="tok-number">0x34</span>,       <span class="tok-number">0x36</span>,       <span class="tok-number">0x33</span>,       <span class="tok-number">0x37</span>,</span>
<span class="line" id="L1109">            <span class="tok-number">0x34</span>,       <span class="tok-number">0x36</span>,       <span class="tok-number">0x34</span>,       <span class="tok-number">0x39</span>,       <span class="tok-number">0x33</span>,       <span class="tok-number">0x39</span>,       <span class="tok-number">0x33</span>,</span>
<span class="line" id="L1110">            <span class="tok-number">0x31</span>,       <span class="tok-number">0x39</span>,       <span class="tok-number">0x32</span>,       <span class="tok-number">0x35</span>,       <span class="tok-number">0x35</span>,       <span class="tok-number">0x30</span>,       <span class="tok-number">0x36</span>,</span>
<span class="line" id="L1111">            <span class="tok-number">0x30</span>,       <span class="tok-number">0x34</span>,       <span class="tok-number">0x30</span>,       <span class="tok-number">0x30</span>,       <span class="tok-number">0x39</span>,       <span class="tok-number">0x4040026b</span>, <span class="tok-number">0x31</span>,</span>
<span class="line" id="L1112">            <span class="tok-number">0x36</span>,       <span class="tok-number">0x37</span>,       <span class="tok-number">0x31</span>,       <span class="tok-number">0x31</span>,       <span class="tok-number">0x33</span>,       <span class="tok-number">0x39</span>,       <span class="tok-number">0x30</span>,</span>
<span class="line" id="L1113">            <span class="tok-number">0x30</span>,       <span class="tok-number">0x39</span>,       <span class="tok-number">0x38</span>,       <span class="tok-number">0x40400335</span>, <span class="tok-number">0x34</span>,       <span class="tok-number">0x30</span>,       <span class="tok-number">0x31</span>,</span>
<span class="line" id="L1114">            <span class="tok-number">0x32</span>,       <span class="tok-number">0x38</span>,       <span class="tok-number">0x35</span>,       <span class="tok-number">0x38</span>,       <span class="tok-number">0x33</span>,       <span class="tok-number">0x36</span>,       <span class="tok-number">0x31</span>,</span>
<span class="line" id="L1115">            <span class="tok-number">0x36</span>,       <span class="tok-number">0x30</span>,       <span class="tok-number">0x33</span>,       <span class="tok-number">0x35</span>,       <span class="tok-number">0x36</span>,       <span class="tok-number">0x33</span>,       <span class="tok-number">0x37</span>,</span>
<span class="line" id="L1116">            <span class="tok-number">0x30</span>,       <span class="tok-number">0x37</span>,       <span class="tok-number">0x36</span>,       <span class="tok-number">0x36</span>,       <span class="tok-number">0x30</span>,       <span class="tok-number">0x31</span>,       <span class="tok-number">0x30</span>,</span>
<span class="line" id="L1117">            <span class="tok-number">0x34</span>,       <span class="tok-number">0x40400172</span>, <span class="tok-number">0x38</span>,       <span class="tok-number">0x31</span>,       <span class="tok-number">0x39</span>,       <span class="tok-number">0x34</span>,       <span class="tok-number">0x32</span>,</span>
<span class="line" id="L1118">            <span class="tok-number">0x39</span>,       <span class="tok-number">0x4080041e</span>, <span class="tok-number">0x404000ef</span>, <span class="tok-number">0x4040028b</span>, <span class="tok-number">0x37</span>,       <span class="tok-number">0x38</span>,       <span class="tok-number">0x33</span>,</span>
<span class="line" id="L1119">            <span class="tok-number">0x37</span>,       <span class="tok-number">0x34</span>,       <span class="tok-number">0x404004a8</span>, <span class="tok-number">0x38</span>,       <span class="tok-number">0x32</span>,       <span class="tok-number">0x35</span>,       <span class="tok-number">0x35</span>,</span>
<span class="line" id="L1120">            <span class="tok-number">0x33</span>,       <span class="tok-number">0x37</span>,       <span class="tok-number">0x40800209</span>, <span class="tok-number">0x32</span>,       <span class="tok-number">0x36</span>,       <span class="tok-number">0x38</span>,       <span class="tok-number">0x4040002e</span>,</span>
<span class="line" id="L1121">            <span class="tok-number">0x34</span>,       <span class="tok-number">0x30</span>,       <span class="tok-number">0x34</span>,       <span class="tok-number">0x37</span>,       <span class="tok-number">0x404001d1</span>, <span class="tok-number">0x34</span>,       <span class="tok-number">0x404004b5</span>,</span>
<span class="line" id="L1122">            <span class="tok-number">0x4040038d</span>, <span class="tok-number">0x38</span>,       <span class="tok-number">0x34</span>,       <span class="tok-number">0x404003a8</span>, <span class="tok-number">0x36</span>,       <span class="tok-number">0x40c0031f</span>, <span class="tok-number">0x33</span>,</span>
<span class="line" id="L1123">            <span class="tok-number">0x33</span>,       <span class="tok-number">0x31</span>,       <span class="tok-number">0x33</span>,       <span class="tok-number">0x36</span>,       <span class="tok-number">0x37</span>,       <span class="tok-number">0x37</span>,       <span class="tok-number">0x30</span>,</span>
<span class="line" id="L1124">            <span class="tok-number">0x32</span>,       <span class="tok-number">0x38</span>,       <span class="tok-number">0x39</span>,       <span class="tok-number">0x38</span>,       <span class="tok-number">0x39</span>,       <span class="tok-number">0x31</span>,       <span class="tok-number">0x35</span>,</span>
<span class="line" id="L1125">            <span class="tok-number">0x32</span>,       <span class="tok-number">0x40400062</span>, <span class="tok-number">0x35</span>,       <span class="tok-number">0x32</span>,       <span class="tok-number">0x31</span>,       <span class="tok-number">0x36</span>,       <span class="tok-number">0x32</span>,</span>
<span class="line" id="L1126">            <span class="tok-number">0x30</span>,       <span class="tok-number">0x35</span>,       <span class="tok-number">0x36</span>,       <span class="tok-number">0x39</span>,       <span class="tok-number">0x36</span>,       <span class="tok-number">0x40400411</span>, <span class="tok-number">0x30</span>,</span>
<span class="line" id="L1127">            <span class="tok-number">0x35</span>,       <span class="tok-number">0x38</span>,       <span class="tok-number">0x40400477</span>, <span class="tok-number">0x35</span>,       <span class="tok-number">0x40400498</span>, <span class="tok-number">0x35</span>,       <span class="tok-number">0x31</span>,</span>
<span class="line" id="L1128">            <span class="tok-number">0x31</span>,       <span class="tok-number">0x40400209</span>, <span class="tok-number">0x38</span>,       <span class="tok-number">0x32</span>,       <span class="tok-number">0x34</span>,       <span class="tok-number">0x33</span>,       <span class="tok-number">0x30</span>,</span>
<span class="line" id="L1129">            <span class="tok-number">0x30</span>,       <span class="tok-number">0x33</span>,       <span class="tok-number">0x35</span>,       <span class="tok-number">0x35</span>,       <span class="tok-number">0x38</span>,       <span class="tok-number">0x37</span>,       <span class="tok-number">0x36</span>,</span>
<span class="line" id="L1130">            <span class="tok-number">0x34</span>,       <span class="tok-number">0x30</span>,       <span class="tok-number">0x32</span>,       <span class="tok-number">0x34</span>,       <span class="tok-number">0x37</span>,       <span class="tok-number">0x34</span>,       <span class="tok-number">0x39</span>,</span>
<span class="line" id="L1131">            <span class="tok-number">0x36</span>,       <span class="tok-number">0x34</span>,       <span class="tok-number">0x37</span>,       <span class="tok-number">0x33</span>,       <span class="tok-number">0x32</span>,       <span class="tok-number">0x36</span>,       <span class="tok-number">0x33</span>,</span>
<span class="line" id="L1132">            <span class="tok-number">0x4040043e</span>, <span class="tok-number">0x39</span>,       <span class="tok-number">0x39</span>,       <span class="tok-number">0x32</span>,       <span class="tok-number">0x4040044b</span>, <span class="tok-number">0x34</span>,       <span class="tok-number">0x32</span>,</span>
<span class="line" id="L1133">            <span class="tok-number">0x36</span>,       <span class="tok-number">0x39</span>,       <span class="tok-number">0x40c002c5</span>, <span class="tok-number">0x37</span>,       <span class="tok-number">0x404001d6</span>, <span class="tok-number">0x34</span>,       <span class="tok-number">0x4040053d</span>,</span>
<span class="line" id="L1134">            <span class="tok-number">0x4040041d</span>, <span class="tok-number">0x39</span>,       <span class="tok-number">0x33</span>,       <span class="tok-number">0x34</span>,       <span class="tok-number">0x31</span>,       <span class="tok-number">0x37</span>,       <span class="tok-number">0x404001ad</span>,</span>
<span class="line" id="L1135">            <span class="tok-number">0x31</span>,       <span class="tok-number">0x32</span>,       <span class="tok-number">0x4040002a</span>, <span class="tok-number">0x34</span>,       <span class="tok-number">0x4040019e</span>, <span class="tok-number">0x31</span>,       <span class="tok-number">0x35</span>,</span>
<span class="line" id="L1136">            <span class="tok-number">0x30</span>,       <span class="tok-number">0x33</span>,       <span class="tok-number">0x30</span>,       <span class="tok-number">0x32</span>,       <span class="tok-number">0x38</span>,       <span class="tok-number">0x36</span>,       <span class="tok-number">0x31</span>,</span>
<span class="line" id="L1137">            <span class="tok-number">0x38</span>,       <span class="tok-number">0x32</span>,       <span class="tok-number">0x39</span>,       <span class="tok-number">0x37</span>,       <span class="tok-number">0x34</span>,       <span class="tok-number">0x35</span>,       <span class="tok-number">0x35</span>,</span>
<span class="line" id="L1138">            <span class="tok-number">0x35</span>,       <span class="tok-number">0x37</span>,       <span class="tok-number">0x30</span>,       <span class="tok-number">0x36</span>,       <span class="tok-number">0x37</span>,       <span class="tok-number">0x34</span>,       <span class="tok-number">0x40400135</span>,</span>
<span class="line" id="L1139">            <span class="tok-number">0x35</span>,       <span class="tok-number">0x30</span>,       <span class="tok-number">0x35</span>,       <span class="tok-number">0x34</span>,       <span class="tok-number">0x39</span>,       <span class="tok-number">0x34</span>,       <span class="tok-number">0x35</span>,</span>
<span class="line" id="L1140">            <span class="tok-number">0x38</span>,       <span class="tok-number">0x404001c5</span>, <span class="tok-number">0x39</span>,       <span class="tok-number">0x40400051</span>, <span class="tok-number">0x35</span>,       <span class="tok-number">0x36</span>,       <span class="tok-number">0x404001ec</span>,</span>
<span class="line" id="L1141">            <span class="tok-number">0x37</span>,       <span class="tok-number">0x32</span>,       <span class="tok-number">0x31</span>,       <span class="tok-number">0x30</span>,       <span class="tok-number">0x37</span>,       <span class="tok-number">0x39</span>,       <span class="tok-number">0x40400159</span>,</span>
<span class="line" id="L1142">            <span class="tok-number">0x33</span>,       <span class="tok-number">0x30</span>,       <span class="tok-number">0x4040010a</span>, <span class="tok-number">0x33</span>,       <span class="tok-number">0x32</span>,       <span class="tok-number">0x31</span>,       <span class="tok-number">0x31</span>,</span>
<span class="line" id="L1143">            <span class="tok-number">0x36</span>,       <span class="tok-number">0x35</span>,       <span class="tok-number">0x33</span>,       <span class="tok-number">0x34</span>,       <span class="tok-number">0x34</span>,       <span class="tok-number">0x39</span>,       <span class="tok-number">0x38</span>,</span>
<span class="line" id="L1144">            <span class="tok-number">0x37</span>,       <span class="tok-number">0x32</span>,       <span class="tok-number">0x30</span>,       <span class="tok-number">0x32</span>,       <span class="tok-number">0x37</span>,       <span class="tok-number">0x4040011b</span>, <span class="tok-number">0x30</span>,</span>
<span class="line" id="L1145">            <span class="tok-number">0x32</span>,       <span class="tok-number">0x33</span>,       <span class="tok-number">0x36</span>,       <span class="tok-number">0x34</span>,       <span class="tok-number">0x4040022e</span>, <span class="tok-number">0x35</span>,       <span class="tok-number">0x34</span>,</span>
<span class="line" id="L1146">            <span class="tok-number">0x39</span>,       <span class="tok-number">0x39</span>,       <span class="tok-number">0x31</span>,       <span class="tok-number">0x31</span>,       <span class="tok-number">0x39</span>,       <span class="tok-number">0x38</span>,       <span class="tok-number">0x40400418</span>,</span>
<span class="line" id="L1147">            <span class="tok-number">0x34</span>,       <span class="tok-number">0x4040011b</span>, <span class="tok-number">0x35</span>,       <span class="tok-number">0x33</span>,       <span class="tok-number">0x35</span>,       <span class="tok-number">0x36</span>,       <span class="tok-number">0x36</span>,</span>
<span class="line" id="L1148">            <span class="tok-number">0x33</span>,       <span class="tok-number">0x36</span>,       <span class="tok-number">0x39</span>,       <span class="tok-number">0x40400450</span>, <span class="tok-number">0x32</span>,       <span class="tok-number">0x36</span>,       <span class="tok-number">0x35</span>,</span>
<span class="line" id="L1149">            <span class="tok-number">0x404002e4</span>, <span class="tok-number">0x37</span>,       <span class="tok-number">0x38</span>,       <span class="tok-number">0x36</span>,       <span class="tok-number">0x32</span>,       <span class="tok-number">0x35</span>,       <span class="tok-number">0x35</span>,</span>
<span class="line" id="L1150">            <span class="tok-number">0x31</span>,       <span class="tok-number">0x404003da</span>, <span class="tok-number">0x31</span>,       <span class="tok-number">0x37</span>,       <span class="tok-number">0x35</span>,       <span class="tok-number">0x37</span>,       <span class="tok-number">0x34</span>,</span>
<span class="line" id="L1151">            <span class="tok-number">0x36</span>,       <span class="tok-number">0x37</span>,       <span class="tok-number">0x32</span>,       <span class="tok-number">0x38</span>,       <span class="tok-number">0x39</span>,       <span class="tok-number">0x30</span>,       <span class="tok-number">0x39</span>,</span>
<span class="line" id="L1152">            <span class="tok-number">0x37</span>,       <span class="tok-number">0x37</span>,       <span class="tok-number">0x37</span>,       <span class="tok-number">0x37</span>,       <span class="tok-number">0x40800453</span>, <span class="tok-number">0x30</span>,       <span class="tok-number">0x30</span>,</span>
<span class="line" id="L1153">            <span class="tok-number">0x30</span>,       <span class="tok-number">0x404005fd</span>, <span class="tok-number">0x37</span>,       <span class="tok-number">0x30</span>,       <span class="tok-number">0x404004df</span>, <span class="tok-number">0x36</span>,       <span class="tok-number">0x404003e9</span>,</span>
<span class="line" id="L1154">            <span class="tok-number">0x34</span>,       <span class="tok-number">0x39</span>,       <span class="tok-number">0x31</span>,       <span class="tok-number">0x4040041e</span>, <span class="tok-number">0x40400297</span>, <span class="tok-number">0x32</span>,       <span class="tok-number">0x31</span>,</span>
<span class="line" id="L1155">            <span class="tok-number">0x34</span>,       <span class="tok-number">0x37</span>,       <span class="tok-number">0x37</span>,       <span class="tok-number">0x32</span>,       <span class="tok-number">0x33</span>,       <span class="tok-number">0x35</span>,       <span class="tok-number">0x30</span>,</span>
<span class="line" id="L1156">            <span class="tok-number">0x31</span>,       <span class="tok-number">0x34</span>,       <span class="tok-number">0x31</span>,       <span class="tok-number">0x34</span>,       <span class="tok-number">0x40400643</span>, <span class="tok-number">0x33</span>,       <span class="tok-number">0x35</span>,</span>
<span class="line" id="L1157">            <span class="tok-number">0x36</span>,       <span class="tok-number">0x404004af</span>, <span class="tok-number">0x31</span>,       <span class="tok-number">0x36</span>,       <span class="tok-number">0x31</span>,       <span class="tok-number">0x33</span>,       <span class="tok-number">0x36</span>,</span>
<span class="line" id="L1158">            <span class="tok-number">0x31</span>,       <span class="tok-number">0x31</span>,       <span class="tok-number">0x35</span>,       <span class="tok-number">0x37</span>,       <span class="tok-number">0x33</span>,       <span class="tok-number">0x35</span>,       <span class="tok-number">0x32</span>,</span>
<span class="line" id="L1159">            <span class="tok-number">0x35</span>,       <span class="tok-number">0x40400504</span>, <span class="tok-number">0x33</span>,       <span class="tok-number">0x34</span>,       <span class="tok-number">0x4040005b</span>, <span class="tok-number">0x31</span>,       <span class="tok-number">0x38</span>,</span>
<span class="line" id="L1160">            <span class="tok-number">0x4040047b</span>, <span class="tok-number">0x38</span>,       <span class="tok-number">0x34</span>,       <span class="tok-number">0x404005e7</span>, <span class="tok-number">0x33</span>,       <span class="tok-number">0x33</span>,       <span class="tok-number">0x32</span>,</span>
<span class="line" id="L1161">            <span class="tok-number">0x33</span>,       <span class="tok-number">0x39</span>,       <span class="tok-number">0x30</span>,       <span class="tok-number">0x37</span>,       <span class="tok-number">0x33</span>,       <span class="tok-number">0x39</span>,       <span class="tok-number">0x34</span>,</span>
<span class="line" id="L1162">            <span class="tok-number">0x31</span>,       <span class="tok-number">0x34</span>,       <span class="tok-number">0x33</span>,       <span class="tok-number">0x33</span>,       <span class="tok-number">0x33</span>,       <span class="tok-number">0x34</span>,       <span class="tok-number">0x35</span>,</span>
<span class="line" id="L1163">            <span class="tok-number">0x34</span>,       <span class="tok-number">0x37</span>,       <span class="tok-number">0x37</span>,       <span class="tok-number">0x36</span>,       <span class="tok-number">0x32</span>,       <span class="tok-number">0x34</span>,       <span class="tok-number">0x40400242</span>,</span>
<span class="line" id="L1164">            <span class="tok-number">0x32</span>,       <span class="tok-number">0x35</span>,       <span class="tok-number">0x31</span>,       <span class="tok-number">0x38</span>,       <span class="tok-number">0x39</span>,       <span class="tok-number">0x38</span>,       <span class="tok-number">0x33</span>,</span>
<span class="line" id="L1165">            <span class="tok-number">0x35</span>,       <span class="tok-number">0x36</span>,       <span class="tok-number">0x39</span>,       <span class="tok-number">0x34</span>,       <span class="tok-number">0x38</span>,       <span class="tok-number">0x35</span>,       <span class="tok-number">0x35</span>,</span>
<span class="line" id="L1166">            <span class="tok-number">0x36</span>,       <span class="tok-number">0x32</span>,       <span class="tok-number">0x30</span>,       <span class="tok-number">0x39</span>,       <span class="tok-number">0x39</span>,       <span class="tok-number">0x32</span>,       <span class="tok-number">0x31</span>,</span>
<span class="line" id="L1167">            <span class="tok-number">0x39</span>,       <span class="tok-number">0x32</span>,       <span class="tok-number">0x32</span>,       <span class="tok-number">0x32</span>,       <span class="tok-number">0x31</span>,       <span class="tok-number">0x38</span>,       <span class="tok-number">0x34</span>,</span>
<span class="line" id="L1168">            <span class="tok-number">0x32</span>,       <span class="tok-number">0x37</span>,       <span class="tok-number">0x4040023e</span>, <span class="tok-number">0x32</span>,       <span class="tok-number">0x404000ba</span>, <span class="tok-number">0x36</span>,       <span class="tok-number">0x38</span>,</span>
<span class="line" id="L1169">            <span class="tok-number">0x38</span>,       <span class="tok-number">0x37</span>,       <span class="tok-number">0x36</span>,       <span class="tok-number">0x37</span>,       <span class="tok-number">0x31</span>,       <span class="tok-number">0x37</span>,       <span class="tok-number">0x39</span>,</span>
<span class="line" id="L1170">            <span class="tok-number">0x30</span>,       <span class="tok-number">0x40400055</span>, <span class="tok-number">0x30</span>,       <span class="tok-number">0x40800106</span>, <span class="tok-number">0x36</span>,       <span class="tok-number">0x36</span>,       <span class="tok-number">0x404003e7</span>,</span>
<span class="line" id="L1171">            <span class="tok-number">0x38</span>,       <span class="tok-number">0x38</span>,       <span class="tok-number">0x36</span>,       <span class="tok-number">0x32</span>,       <span class="tok-number">0x37</span>,       <span class="tok-number">0x32</span>,       <span class="tok-number">0x404006dc</span>,</span>
<span class="line" id="L1172">            <span class="tok-number">0x31</span>,       <span class="tok-number">0x37</span>,       <span class="tok-number">0x38</span>,       <span class="tok-number">0x36</span>,       <span class="tok-number">0x30</span>,       <span class="tok-number">0x38</span>,       <span class="tok-number">0x35</span>,</span>
<span class="line" id="L1173">            <span class="tok-number">0x37</span>,       <span class="tok-number">0x40400073</span>, <span class="tok-number">0x33</span>,       <span class="tok-number">0x408002fc</span>, <span class="tok-number">0x37</span>,       <span class="tok-number">0x39</span>,       <span class="tok-number">0x37</span>,</span>
<span class="line" id="L1174">            <span class="tok-number">0x36</span>,       <span class="tok-number">0x36</span>,       <span class="tok-number">0x38</span>,       <span class="tok-number">0x31</span>,       <span class="tok-number">0x404002bd</span>, <span class="tok-number">0x30</span>,       <span class="tok-number">0x30</span>,</span>
<span class="line" id="L1175">            <span class="tok-number">0x39</span>,       <span class="tok-number">0x35</span>,       <span class="tok-number">0x33</span>,       <span class="tok-number">0x38</span>,       <span class="tok-number">0x38</span>,       <span class="tok-number">0x40400638</span>, <span class="tok-number">0x33</span>,</span>
<span class="line" id="L1176">            <span class="tok-number">0x404006a5</span>, <span class="tok-number">0x30</span>,       <span class="tok-number">0x36</span>,       <span class="tok-number">0x38</span>,       <span class="tok-number">0x30</span>,       <span class="tok-number">0x30</span>,       <span class="tok-number">0x36</span>,</span>
<span class="line" id="L1177">            <span class="tok-number">0x34</span>,       <span class="tok-number">0x32</span>,       <span class="tok-number">0x32</span>,       <span class="tok-number">0x35</span>,       <span class="tok-number">0x31</span>,       <span class="tok-number">0x32</span>,       <span class="tok-number">0x35</span>,</span>
<span class="line" id="L1178">            <span class="tok-number">0x32</span>,       <span class="tok-number">0x4040057b</span>, <span class="tok-number">0x37</span>,       <span class="tok-number">0x33</span>,       <span class="tok-number">0x39</span>,       <span class="tok-number">0x32</span>,       <span class="tok-number">0x40400297</span>,</span>
<span class="line" id="L1179">            <span class="tok-number">0x40400474</span>, <span class="tok-number">0x34</span>,       <span class="tok-number">0x408006b3</span>, <span class="tok-number">0x38</span>,       <span class="tok-number">0x36</span>,       <span class="tok-number">0x32</span>,       <span class="tok-number">0x36</span>,</span>
<span class="line" id="L1180">            <span class="tok-number">0x39</span>,       <span class="tok-number">0x34</span>,       <span class="tok-number">0x35</span>,       <span class="tok-number">0x404001e5</span>, <span class="tok-number">0x34</span>,       <span class="tok-number">0x31</span>,       <span class="tok-number">0x39</span>,</span>
<span class="line" id="L1181">            <span class="tok-number">0x36</span>,       <span class="tok-number">0x35</span>,       <span class="tok-number">0x32</span>,       <span class="tok-number">0x38</span>,       <span class="tok-number">0x35</span>,       <span class="tok-number">0x30</span>,       <span class="tok-number">0x40400099</span>,</span>
<span class="line" id="L1182">            <span class="tok-number">0x4040039c</span>, <span class="tok-number">0x31</span>,       <span class="tok-number">0x38</span>,       <span class="tok-number">0x36</span>,       <span class="tok-number">0x33</span>,       <span class="tok-number">0x404001be</span>, <span class="tok-number">0x34</span>,</span>
<span class="line" id="L1183">            <span class="tok-number">0x40800154</span>, <span class="tok-number">0x32</span>,       <span class="tok-number">0x30</span>,       <span class="tok-number">0x33</span>,       <span class="tok-number">0x39</span>,       <span class="tok-number">0x4040058b</span>, <span class="tok-number">0x34</span>,</span>
<span class="line" id="L1184">            <span class="tok-number">0x35</span>,       <span class="tok-number">0x404002bc</span>, <span class="tok-number">0x32</span>,       <span class="tok-number">0x33</span>,       <span class="tok-number">0x37</span>,       <span class="tok-number">0x4040042c</span>, <span class="tok-number">0x36</span>,</span>
<span class="line" id="L1185">            <span class="tok-number">0x40400510</span>, <span class="tok-number">0x35</span>,       <span class="tok-number">0x36</span>,       <span class="tok-number">0x40400638</span>, <span class="tok-number">0x37</span>,       <span class="tok-number">0x31</span>,       <span class="tok-number">0x39</span>,</span>
<span class="line" id="L1186">            <span class="tok-number">0x31</span>,       <span class="tok-number">0x37</span>,       <span class="tok-number">0x32</span>,       <span class="tok-number">0x38</span>,       <span class="tok-number">0x40400171</span>, <span class="tok-number">0x37</span>,       <span class="tok-number">0x36</span>,</span>
<span class="line" id="L1187">            <span class="tok-number">0x34</span>,       <span class="tok-number">0x36</span>,       <span class="tok-number">0x35</span>,       <span class="tok-number">0x37</span>,       <span class="tok-number">0x35</span>,       <span class="tok-number">0x37</span>,       <span class="tok-number">0x33</span>,</span>
<span class="line" id="L1188">            <span class="tok-number">0x39</span>,       <span class="tok-number">0x40400101</span>, <span class="tok-number">0x33</span>,       <span class="tok-number">0x38</span>,       <span class="tok-number">0x39</span>,       <span class="tok-number">0x40400748</span>, <span class="tok-number">0x38</span>,</span>
<span class="line" id="L1189">            <span class="tok-number">0x33</span>,       <span class="tok-number">0x32</span>,       <span class="tok-number">0x36</span>,       <span class="tok-number">0x34</span>,       <span class="tok-number">0x35</span>,       <span class="tok-number">0x39</span>,       <span class="tok-number">0x39</span>,</span>
<span class="line" id="L1190">            <span class="tok-number">0x35</span>,       <span class="tok-number">0x38</span>,       <span class="tok-number">0x404006a7</span>, <span class="tok-number">0x30</span>,       <span class="tok-number">0x34</span>,       <span class="tok-number">0x37</span>,       <span class="tok-number">0x38</span>,</span>
<span class="line" id="L1191">            <span class="tok-number">0x404001de</span>, <span class="tok-number">0x40400328</span>, <span class="tok-number">0x39</span>,       <span class="tok-number">0x4040002d</span>, <span class="tok-number">0x36</span>,       <span class="tok-number">0x34</span>,       <span class="tok-number">0x30</span>,</span>
<span class="line" id="L1192">            <span class="tok-number">0x37</span>,       <span class="tok-number">0x38</span>,       <span class="tok-number">0x39</span>,       <span class="tok-number">0x35</span>,       <span class="tok-number">0x31</span>,       <span class="tok-number">0x4040008e</span>, <span class="tok-number">0x36</span>,</span>
<span class="line" id="L1193">            <span class="tok-number">0x38</span>,       <span class="tok-number">0x33</span>,       <span class="tok-number">0x4040012f</span>, <span class="tok-number">0x32</span>,       <span class="tok-number">0x35</span>,       <span class="tok-number">0x39</span>,       <span class="tok-number">0x35</span>,</span>
<span class="line" id="L1194">            <span class="tok-number">0x37</span>,       <span class="tok-number">0x30</span>,       <span class="tok-number">0x40400468</span>, <span class="tok-number">0x38</span>,       <span class="tok-number">0x32</span>,       <span class="tok-number">0x32</span>,       <span class="tok-number">0x404002c8</span>,</span>
<span class="line" id="L1195">            <span class="tok-number">0x32</span>,       <span class="tok-number">0x4040061b</span>, <span class="tok-number">0x34</span>,       <span class="tok-number">0x30</span>,       <span class="tok-number">0x37</span>,       <span class="tok-number">0x37</span>,       <span class="tok-number">0x32</span>,</span>
<span class="line" id="L1196">            <span class="tok-number">0x36</span>,       <span class="tok-number">0x37</span>,       <span class="tok-number">0x31</span>,       <span class="tok-number">0x39</span>,       <span class="tok-number">0x34</span>,       <span class="tok-number">0x37</span>,       <span class="tok-number">0x38</span>,</span>
<span class="line" id="L1197">            <span class="tok-number">0x40400319</span>, <span class="tok-number">0x38</span>,       <span class="tok-number">0x32</span>,       <span class="tok-number">0x36</span>,       <span class="tok-number">0x30</span>,       <span class="tok-number">0x31</span>,       <span class="tok-number">0x34</span>,</span>
<span class="line" id="L1198">            <span class="tok-number">0x37</span>,       <span class="tok-number">0x36</span>,       <span class="tok-number">0x39</span>,       <span class="tok-number">0x39</span>,       <span class="tok-number">0x30</span>,       <span class="tok-number">0x39</span>,       <span class="tok-number">0x404004e8</span>,</span>
<span class="line" id="L1199">            <span class="tok-number">0x30</span>,       <span class="tok-number">0x31</span>,       <span class="tok-number">0x33</span>,       <span class="tok-number">0x36</span>,       <span class="tok-number">0x33</span>,       <span class="tok-number">0x39</span>,       <span class="tok-number">0x34</span>,</span>
<span class="line" id="L1200">            <span class="tok-number">0x34</span>,       <span class="tok-number">0x33</span>,       <span class="tok-number">0x4040027f</span>, <span class="tok-number">0x33</span>,       <span class="tok-number">0x30</span>,       <span class="tok-number">0x40400105</span>, <span class="tok-number">0x32</span>,</span>
<span class="line" id="L1201">            <span class="tok-number">0x30</span>,       <span class="tok-number">0x33</span>,       <span class="tok-number">0x34</span>,       <span class="tok-number">0x39</span>,       <span class="tok-number">0x36</span>,       <span class="tok-number">0x32</span>,       <span class="tok-number">0x35</span>,</span>
<span class="line" id="L1202">            <span class="tok-number">0x32</span>,       <span class="tok-number">0x34</span>,       <span class="tok-number">0x35</span>,       <span class="tok-number">0x31</span>,       <span class="tok-number">0x37</span>,       <span class="tok-number">0x404003b5</span>, <span class="tok-number">0x39</span>,</span>
<span class="line" id="L1203">            <span class="tok-number">0x36</span>,       <span class="tok-number">0x35</span>,       <span class="tok-number">0x31</span>,       <span class="tok-number">0x34</span>,       <span class="tok-number">0x33</span>,       <span class="tok-number">0x31</span>,       <span class="tok-number">0x34</span>,</span>
<span class="line" id="L1204">            <span class="tok-number">0x32</span>,       <span class="tok-number">0x39</span>,       <span class="tok-number">0x38</span>,       <span class="tok-number">0x30</span>,       <span class="tok-number">0x39</span>,       <span class="tok-number">0x31</span>,       <span class="tok-number">0x39</span>,</span>
<span class="line" id="L1205">            <span class="tok-number">0x30</span>,       <span class="tok-number">0x36</span>,       <span class="tok-number">0x35</span>,       <span class="tok-number">0x39</span>,       <span class="tok-number">0x32</span>,       <span class="tok-number">0x40400282</span>, <span class="tok-number">0x37</span>,</span>
<span class="line" id="L1206">            <span class="tok-number">0x32</span>,       <span class="tok-number">0x32</span>,       <span class="tok-number">0x31</span>,       <span class="tok-number">0x36</span>,       <span class="tok-number">0x39</span>,       <span class="tok-number">0x36</span>,       <span class="tok-number">0x34</span>,</span>
<span class="line" id="L1207">            <span class="tok-number">0x36</span>,       <span class="tok-number">0x40400419</span>, <span class="tok-number">0x4040007a</span>, <span class="tok-number">0x35</span>,       <span class="tok-number">0x4040050e</span>, <span class="tok-number">0x34</span>,       <span class="tok-number">0x40800565</span>,</span>
<span class="line" id="L1208">            <span class="tok-number">0x38</span>,       <span class="tok-number">0x40400559</span>, <span class="tok-number">0x39</span>,       <span class="tok-number">0x37</span>,       <span class="tok-number">0x4040057b</span>, <span class="tok-number">0x35</span>,       <span class="tok-number">0x34</span>,</span>
<span class="line" id="L1209">            <span class="tok-number">0x4040049d</span>, <span class="tok-number">0x4040023e</span>, <span class="tok-number">0x37</span>,       <span class="tok-number">0x4040065a</span>, <span class="tok-number">0x38</span>,       <span class="tok-number">0x34</span>,       <span class="tok-number">0x36</span>,</span>
<span class="line" id="L1210">            <span class="tok-number">0x38</span>,       <span class="tok-number">0x31</span>,       <span class="tok-number">0x33</span>,       <span class="tok-number">0x4040008c</span>, <span class="tok-number">0x36</span>,       <span class="tok-number">0x38</span>,       <span class="tok-number">0x33</span>,</span>
<span class="line" id="L1211">            <span class="tok-number">0x38</span>,       <span class="tok-number">0x36</span>,       <span class="tok-number">0x38</span>,       <span class="tok-number">0x39</span>,       <span class="tok-number">0x34</span>,       <span class="tok-number">0x32</span>,       <span class="tok-number">0x37</span>,</span>
<span class="line" id="L1212">            <span class="tok-number">0x37</span>,       <span class="tok-number">0x34</span>,       <span class="tok-number">0x31</span>,       <span class="tok-number">0x35</span>,       <span class="tok-number">0x35</span>,       <span class="tok-number">0x39</span>,       <span class="tok-number">0x39</span>,</span>
<span class="line" id="L1213">            <span class="tok-number">0x31</span>,       <span class="tok-number">0x38</span>,       <span class="tok-number">0x35</span>,       <span class="tok-number">0x4040005a</span>, <span class="tok-number">0x32</span>,       <span class="tok-number">0x34</span>,       <span class="tok-number">0x35</span>,</span>
<span class="line" id="L1214">            <span class="tok-number">0x39</span>,       <span class="tok-number">0x35</span>,       <span class="tok-number">0x33</span>,       <span class="tok-number">0x39</span>,       <span class="tok-number">0x35</span>,       <span class="tok-number">0x39</span>,       <span class="tok-number">0x34</span>,</span>
<span class="line" id="L1215">            <span class="tok-number">0x33</span>,       <span class="tok-number">0x31</span>,       <span class="tok-number">0x404005b7</span>, <span class="tok-number">0x37</span>,       <span class="tok-number">0x40400012</span>, <span class="tok-number">0x36</span>,       <span class="tok-number">0x38</span>,</span>
<span class="line" id="L1216">            <span class="tok-number">0x30</span>,       <span class="tok-number">0x38</span>,       <span class="tok-number">0x34</span>,       <span class="tok-number">0x35</span>,       <span class="tok-number">0x404002e7</span>, <span class="tok-number">0x37</span>,       <span class="tok-number">0x33</span>,</span>
<span class="line" id="L1217">            <span class="tok-number">0x4040081e</span>, <span class="tok-number">0x39</span>,       <span class="tok-number">0x35</span>,       <span class="tok-number">0x38</span>,       <span class="tok-number">0x34</span>,       <span class="tok-number">0x38</span>,       <span class="tok-number">0x36</span>,</span>
<span class="line" id="L1218">            <span class="tok-number">0x35</span>,       <span class="tok-number">0x33</span>,       <span class="tok-number">0x38</span>,       <span class="tok-number">0x404006e8</span>, <span class="tok-number">0x36</span>,       <span class="tok-number">0x32</span>,       <span class="tok-number">0x404000f2</span>,</span>
<span class="line" id="L1219">            <span class="tok-number">0x36</span>,       <span class="tok-number">0x30</span>,       <span class="tok-number">0x39</span>,       <span class="tok-number">0x404004b6</span>, <span class="tok-number">0x36</span>,       <span class="tok-number">0x30</span>,       <span class="tok-number">0x38</span>,</span>
<span class="line" id="L1220">            <span class="tok-number">0x30</span>,       <span class="tok-number">0x35</span>,       <span class="tok-number">0x31</span>,       <span class="tok-number">0x32</span>,       <span class="tok-number">0x34</span>,       <span class="tok-number">0x33</span>,       <span class="tok-number">0x38</span>,</span>
<span class="line" id="L1221">            <span class="tok-number">0x38</span>,       <span class="tok-number">0x34</span>,       <span class="tok-number">0x4040013a</span>, <span class="tok-number">0x4040000b</span>, <span class="tok-number">0x34</span>,       <span class="tok-number">0x31</span>,       <span class="tok-number">0x33</span>,</span>
<span class="line" id="L1222">            <span class="tok-number">0x4040030f</span>, <span class="tok-number">0x37</span>,       <span class="tok-number">0x36</span>,       <span class="tok-number">0x32</span>,       <span class="tok-number">0x37</span>,       <span class="tok-number">0x38</span>,       <span class="tok-number">0x40400341</span>,</span>
<span class="line" id="L1223">            <span class="tok-number">0x37</span>,       <span class="tok-number">0x31</span>,       <span class="tok-number">0x35</span>,       <span class="tok-number">0x4040059b</span>, <span class="tok-number">0x33</span>,       <span class="tok-number">0x35</span>,       <span class="tok-number">0x39</span>,</span>
<span class="line" id="L1224">            <span class="tok-number">0x39</span>,       <span class="tok-number">0x37</span>,       <span class="tok-number">0x37</span>,       <span class="tok-number">0x30</span>,       <span class="tok-number">0x30</span>,       <span class="tok-number">0x31</span>,       <span class="tok-number">0x32</span>,</span>
<span class="line" id="L1225">            <span class="tok-number">0x39</span>,       <span class="tok-number">0x40400472</span>, <span class="tok-number">0x38</span>,       <span class="tok-number">0x39</span>,       <span class="tok-number">0x34</span>,       <span class="tok-number">0x34</span>,       <span class="tok-number">0x31</span>,</span>
<span class="line" id="L1226">            <span class="tok-number">0x40400277</span>, <span class="tok-number">0x36</span>,       <span class="tok-number">0x38</span>,       <span class="tok-number">0x35</span>,       <span class="tok-number">0x35</span>,       <span class="tok-number">0x4040005f</span>, <span class="tok-number">0x34</span>,</span>
<span class="line" id="L1227">            <span class="tok-number">0x30</span>,       <span class="tok-number">0x36</span>,       <span class="tok-number">0x33</span>,       <span class="tok-number">0x404008e6</span>, <span class="tok-number">0x32</span>,       <span class="tok-number">0x30</span>,       <span class="tok-number">0x37</span>,</span>
<span class="line" id="L1228">            <span class="tok-number">0x32</span>,       <span class="tok-number">0x32</span>,       <span class="tok-number">0x40400158</span>, <span class="tok-number">0x40800203</span>, <span class="tok-number">0x34</span>,       <span class="tok-number">0x38</span>,       <span class="tok-number">0x31</span>,</span>
<span class="line" id="L1229">            <span class="tok-number">0x35</span>,       <span class="tok-number">0x38</span>,       <span class="tok-number">0x40400205</span>, <span class="tok-number">0x404001fe</span>, <span class="tok-number">0x4040027a</span>, <span class="tok-number">0x40400298</span>, <span class="tok-number">0x33</span>,</span>
<span class="line" id="L1230">            <span class="tok-number">0x39</span>,       <span class="tok-number">0x34</span>,       <span class="tok-number">0x35</span>,       <span class="tok-number">0x32</span>,       <span class="tok-number">0x32</span>,       <span class="tok-number">0x36</span>,       <span class="tok-number">0x37</span>,</span>
<span class="line" id="L1231">            <span class="tok-number">0x40c00496</span>, <span class="tok-number">0x38</span>,       <span class="tok-number">0x4040058a</span>, <span class="tok-number">0x32</span>,       <span class="tok-number">0x31</span>,       <span class="tok-number">0x404002ea</span>, <span class="tok-number">0x32</span>,</span>
<span class="line" id="L1232">            <span class="tok-number">0x40400387</span>, <span class="tok-number">0x35</span>,       <span class="tok-number">0x34</span>,       <span class="tok-number">0x36</span>,       <span class="tok-number">0x36</span>,       <span class="tok-number">0x36</span>,       <span class="tok-number">0x4040051b</span>,</span>
<span class="line" id="L1233">            <span class="tok-number">0x32</span>,       <span class="tok-number">0x33</span>,       <span class="tok-number">0x39</span>,       <span class="tok-number">0x38</span>,       <span class="tok-number">0x36</span>,       <span class="tok-number">0x34</span>,       <span class="tok-number">0x35</span>,</span>
<span class="line" id="L1234">            <span class="tok-number">0x36</span>,       <span class="tok-number">0x404004c4</span>, <span class="tok-number">0x31</span>,       <span class="tok-number">0x36</span>,       <span class="tok-number">0x33</span>,       <span class="tok-number">0x35</span>,       <span class="tok-number">0x40800253</span>,</span>
<span class="line" id="L1235">            <span class="tok-number">0x40400811</span>, <span class="tok-number">0x37</span>,       <span class="tok-number">0x404008ad</span>, <span class="tok-number">0x39</span>,       <span class="tok-number">0x38</span>,       <span class="tok-number">0x4040045e</span>, <span class="tok-number">0x39</span>,</span>
<span class="line" id="L1236">            <span class="tok-number">0x33</span>,       <span class="tok-number">0x36</span>,       <span class="tok-number">0x33</span>,       <span class="tok-number">0x34</span>,       <span class="tok-number">0x4040075b</span>, <span class="tok-number">0x37</span>,       <span class="tok-number">0x34</span>,</span>
<span class="line" id="L1237">            <span class="tok-number">0x33</span>,       <span class="tok-number">0x32</span>,       <span class="tok-number">0x34</span>,       <span class="tok-number">0x4040047b</span>, <span class="tok-number">0x31</span>,       <span class="tok-number">0x35</span>,       <span class="tok-number">0x30</span>,</span>
<span class="line" id="L1238">            <span class="tok-number">0x37</span>,       <span class="tok-number">0x36</span>,       <span class="tok-number">0x404004bb</span>, <span class="tok-number">0x37</span>,       <span class="tok-number">0x39</span>,       <span class="tok-number">0x34</span>,       <span class="tok-number">0x35</span>,</span>
<span class="line" id="L1239">            <span class="tok-number">0x31</span>,       <span class="tok-number">0x30</span>,       <span class="tok-number">0x39</span>,       <span class="tok-number">0x4040003e</span>, <span class="tok-number">0x30</span>,       <span class="tok-number">0x39</span>,       <span class="tok-number">0x34</span>,</span>
<span class="line" id="L1240">            <span class="tok-number">0x30</span>,       <span class="tok-number">0x404006a6</span>, <span class="tok-number">0x38</span>,       <span class="tok-number">0x38</span>,       <span class="tok-number">0x37</span>,       <span class="tok-number">0x39</span>,       <span class="tok-number">0x37</span>,</span>
<span class="line" id="L1241">            <span class="tok-number">0x31</span>,       <span class="tok-number">0x30</span>,       <span class="tok-number">0x38</span>,       <span class="tok-number">0x39</span>,       <span class="tok-number">0x33</span>,       <span class="tok-number">0x404008f0</span>, <span class="tok-number">0x36</span>,</span>
<span class="line" id="L1242">            <span class="tok-number">0x39</span>,       <span class="tok-number">0x31</span>,       <span class="tok-number">0x33</span>,       <span class="tok-number">0x36</span>,       <span class="tok-number">0x38</span>,       <span class="tok-number">0x36</span>,       <span class="tok-number">0x37</span>,</span>
<span class="line" id="L1243">            <span class="tok-number">0x32</span>,       <span class="tok-number">0x4040025b</span>, <span class="tok-number">0x404001fe</span>, <span class="tok-number">0x35</span>,       <span class="tok-number">0x4040053f</span>, <span class="tok-number">0x40400468</span>, <span class="tok-number">0x40400801</span>,</span>
<span class="line" id="L1244">            <span class="tok-number">0x31</span>,       <span class="tok-number">0x37</span>,       <span class="tok-number">0x39</span>,       <span class="tok-number">0x32</span>,       <span class="tok-number">0x38</span>,       <span class="tok-number">0x36</span>,       <span class="tok-number">0x38</span>,</span>
<span class="line" id="L1245">            <span class="tok-number">0x404008cc</span>, <span class="tok-number">0x38</span>,       <span class="tok-number">0x37</span>,       <span class="tok-number">0x34</span>,       <span class="tok-number">0x37</span>,       <span class="tok-number">0x4080079e</span>, <span class="tok-number">0x38</span>,</span>
<span class="line" id="L1246">            <span class="tok-number">0x32</span>,       <span class="tok-number">0x34</span>,       <span class="tok-number">0x4040097a</span>, <span class="tok-number">0x38</span>,       <span class="tok-number">0x4040025b</span>, <span class="tok-number">0x37</span>,       <span class="tok-number">0x31</span>,</span>
<span class="line" id="L1247">            <span class="tok-number">0x34</span>,       <span class="tok-number">0x39</span>,       <span class="tok-number">0x30</span>,       <span class="tok-number">0x39</span>,       <span class="tok-number">0x36</span>,       <span class="tok-number">0x37</span>,       <span class="tok-number">0x35</span>,</span>
<span class="line" id="L1248">            <span class="tok-number">0x39</span>,       <span class="tok-number">0x38</span>,       <span class="tok-number">0x404006ef</span>, <span class="tok-number">0x33</span>,       <span class="tok-number">0x36</span>,       <span class="tok-number">0x35</span>,       <span class="tok-number">0x40400134</span>,</span>
<span class="line" id="L1249">            <span class="tok-number">0x38</span>,       <span class="tok-number">0x31</span>,       <span class="tok-number">0x4040005c</span>, <span class="tok-number">0x40400745</span>, <span class="tok-number">0x40400936</span>, <span class="tok-number">0x36</span>,       <span class="tok-number">0x38</span>,</span>
<span class="line" id="L1250">            <span class="tok-number">0x32</span>,       <span class="tok-number">0x39</span>,       <span class="tok-number">0x4040057e</span>, <span class="tok-number">0x38</span>,       <span class="tok-number">0x37</span>,       <span class="tok-number">0x32</span>,       <span class="tok-number">0x32</span>,</span>
<span class="line" id="L1251">            <span class="tok-number">0x36</span>,       <span class="tok-number">0x35</span>,       <span class="tok-number">0x38</span>,       <span class="tok-number">0x38</span>,       <span class="tok-number">0x30</span>,       <span class="tok-number">0x40400611</span>, <span class="tok-number">0x35</span>,</span>
<span class="line" id="L1252">            <span class="tok-number">0x40400249</span>, <span class="tok-number">0x34</span>,       <span class="tok-number">0x32</span>,       <span class="tok-number">0x37</span>,       <span class="tok-number">0x30</span>,       <span class="tok-number">0x34</span>,       <span class="tok-number">0x37</span>,</span>
<span class="line" id="L1253">            <span class="tok-number">0x37</span>,       <span class="tok-number">0x35</span>,       <span class="tok-number">0x35</span>,       <span class="tok-number">0x4040081e</span>, <span class="tok-number">0x33</span>,       <span class="tok-number">0x37</span>,       <span class="tok-number">0x39</span>,</span>
<span class="line" id="L1254">            <span class="tok-number">0x36</span>,       <span class="tok-number">0x34</span>,       <span class="tok-number">0x31</span>,       <span class="tok-number">0x34</span>,       <span class="tok-number">0x35</span>,       <span class="tok-number">0x31</span>,       <span class="tok-number">0x35</span>,</span>
<span class="line" id="L1255">            <span class="tok-number">0x32</span>,       <span class="tok-number">0x404005fd</span>, <span class="tok-number">0x32</span>,       <span class="tok-number">0x33</span>,       <span class="tok-number">0x34</span>,       <span class="tok-number">0x33</span>,       <span class="tok-number">0x36</span>,</span>
<span class="line" id="L1256">            <span class="tok-number">0x34</span>,       <span class="tok-number">0x35</span>,       <span class="tok-number">0x34</span>,       <span class="tok-number">0x404005de</span>, <span class="tok-number">0x34</span>,       <span class="tok-number">0x34</span>,       <span class="tok-number">0x34</span>,</span>
<span class="line" id="L1257">            <span class="tok-number">0x37</span>,       <span class="tok-number">0x39</span>,       <span class="tok-number">0x35</span>,       <span class="tok-number">0x4040003c</span>, <span class="tok-number">0x40400523</span>, <span class="tok-number">0x408008e6</span>, <span class="tok-number">0x34</span>,</span>
<span class="line" id="L1258">            <span class="tok-number">0x31</span>,       <span class="tok-number">0x4040052a</span>, <span class="tok-number">0x33</span>,       <span class="tok-number">0x40400304</span>, <span class="tok-number">0x35</span>,       <span class="tok-number">0x32</span>,       <span class="tok-number">0x33</span>,</span>
<span class="line" id="L1259">            <span class="tok-number">0x31</span>,       <span class="tok-number">0x40800841</span>, <span class="tok-number">0x31</span>,       <span class="tok-number">0x36</span>,       <span class="tok-number">0x36</span>,       <span class="tok-number">0x31</span>,       <span class="tok-number">0x404008b2</span>,</span>
<span class="line" id="L1260">            <span class="tok-number">0x35</span>,       <span class="tok-number">0x39</span>,       <span class="tok-number">0x36</span>,       <span class="tok-number">0x39</span>,       <span class="tok-number">0x35</span>,       <span class="tok-number">0x33</span>,       <span class="tok-number">0x36</span>,</span>
<span class="line" id="L1261">            <span class="tok-number">0x32</span>,       <span class="tok-number">0x33</span>,       <span class="tok-number">0x31</span>,       <span class="tok-number">0x34</span>,       <span class="tok-number">0x404005ff</span>, <span class="tok-number">0x32</span>,       <span class="tok-number">0x34</span>,</span>
<span class="line" id="L1262">            <span class="tok-number">0x38</span>,       <span class="tok-number">0x34</span>,       <span class="tok-number">0x39</span>,       <span class="tok-number">0x33</span>,       <span class="tok-number">0x37</span>,       <span class="tok-number">0x31</span>,       <span class="tok-number">0x38</span>,</span>
<span class="line" id="L1263">            <span class="tok-number">0x37</span>,       <span class="tok-number">0x31</span>,       <span class="tok-number">0x31</span>,       <span class="tok-number">0x30</span>,       <span class="tok-number">0x31</span>,       <span class="tok-number">0x34</span>,       <span class="tok-number">0x35</span>,</span>
<span class="line" id="L1264">            <span class="tok-number">0x37</span>,       <span class="tok-number">0x36</span>,       <span class="tok-number">0x35</span>,       <span class="tok-number">0x34</span>,       <span class="tok-number">0x40400761</span>, <span class="tok-number">0x30</span>,       <span class="tok-number">0x32</span>,</span>
<span class="line" id="L1265">            <span class="tok-number">0x37</span>,       <span class="tok-number">0x39</span>,       <span class="tok-number">0x39</span>,       <span class="tok-number">0x33</span>,       <span class="tok-number">0x34</span>,       <span class="tok-number">0x34</span>,       <span class="tok-number">0x30</span>,</span>
<span class="line" id="L1266">            <span class="tok-number">0x33</span>,       <span class="tok-number">0x37</span>,       <span class="tok-number">0x34</span>,       <span class="tok-number">0x32</span>,       <span class="tok-number">0x30</span>,       <span class="tok-number">0x30</span>,       <span class="tok-number">0x37</span>,</span>
<span class="line" id="L1267">            <span class="tok-number">0x4040093f</span>, <span class="tok-number">0x37</span>,       <span class="tok-number">0x38</span>,       <span class="tok-number">0x35</span>,       <span class="tok-number">0x33</span>,       <span class="tok-number">0x39</span>,       <span class="tok-number">0x30</span>,</span>
<span class="line" id="L1268">            <span class="tok-number">0x36</span>,       <span class="tok-number">0x32</span>,       <span class="tok-number">0x31</span>,       <span class="tok-number">0x39</span>,       <span class="tok-number">0x40800299</span>, <span class="tok-number">0x40400345</span>, <span class="tok-number">0x38</span>,</span>
<span class="line" id="L1269">            <span class="tok-number">0x34</span>,       <span class="tok-number">0x37</span>,       <span class="tok-number">0x408003d2</span>, <span class="tok-number">0x38</span>,       <span class="tok-number">0x33</span>,       <span class="tok-number">0x33</span>,       <span class="tok-number">0x32</span>,</span>
<span class="line" id="L1270">            <span class="tok-number">0x31</span>,       <span class="tok-number">0x34</span>,       <span class="tok-number">0x34</span>,       <span class="tok-number">0x35</span>,       <span class="tok-number">0x37</span>,       <span class="tok-number">0x31</span>,       <span class="tok-number">0x40400284</span>,</span>
<span class="line" id="L1271">            <span class="tok-number">0x40400776</span>, <span class="tok-number">0x34</span>,       <span class="tok-number">0x33</span>,       <span class="tok-number">0x35</span>,       <span class="tok-number">0x30</span>,       <span class="tok-number">0x40400928</span>, <span class="tok-number">0x40400468</span>,</span>
<span class="line" id="L1272">            <span class="tok-number">0x35</span>,       <span class="tok-number">0x33</span>,       <span class="tok-number">0x31</span>,       <span class="tok-number">0x39</span>,       <span class="tok-number">0x31</span>,       <span class="tok-number">0x30</span>,       <span class="tok-number">0x34</span>,</span>
<span class="line" id="L1273">            <span class="tok-number">0x38</span>,       <span class="tok-number">0x34</span>,       <span class="tok-number">0x38</span>,       <span class="tok-number">0x31</span>,       <span class="tok-number">0x30</span>,       <span class="tok-number">0x30</span>,       <span class="tok-number">0x35</span>,</span>
<span class="line" id="L1274">            <span class="tok-number">0x33</span>,       <span class="tok-number">0x37</span>,       <span class="tok-number">0x30</span>,       <span class="tok-number">0x36</span>,       <span class="tok-number">0x404008bc</span>, <span class="tok-number">0x4080059d</span>, <span class="tok-number">0x40800781</span>,</span>
<span class="line" id="L1275">            <span class="tok-number">0x31</span>,       <span class="tok-number">0x40400559</span>, <span class="tok-number">0x37</span>,       <span class="tok-number">0x4040031b</span>, <span class="tok-number">0x35</span>,       <span class="tok-number">0x404007ec</span>, <span class="tok-number">0x4040040c</span>,</span>
<span class="line" id="L1276">            <span class="tok-number">0x36</span>,       <span class="tok-number">0x33</span>,       <span class="tok-number">0x408007dc</span>, <span class="tok-number">0x34</span>,       <span class="tok-number">0x40400971</span>, <span class="tok-number">0x4080034e</span>, <span class="tok-number">0x408003f5</span>,</span>
<span class="line" id="L1277">            <span class="tok-number">0x38</span>,       <span class="tok-number">0x4080052d</span>, <span class="tok-number">0x40800887</span>, <span class="tok-number">0x39</span>,       <span class="tok-number">0x40400187</span>, <span class="tok-number">0x39</span>,       <span class="tok-number">0x31</span>,</span>
<span class="line" id="L1278">            <span class="tok-number">0x404008ce</span>, <span class="tok-number">0x38</span>,       <span class="tok-number">0x31</span>,       <span class="tok-number">0x34</span>,       <span class="tok-number">0x36</span>,       <span class="tok-number">0x37</span>,       <span class="tok-number">0x35</span>,</span>
<span class="line" id="L1279">            <span class="tok-number">0x31</span>,       <span class="tok-number">0x4040062b</span>, <span class="tok-number">0x31</span>,       <span class="tok-number">0x32</span>,       <span class="tok-number">0x33</span>,       <span class="tok-number">0x39</span>,       <span class="tok-number">0x40c001a9</span>,</span>
<span class="line" id="L1280">            <span class="tok-number">0x39</span>,       <span class="tok-number">0x30</span>,       <span class="tok-number">0x37</span>,       <span class="tok-number">0x31</span>,       <span class="tok-number">0x38</span>,       <span class="tok-number">0x36</span>,       <span class="tok-number">0x34</span>,</span>
<span class="line" id="L1281">            <span class="tok-number">0x39</span>,       <span class="tok-number">0x34</span>,       <span class="tok-number">0x32</span>,       <span class="tok-number">0x33</span>,       <span class="tok-number">0x31</span>,       <span class="tok-number">0x39</span>,       <span class="tok-number">0x36</span>,</span>
<span class="line" id="L1282">            <span class="tok-number">0x31</span>,       <span class="tok-number">0x35</span>,       <span class="tok-number">0x36</span>,       <span class="tok-number">0x404001ec</span>, <span class="tok-number">0x404006bc</span>, <span class="tok-number">0x39</span>,       <span class="tok-number">0x35</span>,</span>
<span class="line" id="L1283">            <span class="tok-number">0x40400926</span>, <span class="tok-number">0x40400469</span>, <span class="tok-number">0x4040011b</span>, <span class="tok-number">0x36</span>,       <span class="tok-number">0x30</span>,       <span class="tok-number">0x33</span>,       <span class="tok-number">0x38</span>,</span>
<span class="line" id="L1284">            <span class="tok-number">0x40400a25</span>, <span class="tok-number">0x4040016f</span>, <span class="tok-number">0x40400384</span>, <span class="tok-number">0x36</span>,       <span class="tok-number">0x32</span>,       <span class="tok-number">0x4040045a</span>, <span class="tok-number">0x35</span>,</span>
<span class="line" id="L1285">            <span class="tok-number">0x4040084c</span>, <span class="tok-number">0x36</span>,       <span class="tok-number">0x33</span>,       <span class="tok-number">0x38</span>,       <span class="tok-number">0x39</span>,       <span class="tok-number">0x33</span>,       <span class="tok-number">0x37</span>,</span>
<span class="line" id="L1286">            <span class="tok-number">0x37</span>,       <span class="tok-number">0x38</span>,       <span class="tok-number">0x37</span>,       <span class="tok-number">0x404008c5</span>, <span class="tok-number">0x404000f8</span>, <span class="tok-number">0x39</span>,       <span class="tok-number">0x37</span>,</span>
<span class="line" id="L1287">            <span class="tok-number">0x39</span>,       <span class="tok-number">0x32</span>,       <span class="tok-number">0x30</span>,       <span class="tok-number">0x37</span>,       <span class="tok-number">0x37</span>,       <span class="tok-number">0x33</span>,       <span class="tok-number">0x404005d7</span>,</span>
<span class="line" id="L1288">            <span class="tok-number">0x32</span>,       <span class="tok-number">0x31</span>,       <span class="tok-number">0x38</span>,       <span class="tok-number">0x32</span>,       <span class="tok-number">0x35</span>,       <span class="tok-number">0x36</span>,       <span class="tok-number">0x404007df</span>,</span>
<span class="line" id="L1289">            <span class="tok-number">0x36</span>,       <span class="tok-number">0x36</span>,       <span class="tok-number">0x404006d6</span>, <span class="tok-number">0x34</span>,       <span class="tok-number">0x32</span>,       <span class="tok-number">0x4080067e</span>, <span class="tok-number">0x36</span>,</span>
<span class="line" id="L1290">            <span class="tok-number">0x404006e6</span>, <span class="tok-number">0x34</span>,       <span class="tok-number">0x34</span>,       <span class="tok-number">0x40400024</span>, <span class="tok-number">0x35</span>,       <span class="tok-number">0x34</span>,       <span class="tok-number">0x39</span>,</span>
<span class="line" id="L1291">            <span class="tok-number">0x32</span>,       <span class="tok-number">0x30</span>,       <span class="tok-number">0x32</span>,       <span class="tok-number">0x36</span>,       <span class="tok-number">0x30</span>,       <span class="tok-number">0x35</span>,       <span class="tok-number">0x40400ab3</span>,</span>
<span class="line" id="L1292">            <span class="tok-number">0x408003e4</span>, <span class="tok-number">0x32</span>,       <span class="tok-number">0x30</span>,       <span class="tok-number">0x31</span>,       <span class="tok-number">0x34</span>,       <span class="tok-number">0x39</span>,       <span class="tok-number">0x404004d2</span>,</span>
<span class="line" id="L1293">            <span class="tok-number">0x38</span>,       <span class="tok-number">0x35</span>,       <span class="tok-number">0x30</span>,       <span class="tok-number">0x37</span>,       <span class="tok-number">0x33</span>,       <span class="tok-number">0x40400599</span>, <span class="tok-number">0x36</span>,</span>
<span class="line" id="L1294">            <span class="tok-number">0x36</span>,       <span class="tok-number">0x36</span>,       <span class="tok-number">0x30</span>,       <span class="tok-number">0x40400194</span>, <span class="tok-number">0x32</span>,       <span class="tok-number">0x34</span>,       <span class="tok-number">0x33</span>,</span>
<span class="line" id="L1295">            <span class="tok-number">0x34</span>,       <span class="tok-number">0x30</span>,       <span class="tok-number">0x40400087</span>, <span class="tok-number">0x30</span>,       <span class="tok-number">0x4040076b</span>, <span class="tok-number">0x38</span>,       <span class="tok-number">0x36</span>,</span>
<span class="line" id="L1296">            <span class="tok-number">0x33</span>,       <span class="tok-number">0x40400956</span>, <span class="tok-number">0x404007e4</span>, <span class="tok-number">0x4040042b</span>, <span class="tok-number">0x40400174</span>, <span class="tok-number">0x35</span>,       <span class="tok-number">0x37</span>,</span>
<span class="line" id="L1297">            <span class="tok-number">0x39</span>,       <span class="tok-number">0x36</span>,       <span class="tok-number">0x32</span>,       <span class="tok-number">0x36</span>,       <span class="tok-number">0x38</span>,       <span class="tok-number">0x35</span>,       <span class="tok-number">0x36</span>,</span>
<span class="line" id="L1298">            <span class="tok-number">0x40400140</span>, <span class="tok-number">0x35</span>,       <span class="tok-number">0x30</span>,       <span class="tok-number">0x38</span>,       <span class="tok-number">0x40400523</span>, <span class="tok-number">0x35</span>,       <span class="tok-number">0x38</span>,</span>
<span class="line" id="L1299">            <span class="tok-number">0x37</span>,       <span class="tok-number">0x39</span>,       <span class="tok-number">0x36</span>,       <span class="tok-number">0x39</span>,       <span class="tok-number">0x39</span>,       <span class="tok-number">0x40400711</span>, <span class="tok-number">0x35</span>,</span>
<span class="line" id="L1300">            <span class="tok-number">0x37</span>,       <span class="tok-number">0x34</span>,       <span class="tok-number">0x40400a18</span>, <span class="tok-number">0x38</span>,       <span class="tok-number">0x34</span>,       <span class="tok-number">0x30</span>,       <span class="tok-number">0x404008b3</span>,</span>
<span class="line" id="L1301">            <span class="tok-number">0x31</span>,       <span class="tok-number">0x34</span>,       <span class="tok-number">0x35</span>,       <span class="tok-number">0x39</span>,       <span class="tok-number">0x31</span>,       <span class="tok-number">0x4040078c</span>, <span class="tok-number">0x37</span>,</span>
<span class="line" id="L1302">            <span class="tok-number">0x30</span>,       <span class="tok-number">0x40400234</span>, <span class="tok-number">0x30</span>,       <span class="tok-number">0x31</span>,       <span class="tok-number">0x40400be7</span>, <span class="tok-number">0x31</span>,       <span class="tok-number">0x32</span>,</span>
<span class="line" id="L1303">            <span class="tok-number">0x40400c74</span>, <span class="tok-number">0x30</span>,       <span class="tok-number">0x404003c3</span>, <span class="tok-number">0x33</span>,       <span class="tok-number">0x39</span>,       <span class="tok-number">0x40400b2a</span>, <span class="tok-number">0x40400112</span>,</span>
<span class="line" id="L1304">            <span class="tok-number">0x37</span>,       <span class="tok-number">0x31</span>,       <span class="tok-number">0x35</span>,       <span class="tok-number">0x404003b0</span>, <span class="tok-number">0x34</span>,       <span class="tok-number">0x32</span>,       <span class="tok-number">0x30</span>,</span>
<span class="line" id="L1305">            <span class="tok-number">0x40800bf2</span>, <span class="tok-number">0x39</span>,       <span class="tok-number">0x40400bc2</span>, <span class="tok-number">0x30</span>,       <span class="tok-number">0x37</span>,       <span class="tok-number">0x40400341</span>, <span class="tok-number">0x40400795</span>,</span>
<span class="line" id="L1306">            <span class="tok-number">0x40400aaf</span>, <span class="tok-number">0x40400c62</span>, <span class="tok-number">0x32</span>,       <span class="tok-number">0x31</span>,       <span class="tok-number">0x40400960</span>, <span class="tok-number">0x32</span>,       <span class="tok-number">0x35</span>,</span>
<span class="line" id="L1307">            <span class="tok-number">0x31</span>,       <span class="tok-number">0x4040057b</span>, <span class="tok-number">0x40400944</span>, <span class="tok-number">0x39</span>,       <span class="tok-number">0x32</span>,       <span class="tok-number">0x404001b2</span>, <span class="tok-number">0x38</span>,</span>
<span class="line" id="L1308">            <span class="tok-number">0x32</span>,       <span class="tok-number">0x36</span>,       <span class="tok-number">0x40400b66</span>, <span class="tok-number">0x32</span>,       <span class="tok-number">0x40400278</span>, <span class="tok-number">0x33</span>,       <span class="tok-number">0x32</span>,</span>
<span class="line" id="L1309">            <span class="tok-number">0x31</span>,       <span class="tok-number">0x35</span>,       <span class="tok-number">0x37</span>,       <span class="tok-number">0x39</span>,       <span class="tok-number">0x31</span>,       <span class="tok-number">0x39</span>,       <span class="tok-number">0x38</span>,</span>
<span class="line" id="L1310">            <span class="tok-number">0x34</span>,       <span class="tok-number">0x31</span>,       <span class="tok-number">0x34</span>,       <span class="tok-number">0x4080087b</span>, <span class="tok-number">0x39</span>,       <span class="tok-number">0x31</span>,       <span class="tok-number">0x36</span>,</span>
<span class="line" id="L1311">            <span class="tok-number">0x34</span>,       <span class="tok-number">0x408006e8</span>, <span class="tok-number">0x39</span>,       <span class="tok-number">0x40800b58</span>, <span class="tok-number">0x404008db</span>, <span class="tok-number">0x37</span>,       <span class="tok-number">0x32</span>,</span>
<span class="line" id="L1312">            <span class="tok-number">0x32</span>,       <span class="tok-number">0x40400321</span>, <span class="tok-number">0x35</span>,       <span class="tok-number">0x404008a4</span>, <span class="tok-number">0x40400141</span>, <span class="tok-number">0x39</span>,       <span class="tok-number">0x31</span>,</span>
<span class="line" id="L1313">            <span class="tok-number">0x30</span>,       <span class="tok-number">0x404000bc</span>, <span class="tok-number">0x40400c5b</span>, <span class="tok-number">0x35</span>,       <span class="tok-number">0x32</span>,       <span class="tok-number">0x38</span>,       <span class="tok-number">0x30</span>,</span>
<span class="line" id="L1314">            <span class="tok-number">0x31</span>,       <span class="tok-number">0x37</span>,       <span class="tok-number">0x40400231</span>, <span class="tok-number">0x37</span>,       <span class="tok-number">0x31</span>,       <span class="tok-number">0x32</span>,       <span class="tok-number">0x40400914</span>,</span>
<span class="line" id="L1315">            <span class="tok-number">0x38</span>,       <span class="tok-number">0x33</span>,       <span class="tok-number">0x32</span>,       <span class="tok-number">0x40400373</span>, <span class="tok-number">0x31</span>,       <span class="tok-number">0x40400589</span>, <span class="tok-number">0x30</span>,</span>
<span class="line" id="L1316">            <span class="tok-number">0x39</span>,       <span class="tok-number">0x33</span>,       <span class="tok-number">0x35</span>,       <span class="tok-number">0x33</span>,       <span class="tok-number">0x39</span>,       <span class="tok-number">0x36</span>,       <span class="tok-number">0x35</span>,</span>
<span class="line" id="L1317">            <span class="tok-number">0x37</span>,       <span class="tok-number">0x4040064b</span>, <span class="tok-number">0x31</span>,       <span class="tok-number">0x30</span>,       <span class="tok-number">0x38</span>,       <span class="tok-number">0x33</span>,       <span class="tok-number">0x40400069</span>,</span>
<span class="line" id="L1318">            <span class="tok-number">0x35</span>,       <span class="tok-number">0x31</span>,       <span class="tok-number">0x4040077a</span>, <span class="tok-number">0x40400d5a</span>, <span class="tok-number">0x31</span>,       <span class="tok-number">0x34</span>,       <span class="tok-number">0x34</span>,</span>
<span class="line" id="L1319">            <span class="tok-number">0x34</span>,       <span class="tok-number">0x32</span>,       <span class="tok-number">0x31</span>,       <span class="tok-number">0x30</span>,       <span class="tok-number">0x30</span>,       <span class="tok-number">0x40400202</span>, <span class="tok-number">0x30</span>,</span>
<span class="line" id="L1320">            <span class="tok-number">0x33</span>,       <span class="tok-number">0x4040019c</span>, <span class="tok-number">0x31</span>,       <span class="tok-number">0x31</span>,       <span class="tok-number">0x30</span>,       <span class="tok-number">0x33</span>,       <span class="tok-number">0x40400c81</span>,</span>
<span class="line" id="L1321">            <span class="tok-number">0x40400009</span>, <span class="tok-number">0x40400026</span>, <span class="tok-number">0x40c00602</span>, <span class="tok-number">0x35</span>,       <span class="tok-number">0x31</span>,       <span class="tok-number">0x36</span>,       <span class="tok-number">0x404005d9</span>,</span>
<span class="line" id="L1322">            <span class="tok-number">0x40800883</span>, <span class="tok-number">0x4040092a</span>, <span class="tok-number">0x35</span>,       <span class="tok-number">0x40800c42</span>, <span class="tok-number">0x38</span>,       <span class="tok-number">0x35</span>,       <span class="tok-number">0x31</span>,</span>
<span class="line" id="L1323">            <span class="tok-number">0x37</span>,       <span class="tok-number">0x31</span>,       <span class="tok-number">0x34</span>,       <span class="tok-number">0x33</span>,       <span class="tok-number">0x37</span>,       <span class="tok-number">0x40400605</span>, <span class="tok-number">0x4040006d</span>,</span>
<span class="line" id="L1324">            <span class="tok-number">0x31</span>,       <span class="tok-number">0x35</span>,       <span class="tok-number">0x35</span>,       <span class="tok-number">0x36</span>,       <span class="tok-number">0x35</span>,       <span class="tok-number">0x30</span>,       <span class="tok-number">0x38</span>,</span>
<span class="line" id="L1325">            <span class="tok-number">0x38</span>,       <span class="tok-number">0x404003b9</span>, <span class="tok-number">0x39</span>,       <span class="tok-number">0x38</span>,       <span class="tok-number">0x39</span>,       <span class="tok-number">0x38</span>,       <span class="tok-number">0x35</span>,</span>
<span class="line" id="L1326">            <span class="tok-number">0x39</span>,       <span class="tok-number">0x39</span>,       <span class="tok-number">0x38</span>,       <span class="tok-number">0x32</span>,       <span class="tok-number">0x33</span>,       <span class="tok-number">0x38</span>,       <span class="tok-number">0x404001cf</span>,</span>
<span class="line" id="L1327">            <span class="tok-number">0x404009ba</span>, <span class="tok-number">0x33</span>,       <span class="tok-number">0x4040016c</span>, <span class="tok-number">0x4040043e</span>, <span class="tok-number">0x404009c3</span>, <span class="tok-number">0x38</span>,       <span class="tok-number">0x40800e05</span>,</span>
<span class="line" id="L1328">            <span class="tok-number">0x33</span>,       <span class="tok-number">0x32</span>,       <span class="tok-number">0x40400107</span>, <span class="tok-number">0x35</span>,       <span class="tok-number">0x40400305</span>, <span class="tok-number">0x33</span>,       <span class="tok-number">0x404001ca</span>,</span>
<span class="line" id="L1329">            <span class="tok-number">0x39</span>,       <span class="tok-number">0x4040041b</span>, <span class="tok-number">0x39</span>,       <span class="tok-number">0x38</span>,       <span class="tok-number">0x4040087d</span>, <span class="tok-number">0x34</span>,       <span class="tok-number">0x40400cb8</span>,</span>
<span class="line" id="L1330">            <span class="tok-number">0x37</span>,       <span class="tok-number">0x4040064b</span>, <span class="tok-number">0x30</span>,       <span class="tok-number">0x37</span>,       <span class="tok-number">0x404000e5</span>, <span class="tok-number">0x34</span>,       <span class="tok-number">0x38</span>,</span>
<span class="line" id="L1331">            <span class="tok-number">0x31</span>,       <span class="tok-number">0x34</span>,       <span class="tok-number">0x31</span>,       <span class="tok-number">0x40400539</span>, <span class="tok-number">0x38</span>,       <span class="tok-number">0x35</span>,       <span class="tok-number">0x39</span>,</span>
<span class="line" id="L1332">            <span class="tok-number">0x34</span>,       <span class="tok-number">0x36</span>,       <span class="tok-number">0x31</span>,       <span class="tok-number">0x40400bc9</span>, <span class="tok-number">0x38</span>,       <span class="tok-number">0x30</span>,</span>
<span class="line" id="L1333">        },</span>
<span class="line" id="L1334">    },</span>
<span class="line" id="L1335">    HuffTest{</span>
<span class="line" id="L1336">        .input = <span class="tok-str">&quot;huffman-rand-1k.input&quot;</span>,</span>
<span class="line" id="L1337">        .want = <span class="tok-str">&quot;huffman-rand-1k.{s}.expect&quot;</span>,</span>
<span class="line" id="L1338">        .want_no_input = <span class="tok-str">&quot;huffman-rand-1k.{s}.expect-noinput&quot;</span>,</span>
<span class="line" id="L1339">        .tokens = &amp;[_]token.Token{</span>
<span class="line" id="L1340">            <span class="tok-number">0xf8</span>, <span class="tok-number">0x8b</span>, <span class="tok-number">0x96</span>, <span class="tok-number">0x76</span>, <span class="tok-number">0x48</span>, <span class="tok-number">0xd</span>,  <span class="tok-number">0x85</span>, <span class="tok-number">0x94</span>, <span class="tok-number">0x25</span>, <span class="tok-number">0x80</span>, <span class="tok-number">0xaf</span>, <span class="tok-number">0xc2</span>, <span class="tok-number">0xfe</span>, <span class="tok-number">0x8d</span>,</span>
<span class="line" id="L1341">            <span class="tok-number">0xe8</span>, <span class="tok-number">0x20</span>, <span class="tok-number">0xeb</span>, <span class="tok-number">0x17</span>, <span class="tok-number">0x86</span>, <span class="tok-number">0xc9</span>, <span class="tok-number">0xb7</span>, <span class="tok-number">0xc5</span>, <span class="tok-number">0xde</span>, <span class="tok-number">0x6</span>,  <span class="tok-number">0xea</span>, <span class="tok-number">0x7d</span>, <span class="tok-number">0x18</span>, <span class="tok-number">0x8b</span>,</span>
<span class="line" id="L1342">            <span class="tok-number">0xe7</span>, <span class="tok-number">0x3e</span>, <span class="tok-number">0x7</span>,  <span class="tok-number">0xda</span>, <span class="tok-number">0xdf</span>, <span class="tok-number">0xff</span>, <span class="tok-number">0x6c</span>, <span class="tok-number">0x73</span>, <span class="tok-number">0xde</span>, <span class="tok-number">0xcc</span>, <span class="tok-number">0xe7</span>, <span class="tok-number">0x6d</span>, <span class="tok-number">0x8d</span>, <span class="tok-number">0x4</span>,</span>
<span class="line" id="L1343">            <span class="tok-number">0x19</span>, <span class="tok-number">0x49</span>, <span class="tok-number">0x7f</span>, <span class="tok-number">0x47</span>, <span class="tok-number">0x1f</span>, <span class="tok-number">0x48</span>, <span class="tok-number">0x15</span>, <span class="tok-number">0xb0</span>, <span class="tok-number">0xe8</span>, <span class="tok-number">0x9e</span>, <span class="tok-number">0xf2</span>, <span class="tok-number">0x31</span>, <span class="tok-number">0x59</span>, <span class="tok-number">0xde</span>,</span>
<span class="line" id="L1344">            <span class="tok-number">0x34</span>, <span class="tok-number">0xb4</span>, <span class="tok-number">0x5b</span>, <span class="tok-number">0xe5</span>, <span class="tok-number">0xe0</span>, <span class="tok-number">0x9</span>,  <span class="tok-number">0x11</span>, <span class="tok-number">0x30</span>, <span class="tok-number">0xc2</span>, <span class="tok-number">0x88</span>, <span class="tok-number">0x5b</span>, <span class="tok-number">0x7c</span>, <span class="tok-number">0x5d</span>, <span class="tok-number">0x14</span>,</span>
<span class="line" id="L1345">            <span class="tok-number">0x13</span>, <span class="tok-number">0x6f</span>, <span class="tok-number">0x23</span>, <span class="tok-number">0xa9</span>, <span class="tok-number">0xd</span>,  <span class="tok-number">0xbc</span>, <span class="tok-number">0x2d</span>, <span class="tok-number">0x23</span>, <span class="tok-number">0xbe</span>, <span class="tok-number">0xd9</span>, <span class="tok-number">0xed</span>, <span class="tok-number">0x75</span>, <span class="tok-number">0x4</span>,  <span class="tok-number">0x6c</span>,</span>
<span class="line" id="L1346">            <span class="tok-number">0x99</span>, <span class="tok-number">0xdf</span>, <span class="tok-number">0xfd</span>, <span class="tok-number">0x70</span>, <span class="tok-number">0x66</span>, <span class="tok-number">0xe6</span>, <span class="tok-number">0xee</span>, <span class="tok-number">0xd9</span>, <span class="tok-number">0xb1</span>, <span class="tok-number">0x9e</span>, <span class="tok-number">0x6e</span>, <span class="tok-number">0x83</span>, <span class="tok-number">0x59</span>, <span class="tok-number">0xd5</span>,</span>
<span class="line" id="L1347">            <span class="tok-number">0xd4</span>, <span class="tok-number">0x80</span>, <span class="tok-number">0x59</span>, <span class="tok-number">0x98</span>, <span class="tok-number">0x77</span>, <span class="tok-number">0x89</span>, <span class="tok-number">0x43</span>, <span class="tok-number">0x38</span>, <span class="tok-number">0xc9</span>, <span class="tok-number">0xaf</span>, <span class="tok-number">0x30</span>, <span class="tok-number">0x32</span>, <span class="tok-number">0x9a</span>, <span class="tok-number">0x20</span>,</span>
<span class="line" id="L1348">            <span class="tok-number">0x1b</span>, <span class="tok-number">0x46</span>, <span class="tok-number">0x3d</span>, <span class="tok-number">0x67</span>, <span class="tok-number">0x6e</span>, <span class="tok-number">0xd7</span>, <span class="tok-number">0x72</span>, <span class="tok-number">0x9e</span>, <span class="tok-number">0x4e</span>, <span class="tok-number">0x21</span>, <span class="tok-number">0x4f</span>, <span class="tok-number">0xc6</span>, <span class="tok-number">0xe0</span>, <span class="tok-number">0xd4</span>,</span>
<span class="line" id="L1349">            <span class="tok-number">0x7b</span>, <span class="tok-number">0x4</span>,  <span class="tok-number">0x8d</span>, <span class="tok-number">0xa5</span>, <span class="tok-number">0x3</span>,  <span class="tok-number">0xf6</span>, <span class="tok-number">0x5</span>,  <span class="tok-number">0x9b</span>, <span class="tok-number">0x6b</span>, <span class="tok-number">0xdc</span>, <span class="tok-number">0x2a</span>, <span class="tok-number">0x93</span>, <span class="tok-number">0x77</span>, <span class="tok-number">0x28</span>,</span>
<span class="line" id="L1350">            <span class="tok-number">0xfd</span>, <span class="tok-number">0xb4</span>, <span class="tok-number">0x62</span>, <span class="tok-number">0xda</span>, <span class="tok-number">0x20</span>, <span class="tok-number">0xe7</span>, <span class="tok-number">0x1f</span>, <span class="tok-number">0xab</span>, <span class="tok-number">0x6b</span>, <span class="tok-number">0x51</span>, <span class="tok-number">0x43</span>, <span class="tok-number">0x39</span>, <span class="tok-number">0x2f</span>, <span class="tok-number">0xa0</span>,</span>
<span class="line" id="L1351">            <span class="tok-number">0x92</span>, <span class="tok-number">0x1</span>,  <span class="tok-number">0x6c</span>, <span class="tok-number">0x75</span>, <span class="tok-number">0x3e</span>, <span class="tok-number">0xf4</span>, <span class="tok-number">0x35</span>, <span class="tok-number">0xfd</span>, <span class="tok-number">0x43</span>, <span class="tok-number">0x2e</span>, <span class="tok-number">0xf7</span>, <span class="tok-number">0xa4</span>, <span class="tok-number">0x75</span>, <span class="tok-number">0xda</span>,</span>
<span class="line" id="L1352">            <span class="tok-number">0xea</span>, <span class="tok-number">0x9b</span>, <span class="tok-number">0xa</span>,  <span class="tok-number">0x64</span>, <span class="tok-number">0xb</span>,  <span class="tok-number">0xe0</span>, <span class="tok-number">0x23</span>, <span class="tok-number">0x29</span>, <span class="tok-number">0xbd</span>, <span class="tok-number">0xf7</span>, <span class="tok-number">0xe7</span>, <span class="tok-number">0x83</span>, <span class="tok-number">0x3c</span>, <span class="tok-number">0xfb</span>,</span>
<span class="line" id="L1353">            <span class="tok-number">0xdf</span>, <span class="tok-number">0xb3</span>, <span class="tok-number">0xae</span>, <span class="tok-number">0x4f</span>, <span class="tok-number">0xa4</span>, <span class="tok-number">0x47</span>, <span class="tok-number">0x55</span>, <span class="tok-number">0x99</span>, <span class="tok-number">0xde</span>, <span class="tok-number">0x2f</span>, <span class="tok-number">0x96</span>, <span class="tok-number">0x6e</span>, <span class="tok-number">0x1c</span>, <span class="tok-number">0x43</span>,</span>
<span class="line" id="L1354">            <span class="tok-number">0x4c</span>, <span class="tok-number">0x87</span>, <span class="tok-number">0xe2</span>, <span class="tok-number">0x7c</span>, <span class="tok-number">0xd9</span>, <span class="tok-number">0x5f</span>, <span class="tok-number">0x4c</span>, <span class="tok-number">0x7c</span>, <span class="tok-number">0xe8</span>, <span class="tok-number">0x90</span>, <span class="tok-number">0x3</span>,  <span class="tok-number">0xdb</span>, <span class="tok-number">0x30</span>, <span class="tok-number">0x95</span>,</span>
<span class="line" id="L1355">            <span class="tok-number">0xd6</span>, <span class="tok-number">0x22</span>, <span class="tok-number">0xc</span>,  <span class="tok-number">0x47</span>, <span class="tok-number">0xb8</span>, <span class="tok-number">0x4d</span>, <span class="tok-number">0x6b</span>, <span class="tok-number">0xbd</span>, <span class="tok-number">0x24</span>, <span class="tok-number">0x11</span>, <span class="tok-number">0xab</span>, <span class="tok-number">0x2c</span>, <span class="tok-number">0xd7</span>, <span class="tok-number">0xbe</span>,</span>
<span class="line" id="L1356">            <span class="tok-number">0x6e</span>, <span class="tok-number">0x7a</span>, <span class="tok-number">0xd6</span>, <span class="tok-number">0x8</span>,  <span class="tok-number">0xa3</span>, <span class="tok-number">0x98</span>, <span class="tok-number">0xd8</span>, <span class="tok-number">0xdd</span>, <span class="tok-number">0x15</span>, <span class="tok-number">0x6a</span>, <span class="tok-number">0xfa</span>, <span class="tok-number">0x93</span>, <span class="tok-number">0x30</span>, <span class="tok-number">0x1</span>,</span>
<span class="line" id="L1357">            <span class="tok-number">0x25</span>, <span class="tok-number">0x1d</span>, <span class="tok-number">0xa2</span>, <span class="tok-number">0x74</span>, <span class="tok-number">0x86</span>, <span class="tok-number">0x4b</span>, <span class="tok-number">0x6a</span>, <span class="tok-number">0x95</span>, <span class="tok-number">0xe8</span>, <span class="tok-number">0xe1</span>, <span class="tok-number">0x4e</span>, <span class="tok-number">0xe</span>,  <span class="tok-number">0x76</span>, <span class="tok-number">0xb9</span>,</span>
<span class="line" id="L1358">            <span class="tok-number">0x49</span>, <span class="tok-number">0xa9</span>, <span class="tok-number">0x5f</span>, <span class="tok-number">0xa0</span>, <span class="tok-number">0xa6</span>, <span class="tok-number">0x63</span>, <span class="tok-number">0x3c</span>, <span class="tok-number">0x7e</span>, <span class="tok-number">0x7e</span>, <span class="tok-number">0x20</span>, <span class="tok-number">0x13</span>, <span class="tok-number">0x4f</span>, <span class="tok-number">0xbb</span>, <span class="tok-number">0x66</span>,</span>
<span class="line" id="L1359">            <span class="tok-number">0x92</span>, <span class="tok-number">0xb8</span>, <span class="tok-number">0x2e</span>, <span class="tok-number">0xa4</span>, <span class="tok-number">0xfa</span>, <span class="tok-number">0x48</span>, <span class="tok-number">0xcb</span>, <span class="tok-number">0xae</span>, <span class="tok-number">0xb9</span>, <span class="tok-number">0x3c</span>, <span class="tok-number">0xaf</span>, <span class="tok-number">0xd3</span>, <span class="tok-number">0x1f</span>, <span class="tok-number">0xe1</span>,</span>
<span class="line" id="L1360">            <span class="tok-number">0xd5</span>, <span class="tok-number">0x8d</span>, <span class="tok-number">0x42</span>, <span class="tok-number">0x6d</span>, <span class="tok-number">0xf0</span>, <span class="tok-number">0xfc</span>, <span class="tok-number">0x8c</span>, <span class="tok-number">0xc</span>,  <span class="tok-number">0x0</span>,  <span class="tok-number">0xde</span>, <span class="tok-number">0x40</span>, <span class="tok-number">0xab</span>, <span class="tok-number">0x8b</span>, <span class="tok-number">0x47</span>,</span>
<span class="line" id="L1361">            <span class="tok-number">0x97</span>, <span class="tok-number">0x4e</span>, <span class="tok-number">0xa8</span>, <span class="tok-number">0xcf</span>, <span class="tok-number">0x8e</span>, <span class="tok-number">0xdb</span>, <span class="tok-number">0xa6</span>, <span class="tok-number">0x8b</span>, <span class="tok-number">0x20</span>, <span class="tok-number">0x9</span>,  <span class="tok-number">0x84</span>, <span class="tok-number">0x7a</span>, <span class="tok-number">0x66</span>, <span class="tok-number">0xe5</span>,</span>
<span class="line" id="L1362">            <span class="tok-number">0x98</span>, <span class="tok-number">0x29</span>, <span class="tok-number">0x2</span>,  <span class="tok-number">0x95</span>, <span class="tok-number">0xe6</span>, <span class="tok-number">0x38</span>, <span class="tok-number">0x32</span>, <span class="tok-number">0x60</span>, <span class="tok-number">0x3</span>,  <span class="tok-number">0xe3</span>, <span class="tok-number">0x9a</span>, <span class="tok-number">0x1e</span>, <span class="tok-number">0x54</span>, <span class="tok-number">0xe8</span>,</span>
<span class="line" id="L1363">            <span class="tok-number">0x63</span>, <span class="tok-number">0x80</span>, <span class="tok-number">0x48</span>, <span class="tok-number">0x9c</span>, <span class="tok-number">0xe7</span>, <span class="tok-number">0x63</span>, <span class="tok-number">0x33</span>, <span class="tok-number">0x6e</span>, <span class="tok-number">0xa0</span>, <span class="tok-number">0x65</span>, <span class="tok-number">0x83</span>, <span class="tok-number">0xfa</span>, <span class="tok-number">0xc6</span>, <span class="tok-number">0xba</span>,</span>
<span class="line" id="L1364">            <span class="tok-number">0x7a</span>, <span class="tok-number">0x43</span>, <span class="tok-number">0x71</span>, <span class="tok-number">0x5</span>,  <span class="tok-number">0xf5</span>, <span class="tok-number">0x68</span>, <span class="tok-number">0x69</span>, <span class="tok-number">0x85</span>, <span class="tok-number">0x9c</span>, <span class="tok-number">0xba</span>, <span class="tok-number">0x45</span>, <span class="tok-number">0xcd</span>, <span class="tok-number">0x6b</span>, <span class="tok-number">0xb</span>,</span>
<span class="line" id="L1365">            <span class="tok-number">0x19</span>, <span class="tok-number">0xd1</span>, <span class="tok-number">0xbb</span>, <span class="tok-number">0x7f</span>, <span class="tok-number">0x70</span>, <span class="tok-number">0x85</span>, <span class="tok-number">0x92</span>, <span class="tok-number">0xd1</span>, <span class="tok-number">0xb4</span>, <span class="tok-number">0x64</span>, <span class="tok-number">0x82</span>, <span class="tok-number">0xb1</span>, <span class="tok-number">0xe4</span>, <span class="tok-number">0x62</span>,</span>
<span class="line" id="L1366">            <span class="tok-number">0xc5</span>, <span class="tok-number">0x3c</span>, <span class="tok-number">0x46</span>, <span class="tok-number">0x1f</span>, <span class="tok-number">0x92</span>, <span class="tok-number">0x31</span>, <span class="tok-number">0x1c</span>, <span class="tok-number">0x4e</span>, <span class="tok-number">0x41</span>, <span class="tok-number">0x77</span>, <span class="tok-number">0xf7</span>, <span class="tok-number">0xe7</span>, <span class="tok-number">0x87</span>, <span class="tok-number">0xa2</span>,</span>
<span class="line" id="L1367">            <span class="tok-number">0xf</span>,  <span class="tok-number">0x6e</span>, <span class="tok-number">0xe8</span>, <span class="tok-number">0x92</span>, <span class="tok-number">0x3</span>,  <span class="tok-number">0x6b</span>, <span class="tok-number">0xa</span>,  <span class="tok-number">0xe7</span>, <span class="tok-number">0xa9</span>, <span class="tok-number">0x3b</span>, <span class="tok-number">0x11</span>, <span class="tok-number">0xda</span>, <span class="tok-number">0x66</span>, <span class="tok-number">0x8a</span>,</span>
<span class="line" id="L1368">            <span class="tok-number">0x29</span>, <span class="tok-number">0xda</span>, <span class="tok-number">0x79</span>, <span class="tok-number">0xe1</span>, <span class="tok-number">0x64</span>, <span class="tok-number">0x8d</span>, <span class="tok-number">0xe3</span>, <span class="tok-number">0x54</span>, <span class="tok-number">0xd4</span>, <span class="tok-number">0xf5</span>, <span class="tok-number">0xef</span>, <span class="tok-number">0x64</span>, <span class="tok-number">0x87</span>, <span class="tok-number">0x3b</span>,</span>
<span class="line" id="L1369">            <span class="tok-number">0xf4</span>, <span class="tok-number">0xc2</span>, <span class="tok-number">0xf4</span>, <span class="tok-number">0x71</span>, <span class="tok-number">0x13</span>, <span class="tok-number">0xa9</span>, <span class="tok-number">0xe9</span>, <span class="tok-number">0xe0</span>, <span class="tok-number">0xa2</span>, <span class="tok-number">0x6</span>,  <span class="tok-number">0x14</span>, <span class="tok-number">0xab</span>, <span class="tok-number">0x5d</span>, <span class="tok-number">0xa7</span>,</span>
<span class="line" id="L1370">            <span class="tok-number">0x96</span>, <span class="tok-number">0x0</span>,  <span class="tok-number">0xd6</span>, <span class="tok-number">0xc3</span>, <span class="tok-number">0xcc</span>, <span class="tok-number">0x57</span>, <span class="tok-number">0xed</span>, <span class="tok-number">0x39</span>, <span class="tok-number">0x6a</span>, <span class="tok-number">0x25</span>, <span class="tok-number">0xcd</span>, <span class="tok-number">0x76</span>, <span class="tok-number">0xea</span>, <span class="tok-number">0xba</span>,</span>
<span class="line" id="L1371">            <span class="tok-number">0x3a</span>, <span class="tok-number">0xf2</span>, <span class="tok-number">0xa1</span>, <span class="tok-number">0x95</span>, <span class="tok-number">0x5d</span>, <span class="tok-number">0xe5</span>, <span class="tok-number">0x71</span>, <span class="tok-number">0xcf</span>, <span class="tok-number">0x9c</span>, <span class="tok-number">0x62</span>, <span class="tok-number">0x9e</span>, <span class="tok-number">0x6a</span>, <span class="tok-number">0xfa</span>, <span class="tok-number">0xd5</span>,</span>
<span class="line" id="L1372">            <span class="tok-number">0x31</span>, <span class="tok-number">0xd1</span>, <span class="tok-number">0xa8</span>, <span class="tok-number">0x66</span>, <span class="tok-number">0x30</span>, <span class="tok-number">0x33</span>, <span class="tok-number">0xaa</span>, <span class="tok-number">0x51</span>, <span class="tok-number">0x17</span>, <span class="tok-number">0x13</span>, <span class="tok-number">0x82</span>, <span class="tok-number">0x99</span>, <span class="tok-number">0xc8</span>, <span class="tok-number">0x14</span>,</span>
<span class="line" id="L1373">            <span class="tok-number">0x60</span>, <span class="tok-number">0x9f</span>, <span class="tok-number">0x4d</span>, <span class="tok-number">0x32</span>, <span class="tok-number">0x6d</span>, <span class="tok-number">0xda</span>, <span class="tok-number">0x19</span>, <span class="tok-number">0x26</span>, <span class="tok-number">0x21</span>, <span class="tok-number">0xdc</span>, <span class="tok-number">0x7e</span>, <span class="tok-number">0x2e</span>, <span class="tok-number">0x25</span>, <span class="tok-number">0x67</span>,</span>
<span class="line" id="L1374">            <span class="tok-number">0x72</span>, <span class="tok-number">0xca</span>, <span class="tok-number">0xf</span>,  <span class="tok-number">0x92</span>, <span class="tok-number">0xcd</span>, <span class="tok-number">0xf6</span>, <span class="tok-number">0xd6</span>, <span class="tok-number">0xcb</span>, <span class="tok-number">0x97</span>, <span class="tok-number">0x8a</span>, <span class="tok-number">0x33</span>, <span class="tok-number">0x58</span>, <span class="tok-number">0x73</span>, <span class="tok-number">0x70</span>,</span>
<span class="line" id="L1375">            <span class="tok-number">0x91</span>, <span class="tok-number">0x1d</span>, <span class="tok-number">0xbf</span>, <span class="tok-number">0x28</span>, <span class="tok-number">0x23</span>, <span class="tok-number">0xa3</span>, <span class="tok-number">0xc</span>,  <span class="tok-number">0xf1</span>, <span class="tok-number">0x83</span>, <span class="tok-number">0xc3</span>, <span class="tok-number">0xc8</span>, <span class="tok-number">0x56</span>, <span class="tok-number">0x77</span>, <span class="tok-number">0x68</span>,</span>
<span class="line" id="L1376">            <span class="tok-number">0xe3</span>, <span class="tok-number">0x82</span>, <span class="tok-number">0xba</span>, <span class="tok-number">0xb9</span>, <span class="tok-number">0x57</span>, <span class="tok-number">0x56</span>, <span class="tok-number">0x57</span>, <span class="tok-number">0x9c</span>, <span class="tok-number">0xc3</span>, <span class="tok-number">0xd6</span>, <span class="tok-number">0x14</span>, <span class="tok-number">0x5</span>,  <span class="tok-number">0x3c</span>, <span class="tok-number">0xb1</span>,</span>
<span class="line" id="L1377">            <span class="tok-number">0xaf</span>, <span class="tok-number">0x93</span>, <span class="tok-number">0xc8</span>, <span class="tok-number">0x8a</span>, <span class="tok-number">0x57</span>, <span class="tok-number">0x7f</span>, <span class="tok-number">0x53</span>, <span class="tok-number">0xfa</span>, <span class="tok-number">0x2f</span>, <span class="tok-number">0xaa</span>, <span class="tok-number">0x6e</span>, <span class="tok-number">0x66</span>, <span class="tok-number">0x83</span>, <span class="tok-number">0xfa</span>,</span>
<span class="line" id="L1378">            <span class="tok-number">0x33</span>, <span class="tok-number">0xd1</span>, <span class="tok-number">0x21</span>, <span class="tok-number">0xab</span>, <span class="tok-number">0x1b</span>, <span class="tok-number">0x71</span>, <span class="tok-number">0xb4</span>, <span class="tok-number">0x7c</span>, <span class="tok-number">0xda</span>, <span class="tok-number">0xfd</span>, <span class="tok-number">0xfb</span>, <span class="tok-number">0x7f</span>, <span class="tok-number">0x20</span>, <span class="tok-number">0xab</span>,</span>
<span class="line" id="L1379">            <span class="tok-number">0x5e</span>, <span class="tok-number">0xd5</span>, <span class="tok-number">0xca</span>, <span class="tok-number">0xfd</span>, <span class="tok-number">0xdd</span>, <span class="tok-number">0xe0</span>, <span class="tok-number">0xee</span>, <span class="tok-number">0xda</span>, <span class="tok-number">0xba</span>, <span class="tok-number">0xa8</span>, <span class="tok-number">0x27</span>, <span class="tok-number">0x99</span>, <span class="tok-number">0x97</span>, <span class="tok-number">0x69</span>,</span>
<span class="line" id="L1380">            <span class="tok-number">0xc1</span>, <span class="tok-number">0x3c</span>, <span class="tok-number">0x82</span>, <span class="tok-number">0x8c</span>, <span class="tok-number">0xa</span>,  <span class="tok-number">0x5c</span>, <span class="tok-number">0x2d</span>, <span class="tok-number">0x5b</span>, <span class="tok-number">0x88</span>, <span class="tok-number">0x3e</span>, <span class="tok-number">0x34</span>, <span class="tok-number">0x35</span>, <span class="tok-number">0x86</span>, <span class="tok-number">0x37</span>,</span>
<span class="line" id="L1381">            <span class="tok-number">0x46</span>, <span class="tok-number">0x79</span>, <span class="tok-number">0xe1</span>, <span class="tok-number">0xaa</span>, <span class="tok-number">0x19</span>, <span class="tok-number">0xfb</span>, <span class="tok-number">0xaa</span>, <span class="tok-number">0xde</span>, <span class="tok-number">0x15</span>, <span class="tok-number">0x9</span>,  <span class="tok-number">0xd</span>,  <span class="tok-number">0x1a</span>, <span class="tok-number">0x57</span>, <span class="tok-number">0xff</span>,</span>
<span class="line" id="L1382">            <span class="tok-number">0xb5</span>, <span class="tok-number">0xf</span>,  <span class="tok-number">0xf3</span>, <span class="tok-number">0x2b</span>, <span class="tok-number">0x5a</span>, <span class="tok-number">0x6a</span>, <span class="tok-number">0x4d</span>, <span class="tok-number">0x19</span>, <span class="tok-number">0x77</span>, <span class="tok-number">0x71</span>, <span class="tok-number">0x45</span>, <span class="tok-number">0xdf</span>, <span class="tok-number">0x4f</span>, <span class="tok-number">0xb3</span>,</span>
<span class="line" id="L1383">            <span class="tok-number">0xec</span>, <span class="tok-number">0xf1</span>, <span class="tok-number">0xeb</span>, <span class="tok-number">0x18</span>, <span class="tok-number">0x53</span>, <span class="tok-number">0x3e</span>, <span class="tok-number">0x3b</span>, <span class="tok-number">0x47</span>, <span class="tok-number">0x8</span>,  <span class="tok-number">0x9a</span>, <span class="tok-number">0x73</span>, <span class="tok-number">0xa0</span>, <span class="tok-number">0x5c</span>, <span class="tok-number">0x8c</span>,</span>
<span class="line" id="L1384">            <span class="tok-number">0x5f</span>, <span class="tok-number">0xeb</span>, <span class="tok-number">0xf</span>,  <span class="tok-number">0x3a</span>, <span class="tok-number">0xc2</span>, <span class="tok-number">0x43</span>, <span class="tok-number">0x67</span>, <span class="tok-number">0xb4</span>, <span class="tok-number">0x66</span>, <span class="tok-number">0x67</span>, <span class="tok-number">0x80</span>, <span class="tok-number">0x58</span>, <span class="tok-number">0xe</span>,  <span class="tok-number">0xc1</span>,</span>
<span class="line" id="L1385">            <span class="tok-number">0xec</span>, <span class="tok-number">0x40</span>, <span class="tok-number">0xd4</span>, <span class="tok-number">0x22</span>, <span class="tok-number">0x94</span>, <span class="tok-number">0xca</span>, <span class="tok-number">0xf9</span>, <span class="tok-number">0xe8</span>, <span class="tok-number">0x92</span>, <span class="tok-number">0xe4</span>, <span class="tok-number">0x69</span>, <span class="tok-number">0x38</span>, <span class="tok-number">0xbe</span>, <span class="tok-number">0x67</span>,</span>
<span class="line" id="L1386">            <span class="tok-number">0x64</span>, <span class="tok-number">0xca</span>, <span class="tok-number">0x50</span>, <span class="tok-number">0xc7</span>, <span class="tok-number">0x6</span>,  <span class="tok-number">0x67</span>, <span class="tok-number">0x42</span>, <span class="tok-number">0x6e</span>, <span class="tok-number">0xa3</span>, <span class="tok-number">0xf0</span>, <span class="tok-number">0xb7</span>, <span class="tok-number">0x6c</span>, <span class="tok-number">0xf2</span>, <span class="tok-number">0xe8</span>,</span>
<span class="line" id="L1387">            <span class="tok-number">0x5f</span>, <span class="tok-number">0xb1</span>, <span class="tok-number">0xaf</span>, <span class="tok-number">0xe7</span>, <span class="tok-number">0xdb</span>, <span class="tok-number">0xbb</span>, <span class="tok-number">0x77</span>, <span class="tok-number">0xb5</span>, <span class="tok-number">0xf8</span>, <span class="tok-number">0xcb</span>, <span class="tok-number">0x8</span>,  <span class="tok-number">0xc4</span>, <span class="tok-number">0x75</span>, <span class="tok-number">0x7e</span>,</span>
<span class="line" id="L1388">            <span class="tok-number">0xc0</span>, <span class="tok-number">0xf9</span>, <span class="tok-number">0x1c</span>, <span class="tok-number">0x7f</span>, <span class="tok-number">0x3c</span>, <span class="tok-number">0x89</span>, <span class="tok-number">0x2f</span>, <span class="tok-number">0xd2</span>, <span class="tok-number">0x58</span>, <span class="tok-number">0x3a</span>, <span class="tok-number">0xe2</span>, <span class="tok-number">0xf8</span>, <span class="tok-number">0x91</span>, <span class="tok-number">0xb6</span>,</span>
<span class="line" id="L1389">            <span class="tok-number">0x7b</span>, <span class="tok-number">0x24</span>, <span class="tok-number">0x27</span>, <span class="tok-number">0xe9</span>, <span class="tok-number">0xae</span>, <span class="tok-number">0x84</span>, <span class="tok-number">0x8b</span>, <span class="tok-number">0xde</span>, <span class="tok-number">0x74</span>, <span class="tok-number">0xac</span>, <span class="tok-number">0xfd</span>, <span class="tok-number">0xd9</span>, <span class="tok-number">0xb7</span>, <span class="tok-number">0x69</span>,</span>
<span class="line" id="L1390">            <span class="tok-number">0x2a</span>, <span class="tok-number">0xec</span>, <span class="tok-number">0x32</span>, <span class="tok-number">0x6f</span>, <span class="tok-number">0xf0</span>, <span class="tok-number">0x92</span>, <span class="tok-number">0x84</span>, <span class="tok-number">0xf1</span>, <span class="tok-number">0x40</span>, <span class="tok-number">0xc</span>,  <span class="tok-number">0x8a</span>, <span class="tok-number">0xbc</span>, <span class="tok-number">0x39</span>, <span class="tok-number">0x6e</span>,</span>
<span class="line" id="L1391">            <span class="tok-number">0x2e</span>, <span class="tok-number">0x73</span>, <span class="tok-number">0xd4</span>, <span class="tok-number">0x6e</span>, <span class="tok-number">0x8a</span>, <span class="tok-number">0x74</span>, <span class="tok-number">0x2a</span>, <span class="tok-number">0xdc</span>, <span class="tok-number">0x60</span>, <span class="tok-number">0x1f</span>, <span class="tok-number">0xa3</span>, <span class="tok-number">0x7</span>,  <span class="tok-number">0xde</span>, <span class="tok-number">0x75</span>,</span>
<span class="line" id="L1392">            <span class="tok-number">0x8b</span>, <span class="tok-number">0x74</span>, <span class="tok-number">0xc8</span>, <span class="tok-number">0xfe</span>, <span class="tok-number">0x63</span>, <span class="tok-number">0x75</span>, <span class="tok-number">0xf6</span>, <span class="tok-number">0x3d</span>, <span class="tok-number">0x63</span>, <span class="tok-number">0xac</span>, <span class="tok-number">0x33</span>, <span class="tok-number">0x89</span>, <span class="tok-number">0xc3</span>, <span class="tok-number">0xf0</span>,</span>
<span class="line" id="L1393">            <span class="tok-number">0xf8</span>, <span class="tok-number">0x2d</span>, <span class="tok-number">0x6b</span>, <span class="tok-number">0xb4</span>, <span class="tok-number">0x9e</span>, <span class="tok-number">0x74</span>, <span class="tok-number">0x8b</span>, <span class="tok-number">0x5c</span>, <span class="tok-number">0x33</span>, <span class="tok-number">0xb4</span>, <span class="tok-number">0xca</span>, <span class="tok-number">0xa8</span>, <span class="tok-number">0xe4</span>, <span class="tok-number">0x99</span>,</span>
<span class="line" id="L1394">            <span class="tok-number">0xb6</span>, <span class="tok-number">0x90</span>, <span class="tok-number">0xa1</span>, <span class="tok-number">0xef</span>, <span class="tok-number">0xf</span>,  <span class="tok-number">0xd3</span>, <span class="tok-number">0x61</span>, <span class="tok-number">0xb2</span>, <span class="tok-number">0xc6</span>, <span class="tok-number">0x1a</span>, <span class="tok-number">0x94</span>, <span class="tok-number">0x7c</span>, <span class="tok-number">0x44</span>, <span class="tok-number">0x55</span>,</span>
<span class="line" id="L1395">            <span class="tok-number">0xf4</span>, <span class="tok-number">0x45</span>, <span class="tok-number">0xff</span>, <span class="tok-number">0x9e</span>, <span class="tok-number">0xa5</span>, <span class="tok-number">0x5a</span>, <span class="tok-number">0xc6</span>, <span class="tok-number">0xa0</span>, <span class="tok-number">0xe8</span>, <span class="tok-number">0x2a</span>, <span class="tok-number">0xc1</span>, <span class="tok-number">0x8d</span>, <span class="tok-number">0x6f</span>, <span class="tok-number">0x34</span>,</span>
<span class="line" id="L1396">            <span class="tok-number">0x11</span>, <span class="tok-number">0xb9</span>, <span class="tok-number">0xbe</span>, <span class="tok-number">0x4e</span>, <span class="tok-number">0xd9</span>, <span class="tok-number">0x87</span>, <span class="tok-number">0x97</span>, <span class="tok-number">0x73</span>, <span class="tok-number">0xcf</span>, <span class="tok-number">0x3d</span>, <span class="tok-number">0x23</span>, <span class="tok-number">0xae</span>, <span class="tok-number">0xd5</span>, <span class="tok-number">0x1a</span>,</span>
<span class="line" id="L1397">            <span class="tok-number">0x5e</span>, <span class="tok-number">0xae</span>, <span class="tok-number">0x5d</span>, <span class="tok-number">0x6a</span>, <span class="tok-number">0x3</span>,  <span class="tok-number">0xf9</span>, <span class="tok-number">0x22</span>, <span class="tok-number">0xd</span>,  <span class="tok-number">0x10</span>, <span class="tok-number">0xd9</span>, <span class="tok-number">0x47</span>, <span class="tok-number">0x69</span>, <span class="tok-number">0x15</span>, <span class="tok-number">0x3f</span>,</span>
<span class="line" id="L1398">            <span class="tok-number">0xee</span>, <span class="tok-number">0x52</span>, <span class="tok-number">0xa3</span>, <span class="tok-number">0x8</span>,  <span class="tok-number">0xd2</span>, <span class="tok-number">0x3c</span>, <span class="tok-number">0x51</span>, <span class="tok-number">0xf4</span>, <span class="tok-number">0xf8</span>, <span class="tok-number">0x9d</span>, <span class="tok-number">0xe4</span>, <span class="tok-number">0x98</span>, <span class="tok-number">0x89</span>, <span class="tok-number">0xc8</span>,</span>
<span class="line" id="L1399">            <span class="tok-number">0x67</span>, <span class="tok-number">0x39</span>, <span class="tok-number">0xd5</span>, <span class="tok-number">0x5e</span>, <span class="tok-number">0x35</span>, <span class="tok-number">0x78</span>, <span class="tok-number">0x27</span>, <span class="tok-number">0xe8</span>, <span class="tok-number">0x3c</span>, <span class="tok-number">0x80</span>, <span class="tok-number">0xae</span>, <span class="tok-number">0x79</span>, <span class="tok-number">0x71</span>, <span class="tok-number">0xd2</span>,</span>
<span class="line" id="L1400">            <span class="tok-number">0x93</span>, <span class="tok-number">0xf4</span>, <span class="tok-number">0xaa</span>, <span class="tok-number">0x51</span>, <span class="tok-number">0x12</span>, <span class="tok-number">0x1c</span>, <span class="tok-number">0x4b</span>, <span class="tok-number">0x1b</span>, <span class="tok-number">0xe5</span>, <span class="tok-number">0x6e</span>, <span class="tok-number">0x15</span>, <span class="tok-number">0x6f</span>, <span class="tok-number">0xe4</span>, <span class="tok-number">0xbb</span>,</span>
<span class="line" id="L1401">            <span class="tok-number">0x51</span>, <span class="tok-number">0x9b</span>, <span class="tok-number">0x45</span>, <span class="tok-number">0x9f</span>, <span class="tok-number">0xf9</span>, <span class="tok-number">0xc4</span>, <span class="tok-number">0x8c</span>, <span class="tok-number">0x2a</span>, <span class="tok-number">0xfb</span>, <span class="tok-number">0x1a</span>, <span class="tok-number">0xdf</span>, <span class="tok-number">0x55</span>, <span class="tok-number">0xd3</span>, <span class="tok-number">0x48</span>,</span>
<span class="line" id="L1402">            <span class="tok-number">0x93</span>, <span class="tok-number">0x27</span>, <span class="tok-number">0x1</span>,  <span class="tok-number">0x26</span>, <span class="tok-number">0xc2</span>, <span class="tok-number">0x6b</span>, <span class="tok-number">0x55</span>, <span class="tok-number">0x6d</span>, <span class="tok-number">0xa2</span>, <span class="tok-number">0xfb</span>, <span class="tok-number">0x84</span>, <span class="tok-number">0x8b</span>, <span class="tok-number">0xc9</span>, <span class="tok-number">0x9e</span>,</span>
<span class="line" id="L1403">            <span class="tok-number">0x28</span>, <span class="tok-number">0xc2</span>, <span class="tok-number">0xef</span>, <span class="tok-number">0x1a</span>, <span class="tok-number">0x24</span>, <span class="tok-number">0xec</span>, <span class="tok-number">0x9b</span>, <span class="tok-number">0xae</span>, <span class="tok-number">0xbd</span>, <span class="tok-number">0x60</span>, <span class="tok-number">0xe9</span>, <span class="tok-number">0x15</span>, <span class="tok-number">0x35</span>, <span class="tok-number">0xee</span>,</span>
<span class="line" id="L1404">            <span class="tok-number">0x42</span>, <span class="tok-number">0xa4</span>, <span class="tok-number">0x33</span>, <span class="tok-number">0x5b</span>, <span class="tok-number">0xfa</span>, <span class="tok-number">0xf</span>,  <span class="tok-number">0xb6</span>, <span class="tok-number">0xf7</span>, <span class="tok-number">0x1</span>,  <span class="tok-number">0xa6</span>, <span class="tok-number">0x2</span>,  <span class="tok-number">0x4c</span>, <span class="tok-number">0xca</span>, <span class="tok-number">0x90</span>,</span>
<span class="line" id="L1405">            <span class="tok-number">0x58</span>, <span class="tok-number">0x3a</span>, <span class="tok-number">0x96</span>, <span class="tok-number">0x41</span>, <span class="tok-number">0xe7</span>, <span class="tok-number">0xcb</span>, <span class="tok-number">0x9</span>,  <span class="tok-number">0x8c</span>, <span class="tok-number">0xdb</span>, <span class="tok-number">0x85</span>, <span class="tok-number">0x4d</span>, <span class="tok-number">0xa8</span>, <span class="tok-number">0x89</span>, <span class="tok-number">0xf3</span>,</span>
<span class="line" id="L1406">            <span class="tok-number">0xb5</span>, <span class="tok-number">0x8e</span>, <span class="tok-number">0xfd</span>, <span class="tok-number">0x75</span>, <span class="tok-number">0x5b</span>, <span class="tok-number">0x4f</span>, <span class="tok-number">0xed</span>, <span class="tok-number">0xde</span>, <span class="tok-number">0x3f</span>, <span class="tok-number">0xeb</span>, <span class="tok-number">0x38</span>, <span class="tok-number">0xa3</span>, <span class="tok-number">0xbe</span>, <span class="tok-number">0xb0</span>,</span>
<span class="line" id="L1407">            <span class="tok-number">0x73</span>, <span class="tok-number">0xfc</span>, <span class="tok-number">0xb8</span>, <span class="tok-number">0x54</span>, <span class="tok-number">0xf7</span>, <span class="tok-number">0x4c</span>, <span class="tok-number">0x30</span>, <span class="tok-number">0x67</span>, <span class="tok-number">0x2e</span>, <span class="tok-number">0x38</span>, <span class="tok-number">0xa2</span>, <span class="tok-number">0x54</span>, <span class="tok-number">0x18</span>, <span class="tok-number">0xba</span>,</span>
<span class="line" id="L1408">            <span class="tok-number">0x8</span>,  <span class="tok-number">0xbf</span>, <span class="tok-number">0xf2</span>, <span class="tok-number">0x39</span>, <span class="tok-number">0xd5</span>, <span class="tok-number">0xfe</span>, <span class="tok-number">0xa5</span>, <span class="tok-number">0x41</span>, <span class="tok-number">0xc6</span>, <span class="tok-number">0x66</span>, <span class="tok-number">0x66</span>, <span class="tok-number">0xba</span>, <span class="tok-number">0x81</span>, <span class="tok-number">0xef</span>,</span>
<span class="line" id="L1409">            <span class="tok-number">0x67</span>, <span class="tok-number">0xe4</span>, <span class="tok-number">0xe6</span>, <span class="tok-number">0x3c</span>, <span class="tok-number">0xc</span>,  <span class="tok-number">0xca</span>, <span class="tok-number">0xa4</span>, <span class="tok-number">0xa</span>,  <span class="tok-number">0x79</span>, <span class="tok-number">0xb3</span>, <span class="tok-number">0x57</span>, <span class="tok-number">0x8b</span>, <span class="tok-number">0x8a</span>, <span class="tok-number">0x75</span>,</span>
<span class="line" id="L1410">            <span class="tok-number">0x98</span>, <span class="tok-number">0x18</span>, <span class="tok-number">0x42</span>, <span class="tok-number">0x2f</span>, <span class="tok-number">0x29</span>, <span class="tok-number">0xa3</span>, <span class="tok-number">0x82</span>, <span class="tok-number">0xef</span>, <span class="tok-number">0x9f</span>, <span class="tok-number">0x86</span>, <span class="tok-number">0x6</span>,  <span class="tok-number">0x23</span>, <span class="tok-number">0xe1</span>, <span class="tok-number">0x75</span>,</span>
<span class="line" id="L1411">            <span class="tok-number">0xfa</span>, <span class="tok-number">0x8</span>,  <span class="tok-number">0xb1</span>, <span class="tok-number">0xde</span>, <span class="tok-number">0x17</span>, <span class="tok-number">0x4a</span>,</span>
<span class="line" id="L1412">        },</span>
<span class="line" id="L1413">    },</span>
<span class="line" id="L1414">    HuffTest{</span>
<span class="line" id="L1415">        .input = <span class="tok-str">&quot;huffman-rand-limit.input&quot;</span>,</span>
<span class="line" id="L1416">        .want = <span class="tok-str">&quot;huffman-rand-limit.{s}.expect&quot;</span>,</span>
<span class="line" id="L1417">        .want_no_input = <span class="tok-str">&quot;huffman-rand-limit.{s}.expect-noinput&quot;</span>,</span>
<span class="line" id="L1418">        .tokens = &amp;[_]token.Token{</span>
<span class="line" id="L1419">            <span class="tok-number">0x61</span>, <span class="tok-number">0x51c00000</span>, <span class="tok-number">0xa</span>,  <span class="tok-number">0xf8</span>, <span class="tok-number">0x8b</span>, <span class="tok-number">0x96</span>, <span class="tok-number">0x76</span>, <span class="tok-number">0x48</span>, <span class="tok-number">0xa</span>,  <span class="tok-number">0x85</span>, <span class="tok-number">0x94</span>, <span class="tok-number">0x25</span>, <span class="tok-number">0x80</span>,</span>
<span class="line" id="L1420">            <span class="tok-number">0xaf</span>, <span class="tok-number">0xc2</span>,       <span class="tok-number">0xfe</span>, <span class="tok-number">0x8d</span>, <span class="tok-number">0xe8</span>, <span class="tok-number">0x20</span>, <span class="tok-number">0xeb</span>, <span class="tok-number">0x17</span>, <span class="tok-number">0x86</span>, <span class="tok-number">0xc9</span>, <span class="tok-number">0xb7</span>, <span class="tok-number">0xc5</span>, <span class="tok-number">0xde</span>,</span>
<span class="line" id="L1421">            <span class="tok-number">0x6</span>,  <span class="tok-number">0xea</span>,       <span class="tok-number">0x7d</span>, <span class="tok-number">0x18</span>, <span class="tok-number">0x8b</span>, <span class="tok-number">0xe7</span>, <span class="tok-number">0x3e</span>, <span class="tok-number">0x7</span>,  <span class="tok-number">0xda</span>, <span class="tok-number">0xdf</span>, <span class="tok-number">0xff</span>, <span class="tok-number">0x6c</span>, <span class="tok-number">0x73</span>,</span>
<span class="line" id="L1422">            <span class="tok-number">0xde</span>, <span class="tok-number">0xcc</span>,       <span class="tok-number">0xe7</span>, <span class="tok-number">0x6d</span>, <span class="tok-number">0x8d</span>, <span class="tok-number">0x4</span>,  <span class="tok-number">0x19</span>, <span class="tok-number">0x49</span>, <span class="tok-number">0x7f</span>, <span class="tok-number">0x47</span>, <span class="tok-number">0x1f</span>, <span class="tok-number">0x48</span>, <span class="tok-number">0x15</span>,</span>
<span class="line" id="L1423">            <span class="tok-number">0xb0</span>, <span class="tok-number">0xe8</span>,       <span class="tok-number">0x9e</span>, <span class="tok-number">0xf2</span>, <span class="tok-number">0x31</span>, <span class="tok-number">0x59</span>, <span class="tok-number">0xde</span>, <span class="tok-number">0x34</span>, <span class="tok-number">0xb4</span>, <span class="tok-number">0x5b</span>, <span class="tok-number">0xe5</span>, <span class="tok-number">0xe0</span>, <span class="tok-number">0x9</span>,</span>
<span class="line" id="L1424">            <span class="tok-number">0x11</span>, <span class="tok-number">0x30</span>,       <span class="tok-number">0xc2</span>, <span class="tok-number">0x88</span>, <span class="tok-number">0x5b</span>, <span class="tok-number">0x7c</span>, <span class="tok-number">0x5d</span>, <span class="tok-number">0x14</span>, <span class="tok-number">0x13</span>, <span class="tok-number">0x6f</span>, <span class="tok-number">0x23</span>, <span class="tok-number">0xa9</span>, <span class="tok-number">0xa</span>,</span>
<span class="line" id="L1425">            <span class="tok-number">0xbc</span>, <span class="tok-number">0x2d</span>,       <span class="tok-number">0x23</span>, <span class="tok-number">0xbe</span>, <span class="tok-number">0xd9</span>, <span class="tok-number">0xed</span>, <span class="tok-number">0x75</span>, <span class="tok-number">0x4</span>,  <span class="tok-number">0x6c</span>, <span class="tok-number">0x99</span>, <span class="tok-number">0xdf</span>, <span class="tok-number">0xfd</span>, <span class="tok-number">0x70</span>,</span>
<span class="line" id="L1426">            <span class="tok-number">0x66</span>, <span class="tok-number">0xe6</span>,       <span class="tok-number">0xee</span>, <span class="tok-number">0xd9</span>, <span class="tok-number">0xb1</span>, <span class="tok-number">0x9e</span>, <span class="tok-number">0x6e</span>, <span class="tok-number">0x83</span>, <span class="tok-number">0x59</span>, <span class="tok-number">0xd5</span>, <span class="tok-number">0xd4</span>, <span class="tok-number">0x80</span>, <span class="tok-number">0x59</span>,</span>
<span class="line" id="L1427">            <span class="tok-number">0x98</span>, <span class="tok-number">0x77</span>,       <span class="tok-number">0x89</span>, <span class="tok-number">0x43</span>, <span class="tok-number">0x38</span>, <span class="tok-number">0xc9</span>, <span class="tok-number">0xaf</span>, <span class="tok-number">0x30</span>, <span class="tok-number">0x32</span>, <span class="tok-number">0x9a</span>, <span class="tok-number">0x20</span>, <span class="tok-number">0x1b</span>, <span class="tok-number">0x46</span>,</span>
<span class="line" id="L1428">            <span class="tok-number">0x3d</span>, <span class="tok-number">0x67</span>,       <span class="tok-number">0x6e</span>, <span class="tok-number">0xd7</span>, <span class="tok-number">0x72</span>, <span class="tok-number">0x9e</span>, <span class="tok-number">0x4e</span>, <span class="tok-number">0x21</span>, <span class="tok-number">0x4f</span>, <span class="tok-number">0xc6</span>, <span class="tok-number">0xe0</span>, <span class="tok-number">0xd4</span>, <span class="tok-number">0x7b</span>,</span>
<span class="line" id="L1429">            <span class="tok-number">0x4</span>,  <span class="tok-number">0x8d</span>,       <span class="tok-number">0xa5</span>, <span class="tok-number">0x3</span>,  <span class="tok-number">0xf6</span>, <span class="tok-number">0x5</span>,  <span class="tok-number">0x9b</span>, <span class="tok-number">0x6b</span>, <span class="tok-number">0xdc</span>, <span class="tok-number">0x2a</span>, <span class="tok-number">0x93</span>, <span class="tok-number">0x77</span>, <span class="tok-number">0x28</span>,</span>
<span class="line" id="L1430">            <span class="tok-number">0xfd</span>, <span class="tok-number">0xb4</span>,       <span class="tok-number">0x62</span>, <span class="tok-number">0xda</span>, <span class="tok-number">0x20</span>, <span class="tok-number">0xe7</span>, <span class="tok-number">0x1f</span>, <span class="tok-number">0xab</span>, <span class="tok-number">0x6b</span>, <span class="tok-number">0x51</span>, <span class="tok-number">0x43</span>, <span class="tok-number">0x39</span>, <span class="tok-number">0x2f</span>,</span>
<span class="line" id="L1431">            <span class="tok-number">0xa0</span>, <span class="tok-number">0x92</span>,       <span class="tok-number">0x1</span>,  <span class="tok-number">0x6c</span>, <span class="tok-number">0x75</span>, <span class="tok-number">0x3e</span>, <span class="tok-number">0xf4</span>, <span class="tok-number">0x35</span>, <span class="tok-number">0xfd</span>, <span class="tok-number">0x43</span>, <span class="tok-number">0x2e</span>, <span class="tok-number">0xf7</span>, <span class="tok-number">0xa4</span>,</span>
<span class="line" id="L1432">            <span class="tok-number">0x75</span>, <span class="tok-number">0xda</span>,       <span class="tok-number">0xea</span>, <span class="tok-number">0x9b</span>, <span class="tok-number">0xa</span>,</span>
<span class="line" id="L1433">        },</span>
<span class="line" id="L1434">    },</span>
<span class="line" id="L1435">    HuffTest{</span>
<span class="line" id="L1436">        .input = <span class="tok-str">&quot;huffman-shifts.input&quot;</span>,</span>
<span class="line" id="L1437">        .want = <span class="tok-str">&quot;huffman-shifts.{s}.expect&quot;</span>,</span>
<span class="line" id="L1438">        .want_no_input = <span class="tok-str">&quot;huffman-shifts.{s}.expect-noinput&quot;</span>,</span>
<span class="line" id="L1439">        .tokens = &amp;[_]token.Token{</span>
<span class="line" id="L1440">            <span class="tok-number">0x31</span>,       <span class="tok-number">0x30</span>,       <span class="tok-number">0x7fc00001</span>, <span class="tok-number">0x7fc00001</span>, <span class="tok-number">0x7fc00001</span>, <span class="tok-number">0x7fc00001</span>, <span class="tok-number">0x7fc00001</span>,</span>
<span class="line" id="L1441">            <span class="tok-number">0x7fc00001</span>, <span class="tok-number">0x7fc00001</span>, <span class="tok-number">0x7fc00001</span>, <span class="tok-number">0x7fc00001</span>, <span class="tok-number">0x7fc00001</span>, <span class="tok-number">0x7fc00001</span>, <span class="tok-number">0x7fc00001</span>,</span>
<span class="line" id="L1442">            <span class="tok-number">0x7fc00001</span>, <span class="tok-number">0x7fc00001</span>, <span class="tok-number">0x7fc00001</span>, <span class="tok-number">0x52400001</span>, <span class="tok-number">0xd</span>,        <span class="tok-number">0xa</span>,        <span class="tok-number">0x32</span>,</span>
<span class="line" id="L1443">            <span class="tok-number">0x33</span>,       <span class="tok-number">0x7fc00001</span>, <span class="tok-number">0x7fc00001</span>, <span class="tok-number">0x7fc00001</span>, <span class="tok-number">0x7fc00001</span>, <span class="tok-number">0x7fc00001</span>, <span class="tok-number">0x7fc00001</span>,</span>
<span class="line" id="L1444">            <span class="tok-number">0x7fc00001</span>, <span class="tok-number">0x7fc00001</span>, <span class="tok-number">0x7fc00001</span>, <span class="tok-number">0x7f400001</span>,</span>
<span class="line" id="L1445">        },</span>
<span class="line" id="L1446">    },</span>
<span class="line" id="L1447">    HuffTest{</span>
<span class="line" id="L1448">        .input = <span class="tok-str">&quot;huffman-text-shift.input&quot;</span>,</span>
<span class="line" id="L1449">        .want = <span class="tok-str">&quot;huffman-text-shift.{s}.expect&quot;</span>,</span>
<span class="line" id="L1450">        .want_no_input = <span class="tok-str">&quot;huffman-text-shift.{s}.expect-noinput&quot;</span>,</span>
<span class="line" id="L1451">        .tokens = &amp;[_]token.Token{</span>
<span class="line" id="L1452">            <span class="tok-number">0x2f</span>,       <span class="tok-number">0x2f</span>, <span class="tok-number">0x43</span>, <span class="tok-number">0x6f</span>, <span class="tok-number">0x70</span>, <span class="tok-number">0x79</span>, <span class="tok-number">0x72</span>,       <span class="tok-number">0x69</span>, <span class="tok-number">0x67</span>,       <span class="tok-number">0x68</span>,</span>
<span class="line" id="L1453">            <span class="tok-number">0x74</span>,       <span class="tok-number">0x32</span>, <span class="tok-number">0x30</span>, <span class="tok-number">0x30</span>, <span class="tok-number">0x39</span>, <span class="tok-number">0x54</span>, <span class="tok-number">0x68</span>,       <span class="tok-number">0x47</span>, <span class="tok-number">0x6f</span>,       <span class="tok-number">0x41</span>,</span>
<span class="line" id="L1454">            <span class="tok-number">0x75</span>,       <span class="tok-number">0x74</span>, <span class="tok-number">0x68</span>, <span class="tok-number">0x6f</span>, <span class="tok-number">0x72</span>, <span class="tok-number">0x2e</span>, <span class="tok-number">0x41</span>,       <span class="tok-number">0x6c</span>, <span class="tok-number">0x6c</span>,       <span class="tok-number">0x40800016</span>,</span>
<span class="line" id="L1455">            <span class="tok-number">0x72</span>,       <span class="tok-number">0x72</span>, <span class="tok-number">0x76</span>, <span class="tok-number">0x64</span>, <span class="tok-number">0x2e</span>, <span class="tok-number">0xd</span>,  <span class="tok-number">0xa</span>,        <span class="tok-number">0x2f</span>, <span class="tok-number">0x2f</span>,       <span class="tok-number">0x55</span>,</span>
<span class="line" id="L1456">            <span class="tok-number">0x6f</span>,       <span class="tok-number">0x66</span>, <span class="tok-number">0x74</span>, <span class="tok-number">0x68</span>, <span class="tok-number">0x69</span>, <span class="tok-number">0x6f</span>, <span class="tok-number">0x75</span>,       <span class="tok-number">0x72</span>, <span class="tok-number">0x63</span>,       <span class="tok-number">0x63</span>,</span>
<span class="line" id="L1457">            <span class="tok-number">0x6f</span>,       <span class="tok-number">0x64</span>, <span class="tok-number">0x69</span>, <span class="tok-number">0x67</span>, <span class="tok-number">0x6f</span>, <span class="tok-number">0x76</span>, <span class="tok-number">0x72</span>,       <span class="tok-number">0x6e</span>, <span class="tok-number">0x64</span>,       <span class="tok-number">0x62</span>,</span>
<span class="line" id="L1458">            <span class="tok-number">0x79</span>,       <span class="tok-number">0x42</span>, <span class="tok-number">0x53</span>, <span class="tok-number">0x44</span>, <span class="tok-number">0x2d</span>, <span class="tok-number">0x74</span>, <span class="tok-number">0x79</span>,       <span class="tok-number">0x6c</span>, <span class="tok-number">0x40400020</span>, <span class="tok-number">0x6c</span>,</span>
<span class="line" id="L1459">            <span class="tok-number">0x69</span>,       <span class="tok-number">0x63</span>, <span class="tok-number">0x6e</span>, <span class="tok-number">0x74</span>, <span class="tok-number">0x68</span>, <span class="tok-number">0x74</span>, <span class="tok-number">0x63</span>,       <span class="tok-number">0x6e</span>, <span class="tok-number">0x62</span>,       <span class="tok-number">0x66</span>,</span>
<span class="line" id="L1460">            <span class="tok-number">0x6f</span>,       <span class="tok-number">0x75</span>, <span class="tok-number">0x6e</span>, <span class="tok-number">0x64</span>, <span class="tok-number">0x69</span>, <span class="tok-number">0x6e</span>, <span class="tok-number">0x74</span>,       <span class="tok-number">0x68</span>, <span class="tok-number">0x4c</span>,       <span class="tok-number">0x49</span>,</span>
<span class="line" id="L1461">            <span class="tok-number">0x43</span>,       <span class="tok-number">0x45</span>, <span class="tok-number">0x4e</span>, <span class="tok-number">0x53</span>, <span class="tok-number">0x45</span>, <span class="tok-number">0x66</span>, <span class="tok-number">0x69</span>,       <span class="tok-number">0x6c</span>, <span class="tok-number">0x2e</span>,       <span class="tok-number">0xd</span>,</span>
<span class="line" id="L1462">            <span class="tok-number">0xa</span>,        <span class="tok-number">0xd</span>,  <span class="tok-number">0xa</span>,  <span class="tok-number">0x70</span>, <span class="tok-number">0x63</span>, <span class="tok-number">0x6b</span>, <span class="tok-number">0x67</span>,       <span class="tok-number">0x6d</span>, <span class="tok-number">0x69</span>,       <span class="tok-number">0x6e</span>,</span>
<span class="line" id="L1463">            <span class="tok-number">0x4040000a</span>, <span class="tok-number">0x69</span>, <span class="tok-number">0x6d</span>, <span class="tok-number">0x70</span>, <span class="tok-number">0x6f</span>, <span class="tok-number">0x72</span>, <span class="tok-number">0x74</span>,       <span class="tok-number">0x22</span>, <span class="tok-number">0x6f</span>,       <span class="tok-number">0x22</span>,</span>
<span class="line" id="L1464">            <span class="tok-number">0x4040000c</span>, <span class="tok-number">0x66</span>, <span class="tok-number">0x75</span>, <span class="tok-number">0x6e</span>, <span class="tok-number">0x63</span>, <span class="tok-number">0x6d</span>, <span class="tok-number">0x69</span>,       <span class="tok-number">0x6e</span>, <span class="tok-number">0x28</span>,       <span class="tok-number">0x29</span>,</span>
<span class="line" id="L1465">            <span class="tok-number">0x7b</span>,       <span class="tok-number">0xd</span>,  <span class="tok-number">0xa</span>,  <span class="tok-number">0x9</span>,  <span class="tok-number">0x76</span>, <span class="tok-number">0x72</span>, <span class="tok-number">0x62</span>,       <span class="tok-number">0x3d</span>, <span class="tok-number">0x6d</span>,       <span class="tok-number">0x6b</span>,</span>
<span class="line" id="L1466">            <span class="tok-number">0x28</span>,       <span class="tok-number">0x5b</span>, <span class="tok-number">0x5d</span>, <span class="tok-number">0x62</span>, <span class="tok-number">0x79</span>, <span class="tok-number">0x74</span>, <span class="tok-number">0x2c</span>,       <span class="tok-number">0x36</span>, <span class="tok-number">0x35</span>,       <span class="tok-number">0x35</span>,</span>
<span class="line" id="L1467">            <span class="tok-number">0x33</span>,       <span class="tok-number">0x35</span>, <span class="tok-number">0x29</span>, <span class="tok-number">0xd</span>,  <span class="tok-number">0xa</span>,  <span class="tok-number">0x9</span>,  <span class="tok-number">0x66</span>,       <span class="tok-number">0x2c</span>, <span class="tok-number">0x5f</span>,       <span class="tok-number">0x3a</span>,</span>
<span class="line" id="L1468">            <span class="tok-number">0x3d</span>,       <span class="tok-number">0x6f</span>, <span class="tok-number">0x2e</span>, <span class="tok-number">0x43</span>, <span class="tok-number">0x72</span>, <span class="tok-number">0x74</span>, <span class="tok-number">0x28</span>,       <span class="tok-number">0x22</span>, <span class="tok-number">0x68</span>,       <span class="tok-number">0x75</span>,</span>
<span class="line" id="L1469">            <span class="tok-number">0x66</span>,       <span class="tok-number">0x66</span>, <span class="tok-number">0x6d</span>, <span class="tok-number">0x6e</span>, <span class="tok-number">0x2d</span>, <span class="tok-number">0x6e</span>, <span class="tok-number">0x75</span>,       <span class="tok-number">0x6c</span>, <span class="tok-number">0x6c</span>,       <span class="tok-number">0x2d</span>,</span>
<span class="line" id="L1470">            <span class="tok-number">0x6d</span>,       <span class="tok-number">0x78</span>, <span class="tok-number">0x2e</span>, <span class="tok-number">0x69</span>, <span class="tok-number">0x6e</span>, <span class="tok-number">0x22</span>, <span class="tok-number">0x40800021</span>, <span class="tok-number">0x2e</span>, <span class="tok-number">0x57</span>,       <span class="tok-number">0x72</span>,</span>
<span class="line" id="L1471">            <span class="tok-number">0x69</span>,       <span class="tok-number">0x74</span>, <span class="tok-number">0x28</span>, <span class="tok-number">0x62</span>, <span class="tok-number">0x29</span>, <span class="tok-number">0xd</span>,  <span class="tok-number">0xa</span>,        <span class="tok-number">0x7d</span>, <span class="tok-number">0xd</span>,        <span class="tok-number">0xa</span>,</span>
<span class="line" id="L1472">            <span class="tok-number">0x41</span>,       <span class="tok-number">0x42</span>, <span class="tok-number">0x43</span>, <span class="tok-number">0x44</span>, <span class="tok-number">0x45</span>, <span class="tok-number">0x46</span>, <span class="tok-number">0x47</span>,       <span class="tok-number">0x48</span>, <span class="tok-number">0x49</span>,       <span class="tok-number">0x4a</span>,</span>
<span class="line" id="L1473">            <span class="tok-number">0x4b</span>,       <span class="tok-number">0x4c</span>, <span class="tok-number">0x4d</span>, <span class="tok-number">0x4e</span>, <span class="tok-number">0x4f</span>, <span class="tok-number">0x50</span>, <span class="tok-number">0x51</span>,       <span class="tok-number">0x52</span>, <span class="tok-number">0x53</span>,       <span class="tok-number">0x54</span>,</span>
<span class="line" id="L1474">            <span class="tok-number">0x55</span>,       <span class="tok-number">0x56</span>, <span class="tok-number">0x58</span>, <span class="tok-number">0x78</span>, <span class="tok-number">0x79</span>, <span class="tok-number">0x7a</span>, <span class="tok-number">0x21</span>,       <span class="tok-number">0x22</span>, <span class="tok-number">0x23</span>,       <span class="tok-number">0xc2</span>,</span>
<span class="line" id="L1475">            <span class="tok-number">0xa4</span>,       <span class="tok-number">0x25</span>, <span class="tok-number">0x26</span>, <span class="tok-number">0x2f</span>, <span class="tok-number">0x3f</span>, <span class="tok-number">0x22</span>,</span>
<span class="line" id="L1476">        },</span>
<span class="line" id="L1477">    },</span>
<span class="line" id="L1478">    HuffTest{</span>
<span class="line" id="L1479">        .input = <span class="tok-str">&quot;huffman-text.input&quot;</span>,</span>
<span class="line" id="L1480">        .want = <span class="tok-str">&quot;huffman-text.{s}.expect&quot;</span>,</span>
<span class="line" id="L1481">        .want_no_input = <span class="tok-str">&quot;huffman-text.{s}.expect-noinput&quot;</span>,</span>
<span class="line" id="L1482">        .tokens = &amp;[_]token.Token{</span>
<span class="line" id="L1483">            <span class="tok-number">0x2f</span>,       <span class="tok-number">0x2f</span>,       <span class="tok-number">0x20</span>,       <span class="tok-number">0x7a</span>,       <span class="tok-number">0x69</span>, <span class="tok-number">0x67</span>, <span class="tok-number">0x20</span>, <span class="tok-number">0x76</span>,</span>
<span class="line" id="L1484">            <span class="tok-number">0x30</span>,       <span class="tok-number">0x2e</span>,       <span class="tok-number">0x31</span>,       <span class="tok-number">0x30</span>,       <span class="tok-number">0x2e</span>, <span class="tok-number">0x30</span>, <span class="tok-number">0x0a</span>, <span class="tok-number">0x2f</span>,</span>
<span class="line" id="L1485">            <span class="tok-number">0x2f</span>,       <span class="tok-number">0x20</span>,       <span class="tok-number">0x63</span>,       <span class="tok-number">0x72</span>,       <span class="tok-number">0x65</span>, <span class="tok-number">0x61</span>, <span class="tok-number">0x74</span>, <span class="tok-number">0x65</span>,</span>
<span class="line" id="L1486">            <span class="tok-number">0x20</span>,       <span class="tok-number">0x61</span>,       <span class="tok-number">0x20</span>,       <span class="tok-number">0x66</span>,       <span class="tok-number">0x69</span>, <span class="tok-number">0x6c</span>, <span class="tok-number">0x65</span>, <span class="tok-number">0x40400004</span>,</span>
<span class="line" id="L1487">            <span class="tok-number">0x6c</span>,       <span class="tok-number">0x65</span>,       <span class="tok-number">0x64</span>,       <span class="tok-number">0x20</span>,       <span class="tok-number">0x77</span>, <span class="tok-number">0x69</span>, <span class="tok-number">0x74</span>, <span class="tok-number">0x68</span>,</span>
<span class="line" id="L1488">            <span class="tok-number">0x20</span>,       <span class="tok-number">0x30</span>,       <span class="tok-number">0x78</span>,       <span class="tok-number">0x30</span>,       <span class="tok-number">0x30</span>, <span class="tok-number">0x0a</span>, <span class="tok-number">0x63</span>, <span class="tok-number">0x6f</span>,</span>
<span class="line" id="L1489">            <span class="tok-number">0x6e</span>,       <span class="tok-number">0x73</span>,       <span class="tok-number">0x74</span>,       <span class="tok-number">0x20</span>,       <span class="tok-number">0x73</span>, <span class="tok-number">0x74</span>, <span class="tok-number">0x64</span>, <span class="tok-number">0x20</span>,</span>
<span class="line" id="L1490">            <span class="tok-number">0x3d</span>,       <span class="tok-number">0x20</span>,       <span class="tok-number">0x40</span>,       <span class="tok-number">0x69</span>,       <span class="tok-number">0x6d</span>, <span class="tok-number">0x70</span>, <span class="tok-number">0x6f</span>, <span class="tok-number">0x72</span>,</span>
<span class="line" id="L1491">            <span class="tok-number">0x74</span>,       <span class="tok-number">0x28</span>,       <span class="tok-number">0x22</span>,       <span class="tok-number">0x73</span>,       <span class="tok-number">0x74</span>, <span class="tok-number">0x64</span>, <span class="tok-number">0x22</span>, <span class="tok-number">0x29</span>,</span>
<span class="line" id="L1492">            <span class="tok-number">0x3b</span>,       <span class="tok-number">0x0a</span>,       <span class="tok-number">0x0a</span>,       <span class="tok-number">0x70</span>,       <span class="tok-number">0x75</span>, <span class="tok-number">0x62</span>, <span class="tok-number">0x20</span>, <span class="tok-number">0x66</span>,</span>
<span class="line" id="L1493">            <span class="tok-number">0x6e</span>,       <span class="tok-number">0x20</span>,       <span class="tok-number">0x6d</span>,       <span class="tok-number">0x61</span>,       <span class="tok-number">0x69</span>, <span class="tok-number">0x6e</span>, <span class="tok-number">0x28</span>, <span class="tok-number">0x29</span>,</span>
<span class="line" id="L1494">            <span class="tok-number">0x20</span>,       <span class="tok-number">0x21</span>,       <span class="tok-number">0x76</span>,       <span class="tok-number">0x6f</span>,       <span class="tok-number">0x69</span>, <span class="tok-number">0x64</span>, <span class="tok-number">0x20</span>, <span class="tok-number">0x7b</span>,</span>
<span class="line" id="L1495">            <span class="tok-number">0x0a</span>,       <span class="tok-number">0x20</span>,       <span class="tok-number">0x20</span>,       <span class="tok-number">0x20</span>,       <span class="tok-number">0x20</span>, <span class="tok-number">0x76</span>, <span class="tok-number">0x61</span>, <span class="tok-number">0x72</span>,</span>
<span class="line" id="L1496">            <span class="tok-number">0x20</span>,       <span class="tok-number">0x62</span>,       <span class="tok-number">0x20</span>,       <span class="tok-number">0x3d</span>,       <span class="tok-number">0x20</span>, <span class="tok-number">0x5b</span>, <span class="tok-number">0x31</span>, <span class="tok-number">0x5d</span>,</span>
<span class="line" id="L1497">            <span class="tok-number">0x75</span>,       <span class="tok-number">0x38</span>,       <span class="tok-number">0x7b</span>,       <span class="tok-number">0x30</span>,       <span class="tok-number">0x7d</span>, <span class="tok-number">0x20</span>, <span class="tok-number">0x2a</span>, <span class="tok-number">0x2a</span>,</span>
<span class="line" id="L1498">            <span class="tok-number">0x20</span>,       <span class="tok-number">0x36</span>,       <span class="tok-number">0x35</span>,       <span class="tok-number">0x35</span>,       <span class="tok-number">0x33</span>, <span class="tok-number">0x35</span>, <span class="tok-number">0x3b</span>, <span class="tok-number">0x4080001e</span>,</span>
<span class="line" id="L1499">            <span class="tok-number">0x40c00055</span>, <span class="tok-number">0x66</span>,       <span class="tok-number">0x20</span>,       <span class="tok-number">0x3d</span>,       <span class="tok-number">0x20</span>, <span class="tok-number">0x74</span>, <span class="tok-number">0x72</span>, <span class="tok-number">0x79</span>,</span>
<span class="line" id="L1500">            <span class="tok-number">0x4040005d</span>, <span class="tok-number">0x2e</span>,       <span class="tok-number">0x66</span>,       <span class="tok-number">0x73</span>,       <span class="tok-number">0x2e</span>, <span class="tok-number">0x63</span>, <span class="tok-number">0x77</span>, <span class="tok-number">0x64</span>,</span>
<span class="line" id="L1501">            <span class="tok-number">0x28</span>,       <span class="tok-number">0x29</span>,       <span class="tok-number">0x2e</span>,       <span class="tok-number">0x40c0008f</span>, <span class="tok-number">0x46</span>, <span class="tok-number">0x69</span>, <span class="tok-number">0x6c</span>, <span class="tok-number">0x65</span>,</span>
<span class="line" id="L1502">            <span class="tok-number">0x28</span>,       <span class="tok-number">0x4080002a</span>, <span class="tok-number">0x40400000</span>, <span class="tok-number">0x22</span>,       <span class="tok-number">0x68</span>, <span class="tok-number">0x75</span>, <span class="tok-number">0x66</span>, <span class="tok-number">0x66</span>,</span>
<span class="line" id="L1503">            <span class="tok-number">0x6d</span>,       <span class="tok-number">0x61</span>,       <span class="tok-number">0x6e</span>,       <span class="tok-number">0x2d</span>,       <span class="tok-number">0x6e</span>, <span class="tok-number">0x75</span>, <span class="tok-number">0x6c</span>, <span class="tok-number">0x6c</span>,</span>
<span class="line" id="L1504">            <span class="tok-number">0x2d</span>,       <span class="tok-number">0x6d</span>,       <span class="tok-number">0x61</span>,       <span class="tok-number">0x78</span>,       <span class="tok-number">0x2e</span>, <span class="tok-number">0x69</span>, <span class="tok-number">0x6e</span>, <span class="tok-number">0x22</span>,</span>
<span class="line" id="L1505">            <span class="tok-number">0x2c</span>,       <span class="tok-number">0x4180001e</span>, <span class="tok-number">0x2e</span>,       <span class="tok-number">0x7b</span>,       <span class="tok-number">0x20</span>, <span class="tok-number">0x2e</span>, <span class="tok-number">0x72</span>, <span class="tok-number">0x65</span>,</span>
<span class="line" id="L1506">            <span class="tok-number">0x61</span>,       <span class="tok-number">0x64</span>,       <span class="tok-number">0x4080004e</span>, <span class="tok-number">0x75</span>,       <span class="tok-number">0x65</span>, <span class="tok-number">0x20</span>, <span class="tok-number">0x7d</span>, <span class="tok-number">0x40c0001a</span>,</span>
<span class="line" id="L1507">            <span class="tok-number">0x29</span>,       <span class="tok-number">0x40c0006b</span>, <span class="tok-number">0x64</span>,       <span class="tok-number">0x65</span>,       <span class="tok-number">0x66</span>, <span class="tok-number">0x65</span>, <span class="tok-number">0x72</span>, <span class="tok-number">0x20</span>,</span>
<span class="line" id="L1508">            <span class="tok-number">0x66</span>,       <span class="tok-number">0x2e</span>,       <span class="tok-number">0x63</span>,       <span class="tok-number">0x6c</span>,       <span class="tok-number">0x6f</span>, <span class="tok-number">0x73</span>, <span class="tok-number">0x65</span>, <span class="tok-number">0x28</span>,</span>
<span class="line" id="L1509">            <span class="tok-number">0x404000b6</span>, <span class="tok-number">0x40400015</span>, <span class="tok-number">0x5f</span>,       <span class="tok-number">0x4100007b</span>, <span class="tok-number">0x66</span>, <span class="tok-number">0x2e</span>, <span class="tok-number">0x77</span>, <span class="tok-number">0x72</span>,</span>
<span class="line" id="L1510">            <span class="tok-number">0x69</span>,       <span class="tok-number">0x74</span>,       <span class="tok-number">0x65</span>,       <span class="tok-number">0x41</span>,       <span class="tok-number">0x6c</span>, <span class="tok-number">0x6c</span>, <span class="tok-number">0x28</span>, <span class="tok-number">0x62</span>,</span>
<span class="line" id="L1511">            <span class="tok-number">0x5b</span>,       <span class="tok-number">0x30</span>,       <span class="tok-number">0x2e</span>,       <span class="tok-number">0x2e</span>,       <span class="tok-number">0x5d</span>, <span class="tok-number">0x29</span>, <span class="tok-number">0x3b</span>, <span class="tok-number">0x0a</span>,</span>
<span class="line" id="L1512">            <span class="tok-number">0x7d</span>,       <span class="tok-number">0x0a</span>,</span>
<span class="line" id="L1513">        },</span>
<span class="line" id="L1514">    },</span>
<span class="line" id="L1515">    HuffTest{</span>
<span class="line" id="L1516">        .input = <span class="tok-str">&quot;huffman-zero.input&quot;</span>,</span>
<span class="line" id="L1517">        .want = <span class="tok-str">&quot;huffman-zero.{s}.expect&quot;</span>,</span>
<span class="line" id="L1518">        .want_no_input = <span class="tok-str">&quot;huffman-zero.{s}.expect-noinput&quot;</span>,</span>
<span class="line" id="L1519">        .tokens = &amp;[_]token.Token{ <span class="tok-number">0x30</span>, ml, <span class="tok-number">0x4b800000</span> },</span>
<span class="line" id="L1520">    },</span>
<span class="line" id="L1521">    HuffTest{</span>
<span class="line" id="L1522">        .input = <span class="tok-str">&quot;&quot;</span>,</span>
<span class="line" id="L1523">        .want = <span class="tok-str">&quot;&quot;</span>,</span>
<span class="line" id="L1524">        .want_no_input = <span class="tok-str">&quot;null-long-match.{s}.expect-noinput&quot;</span>,</span>
<span class="line" id="L1525">        .tokens = &amp;[_]token.Token{</span>
<span class="line" id="L1526">            <span class="tok-number">0x0</span>, ml, ml, ml,         ml, ml, ml, ml, ml, ml, ml, ml, ml, ml, ml, ml, ml, ml, ml, ml,</span>
<span class="line" id="L1527">            ml,  ml, ml, ml,         ml, ml, ml, ml, ml, ml, ml, ml, ml, ml, ml, ml, ml, ml, ml, ml,</span>
<span class="line" id="L1528">            ml,  ml, ml, ml,         ml, ml, ml, ml, ml, ml, ml, ml, ml, ml, ml, ml, ml, ml, ml, ml,</span>
<span class="line" id="L1529">            ml,  ml, ml, ml,         ml, ml, ml, ml, ml, ml, ml, ml, ml, ml, ml, ml, ml, ml, ml, ml,</span>
<span class="line" id="L1530">            ml,  ml, ml, ml,         ml, ml, ml, ml, ml, ml, ml, ml, ml, ml, ml, ml, ml, ml, ml, ml,</span>
<span class="line" id="L1531">            ml,  ml, ml, ml,         ml, ml, ml, ml, ml, ml, ml, ml, ml, ml, ml, ml, ml, ml, ml, ml,</span>
<span class="line" id="L1532">            ml,  ml, ml, ml,         ml, ml, ml, ml, ml, ml, ml, ml, ml, ml, ml, ml, ml, ml, ml, ml,</span>
<span class="line" id="L1533">            ml,  ml, ml, ml,         ml, ml, ml, ml, ml, ml, ml, ml, ml, ml, ml, ml, ml, ml, ml, ml,</span>
<span class="line" id="L1534">            ml,  ml, ml, ml,         ml, ml, ml, ml, ml, ml, ml, ml, ml, ml, ml, ml, ml, ml, ml, ml,</span>
<span class="line" id="L1535">            ml,  ml, ml, ml,         ml, ml, ml, ml, ml, ml, ml, ml, ml, ml, ml, ml, ml, ml, ml, ml,</span>
<span class="line" id="L1536">            ml,  ml, ml, ml,         ml, ml, ml, ml, ml, ml, ml, ml, ml, ml, ml, ml, ml, ml, ml, ml,</span>
<span class="line" id="L1537">            ml,  ml, ml, ml,         ml, ml, ml, ml, ml, ml, ml, ml, ml, ml, ml, ml, ml, ml, ml, ml,</span>
<span class="line" id="L1538">            ml,  ml, ml, ml,         ml, ml, ml, ml, ml, ml, ml, ml, ml, ml, ml, ml, ml, ml, ml, ml,</span>
<span class="line" id="L1539">            ml,  ml, ml, ml,         ml, ml, ml, ml, ml, ml, ml, ml, ml, ml, ml, ml, ml, ml, ml, ml,</span>
<span class="line" id="L1540">            ml,  ml, ml, ml,         ml, ml, ml, ml, ml, ml, ml, ml, ml, ml, ml, ml, ml, ml, ml, ml,</span>
<span class="line" id="L1541">            ml,  ml, ml, ml,         ml, ml, ml, ml, ml, ml, ml, ml, ml, ml, ml, ml, ml, ml, ml, ml,</span>
<span class="line" id="L1542">            ml,  ml, ml, ml,         ml, ml, ml, ml, ml, ml, ml, ml, ml, ml, ml, ml, ml, ml, ml, ml,</span>
<span class="line" id="L1543">            ml,  ml, ml, ml,         ml, ml, ml, ml, ml, ml, ml, ml, ml, ml, ml, ml, ml, ml, ml, ml,</span>
<span class="line" id="L1544">            ml,  ml, ml, ml,         ml, ml, ml, ml, ml, ml, ml, ml, ml, ml, ml, ml, ml, ml, ml, ml,</span>
<span class="line" id="L1545">            ml,  ml, ml, ml,         ml, ml, ml, ml, ml, ml, ml, ml, ml, ml, ml, ml, ml, ml, ml, ml,</span>
<span class="line" id="L1546">            ml,  ml, ml, ml,         ml, ml, ml, ml, ml, ml, ml, ml, ml, ml, ml, ml, ml, ml, ml, ml,</span>
<span class="line" id="L1547">            ml,  ml, ml, ml,         ml, ml, ml, ml, ml, ml, ml, ml, ml, ml, ml, ml, ml, ml, ml, ml,</span>
<span class="line" id="L1548">            ml,  ml, ml, ml,         ml, ml, ml, ml, ml, ml, ml, ml, ml, ml, ml, ml, ml, ml, ml, ml,</span>
<span class="line" id="L1549">            ml,  ml, ml, ml,         ml, ml, ml, ml, ml, ml, ml, ml, ml, ml, ml, ml, ml, ml, ml, ml,</span>
<span class="line" id="L1550">            ml,  ml, ml, ml,         ml, ml, ml, ml, ml, ml, ml, ml, ml, ml, ml, ml, ml, ml, ml, ml,</span>
<span class="line" id="L1551">            ml,  ml, ml, ml,         ml, ml, ml, ml, ml, ml, ml, ml, ml, ml, ml, ml, ml, ml, ml, ml,</span>
<span class="line" id="L1552">            ml,  ml, ml, ml,         ml, ml, ml, ml, ml, ml, ml, ml, ml, ml, ml, ml, ml, ml, ml, ml,</span>
<span class="line" id="L1553">            ml,  ml, ml, ml,         ml, ml, ml, ml, ml, ml, ml, ml, ml, ml, ml, ml, ml, ml, ml, ml,</span>
<span class="line" id="L1554">            ml,  ml, ml, ml,         ml, ml, ml, ml, ml, ml, ml, ml, ml, ml, ml, ml, ml, ml, ml, ml,</span>
<span class="line" id="L1555">            ml,  ml, ml, ml,         ml, ml, ml, ml, ml, ml, ml, ml, ml, ml, ml, ml, ml, ml, ml, ml,</span>
<span class="line" id="L1556">            ml,  ml, ml, ml,         ml, ml, ml, ml, ml, ml, ml, ml, ml, ml, ml, ml, ml, ml, ml, ml,</span>
<span class="line" id="L1557">            ml,  ml, ml, ml,         ml, ml, ml, ml, ml, ml, ml, ml, ml, ml, ml, ml, ml, ml, ml, ml,</span>
<span class="line" id="L1558">            ml,  ml, ml, ml,         ml, ml, ml, ml, ml, ml, ml, ml, ml, ml, ml, ml, ml, ml, ml, ml,</span>
<span class="line" id="L1559">            ml,  ml, ml, ml,         ml, ml, ml, ml, ml, ml, ml, ml, ml, ml, ml, ml, ml, ml, ml, ml,</span>
<span class="line" id="L1560">            ml,  ml, ml, ml,         ml, ml, ml, ml, ml, ml, ml, ml, ml, ml, ml, ml, ml, ml, ml, ml,</span>
<span class="line" id="L1561">            ml,  ml, ml, ml,         ml, ml, ml, ml, ml, ml, ml, ml, ml, ml, ml, ml, ml, ml, ml, ml,</span>
<span class="line" id="L1562">            ml,  ml, ml, ml,         ml, ml, ml, ml, ml, ml, ml, ml, ml, ml, ml, ml, ml, ml, ml, ml,</span>
<span class="line" id="L1563">            ml,  ml, ml, ml,         ml, ml, ml, ml, ml, ml, ml, ml, ml, ml, ml, ml, ml, ml, ml, ml,</span>
<span class="line" id="L1564">            ml,  ml, ml, <span class="tok-number">0x41400000</span>,</span>
<span class="line" id="L1565">        },</span>
<span class="line" id="L1566">    },</span>
<span class="line" id="L1567">};</span>
<span class="line" id="L1568"></span>
<span class="line" id="L1569"><span class="tok-kw">const</span> TestType = <span class="tok-kw">enum</span> {</span>
<span class="line" id="L1570">    write_block,</span>
<span class="line" id="L1571">    write_dyn_block, <span class="tok-comment">// write dynamic block</span>
</span>
<span class="line" id="L1572">    write_huffman_block,</span>
<span class="line" id="L1573"></span>
<span class="line" id="L1574">    <span class="tok-kw">fn</span> <span class="tok-fn">to_s</span>(self: TestType) []<span class="tok-kw">const</span> <span class="tok-type">u8</span> {</span>
<span class="line" id="L1575">        <span class="tok-kw">return</span> <span class="tok-kw">switch</span> (self) {</span>
<span class="line" id="L1576">            .write_block =&gt; <span class="tok-str">&quot;wb&quot;</span>,</span>
<span class="line" id="L1577">            .write_dyn_block =&gt; <span class="tok-str">&quot;dyn&quot;</span>,</span>
<span class="line" id="L1578">            .write_huffman_block =&gt; <span class="tok-str">&quot;huff&quot;</span>,</span>
<span class="line" id="L1579">        };</span>
<span class="line" id="L1580">    }</span>
<span class="line" id="L1581">};</span>
<span class="line" id="L1582"></span>
<span class="line" id="L1583"><span class="tok-kw">test</span> <span class="tok-str">&quot;writeBlock&quot;</span> {</span>
<span class="line" id="L1584">    <span class="tok-comment">// tests if the writeBlock encoding has changed.</span>
</span>
<span class="line" id="L1585"></span>
<span class="line" id="L1586">    <span class="tok-kw">const</span> ttype: TestType = .write_block;</span>
<span class="line" id="L1587">    <span class="tok-kw">try</span> testBlock(writeBlockTests[<span class="tok-number">0</span>], ttype);</span>
<span class="line" id="L1588">    <span class="tok-kw">try</span> testBlock(writeBlockTests[<span class="tok-number">1</span>], ttype);</span>
<span class="line" id="L1589">    <span class="tok-kw">try</span> testBlock(writeBlockTests[<span class="tok-number">2</span>], ttype);</span>
<span class="line" id="L1590">    <span class="tok-kw">try</span> testBlock(writeBlockTests[<span class="tok-number">3</span>], ttype);</span>
<span class="line" id="L1591">    <span class="tok-kw">try</span> testBlock(writeBlockTests[<span class="tok-number">4</span>], ttype);</span>
<span class="line" id="L1592">    <span class="tok-kw">try</span> testBlock(writeBlockTests[<span class="tok-number">5</span>], ttype);</span>
<span class="line" id="L1593">    <span class="tok-kw">try</span> testBlock(writeBlockTests[<span class="tok-number">6</span>], ttype);</span>
<span class="line" id="L1594">    <span class="tok-kw">try</span> testBlock(writeBlockTests[<span class="tok-number">7</span>], ttype);</span>
<span class="line" id="L1595">    <span class="tok-kw">try</span> testBlock(writeBlockTests[<span class="tok-number">8</span>], ttype);</span>
<span class="line" id="L1596">}</span>
<span class="line" id="L1597"></span>
<span class="line" id="L1598"><span class="tok-kw">test</span> <span class="tok-str">&quot;writeBlockDynamic&quot;</span> {</span>
<span class="line" id="L1599">    <span class="tok-comment">// tests if the writeBlockDynamic encoding has changed.</span>
</span>
<span class="line" id="L1600"></span>
<span class="line" id="L1601">    <span class="tok-kw">const</span> ttype: TestType = .write_dyn_block;</span>
<span class="line" id="L1602">    <span class="tok-kw">try</span> testBlock(writeBlockTests[<span class="tok-number">0</span>], ttype);</span>
<span class="line" id="L1603">    <span class="tok-kw">try</span> testBlock(writeBlockTests[<span class="tok-number">1</span>], ttype);</span>
<span class="line" id="L1604">    <span class="tok-kw">try</span> testBlock(writeBlockTests[<span class="tok-number">2</span>], ttype);</span>
<span class="line" id="L1605">    <span class="tok-kw">try</span> testBlock(writeBlockTests[<span class="tok-number">3</span>], ttype);</span>
<span class="line" id="L1606">    <span class="tok-kw">try</span> testBlock(writeBlockTests[<span class="tok-number">4</span>], ttype);</span>
<span class="line" id="L1607">    <span class="tok-kw">try</span> testBlock(writeBlockTests[<span class="tok-number">5</span>], ttype);</span>
<span class="line" id="L1608">    <span class="tok-kw">try</span> testBlock(writeBlockTests[<span class="tok-number">6</span>], ttype);</span>
<span class="line" id="L1609">    <span class="tok-kw">try</span> testBlock(writeBlockTests[<span class="tok-number">7</span>], ttype);</span>
<span class="line" id="L1610">    <span class="tok-kw">try</span> testBlock(writeBlockTests[<span class="tok-number">8</span>], ttype);</span>
<span class="line" id="L1611">}</span>
<span class="line" id="L1612"></span>
<span class="line" id="L1613"><span class="tok-comment">// testBlock tests a block against its references,</span>
</span>
<span class="line" id="L1614"><span class="tok-comment">// or regenerate the references, if &quot;-update&quot; flag is set.</span>
</span>
<span class="line" id="L1615"><span class="tok-kw">fn</span> <span class="tok-fn">testBlock</span>(<span class="tok-kw">comptime</span> ht: HuffTest, ttype: TestType) !<span class="tok-type">void</span> {</span>
<span class="line" id="L1616">    <span class="tok-comment">// Skip wasi because it does not support std.fs.openDirAbsolute()</span>
</span>
<span class="line" id="L1617">    <span class="tok-kw">if</span> (builtin.os.tag == .wasi) <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SkipZigTest;</span>
<span class="line" id="L1618"></span>
<span class="line" id="L1619">    <span class="tok-kw">var</span> want_name: []<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L1620">    <span class="tok-kw">var</span> want_name_no_input: []<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L1621">    <span class="tok-kw">var</span> input: []<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L1622">    <span class="tok-kw">var</span> want: []<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L1623">    <span class="tok-kw">var</span> want_ni: []<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>; <span class="tok-comment">// want no input: what we expect when input is empty</span>
</span>
<span class="line" id="L1624"></span>
<span class="line" id="L1625">    <span class="tok-kw">const</span> current_dir = <span class="tok-kw">try</span> std.fs.openDirAbsolute(std.fs.path.dirname(<span class="tok-builtin">@src</span>().file).?, .{});</span>
<span class="line" id="L1626">    <span class="tok-kw">const</span> testdata_dir = <span class="tok-kw">try</span> current_dir.openDir(<span class="tok-str">&quot;testdata&quot;</span>, .{});</span>
<span class="line" id="L1627"></span>
<span class="line" id="L1628">    <span class="tok-kw">var</span> want_name_type = <span class="tok-kw">if</span> (ht.want.len == <span class="tok-number">0</span>) .{} <span class="tok-kw">else</span> .{ttype.to_s()};</span>
<span class="line" id="L1629">    want_name = <span class="tok-kw">try</span> fmt.allocPrint(testing.allocator, ht.want, want_name_type);</span>
<span class="line" id="L1630">    <span class="tok-kw">defer</span> testing.allocator.free(want_name);</span>
<span class="line" id="L1631"></span>
<span class="line" id="L1632">    <span class="tok-kw">if</span> (!mem.eql(<span class="tok-type">u8</span>, ht.input, <span class="tok-str">&quot;&quot;</span>)) {</span>
<span class="line" id="L1633">        <span class="tok-kw">const</span> in_file = <span class="tok-kw">try</span> testdata_dir.openFile(ht.input, .{});</span>
<span class="line" id="L1634">        input = <span class="tok-kw">try</span> in_file.reader().readAllAlloc(testing.allocator, math.maxInt(<span class="tok-type">usize</span>));</span>
<span class="line" id="L1635">        <span class="tok-kw">defer</span> testing.allocator.free(input);</span>
<span class="line" id="L1636"></span>
<span class="line" id="L1637">        <span class="tok-kw">const</span> want_file = <span class="tok-kw">try</span> testdata_dir.openFile(want_name, .{});</span>
<span class="line" id="L1638">        want = <span class="tok-kw">try</span> want_file.reader().readAllAlloc(testing.allocator, math.maxInt(<span class="tok-type">usize</span>));</span>
<span class="line" id="L1639">        <span class="tok-kw">defer</span> testing.allocator.free(want);</span>
<span class="line" id="L1640"></span>
<span class="line" id="L1641">        <span class="tok-kw">var</span> buf = ArrayList(<span class="tok-type">u8</span>).init(testing.allocator);</span>
<span class="line" id="L1642">        <span class="tok-kw">var</span> bw = <span class="tok-kw">try</span> huffmanBitWriter(testing.allocator, buf.writer());</span>
<span class="line" id="L1643">        <span class="tok-kw">try</span> writeToType(ttype, &amp;bw, ht.tokens, input);</span>
<span class="line" id="L1644"></span>
<span class="line" id="L1645">        <span class="tok-kw">var</span> got = buf.items;</span>
<span class="line" id="L1646">        <span class="tok-kw">try</span> expect(mem.eql(<span class="tok-type">u8</span>, got, want)); <span class="tok-comment">// expect writeBlock to yield expected result</span>
</span>
<span class="line" id="L1647"></span>
<span class="line" id="L1648">        <span class="tok-comment">// Test if the writer produces the same output after reset.</span>
</span>
<span class="line" id="L1649">        buf.deinit();</span>
<span class="line" id="L1650">        buf = ArrayList(<span class="tok-type">u8</span>).init(testing.allocator);</span>
<span class="line" id="L1651">        <span class="tok-kw">defer</span> buf.deinit();</span>
<span class="line" id="L1652"></span>
<span class="line" id="L1653">        bw.reset(buf.writer());</span>
<span class="line" id="L1654">        <span class="tok-kw">defer</span> bw.deinit();</span>
<span class="line" id="L1655"></span>
<span class="line" id="L1656">        <span class="tok-kw">try</span> writeToType(ttype, &amp;bw, ht.tokens, input);</span>
<span class="line" id="L1657">        <span class="tok-kw">try</span> bw.flush();</span>
<span class="line" id="L1658">        got = buf.items;</span>
<span class="line" id="L1659">        <span class="tok-kw">try</span> expect(mem.eql(<span class="tok-type">u8</span>, got, want)); <span class="tok-comment">// expect writeBlock to yield expected result</span>
</span>
<span class="line" id="L1660">        <span class="tok-kw">try</span> testWriterEOF(.write_block, ht.tokens, input);</span>
<span class="line" id="L1661">    }</span>
<span class="line" id="L1662"></span>
<span class="line" id="L1663">    want_name_no_input = <span class="tok-kw">try</span> fmt.allocPrint(testing.allocator, ht.want_no_input, .{ttype.to_s()});</span>
<span class="line" id="L1664">    <span class="tok-kw">defer</span> testing.allocator.free(want_name_no_input);</span>
<span class="line" id="L1665"></span>
<span class="line" id="L1666">    <span class="tok-kw">const</span> want_no_input_file = <span class="tok-kw">try</span> testdata_dir.openFile(want_name_no_input, .{});</span>
<span class="line" id="L1667">    want_ni = <span class="tok-kw">try</span> want_no_input_file.reader().readAllAlloc(testing.allocator, math.maxInt(<span class="tok-type">usize</span>));</span>
<span class="line" id="L1668">    <span class="tok-kw">defer</span> testing.allocator.free(want_ni);</span>
<span class="line" id="L1669"></span>
<span class="line" id="L1670">    <span class="tok-kw">var</span> buf = ArrayList(<span class="tok-type">u8</span>).init(testing.allocator);</span>
<span class="line" id="L1671">    <span class="tok-kw">var</span> bw = <span class="tok-kw">try</span> huffmanBitWriter(testing.allocator, buf.writer());</span>
<span class="line" id="L1672"></span>
<span class="line" id="L1673">    <span class="tok-kw">try</span> writeToType(ttype, &amp;bw, ht.tokens, <span class="tok-null">null</span>);</span>
<span class="line" id="L1674"></span>
<span class="line" id="L1675">    <span class="tok-kw">var</span> got = buf.items;</span>
<span class="line" id="L1676">    <span class="tok-kw">try</span> expect(mem.eql(<span class="tok-type">u8</span>, got, want_ni)); <span class="tok-comment">// expect writeBlock to yield expected result</span>
</span>
<span class="line" id="L1677">    <span class="tok-kw">try</span> expect(got[<span class="tok-number">0</span>] &amp; <span class="tok-number">1</span> != <span class="tok-number">1</span>); <span class="tok-comment">// expect no EOF</span>
</span>
<span class="line" id="L1678"></span>
<span class="line" id="L1679">    <span class="tok-comment">// Test if the writer produces the same output after reset.</span>
</span>
<span class="line" id="L1680">    buf.deinit();</span>
<span class="line" id="L1681">    buf = ArrayList(<span class="tok-type">u8</span>).init(testing.allocator);</span>
<span class="line" id="L1682">    <span class="tok-kw">defer</span> buf.deinit();</span>
<span class="line" id="L1683"></span>
<span class="line" id="L1684">    bw.reset(buf.writer());</span>
<span class="line" id="L1685">    <span class="tok-kw">defer</span> bw.deinit();</span>
<span class="line" id="L1686"></span>
<span class="line" id="L1687">    <span class="tok-kw">try</span> writeToType(ttype, &amp;bw, ht.tokens, <span class="tok-null">null</span>);</span>
<span class="line" id="L1688">    <span class="tok-kw">try</span> bw.flush();</span>
<span class="line" id="L1689">    got = buf.items;</span>
<span class="line" id="L1690"></span>
<span class="line" id="L1691">    <span class="tok-kw">try</span> expect(mem.eql(<span class="tok-type">u8</span>, got, want_ni)); <span class="tok-comment">// expect writeBlock to yield expected result</span>
</span>
<span class="line" id="L1692">    <span class="tok-kw">try</span> testWriterEOF(.write_block, ht.tokens, &amp;[<span class="tok-number">0</span>]<span class="tok-type">u8</span>{});</span>
<span class="line" id="L1693">}</span>
<span class="line" id="L1694"></span>
<span class="line" id="L1695"><span class="tok-kw">fn</span> <span class="tok-fn">writeToType</span>(ttype: TestType, bw: <span class="tok-kw">anytype</span>, tok: []<span class="tok-kw">const</span> token.Token, input: ?[]<span class="tok-type">u8</span>) !<span class="tok-type">void</span> {</span>
<span class="line" id="L1696">    <span class="tok-kw">switch</span> (ttype) {</span>
<span class="line" id="L1697">        .write_block =&gt; <span class="tok-kw">try</span> bw.writeBlock(tok, <span class="tok-null">false</span>, input),</span>
<span class="line" id="L1698">        .write_dyn_block =&gt; <span class="tok-kw">try</span> bw.writeBlockDynamic(tok, <span class="tok-null">false</span>, input),</span>
<span class="line" id="L1699">        <span class="tok-kw">else</span> =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L1700">    }</span>
<span class="line" id="L1701">    <span class="tok-kw">try</span> bw.flush();</span>
<span class="line" id="L1702">}</span>
<span class="line" id="L1703"></span>
<span class="line" id="L1704"><span class="tok-comment">// Tests if the written block contains an EOF marker.</span>
</span>
<span class="line" id="L1705"><span class="tok-kw">fn</span> <span class="tok-fn">testWriterEOF</span>(ttype: TestType, ht_tokens: []<span class="tok-kw">const</span> token.Token, input: []<span class="tok-type">u8</span>) !<span class="tok-type">void</span> {</span>
<span class="line" id="L1706">    <span class="tok-kw">var</span> buf = ArrayList(<span class="tok-type">u8</span>).init(testing.allocator);</span>
<span class="line" id="L1707">    <span class="tok-kw">defer</span> buf.deinit();</span>
<span class="line" id="L1708">    <span class="tok-kw">var</span> bw = <span class="tok-kw">try</span> huffmanBitWriter(testing.allocator, buf.writer());</span>
<span class="line" id="L1709">    <span class="tok-kw">defer</span> bw.deinit();</span>
<span class="line" id="L1710"></span>
<span class="line" id="L1711">    <span class="tok-kw">switch</span> (ttype) {</span>
<span class="line" id="L1712">        .write_block =&gt; <span class="tok-kw">try</span> bw.writeBlock(ht_tokens, <span class="tok-null">true</span>, input),</span>
<span class="line" id="L1713">        .write_dyn_block =&gt; <span class="tok-kw">try</span> bw.writeBlockDynamic(ht_tokens, <span class="tok-null">true</span>, input),</span>
<span class="line" id="L1714">        .write_huffman_block =&gt; <span class="tok-kw">try</span> bw.writeBlockHuff(<span class="tok-null">true</span>, input),</span>
<span class="line" id="L1715">    }</span>
<span class="line" id="L1716"></span>
<span class="line" id="L1717">    <span class="tok-kw">try</span> bw.flush();</span>
<span class="line" id="L1718"></span>
<span class="line" id="L1719">    <span class="tok-kw">var</span> b = buf.items;</span>
<span class="line" id="L1720">    <span class="tok-kw">try</span> expect(b.len &gt; <span class="tok-number">0</span>);</span>
<span class="line" id="L1721">    <span class="tok-kw">try</span> expect(b[<span class="tok-number">0</span>] &amp; <span class="tok-number">1</span> == <span class="tok-number">1</span>);</span>
<span class="line" id="L1722">}</span>
<span class="line" id="L1723"></span>
</code></pre></body>
</html>