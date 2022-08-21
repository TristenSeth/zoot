<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">    <title>leb128.zig - source view</title>
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
<pre><code><span class="line" id="L1"><span class="tok-kw">const</span> builtin = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;builtin&quot;</span>);</span>
<span class="line" id="L2"><span class="tok-kw">const</span> std = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;std&quot;</span>);</span>
<span class="line" id="L3"><span class="tok-kw">const</span> testing = std.testing;</span>
<span class="line" id="L4"></span>
<span class="line" id="L5"><span class="tok-comment">/// Read a single unsigned LEB128 value from the given reader as type T,</span></span>
<span class="line" id="L6"><span class="tok-comment">/// or error.Overflow if the value cannot fit.</span></span>
<span class="line" id="L7"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">readULEB128</span>(<span class="tok-kw">comptime</span> T: <span class="tok-type">type</span>, reader: <span class="tok-kw">anytype</span>) !T {</span>
<span class="line" id="L8">    <span class="tok-kw">const</span> U = <span class="tok-kw">if</span> (<span class="tok-builtin">@typeInfo</span>(T).Int.bits &lt; <span class="tok-number">8</span>) <span class="tok-type">u8</span> <span class="tok-kw">else</span> T;</span>
<span class="line" id="L9">    <span class="tok-kw">const</span> ShiftT = std.math.Log2Int(U);</span>
<span class="line" id="L10"></span>
<span class="line" id="L11">    <span class="tok-kw">const</span> max_group = (<span class="tok-builtin">@typeInfo</span>(U).Int.bits + <span class="tok-number">6</span>) / <span class="tok-number">7</span>;</span>
<span class="line" id="L12"></span>
<span class="line" id="L13">    <span class="tok-kw">var</span> value = <span class="tok-builtin">@as</span>(U, <span class="tok-number">0</span>);</span>
<span class="line" id="L14">    <span class="tok-kw">var</span> group = <span class="tok-builtin">@as</span>(ShiftT, <span class="tok-number">0</span>);</span>
<span class="line" id="L15"></span>
<span class="line" id="L16">    <span class="tok-kw">while</span> (group &lt; max_group) : (group += <span class="tok-number">1</span>) {</span>
<span class="line" id="L17">        <span class="tok-kw">const</span> byte = <span class="tok-kw">try</span> reader.readByte();</span>
<span class="line" id="L18">        <span class="tok-kw">var</span> temp = <span class="tok-builtin">@as</span>(U, byte &amp; <span class="tok-number">0x7f</span>);</span>
<span class="line" id="L19"></span>
<span class="line" id="L20">        <span class="tok-kw">if</span> (<span class="tok-builtin">@shlWithOverflow</span>(U, temp, group * <span class="tok-number">7</span>, &amp;temp)) <span class="tok-kw">return</span> <span class="tok-kw">error</span>.Overflow;</span>
<span class="line" id="L21"></span>
<span class="line" id="L22">        value |= temp;</span>
<span class="line" id="L23">        <span class="tok-kw">if</span> (byte &amp; <span class="tok-number">0x80</span> == <span class="tok-number">0</span>) <span class="tok-kw">break</span>;</span>
<span class="line" id="L24">    } <span class="tok-kw">else</span> {</span>
<span class="line" id="L25">        <span class="tok-kw">return</span> <span class="tok-kw">error</span>.Overflow;</span>
<span class="line" id="L26">    }</span>
<span class="line" id="L27"></span>
<span class="line" id="L28">    <span class="tok-comment">// only applies in the case that we extended to u8</span>
</span>
<span class="line" id="L29">    <span class="tok-kw">if</span> (U != T) {</span>
<span class="line" id="L30">        <span class="tok-kw">if</span> (value &gt; std.math.maxInt(T)) <span class="tok-kw">return</span> <span class="tok-kw">error</span>.Overflow;</span>
<span class="line" id="L31">    }</span>
<span class="line" id="L32"></span>
<span class="line" id="L33">    <span class="tok-kw">return</span> <span class="tok-builtin">@truncate</span>(T, value);</span>
<span class="line" id="L34">}</span>
<span class="line" id="L35"></span>
<span class="line" id="L36"><span class="tok-comment">/// Write a single unsigned integer as unsigned LEB128 to the given writer.</span></span>
<span class="line" id="L37"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">writeULEB128</span>(writer: <span class="tok-kw">anytype</span>, uint_value: <span class="tok-kw">anytype</span>) !<span class="tok-type">void</span> {</span>
<span class="line" id="L38">    <span class="tok-kw">const</span> T = <span class="tok-builtin">@TypeOf</span>(uint_value);</span>
<span class="line" id="L39">    <span class="tok-kw">const</span> U = <span class="tok-kw">if</span> (<span class="tok-builtin">@typeInfo</span>(T).Int.bits &lt; <span class="tok-number">8</span>) <span class="tok-type">u8</span> <span class="tok-kw">else</span> T;</span>
<span class="line" id="L40">    <span class="tok-kw">var</span> value = <span class="tok-builtin">@intCast</span>(U, uint_value);</span>
<span class="line" id="L41"></span>
<span class="line" id="L42">    <span class="tok-kw">while</span> (<span class="tok-null">true</span>) {</span>
<span class="line" id="L43">        <span class="tok-kw">const</span> byte = <span class="tok-builtin">@truncate</span>(<span class="tok-type">u8</span>, value &amp; <span class="tok-number">0x7f</span>);</span>
<span class="line" id="L44">        value &gt;&gt;= <span class="tok-number">7</span>;</span>
<span class="line" id="L45">        <span class="tok-kw">if</span> (value == <span class="tok-number">0</span>) {</span>
<span class="line" id="L46">            <span class="tok-kw">try</span> writer.writeByte(byte);</span>
<span class="line" id="L47">            <span class="tok-kw">break</span>;</span>
<span class="line" id="L48">        } <span class="tok-kw">else</span> {</span>
<span class="line" id="L49">            <span class="tok-kw">try</span> writer.writeByte(byte | <span class="tok-number">0x80</span>);</span>
<span class="line" id="L50">        }</span>
<span class="line" id="L51">    }</span>
<span class="line" id="L52">}</span>
<span class="line" id="L53"></span>
<span class="line" id="L54"><span class="tok-comment">/// Read a single signed LEB128 value from the given reader as type T,</span></span>
<span class="line" id="L55"><span class="tok-comment">/// or error.Overflow if the value cannot fit.</span></span>
<span class="line" id="L56"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">readILEB128</span>(<span class="tok-kw">comptime</span> T: <span class="tok-type">type</span>, reader: <span class="tok-kw">anytype</span>) !T {</span>
<span class="line" id="L57">    <span class="tok-kw">const</span> S = <span class="tok-kw">if</span> (<span class="tok-builtin">@typeInfo</span>(T).Int.bits &lt; <span class="tok-number">8</span>) <span class="tok-type">i8</span> <span class="tok-kw">else</span> T;</span>
<span class="line" id="L58">    <span class="tok-kw">const</span> U = std.meta.Int(.unsigned, <span class="tok-builtin">@typeInfo</span>(S).Int.bits);</span>
<span class="line" id="L59">    <span class="tok-kw">const</span> ShiftU = std.math.Log2Int(U);</span>
<span class="line" id="L60"></span>
<span class="line" id="L61">    <span class="tok-kw">const</span> max_group = (<span class="tok-builtin">@typeInfo</span>(U).Int.bits + <span class="tok-number">6</span>) / <span class="tok-number">7</span>;</span>
<span class="line" id="L62"></span>
<span class="line" id="L63">    <span class="tok-kw">var</span> value = <span class="tok-builtin">@as</span>(U, <span class="tok-number">0</span>);</span>
<span class="line" id="L64">    <span class="tok-kw">var</span> group = <span class="tok-builtin">@as</span>(ShiftU, <span class="tok-number">0</span>);</span>
<span class="line" id="L65"></span>
<span class="line" id="L66">    <span class="tok-kw">while</span> (group &lt; max_group) : (group += <span class="tok-number">1</span>) {</span>
<span class="line" id="L67">        <span class="tok-kw">const</span> byte = <span class="tok-kw">try</span> reader.readByte();</span>
<span class="line" id="L68">        <span class="tok-kw">var</span> temp = <span class="tok-builtin">@as</span>(U, byte &amp; <span class="tok-number">0x7f</span>);</span>
<span class="line" id="L69"></span>
<span class="line" id="L70">        <span class="tok-kw">const</span> shift = group * <span class="tok-number">7</span>;</span>
<span class="line" id="L71">        <span class="tok-kw">if</span> (<span class="tok-builtin">@shlWithOverflow</span>(U, temp, shift, &amp;temp)) {</span>
<span class="line" id="L72">            <span class="tok-comment">// Overflow is ok so long as the sign bit is set and this is the last byte</span>
</span>
<span class="line" id="L73">            <span class="tok-kw">if</span> (byte &amp; <span class="tok-number">0x80</span> != <span class="tok-number">0</span>) <span class="tok-kw">return</span> <span class="tok-kw">error</span>.Overflow;</span>
<span class="line" id="L74">            <span class="tok-kw">if</span> (<span class="tok-builtin">@bitCast</span>(S, temp) &gt;= <span class="tok-number">0</span>) <span class="tok-kw">return</span> <span class="tok-kw">error</span>.Overflow;</span>
<span class="line" id="L75"></span>
<span class="line" id="L76">            <span class="tok-comment">// and all the overflowed bits are 1</span>
</span>
<span class="line" id="L77">            <span class="tok-kw">const</span> remaining_shift = <span class="tok-builtin">@intCast</span>(<span class="tok-type">u3</span>, <span class="tok-builtin">@typeInfo</span>(U).Int.bits - <span class="tok-builtin">@as</span>(<span class="tok-type">u16</span>, shift));</span>
<span class="line" id="L78">            <span class="tok-kw">const</span> remaining_bits = <span class="tok-builtin">@bitCast</span>(<span class="tok-type">i8</span>, byte | <span class="tok-number">0x80</span>) &gt;&gt; remaining_shift;</span>
<span class="line" id="L79">            <span class="tok-kw">if</span> (remaining_bits != -<span class="tok-number">1</span>) <span class="tok-kw">return</span> <span class="tok-kw">error</span>.Overflow;</span>
<span class="line" id="L80">        } <span class="tok-kw">else</span> {</span>
<span class="line" id="L81">            <span class="tok-comment">// If we don't overflow and this is the last byte and the number being decoded</span>
</span>
<span class="line" id="L82">            <span class="tok-comment">// is negative, check that the remaining bits are 1</span>
</span>
<span class="line" id="L83">            <span class="tok-kw">if</span> ((byte &amp; <span class="tok-number">0x80</span> == <span class="tok-number">0</span>) <span class="tok-kw">and</span> (<span class="tok-builtin">@bitCast</span>(S, temp) &lt; <span class="tok-number">0</span>)) {</span>
<span class="line" id="L84">                <span class="tok-kw">const</span> remaining_shift = <span class="tok-builtin">@intCast</span>(<span class="tok-type">u3</span>, <span class="tok-builtin">@typeInfo</span>(U).Int.bits - <span class="tok-builtin">@as</span>(<span class="tok-type">u16</span>, shift));</span>
<span class="line" id="L85">                <span class="tok-kw">const</span> remaining_bits = <span class="tok-builtin">@bitCast</span>(<span class="tok-type">i8</span>, byte | <span class="tok-number">0x80</span>) &gt;&gt; remaining_shift;</span>
<span class="line" id="L86">                <span class="tok-kw">if</span> (remaining_bits != -<span class="tok-number">1</span>) <span class="tok-kw">return</span> <span class="tok-kw">error</span>.Overflow;</span>
<span class="line" id="L87">            }</span>
<span class="line" id="L88">        }</span>
<span class="line" id="L89"></span>
<span class="line" id="L90">        value |= temp;</span>
<span class="line" id="L91">        <span class="tok-kw">if</span> (byte &amp; <span class="tok-number">0x80</span> == <span class="tok-number">0</span>) {</span>
<span class="line" id="L92">            <span class="tok-kw">const</span> needs_sign_ext = group + <span class="tok-number">1</span> &lt; max_group;</span>
<span class="line" id="L93">            <span class="tok-kw">if</span> (byte &amp; <span class="tok-number">0x40</span> != <span class="tok-number">0</span> <span class="tok-kw">and</span> needs_sign_ext) {</span>
<span class="line" id="L94">                <span class="tok-kw">const</span> ones = <span class="tok-builtin">@as</span>(S, -<span class="tok-number">1</span>);</span>
<span class="line" id="L95">                value |= <span class="tok-builtin">@bitCast</span>(U, ones) &lt;&lt; (shift + <span class="tok-number">7</span>);</span>
<span class="line" id="L96">            }</span>
<span class="line" id="L97">            <span class="tok-kw">break</span>;</span>
<span class="line" id="L98">        }</span>
<span class="line" id="L99">    } <span class="tok-kw">else</span> {</span>
<span class="line" id="L100">        <span class="tok-kw">return</span> <span class="tok-kw">error</span>.Overflow;</span>
<span class="line" id="L101">    }</span>
<span class="line" id="L102"></span>
<span class="line" id="L103">    <span class="tok-kw">const</span> result = <span class="tok-builtin">@bitCast</span>(S, value);</span>
<span class="line" id="L104">    <span class="tok-comment">// Only applies if we extended to i8</span>
</span>
<span class="line" id="L105">    <span class="tok-kw">if</span> (S != T) {</span>
<span class="line" id="L106">        <span class="tok-kw">if</span> (result &gt; std.math.maxInt(T) <span class="tok-kw">or</span> result &lt; std.math.minInt(T)) <span class="tok-kw">return</span> <span class="tok-kw">error</span>.Overflow;</span>
<span class="line" id="L107">    }</span>
<span class="line" id="L108"></span>
<span class="line" id="L109">    <span class="tok-kw">return</span> <span class="tok-builtin">@truncate</span>(T, result);</span>
<span class="line" id="L110">}</span>
<span class="line" id="L111"></span>
<span class="line" id="L112"><span class="tok-comment">/// Write a single signed integer as signed LEB128 to the given writer.</span></span>
<span class="line" id="L113"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">writeILEB128</span>(writer: <span class="tok-kw">anytype</span>, int_value: <span class="tok-kw">anytype</span>) !<span class="tok-type">void</span> {</span>
<span class="line" id="L114">    <span class="tok-kw">const</span> T = <span class="tok-builtin">@TypeOf</span>(int_value);</span>
<span class="line" id="L115">    <span class="tok-kw">const</span> S = <span class="tok-kw">if</span> (<span class="tok-builtin">@typeInfo</span>(T).Int.bits &lt; <span class="tok-number">8</span>) <span class="tok-type">i8</span> <span class="tok-kw">else</span> T;</span>
<span class="line" id="L116">    <span class="tok-kw">const</span> U = std.meta.Int(.unsigned, <span class="tok-builtin">@typeInfo</span>(S).Int.bits);</span>
<span class="line" id="L117"></span>
<span class="line" id="L118">    <span class="tok-kw">var</span> value = <span class="tok-builtin">@intCast</span>(S, int_value);</span>
<span class="line" id="L119"></span>
<span class="line" id="L120">    <span class="tok-kw">while</span> (<span class="tok-null">true</span>) {</span>
<span class="line" id="L121">        <span class="tok-kw">const</span> uvalue = <span class="tok-builtin">@bitCast</span>(U, value);</span>
<span class="line" id="L122">        <span class="tok-kw">const</span> byte = <span class="tok-builtin">@truncate</span>(<span class="tok-type">u8</span>, uvalue);</span>
<span class="line" id="L123">        value &gt;&gt;= <span class="tok-number">6</span>;</span>
<span class="line" id="L124">        <span class="tok-kw">if</span> (value == -<span class="tok-number">1</span> <span class="tok-kw">or</span> value == <span class="tok-number">0</span>) {</span>
<span class="line" id="L125">            <span class="tok-kw">try</span> writer.writeByte(byte &amp; <span class="tok-number">0x7F</span>);</span>
<span class="line" id="L126">            <span class="tok-kw">break</span>;</span>
<span class="line" id="L127">        } <span class="tok-kw">else</span> {</span>
<span class="line" id="L128">            value &gt;&gt;= <span class="tok-number">1</span>;</span>
<span class="line" id="L129">            <span class="tok-kw">try</span> writer.writeByte(byte | <span class="tok-number">0x80</span>);</span>
<span class="line" id="L130">        }</span>
<span class="line" id="L131">    }</span>
<span class="line" id="L132">}</span>
<span class="line" id="L133"></span>
<span class="line" id="L134"><span class="tok-comment">/// This is an &quot;advanced&quot; function. It allows one to use a fixed amount of memory to store a</span></span>
<span class="line" id="L135"><span class="tok-comment">/// ULEB128. This defeats the entire purpose of using this data encoding; it will no longer use</span></span>
<span class="line" id="L136"><span class="tok-comment">/// fewer bytes to store smaller numbers. The advantage of using a fixed width is that it makes</span></span>
<span class="line" id="L137"><span class="tok-comment">/// fields have a predictable size and so depending on the use case this tradeoff can be worthwhile.</span></span>
<span class="line" id="L138"><span class="tok-comment">/// An example use case of this is in emitting DWARF info where one wants to make a ULEB128 field</span></span>
<span class="line" id="L139"><span class="tok-comment">/// &quot;relocatable&quot;, meaning that it becomes possible to later go back and patch the number to be a</span></span>
<span class="line" id="L140"><span class="tok-comment">/// different value without shifting all the following code.</span></span>
<span class="line" id="L141"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">writeUnsignedFixed</span>(<span class="tok-kw">comptime</span> l: <span class="tok-type">usize</span>, ptr: *[l]<span class="tok-type">u8</span>, int: std.meta.Int(.unsigned, l * <span class="tok-number">7</span>)) <span class="tok-type">void</span> {</span>
<span class="line" id="L142">    <span class="tok-kw">const</span> T = <span class="tok-builtin">@TypeOf</span>(int);</span>
<span class="line" id="L143">    <span class="tok-kw">const</span> U = <span class="tok-kw">if</span> (<span class="tok-builtin">@typeInfo</span>(T).Int.bits &lt; <span class="tok-number">8</span>) <span class="tok-type">u8</span> <span class="tok-kw">else</span> T;</span>
<span class="line" id="L144">    <span class="tok-kw">var</span> value = <span class="tok-builtin">@intCast</span>(U, int);</span>
<span class="line" id="L145"></span>
<span class="line" id="L146">    <span class="tok-kw">comptime</span> <span class="tok-kw">var</span> i = <span class="tok-number">0</span>;</span>
<span class="line" id="L147">    <span class="tok-kw">inline</span> <span class="tok-kw">while</span> (i &lt; (l - <span class="tok-number">1</span>)) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L148">        <span class="tok-kw">const</span> byte = <span class="tok-builtin">@truncate</span>(<span class="tok-type">u8</span>, value) | <span class="tok-number">0b1000_0000</span>;</span>
<span class="line" id="L149">        value &gt;&gt;= <span class="tok-number">7</span>;</span>
<span class="line" id="L150">        ptr[i] = byte;</span>
<span class="line" id="L151">    }</span>
<span class="line" id="L152">    ptr[i] = <span class="tok-builtin">@truncate</span>(<span class="tok-type">u8</span>, value);</span>
<span class="line" id="L153">}</span>
<span class="line" id="L154"></span>
<span class="line" id="L155"><span class="tok-kw">test</span> <span class="tok-str">&quot;writeUnsignedFixed&quot;</span> {</span>
<span class="line" id="L156">    {</span>
<span class="line" id="L157">        <span class="tok-kw">var</span> buf: [<span class="tok-number">4</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L158">        writeUnsignedFixed(<span class="tok-number">4</span>, &amp;buf, <span class="tok-number">0</span>);</span>
<span class="line" id="L159">        <span class="tok-kw">try</span> testing.expect((<span class="tok-kw">try</span> test_read_uleb128(<span class="tok-type">u64</span>, &amp;buf)) == <span class="tok-number">0</span>);</span>
<span class="line" id="L160">    }</span>
<span class="line" id="L161">    {</span>
<span class="line" id="L162">        <span class="tok-kw">var</span> buf: [<span class="tok-number">4</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L163">        writeUnsignedFixed(<span class="tok-number">4</span>, &amp;buf, <span class="tok-number">1</span>);</span>
<span class="line" id="L164">        <span class="tok-kw">try</span> testing.expect((<span class="tok-kw">try</span> test_read_uleb128(<span class="tok-type">u64</span>, &amp;buf)) == <span class="tok-number">1</span>);</span>
<span class="line" id="L165">    }</span>
<span class="line" id="L166">    {</span>
<span class="line" id="L167">        <span class="tok-kw">var</span> buf: [<span class="tok-number">4</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L168">        writeUnsignedFixed(<span class="tok-number">4</span>, &amp;buf, <span class="tok-number">1000</span>);</span>
<span class="line" id="L169">        <span class="tok-kw">try</span> testing.expect((<span class="tok-kw">try</span> test_read_uleb128(<span class="tok-type">u64</span>, &amp;buf)) == <span class="tok-number">1000</span>);</span>
<span class="line" id="L170">    }</span>
<span class="line" id="L171">    {</span>
<span class="line" id="L172">        <span class="tok-kw">var</span> buf: [<span class="tok-number">4</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L173">        writeUnsignedFixed(<span class="tok-number">4</span>, &amp;buf, <span class="tok-number">10000000</span>);</span>
<span class="line" id="L174">        <span class="tok-kw">try</span> testing.expect((<span class="tok-kw">try</span> test_read_uleb128(<span class="tok-type">u64</span>, &amp;buf)) == <span class="tok-number">10000000</span>);</span>
<span class="line" id="L175">    }</span>
<span class="line" id="L176">}</span>
<span class="line" id="L177"></span>
<span class="line" id="L178"><span class="tok-comment">// tests</span>
</span>
<span class="line" id="L179"><span class="tok-kw">fn</span> <span class="tok-fn">test_read_stream_ileb128</span>(<span class="tok-kw">comptime</span> T: <span class="tok-type">type</span>, encoded: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) !T {</span>
<span class="line" id="L180">    <span class="tok-kw">var</span> reader = std.io.fixedBufferStream(encoded);</span>
<span class="line" id="L181">    <span class="tok-kw">return</span> <span class="tok-kw">try</span> readILEB128(T, reader.reader());</span>
<span class="line" id="L182">}</span>
<span class="line" id="L183"></span>
<span class="line" id="L184"><span class="tok-kw">fn</span> <span class="tok-fn">test_read_stream_uleb128</span>(<span class="tok-kw">comptime</span> T: <span class="tok-type">type</span>, encoded: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) !T {</span>
<span class="line" id="L185">    <span class="tok-kw">var</span> reader = std.io.fixedBufferStream(encoded);</span>
<span class="line" id="L186">    <span class="tok-kw">return</span> <span class="tok-kw">try</span> readULEB128(T, reader.reader());</span>
<span class="line" id="L187">}</span>
<span class="line" id="L188"></span>
<span class="line" id="L189"><span class="tok-kw">fn</span> <span class="tok-fn">test_read_ileb128</span>(<span class="tok-kw">comptime</span> T: <span class="tok-type">type</span>, encoded: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) !T {</span>
<span class="line" id="L190">    <span class="tok-kw">var</span> reader = std.io.fixedBufferStream(encoded);</span>
<span class="line" id="L191">    <span class="tok-kw">const</span> v1 = <span class="tok-kw">try</span> readILEB128(T, reader.reader());</span>
<span class="line" id="L192">    <span class="tok-kw">return</span> v1;</span>
<span class="line" id="L193">}</span>
<span class="line" id="L194"></span>
<span class="line" id="L195"><span class="tok-kw">fn</span> <span class="tok-fn">test_read_uleb128</span>(<span class="tok-kw">comptime</span> T: <span class="tok-type">type</span>, encoded: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) !T {</span>
<span class="line" id="L196">    <span class="tok-kw">var</span> reader = std.io.fixedBufferStream(encoded);</span>
<span class="line" id="L197">    <span class="tok-kw">const</span> v1 = <span class="tok-kw">try</span> readULEB128(T, reader.reader());</span>
<span class="line" id="L198">    <span class="tok-kw">return</span> v1;</span>
<span class="line" id="L199">}</span>
<span class="line" id="L200"></span>
<span class="line" id="L201"><span class="tok-kw">fn</span> <span class="tok-fn">test_read_ileb128_seq</span>(<span class="tok-kw">comptime</span> T: <span class="tok-type">type</span>, <span class="tok-kw">comptime</span> N: <span class="tok-type">usize</span>, encoded: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) !<span class="tok-type">void</span> {</span>
<span class="line" id="L202">    <span class="tok-kw">var</span> reader = std.io.fixedBufferStream(encoded);</span>
<span class="line" id="L203">    <span class="tok-kw">var</span> i: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L204">    <span class="tok-kw">while</span> (i &lt; N) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L205">        _ = <span class="tok-kw">try</span> readILEB128(T, reader.reader());</span>
<span class="line" id="L206">    }</span>
<span class="line" id="L207">}</span>
<span class="line" id="L208"></span>
<span class="line" id="L209"><span class="tok-kw">fn</span> <span class="tok-fn">test_read_uleb128_seq</span>(<span class="tok-kw">comptime</span> T: <span class="tok-type">type</span>, <span class="tok-kw">comptime</span> N: <span class="tok-type">usize</span>, encoded: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) !<span class="tok-type">void</span> {</span>
<span class="line" id="L210">    <span class="tok-kw">var</span> reader = std.io.fixedBufferStream(encoded);</span>
<span class="line" id="L211">    <span class="tok-kw">var</span> i: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L212">    <span class="tok-kw">while</span> (i &lt; N) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L213">        _ = <span class="tok-kw">try</span> readULEB128(T, reader.reader());</span>
<span class="line" id="L214">    }</span>
<span class="line" id="L215">}</span>
<span class="line" id="L216"></span>
<span class="line" id="L217"><span class="tok-kw">test</span> <span class="tok-str">&quot;deserialize signed LEB128&quot;</span> {</span>
<span class="line" id="L218">    <span class="tok-comment">// Truncated</span>
</span>
<span class="line" id="L219">    <span class="tok-kw">try</span> testing.expectError(<span class="tok-kw">error</span>.EndOfStream, test_read_stream_ileb128(<span class="tok-type">i64</span>, <span class="tok-str">&quot;\x80&quot;</span>));</span>
<span class="line" id="L220"></span>
<span class="line" id="L221">    <span class="tok-comment">// Overflow</span>
</span>
<span class="line" id="L222">    <span class="tok-kw">try</span> testing.expectError(<span class="tok-kw">error</span>.Overflow, test_read_ileb128(<span class="tok-type">i8</span>, <span class="tok-str">&quot;\x80\x80\x40&quot;</span>));</span>
<span class="line" id="L223">    <span class="tok-kw">try</span> testing.expectError(<span class="tok-kw">error</span>.Overflow, test_read_ileb128(<span class="tok-type">i16</span>, <span class="tok-str">&quot;\x80\x80\x80\x40&quot;</span>));</span>
<span class="line" id="L224">    <span class="tok-kw">try</span> testing.expectError(<span class="tok-kw">error</span>.Overflow, test_read_ileb128(<span class="tok-type">i32</span>, <span class="tok-str">&quot;\x80\x80\x80\x80\x40&quot;</span>));</span>
<span class="line" id="L225">    <span class="tok-kw">try</span> testing.expectError(<span class="tok-kw">error</span>.Overflow, test_read_ileb128(<span class="tok-type">i64</span>, <span class="tok-str">&quot;\x80\x80\x80\x80\x80\x80\x80\x80\x80\x40&quot;</span>));</span>
<span class="line" id="L226">    <span class="tok-kw">try</span> testing.expectError(<span class="tok-kw">error</span>.Overflow, test_read_ileb128(<span class="tok-type">i8</span>, <span class="tok-str">&quot;\xff\x7e&quot;</span>));</span>
<span class="line" id="L227">    <span class="tok-kw">try</span> testing.expectError(<span class="tok-kw">error</span>.Overflow, test_read_ileb128(<span class="tok-type">i32</span>, <span class="tok-str">&quot;\x80\x80\x80\x80\x08&quot;</span>));</span>
<span class="line" id="L228">    <span class="tok-kw">try</span> testing.expectError(<span class="tok-kw">error</span>.Overflow, test_read_ileb128(<span class="tok-type">i64</span>, <span class="tok-str">&quot;\x80\x80\x80\x80\x80\x80\x80\x80\x80\x01&quot;</span>));</span>
<span class="line" id="L229"></span>
<span class="line" id="L230">    <span class="tok-comment">// Decode SLEB128</span>
</span>
<span class="line" id="L231">    <span class="tok-kw">try</span> testing.expect((<span class="tok-kw">try</span> test_read_ileb128(<span class="tok-type">i64</span>, <span class="tok-str">&quot;\x00&quot;</span>)) == <span class="tok-number">0</span>);</span>
<span class="line" id="L232">    <span class="tok-kw">try</span> testing.expect((<span class="tok-kw">try</span> test_read_ileb128(<span class="tok-type">i64</span>, <span class="tok-str">&quot;\x01&quot;</span>)) == <span class="tok-number">1</span>);</span>
<span class="line" id="L233">    <span class="tok-kw">try</span> testing.expect((<span class="tok-kw">try</span> test_read_ileb128(<span class="tok-type">i64</span>, <span class="tok-str">&quot;\x3f&quot;</span>)) == <span class="tok-number">63</span>);</span>
<span class="line" id="L234">    <span class="tok-kw">try</span> testing.expect((<span class="tok-kw">try</span> test_read_ileb128(<span class="tok-type">i64</span>, <span class="tok-str">&quot;\x40&quot;</span>)) == -<span class="tok-number">64</span>);</span>
<span class="line" id="L235">    <span class="tok-kw">try</span> testing.expect((<span class="tok-kw">try</span> test_read_ileb128(<span class="tok-type">i64</span>, <span class="tok-str">&quot;\x41&quot;</span>)) == -<span class="tok-number">63</span>);</span>
<span class="line" id="L236">    <span class="tok-kw">try</span> testing.expect((<span class="tok-kw">try</span> test_read_ileb128(<span class="tok-type">i64</span>, <span class="tok-str">&quot;\x7f&quot;</span>)) == -<span class="tok-number">1</span>);</span>
<span class="line" id="L237">    <span class="tok-kw">try</span> testing.expect((<span class="tok-kw">try</span> test_read_ileb128(<span class="tok-type">i64</span>, <span class="tok-str">&quot;\x80\x01&quot;</span>)) == <span class="tok-number">128</span>);</span>
<span class="line" id="L238">    <span class="tok-kw">try</span> testing.expect((<span class="tok-kw">try</span> test_read_ileb128(<span class="tok-type">i64</span>, <span class="tok-str">&quot;\x81\x01&quot;</span>)) == <span class="tok-number">129</span>);</span>
<span class="line" id="L239">    <span class="tok-kw">try</span> testing.expect((<span class="tok-kw">try</span> test_read_ileb128(<span class="tok-type">i64</span>, <span class="tok-str">&quot;\xff\x7e&quot;</span>)) == -<span class="tok-number">129</span>);</span>
<span class="line" id="L240">    <span class="tok-kw">try</span> testing.expect((<span class="tok-kw">try</span> test_read_ileb128(<span class="tok-type">i64</span>, <span class="tok-str">&quot;\x80\x7f&quot;</span>)) == -<span class="tok-number">128</span>);</span>
<span class="line" id="L241">    <span class="tok-kw">try</span> testing.expect((<span class="tok-kw">try</span> test_read_ileb128(<span class="tok-type">i64</span>, <span class="tok-str">&quot;\x81\x7f&quot;</span>)) == -<span class="tok-number">127</span>);</span>
<span class="line" id="L242">    <span class="tok-kw">try</span> testing.expect((<span class="tok-kw">try</span> test_read_ileb128(<span class="tok-type">i64</span>, <span class="tok-str">&quot;\xc0\x00&quot;</span>)) == <span class="tok-number">64</span>);</span>
<span class="line" id="L243">    <span class="tok-kw">try</span> testing.expect((<span class="tok-kw">try</span> test_read_ileb128(<span class="tok-type">i64</span>, <span class="tok-str">&quot;\xc7\x9f\x7f&quot;</span>)) == -<span class="tok-number">12345</span>);</span>
<span class="line" id="L244">    <span class="tok-kw">try</span> testing.expect((<span class="tok-kw">try</span> test_read_ileb128(<span class="tok-type">i8</span>, <span class="tok-str">&quot;\xff\x7f&quot;</span>)) == -<span class="tok-number">1</span>);</span>
<span class="line" id="L245">    <span class="tok-kw">try</span> testing.expect((<span class="tok-kw">try</span> test_read_ileb128(<span class="tok-type">i16</span>, <span class="tok-str">&quot;\xff\xff\x7f&quot;</span>)) == -<span class="tok-number">1</span>);</span>
<span class="line" id="L246">    <span class="tok-kw">try</span> testing.expect((<span class="tok-kw">try</span> test_read_ileb128(<span class="tok-type">i32</span>, <span class="tok-str">&quot;\xff\xff\xff\xff\x7f&quot;</span>)) == -<span class="tok-number">1</span>);</span>
<span class="line" id="L247">    <span class="tok-kw">try</span> testing.expect((<span class="tok-kw">try</span> test_read_ileb128(<span class="tok-type">i32</span>, <span class="tok-str">&quot;\x80\x80\x80\x80\x78&quot;</span>)) == -<span class="tok-number">0x80000000</span>);</span>
<span class="line" id="L248">    <span class="tok-kw">try</span> testing.expect((<span class="tok-kw">try</span> test_read_ileb128(<span class="tok-type">i64</span>, <span class="tok-str">&quot;\x80\x80\x80\x80\x80\x80\x80\x80\x80\x7f&quot;</span>)) == <span class="tok-builtin">@bitCast</span>(<span class="tok-type">i64</span>, <span class="tok-builtin">@intCast</span>(<span class="tok-type">u64</span>, <span class="tok-number">0x8000000000000000</span>)));</span>
<span class="line" id="L249">    <span class="tok-kw">try</span> testing.expect((<span class="tok-kw">try</span> test_read_ileb128(<span class="tok-type">i64</span>, <span class="tok-str">&quot;\x80\x80\x80\x80\x80\x80\x80\x80\x40&quot;</span>)) == -<span class="tok-number">0x4000000000000000</span>);</span>
<span class="line" id="L250">    <span class="tok-kw">try</span> testing.expect((<span class="tok-kw">try</span> test_read_ileb128(<span class="tok-type">i64</span>, <span class="tok-str">&quot;\x80\x80\x80\x80\x80\x80\x80\x80\x80\x7f&quot;</span>)) == -<span class="tok-number">0x8000000000000000</span>);</span>
<span class="line" id="L251"></span>
<span class="line" id="L252">    <span class="tok-comment">// Decode unnormalized SLEB128 with extra padding bytes.</span>
</span>
<span class="line" id="L253">    <span class="tok-kw">try</span> testing.expect((<span class="tok-kw">try</span> test_read_ileb128(<span class="tok-type">i64</span>, <span class="tok-str">&quot;\x80\x00&quot;</span>)) == <span class="tok-number">0</span>);</span>
<span class="line" id="L254">    <span class="tok-kw">try</span> testing.expect((<span class="tok-kw">try</span> test_read_ileb128(<span class="tok-type">i64</span>, <span class="tok-str">&quot;\x80\x80\x00&quot;</span>)) == <span class="tok-number">0</span>);</span>
<span class="line" id="L255">    <span class="tok-kw">try</span> testing.expect((<span class="tok-kw">try</span> test_read_ileb128(<span class="tok-type">i64</span>, <span class="tok-str">&quot;\xff\x00&quot;</span>)) == <span class="tok-number">0x7f</span>);</span>
<span class="line" id="L256">    <span class="tok-kw">try</span> testing.expect((<span class="tok-kw">try</span> test_read_ileb128(<span class="tok-type">i64</span>, <span class="tok-str">&quot;\xff\x80\x00&quot;</span>)) == <span class="tok-number">0x7f</span>);</span>
<span class="line" id="L257">    <span class="tok-kw">try</span> testing.expect((<span class="tok-kw">try</span> test_read_ileb128(<span class="tok-type">i64</span>, <span class="tok-str">&quot;\x80\x81\x00&quot;</span>)) == <span class="tok-number">0x80</span>);</span>
<span class="line" id="L258">    <span class="tok-kw">try</span> testing.expect((<span class="tok-kw">try</span> test_read_ileb128(<span class="tok-type">i64</span>, <span class="tok-str">&quot;\x80\x81\x80\x00&quot;</span>)) == <span class="tok-number">0x80</span>);</span>
<span class="line" id="L259"></span>
<span class="line" id="L260">    <span class="tok-comment">// Decode sequence of SLEB128 values</span>
</span>
<span class="line" id="L261">    <span class="tok-kw">try</span> test_read_ileb128_seq(<span class="tok-type">i64</span>, <span class="tok-number">4</span>, <span class="tok-str">&quot;\x81\x01\x3f\x80\x7f\x80\x80\x80\x00&quot;</span>);</span>
<span class="line" id="L262">}</span>
<span class="line" id="L263"></span>
<span class="line" id="L264"><span class="tok-kw">test</span> <span class="tok-str">&quot;deserialize unsigned LEB128&quot;</span> {</span>
<span class="line" id="L265">    <span class="tok-comment">// Truncated</span>
</span>
<span class="line" id="L266">    <span class="tok-kw">try</span> testing.expectError(<span class="tok-kw">error</span>.EndOfStream, test_read_stream_uleb128(<span class="tok-type">u64</span>, <span class="tok-str">&quot;\x80&quot;</span>));</span>
<span class="line" id="L267"></span>
<span class="line" id="L268">    <span class="tok-comment">// Overflow</span>
</span>
<span class="line" id="L269">    <span class="tok-kw">try</span> testing.expectError(<span class="tok-kw">error</span>.Overflow, test_read_uleb128(<span class="tok-type">u8</span>, <span class="tok-str">&quot;\x80\x02&quot;</span>));</span>
<span class="line" id="L270">    <span class="tok-kw">try</span> testing.expectError(<span class="tok-kw">error</span>.Overflow, test_read_uleb128(<span class="tok-type">u8</span>, <span class="tok-str">&quot;\x80\x80\x40&quot;</span>));</span>
<span class="line" id="L271">    <span class="tok-kw">try</span> testing.expectError(<span class="tok-kw">error</span>.Overflow, test_read_uleb128(<span class="tok-type">u16</span>, <span class="tok-str">&quot;\x80\x80\x84&quot;</span>));</span>
<span class="line" id="L272">    <span class="tok-kw">try</span> testing.expectError(<span class="tok-kw">error</span>.Overflow, test_read_uleb128(<span class="tok-type">u16</span>, <span class="tok-str">&quot;\x80\x80\x80\x40&quot;</span>));</span>
<span class="line" id="L273">    <span class="tok-kw">try</span> testing.expectError(<span class="tok-kw">error</span>.Overflow, test_read_uleb128(<span class="tok-type">u32</span>, <span class="tok-str">&quot;\x80\x80\x80\x80\x90&quot;</span>));</span>
<span class="line" id="L274">    <span class="tok-kw">try</span> testing.expectError(<span class="tok-kw">error</span>.Overflow, test_read_uleb128(<span class="tok-type">u32</span>, <span class="tok-str">&quot;\x80\x80\x80\x80\x40&quot;</span>));</span>
<span class="line" id="L275">    <span class="tok-kw">try</span> testing.expectError(<span class="tok-kw">error</span>.Overflow, test_read_uleb128(<span class="tok-type">u64</span>, <span class="tok-str">&quot;\x80\x80\x80\x80\x80\x80\x80\x80\x80\x40&quot;</span>));</span>
<span class="line" id="L276"></span>
<span class="line" id="L277">    <span class="tok-comment">// Decode ULEB128</span>
</span>
<span class="line" id="L278">    <span class="tok-kw">try</span> testing.expect((<span class="tok-kw">try</span> test_read_uleb128(<span class="tok-type">u64</span>, <span class="tok-str">&quot;\x00&quot;</span>)) == <span class="tok-number">0</span>);</span>
<span class="line" id="L279">    <span class="tok-kw">try</span> testing.expect((<span class="tok-kw">try</span> test_read_uleb128(<span class="tok-type">u64</span>, <span class="tok-str">&quot;\x01&quot;</span>)) == <span class="tok-number">1</span>);</span>
<span class="line" id="L280">    <span class="tok-kw">try</span> testing.expect((<span class="tok-kw">try</span> test_read_uleb128(<span class="tok-type">u64</span>, <span class="tok-str">&quot;\x3f&quot;</span>)) == <span class="tok-number">63</span>);</span>
<span class="line" id="L281">    <span class="tok-kw">try</span> testing.expect((<span class="tok-kw">try</span> test_read_uleb128(<span class="tok-type">u64</span>, <span class="tok-str">&quot;\x40&quot;</span>)) == <span class="tok-number">64</span>);</span>
<span class="line" id="L282">    <span class="tok-kw">try</span> testing.expect((<span class="tok-kw">try</span> test_read_uleb128(<span class="tok-type">u64</span>, <span class="tok-str">&quot;\x7f&quot;</span>)) == <span class="tok-number">0x7f</span>);</span>
<span class="line" id="L283">    <span class="tok-kw">try</span> testing.expect((<span class="tok-kw">try</span> test_read_uleb128(<span class="tok-type">u64</span>, <span class="tok-str">&quot;\x80\x01&quot;</span>)) == <span class="tok-number">0x80</span>);</span>
<span class="line" id="L284">    <span class="tok-kw">try</span> testing.expect((<span class="tok-kw">try</span> test_read_uleb128(<span class="tok-type">u64</span>, <span class="tok-str">&quot;\x81\x01&quot;</span>)) == <span class="tok-number">0x81</span>);</span>
<span class="line" id="L285">    <span class="tok-kw">try</span> testing.expect((<span class="tok-kw">try</span> test_read_uleb128(<span class="tok-type">u64</span>, <span class="tok-str">&quot;\x90\x01&quot;</span>)) == <span class="tok-number">0x90</span>);</span>
<span class="line" id="L286">    <span class="tok-kw">try</span> testing.expect((<span class="tok-kw">try</span> test_read_uleb128(<span class="tok-type">u64</span>, <span class="tok-str">&quot;\xff\x01&quot;</span>)) == <span class="tok-number">0xff</span>);</span>
<span class="line" id="L287">    <span class="tok-kw">try</span> testing.expect((<span class="tok-kw">try</span> test_read_uleb128(<span class="tok-type">u64</span>, <span class="tok-str">&quot;\x80\x02&quot;</span>)) == <span class="tok-number">0x100</span>);</span>
<span class="line" id="L288">    <span class="tok-kw">try</span> testing.expect((<span class="tok-kw">try</span> test_read_uleb128(<span class="tok-type">u64</span>, <span class="tok-str">&quot;\x81\x02&quot;</span>)) == <span class="tok-number">0x101</span>);</span>
<span class="line" id="L289">    <span class="tok-kw">try</span> testing.expect((<span class="tok-kw">try</span> test_read_uleb128(<span class="tok-type">u64</span>, <span class="tok-str">&quot;\x80\xc1\x80\x80\x10&quot;</span>)) == <span class="tok-number">4294975616</span>);</span>
<span class="line" id="L290">    <span class="tok-kw">try</span> testing.expect((<span class="tok-kw">try</span> test_read_uleb128(<span class="tok-type">u64</span>, <span class="tok-str">&quot;\x80\x80\x80\x80\x80\x80\x80\x80\x80\x01&quot;</span>)) == <span class="tok-number">0x8000000000000000</span>);</span>
<span class="line" id="L291"></span>
<span class="line" id="L292">    <span class="tok-comment">// Decode ULEB128 with extra padding bytes</span>
</span>
<span class="line" id="L293">    <span class="tok-kw">try</span> testing.expect((<span class="tok-kw">try</span> test_read_uleb128(<span class="tok-type">u64</span>, <span class="tok-str">&quot;\x80\x00&quot;</span>)) == <span class="tok-number">0</span>);</span>
<span class="line" id="L294">    <span class="tok-kw">try</span> testing.expect((<span class="tok-kw">try</span> test_read_uleb128(<span class="tok-type">u64</span>, <span class="tok-str">&quot;\x80\x80\x00&quot;</span>)) == <span class="tok-number">0</span>);</span>
<span class="line" id="L295">    <span class="tok-kw">try</span> testing.expect((<span class="tok-kw">try</span> test_read_uleb128(<span class="tok-type">u64</span>, <span class="tok-str">&quot;\xff\x00&quot;</span>)) == <span class="tok-number">0x7f</span>);</span>
<span class="line" id="L296">    <span class="tok-kw">try</span> testing.expect((<span class="tok-kw">try</span> test_read_uleb128(<span class="tok-type">u64</span>, <span class="tok-str">&quot;\xff\x80\x00&quot;</span>)) == <span class="tok-number">0x7f</span>);</span>
<span class="line" id="L297">    <span class="tok-kw">try</span> testing.expect((<span class="tok-kw">try</span> test_read_uleb128(<span class="tok-type">u64</span>, <span class="tok-str">&quot;\x80\x81\x00&quot;</span>)) == <span class="tok-number">0x80</span>);</span>
<span class="line" id="L298">    <span class="tok-kw">try</span> testing.expect((<span class="tok-kw">try</span> test_read_uleb128(<span class="tok-type">u64</span>, <span class="tok-str">&quot;\x80\x81\x80\x00&quot;</span>)) == <span class="tok-number">0x80</span>);</span>
<span class="line" id="L299"></span>
<span class="line" id="L300">    <span class="tok-comment">// Decode sequence of ULEB128 values</span>
</span>
<span class="line" id="L301">    <span class="tok-kw">try</span> test_read_uleb128_seq(<span class="tok-type">u64</span>, <span class="tok-number">4</span>, <span class="tok-str">&quot;\x81\x01\x3f\x80\x7f\x80\x80\x80\x00&quot;</span>);</span>
<span class="line" id="L302">}</span>
<span class="line" id="L303"></span>
<span class="line" id="L304"><span class="tok-kw">fn</span> <span class="tok-fn">test_write_leb128</span>(value: <span class="tok-kw">anytype</span>) !<span class="tok-type">void</span> {</span>
<span class="line" id="L305">    <span class="tok-kw">const</span> T = <span class="tok-builtin">@TypeOf</span>(value);</span>
<span class="line" id="L306">    <span class="tok-kw">const</span> signedness = <span class="tok-builtin">@typeInfo</span>(T).Int.signedness;</span>
<span class="line" id="L307">    <span class="tok-kw">const</span> t_signed = signedness == .signed;</span>
<span class="line" id="L308"></span>
<span class="line" id="L309">    <span class="tok-kw">const</span> writeStream = <span class="tok-kw">if</span> (t_signed) writeILEB128 <span class="tok-kw">else</span> writeULEB128;</span>
<span class="line" id="L310">    <span class="tok-kw">const</span> readStream = <span class="tok-kw">if</span> (t_signed) readILEB128 <span class="tok-kw">else</span> readULEB128;</span>
<span class="line" id="L311"></span>
<span class="line" id="L312">    <span class="tok-comment">// decode to a larger bit size too, to ensure sign extension</span>
</span>
<span class="line" id="L313">    <span class="tok-comment">// is working as expected</span>
</span>
<span class="line" id="L314">    <span class="tok-kw">const</span> larger_type_bits = ((<span class="tok-builtin">@typeInfo</span>(T).Int.bits + <span class="tok-number">8</span>) / <span class="tok-number">8</span>) * <span class="tok-number">8</span>;</span>
<span class="line" id="L315">    <span class="tok-kw">const</span> B = std.meta.Int(signedness, larger_type_bits);</span>
<span class="line" id="L316"></span>
<span class="line" id="L317">    <span class="tok-kw">const</span> bytes_needed = bn: {</span>
<span class="line" id="L318">        <span class="tok-kw">if</span> (<span class="tok-builtin">@typeInfo</span>(T).Int.bits &lt;= <span class="tok-number">7</span>) <span class="tok-kw">break</span> :bn <span class="tok-builtin">@as</span>(<span class="tok-type">u16</span>, <span class="tok-number">1</span>);</span>
<span class="line" id="L319"></span>
<span class="line" id="L320">        <span class="tok-kw">const</span> unused_bits = <span class="tok-kw">if</span> (value &lt; <span class="tok-number">0</span>) <span class="tok-builtin">@clz</span>(T, ~value) <span class="tok-kw">else</span> <span class="tok-builtin">@clz</span>(T, value);</span>
<span class="line" id="L321">        <span class="tok-kw">const</span> used_bits: <span class="tok-type">u16</span> = (<span class="tok-builtin">@typeInfo</span>(T).Int.bits - unused_bits) + <span class="tok-builtin">@boolToInt</span>(t_signed);</span>
<span class="line" id="L322">        <span class="tok-kw">if</span> (used_bits &lt;= <span class="tok-number">7</span>) <span class="tok-kw">break</span> :bn <span class="tok-builtin">@as</span>(<span class="tok-type">u16</span>, <span class="tok-number">1</span>);</span>
<span class="line" id="L323">        <span class="tok-kw">break</span> :bn ((used_bits + <span class="tok-number">6</span>) / <span class="tok-number">7</span>);</span>
<span class="line" id="L324">    };</span>
<span class="line" id="L325"></span>
<span class="line" id="L326">    <span class="tok-kw">const</span> max_groups = <span class="tok-kw">if</span> (<span class="tok-builtin">@typeInfo</span>(T).Int.bits == <span class="tok-number">0</span>) <span class="tok-number">1</span> <span class="tok-kw">else</span> (<span class="tok-builtin">@typeInfo</span>(T).Int.bits + <span class="tok-number">6</span>) / <span class="tok-number">7</span>;</span>
<span class="line" id="L327"></span>
<span class="line" id="L328">    <span class="tok-kw">var</span> buf: [max_groups]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L329">    <span class="tok-kw">var</span> fbs = std.io.fixedBufferStream(&amp;buf);</span>
<span class="line" id="L330"></span>
<span class="line" id="L331">    <span class="tok-comment">// stream write</span>
</span>
<span class="line" id="L332">    <span class="tok-kw">try</span> writeStream(fbs.writer(), value);</span>
<span class="line" id="L333">    <span class="tok-kw">const</span> w1_pos = fbs.pos;</span>
<span class="line" id="L334">    <span class="tok-kw">try</span> testing.expect(w1_pos == bytes_needed);</span>
<span class="line" id="L335"></span>
<span class="line" id="L336">    <span class="tok-comment">// stream read</span>
</span>
<span class="line" id="L337">    fbs.pos = <span class="tok-number">0</span>;</span>
<span class="line" id="L338">    <span class="tok-kw">const</span> sr = <span class="tok-kw">try</span> readStream(T, fbs.reader());</span>
<span class="line" id="L339">    <span class="tok-kw">try</span> testing.expect(fbs.pos == w1_pos);</span>
<span class="line" id="L340">    <span class="tok-kw">try</span> testing.expect(sr == value);</span>
<span class="line" id="L341"></span>
<span class="line" id="L342">    <span class="tok-comment">// bigger type stream read</span>
</span>
<span class="line" id="L343">    fbs.pos = <span class="tok-number">0</span>;</span>
<span class="line" id="L344">    <span class="tok-kw">const</span> bsr = <span class="tok-kw">try</span> readStream(B, fbs.reader());</span>
<span class="line" id="L345">    <span class="tok-kw">try</span> testing.expect(fbs.pos == w1_pos);</span>
<span class="line" id="L346">    <span class="tok-kw">try</span> testing.expect(bsr == value);</span>
<span class="line" id="L347">}</span>
<span class="line" id="L348"></span>
<span class="line" id="L349"><span class="tok-kw">test</span> <span class="tok-str">&quot;serialize unsigned LEB128&quot;</span> {</span>
<span class="line" id="L350">    <span class="tok-kw">if</span> ((builtin.zig_backend == .stage1 <span class="tok-kw">or</span> builtin.zig_backend == .stage2_llvm) <span class="tok-kw">and</span></span>
<span class="line" id="L351">        builtin.cpu.arch == .riscv64)</span>
<span class="line" id="L352">    {</span>
<span class="line" id="L353">        <span class="tok-comment">// https://github.com/ziglang/zig/issues/12031</span>
</span>
<span class="line" id="L354">        <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SkipZigTest;</span>
<span class="line" id="L355">    }</span>
<span class="line" id="L356"></span>
<span class="line" id="L357">    <span class="tok-kw">const</span> max_bits = <span class="tok-number">18</span>;</span>
<span class="line" id="L358"></span>
<span class="line" id="L359">    <span class="tok-kw">comptime</span> <span class="tok-kw">var</span> t = <span class="tok-number">0</span>;</span>
<span class="line" id="L360">    <span class="tok-kw">inline</span> <span class="tok-kw">while</span> (t &lt;= max_bits) : (t += <span class="tok-number">1</span>) {</span>
<span class="line" id="L361">        <span class="tok-kw">const</span> T = std.meta.Int(.unsigned, t);</span>
<span class="line" id="L362">        <span class="tok-kw">const</span> min = std.math.minInt(T);</span>
<span class="line" id="L363">        <span class="tok-kw">const</span> max = std.math.maxInt(T);</span>
<span class="line" id="L364">        <span class="tok-kw">var</span> i = <span class="tok-builtin">@as</span>(std.meta.Int(.unsigned, <span class="tok-builtin">@typeInfo</span>(T).Int.bits + <span class="tok-number">1</span>), min);</span>
<span class="line" id="L365"></span>
<span class="line" id="L366">        <span class="tok-kw">while</span> (i &lt;= max) : (i += <span class="tok-number">1</span>) <span class="tok-kw">try</span> test_write_leb128(<span class="tok-builtin">@intCast</span>(T, i));</span>
<span class="line" id="L367">    }</span>
<span class="line" id="L368">}</span>
<span class="line" id="L369"></span>
<span class="line" id="L370"><span class="tok-kw">test</span> <span class="tok-str">&quot;serialize signed LEB128&quot;</span> {</span>
<span class="line" id="L371">    <span class="tok-kw">if</span> ((builtin.zig_backend == .stage1 <span class="tok-kw">or</span> builtin.zig_backend == .stage2_llvm) <span class="tok-kw">and</span></span>
<span class="line" id="L372">        builtin.cpu.arch == .riscv64)</span>
<span class="line" id="L373">    {</span>
<span class="line" id="L374">        <span class="tok-comment">// https://github.com/ziglang/zig/issues/12031</span>
</span>
<span class="line" id="L375">        <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SkipZigTest;</span>
<span class="line" id="L376">    }</span>
<span class="line" id="L377"></span>
<span class="line" id="L378">    <span class="tok-comment">// explicitly test i0 because starting `t` at 0</span>
</span>
<span class="line" id="L379">    <span class="tok-comment">// will break the while loop</span>
</span>
<span class="line" id="L380">    <span class="tok-kw">try</span> test_write_leb128(<span class="tok-builtin">@as</span>(<span class="tok-type">i0</span>, <span class="tok-number">0</span>));</span>
<span class="line" id="L381"></span>
<span class="line" id="L382">    <span class="tok-kw">const</span> max_bits = <span class="tok-number">18</span>;</span>
<span class="line" id="L383"></span>
<span class="line" id="L384">    <span class="tok-kw">comptime</span> <span class="tok-kw">var</span> t = <span class="tok-number">1</span>;</span>
<span class="line" id="L385">    <span class="tok-kw">inline</span> <span class="tok-kw">while</span> (t &lt;= max_bits) : (t += <span class="tok-number">1</span>) {</span>
<span class="line" id="L386">        <span class="tok-kw">const</span> T = std.meta.Int(.signed, t);</span>
<span class="line" id="L387">        <span class="tok-kw">const</span> min = std.math.minInt(T);</span>
<span class="line" id="L388">        <span class="tok-kw">const</span> max = std.math.maxInt(T);</span>
<span class="line" id="L389">        <span class="tok-kw">var</span> i = <span class="tok-builtin">@as</span>(std.meta.Int(.signed, <span class="tok-builtin">@typeInfo</span>(T).Int.bits + <span class="tok-number">1</span>), min);</span>
<span class="line" id="L390"></span>
<span class="line" id="L391">        <span class="tok-kw">while</span> (i &lt;= max) : (i += <span class="tok-number">1</span>) <span class="tok-kw">try</span> test_write_leb128(<span class="tok-builtin">@intCast</span>(T, i));</span>
<span class="line" id="L392">    }</span>
<span class="line" id="L393">}</span>
<span class="line" id="L394"></span>
</code></pre></body>
</html>