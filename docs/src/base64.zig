<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">    <title>base64.zig - source view</title>
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
<pre><code><span class="line" id="L1"><span class="tok-kw">const</span> std = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;std.zig&quot;</span>);</span>
<span class="line" id="L2"><span class="tok-kw">const</span> assert = std.debug.assert;</span>
<span class="line" id="L3"><span class="tok-kw">const</span> testing = std.testing;</span>
<span class="line" id="L4"><span class="tok-kw">const</span> mem = std.mem;</span>
<span class="line" id="L5"></span>
<span class="line" id="L6"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> Error = <span class="tok-kw">error</span>{</span>
<span class="line" id="L7">    InvalidCharacter,</span>
<span class="line" id="L8">    InvalidPadding,</span>
<span class="line" id="L9">    NoSpaceLeft,</span>
<span class="line" id="L10">};</span>
<span class="line" id="L11"></span>
<span class="line" id="L12"><span class="tok-kw">const</span> decoderWithIgnoreProto = <span class="tok-kw">switch</span> (<span class="tok-builtin">@import</span>(<span class="tok-str">&quot;builtin&quot;</span>).zig_backend) {</span>
<span class="line" id="L13">    .stage1 =&gt; <span class="tok-kw">fn</span> (ignore: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) Base64DecoderWithIgnore,</span>
<span class="line" id="L14">    <span class="tok-kw">else</span> =&gt; *<span class="tok-kw">const</span> <span class="tok-kw">fn</span> (ignore: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) Base64DecoderWithIgnore,</span>
<span class="line" id="L15">};</span>
<span class="line" id="L16"></span>
<span class="line" id="L17"><span class="tok-comment">/// Base64 codecs</span></span>
<span class="line" id="L18"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> Codecs = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L19">    alphabet_chars: [<span class="tok-number">64</span>]<span class="tok-type">u8</span>,</span>
<span class="line" id="L20">    pad_char: ?<span class="tok-type">u8</span>,</span>
<span class="line" id="L21">    decoderWithIgnore: decoderWithIgnoreProto,</span>
<span class="line" id="L22">    Encoder: Base64Encoder,</span>
<span class="line" id="L23">    Decoder: Base64Decoder,</span>
<span class="line" id="L24">};</span>
<span class="line" id="L25"></span>
<span class="line" id="L26"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> standard_alphabet_chars = <span class="tok-str">&quot;ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/&quot;</span>.*;</span>
<span class="line" id="L27"><span class="tok-kw">fn</span> <span class="tok-fn">standardBase64DecoderWithIgnore</span>(ignore: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) Base64DecoderWithIgnore {</span>
<span class="line" id="L28">    <span class="tok-kw">return</span> Base64DecoderWithIgnore.init(standard_alphabet_chars, <span class="tok-str">'='</span>, ignore);</span>
<span class="line" id="L29">}</span>
<span class="line" id="L30"></span>
<span class="line" id="L31"><span class="tok-comment">/// Standard Base64 codecs, with padding</span></span>
<span class="line" id="L32"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> standard = Codecs{</span>
<span class="line" id="L33">    .alphabet_chars = standard_alphabet_chars,</span>
<span class="line" id="L34">    .pad_char = <span class="tok-str">'='</span>,</span>
<span class="line" id="L35">    .decoderWithIgnore = standardBase64DecoderWithIgnore,</span>
<span class="line" id="L36">    .Encoder = Base64Encoder.init(standard_alphabet_chars, <span class="tok-str">'='</span>),</span>
<span class="line" id="L37">    .Decoder = Base64Decoder.init(standard_alphabet_chars, <span class="tok-str">'='</span>),</span>
<span class="line" id="L38">};</span>
<span class="line" id="L39"></span>
<span class="line" id="L40"><span class="tok-comment">/// Standard Base64 codecs, without padding</span></span>
<span class="line" id="L41"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> standard_no_pad = Codecs{</span>
<span class="line" id="L42">    .alphabet_chars = standard_alphabet_chars,</span>
<span class="line" id="L43">    .pad_char = <span class="tok-null">null</span>,</span>
<span class="line" id="L44">    .decoderWithIgnore = standardBase64DecoderWithIgnore,</span>
<span class="line" id="L45">    .Encoder = Base64Encoder.init(standard_alphabet_chars, <span class="tok-null">null</span>),</span>
<span class="line" id="L46">    .Decoder = Base64Decoder.init(standard_alphabet_chars, <span class="tok-null">null</span>),</span>
<span class="line" id="L47">};</span>
<span class="line" id="L48"></span>
<span class="line" id="L49"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> url_safe_alphabet_chars = <span class="tok-str">&quot;ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_&quot;</span>.*;</span>
<span class="line" id="L50"><span class="tok-kw">fn</span> <span class="tok-fn">urlSafeBase64DecoderWithIgnore</span>(ignore: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) Base64DecoderWithIgnore {</span>
<span class="line" id="L51">    <span class="tok-kw">return</span> Base64DecoderWithIgnore.init(url_safe_alphabet_chars, <span class="tok-null">null</span>, ignore);</span>
<span class="line" id="L52">}</span>
<span class="line" id="L53"></span>
<span class="line" id="L54"><span class="tok-comment">/// URL-safe Base64 codecs, with padding</span></span>
<span class="line" id="L55"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> url_safe = Codecs{</span>
<span class="line" id="L56">    .alphabet_chars = url_safe_alphabet_chars,</span>
<span class="line" id="L57">    .pad_char = <span class="tok-str">'='</span>,</span>
<span class="line" id="L58">    .decoderWithIgnore = urlSafeBase64DecoderWithIgnore,</span>
<span class="line" id="L59">    .Encoder = Base64Encoder.init(url_safe_alphabet_chars, <span class="tok-str">'='</span>),</span>
<span class="line" id="L60">    .Decoder = Base64Decoder.init(url_safe_alphabet_chars, <span class="tok-str">'='</span>),</span>
<span class="line" id="L61">};</span>
<span class="line" id="L62"></span>
<span class="line" id="L63"><span class="tok-comment">/// URL-safe Base64 codecs, without padding</span></span>
<span class="line" id="L64"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> url_safe_no_pad = Codecs{</span>
<span class="line" id="L65">    .alphabet_chars = url_safe_alphabet_chars,</span>
<span class="line" id="L66">    .pad_char = <span class="tok-null">null</span>,</span>
<span class="line" id="L67">    .decoderWithIgnore = urlSafeBase64DecoderWithIgnore,</span>
<span class="line" id="L68">    .Encoder = Base64Encoder.init(url_safe_alphabet_chars, <span class="tok-null">null</span>),</span>
<span class="line" id="L69">    .Decoder = Base64Decoder.init(url_safe_alphabet_chars, <span class="tok-null">null</span>),</span>
<span class="line" id="L70">};</span>
<span class="line" id="L71"></span>
<span class="line" id="L72"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> standard_pad_char = <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;deprecated; use standard.pad_char&quot;</span>);</span>
<span class="line" id="L73"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> standard_encoder = <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;deprecated; use standard.Encoder&quot;</span>);</span>
<span class="line" id="L74"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> standard_decoder = <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;deprecated; use standard.Decoder&quot;</span>);</span>
<span class="line" id="L75"></span>
<span class="line" id="L76"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> Base64Encoder = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L77">    alphabet_chars: [<span class="tok-number">64</span>]<span class="tok-type">u8</span>,</span>
<span class="line" id="L78">    pad_char: ?<span class="tok-type">u8</span>,</span>
<span class="line" id="L79"></span>
<span class="line" id="L80">    <span class="tok-comment">/// A bunch of assertions, then simply pass the data right through.</span></span>
<span class="line" id="L81">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">init</span>(alphabet_chars: [<span class="tok-number">64</span>]<span class="tok-type">u8</span>, pad_char: ?<span class="tok-type">u8</span>) Base64Encoder {</span>
<span class="line" id="L82">        assert(alphabet_chars.len == <span class="tok-number">64</span>);</span>
<span class="line" id="L83">        <span class="tok-kw">var</span> char_in_alphabet = [_]<span class="tok-type">bool</span>{<span class="tok-null">false</span>} ** <span class="tok-number">256</span>;</span>
<span class="line" id="L84">        <span class="tok-kw">for</span> (alphabet_chars) |c| {</span>
<span class="line" id="L85">            assert(!char_in_alphabet[c]);</span>
<span class="line" id="L86">            assert(pad_char == <span class="tok-null">null</span> <span class="tok-kw">or</span> c != pad_char.?);</span>
<span class="line" id="L87">            char_in_alphabet[c] = <span class="tok-null">true</span>;</span>
<span class="line" id="L88">        }</span>
<span class="line" id="L89">        <span class="tok-kw">return</span> Base64Encoder{</span>
<span class="line" id="L90">            .alphabet_chars = alphabet_chars,</span>
<span class="line" id="L91">            .pad_char = pad_char,</span>
<span class="line" id="L92">        };</span>
<span class="line" id="L93">    }</span>
<span class="line" id="L94"></span>
<span class="line" id="L95">    <span class="tok-comment">/// Compute the encoded length</span></span>
<span class="line" id="L96">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">calcSize</span>(encoder: *<span class="tok-kw">const</span> Base64Encoder, source_len: <span class="tok-type">usize</span>) <span class="tok-type">usize</span> {</span>
<span class="line" id="L97">        <span class="tok-kw">if</span> (encoder.pad_char != <span class="tok-null">null</span>) {</span>
<span class="line" id="L98">            <span class="tok-kw">return</span> <span class="tok-builtin">@divTrunc</span>(source_len + <span class="tok-number">2</span>, <span class="tok-number">3</span>) * <span class="tok-number">4</span>;</span>
<span class="line" id="L99">        } <span class="tok-kw">else</span> {</span>
<span class="line" id="L100">            <span class="tok-kw">const</span> leftover = source_len % <span class="tok-number">3</span>;</span>
<span class="line" id="L101">            <span class="tok-kw">return</span> <span class="tok-builtin">@divTrunc</span>(source_len, <span class="tok-number">3</span>) * <span class="tok-number">4</span> + <span class="tok-builtin">@divTrunc</span>(leftover * <span class="tok-number">4</span> + <span class="tok-number">2</span>, <span class="tok-number">3</span>);</span>
<span class="line" id="L102">        }</span>
<span class="line" id="L103">    }</span>
<span class="line" id="L104"></span>
<span class="line" id="L105">    <span class="tok-comment">/// dest.len must at least be what you get from ::calcSize.</span></span>
<span class="line" id="L106">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">encode</span>(encoder: *<span class="tok-kw">const</span> Base64Encoder, dest: []<span class="tok-type">u8</span>, source: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) []<span class="tok-kw">const</span> <span class="tok-type">u8</span> {</span>
<span class="line" id="L107">        <span class="tok-kw">const</span> out_len = encoder.calcSize(source.len);</span>
<span class="line" id="L108">        assert(dest.len &gt;= out_len);</span>
<span class="line" id="L109"></span>
<span class="line" id="L110">        <span class="tok-kw">var</span> acc: <span class="tok-type">u12</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L111">        <span class="tok-kw">var</span> acc_len: <span class="tok-type">u4</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L112">        <span class="tok-kw">var</span> out_idx: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L113">        <span class="tok-kw">for</span> (source) |v| {</span>
<span class="line" id="L114">            acc = (acc &lt;&lt; <span class="tok-number">8</span>) + v;</span>
<span class="line" id="L115">            acc_len += <span class="tok-number">8</span>;</span>
<span class="line" id="L116">            <span class="tok-kw">while</span> (acc_len &gt;= <span class="tok-number">6</span>) {</span>
<span class="line" id="L117">                acc_len -= <span class="tok-number">6</span>;</span>
<span class="line" id="L118">                dest[out_idx] = encoder.alphabet_chars[<span class="tok-builtin">@truncate</span>(<span class="tok-type">u6</span>, (acc &gt;&gt; acc_len))];</span>
<span class="line" id="L119">                out_idx += <span class="tok-number">1</span>;</span>
<span class="line" id="L120">            }</span>
<span class="line" id="L121">        }</span>
<span class="line" id="L122">        <span class="tok-kw">if</span> (acc_len &gt; <span class="tok-number">0</span>) {</span>
<span class="line" id="L123">            dest[out_idx] = encoder.alphabet_chars[<span class="tok-builtin">@truncate</span>(<span class="tok-type">u6</span>, (acc &lt;&lt; <span class="tok-number">6</span> - acc_len))];</span>
<span class="line" id="L124">            out_idx += <span class="tok-number">1</span>;</span>
<span class="line" id="L125">        }</span>
<span class="line" id="L126">        <span class="tok-kw">if</span> (encoder.pad_char) |pad_char| {</span>
<span class="line" id="L127">            <span class="tok-kw">for</span> (dest[out_idx..]) |*pad| {</span>
<span class="line" id="L128">                pad.* = pad_char;</span>
<span class="line" id="L129">            }</span>
<span class="line" id="L130">        }</span>
<span class="line" id="L131">        <span class="tok-kw">return</span> dest[<span class="tok-number">0</span>..out_len];</span>
<span class="line" id="L132">    }</span>
<span class="line" id="L133">};</span>
<span class="line" id="L134"></span>
<span class="line" id="L135"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> Base64Decoder = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L136">    <span class="tok-kw">const</span> invalid_char: <span class="tok-type">u8</span> = <span class="tok-number">0xff</span>;</span>
<span class="line" id="L137"></span>
<span class="line" id="L138">    <span class="tok-comment">/// e.g. 'A' =&gt; 0.</span></span>
<span class="line" id="L139">    <span class="tok-comment">/// `invalid_char` for any value not in the 64 alphabet chars.</span></span>
<span class="line" id="L140">    char_to_index: [<span class="tok-number">256</span>]<span class="tok-type">u8</span>,</span>
<span class="line" id="L141">    pad_char: ?<span class="tok-type">u8</span>,</span>
<span class="line" id="L142"></span>
<span class="line" id="L143">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">init</span>(alphabet_chars: [<span class="tok-number">64</span>]<span class="tok-type">u8</span>, pad_char: ?<span class="tok-type">u8</span>) Base64Decoder {</span>
<span class="line" id="L144">        <span class="tok-kw">var</span> result = Base64Decoder{</span>
<span class="line" id="L145">            .char_to_index = [_]<span class="tok-type">u8</span>{invalid_char} ** <span class="tok-number">256</span>,</span>
<span class="line" id="L146">            .pad_char = pad_char,</span>
<span class="line" id="L147">        };</span>
<span class="line" id="L148"></span>
<span class="line" id="L149">        <span class="tok-kw">var</span> char_in_alphabet = [_]<span class="tok-type">bool</span>{<span class="tok-null">false</span>} ** <span class="tok-number">256</span>;</span>
<span class="line" id="L150">        <span class="tok-kw">for</span> (alphabet_chars) |c, i| {</span>
<span class="line" id="L151">            assert(!char_in_alphabet[c]);</span>
<span class="line" id="L152">            assert(pad_char == <span class="tok-null">null</span> <span class="tok-kw">or</span> c != pad_char.?);</span>
<span class="line" id="L153"></span>
<span class="line" id="L154">            result.char_to_index[c] = <span class="tok-builtin">@intCast</span>(<span class="tok-type">u8</span>, i);</span>
<span class="line" id="L155">            char_in_alphabet[c] = <span class="tok-null">true</span>;</span>
<span class="line" id="L156">        }</span>
<span class="line" id="L157">        <span class="tok-kw">return</span> result;</span>
<span class="line" id="L158">    }</span>
<span class="line" id="L159"></span>
<span class="line" id="L160">    <span class="tok-comment">/// Return the maximum possible decoded size for a given input length - The actual length may be less if the input includes padding.</span></span>
<span class="line" id="L161">    <span class="tok-comment">/// `InvalidPadding` is returned if the input length is not valid.</span></span>
<span class="line" id="L162">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">calcSizeUpperBound</span>(decoder: *<span class="tok-kw">const</span> Base64Decoder, source_len: <span class="tok-type">usize</span>) Error!<span class="tok-type">usize</span> {</span>
<span class="line" id="L163">        <span class="tok-kw">var</span> result = source_len / <span class="tok-number">4</span> * <span class="tok-number">3</span>;</span>
<span class="line" id="L164">        <span class="tok-kw">const</span> leftover = source_len % <span class="tok-number">4</span>;</span>
<span class="line" id="L165">        <span class="tok-kw">if</span> (decoder.pad_char != <span class="tok-null">null</span>) {</span>
<span class="line" id="L166">            <span class="tok-kw">if</span> (leftover % <span class="tok-number">4</span> != <span class="tok-number">0</span>) <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InvalidPadding;</span>
<span class="line" id="L167">        } <span class="tok-kw">else</span> {</span>
<span class="line" id="L168">            <span class="tok-kw">if</span> (leftover % <span class="tok-number">4</span> == <span class="tok-number">1</span>) <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InvalidPadding;</span>
<span class="line" id="L169">            result += leftover * <span class="tok-number">3</span> / <span class="tok-number">4</span>;</span>
<span class="line" id="L170">        }</span>
<span class="line" id="L171">        <span class="tok-kw">return</span> result;</span>
<span class="line" id="L172">    }</span>
<span class="line" id="L173"></span>
<span class="line" id="L174">    <span class="tok-comment">/// Return the exact decoded size for a slice.</span></span>
<span class="line" id="L175">    <span class="tok-comment">/// `InvalidPadding` is returned if the input length is not valid.</span></span>
<span class="line" id="L176">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">calcSizeForSlice</span>(decoder: *<span class="tok-kw">const</span> Base64Decoder, source: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) Error!<span class="tok-type">usize</span> {</span>
<span class="line" id="L177">        <span class="tok-kw">const</span> source_len = source.len;</span>
<span class="line" id="L178">        <span class="tok-kw">var</span> result = <span class="tok-kw">try</span> decoder.calcSizeUpperBound(source_len);</span>
<span class="line" id="L179">        <span class="tok-kw">if</span> (decoder.pad_char) |pad_char| {</span>
<span class="line" id="L180">            <span class="tok-kw">if</span> (source_len &gt;= <span class="tok-number">1</span> <span class="tok-kw">and</span> source[source_len - <span class="tok-number">1</span>] == pad_char) result -= <span class="tok-number">1</span>;</span>
<span class="line" id="L181">            <span class="tok-kw">if</span> (source_len &gt;= <span class="tok-number">2</span> <span class="tok-kw">and</span> source[source_len - <span class="tok-number">2</span>] == pad_char) result -= <span class="tok-number">1</span>;</span>
<span class="line" id="L182">        }</span>
<span class="line" id="L183">        <span class="tok-kw">return</span> result;</span>
<span class="line" id="L184">    }</span>
<span class="line" id="L185"></span>
<span class="line" id="L186">    <span class="tok-comment">/// dest.len must be what you get from ::calcSize.</span></span>
<span class="line" id="L187">    <span class="tok-comment">/// invalid characters result in error.InvalidCharacter.</span></span>
<span class="line" id="L188">    <span class="tok-comment">/// invalid padding results in error.InvalidPadding.</span></span>
<span class="line" id="L189">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">decode</span>(decoder: *<span class="tok-kw">const</span> Base64Decoder, dest: []<span class="tok-type">u8</span>, source: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) Error!<span class="tok-type">void</span> {</span>
<span class="line" id="L190">        <span class="tok-kw">if</span> (decoder.pad_char != <span class="tok-null">null</span> <span class="tok-kw">and</span> source.len % <span class="tok-number">4</span> != <span class="tok-number">0</span>) <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InvalidPadding;</span>
<span class="line" id="L191">        <span class="tok-kw">var</span> acc: <span class="tok-type">u12</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L192">        <span class="tok-kw">var</span> acc_len: <span class="tok-type">u4</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L193">        <span class="tok-kw">var</span> dest_idx: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L194">        <span class="tok-kw">var</span> leftover_idx: ?<span class="tok-type">usize</span> = <span class="tok-null">null</span>;</span>
<span class="line" id="L195">        <span class="tok-kw">for</span> (source) |c, src_idx| {</span>
<span class="line" id="L196">            <span class="tok-kw">const</span> d = decoder.char_to_index[c];</span>
<span class="line" id="L197">            <span class="tok-kw">if</span> (d == invalid_char) {</span>
<span class="line" id="L198">                <span class="tok-kw">if</span> (decoder.pad_char == <span class="tok-null">null</span> <span class="tok-kw">or</span> c != decoder.pad_char.?) <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InvalidCharacter;</span>
<span class="line" id="L199">                leftover_idx = src_idx;</span>
<span class="line" id="L200">                <span class="tok-kw">break</span>;</span>
<span class="line" id="L201">            }</span>
<span class="line" id="L202">            acc = (acc &lt;&lt; <span class="tok-number">6</span>) + d;</span>
<span class="line" id="L203">            acc_len += <span class="tok-number">6</span>;</span>
<span class="line" id="L204">            <span class="tok-kw">if</span> (acc_len &gt;= <span class="tok-number">8</span>) {</span>
<span class="line" id="L205">                acc_len -= <span class="tok-number">8</span>;</span>
<span class="line" id="L206">                dest[dest_idx] = <span class="tok-builtin">@truncate</span>(<span class="tok-type">u8</span>, acc &gt;&gt; acc_len);</span>
<span class="line" id="L207">                dest_idx += <span class="tok-number">1</span>;</span>
<span class="line" id="L208">            }</span>
<span class="line" id="L209">        }</span>
<span class="line" id="L210">        <span class="tok-kw">if</span> (acc_len &gt; <span class="tok-number">4</span> <span class="tok-kw">or</span> (acc &amp; (<span class="tok-builtin">@as</span>(<span class="tok-type">u12</span>, <span class="tok-number">1</span>) &lt;&lt; acc_len) - <span class="tok-number">1</span>) != <span class="tok-number">0</span>) {</span>
<span class="line" id="L211">            <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InvalidPadding;</span>
<span class="line" id="L212">        }</span>
<span class="line" id="L213">        <span class="tok-kw">if</span> (leftover_idx == <span class="tok-null">null</span>) <span class="tok-kw">return</span>;</span>
<span class="line" id="L214">        <span class="tok-kw">var</span> leftover = source[leftover_idx.?..];</span>
<span class="line" id="L215">        <span class="tok-kw">if</span> (decoder.pad_char) |pad_char| {</span>
<span class="line" id="L216">            <span class="tok-kw">const</span> padding_len = acc_len / <span class="tok-number">2</span>;</span>
<span class="line" id="L217">            <span class="tok-kw">var</span> padding_chars: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L218">            <span class="tok-kw">for</span> (leftover) |c| {</span>
<span class="line" id="L219">                <span class="tok-kw">if</span> (c != pad_char) {</span>
<span class="line" id="L220">                    <span class="tok-kw">return</span> <span class="tok-kw">if</span> (c == Base64Decoder.invalid_char) <span class="tok-kw">error</span>.InvalidCharacter <span class="tok-kw">else</span> <span class="tok-kw">error</span>.InvalidPadding;</span>
<span class="line" id="L221">                }</span>
<span class="line" id="L222">                padding_chars += <span class="tok-number">1</span>;</span>
<span class="line" id="L223">            }</span>
<span class="line" id="L224">            <span class="tok-kw">if</span> (padding_chars != padding_len) <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InvalidPadding;</span>
<span class="line" id="L225">        }</span>
<span class="line" id="L226">    }</span>
<span class="line" id="L227">};</span>
<span class="line" id="L228"></span>
<span class="line" id="L229"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> Base64DecoderWithIgnore = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L230">    decoder: Base64Decoder,</span>
<span class="line" id="L231">    char_is_ignored: [<span class="tok-number">256</span>]<span class="tok-type">bool</span>,</span>
<span class="line" id="L232"></span>
<span class="line" id="L233">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">init</span>(alphabet_chars: [<span class="tok-number">64</span>]<span class="tok-type">u8</span>, pad_char: ?<span class="tok-type">u8</span>, ignore_chars: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) Base64DecoderWithIgnore {</span>
<span class="line" id="L234">        <span class="tok-kw">var</span> result = Base64DecoderWithIgnore{</span>
<span class="line" id="L235">            .decoder = Base64Decoder.init(alphabet_chars, pad_char),</span>
<span class="line" id="L236">            .char_is_ignored = [_]<span class="tok-type">bool</span>{<span class="tok-null">false</span>} ** <span class="tok-number">256</span>,</span>
<span class="line" id="L237">        };</span>
<span class="line" id="L238">        <span class="tok-kw">for</span> (ignore_chars) |c| {</span>
<span class="line" id="L239">            assert(result.decoder.char_to_index[c] == Base64Decoder.invalid_char);</span>
<span class="line" id="L240">            assert(!result.char_is_ignored[c]);</span>
<span class="line" id="L241">            assert(result.decoder.pad_char != c);</span>
<span class="line" id="L242">            result.char_is_ignored[c] = <span class="tok-null">true</span>;</span>
<span class="line" id="L243">        }</span>
<span class="line" id="L244">        <span class="tok-kw">return</span> result;</span>
<span class="line" id="L245">    }</span>
<span class="line" id="L246"></span>
<span class="line" id="L247">    <span class="tok-comment">/// Return the maximum possible decoded size for a given input length - The actual length may be less if the input includes padding</span></span>
<span class="line" id="L248">    <span class="tok-comment">/// `InvalidPadding` is returned if the input length is not valid.</span></span>
<span class="line" id="L249">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">calcSizeUpperBound</span>(decoder_with_ignore: *<span class="tok-kw">const</span> Base64DecoderWithIgnore, source_len: <span class="tok-type">usize</span>) Error!<span class="tok-type">usize</span> {</span>
<span class="line" id="L250">        <span class="tok-kw">var</span> result = source_len / <span class="tok-number">4</span> * <span class="tok-number">3</span>;</span>
<span class="line" id="L251">        <span class="tok-kw">if</span> (decoder_with_ignore.decoder.pad_char == <span class="tok-null">null</span>) {</span>
<span class="line" id="L252">            <span class="tok-kw">const</span> leftover = source_len % <span class="tok-number">4</span>;</span>
<span class="line" id="L253">            result += leftover * <span class="tok-number">3</span> / <span class="tok-number">4</span>;</span>
<span class="line" id="L254">        }</span>
<span class="line" id="L255">        <span class="tok-kw">return</span> result;</span>
<span class="line" id="L256">    }</span>
<span class="line" id="L257"></span>
<span class="line" id="L258">    <span class="tok-comment">/// Invalid characters that are not ignored result in error.InvalidCharacter.</span></span>
<span class="line" id="L259">    <span class="tok-comment">/// Invalid padding results in error.InvalidPadding.</span></span>
<span class="line" id="L260">    <span class="tok-comment">/// Decoding more data than can fit in dest results in error.NoSpaceLeft. See also ::calcSizeUpperBound.</span></span>
<span class="line" id="L261">    <span class="tok-comment">/// Returns the number of bytes written to dest.</span></span>
<span class="line" id="L262">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">decode</span>(decoder_with_ignore: *<span class="tok-kw">const</span> Base64DecoderWithIgnore, dest: []<span class="tok-type">u8</span>, source: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) Error!<span class="tok-type">usize</span> {</span>
<span class="line" id="L263">        <span class="tok-kw">const</span> decoder = &amp;decoder_with_ignore.decoder;</span>
<span class="line" id="L264">        <span class="tok-kw">var</span> acc: <span class="tok-type">u12</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L265">        <span class="tok-kw">var</span> acc_len: <span class="tok-type">u4</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L266">        <span class="tok-kw">var</span> dest_idx: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L267">        <span class="tok-kw">var</span> leftover_idx: ?<span class="tok-type">usize</span> = <span class="tok-null">null</span>;</span>
<span class="line" id="L268">        <span class="tok-kw">for</span> (source) |c, src_idx| {</span>
<span class="line" id="L269">            <span class="tok-kw">if</span> (decoder_with_ignore.char_is_ignored[c]) <span class="tok-kw">continue</span>;</span>
<span class="line" id="L270">            <span class="tok-kw">const</span> d = decoder.char_to_index[c];</span>
<span class="line" id="L271">            <span class="tok-kw">if</span> (d == Base64Decoder.invalid_char) {</span>
<span class="line" id="L272">                <span class="tok-kw">if</span> (decoder.pad_char == <span class="tok-null">null</span> <span class="tok-kw">or</span> c != decoder.pad_char.?) <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InvalidCharacter;</span>
<span class="line" id="L273">                leftover_idx = src_idx;</span>
<span class="line" id="L274">                <span class="tok-kw">break</span>;</span>
<span class="line" id="L275">            }</span>
<span class="line" id="L276">            acc = (acc &lt;&lt; <span class="tok-number">6</span>) + d;</span>
<span class="line" id="L277">            acc_len += <span class="tok-number">6</span>;</span>
<span class="line" id="L278">            <span class="tok-kw">if</span> (acc_len &gt;= <span class="tok-number">8</span>) {</span>
<span class="line" id="L279">                <span class="tok-kw">if</span> (dest_idx == dest.len) <span class="tok-kw">return</span> <span class="tok-kw">error</span>.NoSpaceLeft;</span>
<span class="line" id="L280">                acc_len -= <span class="tok-number">8</span>;</span>
<span class="line" id="L281">                dest[dest_idx] = <span class="tok-builtin">@truncate</span>(<span class="tok-type">u8</span>, acc &gt;&gt; acc_len);</span>
<span class="line" id="L282">                dest_idx += <span class="tok-number">1</span>;</span>
<span class="line" id="L283">            }</span>
<span class="line" id="L284">        }</span>
<span class="line" id="L285">        <span class="tok-kw">if</span> (acc_len &gt; <span class="tok-number">4</span> <span class="tok-kw">or</span> (acc &amp; (<span class="tok-builtin">@as</span>(<span class="tok-type">u12</span>, <span class="tok-number">1</span>) &lt;&lt; acc_len) - <span class="tok-number">1</span>) != <span class="tok-number">0</span>) {</span>
<span class="line" id="L286">            <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InvalidPadding;</span>
<span class="line" id="L287">        }</span>
<span class="line" id="L288">        <span class="tok-kw">const</span> padding_len = acc_len / <span class="tok-number">2</span>;</span>
<span class="line" id="L289">        <span class="tok-kw">if</span> (leftover_idx == <span class="tok-null">null</span>) {</span>
<span class="line" id="L290">            <span class="tok-kw">if</span> (decoder.pad_char != <span class="tok-null">null</span> <span class="tok-kw">and</span> padding_len != <span class="tok-number">0</span>) <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InvalidPadding;</span>
<span class="line" id="L291">            <span class="tok-kw">return</span> dest_idx;</span>
<span class="line" id="L292">        }</span>
<span class="line" id="L293">        <span class="tok-kw">var</span> leftover = source[leftover_idx.?..];</span>
<span class="line" id="L294">        <span class="tok-kw">if</span> (decoder.pad_char) |pad_char| {</span>
<span class="line" id="L295">            <span class="tok-kw">var</span> padding_chars: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L296">            <span class="tok-kw">for</span> (leftover) |c| {</span>
<span class="line" id="L297">                <span class="tok-kw">if</span> (decoder_with_ignore.char_is_ignored[c]) <span class="tok-kw">continue</span>;</span>
<span class="line" id="L298">                <span class="tok-kw">if</span> (c != pad_char) {</span>
<span class="line" id="L299">                    <span class="tok-kw">return</span> <span class="tok-kw">if</span> (c == Base64Decoder.invalid_char) <span class="tok-kw">error</span>.InvalidCharacter <span class="tok-kw">else</span> <span class="tok-kw">error</span>.InvalidPadding;</span>
<span class="line" id="L300">                }</span>
<span class="line" id="L301">                padding_chars += <span class="tok-number">1</span>;</span>
<span class="line" id="L302">            }</span>
<span class="line" id="L303">            <span class="tok-kw">if</span> (padding_chars != padding_len) <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InvalidPadding;</span>
<span class="line" id="L304">        }</span>
<span class="line" id="L305">        <span class="tok-kw">return</span> dest_idx;</span>
<span class="line" id="L306">    }</span>
<span class="line" id="L307">};</span>
<span class="line" id="L308"></span>
<span class="line" id="L309"><span class="tok-kw">test</span> <span class="tok-str">&quot;base64&quot;</span> {</span>
<span class="line" id="L310">    <span class="tok-builtin">@setEvalBranchQuota</span>(<span class="tok-number">8000</span>);</span>
<span class="line" id="L311">    <span class="tok-kw">try</span> testBase64();</span>
<span class="line" id="L312">    <span class="tok-kw">comptime</span> <span class="tok-kw">try</span> testAllApis(standard, <span class="tok-str">&quot;comptime&quot;</span>, <span class="tok-str">&quot;Y29tcHRpbWU=&quot;</span>);</span>
<span class="line" id="L313">}</span>
<span class="line" id="L314"></span>
<span class="line" id="L315"><span class="tok-kw">test</span> <span class="tok-str">&quot;base64 url_safe_no_pad&quot;</span> {</span>
<span class="line" id="L316">    <span class="tok-builtin">@setEvalBranchQuota</span>(<span class="tok-number">8000</span>);</span>
<span class="line" id="L317">    <span class="tok-kw">try</span> testBase64UrlSafeNoPad();</span>
<span class="line" id="L318">    <span class="tok-kw">comptime</span> <span class="tok-kw">try</span> testAllApis(url_safe_no_pad, <span class="tok-str">&quot;comptime&quot;</span>, <span class="tok-str">&quot;Y29tcHRpbWU&quot;</span>);</span>
<span class="line" id="L319">}</span>
<span class="line" id="L320"></span>
<span class="line" id="L321"><span class="tok-kw">fn</span> <span class="tok-fn">testBase64</span>() !<span class="tok-type">void</span> {</span>
<span class="line" id="L322">    <span class="tok-kw">const</span> codecs = standard;</span>
<span class="line" id="L323"></span>
<span class="line" id="L324">    <span class="tok-kw">try</span> testAllApis(codecs, <span class="tok-str">&quot;&quot;</span>, <span class="tok-str">&quot;&quot;</span>);</span>
<span class="line" id="L325">    <span class="tok-kw">try</span> testAllApis(codecs, <span class="tok-str">&quot;f&quot;</span>, <span class="tok-str">&quot;Zg==&quot;</span>);</span>
<span class="line" id="L326">    <span class="tok-kw">try</span> testAllApis(codecs, <span class="tok-str">&quot;fo&quot;</span>, <span class="tok-str">&quot;Zm8=&quot;</span>);</span>
<span class="line" id="L327">    <span class="tok-kw">try</span> testAllApis(codecs, <span class="tok-str">&quot;foo&quot;</span>, <span class="tok-str">&quot;Zm9v&quot;</span>);</span>
<span class="line" id="L328">    <span class="tok-kw">try</span> testAllApis(codecs, <span class="tok-str">&quot;foob&quot;</span>, <span class="tok-str">&quot;Zm9vYg==&quot;</span>);</span>
<span class="line" id="L329">    <span class="tok-kw">try</span> testAllApis(codecs, <span class="tok-str">&quot;fooba&quot;</span>, <span class="tok-str">&quot;Zm9vYmE=&quot;</span>);</span>
<span class="line" id="L330">    <span class="tok-kw">try</span> testAllApis(codecs, <span class="tok-str">&quot;foobar&quot;</span>, <span class="tok-str">&quot;Zm9vYmFy&quot;</span>);</span>
<span class="line" id="L331"></span>
<span class="line" id="L332">    <span class="tok-kw">try</span> testDecodeIgnoreSpace(codecs, <span class="tok-str">&quot;&quot;</span>, <span class="tok-str">&quot; &quot;</span>);</span>
<span class="line" id="L333">    <span class="tok-kw">try</span> testDecodeIgnoreSpace(codecs, <span class="tok-str">&quot;f&quot;</span>, <span class="tok-str">&quot;Z g= =&quot;</span>);</span>
<span class="line" id="L334">    <span class="tok-kw">try</span> testDecodeIgnoreSpace(codecs, <span class="tok-str">&quot;fo&quot;</span>, <span class="tok-str">&quot;    Zm8=&quot;</span>);</span>
<span class="line" id="L335">    <span class="tok-kw">try</span> testDecodeIgnoreSpace(codecs, <span class="tok-str">&quot;foo&quot;</span>, <span class="tok-str">&quot;Zm9v    &quot;</span>);</span>
<span class="line" id="L336">    <span class="tok-kw">try</span> testDecodeIgnoreSpace(codecs, <span class="tok-str">&quot;foob&quot;</span>, <span class="tok-str">&quot;Zm9vYg = = &quot;</span>);</span>
<span class="line" id="L337">    <span class="tok-kw">try</span> testDecodeIgnoreSpace(codecs, <span class="tok-str">&quot;fooba&quot;</span>, <span class="tok-str">&quot;Zm9v YmE=&quot;</span>);</span>
<span class="line" id="L338">    <span class="tok-kw">try</span> testDecodeIgnoreSpace(codecs, <span class="tok-str">&quot;foobar&quot;</span>, <span class="tok-str">&quot; Z m 9 v Y m F y &quot;</span>);</span>
<span class="line" id="L339"></span>
<span class="line" id="L340">    <span class="tok-comment">// test getting some api errors</span>
</span>
<span class="line" id="L341">    <span class="tok-kw">try</span> testError(codecs, <span class="tok-str">&quot;A&quot;</span>, <span class="tok-kw">error</span>.InvalidPadding);</span>
<span class="line" id="L342">    <span class="tok-kw">try</span> testError(codecs, <span class="tok-str">&quot;AA&quot;</span>, <span class="tok-kw">error</span>.InvalidPadding);</span>
<span class="line" id="L343">    <span class="tok-kw">try</span> testError(codecs, <span class="tok-str">&quot;AAA&quot;</span>, <span class="tok-kw">error</span>.InvalidPadding);</span>
<span class="line" id="L344">    <span class="tok-kw">try</span> testError(codecs, <span class="tok-str">&quot;A..A&quot;</span>, <span class="tok-kw">error</span>.InvalidCharacter);</span>
<span class="line" id="L345">    <span class="tok-kw">try</span> testError(codecs, <span class="tok-str">&quot;AA=A&quot;</span>, <span class="tok-kw">error</span>.InvalidPadding);</span>
<span class="line" id="L346">    <span class="tok-kw">try</span> testError(codecs, <span class="tok-str">&quot;AA/=&quot;</span>, <span class="tok-kw">error</span>.InvalidPadding);</span>
<span class="line" id="L347">    <span class="tok-kw">try</span> testError(codecs, <span class="tok-str">&quot;A/==&quot;</span>, <span class="tok-kw">error</span>.InvalidPadding);</span>
<span class="line" id="L348">    <span class="tok-kw">try</span> testError(codecs, <span class="tok-str">&quot;A===&quot;</span>, <span class="tok-kw">error</span>.InvalidPadding);</span>
<span class="line" id="L349">    <span class="tok-kw">try</span> testError(codecs, <span class="tok-str">&quot;====&quot;</span>, <span class="tok-kw">error</span>.InvalidPadding);</span>
<span class="line" id="L350"></span>
<span class="line" id="L351">    <span class="tok-kw">try</span> testNoSpaceLeftError(codecs, <span class="tok-str">&quot;AA==&quot;</span>);</span>
<span class="line" id="L352">    <span class="tok-kw">try</span> testNoSpaceLeftError(codecs, <span class="tok-str">&quot;AAA=&quot;</span>);</span>
<span class="line" id="L353">    <span class="tok-kw">try</span> testNoSpaceLeftError(codecs, <span class="tok-str">&quot;AAAA&quot;</span>);</span>
<span class="line" id="L354">    <span class="tok-kw">try</span> testNoSpaceLeftError(codecs, <span class="tok-str">&quot;AAAAAA==&quot;</span>);</span>
<span class="line" id="L355">}</span>
<span class="line" id="L356"></span>
<span class="line" id="L357"><span class="tok-kw">fn</span> <span class="tok-fn">testBase64UrlSafeNoPad</span>() !<span class="tok-type">void</span> {</span>
<span class="line" id="L358">    <span class="tok-kw">const</span> codecs = url_safe_no_pad;</span>
<span class="line" id="L359"></span>
<span class="line" id="L360">    <span class="tok-kw">try</span> testAllApis(codecs, <span class="tok-str">&quot;&quot;</span>, <span class="tok-str">&quot;&quot;</span>);</span>
<span class="line" id="L361">    <span class="tok-kw">try</span> testAllApis(codecs, <span class="tok-str">&quot;f&quot;</span>, <span class="tok-str">&quot;Zg&quot;</span>);</span>
<span class="line" id="L362">    <span class="tok-kw">try</span> testAllApis(codecs, <span class="tok-str">&quot;fo&quot;</span>, <span class="tok-str">&quot;Zm8&quot;</span>);</span>
<span class="line" id="L363">    <span class="tok-kw">try</span> testAllApis(codecs, <span class="tok-str">&quot;foo&quot;</span>, <span class="tok-str">&quot;Zm9v&quot;</span>);</span>
<span class="line" id="L364">    <span class="tok-kw">try</span> testAllApis(codecs, <span class="tok-str">&quot;foob&quot;</span>, <span class="tok-str">&quot;Zm9vYg&quot;</span>);</span>
<span class="line" id="L365">    <span class="tok-kw">try</span> testAllApis(codecs, <span class="tok-str">&quot;fooba&quot;</span>, <span class="tok-str">&quot;Zm9vYmE&quot;</span>);</span>
<span class="line" id="L366">    <span class="tok-kw">try</span> testAllApis(codecs, <span class="tok-str">&quot;foobar&quot;</span>, <span class="tok-str">&quot;Zm9vYmFy&quot;</span>);</span>
<span class="line" id="L367"></span>
<span class="line" id="L368">    <span class="tok-kw">try</span> testDecodeIgnoreSpace(codecs, <span class="tok-str">&quot;&quot;</span>, <span class="tok-str">&quot; &quot;</span>);</span>
<span class="line" id="L369">    <span class="tok-kw">try</span> testDecodeIgnoreSpace(codecs, <span class="tok-str">&quot;f&quot;</span>, <span class="tok-str">&quot;Z g &quot;</span>);</span>
<span class="line" id="L370">    <span class="tok-kw">try</span> testDecodeIgnoreSpace(codecs, <span class="tok-str">&quot;fo&quot;</span>, <span class="tok-str">&quot;    Zm8&quot;</span>);</span>
<span class="line" id="L371">    <span class="tok-kw">try</span> testDecodeIgnoreSpace(codecs, <span class="tok-str">&quot;foo&quot;</span>, <span class="tok-str">&quot;Zm9v    &quot;</span>);</span>
<span class="line" id="L372">    <span class="tok-kw">try</span> testDecodeIgnoreSpace(codecs, <span class="tok-str">&quot;foob&quot;</span>, <span class="tok-str">&quot;Zm9vYg   &quot;</span>);</span>
<span class="line" id="L373">    <span class="tok-kw">try</span> testDecodeIgnoreSpace(codecs, <span class="tok-str">&quot;fooba&quot;</span>, <span class="tok-str">&quot;Zm9v YmE&quot;</span>);</span>
<span class="line" id="L374">    <span class="tok-kw">try</span> testDecodeIgnoreSpace(codecs, <span class="tok-str">&quot;foobar&quot;</span>, <span class="tok-str">&quot; Z m 9 v Y m F y &quot;</span>);</span>
<span class="line" id="L375"></span>
<span class="line" id="L376">    <span class="tok-comment">// test getting some api errors</span>
</span>
<span class="line" id="L377">    <span class="tok-kw">try</span> testError(codecs, <span class="tok-str">&quot;A&quot;</span>, <span class="tok-kw">error</span>.InvalidPadding);</span>
<span class="line" id="L378">    <span class="tok-kw">try</span> testError(codecs, <span class="tok-str">&quot;AAA=&quot;</span>, <span class="tok-kw">error</span>.InvalidCharacter);</span>
<span class="line" id="L379">    <span class="tok-kw">try</span> testError(codecs, <span class="tok-str">&quot;A..A&quot;</span>, <span class="tok-kw">error</span>.InvalidCharacter);</span>
<span class="line" id="L380">    <span class="tok-kw">try</span> testError(codecs, <span class="tok-str">&quot;AA=A&quot;</span>, <span class="tok-kw">error</span>.InvalidCharacter);</span>
<span class="line" id="L381">    <span class="tok-kw">try</span> testError(codecs, <span class="tok-str">&quot;AA/=&quot;</span>, <span class="tok-kw">error</span>.InvalidCharacter);</span>
<span class="line" id="L382">    <span class="tok-kw">try</span> testError(codecs, <span class="tok-str">&quot;A/==&quot;</span>, <span class="tok-kw">error</span>.InvalidCharacter);</span>
<span class="line" id="L383">    <span class="tok-kw">try</span> testError(codecs, <span class="tok-str">&quot;A===&quot;</span>, <span class="tok-kw">error</span>.InvalidCharacter);</span>
<span class="line" id="L384">    <span class="tok-kw">try</span> testError(codecs, <span class="tok-str">&quot;====&quot;</span>, <span class="tok-kw">error</span>.InvalidCharacter);</span>
<span class="line" id="L385"></span>
<span class="line" id="L386">    <span class="tok-kw">try</span> testNoSpaceLeftError(codecs, <span class="tok-str">&quot;AA&quot;</span>);</span>
<span class="line" id="L387">    <span class="tok-kw">try</span> testNoSpaceLeftError(codecs, <span class="tok-str">&quot;AAA&quot;</span>);</span>
<span class="line" id="L388">    <span class="tok-kw">try</span> testNoSpaceLeftError(codecs, <span class="tok-str">&quot;AAAA&quot;</span>);</span>
<span class="line" id="L389">    <span class="tok-kw">try</span> testNoSpaceLeftError(codecs, <span class="tok-str">&quot;AAAAAA&quot;</span>);</span>
<span class="line" id="L390">}</span>
<span class="line" id="L391"></span>
<span class="line" id="L392"><span class="tok-kw">fn</span> <span class="tok-fn">testAllApis</span>(codecs: Codecs, expected_decoded: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, expected_encoded: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) !<span class="tok-type">void</span> {</span>
<span class="line" id="L393">    <span class="tok-comment">// Base64Encoder</span>
</span>
<span class="line" id="L394">    {</span>
<span class="line" id="L395">        <span class="tok-kw">var</span> buffer: [<span class="tok-number">0x100</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L396">        <span class="tok-kw">const</span> encoded = codecs.Encoder.encode(&amp;buffer, expected_decoded);</span>
<span class="line" id="L397">        <span class="tok-kw">try</span> testing.expectEqualSlices(<span class="tok-type">u8</span>, expected_encoded, encoded);</span>
<span class="line" id="L398">    }</span>
<span class="line" id="L399"></span>
<span class="line" id="L400">    <span class="tok-comment">// Base64Decoder</span>
</span>
<span class="line" id="L401">    {</span>
<span class="line" id="L402">        <span class="tok-kw">var</span> buffer: [<span class="tok-number">0x100</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L403">        <span class="tok-kw">var</span> decoded = buffer[<span class="tok-number">0</span>..<span class="tok-kw">try</span> codecs.Decoder.calcSizeForSlice(expected_encoded)];</span>
<span class="line" id="L404">        <span class="tok-kw">try</span> codecs.Decoder.decode(decoded, expected_encoded);</span>
<span class="line" id="L405">        <span class="tok-kw">try</span> testing.expectEqualSlices(<span class="tok-type">u8</span>, expected_decoded, decoded);</span>
<span class="line" id="L406">    }</span>
<span class="line" id="L407"></span>
<span class="line" id="L408">    <span class="tok-comment">// Base64DecoderWithIgnore</span>
</span>
<span class="line" id="L409">    {</span>
<span class="line" id="L410">        <span class="tok-kw">const</span> decoder_ignore_nothing = codecs.decoderWithIgnore(<span class="tok-str">&quot;&quot;</span>);</span>
<span class="line" id="L411">        <span class="tok-kw">var</span> buffer: [<span class="tok-number">0x100</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L412">        <span class="tok-kw">var</span> decoded = buffer[<span class="tok-number">0</span>..<span class="tok-kw">try</span> decoder_ignore_nothing.calcSizeUpperBound(expected_encoded.len)];</span>
<span class="line" id="L413">        <span class="tok-kw">var</span> written = <span class="tok-kw">try</span> decoder_ignore_nothing.decode(decoded, expected_encoded);</span>
<span class="line" id="L414">        <span class="tok-kw">try</span> testing.expect(written &lt;= decoded.len);</span>
<span class="line" id="L415">        <span class="tok-kw">try</span> testing.expectEqualSlices(<span class="tok-type">u8</span>, expected_decoded, decoded[<span class="tok-number">0</span>..written]);</span>
<span class="line" id="L416">    }</span>
<span class="line" id="L417">}</span>
<span class="line" id="L418"></span>
<span class="line" id="L419"><span class="tok-kw">fn</span> <span class="tok-fn">testDecodeIgnoreSpace</span>(codecs: Codecs, expected_decoded: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, encoded: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) !<span class="tok-type">void</span> {</span>
<span class="line" id="L420">    <span class="tok-kw">const</span> decoder_ignore_space = codecs.decoderWithIgnore(<span class="tok-str">&quot; &quot;</span>);</span>
<span class="line" id="L421">    <span class="tok-kw">var</span> buffer: [<span class="tok-number">0x100</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L422">    <span class="tok-kw">var</span> decoded = buffer[<span class="tok-number">0</span>..<span class="tok-kw">try</span> decoder_ignore_space.calcSizeUpperBound(encoded.len)];</span>
<span class="line" id="L423">    <span class="tok-kw">var</span> written = <span class="tok-kw">try</span> decoder_ignore_space.decode(decoded, encoded);</span>
<span class="line" id="L424">    <span class="tok-kw">try</span> testing.expectEqualSlices(<span class="tok-type">u8</span>, expected_decoded, decoded[<span class="tok-number">0</span>..written]);</span>
<span class="line" id="L425">}</span>
<span class="line" id="L426"></span>
<span class="line" id="L427"><span class="tok-kw">fn</span> <span class="tok-fn">testError</span>(codecs: Codecs, encoded: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, expected_err: <span class="tok-type">anyerror</span>) !<span class="tok-type">void</span> {</span>
<span class="line" id="L428">    <span class="tok-kw">const</span> decoder_ignore_space = codecs.decoderWithIgnore(<span class="tok-str">&quot; &quot;</span>);</span>
<span class="line" id="L429">    <span class="tok-kw">var</span> buffer: [<span class="tok-number">0x100</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L430">    <span class="tok-kw">if</span> (codecs.Decoder.calcSizeForSlice(encoded)) |decoded_size| {</span>
<span class="line" id="L431">        <span class="tok-kw">var</span> decoded = buffer[<span class="tok-number">0</span>..decoded_size];</span>
<span class="line" id="L432">        <span class="tok-kw">if</span> (codecs.Decoder.decode(decoded, encoded)) |_| {</span>
<span class="line" id="L433">            <span class="tok-kw">return</span> <span class="tok-kw">error</span>.ExpectedError;</span>
<span class="line" id="L434">        } <span class="tok-kw">else</span> |err| <span class="tok-kw">if</span> (err != expected_err) <span class="tok-kw">return</span> err;</span>
<span class="line" id="L435">    } <span class="tok-kw">else</span> |err| <span class="tok-kw">if</span> (err != expected_err) <span class="tok-kw">return</span> err;</span>
<span class="line" id="L436"></span>
<span class="line" id="L437">    <span class="tok-kw">if</span> (decoder_ignore_space.decode(buffer[<span class="tok-number">0</span>..], encoded)) |_| {</span>
<span class="line" id="L438">        <span class="tok-kw">return</span> <span class="tok-kw">error</span>.ExpectedError;</span>
<span class="line" id="L439">    } <span class="tok-kw">else</span> |err| <span class="tok-kw">if</span> (err != expected_err) <span class="tok-kw">return</span> err;</span>
<span class="line" id="L440">}</span>
<span class="line" id="L441"></span>
<span class="line" id="L442"><span class="tok-kw">fn</span> <span class="tok-fn">testNoSpaceLeftError</span>(codecs: Codecs, encoded: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) !<span class="tok-type">void</span> {</span>
<span class="line" id="L443">    <span class="tok-kw">const</span> decoder_ignore_space = codecs.decoderWithIgnore(<span class="tok-str">&quot; &quot;</span>);</span>
<span class="line" id="L444">    <span class="tok-kw">var</span> buffer: [<span class="tok-number">0x100</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L445">    <span class="tok-kw">var</span> decoded = buffer[<span class="tok-number">0</span> .. (<span class="tok-kw">try</span> codecs.Decoder.calcSizeForSlice(encoded)) - <span class="tok-number">1</span>];</span>
<span class="line" id="L446">    <span class="tok-kw">if</span> (decoder_ignore_space.decode(decoded, encoded)) |_| {</span>
<span class="line" id="L447">        <span class="tok-kw">return</span> <span class="tok-kw">error</span>.ExpectedError;</span>
<span class="line" id="L448">    } <span class="tok-kw">else</span> |err| <span class="tok-kw">if</span> (err != <span class="tok-kw">error</span>.NoSpaceLeft) <span class="tok-kw">return</span> err;</span>
<span class="line" id="L449">}</span>
<span class="line" id="L450"></span>
</code></pre></body>
</html>