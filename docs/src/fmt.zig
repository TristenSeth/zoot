<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">    <title>fmt.zig - source view</title>
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
<span class="line" id="L2"><span class="tok-kw">const</span> io = std.io;</span>
<span class="line" id="L3"><span class="tok-kw">const</span> math = std.math;</span>
<span class="line" id="L4"><span class="tok-kw">const</span> assert = std.debug.assert;</span>
<span class="line" id="L5"><span class="tok-kw">const</span> mem = std.mem;</span>
<span class="line" id="L6"><span class="tok-kw">const</span> unicode = std.unicode;</span>
<span class="line" id="L7"><span class="tok-kw">const</span> meta = std.meta;</span>
<span class="line" id="L8"><span class="tok-kw">const</span> builtin = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;builtin&quot;</span>);</span>
<span class="line" id="L9"><span class="tok-kw">const</span> errol = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;fmt/errol.zig&quot;</span>);</span>
<span class="line" id="L10"><span class="tok-kw">const</span> lossyCast = std.math.lossyCast;</span>
<span class="line" id="L11"><span class="tok-kw">const</span> expectFmt = std.testing.expectFmt;</span>
<span class="line" id="L12"></span>
<span class="line" id="L13"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> default_max_depth = <span class="tok-number">3</span>;</span>
<span class="line" id="L14"></span>
<span class="line" id="L15"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> Alignment = <span class="tok-kw">enum</span> {</span>
<span class="line" id="L16">    Left,</span>
<span class="line" id="L17">    Center,</span>
<span class="line" id="L18">    Right,</span>
<span class="line" id="L19">};</span>
<span class="line" id="L20"></span>
<span class="line" id="L21"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FormatOptions = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L22">    precision: ?<span class="tok-type">usize</span> = <span class="tok-null">null</span>,</span>
<span class="line" id="L23">    width: ?<span class="tok-type">usize</span> = <span class="tok-null">null</span>,</span>
<span class="line" id="L24">    alignment: Alignment = .Right,</span>
<span class="line" id="L25">    fill: <span class="tok-type">u8</span> = <span class="tok-str">' '</span>,</span>
<span class="line" id="L26">};</span>
<span class="line" id="L27"></span>
<span class="line" id="L28"><span class="tok-comment">/// Renders fmt string with args, calling `writer` with slices of bytes.</span></span>
<span class="line" id="L29"><span class="tok-comment">/// If `writer` returns an error, the error is returned from `format` and</span></span>
<span class="line" id="L30"><span class="tok-comment">/// `writer` is not called again.</span></span>
<span class="line" id="L31"><span class="tok-comment">///</span></span>
<span class="line" id="L32"><span class="tok-comment">/// The format string must be comptime known and may contain placeholders following</span></span>
<span class="line" id="L33"><span class="tok-comment">/// this format:</span></span>
<span class="line" id="L34"><span class="tok-comment">/// `{[argument][specifier]:[fill][alignment][width].[precision]}`</span></span>
<span class="line" id="L35"><span class="tok-comment">///</span></span>
<span class="line" id="L36"><span class="tok-comment">/// Above, each word including its surrounding [ and ] is a parameter which you have to replace with something:</span></span>
<span class="line" id="L37"><span class="tok-comment">///</span></span>
<span class="line" id="L38"><span class="tok-comment">/// - *argument* is either the numeric index or the field name of the argument that should be inserted</span></span>
<span class="line" id="L39"><span class="tok-comment">///   - when using a field name, you are required to enclose the field name (an identifier) in square</span></span>
<span class="line" id="L40"><span class="tok-comment">///     brackets, e.g. {[score]...} as opposed to the numeric index form which can be written e.g. {2...}</span></span>
<span class="line" id="L41"><span class="tok-comment">/// - *specifier* is a type-dependent formatting option that determines how a type should formatted (see below)</span></span>
<span class="line" id="L42"><span class="tok-comment">/// - *fill* is a single character which is used to pad the formatted text</span></span>
<span class="line" id="L43"><span class="tok-comment">/// - *alignment* is one of the three characters `&lt;`, `^` or `&gt;`. they define if the text is *left*, *center*, or *right* aligned</span></span>
<span class="line" id="L44"><span class="tok-comment">/// - *width* is the total width of the field in characters</span></span>
<span class="line" id="L45"><span class="tok-comment">/// - *precision* specifies how many decimals a formatted number should have</span></span>
<span class="line" id="L46"><span class="tok-comment">///</span></span>
<span class="line" id="L47"><span class="tok-comment">/// Note that most of the parameters are optional and may be omitted. Also you can leave out separators like `:` and `.` when</span></span>
<span class="line" id="L48"><span class="tok-comment">/// all parameters after the separator are omitted.</span></span>
<span class="line" id="L49"><span class="tok-comment">/// Only exception is the *fill* parameter. If *fill* is required, one has to specify *alignment* as well, as otherwise</span></span>
<span class="line" id="L50"><span class="tok-comment">/// the digits after `:` is interpreted as *width*, not *fill*.</span></span>
<span class="line" id="L51"><span class="tok-comment">///</span></span>
<span class="line" id="L52"><span class="tok-comment">/// The *specifier* has several options for types:</span></span>
<span class="line" id="L53"><span class="tok-comment">/// - `x` and `X`: output numeric value in hexadecimal notation</span></span>
<span class="line" id="L54"><span class="tok-comment">/// - `s`:</span></span>
<span class="line" id="L55"><span class="tok-comment">///   - for pointer-to-many and C pointers of u8, print as a C-string using zero-termination</span></span>
<span class="line" id="L56"><span class="tok-comment">///   - for slices of u8, print the entire slice as a string without zero-termination</span></span>
<span class="line" id="L57"><span class="tok-comment">/// - `e`: output floating point value in scientific notation</span></span>
<span class="line" id="L58"><span class="tok-comment">/// - `d`: output numeric value in decimal notation</span></span>
<span class="line" id="L59"><span class="tok-comment">/// - `b`: output integer value in binary notation</span></span>
<span class="line" id="L60"><span class="tok-comment">/// - `o`: output integer value in octal notation</span></span>
<span class="line" id="L61"><span class="tok-comment">/// - `c`: output integer as an ASCII character. Integer type must have 8 bits at max.</span></span>
<span class="line" id="L62"><span class="tok-comment">/// - `u`: output integer as an UTF-8 sequence. Integer type must have 21 bits at max.</span></span>
<span class="line" id="L63"><span class="tok-comment">/// - `?`: output optional value as either the unwrapped value, or `null`; may be followed by a format specifier for the underlying value.</span></span>
<span class="line" id="L64"><span class="tok-comment">/// - `!`: output error union value as either the unwrapped value, or the formatted error value; may be followed by a format specifier for the underlying value.</span></span>
<span class="line" id="L65"><span class="tok-comment">/// - `*`: output the address of the value instead of the value itself.</span></span>
<span class="line" id="L66"><span class="tok-comment">/// - `any`: output a value of any type using its default format.</span></span>
<span class="line" id="L67"><span class="tok-comment">///</span></span>
<span class="line" id="L68"><span class="tok-comment">/// If a formatted user type contains a function of the type</span></span>
<span class="line" id="L69"><span class="tok-comment">/// ```</span></span>
<span class="line" id="L70"><span class="tok-comment">/// pub fn format(value: ?, comptime fmt: []const u8, options: std.fmt.FormatOptions, writer: anytype) !void</span></span>
<span class="line" id="L71"><span class="tok-comment">/// ```</span></span>
<span class="line" id="L72"><span class="tok-comment">/// with `?` being the type formatted, this function will be called instead of the default implementation.</span></span>
<span class="line" id="L73"><span class="tok-comment">/// This allows user types to be formatted in a logical manner instead of dumping all fields of the type.</span></span>
<span class="line" id="L74"><span class="tok-comment">///</span></span>
<span class="line" id="L75"><span class="tok-comment">/// A user type may be a `struct`, `vector`, `union` or `enum` type.</span></span>
<span class="line" id="L76"><span class="tok-comment">///</span></span>
<span class="line" id="L77"><span class="tok-comment">/// To print literal curly braces, escape them by writing them twice, e.g. `{{` or `}}`.</span></span>
<span class="line" id="L78"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">format</span>(</span>
<span class="line" id="L79">    writer: <span class="tok-kw">anytype</span>,</span>
<span class="line" id="L80">    <span class="tok-kw">comptime</span> fmt: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L81">    args: <span class="tok-kw">anytype</span>,</span>
<span class="line" id="L82">) !<span class="tok-type">void</span> {</span>
<span class="line" id="L83">    <span class="tok-kw">const</span> ArgsType = <span class="tok-builtin">@TypeOf</span>(args);</span>
<span class="line" id="L84">    <span class="tok-kw">const</span> args_type_info = <span class="tok-builtin">@typeInfo</span>(ArgsType);</span>
<span class="line" id="L85">    <span class="tok-kw">if</span> (args_type_info != .Struct) {</span>
<span class="line" id="L86">        <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;expected tuple or struct argument, found &quot;</span> ++ <span class="tok-builtin">@typeName</span>(ArgsType));</span>
<span class="line" id="L87">    }</span>
<span class="line" id="L88"></span>
<span class="line" id="L89">    <span class="tok-kw">const</span> fields_info = args_type_info.Struct.fields;</span>
<span class="line" id="L90">    <span class="tok-kw">if</span> (fields_info.len &gt; max_format_args) {</span>
<span class="line" id="L91">        <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;32 arguments max are supported per format call&quot;</span>);</span>
<span class="line" id="L92">    }</span>
<span class="line" id="L93"></span>
<span class="line" id="L94">    <span class="tok-builtin">@setEvalBranchQuota</span>(<span class="tok-number">2000000</span>);</span>
<span class="line" id="L95">    <span class="tok-kw">comptime</span> <span class="tok-kw">var</span> arg_state: ArgState = .{ .args_len = fields_info.len };</span>
<span class="line" id="L96">    <span class="tok-kw">comptime</span> <span class="tok-kw">var</span> i = <span class="tok-number">0</span>;</span>
<span class="line" id="L97">    <span class="tok-kw">inline</span> <span class="tok-kw">while</span> (i &lt; fmt.len) {</span>
<span class="line" id="L98">        <span class="tok-kw">const</span> start_index = i;</span>
<span class="line" id="L99"></span>
<span class="line" id="L100">        <span class="tok-kw">inline</span> <span class="tok-kw">while</span> (i &lt; fmt.len) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L101">            <span class="tok-kw">switch</span> (fmt[i]) {</span>
<span class="line" id="L102">                <span class="tok-str">'{'</span>, <span class="tok-str">'}'</span> =&gt; <span class="tok-kw">break</span>,</span>
<span class="line" id="L103">                <span class="tok-kw">else</span> =&gt; {},</span>
<span class="line" id="L104">            }</span>
<span class="line" id="L105">        }</span>
<span class="line" id="L106"></span>
<span class="line" id="L107">        <span class="tok-kw">comptime</span> <span class="tok-kw">var</span> end_index = i;</span>
<span class="line" id="L108">        <span class="tok-kw">comptime</span> <span class="tok-kw">var</span> unescape_brace = <span class="tok-null">false</span>;</span>
<span class="line" id="L109"></span>
<span class="line" id="L110">        <span class="tok-comment">// Handle {{ and }}, those are un-escaped as single braces</span>
</span>
<span class="line" id="L111">        <span class="tok-kw">if</span> (i + <span class="tok-number">1</span> &lt; fmt.len <span class="tok-kw">and</span> fmt[i + <span class="tok-number">1</span>] == fmt[i]) {</span>
<span class="line" id="L112">            unescape_brace = <span class="tok-null">true</span>;</span>
<span class="line" id="L113">            <span class="tok-comment">// Make the first brace part of the literal...</span>
</span>
<span class="line" id="L114">            end_index += <span class="tok-number">1</span>;</span>
<span class="line" id="L115">            <span class="tok-comment">// ...and skip both</span>
</span>
<span class="line" id="L116">            i += <span class="tok-number">2</span>;</span>
<span class="line" id="L117">        }</span>
<span class="line" id="L118"></span>
<span class="line" id="L119">        <span class="tok-comment">// Write out the literal</span>
</span>
<span class="line" id="L120">        <span class="tok-kw">if</span> (start_index != end_index) {</span>
<span class="line" id="L121">            <span class="tok-kw">try</span> writer.writeAll(fmt[start_index..end_index]);</span>
<span class="line" id="L122">        }</span>
<span class="line" id="L123"></span>
<span class="line" id="L124">        <span class="tok-comment">// We've already skipped the other brace, restart the loop</span>
</span>
<span class="line" id="L125">        <span class="tok-kw">if</span> (unescape_brace) <span class="tok-kw">continue</span>;</span>
<span class="line" id="L126"></span>
<span class="line" id="L127">        <span class="tok-kw">if</span> (i &gt;= fmt.len) <span class="tok-kw">break</span>;</span>
<span class="line" id="L128"></span>
<span class="line" id="L129">        <span class="tok-kw">if</span> (fmt[i] == <span class="tok-str">'}'</span>) {</span>
<span class="line" id="L130">            <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;missing opening {&quot;</span>);</span>
<span class="line" id="L131">        }</span>
<span class="line" id="L132"></span>
<span class="line" id="L133">        <span class="tok-comment">// Get past the {</span>
</span>
<span class="line" id="L134">        <span class="tok-kw">comptime</span> assert(fmt[i] == <span class="tok-str">'{'</span>);</span>
<span class="line" id="L135">        i += <span class="tok-number">1</span>;</span>
<span class="line" id="L136"></span>
<span class="line" id="L137">        <span class="tok-kw">const</span> fmt_begin = i;</span>
<span class="line" id="L138">        <span class="tok-comment">// Find the closing brace</span>
</span>
<span class="line" id="L139">        <span class="tok-kw">inline</span> <span class="tok-kw">while</span> (i &lt; fmt.len <span class="tok-kw">and</span> fmt[i] != <span class="tok-str">'}'</span>) : (i += <span class="tok-number">1</span>) {}</span>
<span class="line" id="L140">        <span class="tok-kw">const</span> fmt_end = i;</span>
<span class="line" id="L141"></span>
<span class="line" id="L142">        <span class="tok-kw">if</span> (i &gt;= fmt.len) {</span>
<span class="line" id="L143">            <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;missing closing }&quot;</span>);</span>
<span class="line" id="L144">        }</span>
<span class="line" id="L145"></span>
<span class="line" id="L146">        <span class="tok-comment">// Get past the }</span>
</span>
<span class="line" id="L147">        <span class="tok-kw">comptime</span> assert(fmt[i] == <span class="tok-str">'}'</span>);</span>
<span class="line" id="L148">        i += <span class="tok-number">1</span>;</span>
<span class="line" id="L149"></span>
<span class="line" id="L150">        <span class="tok-kw">const</span> placeholder = <span class="tok-kw">comptime</span> parsePlaceholder(fmt[fmt_begin..fmt_end].*);</span>
<span class="line" id="L151">        <span class="tok-kw">const</span> arg_pos = <span class="tok-kw">comptime</span> <span class="tok-kw">switch</span> (placeholder.arg) {</span>
<span class="line" id="L152">            .none =&gt; <span class="tok-null">null</span>,</span>
<span class="line" id="L153">            .number =&gt; |pos| pos,</span>
<span class="line" id="L154">            .named =&gt; |arg_name| meta.fieldIndex(ArgsType, arg_name) <span class="tok-kw">orelse</span></span>
<span class="line" id="L155">                <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;no argument with name '&quot;</span> ++ arg_name ++ <span class="tok-str">&quot;'&quot;</span>),</span>
<span class="line" id="L156">        };</span>
<span class="line" id="L157"></span>
<span class="line" id="L158">        <span class="tok-kw">const</span> width = <span class="tok-kw">switch</span> (placeholder.width) {</span>
<span class="line" id="L159">            .none =&gt; <span class="tok-null">null</span>,</span>
<span class="line" id="L160">            .number =&gt; |v| v,</span>
<span class="line" id="L161">            .named =&gt; |arg_name| blk: {</span>
<span class="line" id="L162">                <span class="tok-kw">const</span> arg_i = <span class="tok-kw">comptime</span> meta.fieldIndex(ArgsType, arg_name) <span class="tok-kw">orelse</span></span>
<span class="line" id="L163">                    <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;no argument with name '&quot;</span> ++ arg_name ++ <span class="tok-str">&quot;'&quot;</span>);</span>
<span class="line" id="L164">                _ = <span class="tok-kw">comptime</span> arg_state.nextArg(arg_i) <span class="tok-kw">orelse</span> <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;too few arguments&quot;</span>);</span>
<span class="line" id="L165">                <span class="tok-kw">break</span> :blk <span class="tok-builtin">@field</span>(args, arg_name);</span>
<span class="line" id="L166">            },</span>
<span class="line" id="L167">        };</span>
<span class="line" id="L168"></span>
<span class="line" id="L169">        <span class="tok-kw">const</span> precision = <span class="tok-kw">switch</span> (placeholder.precision) {</span>
<span class="line" id="L170">            .none =&gt; <span class="tok-null">null</span>,</span>
<span class="line" id="L171">            .number =&gt; |v| v,</span>
<span class="line" id="L172">            .named =&gt; |arg_name| blk: {</span>
<span class="line" id="L173">                <span class="tok-kw">const</span> arg_i = <span class="tok-kw">comptime</span> meta.fieldIndex(ArgsType, arg_name) <span class="tok-kw">orelse</span></span>
<span class="line" id="L174">                    <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;no argument with name '&quot;</span> ++ arg_name ++ <span class="tok-str">&quot;'&quot;</span>);</span>
<span class="line" id="L175">                _ = <span class="tok-kw">comptime</span> arg_state.nextArg(arg_i) <span class="tok-kw">orelse</span> <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;too few arguments&quot;</span>);</span>
<span class="line" id="L176">                <span class="tok-kw">break</span> :blk <span class="tok-builtin">@field</span>(args, arg_name);</span>
<span class="line" id="L177">            },</span>
<span class="line" id="L178">        };</span>
<span class="line" id="L179"></span>
<span class="line" id="L180">        <span class="tok-kw">const</span> arg_to_print = <span class="tok-kw">comptime</span> arg_state.nextArg(arg_pos) <span class="tok-kw">orelse</span></span>
<span class="line" id="L181">            <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;too few arguments&quot;</span>);</span>
<span class="line" id="L182"></span>
<span class="line" id="L183">        <span class="tok-kw">try</span> formatType(</span>
<span class="line" id="L184">            <span class="tok-builtin">@field</span>(args, fields_info[arg_to_print].name),</span>
<span class="line" id="L185">            placeholder.specifier_arg,</span>
<span class="line" id="L186">            FormatOptions{</span>
<span class="line" id="L187">                .fill = placeholder.fill,</span>
<span class="line" id="L188">                .alignment = placeholder.alignment,</span>
<span class="line" id="L189">                .width = width,</span>
<span class="line" id="L190">                .precision = precision,</span>
<span class="line" id="L191">            },</span>
<span class="line" id="L192">            writer,</span>
<span class="line" id="L193">            default_max_depth,</span>
<span class="line" id="L194">        );</span>
<span class="line" id="L195">    }</span>
<span class="line" id="L196"></span>
<span class="line" id="L197">    <span class="tok-kw">if</span> (<span class="tok-kw">comptime</span> arg_state.hasUnusedArgs()) {</span>
<span class="line" id="L198">        <span class="tok-kw">const</span> missing_count = arg_state.args_len - <span class="tok-builtin">@popCount</span>(ArgSetType, arg_state.used_args);</span>
<span class="line" id="L199">        <span class="tok-kw">switch</span> (missing_count) {</span>
<span class="line" id="L200">            <span class="tok-number">0</span> =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L201">            <span class="tok-number">1</span> =&gt; <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;unused argument in '&quot;</span> ++ fmt ++ <span class="tok-str">&quot;'&quot;</span>),</span>
<span class="line" id="L202">            <span class="tok-kw">else</span> =&gt; <span class="tok-builtin">@compileError</span>((<span class="tok-kw">comptime</span> comptimePrint(<span class="tok-str">&quot;{d}&quot;</span>, .{missing_count})) ++ <span class="tok-str">&quot; unused arguments in '&quot;</span> ++ fmt ++ <span class="tok-str">&quot;'&quot;</span>),</span>
<span class="line" id="L203">        }</span>
<span class="line" id="L204">    }</span>
<span class="line" id="L205">}</span>
<span class="line" id="L206"></span>
<span class="line" id="L207"><span class="tok-kw">fn</span> <span class="tok-fn">parsePlaceholder</span>(<span class="tok-kw">comptime</span> str: <span class="tok-kw">anytype</span>) Placeholder {</span>
<span class="line" id="L208">    <span class="tok-kw">comptime</span> <span class="tok-kw">var</span> parser = Parser{ .buf = &amp;str };</span>
<span class="line" id="L209"></span>
<span class="line" id="L210">    <span class="tok-comment">// Parse the positional argument number</span>
</span>
<span class="line" id="L211">    <span class="tok-kw">const</span> arg = <span class="tok-kw">comptime</span> parser.specifier() <span class="tok-kw">catch</span> |err|</span>
<span class="line" id="L212">        <span class="tok-builtin">@compileError</span>(<span class="tok-builtin">@errorName</span>(err));</span>
<span class="line" id="L213"></span>
<span class="line" id="L214">    <span class="tok-comment">// Parse the format specifier</span>
</span>
<span class="line" id="L215">    <span class="tok-kw">const</span> specifier_arg = <span class="tok-kw">comptime</span> parser.until(<span class="tok-str">':'</span>);</span>
<span class="line" id="L216"></span>
<span class="line" id="L217">    <span class="tok-comment">// Skip the colon, if present</span>
</span>
<span class="line" id="L218">    <span class="tok-kw">if</span> (<span class="tok-kw">comptime</span> parser.char()) |ch| {</span>
<span class="line" id="L219">        <span class="tok-kw">if</span> (ch != <span class="tok-str">':'</span>) {</span>
<span class="line" id="L220">            <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;expected : or }, found '&quot;</span> ++ [<span class="tok-number">1</span>]<span class="tok-type">u8</span>{ch} ++ <span class="tok-str">&quot;'&quot;</span>);</span>
<span class="line" id="L221">        }</span>
<span class="line" id="L222">    }</span>
<span class="line" id="L223"></span>
<span class="line" id="L224">    <span class="tok-comment">// Parse the fill character</span>
</span>
<span class="line" id="L225">    <span class="tok-comment">// The fill parameter requires the alignment parameter to be specified</span>
</span>
<span class="line" id="L226">    <span class="tok-comment">// too</span>
</span>
<span class="line" id="L227">    <span class="tok-kw">const</span> fill = <span class="tok-kw">comptime</span> <span class="tok-kw">if</span> (parser.peek(<span class="tok-number">1</span>)) |ch|</span>
<span class="line" id="L228">        <span class="tok-kw">switch</span> (ch) {</span>
<span class="line" id="L229">            <span class="tok-str">'&lt;'</span>, <span class="tok-str">'^'</span>, <span class="tok-str">'&gt;'</span> =&gt; parser.char().?,</span>
<span class="line" id="L230">            <span class="tok-kw">else</span> =&gt; <span class="tok-str">' '</span>,</span>
<span class="line" id="L231">        }</span>
<span class="line" id="L232">    <span class="tok-kw">else</span></span>
<span class="line" id="L233">        <span class="tok-str">' '</span>;</span>
<span class="line" id="L234"></span>
<span class="line" id="L235">    <span class="tok-comment">// Parse the alignment parameter</span>
</span>
<span class="line" id="L236">    <span class="tok-kw">const</span> alignment: Alignment = <span class="tok-kw">comptime</span> <span class="tok-kw">if</span> (parser.peek(<span class="tok-number">0</span>)) |ch| init: {</span>
<span class="line" id="L237">        <span class="tok-kw">switch</span> (ch) {</span>
<span class="line" id="L238">            <span class="tok-str">'&lt;'</span>, <span class="tok-str">'^'</span>, <span class="tok-str">'&gt;'</span> =&gt; _ = parser.char(),</span>
<span class="line" id="L239">            <span class="tok-kw">else</span> =&gt; {},</span>
<span class="line" id="L240">        }</span>
<span class="line" id="L241">        <span class="tok-kw">break</span> :init <span class="tok-kw">switch</span> (ch) {</span>
<span class="line" id="L242">            <span class="tok-str">'&lt;'</span> =&gt; .Left,</span>
<span class="line" id="L243">            <span class="tok-str">'^'</span> =&gt; .Center,</span>
<span class="line" id="L244">            <span class="tok-kw">else</span> =&gt; .Right,</span>
<span class="line" id="L245">        };</span>
<span class="line" id="L246">    } <span class="tok-kw">else</span> .Right;</span>
<span class="line" id="L247"></span>
<span class="line" id="L248">    <span class="tok-comment">// Parse the width parameter</span>
</span>
<span class="line" id="L249">    <span class="tok-kw">const</span> width = <span class="tok-kw">comptime</span> parser.specifier() <span class="tok-kw">catch</span> |err|</span>
<span class="line" id="L250">        <span class="tok-builtin">@compileError</span>(<span class="tok-builtin">@errorName</span>(err));</span>
<span class="line" id="L251"></span>
<span class="line" id="L252">    <span class="tok-comment">// Skip the dot, if present</span>
</span>
<span class="line" id="L253">    <span class="tok-kw">if</span> (<span class="tok-kw">comptime</span> parser.char()) |ch| {</span>
<span class="line" id="L254">        <span class="tok-kw">if</span> (ch != <span class="tok-str">'.'</span>) {</span>
<span class="line" id="L255">            <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;expected . or }, found '&quot;</span> ++ [<span class="tok-number">1</span>]<span class="tok-type">u8</span>{ch} ++ <span class="tok-str">&quot;'&quot;</span>);</span>
<span class="line" id="L256">        }</span>
<span class="line" id="L257">    }</span>
<span class="line" id="L258"></span>
<span class="line" id="L259">    <span class="tok-comment">// Parse the precision parameter</span>
</span>
<span class="line" id="L260">    <span class="tok-kw">const</span> precision = <span class="tok-kw">comptime</span> parser.specifier() <span class="tok-kw">catch</span> |err|</span>
<span class="line" id="L261">        <span class="tok-builtin">@compileError</span>(<span class="tok-builtin">@errorName</span>(err));</span>
<span class="line" id="L262"></span>
<span class="line" id="L263">    <span class="tok-kw">if</span> (<span class="tok-kw">comptime</span> parser.char()) |ch| {</span>
<span class="line" id="L264">        <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;extraneous trailing character '&quot;</span> ++ [<span class="tok-number">1</span>]<span class="tok-type">u8</span>{ch} ++ <span class="tok-str">&quot;'&quot;</span>);</span>
<span class="line" id="L265">    }</span>
<span class="line" id="L266"></span>
<span class="line" id="L267">    <span class="tok-kw">return</span> Placeholder{</span>
<span class="line" id="L268">        .specifier_arg = cacheString(specifier_arg[<span class="tok-number">0</span>..specifier_arg.len].*),</span>
<span class="line" id="L269">        .fill = fill,</span>
<span class="line" id="L270">        .alignment = alignment,</span>
<span class="line" id="L271">        .arg = arg,</span>
<span class="line" id="L272">        .width = width,</span>
<span class="line" id="L273">        .precision = precision,</span>
<span class="line" id="L274">    };</span>
<span class="line" id="L275">}</span>
<span class="line" id="L276"></span>
<span class="line" id="L277"><span class="tok-kw">fn</span> <span class="tok-fn">cacheString</span>(str: <span class="tok-kw">anytype</span>) []<span class="tok-kw">const</span> <span class="tok-type">u8</span> {</span>
<span class="line" id="L278">    <span class="tok-kw">return</span> &amp;str;</span>
<span class="line" id="L279">}</span>
<span class="line" id="L280"></span>
<span class="line" id="L281"><span class="tok-kw">const</span> Placeholder = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L282">    specifier_arg: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L283">    fill: <span class="tok-type">u8</span>,</span>
<span class="line" id="L284">    alignment: Alignment,</span>
<span class="line" id="L285">    arg: Specifier,</span>
<span class="line" id="L286">    width: Specifier,</span>
<span class="line" id="L287">    precision: Specifier,</span>
<span class="line" id="L288">};</span>
<span class="line" id="L289"></span>
<span class="line" id="L290"><span class="tok-kw">const</span> Specifier = <span class="tok-kw">union</span>(<span class="tok-kw">enum</span>) {</span>
<span class="line" id="L291">    none,</span>
<span class="line" id="L292">    number: <span class="tok-type">usize</span>,</span>
<span class="line" id="L293">    named: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L294">};</span>
<span class="line" id="L295"></span>
<span class="line" id="L296"><span class="tok-kw">const</span> Parser = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L297">    buf: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L298">    pos: <span class="tok-type">usize</span> = <span class="tok-number">0</span>,</span>
<span class="line" id="L299"></span>
<span class="line" id="L300">    <span class="tok-comment">// Returns a decimal number or null if the current character is not a</span>
</span>
<span class="line" id="L301">    <span class="tok-comment">// digit</span>
</span>
<span class="line" id="L302">    <span class="tok-kw">fn</span> <span class="tok-fn">number</span>(self: *<span class="tok-builtin">@This</span>()) ?<span class="tok-type">usize</span> {</span>
<span class="line" id="L303">        <span class="tok-kw">var</span> r: ?<span class="tok-type">usize</span> = <span class="tok-null">null</span>;</span>
<span class="line" id="L304"></span>
<span class="line" id="L305">        <span class="tok-kw">while</span> (self.pos &lt; self.buf.len) : (self.pos += <span class="tok-number">1</span>) {</span>
<span class="line" id="L306">            <span class="tok-kw">switch</span> (self.buf[self.pos]) {</span>
<span class="line" id="L307">                <span class="tok-str">'0'</span>...<span class="tok-str">'9'</span> =&gt; {</span>
<span class="line" id="L308">                    <span class="tok-kw">if</span> (r == <span class="tok-null">null</span>) r = <span class="tok-number">0</span>;</span>
<span class="line" id="L309">                    r.? *= <span class="tok-number">10</span>;</span>
<span class="line" id="L310">                    r.? += self.buf[self.pos] - <span class="tok-str">'0'</span>;</span>
<span class="line" id="L311">                },</span>
<span class="line" id="L312">                <span class="tok-kw">else</span> =&gt; <span class="tok-kw">break</span>,</span>
<span class="line" id="L313">            }</span>
<span class="line" id="L314">        }</span>
<span class="line" id="L315"></span>
<span class="line" id="L316">        <span class="tok-kw">return</span> r;</span>
<span class="line" id="L317">    }</span>
<span class="line" id="L318"></span>
<span class="line" id="L319">    <span class="tok-comment">// Returns a substring of the input starting from the current position</span>
</span>
<span class="line" id="L320">    <span class="tok-comment">// and ending where `ch` is found or until the end if not found</span>
</span>
<span class="line" id="L321">    <span class="tok-kw">fn</span> <span class="tok-fn">until</span>(self: *<span class="tok-builtin">@This</span>(), ch: <span class="tok-type">u8</span>) []<span class="tok-kw">const</span> <span class="tok-type">u8</span> {</span>
<span class="line" id="L322">        <span class="tok-kw">const</span> start = self.pos;</span>
<span class="line" id="L323"></span>
<span class="line" id="L324">        <span class="tok-kw">if</span> (start &gt;= self.buf.len)</span>
<span class="line" id="L325">            <span class="tok-kw">return</span> &amp;[_]<span class="tok-type">u8</span>{};</span>
<span class="line" id="L326"></span>
<span class="line" id="L327">        <span class="tok-kw">while</span> (self.pos &lt; self.buf.len) : (self.pos += <span class="tok-number">1</span>) {</span>
<span class="line" id="L328">            <span class="tok-kw">if</span> (self.buf[self.pos] == ch) <span class="tok-kw">break</span>;</span>
<span class="line" id="L329">        }</span>
<span class="line" id="L330">        <span class="tok-kw">return</span> self.buf[start..self.pos];</span>
<span class="line" id="L331">    }</span>
<span class="line" id="L332"></span>
<span class="line" id="L333">    <span class="tok-comment">// Returns one character, if available</span>
</span>
<span class="line" id="L334">    <span class="tok-kw">fn</span> <span class="tok-fn">char</span>(self: *<span class="tok-builtin">@This</span>()) ?<span class="tok-type">u8</span> {</span>
<span class="line" id="L335">        <span class="tok-kw">if</span> (self.pos &lt; self.buf.len) {</span>
<span class="line" id="L336">            <span class="tok-kw">const</span> ch = self.buf[self.pos];</span>
<span class="line" id="L337">            self.pos += <span class="tok-number">1</span>;</span>
<span class="line" id="L338">            <span class="tok-kw">return</span> ch;</span>
<span class="line" id="L339">        }</span>
<span class="line" id="L340">        <span class="tok-kw">return</span> <span class="tok-null">null</span>;</span>
<span class="line" id="L341">    }</span>
<span class="line" id="L342"></span>
<span class="line" id="L343">    <span class="tok-kw">fn</span> <span class="tok-fn">maybe</span>(self: *<span class="tok-builtin">@This</span>(), val: <span class="tok-type">u8</span>) <span class="tok-type">bool</span> {</span>
<span class="line" id="L344">        <span class="tok-kw">if</span> (self.pos &lt; self.buf.len <span class="tok-kw">and</span> self.buf[self.pos] == val) {</span>
<span class="line" id="L345">            self.pos += <span class="tok-number">1</span>;</span>
<span class="line" id="L346">            <span class="tok-kw">return</span> <span class="tok-null">true</span>;</span>
<span class="line" id="L347">        }</span>
<span class="line" id="L348">        <span class="tok-kw">return</span> <span class="tok-null">false</span>;</span>
<span class="line" id="L349">    }</span>
<span class="line" id="L350"></span>
<span class="line" id="L351">    <span class="tok-comment">// Returns a decimal number or null if the current character is not a</span>
</span>
<span class="line" id="L352">    <span class="tok-comment">// digit</span>
</span>
<span class="line" id="L353">    <span class="tok-kw">fn</span> <span class="tok-fn">specifier</span>(self: *<span class="tok-builtin">@This</span>()) !Specifier {</span>
<span class="line" id="L354">        <span class="tok-kw">if</span> (self.maybe(<span class="tok-str">'['</span>)) {</span>
<span class="line" id="L355">            <span class="tok-kw">const</span> arg_name = self.until(<span class="tok-str">']'</span>);</span>
<span class="line" id="L356"></span>
<span class="line" id="L357">            <span class="tok-kw">if</span> (!self.maybe(<span class="tok-str">']'</span>))</span>
<span class="line" id="L358">                <span class="tok-kw">return</span> <span class="tok-builtin">@field</span>(<span class="tok-type">anyerror</span>, <span class="tok-str">&quot;Expected closing ]&quot;</span>);</span>
<span class="line" id="L359"></span>
<span class="line" id="L360">            <span class="tok-kw">return</span> Specifier{ .named = arg_name };</span>
<span class="line" id="L361">        }</span>
<span class="line" id="L362">        <span class="tok-kw">if</span> (self.number()) |i|</span>
<span class="line" id="L363">            <span class="tok-kw">return</span> Specifier{ .number = i };</span>
<span class="line" id="L364"></span>
<span class="line" id="L365">        <span class="tok-kw">return</span> Specifier{ .none = {} };</span>
<span class="line" id="L366">    }</span>
<span class="line" id="L367"></span>
<span class="line" id="L368">    <span class="tok-comment">// Returns the n-th next character or null if that's past the end</span>
</span>
<span class="line" id="L369">    <span class="tok-kw">fn</span> <span class="tok-fn">peek</span>(self: *<span class="tok-builtin">@This</span>(), n: <span class="tok-type">usize</span>) ?<span class="tok-type">u8</span> {</span>
<span class="line" id="L370">        <span class="tok-kw">return</span> <span class="tok-kw">if</span> (self.pos + n &lt; self.buf.len) self.buf[self.pos + n] <span class="tok-kw">else</span> <span class="tok-null">null</span>;</span>
<span class="line" id="L371">    }</span>
<span class="line" id="L372">};</span>
<span class="line" id="L373"></span>
<span class="line" id="L374"><span class="tok-kw">const</span> ArgSetType = <span class="tok-type">u32</span>;</span>
<span class="line" id="L375"><span class="tok-kw">const</span> max_format_args = <span class="tok-builtin">@typeInfo</span>(ArgSetType).Int.bits;</span>
<span class="line" id="L376"></span>
<span class="line" id="L377"><span class="tok-kw">const</span> ArgState = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L378">    next_arg: <span class="tok-type">usize</span> = <span class="tok-number">0</span>,</span>
<span class="line" id="L379">    used_args: ArgSetType = <span class="tok-number">0</span>,</span>
<span class="line" id="L380">    args_len: <span class="tok-type">usize</span>,</span>
<span class="line" id="L381"></span>
<span class="line" id="L382">    <span class="tok-kw">fn</span> <span class="tok-fn">hasUnusedArgs</span>(self: *<span class="tok-builtin">@This</span>()) <span class="tok-type">bool</span> {</span>
<span class="line" id="L383">        <span class="tok-kw">return</span> <span class="tok-builtin">@popCount</span>(ArgSetType, self.used_args) != self.args_len;</span>
<span class="line" id="L384">    }</span>
<span class="line" id="L385"></span>
<span class="line" id="L386">    <span class="tok-kw">fn</span> <span class="tok-fn">nextArg</span>(self: *<span class="tok-builtin">@This</span>(), arg_index: ?<span class="tok-type">usize</span>) ?<span class="tok-type">usize</span> {</span>
<span class="line" id="L387">        <span class="tok-kw">const</span> next_index = arg_index <span class="tok-kw">orelse</span> init: {</span>
<span class="line" id="L388">            <span class="tok-kw">const</span> arg = self.next_arg;</span>
<span class="line" id="L389">            self.next_arg += <span class="tok-number">1</span>;</span>
<span class="line" id="L390">            <span class="tok-kw">break</span> :init arg;</span>
<span class="line" id="L391">        };</span>
<span class="line" id="L392"></span>
<span class="line" id="L393">        <span class="tok-kw">if</span> (next_index &gt;= self.args_len) {</span>
<span class="line" id="L394">            <span class="tok-kw">return</span> <span class="tok-null">null</span>;</span>
<span class="line" id="L395">        }</span>
<span class="line" id="L396"></span>
<span class="line" id="L397">        <span class="tok-comment">// Mark this argument as used</span>
</span>
<span class="line" id="L398">        self.used_args |= <span class="tok-builtin">@as</span>(ArgSetType, <span class="tok-number">1</span>) &lt;&lt; <span class="tok-builtin">@intCast</span>(<span class="tok-type">u5</span>, next_index);</span>
<span class="line" id="L399">        <span class="tok-kw">return</span> next_index;</span>
<span class="line" id="L400">    }</span>
<span class="line" id="L401">};</span>
<span class="line" id="L402"></span>
<span class="line" id="L403"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">formatAddress</span>(value: <span class="tok-kw">anytype</span>, options: FormatOptions, writer: <span class="tok-kw">anytype</span>) <span class="tok-builtin">@TypeOf</span>(writer).Error!<span class="tok-type">void</span> {</span>
<span class="line" id="L404">    _ = options;</span>
<span class="line" id="L405">    <span class="tok-kw">const</span> T = <span class="tok-builtin">@TypeOf</span>(value);</span>
<span class="line" id="L406"></span>
<span class="line" id="L407">    <span class="tok-kw">switch</span> (<span class="tok-builtin">@typeInfo</span>(T)) {</span>
<span class="line" id="L408">        .Pointer =&gt; |info| {</span>
<span class="line" id="L409">            <span class="tok-kw">try</span> writer.writeAll(<span class="tok-builtin">@typeName</span>(info.child) ++ <span class="tok-str">&quot;@&quot;</span>);</span>
<span class="line" id="L410">            <span class="tok-kw">if</span> (info.size == .Slice)</span>
<span class="line" id="L411">                <span class="tok-kw">try</span> formatInt(<span class="tok-builtin">@ptrToInt</span>(value.ptr), <span class="tok-number">16</span>, .lower, FormatOptions{}, writer)</span>
<span class="line" id="L412">            <span class="tok-kw">else</span></span>
<span class="line" id="L413">                <span class="tok-kw">try</span> formatInt(<span class="tok-builtin">@ptrToInt</span>(value), <span class="tok-number">16</span>, .lower, FormatOptions{}, writer);</span>
<span class="line" id="L414">            <span class="tok-kw">return</span>;</span>
<span class="line" id="L415">        },</span>
<span class="line" id="L416">        .Optional =&gt; |info| {</span>
<span class="line" id="L417">            <span class="tok-kw">if</span> (<span class="tok-builtin">@typeInfo</span>(info.child) == .Pointer) {</span>
<span class="line" id="L418">                <span class="tok-kw">try</span> writer.writeAll(<span class="tok-builtin">@typeName</span>(info.child) ++ <span class="tok-str">&quot;@&quot;</span>);</span>
<span class="line" id="L419">                <span class="tok-kw">try</span> formatInt(<span class="tok-builtin">@ptrToInt</span>(value), <span class="tok-number">16</span>, .lower, FormatOptions{}, writer);</span>
<span class="line" id="L420">                <span class="tok-kw">return</span>;</span>
<span class="line" id="L421">            }</span>
<span class="line" id="L422">        },</span>
<span class="line" id="L423">        <span class="tok-kw">else</span> =&gt; {},</span>
<span class="line" id="L424">    }</span>
<span class="line" id="L425"></span>
<span class="line" id="L426">    <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;cannot format non-pointer type &quot;</span> ++ <span class="tok-builtin">@typeName</span>(T) ++ <span class="tok-str">&quot; with * specifier&quot;</span>);</span>
<span class="line" id="L427">}</span>
<span class="line" id="L428"></span>
<span class="line" id="L429"><span class="tok-comment">// This ANY const is a workaround for: https://github.com/ziglang/zig/issues/7948</span>
</span>
<span class="line" id="L430"><span class="tok-kw">const</span> ANY = <span class="tok-str">&quot;any&quot;</span>;</span>
<span class="line" id="L431"></span>
<span class="line" id="L432"><span class="tok-kw">fn</span> <span class="tok-fn">defaultSpec</span>(<span class="tok-kw">comptime</span> T: <span class="tok-type">type</span>) [:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span> {</span>
<span class="line" id="L433">    <span class="tok-kw">switch</span> (<span class="tok-builtin">@typeInfo</span>(T)) {</span>
<span class="line" id="L434">        .Array =&gt; |_| <span class="tok-kw">return</span> ANY,</span>
<span class="line" id="L435">        .Pointer =&gt; |ptr_info| <span class="tok-kw">switch</span> (ptr_info.size) {</span>
<span class="line" id="L436">            .One =&gt; <span class="tok-kw">switch</span> (<span class="tok-builtin">@typeInfo</span>(ptr_info.child)) {</span>
<span class="line" id="L437">                .Array =&gt; |_| <span class="tok-kw">return</span> <span class="tok-str">&quot;*&quot;</span>,</span>
<span class="line" id="L438">                <span class="tok-kw">else</span> =&gt; {},</span>
<span class="line" id="L439">            },</span>
<span class="line" id="L440">            .Many, .C =&gt; <span class="tok-kw">return</span> <span class="tok-str">&quot;*&quot;</span>,</span>
<span class="line" id="L441">            .Slice =&gt; <span class="tok-kw">return</span> ANY,</span>
<span class="line" id="L442">        },</span>
<span class="line" id="L443">        .Optional =&gt; |info| <span class="tok-kw">return</span> <span class="tok-str">&quot;?&quot;</span> ++ defaultSpec(info.child),</span>
<span class="line" id="L444">        .ErrorUnion =&gt; |info| <span class="tok-kw">return</span> <span class="tok-str">&quot;!&quot;</span> ++ defaultSpec(info.payload),</span>
<span class="line" id="L445">        <span class="tok-kw">else</span> =&gt; {},</span>
<span class="line" id="L446">    }</span>
<span class="line" id="L447">    <span class="tok-kw">return</span> <span class="tok-str">&quot;&quot;</span>;</span>
<span class="line" id="L448">}</span>
<span class="line" id="L449"></span>
<span class="line" id="L450"><span class="tok-kw">fn</span> <span class="tok-fn">stripOptionalOrErrorUnionSpec</span>(<span class="tok-kw">comptime</span> fmt: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) []<span class="tok-kw">const</span> <span class="tok-type">u8</span> {</span>
<span class="line" id="L451">    <span class="tok-kw">return</span> <span class="tok-kw">if</span> (std.mem.eql(<span class="tok-type">u8</span>, fmt[<span class="tok-number">1</span>..], ANY))</span>
<span class="line" id="L452">        ANY</span>
<span class="line" id="L453">    <span class="tok-kw">else</span></span>
<span class="line" id="L454">        fmt[<span class="tok-number">1</span>..];</span>
<span class="line" id="L455">}</span>
<span class="line" id="L456"></span>
<span class="line" id="L457"><span class="tok-kw">fn</span> <span class="tok-fn">invalidFmtErr</span>(<span class="tok-kw">comptime</span> fmt: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, value: <span class="tok-kw">anytype</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L458">    <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;invalid format string '&quot;</span> ++ fmt ++ <span class="tok-str">&quot;' for type '&quot;</span> ++ <span class="tok-builtin">@typeName</span>(<span class="tok-builtin">@TypeOf</span>(value)) ++ <span class="tok-str">&quot;'&quot;</span>);</span>
<span class="line" id="L459">}</span>
<span class="line" id="L460"></span>
<span class="line" id="L461"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">formatType</span>(</span>
<span class="line" id="L462">    value: <span class="tok-kw">anytype</span>,</span>
<span class="line" id="L463">    <span class="tok-kw">comptime</span> fmt: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L464">    options: FormatOptions,</span>
<span class="line" id="L465">    writer: <span class="tok-kw">anytype</span>,</span>
<span class="line" id="L466">    max_depth: <span class="tok-type">usize</span>,</span>
<span class="line" id="L467">) <span class="tok-builtin">@TypeOf</span>(writer).Error!<span class="tok-type">void</span> {</span>
<span class="line" id="L468">    <span class="tok-kw">const</span> T = <span class="tok-builtin">@TypeOf</span>(value);</span>
<span class="line" id="L469">    <span class="tok-kw">const</span> actual_fmt = <span class="tok-kw">comptime</span> <span class="tok-kw">if</span> (std.mem.eql(<span class="tok-type">u8</span>, fmt, ANY))</span>
<span class="line" id="L470">        defaultSpec(<span class="tok-builtin">@TypeOf</span>(value))</span>
<span class="line" id="L471">    <span class="tok-kw">else</span> <span class="tok-kw">if</span> (fmt.len != <span class="tok-number">0</span> <span class="tok-kw">and</span> (fmt[<span class="tok-number">0</span>] == <span class="tok-str">'?'</span> <span class="tok-kw">or</span> fmt[<span class="tok-number">0</span>] == <span class="tok-str">'!'</span>)) <span class="tok-kw">switch</span> (<span class="tok-builtin">@typeInfo</span>(T)) {</span>
<span class="line" id="L472">        .Optional, .ErrorUnion =&gt; fmt,</span>
<span class="line" id="L473">        <span class="tok-kw">else</span> =&gt; stripOptionalOrErrorUnionSpec(fmt),</span>
<span class="line" id="L474">    } <span class="tok-kw">else</span> fmt;</span>
<span class="line" id="L475"></span>
<span class="line" id="L476">    <span class="tok-kw">if</span> (<span class="tok-kw">comptime</span> std.mem.eql(<span class="tok-type">u8</span>, actual_fmt, <span class="tok-str">&quot;*&quot;</span>)) {</span>
<span class="line" id="L477">        <span class="tok-kw">return</span> formatAddress(value, options, writer);</span>
<span class="line" id="L478">    }</span>
<span class="line" id="L479"></span>
<span class="line" id="L480">    <span class="tok-kw">if</span> (<span class="tok-kw">comptime</span> std.meta.trait.hasFn(<span class="tok-str">&quot;format&quot;</span>)(T)) {</span>
<span class="line" id="L481">        <span class="tok-kw">return</span> <span class="tok-kw">try</span> value.format(actual_fmt, options, writer);</span>
<span class="line" id="L482">    }</span>
<span class="line" id="L483"></span>
<span class="line" id="L484">    <span class="tok-kw">switch</span> (<span class="tok-builtin">@typeInfo</span>(T)) {</span>
<span class="line" id="L485">        .ComptimeInt, .Int, .ComptimeFloat, .Float =&gt; {</span>
<span class="line" id="L486">            <span class="tok-kw">return</span> formatValue(value, actual_fmt, options, writer);</span>
<span class="line" id="L487">        },</span>
<span class="line" id="L488">        .Void =&gt; {</span>
<span class="line" id="L489">            <span class="tok-kw">if</span> (actual_fmt.len != <span class="tok-number">0</span>) invalidFmtErr(fmt, value);</span>
<span class="line" id="L490">            <span class="tok-kw">return</span> formatBuf(<span class="tok-str">&quot;void&quot;</span>, options, writer);</span>
<span class="line" id="L491">        },</span>
<span class="line" id="L492">        .Bool =&gt; {</span>
<span class="line" id="L493">            <span class="tok-kw">if</span> (actual_fmt.len != <span class="tok-number">0</span>) invalidFmtErr(fmt, value);</span>
<span class="line" id="L494">            <span class="tok-kw">return</span> formatBuf(<span class="tok-kw">if</span> (value) <span class="tok-str">&quot;true&quot;</span> <span class="tok-kw">else</span> <span class="tok-str">&quot;false&quot;</span>, options, writer);</span>
<span class="line" id="L495">        },</span>
<span class="line" id="L496">        .Optional =&gt; {</span>
<span class="line" id="L497">            <span class="tok-kw">if</span> (actual_fmt.len == <span class="tok-number">0</span> <span class="tok-kw">or</span> actual_fmt[<span class="tok-number">0</span>] != <span class="tok-str">'?'</span>)</span>
<span class="line" id="L498">                <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;cannot format optional without a specifier (i.e. {?} or {any})&quot;</span>);</span>
<span class="line" id="L499">            <span class="tok-kw">const</span> remaining_fmt = <span class="tok-kw">comptime</span> stripOptionalOrErrorUnionSpec(actual_fmt);</span>
<span class="line" id="L500">            <span class="tok-kw">if</span> (value) |payload| {</span>
<span class="line" id="L501">                <span class="tok-kw">return</span> formatType(payload, remaining_fmt, options, writer, max_depth);</span>
<span class="line" id="L502">            } <span class="tok-kw">else</span> {</span>
<span class="line" id="L503">                <span class="tok-kw">return</span> formatBuf(<span class="tok-str">&quot;null&quot;</span>, options, writer);</span>
<span class="line" id="L504">            }</span>
<span class="line" id="L505">        },</span>
<span class="line" id="L506">        .ErrorUnion =&gt; {</span>
<span class="line" id="L507">            <span class="tok-kw">if</span> (actual_fmt.len == <span class="tok-number">0</span> <span class="tok-kw">or</span> actual_fmt[<span class="tok-number">0</span>] != <span class="tok-str">'!'</span>)</span>
<span class="line" id="L508">                <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;cannot format error union without a specifier (i.e. {!} or {any})&quot;</span>);</span>
<span class="line" id="L509">            <span class="tok-kw">const</span> remaining_fmt = <span class="tok-kw">comptime</span> stripOptionalOrErrorUnionSpec(actual_fmt);</span>
<span class="line" id="L510">            <span class="tok-kw">if</span> (value) |payload| {</span>
<span class="line" id="L511">                <span class="tok-kw">return</span> formatType(payload, remaining_fmt, options, writer, max_depth);</span>
<span class="line" id="L512">            } <span class="tok-kw">else</span> |err| {</span>
<span class="line" id="L513">                <span class="tok-kw">return</span> formatType(err, <span class="tok-str">&quot;&quot;</span>, options, writer, max_depth);</span>
<span class="line" id="L514">            }</span>
<span class="line" id="L515">        },</span>
<span class="line" id="L516">        .ErrorSet =&gt; {</span>
<span class="line" id="L517">            <span class="tok-kw">if</span> (actual_fmt.len != <span class="tok-number">0</span>) invalidFmtErr(fmt, value);</span>
<span class="line" id="L518">            <span class="tok-kw">try</span> writer.writeAll(<span class="tok-str">&quot;error.&quot;</span>);</span>
<span class="line" id="L519">            <span class="tok-kw">return</span> writer.writeAll(<span class="tok-builtin">@errorName</span>(value));</span>
<span class="line" id="L520">        },</span>
<span class="line" id="L521">        .Enum =&gt; |enumInfo| {</span>
<span class="line" id="L522">            <span class="tok-kw">try</span> writer.writeAll(<span class="tok-builtin">@typeName</span>(T));</span>
<span class="line" id="L523">            <span class="tok-kw">if</span> (enumInfo.is_exhaustive) {</span>
<span class="line" id="L524">                <span class="tok-kw">if</span> (actual_fmt.len != <span class="tok-number">0</span>) invalidFmtErr(fmt, value);</span>
<span class="line" id="L525">                <span class="tok-kw">try</span> writer.writeAll(<span class="tok-str">&quot;.&quot;</span>);</span>
<span class="line" id="L526">                <span class="tok-kw">try</span> writer.writeAll(<span class="tok-builtin">@tagName</span>(value));</span>
<span class="line" id="L527">                <span class="tok-kw">return</span>;</span>
<span class="line" id="L528">            }</span>
<span class="line" id="L529"></span>
<span class="line" id="L530">            <span class="tok-comment">// Use @tagName only if value is one of known fields</span>
</span>
<span class="line" id="L531">            <span class="tok-builtin">@setEvalBranchQuota</span>(<span class="tok-number">3</span> * enumInfo.fields.len);</span>
<span class="line" id="L532">            <span class="tok-kw">inline</span> <span class="tok-kw">for</span> (enumInfo.fields) |enumField| {</span>
<span class="line" id="L533">                <span class="tok-kw">if</span> (<span class="tok-builtin">@enumToInt</span>(value) == enumField.value) {</span>
<span class="line" id="L534">                    <span class="tok-kw">try</span> writer.writeAll(<span class="tok-str">&quot;.&quot;</span>);</span>
<span class="line" id="L535">                    <span class="tok-kw">try</span> writer.writeAll(<span class="tok-builtin">@tagName</span>(value));</span>
<span class="line" id="L536">                    <span class="tok-kw">return</span>;</span>
<span class="line" id="L537">                }</span>
<span class="line" id="L538">            }</span>
<span class="line" id="L539"></span>
<span class="line" id="L540">            <span class="tok-kw">try</span> writer.writeAll(<span class="tok-str">&quot;(&quot;</span>);</span>
<span class="line" id="L541">            <span class="tok-kw">try</span> formatType(<span class="tok-builtin">@enumToInt</span>(value), actual_fmt, options, writer, max_depth);</span>
<span class="line" id="L542">            <span class="tok-kw">try</span> writer.writeAll(<span class="tok-str">&quot;)&quot;</span>);</span>
<span class="line" id="L543">        },</span>
<span class="line" id="L544">        .Union =&gt; |info| {</span>
<span class="line" id="L545">            <span class="tok-kw">if</span> (actual_fmt.len != <span class="tok-number">0</span>) invalidFmtErr(fmt, value);</span>
<span class="line" id="L546">            <span class="tok-kw">try</span> writer.writeAll(<span class="tok-builtin">@typeName</span>(T));</span>
<span class="line" id="L547">            <span class="tok-kw">if</span> (max_depth == <span class="tok-number">0</span>) {</span>
<span class="line" id="L548">                <span class="tok-kw">return</span> writer.writeAll(<span class="tok-str">&quot;{ ... }&quot;</span>);</span>
<span class="line" id="L549">            }</span>
<span class="line" id="L550">            <span class="tok-kw">if</span> (info.tag_type) |UnionTagType| {</span>
<span class="line" id="L551">                <span class="tok-kw">try</span> writer.writeAll(<span class="tok-str">&quot;{ .&quot;</span>);</span>
<span class="line" id="L552">                <span class="tok-kw">try</span> writer.writeAll(<span class="tok-builtin">@tagName</span>(<span class="tok-builtin">@as</span>(UnionTagType, value)));</span>
<span class="line" id="L553">                <span class="tok-kw">try</span> writer.writeAll(<span class="tok-str">&quot; = &quot;</span>);</span>
<span class="line" id="L554">                <span class="tok-kw">inline</span> <span class="tok-kw">for</span> (info.fields) |u_field| {</span>
<span class="line" id="L555">                    <span class="tok-kw">if</span> (value == <span class="tok-builtin">@field</span>(UnionTagType, u_field.name)) {</span>
<span class="line" id="L556">                        <span class="tok-kw">try</span> formatType(<span class="tok-builtin">@field</span>(value, u_field.name), ANY, options, writer, max_depth - <span class="tok-number">1</span>);</span>
<span class="line" id="L557">                    }</span>
<span class="line" id="L558">                }</span>
<span class="line" id="L559">                <span class="tok-kw">try</span> writer.writeAll(<span class="tok-str">&quot; }&quot;</span>);</span>
<span class="line" id="L560">            } <span class="tok-kw">else</span> {</span>
<span class="line" id="L561">                <span class="tok-kw">try</span> format(writer, <span class="tok-str">&quot;@{x}&quot;</span>, .{<span class="tok-builtin">@ptrToInt</span>(&amp;value)});</span>
<span class="line" id="L562">            }</span>
<span class="line" id="L563">        },</span>
<span class="line" id="L564">        .Struct =&gt; |info| {</span>
<span class="line" id="L565">            <span class="tok-kw">if</span> (actual_fmt.len != <span class="tok-number">0</span>) invalidFmtErr(fmt, value);</span>
<span class="line" id="L566">            <span class="tok-kw">if</span> (info.is_tuple) {</span>
<span class="line" id="L567">                <span class="tok-comment">// Skip the type and field names when formatting tuples.</span>
</span>
<span class="line" id="L568">                <span class="tok-kw">if</span> (max_depth == <span class="tok-number">0</span>) {</span>
<span class="line" id="L569">                    <span class="tok-kw">return</span> writer.writeAll(<span class="tok-str">&quot;{ ... }&quot;</span>);</span>
<span class="line" id="L570">                }</span>
<span class="line" id="L571">                <span class="tok-kw">try</span> writer.writeAll(<span class="tok-str">&quot;{&quot;</span>);</span>
<span class="line" id="L572">                <span class="tok-kw">inline</span> <span class="tok-kw">for</span> (info.fields) |f, i| {</span>
<span class="line" id="L573">                    <span class="tok-kw">if</span> (i == <span class="tok-number">0</span>) {</span>
<span class="line" id="L574">                        <span class="tok-kw">try</span> writer.writeAll(<span class="tok-str">&quot; &quot;</span>);</span>
<span class="line" id="L575">                    } <span class="tok-kw">else</span> {</span>
<span class="line" id="L576">                        <span class="tok-kw">try</span> writer.writeAll(<span class="tok-str">&quot;, &quot;</span>);</span>
<span class="line" id="L577">                    }</span>
<span class="line" id="L578">                    <span class="tok-kw">try</span> formatType(<span class="tok-builtin">@field</span>(value, f.name), ANY, options, writer, max_depth - <span class="tok-number">1</span>);</span>
<span class="line" id="L579">                }</span>
<span class="line" id="L580">                <span class="tok-kw">return</span> writer.writeAll(<span class="tok-str">&quot; }&quot;</span>);</span>
<span class="line" id="L581">            }</span>
<span class="line" id="L582">            <span class="tok-kw">try</span> writer.writeAll(<span class="tok-builtin">@typeName</span>(T));</span>
<span class="line" id="L583">            <span class="tok-kw">if</span> (max_depth == <span class="tok-number">0</span>) {</span>
<span class="line" id="L584">                <span class="tok-kw">return</span> writer.writeAll(<span class="tok-str">&quot;{ ... }&quot;</span>);</span>
<span class="line" id="L585">            }</span>
<span class="line" id="L586">            <span class="tok-kw">try</span> writer.writeAll(<span class="tok-str">&quot;{&quot;</span>);</span>
<span class="line" id="L587">            <span class="tok-kw">inline</span> <span class="tok-kw">for</span> (info.fields) |f, i| {</span>
<span class="line" id="L588">                <span class="tok-kw">if</span> (i == <span class="tok-number">0</span>) {</span>
<span class="line" id="L589">                    <span class="tok-kw">try</span> writer.writeAll(<span class="tok-str">&quot; .&quot;</span>);</span>
<span class="line" id="L590">                } <span class="tok-kw">else</span> {</span>
<span class="line" id="L591">                    <span class="tok-kw">try</span> writer.writeAll(<span class="tok-str">&quot;, .&quot;</span>);</span>
<span class="line" id="L592">                }</span>
<span class="line" id="L593">                <span class="tok-kw">try</span> writer.writeAll(f.name);</span>
<span class="line" id="L594">                <span class="tok-kw">try</span> writer.writeAll(<span class="tok-str">&quot; = &quot;</span>);</span>
<span class="line" id="L595">                <span class="tok-kw">try</span> formatType(<span class="tok-builtin">@field</span>(value, f.name), ANY, options, writer, max_depth - <span class="tok-number">1</span>);</span>
<span class="line" id="L596">            }</span>
<span class="line" id="L597">            <span class="tok-kw">try</span> writer.writeAll(<span class="tok-str">&quot; }&quot;</span>);</span>
<span class="line" id="L598">        },</span>
<span class="line" id="L599">        .Pointer =&gt; |ptr_info| <span class="tok-kw">switch</span> (ptr_info.size) {</span>
<span class="line" id="L600">            .One =&gt; <span class="tok-kw">switch</span> (<span class="tok-builtin">@typeInfo</span>(ptr_info.child)) {</span>
<span class="line" id="L601">                .Array =&gt; |info| {</span>
<span class="line" id="L602">                    <span class="tok-kw">if</span> (actual_fmt.len == <span class="tok-number">0</span>)</span>
<span class="line" id="L603">                        <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;cannot format array ref without a specifier (i.e. {s} or {*})&quot;</span>);</span>
<span class="line" id="L604">                    <span class="tok-kw">if</span> (info.child == <span class="tok-type">u8</span>) {</span>
<span class="line" id="L605">                        <span class="tok-kw">switch</span> (actual_fmt[<span class="tok-number">0</span>]) {</span>
<span class="line" id="L606">                            <span class="tok-str">'s'</span>, <span class="tok-str">'x'</span>, <span class="tok-str">'X'</span>, <span class="tok-str">'e'</span>, <span class="tok-str">'E'</span> =&gt; {</span>
<span class="line" id="L607">                                <span class="tok-kw">comptime</span> checkTextFmt(actual_fmt);</span>
<span class="line" id="L608">                                <span class="tok-kw">return</span> formatBuf(value, options, writer);</span>
<span class="line" id="L609">                            },</span>
<span class="line" id="L610">                            <span class="tok-kw">else</span> =&gt; {},</span>
<span class="line" id="L611">                        }</span>
<span class="line" id="L612">                    }</span>
<span class="line" id="L613">                    <span class="tok-kw">if</span> (<span class="tok-kw">comptime</span> std.meta.trait.isZigString(info.child)) {</span>
<span class="line" id="L614">                        <span class="tok-kw">for</span> (value) |item, i| {</span>
<span class="line" id="L615">                            <span class="tok-kw">comptime</span> checkTextFmt(actual_fmt);</span>
<span class="line" id="L616">                            <span class="tok-kw">if</span> (i != <span class="tok-number">0</span>) <span class="tok-kw">try</span> formatBuf(<span class="tok-str">&quot;, &quot;</span>, options, writer);</span>
<span class="line" id="L617">                            <span class="tok-kw">try</span> formatBuf(item, options, writer);</span>
<span class="line" id="L618">                        }</span>
<span class="line" id="L619">                        <span class="tok-kw">return</span>;</span>
<span class="line" id="L620">                    }</span>
<span class="line" id="L621">                    invalidFmtErr(fmt, value);</span>
<span class="line" id="L622">                },</span>
<span class="line" id="L623">                .Enum, .Union, .Struct =&gt; {</span>
<span class="line" id="L624">                    <span class="tok-kw">return</span> formatType(value.*, actual_fmt, options, writer, max_depth);</span>
<span class="line" id="L625">                },</span>
<span class="line" id="L626">                <span class="tok-kw">else</span> =&gt; <span class="tok-kw">return</span> format(writer, <span class="tok-str">&quot;{s}@{x}&quot;</span>, .{ <span class="tok-builtin">@typeName</span>(ptr_info.child), <span class="tok-builtin">@ptrToInt</span>(value) }),</span>
<span class="line" id="L627">            },</span>
<span class="line" id="L628">            .Many, .C =&gt; {</span>
<span class="line" id="L629">                <span class="tok-kw">if</span> (actual_fmt.len == <span class="tok-number">0</span>)</span>
<span class="line" id="L630">                    <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;cannot format pointer without a specifier (i.e. {s} or {*})&quot;</span>);</span>
<span class="line" id="L631">                <span class="tok-kw">if</span> (ptr_info.sentinel) |_| {</span>
<span class="line" id="L632">                    <span class="tok-kw">return</span> formatType(mem.span(value), actual_fmt, options, writer, max_depth);</span>
<span class="line" id="L633">                }</span>
<span class="line" id="L634">                <span class="tok-kw">if</span> (ptr_info.child == <span class="tok-type">u8</span>) {</span>
<span class="line" id="L635">                    <span class="tok-kw">switch</span> (actual_fmt[<span class="tok-number">0</span>]) {</span>
<span class="line" id="L636">                        <span class="tok-str">'s'</span>, <span class="tok-str">'x'</span>, <span class="tok-str">'X'</span>, <span class="tok-str">'e'</span>, <span class="tok-str">'E'</span> =&gt; {</span>
<span class="line" id="L637">                            <span class="tok-kw">comptime</span> checkTextFmt(actual_fmt);</span>
<span class="line" id="L638">                            <span class="tok-kw">return</span> formatBuf(mem.span(value), options, writer);</span>
<span class="line" id="L639">                        },</span>
<span class="line" id="L640">                        <span class="tok-kw">else</span> =&gt; {},</span>
<span class="line" id="L641">                    }</span>
<span class="line" id="L642">                }</span>
<span class="line" id="L643">                invalidFmtErr(fmt, value);</span>
<span class="line" id="L644">            },</span>
<span class="line" id="L645">            .Slice =&gt; {</span>
<span class="line" id="L646">                <span class="tok-kw">if</span> (actual_fmt.len == <span class="tok-number">0</span>)</span>
<span class="line" id="L647">                    <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;cannot format slice without a specifier (i.e. {s} or {any})&quot;</span>);</span>
<span class="line" id="L648">                <span class="tok-kw">if</span> (max_depth == <span class="tok-number">0</span>) {</span>
<span class="line" id="L649">                    <span class="tok-kw">return</span> writer.writeAll(<span class="tok-str">&quot;{ ... }&quot;</span>);</span>
<span class="line" id="L650">                }</span>
<span class="line" id="L651">                <span class="tok-kw">if</span> (ptr_info.child == <span class="tok-type">u8</span>) {</span>
<span class="line" id="L652">                    <span class="tok-kw">switch</span> (actual_fmt[<span class="tok-number">0</span>]) {</span>
<span class="line" id="L653">                        <span class="tok-str">'s'</span>, <span class="tok-str">'x'</span>, <span class="tok-str">'X'</span>, <span class="tok-str">'e'</span>, <span class="tok-str">'E'</span> =&gt; {</span>
<span class="line" id="L654">                            <span class="tok-kw">comptime</span> checkTextFmt(actual_fmt);</span>
<span class="line" id="L655">                            <span class="tok-kw">return</span> formatBuf(value, options, writer);</span>
<span class="line" id="L656">                        },</span>
<span class="line" id="L657">                        <span class="tok-kw">else</span> =&gt; {},</span>
<span class="line" id="L658">                    }</span>
<span class="line" id="L659">                }</span>
<span class="line" id="L660">                <span class="tok-kw">try</span> writer.writeAll(<span class="tok-str">&quot;{ &quot;</span>);</span>
<span class="line" id="L661">                <span class="tok-kw">for</span> (value) |elem, i| {</span>
<span class="line" id="L662">                    <span class="tok-kw">try</span> formatType(elem, actual_fmt, options, writer, max_depth - <span class="tok-number">1</span>);</span>
<span class="line" id="L663">                    <span class="tok-kw">if</span> (i != value.len - <span class="tok-number">1</span>) {</span>
<span class="line" id="L664">                        <span class="tok-kw">try</span> writer.writeAll(<span class="tok-str">&quot;, &quot;</span>);</span>
<span class="line" id="L665">                    }</span>
<span class="line" id="L666">                }</span>
<span class="line" id="L667">                <span class="tok-kw">try</span> writer.writeAll(<span class="tok-str">&quot; }&quot;</span>);</span>
<span class="line" id="L668">            },</span>
<span class="line" id="L669">        },</span>
<span class="line" id="L670">        .Array =&gt; |info| {</span>
<span class="line" id="L671">            <span class="tok-kw">if</span> (actual_fmt.len == <span class="tok-number">0</span>)</span>
<span class="line" id="L672">                <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;cannot format array without a specifier (i.e. {s} or {any})&quot;</span>);</span>
<span class="line" id="L673">            <span class="tok-kw">if</span> (max_depth == <span class="tok-number">0</span>) {</span>
<span class="line" id="L674">                <span class="tok-kw">return</span> writer.writeAll(<span class="tok-str">&quot;{ ... }&quot;</span>);</span>
<span class="line" id="L675">            }</span>
<span class="line" id="L676">            <span class="tok-kw">if</span> (info.child == <span class="tok-type">u8</span>) {</span>
<span class="line" id="L677">                <span class="tok-kw">switch</span> (actual_fmt[<span class="tok-number">0</span>]) {</span>
<span class="line" id="L678">                    <span class="tok-str">'s'</span>, <span class="tok-str">'x'</span>, <span class="tok-str">'X'</span>, <span class="tok-str">'e'</span>, <span class="tok-str">'E'</span> =&gt; {</span>
<span class="line" id="L679">                        <span class="tok-kw">comptime</span> checkTextFmt(actual_fmt);</span>
<span class="line" id="L680">                        <span class="tok-kw">return</span> formatBuf(&amp;value, options, writer);</span>
<span class="line" id="L681">                    },</span>
<span class="line" id="L682">                    <span class="tok-kw">else</span> =&gt; {},</span>
<span class="line" id="L683">                }</span>
<span class="line" id="L684">            }</span>
<span class="line" id="L685">            <span class="tok-kw">try</span> writer.writeAll(<span class="tok-str">&quot;{ &quot;</span>);</span>
<span class="line" id="L686">            <span class="tok-kw">for</span> (value) |elem, i| {</span>
<span class="line" id="L687">                <span class="tok-kw">try</span> formatType(elem, actual_fmt, options, writer, max_depth - <span class="tok-number">1</span>);</span>
<span class="line" id="L688">                <span class="tok-kw">if</span> (i &lt; value.len - <span class="tok-number">1</span>) {</span>
<span class="line" id="L689">                    <span class="tok-kw">try</span> writer.writeAll(<span class="tok-str">&quot;, &quot;</span>);</span>
<span class="line" id="L690">                }</span>
<span class="line" id="L691">            }</span>
<span class="line" id="L692">            <span class="tok-kw">try</span> writer.writeAll(<span class="tok-str">&quot; }&quot;</span>);</span>
<span class="line" id="L693">        },</span>
<span class="line" id="L694">        .Vector =&gt; |info| {</span>
<span class="line" id="L695">            <span class="tok-kw">try</span> writer.writeAll(<span class="tok-str">&quot;{ &quot;</span>);</span>
<span class="line" id="L696">            <span class="tok-kw">var</span> i: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L697">            <span class="tok-kw">while</span> (i &lt; info.len) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L698">                <span class="tok-kw">try</span> formatValue(value[i], actual_fmt, options, writer);</span>
<span class="line" id="L699">                <span class="tok-kw">if</span> (i &lt; info.len - <span class="tok-number">1</span>) {</span>
<span class="line" id="L700">                    <span class="tok-kw">try</span> writer.writeAll(<span class="tok-str">&quot;, &quot;</span>);</span>
<span class="line" id="L701">                }</span>
<span class="line" id="L702">            }</span>
<span class="line" id="L703">            <span class="tok-kw">try</span> writer.writeAll(<span class="tok-str">&quot; }&quot;</span>);</span>
<span class="line" id="L704">        },</span>
<span class="line" id="L705">        .Fn =&gt; {</span>
<span class="line" id="L706">            <span class="tok-kw">if</span> (actual_fmt.len != <span class="tok-number">0</span>) invalidFmtErr(fmt, value);</span>
<span class="line" id="L707">            <span class="tok-kw">return</span> format(writer, <span class="tok-str">&quot;{s}@{x}&quot;</span>, .{ <span class="tok-builtin">@typeName</span>(T), <span class="tok-builtin">@ptrToInt</span>(value) });</span>
<span class="line" id="L708">        },</span>
<span class="line" id="L709">        .Type =&gt; {</span>
<span class="line" id="L710">            <span class="tok-kw">if</span> (actual_fmt.len != <span class="tok-number">0</span>) invalidFmtErr(fmt, value);</span>
<span class="line" id="L711">            <span class="tok-kw">return</span> formatBuf(<span class="tok-builtin">@typeName</span>(value), options, writer);</span>
<span class="line" id="L712">        },</span>
<span class="line" id="L713">        .EnumLiteral =&gt; {</span>
<span class="line" id="L714">            <span class="tok-kw">if</span> (actual_fmt.len != <span class="tok-number">0</span>) invalidFmtErr(fmt, value);</span>
<span class="line" id="L715">            <span class="tok-kw">const</span> buffer = [_]<span class="tok-type">u8</span>{<span class="tok-str">'.'</span>} ++ <span class="tok-builtin">@tagName</span>(value);</span>
<span class="line" id="L716">            <span class="tok-kw">return</span> formatBuf(buffer, options, writer);</span>
<span class="line" id="L717">        },</span>
<span class="line" id="L718">        .Null =&gt; {</span>
<span class="line" id="L719">            <span class="tok-kw">if</span> (actual_fmt.len != <span class="tok-number">0</span>) invalidFmtErr(fmt, value);</span>
<span class="line" id="L720">            <span class="tok-kw">return</span> formatBuf(<span class="tok-str">&quot;null&quot;</span>, options, writer);</span>
<span class="line" id="L721">        },</span>
<span class="line" id="L722">        <span class="tok-kw">else</span> =&gt; <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;unable to format type '&quot;</span> ++ <span class="tok-builtin">@typeName</span>(T) ++ <span class="tok-str">&quot;'&quot;</span>),</span>
<span class="line" id="L723">    }</span>
<span class="line" id="L724">}</span>
<span class="line" id="L725"></span>
<span class="line" id="L726"><span class="tok-kw">fn</span> <span class="tok-fn">formatValue</span>(</span>
<span class="line" id="L727">    value: <span class="tok-kw">anytype</span>,</span>
<span class="line" id="L728">    <span class="tok-kw">comptime</span> fmt: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L729">    options: FormatOptions,</span>
<span class="line" id="L730">    writer: <span class="tok-kw">anytype</span>,</span>
<span class="line" id="L731">) !<span class="tok-type">void</span> {</span>
<span class="line" id="L732">    <span class="tok-kw">if</span> (<span class="tok-kw">comptime</span> std.mem.eql(<span class="tok-type">u8</span>, fmt, <span class="tok-str">&quot;B&quot;</span>)) {</span>
<span class="line" id="L733">        <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;specifier 'B' has been deprecated, wrap your argument in std.fmt.fmtIntSizeDec instead&quot;</span>);</span>
<span class="line" id="L734">    } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (<span class="tok-kw">comptime</span> std.mem.eql(<span class="tok-type">u8</span>, fmt, <span class="tok-str">&quot;Bi&quot;</span>)) {</span>
<span class="line" id="L735">        <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;specifier 'Bi' has been deprecated, wrap your argument in std.fmt.fmtIntSizeBin instead&quot;</span>);</span>
<span class="line" id="L736">    }</span>
<span class="line" id="L737"></span>
<span class="line" id="L738">    <span class="tok-kw">const</span> T = <span class="tok-builtin">@TypeOf</span>(value);</span>
<span class="line" id="L739">    <span class="tok-kw">switch</span> (<span class="tok-builtin">@typeInfo</span>(T)) {</span>
<span class="line" id="L740">        .Float, .ComptimeFloat =&gt; <span class="tok-kw">return</span> formatFloatValue(value, fmt, options, writer),</span>
<span class="line" id="L741">        .Int, .ComptimeInt =&gt; <span class="tok-kw">return</span> formatIntValue(value, fmt, options, writer),</span>
<span class="line" id="L742">        .Bool =&gt; <span class="tok-kw">return</span> formatBuf(<span class="tok-kw">if</span> (value) <span class="tok-str">&quot;true&quot;</span> <span class="tok-kw">else</span> <span class="tok-str">&quot;false&quot;</span>, options, writer),</span>
<span class="line" id="L743">        <span class="tok-kw">else</span> =&gt; <span class="tok-kw">comptime</span> <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L744">    }</span>
<span class="line" id="L745">}</span>
<span class="line" id="L746"></span>
<span class="line" id="L747"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">formatIntValue</span>(</span>
<span class="line" id="L748">    value: <span class="tok-kw">anytype</span>,</span>
<span class="line" id="L749">    <span class="tok-kw">comptime</span> fmt: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L750">    options: FormatOptions,</span>
<span class="line" id="L751">    writer: <span class="tok-kw">anytype</span>,</span>
<span class="line" id="L752">) !<span class="tok-type">void</span> {</span>
<span class="line" id="L753">    <span class="tok-kw">comptime</span> <span class="tok-kw">var</span> radix = <span class="tok-number">10</span>;</span>
<span class="line" id="L754">    <span class="tok-kw">comptime</span> <span class="tok-kw">var</span> case: Case = .lower;</span>
<span class="line" id="L755"></span>
<span class="line" id="L756">    <span class="tok-kw">const</span> int_value = <span class="tok-kw">if</span> (<span class="tok-builtin">@TypeOf</span>(value) == <span class="tok-type">comptime_int</span>) blk: {</span>
<span class="line" id="L757">        <span class="tok-kw">const</span> Int = math.IntFittingRange(value, value);</span>
<span class="line" id="L758">        <span class="tok-kw">break</span> :blk <span class="tok-builtin">@as</span>(Int, value);</span>
<span class="line" id="L759">    } <span class="tok-kw">else</span> value;</span>
<span class="line" id="L760"></span>
<span class="line" id="L761">    <span class="tok-kw">if</span> (fmt.len == <span class="tok-number">0</span> <span class="tok-kw">or</span> <span class="tok-kw">comptime</span> std.mem.eql(<span class="tok-type">u8</span>, fmt, <span class="tok-str">&quot;d&quot;</span>)) {</span>
<span class="line" id="L762">        radix = <span class="tok-number">10</span>;</span>
<span class="line" id="L763">        case = .lower;</span>
<span class="line" id="L764">    } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (<span class="tok-kw">comptime</span> std.mem.eql(<span class="tok-type">u8</span>, fmt, <span class="tok-str">&quot;c&quot;</span>)) {</span>
<span class="line" id="L765">        <span class="tok-kw">if</span> (<span class="tok-builtin">@typeInfo</span>(<span class="tok-builtin">@TypeOf</span>(int_value)).Int.bits &lt;= <span class="tok-number">8</span>) {</span>
<span class="line" id="L766">            <span class="tok-kw">return</span> formatAsciiChar(<span class="tok-builtin">@as</span>(<span class="tok-type">u8</span>, int_value), options, writer);</span>
<span class="line" id="L767">        } <span class="tok-kw">else</span> {</span>
<span class="line" id="L768">            <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;cannot print integer that is larger than 8 bits as an ASCII character&quot;</span>);</span>
<span class="line" id="L769">        }</span>
<span class="line" id="L770">    } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (<span class="tok-kw">comptime</span> std.mem.eql(<span class="tok-type">u8</span>, fmt, <span class="tok-str">&quot;u&quot;</span>)) {</span>
<span class="line" id="L771">        <span class="tok-kw">if</span> (<span class="tok-builtin">@typeInfo</span>(<span class="tok-builtin">@TypeOf</span>(int_value)).Int.bits &lt;= <span class="tok-number">21</span>) {</span>
<span class="line" id="L772">            <span class="tok-kw">return</span> formatUnicodeCodepoint(<span class="tok-builtin">@as</span>(<span class="tok-type">u21</span>, int_value), options, writer);</span>
<span class="line" id="L773">        } <span class="tok-kw">else</span> {</span>
<span class="line" id="L774">            <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;cannot print integer that is larger than 21 bits as an UTF-8 sequence&quot;</span>);</span>
<span class="line" id="L775">        }</span>
<span class="line" id="L776">    } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (<span class="tok-kw">comptime</span> std.mem.eql(<span class="tok-type">u8</span>, fmt, <span class="tok-str">&quot;b&quot;</span>)) {</span>
<span class="line" id="L777">        radix = <span class="tok-number">2</span>;</span>
<span class="line" id="L778">        case = .lower;</span>
<span class="line" id="L779">    } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (<span class="tok-kw">comptime</span> std.mem.eql(<span class="tok-type">u8</span>, fmt, <span class="tok-str">&quot;x&quot;</span>)) {</span>
<span class="line" id="L780">        radix = <span class="tok-number">16</span>;</span>
<span class="line" id="L781">        case = .lower;</span>
<span class="line" id="L782">    } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (<span class="tok-kw">comptime</span> std.mem.eql(<span class="tok-type">u8</span>, fmt, <span class="tok-str">&quot;X&quot;</span>)) {</span>
<span class="line" id="L783">        radix = <span class="tok-number">16</span>;</span>
<span class="line" id="L784">        case = .upper;</span>
<span class="line" id="L785">    } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (<span class="tok-kw">comptime</span> std.mem.eql(<span class="tok-type">u8</span>, fmt, <span class="tok-str">&quot;o&quot;</span>)) {</span>
<span class="line" id="L786">        radix = <span class="tok-number">8</span>;</span>
<span class="line" id="L787">        case = .lower;</span>
<span class="line" id="L788">    } <span class="tok-kw">else</span> {</span>
<span class="line" id="L789">        invalidFmtErr(fmt, value);</span>
<span class="line" id="L790">    }</span>
<span class="line" id="L791"></span>
<span class="line" id="L792">    <span class="tok-kw">return</span> formatInt(int_value, radix, case, options, writer);</span>
<span class="line" id="L793">}</span>
<span class="line" id="L794"></span>
<span class="line" id="L795"><span class="tok-kw">fn</span> <span class="tok-fn">formatFloatValue</span>(</span>
<span class="line" id="L796">    value: <span class="tok-kw">anytype</span>,</span>
<span class="line" id="L797">    <span class="tok-kw">comptime</span> fmt: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L798">    options: FormatOptions,</span>
<span class="line" id="L799">    writer: <span class="tok-kw">anytype</span>,</span>
<span class="line" id="L800">) !<span class="tok-type">void</span> {</span>
<span class="line" id="L801">    <span class="tok-comment">// this buffer should be enough to display all decimal places of a decimal f64 number.</span>
</span>
<span class="line" id="L802">    <span class="tok-kw">var</span> buf: [<span class="tok-number">512</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L803">    <span class="tok-kw">var</span> buf_stream = std.io.fixedBufferStream(&amp;buf);</span>
<span class="line" id="L804"></span>
<span class="line" id="L805">    <span class="tok-kw">if</span> (fmt.len == <span class="tok-number">0</span> <span class="tok-kw">or</span> <span class="tok-kw">comptime</span> std.mem.eql(<span class="tok-type">u8</span>, fmt, <span class="tok-str">&quot;e&quot;</span>)) {</span>
<span class="line" id="L806">        formatFloatScientific(value, options, buf_stream.writer()) <span class="tok-kw">catch</span> |err| <span class="tok-kw">switch</span> (err) {</span>
<span class="line" id="L807">            <span class="tok-kw">error</span>.NoSpaceLeft =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L808">        };</span>
<span class="line" id="L809">    } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (<span class="tok-kw">comptime</span> std.mem.eql(<span class="tok-type">u8</span>, fmt, <span class="tok-str">&quot;d&quot;</span>)) {</span>
<span class="line" id="L810">        formatFloatDecimal(value, options, buf_stream.writer()) <span class="tok-kw">catch</span> |err| <span class="tok-kw">switch</span> (err) {</span>
<span class="line" id="L811">            <span class="tok-kw">error</span>.NoSpaceLeft =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L812">        };</span>
<span class="line" id="L813">    } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (<span class="tok-kw">comptime</span> std.mem.eql(<span class="tok-type">u8</span>, fmt, <span class="tok-str">&quot;x&quot;</span>)) {</span>
<span class="line" id="L814">        formatFloatHexadecimal(value, options, buf_stream.writer()) <span class="tok-kw">catch</span> |err| <span class="tok-kw">switch</span> (err) {</span>
<span class="line" id="L815">            <span class="tok-kw">error</span>.NoSpaceLeft =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L816">        };</span>
<span class="line" id="L817">    } <span class="tok-kw">else</span> {</span>
<span class="line" id="L818">        invalidFmtErr(fmt, value);</span>
<span class="line" id="L819">    }</span>
<span class="line" id="L820"></span>
<span class="line" id="L821">    <span class="tok-kw">return</span> formatBuf(buf_stream.getWritten(), options, writer);</span>
<span class="line" id="L822">}</span>
<span class="line" id="L823"></span>
<span class="line" id="L824"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> Case = <span class="tok-kw">enum</span> { lower, upper };</span>
<span class="line" id="L825"></span>
<span class="line" id="L826"><span class="tok-kw">fn</span> <span class="tok-fn">formatSliceHexImpl</span>(<span class="tok-kw">comptime</span> case: Case) <span class="tok-type">type</span> {</span>
<span class="line" id="L827">    <span class="tok-kw">const</span> charset = <span class="tok-str">&quot;0123456789&quot;</span> ++ <span class="tok-kw">if</span> (case == .upper) <span class="tok-str">&quot;ABCDEF&quot;</span> <span class="tok-kw">else</span> <span class="tok-str">&quot;abcdef&quot;</span>;</span>
<span class="line" id="L828"></span>
<span class="line" id="L829">    <span class="tok-kw">return</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L830">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">f</span>(</span>
<span class="line" id="L831">            bytes: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L832">            <span class="tok-kw">comptime</span> fmt: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L833">            options: std.fmt.FormatOptions,</span>
<span class="line" id="L834">            writer: <span class="tok-kw">anytype</span>,</span>
<span class="line" id="L835">        ) !<span class="tok-type">void</span> {</span>
<span class="line" id="L836">            _ = fmt;</span>
<span class="line" id="L837">            _ = options;</span>
<span class="line" id="L838">            <span class="tok-kw">var</span> buf: [<span class="tok-number">2</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L839"></span>
<span class="line" id="L840">            <span class="tok-kw">for</span> (bytes) |c| {</span>
<span class="line" id="L841">                buf[<span class="tok-number">0</span>] = charset[c &gt;&gt; <span class="tok-number">4</span>];</span>
<span class="line" id="L842">                buf[<span class="tok-number">1</span>] = charset[c &amp; <span class="tok-number">15</span>];</span>
<span class="line" id="L843">                <span class="tok-kw">try</span> writer.writeAll(&amp;buf);</span>
<span class="line" id="L844">            }</span>
<span class="line" id="L845">        }</span>
<span class="line" id="L846">    };</span>
<span class="line" id="L847">}</span>
<span class="line" id="L848"></span>
<span class="line" id="L849"><span class="tok-kw">const</span> formatSliceHexLower = formatSliceHexImpl(.lower).f;</span>
<span class="line" id="L850"><span class="tok-kw">const</span> formatSliceHexUpper = formatSliceHexImpl(.upper).f;</span>
<span class="line" id="L851"></span>
<span class="line" id="L852"><span class="tok-comment">/// Return a Formatter for a []const u8 where every byte is formatted as a pair</span></span>
<span class="line" id="L853"><span class="tok-comment">/// of lowercase hexadecimal digits.</span></span>
<span class="line" id="L854"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">fmtSliceHexLower</span>(bytes: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) std.fmt.Formatter(formatSliceHexLower) {</span>
<span class="line" id="L855">    <span class="tok-kw">return</span> .{ .data = bytes };</span>
<span class="line" id="L856">}</span>
<span class="line" id="L857"></span>
<span class="line" id="L858"><span class="tok-comment">/// Return a Formatter for a []const u8 where every byte is formatted as pair</span></span>
<span class="line" id="L859"><span class="tok-comment">/// of uppercase hexadecimal digits.</span></span>
<span class="line" id="L860"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">fmtSliceHexUpper</span>(bytes: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) std.fmt.Formatter(formatSliceHexUpper) {</span>
<span class="line" id="L861">    <span class="tok-kw">return</span> .{ .data = bytes };</span>
<span class="line" id="L862">}</span>
<span class="line" id="L863"></span>
<span class="line" id="L864"><span class="tok-kw">fn</span> <span class="tok-fn">formatSliceEscapeImpl</span>(<span class="tok-kw">comptime</span> case: Case) <span class="tok-type">type</span> {</span>
<span class="line" id="L865">    <span class="tok-kw">const</span> charset = <span class="tok-str">&quot;0123456789&quot;</span> ++ <span class="tok-kw">if</span> (case == .upper) <span class="tok-str">&quot;ABCDEF&quot;</span> <span class="tok-kw">else</span> <span class="tok-str">&quot;abcdef&quot;</span>;</span>
<span class="line" id="L866"></span>
<span class="line" id="L867">    <span class="tok-kw">return</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L868">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">f</span>(</span>
<span class="line" id="L869">            bytes: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L870">            <span class="tok-kw">comptime</span> fmt: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L871">            options: std.fmt.FormatOptions,</span>
<span class="line" id="L872">            writer: <span class="tok-kw">anytype</span>,</span>
<span class="line" id="L873">        ) !<span class="tok-type">void</span> {</span>
<span class="line" id="L874">            _ = fmt;</span>
<span class="line" id="L875">            _ = options;</span>
<span class="line" id="L876">            <span class="tok-kw">var</span> buf: [<span class="tok-number">4</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L877"></span>
<span class="line" id="L878">            buf[<span class="tok-number">0</span>] = <span class="tok-str">'\\'</span>;</span>
<span class="line" id="L879">            buf[<span class="tok-number">1</span>] = <span class="tok-str">'x'</span>;</span>
<span class="line" id="L880"></span>
<span class="line" id="L881">            <span class="tok-kw">for</span> (bytes) |c| {</span>
<span class="line" id="L882">                <span class="tok-kw">if</span> (std.ascii.isPrint(c)) {</span>
<span class="line" id="L883">                    <span class="tok-kw">try</span> writer.writeByte(c);</span>
<span class="line" id="L884">                } <span class="tok-kw">else</span> {</span>
<span class="line" id="L885">                    buf[<span class="tok-number">2</span>] = charset[c &gt;&gt; <span class="tok-number">4</span>];</span>
<span class="line" id="L886">                    buf[<span class="tok-number">3</span>] = charset[c &amp; <span class="tok-number">15</span>];</span>
<span class="line" id="L887">                    <span class="tok-kw">try</span> writer.writeAll(&amp;buf);</span>
<span class="line" id="L888">                }</span>
<span class="line" id="L889">            }</span>
<span class="line" id="L890">        }</span>
<span class="line" id="L891">    };</span>
<span class="line" id="L892">}</span>
<span class="line" id="L893"></span>
<span class="line" id="L894"><span class="tok-kw">const</span> formatSliceEscapeLower = formatSliceEscapeImpl(.lower).f;</span>
<span class="line" id="L895"><span class="tok-kw">const</span> formatSliceEscapeUpper = formatSliceEscapeImpl(.upper).f;</span>
<span class="line" id="L896"></span>
<span class="line" id="L897"><span class="tok-comment">/// Return a Formatter for a []const u8 where every non-printable ASCII</span></span>
<span class="line" id="L898"><span class="tok-comment">/// character is escaped as \xNN, where NN is the character in lowercase</span></span>
<span class="line" id="L899"><span class="tok-comment">/// hexadecimal notation.</span></span>
<span class="line" id="L900"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">fmtSliceEscapeLower</span>(bytes: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) std.fmt.Formatter(formatSliceEscapeLower) {</span>
<span class="line" id="L901">    <span class="tok-kw">return</span> .{ .data = bytes };</span>
<span class="line" id="L902">}</span>
<span class="line" id="L903"></span>
<span class="line" id="L904"><span class="tok-comment">/// Return a Formatter for a []const u8 where every non-printable ASCII</span></span>
<span class="line" id="L905"><span class="tok-comment">/// character is escaped as \xNN, where NN is the character in uppercase</span></span>
<span class="line" id="L906"><span class="tok-comment">/// hexadecimal notation.</span></span>
<span class="line" id="L907"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">fmtSliceEscapeUpper</span>(bytes: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) std.fmt.Formatter(formatSliceEscapeUpper) {</span>
<span class="line" id="L908">    <span class="tok-kw">return</span> .{ .data = bytes };</span>
<span class="line" id="L909">}</span>
<span class="line" id="L910"></span>
<span class="line" id="L911"><span class="tok-kw">fn</span> <span class="tok-fn">formatSizeImpl</span>(<span class="tok-kw">comptime</span> radix: <span class="tok-type">comptime_int</span>) <span class="tok-type">type</span> {</span>
<span class="line" id="L912">    <span class="tok-kw">return</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L913">        <span class="tok-kw">fn</span> <span class="tok-fn">f</span>(</span>
<span class="line" id="L914">            value: <span class="tok-type">u64</span>,</span>
<span class="line" id="L915">            <span class="tok-kw">comptime</span> fmt: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L916">            options: FormatOptions,</span>
<span class="line" id="L917">            writer: <span class="tok-kw">anytype</span>,</span>
<span class="line" id="L918">        ) !<span class="tok-type">void</span> {</span>
<span class="line" id="L919">            _ = fmt;</span>
<span class="line" id="L920">            <span class="tok-kw">if</span> (value == <span class="tok-number">0</span>) {</span>
<span class="line" id="L921">                <span class="tok-kw">return</span> formatBuf(<span class="tok-str">&quot;0B&quot;</span>, options, writer);</span>
<span class="line" id="L922">            }</span>
<span class="line" id="L923">            <span class="tok-comment">// The worst case in terms of space needed is 32 bytes + 3 for the suffix.</span>
</span>
<span class="line" id="L924">            <span class="tok-kw">var</span> buf: [<span class="tok-number">35</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L925">            <span class="tok-kw">var</span> bufstream = io.fixedBufferStream(buf[<span class="tok-number">0</span>..]);</span>
<span class="line" id="L926"></span>
<span class="line" id="L927">            <span class="tok-kw">const</span> mags_si = <span class="tok-str">&quot; kMGTPEZY&quot;</span>;</span>
<span class="line" id="L928">            <span class="tok-kw">const</span> mags_iec = <span class="tok-str">&quot; KMGTPEZY&quot;</span>;</span>
<span class="line" id="L929"></span>
<span class="line" id="L930">            <span class="tok-kw">const</span> log2 = math.log2(value);</span>
<span class="line" id="L931">            <span class="tok-kw">const</span> magnitude = <span class="tok-kw">switch</span> (radix) {</span>
<span class="line" id="L932">                <span class="tok-number">1000</span> =&gt; math.min(log2 / <span class="tok-kw">comptime</span> math.log2(<span class="tok-number">1000</span>), mags_si.len - <span class="tok-number">1</span>),</span>
<span class="line" id="L933">                <span class="tok-number">1024</span> =&gt; math.min(log2 / <span class="tok-number">10</span>, mags_iec.len - <span class="tok-number">1</span>),</span>
<span class="line" id="L934">                <span class="tok-kw">else</span> =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L935">            };</span>
<span class="line" id="L936">            <span class="tok-kw">const</span> new_value = lossyCast(<span class="tok-type">f64</span>, value) / math.pow(<span class="tok-type">f64</span>, lossyCast(<span class="tok-type">f64</span>, radix), lossyCast(<span class="tok-type">f64</span>, magnitude));</span>
<span class="line" id="L937">            <span class="tok-kw">const</span> suffix = <span class="tok-kw">switch</span> (radix) {</span>
<span class="line" id="L938">                <span class="tok-number">1000</span> =&gt; mags_si[magnitude],</span>
<span class="line" id="L939">                <span class="tok-number">1024</span> =&gt; mags_iec[magnitude],</span>
<span class="line" id="L940">                <span class="tok-kw">else</span> =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L941">            };</span>
<span class="line" id="L942"></span>
<span class="line" id="L943">            formatFloatDecimal(new_value, options, bufstream.writer()) <span class="tok-kw">catch</span> |err| <span class="tok-kw">switch</span> (err) {</span>
<span class="line" id="L944">                <span class="tok-kw">error</span>.NoSpaceLeft =&gt; <span class="tok-kw">unreachable</span>, <span class="tok-comment">// 35 bytes should be enough</span>
</span>
<span class="line" id="L945">            };</span>
<span class="line" id="L946"></span>
<span class="line" id="L947">            bufstream.writer().writeAll(<span class="tok-kw">if</span> (suffix == <span class="tok-str">' '</span>)</span>
<span class="line" id="L948">                <span class="tok-str">&quot;B&quot;</span></span>
<span class="line" id="L949">            <span class="tok-kw">else</span> <span class="tok-kw">switch</span> (radix) {</span>
<span class="line" id="L950">                <span class="tok-number">1000</span> =&gt; &amp;[_]<span class="tok-type">u8</span>{ suffix, <span class="tok-str">'B'</span> },</span>
<span class="line" id="L951">                <span class="tok-number">1024</span> =&gt; &amp;[_]<span class="tok-type">u8</span>{ suffix, <span class="tok-str">'i'</span>, <span class="tok-str">'B'</span> },</span>
<span class="line" id="L952">                <span class="tok-kw">else</span> =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L953">            }) <span class="tok-kw">catch</span> |err| <span class="tok-kw">switch</span> (err) {</span>
<span class="line" id="L954">                <span class="tok-kw">error</span>.NoSpaceLeft =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L955">            };</span>
<span class="line" id="L956">            <span class="tok-kw">return</span> formatBuf(bufstream.getWritten(), options, writer);</span>
<span class="line" id="L957">        }</span>
<span class="line" id="L958">    };</span>
<span class="line" id="L959">}</span>
<span class="line" id="L960"></span>
<span class="line" id="L961"><span class="tok-kw">const</span> formatSizeDec = formatSizeImpl(<span class="tok-number">1000</span>).f;</span>
<span class="line" id="L962"><span class="tok-kw">const</span> formatSizeBin = formatSizeImpl(<span class="tok-number">1024</span>).f;</span>
<span class="line" id="L963"></span>
<span class="line" id="L964"><span class="tok-comment">/// Return a Formatter for a u64 value representing a file size.</span></span>
<span class="line" id="L965"><span class="tok-comment">/// This formatter represents the number as multiple of 1000 and uses the SI</span></span>
<span class="line" id="L966"><span class="tok-comment">/// measurement units (kB, MB, GB, ...).</span></span>
<span class="line" id="L967"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">fmtIntSizeDec</span>(value: <span class="tok-type">u64</span>) std.fmt.Formatter(formatSizeDec) {</span>
<span class="line" id="L968">    <span class="tok-kw">return</span> .{ .data = value };</span>
<span class="line" id="L969">}</span>
<span class="line" id="L970"></span>
<span class="line" id="L971"><span class="tok-comment">/// Return a Formatter for a u64 value representing a file size.</span></span>
<span class="line" id="L972"><span class="tok-comment">/// This formatter represents the number as multiple of 1024 and uses the IEC</span></span>
<span class="line" id="L973"><span class="tok-comment">/// measurement units (KiB, MiB, GiB, ...).</span></span>
<span class="line" id="L974"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">fmtIntSizeBin</span>(value: <span class="tok-type">u64</span>) std.fmt.Formatter(formatSizeBin) {</span>
<span class="line" id="L975">    <span class="tok-kw">return</span> .{ .data = value };</span>
<span class="line" id="L976">}</span>
<span class="line" id="L977"></span>
<span class="line" id="L978"><span class="tok-kw">fn</span> <span class="tok-fn">checkTextFmt</span>(<span class="tok-kw">comptime</span> fmt: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L979">    <span class="tok-kw">if</span> (fmt.len != <span class="tok-number">1</span>)</span>
<span class="line" id="L980">        <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;unsupported format string '&quot;</span> ++ fmt ++ <span class="tok-str">&quot;' when formatting text&quot;</span>);</span>
<span class="line" id="L981">    <span class="tok-kw">switch</span> (fmt[<span class="tok-number">0</span>]) {</span>
<span class="line" id="L982">        <span class="tok-str">'x'</span> =&gt; <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;specifier 'x' has been deprecated, wrap your argument in std.fmt.fmtSliceHexLower instead&quot;</span>),</span>
<span class="line" id="L983">        <span class="tok-str">'X'</span> =&gt; <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;specifier 'X' has been deprecated, wrap your argument in std.fmt.fmtSliceHexUpper instead&quot;</span>),</span>
<span class="line" id="L984">        <span class="tok-str">'e'</span> =&gt; <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;specifier 'e' has been deprecated, wrap your argument in std.fmt.fmtSliceEscapeLower instead&quot;</span>),</span>
<span class="line" id="L985">        <span class="tok-str">'E'</span> =&gt; <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;specifier 'E' has been deprecated, wrap your argument in std.fmt.fmtSliceEscapeUpper instead&quot;</span>),</span>
<span class="line" id="L986">        <span class="tok-str">'z'</span> =&gt; <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;specifier 'z' has been deprecated, wrap your argument in std.zig.fmtId instead&quot;</span>),</span>
<span class="line" id="L987">        <span class="tok-str">'Z'</span> =&gt; <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;specifier 'Z' has been deprecated, wrap your argument in std.zig.fmtEscapes instead&quot;</span>),</span>
<span class="line" id="L988">        <span class="tok-kw">else</span> =&gt; {},</span>
<span class="line" id="L989">    }</span>
<span class="line" id="L990">}</span>
<span class="line" id="L991"></span>
<span class="line" id="L992"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">formatText</span>(</span>
<span class="line" id="L993">    bytes: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L994">    <span class="tok-kw">comptime</span> fmt: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L995">    options: FormatOptions,</span>
<span class="line" id="L996">    writer: <span class="tok-kw">anytype</span>,</span>
<span class="line" id="L997">) !<span class="tok-type">void</span> {</span>
<span class="line" id="L998">    <span class="tok-kw">comptime</span> checkTextFmt(fmt);</span>
<span class="line" id="L999">    <span class="tok-kw">return</span> formatBuf(bytes, options, writer);</span>
<span class="line" id="L1000">}</span>
<span class="line" id="L1001"></span>
<span class="line" id="L1002"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">formatAsciiChar</span>(</span>
<span class="line" id="L1003">    c: <span class="tok-type">u8</span>,</span>
<span class="line" id="L1004">    options: FormatOptions,</span>
<span class="line" id="L1005">    writer: <span class="tok-kw">anytype</span>,</span>
<span class="line" id="L1006">) !<span class="tok-type">void</span> {</span>
<span class="line" id="L1007">    _ = options;</span>
<span class="line" id="L1008">    <span class="tok-kw">return</span> writer.writeAll(<span class="tok-builtin">@as</span>(*<span class="tok-kw">const</span> [<span class="tok-number">1</span>]<span class="tok-type">u8</span>, &amp;c));</span>
<span class="line" id="L1009">}</span>
<span class="line" id="L1010"></span>
<span class="line" id="L1011"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">formatUnicodeCodepoint</span>(</span>
<span class="line" id="L1012">    c: <span class="tok-type">u21</span>,</span>
<span class="line" id="L1013">    options: FormatOptions,</span>
<span class="line" id="L1014">    writer: <span class="tok-kw">anytype</span>,</span>
<span class="line" id="L1015">) !<span class="tok-type">void</span> {</span>
<span class="line" id="L1016">    <span class="tok-kw">var</span> buf: [<span class="tok-number">4</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L1017">    <span class="tok-kw">const</span> len = unicode.utf8Encode(c, &amp;buf) <span class="tok-kw">catch</span> |err| <span class="tok-kw">switch</span> (err) {</span>
<span class="line" id="L1018">        <span class="tok-kw">error</span>.Utf8CannotEncodeSurrogateHalf, <span class="tok-kw">error</span>.CodepointTooLarge =&gt; {</span>
<span class="line" id="L1019">            <span class="tok-kw">const</span> len = unicode.utf8Encode(unicode.replacement_character, &amp;buf) <span class="tok-kw">catch</span> <span class="tok-kw">unreachable</span>;</span>
<span class="line" id="L1020">            <span class="tok-kw">return</span> formatBuf(buf[<span class="tok-number">0</span>..len], options, writer);</span>
<span class="line" id="L1021">        },</span>
<span class="line" id="L1022">    };</span>
<span class="line" id="L1023">    <span class="tok-kw">return</span> formatBuf(buf[<span class="tok-number">0</span>..len], options, writer);</span>
<span class="line" id="L1024">}</span>
<span class="line" id="L1025"></span>
<span class="line" id="L1026"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">formatBuf</span>(</span>
<span class="line" id="L1027">    buf: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L1028">    options: FormatOptions,</span>
<span class="line" id="L1029">    writer: <span class="tok-kw">anytype</span>,</span>
<span class="line" id="L1030">) !<span class="tok-type">void</span> {</span>
<span class="line" id="L1031">    <span class="tok-kw">if</span> (options.width) |min_width| {</span>
<span class="line" id="L1032">        <span class="tok-comment">// In case of error assume the buffer content is ASCII-encoded</span>
</span>
<span class="line" id="L1033">        <span class="tok-kw">const</span> width = unicode.utf8CountCodepoints(buf) <span class="tok-kw">catch</span> buf.len;</span>
<span class="line" id="L1034">        <span class="tok-kw">const</span> padding = <span class="tok-kw">if</span> (width &lt; min_width) min_width - width <span class="tok-kw">else</span> <span class="tok-number">0</span>;</span>
<span class="line" id="L1035"></span>
<span class="line" id="L1036">        <span class="tok-kw">if</span> (padding == <span class="tok-number">0</span>)</span>
<span class="line" id="L1037">            <span class="tok-kw">return</span> writer.writeAll(buf);</span>
<span class="line" id="L1038"></span>
<span class="line" id="L1039">        <span class="tok-kw">switch</span> (options.alignment) {</span>
<span class="line" id="L1040">            .Left =&gt; {</span>
<span class="line" id="L1041">                <span class="tok-kw">try</span> writer.writeAll(buf);</span>
<span class="line" id="L1042">                <span class="tok-kw">try</span> writer.writeByteNTimes(options.fill, padding);</span>
<span class="line" id="L1043">            },</span>
<span class="line" id="L1044">            .Center =&gt; {</span>
<span class="line" id="L1045">                <span class="tok-kw">const</span> left_padding = padding / <span class="tok-number">2</span>;</span>
<span class="line" id="L1046">                <span class="tok-kw">const</span> right_padding = (padding + <span class="tok-number">1</span>) / <span class="tok-number">2</span>;</span>
<span class="line" id="L1047">                <span class="tok-kw">try</span> writer.writeByteNTimes(options.fill, left_padding);</span>
<span class="line" id="L1048">                <span class="tok-kw">try</span> writer.writeAll(buf);</span>
<span class="line" id="L1049">                <span class="tok-kw">try</span> writer.writeByteNTimes(options.fill, right_padding);</span>
<span class="line" id="L1050">            },</span>
<span class="line" id="L1051">            .Right =&gt; {</span>
<span class="line" id="L1052">                <span class="tok-kw">try</span> writer.writeByteNTimes(options.fill, padding);</span>
<span class="line" id="L1053">                <span class="tok-kw">try</span> writer.writeAll(buf);</span>
<span class="line" id="L1054">            },</span>
<span class="line" id="L1055">        }</span>
<span class="line" id="L1056">    } <span class="tok-kw">else</span> {</span>
<span class="line" id="L1057">        <span class="tok-comment">// Fast path, avoid counting the number of codepoints</span>
</span>
<span class="line" id="L1058">        <span class="tok-kw">try</span> writer.writeAll(buf);</span>
<span class="line" id="L1059">    }</span>
<span class="line" id="L1060">}</span>
<span class="line" id="L1061"></span>
<span class="line" id="L1062"><span class="tok-comment">/// Print a float in scientific notation to the specified precision. Null uses full precision.</span></span>
<span class="line" id="L1063"><span class="tok-comment">/// It should be the case that every full precision, printed value can be re-parsed back to the</span></span>
<span class="line" id="L1064"><span class="tok-comment">/// same type unambiguously.</span></span>
<span class="line" id="L1065"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">formatFloatScientific</span>(</span>
<span class="line" id="L1066">    value: <span class="tok-kw">anytype</span>,</span>
<span class="line" id="L1067">    options: FormatOptions,</span>
<span class="line" id="L1068">    writer: <span class="tok-kw">anytype</span>,</span>
<span class="line" id="L1069">) !<span class="tok-type">void</span> {</span>
<span class="line" id="L1070">    <span class="tok-kw">var</span> x = <span class="tok-builtin">@floatCast</span>(<span class="tok-type">f64</span>, value);</span>
<span class="line" id="L1071"></span>
<span class="line" id="L1072">    <span class="tok-comment">// Errol doesn't handle these special cases.</span>
</span>
<span class="line" id="L1073">    <span class="tok-kw">if</span> (math.signbit(x)) {</span>
<span class="line" id="L1074">        <span class="tok-kw">try</span> writer.writeAll(<span class="tok-str">&quot;-&quot;</span>);</span>
<span class="line" id="L1075">        x = -x;</span>
<span class="line" id="L1076">    }</span>
<span class="line" id="L1077"></span>
<span class="line" id="L1078">    <span class="tok-kw">if</span> (math.isNan(x)) {</span>
<span class="line" id="L1079">        <span class="tok-kw">return</span> writer.writeAll(<span class="tok-str">&quot;nan&quot;</span>);</span>
<span class="line" id="L1080">    }</span>
<span class="line" id="L1081">    <span class="tok-kw">if</span> (math.isPositiveInf(x)) {</span>
<span class="line" id="L1082">        <span class="tok-kw">return</span> writer.writeAll(<span class="tok-str">&quot;inf&quot;</span>);</span>
<span class="line" id="L1083">    }</span>
<span class="line" id="L1084">    <span class="tok-kw">if</span> (x == <span class="tok-number">0.0</span>) {</span>
<span class="line" id="L1085">        <span class="tok-kw">try</span> writer.writeAll(<span class="tok-str">&quot;0&quot;</span>);</span>
<span class="line" id="L1086"></span>
<span class="line" id="L1087">        <span class="tok-kw">if</span> (options.precision) |precision| {</span>
<span class="line" id="L1088">            <span class="tok-kw">if</span> (precision != <span class="tok-number">0</span>) {</span>
<span class="line" id="L1089">                <span class="tok-kw">try</span> writer.writeAll(<span class="tok-str">&quot;.&quot;</span>);</span>
<span class="line" id="L1090">                <span class="tok-kw">var</span> i: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L1091">                <span class="tok-kw">while</span> (i &lt; precision) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L1092">                    <span class="tok-kw">try</span> writer.writeAll(<span class="tok-str">&quot;0&quot;</span>);</span>
<span class="line" id="L1093">                }</span>
<span class="line" id="L1094">            }</span>
<span class="line" id="L1095">        } <span class="tok-kw">else</span> {</span>
<span class="line" id="L1096">            <span class="tok-kw">try</span> writer.writeAll(<span class="tok-str">&quot;.0&quot;</span>);</span>
<span class="line" id="L1097">        }</span>
<span class="line" id="L1098"></span>
<span class="line" id="L1099">        <span class="tok-kw">try</span> writer.writeAll(<span class="tok-str">&quot;e+00&quot;</span>);</span>
<span class="line" id="L1100">        <span class="tok-kw">return</span>;</span>
<span class="line" id="L1101">    }</span>
<span class="line" id="L1102"></span>
<span class="line" id="L1103">    <span class="tok-kw">var</span> buffer: [<span class="tok-number">32</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L1104">    <span class="tok-kw">var</span> float_decimal = errol.errol3(x, buffer[<span class="tok-number">0</span>..]);</span>
<span class="line" id="L1105"></span>
<span class="line" id="L1106">    <span class="tok-kw">if</span> (options.precision) |precision| {</span>
<span class="line" id="L1107">        errol.roundToPrecision(&amp;float_decimal, precision, errol.RoundMode.Scientific);</span>
<span class="line" id="L1108"></span>
<span class="line" id="L1109">        <span class="tok-kw">try</span> writer.writeAll(float_decimal.digits[<span class="tok-number">0</span>..<span class="tok-number">1</span>]);</span>
<span class="line" id="L1110"></span>
<span class="line" id="L1111">        <span class="tok-comment">// {e0} case prints no `.`</span>
</span>
<span class="line" id="L1112">        <span class="tok-kw">if</span> (precision != <span class="tok-number">0</span>) {</span>
<span class="line" id="L1113">            <span class="tok-kw">try</span> writer.writeAll(<span class="tok-str">&quot;.&quot;</span>);</span>
<span class="line" id="L1114"></span>
<span class="line" id="L1115">            <span class="tok-kw">var</span> printed: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L1116">            <span class="tok-kw">if</span> (float_decimal.digits.len &gt; <span class="tok-number">1</span>) {</span>
<span class="line" id="L1117">                <span class="tok-kw">const</span> num_digits = math.min(float_decimal.digits.len, precision + <span class="tok-number">1</span>);</span>
<span class="line" id="L1118">                <span class="tok-kw">try</span> writer.writeAll(float_decimal.digits[<span class="tok-number">1</span>..num_digits]);</span>
<span class="line" id="L1119">                printed += num_digits - <span class="tok-number">1</span>;</span>
<span class="line" id="L1120">            }</span>
<span class="line" id="L1121"></span>
<span class="line" id="L1122">            <span class="tok-kw">while</span> (printed &lt; precision) : (printed += <span class="tok-number">1</span>) {</span>
<span class="line" id="L1123">                <span class="tok-kw">try</span> writer.writeAll(<span class="tok-str">&quot;0&quot;</span>);</span>
<span class="line" id="L1124">            }</span>
<span class="line" id="L1125">        }</span>
<span class="line" id="L1126">    } <span class="tok-kw">else</span> {</span>
<span class="line" id="L1127">        <span class="tok-kw">try</span> writer.writeAll(float_decimal.digits[<span class="tok-number">0</span>..<span class="tok-number">1</span>]);</span>
<span class="line" id="L1128">        <span class="tok-kw">try</span> writer.writeAll(<span class="tok-str">&quot;.&quot;</span>);</span>
<span class="line" id="L1129">        <span class="tok-kw">if</span> (float_decimal.digits.len &gt; <span class="tok-number">1</span>) {</span>
<span class="line" id="L1130">            <span class="tok-kw">const</span> num_digits = <span class="tok-kw">if</span> (<span class="tok-builtin">@TypeOf</span>(value) == <span class="tok-type">f32</span>) math.min(<span class="tok-builtin">@as</span>(<span class="tok-type">usize</span>, <span class="tok-number">9</span>), float_decimal.digits.len) <span class="tok-kw">else</span> float_decimal.digits.len;</span>
<span class="line" id="L1131"></span>
<span class="line" id="L1132">            <span class="tok-kw">try</span> writer.writeAll(float_decimal.digits[<span class="tok-number">1</span>..num_digits]);</span>
<span class="line" id="L1133">        } <span class="tok-kw">else</span> {</span>
<span class="line" id="L1134">            <span class="tok-kw">try</span> writer.writeAll(<span class="tok-str">&quot;0&quot;</span>);</span>
<span class="line" id="L1135">        }</span>
<span class="line" id="L1136">    }</span>
<span class="line" id="L1137"></span>
<span class="line" id="L1138">    <span class="tok-kw">try</span> writer.writeAll(<span class="tok-str">&quot;e&quot;</span>);</span>
<span class="line" id="L1139">    <span class="tok-kw">const</span> exp = float_decimal.exp - <span class="tok-number">1</span>;</span>
<span class="line" id="L1140"></span>
<span class="line" id="L1141">    <span class="tok-kw">if</span> (exp &gt;= <span class="tok-number">0</span>) {</span>
<span class="line" id="L1142">        <span class="tok-kw">try</span> writer.writeAll(<span class="tok-str">&quot;+&quot;</span>);</span>
<span class="line" id="L1143">        <span class="tok-kw">if</span> (exp &gt; -<span class="tok-number">10</span> <span class="tok-kw">and</span> exp &lt; <span class="tok-number">10</span>) {</span>
<span class="line" id="L1144">            <span class="tok-kw">try</span> writer.writeAll(<span class="tok-str">&quot;0&quot;</span>);</span>
<span class="line" id="L1145">        }</span>
<span class="line" id="L1146">        <span class="tok-kw">try</span> formatInt(exp, <span class="tok-number">10</span>, .lower, FormatOptions{ .width = <span class="tok-number">0</span> }, writer);</span>
<span class="line" id="L1147">    } <span class="tok-kw">else</span> {</span>
<span class="line" id="L1148">        <span class="tok-kw">try</span> writer.writeAll(<span class="tok-str">&quot;-&quot;</span>);</span>
<span class="line" id="L1149">        <span class="tok-kw">if</span> (exp &gt; -<span class="tok-number">10</span> <span class="tok-kw">and</span> exp &lt; <span class="tok-number">10</span>) {</span>
<span class="line" id="L1150">            <span class="tok-kw">try</span> writer.writeAll(<span class="tok-str">&quot;0&quot;</span>);</span>
<span class="line" id="L1151">        }</span>
<span class="line" id="L1152">        <span class="tok-kw">try</span> formatInt(-exp, <span class="tok-number">10</span>, .lower, FormatOptions{ .width = <span class="tok-number">0</span> }, writer);</span>
<span class="line" id="L1153">    }</span>
<span class="line" id="L1154">}</span>
<span class="line" id="L1155"></span>
<span class="line" id="L1156"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">formatFloatHexadecimal</span>(</span>
<span class="line" id="L1157">    value: <span class="tok-kw">anytype</span>,</span>
<span class="line" id="L1158">    options: FormatOptions,</span>
<span class="line" id="L1159">    writer: <span class="tok-kw">anytype</span>,</span>
<span class="line" id="L1160">) !<span class="tok-type">void</span> {</span>
<span class="line" id="L1161">    <span class="tok-kw">if</span> (math.signbit(value)) {</span>
<span class="line" id="L1162">        <span class="tok-kw">try</span> writer.writeByte(<span class="tok-str">'-'</span>);</span>
<span class="line" id="L1163">    }</span>
<span class="line" id="L1164">    <span class="tok-kw">if</span> (math.isNan(value)) {</span>
<span class="line" id="L1165">        <span class="tok-kw">return</span> writer.writeAll(<span class="tok-str">&quot;nan&quot;</span>);</span>
<span class="line" id="L1166">    }</span>
<span class="line" id="L1167">    <span class="tok-kw">if</span> (math.isInf(value)) {</span>
<span class="line" id="L1168">        <span class="tok-kw">return</span> writer.writeAll(<span class="tok-str">&quot;inf&quot;</span>);</span>
<span class="line" id="L1169">    }</span>
<span class="line" id="L1170"></span>
<span class="line" id="L1171">    <span class="tok-kw">const</span> T = <span class="tok-builtin">@TypeOf</span>(value);</span>
<span class="line" id="L1172">    <span class="tok-kw">const</span> TU = std.meta.Int(.unsigned, <span class="tok-builtin">@bitSizeOf</span>(T));</span>
<span class="line" id="L1173"></span>
<span class="line" id="L1174">    <span class="tok-kw">const</span> mantissa_bits = math.floatMantissaBits(T);</span>
<span class="line" id="L1175">    <span class="tok-kw">const</span> fractional_bits = math.floatFractionalBits(T);</span>
<span class="line" id="L1176">    <span class="tok-kw">const</span> exponent_bits = math.floatExponentBits(T);</span>
<span class="line" id="L1177">    <span class="tok-kw">const</span> mantissa_mask = (<span class="tok-number">1</span> &lt;&lt; mantissa_bits) - <span class="tok-number">1</span>;</span>
<span class="line" id="L1178">    <span class="tok-kw">const</span> exponent_mask = (<span class="tok-number">1</span> &lt;&lt; exponent_bits) - <span class="tok-number">1</span>;</span>
<span class="line" id="L1179">    <span class="tok-kw">const</span> exponent_bias = (<span class="tok-number">1</span> &lt;&lt; (exponent_bits - <span class="tok-number">1</span>)) - <span class="tok-number">1</span>;</span>
<span class="line" id="L1180"></span>
<span class="line" id="L1181">    <span class="tok-kw">const</span> as_bits = <span class="tok-builtin">@bitCast</span>(TU, value);</span>
<span class="line" id="L1182">    <span class="tok-kw">var</span> mantissa = as_bits &amp; mantissa_mask;</span>
<span class="line" id="L1183">    <span class="tok-kw">var</span> exponent: <span class="tok-type">i32</span> = <span class="tok-builtin">@truncate</span>(<span class="tok-type">u16</span>, (as_bits &gt;&gt; mantissa_bits) &amp; exponent_mask);</span>
<span class="line" id="L1184"></span>
<span class="line" id="L1185">    <span class="tok-kw">const</span> is_denormal = exponent == <span class="tok-number">0</span> <span class="tok-kw">and</span> mantissa != <span class="tok-number">0</span>;</span>
<span class="line" id="L1186">    <span class="tok-kw">const</span> is_zero = exponent == <span class="tok-number">0</span> <span class="tok-kw">and</span> mantissa == <span class="tok-number">0</span>;</span>
<span class="line" id="L1187"></span>
<span class="line" id="L1188">    <span class="tok-kw">if</span> (is_zero) {</span>
<span class="line" id="L1189">        <span class="tok-comment">// Handle this case here to simplify the logic below.</span>
</span>
<span class="line" id="L1190">        <span class="tok-kw">try</span> writer.writeAll(<span class="tok-str">&quot;0x0&quot;</span>);</span>
<span class="line" id="L1191">        <span class="tok-kw">if</span> (options.precision) |precision| {</span>
<span class="line" id="L1192">            <span class="tok-kw">if</span> (precision &gt; <span class="tok-number">0</span>) {</span>
<span class="line" id="L1193">                <span class="tok-kw">try</span> writer.writeAll(<span class="tok-str">&quot;.&quot;</span>);</span>
<span class="line" id="L1194">                <span class="tok-kw">try</span> writer.writeByteNTimes(<span class="tok-str">'0'</span>, precision);</span>
<span class="line" id="L1195">            }</span>
<span class="line" id="L1196">        } <span class="tok-kw">else</span> {</span>
<span class="line" id="L1197">            <span class="tok-kw">try</span> writer.writeAll(<span class="tok-str">&quot;.0&quot;</span>);</span>
<span class="line" id="L1198">        }</span>
<span class="line" id="L1199">        <span class="tok-kw">try</span> writer.writeAll(<span class="tok-str">&quot;p0&quot;</span>);</span>
<span class="line" id="L1200">        <span class="tok-kw">return</span>;</span>
<span class="line" id="L1201">    }</span>
<span class="line" id="L1202"></span>
<span class="line" id="L1203">    <span class="tok-kw">if</span> (is_denormal) {</span>
<span class="line" id="L1204">        <span class="tok-comment">// Adjust the exponent for printing.</span>
</span>
<span class="line" id="L1205">        exponent += <span class="tok-number">1</span>;</span>
<span class="line" id="L1206">    } <span class="tok-kw">else</span> {</span>
<span class="line" id="L1207">        <span class="tok-kw">if</span> (fractional_bits == mantissa_bits)</span>
<span class="line" id="L1208">            mantissa |= <span class="tok-number">1</span> &lt;&lt; fractional_bits; <span class="tok-comment">// Add the implicit integer bit.</span>
</span>
<span class="line" id="L1209">    }</span>
<span class="line" id="L1210"></span>
<span class="line" id="L1211">    <span class="tok-comment">// Fill in zeroes to round the mantissa width to a multiple of 4.</span>
</span>
<span class="line" id="L1212">    <span class="tok-kw">if</span> (T == <span class="tok-type">f16</span>) mantissa &lt;&lt;= <span class="tok-number">2</span> <span class="tok-kw">else</span> <span class="tok-kw">if</span> (T == <span class="tok-type">f32</span>) mantissa &lt;&lt;= <span class="tok-number">1</span>;</span>
<span class="line" id="L1213"></span>
<span class="line" id="L1214">    <span class="tok-kw">const</span> mantissa_digits = (fractional_bits + <span class="tok-number">3</span>) / <span class="tok-number">4</span>;</span>
<span class="line" id="L1215"></span>
<span class="line" id="L1216">    <span class="tok-kw">if</span> (options.precision) |precision| {</span>
<span class="line" id="L1217">        <span class="tok-comment">// Round if needed.</span>
</span>
<span class="line" id="L1218">        <span class="tok-kw">if</span> (precision &lt; mantissa_digits) {</span>
<span class="line" id="L1219">            <span class="tok-comment">// We always have at least 4 extra bits.</span>
</span>
<span class="line" id="L1220">            <span class="tok-kw">var</span> extra_bits = (mantissa_digits - precision) * <span class="tok-number">4</span>;</span>
<span class="line" id="L1221">            <span class="tok-comment">// The result LSB is the Guard bit, we need two more (Round and</span>
</span>
<span class="line" id="L1222">            <span class="tok-comment">// Sticky) to round the value.</span>
</span>
<span class="line" id="L1223">            <span class="tok-kw">while</span> (extra_bits &gt; <span class="tok-number">2</span>) {</span>
<span class="line" id="L1224">                mantissa = (mantissa &gt;&gt; <span class="tok-number">1</span>) | (mantissa &amp; <span class="tok-number">1</span>);</span>
<span class="line" id="L1225">                extra_bits -= <span class="tok-number">1</span>;</span>
<span class="line" id="L1226">            }</span>
<span class="line" id="L1227">            <span class="tok-comment">// Round to nearest, tie to even.</span>
</span>
<span class="line" id="L1228">            mantissa |= <span class="tok-builtin">@boolToInt</span>(mantissa &amp; <span class="tok-number">0b100</span> != <span class="tok-number">0</span>);</span>
<span class="line" id="L1229">            mantissa += <span class="tok-number">1</span>;</span>
<span class="line" id="L1230">            <span class="tok-comment">// Drop the excess bits.</span>
</span>
<span class="line" id="L1231">            mantissa &gt;&gt;= <span class="tok-number">2</span>;</span>
<span class="line" id="L1232">            <span class="tok-comment">// Restore the alignment.</span>
</span>
<span class="line" id="L1233">            mantissa &lt;&lt;= <span class="tok-builtin">@intCast</span>(math.Log2Int(TU), (mantissa_digits - precision) * <span class="tok-number">4</span>);</span>
<span class="line" id="L1234"></span>
<span class="line" id="L1235">            <span class="tok-kw">const</span> overflow = mantissa &amp; (<span class="tok-number">1</span> &lt;&lt; <span class="tok-number">1</span> + mantissa_digits * <span class="tok-number">4</span>) != <span class="tok-number">0</span>;</span>
<span class="line" id="L1236">            <span class="tok-comment">// Prefer a normalized result in case of overflow.</span>
</span>
<span class="line" id="L1237">            <span class="tok-kw">if</span> (overflow) {</span>
<span class="line" id="L1238">                mantissa &gt;&gt;= <span class="tok-number">1</span>;</span>
<span class="line" id="L1239">                exponent += <span class="tok-number">1</span>;</span>
<span class="line" id="L1240">            }</span>
<span class="line" id="L1241">        }</span>
<span class="line" id="L1242">    }</span>
<span class="line" id="L1243"></span>
<span class="line" id="L1244">    <span class="tok-comment">// +1 for the decimal part.</span>
</span>
<span class="line" id="L1245">    <span class="tok-kw">var</span> buf: [<span class="tok-number">1</span> + mantissa_digits]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L1246">    _ = formatIntBuf(&amp;buf, mantissa, <span class="tok-number">16</span>, .lower, .{ .fill = <span class="tok-str">'0'</span>, .width = <span class="tok-number">1</span> + mantissa_digits });</span>
<span class="line" id="L1247"></span>
<span class="line" id="L1248">    <span class="tok-kw">try</span> writer.writeAll(<span class="tok-str">&quot;0x&quot;</span>);</span>
<span class="line" id="L1249">    <span class="tok-kw">try</span> writer.writeByte(buf[<span class="tok-number">0</span>]);</span>
<span class="line" id="L1250">    <span class="tok-kw">const</span> trimmed = mem.trimRight(<span class="tok-type">u8</span>, buf[<span class="tok-number">1</span>..], <span class="tok-str">&quot;0&quot;</span>);</span>
<span class="line" id="L1251">    <span class="tok-kw">if</span> (options.precision) |precision| {</span>
<span class="line" id="L1252">        <span class="tok-kw">if</span> (precision &gt; <span class="tok-number">0</span>) <span class="tok-kw">try</span> writer.writeAll(<span class="tok-str">&quot;.&quot;</span>);</span>
<span class="line" id="L1253">    } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (trimmed.len &gt; <span class="tok-number">0</span>) {</span>
<span class="line" id="L1254">        <span class="tok-kw">try</span> writer.writeAll(<span class="tok-str">&quot;.&quot;</span>);</span>
<span class="line" id="L1255">    }</span>
<span class="line" id="L1256">    <span class="tok-kw">try</span> writer.writeAll(trimmed);</span>
<span class="line" id="L1257">    <span class="tok-comment">// Add trailing zeros if explicitly requested.</span>
</span>
<span class="line" id="L1258">    <span class="tok-kw">if</span> (options.precision) |precision| <span class="tok-kw">if</span> (precision &gt; <span class="tok-number">0</span>) {</span>
<span class="line" id="L1259">        <span class="tok-kw">if</span> (precision &gt; trimmed.len)</span>
<span class="line" id="L1260">            <span class="tok-kw">try</span> writer.writeByteNTimes(<span class="tok-str">'0'</span>, precision - trimmed.len);</span>
<span class="line" id="L1261">    };</span>
<span class="line" id="L1262">    <span class="tok-kw">try</span> writer.writeAll(<span class="tok-str">&quot;p&quot;</span>);</span>
<span class="line" id="L1263">    <span class="tok-kw">try</span> formatInt(exponent - exponent_bias, <span class="tok-number">10</span>, .lower, .{}, writer);</span>
<span class="line" id="L1264">}</span>
<span class="line" id="L1265"></span>
<span class="line" id="L1266"><span class="tok-comment">/// Print a float of the format x.yyyyy where the number of y is specified by the precision argument.</span></span>
<span class="line" id="L1267"><span class="tok-comment">/// By default floats are printed at full precision (no rounding).</span></span>
<span class="line" id="L1268"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">formatFloatDecimal</span>(</span>
<span class="line" id="L1269">    value: <span class="tok-kw">anytype</span>,</span>
<span class="line" id="L1270">    options: FormatOptions,</span>
<span class="line" id="L1271">    writer: <span class="tok-kw">anytype</span>,</span>
<span class="line" id="L1272">) !<span class="tok-type">void</span> {</span>
<span class="line" id="L1273">    <span class="tok-kw">var</span> x = <span class="tok-builtin">@as</span>(<span class="tok-type">f64</span>, value);</span>
<span class="line" id="L1274"></span>
<span class="line" id="L1275">    <span class="tok-comment">// Errol doesn't handle these special cases.</span>
</span>
<span class="line" id="L1276">    <span class="tok-kw">if</span> (math.signbit(x)) {</span>
<span class="line" id="L1277">        <span class="tok-kw">try</span> writer.writeAll(<span class="tok-str">&quot;-&quot;</span>);</span>
<span class="line" id="L1278">        x = -x;</span>
<span class="line" id="L1279">    }</span>
<span class="line" id="L1280"></span>
<span class="line" id="L1281">    <span class="tok-kw">if</span> (math.isNan(x)) {</span>
<span class="line" id="L1282">        <span class="tok-kw">return</span> writer.writeAll(<span class="tok-str">&quot;nan&quot;</span>);</span>
<span class="line" id="L1283">    }</span>
<span class="line" id="L1284">    <span class="tok-kw">if</span> (math.isPositiveInf(x)) {</span>
<span class="line" id="L1285">        <span class="tok-kw">return</span> writer.writeAll(<span class="tok-str">&quot;inf&quot;</span>);</span>
<span class="line" id="L1286">    }</span>
<span class="line" id="L1287">    <span class="tok-kw">if</span> (x == <span class="tok-number">0.0</span>) {</span>
<span class="line" id="L1288">        <span class="tok-kw">try</span> writer.writeAll(<span class="tok-str">&quot;0&quot;</span>);</span>
<span class="line" id="L1289"></span>
<span class="line" id="L1290">        <span class="tok-kw">if</span> (options.precision) |precision| {</span>
<span class="line" id="L1291">            <span class="tok-kw">if</span> (precision != <span class="tok-number">0</span>) {</span>
<span class="line" id="L1292">                <span class="tok-kw">try</span> writer.writeAll(<span class="tok-str">&quot;.&quot;</span>);</span>
<span class="line" id="L1293">                <span class="tok-kw">var</span> i: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L1294">                <span class="tok-kw">while</span> (i &lt; precision) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L1295">                    <span class="tok-kw">try</span> writer.writeAll(<span class="tok-str">&quot;0&quot;</span>);</span>
<span class="line" id="L1296">                }</span>
<span class="line" id="L1297">            }</span>
<span class="line" id="L1298">        }</span>
<span class="line" id="L1299"></span>
<span class="line" id="L1300">        <span class="tok-kw">return</span>;</span>
<span class="line" id="L1301">    }</span>
<span class="line" id="L1302"></span>
<span class="line" id="L1303">    <span class="tok-comment">// non-special case, use errol3</span>
</span>
<span class="line" id="L1304">    <span class="tok-kw">var</span> buffer: [<span class="tok-number">32</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L1305">    <span class="tok-kw">var</span> float_decimal = errol.errol3(x, buffer[<span class="tok-number">0</span>..]);</span>
<span class="line" id="L1306"></span>
<span class="line" id="L1307">    <span class="tok-kw">if</span> (options.precision) |precision| {</span>
<span class="line" id="L1308">        errol.roundToPrecision(&amp;float_decimal, precision, errol.RoundMode.Decimal);</span>
<span class="line" id="L1309"></span>
<span class="line" id="L1310">        <span class="tok-comment">// exp &lt; 0 means the leading is always 0 as errol result is normalized.</span>
</span>
<span class="line" id="L1311">        <span class="tok-kw">var</span> num_digits_whole = <span class="tok-kw">if</span> (float_decimal.exp &gt; <span class="tok-number">0</span>) <span class="tok-builtin">@intCast</span>(<span class="tok-type">usize</span>, float_decimal.exp) <span class="tok-kw">else</span> <span class="tok-number">0</span>;</span>
<span class="line" id="L1312"></span>
<span class="line" id="L1313">        <span class="tok-comment">// the actual slice into the buffer, we may need to zero-pad between num_digits_whole and this.</span>
</span>
<span class="line" id="L1314">        <span class="tok-kw">var</span> num_digits_whole_no_pad = math.min(num_digits_whole, float_decimal.digits.len);</span>
<span class="line" id="L1315"></span>
<span class="line" id="L1316">        <span class="tok-kw">if</span> (num_digits_whole &gt; <span class="tok-number">0</span>) {</span>
<span class="line" id="L1317">            <span class="tok-comment">// We may have to zero pad, for instance 1e4 requires zero padding.</span>
</span>
<span class="line" id="L1318">            <span class="tok-kw">try</span> writer.writeAll(float_decimal.digits[<span class="tok-number">0</span>..num_digits_whole_no_pad]);</span>
<span class="line" id="L1319"></span>
<span class="line" id="L1320">            <span class="tok-kw">var</span> i = num_digits_whole_no_pad;</span>
<span class="line" id="L1321">            <span class="tok-kw">while</span> (i &lt; num_digits_whole) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L1322">                <span class="tok-kw">try</span> writer.writeAll(<span class="tok-str">&quot;0&quot;</span>);</span>
<span class="line" id="L1323">            }</span>
<span class="line" id="L1324">        } <span class="tok-kw">else</span> {</span>
<span class="line" id="L1325">            <span class="tok-kw">try</span> writer.writeAll(<span class="tok-str">&quot;0&quot;</span>);</span>
<span class="line" id="L1326">        }</span>
<span class="line" id="L1327"></span>
<span class="line" id="L1328">        <span class="tok-comment">// {.0} special case doesn't want a trailing '.'</span>
</span>
<span class="line" id="L1329">        <span class="tok-kw">if</span> (precision == <span class="tok-number">0</span>) {</span>
<span class="line" id="L1330">            <span class="tok-kw">return</span>;</span>
<span class="line" id="L1331">        }</span>
<span class="line" id="L1332"></span>
<span class="line" id="L1333">        <span class="tok-kw">try</span> writer.writeAll(<span class="tok-str">&quot;.&quot;</span>);</span>
<span class="line" id="L1334"></span>
<span class="line" id="L1335">        <span class="tok-comment">// Keep track of fractional count printed for case where we pre-pad then post-pad with 0's.</span>
</span>
<span class="line" id="L1336">        <span class="tok-kw">var</span> printed: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L1337"></span>
<span class="line" id="L1338">        <span class="tok-comment">// Zero-fill until we reach significant digits or run out of precision.</span>
</span>
<span class="line" id="L1339">        <span class="tok-kw">if</span> (float_decimal.exp &lt;= <span class="tok-number">0</span>) {</span>
<span class="line" id="L1340">            <span class="tok-kw">const</span> zero_digit_count = <span class="tok-builtin">@intCast</span>(<span class="tok-type">usize</span>, -float_decimal.exp);</span>
<span class="line" id="L1341">            <span class="tok-kw">const</span> zeros_to_print = math.min(zero_digit_count, precision);</span>
<span class="line" id="L1342"></span>
<span class="line" id="L1343">            <span class="tok-kw">var</span> i: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L1344">            <span class="tok-kw">while</span> (i &lt; zeros_to_print) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L1345">                <span class="tok-kw">try</span> writer.writeAll(<span class="tok-str">&quot;0&quot;</span>);</span>
<span class="line" id="L1346">                printed += <span class="tok-number">1</span>;</span>
<span class="line" id="L1347">            }</span>
<span class="line" id="L1348"></span>
<span class="line" id="L1349">            <span class="tok-kw">if</span> (printed &gt;= precision) {</span>
<span class="line" id="L1350">                <span class="tok-kw">return</span>;</span>
<span class="line" id="L1351">            }</span>
<span class="line" id="L1352">        }</span>
<span class="line" id="L1353"></span>
<span class="line" id="L1354">        <span class="tok-comment">// Remaining fractional portion, zero-padding if insufficient.</span>
</span>
<span class="line" id="L1355">        assert(precision &gt;= printed);</span>
<span class="line" id="L1356">        <span class="tok-kw">if</span> (num_digits_whole_no_pad + precision - printed &lt; float_decimal.digits.len) {</span>
<span class="line" id="L1357">            <span class="tok-kw">try</span> writer.writeAll(float_decimal.digits[num_digits_whole_no_pad .. num_digits_whole_no_pad + precision - printed]);</span>
<span class="line" id="L1358">            <span class="tok-kw">return</span>;</span>
<span class="line" id="L1359">        } <span class="tok-kw">else</span> {</span>
<span class="line" id="L1360">            <span class="tok-kw">try</span> writer.writeAll(float_decimal.digits[num_digits_whole_no_pad..]);</span>
<span class="line" id="L1361">            printed += float_decimal.digits.len - num_digits_whole_no_pad;</span>
<span class="line" id="L1362"></span>
<span class="line" id="L1363">            <span class="tok-kw">while</span> (printed &lt; precision) : (printed += <span class="tok-number">1</span>) {</span>
<span class="line" id="L1364">                <span class="tok-kw">try</span> writer.writeAll(<span class="tok-str">&quot;0&quot;</span>);</span>
<span class="line" id="L1365">            }</span>
<span class="line" id="L1366">        }</span>
<span class="line" id="L1367">    } <span class="tok-kw">else</span> {</span>
<span class="line" id="L1368">        <span class="tok-comment">// exp &lt; 0 means the leading is always 0 as errol result is normalized.</span>
</span>
<span class="line" id="L1369">        <span class="tok-kw">var</span> num_digits_whole = <span class="tok-kw">if</span> (float_decimal.exp &gt; <span class="tok-number">0</span>) <span class="tok-builtin">@intCast</span>(<span class="tok-type">usize</span>, float_decimal.exp) <span class="tok-kw">else</span> <span class="tok-number">0</span>;</span>
<span class="line" id="L1370"></span>
<span class="line" id="L1371">        <span class="tok-comment">// the actual slice into the buffer, we may need to zero-pad between num_digits_whole and this.</span>
</span>
<span class="line" id="L1372">        <span class="tok-kw">var</span> num_digits_whole_no_pad = math.min(num_digits_whole, float_decimal.digits.len);</span>
<span class="line" id="L1373"></span>
<span class="line" id="L1374">        <span class="tok-kw">if</span> (num_digits_whole &gt; <span class="tok-number">0</span>) {</span>
<span class="line" id="L1375">            <span class="tok-comment">// We may have to zero pad, for instance 1e4 requires zero padding.</span>
</span>
<span class="line" id="L1376">            <span class="tok-kw">try</span> writer.writeAll(float_decimal.digits[<span class="tok-number">0</span>..num_digits_whole_no_pad]);</span>
<span class="line" id="L1377"></span>
<span class="line" id="L1378">            <span class="tok-kw">var</span> i = num_digits_whole_no_pad;</span>
<span class="line" id="L1379">            <span class="tok-kw">while</span> (i &lt; num_digits_whole) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L1380">                <span class="tok-kw">try</span> writer.writeAll(<span class="tok-str">&quot;0&quot;</span>);</span>
<span class="line" id="L1381">            }</span>
<span class="line" id="L1382">        } <span class="tok-kw">else</span> {</span>
<span class="line" id="L1383">            <span class="tok-kw">try</span> writer.writeAll(<span class="tok-str">&quot;0&quot;</span>);</span>
<span class="line" id="L1384">        }</span>
<span class="line" id="L1385"></span>
<span class="line" id="L1386">        <span class="tok-comment">// Omit `.` if no fractional portion</span>
</span>
<span class="line" id="L1387">        <span class="tok-kw">if</span> (float_decimal.exp &gt;= <span class="tok-number">0</span> <span class="tok-kw">and</span> num_digits_whole_no_pad == float_decimal.digits.len) {</span>
<span class="line" id="L1388">            <span class="tok-kw">return</span>;</span>
<span class="line" id="L1389">        }</span>
<span class="line" id="L1390"></span>
<span class="line" id="L1391">        <span class="tok-kw">try</span> writer.writeAll(<span class="tok-str">&quot;.&quot;</span>);</span>
<span class="line" id="L1392"></span>
<span class="line" id="L1393">        <span class="tok-comment">// Zero-fill until we reach significant digits or run out of precision.</span>
</span>
<span class="line" id="L1394">        <span class="tok-kw">if</span> (float_decimal.exp &lt; <span class="tok-number">0</span>) {</span>
<span class="line" id="L1395">            <span class="tok-kw">const</span> zero_digit_count = <span class="tok-builtin">@intCast</span>(<span class="tok-type">usize</span>, -float_decimal.exp);</span>
<span class="line" id="L1396"></span>
<span class="line" id="L1397">            <span class="tok-kw">var</span> i: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L1398">            <span class="tok-kw">while</span> (i &lt; zero_digit_count) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L1399">                <span class="tok-kw">try</span> writer.writeAll(<span class="tok-str">&quot;0&quot;</span>);</span>
<span class="line" id="L1400">            }</span>
<span class="line" id="L1401">        }</span>
<span class="line" id="L1402"></span>
<span class="line" id="L1403">        <span class="tok-kw">try</span> writer.writeAll(float_decimal.digits[num_digits_whole_no_pad..]);</span>
<span class="line" id="L1404">    }</span>
<span class="line" id="L1405">}</span>
<span class="line" id="L1406"></span>
<span class="line" id="L1407"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">formatInt</span>(</span>
<span class="line" id="L1408">    value: <span class="tok-kw">anytype</span>,</span>
<span class="line" id="L1409">    base: <span class="tok-type">u8</span>,</span>
<span class="line" id="L1410">    case: Case,</span>
<span class="line" id="L1411">    options: FormatOptions,</span>
<span class="line" id="L1412">    writer: <span class="tok-kw">anytype</span>,</span>
<span class="line" id="L1413">) !<span class="tok-type">void</span> {</span>
<span class="line" id="L1414">    assert(base &gt;= <span class="tok-number">2</span>);</span>
<span class="line" id="L1415"></span>
<span class="line" id="L1416">    <span class="tok-kw">const</span> int_value = <span class="tok-kw">if</span> (<span class="tok-builtin">@TypeOf</span>(value) == <span class="tok-type">comptime_int</span>) blk: {</span>
<span class="line" id="L1417">        <span class="tok-kw">const</span> Int = math.IntFittingRange(value, value);</span>
<span class="line" id="L1418">        <span class="tok-kw">break</span> :blk <span class="tok-builtin">@as</span>(Int, value);</span>
<span class="line" id="L1419">    } <span class="tok-kw">else</span> value;</span>
<span class="line" id="L1420"></span>
<span class="line" id="L1421">    <span class="tok-kw">const</span> value_info = <span class="tok-builtin">@typeInfo</span>(<span class="tok-builtin">@TypeOf</span>(int_value)).Int;</span>
<span class="line" id="L1422"></span>
<span class="line" id="L1423">    <span class="tok-comment">// The type must have the same size as `base` or be wider in order for the</span>
</span>
<span class="line" id="L1424">    <span class="tok-comment">// division to work</span>
</span>
<span class="line" id="L1425">    <span class="tok-kw">const</span> min_int_bits = <span class="tok-kw">comptime</span> math.max(value_info.bits, <span class="tok-number">8</span>);</span>
<span class="line" id="L1426">    <span class="tok-kw">const</span> MinInt = std.meta.Int(.unsigned, min_int_bits);</span>
<span class="line" id="L1427"></span>
<span class="line" id="L1428">    <span class="tok-kw">const</span> abs_value = math.absCast(int_value);</span>
<span class="line" id="L1429">    <span class="tok-comment">// The worst case in terms of space needed is base 2, plus 1 for the sign</span>
</span>
<span class="line" id="L1430">    <span class="tok-kw">var</span> buf: [<span class="tok-number">1</span> + math.max(value_info.bits, <span class="tok-number">1</span>)]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L1431"></span>
<span class="line" id="L1432">    <span class="tok-kw">var</span> a: MinInt = abs_value;</span>
<span class="line" id="L1433">    <span class="tok-kw">var</span> index: <span class="tok-type">usize</span> = buf.len;</span>
<span class="line" id="L1434">    <span class="tok-kw">while</span> (<span class="tok-null">true</span>) {</span>
<span class="line" id="L1435">        <span class="tok-kw">const</span> digit = a % base;</span>
<span class="line" id="L1436">        index -= <span class="tok-number">1</span>;</span>
<span class="line" id="L1437">        buf[index] = digitToChar(<span class="tok-builtin">@intCast</span>(<span class="tok-type">u8</span>, digit), case);</span>
<span class="line" id="L1438">        a /= base;</span>
<span class="line" id="L1439">        <span class="tok-kw">if</span> (a == <span class="tok-number">0</span>) <span class="tok-kw">break</span>;</span>
<span class="line" id="L1440">    }</span>
<span class="line" id="L1441"></span>
<span class="line" id="L1442">    <span class="tok-kw">if</span> (value_info.signedness == .signed) {</span>
<span class="line" id="L1443">        <span class="tok-kw">if</span> (value &lt; <span class="tok-number">0</span>) {</span>
<span class="line" id="L1444">            <span class="tok-comment">// Negative integer</span>
</span>
<span class="line" id="L1445">            index -= <span class="tok-number">1</span>;</span>
<span class="line" id="L1446">            buf[index] = <span class="tok-str">'-'</span>;</span>
<span class="line" id="L1447">        } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (options.width == <span class="tok-null">null</span> <span class="tok-kw">or</span> options.width.? == <span class="tok-number">0</span>) {</span>
<span class="line" id="L1448">            <span class="tok-comment">// Positive integer, omit the plus sign</span>
</span>
<span class="line" id="L1449">        } <span class="tok-kw">else</span> {</span>
<span class="line" id="L1450">            <span class="tok-comment">// Positive integer</span>
</span>
<span class="line" id="L1451">            index -= <span class="tok-number">1</span>;</span>
<span class="line" id="L1452">            buf[index] = <span class="tok-str">'+'</span>;</span>
<span class="line" id="L1453">        }</span>
<span class="line" id="L1454">    }</span>
<span class="line" id="L1455"></span>
<span class="line" id="L1456">    <span class="tok-kw">return</span> formatBuf(buf[index..], options, writer);</span>
<span class="line" id="L1457">}</span>
<span class="line" id="L1458"></span>
<span class="line" id="L1459"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">formatIntBuf</span>(out_buf: []<span class="tok-type">u8</span>, value: <span class="tok-kw">anytype</span>, base: <span class="tok-type">u8</span>, case: Case, options: FormatOptions) <span class="tok-type">usize</span> {</span>
<span class="line" id="L1460">    <span class="tok-kw">var</span> fbs = std.io.fixedBufferStream(out_buf);</span>
<span class="line" id="L1461">    formatInt(value, base, case, options, fbs.writer()) <span class="tok-kw">catch</span> <span class="tok-kw">unreachable</span>;</span>
<span class="line" id="L1462">    <span class="tok-kw">return</span> fbs.pos;</span>
<span class="line" id="L1463">}</span>
<span class="line" id="L1464"></span>
<span class="line" id="L1465"><span class="tok-kw">const</span> FormatDurationData = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L1466">    ns: <span class="tok-type">u64</span>,</span>
<span class="line" id="L1467">    negative: <span class="tok-type">bool</span> = <span class="tok-null">false</span>,</span>
<span class="line" id="L1468">};</span>
<span class="line" id="L1469"></span>
<span class="line" id="L1470"><span class="tok-kw">fn</span> <span class="tok-fn">formatDuration</span>(data: FormatDurationData, <span class="tok-kw">comptime</span> fmt: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, options: std.fmt.FormatOptions, writer: <span class="tok-kw">anytype</span>) !<span class="tok-type">void</span> {</span>
<span class="line" id="L1471">    _ = fmt;</span>
<span class="line" id="L1472"></span>
<span class="line" id="L1473">    <span class="tok-comment">// worst case: &quot;-XXXyXXwXXdXXhXXmXX.XXXs&quot;.len = 24</span>
</span>
<span class="line" id="L1474">    <span class="tok-kw">var</span> buf: [<span class="tok-number">24</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L1475">    <span class="tok-kw">var</span> fbs = std.io.fixedBufferStream(&amp;buf);</span>
<span class="line" id="L1476">    <span class="tok-kw">var</span> buf_writer = fbs.writer();</span>
<span class="line" id="L1477">    <span class="tok-kw">if</span> (data.negative) {</span>
<span class="line" id="L1478">        <span class="tok-kw">try</span> buf_writer.writeByte(<span class="tok-str">'-'</span>);</span>
<span class="line" id="L1479">    }</span>
<span class="line" id="L1480"></span>
<span class="line" id="L1481">    <span class="tok-kw">var</span> ns_remaining = data.ns;</span>
<span class="line" id="L1482">    <span class="tok-kw">inline</span> <span class="tok-kw">for</span> (.{</span>
<span class="line" id="L1483">        .{ .ns = <span class="tok-number">365</span> * std.time.ns_per_day, .sep = <span class="tok-str">'y'</span> },</span>
<span class="line" id="L1484">        .{ .ns = std.time.ns_per_week, .sep = <span class="tok-str">'w'</span> },</span>
<span class="line" id="L1485">        .{ .ns = std.time.ns_per_day, .sep = <span class="tok-str">'d'</span> },</span>
<span class="line" id="L1486">        .{ .ns = std.time.ns_per_hour, .sep = <span class="tok-str">'h'</span> },</span>
<span class="line" id="L1487">        .{ .ns = std.time.ns_per_min, .sep = <span class="tok-str">'m'</span> },</span>
<span class="line" id="L1488">    }) |unit| {</span>
<span class="line" id="L1489">        <span class="tok-kw">if</span> (ns_remaining &gt;= unit.ns) {</span>
<span class="line" id="L1490">            <span class="tok-kw">const</span> units = ns_remaining / unit.ns;</span>
<span class="line" id="L1491">            <span class="tok-kw">try</span> formatInt(units, <span class="tok-number">10</span>, .lower, .{}, buf_writer);</span>
<span class="line" id="L1492">            <span class="tok-kw">try</span> buf_writer.writeByte(unit.sep);</span>
<span class="line" id="L1493">            ns_remaining -= units * unit.ns;</span>
<span class="line" id="L1494">            <span class="tok-kw">if</span> (ns_remaining == <span class="tok-number">0</span>)</span>
<span class="line" id="L1495">                <span class="tok-kw">return</span> formatBuf(fbs.getWritten(), options, writer);</span>
<span class="line" id="L1496">        }</span>
<span class="line" id="L1497">    }</span>
<span class="line" id="L1498"></span>
<span class="line" id="L1499">    <span class="tok-kw">inline</span> <span class="tok-kw">for</span> (.{</span>
<span class="line" id="L1500">        .{ .ns = std.time.ns_per_s, .sep = <span class="tok-str">&quot;s&quot;</span> },</span>
<span class="line" id="L1501">        .{ .ns = std.time.ns_per_ms, .sep = <span class="tok-str">&quot;ms&quot;</span> },</span>
<span class="line" id="L1502">        .{ .ns = std.time.ns_per_us, .sep = <span class="tok-str">&quot;us&quot;</span> },</span>
<span class="line" id="L1503">    }) |unit| {</span>
<span class="line" id="L1504">        <span class="tok-kw">const</span> kunits = ns_remaining * <span class="tok-number">1000</span> / unit.ns;</span>
<span class="line" id="L1505">        <span class="tok-kw">if</span> (kunits &gt;= <span class="tok-number">1000</span>) {</span>
<span class="line" id="L1506">            <span class="tok-kw">try</span> formatInt(kunits / <span class="tok-number">1000</span>, <span class="tok-number">10</span>, .lower, .{}, buf_writer);</span>
<span class="line" id="L1507">            <span class="tok-kw">const</span> frac = kunits % <span class="tok-number">1000</span>;</span>
<span class="line" id="L1508">            <span class="tok-kw">if</span> (frac &gt; <span class="tok-number">0</span>) {</span>
<span class="line" id="L1509">                <span class="tok-comment">// Write up to 3 decimal places</span>
</span>
<span class="line" id="L1510">                <span class="tok-kw">var</span> decimal_buf = [_]<span class="tok-type">u8</span>{ <span class="tok-str">'.'</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span> };</span>
<span class="line" id="L1511">                _ = formatIntBuf(decimal_buf[<span class="tok-number">1</span>..], frac, <span class="tok-number">10</span>, .lower, .{ .fill = <span class="tok-str">'0'</span>, .width = <span class="tok-number">3</span> });</span>
<span class="line" id="L1512">                <span class="tok-kw">var</span> end: <span class="tok-type">usize</span> = <span class="tok-number">4</span>;</span>
<span class="line" id="L1513">                <span class="tok-kw">while</span> (end &gt; <span class="tok-number">1</span>) : (end -= <span class="tok-number">1</span>) {</span>
<span class="line" id="L1514">                    <span class="tok-kw">if</span> (decimal_buf[end - <span class="tok-number">1</span>] != <span class="tok-str">'0'</span>) <span class="tok-kw">break</span>;</span>
<span class="line" id="L1515">                }</span>
<span class="line" id="L1516">                <span class="tok-kw">try</span> buf_writer.writeAll(decimal_buf[<span class="tok-number">0</span>..end]);</span>
<span class="line" id="L1517">            }</span>
<span class="line" id="L1518">            <span class="tok-kw">try</span> buf_writer.writeAll(unit.sep);</span>
<span class="line" id="L1519">            <span class="tok-kw">return</span> formatBuf(fbs.getWritten(), options, writer);</span>
<span class="line" id="L1520">        }</span>
<span class="line" id="L1521">    }</span>
<span class="line" id="L1522"></span>
<span class="line" id="L1523">    <span class="tok-kw">try</span> formatInt(ns_remaining, <span class="tok-number">10</span>, .lower, .{}, buf_writer);</span>
<span class="line" id="L1524">    <span class="tok-kw">try</span> buf_writer.writeAll(<span class="tok-str">&quot;ns&quot;</span>);</span>
<span class="line" id="L1525">    <span class="tok-kw">return</span> formatBuf(fbs.getWritten(), options, writer);</span>
<span class="line" id="L1526">}</span>
<span class="line" id="L1527"></span>
<span class="line" id="L1528"><span class="tok-comment">/// Return a Formatter for number of nanoseconds according to its magnitude:</span></span>
<span class="line" id="L1529"><span class="tok-comment">/// [#y][#w][#d][#h][#m]#[.###][n|u|m]s</span></span>
<span class="line" id="L1530"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">fmtDuration</span>(ns: <span class="tok-type">u64</span>) Formatter(formatDuration) {</span>
<span class="line" id="L1531">    <span class="tok-kw">const</span> data = FormatDurationData{ .ns = ns };</span>
<span class="line" id="L1532">    <span class="tok-kw">return</span> .{ .data = data };</span>
<span class="line" id="L1533">}</span>
<span class="line" id="L1534"></span>
<span class="line" id="L1535"><span class="tok-kw">test</span> <span class="tok-str">&quot;fmtDuration&quot;</span> {</span>
<span class="line" id="L1536">    <span class="tok-kw">var</span> buf: [<span class="tok-number">24</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L1537">    <span class="tok-kw">inline</span> <span class="tok-kw">for</span> (.{</span>
<span class="line" id="L1538">        .{ .s = <span class="tok-str">&quot;0ns&quot;</span>, .d = <span class="tok-number">0</span> },</span>
<span class="line" id="L1539">        .{ .s = <span class="tok-str">&quot;1ns&quot;</span>, .d = <span class="tok-number">1</span> },</span>
<span class="line" id="L1540">        .{ .s = <span class="tok-str">&quot;999ns&quot;</span>, .d = std.time.ns_per_us - <span class="tok-number">1</span> },</span>
<span class="line" id="L1541">        .{ .s = <span class="tok-str">&quot;1us&quot;</span>, .d = std.time.ns_per_us },</span>
<span class="line" id="L1542">        .{ .s = <span class="tok-str">&quot;1.45us&quot;</span>, .d = <span class="tok-number">1450</span> },</span>
<span class="line" id="L1543">        .{ .s = <span class="tok-str">&quot;1.5us&quot;</span>, .d = <span class="tok-number">3</span> * std.time.ns_per_us / <span class="tok-number">2</span> },</span>
<span class="line" id="L1544">        .{ .s = <span class="tok-str">&quot;14.5us&quot;</span>, .d = <span class="tok-number">14500</span> },</span>
<span class="line" id="L1545">        .{ .s = <span class="tok-str">&quot;145us&quot;</span>, .d = <span class="tok-number">145000</span> },</span>
<span class="line" id="L1546">        .{ .s = <span class="tok-str">&quot;999.999us&quot;</span>, .d = std.time.ns_per_ms - <span class="tok-number">1</span> },</span>
<span class="line" id="L1547">        .{ .s = <span class="tok-str">&quot;1ms&quot;</span>, .d = std.time.ns_per_ms + <span class="tok-number">1</span> },</span>
<span class="line" id="L1548">        .{ .s = <span class="tok-str">&quot;1.5ms&quot;</span>, .d = <span class="tok-number">3</span> * std.time.ns_per_ms / <span class="tok-number">2</span> },</span>
<span class="line" id="L1549">        .{ .s = <span class="tok-str">&quot;1.11ms&quot;</span>, .d = <span class="tok-number">1110000</span> },</span>
<span class="line" id="L1550">        .{ .s = <span class="tok-str">&quot;1.111ms&quot;</span>, .d = <span class="tok-number">1111000</span> },</span>
<span class="line" id="L1551">        .{ .s = <span class="tok-str">&quot;1.111ms&quot;</span>, .d = <span class="tok-number">1111100</span> },</span>
<span class="line" id="L1552">        .{ .s = <span class="tok-str">&quot;999.999ms&quot;</span>, .d = std.time.ns_per_s - <span class="tok-number">1</span> },</span>
<span class="line" id="L1553">        .{ .s = <span class="tok-str">&quot;1s&quot;</span>, .d = std.time.ns_per_s },</span>
<span class="line" id="L1554">        .{ .s = <span class="tok-str">&quot;59.999s&quot;</span>, .d = std.time.ns_per_min - <span class="tok-number">1</span> },</span>
<span class="line" id="L1555">        .{ .s = <span class="tok-str">&quot;1m&quot;</span>, .d = std.time.ns_per_min },</span>
<span class="line" id="L1556">        .{ .s = <span class="tok-str">&quot;1h&quot;</span>, .d = std.time.ns_per_hour },</span>
<span class="line" id="L1557">        .{ .s = <span class="tok-str">&quot;1d&quot;</span>, .d = std.time.ns_per_day },</span>
<span class="line" id="L1558">        .{ .s = <span class="tok-str">&quot;1w&quot;</span>, .d = std.time.ns_per_week },</span>
<span class="line" id="L1559">        .{ .s = <span class="tok-str">&quot;1y&quot;</span>, .d = <span class="tok-number">365</span> * std.time.ns_per_day },</span>
<span class="line" id="L1560">        .{ .s = <span class="tok-str">&quot;1y52w23h59m59.999s&quot;</span>, .d = <span class="tok-number">730</span> * std.time.ns_per_day - <span class="tok-number">1</span> }, <span class="tok-comment">// 365d = 52w1d</span>
</span>
<span class="line" id="L1561">        .{ .s = <span class="tok-str">&quot;1y1h1.001s&quot;</span>, .d = <span class="tok-number">365</span> * std.time.ns_per_day + std.time.ns_per_hour + std.time.ns_per_s + std.time.ns_per_ms },</span>
<span class="line" id="L1562">        .{ .s = <span class="tok-str">&quot;1y1h1s&quot;</span>, .d = <span class="tok-number">365</span> * std.time.ns_per_day + std.time.ns_per_hour + std.time.ns_per_s + <span class="tok-number">999</span> * std.time.ns_per_us },</span>
<span class="line" id="L1563">        .{ .s = <span class="tok-str">&quot;1y1h999.999us&quot;</span>, .d = <span class="tok-number">365</span> * std.time.ns_per_day + std.time.ns_per_hour + std.time.ns_per_ms - <span class="tok-number">1</span> },</span>
<span class="line" id="L1564">        .{ .s = <span class="tok-str">&quot;1y1h1ms&quot;</span>, .d = <span class="tok-number">365</span> * std.time.ns_per_day + std.time.ns_per_hour + std.time.ns_per_ms },</span>
<span class="line" id="L1565">        .{ .s = <span class="tok-str">&quot;1y1h1ms&quot;</span>, .d = <span class="tok-number">365</span> * std.time.ns_per_day + std.time.ns_per_hour + std.time.ns_per_ms + <span class="tok-number">1</span> },</span>
<span class="line" id="L1566">        .{ .s = <span class="tok-str">&quot;1y1m999ns&quot;</span>, .d = <span class="tok-number">365</span> * std.time.ns_per_day + std.time.ns_per_min + <span class="tok-number">999</span> },</span>
<span class="line" id="L1567">        .{ .s = <span class="tok-str">&quot;584y49w23h34m33.709s&quot;</span>, .d = math.maxInt(<span class="tok-type">u64</span>) },</span>
<span class="line" id="L1568">    }) |tc| {</span>
<span class="line" id="L1569">        <span class="tok-kw">const</span> slice = <span class="tok-kw">try</span> bufPrint(&amp;buf, <span class="tok-str">&quot;{}&quot;</span>, .{fmtDuration(tc.d)});</span>
<span class="line" id="L1570">        <span class="tok-kw">try</span> std.testing.expectEqualStrings(tc.s, slice);</span>
<span class="line" id="L1571">    }</span>
<span class="line" id="L1572"></span>
<span class="line" id="L1573">    <span class="tok-kw">inline</span> <span class="tok-kw">for</span> (.{</span>
<span class="line" id="L1574">        .{ .s = <span class="tok-str">&quot;=======0ns&quot;</span>, .f = <span class="tok-str">&quot;{s:=&gt;10}&quot;</span>, .d = <span class="tok-number">0</span> },</span>
<span class="line" id="L1575">        .{ .s = <span class="tok-str">&quot;1ns=======&quot;</span>, .f = <span class="tok-str">&quot;{s:=&lt;10}&quot;</span>, .d = <span class="tok-number">1</span> },</span>
<span class="line" id="L1576">        .{ .s = <span class="tok-str">&quot;  999ns   &quot;</span>, .f = <span class="tok-str">&quot;{s:^10}&quot;</span>, .d = std.time.ns_per_us - <span class="tok-number">1</span> },</span>
<span class="line" id="L1577">    }) |tc| {</span>
<span class="line" id="L1578">        <span class="tok-kw">const</span> slice = <span class="tok-kw">try</span> bufPrint(&amp;buf, tc.f, .{fmtDuration(tc.d)});</span>
<span class="line" id="L1579">        <span class="tok-kw">try</span> std.testing.expectEqualStrings(tc.s, slice);</span>
<span class="line" id="L1580">    }</span>
<span class="line" id="L1581">}</span>
<span class="line" id="L1582"></span>
<span class="line" id="L1583"><span class="tok-kw">fn</span> <span class="tok-fn">formatDurationSigned</span>(ns: <span class="tok-type">i64</span>, <span class="tok-kw">comptime</span> fmt: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, options: std.fmt.FormatOptions, writer: <span class="tok-kw">anytype</span>) !<span class="tok-type">void</span> {</span>
<span class="line" id="L1584">    <span class="tok-kw">if</span> (ns &lt; <span class="tok-number">0</span>) {</span>
<span class="line" id="L1585">        <span class="tok-kw">const</span> data = FormatDurationData{ .ns = <span class="tok-builtin">@intCast</span>(<span class="tok-type">u64</span>, -ns), .negative = <span class="tok-null">true</span> };</span>
<span class="line" id="L1586">        <span class="tok-kw">try</span> formatDuration(data, fmt, options, writer);</span>
<span class="line" id="L1587">    } <span class="tok-kw">else</span> {</span>
<span class="line" id="L1588">        <span class="tok-kw">const</span> data = FormatDurationData{ .ns = <span class="tok-builtin">@intCast</span>(<span class="tok-type">u64</span>, ns) };</span>
<span class="line" id="L1589">        <span class="tok-kw">try</span> formatDuration(data, fmt, options, writer);</span>
<span class="line" id="L1590">    }</span>
<span class="line" id="L1591">}</span>
<span class="line" id="L1592"></span>
<span class="line" id="L1593"><span class="tok-comment">/// Return a Formatter for number of nanoseconds according to its signed magnitude:</span></span>
<span class="line" id="L1594"><span class="tok-comment">/// [#y][#w][#d][#h][#m]#[.###][n|u|m]s</span></span>
<span class="line" id="L1595"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">fmtDurationSigned</span>(ns: <span class="tok-type">i64</span>) Formatter(formatDurationSigned) {</span>
<span class="line" id="L1596">    <span class="tok-kw">return</span> .{ .data = ns };</span>
<span class="line" id="L1597">}</span>
<span class="line" id="L1598"></span>
<span class="line" id="L1599"><span class="tok-kw">test</span> <span class="tok-str">&quot;fmtDurationSigned&quot;</span> {</span>
<span class="line" id="L1600">    <span class="tok-kw">var</span> buf: [<span class="tok-number">24</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L1601">    <span class="tok-kw">inline</span> <span class="tok-kw">for</span> (.{</span>
<span class="line" id="L1602">        .{ .s = <span class="tok-str">&quot;0ns&quot;</span>, .d = <span class="tok-number">0</span> },</span>
<span class="line" id="L1603">        .{ .s = <span class="tok-str">&quot;1ns&quot;</span>, .d = <span class="tok-number">1</span> },</span>
<span class="line" id="L1604">        .{ .s = <span class="tok-str">&quot;-1ns&quot;</span>, .d = -(<span class="tok-number">1</span>) },</span>
<span class="line" id="L1605">        .{ .s = <span class="tok-str">&quot;999ns&quot;</span>, .d = std.time.ns_per_us - <span class="tok-number">1</span> },</span>
<span class="line" id="L1606">        .{ .s = <span class="tok-str">&quot;-999ns&quot;</span>, .d = -(std.time.ns_per_us - <span class="tok-number">1</span>) },</span>
<span class="line" id="L1607">        .{ .s = <span class="tok-str">&quot;1us&quot;</span>, .d = std.time.ns_per_us },</span>
<span class="line" id="L1608">        .{ .s = <span class="tok-str">&quot;-1us&quot;</span>, .d = -(std.time.ns_per_us) },</span>
<span class="line" id="L1609">        .{ .s = <span class="tok-str">&quot;1.45us&quot;</span>, .d = <span class="tok-number">1450</span> },</span>
<span class="line" id="L1610">        .{ .s = <span class="tok-str">&quot;-1.45us&quot;</span>, .d = -(<span class="tok-number">1450</span>) },</span>
<span class="line" id="L1611">        .{ .s = <span class="tok-str">&quot;1.5us&quot;</span>, .d = <span class="tok-number">3</span> * std.time.ns_per_us / <span class="tok-number">2</span> },</span>
<span class="line" id="L1612">        .{ .s = <span class="tok-str">&quot;-1.5us&quot;</span>, .d = -(<span class="tok-number">3</span> * std.time.ns_per_us / <span class="tok-number">2</span>) },</span>
<span class="line" id="L1613">        .{ .s = <span class="tok-str">&quot;14.5us&quot;</span>, .d = <span class="tok-number">14500</span> },</span>
<span class="line" id="L1614">        .{ .s = <span class="tok-str">&quot;-14.5us&quot;</span>, .d = -(<span class="tok-number">14500</span>) },</span>
<span class="line" id="L1615">        .{ .s = <span class="tok-str">&quot;145us&quot;</span>, .d = <span class="tok-number">145000</span> },</span>
<span class="line" id="L1616">        .{ .s = <span class="tok-str">&quot;-145us&quot;</span>, .d = -(<span class="tok-number">145000</span>) },</span>
<span class="line" id="L1617">        .{ .s = <span class="tok-str">&quot;999.999us&quot;</span>, .d = std.time.ns_per_ms - <span class="tok-number">1</span> },</span>
<span class="line" id="L1618">        .{ .s = <span class="tok-str">&quot;-999.999us&quot;</span>, .d = -(std.time.ns_per_ms - <span class="tok-number">1</span>) },</span>
<span class="line" id="L1619">        .{ .s = <span class="tok-str">&quot;1ms&quot;</span>, .d = std.time.ns_per_ms + <span class="tok-number">1</span> },</span>
<span class="line" id="L1620">        .{ .s = <span class="tok-str">&quot;-1ms&quot;</span>, .d = -(std.time.ns_per_ms + <span class="tok-number">1</span>) },</span>
<span class="line" id="L1621">        .{ .s = <span class="tok-str">&quot;1.5ms&quot;</span>, .d = <span class="tok-number">3</span> * std.time.ns_per_ms / <span class="tok-number">2</span> },</span>
<span class="line" id="L1622">        .{ .s = <span class="tok-str">&quot;-1.5ms&quot;</span>, .d = -(<span class="tok-number">3</span> * std.time.ns_per_ms / <span class="tok-number">2</span>) },</span>
<span class="line" id="L1623">        .{ .s = <span class="tok-str">&quot;1.11ms&quot;</span>, .d = <span class="tok-number">1110000</span> },</span>
<span class="line" id="L1624">        .{ .s = <span class="tok-str">&quot;-1.11ms&quot;</span>, .d = -(<span class="tok-number">1110000</span>) },</span>
<span class="line" id="L1625">        .{ .s = <span class="tok-str">&quot;1.111ms&quot;</span>, .d = <span class="tok-number">1111000</span> },</span>
<span class="line" id="L1626">        .{ .s = <span class="tok-str">&quot;-1.111ms&quot;</span>, .d = -(<span class="tok-number">1111000</span>) },</span>
<span class="line" id="L1627">        .{ .s = <span class="tok-str">&quot;1.111ms&quot;</span>, .d = <span class="tok-number">1111100</span> },</span>
<span class="line" id="L1628">        .{ .s = <span class="tok-str">&quot;-1.111ms&quot;</span>, .d = -(<span class="tok-number">1111100</span>) },</span>
<span class="line" id="L1629">        .{ .s = <span class="tok-str">&quot;999.999ms&quot;</span>, .d = std.time.ns_per_s - <span class="tok-number">1</span> },</span>
<span class="line" id="L1630">        .{ .s = <span class="tok-str">&quot;-999.999ms&quot;</span>, .d = -(std.time.ns_per_s - <span class="tok-number">1</span>) },</span>
<span class="line" id="L1631">        .{ .s = <span class="tok-str">&quot;1s&quot;</span>, .d = std.time.ns_per_s },</span>
<span class="line" id="L1632">        .{ .s = <span class="tok-str">&quot;-1s&quot;</span>, .d = -(std.time.ns_per_s) },</span>
<span class="line" id="L1633">        .{ .s = <span class="tok-str">&quot;59.999s&quot;</span>, .d = std.time.ns_per_min - <span class="tok-number">1</span> },</span>
<span class="line" id="L1634">        .{ .s = <span class="tok-str">&quot;-59.999s&quot;</span>, .d = -(std.time.ns_per_min - <span class="tok-number">1</span>) },</span>
<span class="line" id="L1635">        .{ .s = <span class="tok-str">&quot;1m&quot;</span>, .d = std.time.ns_per_min },</span>
<span class="line" id="L1636">        .{ .s = <span class="tok-str">&quot;-1m&quot;</span>, .d = -(std.time.ns_per_min) },</span>
<span class="line" id="L1637">        .{ .s = <span class="tok-str">&quot;1h&quot;</span>, .d = std.time.ns_per_hour },</span>
<span class="line" id="L1638">        .{ .s = <span class="tok-str">&quot;-1h&quot;</span>, .d = -(std.time.ns_per_hour) },</span>
<span class="line" id="L1639">        .{ .s = <span class="tok-str">&quot;1d&quot;</span>, .d = std.time.ns_per_day },</span>
<span class="line" id="L1640">        .{ .s = <span class="tok-str">&quot;-1d&quot;</span>, .d = -(std.time.ns_per_day) },</span>
<span class="line" id="L1641">        .{ .s = <span class="tok-str">&quot;1w&quot;</span>, .d = std.time.ns_per_week },</span>
<span class="line" id="L1642">        .{ .s = <span class="tok-str">&quot;-1w&quot;</span>, .d = -(std.time.ns_per_week) },</span>
<span class="line" id="L1643">        .{ .s = <span class="tok-str">&quot;1y&quot;</span>, .d = <span class="tok-number">365</span> * std.time.ns_per_day },</span>
<span class="line" id="L1644">        .{ .s = <span class="tok-str">&quot;-1y&quot;</span>, .d = -(<span class="tok-number">365</span> * std.time.ns_per_day) },</span>
<span class="line" id="L1645">        .{ .s = <span class="tok-str">&quot;1y52w23h59m59.999s&quot;</span>, .d = <span class="tok-number">730</span> * std.time.ns_per_day - <span class="tok-number">1</span> }, <span class="tok-comment">// 365d = 52w1d</span>
</span>
<span class="line" id="L1646">        .{ .s = <span class="tok-str">&quot;-1y52w23h59m59.999s&quot;</span>, .d = -(<span class="tok-number">730</span> * std.time.ns_per_day - <span class="tok-number">1</span>) }, <span class="tok-comment">// 365d = 52w1d</span>
</span>
<span class="line" id="L1647">        .{ .s = <span class="tok-str">&quot;1y1h1.001s&quot;</span>, .d = <span class="tok-number">365</span> * std.time.ns_per_day + std.time.ns_per_hour + std.time.ns_per_s + std.time.ns_per_ms },</span>
<span class="line" id="L1648">        .{ .s = <span class="tok-str">&quot;-1y1h1.001s&quot;</span>, .d = -(<span class="tok-number">365</span> * std.time.ns_per_day + std.time.ns_per_hour + std.time.ns_per_s + std.time.ns_per_ms) },</span>
<span class="line" id="L1649">        .{ .s = <span class="tok-str">&quot;1y1h1s&quot;</span>, .d = <span class="tok-number">365</span> * std.time.ns_per_day + std.time.ns_per_hour + std.time.ns_per_s + <span class="tok-number">999</span> * std.time.ns_per_us },</span>
<span class="line" id="L1650">        .{ .s = <span class="tok-str">&quot;-1y1h1s&quot;</span>, .d = -(<span class="tok-number">365</span> * std.time.ns_per_day + std.time.ns_per_hour + std.time.ns_per_s + <span class="tok-number">999</span> * std.time.ns_per_us) },</span>
<span class="line" id="L1651">        .{ .s = <span class="tok-str">&quot;1y1h999.999us&quot;</span>, .d = <span class="tok-number">365</span> * std.time.ns_per_day + std.time.ns_per_hour + std.time.ns_per_ms - <span class="tok-number">1</span> },</span>
<span class="line" id="L1652">        .{ .s = <span class="tok-str">&quot;-1y1h999.999us&quot;</span>, .d = -(<span class="tok-number">365</span> * std.time.ns_per_day + std.time.ns_per_hour + std.time.ns_per_ms - <span class="tok-number">1</span>) },</span>
<span class="line" id="L1653">        .{ .s = <span class="tok-str">&quot;1y1h1ms&quot;</span>, .d = <span class="tok-number">365</span> * std.time.ns_per_day + std.time.ns_per_hour + std.time.ns_per_ms },</span>
<span class="line" id="L1654">        .{ .s = <span class="tok-str">&quot;-1y1h1ms&quot;</span>, .d = -(<span class="tok-number">365</span> * std.time.ns_per_day + std.time.ns_per_hour + std.time.ns_per_ms) },</span>
<span class="line" id="L1655">        .{ .s = <span class="tok-str">&quot;1y1h1ms&quot;</span>, .d = <span class="tok-number">365</span> * std.time.ns_per_day + std.time.ns_per_hour + std.time.ns_per_ms + <span class="tok-number">1</span> },</span>
<span class="line" id="L1656">        .{ .s = <span class="tok-str">&quot;-1y1h1ms&quot;</span>, .d = -(<span class="tok-number">365</span> * std.time.ns_per_day + std.time.ns_per_hour + std.time.ns_per_ms + <span class="tok-number">1</span>) },</span>
<span class="line" id="L1657">        .{ .s = <span class="tok-str">&quot;1y1m999ns&quot;</span>, .d = <span class="tok-number">365</span> * std.time.ns_per_day + std.time.ns_per_min + <span class="tok-number">999</span> },</span>
<span class="line" id="L1658">        .{ .s = <span class="tok-str">&quot;-1y1m999ns&quot;</span>, .d = -(<span class="tok-number">365</span> * std.time.ns_per_day + std.time.ns_per_min + <span class="tok-number">999</span>) },</span>
<span class="line" id="L1659">        .{ .s = <span class="tok-str">&quot;292y24w3d23h47m16.854s&quot;</span>, .d = math.maxInt(<span class="tok-type">i64</span>) },</span>
<span class="line" id="L1660">        .{ .s = <span class="tok-str">&quot;-292y24w3d23h47m16.854s&quot;</span>, .d = math.minInt(<span class="tok-type">i64</span>) + <span class="tok-number">1</span> },</span>
<span class="line" id="L1661">    }) |tc| {</span>
<span class="line" id="L1662">        <span class="tok-kw">const</span> slice = <span class="tok-kw">try</span> bufPrint(&amp;buf, <span class="tok-str">&quot;{}&quot;</span>, .{fmtDurationSigned(tc.d)});</span>
<span class="line" id="L1663">        <span class="tok-kw">try</span> std.testing.expectEqualStrings(tc.s, slice);</span>
<span class="line" id="L1664">    }</span>
<span class="line" id="L1665"></span>
<span class="line" id="L1666">    <span class="tok-kw">inline</span> <span class="tok-kw">for</span> (.{</span>
<span class="line" id="L1667">        .{ .s = <span class="tok-str">&quot;=======0ns&quot;</span>, .f = <span class="tok-str">&quot;{s:=&gt;10}&quot;</span>, .d = <span class="tok-number">0</span> },</span>
<span class="line" id="L1668">        .{ .s = <span class="tok-str">&quot;1ns=======&quot;</span>, .f = <span class="tok-str">&quot;{s:=&lt;10}&quot;</span>, .d = <span class="tok-number">1</span> },</span>
<span class="line" id="L1669">        .{ .s = <span class="tok-str">&quot;-1ns======&quot;</span>, .f = <span class="tok-str">&quot;{s:=&lt;10}&quot;</span>, .d = -(<span class="tok-number">1</span>) },</span>
<span class="line" id="L1670">        .{ .s = <span class="tok-str">&quot;  -999ns  &quot;</span>, .f = <span class="tok-str">&quot;{s:^10}&quot;</span>, .d = -(std.time.ns_per_us - <span class="tok-number">1</span>) },</span>
<span class="line" id="L1671">    }) |tc| {</span>
<span class="line" id="L1672">        <span class="tok-kw">const</span> slice = <span class="tok-kw">try</span> bufPrint(&amp;buf, tc.f, .{fmtDurationSigned(tc.d)});</span>
<span class="line" id="L1673">        <span class="tok-kw">try</span> std.testing.expectEqualStrings(tc.s, slice);</span>
<span class="line" id="L1674">    }</span>
<span class="line" id="L1675">}</span>
<span class="line" id="L1676"></span>
<span class="line" id="L1677"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> ParseIntError = <span class="tok-kw">error</span>{</span>
<span class="line" id="L1678">    <span class="tok-comment">/// The result cannot fit in the type specified</span></span>
<span class="line" id="L1679">    Overflow,</span>
<span class="line" id="L1680"></span>
<span class="line" id="L1681">    <span class="tok-comment">/// The input was empty or had a byte that was not a digit</span></span>
<span class="line" id="L1682">    InvalidCharacter,</span>
<span class="line" id="L1683">};</span>
<span class="line" id="L1684"></span>
<span class="line" id="L1685"><span class="tok-comment">/// Creates a Formatter type from a format function. Wrapping data in Formatter(func) causes</span></span>
<span class="line" id="L1686"><span class="tok-comment">/// the data to be formatted using the given function `func`.  `func` must be of the following</span></span>
<span class="line" id="L1687"><span class="tok-comment">/// form:</span></span>
<span class="line" id="L1688"><span class="tok-comment">///</span></span>
<span class="line" id="L1689"><span class="tok-comment">///     fn formatExample(</span></span>
<span class="line" id="L1690"><span class="tok-comment">///         data: T,</span></span>
<span class="line" id="L1691"><span class="tok-comment">///         comptime fmt: []const u8,</span></span>
<span class="line" id="L1692"><span class="tok-comment">///         options: std.fmt.FormatOptions,</span></span>
<span class="line" id="L1693"><span class="tok-comment">///         writer: anytype,</span></span>
<span class="line" id="L1694"><span class="tok-comment">///     ) !void;</span></span>
<span class="line" id="L1695"><span class="tok-comment">///</span></span>
<span class="line" id="L1696"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">Formatter</span>(<span class="tok-kw">comptime</span> format_fn: <span class="tok-kw">anytype</span>) <span class="tok-type">type</span> {</span>
<span class="line" id="L1697">    <span class="tok-kw">const</span> Data = <span class="tok-builtin">@typeInfo</span>(<span class="tok-builtin">@TypeOf</span>(format_fn)).Fn.args[<span class="tok-number">0</span>].arg_type.?;</span>
<span class="line" id="L1698">    <span class="tok-kw">return</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L1699">        data: Data,</span>
<span class="line" id="L1700">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">format</span>(</span>
<span class="line" id="L1701">            self: <span class="tok-builtin">@This</span>(),</span>
<span class="line" id="L1702">            <span class="tok-kw">comptime</span> fmt: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L1703">            options: std.fmt.FormatOptions,</span>
<span class="line" id="L1704">            writer: <span class="tok-kw">anytype</span>,</span>
<span class="line" id="L1705">        ) <span class="tok-builtin">@TypeOf</span>(writer).Error!<span class="tok-type">void</span> {</span>
<span class="line" id="L1706">            <span class="tok-kw">try</span> format_fn(self.data, fmt, options, writer);</span>
<span class="line" id="L1707">        }</span>
<span class="line" id="L1708">    };</span>
<span class="line" id="L1709">}</span>
<span class="line" id="L1710"></span>
<span class="line" id="L1711"><span class="tok-comment">/// Parses the string `buf` as signed or unsigned representation in the</span></span>
<span class="line" id="L1712"><span class="tok-comment">/// specified radix of an integral value of type `T`.</span></span>
<span class="line" id="L1713"><span class="tok-comment">///</span></span>
<span class="line" id="L1714"><span class="tok-comment">/// When `radix` is zero the string prefix is examined to detect the true radix:</span></span>
<span class="line" id="L1715"><span class="tok-comment">///  * A prefix of &quot;0b&quot; implies radix=2,</span></span>
<span class="line" id="L1716"><span class="tok-comment">///  * A prefix of &quot;0o&quot; implies radix=8,</span></span>
<span class="line" id="L1717"><span class="tok-comment">///  * A prefix of &quot;0x&quot; implies radix=16,</span></span>
<span class="line" id="L1718"><span class="tok-comment">///  * Otherwise radix=10 is assumed.</span></span>
<span class="line" id="L1719"><span class="tok-comment">///</span></span>
<span class="line" id="L1720"><span class="tok-comment">/// Ignores '_' character in `buf`.</span></span>
<span class="line" id="L1721"><span class="tok-comment">/// See also `parseUnsigned`.</span></span>
<span class="line" id="L1722"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">parseInt</span>(<span class="tok-kw">comptime</span> T: <span class="tok-type">type</span>, buf: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, radix: <span class="tok-type">u8</span>) ParseIntError!T {</span>
<span class="line" id="L1723">    <span class="tok-kw">if</span> (buf.len == <span class="tok-number">0</span>) <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InvalidCharacter;</span>
<span class="line" id="L1724">    <span class="tok-kw">if</span> (buf[<span class="tok-number">0</span>] == <span class="tok-str">'+'</span>) <span class="tok-kw">return</span> parseWithSign(T, buf[<span class="tok-number">1</span>..], radix, .Pos);</span>
<span class="line" id="L1725">    <span class="tok-kw">if</span> (buf[<span class="tok-number">0</span>] == <span class="tok-str">'-'</span>) <span class="tok-kw">return</span> parseWithSign(T, buf[<span class="tok-number">1</span>..], radix, .Neg);</span>
<span class="line" id="L1726">    <span class="tok-kw">return</span> parseWithSign(T, buf, radix, .Pos);</span>
<span class="line" id="L1727">}</span>
<span class="line" id="L1728"></span>
<span class="line" id="L1729"><span class="tok-kw">test</span> <span class="tok-str">&quot;parseInt&quot;</span> {</span>
<span class="line" id="L1730">    <span class="tok-kw">try</span> std.testing.expect((<span class="tok-kw">try</span> parseInt(<span class="tok-type">i32</span>, <span class="tok-str">&quot;-10&quot;</span>, <span class="tok-number">10</span>)) == -<span class="tok-number">10</span>);</span>
<span class="line" id="L1731">    <span class="tok-kw">try</span> std.testing.expect((<span class="tok-kw">try</span> parseInt(<span class="tok-type">i32</span>, <span class="tok-str">&quot;+10&quot;</span>, <span class="tok-number">10</span>)) == <span class="tok-number">10</span>);</span>
<span class="line" id="L1732">    <span class="tok-kw">try</span> std.testing.expect((<span class="tok-kw">try</span> parseInt(<span class="tok-type">u32</span>, <span class="tok-str">&quot;+10&quot;</span>, <span class="tok-number">10</span>)) == <span class="tok-number">10</span>);</span>
<span class="line" id="L1733">    <span class="tok-kw">try</span> std.testing.expectError(<span class="tok-kw">error</span>.Overflow, parseInt(<span class="tok-type">u32</span>, <span class="tok-str">&quot;-10&quot;</span>, <span class="tok-number">10</span>));</span>
<span class="line" id="L1734">    <span class="tok-kw">try</span> std.testing.expectError(<span class="tok-kw">error</span>.InvalidCharacter, parseInt(<span class="tok-type">u32</span>, <span class="tok-str">&quot; 10&quot;</span>, <span class="tok-number">10</span>));</span>
<span class="line" id="L1735">    <span class="tok-kw">try</span> std.testing.expectError(<span class="tok-kw">error</span>.InvalidCharacter, parseInt(<span class="tok-type">u32</span>, <span class="tok-str">&quot;10 &quot;</span>, <span class="tok-number">10</span>));</span>
<span class="line" id="L1736">    <span class="tok-kw">try</span> std.testing.expectError(<span class="tok-kw">error</span>.InvalidCharacter, parseInt(<span class="tok-type">u32</span>, <span class="tok-str">&quot;_10_&quot;</span>, <span class="tok-number">10</span>));</span>
<span class="line" id="L1737">    <span class="tok-kw">try</span> std.testing.expectError(<span class="tok-kw">error</span>.InvalidCharacter, parseInt(<span class="tok-type">u32</span>, <span class="tok-str">&quot;0x_10_&quot;</span>, <span class="tok-number">10</span>));</span>
<span class="line" id="L1738">    <span class="tok-kw">try</span> std.testing.expectError(<span class="tok-kw">error</span>.InvalidCharacter, parseInt(<span class="tok-type">u32</span>, <span class="tok-str">&quot;0x10_&quot;</span>, <span class="tok-number">10</span>));</span>
<span class="line" id="L1739">    <span class="tok-kw">try</span> std.testing.expectError(<span class="tok-kw">error</span>.InvalidCharacter, parseInt(<span class="tok-type">u32</span>, <span class="tok-str">&quot;0x_10&quot;</span>, <span class="tok-number">10</span>));</span>
<span class="line" id="L1740">    <span class="tok-kw">try</span> std.testing.expect((<span class="tok-kw">try</span> parseInt(<span class="tok-type">u8</span>, <span class="tok-str">&quot;255&quot;</span>, <span class="tok-number">10</span>)) == <span class="tok-number">255</span>);</span>
<span class="line" id="L1741">    <span class="tok-kw">try</span> std.testing.expectError(<span class="tok-kw">error</span>.Overflow, parseInt(<span class="tok-type">u8</span>, <span class="tok-str">&quot;256&quot;</span>, <span class="tok-number">10</span>));</span>
<span class="line" id="L1742"></span>
<span class="line" id="L1743">    <span class="tok-comment">// +0 and -0 should work for unsigned</span>
</span>
<span class="line" id="L1744">    <span class="tok-kw">try</span> std.testing.expect((<span class="tok-kw">try</span> parseInt(<span class="tok-type">u8</span>, <span class="tok-str">&quot;-0&quot;</span>, <span class="tok-number">10</span>)) == <span class="tok-number">0</span>);</span>
<span class="line" id="L1745">    <span class="tok-kw">try</span> std.testing.expect((<span class="tok-kw">try</span> parseInt(<span class="tok-type">u8</span>, <span class="tok-str">&quot;+0&quot;</span>, <span class="tok-number">10</span>)) == <span class="tok-number">0</span>);</span>
<span class="line" id="L1746"></span>
<span class="line" id="L1747">    <span class="tok-comment">// ensure minInt is parsed correctly</span>
</span>
<span class="line" id="L1748">    <span class="tok-kw">try</span> std.testing.expect((<span class="tok-kw">try</span> parseInt(<span class="tok-type">i8</span>, <span class="tok-str">&quot;-128&quot;</span>, <span class="tok-number">10</span>)) == math.minInt(<span class="tok-type">i8</span>));</span>
<span class="line" id="L1749">    <span class="tok-kw">try</span> std.testing.expect((<span class="tok-kw">try</span> parseInt(<span class="tok-type">i43</span>, <span class="tok-str">&quot;-4398046511104&quot;</span>, <span class="tok-number">10</span>)) == math.minInt(<span class="tok-type">i43</span>));</span>
<span class="line" id="L1750"></span>
<span class="line" id="L1751">    <span class="tok-comment">// empty string or bare +- is invalid</span>
</span>
<span class="line" id="L1752">    <span class="tok-kw">try</span> std.testing.expectError(<span class="tok-kw">error</span>.InvalidCharacter, parseInt(<span class="tok-type">u32</span>, <span class="tok-str">&quot;&quot;</span>, <span class="tok-number">10</span>));</span>
<span class="line" id="L1753">    <span class="tok-kw">try</span> std.testing.expectError(<span class="tok-kw">error</span>.InvalidCharacter, parseInt(<span class="tok-type">i32</span>, <span class="tok-str">&quot;&quot;</span>, <span class="tok-number">10</span>));</span>
<span class="line" id="L1754">    <span class="tok-kw">try</span> std.testing.expectError(<span class="tok-kw">error</span>.InvalidCharacter, parseInt(<span class="tok-type">u32</span>, <span class="tok-str">&quot;+&quot;</span>, <span class="tok-number">10</span>));</span>
<span class="line" id="L1755">    <span class="tok-kw">try</span> std.testing.expectError(<span class="tok-kw">error</span>.InvalidCharacter, parseInt(<span class="tok-type">i32</span>, <span class="tok-str">&quot;+&quot;</span>, <span class="tok-number">10</span>));</span>
<span class="line" id="L1756">    <span class="tok-kw">try</span> std.testing.expectError(<span class="tok-kw">error</span>.InvalidCharacter, parseInt(<span class="tok-type">u32</span>, <span class="tok-str">&quot;-&quot;</span>, <span class="tok-number">10</span>));</span>
<span class="line" id="L1757">    <span class="tok-kw">try</span> std.testing.expectError(<span class="tok-kw">error</span>.InvalidCharacter, parseInt(<span class="tok-type">i32</span>, <span class="tok-str">&quot;-&quot;</span>, <span class="tok-number">10</span>));</span>
<span class="line" id="L1758"></span>
<span class="line" id="L1759">    <span class="tok-comment">// autodectect the radix</span>
</span>
<span class="line" id="L1760">    <span class="tok-kw">try</span> std.testing.expect((<span class="tok-kw">try</span> parseInt(<span class="tok-type">i32</span>, <span class="tok-str">&quot;111&quot;</span>, <span class="tok-number">0</span>)) == <span class="tok-number">111</span>);</span>
<span class="line" id="L1761">    <span class="tok-kw">try</span> std.testing.expect((<span class="tok-kw">try</span> parseInt(<span class="tok-type">i32</span>, <span class="tok-str">&quot;1_1_1&quot;</span>, <span class="tok-number">0</span>)) == <span class="tok-number">111</span>);</span>
<span class="line" id="L1762">    <span class="tok-kw">try</span> std.testing.expect((<span class="tok-kw">try</span> parseInt(<span class="tok-type">i32</span>, <span class="tok-str">&quot;1_1_1&quot;</span>, <span class="tok-number">0</span>)) == <span class="tok-number">111</span>);</span>
<span class="line" id="L1763">    <span class="tok-kw">try</span> std.testing.expect((<span class="tok-kw">try</span> parseInt(<span class="tok-type">i32</span>, <span class="tok-str">&quot;+0b111&quot;</span>, <span class="tok-number">0</span>)) == <span class="tok-number">7</span>);</span>
<span class="line" id="L1764">    <span class="tok-kw">try</span> std.testing.expect((<span class="tok-kw">try</span> parseInt(<span class="tok-type">i32</span>, <span class="tok-str">&quot;+0B111&quot;</span>, <span class="tok-number">0</span>)) == <span class="tok-number">7</span>);</span>
<span class="line" id="L1765">    <span class="tok-kw">try</span> std.testing.expect((<span class="tok-kw">try</span> parseInt(<span class="tok-type">i32</span>, <span class="tok-str">&quot;+0b1_11&quot;</span>, <span class="tok-number">0</span>)) == <span class="tok-number">7</span>);</span>
<span class="line" id="L1766">    <span class="tok-kw">try</span> std.testing.expect((<span class="tok-kw">try</span> parseInt(<span class="tok-type">i32</span>, <span class="tok-str">&quot;+0o111&quot;</span>, <span class="tok-number">0</span>)) == <span class="tok-number">73</span>);</span>
<span class="line" id="L1767">    <span class="tok-kw">try</span> std.testing.expect((<span class="tok-kw">try</span> parseInt(<span class="tok-type">i32</span>, <span class="tok-str">&quot;+0O111&quot;</span>, <span class="tok-number">0</span>)) == <span class="tok-number">73</span>);</span>
<span class="line" id="L1768">    <span class="tok-kw">try</span> std.testing.expect((<span class="tok-kw">try</span> parseInt(<span class="tok-type">i32</span>, <span class="tok-str">&quot;+0o11_1&quot;</span>, <span class="tok-number">0</span>)) == <span class="tok-number">73</span>);</span>
<span class="line" id="L1769">    <span class="tok-kw">try</span> std.testing.expect((<span class="tok-kw">try</span> parseInt(<span class="tok-type">i32</span>, <span class="tok-str">&quot;+0x111&quot;</span>, <span class="tok-number">0</span>)) == <span class="tok-number">273</span>);</span>
<span class="line" id="L1770">    <span class="tok-kw">try</span> std.testing.expect((<span class="tok-kw">try</span> parseInt(<span class="tok-type">i32</span>, <span class="tok-str">&quot;-0b111&quot;</span>, <span class="tok-number">0</span>)) == -<span class="tok-number">7</span>);</span>
<span class="line" id="L1771">    <span class="tok-kw">try</span> std.testing.expect((<span class="tok-kw">try</span> parseInt(<span class="tok-type">i32</span>, <span class="tok-str">&quot;-0b11_1&quot;</span>, <span class="tok-number">0</span>)) == -<span class="tok-number">7</span>);</span>
<span class="line" id="L1772">    <span class="tok-kw">try</span> std.testing.expect((<span class="tok-kw">try</span> parseInt(<span class="tok-type">i32</span>, <span class="tok-str">&quot;-0o111&quot;</span>, <span class="tok-number">0</span>)) == -<span class="tok-number">73</span>);</span>
<span class="line" id="L1773">    <span class="tok-kw">try</span> std.testing.expect((<span class="tok-kw">try</span> parseInt(<span class="tok-type">i32</span>, <span class="tok-str">&quot;-0x111&quot;</span>, <span class="tok-number">0</span>)) == -<span class="tok-number">273</span>);</span>
<span class="line" id="L1774">    <span class="tok-kw">try</span> std.testing.expect((<span class="tok-kw">try</span> parseInt(<span class="tok-type">i32</span>, <span class="tok-str">&quot;-0X111&quot;</span>, <span class="tok-number">0</span>)) == -<span class="tok-number">273</span>);</span>
<span class="line" id="L1775">    <span class="tok-kw">try</span> std.testing.expect((<span class="tok-kw">try</span> parseInt(<span class="tok-type">i32</span>, <span class="tok-str">&quot;-0x1_11&quot;</span>, <span class="tok-number">0</span>)) == -<span class="tok-number">273</span>);</span>
<span class="line" id="L1776"></span>
<span class="line" id="L1777">    <span class="tok-comment">// bare binary/octal/decimal prefix is invalid</span>
</span>
<span class="line" id="L1778">    <span class="tok-kw">try</span> std.testing.expectError(<span class="tok-kw">error</span>.InvalidCharacter, parseInt(<span class="tok-type">u32</span>, <span class="tok-str">&quot;0b&quot;</span>, <span class="tok-number">0</span>));</span>
<span class="line" id="L1779">    <span class="tok-kw">try</span> std.testing.expectError(<span class="tok-kw">error</span>.InvalidCharacter, parseInt(<span class="tok-type">u32</span>, <span class="tok-str">&quot;0o&quot;</span>, <span class="tok-number">0</span>));</span>
<span class="line" id="L1780">    <span class="tok-kw">try</span> std.testing.expectError(<span class="tok-kw">error</span>.InvalidCharacter, parseInt(<span class="tok-type">u32</span>, <span class="tok-str">&quot;0x&quot;</span>, <span class="tok-number">0</span>));</span>
<span class="line" id="L1781">}</span>
<span class="line" id="L1782"></span>
<span class="line" id="L1783"><span class="tok-kw">fn</span> <span class="tok-fn">parseWithSign</span>(</span>
<span class="line" id="L1784">    <span class="tok-kw">comptime</span> T: <span class="tok-type">type</span>,</span>
<span class="line" id="L1785">    buf: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L1786">    radix: <span class="tok-type">u8</span>,</span>
<span class="line" id="L1787">    <span class="tok-kw">comptime</span> sign: <span class="tok-kw">enum</span> { Pos, Neg },</span>
<span class="line" id="L1788">) ParseIntError!T {</span>
<span class="line" id="L1789">    <span class="tok-kw">if</span> (buf.len == <span class="tok-number">0</span>) <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InvalidCharacter;</span>
<span class="line" id="L1790"></span>
<span class="line" id="L1791">    <span class="tok-kw">var</span> buf_radix = radix;</span>
<span class="line" id="L1792">    <span class="tok-kw">var</span> buf_start = buf;</span>
<span class="line" id="L1793">    <span class="tok-kw">if</span> (radix == <span class="tok-number">0</span>) {</span>
<span class="line" id="L1794">        <span class="tok-comment">// Treat is as a decimal number by default.</span>
</span>
<span class="line" id="L1795">        buf_radix = <span class="tok-number">10</span>;</span>
<span class="line" id="L1796">        <span class="tok-comment">// Detect the radix by looking at buf prefix.</span>
</span>
<span class="line" id="L1797">        <span class="tok-kw">if</span> (buf.len &gt; <span class="tok-number">2</span> <span class="tok-kw">and</span> buf[<span class="tok-number">0</span>] == <span class="tok-str">'0'</span>) {</span>
<span class="line" id="L1798">            <span class="tok-kw">switch</span> (std.ascii.toLower(buf[<span class="tok-number">1</span>])) {</span>
<span class="line" id="L1799">                <span class="tok-str">'b'</span> =&gt; {</span>
<span class="line" id="L1800">                    buf_radix = <span class="tok-number">2</span>;</span>
<span class="line" id="L1801">                    buf_start = buf[<span class="tok-number">2</span>..];</span>
<span class="line" id="L1802">                },</span>
<span class="line" id="L1803">                <span class="tok-str">'o'</span> =&gt; {</span>
<span class="line" id="L1804">                    buf_radix = <span class="tok-number">8</span>;</span>
<span class="line" id="L1805">                    buf_start = buf[<span class="tok-number">2</span>..];</span>
<span class="line" id="L1806">                },</span>
<span class="line" id="L1807">                <span class="tok-str">'x'</span> =&gt; {</span>
<span class="line" id="L1808">                    buf_radix = <span class="tok-number">16</span>;</span>
<span class="line" id="L1809">                    buf_start = buf[<span class="tok-number">2</span>..];</span>
<span class="line" id="L1810">                },</span>
<span class="line" id="L1811">                <span class="tok-kw">else</span> =&gt; {},</span>
<span class="line" id="L1812">            }</span>
<span class="line" id="L1813">        }</span>
<span class="line" id="L1814">    }</span>
<span class="line" id="L1815"></span>
<span class="line" id="L1816">    <span class="tok-kw">const</span> add = <span class="tok-kw">switch</span> (sign) {</span>
<span class="line" id="L1817">        .Pos =&gt; math.add,</span>
<span class="line" id="L1818">        .Neg =&gt; math.sub,</span>
<span class="line" id="L1819">    };</span>
<span class="line" id="L1820"></span>
<span class="line" id="L1821">    <span class="tok-kw">var</span> x: T = <span class="tok-number">0</span>;</span>
<span class="line" id="L1822"></span>
<span class="line" id="L1823">    <span class="tok-kw">if</span> (buf_start[<span class="tok-number">0</span>] == <span class="tok-str">'_'</span> <span class="tok-kw">or</span> buf_start[buf_start.len - <span class="tok-number">1</span>] == <span class="tok-str">'_'</span>) <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InvalidCharacter;</span>
<span class="line" id="L1824"></span>
<span class="line" id="L1825">    <span class="tok-kw">for</span> (buf_start) |c| {</span>
<span class="line" id="L1826">        <span class="tok-kw">if</span> (c == <span class="tok-str">'_'</span>) <span class="tok-kw">continue</span>;</span>
<span class="line" id="L1827">        <span class="tok-kw">const</span> digit = <span class="tok-kw">try</span> charToDigit(c, buf_radix);</span>
<span class="line" id="L1828"></span>
<span class="line" id="L1829">        <span class="tok-kw">if</span> (x != <span class="tok-number">0</span>) x = <span class="tok-kw">try</span> math.mul(T, x, math.cast(T, buf_radix) <span class="tok-kw">orelse</span> <span class="tok-kw">return</span> <span class="tok-kw">error</span>.Overflow);</span>
<span class="line" id="L1830">        x = <span class="tok-kw">try</span> add(T, x, math.cast(T, digit) <span class="tok-kw">orelse</span> <span class="tok-kw">return</span> <span class="tok-kw">error</span>.Overflow);</span>
<span class="line" id="L1831">    }</span>
<span class="line" id="L1832"></span>
<span class="line" id="L1833">    <span class="tok-kw">return</span> x;</span>
<span class="line" id="L1834">}</span>
<span class="line" id="L1835"></span>
<span class="line" id="L1836"><span class="tok-comment">/// Parses the string `buf` as  unsigned representation in the specified radix</span></span>
<span class="line" id="L1837"><span class="tok-comment">/// of an integral value of type `T`.</span></span>
<span class="line" id="L1838"><span class="tok-comment">///</span></span>
<span class="line" id="L1839"><span class="tok-comment">/// When `radix` is zero the string prefix is examined to detect the true radix:</span></span>
<span class="line" id="L1840"><span class="tok-comment">///  * A prefix of &quot;0b&quot; implies radix=2,</span></span>
<span class="line" id="L1841"><span class="tok-comment">///  * A prefix of &quot;0o&quot; implies radix=8,</span></span>
<span class="line" id="L1842"><span class="tok-comment">///  * A prefix of &quot;0x&quot; implies radix=16,</span></span>
<span class="line" id="L1843"><span class="tok-comment">///  * Otherwise radix=10 is assumed.</span></span>
<span class="line" id="L1844"><span class="tok-comment">///</span></span>
<span class="line" id="L1845"><span class="tok-comment">/// Ignores '_' character in `buf`.</span></span>
<span class="line" id="L1846"><span class="tok-comment">/// See also `parseInt`.</span></span>
<span class="line" id="L1847"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">parseUnsigned</span>(<span class="tok-kw">comptime</span> T: <span class="tok-type">type</span>, buf: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, radix: <span class="tok-type">u8</span>) ParseIntError!T {</span>
<span class="line" id="L1848">    <span class="tok-kw">return</span> parseWithSign(T, buf, radix, .Pos);</span>
<span class="line" id="L1849">}</span>
<span class="line" id="L1850"></span>
<span class="line" id="L1851"><span class="tok-kw">test</span> <span class="tok-str">&quot;parseUnsigned&quot;</span> {</span>
<span class="line" id="L1852">    <span class="tok-kw">try</span> std.testing.expect((<span class="tok-kw">try</span> parseUnsigned(<span class="tok-type">u16</span>, <span class="tok-str">&quot;050124&quot;</span>, <span class="tok-number">10</span>)) == <span class="tok-number">50124</span>);</span>
<span class="line" id="L1853">    <span class="tok-kw">try</span> std.testing.expect((<span class="tok-kw">try</span> parseUnsigned(<span class="tok-type">u16</span>, <span class="tok-str">&quot;65535&quot;</span>, <span class="tok-number">10</span>)) == <span class="tok-number">65535</span>);</span>
<span class="line" id="L1854">    <span class="tok-kw">try</span> std.testing.expect((<span class="tok-kw">try</span> parseUnsigned(<span class="tok-type">u16</span>, <span class="tok-str">&quot;65_535&quot;</span>, <span class="tok-number">10</span>)) == <span class="tok-number">65535</span>);</span>
<span class="line" id="L1855">    <span class="tok-kw">try</span> std.testing.expectError(<span class="tok-kw">error</span>.Overflow, parseUnsigned(<span class="tok-type">u16</span>, <span class="tok-str">&quot;65536&quot;</span>, <span class="tok-number">10</span>));</span>
<span class="line" id="L1856"></span>
<span class="line" id="L1857">    <span class="tok-kw">try</span> std.testing.expect((<span class="tok-kw">try</span> parseUnsigned(<span class="tok-type">u64</span>, <span class="tok-str">&quot;0ffffffffffffffff&quot;</span>, <span class="tok-number">16</span>)) == <span class="tok-number">0xffffffffffffffff</span>);</span>
<span class="line" id="L1858">    <span class="tok-kw">try</span> std.testing.expect((<span class="tok-kw">try</span> parseUnsigned(<span class="tok-type">u64</span>, <span class="tok-str">&quot;0f_fff_fff_fff_fff_fff&quot;</span>, <span class="tok-number">16</span>)) == <span class="tok-number">0xffffffffffffffff</span>);</span>
<span class="line" id="L1859">    <span class="tok-kw">try</span> std.testing.expectError(<span class="tok-kw">error</span>.Overflow, parseUnsigned(<span class="tok-type">u64</span>, <span class="tok-str">&quot;10000000000000000&quot;</span>, <span class="tok-number">16</span>));</span>
<span class="line" id="L1860"></span>
<span class="line" id="L1861">    <span class="tok-kw">try</span> std.testing.expect((<span class="tok-kw">try</span> parseUnsigned(<span class="tok-type">u32</span>, <span class="tok-str">&quot;DeadBeef&quot;</span>, <span class="tok-number">16</span>)) == <span class="tok-number">0xDEADBEEF</span>);</span>
<span class="line" id="L1862"></span>
<span class="line" id="L1863">    <span class="tok-kw">try</span> std.testing.expect((<span class="tok-kw">try</span> parseUnsigned(<span class="tok-type">u7</span>, <span class="tok-str">&quot;1&quot;</span>, <span class="tok-number">10</span>)) == <span class="tok-number">1</span>);</span>
<span class="line" id="L1864">    <span class="tok-kw">try</span> std.testing.expect((<span class="tok-kw">try</span> parseUnsigned(<span class="tok-type">u7</span>, <span class="tok-str">&quot;1000&quot;</span>, <span class="tok-number">2</span>)) == <span class="tok-number">8</span>);</span>
<span class="line" id="L1865"></span>
<span class="line" id="L1866">    <span class="tok-kw">try</span> std.testing.expectError(<span class="tok-kw">error</span>.InvalidCharacter, parseUnsigned(<span class="tok-type">u32</span>, <span class="tok-str">&quot;f&quot;</span>, <span class="tok-number">10</span>));</span>
<span class="line" id="L1867">    <span class="tok-kw">try</span> std.testing.expectError(<span class="tok-kw">error</span>.InvalidCharacter, parseUnsigned(<span class="tok-type">u8</span>, <span class="tok-str">&quot;109&quot;</span>, <span class="tok-number">8</span>));</span>
<span class="line" id="L1868"></span>
<span class="line" id="L1869">    <span class="tok-kw">try</span> std.testing.expect((<span class="tok-kw">try</span> parseUnsigned(<span class="tok-type">u32</span>, <span class="tok-str">&quot;NUMBER&quot;</span>, <span class="tok-number">36</span>)) == <span class="tok-number">1442151747</span>);</span>
<span class="line" id="L1870"></span>
<span class="line" id="L1871">    <span class="tok-comment">// these numbers should fit even though the radix itself doesn't fit in the destination type</span>
</span>
<span class="line" id="L1872">    <span class="tok-kw">try</span> std.testing.expect((<span class="tok-kw">try</span> parseUnsigned(<span class="tok-type">u1</span>, <span class="tok-str">&quot;0&quot;</span>, <span class="tok-number">10</span>)) == <span class="tok-number">0</span>);</span>
<span class="line" id="L1873">    <span class="tok-kw">try</span> std.testing.expect((<span class="tok-kw">try</span> parseUnsigned(<span class="tok-type">u1</span>, <span class="tok-str">&quot;1&quot;</span>, <span class="tok-number">10</span>)) == <span class="tok-number">1</span>);</span>
<span class="line" id="L1874">    <span class="tok-kw">try</span> std.testing.expectError(<span class="tok-kw">error</span>.Overflow, parseUnsigned(<span class="tok-type">u1</span>, <span class="tok-str">&quot;2&quot;</span>, <span class="tok-number">10</span>));</span>
<span class="line" id="L1875">    <span class="tok-kw">try</span> std.testing.expect((<span class="tok-kw">try</span> parseUnsigned(<span class="tok-type">u1</span>, <span class="tok-str">&quot;001&quot;</span>, <span class="tok-number">16</span>)) == <span class="tok-number">1</span>);</span>
<span class="line" id="L1876">    <span class="tok-kw">try</span> std.testing.expect((<span class="tok-kw">try</span> parseUnsigned(<span class="tok-type">u2</span>, <span class="tok-str">&quot;3&quot;</span>, <span class="tok-number">16</span>)) == <span class="tok-number">3</span>);</span>
<span class="line" id="L1877">    <span class="tok-kw">try</span> std.testing.expectError(<span class="tok-kw">error</span>.Overflow, parseUnsigned(<span class="tok-type">u2</span>, <span class="tok-str">&quot;4&quot;</span>, <span class="tok-number">16</span>));</span>
<span class="line" id="L1878"></span>
<span class="line" id="L1879">    <span class="tok-comment">// parseUnsigned does not expect a sign</span>
</span>
<span class="line" id="L1880">    <span class="tok-kw">try</span> std.testing.expectError(<span class="tok-kw">error</span>.InvalidCharacter, parseUnsigned(<span class="tok-type">u8</span>, <span class="tok-str">&quot;+0&quot;</span>, <span class="tok-number">10</span>));</span>
<span class="line" id="L1881">    <span class="tok-kw">try</span> std.testing.expectError(<span class="tok-kw">error</span>.InvalidCharacter, parseUnsigned(<span class="tok-type">u8</span>, <span class="tok-str">&quot;-0&quot;</span>, <span class="tok-number">10</span>));</span>
<span class="line" id="L1882"></span>
<span class="line" id="L1883">    <span class="tok-comment">// test empty string error</span>
</span>
<span class="line" id="L1884">    <span class="tok-kw">try</span> std.testing.expectError(<span class="tok-kw">error</span>.InvalidCharacter, parseUnsigned(<span class="tok-type">u8</span>, <span class="tok-str">&quot;&quot;</span>, <span class="tok-number">10</span>));</span>
<span class="line" id="L1885">}</span>
<span class="line" id="L1886"></span>
<span class="line" id="L1887"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> parseFloat = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;fmt/parse_float.zig&quot;</span>).parseFloat;</span>
<span class="line" id="L1888"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> parseHexFloat = <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;deprecated; use `parseFloat`&quot;</span>);</span>
<span class="line" id="L1889"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> ParseFloatError = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;fmt/parse_float.zig&quot;</span>).ParseFloatError;</span>
<span class="line" id="L1890"></span>
<span class="line" id="L1891"><span class="tok-kw">test</span> {</span>
<span class="line" id="L1892">    _ = parseFloat;</span>
<span class="line" id="L1893">}</span>
<span class="line" id="L1894"></span>
<span class="line" id="L1895"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">charToDigit</span>(c: <span class="tok-type">u8</span>, radix: <span class="tok-type">u8</span>) (<span class="tok-kw">error</span>{InvalidCharacter}!<span class="tok-type">u8</span>) {</span>
<span class="line" id="L1896">    <span class="tok-kw">const</span> value = <span class="tok-kw">switch</span> (c) {</span>
<span class="line" id="L1897">        <span class="tok-str">'0'</span>...<span class="tok-str">'9'</span> =&gt; c - <span class="tok-str">'0'</span>,</span>
<span class="line" id="L1898">        <span class="tok-str">'A'</span>...<span class="tok-str">'Z'</span> =&gt; c - <span class="tok-str">'A'</span> + <span class="tok-number">10</span>,</span>
<span class="line" id="L1899">        <span class="tok-str">'a'</span>...<span class="tok-str">'z'</span> =&gt; c - <span class="tok-str">'a'</span> + <span class="tok-number">10</span>,</span>
<span class="line" id="L1900">        <span class="tok-kw">else</span> =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InvalidCharacter,</span>
<span class="line" id="L1901">    };</span>
<span class="line" id="L1902"></span>
<span class="line" id="L1903">    <span class="tok-kw">if</span> (value &gt;= radix) <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InvalidCharacter;</span>
<span class="line" id="L1904"></span>
<span class="line" id="L1905">    <span class="tok-kw">return</span> value;</span>
<span class="line" id="L1906">}</span>
<span class="line" id="L1907"></span>
<span class="line" id="L1908"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">digitToChar</span>(digit: <span class="tok-type">u8</span>, case: Case) <span class="tok-type">u8</span> {</span>
<span class="line" id="L1909">    <span class="tok-kw">return</span> <span class="tok-kw">switch</span> (digit) {</span>
<span class="line" id="L1910">        <span class="tok-number">0</span>...<span class="tok-number">9</span> =&gt; digit + <span class="tok-str">'0'</span>,</span>
<span class="line" id="L1911">        <span class="tok-number">10</span>...<span class="tok-number">35</span> =&gt; digit + ((<span class="tok-kw">if</span> (case == .upper) <span class="tok-builtin">@as</span>(<span class="tok-type">u8</span>, <span class="tok-str">'A'</span>) <span class="tok-kw">else</span> <span class="tok-builtin">@as</span>(<span class="tok-type">u8</span>, <span class="tok-str">'a'</span>)) - <span class="tok-number">10</span>),</span>
<span class="line" id="L1912">        <span class="tok-kw">else</span> =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L1913">    };</span>
<span class="line" id="L1914">}</span>
<span class="line" id="L1915"></span>
<span class="line" id="L1916"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> BufPrintError = <span class="tok-kw">error</span>{</span>
<span class="line" id="L1917">    <span class="tok-comment">/// As much as possible was written to the buffer, but it was too small to fit all the printed bytes.</span></span>
<span class="line" id="L1918">    NoSpaceLeft,</span>
<span class="line" id="L1919">};</span>
<span class="line" id="L1920"></span>
<span class="line" id="L1921"><span class="tok-comment">/// print a Formatter string into `buf`. Actually just a thin wrapper around `format` and `fixedBufferStream`.</span></span>
<span class="line" id="L1922"><span class="tok-comment">/// returns a slice of the bytes printed to.</span></span>
<span class="line" id="L1923"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">bufPrint</span>(buf: []<span class="tok-type">u8</span>, <span class="tok-kw">comptime</span> fmt: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, args: <span class="tok-kw">anytype</span>) BufPrintError![]<span class="tok-type">u8</span> {</span>
<span class="line" id="L1924">    <span class="tok-kw">var</span> fbs = std.io.fixedBufferStream(buf);</span>
<span class="line" id="L1925">    <span class="tok-kw">try</span> format(fbs.writer(), fmt, args);</span>
<span class="line" id="L1926">    <span class="tok-kw">return</span> fbs.getWritten();</span>
<span class="line" id="L1927">}</span>
<span class="line" id="L1928"></span>
<span class="line" id="L1929"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">bufPrintZ</span>(buf: []<span class="tok-type">u8</span>, <span class="tok-kw">comptime</span> fmt: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, args: <span class="tok-kw">anytype</span>) BufPrintError![:<span class="tok-number">0</span>]<span class="tok-type">u8</span> {</span>
<span class="line" id="L1930">    <span class="tok-kw">const</span> result = <span class="tok-kw">try</span> bufPrint(buf, fmt ++ <span class="tok-str">&quot;\x00&quot;</span>, args);</span>
<span class="line" id="L1931">    <span class="tok-kw">return</span> result[<span class="tok-number">0</span> .. result.len - <span class="tok-number">1</span> :<span class="tok-number">0</span>];</span>
<span class="line" id="L1932">}</span>
<span class="line" id="L1933"></span>
<span class="line" id="L1934"><span class="tok-comment">/// Count the characters needed for format. Useful for preallocating memory</span></span>
<span class="line" id="L1935"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">count</span>(<span class="tok-kw">comptime</span> fmt: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, args: <span class="tok-kw">anytype</span>) <span class="tok-type">u64</span> {</span>
<span class="line" id="L1936">    <span class="tok-kw">var</span> counting_writer = std.io.countingWriter(std.io.null_writer);</span>
<span class="line" id="L1937">    format(counting_writer.writer(), fmt, args) <span class="tok-kw">catch</span> |err| <span class="tok-kw">switch</span> (err) {};</span>
<span class="line" id="L1938">    <span class="tok-kw">return</span> counting_writer.bytes_written;</span>
<span class="line" id="L1939">}</span>
<span class="line" id="L1940"></span>
<span class="line" id="L1941"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> AllocPrintError = <span class="tok-kw">error</span>{OutOfMemory};</span>
<span class="line" id="L1942"></span>
<span class="line" id="L1943"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">allocPrint</span>(allocator: mem.Allocator, <span class="tok-kw">comptime</span> fmt: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, args: <span class="tok-kw">anytype</span>) AllocPrintError![]<span class="tok-type">u8</span> {</span>
<span class="line" id="L1944">    <span class="tok-kw">const</span> size = math.cast(<span class="tok-type">usize</span>, count(fmt, args)) <span class="tok-kw">orelse</span> <span class="tok-kw">return</span> <span class="tok-kw">error</span>.OutOfMemory;</span>
<span class="line" id="L1945">    <span class="tok-kw">const</span> buf = <span class="tok-kw">try</span> allocator.alloc(<span class="tok-type">u8</span>, size);</span>
<span class="line" id="L1946">    <span class="tok-kw">return</span> bufPrint(buf, fmt, args) <span class="tok-kw">catch</span> |err| <span class="tok-kw">switch</span> (err) {</span>
<span class="line" id="L1947">        <span class="tok-kw">error</span>.NoSpaceLeft =&gt; <span class="tok-kw">unreachable</span>, <span class="tok-comment">// we just counted the size above</span>
</span>
<span class="line" id="L1948">    };</span>
<span class="line" id="L1949">}</span>
<span class="line" id="L1950"></span>
<span class="line" id="L1951"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> allocPrint0 = <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;deprecated; use allocPrintZ&quot;</span>);</span>
<span class="line" id="L1952"></span>
<span class="line" id="L1953"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">allocPrintZ</span>(allocator: mem.Allocator, <span class="tok-kw">comptime</span> fmt: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, args: <span class="tok-kw">anytype</span>) AllocPrintError![:<span class="tok-number">0</span>]<span class="tok-type">u8</span> {</span>
<span class="line" id="L1954">    <span class="tok-kw">const</span> result = <span class="tok-kw">try</span> allocPrint(allocator, fmt ++ <span class="tok-str">&quot;\x00&quot;</span>, args);</span>
<span class="line" id="L1955">    <span class="tok-kw">return</span> result[<span class="tok-number">0</span> .. result.len - <span class="tok-number">1</span> :<span class="tok-number">0</span>];</span>
<span class="line" id="L1956">}</span>
<span class="line" id="L1957"></span>
<span class="line" id="L1958"><span class="tok-kw">test</span> <span class="tok-str">&quot;bufPrintInt&quot;</span> {</span>
<span class="line" id="L1959">    <span class="tok-kw">var</span> buffer: [<span class="tok-number">100</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L1960">    <span class="tok-kw">const</span> buf = buffer[<span class="tok-number">0</span>..];</span>
<span class="line" id="L1961"></span>
<span class="line" id="L1962">    <span class="tok-kw">try</span> std.testing.expectEqualSlices(<span class="tok-type">u8</span>, <span class="tok-str">&quot;-1&quot;</span>, bufPrintIntToSlice(buf, <span class="tok-builtin">@as</span>(<span class="tok-type">i1</span>, -<span class="tok-number">1</span>), <span class="tok-number">10</span>, .lower, FormatOptions{}));</span>
<span class="line" id="L1963"></span>
<span class="line" id="L1964">    <span class="tok-kw">try</span> std.testing.expectEqualSlices(<span class="tok-type">u8</span>, <span class="tok-str">&quot;-101111000110000101001110&quot;</span>, bufPrintIntToSlice(buf, <span class="tok-builtin">@as</span>(<span class="tok-type">i32</span>, -<span class="tok-number">12345678</span>), <span class="tok-number">2</span>, .lower, FormatOptions{}));</span>
<span class="line" id="L1965">    <span class="tok-kw">try</span> std.testing.expectEqualSlices(<span class="tok-type">u8</span>, <span class="tok-str">&quot;-12345678&quot;</span>, bufPrintIntToSlice(buf, <span class="tok-builtin">@as</span>(<span class="tok-type">i32</span>, -<span class="tok-number">12345678</span>), <span class="tok-number">10</span>, .lower, FormatOptions{}));</span>
<span class="line" id="L1966">    <span class="tok-kw">try</span> std.testing.expectEqualSlices(<span class="tok-type">u8</span>, <span class="tok-str">&quot;-bc614e&quot;</span>, bufPrintIntToSlice(buf, <span class="tok-builtin">@as</span>(<span class="tok-type">i32</span>, -<span class="tok-number">12345678</span>), <span class="tok-number">16</span>, .lower, FormatOptions{}));</span>
<span class="line" id="L1967">    <span class="tok-kw">try</span> std.testing.expectEqualSlices(<span class="tok-type">u8</span>, <span class="tok-str">&quot;-BC614E&quot;</span>, bufPrintIntToSlice(buf, <span class="tok-builtin">@as</span>(<span class="tok-type">i32</span>, -<span class="tok-number">12345678</span>), <span class="tok-number">16</span>, .upper, FormatOptions{}));</span>
<span class="line" id="L1968"></span>
<span class="line" id="L1969">    <span class="tok-kw">try</span> std.testing.expectEqualSlices(<span class="tok-type">u8</span>, <span class="tok-str">&quot;12345678&quot;</span>, bufPrintIntToSlice(buf, <span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">12345678</span>), <span class="tok-number">10</span>, .upper, FormatOptions{}));</span>
<span class="line" id="L1970"></span>
<span class="line" id="L1971">    <span class="tok-kw">try</span> std.testing.expectEqualSlices(<span class="tok-type">u8</span>, <span class="tok-str">&quot;   666&quot;</span>, bufPrintIntToSlice(buf, <span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">666</span>), <span class="tok-number">10</span>, .lower, FormatOptions{ .width = <span class="tok-number">6</span> }));</span>
<span class="line" id="L1972">    <span class="tok-kw">try</span> std.testing.expectEqualSlices(<span class="tok-type">u8</span>, <span class="tok-str">&quot;  1234&quot;</span>, bufPrintIntToSlice(buf, <span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">0x1234</span>), <span class="tok-number">16</span>, .lower, FormatOptions{ .width = <span class="tok-number">6</span> }));</span>
<span class="line" id="L1973">    <span class="tok-kw">try</span> std.testing.expectEqualSlices(<span class="tok-type">u8</span>, <span class="tok-str">&quot;1234&quot;</span>, bufPrintIntToSlice(buf, <span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">0x1234</span>), <span class="tok-number">16</span>, .lower, FormatOptions{ .width = <span class="tok-number">1</span> }));</span>
<span class="line" id="L1974"></span>
<span class="line" id="L1975">    <span class="tok-kw">try</span> std.testing.expectEqualSlices(<span class="tok-type">u8</span>, <span class="tok-str">&quot;+42&quot;</span>, bufPrintIntToSlice(buf, <span class="tok-builtin">@as</span>(<span class="tok-type">i32</span>, <span class="tok-number">42</span>), <span class="tok-number">10</span>, .lower, FormatOptions{ .width = <span class="tok-number">3</span> }));</span>
<span class="line" id="L1976">    <span class="tok-kw">try</span> std.testing.expectEqualSlices(<span class="tok-type">u8</span>, <span class="tok-str">&quot;-42&quot;</span>, bufPrintIntToSlice(buf, <span class="tok-builtin">@as</span>(<span class="tok-type">i32</span>, -<span class="tok-number">42</span>), <span class="tok-number">10</span>, .lower, FormatOptions{ .width = <span class="tok-number">3</span> }));</span>
<span class="line" id="L1977">}</span>
<span class="line" id="L1978"></span>
<span class="line" id="L1979"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">bufPrintIntToSlice</span>(buf: []<span class="tok-type">u8</span>, value: <span class="tok-kw">anytype</span>, base: <span class="tok-type">u8</span>, case: Case, options: FormatOptions) []<span class="tok-type">u8</span> {</span>
<span class="line" id="L1980">    <span class="tok-kw">return</span> buf[<span class="tok-number">0</span>..formatIntBuf(buf, value, base, case, options)];</span>
<span class="line" id="L1981">}</span>
<span class="line" id="L1982"></span>
<span class="line" id="L1983"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">comptimePrint</span>(<span class="tok-kw">comptime</span> fmt: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, args: <span class="tok-kw">anytype</span>) *<span class="tok-kw">const</span> [count(fmt, args):<span class="tok-number">0</span>]<span class="tok-type">u8</span> {</span>
<span class="line" id="L1984">    <span class="tok-kw">comptime</span> {</span>
<span class="line" id="L1985">        <span class="tok-kw">var</span> buf: [count(fmt, args):<span class="tok-number">0</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L1986">        _ = bufPrint(&amp;buf, fmt, args) <span class="tok-kw">catch</span> <span class="tok-kw">unreachable</span>;</span>
<span class="line" id="L1987">        buf[buf.len] = <span class="tok-number">0</span>;</span>
<span class="line" id="L1988">        <span class="tok-kw">return</span> &amp;buf;</span>
<span class="line" id="L1989">    }</span>
<span class="line" id="L1990">}</span>
<span class="line" id="L1991"></span>
<span class="line" id="L1992"><span class="tok-kw">test</span> <span class="tok-str">&quot;comptimePrint&quot;</span> {</span>
<span class="line" id="L1993">    <span class="tok-builtin">@setEvalBranchQuota</span>(<span class="tok-number">2000</span>);</span>
<span class="line" id="L1994">    <span class="tok-kw">try</span> std.testing.expectEqual(*<span class="tok-kw">const</span> [<span class="tok-number">3</span>:<span class="tok-number">0</span>]<span class="tok-type">u8</span>, <span class="tok-builtin">@TypeOf</span>(<span class="tok-kw">comptime</span> comptimePrint(<span class="tok-str">&quot;{}&quot;</span>, .{<span class="tok-number">100</span>})));</span>
<span class="line" id="L1995">    <span class="tok-kw">try</span> std.testing.expectEqualSlices(<span class="tok-type">u8</span>, <span class="tok-str">&quot;100&quot;</span>, <span class="tok-kw">comptime</span> comptimePrint(<span class="tok-str">&quot;{}&quot;</span>, .{<span class="tok-number">100</span>}));</span>
<span class="line" id="L1996">}</span>
<span class="line" id="L1997"></span>
<span class="line" id="L1998"><span class="tok-kw">test</span> <span class="tok-str">&quot;parse u64 digit too big&quot;</span> {</span>
<span class="line" id="L1999">    _ = parseUnsigned(<span class="tok-type">u64</span>, <span class="tok-str">&quot;123a&quot;</span>, <span class="tok-number">10</span>) <span class="tok-kw">catch</span> |err| {</span>
<span class="line" id="L2000">        <span class="tok-kw">if</span> (err == <span class="tok-kw">error</span>.InvalidCharacter) <span class="tok-kw">return</span>;</span>
<span class="line" id="L2001">        <span class="tok-kw">unreachable</span>;</span>
<span class="line" id="L2002">    };</span>
<span class="line" id="L2003">    <span class="tok-kw">unreachable</span>;</span>
<span class="line" id="L2004">}</span>
<span class="line" id="L2005"></span>
<span class="line" id="L2006"><span class="tok-kw">test</span> <span class="tok-str">&quot;parse unsigned comptime&quot;</span> {</span>
<span class="line" id="L2007">    <span class="tok-kw">comptime</span> {</span>
<span class="line" id="L2008">        <span class="tok-kw">try</span> std.testing.expect((<span class="tok-kw">try</span> parseUnsigned(<span class="tok-type">usize</span>, <span class="tok-str">&quot;2&quot;</span>, <span class="tok-number">10</span>)) == <span class="tok-number">2</span>);</span>
<span class="line" id="L2009">    }</span>
<span class="line" id="L2010">}</span>
<span class="line" id="L2011"></span>
<span class="line" id="L2012"><span class="tok-kw">test</span> <span class="tok-str">&quot;escaped braces&quot;</span> {</span>
<span class="line" id="L2013">    <span class="tok-kw">try</span> expectFmt(<span class="tok-str">&quot;escaped: {{foo}}\n&quot;</span>, <span class="tok-str">&quot;escaped: {{{{foo}}}}\n&quot;</span>, .{});</span>
<span class="line" id="L2014">    <span class="tok-kw">try</span> expectFmt(<span class="tok-str">&quot;escaped: {foo}\n&quot;</span>, <span class="tok-str">&quot;escaped: {{foo}}\n&quot;</span>, .{});</span>
<span class="line" id="L2015">}</span>
<span class="line" id="L2016"></span>
<span class="line" id="L2017"><span class="tok-kw">test</span> <span class="tok-str">&quot;optional&quot;</span> {</span>
<span class="line" id="L2018">    {</span>
<span class="line" id="L2019">        <span class="tok-kw">const</span> value: ?<span class="tok-type">i32</span> = <span class="tok-number">1234</span>;</span>
<span class="line" id="L2020">        <span class="tok-kw">try</span> expectFmt(<span class="tok-str">&quot;optional: 1234\n&quot;</span>, <span class="tok-str">&quot;optional: {?}\n&quot;</span>, .{value});</span>
<span class="line" id="L2021">        <span class="tok-kw">try</span> expectFmt(<span class="tok-str">&quot;optional: 1234\n&quot;</span>, <span class="tok-str">&quot;optional: {?d}\n&quot;</span>, .{value});</span>
<span class="line" id="L2022">        <span class="tok-kw">try</span> expectFmt(<span class="tok-str">&quot;optional: 4d2\n&quot;</span>, <span class="tok-str">&quot;optional: {?x}\n&quot;</span>, .{value});</span>
<span class="line" id="L2023">    }</span>
<span class="line" id="L2024">    {</span>
<span class="line" id="L2025">        <span class="tok-kw">const</span> value: ?[]<span class="tok-kw">const</span> <span class="tok-type">u8</span> = <span class="tok-str">&quot;string&quot;</span>;</span>
<span class="line" id="L2026">        <span class="tok-kw">try</span> expectFmt(<span class="tok-str">&quot;optional: string\n&quot;</span>, <span class="tok-str">&quot;optional: {?s}\n&quot;</span>, .{value});</span>
<span class="line" id="L2027">    }</span>
<span class="line" id="L2028">    {</span>
<span class="line" id="L2029">        <span class="tok-kw">const</span> value: ?<span class="tok-type">i32</span> = <span class="tok-null">null</span>;</span>
<span class="line" id="L2030">        <span class="tok-kw">try</span> expectFmt(<span class="tok-str">&quot;optional: null\n&quot;</span>, <span class="tok-str">&quot;optional: {?}\n&quot;</span>, .{value});</span>
<span class="line" id="L2031">    }</span>
<span class="line" id="L2032">    {</span>
<span class="line" id="L2033">        <span class="tok-kw">const</span> value = <span class="tok-builtin">@intToPtr</span>(?*<span class="tok-type">i32</span>, <span class="tok-number">0xf000d000</span>);</span>
<span class="line" id="L2034">        <span class="tok-kw">try</span> expectFmt(<span class="tok-str">&quot;optional: *i32@f000d000\n&quot;</span>, <span class="tok-str">&quot;optional: {*}\n&quot;</span>, .{value});</span>
<span class="line" id="L2035">    }</span>
<span class="line" id="L2036">}</span>
<span class="line" id="L2037"></span>
<span class="line" id="L2038"><span class="tok-kw">test</span> <span class="tok-str">&quot;error&quot;</span> {</span>
<span class="line" id="L2039">    {</span>
<span class="line" id="L2040">        <span class="tok-kw">const</span> value: <span class="tok-type">anyerror</span>!<span class="tok-type">i32</span> = <span class="tok-number">1234</span>;</span>
<span class="line" id="L2041">        <span class="tok-kw">try</span> expectFmt(<span class="tok-str">&quot;error union: 1234\n&quot;</span>, <span class="tok-str">&quot;error union: {!}\n&quot;</span>, .{value});</span>
<span class="line" id="L2042">        <span class="tok-kw">try</span> expectFmt(<span class="tok-str">&quot;error union: 1234\n&quot;</span>, <span class="tok-str">&quot;error union: {!d}\n&quot;</span>, .{value});</span>
<span class="line" id="L2043">        <span class="tok-kw">try</span> expectFmt(<span class="tok-str">&quot;error union: 4d2\n&quot;</span>, <span class="tok-str">&quot;error union: {!x}\n&quot;</span>, .{value});</span>
<span class="line" id="L2044">    }</span>
<span class="line" id="L2045">    {</span>
<span class="line" id="L2046">        <span class="tok-kw">const</span> value: <span class="tok-type">anyerror</span>![]<span class="tok-kw">const</span> <span class="tok-type">u8</span> = <span class="tok-str">&quot;string&quot;</span>;</span>
<span class="line" id="L2047">        <span class="tok-kw">try</span> expectFmt(<span class="tok-str">&quot;error union: string\n&quot;</span>, <span class="tok-str">&quot;error union: {!s}\n&quot;</span>, .{value});</span>
<span class="line" id="L2048">    }</span>
<span class="line" id="L2049">    {</span>
<span class="line" id="L2050">        <span class="tok-kw">const</span> value: <span class="tok-type">anyerror</span>!<span class="tok-type">i32</span> = <span class="tok-kw">error</span>.InvalidChar;</span>
<span class="line" id="L2051">        <span class="tok-kw">try</span> expectFmt(<span class="tok-str">&quot;error union: error.InvalidChar\n&quot;</span>, <span class="tok-str">&quot;error union: {!}\n&quot;</span>, .{value});</span>
<span class="line" id="L2052">    }</span>
<span class="line" id="L2053">}</span>
<span class="line" id="L2054"></span>
<span class="line" id="L2055"><span class="tok-kw">test</span> <span class="tok-str">&quot;int.small&quot;</span> {</span>
<span class="line" id="L2056">    {</span>
<span class="line" id="L2057">        <span class="tok-kw">const</span> value: <span class="tok-type">u3</span> = <span class="tok-number">0b101</span>;</span>
<span class="line" id="L2058">        <span class="tok-kw">try</span> expectFmt(<span class="tok-str">&quot;u3: 5\n&quot;</span>, <span class="tok-str">&quot;u3: {}\n&quot;</span>, .{value});</span>
<span class="line" id="L2059">    }</span>
<span class="line" id="L2060">}</span>
<span class="line" id="L2061"></span>
<span class="line" id="L2062"><span class="tok-kw">test</span> <span class="tok-str">&quot;int.specifier&quot;</span> {</span>
<span class="line" id="L2063">    {</span>
<span class="line" id="L2064">        <span class="tok-kw">const</span> value: <span class="tok-type">u8</span> = <span class="tok-str">'a'</span>;</span>
<span class="line" id="L2065">        <span class="tok-kw">try</span> expectFmt(<span class="tok-str">&quot;u8: a\n&quot;</span>, <span class="tok-str">&quot;u8: {c}\n&quot;</span>, .{value});</span>
<span class="line" id="L2066">    }</span>
<span class="line" id="L2067">    {</span>
<span class="line" id="L2068">        <span class="tok-kw">const</span> value: <span class="tok-type">u8</span> = <span class="tok-number">0b1100</span>;</span>
<span class="line" id="L2069">        <span class="tok-kw">try</span> expectFmt(<span class="tok-str">&quot;u8: 0b1100\n&quot;</span>, <span class="tok-str">&quot;u8: 0b{b}\n&quot;</span>, .{value});</span>
<span class="line" id="L2070">    }</span>
<span class="line" id="L2071">    {</span>
<span class="line" id="L2072">        <span class="tok-kw">const</span> value: <span class="tok-type">u16</span> = <span class="tok-number">0o1234</span>;</span>
<span class="line" id="L2073">        <span class="tok-kw">try</span> expectFmt(<span class="tok-str">&quot;u16: 0o1234\n&quot;</span>, <span class="tok-str">&quot;u16: 0o{o}\n&quot;</span>, .{value});</span>
<span class="line" id="L2074">    }</span>
<span class="line" id="L2075">    {</span>
<span class="line" id="L2076">        <span class="tok-kw">const</span> value: <span class="tok-type">u8</span> = <span class="tok-str">'a'</span>;</span>
<span class="line" id="L2077">        <span class="tok-kw">try</span> expectFmt(<span class="tok-str">&quot;UTF-8: a\n&quot;</span>, <span class="tok-str">&quot;UTF-8: {u}\n&quot;</span>, .{value});</span>
<span class="line" id="L2078">    }</span>
<span class="line" id="L2079">    {</span>
<span class="line" id="L2080">        <span class="tok-kw">const</span> value: <span class="tok-type">u21</span> = <span class="tok-number">0x1F310</span>;</span>
<span class="line" id="L2081">        <span class="tok-kw">try</span> expectFmt(<span class="tok-str">&quot;UTF-8: 🌐\n&quot;</span>, <span class="tok-str">&quot;UTF-8: {u}\n&quot;</span>, .{value});</span>
<span class="line" id="L2082">    }</span>
<span class="line" id="L2083">    {</span>
<span class="line" id="L2084">        <span class="tok-kw">const</span> value: <span class="tok-type">u21</span> = <span class="tok-number">0xD800</span>;</span>
<span class="line" id="L2085">        <span class="tok-kw">try</span> expectFmt(<span class="tok-str">&quot;UTF-8: �\n&quot;</span>, <span class="tok-str">&quot;UTF-8: {u}\n&quot;</span>, .{value});</span>
<span class="line" id="L2086">    }</span>
<span class="line" id="L2087">    {</span>
<span class="line" id="L2088">        <span class="tok-kw">const</span> value: <span class="tok-type">u21</span> = <span class="tok-number">0x110001</span>;</span>
<span class="line" id="L2089">        <span class="tok-kw">try</span> expectFmt(<span class="tok-str">&quot;UTF-8: �\n&quot;</span>, <span class="tok-str">&quot;UTF-8: {u}\n&quot;</span>, .{value});</span>
<span class="line" id="L2090">    }</span>
<span class="line" id="L2091">}</span>
<span class="line" id="L2092"></span>
<span class="line" id="L2093"><span class="tok-kw">test</span> <span class="tok-str">&quot;int.padded&quot;</span> {</span>
<span class="line" id="L2094">    <span class="tok-kw">try</span> expectFmt(<span class="tok-str">&quot;u8: '   1'&quot;</span>, <span class="tok-str">&quot;u8: '{:4}'&quot;</span>, .{<span class="tok-builtin">@as</span>(<span class="tok-type">u8</span>, <span class="tok-number">1</span>)});</span>
<span class="line" id="L2095">    <span class="tok-kw">try</span> expectFmt(<span class="tok-str">&quot;u8: '1000'&quot;</span>, <span class="tok-str">&quot;u8: '{:0&lt;4}'&quot;</span>, .{<span class="tok-builtin">@as</span>(<span class="tok-type">u8</span>, <span class="tok-number">1</span>)});</span>
<span class="line" id="L2096">    <span class="tok-kw">try</span> expectFmt(<span class="tok-str">&quot;u8: '0001'&quot;</span>, <span class="tok-str">&quot;u8: '{:0&gt;4}'&quot;</span>, .{<span class="tok-builtin">@as</span>(<span class="tok-type">u8</span>, <span class="tok-number">1</span>)});</span>
<span class="line" id="L2097">    <span class="tok-kw">try</span> expectFmt(<span class="tok-str">&quot;u8: '0100'&quot;</span>, <span class="tok-str">&quot;u8: '{:0^4}'&quot;</span>, .{<span class="tok-builtin">@as</span>(<span class="tok-type">u8</span>, <span class="tok-number">1</span>)});</span>
<span class="line" id="L2098">    <span class="tok-kw">try</span> expectFmt(<span class="tok-str">&quot;i8: '-1  '&quot;</span>, <span class="tok-str">&quot;i8: '{:&lt;4}'&quot;</span>, .{<span class="tok-builtin">@as</span>(<span class="tok-type">i8</span>, -<span class="tok-number">1</span>)});</span>
<span class="line" id="L2099">    <span class="tok-kw">try</span> expectFmt(<span class="tok-str">&quot;i8: '  -1'&quot;</span>, <span class="tok-str">&quot;i8: '{:&gt;4}'&quot;</span>, .{<span class="tok-builtin">@as</span>(<span class="tok-type">i8</span>, -<span class="tok-number">1</span>)});</span>
<span class="line" id="L2100">    <span class="tok-kw">try</span> expectFmt(<span class="tok-str">&quot;i8: ' -1 '&quot;</span>, <span class="tok-str">&quot;i8: '{:^4}'&quot;</span>, .{<span class="tok-builtin">@as</span>(<span class="tok-type">i8</span>, -<span class="tok-number">1</span>)});</span>
<span class="line" id="L2101">    <span class="tok-kw">try</span> expectFmt(<span class="tok-str">&quot;i16: '-1234'&quot;</span>, <span class="tok-str">&quot;i16: '{:4}'&quot;</span>, .{<span class="tok-builtin">@as</span>(<span class="tok-type">i16</span>, -<span class="tok-number">1234</span>)});</span>
<span class="line" id="L2102">    <span class="tok-kw">try</span> expectFmt(<span class="tok-str">&quot;i16: '+1234'&quot;</span>, <span class="tok-str">&quot;i16: '{:4}'&quot;</span>, .{<span class="tok-builtin">@as</span>(<span class="tok-type">i16</span>, <span class="tok-number">1234</span>)});</span>
<span class="line" id="L2103">    <span class="tok-kw">try</span> expectFmt(<span class="tok-str">&quot;i16: '-12345'&quot;</span>, <span class="tok-str">&quot;i16: '{:4}'&quot;</span>, .{<span class="tok-builtin">@as</span>(<span class="tok-type">i16</span>, -<span class="tok-number">12345</span>)});</span>
<span class="line" id="L2104">    <span class="tok-kw">try</span> expectFmt(<span class="tok-str">&quot;i16: '+12345'&quot;</span>, <span class="tok-str">&quot;i16: '{:4}'&quot;</span>, .{<span class="tok-builtin">@as</span>(<span class="tok-type">i16</span>, <span class="tok-number">12345</span>)});</span>
<span class="line" id="L2105">    <span class="tok-kw">try</span> expectFmt(<span class="tok-str">&quot;u16: '12345'&quot;</span>, <span class="tok-str">&quot;u16: '{:4}'&quot;</span>, .{<span class="tok-builtin">@as</span>(<span class="tok-type">u16</span>, <span class="tok-number">12345</span>)});</span>
<span class="line" id="L2106"></span>
<span class="line" id="L2107">    <span class="tok-kw">try</span> expectFmt(<span class="tok-str">&quot;UTF-8: 'ü   '&quot;</span>, <span class="tok-str">&quot;UTF-8: '{u:&lt;4}'&quot;</span>, .{<span class="tok-str">'ü'</span>});</span>
<span class="line" id="L2108">    <span class="tok-kw">try</span> expectFmt(<span class="tok-str">&quot;UTF-8: '   ü'&quot;</span>, <span class="tok-str">&quot;UTF-8: '{u:&gt;4}'&quot;</span>, .{<span class="tok-str">'ü'</span>});</span>
<span class="line" id="L2109">    <span class="tok-kw">try</span> expectFmt(<span class="tok-str">&quot;UTF-8: ' ü  '&quot;</span>, <span class="tok-str">&quot;UTF-8: '{u:^4}'&quot;</span>, .{<span class="tok-str">'ü'</span>});</span>
<span class="line" id="L2110">}</span>
<span class="line" id="L2111"></span>
<span class="line" id="L2112"><span class="tok-kw">test</span> <span class="tok-str">&quot;buffer&quot;</span> {</span>
<span class="line" id="L2113">    {</span>
<span class="line" id="L2114">        <span class="tok-kw">var</span> buf1: [<span class="tok-number">32</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L2115">        <span class="tok-kw">var</span> fbs = std.io.fixedBufferStream(&amp;buf1);</span>
<span class="line" id="L2116">        <span class="tok-kw">try</span> formatType(<span class="tok-number">1234</span>, <span class="tok-str">&quot;&quot;</span>, FormatOptions{}, fbs.writer(), default_max_depth);</span>
<span class="line" id="L2117">        <span class="tok-kw">try</span> std.testing.expect(mem.eql(<span class="tok-type">u8</span>, fbs.getWritten(), <span class="tok-str">&quot;1234&quot;</span>));</span>
<span class="line" id="L2118"></span>
<span class="line" id="L2119">        fbs.reset();</span>
<span class="line" id="L2120">        <span class="tok-kw">try</span> formatType(<span class="tok-str">'a'</span>, <span class="tok-str">&quot;c&quot;</span>, FormatOptions{}, fbs.writer(), default_max_depth);</span>
<span class="line" id="L2121">        <span class="tok-kw">try</span> std.testing.expect(mem.eql(<span class="tok-type">u8</span>, fbs.getWritten(), <span class="tok-str">&quot;a&quot;</span>));</span>
<span class="line" id="L2122"></span>
<span class="line" id="L2123">        fbs.reset();</span>
<span class="line" id="L2124">        <span class="tok-kw">try</span> formatType(<span class="tok-number">0b1100</span>, <span class="tok-str">&quot;b&quot;</span>, FormatOptions{}, fbs.writer(), default_max_depth);</span>
<span class="line" id="L2125">        <span class="tok-kw">try</span> std.testing.expect(mem.eql(<span class="tok-type">u8</span>, fbs.getWritten(), <span class="tok-str">&quot;1100&quot;</span>));</span>
<span class="line" id="L2126">    }</span>
<span class="line" id="L2127">}</span>
<span class="line" id="L2128"></span>
<span class="line" id="L2129"><span class="tok-kw">test</span> <span class="tok-str">&quot;array&quot;</span> {</span>
<span class="line" id="L2130">    {</span>
<span class="line" id="L2131">        <span class="tok-kw">const</span> value: [<span class="tok-number">3</span>]<span class="tok-type">u8</span> = <span class="tok-str">&quot;abc&quot;</span>.*;</span>
<span class="line" id="L2132">        <span class="tok-kw">try</span> expectFmt(<span class="tok-str">&quot;array: abc\n&quot;</span>, <span class="tok-str">&quot;array: {s}\n&quot;</span>, .{value});</span>
<span class="line" id="L2133">        <span class="tok-kw">try</span> expectFmt(<span class="tok-str">&quot;array: abc\n&quot;</span>, <span class="tok-str">&quot;array: {s}\n&quot;</span>, .{&amp;value});</span>
<span class="line" id="L2134">        <span class="tok-kw">try</span> expectFmt(<span class="tok-str">&quot;array: { 97, 98, 99 }\n&quot;</span>, <span class="tok-str">&quot;array: {d}\n&quot;</span>, .{value});</span>
<span class="line" id="L2135"></span>
<span class="line" id="L2136">        <span class="tok-kw">var</span> buf: [<span class="tok-number">100</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L2137">        <span class="tok-kw">try</span> expectFmt(</span>
<span class="line" id="L2138">            <span class="tok-kw">try</span> bufPrint(buf[<span class="tok-number">0</span>..], <span class="tok-str">&quot;array: [3]u8@{x}\n&quot;</span>, .{<span class="tok-builtin">@ptrToInt</span>(&amp;value)}),</span>
<span class="line" id="L2139">            <span class="tok-str">&quot;array: {*}\n&quot;</span>,</span>
<span class="line" id="L2140">            .{&amp;value},</span>
<span class="line" id="L2141">        );</span>
<span class="line" id="L2142">    }</span>
<span class="line" id="L2143">}</span>
<span class="line" id="L2144"></span>
<span class="line" id="L2145"><span class="tok-kw">test</span> <span class="tok-str">&quot;slice&quot;</span> {</span>
<span class="line" id="L2146">    {</span>
<span class="line" id="L2147">        <span class="tok-kw">const</span> value: []<span class="tok-kw">const</span> <span class="tok-type">u8</span> = <span class="tok-str">&quot;abc&quot;</span>;</span>
<span class="line" id="L2148">        <span class="tok-kw">try</span> expectFmt(<span class="tok-str">&quot;slice: abc\n&quot;</span>, <span class="tok-str">&quot;slice: {s}\n&quot;</span>, .{value});</span>
<span class="line" id="L2149">    }</span>
<span class="line" id="L2150">    {</span>
<span class="line" id="L2151">        <span class="tok-kw">var</span> runtime_zero: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L2152">        <span class="tok-kw">const</span> value = <span class="tok-builtin">@intToPtr</span>([*]<span class="tok-kw">align</span>(<span class="tok-number">1</span>) <span class="tok-kw">const</span> []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, <span class="tok-number">0xdeadbeef</span>)[runtime_zero..runtime_zero];</span>
<span class="line" id="L2153">        <span class="tok-kw">try</span> expectFmt(<span class="tok-str">&quot;slice: []const u8@deadbeef\n&quot;</span>, <span class="tok-str">&quot;slice: {*}\n&quot;</span>, .{value});</span>
<span class="line" id="L2154">    }</span>
<span class="line" id="L2155">    {</span>
<span class="line" id="L2156">        <span class="tok-kw">const</span> null_term_slice: [:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span> = <span class="tok-str">&quot;\x00hello\x00&quot;</span>;</span>
<span class="line" id="L2157">        <span class="tok-kw">try</span> expectFmt(<span class="tok-str">&quot;buf: \x00hello\x00\n&quot;</span>, <span class="tok-str">&quot;buf: {s}\n&quot;</span>, .{null_term_slice});</span>
<span class="line" id="L2158">    }</span>
<span class="line" id="L2159"></span>
<span class="line" id="L2160">    <span class="tok-kw">try</span> expectFmt(<span class="tok-str">&quot;buf:  Test\n&quot;</span>, <span class="tok-str">&quot;buf: {s:5}\n&quot;</span>, .{<span class="tok-str">&quot;Test&quot;</span>});</span>
<span class="line" id="L2161">    <span class="tok-kw">try</span> expectFmt(<span class="tok-str">&quot;buf: Test\n Other text&quot;</span>, <span class="tok-str">&quot;buf: {s}\n Other text&quot;</span>, .{<span class="tok-str">&quot;Test&quot;</span>});</span>
<span class="line" id="L2162"></span>
<span class="line" id="L2163">    {</span>
<span class="line" id="L2164">        <span class="tok-kw">var</span> int_slice = [_]<span class="tok-type">u32</span>{ <span class="tok-number">1</span>, <span class="tok-number">4096</span>, <span class="tok-number">391891</span>, <span class="tok-number">1111111111</span> };</span>
<span class="line" id="L2165">        <span class="tok-kw">var</span> runtime_zero: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L2166">        <span class="tok-kw">try</span> expectFmt(<span class="tok-str">&quot;int: { 1, 4096, 391891, 1111111111 }&quot;</span>, <span class="tok-str">&quot;int: {any}&quot;</span>, .{int_slice[runtime_zero..]});</span>
<span class="line" id="L2167">        <span class="tok-kw">try</span> expectFmt(<span class="tok-str">&quot;int: { 1, 4096, 391891, 1111111111 }&quot;</span>, <span class="tok-str">&quot;int: {d}&quot;</span>, .{int_slice[runtime_zero..]});</span>
<span class="line" id="L2168">        <span class="tok-kw">try</span> expectFmt(<span class="tok-str">&quot;int: { 1, 1000, 5fad3, 423a35c7 }&quot;</span>, <span class="tok-str">&quot;int: {x}&quot;</span>, .{int_slice[runtime_zero..]});</span>
<span class="line" id="L2169">        <span class="tok-kw">try</span> expectFmt(<span class="tok-str">&quot;int: { 00001, 01000, 5fad3, 423a35c7 }&quot;</span>, <span class="tok-str">&quot;int: {x:0&gt;5}&quot;</span>, .{int_slice[runtime_zero..]});</span>
<span class="line" id="L2170">    }</span>
<span class="line" id="L2171">}</span>
<span class="line" id="L2172"></span>
<span class="line" id="L2173"><span class="tok-kw">test</span> <span class="tok-str">&quot;escape non-printable&quot;</span> {</span>
<span class="line" id="L2174">    <span class="tok-kw">try</span> expectFmt(<span class="tok-str">&quot;abc&quot;</span>, <span class="tok-str">&quot;{s}&quot;</span>, .{fmtSliceEscapeLower(<span class="tok-str">&quot;abc&quot;</span>)});</span>
<span class="line" id="L2175">    <span class="tok-kw">try</span> expectFmt(<span class="tok-str">&quot;ab\\xffc&quot;</span>, <span class="tok-str">&quot;{s}&quot;</span>, .{fmtSliceEscapeLower(<span class="tok-str">&quot;ab\xffc&quot;</span>)});</span>
<span class="line" id="L2176">    <span class="tok-kw">try</span> expectFmt(<span class="tok-str">&quot;ab\\xFFc&quot;</span>, <span class="tok-str">&quot;{s}&quot;</span>, .{fmtSliceEscapeUpper(<span class="tok-str">&quot;ab\xffc&quot;</span>)});</span>
<span class="line" id="L2177">}</span>
<span class="line" id="L2178"></span>
<span class="line" id="L2179"><span class="tok-kw">test</span> <span class="tok-str">&quot;pointer&quot;</span> {</span>
<span class="line" id="L2180">    <span class="tok-kw">if</span> (builtin.zig_backend == .stage1) <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SkipZigTest;</span>
<span class="line" id="L2181">    {</span>
<span class="line" id="L2182">        <span class="tok-kw">const</span> value = <span class="tok-builtin">@intToPtr</span>(*<span class="tok-kw">align</span>(<span class="tok-number">1</span>) <span class="tok-type">i32</span>, <span class="tok-number">0xdeadbeef</span>);</span>
<span class="line" id="L2183">        <span class="tok-kw">try</span> expectFmt(<span class="tok-str">&quot;pointer: i32@deadbeef\n&quot;</span>, <span class="tok-str">&quot;pointer: {}\n&quot;</span>, .{value});</span>
<span class="line" id="L2184">        <span class="tok-kw">try</span> expectFmt(<span class="tok-str">&quot;pointer: i32@deadbeef\n&quot;</span>, <span class="tok-str">&quot;pointer: {*}\n&quot;</span>, .{value});</span>
<span class="line" id="L2185">    }</span>
<span class="line" id="L2186">    {</span>
<span class="line" id="L2187">        <span class="tok-kw">const</span> value = <span class="tok-builtin">@intToPtr</span>(*<span class="tok-kw">align</span>(<span class="tok-number">1</span>) <span class="tok-kw">const</span> <span class="tok-kw">fn</span> () <span class="tok-type">void</span>, <span class="tok-number">0xdeadbeef</span>);</span>
<span class="line" id="L2188">        <span class="tok-kw">try</span> expectFmt(<span class="tok-str">&quot;pointer: fn() void@deadbeef\n&quot;</span>, <span class="tok-str">&quot;pointer: {}\n&quot;</span>, .{value});</span>
<span class="line" id="L2189">    }</span>
<span class="line" id="L2190">    {</span>
<span class="line" id="L2191">        <span class="tok-kw">const</span> value = <span class="tok-builtin">@intToPtr</span>(*<span class="tok-kw">align</span>(<span class="tok-number">1</span>) <span class="tok-kw">const</span> <span class="tok-kw">fn</span> () <span class="tok-type">void</span>, <span class="tok-number">0xdeadbeef</span>);</span>
<span class="line" id="L2192">        <span class="tok-kw">try</span> expectFmt(<span class="tok-str">&quot;pointer: fn() void@deadbeef\n&quot;</span>, <span class="tok-str">&quot;pointer: {}\n&quot;</span>, .{value});</span>
<span class="line" id="L2193">    }</span>
<span class="line" id="L2194">}</span>
<span class="line" id="L2195"></span>
<span class="line" id="L2196"><span class="tok-kw">test</span> <span class="tok-str">&quot;cstr&quot;</span> {</span>
<span class="line" id="L2197">    <span class="tok-kw">try</span> expectFmt(</span>
<span class="line" id="L2198">        <span class="tok-str">&quot;cstr: Test C\n&quot;</span>,</span>
<span class="line" id="L2199">        <span class="tok-str">&quot;cstr: {s}\n&quot;</span>,</span>
<span class="line" id="L2200">        .{<span class="tok-builtin">@ptrCast</span>([*c]<span class="tok-kw">const</span> <span class="tok-type">u8</span>, <span class="tok-str">&quot;Test C&quot;</span>)},</span>
<span class="line" id="L2201">    );</span>
<span class="line" id="L2202">    <span class="tok-kw">try</span> expectFmt(</span>
<span class="line" id="L2203">        <span class="tok-str">&quot;cstr:     Test C\n&quot;</span>,</span>
<span class="line" id="L2204">        <span class="tok-str">&quot;cstr: {s:10}\n&quot;</span>,</span>
<span class="line" id="L2205">        .{<span class="tok-builtin">@ptrCast</span>([*c]<span class="tok-kw">const</span> <span class="tok-type">u8</span>, <span class="tok-str">&quot;Test C&quot;</span>)},</span>
<span class="line" id="L2206">    );</span>
<span class="line" id="L2207">}</span>
<span class="line" id="L2208"></span>
<span class="line" id="L2209"><span class="tok-kw">test</span> <span class="tok-str">&quot;filesize&quot;</span> {</span>
<span class="line" id="L2210">    <span class="tok-kw">try</span> expectFmt(<span class="tok-str">&quot;file size: 42B\n&quot;</span>, <span class="tok-str">&quot;file size: {}\n&quot;</span>, .{fmtIntSizeDec(<span class="tok-number">42</span>)});</span>
<span class="line" id="L2211">    <span class="tok-kw">try</span> expectFmt(<span class="tok-str">&quot;file size: 42B\n&quot;</span>, <span class="tok-str">&quot;file size: {}\n&quot;</span>, .{fmtIntSizeBin(<span class="tok-number">42</span>)});</span>
<span class="line" id="L2212">    <span class="tok-kw">try</span> expectFmt(<span class="tok-str">&quot;file size: 63MB\n&quot;</span>, <span class="tok-str">&quot;file size: {}\n&quot;</span>, .{fmtIntSizeDec(<span class="tok-number">63</span> * <span class="tok-number">1000</span> * <span class="tok-number">1000</span>)});</span>
<span class="line" id="L2213">    <span class="tok-kw">try</span> expectFmt(<span class="tok-str">&quot;file size: 63MiB\n&quot;</span>, <span class="tok-str">&quot;file size: {}\n&quot;</span>, .{fmtIntSizeBin(<span class="tok-number">63</span> * <span class="tok-number">1024</span> * <span class="tok-number">1024</span>)});</span>
<span class="line" id="L2214">    <span class="tok-kw">try</span> expectFmt(<span class="tok-str">&quot;file size: 66.06MB\n&quot;</span>, <span class="tok-str">&quot;file size: {:.2}\n&quot;</span>, .{fmtIntSizeDec(<span class="tok-number">63</span> * <span class="tok-number">1024</span> * <span class="tok-number">1024</span>)});</span>
<span class="line" id="L2215">    <span class="tok-kw">try</span> expectFmt(<span class="tok-str">&quot;file size: 60.08MiB\n&quot;</span>, <span class="tok-str">&quot;file size: {:.2}\n&quot;</span>, .{fmtIntSizeBin(<span class="tok-number">63</span> * <span class="tok-number">1000</span> * <span class="tok-number">1000</span>)});</span>
<span class="line" id="L2216">    <span class="tok-kw">try</span> expectFmt(<span class="tok-str">&quot;file size: =66.06MB=\n&quot;</span>, <span class="tok-str">&quot;file size: {:=^9.2}\n&quot;</span>, .{fmtIntSizeDec(<span class="tok-number">63</span> * <span class="tok-number">1024</span> * <span class="tok-number">1024</span>)});</span>
<span class="line" id="L2217">    <span class="tok-kw">try</span> expectFmt(<span class="tok-str">&quot;file size:   66.06MB\n&quot;</span>, <span class="tok-str">&quot;file size: {: &gt;9.2}\n&quot;</span>, .{fmtIntSizeDec(<span class="tok-number">63</span> * <span class="tok-number">1024</span> * <span class="tok-number">1024</span>)});</span>
<span class="line" id="L2218">    <span class="tok-kw">try</span> expectFmt(<span class="tok-str">&quot;file size: 66.06MB  \n&quot;</span>, <span class="tok-str">&quot;file size: {: &lt;9.2}\n&quot;</span>, .{fmtIntSizeDec(<span class="tok-number">63</span> * <span class="tok-number">1024</span> * <span class="tok-number">1024</span>)});</span>
<span class="line" id="L2219">    <span class="tok-kw">try</span> expectFmt(<span class="tok-str">&quot;file size: 0.01844674407370955ZB\n&quot;</span>, <span class="tok-str">&quot;file size: {}\n&quot;</span>, .{fmtIntSizeDec(math.maxInt(<span class="tok-type">u64</span>))});</span>
<span class="line" id="L2220">}</span>
<span class="line" id="L2221"></span>
<span class="line" id="L2222"><span class="tok-kw">test</span> <span class="tok-str">&quot;struct&quot;</span> {</span>
<span class="line" id="L2223">    {</span>
<span class="line" id="L2224">        <span class="tok-kw">const</span> Struct = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L2225">            field: <span class="tok-type">u8</span>,</span>
<span class="line" id="L2226">        };</span>
<span class="line" id="L2227">        <span class="tok-kw">const</span> value = Struct{ .field = <span class="tok-number">42</span> };</span>
<span class="line" id="L2228">        <span class="tok-kw">try</span> expectFmt(<span class="tok-str">&quot;struct: Struct{ .field = 42 }\n&quot;</span>, <span class="tok-str">&quot;struct: {}\n&quot;</span>, .{value});</span>
<span class="line" id="L2229">        <span class="tok-kw">try</span> expectFmt(<span class="tok-str">&quot;struct: Struct{ .field = 42 }\n&quot;</span>, <span class="tok-str">&quot;struct: {}\n&quot;</span>, .{&amp;value});</span>
<span class="line" id="L2230">    }</span>
<span class="line" id="L2231">    {</span>
<span class="line" id="L2232">        <span class="tok-kw">const</span> Struct = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L2233">            a: <span class="tok-type">u0</span>,</span>
<span class="line" id="L2234">            b: <span class="tok-type">u1</span>,</span>
<span class="line" id="L2235">        };</span>
<span class="line" id="L2236">        <span class="tok-kw">const</span> value = Struct{ .a = <span class="tok-number">0</span>, .b = <span class="tok-number">1</span> };</span>
<span class="line" id="L2237">        <span class="tok-kw">try</span> expectFmt(<span class="tok-str">&quot;struct: Struct{ .a = 0, .b = 1 }\n&quot;</span>, <span class="tok-str">&quot;struct: {}\n&quot;</span>, .{value});</span>
<span class="line" id="L2238">    }</span>
<span class="line" id="L2239">}</span>
<span class="line" id="L2240"></span>
<span class="line" id="L2241"><span class="tok-kw">test</span> <span class="tok-str">&quot;enum&quot;</span> {</span>
<span class="line" id="L2242">    <span class="tok-kw">if</span> (builtin.zig_backend == .stage1) {</span>
<span class="line" id="L2243">        <span class="tok-comment">// stage1 starts the typename with 'std' which might also be desireable for stage2</span>
</span>
<span class="line" id="L2244">        <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SkipZigTest;</span>
<span class="line" id="L2245">    }</span>
<span class="line" id="L2246">    <span class="tok-kw">const</span> Enum = <span class="tok-kw">enum</span> {</span>
<span class="line" id="L2247">        One,</span>
<span class="line" id="L2248">        Two,</span>
<span class="line" id="L2249">    };</span>
<span class="line" id="L2250">    <span class="tok-kw">const</span> value = Enum.Two;</span>
<span class="line" id="L2251">    <span class="tok-kw">try</span> expectFmt(<span class="tok-str">&quot;enum: Enum.Two\n&quot;</span>, <span class="tok-str">&quot;enum: {}\n&quot;</span>, .{value});</span>
<span class="line" id="L2252">    <span class="tok-kw">try</span> expectFmt(<span class="tok-str">&quot;enum: Enum.Two\n&quot;</span>, <span class="tok-str">&quot;enum: {}\n&quot;</span>, .{&amp;value});</span>
<span class="line" id="L2253">    <span class="tok-kw">try</span> expectFmt(<span class="tok-str">&quot;enum: Enum.One\n&quot;</span>, <span class="tok-str">&quot;enum: {}\n&quot;</span>, .{Enum.One});</span>
<span class="line" id="L2254">    <span class="tok-kw">try</span> expectFmt(<span class="tok-str">&quot;enum: Enum.Two\n&quot;</span>, <span class="tok-str">&quot;enum: {}\n&quot;</span>, .{Enum.Two});</span>
<span class="line" id="L2255"></span>
<span class="line" id="L2256">    <span class="tok-comment">// test very large enum to verify ct branch quota is large enough</span>
</span>
<span class="line" id="L2257">    <span class="tok-kw">try</span> expectFmt(<span class="tok-str">&quot;enum: os.windows.win32error.Win32Error.INVALID_FUNCTION\n&quot;</span>, <span class="tok-str">&quot;enum: {}\n&quot;</span>, .{std.os.windows.Win32Error.INVALID_FUNCTION});</span>
<span class="line" id="L2258">}</span>
<span class="line" id="L2259"></span>
<span class="line" id="L2260"><span class="tok-kw">test</span> <span class="tok-str">&quot;non-exhaustive enum&quot;</span> {</span>
<span class="line" id="L2261">    <span class="tok-kw">if</span> (builtin.zig_backend == .stage1) {</span>
<span class="line" id="L2262">        <span class="tok-comment">// stage1 fails to return fully qualified namespaces.</span>
</span>
<span class="line" id="L2263">        <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SkipZigTest;</span>
<span class="line" id="L2264">    }</span>
<span class="line" id="L2265">    <span class="tok-kw">const</span> Enum = <span class="tok-kw">enum</span>(<span class="tok-type">u16</span>) {</span>
<span class="line" id="L2266">        One = <span class="tok-number">0x000f</span>,</span>
<span class="line" id="L2267">        Two = <span class="tok-number">0xbeef</span>,</span>
<span class="line" id="L2268">        _,</span>
<span class="line" id="L2269">    };</span>
<span class="line" id="L2270">    <span class="tok-kw">try</span> expectFmt(<span class="tok-str">&quot;enum: fmt.test.non-exhaustive enum.Enum.One\n&quot;</span>, <span class="tok-str">&quot;enum: {}\n&quot;</span>, .{Enum.One});</span>
<span class="line" id="L2271">    <span class="tok-kw">try</span> expectFmt(<span class="tok-str">&quot;enum: fmt.test.non-exhaustive enum.Enum.Two\n&quot;</span>, <span class="tok-str">&quot;enum: {}\n&quot;</span>, .{Enum.Two});</span>
<span class="line" id="L2272">    <span class="tok-kw">try</span> expectFmt(<span class="tok-str">&quot;enum: fmt.test.non-exhaustive enum.Enum(4660)\n&quot;</span>, <span class="tok-str">&quot;enum: {}\n&quot;</span>, .{<span class="tok-builtin">@intToEnum</span>(Enum, <span class="tok-number">0x1234</span>)});</span>
<span class="line" id="L2273">    <span class="tok-kw">try</span> expectFmt(<span class="tok-str">&quot;enum: fmt.test.non-exhaustive enum.Enum.One\n&quot;</span>, <span class="tok-str">&quot;enum: {x}\n&quot;</span>, .{Enum.One});</span>
<span class="line" id="L2274">    <span class="tok-kw">try</span> expectFmt(<span class="tok-str">&quot;enum: fmt.test.non-exhaustive enum.Enum.Two\n&quot;</span>, <span class="tok-str">&quot;enum: {x}\n&quot;</span>, .{Enum.Two});</span>
<span class="line" id="L2275">    <span class="tok-kw">try</span> expectFmt(<span class="tok-str">&quot;enum: fmt.test.non-exhaustive enum.Enum.Two\n&quot;</span>, <span class="tok-str">&quot;enum: {X}\n&quot;</span>, .{Enum.Two});</span>
<span class="line" id="L2276">    <span class="tok-kw">try</span> expectFmt(<span class="tok-str">&quot;enum: fmt.test.non-exhaustive enum.Enum(1234)\n&quot;</span>, <span class="tok-str">&quot;enum: {x}\n&quot;</span>, .{<span class="tok-builtin">@intToEnum</span>(Enum, <span class="tok-number">0x1234</span>)});</span>
<span class="line" id="L2277">}</span>
<span class="line" id="L2278"></span>
<span class="line" id="L2279"><span class="tok-kw">test</span> <span class="tok-str">&quot;float.scientific&quot;</span> {</span>
<span class="line" id="L2280">    <span class="tok-kw">try</span> expectFmt(<span class="tok-str">&quot;f32: 1.34000003e+00&quot;</span>, <span class="tok-str">&quot;f32: {e}&quot;</span>, .{<span class="tok-builtin">@as</span>(<span class="tok-type">f32</span>, <span class="tok-number">1.34</span>)});</span>
<span class="line" id="L2281">    <span class="tok-kw">try</span> expectFmt(<span class="tok-str">&quot;f32: 1.23400001e+01&quot;</span>, <span class="tok-str">&quot;f32: {e}&quot;</span>, .{<span class="tok-builtin">@as</span>(<span class="tok-type">f32</span>, <span class="tok-number">12.34</span>)});</span>
<span class="line" id="L2282">    <span class="tok-kw">try</span> expectFmt(<span class="tok-str">&quot;f64: -1.234e+11&quot;</span>, <span class="tok-str">&quot;f64: {e}&quot;</span>, .{<span class="tok-builtin">@as</span>(<span class="tok-type">f64</span>, -<span class="tok-number">12.34e10</span>)});</span>
<span class="line" id="L2283">    <span class="tok-kw">try</span> expectFmt(<span class="tok-str">&quot;f64: 9.99996e-40&quot;</span>, <span class="tok-str">&quot;f64: {e}&quot;</span>, .{<span class="tok-builtin">@as</span>(<span class="tok-type">f64</span>, <span class="tok-number">9.999960e-40</span>)});</span>
<span class="line" id="L2284">}</span>
<span class="line" id="L2285"></span>
<span class="line" id="L2286"><span class="tok-kw">test</span> <span class="tok-str">&quot;float.scientific.precision&quot;</span> {</span>
<span class="line" id="L2287">    <span class="tok-kw">try</span> expectFmt(<span class="tok-str">&quot;f64: 1.40971e-42&quot;</span>, <span class="tok-str">&quot;f64: {e:.5}&quot;</span>, .{<span class="tok-builtin">@as</span>(<span class="tok-type">f64</span>, <span class="tok-number">1.409706e-42</span>)});</span>
<span class="line" id="L2288">    <span class="tok-kw">try</span> expectFmt(<span class="tok-str">&quot;f64: 1.00000e-09&quot;</span>, <span class="tok-str">&quot;f64: {e:.5}&quot;</span>, .{<span class="tok-builtin">@as</span>(<span class="tok-type">f64</span>, <span class="tok-builtin">@bitCast</span>(<span class="tok-type">f32</span>, <span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">814313563</span>)))});</span>
<span class="line" id="L2289">    <span class="tok-kw">try</span> expectFmt(<span class="tok-str">&quot;f64: 7.81250e-03&quot;</span>, <span class="tok-str">&quot;f64: {e:.5}&quot;</span>, .{<span class="tok-builtin">@as</span>(<span class="tok-type">f64</span>, <span class="tok-builtin">@bitCast</span>(<span class="tok-type">f32</span>, <span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">1006632960</span>)))});</span>
<span class="line" id="L2290">    <span class="tok-comment">// libc rounds 1.000005e+05 to 1.00000e+05 but zig does 1.00001e+05.</span>
</span>
<span class="line" id="L2291">    <span class="tok-comment">// In fact, libc doesn't round a lot of 5 cases up when one past the precision point.</span>
</span>
<span class="line" id="L2292">    <span class="tok-kw">try</span> expectFmt(<span class="tok-str">&quot;f64: 1.00001e+05&quot;</span>, <span class="tok-str">&quot;f64: {e:.5}&quot;</span>, .{<span class="tok-builtin">@as</span>(<span class="tok-type">f64</span>, <span class="tok-builtin">@bitCast</span>(<span class="tok-type">f32</span>, <span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">1203982400</span>)))});</span>
<span class="line" id="L2293">}</span>
<span class="line" id="L2294"></span>
<span class="line" id="L2295"><span class="tok-kw">test</span> <span class="tok-str">&quot;float.special&quot;</span> {</span>
<span class="line" id="L2296">    <span class="tok-kw">try</span> expectFmt(<span class="tok-str">&quot;f64: nan&quot;</span>, <span class="tok-str">&quot;f64: {}&quot;</span>, .{math.nan_f64});</span>
<span class="line" id="L2297">    <span class="tok-comment">// negative nan is not defined by IEE 754,</span>
</span>
<span class="line" id="L2298">    <span class="tok-comment">// and ARM thus normalizes it to positive nan</span>
</span>
<span class="line" id="L2299">    <span class="tok-kw">if</span> (builtin.target.cpu.arch != .arm) {</span>
<span class="line" id="L2300">        <span class="tok-kw">try</span> expectFmt(<span class="tok-str">&quot;f64: -nan&quot;</span>, <span class="tok-str">&quot;f64: {}&quot;</span>, .{-math.nan_f64});</span>
<span class="line" id="L2301">    }</span>
<span class="line" id="L2302">    <span class="tok-kw">try</span> expectFmt(<span class="tok-str">&quot;f64: inf&quot;</span>, <span class="tok-str">&quot;f64: {}&quot;</span>, .{math.inf(<span class="tok-type">f64</span>)});</span>
<span class="line" id="L2303">    <span class="tok-kw">try</span> expectFmt(<span class="tok-str">&quot;f64: -inf&quot;</span>, <span class="tok-str">&quot;f64: {}&quot;</span>, .{-math.inf(<span class="tok-type">f64</span>)});</span>
<span class="line" id="L2304">}</span>
<span class="line" id="L2305"></span>
<span class="line" id="L2306"><span class="tok-kw">test</span> <span class="tok-str">&quot;float.hexadecimal.special&quot;</span> {</span>
<span class="line" id="L2307">    <span class="tok-kw">try</span> expectFmt(<span class="tok-str">&quot;f64: nan&quot;</span>, <span class="tok-str">&quot;f64: {x}&quot;</span>, .{math.nan_f64});</span>
<span class="line" id="L2308">    <span class="tok-comment">// negative nan is not defined by IEE 754,</span>
</span>
<span class="line" id="L2309">    <span class="tok-comment">// and ARM thus normalizes it to positive nan</span>
</span>
<span class="line" id="L2310">    <span class="tok-kw">if</span> (builtin.target.cpu.arch != .arm) {</span>
<span class="line" id="L2311">        <span class="tok-kw">try</span> expectFmt(<span class="tok-str">&quot;f64: -nan&quot;</span>, <span class="tok-str">&quot;f64: {x}&quot;</span>, .{-math.nan_f64});</span>
<span class="line" id="L2312">    }</span>
<span class="line" id="L2313">    <span class="tok-kw">try</span> expectFmt(<span class="tok-str">&quot;f64: inf&quot;</span>, <span class="tok-str">&quot;f64: {x}&quot;</span>, .{math.inf(<span class="tok-type">f64</span>)});</span>
<span class="line" id="L2314">    <span class="tok-kw">try</span> expectFmt(<span class="tok-str">&quot;f64: -inf&quot;</span>, <span class="tok-str">&quot;f64: {x}&quot;</span>, .{-math.inf(<span class="tok-type">f64</span>)});</span>
<span class="line" id="L2315"></span>
<span class="line" id="L2316">    <span class="tok-kw">try</span> expectFmt(<span class="tok-str">&quot;f64: 0x0.0p0&quot;</span>, <span class="tok-str">&quot;f64: {x}&quot;</span>, .{<span class="tok-builtin">@as</span>(<span class="tok-type">f64</span>, <span class="tok-number">0</span>)});</span>
<span class="line" id="L2317">    <span class="tok-kw">try</span> expectFmt(<span class="tok-str">&quot;f64: -0x0.0p0&quot;</span>, <span class="tok-str">&quot;f64: {x}&quot;</span>, .{-<span class="tok-builtin">@as</span>(<span class="tok-type">f64</span>, <span class="tok-number">0</span>)});</span>
<span class="line" id="L2318">}</span>
<span class="line" id="L2319"></span>
<span class="line" id="L2320"><span class="tok-kw">test</span> <span class="tok-str">&quot;float.hexadecimal&quot;</span> {</span>
<span class="line" id="L2321">    <span class="tok-kw">try</span> expectFmt(<span class="tok-str">&quot;f16: 0x1.554p-2&quot;</span>, <span class="tok-str">&quot;f16: {x}&quot;</span>, .{<span class="tok-builtin">@as</span>(<span class="tok-type">f16</span>, <span class="tok-number">1.0</span> / <span class="tok-number">3.0</span>)});</span>
<span class="line" id="L2322">    <span class="tok-kw">try</span> expectFmt(<span class="tok-str">&quot;f32: 0x1.555556p-2&quot;</span>, <span class="tok-str">&quot;f32: {x}&quot;</span>, .{<span class="tok-builtin">@as</span>(<span class="tok-type">f32</span>, <span class="tok-number">1.0</span> / <span class="tok-number">3.0</span>)});</span>
<span class="line" id="L2323">    <span class="tok-kw">try</span> expectFmt(<span class="tok-str">&quot;f64: 0x1.5555555555555p-2&quot;</span>, <span class="tok-str">&quot;f64: {x}&quot;</span>, .{<span class="tok-builtin">@as</span>(<span class="tok-type">f64</span>, <span class="tok-number">1.0</span> / <span class="tok-number">3.0</span>)});</span>
<span class="line" id="L2324">    <span class="tok-kw">try</span> expectFmt(<span class="tok-str">&quot;f128: 0x1.5555555555555555555555555555p-2&quot;</span>, <span class="tok-str">&quot;f128: {x}&quot;</span>, .{<span class="tok-builtin">@as</span>(<span class="tok-type">f128</span>, <span class="tok-number">1.0</span> / <span class="tok-number">3.0</span>)});</span>
<span class="line" id="L2325"></span>
<span class="line" id="L2326">    <span class="tok-kw">try</span> expectFmt(<span class="tok-str">&quot;f16: 0x1p-14&quot;</span>, <span class="tok-str">&quot;f16: {x}&quot;</span>, .{math.floatMin(<span class="tok-type">f16</span>)});</span>
<span class="line" id="L2327">    <span class="tok-kw">try</span> expectFmt(<span class="tok-str">&quot;f32: 0x1p-126&quot;</span>, <span class="tok-str">&quot;f32: {x}&quot;</span>, .{math.floatMin(<span class="tok-type">f32</span>)});</span>
<span class="line" id="L2328">    <span class="tok-kw">try</span> expectFmt(<span class="tok-str">&quot;f64: 0x1p-1022&quot;</span>, <span class="tok-str">&quot;f64: {x}&quot;</span>, .{math.floatMin(<span class="tok-type">f64</span>)});</span>
<span class="line" id="L2329">    <span class="tok-kw">try</span> expectFmt(<span class="tok-str">&quot;f128: 0x1p-16382&quot;</span>, <span class="tok-str">&quot;f128: {x}&quot;</span>, .{math.floatMin(<span class="tok-type">f128</span>)});</span>
<span class="line" id="L2330"></span>
<span class="line" id="L2331">    <span class="tok-kw">try</span> expectFmt(<span class="tok-str">&quot;f16: 0x0.004p-14&quot;</span>, <span class="tok-str">&quot;f16: {x}&quot;</span>, .{math.floatTrueMin(<span class="tok-type">f16</span>)});</span>
<span class="line" id="L2332">    <span class="tok-kw">try</span> expectFmt(<span class="tok-str">&quot;f32: 0x0.000002p-126&quot;</span>, <span class="tok-str">&quot;f32: {x}&quot;</span>, .{math.floatTrueMin(<span class="tok-type">f32</span>)});</span>
<span class="line" id="L2333">    <span class="tok-kw">try</span> expectFmt(<span class="tok-str">&quot;f64: 0x0.0000000000001p-1022&quot;</span>, <span class="tok-str">&quot;f64: {x}&quot;</span>, .{math.floatTrueMin(<span class="tok-type">f64</span>)});</span>
<span class="line" id="L2334">    <span class="tok-kw">try</span> expectFmt(<span class="tok-str">&quot;f128: 0x0.0000000000000000000000000001p-16382&quot;</span>, <span class="tok-str">&quot;f128: {x}&quot;</span>, .{math.floatTrueMin(<span class="tok-type">f128</span>)});</span>
<span class="line" id="L2335"></span>
<span class="line" id="L2336">    <span class="tok-kw">try</span> expectFmt(<span class="tok-str">&quot;f16: 0x1.ffcp15&quot;</span>, <span class="tok-str">&quot;f16: {x}&quot;</span>, .{math.floatMax(<span class="tok-type">f16</span>)});</span>
<span class="line" id="L2337">    <span class="tok-kw">try</span> expectFmt(<span class="tok-str">&quot;f32: 0x1.fffffep127&quot;</span>, <span class="tok-str">&quot;f32: {x}&quot;</span>, .{math.floatMax(<span class="tok-type">f32</span>)});</span>
<span class="line" id="L2338">    <span class="tok-kw">try</span> expectFmt(<span class="tok-str">&quot;f64: 0x1.fffffffffffffp1023&quot;</span>, <span class="tok-str">&quot;f64: {x}&quot;</span>, .{math.floatMax(<span class="tok-type">f64</span>)});</span>
<span class="line" id="L2339">    <span class="tok-kw">try</span> expectFmt(<span class="tok-str">&quot;f128: 0x1.ffffffffffffffffffffffffffffp16383&quot;</span>, <span class="tok-str">&quot;f128: {x}&quot;</span>, .{math.floatMax(<span class="tok-type">f128</span>)});</span>
<span class="line" id="L2340">}</span>
<span class="line" id="L2341"></span>
<span class="line" id="L2342"><span class="tok-kw">test</span> <span class="tok-str">&quot;float.hexadecimal.precision&quot;</span> {</span>
<span class="line" id="L2343">    <span class="tok-kw">try</span> expectFmt(<span class="tok-str">&quot;f16: 0x1.5p-2&quot;</span>, <span class="tok-str">&quot;f16: {x:.1}&quot;</span>, .{<span class="tok-builtin">@as</span>(<span class="tok-type">f16</span>, <span class="tok-number">1.0</span> / <span class="tok-number">3.0</span>)});</span>
<span class="line" id="L2344">    <span class="tok-kw">try</span> expectFmt(<span class="tok-str">&quot;f32: 0x1.555p-2&quot;</span>, <span class="tok-str">&quot;f32: {x:.3}&quot;</span>, .{<span class="tok-builtin">@as</span>(<span class="tok-type">f32</span>, <span class="tok-number">1.0</span> / <span class="tok-number">3.0</span>)});</span>
<span class="line" id="L2345">    <span class="tok-kw">try</span> expectFmt(<span class="tok-str">&quot;f64: 0x1.55555p-2&quot;</span>, <span class="tok-str">&quot;f64: {x:.5}&quot;</span>, .{<span class="tok-builtin">@as</span>(<span class="tok-type">f64</span>, <span class="tok-number">1.0</span> / <span class="tok-number">3.0</span>)});</span>
<span class="line" id="L2346">    <span class="tok-kw">try</span> expectFmt(<span class="tok-str">&quot;f128: 0x1.5555555p-2&quot;</span>, <span class="tok-str">&quot;f128: {x:.7}&quot;</span>, .{<span class="tok-builtin">@as</span>(<span class="tok-type">f128</span>, <span class="tok-number">1.0</span> / <span class="tok-number">3.0</span>)});</span>
<span class="line" id="L2347"></span>
<span class="line" id="L2348">    <span class="tok-kw">try</span> expectFmt(<span class="tok-str">&quot;f16: 0x1.00000p0&quot;</span>, <span class="tok-str">&quot;f16: {x:.5}&quot;</span>, .{<span class="tok-builtin">@as</span>(<span class="tok-type">f16</span>, <span class="tok-number">1.0</span>)});</span>
<span class="line" id="L2349">    <span class="tok-kw">try</span> expectFmt(<span class="tok-str">&quot;f32: 0x1.00000p0&quot;</span>, <span class="tok-str">&quot;f32: {x:.5}&quot;</span>, .{<span class="tok-builtin">@as</span>(<span class="tok-type">f32</span>, <span class="tok-number">1.0</span>)});</span>
<span class="line" id="L2350">    <span class="tok-kw">try</span> expectFmt(<span class="tok-str">&quot;f64: 0x1.00000p0&quot;</span>, <span class="tok-str">&quot;f64: {x:.5}&quot;</span>, .{<span class="tok-builtin">@as</span>(<span class="tok-type">f64</span>, <span class="tok-number">1.0</span>)});</span>
<span class="line" id="L2351">    <span class="tok-kw">try</span> expectFmt(<span class="tok-str">&quot;f128: 0x1.00000p0&quot;</span>, <span class="tok-str">&quot;f128: {x:.5}&quot;</span>, .{<span class="tok-builtin">@as</span>(<span class="tok-type">f128</span>, <span class="tok-number">1.0</span>)});</span>
<span class="line" id="L2352">}</span>
<span class="line" id="L2353"></span>
<span class="line" id="L2354"><span class="tok-kw">test</span> <span class="tok-str">&quot;float.decimal&quot;</span> {</span>
<span class="line" id="L2355">    <span class="tok-kw">try</span> expectFmt(<span class="tok-str">&quot;f64: 152314000000000000000000000000&quot;</span>, <span class="tok-str">&quot;f64: {d}&quot;</span>, .{<span class="tok-builtin">@as</span>(<span class="tok-type">f64</span>, <span class="tok-number">1.52314e+29</span>)});</span>
<span class="line" id="L2356">    <span class="tok-kw">try</span> expectFmt(<span class="tok-str">&quot;f32: 0&quot;</span>, <span class="tok-str">&quot;f32: {d}&quot;</span>, .{<span class="tok-builtin">@as</span>(<span class="tok-type">f32</span>, <span class="tok-number">0.0</span>)});</span>
<span class="line" id="L2357">    <span class="tok-kw">try</span> expectFmt(<span class="tok-str">&quot;f32: 0&quot;</span>, <span class="tok-str">&quot;f32: {d:.0}&quot;</span>, .{<span class="tok-builtin">@as</span>(<span class="tok-type">f32</span>, <span class="tok-number">0.0</span>)});</span>
<span class="line" id="L2358">    <span class="tok-kw">try</span> expectFmt(<span class="tok-str">&quot;f32: 1.1&quot;</span>, <span class="tok-str">&quot;f32: {d:.1}&quot;</span>, .{<span class="tok-builtin">@as</span>(<span class="tok-type">f32</span>, <span class="tok-number">1.1234</span>)});</span>
<span class="line" id="L2359">    <span class="tok-kw">try</span> expectFmt(<span class="tok-str">&quot;f32: 1234.57&quot;</span>, <span class="tok-str">&quot;f32: {d:.2}&quot;</span>, .{<span class="tok-builtin">@as</span>(<span class="tok-type">f32</span>, <span class="tok-number">1234.567</span>)});</span>
<span class="line" id="L2360">    <span class="tok-comment">// -11.1234 is converted to f64 -11.12339... internally (errol3() function takes f64).</span>
</span>
<span class="line" id="L2361">    <span class="tok-comment">// -11.12339... is rounded back up to -11.1234</span>
</span>
<span class="line" id="L2362">    <span class="tok-kw">try</span> expectFmt(<span class="tok-str">&quot;f32: -11.1234&quot;</span>, <span class="tok-str">&quot;f32: {d:.4}&quot;</span>, .{<span class="tok-builtin">@as</span>(<span class="tok-type">f32</span>, -<span class="tok-number">11.1234</span>)});</span>
<span class="line" id="L2363">    <span class="tok-kw">try</span> expectFmt(<span class="tok-str">&quot;f32: 91.12345&quot;</span>, <span class="tok-str">&quot;f32: {d:.5}&quot;</span>, .{<span class="tok-builtin">@as</span>(<span class="tok-type">f32</span>, <span class="tok-number">91.12345</span>)});</span>
<span class="line" id="L2364">    <span class="tok-kw">try</span> expectFmt(<span class="tok-str">&quot;f64: 91.1234567890&quot;</span>, <span class="tok-str">&quot;f64: {d:.10}&quot;</span>, .{<span class="tok-builtin">@as</span>(<span class="tok-type">f64</span>, <span class="tok-number">91.12345678901235</span>)});</span>
<span class="line" id="L2365">    <span class="tok-kw">try</span> expectFmt(<span class="tok-str">&quot;f64: 0.00000&quot;</span>, <span class="tok-str">&quot;f64: {d:.5}&quot;</span>, .{<span class="tok-builtin">@as</span>(<span class="tok-type">f64</span>, <span class="tok-number">0.0</span>)});</span>
<span class="line" id="L2366">    <span class="tok-kw">try</span> expectFmt(<span class="tok-str">&quot;f64: 6&quot;</span>, <span class="tok-str">&quot;f64: {d:.0}&quot;</span>, .{<span class="tok-builtin">@as</span>(<span class="tok-type">f64</span>, <span class="tok-number">5.700</span>)});</span>
<span class="line" id="L2367">    <span class="tok-kw">try</span> expectFmt(<span class="tok-str">&quot;f64: 10.0&quot;</span>, <span class="tok-str">&quot;f64: {d:.1}&quot;</span>, .{<span class="tok-builtin">@as</span>(<span class="tok-type">f64</span>, <span class="tok-number">9.999</span>)});</span>
<span class="line" id="L2368">    <span class="tok-kw">try</span> expectFmt(<span class="tok-str">&quot;f64: 1.000&quot;</span>, <span class="tok-str">&quot;f64: {d:.3}&quot;</span>, .{<span class="tok-builtin">@as</span>(<span class="tok-type">f64</span>, <span class="tok-number">1.0</span>)});</span>
<span class="line" id="L2369">    <span class="tok-kw">try</span> expectFmt(<span class="tok-str">&quot;f64: 0.00030000&quot;</span>, <span class="tok-str">&quot;f64: {d:.8}&quot;</span>, .{<span class="tok-builtin">@as</span>(<span class="tok-type">f64</span>, <span class="tok-number">0.0003</span>)});</span>
<span class="line" id="L2370">    <span class="tok-kw">try</span> expectFmt(<span class="tok-str">&quot;f64: 0.00000&quot;</span>, <span class="tok-str">&quot;f64: {d:.5}&quot;</span>, .{<span class="tok-builtin">@as</span>(<span class="tok-type">f64</span>, <span class="tok-number">1.40130e-45</span>)});</span>
<span class="line" id="L2371">    <span class="tok-kw">try</span> expectFmt(<span class="tok-str">&quot;f64: 0.00000&quot;</span>, <span class="tok-str">&quot;f64: {d:.5}&quot;</span>, .{<span class="tok-builtin">@as</span>(<span class="tok-type">f64</span>, <span class="tok-number">9.999960e-40</span>)});</span>
<span class="line" id="L2372">    <span class="tok-kw">try</span> expectFmt(<span class="tok-str">&quot;f64: 10000000000000.00&quot;</span>, <span class="tok-str">&quot;f64: {d:.2}&quot;</span>, .{<span class="tok-builtin">@as</span>(<span class="tok-type">f64</span>, <span class="tok-number">9999999999999.999</span>)});</span>
<span class="line" id="L2373">    <span class="tok-kw">try</span> expectFmt(<span class="tok-str">&quot;f64: 10000000000000000000000000000000000000&quot;</span>, <span class="tok-str">&quot;f64: {d}&quot;</span>, .{<span class="tok-builtin">@as</span>(<span class="tok-type">f64</span>, <span class="tok-number">1e37</span>)});</span>
<span class="line" id="L2374">    <span class="tok-kw">try</span> expectFmt(<span class="tok-str">&quot;f64: 100000000000000000000000000000000000000&quot;</span>, <span class="tok-str">&quot;f64: {d}&quot;</span>, .{<span class="tok-builtin">@as</span>(<span class="tok-type">f64</span>, <span class="tok-number">1e38</span>)});</span>
<span class="line" id="L2375">}</span>
<span class="line" id="L2376"></span>
<span class="line" id="L2377"><span class="tok-kw">test</span> <span class="tok-str">&quot;float.libc.sanity&quot;</span> {</span>
<span class="line" id="L2378">    <span class="tok-kw">try</span> expectFmt(<span class="tok-str">&quot;f64: 0.00001&quot;</span>, <span class="tok-str">&quot;f64: {d:.5}&quot;</span>, .{<span class="tok-builtin">@as</span>(<span class="tok-type">f64</span>, <span class="tok-builtin">@bitCast</span>(<span class="tok-type">f32</span>, <span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">916964781</span>)))});</span>
<span class="line" id="L2379">    <span class="tok-kw">try</span> expectFmt(<span class="tok-str">&quot;f64: 0.00001&quot;</span>, <span class="tok-str">&quot;f64: {d:.5}&quot;</span>, .{<span class="tok-builtin">@as</span>(<span class="tok-type">f64</span>, <span class="tok-builtin">@bitCast</span>(<span class="tok-type">f32</span>, <span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">925353389</span>)))});</span>
<span class="line" id="L2380">    <span class="tok-kw">try</span> expectFmt(<span class="tok-str">&quot;f64: 0.10000&quot;</span>, <span class="tok-str">&quot;f64: {d:.5}&quot;</span>, .{<span class="tok-builtin">@as</span>(<span class="tok-type">f64</span>, <span class="tok-builtin">@bitCast</span>(<span class="tok-type">f32</span>, <span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">1036831278</span>)))});</span>
<span class="line" id="L2381">    <span class="tok-kw">try</span> expectFmt(<span class="tok-str">&quot;f64: 1.00000&quot;</span>, <span class="tok-str">&quot;f64: {d:.5}&quot;</span>, .{<span class="tok-builtin">@as</span>(<span class="tok-type">f64</span>, <span class="tok-builtin">@bitCast</span>(<span class="tok-type">f32</span>, <span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">1065353133</span>)))});</span>
<span class="line" id="L2382">    <span class="tok-kw">try</span> expectFmt(<span class="tok-str">&quot;f64: 10.00000&quot;</span>, <span class="tok-str">&quot;f64: {d:.5}&quot;</span>, .{<span class="tok-builtin">@as</span>(<span class="tok-type">f64</span>, <span class="tok-builtin">@bitCast</span>(<span class="tok-type">f32</span>, <span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">1092616192</span>)))});</span>
<span class="line" id="L2383"></span>
<span class="line" id="L2384">    <span class="tok-comment">// libc differences</span>
</span>
<span class="line" id="L2385">    <span class="tok-comment">//</span>
</span>
<span class="line" id="L2386">    <span class="tok-comment">// This is 0.015625 exactly according to gdb. We thus round down,</span>
</span>
<span class="line" id="L2387">    <span class="tok-comment">// however glibc rounds up for some reason. This occurs for all</span>
</span>
<span class="line" id="L2388">    <span class="tok-comment">// floats of the form x.yyyy25 on a precision point.</span>
</span>
<span class="line" id="L2389">    <span class="tok-kw">try</span> expectFmt(<span class="tok-str">&quot;f64: 0.01563&quot;</span>, <span class="tok-str">&quot;f64: {d:.5}&quot;</span>, .{<span class="tok-builtin">@as</span>(<span class="tok-type">f64</span>, <span class="tok-builtin">@bitCast</span>(<span class="tok-type">f32</span>, <span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">1015021568</span>)))});</span>
<span class="line" id="L2390">    <span class="tok-comment">// errol3 rounds to ... 630 but libc rounds to ...632. Grisu3</span>
</span>
<span class="line" id="L2391">    <span class="tok-comment">// also rounds to 630 so I'm inclined to believe libc is not</span>
</span>
<span class="line" id="L2392">    <span class="tok-comment">// optimal here.</span>
</span>
<span class="line" id="L2393">    <span class="tok-kw">try</span> expectFmt(<span class="tok-str">&quot;f64: 18014400656965630.00000&quot;</span>, <span class="tok-str">&quot;f64: {d:.5}&quot;</span>, .{<span class="tok-builtin">@as</span>(<span class="tok-type">f64</span>, <span class="tok-builtin">@bitCast</span>(<span class="tok-type">f32</span>, <span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">1518338049</span>)))});</span>
<span class="line" id="L2394">}</span>
<span class="line" id="L2395"></span>
<span class="line" id="L2396"><span class="tok-kw">test</span> <span class="tok-str">&quot;custom&quot;</span> {</span>
<span class="line" id="L2397">    <span class="tok-kw">const</span> Vec2 = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L2398">        <span class="tok-kw">const</span> SelfType = <span class="tok-builtin">@This</span>();</span>
<span class="line" id="L2399">        x: <span class="tok-type">f32</span>,</span>
<span class="line" id="L2400">        y: <span class="tok-type">f32</span>,</span>
<span class="line" id="L2401"></span>
<span class="line" id="L2402">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">format</span>(</span>
<span class="line" id="L2403">            self: SelfType,</span>
<span class="line" id="L2404">            <span class="tok-kw">comptime</span> fmt: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L2405">            options: FormatOptions,</span>
<span class="line" id="L2406">            writer: <span class="tok-kw">anytype</span>,</span>
<span class="line" id="L2407">        ) !<span class="tok-type">void</span> {</span>
<span class="line" id="L2408">            _ = options;</span>
<span class="line" id="L2409">            <span class="tok-kw">if</span> (fmt.len == <span class="tok-number">0</span> <span class="tok-kw">or</span> <span class="tok-kw">comptime</span> std.mem.eql(<span class="tok-type">u8</span>, fmt, <span class="tok-str">&quot;p&quot;</span>)) {</span>
<span class="line" id="L2410">                <span class="tok-kw">return</span> std.fmt.format(writer, <span class="tok-str">&quot;({d:.3},{d:.3})&quot;</span>, .{ self.x, self.y });</span>
<span class="line" id="L2411">            } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (<span class="tok-kw">comptime</span> std.mem.eql(<span class="tok-type">u8</span>, fmt, <span class="tok-str">&quot;d&quot;</span>)) {</span>
<span class="line" id="L2412">                <span class="tok-kw">return</span> std.fmt.format(writer, <span class="tok-str">&quot;{d:.3}x{d:.3}&quot;</span>, .{ self.x, self.y });</span>
<span class="line" id="L2413">            } <span class="tok-kw">else</span> {</span>
<span class="line" id="L2414">                <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;unknown format character: '&quot;</span> ++ fmt ++ <span class="tok-str">&quot;'&quot;</span>);</span>
<span class="line" id="L2415">            }</span>
<span class="line" id="L2416">        }</span>
<span class="line" id="L2417">    };</span>
<span class="line" id="L2418"></span>
<span class="line" id="L2419">    <span class="tok-kw">var</span> value = Vec2{</span>
<span class="line" id="L2420">        .x = <span class="tok-number">10.2</span>,</span>
<span class="line" id="L2421">        .y = <span class="tok-number">2.22</span>,</span>
<span class="line" id="L2422">    };</span>
<span class="line" id="L2423">    <span class="tok-kw">try</span> expectFmt(<span class="tok-str">&quot;point: (10.200,2.220)\n&quot;</span>, <span class="tok-str">&quot;point: {}\n&quot;</span>, .{&amp;value});</span>
<span class="line" id="L2424">    <span class="tok-kw">try</span> expectFmt(<span class="tok-str">&quot;dim: 10.200x2.220\n&quot;</span>, <span class="tok-str">&quot;dim: {d}\n&quot;</span>, .{&amp;value});</span>
<span class="line" id="L2425"></span>
<span class="line" id="L2426">    <span class="tok-comment">// same thing but not passing a pointer</span>
</span>
<span class="line" id="L2427">    <span class="tok-kw">try</span> expectFmt(<span class="tok-str">&quot;point: (10.200,2.220)\n&quot;</span>, <span class="tok-str">&quot;point: {}\n&quot;</span>, .{value});</span>
<span class="line" id="L2428">    <span class="tok-kw">try</span> expectFmt(<span class="tok-str">&quot;dim: 10.200x2.220\n&quot;</span>, <span class="tok-str">&quot;dim: {d}\n&quot;</span>, .{value});</span>
<span class="line" id="L2429">}</span>
<span class="line" id="L2430"></span>
<span class="line" id="L2431"><span class="tok-kw">test</span> <span class="tok-str">&quot;struct&quot;</span> {</span>
<span class="line" id="L2432">    <span class="tok-kw">if</span> (builtin.zig_backend == .stage1) {</span>
<span class="line" id="L2433">        <span class="tok-comment">// stage1 fails to return fully qualified namespaces.</span>
</span>
<span class="line" id="L2434">        <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SkipZigTest;</span>
<span class="line" id="L2435">    }</span>
<span class="line" id="L2436">    <span class="tok-kw">const</span> S = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L2437">        a: <span class="tok-type">u32</span>,</span>
<span class="line" id="L2438">        b: <span class="tok-type">anyerror</span>,</span>
<span class="line" id="L2439">    };</span>
<span class="line" id="L2440"></span>
<span class="line" id="L2441">    <span class="tok-kw">const</span> inst = S{</span>
<span class="line" id="L2442">        .a = <span class="tok-number">456</span>,</span>
<span class="line" id="L2443">        .b = <span class="tok-kw">error</span>.Unused,</span>
<span class="line" id="L2444">    };</span>
<span class="line" id="L2445"></span>
<span class="line" id="L2446">    <span class="tok-kw">try</span> expectFmt(<span class="tok-str">&quot;fmt.test.struct.S{ .a = 456, .b = error.Unused }&quot;</span>, <span class="tok-str">&quot;{}&quot;</span>, .{inst});</span>
<span class="line" id="L2447">    <span class="tok-comment">// Tuples</span>
</span>
<span class="line" id="L2448">    <span class="tok-kw">try</span> expectFmt(<span class="tok-str">&quot;{ }&quot;</span>, <span class="tok-str">&quot;{}&quot;</span>, .{.{}});</span>
<span class="line" id="L2449">    <span class="tok-kw">try</span> expectFmt(<span class="tok-str">&quot;{ -1 }&quot;</span>, <span class="tok-str">&quot;{}&quot;</span>, .{.{-<span class="tok-number">1</span>}});</span>
<span class="line" id="L2450">    <span class="tok-kw">try</span> expectFmt(<span class="tok-str">&quot;{ -1, 42, 2.5e+04 }&quot;</span>, <span class="tok-str">&quot;{}&quot;</span>, .{.{ -<span class="tok-number">1</span>, <span class="tok-number">42</span>, <span class="tok-number">0.25e5</span> }});</span>
<span class="line" id="L2451">}</span>
<span class="line" id="L2452"></span>
<span class="line" id="L2453"><span class="tok-kw">test</span> <span class="tok-str">&quot;union&quot;</span> {</span>
<span class="line" id="L2454">    <span class="tok-kw">if</span> (builtin.zig_backend == .stage1) {</span>
<span class="line" id="L2455">        <span class="tok-comment">// stage1 fails to return fully qualified namespaces.</span>
</span>
<span class="line" id="L2456">        <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SkipZigTest;</span>
<span class="line" id="L2457">    }</span>
<span class="line" id="L2458">    <span class="tok-kw">const</span> TU = <span class="tok-kw">union</span>(<span class="tok-kw">enum</span>) {</span>
<span class="line" id="L2459">        float: <span class="tok-type">f32</span>,</span>
<span class="line" id="L2460">        int: <span class="tok-type">u32</span>,</span>
<span class="line" id="L2461">    };</span>
<span class="line" id="L2462"></span>
<span class="line" id="L2463">    <span class="tok-kw">const</span> UU = <span class="tok-kw">union</span> {</span>
<span class="line" id="L2464">        float: <span class="tok-type">f32</span>,</span>
<span class="line" id="L2465">        int: <span class="tok-type">u32</span>,</span>
<span class="line" id="L2466">    };</span>
<span class="line" id="L2467"></span>
<span class="line" id="L2468">    <span class="tok-kw">const</span> EU = <span class="tok-kw">extern</span> <span class="tok-kw">union</span> {</span>
<span class="line" id="L2469">        float: <span class="tok-type">f32</span>,</span>
<span class="line" id="L2470">        int: <span class="tok-type">u32</span>,</span>
<span class="line" id="L2471">    };</span>
<span class="line" id="L2472"></span>
<span class="line" id="L2473">    <span class="tok-kw">const</span> tu_inst = TU{ .int = <span class="tok-number">123</span> };</span>
<span class="line" id="L2474">    <span class="tok-kw">const</span> uu_inst = UU{ .int = <span class="tok-number">456</span> };</span>
<span class="line" id="L2475">    <span class="tok-kw">const</span> eu_inst = EU{ .float = <span class="tok-number">321.123</span> };</span>
<span class="line" id="L2476"></span>
<span class="line" id="L2477">    <span class="tok-kw">try</span> expectFmt(<span class="tok-str">&quot;fmt.test.union.TU{ .int = 123 }&quot;</span>, <span class="tok-str">&quot;{}&quot;</span>, .{tu_inst});</span>
<span class="line" id="L2478"></span>
<span class="line" id="L2479">    <span class="tok-kw">var</span> buf: [<span class="tok-number">100</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L2480">    <span class="tok-kw">const</span> uu_result = <span class="tok-kw">try</span> bufPrint(buf[<span class="tok-number">0</span>..], <span class="tok-str">&quot;{}&quot;</span>, .{uu_inst});</span>
<span class="line" id="L2481">    <span class="tok-kw">try</span> std.testing.expect(mem.eql(<span class="tok-type">u8</span>, uu_result[<span class="tok-number">0</span>..<span class="tok-number">18</span>], <span class="tok-str">&quot;fmt.test.union.UU@&quot;</span>));</span>
<span class="line" id="L2482"></span>
<span class="line" id="L2483">    <span class="tok-kw">const</span> eu_result = <span class="tok-kw">try</span> bufPrint(buf[<span class="tok-number">0</span>..], <span class="tok-str">&quot;{}&quot;</span>, .{eu_inst});</span>
<span class="line" id="L2484">    <span class="tok-kw">try</span> std.testing.expect(mem.eql(<span class="tok-type">u8</span>, eu_result[<span class="tok-number">0</span>..<span class="tok-number">18</span>], <span class="tok-str">&quot;fmt.test.union.EU@&quot;</span>));</span>
<span class="line" id="L2485">}</span>
<span class="line" id="L2486"></span>
<span class="line" id="L2487"><span class="tok-kw">test</span> <span class="tok-str">&quot;enum&quot;</span> {</span>
<span class="line" id="L2488">    <span class="tok-kw">if</span> (builtin.zig_backend == .stage1) {</span>
<span class="line" id="L2489">        <span class="tok-comment">// stage1 fails to return fully qualified namespaces.</span>
</span>
<span class="line" id="L2490">        <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SkipZigTest;</span>
<span class="line" id="L2491">    }</span>
<span class="line" id="L2492">    <span class="tok-kw">const</span> E = <span class="tok-kw">enum</span> {</span>
<span class="line" id="L2493">        One,</span>
<span class="line" id="L2494">        Two,</span>
<span class="line" id="L2495">        Three,</span>
<span class="line" id="L2496">    };</span>
<span class="line" id="L2497"></span>
<span class="line" id="L2498">    <span class="tok-kw">const</span> inst = E.Two;</span>
<span class="line" id="L2499"></span>
<span class="line" id="L2500">    <span class="tok-kw">try</span> expectFmt(<span class="tok-str">&quot;fmt.test.enum.E.Two&quot;</span>, <span class="tok-str">&quot;{}&quot;</span>, .{inst});</span>
<span class="line" id="L2501">}</span>
<span class="line" id="L2502"></span>
<span class="line" id="L2503"><span class="tok-kw">test</span> <span class="tok-str">&quot;struct.self-referential&quot;</span> {</span>
<span class="line" id="L2504">    <span class="tok-kw">if</span> (builtin.zig_backend == .stage1) {</span>
<span class="line" id="L2505">        <span class="tok-comment">// stage1 fails to return fully qualified namespaces.</span>
</span>
<span class="line" id="L2506">        <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SkipZigTest;</span>
<span class="line" id="L2507">    }</span>
<span class="line" id="L2508">    <span class="tok-kw">const</span> S = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L2509">        <span class="tok-kw">const</span> SelfType = <span class="tok-builtin">@This</span>();</span>
<span class="line" id="L2510">        a: ?*SelfType,</span>
<span class="line" id="L2511">    };</span>
<span class="line" id="L2512"></span>
<span class="line" id="L2513">    <span class="tok-kw">var</span> inst = S{</span>
<span class="line" id="L2514">        .a = <span class="tok-null">null</span>,</span>
<span class="line" id="L2515">    };</span>
<span class="line" id="L2516">    inst.a = &amp;inst;</span>
<span class="line" id="L2517"></span>
<span class="line" id="L2518">    <span class="tok-kw">try</span> expectFmt(<span class="tok-str">&quot;fmt.test.struct.self-referential.S{ .a = fmt.test.struct.self-referential.S{ .a = fmt.test.struct.self-referential.S{ .a = fmt.test.struct.self-referential.S{ ... } } } }&quot;</span>, <span class="tok-str">&quot;{}&quot;</span>, .{inst});</span>
<span class="line" id="L2519">}</span>
<span class="line" id="L2520"></span>
<span class="line" id="L2521"><span class="tok-kw">test</span> <span class="tok-str">&quot;struct.zero-size&quot;</span> {</span>
<span class="line" id="L2522">    <span class="tok-kw">if</span> (builtin.zig_backend == .stage1) {</span>
<span class="line" id="L2523">        <span class="tok-comment">// stage1 fails to return fully qualified namespaces.</span>
</span>
<span class="line" id="L2524">        <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SkipZigTest;</span>
<span class="line" id="L2525">    }</span>
<span class="line" id="L2526">    <span class="tok-kw">const</span> A = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L2527">        <span class="tok-kw">fn</span> <span class="tok-fn">foo</span>() <span class="tok-type">void</span> {}</span>
<span class="line" id="L2528">    };</span>
<span class="line" id="L2529">    <span class="tok-kw">const</span> B = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L2530">        a: A,</span>
<span class="line" id="L2531">        c: <span class="tok-type">i32</span>,</span>
<span class="line" id="L2532">    };</span>
<span class="line" id="L2533"></span>
<span class="line" id="L2534">    <span class="tok-kw">const</span> a = A{};</span>
<span class="line" id="L2535">    <span class="tok-kw">const</span> b = B{ .a = a, .c = <span class="tok-number">0</span> };</span>
<span class="line" id="L2536"></span>
<span class="line" id="L2537">    <span class="tok-kw">try</span> expectFmt(<span class="tok-str">&quot;fmt.test.struct.zero-size.B{ .a = fmt.test.struct.zero-size.A{ }, .c = 0 }&quot;</span>, <span class="tok-str">&quot;{}&quot;</span>, .{b});</span>
<span class="line" id="L2538">}</span>
<span class="line" id="L2539"></span>
<span class="line" id="L2540"><span class="tok-kw">test</span> <span class="tok-str">&quot;bytes.hex&quot;</span> {</span>
<span class="line" id="L2541">    <span class="tok-kw">const</span> some_bytes = <span class="tok-str">&quot;\xCA\xFE\xBA\xBE&quot;</span>;</span>
<span class="line" id="L2542">    <span class="tok-kw">try</span> expectFmt(<span class="tok-str">&quot;lowercase: cafebabe\n&quot;</span>, <span class="tok-str">&quot;lowercase: {x}\n&quot;</span>, .{fmtSliceHexLower(some_bytes)});</span>
<span class="line" id="L2543">    <span class="tok-kw">try</span> expectFmt(<span class="tok-str">&quot;uppercase: CAFEBABE\n&quot;</span>, <span class="tok-str">&quot;uppercase: {X}\n&quot;</span>, .{fmtSliceHexUpper(some_bytes)});</span>
<span class="line" id="L2544">    <span class="tok-comment">//Test Slices</span>
</span>
<span class="line" id="L2545">    <span class="tok-kw">try</span> expectFmt(<span class="tok-str">&quot;uppercase: CAFE\n&quot;</span>, <span class="tok-str">&quot;uppercase: {X}\n&quot;</span>, .{fmtSliceHexUpper(some_bytes[<span class="tok-number">0</span>..<span class="tok-number">2</span>])});</span>
<span class="line" id="L2546">    <span class="tok-kw">try</span> expectFmt(<span class="tok-str">&quot;lowercase: babe\n&quot;</span>, <span class="tok-str">&quot;lowercase: {x}\n&quot;</span>, .{fmtSliceHexLower(some_bytes[<span class="tok-number">2</span>..])});</span>
<span class="line" id="L2547">    <span class="tok-kw">const</span> bytes_with_zeros = <span class="tok-str">&quot;\x00\x0E\xBA\xBE&quot;</span>;</span>
<span class="line" id="L2548">    <span class="tok-kw">try</span> expectFmt(<span class="tok-str">&quot;lowercase: 000ebabe\n&quot;</span>, <span class="tok-str">&quot;lowercase: {x}\n&quot;</span>, .{fmtSliceHexLower(bytes_with_zeros)});</span>
<span class="line" id="L2549">}</span>
<span class="line" id="L2550"></span>
<span class="line" id="L2551"><span class="tok-comment">/// Decodes the sequence of bytes represented by the specified string of</span></span>
<span class="line" id="L2552"><span class="tok-comment">/// hexadecimal characters.</span></span>
<span class="line" id="L2553"><span class="tok-comment">/// Returns a slice of the output buffer containing the decoded bytes.</span></span>
<span class="line" id="L2554"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">hexToBytes</span>(out: []<span class="tok-type">u8</span>, input: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) ![]<span class="tok-type">u8</span> {</span>
<span class="line" id="L2555">    <span class="tok-comment">// Expect 0 or n pairs of hexadecimal digits.</span>
</span>
<span class="line" id="L2556">    <span class="tok-kw">if</span> (input.len &amp; <span class="tok-number">1</span> != <span class="tok-number">0</span>)</span>
<span class="line" id="L2557">        <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InvalidLength;</span>
<span class="line" id="L2558">    <span class="tok-kw">if</span> (out.len * <span class="tok-number">2</span> &lt; input.len)</span>
<span class="line" id="L2559">        <span class="tok-kw">return</span> <span class="tok-kw">error</span>.NoSpaceLeft;</span>
<span class="line" id="L2560"></span>
<span class="line" id="L2561">    <span class="tok-kw">var</span> in_i: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L2562">    <span class="tok-kw">while</span> (in_i &lt; input.len) : (in_i += <span class="tok-number">2</span>) {</span>
<span class="line" id="L2563">        <span class="tok-kw">const</span> hi = <span class="tok-kw">try</span> charToDigit(input[in_i], <span class="tok-number">16</span>);</span>
<span class="line" id="L2564">        <span class="tok-kw">const</span> lo = <span class="tok-kw">try</span> charToDigit(input[in_i + <span class="tok-number">1</span>], <span class="tok-number">16</span>);</span>
<span class="line" id="L2565">        out[in_i / <span class="tok-number">2</span>] = (hi &lt;&lt; <span class="tok-number">4</span>) | lo;</span>
<span class="line" id="L2566">    }</span>
<span class="line" id="L2567"></span>
<span class="line" id="L2568">    <span class="tok-kw">return</span> out[<span class="tok-number">0</span> .. in_i / <span class="tok-number">2</span>];</span>
<span class="line" id="L2569">}</span>
<span class="line" id="L2570"></span>
<span class="line" id="L2571"><span class="tok-kw">test</span> <span class="tok-str">&quot;hexToBytes&quot;</span> {</span>
<span class="line" id="L2572">    <span class="tok-kw">var</span> buf: [<span class="tok-number">32</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L2573">    <span class="tok-kw">try</span> expectFmt(<span class="tok-str">&quot;90&quot;</span> ** <span class="tok-number">32</span>, <span class="tok-str">&quot;{s}&quot;</span>, .{fmtSliceHexUpper(<span class="tok-kw">try</span> hexToBytes(&amp;buf, <span class="tok-str">&quot;90&quot;</span> ** <span class="tok-number">32</span>))});</span>
<span class="line" id="L2574">    <span class="tok-kw">try</span> expectFmt(<span class="tok-str">&quot;ABCD&quot;</span>, <span class="tok-str">&quot;{s}&quot;</span>, .{fmtSliceHexUpper(<span class="tok-kw">try</span> hexToBytes(&amp;buf, <span class="tok-str">&quot;ABCD&quot;</span>))});</span>
<span class="line" id="L2575">    <span class="tok-kw">try</span> expectFmt(<span class="tok-str">&quot;&quot;</span>, <span class="tok-str">&quot;{s}&quot;</span>, .{fmtSliceHexUpper(<span class="tok-kw">try</span> hexToBytes(&amp;buf, <span class="tok-str">&quot;&quot;</span>))});</span>
<span class="line" id="L2576">    <span class="tok-kw">try</span> std.testing.expectError(<span class="tok-kw">error</span>.InvalidCharacter, hexToBytes(&amp;buf, <span class="tok-str">&quot;012Z&quot;</span>));</span>
<span class="line" id="L2577">    <span class="tok-kw">try</span> std.testing.expectError(<span class="tok-kw">error</span>.InvalidLength, hexToBytes(&amp;buf, <span class="tok-str">&quot;AAA&quot;</span>));</span>
<span class="line" id="L2578">    <span class="tok-kw">try</span> std.testing.expectError(<span class="tok-kw">error</span>.NoSpaceLeft, hexToBytes(buf[<span class="tok-number">0</span>..<span class="tok-number">1</span>], <span class="tok-str">&quot;ABAB&quot;</span>));</span>
<span class="line" id="L2579">}</span>
<span class="line" id="L2580"></span>
<span class="line" id="L2581"><span class="tok-kw">test</span> <span class="tok-str">&quot;formatIntValue with comptime_int&quot;</span> {</span>
<span class="line" id="L2582">    <span class="tok-kw">const</span> value: <span class="tok-type">comptime_int</span> = <span class="tok-number">123456789123456789</span>;</span>
<span class="line" id="L2583"></span>
<span class="line" id="L2584">    <span class="tok-kw">var</span> buf: [<span class="tok-number">20</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L2585">    <span class="tok-kw">var</span> fbs = std.io.fixedBufferStream(&amp;buf);</span>
<span class="line" id="L2586">    <span class="tok-kw">try</span> formatIntValue(value, <span class="tok-str">&quot;&quot;</span>, FormatOptions{}, fbs.writer());</span>
<span class="line" id="L2587">    <span class="tok-kw">try</span> std.testing.expect(mem.eql(<span class="tok-type">u8</span>, fbs.getWritten(), <span class="tok-str">&quot;123456789123456789&quot;</span>));</span>
<span class="line" id="L2588">}</span>
<span class="line" id="L2589"></span>
<span class="line" id="L2590"><span class="tok-kw">test</span> <span class="tok-str">&quot;formatFloatValue with comptime_float&quot;</span> {</span>
<span class="line" id="L2591">    <span class="tok-kw">const</span> value: <span class="tok-type">comptime_float</span> = <span class="tok-number">1.0</span>;</span>
<span class="line" id="L2592"></span>
<span class="line" id="L2593">    <span class="tok-kw">var</span> buf: [<span class="tok-number">20</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L2594">    <span class="tok-kw">var</span> fbs = std.io.fixedBufferStream(&amp;buf);</span>
<span class="line" id="L2595">    <span class="tok-kw">try</span> formatFloatValue(value, <span class="tok-str">&quot;&quot;</span>, FormatOptions{}, fbs.writer());</span>
<span class="line" id="L2596">    <span class="tok-kw">try</span> std.testing.expect(mem.eql(<span class="tok-type">u8</span>, fbs.getWritten(), <span class="tok-str">&quot;1.0e+00&quot;</span>));</span>
<span class="line" id="L2597"></span>
<span class="line" id="L2598">    <span class="tok-kw">try</span> expectFmt(<span class="tok-str">&quot;1.0e+00&quot;</span>, <span class="tok-str">&quot;{}&quot;</span>, .{value});</span>
<span class="line" id="L2599">    <span class="tok-kw">try</span> expectFmt(<span class="tok-str">&quot;1.0e+00&quot;</span>, <span class="tok-str">&quot;{}&quot;</span>, .{<span class="tok-number">1.0</span>});</span>
<span class="line" id="L2600">}</span>
<span class="line" id="L2601"></span>
<span class="line" id="L2602"><span class="tok-kw">test</span> <span class="tok-str">&quot;formatType max_depth&quot;</span> {</span>
<span class="line" id="L2603">    <span class="tok-kw">if</span> (builtin.zig_backend == .stage1) {</span>
<span class="line" id="L2604">        <span class="tok-comment">// stage1 fails to return fully qualified namespaces.</span>
</span>
<span class="line" id="L2605">        <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SkipZigTest;</span>
<span class="line" id="L2606">    }</span>
<span class="line" id="L2607">    <span class="tok-kw">const</span> Vec2 = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L2608">        <span class="tok-kw">const</span> SelfType = <span class="tok-builtin">@This</span>();</span>
<span class="line" id="L2609">        x: <span class="tok-type">f32</span>,</span>
<span class="line" id="L2610">        y: <span class="tok-type">f32</span>,</span>
<span class="line" id="L2611"></span>
<span class="line" id="L2612">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">format</span>(</span>
<span class="line" id="L2613">            self: SelfType,</span>
<span class="line" id="L2614">            <span class="tok-kw">comptime</span> fmt: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L2615">            options: FormatOptions,</span>
<span class="line" id="L2616">            writer: <span class="tok-kw">anytype</span>,</span>
<span class="line" id="L2617">        ) !<span class="tok-type">void</span> {</span>
<span class="line" id="L2618">            _ = options;</span>
<span class="line" id="L2619">            <span class="tok-kw">if</span> (fmt.len == <span class="tok-number">0</span>) {</span>
<span class="line" id="L2620">                <span class="tok-kw">return</span> std.fmt.format(writer, <span class="tok-str">&quot;({d:.3},{d:.3})&quot;</span>, .{ self.x, self.y });</span>
<span class="line" id="L2621">            } <span class="tok-kw">else</span> {</span>
<span class="line" id="L2622">                <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;unknown format string: '&quot;</span> ++ fmt ++ <span class="tok-str">&quot;'&quot;</span>);</span>
<span class="line" id="L2623">            }</span>
<span class="line" id="L2624">        }</span>
<span class="line" id="L2625">    };</span>
<span class="line" id="L2626">    <span class="tok-kw">const</span> E = <span class="tok-kw">enum</span> {</span>
<span class="line" id="L2627">        One,</span>
<span class="line" id="L2628">        Two,</span>
<span class="line" id="L2629">        Three,</span>
<span class="line" id="L2630">    };</span>
<span class="line" id="L2631">    <span class="tok-kw">const</span> TU = <span class="tok-kw">union</span>(<span class="tok-kw">enum</span>) {</span>
<span class="line" id="L2632">        <span class="tok-kw">const</span> SelfType = <span class="tok-builtin">@This</span>();</span>
<span class="line" id="L2633">        float: <span class="tok-type">f32</span>,</span>
<span class="line" id="L2634">        int: <span class="tok-type">u32</span>,</span>
<span class="line" id="L2635">        ptr: ?*SelfType,</span>
<span class="line" id="L2636">    };</span>
<span class="line" id="L2637">    <span class="tok-kw">const</span> S = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L2638">        <span class="tok-kw">const</span> SelfType = <span class="tok-builtin">@This</span>();</span>
<span class="line" id="L2639">        a: ?*SelfType,</span>
<span class="line" id="L2640">        tu: TU,</span>
<span class="line" id="L2641">        e: E,</span>
<span class="line" id="L2642">        vec: Vec2,</span>
<span class="line" id="L2643">    };</span>
<span class="line" id="L2644"></span>
<span class="line" id="L2645">    <span class="tok-kw">var</span> inst = S{</span>
<span class="line" id="L2646">        .a = <span class="tok-null">null</span>,</span>
<span class="line" id="L2647">        .tu = TU{ .ptr = <span class="tok-null">null</span> },</span>
<span class="line" id="L2648">        .e = E.Two,</span>
<span class="line" id="L2649">        .vec = Vec2{ .x = <span class="tok-number">10.2</span>, .y = <span class="tok-number">2.22</span> },</span>
<span class="line" id="L2650">    };</span>
<span class="line" id="L2651">    inst.a = &amp;inst;</span>
<span class="line" id="L2652">    inst.tu.ptr = &amp;inst.tu;</span>
<span class="line" id="L2653"></span>
<span class="line" id="L2654">    <span class="tok-kw">var</span> buf: [<span class="tok-number">1000</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L2655">    <span class="tok-kw">var</span> fbs = std.io.fixedBufferStream(&amp;buf);</span>
<span class="line" id="L2656">    <span class="tok-kw">try</span> formatType(inst, <span class="tok-str">&quot;&quot;</span>, FormatOptions{}, fbs.writer(), <span class="tok-number">0</span>);</span>
<span class="line" id="L2657">    <span class="tok-kw">try</span> std.testing.expect(mem.eql(<span class="tok-type">u8</span>, fbs.getWritten(), <span class="tok-str">&quot;fmt.test.formatType max_depth.S{ ... }&quot;</span>));</span>
<span class="line" id="L2658"></span>
<span class="line" id="L2659">    fbs.reset();</span>
<span class="line" id="L2660">    <span class="tok-kw">try</span> formatType(inst, <span class="tok-str">&quot;&quot;</span>, FormatOptions{}, fbs.writer(), <span class="tok-number">1</span>);</span>
<span class="line" id="L2661">    <span class="tok-kw">try</span> std.testing.expect(mem.eql(<span class="tok-type">u8</span>, fbs.getWritten(), <span class="tok-str">&quot;fmt.test.formatType max_depth.S{ .a = fmt.test.formatType max_depth.S{ ... }, .tu = fmt.test.formatType max_depth.TU{ ... }, .e = fmt.test.formatType max_depth.E.Two, .vec = (10.200,2.220) }&quot;</span>));</span>
<span class="line" id="L2662"></span>
<span class="line" id="L2663">    fbs.reset();</span>
<span class="line" id="L2664">    <span class="tok-kw">try</span> formatType(inst, <span class="tok-str">&quot;&quot;</span>, FormatOptions{}, fbs.writer(), <span class="tok-number">2</span>);</span>
<span class="line" id="L2665">    <span class="tok-kw">try</span> std.testing.expect(mem.eql(<span class="tok-type">u8</span>, fbs.getWritten(), <span class="tok-str">&quot;fmt.test.formatType max_depth.S{ .a = fmt.test.formatType max_depth.S{ .a = fmt.test.formatType max_depth.S{ ... }, .tu = fmt.test.formatType max_depth.TU{ ... }, .e = fmt.test.formatType max_depth.E.Two, .vec = (10.200,2.220) }, .tu = fmt.test.formatType max_depth.TU{ .ptr = fmt.test.formatType max_depth.TU{ ... } }, .e = fmt.test.formatType max_depth.E.Two, .vec = (10.200,2.220) }&quot;</span>));</span>
<span class="line" id="L2666"></span>
<span class="line" id="L2667">    fbs.reset();</span>
<span class="line" id="L2668">    <span class="tok-kw">try</span> formatType(inst, <span class="tok-str">&quot;&quot;</span>, FormatOptions{}, fbs.writer(), <span class="tok-number">3</span>);</span>
<span class="line" id="L2669">    <span class="tok-kw">try</span> std.testing.expect(mem.eql(<span class="tok-type">u8</span>, fbs.getWritten(), <span class="tok-str">&quot;fmt.test.formatType max_depth.S{ .a = fmt.test.formatType max_depth.S{ .a = fmt.test.formatType max_depth.S{ .a = fmt.test.formatType max_depth.S{ ... }, .tu = fmt.test.formatType max_depth.TU{ ... }, .e = fmt.test.formatType max_depth.E.Two, .vec = (10.200,2.220) }, .tu = fmt.test.formatType max_depth.TU{ .ptr = fmt.test.formatType max_depth.TU{ ... } }, .e = fmt.test.formatType max_depth.E.Two, .vec = (10.200,2.220) }, .tu = fmt.test.formatType max_depth.TU{ .ptr = fmt.test.formatType max_depth.TU{ .ptr = fmt.test.formatType max_depth.TU{ ... } } }, .e = fmt.test.formatType max_depth.E.Two, .vec = (10.200,2.220) }&quot;</span>));</span>
<span class="line" id="L2670">}</span>
<span class="line" id="L2671"></span>
<span class="line" id="L2672"><span class="tok-kw">test</span> <span class="tok-str">&quot;positional&quot;</span> {</span>
<span class="line" id="L2673">    <span class="tok-kw">try</span> expectFmt(<span class="tok-str">&quot;2 1 0&quot;</span>, <span class="tok-str">&quot;{2} {1} {0}&quot;</span>, .{ <span class="tok-builtin">@as</span>(<span class="tok-type">usize</span>, <span class="tok-number">0</span>), <span class="tok-builtin">@as</span>(<span class="tok-type">usize</span>, <span class="tok-number">1</span>), <span class="tok-builtin">@as</span>(<span class="tok-type">usize</span>, <span class="tok-number">2</span>) });</span>
<span class="line" id="L2674">    <span class="tok-kw">try</span> expectFmt(<span class="tok-str">&quot;2 1 0&quot;</span>, <span class="tok-str">&quot;{2} {1} {}&quot;</span>, .{ <span class="tok-builtin">@as</span>(<span class="tok-type">usize</span>, <span class="tok-number">0</span>), <span class="tok-builtin">@as</span>(<span class="tok-type">usize</span>, <span class="tok-number">1</span>), <span class="tok-builtin">@as</span>(<span class="tok-type">usize</span>, <span class="tok-number">2</span>) });</span>
<span class="line" id="L2675">    <span class="tok-kw">try</span> expectFmt(<span class="tok-str">&quot;0 0&quot;</span>, <span class="tok-str">&quot;{0} {0}&quot;</span>, .{<span class="tok-builtin">@as</span>(<span class="tok-type">usize</span>, <span class="tok-number">0</span>)});</span>
<span class="line" id="L2676">    <span class="tok-kw">try</span> expectFmt(<span class="tok-str">&quot;0 1&quot;</span>, <span class="tok-str">&quot;{} {1}&quot;</span>, .{ <span class="tok-builtin">@as</span>(<span class="tok-type">usize</span>, <span class="tok-number">0</span>), <span class="tok-builtin">@as</span>(<span class="tok-type">usize</span>, <span class="tok-number">1</span>) });</span>
<span class="line" id="L2677">    <span class="tok-kw">try</span> expectFmt(<span class="tok-str">&quot;1 0 0 1&quot;</span>, <span class="tok-str">&quot;{1} {} {0} {}&quot;</span>, .{ <span class="tok-builtin">@as</span>(<span class="tok-type">usize</span>, <span class="tok-number">0</span>), <span class="tok-builtin">@as</span>(<span class="tok-type">usize</span>, <span class="tok-number">1</span>) });</span>
<span class="line" id="L2678">}</span>
<span class="line" id="L2679"></span>
<span class="line" id="L2680"><span class="tok-kw">test</span> <span class="tok-str">&quot;positional with specifier&quot;</span> {</span>
<span class="line" id="L2681">    <span class="tok-kw">try</span> expectFmt(<span class="tok-str">&quot;10.0&quot;</span>, <span class="tok-str">&quot;{0d:.1}&quot;</span>, .{<span class="tok-builtin">@as</span>(<span class="tok-type">f64</span>, <span class="tok-number">9.999</span>)});</span>
<span class="line" id="L2682">}</span>
<span class="line" id="L2683"></span>
<span class="line" id="L2684"><span class="tok-kw">test</span> <span class="tok-str">&quot;positional/alignment/width/precision&quot;</span> {</span>
<span class="line" id="L2685">    <span class="tok-kw">try</span> expectFmt(<span class="tok-str">&quot;10.0&quot;</span>, <span class="tok-str">&quot;{0d: &gt;3.1}&quot;</span>, .{<span class="tok-builtin">@as</span>(<span class="tok-type">f64</span>, <span class="tok-number">9.999</span>)});</span>
<span class="line" id="L2686">}</span>
<span class="line" id="L2687"></span>
<span class="line" id="L2688"><span class="tok-kw">test</span> <span class="tok-str">&quot;vector&quot;</span> {</span>
<span class="line" id="L2689">    <span class="tok-kw">if</span> (builtin.target.cpu.arch == .riscv64) {</span>
<span class="line" id="L2690">        <span class="tok-comment">// https://github.com/ziglang/zig/issues/4486</span>
</span>
<span class="line" id="L2691">        <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SkipZigTest;</span>
<span class="line" id="L2692">    }</span>
<span class="line" id="L2693"></span>
<span class="line" id="L2694">    <span class="tok-kw">if</span> (builtin.zig_backend == .stage1) {</span>
<span class="line" id="L2695">        <span class="tok-comment">// Regressed in LLVM 14:</span>
</span>
<span class="line" id="L2696">        <span class="tok-comment">// https://github.com/llvm/llvm-project/issues/55522</span>
</span>
<span class="line" id="L2697">        <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SkipZigTest;</span>
<span class="line" id="L2698">    }</span>
<span class="line" id="L2699"></span>
<span class="line" id="L2700">    <span class="tok-kw">const</span> vbool: <span class="tok-builtin">@Vector</span>(<span class="tok-number">4</span>, <span class="tok-type">bool</span>) = [_]<span class="tok-type">bool</span>{ <span class="tok-null">true</span>, <span class="tok-null">false</span>, <span class="tok-null">true</span>, <span class="tok-null">false</span> };</span>
<span class="line" id="L2701">    <span class="tok-kw">const</span> vi64: <span class="tok-builtin">@Vector</span>(<span class="tok-number">4</span>, <span class="tok-type">i64</span>) = [_]<span class="tok-type">i64</span>{ -<span class="tok-number">2</span>, -<span class="tok-number">1</span>, <span class="tok-number">0</span>, <span class="tok-number">1</span> };</span>
<span class="line" id="L2702">    <span class="tok-kw">const</span> vu64: <span class="tok-builtin">@Vector</span>(<span class="tok-number">4</span>, <span class="tok-type">u64</span>) = [_]<span class="tok-type">u64</span>{ <span class="tok-number">1000</span>, <span class="tok-number">2000</span>, <span class="tok-number">3000</span>, <span class="tok-number">4000</span> };</span>
<span class="line" id="L2703"></span>
<span class="line" id="L2704">    <span class="tok-kw">try</span> expectFmt(<span class="tok-str">&quot;{ true, false, true, false }&quot;</span>, <span class="tok-str">&quot;{}&quot;</span>, .{vbool});</span>
<span class="line" id="L2705">    <span class="tok-kw">try</span> expectFmt(<span class="tok-str">&quot;{ -2, -1, 0, 1 }&quot;</span>, <span class="tok-str">&quot;{}&quot;</span>, .{vi64});</span>
<span class="line" id="L2706">    <span class="tok-kw">try</span> expectFmt(<span class="tok-str">&quot;{    -2,    -1,    +0,    +1 }&quot;</span>, <span class="tok-str">&quot;{d:5}&quot;</span>, .{vi64});</span>
<span class="line" id="L2707">    <span class="tok-kw">try</span> expectFmt(<span class="tok-str">&quot;{ 1000, 2000, 3000, 4000 }&quot;</span>, <span class="tok-str">&quot;{}&quot;</span>, .{vu64});</span>
<span class="line" id="L2708">    <span class="tok-kw">try</span> expectFmt(<span class="tok-str">&quot;{ 3e8, 7d0, bb8, fa0 }&quot;</span>, <span class="tok-str">&quot;{x}&quot;</span>, .{vu64});</span>
<span class="line" id="L2709">}</span>
<span class="line" id="L2710"></span>
<span class="line" id="L2711"><span class="tok-kw">test</span> <span class="tok-str">&quot;enum-literal&quot;</span> {</span>
<span class="line" id="L2712">    <span class="tok-kw">try</span> expectFmt(<span class="tok-str">&quot;.hello_world&quot;</span>, <span class="tok-str">&quot;{}&quot;</span>, .{.hello_world});</span>
<span class="line" id="L2713">}</span>
<span class="line" id="L2714"></span>
<span class="line" id="L2715"><span class="tok-kw">test</span> <span class="tok-str">&quot;padding&quot;</span> {</span>
<span class="line" id="L2716">    <span class="tok-kw">try</span> expectFmt(<span class="tok-str">&quot;Simple&quot;</span>, <span class="tok-str">&quot;{s}&quot;</span>, .{<span class="tok-str">&quot;Simple&quot;</span>});</span>
<span class="line" id="L2717">    <span class="tok-kw">try</span> expectFmt(<span class="tok-str">&quot;      true&quot;</span>, <span class="tok-str">&quot;{:10}&quot;</span>, .{<span class="tok-null">true</span>});</span>
<span class="line" id="L2718">    <span class="tok-kw">try</span> expectFmt(<span class="tok-str">&quot;      true&quot;</span>, <span class="tok-str">&quot;{:&gt;10}&quot;</span>, .{<span class="tok-null">true</span>});</span>
<span class="line" id="L2719">    <span class="tok-kw">try</span> expectFmt(<span class="tok-str">&quot;======true&quot;</span>, <span class="tok-str">&quot;{:=&gt;10}&quot;</span>, .{<span class="tok-null">true</span>});</span>
<span class="line" id="L2720">    <span class="tok-kw">try</span> expectFmt(<span class="tok-str">&quot;true======&quot;</span>, <span class="tok-str">&quot;{:=&lt;10}&quot;</span>, .{<span class="tok-null">true</span>});</span>
<span class="line" id="L2721">    <span class="tok-kw">try</span> expectFmt(<span class="tok-str">&quot;   true   &quot;</span>, <span class="tok-str">&quot;{:^10}&quot;</span>, .{<span class="tok-null">true</span>});</span>
<span class="line" id="L2722">    <span class="tok-kw">try</span> expectFmt(<span class="tok-str">&quot;===true===&quot;</span>, <span class="tok-str">&quot;{:=^10}&quot;</span>, .{<span class="tok-null">true</span>});</span>
<span class="line" id="L2723">    <span class="tok-kw">try</span> expectFmt(<span class="tok-str">&quot;           Minimum width&quot;</span>, <span class="tok-str">&quot;{s:18} width&quot;</span>, .{<span class="tok-str">&quot;Minimum&quot;</span>});</span>
<span class="line" id="L2724">    <span class="tok-kw">try</span> expectFmt(<span class="tok-str">&quot;==================Filled&quot;</span>, <span class="tok-str">&quot;{s:=&gt;24}&quot;</span>, .{<span class="tok-str">&quot;Filled&quot;</span>});</span>
<span class="line" id="L2725">    <span class="tok-kw">try</span> expectFmt(<span class="tok-str">&quot;        Centered        &quot;</span>, <span class="tok-str">&quot;{s:^24}&quot;</span>, .{<span class="tok-str">&quot;Centered&quot;</span>});</span>
<span class="line" id="L2726">    <span class="tok-kw">try</span> expectFmt(<span class="tok-str">&quot;-&quot;</span>, <span class="tok-str">&quot;{s:-^1}&quot;</span>, .{<span class="tok-str">&quot;&quot;</span>});</span>
<span class="line" id="L2727">    <span class="tok-kw">try</span> expectFmt(<span class="tok-str">&quot;==crêpe===&quot;</span>, <span class="tok-str">&quot;{s:=^10}&quot;</span>, .{<span class="tok-str">&quot;crêpe&quot;</span>});</span>
<span class="line" id="L2728">    <span class="tok-kw">try</span> expectFmt(<span class="tok-str">&quot;=====crêpe&quot;</span>, <span class="tok-str">&quot;{s:=&gt;10}&quot;</span>, .{<span class="tok-str">&quot;crêpe&quot;</span>});</span>
<span class="line" id="L2729">    <span class="tok-kw">try</span> expectFmt(<span class="tok-str">&quot;crêpe=====&quot;</span>, <span class="tok-str">&quot;{s:=&lt;10}&quot;</span>, .{<span class="tok-str">&quot;crêpe&quot;</span>});</span>
<span class="line" id="L2730">}</span>
<span class="line" id="L2731"></span>
<span class="line" id="L2732"><span class="tok-kw">test</span> <span class="tok-str">&quot;decimal float padding&quot;</span> {</span>
<span class="line" id="L2733">    <span class="tok-kw">var</span> number: <span class="tok-type">f32</span> = <span class="tok-number">3.1415</span>;</span>
<span class="line" id="L2734">    <span class="tok-kw">try</span> expectFmt(<span class="tok-str">&quot;left-pad:   **3.141\n&quot;</span>, <span class="tok-str">&quot;left-pad:   {d:*&gt;7.3}\n&quot;</span>, .{number});</span>
<span class="line" id="L2735">    <span class="tok-kw">try</span> expectFmt(<span class="tok-str">&quot;center-pad: *3.141*\n&quot;</span>, <span class="tok-str">&quot;center-pad: {d:*^7.3}\n&quot;</span>, .{number});</span>
<span class="line" id="L2736">    <span class="tok-kw">try</span> expectFmt(<span class="tok-str">&quot;right-pad:  3.141**\n&quot;</span>, <span class="tok-str">&quot;right-pad:  {d:*&lt;7.3}\n&quot;</span>, .{number});</span>
<span class="line" id="L2737">}</span>
<span class="line" id="L2738"></span>
<span class="line" id="L2739"><span class="tok-kw">test</span> <span class="tok-str">&quot;sci float padding&quot;</span> {</span>
<span class="line" id="L2740">    <span class="tok-kw">var</span> number: <span class="tok-type">f32</span> = <span class="tok-number">3.1415</span>;</span>
<span class="line" id="L2741">    <span class="tok-kw">try</span> expectFmt(<span class="tok-str">&quot;left-pad:   **3.141e+00\n&quot;</span>, <span class="tok-str">&quot;left-pad:   {e:*&gt;11.3}\n&quot;</span>, .{number});</span>
<span class="line" id="L2742">    <span class="tok-kw">try</span> expectFmt(<span class="tok-str">&quot;center-pad: *3.141e+00*\n&quot;</span>, <span class="tok-str">&quot;center-pad: {e:*^11.3}\n&quot;</span>, .{number});</span>
<span class="line" id="L2743">    <span class="tok-kw">try</span> expectFmt(<span class="tok-str">&quot;right-pad:  3.141e+00**\n&quot;</span>, <span class="tok-str">&quot;right-pad:  {e:*&lt;11.3}\n&quot;</span>, .{number});</span>
<span class="line" id="L2744">}</span>
<span class="line" id="L2745"></span>
<span class="line" id="L2746"><span class="tok-kw">test</span> <span class="tok-str">&quot;null&quot;</span> {</span>
<span class="line" id="L2747">    <span class="tok-kw">const</span> inst = <span class="tok-null">null</span>;</span>
<span class="line" id="L2748">    <span class="tok-kw">try</span> expectFmt(<span class="tok-str">&quot;null&quot;</span>, <span class="tok-str">&quot;{}&quot;</span>, .{inst});</span>
<span class="line" id="L2749">}</span>
<span class="line" id="L2750"></span>
<span class="line" id="L2751"><span class="tok-kw">test</span> <span class="tok-str">&quot;type&quot;</span> {</span>
<span class="line" id="L2752">    <span class="tok-kw">try</span> expectFmt(<span class="tok-str">&quot;u8&quot;</span>, <span class="tok-str">&quot;{}&quot;</span>, .{<span class="tok-type">u8</span>});</span>
<span class="line" id="L2753">    <span class="tok-kw">try</span> expectFmt(<span class="tok-str">&quot;?f32&quot;</span>, <span class="tok-str">&quot;{}&quot;</span>, .{?<span class="tok-type">f32</span>});</span>
<span class="line" id="L2754">    <span class="tok-kw">try</span> expectFmt(<span class="tok-str">&quot;[]const u8&quot;</span>, <span class="tok-str">&quot;{}&quot;</span>, .{[]<span class="tok-kw">const</span> <span class="tok-type">u8</span>});</span>
<span class="line" id="L2755">}</span>
<span class="line" id="L2756"></span>
<span class="line" id="L2757"><span class="tok-kw">test</span> <span class="tok-str">&quot;named arguments&quot;</span> {</span>
<span class="line" id="L2758">    <span class="tok-kw">try</span> expectFmt(<span class="tok-str">&quot;hello world!&quot;</span>, <span class="tok-str">&quot;{s} world{c}&quot;</span>, .{ <span class="tok-str">&quot;hello&quot;</span>, <span class="tok-str">'!'</span> });</span>
<span class="line" id="L2759">    <span class="tok-kw">try</span> expectFmt(<span class="tok-str">&quot;hello world!&quot;</span>, <span class="tok-str">&quot;{[greeting]s} world{[punctuation]c}&quot;</span>, .{ .punctuation = <span class="tok-str">'!'</span>, .greeting = <span class="tok-str">&quot;hello&quot;</span> });</span>
<span class="line" id="L2760">    <span class="tok-kw">try</span> expectFmt(<span class="tok-str">&quot;hello world!&quot;</span>, <span class="tok-str">&quot;{[1]s} world{[0]c}&quot;</span>, .{ <span class="tok-str">'!'</span>, <span class="tok-str">&quot;hello&quot;</span> });</span>
<span class="line" id="L2761">}</span>
<span class="line" id="L2762"></span>
<span class="line" id="L2763"><span class="tok-kw">test</span> <span class="tok-str">&quot;runtime width specifier&quot;</span> {</span>
<span class="line" id="L2764">    <span class="tok-kw">var</span> width: <span class="tok-type">usize</span> = <span class="tok-number">9</span>;</span>
<span class="line" id="L2765">    <span class="tok-kw">try</span> expectFmt(<span class="tok-str">&quot;~~hello~~&quot;</span>, <span class="tok-str">&quot;{s:~^[1]}&quot;</span>, .{ <span class="tok-str">&quot;hello&quot;</span>, width });</span>
<span class="line" id="L2766">    <span class="tok-kw">try</span> expectFmt(<span class="tok-str">&quot;~~hello~~&quot;</span>, <span class="tok-str">&quot;{s:~^[width]}&quot;</span>, .{ .string = <span class="tok-str">&quot;hello&quot;</span>, .width = width });</span>
<span class="line" id="L2767">    <span class="tok-kw">try</span> expectFmt(<span class="tok-str">&quot;    hello&quot;</span>, <span class="tok-str">&quot;{s:[1]}&quot;</span>, .{ <span class="tok-str">&quot;hello&quot;</span>, width });</span>
<span class="line" id="L2768">    <span class="tok-kw">try</span> expectFmt(<span class="tok-str">&quot;42     hello&quot;</span>, <span class="tok-str">&quot;{d} {s:[2]}&quot;</span>, .{ <span class="tok-number">42</span>, <span class="tok-str">&quot;hello&quot;</span>, width });</span>
<span class="line" id="L2769">}</span>
<span class="line" id="L2770"></span>
<span class="line" id="L2771"><span class="tok-kw">test</span> <span class="tok-str">&quot;runtime precision specifier&quot;</span> {</span>
<span class="line" id="L2772">    <span class="tok-kw">var</span> number: <span class="tok-type">f32</span> = <span class="tok-number">3.1415</span>;</span>
<span class="line" id="L2773">    <span class="tok-kw">var</span> precision: <span class="tok-type">usize</span> = <span class="tok-number">2</span>;</span>
<span class="line" id="L2774">    <span class="tok-kw">try</span> expectFmt(<span class="tok-str">&quot;3.14e+00&quot;</span>, <span class="tok-str">&quot;{:1.[1]}&quot;</span>, .{ number, precision });</span>
<span class="line" id="L2775">    <span class="tok-kw">try</span> expectFmt(<span class="tok-str">&quot;3.14e+00&quot;</span>, <span class="tok-str">&quot;{:1.[precision]}&quot;</span>, .{ .number = number, .precision = precision });</span>
<span class="line" id="L2776">}</span>
<span class="line" id="L2777"></span>
</code></pre></body>
</html>