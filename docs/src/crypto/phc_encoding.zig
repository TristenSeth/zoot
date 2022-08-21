<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">    <title>crypto/phc_encoding.zig - source view</title>
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
<pre><code><span class="line" id="L1"><span class="tok-comment">// https://github.com/P-H-C/phc-string-format</span>
</span>
<span class="line" id="L2"></span>
<span class="line" id="L3"><span class="tok-kw">const</span> std = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;std&quot;</span>);</span>
<span class="line" id="L4"><span class="tok-kw">const</span> fmt = std.fmt;</span>
<span class="line" id="L5"><span class="tok-kw">const</span> io = std.io;</span>
<span class="line" id="L6"><span class="tok-kw">const</span> mem = std.mem;</span>
<span class="line" id="L7"><span class="tok-kw">const</span> meta = std.meta;</span>
<span class="line" id="L8"></span>
<span class="line" id="L9"><span class="tok-kw">const</span> fields_delimiter = <span class="tok-str">&quot;$&quot;</span>;</span>
<span class="line" id="L10"><span class="tok-kw">const</span> version_param_name = <span class="tok-str">&quot;v&quot;</span>;</span>
<span class="line" id="L11"><span class="tok-kw">const</span> params_delimiter = <span class="tok-str">&quot;,&quot;</span>;</span>
<span class="line" id="L12"><span class="tok-kw">const</span> kv_delimiter = <span class="tok-str">&quot;=&quot;</span>;</span>
<span class="line" id="L13"></span>
<span class="line" id="L14"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> Error = std.crypto.errors.EncodingError || <span class="tok-kw">error</span>{NoSpaceLeft};</span>
<span class="line" id="L15"></span>
<span class="line" id="L16"><span class="tok-kw">const</span> B64Decoder = std.base64.standard_no_pad.Decoder;</span>
<span class="line" id="L17"><span class="tok-kw">const</span> B64Encoder = std.base64.standard_no_pad.Encoder;</span>
<span class="line" id="L18"></span>
<span class="line" id="L19"><span class="tok-comment">/// A wrapped binary value whose maximum size is `max_len`.</span></span>
<span class="line" id="L20"><span class="tok-comment">///</span></span>
<span class="line" id="L21"><span class="tok-comment">/// This type must be used whenever a binary value is encoded in a PHC-formatted string.</span></span>
<span class="line" id="L22"><span class="tok-comment">/// This includes `salt`, `hash`, and any other binary parameters such as keys.</span></span>
<span class="line" id="L23"><span class="tok-comment">///</span></span>
<span class="line" id="L24"><span class="tok-comment">/// Once initialized, the actual value can be read with the `constSlice()` function.</span></span>
<span class="line" id="L25"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">BinValue</span>(<span class="tok-kw">comptime</span> max_len: <span class="tok-type">usize</span>) <span class="tok-type">type</span> {</span>
<span class="line" id="L26">    <span class="tok-kw">return</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L27">        <span class="tok-kw">const</span> Self = <span class="tok-builtin">@This</span>();</span>
<span class="line" id="L28">        <span class="tok-kw">const</span> capacity = max_len;</span>
<span class="line" id="L29">        <span class="tok-kw">const</span> max_encoded_length = B64Encoder.calcSize(max_len);</span>
<span class="line" id="L30"></span>
<span class="line" id="L31">        buf: [max_len]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>,</span>
<span class="line" id="L32">        len: <span class="tok-type">usize</span> = <span class="tok-number">0</span>,</span>
<span class="line" id="L33"></span>
<span class="line" id="L34">        <span class="tok-comment">/// Wrap an existing byte slice</span></span>
<span class="line" id="L35">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">fromSlice</span>(slice: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) Error!Self {</span>
<span class="line" id="L36">            <span class="tok-kw">if</span> (slice.len &gt; capacity) <span class="tok-kw">return</span> Error.NoSpaceLeft;</span>
<span class="line" id="L37">            <span class="tok-kw">var</span> bin_value: Self = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L38">            mem.copy(<span class="tok-type">u8</span>, &amp;bin_value.buf, slice);</span>
<span class="line" id="L39">            bin_value.len = slice.len;</span>
<span class="line" id="L40">            <span class="tok-kw">return</span> bin_value;</span>
<span class="line" id="L41">        }</span>
<span class="line" id="L42"></span>
<span class="line" id="L43">        <span class="tok-comment">/// Return the slice containing the actual value.</span></span>
<span class="line" id="L44">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">constSlice</span>(self: *<span class="tok-kw">const</span> Self) []<span class="tok-kw">const</span> <span class="tok-type">u8</span> {</span>
<span class="line" id="L45">            <span class="tok-kw">return</span> self.buf[<span class="tok-number">0</span>..self.len];</span>
<span class="line" id="L46">        }</span>
<span class="line" id="L47"></span>
<span class="line" id="L48">        <span class="tok-kw">fn</span> <span class="tok-fn">fromB64</span>(self: *Self, str: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) !<span class="tok-type">void</span> {</span>
<span class="line" id="L49">            <span class="tok-kw">const</span> len = B64Decoder.calcSizeForSlice(str) <span class="tok-kw">catch</span> <span class="tok-kw">return</span> Error.InvalidEncoding;</span>
<span class="line" id="L50">            <span class="tok-kw">if</span> (len &gt; self.buf.len) <span class="tok-kw">return</span> Error.NoSpaceLeft;</span>
<span class="line" id="L51">            B64Decoder.decode(&amp;self.buf, str) <span class="tok-kw">catch</span> <span class="tok-kw">return</span> Error.InvalidEncoding;</span>
<span class="line" id="L52">            self.len = len;</span>
<span class="line" id="L53">        }</span>
<span class="line" id="L54"></span>
<span class="line" id="L55">        <span class="tok-kw">fn</span> <span class="tok-fn">toB64</span>(self: *<span class="tok-kw">const</span> Self, buf: []<span class="tok-type">u8</span>) ![]<span class="tok-kw">const</span> <span class="tok-type">u8</span> {</span>
<span class="line" id="L56">            <span class="tok-kw">const</span> value = self.constSlice();</span>
<span class="line" id="L57">            <span class="tok-kw">const</span> len = B64Encoder.calcSize(value.len);</span>
<span class="line" id="L58">            <span class="tok-kw">if</span> (len &gt; buf.len) <span class="tok-kw">return</span> Error.NoSpaceLeft;</span>
<span class="line" id="L59">            <span class="tok-kw">return</span> B64Encoder.encode(buf, value);</span>
<span class="line" id="L60">        }</span>
<span class="line" id="L61">    };</span>
<span class="line" id="L62">}</span>
<span class="line" id="L63"></span>
<span class="line" id="L64"><span class="tok-comment">/// Deserialize a PHC-formatted string into a structure `HashResult`.</span></span>
<span class="line" id="L65"><span class="tok-comment">///</span></span>
<span class="line" id="L66"><span class="tok-comment">/// Required field in the `HashResult` structure:</span></span>
<span class="line" id="L67"><span class="tok-comment">///   - `alg_id`: algorithm identifier</span></span>
<span class="line" id="L68"><span class="tok-comment">/// Optional, special fields:</span></span>
<span class="line" id="L69"><span class="tok-comment">///   - `alg_version`: algorithm version (unsigned integer)</span></span>
<span class="line" id="L70"><span class="tok-comment">///   - `salt`: salt</span></span>
<span class="line" id="L71"><span class="tok-comment">///   - `hash`: output of the hash function</span></span>
<span class="line" id="L72"><span class="tok-comment">///</span></span>
<span class="line" id="L73"><span class="tok-comment">/// Other fields will also be deserialized from the function parameters section.</span></span>
<span class="line" id="L74"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">deserialize</span>(<span class="tok-kw">comptime</span> HashResult: <span class="tok-type">type</span>, str: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) Error!HashResult {</span>
<span class="line" id="L75">    <span class="tok-kw">var</span> out = mem.zeroes(HashResult);</span>
<span class="line" id="L76">    <span class="tok-kw">var</span> it = mem.split(<span class="tok-type">u8</span>, str, fields_delimiter);</span>
<span class="line" id="L77">    <span class="tok-kw">var</span> set_fields: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L78"></span>
<span class="line" id="L79">    <span class="tok-kw">while</span> (<span class="tok-null">true</span>) {</span>
<span class="line" id="L80">        <span class="tok-comment">// Read the algorithm identifier</span>
</span>
<span class="line" id="L81">        <span class="tok-kw">if</span> ((it.next() <span class="tok-kw">orelse</span> <span class="tok-kw">return</span> Error.InvalidEncoding).len != <span class="tok-number">0</span>) <span class="tok-kw">return</span> Error.InvalidEncoding;</span>
<span class="line" id="L82">        out.alg_id = it.next() <span class="tok-kw">orelse</span> <span class="tok-kw">return</span> Error.InvalidEncoding;</span>
<span class="line" id="L83">        set_fields += <span class="tok-number">1</span>;</span>
<span class="line" id="L84"></span>
<span class="line" id="L85">        <span class="tok-comment">// Read the optional version number</span>
</span>
<span class="line" id="L86">        <span class="tok-kw">var</span> field = it.next() <span class="tok-kw">orelse</span> <span class="tok-kw">break</span>;</span>
<span class="line" id="L87">        <span class="tok-kw">if</span> (kvSplit(field)) |opt_version| {</span>
<span class="line" id="L88">            <span class="tok-kw">if</span> (mem.eql(<span class="tok-type">u8</span>, opt_version.key, version_param_name)) {</span>
<span class="line" id="L89">                <span class="tok-kw">if</span> (<span class="tok-builtin">@hasField</span>(HashResult, <span class="tok-str">&quot;alg_version&quot;</span>)) {</span>
<span class="line" id="L90">                    <span class="tok-kw">const</span> value_type_info = <span class="tok-kw">switch</span> (<span class="tok-builtin">@typeInfo</span>(<span class="tok-builtin">@TypeOf</span>(out.alg_version))) {</span>
<span class="line" id="L91">                        .Optional =&gt; |opt| <span class="tok-kw">comptime</span> <span class="tok-builtin">@typeInfo</span>(opt.child),</span>
<span class="line" id="L92">                        <span class="tok-kw">else</span> =&gt; |t| t,</span>
<span class="line" id="L93">                    };</span>
<span class="line" id="L94">                    out.alg_version = fmt.parseUnsigned(</span>
<span class="line" id="L95">                        <span class="tok-builtin">@Type</span>(value_type_info),</span>
<span class="line" id="L96">                        opt_version.value,</span>
<span class="line" id="L97">                        <span class="tok-number">10</span>,</span>
<span class="line" id="L98">                    ) <span class="tok-kw">catch</span> <span class="tok-kw">return</span> Error.InvalidEncoding;</span>
<span class="line" id="L99">                    set_fields += <span class="tok-number">1</span>;</span>
<span class="line" id="L100">                }</span>
<span class="line" id="L101">                field = it.next() <span class="tok-kw">orelse</span> <span class="tok-kw">break</span>;</span>
<span class="line" id="L102">            }</span>
<span class="line" id="L103">        } <span class="tok-kw">else</span> |_| {}</span>
<span class="line" id="L104"></span>
<span class="line" id="L105">        <span class="tok-comment">// Read optional parameters</span>
</span>
<span class="line" id="L106">        <span class="tok-kw">var</span> has_params = <span class="tok-null">false</span>;</span>
<span class="line" id="L107">        <span class="tok-kw">var</span> it_params = mem.split(<span class="tok-type">u8</span>, field, params_delimiter);</span>
<span class="line" id="L108">        <span class="tok-kw">while</span> (it_params.next()) |params| {</span>
<span class="line" id="L109">            <span class="tok-kw">const</span> param = kvSplit(params) <span class="tok-kw">catch</span> <span class="tok-kw">break</span>;</span>
<span class="line" id="L110">            <span class="tok-kw">var</span> found = <span class="tok-null">false</span>;</span>
<span class="line" id="L111">            <span class="tok-kw">inline</span> <span class="tok-kw">for</span> (<span class="tok-kw">comptime</span> meta.fields(HashResult)) |p| {</span>
<span class="line" id="L112">                <span class="tok-kw">if</span> (mem.eql(<span class="tok-type">u8</span>, p.name, param.key)) {</span>
<span class="line" id="L113">                    <span class="tok-kw">switch</span> (<span class="tok-builtin">@typeInfo</span>(p.field_type)) {</span>
<span class="line" id="L114">                        .Int =&gt; <span class="tok-builtin">@field</span>(out, p.name) = fmt.parseUnsigned(</span>
<span class="line" id="L115">                            p.field_type,</span>
<span class="line" id="L116">                            param.value,</span>
<span class="line" id="L117">                            <span class="tok-number">10</span>,</span>
<span class="line" id="L118">                        ) <span class="tok-kw">catch</span> <span class="tok-kw">return</span> Error.InvalidEncoding,</span>
<span class="line" id="L119">                        .Pointer =&gt; |ptr| {</span>
<span class="line" id="L120">                            <span class="tok-kw">if</span> (!ptr.is_const) <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;Value slice must be constant&quot;</span>);</span>
<span class="line" id="L121">                            <span class="tok-builtin">@field</span>(out, p.name) = param.value;</span>
<span class="line" id="L122">                        },</span>
<span class="line" id="L123">                        .Struct =&gt; <span class="tok-kw">try</span> <span class="tok-builtin">@field</span>(out, p.name).fromB64(param.value),</span>
<span class="line" id="L124">                        <span class="tok-kw">else</span> =&gt; std.debug.panic(</span>
<span class="line" id="L125">                            <span class="tok-str">&quot;Value for [{s}] must be an integer, a constant slice or a BinValue&quot;</span>,</span>
<span class="line" id="L126">                            .{p.name},</span>
<span class="line" id="L127">                        ),</span>
<span class="line" id="L128">                    }</span>
<span class="line" id="L129">                    set_fields += <span class="tok-number">1</span>;</span>
<span class="line" id="L130">                    found = <span class="tok-null">true</span>;</span>
<span class="line" id="L131">                    <span class="tok-kw">break</span>;</span>
<span class="line" id="L132">                }</span>
<span class="line" id="L133">            }</span>
<span class="line" id="L134">            <span class="tok-kw">if</span> (!found) <span class="tok-kw">return</span> Error.InvalidEncoding; <span class="tok-comment">// An unexpected parameter was found in the string</span>
</span>
<span class="line" id="L135">            has_params = <span class="tok-null">true</span>;</span>
<span class="line" id="L136">        }</span>
<span class="line" id="L137"></span>
<span class="line" id="L138">        <span class="tok-comment">// No separator between an empty parameters set and the salt</span>
</span>
<span class="line" id="L139">        <span class="tok-kw">if</span> (has_params) field = it.next() <span class="tok-kw">orelse</span> <span class="tok-kw">break</span>;</span>
<span class="line" id="L140"></span>
<span class="line" id="L141">        <span class="tok-comment">// Read an optional salt</span>
</span>
<span class="line" id="L142">        <span class="tok-kw">if</span> (<span class="tok-builtin">@hasField</span>(HashResult, <span class="tok-str">&quot;salt&quot;</span>)) {</span>
<span class="line" id="L143">            <span class="tok-kw">try</span> out.salt.fromB64(field);</span>
<span class="line" id="L144">            set_fields += <span class="tok-number">1</span>;</span>
<span class="line" id="L145">        } <span class="tok-kw">else</span> {</span>
<span class="line" id="L146">            <span class="tok-kw">return</span> Error.InvalidEncoding;</span>
<span class="line" id="L147">        }</span>
<span class="line" id="L148"></span>
<span class="line" id="L149">        <span class="tok-comment">// Read an optional hash</span>
</span>
<span class="line" id="L150">        field = it.next() <span class="tok-kw">orelse</span> <span class="tok-kw">break</span>;</span>
<span class="line" id="L151">        <span class="tok-kw">if</span> (<span class="tok-builtin">@hasField</span>(HashResult, <span class="tok-str">&quot;hash&quot;</span>)) {</span>
<span class="line" id="L152">            <span class="tok-kw">try</span> out.hash.fromB64(field);</span>
<span class="line" id="L153">            set_fields += <span class="tok-number">1</span>;</span>
<span class="line" id="L154">        } <span class="tok-kw">else</span> {</span>
<span class="line" id="L155">            <span class="tok-kw">return</span> Error.InvalidEncoding;</span>
<span class="line" id="L156">        }</span>
<span class="line" id="L157">        <span class="tok-kw">break</span>;</span>
<span class="line" id="L158">    }</span>
<span class="line" id="L159"></span>
<span class="line" id="L160">    <span class="tok-comment">// Check that all the required fields have been set, excluding optional values and parameters</span>
</span>
<span class="line" id="L161">    <span class="tok-comment">// with default values</span>
</span>
<span class="line" id="L162">    <span class="tok-kw">var</span> expected_fields: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L163">    <span class="tok-kw">inline</span> <span class="tok-kw">for</span> (<span class="tok-kw">comptime</span> meta.fields(HashResult)) |p| {</span>
<span class="line" id="L164">        <span class="tok-kw">if</span> (<span class="tok-builtin">@typeInfo</span>(p.field_type) != .Optional <span class="tok-kw">and</span> p.default_value == <span class="tok-null">null</span>) {</span>
<span class="line" id="L165">            expected_fields += <span class="tok-number">1</span>;</span>
<span class="line" id="L166">        }</span>
<span class="line" id="L167">    }</span>
<span class="line" id="L168">    <span class="tok-kw">if</span> (set_fields &lt; expected_fields) <span class="tok-kw">return</span> Error.InvalidEncoding;</span>
<span class="line" id="L169"></span>
<span class="line" id="L170">    <span class="tok-kw">return</span> out;</span>
<span class="line" id="L171">}</span>
<span class="line" id="L172"></span>
<span class="line" id="L173"><span class="tok-comment">/// Serialize parameters into a PHC string.</span></span>
<span class="line" id="L174"><span class="tok-comment">///</span></span>
<span class="line" id="L175"><span class="tok-comment">/// Required field for `params`:</span></span>
<span class="line" id="L176"><span class="tok-comment">///   - `alg_id`: algorithm identifier</span></span>
<span class="line" id="L177"><span class="tok-comment">/// Optional, special fields:</span></span>
<span class="line" id="L178"><span class="tok-comment">///   - `alg_version`: algorithm version (unsigned integer)</span></span>
<span class="line" id="L179"><span class="tok-comment">///   - `salt`: salt</span></span>
<span class="line" id="L180"><span class="tok-comment">///   - `hash`: output of the hash function</span></span>
<span class="line" id="L181"><span class="tok-comment">///</span></span>
<span class="line" id="L182"><span class="tok-comment">/// `params` can also include any additional parameters.</span></span>
<span class="line" id="L183"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">serialize</span>(params: <span class="tok-kw">anytype</span>, str: []<span class="tok-type">u8</span>) Error![]<span class="tok-kw">const</span> <span class="tok-type">u8</span> {</span>
<span class="line" id="L184">    <span class="tok-kw">var</span> buf = io.fixedBufferStream(str);</span>
<span class="line" id="L185">    <span class="tok-kw">try</span> serializeTo(params, buf.writer());</span>
<span class="line" id="L186">    <span class="tok-kw">return</span> buf.getWritten();</span>
<span class="line" id="L187">}</span>
<span class="line" id="L188"></span>
<span class="line" id="L189"><span class="tok-comment">/// Compute the number of bytes required to serialize `params`</span></span>
<span class="line" id="L190"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">calcSize</span>(params: <span class="tok-kw">anytype</span>) <span class="tok-type">usize</span> {</span>
<span class="line" id="L191">    <span class="tok-kw">var</span> buf = io.countingWriter(io.null_writer);</span>
<span class="line" id="L192">    serializeTo(params, buf.writer()) <span class="tok-kw">catch</span> <span class="tok-kw">unreachable</span>;</span>
<span class="line" id="L193">    <span class="tok-kw">return</span> <span class="tok-builtin">@intCast</span>(<span class="tok-type">usize</span>, buf.bytes_written);</span>
<span class="line" id="L194">}</span>
<span class="line" id="L195"></span>
<span class="line" id="L196"><span class="tok-kw">fn</span> <span class="tok-fn">serializeTo</span>(params: <span class="tok-kw">anytype</span>, out: <span class="tok-kw">anytype</span>) !<span class="tok-type">void</span> {</span>
<span class="line" id="L197">    <span class="tok-kw">const</span> HashResult = <span class="tok-builtin">@TypeOf</span>(params);</span>
<span class="line" id="L198">    <span class="tok-kw">try</span> out.writeAll(fields_delimiter);</span>
<span class="line" id="L199">    <span class="tok-kw">try</span> out.writeAll(params.alg_id);</span>
<span class="line" id="L200"></span>
<span class="line" id="L201">    <span class="tok-kw">if</span> (<span class="tok-builtin">@hasField</span>(HashResult, <span class="tok-str">&quot;alg_version&quot;</span>)) {</span>
<span class="line" id="L202">        <span class="tok-kw">if</span> (<span class="tok-builtin">@typeInfo</span>(<span class="tok-builtin">@TypeOf</span>(params.alg_version)) == .Optional) {</span>
<span class="line" id="L203">            <span class="tok-kw">if</span> (params.alg_version) |alg_version| {</span>
<span class="line" id="L204">                <span class="tok-kw">try</span> out.print(</span>
<span class="line" id="L205">                    <span class="tok-str">&quot;{s}{s}{s}{}&quot;</span>,</span>
<span class="line" id="L206">                    .{ fields_delimiter, version_param_name, kv_delimiter, alg_version },</span>
<span class="line" id="L207">                );</span>
<span class="line" id="L208">            }</span>
<span class="line" id="L209">        } <span class="tok-kw">else</span> {</span>
<span class="line" id="L210">            <span class="tok-kw">try</span> out.print(</span>
<span class="line" id="L211">                <span class="tok-str">&quot;{s}{s}{s}{}&quot;</span>,</span>
<span class="line" id="L212">                .{ fields_delimiter, version_param_name, kv_delimiter, params.alg_version },</span>
<span class="line" id="L213">            );</span>
<span class="line" id="L214">        }</span>
<span class="line" id="L215">    }</span>
<span class="line" id="L216"></span>
<span class="line" id="L217">    <span class="tok-kw">var</span> has_params = <span class="tok-null">false</span>;</span>
<span class="line" id="L218">    <span class="tok-kw">inline</span> <span class="tok-kw">for</span> (<span class="tok-kw">comptime</span> meta.fields(HashResult)) |p| {</span>
<span class="line" id="L219">        <span class="tok-kw">if</span> (<span class="tok-kw">comptime</span> !(mem.eql(<span class="tok-type">u8</span>, p.name, <span class="tok-str">&quot;alg_id&quot;</span>) <span class="tok-kw">or</span></span>
<span class="line" id="L220">            mem.eql(<span class="tok-type">u8</span>, p.name, <span class="tok-str">&quot;alg_version&quot;</span>) <span class="tok-kw">or</span></span>
<span class="line" id="L221">            mem.eql(<span class="tok-type">u8</span>, p.name, <span class="tok-str">&quot;hash&quot;</span>) <span class="tok-kw">or</span></span>
<span class="line" id="L222">            mem.eql(<span class="tok-type">u8</span>, p.name, <span class="tok-str">&quot;salt&quot;</span>)))</span>
<span class="line" id="L223">        {</span>
<span class="line" id="L224">            <span class="tok-kw">const</span> value = <span class="tok-builtin">@field</span>(params, p.name);</span>
<span class="line" id="L225">            <span class="tok-kw">try</span> out.writeAll(<span class="tok-kw">if</span> (has_params) params_delimiter <span class="tok-kw">else</span> fields_delimiter);</span>
<span class="line" id="L226">            <span class="tok-kw">if</span> (<span class="tok-builtin">@typeInfo</span>(p.field_type) == .Struct) {</span>
<span class="line" id="L227">                <span class="tok-kw">var</span> buf: [<span class="tok-builtin">@TypeOf</span>(value).max_encoded_length]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L228">                <span class="tok-kw">try</span> out.print(<span class="tok-str">&quot;{s}{s}{s}&quot;</span>, .{ p.name, kv_delimiter, <span class="tok-kw">try</span> value.toB64(&amp;buf) });</span>
<span class="line" id="L229">            } <span class="tok-kw">else</span> {</span>
<span class="line" id="L230">                <span class="tok-kw">try</span> out.print(</span>
<span class="line" id="L231">                    <span class="tok-kw">if</span> (<span class="tok-builtin">@typeInfo</span>(<span class="tok-builtin">@TypeOf</span>(value)) == .Pointer) <span class="tok-str">&quot;{s}{s}{s}&quot;</span> <span class="tok-kw">else</span> <span class="tok-str">&quot;{s}{s}{}&quot;</span>,</span>
<span class="line" id="L232">                    .{ p.name, kv_delimiter, value },</span>
<span class="line" id="L233">                );</span>
<span class="line" id="L234">            }</span>
<span class="line" id="L235">            has_params = <span class="tok-null">true</span>;</span>
<span class="line" id="L236">        }</span>
<span class="line" id="L237">    }</span>
<span class="line" id="L238"></span>
<span class="line" id="L239">    <span class="tok-kw">var</span> has_salt = <span class="tok-null">false</span>;</span>
<span class="line" id="L240">    <span class="tok-kw">if</span> (<span class="tok-builtin">@hasField</span>(HashResult, <span class="tok-str">&quot;salt&quot;</span>)) {</span>
<span class="line" id="L241">        <span class="tok-kw">var</span> buf: [<span class="tok-builtin">@TypeOf</span>(params.salt).max_encoded_length]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L242">        <span class="tok-kw">try</span> out.print(<span class="tok-str">&quot;{s}{s}&quot;</span>, .{ fields_delimiter, <span class="tok-kw">try</span> params.salt.toB64(&amp;buf) });</span>
<span class="line" id="L243">        has_salt = <span class="tok-null">true</span>;</span>
<span class="line" id="L244">    }</span>
<span class="line" id="L245"></span>
<span class="line" id="L246">    <span class="tok-kw">if</span> (<span class="tok-builtin">@hasField</span>(HashResult, <span class="tok-str">&quot;hash&quot;</span>)) {</span>
<span class="line" id="L247">        <span class="tok-kw">var</span> buf: [<span class="tok-builtin">@TypeOf</span>(params.hash).max_encoded_length]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L248">        <span class="tok-kw">if</span> (!has_salt) <span class="tok-kw">try</span> out.writeAll(fields_delimiter);</span>
<span class="line" id="L249">        <span class="tok-kw">try</span> out.print(<span class="tok-str">&quot;{s}{s}&quot;</span>, .{ fields_delimiter, <span class="tok-kw">try</span> params.hash.toB64(&amp;buf) });</span>
<span class="line" id="L250">    }</span>
<span class="line" id="L251">}</span>
<span class="line" id="L252"></span>
<span class="line" id="L253"><span class="tok-comment">// Split a `key=value` string into `key` and `value`</span>
</span>
<span class="line" id="L254"><span class="tok-kw">fn</span> <span class="tok-fn">kvSplit</span>(str: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) !<span class="tok-kw">struct</span> { key: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, value: []<span class="tok-kw">const</span> <span class="tok-type">u8</span> } {</span>
<span class="line" id="L255">    <span class="tok-kw">var</span> it = mem.split(<span class="tok-type">u8</span>, str, kv_delimiter);</span>
<span class="line" id="L256">    <span class="tok-kw">const</span> key = it.first();</span>
<span class="line" id="L257">    <span class="tok-kw">const</span> value = it.next() <span class="tok-kw">orelse</span> <span class="tok-kw">return</span> Error.InvalidEncoding;</span>
<span class="line" id="L258">    <span class="tok-kw">const</span> ret = .{ .key = key, .value = value };</span>
<span class="line" id="L259">    <span class="tok-kw">return</span> ret;</span>
<span class="line" id="L260">}</span>
<span class="line" id="L261"></span>
<span class="line" id="L262"><span class="tok-kw">test</span> <span class="tok-str">&quot;phc format - encoding/decoding&quot;</span> {</span>
<span class="line" id="L263">    <span class="tok-kw">const</span> Input = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L264">        str: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L265">        HashResult: <span class="tok-type">type</span>,</span>
<span class="line" id="L266">    };</span>
<span class="line" id="L267">    <span class="tok-kw">const</span> inputs = [_]Input{</span>
<span class="line" id="L268">        .{</span>
<span class="line" id="L269">            .str = <span class="tok-str">&quot;$argon2id$v=19$key=a2V5,m=4096,t=0,p=1$X1NhbHQAAAAAAAAAAAAAAA$bWh++MKN1OiFHKgIWTLvIi1iHicmHH7+Fv3K88ifFfI&quot;</span>,</span>
<span class="line" id="L270">            .HashResult = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L271">                alg_id: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L272">                alg_version: <span class="tok-type">u16</span>,</span>
<span class="line" id="L273">                key: BinValue(<span class="tok-number">16</span>),</span>
<span class="line" id="L274">                m: <span class="tok-type">usize</span>,</span>
<span class="line" id="L275">                t: <span class="tok-type">u64</span>,</span>
<span class="line" id="L276">                p: <span class="tok-type">u32</span>,</span>
<span class="line" id="L277">                salt: BinValue(<span class="tok-number">16</span>),</span>
<span class="line" id="L278">                hash: BinValue(<span class="tok-number">32</span>),</span>
<span class="line" id="L279">            },</span>
<span class="line" id="L280">        },</span>
<span class="line" id="L281">        .{</span>
<span class="line" id="L282">            .str = <span class="tok-str">&quot;$scrypt$v=1$ln=15,r=8,p=1$c2FsdHNhbHQ$dGVzdHBhc3M&quot;</span>,</span>
<span class="line" id="L283">            .HashResult = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L284">                alg_id: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L285">                alg_version: ?<span class="tok-type">u30</span>,</span>
<span class="line" id="L286">                ln: <span class="tok-type">u6</span>,</span>
<span class="line" id="L287">                r: <span class="tok-type">u30</span>,</span>
<span class="line" id="L288">                p: <span class="tok-type">u30</span>,</span>
<span class="line" id="L289">                salt: BinValue(<span class="tok-number">16</span>),</span>
<span class="line" id="L290">                hash: BinValue(<span class="tok-number">16</span>),</span>
<span class="line" id="L291">            },</span>
<span class="line" id="L292">        },</span>
<span class="line" id="L293">        .{</span>
<span class="line" id="L294">            .str = <span class="tok-str">&quot;$scrypt&quot;</span>,</span>
<span class="line" id="L295">            .HashResult = <span class="tok-kw">struct</span> { alg_id: []<span class="tok-kw">const</span> <span class="tok-type">u8</span> },</span>
<span class="line" id="L296">        },</span>
<span class="line" id="L297">        .{ .str = <span class="tok-str">&quot;$scrypt$v=1&quot;</span>, .HashResult = <span class="tok-kw">struct</span> { alg_id: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, alg_version: <span class="tok-type">u16</span> } },</span>
<span class="line" id="L298">        .{</span>
<span class="line" id="L299">            .str = <span class="tok-str">&quot;$scrypt$ln=15,r=8,p=1&quot;</span>,</span>
<span class="line" id="L300">            .HashResult = <span class="tok-kw">struct</span> { alg_id: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, alg_version: ?<span class="tok-type">u30</span>, ln: <span class="tok-type">u6</span>, r: <span class="tok-type">u30</span>, p: <span class="tok-type">u30</span> },</span>
<span class="line" id="L301">        },</span>
<span class="line" id="L302">        .{</span>
<span class="line" id="L303">            .str = <span class="tok-str">&quot;$scrypt$c2FsdHNhbHQ&quot;</span>,</span>
<span class="line" id="L304">            .HashResult = <span class="tok-kw">struct</span> { alg_id: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, salt: BinValue(<span class="tok-number">16</span>) },</span>
<span class="line" id="L305">        },</span>
<span class="line" id="L306">        .{</span>
<span class="line" id="L307">            .str = <span class="tok-str">&quot;$scrypt$v=1$ln=15,r=8,p=1$c2FsdHNhbHQ&quot;</span>,</span>
<span class="line" id="L308">            .HashResult = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L309">                alg_id: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L310">                alg_version: <span class="tok-type">u16</span>,</span>
<span class="line" id="L311">                ln: <span class="tok-type">u6</span>,</span>
<span class="line" id="L312">                r: <span class="tok-type">u30</span>,</span>
<span class="line" id="L313">                p: <span class="tok-type">u30</span>,</span>
<span class="line" id="L314">                salt: BinValue(<span class="tok-number">16</span>),</span>
<span class="line" id="L315">            },</span>
<span class="line" id="L316">        },</span>
<span class="line" id="L317">        .{</span>
<span class="line" id="L318">            .str = <span class="tok-str">&quot;$scrypt$v=1$ln=15,r=8,p=1&quot;</span>,</span>
<span class="line" id="L319">            .HashResult = <span class="tok-kw">struct</span> { alg_id: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, alg_version: ?<span class="tok-type">u30</span>, ln: <span class="tok-type">u6</span>, r: <span class="tok-type">u30</span>, p: <span class="tok-type">u30</span> },</span>
<span class="line" id="L320">        },</span>
<span class="line" id="L321">        .{</span>
<span class="line" id="L322">            .str = <span class="tok-str">&quot;$scrypt$v=1$c2FsdHNhbHQ$dGVzdHBhc3M&quot;</span>,</span>
<span class="line" id="L323">            .HashResult = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L324">                alg_id: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L325">                alg_version: <span class="tok-type">u16</span>,</span>
<span class="line" id="L326">                salt: BinValue(<span class="tok-number">16</span>),</span>
<span class="line" id="L327">                hash: BinValue(<span class="tok-number">16</span>),</span>
<span class="line" id="L328">            },</span>
<span class="line" id="L329">        },</span>
<span class="line" id="L330">        .{</span>
<span class="line" id="L331">            .str = <span class="tok-str">&quot;$scrypt$v=1$c2FsdHNhbHQ&quot;</span>,</span>
<span class="line" id="L332">            .HashResult = <span class="tok-kw">struct</span> { alg_id: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, alg_version: <span class="tok-type">u16</span>, salt: BinValue(<span class="tok-number">16</span>) },</span>
<span class="line" id="L333">        },</span>
<span class="line" id="L334">        .{</span>
<span class="line" id="L335">            .str = <span class="tok-str">&quot;$scrypt$c2FsdHNhbHQ$dGVzdHBhc3M&quot;</span>,</span>
<span class="line" id="L336">            .HashResult = <span class="tok-kw">struct</span> { alg_id: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, salt: BinValue(<span class="tok-number">16</span>), hash: BinValue(<span class="tok-number">16</span>) },</span>
<span class="line" id="L337">        },</span>
<span class="line" id="L338">    };</span>
<span class="line" id="L339">    <span class="tok-kw">inline</span> <span class="tok-kw">for</span> (inputs) |input| {</span>
<span class="line" id="L340">        <span class="tok-kw">const</span> v = <span class="tok-kw">try</span> deserialize(input.HashResult, input.str);</span>
<span class="line" id="L341">        <span class="tok-kw">var</span> buf: [input.str.len]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L342">        <span class="tok-kw">const</span> s1 = <span class="tok-kw">try</span> serialize(v, &amp;buf);</span>
<span class="line" id="L343">        <span class="tok-kw">try</span> std.testing.expectEqualSlices(<span class="tok-type">u8</span>, input.str, s1);</span>
<span class="line" id="L344">    }</span>
<span class="line" id="L345">}</span>
<span class="line" id="L346"></span>
<span class="line" id="L347"><span class="tok-kw">test</span> <span class="tok-str">&quot;phc format - empty input string&quot;</span> {</span>
<span class="line" id="L348">    <span class="tok-kw">const</span> s = <span class="tok-str">&quot;&quot;</span>;</span>
<span class="line" id="L349">    <span class="tok-kw">const</span> v = deserialize(<span class="tok-kw">struct</span> { alg_id: []<span class="tok-kw">const</span> <span class="tok-type">u8</span> }, s);</span>
<span class="line" id="L350">    <span class="tok-kw">try</span> std.testing.expectError(Error.InvalidEncoding, v);</span>
<span class="line" id="L351">}</span>
<span class="line" id="L352"></span>
<span class="line" id="L353"><span class="tok-kw">test</span> <span class="tok-str">&quot;phc format - hash without salt&quot;</span> {</span>
<span class="line" id="L354">    <span class="tok-kw">const</span> s = <span class="tok-str">&quot;$scrypt&quot;</span>;</span>
<span class="line" id="L355">    <span class="tok-kw">const</span> v = deserialize(<span class="tok-kw">struct</span> { alg_id: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, hash: BinValue(<span class="tok-number">16</span>) }, s);</span>
<span class="line" id="L356">    <span class="tok-kw">try</span> std.testing.expectError(Error.InvalidEncoding, v);</span>
<span class="line" id="L357">}</span>
<span class="line" id="L358"></span>
<span class="line" id="L359"><span class="tok-kw">test</span> <span class="tok-str">&quot;phc format - calcSize&quot;</span> {</span>
<span class="line" id="L360">    <span class="tok-kw">const</span> s = <span class="tok-str">&quot;$scrypt$v=1$ln=15,r=8,p=1$c2FsdHNhbHQ$dGVzdHBhc3M&quot;</span>;</span>
<span class="line" id="L361">    <span class="tok-kw">const</span> v = <span class="tok-kw">try</span> deserialize(<span class="tok-kw">struct</span> {</span>
<span class="line" id="L362">        alg_id: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L363">        alg_version: <span class="tok-type">u16</span>,</span>
<span class="line" id="L364">        ln: <span class="tok-type">u6</span>,</span>
<span class="line" id="L365">        r: <span class="tok-type">u30</span>,</span>
<span class="line" id="L366">        p: <span class="tok-type">u30</span>,</span>
<span class="line" id="L367">        salt: BinValue(<span class="tok-number">8</span>),</span>
<span class="line" id="L368">        hash: BinValue(<span class="tok-number">8</span>),</span>
<span class="line" id="L369">    }, s);</span>
<span class="line" id="L370">    <span class="tok-kw">try</span> std.testing.expectEqual(calcSize(v), s.len);</span>
<span class="line" id="L371">}</span>
<span class="line" id="L372"></span>
</code></pre></body>
</html>